//
//  SettingsViewModel.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// ViewModel for the settings view
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var error: AppError?
    @Published var isDownloadingModel = false
    @Published var downloadProgress: Double = 0.0

    private let languageManager: LanguageManager
    private let translationService: TranslationServiceProtocol
    private let storageService: StorageServiceProtocol

    private let settingsKey = "talklens_app_settings"
    private let defaults = UserDefaults.standard

    init(
        languageManager: LanguageManager,
        translationService: TranslationServiceProtocol,
        storageService: StorageServiceProtocol
    ) {
        self.languageManager = languageManager
        self.translationService = translationService
        self.storageService = storageService

        // Load settings or use defaults
        if let data = defaults.data(forKey: settingsKey),
           let savedSettings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = savedSettings
        } else {
            self.settings = AppSettings()
        }

        // Sync with language manager
        syncWithLanguageManager()
    }

    /// Updates the source language
    func updateSourceLanguage(_ language: Language) {
        settings.sourceLanguage = language
        languageManager.updateSourceLanguage(language)
        saveSettings()
    }

    /// Updates the target language
    func updateTargetLanguage(_ language: Language) {
        settings.targetLanguage = language
        languageManager.updateTargetLanguage(language)
        saveSettings()
    }

    /// Swaps source and target languages
    func swapLanguages() {
        languageManager.swapLanguages()
        settings.sourceLanguage = languageManager.sourceLanguage
        settings.targetLanguage = languageManager.targetLanguage
        saveSettings()
    }

    /// Downloads a language model
    func downloadLanguageModel(_ language: Language) async {
        isDownloadingModel = true
        downloadProgress = 0.0

        do {
            try await languageManager.downloadModel(for: language)
            downloadProgress = 1.0
            isDownloadingModel = false
        } catch {
            self.error = .translationFailed(underlying: error)
            isDownloadingModel = false
            AppLogger.logError(error)
        }
    }

    /// Deletes a language model
    func deleteLanguageModel(_ language: Language) {
        do {
            try languageManager.deleteModel(for: language)
        } catch {
            self.error = .translationFailed(underlying: error)
            AppLogger.logError(error)
        }
    }

    /// Clears the translation cache
    func clearCache() {
        do {
            try storageService.clearAll()
            AppLogger.info("Cache cleared successfully")
        } catch {
            self.error = .storageError(underlying: error)
            AppLogger.logError(error)
        }
    }

    /// Toggles auto-detect language
    func toggleAutoDetect(_ enabled: Bool) {
        settings.autoDetectLanguage = enabled
        if enabled {
            settings.sourceLanguage = .autoDetect
            languageManager.updateSourceLanguage(.autoDetect)
        }
        saveSettings()
    }

    /// Updates auto-capture setting
    func updateAutoCapture(_ enabled: Bool) {
        settings.autoCapture = enabled
        saveSettings()
    }

    /// Updates flash default setting
    func updateFlashDefault(_ enabled: Bool) {
        settings.flashDefaultOn = enabled
        saveSettings()
    }

    /// Updates image quality setting
    func updateImageQuality(_ quality: AppSettings.ImageQuality) {
        settings.imageQuality = quality
        saveSettings()
    }

    /// Updates translation history setting
    func updateKeepHistory(_ enabled: Bool) {
        settings.keepTranslationHistory = enabled
        saveSettings()
    }

    /// Updates keep original images setting
    func updateKeepOriginalImages(_ enabled: Bool) {
        settings.keepOriginalImages = enabled
        saveSettings()
    }

    // MARK: - Private Methods

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: settingsKey)
        }
    }

    private func syncWithLanguageManager() {
        settings.sourceLanguage = languageManager.sourceLanguage
        settings.targetLanguage = languageManager.targetLanguage
    }
}

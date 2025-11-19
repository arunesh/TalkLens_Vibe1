//
//  LanguageManager.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import Combine

/// Manages language selection and model downloads
@MainActor
class LanguageManager: ObservableObject {
    @Published var sourceLanguage: Language
    @Published var targetLanguage: Language
    @Published var availableLanguages: [Language]
    @Published var downloadedLanguages: Set<String>

    private let translationService: TranslationServiceProtocol
    private let defaults = UserDefaults.standard

    private let sourceLanguageKey = "talklens_source_language"
    private let targetLanguageKey = "talklens_target_language"
    private let downloadedLanguagesKey = "talklens_downloaded_languages"

    init(translationService: TranslationServiceProtocol = MockTranslationService()) {
        self.translationService = translationService

        // Load available languages
        self.availableLanguages = Language.allLanguages

        // Load saved languages or use defaults
        if let sourceData = defaults.data(forKey: sourceLanguageKey),
           let savedSource = try? JSONDecoder().decode(Language.self, from: sourceData) {
            self.sourceLanguage = savedSource
        } else {
            self.sourceLanguage = .autoDetect
        }

        if let targetData = defaults.data(forKey: targetLanguageKey),
           let savedTarget = try? JSONDecoder().decode(Language.self, from: targetData) {
            self.targetLanguage = savedTarget
        } else {
            self.targetLanguage = .english
        }

        // Load downloaded languages
        if let downloadedArray = defaults.stringArray(forKey: downloadedLanguagesKey) {
            self.downloadedLanguages = Set(downloadedArray)
        } else {
            self.downloadedLanguages = ["en", "auto"]
        }

        // Update languages with download status
        updateDownloadedLanguages()
    }

    /// Swaps source and target languages
    func swapLanguages() {
        guard sourceLanguage.code != "auto" else { return }

        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp

        saveLanguages()
    }

    /// Updates the source language
    func updateSourceLanguage(_ language: Language) {
        sourceLanguage = language
        saveLanguages()
    }

    /// Updates the target language
    func updateTargetLanguage(_ language: Language) {
        targetLanguage = language
        saveLanguages()
    }

    /// Updates the download status of all languages
    func updateDownloadedLanguages() {
        availableLanguages = availableLanguages.map { language in
            var updated = language
            updated.isDownloaded = translationService.isModelDownloaded(for: language)
            if updated.isDownloaded {
                downloadedLanguages.insert(updated.code)
            }
            return updated
        }
        saveDownloadedLanguages()
    }

    /// Downloads a language model
    func downloadModel(for language: Language) async throws {
        try await translationService.downloadModel(for: language)
        downloadedLanguages.insert(language.code)
        updateDownloadedLanguages()
    }

    /// Deletes a language model
    func deleteModel(for language: Language) throws {
        try translationService.deleteModel(for: language)
        downloadedLanguages.remove(language.code)
        updateDownloadedLanguages()
    }

    /// Checks if a language model is downloaded
    func isModelDownloaded(for language: Language) -> Bool {
        translationService.isModelDownloaded(for: language)
    }

    /// Gets download progress for a language
    func downloadProgress(for language: Language) -> Double {
        translationService.downloadProgress(for: language)
    }

    // MARK: - Private Methods

    private func saveLanguages() {
        if let encoded = try? JSONEncoder().encode(sourceLanguage) {
            defaults.set(encoded, forKey: sourceLanguageKey)
        }
        if let encoded = try? JSONEncoder().encode(targetLanguage) {
            defaults.set(encoded, forKey: targetLanguageKey)
        }
    }

    private func saveDownloadedLanguages() {
        defaults.set(Array(downloadedLanguages), forKey: downloadedLanguagesKey)
    }
}

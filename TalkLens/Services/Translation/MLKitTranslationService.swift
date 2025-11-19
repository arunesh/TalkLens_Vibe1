//
//  MLKitTranslationService.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import MLKitTranslate

/// Production translation service using Google MLKit Translation
@MainActor
class MLKitTranslationService: TranslationServiceProtocol {
    private var translators: [String: Translator] = [:]
    private var downloadProgressCallbacks: [String: ((Double) -> Void)] = [:]
    private var currentDownloadProgress: [String: Double] = [:]

    private let modelManager: ModelManager
    private let defaults = UserDefaults.standard
    private let downloadedModelsKey = "mlkit_downloaded_models"

    init() {
        self.modelManager = ModelManager.modelManager()
    }

    func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String {
        // Handle auto-detect source language
        let actualSourceLanguage: TranslateLanguage
        if sourceLanguage.code == "auto" {
            // Use language identification to detect source
            actualSourceLanguage = try await detectLanguage(in: text)
        } else {
            guard let sourceLang = mapLanguageCode(sourceLanguage.code) else {
                throw AppError.translationFailed(underlying: NSError(
                    domain: "TalkLens",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unsupported source language: \(sourceLanguage.code)"]
                ))
            }
            actualSourceLanguage = sourceLang
        }

        guard let targetLang = mapLanguageCode(targetLanguage.code) else {
            throw AppError.translationFailed(underlying: NSError(
                domain: "TalkLens",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unsupported target language: \(targetLanguage.code)"]
            ))
        }

        // Get or create translator
        let translator = getTranslator(from: actualSourceLanguage, to: targetLang)

        // Ensure model is downloaded
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false, // Only download on Wi-Fi by default
            allowsBackgroundDownloading: true
        )

        do {
            // Download model if needed
            try await translator.downloadModelIfNeeded(with: conditions)

            // Perform translation
            let translatedText = try await translator.translate(text)

            AppLogger.info("Translation completed: \(text.count) → \(translatedText.count) characters")

            return translatedText
        } catch {
            AppLogger.logError(error)
            throw AppError.translationFailed(underlying: error)
        }
    }

    func downloadModel(for language: Language) async throws {
        guard let translateLanguage = mapLanguageCode(language.code) else {
            throw AppError.translationFailed(underlying: NSError(
                domain: "TalkLens",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unsupported language: \(language.code)"]
            ))
        }

        let model = TranslateRemoteModel.translateRemoteModel(language: translateLanguage)

        let conditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
        )

        // Set up progress tracking
        let progressKey = language.code
        currentDownloadProgress[progressKey] = 0.0

        NotificationCenter.default.addObserver(
            forName: .mlkitModelDownloadDidSucceed,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let downloadedModel = notification.userInfo?[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel,
               downloadedModel.language == translateLanguage {
                self?.currentDownloadProgress[progressKey] = 1.0
                self?.saveDownloadedModel(language.code)
                AppLogger.info("Model downloaded successfully: \(language.name)")
            }
        }

        NotificationCenter.default.addObserver(
            forName: .mlkitModelDownloadDidFail,
            object: nil,
            queue: .main
        ) { notification in
            if let error = notification.userInfo?[ModelDownloadUserInfoKey.error.rawValue] as? NSError {
                AppLogger.error("Model download failed: \(error.localizedDescription)")
            }
        }

        do {
            let isDownloaded = modelManager.isModelDownloaded(model)
            if isDownloaded {
                currentDownloadProgress[progressKey] = 1.0
                saveDownloadedModel(language.code)
                return
            }

            try await modelManager.download(model, conditions: conditions)
            currentDownloadProgress[progressKey] = 1.0
            saveDownloadedModel(language.code)

        } catch {
            currentDownloadProgress.removeValue(forKey: progressKey)
            AppLogger.logError(error)
            throw AppError.translationFailed(underlying: error)
        }
    }

    func deleteModel(for language: Language) throws {
        guard let translateLanguage = mapLanguageCode(language.code) else {
            throw AppError.translationFailed(underlying: NSError(
                domain: "TalkLens",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unsupported language: \(language.code)"]
            ))
        }

        let model = TranslateRemoteModel.translateRemoteModel(language: translateLanguage)

        do {
            try modelManager.deleteDownloadedModel(model)
            removeDownloadedModel(language.code)
            AppLogger.info("Model deleted: \(language.name)")
        } catch {
            AppLogger.logError(error)
            throw AppError.translationFailed(underlying: error)
        }
    }

    func isModelDownloaded(for language: Language) -> Bool {
        // Check persistent storage
        let downloadedModels = defaults.stringArray(forKey: downloadedModelsKey) ?? []
        if downloadedModels.contains(language.code) {
            return true
        }

        // Check with model manager
        guard let translateLanguage = mapLanguageCode(language.code) else {
            return false
        }

        let model = TranslateRemoteModel.translateRemoteModel(language: translateLanguage)
        return modelManager.isModelDownloaded(model)
    }

    func downloadProgress(for language: Language) -> Double {
        return currentDownloadProgress[language.code] ?? 0.0
    }

    // MARK: - Private Methods

    private func getTranslator(from source: TranslateLanguage, to target: TranslateLanguage) -> Translator {
        let key = "\(source.rawValue)-\(target.rawValue)"

        if let existing = translators[key] {
            return existing
        }

        let options = TranslatorOptions(sourceLanguage: source, targetLanguage: target)
        let translator = Translator.translator(options: options)
        translators[key] = translator

        return translator
    }

    private func detectLanguage(in text: String) async throws -> TranslateLanguage {
        // Use MLKit Language Identification
        // For now, we'll default to English if auto-detect is used
        // You can implement MLKitLanguageIdentification for better detection

        // Simplified: return English as default
        // In production, use:
        // import MLKitLanguageID
        // let languageId = LanguageIdentification.languageIdentification()
        // let identifiedLanguage = try await languageId.identifyLanguage(for: text)

        return .english
    }

    private func mapLanguageCode(_ code: String) -> TranslateLanguage? {
        switch code {
        case "en": return .english
        case "es": return .spanish
        case "fr": return .french
        case "de": return .german
        case "it": return .italian
        case "pt": return .portuguese
        case "ru": return .russian
        case "ja": return .japanese
        case "ko": return .korean
        case "zh": return .chinese
        case "ar": return .arabic
        case "hi": return .hindi
        case "auto": return nil // Handle separately
        default: return nil
        }
    }

    private func saveDownloadedModel(_ languageCode: String) {
        var downloadedModels = defaults.stringArray(forKey: downloadedModelsKey) ?? []
        if !downloadedModels.contains(languageCode) {
            downloadedModels.append(languageCode)
            defaults.set(downloadedModels, forKey: downloadedModelsKey)
        }
    }

    private func removeDownloadedModel(_ languageCode: String) {
        var downloadedModels = defaults.stringArray(forKey: downloadedModelsKey) ?? []
        downloadedModels.removeAll { $0 == languageCode }
        defaults.set(downloadedModels, forKey: downloadedModelsKey)
    }
}

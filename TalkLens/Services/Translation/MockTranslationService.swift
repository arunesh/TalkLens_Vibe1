//
//  MockTranslationService.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// Mock implementation of translation service for development
class MockTranslationService: TranslationServiceProtocol {
    private var downloadedModels: Set<String> = ["en", "auto"]
    private var downloadProgressValues: [String: Double] = [:]

    func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String {
        // Simulate translation
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Return mock translation
        return "[\(targetLanguage.name) Translation]\n\n" + text
    }

    func downloadModel(for language: Language) async throws {
        guard !isModelDownloaded(for: language) else { return }

        // Simulate download with progress
        downloadProgressValues[language.code] = 0.0

        for i in 1...10 {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            downloadProgressValues[language.code] = Double(i) / 10.0
        }

        downloadedModels.insert(language.code)
        downloadProgressValues.removeValue(forKey: language.code)
    }

    func deleteModel(for language: Language) throws {
        downloadedModels.remove(language.code)
    }

    func isModelDownloaded(for language: Language) -> Bool {
        downloadedModels.contains(language.code)
    }

    func downloadProgress(for language: Language) -> Double {
        downloadProgressValues[language.code] ?? 0.0
    }
}

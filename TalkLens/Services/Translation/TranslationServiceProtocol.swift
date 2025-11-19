//
//  TranslationServiceProtocol.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// Protocol for translation services
protocol TranslationServiceProtocol {
    /// Translates text from one language to another
    /// - Parameters:
    ///   - text: The text to translate
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    /// - Returns: Translated text
    func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String

    /// Downloads a translation model for the specified language
    /// - Parameter language: The language model to download
    func downloadModel(for language: Language) async throws

    /// Deletes a translation model for the specified language
    /// - Parameter language: The language model to delete
    func deleteModel(for language: Language) throws

    /// Checks if a model is downloaded for the specified language
    /// - Parameter language: The language to check
    /// - Returns: true if model is downloaded, false otherwise
    func isModelDownloaded(for language: Language) -> Bool

    /// Gets the download progress for a language model
    /// - Parameter language: The language being downloaded
    /// - Returns: Progress value between 0.0 and 1.0
    func downloadProgress(for language: Language) -> Double
}

//
//  Language.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// Represents a language supported by the app
struct Language: Codable, Hashable, Identifiable {
    let id: String  // ISO 639-1 code (e.g., "en", "es", "fr")
    let code: String // ISO 639-1 code
    let name: String // Display name (e.g., "English", "Spanish")
    var isDownloaded: Bool

    init(code: String, name: String, isDownloaded: Bool = false) {
        self.id = code
        self.code = code
        self.name = name
        self.isDownloaded = isDownloaded
    }

    // Common languages
    static let english = Language(code: "en", name: "English", isDownloaded: true)
    static let spanish = Language(code: "es", name: "Spanish")
    static let french = Language(code: "fr", name: "French")
    static let german = Language(code: "de", name: "German")
    static let italian = Language(code: "it", name: "Italian")
    static let portuguese = Language(code: "pt", name: "Portuguese")
    static let russian = Language(code: "ru", name: "Russian")
    static let japanese = Language(code: "ja", name: "Japanese")
    static let korean = Language(code: "ko", name: "Korean")
    static let chinese = Language(code: "zh", name: "Chinese (Simplified)")
    static let arabic = Language(code: "ar", name: "Arabic")
    static let hindi = Language(code: "hi", name: "Hindi")

    // Auto-detect option
    static let autoDetect = Language(code: "auto", name: "Auto-Detect", isDownloaded: true)

    // All supported languages
    static let allLanguages: [Language] = [
        .autoDetect,
        .english,
        .spanish,
        .french,
        .german,
        .italian,
        .portuguese,
        .russian,
        .japanese,
        .korean,
        .chinese,
        .arabic,
        .hindi
    ]
}

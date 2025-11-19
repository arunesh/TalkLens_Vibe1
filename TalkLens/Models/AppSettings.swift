//
//  AppSettings.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// App-wide settings and preferences
struct AppSettings: Codable {
    var sourceLanguage: Language
    var targetLanguage: Language
    var autoDetectLanguage: Bool
    var autoCapture: Bool
    var flashDefaultOn: Bool
    var imageQuality: ImageQuality
    var keepTranslationHistory: Bool
    var keepOriginalImages: Bool

    init(
        sourceLanguage: Language = .autoDetect,
        targetLanguage: Language = .english,
        autoDetectLanguage: Bool = true,
        autoCapture: Bool = true,
        flashDefaultOn: Bool = false,
        imageQuality: ImageQuality = .high,
        keepTranslationHistory: Bool = true,
        keepOriginalImages: Bool = true
    ) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.autoDetectLanguage = autoDetectLanguage
        self.autoCapture = autoCapture
        self.flashDefaultOn = flashDefaultOn
        self.imageQuality = imageQuality
        self.keepTranslationHistory = keepTranslationHistory
        self.keepOriginalImages = keepOriginalImages
    }

    enum ImageQuality: String, Codable, CaseIterable {
        case high = "High"
        case medium = "Medium"

        var compressionQuality: CGFloat {
            switch self {
            case .high:
                return 0.9
            case .medium:
                return 0.7
            }
        }
    }
}

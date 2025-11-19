//
//  DocumentProcessor.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit

/// Orchestrates the OCR and translation pipeline
class DocumentProcessor {
    private let ocrService: OCRServiceProtocol
    private let translationService: TranslationServiceProtocol

    init(
        ocrService: OCRServiceProtocol,
        translationService: TranslationServiceProtocol
    ) {
        self.ocrService = ocrService
        self.translationService = translationService
    }

    /// Processes a document by performing OCR and translation on all pages
    /// - Parameter document: The document to process
    /// - Returns: Updated document with recognized and translated text
    func processDocument(_ document: Document) async throws -> Document {
        var updatedDocument = document
        updatedDocument.status = .recognizing

        // Process each page
        var updatedPages: [DocumentPage] = []

        for page in document.pages {
            guard let image = page.image else {
                throw AppError.imageProcessingFailed
            }

            // OCR
            let recognizedText = try await ocrService.recognizeText(
                in: image,
                language: document.sourceLanguage.code != "auto" ? document.sourceLanguage : nil
            )

            var updatedPage = page
            updatedPage.recognizedText = recognizedText.text

            updatedPages.append(updatedPage)
        }

        updatedDocument.pages = updatedPages
        updatedDocument.status = .translating

        // Translate all pages
        updatedPages = []
        for page in updatedDocument.pages {
            guard let text = page.recognizedText else { continue }

            let translatedText = try await translationService.translate(
                text: text,
                from: document.sourceLanguage,
                to: document.targetLanguage
            )

            var updatedPage = page
            updatedPage.translatedText = translatedText
            updatedPages.append(updatedPage)
        }

        updatedDocument.pages = updatedPages
        updatedDocument.status = .completed

        return updatedDocument
    }
}

/// App-specific errors
enum AppError: LocalizedError {
    case cameraAccessDenied
    case photosAccessDenied
    case ocrFailed(underlying: Error)
    case translationFailed(underlying: Error)
    case modelNotDownloaded(language: Language)
    case networkRequired
    case imageProcessingFailed
    case storageError(underlying: Error)
    case unknown(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            return "Camera access is required to scan documents."
        case .photosAccessDenied:
            return "Photos access is required to import images."
        case .ocrFailed(let error):
            return "Text recognition failed: \(error.localizedDescription)"
        case .translationFailed(let error):
            return "Translation failed: \(error.localizedDescription)"
        case .modelNotDownloaded(let language):
            return "Translation model for \(language.name) is not downloaded."
        case .networkRequired:
            return "Network connection required to download models."
        case .imageProcessingFailed:
            return "Failed to process image."
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .unknown(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}

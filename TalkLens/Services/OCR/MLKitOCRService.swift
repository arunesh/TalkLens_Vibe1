//
//  MLKitOCRService.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit
import MLKitTextRecognition
import MLKitVision

/// Production OCR service using Google MLKit Text Recognition
class MLKitOCRService: OCRServiceProtocol {
    private let textRecognizer: TextRecognizer

    init() {
        // Use Latin script recognizer by default (supports most languages)
        // For specific language scripts, you can use:
        // - TextRecognizer.chineseTextRecognizer() for Chinese
        // - TextRecognizer.devanagariTextRecognizer() for Devanagari
        // - TextRecognizer.japaneseTextRecognizer() for Japanese
        // - TextRecognizer.koreanTextRecognizer() for Korean
        textRecognizer = TextRecognizer.textRecognizer()
    }

    func recognizeText(
        in image: UIImage,
        language: Language?
    ) async throws -> RecognizedText {
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation

        do {
            let result = try await textRecognizer.process(visionImage)

            // Extract all text from recognized blocks
            let recognizedText = result.text

            // Calculate average confidence from blocks
            let confidence = calculateAverageConfidence(from: result)

            AppLogger.info("OCR completed: \(recognizedText.count) characters recognized")

            return RecognizedText(
                text: recognizedText,
                confidence: confidence,
                language: language
            )
        } catch {
            AppLogger.logError(error)
            throw AppError.ocrFailed(underlying: error)
        }
    }

    // MARK: - Private Methods

    private func calculateAverageConfidence(from result: Text) -> Float {
        // MLKit doesn't provide direct confidence scores in all cases
        // We can estimate based on the number of recognized blocks
        // For a more accurate implementation, you could analyze individual elements

        guard !result.blocks.isEmpty else { return 0.0 }

        // Return a heuristic confidence based on text structure
        let hasBlocks = !result.blocks.isEmpty
        let hasLines = result.blocks.contains { !$0.lines.isEmpty }
        let hasElements = result.blocks.contains { block in
            block.lines.contains { !$0.elements.isEmpty }
        }

        if hasElements {
            return 0.95
        } else if hasLines {
            return 0.85
        } else if hasBlocks {
            return 0.75
        } else {
            return 0.5
        }
    }
}

/// Extended MLKit OCR service that can switch recognizers based on language
class AdaptiveMLKitOCRService: OCRServiceProtocol {
    func recognizeText(
        in image: UIImage,
        language: Language?
    ) async throws -> RecognizedText {
        let textRecognizer = selectRecognizer(for: language)
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation

        do {
            let result = try await textRecognizer.process(visionImage)
            let confidence = calculateAverageConfidence(from: result)

            AppLogger.info("OCR completed with \(language?.name ?? "auto") recognizer: \(result.text.count) characters")

            return RecognizedText(
                text: result.text,
                confidence: confidence,
                language: language
            )
        } catch {
            AppLogger.logError(error)
            throw AppError.ocrFailed(underlying: error)
        }
    }

    // MARK: - Private Methods

    private func selectRecognizer(for language: Language?) -> TextRecognizer {
        guard let language = language else {
            return TextRecognizer.textRecognizer()
        }

        switch language.code {
        case "zh":
            return TextRecognizer.chineseTextRecognizer()
        case "hi":
            return TextRecognizer.devanagariTextRecognizer()
        case "ja":
            return TextRecognizer.japaneseTextRecognizer()
        case "ko":
            return TextRecognizer.koreanTextRecognizer()
        default:
            return TextRecognizer.textRecognizer()
        }
    }

    private func calculateAverageConfidence(from result: Text) -> Float {
        guard !result.blocks.isEmpty else { return 0.0 }

        let hasBlocks = !result.blocks.isEmpty
        let hasLines = result.blocks.contains { !$0.lines.isEmpty }
        let hasElements = result.blocks.contains { block in
            block.lines.contains { !$0.elements.isEmpty }
        }

        if hasElements {
            return 0.95
        } else if hasLines {
            return 0.85
        } else if hasBlocks {
            return 0.75
        } else {
            return 0.5
        }
    }
}

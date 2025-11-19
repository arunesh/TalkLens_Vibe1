//
//  MockOCRService.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit

/// Mock implementation of OCR service for development
class MockOCRService: OCRServiceProtocol {
    func recognizeText(
        in image: UIImage,
        language: Language?
    ) async throws -> RecognizedText {
        // Simulate OCR processing
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Return mock text
        return RecognizedText(
            text: "This is sample recognized text from the image.\n\nIt contains multiple lines and paragraphs to simulate real OCR output.",
            confidence: 0.95,
            language: language ?? .english
        )
    }
}

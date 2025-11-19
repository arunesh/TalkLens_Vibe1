//
//  OCRServiceProtocol.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit

/// Result of text recognition
struct RecognizedText {
    let text: String
    let confidence: Float
    let language: Language?
}

/// Protocol for OCR (Optical Character Recognition) services
protocol OCRServiceProtocol {
    /// Recognizes text in the given image
    /// - Parameters:
    ///   - image: The image to recognize text from
    ///   - language: Optional language hint for better recognition
    /// - Returns: RecognizedText containing the extracted text
    func recognizeText(
        in image: UIImage,
        language: Language?
    ) async throws -> RecognizedText
}

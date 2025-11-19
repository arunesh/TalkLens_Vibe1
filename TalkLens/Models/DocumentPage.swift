//
//  DocumentPage.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit

/// Represents a single page in a document
struct DocumentPage: Identifiable, Codable {
    let id: UUID
    let imageData: Data
    var recognizedText: String?
    var translatedText: String?
    let pageNumber: Int

    init(id: UUID = UUID(), imageData: Data, recognizedText: String? = nil, translatedText: String? = nil, pageNumber: Int) {
        self.id = id
        self.imageData = imageData
        self.recognizedText = recognizedText
        self.translatedText = translatedText
        self.pageNumber = pageNumber
    }

    // Helper to get UIImage from data
    var image: UIImage? {
        UIImage(data: imageData)
    }

    // Helper to create from UIImage
    static func from(image: UIImage, pageNumber: Int, compressionQuality: CGFloat = 0.8) -> DocumentPage? {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        return DocumentPage(imageData: data, pageNumber: pageNumber)
    }
}

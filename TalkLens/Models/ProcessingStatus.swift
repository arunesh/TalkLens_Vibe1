//
//  ProcessingStatus.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// Represents the processing status of a document
enum ProcessingStatus: String, Codable {
    case pending      // Not yet started
    case recognizing  // OCR in progress
    case translating  // Translation in progress
    case completed    // Successfully completed
    case failed       // Processing failed

    var displayText: String {
        switch self {
        case .pending:
            return "Pending"
        case .recognizing:
            return "Recognizing text..."
        case .translating:
            return "Translating..."
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        }
    }
}

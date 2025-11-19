//
//  Document.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// Represents a multi-page document with translation
struct Document: Identifiable, Codable {
    let id: UUID
    var pages: [DocumentPage]
    let sourceLanguage: Language
    let targetLanguage: Language
    let createdAt: Date
    var status: ProcessingStatus

    init(
        id: UUID = UUID(),
        pages: [DocumentPage],
        sourceLanguage: Language,
        targetLanguage: Language,
        createdAt: Date = Date(),
        status: ProcessingStatus = .pending
    ) {
        self.id = id
        self.pages = pages
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.createdAt = createdAt
        self.status = status
    }

    var pageCount: Int {
        pages.count
    }

    var isComplete: Bool {
        status == .completed
    }

    var isFailed: Bool {
        status == .failed
    }

    // Helper to get first page thumbnail
    var thumbnailPage: DocumentPage? {
        pages.first
    }
}

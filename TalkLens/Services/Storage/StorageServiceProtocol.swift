//
//  StorageServiceProtocol.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// Protocol for data persistence services
protocol StorageServiceProtocol {
    /// Saves a document to storage
    /// - Parameter document: The document to save
    func saveDocument(_ document: Document) throws

    /// Fetches all saved documents
    /// - Returns: Array of documents
    func fetchDocuments() throws -> [Document]

    /// Deletes a document by ID
    /// - Parameter id: The document ID to delete
    func deleteDocument(_ id: UUID) throws

    /// Clears all saved documents
    func clearAll() throws
}

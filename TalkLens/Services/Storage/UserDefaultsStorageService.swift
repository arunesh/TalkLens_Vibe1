//
//  UserDefaultsStorageService.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// Simple storage implementation using UserDefaults
class UserDefaultsStorageService: StorageServiceProtocol {
    private let documentsKey = "talklens_documents"
    private let defaults = UserDefaults.standard

    func saveDocument(_ document: Document) throws {
        var documents = try fetchDocuments()

        // Update existing or add new
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index] = document
        } else {
            documents.append(document)
        }

        // Encode and save
        let encoded = try JSONEncoder().encode(documents)
        defaults.set(encoded, forKey: documentsKey)
    }

    func fetchDocuments() throws -> [Document] {
        guard let data = defaults.data(forKey: documentsKey) else {
            return []
        }

        let documents = try JSONDecoder().decode([Document].self, from: data)
        return documents.sorted { $0.createdAt > $1.createdAt }
    }

    func deleteDocument(_ id: UUID) throws {
        var documents = try fetchDocuments()
        documents.removeAll { $0.id == id }

        let encoded = try JSONEncoder().encode(documents)
        defaults.set(encoded, forKey: documentsKey)
    }

    func clearAll() throws {
        defaults.removeObject(forKey: documentsKey)
    }
}

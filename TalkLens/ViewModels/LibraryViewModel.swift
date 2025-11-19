//
//  LibraryViewModel.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit

/// ViewModel for the library view
@MainActor
class LibraryViewModel: ObservableObject {
    @Published var documents: [Document] = []
    @Published var isLoading = false
    @Published var selectedDocument: Document?
    @Published var error: AppError?
    @Published var searchQuery = ""
    @Published var isImporting = false

    private let storageService: StorageServiceProtocol
    private let documentProcessor: DocumentProcessor
    private let languageManager: LanguageManager

    init(
        storageService: StorageServiceProtocol,
        documentProcessor: DocumentProcessor,
        languageManager: LanguageManager
    ) {
        self.storageService = storageService
        self.documentProcessor = documentProcessor
        self.languageManager = languageManager
    }

    /// Loads documents from storage
    func loadDocuments() {
        isLoading = true

        do {
            documents = try storageService.fetchDocuments()
            isLoading = false
        } catch {
            self.error = .storageError(underlying: error)
            isLoading = false
            AppLogger.logError(error)
        }
    }

    /// Imports images and processes them
    func importImages(_ images: [UIImage]) async {
        guard !images.isEmpty else { return }

        isImporting = true

        // Convert images to pages
        let pages = images.enumerated().compactMap { index, image in
            DocumentPage.from(image: image, pageNumber: index + 1)
        }

        guard !pages.isEmpty else {
            isImporting = false
            return
        }

        // Create document
        let document = Document(
            pages: pages,
            sourceLanguage: languageManager.sourceLanguage,
            targetLanguage: languageManager.targetLanguage
        )

        do {
            // Process document
            let processed = try await documentProcessor.processDocument(document)

            // Save document
            try storageService.saveDocument(processed)

            // Reload documents
            loadDocuments()

            // Select the new document
            selectedDocument = processed

            isImporting = false

        } catch {
            self.error = .translationFailed(underlying: error)
            isImporting = false
            AppLogger.logError(error)
        }
    }

    /// Deletes a document
    func deleteDocument(_ document: Document) {
        do {
            try storageService.deleteDocument(document.id)
            documents.removeAll { $0.id == document.id }
            AppLogger.info("Deleted document \(document.id)")
        } catch {
            self.error = .storageError(underlying: error)
            AppLogger.logError(error)
        }
    }

    /// Searches documents based on query
    func searchDocuments(query: String) {
        searchQuery = query

        guard !query.isEmpty else {
            loadDocuments()
            return
        }

        do {
            let allDocuments = try storageService.fetchDocuments()
            documents = allDocuments.filter { document in
                // Search in recognized text
                let textMatch = document.pages.contains { page in
                    page.recognizedText?.localizedCaseInsensitiveContains(query) == true ||
                    page.translatedText?.localizedCaseInsensitiveContains(query) == true
                }

                // Search in language names
                let languageMatch = document.sourceLanguage.name.localizedCaseInsensitiveContains(query) ||
                                  document.targetLanguage.name.localizedCaseInsensitiveContains(query)

                return textMatch || languageMatch
            }
        } catch {
            self.error = .storageError(underlying: error)
            AppLogger.logError(error)
        }
    }

    /// Clears the search query
    func clearSearch() {
        searchQuery = ""
        loadDocuments()
    }
}

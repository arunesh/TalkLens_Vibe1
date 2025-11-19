//
//  CameraViewModel.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit
import Combine

/// ViewModel for the camera view
@MainActor
class CameraViewModel: ObservableObject {
    @Published var capturedPages: [DocumentPage] = []
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    @Published var error: AppError?
    @Published var showResults = false
    @Published var processedDocument: Document?

    private let cameraService: CameraServiceProtocol
    private let documentProcessor: DocumentProcessor
    private let languageManager: LanguageManager
    private let storageService: StorageServiceProtocol

    init(
        cameraService: CameraServiceProtocol,
        documentProcessor: DocumentProcessor,
        languageManager: LanguageManager,
        storageService: StorageServiceProtocol
    ) {
        self.cameraService = cameraService
        self.documentProcessor = documentProcessor
        self.languageManager = languageManager
        self.storageService = storageService
    }

    /// Captures an image from the camera
    func captureImage() async {
        do {
            let image = try await cameraService.capturePhoto()
            let pageNumber = capturedPages.count + 1

            if let page = DocumentPage.from(image: image, pageNumber: pageNumber) {
                capturedPages.append(page)
                AppLogger.info("Captured page \(pageNumber)")
            }

        } catch {
            self.error = .imageProcessingFailed
            AppLogger.logError(error)
        }
    }

    /// Deletes a page from the captured pages
    func deletePage(_ page: DocumentPage) {
        capturedPages.removeAll { $0.id == page.id }

        // Renumber remaining pages
        for (index, var updatedPage) in capturedPages.enumerated() {
            updatedPage = DocumentPage(
                id: updatedPage.id,
                imageData: updatedPage.imageData,
                recognizedText: updatedPage.recognizedText,
                translatedText: updatedPage.translatedText,
                pageNumber: index + 1
            )
            capturedPages[index] = updatedPage
        }
    }

    /// Processes and translates all captured pages
    func translate() async {
        guard !capturedPages.isEmpty else { return }

        isProcessing = true
        processingProgress = 0.0
        error = nil

        do {
            // Create document
            let document = Document(
                pages: capturedPages,
                sourceLanguage: languageManager.sourceLanguage,
                targetLanguage: languageManager.targetLanguage
            )

            // Process document
            let processed = try await documentProcessor.processDocument(document)

            processingProgress = 1.0

            // Save document
            try storageService.saveDocument(processed)

            // Show results
            processedDocument = processed
            showResults = true

            // Clear captured pages
            capturedPages.removeAll()

            isProcessing = false

        } catch {
            self.error = .translationFailed(underlying: error)
            isProcessing = false
            AppLogger.logError(error)
        }
    }

    /// Toggles the camera flash
    func toggleFlash() {
        cameraService.toggleFlash()
    }

    /// Starts the camera session
    func startCamera() {
        cameraService.startSession()
    }

    /// Stops the camera session
    func stopCamera() {
        cameraService.stopSession()
    }
}

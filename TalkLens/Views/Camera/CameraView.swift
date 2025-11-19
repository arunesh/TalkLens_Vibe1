//
//  CameraView.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel
    @EnvironmentObject var languageManager: LanguageManager

    init() {
        let cameraService = MockCameraService()
        let ocrService = MockOCRService()
        let translationService = MockTranslationService()
        let documentProcessor = DocumentProcessor(
            ocrService: ocrService,
            translationService: translationService
        )
        let storageService = UserDefaultsStorageService()
        let languageManager = LanguageManager()

        _viewModel = StateObject(wrappedValue: CameraViewModel(
            cameraService: cameraService,
            documentProcessor: documentProcessor,
            languageManager: languageManager,
            storageService: storageService
        ))
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Camera Preview Placeholder
                Color.black
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    // Page Thumbnails
                    if !viewModel.capturedPages.isEmpty {
                        PageThumbnailStrip(pages: viewModel.capturedPages) { page in
                            viewModel.deletePage(page)
                        }
                        .padding(.bottom, 20)
                    }

                    // Controls
                    CameraControls(
                        viewModel: viewModel,
                        onCapture: {
                            Task {
                                await viewModel.captureImage()
                            }
                        },
                        onTranslate: {
                            Task {
                                await viewModel.translate()
                            }
                        }
                    )
                    .padding(.bottom, 40)
                }

                // Processing Overlay
                if viewModel.isProcessing {
                    LoadingOverlay(
                        message: "Processing...",
                        progress: viewModel.processingProgress
                    )
                }
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    LanguageIndicator(
                        source: languageManager.sourceLanguage,
                        target: languageManager.targetLanguage
                    )
                }
            }
            .sheet(isPresented: $viewModel.showResults) {
                if let document = viewModel.processedDocument {
                    TranslationResultView(document: document)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .onAppear {
                viewModel.startCamera()
            }
            .onDisappear {
                viewModel.stopCamera()
            }
        }
    }
}

struct CameraControls: View {
    @ObservedObject var viewModel: CameraViewModel
    let onCapture: () -> Void
    let onTranslate: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            // Flash Toggle
            Button(action: {
                viewModel.toggleFlash()
            }) {
                Image(systemName: viewModel.cameraService.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
            }

            // Capture Button
            Button(action: onCapture) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 70, height: 70)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                }
            }

            // Translate Button
            if !viewModel.capturedPages.isEmpty {
                Button(action: onTranslate) {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            } else {
                Color.clear
                    .frame(width: 60, height: 60)
            }
        }
    }
}

struct PageThumbnailStrip: View {
    let pages: [DocumentPage]
    let onDelete: (DocumentPage) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(pages) { page in
                    PageThumbnail(page: page) {
                        onDelete(page)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 100)
    }
}

struct PageThumbnail: View {
    let page: DocumentPage
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = page.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }

            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .offset(x: 8, y: -8)
        }
    }
}

struct LanguageIndicator: View {
    let source: Language
    let target: Language

    var body: some View {
        Text("\(source.code.uppercased()) → \(target.code.uppercased())")
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.systemGray5))
            .cornerRadius(12)
    }
}

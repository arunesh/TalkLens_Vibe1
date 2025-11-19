//
//  LibraryView.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI
import PhotosUI

struct LibraryView: View {
    @StateObject private var viewModel: LibraryViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingImagePicker = false
    @State private var selectedImages: [UIImage] = []

    init() {
        let storageService = UserDefaultsStorageService()
        let ocrService = MockOCRService()
        let translationService = MockTranslationService()
        let documentProcessor = DocumentProcessor(
            ocrService: ocrService,
            translationService: translationService
        )
        let languageManager = LanguageManager()

        _viewModel = StateObject(wrappedValue: LibraryViewModel(
            storageService: storageService,
            documentProcessor: documentProcessor,
            languageManager: languageManager
        ))
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.documents.isEmpty {
                    EmptyLibraryView {
                        showingImagePicker = true
                    }
                } else {
                    DocumentList(viewModel: viewModel)
                }

                // Loading Overlay
                if viewModel.isImporting {
                    LoadingOverlay(message: "Processing images...")
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search documents")
            .onChange(of: viewModel.searchQuery) { newValue in
                if newValue.isEmpty {
                    viewModel.loadDocuments()
                } else {
                    viewModel.searchDocuments(query: newValue)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(images: $selectedImages)
            }
            .onChange(of: selectedImages) { images in
                guard !images.isEmpty else { return }
                Task {
                    await viewModel.importImages(images)
                    selectedImages = []
                }
            }
            .sheet(item: $viewModel.selectedDocument) { document in
                TranslationResultView(document: document)
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
                viewModel.loadDocuments()
            }
        }
    }
}

struct EmptyLibraryView: View {
    let onImport: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Documents Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Import images to get started")
                .foregroundColor(.secondary)

            Button(action: onImport) {
                Text("Import Images")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
    }
}

struct DocumentList: View {
    @ObservedObject var viewModel: LibraryViewModel

    var body: some View {
        List {
            ForEach(viewModel.documents) { document in
                DocumentCard(document: document)
                    .onTapGesture {
                        viewModel.selectedDocument = document
                    }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.deleteDocument(viewModel.documents[index])
                }
            }
        }
        .refreshable {
            viewModel.loadDocuments()
        }
    }
}

struct DocumentCard: View {
    let document: Document

    var body: some View {
        HStack(spacing: 15) {
            // Thumbnail
            if let page = document.thumbnailPage, let image = page.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 80)
            }

            // Document Info
            VStack(alignment: .leading, spacing: 6) {
                Text("\(document.sourceLanguage.name) → \(document.targetLanguage.name)")
                    .font(.headline)

                Text("\(document.pageCount) page\(document.pageCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(document.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Status Badge
                StatusBadge(status: document.status)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct StatusBadge: View {
    let status: ProcessingStatus

    var body: some View {
        Text(status.displayText)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }

    var statusColor: Color {
        switch status {
        case .pending:
            return .gray
        case .recognizing, .translating:
            return .orange
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
}

// Simple Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 10

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            var loadedImages: [UIImage] = []

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                loadedImages.append(image)
                                if loadedImages.count == results.count {
                                    self.parent.images = loadedImages
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

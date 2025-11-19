//
//  TranslationResultView.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct TranslationResultView: View {
    let document: Document
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var showingOriginal = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Language Indicator
                HStack {
                    Text("\(document.sourceLanguage.name) → \(document.targetLanguage.name)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()

                // Toggle View Mode
                Picker("View Mode", selection: $showingOriginal) {
                    Text("Translation").tag(false)
                    Text("Original").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Page Content
                if document.pages.indices.contains(currentPage) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Image Preview
                            if let image = document.pages[currentPage].image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }

                            // Text Content
                            if showingOriginal {
                                if let text = document.pages[currentPage].recognizedText {
                                    TextBlock(title: "Original Text", text: text)
                                }
                            } else {
                                if let text = document.pages[currentPage].translatedText {
                                    TextBlock(title: "Translated Text", text: text)
                                }
                            }
                        }
                        .padding()
                    }
                }

                // Page Navigation
                if document.pageCount > 1 {
                    HStack {
                        Button(action: {
                            if currentPage > 0 {
                                currentPage -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage == 0)

                        Spacer()

                        Text("Page \(currentPage + 1) of \(document.pageCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Button(action: {
                            if currentPage < document.pageCount - 1 {
                                currentPage += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(currentPage < document.pageCount - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= document.pageCount - 1)
                    }
                    .padding()
                }
            }
            .navigationTitle("Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            copyText()
                        }) {
                            Label("Copy Text", systemImage: "doc.on.doc")
                        }

                        Button(action: {
                            shareDocument()
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    func copyText() {
        let text = showingOriginal
            ? document.pages[currentPage].recognizedText
            : document.pages[currentPage].translatedText

        if let text = text {
            UIPasteboard.general.string = text
        }
    }

    func shareDocument() {
        // TODO: Implement share functionality
    }
}

struct TextBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = text
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }

            Text(text)
                .font(.body)
                .textSelection(.enabled)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

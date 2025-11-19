//
//  ModelDownloadScreen.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct ModelDownloadScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Download Language Models")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Required for offline translation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 60)

            Spacer()

            // Model Information
            VStack(spacing: 20) {
                if let source = viewModel.selectedSourceLanguage,
                   let target = viewModel.selectedTargetLanguage {

                    ModelInfoCard(language: source)

                    if source.code != target.code {
                        ModelInfoCard(language: target)
                    }

                    // Total Size
                    HStack {
                        Text("Total Size")
                            .font(.headline)
                        Spacer()
                        Text("~60-80 MB")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                // Network Warning
                HStack(spacing: 12) {
                    Image(systemName: "wifi")
                        .foregroundColor(.orange)
                    Text("Wi-Fi connection recommended")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // Progress Bar
            if viewModel.isDownloading {
                VStack(spacing: 10) {
                    ProgressView(value: viewModel.downloadProgress)
                        .progressViewStyle(.linear)

                    Text("\(Int(viewModel.downloadProgress * 100))% Complete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
            }

            // Buttons
            if !viewModel.isDownloading {
                VStack(spacing: 15) {
                    Button(action: {
                        Task {
                            await viewModel.downloadRequiredModels()
                            viewModel.nextStep()
                        }
                    }) {
                        Text("Download Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        viewModel.skipDownload()
                    }) {
                        Text("Download Later")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 40)
            }

            Spacer()
        }
        .padding(.bottom, 40)
    }
}

struct ModelInfoCard: View {
    let language: Language

    var body: some View {
        HStack {
            Image(systemName: "doc.text")
                .foregroundColor(.blue)
            Text(language.name)
                .font(.headline)
            Spacer()
            Text("~30-40 MB")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

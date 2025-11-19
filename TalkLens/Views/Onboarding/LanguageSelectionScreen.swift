//
//  LanguageSelectionScreen.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct LanguageSelectionScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @ObservedObject var languageManager: LanguageManager

    @State private var sourceLanguage: Language = .autoDetect
    @State private var targetLanguage: Language = .english

    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "globe")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Choose Your Languages")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Select the languages you want to translate between")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 60)

            Spacer()

            // Language Selection
            VStack(spacing: 30) {
                // Source Language
                VStack(alignment: .leading, spacing: 10) {
                    Text("From")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Picker("Source Language", selection: $sourceLanguage) {
                        ForEach(languageManager.availableLanguages) { language in
                            Text(language.name).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                // Swap Button
                Button(action: {
                    if sourceLanguage.code != "auto" {
                        let temp = sourceLanguage
                        sourceLanguage = targetLanguage
                        targetLanguage = temp
                    }
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title2)
                        .foregroundColor(.blue)
                }

                // Target Language
                VStack(alignment: .leading, spacing: 10) {
                    Text("To")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Picker("Target Language", selection: $targetLanguage) {
                        ForEach(languageManager.availableLanguages.filter { $0.code != "auto" }) { language in
                            Text(language.name).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // Popular Pairs
            VStack(alignment: .leading, spacing: 10) {
                Text("Popular Pairs")
                    .font(.headline)
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        PopularPairButton(from: "Spanish", to: "English") {
                            sourceLanguage = .spanish
                            targetLanguage = .english
                        }
                        PopularPairButton(from: "French", to: "English") {
                            sourceLanguage = .french
                            targetLanguage = .english
                        }
                        PopularPairButton(from: "German", to: "English") {
                            sourceLanguage = .german
                            targetLanguage = .english
                        }
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // Buttons
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.previousStep()
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                Button(action: {
                    viewModel.selectLanguagePair(source: sourceLanguage, target: targetLanguage)
                    viewModel.nextStep()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

struct PopularPairButton: View {
    let from: String
    let to: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(from) → \(to)")
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

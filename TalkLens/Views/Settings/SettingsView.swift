//
//  SettingsView.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject var languageManager: LanguageManager

    init() {
        let languageManager = LanguageManager()
        let translationService = MockTranslationService()
        let storageService = UserDefaultsStorageService()

        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            languageManager: languageManager,
            translationService: translationService,
            storageService: storageService
        ))
    }

    var body: some View {
        NavigationView {
            List {
                // Translation Settings
                Section("Translation") {
                    HStack {
                        Text("Source Language")
                        Spacer()
                        Picker("Source", selection: Binding(
                            get: { viewModel.settings.sourceLanguage },
                            set: { viewModel.updateSourceLanguage($0) }
                        )) {
                            ForEach(languageManager.availableLanguages) { language in
                                Text(language.name).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    HStack {
                        Text("Target Language")
                        Spacer()
                        Picker("Target", selection: Binding(
                            get: { viewModel.settings.targetLanguage },
                            set: { viewModel.updateTargetLanguage($0) }
                        )) {
                            ForEach(languageManager.availableLanguages.filter { $0.code != "auto" }) { language in
                                Text(language.name).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Button(action: {
                        viewModel.swapLanguages()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                            Text("Swap Languages")
                        }
                    }
                    .disabled(viewModel.settings.sourceLanguage.code == "auto")

                    Toggle("Auto-detect Language", isOn: Binding(
                        get: { viewModel.settings.autoDetectLanguage },
                        set: { viewModel.toggleAutoDetect($0) }
                    ))
                }

                // Camera Settings
                Section("Camera") {
                    Toggle("Auto-capture", isOn: Binding(
                        get: { viewModel.settings.autoCapture },
                        set: { viewModel.updateAutoCapture($0) }
                    ))

                    Toggle("Flash Default On", isOn: Binding(
                        get: { viewModel.settings.flashDefaultOn },
                        set: { viewModel.updateFlashDefault($0) }
                    ))

                    Picker("Image Quality", selection: Binding(
                        get: { viewModel.settings.imageQuality },
                        set: { viewModel.updateImageQuality($0) }
                    )) {
                        ForEach(AppSettings.ImageQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue).tag(quality)
                        }
                    }
                }

                // Downloaded Models
                Section("Language Models") {
                    NavigationLink(destination: ModelManagementView(
                        viewModel: viewModel,
                        languageManager: languageManager
                    )) {
                        HStack {
                            Image(systemName: "arrow.down.circle")
                            Text("Manage Models")
                            Spacer()
                            Text("\(languageManager.downloadedLanguages.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // General Settings
                Section("General") {
                    Toggle("Keep Translation History", isOn: Binding(
                        get: { viewModel.settings.keepTranslationHistory },
                        set: { viewModel.updateKeepHistory($0) }
                    ))

                    Toggle("Keep Original Images", isOn: Binding(
                        get: { viewModel.settings.keepOriginalImages },
                        set: { viewModel.updateKeepOriginalImages($0) }
                    ))

                    Button(action: {
                        viewModel.clearCache()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Cache")
                        }
                        .foregroundColor(.red)
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://talklens.app/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://talklens.app/terms")!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

struct ModelManagementView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var languageManager: LanguageManager

    var body: some View {
        List {
            ForEach(languageManager.availableLanguages.filter { $0.code != "auto" }) { language in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.name)
                            .font(.headline)
                        Text("~30-40 MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if languageManager.isModelDownloaded(for: language) {
                        Button(action: {
                            viewModel.deleteLanguageModel(language)
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    } else {
                        Button(action: {
                            Task {
                                await viewModel.downloadLanguageModel(language)
                            }
                        }) {
                            if viewModel.isDownloadingModel {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Language Models")
        .navigationBarTitleDisplayMode(.inline)
    }
}

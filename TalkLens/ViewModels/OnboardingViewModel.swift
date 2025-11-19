//
//  OnboardingViewModel.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import SwiftUI

/// ViewModel for the onboarding flow
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedSourceLanguage: Language?
    @Published var selectedTargetLanguage: Language?
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading = false
    @Published var error: AppError?
    @Published var hasCompletedOnboarding = false

    private let languageManager: LanguageManager
    private let translationService: TranslationServiceProtocol

    init(
        languageManager: LanguageManager,
        translationService: TranslationServiceProtocol = MockTranslationService()
    ) {
        self.languageManager = languageManager
        self.translationService = translationService
    }

    /// Selects a language pair
    func selectLanguagePair(source: Language, target: Language) {
        selectedSourceLanguage = source
        selectedTargetLanguage = target
        languageManager.updateSourceLanguage(source)
        languageManager.updateTargetLanguage(target)
    }

    /// Downloads required language models
    func downloadRequiredModels() async {
        guard let source = selectedSourceLanguage,
              let target = selectedTargetLanguage else {
            return
        }

        isDownloading = true
        downloadProgress = 0.0

        do {
            // Download source language model (if not auto-detect)
            if source.code != "auto" && !languageManager.isModelDownloaded(for: source) {
                try await languageManager.downloadModel(for: source)
                downloadProgress = 0.5
            }

            // Download target language model
            if !languageManager.isModelDownloaded(for: target) {
                try await languageManager.downloadModel(for: target)
                downloadProgress = 1.0
            }

            isDownloading = false

        } catch {
            self.error = .translationFailed(underlying: error)
            isDownloading = false
        }
    }

    /// Skips the model download step
    func skipDownload() {
        nextStep()
    }

    /// Marks onboarding as complete
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    /// Moves to the next step
    func nextStep() {
        if let next = currentStep.next {
            currentStep = next
        } else {
            completeOnboarding()
        }
    }

    /// Moves to the previous step
    func previousStep() {
        if let previous = currentStep.previous {
            currentStep = previous
        }
    }

    /// Skips the current step if allowed
    func skipCurrentStep() {
        guard currentStep.canSkip else { return }
        nextStep()
    }
}

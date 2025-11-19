//
//  OnboardingView.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init(languageManager: LanguageManager) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(languageManager: languageManager))
    }

    var body: some View {
        ZStack {
            switch viewModel.currentStep {
            case .welcome:
                WelcomeScreen(viewModel: viewModel)
            case .languageSelection:
                LanguageSelectionScreen(viewModel: viewModel, languageManager: languageManager)
            case .modelDownload:
                ModelDownloadScreen(viewModel: viewModel)
            case .tutorial:
                TutorialCarousel(viewModel: viewModel)
            case .permissions:
                PermissionsScreen(viewModel: viewModel)
            case .complete:
                EmptyView()
                    .onAppear {
                        hasCompletedOnboarding = true
                    }
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
    }
}

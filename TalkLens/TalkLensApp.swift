//
//  TalkLensApp.swift
//  TalkLens
//
//  Created by Arun Mishra on 11/18/25.
//

import SwiftUI

@main
struct TalkLensApp: App {
    @StateObject private var languageManager = LanguageManager(translationService: MLKitTranslationService())
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                RootTabView()
                    .environmentObject(languageManager)
            } else {
                OnboardingView(languageManager: languageManager)
                    .environmentObject(languageManager)
            }
        }
    }
}

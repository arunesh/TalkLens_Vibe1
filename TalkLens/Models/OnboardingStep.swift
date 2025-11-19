//
//  OnboardingStep.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation

/// Represents the steps in the onboarding flow
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case languageSelection = 1
    case modelDownload = 2
    case tutorial = 3
    case permissions = 4
    case complete = 5

    var title: String {
        switch self {
        case .welcome:
            return "Welcome to TalkLens"
        case .languageSelection:
            return "Choose Your Languages"
        case .modelDownload:
            return "Download Language Models"
        case .tutorial:
            return "How It Works"
        case .permissions:
            return "Required Permissions"
        case .complete:
            return "You're All Set!"
        }
    }

    var canSkip: Bool {
        switch self {
        case .modelDownload, .tutorial:
            return true
        default:
            return false
        }
    }

    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var previous: OnboardingStep? {
        guard rawValue > 0 else { return nil }
        return OnboardingStep(rawValue: rawValue - 1)
    }
}

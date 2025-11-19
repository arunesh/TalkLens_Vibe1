//
//  WelcomeScreen.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct WelcomeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App Icon/Logo
            Image(systemName: "text.viewfinder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)

            // App Name
            Text("TalkLens")
                .font(.system(size: 48, weight: .bold))

            // Tagline
            Text("Translate Documents On-Device")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Features List
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "camera", title: "Scan Documents", description: "Capture multiple pages with ease")
                FeatureRow(icon: "text.magnifyingglass", title: "Extract Text", description: "Powerful OCR technology")
                FeatureRow(icon: "globe", title: "Translate", description: "Support for 50+ languages")
                FeatureRow(icon: "lock.shield", title: "Private", description: "All processing on-device")
            }
            .padding(.horizontal, 40)

            Spacer()

            // Get Started Button
            Button(action: {
                viewModel.nextStep()
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

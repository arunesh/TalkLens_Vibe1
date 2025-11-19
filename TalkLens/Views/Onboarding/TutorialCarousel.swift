//
//  TutorialCarousel.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct TutorialCarousel: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var currentPage = 0

    let tutorialPages = [
        TutorialPage(
            icon: "camera.viewfinder",
            title: "Scan Documents",
            description: "Point your camera at any document. The app will automatically detect edges and capture pages."
        ),
        TutorialPage(
            icon: "photo.on.rectangle",
            title: "Import from Library",
            description: "Already have images? Import them from your photo library or files for instant translation."
        ),
        TutorialPage(
            icon: "globe",
            title: "Change Languages",
            description: "Easily switch between language pairs in Settings. Models download automatically when needed."
        ),
        TutorialPage(
            icon: "checkmark.circle",
            title: "You're Ready!",
            description: "Start translating documents privately on your device. No internet required after setup."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Tutorial Pages
            TabView(selection: $currentPage) {
                ForEach(0..<tutorialPages.count, id: \.self) { index in
                    TutorialPageView(page: tutorialPages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Buttons
            HStack(spacing: 15) {
                if currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            currentPage -= 1
                        }
                    }) {
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }

                Button(action: {
                    if currentPage < tutorialPages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        viewModel.nextStep()
                    }
                }) {
                    Text(currentPage < tutorialPages.count - 1 ? "Next" : "Continue")
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

            // Skip Button
            Button(action: {
                viewModel.skipCurrentStep()
            }) {
                Text("Skip Tutorial")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
        }
    }
}

struct TutorialPage {
    let icon: String
    let title: String
    let description: String
}

struct TutorialPageView: View {
    let page: TutorialPage

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

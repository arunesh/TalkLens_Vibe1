//
//  LoadingOverlay.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct LoadingOverlay: View {
    let message: String
    var progress: Double?

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)

                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)

                if let progress = progress {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .frame(width: 200)

                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(40)
            .background(Color(.systemGray))
            .cornerRadius(20)
        }
    }
}

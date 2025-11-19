//
//  RootTabView.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        TabView {
            CameraView()
                .tabItem {
                    Label("Scan", systemImage: "camera")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "photo.on.rectangle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(languageManager)
    }
}

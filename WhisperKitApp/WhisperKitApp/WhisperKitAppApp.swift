//
//  WhisperKitAppApp.swift
//  WhisperKitApp
//
//  VoiceKitLab - Voice transcription demonstration app
//

import SwiftData
import SwiftUI

@main
struct WhisperKitAppApp: App {
    @State private var appState = AppState.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup("VoiceKitLab") {
            ContentView()
                .environment(appState)
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 500)
                #endif
        }
        .modelContainer(sharedModelContainer)
    }
}

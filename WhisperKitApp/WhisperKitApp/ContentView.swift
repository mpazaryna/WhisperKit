//
//  ContentView.swift
//  WhisperKitApp
//
//  Main navigation view for VoiceKitLab
//

import SwiftUI

struct ContentView: View {
    @State private var selectedItem: NavigationItem? = .examples
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack(alignment: .top) {
            NavigationSplitView {
                SidebarView(selection: $selectedItem)
            } detail: {
                detailView
            }

            // Non-blocking warm-up banner
            WarmupBannerView()
                .animation(.easeInOut(duration: 0.3), value: appState.isModelLoading)
                .animation(.easeInOut(duration: 0.3), value: appState.isWarmingUp)
        }
        .task {
            await appState.loadModelIfNeeded()
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedItem {
        case .examples:
            ExamplesHomeView(selection: $selectedItem)
        case .voice:
            LiveTranscriptionView()
        case .comparison:
            EngineComparisonView()
        case .settings:
            SettingsView()
        case nil:
            Text("Select an item")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState.shared)
}

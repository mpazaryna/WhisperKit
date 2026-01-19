//
//  ExamplesHomeView.swift
//  WhisperKitApp
//
//  Home view with feature cards for VoiceKitLab
//

import SwiftUI

struct ExamplesHomeView: View {
    @Binding var selection: NavigationItem?
    @Environment(AppState.self) private var appState

    private let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                modelStatusSection
                featuresGrid
            }
            .padding()
        }
        .navigationTitle("Examples")
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VoiceKitLab")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Explore voice transcription capabilities with WhisperKit and Apple Speech")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Model Status

    private var modelStatusSection: some View {
        HStack {
            if appState.isModelLoading {
                ProgressView()
                    .controlSize(.small)
            } else if appState.isModelLoaded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.yellow)
            }

            Text(appState.modelStatusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Features Grid

    private var featuresGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            FeatureCard(
                title: "Basic Transcription",
                description: "Test transcription with audio files",
                icon: "doc.text"
            ) {
                selection = .examples
            }

            FeatureCard(
                title: "Engine Comparison",
                description: "Compare WhisperKit vs Apple Speech",
                icon: "arrow.left.arrow.right"
            ) {
                selection = .comparison
            }

            FeatureCard(
                title: "Live Recording",
                description: "Real-time transcription from microphone",
                icon: "mic.fill"
            ) {
                selection = .voice
            }

            FeatureCard(
                title: "Medical Terms",
                description: "Test chiropractic vocabulary accuracy",
                icon: "stethoscope"
            ) {
                selection = .examples
            }

            FeatureCard(
                title: "Model Info",
                description: "View loaded model details",
                icon: "info.circle"
            ) {
                selection = .settings
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExamplesHomeView(selection: .constant(nil))
            .environment(AppState.shared)
    }
}

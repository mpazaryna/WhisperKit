//
//  ExamplesHomeView.swift
//  WhisperKitApp
//
//  Home view for VoiceKitLab
//

import SwiftUI

struct ExamplesHomeView: View {
    @Binding var selection: NavigationItem?
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                modelStatusSection
                aboutSection
                architectureSection
                gettingStartedSection
            }
            .padding()
        }
        .navigationTitle("Home")
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VoiceKitLab")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("On-device voice transcription for medical documentation")
                .font(.title3)
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

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("About", systemImage: "info.circle")
                .font(.headline)

            Text("""
            VoiceKitLab is a demonstration app for exploring on-device voice-to-text transcription, \
            specifically designed for medical and chiropractic documentation workflows. The goal is \
            to provide 100% on-device speech recognition for SOAP note generation without requiring \
            third-party subscriptions or sending patient data to external servers.
            """)
            .font(.body)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Architecture Section

    private var architectureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Architecture", systemImage: "square.stack.3d.up")
                .font(.headline)

            Text("""
            This app uses VoiceKit, a facade layer that provides a unified API for multiple \
            transcription providers. Rather than coupling directly to WhisperKit or Apple Speech, \
            VoiceKit abstracts the underlying implementation, allowing us to:
            """)
            .font(.body)
            .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Swap transcription engines without changing app code")
                bulletPoint("Compare accuracy between WhisperKit and Apple Speech")
                bulletPoint("Add new providers (like faster-whisper) in the future")
                bulletPoint("Maintain consistent error handling across providers")
            }
            .padding(.leading, 8)

            Text("""
            WhisperKit, developed by Argmax, runs OpenAI's Whisper model entirely on-device using \
            Apple's CoreML and Metal frameworks. The base-en model (~140MB) provides a good balance \
            of accuracy and performance for medical terminology.
            """)
            .font(.body)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Getting Started Section

    private var gettingStartedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Getting Started", systemImage: "arrow.right.circle")
                .font(.headline)

            Text("""
            Use the sidebar to navigate between features:
            """)
            .font(.body)
            .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Voice — Record and transcribe using WhisperKit")
                bulletPoint("Comparison — Compare WhisperKit vs Apple Speech side-by-side")
                bulletPoint("Settings — View model information and links")
            }
            .padding(.leading, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helper

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.blue)
            Text(text)
                .foregroundStyle(.secondary)
        }
        .font(.body)
    }
}

#Preview {
    NavigationStack {
        ExamplesHomeView(selection: .constant(nil))
            .environment(AppState.shared)
    }
}

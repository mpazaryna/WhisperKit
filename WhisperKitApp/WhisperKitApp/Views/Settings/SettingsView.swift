//
//  SettingsView.swift
//  WhisperKitApp
//
//  Settings and model information view
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                modelSection
                aboutSection
            }
            .padding()
        }
        .navigationTitle("Settings")
    }

    // MARK: - Model Section

    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Model")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                statusRow(
                    title: "Status",
                    value: appState.modelStatusText,
                    icon: appState.isReady ? "checkmark.circle.fill" : (appState.isModelLoading || appState.isWarmingUp ? "arrow.circlepath" : "circle"),
                    iconColor: appState.isReady ? .green : (appState.isModelLoading || appState.isWarmingUp ? .orange : .secondary)
                )

                Divider()

                statusRow(
                    title: "Model",
                    value: "base-en",
                    icon: "cpu",
                    iconColor: .blue
                )

                Divider()

                statusRow(
                    title: "Size",
                    value: "~140 MB",
                    icon: "doc.zipper",
                    iconColor: .orange
                )

                Divider()

                statusRow(
                    title: "Processing",
                    value: "On-Device",
                    icon: "iphone",
                    iconColor: .purple
                )
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if !appState.isReady && !appState.isModelLoading && !appState.isWarmingUp {
                Button {
                    Task { await appState.loadModelIfNeeded() }
                } label: {
                    Label("Load Model", systemImage: "arrow.down.circle")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                statusRow(
                    title: "App",
                    value: "VoiceKitLab",
                    icon: "app",
                    iconColor: .blue
                )

                Divider()

                statusRow(
                    title: "Version",
                    value: Bundle.main.appVersion,
                    icon: "number",
                    iconColor: .gray
                )

                Divider()

                statusRow(
                    title: "Engine",
                    value: "WhisperKit",
                    icon: "waveform",
                    iconColor: .green
                )

            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // VoiceKit section
            VStack(alignment: .leading, spacing: 12) {
                Text("VoiceKit acts as a facade layer, providing a unified API for multiple transcription providers including WhisperKit and Apple Speech.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                Link(destination: URL(string: "https://github.com/mpazaryna/VoiceKit")!) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundStyle(.blue)
                        Text("VoiceKit on GitHub")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                Link(destination: URL(string: "https://github.com/argmaxinc/WhisperKit")!) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundStyle(.blue)
                        Text("WhisperKit on GitHub")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Helper Views

    private func statusRow(title: String, value: String, icon: String, iconColor: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppState.shared)
    }
}

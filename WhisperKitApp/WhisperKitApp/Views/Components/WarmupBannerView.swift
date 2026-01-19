//
//  WarmupBannerView.swift
//  WhisperKitApp
//
//  Non-blocking warm-up status banner with liquid glass styling
//

import SwiftUI

struct WarmupBannerView: View {
    @Environment(AppState.self) private var appState
    @State private var isVisible = false

    var body: some View {
        if shouldShowBanner {
            banner
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = true
                    }
                }
        }
    }

    private var shouldShowBanner: Bool {
        appState.isModelLoading || appState.isWarmingUp
    }

    private var banner: some View {
        HStack(spacing: 12) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.2))
                    .frame(width: 36, height: 36)

                if appState.isWarmingUp {
                    Image(systemName: "waveform")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.blue)
                        .symbolEffect(.variableColor.iterative.reversing)
                } else {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            // Status text
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(statusSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Phase indicator
            phaseIndicator
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var statusTitle: String {
        if appState.isModelLoading {
            return "Loading Voice Model"
        } else if appState.isWarmingUp {
            return "Warming Up"
        }
        return "Preparing..."
    }

    private var statusSubtitle: String {
        if appState.isModelLoading {
            return "Preparing WhisperKit model..."
        } else if appState.isWarmingUp {
            return "Optimizing for your device (one-time)"
        }
        return "Please wait..."
    }

    private var phaseIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(appState.isModelLoading || appState.isModelLoaded ? .blue : .gray.opacity(0.3))
                .frame(width: 6, height: 6)
            Circle()
                .fill(appState.isWarmingUp || appState.isReady ? .blue : .gray.opacity(0.3))
                .frame(width: 6, height: 6)
        }
    }
}

// MARK: - Wrapper for easy integration

struct WarmupBannerOverlay<Content: View>: View {
    @Environment(AppState.self) private var appState
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            content

            WarmupBannerView()
                .animation(.easeInOut(duration: 0.3), value: appState.isModelLoading)
                .animation(.easeInOut(duration: 0.3), value: appState.isWarmingUp)
        }
    }
}

#Preview("Loading") {
    WarmupBannerView()
        .environment(AppState.shared)
        .padding(.top, 50)
}

#Preview("In App") {
    NavigationStack {
        WarmupBannerOverlay {
            List {
                Section("Today's Schedule") {
                    Text("9:00 AM - John Smith")
                    Text("10:30 AM - Jane Doe")
                    Text("2:00 PM - Bob Wilson")
                }
                Section("Recent Patients") {
                    Text("Patient Record 1")
                    Text("Patient Record 2")
                }
            }
            .navigationTitle("Dashboard")
        }
    }
    .environment(AppState.shared)
}

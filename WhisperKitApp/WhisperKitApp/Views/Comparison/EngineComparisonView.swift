//
//  EngineComparisonView.swift
//  WhisperKitApp
//
//  Compare WhisperKit vs Apple Speech transcription
//

import Speech
import SwiftUI
import VoiceKit

struct EngineComparisonView: View {
    @Environment(AppState.self) private var appState

    @State private var isTranscribing = false
    @State private var whisperResult = ""
    @State private var appleResult = ""
    @State private var errorMessage = ""

    // Timer state
    @State private var transcriptionStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var finalTranscriptionTime: TimeInterval?
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            recordingSection
            resultsSection
            Spacer()
        }
        .padding()
        .navigationTitle("Engine Comparison")
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Transcription Comparison")
                .font(.largeTitle)
                .fontWeight(.bold)

            modelStatus
        }
    }

    private var modelStatus: some View {
        Group {
            if appState.isModelLoading {
                HStack {
                    ProgressView()
                    Text("Loading WhisperKit model...")
                        .foregroundStyle(.secondary)
                }
            } else if appState.isModelLoaded {
                Label("Model Ready", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if let error = appState.modelError {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
    }

    // MARK: - Recording

    private var recordingSection: some View {
        VStack(spacing: 16) {
            Button {
                Task { await toggleRecording() }
            } label: {
                Label(
                    appState.recorder.isRecording ? "Stop Recording" : "Start Recording",
                    systemImage: appState.recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                )
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(appState.recorder.isRecording ? Color.red : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!appState.isModelLoaded || isTranscribing)

            if appState.recorder.isRecording {
                HStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                    Text("Recording...")
                        .foregroundStyle(.secondary)
                }
            }

            if isTranscribing {
                VStack(spacing: 8) {
                    HStack {
                        ProgressView()
                        Text("Transcribing...")
                            .foregroundStyle(.secondary)
                    }
                    Text(String(format: "%.1f seconds", elapsedTime))
                        .font(.title2.monospacedDigit())
                        .foregroundStyle(.blue)
                }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(spacing: 16) {
            if let time = finalTranscriptionTime {
                Text(String(format: "Transcribed in %.1f seconds", time))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !whisperResult.isEmpty || !appleResult.isEmpty {
                HStack(alignment: .top, spacing: 16) {
                    resultCard(
                        title: "WhisperKit",
                        icon: "waveform",
                        result: whisperResult
                    )

                    resultCard(
                        title: "Apple Speech",
                        icon: "apple.logo",
                        result: appleResult
                    )
                }
            }
        }
    }

    private func resultCard(title: String, icon: String, result: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)

            Text(result.isEmpty ? "No result" : result)
                .font(.body)
                .foregroundStyle(result.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    private func toggleRecording() async {
        if appState.recorder.isRecording {
            await stopAndTranscribe()
        } else {
            await startRecording()
        }
    }

    private func startRecording() async {
        errorMessage = ""
        whisperResult = ""
        appleResult = ""
        finalTranscriptionTime = nil

        do {
            try await appState.recorder.startRecording()
        } catch {
            errorMessage = "Recording failed: \(error.localizedDescription)"
        }
    }

    private func stopAndTranscribe() async {
        guard let audioURL = appState.recorder.stopRecording() else {
            errorMessage = "No recording available"
            return
        }

        isTranscribing = true
        startTimer()

        // Run both transcriptions in parallel
        async let whisperTask = transcribeWithWhisper(url: audioURL)
        async let appleTask = transcribeWithApple(url: audioURL)

        whisperResult = await whisperTask
        appleResult = await appleTask

        stopTimer()
        isTranscribing = false
    }

    // MARK: - Timer

    private func startTimer() {
        transcriptionStartTime = Date()
        elapsedTime = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = transcriptionStartTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil

        if let startTime = transcriptionStartTime {
            finalTranscriptionTime = Date().timeIntervalSince(startTime)
        }
        transcriptionStartTime = nil
    }

    private func transcribeWithWhisper(url: URL) async -> String {
        do {
            let result = try await appState.voiceService.transcribe(audioURL: url)
            return result.text
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }

    private func transcribeWithApple(url: URL) async -> String {
        let status = await appState.appleService.requestAuthorization()
        guard status == .authorized else {
            return "Not authorized"
        }

        do {
            return try await appState.appleService.transcribe(audioURL: url)
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        EngineComparisonView()
            .environment(AppState.shared)
    }
}

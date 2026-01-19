//
//  LiveTranscriptionView.swift
//  WhisperKitApp
//
//  Live microphone recording and transcription
//

import SwiftUI
import VoiceKit

struct LiveTranscriptionView: View {
    @Environment(AppState.self) private var appState

    @State private var isRecording = false
    @State private var isTranscribing = false
    @State private var transcriptionResult = ""
    @State private var errorMessage = ""

    // Timer state
    @State private var transcriptionStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var finalTranscriptionTime: TimeInterval?
    @State private var actualWhisperKitTime: TimeInterval?
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            recordingSection
            resultSection
            Spacer()
        }
        .padding()
        .navigationTitle("Live Recording")
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Live Transcription")
                .font(.title)
                .fontWeight(.bold)

            Text("Record audio from your microphone and transcribe it")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            modelStatus
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var modelStatus: some View {
        HStack {
            if appState.isModelLoading || appState.isWarmingUp {
                ProgressView()
                    .controlSize(.small)
            } else if appState.isReady {
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
    }

    // MARK: - Recording Section

    private var recordingSection: some View {
        VStack(spacing: 16) {
            Button {
                Task { await toggleRecording() }
            } label: {
                Label(
                    isRecording ? "Stop Recording" : "Start Recording",
                    systemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill"
                )
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isRecording ? Color.red : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!appState.isReady || isTranscribing)

            if isRecording {
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

    // MARK: - Result Section

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let wallTime = finalTranscriptionTime {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "Total time: %.2f seconds", wallTime))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let whisperTime = actualWhisperKitTime {
                        Text(String(format: "WhisperKit time: %.2f seconds", whisperTime))
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }

            if !transcriptionResult.isEmpty {
                HStack {
                    Text("Transcription")
                        .font(.headline)
                    Spacer()
                    Button {
                        copyToClipboard()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                Text(transcriptionResult)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    // MARK: - Actions

    private func toggleRecording() async {
        if isRecording {
            await stopAndTranscribe()
        } else {
            await startRecording()
        }
    }

    private func startRecording() async {
        errorMessage = ""
        transcriptionResult = ""
        finalTranscriptionTime = nil
        actualWhisperKitTime = nil

        do {
            try await appState.recorder.startRecording()
            isRecording = true
        } catch {
            errorMessage = "Recording failed: \(error.localizedDescription)"
        }
    }

    private func stopAndTranscribe() async {
        isRecording = false

        guard let audioURL = appState.recorder.stopRecording() else {
            errorMessage = "No recording available"
            return
        }

        isTranscribing = true
        startTimer()

        do {
            let result = try await appState.voiceService.transcribe(audioURL: audioURL)
            transcriptionResult = result.text
            actualWhisperKitTime = result.duration
        } catch {
            errorMessage = "Transcription failed: \(error.localizedDescription)"
        }

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

    private func copyToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(transcriptionResult, forType: .string)
        #else
        UIPasteboard.general.string = transcriptionResult
        #endif
    }
}

#Preview {
    NavigationStack {
        LiveTranscriptionView()
            .environment(AppState.shared)
    }
}

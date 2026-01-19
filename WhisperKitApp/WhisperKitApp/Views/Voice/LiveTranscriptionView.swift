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
            .disabled(!appState.isModelLoaded || isTranscribing)

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
                HStack {
                    ProgressView()
                    Text("Transcribing...")
                        .foregroundStyle(.secondary)
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
        defer { isTranscribing = false }

        do {
            let result = try await appState.voiceService.transcribe(audioURL: audioURL)
            transcriptionResult = result.text
        } catch {
            errorMessage = "Transcription failed: \(error.localizedDescription)"
        }
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

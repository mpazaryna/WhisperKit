//
//  TranscriptionComparisonView.swift
//  WhisperKitApp
//
//  Compare WhisperKit vs Apple Speech transcription
//

import Speech
import SwiftUI

struct TranscriptionComparisonView: View {

    @State private var recorder = AudioRecorderService()
    @State private var whisperService = VoiceTranscriptionService()
    @State private var appleService = AppleSpeechService()

    @State private var isLoading = false
    @State private var isModelLoaded = false
    @State private var isTranscribing = false

    @State private var whisperResult = ""
    @State private var appleResult = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            recordingSection
            resultsSection
            Spacer()
        }
        .padding()
        .task {
            await loadModel()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Transcription Comparison")
                .font(.largeTitle)
                .fontWeight(.bold)

            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading WhisperKit model...")
                        .foregroundStyle(.secondary)
                }
            } else if isModelLoaded {
                Label("Model Ready", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
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
                    recorder.isRecording ? "Stop Recording" : "Start Recording",
                    systemImage: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                )
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(recorder.isRecording ? Color.red : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isModelLoaded || isTranscribing)

            if recorder.isRecording {
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

    // MARK: - Results

    private var resultsSection: some View {
        VStack(spacing: 16) {
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

    private func loadModel() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await whisperService.loadModel()
            isModelLoaded = true
        } catch {
            errorMessage = "Failed to load model: \(error.localizedDescription)"
        }
    }

    private func toggleRecording() async {
        if recorder.isRecording {
            await stopAndTranscribe()
        } else {
            await startRecording()
        }
    }

    private func startRecording() async {
        errorMessage = ""
        whisperResult = ""
        appleResult = ""

        do {
            try await recorder.startRecording()
        } catch {
            errorMessage = "Recording failed: \(error.localizedDescription)"
        }
    }

    private func stopAndTranscribe() async {
        guard let audioURL = recorder.stopRecording() else {
            errorMessage = "No recording available"
            return
        }

        isTranscribing = true
        defer { isTranscribing = false }

        // Run both transcriptions in parallel
        async let whisperTask = transcribeWithWhisper(url: audioURL)
        async let appleTask = transcribeWithApple(url: audioURL)

        whisperResult = await whisperTask
        appleResult = await appleTask
    }

    private func transcribeWithWhisper(url: URL) async -> String {
        do {
            return try await whisperService.transcribe(audioURL: url)
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }

    private func transcribeWithApple(url: URL) async -> String {
        let status = await appleService.requestAuthorization()
        guard status == .authorized else {
            return "Not authorized"
        }

        do {
            return try await appleService.transcribe(audioURL: url)
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    TranscriptionComparisonView()
}

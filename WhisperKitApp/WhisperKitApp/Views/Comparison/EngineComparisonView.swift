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

    // Individual engine timing
    @State private var whisperTime: TimeInterval?
    @State private var appleTime: TimeInterval?

    // Audio file metrics
    @State private var audioFileSize: Int64?
    @State private var audioFilePath: String?

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
                    Text("Loading model...")
                        .foregroundStyle(.secondary)
                }
            } else if appState.isWarmingUp {
                HStack {
                    ProgressView()
                    Text("Warming up...")
                        .foregroundStyle(.secondary)
                }
            } else if appState.isReady {
                Label(appState.modelStatusText, systemImage: "checkmark.circle.fill")
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
            .disabled(!appState.isReady || isTranscribing)

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
            // Audio file info
            if let size = audioFileSize {
                HStack(spacing: 16) {
                    Label(formatFileSize(size), systemImage: "doc.fill")
                    if let path = audioFilePath {
                        Text(path)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if let time = finalTranscriptionTime {
                Text(String(format: "Total time: %.2f seconds", time))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !whisperResult.isEmpty || !appleResult.isEmpty {
                HStack(alignment: .top, spacing: 16) {
                    resultCard(
                        title: "WhisperKit",
                        icon: "waveform",
                        result: whisperResult,
                        time: whisperTime
                    )

                    resultCard(
                        title: "Apple Speech",
                        icon: "apple.logo",
                        result: appleResult,
                        time: appleTime
                    )
                }
            }
        }
    }

    private func resultCard(title: String, icon: String, result: String, time: TimeInterval?) -> some View {
        let wordCount = result.split(separator: " ").count
        let charCount = result.count
        let wordsPerSecond = time.map { wordCount > 0 && $0 > 0 ? Double(wordCount) / $0 : 0 }

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                Spacer()
                if let time {
                    Text(String(format: "%.2fs", time))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(time > 10 ? .red : (time > 5 ? .orange : .green))
                }
            }

            // Metrics row
            if !result.isEmpty && !result.starts(with: "Error") && !result.starts(with: "Not authorized") {
                HStack(spacing: 12) {
                    metricBadge(value: "\(wordCount)", label: "words")
                    metricBadge(value: "\(charCount)", label: "chars")
                    if let wps = wordsPerSecond, wps > 0 {
                        metricBadge(value: String(format: "%.1f", wps), label: "w/s")
                    }
                }
                .font(.caption2)
            }

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

    private func metricBadge(value: String, label: String) -> some View {
        HStack(spacing: 2) {
            Text(value)
                .fontWeight(.semibold)
            Text(label)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.blue.opacity(0.1))
        .clipShape(Capsule())
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let kb = Double(bytes) / 1024
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        } else {
            return String(format: "%.1f MB", kb / 1024)
        }
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
        whisperTime = nil
        appleTime = nil
        audioFileSize = nil
        audioFilePath = nil

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

        // Capture audio file info
        if let attrs = try? FileManager.default.attributesOfItem(atPath: audioURL.path),
           let size = attrs[.size] as? Int64 {
            audioFileSize = size
        }
        audioFilePath = audioURL.lastPathComponent

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
            await MainActor.run {
                whisperTime = result.duration
            }
            return result.text
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }

    private func transcribeWithApple(url: URL) async -> String {
        let start = Date()
        let status = await appState.appleService.requestAuthorization()
        guard status == .authorized else {
            await MainActor.run {
                appleTime = Date().timeIntervalSince(start)
            }
            return "Not authorized"
        }

        do {
            let result = try await appState.appleService.transcribe(audioURL: url)
            await MainActor.run {
                appleTime = Date().timeIntervalSince(start)
            }
            return result
        } catch {
            await MainActor.run {
                appleTime = Date().timeIntervalSince(start)
            }
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

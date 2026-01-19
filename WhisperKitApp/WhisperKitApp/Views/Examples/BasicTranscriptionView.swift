//
//  BasicTranscriptionView.swift
//  WhisperKitApp
//
//  File-based transcription testing
//

import SwiftUI
import UniformTypeIdentifiers
import VoiceKit

struct BasicTranscriptionView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedFileURL: URL?
    @State private var transcriptionResult = ""
    @State private var isTranscribing = false
    @State private var showingFilePicker = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            fileSelectionSection
            transcribeButton
            resultSection
            Spacer()
        }
        .padding()
        .navigationTitle("Basic Transcription")
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.audio, .mpeg4Audio, .wav, .mp3],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("File Transcription")
                .font(.title)
                .fontWeight(.bold)

            Text("Select an audio file to transcribe using WhisperKit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - File Selection

    private var fileSelectionSection: some View {
        VStack(spacing: 12) {
            Button {
                showingFilePicker = true
            } label: {
                Label("Select Audio File", systemImage: "folder")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            if let url = selectedFileURL {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundStyle(.secondary)
                    Text(url.lastPathComponent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button {
                        selectedFileURL = nil
                        transcriptionResult = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    // MARK: - Transcribe Button

    private var transcribeButton: some View {
        Button {
            Task { await transcribe() }
        } label: {
            if isTranscribing {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("Transcribing...")
                }
            } else {
                Label("Transcribe", systemImage: "waveform")
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedFileURL == nil || isTranscribing || !appState.isModelLoaded)
    }

    // MARK: - Result Section

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            if !transcriptionResult.isEmpty {
                HStack {
                    Text("Result")
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

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                // Start accessing security-scoped resource
                if url.startAccessingSecurityScopedResource() {
                    selectedFileURL = url
                    transcriptionResult = ""
                    errorMessage = ""
                }
            }
        case .failure(let error):
            errorMessage = "File selection failed: \(error.localizedDescription)"
        }
    }

    private func transcribe() async {
        guard let url = selectedFileURL else { return }

        isTranscribing = true
        errorMessage = ""

        defer {
            isTranscribing = false
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let result = try await appState.voiceService.transcribe(audioURL: url)
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
        BasicTranscriptionView()
            .environment(AppState.shared)
    }
}

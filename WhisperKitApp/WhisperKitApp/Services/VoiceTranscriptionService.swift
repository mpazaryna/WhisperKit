//
//  VoiceTranscriptionService.swift
//  WhisperKitApp
//
//  Spike: Basic WhisperKit integration
//

import Foundation
import WhisperKit

// MARK: - Errors

enum VoiceTranscriptionError: Error, Equatable {
    case modelNotLoaded
    case transcriptionFailed(String)
}

// MARK: - VoiceTranscriptionService

/// Service for on-device voice transcription using WhisperKit.
/// Spike implementation to validate WhisperKit integration.
@MainActor
class VoiceTranscriptionService {

    // MARK: - Properties

    private var whisperKit: WhisperKit?

    /// Whether the model has been loaded and is ready for transcription.
    var isModelLoaded: Bool {
        whisperKit != nil
    }

    // MARK: - Initialization

    init() {}

    // MARK: - Model Loading

    /// Loads the WhisperKit model for transcription.
    /// Uses `openai_whisper-base.en` model (~140MB) for balance of size/accuracy.
    func loadModel() async throws {
        whisperKit = try await WhisperKit(WhisperKitConfig(model: "openai_whisper-base.en"))
    }

    // MARK: - Transcription

    /// Transcribes audio from the given URL.
    /// - Parameter audioURL: URL to the audio file (wav, mp3, m4a, flac)
    /// - Returns: Transcribed text
    func transcribe(audioURL: URL) async throws -> String {
        guard let whisperKit else {
            throw VoiceTranscriptionError.modelNotLoaded
        }

        let results = try await whisperKit.transcribe(audioPath: audioURL.path)
        let text = results.map { $0.text }.joined(separator: " ")

        guard !text.isEmpty else {
            throw VoiceTranscriptionError.transcriptionFailed("No transcription result")
        }

        return text
    }
}

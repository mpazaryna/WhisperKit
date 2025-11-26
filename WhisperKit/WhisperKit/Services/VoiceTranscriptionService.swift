//
//  VoiceTranscriptionService.swift
//  WhisperKit
//
//  Spike: Basic WhisperKit integration
//

import Foundation
import WhisperKit

// MARK: - Errors

enum VoiceTranscriptionError: Error {
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
    /// Uses `base-en` model as recommended for medical terminology balance.
    func loadModel() async throws {
        // TODO: Implement model loading
        // whisperKit = try await WhisperKit(WhisperKitConfig(model: "base-en"))
    }

    // MARK: - Transcription

    /// Transcribes audio from the given URL.
    /// - Parameter audioURL: URL to the audio file (wav, mp3, m4a, flac)
    /// - Returns: Transcribed text
    func transcribe(audioURL: URL) async throws -> String {
        guard isModelLoaded else {
            throw VoiceTranscriptionError.modelNotLoaded
        }

        // TODO: Implement transcription
        // let result = try await whisperKit?.transcribe(audioPath: audioURL.path)
        // return result?.text ?? ""

        return ""
    }
}

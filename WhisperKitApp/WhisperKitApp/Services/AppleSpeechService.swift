//
//  AppleSpeechService.swift
//  WhisperKitApp
//
//  Spike: Apple Speech Recognition for comparison
//

import Foundation
import Speech

// MARK: - AppleSpeechService

/// Service for on-device speech recognition using Apple's Speech framework.
/// Used for comparison against WhisperKit accuracy.
class AppleSpeechService {

    // MARK: - Properties

    private let speechRecognizer: SFSpeechRecognizer?

    var isAvailable: Bool {
        speechRecognizer?.isAvailable ?? false
    }

    // MARK: - Initialization

    init(locale: Locale = Locale(identifier: "en-US")) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    // MARK: - Authorization

    func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    // MARK: - Transcription

    /// Transcribes audio from the given URL using Apple Speech Recognition.
    /// - Parameter audioURL: URL to the audio file
    /// - Returns: Transcribed text
    func transcribe(audioURL: URL) async throws -> String {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            throw AppleSpeechError.recognizerUnavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        request.requiresOnDeviceRecognition = true  // Force on-device for fair comparison

        return try await withCheckedThrowingContinuation { continuation in
            speechRecognizer.recognitionTask(with: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if let result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
}

// MARK: - Errors

enum AppleSpeechError: Error {
    case recognizerUnavailable
    case authorizationDenied
}

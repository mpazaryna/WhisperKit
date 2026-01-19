//
//  AppState.swift
//  WhisperKitApp
//
//  Shared app state for model loading across views
//

import Foundation
import VoiceKit

@MainActor
@Observable
class AppState {

    // MARK: - Shared Instance

    static let shared = AppState()

    // MARK: - State

    var isModelLoaded = false
    var isModelLoading = false
    var modelError: String?

    // MARK: - Services

    let voiceService = VoiceTranscriptionService()
    let appleService = AppleSpeechService()
    let recorder = AudioRecorderService()

    // MARK: - Model Loading

    func loadModelIfNeeded() async {
        guard !isModelLoaded && !isModelLoading else { return }

        isModelLoading = true
        modelError = nil

        do {
            try await voiceService.loadModel()
            isModelLoaded = true
        } catch {
            modelError = "Failed to load model: \(error.localizedDescription)"
        }

        isModelLoading = false
    }

    var modelStatusText: String {
        if isModelLoading {
            return "Loading model..."
        } else if isModelLoaded {
            return "Model ready"
        } else if let error = modelError {
            return error
        } else {
            return "Model not loaded"
        }
    }
}

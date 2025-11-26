//
//  VoiceTranscriptionServiceTests.swift
//  WhisperKitTests
//
//  Spike: Validate WhisperKit basic transcription
//

import Testing
@testable import WhisperKit

// MARK: - Spike Tests for VoiceTranscriptionService

struct VoiceTranscriptionServiceTests {

    // MARK: - Initialization Tests

    @Test("Service initializes without throwing")
    func serviceInitializes() async throws {
        let service = VoiceTranscriptionService()
        #expect(service != nil)
    }

    // MARK: - Model Loading Tests

    @Test("Service loads base-en model successfully")
    func loadsBaseEnModel() async throws {
        let service = VoiceTranscriptionService()
        try await service.loadModel()
        #expect(service.isModelLoaded)
    }

    @Test("Service reports model not loaded before initialization")
    func modelNotLoadedInitially() {
        let service = VoiceTranscriptionService()
        #expect(!service.isModelLoaded)
    }

    // MARK: - Transcription Tests

    @Test("Transcribes audio file and returns non-empty text")
    func transcribesAudioFile() async throws {
        let service = VoiceTranscriptionService()
        try await service.loadModel()

        // Use a test audio file - we'll need to add one to the test bundle
        let testAudioURL = try getTestAudioURL()
        let result = try await service.transcribe(audioURL: testAudioURL)

        #expect(!result.isEmpty)
    }

    @Test("Throws error when transcribing without loaded model")
    func throwsWhenModelNotLoaded() async throws {
        let service = VoiceTranscriptionService()
        // Don't load model

        let testAudioURL = try getTestAudioURL()

        await #expect(throws: VoiceTranscriptionError.modelNotLoaded) {
            _ = try await service.transcribe(audioURL: testAudioURL)
        }
    }

    // MARK: - Helpers

    private func getTestAudioURL() throws -> URL {
        // For now, we'll create a simple test - in real spike we'll use actual audio
        guard let url = Bundle(for: BundleToken.self).url(forResource: "test_audio", withExtension: "wav") else {
            throw TestError.missingTestAudio
        }
        return url
    }
}

// Helper class to get test bundle
private class BundleToken {}

enum TestError: Error {
    case missingTestAudio
}

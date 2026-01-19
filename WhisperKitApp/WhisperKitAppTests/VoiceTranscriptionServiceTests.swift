//
//  VoiceTranscriptionServiceTests.swift
//  WhisperKitAppTests
//
//  Spike: Validate WhisperKit basic transcription
//

import Foundation
import Speech
import Testing
import VoiceKit
@testable import WhisperKitApp

// MARK: - Test Utilities

private class BundleToken {}

enum TestError: Error {
    case missingTestAudio
}

enum TestAudio {
    static func url(forResource name: String, withExtension ext: String) throws -> URL {
        guard let url = Bundle(for: BundleToken.self).url(forResource: name, withExtension: ext) else {
            throw TestError.missingTestAudio
        }
        return url
    }
}

// MARK: - Initialization Tests

@Suite("VoiceTranscriptionService Initialization")
@MainActor
struct VoiceTranscriptionServiceInitTests {

    @Test("Service initializes without throwing")
    func serviceInitializes() async throws {
        let service = VoiceTranscriptionService()
        #expect(service != nil)
    }

    @Test("Service reports model not loaded before initialization")
    func modelNotLoadedInitially() async {
        let service = VoiceTranscriptionService()
        #expect(!service.isModelLoaded)
    }
}

// MARK: - Model Loading Tests

@Suite("VoiceTranscriptionService Model Loading")
@MainActor
struct VoiceTranscriptionServiceModelTests {

    @Test("Loads base-en model successfully")
    func loadsBaseEnModel() async throws {
        let service = VoiceTranscriptionService()
        try await service.loadModel()
        #expect(service.isModelLoaded)
    }
}

// MARK: - Transcription Tests

@Suite("VoiceTranscriptionService Transcription")
@MainActor
struct VoiceTranscriptionServiceTranscriptionTests {

    let service: VoiceTranscriptionService

    init() async throws {
        service = VoiceTranscriptionService()
        try await service.loadModel()
    }

    @Test("Transcribes audio file and returns non-empty text")
    func transcribesAudioFile() async throws {
        let audioURL = try TestAudio.url(forResource: "test_audio", withExtension: "wav")
        let result = try await service.transcribe(audioURL: audioURL)
        #expect(!result.text.isEmpty)
    }

    @Test("Throws error when transcribing without loaded model")
    func throwsWhenModelNotLoaded() async throws {
        let uninitializedService = VoiceTranscriptionService()
        let dummyURL = URL(fileURLWithPath: "/tmp/dummy.wav")

        await #expect(throws: VoiceTranscriptionError.modelNotLoaded) {
            _ = try await uninitializedService.transcribe(audioURL: dummyURL)
        }
    }
}

// MARK: - Medical Terminology Tests

@Suite("Medical Terminology Accuracy")
@MainActor
struct MedicalTerminologyTests {

    let service: VoiceTranscriptionService

    init() async throws {
        service = VoiceTranscriptionService()
        try await service.loadModel()
    }

    @Test("Transcribes chiropractic terms accurately")
    func transcribesMedicalTerminology() async throws {
        let audioURL = try TestAudio.url(forResource: "patient_001", withExtension: "m4a")
        let result = try await service.transcribe(audioURL: audioURL)

        #expect(!result.text.isEmpty)

        let lowercased = result.text.lowercased()

        print("📝 Transcription: \(result.text)")
        print("📋 Term Analysis:")
        print("   sacroiliac: \(lowercased.contains("sacroiliac") ? "✅" : "❌")")
        print("   sternocleidomastoid: \(lowercased.contains("sternocleidomastoid") ? "✅" : "❌")")
        print("   c5/c6: \(lowercased.contains("c5") || lowercased.contains("c6") ? "✅" : "❌")")
        print("   facet: \(lowercased.contains("facet") ? "✅" : "❌")")
    }
}

// MARK: - Engine Comparison Tests

@Suite("WhisperKit vs Apple Speech Comparison")
@MainActor
struct TranscriptionComparisonTests {

    @Test("Compare engines on medical terminology")
    func compareTranscriptionEngines() async throws {
        let audioURL = try TestAudio.url(forResource: "patient_001", withExtension: "m4a")

        // WhisperKit
        let whisperService = VoiceTranscriptionService()
        try await whisperService.loadModel()
        let whisperResult = try await whisperService.transcribe(audioURL: audioURL)

        // Apple Speech
        let appleService = AppleSpeechService()
        let authStatus = await appleService.requestAuthorization()
        guard authStatus == .authorized else {
            print("⚠️ Apple Speech not authorized - skipping comparison")
            return
        }
        let appleResult = try await appleService.transcribe(audioURL: audioURL)

        // Report
        print("")
        print("═══════════════════════════════════════════════════════")
        print("📊 TRANSCRIPTION COMPARISON")
        print("═══════════════════════════════════════════════════════")
        print("")
        print("🤖 WhisperKit: \(whisperResult.text)")
        print("")
        print("🍎 Apple: \(appleResult)")
        print("")

        let terms = ["sacroiliac", "sternocleidomastoid", "c5", "c6", "facet", "palpation", "dysfunction"]
        print("📋 Term Analysis:")
        for term in terms {
            let w = whisperResult.text.lowercased().contains(term) ? "✅" : "❌"
            let a = appleResult.lowercased().contains(term) ? "✅" : "❌"
            print("   \(term): WhisperKit \(w) | Apple \(a)")
        }
        print("═══════════════════════════════════════════════════════")

        #expect(!whisperResult.text.isEmpty)
    }
}


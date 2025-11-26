//
//  ClosedLoopTranscriptionTests.swift
//  WhisperKitAppTests
//
//  Closed-loop testing: text → audio → transcription → compare
//

import Foundation
import Testing
@testable import WhisperKitApp

// MARK: - Closed Loop Transcription Tests

@Suite("Closed Loop Transcription Tests")
@MainActor
struct ClosedLoopTranscriptionTests {

    let service: VoiceTranscriptionService

    init() async throws {
        service = VoiceTranscriptionService()
        try await service.loadModel()
    }

    // MARK: - Individual Fixture Tests

    @Test("Small basic transcript")
    func testSmallBasic() async throws {
        try await runClosedLoopTest(fixtureName: "small_basic")
    }

    @Test("Medium chiropractic transcript")
    func testMediumChiropractic() async throws {
        try await runClosedLoopTest(fixtureName: "medium_chiropractic")
    }

    @Test("Large SOAP note transcript")
    func testLargeSoapNote() async throws {
        try await runClosedLoopTest(fixtureName: "large_soap_note")
    }

    @Test("Vertebral levels transcript")
    func testVertebralLevels() async throws {
        try await runClosedLoopTest(fixtureName: "vertebral_levels")
    }

    @Test("Anatomical terms transcript")
    func testAnatomicalTerms() async throws {
        try await runClosedLoopTest(fixtureName: "anatomical_terms")
    }

    @Test("Diagnoses transcript")
    func testDiagnoses() async throws {
        try await runClosedLoopTest(fixtureName: "diagnoses")
    }

    // MARK: - Test Runner

    private func runClosedLoopTest(fixtureName: String) async throws {
        let fixture = try AudioFixtureLoader.load(named: fixtureName)

        let startTime = Date()
        let transcription = try await service.transcribe(audioURL: fixture.audioURL)
        let elapsed = Date().timeIntervalSince(startTime)

        let accuracy = fixture.calculateAccuracy(transcription: transcription)

        // Print detailed report
        print("")
        print("═══════════════════════════════════════════════════════")
        print("🔄 CLOSED LOOP TEST: \(fixture.name)")
        print("═══════════════════════════════════════════════════════")
        print("")
        print("📄 EXPECTED:")
        print(fixture.expectedTranscript.prefix(200) + (fixture.expectedTranscript.count > 200 ? "..." : ""))
        print("")
        print("📝 TRANSCRIBED:")
        print(transcription.prefix(200) + (transcription.count > 200 ? "..." : ""))
        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📊 ACCURACY:")
        print(accuracy.summary)
        print("")
        print("⏱️  Transcription time: \(String(format: "%.2f", elapsed))s")
        print("")

        if !accuracy.keyTermsFound.isEmpty {
            print("✅ Key terms found: \(accuracy.keyTermsFound.joined(separator: ", "))")
        }

        let missingKeyTerms = fixture.keyTerms.filter { !accuracy.keyTermsFound.contains($0) }
        if !missingKeyTerms.isEmpty {
            print("❌ Key terms missed: \(missingKeyTerms.joined(separator: ", "))")
        }

        print("═══════════════════════════════════════════════════════")

        // Assertions
        #expect(!transcription.isEmpty, "Transcription should not be empty")
        #expect(accuracy.wordAccuracy >= 0.5, "Word accuracy should be at least 50%")
        #expect(accuracy.keyTermAccuracy >= 0.3, "Key term accuracy should be at least 30%")
    }
}

// MARK: - All Fixtures Test

@Suite("All Fixtures Transcription Tests")
@MainActor
struct AllFixturesTranscriptionTests {

    let service: VoiceTranscriptionService

    init() async throws {
        service = VoiceTranscriptionService()
        try await service.loadModel()
    }

    @Test("Run all fixtures and generate summary report")
    func testAllFixtures() async throws {
        let fixtures = try AudioFixtureLoader.loadAll()

        var results: [(fixture: AudioFixture, transcription: String, accuracy: AccuracyResult, time: Double)] = []

        print("")
        print("╔═══════════════════════════════════════════════════════╗")
        print("║         ALL FIXTURES TRANSCRIPTION REPORT             ║")
        print("╚═══════════════════════════════════════════════════════╝")
        print("")

        for fixture in fixtures {
            let startTime = Date()
            let transcription = try await service.transcribe(audioURL: fixture.audioURL)
            let elapsed = Date().timeIntervalSince(startTime)
            let accuracy = fixture.calculateAccuracy(transcription: transcription)

            results.append((fixture, transcription, accuracy, elapsed))

            let wordPct = String(format: "%.0f%%", accuracy.wordAccuracy * 100)
            let keyPct = String(format: "%.0f%%", accuracy.keyTermAccuracy * 100)
            let timeStr = String(format: "%.1fs", elapsed)

            print("  \(fixture.name.padding(toLength: 25, withPad: " ", startingAt: 0)) | Words: \(wordPct.padding(toLength: 4, withPad: " ", startingAt: 0)) | Keys: \(keyPct.padding(toLength: 4, withPad: " ", startingAt: 0)) | Time: \(timeStr)")
        }

        // Summary statistics
        let avgWordAccuracy = results.map { $0.accuracy.wordAccuracy }.reduce(0, +) / Double(results.count)
        let avgKeyAccuracy = results.map { $0.accuracy.keyTermAccuracy }.reduce(0, +) / Double(results.count)
        let totalTime = results.map { $0.time }.reduce(0, +)

        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📊 SUMMARY")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("  Total fixtures:      \(results.count)")
        print("  Avg word accuracy:   \(String(format: "%.1f%%", avgWordAccuracy * 100))")
        print("  Avg key term accuracy: \(String(format: "%.1f%%", avgKeyAccuracy * 100))")
        print("  Total time:          \(String(format: "%.1fs", totalTime))")
        print("╚═══════════════════════════════════════════════════════╝")

        #expect(avgWordAccuracy >= 0.5, "Average word accuracy should be at least 50%")
    }
}

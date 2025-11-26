//
//  AudioFixtures.swift
//  WhisperKitAppTests
//
//  Fixture-based audio testing infrastructure
//

import Foundation

// MARK: - Audio Fixture

struct AudioFixture: Identifiable {
    let id: String
    let name: String
    let category: Category
    let expectedTranscript: String
    let audioURL: URL
    let keyTerms: [String]

    enum Category: String, CaseIterable {
        case small
        case medium
        case large
        case anatomical
        case vertebral
        case diagnoses
    }

    /// Calculates word-level accuracy between transcription and expected
    func calculateAccuracy(transcription: String) -> AccuracyResult {
        let expectedWords = normalizeText(expectedTranscript).split(separator: " ").map(String.init)
        let actualWords = normalizeText(transcription).split(separator: " ").map(String.init)

        let expectedSet = Set(expectedWords)
        let actualSet = Set(actualWords)

        let matchedWords = expectedSet.intersection(actualSet)
        let missingWords = expectedSet.subtracting(actualSet)
        let extraWords = actualSet.subtracting(expectedSet)

        let keyTermsFound = keyTerms.filter { term in
            transcription.lowercased().contains(term.lowercased())
        }

        return AccuracyResult(
            wordAccuracy: Double(matchedWords.count) / Double(expectedWords.count),
            matchedWords: matchedWords.count,
            totalExpectedWords: expectedWords.count,
            missingWords: Array(missingWords),
            extraWords: Array(extraWords),
            keyTermsFound: keyTermsFound,
            keyTermsTotal: keyTerms.count
        )
    }

    private func normalizeText(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Accuracy Result

struct AccuracyResult {
    let wordAccuracy: Double
    let matchedWords: Int
    let totalExpectedWords: Int
    let missingWords: [String]
    let extraWords: [String]
    let keyTermsFound: [String]
    let keyTermsTotal: Int

    var keyTermAccuracy: Double {
        guard keyTermsTotal > 0 else { return 1.0 }
        return Double(keyTermsFound.count) / Double(keyTermsTotal)
    }

    var summary: String {
        """
        Word Accuracy: \(String(format: "%.1f%%", wordAccuracy * 100)) (\(matchedWords)/\(totalExpectedWords))
        Key Terms: \(keyTermsFound.count)/\(keyTermsTotal) (\(String(format: "%.1f%%", keyTermAccuracy * 100)))
        """
    }
}

// MARK: - Fixture Loader

enum AudioFixtureLoader {

    /// Load all fixtures from the test bundle
    static func loadAll() throws -> [AudioFixture] {
        let bundle = Bundle(for: BundleToken.self)

        // Get all txt files (transcripts) from bundle
        guard let transcriptURLs = bundle.urls(forResourcesWithExtension: "txt", subdirectory: nil),
              !transcriptURLs.isEmpty else {
            throw FixtureError.fixturesNotFound
        }

        return try transcriptURLs.compactMap { txtURL -> AudioFixture? in
            let name = txtURL.deletingPathExtension().lastPathComponent

            // Find matching audio file
            guard let audioURL = bundle.url(forResource: name, withExtension: "m4a") else {
                return nil
            }

            let transcript = try String(contentsOf: txtURL, encoding: .utf8)
            let category = categorize(name: name)
            let keyTerms = extractKeyTerms(for: category, from: transcript)

            return AudioFixture(
                id: name,
                name: name.replacingOccurrences(of: "_", with: " ").capitalized,
                category: category,
                expectedTranscript: transcript,
                audioURL: audioURL,
                keyTerms: keyTerms
            )
        }
    }

    /// Load a specific fixture by name
    static func load(named name: String) throws -> AudioFixture {
        let bundle = Bundle(for: BundleToken.self)

        guard let txtURL = bundle.url(forResource: name, withExtension: "txt") else {
            throw FixtureError.fixtureNotFound(name)
        }

        guard let audioURL = bundle.url(forResource: name, withExtension: "m4a") else {
            throw FixtureError.fixtureNotFound(name)
        }

        let transcript = try String(contentsOf: txtURL, encoding: .utf8)
        let category = categorize(name: name)
        let keyTerms = extractKeyTerms(for: category, from: transcript)

        return AudioFixture(
            id: name,
            name: name.replacingOccurrences(of: "_", with: " ").capitalized,
            category: category,
            expectedTranscript: transcript,
            audioURL: audioURL,
            keyTerms: keyTerms
        )
    }

    /// Load fixtures by category
    static func load(category: AudioFixture.Category) throws -> [AudioFixture] {
        try loadAll().filter { $0.category == category }
    }

    // MARK: - Private

    private static func categorize(name: String) -> AudioFixture.Category {
        if name.contains("small") { return .small }
        if name.contains("medium") { return .medium }
        if name.contains("large") { return .large }
        if name.contains("anatomical") { return .anatomical }
        if name.contains("vertebral") { return .vertebral }
        if name.contains("diagnos") { return .diagnoses }
        return .medium
    }

    private static func extractKeyTerms(for category: AudioFixture.Category, from transcript: String) -> [String] {
        switch category {
        case .small:
            return ["sacroiliac", "dysfunction"]
        case .medium:
            return ["sacroiliac", "sternocleidomastoid", "palpation", "c5", "c6", "facet", "cervical", "chiropractic"]
        case .large:
            return ["subjective", "objective", "assessment", "plan", "radiculopathy", "l4", "l5", "s1", "lumbar", "paraspinal", "dermatome", "mckenzie"]
        case .anatomical:
            return ["sternocleidomastoid", "trapezius", "levator", "scapulae", "rhomboids", "latissimus", "piriformis", "gluteus", "quadratus", "psoas"]
        case .vertebral:
            return ["c1", "c2", "c3", "c4", "c5", "c6", "c7", "t1", "t4", "t7", "t12", "l1", "l3", "l4", "l5", "s1", "atlas", "axis"]
        case .diagnoses:
            return ["radiculopathy", "sacroiliitis", "piriformis", "arthropathy", "herniated", "nucleus", "pulposus", "stenosis", "spondylolisthesis", "cauda", "equina", "ankylosing", "spondylitis"]
        }
    }
}

// MARK: - Errors

enum FixtureError: Error {
    case fixturesNotFound
    case fixtureNotFound(String)
}

// MARK: - Bundle Token

private class BundleToken {}

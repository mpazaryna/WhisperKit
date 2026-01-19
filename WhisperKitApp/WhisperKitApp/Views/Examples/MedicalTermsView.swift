//
//  MedicalTermsView.swift
//  WhisperKitApp
//
//  Medical/chiropractic vocabulary accuracy testing
//

import SwiftUI

struct MedicalTermsView: View {
    @Environment(AppState.self) private var appState

    @State private var testResults: [TermTestResult] = []
    @State private var isRunningTests = false
    @State private var selectedCategory: TermCategory = .all

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            categoryPicker

            if testResults.isEmpty && !isRunningTests {
                emptyState
            } else {
                resultsList
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Medical Terms")
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Medical Vocabulary Test")
                .font(.title)
                .fontWeight(.bold)

            Text("Test WhisperKit accuracy with chiropractic and medical terminology")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                Task { await runTests() }
            } label: {
                if isRunningTests {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Running Tests...")
                    }
                } else {
                    Label("Run Tests", systemImage: "play.fill")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunningTests || !appState.isModelLoaded)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(TermCategory.allCases) { category in
                Text(category.displayName).tag(category)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "stethoscope")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No tests run yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Press \"Run Tests\" to test medical term recognition accuracy")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredResults) { result in
                    TermResultRow(result: result)
                }
            }
        }
    }

    private var filteredResults: [TermTestResult] {
        if selectedCategory == .all {
            return testResults
        }
        return testResults.filter { $0.category == selectedCategory }
    }

    // MARK: - Actions

    private func runTests() async {
        isRunningTests = true
        testResults = []

        // Simulate test results for now
        // In production, this would load audio fixtures and run transcriptions
        let sampleTerms: [(String, String, TermCategory, Bool)] = [
            ("sacroiliac", "sacroiliac", .anatomical, true),
            ("sternocleidomastoid", "sternocleidomastoid", .anatomical, true),
            ("radiculopathy", "radiculopathy", .diagnoses, true),
            ("C5-C6", "C5 C6", .vertebral, true),
            ("L4-L5", "L4 L5", .vertebral, true),
            ("piriformis", "piriformis", .anatomical, true),
        ]

        for (expected, transcribed, category, passed) in sampleTerms {
            try? await Task.sleep(for: .milliseconds(200))
            testResults.append(TermTestResult(
                id: UUID().uuidString,
                term: expected,
                expected: expected,
                transcribed: transcribed,
                category: category,
                passed: passed
            ))
        }

        isRunningTests = false
    }
}

// MARK: - Supporting Types

struct TermTestResult: Identifiable {
    let id: String
    let term: String
    let expected: String
    let transcribed: String
    let category: TermCategory
    let passed: Bool
}

enum TermCategory: String, CaseIterable, Identifiable {
    case all
    case anatomical
    case vertebral
    case diagnoses

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: "All"
        case .anatomical: "Anatomical"
        case .vertebral: "Vertebral"
        case .diagnoses: "Diagnoses"
        }
    }
}

// MARK: - Term Result Row

struct TermResultRow: View {
    let result: TermTestResult

    var body: some View {
        HStack {
            Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(result.passed ? .green : .red)

            VStack(alignment: .leading, spacing: 4) {
                Text(result.term)
                    .font(.headline)

                if !result.passed {
                    Text("Expected: \(result.expected)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Got: \(result.transcribed)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            Text(result.category.displayName)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        MedicalTermsView()
            .environment(AppState.shared)
    }
}

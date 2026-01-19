//
//  AppState.swift
//  WhisperKitApp
//
//  Shared app state for model loading across views
//

import Foundation
import os.log
import VoiceKit

private let logger = Logger(subsystem: "com.voicekitlab", category: "appstate")

@MainActor
@Observable
class AppState {

    // MARK: - Shared Instance

    static let shared = AppState()

    // MARK: - State

    var isModelLoaded = false
    var isModelLoading = false
    var isWarmingUp = false
    var isReady = false
    var modelError: String?
    var modelLoadTime: TimeInterval?
    var warmupTime: TimeInterval?

    // MARK: - Services

    let voiceService = VoiceTranscriptionService()
    let appleService = AppleSpeechService()
    let recorder = AudioRecorderService()

    // MARK: - Model Loading

    func loadModelIfNeeded() async {
        guard !isModelLoaded && !isModelLoading else { return }

        isModelLoading = true
        modelError = nil

        logger.info("🔄 AppState: Starting model load...")
        print("[AppState] 🔄 Starting model load...")
        let startTime = Date()

        do {
            try await voiceService.loadModel()
            let elapsed = Date().timeIntervalSince(startTime)
            modelLoadTime = elapsed
            isModelLoaded = true
            logger.info("✅ AppState: Model loaded in \(String(format: "%.2f", elapsed))s")
            print("[AppState] ✅ Model loaded in \(String(format: "%.2f", elapsed))s")

            // Automatically start warmup after model loads
            await performWarmup()
        } catch {
            let elapsed = Date().timeIntervalSince(startTime)
            modelError = "Failed to load model: \(error.localizedDescription)"
            logger.error("❌ AppState: Model load failed after \(String(format: "%.2f", elapsed))s: \(error.localizedDescription)")
            print("[AppState] ❌ Model load failed after \(String(format: "%.2f", elapsed))s: \(error.localizedDescription)")
        }

        isModelLoading = false
    }

    // MARK: - Model Warm-up

    /// Performs a warm-up transcription to trigger CoreML compilation.
    /// This ensures the first real transcription is fast.
    private func performWarmup() async {
        guard isModelLoaded && !isWarmingUp else { return }

        isWarmingUp = true
        logger.info("🔥 AppState: Starting model warm-up...")
        print("[AppState] 🔥 Starting model warm-up (CoreML compilation)...")
        let startTime = Date()

        do {
            // Create a minimal audio file for warm-up
            let warmupURL = try createWarmupAudio()
            defer { try? FileManager.default.removeItem(at: warmupURL) }

            // Run transcription to trigger CoreML compilation
            // We don't care about the result - just triggering the compilation
            do {
                _ = try await voiceService.transcribe(audioURL: warmupURL)
            } catch {
                // Empty transcription result is expected for silence - that's OK
                // The important thing is that CoreML compilation happened
                logger.info("ℹ️ AppState: Warm-up transcription returned no text (expected for silence)")
                print("[AppState] ℹ️ Warm-up transcription empty (expected) - CoreML compilation complete")
            }

            let elapsed = Date().timeIntervalSince(startTime)
            warmupTime = elapsed
            isReady = true
            logger.info("✅ AppState: Warm-up complete in \(String(format: "%.2f", elapsed))s")
            print("[AppState] ✅ Warm-up complete in \(String(format: "%.2f", elapsed))s - ready for transcription")
        } catch {
            // Only fails if we can't create the audio file
            let elapsed = Date().timeIntervalSince(startTime)
            logger.warning("⚠️ AppState: Warm-up failed after \(String(format: "%.2f", elapsed))s: \(error.localizedDescription)")
            print("[AppState] ⚠️ Warm-up failed: \(error.localizedDescription) - first transcription may be slow")
            isReady = true // Still mark as ready, just without warm-up
        }

        isWarmingUp = false
    }

    /// Creates a minimal audio file for warm-up purposes
    private func createWarmupAudio() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("warmup.wav")

        // Create a minimal WAV file with ~0.5 seconds of near-silence
        // WAV header (44 bytes) + minimal audio data
        let sampleRate: UInt32 = 16000
        let numSamples: UInt32 = 8000 // 0.5 seconds
        let bitsPerSample: UInt16 = 16
        let numChannels: UInt16 = 1
        let dataSize = numSamples * UInt32(bitsPerSample / 8) * UInt32(numChannels)

        var header = Data()
        // RIFF header
        header.append(contentsOf: "RIFF".utf8)
        header.append(contentsOf: withUnsafeBytes(of: (36 + dataSize).littleEndian) { Array($0) })
        header.append(contentsOf: "WAVE".utf8)
        // fmt chunk
        header.append(contentsOf: "fmt ".utf8)
        header.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) }) // PCM
        header.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: sampleRate.littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: (sampleRate * UInt32(bitsPerSample / 8) * UInt32(numChannels)).littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: (numChannels * bitsPerSample / 8).littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })
        // data chunk
        header.append(contentsOf: "data".utf8)
        header.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Array($0) })

        // Add near-silence audio data (small random values to avoid "no audio" detection)
        var audioData = Data(count: Int(dataSize))
        for i in stride(from: 0, to: Int(dataSize), by: 2) {
            let sample = Int16.random(in: -100...100) // Very quiet noise
            audioData[i] = UInt8(truncatingIfNeeded: sample)
            audioData[i + 1] = UInt8(truncatingIfNeeded: sample >> 8)
        }

        header.append(audioData)
        try header.write(to: url)

        return url
    }

    var modelStatusText: String {
        if isModelLoading {
            return "Loading model..."
        } else if isWarmingUp {
            return "Warming up..."
        } else if isReady {
            let totalTime = (modelLoadTime ?? 0) + (warmupTime ?? 0)
            return String(format: "Ready (%.1fs)", totalTime)
        } else if isModelLoaded {
            if let time = modelLoadTime {
                return String(format: "Model loaded (%.1fs)", time)
            }
            return "Model loaded"
        } else if let error = modelError {
            return error
        } else {
            return "Model not loaded"
        }
    }
}

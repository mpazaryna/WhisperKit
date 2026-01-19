# VoiceKit Integration Guide

This guide documents how VoiceKit was integrated into VoiceKitLab and serves as a reference for integrating VoiceKit into other applications (e.g., the chiropractic Cairo app).

## Overview

VoiceKit provides a facade layer over WhisperKit (and optionally Apple Speech) for on-device transcription. Key benefits:
- Unified API for multiple transcription engines
- On-device processing (no cloud dependencies)
- Optimized for medical/technical terminology
- ~117 words/second after warm-up

## Prerequisites

- macOS 26.1+ / iOS 26.1+ / visionOS 26.1+
- Apple Silicon (M-series Mac or A-series iOS device)
- Xcode 26+

## Step 1: Add VoiceKit Dependency

Add VoiceKit to your project via Swift Package Manager:

```swift
// Package.swift or Xcode > File > Add Package Dependencies
dependencies: [
    .package(url: "https://github.com/mpazaryna/VoiceKit", branch: "main")
]
```

Or in Xcode: File → Add Package Dependencies → Enter the repository URL.

## Step 2: Create AppState

Create a shared state manager that handles model loading and warm-up:

```swift
// Services/AppState.swift
import Foundation
import os.log
import VoiceKit

private let logger = Logger(subsystem: "com.yourapp", category: "appstate")

@MainActor
@Observable
class AppState {

    static let shared = AppState()

    // MARK: - State

    var isModelLoaded = false
    var isModelLoading = false
    var isWarmingUp = false
    var isReady = false  // True when warm-up complete
    var modelError: String?
    var modelLoadTime: TimeInterval?
    var warmupTime: TimeInterval?

    // MARK: - Services

    let voiceService = VoiceTranscriptionService()
    let recorder = AudioRecorderService()

    // MARK: - Model Loading

    func loadModelIfNeeded() async {
        guard !isModelLoaded && !isModelLoading else { return }

        isModelLoading = true
        modelError = nil

        print("[AppState] 🔄 Starting model load...")
        let startTime = Date()

        do {
            try await voiceService.loadModel()
            let elapsed = Date().timeIntervalSince(startTime)
            modelLoadTime = elapsed
            isModelLoaded = true
            print("[AppState] ✅ Model loaded in \(String(format: "%.2f", elapsed))s")

            // Automatically start warm-up
            await performWarmup()
        } catch {
            modelError = "Failed to load model: \(error.localizedDescription)"
            print("[AppState] ❌ Model load failed: \(error.localizedDescription)")
        }

        isModelLoading = false
    }

    // MARK: - Warm-up

    private func performWarmup() async {
        guard isModelLoaded && !isWarmingUp else { return }

        isWarmingUp = true
        print("[AppState] 🔥 Starting warm-up (CoreML compilation)...")
        let startTime = Date()

        do {
            let warmupURL = try createWarmupAudio()
            defer { try? FileManager.default.removeItem(at: warmupURL) }

            // Transcription triggers CoreML compilation
            // Empty result is expected for silence
            do {
                _ = try await voiceService.transcribe(audioURL: warmupURL)
            } catch {
                print("[AppState] ℹ️ Warm-up transcription empty (expected)")
            }

            let elapsed = Date().timeIntervalSince(startTime)
            warmupTime = elapsed
            isReady = true
            print("[AppState] ✅ Warm-up complete in \(String(format: "%.2f", elapsed))s")
        } catch {
            print("[AppState] ⚠️ Warm-up failed: \(error.localizedDescription)")
            isReady = true  // Still mark ready, first transcription will be slower
        }

        isWarmingUp = false
    }

    private func createWarmupAudio() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("warmup.wav")

        // Create minimal WAV file (0.5s of near-silence)
        let sampleRate: UInt32 = 16000
        let numSamples: UInt32 = 8000
        let bitsPerSample: UInt16 = 16
        let numChannels: UInt16 = 1
        let dataSize = numSamples * UInt32(bitsPerSample / 8) * UInt32(numChannels)

        var header = Data()
        header.append(contentsOf: "RIFF".utf8)
        header.append(contentsOf: withUnsafeBytes(of: (36 + dataSize).littleEndian) { Array($0) })
        header.append(contentsOf: "WAVE".utf8)
        header.append(contentsOf: "fmt ".utf8)
        header.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: sampleRate.littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: (sampleRate * UInt32(bitsPerSample / 8) * UInt32(numChannels)).littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: (numChannels * bitsPerSample / 8).littleEndian) { Array($0) })
        header.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })
        header.append(contentsOf: "data".utf8)
        header.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Array($0) })

        var audioData = Data(count: Int(dataSize))
        for i in stride(from: 0, to: Int(dataSize), by: 2) {
            let sample = Int16.random(in: -100...100)
            audioData[i] = UInt8(truncatingIfNeeded: sample)
            audioData[i + 1] = UInt8(truncatingIfNeeded: sample >> 8)
        }

        header.append(audioData)
        try header.write(to: url)
        return url
    }

    var modelStatusText: String {
        if isModelLoading { return "Loading model..." }
        if isWarmingUp { return "Warming up..." }
        if isReady {
            let totalTime = (modelLoadTime ?? 0) + (warmupTime ?? 0)
            return String(format: "Ready (%.1fs)", totalTime)
        }
        if let error = modelError { return error }
        return "Model not loaded"
    }
}
```

## Step 3: Configure App Entry Point

Inject AppState into the environment:

```swift
// YourApp.swift
import SwiftUI

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AppState.shared)
        }
    }
}
```

## Step 4: Trigger Model Loading

Load the model when your main view appears:

```swift
// ContentView.swift
import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            // Your content here
        }
        .task {
            await appState.loadModelIfNeeded()
        }
    }
}
```

## Step 5: Create Transcription View

Build a view that records and transcribes:

```swift
// TranscriptionView.swift
import SwiftUI
import VoiceKit

struct TranscriptionView: View {
    @Environment(AppState.self) private var appState

    @State private var isRecording = false
    @State private var isTranscribing = false
    @State private var transcription = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            // Status indicator
            statusView

            // Record button
            Button {
                Task { await toggleRecording() }
            } label: {
                Label(
                    isRecording ? "Stop" : "Record",
                    systemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill"
                )
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isRecording ? Color.red : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!appState.isReady || isTranscribing)

            // Transcription result
            if !transcription.isEmpty {
                Text(transcription)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }

    private var statusView: some View {
        HStack {
            if appState.isModelLoading || appState.isWarmingUp {
                ProgressView()
                    .controlSize(.small)
            } else if appState.isReady {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            Text(appState.modelStatusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func toggleRecording() async {
        if isRecording {
            await stopAndTranscribe()
        } else {
            await startRecording()
        }
    }

    private func startRecording() async {
        errorMessage = ""
        transcription = ""

        do {
            try await appState.recorder.startRecording()
            isRecording = true
        } catch {
            errorMessage = "Recording failed: \(error.localizedDescription)"
        }
    }

    private func stopAndTranscribe() async {
        isRecording = false

        guard let audioURL = appState.recorder.stopRecording() else {
            errorMessage = "No recording available"
            return
        }

        isTranscribing = true

        do {
            let result = try await appState.voiceService.transcribe(audioURL: audioURL)
            transcription = result.text
        } catch {
            errorMessage = "Transcription failed: \(error.localizedDescription)"
        }

        isTranscribing = false
    }
}
```

## Step 6: Add Warm-up Banner (Optional but Recommended)

Create a non-blocking banner to show warm-up progress:

```swift
// WarmupBannerView.swift
import SwiftUI

struct WarmupBannerView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.isModelLoading || appState.isWarmingUp {
            HStack(spacing: 12) {
                ProgressView()

                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.isModelLoading ? "Loading Voice Model" : "Warming Up")
                        .font(.subheadline.weight(.semibold))
                    Text(appState.isModelLoading ? "Preparing WhisperKit..." : "Optimizing for your device")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding()
        }
    }
}
```

Use it in your ContentView:

```swift
var body: some View {
    ZStack(alignment: .top) {
        NavigationStack {
            // Your content
        }

        WarmupBannerView()
    }
    .task {
        await appState.loadModelIfNeeded()
    }
}
```

## Step 7: Add Required Permissions

### macOS

Add to your entitlements:
```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

### iOS

Add to Info.plist:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone for voice transcription.</string>
```

## Expected Timing

| Phase | Duration | Notes |
|-------|----------|-------|
| Model load | ~4-5s | Model files cached after first download |
| Warm-up | ~25-30s | CoreML compilation (one-time per session) |
| Transcription | ~0.75s | ~117 words/second |

## Key Points

1. **Always implement warm-up**: Without it, first transcription takes ~30 seconds
2. **Use `isReady` not `isModelLoaded`**: Ensures CoreML compilation is complete
3. **Non-blocking UX**: Users can navigate while warming up, just disable transcription features
4. **Handle empty transcription**: Warm-up with silence returns no text - this is expected

## Troubleshooting

### Model takes long to load on first launch
This is the initial download from Hugging Face (~140MB for base-en). Subsequent launches use cached model files.

### Transcription returns empty
- Check audio file format (WAV, M4A, MP3 supported)
- Ensure audio contains speech (not just silence)
- Verify model is loaded (`voiceService.isModelLoaded`)

### Button stays disabled
Check that `isReady` is true, not just `isModelLoaded`. The warm-up must complete.

## VoiceKitLab Implementation Reference

This app (VoiceKitLab) serves as the reference implementation. Key files:

| File | Purpose |
|------|---------|
| `Services/AppState.swift` | State management with warm-up |
| `Services/AudioRecorderService.swift` | Microphone recording |
| `Views/Voice/LiveTranscriptionView.swift` | Recording and transcription UI |
| `Views/Components/WarmupBannerView.swift` | Non-blocking status banner |
| `Views/Comparison/EngineComparisonView.swift` | WhisperKit vs Apple Speech comparison |

## Integration Checklist

- [ ] Add VoiceKit package dependency
- [ ] Create AppState with warm-up logic
- [ ] Inject AppState into environment
- [ ] Trigger `loadModelIfNeeded()` on app launch
- [ ] Implement transcription view with recording
- [ ] Add warm-up banner for UX
- [ ] Configure microphone permissions
- [ ] Test on device (Neural Engine required)
- [ ] Verify warm transcription time (~0.75s)

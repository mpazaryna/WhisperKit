# WhisperKitApp

On-device voice-to-text transcription for medical/chiropractic terminology using WhisperKit.

## Overview

This project validates WhisperKit as a replacement for third-party speech recognition services, enabling 100% on-device transcription for HIPAA-compliant medical applications without subscription costs.

## Key Features

- **On-Device Transcription**: No cloud dependencies, fully offline capable
- **Medical Terminology**: Optimized for chiropractic/anatomical terms
- **WhisperKit Integration**: Using `openai_whisper-base.en` model (~140MB)
- **Comparison Testing**: Side-by-side validation against Apple Speech Recognition

## Project Structure

```
WhisperKitApp/
├── WhisperKitApp/
│   ├── Services/
│   │   ├── VoiceTranscriptionService.swift   # WhisperKit wrapper
│   │   ├── AppleSpeechService.swift          # Apple Speech (comparison)
│   │   └── AudioRecorderService.swift        # Microphone recording
│   └── Views/
│       └── TranscriptionComparisonView.swift # Side-by-side UI
├── WhisperKitAppTests/
│   ├── VoiceTranscriptionServiceTests.swift  # Core tests
│   ├── ClosedLoopTranscriptionTests.swift    # Fixture-based tests
│   ├── AudioFixtures.swift                   # Test infrastructure
│   └── fixtures/
│       ├── transcripts/                      # Source text files
│       ├── audio/                            # Generated audio
│       └── generate_audio.sh                 # Audio generation script
└── docs/
    ├── spec.md                               # Original requirements
    └── spike-whisperkit-results.md           # Spike findings
```

## Requirements

- macOS 14.0+ / iOS 17.0+
- Xcode 15.0+
- WhisperKit 0.15.0

## Quick Start

1. Open `WhisperKitApp.xcodeproj` in Xcode
2. Build and run (Cmd+R)
3. Grant microphone permission when prompted
4. Tap "Start Recording" and speak
5. View side-by-side transcription results

## Test Fixtures

Generate test audio from text transcripts:

```bash
cd WhisperKitAppTests/fixtures
./generate_audio.sh
```

Add new test cases:
1. Create `fixtures/transcripts/my_test.txt`
2. Run `./generate_audio.sh`
3. Tests automatically discover new fixtures

## Accuracy Results

| Category | Key Term Accuracy | Notes |
|----------|-------------------|-------|
| Vertebral Levels (C1-S1) | 100% | Perfect recognition |
| Basic Medical Terms | 85-90% | sacroiliac, facet, lumbar |
| Complex Terms | 70-80% | sternocleidomastoid challenging |

See [spike-whisperkit-results.md](docs/spike-whisperkit-results.md) for detailed findings.

## Usage

```swift
// Initialize service
let service = VoiceTranscriptionService()
try await service.loadModel()

// Transcribe audio
let text = try await service.transcribe(audioURL: url)
```

## Permissions

Add to Info.plist:
- `Privacy - Microphone Usage Description`
- `Privacy - Speech Recognition Usage Description`

For App Sandbox, enable:
- Audio Input
- Outgoing Connections (Client)

## Documentation

- [Original Spec](docs/spec.md) - Problem statement and requirements
- [Spike Results](docs/spike-whisperkit-results.md) - Detailed validation findings

## License

MIT

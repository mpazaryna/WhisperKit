# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftUI app integrating WhisperKit for on-device voice-to-text transcription with medical terminology accuracy. Targets iOS, macOS, and visionOS. The goal is to provide 100% on-device speech recognition for chiropractic/medical SOAP note generation without requiring third-party subscriptions.

## Build Commands

```bash
# Build for macOS
xcodebuild -project WhisperKit/WhisperKit.xcodeproj -scheme WhisperKit -destination 'platform=macOS'

# Build for iOS simulator
xcodebuild -project WhisperKit/WhisperKit.xcodeproj -scheme WhisperKit -destination 'platform=iOS Simulator,name=iPhone 16'

# Run unit tests
xcodebuild test -project WhisperKit/WhisperKit.xcodeproj -scheme WhisperKit -destination 'platform=macOS'

# Run UI tests
xcodebuild test -project WhisperKit/WhisperKit.xcodeproj -scheme WhisperKitUITests -destination 'platform=macOS'
```

## Architecture

- **WhisperKit/WhisperKit/**: Main app source code
  - `WhisperKitApp.swift`: App entry point with SwiftData model container setup
  - `ContentView.swift`: Main UI using NavigationSplitView pattern
  - `Item.swift`: SwiftData model

- **WhisperKit/WhisperKitTests/**: Unit tests using Swift Testing framework (`@Test` macros)
- **WhisperKit/WhisperKitUITests/**: UI tests

## Key Technical Details

- Uses SwiftData for persistence (not Core Data)
- Swift 5.0 with strict concurrency (`SWIFT_APPROACHABLE_CONCURRENCY`, `MainActor` default isolation)
- Multi-platform: iOS 26.1+, macOS 26.1+, visionOS 26.1+
- App Sandbox enabled with hardened runtime

## Planned WhisperKit Integration

Per `docs/spec.md`, the app will integrate WhisperKit (https://github.com/argmaxinc/WhisperKit) for voice transcription:
- Recommended model: `base-en` (~140MB) for balance of size/accuracy
- Service pattern: `VoiceTranscriptionService` wrapping WhisperKit
- Model loading follows async/await patterns at app startup

# WhisperKit Documentation

## Overview

WhisperKit is an Argmax framework for deploying speech-to-text systems on Apple Silicon devices. It enables "on-device speech recognition" with features like real-time streaming and voice activity detection.

## Installation Methods

### Swift Package Manager (SPM)

Add via Xcode's package dependencies or include in Package.swift:

```swift
.package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.9.0")
```

### Homebrew

```bash
brew install whisperkit-cli
```

### Requirements

- macOS 14.0+
- Xcode 15.0+

## Core Features

- Real-time streaming transcription
- Word-level timestamps
- Voice activity detection
- Multiple model support (tiny through large-v3)
- Translation capabilities
- Language auto-detection

## Quick Start Example

Initialize and transcribe audio:

```swift
import WhisperKit

Task {
    let pipe = try? await WhisperKit()
    let transcription = try? await pipe!.transcribe(
        audioPath: "path/to/audio.wav"
    )?.text
}
```

## Model Selection

Supports dynamic model loading with glob pattern matching:

```swift
let config = WhisperKitConfig(model: "large-v3")
let pipe = try? await WhisperKit(config)
```

Available models are hosted on HuggingFace with prefix `openai_whisper-{MODEL}`.

### Available Models

Models range from tiny to large-v3, supporting various accuracy and performance tradeoffs.

## Local Server API

The framework includes an OpenAI-compatible local server.

### Endpoints

- `POST /v1/audio/transcriptions`
- `POST /v1/audio/translations`

### Key Parameters

- `file` (required): Audio file to transcribe
- `language`: Language specification
- `prompt`: Initial prompt for the model
- `temperature`: Sampling temperature
- `timestamp_granularities`: Granularity of timestamps
- `stream`: Support for streaming responses

### Launch Server

```bash
BUILD_ALL=1 swift run whisperkit-cli serve --model tiny
```

## Client Support

Pre-built client examples are available for:

- Python (OpenAI SDK)
- Swift
- curl

## API Response Formats

The server supports the following response formats:

- JSON
- verbose_json

### Limitations

- Response formats limited to JSON and verbose_json
- Model selection via server launch flag only

## Licensing

WhisperKit is released under the MIT License.

### Citation

For academic use, cite as:

> "WhisperKit by Argmax, Inc., 2024"

## Additional Resources

- Repository: https://github.com/argmaxinc/WhisperKit
- Package Index: https://swiftpackageindex.com/argmaxinc/WhisperKit
- Models: Available on HuggingFace

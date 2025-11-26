# WhisperKit README Documentation

## Overview

WhisperKit is an Argmax framework for deploying state-of-the-art speech-to-text systems on device with advanced features including real-time streaming, word timestamps, voice activity detection, and more.

## Installation

### Swift Package Manager

WhisperKit integrates into Swift projects using the Swift Package Manager.

**Prerequisites:**
- macOS 14.0 or later
- Xcode 15.0 or later

**Xcode Steps:**
1. Open your Swift project in Xcode
2. Navigate to File > Add Package Dependencies
3. Enter: `https://github.com/argmaxinc/whisperkit`
4. Choose version range and click Finish

**Package.swift Integration:**
```swift
dependencies: [
 .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.9.0"),
],

.target(
 name: "YourApp",
 dependencies: ["WhisperKit"]
),
```

**Homebrew:**
```bash
brew install whisperkit-cli
```

## Getting Started

### Quick Example

Basic transcription of local audio:
```swift
import WhisperKit

Task {
 let pipe = try? await WhisperKit()
 let transcription = try? await pipe!.transcribe(audioPath: "path/to/audio.{wav,mp3,m4a,flac}")?.text
 print(transcription)
}
```

### Model Selection

WhisperKit automatically downloads the recommended model for your device. Specify models explicitly:
```swift
let pipe = try? await WhisperKit(WhisperKitConfig(model: "large-v3"))
```

Glob pattern support:
```swift
let pipe = try? await WhisperKit(WhisperKitConfig(model: "distil*large-v3"))
```

Available models are in the [HuggingFace repository](https://huggingface.co/argmaxinc/whisperkit-coreml).

### Generating Models

Using custom fine-tuned models from the `whisperkittools` repository:
```swift
let config = WhisperKitConfig(model: "large-v3", modelRepo: "username/your-model-repo")
let pipe = try? await WhisperKit(config)
```

### Swift CLI

**Setup:**
```bash
git clone https://github.com/argmaxinc/whisperkit.git
cd whisperkit
make setup
make download-model MODEL=large-v3
```

**Transcription:**
```bash
swift run whisperkit-cli transcribe --model-path "Models/whisperkit-coreml/openai_whisper-large-v3" --audio-path "path/to/audio.{wav,mp3,m4a,flac}"
```

**Streaming from microphone:**
```bash
swift run whisperkit-cli transcribe --model-path "Models/whisperkit-coreml/openai_whisper-large-v3" --stream
```

## WhisperKit Local Server

The local server implements the OpenAI Audio API, enabling existing OpenAI SDK clients to be used with WhisperKit. It supports transcription and translation with output streaming capabilities.

### Building the Server

```bash
make build-local-server
# Or manually
BUILD_ALL=1 swift build --product whisperkit-cli
```

### Starting the Server

```bash
# Default settings
BUILD_ALL=1 swift run whisperkit-cli serve

# Custom host and port
BUILD_ALL=1 swift run whisperkit-cli serve --host 0.0.0.0 --port 8080

# With specific model and verbose logging
BUILD_ALL=1 swift run whisperkit-cli serve --model tiny --verbose

# View all parameters
BUILD_ALL=1 swift run whisperkit-cli serve --help
```

### API Endpoints

- **POST** `/v1/audio/transcriptions` - Transcribe audio to text
- **POST** `/v1/audio/translations` - Translate audio to English

### Supported Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `file` | Audio file (wav, mp3, m4a, flac) | Required |
| `model` | Model identifier | Server default |
| `language` | Source language code | Auto-detect |
| `prompt` | Text to guide transcription | None |
| `response_format` | Output format (json, verbose_json) | verbose_json |
| `temperature` | Sampling temperature (0.0-1.0) | 0.0 |
| `timestamp_granularities[]` | Timing detail (word, segment) | segment |
| `stream` | Enable streaming | false |

### Client Examples

**Python (OpenAI SDK):**
```python
from openai import OpenAI
client = OpenAI(base_url="http://localhost:50060/v1")
result = client.audio.transcriptions.create(
 file=open("audio.wav", "rb"),
 model="tiny"
)
print(result.text)
```

**Swift CLI Client:**
```bash
cd Examples/ServeCLIClient/Swift
swift run whisperkit-client transcribe audio.wav --language en
```

**Shell/Curl:**
```bash
cd Examples/ServeCLIClient/Curl
chmod +x *.sh
./transcribe.sh audio.wav --language en
```

### API Limitations

- **Response formats:** Only JSON and verbose_json (no plain text, SRT, VTT)
- **Model selection:** Client launches server with desired model via `--model` flag

### Fully Supported Features

- Logprobs parameter for token-level probabilities
- Server-Sent Events (SSE) for real-time transcription
- Word and segment-level timestamp granularities
- Automatic language detection
- Temperature control for transcription randomness
- Prompt text guidance

## Contributing & Roadmap

Contributions are welcome. Search the codebase for "TODO" comments indicating features yet to be built. See the [contribution guidelines](CONTRIBUTING.md) for submission standards and the public roadmap.

## License

WhisperKit is released under the MIT License. See [LICENSE](LICENSE) for details.

## Citation

If using WhisperKit academically, cite as:
```bibtex
@misc{whisperkit-argmax,
 title = {WhisperKit},
 author = {Argmax, Inc.},
 year = {2024},
 URL = {https://github.com/argmaxinc/WhisperKit}
}
```

For inquiries: info@argmaxinc.com

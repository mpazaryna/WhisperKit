## Problem Statement

**TestFlight Blocker**: Cannot ask TestFlight users to pay for both PAB subscription AND third-party Wispr subscription for voice-to-text.

### Current State
- Using third-party Wispr tool for voice-to-text during SOAP note generation
- Works well: 100% accuracy on chiropractic/anatomical terminology
- **Blocker**: Requires separate user subscription for TestFlight testers

### Why Built-in macOS Dictation Doesn't Work
Tested Apple's native dictation - failed on medical terminology:
- "sacroiliac" → mangled
- "sternocleidomastoid" → gibberish  
- "C5-C6 facet" → "see five see six facet"

Whisper models are trained on medical terminology and achieve 100% accuracy on clinical terms.

---

## Proposed Solution: WhisperKit Integration

### What is WhisperKit?

**WhisperKit** by Argmax is a production-ready, native Swift framework for on-device Whisper transcription on Apple Silicon.

**Key Features:**
- ✅ **Production-Proven**: Powers ModMed Scribe (medical EMR) at AAD2025
- ✅ **Medical-Tuned Models**: Validated for clinical terminology accuracy
- ✅ **On-Device**: 100% privacy, no cloud dependencies
- ✅ **Native Swift**: Clean integration with SwiftUI
- ✅ **Real-Time Streaming**: Record during patient sessions
- ✅ **MIT Licensed**: Free, no subscription costs
- ✅ **Custom Vocabulary**: Runtime customization for domain terms

**Repository**: https://github.com/argmaxinc/WhisperKit  
**Version**: 0.15.0 (actively maintained)

---

## Architecture

### Integration Flow

```
Current Flow:
Manual text → Apple Intelligence → SOAP generation → MLX processors

Proposed Flow:
Audio recording → WhisperKit transcription → Apple Intelligence → SOAP → MLX
```

### Service Architecture

```swift
// Features/Notes/Services/VoiceTranscriptionService.swift
import WhisperKit

class VoiceTranscriptionService {
    private var whisperKit: WhisperKit?
    
    func initialize() async throws {
        whisperKit = try await WhisperKit(model: "base-en")
    }
    
    func transcribe(audioPath: String) async throws -> String {
        let result = try await whisperKit?.transcribe(audioPath: audioPath)
        return result?.text ?? ""
    }
}
```

### Model Selection

| Model | Size | Use Case | Recommendation |
|-------|------|----------|----------------|
| `tiny-en` | ~40MB | Fast, low accuracy | ❌ Too inaccurate for medical |
| `base-en` | ~140MB | Good balance | ✅ **Start here** |
| `small-en` | ~460MB | Better accuracy | ✅ **If base-en insufficient** |
| `medium-en` | ~1.5GB | High accuracy | ⚠️ Probably overkill |
| `large-v3` | ~3GB | Best accuracy | ❌ Too large for mobile |

**Recommendation**: Start with `base-en` (140MB), validate accuracy, upgrade to `small-en` if needed.

---

## Implementation Plan

### Phase 1: Basic Integration (Day 1)

**Tasks:**
1. Add WhisperKit via Swift Package Manager
2. Create `VoiceTranscriptionService.swift`
3. Add model preloading to `MLXPreloader.swift`
4. Basic UI: record button in SOAP generation view
5. Wire transcription → text field population

**Deliverable**: Can record audio, transcribe, populate SOAP input field

### Phase 2: UX Polish (Day 2)

**Tasks:**
1. Audio waveform visualization during recording
2. Loading states and progress indicators
3. Error handling (permissions, model download failures)
4. Stop/cancel/retry controls
5. Test with real patient note scenarios

**Deliverable**: Production-ready UX for TestFlight

### Phase 3: Post-TestFlight Enhancements (Future)

Based on user feedback:
- Custom vocabulary for chiropractic terms
- Real-time streaming transcription (live display)
- Medical-tuned model evaluation (WhisperKit Pro)
- Word-level timestamps for note editing
- Language detection and multi-language support

---

## Technical Details

### Swift Package Manager Integration

```swift
dependencies: [
    .package(url: "https://github.com/argmaxinc/WhisperKit", from: "0.15.0")
]
```

### Model Loading Strategy

Follow existing MLX preloading pattern:
- Load model at app startup (alongside ICD-10, CPT, Vertebral Level models)
- Display in `StartupView.swift` branded splash screen
- Cache model files locally (downloaded on first use)

**Expected Preload Time**: ~500ms for `base-en` model (vs ~34ms for current MLX models)

### Custom Vocabulary for Chiropractic Terms

```swift
let chiropracticTerms = [
    "sacroiliac", "sternocleidomastoid", "facet",
    "subluxation", "vertebrae", "C1", "C2", "C3", "C4", "C5", "C6", "C7",
    "thoracic", "lumbar", "cervical", "atlas", "axis",
    "manipulation", "adjustment", "palpation", "ROM",
    "flexion", "extension", "rotation", "lateral flexion"
]

whisperKit.setCustomVocabulary(chiropracticTerms)
```

**Note**: Custom Vocabulary is a WhisperKit Pro feature - may require upgrade from free version.

---

## Privacy & Security

**Benefits:**
- ✅ **100% On-Device**: No audio leaves the device
- ✅ **No Cloud Dependencies**: Works offline
- ✅ **No Third-Party Services**: No subscription, no data sharing
- ✅ **HIPAA Compliant**: Local processing only

**Permissions Required:**
- Microphone access (standard iOS/macOS permission)

---

## Success Criteria

**Must Have (TestFlight):**
- ✅ Record audio in SOAP generation view
- ✅ Transcribe with medical terminology accuracy (>95% on test cases)
- ✅ No user subscription required
- ✅ Works offline

**Nice to Have (Post-TestFlight):**
- Real-time streaming transcription
- Custom vocabulary for chiropractic terms
- Multi-language support
- Word-level timestamps

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Model download fails | High | Bundle smallest model (base-en) in app, download larger as fallback |
| Accuracy insufficient | High | Start with base-en, upgrade to small-en, validate against Wispr |
| Performance issues | Medium | Async/await, background processing, loading indicators |
| Microphone permission denied | Medium | Clear permission prompts, fallback to text input |
| Model size bloats app | Low | base-en is only 140MB, acceptable for medical app |

---

## References

- **WhisperKit GitHub**: https://github.com/argmaxinc/WhisperKit
- **ModMed Scribe Case Study**: https://www.argmaxinc.com/blog/modmed-scribe
- **WhisperKit Documentation**: https://swiftpackageindex.com/argmaxinc/WhisperKit/main/documentation/whisperkit

---

## Priority & Effort

**Status**: Proposed  
**Priority**: High (TestFlight Blocker)  
**Estimated Effort**: 1-2 days  
**Dependencies**: None

---

**Conclusion**: WhisperKit provides a production-ready, native solution that solves the TestFlight blocker without requiring weeks of custom development. The ModMed partnership validates medical terminology accuracy, and the 1-2 day implementation timeline makes this feasible for immediate work.
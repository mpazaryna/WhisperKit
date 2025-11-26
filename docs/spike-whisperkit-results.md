# Spike: WhisperKit Integration

**Date:** 2025-11-26
**Status:** Complete - Success
**Time Spent:** ~4 hours

---

## Objective

Validate WhisperKit as a replacement for third-party Wispr subscription for on-device voice-to-text transcription with medical terminology accuracy.

---

## Success Criteria Checklist

- [x] WhisperKit SPM dependency resolves and builds
- [x] Model downloads/loads successfully (~10s load time)
- [x] Can transcribe audio files (wav, m4a)
- [x] Tests pass with real data
- [x] Medical terminology accuracy validated
- [x] Comparison with Apple Speech completed
- [x] Pattern documented for Phase 1 implementation

---

## Technical Findings

### Setup & Integration

| Aspect | Finding |
|--------|---------|
| SPM Package | `https://github.com/argmaxinc/WhisperKit` v0.15.0 |
| Model Used | `openai_whisper-base.en` (~140MB) |
| Model Load Time | ~10 seconds (cached) |
| Transcription Speed | 1-2 seconds for short clips |
| Platforms Tested | macOS 14+ |

### API Pattern

```swift
// Initialize
let whisperKit = try await WhisperKit(WhisperKitConfig(model: "openai_whisper-base.en"))

// Transcribe
let results = try await whisperKit.transcribe(audioPath: url.path)
let text = results.map { $0.text }.joined(separator: " ")
```

### Model Options

| Model | Size | Recommendation |
|-------|------|----------------|
| `openai_whisper-tiny.en` | ~40MB | Too inaccurate |
| `openai_whisper-base.en` | ~140MB | **Recommended - good balance** |
| `openai_whisper-small.en` | ~460MB | Try if base insufficient |
| `openai_whisper-medium.en` | ~1.5GB | Overkill for mobile |

---

## Accuracy Results

### Medical Terminology Test (Human Voice)

Audio: "The patient presents with sacroiliac joint dysfunction and sternocleidomastoid tension. Palpation reveals C5, C6, facet involvement."

| Term | WhisperKit | Apple Speech |
|------|------------|--------------|
| sacroiliac | ✅ | ✅ |
| sternocleidomastoid | ❌ (sternonucleotod mastide) | ❌ (sterno nucleotide Maytide) |
| C5 | ✅ | ✅ |
| C6 | ✅ | ✅ |
| facet | ✅ | ✅ |
| palpation | ❌ (palpatation) | ❌ (palpitation) |
| dysfunction | ✅ | ✅ |

**Score: WhisperKit 5/7 = Apple Speech 5/7**

### Closed-Loop Testing (TTS Generated Audio)

Comprehensive testing using fixture-based text-to-speech audio with accuracy validation:

| Fixture | Duration | Word Accuracy | Key Terms | Transcription Time |
|---------|----------|---------------|-----------|-------------------|
| Small Basic | ~3s | 71.4% | 2/2 (100%) | 1.16s |
| Medium Chiropractic | ~16s | 77.1% | 7/8 (87.5%) | 1.67s |
| Diagnoses | ~17s | 70.4% | 10/13 (76.9%) | 1.74s |
| Anatomical Terms | ~18s | 73.0% | 8/10 (80.0%) | 1.73s |
| **Vertebral Levels** | ~23s | **87.5%** | **18/18 (100%)** | 1.86s |
| Large SOAP Note | ~90s | 65.6% | 10/12 (83.3%) | 2.98s |

**Key Findings:**
- **Vertebral levels (C1-C7, T1-T12, L1-S1)**: 100% accuracy
- **90-second SOAP note**: No cutoff, transcribed in under 3 seconds
- **Challenging terms**: sternocleidomastoid, radiculopathy, spondylolisthesis

### Key Insight

WhisperKit matches Apple's on-device speech recognition quality while providing:
- No subscription cost
- Full offline capability
- No cloud dependencies
- HIPAA-compliant local processing

---

## Files Created

### Production Code
- `Services/VoiceTranscriptionService.swift` - WhisperKit wrapper
- `Services/AppleSpeechService.swift` - Apple Speech wrapper (for comparison)
- `Services/AudioRecorderService.swift` - Microphone recording
- `Views/TranscriptionComparisonView.swift` - Side-by-side comparison UI

### Test Code
- `VoiceTranscriptionServiceTests.swift` - Core test suites:
  - `VoiceTranscriptionServiceInitTests`
  - `VoiceTranscriptionServiceModelTests`
  - `VoiceTranscriptionServiceTranscriptionTests`
  - `MedicalTerminologyTests`
  - `TranscriptionComparisonTests`
- `ClosedLoopTranscriptionTests.swift` - Fixture-based accuracy tests
- `AudioFixtures.swift` - Fixture loader with accuracy calculation

### Test Fixtures
- `fixtures/transcripts/*.txt` - Source text for audio generation
- `fixtures/audio/*.m4a` - Generated audio files
- `fixtures/generate_audio.sh` - Script to regenerate audio from text

---

## Permissions Required

Add to Info.plist:
- `Privacy - Microphone Usage Description`
- `Privacy - Speech Recognition Usage Description`

For App Sandbox:
- Enable **Audio Input**
- Enable **Outgoing Connections (Client)**

---

## Risks Identified

| Risk | Mitigation |
|------|------------|
| Hard medical terms (sternocleidomastoid) | Users can correct; try small.en model |
| 140MB model size | Acceptable for medical app |
| 10s model load time | Load at app startup with splash screen |
| Network needed for first model download | Bundle model or download on first launch |

---

## Recommendation

**Proceed with Phase 1 implementation.**

WhisperKit is production-ready and solves the TestFlight blocker:
1. Matches Apple's accuracy on medical terms
2. No subscription required
3. Fully on-device / HIPAA compliant
4. Clean Swift API

### Next Steps (Phase 1)

1. Integrate `VoiceTranscriptionService` into PAB's SOAP note generation
2. Add model preloading to app startup
3. Build record button in SOAP input view
4. Wire transcription → text field population
5. Add loading states and error handling

---

## Appendix: Test Output

```
═══════════════════════════════════════════════════════
📊 TRANSCRIPTION COMPARISON - Medical Terminology
═══════════════════════════════════════════════════════

🤖 WhisperKit (base.en):
   The patient presents with sacroiliac joint dysfunction and
   sternonucleotod mastide tension. Palpatation reveals C5, C6,
   facet involvement.

🍎 Apple Speech (on-device):
   The patient presents with sacroiliac joint dysfunction and
   sterno nucleotide Maytide tension palpitation reveals C5 C6
   facet involvement

📋 Term Analysis:
   sacroiliac: WhisperKit ✅ | Apple ✅
   sternocleidomastoid: WhisperKit ❌ | Apple ❌
   c5: WhisperKit ✅ | Apple ✅
   c6: WhisperKit ✅ | Apple ✅
   facet: WhisperKit ✅ | Apple ✅
   palpation: WhisperKit ❌ | Apple ❌
   dysfunction: WhisperKit ✅ | Apple ✅
═══════════════════════════════════════════════════════
```

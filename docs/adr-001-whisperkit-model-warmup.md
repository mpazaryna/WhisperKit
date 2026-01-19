# ADR-001: WhisperKit Model Warm-up Strategy

**Status:** Accepted and Validated
**Date:** 2026-01-19
**Author:** Development Team

## Context

WhisperKit uses CoreML to run Whisper models on Apple's Neural Engine. On the first transcription after model loading, CoreML performs Just-In-Time (JIT) compilation to optimize the model for the specific device's Neural Engine. This compilation is a one-time cost per app session but causes significant delay on the first user-initiated transcription.

### Observed Behavior

Testing on iPad revealed:

| Run | WhisperKit Time | Notes |
|-----|-----------------|-------|
| 1st (cold) | 29.48s | Includes CoreML compilation |
| 2nd (warm) | 0.75s | Model already compiled |

The 29-second delay on first transcription is unacceptable for production use in a medical documentation context where practitioners expect responsive voice input.

### Root Cause

WhisperKit's `loadModel()` completes quickly, but the actual CoreML Neural Engine compilation is deferred until the first `transcribe()` call. This lazy compilation strategy optimizes app startup time but shifts the cost to the first user interaction.

**Validated timing breakdown (iPad testing):**

| Phase | Duration | Notes |
|-------|----------|-------|
| Model load | 4.12s | Model files cached locally |
| CoreML compilation | 29.33s | Triggered by first transcribe() |
| **Total startup** | **~34s** | Before user can transcribe |

The model files themselves are cached by WhisperKit in `~/.cache/huggingface/hub` after first download. Subsequent app launches only require the CoreML compilation phase.

## Decision

Implement an automatic model warm-up strategy that triggers CoreML compilation at app launch, before the user attempts their first transcription.

### Implementation

1. **Automatic warm-up after model load**: After `loadModel()` completes, immediately perform a warm-up transcription using a minimal synthetic audio file.

2. **Synthetic warm-up audio**: Generate a 0.5-second WAV file with near-silence (low-amplitude noise) programmatically. This avoids bundling additional assets and ensures the audio is valid enough to trigger full model compilation.

3. **Three-phase initialization**:
   - Phase 1: Model Loading ("Loading model...")
   - Phase 2: Warm-up ("Warming up...")
   - Phase 3: Ready ("Ready (X.Xs)")

4. **UI blocking**: Recording buttons remain disabled until warm-up completes, preventing users from experiencing the cold-start delay.

### Code Structure

```swift
// AppState.swift
func loadModelIfNeeded() async {
    // Phase 1: Load model
    try await voiceService.loadModel()

    // Phase 2: Automatic warm-up
    await performWarmup()
}

private func performWarmup() async {
    let warmupURL = try createWarmupAudio()  // 0.5s synthetic WAV
    do {
        _ = try await voiceService.transcribe(audioURL: warmupURL)
    } catch {
        // Empty transcription is expected for silence - CoreML compilation still happens
    }
    isReady = true  // Now safe for user interaction
}
```

### UI Implementation

A non-blocking floating banner (`WarmupBannerView`) displays during initialization:
- Uses iOS liquid glass styling (`.ultraThinMaterial`)
- Shows phase: "Loading Voice Model" → "Warming Up"
- Does not prevent user from navigating (viewing schedules, patient records, etc.)
- Auto-dismisses when warm-up completes

This approach aligns with the chiropractic application's MLX warm-up pattern where users can interact with other features while models initialize.

## Consequences

### Positive

- **Consistent user experience**: First transcription is as fast as subsequent ones (~0.75s)
- **Predictable timing**: Users see clear progress indicators during initialization
- **No bundled assets**: Warm-up audio is generated programmatically
- **Graceful degradation**: If warm-up fails, app still works (first transcription will just be slower)

### Negative

- **Longer perceived startup**: Total initialization time increases by ~29s (model load + warm-up)
- **Resource usage at launch**: Neural Engine is active during warm-up even if user doesn't immediately use transcription

### Neutral

- **One-time cost**: Warm-up only happens once per app session
- **Aligns with chiropractic app**: The main application already performs MLX model warm-up at launch, so users expect initialization time

## Alternatives Considered

### 1. Lazy compilation (status quo)
- **Rejected**: 29-second delay on first transcription is unacceptable for medical workflows

### 2. Pre-compiled models
- **Not available**: CoreML compilation is device-specific; cannot ship pre-compiled models

### 3. Background warm-up after UI appears
- **Rejected**: Risk of user attempting transcription before warm-up completes; complex state management

### 4. Bundle a real audio file for warm-up
- **Rejected**: Adds unnecessary asset; synthetic audio achieves the same CoreML compilation

## Metrics

### Validated Performance (iPad Testing)

| Metric | Before Warm-up | After Warm-up |
|--------|----------------|---------------|
| First transcription | 29.48s | 0.75s |
| App initialization | ~5s | ~34s |
| User-perceived latency | High (unexpected delay) | Low (expected during startup) |

### Detailed Timing Breakdown

```
[AppState] 🔄 Starting model load...
[AppState] ✅ Model loaded in 4.12s
[AppState] 🔥 Starting model warm-up (CoreML compilation)...
Loaded models for whisper size: base.en in 29.33s
[AppState] ℹ️ Warm-up transcription empty (expected) - CoreML compilation complete
[AppState] ✅ Warm-up complete in 29.37s - ready for transcription
```

### Transcription Performance Post-Warm-up

| Test | Words | Time | Words/Second |
|------|-------|------|--------------|
| WhisperKit (warm) | 88 | 0.75s | ~117 w/s |
| Apple Speech | 88 | 0.088s | ~1000 w/s |

Note: Apple Speech is faster but WhisperKit provides better accuracy for medical terminology.

## References

- WhisperKit documentation: https://github.com/argmaxinc/WhisperKit
- CoreML optimization: Neural Engine compilation is device-specific and cannot be cached across installs
- Related: MLX model warm-up in chiropractic application uses similar pattern

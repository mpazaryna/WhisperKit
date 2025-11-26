# ModMed Case Study

**Date:** November 12, 2025

**Type:** Customer Case Study

## Overview

ModMed, serving over 40,000 US healthcare providers, partnered with Argmax SDK to enhance its AI Scribe solution with real-time ambient listening capabilities. The integration has been running in production since March 2025 with zero downtime.

## Key Achievements

**Performance Improvements:**
- Reduced transcript finalization latency from several seconds on cloud infrastructure to under 500ms (p95) on-device
- Achieved consistent performance regardless of session duration or internet connectivity
- Enabled clinicians to review suggested visit notes immediately after patient conversations

**Technical Implementation:**
ModMed initially fine-tuned OpenAI's Whisper Large v3 using specialty-specific medical data. After deploying on-device using Argmax's WhisperKit, the company later upgraded to Nvidia's Parakeet model with Argmax's support.

## Production Excellence

The company maintains enterprise-level SLAs through Argmax's dedicated hardware lab. Notably, Argmax detected and collaborated with Apple to resolve a Neural Engine bug on iOS 26 Developer Beta before public release, preventing potential production issues.

## CEO Perspective

Daniel Cane, ModMed Co-founder, emphasized: *"Argmax has been instrumental...delivering high accuracy, performance, and battery life on mobile devices."*

---

**Related Resources:**
- Heidi Health case study (November 10, 2025)
- Custom Vocabulary feature announcement (November 19, 2025)

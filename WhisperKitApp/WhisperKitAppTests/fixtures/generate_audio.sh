#!/bin/bash
#
# Generate audio fixtures from transcript text files
# Usage: ./generate_audio.sh [voice]
#
# Available voices: say -v '?' to list all
# Recommended: Alex, Samantha, Daniel, Karen, Moira
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TRANSCRIPTS_DIR="$SCRIPT_DIR/transcripts"
AUDIO_DIR="$SCRIPT_DIR/audio"
VOICE="${1:-Alex}"

# Create audio directory
mkdir -p "$AUDIO_DIR"

echo "🎙️  Generating audio fixtures with voice: $VOICE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Generate audio for each transcript
for txt_file in "$TRANSCRIPTS_DIR"/*.txt; do
    if [ -f "$txt_file" ]; then
        filename=$(basename "$txt_file" .txt)
        audio_file="$AUDIO_DIR/${filename}.m4a"

        echo "📝 $filename.txt"

        # Read text, normalize whitespace (remove newlines), and generate audio
        text=$(cat "$txt_file" | tr '\n' ' ' | tr -s ' ')
        say -v "$VOICE" -o "$audio_file" "$text"

        # Get file info
        size=$(ls -lh "$audio_file" | awk '{print $5}')
        duration=$(afinfo "$audio_file" 2>/dev/null | grep "duration" | awk '{print $3}')

        echo "   → $filename.m4a ($size, ${duration}s)"
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Audio generation complete!"
echo ""
echo "Files generated in: $AUDIO_DIR"
ls -la "$AUDIO_DIR"

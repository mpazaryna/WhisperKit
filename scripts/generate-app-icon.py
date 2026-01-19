#!/usr/bin/env python3
"""
Generate VoiceKitLab app icon with waveform design.

Usage:
    pip install pillow
    python scripts/generate-app-icon.py

Outputs icons to WhisperKitApp/WhisperKitApp/Assets.xcassets/AppIcon.appiconset/
"""

import math
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Please install Pillow: pip install pillow")
    exit(1)


def create_app_icon(size: int) -> Image.Image:
    """Create a VoiceKitLab app icon at the specified size."""

    # Create image with transparent background
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background - dark blue gradient simulation
    # Using a deep blue/purple color scheme
    bg_color = (25, 35, 75)  # Deep navy blue

    # Draw rounded rectangle background
    corner_radius = int(size * 0.22)  # iOS-style rounded corners
    draw.rounded_rectangle(
        [(0, 0), (size - 1, size - 1)],
        radius=corner_radius,
        fill=bg_color
    )

    # Add subtle gradient overlay (lighter at top)
    for y in range(size):
        alpha = int(30 * (1 - y / size))  # Fade from top
        for x in range(size):
            # Only apply within rounded rect bounds (approximate)
            dist_from_edge = min(x, y, size - x - 1, size - y - 1)
            if dist_from_edge > corner_radius * 0.3:
                current = img.getpixel((x, y))
                if current[3] > 0:  # Has alpha
                    new_color = (
                        min(255, current[0] + alpha),
                        min(255, current[1] + alpha),
                        min(255, current[2] + alpha + 10),
                        current[3]
                    )
                    img.putpixel((x, y), new_color)

    # Draw waveform
    center_y = size // 2
    wave_width = int(size * 0.65)
    wave_start_x = (size - wave_width) // 2
    bar_width = max(2, int(size * 0.035))
    bar_spacing = max(3, int(size * 0.055))
    num_bars = wave_width // bar_spacing

    # Waveform heights (symmetric pattern)
    heights = []
    for i in range(num_bars):
        # Create a pleasing waveform pattern
        t = i / (num_bars - 1) if num_bars > 1 else 0.5
        # Multiple sine waves for organic look
        h = (
            0.5 * math.sin(t * math.pi * 2) +
            0.3 * math.sin(t * math.pi * 4 + 0.5) +
            0.2 * math.sin(t * math.pi * 6 + 1.0)
        )
        h = (h + 1) / 2  # Normalize to 0-1
        h = 0.3 + h * 0.5  # Scale to 0.3-0.8
        heights.append(h)

    # Color gradient for bars (cyan to blue)
    for i, h in enumerate(heights):
        x = wave_start_x + i * bar_spacing
        bar_height = int(size * 0.5 * h)

        # Gradient from cyan to blue based on position
        t = i / len(heights)
        r = int(50 + 100 * (1 - t))
        g = int(200 - 50 * t)
        b = int(255 - 30 * t)
        bar_color = (r, g, b)

        # Draw bar (centered vertically)
        y1 = center_y - bar_height // 2
        y2 = center_y + bar_height // 2

        # Rounded caps
        cap_radius = bar_width // 2
        draw.rounded_rectangle(
            [(x, y1), (x + bar_width, y2)],
            radius=cap_radius,
            fill=bar_color
        )

    # Add a subtle glow effect around waveform
    # (simplified - just brighten center area slightly)

    return img


def main():
    # Output directory
    script_dir = Path(__file__).parent.parent
    output_dir = script_dir / "WhisperKitApp" / "WhisperKitApp" / "Assets.xcassets" / "AppIcon.appiconset"

    if not output_dir.exists():
        print(f"Creating output directory: {output_dir}")
        output_dir.mkdir(parents=True, exist_ok=True)

    # Icon sizes needed for macOS and iOS
    sizes = [16, 32, 64, 128, 256, 512, 1024]

    print("Generating VoiceKitLab app icons...")

    for size in sizes:
        icon = create_app_icon(size)
        filename = f"AppIcon-{size}.png"
        filepath = output_dir / filename
        icon.save(filepath, "PNG")
        print(f"  Created: {filename}")

    # Create Contents.json
    contents = """{
  "images" : [
    {
      "filename" : "AppIcon-16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "AppIcon-32.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "AppIcon-32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "AppIcon-64.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "AppIcon-128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "AppIcon-256.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "AppIcon-256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "AppIcon-512.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "AppIcon-512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "AppIcon-1024.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    },
    {
      "filename" : "AppIcon-1024.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""

    contents_path = output_dir / "Contents.json"
    contents_path.write_text(contents)
    print(f"  Created: Contents.json")

    print(f"\nDone! Icons saved to: {output_dir}")


if __name__ == "__main__":
    main()

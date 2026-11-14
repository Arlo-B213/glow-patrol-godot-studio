"""Key out a flat green (#00FF00-ish) background to transparent.

Usage: python key_green.py <in.png> <out.png>

Pixels that are clearly green (green high, red and blue low) become fully transparent.
Greenish pixels on the character edge are pulled back toward the neighbouring colour
to reduce green fringing.
"""
import sys

from PIL import Image


def is_green(r: int, g: int, b: int) -> bool:
    return g > 150 and g > r + 60 and g > b + 60


def key(src: str, dst: str) -> float:
    img = Image.open(src).convert("RGBA")
    px = img.load()
    w, h = img.size
    removed = 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if is_green(r, g, b):
                px[x, y] = (r, g, b, 0)
                removed += 1
            elif g > r and g > b:
                # Spill: cap the green channel so edges stop looking green.
                px[x, y] = (r, min(g, max(r, b)), b, a)
    img.save(dst, "PNG")
    return 100.0 * removed / (w * h)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    share = key(sys.argv[1], sys.argv[2])
    print(f"keyed {share:.1f}% of pixels -> {sys.argv[2]}")

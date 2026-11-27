"""Remove the dark purple neon background from an approved reference image.

Usage: python cutout.py <in.png> <out.png> [tolerance] [size]

Flood-fills from the image border through pixels close to the corner colour, so
interior colours that happen to match the background (for example the lantern
glow) are kept unless they touch the border. Output is an RGBA PNG resized so
its longest side is `size` (default 512, the portrait size from the pipeline doc).
"""
import sys
from collections import deque

from PIL import Image


def cutout(src: str, dst: str, tolerance: int = 60, size: int = 512) -> None:
    img = Image.open(src).convert("RGBA")
    w, h = img.size
    px = img.load()
    bg = px[0, 0][:3]

    def near_bg(x: int, y: int) -> bool:
        r, g, b, _ = px[x, y]
        return abs(r - bg[0]) + abs(g - bg[1]) + abs(b - bg[2]) <= tolerance

    seen = [[False] * h for _ in range(w)]
    queue: deque = deque()
    for x in range(w):
        for y in (0, h - 1):
            if near_bg(x, y) and not seen[x][y]:
                seen[x][y] = True
                queue.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if near_bg(x, y) and not seen[x][y]:
                seen[x][y] = True
                queue.append((x, y))

    while queue:
        x, y = queue.popleft()
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and not seen[nx][ny] and near_bg(nx, ny):
                seen[nx][ny] = True
                queue.append((nx, ny))

    for x in range(w):
        for y in range(h):
            if seen[x][y]:
                r, g, b, _ = px[x, y]
                px[x, y] = (r, g, b, 0)

    scale = size / max(w, h)
    if scale < 1:
        img = img.resize((round(w * scale), round(h * scale)), Image.LANCZOS)
    img.save(dst, "PNG")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    tol = int(sys.argv[3]) if len(sys.argv) > 3 else 60
    out_size = int(sys.argv[4]) if len(sys.argv) > 4 else 512
    cutout(sys.argv[1], sys.argv[2], tol, out_size)
    print(f"saved {sys.argv[2]}")

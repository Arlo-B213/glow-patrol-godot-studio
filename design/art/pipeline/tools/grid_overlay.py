"""Draw a labelled coordinate grid over an image, to trace part outlines.

Usage: python grid_overlay.py <in.png> <out.png> [step]
"""
import sys
from PIL import Image, ImageDraw, ImageFont

src, dst = sys.argv[1], sys.argv[2]
step = int(sys.argv[3]) if len(sys.argv) > 3 else 64
img = Image.open(src).convert("RGBA")
bg = Image.new("RGBA", img.size, (60, 60, 60, 255))
bg.alpha_composite(img)
d = ImageDraw.Draw(bg)
font = ImageFont.load_default()
for x in range(0, img.width + 1, step):
    d.line([(x, 0), (x, img.height)], fill=(255, 0, 255, 255), width=1)
    d.text((x + 2, 2), str(x), fill=(255, 255, 255, 255), font=font)
for y in range(0, img.height + 1, step):
    d.line([(0, y), (img.width, y)], fill=(0, 255, 255, 255), width=1)
    d.text((2, y + 2), str(y), fill=(255, 255, 255, 255), font=font)
bg.convert("RGB").save(dst)
print("saved", dst)

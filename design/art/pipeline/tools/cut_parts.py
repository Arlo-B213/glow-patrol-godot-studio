"""Cut named parts out of an approved image using polygons (pixels stay exactly as approved).

Usage: python cut_parts.py <parts.json> <out_dir> [overlay.png] [check.png]
Parts are listed back to front. Each part keeps only the source pixels inside its polygon,
minus any polygons named in its "cut_out" list. "check.png" stacks all parts back to front
so the cut can be compared with the source.
"""
import json
import os
import sys

from PIL import Image, ImageChops, ImageDraw


def polygon_mask(size, poly):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).polygon([tuple(p) for p in poly], fill=255)
    return m


def main():
    spec_path, out_dir = sys.argv[1], sys.argv[2]
    overlay_path = sys.argv[3] if len(sys.argv) > 3 else None
    check_path = sys.argv[4] if len(sys.argv) > 4 else None
    spec = json.load(open(spec_path))
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(spec_path)))
    src = Image.open(os.path.join(base_dir, spec["source"])).convert("RGBA")
    os.makedirs(out_dir, exist_ok=True)
    size = src.size
    by_name = {p["name"]: p for p in spec["parts"]}
    overlay = src.copy()
    draw = ImageDraw.Draw(overlay)
    colours = [(255, 0, 0), (0, 255, 0), (0, 128, 255), (255, 0, 255), (255, 255, 0), (0, 255, 255), (255, 128, 0)]
    check = Image.new("RGBA", size, (0, 0, 0, 0))
    for i, part in enumerate(spec["parts"]):
        mask = polygon_mask(size, part["poly"])
        for other in part.get("cut_out", []):
            hole = polygon_mask(size, by_name[other]["poly"])
            mask = ImageChops.subtract(mask, hole)
        alpha = ImageChops.multiply(mask, src.getchannel("A"))
        out = src.copy()
        out.putalpha(alpha)
        out.save(os.path.join(out_dir, part["name"] + ".png"))
        check.alpha_composite(out)
        print(part["name"], "bbox", out.getbbox())
        c = colours[i % len(colours)]
        draw.line([tuple(p) for p in part["poly"]] + [tuple(part["poly"][0])], fill=c, width=3)
        draw.text((part["poly"][0][0] + 4, part["poly"][0][1] + 4), part["name"], fill=c)
    if overlay_path:
        overlay.convert("RGB").save(overlay_path)
        print("overlay", overlay_path)
    if check_path:
        bg = Image.new("RGBA", size, (60, 60, 60, 255))
        bg.alpha_composite(check)
        bg.convert("RGB").save(check_path)
        print("check", check_path)


if __name__ == "__main__":
    main()

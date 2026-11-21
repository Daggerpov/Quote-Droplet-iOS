"""Frames the raw StoreScreens shots for the App Store: a caption above the screenshot, on the
background color of the palette that screen was taken in.

    python3 make_store_screens.py <raw dir> <out dir> [iphone|ipad]

iphone → 1320x2868 (6.9" display), ipad → 2064x2752 (13" display). Needs Pillow.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

# name in the raw dir → (palette, eyebrow, headline). The order here is the store order.
SCREENS = [
    ("1-droplets", "Espresso", "QUOTE DROPLET", "A daily drop\nof wisdom"),
    ("7-home", "Espresso", "WIDGETS", "Quotes right on\nyour home screen"),
    ("8-custom", "Sage", "YOUR OWN QUOTES", "Add the quotes\nthat matter to you"),
    ("2-appearance", "Espresso", "MAKE IT YOURS", "Eight palettes,\nor your own colors"),
    ("3-search", "Midnight", "SEARCH", "Find the words\nyou need"),
    ("4-top", "Sky", "TOP QUOTES", "The quotes readers\nlove most"),
    ("5-community", "Linen", "COMMUNITY", "Share the quotes\nthat moved you"),
    ("6-notification", "Ember", "DAILY NOTIFICATION", "One quote a day,\nat your time"),
]

# [background, text, accent], same as the app's ColorHelper.swift.
PALETTES = {
    "Espresso": ("3A2C24", "F7EEDD", "E8B66B"),
    "Midnight": ("0C1A2E", "F1E4CE", "DDA978"),
    "Ember": ("1E1D2A", "F4F2F8", "F59A62"),
    "Sky": ("DCEEF8", "0F2536", "1D6696"),
    "Linen": ("F6F0E6", "3A2E27", "A9492A"),
    "Sage": ("E6ECE2", "1E2B22", "3F6E4E"),
}

SIZES = {"iphone": (1320, 2868), "ipad": (2064, 2752)}

SERIF = "/System/Library/Fonts/NewYork.ttf"
SANS = "/System/Library/Fonts/SFNS.ttf"


def rgb(hex_string):
    return tuple(int(hex_string[i:i + 2], 16) for i in (0, 2, 4))


def mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def font(path, size, axes):
    """Loads a variable system font with the given axis values (see get_variation_axes())."""
    f = ImageFont.truetype(path, size)
    f.set_variation_by_axes(axes)
    return f


def compose(raw_path, out_path, size, palette, eyebrow, headline, ipad):
    W, H = size
    bg, text, accent = (rgb(c) for c in PALETTES[palette])
    is_dark = sum(bg) / 3 < 128
    top = mix(bg, (255, 255, 255), 0.06) if is_dark else mix(bg, (255, 255, 255), 0.25)
    bottom = mix(bg, (0, 0, 0), 0.35) if is_dark else mix(bg, text, 0.08)

    canvas = Image.new("RGB", (W, H), bg)
    draw = ImageDraw.Draw(canvas)
    for y in range(H):
        draw.line([(0, y), (W, y)], fill=mix(top, bottom, y / (H - 1)))

    # Caption.
    scale = W / 1320 if not ipad else 1.35
    eyebrow_font = font(SANS, round(40 * scale), [100, 28, 400, 640])  # width, optical size, grade, weight
    headline_font = font(SERIF, round(108 * scale), [32, 640, 0])  # optical size, weight, grade
    y = round(150 * scale) if not ipad else 150
    tracking = round(6 * scale)
    width = sum(draw.textlength(ch, font=eyebrow_font) for ch in eyebrow) + tracking * (len(eyebrow) - 1)
    x = (W - width) / 2
    for ch in eyebrow:
        draw.text((x, y), ch, font=eyebrow_font, fill=accent)
        x += draw.textlength(ch, font=eyebrow_font) + tracking
    y += round(80 * scale)
    draw.multiline_text((W / 2, y), headline, font=headline_font, fill=text, anchor="ma",
                        align="center", spacing=round(18 * scale))
    caption_bottom = draw.multiline_textbbox((W / 2, y), headline, font=headline_font, anchor="ma",
                                             align="center", spacing=round(18 * scale))[3]

    # Screenshot with rounded corners, a hairline and a soft shadow.
    shot = Image.open(raw_path).convert("RGB")
    shot_top = caption_bottom + round(90 * scale)
    margin_bottom = round(70 * scale)
    max_h = H - shot_top - margin_bottom
    max_w = round(W * (0.80 if not ipad else 0.80))
    ratio = min(max_w / shot.width, max_h / shot.height)
    sw, sh = round(shot.width * ratio), round(shot.height * ratio)
    shot = shot.resize((sw, sh), Image.LANCZOS)
    radius = round(sw * (0.115 if not ipad else 0.035))
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, sw - 1, sh - 1), radius=radius, fill=255)
    sx = (W - sw) // 2
    sy = shot_top

    shadow = Image.new("L", (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle((sx, sy + 24, sx + sw, sy + sh + 24), radius=radius, fill=110 if is_dark else 60)
    shadow = shadow.filter(ImageFilter.GaussianBlur(40))
    canvas.paste(Image.new("RGB", (W, H), (0, 0, 0)), (0, 0), shadow)

    border = round(5 * scale)
    frame_color = mix(bg, text, 0.22) if is_dark else mix(bg, text, 0.16)
    ImageDraw.Draw(canvas).rounded_rectangle((sx - border, sy - border, sx + sw + border, sy + sh + border),
                                             radius=radius + border, fill=frame_color)
    canvas.paste(shot, (sx, sy), mask)
    canvas.save(out_path, "PNG")


def main():
    raw_dir, out_dir = sys.argv[1], sys.argv[2]
    kind = sys.argv[3] if len(sys.argv) > 3 else "iphone"
    os.makedirs(out_dir, exist_ok=True)
    n = 0
    for name, palette, eyebrow, headline in SCREENS:
        raw = os.path.join(raw_dir, f"{name}.png")
        if not os.path.exists(raw):
            print("skip (no raw shot):", name)
            continue
        n += 1
        out = os.path.join(out_dir, f"{n:02d}-{name.split('-', 1)[1]}.png")
        compose(raw, out, SIZES[kind], palette, eyebrow, headline, kind == "ipad")
        print(out)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Rough placeholder sprites for foes with no picked art (30 October, Ryan: "make a placeholder
art with whatever tools you have available. It can be a comically rough entry as a reminder").

Each foe is a few flat shapes at the cut's own sizes (72x96, 96x144 when massive; a 16x16 map
token), outlined in one dark pixel like the foeforge cuts and stamped with a yellow "?" in a
corner, so nobody mistakes it for a pick. A render picked through tools/foeforge replaces it.

    python3 tools/placeholder_art.py            # every foe below that has no art yet
    python3 tools/placeholder_art.py king_gel   # just these, overwriting
    python3 tools/placeholder_art.py --force    # every foe below, overwriting

Then run Godot's import (README) so the new PNGs load.
"""
import math
import os
import sys

from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "foes")
OUTLINE = (20, 22, 28, 255)
STAMP = (255, 220, 40, 255)


def _outline(im):
    """One dark pixel round the drawing, as the cuts have."""
    a = im.getchannel("A")
    w, h = im.size
    src = a.load()
    px = im.load()
    for y in range(h):
        for x in range(w):
            if src[x, y]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and src[nx, ny]:
                    px[x, y] = OUTLINE
                    break
    return im


def _stamp(im):
    """The reminder: a yellow "?" on a dark tag in the top right corner."""
    d = ImageDraw.Draw(im)
    w = im.size[0]
    d.rectangle((w - 11, 1, w - 2, 12), fill=OUTLINE)
    d.line((w - 9, 4, w - 8, 3), fill=STAMP)
    d.line((w - 8, 3, w - 5, 3), fill=STAMP)
    d.line((w - 4, 4, w - 4, 5), fill=STAMP)
    d.line((w - 5, 6, w - 6, 7), fill=STAMP)
    d.point((w - 6, 8), fill=STAMP)
    d.point((w - 6, 10), fill=STAMP)
    return im


def _map_token(combat):
    """The map's 16x16 token: the combat sprite shrunk whole, nearest, centred, outlined again."""
    box = combat.getchannel("A").getbbox() or (0, 0) + combat.size
    body = combat.crop(box)
    bw, bh = body.size
    scale = min(14 / bw, 14 / bh)
    small = body.resize((max(1, round(bw * scale)), max(1, round(bh * scale))), Image.NEAREST)
    token = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    token.paste(small, ((16 - small.size[0]) // 2, 15 - small.size[1]), small)
    return _outline(token)


def king_gel(d, w, h):
    blue, dark, light = (64, 140, 230, 255), (34, 82, 170, 255), (190, 230, 255, 255)
    d.ellipse((10, 50, 86, 138), fill=blue)
    d.chord((10, 50, 86, 138), 20, 160, fill=dark)
    d.ellipse((24, 62, 40, 78), fill=light)
    d.ellipse((32, 84, 42, 98), fill=OUTLINE)
    d.ellipse((54, 84, 64, 98), fill=OUTLINE)
    d.arc((30, 92, 66, 120), 20, 160, fill=OUTLINE, width=3)
    gold, red, green = (240, 196, 40, 255), (220, 40, 50, 255), (40, 190, 90, 255)
    d.polygon([(30, 54), (34, 30), (42, 44), (48, 26), (54, 44), (62, 30), (66, 54)], fill=gold)
    d.rectangle((30, 50, 66, 56), fill=gold)
    d.ellipse((45, 34, 51, 40), fill=red)
    d.ellipse((35, 42, 39, 46), fill=green)
    d.ellipse((57, 42, 61, 46), fill=green)
    for x in (2, 78):
        d.ellipse((x, 112, x + 16, 132), fill=blue)
        d.point((x + 5, 120), fill=OUTLINE)
        d.point((x + 10, 120), fill=OUTLINE)


def pilgrim(d, w, h):
    robe, robe_d, skin = (130, 88, 50, 255), (92, 60, 34, 255), (110, 170, 80, 255)
    d.polygon([(20, 92), (26, 40), (36, 26), (48, 40), (54, 92)], fill=robe)
    d.polygon([(26, 40), (36, 26), (48, 40), (44, 46), (30, 46)], fill=robe_d)
    d.ellipse((28, 34, 46, 52), fill=skin)
    d.ellipse((31, 40, 35, 44), fill=(255, 230, 60, 255))
    d.ellipse((39, 40, 43, 44), fill=(255, 230, 60, 255))
    d.line((24, 60, 10, 66), fill=robe, width=4)
    d.rectangle((4, 64, 14, 78), fill=(250, 210, 80, 255))
    d.rectangle((6, 67, 12, 75), fill=(255, 250, 200, 255))
    d.line((9, 58, 9, 64), fill=(90, 90, 100, 255), width=2)
    d.line((50, 60, 60, 54), fill=robe, width=4)
    d.polygon([(58, 56), (70, 30), (64, 56)], fill=(200, 205, 215, 255))
    d.line((58, 56, 64, 58), fill=(70, 50, 30, 255), width=3)


def phantom_train(d, w, h):
    black, grey, green = (38, 40, 48, 255), (90, 94, 106, 255), (90, 255, 140, 255)
    d.rectangle((14, 60, 82, 128), fill=black)
    d.rectangle((38, 20, 58, 60), fill=black)
    d.rectangle((34, 16, 62, 24), fill=grey)
    for i, (x, y) in enumerate(((44, 4), (54, 0), (36, 0))):
        d.ellipse((x, y, x + 12, y + 10), fill=(180, 255, 200, 160 - i * 30))
    d.ellipse((22, 64, 74, 116), fill=grey)
    d.ellipse((32, 76, 44, 90), fill=green)
    d.ellipse((52, 76, 64, 90), fill=green)
    d.polygon([(46, 92), (50, 92), (48, 98)], fill=OUTLINE)
    d.rectangle((34, 102, 62, 108), fill=(230, 230, 220, 255))
    for x in range(36, 62, 5):
        d.line((x, 102, x, 108), fill=OUTLINE)
    d.polygon([(10, 128), (86, 128), (74, 142), (22, 142)], fill=grey)
    for x in range(24, 76, 8):
        d.line((x, 130, x - 4, 140), fill=black, width=2)


def vampire_lord(d, w, h):
    cape, lining, skin = (30, 26, 38, 255), (170, 24, 40, 255), (226, 222, 232, 255)
    d.polygon([(4, 94), (20, 30), (36, 22), (52, 30), (68, 94)], fill=cape)
    d.polygon([(18, 94), (28, 40), (44, 40), (54, 94)], fill=lining)
    d.polygon([(22, 32), (14, 12), (30, 24)], fill=cape)
    d.polygon([(50, 32), (58, 12), (42, 24)], fill=cape)
    d.ellipse((26, 14, 46, 38), fill=skin)
    d.polygon([(26, 22), (36, 12), (46, 22)], fill=(40, 34, 50, 255))
    d.point((31, 26), fill=(255, 40, 40, 255))
    d.point((32, 26), fill=(255, 40, 40, 255))
    d.point((40, 26), fill=(255, 40, 40, 255))
    d.point((41, 26), fill=(255, 40, 40, 255))
    d.line((32, 32, 40, 32), fill=OUTLINE)
    d.point((33, 33), fill=(255, 255, 255, 255))
    d.point((39, 33), fill=(255, 255, 255, 255))
    for x in (6, 58):
        d.line((x, 56, x + 8, 50), fill=skin, width=2)


def obsidian_tyrant(d, w, h):
    black, crack, eye = (34, 30, 40, 255), (255, 120, 30, 255), (255, 200, 40, 255)
    d.polygon([(6, 80), (30, 60), (60, 58), (72, 70), (64, 100), (40, 104), (20, 98)], fill=black)
    d.polygon([(52, 26), (90, 22), (94, 44), (80, 52), (66, 64), (56, 60), (50, 40)], fill=black)
    d.polygon([(66, 46), (94, 44), (92, 52), (70, 54)], fill=(190, 40, 40, 255))
    for x in range(70, 92, 5):
        d.polygon([(x, 44), (x + 2, 49), (x + 4, 44)], fill=(240, 240, 230, 255))
    d.ellipse((74, 28, 80, 34), fill=eye)
    d.line((30, 100, 26, 136), fill=black, width=8)
    d.line((50, 102, 54, 136), fill=black, width=8)
    d.line((20, 136, 34, 136), fill=black, width=4)
    d.line((48, 136, 62, 136), fill=black, width=4)
    d.line((60, 70, 70, 80), fill=black, width=4)
    d.line((8, 80, 0, 96), fill=black, width=6)
    for seg in [((20, 74), (34, 82), (44, 76)), ((36, 92), (46, 88), (56, 94)), ((58, 32), (66, 36))]:
        d.line(seg, fill=crack, width=1)
    d.rectangle((30, 54, 44, 60), fill=(120, 70, 140, 255))


def saurian_queen(d, w, h):
    robe, scale, gold = (110, 60, 150, 255), (90, 160, 90, 255), (240, 196, 40, 255)
    d.polygon([(18, 94), (26, 40), (46, 40), (54, 94)], fill=robe)
    d.ellipse((26, 22, 46, 44), fill=scale)
    d.polygon([(24, 26), (36, 2), (48, 26)], fill=gold)
    d.ellipse((33, 10, 39, 16), fill=(220, 40, 60, 255))
    d.point((31, 32), fill=OUTLINE)
    d.point((41, 32), fill=OUTLINE)
    d.line((32, 38, 40, 38), fill=OUTLINE)
    d.line((48, 52, 60, 46), fill=scale, width=3)
    d.arc((40, 10, 72, 60), 270, 80, fill=(255, 250, 150, 255), width=2)


def rotbloom(d, w, h):
    body, dark, mouth = (110, 150, 60, 255), (70, 100, 40, 255), (150, 30, 50, 255)
    d.ellipse((12, 50, 84, 128), fill=body)
    d.chord((12, 50, 84, 128), 10, 170, fill=dark)
    d.ellipse((24, 70, 72, 110), fill=mouth)
    for x in range(28, 70, 7):
        d.polygon([(x, 74), (x + 3, 82), (x + 6, 74)], fill=(240, 236, 210, 255))
        d.polygon([(x, 106), (x + 3, 98), (x + 6, 106)], fill=(240, 236, 210, 255))
    purple = (140, 70, 160, 255)
    for i in range(5):
        a = math.radians(200 + i * 35)
        x0, y0 = 48 + 30 * math.cos(a), 86 + 34 * math.sin(a)
        x1, y1 = 48 + 46 * math.cos(a), 86 + 52 * math.sin(a)
        d.line((x0, y0, x1, y1), fill=purple, width=5)
        d.ellipse((x1 - 4, y1 - 4, x1 + 4, y1 + 4), fill=purple)
    d.line((20, 128, 14, 142), fill=dark, width=6)
    d.line((76, 128, 82, 142), fill=dark, width=6)


def gilgamesh(d, w, h):
    red, gold, skin = (190, 40, 40, 255), (230, 190, 60, 255), (220, 180, 140, 255)
    d.polygon([(16, 94), (22, 46), (50, 46), (56, 94)], fill=red)
    d.rectangle((24, 46, 48, 66), fill=gold)
    d.ellipse((26, 22, 46, 46), fill=skin)
    d.polygon([(24, 30), (36, 14), (48, 30)], fill=red)
    d.polygon([(20, 22), (24, 30), (16, 30)], fill=gold)
    d.polygon([(52, 22), (48, 30), (56, 30)], fill=gold)
    d.point((32, 34), fill=OUTLINE)
    d.point((40, 34), fill=OUTLINE)
    d.line((32, 40, 40, 40), fill=OUTLINE)
    steel = (200, 205, 215, 255)
    for x0, y0, x1, y1 in ((48, 56, 70, 18), (24, 56, 4, 22), (50, 70, 70, 74), (22, 70, 2, 76)):
        d.line((x0, y0, x1, y1), fill=steel, width=3)
        d.line((x0, y0, (x0 * 3 + x1) / 4, (y0 * 3 + y1) / 4), fill=(110, 70, 40, 255), width=4)


def _eye(d, w, h, iris):
    bronze, crack = (170, 120, 60, 255), (250, 240, 170, 255)
    d.chord((4, 20, 68, 92), 140, 400, fill=bronze)
    d.ellipse((16, 38, 56, 74), fill=(245, 245, 235, 255))
    d.ellipse((28, 44, 44, 68), fill=iris)
    d.rectangle((34, 46, 37, 66), fill=OUTLINE)
    d.line((8, 40, 18, 46), fill=crack)
    d.line((60, 44, 52, 50), fill=crack)
    d.line((36, 82, 38, 90), fill=crack)


def piercing_eye(d, w, h):
    _eye(d, w, h, (220, 50, 50, 255))


def prising_eye(d, w, h):
    _eye(d, w, h, (60, 200, 90, 255))


FOES = {
    # id: (draw, massive)
    "king_gel": (king_gel, True),
    "pilgrim": (pilgrim, False),
    "phantom_train": (phantom_train, True),
    "vampire_lord": (vampire_lord, False),
    "obsidian_tyrant": (obsidian_tyrant, True),
    "saurian_queen": (saurian_queen, False),
    "rotbloom": (rotbloom, True),
    "gilgamesh": (gilgamesh, False),
    "piercing_eye": (piercing_eye, False),
    "prising_eye": (prising_eye, False),
}


def draw(foe_id):
    fn, massive = FOES[foe_id]
    w, h = (96, 144) if massive else (72, 96)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    fn(ImageDraw.Draw(im), w, h)
    # Alpha is all or nothing in the cuts (a half-lit smoke puff stays lit, as drawn).
    px = im.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255 if a >= 96 else 0)
    drawn = _outline(im)
    token = _map_token(drawn.copy())   # the token from the drawing alone; the stamp is the combat sprite's
    return _stamp(drawn), token


def main(argv):
    force = "--force" in argv
    ids = [a for a in argv if not a.startswith("--")]
    for foe_id in ids or FOES.keys():
        if foe_id not in FOES:
            sys.exit("no placeholder for %s (known: %s)" % (foe_id, ", ".join(FOES)))
        combat_path = os.path.join(OUT, "%s_combat.png" % foe_id)
        if os.path.exists(combat_path) and not (force or ids):
            continue
        combat, token = draw(foe_id)
        combat.save(combat_path)
        token.save(os.path.join(OUT, "%s_map.png" % foe_id))
        print("drew", foe_id)


if __name__ == "__main__":
    main(sys.argv[1:])

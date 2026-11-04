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


def djinn(d, w, h):
    blue, dark, gold, smoke = (70, 120, 220, 255), (40, 70, 160, 255), (240, 196, 40, 255), (150, 170, 210, 255)
    d.polygon([(30, 60), (44, 60), (46, 74), (40, 86), (34, 94), (36, 82), (30, 72)], fill=smoke)
    d.polygon([(22, 36), (50, 36), (46, 62), (26, 62)], fill=blue)
    d.line((22, 40, 8, 54), fill=blue, width=6)
    d.line((50, 40, 60, 26), fill=blue, width=6)
    d.rectangle((10, 50, 16, 54), fill=gold)
    d.rectangle((54, 30, 60, 34), fill=gold)
    d.ellipse((26, 16, 46, 38), fill=blue)
    d.ellipse((22, 4, 50, 24), fill=(150, 60, 140, 255))
    d.polygon([(36, 8), (40, 13), (36, 18), (32, 13)], fill=gold)
    d.point((32, 28), fill=OUTLINE)
    d.point((40, 28), fill=OUTLINE)
    d.line((31, 33, 41, 33), fill=dark, width=2)
    d.arc((52, 2, 76, 34), 180, 290, fill=(220, 225, 235, 255), width=3)
    d.line((60, 26, 58, 30), fill=(110, 70, 40, 255), width=3)


def ruby_colossus(d, w, h):
    # Ruby Weapon by archetype: a red colossus half-buried in the sand, two tentacles rising.
    red, dark, sand, eye = (190, 30, 36, 255), (120, 16, 24, 255), (214, 184, 120, 255), (255, 230, 90, 255)
    d.ellipse((4, 106, 92, 140), fill=sand)
    d.polygon([(26, 120), (22, 70), (34, 46), (62, 46), (74, 70), (70, 120)], fill=red)
    d.polygon([(34, 62), (62, 62), (66, 104), (30, 104)], fill=dark)
    d.line((48, 62, 48, 104), fill=red, width=2)
    d.ellipse((34, 22, 62, 52), fill=red)
    d.polygon([(36, 30), (24, 8), (42, 26)], fill=dark)
    d.polygon([(60, 30), (72, 8), (54, 26)], fill=dark)
    d.rectangle((40, 36, 44, 39), fill=eye)
    d.rectangle((52, 36, 56, 39), fill=eye)
    d.line((14, 122, 8, 82), fill=red, width=7)
    d.line((82, 122, 88, 82), fill=red, width=7)
    d.ellipse((2, 74, 16, 88), fill=dark)
    d.ellipse((80, 74, 94, 88), fill=dark)


def _tentacle(d, w, h, thrash):
    red, dark, sand = (190, 30, 36, 255), (120, 16, 24, 255), (214, 184, 120, 255)
    d.ellipse((8, 72, 64, 94), fill=sand)
    if thrash:
        d.line((36, 84, 30, 50), fill=red, width=9)
        d.line((30, 50, 46, 28), fill=red, width=9)
        d.line((46, 28, 32, 10), fill=red, width=8)
        d.ellipse((24, 2, 40, 18), fill=dark)
        d.line((46, 28, 62, 22), fill=red, width=5)
    else:
        d.line((36, 84, 36, 40), fill=red, width=10)
        d.polygon([(24, 44), (48, 44), (36, 10)], fill=dark)
        d.line((14, 80, 58, 80), fill=dark, width=2)


def burrowing_tentacle(d, w, h):
    _tentacle(d, w, h, False)


def thrashing_tentacle(d, w, h):
    _tentacle(d, w, h, True)


def _giant(d, w, h, pal):
    """The Marsh's massive line (31 October): an undead giant in plate, its cleaver down."""
    plate, dark, skin, eye, iron = pal
    d.polygon([(18, 54), (78, 54), (86, 104), (70, 110), (26, 110), (10, 104)], fill=plate)
    d.rectangle((26, 108, 42, 140), fill=dark)
    d.rectangle((54, 108, 70, 140), fill=dark)
    d.rectangle((22, 136, 44, 142), fill=plate)
    d.rectangle((52, 136, 74, 142), fill=plate)
    d.ellipse((4, 50, 26, 70), fill=dark)
    d.ellipse((70, 50, 92, 70), fill=dark)
    d.line((14, 68, 10, 104), fill=skin, width=7)
    d.line((82, 68, 86, 98), fill=skin, width=7)
    d.ellipse((36, 28, 60, 54), fill=skin)
    d.polygon([(34, 36), (48, 24), (62, 36), (60, 42), (36, 42)], fill=dark)
    d.rectangle((41, 44, 44, 47), fill=eye)
    d.rectangle((52, 44, 55, 47), fill=eye)
    d.line((42, 51, 54, 51), fill=dark, width=2)
    for y in range(64, 104, 10):
        d.line((22, y, 74, y), fill=dark, width=1)
    d.polygon([(80, 96), (94, 96), (94, 130), (84, 136), (80, 128)], fill=iron)
    d.line((86, 92, 86, 100), fill=(90, 60, 40, 255), width=4)


GIANTS = {
    "barrow_giant": ((150, 84, 44, 255), (96, 54, 32, 255), (140, 160, 128, 255), (130, 255, 170, 255), (150, 150, 160, 255)),
    "grave_giant": ((200, 196, 182, 255), (120, 116, 108, 255), (150, 170, 196, 255), (255, 250, 200, 255), (110, 110, 120, 255)),
    "charnel_giant": ((54, 56, 66, 255), (24, 26, 32, 255), (196, 182, 96, 255), (255, 230, 90, 255), (200, 170, 70, 255)),
}


def barrow_giant(d, w, h):
    _giant(d, w, h, GIANTS["barrow_giant"])


def grave_giant(d, w, h):
    _giant(d, w, h, GIANTS["grave_giant"])


def charnel_giant(d, w, h):
    _giant(d, w, h, GIANTS["charnel_giant"])


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



# The elites session's placeholders (3 November): the Fiend of Fire, the Peak's third boss, and
# the new elites and wanderers, each a few flat shapes, a reminder until a render is picked.

def fiend_of_fire(d, w, h):
    ember, scale, flame, blade = (200, 60, 40, 255), (40, 30, 34, 255), (250, 170, 40, 255), (210, 220, 230, 255)
    d.polygon([(10, 140), (30, 96), (48, 70), (66, 96), (86, 140)], fill=scale)
    d.ellipse((20, 118, 76, 142), fill=scale)
    d.rectangle((40, 44, 56, 80), fill=ember)
    d.ellipse((38, 26, 58, 48), fill=ember)
    d.polygon([(40, 28), (48, 8), (52, 26), (60, 12), (58, 30)], fill=flame)
    for i, (x0, y0, x1, y1) in enumerate(((40, 52, 14, 40), (40, 60, 10, 62), (40, 68, 16, 86), (56, 52, 82, 40), (56, 60, 86, 62), (56, 68, 80, 86))):
        d.line((x0, y0, x1, y1), fill=ember, width=4)
        d.line((x1, y1, x1 + (-6 if x1 < 48 else 6), y1 - 14), fill=blade, width=3)
    d.ellipse((42, 34, 46, 38), fill=flame)
    d.ellipse((50, 34, 54, 38), fill=flame)


def bane(d, w, h):
    smoke, fire, horn = (36, 30, 40, 255), (240, 120, 30, 255), (90, 70, 60, 255)
    d.polygon([(14, 140), (28, 70), (48, 44), (68, 70), (82, 140)], fill=smoke)
    d.polygon([(8, 110), (28, 60), (34, 100)], fill=smoke)
    d.polygon([(88, 110), (68, 60), (62, 100)], fill=smoke)
    d.polygon([(34, 20), (48, 0), (62, 20), (58, 46), (38, 46)], fill=fire)
    d.ellipse((40, 30, 56, 46), fill=smoke)
    d.ellipse((43, 35, 47, 39), fill=fire)
    d.ellipse((49, 35, 53, 39), fill=fire)
    d.polygon([(36, 32), (22, 12), (40, 26)], fill=horn)
    d.polygon([(60, 32), (74, 12), (56, 26)], fill=horn)
    d.line((26, 80, 4, 40), fill=fire, width=4)   # the whip
    d.line((70, 84, 88, 30), fill=fire, width=6)  # the sword


def firelord(d, w, h):
    lava, rock, flame = (235, 110, 30, 255), (50, 36, 32, 255), (250, 200, 60, 255)
    d.ellipse((4, 112, 92, 142), fill=lava)
    d.polygon([(22, 124), (30, 60), (66, 60), (74, 124)], fill=rock)
    d.rectangle((28, 70, 68, 76), fill=lava)
    d.rectangle((28, 92, 68, 98), fill=lava)
    d.ellipse((34, 30, 62, 62), fill=rock)
    d.polygon([(34, 36), (40, 8), (48, 30), (56, 6), (62, 36)], fill=flame)
    d.ellipse((40, 42, 46, 48), fill=flame)
    d.ellipse((50, 42, 56, 48), fill=flame)
    d.line((68, 70, 90, 30), fill=rock, width=6)   # the hammer's haft
    d.rectangle((80, 14, 96, 40), fill=rock)
    d.rectangle((82, 18, 94, 36), fill=lava)


def thunder_ape(d, w, h):
    fur, gold, horn, bolt = (40, 36, 44, 255), (240, 200, 50, 255), (120, 100, 80, 255), (120, 220, 255, 255)
    d.ellipse((12, 36, 60, 88), fill=fur)
    d.ellipse((18, 20, 50, 50), fill=fur)
    d.polygon([(20, 26), (12, 8), (26, 22)], fill=horn)
    d.polygon([(46, 26), (54, 8), (40, 22)], fill=horn)
    d.ellipse((24, 30, 30, 36), fill=gold)
    d.ellipse((36, 30, 42, 36), fill=gold)
    d.ellipse((6, 62, 24, 92), fill=fur)
    d.ellipse((48, 62, 66, 92), fill=fur)
    d.rectangle((30, 42, 38, 46), fill=gold)
    d.line((34, 44, 50, 24, 44, 24, 60, 4), fill=bolt, width=3)


def rust_monster(d, w, h):
    rust, dark, antenna = (170, 90, 40, 255), (110, 56, 26, 255), (220, 160, 80, 255)
    d.ellipse((10, 50, 62, 84), fill=rust)
    d.chord((10, 50, 62, 84), 180, 360, fill=dark)
    d.ellipse((48, 56, 70, 76), fill=rust)
    d.ellipse((58, 62, 62, 66), fill=OUTLINE)
    d.line((64, 60, 70, 36, 60, 24), fill=antenna, width=2)
    d.line((66, 62, 72, 44, 64, 30), fill=antenna, width=2)
    d.polygon([(10, 66), (0, 60), (0, 74)], fill=dark)   # the paddle tail
    for x in (16, 28, 40, 52):
        d.rectangle((x, 82, x + 6, 92), fill=dark)


def skeleton_king(d, w, h):
    bone, plate, gold, cloak = (225, 215, 190, 255), (110, 80, 60, 255), (230, 190, 40, 255), (70, 30, 50, 255)
    d.polygon([(18, 92), (22, 40), (50, 40), (54, 92)], fill=cloak)
    d.rectangle((26, 40, 46, 70), fill=plate)
    d.ellipse((28, 18, 44, 36), fill=bone)
    d.ellipse((31, 24, 35, 28), fill=OUTLINE)
    d.ellipse((37, 24, 41, 28), fill=OUTLINE)
    d.polygon([(28, 20), (30, 8), (34, 16), (36, 6), (38, 16), (42, 8), (44, 20)], fill=gold)
    d.line((48, 50, 64, 20), fill=plate, width=4)   # the mace
    d.ellipse((58, 10, 72, 24), fill=plate)
    d.rectangle((28, 70, 34, 92), fill=bone)
    d.rectangle((38, 70, 44, 92), fill=bone)


def fell_rider(d, w, h):
    beast, cloak, blade = (60, 50, 70, 255), (20, 16, 24, 255), (200, 210, 230, 255)
    d.polygon([(4, 50), (24, 60), (18, 40)], fill=beast)    # the wings
    d.polygon([(68, 50), (48, 60), (54, 40)], fill=beast)
    d.ellipse((18, 56, 56, 84), fill=beast)
    d.polygon([(54, 62), (70, 52), (66, 70)], fill=beast)   # the head
    d.line((16, 70, 2, 90), fill=beast, width=4)             # the tail
    d.polygon([(28, 58), (30, 26), (44, 26), (46, 58)], fill=cloak)
    d.ellipse((30, 14, 44, 30), fill=cloak)
    d.line((46, 40, 62, 16), fill=blade, width=3)
    for x in (22, 34, 46):
        d.rectangle((x, 84, x + 4, 94), fill=beast)


def collector(d, w, h):
    cloak, cage, light = (34, 30, 40, 255), (90, 90, 100, 255), (230, 240, 200, 255)
    d.polygon([(22, 94), (28, 30), (44, 30), (50, 94)], fill=cloak)
    d.rectangle((28, 10, 44, 32), fill=cage)
    d.rectangle((31, 13, 41, 29), fill=light)
    for x in (33, 36, 39):
        d.line((x, 13, x, 29), fill=cage, width=1)
    d.line((52, 20, 56, 94), fill=cage, width=3)   # the staff
    for x in (24, 34, 44):
        d.ellipse((x, 66, x + 8, 76), fill=(200, 180, 160, 255))   # the heads at its belt


def wild_hunt_rider(d, w, h):
    horse, plate, frost = (200, 200, 210, 255), (30, 28, 36, 255), (170, 220, 250, 255)
    d.ellipse((10, 52, 56, 76), fill=horse)
    d.polygon([(52, 56), (68, 44), (62, 66)], fill=horse)
    for x in (14, 26, 38, 48):
        d.rectangle((x, 74, x + 4, 90), fill=horse)
    d.polygon([(26, 56), (28, 26), (40, 26), (42, 56)], fill=plate)
    d.ellipse((28, 14, 40, 28), fill=plate)
    d.polygon([(28, 18), (24, 4), (32, 16)], fill=plate)
    d.polygon([(40, 18), (44, 4), (36, 16)], fill=plate)
    d.line((42, 40, 70, 20), fill=frost, width=3)   # the lance
    d.ellipse((4, 80, 14, 90), fill=frost)


def ravener(d, w, h):
    hide, belly, teeth = (56, 90, 50, 255), (120, 130, 90, 255), (240, 240, 230, 255)
    d.ellipse((14, 60, 80, 110), fill=hide)
    d.polygon([(14, 86), (0, 120), (26, 104)], fill=hide)   # the tail
    d.ellipse((50, 28, 96, 72), fill=hide)                  # the head
    d.polygon([(60, 60), (94, 56), (90, 76), (62, 78)], fill=belly)   # the jaw
    for x in (64, 72, 80, 88):
        d.polygon([(x, 58), (x + 3, 68), (x + 6, 58)], fill=teeth)
    d.ellipse((70, 38, 76, 44), fill=(240, 200, 40, 255))
    for x in (30, 44, 58):
        d.polygon([(x, 62), (x + 6, 50), (x + 12, 62)], fill=belly)   # the spines
    d.rectangle((28, 106, 40, 136), fill=hide)
    d.rectangle((56, 106, 68, 136), fill=hide)


def shambler(d, w, h):
    flesh, dark, eye = (90, 50, 80, 255), (50, 26, 46, 255), (230, 220, 90, 255)
    d.ellipse((12, 50, 84, 126), fill=flesh)
    for x0, y0, x1, y1 in ((20, 110, 4, 140), (40, 118, 34, 142), (58, 118, 66, 142), (76, 110, 92, 140), (14, 70, 0, 56), (84, 70, 96, 54)):
        d.line((x0, y0, x1, y1), fill=dark, width=5)
    for cx, cy in ((34, 70), (56, 64), (46, 92), (68, 90), (28, 96)):
        d.ellipse((cx - 6, cy - 6, cx + 6, cy + 6), fill=eye)
        d.ellipse((cx - 2, cy - 2, cx + 2, cy + 2), fill=OUTLINE)


def shambler_spawn(d, w, h):
    flesh, eye = (90, 50, 80, 255), (230, 220, 90, 255)
    d.ellipse((20, 44, 52, 76), fill=flesh)
    d.line((26, 72, 16, 90), fill=flesh, width=4)
    d.line((46, 72, 56, 90), fill=flesh, width=4)
    d.ellipse((30, 54, 42, 66), fill=eye)
    d.ellipse((34, 58, 38, 62), fill=OUTLINE)


def enkidu(d, w, h):
    fur, skin = (120, 80, 50, 255), (170, 130, 90, 255)
    d.ellipse((14, 40, 58, 84), fill=fur)
    d.ellipse((22, 20, 50, 48), fill=skin)
    d.polygon([(22, 30), (18, 10), (30, 24), (36, 8), (42, 24), (54, 10), (50, 30)], fill=fur)
    d.ellipse((28, 30, 33, 35), fill=OUTLINE)
    d.ellipse((39, 30, 44, 35), fill=OUTLINE)
    d.ellipse((6, 60, 20, 88), fill=fur)
    d.ellipse((52, 60, 66, 88), fill=fur)


def goblin_nob(d, w, h):
    green, dark, iron, wood = (90, 140, 60, 255), (50, 90, 40, 255), (120, 120, 130, 255), (110, 70, 40, 255)
    d.ellipse((14, 36, 62, 90), fill=green)
    d.rectangle((16, 36, 40, 50), fill=iron)   # the shoulder plate
    d.ellipse((22, 12, 54, 44), fill=green)
    d.polygon([(26, 40), (52, 40), (50, 52), (28, 52)], fill=dark)   # the jaw
    d.ellipse((30, 24, 35, 29), fill=(240, 60, 40, 255))
    d.ellipse((42, 24, 47, 29), fill=(240, 60, 40, 255))
    d.polygon([(20, 22), (8, 14), (24, 30)], fill=green)   # the ears
    d.polygon([(56, 22), (68, 14), (52, 30)], fill=green)
    d.line((56, 56, 70, 14), fill=wood, width=5)            # the club
    d.ellipse((62, 4, 78, 24), fill=wood)
    for x, y in ((64, 6), (74, 10), (70, 20)):
        d.rectangle((x, y, x + 2, y + 2), fill=iron)
    d.rectangle((22, 88, 32, 94), fill=dark)
    d.rectangle((44, 88, 54, 94), fill=dark)



def mantis_ant(d, w, h):
    brown, dark, blade = (130, 80, 40, 255), (80, 48, 24, 255), (200, 190, 150, 255)
    d.ellipse((24, 70, 72, 110), fill=brown)        # the abdomen
    d.ellipse((36, 46, 64, 76), fill=brown)         # the thorax
    d.ellipse((38, 20, 62, 48), fill=dark)          # the head
    d.ellipse((42, 28, 48, 34), fill=blade)
    d.ellipse((52, 28, 58, 34), fill=blade)
    d.line((44, 22, 30, 4), fill=dark, width=2)     # the antennae
    d.line((56, 22, 70, 4), fill=dark, width=2)
    d.polygon([(36, 52), (8, 30), (14, 26), (40, 46)], fill=blade)   # the mantis blades
    d.polygon([(64, 52), (92, 30), (86, 26), (60, 46)], fill=blade)
    for x0, y0, x1, y1 in ((36, 84, 12, 104), (40, 96, 18, 124), (64, 84, 88, 104), (60, 96, 82, 124)):
        d.line((x0, y0, x1, y1), fill=dark, width=3)
    d.polygon([(6, 136), (30, 118), (66, 118), (90, 136)], fill=(90, 70, 40, 255))   # the broken earth


def marsh_serpent(d, w, h):
    scale, belly, fang, water = (40, 90, 60, 255), (130, 160, 90, 255), (240, 240, 230, 255), (30, 40, 44, 255)
    d.ellipse((0, 118, 96, 142), fill=water)
    d.ellipse((10, 96, 60, 132), fill=scale)        # the coils
    d.ellipse((40, 100, 90, 134), fill=scale)
    d.polygon([(44, 110), (50, 40), (70, 40), (76, 110)], fill=scale)   # the raised body
    d.rectangle((54, 50, 66, 108), fill=belly)
    d.polygon([(34, 44), (60, 10), (86, 44), (80, 60), (40, 60)], fill=scale)   # the hood
    d.ellipse((46, 24, 74, 56), fill=scale)         # the head
    d.ellipse((52, 34, 58, 40), fill=(240, 200, 40, 255))
    d.ellipse((62, 34, 68, 40), fill=(240, 200, 40, 255))
    d.polygon([(52, 52), (55, 62), (58, 52)], fill=fang)
    d.polygon([(62, 52), (65, 62), (68, 52)], fill=fang)
    d.line((60, 56, 60, 70, 56, 76), fill=(220, 60, 60, 255), width=2)   # the tongue


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
    "djinn": (djinn, False),
    "barrow_giant": (barrow_giant, True),
    "grave_giant": (grave_giant, True),
    "charnel_giant": (charnel_giant, True),
    "piercing_eye": (piercing_eye, False),
    "prising_eye": (prising_eye, False),
    "ruby_colossus": (ruby_colossus, True),
    "burrowing_tentacle": (burrowing_tentacle, False),
    "thrashing_tentacle": (thrashing_tentacle, False),
    "fiend_of_fire": (fiend_of_fire, True),
    "bane": (bane, True),
    "firelord": (firelord, True),
    "thunder_ape": (thunder_ape, False),
    "rust_monster": (rust_monster, False),
    "skeleton_king": (skeleton_king, False),
    "fell_rider": (fell_rider, False),
    "collector": (collector, False),
    "wild_hunt_rider": (wild_hunt_rider, False),
    "ravener": (ravener, True),
    "shambler": (shambler, True),
    "shambler_spawn": (shambler_spawn, False),
    "enkidu": (enkidu, False),
    "goblin_nob": (goblin_nob, False),
    "mantis_ant": (mantis_ant, True),
    "marsh_serpent": (marsh_serpent, True),
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

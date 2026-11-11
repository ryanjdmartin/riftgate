#!/usr/bin/env python3
"""The field's caches as flat map tokens, for a hex the other world has flattened.

A cache on solid ground is a model (tools/lowforge: cache_<id>); where the painting has taken
its hex the model is gone with the ground and the map view draws this picture in its place, in
the foes' map-token register (16x16, a dark outline, three tones), since everything on flattened
ground is a flat picture. The grids are typed here, one a loot kind in content/loot.json, and
written to art/loot/<id>_map.png:

    python3 tools/loot_tokens.py          # then: godot --headless --path . --import
    python3 tools/loot_tokens.py sheet.png   # also a contact sheet at 12x, for review

tests/test_content.gd ties the files to the content's ids, so a renamed kind fails the build
until its grid's name follows. First cuts.
"""

import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "art" / "loot"

PALETTE = {
    ".": (0, 0, 0, 0),
    "k": (20, 16, 24, 255),      # the outline
    # steel, a wreck's
    "s": (52, 60, 72, 255),
    "S": (98, 110, 126, 255),
    "W": (176, 188, 202, 255),
    "a": (255, 190, 64, 255),    # the lamp still lit
    # bone
    "b": (140, 132, 108, 255),
    "B": (206, 198, 172, 255),
    "w": (244, 240, 222, 255),
    "h": (84, 50, 62, 255),      # dried hide
    # their stone and their light
    "d": (34, 30, 46, 255),
    "D": (66, 58, 88, 255),
    "v": (124, 72, 216, 255),
    "V": (200, 164, 255, 255),
    "x": (242, 232, 255, 255),
}

GRIDS = {
    # A machine's hulk, canted, its gun drooped to the right, one lamp lit at its stern.
    "derelict": """
................
......kkkk......
....kkWWWSkk....
...kWWWWSSskkkk.
...kSWWSSskSSSk.
.kkkkSSSsskkksk.
kWWWkkkkkkSSkk..
kSWWWWWWSSSSsk..
kSSWWWWSSSSssk..
ksSSSSSSSSsssk..
kaksssssssskak..
.kkskskskskkk...
..kkkkkkkkk.kkk.
............kSsk
.............kk.
................
""",
    # One of theirs picked to the bone: the skull at the left, the spine, a cage of ribs.
    "carcass": """
................
................
.....k.k.k.k....
....kBkBkBkBk...
...kBkkBkBkBkk..
..kkBk.kBkBkBk..
.kwwkkkkkkkkBkk.
kwwwwBBBBBBBBbk.
kwkwwBkkkkkkkbbk
kwwwBkkBkBkBkkbk
.kkkk.kBkBkBk.kk
.khhk.kBkBkBk...
..kk...k.k.k....
................
................
................
""",
    # A thing of theirs: two splinters of black stone leaning round a core of their light.
    "relic": """
.......kk.......
......kVVk......
.....kVxxVk.....
..k...kVVk...k..
.kdk...kk...kdk.
.kdDk......kDdk.
kdDDk..kk..kDDdk
kdDvk.kVVk.kvDdk
kdDvkkvVVvkkvDdk
kdDDkvVxxVvkDDdk
kdDDkkvVVvkkDDdk
.kdDDkkvvkkDDdk.
.kkdDDkkkkDDdkk.
...kkddddddkk...
.....kkkkkk.....
................
""",
}


def token(grid):
    rows = [r for r in grid.strip("\n").split("\n")]
    if len(rows) != 16 or any(len(r) != 16 for r in rows):
        raise SystemExit("a token is 16 by 16: %s" % [len(r) for r in rows])
    im = Image.new("RGBA", (16, 16))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            im.putpixel((x, y), PALETTE[ch])
    return im


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    ims = {}
    for name, grid in GRIDS.items():
        ims[name] = token(grid)
        ims[name].save(OUT / ("%s_map.png" % name))
    if len(sys.argv) > 1:
        sheet = Image.new("RGBA", (len(ims) * 16 * 12, 16 * 12), (42, 54, 40, 255))
        for i, im in enumerate(ims.values()):
            sheet.alpha_composite(im.resize((192, 192), Image.NEAREST), (i * 192, 0))
        sheet.save(sys.argv[1])
    print("loot tokens: %s -> %s" % (", ".join(ims), OUT))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Export the enemy sprite grids from docs/sprites-enemies.html to PNGs the engine loads.

The enemy sheet draws every foe from a hand-typed character grid and a per-faction palette.
Until better enemy art exists, those grids are the enemy art. This reads them straight out of
the page so the sheet stays the single place they are edited, and writes:

    art/foes/<foe_id>_combat.png   48x64 (elites 64x96), the skirmish sprite
    art/foes/<foe_id>_map.png      16x16 token (the bone colossus 40x40), the map sprite
    art/foes/contact.png           everything at 3x on one sheet, for review

Run from the repo root with the spriter venv, then let Godot import the new files:

    tools/spriter/.venv/bin/python tools/sheet_export.py
    godot --headless --path . --import
"""

import re
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SHEET = ROOT / "docs" / "sprites-enemies.html"
OUT = ROOT / "art" / "foes"

# grid name -> (foe id, palette name)
COMBAT = {
    # The sheet's grids predate the domains of 9 October; each exports under the foe that
    # descends from it (content/foes.json). The brute, the spawn and the whisperer have no heir.
    "GHOUL": ("revenant", "UND"),
    "NECRO": ("ghost", "UND"),
    "COLOSSUS": ("bone_wyvern", "UND"),
    "HELLCASTER": ("drake", "DEM"),
    "PITLORD": ("magma_elemental", "DEM"),
    "MAW": ("sandworm", "ELD"),
}
MAP = {
    "T_GHOUL": ("revenant", "UND"),
    "T_NECRO": ("ghost", "UND"),
    "TB_COLOSSUS": ("bone_wyvern", "UND"),
    "T_HELLCASTER": ("drake", "DEM"),
    "T_PITLORD": ("magma_elemental", "DEM"),
    "T_MAW": ("sandworm", "ELD"),
}


def parse_palettes(text):
    palettes = {}
    for name, body in re.findall(r"var (UND|DEM|ELD) = \{(.*?)\};", text, re.S):
        entries = re.findall(r"'?([^\s:'\",{}]+)'?\s*:\s*'(#[0-9a-fA-F]{6})'", body)
        palettes[name] = {k: v for k, v in entries}
    return palettes


def parse_grids(text):
    grids = {}
    for name, body in re.findall(r"var ([A-Z_]+) = \[(.*?)\];", text, re.S):
        rows = re.findall(r"'([.#A-Za-z0-9]+)'", body)
        if rows:
            grids[name] = rows
    return grids


def hex_rgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def render(rows, palette):
    w = max(len(r) for r in rows)
    h = len(rows)
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    missing = set()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            col = palette.get(ch)
            if col is None:
                missing.add(ch)
                continue
            px[x, y] = hex_rgb(col) + (255,)
    return img, missing


def main():
    text = SHEET.read_text(encoding="utf-8")
    palettes = parse_palettes(text)
    grids = parse_grids(text)
    OUT.mkdir(parents=True, exist_ok=True)
    problems = []
    written = []

    # A foe cut from a foeforge pick (tools/foeforge/picks/picks.json, 9 October) keeps that
    # art: the sketch grids are the floor, and every foe has a pick now. --force overwrites.
    picks_file = ROOT / "tools" / "foeforge" / "picks" / "picks.json"
    picked = set()
    if picks_file.exists():
        import json
        picked = {p["foe"] for p in json.loads(picks_file.read_text())["picks"].values() if p["role"] in ("sprite", "chibi")}
    force = "--force" in sys.argv

    def export(table, suffix):
        for grid_name, (foe_id, pal_name) in table.items():
            if foe_id in picked and not force:
                problems.append(f"{grid_name}: {foe_id} has foeforge art; kept (--force overwrites)")
                continue
            rows = grids.get(grid_name)
            if rows is None:
                problems.append(f"{grid_name}: grid not found in the sheet")
                continue
            img, missing = render(rows, palettes[pal_name])
            if missing:
                problems.append(f"{grid_name}: no colour for {sorted(missing)} in {pal_name}")
            path = OUT / f"{foe_id}_{suffix}.png"
            img.save(path)
            written.append((foe_id, suffix, img))

    export(COMBAT, "combat")
    export(MAP, "map")

    # Contact sheet: combat sprites at 3x with their map tokens beneath, on the field colour.
    combat = [(f, i) for f, s, i in written if s == "combat"]
    tokens = {f: i for f, s, i in written if s == "map"}
    if not combat:
        for p in problems:
            print("  " + p)
        print("nothing exported: every grid's foe has foeforge art (--force overwrites)")
        return
    scale = 3
    cell_w = 64 * scale + 24
    cell_h = 96 * scale + 40 * scale + 40
    sheet = Image.new("RGBA", (cell_w * len(combat), cell_h), (0x1B, 0x1F, 0x26, 255))
    draw = ImageDraw.Draw(sheet)
    for n, (foe_id, img) in enumerate(combat):
        x = n * cell_w + 12
        big = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
        sheet.paste(big, (x, 96 * scale - big.height + 8), big)
        tok = tokens.get(foe_id)
        if tok is not None:
            tbig = tok.resize((tok.width * scale, tok.height * scale), Image.NEAREST)
            sheet.paste(tbig, (x, 96 * scale + 24), tbig)
        draw.text((x, cell_h - 18), foe_id, fill=(0xE8, 0xE4, 0xD6, 255))
    sheet.save(OUT / "contact.png")

    for foe_id, suffix, img in written:
        print(f"  {foe_id}_{suffix}.png  {img.width}x{img.height}")
    print(f"wrote {len(written)} sprites and contact.png to {OUT.relative_to(ROOT)}")
    for p in problems:
        print("PROBLEM:", p)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())

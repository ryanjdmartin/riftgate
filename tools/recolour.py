#!/usr/bin/env python3
"""A recolour's sprites from its base's: the ladder's palette swaps (Ryan, 28 October:
"classic palette-swaps in the final fantasy style"; "Recolour by hue is fine as long as the
colour is sufficiently different and they have a modified name or prefix or something ...
Don't need another marker").

    python3 tools/recolour.py <base> <id> --hue H --light L [--tint T]
    python3 tools/recolour.py --all

The same transform on art/foes/<base>_combat.png and <base>_map.png, written beside them as
art/foes/<id>_combat.png and <id>_map.png; run Godot's --import after (CLAUDE.md). For every
opaque pixel whose lightness (HLS) lies between 0.12 and 0.95, so the outline and the whites
stay: a saturated pixel (saturation 0.15 or more) has its hue rotated by H degrees; a grey one
takes hue H outright at saturation T when T is given, and stays as it is when not; every pixel
it changes has its lightness multiplied by L, held between 0.05 and 0.97. The alpha never
changes. No other marker.

--all writes every recolour in TABLE, the hues chosen on 28 October by the three Machado
simulations (protan, deutan and tritan at severity 1.0, in linear RGB): each pair kept as far
from its base, and the tier three from the tier two, as the worst of the three leaves them
(the mean per-pixel distance in simulated sRGB). A pair Ryan cannot tell apart on the phone
takes a lightness step here, never a marker.
"""

import argparse
import colorsys
import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FOES = os.path.join(ROOT, "art", "foes")
KINDS = ("combat", "map")

# base -> [(id, hue, light, tint or None)], tier two then tier three.
TABLE = {
    "goblin": [("goblin_guard", 240, 0.80, 0.45), ("goblin_captain", 180, 1.25, 0.45)],
    "wolf": [("warg", 60, 1.25, 0.45), ("alpha_warg", 240, 0.80, 0.45)],
    "gel": [("bubble_gel", 150, 0.80, None), ("metal_gel", 180, 1.25, None)],
    "mandragora": [("mandrake", 210, 1.25, None), ("alraune", 60, 1.25, None)],
    "needler": [("barbed_needler", 180, 0.80, 0.45), ("great_needler", 270, 0.80, 0.45)],
    "antlion": [("pit_antlion", 210, 0.80, None), ("antlion_queen", 150, 1.25, None)],
    "cockatrice": [("basilisk", 210, 0.80, None), ("gorgon", 180, 1.25, None)],
    "revenant": [("wight", 240, 0.80, 0.45), ("lich", 60, 1.25, 0.45)],
    "ghost": [("spectre", 240, 0.80, 0.45), ("wraith", 60, 1.25, 0.45)],
    "zombie_knight": [("death_knight", 60, 1.25, 0.45), ("dread_knight", 240, 0.80, 0.45)],
    "bomb": [("grenade", 180, 1.25, 0.45), ("balloon", 240, 1.00, None)],
    "salamander": [("fire_lizard", 210, 1.25, None), ("magma_lizard", 60, 1.25, None)],
    "drake": [("wyvern", 240, 1.25, None), ("red_dragon", 60, 1.25, None)],
    # The massive lines (31 October), by the same three simulations: the worst case 64 for the
    # Treant's (tinted, its whites grey), 77 for the Sandworm's (hue 180 at tier two, past the
    # violet that 240 and 210 landed on) and 47 for the Magma Elemental's (tinted, its rock grey).
    "treant": [("dusk_treant", 240, 0.80, 0.45), ("frost_treant", 180, 1.25, 0.45)],
    "sandworm": [("night_sandworm", 180, 0.80, None), ("salt_sandworm", 150, 1.25, None)],
    "magma_golem": [("basalt_elemental", 210, 1.25, 0.45), ("sulphur_elemental", 60, 1.25, 0.45)],
}


def recolour(pixels: np.ndarray, hue: float, light: float, tint) -> np.ndarray:
    """The transform on an (n, 4) RGBA array of 0..255, returned as a new uint8 array."""
    out = pixels.copy()
    for i, (r, g, b, a) in enumerate(pixels):
        if a == 0:
            continue
        h, l, s = colorsys.rgb_to_hls(r / 255.0, g / 255.0, b / 255.0)
        if l < 0.12 or l > 0.95:
            continue   # the outline and the whites
        if s < 0.15:
            if tint is None or tint <= 0:
                continue   # a grey stays without a tint
            h, s = hue / 360.0, tint   # a grey takes the hue outright
        else:
            h = (h + hue / 360.0) % 1.0
        l = min(0.97, max(0.05, l * light))
        r2, g2, b2 = colorsys.hls_to_rgb(h, l, s)
        out[i, :3] = [int(round(r2 * 255)), int(round(g2 * 255)), int(round(b2 * 255))]
    return out


def write(base: str, rid: str, hue: float, light: float, tint) -> None:
    for kind in KINDS:
        src = os.path.join(FOES, "%s_%s.png" % (base, kind))
        if not os.path.exists(src):
            sys.exit("no %s sprite for %s: %s" % (kind, base, src))
        im = Image.open(src).convert("RGBA")
        px = np.array(im, dtype=np.uint8)
        flat = recolour(px.reshape(-1, 4), hue, light, tint)
        Image.fromarray(flat.reshape(px.shape), "RGBA").save(os.path.join(FOES, "%s_%s.png" % (rid, kind)))
        print("%s_%s.png from %s_%s.png: hue %d, light %.2f%s" % (rid, kind, base, kind, hue, light, "" if tint is None else ", tint %.2f" % tint))


def main() -> None:
    ap = argparse.ArgumentParser(description="A recolour's sprites from its base's (the ladder's palette swaps).")
    ap.add_argument("base", nargs="?")
    ap.add_argument("id", nargs="?")
    ap.add_argument("--hue", type=float)
    ap.add_argument("--light", type=float, default=1.0)
    ap.add_argument("--tint", type=float)
    ap.add_argument("--all", action="store_true", help="write every recolour in the table")
    args = ap.parse_args()
    if args.all:
        for base, rows in TABLE.items():
            for rid, hue, light, tint in rows:
                write(base, rid, hue, light, tint)
        return
    if not args.base or not args.id or args.hue is None:
        ap.error("give a base, an id and --hue, or --all")
    write(args.base, args.id, args.hue, args.light, args.tint)


if __name__ == "__main__":
    main()

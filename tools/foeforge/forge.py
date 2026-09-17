#!/usr/bin/env python3
"""Enemy sprites from an image model, then cut down to what the engine loads.

Two steps, both driven from content/foes.json so the prompts and the file names come from
the same place as the codex text:

    generate   render candidate images for a foe with mflux (FLUX on Apple silicon)
    cut        turn one chosen candidate into art/foes/<id>_combat.png and <id>_map.png

    tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate ghoul --n 4
    tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut tools/foeforge/out/ghoul/ghoul_3.png ghoul
    godot --headless --path . --import

`generate` writes tools/foeforge/out/<id>/<id>_<seed>.png and a contact sheet of the batch.
`cut` keys out the flat background, crops to the figure, scales to the sprite frame (48x64,
elites 64x96, map tokens 16x16 or 40x40 for the colossus), quantises to the faction palette
from the enemy sheet, and adds the one-pixel outline. Nothing overwrites art/foes until you
run `cut`, so the exported sketch grids stay until a candidate beats them.
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent.parent
FOES = ROOT / "content" / "foes.json"
SHEET = ROOT / "docs" / "sprites-enemies.html"
OUT = ROOT / "tools" / "foeforge" / "out"
ART = ROOT / "art" / "foes"
MFLUX = ROOT / "tools" / "foeforge" / ".venv" / "bin" / "mflux-generate-flux2"
MFLUX_EDIT = ROOT / "tools" / "foeforge" / ".venv" / "bin" / "mflux-generate-flux2-edit"

MODEL = "flux2-klein-4b"
QUANTIZE = "4"
STEPS = "4"
WIDTH, HEIGHT = 512, 768

STYLE = (
    "16-bit SNES RPG battle sprite in the style of Final Fantasy VI enemies: ornate, detailed, "
    "over-the-top high fantasy, up to twenty colours, one-pixel dark outline. Full body, facing "
    "the viewer in three-quarter view, centered, isolated on a solid flat pure white background, "
    "no text, no border, no ground shadow."
)

FACTION_LOOK = {
    "undead": "sickly green flesh, bone white, faded purple rags, a green necrotic glow",
    "demonic": "deep red hide, black iron, brass trim, fire orange and yellow embers",
    "eldritch": "violet flesh, dark teal shadows, pale cyan glow, too many eyes",
}

PALETTE_FOR = {"undead": "UND", "demonic": "DEM", "eldritch": "ELD"}
COMBAT_SIZE = {1: (48, 64), 2: (64, 96)}
MAP_SIZE = {1: (16, 16), 2: (16, 16)}
BIG_MAP = {"bone_colossus": (40, 40)}


def load_foes():
    return {e["id"]: e for e in json.loads(FOES.read_text())["entries"]}


def prompt_for(foe):
    look = FACTION_LOOK.get(foe.get("faction", ""), "")
    body = " ".join(s for s in [foe.get("design", {}).get("fantasy", ""), foe.get("codex", "")] if s)
    size = "A towering elite, twice the height of a common foe." if int(foe.get("size") or 1) > 1 else ""
    return f"{STYLE} Subject: {foe['name']}, a {foe.get('faction', '')} monster. {body} {size} Colours: {look}."


def generate(args):
    foes = load_foes()
    foe = foes[args.foe]
    out = OUT / args.foe
    out.mkdir(parents=True, exist_ok=True)
    prompt = args.prompt or prompt_for(foe)
    (out / "prompt.txt").write_text(prompt + "\n")
    print(prompt)
    height = HEIGHT if int(foe.get("size") or 1) == 1 else 1024
    made = []
    for seed in range(args.seed, args.seed + args.n):
        path = out / f"{args.foe}_{seed}.png"
        cmd = [str(MFLUX), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", prompt,
               "--width", str(WIDTH), "--height", str(height), "--steps", STEPS,
               "--seed", str(seed), "--output", str(path)]
        print("rendering", path.name)
        subprocess.run(cmd, check=True)
        made.append(path)
    contact(made, out / "contact.png")
    print(f"{len(made)} candidates in {out.relative_to(ROOT)}")


def contact(paths, dest):
    imgs = [Image.open(p).convert("RGB") for p in paths]
    if not imgs:
        return
    w = 256
    h = int(imgs[0].height * w / imgs[0].width)
    sheet = Image.new("RGB", (w * len(imgs), h + 20), (27, 31, 38))
    d = ImageDraw.Draw(sheet)
    for i, (p, im) in enumerate(zip(paths, imgs)):
        sheet.paste(im.resize((w, h), Image.LANCZOS), (i * w, 0))
        d.text((i * w + 4, h + 4), p.stem, fill=(232, 228, 214))
    sheet.save(dest)


# ---------------------------------------------------------------- cut

def parse_palettes():
    text = SHEET.read_text(encoding="utf-8")
    palettes = {}
    for name, body in re.findall(r"var (UND|DEM|ELD) = \{(.*?)\};", text, re.S):
        entries = re.findall(r"'?([^\s:'\",{}]+)'?\s*:\s*'(#[0-9a-fA-F]{6})'", body)
        palettes[name] = [tuple(int(v[i:i + 2], 16) for i in (1, 3, 5)) for _, v in entries]
    return palettes


def key_background(img, tol=48):
    """Alpha out the flat background: anything close to the corner colour, flood-filled from
    the edges so a white detail inside the figure survives."""
    img = img.convert("RGBA")
    w, h = img.size
    px = img.load()
    corners = [px[0, 0], px[w - 1, 0], px[0, h - 1], px[w - 1, h - 1]]
    bg = tuple(sum(c[i] for c in corners) // 4 for i in range(3))

    def near(p):
        return all(abs(p[i] - bg[i]) <= tol for i in range(3))

    seen = bytearray(w * h)
    stack = [(x, 0) for x in range(w)] + [(x, h - 1) for x in range(w)] + [(0, y) for y in range(h)] + [(w - 1, y) for y in range(h)]
    while stack:
        x, y = stack.pop()
        i = y * w + x
        if seen[i] or not near(px[x, y]):
            continue
        seen[i] = 1
        px[x, y] = (0, 0, 0, 0)
        if x > 0:
            stack.append((x - 1, y))
        if x < w - 1:
            stack.append((x + 1, y))
        if y > 0:
            stack.append((x, y - 1))
        if y < h - 1:
            stack.append((x, y + 1))
    return img


def quantize(img, palette, colours=16):
    """Flatten the shading into a few coherent regions (median cut on the opaque pixels),
    then, if a palette is given, snap each region colour to its nearest palette colour.
    Snapping pixel by pixel speckles, because neighbouring shades fall either side of a
    palette boundary; snapping regions keeps the plates flat, the way a pixel artist
    would. With no palette the model's own colours stay, reduced to `colours`."""
    w, h = img.size
    px = img.load()
    # Median cut needs an RGB image. Paint transparent pixels the figure's mean colour so
    # they cost no palette entry and bleed nothing at the edges; alpha is already hard.
    arr = np.array(img)
    opaque = arr[..., 3] >= 128
    fill = arr[opaque][:, :3].mean(axis=0).astype(np.uint8) if opaque.any() else np.zeros(3, np.uint8)
    rgb_arr = arr[..., :3].copy()
    rgb_arr[~opaque] = fill
    rgb = Image.fromarray(rgb_arr, "RGB")
    flat = rgb.quantize(colors=colours, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    fp = flat.load()
    cache = {}
    for y in range(h):
        for x in range(w):
            if px[x, y][3] < 128:
                px[x, y] = (0, 0, 0, 0)
                continue
            r, g, b = fp[x, y]
            if not palette:
                px[x, y] = (r, g, b, 255)
                continue
            if (r, g, b) not in cache:
                cache[(r, g, b)] = min(palette, key=lambda c: (c[0] - r) ** 2 + (c[1] - g) ** 2 + (c[2] - b) ** 2)
            px[x, y] = cache[(r, g, b)] + (255,)
    return img


def outline(img, colour=(20, 22, 28, 255)):
    """One-pixel outline around the opaque shape, drawn into transparent neighbours."""
    w, h = img.size
    src = img.load()
    out = img.copy()
    dst = out.load()
    for y in range(h):
        for x in range(w):
            if src[x, y][3] >= 128:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and src[nx, ny][3] >= 128:
                    dst[x, y] = colour
                    break
    return out


def fit(img, frame):
    """Scale the cropped figure into the frame, keeping aspect, feet on the floor, with a
    one-pixel margin for the outline. Transparent pixels are painted the figure's mean
    colour before scaling so edge pixels blend with the figure rather than with black, and
    alpha is hard-thresholded afterwards so nothing is half there."""
    fw, fh = frame
    bbox = img.getbbox()
    fig = np.array(img.crop(bbox)).astype(np.float32)
    opaque = fig[..., 3] >= 128
    if opaque.any():
        mean = fig[opaque][:, :3].mean(axis=0)
        fig[~opaque, :3] = mean
    fig[..., 3] = np.where(opaque, 255.0, 0.0)
    fig_img = Image.fromarray(fig.astype(np.uint8), "RGBA")
    inner = (fw - 2, fh - 2)
    scale = min(inner[0] / fig_img.width, inner[1] / fig_img.height)
    size = (max(1, round(fig_img.width * scale)), max(1, round(fig_img.height * scale)))
    small = np.array(fig_img.resize(size, Image.LANCZOS))
    small[..., 3] = np.where(small[..., 3] >= 128, 255, 0)
    small[small[..., 3] == 0] = 0
    canvas = Image.new("RGBA", frame, (0, 0, 0, 0))
    canvas.paste(Image.fromarray(small, "RGBA"), ((fw - size[0]) // 2, fh - 1 - size[1]))
    return canvas


def cut(args):
    foes = load_foes()
    foe = foes[args.foe]
    pal = parse_palettes()[PALETTE_FOR[foe.get("faction", "undead")]] if args.faction_palette else None
    src = key_background(Image.open(args.image))
    size = int(foe.get("size") or 1)
    ART.mkdir(parents=True, exist_ok=True)
    combat = outline(quantize(fit(src, COMBAT_SIZE[size]), pal, args.colours))
    combat.save(ART / f"{args.foe}_combat.png")
    map_frame = BIG_MAP.get(args.foe, MAP_SIZE[size])
    token = outline(quantize(fit(src, map_frame), pal, min(args.colours, 8)))
    token.save(ART / f"{args.foe}_map.png")
    preview = Image.new("RGBA", (combat.width * 4 + token.width * 4 + 24, max(combat.height, token.height) * 4), (27, 31, 38, 255))
    preview.paste(combat.resize((combat.width * 4, combat.height * 4), Image.NEAREST), (0, 0))
    preview.paste(token.resize((token.width * 4, token.height * 4), Image.NEAREST), (combat.width * 4 + 24, 0))
    pv = OUT / args.foe / f"{args.foe}_cut_preview.png"
    pv.parent.mkdir(parents=True, exist_ok=True)
    preview.save(pv)
    print(f"wrote {args.foe}_combat.png {combat.size} and {args.foe}_map.png {token.size}; preview {pv.relative_to(ROOT)}")


# ---------------------------------------------------------------- mechs: the hybrid

CHASSIS = ROOT / "content" / "chassis.json"
MECH_ART = ROOT / "art" / "mechs"
MECH_FRAME = (80, 96)
MECH_STYLE = (
    "Isometric pixel art game sprite of a heavy military mech in the style of Into the Breach: "
    "chunky, rugged, grounded military hardware, riveted plates, exposed pistons, a cockpit slit "
    "glowing cyan, an amber marking light. Keep this pose, proportions and camera angle. Clean "
    "one-pixel dark outline, flat cel shading with strong top-face highlights, isolated on a "
    "solid flat pure white background, no text, no ground shadow."
)
MAKER_LOOK = {
    "minerva": "cold steel grey plates with deep red armour panels",
    "kestrel": "cold steel with cobalt blue airframe panels",
    "wainwright_sutler": "cold steel with bone-white armour plates",
}
# The edit model keeps the render's shape and adds the finish; the instruction says so in
# as many words, then names the finish wanted and the colours to keep.
MECH_EDIT = (
    "Redraw this isometric pixel art mech with exactly the same silhouette, pose, parts, "
    "proportions and camera angle, adding finish: riveted steel plates, panel lines, worn "
    "edges, tread texture on any tracks, hydraulic pistons at the joints, cel shading with "
    "strong top highlights, one-pixel dark outline. Keep the same colours: {look}, cyan cockpit "
    "glass, amber marking lights. Solid flat pure white background, no shadow, no text."
)


def load_chassis():
    d = json.loads(CHASSIS.read_text())
    return {e["id"]: e for e in d["entries"]}


def mech_prompt(c):
    body = " ".join(s for s in [c.get("design", {}).get("fantasy", ""), c.get("codex", "")] if s)
    look = MAKER_LOOK.get(c.get("maker", ""), "cold steel")
    return f"{MECH_STYLE} Subject: the {c['name']}, a {c.get('silhouette', '')} war machine. {body} Colours: {look}."


def mech_reference(chassis_id, turn, src=""):
    """The renderer's own sprite, on white and blown up, as the model's composition
    reference: the design stays fixed and the model does the finish. `src` is any render
    (a blendforge review sprite, say); by default the sprite already in art/mechs."""
    src = Path(src) if src else MECH_ART / f"{chassis_id}_combat_{turn}.png"
    im = Image.open(src).convert("RGBA")
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
    bg.paste(im, (0, 0), im)
    k = 8
    ref = OUT / chassis_id / f"{chassis_id}_{turn}_ref.png"
    ref.parent.mkdir(parents=True, exist_ok=True)
    bg.convert("RGB").resize((im.width * k, im.height * k), Image.NEAREST).save(ref)
    return ref, (im.width * k, im.height * k)


def mech(args):
    c = load_chassis()[args.chassis]
    ref, (w, h) = mech_reference(args.chassis, args.turn, args.ref)
    out = OUT / args.chassis
    if args.mode == "edit":
        prompt = args.prompt or MECH_EDIT.format(look=MAKER_LOOK.get(c.get("maker", ""), "cold steel"))
    else:
        prompt = args.prompt or mech_prompt(c)
    (out / "prompt.txt").write_text(prompt + "\n")
    print(prompt)
    made = []
    for seed in range(args.seed, args.seed + args.n):
        path = out / f"{args.chassis}_{args.turn}_{seed}.png"
        if args.mode == "edit":
            # Edit mode: the render is the picture being edited, not a noisy starting point,
            # so the design survives and the model only adds what the instruction asks for.
            cmd = [str(MFLUX_EDIT), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", prompt,
                   "--image-paths", str(ref), "--steps", STEPS, "--seed", str(seed), "--output", str(path)]
        else:
            cmd = [str(MFLUX), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", prompt,
                   "--image-path", str(ref), "--image-strength", str(args.strength),
                   "--width", str(w), "--height", str(h), "--steps", STEPS,
                   "--seed", str(seed), "--output", str(path)]
        print("rendering", path.name)
        subprocess.run(cmd, check=True)
        made.append(path)
    contact(made, out / f"contact_{args.turn}.png")
    print(f"{len(made)} candidates in {out.relative_to(ROOT)}")


def cut_mech(args):
    src = key_background(Image.open(args.image))
    MECH_ART.mkdir(parents=True, exist_ok=True)
    if args.chunk > 1:
        # The other genre: mechs at a coarser pixel grid than the foes. Fit into a frame
        # `chunk` times smaller, quantise there, then scale up by nearest neighbour so each
        # mech pixel is a block of foe pixels.
        small_frame = (MECH_FRAME[0] // args.chunk, MECH_FRAME[1] // args.chunk)
        small = outline(quantize(fit(src, small_frame), None, args.colours))
        sprite = small.resize((small.width * args.chunk, small.height * args.chunk), Image.NEAREST)
    else:
        sprite = outline(quantize(fit(src, MECH_FRAME), None, args.colours))
    dest = Path(args.out) if args.out else MECH_ART / f"{args.chassis}_combat_{args.turn}.png"
    sprite.save(dest)
    pv = dest.with_name(dest.stem + "_preview.png") if args.out else OUT / args.chassis / f"{args.chassis}_{args.turn}_cut_preview.png"
    pv.parent.mkdir(parents=True, exist_ok=True)
    sprite.resize((sprite.width * 4, sprite.height * 4), Image.NEAREST).save(pv)
    print(f"wrote {dest} {sprite.size}; preview {pv}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    m = sub.add_parser("mech", help="candidates for a mech's combat sprite, from the renderer's sprite as reference")
    m.add_argument("chassis")
    m.add_argument("--turn", default="front_right", choices=["front", "front_left", "front_right"])
    m.add_argument("--n", type=int, default=2)
    m.add_argument("--seed", type=int, default=1)
    m.add_argument("--mode", default="edit", choices=["edit", "img2img"], help="edit (default) keeps the render's design and adds finish; img2img redraws freely from it and rarely keeps the design")
    m.add_argument("--strength", type=float, default=0.3, help="img2img only: how far the model may stray from the render; lower is freer")
    m.add_argument("--prompt", default="")
    m.add_argument("--ref", default="", help="reference sprite to refine (default: the one in art/mechs); e.g. a blendforge render in tools/blendforge/out")
    m.set_defaults(func=mech)
    cm = sub.add_parser("cut-mech", help="cut a chosen candidate into art/mechs/<chassis>_combat_<turn>.png")
    cm.add_argument("image")
    cm.add_argument("chassis")
    cm.add_argument("--turn", default="front_right", choices=["front", "front_left", "front_right"])
    cm.add_argument("--colours", type=int, default=16, help="colours to keep (default 16, the foes' density; 8 was tried for a genre split and dulls a finished sprite)")
    cm.add_argument("--chunk", type=int, default=1, help="pixel size relative to the foes: 2 draws the mech on a grid twice as coarse (tried; it loses too much at 40x48)")
    cm.add_argument("--out", default="", help="write here instead of art/mechs (for experiments)")
    cm.set_defaults(func=cut_mech)
    g = sub.add_parser("generate")
    g.add_argument("foe")
    g.add_argument("--n", type=int, default=4)
    g.add_argument("--seed", type=int, default=1)
    g.add_argument("--prompt", default="")
    g.set_defaults(func=generate)
    c = sub.add_parser("cut")
    c.add_argument("image")
    c.add_argument("foe")
    c.add_argument("--colours", type=int, default=16, help="colours to keep (default 16)")
    c.add_argument("--faction-palette", action="store_true", help="snap to the faction palette from the enemy sheet instead of keeping the model's colours")
    c.set_defaults(func=cut)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())

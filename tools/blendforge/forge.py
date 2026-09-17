#!/usr/bin/env python3
"""Mech sprites from a Blender model, in the spriter's style.

A .blend gives authoritative geometry, so every facing renders identically and a change to the
model is a re-render. Blender only produces data passes (normals, material index, depth); the
shading, tone ramps, creases, outline and frame fitting are the spriter's own, so a mech from
a .blend and a mech from primitives sit side by side without a seam.

    render    render a .blend into the engine's mech files (combat turns, map strip, contact)
    example   build a .blend from one of the spriter's primitive models, as a template

    tools/spriter/.venv/bin/python tools/blendforge/forge.py example bulwark
    tools/spriter/.venv/bin/python tools/blendforge/forge.py render tools/blendforge/models/bulwark.blend bulwark
    tools/spriter/.venv/bin/python tools/blendforge/forge.py render my_anvil.blend anvil --install
    godot --headless --path . --import

Output goes to tools/blendforge/out/<chassis>/ for review; `--install` writes art/mechs instead.

Model conventions (see README.md): one mech per file at the origin, standing on z=0, facing
+y, any scale; materials named by role (steel, steel_dark, livery, glass, amber, rubber, bore,
hot, white) or coloured freely; objects with "detail" in the name are dropped from map tokens.
"""

import argparse
import json
import math
import os
import subprocess
import sys
import tempfile
from dataclasses import asdict
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT / "tools" / "spriter"))
import spriter  # noqa: E402

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
MODELS = HERE / "models"
MECH_ART = ROOT / "art" / "mechs"
CHASSIS = ROOT / "content" / "chassis.json"
BLENDER = os.environ.get("BLENDER", "/Applications/Blender.app/Contents/MacOS/Blender")

COMBAT_FRAME = (80, 96)
COMBAT_BASELINE_PX = 10          # the spriter's 6 units at 1.8 ppu
COMBAT_SUPERSAMPLE = 4
MAP_SUPERSAMPLE = spriter.MAP["supersample"]
MAP_RATIO = spriter.MAP["ppu"] / spriter.COMBAT["ppu"]   # a map token is this much smaller than the combat sprite
PAD = 24
LIGHT = np.array([-0.45, -0.55, 0.7])
CREASE_DEPTH = 3.0


def blender(*args, timeout=600):
    if not Path(BLENDER).exists():
        raise SystemExit(f"Blender not found at {BLENDER}; set BLENDER=/path/to/Blender")
    cmd = [BLENDER, "-b", *args]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    lines = [l for l in r.stdout.splitlines() if l.startswith("blendforge:")]
    for l in lines:
        print(l)
    if r.returncode != 0 or not lines:
        print(r.stdout[-3000:], file=sys.stderr)
        print(r.stderr[-3000:], file=sys.stderr)
        raise SystemExit("Blender failed")


def maker_of(chassis_id, override=""):
    if override:
        return override
    for e in json.loads(CHASSIS.read_text())["entries"]:
        if e["id"] == chassis_id:
            return e.get("maker", "minerva")
    return "minerva"


# ---------------------------------------------------------------- example

def example(args):
    model = spriter.TEMPLATES[args.model]()
    parts = []
    for p in model.parts:
        d = asdict(p)
        d["type"] = "box" if isinstance(p, spriter.Box) else "cyl"
        parts.append(d)
    with tempfile.TemporaryDirectory() as td:
        pj = Path(td) / "parts.json"
        pj.write_text(json.dumps({"name": model.name, "maker": model.maker, "parts": parts}))
        dest = MODELS / f"{model.name}.blend"
        blender("-P", str(HERE / "bl_build.py"), "--", "--parts", str(pj), "--out", str(dest))
    print(f"template at {dest.relative_to(ROOT)}; render it with: forge.py render {dest.relative_to(ROOT)} {model.name}")


# ---------------------------------------------------------------- render

def spec_for(args):
    groups = {
        "combat": {"width": COMBAT_FRAME[0], "height": COMBAT_FRAME[1], "baseline": COMBAT_BASELINE_PX,
                   "fill": args.fill, "ppu": args.ppu},
        "map": {"width": spriter.MAP["width"], "height": spriter.MAP["height"], "baseline": 1,
                "fill": 1.0, "ppu": args.ppu * MAP_RATIO if args.ppu else 0.0,
                "ratio_of": "combat", "ratio": MAP_RATIO},
    }
    views = []
    for k, yaw in spriter.COMBAT_YAWS.items():
        views.append({"name": f"combat_{k}", "group": "combat", "yaw": yaw, "pitch": spriter.COMBAT["pitch"],
                      "detail": True, "supersample": COMBAT_SUPERSAMPLE, "pad": PAD})
    for k, yaw in spriter.MAP_YAWS.items():
        views.append({"name": f"map_{k}", "group": "map", "yaw": yaw, "pitch": spriter.MAP["pitch"],
                      "detail": False, "supersample": MAP_SUPERSAMPLE, "pad": PAD})
    return {"groups": groups, "views": views}


# ---------------------------------------------------------------- surface patterns
# A patterned role is a base material plus a pattern in the part's own coordinates, so it
# sticks to the part in every view and needs no image model. Each returns, per sample, 0
# for untouched, 1 for a dark line (the ramp's darkest tone), 2 for a highlight (one tone
# up). Units are model units; patterns are sized for the 80x96 frame at about 1.2 px/unit.

def _stripes(coord, period, width):
    return (np.mod(coord, period) < width)


def pat_tread(p, n):
    """Tread blocks: dark bands across the run, which lies along local y."""
    return np.where(_stripes(p[..., 1], 3.0, 1.1), 1, 0)


def pat_grille(p, n):
    """Horizontal slats up the face."""
    return np.where(_stripes(p[..., 2], 2.2, 0.9), 1, 0)


def pat_rivet(p, n):
    """A dot every few units in the plane of the face, as a one-pixel highlight."""
    axis = np.argmax(np.abs(n), axis=-1)
    u = np.where(axis == 0, p[..., 1], p[..., 0])
    v = np.where(axis == 2, p[..., 1], p[..., 2])
    dot = _stripes(u + 2.0, 5.0, 1.0) & _stripes(v + 2.0, 5.0, 1.0)
    return np.where(dot, 2, 0)


def pat_panel(p, n):
    """Panel seams: a dark line every few units, both ways across the face."""
    axis = np.argmax(np.abs(n), axis=-1)
    u = np.where(axis == 0, p[..., 1], p[..., 0])
    v = np.where(axis == 2, p[..., 1], p[..., 2])
    return np.where(_stripes(u + 1.0, 7.0, 0.8) | _stripes(v + 1.0, 9.0, 0.8), 1, 0)


PATTERNS = {"tread": ("rubber", pat_tread), "grille": ("steel_dark", pat_grille),
            "rivet": ("steel", pat_rivet), "panel": ("steel", pat_panel)}


def ramp_for(material, maker):
    """The spriter's four tones for a role, or four tones built from the author's colour."""
    if material["role"] in PATTERNS:
        return [spriter.hex_to_rgb(h) for h in spriter.material_ramp(PATTERNS[material["role"]][0], maker)]
    if material["role"]:
        return [spriter.hex_to_rgb(h) for h in spriter.material_ramp(material["role"], maker)]
    c = np.array(material["colour"], dtype=float) ** (1 / 2.2)   # linear to display
    return [tuple(int(v) for v in np.clip(c * f * 255, 0, 255)) for f in (0.38, 0.6, 0.82, 1.0)]


def shade(nrm, aux, yaw, materials, maker, meta, pos=None):
    """Colour every sample the spriter's way: normal against the fixed light, four tones,
    top faces bumped a tone, then the material's surface pattern if it has one. Returns
    colours (h, w, 4), normals in the spriter's world, depth in units, material index,
    coverage."""
    cover = nrm[..., 3] > 127
    n = nrm[..., :3].astype(np.float32) / 255.0 * 2.0 - 1.0
    R = spriter.rot_z(yaw)                      # the spriter's world: the model turned, camera fixed
    n_w = n @ R.T
    norm = np.linalg.norm(n_w, axis=2, keepdims=True)
    n_w = n_w / np.where(norm < 1e-6, 1.0, norm)
    L = LIGHT / np.linalg.norm(LIGHT)
    ndl = n_w @ L
    tone = np.select([ndl > 0.62, ndl > 0.22, ndl > -0.25], [3, 2, 1], default=0)
    tone = np.where((n_w[..., 2] > 0.85) & (tone < 3), tone + 1, tone)
    idx = aux[..., 0].astype(int)
    if pos is not None:
        r = float(meta.get("pos_radius", 1.0))
        local = (pos[..., :3].astype(np.float32) / 255.0 - 0.5) * (2.0 * r)
        for m in materials:
            fn = PATTERNS.get(m["role"], (None, None))[1]
            if fn is None:
                continue
            sel = cover & (idx == m["index"])
            if not sel.any():
                continue
            mark = fn(local, n)          # the part's own normal, before the view turn
            tone = np.where(sel & (mark == 1), 0, tone)
            tone = np.where(sel & (mark == 2), np.minimum(tone + 1, 3), tone)
    depth = meta["depth_near"] + aux[..., 1].astype(np.float32) / 255.0 * (meta["depth_far"] - meta["depth_near"])
    ramps = {m["index"]: ramp_for(m, maker) for m in materials}
    colour = np.zeros(nrm.shape[:2] + (4,), dtype=np.uint8)
    for i, ramp in ramps.items():
        sel = cover & (idx == i)
        for t in range(4):
            s = sel & (tone == t)
            colour[s, :3] = ramp[t]
            colour[s, 3] = 255
    return colour, n_w, depth, idx, cover


def downsample_fields(n_w, depth, idx, cover, k):
    """Per output pixel: the majority material, the mean normal and median depth of its
    covered samples. Creases are decided at output scale from these."""
    h, w = n_w.shape[0] // k, n_w.shape[1] // k
    out_n = np.zeros((h, w, 3), np.float32)
    out_d = np.full((h, w), np.inf, np.float32)
    out_i = np.zeros((h, w), int)
    for y in range(h):
        for x in range(w):
            c = cover[y * k:(y + 1) * k, x * k:(x + 1) * k]
            if c.sum() * 2 < k * k:
                continue
            ids = idx[y * k:(y + 1) * k, x * k:(x + 1) * k][c]
            best = np.bincount(ids).argmax()
            pick = c & (idx[y * k:(y + 1) * k, x * k:(x + 1) * k] == best)
            nn = n_w[y * k:(y + 1) * k, x * k:(x + 1) * k][pick].mean(axis=0)
            out_n[y, x] = nn / max(np.linalg.norm(nn), 1e-6)
            out_d[y, x] = np.median(depth[y * k:(y + 1) * k, x * k:(x + 1) * k][pick])
            out_i[y, x] = best
    return out_n, out_d, out_i


def crease(img, n_w, depth, idx, ramps):
    """The spriter's crease rule at output scale: neighbours whose normals disagree strongly
    or that sit far apart in depth get the farther pixel drawn in its darkest tone."""
    mask = img[..., 3] > 0
    height, width = mask.shape
    crease_px = np.zeros_like(mask)
    for dy, dx in ((0, 1), (1, 0)):
        a = mask[dy:, dx:] & mask[: height - dy, : width - dx]
        dot = (n_w[dy:, dx:] * n_w[: height - dy, : width - dx]).sum(axis=2)
        with np.errstate(invalid="ignore"):
            dz = np.abs(depth[dy:, dx:] - depth[: height - dy, : width - dx])
        far = a & ((dot < 0.15) | (dz > CREASE_DEPTH))
        behind_first = depth[dy:, dx:] > depth[: height - dy, : width - dx]
        c1 = np.zeros_like(mask)
        c1[dy:, dx:] = far & behind_first
        c2 = np.zeros_like(mask)
        c2[: height - dy, : width - dx] = far & ~behind_first
        crease_px |= c1 | c2
    out = img.copy()
    for i, ramp in ramps.items():
        sel = crease_px & (idx == i)
        out[sel, :3] = ramp[0]
    return out


def crop_fit(arr, width, height, pad):
    """The spriter's render_fit crop: centre the drawing horizontally, keep its baseline
    unless it would spill, and warn instead of shrinking if it cannot fit."""
    ys, xs = np.where(arr[:, :, 3] > 0)
    ox, oy = pad, pad
    if ys.size:
        x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
        if x1 - x0 + 3 > width or y1 - y0 + 3 > height:
            print(f"warning: drawing {x1 - x0 + 1}x{y1 - y0 + 1} overflows the {width}x{height} frame; lower --fill or --ppu", file=sys.stderr)
        ox = int(round((x0 + x1 + 1) / 2.0 - width / 2.0))
        if y1 > oy + height - 2:
            oy = y1 - (height - 2)
        if y0 < oy + 1:
            oy = max(y0 - 1, 0)
        ox = max(0, min(ox, arr.shape[1] - width))
        oy = max(0, min(oy, arr.shape[0] - height))
    return arr[oy:oy + height, ox:ox + width].copy()


def compose(view, passes, meta, maker):
    nrm = np.asarray(Image.open(passes / f"{view['name']}_nrm.png").convert("RGBA"))
    aux = np.asarray(Image.open(passes / f"{view['name']}_aux.png").convert("RGBA"))
    pos_file = passes / f"{view['name']}_pos.png"
    pos = np.asarray(Image.open(pos_file).convert("RGBA")) if pos_file.exists() else None
    colour, n_w, depth, idx, cover = shade(nrm, aux, view["yaw"], meta["materials"], maker, meta, pos)
    k = view["supersample"]
    small = spriter._mode_downsample(colour, k)
    if view["detail"]:   # combat scale draws creases; map tokens are too small for them
        n1, d1, i1 = downsample_fields(n_w, depth, idx, cover, k)
        ramps = {m["index"]: ramp_for(m, maker) for m in meta["materials"]}
        small = crease(small, n1, d1, i1, ramps)
    small = spriter._outline(small)
    return Image.fromarray(small, "RGBA")


def render_blend(blend, name, maker, spec, work, out_dir):
    """Render one .blend through Blender and the spriter's shading into out_dir. Returns
    the contact sheet path."""
    blend = Path(blend).resolve()
    if not blend.exists():
        raise SystemExit(f"no such file {blend}")
    passes = Path(work) / "passes"
    passes.mkdir(parents=True, exist_ok=True)
    sj = passes / "spec.json"
    sj.write_text(json.dumps(spec, indent=1))
    blender(str(blend), "-P", str(HERE / "bl_render.py"), "--", "--spec", str(sj), "--out", str(passes))
    meta = json.loads((passes / "meta.json").read_text())
    print("materials:", ", ".join(f"{m['name']}->{m['role'] or 'own colour'}" for m in meta["materials"]))
    print("pixels per unit: combat %.3f, map %.3f" % (meta["ppu"]["combat"], meta["ppu"]["map"]))
    combat, maps = {}, {}
    for v in spec["views"]:
        g = spec["groups"][v["group"]]
        arr = np.asarray(compose(v, passes, meta, maker))
        im = Image.fromarray(crop_fit(arr, g["width"], g["height"], v["pad"]), "RGBA")
        (combat if v["group"] == "combat" else maps)[v["name"].split("_", 1)[1]] = im
    return spriter.write_sheets(name, combat, maps, str(out_dir), contact_only=False)


def render(args):
    maker = maker_of(args.chassis, args.maker)
    out_dir = MECH_ART if args.install else OUT / args.chassis
    path = render_blend(args.blend, args.chassis, maker, spec_for(args), OUT / args.chassis, out_dir)
    print(f"{args.chassis}: {Path(path).relative_to(ROOT)}" + ("" if args.install else "  (add --install to write art/mechs)"))


# ---------------------------------------------------------------- polish

def polish(args):
    """Run the finish pass on a massing file, writing a new .blend beside it. The maker's
    manner and the chassis's kit come from profiles.py."""
    import profiles
    src = Path(args.blend).resolve()
    chassis = args.chassis or src.stem.split("_")[0]
    maker = maker_of(chassis, args.maker)
    prof = profiles.profile_for(maker, chassis)
    if args.strength:
        prof["plate_strength"] = args.strength
        prof["track_strength"] = max(1.0, args.strength * 0.6)
    dest = Path(args.out).resolve() if args.out else src.with_name(src.stem + "_polished.blend")
    finish = HERE / "finish" / f"{chassis}.py"     # the chassis's own finishing touches, if written
    extra = ["--finish", str(finish)] if finish.exists() else []
    blender(str(src), "-P", str(HERE / "bl_polish.py"), "--", "--out", str(dest), "--profile", json.dumps(prof), *extra)
    print(f"polished {chassis} as {maker}: {dest.relative_to(ROOT) if dest.is_relative_to(ROOT) else dest}")


def export(args):
    """Bake wear into vertex colours and export a .blend to art/models/<chassis>.glb for the
    in-engine 3D view."""
    src = Path(args.blend).resolve()
    dest = ROOT / "art" / "models" / f"{args.chassis}.glb"
    dest.parent.mkdir(parents=True, exist_ok=True)
    blender(str(src), "-P", str(HERE / "bl_export.py"), "--", "--out", str(dest), "--bake", "0" if args.no_bake else "1")
    print(f"exported {dest.relative_to(ROOT)}; run godot --headless --path . --import")


# ---------------------------------------------------------------- archetypes

def archetypes(args):
    import archetypes as lib
    from PIL import ImageDraw
    names = args.names or list(lib.ARCHETYPES)
    bad = [n for n in names if n not in lib.ARCHETYPES]
    if bad:
        raise SystemExit(f"unknown archetype {bad}; have {', '.join(lib.ARCHETYPES)}")
    sheets = []
    for n in names:
        model = lib.ARCHETYPES[n]()
        dest = MODELS / "archetypes" / f"{n}.blend"
        with tempfile.TemporaryDirectory() as td:
            pj = Path(td) / "parts.json"
            pj.write_text(json.dumps(model.spec()))
            blender("-P", str(HERE / "bl_build.py"), "--", "--parts", str(pj), "--out", str(dest))
        if args.build_only:
            continue
        work = OUT / "archetypes" / n
        sheets.append((n, render_blend(dest, n, args.maker, spec_for(args), work, work)))
    if not sheets:
        return
    # one review sheet: every archetype's contact sheet stacked, labelled
    imgs = [(n, Image.open(p).convert("RGBA")) for n, p in sheets]
    W = max(im.width for _, im in imgs)
    H = sum(im.height + 28 for _, im in imgs)
    sheet = Image.new("RGBA", (W, H), (0x1b, 0x1f, 0x26, 255))
    d = ImageDraw.Draw(sheet)
    y = 0
    for n, im in imgs:
        d.text((8, y + 8), n, fill=(232, 228, 214))
        sheet.paste(im, (0, y + 28), im)
        y += im.height + 28
    path = OUT / "archetypes" / "contact.png"
    sheet.save(path)
    print(f"{len(imgs)} archetypes: {path.relative_to(ROOT)}; models in {(MODELS / 'archetypes').relative_to(ROOT)}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("render", help="render a .blend into the engine's mech files")
    r.add_argument("blend")
    r.add_argument("chassis", help="chassis id from content/chassis.json; names the files and picks the maker's livery")
    r.add_argument("--maker", default="", help="livery override: minerva, kestrel, wainwright_sutler")
    r.add_argument("--fill", type=float, default=1.0, help="how much of the combat frame the largest turn fills (default 1.0)")
    r.add_argument("--ppu", type=float, default=0.0, help="force pixels per model unit instead of fitting, for matching sizes across mechs")
    r.add_argument("--install", action="store_true", help="write art/mechs instead of tools/blendforge/out")
    r.set_defaults(func=render)
    e = sub.add_parser("example", help="build a template .blend from a spriter model")
    e.add_argument("model", choices=sorted(spriter.TEMPLATES))
    e.set_defaults(func=example)
    p = sub.add_parser("polish", help="the finish pass: bevels, panels, rivets, track cleats and wheels, chamfered caps; writes <name>_polished.blend")
    p.add_argument("blend")
    p.add_argument("chassis", nargs="?", default="", help="chassis id, for the maker's manner and the chassis kit (default: the file's stem)")
    p.add_argument("--maker", default="", help="override the maker profile: minerva, kestrel, wainwright_sutler, aphelion, arsenal")
    p.add_argument("--out", default="")
    p.add_argument("--strength", type=float, default=0.0, help="override the profile's plate strength (tracks follow at 0.6x)")
    p.set_defaults(func=polish)
    x = sub.add_parser("export", help="export a .blend to art/models/<chassis>.glb for the in-engine 3D view")
    x.add_argument("blend")
    x.add_argument("chassis")
    x.add_argument("--no-bake", action="store_true", help="skip baking occlusion and edge wear into vertex colours")
    x.set_defaults(func=export)
    a = sub.add_parser("archetypes", help="build the starter silhouettes in archetypes.py as .blend files and render a review sheet")
    a.add_argument("names", nargs="*", help="which archetypes; default all")
    a.add_argument("--maker", default="minerva", help="livery for the review renders")
    a.add_argument("--fill", type=float, default=1.0)
    a.add_argument("--ppu", type=float, default=0.0)
    a.add_argument("--build-only", action="store_true", help="write the .blend files without rendering")
    a.set_defaults(func=archetypes)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())

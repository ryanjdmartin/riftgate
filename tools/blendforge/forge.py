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
+y, any scale; materials named by role (steel, steel_dark, house, glass, amber, rubber, bore,
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
            return e.get("maker", "halvard")
    return "halvard"


# ---------------------------------------------------------------- example

def example(args):
    model = spriter.MODELS[args.model]()
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


def ramp_for(material, maker):
    """The spriter's four tones for a role, or four tones built from the author's colour."""
    if material["role"]:
        return [spriter.hex_to_rgb(h) for h in spriter.material_ramp(material["role"], maker)]
    c = np.array(material["colour"], dtype=float) ** (1 / 2.2)   # linear to display
    return [tuple(int(v) for v in np.clip(c * f * 255, 0, 255)) for f in (0.38, 0.6, 0.82, 1.0)]


def shade(nrm, aux, yaw, materials, maker, meta):
    """Colour every sample the spriter's way: normal against the fixed light, four tones,
    top faces bumped a tone. Returns colours (h, w, 4), normals in the spriter's world,
    depth in units, material index, coverage."""
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
    colour, n_w, depth, idx, cover = shade(nrm, aux, view["yaw"], meta["materials"], maker, meta)
    k = view["supersample"]
    small = spriter._mode_downsample(colour, k)
    if view["detail"]:   # combat scale draws creases; map tokens are too small for them
        n1, d1, i1 = downsample_fields(n_w, depth, idx, cover, k)
        ramps = {m["index"]: ramp_for(m, maker) for m in meta["materials"]}
        small = crease(small, n1, d1, i1, ramps)
    small = spriter._outline(small)
    return Image.fromarray(small, "RGBA")


def render(args):
    blend = Path(args.blend).resolve()
    if not blend.exists():
        raise SystemExit(f"no such file {blend}")
    maker = maker_of(args.chassis, args.maker)
    spec = spec_for(args)
    passes = OUT / args.chassis / "passes"
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
    out_dir = MECH_ART if args.install else OUT / args.chassis
    path = spriter.write_sheets(args.chassis, combat, maps, str(out_dir), contact_only=False)
    print(f"{args.chassis}: {Path(path).relative_to(ROOT)}" + ("" if args.install else "  (add --install to write art/mechs)"))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("render", help="render a .blend into the engine's mech files")
    r.add_argument("blend")
    r.add_argument("chassis", help="chassis id from content/chassis.json; names the files and picks the house colour")
    r.add_argument("--maker", default="", help="house colour override: halvard, kestrel, orrin_pike")
    r.add_argument("--fill", type=float, default=1.0, help="how much of the combat frame the largest turn fills (default 1.0)")
    r.add_argument("--ppu", type=float, default=0.0, help="force pixels per model unit instead of fitting, for matching sizes across mechs")
    r.add_argument("--install", action="store_true", help="write art/mechs instead of tools/blendforge/out")
    r.set_defaults(func=render)
    e = sub.add_parser("example", help="build a template .blend from a spriter model")
    e.add_argument("model", choices=sorted(spriter.MODELS))
    e.set_defaults(func=example)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())

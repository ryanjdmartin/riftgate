#!/usr/bin/env python3
"""Riftgate spriter: renders mechs built from primitives into pixel-art sprite sheets.

A mech is a list of boxes and cylinders in "mech space": x right, y forward (the way the
mech faces), z up, units are pixels at combat scale. The renderer casts one orthographic ray
per output pixel, shades by surface normal with a discrete tone ramp per material, quantises
to the palette, and adds a one-pixel outline. Facing is a yaw of the model; scale is pixels
per unit. So one model gives every facing at every scale, and animation is moving parts.

Usage:
    python spriter.py bulwark --out ../../art/mechs        # sheets + a contact sheet
    python spriter.py bulwark --contact-only               # just the contact sheet to look at
"""
from __future__ import annotations

import argparse
import math
import os
import sys
from dataclasses import dataclass, field

import numpy as np
from PIL import Image

# ------------------------------------------------------------------ palette
# Tone index 0 is darkest, 3 lightest. Materials map normal-light angle to a tone.
STEEL = ["#2b3038", "#4a525e", "#737d8a", "#a3acb6"]
STEEL_DARK = ["#1f2329", "#2b3038", "#4a525e", "#737d8a"]
RUBBER = ["#16181c", "#22262c", "#35393f", "#454a51"]
GLASS = ["#1c6f8a", "#2fa7c9", "#6fe3ff", "#c8f6ff"]
AMBER = ["#7a5217", "#a8741f", "#e8a93a", "#ffd27a"]
HOT = ["#7a2018", "#b0342a", "#e0473a", "#ff8a6a"]
BORE = ["#0b0d10", "#0b0d10", "#14171c", "#1f2329"]
WHITE = ["#8f8a7a", "#a9a291", "#d8d2c2", "#f0ebdc"]

HOUSE = {
    "halvard": ["#3a0f16", "#5a1620", "#8a2430", "#b8303f"],
    "kestrel": ["#132148", "#1c3270", "#2d4fa8", "#4a74d8"],
    "orrin_pike": WHITE,
}
OUTLINE = "#1a1d23"


def hex_to_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


# ------------------------------------------------------------------ primitives
@dataclass
class Box:
    lo: tuple[float, float, float]
    hi: tuple[float, float, float]
    material: str
    detail: bool = False   # skipped at map scale


@dataclass
class Cyl:
    axis: str            # "x", "y" or "z"
    center: tuple[float, float, float]
    radius: float
    length: float
    material: str
    detail: bool = False


@dataclass
class Model:
    name: str
    maker: str
    parts: list = field(default_factory=list)
    combat_size: tuple[int, int] = (80, 96)   # foe pixel density, wider than the elite frame: a turned walker is wide and low
    combat_baseline: float = 6.0

    def box(self, x0, x1, y0, y1, z0, z1, material, detail=False):
        self.parts.append(Box((min(x0, x1), min(y0, y1), min(z0, z1)),
                              (max(x0, x1), max(y0, y1), max(z0, z1)), material, detail))

    def cyl(self, axis, cx, cy, cz, radius, length, material, detail=False):
        self.parts.append(Cyl(axis, (cx, cy, cz), radius, length, material, detail))

    def mirror_x(self, fn):
        """Run fn(sign) for both sides."""
        fn(-1.0)
        fn(1.0)

    def lift(self, dz: float):
        """Raise every part so far by dz (hovering units)."""
        for p in self.parts:
            if isinstance(p, Box):
                p.lo = (p.lo[0], p.lo[1], p.lo[2] + dz)
                p.hi = (p.hi[0], p.hi[1], p.hi[2] + dz)
            else:
                p.center = (p.center[0], p.center[1], p.center[2] + dz)


# ------------------------------------------------------------------ intersection (vectorised)
def intersect_box(o, d, box: Box):
    lo = np.array(box.lo)
    hi = np.array(box.hi)
    inv = 1.0 / np.where(np.abs(d) < 1e-9, 1e-9, d)
    t0 = (lo - o) * inv
    t1 = (hi - o) * inv
    tmin = np.minimum(t0, t1)
    tmax = np.maximum(t0, t1)
    t_in = tmin.max(axis=1)
    t_out = tmax.min(axis=1)
    hit = (t_in <= t_out) & (t_out > 0)
    t = np.where(hit, t_in, np.inf)
    # normal: the axis whose slab produced t_in
    axis = tmin.argmax(axis=1)
    n = np.zeros_like(o)
    rows = np.arange(o.shape[0])
    n[rows, axis] = -np.sign(d[rows, axis])
    return t, n


def intersect_cyl(o, d, cyl: Cyl):
    ai = "xyz".index(cyl.axis)
    p = [i for i in range(3) if i != ai]
    c = np.array(cyl.center)
    oc = o - c
    a = d[:, p[0]] ** 2 + d[:, p[1]] ** 2
    b = 2.0 * (oc[:, p[0]] * d[:, p[0]] + oc[:, p[1]] * d[:, p[1]])
    cc = oc[:, p[0]] ** 2 + oc[:, p[1]] ** 2 - cyl.radius ** 2
    disc = b * b - 4 * a * cc
    ok = (disc >= 0) & (a > 1e-12)
    sq = np.sqrt(np.where(ok, disc, 0.0))
    a_safe = np.where(a > 1e-12, a, 1.0)
    t_c_in = np.where(ok, (-b - sq) / (2 * a_safe), np.inf)
    t_c_out = np.where(ok, (-b + sq) / (2 * a_safe), -np.inf)
    # caps: slab along the axis
    half = cyl.length / 2.0
    da = np.where(np.abs(d[:, ai]) < 1e-9, 1e-9, d[:, ai])
    ta0 = (c[ai] - half - o[:, ai]) / da
    ta1 = (c[ai] + half - o[:, ai]) / da
    t_a_in = np.minimum(ta0, ta1)
    t_a_out = np.maximum(ta0, ta1)
    t_in = np.maximum(t_c_in, t_a_in)
    t_out = np.minimum(t_c_out, t_a_out)
    hit = ok & (t_in <= t_out) & (t_out > 0)
    t = np.where(hit, t_in, np.inf)
    n = np.zeros_like(o)
    cap = t_a_in >= t_c_in
    hitp = o + d * t[:, None]
    # radial normal
    radial = np.zeros_like(o)
    radial[:, p[0]] = hitp[:, p[0]] - c[p[0]]
    radial[:, p[1]] = hitp[:, p[1]] - c[p[1]]
    norm = np.linalg.norm(radial, axis=1, keepdims=True)
    radial = radial / np.where(norm < 1e-9, 1.0, norm)
    n[:] = radial
    n[cap, :] = 0.0
    n[cap, ai] = -np.sign(d[cap, ai])
    return t, n


# ------------------------------------------------------------------ rendering
def rot_z(theta_deg: float):
    t = math.radians(theta_deg)
    c, s = math.cos(t), math.sin(t)
    return np.array([[c, -s, 0.0], [s, c, 0.0], [0.0, 0.0, 1.0]])


def render(model: Model, yaw: float, pitch: float, ppu: float, width: int, height: int,
           baseline: float = 0.0, light=(-0.45, -0.55, 0.7), detail: bool = True,
           crease_depth: float = 3.0, supersample: int = 1) -> Image.Image:
    """Orthographic render. yaw rotates the model about z (0 = facing away from the camera,
    180 = facing the camera). pitch is the camera's downward tilt in degrees. ppu is pixels per
    model unit. baseline is the screen-space height (in units) of the model's z=0 plane above
    the bottom edge of the image. detail=False drops parts flagged as detail (map scale).
    crease_depth is the depth step (in units) between neighbours that draws a crease line.
    supersample > 1 renders that many times larger, then keeps the most common colour of each
    block (majority vote, so thin slivers vanish instead of sparkling); creases are skipped."""
    if supersample > 1:
        big = _raster(model, yaw, pitch, ppu * supersample, width * supersample,
                      height * supersample, baseline, light, detail, crease=False)
        small = _mode_downsample(np.asarray(big), supersample)
        return Image.fromarray(_outline(small), "RGBA")
    img = _raster(model, yaw, pitch, ppu, width, height, baseline, light, detail, True, crease_depth)
    return Image.fromarray(_outline(np.asarray(img)), "RGBA")


def render_fit(model: Model, yaw: float, width: int, height: int, ppu: float,
               baseline: float = 0.0, pad: int = 24, **kw) -> Image.Image:
    """render() on a canvas padded on every side, then crop back to the frame so the drawing
    is never clipped: a turned model projects wider and lower than its head-on view, and a
    fixed baseline cut the tracks off the three-quarter Bulwark. The crop keeps the model's
    own baseline (so feet and hovering stay where the model put them) unless the drawing
    would spill out, then shifts just enough, and it centres the drawing horizontally."""
    big = render(model, yaw, ppu=ppu, width=width + 2 * pad, height=height + 2 * pad,
                 baseline=baseline + pad / ppu, **kw)
    arr = np.asarray(big)
    ys, xs = np.where(arr[:, :, 3] > 0)
    if ys.size:
        # A model too big for the frame at this scale (a wide airframe turned side-on) is
        # rendered again a little smaller rather than clipped.
        bw, bh = xs.max() - xs.min() + 3, ys.max() - ys.min() + 3
        if bw > width or bh > height:
            shrink = min(width / bw, height / bh)
            return render_fit(model, yaw, width, height, ppu * shrink, baseline, pad, **kw)
    ox, oy = pad, pad
    if ys.size:
        x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
        ox = int(round((x0 + x1 + 1) / 2.0 - width / 2.0))
        if y1 > oy + height - 2:
            oy = y1 - (height - 2)
        if y0 < oy + 1:
            oy = max(y0 - 1, 0)
        ox = max(0, min(ox, arr.shape[1] - width))
        oy = max(0, min(oy, arr.shape[0] - height))
    return Image.fromarray(arr[oy:oy + height, ox:ox + width].copy(), "RGBA")


def _mode_downsample(img: np.ndarray, k: int) -> np.ndarray:
    h, w = img.shape[0] // k, img.shape[1] // k
    out = np.zeros((h, w, 4), dtype=np.uint8)
    blocks = img[: h * k, : w * k].reshape(h, k, w, k, 4).transpose(0, 2, 1, 3, 4).reshape(h, w, k * k, 4)
    for y in range(h):
        for x in range(w):
            px = blocks[y, x]
            opaque = px[px[:, 3] > 0]
            if opaque.shape[0] * 2 < k * k:      # mostly empty: stays transparent
                continue
            keys, counts = np.unique(opaque, axis=0, return_counts=True)
            out[y, x] = keys[counts.argmax()]
    return out


def _outline(img: np.ndarray) -> np.ndarray:
    img = img.copy()
    height, width = img.shape[:2]
    mask2 = img[:, :, 3] > 0
    out = np.zeros_like(mask2)
    for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0)):
        shifted = np.zeros_like(mask2)
        ys = slice(max(dy, 0), height + min(dy, 0))
        yd = slice(max(-dy, 0), height + min(-dy, 0))
        xs = slice(max(dx, 0), width + min(dx, 0))
        xd = slice(max(-dx, 0), width + min(-dx, 0))
        shifted[yd, xd] = mask2[ys, xs]
        out |= shifted & ~mask2
    img[out, :3] = hex_to_rgb(OUTLINE)
    img[out, 3] = 255
    return img


def _raster(model: Model, yaw: float, pitch: float, ppu: float, width: int, height: int,
            baseline: float, light, detail: bool, crease: bool, crease_depth: float = 3.0) -> Image.Image:
    parts = [p for p in model.parts if detail or not p.detail]
    if not parts:
        return Image.new("RGBA", (width, height), (0, 0, 0, 0))
    ph = math.radians(pitch)
    fwd = np.array([0.0, math.cos(ph), -math.sin(ph)])     # camera looks along this
    up = np.array([0.0, math.sin(ph), math.cos(ph)])
    right = np.array([1.0, 0.0, 0.0])
    R = rot_z(yaw)          # model -> world
    Rinv = R.T              # world -> model

    px = np.arange(width)
    py = np.arange(height)
    gx, gy = np.meshgrid(px, py)
    sx = (gx.ravel() - width / 2.0 + 0.5) / ppu
    sy = (height - gy.ravel() - 0.5) / ppu - baseline
    origins_w = sx[:, None] * right[None, :] + sy[:, None] * up[None, :] - 400.0 * fwd[None, :]
    dirs_w = np.repeat(fwd[None, :], origins_w.shape[0], axis=0)
    o = origins_w @ Rinv.T
    d = dirs_w @ Rinv.T

    best_t = np.full(o.shape[0], np.inf)
    best_n = np.zeros_like(o)
    best_m = np.full(o.shape[0], -1, dtype=int)
    mats: list[str] = []
    flat = np.zeros(len(parts), dtype=bool)
    with np.errstate(invalid="ignore", divide="ignore"):
        for i, part in enumerate(parts):
            mats.append(part.material)
            flat[i] = isinstance(part, Box)
            t, n = intersect_box(o, d, part) if isinstance(part, Box) else intersect_cyl(o, d, part)
            closer = t < best_t
            best_t = np.where(closer, t, best_t)
            best_n[closer] = n[closer]
            best_m[closer] = i

    # shading: normal in world space against a fixed light
    L = np.array(light, dtype=float)
    L = L / np.linalg.norm(L)
    n_w = best_n @ R.T
    ndl = (n_w @ L)
    tone = np.select([ndl > 0.62, ndl > 0.22, ndl > -0.25], [3, 2, 1], default=0)
    # top faces catch the light: bump one tone
    tone = np.where((n_w[:, 2] > 0.85) & (tone < 3), tone + 1, tone)

    mask = np.isfinite(best_t)
    img = np.zeros((height * width, 4), dtype=np.uint8)
    for i, mat in enumerate(mats):
        ramp = material_ramp(mat, model.maker)
        sel = mask & (best_m == i)
        if not sel.any():
            continue
        for tn in range(4):
            s2 = sel & (tone == tn)
            if s2.any():
                img[s2, :3] = hex_to_rgb(ramp[tn])
                img[s2, 3] = 255

    # crease lines: neighbouring pixels whose normals disagree strongly get the darkest tone
    img = img.reshape(height, width, 4)
    mask2 = mask.reshape(height, width)
    nw = n_w.reshape(height, width, 3)
    depth = best_t.reshape(height, width)
    mats_arr = best_m.reshape(height, width)
    if not crease:
        return Image.fromarray(img, "RGBA")
    crease_px = np.zeros_like(mask2)
    flat_px = np.zeros_like(mask2)
    flat_px[mask2] = flat[mats_arr[mask2]]
    for dy, dx in ((0, 1), (1, 0)):
        a = mask2[dy:, dx:] & mask2[: height - dy, : width - dx]
        both_flat = flat_px[dy:, dx:] & flat_px[: height - dy, : width - dx]
        dot = (nw[dy:, dx:] * nw[: height - dy, : width - dx]).sum(axis=2)
        with np.errstate(invalid="ignore"):
            dz = np.abs(depth[dy:, dx:] - depth[: height - dy, : width - dx])
        far = a & ((both_flat & (dot < 0.15)) | (dz > crease_depth))
        # darken the pixel that is farther away (behind)
        behind_first = depth[dy:, dx:] > depth[: height - dy, : width - dx]
        c1 = np.zeros_like(mask2)
        c1[dy:, dx:] = far & behind_first
        c2 = np.zeros_like(mask2)
        c2[: height - dy, : width - dx] = far & ~behind_first
        crease_px |= c1 | c2
    for i, mat in enumerate(mats):
        ramp = material_ramp(mat, model.maker)
        sel = crease_px & (mats_arr == i)
        img[sel, :3] = hex_to_rgb(ramp[0])
    return Image.fromarray(img, "RGBA")


def material_ramp(mat: str, maker: str) -> list[str]:
    if mat == "house":
        return HOUSE[maker]
    return {
        "steel": STEEL, "steel_dark": STEEL_DARK, "rubber": RUBBER, "glass": GLASS,
        "amber": AMBER, "hot": HOT, "bore": BORE, "white": WHITE,
    }[mat]


# ------------------------------------------------------------------ models
def bulwark() -> Model:
    """Halvard Bulwark: a tank with fists. Units are combat-scale pixels; faces +y."""
    m = Model("bulwark", "halvard")
    # tracks: rubber runs with steel skirts
    def track(s):
        x0, x1 = s * 12, s * 21
        m.box(x0, x1, -17, 17, 0, 9, "rubber")
        m.box(x0, x1, -17, 17, 9, 12, "steel_dark")          # track skirt
        m.cyl("x", s * 16.5, 12, 4.5, 4.5, 9.5, "steel_dark")  # drive sprocket
        m.cyl("x", s * 16.5, -12, 4.5, 4.5, 9.5, "steel_dark")
    m.mirror_x(track)
    # hull and glacis
    m.box(-12, 12, -15, 14, 5, 19, "steel")
    m.box(-11, 11, 12, 16, 8, 20, "house")                   # glacis plate, house colour
    m.box(-12, 12, -15, -12, 19, 22, "steel_dark")           # rear deck lip
    # superstructure with a bevel (stacked, stepping in)
    m.box(-9, 9, -8, 7, 19, 30, "steel")
    m.box(-7, 7, -7, 8, 30, 33, "steel")
    m.box(-8, 8, 6, 9, 20, 29, "house")                      # front plate
    m.box(-5, 5, 8, 10, 23, 28, "glass")                     # cockpit slit
    m.box(-0.6, 0.6, 9.5, 10.5, 23, 28, "steel_dark", detail=True)  # pane divider
    m.box(-3, 3, 8.5, 9.5, 20.5, 22, "amber", detail=True)   # chevron marking
    # sensor mast and searchlight
    m.box(-2, 2, -5, -1, 33, 40, "steel_dark")
    m.box(-2.5, 2.5, -5.5, -0.5, 40, 42, "amber")
    m.box(-15, -8, -4, 3, 28, 34, "steel")                   # searchlight housing, left
    m.cyl("y", -11.5, 3.5, 31, 2.5, 2, "amber", detail=True)  # lens
    # shoulder slug cannon, right: housing, short fat barrel, brake, bore
    m.box(5, 16, -8, 8, 27, 38, "steel")
    m.box(6, 15, 6, 9, 28, 37, "house")                      # housing face plate
    m.cyl("y", 10.5, 14, 32.5, 4.5, 12, "steel_dark")        # barrel y 8..20
    m.box(6, 15, 19, 23, 28, 37, "steel")                    # muzzle brake block
    m.box(6.5, 8, 19.5, 22.5, 29, 36, "bore", detail=True)   # brake slots
    m.box(13, 14.5, 19.5, 22.5, 29, 36, "bore", detail=True)
    m.cyl("y", 10.5, 23.6, 32.5, 2.4, 1.2, "bore", detail=True)  # the bore
    m.box(7, 14, -6, 6, 24, 27, "rubber")                    # ammo feed belt under the housing
    # arms: shoulder block on the hull side, forearm reaching forward, fist at the end
    def arm(s):
        m.box(s * 13, s * 20, 2, 10, 12, 24, "steel")        # shoulder block
        m.cyl("x", s * 16.5, 6, 18, 2.5, 8, "steel_dark", detail=True)  # hydraulic pin
        m.box(s * 14, s * 21, 9, 21, 9, 17, "house")          # forearm
        m.box(s * 15, s * 20, 10, 20, 17, 18.5, "steel_dark", detail=True)  # forearm top rail
        m.box(s * 13.5, s * 21.5, 20, 27, 6, 15, "steel_dark")  # fist
        m.box(s * 14, s * 21, 26.5, 28, 9, 13, "steel", detail=True)  # knuckle plate
        m.box(s * 13, s * 14.5, 21, 25, 7, 11, "steel", detail=True)  # thumb
    m.mirror_x(arm)
    return m


def sentinel() -> Model:
    """Orrin & Pike Sentinel: a quadruped walker with two shoulder pods and a chin gun."""
    m = Model("sentinel", "orrin_pike")
    # body
    m.box(-11, 11, -12, 12, 16, 30, "steel")
    m.box(-9, 9, -10, 10, 30, 32, "house")                   # top plate
    m.box(-9, 9, 12, 14, 18, 28, "house")                    # glacis
    m.box(-4, 4, 14, 15, 21, 26, "glass")                    # cockpit
    m.box(-0.6, 0.6, 14.5, 15.5, 21, 26, "steel_dark", detail=True)
    m.box(-9, 9, -12, -10, 22, 30, "steel_dark")             # rear radiator
    m.cyl("y", 0, 16, 19, 1.6, 8, "steel_dark", detail=True)  # chin gun
    m.box(-3, 3, -8, -4, 32, 36, "steel_dark")               # sensor head
    m.box(-2, 2, -7, -5, 36, 37.5, "amber", detail=True)
    def pod(s):
        m.box(s * 11, s * 19, -6, 4, 22, 32, "steel")        # shoulder pod
        m.box(s * 12, s * 18, 4, 5.5, 23, 31, "house")        # pod face
        for gx in (13.5, 16.5):
            for gz in (24.5, 28.5):
                m.box(s * (gx - 0.9), s * (gx + 0.9), 5.6, 6.2, gz - 0.9, gz + 0.9, "bore", detail=True)
        m.box(s * 12, s * 18, -5, 3, 32, 33.5, "house", detail=True)  # pod lid
    m.mirror_x(pod)
    def leg(sx, sy):
        m.box(sx * 11, sx * 15, sy * 4, sy * 10, 14, 22, "steel_dark")   # hip
        m.box(sx * 14, sx * 19, sy * 5, sy * 10, 8, 18, "house")         # upper leg
        m.box(sx * 17, sx * 21, sy * 4, sy * 11, 0, 10, "steel_dark")    # lower leg
        m.box(sx * 16, sx * 21.5, sy * 3, sy * 11.5, 0, 2.5, "rubber")   # foot pad
        m.cyl("x", sx * 16.5, sy * 7.5, 18, 2.0, 6, "steel", detail=True)  # hip pin
    for sx in (-1, 1):
        for sy in (-1, 1):
            leg(sx, sy)
    return m


def raptor() -> Model:
    """Kestrel Raptor: an interceptor airframe hovering on hot engines. Built at ground level
    and lifted at the end so it floats in the standard frame."""
    m = Model("raptor", "kestrel")
    # fuselage and nose
    m.box(-4, 4, -16, 10, 10, 17, "steel")
    m.box(-3, 3, 10, 16, 11, 16, "steel")
    m.box(-2, 2, 16, 21, 12, 15, "steel_dark")               # nose cone
    m.box(-3, 3, 2, 9, 17, 20, "glass")                      # canopy
    m.box(-0.6, 0.6, 2, 9, 17.5, 20.5, "steel_dark", detail=True)  # canopy spine
    m.box(-4, 4, -8, 2, 17, 18.5, "house")                   # spine plate behind the canopy
    # swept wing as three stepped slabs
    m.box(-20, 20, -9, -3, 12, 14, "house")
    m.box(-15, 15, -3, 1, 12, 14, "house")
    m.box(-9, 9, 1, 4, 12, 13.5, "house")
    m.box(-20, 20, -9, -8, 14, 14.8, "steel_dark", detail=True)  # trailing edge line
    # wingtip missiles and nav lights
    def tip(s):
        m.cyl("y", s * 18.5, -5, 14.5, 1.8, 10, "steel_dark")
        m.box(s * 19.5, s * 20.5, -5, -4, 14, 15, "amber", detail=True)
    m.mirror_x(tip)
    # engines with hot exhaust
    def engine(s):
        m.cyl("y", s * 7, -12, 13, 3.5, 12, "steel_dark")
        m.cyl("y", s * 7, -18.5, 13, 2.6, 1.6, "hot")
        m.box(s * 5, s * 9, -6, -4, 16.5, 18, "steel", detail=True)  # intake lip
    m.mirror_x(engine)
    # tail fin and underslung gun
    m.box(-1, 1, -17, -9, 17, 25, "house")
    m.box(-1.2, 1.2, -17, -14, 24, 25.5, "amber", detail=True)
    m.cyl("y", 0, 4, 9.5, 1.5, 14, "steel_dark")
    m.cyl("y", 0, 11.3, 9.5, 0.9, 0.8, "bore", detail=True)
    m.lift(8.0)
    return m


MODELS = {"bulwark": bulwark, "sentinel": sentinel, "raptor": raptor}


# ------------------------------------------------------------------ sheets
# Combat sprites are isometric in spirit: the camera 30 degrees down and the model turned 45
# degrees off head-on, so every part shows a top, a lit side and a shaded side. 1.33 pixels
# per unit fills the 64x96 frame with the same models that filled 48x64.
COMBAT = dict(pitch=30.0, ppu=1.8)   # walkers fill the 96-tall frame; render_fit shrinks anything that overflows
COMBAT_YAWS = {"front": 180.0, "front_left": 135.0, "front_right": 225.0}
MAP = dict(pitch=42.0, ppu=0.42, width=24, height=28, baseline=2.0, detail=False, supersample=3)
# Pointy-top hex facings in the sim's Hex.DIRECTIONS order: E, NE, NW, W, SW, SE. Yaw 0 faces
# up the screen (north), positive yaw turns anticlockwise seen from above.
MAP_YAWS = {"e": 270.0, "ne": 330.0, "nw": 30.0, "w": 90.0, "sw": 150.0, "se": 210.0}


def build_sheets(model: Model, out_dir: str, contact_only: bool) -> str:
    cw_, ch_ = model.combat_size
    combat = {k: render_fit(model, yaw, width=cw_, height=ch_, baseline=model.combat_baseline, **COMBAT)
              for k, yaw in COMBAT_YAWS.items()}
    maps = {k: render_fit(model, yaw, **MAP) for k, yaw in MAP_YAWS.items()}
    return write_sheets(model.name, combat, maps, out_dir, contact_only)


def write_sheets(name: str, combat: dict, maps: dict, out_dir: str, contact_only: bool) -> str:
    """Write the engine's files for one mech from rendered frames: the combat turns, the loose
    map facings, the map strip, and a 4x contact sheet. Shared with tools/blendforge, which
    renders the frames from a .blend instead of from primitives, so both produce the same
    files and the engine cannot tell them apart."""
    os.makedirs(out_dir, exist_ok=True)
    ch_ = max(im.height for im in combat.values())
    if not contact_only:
        for k, im in combat.items():
            im.save(os.path.join(out_dir, f"{name}_combat_{k}.png"))
        for k, im in maps.items():
            im.save(os.path.join(out_dir, f"{name}_map_{k}.png"))
        # a strip of the six map facings, in order, for the engine to slice
        strip = Image.new("RGBA", (MAP["width"] * 6, MAP["height"]), (0, 0, 0, 0))
        for i, k in enumerate(MAP_YAWS):
            strip.paste(maps[k], (i * MAP["width"], 0))
        strip.save(os.path.join(out_dir, f"{name}_map_strip.png"))
    # contact sheet at 4x for humans
    z = 4
    cw = sum(im.width for im in combat.values()) + 8 * (len(combat) + 1)
    mw = sum(im.width for im in maps.values()) + 8 * (len(maps) + 1)
    W = max(cw, mw)
    H = ch_ + MAP["height"] + 24
    sheet = Image.new("RGBA", (W, H), (0x1b, 0x1f, 0x26, 255))
    x = 8
    for im in combat.values():
        sheet.paste(im, (x, 8), im)
        x += im.width + 8
    x = 8
    for im in maps.values():
        sheet.paste(im, (x, ch_ + 16), im)
        x += im.width + 8
    sheet = sheet.resize((W * z, H * z), Image.NEAREST)
    path = os.path.join(out_dir, f"{name}_contact.png")
    sheet.save(path)
    return path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("model", nargs="*", help="model names, or nothing for every model")
    ap.add_argument("--out", default=os.path.join(os.path.dirname(__file__), "..", "..", "art", "mechs"))
    ap.add_argument("--contact-only", action="store_true")
    args = ap.parse_args()
    names = args.model or sorted(MODELS)
    for name in names:
        if name not in MODELS:
            print(f"unknown model {name!r}; have {', '.join(sorted(MODELS))}", file=sys.stderr)
            return 2
        path = build_sheets(MODELS[name](), os.path.abspath(args.out), args.contact_only)
        print(f"{name}: {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

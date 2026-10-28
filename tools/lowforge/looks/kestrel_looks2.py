"""Look tests for the Kestrel line's third round (Ryan, 26 October, on the second: the jaeger
Skua "pretty cool", another crack at it and other options; the starfighter Needletail good, riff
on it; a stab at the Puffin and the Storm Petrel trading bases; the Giant Petrel off the Lun,
"something uniquely ours and very Kestrel"). Not content and not in models_low.py: built only by
build_look.py (docs/looks/kestrel_*.png). x right, y forward, z up, as in models_low.py."""

import math

from mathutils import Matrix, Vector

from bl_low import diamond, hexagon, rect
from kestrel_looks import _canopy, _nt_motion, _nt_wings, _nt_xtail, _top
from models_low import (_beam, _blade_section, _case, _chine_section, _disc, _fin_section, _fuse, _hexr, _hull_section,
                        _missile_face, _oct, _poly, _rings, _sq, _tube, _wing)

KT = "kestrel"


def _rot_z(ring, ang, cx=0.0, cy=0.0):
    """A 3D ring turned `ang` radians about the vertical through (cx, cy)."""
    c, s = math.cos(ang), math.sin(ang)
    out = []
    for (x, y, z) in ring:
        dx, dy = x - cx, y - cy
        out.append((cx + dx * c - dy * s, cy + dx * s + dy * c, z))
    return out


def _lerp_at(table, y):
    """Linear interpolation through a table of (y, *values), y descending."""
    for a, b in zip(table, table[1:]):
        if b[0] <= y <= a[0]:
            t = (a[0] - y) / (a[0] - b[0])
            return [p + (q - p) * t for p, q in zip(a[1:], b[1:])]
    return list(table[0][1:]) if y > table[0][0] else list(table[-1][1:])


# ---------------------------------------------------------------- the Skua, round two

def _skua_body(b, fuse, bill, booster_y, booster_r, cap=True):
    """A jaeger's body: the fuselage, the drooping hooked bill with the dark cap the bird wears,
    the body flowing into one big booster astern. Returns the booster's lit part names."""
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in fuse], "steel.plate", "fuselage")
    b.loft([(y, [(x, z + dz) for (x, z) in _fuse(w, t, bt)]) for (y, w, t, bt, dz) in bill], "steel.plate", "bill")
    yt, wt, tt, bt, dzt = bill[-1]
    b.loft([(yt - 0.5, [(x, z + dzt) for (x, z) in diamond(0.0, 0.0, wt + 0.4, tt + bt + 0.2)]),
            (yt + 6.0, [(x, z + dzt - 1.9) for (x, z) in diamond(0.0, 0.0, 0.4, 0.4)])], "steel.dark", "bill_hook")
    if cap:   # the dark cap: a thin shell over the nose's top, the bill's root to the canopy
        rows = []
        for (y, w, t, bt, dz) in bill[:3]:
            rows.append((y, [(-w * 0.46, dz + t * 0.55), (w * 0.46, dz + t * 0.55), (w * 0.26, dz + t + 0.25), (-w * 0.26, dz + t + 0.25)]))
        b.loft(rows, "steel.dark", "cap")
    y0, w0, t0, b0 = fuse[-1]
    b.loft([(y0, _fuse(w0, t0, b0)), (booster_y + 11.0, _hexr(0.0, 0.3, booster_r))], "steel.plate", "tail_fairing")
    b.prism("y", 0.0, booster_y, 0.3, booster_r, 22.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    b.prism("y", 0.0, booster_y - 10.0, 0.3, booster_r + 0.5, 2.4, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(booster_y - 11.2, _hexr(0.0, 0.3, booster_r + 0.4)), (booster_y - 11.8, _hexr(0.0, 0.3, booster_r - 0.6))], "amber.exhaust", "exhaust")
    return ["booster_ring", "exhaust"]


def _skua_pods(b, px_list, y0, y1, z0, h):
    """The Flechette Pod as twin pods on the spine, honeycomb faces forward, collars lit by the run."""
    for px in px_list:
        b.loft([(y0 - 6.0, rect(px, 1.8, z0 - 0.2, z0 + h * 0.6)), (y0, rect(px, 3.4, z0, z0 + h)), (y1, rect(px, 3.4, z0, z0 + h))], "steel.panel", "flechette_pod")
        _missile_face(b, (px - 1.7, y1 + 0.1, z0), (0.0, 0.0, 1.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), 3.4, "flechette_face")
        for (za, zb) in ((z0 + h - 0.1, z0 + h + 0.4), (z0 - 0.4, z0 + 0.1)):
            b.box(px - 2.1, px + 2.1, y1 - 0.8, y1, za, zb, "amber.ember", "pod_collar")


def _skua_acts(b, wings, sweep, boosters, spread=4.0):
    """The strafing run (the wings swept, the pods firing twice) and the sweep-by-speed gait,
    over whatever joints `wings` names, each to its own `sweep` sign."""
    b.act("strafing_run", 4.4, {w: [(0.3, 0.0), (0.9, s * sweep), (3.0, s * sweep), (3.8, 0.0)] for w, s in wings},
          body=[(0.4, 0.0, 0.0, 0.0), (1.1, 0.0, 10.0, -2.5, 0.0, -9.0, 0.0), (1.9, 0.0, 16.0, -3.5, 0.0, -10.0, 0.0), (2.6, 0.0, 18.0, 1.0, 0.0, 8.0, 0.0),
                (3.3, 0.0, 8.0, 2.0, 0.0, 4.0, 0.0), (4.4, 0.0, 0.0, 0.0)],
          glow=[(["pod_collar"], [(1.2, 0.0), (1.3, 16.0), (1.45, 1.0), (1.6, 16.0), (1.75, 1.0), (2.1, 0.0)]),
                (boosters, [(0.4, 0.0), (0.9, 7.0), (2.6, 7.0), (3.4, 0.0)])])
    glow = {"parts": boosters, "k": 5.0}
    b.gait_option("spread", tracks={w: [(0.0, -s * spread), (1.0, -s * spread)] for w, s in wings}, glow=glow)
    b.gait(tracks={w: [(0.0, s * sweep), (1.0, s * sweep)] for w, s in wings}, glow=glow,
           body_hold=(0.0, 0.0, 0.0, 0.0, -6.0, 0.0), start=("spread", 0.25, 0.85))
    b.move(slide=0.5, bank=44.0, accel=0.7, heft=0.08, oversteer=0.3)


def ktlook_skua_jaeger2(b):
    """The jaeger, second crack: the body longer and slimmer, flowing into its one booster without
    a step; the bill's hook sharper and the dark cap the bird wears over the crown; the arms
    shorter and cranked higher, the hands longer and narrower so the spread wing reads as a
    seabird's and the swept one as a thrown dart; the white flash a bar across the hand's root;
    the streamers longer and finer; the fin lower and raked; the tailplanes a shallow V."""
    FUSE = [(30.0, 7.0, 3.3, 3.3), (18.0, 10.0, 4.4, 4.0), (4.0, 11.4, 4.9, 4.4), (-10.0, 10.8, 4.8, 4.4), (-22.0, 9.4, 4.5, 4.3)]
    BILL = [(30.0, 7.0, 3.3, 3.3, 0.0), (38.0, 5.4, 2.5, 2.5, -0.5), (45.0, 3.6, 1.7, 1.7, -1.4), (51.0, 2.0, 0.9, 0.9, -2.6), (54.5, 0.9, 0.4, 0.4, -3.8)]
    boosters = _skua_body(b, FUSE, BILL, -36.0, 7.0)
    _canopy(b, FUSE + [(-40.0, 8.0, 4.0, 4.0)], [(27.0, 1.0, 0.6), (23.0, 2.5, 2.6), (16.0, 2.9, 3.4), (9.0, 2.5, 2.7), (5.0, 1.3, 1.0)], 16.0)
    for s in (-1.0, 1.0):
        b.loft([(12.0, rect(s * 6.2, 2.2, -2.4, 2.0)), (4.0, rect(s * 6.4, 2.6, -2.6, 2.4))], "steel.dark", "intake_cheek")
        b.box(s * 6.2 - 0.9, s * 6.2 + 0.9, 12.0, 12.4, -2.2, 1.8, "bore.dark", "intake")
    WX, WY, WZ = 17.0, 2.0, 7.8
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 5.0, 4.0, -11.0, 3.4, 1.1), _blade_section(s * 11.0, 7.4, -7.6, 6.2, 0.9),
                   _blade_section(s * (WX + 0.8), 8.6, -4.6, WZ, 0.8)], "livery.livery", "wing_arm")
        b.prism("z", s * WX, WY, WZ, 2.3, 2.6, "steel.dark", 8, "wrist", phase=math.pi / 8)
        with b.joint("wing_" + side, (s * WX, WY, WZ), axis="yaw", limits=(-6.0, 58.0) if s < 0 else (-58.0, 6.0)):
            _rings(b, [_blade_section(s * (WX - 0.4), 8.4, -4.5, WZ, 0.8), _blade_section(s * (WX + 5.0), 7.0, -4.8, WZ - 0.4, 0.7)], "livery.livery", "wing_hand")
            _rings(b, [_blade_section(s * (WX + 5.0), 7.0, -4.8, WZ - 0.4, 0.7), _blade_section(s * (WX + 10.0), 5.4, -5.0, WZ - 0.8, 0.62)], "bone.bone", "wing_flash")
            _rings(b, [_blade_section(s * (WX + 10.0), 5.4, -5.0, WZ - 0.8, 0.62), _blade_section(s * (WX + 24.0), -0.8, -6.4, WZ - 2.2, 0.4),
                       _blade_section(s * (WX + 37.0), -8.4, -9.4, WZ - 3.6, 0.18)], "livery.livery", "wing_hand")
        # The V tailplanes off the fairing, canted up thirty degrees.
        ca = math.radians(30.0)
        _rings(b, [_blade_section(s * 5.0, -30.0, -43.0, 3.6, 0.5), [(s * (5.0 + 14.0 * math.cos(ca)), y, 3.6 + 14.0 * math.sin(ca) + dz) for (y, dz) in ((-45.0, 0.0), (-42.0, 0.25), (-39.0, 0.0), (-42.0, -0.25))]],
               "livery.livery", "stabiliser")
        _rings(b, [[(s * 1.4 - 0.9, -40.0, 7.7), (s * 1.4, -40.0, 8.1), (s * 1.4 + 0.9, -40.0, 7.7), (s * 1.4, -40.0, 7.3)],
                   [(s * 2.4 - 0.7, -56.0, 6.6), (s * 2.4, -56.0, 6.9), (s * 2.4 + 0.7, -56.0, 6.6), (s * 2.4, -56.0, 6.3)],
                   [(s * 3.4 - 0.05, -76.0, 5.8), (s * 3.4, -76.0, 5.85), (s * 3.4 + 0.05, -76.0, 5.8), (s * 3.4, -76.0, 5.75)]], "livery.livery", "streamer")
        b.box(s * 1.4 - 0.6, s * 1.4 + 0.6, -41.0, -31.0, 4.6, 8.0, "steel.plate", "streamer_root")
    _rings(b, [_fin_section(0.0, -14.0, -32.0, 4.6, 0.7), _fin_section(0.0, -29.0, -36.0, 13.0, 0.3)], "livery.livery", "fin")
    _skua_pods(b, [-3.0, 3.0], -10.0, 3.0, 4.4, 3.8)
    for s in (-1.0, 1.0):
        b.box(s * 10.0 - 0.7, s * 10.0 + 0.7, -4.0, 4.0, 1.6, 4.4, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 10.0, 4.0, 1.0), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    b.pad("hp_3", (0.0, -8.0, -4.8), scale=0.5, size=(5.0, 1.4))
    _skua_acts(b, [("wing_l", 1.0), ("wing_r", -1.0)], 52.0, boosters)

ktlook_skua_jaeger2.maker = KT


def ktlook_skua_scissor(b):
    """The scissor: two straight wings stacked on one pivot drum at the centre of mass, each
    slewed the opposite way, so at rest they cross in a wide X from above and on the run both
    slew further until the four arms close up into a narrow dart. Nothing in the roster is an X.
    A jaeger's body and bill under them, one booster, a low fin; the pods ride the drum."""
    FUSE = [(28.0, 6.6, 3.2, 3.0), (16.0, 9.6, 4.2, 3.8), (2.0, 10.6, 4.6, 4.2), (-12.0, 10.0, 4.5, 4.1), (-22.0, 9.0, 4.3, 4.1)]
    BILL = [(28.0, 6.6, 3.2, 3.0, 0.0), (36.0, 5.0, 2.4, 2.3, -0.4), (43.0, 3.3, 1.6, 1.5, -1.2), (48.0, 1.8, 0.8, 0.8, -2.2), (51.0, 0.8, 0.4, 0.4, -3.1)]
    boosters = _skua_body(b, FUSE, BILL, -36.0, 6.8)
    _canopy(b, FUSE + [(-40.0, 8.0, 4.0, 4.0)], [(25.0, 1.0, 0.6), (21.0, 2.4, 2.5), (15.0, 2.8, 3.2), (9.0, 2.4, 2.6), (5.5, 1.3, 1.0)], 15.0)
    PZ, PY, REST = 5.2, -2.0, math.radians(26.0)
    b.prism("z", 0.0, PY, PZ, 5.2, 4.2, "steel.dark", 10, "pivot_drum")
    for (name, z, sgn) in (("wing_u", PZ + 1.6, 1.0), ("wing_d", PZ - 1.4, -1.0)):
        straight = [_blade_section(x, 5.6 - abs(x) * 0.06, -3.2 - abs(x) * 0.04, z, 0.78 - abs(x) * 0.011) for x in (-44.0, -22.0, 0.0, 22.0, 44.0)]
        rings = [_rot_z(r, sgn * REST, 0.0, PY) for r in straight]
        lim = (-6.0, 44.0) if sgn > 0 else (-44.0, 6.0)
        with b.joint(name, (0.0, PY, z), axis="yaw", limits=lim):
            _rings(b, rings, "livery.livery", "wing")
            for x in (-30.0, 30.0):
                band = [_rot_z(_blade_section(xx, 5.6 - abs(xx) * 0.06, -3.2 - abs(xx) * 0.04, z + 0.02, 0.8 - abs(xx) * 0.011), sgn * REST, 0.0, PY) for xx in (x - 3.0, x + 3.0)]
                _rings(b, band, "bone.bone", "wing_band")
    _skua_pods(b, [-7.6, 7.6], -6.0, 5.0, 2.8, 3.2)
    _rings(b, [_fin_section(0.0, -16.0, -33.0, 4.4, 0.7), _fin_section(0.0, -30.0, -37.0, 12.0, 0.3)], "livery.livery", "fin")
    for s in (-1.0, 1.0):
        _rings(b, [_blade_section(s * 6.0, -33.0, -44.0, 1.6, 0.5), _blade_section(s * 15.0, -41.0, -46.0, 1.2, 0.25)], "livery.livery", "stabiliser")
        b.box(s * 5.4 - 0.7, s * 5.4 + 0.7, 6.0, 16.0, -4.0, -2.2, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 5.4, 15.0, -4.6), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    b.pad("hp_3", (0.0, -12.0, -4.6), scale=0.5, size=(5.0, 1.4))
    _skua_acts(b, [("wing_u", 1.0), ("wing_d", -1.0)], 38.0, boosters, spread=5.0)

ktlook_skua_scissor.maker = KT


def ktlook_skua_droptip(b):
    """The drop-tip: a flat dart of a body with a cranked wing whose outer third hinges down for
    the run (joints tip_l, tip_r), so from above the span shrinks to a slim arrow and the dropped
    tips become fences at its sides; spread again, a broad dart. The swing is vertical where the
    others' is flat, and the rest pose is unlike the Buzzard's plank by its crank and its notch.
    One booster, buried; the bill and cap; twin pods on the spine."""
    FUSE = [(30.0, 8.0, 3.0, 2.6), (18.0, 13.0, 3.8, 3.2), (4.0, 16.0, 4.2, 3.4), (-10.0, 15.0, 4.0, 3.4), (-22.0, 12.0, 3.8, 3.4)]
    BILL = [(30.0, 8.0, 3.0, 2.6, 0.0), (38.0, 5.8, 2.2, 2.0, -0.4), (45.0, 3.6, 1.5, 1.4, -1.2), (50.0, 1.8, 0.8, 0.8, -2.2), (53.0, 0.8, 0.4, 0.4, -3.0)]
    boosters = _skua_body(b, FUSE, BILL, -36.0, 6.6)
    _canopy(b, FUSE + [(-40.0, 8.0, 4.0, 4.0)], [(26.0, 1.0, 0.6), (22.0, 2.5, 2.5), (15.0, 2.9, 3.2), (8.0, 2.5, 2.6), (4.0, 1.3, 1.0)], 15.0)
    HX = 20.0
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 7.0, 10.0, -16.0, 1.2, 1.3), _blade_section(s * HX, 0.0, -14.0, 1.2, 0.8)], "livery.livery", "wing_inner")
        b.prism("y", s * HX, -7.0, 1.2, 1.1, 14.0, "steel.dark", 6, "tip_hinge")
        with b.joint("tip_" + side, (s * HX, -7.0, 1.2), axis="roll", limits=(0.0, 70.0) if s < 0 else (-70.0, 0.0)):
            _rings(b, [_blade_section(s * (HX + 0.3), 0.0, -14.0, 1.2, 0.8), _blade_section(s * (HX + 9.0), -3.0, -13.0, 1.2, 0.6),
                       _blade_section(s * (HX + 19.0), -8.6, -13.4, 1.2, 0.25)], "livery.livery", "wing_tip")
            _rings(b, [_blade_section(s * (HX + 2.0), -0.8, -13.8, 1.22, 0.8), _blade_section(s * (HX + 6.0), -2.0, -13.4, 1.22, 0.7)], "bone.bone", "wing_flash")
        _rings(b, [_blade_section(s * 5.0, -30.0, -42.0, 1.6, 0.5), _blade_section(s * 13.0, -38.0, -45.0, 1.2, 0.25)], "livery.livery", "stabiliser")
        b.box(s * 11.0 - 0.7, s * 11.0 + 0.7, -2.0, 8.0, -1.6, 0.4, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 11.0, 8.0, -2.2), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    _rings(b, [_fin_section(0.0, -16.0, -33.0, 4.0, 0.7), _fin_section(0.0, -30.0, -37.0, 12.0, 0.3)], "livery.livery", "fin")
    _skua_pods(b, [-3.2, 3.2], -12.0, 2.0, 4.0, 3.4)
    b.pad("hp_3", (0.0, -10.0, -4.0), scale=0.5, size=(5.0, 1.4))
    _skua_acts(b, [("tip_l", 1.0), ("tip_r", -1.0)], 62.0, boosters, spread=0.0)

ktlook_skua_droptip.maker = KT


# ---------------------------------------------------------------- the Needletail, starfighter riffs

def _needle_nose(b, y0, y1, w0, collar_y, tip=True):
    """A long needle nose from the body's front section at `y0` to `y1`, a cobalt collar at
    `collar_y` and a dark tip past it."""
    rows = [(y0, _fuse(w0, w0 * 0.5, w0 * 0.47))]
    for k in range(1, 5):
        t = k / 4.0
        w = w0 * (1.0 - 0.72 * t)
        rows.append((y0 + (y1 - y0) * t, _fuse(w, w * 0.5, w * 0.47)))
    b.loft(rows, "steel.plate", "nose_cone")
    wc = w0 * (1.0 - 0.72 * (collar_y - y0) / (y1 - y0)) + 0.3
    b.loft([(collar_y - 1.5, _fuse(wc, wc * 0.5, wc * 0.47)), (collar_y + 1.5, _fuse(wc, wc * 0.5, wc * 0.47))], "livery.livery", "nose_band")
    if tip:
        wt = w0 * 0.28
        b.loft([(y1 - 0.5, diamond(0.0, 0.0, wt + 0.3, wt * 0.9)), (y1 + 12.0, diamond(0.0, 0.0, 0.2, 0.2))], "steel.dark", "nose_tip")


def _needle_tip_sensor(b, y, r=2.6):
    """The Fovea Designator as the needle's own tip: the sensor ball set in the nose's end, its
    lens forward, turning (sensor) and nodding (eye) in a chrome collar."""
    b.loft([(y - 2.4, _oct(0.0, 2.0 * r + 1.0, 2.0 * r + 1.0, 0.0, 10)), (y - 0.6, _oct(0.0, 2.0 * r + 0.6, 2.0 * r + 0.6, 0.0, 10))], "steel.plate", "sensor_collar")
    with b.joint("sensor", (0.0, y, 0.0), axis="yaw", limits=(-60.0, 60.0)):
        with b.joint("eye", (0.0, y, 0.0), axis="pitch", limits=(-30.0, 25.0)):
            b.loft([(y + dy, _oct(0.0, 2.0 * rr, 2.0 * rr, 0.0, 10)) for (dy, rr) in ((-1.2, r * 0.8), (0.6, r), (2.2, r * 0.82), (3.0, r * 0.5))], "steel.dark", "sensor_ball")
            b.prism("y", 0.0, y + 3.3, 0.0, r * 0.6, 0.8, "glass.glass", 10, "lens")
            b.prism("y", 0.0, y + 3.8, 0.0, r * 0.32, 0.6, "amber.lit", 10, "fovea")


def ktlook_needle_lance(b):
    """The lance: the starfighter pushed further. The Fovea Designator is the needle's own tip, a
    sensor ball set in the end of a nose a body long, looking down the lance; the body is a short
    faceted spindle behind it, the cockpit far aft under a dorsal spine; the nacelles stand on the
    centre of mass under short anhedral stubs; a Y tail, one fin up and two down and out."""
    FUSE = [(30.0, 3.6, 1.8, 1.7), (22.0, 7.0, 3.0, 2.8), (10.0, 11.0, 4.4, 4.0), (-2.0, 13.0, 5.0, 4.4), (-14.0, 12.4, 4.9, 4.3),
            (-26.0, 9.4, 4.0, 3.4), (-36.0, 4.6, 2.2, 2.0), (-42.0, 2.4, 1.3, 1.2)]
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    _needle_nose(b, 29.5, 78.0, 3.6, 50.0, tip=False)
    _needle_tip_sensor(b, 78.0, 2.4)
    _canopy(b, FUSE, [(-6.0, 1.2, 0.8), (-10.0, 2.8, 3.2), (-17.0, 3.2, 4.0), (-24.0, 2.8, 3.2), (-29.0, 1.8, 1.4)], -16.6)
    # A dorsal spine from the canopy's back to the fin.
    b.loft([(-29.0, rect(0.0, 2.8, _top(FUSE, -29.0) - 0.4, _top(FUSE, -29.0) + 1.2)), (-38.0, rect(0.0, 1.6, _top(FUSE, -38.0) - 0.3, _top(FUSE, -38.0) + 0.8))], "steel.dark", "spine")
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 5.0, 5.0, -8.0, 0.0, 1.1), _blade_section(s * 20.0, 2.6, -6.6, -3.4, 0.8)], "livery.livery", "stub_wing")
        nx, ny, nz = s * 23.0, -1.5, -3.8
        b.prism("x", s * 20.5, ny, nz, 2.8, 2.6, "steel.dark", 8, "nacelle_root", phase=math.pi / 8)
        with b.joint("nacelle_" + side, (nx, ny, nz), axis="pitch", limits=(-95.0, 22.0)):
            b.prism("z", nx, ny, nz - 2.0, 4.0, 15.0, "steel.dark", 6, "nacelle", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 7.0, 4.3, 5.0, "steel.plate", 6, "nacelle_cowl", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 1.5, 4.2, 2.6, "livery.livery", 6, "nacelle_band", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 9.9, 4.7, 1.0, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
            _disc(b, (nx, ny, nz + 10.45), (0.0, 0.0, 1.0), 3.9, 6, "bore.dark", "intake", phase=math.pi / 6)
            b.prism("z", nx, ny, nz - 10.2, 4.5, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
            _disc(b, (nx, ny, nz - 11.1), (0.0, 0.0, -1.0), 4.1, 6, "amber.exhaust", "exhaust", phase=math.pi / 6)
        b.box(s * 11.0 - 0.7, s * 11.0 + 0.7, -3.0, 6.0, -4.4, -2.6, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 11.0, 5.0, -5.0), "barrel" if s < 0 else "dish", scale=0.5)
    b.pad("hp_3", (0.0, -14.0, -5.0), scale=0.5, size=(4.0, 1.2))
    # The Y tail: a fin up on the spine and two fins down and out at forty degrees.
    _rings(b, [_fin_section(0.0, -30.0, -41.0, _top(FUSE, -34.0), 0.5), _fin_section(0.0, -38.0, -43.0, _top(FUSE, -34.0) + 9.0, 0.25)], "livery.livery", "fin")
    for s in (-1.0, 1.0):
        a = math.radians(40.0)
        _rings(b, [[(s * 1.0, -30.0, -1.0), (s * 1.2, -36.0, -1.0), (s * 1.0, -41.0, -1.0), (s * 0.8, -36.0, -1.0)],
                   [(s * 8.0 * math.sin(a), -37.0, -1.0 - 8.0 * math.cos(a)), (s * 8.0 * math.sin(a) + s * 0.2, -40.0, -1.0 - 8.0 * math.cos(a)),
                    (s * 8.0 * math.sin(a), -43.0, -1.0 - 8.0 * math.cos(a)), (s * 8.0 * math.sin(a) - s * 0.2, -40.0, -1.0 - 8.0 * math.cos(a))]], "livery.livery", "ventral_fin")
    _nt_motion(b)

ktlook_needle_lance.maker = KT


def ktlook_needle_dart(b):
    """The dart: the needle nose grows into a faceted diamond of a body, widest at the centre of
    mass where the nacelles stand at its corners on short stubs, then closing to a tail; the
    cockpit a raised dome aft on the diamond's spine with the designator's ball ahead of it on a
    low mast; a short X tail. A starfighter with the body's weight in one facet."""
    FUSE = [(34.0, 3.2, 1.6, 1.5), (26.0, 6.0, 2.6, 2.4), (14.0, 12.0, 3.6, 3.2), (2.0, 20.0, 4.4, 3.8), (-6.0, 22.0, 4.8, 4.0),
            (-16.0, 17.0, 4.6, 3.8), (-28.0, 9.0, 3.6, 3.0), (-38.0, 3.0, 1.6, 1.5)]
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    _needle_nose(b, 33.5, 76.0, 3.2, 52.0)
    b.loft([(-37.5, diamond(0.0, 0.1, 2.6, 2.4)), (-48.0, diamond(0.0, 0.1, 0.3, 0.3))], "steel.dark", "needle")
    _canopy(b, FUSE, [(-8.0, 1.4, 0.9), (-12.0, 3.0, 3.4), (-18.0, 3.2, 3.9), (-24.0, 2.6, 3.0), (-28.0, 1.6, 1.2)], -17.6)
    # The designator on a low mast ahead of the dome, on the diamond's flat top.
    mz = _top(FUSE, -1.0)
    b.prism("z", 0.0, -1.0, mz + 1.0, 1.0, 2.0, "steel.dark", 6, "sight_mast")
    sz = mz + 4.2
    with b.joint("sensor", (0.0, -1.0, sz), axis="yaw", limits=(-80.0, 80.0)):
        with b.joint("eye", (0.0, -1.0, sz), axis="pitch", limits=(-30.0, 20.0)):
            b.loft([(-1.0 + dy, _oct(sz, 2.0 * r, 2.0 * r, 0.0, 10)) for (dy, r) in ((-3.6, 0.9), (-2.6, 2.3), (-0.8, 3.0), (1.0, 2.5), (1.9, 1.6))], "steel.plate", "sensor_ball")
            b.prism("y", 0.0, 1.3, sz, 1.7, 0.8, "glass.glass", 10, "lens")
            b.prism("y", 0.0, 1.75, sz, 0.85, 0.6, "amber.lit", 10, "fovea")
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 10.0, 2.0, -10.0, 0.2, 1.0), _blade_section(s * 22.0, 0.0, -8.0, -0.6, 0.8)], "livery.livery", "stub_wing")
        nx, ny, nz = s * 25.0, -4.0, -0.6
        b.prism("x", s * 22.5, ny, nz, 2.8, 2.8, "steel.dark", 8, "nacelle_root", phase=math.pi / 8)
        with b.joint("nacelle_" + side, (nx, ny, nz), axis="pitch", limits=(-95.0, 22.0)):
            b.prism("z", nx, ny, nz - 2.2, 4.2, 16.0, "steel.dark", 6, "nacelle", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 7.5, 4.5, 5.5, "steel.plate", 6, "nacelle_cowl", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 1.5, 4.4, 2.8, "livery.livery", 6, "nacelle_band", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 10.7, 4.9, 1.0, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
            _disc(b, (nx, ny, nz + 11.25), (0.0, 0.0, 1.0), 4.1, 6, "bore.dark", "intake", phase=math.pi / 6)
            b.prism("z", nx, ny, nz - 11.0, 4.7, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
            _disc(b, (nx, ny, nz - 11.9), (0.0, 0.0, -1.0), 4.3, 6, "amber.exhaust", "exhaust", phase=math.pi / 6)
        b.box(s * 14.0 - 0.7, s * 14.0 + 0.7, -4.0, 4.0, -4.0, -2.2, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 14.0, 3.0, -4.6), "barrel" if s < 0 else "dish", scale=0.5)
    b.pad("hp_3", (0.0, -20.0, -4.0), scale=0.5, size=(4.0, 1.2))
    _nt_xtail(b, (0.8, -27.0, -37.0), (7.0, -33.0, -39.0))
    _nt_motion(b)

ktlook_needle_dart.maker = KT


# ---------------------------------------------------------------- the Puffin and the Storm Petrel, traded

def _boat_hull(b, hull, deck_scale=1.0):
    """A long chined hull with its skirt and rub rails (the Storm Petrel's first cut), returning
    `at(y)` -> (w, z0, z1)."""
    def at(y):
        return tuple(_lerp_at([(y, w, z0, z1) for (y, w, z0, z1, c) in hull], y))
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in hull], "steel.plate", "hull")
    skirt = [(y, w + 1.0, z0 - 0.6, z0 + 1.4, 0.8) for (y, w, z0, z1, c) in hull[1:]]
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.3)) for (y, w, z0, z1, c) in skirt], "steel.dark", "lip")
    for s in (-1.0, 1.0):
        secs = []
        for (y, w, z0, z1, c) in hull[1:]:
            hw, zc = w / 2.0, z0 + (z1 - z0) * 0.42
            pts = [(hw + 0.4, zc), (hw - 0.3, zc + 0.7), (hw - 1.2, zc), (hw - 0.3, zc - 0.7)]
            secs.append((y, [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]))
        b.loft(list(reversed(secs)), "livery.livery", "chine_stripe")
    return at


def _boat_cab(b, deck, rows, frame_y):
    def cab(y, grow=0.0):
        w, h = _lerp_at(rows, y)
        z, hw = deck(y), w / 2.0 + grow
        return [(-hw, z - 0.8), (hw, z - 0.8), (hw, z + h * 0.45 + grow), (hw * 0.5, z + h + grow), (-hw * 0.5, z + h + grow), (-hw, z + h * 0.45 + grow)]
    b.loft([(y, cab(y)) for (y, w, h) in rows], "glass.glass", "canopy")
    b.loft([(frame_y + 0.6, cab(frame_y + 0.6, 0.35)), (frame_y - 0.6, cab(frame_y - 0.6, 0.35))], "steel.dark", "canopy_frame")


def _stern_booster(b, by, bz, br, band=True, fin=True):
    b.prism("y", 0.0, by, bz, br, 32.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    if band:
        b.prism("y", 0.0, by + 6.0, bz, br + 0.3, 4.0, "livery.livery", 6, "booster_band", phase=math.pi / 6)
    b.prism("y", 0.0, by + 16.4, bz, br + 0.6, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
    b.loft([(by + 16.9, _hexr(0.0, bz, br - 0.2)), (by + 17.1, _hexr(0.0, bz, br - 0.8))], "bore.dark", "intake")
    b.prism("y", 0.0, by - 16.8, bz, br + 0.4, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(by - 17.6, _hexr(0.0, bz, br + 0.2)), (by - 18.1, _hexr(0.0, bz, br - 0.6))], "amber.exhaust", "exhaust")
    if fin:
        _rings(b, [_fin_section(0.0, by + 10.0, by - 10.0, bz + br - 0.8, 0.7), _fin_section(0.0, by - 4.0, by - 14.0, bz + br + 11.0, 0.35)], "livery.livery", "fin")


def ktlook_puffin_boat(b):
    """The Puffin on the Storm Petrel's base (Ryan, 26 October: the speedboat with a mast reads as
    a research boat, which fits the Puffin): the long chined hull and wave-piercing bow at the
    light class's size, one booster astern, and the mast carrying the Puffin's own piece, the
    Backwash Ionizer's projector dish at the masthead over a yard of aerials and a radome, the
    prow's band of light kept as its signature; no riot plates. Short stub wings off the flanks
    carry the pods (hp_1 the Laser Carbine, hp_2 the Deflector's dish), a shoulder fairing the
    Coil's dish (hp_3), the left shoulder bare (hp_4). Floats: the lip at z = 6."""
    K = 0.86
    HULL = [(y * K, w * K, 6.0 + (z0 - 6.0) * K, 6.0 + (z1 - 6.0) * K, c * K) for (y, w, z0, z1, c) in
            ((48.0, 3.0, 10.6, 12.6, 0.6), (40.0, 10.0, 8.8, 14.0, 1.4), (28.0, 18.0, 7.2, 15.6, 2.2), (12.0, 24.0, 6.6, 16.4, 2.8),
             (-12.0, 24.0, 6.6, 16.4, 2.8), (-30.0, 21.0, 7.0, 16.0, 2.4), (-42.0, 15.0, 8.0, 15.2, 2.0))]
    at = _boat_hull(b, HULL)
    deck = lambda y: at(y)[2]
    # The prow's band of light and the projector slot at the bow, the Puffin's own.
    w0, z00, z01 = at(36.0)
    b.loft([(35.0, _hull_section(z00 + 0.3, z01 - 0.3, w0 + 0.3, 1.0)), (36.5, _hull_section(z00 + 0.5, z01 - 0.5, w0 - 0.4, 0.8))], "amber.light", "prow_band")
    _boat_cab(b, deck, [(26.0, 4.5, 0.6), (21.0, 9.0, 2.6), (14.0, 11.0, 3.6), (7.0, 10.0, 3.3), (2.0, 7.0, 2.2)], 15.0)
    # The mast: the Ionizer's projector dish at the masthead, lit, over a yard of aerials and a radome.
    my, mz0, mtop, yz = -6.0, deck(-6.0), 36.0, 28.0
    _beam(b, (0.0, my, mz0 - 0.5), (0.0, my, mtop), _poly(1.3, 6), _poly(0.7, 6), "steel.dark", "mast")
    _beam(b, (-8.0, my, yz), (8.0, my, yz), _sq(0.8, 0.8), _sq(0.8, 0.8), "steel.dark", "yard")
    for s in (-1.0, 1.0):
        _beam(b, (s * 7.5, my, yz), (s * 7.5, my, yz + 7.0), _poly(0.25, 4), _poly(0.12, 4), "steel.dark", "aerial")
    b.loft([(my - 2.4, _oct(yz + 2.2, 1.2, 1.2, 0.0, 8)), (my - 1.2, _oct(yz + 2.6, 3.6, 3.6, 0.0, 8)), (my + 1.2, _oct(yz + 2.6, 3.6, 3.6, 0.0, 8)), (my + 2.4, _oct(yz + 2.2, 1.2, 1.2, 0.0, 8))], "bone.bone", "radome")
    with b.joint("projector", (0.0, my, mtop), axis="yaw", limits=(-120.0, 120.0)):
        tilt = Matrix.Translation((0.0, my, mtop + 1.6)) @ Matrix.Rotation(math.radians(70.0), 4, "X")
        b.loft([(0.0, _poly(0.9, 8)), (1.2, _poly(4.6, 8)), (2.0, _poly(5.0, 8))], "steel.plate", "projector_dish", tilt)
        b.loft([(1.0, _poly(1.3, 8)), (2.0, _poly(1.3, 8))], "amber.engine", "projector_core", tilt)
    _stern_booster(b, -32.0, 12.6, 6.0)
    for s in (-1.0, 1.0):
        root = [(s * 9.5, -6.0, 11.4), (s * 9.5, 0.0, 12.8), (s * 9.5, 6.0, 11.4), (s * 9.5, 0.0, 10.0)]
        tip = [(s * 24.0, 2.0, 9.6), (s * 24.0, 6.0, 10.2), (s * 24.0, 10.0, 9.6), (s * 24.0, 6.0, 9.0)]
        _wing(b, root, tip, "livery.livery", "wing")
        px = s * 21.0
        b.box(min(px - 0.8, px + 0.8), max(px - 0.8, px + 0.8), 2.0, 8.0, 7.6, 9.6, "steel.plate", "pod_pylon")
        with b.socket("hp_%d" % (1 if s < 0 else 2), (px, 10.0, 7.4), scale=0.5):
            b.prism("y", px, 5.0, 7.4, 1.5, 11.0, "steel.dark", 6, "pod")
            if s < 0:
                b.prism("y", px, 15.0, 7.4, 0.8, 10.0, "steel.dark", 6, "laser_carbine")
            else:
                b.prism("y", px, 12.5, 7.4, 3.0, 1.2, "steel.plate", 8, "dish")
                b.prism("y", px, 13.3, 7.4, 1.2, 0.8, "amber.engine", 8, "dish_core")
        rx, ry = s * 7.5, -14.0
        dz = deck(ry)
        b.loft([(ry - 7.0, rect(rx, 2.8, dz - 0.6, dz + 1.0)), (ry + 5.0, rect(rx, 4.0, dz - 0.6, dz + 2.0))], "steel.panel", "shoulder_fairing")
        if s > 0:
            b.stock("hp_3", (rx, ry + 5.5, dz + 1.3), "dish", scale=0.5)
        else:
            b.pad("hp_4", (rx, ry + 5.5, dz + 1.3), scale=0.5, size=(3.6, 1.3))
    for (nx, ny) in ((-6.0, 18.0), (6.0, 18.0), (-6.0, -16.0), (6.0, -16.0)):
        b.prism("z", nx, ny, 6.2, 2.0, 1.4, "amber.engine", 6, "lift_nozzle")
    boosters = ["booster_ring", "exhaust"]
    b.act("project", 4.6, {"projector": [(0.5, 0.0), (1.6, 55.0), (3.4, 55.0), (4.4, 0.0)]},
          glow=[(["projector_core", "prow_band"], [(1.4, 0.0), (1.7, 9.0), (2.0, 2.0), (2.3, 11.0), (3.4, 11.0), (4.2, 0.0)])])
    b.act("lift_hop", 4.6, body=[(0.5, 0.0, 0.0, -2.0, 0.0, 0.0, 0.0), (1.2, 0.0, 0.0, 16.0, 0.0, 6.0, 12.0), (1.8, 0.0, 0.0, 14.0, 0.0, -4.0, -10.0), (2.5, 0.0, 0.0, -3.0, 0.0, 0.0, 0.0),
                                 (2.9, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0), (3.4, 0.0, 0.0, -1.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(["lift_nozzle"], [(0.3, 0.0), (0.6, 10.0), (1.2, 10.0), (1.8, 3.0), (2.5, 8.0), (3.2, 0.0)])])
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, -5.0, 0.0), glow={"parts": boosters, "k": 5.0}, rock=3.0)
    b.move(slide=0.3, bank=0.0, accel=0.8, heft=0.13, oversteer=1.5)

ktlook_puffin_boat.maker = KT


def ktlook_storm_hull(b):
    """The Storm Petrel on the Puffin's base (Ryan, 26 October: the tankiest Kestrel by role must
    look like it takes a hit, and the sturdy Puffin hull does): the wide chined hull and the two
    giant boosters at the medium class's size, made to take a blow. A heavy dark bow plate ahead
    of the prow and a tall armoured skirt; the riot shield one big cobalt plate hinged across the
    foredeck, lying raked over the bow at rest and raising to a wall (joint shield, pitch), its
    field strip lit; St. Elmo's fire on a short armoured mast behind the canopy, its yard and
    masthead lit; the wings thick sponsons. Mounts in the die's order: hp_1 and hp_3 gun tubs on
    the sponsons, hp_2 a rack on the afterdeck, hp_4 bare beside it. Floats: the lip at z = 6."""
    K = 1.18
    HULL = [(y * K, w * K, 6.0 + (z0 - 6.5) * K, 6.0 + (z1 - 6.5) * K, c * K) for (y, w, z0, z1, c) in
            ((30.0, 14.0, 10.0, 14.6, 2.0), (20.0, 28.0, 8.0, 17.6, 3.0), (6.0, 36.0, 7.0, 19.4, 3.5), (-12.0, 34.0, 7.0, 19.4, 3.5),
             (-26.0, 30.0, 8.0, 18.8, 3.0), (-36.0, 22.0, 10.0, 17.4, 2.5))]
    at = lambda y: tuple(_lerp_at([(y, w, z0, z1) for (y, w, z0, z1, c) in HULL], y))
    deck = lambda y: at(y)[2]
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "hull")
    # The armoured skirt, taller than the Puffin's rim, and the bow plate: a dark wedge ahead of
    # the prow and under it, the hull's plow.
    SKIRT = [(y, w + 1.4, z0 - 0.8, z0 + 3.0, 1.0) for (y, w, z0, z1, c) in HULL]
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.3)) for (y, w, z0, z1, c) in SKIRT], "steel.dark", "lip")
    w0, z00, z01 = at(HULL[0][0])
    b.loft([(HULL[0][0], _case(w0 + 1.0, z00 - 0.6, z01 + 0.4, 2.0)), (HULL[0][0] + 9.0, _case(w0 * 0.55, z00 + 1.4, z01 - 1.6, 1.4)), (HULL[0][0] + 13.0, _case(2.0, z00 + 3.0, z00 + 4.4, 0.5))],
           "steel.dark", "bow_plate")
    for k in range(3):
        y = HULL[0][0] + 2.0 + k * 3.0
        b.box(-w0 * 0.3, w0 * 0.3, y, y + 0.8, z01 - 0.2 - k * 0.5, z01 + 0.6 - k * 0.5, "steel.plate", "bow_rib")
    _boat_cab(b, deck, [(18.0, 6.0, 0.6), (12.0, 11.0, 3.0), (4.0, 12.6, 4.0), (-5.0, 12.0, 3.6), (-11.0, 10.0, 2.6)], 8.0)
    # The riot shield: one big cobalt plate hinged across the foredeck ahead of the canopy, raked
    # over the bow at rest and raised to plumb to wall the bow; its rim chrome, its field strip
    # along the top edge and the boss on its face lit as the field rises.
    HY, HZ = 20.0, deck(20.0) + 0.4
    b.prism("x", 0.0, HY, HZ, 1.4, 26.0, "steel.dark", 6, "hinge")
    with b.joint("shield", (0.0, HY, HZ), axis="pitch", limits=(0.0, 62.0)):
        ANG = math.radians(24.0)
        d = Vector((0.0, math.cos(ANG), math.sin(ANG)))
        OUT = [(-13.0, 0.0), (13.0, 0.0), (14.5, 8.0), (12.0, 20.0), (0.0, 23.0), (-12.0, 20.0), (-14.5, 8.0)]   # (across, out from the hinge)
        n = Vector((0.0, -math.sin(ANG), math.cos(ANG)))
        faces = [[tuple(Vector((u, HY, HZ)) + d * v + n * off) for (u, v) in OUT] for off in (-0.7, 0.7)]
        _rings(b, faces, "livery.livery2", "plate")
        rim = [(u * 1.06, v * 1.06) for (u, v) in OUT]
        _rings(b, [[tuple(Vector((u, HY, HZ)) + d * v + n * off) for (u, v) in rim] for off in (-0.5, 0.5)], "steel.plate", "plate_rim")
        boss = Vector((0.0, HY, HZ)) + d * 11.0
        _disc(b, tuple(boss + n * 0.8), tuple(n), 3.0, 6, "steel.dark", "boss")
        _disc(b, tuple(boss + n * 0.9), tuple(n), 1.9, 6, "amber.ember", "field_boss")
        _beam(b, tuple(Vector((-12.0, HY, HZ)) + d * 20.6 + n * 0.3), tuple(Vector((12.0, HY, HZ)) + d * 20.6 + n * 0.3), _sq(0.9, 1.8), _sq(0.9, 1.8), "amber.ember", "field_edge")
    # St. Elmo's fire on a short armoured mast behind the canopy.
    my, mz0, mtop, yz = -14.0, deck(-14.0), 34.0, 29.0
    _beam(b, (0.0, my, mz0 - 0.5), (0.0, my, mtop), _poly(2.0, 6), _poly(1.0, 6), "steel.dark", "mast")
    _beam(b, (-8.0, my, yz), (8.0, my, yz), _sq(0.9, 0.9), _sq(0.9, 0.9), "steel.dark", "yard")
    cz = mtop + 2.2
    b.loft([(my + dy, _oct(cz, 2.0 * r, 2.0 * r, 0.0, 8)) for (dy, r) in ((-2.6, 0.8), (-1.6, 2.4), (0.0, 3.0), (1.6, 2.4), (2.6, 0.8))], "amber.corona", "corona")
    _rings(b, [[(5.4 * math.cos(a), my + 5.4 * math.sin(a), cz) for a in [i * math.pi / 6 for i in range(12)]],
               [(4.2 * math.cos(a), my + 4.2 * math.sin(a), cz) for a in [i * math.pi / 6 for i in range(12)]]], "amber.corona", "corona_halo", cap=False)
    for s in (-1.0, 1.0):
        b.loft([(my + dy, _oct(yz, 2.0 * r, 2.0 * r, s * 8.8, 6)) for (dy, r) in ((-1.4, 0.5), (0.0, 1.6), (1.4, 0.5))], "amber.corona", "corona_tip")
    # The nacelles and giant boosters, the Puffin's, scaled; thick sponsons in the wings' place
    # carrying the gun tubs.
    def nac_top(y):
        return deck(-6.0 * K) + (deck(-33.0 * K) - deck(-6.0 * K)) * (-6.0 * K - y) / (27.0 * K)
    for s in (-1.0, 1.0):
        bx, bz, br = s * 17.0 * K, 6.0 + (12.4 - 6.5) * K, 6.4 * K
        def nac(y, x_out):
            t = nac_top(y)
            pts = [(10.0 * K, 8.6), (x_out, 8.6), (x_out, t - 1.6), (x_out - 1.6, t), (10.0 * K, t)]
            return [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]
        b.loft([(-6.0 * K, nac(-6.0 * K, 22.2 * K)), (-20.0 * K, nac(-20.0 * K, 22.0 * K)), (-33.0 * K, nac(-33.0 * K, 21.2 * K))], "steel.plate", "nacelle")
        b.prism("y", bx, -20.5 * K, bz, br, 31.0 * K, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.loft([(-5.0 * K, hexagon(bx, bz, 12.0 * K, 10.6 * K)), (-4.4 * K, hexagon(bx, bz, 10.6 * K, 9.4 * K))], "bore.dark", "intake")
        b.prism("y", bx, -4.8 * K, bz, 7.2 * K, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
        b.prism("y", bx, -36.0 * K, bz, 7.3 * K, 1.2, "steel.plate", 6, "exhaust_lip", phase=math.pi / 6)
        b.prism("y", bx, -36.9 * K, bz, 6.9 * K, 1.4, "amber.engine", 6, "nozzle_ring", phase=math.pi / 6)
        b.loft([(-37.6 * K, hexagon(bx, bz, 11.2 * K, 9.8 * K)), (-38.1 * K, hexagon(bx, bz, 10.0 * K, 8.6 * K))], "amber.exhaust", "exhaust")
        # The sponson: a thick armoured shelf out of the nacelle's flank, its gun tub on top.
        sx0, sx1 = sorted((s * 22.0 * K, s * 34.0 * K))
        b.loft([(-4.0, [(x + (sx0 + sx1) / 2.0, z) for (x, z) in _case(sx1 - sx0, 10.0, 15.0, 1.6)]),
                (-22.0, [(x + (sx0 + sx1) / 2.0, z) for (x, z) in _case(sx1 - sx0, 10.0, 15.0, 1.6)]),
                (-30.0, [(x + (sx0 + sx1) / 2.0, z) for (x, z) in _case((sx1 - sx0) * 0.6, 10.5, 14.0, 1.2)])], "livery.livery", "sponson")
        tx = (sx0 + sx1) / 2.0
        b.box(tx - 2.0, tx + 2.0, -14.0, -9.0, 14.8, 16.2, "steel.panel", "mount")
        b.stock("hp_%d" % (1 if s < 0 else 3), (tx, -9.0, 17.4), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    # The afterdeck mounts between the mast and the fins.
    b.box(-6.5, -2.5, -26.0, -22.0, deck(-24.0) - 0.6, deck(-24.0) + 0.9, "steel.panel", "mount")
    b.stock("hp_2", (-4.5, -22.0, deck(-24.0) + 2.0), "rack", scale=0.5)
    b.pad("hp_4", (4.5, -24.0, deck(-24.0) + 1.0), scale=0.5, size=(4.0, 1.4))
    fh, fy0, fy1 = 14.0, -48.0, -39.0
    for s in (-1.0, 1.0):
        a = math.radians(s * 35.0)
        fx, fz = s * 8.0, deck(-35.0)
        root = [(fx, -40.0, fz - 0.8), (fx, -28.0, fz - 0.8), (fx, -28.0, fz + 0.2), (fx, -40.0, fz + 0.2)]
        tip = [(fx + fh * math.sin(a), fy0, fz + fh * math.cos(a)), (fx + fh * math.sin(a), fy1, fz + fh * math.cos(a)),
               (fx + fh * math.sin(a), fy1, fz + 0.5 + fh * math.cos(a)), (fx + fh * math.sin(a), fy0, fz + 0.5 + fh * math.cos(a))]
        _wing(b, root, tip, "livery.livery", "fin")
    for (nx, ny) in ((-9.0, 12.0), (9.0, 12.0), (-9.0, -18.0), (9.0, -18.0)):
        b.prism("z", nx, ny, 6.4, 2.6, 1.4, "amber.engine", 6, "lift_nozzle")
    boosters = ["nozzle_ring", "exhaust"]
    b.act("shield_up", 5.0, {"shield": [(0.4, 0.0), (1.2, 58.0), (3.4, 58.0), (4.3, 0.0)]},
          body=[(0.5, 0.0, 0.0, 0.0), (1.3, 0.0, -1.0, -1.6, 0.0, 2.0, 0.0), (3.4, 0.0, -1.0, -1.6, 0.0, 2.0, 0.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(["field_edge", "field_boss"], [(0.8, 0.0), (1.3, 10.0), (1.6, 4.0), (1.9, 12.0), (3.4, 12.0), (4.3, 0.0)])])
    b.act("ram", 3.8, {"shield": [(0.4, 0.0), (1.0, 30.0), (1.4, 4.0), (2.0, 8.0), (2.9, 0.0)]},
          body=[(0.9, 0.0, -2.0, 0.5, 0.0, 2.0, 0.0), (1.4, 0.0, 10.0, -1.0, 0.0, -4.0, 0.0), (2.0, 0.0, 6.0, -0.5, 0.0, -1.0, 0.0), (3.8, 0.0, 0.0, 0.0)],
          glow=[(["field_edge", "field_boss"], [(1.3, 0.0), (1.4, 16.0), (1.8, 3.0), (2.5, 0.0)])], heft=0.06)
    b.act("st_elmo", 4.6, {"shield": [(0.6, 0.0), (1.6, 10.0), (3.4, 10.0), (4.2, 0.0)]},
          body=[(0.6, 0.0, 0.0, 0.0), (1.6, 0.0, 0.0, 1.2), (3.4, 0.0, 0.0, 1.2), (4.6, 0.0, 0.0, 0.0)],
          glow=[(["corona"], [(0.3, 0.0), (0.6, 6.0), (0.75, 1.0), (1.0, 9.0), (1.15, 2.0), (1.5, 12.0), (1.7, 5.0), (2.0, 14.0), (3.4, 14.0), (4.2, 0.0)])])
    b.gait(hold={"shield": 20.0}, body_hold=(0.0, 0.0, 0.0, 0.0, -3.0, 0.0), glow={"parts": boosters, "k": 5.0}, rock=3.0)
    b.move(slide=0.3, bank=0.0, accel=0.6, heft=0.14, oversteer=1.1)

ktlook_storm_hull.maker = KT


# ---------------------------------------------------------------- the Giant Petrel, ours

def _planform(points_right):
    """A chevron's outline as a closed ring from (x, y) points of its right half, bow to stern,
    mirrored for the left, the centreline points shared."""
    right = list(points_right)
    left = [(-x, y) for (x, y) in reversed(right) if x > 0.0]
    return right + left


def ktlook_giant_wing(b):
    """The flagship as a flying-wing hovercraft: one wide chrome chevron, the giant petrel's span,
    nothing else in the roster. A thick centre body with the bridge at the apex; four of Kestrel's
    giant booster drums set across the trailing edge, lit; the Spindrift Salvo's six tubes recessed
    in the leading edge's roots in two banks, their mouths lit as they fire; the Reheat Uplink's
    dish on a dorsal pylon aft of the bridge; a turret on each wing (hp_1 the Railgun left, hp_2
    the Twin Autoguns right), hp_3 bare on the spine; a skirt all round under the chevron; canted
    fins at the tips. Floats: the lip at z = 6."""
    Z0, Z1 = 6.0, 20.0
    LE = [(0.0, 64.0), (14.0, 56.0), (30.0, 46.0), (50.0, 34.0), (70.0, 22.0), (86.0, 12.0)]   # the leading edge, apex to tip
    TE = [(86.0, 2.0), (70.0, -4.0), (50.0, -16.0), (30.0, -28.0), (14.0, -34.0), (0.0, -36.0)]   # the trailing edge, tip to centre
    def le(x):
        return _lerp_at([(-p[0], p[1]) for p in LE], -abs(x))[0]
    def te(x):
        return _lerp_at([(-p[0], p[1]) for p in reversed(TE)], -abs(x))[0]
    def thick(x):
        return max(1.6, 8.0 - abs(x) * 0.075)
    stations = [-86.0, -70.0, -50.0, -30.0, -14.0, 0.0, 14.0, 30.0, 50.0, 70.0, 86.0]
    _rings(b, [_blade_section(x, le(x), te(x), (Z0 + Z1) / 2.0 + 1.0, thick(x), lead=0.42) for x in stations], "steel.plate", "wing")
    outline = _planform(LE + TE[:-1])
    _rings(b, [[(x, y, Z0 - 0.4) for (x, y) in outline], [(x * 0.985, y * 0.985 + 0.4, Z0 + 1.8) for (x, y) in outline]], "steel.dark", "lip", cap=False)
    # The centre body: a chined hull rising out of the wing, the bridge's glass across its front.
    HULL = [(60.0, 8.0, 14.0, 20.0, 1.4), (48.0, 16.0, 12.0, 26.0, 2.6), (28.0, 22.0, 11.0, 28.0, 3.4), (0.0, 22.0, 11.0, 28.0, 3.4), (-24.0, 18.0, 12.0, 26.0, 2.6), (-40.0, 10.0, 14.0, 22.0, 1.6)]
    deck = lambda y: _lerp_at([(y, z1) for (y, w, z0, z1, c) in HULL], y)[0]
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "body")
    _boat_cab(b, deck, [(56.0, 4.0, 0.6), (51.0, 9.0, 2.6), (44.0, 12.0, 3.4), (36.0, 12.0, 3.0), (31.0, 9.0, 1.6)], 45.0)
    for s in (-1.0, 1.0):
        secs = []
        for y in (56.0, 44.0, 20.0, -10.0, -30.0):
            w, z0, z1 = _lerp_at([(yy, ww, zz0, zz1) for (yy, ww, zz0, zz1, c) in HULL], y)
            hw, zc = w / 2.0, z0 + (z1 - z0) * 0.42
            pts = [(hw + 0.4, zc), (hw - 0.3, zc + 0.8), (hw - 1.2, zc), (hw - 0.3, zc - 0.8)]
            secs.append((y, [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]))
        b.loft(list(reversed(secs)), "livery.livery", "chine_stripe")
    # Four giant boosters across the trailing edge, half sunk in the wing, their mouths on the
    # wing's top and their rings and exhausts past the edge.
    for x in (-50.0, -24.0, 24.0, 50.0):
        bz, br = (Z0 + Z1) / 2.0 + 2.6, 6.4
        ty = te(x)
        b.prism("y", x, ty + 10.0, bz, br, 30.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", x, ty + 25.6, bz, br + 0.6, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
        b.loft([(ty + 26.1, _hexr(x, bz, br - 0.2)), (ty + 26.3, _hexr(x, bz, br - 0.8))], "bore.dark", "intake")
        b.prism("y", x, ty - 6.0, bz, br + 0.4, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
        b.loft([(ty - 6.8, _hexr(x, bz, br + 0.2)), (ty - 7.3, _hexr(x, bz, br - 0.6))], "amber.exhaust", "exhaust")
        b.loft([(ty + 2.0, [(xx + x, z) for (xx, z) in _case(13.0, bz - 2.0, bz + 2.0, 1.0)]),
                (ty + 8.0, [(xx + x, z) for (xx, z) in _case(14.0, bz - 2.5, bz + 3.5, 1.2)])], "livery.livery", "booster_band")
    # The Spindrift Salvo: two banks of three tubes recessed in the leading edge's roots, their
    # floors and mouths lit as they fire.
    for s in (-1.0, 1.0):
        for k, tag in enumerate("abc"):
            x = s * (16.0 + 6.0 * k)
            y0 = le(x) - 0.2
            p1, p0 = Vector((x, y0, (Z0 + Z1) / 2.0 + 1.4)), Vector((x, y0 - 12.0, (Z0 + Z1) / 2.0 + 1.4))
            _tube(b, tuple(p0), tuple(p1), 2.5, 1.9, 8, "steel.dark", "salvo_" + tag, floor_material="amber.ember", floor_depth=1.2)
            _disc(b, tuple(p1 - Vector((0.0, 0.4, 0.0))), (0.0, 1.0, 0.0), 2.6, 8, "amber.ember", "salvo_%s_blast" % tag)
    # The Reheat Uplink: a dish on a dorsal pylon aft of the bridge.
    uy, uz = 10.0, deck(10.0)
    b.loft([(14.0, rect(0.0, 4.0, uz - 0.4, uz + 3.0)), (6.0, rect(0.0, 3.0, uz - 0.4, uz + 3.6))], "steel.dark", "uplink_mast")
    with b.joint("sensor_uplink", (0.0, uy, uz + 3.6), axis="yaw", limits=(-120.0, 120.0)):
        tilt = Matrix.Translation((0.0, uy, uz + 6.0)) @ Matrix.Rotation(math.radians(50.0), 4, "X")
        b.loft([(0.0, _poly(1.0, 8)), (1.2, _poly(6.4, 8)), (2.2, _poly(6.8, 8))], "steel.plate", "uplink_dish", tilt)
        b.loft([(1.0, _poly(1.3, 8)), (2.0, _poly(1.3, 8))], "amber.lit", "uplink_core", tilt)
    # The turrets on the wings, and the canted tip fins.
    for s, pin, kind in ((-1.0, "hp_1", "barrel"), (1.0, "hp_2", "twin_barrel")):
        tx, ty = s * 40.0, 6.0
        tz = (Z0 + Z1) / 2.0 + 1.0 + thick(tx) * 0.6
        b.prism("z", tx, ty, tz + 0.4, 5.6, 1.2, "steel.dark", 8, "turret_ring", phase=math.pi / 8)
        with b.joint("turret_" + ("l" if s < 0 else "r"), (tx, ty, tz + 1.0), axis="yaw", limits=(-75.0, 75.0)):
            b.loft([(tz + 0.8, _poly(5.2, 8, math.pi / 8)), (tz + 3.2, _poly(4.8, 8, math.pi / 8)), (tz + 4.8, _poly(3.2, 8, math.pi / 8))],
                   "steel.plate", "turret_house", Matrix.Translation((tx, ty, 0.0)) @ Matrix.Rotation(math.pi / 2, 4, "X"))
            b.stock(pin, (tx, ty + 2.0, tz + 3.0), kind, scale=0.8)
        a = math.radians(s * 30.0)
        fz = (Z0 + Z1) / 2.0 + 1.0
        _rings(b, [[(s * 84.0, 12.0, fz), (s * 84.4, 7.0, fz), (s * 84.0, 2.0, fz), (s * 83.6, 7.0, fz)],
                   [(s * 84.0 + 12.0 * math.sin(a), 4.0, fz + 12.0 * math.cos(a)), (s * 84.0 + 12.0 * math.sin(a) + s * 0.2, 1.0, fz + 12.0 * math.cos(a)),
                    (s * 84.0 + 12.0 * math.sin(a), -2.0, fz + 12.0 * math.cos(a)), (s * 84.0 + 12.0 * math.sin(a) - s * 0.2, 1.0, fz + 12.0 * math.cos(a))]], "livery.livery", "fin")
    b.pad("hp_3", (0.0, -14.0, deck(-14.0) + 1.0), scale=0.8, size=(4.4, 1.4))
    for (nx, ny) in ((-30.0, 10.0), (30.0, 10.0), (-30.0, -16.0), (30.0, -16.0), (0.0, 30.0), (0.0, -24.0)):
        b.prism("z", nx, ny, Z0 + 0.2, 2.6, 1.4, "amber.engine", 6, "lift_nozzle")
    boosters = ["booster_ring", "exhaust"]
    b.act("salvo", 6.2, body=[(1.8, 0.0, 0.0, 0.0), (2.2, 0.0, -0.6, 0.0, 0.0, 0.8, 0.0), (2.7, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0), (3.2, 0.0, -1.3, 0.0, 0.0, 1.0, 0.0), (4.0, 0.0, -0.5, 0.0), (6.2, 0.0, 0.0, 0.0)],
          glow=[(["salvo_a_floor", "salvo_a_blast"], [(2.0, 0.0), (2.15, 16.0), (2.6, 2.0), (3.4, 0.0)]),
                (["salvo_b_floor", "salvo_b_blast"], [(2.5, 0.0), (2.65, 16.0), (3.1, 2.0), (3.9, 0.0)]),
                (["salvo_c_floor", "salvo_c_blast"], [(3.0, 0.0), (3.15, 16.0), (3.6, 2.0), (4.4, 0.0)])])
    b.act("immelmann", 6.0, body=[(0.8, 0.0, 0.0, 0.0), (2.0, 0.0, 2.0, 4.0, 0.0, 3.0, 0.0), (3.8, 0.0, 3.0, 4.5, 0.0, 2.0, 0.0), (4.8, 0.0, 1.0, -1.0, 0.0, -1.0, 0.0), (6.0, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.5, 0.0), (1.2, 6.0), (1.8, 12.0), (3.8, 12.0), (4.6, 0.0)])])
    b.act("uplink", 5.6, {"sensor_uplink": [(0.5, 0.0), (1.9, 60.0), (3.6, 60.0), (5.0, 0.0)]},
          glow=[(["uplink_core"], [(1.8, 0.0), (2.1, 10.0), (2.4, 2.0), (2.7, 12.0), (3.6, 12.0), (4.4, 0.0)])])
    b.act("traverse", 7.4, {"turret_l": [(0.6, 0.0), (2.0, 46.0), (2.8, 46.0), (5.2, -34.0), (6.0, -34.0), (7.2, 0.0)],
                            "turret_r": [(1.0, 0.0), (2.4, -40.0), (3.2, -40.0), (5.4, 30.0), (6.2, 30.0), (7.2, 0.0)]})
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, 2.0, 0.0), glow={"parts": boosters, "k": 4.0}, rock=2.0)
    b.move(slide=0.3, bank=0.0, accel=1.6, heft=0.25, oversteer=0.5)

ktlook_giant_wing.maker = KT


def ktlook_giant_cat(b):
    """The flagship as a catamaran: two long chined hulls, each the Puffin's hull drawn out and
    ending in one of Kestrel's giant boosters, bridged by a deck that carries a stepped bridge
    tower forward, the Spindrift Salvo as a turret of six tubes amidships that trains and elevates
    (joints salvo_ring, salvo), and the Reheat Uplink's dish on a mast aft. A gun turret on each
    bow (hp_1 the Railgun left, hp_2 the Twin Autoguns right), hp_3 bare on the deck. From above
    an H, which nothing else in the roster is. Floats: the lips at z = 6."""
    HX = 24.0
    HULL = [(70.0, 4.0, 11.0, 13.0, 0.8), (60.0, 10.0, 9.0, 15.0, 1.6), (44.0, 15.0, 7.2, 17.0, 2.2), (20.0, 18.0, 6.6, 18.0, 2.6),
            (-20.0, 18.0, 6.6, 18.0, 2.6), (-44.0, 16.0, 7.0, 17.4, 2.2), (-58.0, 13.0, 8.0, 16.6, 1.8)]
    deck = lambda y: _lerp_at([(y, z1) for (y, w, z0, z1, c) in HULL], y)[0]
    for s in (-1.0, 1.0):
        cx = s * HX
        b.loft([(y, _chine_section(z0, z1, w, c, cx=cx)) for (y, w, z0, z1, c) in HULL], "steel.plate", "hull")
        b.loft([(y, _hull_section(z0 - 0.6, z0 + 1.4, w + 1.0, 0.8, cx=cx, belly=0.3)) for (y, w, z0, z1, c) in HULL[1:]], "steel.dark", "lip")
        w0, z00, z01 = _lerp_at([(yy, ww, zz0, zz1) for (yy, ww, zz0, zz1, c) in HULL], 58.0)
        b.loft([(57.0, _hull_section(z00 + 0.3, z01 - 0.3, w0 + 0.3, 1.0, cx=cx)), (58.5, _hull_section(z00 + 0.5, z01 - 0.5, w0 - 0.4, 0.8, cx=cx))], "amber.light", "prow_band")
        secs = []
        for (y, w, z0, z1, c) in HULL[1:]:
            hw, zc = w / 2.0, z0 + (z1 - z0) * 0.42
            pts = [(cx + hw + 0.4, zc), (cx + hw - 0.3, zc + 0.7), (cx + hw - 1.2, zc), (cx + hw - 0.3, zc - 0.7)]
            secs.append((y, pts if s > 0 else [(2 * cx - x, z) for (x, z) in reversed(pts)]))
        b.loft(list(reversed(secs)), "livery.livery", "chine_stripe")
        # The giant booster astern of each hull, the hull's tail flowing onto its drum.
        by, bz, br = -64.0, 13.6, 8.0
        yl, wl, z0l, z1l, cl = HULL[-1]
        b.loft([(yl, _oct((z0l + z1l) / 2.0, wl, z1l - z0l, cx, 6)), (by + 14.0, _hexr(cx, bz, br))], "steel.plate", "tail_fairing")
        b.prism("y", cx, by, bz, br, 30.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", cx, by + 8.0, bz, br + 0.3, 4.0, "livery.livery", 6, "booster_band", phase=math.pi / 6)
        b.prism("y", cx, by - 15.4, bz, br + 0.4, 1.8, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
        b.loft([(by - 16.3, _hexr(cx, bz, br + 0.2)), (by - 16.9, _hexr(cx, bz, br - 0.8))], "amber.exhaust", "exhaust")
        _rings(b, [_fin_section(cx, by + 6.0, by - 10.0, bz + br - 0.8, 0.8), _fin_section(cx + s * 4.0, by - 6.0, by - 14.0, bz + br + 12.0, 0.4)], "livery.livery", "fin")
        # A gun turret on each bow.
        ty = 40.0
        tz = deck(ty)
        b.prism("z", cx, ty, tz + 0.4, 5.4, 1.2, "steel.dark", 8, "turret_ring", phase=math.pi / 8)
        with b.joint("turret_" + ("l" if s < 0 else "r"), (cx, ty, tz + 1.0), axis="yaw", limits=(-75.0, 75.0)):
            b.loft([(tz + 0.8, _poly(5.0, 8, math.pi / 8)), (tz + 3.2, _poly(4.6, 8, math.pi / 8)), (tz + 4.8, _poly(3.0, 8, math.pi / 8))],
                   "steel.plate", "turret_house", Matrix.Translation((cx, ty, 0.0)) @ Matrix.Rotation(math.pi / 2, 4, "X"))
            b.stock("hp_1" if s < 0 else "hp_2", (cx, ty + 2.0, tz + 3.0), "barrel" if s < 0 else "twin_barrel", scale=0.8)
        for ny in (30.0, -30.0):
            b.prism("z", cx, ny, 6.2, 2.4, 1.4, "amber.engine", 6, "lift_nozzle")
    # The bridge deck between the hulls: a slab with a chamfered edge, and the bridge tower
    # stepped up forward with a band of glass round its top.
    DZ0, DZ1 = 15.0, 19.0
    b.loft([(34.0, _case(2 * HX + 6.0, DZ0, DZ1, 1.6)), (-40.0, _case(2 * HX + 6.0, DZ0, DZ1, 1.6))], "steel.plate", "bridge_deck")
    for s in (-1.0, 1.0):
        b.loft([(30.0, rect(s * (HX - 4.0), 10.0, DZ1 - 0.2, DZ1 + 0.6)), (-36.0, rect(s * (HX - 4.0), 10.0, DZ1 - 0.2, DZ1 + 0.6))], "livery.livery", "deck_stripe")
    TOWER = [(30.0, 16.0, DZ1, DZ1 + 6.0, 1.6), (18.0, 20.0, DZ1, DZ1 + 9.0, 2.0), (6.0, 20.0, DZ1, DZ1 + 9.0, 2.0), (-4.0, 14.0, DZ1, DZ1 + 6.0, 1.6)]
    b.loft([(y, _case(w, z0, z1, c)) for (y, w, z0, z1, c) in TOWER], "steel.plate", "bridge_tower")
    tdeck = lambda y: _lerp_at([(y, z1) for (y, w, z0, z1, c) in TOWER], y)[0]
    _boat_cab(b, tdeck, [(28.0, 5.0, 0.6), (24.0, 11.0, 2.8), (18.0, 14.0, 3.6), (12.0, 14.0, 3.4), (8.0, 10.0, 1.8)], 19.0)
    # The Spindrift Salvo: six tubes in a turret amidships, training on a ring and elevating.
    sy, sz = -18.0, DZ1
    b.prism("z", 0.0, sy, sz + 0.5, 9.0, 1.4, "steel.dark", 10, "salvo_base")
    with b.joint("salvo_ring", (0.0, sy, sz + 1.2), axis="yaw", limits=(-90.0, 90.0)):
        b.loft([(sz + 1.2, _poly(8.4, 10)), (sz + 4.0, _poly(7.6, 10))], "steel.plate", "salvo_turret", Matrix.Translation((0.0, sy, 0.0)) @ Matrix.Rotation(math.pi / 2, 4, "X"))
        with b.joint("salvo", (0.0, sy - 4.0, sz + 5.0), axis="pitch", limits=(-2.0, 30.0)):
            b.loft([(sy - 6.0, _case(14.0, sz + 4.0, sz + 6.2, 0.8)), (sy + 6.0, _case(14.0, sz + 4.0, sz + 6.2, 0.8))], "steel.panel", "salvo_plinth")
            for k, tag in enumerate("abc"):
                for s in (-1.0, 1.0):
                    x = s * (2.6 + 0.0)
                    zz = sz + 8.0 + k * 0.0
                    p0, p1 = Vector((s * 4.2, sy - 6.0 + k * 0.0, sz + 8.2 + (k - 1) * 0.0)), Vector((s * 4.2, sy + 7.0, sz + 9.6))
                    off = Vector((0.0, 0.0, (k - 1) * 3.6))
                    _tube(b, tuple(p0 + off), tuple(p1 + off), 2.2, 1.7, 8, "steel.dark", "salvo_" + tag, floor_material="amber.ember", floor_depth=1.0)
                    dv = (p1 - p0).normalized()
                    _disc(b, tuple(p0 + off - dv * 0.15), tuple(-dv), 1.9, 8, "amber.ember", "salvo_%s_blast" % tag)
    # The Reheat Uplink's dish on a mast at the deck's stern.
    uy = -34.0
    _beam(b, (0.0, uy, DZ1 - 0.5), (0.0, uy, DZ1 + 14.0), _poly(1.6, 6), _poly(0.9, 6), "steel.dark", "uplink_mast")
    with b.joint("sensor_uplink", (0.0, uy, DZ1 + 14.0), axis="yaw", limits=(-150.0, 150.0)):
        tilt = Matrix.Translation((0.0, uy, DZ1 + 16.4)) @ Matrix.Rotation(math.radians(55.0), 4, "X")
        b.loft([(0.0, _poly(1.0, 8)), (1.2, _poly(6.0, 8)), (2.2, _poly(6.4, 8))], "steel.plate", "uplink_dish", tilt)
        b.loft([(1.0, _poly(1.3, 8)), (2.0, _poly(1.3, 8))], "amber.lit", "uplink_core", tilt)
    b.pad("hp_3", (10.0, 0.0, DZ1 + 1.0), scale=0.8, size=(4.4, 1.4))
    boosters = ["booster_ring", "exhaust"]
    b.act("salvo", 6.2, {"salvo_ring": [(0.4, 0.0), (1.6, 40.0), (4.8, 40.0), (6.0, 0.0)], "salvo": [(0.8, 0.0), (1.8, 22.0), (4.6, 22.0), (5.8, 0.0)]},
          body=[(1.8, 0.0, 0.0, 0.0), (2.2, 0.0, -0.6, 0.0, 0.0, 0.8, 0.0), (2.7, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0), (3.2, 0.0, -1.3, 0.0, 0.0, 1.0, 0.0), (4.0, 0.0, -0.5, 0.0), (6.2, 0.0, 0.0, 0.0)],
          glow=[(["salvo_a_floor", "salvo_a_blast"], [(2.0, 0.0), (2.15, 16.0), (2.6, 2.0), (3.4, 0.0)]),
                (["salvo_b_floor", "salvo_b_blast"], [(2.5, 0.0), (2.65, 16.0), (3.1, 2.0), (3.9, 0.0)]),
                (["salvo_c_floor", "salvo_c_blast"], [(3.0, 0.0), (3.15, 16.0), (3.6, 2.0), (4.4, 0.0)])])
    b.act("immelmann", 6.0, body=[(0.8, 0.0, 0.0, 0.0), (2.0, 0.0, 4.0, 3.0, 0.0, 2.0, 0.0), (3.8, 0.0, 6.0, 3.5, 0.0, 1.5, 0.0), (4.8, 0.0, 1.0, -1.0, 0.0, -1.0, 0.0), (6.0, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.5, 0.0), (1.2, 6.0), (1.8, 12.0), (3.8, 12.0), (4.6, 0.0)])])
    b.act("uplink", 5.6, {"sensor_uplink": [(0.5, 0.0), (1.9, 70.0), (3.6, 70.0), (5.0, 0.0)]},
          glow=[(["uplink_core"], [(1.8, 0.0), (2.1, 10.0), (2.4, 2.0), (2.7, 12.0), (3.6, 12.0), (4.4, 0.0)])])
    b.act("traverse", 7.4, {"turret_l": [(0.6, 0.0), (2.0, 46.0), (2.8, 46.0), (5.2, -34.0), (6.0, -34.0), (7.2, 0.0)],
                            "turret_r": [(1.0, 0.0), (2.4, -40.0), (3.2, -40.0), (5.4, 30.0), (6.2, 30.0), (7.2, 0.0)]})
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, 2.0, 0.0), glow={"parts": boosters, "k": 4.0}, rock=2.0)
    b.move(slide=0.3, bank=0.0, accel=1.6, heft=0.25, oversteer=0.5)

ktlook_giant_cat.maker = KT


LOOKS = ["ktlook_skua_jaeger2", "ktlook_skua_scissor", "ktlook_skua_droptip", "ktlook_needle_lance", "ktlook_needle_dart",
         "ktlook_puffin_boat", "ktlook_storm_hull", "ktlook_giant_wing", "ktlook_giant_cat"]

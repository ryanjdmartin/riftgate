"""Look tests for the Kestrel line's second round (Ryan's notes of 23 October on Claude's first
cut), for him to see before any is chosen (docs/looks/kestrel_*.png). The Needletail with its
stub wings moved to the centre of mass, and flipped into the classic starfighter's layout (a
very long thin nose cone, the cockpit aft); the Skua as an original swing-wing (Ryan: the first
cut was the F-14 poly for poly, "I'm ok for a homage, but that has no originality in it
whatsoever"). Not content and not in models_low.py: built only by build_look.py. x right,
y forward, z up, as in models_low.py."""

import math

from bl_low import diamond, rect
from models_low import _blade_section, _disc, _fin_section, _fuse, _hexr, _missile_face, _oct, _rings

KT = "kestrel"


def _top(fuse, y):
    """The fuselage's top at `y`, from its (y, w, top, bottom) sections."""
    for (y0, w0, t0, b0), (y1, w1, t1, b1) in zip(fuse, fuse[1:]):
        if y1 <= y <= y0:
            return t0 + (t1 - t0) * (y0 - y) / (y0 - y1)
    return fuse[-1][2]


def _canopy(b, fuse, rows, frame_y, label="canopy"):
    """A canopy on the fuselage's top through `rows` of (y, half width, height), a frame band
    across it at `frame_y`."""
    def cab(y, hw, h, grow=0.0):
        z, hw = _top(fuse, y), hw + grow
        return [(-hw, z - 0.6), (hw, z - 0.6), (hw, z + h * 0.55 + grow), (hw * 0.6, z + h + grow), (-hw * 0.6, z + h + grow), (-hw, z + h * 0.55 + grow)]
    b.loft([(y, cab(y, hw, h)) for (y, hw, h) in rows], "glass.glass", label)
    hw, h = max((r[1], r[2]) for r in rows)
    b.loft([(frame_y + 0.6, cab(frame_y + 0.6, hw, h, 0.3)), (frame_y - 0.6, cab(frame_y - 0.6, hw, h, 0.3))], "steel.dark", label + "_frame")


# ---------------------------------------------------------------- the Needletail

def _nt_sensor(b, y, mz):
    """The Fovea Designator (fixed): a sensor ball on a short mast standing on the spine at `y`,
    turning (sensor) and nodding (eye), its lens a glass ring round a lit core."""
    b.prism("z", 0.0, y, mz + 2.2, 1.0, 4.4, "steel.dark", 6, "sight_mast")
    sz = mz + 6.8
    with b.joint("sensor", (0.0, y, sz), axis="yaw", limits=(-80.0, 80.0)):
        with b.joint("eye", (0.0, y, sz), axis="pitch", limits=(-30.0, 20.0)):
            BALL = [(-4.2, 1.0), (-3.2, 2.6), (-1.0, 3.4), (1.2, 2.8), (2.2, 1.8)]   # (y off the mast, radius)
            b.loft([(y + dy, _oct(sz, 2.0 * r, 2.0 * r, 0.0, 10)) for (dy, r) in BALL], "steel.plate", "sensor_ball")
            b.prism("y", 0.0, y + 2.5, sz, 1.9, 0.8, "glass.glass", 10, "lens")
            b.prism("y", 0.0, y + 2.95, sz, 0.95, 0.6, "amber.lit", 10, "fovea")
            for s in (-1.0, 1.0):
                b.box(s * 3.2 - 0.4, s * 3.2 + 0.4, y - 1.6, y + 1.6, sz - 1.0, sz + 1.0, "steel.dark", "sensor_cheek")


def _nt_wings(b, wy, belly_y, belly_z):
    """The stub wings, straight and short, centred on the pivot line `wy`, and on each tip a
    booster nacelle standing upright on a pivot drum (its intake up, its exhaust lit
    underneath); the mounts under the stubs, the third bare under the belly at `belly_y`."""
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 4.0, wy + 6.5, wy - 6.5, 0.4, 1.1), _blade_section(s * 24.0, wy + 4.5, wy - 4.5, -0.4, 0.8)], "livery.livery", "stub_wing")
        b.prism("x", s * 25.0, wy, -0.4, 3.0, 3.0, "steel.dark", 8, "nacelle_root", phase=math.pi / 8)
        nx, ny, nz = s * 28.0, wy, -0.4
        with b.joint("nacelle_" + side, (nx, ny, nz), axis="pitch", limits=(-95.0, 22.0)):
            b.prism("z", nx, ny, nz - 2.5, 4.4, 17.0, "steel.dark", 6, "nacelle", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 8.0, 4.7, 6.0, "steel.plate", 6, "nacelle_cowl", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 1.5, 4.6, 3.0, "livery.livery", 6, "nacelle_band", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 11.4, 5.1, 1.0, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
            _disc(b, (nx, ny, nz + 11.95), (0.0, 0.0, 1.0), 4.3, 6, "bore.dark", "intake", phase=math.pi / 6)
            b.prism("z", nx, ny, nz - 11.6, 4.9, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
            _disc(b, (nx, ny, nz - 12.5), (0.0, 0.0, -1.0), 4.5, 6, "amber.exhaust", "exhaust", phase=math.pi / 6)
        b.box(s * 12.5 - 0.7, s * 12.5 + 0.7, wy - 2.5, wy + 7.5, -2.2, -0.6, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 12.5, wy + 6.5, -3.0), "barrel" if s < 0 else "dish", scale=0.5)
    b.pad("hp_3", (0.0, belly_y, belly_z), scale=0.5, size=(4.0, 1.2))


def _nt_xtail(b, root, tip, z0=0.1):
    """Four small cobalt fins in an X: `root` and `tip` are (radius, y_le, y_te)."""
    for k in range(4):
        a = math.radians(45.0 + 90.0 * k)
        dx, dz = math.cos(a), math.sin(a)
        tx, tz = -dz * 0.25, dx * 0.25

        def sec(rad, y_le, y_te, dx=dx, dz=dz, tx=tx, tz=tz):
            ym = y_le - (y_le - y_te) * 0.35
            cx, cz = dx * rad, z0 + dz * rad
            return [(cx, y_te, cz), (cx + tx, ym, cz + tz), (cx, y_le, cz), (cx - tx, ym, cz - tz)]
        _rings(b, [sec(*root), sec(*tip)], "livery.livery", "tail_fin")


def _nt_motion(b):
    """The first cut's acts and movement (models_low.needletail), so the looks pose alike."""
    boosters = ["booster_ring", "exhaust"]
    b.act("transition", 5.2, {
        "nacelle_l": [(0.4, 0.0), (1.4, -88.0), (3.2, -88.0), (4.2, 0.0)],
        "nacelle_r": [(0.4, 0.0), (1.4, -88.0), (3.2, -88.0), (4.2, 0.0)],
    }, body=[(0.6, 0.0, 0.0, 0.0), (1.4, 0.0, 8.0, -1.0, 0.0, -6.0, 0.0), (2.4, 0.0, 14.0, -0.5, 0.0, -5.0, 0.0), (3.2, 0.0, 12.0, 0.5, 0.0, 2.0, 0.0),
             (4.0, 0.0, 4.0, 1.0, 0.0, 6.0, 0.0), (5.2, 0.0, 0.0, 0.0)],
       glow=[(boosters, [(0.3, 0.0), (0.9, 6.0), (3.2, 6.0), (4.0, 1.0), (4.8, 0.0)])])
    b.act("designate", 5.6, {
        "sensor": [(0.5, 0.0), (1.6, 42.0), (3.6, 42.0), (4.6, 0.0)],
        "eye": [(1.2, 0.0), (1.8, -14.0), (3.6, -14.0), (4.4, 0.0)],
    }, body=[(1.0, 0.0, 0.0, 0.0), (1.8, 0.0, -2.0, 0.5, 8.0, -2.0, 0.0), (3.6, 0.0, -2.0, 0.5, 8.0, -2.0, 0.0), (4.8, 0.0, 0.0, 0.0)],
       glow=[(["fovea"], [(1.6, 0.0), (1.9, 9.0), (2.1, 3.0), (2.4, 12.0), (3.6, 12.0), (4.2, 0.0)])])
    glow = {"parts": boosters, "k": 5.0}
    b.gait_option("hover", tracks={"nacelle_l": [(0.0, -12.0), (1.0, -12.0)], "nacelle_r": [(0.0, -12.0), (1.0, -12.0)]}, glow=glow)
    b.gait(tracks={"nacelle_l": [(0.0, -86.0), (1.0, -86.0)], "nacelle_r": [(0.0, -86.0), (1.0, -86.0)]}, glow=glow,
           body_hold=(0.0, 0.0, 0.0, 0.0, -4.0, 0.0), start=("hover", 0.25, 0.85))
    b.move(slide=0.35, bank=32.0, accel=0.7, heft=0.1, oversteer=0.4)


def ktlook_needle_cg(b):
    """The first cut with its stub wings and nacelles moved forward to the centre of mass (Ryan:
    "I think the wings need to be moved up to the center of mass"), so it hangs level on its
    boosters: the pivot line 13 forward, beside the canopy's back half; everything else as built."""
    FUSE = [(46.0, 1.2, 0.5, 0.5), (38.0, 6.0, 2.6, 2.4), (28.0, 11.0, 4.4, 4.0), (14.0, 13.0, 5.0, 4.6), (0.0, 12.0, 5.0, 4.4),
            (-12.0, 8.0, 4.0, 3.4), (-22.0, 4.4, 2.4, 2.2), (-30.0, 3.2, 1.8, 1.6), (-58.0, 2.2, 1.2, 1.0)]   # (y, w, top, bottom)
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    b.loft([(38.0, diamond(0.0, 0.0, 2.0, 1.8)), (47.0, diamond(0.0, 0.0, 0.8, 0.6))], "steel.dark", "nose_tip")
    b.loft([(-57.0, diamond(0.0, 0.1, 2.0, 1.8)), (-75.0, diamond(0.0, 0.1, 0.3, 0.3))], "steel.dark", "needle")
    _canopy(b, FUSE, [(33.0, 1.2, 0.8), (28.0, 2.8, 3.2), (20.0, 3.2, 4.0), (12.0, 3.0, 3.4), (6.0, 2.0, 1.4)], 20.4)
    _nt_sensor(b, -4.0, _top(FUSE, -4.0))
    _nt_wings(b, 7.5, -12.0, -3.4)
    _nt_xtail(b, (0.8, -48.0, -58.0), (7.5, -55.0, -60.0))
    _nt_motion(b)

ktlook_needle_cg.maker = KT


def ktlook_needle_flip(b):
    """Flipped into the classic starfighter's layout (Ryan: "with a very extended thin nosecone,
    and aft-mounted cockpit"): the needle is the nose now, long and thin with a banded collar
    and a dark tip; the body's weight sits aft, so the stub wings and their upright nacelles
    stand on the centre of mass a little behind the middle; the canopy rides aft of them; the
    Fovea Designator's mast stands on the spine ahead of the wings, looking down the nose; the
    X tail on a short tail cone that still ends in a needle."""
    FUSE = [(40.0, 3.4, 1.7, 1.6), (30.0, 6.4, 2.8, 2.6), (16.0, 10.0, 4.0, 3.6), (2.0, 12.6, 4.8, 4.2), (-10.0, 13.4, 5.2, 4.4),
            (-22.0, 11.6, 4.8, 4.0), (-32.0, 7.6, 3.4, 2.8), (-40.0, 3.4, 1.8, 1.6)]   # (y, w, top, bottom)
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    NOSE = [(39.0, 3.4, 1.7, 1.6), (52.0, 2.5, 1.2, 1.2), (66.0, 1.8, 0.85, 0.85), (80.0, 1.2, 0.55, 0.55)]
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in NOSE], "steel.plate", "nose_cone")
    b.loft([(56.0, _fuse(2.7, 1.3, 1.3)), (59.0, _fuse(2.6, 1.25, 1.25))], "livery.livery", "nose_band")
    b.loft([(79.5, diamond(0.0, 0.0, 1.3, 1.1)), (92.0, diamond(0.0, 0.0, 0.2, 0.2))], "steel.dark", "nose_tip")
    b.loft([(-39.5, diamond(0.0, 0.1, 2.4, 2.2)), (-50.0, diamond(0.0, 0.1, 0.3, 0.3))], "steel.dark", "needle")
    _canopy(b, FUSE, [(-4.0, 1.2, 0.8), (-8.0, 2.8, 3.2), (-15.0, 3.2, 4.0), (-22.0, 3.0, 3.4), (-27.0, 2.0, 1.4)], -14.6)
    _nt_sensor(b, 15.0, _top(FUSE, 15.0))
    _nt_wings(b, -2.0, -18.0, -4.6)
    _nt_xtail(b, (0.8, -29.0, -39.0), (8.0, -35.0, -41.0))
    _nt_motion(b)

ktlook_needle_flip.maker = KT


# ---------------------------------------------------------------- the Skua

def _gull_rings(xs, ys_le, ys_te, zs, ts):
    return [_blade_section(x, yl, yt, z, t) for (x, yl, yt, z, t) in zip(xs, ys_le, ys_te, zs, ts)]


def ktlook_skua_jaeger(b):
    """The Skua after the bird, not the F-14: a jaeger, the pirate gull that chases other birds
    down for what they carry. A stocky body with a hooked, drooping nose; one big Kestrel
    booster astern; gull wings cranked at the wrist, the inner arm rising from the shoulder and
    fixed, the outer hand long and pointed with the bird's white flash at its root, and the hand
    is what swings: it sweeps back about the wrist for the dive (joints wing_l, wing_r), so
    spread it is a seabird and swept a stooping arrow; a single raked fin; and the jaeger's two
    long central tail streamers past the booster. Every weapon strikes twice, so the Flechette
    Pod (fixed) is a pair of pods side by side on the spine, their honeycomb faces forward."""
    FUSE = [(30.0, 7.2, 3.4, 3.4), (20.0, 10.6, 4.6, 4.2), (6.0, 12.4, 5.2, 4.6), (-8.0, 12.0, 5.2, 4.6),
            (-20.0, 10.4, 4.8, 4.4), (-28.0, 9.0, 4.6, 4.4)]   # (y, w, top, bottom)
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    # The hooked nose: each section a little lower toward the tip, so the bill droops.
    BILL = [(30.0, 7.2, 3.4, 3.4, 0.0), (38.0, 5.6, 2.6, 2.6, -0.4), (45.0, 3.8, 1.8, 1.8, -1.2), (50.0, 2.2, 1.0, 1.0, -2.2), (53.0, 0.9, 0.4, 0.4, -3.2)]
    b.loft([(y, [(x, z + dz) for (x, z) in _fuse(w, t, bt)]) for (y, w, t, bt, dz) in BILL], "steel.plate", "bill")
    b.loft([(49.0, [(x, z - 2.0) for (x, z) in diamond(0.0, 0.0, 2.4, 2.2)]), (55.5, [(x, z - 3.9) for (x, z) in diamond(0.0, 0.0, 0.4, 0.4)])], "steel.dark", "bill_tip")
    _canopy(b, FUSE + [(-40.0, 8.0, 4.0, 4.0)], [(28.0, 1.0, 0.6), (24.0, 2.6, 2.8), (17.0, 3.0, 3.6), (10.0, 2.6, 2.8), (6.0, 1.4, 1.0)], 17.0)
    # One big booster astern, the body flowing into its drum; its ring and exhaust lit.
    b.prism("y", 0.0, -38.0, 0.4, 7.4, 22.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    b.prism("y", 0.0, -26.6, 0.4, 7.9, 1.2, "steel.plate", 6, "booster_lip", phase=math.pi / 6)
    b.prism("y", 0.0, -48.0, 0.4, 7.9, 2.4, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(-49.2, _hexr(0.0, 0.4, 7.8)), (-49.8, _hexr(0.0, 0.4, 7.0))], "amber.exhaust", "exhaust")
    for s in (-1.0, 1.0):
        # Cheek intakes ahead of the wing roots.
        b.loft([(14.0, rect(s * 6.6, 2.4, -2.6, 2.0)), (6.0, rect(s * 6.8, 2.8, -2.8, 2.4))], "steel.dark", "intake_cheek")
        b.box(s * 6.6 - 1.0, s * 6.6 + 1.0, 14.0, 14.4, -2.4, 1.8, "bore.dark", "intake")
    # The gull wings: the arm fixed, rising from the shoulder to the wrist; the hand swinging
    # about the wrist, long and pointed, falling away, the white flash at its root.
    WX, WY, WZ = 21.0, 1.5, 7.4
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        # The arm reaches forward to the wrist, so the leading edge kinks there as a bird's does.
        _rings(b, [_blade_section(s * 5.0, 4.0, -12.0, 3.2, 1.2), _blade_section(s * 14.0, 6.6, -8.4, 5.8, 0.9),
                   _blade_section(s * (WX + 1.0), 8.2, -5.0, WZ, 0.8)], "livery.livery", "wing_arm")
        b.prism("z", s * WX, WY, WZ, 2.6, 2.8, "steel.dark", 8, "wrist", phase=math.pi / 8)
        with b.joint("wing_" + side, (s * WX, WY, WZ), axis="yaw", limits=(-6.0, 55.0) if s < 0 else (-55.0, 6.0)):
            _rings(b, [_blade_section(s * (WX - 0.5), 8.0, -4.9, WZ, 0.8), _blade_section(s * (WX + 8.0), 5.2, -5.4, WZ - 0.7, 0.65)], "bone.bone", "wing_flash")
            _rings(b, [_blade_section(s * (WX + 8.0), 5.2, -5.4, WZ - 0.7, 0.65), _blade_section(s * (WX + 20.0), -0.4, -6.8, WZ - 2.0, 0.45),
                       _blade_section(s * (WX + 31.0), -7.6, -9.0, WZ - 3.4, 0.2)], "livery.livery", "wing_hand")
        # The tailplanes: short, swept wedges off the booster's flanks.
        _rings(b, [_blade_section(s * 7.0, -36.0, -47.0, 1.0, 0.5), _blade_section(s * 17.0, -44.0, -49.0, 0.6, 0.25)], "livery.livery", "stabiliser")
        # The streamers: the jaeger's two long central tail feathers, thin and dark, past the
        # booster's mouth, a little apart.
        _rings(b, [[(s * 1.6 - 1.0, -40.0, 8.2), (s * 1.6, -40.0, 8.6), (s * 1.6 + 1.0, -40.0, 8.2), (s * 1.6, -40.0, 7.8)],
                   [(s * 2.6 - 0.8, -54.0, 7.0), (s * 2.6, -54.0, 7.3), (s * 2.6 + 0.8, -54.0, 7.0), (s * 2.6, -54.0, 6.7)],
                   [(s * 3.4 - 0.05, -68.0, 6.0), (s * 3.4, -68.0, 6.05), (s * 3.4 + 0.05, -68.0, 6.0), (s * 3.4, -68.0, 5.95)]], "livery.livery", "streamer")
        b.box(s * 1.4 - 0.6, s * 1.4 + 0.6, -41.0, -30.0, 4.8, 8.4, "steel.plate", "streamer_root")
    # The single raked fin on the spine ahead of the booster.
    _rings(b, [_fin_section(0.0, -16.0, -34.0, 4.8, 0.7), _fin_section(0.0, -29.0, -38.0, 17.0, 0.3)], "livery.livery", "fin")
    # The Flechette Pod (fixed): two pods side by side on the spine behind the canopy, their
    # honeycomb faces forward, each in a dark collar the run lights.
    for s in (-1.0, 1.0):
        px = s * 3.0
        b.loft([(-12.0, rect(px, 1.8, 4.6, 6.8)), (-6.0, rect(px, 3.4, 4.8, 8.6)), (4.0, rect(px, 3.4, 4.8, 8.6))], "steel.panel", "flechette_pod")
        _missile_face(b, (px - 1.7, 4.1, 4.8), (0.0, 0.0, 1.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), 3.4, "flechette_face")
        for (x0, x1, z0, z1) in ((px - 2.1, px + 2.1, 8.5, 9.0), (px - 2.1, px + 2.1, 4.4, 4.9)):
            b.box(x0, x1, 3.8, 4.6, z0, z1, "amber.ember", "pod_collar")
    # The mounts under the arms; the third bare under the belly.
    for s in (-1.0, 1.0):
        b.box(s * 12.0 - 0.7, s * 12.0 + 0.7, -6.0, 3.0, 1.0, 3.8, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 12.0, 3.0, 0.4), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    b.pad("hp_3", (0.0, -10.0, -5.0), scale=0.5, size=(5.0, 1.4))
    boosters = ["booster_ring", "exhaust"]
    # The stoop: the hands sweep back about the wrists and it dives, the pods firing twice.
    b.act("stoop", 4.4, {
        "wing_l": [(0.3, 0.0), (0.9, 50.0), (3.0, 50.0), (3.8, 0.0)],
        "wing_r": [(0.3, 0.0), (0.9, -50.0), (3.0, -50.0), (3.8, 0.0)],
    }, body=[(0.4, 0.0, 0.0, 0.0), (1.1, 0.0, 10.0, -2.5, 0.0, -9.0, 0.0), (1.9, 0.0, 16.0, -3.5, 0.0, -10.0, 0.0), (2.6, 0.0, 18.0, 1.0, 0.0, 8.0, 0.0),
             (3.3, 0.0, 8.0, 2.0, 0.0, 4.0, 0.0), (4.4, 0.0, 0.0, 0.0)],
       glow=[(["pod_collar"], [(1.2, 0.0), (1.3, 16.0), (1.45, 1.0), (1.6, 16.0), (1.75, 1.0), (2.1, 0.0)]),
             (boosters, [(0.4, 0.0), (0.9, 7.0), (2.6, 7.0), (3.4, 0.0)])])
    glow = {"parts": boosters, "k": 5.0}
    b.gait_option("spread", tracks={"wing_l": [(0.0, 4.0), (1.0, 4.0)], "wing_r": [(0.0, -4.0), (1.0, -4.0)]}, glow=glow)
    b.gait(tracks={"wing_l": [(0.0, 46.0), (1.0, 46.0)], "wing_r": [(0.0, -46.0), (1.0, -46.0)]}, glow=glow,
           body_hold=(0.0, 0.0, 0.0, 0.0, -6.0, 0.0), start=("spread", 0.25, 0.85))
    b.move(slide=0.5, bank=44.0, accel=0.7, heft=0.08, oversteer=0.3)

ktlook_skua_jaeger.maker = KT


def ktlook_skua_oblique(b):
    """The wild card: one straight wing in a single piece on a pivot drum on the spine, which
    slews as a whole (the oblique wing; NASA's AD-1 is the homage), so at rest it is a cross and
    on the run a slash across the body, one tip forward and the other back. A slim body on one
    big booster, a canopy forward, a T-tail; the Flechette Pod's twin pods ride the pivot drum
    and slew with the wing."""
    FUSE = [(52.0, 1.0, 0.5, 0.5), (44.0, 5.0, 2.2, 2.0), (32.0, 8.6, 3.8, 3.4), (16.0, 10.4, 4.6, 4.0), (0.0, 10.6, 4.8, 4.2),
            (-16.0, 9.6, 4.4, 4.0), (-26.0, 8.8, 4.2, 4.0)]   # (y, w, top, bottom)
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    b.loft([(44.0, diamond(0.0, 0.0, 2.2, 2.0)), (55.0, diamond(0.0, 0.0, 0.4, 0.4))], "steel.dark", "nose_tip")
    _canopy(b, FUSE, [(40.0, 1.0, 0.6), (35.0, 2.4, 2.8), (28.0, 2.8, 3.4), (21.0, 2.4, 2.6), (17.0, 1.4, 1.0)], 28.0)
    b.prism("y", 0.0, -36.0, 0.2, 6.8, 22.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    b.prism("y", 0.0, -25.0, 0.2, 7.3, 1.2, "steel.plate", 6, "booster_lip", phase=math.pi / 6)
    b.prism("y", 0.0, -46.0, 0.2, 7.3, 2.4, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(-47.2, _hexr(0.0, 0.2, 7.2)), (-47.8, _hexr(0.0, 0.2, 6.4))], "amber.exhaust", "exhaust")
    # The T-tail: a fin on the booster's back and a tailplane across its top.
    _rings(b, [_fin_section(0.0, -24.0, -44.0, 6.0, 0.7), _fin_section(0.0, -36.0, -46.0, 19.0, 0.4)], "livery.livery", "fin")
    _rings(b, [_blade_section(-15.0, -40.0, -47.0, 19.0, 0.3), _blade_section(0.0, -35.0, -46.0, 19.4, 0.5), _blade_section(15.0, -40.0, -47.0, 19.0, 0.3)], "livery.livery", "tailplane")
    # The pivot drum on the spine and the wing in one piece across it, slewing as a whole.
    PZ = 6.2
    b.prism("z", 0.0, 2.0, PZ - 0.8, 6.0, 2.4, "steel.dark", 10, "pivot_drum")
    with b.joint("wing", (0.0, 2.0, PZ), axis="yaw", limits=(-60.0, 60.0)):
        _rings(b, [_blade_section(-54.0, 6.4, -1.6, PZ + 0.4, 0.3), _blade_section(-30.0, 8.6, -4.6, PZ + 0.8, 0.6),
                   _blade_section(-8.0, 10.0, -6.0, PZ + 1.0, 0.9), _blade_section(8.0, 10.0, -6.0, PZ + 1.0, 0.9),
                   _blade_section(30.0, 8.6, -4.6, PZ + 0.8, 0.6), _blade_section(54.0, 6.4, -1.6, PZ + 0.4, 0.3)], "livery.livery", "wing")
        for s in (-1.0, 1.0):
            _rings(b, [_blade_section(s * 18.0, 9.2, -5.4, PZ + 1.05, 0.75), _blade_section(s * 24.0, 8.9, -5.0, PZ + 0.95, 0.7)], "bone.bone", "wing_band")
            px = s * 3.4
            b.loft([(-5.0, rect(px, 2.0, PZ + 1.6, PZ + 3.6)), (0.0, rect(px, 3.6, PZ + 1.6, PZ + 5.2)), (9.0, rect(px, 3.6, PZ + 1.6, PZ + 5.2))], "steel.panel", "flechette_pod")
            _missile_face(b, (px - 1.8, 9.1, PZ + 1.6), (0.0, 0.0, 1.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), 3.6, "flechette_face")
            b.box(px - 2.2, px + 2.2, 8.8, 9.6, PZ + 5.1, PZ + 5.6, "amber.ember", "pod_collar")
    for s in (-1.0, 1.0):
        b.box(s * 5.6 - 0.7, s * 5.6 + 0.7, 4.0, 14.0, -4.2, -2.4, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 5.6, 13.0, -4.8), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    b.pad("hp_3", (0.0, -12.0, -4.6), scale=0.5, size=(5.0, 1.4))
    boosters = ["booster_ring", "exhaust"]
    b.act("slash", 4.4, {
        "wing": [(0.3, 0.0), (1.0, 50.0), (3.0, 50.0), (3.8, 0.0)],
    }, body=[(0.4, 0.0, 0.0, 0.0), (1.1, 0.0, 10.0, -2.5, 0.0, -9.0, -10.0), (1.9, 0.0, 16.0, -3.5, 0.0, -10.0, -8.0), (2.6, 0.0, 18.0, 1.0, 0.0, 8.0, 0.0),
             (3.3, 0.0, 8.0, 2.0, 0.0, 4.0, 0.0), (4.4, 0.0, 0.0, 0.0)],
       glow=[(["pod_collar"], [(1.2, 0.0), (1.3, 16.0), (1.45, 1.0), (1.6, 16.0), (1.75, 1.0), (2.1, 0.0)]),
             (boosters, [(0.4, 0.0), (0.9, 7.0), (2.6, 7.0), (3.4, 0.0)])])
    glow = {"parts": boosters, "k": 5.0}
    b.gait_option("square", tracks={"wing": [(0.0, 0.0), (1.0, 0.0)]}, glow=glow)
    b.gait(tracks={"wing": [(0.0, 45.0), (1.0, 45.0)]}, glow=glow, body_hold=(0.0, 0.0, 0.0, 0.0, -6.0, 0.0), start=("square", 0.25, 0.85))
    b.move(slide=0.5, bank=40.0, accel=0.7, heft=0.08, oversteer=0.3)

ktlook_skua_oblique.maker = KT


LOOKS = ["ktlook_needle_cg", "ktlook_needle_flip", "ktlook_skua_jaeger", "ktlook_skua_oblique"]

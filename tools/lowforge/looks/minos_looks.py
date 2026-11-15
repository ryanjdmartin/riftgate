"""A look test for Minos (the Arsenal, tier three, medium, hover; docs/briefs/arsenal_minos.md),
15 November, first round. Ryan, 12 October: "A backpack with short wings, digitigrade legs, a
corrupted Aile Strike Gundam or Evangelion frame", "hover movement", and "Two Gundams are fine,
since this is the stereotypical dark one and not the hero frame." Cues only, never a copy of any
one machine: the long thin limbs, the narrow waist and the hunch are the one's; the pack with its
two short wings and twin thrusters, and a V of a crest grown out into horns, the other's.

The figure: tall and thin, everything above the waist leaning forward on a bare spine; a keeled
chest like a bird's breastbone, its ribs lit red; narrow shoulders under blades swept back; the
head low and thrust forward, two slit eyes, the crest's horns uneven; the pack on its back with two
short swept wings, the left one broken off short, and twin thrusters blowing down and back; the
digitigrade legs hanging and trailing under it, since it never walks, a hoverjet at each hock; the
right arm hanging past the knee, the left raised with a gun along its forearm. Its kit is in
question (Ryan, 6 November), so the locked piece is a plain drum on the right forearm and nothing
more. Mounts: hp_1 and hp_2 on the wing roots either side of the pack, firing over the shoulders
(the proposal's Suppression Battery and Shotfire Rack as their class), hp_3 along the left forearm
(the Plasma Arquebus), hp_4 on the right hip (a pair, where the proposal's vent stood).

A second look, the same figure with the judge's tail (Dante's Minos sends each soul to its place by
coiling his tail): a segmented cable from the base of the spine, hanging and coiling forward under
the feet to a hook. Nobody asked for it; it is there to be struck or kept.

Not content: built only by build_look.py and sheet.py, x right, y forward, z up, as in
models_low.py. Hovers: the lowest claw at about z = 6.

Second round, the same day, on Ryan's notes ("Minos is actually pretty close to what I thought. No
tail. Maybe bump up the wings so it's more obvious in the silhouette"): the figure as it stood, no
tail, and the pack's wings grown (`_big_wing`): longer, deeper and cranked at mid-span, the outer
panel raked back to a narrow tip with two blades off its trailing edge, the left one still broken
short on the slant. Two sizes on the sheet, his to pick between or past."""

import math

from mathutils import Matrix, Vector

from bl_low import rect
from models_low import _beam, _poly, _rings, _slab, _spike, _sq, _wing

AR = "arsenal"
TILT = 19.0                  # the hunch: everything above the waist leans this far forward
WAIST = (0.0, -2.0, 62.0)    # where it bends
LEAN = Matrix.Translation(Vector(WAIST)) @ Matrix.Rotation(-math.radians(TILT), 4, "X") @ Matrix.Translation(-Vector(WAIST))

# The chest's sections up its height: (z, width, y of the back, y of the flanks' front edge, y of the keel).
CHEST = [(76.0, 11.0, -7.0, 1.0, 5.0), (84.0, 19.0, -9.0, 3.0, 10.0), (94.0, 33.0, -10.0, 4.0, 14.0), (100.0, 27.0, -9.0, 1.0, 7.0)]


def _tp(p):
    """A point of the upright upper body, where the hunch carries it."""
    v = LEAN @ Vector(p)
    return (v.x, v.y, v.z)


def _add(p, d):
    return (p[0] + d[0], p[1] + d[1], p[2] + d[2])


def _lerp(a, c, t):
    return tuple(a[i] + (c[i] - a[i]) * t for i in range(len(a)))


def _chest_at(z):
    for lo, hi in zip(CHEST, CHEST[1:]):
        if lo[0] <= z <= hi[0]:
            return _lerp(lo, hi, (z - lo[0]) / (hi[0] - lo[0]))
    return CHEST[-1]


def _jet(b, at, r, length, pitch, label, lean=None, sides=8):
    """A thruster: built along -y with its mouth at the far end, so the mouth wears the exhaust
    tile fitted whole, then pitched (90 blows straight down) and set at `at`, its root there."""
    start = len(b.objects)
    ring = lambda rr: [(rr * math.cos(math.pi / sides + i * 2.0 * math.pi / sides), rr * math.sin(math.pi / sides + i * 2.0 * math.pi / sides)) for i in range(sides)]
    b.loft([(-length, ring(r)), (-length * 0.4, ring(r * 0.78)), (0.0, ring(r * 0.5))], "steel.dark", label)
    b.loft([(-length - 0.8, ring(r * 1.1)), (-length + 0.9, ring(r * 1.1))], "amber.engine", label + "_ring")
    b.loft([(-length - 0.95, ring(r * 0.9)), (-length - 0.6, ring(r * 0.9))], "amber.exhaust", label + "_mouth")
    m = Matrix.Translation(Vector(at)) @ Matrix.Rotation(math.radians(pitch), 4, "X")
    if lean is not None:
        m = lean @ m
    for ob in b.objects[start:]:
        ob.matrix_world = m @ ob.matrix_world


def _leg(b, s):
    """A digitigrade leg that carries nothing: hanging from the hip, the thigh forward, the shin
    trailing back to the hock, the long foot down to three limp claws; a hoverjet behind the hock."""
    hip = (s * 8.0, -3.0, 58.0)
    knee = (s * 10.5, 9.0, 41.0)
    hock = (s * 10.5, -10.0, 27.0)
    ball = (s * 10.5, -5.0, 12.5)
    b.prism("x", s * 9.5, hip[1], hip[2], 4.6, 6.0, "steel.dark", 8, "hip")
    _beam(b, hip, knee, _sq(5.6, 7.0), _sq(4.6, 5.4), "steel.panel", "thigh")
    n = (0.0, 0.82, 0.58)   # square to the thigh, forward and up
    _beam(b, _add(_lerp(hip, knee, 0.12), (0.0, n[1] * 4.4, n[2] * 4.4)), _add(_lerp(hip, knee, 1.08), (0.0, n[1] * 3.8, n[2] * 3.8)),
          _sq(7.5, 2.0), _sq(5.5, 1.8), "steel.plate", "cuisse")
    _beam(b, _add(_lerp(hip, knee, 0.25), (0.0, n[1] * 5.5, n[2] * 5.5)), _add(_lerp(hip, knee, 0.92), (0.0, n[1] * 4.8, n[2] * 4.8)),
          _sq(1.2, 0.6), _sq(1.0, 0.6), "glass.glass", "cuisse_seam")
    b.prism("x", knee[0], knee[1], knee[2], 3.6, 7.0, "steel.dark", 8, "knee")
    _spike(b, (knee[0], knee[1] + 2.0, knee[2] + 1.0), (knee[0], knee[1] + 13.0, knee[2] + 6.0), 1.8, "steel.dark", "knee_spike")
    _beam(b, knee, hock, _sq(4.0, 4.6), _sq(3.2, 3.8), "steel.panel", "shin")
    back = (0.0, -0.59, 0.80)   # square to the shin, back and up
    _beam(b, _add(_lerp(knee, hock, 0.1), (0.0, back[1] * 4.2, back[2] * 4.2)), _add(_lerp(knee, hock, 0.85), (0.0, back[1] * 2.6, back[2] * 2.6)),
          _sq(1.6, 6.5), _sq(1.2, 2.4), "steel.plate", "calf_fin")
    b.prism("x", hock[0], hock[1], hock[2], 3.2, 6.5, "steel.dark", 8, "hock")
    _jet(b, (hock[0], hock[1] - 3.0, hock[2] + 1.0), 3.8, 7.5, 62.0, "hoverjet")
    _beam(b, hock, ball, _sq(3.8, 4.4), _sq(3.0, 3.4), "steel.panel", "metatarsus")
    b.prism("x", ball[0], ball[1], ball[2], 2.4, 5.0, "steel.dark", 6, "ball")
    for dx, dy, dz in ((-2.4, 6.5, -6.0), (2.4, 6.5, -6.0), (0.0, -5.0, -4.6)):
        _spike(b, ball, _add(ball, (dx, dy, dz)), 1.3, "steel.dark", "claw")


def _arm(b, s, shoulder, elbow, wrist, grip):
    """A long thin arm: a rod of an upper arm, an elbow with a spur, a heavier vambrace, three claws
    hanging `grip` from the wrist."""
    _beam(b, shoulder, elbow, _sq(5.0, 5.4), _sq(4.0, 4.4), "steel.panel", "upper_arm")
    b.prism("x", elbow[0], elbow[1], elbow[2], 3.4, 6.5, "steel.dark", 8, "elbow")
    _spike(b, elbow, _add(elbow, (s * 1.5, -10.0, 3.5)), 1.6, "steel.dark", "elbow_spur")
    _beam(b, elbow, wrist, _sq(6.2, 7.0), _sq(7.6, 8.4), "steel.plate", "forearm")
    b.prism("x", wrist[0], wrist[1], wrist[2], 2.8, 8.6, "steel.dark", 6, "wrist")
    for dx in (-3.0, 0.0, 3.0):
        _spike(b, _add(wrist, (dx, 0.0, 0.0)), _add(wrist, (dx * 1.3 + grip[0], grip[1], grip[2])), 1.45, "steel.dark", "finger")


def _tail(b):
    """The judge's tail: a segmented cable from the base of the spine, down behind the legs and
    coiling forward under the feet to a hook."""
    pts = [(0.0, -8.0, 56.0), (1.0, -17.0, 52.0), (3.0, -24.0, 44.0), (5.0, -27.5, 34.0), (6.0, -25.5, 24.0),
           (5.0, -19.5, 15.5), (3.0, -10.5, 10.5), (0.0, -1.5, 9.0), (-2.5, 6.5, 11.5)]
    for k, (p0, p1) in enumerate(zip(pts, pts[1:])):
        r0, r1 = 3.9 - k * 0.32, 3.9 - (k + 1) * 0.32
        _beam(b, p0, p1, _poly(r0, 6), _poly(r1 * 0.92, 6), "steel.dark" if k % 2 else "steel.panel", "tail")
        if k:
            _beam(b, _lerp(p0, p1, -0.06), _lerp(p0, p1, 0.06), _poly(r0 + 0.9, 6), _poly(r0 + 0.9, 6), "steel.plate", "tail_collar")
    tip = pts[-1]
    _spike(b, tip, _add(tip, (-1.5, 4.5, 9.0)), 1.8, "steel.dark", "tail_hook")
    _spike(b, _add(tip, (-0.6, 1.5, 2.5)), _add(tip, (-1.0, -4.0, 6.0)), 1.1, "steel.dark", "tail_barb")


def _big_wing(b, s, whole, span, chord):
    """Round two's wing: round one's swept wing off the pack, `span` times as long and `chord` times
    as deep, cranked at mid-span so the outer panel rakes back to a narrow tip. The left one
    (`whole` false) is still broken short, cut on the slant across its outer panel."""
    CRANK = 0.5
    keys = [  # (t along the span, x out from the pack, the leading edge's y, the chord, the top's z, the thickness)
        (0.0, 9.0, -6.5, 16.0 * chord, 97.2, 2.8),
        (CRANK, 9.0 + 35.0 * span * CRANK, -6.5 - 6.0 * span, 12.0 * chord, 97.2 + 7.5 * span, 2.0),
        (1.0, 9.0 + 35.0 * span, -6.5 - 24.0 * span, 4.5 * chord, 97.2 + 13.0 * span, 1.1),
    ]

    def at(t):
        lo, hi = (keys[0], keys[1]) if t <= CRANK else (keys[1], keys[2])
        return _lerp(lo, hi, (t - lo[0]) / (hi[0] - lo[0]))

    def lead(t, top=True):
        _, x, y, _c, z, th = at(t)
        return (s * x, y, z if top else z - th)

    def trail(t, top=True):
        _, x, y, c, z, th = at(t)
        return (s * x, y - c, (z - 1.2 if top else z - 1.2 - th))

    def section(tl, tt):
        return [lead(tl), trail(tt), trail(tt, False), lead(tl, False)]

    # The panels: the inner one whole; the outer to its tip, or to the break (further out along the
    # leading edge than the trailing one, so the stump ends on a slant).
    ends = (1.0, 1.0) if whole else (0.86, 0.66)
    for (l0, t0), (l1, t1) in (((0.0, 0.0), (CRANK, CRANK)), ((CRANK, CRANK), ends)):
        _wing(b, section(l0, t0), section(l1, t1), "steel.plate", "wing")
        # A dark leading edge, and a seam along the top lit like a crack.
        _beam(b, _add(lead(l0), (0.0, 0.7, -1.3)), _add(lead(l1), (0.0, 0.7, -0.7)), _sq(1.8, 3.6), _sq(1.5, 2.2), "steel.dark", "wing_edge")
        a0, a1 = _lerp(lead(l0), trail(t0), 0.42), _lerp(lead(l1), trail(t1), 0.42)
        _slab(b, [_add(_lerp(a0, a1, 0.06), (0.0, 0.9, 0.3)), _add(_lerp(a0, a1, 0.95), (0.0, 0.6, 0.3)),
                  _add(_lerp(a0, a1, 0.95), (0.0, -0.6, 0.3)), _add(_lerp(a0, a1, 0.06), (0.0, -0.9, 0.3))], (0.0, 0.0, 1.0), 0.5, "glass.glass", "wing_seam")
    if whole:
        # Two blades off the outer panel's trailing edge, raked back and out, so the wing ends in points.
        for t, reach in ((0.68, 9.0), (0.86, 7.0)):
            base = _add(_lerp(trail(t), lead(t), 0.12), (0.0, 0.0, -0.6))
            _spike(b, base, _add(base, (s * reach * 0.35 * span, -reach * span, 1.0)), 1.5, "steel.dark", "wing_blade")
    else:
        _slab(b, [_add(q, (s * 0.35, 0.0, 0.0)) for q in section(*ends)], (s * 0.82, 0.57, 0.0), 0.6, "glass.glass", "wing_break")


def _minos(b, tail=False, wings=None):
    # The legs and the pelvis they hang from, upright: only what is above the waist leans.
    for s in (-1.0, 1.0):
        _leg(b, s)
    b.box(-7.0, 7.0, -7.5, 2.5, 55.0, 62.0, "steel.dark", "pelvis")
    b.loft([(3.0, rect(0.0, 8.0, 53.0, 61.0)), (8.5, rect(0.0, 3.0, 51.0, 57.0))], "steel.plate", "pelvis_prow")
    for s in (-1.0, 1.0):
        _slab(b, [(s * 8.6, -6.0, 62.5), (s * 8.6, 4.0, 62.5), (s * 11.5, 2.5, 50.0), (s * 11.5, -4.0, 52.0)], (s, 0.0, 0.22), 1.4, "steel.plate", "tasset")
    # hp_4, the right hip: a block on the pelvis's flank and a pair off it, level.
    b.box(9.0, 15.5, -4.5, 3.5, 55.0, 61.0, "steel.plate", "hip_mount")
    b.stock("hp_4", (12.5, 4.0, 58.0), "twin_barrel", scale=0.55, carries="twin_autoguns")
    if tail:
        _tail(b)

    # Everything above the waist, built upright and then leant forward as one.
    start = len(b.objects)
    # The spine bare at the waist: four vertebrae with the red showing between them, a strut either side.
    for k in range(4):
        z0 = 62.4 + k * 4.0
        b.prism("z", 0.0, -3.0, z0 + 1.5, 4.3 - 0.2 * k, 3.0, "steel.dark", 6, "vertebra")
        b.prism("z", 0.0, -3.0, z0 + 3.5, 2.9, 1.0, "glass.glass", 6, "spine_glow")
    for s in (-1.0, 1.0):
        _beam(b, (s * 4.6, 1.5, 62.0), (s * 6.4, 3.5, 78.5), _poly(1.25, 6), _poly(1.25, 6), "steel.plate", "strut")
    # The chest: narrow at the waist, wide at the shoulders, drawn forward to a keel.
    _rings(b, [[(-w / 2.0, yb, z), (w / 2.0, yb, z), (w / 2.0, ym, z), (0.0, yf, z), (-w / 2.0, ym, z)] for z, w, yb, ym, yf in CHEST], "steel.plate", "chest")
    for (z0, _, _, _, k0), (z1, _, _, _, k1) in zip(CHEST, CHEST[1:]):
        _beam(b, (0.0, k0 + 0.3, z0), (0.0, k1 + 0.3, z1), _sq(2.4, 1.8), _sq(2.4, 1.8), "steel.dark", "keel")
    # The ribs: three lit slits down each side of the keel.
    for s in (-1.0, 1.0):
        for zc in (80.5, 85.0, 89.5):
            quad = []
            for z, t in ((zc, 0.16), (zc, 0.86), (zc + 1.5, 0.86), (zc + 1.5, 0.16)):
                _, w, _, ym, yf = _chest_at(z)
                quad.append(_lerp((s * w / 2.0, ym, z), (0.0, yf, z), t))
            _, w, _, ym, yf = _chest_at(zc)
            nrm = Vector((s * (yf - ym), w / 2.0, 0.0)).normalized()
            _slab(b, [_add(p, tuple(nrm * 0.45)) for p in quad], tuple(nrm), 0.7, "glass.glass", "rib_glow")
    b.box(-6.0, 6.0, -6.0, 5.0, 99.0, 103.0, "steel.dark", "collar")
    # The shoulders: a ball each side under a blade swept up and back.
    for s in (-1.0, 1.0):
        b.prism("x", s * 20.0, -1.0, 95.0, 5.0, 8.0, "steel.dark", 8, "shoulder")
        _rings(b, [[(s * 15.0, -8.0, 97.5), (s * 26.5, -8.0, 96.0), (s * 26.5, 6.0, 96.0), (s * 15.0, 6.0, 97.5)],
                   [(s * 21.0, -15.0, 103.5), (s * 28.0, -15.0, 102.5), (s * 28.0, -4.0, 102.5), (s * 21.0, -4.0, 103.5)],
                   [(s * 27.0, -27.0, 109.5), (s * 28.2, -27.0, 109.5), (s * 28.2, -25.8, 109.5), (s * 27.0, -25.8, 109.5)]], "steel.panel", "pauldron")
        _slab(b, [(s * 28.2, -13.0, 101.6), (s * 28.2, -6.0, 101.6), (s * 27.2, 2.0, 97.4), (s * 27.2, -6.0, 97.4)], (s, 0.0, 0.2), 0.6, "glass.glass", "pauldron_glow")
    # The pack: a block on the back, a dark housing over it, a short swept wing off each side.
    b.loft([(-20.0, rect(0.0, 16.0, 82.0, 101.0)), (-9.0, rect(0.0, 20.0, 80.0, 100.0))], "steel.panel", "pack")
    ridge = lambda w, z0, z1: [(-w / 2.0, z0), (w / 2.0, z0), (w / 2.0, z1), (0.0, z1 + 2.6), (-w / 2.0, z1)]
    b.loft([(-21.0, ridge(12.0, 100.0, 101.6)), (-9.0, ridge(18.0, 99.5, 103.4))], "steel.dark", "pack_top")
    for z in (92.8, 95.4, 98.0):
        b.box(-6.0, 6.0, -20.9, -20.0, z, z + 1.3, "amber.fume", "pack_vent")
    for s in (-1.0, 1.0):
        whole = s > 0   # the left wing is broken off short
        if wings is not None:
            _big_wing(b, s, whole, *wings)
            b.box(min(s * 10.0, s * 18.0), max(s * 10.0, s * 18.0), -19.0, -9.0, 96.5, 99.0, "steel.dark", "rack_mount")
            continue
        root = [(s * 9.0, -6.5, 97.2), (s * 9.0, -22.5, 96.0), (s * 9.0, -22.5, 93.2), (s * 9.0, -6.5, 94.4)]
        if whole:
            tip = [(s * 44.0, -24.0, 109.4), (s * 44.0, -33.5, 108.8), (s * 44.0, -33.5, 107.4), (s * 44.0, -24.0, 108.0)]
        else:
            tip = [(s * 32.0, -18.0, 105.3), (s * 25.5, -28.5, 102.2), (s * 25.5, -28.5, 100.4), (s * 32.0, -18.0, 103.5)]
        _wing(b, root, tip, "steel.plate", "wing")
        # A dark leading edge, and a seam along the top lit like a crack.
        _beam(b, _add(root[0], (0.0, 0.6, -1.4)), _add(tip[0], (0.0, 0.6, -0.7)), _sq(1.6, 3.4), _sq(1.4, 2.0), "steel.dark", "wing_edge")
        a0, a1 = _lerp(root[0], root[1], 0.45), _lerp(tip[0], tip[1], 0.45)
        _slab(b, [_add(_lerp(a0, a1, 0.08), (0.0, 0.8, 0.25)), _add(_lerp(a0, a1, 0.94), (0.0, 0.5, 0.25)),
                  _add(_lerp(a0, a1, 0.94), (0.0, -0.5, 0.25)), _add(_lerp(a0, a1, 0.08), (0.0, -0.8, 0.25))], (0.0, 0.0, 1.0), 0.5, "glass.glass", "wing_seam")
        if not whole:
            _slab(b, [_add(p, (s * 0.35, 0.0, 0.0)) for p in tip], (s * 0.82, 0.57, 0.0), 0.6, "glass.glass", "wing_break")
        # The wing root's mount block, for hp_1 and hp_2.
        b.box(min(s * 10.0, s * 18.0), max(s * 10.0, s * 18.0), -19.0, -9.0, 96.5, 99.0, "steel.dark", "rack_mount")
    for ob in b.objects[start:]:
        ob.matrix_world = LEAN @ ob.matrix_world
    # The twin thrusters under the pack, blowing down and back.
    for s in (-1.0, 1.0):
        _jet(b, (s * 5.2, -19.0, 86.5), 5.6, 13.0, 48.0, "thruster", LEAN)
    # hp_1 and hp_2: a rack on each wing root, level over the shoulders.
    for s, n, carries in ((-1.0, 1, "suppression_battery"), (1.0, 2, "shotfire_rack")):
        b.stock("hp_%d" % n, _tp((s * 14.0, -13.0, 99.0)), "rack", scale=0.62, carries=carries)

    # The arms hang from the leant shoulders. The left raised, its forearm near level, the gun
    # along it (hp_3); the right hanging past the knee, the locked piece a plain drum on its forearm.
    sl, sr = _tp((-20.0, -1.0, 95.0)), _tp((20.0, -1.0, 95.0))
    el = _add(sl, (-4.0, -7.0, -24.0))
    wl = _add(el, (1.0, 24.0, -5.0))
    _arm(b, -1.0, sl, el, wl, (0.0, 10.0, -7.5))
    fwd = Vector(wl) - Vector(el)
    b.box(el[0] - 7.4, el[0] - 3.4, el[1] + 5.0, el[1] + 15.0, el[2] - 1.0, el[2] + 3.0, "steel.dark", "arm_mount")
    b.stock("hp_3", _add(_lerp(el, wl, 0.5), (-5.4, 0.0, 2.2)), "barrel", forward=tuple(fwd.normalized()), scale=0.6, carries="plasma_arquebus")
    er = _add(sr, (4.0, -5.0, -26.0))
    wr = _add(er, (-1.0, 9.0, -27.0))
    _arm(b, 1.0, sr, er, wr, (0.0, 4.0, -14.0))
    mid = _lerp(er, wr, 0.5)
    b.prism("x", mid[0] + 5.0, mid[1], mid[2], 5.6, 3.6, "steel.dark", 10, "drum")
    b.prism("x", mid[0] + 7.0, mid[1], mid[2], 2.6, 0.8, "glass.glass", 8, "drum_glow")

    # The head: low and thrust forward on a thin neck, looking down its own face. A narrow skull
    # tapering to a point, a brow over two slit eyes, a short jaw, and the crest grown into horns.
    root = (0.0, 19.0, 102.5)
    nod = Matrix.Translation(Vector(root)) @ Matrix.Rotation(-math.radians(9.0), 4, "X") @ Matrix.Translation(-Vector(root))
    hp = lambda p: tuple(nod @ Vector((p[0], p[1] + 2.0, p[2] + 2.0)))   # the head's points, set on its neck and nodded
    _beam(b, _tp((0.0, 1.0, 102.0)), root, _poly(2.6, 6), _poly(2.4, 6), "steel.dark", "neck")
    _rings(b, [[hp(p) for p in ring] for ring in (
        [(-4.8, 14.0, 97.5), (4.8, 14.0, 97.5), (4.8, 14.0, 106.0), (-4.8, 14.0, 106.0)],
        [(-4.4, 24.0, 98.0), (4.4, 24.0, 98.0), (4.4, 24.0, 105.5), (-4.4, 24.0, 105.5)],
        [(-1.4, 31.5, 98.6), (1.4, 31.5, 98.6), (1.4, 31.5, 100.4), (-1.4, 31.5, 100.4)])], "steel.plate", "skull")
    _rings(b, [[hp(p) for p in ring] for ring in (
        [(-5.6, 14.5, 105.6), (5.6, 14.5, 105.6), (5.6, 14.5, 107.6), (-5.6, 14.5, 107.6)],
        [(-4.4, 25.5, 104.6), (4.4, 25.5, 104.6), (4.4, 25.5, 106.0), (-4.4, 25.5, 106.0)])], "steel.panel", "brow")
    for s in (-1.0, 1.0):
        _slab(b, [hp(p) for p in ((s * 0.8, 25.8, 104.6), (s * 3.9, 25.8, 104.6), (s * 2.6, 29.6, 102.0), (s * 0.6, 29.6, 102.0))], tuple(nod.to_3x3() @ Vector((0.0, 0.56, 0.83))), 0.7, "glass.glass", "eye")
    _rings(b, [[hp(p) for p in ring] for ring in (
        [(-3.4, 16.0, 95.4), (3.4, 16.0, 95.4), (3.4, 16.0, 97.6), (-3.4, 16.0, 97.6)],
        [(-1.2, 29.0, 96.4), (1.2, 29.0, 96.4), (1.2, 29.0, 97.6), (-1.2, 29.0, 97.6)])], "steel.dark", "jaw")
    # The horns: a V from the brow, each kinked back; the right grown longer, with a second tine.
    brow = hp((0.0, 22.5, 106.0))
    for s, k1, k2 in ((-1.0, (-8.5, -6.0, 9.5), (-4.0, -12.0, 12.0)), (1.0, (9.0, -6.5, 10.0), (5.0, -14.5, 15.5))):
        base = _add(brow, (s * 1.6, 0.0, 0.0))
        kink = _add(base, k1)
        _beam(b, base, kink, _sq(3.2, 2.2), _sq(2.6, 1.8), "steel.dark", "horn")
        _spike(b, kink, _add(kink, k2), 1.45, "steel.dark", "horn_tip")
        if s > 0:
            _spike(b, _lerp(base, kink, 0.7), _add(_lerp(base, kink, 0.7), (4.5, 5.0, 6.5)), 0.9, "steel.dark", "horn_tine")

    # What burns: the thrusters and hoverjets hot, the red glass (the builder lights the Arsenal's) as it rests.
    hot = ["thruster_ring", "thruster_mouth", "hoverjet_ring", "hoverjet_mouth"]
    b.gait(glow={"parts": hot + ["pack_vent"], "k": 2.0}, body_hold=(0.0, 0.0, 0.0, 0.0, -4.0, 0.0), rock=3.0)
    b.halo = list(hot)
    b.standing = {"pack_vent": 5.0}
    b.move(slide=0.4, bank=0.0, accel=1.2, heft=0.18, oversteer=0.3)


def arlook_minos(b):
    """Minos as Ryan put it: the dark frame, the winged pack, the digitigrade legs, hovering."""
    _minos(b)


arlook_minos.maker = AR


def arlook_minos_tail(b):
    """The same figure with the judge's tail hanging and coiling under it."""
    _minos(b, tail=True)


arlook_minos_tail.maker = AR



def arlook_minos2(b):
    """Round two: no tail, the wings bumped up to half as long again and deeper."""
    _minos(b, wings=(1.5, 1.45))


arlook_minos2.maker = AR


def arlook_minos2_wide(b):
    """Round two, further: the wings at twice round one's span."""
    _minos(b, wings=(2.0, 1.7))


arlook_minos2_wide.maker = AR

LOOKS = ["arlook_minos", "arlook_minos_tail", "arlook_minos2", "arlook_minos2_wide"]

SHEET = {
    "title": "Minos, first round, 15 November (look tests, not content)",
    "out": "docs/looks/arsenal_minos.png",
    "cell": (320, 400),
    "rows": [
        {"model": "arlook_minos", "label": "Minos", "views": ["codex", "above", "skirmish", "front", ("from the side", 90.0, 8.0)]},
        {"model": "arlook_minos_tail", "label": "With the judge's tail", "views": ["codex", "skirmish", ("from the side", 90.0, 8.0)]},
    ],
}

_VIEWS2 = ["codex", "above", "skirmish", "front", ("from the side", 90.0, 8.0)]
SHEET2 = {
    "title": "Minos, second round, 15 November (look tests, not content)",
    "out": "docs/looks/arsenal_minos2.png",
    "cell": (320, 400),
    "rows": [
        {"model": "arlook_minos2", "label": "Wings bumped up", "views": _VIEWS2},
        {"model": "arlook_minos2_wide", "label": "Bumped up further", "views": _VIEWS2},
    ],
}

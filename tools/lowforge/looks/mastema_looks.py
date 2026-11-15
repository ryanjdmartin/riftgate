"""A look test for Mastema, the Arsenal's everything-burns flyer (Ryan, 12 October: "Ditch the
cauldron: a bat-winged flyer with arms is plenty of visual, no feet, a creepy hovering flying
thing"; the detail on his call is the brief's, docs/briefs/arsenal_mastema.md: a hunched torso and
a horned head with a long jaw, broad bat wings of black chrome panels ribbed in red glass that
tilt and vector and never flap, two long arms ending in claws, nothing below the ribs but a
tapering keel, boosters under the wing roots; the Stryge off its perch). First round, 15
November: one figure, its wings raised to hover, and the same figure with its wings levelled,
since they tilt. Its kit is unanswered, so nothing here is a locked piece: the open chest's
banked fire is a plain Arsenal cue, and the four mounts wear class shapes only to be judged
(hp_1 and hp_2 on the wing roots, hp_3 and hp_4 on the shoulders, as the brief proposed). Not
content: built only by build_look.py, x right, y forward, z up, as in models_low.py. It hovers:
the keel's tip and the claws hang a little above z = 0."""

import math

from mathutils import Matrix, Vector

from models_low import _beam, _deck, _rings, _slab, _spike, _sq, _tube

AR = "arsenal"


def _curve(b, pts, radii, material, label, n=4, phase=math.pi / 4.0):
    """A tapering limb through 3D points: an n-sided section at each, squared to the path."""
    pts = [Vector(p) for p in pts]
    ref = Vector((0.0, 0.0, 1.0))
    rings = []
    for i, p in enumerate(pts):
        d = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
        side = d.cross(ref)
        if side.length < 1e-4:
            side = Vector((1.0, 0.0, 0.0))
        side.normalize()
        up = side.cross(d).normalized()
        r = max(radii[i], 0.12)
        rings.append([p + side * (r * math.cos(phase + k * 2.0 * math.pi / n)) + up * (r * math.sin(phase + k * 2.0 * math.pi / n)) for k in range(n)])
    return _rings(b, rings, material, label)


def _wing_frame(s, origin, dih, sweep, tilt):
    """A wing's plane: (u out along the span, v toward the leading edge) to world, and its
    normal. `dih` raises the tip, `sweep` carries it back, `tilt` stands the leading edge up
    (0 lies the wing flat, 90 hangs it as a curtain)."""
    d, w, t = (math.radians(a) for a in (dih, sweep, tilt))
    U = Vector((s * math.cos(d) * math.cos(w), -math.sin(w), math.sin(d) * math.cos(w))).normalized()
    V = Vector((0.0, math.cos(t), math.sin(t)))
    V = (V - U * V.dot(U)).normalized()
    N = U.cross(V).normalized()
    O = Vector(origin)
    return (lambda p: O + U * p[0] + V * p[1]), N


def _bat_wing(b, s, origin, dih, sweep, tilt, k=1.0, sag=4.5):
    """One bat wing as a flat fan: a dark arm out to the wrist, four red glass fingers from it,
    black panels between them with the trailing edge scalloped from tip to tip, the last panel
    closing back to the body. Returns the plane's map, for a mount on the root."""
    P, N = _wing_frame(s, origin, dih, sweep, tilt)
    R, W = Vector((0.0, 0.0)), Vector((24.0, 12.0)) * k
    tips = [Vector(p) * k for p in ((78.0, 12.0), (74.0, -20.0), (56.0, -44.0), (30.0, -54.0))]
    B = Vector((3.0, -36.0)) * k

    def scallop(a, c, pull=0.22):
        m = (a + c) / 2.0
        return m + (W - m) * pull

    # Each panel is two facets meeting on a line from the wrist to its scallop, the scallop
    # billowed back off the wing's plane: a membrane's sag, and a break in a face that would
    # otherwise take the Arsenal's chrome glint whole.
    back = N if N.dot(Vector((0.0, -0.5, 0.86))) > 0.0 else -N
    spans = [(tips[0], tips[1], 0.22), (tips[1], tips[2], 0.22), (tips[2], tips[3], 0.22), (tips[3], B, 0.3)]
    for a, c, pull in spans:
        m = P(scallop(a, c, pull)) + back * sag * k
        for tri in ((P(W), P(a), m), (P(W), m, P(c))):
            n = (tri[1] - tri[0]).cross(tri[2] - tri[0]).normalized()
            _slab(b, list(tri), n, 0.9, "steel.dark", "wing_panel")
    _slab(b, [P(W), P(B), P(R)], N, 0.9, "steel.dark", "wing_panel")
    # The arm: root to wrist, bowed a little toward the leading edge, a knuckle and a thumb claw.
    elbow = (R + W) / 2.0 + Vector((-2.0, 3.0)) * k
    _curve(b, [P(R), P(elbow), P(W)], [4.2 * k, 3.4 * k, 3.0 * k], "steel.plate", "wing_arm", n=6, phase=0.0)
    _curve(b, [P(W) - N * 2.6 * k, P(W) + N * 2.6 * k], [3.6 * k, 3.6 * k], "steel.panel", "wing_wrist", n=6, phase=0.0)
    _spike(b, P(W), P(W + Vector((5.0, 13.0)) * k), 1.5 * k, "steel.dark", "wing_thumb")
    # The fingers: red glass, standing proud of the panels on both faces, a dark claw past each tip.
    for t in tips:
        _beam(b, P(W), P(t), _sq(2.2 * k, 2.2 * k), _sq(1.2 * k, 1.2 * k), "glass.glass", "wing_rib")
        out = (t - W).normalized()
        _spike(b, P(t - out * 1.0), P(t + out * 6.0 * k), 1.0 * k, "steel.dark", "wing_claw")
    _beam(b, P(R), P(B), _sq(1.8 * k, 1.8 * k), _sq(1.0 * k, 1.0 * k), "glass.glass", "wing_rib")
    return P, N


LIFT = 6.0   # how far the figure rides above the height it was first drawn at, the keel grown down to match


def _mastema(b, tilt, dih, sweep):
    # The torso leans forward on the keel's root: built upright in its own frame, hunched by the frame.
    lean = Matrix.Translation((0.0, -2.0, 38.0)) @ Matrix.Rotation(math.radians(-24.0), 4, "X")

    def L(x, y, z):
        return lean @ Vector((x, y, z))

    def ring(w, d, cy, z, c):
        return [lean @ Vector(p) for p in _deck(w, d, cy, z, c)]

    # The keel: nothing below the ribs but a blade tapering to a point, swept back as it falls.
    def hexr(hw, hd, cy, z):
        return [(hw, cy, z), (hw * 0.5, cy + hd, z), (-hw * 0.5, cy + hd, z), (-hw, cy, z), (-hw * 0.5, cy - hd, z), (hw * 0.5, cy - hd, z)]
    _rings(b, [hexr(9.0, 9.0, -2.0, 39.0 + LIFT), hexr(6.2, 8.6, -4.0, 34.0), hexr(3.8, 6.6, -7.0, 21.0), hexr(1.7, 3.8, -10.0, 11.0), hexr(0.25, 0.4, -13.0, 4.0)], "steel.plate", "keel")
    for z, hw, hd, cy in ((38.0, 8.0, 9.6, -3.2), (27.5, 5.6, 8.2, -5.6), (16.0, 3.2, 5.6, -8.6)):
        _rings(b, [hexr(hw, hd, cy, z - 1.5), hexr(hw, hd, cy, z + 1.5)], "steel.dark", "keel_band")
    _curve(b, [(0.0, 5.3, 34.0), (0.0, 0.2, 21.0), (0.0, -5.6, 11.0)], [1.0, 0.9, 0.6], "glass.glass", "keel_seam")
    start, pstart = len(b.objects), len(b.pins)   # everything from here is built LIFT low and raised at the end
    # The ribcage, flaring to the shoulders, and the hump of the back over them.
    _rings(b, [ring(20.0, 16.0, 0.0, 0.0, 4.0), ring(34.0, 20.0, 0.0, 12.0, 5.0), ring(46.0, 22.0, 0.0, 24.0, 6.0), ring(38.0, 18.0, 0.0, 30.0, 5.0)], "steel.panel", "ribcage")
    _rings(b, [ring(32.0, 16.0, -6.0, 22.0, 4.0), ring(26.0, 14.0, -7.5, 31.0, 4.0), ring(16.0, 9.0, -8.5, 38.0, 3.0)], "steel.plate", "hump")
    for k, (y, z) in enumerate(((-13.5, 26.0), (-13.5, 32.0), (-12.0, 37.5))):
        _spike(b, L(0.0, y, z), L(0.0, y - 7.0 + k, z + 4.0), 1.6, "steel.dark", "dorsal_spike")
    for s in (-1.0, 1.0):
        _beam(b, L(s * 4.2, -13.6, 23.5), L(s * 3.4, -14.0, 34.5), _sq(1.5, 1.2), _sq(1.2, 1.2), "glass.glass", "spine_slit")
    # The open chest: a dark frame, a banked fire in it, the ribs across.
    hexf = [(9.5, 13.0), (5.0, 21.5), (-5.0, 21.5), (-9.5, 13.0), (-5.0, 4.5), (5.0, 4.5)]
    b.loft([(8.6, hexf), (11.6, hexf)], "steel.dark", "chest_frame", lean)
    b.loft([(11.2, [(x * 0.82, 13.0 + (z - 13.0) * 0.82) for x, z in hexf]), (12.0, [(x * 0.82, 13.0 + (z - 13.0) * 0.82) for x, z in hexf])], "amber.furnace", "chest_fire", lean)
    for z in (7.5, 11.5, 15.5, 19.5):
        for s in (-1.0, 1.0):
            _beam(b, L(s * 10.5, 11.6, z + 1.6), L(0.0, 13.2, z - 0.6), _sq(1.5, 1.5), _sq(1.5, 1.5), "steel.plate", "rib")
    b.loft([(11.4, [(-1.1, 4.0), (1.1, 4.0), (1.1, 22.0), (-1.1, 22.0)]), (13.6, [(-1.1, 4.0), (1.1, 4.0), (1.1, 22.0), (-1.1, 22.0)])], "steel.dark", "sternum", lean)
    # Rib plates down each flank, below the shoulders.
    for z in (3.0, 8.0, 13.0):
        for s in (-1.0, 1.0):
            hw = 10.0 + z * 0.6
            _beam(b, L(s * (hw + 0.8), -5.0, z + 2.0), L(s * (hw + 1.6), 6.0, z), _sq(1.2, 3.0), _sq(1.2, 2.4), "steel.dark", "flank_rib")

    # The head: thrust forward and down off the chest, lower than the hump behind it. A skull
    # under a brow, a long tapering snout, the lower jaw dropped a little, two lit eyes, two horns.
    head = Matrix.Translation((0.0, 28.0, 61.0)) @ Matrix.Rotation(math.radians(-20.0), 4, "X") @ Matrix.Scale(1.18, 4)

    def H(x, y, z):
        return head @ Vector((x, y, z))

    def sec(w, z0, z1, c=1.4):
        return [(-w / 2.0, z0), (w / 2.0, z0), (w / 2.0, z1 - c), (w / 2.0 - c, z1), (-w / 2.0 + c, z1), (-w / 2.0, z1 - c)]
    _curve(b, [(0.0, 15.0, 59.0), (0.0, 21.0, 61.5), H(0.0, -4.0, 0.5)], [6.5, 5.6, 5.0], "steel.dark", "neck", n=6, phase=0.0)
    b.loft([(-7.0, sec(11.0, -4.5, 5.0)), (2.0, sec(13.0, -5.0, 7.0)), (8.0, sec(10.0, -4.5, 6.0))], "steel.panel", "skull", head)
    b.loft([(1.0, sec(14.0, 5.0, 8.4, 1.0)), (9.5, sec(11.0, 4.4, 7.0, 1.0))], "steel.plate", "brow", head)
    b.loft([(8.0, sec(8.0, -2.4, 4.4)), (17.0, sec(6.0, -2.0, 2.4, 1.0)), (25.0, sec(3.6, -1.6, 0.4, 0.6))], "steel.plate", "snout", head)
    jaw = head @ Matrix.Translation((0.0, 1.0, -5.0)) @ Matrix.Rotation(math.radians(-13.0), 4, "X") @ Matrix.Translation((0.0, -1.0, 5.0))
    b.loft([(-2.0, sec(10.0, -8.0, -4.6, 0.6)), (9.0, sec(8.0, -7.0, -4.2, 0.6)), (23.5, sec(3.4, -5.0, -3.6, 0.4))], "steel.dark", "jaw", jaw)
    b.loft([(6.0, [(-2.6, -4.3), (2.6, -4.3), (2.6, -3.3), (-2.6, -3.3)]), (20.0, [(-1.2, -3.7), (1.2, -3.7), (1.2, -3.0), (-1.2, -3.0)])], "amber.furnace", "maw", jaw)
    for s in (-1.0, 1.0):
        b.box(s * 4.6 - 2.0, s * 4.6 + 2.0, 7.6, 8.9, 1.3, 3.9, "glass.glass", "eye", head)
        _spike(b, (jaw @ Vector((s * 1.6, 21.0, -3.8))), (jaw @ Vector((s * 1.9, 22.0, 0.2))), 0.7, "steel.plate", "fang")
        _spike(b, H(s * 2.4, 22.0, -1.4), H(s * 2.7, 23.0, -4.6), 0.7, "steel.plate", "fang")
        _curve(b, [H(s * 4.5, -3.0, 5.5), H(s * 9.5, -7.0, 12.0), H(s * 14.0, -8.0, 20.0), H(s * 16.0, -5.0, 29.0)], [3.3, 2.8, 1.9, 0.15], "steel.dark", "horn")

    # The shoulders and the long arms: upper arm down and out, an elbow with a spur, a long
    # vambrace forward and in, a hand of three long claws hung low ahead of the keel.
    for s in (-1.0, 1.0):
        _rings(b, [[(s * 19.0, -1.0, 61.0), (s * 35.0, -1.0, 58.0), (s * 35.0, 17.0, 56.5), (s * 19.0, 17.0, 59.5)],
                   [(s * 21.0, 2.0, 67.0), (s * 32.0, 2.0, 65.0), (s * 32.0, 14.0, 64.0), (s * 21.0, 14.0, 66.0)]], "steel.plate", "pauldron")
        for y in (2.0, 9.0):
            _spike(b, (s * 33.0, y, 61.0), (s * 43.0, y - 2.0, 70.0 - y * 0.3), 1.9, "steel.dark", "pauldron_spike")
        shoulder, elbow, wrist = (s * 28.0, 8.0, 57.0), (s * 35.0, 11.0, 34.0), (s * 21.0, 34.0, 23.0)
        _beam(b, shoulder, elbow, _sq(8.5, 8.5), _sq(7.0, 7.0), "steel.panel", "upper_arm")
        b.box(elbow[0] - 4.6, elbow[0] + 4.6, elbow[1] - 4.6, elbow[1] + 4.6, elbow[2] - 4.6, elbow[2] + 4.6, "steel.dark", "elbow")
        _spike(b, (elbow[0], elbow[1] - 3.0, elbow[2] + 1.0), (elbow[0] + s * 3.0, elbow[1] - 15.0, elbow[2] + 6.0), 1.8, "steel.dark", "elbow_spur")
        _beam(b, elbow, wrist, _sq(6.6, 6.6), _sq(8.6, 8.0), "steel.plate", "forearm")
        _beam(b, (elbow[0] * 0.6 + wrist[0] * 0.4, elbow[1] * 0.6 + wrist[1] * 0.4, elbow[2] * 0.6 + wrist[2] * 0.4 + 4.6),
              (elbow[0] * 0.15 + wrist[0] * 0.85, elbow[1] * 0.15 + wrist[1] * 0.85, elbow[2] * 0.15 + wrist[2] * 0.85 + 5.2), _sq(2.4, 1.2), _sq(2.4, 1.2), "glass.glass", "vambrace_slit")
        w = Vector(wrist)
        _curve(b, [w, w + Vector((-s * 1.0, 6.0, -2.0))], [4.6, 4.0], "steel.dark", "palm", n=6, phase=0.0)
        for k in (-1.0, 0.0, 1.0):
            base = w + Vector((k * 3.2 - s * 0.8, 5.0, -2.0))
            _curve(b, [base, base + Vector((k * 2.6, 8.0, -1.5)), base + Vector((k * 4.2 - s * 1.0, 13.0, -7.0)), base + Vector((k * 4.6 - s * 2.0, 14.0, -14.5))],
                   [1.9, 1.6, 1.1, 0.12], "steel.dark", "claw")
        thumb = w + Vector((-s * 3.6, 2.0, -1.0))
        _curve(b, [thumb, thumb + Vector((-s * 4.0, 5.0, -3.0)), thumb + Vector((-s * 4.6, 7.0, -9.0))], [1.5, 1.1, 0.12], "steel.dark", "claw")
        # The shoulder's mount, on the pauldron (hp_3 left, hp_4 right).
        b.box(s * 26.5 - 3.4, s * 26.5 + 3.4, 4.0, 11.0, 65.0, 67.6, "steel.dark", "shoulder_mount")
        b.stock("hp_%d" % (3 if s < 0 else 4), (s * 26.5, 9.0, 68.6), "barrel", scale=0.7, carries="blazethrower" if s < 0 else "backdraft_charge")

    # The wings, off the hump's flanks, and a booster under each root, its mouth down and back.
    for s in (-1.0, 1.0):
        root = L(s * 12.0, -8.5, 31.0)
        P, N = _bat_wing(b, s, root, dih, sweep, tilt, k=0.88)
        b.box(s * 12.0 - 6.0, s * 12.0 + 6.0, -9.0, 3.0, 26.0, 35.0, "steel.dark", "wing_root", lean)
        top = L(s * 12.5, -9.5, 36.0)
        b.box(s * 12.5 - 3.6, s * 12.5 + 3.6, -13.0, -5.0, 34.6, 36.6, "steel.plate", "root_mount", lean)
        b.stock("hp_%d" % (1 if s < 0 else 2), (top.x, top.y + 1.5, top.z + 1.6), "rack", scale=0.52, carries="meteor_artillery")
        p0, p1 = L(s * 12.5, -12.0, 26.0), L(s * 13.5, -22.0, 12.0)
        _tube(b, p0, p1, 6.0, 4.8, 8, "steel.dark", "booster", floor_material="amber.exhaust", floor_depth=1.6)
        _curve(b, [p0 + (p1 - p0) * 0.78, p0 + (p1 - p0) * 0.92], [6.6, 6.6], "amber.engine", "booster_ring", n=8, phase=0.0)
    lift = Matrix.Translation((0.0, 0.0, LIFT))
    for ob in b.objects[start:] + b.pins[pstart:]:
        if ob.parent is None:
            ob.matrix_world = lift @ ob.matrix_world


def arlook_mastema(b):
    """Mastema hovering: its wings raised behind it, the leading edges up and the fingers hung
    out and down, so it looms from the front and still shows its span from above."""
    _mastema(b, tilt=68.0, dih=28.0, sweep=-8.0)


arlook_mastema.maker = AR


def arlook_mastema_level(b):
    """The same figure with its wings tilted level, as it would carry them to move: the wings
    tilt and vector, they never flap."""
    _mastema(b, tilt=14.0, dih=8.0, sweep=22.0)


arlook_mastema_level.maker = AR

LOOKS = ["arlook_mastema", "arlook_mastema_level"]

SHEET = {
    "title": "Mastema, first round, 15 November (look tests, not content)",
    "out": "docs/looks/arsenal_mastema.png",
    "cell": (340, 340),
    "rows": [
        {"model": "arlook_mastema", "label": "Wings raised to hover", "views": ["codex", "above", "skirmish", "front", "side"]},
        {"model": "arlook_mastema_level", "label": "Wings levelled to move", "views": ["codex", "above", "skirmish", "front", "side"]},
    ],
}

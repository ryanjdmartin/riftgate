"""The units, each from Ryan's brief (21 September), massed in the Descent register: few
facets, every one deliberate. x right, y forward, z up; a mech is about 60 units wide.
Tile names after the dot pick the texture; the role before it is what the engine reads.
Every number here is a proportion Ryan may change; the render is a minute away.
Function names are chassis ids (content/chassis.json), so the build lands where the
engine looks: art/models/<id>.glb.
"""

import math

import bmesh
from mathutils import Matrix, Vector

from bl_low import boom, diamond, hexagon, rect


def badger(b):
    """Minerva "Honey Badger": heavy machinery, mining roots, boxy and indestructible. Treads;
    a low reinforced frame with a raised engine deck; the cockpit tucked into the front of the
    frame under a brow, between two cheeks, so it survives a cave-in; two excavator booms
    pivoting on the frame's flanks at mid-length (not shoulders), reaching forward past the
    cockpit; an outsized claw on the left, the defining feature; a barrel mount on the right;
    a missile box on the deck; floodlights, vents, a ladder, a hatch."""
    # Treads: wide enough for the booms to rest over them, chamfered both ends, a skirt
    # plate over each, hazard tips forward.
    for s in (-1.0, 1.0):
        cx = s * 25.0
        b.loft([(-36.0, rect(cx, 24.0, 5.0, 11.0)), (-29.0, rect(cx, 24.0, 0.0, 19.0)),
                (29.0, rect(cx, 24.0, 0.0, 19.0)), (36.0, rect(cx, 24.0, 5.0, 11.0))], "bore.tread", "tread")
        b.box(cx - 13.0, cx + 13.0, -31.0, 31.0, 18.0, 21.0, "steel.plate", "skirt")
        b.box(cx - 13.0, cx + 13.0, 22.0, 31.0, 21.0, 23.0, "steel.stripe", "skirt_tip")
    # Frame: low across the treads, the cheeks either side of the cockpit bay at the front.
    b.loft([(-30.0, rect(0.0, 44.0, 20.0, 34.0)), (12.0, rect(0.0, 44.0, 20.0, 34.0))], "steel.panel", "hull")
    for s in (-1.0, 1.0):
        b.loft([(12.0, rect(s * 15.0, 14.0, 20.0, 36.0)), (30.0, rect(s * 15.0, 14.0, 21.0, 34.0))], "steel.panel", "cheek")
    # The brow: a heavy plate over the cockpit bay, floodlights under its lip.
    b.loft([(6.0, rect(0.0, 44.0, 34.0, 40.0)), (32.0, rect(0.0, 40.0, 33.0, 39.0))], "steel.plate", "brow")
    b.box(-20.0, 20.0, 32.0, 33.5, 34.0, 38.0, "steel.hazard", "brow_lip")
    for s in (-1.0, 1.0):
        b.box(s * 12.0 - 3.0, s * 12.0 + 3.0, 30.0, 33.0, 30.5, 33.5, "amber.light", "floodlight")
    # Cockpit: tucked into the bay, glass face set back under the brow.
    b.loft([(10.0, rect(0.0, 16.0, 22.0, 33.0)), (26.0, rect(0.0, 15.0, 23.0, 32.0))], "steel.plate", "cockpit")
    b.loft([(26.0, rect(0.0, 13.0, 24.0, 31.0)), (27.5, rect(0.0, 11.0, 25.0, 30.0))], "glass.glass", "canopy")
    # Engine deck at the rear, raised, with vents, an exhaust and the hatch.
    b.loft([(-30.0, rect(0.0, 36.0, 34.0, 46.0)), (-4.0, rect(0.0, 36.0, 34.0, 46.0)), (2.0, rect(0.0, 34.0, 34.0, 40.0))], "steel.panel", "deck")
    b.box(-16.0, 16.0, -33.0, -30.0, 22.0, 44.0, "steel.vent", "rear_vents")
    b.box(-8.0, 0.0, -14.0, -6.0, 46.0, 48.0, "steel.plate", "hatch")
    b.box(-14.0, -10.0, -26.0, -18.0, 46.0, 54.0, "steel.dark", "exhaust")
    b.box(-22.5, -19.5, -20.0, 0.0, 22.0, 44.0, "steel.ladder", "ladder")
    # Booms: a compact cuff on each flank at mid-length holding a big hinge cylinder (like
    # the elbow), a cannon flanking it outboard, upper and lower booms of one width, the
    # forearms dropping to the ground ahead of the cockpit.
    ARM = 16.0
    for s, kind in ((-1.0, "claw"), (1.0, "gun")):
        px = s * 22.0
        b.box(px - 6.0, px + 6.0, -14.0, 2.0, 24.0, 44.0, "steel.panel", "cuff")
        hinge_x = px + s * 10.0
        b.prism("x", hinge_x, -6.0, 34.0, 11.0, 16.0, "steel.dark", 6, "hinge")
        # The shoulder cannon, outboard of the hinge.
        cx = hinge_x + s * 12.0
        b.box(cx - 3.5, cx + 3.5, -12.0, 0.0, 30.0, 38.0, "steel.plate", "cannon_mount")
        b.prism("y", cx, 12.0, 34.0, 2.6, 26.0, "steel.dark", 6, "cannon")
        b.pin("hp_%d" % (3 if s < 0 else 4), (cx, 0.0, 34.0))
        start = (hinge_x, -6.0, 34.0)
        elbow, _ = boom(b, start, 42.0, 12.0, 0.0, ARM, ARM, ARM, ARM, "livery.livery2", "upper_boom")   # straight ahead, no yaw
        b.prism("x", elbow[0], elbow[1], elbow[2], 10.0, ARM + 4.0, "steel.dark", 6, "elbow")
        wrist, rot = boom(b, elbow, 28.0, 48.0, 0.0, ARM, ARM, ARM, ARM, "steel.plate", "forearm")
        b.prism("x", wrist[0], wrist[1], wrist[2], 9.0, ARM + 8.0, "steel.dark", 6, "wrist")
        if kind == "claw":
            # The grapple (Ryan's references, 21 September): an excavator grab made sharp.
            # Plated cheeks house the pivot; two long curved fingers sweep down and back
            # from above, two shorter opposing tines curl up from below, interleaved so
            # they close between each other; every tine tapers to a point.
            for s2 in (-1.0, 1.0):
                b.box(wrist[0] + s2 * 13.0 - 1.5, wrist[0] + s2 * 13.0 + 1.5, wrist[1] - 9.0, wrist[1] + 9.0, wrist[2] - 9.0, wrist[2] + 9.0, "steel.panel", "cheek")
            b.prism("x", wrist[0], wrist[1] + 6.0, wrist[2] - 6.0, 2.2, 30.0, "steel.dark", 6, "pin")
            for sx in (-9.0, 9.0):
                _tine(b, wrist, sx, -10.0, -105.0, 38.0, 8.0, 5.5, "steel.dark", "finger")
            for sx in (-3.0, 3.0):
                _tine(b, wrist, sx, -100.0, 95.0, 30.0, 7.0, 4.5, "steel.dark", "tine")
        else:
            # A weapons mount on the wrist: receiver block and a six-sided barrel, the
            # hardpoint on it.
            b.box(wrist[0] - 7.0, wrist[0] + 7.0, wrist[1] - 6.0, wrist[1] + 12.0, wrist[2] - 6.0, wrist[2] + 6.0, "steel.panel", "mount")
            b.prism("y", wrist[0], wrist[1] + 26.0, wrist[2], 3.2, 30.0, "steel.dark", 6, "barrel")
            b.box(wrist[0] - 3.0, wrist[0] + 3.0, wrist[1] + 10.0, wrist[1] + 16.0, wrist[2] + 6.0, wrist[2] + 9.0, "amber.light", "mount_light")
            b.pin("hp_1", (wrist[0], wrist[1] + 12.0, wrist[2]))
    # Deck weapon: a missile box on a turret ring, right of centre. Its face is exactly one
    # tile (14 units) square on tile boundaries, so the box projection shows the nine tubes
    # whole rather than a slice of them.
    b.prism("z", 7.0, -13.0, 41.0, 8.0, 2.0, "steel.dark", 8, "ring")
    b.box(0.0, 14.0, -22.0, -4.0, 42.0, 56.0, "steel.panel", "turret")
    b.box(0.0, 14.0, -4.6, -3.6, 42.0, 56.0, "steel.missile", "missile_face")
    b.pin("hp_2", (7.0, -12.0, 49.0))


badger.maker = "minerva"


def sparrowhawk(b):
    """Kestrel "Sparrowhawk": a small hit-and-run interceptor. Sleek, speed over defence;
    reverse-swept wings whose rear faces run back into the boosters, a faired canopy far
    back, twin nose guns, two big boosters, a tail rooted into the fuselage and riding over
    the boosters, ending in two angled stabilisers. Small but deadly."""
    # Fuselage: one piece, a six-sided section lofted from a needle nose to a broad rear.
    # The top tapers sharply toward the nose, the belly shallowly, and the belly carries
    # forward under the wing roots (Ryan, 21 September).
    b.loft([(46.0, _fuse(1.2, 0.6, 0.5)), (36.0, _fuse(6.0, 2.2, 2.0)), (18.0, _fuse(12.0, 3.8, 3.4)),
            (0.0, _fuse(16.0, 6.4, 4.6)), (-16.0, _fuse(18.0, 7.0, 4.8)), (-30.0, _fuse(15.0, 5.4, 4.0))], "bone.bone", "fuselage")
    b.loft([(38.0, diamond(0.0, 0.5, 2.0, 1.5)), (46.0, diamond(0.0, 0.5, 1.0, 0.7))], "steel.dark", "nose_tip")
    # Twin nose guns, one either side of the nosecone.
    for s in (-1.0, 1.0):
        b.prism("y", s * 4.5, 36.0, -1.0, 1.3, 26.0, "steel.dark", 6, "nose_gun")
        b.box(s * 4.5 - 1.5, s * 4.5 + 1.5, 22.0, 30.0, -2.5, 1.0, "steel.plate", "gun_fairing")
    # Canopy: far back, low, faired into the spine rather than a bubble.
    b.loft([(-2.0, hexagon(0.0, 6.2, 7.0, 0.5)), (-10.0, hexagon(0.0, 7.4, 9.0, 3.0)),
            (-18.0, hexagon(0.0, 7.5, 9.0, 3.2)), (-26.0, hexagon(0.0, 7.2, 9.0, 3.0))], "glass.glass", "canopy")
    # Behind it the raised spine is an air intake: a scoop with a dark mouth facing forward
    # and slits down its sides.
    b.loft([(-24.0, hexagon(0.0, 7.6, 9.4, 3.6)), (-28.0, hexagon(0.0, 8.4, 10.0, 5.0)), (-36.0, hexagon(0.0, 7.4, 9.4, 3.6))], "steel.panel", "intake")
    b.loft([(-28.2, hexagon(0.0, 8.4, 8.6, 4.2)), (-27.4, hexagon(0.0, 8.4, 8.6, 4.2))], "bore.dark", "intake_mouth")
    for s in (-1.0, 1.0):
        b.box(s * 4.6, s * 5.2, -34.0, -29.0, 7.0, 9.6, "steel.vent", "intake_slits")
    # Reverse-swept wings with a little anhedral, knife-edged at the front (a three-point
    # section: the leading edge is one line), the root's trailing edge running back into
    # the boosters; a weapon pod and gun at each tip.
    for s in (-1.0, 1.0):
        root = [(s * 8.0, -32.0, -1.0), (s * 8.0, -32.0, 1.4), (s * 8.0, 6.0, 0.2)]
        tip = [(s * 32.0, 6.0, -5.4), (s * 32.0, 6.0, -4.6), (s * 32.0, 14.0, -5.0)]
        _wing(b, root, tip, "livery.livery", "wing")
        b.prism("y", s * 32.0, 10.0, -4.8, 2.2, 22.0, "steel.dark", 6, "wing_pod")
        b.prism("y", s * 32.0, 24.0, -4.8, 1.2, 8.0, "steel.dark", 6, "wing_gun")
        b.pin("hp_%d" % (1 if s < 0 else 2), (s * 32.0, 14.0, -4.8))
    # Boosters: two big six-sided drums under and behind the cockpit, red glow at the back.
    for s in (-1.0, 1.0):
        b.prism("y", s * 7.5, -32.0, -1.0, 6.0, 28.0, "steel.panel", 6, "booster", phase=math.pi / 6)
        b.prism("y", s * 7.5, -47.0, -1.0, 6.5, 2.0, "amber.engine", 6, "booster_ring", phase=math.pi / 6)   # lit: the amber role glows
        b.loft([(-48.0, hexagon(s * 7.5, -1.0, 11.0, 9.5)), (-48.5, hexagon(s * 7.5, -1.0, 10.0, 8.5))], "amber.engine", "exhaust")
    # Tail: rooted into the fuselage with a keel, riding over the boosters, two angled
    # stabilisers at the end.
    b.loft([(-18.0, rect(0.0, 12.0, 4.0, 12.0)), (-32.0, rect(0.0, 8.0, 7.0, 12.5)),
            (-46.0, rect(0.0, 5.0, 9.0, 12.5)), (-60.0, rect(0.0, 3.0, 9.5, 11.5))], "bone.bone", "tail_boom")
    b.loft([(-30.0, rect(0.0, 4.0, 4.5, 8.0)), (-44.0, rect(0.0, 3.0, 5.5, 9.0))], "steel.dark", "keel")
    for s in (-1.0, 1.0):
        a = math.radians(s * 38.0)
        root = [(s * 1.5, -60.0, 10.5), (s * 1.5, -48.0, 10.5), (s * 1.5, -48.0, 11.5), (s * 1.5, -60.0, 11.5)]
        tip = [(s * 1.5 + 14.0 * math.sin(a), -62.0, 10.5 + 14.0 * math.cos(a)), (s * 1.5 + 14.0 * math.sin(a), -55.0, 10.5 + 14.0 * math.cos(a)),
               (s * 1.5 + 14.0 * math.sin(a), -55.0, 10.9 + 14.0 * math.cos(a)), (s * 1.5 + 14.0 * math.sin(a), -62.0, 10.9 + 14.0 * math.cos(a))]
        _wing(b, root, tip, "livery.livery", "stabiliser")


sparrowhawk.maker = "kestrel"


def _fuse(w, top, bottom):
    """A fuselage section: six points, `top` above the centreline and `bottom` below it,
    so the top and belly can taper at different rates."""
    return [(w / 2, 0.0), (w / 4, top), (-w / 4, top), (-w / 2, 0.0), (-w / 4, -bottom), (w / 4, -bottom)]


def _wing(b, root, tip, material, label):
    """A wing as a loft between two sections given in full 3D."""
    return _rings(b, [root, tip], material, label)


def _rings(b, rings, material, label):
    """A loft through any number of sections given as 3D point rings, capped at both ends."""
    bm = bmesh.new()
    vs = [[bm.verts.new(p) for p in ring] for ring in rings]
    n = len(vs[0])
    for r0, r1 in zip(vs, vs[1:]):
        for i in range(n):
            try:
                bm.faces.new([r0[i], r0[(i + 1) % n], r1[(i + 1) % n], r1[i]])
            except ValueError:
                pass
    for ring in (vs[0], vs[-1]):
        try:
            bm.faces.new(ring)
        except ValueError:
            pass
    return b._finish(bm, material, label)


def _tine(b, origin, side_x, pitch0, curve, length, w0, t0, material, label, n=5):
    """A curved, tapering tine: a rectangular section swept along an arc in the y-z plane
    from `origin` (offset `side_x`), starting at `pitch0` degrees and turning through
    `curve` degrees over `length`, narrowing to a point."""
    rings = []
    pos = Vector(origin) + Vector((side_x, 0.0, 0.0))
    for k in range(n + 1):
        f = k / float(n)
        th = math.radians(pitch0 + curve * f)
        nrm = Vector((0.0, -math.sin(th), math.cos(th)))
        w = w0 * (1.0 - 0.82 * f) + 0.4
        t = t0 * (1.0 - 0.9 * f) + 0.3
        rings.append([pos + Vector((-w / 2, 0, 0)) - nrm * (t / 2), pos + Vector((w / 2, 0, 0)) - nrm * (t / 2),
                      pos + Vector((w / 2, 0, 0)) + nrm * (t / 2), pos + Vector((-w / 2, 0, 0)) + nrm * (t / 2)])
        if k < n:
            th2 = math.radians(pitch0 + curve * (k + 0.5) / n)
            pos = pos + Vector((0.0, math.cos(th2), math.sin(th2))) * (length / n)
    return _rings(b, rings, material, label)


# ---------------------------------------------------------------- structures (the Arsenal)

def _blades(b, x0, x1, y, z, step=12.0, h=16.0, w=2.4):
    """A row of upright blades along a top edge, each a wedge leaning back, so the crown
    reads as a saw rather than teeth (no crenellations: Ryan, 20 September)."""
    x = x0
    while x + w <= x1 + 0.01:
        b.loft([(y - 3.5, rect(x + w / 2, w, z, z + h * 0.35)), (y + 3.5, rect(x + w / 2, w, z, z + h))], "steel.dark", "blade")
        x += step


def _gun(b, x, y, z):
    """A turret ring, a mount and one heavy six-sided barrel. The map stands the gate turned
    about, so the barrel points to local -y to face north on the field."""
    b.prism("z", x, y, z + 2.5, 12.0, 5.0, "steel.dark", 6, "ring")
    b.box(x - 7.0, x + 7.0, y - 8.0, y + 8.0, z + 5.0, z + 15.0, "steel.panel", "mount")
    b.prism("y", x, y - 20.0, z + 11.0, 3.6, 34.0, "steel.dark", 6, "barrel")
    b.box(x - 4.0, x + 4.0, y + 8.0, y + 11.0, z + 6.0, z + 13.0, "amber.light", "sight")


def wall(b):
    """One wall segment of the field's emitter line (decided 20 September): a hex wide, the
    gate's wall height, a hazard band, a buttress each face, blades along the top."""
    b.tile_world = 80.0
    W, D, H = 31.0, 12.0, 70.0
    b.box(-W, W, -D - 6.0, D + 6.0, 0.0, 6.0, "steel.dark", "plinth")
    b.box(-W, W, -D, D, 6.0, H, "steel.panel", "wall")
    for f in (-1.0, 1.0):
        b.box(-W, W, f * (D + 0.2), f * (D + 1.4), 21.0, 24.5, "amber.strip", "light_strip")
        b.loft([(f * D, rect(0.0, 10.0, 6.0, H - 6.0)), (f * (D + 12.0), rect(0.0, 10.0, 6.0, 12.0))], "steel.dark", "buttress")
    _blades(b, -W + 1.0, W - 1.0, D - 2.0, H)
    _blades(b, -W + 1.0, W - 1.0, -D + 2.0, H)


wall.maker = "arsenal"


def gate(b):
    """The gate: the field's projector and the Arsenal's device. Three hexes wide, a low
    wall either side, a gatehouse rising above it with a tall narrow pointed mouth in two
    stepped reveals, two finned six-sided towers with a heavy gun each, blades on every top
    edge, lamps either side of the mouth."""
    b.tile_world = 80.0
    W, D, H = 92.0, 16.0, 70.0
    b.box(-W, W, -D - 8.0, D + 8.0, 0.0, 6.0, "steel.dark", "plinth")
    b.box(-W, W, -D, D, 6.0, H, "steel.panel", "wall")
    GW, GH = 58.0, H + 22.0
    b.box(-GW, GW, -D - 3.0, D + 3.0, 6.0, GH, "steel.panel", "gatehouse")
    MW, MH = 22.0, 64.0
    for f in (-1.0, 1.0):
        b.box(-W, -GW, f * (D + 0.2), f * (D + 1.4), 21.0, 24.5, "amber.strip", "light_strip")
        b.box(GW, W, f * (D + 0.2), f * (D + 1.4), 21.0, 24.5, "amber.strip", "light_strip")
    b.box(-MW, MW, -D - 4.0, D + 4.0, 6.0, MH, "bore.dark", "mouth")
    for rw, rh, rd in ((MW + 5.0, MH + 8.0, 4.5), (MW + 10.0, MH + 16.0, 6.0)):
        for f in (-1.0, 1.0):
            y0, y1 = f * (D + 3.0), f * (D + 3.0 + rd)
            b.box(-rw, -rw + 4.5, y0, y1, 6.0, rh, "steel.dark", "jamb")
            b.box(rw - 4.5, rw, y0, y1, 6.0, rh, "steel.dark", "jamb")
            b.loft([(y0, [(-rw, rh), (rw, rh), (0.0, rh + rw * 0.55)]), (y1, [(-rw, rh), (rw, rh), (0.0, rh + rw * 0.55)])], "steel.dark", "point")
    for i in range(5):
        x = -12.0 + i * 6.0
        b.box(x - 0.9, x + 0.9, D + 2.0, D + 4.0, 6.0, MH, "steel.dark", "bar")
    for s in (-1.0, 1.0):
        b.box(-22.0, 22.0, s * (D + 3.0), s * (D + 5.0), GH - 18.0, GH - 6.0, "livery.livery", "device")
        for f in (-1.0, 1.0):
            b.box(s * 30.0, s * 34.0, f * (D + 3.0), f * (D + 5.0), 30.0, 36.0, "amber.light", "lamp")
    b.box(-GW - 2.0, GW + 2.0, -D - 5.0, D + 5.0, GH - 6.0, GH, "steel.dark", "lintel")
    _blades(b, -GW + 2.0, GW - 2.0, D - 1.0, GH, step=10.0, h=22.0)
    _blades(b, -GW + 2.0, GW - 2.0, -D + 1.0, GH, step=10.0, h=22.0)
    TR, TT = 20.0, 112.0
    for s in (-1.0, 1.0):
        x = s * 74.0
        b.prism("z", x, 0.0, (6.0 + TT) / 2.0, TR, TT - 6.0, "steel.panel", 6, "tower", phase=math.pi / 6)
        for k in range(6):
            a = k * math.pi / 3.0
            fx, fy = TR * math.cos(a), TR * math.sin(a)
            b.box(x + fx - 2.0, x + fx + 2.0, fy - 2.0, fy + 2.0, 12.0, TT + 10.0, "steel.dark", "fin")
        b.prism("z", x, 0.0, TT + 1.5, TR + 2.0, 3.0, "steel.dark", 6, "cap", phase=math.pi / 6)
        _gun(b, x, 0.0, TT + 3.0)
        for bx in (x - 30.0, x + 30.0):
            if abs(bx) < W - 4.0 and abs(bx) > GW + 2.0:
                for f in (-1.0, 1.0):
                    b.loft([(f * D, rect(bx, 10.0, 6.0, H - 6.0)), (f * (D + 14.0), rect(bx, 10.0, 6.0, 12.0))], "steel.dark", "bastion")
    for side in (1.0, -1.0):
        _blades(b, -W + 2.0, -88.0, side * (D - 2.0), H)
        _blades(b, 88.0, W - 2.0, side * (D - 2.0), H)


gate.maker = "arsenal"

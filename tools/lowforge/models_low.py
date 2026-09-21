"""The units, each from Ryan's brief (21 September), massed in the Descent register: few
facets, every one deliberate. x right, y forward, z up; a mech is about 60 units wide.
Tile names after the dot pick the texture; the role before it is what the engine reads.
"""

import math

from bl_low import boom, diamond, hexagon, rect


def honey_badger(b):
    """Minerva "Honey Badger": heavy machinery, mining roots, boxy and indestructible. Treads,
    a boxy reinforced frame on top, two excavator-boom arms (claw left, weapon mount right), a
    shielded cockpit on the front, a weapon mount on the right shoulder, floodlights, vents,
    a ladder and a hatch."""
    # Treads: chamfered at both ends, a skirt plate over each.
    for s in (-1.0, 1.0):
        cx = s * 21.0
        b.loft([(-36.0, rect(cx, 16.0, 5.0, 11.0)), (-29.0, rect(cx, 16.0, 0.0, 18.0)),
                (29.0, rect(cx, 16.0, 0.0, 18.0)), (36.0, rect(cx, 16.0, 5.0, 11.0))], "bore.tread", "tread")
        b.box(cx - 9.0, cx + 9.0, -31.0, 31.0, 17.0, 20.5, "steel.plate", "skirt")
        b.box(cx - 9.0, cx + 9.0, 20.0, 31.0, 20.5, 23.0, "steel.stripe", "skirt_tip")
    # Frame: a boxy hull, chamfered at the front top, sitting across the treads.
    b.loft([(-30.0, rect(0.0, 42.0, 19.0, 42.0)), (16.0, rect(0.0, 42.0, 19.0, 42.0)),
            (28.0, rect(0.0, 40.0, 21.0, 38.0))], "steel.panel", "hull")
    b.box(-16.0, 16.0, -33.0, -30.0, 22.0, 38.0, "steel.vent", "rear_vents")
    b.box(-21.5, -19.0, -20.0, 10.0, 24.0, 40.0, "steel.ladder", "ladder")
    b.box(-8.0, 4.0, -12.0, 0.0, 42.0, 44.0, "steel.plate", "hatch")
    b.box(-6.0, -2.0, -22.0, -14.0, 42.0, 50.0, "steel.dark", "exhaust")
    # Cockpit: a shielded block on the front of the frame, glass face under an armour brow.
    b.loft([(28.0, rect(0.0, 26.0, 24.0, 40.0)), (40.0, rect(0.0, 22.0, 27.0, 37.0))], "steel.plate", "cockpit")
    b.loft([(40.0, rect(0.0, 18.0, 28.0, 35.0)), (41.5, rect(0.0, 16.0, 29.0, 34.0))], "glass.glass", "canopy")
    b.box(-13.0, 13.0, 36.0, 43.0, 37.0, 40.0, "steel.hazard", "brow")
    for s in (-1.0, 1.0):
        b.box(s * 11.0 - 3.0, s * 11.0 + 3.0, 42.0, 45.0, 38.0, 42.0, "amber.light", "floodlight")
    # Arms: excavator booms from shoulder blocks at the front corners of the frame.
    for s, kind in ((-1.0, "claw"), (1.0, "gun")):
        sx = s * 26.0
        b.box(sx - 6.0, sx + 6.0, 4.0, 18.0, 26.0, 40.0, "steel.panel", "shoulder")
        b.prism("x", sx, 11.0, 33.0, 5.0, 4.0, "steel.dark", 6, "shoulder_pin")
        elbow, _ = boom(b, (sx + s * 4.0, 11.0, 33.0), 30.0, 28.0, s * 8.0, 9.0, 11.0, 7.0, 8.0, "livery.livery2", "upper_boom")
        b.prism("x", elbow[0], elbow[1], elbow[2], 5.0, 9.0, "steel.dark", 6, "elbow")
        wrist, rot = boom(b, elbow, 26.0, 62.0, s * 4.0, 7.0, 8.0, 6.0, 6.0, "steel.plate", "forearm")
        if kind == "claw":
            # Two hardened prongs closing forward, on a knuckle.
            b.prism("x", wrist[0], wrist[1], wrist[2], 4.5, 10.0, "steel.dark", 6, "knuckle")
            for side in (-1.0, 1.0):
                from mathutils import Matrix, Vector
                m = Matrix.Translation(Vector(wrist)) @ Matrix.Rotation(math.radians(-15.0 - 25.0 * side), 4, "X") @ Matrix.Rotation(math.radians(side * 4.0), 4, "Z")
                b.loft([(0.0, rect(0.0, 6.0, -3.0, 3.0)), (12.0, rect(0.0, 4.0, -2.0, 2.0)), (18.0, rect(0.0, 1.0, -0.5, 0.5))], "steel.stripe", "prong", m)
        else:
            # A weapons mount: receiver block and a six-sided barrel, the hardpoint on it.
            b.box(wrist[0] - 5.0, wrist[0] + 5.0, wrist[1] - 6.0, wrist[1] + 8.0, wrist[2] - 5.0, wrist[2] + 5.0, "steel.panel", "mount")
            b.prism("y", wrist[0], wrist[1] + 20.0, wrist[2], 2.6, 26.0, "steel.dark", 6, "barrel")
            b.pin("hp_1", (wrist[0], wrist[1] + 8.0, wrist[2]))
    # Shoulder weapon on the right: a missile box on a turret ring.
    b.prism("z", 13.0, -6.0, 43.0, 7.0, 2.0, "steel.dark", 8, "ring")
    b.box(6.0, 20.0, -14.0, 4.0, 44.0, 54.0, "steel.panel", "turret")
    b.box(6.5, 19.5, 4.0, 5.5, 45.0, 53.0, "steel.missile", "missile_face")
    b.pin("hp_2", (13.0, -4.0, 49.0))


def sparrowhawk(b):
    """Kestrel "Sparrowhawk": a small hit-and-run interceptor. Sleek, speed over defence;
    reverse-swept wings with prominent weapon mounts, a nose gun, the cockpit far back riding
    two big boosters, a tail extending over and behind them. Small but deadly."""
    # Fuselage: a flattened hexagon lofted from a needle nose to a broad rear.
    b.loft([(46.0, diamond(0.0, 0.0, 1.5, 1.0)), (36.0, hexagon(0.0, 0.0, 6.0, 4.0)),
            (18.0, hexagon(0.0, 1.0, 12.0, 7.0)), (0.0, hexagon(0.0, 2.0, 16.0, 9.0)),
            (-16.0, hexagon(0.0, 2.0, 18.0, 10.0)), (-28.0, hexagon(0.0, 1.5, 14.0, 8.0))], "bone.bone", "fuselage")
    b.loft([(38.0, diamond(0.0, 0.5, 2.0, 1.5)), (46.0, diamond(0.0, 0.5, 1.0, 0.7))], "steel.dark", "nose_tip")
    # Nose gun under the nosecone.
    b.prism("y", 0.0, 40.0, -2.5, 1.2, 22.0, "steel.dark", 6, "nose_gun")
    # Cockpit: far back, a low canopy riding the rear of the fuselage.
    b.loft([(-6.0, hexagon(0.0, 6.0, 8.0, 1.0)), (-12.0, hexagon(0.0, 8.5, 9.0, 4.0)), (-22.0, hexagon(0.0, 8.0, 8.0, 3.0))], "glass.glass", "canopy")
    b.box(-4.0, 4.0, -24.0, -18.0, 6.0, 11.0, "steel.panel", "headrest")
    # Reverse-swept wings: root behind, tip forward; a weapon pod at each tip.
    for s in (-1.0, 1.0):
        pts_root = [(s * 8.0, -14.0, -0.8), (s * 8.0, 6.0, -0.8), (s * 8.0, 6.0, 1.8), (s * 8.0, -14.0, 1.8)]
        pts_tip = [(s * 30.0, 4.0, -0.4), (s * 30.0, 14.0, -0.4), (s * 30.0, 14.0, 0.9), (s * 30.0, 4.0, 0.9)]
        _wing(b, pts_root, pts_tip, "livery.livery", "wing")
        b.prism("y", s * 30.0, 10.0, 0.2, 2.2, 22.0, "steel.dark", 6, "wing_pod")
        b.prism("y", s * 30.0, 24.0, 0.2, 1.2, 8.0, "steel.dark", 6, "wing_gun")
        b.pin("hp_%d" % (1 if s < 0 else 2), (s * 30.0, 14.0, 0.2))
    # Boosters: two big six-sided drums under and behind the cockpit, red glow at the back.
    for s in (-1.0, 1.0):
        b.prism("y", s * 7.5, -32.0, -1.0, 6.0, 28.0, "steel.panel", 6, "booster", phase=math.pi / 6)
        b.prism("y", s * 7.5, -47.0, -1.0, 6.5, 2.0, "steel.engine", 6, "booster_ring", phase=math.pi / 6)
        b.loft([(-48.0, hexagon(s * 7.5, -1.0, 11.0, 9.5)), (-48.5, hexagon(s * 7.5, -1.0, 10.0, 8.5))], "amber.engine", "exhaust")
    # Tail: a boom from the cockpit back over and past the boosters, a fin at its end.
    b.loft([(-20.0, rect(0.0, 6.0, 8.0, 12.0)), (-44.0, rect(0.0, 4.0, 9.0, 12.0)), (-58.0, rect(0.0, 3.0, 9.5, 11.5))], "bone.bone", "tail_boom")
    _wing(b, [(0.0, -58.0, 11.0), (0.0, -46.0, 11.0), (0.0, -46.0, 11.5), (0.0, -58.0, 11.5)],
          [(0.0, -60.0, 22.0), (0.0, -54.0, 22.0), (0.0, -54.0, 22.3), (0.0, -60.0, 22.3)], "livery.livery", "fin")
    for s in (-1.0, 1.0):
        _wing(b, [(s * 1.5, -58.0, 10.0), (s * 1.5, -48.0, 10.0), (s * 1.5, -48.0, 11.0), (s * 1.5, -58.0, 11.0)],
              [(s * 12.0, -60.0, 12.0), (s * 12.0, -55.0, 12.0), (s * 12.0, -55.0, 12.4), (s * 12.0, -60.0, 12.4)], "steel.plate", "tailplane")


def _wing(b, root, tip, material, label):
    """A wing as a loft between two four-point sections given in full 3D."""
    import bmesh
    bm = bmesh.new()
    r = [bm.verts.new(p) for p in root]
    t = [bm.verts.new(p) for p in tip]
    n = len(r)
    for i in range(n):
        try:
            bm.faces.new([r[i], r[(i + 1) % n], t[(i + 1) % n], t[i]])
        except ValueError:
            pass
    for ring in (r, t):
        try:
            bm.faces.new(ring)
        except ValueError:
            pass
    return b._finish(bm, material, label)

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
    # Booms: pivot rings on the flanks at mid-length, big tapered upper booms angled out and
    # forward, forearms dropping to the ground ahead of the cockpit, hydraulic rams on top.
    for s, kind in ((-1.0, "claw"), (1.0, "gun")):
        px = s * 24.0
        # The rotator cuff: a big pivot house pulled back on the flank, a boss on its face,
        # and a gun on top of it (Ryan liked the accident).
        b.box(px - 11.0, px + 11.0, -18.0, 4.0, 22.0, 46.0, "steel.panel", "pivot_house")
        b.prism("x", px + s * 11.0, -7.0, 34.0, 11.0, 4.0, "steel.dark", 8, "pivot_boss")
        b.box(px - 4.0, px + 4.0, -14.0, 2.0, 46.0, 52.0, "steel.plate", "cuff_mount")
        b.prism("y", px, 10.0, 49.0, 2.4, 22.0, "steel.dark", 6, "cuff_gun")
        b.pin("hp_%d" % (3 if s < 0 else 4), (px, 2.0, 49.0))
        start = (px + s * 13.0, -7.0, 34.0)
        elbow, _ = boom(b, start, 42.0, 12.0, s * 3.0, 18.0, 20.0, 14.0, 16.0, "livery.livery2", "upper_boom")
        ram_mid = ((start[0] + elbow[0]) / 2.0, (start[1] + elbow[1]) / 2.0, (start[2] + elbow[2]) / 2.0 + 11.0)
        b.prism("y", ram_mid[0], ram_mid[1], ram_mid[2], 3.0, 28.0, "steel.dark", 6, "ram")
        b.prism("x", elbow[0], elbow[1], elbow[2], 9.0, 18.0, "steel.dark", 6, "elbow")
        wrist, rot = boom(b, elbow, 28.0, 48.0, s * 2.0, 14.0, 15.0, 12.0, 12.0, "steel.plate", "forearm")
        if kind == "claw":
            # The claw, outsized on purpose: a wide knuckle, two hooked fingers spread apart
            # and a thumb from below that closes between them.
            b.prism("x", wrist[0], wrist[1], wrist[2], 9.0, 24.0, "steel.dark", 6, "knuckle")
            for side, yaw, pitch, span, base in ((-1.0, -14.0, -48.0, 28.0, 9.0), (1.0, 14.0, -48.0, 28.0, 9.0), (0.0, 0.0, -100.0, 26.0, 9.0)):
                m = Matrix.Translation(Vector(wrist)) @ Matrix.Rotation(math.radians(pitch), 4, "X") @ Matrix.Rotation(math.radians(yaw), 4, "Z")
                b.loft([(0.0, rect(side * 8.0, base, -4.5, 4.5)), (span * 0.6, rect(side * 8.0, base * 0.7, -3.2, 3.2)),
                        (span, rect(side * 8.0, 1.5, -0.8, 0.8))], "steel.stripe", "prong", m)
        else:
            # A weapons mount: receiver block and a six-sided barrel, the hardpoint on it.
            b.box(wrist[0] - 7.0, wrist[0] + 7.0, wrist[1] - 8.0, wrist[1] + 10.0, wrist[2] - 6.0, wrist[2] + 6.0, "steel.panel", "mount")
            b.prism("y", wrist[0], wrist[1] + 24.0, wrist[2], 3.2, 30.0, "steel.dark", 6, "barrel")
            b.box(wrist[0] - 3.0, wrist[0] + 3.0, wrist[1] + 8.0, wrist[1] + 14.0, wrist[2] + 6.0, wrist[2] + 9.0, "amber.light", "mount_light")
            b.pin("hp_1", (wrist[0], wrist[1] + 10.0, wrist[2]))
    # Deck weapon: a missile box on a turret ring, right of centre.
    b.prism("z", 12.0, -14.0, 47.0, 8.0, 2.0, "steel.dark", 8, "ring")
    b.box(4.0, 20.0, -22.0, -4.0, 48.0, 58.0, "steel.panel", "turret")
    b.box(4.5, 19.5, -4.0, -2.5, 49.0, 57.0, "steel.missile", "missile_face")
    b.pin("hp_2", (12.0, -12.0, 53.0))


badger.maker = "minerva"


def sparrowhawk(b):
    """Kestrel "Sparrowhawk": a small hit-and-run interceptor. Sleek, speed over defence;
    reverse-swept wings whose rear faces run back into the boosters, a faired canopy far
    back, twin nose guns, two big boosters, a tail rooted into the fuselage and riding over
    the boosters, ending in two angled stabilisers. Small but deadly."""
    # Fuselage: a flattened hexagon lofted from a needle nose to a broad rear.
    b.loft([(46.0, diamond(0.0, 0.0, 1.5, 1.0)), (36.0, hexagon(0.0, 0.0, 6.0, 4.0)),
            (18.0, hexagon(0.0, 1.0, 12.0, 7.0)), (0.0, hexagon(0.0, 2.0, 16.0, 9.0)),
            (-16.0, hexagon(0.0, 2.0, 18.0, 10.0)), (-30.0, hexagon(0.0, 1.5, 14.0, 8.0))], "bone.bone", "fuselage")
    b.loft([(38.0, diamond(0.0, 0.5, 2.0, 1.5)), (46.0, diamond(0.0, 0.5, 1.0, 0.7))], "steel.dark", "nose_tip")
    # Twin nose guns, one either side of the nosecone.
    for s in (-1.0, 1.0):
        b.prism("y", s * 4.5, 36.0, -1.0, 1.3, 26.0, "steel.dark", 6, "nose_gun")
        b.box(s * 4.5 - 1.5, s * 4.5 + 1.5, 22.0, 30.0, -2.5, 1.0, "steel.plate", "gun_fairing")
    # Canopy: far back, long and low, faired into the spine rather than a bubble.
    b.loft([(4.0, hexagon(0.0, 6.0, 7.0, 0.5)), (-8.0, hexagon(0.0, 7.4, 9.0, 3.0)),
            (-22.0, hexagon(0.0, 7.6, 9.0, 3.2)), (-34.0, hexagon(0.0, 7.2, 9.0, 3.0))], "glass.glass", "canopy")
    b.loft([(-16.0, hexagon(0.0, 7.6, 9.2, 3.4)), (-35.0, hexagon(0.0, 7.2, 9.2, 3.2))], "steel.panel", "canopy_fairing")
    # A belly under the wing roots, so the underside is coherent where the fuselage ends;
    # the boosters still hang below it, since Kestrel never truly lands.
    b.loft([(12.0, hexagon(0.0, -2.0, 12.0, 5.0)), (-8.0, hexagon(0.0, -2.6, 17.0, 6.0)),
            (-32.0, hexagon(0.0, -2.4, 17.0, 5.6))], "bone.bone", "belly")
    # Reverse-swept wings with a little anhedral, thin and sharp, the root's trailing edge
    # running back into the boosters; a weapon pod and gun at each tip.
    for s in (-1.0, 1.0):
        root = [(s * 8.0, -32.0, -0.6), (s * 8.0, 6.0, -0.6), (s * 8.0, 6.0, 1.4), (s * 8.0, -32.0, 1.4)]
        tip = [(s * 32.0, 6.0, -5.2), (s * 32.0, 14.0, -5.2), (s * 32.0, 14.0, -4.5), (s * 32.0, 6.0, -4.5)]
        _wing(b, root, tip, "livery.livery", "wing")
        b.prism("y", s * 32.0, 10.0, -4.8, 2.2, 22.0, "steel.dark", 6, "wing_pod")
        b.prism("y", s * 32.0, 24.0, -4.8, 1.2, 8.0, "steel.dark", 6, "wing_gun")
        b.pin("hp_%d" % (1 if s < 0 else 2), (s * 32.0, 14.0, -4.8))
    # Boosters: two big six-sided drums under and behind the cockpit, red glow at the back.
    for s in (-1.0, 1.0):
        b.prism("y", s * 7.5, -32.0, -1.0, 6.0, 28.0, "steel.panel", 6, "booster", phase=math.pi / 6)
        b.prism("y", s * 7.5, -47.0, -1.0, 6.5, 2.0, "steel.engine", 6, "booster_ring", phase=math.pi / 6)
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


def _wing(b, root, tip, material, label):
    """A wing as a loft between two four-point sections given in full 3D."""
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


# ---------------------------------------------------------------- structures (the Arsenal)

def _blades(b, x0, x1, y, z, step=12.0, h=16.0, w=2.4):
    """A row of upright blades along a top edge, each a wedge leaning back, so the crown
    reads as a saw rather than teeth (no crenellations: Ryan, 20 September)."""
    x = x0
    while x + w <= x1 + 0.01:
        b.loft([(y - 3.5, rect(x + w / 2, w, z, z + h * 0.35)), (y + 3.5, rect(x + w / 2, w, z, z + h))], "steel.dark", "blade")
        x += step


def _gun(b, x, y, z):
    """A turret ring, a mount and one heavy six-sided barrel, pointing north."""
    b.prism("z", x, y, z + 2.5, 12.0, 5.0, "steel.dark", 6, "ring")
    b.box(x - 7.0, x + 7.0, y - 8.0, y + 8.0, z + 5.0, z + 15.0, "steel.panel", "mount")
    b.prism("y", x, y + 20.0, z + 11.0, 3.6, 34.0, "steel.dark", 6, "barrel")
    b.box(x - 4.0, x + 4.0, y - 11.0, y - 8.0, z + 6.0, z + 13.0, "amber.light", "sight")


def wall(b):
    """One wall segment of the field's emitter line (decided 20 September): a hex wide, the
    gate's wall height, a hazard band, a buttress each face, blades along the top."""
    b.tile_world = 40.0
    W, D, H = 31.0, 12.0, 70.0
    b.box(-W, W, -D - 6.0, D + 6.0, 0.0, 6.0, "steel.dark", "plinth")
    b.box(-W, W, -D, D, 6.0, H, "steel.panel", "wall")
    for f in (-1.0, 1.0):
        b.box(-W, W, f * (D + 0.2), f * (D + 1.4), 20.0, 25.0, "steel.stripe", "band")
        b.loft([(f * D, rect(0.0, 10.0, 6.0, H - 6.0)), (f * (D + 12.0), rect(0.0, 10.0, 6.0, 12.0))], "steel.dark", "buttress")
    _blades(b, -W + 1.0, W - 1.0, D - 2.0, H)
    _blades(b, -W + 1.0, W - 1.0, -D + 2.0, H)


wall.maker = "arsenal"


def gate(b):
    """The gate: the field's projector and the Arsenal's device. Three hexes wide, a low
    wall either side, a gatehouse rising above it with a tall narrow pointed mouth in two
    stepped reveals, two finned six-sided towers with a heavy gun each, blades on every top
    edge, lamps either side of the mouth."""
    b.tile_world = 40.0
    W, D, H = 92.0, 16.0, 70.0
    b.box(-W, W, -D - 8.0, D + 8.0, 0.0, 6.0, "steel.dark", "plinth")
    b.box(-W, W, -D, D, 6.0, H, "steel.panel", "wall")
    GW, GH = 46.0, H + 22.0
    b.box(-GW, GW, -D - 3.0, D + 3.0, 6.0, GH, "steel.panel", "gatehouse")
    MW, MH = 15.0, 64.0
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
        x = s * 66.0
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

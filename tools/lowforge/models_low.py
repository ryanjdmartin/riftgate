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
    # the elbow), a bevelled armour plate over cuff and hinge with the shoulder gun on top
    # of it (Ryan, 22 September: no guns hanging outboard), upper and lower booms of one
    # width, the forearms dropping to the ground ahead of the cockpit.
    ARM = 16.0
    for s, kind in ((-1.0, "claw"), (1.0, "gun")):
        px = s * 22.0
        # The arm sits high enough that the claw rests on the ground, never under it: the
        # model's Z = 0 is the ground, and nothing hangs below it.
        b.box(px - 6.0, px + 6.0, -14.0, 2.0, 30.0, 50.0, "steel.panel", "cuff")
        hinge_x = px + s * 10.0
        b.prism("x", hinge_x, -6.0, 40.0, 11.0, 16.0, "steel.dark", 6, "hinge")
        # The pauldron: a plate over the whole shoulder, wider at its foot, and the gun
        # mounted on it.
        cx = px + s * 5.5
        _rings(b, [[(cx - s * 12.5, -16.0, 50.0), (cx + s * 12.5, -16.0, 50.0), (cx + s * 12.5, 4.0, 50.0), (cx - s * 12.5, 4.0, 50.0)],
                   [(cx - s * 9.5, -14.0, 54.0), (cx + s * 9.5, -14.0, 54.0), (cx + s * 9.5, 2.0, 54.0), (cx - s * 9.5, 2.0, 54.0)]], "steel.plate", "pauldron")
        b.box(cx - 4.0, cx + 4.0, -12.0, 0.0, 54.0, 60.0, "steel.plate", "cannon_mount")
        b.prism("y", cx, 12.0, 57.0, 2.6, 26.0, "steel.dark", 6, "cannon")
        b.pin("hp_%d" % (3 if s < 0 else 4), (cx, 0.0, 57.0))
        start = (hinge_x, -6.0, 40.0)
        elbow, _ = boom(b, start, 42.0, 6.0, 0.0, ARM, ARM, ARM, ARM, "livery.livery2", "upper_boom")   # straight ahead, no yaw
        b.prism("x", elbow[0], elbow[1], elbow[2], 10.0, ARM + 4.0, "steel.dark", 6, "elbow")
        wrist, rot = boom(b, elbow, 28.0, 36.0, 0.0, ARM, ARM, ARM, ARM, "steel.plate", "forearm")
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
                _tine(b, wrist, sx, 0.0, -100.0, 32.0, 8.0, 5.5, "steel.dark", "finger")
            for sx in (-3.0, 3.0):
                _tine(b, wrist, sx, -95.0, 90.0, 24.0, 7.0, 4.5, "steel.dark", "tine")
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
    the boosters, ending in two angled stabilisers. Small but deadly. Reskinned 22 September
    to Kestrel's metals: the body in chrome plate, the wings cobalt, the boosters dark (the
    bone body predated the palettes)."""
    # Fuselage: one piece, a six-sided section lofted from a needle nose to a broad rear.
    # The top tapers sharply toward the nose, the belly shallowly, and the belly carries
    # forward under the wing roots (Ryan, 21 September).
    b.loft([(46.0, _fuse(1.2, 0.6, 0.5)), (36.0, _fuse(6.0, 2.2, 2.0)), (18.0, _fuse(12.0, 3.8, 3.4)),
            (0.0, _fuse(16.0, 6.4, 4.6)), (-16.0, _fuse(18.0, 7.0, 4.8)), (-30.0, _fuse(15.0, 5.4, 4.0))], "steel.plate", "fuselage")
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
        b.prism("y", s * 7.5, -32.0, -1.0, 6.0, 28.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", s * 7.5, -47.0, -1.0, 6.5, 2.0, "amber.engine", 6, "booster_ring", phase=math.pi / 6)   # lit: the amber role glows
        b.loft([(-48.0, hexagon(s * 7.5, -1.0, 11.0, 9.5)), (-48.5, hexagon(s * 7.5, -1.0, 10.0, 8.5))], "amber.engine", "exhaust")
    # Tail: rooted into the fuselage with a keel, riding over the boosters, two angled
    # stabilisers at the end.
    b.loft([(-18.0, rect(0.0, 12.0, 4.0, 12.0)), (-32.0, rect(0.0, 8.0, 7.0, 12.5)),
            (-46.0, rect(0.0, 5.0, 9.0, 12.5)), (-60.0, rect(0.0, 3.0, 9.5, 11.5))], "steel.plate", "tail_boom")
    b.loft([(-30.0, rect(0.0, 4.0, 4.5, 8.0)), (-44.0, rect(0.0, 3.0, 5.5, 9.0))], "steel.dark", "keel")
    for s in (-1.0, 1.0):
        a = math.radians(s * 38.0)
        root = [(s * 1.5, -60.0, 10.5), (s * 1.5, -48.0, 10.5), (s * 1.5, -48.0, 11.5), (s * 1.5, -60.0, 11.5)]
        tip = [(s * 1.5 + 14.0 * math.sin(a), -62.0, 10.5 + 14.0 * math.cos(a)), (s * 1.5 + 14.0 * math.sin(a), -55.0, 10.5 + 14.0 * math.cos(a)),
               (s * 1.5 + 14.0 * math.sin(a), -55.0, 10.9 + 14.0 * math.cos(a)), (s * 1.5 + 14.0 * math.sin(a), -62.0, 10.9 + 14.0 * math.cos(a))]
        _wing(b, root, tip, "livery.livery", "stabiliser")


sparrowhawk.maker = "kestrel"


def clydesdale(b):
    """Wainwright & Sutler "Clydesdale": a massive, boxy, heavily armoured quadruped, the
    wagon-builder's walker, unchanged in a century. An ironclad wagon body, slab-sided in
    riveted iron with chamfered shoulders, on four thick columnar legs that step fore and
    aft only (the notorious turning circle); a low armoured head on a short neck, a visor
    slit under a brow, lamps at the temples; on top a wagon bed in the maker's brown
    carrying the whole payload: two twin-autogun turrets forward, the lance along the spine
    running out past the head, the pocket mortar aft, ablative slabs bolted on the flanks,
    the heat sink and a stack at the tail. Bone-white flared skirts over the hooves, the
    namesake's feathering. First pass from the content's fantasy (22 September)."""
    # The body: an ironclad casemate, one loft from tail to shoulders with a short taper
    # to the neck. A keel under it, a hitch at the tail.
    b.loft([(-36.0, _case(36.0, 26.0, 46.0, 5.0)), (22.0, _case(36.0, 26.0, 46.0, 5.0)), (30.0, _case(30.0, 27.0, 44.0, 4.0))], "steel.panel", "hull")
    b.box(-10.0, 10.0, -30.0, 18.0, 23.0, 26.0, "steel.dark", "keel")
    b.box(-3.0, 3.0, -42.0, -36.0, 24.0, 28.0, "steel.dark", "hitch")
    # The neck and head: lower than the body, so it reads as an animal and not a tank.
    b.loft([(30.0, rect(0.0, 26.0, 30.0, 44.0)), (36.0, rect(0.0, 22.0, 24.0, 40.0))], "steel.plate", "neck")
    b.box(-12.0, 12.0, 36.0, 52.0, 20.0, 38.0, "steel.panel", "head")
    b.box(-13.0, 13.0, 44.0, 53.5, 38.0, 41.5, "steel.plate", "brow")
    b.box(-10.0, 10.0, 52.0, 53.0, 28.0, 34.0, "glass.glass", "visor")
    b.box(-9.0, 9.0, 48.0, 54.0, 20.0, 25.0, "steel.dark", "chin")
    for s in (-1.0, 1.0):
        b.box(min(s * 12.0, s * 13.5), max(s * 12.0, s * 13.5), 44.0, 49.0, 30.0, 35.0, "amber.light", "lamp")
    # The legs: a hip cuff on the flank, a hinge pin, a thigh angling out and (fore pair)
    # forward or (hind pair) back, a knee, a shin straight down into a flared bone skirt
    # and a broad hoof. Nothing hangs below z = 0, the ground.
    for yh, splay in ((16.0, 6.0), (-24.0, -6.0)):
        for s in (-1.0, 1.0):
            hip = (s * 26.0, yh, 37.0)
            knee = (s * 30.0, yh + splay, 20.0)
            ankle = (s * 30.0, yh + splay * 1.5, 6.0)
            b.box(min(s * 18.0, s * 24.0), max(s * 18.0, s * 24.0), yh - 7.0, yh + 7.0, 30.0, 44.0, "steel.panel", "hip")
            b.prism("x", hip[0], hip[1], hip[2], 6.0, 6.0, "steel.dark", 6, "hip_pin")
            _beam(b, hip, knee, _sq(10.0, 12.0), _sq(9.0, 10.0), "steel.plate", "thigh")
            b.prism("x", knee[0], knee[1], knee[2], 5.5, 12.0, "steel.dark", 6, "knee")
            _beam(b, knee, ankle, _sq(8.0, 9.0), _sq(8.0, 8.0), "steel.panel", "shin")
            _rings(b, [[(ankle[0] + u, ankle[1] + v, 12.0) for u, v in _sq(9.0, 9.0)],
                       [(ankle[0] + u, ankle[1] + v, 3.0) for u, v in _sq(16.0, 16.0)]], "bone.bone", "feather")
            b.box(ankle[0] - 7.0, ankle[0] + 7.0, ankle[1] - 8.0, ankle[1] + 8.0, 0.0, 5.0, "steel.dark", "hoof")
    # The bed: a deck plate and low boards round it in the maker's brown, the wagon's own.
    b.box(-19.0, 19.0, -34.0, 20.0, 46.0, 48.0, "steel.plate", "deck")
    for s in (-1.0, 1.0):
        b.box(min(s * 19.0, s * 22.0), max(s * 19.0, s * 22.0), -35.0, 21.0, 46.0, 56.0, "livery.livery2", "bed_side")
    b.box(-22.0, 22.0, 18.0, 21.0, 46.0, 54.0, "livery.livery2", "bed_front")
    b.box(-22.0, 22.0, -35.0, -32.0, 46.0, 54.0, "livery.livery2", "bed_tail")
    # Twin autoguns: a turret ring, a mount and two barrels, one turret each side forward.
    for s in (-1.0, 1.0):
        tx = s * 11.0
        b.prism("z", tx, 8.0, 49.0, 6.0, 2.0, "steel.dark", 8, "ring")
        b.box(tx - 5.0, tx + 5.0, 3.0, 13.0, 50.0, 60.0, "steel.panel", "turret")
        for s2 in (-1.0, 1.0):
            b.prism("y", tx + s2 * 2.6, 24.0, 56.0, 1.8, 22.0, "steel.dark", 6, "autogun")
        b.box(tx - 2.0, tx + 2.0, 13.0, 15.0, 57.0, 59.0, "amber.light", "sight")
        b.pin("hp_%d" % (1 if s < 0 else 2), (tx, 8.0, 56.0))
    # The lance: a breech block aft of centre, saddles along the deck, one long six-sided
    # rail out past the head, a collar, a lit emitter at the point.
    b.box(-5.0, 5.0, -24.0, -6.0, 48.0, 61.0, "steel.panel", "breech")
    b.box(-3.5, 3.5, 6.0, 10.0, 48.0, 54.0, "steel.dark", "saddle")
    _beam(b, (0.0, -26.0, 57.0), (0.0, 64.0, 57.0), _poly(3.4, 6), _poly(2.8, 6), "steel.dark", "lance")
    b.prism("y", 0.0, 24.0, 57.0, 4.8, 5.0, "steel.plate", 6, "guard")
    _beam(b, (0.0, 64.0, 57.0), (0.0, 72.0, 57.0), _poly(2.8, 6), _poly(0.8, 6), "amber.light", "emitter")
    b.pin("hp_3", (0.0, -15.0, 57.0))
    # The pocket mortar aft on the deck, a stubby tube pitched up and forward on a base.
    b.prism("z", -9.0, -24.0, 49.5, 5.0, 3.0, "steel.dark", 8, "mortar_base")
    _beam(b, (-9.0, -24.0, 51.0), (-9.0, -16.0, 65.0), _poly(4.0, 6), _poly(4.4, 6), "steel.panel", "mortar")
    _beam(b, (-9.0, -16.0, 65.0), (-9.0, -15.0, 66.8), _poly(4.4, 6), _poly(3.2, 6), "steel.dark", "muzzle")
    b.pin("hp_4", (-9.0, -20.0, 58.0))
    # Ablative plating: two bolted slabs each flank, standing proud of the hull.
    for s in (-1.0, 1.0):
        for y0, y1 in ((-30.0, -9.0), (-6.0, 15.0)):
            b.box(min(s * 18.0, s * 21.5), max(s * 18.0, s * 21.5), y0, y1, 28.0, 44.0, "steel.plate", "ablative")
    b.pin("hp_5", (-21.5, -7.0, 36.0))
    # The heat sink across the tail, its stack up through the bed.
    b.box(-13.0, 13.0, -40.0, -36.0, 28.0, 44.0, "steel.vent", "heat_sink")
    b.prism("z", 9.0, -28.0, 58.0, 2.8, 20.0, "steel.dark", 6, "stack")
    b.pin("hp_6", (0.0, -38.0, 36.0))


clydesdale.maker = "wainwright_sutler"


def baboon(b):
    """Aphelion "Baboon" (the Mandrill until 28 September): a long-armed, stubby-legged plantigrade walker, orangutan and
    troll at once, its high-tech suite riding on a backpack (Ryan's brief, 26 September).
    White pearl plate with red markings. Fourth pass on Ryan's notes: stumpier legs and
    longer forearms, to sell the proportions at the game's size; the limbs are straight
    tapered octagonal members with their tiles mapped along the member (the world-axis
    seams cut diagonally across them before); the fists are blocks whose front face
    carries one fist tile, knuckles forward as a BattleTech mech holds them, a thumb block
    proud on the outside, the Pulse Repeater on the right one. Kept: the barrel torso, the
    sensor pod with its red eye, the shoulder cannons and the backpack. Every number is a
    proportion Ryan may change."""
    OCT = lambda r: _poly(r, 8, math.pi / 8)
    Z0 = -5.0   # the upper body rides this much lower than the third pass: the legs got shorter
    # Feet and legs: plantigrade, the whole sole on the ground; knee forward of the ankle,
    # hip behind it, the leg a squat zigzag, thick and short.
    for s in (-1.0, 1.0):
        cx = s * 13.0
        b.loft([(-13.0, rect(cx, 15.0, 0.0, 7.0)), (2.0, rect(cx, 17.0, 0.0, 8.5)), (17.0, rect(cx, 15.0, 0.0, 4.0))], "steel.plate", "foot")
        b.box(cx - 8.0, cx + 8.0, 14.0, 18.0, 0.0, 3.0, "steel.dark", "toe_cap")
        ankle = (cx, -1.0, 8.0)
        knee = (cx, 8.0, 19.0)
        hip = (cx * 0.85, -4.0, 25.0)
        b.prism("x", ankle[0], ankle[1], ankle[2], 4.4, 13.0, "steel.dark", 6, "ankle")
        _beam(b, ankle, knee, OCT(5.4), OCT(4.8), "steel.panel", "shin")
        b.prism("x", knee[0], knee[1], knee[2], 5.4, 12.0, "steel.dark", 6, "knee")
        _beam(b, knee, hip, OCT(5.8), OCT(6.2), "steel.plate", "thigh")
        b.box(cx - 5.0, cx + 5.0, 10.5, 13.5, 10.0, 17.0, "livery.livery2", "shin_plate")
        b.prism("x", hip[0], hip[1], hip[2], 5.4, 8.0, "steel.dark", 6, "hip")
    # The waist: a drum.
    b.prism("x", 0.0, -4.0, 32.0 + Z0, 6.5, 32.0, "steel.panel", 8, "pelvis", phase=math.pi / 8)
    # The torso: a barrel of chamfered decks, widest at the chest, upright.
    _rings(b, [_deck(30.0, 22.0, -2.0, 36.0 + Z0, 4.0), _deck(40.0, 28.0, 0.0, 46.0 + Z0, 5.0),
               _deck(40.0, 28.0, 0.0, 56.0 + Z0, 5.0), _deck(32.0, 22.0, 0.0, 62.0 + Z0, 4.0)], "steel.panel", "torso")
    b.box(-12.0, 12.0, 12.0, 15.0, 44.0 + Z0, 58.0 + Z0, "steel.plate", "chest_plate")
    b.box(-10.0, 10.0, 15.0, 16.5, 48.0 + Z0, 52.0 + Z0, "livery.livery", "chevron")
    # The sensor pod: low between the shoulders, one red eye, a brow plate over it.
    b.box(-8.0, 8.0, 8.0, 22.0, 60.0 + Z0, 68.0 + Z0, "steel.dark", "sensor_pod")
    b.box(-6.0, 6.0, 22.0, 23.0, 62.0 + Z0, 66.0 + Z0, "amber.engine", "eye")
    b.box(-9.0, 9.0, 6.0, 24.0, 68.0 + Z0, 70.5 + Z0, "steel.plate", "brow")
    # Shoulders: red pauldrons, an octagonal drum each, low on the torso's shoulder, with
    # an Umbra Projector riding on top (hp_1 left, hp_2 right).
    for s in (-1.0, 1.0):
        px = s * 25.0
        b.prism("x", px, 0.0, 57.0 + Z0, 9.0, 14.0, "livery.livery", 8, "pauldron", phase=math.pi / 8)
        b.prism("x", px, 0.0, 57.0 + Z0, 4.0, 15.0, "steel.dark", 6, "shoulder_pin")
        b.box(px - 4.0, px + 4.0, -2.0, 6.0, 60.0 + Z0, 65.0 + Z0, "steel.plate", "projector_mount")
        b.prism("y", px, 12.0, 63.0 + Z0, 3.2, 20.0, "steel.dark", 6, "umbra_projector")
        b.prism("y", px, 23.0, 63.0 + Z0, 2.2, 3.0, "amber.engine", 6, "emitter")
        b.pin("hp_%d" % (1 if s < 0 else 2), (px, 16.0, 63.0 + Z0))
        # The arm (the Pulse Repeater's pin on the right hand is hp_5): the elbow back and
        # out behind the shoulder, the forearm forward and down to a wrist drum under the
        # shoulder, so the fist hangs straight from it (Ryan, 28 September: arms back,
        # elbows bent). The fist hangs from the drum with its top face level.
        shoulder = (s * 31.0, 0.0, 54.0 + Z0)
        elbow = (s * 38.0, -13.0, 39.0 + Z0)
        wrist = (s * 38.0, 3.0, 22.0 + Z0)
        b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.5, 8.0, "steel.dark", 6, "shoulder_joint")
        _beam(b, shoulder, elbow, OCT(5.2), OCT(4.6), "steel.plate", "upper_arm")
        b.prism("x", elbow[0], elbow[1], elbow[2], 5.5, 12.0, "steel.dark", 6, "elbow")
        _beam(b, elbow, wrist, OCT(4.6), OCT(5.0), "steel.panel", "forearm")
        band0 = tuple(elbow[i] + (wrist[i] - elbow[i]) * 0.3 for i in range(3))
        band1 = tuple(elbow[i] + (wrist[i] - elbow[i]) * 0.5 for i in range(3))
        _beam(b, band0, band1, OCT(5.3), OCT(5.3), "livery.livery2", "forearm_band")
        b.prism("x", wrist[0], wrist[1], wrist[2], 4.6, 13.0, "steel.dark", 6, "wrist")
        _fist(b, wrist[0], wrist[1] - 7.0, wrist[1] + 7.0, wrist[2] - 16.5, wrist[2] - 3.5, 14.0, -s)   # the inner side faces the body
        if s < 0:
            # The left hand's outside is a socket too (hp_6): seven hardpoints need seven pins.
            b.box(wrist[0] - 8.5, wrist[0] - 7.0, wrist[1] - 5.0, wrist[1] + 5.0, wrist[2] - 13.0, wrist[2] - 7.0, "steel.plate", "left_mount")
            b.pin("hp_6", (wrist[0] - 9.5, wrist[1] + 5.0, wrist[2] - 10.0))
        if s > 0:
            # The Pulse Repeater on the outside of the right hand (hp_5).
            gx = wrist[0] + 9.5
            b.box(gx - 2.5, gx + 2.5, wrist[1] - 5.0, wrist[1] + 5.0, wrist[2] - 13.0, wrist[2] - 7.0, "steel.plate", "repeater_mount")
            b.prism("y", gx, wrist[1] + 5.0, wrist[2] - 10.0, 2.0, 18.0, "steel.dark", 6, "pulse_repeater")
            b.prism("y", gx, wrist[1] + 14.5, wrist[2] - 10.0, 1.4, 1.5, "amber.engine", 6, "repeater_tip")
            b.pin("hp_5", (gx, wrist[1] + 5.0, wrist[2] - 10.0))
    # The backpack: a tall rack, red stripes down its sides, two flare pods on top (the
    # fixed component, the Solar Flare Array: built in, so no pin), the Corona dish on its
    # right rear (hp_3), the vent block on its left rear (hp_4), a mount on its right flank (hp_7), a mast with a red light
    # between the pods, and a row of small lit ports across the rack's back.
    b.box(-17.0, 17.0, -26.0, -14.0, 34.0 + Z0, 68.0 + Z0, "steel.panel", "rack")
    for s in (-1.0, 1.0):
        b.box(min(s * 17.0, s * 18.5), max(s * 17.0, s * 18.5), -25.0, -15.0, 38.0 + Z0, 64.0 + Z0, "livery.livery", "rack_stripe")
        b.prism("z", s * 10.0, -20.0, 74.0 + Z0, 5.0, 14.0, "steel.dark", 6, "flare_pod")
        b.prism("z", s * 10.0, -20.0, 81.5 + Z0, 5.5, 1.5, "steel.plate", 6, "pod_cap")
    b.prism("y", 11.0, -27.5, 54.0 + Z0, 7.0, 3.0, "steel.plate", 8, "corona_dish")
    b.prism("y", 11.0, -29.5, 54.0 + Z0, 2.6, 1.0, "amber.engine", 8, "dish_core")
    b.pin("hp_3", (11.0, -28.0, 54.0 + Z0), forward=(0.0, -1.0, 0.0))
    b.box(-16.0, -2.0, -28.5, -26.0, 38.0 + Z0, 52.0 + Z0, "steel.vent", "vent_block")
    b.pin("hp_4", (-9.0, -27.0, 45.0 + Z0), forward=(0.0, -1.0, 0.0))
    # A socket on the rack's right flank (hp_7), a small hard mount on the stripe.
    b.box(18.5, 21.0, -23.0, -17.0, 46.0 + Z0, 54.0 + Z0, "steel.plate", "flank_mount")
    b.pin("hp_7", (21.0, -20.0, 50.0 + Z0), forward=(1.0, 0.0, 0.0))
    for i in range(3):
        b.box(-12.0 + i * 8.0, -8.0 + i * 8.0, -27.0, -26.0, 60.0 + Z0, 62.0 + Z0, "amber.engine", "rack_port")
    b.prism("z", 0.0, -20.0, 80.0 + Z0, 1.2, 24.0, "steel.dark", 6, "mast")
    b.prism("z", 0.0, -20.0, 93.0 + Z0, 2.0, 3.0, "amber.engine", 6, "mast_light")


baboon.maker = "aphelion"


# ---------------------------------------------------------------- the 28 September machines
# First passes from the briefs in content/chassis.json (Ryan's fantasies), for him to move
# by render. Every number is a proportion.

def armadillo(b):
    """Minerva "Armadillo" (HW-22T Heavy Weapons Carrier): a squat, heavily armoured quad
    walker on short thick legs, its back a shell of overlapping armour bands (the namesake)
    bristling with weapons from shuttered ports, the cockpit tucked under the front lip of
    the shell for reduced visibility and extra protection. The Faraday Shutters are the
    ports' shutter frames themselves (fixed, no pin). Pins: hp_1 the left port (Rivet Gun),
    hp_2 the right port (Slug Cannon), hp_3 the rear deck (Missile Rack), hp_4 the left
    flank slab (Ablative Plating), hp_5 the stack at the tail (Blowout Stack)."""
    # The shell: five armour bands from tail to brow, each a chamfered casemate section a
    # little wider and higher toward the middle, standing proud of its neighbour so the
    # seams read as bands. Panel and plate alternate.
    bands = [(-34.0, -22.0, 40.0, 30.0, 6.0), (-23.0, -9.0, 50.0, 36.0, 7.0), (-10.0, 6.0, 56.0, 40.0, 8.0),
             (5.0, 20.0, 54.0, 38.0, 8.0), (19.0, 32.0, 48.0, 33.0, 7.0)]
    for i, (y0, y1, w, top, c) in enumerate(bands):
        tile = "steel.panel" if i % 2 == 0 else "steel.plate"
        b.loft([(y0, _case(w, 14.0, top, c)), (y1, _case(w, 14.0, top, c))], tile, "band")
    # The brow: the front band runs on as a lip over the cockpit bay.
    b.loft([(30.0, _case(46.0, 26.0, 33.0, 6.0)), (40.0, _case(40.0, 28.0, 31.0, 5.0))], "steel.plate", "brow")
    b.box(-14.0, 14.0, 39.0, 40.5, 27.0, 30.0, "steel.hazard", "brow_lip")
    # The cockpit under the lip: a dark bay and a glass slit set back in it.
    b.box(-13.0, 13.0, 30.0, 37.0, 16.0, 27.0, "steel.dark", "cockpit_bay")
    b.box(-10.0, 10.0, 36.5, 37.5, 20.0, 24.0, "glass.glass", "visor")
    for s in (-1.0, 1.0):
        b.box(s * 16.0 - 2.0, s * 16.0 + 2.0, 35.0, 38.0, 22.0, 25.0, "amber.light", "lamp")
    # The belly and the keel plate under it.
    b.box(-20.0, 20.0, -32.0, 30.0, 10.0, 14.5, "steel.dark", "belly")
    # The legs: four stubby columns, a hip cuff under each flank, a short thick thigh
    # splayed out and a shin down onto a broad flat foot. Nothing below the ground.
    for yh in (18.0, -20.0):
        for s in (-1.0, 1.0):
            hip = (s * 22.0, yh, 16.0)
            knee = (s * 29.0, yh, 9.0)
            b.prism("x", hip[0], hip[1], hip[2], 5.0, 8.0, "steel.dark", 6, "hip")
            _beam(b, hip, knee, _sq(9.0, 9.0), _sq(8.0, 8.0), "steel.plate", "thigh")
            b.prism("x", knee[0], knee[1], knee[2], 4.6, 10.0, "steel.dark", 6, "knee")
            b.box(knee[0] - 5.0, knee[0] + 5.0, yh - 5.0, yh + 5.0, 3.0, 9.0, "steel.panel", "shin")
            b.box(knee[0] - 7.0, knee[0] + 7.0, yh - 7.0, yh + 7.0, 0.0, 3.0, "steel.dark", "foot")
    # The weapon ports: shuttered frames set into the shell's crown, a stripe-edged
    # frame each with a dark mouth and a shutter plate half drawn. The Faraday Shutters.
    for s, y, kind in ((-1.0, 2.0, "rivet"), (1.0, 2.0, "slug")):
        px = s * 13.0
        b.box(px - 8.0, px + 8.0, y - 8.0, y + 8.0, 39.0, 43.0, "steel.stripe", "port_frame")
        b.box(px - 6.0, px + 6.0, y - 6.0, y + 6.0, 39.5, 43.5, "bore.dark", "port_mouth")
        b.box(px - 6.5, px + 6.5, y - 6.5, y - 1.0, 43.5, 45.0, "steel.plate", "shutter")
        if kind == "rivet":
            # The rivet gun: a squat receiver and a fat short barrel with a magazine drum.
            b.box(px - 4.0, px + 4.0, y - 4.0, y + 6.0, 44.0, 51.0, "steel.panel", "rivet_receiver")
            b.prism("y", px, y + 14.0, 48.0, 2.6, 16.0, "steel.dark", 6, "rivet_barrel")
            b.prism("x", px + s * 6.0, y, 48.0, 3.6, 5.0, "steel.dark", 8, "rivet_drum")
            b.pin("hp_1", (px, y + 2.0, 48.0))
        else:
            # The slug cannon: a mount block and one long heavy barrel with a muzzle collar.
            b.box(px - 4.0, px + 4.0, y - 4.0, y + 6.0, 44.0, 51.0, "steel.panel", "slug_mount")
            b.prism("y", px, y + 20.0, 48.0, 3.0, 28.0, "steel.dark", 6, "slug_barrel")
            b.prism("y", px, y + 33.0, 48.0, 3.6, 3.0, "steel.plate", 6, "muzzle")
            b.pin("hp_2", (px, y + 2.0, 48.0))
    # The rear deck: a missile box on a low ring behind the ports, its face one tile.
    b.prism("z", 0.0, -16.0, 39.0, 8.0, 2.0, "steel.dark", 8, "ring")
    b.box(-7.0, 7.0, -24.0, -10.0, 40.0, 52.0, "steel.panel", "missile_box")
    b.box(-7.0, 7.0, -9.6, -8.6, 40.0, 52.0, "steel.missile", "missile_face")
    b.pin("hp_3", (0.0, -14.0, 46.0))
    # Ablative slabs on both flanks, bolted proud of the bands; the left one is the pin.
    for s in (-1.0, 1.0):
        for y0, y1 in ((-20.0, -4.0), (0.0, 16.0)):
            b.box(min(s * 27.0, s * 30.0), max(s * 27.0, s * 30.0), y0, y1, 20.0, 34.0, "livery.livery2", "ablative")
    b.pin("hp_4", (-30.0, -2.0, 27.0), forward=(-1.0, 0.0, 0.0))
    # The blowout stack at the tail: a chimney with a hinged cap, vents beside it.
    b.prism("z", 8.0, -30.0, 42.0, 4.0, 16.0, "steel.dark", 6, "stack")
    b.prism("z", 8.0, -30.0, 51.0, 5.0, 2.0, "steel.plate", 6, "stack_cap")
    b.box(-14.0, 0.0, -35.0, -34.0, 20.0, 30.0, "steel.vent", "tail_vents")
    b.pin("hp_5", (8.0, -30.0, 46.0), forward=(0.0, 0.0, 1.0))


armadillo.maker = "minerva"


def wild_boar(b):
    """Minerva "Wild Boar" (AB-70R Assault Breacher): an unstoppable assault tank with a
    front plow and rams, for breaching emplacements or driving through fodder. Treads,
    a long low hull with a steep glacis, a squat turret, a big blade across the whole front
    and two tusk rams thrust out of it (the Breaching Plow, fixed, no pin). Pins: hp_1 the
    turret gun (Slug Cannon), hp_2 the rear box (Missile Rack), hp_3 the flank slabs
    (Ablative Plating), hp_4 the stack (Blowout Stack)."""
    # Treads: long and wide, chamfered both ends, a skirt plate over each.
    for s in (-1.0, 1.0):
        cx = s * 24.0
        b.loft([(-40.0, rect(cx, 22.0, 5.0, 11.0)), (-33.0, rect(cx, 22.0, 0.0, 19.0)),
                (26.0, rect(cx, 22.0, 0.0, 19.0)), (33.0, rect(cx, 22.0, 5.0, 11.0))], "bore.tread", "tread")
        b.box(cx - 12.0, cx + 12.0, -36.0, 28.0, 18.0, 22.0, "steel.plate", "skirt")
    # The hull: low between the treads, a steep glacis at the front, the deck stepping up
    # to the turret ring.
    b.loft([(-36.0, rect(0.0, 40.0, 18.0, 34.0)), (12.0, rect(0.0, 40.0, 18.0, 34.0)), (30.0, rect(0.0, 36.0, 18.0, 22.0))], "steel.panel", "hull")
    b.loft([(-30.0, rect(0.0, 30.0, 34.0, 40.0)), (4.0, rect(0.0, 30.0, 34.0, 40.0)), (10.0, rect(0.0, 26.0, 34.0, 36.0))], "steel.plate", "deck")
    # The driver's slit low on the glacis, lamps either side.
    b.box(-6.0, 6.0, 26.0, 27.0, 26.0, 29.0, "glass.glass", "slit")
    for s in (-1.0, 1.0):
        b.box(s * 12.0 - 2.0, s * 12.0 + 2.0, 25.0, 27.5, 27.0, 30.0, "amber.light", "lamp")
    # The plow: a blade the width of the machine, leaning back from its edge on the ground
    # to a top lip at deck height, its edge hazard-striped; two tusks out of its face, and
    # pushing beams back to the hull.
    _rings(b, [[(-34.0, 46.0, 0.0), (34.0, 46.0, 0.0), (34.0, 44.0, 2.0), (-34.0, 44.0, 2.0)],
               [(-34.0, 36.0, 24.0), (34.0, 36.0, 24.0), (34.0, 33.0, 26.0), (-34.0, 33.0, 26.0)]], "steel.plate", "blade")
    b.box(-34.0, 34.0, 33.0, 37.0, 25.0, 28.0, "steel.hazard", "blade_lip")
    for s in (-1.0, 1.0):
        _beam(b, (s * 16.0, 30.0, 20.0), (s * 16.0, 40.0, 14.0), _sq(6.0, 6.0), _sq(6.0, 6.0), "steel.dark", "push_beam")
        _beam(b, (s * 12.0, 40.0, 12.0), (s * 10.0, 62.0, 18.0), _poly(3.4, 6), _poly(1.2, 6), "steel.dark", "tusk")
    # The turret: an eight-sided drum on a ring, one heavy gun out over the plow (hp_1),
    # a hatch and a sight.
    b.prism("z", 0.0, -8.0, 41.0, 11.0, 2.0, "steel.dark", 8, "ring")
    b.prism("z", 0.0, -8.0, 47.0, 12.0, 10.0, "steel.panel", 8, "turret", phase=math.pi / 8)
    b.box(-5.0, 5.0, 0.0, 6.0, 44.0, 50.0, "steel.plate", "mantlet")
    b.prism("y", 0.0, 24.0, 47.0, 3.2, 40.0, "steel.dark", 6, "gun")
    b.prism("y", 0.0, 43.0, 47.0, 4.0, 4.0, "steel.plate", 6, "muzzle")
    b.box(-4.0, 4.0, -14.0, -6.0, 52.0, 54.0, "steel.plate", "hatch")
    b.box(6.0, 9.0, -4.0, 2.0, 52.0, 55.0, "amber.light", "sight")
    b.pin("hp_1", (0.0, 6.0, 47.0))
    # The rear box: missiles on the back deck, its face one tile (hp_2).
    b.box(-7.0, 7.0, -36.0, -24.0, 40.0, 54.0, "steel.panel", "missile_box")
    b.box(-7.0, 7.0, -23.6, -22.6, 40.0, 54.0, "steel.missile", "missile_face")
    b.pin("hp_2", (0.0, -30.0, 47.0))
    # Ablative slabs down both flanks over the skirts (hp_3 on the left).
    for s in (-1.0, 1.0):
        for y0, y1 in ((-30.0, -12.0), (-8.0, 10.0)):
            b.box(min(s * 20.0, s * 23.0), max(s * 20.0, s * 23.0), y0, y1, 23.0, 33.0, "livery.livery2", "ablative")
    b.pin("hp_3", (-23.0, -10.0, 28.0), forward=(-1.0, 0.0, 0.0))
    # The blowout stack at the tail right, and the exhausts and rear vents.
    b.prism("z", 14.0, -32.0, 44.0, 3.6, 18.0, "steel.dark", 6, "stack")
    b.prism("z", 14.0, -32.0, 54.0, 4.6, 2.0, "steel.plate", 6, "stack_cap")
    b.box(-16.0, 4.0, -39.0, -36.0, 22.0, 32.0, "steel.vent", "rear_vents")
    b.pin("hp_4", (14.0, -32.0, 49.0), forward=(0.0, 0.0, 1.0))
    # A floodlight bar over the glacis.
    b.box(-14.0, 14.0, 8.0, 11.0, 40.0, 43.0, "amber.light", "light_bar")


wild_boar.maker = "minerva"


def _wheel(b, cx, cy, r, w, label="wheel"):
    """An eight-sided wheel across x: rubber tread with a dark hub."""
    b.prism("x", cx, cy, r, r, w, "bore.tread", 8, label, phase=math.pi / 8)
    b.prism("x", cx, cy, r, r * 0.45, w + 1.0, "steel.dark", 6, label + "_hub")


def _buggy(b, half_w, nose, tail, top, tile):
    """A Wainwright & Sutler car's common bones: four big wheels on stub axles, a low tub
    between them with a sloped hood, a dark undertray. `half_w` is to the wheel centres,
    `nose` and `tail` the tub's ends, `top` the tub's deck height."""
    R = 8.5
    for yw in (nose - 12.0, tail + 12.0):
        for s in (-1.0, 1.0):
            _wheel(b, s * half_w, yw, R, 7.0)
            b.prism("x", s * (half_w - 6.0), yw, R, 2.0, 8.0, "steel.dark", 6, "axle")
    hw = half_w - 6.0
    b.box(-hw, hw, tail, nose - 10.0, 5.0, 9.0, "steel.dark", "undertray")
    b.loft([(tail, rect(0.0, hw * 2.0, 9.0, top)), (nose - 12.0, rect(0.0, hw * 2.0, 9.0, top)),
            (nose, rect(0.0, hw * 1.7, 9.0, top - 6.0))], tile, "tub")
    for s in (-1.0, 1.0):
        b.box(min(s * hw, s * (hw + 1.5)), max(s * hw, s * (hw + 1.5)), tail + 2.0, nose - 14.0, 10.0, top - 1.0, "livery.livery2", "flank_stripe")


def prairie_dog(b):
    """Wainwright & Sutler "Prairie Dog" (Pattern 9 Scout Car): a fast, agile, lightly
    armoured skirmisher that skims in and out of a fight. A four-wheeled open buggy in the
    maker's iron and brown: big wheels, a low tub, an open cab with a windscreen and a
    roll cage, a pintle-mounted scattergun at the back (the Flakshot Repeater, fixed, no
    pin), and a tall sensor mast standing up out of the tail like the namesake on watch.
    Pins: hp_1 the hood guns (Twin Autoguns), hp_2 the left rail launcher (Incendiary
    Shells), hp_3 the right skirt plate (Flak Skirt)."""
    _buggy(b, 20.0, 30.0, -28.0, 20.0, "steel.panel")
    # The cab: a seat block, a raked windscreen, a dash, and a roll cage of thin dark bars.
    b.box(-8.0, 8.0, -12.0, 0.0, 20.0, 27.0, "steel.dark", "seat")
    b.loft([(6.0, rect(0.0, 20.0, 20.0, 21.0)), (12.0, rect(0.0, 20.0, 20.0, 30.0))], "glass.glass", "windscreen")
    b.box(-10.0, 10.0, 4.0, 7.0, 20.0, 22.0, "steel.plate", "dash")
    for s in (-1.0, 1.0):
        _beam(b, (s * 12.0, 12.0, 20.0), (s * 12.0, 4.0, 36.0), _sq(1.6, 1.6), _sq(1.6, 1.6), "steel.dark", "cage")
        _beam(b, (s * 12.0, 4.0, 36.0), (s * 12.0, -16.0, 36.0), _sq(1.6, 1.6), _sq(1.6, 1.6), "steel.dark", "cage")
        _beam(b, (s * 12.0, -16.0, 36.0), (s * 12.0, -20.0, 20.0), _sq(1.6, 1.6), _sq(1.6, 1.6), "steel.dark", "cage")
    _beam(b, (-12.0, 4.0, 36.0), (12.0, 4.0, 36.0), _sq(1.6, 1.6), _sq(1.6, 1.6), "steel.dark", "cage")
    _beam(b, (-12.0, -16.0, 36.0), (12.0, -16.0, 36.0), _sq(1.6, 1.6), _sq(1.6, 1.6), "steel.dark", "cage")
    # The pintle gun at the back: a post, a swivel, a drum magazine and a short fat barrel
    # over the cab. The Flakshot Repeater.
    b.prism("z", 0.0, -22.0, 27.0, 1.8, 14.0, "steel.dark", 6, "pintle")
    b.box(-3.0, 3.0, -25.0, -18.0, 34.0, 39.0, "steel.plate", "swivel")
    b.prism("x", 4.5, -21.0, 37.0, 3.6, 4.0, "steel.dark", 8, "flak_drum")
    b.prism("y", 0.0, -10.0, 37.5, 2.2, 16.0, "steel.dark", 6, "flak_barrel")
    b.prism("y", 0.0, -1.5, 37.5, 2.8, 2.0, "steel.plate", 6, "flak_muzzle")
    # The mast: a thin post up out of the tail's right corner with a sensor head, a red
    # light on top. The dog sitting up.
    b.prism("z", 11.0, -25.0, 34.0, 1.2, 28.0, "steel.dark", 4, "mast")
    b.box(8.5, 13.5, -27.5, -22.5, 48.0, 54.0, "steel.panel", "sensor_head")
    b.box(9.5, 12.5, -22.4, -21.6, 49.5, 52.5, "glass.glass", "sensor_eye")
    b.prism("z", 11.0, -25.0, 55.5, 1.6, 3.0, "amber.engine", 6, "mast_light")
    # The hood guns: twin autoguns in a low fairing on the hood (hp_1).
    b.box(-6.0, 6.0, 14.0, 22.0, 14.0, 18.0, "steel.plate", "gun_fairing")
    for s in (-1.0, 1.0):
        b.prism("y", s * 3.0, 30.0, 16.5, 1.4, 20.0, "steel.dark", 6, "autogun")
    b.pin("hp_1", (0.0, 18.0, 16.5))
    # The launcher rail on the left flank: a rack of four tubes in the missile tile (hp_2).
    b.box(-19.0, -15.0, -14.0, 2.0, 12.0, 20.0, "steel.panel", "launcher")
    b.box(-19.0, -15.0, 2.0, 3.0, 12.0, 20.0, "steel.missile", "launcher_face")
    b.pin("hp_2", (-17.0, -6.0, 16.0), forward=(-1.0, 0.0, 0.0))
    # The skirt plate on the right flank over the wheel line (hp_3).
    b.box(15.0, 17.5, -20.0, 10.0, 8.0, 19.0, "steel.plate", "skirt")
    b.pin("hp_3", (17.5, -5.0, 14.0), forward=(1.0, 0.0, 0.0))
    # Lamps on the nose.
    for s in (-1.0, 1.0):
        b.box(s * 9.0 - 2.0, s * 9.0 + 2.0, 29.0, 30.5, 11.0, 13.5, "amber.light", "lamp")


prairie_dog.maker = "wainwright_sutler"


def dingo(b):
    """Wainwright & Sutler "Dingo" (Pattern 12 Support Car): a small, nimble, lightly
    armoured car that hangs back until its allies are placed, then springs. The Prairie
    Dog's bones, closed in: a low enclosed body with a slit visor, and on the roof the
    Megataser Harpoon (fixed, no pin), a barbed dart on a launch rail fed by a capacitor
    drum the size of the car across the back. Pins: hp_1 the hood guns (Twin Autoguns),
    hp_2 the rear tube (Pocket Mortar), hp_3 the left flank tank (Coolant Dump)."""
    _buggy(b, 20.0, 30.0, -28.0, 18.0, "steel.plate")
    # The closed body: a low cabin lofted over the tub, a raked front with a visor slit.
    b.loft([(-20.0, rect(0.0, 26.0, 18.0, 30.0)), (2.0, rect(0.0, 26.0, 18.0, 30.0)), (14.0, rect(0.0, 22.0, 18.0, 22.0))], "steel.panel", "cabin")
    b.box(-8.0, 8.0, 13.0, 14.0, 20.5, 23.5, "glass.glass", "visor")
    for s in (-1.0, 1.0):
        b.box(min(s * 13.0, s * 14.0), max(s * 13.0, s * 14.0), -16.0, -2.0, 22.0, 27.0, "steel.vent", "side_vent")
    # The harpoon: a rail along the roof to a launch head over the nose, the barbed dart
    # lying in it, and behind it the capacitor drum across the back, banded with a lit ring.
    b.box(-2.0, 2.0, -12.0, 22.0, 30.0, 33.0, "steel.dark", "rail")
    b.box(-4.0, 4.0, 16.0, 24.0, 29.0, 36.0, "steel.plate", "launch_head")
    _beam(b, (0.0, -6.0, 34.5), (0.0, 34.0, 34.5), _poly(1.3, 6), _poly(0.5, 6), "steel.dark", "dart")
    for s in (-1.0, 1.0):
        _beam(b, (0.0, 30.0, 34.5), (s * 3.0, 25.0, 34.5 + s * 0.0), _poly(0.9, 4), _poly(0.3, 4), "steel.dark", "barb")
    b.prism("x", 0.0, -20.0, 34.0, 7.0, 26.0, "steel.dark", 8, "capacitor", phase=math.pi / 8)
    b.prism("x", 0.0, -20.0, 34.0, 7.6, 3.0, "amber.strip", 8, "capacitor_ring", phase=math.pi / 8)
    for s in (-1.0, 1.0):
        b.prism("x", s * 14.5, -20.0, 34.0, 4.0, 3.0, "steel.plate", 8, "capacitor_cap")
    b.box(-1.5, 1.5, -13.5, -12.0, 32.0, 35.0, "amber.strip", "cable")
    # The hood guns (hp_1), as the Prairie Dog carries them.
    b.box(-6.0, 6.0, 14.0, 22.0, 13.0, 17.0, "steel.plate", "gun_fairing")
    for s in (-1.0, 1.0):
        b.prism("y", s * 3.0, 30.0, 15.5, 1.4, 20.0, "steel.dark", 6, "autogun")
    b.pin("hp_1", (0.0, 18.0, 15.5))
    # The pocket mortar on the rear deck behind the drum, pitched up over the tail (hp_2).
    b.prism("z", 9.0, -30.0, 19.0, 3.0, 2.0, "steel.dark", 8, "mortar_base")
    _beam(b, (9.0, -30.0, 20.0), (9.0, -25.0, 31.0), _poly(2.6, 6), _poly(2.9, 6), "steel.panel", "mortar")
    b.pin("hp_2", (9.0, -28.0, 25.0))
    # The coolant tank on the left flank, a drum with a vent grille and a dump valve (hp_3).
    b.prism("y", -17.5, -8.0, 14.0, 3.6, 22.0, "steel.plate", 8, "coolant_tank")
    b.box(-19.5, -17.0, -6.0, 4.0, 13.0, 15.0, "steel.vent", "tank_grille")
    b.prism("z", -17.5, 2.0, 9.5, 1.2, 3.0, "steel.dark", 6, "dump_valve")
    b.pin("hp_3", (-19.5, -8.0, 14.0), forward=(-1.0, 0.0, 0.0))
    # Whip antennae off the tail corners, lamps low on the nose.
    for s in (-1.0, 1.0):
        b.prism("z", s * 11.0, -27.0, 30.0, 0.5, 20.0, "steel.dark", 4, "antenna")
        b.box(s * 8.0 - 2.0, s * 8.0 + 2.0, 29.0, 30.5, 10.0, 12.5, "amber.light", "lamp")


dingo.maker = "wainwright_sutler"


def goshawk(b):
    """Kestrel "Goshawk" (K-9 Mk II Attack Airframe): the Sparrowhawk's larger cousin,
    endurance over burst. Wide downturned wings like a hovering predator, weapon mounts
    under them, two boosters on top of the tail section in the A-10's way, twin fins. The
    Afterburner Cannon (fixed, no pin) is the big central nose gun the engines fire through.
    Chrome body, cobalt wings and fins. Pins under the wings: hp_1 left inner (Laser
    Carbine), hp_2 right inner (Headhunter Rifle), hp_3 left outer (Arc Projector), hp_4
    right outer (Deflector); hp_5 the dorsal intake (Ram-air Scoop). Centred on z = 0 like
    the Sparrowhawk; the engine lifts flyers."""
    # Fuselage: broader and deeper than the Sparrowhawk's, a blunt nose for the cannon.
    b.loft([(56.0, _fuse(5.0, 2.0, 1.8)), (44.0, _fuse(11.0, 4.2, 3.6)), (24.0, _fuse(16.0, 5.6, 4.8)),
            (0.0, _fuse(20.0, 7.0, 5.6)), (-22.0, _fuse(20.0, 7.0, 5.4)), (-40.0, _fuse(14.0, 5.0, 4.0)), (-52.0, _fuse(8.0, 3.0, 2.6))], "steel.plate", "fuselage")
    # The Afterburner Cannon: a heavy barrel out of the nose under the centreline, a lit
    # muzzle, a feed fairing back along the belly.
    b.prism("y", 0.0, 62.0, -2.0, 2.8, 30.0, "steel.dark", 6, "cannon")
    b.prism("y", 0.0, 77.5, -2.0, 3.4, 2.0, "amber.engine", 6, "cannon_muzzle")
    b.loft([(20.0, rect(0.0, 8.0, -7.0, -4.0)), (48.0, rect(0.0, 6.0, -6.0, -3.5))], "steel.dark", "feed_fairing")
    # Canopy: faired, low and long, further forward than the Sparrowhawk's.
    b.loft([(24.0, hexagon(0.0, 6.0, 8.0, 0.6)), (14.0, hexagon(0.0, 7.6, 10.0, 3.4)), (0.0, hexagon(0.0, 7.8, 10.0, 3.6)), (-10.0, hexagon(0.0, 7.4, 9.6, 3.0))], "glass.glass", "canopy")
    # The dorsal intake behind it: the Ram-air Scoop's mouth, forward-facing (hp_5).
    b.loft([(-10.0, hexagon(0.0, 7.6, 10.4, 3.8)), (-14.0, hexagon(0.0, 8.8, 11.0, 6.0)), (-24.0, hexagon(0.0, 7.6, 10.4, 3.6))], "steel.panel", "intake")
    b.loft([(-14.2, hexagon(0.0, 8.8, 9.6, 5.0)), (-13.4, hexagon(0.0, 8.8, 9.6, 5.0))], "bore.dark", "intake_mouth")
    b.pin("hp_5", (0.0, -18.0, 9.0), forward=(0.0, 0.0, 1.0))
    # Wings: two panels a side. The inner panel runs out level from the shoulder, the outer
    # turns down (the hovering hawk's drooped tips), knife-edged at the front, the trailing
    # edge swept. A pod and gun under each panel.
    for s in (-1.0, 1.0):
        root = [(s * 9.0, -6.0, 1.0), (s * 9.0, -6.0, 3.0), (s * 9.0, 22.0, 2.0)]
        knuckle = [(s * 28.0, -2.0, 2.0), (s * 28.0, -2.0, 3.4), (s * 28.0, 16.0, 2.7)]
        tip = [(s * 52.0, 0.0, -9.0), (s * 52.0, 0.0, -8.2), (s * 52.0, 9.0, -8.6)]
        _wing(b, root, knuckle, "livery.livery", "wing_inner")
        _wing(b, knuckle, tip, "livery.livery", "wing_outer")
        # inner pod: the carbine (left) and the rifle (right)
        b.prism("y", s * 19.0, 4.0, -1.5, 2.4, 20.0, "steel.dark", 6, "inner_pod")
        b.prism("y", s * 19.0, 17.0, -1.5, 1.3, 8.0, "steel.dark", 6, "inner_gun")
        b.box(s * 19.0 - 1.2, s * 19.0 + 1.2, 0.0, 8.0, -0.5, 2.6, "steel.plate", "inner_pylon")
        b.pin("hp_%d" % (1 if s < 0 else 2), (s * 19.0, 8.0, -1.5))
        # outer pod, hanging under the drooped panel
        oz = 2.7 - (2.7 + 8.6) * (12.0 / 24.0)
        b.prism("y", s * 40.0, 2.0, oz - 3.0, 2.2, 18.0, "steel.dark", 6, "outer_pod")
        b.prism("y", s * 40.0, 13.0, oz - 3.0, 1.2, 6.0, "steel.dark", 6, "outer_gun")
        b.box(s * 40.0 - 1.2, s * 40.0 + 1.2, -2.0, 6.0, oz - 1.5, oz + 0.5, "steel.plate", "outer_pylon")
        b.pin("hp_%d" % (3 if s < 0 else 4), (s * 40.0, 6.0, oz - 3.0))
    # The tail section: a flat boom carrying the boosters on top and the fins at the end.
    b.loft([(-30.0, rect(0.0, 22.0, -2.0, 5.0)), (-56.0, rect(0.0, 26.0, -1.0, 4.0)), (-64.0, rect(0.0, 26.0, -0.5, 3.0))], "steel.plate", "tail_boom")
    for s in (-1.0, 1.0):
        # Boosters on short pylons above the boom, exhausts lit.
        b.box(s * 9.0 - 2.0, s * 9.0 + 2.0, -50.0, -36.0, 5.0, 8.0, "steel.dark", "pylon")
        b.prism("y", s * 9.0, -44.0, 13.0, 6.0, 26.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", s * 9.0, -57.5, 13.0, 6.4, 1.5, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
        b.loft([(-58.0, hexagon(s * 9.0, 13.0, 10.0, 8.6)), (-58.5, hexagon(s * 9.0, 13.0, 9.0, 7.6))], "amber.engine", "exhaust")
        b.loft([(-31.5, hexagon(s * 9.0, 13.0, 9.6, 8.2)), (-31.0, hexagon(s * 9.0, 13.0, 8.6, 7.2))], "bore.dark", "booster_mouth")
        # Twin fins at the boom's ends, upright, cobalt.
        root = [(s * 12.0, -64.0, 3.0), (s * 12.0, -50.0, 3.0), (s * 12.0, -50.0, 4.0), (s * 12.0, -64.0, 4.0)]
        tip = [(s * 13.0, -66.0, 20.0), (s * 13.0, -58.0, 20.0), (s * 13.0, -58.0, 20.6), (s * 13.0, -66.0, 20.6)]
        _wing(b, root, tip, "livery.livery", "fin")
    # Kestrel's chrome carries a stripe of cobalt down the spine and a lit strip in the belly.
    b.box(-2.0, 2.0, -28.0, 26.0, 7.2, 8.0, "livery.livery", "spine_stripe")
    b.box(-4.0, 4.0, 30.0, 40.0, -6.2, -5.6, "amber.strip", "belly_light")


goshawk.maker = "kestrel"


def _spike(b, base, tip, half, material, label):
    """A four-sided spike: a square of half-width `half` at `base` drawn to a point at `tip`."""
    d = (Vector(tip) - Vector(base)).normalized()
    up = Vector((0.0, 0.0, 1.0))
    side = Vector((1.0, 0.0, 0.0)) if abs(d.dot(up)) > 0.999 else d.cross(up).normalized()
    over = side.cross(d).normalized()
    p = Vector(base)
    ring0 = [p + side * u + over * v for u, v in _sq(half * 2.0, half * 2.0)]
    t = Vector(tip)
    ring1 = [t + side * u * 0.05 + over * v * 0.05 for u, v in _sq(half * 2.0, half * 2.0)]
    return _rings(b, [ring0, ring1], material, label)


def nemesis(b):
    """The Arsenal "Nemesis" (Arsenal Instrument IV): a hulking, neckless, spiked brute with
    thick arms made for pummelling and a fiery core in its torso that lights as it takes
    damage and heats. Dark steel and gunmetal, black chrome. Heavy plantigrade legs, a
    barrel torso hunched forward with the shoulders above where a head would be, a visor
    slit in the chest, the core a lit window under it; spikes off the shoulders and back;
    the Gravity Knuckles are the two fists (fixed, no pins). Pins: hp_1 the right forearm
    gun (Plasma Carbine), hp_2 the back tubes (Meteor Artillery), hp_3 the left shoulder
    slab (Ward Plate), hp_4 the lower back block (Entropy Condenser)."""
    OCT = lambda r: _poly(r, 8, math.pi / 8)
    # Legs: thick, short, plantigrade; the feet wide and flat, toe caps.
    for s in (-1.0, 1.0):
        cx = s * 14.0
        b.loft([(-14.0, rect(cx, 17.0, 0.0, 7.0)), (2.0, rect(cx, 19.0, 0.0, 9.0)), (18.0, rect(cx, 17.0, 0.0, 4.5))], "steel.plate", "foot")
        b.box(cx - 9.0, cx + 9.0, 15.0, 19.0, 0.0, 3.0, "steel.dark", "toe_cap")
        ankle = (cx, -2.0, 8.0)
        knee = (cx, 7.0, 21.0)
        hip = (cx * 0.9, -4.0, 30.0)
        b.prism("x", ankle[0], ankle[1], ankle[2], 5.0, 14.0, "steel.dark", 6, "ankle")
        _beam(b, ankle, knee, OCT(6.4), OCT(5.8), "steel.panel", "shin")
        b.prism("x", knee[0], knee[1], knee[2], 6.2, 13.0, "steel.dark", 6, "knee")
        _beam(b, knee, hip, OCT(6.8), OCT(7.2), "steel.plate", "thigh")
        b.box(cx - 6.0, cx + 6.0, 10.0, 13.0, 10.0, 19.0, "livery.livery2", "shin_plate")
    b.prism("x", 0.0, -3.0, 32.0, 8.0, 34.0, "steel.panel", 8, "pelvis", phase=math.pi / 8)
    # The torso: wide chamfered decks, widest at the shoulders, leaning forward so the
    # shoulders overhang the chest; no head, the visor slit between the shoulders.
    _rings(b, [_deck(34.0, 24.0, -2.0, 36.0, 5.0), _deck(46.0, 30.0, 0.0, 48.0, 6.0),
               _deck(52.0, 32.0, 2.0, 60.0, 7.0), _deck(44.0, 28.0, 4.0, 68.0, 6.0)], "steel.panel", "torso")
    b.box(-8.0, 8.0, 17.0, 19.0, 62.0, 65.0, "glass.glass", "visor")
    b.box(-16.0, 16.0, 16.0, 18.0, 58.0, 68.5, "steel.plate", "brow_plate")
    # The core: a recessed lit window in the chest, ribs across it.
    b.box(-9.0, 9.0, 14.0, 17.5, 44.0, 56.0, "steel.dark", "core_housing")
    b.box(-7.0, 7.0, 17.0, 18.2, 46.0, 54.0, "amber.engine", "core")
    for z in (48.5, 51.5):
        b.box(-7.5, 7.5, 18.0, 18.8, z - 0.5, z + 0.5, "steel.dark", "core_rib")
    # Spikes: a row off each shoulder's crown and two up the back.
    for s in (-1.0, 1.0):
        for k in range(3):
            base = (s * (18.0 + k * 6.0), -2.0 + k * 1.0, 66.0 - k * 2.0)
            _spike(b, base, (base[0] + s * 4.0, base[1] - 2.0, base[2] + 10.0 - k * 1.5), 2.4, "steel.dark", "spike")
    for y, z in ((-14.0, 62.0), (-12.0, 52.0)):
        _spike(b, (0.0, y, z), (0.0, y - 9.0, z + 7.0), 2.2, "steel.dark", "back_spike")
    # Arms: massive. A pauldron drum, a thick upper arm out and down, an elbow, a heavier
    # forearm down to a fist by the knee, knuckles forward. The Gravity Knuckles.
    for s in (-1.0, 1.0):
        px = s * 30.0
        b.prism("x", px, 0.0, 62.0, 10.0, 14.0, "steel.plate", 8, "pauldron", phase=math.pi / 8)
        shoulder = (s * 36.0, 0.0, 58.0)
        elbow = (s * 43.0, 4.0, 40.0)
        wrist = (s * 41.0, 14.0, 18.0)
        b.prism("x", shoulder[0], shoulder[1], shoulder[2], 5.5, 9.0, "steel.dark", 6, "shoulder_joint")
        _beam(b, shoulder, elbow, OCT(6.6), OCT(6.0), "steel.panel", "upper_arm")
        b.prism("x", elbow[0], elbow[1], elbow[2], 6.8, 14.0, "steel.dark", 6, "elbow")
        _beam(b, elbow, wrist, OCT(6.2), OCT(7.4), "steel.plate", "forearm")
        _fist(b, wrist[0], 5.0, 22.0, 6.0, 22.0, 17.0, -s)
        if s > 0:
            # The Plasma Carbine along the outside of the right forearm (hp_1).
            gx = wrist[0] + 11.0
            b.box(gx - 2.5, gx + 2.5, 6.0, 20.0, 18.0, 26.0, "steel.plate", "carbine_mount")
            b.prism("y", gx, 24.0, 22.0, 2.2, 22.0, "steel.dark", 6, "plasma_carbine")
            b.prism("y", gx, 35.5, 22.0, 1.6, 1.5, "amber.engine", 6, "carbine_tip")
            b.pin("hp_1", (gx, 20.0, 22.0))
        else:
            # The Ward Plate: a big inscribed slab over the left shoulder (hp_3).
            b.box(px - 14.0, px + 6.0, -10.0, 8.0, 71.0, 74.0, "livery.livery2", "ward_plate")
            b.box(px - 12.0, px + 4.0, -8.0, 6.0, 74.0, 75.0, "steel.plate", "ward_inscription")
            b.pin("hp_3", (px - 4.0, -1.0, 74.0), forward=(0.0, 0.0, 1.0))
    # The Meteor Artillery: two mortar tubes on the upper back, pitched up over the
    # shoulders (hp_2), on a rack.
    b.box(-14.0, 14.0, -20.0, -10.0, 50.0, 62.0, "steel.panel", "rack")
    for s in (-1.0, 1.0):
        _beam(b, (s * 8.0, -16.0, 60.0), (s * 8.0, -8.0, 80.0), _poly(3.8, 6), _poly(4.2, 6), "steel.dark", "meteor_tube")
        _beam(b, (s * 8.0, -8.0, 80.0), (s * 8.0, -7.5, 81.5), _poly(4.2, 6), _poly(3.0, 6), "amber.engine", "tube_mouth")
    b.pin("hp_2", (0.0, -14.0, 66.0), forward=(0.0, 0.0, 1.0))
    # The Entropy Condenser: a dark block on the lower back with lit slots (hp_4).
    b.box(-11.0, 11.0, -18.0, -12.0, 36.0, 48.0, "steel.dark", "condenser")
    for z in (39.0, 43.0):
        b.box(-8.0, 8.0, -18.8, -18.0, z, z + 1.5, "amber.strip", "condenser_slot")
    b.pin("hp_4", (0.0, -18.0, 42.0), forward=(0.0, -1.0, 0.0))


nemesis.maker = "arsenal"


def ammit(b):
    """The Arsenal "Ammit" (Arsenal Instrument VII): a sinister digitigrade figure with four
    clawed arms, the middle pair reaching down as a second pair of legs, a low snout of a
    cockpit with two burning eyes. Reverse-jointed legs, a torso hunched forward and low, a
    long snout out of the chest; the upper arms raised with their talons hanging, the lower
    pair planted ahead of the feet. The four Soulcutter Talons are the four clawed hands
    (fixed, no pins). Pins: hp_1 the upper right forearm (Plasma Carbine), hp_2 the upper
    left forearm (Blazethrower), hp_3 the back slab (Ward Plate), hp_4 the rear pelvis block
    (Entropy Condenser)."""
    OCT = lambda r: _poly(r, 8, math.pi / 8)
    HEX = lambda r: _poly(r, 6)
    # Legs: digitigrade. Hip high and back, knee forward, ankle back and low, a long foot
    # forward onto two toes and a heel claw. Nothing below the ground.
    for s in (-1.0, 1.0):
        cx = s * 12.0
        hip = (cx, -14.0, 34.0)
        knee = (cx + s * 2.0, 2.0, 26.0)
        ankle = (cx + s * 2.0, -10.0, 12.0)
        toe = (cx + s * 2.0, 6.0, 2.0)
        b.prism("x", hip[0], hip[1], hip[2], 5.0, 9.0, "steel.dark", 6, "hip")
        _beam(b, hip, knee, OCT(5.4), OCT(4.6), "steel.plate", "thigh")
        b.prism("x", knee[0], knee[1], knee[2], 4.8, 10.0, "steel.dark", 6, "knee")
        _beam(b, knee, ankle, OCT(4.2), OCT(3.6), "steel.panel", "shin")
        b.prism("x", ankle[0], ankle[1], ankle[2], 3.8, 9.0, "steel.dark", 6, "ankle")
        _beam(b, ankle, toe, _sq(7.0, 6.0), _sq(8.0, 3.0), "steel.plate", "foot")
        for tx in (-3.0, 3.0):
            _tine(b, (toe[0] + tx, toe[1], toe[2] + 1.0), 0.0, 10.0, -14.0, 9.0, 3.0, 2.4, "steel.dark", "toe")
        _tine(b, (ankle[0], ankle[1] - 2.0, 6.0), 0.0, 200.0, 30.0, 7.0, 3.0, 2.2, "steel.dark", "heel_claw")
    # The pelvis, and the torso leaning forward and low: decks stepping forward as they
    # rise, the chest at about the height of a man's shoulder.
    b.prism("x", 0.0, -12.0, 36.0, 6.5, 26.0, "steel.panel", 8, "pelvis", phase=math.pi / 8)
    _rings(b, [_deck(26.0, 20.0, -8.0, 38.0, 4.0), _deck(32.0, 24.0, 0.0, 44.0, 5.0),
               _deck(34.0, 24.0, 8.0, 50.0, 5.0), _deck(26.0, 18.0, 14.0, 54.0, 4.0)], "steel.panel", "torso")
    # The snout: a long hexagonal muzzle out of the chest's top, narrowing to a dark tip,
    # two burning eyes set high at its root under a brow, a lit slit along its jaw.
    b.loft([(12.0, hexagon(0.0, 50.0, 18.0, 10.0)), (30.0, hexagon(0.0, 49.0, 12.0, 7.0)), (42.0, hexagon(0.0, 48.0, 7.0, 4.0))], "steel.plate", "snout")
    b.loft([(42.0, hexagon(0.0, 48.0, 7.0, 4.0)), (45.0, hexagon(0.0, 48.0, 4.0, 2.0))], "steel.dark", "snout_tip")
    b.box(-9.0, 9.0, 12.0, 24.0, 54.5, 56.5, "steel.plate", "brow")
    for s in (-1.0, 1.0):
        b.box(s * 5.0 - 1.8, s * 5.0 + 1.8, 22.0, 24.5, 51.5, 53.5, "amber.engine", "eye")
    b.box(-1.0, 1.0, 26.0, 40.0, 45.8, 46.6, "amber.strip", "jaw_slit")
    # Four arms. The upper pair off the shoulders, raised out and forward, forearms hanging
    # with talons down. The middle pair off the lower torso, planted on the ground ahead of
    # the feet, talons splayed: the second pair of legs.
    arms = (((-1.0, "upper"), (1.0, "upper")), ((-1.0, "lower"), (1.0, "lower")))
    for pair in arms:
        for s, kind in pair:
            if kind == "upper":
                shoulder = (s * 18.0, 8.0, 52.0)
                elbow = (s * 30.0, 14.0, 44.0)
                wrist = (s * 30.0, 22.0, 26.0)
                b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.6, 8.0, "steel.dark", 6, "shoulder")
                _beam(b, shoulder, elbow, HEX(4.4), HEX(3.8), "steel.plate", "upper_arm")
                b.prism("x", elbow[0], elbow[1], elbow[2], 4.4, 9.0, "steel.dark", 6, "elbow")
                _beam(b, elbow, wrist, HEX(3.8), HEX(3.4), "steel.panel", "forearm")
                b.prism("x", wrist[0], wrist[1], wrist[2], 3.2, 8.0, "steel.dark", 6, "wrist")
                # Talons hanging: three curved blades down and forward.
                for tx in (-3.5, 0.0, 3.5):
                    _tine(b, (wrist[0] + tx, wrist[1], wrist[2] - 2.0), 0.0, -70.0, -50.0, 14.0, 3.2, 2.4, "steel.dark", "talon")
                if s > 0:
                    gx = wrist[0] + 6.0
                    b.box(gx - 2.0, gx + 2.0, wrist[1] - 6.0, wrist[1] + 4.0, 30.0, 40.0, "steel.plate", "carbine_mount")
                    b.prism("y", gx, wrist[1] + 12.0, 36.0, 2.0, 18.0, "steel.dark", 6, "plasma_carbine")
                    b.prism("y", gx, wrist[1] + 21.5, 36.0, 1.5, 1.5, "amber.engine", 6, "carbine_tip")
                    b.pin("hp_1", (gx, wrist[1] + 2.0, 36.0))
                else:
                    gx = wrist[0] - 6.0
                    b.box(gx - 2.0, gx + 2.0, wrist[1] - 6.0, wrist[1] + 4.0, 30.0, 40.0, "steel.plate", "thrower_mount")
                    b.prism("y", gx, wrist[1] - 3.0, 36.0, 3.0, 10.0, "steel.dark", 8, "fuel_tank")
                    b.prism("y", gx, wrist[1] + 10.0, 36.0, 1.6, 14.0, "steel.dark", 6, "nozzle")
                    b.prism("y", gx, wrist[1] + 17.5, 36.0, 2.2, 1.5, "amber.engine", 6, "pilot_flame")
                    b.pin("hp_2", (gx, wrist[1] + 2.0, 36.0))
            else:
                shoulder = (s * 14.0, 2.0, 40.0)
                elbow = (s * 26.0, 14.0, 26.0)
                wrist = (s * 24.0, 26.0, 6.0)
                b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.4, 8.0, "steel.dark", 6, "lower_shoulder")
                _beam(b, shoulder, elbow, HEX(4.6), HEX(4.0), "steel.plate", "lower_upper_arm")
                b.prism("x", elbow[0], elbow[1], elbow[2], 4.6, 9.0, "steel.dark", 6, "lower_elbow")
                _beam(b, elbow, wrist, HEX(4.0), HEX(3.6), "steel.panel", "lower_forearm")
                b.prism("x", wrist[0], wrist[1], wrist[2], 3.4, 8.0, "steel.dark", 6, "lower_wrist")
                # Talons planted: three blades splayed forward on the ground.
                for k, tx in enumerate((-4.0, 0.0, 4.0)):
                    _tine(b, (wrist[0] + tx, wrist[1] + 1.0, wrist[2] - 1.0), 0.0, -30.0 - abs(tx) * 2.0, 20.0, 10.0, 3.2, 2.4, "steel.dark", "talon")
    # The Ward Plate: a slab down the spine (hp_3), and the Entropy Condenser at the rear
    # of the pelvis with lit slots (hp_4).
    b.box(-9.0, 9.0, -16.0, -12.0, 36.0, 54.0, "livery.livery2", "ward_plate")
    b.box(-7.0, 7.0, -17.0, -16.0, 40.0, 50.0, "steel.plate", "ward_inscription")
    b.pin("hp_3", (0.0, -17.0, 45.0), forward=(0.0, -1.0, 0.0))
    b.box(-8.0, 8.0, -28.0, -20.0, 30.0, 40.0, "steel.dark", "condenser")
    for z in (33.0, 36.5):
        b.box(-6.0, 6.0, -28.8, -28.0, z, z + 1.2, "amber.strip", "condenser_slot")
    b.pin("hp_4", (0.0, -28.0, 35.0), forward=(0.0, -1.0, 0.0))
    # Spines down the back over the plate.
    for k in range(3):
        _spike(b, (0.0, -14.0 - k * 3.0, 54.0 - k * 6.0), (0.0, -22.0 - k * 3.0, 58.0 - k * 6.0), 1.8, "steel.dark", "spine")


ammit.maker = "arsenal"


def _deck(w, d, cy, z, c):
    """A chamfered rectangle lying flat at height `z`, centred on x = 0 and y = `cy`: eight
    points, a torso's section for `_rings`."""
    hw, hd = w / 2.0, d / 2.0
    return [(-hw + c, cy - hd, z), (hw - c, cy - hd, z), (hw, cy - hd + c, z), (hw, cy + hd - c, z),
            (hw - c, cy + hd, z), (-hw + c, cy + hd, z), (-hw, cy + hd - c, z), (-hw, cy - hd + c, z)]


def _case(w, z0, z1, c):
    """An ironclad's casemate section: a rectangle with its top corners chamfered by `c`."""
    return [(-w / 2, z0), (w / 2, z0), (w / 2, z1 - c), (w / 2 - c, z1), (-w / 2 + c, z1), (-w / 2, z1 - c)]


def _sq(w, h):
    """A rectangular profile for `_beam`, centred: (across, up) pairs."""
    return [(-w / 2, -h / 2), (w / 2, -h / 2), (w / 2, h / 2), (-w / 2, h / 2)]


def _poly(r, n, phase=0.0):
    """A regular polygon profile for `_beam`."""
    return [(r * math.cos(phase + i * 2.0 * math.pi / n), r * math.sin(phase + i * 2.0 * math.pi / n)) for i in range(n)]


def _beam(b, p0, p1, ring0, ring1, material, label):
    """A straight member from `p0` to `p1` in world space: a profile (across, up) at each
    end lofted along the line between them, `across` horizontal. Legs, rails, tubes."""
    d = (Vector(p1) - Vector(p0)).normalized()
    up = Vector((0.0, 0.0, 1.0))
    side = Vector((1.0, 0.0, 0.0)) if abs(d.dot(up)) > 0.999 else d.cross(up).normalized()
    up = side.cross(d).normalized()
    rings = [[Vector(p) + side * u + up * v for u, v in ring] for p, ring in ((p0, ring0), (p1, ring1))]
    # Tiles run along the member, seams around it, so a slanted limb's plates read as plates.
    return _rings(b, rings, material, label, (Vector(p0), d, side, up, None))


def _quad(b, pts, material, label, frame=None):
    """One face on its own, from four points in world space, so a block can wear a
    different tile on each side."""
    bm = bmesh.new()
    vs = [bm.verts.new(Vector(p)) for p in pts]
    bm.faces.new(vs)
    return b._finish(bm, material, label, None, frame)


def _fist(b, cx, y_back, y_front, z0, z1, w, inner_side, label="fist"):
    """A closed fist hanging from the wrist, knuckles forward (+y): a block whose faces each
    carry one tile of their own (Ryan, 28 September). Only the front wears the fingers
    (four columns, the knuckles lit, the thumb curled across the bottom); the inner side
    (toward the body, `inner_side` is -1 for the right hand) wears the bent thumb coming
    down and turning forward; the outer side is the plain back of the hand, and the top,
    bottom and back are plate."""
    hw = w / 2.0
    x0, x1 = cx - hw, cx + hw
    up, right, fwd = Vector((0.0, 0.0, 1.0)), Vector((1.0, 0.0, 0.0)), Vector((0.0, 1.0, 0.0))
    h, d = z1 - z0, y_front - y_back
    _quad(b, [(x0, y_front, z0), (x1, y_front, z0), (x1, y_front, z1), (x0, y_front, z1)], "steel.fist", label + "_front",
          (Vector((x0, y_front, z0)), up, right, fwd, (w, h)))
    inner_x = x0 if inner_side < 0 else x1
    outer_x = x1 if inner_side < 0 else x0
    _quad(b, [(inner_x, y_back, z0), (inner_x, y_front, z0), (inner_x, y_front, z1), (inner_x, y_back, z1)], "steel.thumb", label + "_inner",
          (Vector((inner_x, y_back, z0)), up, fwd, right, (d, h)))
    _quad(b, [(outer_x, y_back, z0), (outer_x, y_front, z0), (outer_x, y_front, z1), (outer_x, y_back, z1)], "steel.plate", label + "_outer")
    _quad(b, [(x0, y_back, z1), (x1, y_back, z1), (x1, y_front, z1), (x0, y_front, z1)], "steel.plate", label + "_top")
    _quad(b, [(x0, y_back, z0), (x1, y_back, z0), (x1, y_front, z0), (x0, y_front, z0)], "steel.plate", label + "_bottom")
    _quad(b, [(x0, y_back, z0), (x1, y_back, z0), (x1, y_back, z1), (x0, y_back, z1)], "steel.plate", label + "_back")


def _fuse(w, top, bottom):
    """A fuselage section: six points, `top` above the centreline and `bottom` below it,
    so the top and belly can taper at different rates."""
    return [(w / 2, 0.0), (w / 4, top), (-w / 4, top), (-w / 2, 0.0), (-w / 4, -bottom), (w / 4, -bottom)]


def _wing(b, root, tip, material, label):
    """A wing as a loft between two sections given in full 3D."""
    return _rings(b, [root, tip], material, label)


def _rings(b, rings, material, label, frame=None):
    """A loft through any number of sections given as 3D point rings, capped at both ends.
    `frame` maps the tiles in the part's own axes (see Build._finish)."""
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
    return b._finish(bm, material, label, None, frame)


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


def _battered(b, x0, x1, d_base, d_top, z0, z1, material, label):
    """A sloped slab: wider at the foot than the top, the curtain-wall section of every
    reference (Ryan, 21 September)."""
    bottom = [(x0, -d_base, z0), (x1, -d_base, z0), (x1, d_base, z0), (x0, d_base, z0)]
    top = [(x0, -d_top, z1), (x1, -d_top, z1), (x1, d_top, z1), (x0, d_top, z1)]
    return _rings(b, [bottom, top], material, label)


def _bastion(b, cx, cy, half_base, half_top, z0, z1, material, label):
    """A squat tapered square tower."""
    bottom = [(cx - half_base, cy - half_base, z0), (cx + half_base, cy - half_base, z0), (cx + half_base, cy + half_base, z0), (cx - half_base, cy + half_base, z0)]
    top = [(cx - half_top, cy - half_top, z1), (cx + half_top, cy - half_top, z1), (cx + half_top, cy + half_top, z1), (cx - half_top, cy + half_top, z1)]
    return _rings(b, [bottom, top], material, label)


def _pilasters(b, x0, x1, d_base, d_top, z0, z1, step, w=6.0):
    """Vertical ribs standing proud of a battered face, both faces, following its slope."""
    x = x0
    while x <= x1 + 0.01:
        for f in (-1.0, 1.0):
            bottom = [(x - w / 2, f * d_base, z0), (x + w / 2, f * d_base, z0), (x + w / 2, f * (d_base + 4.0), z0), (x - w / 2, f * (d_base + 4.0), z0)]
            top = [(x - w / 2, f * d_top, z1), (x + w / 2, f * d_top, z1), (x + w / 2, f * (d_top + 2.5), z1), (x - w / 2, f * (d_top + 2.5), z1)]
            _rings(b, [bottom, top], "steel.dark", "pilaster")
        x += step


def _seams(b, x0, x1, d_base, d_top, z0, z1, heights):
    """Horizontal seam bands across a battered face, both faces."""
    for z in heights:
        t = (z - z0) / (z1 - z0)
        d = d_base + (d_top - d_base) * t
        for f in (-1.0, 1.0):
            b.box(x0, x1, f * d, f * (d + 0.6), z - 0.8, z + 0.8, "steel.dark", "seam")


def _turret(b, x, y, z):
    """A low drum on a pad with a twin gun, barrels to local -y (north on the field)."""
    b.prism("z", x, y, z + 1.5, 19.0, 3.0, "steel.dark", 8, "pad")
    b.prism("z", x, y, z + 7.0, 15.0, 8.0, "steel.panel", 8, "drum")
    b.prism("z", x, y, z + 11.5, 15.5, 1.5, "amber.strip", 8, "drum_light")
    b.box(x - 8.0, x + 8.0, y - 7.0, y + 7.0, z + 11.0, z + 19.0, "steel.panel", "mount")
    for s in (-1.0, 1.0):
        b.prism("y", x + s * 3.5, y - 22.0, z + 15.0, 2.6, 36.0, "steel.dark", 6, "barrel")
    b.box(x - 4.0, x + 4.0, y + 7.0, y + 10.0, z + 12.0, z + 18.0, "amber.light", "sight")


def wall(b):
    """One segment of the curtain wall, a hex wide: a battered slab with a lip, two
    pilasters, seam bands, a vent hatch and lamps. No crenellations, no blades."""
    b.tile_world = 40.0
    W, DB, DT, H = 31.0, 15.0, 10.0, 70.0
    b.box(-W, W, -DB - 5.0, DB + 5.0, 0.0, 5.0, "steel.dark", "footing")
    _battered(b, -W, W, DB, DT, 5.0, H, "steel.panel", "wall")
    b.box(-W, W, -DT - 2.0, DT + 2.0, H, H + 4.0, "steel.dark", "lip")
    _pilasters(b, -W + 10.0, W - 10.0, DB, DT, 5.0, H, 42.0)
    _seams(b, -W, W, DB, DT, 5.0, H, (26.0, 48.0))
    for f in (-1.0, 1.0):
        b.box(-W, W, f * (DB + (DT - DB) * 0.3), f * (DB + (DT - DB) * 0.3 + 1.2), 21.0, 24.5, "amber.strip", "light_strip")
        b.box(-6.0, 6.0, f * (DT + 0.5), f * (DT + 1.6), H - 14.0, H - 6.0, "steel.vent", "vent")
        for lx in (-20.0, 0.0, 20.0):
            b.box(lx - 1.5, lx + 1.5, f * (DT + 0.4), f * (DT + 1.8), H - 3.5, H - 1.0, "amber.light", "lamp")


wall.maker = "arsenal"


def gate(b):
    """The gate: the field's projector. A battered curtain across three hexes, two squat
    tapered bastions with turret drums, and between them a taller gatehouse block with a
    wide panelled door that parts on a lit seam, under a heavy lintel and lip. Panelled
    skins, seams and pilasters, lamps and vents: thick, machine-made, impenetrable."""
    b.tile_world = 40.0
    W, DB, DT, H = 92.0, 15.0, 10.0, 70.0
    b.box(-W, W, -DB - 6.0, DB + 6.0, 0.0, 5.0, "steel.dark", "footing")
    _battered(b, -W, W, DB, DT, 5.0, H, "steel.panel", "wall")
    b.box(-W, W, -DT - 2.0, DT + 2.0, H, H + 4.0, "steel.dark", "lip")
    _seams(b, -W, W, DB, DT, 5.0, H, (26.0, 48.0))
    # The gatehouse: a taller battered block, its door wide and tall.
    GW, GB, GT, GH = 54.0, 21.0, 15.0, 104.0
    _battered(b, -GW, GW, GB, GT, 5.0, GH, "steel.plate", "gatehouse")   # a shade lighter than the bastions, so the blocks read
    b.box(-GW - 2.0, GW + 2.0, -GT - 3.0, GT + 3.0, GH, GH + 5.0, "steel.dark", "gate_lip")
    _pilasters(b, -GW + 8.0, GW - 8.0, GB, GT, 5.0, GH, 23.0, w=7.0)
    _seams(b, -GW, GW, GB, GT, 5.0, GH, (34.0, 62.0, 88.0))
    MW, MH = 38.0, 74.0
    b.box(-MW, MW, -GB - 1.5, GB + 1.5, 5.0, MH, "bore.dark", "mouth")
    # The door stands proud of the battered face on a frame, so it reads as a door and
    # not a recess: two big panels parting on a lit seam, grooves across them, a lit
    # threshold below.
    for f in (-1.0, 1.0):
        d = GB + 2.5
        b.box(-MW - 5.0, MW + 5.0, f * (d - 1.0), f * (d + 0.5), 5.0, MH + 3.0, "steel.dark", "door_frame")
        for s in (-1.0, 1.0):
            b.box(min(s * MW, 0.0) + 1.0, max(s * MW, 0.0) - 1.0, f * (d + 0.5), f * (d + 2.5), 7.0, MH - 2.0, "steel.plate", "door_panel")
            for gz in (22.0, 40.0, 58.0):
                b.box(min(s * MW, 0.0) + 4.0, max(s * MW, 0.0) - 4.0, f * (d + 2.5), f * (d + 3.2), gz - 1.0, gz + 1.0, "steel.dark", "door_groove")
            b.box(min(s * MW, 0.0) + 4.0, max(s * MW, 0.0) - 4.0, f * (d + 2.5), f * (d + 3.1), MH - 12.0, MH - 8.0, "amber.strip", "door_light")
        b.box(-1.2, 1.2, f * (d + 2.5), f * (d + 3.4), 7.0, MH - 2.0, "amber.strip", "door_seam")
        b.box(-MW - 3.0, MW + 3.0, f * (d + 0.5), f * (d + 3.0), 5.0, 7.5, "amber.strip", "threshold")
        b.box(-MW - 4.0, MW + 4.0, f * (GB + (GT - GB) * ((MH - 5.0) / (GH - 5.0)) + 0.5), f * (GB + (GT - GB) * ((MH - 5.0) / (GH - 5.0)) + 3.0), MH, MH + 7.0, "steel.dark", "lintel")
        b.box(-24.0, 24.0, f * (GT + 0.5), f * (GT + 1.6), GH - 22.0, GH - 12.0, "livery.livery", "device")
        for lx in range(-48, 49, 12):
            b.box(lx - 1.5, lx + 1.5, f * (GT + 0.4), f * (GT + 1.8), GH - 3.5, GH - 1.0, "amber.light", "lamp")
        for lx in (-44.0, 44.0):
            b.box(lx - 5.0, lx + 5.0, f * (GB + (GT - GB) * 0.2 + 0.5), f * (GB + (GT - GB) * 0.2 + 1.6), 20.0, 30.0, "steel.vent", "vent")
    # The bastions: squat tapered towers at the ends, a turret drum on each pad.
    BH = 112.0
    for s in (-1.0, 1.0):
        x = s * 76.0
        _bastion(b, x, 0.0, 28.0, 21.0, 0.0, BH, "steel.panel", "bastion")
        b.box(x - 23.0, x + 23.0, -23.0, 23.0, BH, BH + 3.0, "steel.dark", "bastion_lip")
        for f in (-1.0, 1.0):
            for bz in (36.0, 72.0):
                t = bz / BH
                d = 28.0 + (21.0 - 28.0) * t
                b.box(x - d, x + d, f * d, f * (d + 0.6), bz - 0.8, bz + 0.8, "steel.dark", "bastion_seam")
            b.box(x - 5.0, x + 5.0, f * 22.5, f * 23.6, BH - 14.0, BH - 6.0, "steel.vent", "bastion_vent")
            b.box(x - 14.0, x + 14.0, f * 25.0, f * 26.0, 56.0, 59.0, "amber.strip", "bastion_light")
        _turret(b, x, 0.0, BH + 3.0)
        b.pin("hp_%d" % (1 if s < 0 else 2), (x, 0.0, BH + 18.0))
    # A couple of masts on the gatehouse: the projector's antennae.
    for mx in (-30.0, 30.0):
        b.prism("z", mx, 0.0, GH + 14.0, 1.2, 28.0, "steel.dark", 4, "mast")
        b.box(mx - 1.5, mx + 1.5, -1.5, 1.5, GH + 27.0, GH + 30.0, "amber.light", "mast_light")


gate.maker = "arsenal"

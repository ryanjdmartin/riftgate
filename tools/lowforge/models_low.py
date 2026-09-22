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
    return _rings(b, rings, material, label)


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

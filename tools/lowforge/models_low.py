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
        # Wider cuffs, hinges and pauldrons (Ryan, 30 September), so the arms stand clear
        # of the body.
        b.box(min(px - s * 6.0, px + s * 8.0), max(px - s * 6.0, px + s * 8.0), -14.0, 2.0, 30.0, 50.0, "steel.panel", "cuff")
        hinge_x = px + s * 13.0   # between the first pass's 10 and the fourth round's 16 (Ryan, 1 October: a bit too wide)
        b.prism("x", hinge_x, -6.0, 40.0, 11.0, 18.0, "steel.dark", 6, "hinge")
        # The pauldron: a plate over the whole shoulder, wider at its foot, and the gun
        # mounted on it.
        cx = px + s * 6.5
        _rings(b, [[(cx - s * 14.0, -16.0, 50.0), (cx + s * 14.0, -16.0, 50.0), (cx + s * 14.0, 4.0, 50.0), (cx - s * 14.0, 4.0, 50.0)],
                   [(cx - s * 11.5, -14.0, 54.0), (cx + s * 11.5, -14.0, 54.0), (cx + s * 11.5, 2.0, 54.0), (cx - s * 11.5, 2.0, 54.0)]], "steel.plate", "pauldron")
        # A gimbal on each pauldron, the same both sides (Ryan, 1 October): a ring and a
        # drum under a turret joint that traverses. The left carries the Twin Autoguns
        # (hp_3); the right's mount is bare (hp_4: the stock's fourth entry is the
        # Proximity Klaxon, which shows nowhere).
        b.prism("z", cx, -6.0, 54.5, 5.2, 1.0, "steel.dark", 8, "gimbal_ring")
        with b.joint("turret_%s" % ("l" if s < 0 else "r"), (cx, -6.0, 55.0)):
            b.prism("z", cx, -6.0, 57.0, 4.4, 4.0, "steel.plate", 8, "gimbal", phase=math.pi / 8)
            if s < 0:
                with b.socket("hp_3", (cx, -6.0, 59.0)):   # on the gimbal's centre (Ryan, 1 October)
                    b.box(cx - 3.0, cx + 3.0, -10.0, -2.0, 58.0, 61.0, "steel.panel", "receiver")
                    for s2 in (-1.0, 1.0):
                        b.prism("y", cx + s2 * 2.4, 11.0, 59.5, 1.8, 26.0, "steel.dark", 6, "autogun")
            else:
                b.pad("hp_4", (cx, -6.0, 60.0), size=(6.0, 1.0))
        start = (hinge_x, -6.0, 40.0)
        # The whole boom hangs under a shoulder joint at the hinge: it swings on a melee
        # blow and idles under power (the joints, decided earlier and on the to-do; built
        # by code 1 October).
        jt = b.joint("shoulder_%s" % ("l" if s < 0 else "r"), start)
        jt.__enter__()
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
            b.box(wrist[0] - 3.0, wrist[0] + 3.0, wrist[1] + 10.0, wrist[1] + 16.0, wrist[2] + 6.0, wrist[2] + 9.0, "amber.light", "mount_light")
            with b.socket("hp_1", (wrist[0], wrist[1] + 12.0, wrist[2])):
                b.prism("y", wrist[0], wrist[1] + 26.0, wrist[2], 3.2, 30.0, "steel.dark", 6, "barrel")
        jt.__exit__(None, None, None)
    # Deck weapon: a missile box on a turret ring, right of centre. Its face is exactly one
    # tile (14 units) square on tile boundaries, so the box projection shows the nine tubes
    # whole rather than a slice of them.
    b.prism("z", 7.0, -13.0, 41.0, 8.0, 2.0, "steel.dark", 8, "ring")
    with b.socket("hp_2", (7.0, -12.0, 49.0)):   # no joint: a missile box there has no business spinning (Ryan, 1 October)
        b.box(0.0, 14.0, -22.0, -4.0, 42.0, 56.0, "steel.panel", "turret")
        b.box(0.0, 14.0, -4.6, -3.6, 42.0, 56.0, "steel.missile", "missile_face")


badger.maker = "minerva"


def sparrowhawk(b):
    """Kestrel "Sparrowhawk": a small hit-and-run interceptor. Sleek, speed over defence;
    reverse-swept wings whose rear faces run back into the boosters, a faired canopy far
    back, twin nose guns, two big boosters, a tail rooted into the fuselage and riding over
    the boosters, ending in two angled stabilisers. Small but deadly. Reskinned 22 September
    to Kestrel's metals: the body in chrome plate, the wings cobalt, the boosters dark (the
    bone body predated the palettes). Mounts (30 September, the loadout's order): hp_1 and
    hp_2 the nose guns (Overclocked Railgun, Headhunter Rifle), hp_3 the left wing pod (Arc
    Projector, two prongs), hp_4 the right wing pod (Deflector, a projector's dish); every
    socket at half scale, the machine being small."""
    # Fuselage: one piece, a six-sided section lofted from a needle nose to a broad rear.
    # The top tapers sharply toward the nose, the belly shallowly, and the belly carries
    # forward under the wing roots (Ryan, 21 September).
    b.loft([(46.0, _fuse(1.2, 0.6, 0.5)), (36.0, _fuse(6.0, 2.2, 2.0)), (18.0, _fuse(12.0, 3.8, 3.4)),
            (0.0, _fuse(16.0, 6.4, 4.6)), (-16.0, _fuse(18.0, 7.0, 4.8)), (-30.0, _fuse(15.0, 5.4, 4.0))], "steel.plate", "fuselage")
    b.loft([(38.0, diamond(0.0, 0.5, 2.0, 1.5)), (46.0, diamond(0.0, 0.5, 1.0, 0.7))], "steel.dark", "nose_tip")
    # Twin nose guns, one either side of the nosecone, the first two mounts (Ryan, 30
    # September: two nose hardpoints, sleeker than one): hp_1 the left, the Overclocked
    # Railgun; hp_2 the right, the Headhunter Rifle.
    for s in (-1.0, 1.0):
        with b.socket("hp_%d" % (1 if s < 0 else 2), (s * 4.5, 24.0, -1.0), scale=0.5):
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
        if s < 0:
            # The Arc Projector's pod on the left tip (hp_3): two prongs off the pod's nose.
            with b.socket("hp_3", (s * 32.0, 14.0, -4.8), scale=0.5):
                b.prism("y", s * 32.0, 10.0, -4.8, 2.2, 22.0, "steel.dark", 6, "wing_pod")
                for s2 in (-1.0, 1.0):
                    b.prism("y", s * 32.0 + s2 * 1.2, 24.0, -4.8, 0.7, 8.0, "steel.dark", 6, "prong")
        else:
            # The Deflector's pod on the right tip (hp_4): a projector, its dish on the
            # pod's nose (a shield projector is gun-shaped enough to take a mount).
            with b.socket("hp_4", (s * 32.0, 14.0, -4.8), scale=0.5):
                b.prism("y", s * 32.0, 10.0, -4.8, 2.2, 22.0, "steel.dark", 6, "wing_pod")
                b.prism("y", s * 32.0, 21.6, -4.8, 3.2, 1.2, "steel.plate", 8, "dish")
                b.prism("y", s * 32.0, 22.5, -4.8, 1.2, 0.8, "amber.engine", 8, "dish_core")
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
    running out past the head, the pocket mortar and the howitzer aft, a rack of shock
    tubes, ablative slabs bolted on the left flank and a flak skirt hung on the right, the
    heat sink and a stack at the tail. Bone-white flared skirts over the hooves, the
    namesake's feathering. First pass from the content's fantasy (22 September); the pins
    brought up to the d9 loadout 29 September (the howitzer and the shock barrage were new)
    and to the mount rule 30 September: six stock guns on hp_1 to hp_6, the plating and the
    heat sink detail, three bare mounts (hp_7 to hp_9) on the bed rails and the neck."""
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
    # Twin autoguns: a turret ring, a mount and two barrels, one turret each side forward
    # (hp_1 left, hp_2 right).
    for s in (-1.0, 1.0):
        tx = s * 12.0   # a touch outboard, so a traverse clears the lance (Ryan, 1 October)
        # Up on a pedestal, so the guns traverse over the lance and its guard (Ryan, 1
        # October: they would not have cleared the rail).
        # Low, the guns barely clearing the bed's rail, and forward a little; a turret here
        # only turns outward, so the lance is never in its way (Ryan, 1 October).
        b.prism("z", tx, 12.0, 50.0, 6.0, 2.0, "steel.dark", 8, "ring")
        with b.joint("turret_%s" % ("l" if s < 0 else "r"), (tx, 12.0, 51.0)):   # each turret traverses, outward only
            b.box(tx - 5.0, tx + 5.0, 7.0, 17.0, 51.0, 61.0, "steel.panel", "turret")
            b.box(tx - 2.0, tx + 2.0, 17.0, 18.0, 58.0, 60.0, "amber.light", "sight")
            with b.socket("hp_%d" % (1 if s < 0 else 2), (tx, 12.0, 58.0)):
                for s2 in (-1.0, 1.0):
                    b.prism("y", tx + s2 * 2.6, 28.0, 58.0, 1.8, 22.0, "steel.dark", 6, "autogun")
    # The lance (hp_3): a breech block aft of centre, saddles along the deck, one long
    # six-sided rail out past the head, a collar, a lit emitter at the point.
    b.box(-5.0, 5.0, -24.0, -6.0, 48.0, 61.0, "steel.panel", "breech")
    b.box(-3.5, 3.5, 6.0, 10.0, 48.0, 54.0, "steel.dark", "saddle")
    with b.joint("lance", (0.0, -15.0, 57.0)):   # the lance pivots at the breech: it kicks on a shot
        with b.socket("hp_3", (0.0, -15.0, 57.0)):
            _beam(b, (0.0, -26.0, 57.0), (0.0, 64.0, 57.0), _poly(3.4, 6), _poly(2.8, 6), "steel.dark", "lance")
            b.prism("y", 0.0, 24.0, 57.0, 4.8, 5.0, "steel.plate", 6, "guard")
            _beam(b, (0.0, 64.0, 57.0), (0.0, 72.0, 57.0), _poly(2.8, 6), _poly(0.8, 6), "amber.light", "emitter")
    # The pocket mortar (hp_4) aft on the deck's left, a stubby tube pitched up and forward
    # on a base.
    # Out toward the bed's edge, away from the lance's breech, and on a gimbal that
    # traverses (Ryan, 1 October).
    # On the deck, turning outward only like the turrets (Ryan, 1 October: the pedestals
    # of the eleventh round came back down).
    b.prism("z", -13.0, -24.0, 49.5, 5.0, 3.0, "steel.dark", 8, "mortar_base")
    with b.joint("turret_mortar", (-13.0, -24.0, 51.0)):
        with b.socket("hp_4", (-13.0, -24.0, 55.0), forward=(0.0, 0.5, 0.866)):   # the same height as the howitzer's mount (Ryan, 1 October)
            _beam(b, (-13.0, -24.0, 51.0), (-13.0, -16.0, 65.0), _poly(4.0, 6), _poly(4.4, 6), "steel.panel", "mortar")
            _beam(b, (-13.0, -16.0, 65.0), (-13.0, -15.0, 66.8), _poly(4.4, 6), _poly(3.2, 6), "steel.dark", "muzzle")
    # The howitzer (hp_5) on the deck's right: a fat short barrel pitched up out of a
    # breech on a ring, the mortar's big brother; a bit further out, and on its gimbal.
    b.prism("z", 12.5, -14.0, 49.5, 6.0, 3.0, "steel.dark", 8, "howitzer_base")
    with b.joint("turret_howitzer", (12.5, -14.0, 51.0)):
        with b.socket("hp_5", (12.5, -14.0, 55.0), forward=(0.0, 0.866, 0.5)):
            b.box(7.5, 17.5, -19.0, -9.0, 51.0, 59.0, "steel.panel", "howitzer_breech")
            _beam(b, (12.5, -12.0, 55.0), (12.5, 6.0, 65.4), _poly(5.0, 6), _poly(4.4, 6), "steel.dark", "howitzer")
            _beam(b, (12.5, 6.0, 65.4), (12.5, 8.6, 66.9), _poly(4.4, 6), _poly(5.2, 6), "steel.plate", "howitzer_muzzle")
    # The shock barrage (hp_6): a rack of tubes on the deck's left between the turret and
    # the breech, pitched up; the class shape, since nothing was modelled there.
    b.stock("hp_6", (-12.0, -10.0, 52.0), "rack", forward=(0.0, 0.707, 0.707), scale=0.8)   # aft a bit (Ryan, 1 October)
    # Ablative plating: two bolted slabs each flank, standing proud of the hull; the heat
    # sink across the tail, its stack up through the bed. Detail, no mounts: armour and
    # vents show nowhere (the rule, 30 September).
    for s in (-1.0, 1.0):
        for y0, y1 in ((-30.0, -9.0), (-6.0, 15.0)):
            b.box(min(s * 18.0, s * 21.5), max(s * 18.0, s * 21.5), y0, y1, 28.0, 44.0, "steel.plate", "ablative")
    b.box(-13.0, 13.0, -40.0, -36.0, 28.0, 44.0, "steel.vent", "heat_sink")
    b.prism("z", 9.0, -28.0, 58.0, 2.8, 20.0, "steel.dark", 6, "stack")
    # Three bare mounts for a fully gunned loadout (nine hardpoints, six stock guns): one
    # on each of the head's cheeks, low on the sides, AT-AT style, on a bracket; and one
    # behind the head on the hull's front, under the lance (Ryan, 1 October).
    for s, k in ((-1.0, 7), (1.0, 8)):
        b.box(min(s * 12.0, s * 14.5), max(s * 12.0, s * 14.5), 42.0, 48.0, 22.0, 28.0, "steel.panel", "cheek_bracket")
        b.pin("hp_%d" % k, (s * 14.5, 48.0, 25.0))
    b.pad("hp_9", (0.0, 26.0, 45.6), size=(8.0, 2.0))   # down onto the hull's crown (Ryan, 1 October)


clydesdale.maker = "wainwright_sutler"


def baboon(b):
    """Aphelion "Baboon" (the Mandrill until 28 September): a long-armed, stubby-legged plantigrade walker, orangutan and
    troll at once, its high-tech suite riding on a backpack (Ryan's brief, 26 September).
    White pearl plate with red markings. Fourth pass on Ryan's notes: stumpier legs and
    longer forearms, to sell the proportions at the game's size; the limbs are straight
    tapered octagonal members with their tiles mapped along the member (the world-axis
    seams cut diagonally across them before); the fists are blocks whose front face
    carries one fist tile, knuckles forward as a BattleTech mech holds them, a thumb block
    proud on the outside. Kept: the barrel torso, the sensor pod with its red eye, the
    shoulder cannons and the backpack. Fifth pass (Ryan, 30 September): the fists rest on
    the ground again and earn it by carrying the guns: two mounts a hand (hp_3 and hp_4 the
    Pulse Repeaters on the outer sides, hp_5 the Zenith Emitter on the right fist's top,
    hp_6 bare on the left), the shoulders hp_1 and hp_2 (Umbra Projectors); the Radiator
    Sail is the vent block on the backpack, no mount; a d7. Every number is a proportion
    Ryan may change."""
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
        b.box(cx - 5.0, cx + 5.0, 12.5, 15.5, 14.5, 23.5, "livery.livery2", "knee_pad")   # on the knee, not hung under it (Ryan, 30 September)
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
        with b.socket("hp_%d" % (1 if s < 0 else 2), (px, 16.0, 63.0 + Z0)):
            b.prism("y", px, 12.0, 63.0 + Z0, 3.2, 20.0, "steel.dark", 6, "umbra_projector")
            b.prism("y", px, 23.0, 63.0 + Z0, 2.2, 3.0, "amber.engine", 6, "emitter")
        # The arm: the elbow back and out behind the shoulder, the forearm forward and
        # down to a wrist drum, the fist hanging from it to rest on the ground, knuckles
        # forward (Ryan, 30 September: back on the ground, and loaded).
        shoulder = (s * 31.0, 0.0, 54.0 + Z0)
        elbow = (s * 40.0, -12.0, 34.0)
        wrist = (s * 38.0, 4.0, 16.5)   # the fist's sole at z = 0
        b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.5, 8.0, "steel.dark", 6, "shoulder_joint")
        jt = b.joint("shoulder_%s" % ("l" if s < 0 else "r"), shoulder)   # the arm swings from here
        jt.__enter__()
        _beam(b, shoulder, elbow, OCT(5.2), OCT(4.6), "steel.plate", "upper_arm")
        b.prism("x", elbow[0], elbow[1], elbow[2], 5.5, 12.0, "steel.dark", 6, "elbow")
        _beam(b, elbow, wrist, OCT(4.6), OCT(5.0), "steel.panel", "forearm")
        band0 = tuple(elbow[i] + (wrist[i] - elbow[i]) * 0.3 for i in range(3))
        band1 = tuple(elbow[i] + (wrist[i] - elbow[i]) * 0.5 for i in range(3))
        _beam(b, band0, band1, OCT(5.3), OCT(5.3), "livery.livery2", "forearm_band")
        b.prism("x", wrist[0], wrist[1], wrist[2], 4.6, 13.0, "steel.dark", 6, "wrist")
        _fist(b, wrist[0], wrist[1] - 7.0, wrist[1] + 7.0, wrist[2] - 16.5, wrist[2] - 3.5, 14.0, -s)   # the inner side faces the body
        # Two mounts a hand. On the outside of each fist a Pulse Repeater (hp_3 right,
        # hp_4 left); on the fist's top the Zenith Emitter on the right (hp_5) and a bare
        # mount on the left (hp_6).
        gx = wrist[0] + s * 9.5
        b.box(min(gx - 2.5, gx + 2.5), max(gx - 2.5, gx + 2.5), wrist[1] - 5.0, wrist[1] + 5.0, wrist[2] - 13.0, wrist[2] - 7.0, "steel.plate", "repeater_mount")
        with b.socket("hp_%d" % (3 if s > 0 else 4), (gx, wrist[1] + 5.0, wrist[2] - 10.0)):
            b.prism("y", gx, wrist[1] + 5.0, wrist[2] - 10.0, 2.0, 18.0, "steel.dark", 6, "pulse_repeater")
            b.prism("y", gx, wrist[1] + 14.5, wrist[2] - 10.0, 1.4, 1.5, "amber.engine", 6, "repeater_tip")
        top = (wrist[0], wrist[1] + 1.0, wrist[2] - 3.5)
        if s > 0:
            b.box(top[0] - 3.5, top[0] + 3.5, top[1] - 5.0, top[1] + 3.0, top[2], top[2] + 3.0, "steel.plate", "emitter_mount")
            with b.socket("hp_5", (top[0], top[1] + 3.0, top[2] + 3.0)):
                b.prism("y", top[0], top[1] + 12.0, top[2] + 3.0, 2.6, 20.0, "steel.dark", 6, "zenith_emitter")
                b.prism("y", top[0], top[1] + 22.5, top[2] + 3.0, 1.8, 1.5, "amber.engine", 6, "emitter_tip")
        else:
            b.pad("hp_6", (top[0], top[1] + 1.0, top[2] + 3.0), size=(7.0, 3.0))
        jt.__exit__(None, None, None)
    # The backpack: a tall rack, red stripes down its sides, two flare pods on top (the
    # fixed component, the Solar Flare Array: built in, so no pin), the Radiator Sail's
    # vent block on its rear (a vent: detail, no mount), a mast with a red light between
    # the pods, and a row of small lit ports across the rack's back.
    b.box(-17.0, 17.0, -26.0, -14.0, 34.0 + Z0, 68.0 + Z0, "steel.panel", "rack")
    for s in (-1.0, 1.0):
        b.box(min(s * 17.0, s * 18.5), max(s * 17.0, s * 18.5), -25.0, -15.0, 38.0 + Z0, 64.0 + Z0, "livery.livery", "rack_stripe")
        b.prism("z", s * 10.0, -20.0, 74.0 + Z0, 5.0, 14.0, "steel.dark", 6, "flare_pod")
        b.prism("z", s * 10.0, -20.0, 81.5 + Z0, 5.5, 1.5, "steel.plate", 6, "pod_cap")
    b.box(-14.0, 14.0, -28.5, -26.0, 38.0 + Z0, 52.0 + Z0, "steel.vent", "vent_block")
    for i in range(3):
        b.box(-12.0 + i * 8.0, -8.0 + i * 8.0, -27.0, -26.0, 60.0 + Z0, 62.0 + Z0, "amber.engine", "rack_port")
    b.prism("z", 0.0, -20.0, 80.0 + Z0, 1.2, 24.0, "steel.dark", 6, "mast")
    b.prism("z", 0.0, -20.0, 93.0 + Z0, 2.0, 3.0, "amber.engine", 6, "mast_light")


baboon.maker = "aphelion"


# ---------------------------------------------------------------- the 28 September machines
# Second passes on Ryan's notes (29 September). Every number is a proportion.

def armadillo(b):
    """Minerva "Armadillo" (HW-22T Heavy Weapons Carrier): the biggest land machine in the
    game. A domed shell of overlapping armour bands, longer than it is wide (Ryan, 30
    September: armadillo, not turtle), on four long heavy legs whose hips stand out of the
    shell's flanks. The front band runs on as a cowl over a small cockpit bay tucked under
    it, the Badger's way (the first pass's head, with a smaller cockpit: Ryan, 30
    September). The weapons come out of round ports in the shell like a Blastoise: each
    port is a hollow of chassis with the mount at its floor, so a fitted gun rises out of
    it. Mounts (the loadout's order): hp_1 the left rear port (Rivet Gun), hp_2 the right
    rear port (Slug Cannon), hp_3 the hatch behind them, pitched forward (Missile Rack),
    hp_4 and hp_5 two forward ports flanking the cowl, level with the ground, cut back
    into the step behind the front band, bare; the plating on the flanks and the stack at
    the tail are detail. The ports are real holes: b.cut subtracts them from the bands
    before export. The Lockdown Shutters are
    the ports' stripe rims (fixed, no pin)."""
    Z0 = 26.0   # the shell's floor: the legs lift it this high
    # The shell: six bands from tail to brow, a dome in section, each proud of the last;
    # the tail band fuller than before (Ryan, 30 September: it tapered too much).
    bands = [(-50.0, -38.0, 50.0, Z0 + 21.0, 9.0), (-39.0, -22.0, 54.0, Z0 + 24.0, 10.0), (-23.0, -4.0, 60.0, Z0 + 28.0, 12.0),
             (-5.0, 14.0, 62.0, Z0 + 28.0, 12.0), (13.0, 30.0, 56.0, Z0 + 24.0, 11.0), (29.0, 46.0, 48.0, Z0 + 17.0, 9.0)]
    band_obs = []
    for i, (y0, y1, w, top, c) in enumerate(bands):
        tile = "steel.panel" if i % 2 == 0 else "steel.plate"
        band_obs.append(b.loft([(y0, _case(w, Z0 - 2.0, top, c)), (y1, _case(w, Z0 - 2.0, top, c))], tile, "band"))
    b.box(-20.0, 20.0, -48.0, 46.0, Z0 - 6.0, Z0 - 1.0, "steel.dark", "belly")
    # The cowl: the front band runs on as a lip over the cockpit bay, a hazard strip on
    # its edge; the bay a dark recess under it with a small glass slit and two lamps, out
    # far enough to be seen at the game's size (Ryan, 1 October).
    b.loft([(46.0, _case(40.0, Z0 + 1.0, Z0 + 13.0, 5.0)), (56.0, _case(32.0, Z0 + 3.0, Z0 + 10.0, 4.0))], "steel.plate", "cowl")
    b.box(-11.0, 11.0, 55.0, 56.5, Z0 + 3.0, Z0 + 5.5, "steel.hazard", "cowl_lip")
    b.box(-9.0, 9.0, 46.0, 54.0, Z0 - 4.0, Z0 + 3.0, "steel.dark", "cockpit_bay")
    b.box(-6.0, 6.0, 53.5, 54.5, Z0 - 1.5, Z0 + 1.5, "glass.glass", "visor")   # a touch back in (Ryan, 1 October)
    for s in (-1.0, 1.0):
        b.box(s * 11.0 - 1.2, s * 11.0 + 1.2, 52.0, 54.5, Z0 - 0.5, Z0 + 1.5, "amber.light", "lamp")
    # The legs: a heavy hip cuff standing out of each flank, a hinge, a thick thigh out and
    # down, a knee, a shin down onto a broad flat foot with toe plates. Long enough to stride.
    for yh in (22.0, -26.0):
        for s in (-1.0, 1.0):
            b.box(min(s * 24.0, s * 34.0), max(s * 24.0, s * 34.0), yh - 8.0, yh + 8.0, Z0 + 2.0, Z0 + 18.0, "steel.panel", "hip_cuff")
            hip = (s * 34.0, yh, Z0 + 10.0)
            knee = (s * 44.0, yh + (4.0 if yh > 0 else -4.0), 18.0)
            ankle = (s * 42.0, yh + (6.0 if yh > 0 else -6.0), 6.0)
            b.prism("x", hip[0], hip[1], hip[2], 6.5, 8.0, "steel.dark", 6, "hip_pin")
            _beam(b, hip, knee, _sq(13.0, 14.0), _sq(11.0, 12.0), "steel.plate", "thigh")
            b.prism("x", knee[0], knee[1], knee[2], 6.0, 13.0, "steel.dark", 6, "knee")
            _beam(b, knee, ankle, _sq(10.0, 11.0), _sq(10.0, 10.0), "steel.panel", "shin")
            b.box(ankle[0] - 9.0, ankle[0] + 9.0, ankle[1] - 10.0, ankle[1] + 10.0, 0.0, 6.0, "steel.dark", "foot")
            b.box(ankle[0] - 9.0, ankle[0] + 9.0, ankle[1] + (10.0 if yh > 0 else -13.0), ankle[1] + (13.0 if yh > 0 else -10.0), 0.0, 4.0, "steel.stripe", "toe_plate")
    # The rear ports: a hollow cut right through the shell (b.cut: a boolean on the bands),
    # pitched up and forward, lined by a tube with a dark floor and a stripe rim at the
    # mouth; the mount on the floor, deep, the barrel out of it (Ryan, 1 October).
    D = (0.0, 0.707, 0.707)
    for s, kind in ((-1.0, "rivet"), (1.0, "slug")):
        px = s * 14.0
        # A shallow socket (a rack fitted deep would be invisible), but the collar's outer
        # wall runs deep into the shell so its tilted base never stands proud of it (Ryan,
        # 1 October: the tube and the body did not meet).
        p0 = (px, -4.5, Z0 + 25.5)
        p1 = (px, 0.0, Z0 + 30.0)
        b.cut(band_obs, p0, p1, 6.6)
        _tube(b, (px, -11.5, Z0 + 18.5), p1, 8.0, 6.4, 8, "steel.plate", "port", floor_depth=9.9)
        _tube(b, (px, -0.9, Z0 + 29.1), (px, 0.3, Z0 + 30.3), 8.7, 6.4, 8, "steel.stripe", "port_rim", floor=False)
        mount = Vector((px, -3.5, Z0 + 26.5))
        DV = Vector(D)
        # The barrels a fixed length from the mount (they had run to a fixed muzzle point
        # and grew with every push back: Ryan, 1 October).
        if kind == "rivet":
            with b.socket("hp_1", tuple(mount), forward=D, scale=1.2):
                _beam(b, tuple(mount), tuple(mount + DV * 16.0), _poly(3.4, 6), _poly(3.4, 6), "steel.dark", "rivet_barrel")
                _beam(b, tuple(mount + DV * 16.0), tuple(mount + DV * 18.5), _poly(4.0, 6), _poly(3.6, 6), "steel.plate", "rivet_muzzle")
        else:
            with b.socket("hp_2", tuple(mount), forward=D, scale=1.2):
                _beam(b, tuple(mount), tuple(mount + DV * 23.0), _poly(3.0, 6), _poly(2.8, 6), "steel.dark", "slug_barrel")
                _beam(b, tuple(mount + DV * 23.0), tuple(mount + DV * 26.5), _poly(3.8, 6), _poly(3.4, 6), "steel.plate", "slug_muzzle")
    # The hatch behind the ports: a missile cell in a stripe frame, pitched forward with
    # the ports so a cannon fitted there is a hull gun (hp_3).
    # Up and back a little, so a cannon fitted there clears the shell's crown ahead of it
    # (Ryan, 1 October).
    _beam(b, (0.0, -34.0, Z0 + 20.0), (0.0, -26.0, Z0 + 28.0), _sq(16.0, 16.0), _sq(16.0, 16.0), "steel.stripe", "hatch_frame")
    with b.socket("hp_3", (0.0, -26.0, Z0 + 28.0), forward=D, scale=1.2):
        _beam(b, (0.0, -32.0, Z0 + 22.0), (0.0, -24.5, Z0 + 29.5), _sq(13.0, 13.0), _sq(13.0, 13.0), "steel.missile", "missile_cell")
    # Two forward ports flanking the cowl: level with the ground, cut straight back into
    # the step behind the front band (the fifth band's front face stands seven above the
    # sixth's crown), so a gun comes out of that plate and runs forward over the cowl's
    # band (Ryan, 1 October). Bare mounts on their floors, deep (hp_4, hp_5).
    for s, n in ((-1.0, 4), (1.0, 5)):
        px = s * 14.0
        # Lowered so the collar sits inside the plate behind the cowl, its wall run back
        # into the band (Ryan, 1 October: the tube and the body did not meet).
        ZF = Z0 + 17.5
        p0 = (px, 22.0, ZF)
        p1 = (px, 31.0, ZF)
        b.cut(band_obs, p0, p1, 4.8)
        _tube(b, (px, 14.0, ZF), p1, 6.0, 4.6, 8, "steel.plate", "fore_port", floor_depth=8.0)
        _tube(b, (px, 30.1, ZF), (px, 31.3, ZF), 6.6, 4.6, 8, "steel.stripe", "fore_rim", floor=False)
        # A firing channel cut down through the front band ahead of the port, so a gun
        # fitted there lies in a trough instead of running into the shell (Ryan, 1
        # October: the barrels would have clipped the band in front).
        b.cut_box(band_obs, px - 4.6, px + 4.6, 30.0, 47.0, ZF - 4.0, Z0 + 30.0)
        b.pin("hp_%d" % n, (px, 24.5, ZF), forward=(0.0, 1.0, 0.0), scale=1.2)
    # The slab between the two channels cut away too, so the front band steps down to one
    # wide firing deck ahead of the ports (Ryan, 1 October).
    b.cut_box(band_obs, -9.6, 9.6, 30.0, 47.0, ZF - 4.0, Z0 + 30.0)
    # Plating on the flanks between the hips and the blowout stack at the tail with vents
    # across the rear band: detail, no mounts.
    for s in (-1.0, 1.0):
        b.box(min(s * 29.0, s * 32.5), max(s * 29.0, s * 32.5), -10.0, 10.0, Z0 + 2.0, Z0 + 18.0, "livery.livery2", "ablative")
    b.box(-14.0, -2.0, -51.0, -50.0, Z0 + 2.0, Z0 + 12.0, "steel.vent", "tail_vents")
    b.prism("z", 9.0, -44.0, Z0 + 24.0, 4.4, 16.0, "steel.dark", 6, "stack")
    b.prism("z", 9.0, -44.0, Z0 + 33.0, 5.4, 2.0, "steel.plate", 6, "stack_cap")


armadillo.maker = "minerva"


def wild_boar(b):
    """Minerva "Wild Boar" (AB-70R Assault Breacher): an H-tank, the treads the whole point
    (Ryan, 29 September: wider, squatter, treads prominent; it barrels over and through
    everything). Two huge tread units carry a low hull slung between them; a spiked
    cowcatcher in a V thrusts out ahead of the treads, bars and spikes and two tusks (the
    Breaching Plow, fixed, no pin); a low wide turret with a double-barrelled cannon. Pins:
    Mounts (Ryan, 30 September; five hardpoints): hp_1 and hp_2 two parallel guns set
    apart on a larger turret (Slug Cannons), hp_3 the stock missile pod on the left rear
    quarter's deck, hp_4 bare on the turret's top, hp_5 bare on the right rear quarter; the
    tread plating and the stack are detail (armour and vents take no mount)."""
    TX, TW, TH = 26.0, 24.0, 24.0   # tread centre, width, height
    for s in (-1.0, 1.0):
        cx = s * TX
        b.loft([(-40.0, rect(cx, TW, 6.0, 14.0)), (-32.0, rect(cx, TW, 0.0, TH)), (28.0, rect(cx, TW, 0.0, TH)), (38.0, rect(cx, TW, 6.0, 14.0))], "bore.tread", "tread")
        b.box(cx - TW / 2 - 1.0, cx + TW / 2 + 1.0, -34.0, 30.0, TH - 1.0, TH + 5.0, "steel.plate", "skirt")
        b.box(min(cx - s * 5.0, cx + s * 8.0), max(cx - s * 5.0, cx + s * 8.0), -32.0, 16.0, TH + 5.0, TH + 9.0, "steel.panel", "tread_deck")   # trimmed inboard, clear of the turret's drum; back to the tail, under the pod
        b.box(cx - 6.0, cx + 6.0, 30.0, 34.0, TH - 6.0, TH + 4.0, "steel.stripe", "skirt_tip")
    # The hull slung low between the treads, its glacis sloping to the cowcatcher.
    b.loft([(-38.0, rect(0.0, 28.0, 6.0, 26.0)), (10.0, rect(0.0, 28.0, 6.0, 26.0)), (30.0, rect(0.0, 26.0, 8.0, 16.0))], "steel.panel", "hull")
    b.box(-10.0, 10.0, 24.0, 25.0, 12.0, 15.0, "glass.glass", "slit")
    for s in (-1.0, 1.0):
        b.box(s * 11.0 - 1.5, s * 11.0 + 1.5, 24.0, 26.0, 13.0, 16.0, "amber.light", "lamp")
    # The cowcatcher: two slabs in a V from a point ahead of the machine back to the tread
    # fronts, a hazard lip, a row of spikes leaning forward off each slab's top, two tusks
    # off the point, bars back to the hull.
    # Ahead of the treads' fronts (they ran into it: Ryan, 1 October), and rooted: the
    # spine runs back into the hull and the bars reach it from the glacis.
    # Tall and wide, overhanging the treads, its ends barely ahead of their fronts, raked
    # back so the face reads at an angle, the two support bars meeting its back and the
    # tusks growing out of its face (Ryan, 1 October). The spine's height is unchanged.
    APEX, SPAN, SWEEP, RAKE, T = 63.0, 52.0, 24.0, 7.0, 2.0   # the point's y, the half width (wider again: Ryan, 1 October), the y the ends sit behind the point, the top's set-back, the thickness
    def face(x, z, back=False):
        return APEX - SWEEP * abs(x) / SPAN - RAKE * (z - 2.0) / 24.0 - (T if back else 0.0)
    for s in (-1.0, 1.0):
        _rings(b, [[(0.0, face(0.0, 2.0), 2.0), (s * SPAN, face(SPAN, 2.0), 2.0), (s * SPAN, face(SPAN, 2.0, True), 2.0), (0.0, face(0.0, 2.0, True), 2.0)],
                   [(0.0, face(0.0, 26.0), 26.0), (s * SPAN, face(SPAN, 26.0), 26.0), (s * SPAN, face(SPAN, 26.0, True), 26.0), (0.0, face(0.0, 26.0, True), 26.0)]], "steel.plate", "catcher")
        # The top carried up behind the spike row (Ryan, 1 October: more plow without
        # climbing into the cannons): an upper band set back by the plate's thickness.
        # Lined up with the plate's top and leaning hard back toward the chassis (Ryan, 1
        # October: as if to push bodies up over the hull).
        LEAN = 7.0
        _rings(b, [[(0.0, face(0.0, 26.0), 26.0), (s * SPAN, face(SPAN, 26.0), 26.0), (s * SPAN, face(SPAN, 26.0, True), 26.0), (0.0, face(0.0, 26.0, True), 26.0)],
                   [(0.0, face(0.0, 26.0) - LEAN, 32.0), (s * SPAN, face(SPAN, 26.0) - LEAN, 32.0), (s * SPAN, face(SPAN, 26.0, True) - LEAN, 32.0), (0.0, face(0.0, 26.0, True) - LEAN, 32.0)]], "steel.plate", "catcher_crest")
        for k in range(6):
            f = (k + 0.5) / 6.0
            bx = s * SPAN * f
            by = face(bx, 26.0) - T / 2.0
            _spike(b, (bx, by, 25.0), (bx + s * 2.0, by + 7.0, 33.0), 2.0, "steel.dark", "spike")
        _beam(b, (s * 12.0, 26.0, 8.0), (s * 12.0, face(12.0, 8.0, True) + 0.5, 8.0), _sq(5.0, 5.0), _sq(5.0, 5.0), "steel.dark", "bar")
        _beam(b, (s * 10.0, face(10.0, 7.0) - 0.5, 7.0), (s * 15.0, face(10.0, 7.0) + 30.0, 17.0), _poly(5.0, 6), _poly(1.4, 6), "steel.dark", "tusk")   # grown with the plow, and apart (Ryan, 1 October)
    b.box(-2.0, 2.0, 20.0, face(0.0, 22.0) - 1.5, 2.0, 22.0, "steel.hazard", "catcher_spine")   # a smidge back off the front (Ryan, 1 October)
    # The turret: a wide eight-sided drum on the hull, the machine's most prominent
    # feature, two parallel guns set well apart off a wide mantlet (hp_1 left, hp_2 right),
    # a hatch and a sight; a bare mount on its top (hp_4).
    # Up on a base so the drum turns clear of the skirts and the tread decks (Ryan, 1
    # October, from his Blender view: it would have clipped the side panels).
    b.prism("z", 0.0, -6.0, 28.0, 15.0, 4.0, "steel.panel", 8, "turret_base")
    b.prism("z", 0.0, -6.0, 31.0, 19.0, 2.0, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, -6.0, 32.0)):   # the turret traverses (the view turns a turret joint about its up axis)
        b.prism("z", 0.0, -6.0, 37.0, 20.0, 10.0, "steel.panel", 8, "turret", phase=math.pi / 8)
        b.box(-15.0, 15.0, 8.0, 14.0, 33.0, 41.0, "steel.plate", "mantlet")
        for s in (-1.0, 1.0):
            with b.socket("hp_%d" % (1 if s < 0 else 2), (s * 9.0, 14.0, 37.0)):
                b.prism("y", s * 9.0, 32.0, 37.0, 2.8, 40.0, "steel.dark", 6, "gun")
                b.prism("y", s * 9.0, 51.0, 37.0, 3.4, 4.0, "steel.plate", 6, "muzzle")
        b.box(-4.0, 4.0, -20.0, -14.0, 42.0, 44.0, "steel.plate", "hatch")
        b.box(13.0, 16.0, -6.0, 0.0, 42.0, 45.0, "amber.light", "sight")
        b.pad("hp_4", (0.0, 2.0, 44.0))
    # The stock missile pod on the left rear quarter's deck (hp_3), its face forward.
    # Set back and out so the turret's drum and its guns sweep clear of it (Ryan, 1
    # October: the turret must look able to turn).
    with b.socket("hp_3", (-TX - 1.0, -16.0, TH + 16.0)):
        b.box(-TX - 8.0, -TX + 6.0, -30.0, -16.2, TH + 9.0, TH + 23.0, "steel.panel", "missile_box")
        b.box(-TX - 8.0, -TX + 6.0, -16.2, -15.2, TH + 9.0, TH + 23.0, "steel.missile", "missile_face")
    # Ablative plating on the outer faces of the treads and the blowout stack at the hull's
    # tail with vents beside it: detail, no mounts.
    for s in (-1.0, 1.0):
        for y0, y1 in ((-26.0, -8.0), (-4.0, 14.0)):
            b.box(min(s * (TX + TW / 2 + 1.0), s * (TX + TW / 2 + 4.0)), max(s * (TX + TW / 2 + 1.0), s * (TX + TW / 2 + 4.0)), y0, y1, 8.0, 22.0, "livery.livery2", "ablative")
    b.box(-12.0, 12.0, -41.0, -40.0, 8.0, 22.0, "steel.vent", "rear_vents")
    b.prism("z", 0.0, -34.0, 30.0, 4.0, 12.0, "steel.dark", 6, "stack")
    b.prism("z", 0.0, -34.0, 37.0, 5.0, 2.0, "steel.plate", 6, "stack_cap")
    # A bare mount on the right rear quarter's deck (hp_5).
    b.pad("hp_5", (TX, -14.0, TH + 12.0))


wild_boar.maker = "minerva"


def _wheel(b, cx, cy, r, w, label="wheel", lit=False):
    """An eight-sided wheel across x: rubber tread with a dark hub, a lit hub ring if asked."""
    b.prism("x", cx, cy, r, r, w, "bore.tread", 8, label, phase=math.pi / 8)
    b.prism("x", cx, cy, r, r * 0.5, w + 1.0, "steel.dark", 8, label + "_hub", phase=math.pi / 8)
    if lit:
        b.prism("x", cx, cy, r, r * 0.3, w + 1.6, "amber.engine", 8, label + "_ring", phase=math.pi / 8)


def prairie_dog(b):
    """Wainwright & Sutler "Prairie Dog" (Pattern 9 Scout Car): light and fast, an armoured
    buggy rather than a dune buggy (Ryan, 29 September: no open cockpits; the Bilecka Panther
    as a reference). Big wheels under angular arches, a wedge of a body with a raked
    armoured windscreen, and on the roof a rotating turret carrying the pintle scattergun
    (the Flakshot Repeater, fixed, no pin, the class barrel on the turret's left) with the
    twin autoguns on the turret's right (hp_1, the class twin barrel); a sensor mast up out
    of the tail, the dog on watch. hp_2 the rear-left launcher (Incendiary Shells), hp_3
    bare on the rear-right corner (the Flak Skirt takes no mount; the skirt plate is
    detail). Ryan, 30 September: the mast lower, the visor flush with the body; 1 October:
    a squatter turret, a gun either side, none in the middle, nothing hand-modelled."""
    R = 10.0
    for yw in (18.0, -18.0):
        for s in (-1.0, 1.0):
            _wheel(b, s * 20.0, yw, R, 8.0)
            # An angular arch over each wheel, open outward.
            b.loft([(yw - 12.0, rect(s * 18.0, 10.0, R + 2.0, R + 6.0)), (yw, rect(s * 18.0, 10.0, R + 6.0, R + 10.0)), (yw + 12.0, rect(s * 18.0, 10.0, R + 2.0, R + 6.0))], "steel.plate", "arch")
    # The body: a wedge lofted from a squared tail to a low raked nose, a chin plate under.
    b.loft([(-30.0, rect(0.0, 28.0, 8.0, 24.0)), (-6.0, rect(0.0, 30.0, 8.0, 28.0)), (12.0, rect(0.0, 28.0, 8.0, 24.0)), (32.0, rect(0.0, 20.0, 10.0, 15.0))], "steel.panel", "body")
    b.box(-10.0, 10.0, 30.0, 33.0, 8.0, 12.0, "steel.dark", "chin")
    for s in (-1.0, 1.0):
        b.box(min(s * 14.0, s * 15.5), max(s * 14.0, s * 15.5), -26.0, 6.0, 12.0, 20.0, "livery.livery2", "flank_stripe")
    # The windscreen: armoured glass lying flush on the raked roof, slit-narrow, a brow
    # over its top edge.
    _rings(b, [[(-10.0, 13.0, 23.6), (10.0, 13.0, 23.6), (10.0, 13.0, 24.8), (-10.0, 13.0, 24.8)],
               [(-9.0, 19.0, 20.9), (9.0, 19.0, 20.9), (9.0, 19.0, 22.1), (-9.0, 19.0, 22.1)]], "glass.glass", "windscreen")
    b.box(-12.0, 12.0, 10.5, 13.5, 23.5, 26.5, "steel.plate", "brow")
    # The turret on the roof (Ryan, 1 October): squatter, wider, a gun on either side and
    # none in the middle, every gun the class shape and nothing hand-modelled. The left
    # gun is the fixed Flakshot Repeater (a barrel, no pin); the right is hp_1, the Twin
    # Autoguns (a twin barrel).
    b.prism("z", 0.0, -8.0, 28.25, 5.5, 1.5, "steel.dark", 8, "neck")
    b.prism("z", 0.0, -8.0, 29.75, 7.0, 1.5, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, -8.0, 30.5)):   # traverses
        b.prism("z", 0.0, -8.0, 33.0, 7.5, 5.0, "steel.panel", 8, "turret", phase=math.pi / 8)
        # The guns at the drum's middle, their receivers sunk into its flanks (Ryan, 1
        # October: they floated off it, too far forward).
        start = len(b.objects)
        shape_barrel(b, 0.7)
        for ob in b.objects[start:]:
            ob.matrix_world = Matrix.Translation(Vector((-8.8, -9.0, 33.0)))
        b.stock("hp_1", (8.8, -9.0, 33.0), "twin_barrel", scale=0.7)
    # The mast, out of the tail's centre, lower: a post, a sensor head, a red light.
    b.prism("z", 0.0, -27.0, 28.5, 1.2, 11.0, "steel.dark", 4, "mast")   # rooted in the roof; a little shorter (Ryan, 1 October)
    b.box(-2.5, 2.5, -29.5, -24.5, 34.0, 39.0, "steel.panel", "sensor_head")
    b.box(-1.5, 1.5, -24.4, -23.6, 35.0, 38.0, "glass.glass", "sensor_eye")
    b.prism("z", 0.0, -27.0, 40.5, 1.5, 3.0, "amber.engine", 6, "mast_light")
    # The tail (Ryan, 30 September: something to break up the back): a raised hatch panel
    # with a handle, a jerry can strapped either side, tail lights at the corners, a hitch.
    b.box(-7.0, 7.0, -30.8, -30.0, 11.0, 21.0, "steel.panel", "rear_hatch")
    b.box(-3.0, 3.0, -31.6, -30.8, 15.0, 16.2, "steel.dark", "hatch_handle")
    for s in (-1.0, 1.0):
        b.box(s * 11.0 - 2.0, s * 11.0 + 2.0, -32.5, -30.0, 10.0, 17.0, "livery.livery2", "jerry_can")
        b.box(s * 11.0 - 2.4, s * 11.0 + 2.4, -32.7, -29.8, 13.0, 13.8, "steel.dark", "can_strap")
        b.box(s * 12.0 - 1.5, s * 12.0 + 1.5, -30.6, -30.0, 19.0, 21.5, "amber.light", "tail_light")
    b.box(-1.5, 1.5, -34.0, -30.0, 8.0, 10.0, "steel.dark", "hitch")
    # The launcher on the rear-left corner (hp_2): the class rack, its tube face one whole
    # tile (the hand-built box showed a quarter of the tile: Ryan, 1 October).
    b.stock("hp_2", (-10.0, -26.0, 28.5), "rack", scale=0.6)
    # The skirt plate over the right wheel line: detail. The third mount (hp_3) is bare on
    # the rear-right corner, the launcher's twin.
    b.box(23.0, 25.0, -24.0, 24.0, 6.0, 15.0, "steel.plate", "skirt")
    b.pad("hp_3", (10.0, -26.0, 26.0), scale=0.7, size=(6.0, 2.0))   # on the roof, not above it
    for s in (-1.0, 1.0):
        b.box(s * 7.0 - 2.0, s * 7.0 + 2.0, 32.5, 33.5, 12.0, 14.0, "amber.light", "lamp")


prairie_dog.maker = "wainwright_sutler"


def dingo(b):
    """Wainwright & Sutler "Dingo" (Pattern 12 Support Car): the agile, stealthy one, low
    enough to skirt between a big foe's legs (Ryan, 29 September; the MK-200 and the
    Tumbler, toned down to W&S). A flat wedge of a body, and the wheels out on swing arms,
    each on its own cambered arm off the body's corners, hubs lit, so it reads as a thing
    that steps rather than rolls. The Megataser Harpoon (fixed, no pin) lies low along
    the roof, its capacitor drum sunk into the tail. Mounts: hp_1 the nose guns (Twin
    Autoguns), hp_2 the rear-right deck tube (Pocket Mortar), hp_3 bare on the rear-left
    deck; the Coolant Dump takes no mount, so its tank is detail on both flanks (Ryan, 30
    September: the rail into the drum, a vent on the tail plate, the glass along the body)."""
    R = 8.0
    # The body: a low wedge, its top at 18, the nose a knife.
    b.loft([(-30.0, rect(0.0, 30.0, 6.0, 18.0)), (0.0, rect(0.0, 32.0, 6.0, 20.0)), (22.0, rect(0.0, 28.0, 6.0, 14.0)), (36.0, rect(0.0, 16.0, 7.0, 9.0))], "steel.plate", "body")
    b.box(-13.0, 13.0, -32.0, -30.0, 6.0, 16.0, "steel.dark", "tail_plate")
    b.box(-10.0, 10.0, -32.6, -31.8, 7.5, 14.5, "steel.vent", "tail_vent")
    for s in (-1.0, 1.0):
        b.box(min(s * 15.0, s * 16.2), max(s * 15.0, s * 16.2), -24.0, 4.0, 9.0, 15.0, "livery.livery2", "flank_stripe")
        b.box(min(s * 13.0, s * 14.2), max(s * 13.0, s * 14.2), -14.0, -2.0, 15.0, 19.0, "steel.vent", "side_vent")
    # The visor: a long strip of glass lying on the raked front, following the body's
    # taper back toward the roof.
    _rings(b, [[(-10.0, 16.0, 15.8), (10.0, 16.0, 15.8), (10.0, 16.0, 17.2), (-10.0, 16.0, 17.2)],
               [(-7.0, 30.0, 11.3), (7.0, 30.0, 11.3), (7.0, 30.0, 12.5), (-7.0, 30.0, 12.5)]], "glass.glass", "visor")
    # The wheels on swing arms: from a hip on the body's corner out and down to the hub,
    # cambered so the wheel leans in at the top; a lit ring in each hub.
    for yw, hy in ((20.0, 14.0), (-20.0, -14.0)):
        for s in (-1.0, 1.0):
            hip = (s * 15.0, hy, 14.0)
            hub = (s * 26.0, yw, R)
            b.prism("y", hip[0], hip[1], hip[2], 3.0, 6.0, "steel.dark", 6, "arm_hip")
            _beam(b, hip, hub, _sq(5.0, 6.0), _sq(4.0, 5.0), "steel.panel", "swing_arm")
            _wheel(b, hub[0], hub[1], R, 7.0, lit=True)
    # The harpoon: a low rail along the roof to a launch head at the nose's root, the barbed
    # dart in it; the capacitor drum half sunk into the tail with a lit band.
    b.box(-1.5, 1.5, -14.0, 20.0, 20.0, 22.5, "steel.dark", "rail")   # into the capacitor drum
    b.box(-3.5, 3.5, 14.0, 22.0, 19.0, 25.0, "steel.plate", "launch_head")
    _beam(b, (0.0, -6.0, 23.5), (0.0, 34.0, 23.5), _poly(1.2, 6), _poly(0.4, 6), "steel.dark", "dart")
    for s in (-1.0, 1.0):
        _beam(b, (0.0, 30.0, 23.5), (s * 2.6, 25.0, 23.5), _poly(0.8, 4), _poly(0.3, 4), "steel.dark", "barb")
    b.prism("x", 0.0, -20.0, 18.0, 7.0, 24.0, "steel.dark", 8, "capacitor", phase=math.pi / 8)
    b.prism("x", 0.0, -20.0, 18.0, 7.6, 2.5, "amber.strip", 8, "capacitor_ring", phase=math.pi / 8)
    for s in (-1.0, 1.0):
        b.prism("x", s * 13.0, -20.0, 18.0, 4.0, 2.0, "steel.plate", 8, "capacitor_cap")
    # The nose guns: two ports in the raked front either side of the visor (hp_1).
    with b.socket("hp_1", (0.0, 24.0, 10.5), scale=0.6):
        for s in (-1.0, 1.0):
            b.prism("y", s * 6.0, 30.0, 10.5, 1.4, 16.0, "steel.dark", 6, "autogun")
    # The pocket mortar on the rear deck beside the drum, pitched up over the tail (hp_2).
    b.prism("z", 10.0, -28.0, 18.5, 2.6, 1.5, "steel.dark", 8, "mortar_base")
    with b.socket("hp_2", (10.0, -26.0, 23.0), forward=(0.0, 0.406, 0.914), scale=0.6):
        _beam(b, (10.0, -28.0, 19.0), (10.0, -24.0, 28.0), _poly(2.4, 6), _poly(2.7, 6), "steel.panel", "mortar")
    # The coolant tanks low on both flanks, a drum with a grille and a dump valve each:
    # detail. The third mount (hp_3) is bare on the rear-left deck, the mortar's twin.
    for s in (-1.0, 1.0):
        b.prism("y", s * 17.5, -6.0, 11.0, 3.2, 18.0, "steel.plate", 8, "coolant_tank")
        b.box(min(s * 19.2, s * 17.0), max(s * 19.2, s * 17.0), -4.0, 4.0, 10.0, 12.0, "steel.vent", "tank_grille")
        b.prism("z", s * 17.5, 2.5, 7.0, 1.0, 3.0, "steel.dark", 6, "dump_valve")
    b.pad("hp_3", (-10.0, -26.0, 21.0), scale=0.6, size=(6.0, 2.0))
    for s in (-1.0, 1.0):
        b.prism("z", s * 11.0, -29.0, 22.0, 0.5, 12.0, "steel.dark", 4, "antenna")


dingo.maker = "wainwright_sutler"


def goshawk(b):
    """Kestrel "Goshawk" (K-9 Mk II Attack Airframe): a medium-large airframe, endurance over
    burst. Second pass (Ryan, 29 September): a wider span on a shorter body, a smaller
    canopy, weapons clear of the wings, no traditional tail: the boosters ride the aft
    fuselage's shoulders as nacelles, each carrying a fin canted outward, and the cannon is
    a wide short bore tucked under the nose in a fairing that runs back along the belly to
    the engines it draws heat from (the Afterburner Cannon, fixed, no pin). Pins under the
    wings: hp_1 left inner (Laser Carbine), hp_2 right inner (Headhunter Rifle), hp_3 left
    outer (Arc Projector, two prongs), hp_4 right outer (Deflector, a projector's dish);
    hp_5 bare under the belly aft of the cannon (the Ram-air Scoop is the dorsal intake,
    detail, no mount). Ryan, 30 September: the cannon recessed behind the nose, a wide low
    oval bore, its fairing blended into the fuselage. Centred on z = 0 like the Sparrowhawk."""
    # Fuselage: short and deep, a blunt nose.
    b.loft([(44.0, _fuse(6.0, 2.2, 2.4)), (34.0, _fuse(12.0, 4.4, 4.2)), (18.0, _fuse(17.0, 5.8, 5.2)),
            (0.0, _fuse(20.0, 6.8, 5.8)), (-18.0, _fuse(20.0, 6.6, 5.6)), (-34.0, _fuse(14.0, 4.6, 4.0)), (-42.0, _fuse(8.0, 2.6, 2.4))], "steel.plate", "fuselage")
    # The Afterburner Cannon: a wide short bore under the nose, its fairing lofted out of
    # the belly and running back to the engines.
    # The whole grey chunk under the fuselage is the cannon (Ryan, 1 October), so it is
    # decorated along its length: vents cut into the fairing's flanks as pockets (b.cut_box)
    # with a glow at their floors, running back from the muzzle; one glowing groove inset
    # in the barrel; the muzzle open with a rim (an annulus, no cap), the bore tapering
    # inward with glowing walls and a hot floor just inside.
    fairing = b.loft([(-22.0, hexagon(0.0, -5.6, 8.0, 3.0)), (0.0, hexagon(0.0, -6.6, 14.0, 4.6)), (24.0, hexagon(0.0, -6.4, 13.0, 4.2)),
                      (30.0, hexagon(0.0, -5.9, 10.5, 3.4))], "steel.dark", "cannon_fairing")
    for s in (-1.0, 1.0):
        for k in range(4):
            y0 = 2.0 + k * 6.0
            hw = 7.0 - abs(y0 + 2.0 - 12.0) * 0.02   # the flank's half width near the pocket
            x_in, x_out = s * (hw - 1.6), s * (hw + 1.0)   # deeper, longer, the glow a small strip at the floor so it reads as a light inside, not a slab (Ryan, 1 October)
            b.cut_box([fairing], min(x_in, x_out), max(x_in, x_out), y0, y0 + 4.4, -7.3, -5.3)
            b.box(min(x_in, x_in + s * 0.2), max(x_in, x_in + s * 0.2), y0 + 0.1, y0 + 4.3, -7.2, -5.4, "amber.glow", "vent_glow")   # the whole floor of the cut (Ryan, 1 October)
    b.loft([(29.0, hexagon(0.0, -6.0, 9.0, 3.0)), (33.4, hexagon(0.0, -6.0, 8.6, 2.85))], "steel.dark", "cannon_barrel", cap=False)
    b.loft([(33.4, hexagon(0.0, -6.0, 7.8, 2.4)), (34.6, hexagon(0.0, -6.0, 7.8, 2.4))], "amber.glow", "barrel_groove", cap=False)
    b.loft([(34.6, hexagon(0.0, -6.0, 8.5, 2.8)), (40.0, hexagon(0.0, -6.0, 8.0, 2.6))], "steel.dark", "cannon_barrel", cap=False)
    _rings(b, [[(x, 40.0, z) for x, z in hexagon(0.0, -6.0, 8.0, 2.6)], [(x, 40.0, z) for x, z in hexagon(0.0, -6.0, 6.8, 2.1)]], "steel.dark", "cannon_rim", cap=False)
    b.loft([(40.0, hexagon(0.0, -6.0, 6.8, 2.1)), (38.0, hexagon(0.0, -6.0, 5.6, 1.75))], "amber.glow", "cannon_bore", cap=False)
    b.loft([(38.1, hexagon(0.0, -6.0, 5.6, 1.75)), (38.4, hexagon(0.0, -6.0, 5.6, 1.75))], "amber.lit", "cannon_glow")   # a touch back in from the tenth round (Ryan, 1 October)
    # Canopy: small and faired, forward.
    b.loft([(22.0, hexagon(0.0, 6.0, 6.0, 0.5)), (14.0, hexagon(0.0, 7.0, 7.4, 2.4)), (4.0, hexagon(0.0, 7.0, 7.4, 2.4)), (-2.0, hexagon(0.0, 6.6, 7.0, 1.8))], "glass.glass", "canopy")
    # The dorsal intake behind it (hp_5), its mouth forward.
    b.loft([(-2.0, hexagon(0.0, 7.0, 8.0, 2.8)), (-6.0, hexagon(0.0, 8.2, 9.0, 5.2)), (-16.0, hexagon(0.0, 7.2, 8.4, 3.2))], "steel.panel", "intake")
    b.loft([(-6.2, hexagon(0.0, 8.2, 7.8, 4.4)), (-5.4, hexagon(0.0, 8.2, 7.8, 4.4)), ], "bore.dark", "intake_mouth")
    # The fifth mount, bare, a stub under the cannon's fairing amidships.
    b.pad("hp_5", (0.0, -12.0, -7.6), forward=(0.0, 1.0, 0.0), scale=0.7, size=(5.0, 1.5))
    # Wings: level from the shoulder to the knuckle, drooped from the knuckle to a wide tip.
    def wing_z(x):
        ax = abs(x)
        if ax <= 30.0:
            return 2.0 + (ax - 9.0) / 21.0 * 0.8
        return 2.8 - (ax - 30.0) / 34.0 * 12.8
    for s in (-1.0, 1.0):
        root = [(s * 9.0, -6.0, 1.0), (s * 9.0, -6.0, 3.0), (s * 9.0, 20.0, 2.0)]
        knuckle = [(s * 30.0, -2.0, 2.0), (s * 30.0, -2.0, 3.6), (s * 30.0, 14.0, 2.8)]
        tip = [(s * 64.0, 2.0, -10.4), (s * 64.0, 2.0, -9.6), (s * 64.0, 8.0, -10.0)]
        _wing(b, root, knuckle, "livery.livery", "wing_inner")
        _wing(b, knuckle, tip, "livery.livery", "wing_outer")
        for k, (px, r) in enumerate(((20.0, 2.4), (46.0, 2.1))):
            wz = wing_z(px)
            pz = wz - 1.0 - r - 2.0   # the pod hangs clear under the wing on a pylon
            b.box(s * px - 1.2, s * px + 1.2, -1.0, 7.0, pz + r - 0.5, wz - 0.6, "steel.plate", "pylon")
            n = (1 if s < 0 else 2) if k == 0 else (3 if s < 0 else 4)
            with b.socket("hp_%d" % n, (s * px, 6.0, pz), scale=0.7):
                b.prism("y", s * px, 3.0, pz, r, 18.0, "steel.dark", 6, "pod")
                if n == 3:
                    for s2 in (-1.0, 1.0):   # the Arc Projector's prongs
                        b.prism("y", s * px + s2 * 1.1, 14.0, pz, r * 0.3, 6.0, "steel.dark", 6, "prong")
                elif n == 4:   # the Deflector's dish
                    b.prism("y", s * px, 12.6, pz, r * 1.4, 1.2, "steel.plate", 8, "dish")
                    b.prism("y", s * px, 13.5, pz, r * 0.5, 0.8, "amber.engine", 8, "dish_core")
                else:
                    b.prism("y", s * px, 14.0, pz, r * 0.55, 6.0, "steel.dark", 6, "pod_gun")
    # The nacelles: two boosters on the aft shoulders, their mouths dark, exhausts lit, and a
    # fin canted outward off each nacelle's top; a short ventral strake under the tail.
    for s in (-1.0, 1.0):
        nx, nz = s * 11.0, 5.5
        b.prism("y", nx, -24.0, nz, 6.0, 30.0, "steel.dark", 6, "nacelle", phase=math.pi / 6)
        b.box(min(s * 5.0, s * 8.0), max(s * 5.0, s * 8.0), -34.0, -14.0, 1.0, 6.0, "steel.plate", "nacelle_root")
        b.prism("y", nx, -39.5, nz, 6.4, 1.5, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
        b.loft([(-40.0, hexagon(nx, nz, 10.0, 8.6)), (-40.5, hexagon(nx, nz, 9.0, 7.6))], "amber.engine", "exhaust")
        b.loft([(-9.5, hexagon(nx, nz, 9.6, 8.2)), (-9.0, hexagon(nx, nz, 8.6, 7.2))], "bore.dark", "nacelle_mouth")
        a = math.radians(s * 32.0)
        root = [(nx, -38.0, nz + 5.5), (nx, -22.0, nz + 5.5), (nx, -22.0, nz + 6.3), (nx, -38.0, nz + 6.3)]
        tip = [(nx + 15.0 * math.sin(a), -40.0, nz + 5.5 + 15.0 * math.cos(a)), (nx + 15.0 * math.sin(a), -32.0, nz + 5.5 + 15.0 * math.cos(a)),
               (nx + 15.0 * math.sin(a), -32.0, nz + 6.1 + 15.0 * math.cos(a)), (nx + 15.0 * math.sin(a), -40.0, nz + 6.1 + 15.0 * math.cos(a))]
        _wing(b, root, tip, "livery.livery", "fin")
    b.loft([(-42.0, rect(0.0, 1.2, -6.0, -2.4)), (-30.0, rect(0.0, 1.6, -7.5, -3.5))], "steel.dark", "strake")
    b.box(-2.0, 2.0, -20.0, 22.0, 6.8, 7.4, "livery.livery", "spine_stripe")


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
    """The Arsenal "Nemesis" (Arsenal Instrument IV). Second pass (Ryan, 29 September: the
    first was the Baboon without a head): an almost-human brute in demonic armour, a Pacific
    Rim homage in the Apex way. Hard lines, no drums: a tall armoured figure on plantigrade
    legs in greaves, a chest of angled plates round a round lit core, a hooded helm with a
    visor slit and two horns, and asymmetry: the left shoulder a massive spiked pauldron
    carrying the Ward Plate, the right shoulder smaller with the Meteor Artillery's tubes
    behind it and the heavier arm below it carrying the Plasma Carbine. Spikes on the
    shoulders, forearms and knees. The Gravity Knuckles are the fists (fixed, no pins).
    Third pass (Ryan, 30 September): a humanoid's arms, elbows bent and the spiked fists
    forward, no gun on the hand; a hip cannon in the Atlas way; traps like the Hulk's; the
    core's port striped like a vent. Mounts: hp_1 the right hip cannon (Plasma Carbine),
    hp_2 the right shoulder tubes (Meteor Artillery), hp_3 and hp_4 two chest ports flanking
    the core, bare; the Ward Plate stays on the left pauldron and the Entropy Condenser on
    the back as detail (armour and vents take no mount)."""
    # Legs: plantigrade, long, in angular greaves; a heavy sabaton with a toe wedge.
    for s in (-1.0, 1.0):
        cx = s * 12.0
        b.loft([(-12.0, rect(cx, 15.0, 0.0, 6.0)), (4.0, rect(cx, 16.0, 0.0, 8.0)), (18.0, rect(cx, 13.0, 0.0, 3.0))], "steel.plate", "sabaton")
        ankle = (cx, -1.0, 8.0)
        knee = (cx, 5.0, 30.0)
        hip = (cx * 0.8, -3.0, 46.0)
        _beam(b, ankle, knee, _sq(10.0, 11.0), _sq(9.0, 10.0), "steel.panel", "shin")
        b.loft([(2.0, rect(cx, 13.0, 12.0, 26.0)), (9.0, rect(cx, 10.0, 14.0, 24.0))], "steel.plate", "greave")
        b.box(cx - 5.0, cx + 5.0, 6.0, 12.0, 27.0, 34.0, "steel.dark", "knee_cap")
        _spike(b, (cx, 12.0, 31.0), (cx, 20.0, 34.0), 2.0, "steel.dark", "knee_spike")
        _beam(b, knee, hip, _sq(12.0, 13.0), _sq(13.0, 14.0), "steel.panel", "thigh")
        b.loft([(-2.0, rect(cx, 14.0, 34.0, 44.0)), (6.0, rect(cx, 11.0, 36.0, 42.0))], "steel.plate", "cuisse")
    # The pelvis and a faulded skirt of plates.
    b.box(-14.0, 14.0, -8.0, 4.0, 42.0, 52.0, "steel.dark", "pelvis")
    for s in (-1.0, 1.0):
        b.loft([(-6.0, rect(s * 11.0, 10.0, 38.0, 50.0)), (4.0, rect(s * 11.0, 8.0, 40.0, 50.0))], "steel.plate", "fauld")
    # The torso: a waist block flaring to a broad chest of angled plates; the core a round
    # lit disc set in a dark ring at the centre of the chest.
    b.loft([(-8.0, rect(0.0, 26.0, 50.0, 60.0)), (6.0, rect(0.0, 22.0, 50.0, 58.0))], "steel.panel", "waist")
    _rings(b, [[(-16.0, -10.0, 58.0), (16.0, -10.0, 58.0), (14.0, 8.0, 58.0), (-14.0, 8.0, 58.0)],
               [(-26.0, -12.0, 78.0), (26.0, -12.0, 78.0), (20.0, 12.0, 78.0), (-20.0, 12.0, 78.0)]], "steel.plate", "chest")
    b.box(-26.0, 26.0, -12.0, 10.0, 78.0, 82.0, "steel.dark", "collar")
    # The traps: a wedge rising from each shoulder to the neck, Hulk-fashion.
    for s in (-1.0, 1.0):
        _rings(b, [[(s * 26.0, -10.0, 78.0), (s * 26.0, 8.0, 78.0), (s * 26.0, 8.0, 83.0), (s * 26.0, -10.0, 83.0)],
                   [(s * 8.0, -7.0, 82.0), (s * 8.0, 8.0, 82.0), (s * 8.0, 8.0, 90.0), (s * 8.0, -7.0, 90.0)]], "steel.panel", "trapezius")
    for s in (-1.0, 1.0):
        _rings(b, [[(s * 4.0, 10.5, 62.0), (s * 18.0, 9.5, 62.0), (s * 18.0, 9.5, 76.0), (s * 4.0, 10.5, 76.0)],
                   [(s * 4.0, 13.5, 63.0), (s * 15.0, 12.0, 63.0), (s * 15.0, 12.0, 75.0), (s * 4.0, 13.5, 75.0)]], "steel.plate", "pectoral")
    # The core: a ring, the fire behind it, and vent bars across its face so the glow
    # shows between them (Ryan, 30 September).
    b.prism("y", 0.0, 12.0, 69.0, 7.5, 4.0, "steel.dark", 8, "core_ring", phase=math.pi / 8)
    b.prism("y", 0.0, 13.6, 69.0, 5.8, 1.2, "amber.glow", 8, "core_fire", phase=math.pi / 8)   # plain fire, no pattern (Ryan, 1 October)
    for z in (64.4, 67.0, 69.6, 72.2):
        b.box(-5.6, 5.6, 14.2, 15.2, z, z + 1.1, "steel.dark", "core_bar")
    # Two chest ports flanking the core high on the pectoral plates, recessed rings: bare
    # mounts (hp_3 left, hp_4 right).
    for s, n in ((-1.0, 3), (1.0, 4)):
        b.prism("y", s * 12.0, 12.5, 73.0, 3.6, 2.0, "steel.dark", 8, "port_ring", phase=math.pi / 8)
        b.prism("y", s * 12.0, 12.6, 73.0, 2.6, 1.6, "bore.dark", 8, "port_throat", phase=math.pi / 8)
        b.pin("hp_%d" % n, (s * 12.0, 13.5, 73.0))
    # The helm: hooded, low between the shoulders, a visor slit and two horns.
    b.box(-8.0, 8.0, -7.0, 12.0, 82.0, 92.0, "steel.panel", "helm")   # runs back to meet the traps
    b.loft([(-4.0, rect(0.0, 18.0, 90.0, 94.0)), (14.0, rect(0.0, 14.0, 88.0, 92.0))], "steel.plate", "hood")
    b.box(-6.0, 6.0, 12.0, 13.0, 85.0, 87.0, "glass.glass", "visor")
    for s in (-1.0, 1.0):
        _spike(b, (s * 6.0, 2.0, 93.0), (s * 12.0, -2.0, 104.0), 2.2, "steel.dark", "horn")
    # Shoulders: asymmetric. The left a massive slab pauldron with a crown of spikes and
    # the Ward Plate riding on it (hp_3); the right a smaller, angled pauldron.
    L = -1.0
    b.loft([(-14.0, rect(L * 36.0, 20.0, 72.0, 86.0)), (10.0, rect(L * 36.0, 24.0, 70.0, 88.0))], "steel.panel", "pauldron_l")
    for k in range(4):
        y = -10.0 + k * 6.0
        _spike(b, (L * 40.0, y, 88.0), (L * 46.0, y - 2.0, 98.0 - k * 1.5), 2.2, "steel.dark", "pauldron_spike")
    b.box(L * 46.0, L * 28.0, -12.0, 8.0, 88.0, 91.0, "livery.livery2", "ward_plate")   # detail: armour takes no mount
    b.box(L * 44.0, L * 30.0, -10.0, 6.0, 91.0, 92.0, "steel.plate", "ward_inscription")
    b.loft([(-8.0, rect(30.0, 14.0, 74.0, 84.0)), (8.0, rect(30.0, 12.0, 74.0, 82.0))], "steel.plate", "pauldron_r")
    _spike(b, (32.0, 0.0, 84.0), (36.0, -2.0, 92.0), 1.8, "steel.dark", "pauldron_spike_r")
    # The Meteor Artillery behind the right shoulder: two tubes pitched up (hp_2).
    with b.socket("hp_2", (27.0, -14.0, 80.0), forward=(0.0, 0.33, 0.944)):
        b.box(20.0, 34.0, -20.0, -12.0, 64.0, 78.0, "steel.panel", "rack")
        for x in (24.0, 30.0):
            _beam(b, (x, -16.0, 76.0), (x, -9.0, 96.0), _poly(3.2, 6), _poly(3.6, 6), "steel.dark", "meteor_tube")
            _beam(b, (x, -9.0, 96.0), (x, -8.5, 97.5), _poly(3.6, 6), _poly(2.6, 6), "amber.engine", "tube_mouth")
    # Arms: the right heavier. Upper arm down and out, an elbow block, the forearm forward
    # in a vambrace to a fist held out ahead of the hip, knuckles forward and spiked.
    for s in (-1.0, 1.0):
        heavy = s > 0
        shoulder = (s * (32.0 if heavy else 36.0), -1.0, 76.0)
        elbow = (s * (40.0 if heavy else 44.0), -4.0, 52.0)
        wrist = (s * (38.0 if heavy else 42.0), 20.0, 48.0)
        w_up = 12.0 if heavy else 9.0
        w_fo = 14.0 if heavy else 9.5
        jt = b.joint("shoulder_%s" % ("r" if heavy else "l"), shoulder)   # the arm swings from here
        jt.__enter__()
        _beam(b, shoulder, elbow, _sq(w_up, w_up), _sq(w_up - 1.0, w_up - 1.0), "steel.panel", "upper_arm")
        b.box(elbow[0] - 6.5, elbow[0] + 6.5, elbow[1] - 6.0, elbow[1] + 6.0, elbow[2] - 6.0, elbow[2] + 6.0, "steel.dark", "elbow")
        _beam(b, elbow, wrist, _sq(w_fo - 1.0, w_fo - 1.0), _sq(w_fo, w_fo), "steel.plate", "forearm")
        fw = 16.0 if heavy else 13.0
        # The fist upright, thumb on top (Ryan, 30 September: a humanoid's grip, not the
        # Baboon's): built knuckles forward, then turned a quarter about its own forward
        # axis so the thumb side comes up.
        start = len(b.objects)
        _fist(b, wrist[0], wrist[1] - 2.0, wrist[1] + 12.0, wrist[2] - 7.5, wrist[2] + 7.5, fw, -s)
        centre = Vector((wrist[0], wrist[1] + 5.0, wrist[2]))
        turn = Matrix.Translation(centre) @ Matrix.Rotation(s * math.pi / 2.0, 4, "Y") @ Matrix.Translation(-centre)
        for ob in b.objects[start:]:
            ob.matrix_world = turn @ ob.matrix_world
        for k in range(3):   # spiked knuckles, a column down the front of the upright fist
            z = wrist[2] + (k - 1.0) * fw * 0.3
            _spike(b, (wrist[0], wrist[1] + 12.0, z), (wrist[0], wrist[1] + 19.0, z + 1.0), 1.4, "steel.dark", "knuckle_spike")
        if not heavy:
            # Spikes down the outside of the left forearm.
            for k in range(3):
                f = 0.25 + k * 0.25
                px = elbow[0] + (wrist[0] - elbow[0]) * f - 5.0
                py = elbow[1] + (wrist[1] - elbow[1]) * f
                pz = elbow[2] + (wrist[2] - elbow[2]) * f + 5.0
                _spike(b, (px, py, pz), (px - 7.0, py, pz + 5.0), 1.6, "steel.dark", "forearm_spike")
        jt.__exit__(None, None, None)
    # The waist cannon (hp_1): a mount on the right of the waist, the Plasma Carbine
    # forward off it (Ryan, 30 September: on the waist, not the hip).
    b.box(13.0, 23.0, -7.0, 5.0, 51.0, 59.0, "steel.plate", "waist_mount")
    with b.socket("hp_1", (18.0, 5.0, 55.0)):
        b.prism("y", 18.0, 17.0, 55.0, 3.0, 24.0, "steel.dark", 6, "plasma_carbine")
        b.prism("y", 18.0, 29.5, 55.0, 2.2, 1.5, "amber.engine", 6, "carbine_tip")
    # The Entropy Condenser on the lower back, a dark block with lit slots (hp_4).
    b.box(-12.0, 12.0, -20.0, -10.0, 60.0, 74.0, "steel.dark", "condenser")   # detail: a vent takes no mount; up on the back (Ryan, 1 October)
    for z in (64.0, 68.0, 71.5):
        b.box(-9.0, 9.0, -20.8, -20.0, z, z + 1.5, "amber.lit", "condenser_slot")


nemesis.maker = "arsenal"


def ammit(b):
    """The Arsenal "Ammit" (Arsenal Instrument VII): a sinister digitigrade figure with four
    clawed arms, the middle pair a second pair of legs, a low snout of a cockpit. Second pass
    (Ryan, 29 September): the back spines lie flat along the spine; the upper arms rest
    higher and point forward, out of the way; the eyes are long glass strips down the snout,
    cockpit glass; no guns on the arms, shoulder cannons instead; the heel spurs grow from
    the ankle and the rear vent from the pelvis. The four Soulcutter Talons are the four
    clawed hands (fixed, no pins). Mounts: hp_1 the right shoulder cannon (Plasma Carbine),
    hp_2 the left shoulder cannon (Blazethrower), hp_3 and hp_4 two throat ports either
    side of the vent under the jaw, bare (Ryan, 30 September); the Ward Plate on the back
    and the throat vent (the Entropy Condenser, heat exhaled) are detail; the plate lies flat
    on the back's slope with the shoulder cannons on it pointing up the slope, the spines
    rooted in it down its centre (Ryan, 30 September)."""
    OCT = lambda r: _poly(r, 8, math.pi / 8)
    # Legs: digitigrade. Hip high and back, knee forward, ankle back and low, a long foot
    # forward onto two toes; a heel spur growing back out of the ankle joint itself.
    for s in (-1.0, 1.0):
        cx = s * 12.0
        hip = (cx, -14.0, 34.0)
        knee = (cx + s * 2.0, 2.0, 26.0)
        ankle = (cx + s * 2.0, -10.0, 12.0)
        toe = (cx + s * 2.0, 6.0, 2.0)
        b.prism("x", hip[0], hip[1], hip[2], 5.0, 9.0, "steel.dark", 6, "hip")
        _beam(b, hip, knee, _sq(10.0, 10.0), _sq(8.6, 8.6), "steel.plate", "thigh")
        b.prism("x", knee[0], knee[1], knee[2], 4.8, 10.0, "steel.dark", 6, "knee")
        _beam(b, knee, ankle, _sq(8.0, 8.0), _sq(6.8, 6.8), "steel.panel", "shin")
        b.prism("x", ankle[0], ankle[1], ankle[2], 3.8, 9.0, "steel.dark", 6, "ankle")
        _beam(b, ankle, toe, _sq(7.0, 6.0), _sq(8.0, 3.0), "steel.plate", "foot")
        for tx in (-3.0, 3.0):
            _tine(b, (toe[0] + tx, toe[1], toe[2] + 1.0), 0.0, 10.0, -14.0, 9.0, 3.0, 2.4, "steel.dark", "toe", n=2)
        _tine(b, ankle, 0.0, 200.0, 40.0, 9.0, 3.4, 2.6, "steel.dark", "heel_spur", n=2)
    # The pelvis runs back to carry the Entropy Condenser's twin, the exhaust, and the torso
    # leans forward and low above it.
    b.prism("x", 0.0, -12.0, 36.0, 6.5, 26.0, "steel.panel", 8, "pelvis", phase=math.pi / 8)
    b.box(-8.0, 8.0, -24.0, -12.0, 30.0, 40.0, "steel.dark", "tail_block")
    for z in (32.5, 35.5):   # lit slots on its back, the Nemesis's condenser's (Ryan, 1 October)
        b.box(-6.0, 6.0, -24.8, -24.0, z, z + 1.3, "amber.lit", "tail_slot")
    _rings(b, [_deck(26.0, 20.0, -8.0, 38.0, 4.0), _deck(32.0, 24.0, 0.0, 44.0, 5.0),
               _deck(34.0, 24.0, 8.0, 50.0, 5.0), _deck(26.0, 18.0, 14.0, 54.0, 4.0)], "steel.panel", "torso")
    # The snout: a long hexagonal muzzle out of the chest's top, two long glass strips down
    # its top ridges (the cockpit's eyes), a dark tip; under the jaw the Entropy Condenser's
    # throat vent, slotted and lit (hp_4).
    b.loft([(12.0, hexagon(0.0, 50.0, 18.0, 10.0)), (30.0, hexagon(0.0, 49.0, 12.0, 7.0)), (42.0, hexagon(0.0, 48.0, 7.0, 4.0))], "steel.plate", "snout")
    b.loft([(42.0, hexagon(0.0, 48.0, 7.0, 4.0)), (45.0, hexagon(0.0, 48.0, 4.0, 2.0))], "steel.dark", "snout_tip")
    for s in (-1.0, 1.0):
        _rings(b, [[(s * 3.0, 16.0, 54.6), (s * 7.0, 16.0, 52.6), (s * 7.0, 16.0, 53.4), (s * 3.0, 16.0, 55.4)],
                   [(s * 1.5, 38.0, 51.2), (s * 3.5, 38.0, 50.2), (s * 3.5, 38.0, 50.8), (s * 1.5, 38.0, 51.8)]], "glass.glass", "eye_strip")
    b.box(-4.0, 4.0, 20.0, 34.0, 44.0, 45.8, "steel.dark", "throat_vent")
    U = Vector((0.0, 0.766, 0.645))    # up the back's slope
    N = Vector((0.0, -0.645, 0.766))   # out of the back
    for y in (23.0, 27.0, 31.0):
        b.box(-3.0, 3.0, y, y + 1.5, 43.6, 44.2, "amber.strip", "throat_slot")
    # Two throat ports either side of the vent, recessed rings under the jaw, pointing
    # forward and a little down: bare mounts (hp_3 left, hp_4 right).
    for s, n in ((-1.0, 3), (1.0, 4)):
        px = s * 6.5
        _beam(b, (px, 24.0, 47.0), (px, 30.0, 45.0), _poly(3.0, 8), _poly(3.0, 8), "steel.dark", "throat_port")
        _beam(b, (px, 29.0, 45.3), (px, 31.0, 44.7), _poly(2.2, 8), _poly(2.2, 8), "bore.dark", "port_throat")
        b.pin("hp_%d" % n, (px, 30.0, 45.0), forward=(0.0, 0.949, -0.316))
    # The back panel (the Ward Plate, detail): a rectangular plate lying flat on the back's
    # slope from the shoulders to the tail, the shoulder cannons sitting on it and pointing
    # up the slope, so panel and guns lie parallel to the back (Ryan, 30 September).
    P0 = [Vector((-13.0, 1.5, 52.4)), Vector((13.0, 1.5, 52.4)), Vector((13.0, -14.0, 40.0)), Vector((-13.0, -14.0, 40.0))]   # ends below the back's crown (Ryan, 1 October: it poked over the top)
    _rings(b, [P0, [p + N * 2.5 for p in P0]], "livery.livery2", "ward_plate")   # narrower than the torso (Ryan, 1 October)
    I0 = [Vector((-9.0, 0.0, 51.5)), Vector((9.0, 0.0, 51.5)), Vector((9.0, -10.0, 43.5)), Vector((-9.0, -10.0, 43.5))]
    _rings(b, [[p + N * 2.5 for p in I0], [p + N * 3.3 for p in I0]], "steel.plate", "ward_inscription")
    for s in (-1.0, 1.0):
        px = s * 8.5
        base = Vector((px, 0.0, 51.2)) + N * 2.5
        _beam(b, base - U * 2.0, base + U * 8.0, _sq(6.0, 5.0), _sq(6.0, 5.0), "steel.plate", "cannon_mount")
        gun = base + U * 3.0 + N * 5.0
        if s > 0:
            with b.socket("hp_1", tuple(gun), forward=tuple(U)):
                _beam(b, gun, gun + U * 26.0, _poly(2.6, 6), _poly(2.6, 6), "steel.dark", "plasma_carbine")
                _beam(b, gun + U * 26.0, gun + U * 27.5, _poly(2.0, 6), _poly(2.0, 6), "amber.engine", "carbine_tip")
        else:
            with b.socket("hp_2", tuple(gun), forward=tuple(U)):
                _beam(b, gun - U * 8.0, gun + U * 2.0, _poly(3.6, 8), _poly(3.6, 8), "steel.dark", "fuel_tank")
                _beam(b, gun + U * 2.0, gun + U * 19.0, _poly(2.0, 6), _poly(2.0, 6), "steel.dark", "nozzle")
                _beam(b, gun + U * 19.0, gun + U * 20.5, _poly(2.6, 6), _poly(2.6, 6), "amber.engine", "pilot_flame")
    # The spines: a row down the panel's centre line, each rooted in the plate.
    for k in range(5):
        root = Vector((0.0, 0.0, 51.2)) - U * (5.0 * k) + N * 2.0
        _spike(b, tuple(root), tuple(root - U * 5.0 + N * 5.0), 1.6, "steel.dark", "spine")
    # Four arms. The upper pair off the shoulders, held high and forward, forearms angled
    # down and ahead with the talons hanging clear of everything. The middle pair off the
    # lower torso, planted on the ground ahead of the feet, talons splayed.
    for s in (-1.0, 1.0):
        shoulder = (s * 19.0, 6.0, 50.0)
        elbow = (s * 30.0, 22.0, 56.0)
        wrist = (s * 30.0, 38.0, 42.0)
        b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.6, 8.0, "steel.dark", 6, "shoulder")
        with b.joint("shoulder_%s" % ("l" if s < 0 else "r"), shoulder):   # the upper arm swings; the lower pair are legs
            _beam(b, shoulder, elbow, _sq(8.4, 8.4), _sq(7.2, 7.2), "steel.plate", "upper_arm")
            b.prism("x", elbow[0], elbow[1], elbow[2], 4.4, 9.0, "steel.dark", 6, "elbow")
            _beam(b, elbow, wrist, _sq(7.2, 7.2), _sq(6.4, 6.4), "steel.panel", "forearm")
            b.prism("x", wrist[0], wrist[1], wrist[2], 3.2, 8.0, "steel.dark", 6, "wrist")
            for tx in (-3.5, 0.0, 3.5):
                _tine(b, (wrist[0] + tx, wrist[1] + 1.0, wrist[2] - 2.0), 0.0, -60.0, -50.0, 13.0, 3.2, 2.4, "steel.dark", "talon", n=2)
        shoulder = (s * 14.0, 2.0, 40.0)
        elbow = (s * 26.0, 14.0, 26.0)
        wrist = (s * 24.0, 26.0, 6.0)
        b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.4, 8.0, "steel.dark", 6, "lower_shoulder")
        _beam(b, shoulder, elbow, _sq(8.8, 8.8), _sq(7.6, 7.6), "steel.plate", "lower_upper_arm")
        b.prism("x", elbow[0], elbow[1], elbow[2], 4.6, 9.0, "steel.dark", 6, "lower_elbow")
        _beam(b, elbow, wrist, _sq(7.6, 7.6), _sq(6.8, 6.8), "steel.panel", "lower_forearm")
        b.prism("x", wrist[0], wrist[1], wrist[2], 3.4, 8.0, "steel.dark", 6, "lower_wrist")
        for tx in (-4.0, 0.0, 4.0):
            _tine(b, (wrist[0] + tx, wrist[1] + 1.0, wrist[2] - 1.0), 0.0, -30.0 - abs(tx) * 2.0, 20.0, 10.0, 3.2, 2.4, "steel.dark", "talon", n=2)


ammit.maker = "arsenal"


# ---------------------------------------------------------------- the hovercraft (2 October)
# Propulsion reads the maker (Ryan, 2 October): Aphelion's hovers and aircraft are aquatic,
# so the Stingray rides on lift fans sunk flush in its wings and pitches to move; Kestrel
# moves everything on big boosters, so the Puffin is thrust-borne, no skirt and no fan.
# The exposed-rotor fan-copter (the Banshee register) is kept free for a later Aphelion
# flyer; a W&S flyer would be a traditional helicopter profile. Both float: nothing of
# either touches z = 0, the ground.

def _oct(cz, w, h, cx=0.0):
    """An eight-sided section as (x, z) points, `w` across and `h` tall, flat on top: a round
    body or a bell."""
    return [(cx + w / 2 * math.cos(math.pi / 8 + i * math.pi / 4), cz + h / 2 * math.sin(math.pi / 8 + i * math.pi / 4)) for i in range(8)]


def _wing_section(x, y_back, y_front, z_bottom, z_top, shoulder):
    """A flat-topped six-point section in the y-z plane at `x`, for a lofted wing disc: a
    point back and front at mid-height, a plateau `shoulder` in from each end."""
    zm = (z_bottom + z_top) / 2.0
    return [(x, y_back, zm), (x, y_back + shoulder, z_top), (x, y_front - shoulder, z_top),
            (x, y_front, zm), (x, y_front - shoulder, z_bottom), (x, y_back + shoulder, z_bottom)]


def _lift_fan(b, targets, cx, cy, z0, z1, r=8.6, blades=5):
    """A ducted lift fan sunk flush through a wing: a hole cut right through the wing, a
    shallow duct lining its mouth with the rim just proud of the skin, a glow at the duct's
    floor (the downwash, lit) a few units under the rim, a dark hub and wide pitched blades
    just below the mouth. Shallow on purpose: from the hangar's angle a deep duct showed its
    wall and nothing else, so the floor sits at `z1 - 3.5` and the blades over it, and the
    hole below it is open to the underside, never seen from above."""
    b.cut(targets, (cx, cy, z0 - 2.0), (cx, cy, z1 + 2.0), r, 12)
    zfloor = z1 - 3.6
    _tube(b, (cx, cy, zfloor), (cx, cy, z1), r + 0.5, r - 0.8, 12, "steel.dark", "fan_duct", floor_material="amber.glow", floor_depth=0.4)
    zf = z1 - 1.9
    b.prism("z", cx, cy, zf, 2.0, 2.6, "steel.dark", 8, "fan_hub")
    b.prism("z", cx, cy, zf + 1.4, 1.2, 0.6, "steel.plate", 8, "hub_cap")
    ri, ro = 2.0, r - 1.1
    for k in range(blades):
        a = k * 2.0 * math.pi / blades
        di, do = 0.7, 0.3
        il = (cx + ri * math.cos(a - di), cy + ri * math.sin(a - di), zf + 0.5)
        it = (cx + ri * math.cos(a + di), cy + ri * math.sin(a + di), zf - 0.5)
        ot = (cx + ro * math.cos(a + do), cy + ro * math.sin(a + do), zf - 0.9)
        ol = (cx + ro * math.cos(a - do), cy + ro * math.sin(a - do), zf + 0.9)
        _rings(b, [[il, it, ot, ol], [(il[0], il[1], il[2] - 0.45), (it[0], it[1], it[2] - 0.45), (ot[0], ot[1], ot[2] - 0.45), (ol[0], ol[1], ol[2] - 0.45)]], "steel.dark", "fan_blade")


def stingray(b):
    """Aphelion "Stingray" (Perigee Flight 4 Strike Skimmer): the second Aphelion machine, a
    hovercraft that runs hot (Ryan, 2 October; Lionfish and Sea Wasp were the other names).
    A flat lens of a pearl hull: a central body with a slit canopy and one red eye, two
    wing discs lofted out of its flanks, their outer thirds in red (the markings), a ducted
    lift fan sunk flush through each wing where it is thickest, a tail boom flicked up to a
    dark barb with a lit tip (the venom), and the Photosphere Lance (fixed, no pin) under
    the nose where a ray's mouth is. Mounts, in the die's order: hp_1 left shoulder (the
    Solar Flare Array, two pods), hp_2 right shoulder (the Pulse Repeater), hp_3 dorsal on
    a turret joint (the Zenith Emitter), hp_4 right rear wing (the Aurora Lattice, a dish),
    hp_5 bare on the left rear wing (the Radiator Sail is a vent and shows nowhere). Floats:
    the belly at z = 6. Every number is a proportion Ryan may change."""
    # The body: a flattened hexagonal section lofted nose to tail, widest amidships.
    body = b.loft([(44.0, hexagon(0.0, 12.0, 4.0, 3.0)), (36.0, hexagon(0.0, 13.0, 14.0, 9.0)), (20.0, hexagon(0.0, 14.0, 22.0, 16.0)),
                   (0.0, hexagon(0.0, 14.0, 24.0, 18.0)), (-20.0, hexagon(0.0, 14.0, 22.0, 15.0)), (-36.0, hexagon(0.0, 14.5, 14.0, 9.0)),
                   (-44.0, hexagon(0.0, 15.0, 8.0, 5.0))], "steel.plate", "body")
    # The canopy: a glass slit faired into the top of the head, far forward; one red eye
    # at the nose under a brow.
    b.loft([(32.0, hexagon(0.0, 20.0, 5.0, 1.0)), (26.0, hexagon(0.0, 21.0, 10.0, 4.0)), (14.0, hexagon(0.0, 21.5, 10.0, 4.5)), (8.0, hexagon(0.0, 21.0, 8.0, 3.0))], "glass.glass", "canopy")
    b.box(-2.5, 2.5, 38.0, 39.5, 13.5, 16.0, "amber.engine", "eye")
    b.box(-3.5, 3.5, 36.0, 40.0, 16.0, 17.2, "steel.dark", "brow")
    # A red stripe down the spine behind the canopy, and a red chevron on the nose.
    b.box(-1.8, 1.8, -34.0, 6.0, 22.0, 23.0, "livery.livery", "spine_stripe")
    b.box(-5.0, 5.0, 30.0, 34.0, 20.6, 21.4, "livery.livery", "chevron")
    # The wings: two discs lofted out of the flanks, inner in plate, outer in red; a fan
    # sunk through each at the knuckle, where the wing is thickest.
    for s in (-1.0, 1.0):
        root = _wing_section(s * 9.0, -34.0, 38.0, 6.5, 21.5, 16.0)
        knuckle = _wing_section(s * 22.0, -24.0, 30.0, 8.0, 19.0, 12.0)
        tip = _wing_section(s * 36.0, -12.0, 8.0, 12.5, 15.5, 4.0)
        inner = _rings(b, [root, knuckle], "steel.plate", "wing_inner")
        outer = _rings(b, [knuckle, tip], "livery.livery", "wing_outer")
        _lift_fan(b, [inner, outer], s * 23.0, 2.0, 7.5, 20.5)
    # The tail: a boom off the body's tail flicked up, the barb dark and tapering to a lit tip.
    _beam(b, (0.0, -44.0, 15.0), (0.0, -66.0, 20.0), _poly(3.0, 6), _poly(1.6, 6), "steel.plate", "tail_boom")
    b.prism("x", 0.0, -66.0, 20.0, 2.4, 4.0, "steel.dark", 6, "tail_joint")
    _beam(b, (0.0, -66.0, 20.0), (0.0, -80.0, 26.0), _poly(1.8, 4, math.pi / 4), _poly(0.25, 4, math.pi / 4), "steel.dark", "barb")
    b.prism("z", 0.0, -79.0, 25.6, 0.9, 2.2, "amber.lit", 6, "barb_tip")
    # The Photosphere Lance under the nose (fixed, no pin): a long emitter along the keel,
    # a red collar at its root and a lit muzzle.
    b.box(-4.0, 4.0, 10.0, 24.0, 5.5, 9.5, "steel.panel", "lance_mount")
    b.prism("y", 0.0, 32.0, 7.5, 2.6, 36.0, "steel.dark", 6, "lance")
    b.prism("y", 0.0, 22.0, 7.5, 3.1, 4.0, "livery.livery2", 6, "lance_collar")
    b.prism("y", 0.0, 50.5, 7.5, 2.0, 1.4, "amber.engine", 6, "lance_muzzle")
    # The shoulder mounts, forward of the fans either side of the canopy: hp_1 the Solar
    # Flare Array (two flare pods pitched up like mortars), hp_2 the Pulse Repeater.
    for s in (-1.0, 1.0):
        mx = s * 13.0
        b.box(mx - 4.0, mx + 4.0, 14.0, 24.0, 21.0, 23.0, "steel.panel", "shoulder_mount")
        if s < 0:
            with b.socket("hp_1", (mx, 24.0, 23.5), forward=(0.0, 0.819, 0.574)):
                for s2 in (-1.0, 1.0):
                    _beam(b, (mx + s2 * 2.6, 17.0, 23.0), (mx + s2 * 2.6, 27.0, 30.0), _poly(1.7, 6), _poly(1.9, 6), "steel.dark", "flare_pod")
                    b.prism("y", mx + s2 * 2.6, 27.4, 30.3, 1.3, 0.8, "amber.engine", 6, "pod_mouth")
                b.box(mx - 4.5, mx + 4.5, 16.0, 19.0, 23.0, 25.5, "steel.plate", "pod_cradle")
        else:
            with b.socket("hp_2", (mx, 24.0, 23.5)):
                b.box(mx - 2.0, mx + 2.0, 18.0, 25.0, 23.0, 26.0, "steel.plate", "repeater_body")
                b.prism("y", mx, 33.0, 24.5, 1.6, 18.0, "steel.dark", 6, "pulse_repeater")
                b.prism("y", mx, 42.4, 24.5, 1.2, 1.2, "amber.engine", 6, "repeater_tip")
    # The dorsal mount (hp_3) on a turret joint behind the canopy: a gimbal ring and the
    # Zenith Emitter on it.
    b.prism("z", 0.0, -8.0, 23.0, 5.0, 1.2, "steel.dark", 8, "gimbal_ring")
    with b.joint("turret", (0.0, -8.0, 23.6)):
        b.prism("z", 0.0, -8.0, 25.2, 4.0, 3.2, "steel.plate", 8, "gimbal", phase=math.pi / 8)
        with b.socket("hp_3", (0.0, -4.0, 27.5)):
            b.box(-2.6, 2.6, -11.0, -1.0, 26.0, 29.0, "steel.panel", "emitter_body")
            b.prism("y", 0.0, 9.0, 27.5, 2.2, 20.0, "steel.dark", 6, "zenith_emitter")
            b.prism("y", 0.0, 19.6, 27.5, 1.6, 1.4, "amber.engine", 6, "emitter_tip")
    # The rear wing mounts behind the fans: hp_4 the Aurora Lattice (a dish) on the right,
    # hp_5 bare on the left.
    for s in (-1.0, 1.0):
        rx = s * 14.0
        b.box(rx - 3.0, rx + 3.0, -26.0, -18.0, 19.0, 20.5, "steel.panel", "rear_mount")
        if s > 0:
            with b.socket("hp_4", (rx, -18.0, 21.5), scale=0.7):
                b.prism("y", rx, -16.5, 21.5, 0.9, 3.5, "steel.dark", 6, "lattice_mast")
                b.loft([(-14.5, _poly(5.0, 8, math.pi / 8)), (-13.0, _poly(1.8, 8, math.pi / 8))], "steel.plate", "lattice_dish", Matrix.Translation((rx, 0.0, 21.5)))
                b.prism("y", rx, -12.6, 21.5, 1.5, 0.8, "amber.engine", 8, "lattice_core")
        else:
            b.pad("hp_5", (rx, -18.0, 21.0), scale=0.7, size=(6.0, 2.0))


stingray.maker = "aphelion"


def puffin(b):
    """Kestrel "Puffin" (K-11 Mk I Ground-Effect Escort): Kestrel's one machine that touches
    the ground, the escort they thought was very cool and pilots named for the bird (the
    bible's makers row, 28 September; built 2 October). A short deep body in chrome with a
    dark cap over its back, a great faired beak in cobalt banded with light that ends in the
    Prow Projector's emitter (fixed, no pin), a round glass eye each side, stubby wings and
    two canted tail fins (or it is not a Kestrel), two boosters far too big for it slung
    under the wings with their nozzles turned down, and two lit lift nozzles under the
    belly. Mounts, in the die's order: hp_1 under the left wing (the Laser Carbine), hp_2
    under the right (the Deflector, a dish), hp_3 on the back (the Overcharge Coil, a dish),
    hp_4 bare on the tail boom (the Ram-air Scoop is a vent and shows nowhere). Floats on
    its boosters: nothing below z = 4.5."""
    # The body: a round section, short and deep, the nose blunt where the beak begins.
    b.loft([(18.0, _oct(20.0, 14.0, 14.0)), (8.0, _oct(20.0, 26.0, 24.0)), (-4.0, _oct(20.0, 28.0, 26.0)),
            (-16.0, _oct(20.0, 24.0, 22.0)), (-26.0, _oct(21.0, 14.0, 14.0))], "steel.plate", "body")
    # The dark cap over the crown and back (the bird's black), a flattened tube lying on the top.
    b.loft([(6.0, hexagon(0.0, 30.5, 22.0, 6.0)), (-6.0, hexagon(0.0, 31.0, 24.0, 7.0)), (-22.0, hexagon(0.0, 30.0, 16.0, 5.0))], "steel.dark", "cap")
    # The beak: a tall oval lofted forward out of the nose, flat from side to side like a
    # bill and narrowing to its edge, which is the projector's emitter, a tall lit slot
    # (a first pass flared it into a bell, which read as a nozzle); a band of light where
    # a bill is striped.
    b.loft([(16.0, _oct(20.0, 11.0, 22.0)), (26.0, _oct(19.5, 8.0, 19.0)), (34.0, _oct(18.0, 5.5, 14.0)),
            (40.0, _oct(17.5, 4.0, 10.0)), (42.0, _oct(17.5, 3.0, 8.0))], "livery.livery", "beak")
    b.loft([(28.0, _oct(19.2, 8.4, 18.2)), (31.0, _oct(18.8, 7.6, 16.6))], "amber.light", "beak_band")
    b.loft([(42.0, _oct(17.5, 2.6, 7.4)), (42.9, _oct(17.5, 2.0, 6.4))], "amber.engine", "projector_slot")
    # The eyes: a round glass window each side of the head in a dark ring (no open cockpit).
    for s in (-1.0, 1.0):
        b.prism("x", s * 13.4, 10.0, 24.0, 3.9, 1.0, "steel.dark", 8, "eye_ring", phase=math.pi / 8)
        b.prism("x", s * 13.9, 10.0, 24.0, 3.2, 1.0, "glass.glass", 8, "eye", phase=math.pi / 8)
    # Stubby wings off the shoulders, a knife edge forward, drooping a little to the tip; a
    # pylon and a pod under each: hp_1 the Laser Carbine left, hp_2 the Deflector right.
    for s in (-1.0, 1.0):
        root = [(s * 13.0, -14.0, 20.5), (s * 13.0, -14.0, 22.5), (s * 13.0, 2.0, 21.5)]
        tip = [(s * 31.0, -14.0, 18.3), (s * 31.0, -14.0, 19.1), (s * 31.0, -6.0, 18.7)]
        _wing(b, root, tip, "livery.livery", "wing")
        px = s * 24.0
        b.box(px - 1.1, px + 1.1, -11.0, -4.0, 16.8, 19.6, "steel.plate", "pylon")
        with b.socket("hp_%d" % (1 if s < 0 else 2), (px, -2.0, 15.5), scale=0.6):
            b.prism("y", px, -6.0, 15.5, 2.0, 14.0, "steel.dark", 6, "pod")
            if s < 0:
                b.prism("y", px, 6.0, 15.5, 0.9, 12.0, "steel.dark", 6, "laser_carbine")
                b.prism("y", px, 12.4, 15.5, 1.2, 1.0, "steel.plate", 6, "muzzle")
            else:
                b.prism("y", px, 2.5, 15.5, 3.4, 1.2, "steel.plate", 8, "dish")
                b.prism("y", px, 3.4, 15.5, 1.3, 0.8, "amber.engine", 8, "dish_core")
    # The boosters: two six-sided drums far too big for the body, slung under the wings,
    # their mouths dark forward, their nozzles turned down at the back and lit.
    for s in (-1.0, 1.0):
        bx, bz = s * 15.0, 12.0
        b.prism("y", bx, -12.0, bz, 7.5, 34.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.loft([(5.5, hexagon(bx, bz, 13.0, 11.5)), (6.0, hexagon(bx, bz, 11.5, 10.0))], "bore.dark", "booster_mouth")
        b.box(min(s * 8.0, s * 11.0), max(s * 8.0, s * 11.0), -20.0, -2.0, 14.0, 19.0, "steel.plate", "booster_strut")
        _rings(b, [[(bx + 7.5 * math.cos(a), -29.0, bz + 7.5 * math.sin(a)) for a in [math.pi / 6 + i * math.pi / 3 for i in range(6)]],
                   [(bx + 6.6 * math.cos(a), -34.0, bz - 2.0 + 6.6 * math.sin(a)) for a in [math.pi / 6 + i * math.pi / 3 for i in range(6)]]], "steel.plate", "nozzle", cap=False)
        _rings(b, [[(bx + 6.6 * math.cos(a), -34.0, bz - 2.0 + 6.6 * math.sin(a)) for a in [math.pi / 6 + i * math.pi / 3 for i in range(6)]],
                   [(bx + 5.6 * math.cos(a), -34.6, bz - 2.2 + 5.6 * math.sin(a)) for a in [math.pi / 6 + i * math.pi / 3 for i in range(6)]]], "amber.engine", "exhaust")
    # Two lit lift nozzles under the belly: the orange feet.
    for s in (-1.0, 1.0):
        b.prism("z", s * 6.0, 2.0, 6.6, 2.6, 1.6, "amber.engine", 6, "lift_nozzle")
    # The tail: a short boom off the body's rear with two fins canted outward, and the
    # bare fourth mount (hp_4) on top of it.
    b.loft([(-26.0, rect(0.0, 8.0, 24.0, 30.0)), (-38.0, rect(0.0, 4.0, 26.0, 29.5))], "steel.plate", "tail_boom")
    for s in (-1.0, 1.0):
        a = math.radians(s * 40.0)
        root = [(s * 1.5, -38.0, 29.5), (s * 1.5, -28.0, 29.5), (s * 1.5, -28.0, 30.3), (s * 1.5, -38.0, 30.3)]
        tip = [(s * 1.5 + 12.0 * math.sin(a), -40.0, 29.5 + 12.0 * math.cos(a)), (s * 1.5 + 12.0 * math.sin(a), -34.0, 29.5 + 12.0 * math.cos(a)),
               (s * 1.5 + 12.0 * math.sin(a), -34.0, 29.9 + 12.0 * math.cos(a)), (s * 1.5 + 12.0 * math.sin(a), -40.0, 29.9 + 12.0 * math.cos(a))]
        _wing(b, root, tip, "livery.livery", "fin")
    b.pad("hp_4", (0.0, -31.0, 30.5), scale=0.6, size=(4.0, 1.5))
    # The back mount (hp_3) on the cap: a base and the Overcharge Coil's dish facing forward.
    b.box(-2.5, 2.5, -14.0, -8.0, 33.0, 34.6, "steel.panel", "coil_base")
    with b.socket("hp_3", (0.0, -8.0, 35.5), scale=0.6):
        b.prism("y", 0.0, -6.5, 35.5, 0.8, 3.0, "steel.dark", 6, "coil_mast")
        b.prism("y", 0.0, -4.4, 35.5, 3.6, 1.2, "steel.plate", 8, "coil_dish")
        b.prism("y", 0.0, -3.5, 35.5, 1.3, 0.8, "amber.engine", 8, "coil_core")


puffin.maker = "kestrel"


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


def _tube(b, p0, p1, r_out, r_in, n, material, label, floor_material="bore.dark", floor_depth=0.5, floor=True):
    """A hollow cylinder from `p0` to `p1`, open at `p1`: an outer wall, the rim, an inner wall
    down to a dark floor just above `p0`. A recessed gun port: the mount sits on the floor
    and the barrel rises out of the mouth (Ryan, 30 September). `floor=False` leaves both
    ends open, for a rim ring over a port (its floor had been a lid over every port: Ryan,
    1 October)."""
    d = (Vector(p1) - Vector(p0)).normalized()
    up = Vector((0.0, 0.0, 1.0))
    side = Vector((1.0, 0.0, 0.0)) if abs(d.dot(up)) > 0.999 else d.cross(up).normalized()
    over = side.cross(d).normalized()
    def ring(p, r):
        return [Vector(p) + side * (r * math.cos(i * 2.0 * math.pi / n)) + over * (r * math.sin(i * 2.0 * math.pi / n)) for i in range(n)]
    bm = bmesh.new()
    o0 = [bm.verts.new(v) for v in ring(p0, r_out)]
    o1 = [bm.verts.new(v) for v in ring(p1, r_out)]
    i1 = [bm.verts.new(v) for v in ring(p1, r_in)]
    i0 = [bm.verts.new(v) for v in ring(Vector(p0) + d * floor_depth, r_in)]
    for k in range(n):
        k2 = (k + 1) % n
        bm.faces.new([o0[k], o0[k2], o1[k2], o1[k]])
        bm.faces.new([o1[k], o1[k2], i1[k2], i1[k]])
        bm.faces.new([i1[k], i1[k2], i0[k2], i0[k]])
    if floor:
        bm.faces.new(o0)
    ob = b._finish(bm, material, label)
    if not floor:
        return ob
    bm = bmesh.new()
    f0 = [bm.verts.new(v) for v in ring(Vector(p0) + d * (floor_depth + 0.05), r_in * 0.98)]
    bm.faces.new(f0)
    return b._finish(bm, floor_material, label + "_floor")


def _quad(b, pts, material, label, frame=None):
    """One face on its own, from four points in world space, so a block can wear a
    different tile on each side."""
    bm = bmesh.new()
    vs = [bm.verts.new(Vector(p)) for p in pts]
    bm.faces.new(vs)
    return b._finish(bm, material, label, None, frame)


def _fist(b, cx, y_back, y_front, z0, z1, w, inner_side, label="fist"):
    """A closed fist hanging from the wrist, knuckles forward (+y), the back of the hand up
    and the thumb on the inner side (toward the body, `inner_side` is -1 for the right
    hand): a block whose faces each carry one tile of their own (Ryan, 28 September). The
    front wears the fingers; the thumb side, the palm side and the little finger's side
    wear the faces folded out from it (Ryan, 1 October; see Tiles._fist_side); the back of
    the hand and the wrist are plate. Each tile is placed by the hand's own axes, so the
    shared edges meet and the other hand wears its mirror."""
    fwd, back, thumb = Vector((0.0, 1.0, 0.0)), Vector((0.0, 0.0, 1.0)), Vector((float(inner_side), 0.0, 0.0))
    centre = Vector((cx, (y_back + y_front) / 2.0, (z0 + z1) / 2.0))
    half = {"fwd": (y_front - y_back) / 2.0, "back": (z1 - z0) / 2.0, "thumb": w / 2.0}
    axis = {"fwd": fwd, "back": back, "thumb": thumb}
    # (outward, image right, image up, tile) for each face, in the drawn hand's terms.
    faces = [
        ("fwd", "back", "thumb", "steel.fist", "_front"),
        ("thumb", "back", "-fwd", "steel.fisttop", "_thumb"),
        ("-back", "fwd", "thumb", "steel.fistpalm", "_palm"),
        ("-thumb", "back", "fwd", "steel.fistbase", "_base"),
        ("back", "fwd", "thumb", "steel.plate", "_back_of_hand"),
        ("-fwd", "back", "thumb", "steel.plate", "_wrist"),
    ]

    def ax(name):
        return -axis[name[1:]] if name.startswith("-") else axis[name]

    def hx(name):
        return half[name.lstrip("-")]

    for n_name, u_name, v_name, material, suffix in faces:
        n, u, v = ax(n_name), ax(u_name), ax(v_name)
        c = centre + n * hx(n_name)
        hu, hv = hx(u_name), hx(v_name)
        pts = [c - u * hu - v * hv, c + u * hu - v * hv, c + u * hu + v * hv, c - u * hu + v * hv]
        frame = None
        if material != "steel.plate":
            frame = (pts[0], v, u, n, (2.0 * hu, 2.0 * hv))
        if u.cross(v).dot(n) < 0.0:
            pts.reverse()   # the mirrored hand: keep the face turned outward
        _quad(b, [tuple(p) for p in pts], material, label + suffix, frame)


def _fuse(w, top, bottom):
    """A fuselage section: six points, `top` above the centreline and `bottom` below it,
    so the top and belly can taper at different rates."""
    return [(w / 2, 0.0), (w / 4, top), (-w / 4, top), (-w / 2, 0.0), (-w / 4, -bottom), (w / 4, -bottom)]


def _wing(b, root, tip, material, label):
    """A wing as a loft between two sections given in full 3D."""
    return _rings(b, [root, tip], material, label)


def _rings(b, rings, material, label, frame=None, cap=True):
    """A loft through any number of sections given as 3D point rings, capped at both ends
    unless `cap` is False (an annulus or an open tube: a cap would be a disc over the
    hole, which is what hid the Goshawk's muzzle until 1 October). `frame` maps the tiles
    in the part's own axes (see Build._finish)."""
    bm = bmesh.new()
    vs = [[bm.verts.new(p) for p in ring] for ring in rings]
    n = len(vs[0])
    for r0, r1 in zip(vs, vs[1:]):
        for i in range(n):
            try:
                bm.faces.new([r0[i], r0[(i + 1) % n], r1[(i + 1) % n], r1[i]])
            except ValueError:
                pass
    if cap:
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


# ---------------------------------------------------------------- silhouette classes
# What a swapped component wears at a mount (decided 29 September, the rule 30 September:
# hardpoints are gun mounts, a shaped component takes the next mount in the die's order,
# armour and vents show nowhere). The die says what the component is; the model only has
# to look like it could be. Each class is built at the origin along +y (the socket at the
# origin, the business end forward, +z up) at the scale of a 60-unit machine; a pin's own
# scale sizes it to its machine (a Sparrowhawk's pins are half size). Five classes: barrel,
# twin barrel, rack, blade (katar-style), dish (a projector: equipment that can look like a
# gun). `forge.py shapes` builds every class in every maker's metal into
# art/models/shapes/<shape>_<maker>.glb, and MechView3D.mount() hangs one on a pin.

def shape_barrel(b, s=1.0):
    """One gun: a receiver block on the socket, a six-sided barrel, a muzzle collar, a sight."""
    b.box(-4.0 * s, 4.0 * s, -4.0 * s, 6.0 * s, -4.0 * s, 4.0 * s, "steel.panel", "receiver")
    b.prism("y", 0.0, 17.0 * s, 0.0, 2.8 * s, 22.0 * s, "steel.dark", 6, "barrel")
    b.prism("y", 0.0, 29.0 * s, 0.0, 3.3 * s, 2.0 * s, "steel.plate", 6, "muzzle")
    b.box(-1.5 * s, 1.5 * s, 0.0, 4.0 * s, 4.0 * s, 5.5 * s, "amber.light", "sight")


def shape_twin_barrel(b, s=1.0):
    """Two guns side by side off one receiver, a brace between the barrels."""
    b.box(-6.0 * s, 6.0 * s, -4.0 * s, 6.0 * s, -3.5 * s, 3.5 * s, "steel.panel", "receiver")
    for x in (-2.8, 2.8):
        b.prism("y", x * s, 16.0 * s, 0.0, 1.8 * s, 20.0 * s, "steel.dark", 6, "barrel")
        b.prism("y", x * s, 27.0 * s, 0.0, 2.2 * s, 2.0 * s, "steel.plate", 6, "muzzle")
    b.box(-4.0 * s, 4.0 * s, 6.0 * s, 8.0 * s, -1.0 * s, 1.0 * s, "steel.dark", "brace")


def shape_rack(b, s=1.0):
    """A launcher: a box with its tube face forward, exactly one missile tile so the tubes
    read whole, a stripe rail down each side."""
    b.box(-7.0 * s, 7.0 * s, -2.0 * s, 10.8 * s, -7.0 * s, 7.0 * s, "steel.panel", "rack")
    up, right, fwd = Vector((0.0, 0.0, 1.0)), Vector((1.0, 0.0, 0.0)), Vector((0.0, 1.0, 0.0))
    _quad(b, [(-7.0 * s, 11.0 * s, -7.0 * s), (7.0 * s, 11.0 * s, -7.0 * s), (7.0 * s, 11.0 * s, 7.0 * s), (-7.0 * s, 11.0 * s, 7.0 * s)],
          "steel.missile", "rack_face", (Vector((-7.0 * s, 11.0 * s, -7.0 * s)), up, right, fwd, (14.0 * s, 14.0 * s)))
    for x in (-8.0, 7.0):
        b.box(x * s, (x + 1.0) * s, -2.0 * s, 10.0 * s, -7.5 * s, 7.5 * s, "steel.stripe", "rack_rail")


def shape_slab(b, s=1.0):
    """A plate standing across the socket, its face forward, corners chamfered, a livery
    panel on the face."""
    face = _case(16.0 * s, -7.0 * s, 7.0 * s, 3.0 * s)
    b.loft([(0.0, face), (3.0 * s, face)], "steel.plate", "slab")
    panel = _case(12.0 * s, -5.0 * s, 5.0 * s, 2.0 * s)
    b.loft([(3.0 * s, panel), (4.0 * s, panel)], "livery.livery2", "slab_panel")


def shape_vent_block(b, s=1.0):
    """A grille block on the socket with a plate cap and a short stack."""
    b.box(-6.0 * s, 6.0 * s, 0.0, 8.0 * s, -5.0 * s, 5.0 * s, "steel.vent", "vent_block")
    b.box(-6.5 * s, 6.5 * s, 0.0, 8.0 * s, 5.0 * s, 6.0 * s, "steel.plate", "vent_cap")
    b.prism("z", 3.0 * s, 4.0 * s, 9.0 * s, 1.6 * s, 6.0 * s, "steel.dark", 6, "vent_stack")


def shape_dish(b, s=1.0):
    """An emitter: a mast off the socket and a shallow eight-sided dish facing forward, its
    core lit."""
    b.prism("y", 0.0, 2.5 * s, 0.0, 1.2 * s, 5.0 * s, "steel.dark", 6, "dish_mast")
    b.loft([(5.0 * s, _poly(7.0 * s, 8, math.pi / 8)), (7.0 * s, _poly(2.5 * s, 8, math.pi / 8))], "steel.plate", "dish")
    b.prism("y", 0.0, 7.5 * s, 0.0, 2.0 * s, 1.0 * s, "amber.engine", 8, "dish_core")


def shape_blade(b, s=1.0):
    """A melee edge, katar-style (Ryan, 30 September: every blade punches forward, which
    fits the mecha register and lets every mount point the same way): a bracket on the
    socket, a wide flat blade with a spine ridge, tapering to a point."""
    b.box(-5.0 * s, 5.0 * s, -4.0 * s, 1.0 * s, -3.5 * s, 3.5 * s, "steel.panel", "bracket")
    b.loft([(1.0 * s, rect(0.0, 9.0 * s, -1.2 * s, 1.2 * s)), (14.0 * s, rect(0.0, 7.0 * s, -0.9 * s, 0.9 * s)),
            (24.0 * s, rect(0.0, 1.0 * s, -0.3 * s, 0.3 * s))], "steel.dark", "blade")
    b.loft([(1.0 * s, diamond(0.0, 0.0, 2.2 * s, 3.6 * s)), (16.0 * s, diamond(0.0, 0.0, 1.4 * s, 2.4 * s))], "steel.plate", "spine")


## The classes by the name content uses (a component's `shape`; sim/content_db.gd holds the
## same list plus "none"). Slab and vent block are detail helpers now, never mounted: armour
## and vents show nowhere (the rule, 30 September).
SHAPES = {"barrel": shape_barrel, "twin_barrel": shape_twin_barrel, "rack": shape_rack, "blade": shape_blade, "dish": shape_dish}


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

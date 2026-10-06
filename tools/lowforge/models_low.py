"""The units, each from Ryan's brief (21 September), massed in the Descent register: few
facets, every one deliberate. x right, y forward, z up; a mech is about 60 units wide.
Tile names after the dot pick the texture; the role before it is what the engine reads.
Every number here is a proportion Ryan may change; the render is a minute away.
Function names are chassis ids (content/chassis.json), so the build lands where the
engine looks: art/models/<id>.glb.
"""

import math
import os

import bmesh
from mathutils import Matrix, Vector

from bl_low import TILE_WORLD, boom, diamond, hexagon, rect


def badger(b):
    """Minerva "Honey Badger": heavy machinery, mining roots, boxy and indestructible. Treads;
    a low reinforced frame with a raised engine deck; the cockpit tucked into the front of the
    frame under a brow, between two cheeks, so it survives a cave-in; two excavator booms
    pivoting on the frame's flanks at mid-length (not shoulders), reaching forward past the
    cockpit; an outsized claw on the left, the defining feature; the Bullion Fragmenter on the
    right, a sawed-off cannon with a crusher hopper built in (6 October: the Slug Cannon converted to melee and
    locked to the Badger, the second claw gone, so the right boom's mount is no hardpoint and
    the pins run hp_1 missile box, hp_2 left gimbal, hp_3 right gimbal); a missile box on the
    deck; floodlights, vents, a ladder, a hatch."""
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
        # (hp_2); the right's mount is bare (hp_3: the stock's third entry is the
        # Proximity Klaxon, which shows nowhere).
        b.prism("z", cx, -6.0, 54.5, 5.2, 1.0, "steel.dark", 8, "gimbal_ring")
        with b.joint("turret_%s" % ("l" if s < 0 else "r"), (cx, -6.0, 55.0), limits=(-80.0, 80.0)):
            b.prism("z", cx, -6.0, 57.0, 4.4, 4.0, "steel.plate", 8, "gimbal", phase=math.pi / 8)
            if s < 0:
                with b.socket("hp_2", (cx, -6.0, 59.0)):   # on the gimbal's centre (Ryan, 1 October)
                    b.box(cx - 3.0, cx + 3.0, -10.0, -2.0, 58.0, 61.0, "steel.panel", "receiver")
                    for s2 in (-1.0, 1.0):
                        b.prism("y", cx + s2 * 2.4, 11.0, 59.5, 1.8, 26.0, "steel.dark", 6, "autogun")
            else:
                b.pad("hp_3", (cx, -6.0, 60.0), size=(6.0, 1.0))
        start = (hinge_x, -6.0, 40.0)
        # The whole boom hangs under a shoulder joint at the hinge: it swings on a melee
        # blow and idles under power (the joints, decided earlier and on the to-do; built
        # by code 1 October).
        # The joint pass (2 October): an elbow inside each shoulder, and the claw's jaw as
        # two halves on the claw pin, the fingers above and the tines below, opening apart.
        side = "l" if s < 0 else "r"
        # The shoulder lifts only so far before the boom's root rises into the pauldron over it
        # (Ryan, 5 October, the sixth notes); the elbow does the rest, both ways.
        with b.joint("shoulder_%s" % side, start, limits=(-12.0, 18.0)):
            elbow, _ = boom(b, start, 42.0, 6.0, 0.0, ARM, ARM, ARM, ARM, "livery.livery2", "upper_boom")   # straight ahead, no yaw
            b.prism("x", elbow[0], elbow[1], elbow[2], 10.0, ARM + 4.0, "steel.dark", 6, "elbow")
            with b.joint("elbow_%s" % side, elbow, limits=(-50.0, 70.0)):
                wrist, rot = boom(b, elbow, 28.0, 36.0, 0.0, ARM, ARM, ARM, ARM, "steel.plate", "forearm")
                b.prism("x", wrist[0], wrist[1], wrist[2], 9.0, ARM + 8.0, "steel.dark", 6, "wrist")
                # A wrist at the drum (Ryan, 5 October: does it need one? It lets the claw curl
                # like an excavator's bucket, scooping and holding its load level, and the gun
                # sight along its own line): the claw or the mount pitches on the forearm.
                with b.joint("wrist_%s" % side, wrist, limits=(-60.0, 45.0) if kind == "claw" else (-80.0, 40.0)):   # the gun's wide enough to stay level with the boom raised
                    if kind == "claw":
                        # The grapple (Ryan's references, 21 September): an excavator grab made sharp.
                        # Plated cheeks house the pivot; two long curved fingers sweep down and back
                        # from above, two shorter opposing tines curl up from below, interleaved so
                        # they close between each other; every tine tapers to a point.
                        for s2 in (-1.0, 1.0):
                            b.box(wrist[0] + s2 * 13.0 - 1.5, wrist[0] + s2 * 13.0 + 1.5, wrist[1] - 9.0, wrist[1] + 9.0, wrist[2] - 9.0, wrist[2] + 9.0, "steel.panel", "cheek")
                        pin_at = (wrist[0], wrist[1] + 6.0, wrist[2] - 6.0)
                        b.prism("x", pin_at[0], pin_at[1], pin_at[2], 2.2, 30.0, "steel.dark", 6, "pin")
                        with b.joint("jaw_upper", pin_at, limits=(0.0, 45.0)):   # the fingers lift to open
                            for sx in (-9.0, 9.0):
                                _tine(b, wrist, sx, 0.0, -100.0, 32.0, 8.0, 5.5, "steel.dark", "finger")
                        with b.joint("jaw_lower", pin_at, limits=(-45.0, 0.0)):   # the tines drop to open
                            for sx in (-3.0, 3.0):
                                _tine(b, wrist, sx, -95.0, 90.0, 24.0, 7.0, 4.5, "steel.dark", "tine")
                    else:
                        # The Bullion Fragmenter, built in (6 October; Ryan the same day: a sawed-off
                        # cannon, not a breaker, since melee is short range and not contact, and the
                        # joke is that gold and silver are so useless out here that the hopper crushes
                        # them into shot). The breech is a heavy block with a hazard band, the crusher
                        # hopper sits on top with its mouth open upward, and the barrel is short and
                        # wide, sawn off a hand past the breech.
                        wx, wy, wz = wrist
                        b.box(wx - 8.0, wx + 8.0, wy - 6.0, wy + 14.0, wz - 7.0, wz + 7.0, "steel.panel", "breech")
                        b.box(wx - 8.5, wx + 8.5, wy + 2.0, wy + 6.0, wz - 7.5, wz + 7.5, "steel.hazard", "breech_band")
                        b.box(wx - 3.0, wx + 3.0, wy - 5.0, wy - 1.0, wz + 7.0, wz + 9.0, "amber.light", "mount_light")   # the acts' glow track names it
                        b.box(wx - 5.5, wx + 5.5, wy + 0.0, wy + 12.0, wz + 7.0, wz + 15.0, "steel.panel", "hopper")
                        b.box(wx - 4.0, wx + 4.0, wy + 1.5, wy + 10.5, wz + 14.5, wz + 15.2, "steel.dark", "hopper_mouth")
                        b.box(wx - 6.0, wx + 6.0, wy + 12.0, wy + 13.0, wz + 7.0, wz + 15.5, "steel.hazard", "hopper_lip")
                        # The barrel is an open tube (Ryan: the bore inset so it looks hollow): a pale
                        # sawn rim at the muzzle, the bore lined dark five units in, a dark floor.
                        octo = lambda r: [(wx + r * math.cos(math.pi / 8.0 + k * math.pi / 4.0), wz + r * math.sin(math.pi / 8.0 + k * math.pi / 4.0)) for k in range(8)]
                        b.loft([(wy + 14.0, octo(5.8)), (wy + 30.0, octo(5.8))], "steel.dark", "sawn_barrel", cap=False)
                        _rings(b, [[(x, wy + 30.0, z) for x, z in octo(5.8)], [(x, wy + 30.0, z) for x, z in octo(4.4)]], "steel.panel", "muzzle_rim", cap=False)
                        b.loft([(wy + 25.0, octo(4.1)), (wy + 30.0, octo(4.4))], "steel.dark", "bore_lining", cap=False)
                        b.loft([(wy + 24.8, octo(4.1)), (wy + 25.0, octo(4.1))], "steel.dark", "bore_floor")
    # Deck weapon: a missile box on a turret ring, right of centre. Its face is exactly one
    # tile (14 units) square on tile boundaries, so the box projection shows the nine tubes
    # whole rather than a slice of them.
    b.prism("z", 7.0, -13.0, 41.0, 8.0, 2.0, "steel.dark", 8, "ring")
    with b.socket("hp_1", (7.0, -12.0, 49.0)):   # no joint: a missile box there has no business spinning (Ryan, 1 October); hp_1 since 6 October
        b.box(0.0, 14.0, -22.0, -4.0, 42.0, 56.0, "steel.panel", "turret")
        # The tubes on the front alone, one face fitted to the tile (Ryan, 5 October: a slab
        # of missile tile showed the tubes on its edges and back too).
        _missile_face(b, (0.0, -3.95, 42.0), (0.0, 0.0, 1.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), 14.0)

    # Idle acts, third pass (Ryan, 4 October: some stilted, turrets too fast and wild; heavy,
    # with inertia): curves a part runs on through, the servos' heft (b.move), held poses that
    # drift, turrets slow and short with a pause before they turn back (the builder's rule).
    # Degrees and seconds; a key is (t, value) on the joint's own axis or (t, pitch, yaw,
    # roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is
    # (t, k), k the light added over rest.
    b.act("test_claw", 6.4, {   # the boom hoists the claw high on its elbow and it bites twice, turned down and then curled up on its wrist, the gimbals watching
        "shoulder_l": [(1.5, 16.0), (3.4, 17.0), (4.9, 15.0), (6.1, 0.0)],
        "elbow_l": [(1.3, 44.0), (3.4, 48.0), (4.9, 44.0), (6.0, 0.0)],
        "wrist_l": [(1.4, -28.0), (2.7, -30.0), (3.3, 38.0), (4.6, 40.0), (5.9, 0.0)],
        "jaw_upper": [(1.7, 0.0), (2.1, 44.0), (2.35, 44.0), (2.65, 0.0), (3.5, 0.0), (3.9, 44.0), (4.15, 44.0), (4.45, 0.0)],
        "jaw_lower": [(1.7, 0.0), (2.1, -44.0), (2.35, -44.0), (2.65, 0.0), (3.5, 0.0), (3.9, -44.0), (4.15, -44.0), (4.45, 0.0)],
        "turret_l": [(0.4, 0.0), (1.3, 28.0), (4.9, 28.0), (5.9, 0.0)],
        "turret_r": [(0.6, 0.0), (1.5, 28.0), (4.9, 28.0), (5.9, 0.0)],
    }, body=[(1.4, 0.0, 0.0, 0.0, 0.0, 3.0, 2.0), (3.6, 0.0, 0.0, 0.0, 0.0, 3.6, 2.4), (4.9, 0.0, 0.0, 0.0, 0.0, 3.0, 2.0), (6.4, 0.0, 0.0, 0.0)])
    b.act("dig", 6.2, {   # the claw drops open, the wrist turns its tines into the ground, it bites, curls the load up level and hauls it high
        "shoulder_l": [(1.3, -10.0), (2.3, -11.0), (3.7, 16.0), (4.9, 15.0), (6.0, 0.0)],
        "elbow_l": [(1.3, -30.0), (2.3, -32.0), (3.7, 44.0), (4.9, 42.0), (6.0, 0.0)],
        "wrist_l": [(1.1, -45.0), (1.9, -52.0), (2.5, -50.0), (3.2, 40.0), (4.9, 42.0), (6.0, 0.0)],
        "jaw_upper": [(0.9, 44.0), (2.1, 44.0), (2.5, 0.0)],
        "jaw_lower": [(0.9, -44.0), (2.1, -44.0), (2.5, 0.0)],
    }, body=[(1.3, 0.0, 0.0, 0.0, 0.0, -4.0, 0.0), (2.0, 0.0, 0.0, 0.0, 0.0, -4.6, 0.0), (2.4, 0.0, 0.0, -0.4, 0.0, -5.4, 0.0), (3.7, 0.0, 0.0, 0.0, 0.0, 3.0, 0.0),
             (4.9, 0.0, 0.0, 0.0, 0.0, 2.4, 0.0), (6.2, 0.0, 0.0, 0.0)])
    # The gun boom stretched out straight to snipe (Ryan, 6 October, the seventh notes: one
    # line from the hinge through the barrel): the upper boom hangs 6 degrees down and the
    # forearm 36, so the elbow lifts the forearm 30 into the boom's line and the wrist takes
    # the mount 36 back down onto it; the shoulder then raises the whole straight arm, and its
    # small moves are the aim's, the arm staying straight. Held a second, then the shoulder
    # pivots the whole straight arm down onto a new mark and settles (Ryan, 6 October, the
    # eighth notes: as if adjusting its aim).
    b.act("sight_gun", 6.6, {   # the gun boom stretches out straight, holds, pivots down on the shoulder to adjust its aim, the gimbals sighting one way, then the other, the floodlights hot
        "shoulder_r": [(1.3, 15.0), (2.4, 15.5), (3.0, 6.5), (3.25, 7.4), (4.4, 7.0), (5.2, 6.8), (6.4, 0.0)],
        "elbow_r": [(1.3, 30.0), (5.2, 30.0), (6.4, 0.0)],
        "wrist_r": [(1.3, -36.0), (5.2, -36.0), (6.3, 0.0)],
        "turret_l": [(0.6, 0.0), (1.8, -40.0), (2.6, -40.0), (4.4, 20.0), (5.2, 20.0), (5.8, 0.0)],
        "turret_r": [(0.6, 0.0), (1.8, -40.0), (2.6, -40.0), (4.4, 20.0), (5.2, 20.0), (5.8, 0.0)],
    }, body=[(1.8, 0.0, 0.0, 0.0, 6.0, 0.0, 0.0), (2.6, 0.0, 0.0, 0.0, 6.0, 0.0, 0.0), (4.4, 0.0, 0.0, 0.0, -4.0, 0.0, 0.0), (5.2, 0.0, 0.0, 0.0, -4.0, 0.0, 0.0), (6.4, 0.0, 0.0, 0.0)],
       glow=[(["floodlight", "mount_light"], [(0.6, 0.0), (1.2, 6.0), (5.6, 6.0), (6.4, 0.0)])])
    # Both booms raised together (Ryan, 5 October, the fifth notes: flexed in turn, each
    # stroke's down end took the claw through the ground): hoisted high side by side, the
    # claw's jaws gaping at the top and snapping shut, held, and let down slow, the hull
    # rocking back under the weight going up.
    # Raised on the elbows, the shoulders only a little (the sixth notes: they rose into the
    # pauldrons), and the gun held level rather than pointed at the sky.
    b.act("raise_booms", 5.6, {
        "shoulder_l": [(0.4, 0.0), (1.9, 15.0), (2.5, 16.0), (3.7, 17.0), (5.0, 0.0)],
        "elbow_l": [(0.5, 0.0), (1.8, 56.0), (3.7, 60.0), (5.0, 0.0)],
        "wrist_l": [(0.6, 0.0), (1.9, 20.0), (3.7, 22.0), (5.0, 0.0)],
        "shoulder_r": [(0.5, 0.0), (2.0, 15.0), (2.6, 16.0), (3.8, 17.0), (5.1, 0.0)],
        "elbow_r": [(0.6, 0.0), (1.9, 56.0), (3.8, 60.0), (5.1, 0.0)],
        "wrist_r": [(0.7, 0.0), (2.0, -66.0), (3.8, -70.0), (5.1, 0.0)],
        "jaw_upper": [(2.0, 0.0), (2.5, 44.0), (3.1, 44.0), (3.3, 0.0)],
        "jaw_lower": [(2.0, 0.0), (2.5, -44.0), (3.1, -44.0), (3.3, 0.0)],
    }, body=[(0.6, 0.0, 0.0, 0.0), (2.0, 0.0, 0.0, 0.0, 0.0, 2.2, 0.0), (3.3, 0.0, 0.0, 0.0, 0.0, 1.4, 0.0), (3.8, 0.0, 0.0, 0.0, 0.0, 1.8, 0.0), (5.4, 0.0, 0.0, 0.0)],
       glow=[(["floodlight"], [(1.6, 0.0), (2.4, 6.0), (3.8, 6.0), (4.6, 0.0)])])
    # Movement: the treads scroll, the booms carry the claw just clear (Ryan, 5 October: not so
    # high), curled up on its wrist as an excavator carries its bucket, a rock on pulling away
    # and stopping; heavy to start.
    b.gait(treads={"parts": ["tread"], "scroll": 1.0}, hold={"shoulder_l": 7.0, "elbow_l": 6.0, "wrist_l": 24.0, "shoulder_r": 3.0}, rock=7.0)
    b.move(accel=1.2, heft=0.2)

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
    # the boosters; a weapon pod and gun at each tip. The root sits inside the fuselage
    # (Ryan, 6 October, the ninth notes: the wings did not quite meet the fuselage at the
    # front, where it narrows to 7.3 either side of the centreline and the root stood at 8).
    for s in (-1.0, 1.0):
        root = [(s * 6.5, -32.0, -1.0), (s * 6.5, -32.0, 1.4), (s * 6.5, 6.0, 0.2)]
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
        b.loft([(-48.0, hexagon(s * 7.5, -1.0, 11.0, 9.5)), (-48.5, hexagon(s * 7.5, -1.0, 10.0, 8.5))], "amber.exhaust", "exhaust")
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

    # Idle acts, third pass (Ryan, 4 October: the wing dip was bank, hard stop, bank, hard
    # stop; it should feel agile): every move flows into the next through its keys, the light
    # servos (b.move heft) giving a touch of give at each turn, and nothing holds dead still.
    # Degrees and seconds; a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll);
    # a glow key is (t, k), k the light added over rest.
    # The wing dip a barrel roll (Ryan, 5 October, the fifth notes: "since it's cool"; the
    # sixth: quicker, with inertia, and about the fuselage): a dip and a kick the other way to
    # gather, then once round its own length fast, a little past and back, level where it began.
    b.act("barrel_roll", 3.0, body=_barrel_roll(t0=0.35, t1=1.55, over=24.0, duration=3.0),   # once round in a second and a quarter (the seventh notes: slower)
          glow=[(["booster_ring", "exhaust"], [(0.2, 0.0), (0.45, 7.0), (1.6, 7.0), (2.3, 0.0)])])
    # A loop (Ryan, 5 October: the nose dip was the weakest; it needs to do a loop): it backs
    # off, runs in and pulls up through a full circle, over on its back and down, the nose
    # along the path, the boosters hot, and brakes onto its hex a whole turn on, the pose it
    # started in (the rig wraps it). Big, out of its hex and back (the fifth notes: a small
    # one looked awkward); quicker, with a run before it pulls up (the sixth). On the map
    # only: the skirmish's frame has no room for it, nor any reason.
    # Bigger again (the eighth notes: the map has the room), at the same pace round it.
    b.act("loop", 5.2, body=_loop(r=46.0, t0=1.4, t1=4.1, duration=5.2, back=34.0, run=22.0), places=("map",),
          glow=[(["booster_ring", "exhaust"], [(0.6, 0.0), (1.1, 8.0), (4.2, 8.0), (4.9, 0.0)])])
    b.act("flare_boosters", 3.8, body=[(0.5, 0.0, 0.0, 0.0), (1.1, 0.0, 9.0, 0.0, 0.0, -6.0, 0.0), (2.5, 0.0, 12.0, 0.5, 0.0, -7.0, 0.0), (3.8, 0.0, 0.0, 0.0)],
          glow=[(["booster_ring", "exhaust"], [(0.3, 0.0), (0.8, 8.0), (1.2, 4.0), (1.6, 8.0), (2.6, 8.0), (3.4, 0.0)])])
    # A banked circle (Ryan, 5 October, in place of the slow pirouette): wide, out over the next
    # hexes, and on the map only, as the loop (the fifth notes). A circling predator surveying
    # the ground, slow and smooth (the seventh notes). After the eighth (Ryan, 6 October: no
    # right peel if it makes it complicated, just a smooth circle): one true circle,
    # from its hex along its facing and back onto it the same way, the bank steady
    # (_survey_circle).
    # Quicker off the mark and quicker round (the ninth notes), and quicker again (the tenth:
    # about 110 units a second at its fastest, from about 80).
    # To the right (the eleventh notes: so it and the figure eight turn different ways), and
    # from rest to rest at an even rate, where it had slid into its finish.
    circle = _survey_circle()
    b.act("banked_circle", circle[-1][0], body=circle, places=("map",),
          glow=[(["booster_ring", "exhaust"], [(0.2, 0.0), (0.8, 7.0), (circle[-2][0] - 0.6, 6.0), (circle[-1][0] - 0.1, 0.0)])])
    # A figure eight beside it, to judge against the circle (Ryan, 6 October, the ninth notes:
    # "I'd like to see what a figure 8 looks like"; the tenth: a smooth bank change, crossing the
    # hex on a diagonal, larger, quicker): a lobe to the left and one to the right, crossing its
    # hex at speed between them (_figure_eight). Map only.
    eight = _figure_eight()
    mid = round((eight[0][0] + eight[-2][0]) * 0.5, 3)   # the crossing, halfway in time (the pace is symmetric)
    b.act("figure_eight", eight[-1][0], body=eight, places=("map",),
          glow=[(["booster_ring", "exhaust"], [(0.2, 0.0), (0.6, 7.0), (mid - 0.3, 6.0), (mid, 8.0), (mid + 0.3, 6.0), (eight[-2][0] - 0.6, 6.0), (eight[-1][0] - 0.1, 0.0)])])
    # Movement: the boosters brighten, the nose drops; it banks and slides through corners
    # (b.move) at full speed.
    b.gait(glow={"parts": ["booster_ring", "exhaust"], "k": 5.0}, body_hold=(0.0, 0.0, 0.0, 0.0, -6.0, 0.0))
    b.move(slide=0.6, bank=50.0, accel=0.7, heft=0.08, oversteer=0.35)   # strafes most of the aircraft, banks hardest (Ryan, 5 October: more); the lightest in its acts; the nose a little into its corners (the fifth notes: the jets oversteer too, a bit)

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
    # Longer legs (Ryan, 5 October: "it is a horse after all", and the walk wanted them):
    # everything above the legs is built where it always was and raised one whole tile
    # (_Raised), so every seam stays on the world grid; the hips rise with it and the legs
    # take the difference, the shin most.
    H = TILE_WORLD
    raised = _Raised(b, H)
    raised.__enter__()
    # The body: an ironclad casemate, one loft from tail to shoulders with a short taper
    # to the neck. A keel under it, a hitch at the tail.
    b.loft([(-36.0, _case(36.0, 26.0, 46.0, 5.0)), (22.0, _case(36.0, 26.0, 46.0, 5.0)), (30.0, _case(30.0, 27.0, 44.0, 4.0))], "steel.panel", "hull")
    b.box(-10.0, 10.0, -30.0, 18.0, 23.0, 26.0, "steel.dark", "keel")
    b.box(-3.0, 3.0, -42.0, -36.0, 24.0, 28.0, "steel.dark", "hitch")
    # The neck and head: lower than the body, so it reads as an animal and not a tank.
    b.loft([(30.0, rect(0.0, 26.0, 30.0, 44.0)), (36.0, rect(0.0, 22.0, 24.0, 40.0))], "steel.plate", "neck")
    # The head turns and nods on the neck (the joint pass, 2 October: it looks like an
    # AT-AT, without that fidelity); the cheek mounts ride on it with no swivel of their
    # own, so they are built inside its block below.
    head = b.joint("head", (0.0, 36.0, 30.0), axis="yaw", limits={"yaw": (-30.0, 30.0), "pitch": (-10.0, 8.0)})
    head.__enter__()
    b.box(-12.0, 12.0, 36.0, 52.0, 20.0, 38.0, "steel.panel", "head")
    b.box(-13.0, 13.0, 44.0, 53.5, 38.0, 41.5, "steel.plate", "brow")
    b.box(-10.0, 10.0, 52.0, 53.0, 28.0, 34.0, "glass.glass", "visor")
    b.box(-9.0, 9.0, 48.0, 54.0, 20.0, 25.0, "steel.dark", "chin")
    for s in (-1.0, 1.0):
        b.box(min(s * 12.0, s * 13.5), max(s * 12.0, s * 13.5), 44.0, 49.0, 30.0, 35.0, "amber.light", "lamp")
    for s, k in ((-1.0, 7), (1.0, 8)):
        b.box(min(s * 12.0, s * 14.5), max(s * 12.0, s * 14.5), 42.0, 48.0, 22.0, 28.0, "steel.panel", "cheek_bracket")
        b.pin("hp_%d" % k, (s * 14.5, 48.0, 25.0))
    head.__exit__(None, None, None)
    raised.__exit__(None, None, None)
    # The legs: a hip cuff on the flank, a hinge pin, a thigh angling out and (fore pair)
    # forward or (hind pair) back, a knee, a shin straight down into a flared bone skirt
    # and a broad hoof. Nothing hangs below z = 0, the ground.
    # Hip and knee on every leg, fore and aft only (the joint pass, 2 October): the thigh
    # under the hip, the shin under the knee inside it; and an ankle at the shin's foot
    # (Ryan, 4 October, the third pass: more joints if a plod needs them) carrying the
    # feathering and the hoof, so the hoof stays flat to the ground through a stride.
    # The eleventh notes (Ryan, 6 October: the joints looked like a frog's or a lizard's, the
    # hind knee pointing back at mid-height): every knee points forward, as an AT-AT's, and
    # sits two thirds of the way up, a short thigh over a long shin (more calf), each hoof
    # under its hip, so the four legs stand as columns.
    legs = {}
    for yh, fa in ((16.0, "f"), (-24.0, "h")):
        for s in (-1.0, 1.0):
            leg = fa + ("l" if s < 0 else "r")
            hip = (s * 26.0, yh, 37.0 + H)
            knee = (s * 30.0, yh + 4.0, 34.0)
            ankle = (s * 30.0, yh, 6.0)
            b.box(min(s * 18.0, s * 24.0), max(s * 18.0, s * 24.0), yh - 7.0, yh + 7.0, 30.0 + H, 44.0 + H, "steel.panel", "hip")
            b.prism("x", hip[0], hip[1], hip[2], 6.0, 6.0, "steel.dark", 6, "hip_pin")
            legs[leg] = (hip, knee, ankle)
            with b.joint("hip_%s" % leg, hip, limits=(-80.0, 80.0)):   # 70 until the short thighs of the eleventh notes asked the gallop's fold for a hair more
                _beam(b, hip, knee, _sq(11.0, 13.0), _sq(10.0, 11.0), "steel.plate", "thigh")
                b.prism("x", knee[0], knee[1], knee[2], 5.5, 12.0, "steel.dark", 6, "knee")
                with b.joint("knee_%s" % leg, knee, limits=(-115.0, 20.0)):
                    _beam(b, knee, ankle, _sq(9.0, 10.0), _sq(9.0, 9.0), "steel.panel", "shin")
                    with b.joint("ankle_%s" % leg, ankle, limits=(-30.0, 115.0)):
                        _rings(b, [[(ankle[0] + u, ankle[1] + v, 12.0) for u, v in _sq(9.0, 9.0)],
                                   [(ankle[0] + u, ankle[1] + v, 3.0) for u, v in _sq(16.0, 16.0)]], "bone.bone", "feather")
                        b.box(ankle[0] - 7.0, ankle[0] + 7.0, ankle[1] - 8.0, ankle[1] + 8.0, 0.0, 5.0, "steel.dark", "hoof")
    # The bed: a deck plate and low boards round it in the maker's brown, the wagon's own.
    raised = _Raised(b, H)
    raised.__enter__()
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
        with b.joint("turret_%s" % ("l" if s < 0 else "r"), (tx, 12.0, 51.0), limits=(0.0, 110.0) if s < 0 else (-110.0, 0.0)):   # each turret traverses, outward only (the limit holds the view to it)
            b.box(tx - 5.0, tx + 5.0, 7.0, 17.0, 51.0, 61.0, "steel.panel", "turret")
            b.box(tx - 2.0, tx + 2.0, 17.0, 18.0, 58.0, 60.0, "amber.light", "sight")
            with b.socket("hp_%d" % (1 if s < 0 else 2), (tx, 12.0, 58.0)):
                for s2 in (-1.0, 1.0):
                    b.prism("y", tx + s2 * 2.6, 28.0, 58.0, 1.8, 22.0, "steel.dark", 6, "autogun")
    # The lance (hp_3): a breech block aft of centre, saddles along the deck, one long
    # six-sided rail out past the head, a collar, a lit emitter at the point.
    b.box(-5.0, 5.0, -24.0, -6.0, 48.0, 61.0, "steel.panel", "breech")
    b.box(-3.5, 3.5, 6.0, 10.0, 48.0, 54.0, "steel.dark", "saddle")
    with b.joint("lance", (0.0, -15.0, 57.0), limits=(-4.0, 18.0)):   # the lance pivots at the breech: it kicks on a shot, and lifts
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
    with b.joint("turret_mortar", (-13.0, -24.0, 51.0), limits=(0.0, 150.0)):   # outward only, like the turrets
        with b.joint("elev_mortar", (-13.0, -24.0, 53.0), limits=(-12.0, 20.0)):   # the tube's elevation, inside the traverse (the joint pass)
            with b.socket("hp_4", (-13.0, -24.0, 55.0), forward=(0.0, 0.5, 0.866)):   # the same height as the howitzer's mount (Ryan, 1 October)
                _beam(b, (-13.0, -24.0, 51.0), (-13.0, -16.0, 65.0), _poly(4.0, 6), _poly(4.4, 6), "steel.panel", "mortar")
                _beam(b, (-13.0, -16.0, 65.0), (-13.0, -15.0, 66.8), _poly(4.4, 6), _poly(3.2, 6), "steel.dark", "muzzle")
    # The howitzer (hp_5) on the deck's right: a fat short barrel pitched up out of a
    # breech on a ring, the mortar's big brother; a bit further out, and on its gimbal.
    b.prism("z", 12.5, -14.0, 49.5, 6.0, 3.0, "steel.dark", 8, "howitzer_base")
    with b.joint("turret_howitzer", (12.5, -14.0, 51.0), limits=(-150.0, 0.0)):
        with b.joint("elev_howitzer", (12.5, -14.0, 55.0), limits=(-15.0, 20.0)):   # the barrel's elevation at the breech
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
    b.pad("hp_9", (0.0, 26.0, 45.6), size=(8.0, 2.0))   # down onto the hull's crown (Ryan, 1 October)
    raised.__exit__(None, None, None)

    # Idle acts, third pass (Ryan, 4 October: some stilted, turrets too fast and wild, the
    # weight thrown side to side; heavy, with inertia): curves a part runs on through, the
    # servos' heft (b.move), held poses that drift, every gun turning slowly and not far with
    # a pause before it turns back (the builder's rule), and the hooves planted while the
    # body settles over them (_planted). Degrees and seconds; a key is (t, value) on the
    # joint's own axis or (t, pitch, yaw, roll); a body key is (t, dx, dy, dz) or (t, dx, dy,
    # dz, yaw, pitch, roll); a glow key is (t, k), k the light added over rest.
    limb = lambda leg: {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg]}
    b.act("swivel_weapons", 8.4, {   # every gun in sequence: the turrets out, the lance up, the mortar and the howitzer round
        "turret_l": [(0.5, 0.0), (2.3, 60.0), (3.3, 60.0), (5.1, 0.0)],
        "turret_r": [(1.0, 0.0), (2.8, -60.0), (3.8, -60.0), (5.6, 0.0)],
        "lance": [(2.6, 0.0), (3.6, 16.0), (5.2, 17.0), (6.2, 0.0)],
        "turret_mortar": [(3.4, 0.0), (5.4, 65.0), (6.1, 65.0), (8.0, 0.0)],
        "elev_mortar": [(4.4, 0.0), (5.4, 18.0), (6.4, 19.0), (7.4, 0.0)],
        "turret_howitzer": [(3.6, 0.0), (5.6, -65.0), (6.3, -65.0), (8.3, 0.0)],
        "elev_howitzer": [(4.8, 0.0), (5.8, 18.0), (6.6, 19.0), (7.6, 0.0)],
    }, glow=[(["emitter"], [(3.4, 0.0), (4.0, 6.0), (6.6, 6.0), (7.4, 0.0)])])
    b.act("look_around", 6.0, {   # the head sweeps slowly one way, lamps up, then the other, staring
        "head": [(1.4, -6.0, 26.0, 0.0), (2.4, -7.0, 28.0, 0.0), (3.8, 5.0, -26.0, 0.0), (4.7, 6.0, -28.0, 0.0), (5.8, 0.0, 0.0, 0.0)],
    }, glow=[(["lamp"], [(0.4, 0.0), (1.0, 6.0), (5.0, 6.0), (5.8, 0.0)])])
    b.act("stamp", 5.0, {   # the fore-left hoof lifts high and stamps, the body dropping onto it
        "hip_fl": [(0.9, 26.0), (1.8, 28.0), (2.05, 0.0)],
        "knee_fl": [(0.9, -44.0), (1.8, -46.0), (2.05, 0.0)],
        "ankle_fl": [(0.9, 18.0), (1.8, 18.0), (2.05, 0.0)],
        "head": [(0.9, -8.0, 12.0, 0.0), (2.05, 6.0, 0.0, 0.0), (3.4, 0.0, 0.0, 0.0)],
    }, body=[(0.9, 0.0, 0.0, 0.8, 0.0, 2.5, 1.0), (1.8, 0.0, 0.0, 0.9, 0.0, 2.8, 1.1), (2.05, 0.0, 0.0, -1.6, 0.0, -2.0, -0.3), (2.6, 0.0, 0.0, 0.2), (3.4, 0.0, 0.0, 0.0)])
    tracks, body = _planted([limb(leg) for leg in ("fl", "fr", "hl", "hr")],
                            [(1.6, 0.0, -4.0, 0.0), (3.8, 0.0, -4.5, 0.0), (5.4, 0.0, 0.0, 0.0)])
    tracks["head"] = [(1.6, -6.0, 0.0, 0.0), (3.8, -7.0, 0.0, 0.0), (5.4, 0.0, 0.0, 0.0)]
    b.act("settle", 5.8, tracks, body=body)   # the hydraulics let the body down onto its hooves, the head dropping, and heave it up again
    # Movement (Ryan, 4 October, the third pass: stomp and plod, no weight thrown side to
    # side): each hoof planted flat while the body passes over it, then lifted high and
    # stamped down.
    # A heavy trot (Ryan, 6 October, the ninth notes: the gallop has potential but is a bit
    # much, and its hooves met through each other; somewhere between it and the Armadillo's
    # stomp). The gait between the two in a horse, and the namesake's own: diagonal pairs,
    # high-stepping, each fore landing a beat before its hind partner so every pair comes
    # down as a heavy double thud, a moment between pairs with only the swinging hooves
    # under it, the hull dropping and nodding onto each pair. The stances are spread three
    # units fore and aft of the hips and the sweep kept to 22, so a hind hoof reaching
    # forward never comes within 24 of where the fore on its side stands or swings (the
    # hooves are 16 long): nothing of one leg can meet the other. The eleventh notes (on the
    # columnar legs): it rides nearly as tall as its legs reach (`reach` 0.985), barely
    # crouched, so the legs stay nearly straight under it as an AT-AT's, the knees folding
    # only to lift a hoof. A stride of 55, about one and a fifth a second at its map pace.
    tracks, body, stride = _plant([
        {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg],
         "phase": {"fl": 0.0, "hr": 0.05, "fr": 0.5, "hl": 0.55}[leg],
         "shift": legs[leg][0][1] - legs[leg][2][1] + (3.0 if leg[0] == "f" else -3.0),
         "nod": 1.0 if leg[0] == "f" else -0.5}
        for leg in ("fl", "fr", "hl", "hr")], sweep=22.0, duty=0.4, lift=12.0, crouch=0.3, dip=1.4, nod=1.2, reach=0.985, airborne=0.99, smooth=0.03, n=120)
    tracks["head"] = ([(i / 40.0, round(-1.8 * abs(math.sin(2.0 * math.pi * (i / 40.0 - 0.04))), 3)) for i in range(41)], 0.0)   # a nod onto each pair
    b.gait(stride=stride, tracks=tracks, body=body, ease="linear")
    # The eighth notes' gallop, kept as an option for the hangar's Walk to set beside the
    # trot (Ryan: it has potential), its stances spread as the trot's and its sweep cut from
    # 42 to 30 so its hooves pass clear of each other too (they met by two and a half;
    # now a unit clear at the closest, measured): a transverse gallop, hind left, hind
    # right, fore left, fore right, then a moment gathered off the ground, the hull rocking
    # nose up onto the hinds and down over the fores (_gallop).
    tracks, body, stride = _gallop([
        {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg],
         "phase": {"hl": 0.0, "hr": 0.12, "fl": 0.42, "fr": 0.54}[leg],
         "shift": legs[leg][0][1] - legs[leg][2][1] + (3.0 if leg[0] == "f" else -3.0)}
        for leg in ("fl", "fr", "hl", "hr")], sweep=30.0, duty=0.34, lift=10.0, crouch=1.0, hop=3.0, rock=4.0, dip=2.0)   # lift 13 until the long shins of the eleventh notes
    tracks["head"] = ([(i / 40.0, round(-2.5 * math.cos(2.0 * math.pi * (i / 40.0 - 0.1)), 3)) for i in range(41)], 0.0)   # the head lags the rock, steadying it
    b.gait_option("gallop", stride=stride, tracks=tracks, body=body, ease="linear")
    b.move(accel=1.4, heft=0.24)

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
    # Hip, knee and ankle on both legs (the joint pass, 2 October), each inside the last.
    legs, arms = {}, {}
    for s in (-1.0, 1.0):
        cx = s * 13.0
        side = "l" if s < 0 else "r"
        ankle = (cx, -1.0, 8.0)
        knee = (cx, 8.0, 19.0)
        hip = (cx * 0.85, -4.0, 25.0)
        legs[side] = (hip, knee, ankle)
        b.prism("x", hip[0], hip[1], hip[2], 5.4, 8.0, "steel.dark", 6, "hip")
        with b.joint("hip_%s" % side, hip, limits=(-60.0, 60.0)):
            _beam(b, knee, hip, OCT(5.8), OCT(6.2), "steel.plate", "thigh")
            b.prism("x", knee[0], knee[1], knee[2], 5.4, 12.0, "steel.dark", 6, "knee")
            with b.joint("knee_%s" % side, knee, limits=(-60.0, 50.0)):
                _beam(b, ankle, knee, OCT(5.4), OCT(4.8), "steel.panel", "shin")
                b.box(cx - 5.0, cx + 5.0, 12.5, 15.5, 14.5, 23.5, "livery.livery2", "knee_pad")   # on the knee, not hung under it (Ryan, 30 September)
                b.prism("x", ankle[0], ankle[1], ankle[2], 4.4, 13.0, "steel.dark", 6, "ankle")
                with b.joint("ankle_%s" % side, ankle, limits=(-70.0, 70.0)):
                    b.loft([(-13.0, rect(cx, 15.0, 0.0, 7.0)), (2.0, rect(cx, 17.0, 0.0, 8.5)), (17.0, rect(cx, 15.0, 0.0, 4.0))], "steel.plate", "foot")
                    b.box(cx - 8.0, cx + 8.0, 14.0, 18.0, 0.0, 3.0, "steel.dark", "toe_cap")
    # The waist: a drum.
    b.prism("x", 0.0, -4.0, 32.0 + Z0, 6.5, 32.0, "steel.panel", 8, "pelvis", phase=math.pi / 8)
    # The waist (Ryan, 5 October, asking whether a neck would liven its acts: the sensor pod
    # is small and low, so a neck would hardly read; a torso twist and lean over the legs is
    # the MechWarrior signature and moves the arms, the projectors and the backpack with it).
    # Everything above the pelvis drum hangs under it; the cockpit stays fixed to the torso.
    waist = b.joint("waist", (0.0, -4.0, 32.0 + Z0), axis="yaw", limits={"yaw": (-45.0, 45.0), "pitch": (-20.0, 25.0), "roll": (-12.0, 12.0)}, swing=False)
    waist.__enter__()
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
        side = "l" if s < 0 else "r"
        with b.joint("elev_%s" % side, (px, 2.0, 63.0 + Z0), limits=(-6.0, 50.0)):   # the projector elevates on its mount
            with b.socket("hp_%d" % (1 if s < 0 else 2), (px, 16.0, 63.0 + Z0)):
                b.prism("y", px, 12.0, 63.0 + Z0, 3.2, 20.0, "steel.dark", 6, "umbra_projector")
                b.prism("y", px, 23.0, 63.0 + Z0, 2.2, 3.0, "amber.engine", 6, "emitter")
        # The arm: the elbow back and out behind the shoulder, the forearm forward and
        # down to a wrist drum, the fist hanging from it to rest on the ground, knuckles
        # forward (Ryan, 30 September: back on the ground, and loaded).
        shoulder = (s * 31.0, 0.0, 54.0 + Z0)
        elbow = (s * 40.0, -12.0, 34.0)
        wrist = (s * 38.0, 4.0, 16.5)   # the fist's sole at z = 0
        arms[side] = (shoulder, elbow, wrist)
        b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.5, 8.0, "steel.dark", 6, "shoulder_joint")
        jt = b.joint("shoulder_%s" % side, shoulder, limits={"pitch": (-45.0, 60.0), "yaw": (-30.0, 30.0)})   # the arm swings from here
        jt.__enter__()
        _beam(b, shoulder, elbow, OCT(5.2), OCT(4.6), "steel.plate", "upper_arm")
        b.prism("x", elbow[0], elbow[1], elbow[2], 5.5, 12.0, "steel.dark", 6, "elbow")
        el = b.joint("elbow_%s" % side, elbow, limits=(-70.0, 45.0))   # the forearm bends here (the joint pass); up is what lifts the fist
        el.__enter__()
        _beam(b, elbow, wrist, OCT(4.6), OCT(5.0), "steel.panel", "forearm")
        band0 = tuple(elbow[i] + (wrist[i] - elbow[i]) * 0.3 for i in range(3))
        band1 = tuple(elbow[i] + (wrist[i] - elbow[i]) * 0.5 for i in range(3))
        _beam(b, band0, band1, OCT(5.3), OCT(5.3), "livery.livery2", "forearm_band")
        b.prism("x", wrist[0], wrist[1], wrist[2], 4.6, 13.0, "steel.dark", 6, "wrist")
        # A wrist at the drum (Ryan, 5 October: it definitely needs them): the fist and its
        # mounts pitch on the forearm, so a planted fist stays flat on its knuckles and a
        # raised one turns over.
        wr = b.joint("wrist_%s" % side, wrist, limits=(-60.0, 60.0))
        wr.__enter__()
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
        wr.__exit__(None, None, None)
        el.__exit__(None, None, None)
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
    waist.__exit__(None, None, None)

    # Idle acts, third pass (Ryan, 4 October: some stilted; heavy, with inertia): curves a
    # part runs on through, the servos' heft (b.move), held poses that drift, and the feet
    # planted while the body rises over them (_planted). Degrees and seconds; a key is (t,
    # value) on the joint's own axis or (t, pitch, yaw, roll); a body key is (t, dx, dy, dz)
    # or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k), k the light added over rest.
    # Fourth pass (Ryan, 5 October: its acts a bit lame; it needs wrists): the waist turns and
    # leans the whole upper body over the legs, the MechWarrior torso twist, and the wrists
    # turn the fists.
    b.act("scan", 6.4, {   # the torso turns hard one way on its waist, the eye hot, waits, swings across to the other, waits, and comes back; the fists lift clear and swing with it
        "waist": [(1.3, -6.0, 38.0, 0.0), (2.1, -7.0, 40.0, 0.0), (3.9, -6.0, -38.0, 0.0), (4.7, -7.0, -40.0, 0.0), (5.9, 0.0, 0.0, 0.0)],
        "shoulder_l": [(0.8, 14.0), (5.6, 14.0), (6.2, 0.0)],
        "shoulder_r": [(0.8, 14.0), (5.6, 14.0), (6.2, 0.0)],
        "elbow_l": [(0.8, 12.0), (5.6, 12.0), (6.2, 0.0)],
        "elbow_r": [(0.8, 12.0), (5.6, 12.0), (6.2, 0.0)],
        "wrist_l": [(0.8, -20.0), (5.6, -20.0), (6.2, 0.0)],
        "wrist_r": [(0.8, -20.0), (5.6, -20.0), (6.2, 0.0)],
    }, glow=[(["eye"], [(0.6, 0.0), (1.2, 7.0), (5.4, 7.0), (6.0, 0.0)])])
    b.act("inspect_fist", 6.0, {   # the torso turns to the left fist as it comes up before the eye, and the wrist turns it over, inspected
        "waist": [(1.4, -8.0, 20.0, 0.0), (4.2, -9.0, 22.0, 0.0), (5.6, 0.0, 0.0, 0.0)],
        "shoulder_l": [(1.4, 56.0, -26.0, 0.0), (2.3, 56.0, -26.0, -30.0), (3.3, 56.0, -26.0, 30.0), (4.2, 57.0, -24.0, 0.0), (5.6, 0.0, 0.0, 0.0)],
        "elbow_l": [(1.4, 43.0), (4.2, 45.0), (5.6, 0.0)],
        "wrist_l": [(1.5, 0.0), (2.3, -45.0), (3.3, 50.0), (4.0, 10.0), (5.4, 0.0)],
        "shoulder_r": [(1.0, 12.0), (5.0, 12.0), (5.8, 0.0)],
        "elbow_r": [(1.0, 10.0), (5.0, 10.0), (5.8, 0.0)],
        "wrist_r": [(1.0, -18.0), (5.0, -18.0), (5.8, 0.0)],
    }, glow=[(["eye"], [(1.6, 0.0), (2.2, 6.0), (3.8, 6.0), (4.4, 0.0)])])
    # Refined, not crude (Ryan, 5 October, the fifth notes: an Aphelion pilot is too
    # cerebral for a chest beat or a ground pound; the scan light on inspect_fist works): a
    # systems check, each projector stepped up through its range in exact increments with a
    # pause and a test pulse at every mark, the torso turning to the one under test, crisp on
    # its own quicker servos; and a target marked, the torso turning smoothly to it and the
    # left fist raised and levelled at it while the eye holds it and the rack sends twice.
    ticks = [0.8, 1.4, 2.0, 3.0, 3.6, 4.2]
    b.act("calibrate", 6.2, {
        "elev_l": [(0.6, 0.0), (0.8, 12.0), (1.2, 12.0), (1.4, 24.0), (1.8, 24.0), (2.0, 36.0), (2.6, 36.0), (3.3, 0.0)],
        "elev_r": [(2.8, 0.0), (3.0, 12.0), (3.4, 12.0), (3.6, 24.0), (4.0, 24.0), (4.2, 36.0), (4.8, 36.0), (5.5, 0.0)],
        "waist": [(0.5, -2.0, 0.0, 0.0), (0.8, -2.0, 6.0, 0.0), (1.4, -2.0, 10.0, 0.0), (2.0, -2.0, 14.0, 0.0), (2.6, -2.0, 14.0, 0.0), (3.0, -2.0, -6.0, 0.0),
                  (3.6, -2.0, -10.0, 0.0), (4.2, -2.0, -14.0, 0.0), (4.8, -2.0, -14.0, 0.0), (5.8, 0.0, 0.0, 0.0)],
        "shoulder_l": [(0.6, 10.0), (5.4, 10.0), (6.0, 0.0)],
        "shoulder_r": [(0.6, 10.0), (5.4, 10.0), (6.0, 0.0)],
        "wrist_l": [(0.6, -12.0), (5.4, -12.0), (6.0, 0.0)],
        "wrist_r": [(0.6, -12.0), (5.4, -12.0), (6.0, 0.0)],
    }, heft=0.08, glow=[(["emitter", "eye"], [(0.5, 0.0)] + [(t + d, k) for t in ticks for d, k in ((-0.02, 0.0), (0.06, 9.0), (0.3, 0.0))] + [(5.0, 0.0)])])
    # The right fist marks the target (Ryan, 5 October, the sixth notes: inspect_fist already
    # raises the left), the torso turning right to it; the fist comes up palm out, then the
    # wrist turns it down so its projector prongs lock on the mark before the rack sends (the
    # seventh notes: it only showed the enemy its palm).
    b.act("mark_target", 5.2, {
        "waist": [(1.1, -4.0, -24.0, 0.0), (3.7, -4.0, -25.0, 0.0), (4.7, 0.0, 0.0, 0.0)],
        "shoulder_r": [(1.2, 42.0, 10.0, 0.0), (3.6, 43.0, 10.0, 0.0), (4.6, 0.0, 0.0, 0.0)],
        "elbow_r": [(1.2, 30.0), (3.6, 31.0), (4.6, 0.0)],
        "wrist_r": [(1.2, 18.0), (1.45, 18.0), (1.8, -52.0), (3.6, -54.0), (4.6, 0.0)],
        "shoulder_l": [(1.0, 10.0), (4.0, 10.0), (4.8, 0.0)],
        "wrist_l": [(1.0, -12.0), (4.0, -12.0), (4.8, 0.0)],
    }, glow=[(["eye"], [(1.2, 0.0), (1.6, 7.0), (3.4, 7.0), (4.0, 0.0)]),
             (["rack_port"], [(2.0, 0.0), (2.1, 9.0), (2.4, 1.0), (2.6, 9.0), (2.9, 0.0)])])
    b.act("charge_projectors", 6.0, {   # the torso leans back and sweeps on its waist while the projectors raise and the emitters charge hot
        "waist": [(1.0, 8.0, 0.0, 0.0), (2.2, 9.0, 18.0, 0.0), (2.9, 9.0, 18.0, 0.0), (4.3, 9.0, -18.0, 0.0), (4.9, 8.0, -18.0, 0.0), (5.8, 0.0, 0.0, 0.0)],
        "elev_l": [(1.0, 48.0), (4.4, 49.0), (5.4, 0.0)],
        "elev_r": [(1.4, 48.0), (4.6, 49.0), (5.6, 0.0)],
        "shoulder_l": [(0.8, 10.0), (5.4, 10.0), (6.0, 0.0)],
        "shoulder_r": [(0.8, 10.0), (5.4, 10.0), (6.0, 0.0)],
        "wrist_l": [(0.8, -14.0), (5.4, -14.0), (6.0, 0.0)],
        "wrist_r": [(0.8, -14.0), (5.4, -14.0), (6.0, 0.0)],
    }, glow=[(["emitter", "hp_5", "hp_3", "hp_4"], [(0.6, 0.0), (1.6, 4.0), (2.2, 8.0), (2.6, 4.0), (3.0, 8.0), (4.4, 8.0), (5.2, 0.0)])])
    # Movement (Ryan, 4 October, the third pass: stomp and plod, no weight thrown side to
    # side): a heavy knuckle-walk, every foot and fist planted while the body passes over it,
    # the left fist with the right foot; the fists flat on their knuckles through each stance
    # on the wrists (Ryan, 5 October); the body dropping and nodding as each pair lands.
    limbs = []
    for side, other in (("l", "r"), ("r", "l")):
        limbs.append({"hip": "hip_" + side, "knee": "knee_" + side, "ankle": "ankle_" + side, "at": legs[side],
                      "phase": 0.0 if side == "l" else 0.5})
        limbs.append({"hip": "shoulder_" + side, "knee": "elbow_" + side, "ankle": "wrist_" + side, "at": arms[side],
                      "phase": 0.0 if side == "r" else 0.5})
    tracks, body, stride = _plant(limbs, sweep=26.0, lift=6.0, crouch=0.5, dip=1.2, nod=1.0)
    b.gait(stride=stride, tracks=tracks, body=body, ease="linear")
    b.move(accel=1.1, heft=0.2)

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
    # Hip and knee on every leg (the joint pass, 2 October), and an ankle carrying the foot
    # flat through a stride (Ryan, 4 October, the third pass).
    legs = {}
    for yh in (22.0, -26.0):
        for s in (-1.0, 1.0):
            leg = ("f" if yh > 0 else "h") + ("l" if s < 0 else "r")
            b.box(min(s * 24.0, s * 34.0), max(s * 24.0, s * 34.0), yh - 8.0, yh + 8.0, Z0 + 2.0, Z0 + 18.0, "steel.panel", "hip_cuff")
            hip = (s * 34.0, yh, Z0 + 10.0)
            knee = (s * 44.0, yh + (4.0 if yh > 0 else -4.0), 18.0)
            ankle = (s * 42.0, yh + (6.0 if yh > 0 else -6.0), 6.0)
            b.prism("x", hip[0], hip[1], hip[2], 6.5, 8.0, "steel.dark", 6, "hip_pin")
            legs[leg] = (hip, knee, ankle)
            fore = yh > 0
            with b.joint("hip_%s" % leg, hip, limits=(-60.0, 60.0)):
                _beam(b, hip, knee, _sq(13.0, 14.0), _sq(11.0, 12.0), "steel.plate", "thigh")
                b.prism("x", knee[0], knee[1], knee[2], 6.0, 13.0, "steel.dark", 6, "knee")
                with b.joint("knee_%s" % leg, knee, limits=(-115.0, 30.0) if fore else (-30.0, 115.0)):
                    _beam(b, knee, ankle, _sq(10.0, 11.0), _sq(10.0, 10.0), "steel.panel", "shin")
                    with b.joint("ankle_%s" % leg, ankle, limits=(-40.0, 115.0) if fore else (-115.0, 40.0)):
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
        # Each port gun elevates in its port (the joint pass, 2 October): a pitch joint at
        # the mount, the socket inside it.
        with b.joint("elev_%s" % ("l" if s < 0 else "r"), tuple(mount), limits=(-12.0, 28.0)):
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
    # A square channel through the shell along the cell's own line, the cell sliding and
    # tilting in it (Ryan, 5 October, the sixth notes: lifted, the cell slid through the top
    # panel, so the mount wants a cutout): cut through both bands it crosses, long enough for
    # the cell's whole slide, its walls the shell's own; the stripe frame a hollow sleeve over
    # its lower part, floored dark deep in the shell.
    HB, DV, R2 = Vector((0.0, -34.0, Z0 + 20.0)), Vector(D), math.sqrt(2.0)
    b.cut(band_obs, tuple(HB + DV * 0.5), tuple(HB + DV * 20.0), 7.4 * R2, sides=4, phase=math.pi / 4)
    _tube(b, tuple(HB + DV * 0.5), tuple(HB + DV * 11.3), 8.5 * R2, 7.4 * R2, 4, "steel.stripe", "hatch_frame", floor_depth=0.3, phase=math.pi / 4)
    with b.joint("elev_cell", (0.0, -32.0, Z0 + 22.0), limits=(-4.0, 28.0)):   # the cell tilts up and back on its hatch
        with b.socket("hp_3", (0.0, -26.0, Z0 + 28.0), forward=D, scale=1.2):
            # The tubes on the cell's face alone (Ryan, 5 October: the missile tile showed on
            # every side once the cell lifted out): a panel body and one face, the tile fitted
            # to it whole.
            _beam(b, (0.0, -32.0, Z0 + 22.0), (0.0, -24.5, Z0 + 29.5), _sq(13.0, 13.0), _sq(13.0, 13.0), "steel.panel", "missile_cell")
            UP, RT = Vector((0.0, -0.7071, 0.7071)), Vector((1.0, 0.0, 0.0))
            _missile_face(b, Vector((0.0, -24.5, Z0 + 29.5)) + DV * 0.05 - RT * 6.5 - UP * 6.5, UP, RT, DV, 13.0)
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

    # Idle acts, third pass (Ryan, 4 October: some stilted, the weight thrown side to side;
    # heavy, with inertia): curves a part runs on through, the servos' heft (b.move), held
    # poses that drift, and the feet planted while the shell tips over them (_planted).
    # Degrees and seconds; a key is (t, value) on the joint's own axis or (t, pitch, yaw,
    # roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is
    # (t, k), k the light added over rest.
    limb = lambda leg: {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg]}
    # The missile cell rises along its own line before it tilts (Ryan, 5 October: it cut
    # through the stripes), and sinks back after; but its base stays inside the frame, even
    # at the tilt's far corner (Ryan, 5 October, the fifth notes: lifted eleven, it left its
    # housing whole and floated).
    CELL = (0.0, 3.9, 3.9)   # five and a half units up the cell's line
    cell = lambda t0, t1, t2, t3: [(t0, 0.0), (t0 + 0.5, 0.0, 0.0, 0.0) + CELL, (t1, 22.0, 0.0, 0.0) + CELL, (t2, 21.0, 0.0, 0.0) + CELL,
                                   (t3 - 0.5, 0.0, 0.0, 0.0) + CELL, (t3, 0.0)]
    # Present the guns as a sumo does (Ryan, 5 October): a forefoot lifts and steps out wide,
    # then the other, the shell's front sinking between them, and every back gun comes up
    # to bear; then up, and the feet step back in, one and then the other. Each foot stays
    # flat (the hips roll out and the ankles under them: _stance).
    WIDE, LIFT = 7.0, 9.0
    B0, B1, B2, B3, B4 = (0.0, 0.0, 0.0), (0.0, -3.0, -3.0), (0.0, -5.0, -6.0), (0.0, -7.0, -9.0), (0.0, -7.4, -9.6)
    B5 = (0.0, -2.6, -2.6)
    mid = lambda a, b, u: tuple(a[i] + (b[i] - a[i]) * u for i in range(3))

    def step(t0, t1, leg, a, c, ba, bb):
        """A forefoot lifted from `a` units out to `c` units out over t0..t1, the body from ba to bb."""
        x0 = legs[leg][2]
        out = -1.0 if leg.endswith("l") else 1.0
        pa, pc = (x0[0] + out * a, x0[1], x0[2]), (x0[0] + out * c, x0[1], x0[2])
        return [(t0 + (t1 - t0) * 0.3, mid(ba, bb, 0.3), {leg: (pa[0] + (pc[0] - pa[0]) * 0.15, pa[1], pa[2] + LIFT * 0.8)}),
                (t0 + (t1 - t0) * 0.6, mid(ba, bb, 0.6), {leg: (pa[0] + (pc[0] - pa[0]) * 0.7, pa[1], pa[2] + LIFT)}),
                (t0 + (t1 - t0) * 0.85, mid(ba, bb, 0.85), {leg: (pc[0], pc[1], pc[2] + LIFT * 0.45)}),
                (t1, bb, {leg: pc})]
    frames = [(0.3, B0, {})] + step(0.3, 1.2, "fl", 0.0, WIDE, B0, B1) + step(1.3, 2.2, "fr", 0.0, WIDE, B1, B2)
    frames += [(2.65, mid(B2, B3, 0.4), {}), (3.0, mid(B2, B3, 0.8), {}), (3.3, B3, {}), (4.8, B4, {}), (5.6, mid(B4, B3, 0.5), {}),
               (5.9, B3, {}), (6.3, mid(B3, B1, 0.5), {}), (6.8, B1, {})]
    frames += step(6.9, 7.7, "fr", WIDE, 0.0, B1, B5) + step(7.8, 8.6, "fl", WIDE, 0.0, B5, B0)
    tracks, body = _stance(legs, [(round(t, 3), pose, feet) for t, pose, feet in frames])
    tracks.update({
        "elev_l": [(3.2, 0.0), (4.0, 28.0), (5.4, 27.0), (6.2, 0.0)],
        "elev_r": [(3.4, 0.0), (4.2, 28.0), (5.4, 27.0), (6.2, 0.0)],
        "elev_cell": cell(3.1, 4.4, 5.4, 6.6),
    })
    b.act("present_guns", 8.8, tracks, body=body,
          glow=[(["lamp"], [(3.2, 0.0), (3.8, 8.0), (5.6, 8.0), (6.2, 0.0)])])   # the cowl lamps burn: the guns are up
    # Crouch (Ryan, 5 October: the knee bend of the old present_guns as an act of its own):
    # it sinks low and level on its planted feet, settles, and stands.
    tracks, body = _planted([limb(leg) for leg in ("fl", "fr", "hl", "hr")],
                            [(1.4, 0.0, -8.0, -0.6), (2.0, 0.0, -8.6, -0.8), (3.8, 0.0, -9.0, -0.8), (5.0, 0.0, 0.0, 0.0)])
    b.act("crouch", 5.4, tracks, body=body)
    b.act("weapons_check", 6.6, {   # each port gun rises and drops in turn, then the cell lifts out of its hatch and tilts
        "elev_l": [(1.0, 28.0), (1.6, 27.0), (2.4, -10.0), (2.9, 0.0)],
        "elev_r": [(2.0, 0.0), (3.0, 28.0), (3.6, 27.0), (4.4, -10.0), (4.9, 0.0)],
        "elev_cell": cell(3.6, 4.7, 5.3, 6.4),
    })
    b.act("stamp", 5.6, {   # a forefoot lifts high and stamps down, then a hind one, the shell dropping onto each
        "hip_fr": [(0.9, 30.0), (1.8, 31.0), (2.1, 0.0)],
        "knee_fr": [(0.9, -44.0), (1.8, -45.0), (2.1, 0.0)],
        "ankle_fr": [(0.9, 14.0), (1.8, 14.0), (2.1, 0.0)],
        "hip_hl": [(2.8, 0.0), (3.5, 22.0), (4.1, 23.0), (4.4, 0.0)],
        "knee_hl": [(2.8, 0.0), (3.5, 40.0), (4.1, 41.0), (4.4, 0.0)],
        "ankle_hl": [(2.8, 0.0), (3.5, -62.0), (4.1, -64.0), (4.4, 0.0)],
    }, body=[(0.9, 0.0, 0.0, 0.5, 0.0, 1.5, 0.0), (1.8, 0.0, 0.0, 0.6, 0.0, 1.7, 0.0), (2.1, 0.0, 0.0, -1.4, 0.0, -0.8, 0.0), (2.6, 0.0, 0.0, 0.0),
             (3.5, 0.0, 0.0, 0.5, 0.0, -1.2, 0.0), (4.1, 0.0, 0.0, 0.6, 0.0, -1.3, 0.0), (4.4, 0.0, 0.0, -1.4, 0.0, 0.6, 0.0), (5.0, 0.0, 0.0, 0.0)])
    # Movement (Ryan, 4 October, the third pass: stomp and plod, no weight thrown side to
    # side): a heavy walk in diagonal pairs, each foot planted flat while the shell passes
    # over it, lifted and stamped down; the shell level but for its drop onto each pair.
    tracks, body, stride = _plant([
        {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg],
         "phase": 0.0 if leg in ("fl", "hr") else 0.5, "shift": legs[leg][0][1] - legs[leg][2][1]}
        for leg in ("fl", "fr", "hl", "hr")], sweep=30.0, lift=7.0, crouch=0.5, dip=1.6, nod=0.6)
    b.gait(stride=stride, tracks=tracks, body=body, ease="linear")
    b.move(accel=1.6, heft=0.26)

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
    # The whole plow rides a pitch joint at the hull's front, raised and dropped like a
    # dozer blade (the joint pass, 2 October); the bars' hull ends are its hinge.
    plow = b.joint("plow", (0.0, 26.0, 8.0), limits=(-2.0, 18.0))
    plow.__enter__()
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
    plow.__exit__(None, None, None)
    # The turret: a wide eight-sided drum on the hull, the machine's most prominent
    # feature, two parallel guns set well apart off a wide mantlet (hp_1 left, hp_2 right),
    # a hatch and a sight; a bare mount on its top (hp_4).
    # Up on a base so the drum turns clear of the skirts and the tread decks (Ryan, 1
    # October, from his Blender view: it would have clipped the side panels).
    b.prism("z", 0.0, -6.0, 28.0, 15.0, 4.0, "steel.panel", 8, "turret_base")
    b.prism("z", 0.0, -6.0, 31.0, 19.0, 2.0, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, -6.0, 32.0)):   # the turret traverses (the view turns a turret joint about its up axis)
        b.prism("z", 0.0, -6.0, 37.0, 20.0, 10.0, "steel.panel", 8, "turret", phase=math.pi / 8)
        with b.joint("elev", (0.0, 8.0, 37.0), limits=(-6.0, 22.0)):   # the mantlet and both guns elevate together (the joint pass)
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
    with b.joint("elev_pod", (-TX - 1.0, -23.0, TH + 9.0), limits=(0.0, 16.0)):   # the pod tilts up on its deck
        with b.socket("hp_3", (-TX - 1.0, -16.0, TH + 16.0)):
            b.box(-TX - 8.0, -TX + 6.0, -30.0, -16.2, TH + 9.0, TH + 23.0, "steel.panel", "missile_box")
            _missile_face(b, (-TX - 8.0, -16.15, TH + 9.0), (0.0, 0.0, 1.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), 14.0)
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

    # Idle acts, third pass (Ryan, 4 October: turrets too fast and wild; heavy, with
    # inertia): curves a part runs on through, the servos' heft (b.move), held poses that
    # drift, and the turret slow and short with a pause before it turns back (the builder's
    # rule). Degrees and seconds; a key is (t, value) on the joint's own axis or (t, pitch,
    # yaw, roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow
    # key is (t, k), k the light added over rest.
    b.act("sweep_turret", 8.0, {   # a slow sweep out one way, a pause, across to the other, a pause, home; the guns climbing and dropping, the sight hot
        "turret": [(0.5, 0.0), (2.1, 55.0), (2.8, 55.0), (5.7, -45.0), (6.4, -45.0), (7.8, 0.0)],
        "elev": [(1.4, 16.0), (2.8, 18.0), (4.3, -2.0), (5.8, 14.0), (7.6, 0.0)],
    }, glow=[(["sight"], [(0.4, 0.0), (0.9, 7.0), (7.2, 7.0), (8.0, 0.0)])])
    # One heavy lift (Ryan, 5 October: once, to show how heavy it is; the guns up first, out of
    # the plow's way): the guns climb clear, the plow comes up slow and straining, the hull's
    # nose sinking under it, judders at the top, and drops; the hull bucks.
    b.act("test_plow", 5.8, {
        "elev": [(0.3, 0.0), (1.1, 20.0), (4.6, 21.0), (5.4, 0.0)],
        "plow": [(1.2, 0.0), (2.0, 4.0), (2.8, 16.5), (3.05, 18.0), (3.3, 16.0), (3.55, 18.0), (3.9, 18.0), (4.1, -2.0), (4.7, 0.0)],
    }, body=[(1.2, 0.0, 0.0, 0.0), (2.8, 0.0, 0.0, -0.6, 0.0, -2.2, 0.0), (3.05, 0.0, 0.0, -0.7, 0.0, -2.6, 0.0), (3.3, 0.0, 0.0, -0.5, 0.0, -2.0, 0.0),
             (3.9, 0.0, 0.0, -0.7, 0.0, -2.5, 0.0), (4.1, 0.0, 0.0, -1.3, 0.0, 2.6, 0.0), (4.45, 0.0, 0.0, 0.3, 0.0, -0.9, 0.0), (5.0, 0.0, 0.0, 0.0)])
    b.act("rev", 4.6, body=[   # lurches forward, rocks, backs off, lurches again
        (0.6, 0.0, 9.0, 0.0, 0.0, 4.0, 0.0), (1.2, 0.0, 8.0, 0.0, 0.0, -3.0, 0.0), (2.0, 0.0, -4.0, 0.0, 0.0, -2.0, 0.0),
        (2.7, 0.0, 6.0, 0.0, 0.0, 3.0, 0.0), (3.4, 0.0, 5.0, 0.0, 0.0, -2.0, 0.0), (4.6, 0.0, 0.0, 0.0)])
    b.act("tilt_pod", 5.4, {   # the pod tilts up on its deck while the turret turns aside to clear it
        "elev_pod": [(1.2, 16.0), (3.8, 15.5), (4.8, 0.0)],
        "turret": [(0.6, 0.0), (2.0, -45.0), (3.6, -45.0), (5.0, 0.0)],
        "elev": [(1.4, 14.0), (3.6, 13.0), (4.8, 0.0)],
    })
    # Movement: the treads scroll; a rock on pulling away and stopping; the turret turns
    # with the hull (Ryan, 4 October: holding its aim was not worth the complexity).
    # A little unstable under the plow (Ryan, 5 October), and smooth (the fifth notes: the
    # bumps read as a rough road, which every ground machine would then want): the hull's
    # weight sways slowly fore and aft as it goes, the way it does pulling away or revving,
    # two gentle waves over a long cycle so it never ticks like a metronome; the plow nods a
    # beat behind on its rams.
    sway = lambda p: 2.4 * math.sin(2.0 * math.pi * p) + 0.8 * math.sin(4.0 * math.pi * p + 1.1)
    surge = lambda p: 1.6 * math.sin(2.0 * math.pi * p + 0.6)
    phases = [k / 12.0 for k in range(13)]
    b.gait(treads={"parts": ["tread"], "scroll": 1.0}, rock=7.0, stride=150.0,
           body=[(round(p, 3), 0.0, round(surge(p), 2), 0.0, 0.0, round(sway(p), 2), 0.0) for p in phases],
           tracks={"plow": [(round(p, 3), round(max(-2.0, -1.2 * sway(p - 0.08)), 2)) for p in phases]})
    b.move(accel=1.1, heft=0.18)

wild_boar.maker = "minerva"


def _wheel(b, cx, cy, r, w, label="wheel", lit=False):
    """An eight-sided wheel across x: rubber tread with a dark hub, a lit hub ring if asked."""
    b.prism("x", cx, cy, r, r, w, "bore.tread", 8, label, phase=math.pi / 8)
    b.prism("x", cx, cy, r, r * 0.5, w + 1.0, "steel.dark", 8, label + "_hub", phase=math.pi / 8)
    if lit:
        b.prism("x", cx, cy, r, r * 0.3, w + 1.6, "amber.engine", 8, label + "_ring", phase=math.pi / 8)


def _skirt_plate(b, s, r, hubs):
    """The Prairie Dog's skirt, one long plate of armour down the side outboard of both wheels
    (Ryan, 5 October, the sixth notes: the skirt is unique, on both sides; the seventh: out
    past the tyres; the eighth, 6 October: the long connected plate is the defining thing, and
    hides some of the tyres' play in the arches, so it comes back whole, and the front wheels
    steer through it at full lock). The ninth notes (Ryan, 6 October: make it look like the
    designers tried to protect the tyres; of three mock-ups, bash bars, the most W&S,
    functional rather than sleek): a low rail runs on from each end of the plate to a bar
    standing ahead of the front tyre and behind the rear, and a top bar across in front of
    the tyre toward the body; an armoured boss on the plate over each hub. The thirteenth
    (Ryan, 6 October: the bars to the fenders, not the hubs, the wheels free and independent):
    built on the body with the fenders, the plate hanging from the drops at the fenders' inner
    ends and the hoops bolted to the aprons at their outer ends (prairie_dog), so it all rocks
    with the body and the wheels move under it on their own. Raised a unit and a half, since
    the body's nose drops toward the ground in the rev (measured, the lowest part a unit and a
    half clear). A front tyre turning steers through the plate past about nine degrees, its
    hub the first, as it always has (the eighth notes asked to see it); the rails run on the
    plate's outer face, clear of it as far as the map turns it."""
    def bar(x0, x1, y0, y1, z0, z1):
        b.box(min(s * x0, s * x1), max(s * x0, s * x1), min(y0, y1), max(y0, y1), z0, z1, "steel.dark", "bar")
    b.box(min(s * 25.0, s * 26.6), max(s * 25.0, s * 26.6), -24.0, 24.0, 7.5, 16.0, "steel.plate", "skirt")
    for yw in hubs:
        b.prism("x", s * 27.4, yw, r, 3.6, 1.6, "steel.dark", 8, "skirt_boss", phase=math.pi / 8)
    for e, y0, y1 in ((1.0, 30.6, 32.2), (-1.0, -30.6, -32.2)):   # the hoops against the aprons' faces
        bar(26.6, 28.2, e * 22.0, y1, 8.0, 10.0)     # the low rail, bolted on the plate's face and run on past its end
        bar(26.6, 28.2, y0, y1, 8.0, 18.0)           # the upright
        bar(15.0, 28.2, y0, y1, 16.0, 18.0)          # the top bar across the tyre's front or back


def _prairie_body(y):
    """The Prairie Dog's body at y: its half width and its top, read off the body's loft
    (below) so the front arches can follow it in."""
    secs = ((-30.0, 14.0, 24.0), (-6.0, 15.0, 28.0), (12.0, 14.0, 24.0), (32.0, 10.0, 15.0))
    for (y0, h0, t0), (y1, h1, t1) in zip(secs, secs[1:]):
        if y <= y1:
            f = max(0.0, (y - y0) / (y1 - y0))
            return h0 + f * (h1 - h0), t0 + f * (t1 - t0)
    return secs[-1][1], secs[-1][2]


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
    # The wheels spin on their hubs, the front pair steering (the joint pass, 2 October):
    # a steer joint about up carrying the wheel's spin joint. Built first, outside the
    # chassis joint, so they stay planted while the body squats and rocks over them.
    for yw, fr in ((18.0, "f"), (-18.0, "r")):
        for s in (-1.0, 1.0):
            w = fr + ("l" if s < 0 else "r")
            hub = (s * 20.0, yw, R)
            if fr == "f":
                with b.joint("steer_%s" % w, hub, limits=(-32.0, 32.0)):
                    with b.joint("wheel_%s" % w, hub):
                        _wheel(b, s * 20.0, yw, R, 8.0)
            else:
                with b.joint("wheel_%s" % w, hub):
                    _wheel(b, s * 20.0, yw, R, 8.0)
    chassis = b.joint("chassis", (0.0, -4.0, 12.0), limits={"pitch": (-6.0, 6.0), "roll": (-6.0, 6.0)}, swing=False)
    chassis.__enter__()
    for s in (-1.0, 1.0):
        _skirt_plate(b, s, R, (18.0, -18.0))
    for yw in (18.0, -18.0):
        for s in (-1.0, 1.0):
            # An angular arch over each wheel, open outward, its first shape and thickness raised
            # clear of the wheel (Ryan, 5 October: the wheel tops came up through them as the
            # chassis rocked; then, deepened, they read far too thick): the arch rides just
            # over the tyre at rest, so a chassis dipping three or four units over a wheel
            # takes the tyre up into the arch's own depth and never through its top.
            # Raised clear of the tyre (the sixth notes: the wheel top came through in rev again,
            # the arch sitting right on it; five and a half, far too high; the seventh: only the
            # top matters at the game's angles, the tyre may ride into the arch's depth): a unit
            # and a half over its old height, the least that keeps the tyre under the arch's top
            # through the rev's rock and squat (measured).
            # Each arch comes down at its ends (Ryan, 6 October, the thirteenth notes): at its
            # outer end an apron across the tyre's front (or back) down to the hub, shielding it
            # and closing the open wedge where the arch rose off the tyre; at its inner end a drop
            # to the skirt plate, which hangs from the four of them, the bash bars' hoops bolted
            # to the aprons. All on the body; the wheels move free under them.
            out_y, in_y = (yw + 12.0, yw - 12.0) if yw > 0.0 else (yw - 12.0, yw + 12.0)
            e = 1.0 if yw > 0.0 else -1.0
            b.box(min(s * 15.0, s * 26.6), max(s * 15.0, s * 26.6), min(out_y - e * 0.8, out_y + e * 0.6), max(out_y - e * 0.8, out_y + e * 0.6), 9.0, R + 11.0, "steel.plate", "apron")
            b.box(min(s * 16.0, s * 26.6), max(s * 16.0, s * 26.6), min(in_y - e * 0.8, in_y + e * 0.8), max(in_y - e * 0.8, in_y + e * 0.8), 14.0, R + 11.0, "steel.plate", "drop")
            if yw < 0.0:
                b.loft([(yw - 12.0, rect(s * 18.0, 10.0, R + 7.0, R + 11.0)), (yw, rect(s * 18.0, 10.0, R + 11.0, R + 15.0)), (yw + 12.0, rect(s * 18.0, 10.0, R + 7.0, R + 11.0))], "steel.plate", "arch")
                continue
            # The front pair meet the body (Ryan, 6 October, the ninth notes: a gap between the
            # front fenders and the body; an inner flange stepping down into the nose was far too
            # smooth a join for W&S; the box rolled 15 degrees onto the nose lost its squared-off
            # look, the twelfth). The level box again, flat on top and square at every edge, its
            # inner edge run in on one straight line to a unit inside the nose's flank, and a
            # square lip two units wide hung from that edge down to half a unit into the body's
            # top where the nose drops away under the arch, so the arch sits on the hull as a
            # bolted box would. Nothing over the tyre changes, so its top clears the tyre in the
            # rev as the level arch always has.
            nose_half, _top = _prairie_body(yw + 12.0)
            secs = []
            for (y, z0), xi in zip(((yw - 12.0, R + 7.0), (yw, R + 11.0), (yw + 12.0, R + 7.0)), (13.0, (13.0 + nose_half - 1.0) * 0.5, nose_half - 1.0)):
                lip = min(z0, _prairie_body(y)[1] - 0.5)
                pts = [(xi, lip), (xi + 2.0, lip), (xi + 2.0, z0), (23.0, z0), (23.0, z0 + 4.0), (xi, z0 + 4.0)]
                secs.append((y, [(s * x, z) for x, z in (pts if s > 0 else pts[::-1])]))
            b.loft(secs, "steel.plate", "arch")
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
    with b.joint("sensor", (0.0, -27.0, 34.0), limits=(-75.0, 75.0)):   # the head turns on its mast (the joint pass)
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
    # The third mount (hp_3) is bare on the rear-right corner, the launcher's twin.
    b.pad("hp_3", (10.0, -26.0, 26.0), scale=0.7, size=(6.0, 2.0))   # on the roof, not above it
    for s in (-1.0, 1.0):
        b.box(s * 7.0 - 2.0, s * 7.0 + 2.0, 32.5, 33.5, 12.0, 14.0, "amber.light", "lamp")
    chassis.__exit__(None, None, None)

    # Idle acts, third pass (Ryan, 4 October: turrets too fast and wild; real machines with
    # inertia): curves a part runs on through, the servos' heft (b.move), and the turret slow
    # and short with a pause before it turns back (the builder's rule); the wheels spin as
    # keyed. Degrees and seconds; a key is (t, value) on the joint's own axis or (t, pitch,
    # yaw, roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow
    # key is (t, k), k the light added over rest.
    b.act("rev", 4.2, {   # revs eagerly: a jump forward, a squat, back, and again; the wheels spin hard
        "wheel_fl": [(0.3, 0.0), (1.4, -900.0), (2.4, -540.0), (3.4, -1080.0), (4.2, -1080.0)],
        "wheel_fr": [(0.3, 0.0), (1.4, -900.0), (2.4, -540.0), (3.4, -1080.0), (4.2, -1080.0)],
        "wheel_rl": [(0.3, 0.0), (1.4, -900.0), (2.4, -540.0), (3.4, -1080.0), (4.2, -1080.0)],
        "wheel_rr": [(0.3, 0.0), (1.4, -900.0), (2.4, -540.0), (3.4, -1080.0), (4.2, -1080.0)],
        "chassis": [(0.5, 6.0, 0.0, 0.0, 0.0, 0.0, -2.5), (1.2, -6.0, 0.0, 0.0, 0.0, 0.0, -2.0), (2.2, 5.0, 0.0, 0.0, 0.0, 0.0, -1.5), (3.0, -6.0, 0.0, 0.0, 0.0, 0.0, -2.0), (3.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)],
    }, body=[(0.6, 0.0, 10.0, 0.0), (1.3, 0.0, 9.0, 0.0), (2.2, 0.0, -4.0, 0.0), (3.0, 0.0, 6.0, 0.0), (4.2, 0.0, 0.0, 0.0)])
    b.act("scout", 7.6, {   # the sensor head looks one way and then the other, the turret following it round each way and waiting, the mast light hot
        "sensor": [(0.9, 60.0), (2.4, 62.0), (3.6, -55.0), (5.6, -58.0), (6.8, 0.0)],
        "turret": [(0.6, 0.0), (2.2, 45.0), (2.9, 45.0), (5.4, -40.0), (6.1, -40.0), (7.3, 0.0)],
    }, glow=[(["mast_light", "lamp"], [(0.4, 0.0), (0.8, 7.0), (1.2, 2.0), (1.6, 7.0), (6.0, 7.0), (6.8, 0.0)])])
    b.act("traverse_turret", 8.2, {   # the turret traverses out to one side, holds, across to the other, holds, and home, the body settling under its weight
        "turret": [(0.5, 0.0), (2.0, 50.0), (2.7, 50.0), (5.7, -50.0), (6.4, -50.0), (7.9, 0.0)],
        "chassis": [(2.0, 0.0, 0.0, -2.6), (2.7, 0.0, 0.0, -2.8), (4.2, 0.0, 0.0, 0.0), (5.7, 0.0, 0.0, 2.6), (6.4, 0.0, 0.0, 2.8), (8.0, 0.0, 0.0, 0.0)],
    })
    b.act("steer", 3.8, {   # the fronts lock over each way, the body leaning with them
        "steer_fl": [(0.7, 32.0), (1.3, 30.0), (2.3, -32.0), (2.9, -30.0), (3.6, 0.0)],
        "steer_fr": [(0.7, 32.0), (1.3, 30.0), (2.3, -32.0), (2.9, -30.0), (3.6, 0.0)],
        "chassis": [(0.7, 0.0, 0.0, -3.0), (1.3, 0.0, 0.0, -2.6), (2.3, 0.0, 0.0, 3.0), (2.9, 0.0, 0.0, 2.6), (3.6, 0.0, 0.0, 0.0)],
    })
    # Movement: the wheels spin by their radius, the fronts steer into turns, the body rocks
    # on pulling away; the turret turns with the hull.
    b.gait(wheels={"wheel_fl": R, "wheel_fr": R, "wheel_rl": R, "wheel_rr": R}, steer={"steer_fl": 14.0, "steer_fr": 14.0}, rock=5.0)
    b.move(accel=0.6, heft=0.1)

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
    # The wheels (the joint pass, 2 October; Ryan: the posts they hang from are casters
    # with a limited swing, so it can strafe): each on a caster joint about up at its hub,
    # carrying the wheel's spin. Outside the chassis joint, so they stay planted.
    for yw, fr in ((20.0, "f"), (-20.0, "r")):
        for s in (-1.0, 1.0):
            w = fr + ("l" if s < 0 else "r")
            hub = (s * 26.0, yw, R)
            with b.joint("caster_%s" % w, hub, limits=(-85.0, 85.0)):
                with b.joint("wheel_%s" % w, hub):
                    _wheel(b, hub[0], hub[1], R, 7.0, lit=True)
    chassis = b.joint("chassis", (0.0, 0.0, 12.0), limits={"pitch": (-6.0, 6.0), "roll": (-8.0, 8.0)}, swing=False)
    chassis.__enter__()
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
    # The harpoon: a low rail along the roof to a launch head at the nose's root, the barbed
    # dart in it; the capacitor drum half sunk into the tail with a lit band.
    # The whole harpoon pitches on the drum's axis, the drum turning with it (the joint pass).
    with b.joint("harpoon", (0.0, -20.0, 18.0), limits=(-3.0, 24.0)):
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
    with b.joint("elev_mortar", (10.0, -28.0, 19.0), limits=(-6.0, 28.0)):   # the tube elevates on its base
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
    chassis.__exit__(None, None, None)

    # Idle acts, third pass (Ryan, 4 October: some stilted; real machines with inertia; the
    # Dingo was alright): curves a part runs on through and the light servos' heft (b.move);
    # the wheels spin as keyed. Degrees and seconds; a key is (t, value) on the joint's own
    # axis or (t, pitch, yaw, roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw,
    # pitch, roll); a glow key is (t, k), k the light added over rest.
    # Fourth pass (Ryan, 5 October: a little wild and crazy; the strafe tame, the spin's
    # casters paired, and it should not sit still): the wheels roll as far as the car moves
    # over them (ROLL degrees a unit), the casters set square to each move.
    ROLL = math.degrees(1.0 / R)
    spin = lambda keys, k: [(t, round(v * k, 1)) for t, v in keys]
    slide = [(0.35, 0.0), (0.85, -24.0), (1.05, -26.0), (1.75, 22.0), (1.95, 25.0), (2.5, -8.0), (2.75, -9.0), (3.2, 0.0)]
    dart = [(3.55, 0.0), (4.05, 9.0), (4.3, 10.0), (4.85, 0.0)]
    roll_keys = [(t, round(ROLL * (dict(slide).get(t, 0.0)) - ROLL * dict(dart).get(t, 0.0), 1)) for t in sorted(set(dict(slide)) | set(dict(dart)))]
    b.act("strafe", 5.2, places=("map",), tracks={   # every wheel snaps sideways: a dash left, straight across past centre to the right, a twitch back, then a dart forward and back; on the map only (Ryan, 5 October, the sixth notes: it will not fit the skirmish's frame)
        **{"caster_" + w: [(0.3, 84.0), (3.25, 84.0), (3.55, 0.0)] for w in ("fl", "fr", "rl", "rr")},
        **{"wheel_" + w: roll_keys for w in ("fl", "fr", "rl", "rr")},
        "chassis": [(0.55, 0.0, 0.0, 7.0), (0.95, 0.0, 0.0, -8.0), (1.35, 0.0, 0.0, 8.0), (1.9, 0.0, 0.0, -8.0), (2.3, 0.0, 0.0, 6.0), (2.7, 0.0, 0.0, -5.0),
                    (3.1, 0.0, 0.0, 2.0), (3.7, 5.0, 0.0, 0.0), (4.15, -5.0, 0.0, 0.0), (4.5, 4.0, 0.0, 0.0), (5.0, 0.0, 0.0, 0.0)],
    }, body=[(t, x, 0.0, 0.0, round(-x * 0.2, 1), 0.0, 0.0) for t, x in slide] + [(t, 0.0, y, 0.0) for t, y in dart])
    # An antsy pilot, not an animal (Ryan, 5 October, the sixth notes: the harpoon and the
    # mortar check read as a creature fidgeting): the car holds still between quick, discrete
    # inputs, each held: sight ticks on the harpoon, a throttle blip, a caster tap, the tube
    # stepped up and test-dropped twice; on quicker servos than its own (an act's heft).
    blip = lambda t, dy: [(t, 0.0, 0.0, 0.0), (round(t + 0.18, 2), 0.0, dy, 0.0), (round(t + 0.5, 2), 0.0, 0.0, 0.0)]
    b.act("harpoon", 5.0, {   # the harpoon snaps up and the sight ticks while the ring charges in pulses; a throttle blip, a caster tap, then it drops
        "harpoon": [(0.5, 0.0), (0.8, 20.0), (1.5, 20.0), (1.6, 23.0), (1.9, 23.0), (2.0, 19.0), (2.6, 19.0), (2.7, 21.5), (3.6, 21.5), (4.1, 0.0)],
        **{"caster_" + w: [(1.0, 0.0), (1.12, 10.0), (1.6, 10.0), (1.72, -6.0), (2.3, -6.0), (2.42, 0.0), (3.0, 0.0), (3.12, 8.0), (3.5, 8.0), (3.62, 0.0)] for w in ("fl", "fr")},
        **{"wheel_" + w: spin([(2.4, 0.0), (2.58, 3.0), (2.9, 0.0), (3.7, 0.0), (3.88, -2.0), (4.2, 0.0)], ROLL) for w in ("fl", "fr", "rl", "rr")},
        "chassis": [(2.4, 0.0, 0.0, 0.0), (2.55, 2.0, 0.0, 0.0), (2.75, -1.5, 0.0, 0.0), (3.0, 0.0, 0.0, 0.0), (3.7, 0.0, 0.0, 0.0), (3.85, -1.5, 0.0, 0.0), (4.05, 1.0, 0.0, 0.0), (4.3, 0.0, 0.0, 0.0)],
    }, body=blip(2.4, 3.0) + blip(3.7, -2.0)[1:], heft=0.06,
       glow=[(["capacitor_ring"], [(0.6, 0.0), (0.9, 6.0), (1.1, 1.0), (1.4, 7.0), (1.6, 2.0), (1.9, 9.0), (3.6, 9.0), (4.2, 0.0)])])
    # The seventh notes: the harpoon is the good kind of twitchy, the mortar check nodded (the
    # tube test-dropped twice, the chassis dipping with it): now the tube ticks up a notch at a
    # time, each snap settling back a hair, and jitters on its fine aim; nothing pitches the
    # car. The eighth (Ryan, 6 October: the tube is small beside the harpoon, so the back
    # wheels do something too): the pilot lays the mortar with the tail. The rear casters snap
    # over and jab, kicking the tail out a few degrees about the front axle (the car's yaw with
    # the slide that keeps the front wheels put), a fine-aim jitter, the casters snap the other
    # way for a correction back past centre, another tick on the tube, then a throttle blip
    # straightens it and the tube drops.
    kick = lambda t, yaw_deg, dy=0.0: (t, round(26.0 * math.sin(math.radians(yaw_deg)), 2), round(26.0 * (1.0 - math.cos(math.radians(yaw_deg))) + dy, 2), 0.0, yaw_deg, 0.0, 0.0)
    b.act("mortar_check", 4.4, {   # the tube ticked up notch by notch; the rear casters snap and kick the tail over to lay it, a jitter, a correction back, a throttle blip, and down
        "elev_mortar": [(0.4, 0.0), (0.5, 9.5), (0.58, 8.5), (0.95, 8.5), (1.05, 17.5), (1.13, 16.5), (1.5, 16.5), (1.6, 25.5), (1.68, 24.5), (2.2, 24.5),
                        (2.26, 26.0), (2.32, 24.0), (2.38, 25.5), (2.44, 24.5), (2.85, 24.5), (2.92, 23.0), (2.98, 23.5), (3.7, 23.5), (3.8, 25.0), (4.2, 0.0)],
        **{"caster_" + w: [(1.75, 0.0), (1.85, -16.0), (2.6, -16.0), (2.68, 12.0), (3.15, 12.0), (3.25, 0.0)] for w in ("rl", "rr")},
        **{"caster_" + w: [(1.8, 0.0), (1.9, 5.0), (2.6, 5.0), (2.7, -3.0), (3.15, -3.0), (3.25, 0.0)] for w in ("fl", "fr")},
        **{"wheel_" + w: spin([(1.85, 0.0), (2.0, -1.8), (2.6, -1.8), (2.72, 0.6), (3.15, 0.6), (3.33, 3.1), (3.65, 0.0)], ROLL) for w in ("rl", "rr")},
        **{"wheel_" + w: spin([(3.15, 0.0), (3.33, 2.5), (3.65, 0.0)], ROLL) for w in ("fl", "fr")},
    }, body=[(1.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), kick(2.0, 3.5), kick(2.55, 3.5), kick(2.72, -1.1), kick(3.15, -1.1), kick(3.33, 0.0, 2.5), kick(3.65, 0.0)], heft=0.06)
    # A full turn on the spot (Ryan, 5 October: the paired casters could not spin it): each
    # caster square to its corner's radius, the right wheels driving forward and the left
    # back, and the car whips round once anticlockwise and rocks to a stop. The wheels'
    # turn a whole number of turns (near enough the ground they cover), so they come home
    # where they started.
    CASTER = math.degrees(math.atan2(20.0, 26.0))   # the corners' radius off the car's line
    yaw = [(0.45, 0.0), (0.75, 40.0), (1.15, 175.0), (1.55, 315.0), (1.85, 360.0)]
    TURN = 1440.0 / 360.0   # wheel degrees a degree of yaw (the corners' circle over the wheel's: 4.1)
    b.act("spin_out", 3.2, {   # the casters snap diagonal, the car whips round a full turn and rocks to a stop
        **{"caster_" + w: [(0.35, k * CASTER), (2.0, k * CASTER), (2.4, 0.0)] for w, k in (("fl", -1.0), ("fr", 1.0), ("rl", 1.0), ("rr", -1.0))},
        **{"wheel_" + w: [(t, round(k * TURN * v, 1)) for t, v in yaw] + [(3.2, k * 1440.0)] for w, k in (("fl", 1.0), ("rl", 1.0), ("fr", -1.0), ("rr", -1.0))},
        "chassis": [(0.45, 3.0, 0.0, 0.0), (0.8, 2.0, 0.0, -5.0), (1.5, 1.0, 0.0, -6.0), (1.95, -5.0, 0.0, 6.0), (2.3, 3.0, 0.0, -3.0), (2.7, -1.0, 0.0, 1.0), (3.1, 0.0, 0.0, 0.0)],
    }, body=[(0.4, 0.0, 0.0, 0.0)] + [(t, 0.0, 0.0, 0.0, v, 0.0, 0.0) for t, v in yaw[1:]] + [(2.1, 0.0, 0.0, 0.0, 364.0, 0.0, 0.0), (3.2, 0.0, 0.0, 0.0, 360.0, 0.0, 0.0)])
    # Movement (Ryan, 2 October): it drifts. Oversteer (Ryan, 5 October: it lagged through
    # its turns where it should drift into them): the nose swings into a corner ahead of the
    # path, the tail stepping out, and back as the corner ends, while the casters point
    # along the travel, so they counter-steer through it.
    b.gait(wheels={"wheel_fl": R, "wheel_fr": R, "wheel_rl": R, "wheel_rr": R},
           aim={"caster_fl": 1.0, "caster_fr": 1.0, "caster_rl": 1.0, "caster_rr": 1.0}, rock=4.0)
    b.move(slide=0.4, bank=0.0, accel=0.5, heft=0.09, oversteer=2.0)   # drifts wildly on the map and does not bank (Ryan, 2 October); its rear kicked out further (the sixth notes), and further again (the seventh)

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
    # inward with glowing walls and a hot floor just inside. Every one of its lights banked
    # down at rest (amber.ember) so the charge lights them hot against it (Ryan, 6 October,
    # the eighth notes: the resting glow dimmed, the active one brought up, more contrast).
    fairing = b.loft([(-22.0, hexagon(0.0, -5.6, 8.0, 3.0)), (0.0, hexagon(0.0, -6.6, 14.0, 4.6)), (24.0, hexagon(0.0, -6.4, 13.0, 4.2)),
                      (30.0, hexagon(0.0, -5.9, 10.5, 3.4))], "steel.dark", "cannon_fairing")
    for s in (-1.0, 1.0):
        for k in range(4):
            y0 = 2.0 + k * 6.0
            hw = 7.0 - abs(y0 + 2.0 - 12.0) * 0.02   # the flank's half width near the pocket
            x_in, x_out = s * (hw - 1.6), s * (hw + 1.0)   # deeper, longer, the glow a small strip at the floor so it reads as a light inside, not a slab (Ryan, 1 October)
            b.cut_box([fairing], min(x_in, x_out), max(x_in, x_out), y0, y0 + 4.4, -7.3, -5.3)
            b.box(min(x_in, x_in + s * 0.2), max(x_in, x_in + s * 0.2), y0 + 0.1, y0 + 4.3, -7.2, -5.4, "amber.ember", "vent_glow")   # the whole floor of the cut (Ryan, 1 October)
    b.loft([(29.0, hexagon(0.0, -6.0, 9.0, 3.0)), (33.4, hexagon(0.0, -6.0, 8.6, 2.85))], "steel.dark", "cannon_barrel", cap=False)
    b.loft([(33.4, hexagon(0.0, -6.0, 7.8, 2.4)), (34.6, hexagon(0.0, -6.0, 7.8, 2.4))], "amber.ember", "barrel_groove", cap=False)
    b.loft([(34.6, hexagon(0.0, -6.0, 8.5, 2.8)), (40.0, hexagon(0.0, -6.0, 8.0, 2.6))], "steel.dark", "cannon_barrel", cap=False)
    _rings(b, [[(x, 40.0, z) for x, z in hexagon(0.0, -6.0, 8.0, 2.6)], [(x, 40.0, z) for x, z in hexagon(0.0, -6.0, 6.8, 2.1)]], "steel.dark", "cannon_rim", cap=False)
    b.loft([(40.0, hexagon(0.0, -6.0, 6.8, 2.1)), (38.0, hexagon(0.0, -6.0, 5.6, 1.75))], "amber.ember", "cannon_bore", cap=False)
    b.loft([(38.1, hexagon(0.0, -6.0, 5.6, 1.75)), (38.4, hexagon(0.0, -6.0, 5.6, 1.75))], "amber.ember", "cannon_glow")   # a touch back in from the tenth round (Ryan, 1 October)
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
            return 2.0 + (ax - 5.0) / 25.0 * 0.8
        return 2.8 - (ax - 30.0) / 34.0 * 12.8
    for s in (-1.0, 1.0):
        # Rooted inside the fuselage (Ryan, 5 October: the wings did not meet the body; at x 9
        # the root stood beside the narrowing nose), so the root's whole chord is buried.
        root = [(s * 5.0, -6.0, 1.0), (s * 5.0, -6.0, 3.0), (s * 5.0, 20.0, 2.0)]
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
        # The pivot the nacelle tilts on, a drum on its axis (Ryan, 5 October: a block under
        # the nacelle showed as it tilted), so nothing square is left when it turns.
        b.prism("x", s * 7.0, -24.0, nz, 4.6, 5.0, "steel.dark", 8, "nacelle_root", phase=math.pi / 8)
        # Each nacelle pitches on its root for vectored thrust, its fin with it (the joint pass).
        with b.joint("nacelle_%s" % ("l" if s < 0 else "r"), (nx, -24.0, nz), limits=(-14.0, 40.0)):
            b.prism("y", nx, -24.0, nz, 6.0, 30.0, "steel.dark", 6, "nacelle", phase=math.pi / 6)
            b.prism("y", nx, -39.5, nz, 6.4, 1.5, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
            b.loft([(-40.0, hexagon(nx, nz, 10.0, 8.6)), (-40.5, hexagon(nx, nz, 9.0, 7.6))], "amber.exhaust", "exhaust")
            b.loft([(-9.5, hexagon(nx, nz, 9.6, 8.2)), (-9.0, hexagon(nx, nz, 8.6, 7.2))], "bore.dark", "nacelle_mouth")
            a = math.radians(s * 32.0)
            root = [(nx, -38.0, nz + 5.5), (nx, -22.0, nz + 5.5), (nx, -22.0, nz + 6.3), (nx, -38.0, nz + 6.3)]
            tip = [(nx + 15.0 * math.sin(a), -40.0, nz + 5.5 + 15.0 * math.cos(a)), (nx + 15.0 * math.sin(a), -32.0, nz + 5.5 + 15.0 * math.cos(a)),
                   (nx + 15.0 * math.sin(a), -32.0, nz + 6.1 + 15.0 * math.cos(a)), (nx + 15.0 * math.sin(a), -40.0, nz + 6.1 + 15.0 * math.cos(a))]
            _wing(b, root, tip, "livery.livery", "fin")
    b.loft([(-42.0, rect(0.0, 1.2, -6.0, -2.4)), (-30.0, rect(0.0, 1.6, -7.5, -3.5))], "steel.dark", "strake")
    b.box(-2.0, 2.0, -15.0, 22.0, 6.8, 7.4, "livery.livery", "spine_stripe")
    # The heat spine (Ryan, 5 October: "let's try it"): the cannon draws its heat from the
    # engines, and the line it draws it along now runs on top, where the game's cameras look:
    # a dark channel between two rails from the nacelles forward to the intake, and again
    # over the nose ahead of the canopy, its floor a row of cells (heat_1 at the tail to
    # heat_9 at the nose) that charge_cannon lights in turn. Each run lies on the skin: its
    # sections fall on the fuselage's own.
    skin = [(44.0, 2.2), (34.0, 4.4), (18.0, 5.8), (0.0, 6.8), (-18.0, 6.6), (-34.0, 4.6), (-42.0, 2.6)]
    def top(y):
        for (y0, z0), (y1, z1) in zip(skin, skin[1:]):
            if y1 <= y <= y0:
                return z0 + (z1 - z0) * (y - y0) / (y1 - y0)
    def along(y0, y1, section, material, label):
        ys = [y0] + [k for k, _ in skin if min(y0, y1) < k < max(y0, y1)] + [y1]
        b.loft([(y, section(top(y))) for y in sorted(ys)], material, label)
    cell = 1
    for y_front, y_back, half, cells in ((-16.5, -41.0, 1.9, [(-17.5 - k * 3.9, -20.5 - k * 3.9) for k in range(6)]),
                                         (38.3, 23.5, 1.5, [(37.1 - k * 4.5, 33.5 - k * 4.5) for k in range(3)])):
        along(y_front, y_back, lambda z: rect(0.0, 2.0 * half, z - 0.3, z + 0.45), "steel.dark", "heat_channel")
        for s in (-1.0, 1.0):
            along(y_front, y_back, lambda z: rect(s * (half - 0.5), 1.0, z + 0.45, z + 0.95), "steel.dark", "heat_rail")
        for c0, c1 in sorted(cells, key=lambda c: c[0]):
            along(c0, c1, lambda z: rect(0.0, 2.0 * half - 2.0, z + 0.45, z + 0.72), "amber.glow", "heat_%d" % cell)
            cell += 1

    # Idle acts, third pass (Ryan, 4 October: the nacelle check was smooth; some others
    # stilted): curves a part runs on through, the servos' heft (b.move), and nothing holding
    # dead still. Degrees and seconds; a key is (t, value) on the joint's own axis or (t,
    # pitch, yaw, roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a
    # glow key is (t, k), k the light added over rest.
    # Fourth pass (Ryan, 5 October: the moving nacelles are the thing, so a second act for
    # them; the nacelle check rises and sinks instead of dipping a wing; the cannon's glow is
    # hard to see from the game's angles, the bore being under the nose).
    b.act("check_nacelles", 5.6, {   # the nacelles swing down and it climbs on them, holds, then they swing back and it sinks below its station and settles
        "nacelle_l": [(0.9, 40.0), (2.2, 38.0), (3.0, -14.0), (3.9, -12.0), (5.0, 0.0)],
        "nacelle_r": [(0.9, 40.0), (2.2, 38.0), (3.0, -14.0), (3.9, -12.0), (5.0, 0.0)],
    }, body=[(0.8, 0.0, 0.0, 0.0), (1.9, 0.0, -1.0, 12.0, 0.0, 3.0, 0.0), (2.5, 0.0, -1.0, 13.0, 0.0, 2.0, 0.0), (3.6, 0.0, 1.5, -5.0, 0.0, -3.0, 0.0),
             (4.3, 0.0, 0.5, -5.5, 0.0, -1.0, 0.0), (5.6, 0.0, 0.0, 0.0)],
       glow=[(["joint_nacelle_l", "joint_nacelle_r"], [(0.6, 0.0), (1.2, 8.0), (2.4, 6.0), (3.0, 1.0), (3.6, 4.0), (4.6, 0.0)])])
    b.act("vector_turn", 5.4, {   # the nacelles split, one down and one back, and it pivots on the spot; across to the other way; together again
        "nacelle_l": [(0.6, 0.0), (1.2, 40.0), (2.2, 38.0), (2.8, -14.0), (3.8, -12.0), (4.6, 0.0)],
        "nacelle_r": [(0.6, 0.0), (1.2, -14.0), (2.2, -12.0), (2.8, 40.0), (3.8, 38.0), (4.6, 0.0)],
    }, body=[(0.8, 0.0, 0.0, 0.0), (2.1, 0.0, 0.0, 1.0, -34.0, 0.0, 9.0), (2.5, 0.0, 0.0, 1.0, -36.0, 0.0, 6.0), (3.7, 0.0, 0.0, 1.0, 30.0, 0.0, -9.0),
             (4.1, 0.0, 0.0, 1.0, 32.0, 0.0, -6.0), (5.4, 0.0, 0.0, 0.0)],
       glow=[(["joint_nacelle_l"], [(0.8, 0.0), (1.3, 8.0), (2.4, 8.0), (2.9, 0.0)]), (["joint_nacelle_r"], [(2.4, 0.0), (2.9, 8.0), (3.9, 8.0), (4.5, 0.0)])])
    # The cannon draws its heat from the engines: the heat comes forward up the spine on top,
    # where the cameras look (Ryan, 5 October, the fifth notes: "let's try the heat spine"),
    # cell by cell from the tail to the nose, the exhausts fading as it is drawn off; then the
    # cannon under the nose glows up while the machine rises a little on it, nose lifting,
    # holds, and settles as the exhausts flare back. It no longer rolls onto its back to show
    # the belly (the sixth notes: with the spine on top the roll hid it again; Ryan to judge
    # it in game, the spine along the belly the other way if the roll comes back).
    # The seventh notes: the spine much hotter when it lights, the nose up further. The
    # eighth: the spine stays lit through the whole charge, fading only as the act ends, and
    # the cannon, dark at rest now, flickers up and burns far hotter than it did.
    heat = [([("heat_%d" % (i + 1))], [(0.2, 0.0), (round(0.3 + 0.15 * i, 2), 0.0), (round(0.45 + 0.15 * i, 2), 26.0), (round(0.7 + 0.15 * i, 2), 16.0), (3.6, 18.0), (5.2, 16.0), (5.8, 0.0)])
            for i in range(9)]
    b.act("charge_cannon", 6.0, glow=heat + [
        (["vent_glow", "barrel_groove", "cannon_bore", "cannon_glow"], [(1.6, 0.0), (2.2, 5.0), (2.5, 1.5), (2.8, 11.0), (3.1, 4.0), (3.6, 26.0), (4.5, 26.0), (5.4, 0.0)]),
        (["joint_nacelle_l", "joint_nacelle_r"], [(0.3, 0.0), (1.4, -0.6), (4.3, -0.85), (4.6, 7.0), (5.2, 4.0), (5.9, 0.0)])],
          body=[(1.4, 0.0, 0.0, 0.0), (2.6, 0.0, -1.0, 3.2, 0.0, 8.0, 0.0), (3.6, 0.0, -1.6, 4.0, 0.0, 11.0, 0.0), (4.4, 0.0, -1.3, 3.6, 0.0, 10.0, 0.0),
                (5.1, 0.0, 0.8, 1.0, 0.0, -2.5, 0.0), (6.0, 0.0, 0.0, 0.0)])
    # The bank (the fifth notes: more lateral, and level at the ends of the strafe): a skid
    # out one way banked into it, coming level as it stops there; across the other way banked
    # the other, level again at that end; and back to station.
    b.act("bank", 6.6, body=[
        (0.3, 0.0, 0.0, 0.0), (1.0, -9.0, 0.0, 0.3, 0.0, 0.0, -26.0), (1.7, -18.0, 0.0, 0.5, 0.0, 0.0, -4.0), (2.2, -18.5, 0.0, 0.4, 0.0, 0.0, 0.0),
        (3.0, -4.0, 0.0, 0.0, 0.0, 0.0, 26.0), (3.6, 14.0, 0.0, 0.3, 0.0, 0.0, 14.0), (4.1, 18.0, 0.0, 0.5, 0.0, 0.0, 2.0), (4.6, 18.5, 0.0, 0.4, 0.0, 0.0, 0.0),
        (5.4, 8.0, 0.0, 0.2, 0.0, 0.0, -18.0), (6.0, 1.0, 0.0, 0.0, 0.0, 0.0, -3.0), (6.6, 0.0, 0.0, 0.0)])
    # Movement: the nacelles tilt forward, the exhausts flare, the nose drops; it banks into
    # turns (b.move).
    b.gait(hold={"nacelle_l": -12.0, "nacelle_r": -12.0}, glow={"parts": ["joint_nacelle_l", "joint_nacelle_r"], "k": 5.0},
           body_hold=(0.0, 0.0, 0.0, 0.0, -5.0, 0.0))
    b.move(slide=0.3, bank=36.0, accel=0.9, heft=0.12, oversteer=0.3)   # larger and slower than the Sparrowhawk: slides less, banks well (Ryan, 5 October: more); the nose a little into its corners (the fifth notes)

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
    # Hip and knee on both legs (the joint pass, 2 October), and an ankle carrying the
    # sabaton flat through a stride (Ryan, 4 October, the third pass).
    legs = {}
    for s in (-1.0, 1.0):
        cx = s * 12.0
        side = "l" if s < 0 else "r"
        ankle = (cx, -1.0, 8.0)
        knee = (cx, 5.0, 30.0)
        hip = (cx * 0.8, -3.0, 46.0)
        legs[side] = (hip, knee, ankle)
        with b.joint("hip_%s" % side, hip, limits=(-60.0, 60.0)):
            _beam(b, knee, hip, _sq(12.0, 13.0), _sq(13.0, 14.0), "steel.panel", "thigh")
            b.loft([(-2.0, rect(cx, 14.0, 34.0, 44.0)), (6.0, rect(cx, 11.0, 36.0, 42.0))], "steel.plate", "cuisse")
            with b.joint("knee_%s" % side, knee, limits=(-100.0, 20.0)):
                with b.joint("ankle_%s" % side, ankle, limits=(-45.0, 100.0)):
                    b.loft([(-12.0, rect(cx, 15.0, 0.0, 6.0)), (4.0, rect(cx, 16.0, 0.0, 8.0)), (18.0, rect(cx, 13.0, 0.0, 3.0))], "steel.plate", "sabaton")
                _beam(b, ankle, knee, _sq(10.0, 11.0), _sq(9.0, 10.0), "steel.panel", "shin")
                b.loft([(2.0, rect(cx, 13.0, 12.0, 26.0)), (9.0, rect(cx, 10.0, 14.0, 24.0))], "steel.plate", "greave")
                b.box(cx - 5.0, cx + 5.0, 6.0, 12.0, 27.0, 34.0, "steel.dark", "knee_cap")
                _spike(b, (cx, 12.0, 31.0), (cx, 20.0, 34.0), 2.0, "steel.dark", "knee_spike")
    # The pelvis and a faulded skirt of plates.
    b.box(-14.0, 14.0, -8.0, 4.0, 42.0, 52.0, "steel.dark", "pelvis")
    for s in (-1.0, 1.0):
        b.loft([(-6.0, rect(s * 11.0, 10.0, 38.0, 50.0)), (4.0, rect(s * 11.0, 8.0, 40.0, 50.0))], "steel.plate", "fauld")
    # The waist (Ryan, 5 October, the fifth notes: a walker turns with a waist and never by
    # sliding its feet): everything above the pelvis, the arms, the shoulders' guns and the
    # helm, turns and leans on it.
    waist = b.joint("waist", (0.0, -2.0, 50.0), axis="yaw", limits={"yaw": (-35.0, 35.0), "pitch": (-18.0, 12.0), "roll": (-8.0, 8.0)}, swing=False)
    waist.__enter__()
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
    with b.joint("elev_meteor", (27.0, -16.0, 76.0), limits=(-18.0, 16.0)):   # the tubes elevate on the rack (the joint pass)
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
        side = "r" if heavy else "l"
        jt = b.joint("shoulder_%s" % side, shoulder, limits={"pitch": (-50.0, 70.0), "yaw": (-80.0, 80.0)})   # the arm swings from here, and turns in
        jt.__enter__()
        _beam(b, shoulder, elbow, _sq(w_up, w_up), _sq(w_up - 1.0, w_up - 1.0), "steel.panel", "upper_arm")
        b.box(elbow[0] - 6.5, elbow[0] + 6.5, elbow[1] - 6.0, elbow[1] + 6.0, elbow[2] - 6.0, elbow[2] + 6.0, "steel.dark", "elbow")
        el = b.joint("elbow_%s" % side, elbow, limits=(-70.0, 25.0))   # the forearm bends here (the joint pass)
        el.__enter__()
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
        el.__exit__(None, None, None)
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
    waist.__exit__(None, None, None)

    # Idle acts, third pass (Ryan, 4 October: some stilted; heavy, with inertia; MechWarrior,
    # not Gundam): curves a part runs on through, the servos' heft (b.move), held poses that
    # drift, fewer and heavier blows, and the feet planted while the body drops or rears over
    # them (_planted). Degrees and seconds; a key is (t, value) on the joint's own axis or (t,
    # pitch, yaw, roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a
    # glow key is (t, k), k the light added over rest.
    feet = [{"hip": "hip_" + side, "knee": "knee_" + side, "ankle": "ankle_" + side, "at": legs[side]} for side in ("l", "r")]
    # Fourth pass (Ryan, 5 October: an angry boy; the fist pound twice and low, before the
    # chest, not the face, where it looked like crying; the shoulder crack and the meteor
    # angrier). A pose is the shoulder's (pitch, yaw, roll) and the elbow, the left arm's;
    # the right takes it mirrored unless it has its own.

    # The fist pound, forceful (Ryan, 5 October, the fifth notes: too soft): wound up high and
    # wide with the torso reared back on its waist, then slammed together and the body
    # dropping; and at once again (the sixth notes: two quick pounds back to back), a short
    # lift off the bounce and down harder. The lean is the first blow's alone (the eighth),
    # the second the arms' alone. The ninth notes (Ryan, 6 October): it first widens its stance,
    # each foot lifted, set down further out and planted (the hip rolled out, the ankle back
    # so the sabaton lands flat); the fists gather speed all the way into each other and stop
    # dead (_slam), on servos quick enough to show it (the act's heft, where the machine's own
    # took a quarter of a second to catch up); after the second blow the fists stay pressed,
    # grinding, where they had recoiled and come back together, a bounce; and it steps back in.
    # The tenth notes (Ryan, 6 October): the fists meet higher, clear of the hip cannon, the
    # elbows raised out to the sides, so they meet at arm's length before the chest rather
    # than hugging in under the face (measured: the fists 26 forward at chest height, 72, the
    # elbows out at the shoulders' line and up at 66; they had met 16 forward with the
    # elbows tucked low at 55, overlapping each other by eight); and the grind is gone, the
    # small back and forth that read as the fists still oscillating: they stay pressed.
    # The heavier right arm reaches less far, so its pose at the hit is its own, not the
    # left's mirrored (it meets the left fist face to face at its yaw's limit).
    WIDE = (10.0, -40.0, 25.0, 15.0)
    UP, RECOIL, LIFT = (46.0, -20.0, 30.0, 20.0), (18.0, -52.0, 42.0, -2.0), (40.0, -45.0, 40.0, 8.0)
    # The eleventh notes (Ryan: the fists did not meet in either): only the knuckle spikes' tips
    # had touched, the knuckles themselves five and a half apart; the poses now bring the
    # knuckle faces together (measured on the fists' fronts, the spikes passing into the other
    # fist), and pressed a little past.
    HIT_L, HIT_R = (30.0, -73.0, 45.0, -10.0), (35.0, 80.0, -45.0, -14.0)
    PRESS_L, PRESS_R = (30.0, -74.0, 45.0, -10.0), (35.0, 80.0, -45.0, -15.0)
    WIDEN = 9.0   # degrees each hip rolls out to widen the stance
    lift_at = {sd: (legs[sd][2][1] + 1.0, legs[sd][2][2] + 6.0) for sd in ("l", "r")}
    # A leg rolled out reaches less far down: its ankle swings up round the hip, the more so
    # for the ankle standing outboard of the hip.
    rise = lambda sd: (legs[sd][0][2] - legs[sd][2][2]) * (1.0 - math.cos(math.radians(WIDEN))) + (abs(legs[sd][2][0]) - abs(legs[sd][0][0])) * math.sin(math.radians(WIDEN))
    wide_at = {sd: (legs[sd][2][1], legs[sd][2][2] - rise(sd)) for sd in ("l", "r")}
    home_at = {sd: (legs[sd][2][1], legs[sd][2][2]) for sd in ("l", "r")}
    SQ = -1.4   # the wider stance sits lower
    frames = [(0.2, (0.0, 0.0, 0.0), {}), (0.45, (0.0, -0.3, 0.0), {"l": lift_at["l"]}), (0.7, (0.0, -0.6, 0.0), {"l": wide_at["l"]}),
              (0.95, (0.0, -0.9, 0.0), {"r": lift_at["r"]}), (1.2, (0.0, -1.2, 0.0), {"r": wide_at["r"]}), (1.5, (0.0, SQ + 0.6, 1.0), {}),
              (2.05, (0.0, SQ + 1.0, 1.5), {})]
    frames += [(t, b2, {}) for t, b2 in _slam(2.05, (0.0, SQ + 1.0, 1.5), 2.3, (0.0, SQ - 3.2, -2.0))]
    frames += [(2.5, (0.0, SQ - 2.4, -1.4), {}), (4.2, (0.0, SQ - 2.5, -1.5), {}), (4.8, (0.0, SQ, 0.0), {}),
               (5.05, (0.0, SQ + 0.2, 0.0), {"r": lift_at["r"]}), (5.3, (0.0, SQ + 0.5, 0.0), {"r": home_at["r"]}),
               (5.55, (0.0, SQ + 0.8, 0.0), {"l": lift_at["l"]}), (5.8, (0.0, SQ + 1.1, 0.0), {"l": home_at["l"]}), (6.3, (0.0, 0.0, 0.0), {})]
    tracks, body = _steps({sd: feet[i] for i, sd in enumerate(("l", "r"))}, frames)
    # The roll out and back, on each hip and against it on its ankle, as each foot steps.
    rolls = {"l": [(0.2, 0.0), (0.45, 0.5), (0.7, 1.0), (5.55, 1.0), (5.8, 0.0)], "r": [(0.7, 0.0), (0.95, 0.5), (1.2, 1.0), (5.05, 1.0), (5.3, 0.0)]}
    for sd, sign in (("l", 1.0), ("r", -1.0)):
        out = lambda t: sign * WIDEN * _lerp_keys(rolls[sd], t)
        tracks["hip_" + sd] = [(t, a2, 0.0, round(out(t), 3)) for t, a2 in tracks["hip_" + sd]]
        tracks["ankle_" + sd] = [(t, c2, 0.0, round(-out(t), 3)) for t, c2 in tracks["ankle_" + sd]]
    for side in ("l", "r"):
        m = lambda pose: pose if side == "l" else (pose[0], -pose[1], -pose[2], pose[3])
        hit, press = (HIT_L, PRESS_L) if side == "l" else (HIT_R, PRESS_R)
        keys = [(1.5, m(WIDE)), (2.05, m(UP))] + _slam(2.05, m(UP), 2.3, hit) + [(2.42, press), (2.56, m(RECOIL)), (2.72, m(LIFT))] + _slam(2.72, m(LIFT), 2.95, hit) + \
               [(3.1, press), (4.1, press), (4.45, m(RECOIL)), (4.9, m((12.0, -34.0, 20.0, 10.0))), (5.4, (0.0, 0.0, 0.0, 0.0))]   # parted level before they drop, clear of the hip cannon
        tracks["shoulder_" + side] = [(t, p2, y2, r2) for t, (p2, y2, r2, e2) in keys]
        tracks["elbow_" + side] = [(t, e2) for t, (p2, y2, r2, e2) in keys]
    tracks["waist"] = [(t, p2, 0.0, 0.0) for t, p2 in [(1.5, 2.0), (2.05, 4.0)] + _slam(2.05, 4.0, 2.3, -6.0) + [(2.5, -4.0), (4.2, -4.0), (5.0, 0.0)]]   # pitch: the waist's own axis is its yaw
    b.act("pound_fists", 6.6, tracks, body=body, heft=0.05,   # the stance widened foot by foot, then the fists wound up and slammed together before the chest, elbows out, twice, stopping dead, pressed, and the feet stepped back in
          glow=[(["core_fire"], [(2.27, 0.0), (2.33, 13.0), (2.6, 4.0), (2.92, 3.0), (2.98, 16.0), (4.1, 9.0), (5.0, 0.0)])])
    tracks, body = _planted(feet, [(1.2, -2.0, 0.0, 7.0), (3.8, -2.2, 0.0, 7.5), (5.2, 0.0, 0.0, 0.0)])
    tracks.update({
        "shoulder_l": [(1.2, 60.0, 60.0, 0.0), (3.8, 62.0, 62.0, 0.0), (5.0, 0.0, 0.0, 0.0)],
        "shoulder_r": [(1.2, 60.0, -60.0, 0.0), (3.8, 62.0, -62.0, 0.0), (5.0, 0.0, 0.0, 0.0)],
        "elbow_l": [(1.2, -20.0), (3.8, -22.0), (5.0, 0.0)],
        "elbow_r": [(1.2, -20.0), (3.8, -22.0), (5.0, 0.0)],
    })
    b.act("roar", 5.6, tracks, body=body,   # the arms flung wide and up, the body rearing back on its planted feet, the core blazing
          glow=[(["core_fire"], [(0.6, 0.0), (1.2, 10.0), (3.8, 10.0), (4.8, 0.0)])])
    # The meteor, angrier: it stamps into a firing stance, leaning in and turned on its mark
    # (the turn the waist's, Ryan, 5 October: the feet slid round under it),
    # the right arm flung clear and the left fist thrust at the target, the tubes snapping up
    # and loading hot, then two shots, each one kicking the tubes and the body.
    tracks, body = _planted(feet, [(0.5, 0.0, -2.6, -4.0), (0.8, 0.0, -2.0, -3.2), (2.4, 0.0, -2.2, -3.5), (2.55, 0.0, -3.4, -2.0), (2.9, 0.0, -2.2, -3.4),
                                   (3.35, 0.0, -3.4, -2.0), (3.7, 0.0, -2.2, -3.4), (4.4, 0.0, -2.0, -3.0), (5.4, 0.0, 0.0, 0.0)])
    tracks.update({
        "waist": [(0.5, -3.0, -16.0, 0.0), (0.8, -2.0, -15.0, 0.0), (2.4, -2.0, -16.0, 0.0), (2.55, 2.0, -15.0, 0.0), (2.9, -2.0, -16.0, 0.0), (3.35, 2.0, -15.0, 0.0),
                  (3.7, -2.0, -16.0, 0.0), (4.4, -1.0, -15.0, 0.0), (5.4, 0.0, 0.0, 0.0)],   # turned on its mark on the waist, the feet planted; each shot kicks it back
        "elev_meteor": [(0.4, 0.0), (0.9, 16.0), (2.4, 15.0), (2.5, 6.0), (2.9, 15.0), (3.35, 6.0), (3.75, 15.0), (4.4, 15.0), (5.1, 0.0)],
        "shoulder_r": [(0.5, 10.0, -50.0, 0.0), (4.4, 12.0, -52.0, 0.0), (5.2, 0.0, 0.0, 0.0)],
        "shoulder_l": [(0.6, 58.0, -14.0, 0.0), (2.4, 60.0, -16.0, 0.0), (2.55, 55.0, -14.0, 0.0), (3.35, 55.0, -14.0, 0.0), (4.4, 58.0, -15.0, 0.0), (5.2, 0.0, 0.0, 0.0)],
        "elbow_l": [(0.6, 10.0), (4.4, 12.0), (5.2, 0.0)],
    })
    b.act("raise_meteor", 5.6, tracks, body=body,
          glow=[(["tube_mouth"], [(0.6, 0.0), (1.0, 5.0), (1.3, 2.0), (1.6, 7.0), (1.9, 3.0), (2.2, 9.0), (2.4, 9.0), (2.5, 14.0), (2.8, 5.0), (3.3, 9.0),
                                  (3.35, 14.0), (3.7, 5.0), (4.6, 0.0)]),
                (["core_fire"], [(0.4, 0.0), (0.8, 6.0), (4.4, 6.0), (5.0, 0.0)])])
    # The shoulders, angrier: hunched forward, each arm wrenched round in a fast circle that
    # cracks at the bottom, the torso twisting with it on the waist (Ryan, 5 October: not the
    # whole machine pivoting on its feet) and the core flaring at each crack; then the chest
    # thrown out on the waist and slammed forward, the fists clenched before it.
    # The ninth notes (Ryan, 6 October: the fists did not hit at all, the same soft): the slam
    # gathers speed all the way into the fists meeting and stops dead (_slam), and the act runs
    # on quick servos (its heft), where the machine's own let every move lag a quarter second.
    # The tenth notes (the same day): the cracks themselves slower, each arm's circle taking
    # over a second and a quarter where it took under nine tenths (the act's quick servos had
    # left them snapping); and the fists meet as in the pound, the elbows out, a little higher
    # again, since the torso slams forward on its waist into this one (the fists at the core,
    # 77 in the torso's frame, the hip cannon at 55).
    HITC_L, HITC_R = (45.0, -71.0, 45.0, -5.0), (45.0, 78.0, -45.0, -8.0)
    PRESSC_L, PRESSC_R = (45.0, -72.0, 45.0, -5.0), (45.0, 78.0, -45.0, -9.0)
    tracks, body = _planted(feet, [(0.4, 0.0, -1.5, -4.0), (1.8, 0.0, -2.2, -4.5), (3.5, 0.0, -2.2, -4.5), (3.95, 0.0, 0.8, 4.0)] + [(t, *v) for t, v in _slam(3.95, (0.0, 0.8, 4.0), 4.35, (0.0, -3.4, -5.0))] +
                            [(5.05, 0.0, -3.0, -4.6), (6.05, 0.0, 0.0, 0.0)])
    tracks.update({
        "waist": [(0.4, -4.0, 0.0, 0.0), (1.8, -6.0, 20.0, 0.0), (3.5, -6.0, -20.0, 0.0), (3.95, 10.0, 0.0, 0.0)] +
                 [(t, *v) for t, v in _slam(3.95, (10.0, 0.0, 0.0), 4.35, (-12.0, 0.0, 0.0))] + [(5.05, -10.0, 0.0, 0.0), (6.05, 0.0, 0.0, 0.0)],
        "shoulder_l": [(0.5, 55.0, 0.0, 0.0), (0.95, 30.0, 48.0, 0.0), (1.4, -45.0, 20.0, 0.0), (1.8, -12.0, 0.0, 0.0), (3.5, -10.0, 0.0, 0.0), (3.95, -48.0, 10.0, 25.0)] +
                      [(t, *v) for t, v in _slam(3.95, (-48.0, 10.0, 25.0), 4.35, HITC_L[:3])] + [(5.05, *PRESSC_L[:3]), (6.05, 0.0, 0.0, 0.0)],
        "shoulder_r": [(1.8, -8.0, 0.0, 0.0), (2.25, 55.0, 0.0, 0.0), (2.7, 30.0, -48.0, 0.0), (3.15, -45.0, -20.0, 0.0), (3.5, -12.0, 0.0, 0.0), (3.95, -48.0, -10.0, -25.0)] +
                      [(t, *v) for t, v in _slam(3.95, (-48.0, -10.0, -25.0), 4.35, HITC_R[:3])] + [(5.05, *PRESSC_R[:3]), (6.05, 0.0, 0.0, 0.0)],
        "elbow_l": [(0.5, 20.0), (1.8, 0.0), (3.95, 10.0)] + _slam(3.95, 10.0, 4.35, HITC_L[3]) + [(5.05, PRESSC_L[3]), (6.05, 0.0)],
        "elbow_r": [(2.25, 20.0), (3.5, 0.0), (3.95, 10.0)] + _slam(3.95, 10.0, 4.35, HITC_R[3]) + [(5.05, PRESSC_R[3]), (6.05, 0.0)],
    })
    b.act("crack_shoulders", 6.4, tracks, body=body, heft=0.07,
          glow=[(["core_fire"], [(1.65, 0.0), (1.8, 7.0), (2.25, 1.0), (3.5, 7.0), (3.95, 3.0), (4.35, 12.0), (5.05, 10.0), (5.95, 0.0)])])
    # Movement (Ryan, 4 October, the third pass: stomp and plod, MechWarrior and not Gundam,
    # no weight thrown side to side): a long heavy stride, each sabaton planted flat while
    # the body passes over it, lifted and stamped down; the arms swinging evenly against the
    # legs, the forearms carried up; the body dropping and nodding onto each foot.
    tracks, body, stride = _plant([
        {"hip": "hip_" + side, "knee": "knee_" + side, "ankle": "ankle_" + side, "at": legs[side], "phase": 0.0 if side == "l" else 0.5}
        for side in ("l", "r")], sweep=30.0, lift=8.0, crouch=0.5, dip=1.8, nod=1.2)
    tracks["shoulder_l"] = (_swing(5.0, 0.5), 0.0)   # a little swing (Ryan, 5 October: less arm movement; the plod is good)
    tracks["shoulder_r"] = (_swing(5.0, 0.0), 0.0)
    b.gait(stride=stride, tracks=tracks, hold={"elbow_l": 9.0, "elbow_r": 9.0}, body=body, ease="linear")
    b.move(accel=1.2, heft=0.24)

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
    # Hip, knee and ankle on both legs (the joint pass, 2 October).
    legs, arms = {}, {}
    for s in (-1.0, 1.0):
        cx = s * 12.0
        side = "l" if s < 0 else "r"
        hip = (cx, -14.0, 34.0)
        knee = (cx + s * 2.0, 2.0, 26.0)
        ankle = (cx + s * 2.0, -10.0, 12.0)
        toe = (cx + s * 2.0, 6.0, 3.0)
        legs[side] = (hip, knee, ankle)
        b.prism("x", hip[0], hip[1], hip[2], 5.0, 9.0, "steel.dark", 6, "hip")
        with b.joint("hip_%s" % side, hip, limits=(-60.0, 60.0)):
            _beam(b, hip, knee, _sq(10.0, 10.0), _sq(8.6, 8.6), "steel.plate", "thigh")
            b.prism("x", knee[0], knee[1], knee[2], 4.8, 10.0, "steel.dark", 6, "knee")
            with b.joint("knee_%s" % side, knee, limits=(-50.0, 65.0)):   # opens far enough to stand it up on two legs (Ryan, 5 October)
                _beam(b, knee, ankle, _sq(8.0, 8.0), _sq(6.8, 6.8), "steel.panel", "shin")
                b.prism("x", ankle[0], ankle[1], ankle[2], 3.8, 9.0, "steel.dark", 6, "ankle")
                with b.joint("ankle_%s" % side, ankle, limits=(-60.0, 75.0)):
                    # A foot that could carry it (Ryan, 5 October: the hind legs could not
                    # support it; heel spurs, a parallel to the three-taloned hands with one
                    # turned back, every claw bigger, the foot flat on the ground): a heavy
                    # pad at the ball, two long toes forward and a spur back, all three lying
                    # on the ground and hooking into it at the tips.
                    _beam(b, ankle, toe, _sq(7.0, 6.0), _sq(9.0, 4.0), "steel.plate", "foot")
                    b.box(toe[0] - 5.0, toe[0] + 5.0, toe[1] - 4.0, toe[1] + 3.0, 0.0, 4.5, "steel.dark", "foot_pad")
                    for tx in (-3.0, 3.0):
                        # Splayed apart a little at the root (Ryan, 5 October, the fifth notes).
                        root = Vector((toe[0] + tx, toe[1] + 2.0, 1.7))
                        ob = _tine(b, tuple(root), 0.0, 4.0, -16.0, 15.0, 4.2, 3.4, "steel.dark", "toe", n=3)
                        ob.matrix_world = Matrix.Translation(root) @ Matrix.Rotation(math.radians(-12.0 if tx > 0 else 12.0), 4, "Z") @ Matrix.Translation(-root) @ ob.matrix_world
                    _tine(b, (toe[0], toe[1] - 3.0, 1.7), 0.0, 176.0, 16.0, 14.0, 4.6, 3.4, "steel.dark", "heel_spur", n=3)
    # The pelvis runs back to carry the Entropy Condenser's twin, the exhaust, and the torso
    # leans forward and low above it.
    b.prism("x", 0.0, -12.0, 36.0, 6.5, 26.0, "steel.panel", 8, "pelvis", phase=math.pi / 8)
    b.box(-8.0, 8.0, -24.0, -12.0, 30.0, 40.0, "steel.dark", "tail_block")
    for z in (32.5, 35.5):   # lit slots on its back, the Nemesis's condenser's (Ryan, 1 October)
        b.box(-6.0, 6.0, -24.8, -24.0, z, z + 1.3, "amber.lit", "tail_slot")
    # The waist (Ryan, 5 October, the fifth notes: walkers turn with a waist, never by
    # sliding their feet round): the torso, the snout, the back and its guns and the upper
    # arms turn and lean on it over the pelvis. The middle arms stay off it: they carry the
    # machine's weight like legs, so they hang from the pelvis's frame.
    waist = b.joint("waist", (0.0, -10.0, 38.0), axis="yaw", limits={"yaw": (-20.0, 20.0), "pitch": (-12.0, 12.0), "roll": (-8.0, 8.0)}, swing=False)
    waist.__enter__()
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
        # Each shoulder cannon elevates along the plate (the joint pass).
        with b.joint("elev_%s" % ("l" if s < 0 else "r"), tuple(gun), limits=(-12.0, 18.0)):
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
        side = "l" if s < 0 else "r"
        shoulder = (s * 19.0, 6.0, 50.0)
        elbow = (s * 30.0, 22.0, 56.0)
        wrist = (s * 30.0, 38.0, 42.0)
        b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.6, 8.0, "steel.dark", 6, "shoulder")
        # The upper arm swings from the shoulder, bends at the elbow, and the hand turns at
        # the wrist (the joint pass, 2 October); each of its three talons on a joint of its
        # own (Ryan, 5 October: flexed together they waved; they should grip, the Badger's
        # way), out, mid and in across the hand.
        with b.joint("shoulder_%s" % side, shoulder, limits={"pitch": (-45.0, 50.0), "yaw": (-40.0, 40.0)}):
            _beam(b, shoulder, elbow, _sq(8.4, 8.4), _sq(7.2, 7.2), "steel.plate", "upper_arm")
            b.prism("x", elbow[0], elbow[1], elbow[2], 4.4, 9.0, "steel.dark", 6, "elbow")
            with b.joint("elbow_%s" % side, elbow, limits=(-60.0, 64.0)):   # opens far enough to straighten the arm (Ryan, 6 October, the eleventh notes: the strike all the way out)
                _beam(b, elbow, wrist, _sq(7.2, 7.2), _sq(6.4, 6.4), "steel.panel", "forearm")
                b.prism("x", wrist[0], wrist[1], wrist[2], 3.2, 8.0, "steel.dark", 6, "wrist")
                with b.joint("hand_%s" % side, wrist, limits=(-55.0, 25.0)):
                    for tx, which in ((-3.5 * s, "in"), (0.0, "mid"), (3.5 * s, "out")):
                        root = (wrist[0] + tx, wrist[1] + 1.0, wrist[2] - 2.0)
                        with b.joint("talon_%s_%s" % (side, which), root, limits=(-80.0, 50.0)):   # positive opens it, the tip forward and out; it folds far past a hand's natural curl (Ryan, 6 October, the eighth notes: unnaturally so)
                            _tine(b, root, 0.0, -60.0, -50.0, 13.0, 3.2, 2.4, "steel.dark", "talon", n=2)
    waist.__exit__(None, None, None)
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        # The planted lower pair: shoulder, elbow and a wrist, legs in all but name (they
        # never swing on a blow); the wrist keeps the talons flat on the ground whatever
        # the arm does (Ryan, 5 October, the fifth notes: they dug in as it sank and walked).
        shoulder = (s * 14.0, 2.0, 40.0)
        elbow = (s * 26.0, 14.0, 26.0)
        wrist = (s * 24.0, 26.0, 6.0)
        arms[side] = (shoulder, elbow, wrist)
        b.prism("x", shoulder[0], shoulder[1], shoulder[2], 4.4, 8.0, "steel.dark", 6, "lower_shoulder")
        with b.joint("shoulder_low_%s" % side, shoulder, limits=(-40.0, 60.0), swing=False):
            _beam(b, shoulder, elbow, _sq(8.8, 8.8), _sq(7.6, 7.6), "steel.plate", "lower_upper_arm")
            b.prism("x", elbow[0], elbow[1], elbow[2], 4.6, 9.0, "steel.dark", 6, "lower_elbow")
            with b.joint("elbow_low_%s" % side, elbow, limits=(-110.0, 35.0)):
                _beam(b, elbow, wrist, _sq(7.6, 7.6), _sq(6.8, 6.8), "steel.panel", "lower_forearm")
                b.prism("x", wrist[0], wrist[1], wrist[2], 3.4, 8.0, "steel.dark", 6, "lower_wrist")
                with b.joint("hand_low_%s" % side, wrist, limits=(-40.0, 90.0)):
                    # Each talon on a joint of its own, as the upper hands' (Ryan, 5 October, the
                    # sixth notes: do the middle fingers waggle too?); flat on the ground at rest.
                    for tx, which in ((-4.0 * s, "in"), (0.0, "mid"), (4.0 * s, "out")):
                        root = (wrist[0] + tx, wrist[1] + 1.0, wrist[2] - 1.0)
                        with b.joint("talon_low_%s_%s" % (side, which), root, limits=(-40.0, 50.0)):
                            _tine(b, root, 0.0, -30.0 - abs(tx) * 2.0, 20.0, 10.0, 3.2, 2.4, "steel.dark", "talon", n=2)

    # Idle acts, third pass (Ryan, 4 October: some stilted, the weight thrown side to side;
    # heavy, with inertia): curves a part runs on through, the servos' heft (b.move), held
    # poses that drift, the talons working in slower beats, and the hind feet planted while
    # the body rears over them (_planted). Degrees and seconds; a key is (t, value) on the
    # joint's own axis or (t, pitch, yaw, roll); a body key is (t, dx, dy, dz) or (t, dx, dy,
    # dz, yaw, pitch, roll); a glow key is (t, k), k the light added over rest.
    # Fourth pass (Ryan, 5 October): the rear as a rise onto two legs, ready to fight, not a
    # horse rearing; the talons gripping each on its own; raise_cannons pivoting on the hips
    # with the middle hands planted further forward; pilot_flame and stalk dropped (a worse
    # raise_cannons, and awkward), a threat display in their place.
    hind = {side: {"hip": "hip_" + side, "knee": "knee_" + side, "ankle": "ankle_" + side, "at": legs[side]} for side in ("l", "r")}
    mid_arms = {side: {"hip": "shoulder_low_" + side, "knee": "elbow_low_" + side, "ankle": "hand_low_" + side, "at": arms[side]} for side in ("l", "r")}

    def drum(side, t0, rounds, spread, end):
        """Keys for one hand's talons drummed (Ryan, 5 October, the fifth notes: show off the
        fingers): each curls and opens again in turn, out to in, `rounds` times from t0; then
        all spread wide at `spread`, grip hard and rest by `end`."""
        out_yaw = 22.0 if side == "l" else -22.0
        keys = {w: [(t0, 10.0, 0.0, 0.0)] for w in ("out", "mid", "in")}
        for r in range(rounds):
            for k, w in enumerate(("out", "mid", "in")):
                t = t0 + 0.2 + r * 0.75 + k * 0.16
                keys[w] += [(round(t, 3), -34.0, 0.0, 0.0), (round(t + 0.3, 3), 26.0, 0.0, 0.0)]
        for k, w in enumerate(("out", "mid", "in")):
            keys[w] += [(round(spread + 0.07 * k, 3), (48.0, 44.0, 38.0)[k], (out_yaw, 0.0, -out_yaw * 0.4)[k], 0.0), (round(spread + 0.55, 3), -38.0, 0.0, 0.0),
                        (round(spread + 0.9, 3), -36.0, 0.0, 0.0), (end, 0.0, 0.0, 0.0)]
        return {"talon_%s_%s" % (side, w): v for w, v in keys.items()}

    # The rise: the legs straighten under it and the hips carry the body up and back over
    # the feet, the snout still level; the upper pair high and spread (Goro, Machamp) and the
    # middle pair out wide and low, an X of arms (Ryan, 5 October, the fifth notes). Up there
    # it slashes twice toward its centre, the two left arms together and then the two right
    # (the eighth notes). The ninth (Ryan, 6 October: not vicious, not even close; a lame little
    # flailing, not a practice mauling): each pair cocks right back, the upper claw high and
    # out over the shoulder with the talons spread, the middle claw out wide and back, and
    # rakes down and across past its centre in a fifth of a second, gathering speed all the way
    # and stopping dead at the end of the cut (_slam), the talons snapping shut through it, the
    # body lunging into it and the throat flaring; it holds there a beat, quivering, and is
    # flung back up. Quick servos for the act (its heft): the machine's own, a fifth of a
    # second, smeared a slash of that speed into a wave. No new joints: the shoulder's own
    # range carries the arc. The tenth notes (Ryan, 6 October): the two cuts closer together,
    # the right pair cocking back as the left pair cuts and landing six tenths of a second
    # after it, a one-two; and the waist into each, the torso wound the other way as a pair
    # cocks and slammed round with the cut, toward the side the claws rake to.
    W1, W2 = 2.1, 2.7   # each side's cut lands this long after the rise begins
    rise = (-2.0, 11.0, 3.0)
    tracks, body = _steps(hind, [(1.4, rise, {}), (round(W1 - 0.32, 3), (-2.2, 11.4, 1.5), {}), (W1, (-0.8, 9.6, 7.5), {}), (round(W2 - 0.3, 3), (-1.6, 10.8, 3.5), {}),
                                 (W2, (-0.8, 9.6, 7.5), {}), (round(W2 + 0.45, 3), (-1.0, 9.9, 6.8), {}), (round(W2 + 0.85, 3), rise, {}), (4.3, (-2.2, 11.6, 3.4), {}), (5.6, (0.0, 0.0, 0.0), {})])
    tracks["waist"] = [(1.3, 0.0, 0.0, 0.0), (1.55, 0.0, 8.0, 0.0), (1.9, 0.0, 8.0, 0.0)] + [(tt, *v) for tt, v in _slam(1.9, (0.0, 8.0, 0.0), W1, (0.0, -14.0, 0.0))] + \
        [(round(W1 + 0.1, 3), 0.0, -14.0, 0.0), (round(W2 - 0.2, 3), 0.0, -8.0, 0.0)] + [(tt, *v) for tt, v in _slam(round(W2 - 0.2, 3), (0.0, -8.0, 0.0), W2, (0.0, 14.0, 0.0))] + \
        [(round(W2 + 0.45, 3), 0.0, 12.0, 0.0), (round(W2 + 0.9, 3), 0.0, 0.0, 0.0)]
    for side, y, t in (("l", 1.0, W1), ("r", -1.0, W2)):
        # y turns the yaw (and the middle arm's roll) outward on this side; t the cut's end
        out_yaw = 22.0 * y
        X, Xl = (45.0, 26.0 * y, 0.0), (6.0, 0.0, 44.0 * y)
        COCK, CUT, PAST = (50.0, 40.0 * y, 0.0), (2.0, -36.0 * y, 0.0), (-2.0, -38.0 * y, 0.0)   # the cut ends above the middle claw raking under it
        COCKl, CUTl = (-12.0, 0.0, 58.0 * y), (30.0, 0.0, -18.0 * y)
        c0 = round(t - 0.55, 3)   # cocked back by here
        s0 = round(t - 0.2, 3)    # the cut begins
        flat = lambda ks: [(tt, *v) for tt, v in ks]
        tracks.update({
            "shoulder_" + side: flat([(1.2, X), (round(c0 - 0.25, 3), X), (c0, COCK), (s0, COCK)] + _slam(s0, COCK, t, CUT) + [(round(t + 0.12, 3), PAST), (round(t + 0.45, 3), CUT),
                                      (round(t + 0.85, 3), X), (4.3, X), (5.4, (0.0, 0.0, 0.0))]),   # within the shoulder's own range, raised to 50 at most
            "elbow_" + side: [(1.2, 18.0), (round(c0 - 0.25, 3), 18.0), (c0, 30.0), (s0, 30.0)] + _slam(s0, 30.0, t, -8.0) + [(round(t + 0.45, 3), -6.0), (round(t + 0.85, 3), 18.0), (4.3, 20.0), (5.4, 0.0)],
            "hand_" + side: [(1.2, -20.0), (round(c0 - 0.25, 3), -20.0), (c0, 24.0), (s0, 24.0)] + _slam(s0, 24.0, t, -50.0) + [(round(t + 0.45, 3), -46.0), (round(t + 0.85, 3), -20.0), (4.3, -22.0), (5.4, 0.0)],
            "shoulder_low_" + side: flat([(1.3, Xl), (round(c0 - 0.25, 3), Xl), (c0, COCKl), (s0, COCKl)] + _slam(s0, COCKl, t, CUTl) + [(round(t + 0.45, 3), (28.0, 0.0, -16.0 * y)),
                                          (round(t + 0.85, 3), Xl), (4.3, (7.0, 0.0, 46.0 * y)), (5.5, (0.0, 0.0, 0.0))]),
            "elbow_low_" + side: [(1.3, 18.0), (round(c0 - 0.25, 3), 18.0), (c0, 32.0), (s0, 32.0)] + _slam(s0, 32.0, t, 2.0) + [(round(t + 0.45, 3), 4.0), (round(t + 0.85, 3), 18.0), (4.3, 19.0), (5.5, 0.0)],
            "hand_low_" + side: [(1.3, 24.0), (round(c0 - 0.25, 3), 24.0), (c0, 40.0), (s0, 40.0)] + _slam(s0, 40.0, t, 4.0) + [(round(t + 0.45, 3), 6.0), (round(t + 0.85, 3), 24.0), (4.3, 26.0), (5.5, 0.0)],
        })
        for k, w in enumerate(("out", "mid", "in")):
            spread = ((48.0, out_yaw), (44.0, 0.0), (38.0, -out_yaw * 0.4))[k]
            shut = round(t - 0.06 + 0.02 * k, 3)
            tracks["talon_%s_%s" % (side, w)] = [(1.2, 10.0, 0.0, 0.0), (c0, spread[0], spread[1], 0.0), (round(s0 + 0.05, 3), spread[0], spread[1], 0.0),
                                                 (shut, -40.0, 0.0, 0.0), (round(t + 0.5, 3), -38.0, 0.0, 0.0), (round(t + 0.85, 3), 10.0, 0.0, 0.0),
                                                 (4.0, -36.0, 0.0, 0.0), (4.4, -36.0, 0.0, 0.0), (5.2, 0.0, 0.0, 0.0)]
            tracks["talon_low_%s_%s" % (side, w)] = [(c0, 0.0, 0.0, 0.0), (round(s0 + 0.03, 3), 36.0, 0.0, 0.0), (shut, -36.0, 0.0, 0.0), (round(t + 0.5, 3), -34.0, 0.0, 0.0),
                                                     (round(t + 0.85, 3), 0.0, 0.0, 0.0)]
    b.act("rear", 6.0, tracks, body=body, heft=0.05,
          glow=[(["throat_slot", "eye_strip"], [(W1 - 0.15, 0.0), (W1 + 0.02, 12.0), (W1 + 0.3, 5.0), (W2 - 0.05, 4.0), (W2 + 0.02, 13.0), (W2 + 0.7, 3.0), (4.6, 0.0)])])
    # The talons shown off (Ryan, 5 October, the fifth notes: the fingers more, the wave
    # less, the middle pair in it, and no turning on the feet): the torso turns on its waist
    # to one hand as it comes up before the snout, wrist cocked, and holds there while its
    # talons drum in turn, spread wide and grip; the middle hand on that side taps its claws
    # on the ground. Then the other side.
    tracks = {
        "waist": [(0.9, -3.0, 10.0, 0.0), (3.6, -3.0, 11.0, 0.0), (4.4, -3.0, -10.0, 0.0), (7.0, -3.0, -11.0, 0.0), (7.8, 0.0, 0.0, 0.0)],
        "shoulder_l": [(0.9, 14.0, -34.0, 0.0), (3.4, 15.0, -35.0, 0.0), (4.1, 0.0, 0.0, 0.0)],
        "elbow_l": [(0.9, 22.0), (3.4, 23.0), (4.1, 0.0)],
        "hand_l": [(1.0, 22.0), (3.4, 23.0), (4.1, 0.0)],
        "shoulder_r": [(3.6, 0.0, 0.0, 0.0), (4.4, 14.0, 34.0, 0.0), (6.9, 15.0, 35.0, 0.0), (7.6, 0.0, 0.0, 0.0)],
        "elbow_r": [(3.6, 0.0), (4.4, 22.0), (6.9, 23.0), (7.6, 0.0)],
        "hand_r": [(3.7, 0.0), (4.5, 22.0), (6.9, 23.0), (7.6, 0.0)],
        "hand_low_l": [(1.0, 0.0), (1.2, 18.0), (1.4, 0.0), (1.6, 18.0), (1.8, 0.0), (2.4, 0.0), (2.6, 18.0), (2.8, 0.0)],
        "hand_low_r": [(4.5, 0.0), (4.7, 18.0), (4.9, 0.0), (5.1, 18.0), (5.3, 0.0), (5.9, 0.0), (6.1, 18.0), (6.3, 0.0)],
    }
    tracks.update(drum("l", 0.9, 2, 2.6, 3.9))
    tracks.update(drum("r", 4.4, 2, 6.1, 7.4))
    b.act("flex_talons", 8.0, tracks)
    # Raise the cannons on the hips: the middle hands step forward one and then the other,
    # the body pitches down over the hind feet and sinks low between its hands, and the
    # cannons come up along the back to bear. Held long, brooding, the talons folded tight
    # (the seventh notes), the body settling lower by a hair as it waits.
    REACH, LIFT = 8.0, 5.0
    low = lambda side, f, z=0.0: (arms[side][2][1] + REACH * f, arms[side][2][2] + z)
    S0, A, B, C, S3, S4 = (0.0, 0.0, 0.0), (0.0, -4.5, -6.5), (0.5, -5.5, -7.5), (1.0, -6.2, -8.2), (1.5, -7.0, -9.0), (1.6, -7.4, -9.4)
    mixb = lambda a, c, u: tuple(a[i] + (c[i] - a[i]) * u for i in range(3))
    step = lambda t0, t1, side, f0, f1, b0, b1: [(round(t0 + (t1 - t0) * 0.35, 3), mixb(b0, b1, 0.35), {side: low(side, f0 + (f1 - f0) * 0.2, LIFT)}),
                                                 (round(t0 + (t1 - t0) * 0.7, 3), mixb(b0, b1, 0.7), {side: low(side, f0 + (f1 - f0) * 0.8, LIFT)}),
                                                 (t1, b1, {side: low(side, f1)})]
    frames = [(0.3, S0, {}), (0.6, mixb(S0, A, 0.5), {}), (0.9, A, {})]
    frames += step(0.9, 1.5, "l", 0.0, 1.0, A, B) + step(1.5, 2.1, "r", 0.0, 1.0, B, C)
    frames += [(2.6, S3, {}), (6.6, S4, {}), (7.0, C, {})]
    frames += step(7.0, 7.6, "r", 1.0, 0.0, C, B) + step(7.6, 8.2, "l", 1.0, 0.0, B, A)
    frames += [(8.6, mixb(A, S0, 0.6), {}), (9.0, S0, {})]
    tracks, body = _steps({**hind, **{"low_" + k: v for k, v in mid_arms.items()}},
                          [(t, pose, {"low_" + k: v for k, v in feet.items()}) for t, pose, feet in frames])
    tracks.update({"elev_l": [(2.2, 0.0), (3.0, 18.0), (6.4, 17.5), (7.1, 0.0)], "elev_r": [(2.4, 0.0), (3.2, 18.0), (6.5, 17.5), (7.2, 0.0)]})
    # The upper arms fold in against the chest as the guns come up, a mantis's, the talons
    # gripping (Ryan, 5 October, the fifth notes: not so static); carried higher and further
    # in, so the folded claws clear the middle arms' elbows as the body pitches down (the
    # sixth notes; measured, no talon inside a middle arm through the act).
    for side, y in (("l", -1.0), ("r", 1.0)):
        tracks.update({"shoulder_" + side: [(2.0, 0.0, 0.0, 0.0), (2.8, 38.0, 16.0 * y, 0.0), (6.6, 39.0, 17.0 * y, 0.0), (7.5, 0.0, 0.0, 0.0)],
                       "elbow_" + side: [(2.0, 0.0), (2.8, -28.0), (6.6, -30.0), (7.5, 0.0)],
                       "hand_" + side: [(2.2, 0.0), (2.9, -52.0), (6.6, -54.0), (7.5, 0.0)]})
        # The talons curled far past a hand's own curl, the tips folded back under the palm
        # (Ryan, 6 October, the eighth notes: even more, unnaturally so), one after another.
        tracks.update({"talon_%s_%s" % (side, w): [(2.4 + 0.12 * k, 0.0, 0.0, 0.0), (3.1 + 0.12 * k, -74.0, 0.0, 0.0), (6.6, -76.0, 0.0, 0.0), (7.4, 0.0, 0.0, 0.0)]
                       for k, w in enumerate(("out", "mid", "in"))})
    b.act("raise_cannons", 9.2, tracks, body=body,
          glow=[(["carbine_tip", "pilot_flame"], [(2.4, 0.0), (3.0, 8.0), (6.4, 8.0), (7.1, 0.0)])])
    # The threat: the snout drops, the throat vent breathes out its heat, long and hot, and the
    # upper claws strike in a one-two (Ryan, 6 October, the ninth notes): each cocked back
    # with its talons spread, the middle one hung low beneath them ready to grab, thrusts out
    # at the mark and snaps shut as it arrives, the two outer talons closing down and the
    # middle one swinging up to meet them; the second thrusts as the first is snapping. The
    # tenth notes (the same day): a snake's bite, out, snap and straight back, each claw
    # whipped back to its guard the moment it has snapped, its talons opening again there,
    # the body jabbing forward into each strike. The thrusts and snaps gather speed and stop
    # dead (_slam) on quick servos (the act's heft).
    tracks, body = _steps({**hind, **{"low_" + k: v for k, v in mid_arms.items()}},
                          [(1.0, (0.0, -3.0, -6.0), {}), (1.3, (-0.6, -3.0, -5.6), {}), (1.55, (1.6, -3.2, -7.0), {}), (1.7, (0.2, -3.0, -6.2), {}),
                           (1.85, (1.6, -3.2, -7.0), {}), (2.15, (0.0, -3.2, -6.3), {}), (3.0, (0.0, -3.4, -6.6), {}), (4.0, (0.0, 0.0, 0.0), {})])
    flat = lambda ks: [(tt, *v) for tt, v in ks]
    for side, y, t in (("l", 1.0, 1.55), ("r", -1.0, 1.85)):
        # y turns the yaw outward on this side; t the thrust's arrival
        GUARD, THRUST, BACK = (30.0, 16.0 * y, 0.0), (-12.0, -22.0 * y, 0.0), (33.0, 20.0 * y, 0.0)
        # The eleventh notes (Ryan: the arms can extend all the way): the strike straightens the
        # arm to within five degrees, the elbow opening and turning out to line the forearm up
        # with the upper arm (a pitch hinge alone left it bent a third of a right angle, since
        # the upper arm angles out), the talons about fifty units out at the shoulder's height.
        E_GUARD, E_THRUST, E_BACK = (-24.0, 0.0, 0.0), (64.0, 30.0 * y, 0.0), (-28.0, 0.0, 0.0)
        t0 = round(t - 0.24, 3)
        back, home = round(t + 0.27, 3), round(t + 0.53, 3)   # whipped back past its guard, and settled there
        tracks.update({
            "shoulder_" + side: flat([(0.9, GUARD), (t0, GUARD)] + _slam(t0, GUARD, t, THRUST) + [(round(t + 0.08, 3), THRUST), (back, BACK), (home, GUARD), (2.9, GUARD), (3.8, (0.0, 0.0, 0.0))]),
            "elbow_" + side: flat([(0.9, (-22.0, 0.0, 0.0)), (t0, E_GUARD)] + _slam(t0, E_GUARD, t, E_THRUST) + [(round(t + 0.08, 3), E_THRUST), (back, E_BACK), (home, E_GUARD), (2.9, (-23.0, 0.0, 0.0)), (3.8, (0.0, 0.0, 0.0))]),
            "hand_" + side: [(0.9, -8.0), (t0, -10.0)] + _slam(t0, -10.0, t, 6.0) + [(round(t + 0.08, 3), 6.0), (back, -12.0), (home, -10.0), (2.9, -9.0), (3.8, 0.0)],
        })
        snap = round(t + 0.03, 3)
        for w, (pitch, yaw) in (("out", (44.0, 22.0 * y)), ("mid", (-40.0, 0.0)), ("in", (36.0, -8.8 * y))):
            shut = -12.0   # the outer two close down to it and the middle one comes up to it
            tracks["talon_%s_%s" % (side, w)] = [(0.4, 0.0, 0.0, 0.0), (0.9, pitch, yaw, 0.0), (round(t - 0.06, 3), pitch, yaw, 0.0)] + \
                [(tt, *v) for tt, v in _slam(round(t - 0.06, 3), (pitch, yaw, 0.0), snap, (shut, 0.0, 0.0))] + \
                [(back, shut, 0.0, 0.0), (round(home + 0.15, 3), pitch, yaw, 0.0), (2.9, pitch * 0.9, yaw * 0.9, 0.0), (3.7, 0.0, 0.0, 0.0)]
    b.act("threat", 4.4, tracks, body=body, heft=0.05,
          glow=[(["throat_slot", "eye_strip"], [(0.6, 0.0), (1.2, 6.0), (1.58, 11.0), (1.88, 12.0), (2.5, 10.0), (2.9, 3.0), (3.7, 0.0)])])
    # Movement (Ryan, 4 October, the third pass: stomp and plod, no weight thrown side to
    # side): a four-limbed gait, every foot and talon planted while the body passes over it,
    # the lower arms reaching from further back under the chest; the upper arms held up out
    # of the way. Out of step (Ryan, 5 October: more insect than mammal, not in pairs), and
    # the arms and the legs at different speeds (the fifth notes, judged as an option; the
    # sixth: that is the walk, "we need that for reasons"): the hands take three short steps
    # to the legs' two over a cycle two strides long, each pair still half a step apart, so
    # the ripple drifts through the cycle and never repeats inside it; a hand's stance is two
    # thirds of a leg's. Slicker than the other walkers, but with a little bump (the sixth):
    # the body drops onto each landing and the snout nods with it.
    limbs = []
    for side in ("l", "r"):
        limbs.append({"hip": "hip_" + side, "knee": "knee_" + side, "ankle": "ankle_" + side, "at": legs[side],
                      "phase": 0.0 if side == "l" else 0.5, "cycles": 2})
        limbs.append({"hip": "shoulder_low_" + side, "knee": "elbow_low_" + side, "ankle": "hand_low_" + side, "at": arms[side],
                      "phase": 0.25 if side == "r" else 0.75, "shift": -12.0, "cycles": 3})
    tracks, body, stride = _plant(limbs, sweep=60.0, lift=8.0, crouch=0.5, dip=1.5, nod=0.9, n=120)
    b.gait(stride=stride, tracks=tracks, hold={"shoulder_l": 12.0, "shoulder_r": 12.0}, body=body, ease="linear")
    b.move(accel=1.0, heft=0.2)

ammit.maker = "arsenal"


# ---------------------------------------------------------------- the hovercraft (2 October)
# Propulsion reads the maker (Ryan, 2 October): Aphelion's hovers and aircraft are aquatic,
# so the Stingray rides on lift fans sunk flush in its wings and pitches to move; Kestrel
# moves everything on big boosters, so the Puffin is thrust-borne, no skirt and no fan.
# The exposed-rotor fan-copter (the Banshee register) is kept free for a later Aphelion
# flyer; a W&S flyer would be a traditional helicopter profile. Both float: nothing of
# either touches z = 0, the ground.

def _oct(cz, w, h, cx=0.0, n=8):
    """An `n`-sided section as (x, z) points, `w` across and `h` tall, flat on top: a round
    body or a bell. Twelve sides for a chrome body, so no one flank facet mirrors the whole sky
    (the Puffin's second pass showed a white patch where one did)."""
    return [(cx + w / 2 * math.cos(math.pi / n + i * 2 * math.pi / n), cz + h / 2 * math.sin(math.pi / n + i * 2 * math.pi / n)) for i in range(n)]


def _wing_section(x, y_back, y_front, z_bottom, z_top, shoulder):
    """A flat-topped six-point section in the y-z plane at `x`, for a lofted wing disc: a
    point back and front at mid-height, a plateau `shoulder` in from each end."""
    zm = (z_bottom + z_top) / 2.0
    return [(x, y_back, zm), (x, y_back + shoulder, z_top), (x, y_front - shoulder, z_top),
            (x, y_front, zm), (x, y_front - shoulder, z_bottom), (x, y_back + shoulder, z_bottom)]


def _lift_fan(b, targets, cx, cy, z0, z1, r=8.6, blades=5, joint=None, hand=1.0):
    """A ducted lift fan sunk flush through a wing: a hole cut right through the wing, a
    shallow duct lining its mouth with the rim just proud of the skin, a glow at the duct's
    floor (the downwash, lit) a few units under the rim, a dark hub and wide pitched blades
    just below the mouth. Shallow on purpose: from the hangar's angle a deep duct showed its
    wall and nothing else, so the floor sits at `z1 - 3.5` and the blades over it, and the
    hole below it is open to the underside, never seen from above. `joint` names a joint for
    the hub, cap and blades, turning about up, so the rotor can spin (b.spin). `hand` -1
    mirrors the blades' pitch, for a rotor turning the other way (Ryan, 6 October, the eighth
    notes: the starboard fan's blades were pitched for the port fan's spin)."""
    b.cut(targets, (cx, cy, z0 - 2.0), (cx, cy, z1 + 2.0), r, 12)
    zfloor = z1 - 3.6
    _tube(b, (cx, cy, zfloor), (cx, cy, z1), r + 0.5, r - 0.8, 12, "steel.dark", "fan_duct", floor_material="amber.glow", floor_depth=0.4)
    zf = z1 - 1.9
    rotor = b.joint(joint, (cx, cy, zf), axis="yaw") if joint else None
    if rotor:
        rotor.__enter__()
    b.prism("z", cx, cy, zf, 2.0, 2.6, "steel.dark", 8, "fan_hub")
    b.prism("z", cx, cy, zf + 1.4, 1.2, 0.6, "steel.plate", 8, "hub_cap")
    ri, ro = 2.0, r - 1.1
    for k in range(blades):
        a = k * 2.0 * math.pi / blades
        di, do = 0.7 * hand, 0.3 * hand
        il = (cx + ri * math.cos(a - di), cy + ri * math.sin(a - di), zf + 0.5)
        it = (cx + ri * math.cos(a + di), cy + ri * math.sin(a + di), zf - 0.5)
        ot = (cx + ro * math.cos(a + do), cy + ro * math.sin(a + do), zf - 0.9)
        ol = (cx + ro * math.cos(a - do), cy + ro * math.sin(a - do), zf + 0.9)
        quad = [il, it, ot, ol] if hand > 0 else [ol, ot, it, il]   # a mirrored blade wound back the other way, its faces still outward
        _rings(b, [quad, [(p[0], p[1], p[2] - 0.45) for p in quad]], "steel.dark", "fan_blade")
    if rotor:
        rotor.__exit__(None, None, None)


# The Stingray's skin, as a function, so every part sits on it (Ryan, 2 October, on the first
# pass: most of the mounts floated, and a livery spot floated ahead of the cockpit). The body
# is a loft of flattened hexagons along y; each wing a loft of flat-topped six-point sections
# along x. `_ray_top(x, y)` is the higher of the two skins at a point, or None off the machine.
_RAY_BODY = [(44.0, 12.0, 4.0, 3.0), (36.0, 13.0, 14.0, 9.0), (20.0, 14.0, 22.0, 16.0), (0.0, 14.0, 24.0, 18.0),
             (-20.0, 14.0, 22.0, 15.0), (-34.0, 14.5, 17.4, 10.0)]   # (y, cz, w, h), nose to stern; the body ends at the wings' trailing edge and the tail tapers on from the last
_RAY_WING = [(9.0, -34.0, 38.0, 6.5, 21.5, 16.0), (22.0, -24.0, 30.0, 8.0, 19.0, 12.0), (36.0, -12.0, 8.0, 12.5, 15.5, 4.0)]   # (x, y_back, y_front, z_bottom, z_top, shoulder)


def _ray_body_top(x, y):
    rows = _RAY_BODY
    if y > rows[0][0] or y < rows[-1][0]:
        return None
    for (y0, cz0, w0, h0), (y1, cz1, w1, h1) in zip(rows, rows[1:]):
        if y1 <= y <= y0:
            t = (y0 - y) / (y0 - y1)
            cz, w, h = cz0 + (cz1 - cz0) * t, w0 + (w1 - w0) * t, h0 + (h1 - h0) * t
            ax = abs(x)
            if ax > w / 2.0:
                return None
            if ax <= w / 4.0:
                return cz + h / 2.0
            return cz + h / 2.0 * (1.0 - (ax - w / 4.0) / (w / 4.0))
    return None


def _ray_wing_top(x, y):
    ax = abs(x)
    rows = _RAY_WING
    if ax < rows[0][0] or ax > rows[-1][0]:
        return None
    for r0, r1 in zip(rows, rows[1:]):
        if r0[0] <= ax <= r1[0]:
            t = (ax - r0[0]) / (r1[0] - r0[0])
            yb, yf, zb, zt, sh = [a + (c - a) * t for a, c in zip(r0[1:], r1[1:])]
            if y < yb or y > yf:
                return None
            zm = (zb + zt) / 2.0
            if y < yb + sh:
                return zm + (zt - zm) * (y - yb) / sh
            if y > yf - sh:
                return zm + (zt - zm) * (yf - y) / sh
            return zt
    return None


def _ray_top(x, y):
    tops = [t for t in (_ray_body_top(x, y), _ray_wing_top(x, y)) if t is not None]
    return max(tops) if tops else None


def _seat(b, top, cx, cy, w, d, h, material, label, sink=1.5):
    """A mount box standing on a skin: its foot sunk `sink` into the surface at its centre, its
    top `h` above it. Returns the top's z, for what stands on the mount."""
    z = top(cx, cy)
    b.box(cx - w / 2.0, cx + w / 2.0, cy - d / 2.0, cy + d / 2.0, z - sink, z + h, material, label)
    return z + h


def _ridge(b, top, x, y0, y1, w, lift, sink, material, label, step=6.0):
    """A stripe lying along a skin: a loft of thin rectangles from `y0` to `y1`, each at the
    surface's own height, so it follows the hull instead of floating over the low parts."""
    secs = []
    y = y0
    while True:
        z = top(x, y)
        secs.append((y, rect(x, w, z - sink, z + lift)))
        if y >= y1 - 1e-6:
            break
        y = min(y + step, y1)
    b.loft(secs, material, label)


def stingray(b):
    """Aphelion "Stingray" (Perigee Flight 4 Strike Skimmer): the second Aphelion machine, a
    hovercraft that runs hot (Ryan, 2 October; Lionfish and Sea Wasp were the other names).
    A flat lens of a pearl hull: a central body with a slit canopy and one red eye, two
    wing discs lofted out of its flanks, their outer thirds in red (the markings), a ducted
    lift fan sunk flush through each wing where it is thickest, and the Photosphere Lance
    (fixed, no pin) under the nose where a ray's mouth is. Second pass (Ryan, 2 October: too
    literal, it needs no whippy tail; the mounts floated; a livery spot floated ahead of the
    cockpit): no tail; every mount, the canopy, the eye and the spine stripe are seated on
    the skin through `_ray_top`; the nose chevron is gone. Third pass (Ryan, 2 October, late: the
    centre turret is the focal point and read as a gun slapped on a jeep, not a high-tech
    Aphelion machine; the rear mounts still janky; the stern's two glowing slabs served no
    purpose): the turret is a wide low dome faired to the crown with the Zenith Emitter
    leaving a slot in its forward edge; the rear mounts went under the wings. Fourth pass
    (Ryan, 3 October): the under-wing pods move to the forewings and poke out of the wing's
    lower front surface; the turret's pin sits back inside the dome; the shoulder mounts are
    lower and set back; the tail itself is the exhaust. Fifth pass (Ryan, 3 October, on the
    fourth): the turret's pin back and down into the dome a touch more, and the dome taller
    so the emitter clears the canopy; the tail back to the tapering shape, the body's pearl
    running to the end and the grey one thin rim at the mouth, the one wide open exhaust
    kept; and two of the front mounts to the wing tips, since the front carried too many.
    Sixth pass (Ryan, 3 October, almost perfect): the tail thinner and shorter, the third
    pass's shape, a few units of taper to a mouth two thirds the stern's width.
    Ryan picked the shoulder pods at the tips (3 October, night), so the deck keeps the dome
    alone and the forewing pods stay. Seventh pass (the same night): the tail narrows in one
    quick stage from the stern to the mouth, the exhaust itself kept. Mounts, in the die's
    order: hp_1 (the Solar Flare Array, two pods) at the left wing tip and hp_2 (the Pulse
    Repeater) at the right, hp_3 the dome (the Zenith Emitter), hp_4 (the Aurora Lattice, a
    dish) out of the right forewing's underside and hp_5 bare out of the left (the Radiator
    Sail is a vent and shows nowhere). Eighth pass (Ryan, 5 October): the tail still read as two
    stages, the body running on behind the wings as a near-parallel neck before the taper, so
    the body ends at the wings' trailing edge and the tail is one straight taper from there.
    Ninth pass (the same day): the taper's rate kept, the tail four units longer to a smaller
    tip, the mouth half again narrower. Tenth (the same day): the flare pods at the left tip
    point forward like every other gun, stacked over the tip, and the exhaust's hot face sits
    a unit inside the mouth.
    Floats: the belly at z = 6. Every number is a proportion Ryan may change."""
    top = _ray_top
    # The body: a flattened hexagonal section lofted nose to stern, widest amidships.
    b.loft([(y, hexagon(0.0, cz, w, h)) for (y, cz, w, h) in _RAY_BODY], "steel.plate", "body")
    # The canopy: a glass slit faired into the head's crown, each station set from the skin.
    b.loft([(32.0, hexagon(0.0, top(0.0, 32.0) - 0.6, 5.0, 1.4)), (26.0, hexagon(0.0, top(0.0, 26.0), 10.0, 4.0)),
            (14.0, hexagon(0.0, top(0.0, 14.0) + 0.3, 10.0, 4.5)), (8.0, hexagon(0.0, top(0.0, 8.0), 8.0, 3.0))], "glass.glass", "canopy")
    # One red eye sunk into the nose, its lens a touch proud.
    ez = top(0.0, 38.5)
    b.box(-2.5, 2.5, 37.5, 39.5, ez - 2.5, ez + 0.6, "amber.engine", "eye")
    # The spine stripe follows the skin from the stern to behind the canopy.
    _ridge(b, top, 0.0, -32.0, 6.0, 3.6, 0.5, 0.8, "livery.livery", "spine_stripe")
    # The wings: two discs lofted out of the flanks, inner in plate, outer in red; a fan
    # sunk through each at the knuckle, where the wing is thickest.
    for s in (-1.0, 1.0):
        secs = [_wing_section(s * x, yb, yf, zb, zt, sh) for (x, yb, yf, zb, zt, sh) in _RAY_WING]
        inner = _rings(b, [secs[0], secs[1]], "steel.plate", "wing_inner")
        outer = _rings(b, [secs[1], secs[2]], "livery.livery", "wing_outer")
        _lift_fan(b, [inner, outer], s * 23.0, 2.0, 7.5, 20.5, joint="fan_" + ("l" if s < 0 else "r"), hand=-s)   # the pair mirrored, as they spin
    # The tail is the exhaust, and it narrows in one stage (Ryan, 3 to 5 October, the sixth to
    # eighth passes: the shape two iterations ago was great; narrow quicker; then not in two
    # stages, since the body had run on behind the wings as a near-parallel neck before the
    # taper began): the body ends at the wings' trailing edge and the tail is one straight
    # loft in its pearl from there to a mouth two thirds the stern's width, one open duct; a
    # thin dark rim at the mouth is all the grey there is; a dark lining inside and fire at
    # its floor. Nothing is mounted on it.
    b.loft([(-34.0, hexagon(0.0, 14.5, 17.4, 10.0)), (-49.0, hexagon(0.0, 15.0, 8.0, 3.4))], "steel.plate", "tail", cap=False)
    b.loft([(-49.0, hexagon(0.0, 15.0, 8.0, 3.4)), (-50.0, hexagon(0.0, 15.0, 7.6, 3.2))], "steel.dark", "tail_rim", cap=False)
    _rings(b, [[(x, -50.0, z) for x, z in hexagon(0.0, 15.0, 7.6, 3.2)], [(x, -50.0, z) for x, z in hexagon(0.0, 15.0, 6.4, 2.3)]], "steel.dark", "duct_rim", cap=False)
    b.loft([(-50.0, hexagon(0.0, 15.0, 6.4, 2.3)), (-49.0, hexagon(0.0, 15.0, 6.5, 2.35))], "steel.dark", "duct_lining", cap=False)
    b.loft([(-49.0, hexagon(0.0, 15.0, 6.5, 2.35)), (-48.7, hexagon(0.0, 15.0, 6.5, 2.35))], "amber.glow", "nozzle_glow")   # the hot face a unit inside the mouth (Ryan, 5 October)
    # The Photosphere Lance under the nose (fixed, no pin): a long emitter along the keel,
    # a red collar at its root and a lit muzzle.
    b.box(-4.0, 4.0, 10.0, 24.0, 5.5, 9.5, "steel.panel", "lance_mount")
    b.prism("y", 0.0, 32.0, 7.5, 2.6, 36.0, "steel.dark", 6, "lance")
    b.prism("y", 0.0, 22.0, 7.5, 3.1, 4.0, "livery.livery2", 6, "lance_collar")
    b.prism("y", 0.0, 50.5, 7.5, 2.0, 1.4, "amber.engine", 6, "lance_muzzle")

    def forewing_pod(s, name):
        """A pod lying along a forewing's underside, buried under the plateau and emerging
        where the leading edge's lower slope rises past it, its muzzle ahead of the edge
        (Ryan, 3 October): hp_4 the Aurora Lattice (a dish) on the right, hp_5 bare on the left."""
        px, pz = s * 16.0, 9.6
        b.prism("y", px, 24.0, pz, 2.0, 24.0, "steel.dark", 6, "wing_pod")   # y 12 to 36; the wing's leading edge is near y 34 here
        b.prism("y", px, 36.4, pz, 2.3, 1.2, "steel.plate", 6, "pod_collar")
        if name == "hp_4":
            with b.socket(name, (px, 37.0, pz), scale=0.7):
                lattice(px, 37.0, pz)
        else:
            b.pad(name, (px, 37.0, pz), scale=0.7, size=(3.6, 1.4))

    def lattice(px, py, pz):
        """The Aurora Lattice's stock part on a pin at (px, py, pz): a short mast, a dish, a lit core."""
        b.prism("y", px, py + 1.2, pz, 0.9, 2.4, "steel.dark", 6, "lattice_mast")
        b.loft([(py + 2.4, _poly(4.2, 8, math.pi / 8)), (py + 3.8, _poly(1.5, 8, math.pi / 8))], "steel.plate", "lattice_dish", Matrix.Translation((px, 0.0, pz)))
        b.prism("y", px, py + 4.2, pz, 1.3, 0.8, "amber.engine", 8, "lattice_core")

    def tip_pod(s):
        """A pod along a wing tip's outer edge (Ryan, 3 October: too many weapons on the
        front, two to the wing tips): a fairing bridges it to the blade, the pod lies along
        the tip at the blade's mid-height, a collar at its mouth; the mount is its front.
        Returns the pin's place."""
        px, pz = s * 37.8, 14.0
        b.box(min(s * 34.6, s * 37.0), max(s * 34.6, s * 37.0), -9.0, 4.0, 12.9, 15.1, "steel.plate", "tip_fairing")
        b.prism("y", px, -2.0, pz, 2.0, 18.0, "steel.dark", 6, "tip_pod")
        b.prism("y", px, 7.4, pz, 2.3, 1.2, "steel.plate", 6, "tip_collar")
        return px, 8.0, pz

    # The wing tips carry the shoulder pods (Ryan's pick, 3 October, night: keep this
    # layout): hp_1 at the left tip, the flare pods pitched up off the pod's mouth, hp_2 at
    # the right, the repeater running on from the pod; the deck keeps the dome alone; the
    # forewing pods stay.
    for s in (-1.0, 1.0):
        px, py, pz = tip_pod(s)
        if s < 0:
            with b.socket("hp_1", (px, py, pz), scale=0.8):   # the flare pods point forward like every gun (Ryan, 5 October: pitched up read wrong), stacked over the tip
                for s2 in (-1.0, 1.0):
                    _beam(b, (px, py - 1.5, pz + s2 * 1.4), (px, py + 7.5, pz + s2 * 1.4), _poly(1.2, 6), _poly(1.4, 6), "steel.dark", "flare_pod")
                    b.prism("y", px, py + 7.9, pz + s2 * 1.4, 0.9, 0.8, "amber.engine", 6, "pod_mouth")
        else:
            with b.socket("hp_2", (px, py, pz), scale=0.8):
                b.prism("y", px, py + 8.0, pz, 1.4, 16.0, "steel.dark", 6, "pulse_repeater")
                b.prism("y", px, py + 16.4, pz, 1.0, 1.2, "amber.engine", 6, "repeater_tip")
        forewing_pod(s, "hp_4" if s > 0 else "hp_5")
    # The turret (hp_3) behind the canopy: a wide dome faired to the crown on a dark ring,
    # turning whole on its joint, the Zenith Emitter leaving a dark slot in the dome's
    # forward slope (Ryan, 2 October, late: the gun comes out of the edge of something
    # sleek). Fifth pass: the pin two units further back and the dome taller, so the gun
    # leaves the slot from deeper and still clears the canopy's crown (Ryan, 3 October).
    gz = top(0.0, -10.0)
    b.prism("z", 0.0, -10.0, gz + 0.5, 9.2, 1.6, "steel.dark", 8, "turret_ring", phase=math.pi / 8)
    with b.joint("turret", (0.0, -10.0, gz + 1.3)):
        b.loft([(gz + 1.2, _poly(8.8, 8, math.pi / 8)), (gz + 3.6, _poly(8.4, 8, math.pi / 8)), (gz + 6.4, _poly(5.8, 8, math.pi / 8)), (gz + 7.8, _poly(3.2, 8, math.pi / 8))],
               "steel.plate", "turret_dome", Matrix.Translation((0.0, -10.0, 0.0)) @ Matrix.Rotation(math.pi / 2, 4, "X"))
        b.box(-2.8, 2.8, -8.4, -1.0, gz + 3.2, gz + 6.9, "steel.dark", "emitter_slot")
        b.prism("z", 0.0, -10.0, gz + 8.0, 1.8, 0.8, "amber.engine", 8, "dome_light", phase=math.pi / 8)
        with b.socket("hp_3", (0.0, -8.0, gz + 5.0)):   # the pin sits back inside the dome, so a fitted gun comes out of the slot
            b.prism("y", 0.0, 4.0, gz + 5.0, 2.0, 24.0, "steel.dark", 6, "zenith_emitter")
            b.prism("y", 0.0, 16.6, gz + 5.0, 1.5, 1.4, "amber.engine", 6, "emitter_tip")

    # Idle acts, third pass (Ryan, 4 October: turrets too fast and wild; real machines with
    # inertia): curves a part runs on through, the servos' heft (b.move), and the emitter's
    # turret slow and short with a pause before it turns back (the builder's rule). Degrees
    # and seconds; a key is (t, value) on the joint's own axis or (t, pitch, yaw, roll); a
    # body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k),
    # k the light added over rest.
    b.act("scan_emitter", 7.8, {"turret": [(0.5, 0.0), (2.1, 55.0), (2.8, 55.0), (5.7, -45.0), (6.4, -45.0), (7.7, 0.0)]},   # the emitter scans out one way, pauses, across to the other, pauses, home, the ray leaning after it like a helicopter
          body=[(2.1, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0), (2.8, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0), (5.7, -2.0, 0.0, 0.0, 0.0, 0.0, -4.0), (6.4, -2.0, 0.0, 0.0, 0.0, 0.0, -4.0), (7.8, 0.0, 0.0, 0.0)],
          glow=[(["emitter_tip", "dome_light"], [(0.6, 0.0), (1.0, 6.0), (7.0, 6.0), (7.8, 0.0)])])
    b.act("lance_charge", 4.6, glow=[(["lance_muzzle", "eye"], [(0.3, 0.0), (1.0, 4.0), (1.4, 1.0), (2.0, 7.0), (2.4, 3.0), (3.0, 10.0), (3.6, 10.0), (4.3, 0.0)])],
          body=[(1.8, 0.0, 0.0, 0.0, 0.0, -4.0, 0.0), (3.6, 0.0, -3.0, 0.0, 0.0, -6.0, 0.0), (4.6, 0.0, 0.0, 0.0)])
    b.act("thrusters_surge", 4.4, body=[   # surges forward nose down, brakes nose up, settles: a helicopter's
        (0.5, 0.0, 0.0, 0.0), (1.3, 0.0, 12.0, -1.0, 0.0, -12.0, 0.0), (2.3, 0.0, 12.0, 0.0, 0.0, 10.0, 0.0), (3.1, 0.0, 0.0, 0.0, 0.0, -3.0, 0.0), (4.4, 0.0, 0.0, 0.0)],
          glow=[(["nozzle_glow"], [(0.3, 0.0), (0.9, 8.0), (1.6, 8.0), (2.4, 2.0), (3.6, 0.0)])])
    b.act("sidestep", 4.8, body=[   # slides a step to one side, rolling into it, and straight on across to the other
        (0.9, -6.0, 0.0, 0.0, 0.0, 0.0, -12.0), (1.6, -14.0, 0.0, 0.0, 0.0, 0.0, 2.0), (2.6, 2.0, 0.0, 0.0, 0.0, 0.0, 12.0),
        (3.4, 14.0, 0.0, 0.0, 0.0, 0.0, -2.0), (4.8, 0.0, 0.0, 0.0)])
    # Movement (Ryan, 5 October, retiring the helicopter of 3 October: it turned to its final
    # facing and held it, where it need not move so differently from the Dingo and the
    # Puffin): it faces its heading and oversteers through corners like them, banking a
    # little, and noses down hard into its travel, since its fans are its propulsion (the
    # tilt: nose down going forward, a side down to slip that way).
    b.gait(glow={"parts": ["nozzle_glow"], "k": 5.0})
    # The lift fans turn all the time, counter-rotating, and faster under way (Ryan, 6 October,
    # the seventh notes, the model locked: "the thing the Stingray really needs"). Slow enough a
    # frame that five blades never strobe backward at 30 frames a second.
    b.spin("fan_l", -480.0, -840.0)
    b.spin("fan_r", 480.0, 840.0)
    b.move(slide=0.3, bank=14.0, tilt=(26.0, 10.0), accel=0.9, heft=0.12, oversteer=1.2)   # the nose further into its corners (Ryan, 6 October, the seventh notes)

stingray.maker = "aphelion"


def _hull_section(z0, z1, w, c, cx=0.0, belly=0.8):
    """A hovercraft hull's section as (x, z) points, counter-clockwise: a chamfered rectangle,
    wide and low, its underside softened: flat for the middle third and rising `belly` to the
    lower chamfers, so it is not a flat-bottomed box (Ryan, 3 October: a bit of rounding, not
    too much)."""
    hw = w / 2.0
    return [(cx - hw / 3.0, z0), (cx + hw / 3.0, z0), (cx + hw - c, z0 + belly), (cx + hw, z0 + c + belly), (cx + hw, z1 - c),
            (cx + hw - c, z1), (cx - hw + c, z1), (cx - hw, z1 - c), (cx - hw, z0 + c + belly), (cx - hw + c, z0 + belly)]


def _chine_section(z0, z1, w, c, cx=0.0, belly=0.6):
    """A hovercraft hull's section with a hard chine: widest at a crease below mid-height,
    the flank leaning in to a narrower deck above it and tucking under to the skirt below,
    the belly flat for its middle third. A stealth airframe's facet rather than a chamfered
    box: the Puffin's hull since 5 October (the sleek trial of 3 October, made the model)."""
    hw = w / 2.0
    zc = z0 + (z1 - z0) * 0.42
    dw = hw * 0.74
    return [(cx - hw / 3.0, z0), (cx + hw / 3.0, z0), (cx + hw * 0.82, z0 + belly), (cx + hw, zc), (cx + dw, z1),
            (cx - dw, z1), (cx - hw, zc), (cx - hw * 0.82, z0 + belly)]


def puffin(b):
    """Kestrel "Puffin" (K-11 Mk I Ground-Effect Escort): Kestrel's one machine that touches
    the ground, the escort they thought was very cool and pilots named for the bird (the
    bible's makers row, 28 September; built 2 October). Fourth pass (Ryan, 3 October, on the
    third: the shape better but too goofy, a duck; ditch the explicit head, give it a real
    canopy cockpit and perhaps side wings; the giant boosters with the vents on top and the
    skirt are what he loves, bring them out; a little rounding under the hull): the wide low
    oblong hull with its dark lip, a chined cobalt prow carrying the band of light and the
    Prow Projector's lit slot (fixed, no pin), a fighter canopy, side wings with a pod under
    each tip, two giant boosters half out of the rear sponsons, two canted fins, lift nozzles.
    Fifth pass (Ryan, 3 October, on the fourth, looking good): the wings flipped to the reverse
    sweep (Kestrel's, the Sparrowhawk's), with a negative attitude, the tips dropping; the
    canopy carried farther back and settled onto the hull, its frame a band round the glass;
    the skirt carried up the prow; the deck carried over the boosters with the vent housings
    on it; the rear mounts moved up to the shoulders as low fairings. Sixth pass (Ryan, 3
    October, on the fifth: the back too boxy, the hull top overhanging the boosters, the
    vents to be narrower and lower; the fourth's overall shape was better, the back taper,
    the boosters poking out the side and the wings attached to them; the skirt to taper up
    before the beak): the two reconciled. The hull tapers to the stern as in the fourth pass;
    each sponson is a faired nacelle whose top is the deck itself, sloping down with the
    hull's taper and closing on the drum's crown, so the deck is carried over the booster
    without a lid; the drum pokes out of the nacelle's flank and below it; a narrow low
    louvred housing lies on each nacelle's top; the intake is the drum's mouth ahead of the
    nacelle; and the wings grow out of the nacelles' flanks, reverse-swept and dropping, their
    tips ahead of the intakes. The skirt climbs the prow's chine and ends before the band.
    Mounts, in the die's order: hp_1 under the left wing tip (the Laser Carbine), hp_2 under
    the right (the Deflector, a dish), hp_3 on the right shoulder (the Overcharge Coil, a
    dish), hp_4 bare on the left shoulder (the Ram-air Scoop is a vent and shows nowhere).
    Floats: the lip at z = 6.5. Seventh pass (Ryan, 5 October, on the sleek trial of the
    3rd: it looks much better, apply it): the Kestrel read, the hull a chined airframe facet
    (_chine_section) widest at a crease along the flank and leaning in to a narrower deck a
    step lower, the waist pinched so the nacelles stand proud of a fuselage, the fins taller
    and swept back. Eighth pass (the same day, Claude's suggestions 4 and 5, both kept): the
    skirt at two thirds its height, and a cobalt stripe along the chine from the prow back to
    the nacelles, the prow's colour run down the flank."""
    # The hull: wide and low, nose to stern, as (y, w, z0, z1, chamfer), tapering to the stern.
    HULL = [(30.0, 14.0, 10.0, 14.6, 2.0), (20.0, 28.0, 8.0, 17.6, 3.0), (6.0, 36.0, 7.0, 19.4, 3.5), (-12.0, 34.0, 7.0, 19.4, 3.5),
            (-26.0, 30.0, 8.0, 18.8, 3.0), (-36.0, 22.0, 10.0, 17.4, 2.5)]
    section = _chine_section

    def deck(y):
        """The hull's flat top at a station between the chamfers."""
        for (y0, w0, a0, z0, c0), (y1, w1, a1, z1, c1) in zip(HULL, HULL[1:]):
            if y1 <= y <= y0:
                t = (y0 - y) / (y0 - y1)
                return z0 + (z1 - z0) * t
        return HULL[0][3] if y > HULL[0][0] else HULL[-1][3]
    b.loft([(y, section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "hull")
    # The prow: a chined cobalt wedge out of the nose, the band of light across it, its edge
    # the projector's lit slot.
    PROW = [HULL[0], (37.0, 9.0, 11.0, HULL[0][3], 1.6), (43.0, 4.6, 12.0, HULL[0][3] - 0.4, 1.0), (46.0, 2.0, 12.6, HULL[0][3] - 0.8, 0.5)]
    b.loft([(y, section(z0, z1, w, c)) for (y, w, z0, z1, c) in PROW], "livery.livery", "prow")
    b.loft([(38.5, _hull_section(10.6, 15.3, 9.2, 1.4)), (40.0, _hull_section(10.8, 15.2, 8.4, 1.3))], "amber.light", "prow_band")
    b.loft([(46.0, _hull_section(12.7, 14.1, 1.8, 0.4)), (46.9, _hull_section(12.9, 13.9, 1.2, 0.3))], "amber.engine", "projector_slot")
    # The skirt: the dark lip round the hull's foot, the plenum's armoured rim, carried up the
    # prow and tapering up onto its chine, ending short of the band (Ryan, 3 October: it need
    # not run under the beak).
    # The skirt at two thirds its height (Ryan, 5 October), so it reads as a rim and not a hem.
    SKIRT = [(37.0, 9.6, 11.4, 12.1, 0.4), (34.0, 12.2, 10.3, 11.9, 0.7), (30.0, 15.0, 9.5, 11.4, 0.9)] \
        + [(y, w + 1.0, z0 - 0.5, z0 + 1.4, 0.8) for (y, w, z0, z1, c) in HULL[1:]]
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.3)) for (y, w, z0, z1, c) in SKIRT], "steel.dark", "lip")
    # A cobalt stripe along the chine (Ryan, 5 October), the prow's colour run back to the nacelles.
    def hull_at(y):
        for (y0, w0, a0, b0, c0), (y1, w1, a1, b1, c1) in zip(HULL, HULL[1:]):
            if y1 <= y <= y0:
                t = (y0 - y) / (y0 - y1)
                return w0 + (w1 - w0) * t, a0 + (a1 - a0) * t, b0 + (b1 - b0) * t
        return HULL[0][1:4]
    for s in (-1.0, 1.0):
        secs = []
        for y in (30.0, 20.0, 6.0, -6.0):
            w, z0, z1 = hull_at(y)
            hw, zc = w / 2.0, z0 + (z1 - z0) * 0.42
            pts = [(hw + 0.35, zc), (hw - 0.3, zc + 0.8), (hw - 1.2, zc), (hw - 0.3, zc - 0.8)]
            secs.append((y, [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]))
        b.loft(list(reversed(secs)), "livery.livery", "chine_stripe")
    # The canopy: a fighter's glass settled onto the fore deck (Ryan, 3 October: carried
    # farther back, settled down more, the block through it gone): a section with its base
    # sunk into the hull, vertical sides to half height and a chamfer to a flat crown, so it
    # sits on the fuselage rather than resting a lens on it; a frame band round the glass
    # where the windscreen meets the hood; the dark fairing runs on from its end along the
    # spine as the bird's back.
    CAB = [(26.0, 6.0, 0.6), (20.0, 11.0, 3.0), (12.0, 12.6, 4.0), (2.0, 12.0, 3.6), (-4.0, 10.0, 2.6)]   # (y, width at the deck, height over the deck)

    def cab_at(y):
        for (y0, w0, h0), (y1, w1, h1) in zip(CAB, CAB[1:]):
            if y1 <= y <= y0:
                t = (y0 - y) / (y0 - y1)
                return w0 + (w1 - w0) * t, h0 + (h1 - h0) * t
        return CAB[-1][1:]

    def cab(y, grow=0.0):
        w, h = cab_at(y)
        z, hw = deck(y), w / 2.0 + grow
        return [(-hw, z - 0.8), (hw, z - 0.8), (hw, z + h * 0.45 + grow), (hw * 0.5, z + h + grow), (-hw * 0.5, z + h + grow), (-hw, z + h * 0.45 + grow)]
    b.loft([(y, cab(y)) for (y, w, h) in CAB], "glass.glass", "canopy")
    b.loft([(16.4, cab(16.4, 0.35)), (15.2, cab(15.2, 0.35))], "steel.dark", "canopy_frame")
    b.loft([(-4.0, cab(-4.0, 0.3)), (-14.0, [(-4.2, deck(-14.0) - 0.6), (4.2, deck(-14.0) - 0.6), (4.2, deck(-14.0) + 0.9), (2.1, deck(-14.0) + 2.0), (-2.1, deck(-14.0) + 2.0), (-4.2, deck(-14.0) + 0.9)]),
            (-30.0, [(-2.6, deck(-30.0) - 0.6), (2.6, deck(-30.0) - 0.6), (2.6, deck(-30.0) + 0.6), (1.3, deck(-30.0) + 1.4), (-1.3, deck(-30.0) + 1.4), (-2.6, deck(-30.0) + 0.6)])], "steel.dark", "fairing")

    def nac_top(y):
        """The nacelle's top: the deck carried out over the booster, 21 at its front and
        sloping down with the hull's taper to the drum's crown at the stern."""
        top0, top1 = 19.4, 18.4
        return top0 + (top1 - top0) * (-6.0 - y) / 27.0

    def mirror(pts, s):
        """A section drawn for the right side, mirrored for the left with its winding kept."""
        return [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]

    for s in (-1.0, 1.0):
        # The nacelles (Ryan, 3 October, sixth pass): each sponson is a faired housing whose
        # top is the deck itself, from the hull's flank out over the booster drum, its outer
        # top edge chamfered and its whole top sloping down toward the stern with the hull's
        # taper, so the deck is carried over the booster without a lid overhanging it; the
        # drum, a giant six-sided drum, pokes out of the nacelle's flank and below it, its
        # mouth ahead of the nacelle as the intake, bare for its last stretch, its lit ring
        # and exhaust past the stern; a narrow, low louvred housing lies along the top.
        bx, bz, br = s * 17.0, 12.4, 6.4
        def nac(y, x_out):
            t = nac_top(y)
            return mirror([(10.0, 8.6), (x_out, 8.6), (x_out, t - 1.6), (x_out - 1.6, t), (10.0, t)], s)
        b.loft([(-6.0, nac(-6.0, 22.2)), (-20.0, nac(-20.0, 22.0)), (-33.0, nac(-33.0, 21.2))], "steel.plate", "nacelle")
        b.prism("y", bx, -20.5, bz, br, 31.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.loft([(-5.0, hexagon(bx, bz, 12.0, 10.6)), (-4.4, hexagon(bx, bz, 10.6, 9.4))], "bore.dark", "intake")
        b.prism("y", bx, -4.8, bz, 7.2, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
        hx0, hx1 = min(s * 13.0, s * 19.0), max(s * 13.0, s * 19.0)
        b.loft([(-9.0, rect((hx0 + hx1) / 2.0, hx1 - hx0, nac_top(-9.0) - 0.3, nac_top(-9.0) + 1.0)), (-29.0, rect((hx0 + hx1) / 2.0, hx1 - hx0, nac_top(-29.0) - 0.3, nac_top(-29.0) + 1.0))], "steel.dark", "vent_housing")
        lx0, lx1 = min(s * 13.5, s * 18.5), max(s * 13.5, s * 18.5)
        b.loft([(-10.0, rect((lx0 + lx1) / 2.0, lx1 - lx0, nac_top(-10.0) + 1.0, nac_top(-10.0) + 1.5)), (-28.0, rect((lx0 + lx1) / 2.0, lx1 - lx0, nac_top(-28.0) + 1.0, nac_top(-28.0) + 1.5))], "steel.vent", "vent_louvres")
        b.prism("y", bx, -36.0, bz, 7.3, 1.2, "steel.plate", 6, "exhaust_lip", phase=math.pi / 6)
        b.prism("y", bx, -36.9, bz, 6.9, 1.4, "amber.engine", 6, "nozzle_ring", phase=math.pi / 6)
        b.loft([(-37.6, hexagon(bx, bz, 11.2, 9.8)), (-38.1, hexagon(bx, bz, 10.0, 8.6))], "amber.exhaust", "exhaust")
        # The wings grow out of the nacelles' flanks (Ryan, 3 October: attached to the
        # boosters), reverse-swept like the Sparrowhawk's, the tips ahead of the roots and
        # ahead of the intakes, dropping toward the tips, a diamond in section; a pod hangs
        # under each tip on a pylon that reaches the blade's underside and no further: hp_1
        # the Laser Carbine left, hp_2 the Deflector's dish right.
        root = [(s * 20.5, -22.0, 15.8), (s * 20.5, -14.0, 18.0), (s * 20.5, -6.0, 15.8), (s * 20.5, -14.0, 13.6)]
        tip = [(s * 33.0, -8.0, 12.0), (s * 33.0, -3.0, 12.8), (s * 33.0, 2.0, 12.0), (s * 33.0, -3.0, 11.2)]
        _wing(b, root, tip, "livery.livery", "wing")
        px = s * 30.0
        b.box(min(px - 0.9, px + 0.9), max(px - 0.9, px + 0.9), -9.0, -2.0, 9.6, 12.0, "steel.plate", "pod_pylon")
        with b.socket("hp_%d" % (1 if s < 0 else 2), (px, 1.5, 9.2), scale=0.6):
            b.prism("y", px, -4.5, 9.2, 1.6, 12.0, "steel.dark", 6, "pod")
            if s < 0:
                b.prism("y", px, 7.5, 9.2, 0.9, 12.0, "steel.dark", 6, "laser_carbine")
                b.prism("y", px, 13.9, 9.2, 1.2, 1.0, "steel.plate", 6, "muzzle")
            else:
                b.prism("y", px, 4.5, 9.2, 3.4, 1.2, "steel.plate", 8, "dish")
                b.prism("y", px, 5.4, 9.2, 1.3, 0.8, "amber.engine", 8, "dish_core")
    # Two canted fins on the rear deck: the airframe ancestry, tall and swept back.
    fh, fy0, fy1 = 13.0, -42.0, -34.0
    for s in (-1.0, 1.0):
        a = math.radians(s * 35.0)
        fx, fz = s * 7.0, deck(-30.0)
        root = [(fx, -35.0, fz - 0.8), (fx, -24.0, fz - 0.8), (fx, -24.0, fz + 0.2), (fx, -35.0, fz + 0.2)]
        tip = [(fx + fh * math.sin(a), fy0, fz + fh * math.cos(a)), (fx + fh * math.sin(a), fy1, fz + fh * math.cos(a)),
               (fx + fh * math.sin(a), fy1, fz + 0.5 + fh * math.cos(a)), (fx + fh * math.sin(a), fy0, fz + 0.5 + fh * math.cos(a))]
        _wing(b, root, tip, "livery.livery", "fin")
    # The shoulder mounts behind the canopy (Ryan, 3 October: the rear deck mounts were
    # janky): a low fairing lying along each shoulder, rising to its front where the pin is,
    # so a fitted part rides the deck: hp_3 the Overcharge Coil's dish on the right, hp_4
    # bare on the left.
    for s in (-1.0, 1.0):
        rx, ry = s * 10.5, 0.0
        dz = deck(ry)
        b.loft([(ry - 8.0, rect(rx, 3.2, dz - 0.6, dz + 1.2)), (ry + 6.0, rect(rx, 4.6, dz - 0.6, dz + 2.4))], "steel.panel", "shoulder_fairing")
        if s > 0:
            with b.socket("hp_3", (rx, ry + 6.5, dz + 1.5), scale=0.6):
                b.prism("y", rx, ry + 7.8, dz + 1.5, 0.8, 2.6, "steel.dark", 6, "coil_mast")
                b.prism("y", rx, ry + 9.8, dz + 1.5, 3.4, 1.2, "steel.plate", 8, "coil_dish")
                b.prism("y", rx, ry + 10.7, dz + 1.5, 1.2, 0.8, "amber.engine", 8, "coil_core")
        else:
            b.pad("hp_4", (rx, ry + 6.5, dz + 1.5), scale=0.6, size=(4.0, 1.5))
    # Lift nozzles under the belly, lit: the ground effect.
    for (nx, ny) in ((-8.0, 10.0), (8.0, 10.0), (-8.0, -16.0), (8.0, -16.0)):
        b.prism("z", nx, ny, 6.6, 2.4, 1.4, "amber.engine", 6, "lift_nozzle")

    # Idle acts, third pass (Ryan, 4 October: some stilted; real machines with inertia):
    # curves a part runs on through, the servos' heft (b.move), and nothing holding dead
    # still. Degrees and seconds; a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch,
    # roll); a glow key is (t, k), k the light added over rest.
    b.act("boosters_flare", 4.0, body=[(0.5, 0.0, 0.0, 0.0), (1.1, 0.0, 11.0, 1.0, 0.0, 6.0, 0.0), (2.6, 0.0, 13.0, 1.2, 0.0, 6.5, 0.0), (4.0, 0.0, 0.0, 0.0)],
          glow=[(["nozzle_ring", "exhaust"], [(0.3, 0.0), (0.8, 8.0), (1.2, 4.0), (1.6, 9.0), (2.6, 9.0), (3.4, 0.0)])])
    b.act("prow_pulse", 4.0, glow=[(["projector_slot", "prow_band"], [   # the prow projector beats three times, hard
        (0.3, 0.0), (0.6, 9.0), (1.0, 0.5), (1.4, 9.0), (1.8, 0.5), (2.2, 10.0), (3.0, 10.0), (3.8, 0.0)])],
          body=[(0.6, 0.0, 2.0, 0.0, 0.0, 3.0, 0.0), (1.4, 0.0, 2.5, 0.0, 0.0, 3.2, 0.0), (2.2, 0.0, 4.0, 0.0, 0.0, 4.0, 0.0), (4.0, 0.0, 0.0, 0.0)])
    b.act("lift_hop", 4.6, body=[   # a big hop on the lift nozzles: up hard, a roll at the top, down onto a squash, a bounce
        (0.5, 0.0, 0.0, -2.0, 0.0, 0.0, 0.0), (1.2, 0.0, 0.0, 18.0, 0.0, 6.0, 14.0), (1.8, 0.0, 0.0, 16.0, 0.0, -4.0, -12.0), (2.5, 0.0, 0.0, -3.0, 0.0, 0.0, 0.0),
        (2.9, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0), (3.4, 0.0, 0.0, -1.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(["lift_nozzle"], [(0.3, 0.0), (0.6, 10.0), (1.2, 10.0), (1.8, 3.0), (2.5, 8.0), (3.2, 0.0)])])
    b.act("sideslip", 4.8, body=[   # slips sideways on its skirt, nose swinging after, and straight on across to the other side
        (1.0, -12.0, 0.0, 0.0, 12.0, 0.0, -8.0), (1.7, -14.0, 0.0, 0.0, 1.0, 0.0, -1.0), (3.0, 12.0, 0.0, 0.0, -12.0, 0.0, 8.0), (3.7, 14.0, 0.0, 0.0, -1.0, 0.0, 1.0), (4.8, 0.0, 0.0, 0.0)],
          glow=[(["lift_nozzle"], [(0.6, 0.0), (1.0, 5.0), (3.4, 5.0), (4.2, 0.0)])])
    # Movement (Ryan, 3 October): a cross between a jet and the Dingo, on its boosters: it
    # oversteers through turns (Ryan, 5 October: not lagging), less wildly than the Dingo,
    # its nose down a touch. It does not bank (the fifth notes: a hovercraft keeps flat; the
    # Stingray banks because it moves as a helicopter does).
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, -5.0, 0.0), glow={"parts": ["nozzle_ring", "exhaust"], "k": 5.0}, rock=3.0)
    b.move(slide=0.3, bank=0.0, accel=0.8, heft=0.13, oversteer=1.5)   # its rear kicked out further (Ryan, 5 October, the sixth notes), and further again (the seventh)

puffin.maker = "kestrel"


def _deck(w, d, cy, z, c):
    """A chamfered rectangle lying flat at height `z`, centred on x = 0 and y = `cy`: eight
    points, a torso's section for `_rings`."""
    hw, hd = w / 2.0, d / 2.0
    return [(-hw + c, cy - hd, z), (hw - c, cy - hd, z), (hw, cy - hd + c, z), (hw, cy + hd - c, z),
            (hw - c, cy + hd, z), (-hw + c, cy + hd, z), (-hw, cy + hd - c, z), (-hw, cy - hd + c, z)]


class _Raised:
    """Everything built inside the block moved up `dz` once it is built: its roots move (a
    joint's Empty, a pin, an unparented part) and carry their children. The tiles were
    mapped where the parts were made, so a `dz` of whole tiles (TILE_WORLD) keeps every seam
    on the world grid. Leave a joint opened inside the block closed inside it."""

    def __init__(self, b, dz):
        self.b, self.dz = b, dz

    def __enter__(self):
        self.start, self.pstart = len(self.b.objects), len(self.b.pins)
        return self

    def __exit__(self, *exc):
        if exc[0] is None:
            lift = Matrix.Translation(Vector((0.0, 0.0, self.dz)))
            for ob in self.b.objects[self.start:] + self.b.pins[self.pstart:]:
                if ob.parent is None:
                    ob.matrix_world = lift @ ob.matrix_world
        return False


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


def _tube(b, p0, p1, r_out, r_in, n, material, label, floor_material="bore.dark", floor_depth=0.5, floor=True, phase=0.0):
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
        return [Vector(p) + side * (r * math.cos(phase + i * 2.0 * math.pi / n)) + over * (r * math.sin(phase + i * 2.0 * math.pi / n)) for i in range(n)]
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


def _missile_face(b, corner, up, right, fwd, size, label="missile_face"):
    """A launcher's tube face: one square face from `corner` along `right` and `up`, facing
    `fwd`, wearing exactly one missile tile, so the tubes show on the front and nowhere else."""
    o, up, right = Vector(corner), Vector(up), Vector(right)
    return _quad(b, [tuple(o), tuple(o + right * size), tuple(o + right * size + up * size), tuple(o + up * size)],
                 "steel.missile", label, (o, up, right, Vector(fwd), (size, size)))


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


# ---------------------------------------------------------------- gait helpers (the joints row, 2 October)

def _ik2(h, k, e, target, bend):
    """The two angles (degrees, the joints' pitch: positive raises the forward end) that put a
    two-link limb's end on `target`: `h`, `k`, `e` the hip, knee and end at rest and `target`
    as (y, z) pairs in the limb's plane, `bend` the side the knee folds to at rest (+1 or -1),
    kept so the knee never flips through."""
    l1 = math.hypot(k[0] - h[0], k[1] - h[1])
    l2 = math.hypot(e[0] - k[0], e[1] - k[1])
    phi1 = math.atan2(k[1] - h[1], k[0] - h[0])
    phi2 = math.atan2(e[1] - k[1], e[0] - k[0])
    dy, dz = target[0] - h[0], target[1] - h[1]
    d = math.hypot(dy, dz)
    if d > l1 + l2 - 1e-6 or d < abs(l1 - l2) + 1e-6:
        raise ValueError("a planted foot out of reach: %.2f from the hip, the limb spans %.2f to %.2f" % (d, abs(l1 - l2), l1 + l2))
    delta = math.atan2(dz, dy)
    gamma = math.acos(max(-1.0, min(1.0, (l1 * l1 + d * d - l2 * l2) / (2.0 * l1 * d))))
    for sgn in (1.0, -1.0):
        a1 = delta + sgn * gamma
        ky, kz = h[0] + l1 * math.cos(a1), h[1] + l1 * math.sin(a1)
        a2 = math.atan2(target[1] - kz, target[0] - ky)
        if math.sin(a2 - a1) * bend >= 0.0:
            break
    wrap = lambda a: (a + math.pi) % (2.0 * math.pi) - math.pi
    hip = wrap(a1 - phi1)
    knee = wrap(a2 - phi2 - (a1 - phi1))
    return math.degrees(hip), math.degrees(knee)


def _to_body(y, z, dy, dz, pitch):
    """A point fixed on the ground, (y, z) in the model's rest frame, as the body sees it when
    the body has slid (dy, dz) and pitched `pitch` degrees about its origin."""
    c, s = math.cos(math.radians(pitch)), math.sin(math.radians(pitch))
    y, z = y - dy, z - dz
    return (y * c + z * s, -y * s + z * c)


def _limb_angles(l, target, pitch):
    """A limb's hip, knee and ankle (degrees) putting its end on `target` (the body's frame),
    the foot kept flat to the ground under a body pitched `pitch`."""
    h3, k3, e3 = l["at"]
    h, k, e = (h3[1], h3[2]), (k3[1], k3[2]), (e3[1], e3[2])
    bend = 1.0 if math.sin(math.atan2(e[1] - k[1], e[0] - k[0]) - math.atan2(k[1] - h[1], k[0] - h[0])) >= 0.0 else -1.0
    a, b = _ik2(h, k, e, target, bend)
    return a, b, -(a + b + pitch)


def _lerp_keys(keys, t):
    """A value at `t` along (t, v) keys, straight between them, held before the first and after
    the last."""
    if t <= keys[0][0]:
        return keys[0][1]
    for (t0, v0), (t1, v1) in zip(keys, keys[1:]):
        if t <= t1:
            return v0 + (v1 - v0) * (t - t0) / max(1e-9, t1 - t0)
    return keys[-1][1]


def _slam(t0, a, t1, b):
    """Keys after `t0` (where the part stands at `a`) that drive it into `b` at `t1` gathering
    speed all the way and stopping dead there (Ryan, 6 October, the eighth and ninth notes: the
    fists slowed into each other): a third of the way at a little past half the time, three
    quarters three hundredths of a second short of the hit, so the monotone curve carries its
    speed into the last key and has to stop on it. `a` and `b` are numbers or tuples alike."""
    if isinstance(a, tuple):
        mix = lambda f: tuple(round(x + f * (y - x), 3) for x, y in zip(a, b))
    else:
        mix = lambda f: round(a + f * (b - a), 3)
    return [(round(t0 + 0.55 * (t1 - t0), 3), mix(0.3)), (round(t1 - 0.03, 3), mix(0.76)), (t1, b)]


def _planted(limbs, body):
    """Leg keys for an act that moves the body of a walker (Ryan, 4 October, the third pass:
    the weight of the machine believable): `body` the act's keys as (t, dy, dz, pitch), and
    each limb's foot stays where it stands while the body squats, rears or tips over it. A
    limb is a dict as _plant takes ("hip", "knee", "ankle", "at"). Returns joint -> keys,
    to merge into the act's tracks, and the body keys in the act's own shape."""
    tracks = {}
    for l in limbs:
        e = l["at"][2]
        rows = {"hip": [], "knee": [], "ankle": []}
        for t, dy, dz, pitch in body:
            a, b, c = _limb_angles(l, _to_body(e[1], e[2], dy, dz, pitch), pitch)
            rows["hip"].append((t, round(a, 3)))
            rows["knee"].append((t, round(b, 3)))
            rows["ankle"].append((t, round(c, 3)))
        tracks[l["hip"]] = rows["hip"]
        tracks[l["knee"]] = rows["knee"]
        if l.get("ankle"):
            tracks[l["ankle"]] = rows["ankle"]
    return tracks, [(t, 0.0, dy, dz, 0.0, pitch, 0.0) for t, dy, dz, pitch in body]


def _basis(pitch, yaw, roll):
    """A joint's turn as the engine makes it (MechRig.euler_of): degrees in the machine's own
    terms as a 3x3 matrix in Godot's axes (x right, y up, z back), Euler order YXZ."""
    x, y, z = math.radians(pitch), math.radians(yaw), -math.radians(roll)
    cx, sx, cy, sy, cz, sz = math.cos(x), math.sin(x), math.cos(y), math.sin(y), math.cos(z), math.sin(z)
    ry = ((cy, 0.0, sy), (0.0, 1.0, 0.0), (-sy, 0.0, cy))
    rx = ((1.0, 0.0, 0.0), (0.0, cx, -sx), (0.0, sx, cx))
    rz = ((cz, -sz, 0.0), (sz, cz, 0.0), (0.0, 0.0, 1.0))
    return _mm(_mm(ry, rx), rz)


def _mm(a, b):
    return tuple(tuple(sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)) for i in range(3))


def _mv(a, v):
    return tuple(sum(a[i][k] * v[k] for k in range(3)) for i in range(3))


def _godot(p):
    return (p[0], p[2], -p[1])


def _leg_fk(leg, q, body):
    """Where a three-joint leg puts its ankle (the model's axes) and which way its foot's up
    faces (Godot's), `q` the hip's (pitch, roll), the knee's pitch and the ankle's (pitch,
    roll), `body` the body's (dy, dz, pitch): the engine's own sums, so a foot planted here
    stays planted there."""
    h, k, e = (_godot(p) for p in leg)
    rh, rk, ra = _basis(q[0], 0.0, q[1]), _basis(q[2], 0.0, 0.0), _basis(q[3], 0.0, q[4])
    rb = _basis(body[2], 0.0, 0.0)
    ke = _mv(rk, tuple(e[i] - k[i] for i in range(3)))
    he = _mv(rh, tuple(k[i] - h[i] + ke[i] for i in range(3)))
    w = _mv(rb, tuple(h[i] + he[i] for i in range(3)))
    w = (w[0], w[1] + body[1], w[2] - body[0])
    up = _mv(rb, _mv(rh, _mv(rk, _mv(ra, (0.0, 1.0, 0.0)))))
    return (w[0], -w[2], w[1]), up


def _leg_ik(leg, target, body, q0):
    """The hip's pitch and roll, the knee and the ankle's pitch and roll (degrees) that put a
    leg's ankle on `target` (the model's axes) with its foot flat to the ground, under a
    body slid and pitched by `body` (dy, dz, pitch); Newton's method from `q0`, so a pose
    keyed after the last keeps its knee on the same side (Ryan, 5 October: a foot stepped
    out wide, the Armadillo's sumo stance, needs the hip to roll and the ankle with it). A
    straight leg is no place to start from, so the knee is tried bent each way too, and the
    answer bends it the way `q0` does."""
    bend = q0[2]
    for seed in (q0, [q0[0], q0[1], q0[2] - 20.0, q0[3] + 10.0, q0[4]], [q0[0], q0[1], q0[2] + 20.0, q0[3] - 10.0, q0[4]]):
        try:
            q = _leg_newton(leg, target, body, seed)
        except ValueError:
            continue
        if bend == 0.0 or q[2] * bend > 0.0:
            return q
    raise ValueError("a planted foot out of reach at %s" % (tuple(round(v, 1) for v in target),))


def _leg_newton(leg, target, body, q0):
    q = list(q0)
    for _ in range(40):
        p, up = _leg_fk(leg, q, body)
        f = [p[0] - target[0], p[1] - target[1], p[2] - target[2], up[0] * 30.0, up[2] * 30.0]
        if max(abs(v) for v in f) < 1e-6:
            break
        jac = []
        for j in range(5):
            dq = list(q)
            dq[j] += 1e-4
            p2, up2 = _leg_fk(leg, dq, body)
            f2 = [p2[0] - target[0], p2[1] - target[1], p2[2] - target[2], up2[0] * 30.0, up2[2] * 30.0]
            jac.append([(f2[i] - f[i]) / 1e-4 for i in range(5)])
        # Solve J dq = -f (J's columns are jac's rows), by elimination with pivoting.
        m = [[jac[j][i] for j in range(5)] + [-f[i]] for i in range(5)]
        for c in range(5):
            r = max(range(c, 5), key=lambda r: abs(m[r][c]))
            m[c], m[r] = m[r], m[c]
            if abs(m[c][c]) < 1e-12:
                raise ValueError("a leg pose with no solution near the last")
            for r in range(5):
                if r != c:
                    k = m[r][c] / m[c][c]
                    m[r] = [m[r][i] - k * m[c][i] for i in range(6)]
        step = [m[i][5] / m[i][i] for i in range(5)]
        q = [q[i] + max(-10.0, min(10.0, step[i])) for i in range(5)]
    p, up = _leg_fk(leg, q, body)
    if math.dist(p, target) > 0.05 or abs(up[0]) > 1e-3 or abs(up[2]) > 1e-3:
        raise ValueError("a planted foot out of reach at %s" % (tuple(round(v, 1) for v in target),))
    return q


def _stance(legs, frames):
    """Keys for an act that steps a walker's feet about under its body (Ryan, 5 October: the
    Armadillo widening its stance a foot at a time): `legs` maps a leg's name to its (hip,
    knee, ankle) points, `frames` is a list of (t, (dy, dz, pitch), {leg: ankle point}) with
    every leg's ankle wherever it stands at that moment (its rest point if it is not named,
    else the last place named), flat to the ground. Returns joint -> keys, to merge into the
    act's tracks, and the body keys."""
    at = {n: legs[n][2] for n in legs}
    q = {n: [0.0] * 5 for n in legs}
    tracks = {}
    for n in legs:
        for j in ("hip_", "knee_", "ankle_"):
            tracks[j + n] = []
    body = []
    for t, pose, feet in frames:
        at.update(feet)
        for n in legs:
            q[n] = _leg_ik(legs[n], at[n], pose, q[n])
            a, r, k, c, w = (round(v, 3) for v in q[n])
            tracks["hip_" + n].append((t, a, 0.0, r))
            tracks["knee_" + n].append((t, k))
            tracks["ankle_" + n].append((t, c, 0.0, w))
        body.append((t, 0.0, pose[0], pose[1], 0.0, pose[2], 0.0))
    return tracks, body


def _steps(limbs, frames):
    """Keys for an act that moves a walker's body and steps some of its feet about, in the
    limbs' own planes (Ryan, 5 October: the Ammit's middle hands stepped forward as it
    sinks): `limbs` maps a name to a limb as _plant takes it ("hip", "knee", optional
    "ankle", "at"), `frames` is a list of (t, (dy, dz, pitch), {name: (y, z)}) with every
    named end where it is at that moment (its rest point until first named, then the last
    place named). A foot with an ankle stays flat. Returns joint -> keys and the body keys."""
    at = {n: (l["at"][2][1], l["at"][2][2]) for n, l in limbs.items()}
    tracks = {}
    for l in limbs.values():
        for j in ("hip", "knee", "ankle"):
            if l.get(j):
                tracks[l[j]] = []
    body = []
    for t, (dy, dz, pitch), feet in frames:
        at.update(feet)
        for n, l in limbs.items():
            a, k, c = _limb_angles(l, _to_body(at[n][0], at[n][1], dy, dz, pitch), pitch)
            tracks[l["hip"]].append((t, round(a, 3)))
            tracks[l["knee"]].append((t, round(k, 3)))
            if l.get("ankle"):
                tracks[l["ankle"]].append((t, round(c, 3)))
        body.append((t, 0.0, dy, dz, 0.0, pitch, 0.0))
    return tracks, body


def _plant(limbs, sweep, duty=0.55, lift=8.0, crouch=0.0, dip=1.2, nod=0.0, reach=0.96, n=40, airborne=None, smooth=0.0, stomp=False):
    """A walk worked out foot by foot (Ryan, 4 October, the third pass: legs too fast, the
    weight shift far too pronounced; stomp and plod, mechanical, MechWarrior or Star Wars, not
    Gundam or Evangelion). Each limb's foot stays planted on the ground through its stance,
    the leg sweeping back under the body at an even rate while the body travels over it, then
    lifts straight up, carries forward and comes down hard. The body vaults over its legs as
    a heavy walker does: it rides as high as its stance legs allow kept `reach` of straight,
    rising as a leg passes under its hip and settling as the feet spread (so the knees never
    fold into a crouch mid-stride), `crouch` units lower than that, and drops `dip` units more
    as each foot lands, recovering before the next, its nose dipping `nod` degrees with it; it
    never rolls side to side. A limb with an ankle keeps its foot flat to the ground, and the
    body's travel is the legs' to take, so no planted foot sinks or slides.

    `limbs` is a list of dicts: "hip", "knee" and "ankle" the joint names ("ankle" None when
    the foot rides the knee joint), "at" the (hip, knee, end) points of the model, the end
    being the ankle's pivot or the point the foot meets the ground through; "phase" the share
    of the stride its stance starts at; "shift" moves the stance forward (+) or back under
    the body, units. `sweep` is how far each foot travels back through its stance; the stride
    is sweep over `duty`, the share of the stride a foot is down, so the feet never slide.
    `lift` raises a foot off the ground in the swing. `airborne`, a share of straight like
    `reach`, lets a foot in the air bound the body too, so a hoof leaving the back of its
    stance or reaching for the ground ahead lowers it on the way and not all at once on
    landing (a four-beat walk, where one foot is always about to land); `smooth` (a share
    of the stride) eases the body's ride, only ever lower than the legs allow. A limb's
    "cycles" (1 unless given) is how many steps it takes in the cycle, its phase then a share
    of its own step and its stance `sweep` over its cycles (Ryan, 5 October: the Ammit's arms
    and legs at different speeds, three steps of the arms to two of the legs, the cycle as
    long as both take to come round together). `stomp` (Ryan, 6 October, the seventh notes: an
    AT-AT's weight, not a plod) lifts each foot briskly and holds it high, then slams it down
    in the last fifth of its swing, and each landing drops the body hard and lets it shudder,
    a rebound and a settle; a limb's "nod" (1 unless given) signs and scales the body's pitch
    at its landing, so a fore foot can dip the nose and a hind one lift it. Returns (tracks,
    body, stride) for b.gait with ease "linear" (dense keys, n a cycle)."""
    stride = sweep / duty
    loop = max(int(l.get("cycles", 1)) for l in limbs)   # the most steps any limb takes in a cycle
    landings = sorted({round(((l["phase"] + j) / int(l.get("cycles", 1))) % 1.0, 4) for l in limbs for j in range(int(l.get("cycles", 1)))})
    nods = {round(((l["phase"] + j) / int(l.get("cycles", 1))) % 1.0, 4): float(l.get("nod", 1.0)) for l in limbs for j in range(int(l.get("cycles", 1)))}

    def foot(l, p):
        """Where a limb's end goes at phase p, in the model's rest frame: (y, z, down)."""
        e = l["at"][2]
        k = int(l.get("cycles", 1))
        sw = sweep / k
        y0 = e[1] + l.get("shift", 0.0)
        q = (p * k - l["phase"]) % 1.0
        if q < duty:
            return y0 + sw * 0.5 - sw * (q / duty), e[2], True
        s = (q - duty) / (1.0 - duty)
        u = min(1.0, max(0.0, (s - 0.12) / 0.76))
        y = y0 - sw * 0.5 + sw * u * u * (3.0 - 2.0 * u)
        if stomp:
            if s < 0.25:
                r = s / 0.25
                z = e[2] + lift * (1.0 - (1.0 - r) ** 3)      # up briskly
            elif s < 0.8:
                z = e[2] + lift                               # held high, reaching forward
            else:
                r = (s - 0.8) / 0.2
                z = e[2] + lift * (1.0 - r * r * r)           # slammed down
            return y, z, False
        if s < 0.3:
            r = s / 0.3
            z = e[2] + lift * (1.0 - (1.0 - r) * (1.0 - r))   # up briskly, easing at the top
        elif s < 0.62:
            z = e[2] + lift
        else:
            r = (s - 0.62) / 0.38
            z = e[2] + lift * (1.0 - r * r)                   # down gathering speed: the stomp
        return y, z, False

    # The body first: as high as its planted legs allow kept short of straight, lower by the
    # crouch, dropping and nodding as each foot lands and taking most of the stride between
    # landings to come back up.
    rides, jolts, pitch_jolts = [], [], []
    for i in range(n + 1):
        p = i / float(n)
        ride = 0.0
        for l in limbs:
            y, z, down = foot(l, p)
            if not down and airborne is None:
                continue
            h3, k3, e3 = l["at"]
            span = (reach if down else airborne) * (math.hypot(k3[1] - h3[1], k3[2] - h3[2]) + math.hypot(e3[1] - k3[1], e3[2] - k3[2]))
            dy = y - h3[1]
            ride = min(ride, z + math.sqrt(max(0.0, span * span - dy * dy)) - h3[2])
        jolt = 0.0
        pitch_jolt = 0.0
        for land in landings:
            x = ((p - land) % 1.0) * loop   # in steps, so a landing's dip lasts as long whatever the cycle
            if stomp:
                # A hard drop in a moment, then a damped shudder: a rebound past level and a settle.
                j = x / 0.03 if x < 0.03 else (math.exp(-(x - 0.03) / 0.09) * math.cos((x - 0.03) * 2.0 * math.pi / 0.16) if x < 0.45 else 0.0)
            elif x < 0.05:
                j = x / 0.05
            elif x < 0.4:
                r = (x - 0.05) / 0.35
                j = (1.0 - r) * (1.0 - r)
            else:
                j = 0.0
            jolt += j
            pitch_jolt += j * nods[land]
        rides.append(ride)
        jolts.append(jolt)
        pitch_jolts.append(pitch_jolt)
    if smooth > 0.0:
        # The lowest within a window either side, then its mean over the same window: every
        # value the mean takes is at or under the ride at the middle, so no leg overreaches.
        w = max(1, int(round(smooth * n)))
        low = [min(rides[(i + j) % n] for j in range(-w, w + 1)) for i in range(n)]
        rides = [sum(low[(i + j) % n] for j in range(-w, w + 1)) / (2 * w + 1) for i in range(n)]
        rides.append(rides[0])
    pose = [(rides[i] - crouch - dip * jolts[i], -nod * pitch_jolts[i]) for i in range(n + 1)]
    tracks = {}
    for l in limbs:
        rows = {"hip": [], "knee": [], "ankle": []}
        for i in range(n + 1):
            p = i / float(n)
            y, z, _down = foot(l, p)
            dz, pitch = pose[i]
            a, b, c = _limb_angles(l, _to_body(y, z, 0.0, dz, pitch), pitch)
            rows["hip"].append((p, round(a, 3)))
            rows["knee"].append((p, round(b, 3)))
            rows["ankle"].append((p, round(c, 3)))
        tracks[l["hip"]] = (rows["hip"], 0.0)
        tracks[l["knee"]] = (rows["knee"], 0.0)
        if l.get("ankle"):
            tracks[l["ankle"]] = (rows["ankle"], 0.0)
    body = [(i / float(n), 0.0, 0.0, round(dz, 3), 0.0, round(pitch, 3), 0.0) for i, (dz, pitch) in enumerate(pose)]
    return tracks, body, stride


def _gallop(limbs, sweep, duty=0.34, lift=16.0, crouch=1.0, hop=3.0, rock=4.0, dip=2.0, reach=0.97, smooth=0.03, n=160):
    """A heavy slow gallop (Ryan, 6 October, the eighth notes: the stomp looked stuck to the
    ground on suction cups; try the gallop, for fun): a transverse gallop, the hind pair
    landing one after the other, then the fore pair, each hoof down `duty` of the stride
    sweeping back `sweep` units, then all four gathered under the body for a moment off the
    ground. The body rocks as a horse's does, the nose highest as it comes down out of the
    air onto its hind hooves and lowest as it rides over the fore pair, `rock` degrees either
    way; it rises `hop` units in the moment off the ground and drops `dip` as each pair takes
    its weight, `crouch` under its rest height, never higher than its planted legs allow kept
    `reach` of straight (pitch and all). In the air a hoof folds up high and reaches forward
    to land. A limb is a dict as _plant takes, with "phase" its landing in the stride and
    "shift" its stance's centre. Returns (tracks, body, stride) for b.gait, ease linear."""
    stride = sweep / duty
    landings = sorted(l["phase"] for l in limbs)

    def foot(l, p):
        e = l["at"][2]
        y0 = e[1] + l.get("shift", 0.0)
        q = (p - l["phase"]) % 1.0
        if q < duty:
            return y0 + sweep * 0.5 - sweep * (q / duty), e[2], True
        s = (q - duty) / (1.0 - duty)
        u = min(1.0, max(0.0, (s - 0.08) / 0.8))
        y = y0 - sweep * 0.5 + sweep * u * u * (3.0 - 2.0 * u)
        if s < 0.3:
            r = s / 0.3
            z = e[2] + lift * (1.0 - (1.0 - r) ** 2)          # snatched up off the ground
        elif s < 0.7:
            z = e[2] + lift                                    # folded high, carried forward
        else:
            r = (s - 0.7) / 0.3
            z = e[2] + lift * (1.0 - r * r)                    # reaching down to land
        return y, z, False

    last_off = max(((l["phase"] + duty) % 1.0, l) for l in limbs)[0]
    first_on = landings[0]
    air = ((first_on - last_off) % 1.0) or 0.1
    mid_air = (last_off + air * 0.5) % 1.0

    def pitch_at(p):
        return rock * math.cos(2.0 * math.pi * (p - (first_on - 0.02)))   # nose up landing on the hinds, down over the fores

    def bump(p, c, w):
        x = ((p - c + 0.5) % 1.0) - 0.5
        return math.cos(math.pi * x / w) ** 2 if abs(x) < w else 0.0

    pose = []
    for i in range(n + 1):
        p = i / float(n)
        th = pitch_at(p)
        c, sn = math.cos(math.radians(th)), math.sin(math.radians(th))
        want = -crouch + hop * bump(p, mid_air, air * 1.4)
        for land in landings:
            want -= dip * 0.5 * bump(p, land + 0.06, 0.12)
        cap = 1e9
        for l in limbs:
            y, z, down = foot(l, p)
            if not down:
                continue
            h3, k3, e3 = l["at"]
            span = reach * (math.hypot(k3[1] - h3[1], k3[2] - h3[2]) + math.hypot(e3[1] - k3[1], e3[2] - k3[2]))
            hy, hz = h3[1] * c - h3[2] * sn, h3[1] * sn + h3[2] * c
            cap = min(cap, z + math.sqrt(max(0.0, span * span - (hy - y) ** 2)) - hz)
        pose.append([min(want, cap), th])
    if smooth > 0.0:
        w = max(1, int(round(smooth * n)))
        zs = [q[0] for q in pose[:n]]
        low = [min(zs[(i + j) % n] for j in range(-w, w + 1)) for i in range(n)]
        zs = [sum(low[(i + j) % n] for j in range(-w, w + 1)) / (2 * w + 1) for i in range(n)]
        for i in range(n):
            pose[i][0] = zs[i]
        pose[n][0] = zs[0]
    tracks = {}
    for l in limbs:
        rows = {"hip": [], "knee": [], "ankle": []}
        for i in range(n + 1):
            p = i / float(n)
            y, z, _down = foot(l, p)
            dz, th = pose[i]
            a, b, c = _limb_angles(l, _to_body(y, z, 0.0, dz, th), th)
            rows["hip"].append((p, round(a, 3)))
            rows["knee"].append((p, round(b, 3)))
            rows["ankle"].append((p, round(c, 3)))
        tracks[l["hip"]] = (rows["hip"], 0.0)
        tracks[l["knee"]] = (rows["knee"], 0.0)
        if l.get("ankle"):
            tracks[l["ankle"]] = (rows["ankle"], 0.0)
    body = [(i / float(n), 0.0, 0.0, round(dz, 3), 0.0, round(th, 3), 0.0) for i, (dz, th) in enumerate(pose)]
    return tracks, body, stride


def _loop(r, t0, t1, duration, back=26.0, run=16.0, steps=16):
    """Body keys for a loop (Ryan, 5 October; the sixth notes: quicker, and more travel before
    it pulls up): it drifts back `back` with the nose a touch up, runs in `run` forward with
    the nose down, and at `t0` pulls up round a circle of radius `r` standing on its path, up,
    over on its back and down, the nose along the path, done at `t1`; it comes out still
    travelling, flares and brakes onto its hex, a whole turn on (the rig takes it the short way
    home). Keys as (t, dx, dy, dz, yaw, pitch, roll)."""
    y0 = run - back
    keys = [(round(t0 - 0.45, 3), 0.0, -back, -1.0, 0.0, 5.0, 0.0),
            (round(t0 - 0.22, 3), 0.0, round(-back + run * 0.25, 3), -1.5, 0.0, -6.0, 0.0)]
    for i in range(steps + 1):
        u = i / float(steps)
        th = 2.0 * math.pi * u
        keys.append((round(t0 + (t1 - t0) * u, 3), 0.0, round(y0 + r * math.sin(th), 3), round(r * (1.0 - math.cos(th)), 3), 0.0, round(math.degrees(th), 3), 0.0))
    keys.append((round(t1 + 0.5, 3), 0.0, 0.0, 0.6, 0.0, 368.0, 0.0))
    keys.append((round(t1 + 0.95, 3), 0.0, 0.0, 0.0, 0.0, 360.0, 0.0))
    keys.append((duration, 0.0, 0.0, 0.0, 0.0, 360.0, 0.0))
    return keys


def _barrel_roll(t0, t1, over, duration, surge=4.0):
    """Body keys for a barrel roll about its own fuselage (Ryan, the fifth notes; the sixth:
    quicker, with some inertia, and turning on the fuselage, not on the middle of a box that
    takes in the tail, so no corkscrew): a dip and a kick the other way to gather before
    `t0`, then once round to the right by `t1` and `over` degrees past, back short of level
    and settled, the whole while surging a little forward and back. Held a whole turn on to
    the act's end (the rig takes it the short way home). The body turns about the model's
    origin, which is on the fuselage's centreline. Keys as (t, dx, dy, dz, yaw, pitch, roll)."""
    return [(round(t0 * 0.6, 3), 0.0, 0.0, -1.0, 0.0, -4.0, 0.0),
            (t0, 0.0, 0.3, -1.0, 0.0, -3.0, -10.0),
            (t1, 0.0, surge, 1.2, 0.0, -1.0, 360.0 + over),
            (round(t1 + 0.3, 3), 0.0, round(surge * 0.75, 3), 1.0, 0.0, 0.0, round(360.0 - over * 0.35, 3)),
            (round(t1 + 0.6, 3), 0.0, round(surge * 0.4, 3), 0.5, 0.0, 0.0, round(360.0 + over * 0.12, 3)),
            (round(t1 + 0.95, 3), 0.0, 0.0, 0.2, 0.0, 0.0, 360.0),
            (duration, 0.0, 0.0, 0.0, 0.0, 0.0, 360.0)]


def _survey_circle(r=66.0, bank=34.0, side=1.0, t0=0.3, vmax=110.0, rise=6.0, steps=72):
    """Body keys for a circling flight beside its hex (Ryan, 6 October, after the eighth notes:
    no right peel, just a smooth circle). One true circle of radius `r`, flown once round from
    the hex along its facing and back onto the hex along its facing, so it never slides: the
    hex is on the circle's edge, the circle to its right (`side` 1; -1 to its left, the eleventh
    notes turning it right so it and the figure eight, which starts left, go different ways).
    It gathers speed from rest at an even rate over the first eighth of the way round and
    sheds it the same way over the last, stopping on its hex (the eleventh notes: it had come
    in at a third of its speed and stopped dead, a slide into the finish), `vmax` units a second
    between (the ninth and tenth notes: quicker), the nose always along the path, the bank
    coming on with the speed to a steady `bank` degrees toward the turn and easing off as it
    slows, the nose a little down at speed, rising `rise` units over the far side. Keys as (t,
    dx, dy, dz, yaw, pitch, roll)."""
    n = 720
    length = 2.0 * math.pi * r

    def pace(u):
        return max(1e-3, min(1.0, math.sqrt(u / 0.12), math.sqrt(max(0.0, 1.0 - u) / 0.12)))

    clock = [0.0]
    for i in range(n):
        clock.append(clock[-1] + length / n / (vmax * pace((i + 0.5) / n)))
    t1 = round(t0 + clock[-1], 3)
    keys = [(t0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)]
    j = 0
    for k in range(1, steps):
        tt = clock[-1] * k / float(steps)
        while j < n and clock[j + 1] < tt:
            j += 1
        u = (j + (tt - clock[j]) / (clock[j + 1] - clock[j])) / n   # the share of the way round at this key
        th = 2.0 * math.pi * u
        v = pace(u)
        keys.append((round(t0 + clock[-1] * k / float(steps), 3), round(side * (r - r * math.cos(th)), 3), round(r * math.sin(th), 3), round(rise * math.sin(math.pi * u) ** 2, 3),
                     round(-side * math.degrees(th), 3), round(-3.0 * v, 3), round(side * bank * v * v, 3)))
    keys.append((t1, 0.0, 0.0, 0.0, round(-side * 360.0, 3), 0.0, 0.0))
    keys.append((round(t1 + 0.4, 3), 0.0, 0.0, 0.0, round(-side * 360.0, 3), 0.0, 0.0))
    return keys

def _figure_eight(radius=40.0, sharp=1.5, bank=-40.0, t0=0.3, vmax=110.0, rise=6.0, steps=84):
    """Body keys for a figure eight over its hex (Ryan, 6 October, the ninth notes: to see one
    against the circle; the tenth: smooth out the bank change, cross the hex on a diagonal, a
    larger radius, quicker). The eight is laid out by its curvature: each lobe turns by the
    curvature sin(pi u)^`sharp` along it (u the share of the lobe), nothing where it meets the
    hex and tightest, `radius` units, at the lobe's far end, so the bank rolls evenly through
    level as it crosses the hex between lobes and never snaps. Each lobe turns through 180
    degrees and twice the crossing's half angle, the angle that closes the lobe back on the hex
    (solved here; 40 degrees at `sharp` 1.5, so the two passes over the hex cross 80 degrees
    apart, on the diagonal). It leaves its hex along its facing into the left lobe, crosses
    back over the hex at speed into the right lobe, and settles back onto its hex along its
    facing, so it never slides. The speed gathers from rest at an even rate over the first
    tenth and is shed the same way over the last, the bank following the turn (soft capped near
    `bank`) and the speed, rising `rise` units over each lobe's far end. Keys as (t, dx, dy,
    dz, yaw, pitch, roll)."""
    n = 1200
    w = [math.sin(math.pi * (i + 0.5) / n) ** sharp for i in range(n)]
    total_w = sum(w)

    def lobe(alpha, length, side):
        turn = math.radians(180.0 + 2.0 * alpha)
        x = y = th = 0.0
        out = []
        for i in range(n):
            d = side * turn * w[i] / total_w
            th += d * 0.5
            x += -math.sin(th) * length / n
            y += math.cos(th) * length / n
            th += d * 0.5
            out.append((x, y, th, d / (length / n)))
        return out

    alpha = min((math.hypot(*lobe(a / 20.0, 1.0, 1.0)[-1][:2]), a / 20.0) for a in range(200, 1600))[1]
    turn = math.radians(180.0 + 2.0 * alpha)
    length = radius * turn * max(w) * n / total_w   # the lobe whose tightest turn is `radius`
    first = lobe(alpha, length, 1.0)
    pts = [(0.0, 0.0, 0.0, 0.0)] + first
    for x, y, th, k in lobe(alpha, length, -1.0):   # the right lobe from the hex at the left lobe's last heading
        c, sn = math.cos(turn), math.sin(turn)
        pts.append((x * c - y * sn, x * sn + y * c, turn + th, k))
    ds = length / n
    total = ds * (len(pts) - 1)

    def pace(u):   # from rest and back to rest at an even rate (the eleventh notes)
        return max(1e-3, min(1.0, math.sqrt(u / 0.1), math.sqrt(max(0.0, 1.0 - u) / 0.1)))

    clock = [0.0]
    for i in range(1, len(pts)):
        clock.append(clock[-1] + ds / (vmax * pace((i - 0.5) / (len(pts) - 1))))
    t1 = round(t0 + clock[-1], 3)
    kmax = max(abs(q[3]) for q in pts)
    keys = [(t0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)]
    j = 0
    for k in range(1, steps):
        tt = clock[-1] * k / float(steps)
        while j < len(pts) - 2 and clock[j + 1] < tt:
            j += 1
        x, y, th, kap = pts[j]
        u = j / float(len(pts) - 1)
        v = pace(u)
        half = (u * 2.0) % 1.0   # the share of the way round this lobe
        roll = 48.0 * math.tanh((bank / 48.0) * kap / kmax * 1.6) * v * v
        keys.append((round(t0 + clock[-1] * k / float(steps), 3), round(x, 3), round(y, 3), round(rise * math.sin(math.pi * half) ** 2, 3),
                     round(math.degrees(th), 3), round(-3.0 * v, 3), round(roll, 3)))
    keys.append((t1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0))
    keys.append((round(t1 + 0.4, 3), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0))
    return keys


def _swing(amp, phase=0.0, n=40):
    """A limb swung evenly fore and aft over a stride, at its most forward at `phase`: dense
    keys for a gait played "linear"."""
    return [(i / float(n), round(amp * math.cos(2.0 * math.pi * (i / float(n) - phase)), 3)) for i in range(n + 1)]

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
    _missile_face(b, (-7.0 * s, 11.0 * s, -7.0 * s), up, right, fwd, 14.0 * s, "rack_face")
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

"""The units, each from Ryan's brief (21 September), massed in the Descent register: few
facets, every one deliberate. x right, y forward, z up; a mech is about 60 units wide.
Tile names after the dot pick the texture; the role before it is what the engine reads.
Every number here is a proportion Ryan may change; the render is a minute away.
Function names are chassis ids (content/chassis.json), so the build lands where the
engine looks: art/models/<id>.glb.
"""

import bisect
import math
import os

import bmesh
from mathutils import Matrix, Vector

from bl_low import TILE_WORLD, boom, diamond, hexagon, pin_frame, rect


def badger(b):
    """Minerva "Honey Badger": heavy machinery, mining roots, boxy and indestructible. Treads;
    a low reinforced frame with a raised engine deck; the cockpit tucked into the front of the
    frame under a brow, between two cheeks, so it survives a cave-in; two excavator booms
    pivoting on the frame's flanks at mid-length (not shoulders), reaching forward past the
    cockpit; an outsized claw on the left, the defining feature; the Bullion Fragmenter on the
    right, a sawed-off cannon with a crusher hopper built in (6 October: the Slug Cannon converted to melee and
    locked to the Badger, the second claw gone, so the right boom's mount is no hardpoint and
    the pins run hp_1 the deck's ring, hp_2 left gimbal, hp_3 right gimbal); floodlights,
    vents, a ladder, a hatch. Since the stock pass (22 October) its stock is the Rivet Gun
    alone, on the deck's ring as its class shape, the gimbals bare; the missile box and the
    gimbal's autoguns went with the old stock (Ryan's go, 28 October)."""
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
        # drum under a turret joint that traverses, a bare mount on each (hp_2 left, hp_3
        # right: the stock's Canopy and Coolant Jacket show nowhere).
        b.prism("z", cx, -6.0, 54.5, 5.2, 1.0, "steel.dark", 8, "gimbal_ring")
        with b.joint("turret_%s" % ("l" if s < 0 else "r"), (cx, -6.0, 55.0), limits=(-80.0, 80.0)):
            b.prism("z", cx, -6.0, 57.0, 4.4, 4.0, "steel.plate", 8, "gimbal", phase=math.pi / 8)
            b.pad("hp_%d" % (2 if s < 0 else 3), (cx, -6.0, 60.0), size=(6.0, 1.0))   # on the gimbal's centre (Ryan, 1 October)
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
                        # Its business end, riding the wrist: the blast flares at the sawn mouth and
                        # the wrist kicks as it fires (Ryan's go of 3 November).
                        b.fx("bullion_fragmenter", (wx, wy + 31.5, wz), size=26.0)
    # The deck gun on a ring right of centre (hp_1): the stock's Rivet Gun as its class, its
    # barrel forward over the brow; no joint, as the missile box it replaced had none (Ryan,
    # 1 October), so it never spins.
    b.prism("z", 7.0, -13.0, 46.5, 8.0, 1.0, "steel.dark", 8, "ring")
    b.stock("hp_1", (7.0, -12.0, 50.6), "barrel", scale=0.9, carries="rivet_gun")

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
    b.fires = {"chainsaw_claw": ("test_claw", 1.6, 2.9)}   # its fixed weapon fires with a slice of its act: the claw's snap (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.pivots = True   # its tracks turn it on the spot to aim the gun on its hull and the claw, as a tank's neutral turn (Ryan, 31 October: "a cheap way of aiming")
    b.move(accel=1.2, heft=0.2)

badger.maker = "minerva"


# Kestrel's boosters bloom as a halo, Aphelion's as a plume (Ryan, 3 November: "I would apply it to
# all Aphelion boosters as a rule, and keep the aura glow for Kestrel's boosters, that's the
# difference we've been missing"); a booster's shape may want the other (the Kite's wingtip drivers
# take plumes "due to their shape"). And Kestrel's bloom louder (the same day: "Kestrel boosters
# aren't all that impressive when they bloom. It's too subtle at phone scale"): a halo this much
# larger and stronger than a vent's, and the burn on the move this much hotter.
CHEST_FLARE = 1.6   # how much hotter the Nemesis's chest furnace flares than the parts it lights with (Ryan, 3 November)
VENT_FLARE = 0.7    # the Arsenal's rear vents' flares on their sickly amber (the fume tile): their old peaks of twelve to sixteen clipped it to a lemon yellow


def _flare_scale(b, part, k):
    """Every act's flare on `part` k times as hot, the part split out of any glow it shares, so one
    lit part can flare past (or short of) the rest it lights with (Ryan, 3 November, the second
    notes: the Nemesis's chest "bumped up even more when it flares"; the Arsenal's vents a sickly
    orange-yellow, their flares kept gold on their brighter tile). Run after the acts are made."""
    for a in b.acts:
        rows = []
        for g in a["glow"]:
            if part in g["parts"]:
                if len(g["parts"]) > 1:
                    rows.append({"parts": [p for p in g["parts"] if p != part], "keys": g["keys"]})
                rows.append({"parts": [part], "keys": [[t, round(v * k, 2)] for t, v in g["keys"]]})
            else:
                rows.append(g)
        a["glow"] = rows
KESTREL_HALO = 1.8
KESTREL_BURN = 8.0    # a light multiple at full speed (the gait's glow k): 5 before
KESTREL_HEAVY = 7.0   # the heavy flyers' (the Lammergeier, the Giant Petrel): 4 before

def kite(b):
    """Kestrel "Kite": a small hit-and-run interceptor. Sleek, speed over defence;
    reverse-swept wings whose rear faces run back into the boosters, a faired canopy far
    back, twin nose guns, two big boosters, a tail rooted into the fuselage and riding over
    the boosters, its top edges chamfered (12 November), ending in two angled stabilisers. Small but deadly. Reskinned 22 September
    to Kestrel's metals: the body in chrome plate, the wings cobalt, the boosters dark (the
    bone body predated the palettes). Since its rework (21 October) it carries the Pinion
    Driver locked and two hardpoints, three since 11 November, and Ryan, 28 October: "both wingtips be the 'Pinion
    Drivers'... Then the nose mounts are the hardpoints. Then the wingtips can maintain a
    streamlined symmetrical appearance based on what the drivers look like." So a matched
    driver at each tip, fixed, no pin, each a ramjet-gun (Ryan, 29 October: "a kind of
    mini-booster, barrel forwards with a tapered exhaust behind... Like a ramjet-gun"): a
    chrome drum like the boosters' tapering aft to a lit exhaust, a dark inlet ahead ringed by
    gear teeth (the pinion, a wing's flight feathers and a gear) whose backs run aft as strakes
    tapering into the drum, the barrel out of the inlet's centre, its muzzle lit; each fires one of the Driver's two shots. The nose mounts either
    side of the nosecone, hp_1 the stock's Transonic Rifle as its class, hp_2 bare, at half scale,
    the machine being small; hp_3, bare, ahead of the canopy on the centreline: a port under a
    low curved hood, every class there its port form coming out of a round bore drilled in the
    hood's mouth into a short round cut in the nose: the port gun's barrel running down the
    nose to its muzzle, a launcher the port rack, a dish on a telescoping mast clear of the
    hood (Ryan, 12 November: "in front of the canopy, but inset, like the polar bear"; "sink it
    horizontally into the hull more, so the actual mount block is hidden"; "a round rack would
    be warranted when a missile is slotted there"; "slap a gentle curved fairing overtop of the
    back of the mount point, to hide the poking-out edge"; the trough it first lay in filled,
    "Can we make a little round cut under, just long enough that the rack isn't covered?").
    The tail segment's flat face behind the canopy is an air intake, a dark mouth in a steel lip
    (the same day: "Can the flat face behind the canopy also get an intake treatment?"), both
    taking the face's shape once its top corners were chamfered."""
    # Fuselage: one piece, a six-sided section lofted from a needle nose to a broad rear.
    # The top tapers sharply toward the nose, the belly shallowly, and the belly carries
    # forward under the wing roots (Ryan, 21 September).
    fuselage = b.loft([(46.0, _fuse(1.2, 0.6, 0.5)), (36.0, _fuse(6.0, 2.2, 2.0)), (18.0, _fuse(12.0, 3.8, 3.4)),
                       (0.0, _fuse(16.0, 6.4, 4.6)), (-16.0, _fuse(18.0, 7.0, 4.8)), (-30.0, _fuse(15.0, 5.4, 4.0))], "steel.plate", "fuselage")
    b.loft([(38.0, diamond(0.0, 0.5, 2.0, 1.5)), (46.0, diamond(0.0, 0.5, 1.0, 0.7))], "steel.dark", "nose_tip")
    # The nose mounts, one either side of the nosecone on its fairing (Ryan, 30 September:
    # two nose hardpoints, sleeker than one; 28 October: the nose mounts are the hardpoints):
    # hp_1 the left, the stock's Transonic Rifle as its class; hp_2 the right, bare.
    for s in (-1.0, 1.0):
        b.box(s * 4.5 - 1.5, s * 4.5 + 1.5, 22.0, 30.0, -2.5, 1.0, "steel.plate", "gun_fairing")
        if s < 0:
            b.stock("hp_1", (s * 4.5, 28.0, -1.0), "barrel", scale=0.5, carries="transonic_rifle")
        else:
            b.pad("hp_2", (s * 4.5, 30.0, -1.0), scale=0.5, size=(3.0, 1.0))
    # The third mount (its fourth entry, Ryan, 11 November: "giving it 4 faces again"), ahead of
    # the canopy on the centreline, fixed, no joint. Its form after a day of rounds on the 12th,
    # shipped on the 13th on his "Ship it": a port seven ahead of the canopy's nose under a low
    # hood, the weapon coming out of a round bore drilled in the hood's mouth into a short round
    # cut in the nose. The rounds that shaped it, in order: "in front of the canopy, but inset,
    # like the polar bear"; "sink it horizontally into the hull more, so the actual mount block
    # is hidden"; the port pushed forward ("push the barrel horizontally forward, moving the back
    # of the cut with it but not the front", and twice more) and the line raised ("Move the mount
    # vertically up a little bit"; a unit's drop from there tried and taken back, "Maybe revert
    # the drop"). The trough cut down the nose that the weapon first lay in was filled ("I want
    # to see what filling in the cut looks like now"), the round cut below taking its place for
    # a launcher.
    GZ = 5.6                  # the gun's line
    PORT = 5.0                # the port: the mount point, seven ahead of the canopy's nose
    # Every class here is its port form, starting at the mount, its root inside the hood: the
    # port gun (the barrel alone), the port pair for twin barrels (the standard pair had to be
    # sunk far back to hide its receiver: "Twin barrel isn't sticking out as far as it was"),
    # the port rack for a launcher, the round one longer and thinner (his: "it would look the
    # same, but be a bit longer and thinner"), and the port dish on its telescoping mast, so it
    # stands clear of the hood ("The dish will need an extension of some kind so it's not just
    # covered"), at the launcher's scale, so the launcher's diameter ("the dish model needs to be
    # a bit smaller, same diameter as the rack"), and a unit forward of the mount, its sleeve's
    # root still under the hood. The standard shapes were tried here and taken back the same
    # day ("Just for fun ..."; "Ok go back to port gun"). The blade's place is a guess.
    NOSE_FITS = {"barrel": "barrel_port", "rack": ("rack_port", 0.6), "twin_barrel": ("twin_barrel_port", 0.92), "dish": ("dish_port", 0.6, -2.0), "blade": ("blade", 0.7)}
    b.pin("hp_3", (0.0, PORT, GZ), scale=0.5, carries="", fits=NOSE_FITS)
    # The hood over the port (his: "we slap a gentle curved fairing overtop of the back of the
    # mount point, to hide the poking-out edge"; then "carry the fairing forward more, over the
    # mount point, covering more of the weapon"): forward of the canopy the spine falls away
    # under the weapon's level line, so its root stood proud of it. A low arch rising gently off
    # the spine to clear the weapon's root at the mount point, its crown running level from there
    # over the weapon to four past it while the nose falls away under it, so its mouth is the
    # tallest of it; wide enough that its lip rests on the hull either side of the weapon, which
    # comes out of its dark mouth. Its arch sinks into the hull, so it meets the spine with no seam.
    def spine(y):
        return 6.4 - (6.4 - 3.8) * y / 18.0    # the fuselage's top between its sections at 0 and 18
    HOOD_W, HOOD_SUNK = 2.7, 0.4
    HOOD_TOP = GZ + 1.65           # its crown: a barrel's flat top (1.2 over the line) and a little
    HOOD_TAIL, HOOD_LIP = PORT - 3.5, PORT + 4.0
    hood = []
    for y in [HOOD_TAIL + (PORT - HOOD_TAIL) * u for u in (0.0, 0.2, 0.4, 0.6, 0.8, 1.0)] + [PORT + 1.0, PORT + 2.5, HOOD_LIP]:
        u = min(1.0, (y - HOOD_TAIL) / (PORT - HOOD_TAIL))
        crown = spine(HOOD_TAIL) + (HOOD_TOP - spine(HOOD_TAIL)) * (1.0 - (1.0 - u) ** 2)   # eased up off the spine, then level
        rise = max(0.0, crown - spine(y)) + HOOD_SUNK
        hw = HOOD_W * (0.35 + 0.65 * math.sqrt(min(1.0, (y - HOOD_TAIL) / (PORT + 1.0 - HOOD_TAIL))))
        hood.append((y, [(hw * math.cos(math.pi * i / 8.0), spine(y) - HOOD_SUNK + rise * math.sin(math.pi * i / 8.0)) for i in range(9)]))
    hood_part = b.loft(hood, "steel.plate", "port_hood")
    y, mouth = hood[-1]
    hood_mouth = b.loft([(y + 0.02, mouth), (y + 0.06, mouth)], "bore.dark", "port_hood_mouth")
    # A little round cut under the weapon (his: "Can we make a little round cut under, just
    # long enough that the rack isn't covered?"): a channel round the line a little wider than
    # the launcher's drum, from just inside the hood's mouth to just past the launcher's face
    # (5.6 past the mount at its fit), its floor ramped up to the surface beyond,
    # so the nose no longer covers the launcher's underside. Sized to the launcher alone, as
    # close as clears its drum (his, the same day: "shrink the diameter of the hood cut too, as
    # it's a bit big right now anyway"): twin barrels are wider and still touch the nose at their
    # sides. The same bore drills two back into the hood along the line, through its mouth and
    # under its crown, never through its top ("I didn't mean right through the top. I meant drill
    # it out a bit following the hood cut"), the weapon coming out of a round hole in it two
    # sooner, the hole lined dark to its floor.
    CUT_R, CUT_END, CUT_BACK = 1.53, PORT + 5.9, PORT + 2.0
    def ring(y, z):
        return [(CUT_R * math.cos(math.pi * i / 8.0), y, z + CUT_R * math.sin(math.pi * i / 8.0)) for i in range(16)]
    b.cut_hull([fuselage, hood_part, hood_mouth], ring(CUT_BACK, GZ) + ring(CUT_END, GZ) + ring(CUT_END + 1.6, spine(CUT_END + 1.6) + CUT_R))
    _tube(b, (0.0, CUT_BACK, GZ), (0.0, HOOD_LIP + 0.04, GZ), CUT_R - 0.02, CUT_R - 0.1, 16, "bore.dark", "port_bore", floor_material="bore.dark", floor_depth=0.05)
    # Canopy: far back, low, faired into the spine rather than a bubble.
    b.loft([(-2.0, hexagon(0.0, 6.2, 7.0, 0.5)), (-10.0, hexagon(0.0, 7.4, 9.0, 3.0)),
            (-18.0, hexagon(0.0, 7.5, 9.0, 3.2)), (-26.0, hexagon(0.0, 7.2, 9.0, 3.0))], "glass.glass", "canopy")
    # (The old scoop behind it, run through the tail with slits standing out of its flanks, is
    # gone, Ryan, 12 November: "The weird vent jammed through the middle can get taken out".)
    # Reverse-swept wings with a little anhedral, knife-edged at the front (a three-point
    # section: the leading edge is one line), the root's trailing edge running back into
    # the boosters; a Pinion Driver at each tip. The root sits inside the fuselage
    # (Ryan, 6 October, the ninth notes: the wings did not quite meet the fuselage at the
    # front, where it narrows to 7.3 either side of the centreline and the root stood at 8).
    # The leading edge angled more (Ryan, 12 November: "can we angle the forward face of the
    # wings a bit more, to make it a bit more aggressive?", then "Maybe a little more? Just so it
    # reads well at skirmish view"): its root drawn back from 6 to -2, the tip on its driver where
    # it was, so the edge runs out at about 32 degrees off square where it ran at 17. Then the back
    # edge the same way ("What if we pulled the back edge back a bit, making that a sharper angle
    # as well?"): its root, inside the booster, drawn back from -32 to -38, so it sweeps at about
    # 60 degrees where it swept at 56 and leaves the booster four and a half further back.
    for s in (-1.0, 1.0):
        root = [(s * 6.5, -38.0, -1.0), (s * 6.5, -38.0, 1.4), (s * 6.5, -2.0, 0.2)]
        tip = [(s * 32.0, 6.0, -5.4), (s * 32.0, 6.0, -4.6), (s * 32.0, 14.0, -5.0)]
        _wing(b, root, tip, "livery.livery", "wing")
        # The Pinion Driver at the tip, the same both sides (fixed, no pin), a ramjet-gun
        # (Ryan, 29 October: "a kind of mini-booster, barrel forwards with a tapered exhaust
        # behind, something that looks like it gives an extra boost of speed on a kill"): a
        # chrome six-sided drum like the boosters', a lit ring round it and its tail tapering
        # to a lit exhaust; ahead, a dark inlet with the toothed lip (the pinion: a wing's
        # flight feathers, and a gear), the barrel running out of its centre as a ramjet's
        # spike, the muzzle lit.
        tx, tz = s * 32.0, -4.8
        b.loft([(-9.0, _hexr(tx, tz, 2.0)), (-3.5, _hexr(tx, tz, 3.0)), (0.0, _hexr(tx, tz, 3.5)), (12.0, _hexr(tx, tz, 3.5))], "steel.plate", "driver")
        b.prism("y", tx, -1.4, tz, 3.75, 1.4, "amber.engine", 6, "driver_ring", phase=math.pi / 6)
        b.loft([(-9.0, _hexr(tx, tz, 1.85)), (-9.4, _hexr(tx, tz, 1.6))], "amber.exhaust", "driver_exhaust")
        _tube(b, (tx, 11.5, tz), (tx, 16.5, tz), 3.5, 2.6, 6, "steel.plate", "driver_inlet", phase=math.pi / 6)
        # Each tooth's back face runs aft as a strake, tapering down the drum until it meets it
        # (Ryan, 29 October: "extend the back face, tapering it down the length of the ramjet
        # a bit till it meets"); its front stays the gear's face round the lip.
        for k in range(10):
            u = Vector((math.cos(k * math.pi / 5.0), 0.0, math.sin(k * math.pi / 5.0)))
            t = Vector((-u.z, 0.0, u.x))
            tooth = lambda y, r0, r1, w0, w1, u=u, t=t: [tuple(Vector((tx, y, tz)) + u * r + t * w) for r, w in ((r0, -w0), (r0, w0), (r1, w1), (r1, -w1))]
            _rings(b, [tooth(16.5, 3.2, 4.4, 0.6, 0.4), tooth(15.3, 3.2, 4.4, 0.6, 0.4), tooth(9.0, 2.8, 3.0, 0.45, 0.3)], "steel.dark", "pinion")
        b.loft([(12.0, _hexr(tx, tz, 1.8)), (17.5, _hexr(tx, tz, 0.95))], "steel.dark", "driver_spike")
        b.prism("y", tx, 24.0, tz, 0.8, 13.0, "steel.dark", 6, "driver_rail")
        b.prism("y", tx, 30.8, tz, 1.1, 0.8, "amber.engine", 6, "driver_muzzle")
    # Boosters: two big six-sided drums under and behind the cockpit, red glow at the back.
    for s in (-1.0, 1.0):
        b.prism("y", s * 7.5, -32.0, -1.0, 6.0, 28.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", s * 7.5, -47.0, -1.0, 6.5, 2.0, "amber.engine", 6, "booster_ring", phase=math.pi / 6)   # lit: the amber role glows
        b.loft([(-48.0, hexagon(s * 7.5, -1.0, 11.0, 9.5)), (-48.5, hexagon(s * 7.5, -1.0, 10.0, 8.5))], "amber.exhaust", "exhaust")
    # Tail: rooted into the fuselage with a keel, riding over the boosters, two angled
    # stabilisers at the end. Its top edges chamfered, a little at its face, where the intake
    # needs the room, and more aft (Ryan, 12 November: "the tail is kind of boring next to the new
    # designs. Can we chamfer the top edges of it, make it a bit more streamlined?").
    # Six longer aft than it was (his, the same day: "the tail itself could be a smidge longer",
    # then "Maybe a bit longer still"), its back half stretched and its fins carried back with
    # its end.
    TAIL_MID, TAIL_END = -49.0, -66.0
    b.loft([(-18.0, _chamfered(0.0, 12.0, 4.0, 12.0, 1.6)), (-32.0, _chamfered(0.0, 8.0, 7.0, 12.5, 1.8)),
            (TAIL_MID, _chamfered(0.0, 5.0, 9.0, 12.5, 1.2)), (TAIL_END, _chamfered(0.0, 3.0, 9.5, 11.5, 0.7))], "steel.plate", "tail_boom")
    # The tail made part of the body (Ryan, 12 November: "we need to do something about the back
    # end so it doesn't look so much like a tail slapped on. I like the floating tail, maybe we can
    # get it to make more sense as part of the body"), in place of the dark keel it rode on, and
    # then the joins cleaned up ("it was already messy where things connected"): one root, in the
    # body's metal, whose six-sided section keeps its upper corners on the tail's flanks just over
    # its underside the whole way. Where the tail stands on the fuselage its flanks run out and
    # down onto the body's shoulders, a fillet each side; behind the fuselage's blunt end they come
    # in between the boosters and the root sweeps up and back into the tail's underside, its lower
    # edge meeting the tail a few ahead of the exhausts, so the tail is carried on the body and
    # floats free over the boosters either side of it and behind them.
    def boom_at(y):   # the tail's half-width and underside, between its sections
        if y >= -32.0:
            t = (-18.0 - y) / 14.0
            return 6.0 - 2.0 * t, 4.0 + 3.0 * t
        t = (-32.0 - y) / (-32.0 - TAIL_MID)
        return 4.0 - 1.5 * t, 7.0 + 2.0 * t
    def shoulder(y, x):   # the fuselage's top at x, on its shoulder between its sections at -16 and -30
        u = (-16.0 - y) / 14.0
        w, top = 18.0 - 3.0 * u, 7.0 - 1.6 * u
        return top * min(1.0, max(0.0, (w / 2.0 - x) / (w / 4.0)))
    def flank(y, k, up=0.9):   # the root's upper corner, on the tail's flank just over its underside
        xb, zb = boom_at(y)
        return xb - 0.05, zb + up * k
    root = []
    for y, k in ((-18.4, 0.08), (-20.0, 0.6), (-22.5, 1.0), (-26.0, 1.0), (-29.5, 1.0)):   # the fillets, on the fuselage
        xt, zt = flank(y, k, 1.4)
        xs = boom_at(y)[0] + 1.8 * k
        root.append((y, (xt, zt), (xs, shoulder(y, xs) - 0.05), (2.4, -(4.8 - 0.8 * (-16.0 - y) / 14.0) + 0.25)))   # its lower corners just inside the belly
    for y, side, bottom in ((-31.0, (4.6, 2.9), (2.2, -3.4)), (-34.0, (3.6, 3.6), (1.8, 0.6)),
                            (-39.0, (2.4, 6.4), (1.2, 4.6)), (-43.5, (1.3, 8.4), (0.65, 8.2))):   # the cone, behind it
        root.append((y, flank(y, 1.0, 0.6), side, bottom))
    # The faces the vents sit on halved, so each bows less across its corners (the loft's quads
    # are split in two triangles, one way on one flank and the mirror way on the other).
    def mid(p, q):
        return tuple((u + v) / 2.0 for u, v in zip(p, q))
    fine = []
    for i, sec in enumerate(root):
        fine.append(sec)
        if i + 1 < len(root) and sec[0] <= -30.9 and root[i + 1][0] >= -39.5:
            nxt = root[i + 1]
            fine.append(((sec[0] + nxt[0]) / 2.0, mid(sec[1], nxt[1]), mid(sec[2], nxt[2]), mid(sec[3], nxt[3])))
    root = fine
    root_part = b.loft([(y, [side, top, (-top[0], top[1]), (-side[0], side[1]), (-bot[0], bot[1]), bot]) for y, top, side, bot in root], "steel.plate", "tail_root")
    # Raked vents on the root's flanks just over the boosters (his: "I like the idea of angled
    # vents around the lower connection area, since the boosters are there and we remade the tail
    # front face into intakes"; then "Can we add some actual glowing vent parts too?"): three
    # slots each side, each raked back as it rises, cut into the flank as a real pocket (a decal
    # laid on it clipped through one side's flank, whose faces bow out where the other's bow in:
    # "looks good on one side and messed up on the other"), a fire glowing at its floor behind
    # two dark slats across it. The glow is the boosters' burn: it flares with theirs.
    def root_x(y, z):   # the root's flank, between its upper corner and its side, at (y, z)
        for (y0, t0, s0, _), (y1, t1, s1, _) in zip(root, root[1:]):
            if y1 <= y <= y0:
                f = (y0 - y) / (y0 - y1)
                t = (t0[0] + (t1[0] - t0[0]) * f, t0[1] + (t1[1] - t0[1]) * f)
                sd = (s0[0] + (s1[0] - s0[0]) * f, s0[1] + (s1[1] - s0[1]) * f)
                return sd[0] + (t[0] - sd[0]) * (z - sd[1]) / (t[1] - sd[1])
        raise ValueError(y)
    for s in (-1.0, 1.0):
        for y0 in (-31.2, -32.6, -34.0):   # all on the flank's upper face, which rises off the boosters aft
            zb, zt, wide, rake = 4.4, 6.7, 0.9, 1.4
            def slot(d, inset=0.0, z0=zb, z1=zt):   # the raked slot, `d` out from the flank, `inset` in from its edges
                pts = []
                for y, z in ((y0 - inset, z0 + inset), (y0 - wide + inset, z0 + inset), (y0 - wide - rake + inset, z1 - inset), (y0 - rake - inset, z1 - inset)):
                    pts.append((s * (root_x(y, z) + d), y, z))
                return pts
            b.cut_hull([root_part], slot(-0.45) + slot(0.9))
            _rings(b, [slot(-0.42, 0.04), slot(-0.38, 0.04)], "amber.glow", "tail_vent_glow")
            for k in (1, 2):   # the slats, a third and two thirds up, raked with the slot
                zk = zb + (zt - zb) * k / 3.0
                yk = y0 - rake * k / 3.0
                bar = lambda d: [(s * (root_x(y, z) + d), y, z) for y, z in ((yk, zk - 0.08), (yk - wide, zk - 0.08), (yk - wide, zk + 0.08), (yk, zk + 0.08))]
                _rings(b, [bar(-0.25), bar(-0.12)], "steel.dark", "tail_vent_slat")
    # The tail segment's front face, over the canopy, is an air intake (Ryan, 12 November): a dark
    # mouth across it inside a steel lip, a splitter down its middle. Mouth and lip take the
    # face's shape since its top corners were chamfered: the face's sides run up to 10.4 and its
    # chamfers to (4.4, 12), the line x + z = 16.4 on the right; the lip stands 0.4 inside the
    # face's edges and the mouth 0.45 inside the lip.
    def outline(side, top, chamfer, bottom):
        return [(-side, bottom), (side, bottom), (side, chamfer - side), (chamfer - top, top), (top - chamfer, top), (-side, chamfer - side)]
    lip = outline(5.6, 11.6, 16.4 - 0.4 * math.sqrt(2.0), 8.9)
    mouth = outline(5.15, 11.15, 16.4 - 0.85 * math.sqrt(2.0), 9.35)
    _face(b, [(x, -17.9, z) for x, z in mouth], "bore.dark", "intake_mouth")
    _frame(b, lip, mouth, -18.2, -17.2, "steel.plate", "intake_lip")
    b.box(-0.3, 0.3, -18.2, -17.2, 9.35, 11.15, "steel.plate", "intake_lip")
    for s in (-1.0, 1.0):
        a = math.radians(s * 38.0)
        e = TAIL_END + 60.0   # the fins carried back with the tail's end
        root = [(s * 0.9, -60.0 + e, 10.5), (s * 0.9, -48.0 + e, 10.5), (s * 0.9, -48.0 + e, 11.5), (s * 0.9, -60.0 + e, 11.5)]   # inside the chamfered end, so no corner stands off it
        tip = [(s * 1.5 + 14.0 * math.sin(a), -62.0 + e, 10.5 + 14.0 * math.cos(a)), (s * 1.5 + 14.0 * math.sin(a), -55.0 + e, 10.5 + 14.0 * math.cos(a)),
               (s * 1.5 + 14.0 * math.sin(a), -55.0 + e, 10.9 + 14.0 * math.cos(a)), (s * 1.5 + 14.0 * math.sin(a), -62.0 + e, 10.9 + 14.0 * math.cos(a))]
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
          glow=[(["booster_ring", "exhaust", "driver_ring", "driver_exhaust", "tail_vent_glow"], [(0.2, 0.0), (0.45, 7.0), (1.6, 7.0), (2.3, 0.0)])])
    # A loop (Ryan, 5 October: the nose dip was the weakest; it needs to do a loop): it backs
    # off, runs in and pulls up through a full circle, over on its back and down, the nose
    # along the path, the boosters hot, and brakes onto its hex a whole turn on, the pose it
    # started in (the rig wraps it). Big, out of its hex and back (the fifth notes: a small
    # one looked awkward); quicker, with a run before it pulls up (the sixth). On the map
    # only: the skirmish's frame has no room for it, nor any reason.
    # Bigger again (the eighth notes: the map has the room), at the same pace round it.
    b.act("loop", 5.2, body=_loop(r=46.0, t0=1.4, t1=4.1, duration=5.2, back=34.0, run=22.0), places=("map",),
          glow=[(["booster_ring", "exhaust", "driver_ring", "driver_exhaust", "tail_vent_glow"], [(0.6, 0.0), (1.1, 8.0), (4.2, 8.0), (4.9, 0.0)])])
    b.act("flare_boosters", 3.8, body=[(0.5, 0.0, 0.0, 0.0), (1.1, 0.0, 9.0, 0.0, 0.0, -6.0, 0.0), (2.5, 0.0, 12.0, 0.5, 0.0, -7.0, 0.0), (3.8, 0.0, 0.0, 0.0)],
          glow=[(["booster_ring", "exhaust", "driver_ring", "driver_exhaust", "tail_vent_glow"], [(0.3, 0.0), (0.8, 8.0), (1.2, 4.0), (1.6, 8.0), (2.6, 8.0), (3.4, 0.0)])])
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
          glow=[(["booster_ring", "exhaust", "driver_ring", "driver_exhaust", "tail_vent_glow"], [(0.2, 0.0), (0.8, 7.0), (circle[-2][0] - 0.6, 6.0), (circle[-1][0] - 0.1, 0.0)])])
    # A figure eight beside it, to judge against the circle (Ryan, 6 October, the ninth notes:
    # "I'd like to see what a figure 8 looks like"; the tenth: a smooth bank change, crossing the
    # hex on a diagonal, larger, quicker): a lobe to the left and one to the right, crossing its
    # hex at speed between them (_figure_eight). Map only. Quicker again (Ryan, 6 October, the
    # fifteenth notes: it can be sped up): 145 units a second at its fastest, from 110, the
    # whole eight in six seconds from nearly eight.
    eight = _figure_eight(vmax=145.0)
    mid = round((eight[0][0] + eight[-2][0]) * 0.5, 3)   # the crossing, halfway in time (the pace is symmetric)
    b.act("figure_eight", eight[-1][0], body=eight, places=("map",),
          glow=[(["booster_ring", "exhaust", "driver_ring", "driver_exhaust", "tail_vent_glow"], [(0.2, 0.0), (0.6, 7.0), (mid - 0.3, 6.0), (mid, 8.0), (mid + 0.3, 6.0), (eight[-2][0] - 0.6, 6.0), (eight[-1][0] - 0.1, 0.0)])])
    # Movement: the boosters brighten, the drivers' with them, the nose drops; it banks and slides through corners
    # (b.move) at full speed.
    b.halo = [("booster_ring", KESTREL_HALO), ("exhaust", KESTREL_HALO)]   # its boosters, hot; the drivers burn as plumes (below)
    # The Pinion Drivers' ramjets as plumes, Kestrel's machine or not (Ryan, 3 November: "kite's wing
    # boosters need the plume due to their shape. Can get anchored at the glowing ring instead of the
    # exhaust tip, so that it encompasses the exhaust taper"); a quarter larger on his second notes that
    # day ("Kite plumes are in the right spot but a tiny bit too subtle").
    for s in (-1.0, 1.0):
        b.plume("driver_ring", (s * 32.0, -1.4, -4.8), (0.0, -1.0, 0.0), reach=25.0, breadth=9.5)
    b.gait(glow={"parts": ["booster_ring", "exhaust", "driver_ring", "driver_exhaust", "tail_vent_glow"], "k": KESTREL_BURN}, body_hold=(0.0, 0.0, 0.0, 0.0, -6.0, 0.0))
    b.fires = {"pinion_driver": ("flare_boosters", 0.4, 1.8)}   # its fixed weapon fires with a slice of its act: the drivers flaring (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.move(slide=0.6, bank=50.0, accel=0.7, heft=0.08, oversteer=0.35)   # strafes most of the aircraft, banks hardest (Ryan, 5 October: more); the lightest in its acts; the nose a little into its corners (the fifth notes: the jets oversteer too, a bit)

kite.maker = "kestrel"


def clydesdale(b):
    """Wainwright & Sutler "Clydesdale": a massive, boxy, heavily armoured quadruped, the
    wagon-builder's walker, unchanged in a century. An ironclad wagon body, slab-sided in
    riveted iron with chamfered shoulders, on four thick columnar legs that step fore and
    aft only (the notorious turning circle); a low armoured head on a short neck, a visor
    slit under a brow, lamps at the temples; on top a wagon bed in the maker's brown
    carrying its two batteries (Ryan, 11 November): eight ports in a checkerboard, four guns
    up and four stowed in the hull, the Changeover swapping them; ablative slabs bolted on
    each flank, the heat sink and a stack at the tail. Bone-white flared skirts over the
    hooves, the namesake's feathering. First pass from the content's fantasy (22 September);
    the d9 deck of turrets, a lance, a mortar and a howitzer (29 September to 11 November)
    gave way to the batteries, every stock gun its class and every hardpoint on its back."""
    # Longer legs (Ryan, 5 October: "it is a horse after all", and the walk wanted them):
    # everything above the legs is built where it always was and raised one whole tile
    # (_Raised), so every seam stays on the world grid; the hips rise with it and the legs
    # take the difference, the shin most.
    H = TILE_WORLD
    raised = _Raised(b, H)
    raised.__enter__()
    # The body: an ironclad casemate, one loft from tail to shoulders with a short taper
    # to the neck. A keel under it, a hitch at the tail.
    hull = b.loft([(-36.0, _case(36.0, 23.0, 46.0, 5.0)), (22.0, _case(36.0, 23.0, 46.0, 5.0)), (30.0, _case(30.0, 24.0, 44.0, 4.0))], "steel.panel", "hull")   # 3 deeper since 11 November, to stow a battery upright
    b.box(-10.0, 10.0, -30.0, 18.0, 20.0, 23.0, "steel.dark", "keel")
    b.box(-3.0, 3.0, -42.0, -36.0, 24.0, 28.0, "steel.dark", "hitch")
    # The neck and head: lower than the body, so it reads as an animal and not a tank.
    b.loft([(30.0, rect(0.0, 26.0, 30.0, 44.0)), (36.0, rect(0.0, 22.0, 24.0, 40.0))], "steel.plate", "neck")
    # The head turns and nods on the neck (the joint pass, 2 October: it looks like an
    # AT-AT, without that fidelity).
    head = b.joint("head", (0.0, 36.0, 30.0), axis="yaw", limits={"yaw": (-30.0, 30.0), "pitch": (-10.0, 8.0)})
    head.__enter__()
    b.box(-12.0, 12.0, 36.0, 52.0, 20.0, 38.0, "steel.panel", "head")
    b.box(-13.0, 13.0, 44.0, 53.5, 38.0, 41.5, "steel.plate", "brow")
    b.box(-10.0, 10.0, 52.0, 53.0, 28.0, 34.0, "glass.glass", "visor")
    b.box(-9.0, 9.0, 48.0, 54.0, 20.0, 25.0, "steel.dark", "chin")
    for s in (-1.0, 1.0):
        b.box(min(s * 12.0, s * 13.5), max(s * 12.0, s * 13.5), 44.0, 49.0, 30.0, 35.0, "amber.light", "lamp")
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
    # under its hip, so the four legs stand as columns. The fifteenth notes (Ryan, 6 October:
    # the knees good, but the stance leaned too far forward, awkward; a straight leg, a straight
    # calf or less of a lean): the shin stands plumb, the hoof under the knee, and the knee
    # comes forward of the hip by three (from four), so the thigh alone angles, ten degrees,
    # where the shin had raked back under a forward knee and the whole leg read as leaning.
    legs = {}
    for yh, fa in ((16.0, "f"), (-24.0, "h")):
        for s in (-1.0, 1.0):
            leg = fa + ("l" if s < 0 else "r")
            hip = (s * 26.0, yh, 37.0 + H)
            knee = (s * 30.0, yh + 3.0, 34.0)
            ankle = (s * 30.0, yh + 3.0, 6.0)
            b.box(min(s * 18.0, s * 24.0), max(s * 18.0, s * 24.0), yh - 7.0, yh + 7.0, 30.0 + H, 44.0 + H, "steel.panel", "hip")
            b.prism("x", hip[0], hip[1], hip[2], 6.0, 6.0, "steel.dark", 6, "hip_pin")
            legs[leg] = (hip, knee, ankle)
            with b.joint("hip_%s" % leg, hip, limits=(-85.0, 85.0)):   # 70 until the short thighs of the eleventh notes asked the gallop's fold for a hair more; 80 until the plumb shins of the fifteenth
                _beam(b, hip, knee, _sq(11.0, 13.0), _sq(10.0, 11.0), "steel.plate", "thigh")
                b.prism("x", knee[0], knee[1], knee[2], 5.5, 12.0, "steel.dark", 6, "knee")
                with b.joint("knee_%s" % leg, knee, limits=(-115.0, 20.0)):
                    _beam(b, knee, ankle, _sq(9.0, 10.0), _sq(9.0, 9.0), "steel.panel", "shin")
                    with b.joint("ankle_%s" % leg, ankle, limits=(-45.0, 115.0)):   # -30 until the gallop's fores reached out ahead (the eighteenth notes)
                        _rings(b, [[(ankle[0] + u, ankle[1] + v, 12.0) for u, v in _sq(9.0, 9.0)],
                                   [(ankle[0] + u, ankle[1] + v, 3.0) for u, v in _sq(16.0, 16.0)]], "bone.bone", "feather")
                        b.box(ankle[0] - 7.0, ankle[0] + 7.0, ankle[1] - 8.0, ankle[1] + 8.0, 0.0, 5.0, "steel.dark", "hoof")
    # The bed: a deck plate and low boards round it in the maker's brown, the wagon's own, the
    # boards down to a hand above the deck so the guns stand clear of them.
    raised = _Raised(b, H)
    raised.__enter__()
    deck = b.box(-19.0, 19.0, -34.0, 20.0, 46.0, 48.0, "steel.plate", "deck")
    for s in (-1.0, 1.0):
        b.box(min(s * 19.0, s * 22.0), max(s * 19.0, s * 22.0), -35.0, 21.0, 46.0, 52.0, "livery.livery2", "bed_side")
    b.box(-22.0, 22.0, 18.0, 21.0, 46.0, 51.0, "livery.livery2", "bed_front")
    b.box(-22.0, 22.0, -35.0, -32.0, 46.0, 51.0, "livery.livery2", "bed_tail")
    # The batteries (Ryan, 11 November: "if we put all 8 hardpoints back on its back, flipping
    # dice would cause 4 to retreat into its hull ... and the other 4 to emerge ... the 4
    # pivoting vertical, then retreating downward vertically"; the checkerboard his pick): eight
    # ports in two columns either side of the spine and four rows between the boards, the first
    # battery's (hp_1 to hp_4) and the second's (hp_5 to hp_8) alternating, so each raised gun
    # stands where its neighbours are shut and a turn mirrors the deck. Each port is square (Ryan,
    # 11 November: "Sure, square ports, and either trapdoors or split middle"; a rack is square,
    # and a round bore it could pass would not fit four to a column): a stripe frame on the deck
    # round a dark mouth, two trapdoors across it (_hatch); in it a lift (slide, up) carries a
    # turret drum (yaw, the aim) and the gun's elevation (pitch) at the pin. The first battery is
    # built up, its trapdoors hanging open, the second stowed: upright, sunk BATTERY_SINK into the
    # hull (deepened for it) and its trapdoors shut. The form changed_over (Changed Over, the
    # second battery up) pivots the first upright, sinks it and swings its trapdoors shut as the
    # second's drop open, rise and pivot down to rest; letting it go runs that back.
    ports = []   # (pin number, x, y, built up)
    for k, (px, py) in enumerate(BATTERY_PORTS):
        ports.append((k + 1, px, py, True))
    for k, (px, py) in enumerate(BATTERY_PORTS):
        ports.append((k + 5, -px, py, False))
    stock = {1: ("barrel", "maxigun"), 2: ("twin_barrel", "twin_autoguns"), 3: ("barrel", "enfilade_beam"), 4: None,
             5: ("rack", "ankle_mortar"), 6: ("barrel", "howitzer"), 7: ("rack", "airburst_shell"), 8: ("rack", "incendiary_shells")}   # the stock's in pin order, the Shoring Jack showing nowhere (hp_4 bare)
    rest_fwd = (0.0, math.cos(math.radians(BATTERY_ELEVATION)), math.sin(math.radians(BATTERY_ELEVATION)))
    hatches = {}   # pin number -> [(leaf joint, its swing in the form)]
    for n, px, py, up in ports:
        hatches[n] = _hatch(b, str(n), (px, py, 48.0), BATTERY_MOUTH, BATTERY_WALL, 1.5, well=BATTERY_WELL, cut=[hull, deck], cut_dz=H,
                            built_open=up)   # the first battery's hanging open, the second's shut over its stowed guns
        dz = 0.0 if up else -BATTERY_SINK
        fwd = rest_fwd if up else (0.0, 0.0, 1.0)
        with b.joint("lift_%d" % n, (px, py, 49.0 + dz), slide=(0.0, 0.0, 1.0)):
            with b.joint("turret_%d" % n, (px, py, 49.0 + dz), limits=(-BATTERY_TRAVERSE, BATTERY_TRAVERSE)):
                b.prism("z", px, py, 50.5 + dz, BATTERY_DRUM, 3.0, "steel.panel", 12, "drum", phase=math.pi / 12)
                with b.joint("elev_%d" % n, (px, py, 52.5 + dz), axis="pitch", limits=(-90.0, 90.0)):
                    if stock[n] is None:
                        b.pin("hp_%d" % n, (px, py, 52.5 + dz), forward=fwd, scale=BATTERY_SCALE, carries="")
                    else:
                        b.stock("hp_%d" % n, (px, py, 52.5 + dz), stock[n][0], forward=fwd, scale=BATTERY_SCALE, carries=stock[n][1])
    # Ablative plating: two bolted slabs each flank, standing proud of the hull; the heat sink
    # across the tail, its stack rising out of it behind the bed. Detail, no mounts: armour and
    # vents show nowhere (the rule, 30 September).
    for s in (-1.0, 1.0):
        for y0, y1 in ((-30.0, -9.0), (-6.0, 15.0)):
            b.box(min(s * 18.0, s * 21.5), max(s * 18.0, s * 21.5), y0, y1, 28.0, 44.0, "steel.plate", "ablative")
    # The heat sink a radiator since 11 November (the breather's exhale glows in it): a vent block
    # across the tail, its back a frame round a core banked in its heat (heat_glow, near black at
    # rest) behind seven dark fins, so the heat shows between them.
    b.box(-13.0, 13.0, -39.0, -36.0, 28.0, 44.0, "steel.vent", "heat_sink")
    for z0, z1 in ((28.0, 29.0), (43.0, 44.0)):
        b.box(-13.0, 13.0, -40.0, -39.0, z0, z1, "steel.vent", "heat_sink")
    for s in (-1.0, 1.0):
        b.box(min(s * 12.0, s * 13.0), max(s * 12.0, s * 13.0), -40.0, -39.0, 29.0, 43.0, "steel.vent", "heat_sink")
    b.box(-12.0, 12.0, -39.15, -39.0, 29.0, 43.0, "amber.heat", "heat_glow")
    for k in range(7):
        b.box(-12.0, 12.0, -39.9, -39.15, 29.5 + 2.0 * k, 30.5 + 2.0 * k, "steel.dark", "heat_fin")
    b.prism("z", 0.0, -38.0, 52.0, 2.8, 16.0, "steel.dark", 6, "stack")
    raised.__exit__(None, None, None)

    # Idle acts, the fourth pass (Ryan, 11 November: its animations "showing their age, honestly",
    # the idle acts; "Everything else is fine"; of five for the machine as it now stands, "Those all
    # sound good. Don't need the old ones"): the battery on deck ranging where the head looks, the
    # battery's drill, a fore hoof pawing, a breath with the heat sink glowing on the exhale, and the
    # stowed hatches checked in a wave down the deck. At rest the first battery is on deck; Changed
    # Over plays its own copies for the second (b.act's form), its wave over the first's hatches, so
    # the acts always work the battery on deck. Heavy throughout (b.move's heft); every gun turning slowly
    # and not far with a pause before it turns back (the builder's rule). Degrees and seconds; a
    # key is (t, value) on the joint's own axis or (t, pitch, yaw, roll); a body key is (t, dx, dy,
    # dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k), k the light added over rest.
    limb = lambda leg: {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg]}
    HEAT = 196.0   # the heat tile's light at its height: near black at rest, #ff7800 under the phone's eased light (the Polar Bear's vents)
    # The paw: the fore-right hoof (the side the codex's and the skirmish's views see) lifted,
    # set down ahead toe first and dragged back along the ground, twice, the head dipped to it;
    # each key the ankle's place (y, z) and the toe's tip (down negative), the hoof's toe at the
    # ground through each drag and the leg within reach.
    paw = {"hip_fr": [], "knee_fr": [], "ankle_fr": []}
    for t, y, z, toe in ((0.3, 19.0, 6.0, 0.0), (0.9, 22.0, 11.5, -15.0), (1.35, 25.0, 8.0, -6.0), (1.55, 24.0, 6.85, -6.0),
                         (1.85, 19.0, 6.85, -6.0), (2.15, 14.0, 6.85, -6.0), (2.6, 20.0, 11.5, -15.0), (3.05, 25.0, 8.0, -6.0),
                         (3.25, 24.0, 6.85, -6.0), (3.55, 19.0, 6.85, -6.0), (3.85, 14.0, 6.85, -6.0), (4.4, 19.0, 6.0, 0.0)):
        a, kn, c = _limb_angles(limb("fr"), (y, z), 0.0)
        paw["hip_fr"].append((t, round(a, 3)))
        paw["knee_fr"].append((t, round(kn, 3)))
        paw["ankle_fr"].append((t, round(c + toe, 3)))
    paw["head"] = [(0.5, 0.0, 0.0, 0.0), (1.0, -7.0, -10.0, 0.0), (4.4, -7.0, -10.0, 0.0), (5.0, 0.0, 0.0, 0.0)]
    # The breath: the hydraulics let the body down onto its hooves as it breathes out, the heat
    # sink flaring, and heave it back up to its rest (no higher: the legs stand near straight).
    breath, breath_body = _planted([limb(leg) for leg in ("fl", "fr", "hl", "hr")],
                                   [(0.4, 0.0, 0.0, 0.0), (1.5, 0.0, -3.2, 0.0), (3.3, 0.0, -3.6, 0.0), (4.4, 0.0, 0.0, 0.0)])
    breath["head"] = [(0.4, 0.0, 0.0, 0.0), (1.6, -6.0, 0.0, 0.0), (3.3, -7.0, 0.0, 0.0), (4.2, 3.0, 0.0, 0.0), (5.0, 0.0, 0.0, 0.0)]

    def idles(guns, closed, form=None):
        """The five for the battery on deck, `guns` its ports front to back, and the stowed
        battery's ports `closed`, front to back, as the machine's own acts or, with `form`, as that
        form's."""
        # Ranging: the head turns to a bearing, lamps up, and the battery follows its look, the
        # guns slewing together a beat apart and lifting to a range; then a second bearing on
        # the other side, a shorter range; then home.
        ranging = {"head": [(0.4, 0.0, 0.0, 0.0), (1.4, 3.0, 24.0, 0.0), (3.2, 3.0, 24.0, 0.0), (4.6, 2.0, -22.0, 0.0), (6.2, 2.0, -22.0, 0.0), (7.2, 0.0, 0.0, 0.0)]}
        # The drill, a broadside (Ryan, 12 November: the first cut, each gun in turn on its own,
        # "a little dull"): the battery swings outboard together and ripple-fires front to back,
        # each gun kicking hard and the hull jolting under it, its hooves planted; then it swings
        # to the bow, lifts to a long range and ripples back to front; then home. On its own
        # quicker servo, so the kicks snap.
        drill, shots = {}, []
        for k, (n, px, py, up) in enumerate(guns):
            d = 0.1 * k
            ranging["turret_%d" % n] = [(0.9 + d, 0.0), (2.1 + d, 24.0), (3.6 + d, 24.0), (5.4 + d, -20.0), (6.6 + d, -20.0), (7.6 + d, 0.0)]
            ranging["elev_%d" % n] = [(1.4 + d, 0.0), (2.4 + d, 10.0), (3.6 + d, 10.0), (5.4 + d, 5.0), (6.6 + d, 5.0), (7.6 + d, 0.0)]
            d, out = 0.08 * k, (22.0 if px < 0.0 else -22.0)
            t1, t2 = 1.7 + 0.3 * k, 4.3 + 0.3 * (len(guns) - 1 - k)
            drill["turret_%d" % n] = [(0.4 + d, 0.0), (1.3 + d, out), (3.1, out), (3.9, 0.0)]
            drill["elev_%d" % n] = [(0.4 + d, 0.0), (1.3 + d, 12.0), (t1, 12.0), (t1 + 0.05, 24.0), (t1 + 0.35, 12.0), (3.1, 12.0),
                                    (3.9, 22.0), (t2, 22.0), (t2 + 0.05, 34.0), (t2 + 0.35, 22.0), (5.9, 22.0), (6.8, 0.0)]
            shots += [t1, t2]
        jolt = [(0.4, 0.0, 0.0, 0.0)]
        for ts in sorted(shots):
            jolt += [(round(ts, 3), 0.0, 0.0, 0.0), (round(ts + 0.06, 3), -0.5, -0.35, 0.0), (round(ts + 0.24, 3), 0.0, 0.0, 0.0)]
        legs_t, jolt_body = _planted([limb(leg) for leg in ("fl", "fr", "hl", "hr")], jolt + [(7.0, 0.0, 0.0, 0.0)])
        drill.update(legs_t)
        b.act("ranging", 8.2, ranging, glow=[(["lamp"], [(0.3, 0.0), (0.8, 6.0), (7.0, 6.0), (7.6, 0.0)])], form=form)
        b.act("battery_drill", 7.4, drill, body=jolt_body, heft=0.14, form=form)
        b.act("paw", 5.2, paw, form=form)
        b.act("breather", 5.4, breath, body=breath_body, glow=[(["heat_glow"], [(0.5, 0.0), (1.5, HEAT), (3.0, HEAT), (4.0, 0.2 * HEAT), (4.8, 0.0)])], form=form)
        # The hatch check, a wave (Ryan, 12 November: "cascaded and checked all the closed hatches
        # in sequence, like a do the wave effect"): each stowed port's trapdoors crack open into
        # its well and drop shut, front to back, a beat apart and overlapping, so the opening runs
        # down the deck.
        wave = {}
        for k, n in enumerate(closed):
            t0 = 0.4 + 0.25 * k
            wave["shutter_%df" % n] = [(t0, 0.0), (t0 + 0.3, 45.0), (t0 + 0.6, 45.0), (t0 + 0.74, 0.0)]
            wave["shutter_%db" % n] = [(t0 + 0.04, 0.0), (t0 + 0.34, -45.0), (t0 + 0.64, -45.0), (t0 + 0.78, 0.0)]
        b.act("hatch_check", round(0.4 + 0.25 * len(closed) + 1.2, 2), wave, heft=0.12, form=form)
    idles([p for p in ports if p[3]], [p[0] for p in ports if not p[3]])   # at rest: the first battery on deck, the second's hatches checked
    idles([p for p in ports if not p[3]], [p[0] for p in ports if p[3]], form="changed_over")   # Changed Over: the second on deck, the first's hatches
    b.halo = ["heat_glow"]   # the heat sink, hot
    # Movement (Ryan, 4 October, the third pass: stomp and plod, no weight thrown side to
    # side): each hoof planted flat while the body passes over it, then lifted high and
    # stamped down.
    # A lumbering giant's gallop (Ryan, 7 October, the sixteenth notes: the amble moved to the
    # Polar Bear; he still liked the gallop of the eighth notes, so how far toward a lumbering
    # giant?): the transverse gallop, hind left, hind right, fore left, fore right, then a
    # moment gathered with every hoof off the ground. Its stride cannot lengthen: at a sweep of
    # 30 a hind hoof swinging forward passes within two units of the fore planted on its side,
    # and the legs are at their full reach, so the stride stays 88, about 0.75 a second at its
    # map pace (the trot's 1.2), the slowest of its gaits (the fores' clearance grew in the eighteenth
    # notes, below; the stride kept). A shorter time on the ground would
    # slow the legs only by floating it longer. The weight is what is pushed: it barely leaves
    # the ground in the gathered moment (`hop` 0.5, from 3), the hull rocks 6 degrees either
    # way (from 4; at 7 a fore's hip folds past its 85), riding three under its rest, every landing a weight coming down (`thud`:
    # the hull sinking at once as the hoof strikes, recovering slowly through a small rebound,
    # deepest as the fores take it with the nose down), the hooves lifting 7 (from 10) and
    # the head heaving after the rock. The eighteenth notes (Ryan, 7 October: extend the legs
    # more through the stride; no leg moved past vertical into the forward plane): the shin
    # had never passed vertical, the knee jutting forward while it hung back. The fores now
    # throw their hooves ten past where they land late in the swing and draw them back onto it
    # (a limb's `reach`), the leg straightening out ahead, the shin up to 36 degrees forward,
    # and land eight ahead of the hip (from three), which leaves a hind hoof swinging forward
    # seven clear of them where it passed within two. The hinds cannot reach so: four units of
    # it brought them back within three of the fores, eight into them (measured).
    gallop = [{"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg],
               "phase": {"hl": 0.0, "hr": 0.12, "fl": 0.42, "fr": 0.54}[leg],
               "shift": legs[leg][0][1] - legs[leg][2][1] + (8.0 if leg[0] == "f" else -3.0),
               "reach": 10.0 if leg[0] == "f" else 0.0}
              for leg in ("fl", "fr", "hl", "hr")]
    tracks, body, stride = _gallop(gallop, sweep=30.0, duty=0.34, lift=7.0, crouch=3.0, hop=0.5, rock=6.0, dip=5.0, smooth=0.015, thud=True, airborne=0.99)
    tracks["head"] = ([(i / 40.0, round(-4.5 * math.cos(2.0 * math.pi * (i / 40.0 - 0.16)), 3)) for i in range(41)], 0.0)   # the head heaves after the rock
    # A heavy trot (Ryan, 6 October, the ninth notes: the gallop has potential but is a bit
    # much, and its hooves met through each other; somewhere between it and the Polar Bear's
    # stomp), the gait it sets off and pulls up in (below). The gait between the two in a horse:
    # diagonal pairs, high-stepping, each fore landing a beat before its hind partner so every
    # pair comes down as a heavy double thud, the hull dropping and nodding onto each pair.
    # The stances are spread three units fore and aft of the hips and the sweep kept to 22,
    # so a hind hoof reaching forward never meets the fore on its side. The eleventh notes (on
    # the columnar legs): it rides nearly as tall as its legs reach (`reach` 0.985), barely
    # crouched, the knees folding only to lift a hoof. A stride of 55, about one and a fifth a
    # second at its map pace (the fifteenth notes: a little too quick).
    trot = [{"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg],
             "phase": {"fl": 0.0, "hr": 0.05, "fr": 0.5, "hl": 0.55}[leg],
             "shift": legs[leg][0][1] - legs[leg][2][1] + (3.0 if leg[0] == "f" else -3.0),
             "nod": 1.0 if leg[0] == "f" else -0.5, "whole": leg[0] == "h"}
            for leg in ("fl", "fr", "hl", "hr")]
    ttracks, tbody, tstride = _plant(trot, sweep=22.0, duty=0.4, lift=12.0, crouch=0.3, dip=1.4, nod=1.2, reach=0.985, airborne=0.99, smooth=0.03, n=120)
    ttracks["head"] = ([(i / 40.0, round(-1.8 * abs(math.sin(2.0 * math.pi * (i / 40.0 - 0.04))), 3)) for i in range(41)], 0.0)   # a nod onto each pair
    # It sets off at a trot and rolls into the gallop, and drops back to the trot as it pulls
    # up (Ryan, 7 October, the nineteenth notes: it took off straight into a slow gallop):
    # wholly the trot under half its full speed, wholly the gallop over 0.95, crossfading
    # between (b.gait's start). Off the mark the speed alone held the trot for half a step
    # (the twenty-first notes), and a stride held then crossfaded at once clipped a hoof's
    # third step, fast and short (the twenty-second notes: about two steps of trot). Every
    # hoof now takes one trot step (one it is in as it sets off counting), and its next is its
    # own swing into the gallop, the gallop's first stride, worked out foot by foot
    # (_transition): it lifts from its trot stance and lands where and when the gallop lands
    # it, no faster than either gait swings a hoof, the hull easing from the trot's ride to
    # the gallop's meanwhile. The hinds' trot step is always a whole one, never one already
    # under way as it sets off (the twenty-third notes: one trot step is enough, so long as
    # it is complete, the hinds especially, since they push off into the gallop): it sets off
    # as the hind left lands and the hind right has just lifted.
    hand = _transition({"limbs": trot, "duty": 0.4, "stride": tstride, "tracks": ttracks, "body": tbody},
                       {"limbs": gallop, "duty": 0.34, "stride": stride, "tracks": tracks, "body": body}, steps=1)
    b.gait(stride=stride, tracks=tracks, body=body, ease="linear", start=("trot", 0.5, 0.95, hand))
    b.gait_option("trot", stride=tstride, tracks=ttracks, body=tbody, ease="linear")
    b.move(accel=1.4, heft=0.24)
    # The changeover (the form changed_over, held while the second battery is up): the first
    # battery pivots upright and sinks as the second's trapdoors drop open, the second rises as the
    # first is down, the first's trapdoors swing up shut and the second pivots down to rest;
    # letting it go runs it back. RIFTGATE_SEAL_DEBUG=1 holds every model's forms and lets them go
    # in turn, to judge it running.
    P0, P1, S1, I1, O0, O1, R1, E1 = 0.0, 0.35, 0.8, 1.05, 0.25, 0.5, 1.0, 1.4
    lift = lambda t, d: (t, 0.0, 0.0, 0.0, 0.0, 0.0, round(d, 3))
    form = {}
    for n, px, py, up in ports:
        if up:
            form["elev_%d" % n] = [(P0, 0.0), (P1, BATTERY_PIVOT)]
            form["lift_%d" % n] = [lift(P1, 0.0), lift(S1, -BATTERY_SINK)]
            for leaf, swing in hatches[n]:
                form[leaf] = [(0.0, 0.0), (S1, 0.0), (I1, swing)]   # swung up shut over the sunk gun
        else:
            for leaf, swing in hatches[n]:
                form[leaf] = [(0.0, 0.0), (O0, 0.0), (O1, swing)]   # dropped open for the gun to rise
            form["lift_%d" % n] = [lift(0.0, 0.0), lift(O1, 0.0), lift(R1, BATTERY_SINK)]
            form["elev_%d" % n] = [(0.0, 0.0), (R1, 0.0), (E1, -BATTERY_PIVOT)]
    b.form("changed_over", E1, form)

# The Clydesdale's batteries (the form above): the first battery's ports in pin order, the second's
# the same rows mirrored across the spine; how far a stowed gun sits under the deck, the guns'
# rest elevation and the pivot that stands them upright, the traverse, the mouth's half width and
# the frame's wall (a rack at the mounts' scale stands 9.9 by 9.3 upright, so it rises square
# between the hanging leaves, and a port's frame keeps a hand's gap to the next row's), the drum's
# radius, the well's depth, and the mounts' scale (a barrel stands 18.6, so upright and sunk it clears the deck and
# stays in the deepened hull).
BATTERY_PORTS = [(-9.5, 11.75), (9.5, -0.75), (-9.5, -13.25), (9.5, -25.75)]
BATTERY_SINK = 24.0
BATTERY_ELEVATION = 8.0
BATTERY_PIVOT = 82.0
BATTERY_TRAVERSE = 35.0
BATTERY_MOUTH, BATTERY_WALL, BATTERY_DRUM = 5.2, 0.5, 4.0
BATTERY_WELL = 4.5   # the well's floor under the rim (Ryan, 12 November: "Should it be a hole?"): as deep as the hull's shoulder lets the outer ports go
BATTERY_SCALE = 0.62

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
    Ryan may change. Since the stock pass (22 October) every station keeps its kind, the pins
    renumbered to the stock's order and each part its class (Ryan's go, 28 October). Since its
    rework (Ryan, 11 November) four mounts, the fists' outer sides gone ("they don't make sense
    with the hand shape anyway"): the right fist's top the Laser Carbine (hp_1) where the Zenith
    Emitter was; the shoulders' elevating mounts the Halo Projector's dish (hp_2, left) and the
    Ankle Mortar's rack (hp_3, right) where the projectors rode; the left fist's top bare (hp_4,
    the stock's Rivet Gun fitted there). The backpack's two pods are its two locked pieces, the
    Retrocausal Shroud (left) and the Redshift Emitter (right); the vent block on the backpack is
    detail (the Coolant Jacket shows nowhere)."""
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
    # Shoulders: red pauldrons, an octagonal drum each, low on the torso's shoulder, with a
    # stock piece riding on top on its elevating mount: the Halo Shield's dish (hp_3 left),
    # the Ankle Mortar's rack (hp_5 right).
    for s in (-1.0, 1.0):
        px = s * 25.0
        b.prism("x", px, 0.0, 57.0 + Z0, 9.0, 14.0, "livery.livery", 8, "pauldron", phase=math.pi / 8)
        b.prism("x", px, 0.0, 57.0 + Z0, 4.0, 15.0, "steel.dark", 6, "shoulder_pin")
        b.box(px - 4.0, px + 4.0, -2.0, 6.0, 60.0 + Z0, 65.0 + Z0, "steel.plate", "projector_mount")
        side = "l" if s < 0 else "r"
        with b.joint("elev_%s" % side, (px, 2.0, 63.0 + Z0), limits=(-6.0, 50.0)):   # the shoulder piece elevates on its mount
            b.stock("hp_%d" % (2 if s < 0 else 3), (px, 6.0, 64.0 + Z0), "dish" if s < 0 else "rack", scale=0.6, carries="halo_projector" if s < 0 else "ankle_mortar")
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
        # A mount a hand, on the fist's top (Ryan, 11 November: the outer hand mounts go, "they
        # don't make sense with the hand shape anyway"): the Laser Carbine on the right (hp_1)
        # and a bare mount on the left (hp_4).
        top = (wrist[0], wrist[1] + 1.0, wrist[2] - 3.5)
        if s > 0:
            b.box(top[0] - 3.5, top[0] + 3.5, top[1] - 5.0, top[1] + 3.0, top[2], top[2] + 3.0, "steel.plate", "emitter_mount")
            b.stock("hp_1", (top[0], top[1] + 1.0, top[2] + 5.0), "barrel", scale=0.5, carries="laser_carbine")
        else:
            b.pad("hp_4", (top[0], top[1] + 1.0, top[2] + 3.0), size=(7.0, 3.0))
        wr.__exit__(None, None, None)
        el.__exit__(None, None, None)
        jt.__exit__(None, None, None)
    # The backpack: a tall rack, red stripes down its sides, two pods on top, the Radiator
    # Sail's vent block on its rear (a vent: detail, no mount), a mast with a red light
    # between the pods, and a row of small lit ports across the rack's back. The pods are
    # the two locked pieces since 11 November (Ryan: "The backpack are the two locked bits,
    # maybe just need a little something on top, a little asymmetry"), built in, so no pin:
    # the left the Retrocausal Shroud, a ring of lit glass tilted over its cap on a post; the
    # right the Redshift Emitter, a short barrel raked forward off its cap with a lit lens.
    b.box(-17.0, 17.0, -26.0, -14.0, 34.0 + Z0, 68.0 + Z0, "steel.panel", "rack")
    for s in (-1.0, 1.0):
        b.box(min(s * 17.0, s * 18.5), max(s * 17.0, s * 18.5), -25.0, -15.0, 38.0 + Z0, 64.0 + Z0, "livery.livery", "rack_stripe")
        b.prism("z", s * 10.0, -20.0, 74.0 + Z0, 5.0, 14.0, "steel.dark", 6, "flare_pod")
        b.prism("z", s * 10.0, -20.0, 81.5 + Z0, 5.5, 1.5, "steel.plate", 6, "pod_cap")
    # The left pod's ring (the Retrocausal Shroud), tilted toward the front and out.
    rc = Vector((-10.0, -20.0, 87.5 + Z0))
    rn = Vector((-0.35, 0.45, 1.0)).normalized()
    b.prism("z", -10.0, -20.0, 84.6 + Z0, 0.8, 4.6, "steel.dark", 6, "shroud_post")
    _tube(b, tuple(rc - rn * 0.6), tuple(rc + rn * 0.6), 5.4, 4.2, 8, "amber.spark", "shroud_ring", floor=False, phase=math.pi / 8)
    # The right pod's barrel (the Redshift Emitter), raked forward and up, its lens lit.
    eb = Vector((10.0, -20.0, 82.4 + Z0))
    ed = Vector((0.18, 0.75, 0.62)).normalized()
    _tube(b, tuple(eb), tuple(eb + ed * 7.5), 2.8, 2.1, 6, "steel.dark", "emitter_barrel", floor=False)
    b.prism("z", 10.0, -20.0, 82.9 + Z0, 3.2, 1.0, "steel.plate", 6, "emitter_collar")
    _disc(b, tuple(eb + ed * 7.0), tuple(ed), 2.05, 6, "amber.heat", "emitter_lens")
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
    }, heft=0.08, glow=[(["dish_core", "eye"], [(0.5, 0.0)] + [(t + d, k) for t in ticks for d, k in ((-0.02, 0.0), (0.06, 9.0), (0.3, 0.0))] + [(5.0, 0.0)])])
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
    }, glow=[(["dish_core", "hp_2", "hp_4"], [(0.6, 0.0), (1.6, 4.0), (2.2, 8.0), (2.6, 4.0), (3.0, 8.0), (4.4, 8.0), (5.2, 0.0)])])
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
    # Its locked pieces play a slice of its act as they are used: the projectors' charge and blaze
    # (Ryan, 31 October: "go for ones that are cheapest to do first"; the Solar Flare Array's until
    # 11 November).
    b.fires = {"retrocausal_shroud": ("charge_projectors", 1.8, 3.4), "redshift_emitter": ("charge_projectors", 1.8, 3.4)}
    b.move(accel=1.1, heft=0.2)

baboon.maker = "aphelion"


# ---------------------------------------------------------------- the 28 September machines
# Second passes on Ryan's notes (29 September). Every number is a proportion.

def polar_bear(b):
    """Minerva "Polar Bear" (HW-22T Heavy Weapons Carrier): the biggest land machine in the
    game. A domed shell of overlapping armour bands, longer than it is wide (Ryan, 30
    September: armadillo, not turtle), on four long heavy legs whose hips stand out of the
    shell's flanks. The front band runs on as a cowl over a small cockpit bay tucked under
    it, the Badger's way (the first pass's head, with a smaller cockpit: Ryan, 30
    September). The weapons come out of round ports in the shell like a Blastoise: each
    port is a hollow of chassis with the mount at its floor, so a fitted gun rises out of
    it. Mounts, the four weapon ports (Ryan, 15 October: "the 4 weapons ports are the 4
    hardpoints"; his go of 20 October), in the stock's order: hp_1 the left rear port (the
    Rivet Gun), hp_2 the right rear port (the Twin Autoguns), hp_3 and hp_4 two forward ports
    flanking the cowl, level with the ground, cut back into the step behind the front band,
    bare; the plating on the flanks is detail, and a louvred radiator sunk flush in each
    flank's chamfer above the hind hip and two near-square louvred vents low in the tail's
    back panel, each a grille at rest that throws its louvres open over flaring orange heat
    when it vents and shuts flat when it seals, while a vent on each flank's chamfer ahead of
    the rear ports slides out over its glowing core (Ryan, 29 October: the stack's rain flap
    read "more W&S comical than heavy Minerva"; the two vents that replaced it grew into "big
    boxy radiators sticking out at an angle", with "new vents on the sides", their glow "way
    more yellow/orange"; then, 30 October, "Place them flush on the chamfered face above the
    leg joint", and "Split the long rear vent into two squareish ones"). The ports are real
    holes: b.cut subtracts them from the bands before export. The hatch behind the rear ports
    carries the two Cryo Flingers (fixed, no pin; Ryan, 28 October: the brief's lean), a twin
    canister rack that slides out of it to fire, its two barrels bored dark through the rack's
    face (Ryan, 29 October: "the cryo barrels need to be bored in") and a beacon on each rim
    (the beep). Every weapon only runs in and out along its line of fire, never pitching
    (Ryan, 29 October: "remove the vertical pivot from all armadillo weapons"): the port guns
    and the rack slide on their joints, a shot kicks them back along it. The seal made real
    (the form "sealed", held while Sealed): the port guns sink into the shell, then an iris
    plug in the ports' stripe rises out of each port's floor and closes it just under the rim
    (Ryan, 29 October: the leaves drawn back across the shell showed, so they rest out of
    sight under the floor), the radiators shut, the cowl lamps go dark and the whole machine
    hunkers down on its planted feet, the defensive base pose its own acts play from (Ryan,
    29 October: sealed, "the animations set shouldn't be the same"), none of them a vent; the
    flingers' rack stays live, since a sealed Polar Bear still lures; opening runs it back."""
    Z0 = 26.0   # the shell's floor: the legs lift it this high
    PLUG_DEEP, PLUG_DEEP_F = 12.0, 9.0   # how far down its line each port's iris plug rests, rear and fore: under the floor, out of sight in the shell
    # How each class sits in a port (Ryan, 2 November: "some hardpoints want circular missile
    # racks, that fixes the armadillo"): a round launcher for a rack, and every class at the
    # scale that passes the port's bore whole (its octagon's flats: the rear ports' 11.8 across,
    # the fore ports' 10.3), so a fitted part rises out of its port as the guns do, never jammed
    # in its mouth, and sinks under the iris when the shell seals. Each sits at its depth (the
    # third number, back along the line in the pin's units; Ryan, 11 November: "Can't the polar
    # bears guns start deeper? Why do they have to come all the way out? Like a round missile rack
    # doesn't need to poke out at all"): a round rack's face just inside the rim, a gun about as
    # far out as the old hand-built ones (13 past a rear rim, 11 past a fore one), a dish as it was.
    REAR_FITS = {"rack": ("rack_round", 0.78, 5.0), "dish": 0.7, "blade": ("blade", 0.8, 3.9), "twin_barrel": ("twin_barrel", 0.7, 4.3), "barrel": ("barrel", 0.9, 11.7)}
    FORE_FITS = {"rack": ("rack_round", 0.68, 2.6), "dish": 0.6, "blade": ("blade", 0.7, 2.0), "twin_barrel": ("twin_barrel", 0.6, 2.0), "barrel": ("barrel", 0.8, 9.2)}
    # The shell: six bands from tail to brow, a dome in section, each proud of the last;
    # the tail band fuller than before (Ryan, 30 September: it tapered too much).
    bands = [(-50.0, -38.0, 50.0, Z0 + 21.0, 9.0), (-39.0, -22.0, 54.0, Z0 + 24.0, 10.0), (-23.0, -4.0, 60.0, Z0 + 28.0, 12.0),
             (-5.0, 14.0, 62.0, Z0 + 28.0, 12.0), (13.0, 30.0, 56.0, Z0 + 24.0, 11.0), (29.0, 46.0, 48.0, Z0 + 17.0, 9.0)]
    # The tail band square again (Ryan, 29 October): its back had been bevelled to carry the
    # radiators sunk in the slope, and he liked the taper, to keep in mind for the next pass.
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
            # The hind knee a hair ahead of the line from hip to foot (Ryan, 7 October, the
            # eighteenth notes: every knee folding forward, the stubby legs kept), so it folds
            # forward as the fores do; it stood a hair behind and folded back. The legs' shape
            # is unchanged to the eye (the knee 0.8 forward).
            knee = (s * 44.0, yh + (4.0 if yh > 0 else -3.2), 18.0)
            ankle = (s * 42.0, yh + (6.0 if yh > 0 else -6.0), 6.0)
            b.prism("x", hip[0], hip[1], hip[2], 6.5, 8.0, "steel.dark", 6, "hip_pin")
            legs[leg] = (hip, knee, ankle)
            fore = yh > 0
            with b.joint("hip_%s" % leg, hip, limits=(-60.0, 60.0) if fore else (-60.0, 75.0)):   # a hind thigh folding forward swings further (the seventeenth notes)
                _beam(b, hip, knee, _sq(13.0, 14.0), _sq(11.0, 12.0), "steel.plate", "thigh")
                b.prism("x", knee[0], knee[1], knee[2], 6.0, 13.0, "steel.dark", 6, "knee")
                with b.joint("knee_%s" % leg, knee, limits=(-115.0, 30.0)):
                    _beam(b, knee, ankle, _sq(10.0, 11.0), _sq(10.0, 10.0), "steel.panel", "shin")
                    with b.joint("ankle_%s" % leg, ankle, limits=(-40.0, 115.0)):
                        b.box(ankle[0] - 9.0, ankle[0] + 9.0, ankle[1] - 10.0, ankle[1] + 10.0, 0.0, 6.0, "steel.dark", "foot")
                        b.box(ankle[0] - 9.0, ankle[0] + 9.0, ankle[1] + (10.0 if yh > 0 else -13.0), ankle[1] + (13.0 if yh > 0 else -10.0), 0.0, 4.0, "steel.stripe", "toe_plate")
    # The rear ports: a hollow cut right through the shell (b.cut: a boolean on the bands),
    # pitched up and forward, lined by a tube with a dark floor and a stripe rim at the
    # mouth; the mount on the floor, deep, the barrel out of it (Ryan, 1 October).
    D = (0.0, 0.707, 0.707)
    shutters = {}   # port -> [(joint, its slide home)]: the seal's irises (the form below)
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
        tag = "r" + ("l" if s < 0 else "r")
        shutters[tag] = _plug(b, tag, Vector((px, -0.9, Z0 + 29.1)) - Vector(D) * 0.5, D, 6.8, PLUG_DEEP)   # closes just under the rim; rests under the floor
        mount = Vector((px, -3.5, Z0 + 26.5))
        # Each port gun runs in and out of its port along its line (Ryan, 29 October: it
        # pitched on a joint at the mount, and its barrels clipped the shell presenting): a
        # slide joint at the mount, the socket inside it.
        with b.joint("run_%s" % ("l" if s < 0 else "r"), tuple(mount), slide=D):
            # Each stock gun is its class at the fit that passes the bore (Ryan, 11 November: no
            # stock gun is built by hand).
            if kind == "rivet":
                b.stock("hp_1", tuple(mount), "barrel", forward=D, scale=1.2, carries="rivet_gun", fits=REAR_FITS)
            else:
                b.stock("hp_2", tuple(mount), "twin_barrel", forward=D, scale=1.2, carries="twin_autoguns", fits=REAR_FITS)
    # The hatch behind the ports: a rack in a stripe frame, pitched forward with the ports,
    # the Cryo Flingers' (no pin since the rework: the four ports are the hardpoints).
    # Up and back a little, so a cannon fitted there clears the shell's crown ahead of it
    # (Ryan, 1 October).
    # A square channel through the shell along the cell's own line, the cell sliding and
    # tilting in it (Ryan, 5 October, the sixth notes: lifted, the cell slid through the top
    # panel, so the mount wants a cutout): cut through both bands it crosses, long enough for
    # the cell's whole slide, its walls the shell's own; the stripe frame a hollow sleeve over
    # its lower part, floored dark deep in the shell. The sleeve runs down its line until its
    # back edge is buried in the lower deck behind the step (it began where its back edge hung
    # over both decks, a slot under it into the cut: Ryan, 30 October, "the rack has a rear cut
    # that I'm not sure is supposed to be that big"), that run down a skirt in the livery under
    # the stripe (the same day: "that's now a lot of hazard stripe in one area. I don't mind
    # the extension, but maybe this is a good place for livery instead").
    HB, DV, R2 = Vector((0.0, -34.0, Z0 + 20.0)), Vector(D), math.sqrt(2.0)
    b.cut(band_obs, tuple(HB - DV * 8.0), tuple(HB + DV * 20.0), 7.4 * R2, sides=4, phase=math.pi / 4)
    _tube(b, tuple(HB - DV * 8.0), tuple(HB + DV * 0.5), 8.5 * R2, 7.4 * R2, 4, "livery.livery2", "hatch_skirt", floor_depth=0.3, phase=math.pi / 4)
    _tube(b, tuple(HB + DV * 0.5), tuple(HB + DV * 11.3), 8.5 * R2, 7.4 * R2, 4, "steel.stripe", "hatch_frame", floor_depth=0.0, floor=False, phase=math.pi / 4)
    with b.joint("run_rack", (0.0, -32.0, Z0 + 22.0), slide=D):   # the rack slides out of its hatch along its line (it tilted, Ryan, 29 October)
        # The Cryo Flingers' twin rack (fixed, no pin): a panel body, two barrels side by side
        # through its face, bored six deep (Ryan, 29 October: "the cryo barrels need to be bored
        # in"; the face had capped them a hair down), the bore, its floor and the rim at its mouth
        # in the guns' dark steel (Ryan, the same day: the plate rim and its inner wall read
        # light), and a beacon beside each that blinks when the rack runs out (Ryan, 18 October:
        # "a sticky cryo canister with a really annoying beep or something").
        rack = _beam(b, (0.0, -32.0, Z0 + 22.0), (0.0, -24.5, Z0 + 29.5), _sq(13.0, 13.0), _sq(13.0, 13.0), "steel.panel", "flinger_rack")
        UP, RT = Vector((0.0, -0.7071, 0.7071)), Vector((1.0, 0.0, 0.0))
        FACE = Vector((0.0, -24.5, Z0 + 29.5))
        for xo in (-3.2, 3.2):
            c = FACE + RT * xo
            b.cut([rack], tuple(c - DV * 6.0), tuple(c + DV * 0.5), 2.6)
            _tube(b, tuple(c - DV * 6.0), tuple(c + DV * 1.2), 3.0, 2.3, 8, "steel.dark", "flinger_tube", floor_material="steel.dark", floor_depth=0.3)
            _tube(b, tuple(c + DV * 0.7), tuple(c + DV * 1.4), 3.3, 2.3, 8, "steel.dark", "flinger_rim", floor=False)
            bc = c + UP * 3.9 + DV * 0.6
            b.box(bc.x - 0.7, bc.x + 0.7, bc.y - 0.7, bc.y + 0.7, bc.z - 0.7, bc.z + 0.7, "amber.light", "beacon")
    # Two forward ports flanking the cowl: level with the ground, cut straight back into
    # the step behind the front band (the fifth band's front face stands seven above the
    # sixth's crown), so a gun comes out of that plate and runs forward over the cowl's
    # band (Ryan, 1 October). Bare mounts on their floors, deep (hp_3, hp_4).
    for s, n in ((-1.0, 3), (1.0, 4)):
        px = s * 14.0
        # Lowered so the collar sits inside the plate behind the cowl, its wall run back
        # into the band (Ryan, 1 October: the tube and the body did not meet); wide enough
        # that any class fits it at a size that reads (Ryan's go of 2 November: the fore
        # ports' bore had been 9 across, too small for a launcher or a dish to show), and
        # lower again so the wider collar stays inside the band's top.
        ZF = Z0 + 16.0
        p0 = (px, 22.0, ZF)
        p1 = (px, 31.0, ZF)
        b.cut(band_obs, p0, p1, 5.8)
        _tube(b, (px, 14.0, ZF), p1, 7.0, 5.6, 8, "steel.plate", "fore_port", floor_depth=8.0)
        _tube(b, (px, 30.1, ZF), (px, 31.3, ZF), 7.6, 5.6, 8, "steel.stripe", "fore_rim", floor=False)
        # A firing channel cut down through the front band ahead of the port, so a gun
        # fitted there lies in a trough instead of running into the shell (Ryan, 1
        # October: the barrels would have clipped the band in front), stopping at the
        # cowl's back.
        b.cut_box(band_obs, px - 5.6, px + 5.6, 30.0, 46.0, ZF - 5.0, Z0 + 30.0)
        tag = "f" + ("l" if s < 0 else "r")
        shutters[tag] = _plug(b, tag, Vector((px, 29.6, ZF)), (0.0, 1.0, 0.0), 6.0, PLUG_DEEP_F)   # closes just behind the rim; rests behind the floor
        with b.joint("run_" + tag, (px, 24.5, ZF), slide=(0.0, 1.0, 0.0)):   # a gun fitted here runs in and out along its line, and sinks as the seal turns in
            b.pin("hp_%d" % n, (px, 24.5, ZF), forward=(0.0, 1.0, 0.0), scale=1.2, carries="", fits=FORE_FITS)
    # The slab between the two channels cut away too, so the front band steps down to one
    # wide firing deck ahead of the ports (Ryan, 1 October).
    b.cut_box(band_obs, -9.6, 9.6, 30.0, 46.0, ZF - 5.0, Z0 + 30.0)
    # Plating on the flanks between the hips: detail, no mounts.
    for s in (-1.0, 1.0):
        b.box(min(s * 29.0, s * 32.5), max(s * 29.0, s * 32.5), -10.0, 10.0, Z0 + 2.0, Z0 + 18.0, "livery.livery2", "ablative")
    # The radiators (Ryan, 29 October: the two tail vents, "more active animated vents, more
    # rugged looking, that seal as well as the armour ports", then enlarged into radiators;
    # big boxes standing out of the tail at an angle, moved about its back panel and its top
    # rear corners through 30 October, until "Place them flush on the chamfered face above the
    # leg joint, and resize to fit"): one sunk flush in each flank's chamfer of the band over
    # the hind hip, above the hip's cuff where it stands out of the slope, fourteen along the
    # machine by eight up the slope, a dark steel box with a stripe rim and its heat banked in
    # its floor (amber.heat, "way more yellow/orange" than the ember it had), three louvres along
    # the machine on joints. At rest they stand a little out, a grille over the heat; the vent
    # act throws them near square to the slope, so the heat shows between them to a camera
    # above that flank; sealed, they shut flat with the ports.
    vents = [("radiator_heat_" + t, _vent(b, [band_obs[1]], (s * 20.5, -31.0, Z0 + 20.5), 0.0, 14.0, 8.0, 3, "louvre_" + t, 20.0, 80.0, flank=s, heat="radiator_heat_" + t))
             for s, t in ((-1.0, "l"), (1.0, "r"))]   # on the slope (x plus height 41), from the deck's edge to just over the cuff
    # The long rear vent split in two (Ryan, the same day: "Split the long rear vent into two
    # squareish ones"; it had run forty-four across the panel's fifty, then "The rear ones can
    # protrude a bit more"): two vents fifteen wide by twelve tall side by side low in the
    # tail's rear face, each box standing out of it, its mouth two and a half behind the panel
    # and its back a little inside it, four louvres each a little out at rest that throw their
    # upper edges out (edge on to an eye 30 to 42 degrees down behind) and shut flat with the
    # radiators'.
    vents += [("rear_vent_heat_" + t, _vent(b, [band_obs[0]], (s * 12.0, bands[0][0] - 2.5, Z0 + 6.5), 90.0, 15.0, 12.0, 4, "louvre_c" + t, 10.0, 60.0, heat="rear_vent_heat_" + t))
              for s, t in ((-1.0, "l"), (1.0, "r"))]
    # The side vents (Ryan, the same day: "new vents on the sides, on the angled slopes just in
    # front of the back weapons. Those are small rectangular protrusions when sealed, and
    # either slide out, or lever up using the forward edge as a pivot, to show the vent face
    # when venting"; then the glow "way more yellow/orange", with "a larger footprint to
    # sell"): one on each flank's chamfer, just ahead of the rear ports, a dark cap on a stripe
    # rim, fourteen along the machine by eight across, a little down the slope so its well
    # clears the port's tube; venting, it slides straight out of its well on a joint, thin
    # slatted sides rising under the cap over heat that glows between them. Slid, not levered: one joint, and it
    # shows its faces to the cameras ahead and behind alike, where a lever on the forward edge
    # shows its face behind only (and that edge runs up the slope, off the machine's axes, so
    # the rig would turn it on three nested joints: rolled square, pitched, rolled back).
    pops = [("side_vent_heat_" + t,) + _popvent(b, [band_obs[3]], (s * 26.05, 5.5, Z0 + 20.95), s, "vent_pop_" + t, heat="side_vent_heat_" + t)
            for s, t in ((-1.0, "l"), (1.0, "r"))]   # seven up the slope's seventeen

    # Idle acts, third pass (Ryan, 4 October: some stilted, the weight thrown side to side;
    # heavy, with inertia): curves a part runs on through, the servos' heft (b.move), held
    # poses that drift, and the feet planted while the shell tips over them (_planted).
    # Degrees and seconds; a key is (t, value) on the joint's own axis or (t, pitch, yaw,
    # roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is
    # (t, k), k the light added over rest.
    limb = lambda leg: {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg]}
    # Every weapon runs in and out along its line, never pitching (Ryan, 29 October: "they
    # should only move along their axis of firing, in and out"): a port gun runs out RUN to
    # bear, no further, its barrel's root still in the port; the rack slides LIFT up its
    # hatch, its base still inside the frame (lifted eleven, it left its housing whole and
    # floated: Ryan, 5 October, the fifth notes).
    RUN, LIFT = 2.5, 7.0
    along = lambda t, d, line=D: (t, 0.0, 0.0, 0.0) + tuple(round(v * d, 3) for v in line)
    rack_out = lambda t0, t1, t2, t3: [along(t0, 0.0), along(t1, LIFT), along(t2, LIFT - 0.4), along(t3, 0.0)]
    # Present the guns as a sumo does (Ryan, 5 October): a forefoot lifts and steps out wide,
    # then the other, the shell's front sinking between them, and every back gun runs out
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
        "run_l": [along(3.2, 0.0), along(4.0, RUN), along(5.4, RUN - 0.3), along(6.2, 0.0)],
        "run_r": [along(3.4, 0.0), along(4.2, RUN), along(5.4, RUN - 0.3), along(6.2, 0.0)],
        "run_rack": rack_out(3.1, 4.4, 5.4, 6.6),
    })
    blink = lambda t0, t1: [(round(t0 + k * 0.45 + d, 2), v) for k in range(int((t1 - t0) / 0.45)) for d, v in ((0.0, 0.0), (0.05, 12.0), (0.18, 0.0))]
    b.act("present_guns", 8.8, tracks, body=body,
          glow=[(["lamp"], [(3.2, 0.0), (3.8, 8.0), (5.6, 8.0), (6.2, 0.0)]),   # the cowl lamps burn: the guns are up
                (["beacon"], blink(3.6, 6.2))])   # and the canisters beep while the rack is out
    # Crouch (Ryan, 5 October: the knee bend of the old present_guns as an act of its own):
    # it sinks low and level on its planted feet, settles, and stands.
    tracks, body = _planted([limb(leg) for leg in ("fl", "fr", "hl", "hr")],
                            [(1.4, 0.0, -8.0, -0.6), (2.0, 0.0, -8.6, -0.8), (3.8, 0.0, -9.0, -0.8), (5.0, 0.0, 0.0, 0.0)])
    b.act("crouch", 5.4, tracks, body=body)
    b.act("weapons_check", 6.6, {   # each port gun runs out and cycles back in turn, then the rack slides up its hatch, its canisters beeping
        "run_l": [along(1.0, 0.0), along(1.5, RUN), along(1.9, RUN), along(2.1, -0.8), along(2.5, 0.0)],
        "run_r": [along(2.2, 0.0), along(2.7, RUN), along(3.1, RUN), along(3.3, -0.8), along(3.7, 0.0)],
        "run_rack": rack_out(3.6, 4.7, 5.3, 6.4),
    }, glow=[(["beacon"], blink(4.0, 6.2))])
    b.act("stamp", 5.6, {   # a forefoot lifts high and stamps down, then a hind one, the shell dropping onto each
        "hip_fr": [(0.9, 30.0), (1.8, 31.0), (2.1, 0.0)],
        "knee_fr": [(0.9, -44.0), (1.8, -45.0), (2.1, 0.0)],
        "ankle_fr": [(0.9, 14.0), (1.8, 14.0), (2.1, 0.0)],
        "hip_hl": [(2.8, 0.0), (3.5, 32.0), (4.1, 33.0), (4.4, 0.0)],   # the knee folding forward since the eighteenth notes (it folded back: 22, 40, -62), the foot lifted as the fore's is, solved flat
        "knee_hl": [(2.8, 0.0), (3.5, -57.0), (4.1, -58.0), (4.4, 0.0)],
        "ankle_hl": [(2.8, 0.0), (3.5, 26.0), (4.1, 26.5), (4.4, 0.0)],
    }, body=[(0.9, 0.0, 0.0, 0.5, 0.0, 1.5, 0.0), (1.8, 0.0, 0.0, 0.6, 0.0, 1.7, 0.0), (2.1, 0.0, 0.0, -1.4, 0.0, -0.8, 0.0), (2.6, 0.0, 0.0, 0.0),
             (3.5, 0.0, 0.0, 0.5, 0.0, -1.2, 0.0), (4.1, 0.0, 0.0, 0.6, 0.0, -1.3, 0.0), (4.4, 0.0, 0.0, -1.4, 0.0, 0.6, 0.0), (5.0, 0.0, 0.0, 0.0)])
    # Coming about (Ryan, 20 October: the funnel-web's planted footwork for the Dillo): with
    # no head and no waist it turns its whole shell to look, the way it walks, in diagonal
    # pairs: a pair lifts, the shell turns eight degrees on the other pair, planted, and drops
    # onto the landing pair (the stamp's dip); three pairs bring it round twenty-four and a
    # fourth squares the trailing pair up under it, the port guns run out to bear and the cowl
    # lamps burn while it holds facing the new way; then back the same way. The shell sits
    # lower through the turn (its legs stand straight in their planes, and a planted foot
    # under a turning shell needs the slack). Each hip takes the yaw and roll that keep its
    # foot planted and pointing where it landed (_footwork).
    YAW, DIP, REST6 = -24.0, -4.5, (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    low = lambda yaw, drop=0.0: (0.0, 0.0, DIP + drop, yaw, 0.0, 0.0)

    def come(t0, y0, y1):
        """Steps and body keys turning the shell from y0 to y1 in four diagonal pairs from t0,
        0.75 s a pair: 0.45 in the air while the shell turns a third of the way (the fourth
        pair steps with the turn done), then the drop onto it."""
        steps, keys = [], []
        for k in range(4):
            ta, tb = round(t0 + k * 0.75, 3), round(t0 + k * 0.75 + 0.45, 3)
            ya, yb = y0 + (y1 - y0) * min(k, 3) / 3.0, y0 + (y1 - y0) * min(k + 1, 3) / 3.0
            for leg in (("fl", "hr"), ("fr", "hl"))[k % 2]:
                steps.append((leg, ta, tb, ("under", tb), 6.5))
            keys += [(ta, low(ya)), (tb, low(yb)), (round(tb + 0.1, 3), low(yb, -1.6)), (round(tb + 0.3, 3), low(yb))]
        return steps, keys
    s1, k1 = come(0.5, 0.0, YAW)
    s2, k2 = come(5.3, YAW, 0.0)
    tracks, body = _footwork({leg: limb(leg) for leg in ("fl", "fr", "hl", "hr")},
                             [(0.2, REST6), (0.5, low(0.0))] + k1 + [(5.3, low(YAW))] + k2 + [(8.8, REST6)], s1 + s2, until=9.0)
    tracks.update({"run_l": _dense([along(3.2, 0.0), along(3.8, RUN), along(5.1, RUN - 0.3), along(5.8, 0.0)]),
                   "run_r": _dense([along(3.3, 0.0), along(3.9, RUN), along(5.1, RUN - 0.3), along(5.8, 0.0)])})
    b.act("come_about", 9.4, tracks, body=body, ease="linear", heft=0.12,
          glow=[(["lamp"], [(3.4, 0.0), (3.9, 8.0), (5.2, 8.0), (5.8, 0.0)])])
    # Venting (Ryan, 29 October: the vents "more active animated", and never while sealed;
    # then "don't do the double knee bend. Lower down, open vents, close vents, come back up";
    # 30 October: "desync the vent openings, then close them all at the same-ish time", then
    # "Open them in pairs, not one at a time, and leave them open longer once they're all
    # open"; then "slow down the standing back up at the end and start it as the vents are
    # closing. the vents can stay open a touch less long. desync the pairs closing just a
    # bit"): the shell sinks low on its planted feet and settles; the vents open a pair at a
    # time, each left with its right, the rear vents, then the side vents, then the radiators, a
    # radiator's or a rear vent's louvres the lowest first and the rest a beat after, a side
    # vent sliding out, each one's heat flaring as it opens; held open together a second and a
    # half while the heat pours out, they shut a pair at a time a beat apart in the same order
    # as the glow dies, and the shell rises slowly from the first pair's shutting. A louvre's
    # key is a share of its own throw.
    SINK, UP0, UP = -7.0, 4.5, 2.0   # how low it sinks; when it starts back up, and how long it takes
    eased = lambda u: u * u * (3.0 - 2.0 * u)
    rise = [(round(UP0 + UP * k / 8.0, 3), 0.0, round((SINK - 0.3) * (1.0 - eased(k / 8.0)), 3), 0.0) for k in range(1, 9)]   # keyed close so the feet stay planted
    tracks, body = _planted([limb(leg) for leg in ("fl", "fr", "hl", "hr")],
                            [(0.3, 0.0, 0.0, 0.0), (1.2, 0.0, SINK, 0.0), (1.5, 0.0, SINK - 0.3, 0.0), (UP0, 0.0, SINK - 0.3, 0.0)] + rise)
    TIMES = {   # each vent's (opening, shutting), by its heat: a pair at a time, and shut a pair at a time a beat apart
        "rear_vent_heat_l": (1.4, UP0), "rear_vent_heat_r": (1.4, UP0), "side_vent_heat_l": (1.85, UP0 + 0.12),
        "side_vent_heat_r": (1.85, UP0 + 0.12), "radiator_heat_l": (2.3, UP0 + 0.24), "radiator_heat_r": (2.3, UP0 + 0.24)}
    THROW, SHUT = ((0.0, 0.0), (0.35, 1.06), (0.55, 1.0)), 0.45   # a louvre's opening from its own moment; its shutting
    HEAT = 196.0   # the heat's light at its height, over its rest: under the phone's eased light (MechRig.light) it lands #ff7800, as 7 did before
    flare = lambda t0, t1: [(t0, 0.0), (round(t0 + 0.6, 3), HEAT), (t1, HEAT), (round(t1 + 0.65, 3), 0.0)]
    glow = []
    for heat, vent in vents:
        t0, t1 = TIMES[heat]
        for k, (jn, shut, swing) in enumerate(vent):
            tracks[jn] = [(round(t0 + 0.05 * k + t, 3), round(swing * f, 2)) for t, f in THROW] + [(t1, round(swing, 2)), (round(t1 + SHUT, 3), 0.0)]
        glow.append(([heat], flare(t0, t1)))
    for heat, jn, line, out in pops:   # the side vents slide out of their wells and home
        t0, t1 = TIMES[heat]
        tracks[jn] = [along(t, out * f, line) for t, f in ((t0, 0.0), (t0 + 0.45, 1.0), (t1, 1.0), (t1 + 0.5, 0.0))]
        glow.append(([heat], flare(t0, t1)))
    b.act("vent_heat", round(UP0 + UP + 0.3, 3), tracks, body=body, heft=0.1, glow=glow)
    b.halo = [heat for heat, _ in vents] + [p[0] for p in pops]   # its vents, hot
    # Movement (Ryan, 4 October, the third pass: stomp and plod, no weight thrown side to
    # side): a heavy walk in diagonal pairs, each foot planted flat while the shell passes
    # over it, lifted and stamped down; the shell level but for its drop onto each pair. The
    # sixteenth notes gave it the Clydesdale's elephant amble, and the seventeenth built each
    # walk with the hind knees folding back and forward to compare; Ryan picked this walk with
    # every knee folding forward (7 October, the eighteenth notes), the hind knees now folding
    # forward from the rest pose itself, so the acts follow without a word.
    tracks, body, stride = _plant([
        {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg],
         "phase": 0.0 if leg in ("fl", "hr") else 0.5, "shift": legs[leg][0][1] - legs[leg][2][1]}
        for leg in ("fl", "fr", "hl", "hr")], sweep=30.0, lift=7.0, crouch=0.5, dip=1.6, nod=0.6)
    b.gait(stride=stride, tracks=tracks, body=body, ease="linear")
    b.fires = {"cryo_flinger": ("weapons_check", 3.9, 5.6)}   # its fixed weapon fires with a slice of its act: the rack run out and back (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.move(accel=1.6, heft=0.26)
    # The seal (the form "sealed", held while the machine carries the status): the port guns
    # sink into the shell along their lines, past the ports' floors (and a gun fitted in a
    # forward port with them), then each port's iris plug rises out of its floor and closes it
    # just under the rim as every vent's louvres shut flat, the cowl lamps and the vents'
    # heat going dark ("the shell goes dark", its design note),
    # while the whole machine hunkers down on its planted feet, the shell low and its brow
    # dipped: the defensive base pose (Ryan, 29 October). Opening runs it back, the plugs
    # dropping before the guns rise. RIFTGATE_SEAL_DEBUG=1 holds it and lets it go in turn,
    # as the hangar's Forms toggle does, to judge running.
    # SINK takes the farthest a rear port's class reaches at its depth (18.4 along its line, a
    # gun's muzzle) under the iris, which closes about 3.2 out from the mount, and leaves the
    # deepest (a barrel's receiver, 18.3 back) inside the shell's floor, 37.5 down the line.
    SINK, SINK_F, T_SINK, T_PLUG0, T_PLUG1, T_ALL = 17.5, 32.0, 0.45, 0.45, 0.85, 1.2
    HUNK = (0.0, -11.0, -1.5)   # (dy, dz, pitch): low, the brow dipped
    FWD = (0.0, 1.0, 0.0)
    tracks = {jn: [along(0.0, 0.0), along(T_SINK, -SINK)] for jn in ("run_l", "run_r")}
    for tag in ("fl", "fr"):
        tracks["run_" + tag] = [along(0.0, 0.0, FWD), along(T_SINK, -SINK_F, FWD)]
    for jn, (hx, hy, hz) in shutters.values():
        tracks[jn] = [(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (T_PLUG0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (T_PLUG1, 0.0, 0.0, 0.0, hx, hy, hz)]
    for _, vent in vents:   # every vent shuts flat as the plugs close
        for jn, shut, swing in vent:
            tracks[jn] = [(0.0, 0.0), (T_PLUG0, 0.0), (T_PLUG1, shut)]
    hunker = [(round(0.2 + 0.1 * k, 3),) + tuple(round(v * eased(k / 9.0), 3) for v in HUNK) for k in range(10)]   # 0.2 to 1.1 s, dense so the feet stay planted
    limbs4 = [limb(leg) for leg in ("fl", "fr", "hl", "hr")]
    legs_t, body = _planted(limbs4, [(0.0, 0.0, 0.0, 0.0)] + hunker)
    tracks.update(legs_t)
    b.form("sealed", T_ALL, tracks, glow=[(["lamp"] + [heat for heat, _ in vents] + [p[0] for p in pops], -1.0)], body=body)
    # Open, its vents stand ajar (Ryan, 2 November: "When unsealed, the vents should be open, and
    # then more open during the vent animation"): each louvre half its throw and each side vent
    # half out of its well, the vent act opening them the rest of the way, the seal shutting them.
    AJAR = 0.5
    ajar = {jn: swing * AJAR for _, vent in vents for jn, shut, swing in vent}
    for heat, jn, line, out in pops:
        ajar[jn] = tuple(v * out * AJAR for v in line)
    b.ajar("sealed", ajar)
    # Sealed, it plays acts of its own from the hunker (Ryan, 29 October: "the animations set
    # shouldn't be the same, its base pose should be hunkered down in a defensive position"):
    # it braces lower and back as for a blow, rocks its weight back onto its hinds and forward
    # again, and runs the flingers' rack out to beep, since a sealed Polar Bear still lures; it
    # never vents sealed (Ryan, the same day: "I don't think a vent animation should run
    # during the sealed form"). Each an offset over the hunker, the legs solved from the
    # hunkered pose so the feet stay planted (_planted_over).
    tracks, body = _planted_over(limbs4, HUNK, [(0.5, 0.0, 0.0, 0.0), (1.0, -0.6, -2.0, 0.8), (2.6, -0.6, -2.2, 0.9), (3.4, 0.0, 0.0, 0.0)])
    b.act("brace", 3.8, tracks, body=body, form="sealed")
    tracks, body = _planted_over(limbs4, HUNK, [(0.4, 0.0, 0.0, 0.0), (1.3, -1.2, -0.6, 1.6), (2.4, 1.0, -0.4, -1.2), (3.4, 0.3, 0.0, -0.3), (4.2, 0.0, 0.0, 0.0)])
    b.act("rock", 4.6, tracks, body=body, form="sealed")
    b.act("lure", 5.2, {"run_rack": [along(0.6, 0.0), along(1.4, 4.0), along(3.8, 4.0), along(4.6, 0.0)]}, form="sealed",
          glow=[(["beacon"], blink(1.4, 3.8))])

polar_bear.maker = "minerva"


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
                b.stock("hp_%d" % (1 if s < 0 else 2), (s * 9.0, 14.0, 37.0), "barrel", carries="slugthrower")   # the stock's Slugthrowers as their class (Ryan, 11 November: no stock gun is built by hand)
        b.box(-4.0, 4.0, -20.0, -14.0, 42.0, 44.0, "steel.plate", "hatch")
        b.box(13.0, 16.0, -6.0, 0.0, 42.0, 45.0, "amber.light", "sight")
        b.pad("hp_4", (0.0, 2.0, 44.0))
    # The pod's mount on the left rear quarter's deck (hp_3), the stock's Shotfire Rack on it
    # as its class, its face forward.
    # Set back and out so the turret's drum and its guns sweep clear of it (Ryan, 1
    # October: the turret must look able to turn).
    with b.joint("elev_pod", (-TX - 1.0, -23.0, TH + 9.0), limits=(0.0, 16.0)):   # the pod tilts up on its deck
        b.stock("hp_3", (-TX - 1.0, -16.0, TH + 16.0), "rack", carries="shotfire_rack")
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
    b.fires = {"breaching_plow": ("test_plow", 2.5, 4.4)}   # its fixed weapon fires with a slice of its act: the plow down, shaken and thrown up (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.pivots = True   # its tracks turn it on the spot to aim the pod and the plow, as a tank's neutral turn (Ryan, 31 October: "a cheap way of aiming")
    b.move(accel=1.1, heft=0.18)

wild_boar.maker = "minerva"


def _wheel(b, cx, cy, r, w, label="wheel", lit=False):
    """An eight-sided wheel across x: rubber tread with a dark hub, a lit hub ring if asked."""
    b.prism("x", cx, cy, r, r, w, "bore.tread", 8, label, phase=math.pi / 8)
    b.prism("x", cx, cy, r, r * 0.5, w + 1.0, "steel.dark", 8, label + "_hub", phase=math.pi / 8)
    if lit:
        b.prism("x", cx, cy, r, r * 0.3, w + 1.6, "amber.engine", 8, label + "_ring", phase=math.pi / 8)


## The Prairie Dog's ride height over its wheels (Ryan, 9 October: the tyres down and away from
## their wells, a dune buggy's stance; then, the same day, 3.5 left a gap between the wheels and
## the chassis, so a little less); every part on its chassis rides this much higher.
LIFT_PRAIRIE = 2.0
## The arches' aprons' finish: the maker's rust, the flank stripe's ("steel.plate" for metal).
APRON_PRAIRIE = "livery.livery2"   # Ryan, 9 October: the livery aprons
## The arches (and their aprons' tops) sit this much lower than the ride height alone would put
## them (Ryan, 9 October: tighten them over the tyres once the rev was softened).
ARCH_DROP_PRAIRIE = 1.0   # a whole unit, to see (Ryan, 9 October: a little clipping at the vertices is fine)


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
    bare on the rear-right corner (the Flak Skirt takes no mount). Ryan, 30 September: the
    mast lower, the visor flush with the body; 1 October: a squatter turret, a gun either
    side, none in the middle, nothing hand-modelled. Ryan, 9 October, with the scout's role:
    the side skirts, their bash bars and the drops that hung them are gone, and everything
    on the chassis rides LIFT higher over the same wheels, so the tyres sit down and away from
    their wells, a dune buggy's stance on the armoured car; a rounded housing under the body
    along each axle, hub to hub, and the arches' aprons no wider than the arches."""
    R = 10.0
    L = LIFT_PRAIRIE   # the ride height over the wheels, on every part of the chassis
    LA = L - ARCH_DROP_PRAIRIE   # the arches' height, a little tighter over the tyres
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
    # The body rocks about the middle of the wheelbase (Ryan, 9 October: the rev took the front
    # tyres up through their arches; the pivot sat four back, so the nose swung furthest).
    chassis = b.joint("chassis", (0.0, 0.0, 12.0 + L), limits={"pitch": (-6.0, 6.0), "roll": (-6.0, 6.0)}, swing=False)
    chassis.__enter__()
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
            # Each arch comes down at its outer end (Ryan, 6 October, the thirteenth notes): an
            # apron across the tyre's front (or back), shielding it and closing the open wedge
            # where the arch rose off the tyre; on the body, the wheels moving free under it.
            # The apron ends at the arch's own outer edge (Ryan, 9 October: they stood out past
            # the wells; part of the well, not a plate bolted on beside it) and runs in to the
            # body's flank (the same day: gaps showed between it and the body, worst at the nose,
            # which narrows to the front), a quarter of a unit inside it so it never sits over
            # the hood (Ryan: trim the fronts' overlap with the hood).
            out_y, in_y = (yw + 12.0, yw - 12.0) if yw > 0.0 else (yw - 12.0, yw + 12.0)
            e = 1.0 if yw > 0.0 else -1.0
            xin = _prairie_body(out_y)[0] - 0.25
            b.box(min(s * xin, s * 23.0), max(s * xin, s * 23.0), min(out_y - e * 0.8, out_y + e * 0.6), max(out_y - e * 0.8, out_y + e * 0.6), 9.0 + L, R + 11.0 + LA, APRON_PRAIRIE, "apron")
            if yw < 0.0:
                b.loft([(yw - 12.0, rect(s * 18.0, 10.0, R + 7.0 + LA, R + 11.0 + LA)), (yw, rect(s * 18.0, 10.0, R + 11.0 + LA, R + 15.0 + LA)), (yw + 12.0, rect(s * 18.0, 10.0, R + 7.0 + LA, R + 11.0 + LA))], "steel.plate", "arch")
                continue
            # The front pair meet the body (Ryan, 6 October, the ninth notes: a gap between the
            # front fenders and the body; an inner flange stepping down into the nose was far too
            # smooth a join for W&S; the box rolled 15 degrees onto the nose lost its squared-off
            # look, the twelfth). The level box again, flat on top and square at every edge, its
            # inner edge following the hood's own edge a quarter of a unit inside it (Ryan, 9
            # October: trim the overlap with the hood; it had run a unit to a unit and a half over
            # it on one straight line), with a section at the hood's kink so it follows the taper,
            # and a square lip two units wide hung from that edge down to half a unit into the
            # body's top where the nose drops away under the arch, so the arch sits on the hull
            # as a bolted box would. Nothing over the tyre changes, so its top clears the tyre in
            # the rev as the level arch always has.
            secs = []
            for u in (-12.0, -6.0, 0.0, 12.0):
                y = yw + u
                z0 = R + 11.0 + LA - 4.0 * abs(u) / 12.0
                xi = _prairie_body(y)[0] - 0.25
                lip = min(z0, _prairie_body(y)[1] + L - 0.5)
                pts = [(xi, lip), (xi + 2.0, lip), (xi + 2.0, z0), (23.0, z0), (23.0, z0 + 4.0), (xi, z0 + 4.0)]
                secs.append((y, [(s * x, z) for x, z in (pts if s > 0 else pts[::-1])]))
            b.loft(secs, "steel.plate", "arch")
    # The body: a wedge lofted from a squared tail to a low raked nose, a chin plate under.
    b.loft([(-30.0, rect(0.0, 28.0, 8.0 + L, 24.0 + L)), (-6.0, rect(0.0, 30.0, 8.0 + L, 28.0 + L)), (12.0, rect(0.0, 28.0, 8.0 + L, 24.0 + L)), (32.0, rect(0.0, 20.0, 10.0 + L, 15.0 + L))], "steel.panel", "body")
    b.box(-10.0, 10.0, 30.0, 33.0, 8.0 + L, 12.0 + L, "steel.dark", "chin")
    # The axle covers (Ryan, 9 October: a rounded ridge on the underside, so the wheels stop
    # hanging off a floating body): a housing along each axle, hub to hub, and a rounded ridge
    # along each side of the floor joining them, half sunk into it. Only the side ridges show
    # from the game's camera, a rail under the flank between the wheels; the housings are what
    # they join.
    for yw in (18.0, -18.0):
        b.prism("x", 0.0, yw, R, 3.4, 31.0, "steel.dark", 8, "axle_cover", phase=math.pi / 8)
    for s in (-1.0, 1.0):
        b.prism("y", s * 11.5, 0.0, R, 3.0, 36.0, "steel.dark", 8, "axle_ridge", phase=math.pi / 8)
    for s in (-1.0, 1.0):
        b.box(min(s * 14.0, s * 15.5), max(s * 14.0, s * 15.5), -26.0, 6.0, 12.0 + L, 20.0 + L, "livery.livery2", "flank_stripe")
    # The windscreen: armoured glass lying flush on the raked roof, slit-narrow, a brow
    # over its top edge.
    _rings(b, [[(-10.0, 13.0, 23.6 + L), (10.0, 13.0, 23.6 + L), (10.0, 13.0, 24.8 + L), (-10.0, 13.0, 24.8 + L)],
               [(-9.0, 19.0, 20.9 + L), (9.0, 19.0, 20.9 + L), (9.0, 19.0, 22.1 + L), (-9.0, 19.0, 22.1 + L)]], "glass.glass", "windscreen")
    b.box(-12.0, 12.0, 10.5, 13.5, 23.5 + L, 26.5 + L, "steel.plate", "brow")
    # The turret on the roof (Ryan, 1 October): squatter, wider, a gun on either side and
    # none in the middle, every gun the class shape and nothing hand-modelled. The left
    # gun is the fixed Flakshot Repeater (a barrel, no pin); the right is hp_1, the Twin
    # Autoguns (a twin barrel).
    b.prism("z", 0.0, -8.0, 28.25 + L, 5.5, 1.5, "steel.dark", 8, "neck")
    b.prism("z", 0.0, -8.0, 29.75 + L, 7.0, 1.5, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, -8.0, 30.5 + L)):   # traverses
        b.prism("z", 0.0, -8.0, 33.0 + L, 7.5, 5.0, "steel.panel", 8, "turret", phase=math.pi / 8)
        # The guns at the drum's middle, their receivers sunk into its flanks (Ryan, 1
        # October: they floated off it, too far forward).
        start = len(b.objects)
        shape_barrel(b, 0.7)
        for ob in b.objects[start:]:
            ob.matrix_world = Matrix.Translation(Vector((-8.8, -9.0, 33.0 + L)))
        # The scattergun's business end on the turret, as a barrel's muzzle sits (MUZZLES): it
        # flares there and the turret kicks as it fires (Ryan's go of 3 November).
        b.fx("flakshot_repeater", (-8.8, -9.0 + 33.0 * 0.7, 33.0 + L), size=24.0 * 0.7)
        b.stock("hp_1", (8.8, -9.0, 33.0 + L), "twin_barrel", scale=0.7, carries="twin_autoguns")
    # The mast, out of the tail's centre, lower: a post, a sensor head, a red light.
    b.prism("z", 0.0, -27.0, 28.5 + L, 1.2, 11.0, "steel.dark", 4, "mast")   # rooted in the roof; a little shorter (Ryan, 1 October)
    with b.joint("sensor", (0.0, -27.0, 34.0 + L), limits=(-75.0, 75.0)):   # the head turns on its mast (the joint pass)
        b.box(-2.5, 2.5, -29.5, -24.5, 34.0 + L, 39.0 + L, "steel.panel", "sensor_head")
        b.box(-1.5, 1.5, -24.4, -23.6, 35.0 + L, 38.0 + L, "glass.glass", "sensor_eye")
        b.prism("z", 0.0, -27.0, 40.5 + L, 1.5, 3.0, "amber.engine", 6, "mast_light")
    # The tail (Ryan, 30 September: something to break up the back): a raised hatch panel
    # with a handle, a jerry can strapped either side, tail lights at the corners, a hitch.
    b.box(-7.0, 7.0, -30.8, -30.0, 11.0 + L, 21.0 + L, "steel.panel", "rear_hatch")
    b.box(-3.0, 3.0, -31.6, -30.8, 15.0 + L, 16.2 + L, "steel.dark", "hatch_handle")
    for s in (-1.0, 1.0):
        b.box(s * 11.0 - 2.0, s * 11.0 + 2.0, -32.5, -30.0, 10.0 + L, 17.0 + L, "livery.livery2", "jerry_can")
        b.box(s * 11.0 - 2.4, s * 11.0 + 2.4, -32.7, -29.8, 13.0 + L, 13.8 + L, "steel.dark", "can_strap")
        b.box(s * 12.0 - 1.5, s * 12.0 + 1.5, -30.6, -30.0, 19.0 + L, 21.5 + L, "amber.light", "tail_light")
    b.box(-1.5, 1.5, -34.0, -30.0, 8.0 + L, 10.0 + L, "steel.dark", "hitch")
    # The projector on the rear-left corner (hp_2): the stock's Halo Shield as its class, a
    # dish facing forward (the launcher there went with the old stock: Ryan's go, 28 October).
    b.stock("hp_2", (-10.0, -26.0, 28.5 + L), "dish", scale=0.6, carries="halo_projector")
    # The third mount (hp_3) is bare on the rear-right corner, the projector's twin.
    b.pad("hp_3", (10.0, -26.0, 26.0 + L), scale=0.7, size=(6.0, 2.0))   # on the roof, not above it
    for s in (-1.0, 1.0):
        b.box(s * 7.0 - 2.0, s * 7.0 + 2.0, 32.5, 33.5, 12.0 + L, 14.0 + L, "amber.light", "lamp")
    chassis.__exit__(None, None, None)

    # Idle acts, third pass (Ryan, 4 October: turrets too fast and wild; real machines with
    # inertia): curves a part runs on through, the servos' heft (b.move), and the turret slow
    # and short with a pause before it turns back (the builder's rule); the wheels spin as
    # keyed. Degrees and seconds; a key is (t, value) on the joint's own axis or (t, pitch,
    # yaw, roll); a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow
    # key is (t, k), k the light added over rest.
    # The rock five degrees and the squat under half a unit (Ryan, 9 October: six degrees and a
    # squat of two and a half took the tyres two units into the arches once the wheels came up
    # under them; then, with the arches a whole unit lower, a little clipping at the vertices is
    # fine). Measured at the keys: the front tyres reach about half a unit into their arches at
    # the deepest (the servo trails this slow a curve and never passes a key).
    b.act("rev", 4.2, {   # revs eagerly: a jump forward, a squat, back, and again; the wheels spin hard
        "wheel_fl": [(0.3, 0.0), (1.4, -900.0), (2.4, -540.0), (3.4, -1080.0), (4.2, -1080.0)],
        "wheel_fr": [(0.3, 0.0), (1.4, -900.0), (2.4, -540.0), (3.4, -1080.0), (4.2, -1080.0)],
        "wheel_rl": [(0.3, 0.0), (1.4, -900.0), (2.4, -540.0), (3.4, -1080.0), (4.2, -1080.0)],
        "wheel_rr": [(0.3, 0.0), (1.4, -900.0), (2.4, -540.0), (3.4, -1080.0), (4.2, -1080.0)],
        "chassis": [(0.5, 5.0, 0.0, 0.0, 0.0, 0.0, -0.4), (1.2, -5.0, 0.0, 0.0, 0.0, 0.0, -0.3), (2.2, 4.0, 0.0, 0.0, 0.0, 0.0, -0.2), (3.0, -5.0, 0.0, 0.0, 0.0, 0.0, -0.3), (3.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)],
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
    # The front wheels steer 14 degrees a radian a second of turning, eased toward full lock (32)
    # and on a short servo (Ryan, 7 October, the nineteenth notes: they jumped from straight to
    # full lock, since the gain had been read per degree a second): about 22 through a corner's
    # first quarter, 30 at its quickest.
    b.gait(wheels={"wheel_fl": R, "wheel_fr": R, "wheel_rl": R, "wheel_rr": R}, steer={"steer_fl": 14.0, "steer_fr": 14.0}, rock=5.0)
    b.aims = {"flakshot_repeater": "turret"}   # the Flakshot Repeater rides the turret beside hp_1, so the turret turns to aim it
    b.move(accel=0.6, heft=0.1)

prairie_dog.maker = "wainwright_sutler"


## The Cassowary's leg (31 October): a digitigrade leg in its own plane, hip, knee forward, hock
## back and the ball of the foot, each pivot (y, z); the shank from the hock to the ball and the
## toes ride the ankle at the hock and the toe joint at the ball.
_CASSOWARY_HIP = (-1.0, 56.0)
_CASSOWARY_KNEE = (9.0, 47.0)
_CASSOWARY_HOCK = (-7.0, 24.0)
_CASSOWARY_BALL = (2.0, 4.0)


def _cassowary_oct(w, z0, z1, c):
    """A rectangle with every corner chamfered by `c`, as (x, z) points for a loft: the
    Cassowary's cab, squared off and bevelled."""
    hw = w / 2.0
    return [(-hw + c, z0), (hw - c, z0), (hw, z0 + c), (hw, z1 - c), (hw - c, z1), (-hw + c, z1), (-hw, z1 - c), (-hw, z0 + c)]


def _cassowary_mono(pts):
    """A monotone cubic through (t, v...) rows, as the rig runs an act's keys (MechRig._through):
    no slope at a turn, a hold or either end, the weighted harmonic mean of the secants either
    side where a value runs on through a key. Returns a function of t, held outside the keys."""
    pts = sorted((tuple(float(v) for v in p) for p in pts), key=lambda p: p[0])
    n, w = len(pts), len(pts[0]) - 1
    ts = [p[0] for p in pts]
    m = [[0.0] * w for _ in range(n)]
    for i in range(1, n - 1):
        h0, h1 = ts[i] - ts[i - 1], ts[i + 1] - ts[i]
        if h0 <= 0.0 or h1 <= 0.0:
            continue
        for j in range(w):
            d0 = (pts[i][j + 1] - pts[i - 1][j + 1]) / h0
            d1 = (pts[i + 1][j + 1] - pts[i][j + 1]) / h1
            if d0 * d1 > 0.0:
                w0, w1 = 2.0 * h1 + h0, h1 + 2.0 * h0
                m[i][j] = (w0 + w1) / (w0 / d0 + w1 / d1)

    def at(t):
        if t <= ts[0]:
            return pts[0][1:]
        if t >= ts[-1]:
            return pts[-1][1:]
        i = min(max(bisect.bisect_right(ts, t) - 1, 0), n - 2)
        h = ts[i + 1] - ts[i]
        u = (t - ts[i]) / h if h > 0.0 else 1.0
        u2, u3 = u * u, u * u * u
        a, c, d, e = 2.0 * u3 - 3.0 * u2 + 1.0, u3 - 2.0 * u2 + u, -2.0 * u3 + 3.0 * u2, u3 - u2
        return tuple(a * pts[i][j + 1] + c * h * m[i][j] + d * pts[i + 1][j + 1] + e * h * m[i + 1][j] for j in range(w))
    return at


def _cassowary_dense(keys, until, hz=30.0):
    """Sparse keys (t, v...) as dense ones `hz` a second up to `until`, on the curve the rig would
    run through them (rest before the first, as an act's track), for an act keyed linear."""
    pts = list(keys)
    if pts[0][0] > 0.0:
        pts = [(0.0,) + (0.0,) * (len(pts[0]) - 1)] + pts
    f = _cassowary_mono(pts)
    return [(round(i / hz, 3),) + tuple(round(v, 3) for v in f(i / hz)) for i in range(int(round(until * hz)) + 1)]


def _cassowary_hock(ball, shank):
    """Where the hock stands over a ball at `ball` (y, z) with the shank tipped `shank` degrees
    from its rest (pitch, so a negative tip lifts the heel)."""
    vy, vz = _CASSOWARY_HOCK[0] - _CASSOWARY_BALL[0], _CASSOWARY_HOCK[1] - _CASSOWARY_BALL[1]
    c, s = math.cos(math.radians(shank)), math.sin(math.radians(shank))
    return (ball[0] + vy * c - vz * s, ball[1] + vy * s + vz * c)


def _cassowary_solve(ball, shank, toes, dy, dz, pitch):
    """A leg's hip, knee, ankle and toe (degrees) putting its ball at `ball` (y, z, the model's
    rest frame) with the shank tipped `shank` and the toes `toes` to the ground (both pitch from
    rest), under a body slid (dy, dz) and pitched `pitch`: the hip and the knee carry the hock,
    the knee forward (_ik2), the ankle sets the shank and the toe joint the toes."""
    target = _to_body(*_cassowary_hock(ball, shank), dy, dz, pitch)
    hip, knee = _ik2(_CASSOWARY_HIP, _CASSOWARY_KNEE, _CASSOWARY_HOCK, target, -1.0)
    return hip, knee, shank - (hip + knee + pitch), toes - shank


def _cassowary_pose(frames, until, hz=30.0):
    """Leg tracks and body keys for one of the Cassowary's acts, dense for ease "linear": `frames`
    is (t, (dy, dz, pitch), {side: (ball y, ball z, shank, toes)}) with each foot named where it
    is at that moment (at rest until first named, then where it was last named), the body and
    each foot run on the curve the rig runs an act's keys on, so a planted foot never slides
    between keys. Returns joint -> keys and the body keys."""
    rest = (_CASSOWARY_BALL[0], _CASSOWARY_BALL[1], 0.0, 0.0)
    body = _cassowary_mono([(0.0, 0.0, 0.0, 0.0)] + [(t,) + tuple(p) for t, p, _ in frames])
    feet = {}
    for side in ("l", "r"):
        rows = [(0.0,) + rest] + [(t,) + tuple(f[side]) for t, _, f in frames if side in f]
        feet[side] = _cassowary_mono(rows)
    tracks = {j + side: [] for side in ("l", "r") for j in ("hip_", "knee_", "ankle_", "toe_")}
    out = []
    for i in range(int(round(until * hz)) + 1):
        t = round(i / hz, 3)
        dy, dz, pitch = body(t)
        for side in ("l", "r"):
            y, z, shank, toes = feet[side](t)
            q = _cassowary_solve((y, z), shank, toes, dy, dz, pitch)
            for j, v in zip(("hip_", "knee_", "ankle_", "toe_"), q):
                tracks[j + side].append((t, round(v, 3)))
        out.append((t, 0.0, round(dy, 3), round(dz, 3), 0.0, round(pitch, 3), 0.0))
    return tracks, out


def _cassowary_stride(sweep, duty=0.6, lift=5.0, heel=-28.0, roll=0.3, flex=22.0, curl=-30.0, crouch=0.5, dip=1.6, nod=1.2,
                      reach=0.97, n=60, carry=(0.08, 0.8)):
    """The Cassowary's walk (31 October), _plant's worked foot by foot for a digitigrade leg: each
    foot's toes planted flat through its stance while the leg sweeps back under the body, and in
    the stance's last `roll` the heel lifts, the shank tipping `heel` degrees about the ball with
    the toes still flat, the push-off. Then the hock carries forward, lifted `lift`, as the ankle
    flexes the foot up and forward under it, `flex` degrees, its toes curling `curl` (a bird's
    swing: the hock stays low, so the knee never rises into the cab), and the foot reaches down
    flat to land. The body rides as high as its planted legs allow kept `reach` of straight,
    `crouch` lower, and drops `dip` and nods `nod` degrees onto each foot, never rolling. The feet
    a half stride apart. Returns (tracks, body, stride) for b.gait with ease "linear"."""
    stride = sweep / duty
    shank_swing = _cassowary_mono([(0.0, heel), (0.45, flex), (0.85, 0.0), (1.0, 0.0)])
    toes_swing = _cassowary_mono([(0.0, 0.0), (0.25, curl), (0.65, curl * 0.4), (0.85, 0.0), (1.0, 0.0)])
    phases = {"l": 0.0, "r": 0.5}
    y0, z0 = _CASSOWARY_BALL
    off_y, off_z = _cassowary_hock((y0 - sweep * 0.5, z0), heel)   # the hock as the toes leave the ground
    land_y, land_z = _cassowary_hock((y0 + sweep * 0.5, z0), 0.0)  # and as the foot lands

    def foot(side, p):
        """(ball y, ball z, shank, toes, planted) at phase p."""
        q = (p - phases[side]) % 1.0
        if q < duty:
            u = max(0.0, (q / duty - (1.0 - roll)) / roll)
            return y0 + sweep * 0.5 - sweep * q / duty, z0, heel * u * u * (3.0 - 2.0 * u), 0.0, True
        s = (q - duty) / (1.0 - duty)
        u = min(1.0, max(0.0, (s - carry[0]) / carry[1]))
        w = u * u * (3.0 - 2.0 * u)
        hy, hz = off_y + (land_y - off_y) * w, off_z + (land_z - off_z) * w
        if s < 0.3:
            hz += lift * (1.0 - (1.0 - s / 0.3) ** 2)   # up briskly
        elif s < 0.62:
            hz += lift
        else:
            hz += lift * (1.0 - ((s - 0.62) / 0.38) ** 2)  # down gathering speed
        shank = shank_swing(s)[0]
        oy, oz = _cassowary_hock((0.0, 0.0), shank)
        return hy - oy, hz - oz, shank, toes_swing(s)[0], False

    span = reach * (math.hypot(_CASSOWARY_KNEE[0] - _CASSOWARY_HIP[0], _CASSOWARY_KNEE[1] - _CASSOWARY_HIP[1])
                    + math.hypot(_CASSOWARY_HOCK[0] - _CASSOWARY_KNEE[0], _CASSOWARY_HOCK[1] - _CASSOWARY_KNEE[1]))
    pose = []
    for i in range(n + 1):
        p = i / float(n)
        ride = 0.0
        for side in ("l", "r"):
            y, z, shank, _toes, down = foot(side, p)
            if not down:
                continue
            hy, hz = _cassowary_hock((y, z), shank)
            dy = hy - _CASSOWARY_HIP[0]
            ride = min(ride, hz + math.sqrt(max(0.0, span * span - dy * dy)) - _CASSOWARY_HIP[1])
        jolt = 0.0
        for land in phases.values():
            x = (p - land) % 1.0
            jolt += x / 0.05 if x < 0.05 else ((1.0 - (x - 0.05) / 0.35) ** 2 if x < 0.4 else 0.0)
        pose.append((ride - crouch - dip * jolt, -nod * jolt))
    tracks = {}
    for side in ("l", "r"):
        rows = {j: [] for j in ("hip_", "knee_", "ankle_", "toe_")}
        for i in range(n + 1):
            p = i / float(n)
            y, z, shank, toes, _down = foot(side, p)
            dz, pitch = pose[i]
            for j, v in zip(("hip_", "knee_", "ankle_", "toe_"), _cassowary_solve((y, z), shank, toes, 0.0, dz, pitch)):
                rows[j].append((p, round(v, 3)))
        for j, keys in rows.items():
            tracks[j + side] = (keys, 0.0)
    body = [(i / float(n), 0.0, 0.0, round(dz, 3), 0.0, round(pitch, 3), 0.0) for i, (dz, pitch) in enumerate(pose)]
    return tracks, body, stride


def _cassowary_drum_ring(cx, cz, r, flute):
    """The drum's fluted section about its axis (cx, cz) as (x, z) points: six lands of radius
    `r`, one round each chamber, and a groove `flute` deep between each pair, the chambers at
    every sixth of a turn from the top (where the hammer stands)."""
    pts = []
    for j in range(6):
        c = 60.0 * j
        for a, rr in ((c - 16.0, r), (c + 16.0, r), (c + 30.0, r - flute)):
            pts.append((cx + rr * math.sin(math.radians(a)), cz + rr * math.cos(math.radians(a))))
    return pts


def cassowary(b):
    """Wainwright & Sutler "Cassowary" (Pattern 15 Gun Walker), first cut 31 October from Ryan's
    to-do line: a medium chicken walker in the maker's iron, the AT-ST silhouette, a squared cab
    on two digitigrade legs, no arms, five hardpoints, the Spin-Up showing nowhere. Each leg a
    short thigh down and forward to the knee under the pelvis, the long drumstick of a shin back
    to a high hock, the shank down to the ball. The cab turns on a waist over the pelvis the legs
    hang from (a walker turns at the waist), its brow over a visor slit and two lamps, the chin
    turret under the prow. Second round, 2 November, on Ryan's notes ("more of a symbolic
    revolver than a literal one", "weird toes, not mechanical enough"): the revolver drum on the
    cab's flank is a capacitor bank now, six cells round a core between two end plates, wound
    with two copper coils, on its axle in straps off the cab under a lit spark gap; its cells
    light one a counted shot, charging toward the sixth shot, the one its Indexed Cylinder
    counts double, and all six flare and go dark as that shot discharges it (b.count, the
    machine's `shots`); it spins while the machine is Spun Up, the status its Spin-Up grants
    (b.spin_held). The feet are the AT-ST's, broad and flat in iron: a heel block on the shank,
    three hinged toe plates on the ball, so the toes stay flat as the heel lifts. Mounts in the
    die's order: hp_1 the chin turret's Twin Autoguns, hp_2 the left pod's Rivet Gun, hp_3 the
    Ankle Mortar's rack on the roof's rear right, hp_4 the Halo Shield's dish on the roof's
    front left, hp_5 bare on the roof's rear left (the Coolant Jacket shows nowhere)."""
    # The pelvis the legs hang from, a dark block under the waist, a drive box behind it.
    b.box(-12.0, 12.0, -9.0, 7.0, 50.0, 62.0, "steel.dark", "pelvis")
    b.box(-7.0, 7.0, -12.0, -9.0, 52.0, 60.0, "steel.panel", "drive_box")
    b.prism("z", 0.0, -1.0, 62.6, 9.0, 1.6, "steel.dark", 8, "waist_ring", phase=math.pi / 8)
    # The legs, each in its own plane: a hip disc on the pelvis's flank, a short thigh down and
    # forward to the knee, the shin long down and back to the hock, the shank down to the ball,
    # and the foot, the AT-ST's in iron (Ryan, 2 November: the bird's toes were "not mechanical
    # enough"): a heel block on the shank behind the ball, clevis plates either side of the ball's
    # hinge, and on the toe joint three flat toe plates splayed a little, a dark cap on each, so
    # the plates stay flat on the ground as the heel lifts. Nothing hangs below z = 0.
    LX = 17.0
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        x = s * LX
        hip, knee = (x,) + _CASSOWARY_HIP, (x,) + _CASSOWARY_KNEE
        hock, ball = (x,) + _CASSOWARY_HOCK, (x,) + _CASSOWARY_BALL
        with b.joint("hip_" + side, hip, limits=(-35.0, 65.0)):   # what the acts and the stride ask, with a margin
            b.prism("x", x, hip[1], hip[2], 5.6, 9.0, "steel.dark", 8, "hip_disc", phase=math.pi / 8)
            _beam(b, hip, knee, _sq(7.5, 10.0), _sq(6.5, 8.5), "steel.plate", "thigh")
            b.prism("x", x, knee[1], knee[2], 4.2, 9.0, "steel.dark", 8, "knee", phase=math.pi / 8)
            with b.joint("knee_" + side, knee, limits=(-55.0, 25.0)):
                # The drumstick, the leg's long visible stroke: a livery plate on its outer face
                # and a tendon rod down its back.
                _beam(b, knee, hock, _sq(6.0, 7.0), _sq(5.2, 6.0), "steel.panel", "shin")
                d = (Vector(hock) - Vector(knee)).normalized()
                back = Vector((0.0, d.z, -d.y)) if d.z < 0.0 else Vector((0.0, -d.z, d.y))   # square to the shin, toward the leg's rear
                back = back if back.y < 0.0 else -back
                p0, p1 = Vector(knee) + (Vector(hock) - Vector(knee)) * 0.15, Vector(knee) + (Vector(hock) - Vector(knee)) * 0.8
                _beam(b, tuple(p0 + Vector((s * 3.4, 0.0, 0.0))), tuple(p1 + Vector((s * 3.4, 0.0, 0.0))), _sq(0.8, 6.4), _sq(0.8, 5.4), "livery.livery2", "shin_plate")
                _beam(b, tuple(p0 + back * 3.6), tuple(p1 + back * 3.4), _poly(0.9, 6), _poly(0.9, 6), "steel.dark", "tendon")
                b.prism("x", x, hock[1], hock[2], 3.6, 8.0, "steel.dark", 8, "hock", phase=math.pi / 8)
                with b.joint("ankle_" + side, hock, limits=(-60.0, 65.0)):
                    _beam(b, hock, ball, _sq(4.6, 5.0), _sq(4.2, 4.2), "steel.dark", "shank")
                    by = ball[1]
                    b.loft([(by - 10.0, rect(x, 8.0, 0.0, 2.6)), (by - 7.5, rect(x, 10.0, 0.0, 4.8)), (by - 0.6, rect(x, 10.0, 0.0, 4.8))], "steel.plate", "heel")
                    b.box(x - 5.0, x + 5.0, by - 9.5, by - 0.6, 0.0, 0.7, "steel.dark", "heel_tread")
                    for xo in (-4.0, 4.0):
                        b.box(x + xo - 0.6, x + xo + 0.6, by - 3.0, by + 2.2, 1.0, 8.0, "steel.panel", "clevis")
                    b.prism("x", x, ball[1], ball[2], 2.4, 9.2, "steel.dark", 8, "ball", phase=math.pi / 8)
                    with b.joint("toe_" + side, ball, limits=(-85.0, 50.0)):
                        b.box(x - 6.6, x + 6.6, by - 0.4, by + 3.4, 0.0, 2.8, "steel.plate", "forefoot")
                        for ang, length in ((0.0, 13.0), (s * 13.0, 11.5), (-s * 13.0, 11.5)):
                            d = Vector((math.sin(math.radians(ang)), math.cos(math.radians(ang)), 0.0))
                            sd = Vector((d.y, -d.x, 0.0))
                            root = Vector((x, by + 1.0, 0.0)) + sd * (math.copysign(4.3, ang) if ang else 0.0)
                            ring = lambda c, w, h: [tuple(c + sd * (w / 2.0)), tuple(c - sd * (w / 2.0)), tuple(c - sd * (w / 2.0) + Vector((0.0, 0.0, h))), tuple(c + sd * (w / 2.0) + Vector((0.0, 0.0, h)))]
                            _rings(b, [ring(root, 4.4, 2.8), ring(root + d * (length * 0.62), 4.4, 2.8), ring(root + d * length, 3.8, 1.3)], "steel.plate", "toe_plate")
                            _rings(b, [ring(root + d * (length * 0.84), 4.6, 1.9), ring(root + d * (length + 0.6), 4.0, 1.0)], "steel.dark", "toe_cap")

    # The waist (a walker turns at the waist): the cab and everything on it turns and leans on it.
    waist = b.joint("waist", (0.0, -1.0, 62.0), axis="yaw", limits={"yaw": (-45.0, 45.0), "pitch": (-15.0, 12.0), "roll": (-6.0, 6.0)}, swing=False)
    waist.__enter__()
    b.prism("z", 0.0, -1.0, 64.0, 7.0, 1.6, "steel.dark", 8, "collar", phase=math.pi / 8)
    # The cab: squared off and bevelled, the prow raked above and below a vertical nose, the
    # visor slit in the nose under a brow, a lamp either side of it.
    b.loft([(-17.0, _cassowary_oct(25.0, 66.0, 82.0, 2.5)), (-15.5, _cassowary_oct(28.0, 64.0, 84.0, 3.0)), (9.0, _cassowary_oct(28.0, 64.0, 84.0, 3.0)),
            (14.5, _cassowary_oct(27.0, 65.5, 80.5, 3.0)), (19.0, _cassowary_oct(23.0, 69.5, 75.5, 2.0))], "steel.panel", "cab")
    for s in (-1.0, 1.0):
        b.box(min(s * 14.0, s * 14.4), max(s * 14.0, s * 14.4), -14.0, 8.0, 76.5, 80.5, "livery.livery2", "flank_band")
    b.box(-7.5, 7.5, 18.7, 19.5, 71.0, 74.0, "glass.glass", "visor")
    for s in (-1.0, 1.0):
        b.box(min(s * 8.6, s * 10.6), max(s * 8.6, s * 10.6), 18.6, 19.6, 71.0, 74.0, "amber.light", "lamp")
    b.box(-10.5, 10.5, 17.0, 20.8, 75.3, 76.9, "steel.plate", "brow")
    # The roof: a hatch, the rear deck in the livery, an antenna; the tail's grille and lights.
    b.box(-5.0, 5.0, -2.0, 6.0, 84.0, 85.2, "steel.plate", "hatch")
    b.box(-1.5, 1.5, 4.5, 5.5, 85.2, 86.0, "steel.dark", "hatch_handle")
    b.box(-11.0, 11.0, -15.0, -4.0, 84.0, 84.5, "livery.livery2", "deck")
    b.prism("z", -11.0, -14.0, 89.0, 0.5, 10.0, "steel.dark", 4, "antenna")
    b.box(-8.0, 8.0, -17.6, -17.0, 69.0, 77.0, "steel.vent", "rear_vent")
    for s in (-1.0, 1.0):
        b.box(min(s * 9.5, s * 11.5), max(s * 9.5, s * 11.5), -17.5, -16.8, 78.5, 80.5, "amber.light", "tail_light")
    # The chin turret under the prow (hp_1): the stock's Twin Autoguns as their class, on an
    # elevation, far enough forward to read past the nose from above.
    b.box(-5.5, 5.5, 7.0, 14.0, 60.0, 64.5, "steel.dark", "chin_mount")
    with b.joint("elev_chin", (0.0, 12.0, 62.0), limits=(-12.0, 25.0)):
        b.stock("hp_1", (0.0, 14.0, 62.0), "twin_barrel", scale=0.6, carries="twin_autoguns")
    # The left pod (hp_2): an armoured box on the flank, a livery panel on its face, the
    # stock's Rivet Gun as its class forward out of it, on an elevation.
    b.box(-19.5, -13.5, -7.0, 9.0, 67.0, 77.0, "steel.plate", "pod")
    b.box(-19.8, -19.5, -5.0, 7.0, 68.5, 75.5, "livery.livery2", "pod_panel")
    with b.joint("elev_pod", (-16.75, 3.0, 72.0), limits=(-10.0, 25.0)):
        b.stock("hp_2", (-16.75, 9.0, 72.0), "barrel", scale=0.62, carries="rivet_gun")
    # The roof's mounts: the Ankle Mortar's rack at the rear right on its elevation, pitched up
    # (hp_3); the Halo Shield's dish at the front left on a short mast (hp_4); the rear left bare
    # (hp_5: the Coolant Jacket shows nowhere).
    b.box(4.0, 11.0, -14.0, -7.0, 84.5, 86.0, "steel.dark", "mortar_base")
    with b.joint("elev_mortar", (7.5, -10.5, 87.0), limits=(-15.0, 25.0)):
        b.stock("hp_3", (7.5, -11.0, 87.5), "rack", forward=(0.0, 0.819, 0.574), scale=0.5, carries="ankle_mortar")
    b.prism("z", -7.5, 3.0, 86.0, 2.0, 4.4, "steel.dark", 6, "dish_base")
    b.stock("hp_4", (-7.5, 3.0, 88.2), "dish", scale=0.55, carries="halo_projector")
    b.pad("hp_5", (-7.5, -10.5, 85.5), scale=0.55, size=(6.0, 1.5))
    # The capacitor on the right flank, where the revolver drum hung (Ryan, 2 November: "some kind
    # of capacitor, charging up for the sixth hit of its passive"): six cells round a core between
    # two end plates, wound with two copper coils, on an axle in straps off the cab, a spark gap
    # lit over its rear on an arm off the cab, two horns and the spark between them. Each cell's
    # lens in either end plate and its window down its outside light, a cell a counted shot,
    # cell_1 at the top first and the rest clockwise seen from behind; the sixth shot, the one the
    # Indexed Cylinder counts double, discharges them, all six flaring and going dark (b.count).
    # The bank spins while the machine is Spun Up (b.spin_held).
    DX, DY, DZ, DR = 23.5, 0.5, 72.0, 8.5
    Y0, Y1 = DY - 7.5, DY + 7.5
    RC, RL = 4.9, 2.0   # the cells' circle and their lenses
    b.prism("y", DX, DY, DZ, 1.8, 22.0, "steel.dark", 8, "capacitor_axle", phase=math.pi / 8)
    for y in (Y1 + 0.9, Y0 - 0.9):
        b.box(14.0, DX + 1.0, y - 0.9, y + 0.9, DZ - 1.0, DZ + 1.0, "steel.dark", "capacitor_strap")
        b.prism("y", DX, y, DZ, 2.8, 2.0, "steel.plate", 8, "capacitor_boss", phase=math.pi / 8)
    b.box(12.0, DX + 2.0, Y0 - 2.6, Y0 - 0.4, DR + DZ + 0.8, DR + DZ + 2.5, "steel.plate", "spark_arm")
    for xo in (-1.9, 1.9):
        _beam(b, (DX + xo, Y0 - 1.5, DR + DZ + 2.4), (DX + xo * 0.55, Y0 - 1.5, DR + DZ + 5.4), _sq(0.9, 0.9), _sq(0.6, 0.6), "steel.dark", "spark_horn")
    b.box(DX - 0.9, DX + 0.9, Y0 - 2.0, Y0 - 1.0, DR + DZ + 3.0, DR + DZ + 5.0, "amber.lit", "spark_gap")
    with b.joint("capacitor", (DX, DY, DZ), axis="roll"):
        for yf in (Y0, Y1):
            b.prism("y", DX, yf, DZ, DR, 1.4, "steel.plate", 12, "end_plate", phase=math.pi / 12)
        b.prism("y", DX, DY, DZ, 2.6, Y1 - Y0, "steel.panel", 8, "core", phase=math.pi / 8)
        for yb in (DY - 3.2, DY + 3.2):
            b.prism("y", DX, yb, DZ, 7.7, 1.8, "livery.livery2", 12, "coil", phase=math.pi / 12)
        cells = []
        for k in range(6):
            a = math.radians(60.0 * k)
            n, t = Vector((math.sin(a), 0.0, math.cos(a))), Vector((math.cos(a), 0.0, -math.sin(a)))
            c = Vector((DX, DY, DZ)) + n * RC
            label = "cell_%d" % (k + 1)
            cells.append(label)
            b.prism("y", c.x, DY, c.z, 2.3, Y1 - Y0 - 1.0, "steel.dark", 8, "cell_body", phase=math.pi / 8)
            for yf, out in ((Y0, -1.0), (Y1, 1.0)):
                b.prism("y", c.x, yf + out * 0.85, c.z, RL + 0.55, 0.4, "steel.dark", 8, "cell_bezel", phase=math.pi / 8)
                b.prism("y", c.x, yf + out * 1.0, c.z, RL, 0.5, "amber.spark", 8, label, phase=math.pi / 8)
            w = c + n * 2.25   # the window down the cell's outside, between the end plates
            strip = lambda y: [tuple(w + t * 0.75 + Vector((0.0, y, 0.0)) - n * 0.2), tuple(w - t * 0.75 + Vector((0.0, y, 0.0)) - n * 0.2),
                               tuple(w - t * 0.75 + Vector((0.0, y, 0.0)) + n * 0.25), tuple(w + t * 0.75 + Vector((0.0, y, 0.0)) + n * 0.25)]
            _rings(b, [strip(Y0 + 0.9 - DY), strip(Y1 - 0.9 - DY)], "amber.spark", label)
    b.count("shots", cells, on=6.0, off=-1.0, flare=14.0)   # hot when charged, unlit glass when not (lean hotter: the phone sees the rear plate in the cab's shadow)
    b.spin_held("spun_up", "capacitor", 600.0)
    waist.__exit__(None, None, None)

    # Idle acts (the builder's rules: loud, never in step, every joint pausing before it turns
    # back; the feet planted, each act's legs worked out frame by frame, _cassowary_pose, dense
    # for ease "linear", the other tracks on the curve the rig would run, _cassowary_dense).
    # Degrees and seconds; a body pose is (dy, dz, pitch), a foot (ball y, ball z, shank, toes).
    BY, BZ = _CASSOWARY_BALL
    # Test-charging the capacitor: it braces and draws, the cab coming round on the waist onto its
    # mark and the guns up, then the bank spins up three turns, the spark gap crackling hotter as
    # it gathers speed, and as it brakes the gap flashes and the cab kicks back, a test discharge;
    # it holds, lowers and turns home. The bank ends where it started, three turns on (the cells
    # are the count display's alone: nothing here lights them).
    tracks, body = _cassowary_pose([(0.4, (0.0, 0.0, 0.0), {}), (1.0, (0.0, -1.6, -1.0), {}), (3.25, (0.0, -1.8, -1.2), {}), (3.38, (0.0, -2.6, 1.0), {}),
                                    (3.8, (0.0, -1.5, -0.6), {}), (4.9, (0.0, 0.0, 0.0), {})], until=5.8)
    tracks["waist"] = _cassowary_dense([(0.4, 0.0, 0.0, 0.0), (1.0, -2.0, 14.0, 0.0), (3.25, -2.4, 15.0, 0.0), (3.38, 2.2, 15.0, 0.0), (3.8, -1.5, 14.5, 0.0),
                                        (4.6, 0.0, 0.0, 0.0)], 5.8)
    tracks["capacitor"] = _cassowary_dense([(1.1, 0.0), (1.8, 180.0), (2.4, 540.0), (2.9, 900.0), (3.3, 1080.0)], 5.8)
    tracks["elev_chin"] = _cassowary_dense([(0.5, 0.0), (1.1, 9.0), (3.3, 10.0), (4.3, 0.0)], 5.8)
    tracks["elev_pod"] = _cassowary_dense([(0.6, 0.0), (1.2, 7.0), (3.3, 8.0), (4.4, 0.0)], 5.8)
    crackle = [(1.1, 0.0), (1.4, 5.0), (1.5, 1.0), (1.75, 7.0), (1.85, 2.0), (2.1, 9.0), (2.2, 3.0), (2.45, 11.0), (2.55, 4.0), (2.8, 12.0), (3.25, 12.0),
               (3.32, 18.0), (3.6, 4.0), (4.2, 0.0)]
    b.act("test_charge", 5.8, tracks, body=body, ease="linear", heft=0.08,
          glow=[(["spark_gap"], crackle), (["lamp"], [(0.5, 0.0), (1.0, 6.0), (3.4, 6.0), (4.2, 0.0)])])
    # The scan: it rises tall on its toes, the heels lifting, the cab turns on the waist to the
    # left and dips to look, holds, swings across to the right and looks, holds, and comes home
    # as it settles, the lamps hot.
    UP = (BY, BZ, -14.0, 0.0)
    tracks, body = _cassowary_pose([(0.4, (0.0, 0.0, 0.0), {}), (1.4, (0.0, 3.0, 0.5), {"l": UP, "r": UP}), (6.2, (0.0, 3.2, 0.5), {"l": UP, "r": UP}),
                                    (7.2, (0.0, 0.0, 0.0), {"l": (BY, BZ, 0.0, 0.0), "r": (BY, BZ, 0.0, 0.0)})], until=7.6)
    tracks["waist"] = _cassowary_dense([(1.0, 0.0, 0.0, 0.0), (2.1, -4.0, 34.0, 0.0), (3.3, -5.0, 35.0, 0.0), (5.3, -4.0, -34.0, 0.0), (6.5, -5.0, -35.0, 0.0), (7.4, 0.0, 0.0, 0.0)], 7.6)
    b.act("scan", 7.6, tracks, body=body, ease="linear", glow=[(["lamp"], [(1.0, 0.0), (1.6, 7.0), (6.6, 7.0), (7.3, 0.0)])])
    # Hunkering down: it sinks low on its legs, the hocks folding toward the ground and the cab
    # tipping down to look under its prow, holds, then heaves up past its height onto its toes,
    # the chin guns and the pod gun coming up as it rises, and settles.
    LOW = (BY, BZ, 18.0, 0.0)
    tracks, body = _cassowary_pose([(0.5, (0.0, 0.0, 0.0), {}), (1.8, (0.0, -11.0, -2.5), {"l": LOW, "r": LOW}), (3.6, (0.0, -11.8, -3.0), {"l": LOW, "r": LOW}),
                                    (4.6, (0.0, 1.6, 1.0), {"l": (BY, BZ, -6.0, 0.0), "r": (BY, BZ, -6.0, 0.0)}),
                                    (5.4, (0.0, 0.6, 0.3), {"l": (BY, BZ, -2.0, 0.0), "r": (BY, BZ, -2.0, 0.0)}),
                                    (6.3, (0.0, 0.0, 0.0), {"l": (BY, BZ, 0.0, 0.0), "r": (BY, BZ, 0.0, 0.0)})], until=6.6)
    tracks["waist"] = _cassowary_dense([(0.6, 0.0, 0.0, 0.0), (1.8, -6.0, 0.0, 0.0), (3.6, -7.0, 0.0, 0.0), (4.6, 3.0, 0.0, 0.0), (5.6, 0.0, 0.0, 0.0)], 6.6)
    tracks["elev_chin"] = _cassowary_dense([(3.6, 0.0), (4.4, 18.0), (5.2, 18.0), (6.0, 0.0)], 6.6)
    tracks["elev_pod"] = _cassowary_dense([(3.7, 0.0), (4.5, 12.0), (5.2, 12.0), (6.0, 0.0)], 6.6)
    b.act("hunker", 6.6, tracks, body=body, ease="linear", glow=[(["lamp"], [(1.4, 0.0), (2.0, 5.0), (4.2, 5.0), (5.0, 0.0)])])
    # The kick (the flightless bird that kills): the pilot tests the left leg, drawing the foot
    # up folded and holding it, the toe plates flexing on their hinges, then a kick
    # straight out ahead that gathers speed into it and stops dead, held, drawn back, and
    # stamped down, the body dropping onto it; the right foot planted throughout.
    HELD = (BY + 6.0, 16.0, 35.0, -22.0)   # the foot tucked up and forward under the hock, the ankle folded
    OUT = (BY + 20.0, 10.0, 5.0, 6.0)
    frames = [(0.4, (0.0, 0.0, 0.0), {}), (1.0, (0.0, -1.2, 1.5), {"l": (BY + 4.0, 12.0, 25.0, -20.0)}), (1.6, (0.0, -1.0, 1.8), {"l": HELD}),
              (1.9, (0.0, -1.0, 1.8), {"l": HELD[:3] + (6.0,)}), (2.2, (0.0, -1.0, 1.9), {"l": HELD}), (2.5, (0.0, -1.0, 2.0), {"l": HELD})]
    frames += [(t, p[:3], {"l": p[3:]}) for t, p in _slam(2.5, (0.0, -1.0, 2.0) + HELD, 2.7, (0.0, -0.6, 3.5) + OUT)]
    frames += [(3.1, (0.0, -0.6, 3.4), {"l": OUT}), (3.7, (0.0, -1.0, 1.5), {"l": (BY + 2.0, 13.0, 20.0, -10.0)}),
               (3.95, (0.0, -1.0, 1.2), {"l": (BY + 0.5, 9.0, 8.0, 0.0)})]
    frames += [(t, p[:3], {"l": p[3:]}) for t, p in _slam(3.95, (0.0, -1.0, 1.2, BY + 0.5, 9.0, 8.0, 0.0), 4.1, (0.0, -2.4, -1.2, BY, BZ, 0.0, 0.0))]
    frames += [(4.6, (0.0, -0.3, 0.2), {}), (5.4, (0.0, 0.0, 0.0), {})]
    tracks, body = _cassowary_pose(frames, until=6.0)
    tracks["waist"] = _cassowary_dense([(0.6, 0.0, 0.0, 0.0), (1.4, -3.0, 0.0, 0.0), (2.5, -3.5, 0.0, 0.0), (2.7, 2.0, 0.0, 0.0), (3.1, 1.6, 0.0, 0.0), (4.0, -2.0, 0.0, 0.0),
                                        (4.15, 1.5, 0.0, 0.0), (5.0, 0.0, 0.0, 0.0)], 6.0)
    b.act("kick", 6.0, tracks, body=body, ease="linear", heft=0.07, glow=[(["lamp"], [(2.4, 0.0), (2.7, 8.0), (3.2, 8.0), (3.8, 0.0)])])
    # Movement: a long digitigrade stride, the toes planted while the body passes over them, the
    # heel lifting into the push-off, the ankle folding the foot up under the hock as it swings
    # and reaching it down to land flat; the body dropping and nodding onto each foot. A sweep of
    # 40, a stride of 67, so its four hexes a move are paced, not scurried (at 30 it took three
    # steps a second at its map pace).
    tracks, body, stride = _cassowary_stride(sweep=40.0, curl=-18.0)   # the toe plates droop on their hinges through the swing, less than a bird's toes curl
    b.gait(stride=stride, tracks=tracks, body=body, ease="linear")
    b.move(accel=1.0, heft=0.17)
    # Its Spin-Up plays a slice of its test charge as it is used (Ryan, 31 October: the cheapest
    # first; found unfired on 3 November): the capacitor drum spinning up three turns as the spark
    # gap crackles, to the snap at its top.
    b.fires = {"spin_up": ("test_charge", 0.9, 3.8)}

cassowary.maker = "wainwright_sutler"


def dingo(b):
    """Wainwright & Sutler "Dingo" (Pattern 12 Support Car): the agile, stealthy one, low
    enough to skirt between a big foe's legs (Ryan, 29 September; the MK-200 and the
    Tumbler, toned down to W&S). A flat wedge of a body, and the wheels out on swing arms,
    each on its own cambered arm off the body's corners, hubs lit, so it reads as a thing
    that steps rather than rolls. The Hollow-point Harpoon (fixed, no pin; the Megataser Harpoon until 11 November) lies low along
    the roof, its capacitor drum sunk into the tail. The coolant tanks are detail on both
    flanks (Ryan, 30 September: the rail into the drum, a vent on the tail plate, the glass
    along the body). Since the stock pass and Ryan's notes of 28 October ("twin autoguns can't
    be that wide since we don't have variable-width hardpoints... so those are actually two
    hardpoints on the nose. Then where the burst shell used to be can be the coil thing"): the
    two nose ports are two hardpoints, the stock's Twin Autoguns in the left as its class (hp_2)
    and the right bare (hp_3); the Airburst Shell's rack on a gimbal on the flat of the roof,
    left of the harpoon (hp_1; Ryan, 29 October, from the rear-left deck); and the Combat
    Translocator (fixed, no pin) on the rear-right where the tube stood: a riveted cabinet with
    two prongs raised forward and a lit coil threaded on a core between them, W&S iron that is
    totally not a teleporter."""
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
    # The nose guns, either side of the visor's tip: two hardpoints, one gun a mount (Ryan, 28
    # October: no variable-width hardpoints), the stock's Twin Autoguns in the left as their
    # class (hp_2), the right bare (hp_3). Each sits on a low pedestal on the nose ahead of the
    # visor (Ryan's go of 2 November: the mounts had sat inside the raked nose, which buried a
    # fitted dish and half sank a rack), so whatever is fitted stands clear of the nose.
    for s in (-1.0, 1.0):
        px = s * 6.0
        b.box(px - 2.6, px + 2.6, 31.0, 34.5, 9.0, 12.0, "steel.dark", "nose_mount")
        if s < 0:
            b.stock("hp_2", (px, 33.0, 13.6), "twin_barrel", scale=0.45, carries="twin_autoguns")
        else:
            b.pin("hp_3", (px, 33.0, 13.6), scale=0.45, carries="")
    # The launcher on a gimbal on the flat of the roof, left of the harpoon (Ryan, 29 October:
    # "put the back quarter hardpoint on the flat part of the roof instead, still on that
    # side of the harpoon, on a rotating gimbal"; it had stood on the rear-left deck): a
    # turntable on the roof, a yoke turning on it, the stock's Airburst Shell as its class
    # (hp_1) elevating between the yoke's cheeks, clear of the yoke at every elevation.
    GX, GY, GZ = -8.0, -5.0, 25.5
    b.prism("z", GX, GY, 19.9, 4.0, 1.4, "steel.dark", 8, "gimbal_base", phase=math.pi / 8)
    with b.joint("turret_rack", (GX, GY, 20.6), limits=(-30.0, 120.0)):   # the gimbal's traverse, more to the left than toward the harpoon
        b.box(GX - 5.0, GX + 5.0, GY - 1.8, GY + 1.8, 20.6, 21.4, "steel.plate", "gimbal_yoke")
        for s in (-1.0, 1.0):
            b.box(min(GX + s * 4.2, GX + s * 5.0), max(GX + s * 4.2, GX + s * 5.0), GY - 1.6, GY + 1.6, 21.4, GZ + 1.4, "steel.panel", "gimbal_yoke")
            b.prism("x", GX + s * 5.3, GY, GZ, 1.0, 0.6, "steel.plate", 8, "trunnion")
        with b.joint("elev_rack", (GX, GY, GZ), limits=(-8.0, 30.0)):   # the launcher elevates in the yoke
            b.stock("hp_1", (GX, GY, GZ), "rack", forward=(0.0, 0.940, 0.342), scale=0.5, carries="airburst_shell")
    # The Combat Translocator on the rear-right deck where the tube stood (fixed, no pin):
    # a riveted cabinet bolted behind the drum, two prongs raised forward off its top and a
    # stack of lit coil rings between them, threaded on a core out of the cabinet (Ryan, 29
    # October: the rings had floated between the prongs, touching nothing); the coil
    # crackles in its own act.
    b.box(6.0, 14.0, -32.0, -25.5, 16.0, 23.0, "steel.panel", "coil_cabinet")
    b.box(6.5, 13.5, -31.5, -26.0, 23.0, 24.0, "steel.plate", "coil_cap")
    b.box(5.8, 14.2, -32.2, -31.8, 18.0, 20.0, "steel.stripe", "coil_band")
    CD = Vector((0.0, math.cos(math.radians(30.0)), math.sin(math.radians(30.0))))
    C0 = Vector((10.0, -28.0, 24.0))
    for xo in (-2.2, 2.2):
        p0 = C0 + Vector((xo, 0.0, 0.0))
        _beam(b, tuple(p0), tuple(p0 + CD * 12.0), _poly(0.7, 6), _poly(0.45, 6), "steel.dark", "coil_prong")
        b.prism("y", p0.x, (p0 + CD * 12.0).y, (p0 + CD * 12.0).z, 0.8, 1.0, "steel.plate", 6, "prong_tip")
    A0 = C0 + Vector((0.0, 0.0, 0.4))   # the coil's axis
    _beam(b, tuple(A0 - CD * 1.5), tuple(A0 + CD * 11.2), _poly(0.6, 6), _poly(0.5, 6), "steel.dark", "coil_core")
    b.prism("y", A0.x, (A0 + CD * 11.2).y, (A0 + CD * 11.2).z, 0.9, 0.8, "steel.plate", 6, "coil_top")
    for k in range(4):
        c = A0 + CD * (3.5 + 2.2 * k)
        _beam(b, tuple(c - CD * 0.35), tuple(c + CD * 0.35), _poly(1.5, 8), _poly(1.5, 8), "amber.tesla", "coil")   # lightning blue (Ryan, 31 October)
    # The coolant tanks low on both flanks, a drum with a grille and a dump valve each:
    # detail.
    for s in (-1.0, 1.0):
        b.prism("y", s * 17.5, -6.0, 11.0, 3.2, 18.0, "steel.plate", 8, "coolant_tank")
        b.box(min(s * 19.2, s * 17.0), max(s * 19.2, s * 17.0), -4.0, 4.0, 10.0, 12.0, "steel.vent", "tank_grille")
        b.prism("z", s * 17.5, 2.5, 7.0, 1.0, 3.0, "steel.dark", 6, "dump_valve")
    # One antenna, on the left: its twin on the right ran up through the Translocator's
    # cabinet once the coil stood there (Ryan, 29 October: removed).
    b.prism("z", -11.0, -29.0, 22.0, 0.5, 12.0, "steel.dark", 4, "antenna")
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
    # straightens it and the tube drops. On the roof's gimbal (29 October) the launcher swings
    # out over the left quarter as it ticks up, and comes back as it drops; the tail still
    # lays it fine.
    kick = lambda t, yaw_deg, dy=0.0: (t, round(26.0 * math.sin(math.radians(yaw_deg)), 2), round(26.0 * (1.0 - math.cos(math.radians(yaw_deg))) + dy, 2), 0.0, yaw_deg, 0.0, 0.0)
    b.act("rack_check", 5.6, {   # the launcher swung out and ticked up notch by notch; the rear casters snap and kick the tail over to lay it, a jitter, a correction back, a throttle blip, and down and home
        "turret_rack": [(0.4, 0.0), (1.8, 45.0), (3.8, 45.0), (5.2, 0.0)],
        "elev_rack": [(0.4, 0.0), (0.5, 9.5), (0.58, 8.5), (0.95, 8.5), (1.05, 17.5), (1.13, 16.5), (1.5, 16.5), (1.6, 25.5), (1.68, 24.5), (2.2, 24.5),
                      (2.26, 26.0), (2.32, 24.0), (2.38, 25.5), (2.44, 24.5), (2.85, 24.5), (2.92, 23.0), (2.98, 23.5), (3.7, 23.5), (3.8, 25.0), (4.6, 0.0)],
        **{"caster_" + w: [(1.75, 0.0), (1.85, -16.0), (2.6, -16.0), (2.68, 12.0), (3.15, 12.0), (3.25, 0.0)] for w in ("rl", "rr")},
        **{"caster_" + w: [(1.8, 0.0), (1.9, 5.0), (2.6, 5.0), (2.7, -3.0), (3.15, -3.0), (3.25, 0.0)] for w in ("fl", "fr")},
        **{"wheel_" + w: spin([(1.85, 0.0), (2.0, -1.8), (2.6, -1.8), (2.72, 0.6), (3.15, 0.6), (3.33, 3.1), (3.65, 0.0)], ROLL) for w in ("rl", "rr")},
        **{"wheel_" + w: spin([(3.15, 0.0), (3.33, 2.5), (3.65, 0.0)], ROLL) for w in ("fl", "fr")},
    }, body=[(1.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), kick(2.0, 3.5), kick(2.55, 3.5), kick(2.72, -1.1), kick(3.15, -1.1), kick(3.33, 0.0, 2.5), kick(3.65, 0.0)], heft=0.06)
    # The coil check (28 October, with the Translocator modelled): the coil crackles in
    # bursts, a flicker and a hot hold, the car twitching on its casters at each burst as the
    # antsy pilot's inputs do; nothing moves but the light and the twitch.
    crackle = [(0.4, 0.0), (0.48, 9.0), (0.55, 1.0), (0.62, 12.0), (0.7, 2.0), (0.78, 14.0), (1.4, 14.0), (1.5, 1.0),
               (2.2, 1.0), (2.28, 10.0), (2.34, 2.0), (2.42, 16.0), (3.0, 16.0), (3.2, 0.0)]
    b.act("coil_check", 3.6, {
        "chassis": [(0.45, 0.0, 0.0, 0.0), (0.6, 0.0, 0.0, 1.5), (0.8, 0.0, 0.0, -1.0), (1.0, 0.0, 0.0, 0.0),
                    (2.25, 0.0, 0.0, 0.0), (2.4, 0.0, 0.0, -1.5), (2.6, 0.0, 0.0, 1.0), (2.8, 0.0, 0.0, 0.0)],
    }, heft=0.06, glow=[(["coil"], crackle)])
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
    b.halo = ["coil"]   # the Translocator's coil, hot (Ryan, 31 October)
    b.gait(wheels={"wheel_fl": R, "wheel_fr": R, "wheel_rl": R, "wheel_rr": R},
           aim={"caster_fl": 1.0, "caster_fr": 1.0, "caster_rl": 1.0, "caster_rr": 1.0}, rock=4.0)
    b.fires = {"hollow_point_harpoon": ("harpoon", 2.0, 3.2), "combat_translocator": ("coil_check", 2.0, 3.2)}   # its fixed weapons fire with slices of its acts: the harpoon's shot and kick; the coil's second flare (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.pivots = True   # its casters turn it on the spot to aim its nose guns, the harpoon and the coil (Ryan, 31 October: "a cheap way of aiming")
    b.move(slide=0.4, bank=0.0, accel=0.5, heft=0.09, oversteer=2.0)   # drifts wildly on the map and does not bank (Ryan, 2 October); its rear kicked out further (the sixth notes), and further again (the seventh)

dingo.maker = "wainwright_sutler"


def _cottonmouth_prisms(b, specs, material, label):
    """Several low prisms as one part, each (axis, (cx, cy, cz), radius, length, sides, phase)
    laid as Build.prism lays one: a lit set that draws in one call (the weld keeps a lit part
    whole, so six lamps as six parts would be six draws), or a row of like pieces."""
    bm = bmesh.new()
    for axis, (cx, cy, cz), r, length, n, phase in specs:
        if axis == "y":
            m = Matrix.Translation((cx, cy, cz))
        elif axis == "x":
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(math.pi / 2, 4, "Z")
        else:
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(-math.pi / 2, 4, "X")
        rings = [[bm.verts.new(m @ Vector((r * math.cos(phase + 2.0 * math.pi * k / n), y, r * math.sin(phase + 2.0 * math.pi * k / n))))
                  for k in range(n)] for y in (-length / 2.0, length / 2.0)]
        for k in range(n):
            k2 = (k + 1) % n
            bm.faces.new([rings[0][k], rings[0][k2], rings[1][k2], rings[1][k]])
        bm.faces.new(rings[0])
        bm.faces.new(rings[1])
    return b._finish(bm, material, label)


def _cottonmouth_ring(b, cx, cz, y0, y1, r_out, r_in, n, material, label, phase=0.0):
    """A closed ring about an axis along y from `y0` to `y1`: its outer and inner walls and
    both end faces, so a duct or a muzzle reads as a thick-walled hoop from either end."""
    bm = bmesh.new()
    ring = lambda y, r: [bm.verts.new((cx + r * math.cos(phase + 2.0 * math.pi * k / n), y, cz + r * math.sin(phase + 2.0 * math.pi * k / n))) for k in range(n)]
    o0, o1, i1, i0 = ring(y0, r_out), ring(y1, r_out), ring(y1, r_in), ring(y0, r_in)
    for k in range(n):
        k2 = (k + 1) % n
        bm.faces.new([o0[k], o0[k2], o1[k2], o1[k]])
        bm.faces.new([o1[k], o1[k2], i1[k2], i1[k]])
        bm.faces.new([i1[k], i1[k2], i0[k2], i0[k]])
        bm.faces.new([i0[k], i0[k2], o0[k2], o0[k]])
    return b._finish(bm, material, label)


def _cottonmouth_boxes(b, boxes, material, label):
    """Several boxes as one part, each (centre, (u, v, w), (hu, hv, hw)): its three axes as
    vectors and its half-size along each, so a ring of windows round a drum lies square to it
    and draws in one call."""
    bm = bmesh.new()
    for centre, axes, half in boxes:
        c = Vector(centre)
        u, v, w = (Vector(a).normalized() for a in axes)
        corners = [bm.verts.new(c + u * (su * half[0]) + v * (sv * half[1]) + w * (sw * half[2]))
                   for sw in (-1.0, 1.0) for sv in (-1.0, 1.0) for su in (-1.0, 1.0)]
        for f in ((0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)):
            bm.faces.new([corners[i] for i in f])
    return b._finish(bm, material, label)


def _cottonmouth_blade(b, centre, a, r0, r1, chord, pitch, thick, material, label):
    """One fan blade in the disc square to y about `centre`: from radius `r0` to `r1` along the
    angle `a` (radians, from +x toward +z), its chord across the radius pitched `pitch` radians
    out of the disc, as a thin slab."""
    c = Vector(centre)
    u = Vector((math.cos(a), 0.0, math.sin(a)))
    t = Vector((-math.sin(a), 0.0, math.cos(a)))
    ax = Vector((0.0, 1.0, 0.0))
    cd = t * math.cos(pitch) + ax * math.sin(pitch)
    nd = ax * math.cos(pitch) - t * math.sin(pitch)
    face = [c + u * r0 - cd * (chord * 0.5), c + u * r1 - cd * (chord * 0.4), c + u * r1 + cd * (chord * 0.4), c + u * r0 + cd * (chord * 0.5)]
    return _rings(b, [[tuple(p + nd * (thick / 2.0)) for p in face], [tuple(p - nd * (thick / 2.0)) for p in face]], material, label)


def cottonmouth(b):
    """Wainwright & Sutler "Cottonmouth" (Pattern 16 Hover Gunboat): the reach piece, every
    weapon and equipment it aims at a foe leaving the drum as one Indirect shot (Ryan's go, 19
    October; its brief: git show 021f075:docs/briefs/ws_fan_boat.md). Ryan's picture (19
    October): "a big rotating set of barrels with the guns mounted (invisibly) inside, like a
    multi shot grenade launcher. We call it a fan boat but the profile is more sophisticated than
    that, it is still future-tech after all"; the to-do's line: a light hovercraft in the
    maker's iron, a hover hull under a big rotating drum of barrels, the fitted guns inside it,
    the one machine whose hardpoints show no mounts. First cut, 31 October: a squared-off
    hover barge on a rubber skirt the whole way round (its fingers the tread's cleats), a raked
    punt bow behind a fender, gunwale rails, the maker's brown on the flanks; a low armoured
    wheelhouse at the bow, its visor slit on the raked face under a brow, a searchlight on its
    roof that turns (joint sensor) and a whip antenna; amidships the Adaptive Munitions Drum
    (the passive, no entry on the die) on trunnions in a yoke on a ring, elevating to lob (joint
    elev_drum) and turning on its own axis (joint drum, always turning slowly, b.spin): a
    riveted breech casing banded in the livery, a window in the band over each chamber, its back
    a face of six chamber caps round a hub, each lamp banked; six fat barrels out of its front
    through two collars to bored muzzles. Its turn reads from the barrels alone (Ryan, 2
    November: "How on earth does six rotating barrels look still?"), so no barrel is marked.
    The third round (Ryan, 2 November: "Keep the idle turn ... Quickly spin it forward a fixed
    number of barrels when it fires ... only ever light the top barrel mouth"; of the back's lit
    lamp, "that's part of the flash and should be lit when the muzzle is"): an act that turns
    the drum on locks its idle turn (b.spin's step, the act's `locks`), parking it on a chamber,
    and the windows and every chamber lamp burn while it turns (the strip); a shot lights the top
    chamber alone, front and back: the top mouth and the top lamp, fixed on the elevation (not
    the rolling drum), rest hidden in the collar and the casing and slide into the top chamber
    only while the drum stands parked for a shot (joints top_mouth and top_lamp), so neither
    shows in a seam between barrels as the drum turns. The lift intakes either side of the yoke
    and an ammunition locker either side of the barrels, lidded in the livery.
    The heat is the heat tile's, an orange of red and green alone (#ff7800 at its height). The stern is the
    fan-boat's: two ducted fans side by side on a fairing, hazard-striped lips, five blades each
    with yellow tips turning against each other (joints fan_l and fan_r, b.spin), a lit ring
    behind each rotor, and two rudder vanes behind each duct (joints rudder_l1, rudder_l2,
    rudder_r1, rudder_r2) that steer with the turns. Mounts in the die's order, all four hidden
    inside the drum's casing (b.pin hidden=True: nothing drawn there, stock or fitted), riding
    its elevation so a shot kicks the drum: hp_1 the Ankle Mortar, hp_2 the Twin Autoguns, hp_3
    the Halo Shield, hp_4 bare (the Coolant Jacket takes no mount). Floats: the skirt at z = 5.
    The look, the rig, the acts and the gait are Ryan's to judge running."""
    DECK = 15.0
    # The skirt: a rubber bag under the hull the whole way round, bulging past it, rising with
    # the bow's rake; its rounded ends in plan from sections that narrow fore and aft.
    SKIRT = [(-37.0, 6.6, 10.6, 30.0, 2.0), (-35.6, 5.6, 11.0, 40.0, 2.4), (-33.0, 5.0, 11.4, 45.0, 2.6), (21.0, 5.0, 11.4, 45.0, 2.6),
             (28.0, 6.2, 12.4, 43.0, 2.6), (33.0, 8.2, 13.8, 37.0, 2.2), (35.6, 10.0, 14.2, 27.0, 1.8)]   # (y, z0, z1, w, c), stern to bow
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.4)) for (y, z0, z1, w, c) in SKIRT], "bore.tread", "skirt")
    # The hull: a squared barge, the deck level stem to stern, the bottom raked up to a blunt
    # punt bow; riveted iron.
    b.loft([(-34.0, _case(38.0, 9.6, DECK, 2.0)), (-31.0, _case(40.0, 9.0, DECK, 2.6)), (20.0, _case(40.0, 9.0, DECK, 2.6)),
            (28.0, _case(37.0, 10.8, DECK, 2.4)), (33.0, _case(32.0, 13.0, DECK, 2.0))], "steel.panel", "hull")
    for s in (-1.0, 1.0):
        # The gunwale rail along each deck edge, the maker's brown panel down each flank, the
        # lift intakes either side of the drum's yoke.
        b.box(min(s * 19.0, s * 20.4), max(s * 19.0, s * 20.4), -33.0, 19.0, DECK - 0.2, DECK + 0.9, "steel.dark", "gunwale")   # ends where the bow narrows (Ryan, 2 November: the rails poked too far forward)
        b.box(min(s * 19.95, s * 20.5), max(s * 19.95, s * 20.5), -27.0, 17.0, 11.6, 14.2, "livery.livery2", "flank_panel")
        b.box(min(s * 15.6, s * 18.8), max(s * 15.6, s * 18.8), -19.0, -1.0, DECK, DECK + 0.6, "steel.vent", "lift_grille")
        # An ammunition locker either side of the barrels, bolted to the deck, its lid in the
        # livery.
        b.box(min(s * 13.8, s * 18.8), max(s * 13.8, s * 18.8), 3.0, 14.0, DECK, DECK + 3.4, "steel.panel", "locker")
        b.box(min(s * 14.3, s * 18.3), max(s * 14.3, s * 18.3), 3.5, 13.5, DECK + 3.4, DECK + 3.9, "livery.livery2", "locker_lid")
    b.box(-14.5, 14.5, 31.2, 33.6, DECK - 0.6, DECK + 0.5, "steel.dark", "bow_fender")
    _cottonmouth_prisms(b, [("z", (s * 14.5, y, DECK + 1.2), 1.1, 2.4, 6, 0.0) for s in (-1.0, 1.0) for y in (26.5, -23.5)], "steel.dark", "bollard")
    _cottonmouth_prisms(b, [("z", (s * 14.5, y, DECK + 2.6), 1.6, 0.6, 6, 0.0) for s in (-1.0, 1.0) for y in (26.5, -23.5)], "steel.plate", "bollard_cap")
    for s in (-1.0, 1.0):
        b.box(s * 16.0 - 1.6, s * 16.0 + 1.6, -34.5, -33.9, 12.4, 14.4, "amber.lit", "tail_light")

    # The wheelhouse at the bow: low and armoured, its face raked, the visor slit across the rake
    # under a brow, its roof in the livery, two lamps under the face, the searchlight and a whip
    # antenna on the roof.
    CABZ = 22.0
    rake = lambda y: CABZ - 1.15 * (y - 27.0)
    b.loft([(20.0, _case(18.0, DECK - 0.5, CABZ, 1.6)), (27.0, _case(18.0, DECK - 0.5, CABZ, 1.6)), (31.0, _case(16.4, DECK - 0.5, rake(31.0), 1.2))], "steel.panel", "cab")
    _rings(b, [[(-7.0, y, rake(y) - 0.1), (7.0, y, rake(y) - 0.1), (7.0, y, rake(y) + 0.45), (-7.0, y, rake(y) + 0.45)] for y in (27.6, 29.0)], "glass.glass", "visor")
    b.box(-8.6, 8.6, 25.6, 27.6, CABZ - 0.4, CABZ + 1.2, "steel.plate", "brow")
    b.box(-7.4, 7.4, 20.6, 25.4, CABZ, CABZ + 0.5, "livery.livery2", "cab_roof")
    for s in (-1.0, 1.0):
        b.box(s * 5.2 - 1.5, s * 5.2 + 1.5, 30.9, 31.5, DECK + 0.7, DECK + 2.1, "amber.lit", "lamp")
    b.prism("z", -6.0, 21.6, CABZ + 6.4, 0.4, 12.0, "steel.dark", 4, "antenna")
    b.prism("z", 4.4, 23.0, CABZ + 0.9, 1.4, 0.8, "steel.dark", 8, "searchlight_base")
    with b.joint("sensor", (4.4, 23.0, CABZ + 1.3), axis="yaw", limits=(-80.0, 80.0)):
        b.box(3.0, 5.8, 21.6, 24.8, CABZ + 1.3, CABZ + 3.9, "steel.plate", "searchlight_housing")
        b.box(3.3, 5.5, 24.8, 25.3, CABZ + 1.6, CABZ + 3.6, "amber.lit", "searchlight")

    # The drum's yoke: a ring on the deck, a base, two cheeks rising either side of the drum to
    # the trunnions, a sight on the left cheek.
    PY, ZA = -9.0, 29.5          # the trunnions: the drum's pivot and its axis's height
    RC = 12.4                    # the breech casing's radius
    b.prism("z", 0.0, PY + 1.0, DECK + 0.4, 11.0, 0.8, "steel.dark", 12, "yoke_ring", phase=math.pi / 12)
    for s in (-1.0, 1.0):
        b.box(min(s * 12.6, s * 16.6), max(s * 12.6, s * 16.6), PY - 5.6, PY + 7.0, DECK + 0.2, DECK + 2.6, "steel.panel", "yoke_base")
        b.loft([(PY - 4.6, rect(s * 14.4, 2.6, DECK + 2.6, ZA + 3.0)), (PY + 4.6, rect(s * 14.4, 2.6, DECK + 2.6, ZA + 3.0)),
                (PY + 6.2, rect(s * 14.4, 2.6, DECK + 2.6, ZA - 3.0))], "steel.panel", "yoke_cheek")
        b.prism("x", s * 16.2, PY, ZA, 3.0, 1.2, "steel.dark", 8, "trunnion", phase=math.pi / 8)
    b.box(-15.6, -13.2, PY - 2.0, PY + 2.4, ZA + 3.0, ZA + 4.6, "amber.lit", "sight")

    # The drum: elevating in the yoke, turning on its own axis inside it.
    RR, RB = 7.6, 3.7            # the barrels' ring radius and each barrel's
    angles = [math.pi / 2.0 + k * math.pi / 3.0 for k in range(6)]   # a barrel on top at rest, and at every step of 60 degrees
    y0, y1, ym = PY + 10.0, PY + 21.0, PY + 27.5   # the barrels from the casing's face, the muzzles, their mouths
    yb, cr = PY - 7.0, 6.6                         # the drum's back and its chambers' circle there
    with b.joint("elev_drum", (0.0, PY, ZA), axis="pitch", limits=(0.0, 30.0)):
        with b.joint("drum", (0.0, PY, ZA), axis="roll"):
            # The breech casing: chamfered at its back so the drum lifts clear of the deck.
            b.loft([(PY - 7.0, _oct(ZA, 2.0 * (RC - 1.8), 2.0 * (RC - 1.8), 0.0, 12)), (PY - 4.6, _oct(ZA, 2.0 * RC, 2.0 * RC, 0.0, 12)),
                    (PY + 10.0, _oct(ZA, 2.0 * RC, 2.0 * RC, 0.0, 12))], "steel.panel", "casing")
            b.loft([(PY - 5.2, _oct(ZA, 2.0 * RC + 0.8, 2.0 * RC + 0.8, 0.0, 12)), (PY - 3.8, _oct(ZA, 2.0 * RC + 0.8, 2.0 * RC + 0.8, 0.0, 12))], "steel.plate", "casing_rim")
            b.loft([(PY + 9.2, _oct(ZA, 2.0 * RC + 0.8, 2.0 * RC + 0.8, 0.0, 12)), (PY + 10.6, _oct(ZA, 2.0 * RC + 0.8, 2.0 * RC + 0.8, 0.0, 12))], "steel.plate", "casing_rim")
            b.loft([(PY + 0.5, _oct(ZA, 2.0 * RC + 0.4, 2.0 * RC + 0.4, 0.0, 12)), (PY + 4.5, _oct(ZA, 2.0 * RC + 0.4, 2.0 * RC + 0.4, 0.0, 12))], "livery.livery2", "drum_band")
            # A window over each chamber in the band, banked dark, burning as the drum spins up,
            # so the spin reads as a light running round it.
            _cottonmouth_boxes(b, [((RC * 0.97 * math.cos(a), PY + 2.5, ZA + RC * 0.97 * math.sin(a)), ((-math.sin(a), 0.0, math.cos(a)), (0.0, 1.0, 0.0), (math.cos(a), 0.0, math.sin(a))), (1.6, 1.3, 0.5))
                                   for a in angles], "amber.heat", "chamber_window")
            # Its back: a hub and six chamber caps, every lamp banked, burning with the strip (Ryan,
            # 2 November: the lit index lamp went, "that's part of the flash").
            b.prism("y", 0.0, yb - 0.6, ZA, 3.0, 1.2, "steel.dark", 8, "drum_hub", phase=math.pi / 8)
            _cottonmouth_prisms(b, [("y", (cr * math.cos(a), yb - 0.3, ZA + cr * math.sin(a)), 2.3, 0.6, 8, math.pi / 8) for a in angles], "steel.plate", "chamber_cap")
            _cottonmouth_prisms(b, [("y", (cr * math.cos(a), yb - 0.75, ZA + cr * math.sin(a)), 1.5, 0.4, 8, math.pi / 8) for a in angles], "amber.heat", "chamber_lamp")
            # The barrels out of the casing's face, through two collars, to bored muzzles, each
            # bore's floor dark and never lit (a shot lights the top mouth, below).
            for a in angles:
                bx, bz = RR * math.cos(a), ZA + RR * math.sin(a)
                b.prism("y", bx, (y0 + y1) / 2.0, bz, RB, y1 - y0, "steel.dark", 8, "barrel", phase=math.pi / 8)
                _cottonmouth_ring(b, bx, bz, y1, ym, RB + 0.2, RB - 1.0, 8, "steel.dark", "muzzle", phase=math.pi / 8)
            _cottonmouth_prisms(b, [("y", (RR * math.cos(a), ym - 1.8, ZA + RR * math.sin(a)), RB - 0.95, 0.4, 8, math.pi / 8) for a in angles], "bore.dark", "bore_floor")
            b.prism("y", 0.0, (y0 + ym) / 2.0, ZA, 2.3, ym - y0, "steel.dark", 8, "spindle", phase=math.pi / 8)
            b.prism("y", 0.0, ym, ZA, 3.0, 1.4, "steel.plate", 8, "spindle_cap", phase=math.pi / 8)
            for yc in (y0 + 3.6, y1 + 1.6):
                b.prism("y", 0.0, yc, ZA, RR + RB + 0.5, 2.2, "steel.plate", 12, "collar", phase=math.pi / 12)
        # The shot's light, fixed at the top chamber on the elevation (never the rolling drum):
        # the top mouth rests hidden in the collar's solid and the top lamp inside the casing;
        # while the drum stands parked for a shot each slides into the top chamber (forward into
        # its bore, in front of the bore's own floor; back out through its cap, behind its lamp),
        # flashes, and slides home, so neither shows in a seam between barrels as the drum turns.
        with b.joint("top_mouth", (0.0, y1 + 1.6, ZA + RR), slide=(0.0, 1.0, 0.0)):
            _cottonmouth_prisms(b, [("y", (0.0, y1 + 1.6, ZA + RR), RB - 1.15, 0.4, 8, math.pi / 8)], "amber.heat", "top_mouth_glow")
        with b.joint("top_lamp", (0.0, yb + 0.4, ZA + cr), slide=(0.0, -1.0, 0.0)):
            _cottonmouth_prisms(b, [("y", (0.0, yb + 0.4, ZA + cr), 2.1, 0.4, 8, math.pi / 8)], "amber.heat", "top_lamp_glow")   # wider than the lamp it lights, inside the cap it passes through
        # The four mounts, hidden inside the casing (nothing drawn there, stock or fitted), on
        # the elevation so a shot kicks the drum up; in the die's order.
        for n, (dx, dz), carries in ((1, (-4.2, 4.2), "ankle_mortar"), (2, (4.2, 4.2), "twin_autoguns"), (3, (-4.2, -4.2), "halo_projector"), (4, (4.2, -4.2), "")):
            b.pin("hp_%d" % n, (dx, PY + 2.0, ZA + dz), scale=0.5, carries=carries, hidden=True)

    # The stern: two ducted fans side by side on a fairing, each on a pylon, its lip
    # hazard-striped, a motor behind the rotor with a lit ring at its back, five blades with
    # yellow tips turning against its twin's; two rudder vanes behind each duct.
    FX, FY, FZ, FR, FRI = 11.6, -29.0, 25.4, 9.0, 8.0
    b.box(-3.0, 3.0, FY - 2.4, FY + 2.4, DECK, FZ + 4.6, "steel.panel", "fan_fairing")
    rings = []
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        fx = s * FX
        _cottonmouth_ring(b, fx, FZ, FY - 2.6, FY + 2.6, FR, FRI, 16, "steel.panel", "duct", phase=math.pi / 16)
        _cottonmouth_ring(b, fx, FZ, FY - 2.5, FY + 2.5, FRI + 0.05, FRI - 0.25, 16, "steel.dark", "duct_liner", phase=math.pi / 16)
        _cottonmouth_ring(b, fx, FZ, FY - 3.1, FY - 2.6, FR + 0.3, FRI - 0.2, 16, "steel.hazard", "duct_lip", phase=math.pi / 16)
        _cottonmouth_ring(b, fx, FZ, FY + 2.6, FY + 3.1, FR + 0.3, FRI - 0.2, 16, "steel.plate", "duct_lip_front", phase=math.pi / 16)
        b.box(fx - 3.0, fx + 3.0, FY - 2.2, FY + 2.2, DECK, FZ - FR + 0.8, "steel.panel", "duct_pylon")
        b.prism("y", fx, FY - 1.2, FZ, 2.6, 3.0, "steel.dark", 8, "fan_motor", phase=math.pi / 8)
        rings.append(("y", (fx, FY - 2.9, FZ), 2.2, 0.5, 8, math.pi / 8))
        for k in range(3):
            a = math.pi / 2.0 + k * 2.0 * math.pi / 3.0
            _beam(b, (fx + 2.2 * math.cos(a), FY - 1.6, FZ + 2.2 * math.sin(a)), (fx + (FRI + 0.2) * math.cos(a), FY - 1.6, FZ + (FRI + 0.2) * math.sin(a)),
                  _sq(0.9, 0.9), _sq(0.9, 0.9), "steel.dark", "stator")
        with b.joint("fan_" + side, (fx, FY + 1.4, FZ), axis="roll"):
            b.prism("y", fx, FY + 1.4, FZ, 1.8, 2.6, "steel.plate", 8, "fan_hub", phase=math.pi / 8)
            b.loft([(FY + 2.7, _oct(FZ, 3.2, 3.2, fx, 8)), (FY + 4.0, _oct(FZ, 0.6, 0.6, fx, 8))], "steel.plate", "spinner")
            for k in range(5):
                a = k * 2.0 * math.pi / 5.0 + (0.3 if s > 0 else 0.0)
                _cottonmouth_blade(b, (fx, FY + 1.4, FZ), a, 1.6, FRI - 1.9, 3.2, s * math.radians(28.0), 0.5, "steel.dark", "fan_blade")
                _cottonmouth_blade(b, (fx, FY + 1.4, FZ), a, FRI - 1.9, FRI - 0.6, 2.6, s * math.radians(28.0), 0.5, "steel.hazard", "blade_tip")
        for k, dx in enumerate((-4.4, 4.4)):
            rx, ry = fx + dx, FY - 3.8
            b.box(rx - 0.6, rx + 0.6, ry - 0.2, FY - 2.6, FZ + 6.6, FZ + 7.6, "steel.dark", "rudder_bracket")
            b.box(rx - 0.6, rx + 0.6, ry - 0.2, FY - 2.6, FZ - 7.8, FZ - 6.8, "steel.dark", "rudder_bracket")
            with b.joint("rudder_%s%d" % (side, k + 1), (rx, ry, FZ), axis="yaw", limits=(-30.0, 30.0)):
                b.prism("z", rx, ry, FZ, 0.6, 14.4, "steel.dark", 6, "rudder_post")
                b.loft([(ry, rect(rx, 0.9, FZ - 6.8, FZ + 6.4)), (ry - 5.0, rect(rx, 0.6, FZ - 6.0, FZ + 5.6))], "livery.livery2", "rudder")
    _cottonmouth_prisms(b, rings, "amber.heat", "fan_ring")

    # Idle acts (four, loud, never in step; a light hovercraft's servos, b.move). Degrees and
    # seconds; a key is (t, value) on the joint's own axis; a body key is (t, dx, dy, dz) or
    # (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k), k the light added over rest.
    rudders = ("rudder_l1", "rudder_l2", "rudder_r1", "rudder_r2")
    HEAT = 196.0   # the heat tile's light at its height: near black at rest, #ff7800 here under the phone's eased light (the Polar Bear's vents)
    STRIP = ["chamber_window", "chamber_lamp"]   # burning whenever the drum turns on past its idle, every chamber
    FLASH = ["top_mouth_glow", "top_lamp_glow"]  # the top chamber, front and back, lit for a shot alone
    CHAMBERS = 1                                 # chambers the drum turns on between its test shots (Ryan, 3 November: "Ranging can just move one barrel at a time during its animation. Shots moving two makes sense": a weapon's real shot, the hookup's, turns two)
    MOUTH_IN, LAMP_OUT = 3.9, 1.9                # how far the top mouth and lamp slide out of hiding
    SLICE = 1.12                                 # seconds a shot takes, its turn included

    def shot(t0, turned, at, pose):
        """One shot, self-contained from t0 to t0 + SLICE (so the hookup of every weapon's fire can
        cut it): the drum turns CHAMBERS on in 0.36 s, the strip burning as it turns; parked, the top
        mouth and lamp slide out of hiding into the top chamber; at t0 + 0.58 the shot flashes them,
        kicks the drum up four degrees and shoves the hull back on its cushion; they slide home by
        t0 + 1.08. `turned` is the drum's turn so far in the act, `at` its elevation, `pose` the
        body's (dx, dy, dz, yaw, pitch, roll) held through it. Returns the keys by track."""
        dx, dy, dz, yaw, pitch, roll = pose
        out_key = lambda t, d: (t, 0.0, 0.0, 0.0, 0.0, d, 0.0)
        return {"drum": [(t0, turned), (t0 + 0.36, turned + CHAMBERS * 60.0)],
                "elev_drum": [(t0 + 0.58, at), (t0 + 0.64, at + 4.0), (t0 + 1.06, at)],
                "top_mouth": [out_key(t0 + 0.38, 0.0), out_key(t0 + 0.46, MOUTH_IN), out_key(t0 + 1.0, MOUTH_IN), out_key(t0 + 1.08, 0.0)],
                "top_lamp": [out_key(t0 + 0.38, 0.0), out_key(t0 + 0.46, -LAMP_OUT), out_key(t0 + 1.0, -LAMP_OUT), out_key(t0 + 1.08, 0.0)],
                "strip": [(t0, 0.0), (t0 + 0.06, HEAT), (t0 + 0.36, HEAT), (t0 + 0.56, 0.0)],
                "flash": [(t0 + 0.58, 0.0), (t0 + 0.62, HEAT), (t0 + 0.86, 0.3 * HEAT), (t0 + 0.98, 0.0)],
                "body": [(t0 + 0.58, dx, dy, dz, yaw, pitch, roll), (t0 + 0.70, dx, dy - 2.2, dz - 0.3, yaw, pitch + 1.4, roll), (t0 + 1.06, dx, dy, dz, yaw, pitch, roll)]}
    # Spin-up: the drum, locked off its idle turn and parked on a chamber, lifts a touch and spins
    # up through four whole turns, the strip burning as it whirls (no mouth: only a shot lights
    # one), the hull shuddering on its cushion; it spins down onto a chamber and settles.
    b.act("spin_up", 6.6, {
        "elev_drum": [(0.4, 0.0), (1.3, 12.0), (5.2, 12.0), (6.2, 0.0)],
        "drum": [(0.8, 0.0), (1.5, 40.0), (2.2, 210.0), (2.9, 560.0), (3.6, 950.0), (4.3, 1260.0), (5.0, 1410.0), (5.6, 1440.0), (6.6, 1440.0)],
    }, body=[(2.0, 0.0, 0.0, 0.0), (2.3, 0.0, -0.4, 0.3, 0.0, 0.6, 0.8), (2.6, 0.0, -0.6, 0.0, 0.0, 0.8, -0.8), (2.9, 0.0, -0.8, 0.3, 0.0, 1.0, 0.9),
             (3.2, 0.0, -0.8, 0.0, 0.0, 1.0, -0.9), (3.5, 0.0, -0.8, 0.3, 0.0, 1.0, 0.9), (3.8, 0.0, -0.8, 0.0, 0.0, 1.0, -0.9), (4.1, 0.0, -0.6, 0.3, 0.0, 0.8, 0.7),
             (4.4, 0.0, -0.4, 0.0, 0.0, 0.6, -0.5), (5.0, 0.0, 0.0, 0.0)], heft=0.08,
       glow=[(STRIP, [(0.8, 0.0), (2.2, 0.25 * HEAT), (3.0, HEAT), (4.6, HEAT), (5.6, 0.2 * HEAT), (6.3, 0.0)]),
             (["sight"], [(0.4, 0.0), (0.8, 6.0), (5.6, 6.0), (6.2, 0.0)])], locks=["drum"])
    # The ranging: the drum locked off its idle turn and parked on a chamber, up for the back
    # rank and two shots punched out; down for the front rank, three shots sprayed along the row
    # as the hull yaws across it on its rudders between them; and home, the drum's idle turn
    # taking up again from the chamber it stands on. Each shot is a slice of its own (shot()).
    SHOTS = [(1.5, 26.0, 0.0), (2.7, 26.0, 0.0), (4.75, 6.0, 12.0), (6.4, 6.0, 0.0), (8.05, 6.0, -12.0)]   # (t0, elevation, yaw)
    tracks = {"elev_drum": [(0.4, 0.0), (1.4, 26.0)], "drum": [], "top_mouth": [], "top_lamp": []}
    body, strip, flash = [], [], []
    for n, (t0, at, yaw) in enumerate(SHOTS):
        if n == 2:   # down onto the front rank and round to the row's first foe
            tracks["elev_drum"] += [(3.85, 26.0), (4.6, 6.0)]
            body += [(3.85, 0.0, 0.0, 0.0), (4.6, 0.0, 0.0, 0.0, yaw, 0.0, 0.0)]
        elif n > 2:   # round to the row's next foe
            body += [(SHOTS[n - 1][0] + SLICE + 0.03, 0.0, 0.0, 0.0, SHOTS[n - 1][2], 0.0, 0.0), (t0 - 0.05, 0.0, 0.0, 0.0, yaw, 0.0, 0.0)]
        k = shot(t0, CHAMBERS * 60.0 * n, at, (0.0, 0.0, 0.0, yaw, 0.0, 0.0))   # each shot opens where the last one parked, so the drum stands still through its flash
        for jn in ("elev_drum", "drum", "top_mouth", "top_lamp"):
            tracks[jn] += k[jn]
        body += k["body"]
        strip += k["strip"]
        flash += k["flash"]
    end = SHOTS[-1][0] + SLICE
    tracks["elev_drum"] += [(end + 0.05, 6.0), (end + 0.8, 0.0)]
    tracks["drum"] += [(end + 1.0, CHAMBERS * 60.0 * len(SHOTS))]   # held: whole chambers on, where the idle turn takes up again
    body += [(end + 0.05, 0.0, 0.0, 0.0, SHOTS[-1][2], 0.0, 0.0), (end + 0.8, 0.0, 0.0, 0.0)]
    # The rudders lay each yaw, held a beat before they come back.
    lay = lambda t, deg: [(t, 0.0), (t + 0.15, deg), (t + 0.28, deg), (t + 0.45, 0.0)]   # done before the next shot's slice opens
    tracks.update({r: lay(3.95, -18.0) + lay(SHOTS[2][0] + SLICE + 0.03, 16.0) + lay(SHOTS[3][0] + SLICE + 0.03, 16.0) + lay(end + 0.05, -16.0) for r in rudders})
    b.act("ranging", end + 1.0, tracks, body=body, heft=0.08, locks=["drum"],
          glow=[(STRIP, strip), (FLASH, flash), (["sight"], [(0.4, 0.0), (0.9, 6.0), (end, 6.0), (end + 0.6, 0.0)])])
    # Coming about: the rudders go hard over and the hull swings round on its cushion to its
    # left, tipping out as it turns, the searchlight sweeping the water as it holds; then hard
    # over the other way and back round to its station, settling with a heave.
    b.act("come_about", 8.0, {
        **{r: [(0.4, 0.0), (0.9, -28.0), (2.0, -28.0), (2.6, 0.0), (4.6, 0.0), (5.1, 28.0), (6.2, 28.0), (6.8, 0.0)] for r in rudders},
        "sensor": [(2.6, 0.0), (3.4, 50.0), (3.9, 50.0), (4.7, -30.0), (5.2, -30.0), (6.2, 0.0)],
        "elev_drum": [(1.0, 0.0), (2.0, 6.0), (5.6, 6.0), (6.6, 0.0)],
    }, body=[(0.6, 0.0, 0.0, 0.0), (1.6, 0.0, 0.0, 0.4, 24.0, 0.0, 2.6), (2.6, 0.0, 0.0, 0.6, 46.0, 0.0, 0.8), (3.0, 0.0, 0.0, 0.5, 48.0, 0.0, 0.0),
             (4.8, 0.0, 0.0, 0.5, 48.0, 0.0, 0.0), (5.8, 0.0, 0.0, 0.4, 22.0, 0.0, -2.6), (6.8, 0.0, 0.0, 0.2, 0.0, 0.0, -0.6), (7.2, 0.0, 0.0, -0.6, 0.0, 0.6, 0.0), (8.0, 0.0, 0.0, 0.0)],
       glow=[(["searchlight", "lamp"], [(2.4, 0.0), (2.8, 8.0), (5.4, 8.0), (6.0, 0.0)])])
    # The surge: the rudders are tried hard over each way, then the fans roar, their rings
    # burning, and it surges ahead on its cushion with its bow lifting, brakes nose down with
    # the drum swinging up on its trunnions, and drifts back onto its station.
    b.act("surge", 7.2, {
        **{r: [(0.4, 0.0), (0.9, 26.0), (1.4, 26.0), (2.1, -26.0), (2.6, -26.0), (3.1, 0.0)] for r in rudders},
        "elev_drum": [(4.4, 0.0), (4.9, 9.0), (5.4, 9.0), (6.2, 0.0)],
    }, body=[(3.0, 0.0, 0.0, 0.0), (3.9, 0.0, 6.0, 0.8, 0.0, 4.0, 0.0), (4.4, 0.0, 9.0, 0.6, 0.0, 2.0, 0.0), (4.9, 0.0, 9.6, -0.5, 0.0, -2.6, 0.0),
             (5.4, 0.0, 9.4, 0.0, 0.0, -0.6, 0.0), (7.2, 0.0, 0.0, 0.0)],
       glow=[(["fan_ring"], [(3.0, 0.0), (3.4, HEAT), (4.4, HEAT), (5.0, 0.3 * HEAT), (5.6, 0.0)]),
             (["tail_light"], [(4.4, 0.0), (4.6, 6.0), (6.4, 6.0), (6.9, 0.0)])])
    # Movement: the fans turn faster and their rings burn under way, the rudders steer into the
    # turns (trailing edges toward the turn), the bow lifts on the cushion and pulling away; it
    # drifts through its corners, never banking (a hovercraft keeps flat). The drum turns
    # slowly always, a turn in ten seconds.
    b.gait(steer={r: -16.0 for r in rudders}, body_hold=(0.0, 0.0, 0.6, 0.0, 2.5, 0.0), glow={"parts": ["fan_ring"], "k": 0.7 * HEAT}, rock=3.0)
    b.spin("fan_l", 360.0, 1260.0)
    b.spin("fan_r", -360.0, -1260.0)
    b.spin("drum", 36.0, step=60.0)   # a chamber a step: an act that turns it on parks it on one (the ranging, the spin-up)
    b.move(slide=0.35, bank=0.0, accel=0.7, heft=0.13, oversteer=1.3)

cottonmouth.maker = "wainwright_sutler"


def funnel_web(b):
    """Wainwright & Sutler "Funnel-web" (Pattern 19 Ambush Walker): the roster's tank-buster,
    a four-legged walker that does spider-like things (Ryan, 14 and 17 October: a little
    spider takes down a big thing with venom). Four cuts on 19 October, each on Ryan's notes:
    a war machine, not a mechanical spider (the first: the legs under the mass, more leg to
    body, geometry of its own for the gear, practical feet); not the BattleTech Scorpion's quad
    (the second; the note that called it the larger boiler spider's likely shape was logged
    wrong, Ryan, 28 October: the Scorpion stands tall, and the Whip Scorpion walks on six or
    eight legs) but the Revenant's and the Doom
    Arachnotron's legs under a turret, sides as well as a top and a front for the weapons, a
    diminutive little death machine; the legs going down, up and down so the thighs clear the
    body (the third; leggy is fine); and this, the fourth: the body in W&S's military camp,
    the Prairie Dog's and the gunship's, not the Clydesdale's and the Dingo's funky steam
    (no boiler, no stack, no hazard stripes), more aggressive; the side guns pitching only,
    since the torso twist aims them; nothing hanging like a proboscis (the chin gun lay
    pitched down and read as the web-shooter); and the upper legs in the walk beside the
    solver, the Ammit's way, so it walks creepy. So: a compact angular turret of a body on a
    hub, turning and nodding on it (the head joint: the whole body is the turret), its lower
    hull dark, its upper hull a wedge-browed armoured head with two slit eyes in a dark visor
    band, appliqué plates in the livery on its flanks, an exhaust grille and a whip antenna at
    its tail. The Maxigun a bow gun in the snout, level, on a drop joint for the bite (hp_1);
    an armoured pod on each flank with its gun on an elevation, the Howitzer's on the left
    (hp_2), the Twin Autoguns' on the right (hp_3); the deflector's dish a low crest on the
    roof (hp_4); the Web Bomb (fixed, no pin) a box launcher of four tubes on the roof's
    rear, pitched up on its own elevation, the tubes' floors lit. Four long legs from coxa
    joints at the hub's corners, each a strut down and out to a low hip, a thigh up to a knee
    wide and high, a shin down to a flat foot with a toe plate. The rig, the acts and the gait
    are for Ryan to judge running. His fifth notes, the same day: the fore feet's two short
    steps to the hind feet's stride hot-stepped, far too busy, and the head's turn toward each
    foot looked weird, both cut (the feet kept down, the coxae kept lifting each leg through its
    swing); the body is great; two static forward guns in place of the single centred one, the
    jaw reworked to carry them, which leaves a single mount on top, and the web launcher one of
    the side guns. So the stations now: the Maxigun (hp_1) and the Twin Autoguns (hp_3) static
    in the jaw's two mantlets, the Howitzer (hp_2) alone on the roof on its elevation, the Web
    Bomb's four-tube launcher in the left pod on its elevation, the deflector's dish (hp_4) on
    the right pod. His sixth to ninth notes revised the cut part by part (the notes sit at
    each part: the guns pulled in, the fins, the top mount, the planted pivot, the antenna's
    base); his tenth, 20 October: the eighth's fins were the shape and size he liked, it was
    only their base that wanted squaring off, so they are back at that size on a level base;
    and the scan's first turn is quick. His eleventh, the same day: the antenna a little
    inboard, clear of the fin, and the model is good to go. Since the stock pass (22 October)
    its fourth stock piece is a Canopy, which shows nowhere, so the right pod's mount (hp_4)
    is bare (Ryan's go, 28 October)."""
    # The hub: the legs' pelvis under the body, a dark block. Each leg goes down, up and down
    # (the third notes: the thighs had no clearance from the body, and every reference resolves
    # it so): a strut drops from a coxa joint at the hub's corner, down and out, to a low hip
    # hinge clear of the body's flank; the thigh rises from it to a knee standing wide and
    # high; the shin falls to the foot. The walk solver drives the thigh and the shin from the
    # hip; the coxa is the walk's own (below). Nothing hangs below z = 0, the ground.
    b.box(-12.0, 12.0, -12.0, 12.0, 30.0, 39.5, "steel.dark", "hub")
    legs, roots = {}, {}
    for yh, fa in ((10.0, "f"), (-10.0, "h")):
        f = 1.0 if fa == "f" else -1.0
        for s in (-1.0, 1.0):
            leg = fa + ("l" if s < 0 else "r")
            root = (s * 10.0, yh, 32.0)
            hip = (s * 22.0, yh + f * 4.0, 22.0)   # the strut near plumb, so a turn of the coxa rows the hip fore and aft (the sixth notes)
            knee = (s * 38.0, yh + f * 26.0, 56.0)
            ankle = (s * 46.0, yh + f * 34.0, 7.0)
            legs[leg], roots[leg] = (hip, knee, ankle), root
            b.prism("x", root[0], root[1], root[2], 5.0, 6.0, "steel.dark", 6, "coxa_pin")
            # A yaw at each root (the ninth notes: the shuffle slid), so a leg's plane can turn
            # about up and a planted foot stays planted while the body pivots (_pivot); at
            # rest through the walk.
            yawj = b.joint("yaw_%s" % leg, root, axis="yaw", limits=(-30.0, 30.0))
            yawj.__enter__()
            with b.joint("coxa_%s" % leg, root, limits=(-25.0, 25.0)):
                _beam(b, root, hip, _sq(9.0, 10.0), _sq(8.0, 9.0), "steel.dark", "strut")
                b.prism("x", hip[0], hip[1], hip[2], 5.5, 10.5, "steel.dark", 6, "hip_pin")
                # Hip, knee and ankle on every leg, the ankle keeping the foot flat through a
                # stride; the limits hold what the gait and the acts below ask, with a margin.
                with b.joint("hip_%s" % leg, hip, limits=(-50.0, 50.0)):
                    _beam(b, hip, knee, _sq(10.0, 11.0), _sq(8.5, 9.5), "steel.plate", "thigh")
                    b.prism("x", knee[0], knee[1], knee[2], 6.4, 11.5, "steel.dark", 6, "knee")   # a hinge block big enough to own the corner
                    with b.joint("knee_%s" % leg, knee, limits=(-60.0, 60.0)):
                        _beam(b, knee, ankle, _sq(8.0, 9.0), _sq(7.0, 8.0), "steel.panel", "shin")
                        b.prism("x", ankle[0], ankle[1], ankle[2], 3.8, 9.0, "steel.dark", 6, "ankle_pin")
                        with b.joint("ankle_%s" % leg, ankle, limits=(-50.0, 50.0)):
                            b.box(ankle[0] - 6.0, ankle[0] + 6.0, ankle[1] - 7.0, ankle[1] + 7.0, 2.0, 7.5, "steel.dark", "foot")
                            b.box(ankle[0] - 7.5, ankle[0] + 7.5, ankle[1] - 8.5, ankle[1] + 8.5, 0.0, 2.5, "steel.dark", "sole")
                            b.box(ankle[0] - 6.5, ankle[0] + 6.5, ankle[1] + min(f * 8.5, f * 11.5), ankle[1] + max(f * 8.5, f * 11.5), 0.0, 4.0, "steel.plate", "toe_plate")
            yawj.__exit__(None, None, None)
    # The body, a turret on the hub that turns and nods (the joint named head yaws): a dark
    # lower hull running out into a wide flat jaw under the brow, an armoured upper hull over
    # it with a wedge brow, its face a dark visor band with two slit eyes (lamps, so they burn:
    # the rule, lean hotter), a brim over them; appliqué plates in the livery on the flanks, an
    # exhaust grille and two stubs at the tail, a whip antenna off the left rear corner.
    with b.joint("head", (0.0, 0.0, 39.5), limits={"yaw": (-40.0, 40.0), "pitch": (-20.0, 15.0)}):   # the pitch wide (the eighth notes): it looks up and down with its legs and its torso
        b.loft([(-22.0, _case(30.0, 39.0, 47.0, 4.0)), (10.0, _case(32.0, 39.0, 47.0, 4.0)), (22.0, _case(30.0, 40.0, 50.0, 3.0)), (30.0, _case(28.0, 42.0, 52.0, 3.0))], "steel.dark", "lower_hull")
        b.loft([(-24.0, _case(34.0, 46.0, 64.0, 8.0)), (-4.0, _case(38.0, 44.0, 68.0, 8.0)), (14.0, _case(38.0, 45.0, 68.0, 8.0)), (22.0, _case(32.0, 47.0, 64.0, 6.0)), (26.0, _case(28.0, 49.0, 61.0, 4.0))], "steel.plate", "upper_hull")
        b.box(-12.0, 12.0, 25.5, 27.5, 55.0, 60.5, "steel.dark", "visor_band")
        for x0, x1 in ((-11.5, -3.0), (3.0, 11.5)):
            b.box(x0, x1, 27.0, 28.4, 56.6, 59.8, "amber.light", "lamp")   # wide and proud of the band: a phone must read the eyes
        b.box(-13.0, 13.0, 24.0, 29.0, 60.5, 62.5, "steel.plate", "brim")
        # The fins (the eighth notes: the flank plates stood out and said nothing, so they are
        # embraced): a raked blade in the livery off each flank's rear, rising up and behind,
        # in the spirit of a samurai's banner but iron, a little flair on a utilitarian maker;
        # each on a dark bracket.
        # The blade's bottom squared off (the ninth notes, and the tenth: the shape and size
        # of the eighth stay; it was the base, cut square to the rake, that read as a turned
        # bar): a plate in the flank's plane with the eighth's edges, tip and rake, its base
        # level and sunk in the bracket, so the fin rises out of the bracket and the pod.
        for s in (-1.0, 1.0):
            b.box(min(s * 17.0, s * 21.0), max(s * 17.0, s * 21.0), -19.5, -8.0, 50.0, 56.0, "steel.dark", "fin_bracket")
            outline = [(-2.5, 52.0), (-18.7, 52.0), (-30.1, 82.4), (-23.9, 85.6)]   # (y, z): base level, the edges raked 27 degrees, the tip cut square to the rake
            _rings(b, [[(s * 19.7, y, z) for y, z in outline], [(s * 21.3, y, z) for y, z in outline]], "livery.livery2", "fin")
        b.box(-9.0, 9.0, -25.3, -24.0, 49.0, 58.0, "steel.vent", "exhaust_grille")
        for s in (-1.0, 1.0):
            b.prism("y", s * 13.0, -26.5, 53.0, 2.2, 5.0, "steel.dark", 6, "exhaust_stub")
        b.prism("z", -10.5, -20.0, 75.0, 1.2, 16.0, "steel.dark", 6, "antenna")   # inboard of the fin by a clear margin (the eleventh notes: it sat against it)
        b.box(-12.0, -9.0, -21.5, -18.5, 56.0, 67.5, "steel.dark", "antenna_base")   # run down into the hull's chamfer (the ninth notes: it floated)
        # The jaw's two static bow guns (the fifth notes): a mantlet each side of the jaw's
        # flat face, no joint, the Maxigun's on the left (hp_1), the Twin Autoguns' on the
        # right (hp_3); the torso twist and the legs aim them. Pulled back in (the seventh
        # notes): the jaw six shorter and the mantlets near flush with its face, the guns'
        # receivers sunk into them.
        for s, k, shape in ((-1.0, 1, "barrel"), (1.0, 3, "twin_barrel")):
            b.box(min(s * 3.5, s * 12.5), max(s * 3.5, s * 12.5), 28.0, 31.5, 44.0, 51.0, "steel.dark", "mantlet")
            b.stock("hp_%d" % k, (s * 8.0, 31.5, 47.5), shape, scale=0.75, carries="maxigun" if k == 1 else "twin_autoguns")
        # The roof's one mount (hp_2): the howitzer on a low pedestal aft of the pods (the
        # seventh notes: not in line with the side mounts), on its elevation, the torso twist
        # its traverse.
        b.box(-5.0, 5.0, -19.0, -9.0, 63.0, 68.0, "steel.dark", "top_mount")   # sunk into the roof (the eighth notes: a gap showed)
        with b.joint("elev_top", (0.0, -14.0, 68.0), limits=(-8.0, 30.0)):
            b.stock("hp_2", (0.0, -12.0, 69.0), "barrel", forward=(0.0, 0.866, 0.5), scale=0.9, carries="howitzer")
        # The pods: an armoured box on each flank, a livery panel on its outer face, a sight
        # on its front, what it carries on an elevation and never a traverse (the fourth
        # notes: the torso twist aims them). The left pod carries the Web Bomb (fixed, no
        # pin): a box launcher of four tubes out of its front, pitched up a little, each
        # tube's floor lit, so it glows when it is about to lob. The right pod's mount is bare
        # (hp_4: the stock's Canopy shows nowhere; the deflector's dish there went with the old
        # stock, Ryan's go of 28 October).
        for s in (-1.0, 1.0):
            px = s * 23.5
            b.box(min(s * 18.0, s * 29.0), max(s * 18.0, s * 29.0), -10.0, 8.0, 50.0, 64.0, "steel.plate", "pod")
            b.box(min(s * 29.0, s * 29.2), max(s * 29.0, s * 29.2), -8.0, 6.0, 52.0, 62.0, "livery.livery2", "pod_panel")   # flush, a painted panel (the eighth notes)
            b.box(px - 1.5, px + 1.5, 8.0, 9.0, 61.5, 63.5, "amber.light", "sight")
            if s < 0:
                D = Vector((0.0, math.cos(math.radians(10.0)), math.sin(math.radians(10.0))))
                UP = Vector((0.0, -D.z, D.y))
                P0 = Vector((px, 8.0, 56.5))
                with b.joint("elev_l", (px, 4.0, 56.5), limits=(-6.0, 25.0)):
                    _beam(b, tuple(P0 - D * 3.0), tuple(P0 + D * 9.0), _sq(9.5, 8.5), _sq(9.5, 8.5), "steel.plate", "web_rack")
                    for ux in (-2.6, 2.6):
                        for uz in (-2.3, 2.3):
                            off = Vector((ux, 0.0, 0.0)) + UP * uz
                            _tube(b, tuple(P0 + off), tuple(P0 + off + D * 9.3), 2.1, 1.65, 6, "steel.dark", "web_tube", floor_material="amber.light", floor_depth=7.0)
            else:
                with b.joint("elev_r", (px, 4.0, 56.5), limits=(-10.0, 30.0)):
                    b.pad("hp_4", (s * 25.5, 8.0, 56.5), scale=0.85, size=(6.0, 1.5))

    # Idle acts (the builder's rules: curves a part runs on through, held poses that drift,
    # every gun turning slowly and not far with a pause before it turns back). Degrees and
    # seconds; a key is (t, value) on the joint's own axis or (t, pitch, yaw, roll); a body
    # key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k), k
    # the light added over rest. The feet stay planted while the hub moves (_planted); the
    # coxae rest through the acts, since the solver plants from the hips. The eighth notes:
    # the guns clipped the fore legs' shins when the body twisted past twenty-five degrees,
    # so a twist is the head's twenty and a pivot of the legs for the rest, a little
    # predatory skittering (the ninth notes: it slid, since the feet were not planted; now
    # _pivot turns the body in quick steps with every foot not stepping planted, each leg's
    # yaw joint holding its plane on its foot); and the vertical range is this walker's
    # own, its legs and its torso mount looking up and down, so it rears, sinks and coils
    # through the acts.
    limb = lambda leg: {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg]}
    limbs = {leg: limb(leg) for leg in ("fl", "fr", "hl", "hr")}

    # The ambush: it sinks low and coils, the eyes burning, the whole body tipped down at
    # what it watches, holds, and strikes, up and forward; then it draws back up. The strike
    # on a sharp servo.
    tracks, body = _planted(list(limbs.values()),
                            [(0.5, 0.0, 0.0, 0.0), (2.0, 0.0, -10.0, 3.0), (3.6, 0.0, -11.0, 3.5), (3.9, 6.0, -3.0, -3.0), (4.3, 6.0, -3.5, -2.5), (5.6, 0.0, 0.0, 0.0)])
    tracks["head"] = [(0.5, 0.0, 0.0, 0.0), (2.0, -16.0, 0.0, 0.0), (3.6, -18.0, 0.0, 0.0), (3.9, 9.0, 0.0, 0.0), (4.3, 7.0, 0.0, 0.0), (5.6, 0.0, 0.0, 0.0)]
    b.act("stalk", 6.2, tracks, body=body, heft=0.08,
          glow=[(["lamp"], [(0.8, 0.0), (2.0, 5.0), (3.8, 7.0), (4.9, 0.0)])])
    # The scan: it rears up on its legs looking up, pivots round to the right in quick
    # steps and stares, sinks low looking down while it pivots round to the left and
    # stares, and comes back. Every foot not stepping stays planted through the turn
    # (_pivot, the ninth notes: the shuffle slid).
    A, B = ("fl", "hr", "fr", "hl"), ("hl", "fr", "hr", "fl")
    REAR, LOW, REST = (0.0, 8.0, 3.0), (0.0, -8.0, -3.0), (0.0, 0.0, 0.0)
    # The first turn in under a second (the tenth notes: it was the slow one, seven degrees
    # a second against the swing's fifteen), the steps quick enough to want thirty keys a second.
    tracks, body = _pivot(limbs, roots,
                          yaw=[(0.5, 0.0), (1.7, 0.0), (2.6, 12.0), (3.9, 12.0), (5.5, -12.0), (6.7, -12.0), (8.1, 0.0), (8.6, 0.0)],
                          pose=[(0.5, REST), (1.6, REAR), (3.8, REAR), (5.5, LOW), (6.6, LOW), (8.2, REST)],
                          groups=[(1.7, 2.6, A), (3.9, 5.5, B), (6.7, 8.1, A)], until=8.6, hz=30.0)
    tracks["head"] = [(0.5, 0.0, 0.0, 0.0), (1.6, 12.0, 0.0, 0.0), (2.6, 12.0, 20.0, 0.0), (3.8, 13.0, 22.0, 0.0), (5.5, -14.0, -20.0, 0.0), (6.6, -15.0, -22.0, 0.0), (8.2, 0.0, 0.0, 0.0)]
    b.act("scan", 9.2, tracks, body=body, ease="linear",
          glow=[(["lamp"], [(1.0, 0.0), (1.8, 6.0), (7.8, 6.0), (8.6, 0.0)])])
    # Sighting in: it pivots and twists to bring the launcher to bear as it rises lit,
    # holds, then pivots and twists the other way, rearing as the roof gun elevates.
    tracks, body = _pivot(limbs, roots,
                          yaw=[(0.5, 0.0), (0.6, 0.0), (2.0, 8.0), (3.6, 8.0), (5.2, -8.0), (6.5, -8.0), (7.9, 0.0), (8.2, 0.0)],
                          pose=[(0.5, REST), (3.4, REST), (5.4, (0.0, 6.0, 2.0)), (6.4, (0.0, 6.5, 2.0)), (8.0, REST)],
                          groups=[(0.6, 2.0, A), (3.6, 5.2, B), (6.5, 7.9, A)], until=8.2)
    tracks["head"] = [(0.5, 0.0, 0.0, 0.0), (2.2, 0.0, 20.0, 0.0), (3.4, 0.0, 21.0, 0.0), (5.4, 6.0, -20.0, 0.0), (6.4, 7.0, -21.0, 0.0), (7.9, 0.0, 0.0, 0.0)]
    tracks["elev_l"] = [(1.3, 0.0), (2.3, 18.0), (3.3, 20.0), (4.4, 0.0)]
    tracks["elev_top"] = [(4.3, 0.0), (5.3, 22.0), (6.3, 24.0), (7.4, 0.0)]
    b.act("sight_in", 8.6, tracks, body=body, ease="linear",
          glow=[(["web_tube_floor"], [(1.6, 0.0), (2.4, 7.0), (3.6, 7.0), (4.4, 0.0)])])
    # The probe: the fore-left leg lifts and reaches ahead, taps the ground twice, and comes
    # back to its stance, the body sinking a little and tipping down to look at what it taps
    # (_steps: the feet in their own planes, the others planted).
    fl = legs["fl"][2]
    tracks, body = _steps(limbs, [
        (0.6, (0.0, 0.0, 0.0), {}),
        (1.3, (-1.5, -2.5, 1.5), {"fl": (fl[1] + 5.0, fl[2] + 10.0)}),
        (2.0, (-1.5, -4.0, 2.5), {"fl": (fl[1] + 12.0, fl[2] + 0.0)}),
        (2.5, (-1.5, -4.0, 2.5), {"fl": (fl[1] + 12.0, fl[2] + 6.0)}),
        (2.9, (-1.5, -4.5, 2.5), {"fl": (fl[1] + 13.0, fl[2] + 0.0)}),
        (3.7, (-1.5, -4.5, 2.5), {"fl": (fl[1] + 13.0, fl[2] + 0.0)}),
        (4.3, (-0.8, -2.0, 1.0), {"fl": (fl[1] + 5.0, fl[2] + 9.0)}),
        (4.9, (0.0, 0.0, 0.0), {"fl": (fl[1], fl[2])}),
    ])
    tracks["head"] = [(0.8, 0.0, 0.0, 0.0), (2.0, -14.0, 12.0, 0.0), (3.7, -15.0, 14.0, 0.0), (4.9, 0.0, 0.0, 0.0)]
    b.act("probe", 5.4, tracks, body=body)
    # Movement, a creep (Ryan, 19 October: walk creepy, the upper legs in the walk beside the
    # solver, the Ammit's way): every foot takes one step a stride, out of step, hind then
    # fore on a side and the pairs offset, three or more feet down at any moment, each planted
    # while the body passes over it, the body level and never rolling. The coxae row (his
    # choice among the options, the sixth notes): each leg's base swings forward as its foot
    # lands, smoothly back through the stance and forward again through the swing, the solver
    # planting the foot under it (a limb's "coxa" in _plant), so the whole leg sweeps as one
    # and nothing in it is a bump; it had lifted each leg in a hitch through the swing. The
    # feet flicked forward (the sixth notes): the stride is longer (a sweep of 36, so the
    # swing lasts longer at the map's pace) and the foot's carry fills nearly the whole swing
    # (`carry`), the feet still down seven tenths of the time. The fifth notes had cut the
    # fore feet's two short steps to each hind stride (hot-stepping, far too busy) and the
    # head's turn toward each foot (weird).
    DUTY = 0.7
    walk = [dict(limbs[leg], phase={"hl": 0.0, "hr": 0.5, "fl": 0.2, "fr": 0.7}[leg],
                 shift=(6.0 if leg[0] == "f" else -6.0), nod=(0.6 if leg[0] == "f" else -0.4),
                 coxa=("coxa_" + leg, roots[leg], _coxa_row(DUTY, 10.0)))
            for leg in ("fl", "fr", "hl", "hr")]   # each stance a little out from the rest foot, so a lifted foot never folds the leg under its low hip
    tracks, body, stride = _plant(walk, sweep=36.0, duty=DUTY, lift=5.0, crouch=0.3, dip=0.6, nod=0.4, reach=0.96, airborne=0.97, smooth=0.02, n=80, carry=(0.04, 0.92))
    b.gait(stride=stride, tracks=tracks, body=body, ease="linear")   # the row at twenty degrees was an option for a day (the seventh notes); Ryan could not tell the two apart, so it is gone (the eighth)
    b.fires = {"web_bomb": ("sight_in", 2.0, 3.8)}   # its fixed weapon fires with a slice of its act: the web tube lit (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.aims = {"web_bomb": "head"}   # the Web Bomb rides the head with the rest of its guns, so the head turns to aim it
    b.move(accel=0.9, heft=0.16)

funnel_web.maker = "wainwright_sutler"



def _whip_scorpion_leg(b, leg, hip, knee, ankle, s):
    """One of the Whip Scorpion's six legs: a thigh from the hip on the cab's flank up and out to
    a knee standing over the body's line, a shin down to an ankle well clear of the ground, and
    under the ankle a short plumb post on a heavy pad. Hip, knee and ankle each pitch on the axle
    line, so the walk solver (_plant) keeps the post plumb and the pad flat while the body passes
    over it, the Funnel-web's and the Clydesdale's way; the hip turns every way for a turn on the
    spot (_footwork). `s` is -1 on the left."""
    with b.joint("hip_%s" % leg, hip, limits=(-60.0, 60.0)):
        _beam(b, hip, knee, _sq(7.6, 8.6), _sq(6.4, 7.2), "steel.plate", "thigh")
        b.prism("x", knee[0], knee[1], knee[2], 4.8, 10.0, "steel.dark", 6, "knee")
        with b.joint("knee_%s" % leg, knee, limits=(-60.0, 60.0)):
            _beam(b, knee, ankle, _sq(6.4, 7.0), _sq(4.8, 5.2), "steel.panel", "shin")
            b.prism("x", ankle[0], ankle[1], ankle[2], 3.4, 8.0, "steel.dark", 6, "ankle_pin")
            with b.joint("ankle_%s" % leg, ankle, limits=(-50.0, 50.0)):
                ax, ay, az = ankle
                b.box(ax - 2.6, ax + 2.6, ay - 2.6, ay + 2.6, 4.0, az - 1.2, "steel.plate", "foot_post")
                b.box(ax - 6.5, ax + 6.5, ay - 7.0, ay + 7.0, 0.0, 3.6, "steel.dark", "foot")
                b.box(ax - 4.8, ax + 4.8, ay - 5.2, ay + 5.2, 3.6, 5.4, "steel.plate", "foot_cap")


def _whip_scorpion_vent(b, tag, base, d):
    """One of the Thermal Ejection Manifold's vents (the passive's, modelled in, no pin), built as
    a gun (Ryan's to-do line: vents that read as guns): a dark boss on the boiler's shoulder, a
    short heavy barrel out of it with its heat banked in the bore just inside the mouth (the part
    a glow names, `vent_bore_<tag>_floor`), and a muzzle brake round the mouth, the barrel and the
    brake on a joint that runs along their line (`vent_<tag>`), so a blast kicks them back into
    the boss; a collar of heat round the barrel's middle (`vent_heat_<tag>`), lit with the bore,
    so a blast shows from behind and above as well as down the barrel, and still clear of the
    boss at the kick. Returns the joint's name."""
    base, d = Vector(base), Vector(d).normalized()
    _beam(b, tuple(base - d * 2.5), tuple(base + d * 3.0), _poly(5.0, 8, math.pi / 8), _poly(4.4, 8, math.pi / 8), "steel.dark", "vent_boss")
    name = "vent_%s" % tag
    with b.joint(name, tuple(base), slide=tuple(d)):
        _tube(b, tuple(base + d * 1.5), tuple(base + d * 15.5), 3.2, 2.4, 8, "steel.dark", "vent_bore_" + tag, floor_material="amber.heat", floor_depth=12.4, phase=math.pi / 8)
        _tube(b, tuple(base + d * 13.0), tuple(base + d * 16.5), 4.3, 3.2, 8, "steel.plate", "vent_brake", floor=False, phase=math.pi / 8)
        _tube(b, tuple(base + d * 6.0), tuple(base + d * 9.2), 3.9, 3.2, 8, "amber.heat", "vent_heat_" + tag, floor=False, phase=math.pi / 8)
    return name


def _whip_scorpion_eased(keys, t):
    """A value at `t` along keys (t, value, slam), each value a tuple: a smooth step between two
    keys, or, into a key whose slam is True, gathering speed all the way and stopping dead on it
    (a foot stamped down). Held before the first key and after the last."""
    if t <= keys[0][0]:
        return keys[0][1]
    for (t0, a, _), (t1, c, slam) in zip(keys, keys[1:]):
        if t <= t1:
            u = (t - t0) / max(1e-9, t1 - t0)
            w = u ** 2.2 if slam else u * u * (3.0 - 2.0 * u)
            return tuple(x + (y - x) * w for x, y in zip(a, c))
    return keys[-1][1]


def _whip_scorpion_round(order, t0, t1, lift=8.0):
    """One round of steps for _footwork, turning the machine on the spot: each foot of `order` in
    turn lifts and lands under the body as it stands at `t1`, a seventh of the round apart and up
    for a quarter of it, so two feet at most are up at once, never two of a side together when
    `order` alternates the sides."""
    span = t1 - t0
    return [(leg, round(t0 + span * (0.02 + 0.14 * k), 3), round(t0 + span * (0.28 + 0.14 * k), 3), ("under", t1), lift)
            for k, leg in enumerate(order)]


def whip_scorpion(b):
    """Wainwright & Sutler "Whip Scorpion" (Pattern 22 Heavy Walker): the boiler whose vents are
    its guns (Ryan's go, 20 October; its brief: git show 82ff916:docs/briefs/ws_boiler.md), a
    future-tech machine that behaves like a steampunk device, "a crazy steampunk machine venting
    everywhere". From Ryan's to-do line: a heavy walker on six or eight legs in the maker's iron,
    standing tall (Ryan, 28 October: the note of a low quad in the BattleTech Scorpion's shape was
    logged wrong, the Scorpion standing tall), a signal mirror on a mast for the Siphon's dish,
    four hardpoints, vents that read as guns. Second round, 2 November (Ryan, of the first cut's
    whip, claws and feelers: "Scorpion is too literal. Ditch the whip tail and the claws and the
    vestigial front legs"): a machine, not the animal. An armoured cab, its nose raked and glazed
    over a bumper with two floodlights, lamps at its front corners, a ladder up its left flank;
    behind it on a waist a fat boiler in the maker's brown (the cab and the legs the maker's
    iron, as the Clydesdale's bed is brown on an iron body), hooped in dark iron, a sight glass
    down its spine and a gauge on its end banked with heat, and a valve wheel on its back that
    the pilot opens to vent. Six legs off the cab's flanks, the fore pair reaching forward and the
    other two back along the boiler, each a thigh up to a knee standing over the body's line, a
    shin down to an ankle clear of the ground and a plumb post on a heavy pad, drawn in close
    about a heavier body (the first cut drew about the Funnel-web's size for a heavy). The
    Thermal Ejection Manifold (the passive, modelled in): four short gun-barrelled vents in a
    broadside on the boiler's shoulders, angled forward and out, fed by a manifold pipe down each
    flank, each kicking back along its line as it blasts, its bore and a collar round its barrel
    flaring. The Heliographic Death Ray (fixed, no pin; 11 November, in the signal mirror's
    place): a steam-fed mirrored railgun on a pedestal off the cab's back, its head turning and
    the gun elevating, its glass banked dim and flashing white. Mounts in the die's order: hp_1 the left shoulder gun (the stock's Thermal Ray
    as its barrel class) and hp_4 the right's (the Maxigun), each on a ring at a front corner of
    the roof that traverses (turret_l, turret_r); hp_2 and hp_3 bare pads on raised rings either
    side of the ray's pedestal, inboard of the shoulder guns so that a gun fitted there runs clear of them
    (the two Coolant Jackets show nowhere, vents). The look, the rig, the acts and the gait are
    Ryan's to judge running."""
    # The legs, each in the planes the walk solver works in: the knee displaced along the
    # machine from both the hip and the ankle, so a leg's side view always bends at the knee.
    # Hips on the cab's flanks, knees over the body's line, ankles well off the ground on plumb
    # posts, the feet drawn in close to the body. (x, y, z) for the left; the right mirrors.
    LEG_AT = {
        "f": ((25.5, 20.0, 48.0), (38.5, 42.0, 72.0), (44.0, 54.0, 22.0)),
        "m": ((26.5, 4.0, 48.0), (41.5, -20.0, 72.0), (47.0, -22.0, 22.0)),
        "h": ((25.5, -10.0, 48.0), (38.5, -34.0, 72.0), (44.0, -48.0, 22.0)),
    }
    legs = {}
    for k, (hip, knee, ankle) in LEG_AT.items():
        for s in (-1.0, 1.0):
            leg = k + ("l" if s < 0 else "r")
            at = tuple((s * p[0], p[1], p[2]) for p in (hip, knee, ankle))
            legs[leg] = at
            # The hip's housing on the cab's flank and its pin across it.
            x0, x1 = sorted((s * 21.5, s * 28.0))
            b.box(x0, x1, hip[1] - 5.0, hip[1] + 5.0, 42.0, 54.0, "steel.dark", "hip_block")
            b.prism("x", s * 27.5, hip[1], hip[2], 4.4, 5.0, "steel.plate", 6, "hip_pin")
            _whip_scorpion_leg(b, leg, *at, s)
    # The cab: an armoured box, its nose raked and glazed, a dark belly; a bumper across the
    # nose's foot with a floodlight in each end, a lamp in a housing at each front corner of the
    # roof (lamps, so they burn: the rule, lean hotter), a ladder up the left flank between the
    # hips' housings.
    b.loft([(-14.0, _case(44.0, 37.0, 59.0, 7.0)), (24.0, _case(44.0, 37.0, 60.0, 8.0)), (32.0, _case(40.0, 39.0, 58.0, 8.0)),
            (39.0, _case(30.0, 42.0, 53.0, 6.0))], "steel.panel", "cab")
    b.box(-18.0, 18.0, -12.0, 34.0, 34.0, 37.0, "steel.dark", "belly")
    vz = lambda y: 58.0 - (y - 32.0) * 5.0 / 7.0 + 0.45   # just proud of the raked face
    _rings(b, [[(-11.0, 32.6, vz(32.6) - 0.6), (11.0, 32.6, vz(32.6) - 0.6), (11.0, 32.6, vz(32.6)), (-11.0, 32.6, vz(32.6))],
               [(-8.5, 38.4, vz(38.4) - 0.6), (8.5, 38.4, vz(38.4) - 0.6), (8.5, 38.4, vz(38.4)), (-8.5, 38.4, vz(38.4))]], "glass.glass", "visor")
    b.box(-17.0, 17.0, 36.5, 41.0, 37.5, 43.5, "steel.dark", "bumper")
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 11.0, s * 16.5))
        b.box(x0, x1, 40.0, 41.8, 38.4, 42.8, "steel.plate", "flood_housing")
        x0, x1 = sorted((s * 12.0, s * 15.5))
        b.box(x0, x1, 41.6, 42.4, 39.2, 42.0, "amber.light", "floodlight")
        x0, x1 = sorted((s * 13.0, s * 18.5))
        b.box(x0, x1, 28.5, 33.0, 52.5, 57.5, "steel.plate", "lamp_housing")
        x0, x1 = sorted((s * 13.8, s * 17.7))
        b.box(x0, x1, 32.8, 33.8, 53.4, 56.6, "amber.light", "lamp")
    b.box(-22.6, -22.0, 9.6, 14.4, 38.0, 51.5, "steel.ladder", "ladder")
    # The shoulder guns (hp_1 left, the Thermal Ray; hp_4 right, the Maxigun), each on a ring at
    # a front corner of the roof that traverses, its barrel class forward over the nose.
    for s, n, comp in ((-1.0, 1, "thermal_ray"), (1.0, 4, "maxigun")):
        gx = s * 16.5
        b.prism("z", gx, 21.0, 58.0, 5.4, 1.4, "steel.dark", 8, "gun_ring", phase=math.pi / 8)
        with b.joint("turret_" + ("l" if s < 0 else "r"), (gx, 21.0, 58.7), limits=(-60.0, 60.0)):
            b.box(gx - 4.6, gx + 4.6, 16.0, 26.0, 58.7, 62.9, "steel.plate", "gun_mount")
            b.stock("hp_%d" % n, (gx, 22.0, 66.1), "barrel", scale=0.95, carries=comp)
    # The bare mounts either side of the mast (hp_2, hp_3), each on a raised ring, so a gun
    # fitted there runs forward over the roof, inboard of the shoulder guns.
    for s, n in ((-1.0, 2), (1.0, 3)):
        b.prism("z", s * 6.5, 0.0, 60.4, 4.2, 2.6, "steel.dark", 8, "pad_ring", phase=math.pi / 8)
        b.pad("hp_%d" % n, (s * 6.5, 0.0, 63.0), scale=0.9, size=(6.6, 1.2))
    # The Heliographic Death Ray (fixed, no pin; Ryan, 11 November: "an actual gun. Pipes
    # connecting it to the boiler, steampunk style. Mirror or mirrors as part of it because weird
    # future nonsense tech. Like a steam powered mirrored laser railgun"): a pedestal off the cab's
    # back, two steam mains up its rear from the waist into a collar under a head that turns
    # (turret_ray); on it, in trunnion cheeks, the gun that elevates (ray): a dark breech with a
    # brown pressure accumulator hooped on its back and a gauge on its end, a collector mirror on
    # a bracket over the breech with its glass to the sky (so the map, the codex and the skirmish
    # all see it flash), two long rails clamped in iron hoops with the bore between them banked
    # with heat, three relay mirrors along the rails' top tipped by turns, a steam line down each
    # rail, and a muzzle ring round a lens. The glass is cold and flashes white, the one lit
    # colour on the machine that is no flame.
    PY, PZ, GZ = -7.0, 72.0, 79.0   # the pedestal's line, the head's foot, the gun's axis
    b.box(-4.2, 4.2, PY - 4.2, PY + 4.2, 58.5, 60.6, "steel.dark", "ray_foot")
    b.prism("z", 0.0, PY, 65.6, 3.4, 10.4, "steel.plate", 8, "ray_pedestal", phase=math.pi / 8)
    b.prism("z", 0.0, PY, 71.1, 6.0, 1.8, "steel.dark", 8, "ray_collar", phase=math.pi / 8)
    for s in (-1.0, 1.0):
        # A main up from the waist, over the cab's back edge and up the pedestal's rear.
        _beam(b, (s * 6.0, -16.0, 55.0), (s * 6.0, -14.6, 61.4), _poly(2.5, 6), _poly(2.5, 6), "livery.livery2", "ray_main")
        _beam(b, (s * 6.0, -14.6, 61.4), (s * 3.6, PY - 3.6, 63.0), _poly(2.5, 6), _poly(2.5, 6), "livery.livery2", "ray_main")
        _beam(b, (s * 3.6, PY - 3.6, 63.0), (s * 3.6, PY - 3.6, 70.4), _poly(2.5, 6), _poly(2.5, 6), "livery.livery2", "ray_main")
        b.prism("z", s * 3.6, PY - 3.6, 66.3, 3.2, 1.2, "steel.dark", 6, "ray_main_flange")
    N = Vector((0.0, math.cos(math.radians(50.0)), math.sin(math.radians(50.0))))   # the collector's face: forward and up
    RELAYS = (10.0, 23.0, 36.0)   # the relay mirrors, along the rails
    with b.joint("turret_ray", (0.0, PY, PZ), limits=(-60.0, 60.0)):
        b.box(-8.0, 8.0, PY - 5.0, PY + 5.0, PZ, PZ + 1.6, "steel.dark", "ray_cradle")
        for s in (-1.0, 1.0):
            x0, x1 = sorted((s * 6.4, s * 8.0))
            b.box(x0, x1, PY - 3.4, PY + 3.4, PZ + 0.4, GZ + 3.0, "steel.plate", "ray_cheek")
        b.prism("x", 0.0, PY, GZ, 1.8, 17.2, "steel.dark", 6, "ray_trunnion")
        with b.joint("ray", (0.0, PY, GZ), limits=(-8.0, 10.0)):   # its breech rides over the boiler, so it lifts little
            # The gun slid back in its cradle (Ryan, 11 November: "slide it back, keeping the mount
            # in place, so it overhangs the back of the mount ... give the front some space and make
            # a little scorpion vibe"): the cheeks grip the rails at a block, the breech and the
            # collector riding out over the boiler like a tail carried high.
            GY = PY - 13.0
            b.box(-6.2, 6.2, PY - 3.0, PY + 3.0, GZ - 3.4, GZ + 3.2, "steel.dark", "ray_trunnion_block")
            b.box(-6.0, 6.0, GY - 12.0, GY + 3.0, GZ - 4.4, GZ + 4.4, "steel.dark", "ray_breech")
            b.prism("y", 0.0, GY - 4.5, GZ + 8.2, 4.2, 12.0, "livery.livery2", 8, "ray_tank", phase=math.pi / 8)
            for y in (GY - 8.5, GY - 0.5):
                b.prism("y", 0.0, y, GZ + 8.2, 4.7, 1.4, "steel.dark", 8, "ray_tank_hoop", phase=math.pi / 8)
            b.prism("y", 0.0, GY - 10.9, GZ + 8.2, 2.6, 0.8, "steel.dark", 8, "ray_gauge", phase=math.pi / 8)
            b.prism("y", 0.0, GY - 11.4, GZ + 8.2, 2.0, 0.4, "amber.light", 8, "ray_gauge_face", phase=math.pi / 8)
            # A steam line from the tank down each flank of the breech, elbowed.
            for s in (-1.0, 1.0):
                _beam(b, (s * 3.6, GY - 4.5, GZ + 9.0), (s * 7.2, GY - 4.5, GZ + 6.0), _poly(1.4, 6), _poly(1.4, 6), "livery.livery2", "ray_line")
                _beam(b, (s * 7.2, GY - 4.5, GZ + 6.0), (s * 7.2, GY - 4.5, GZ - 2.0), _poly(1.4, 6), _poly(1.4, 6), "livery.livery2", "ray_line")
            # The collector on its bracket, behind and over the tank.
            c = Vector((0.0, GY - 16.0, GZ + 17.0))
            _beam(b, (0.0, GY - 11.0, GZ + 3.0), tuple(c - N * 1.2), _sq(3.0, 2.0), _sq(3.0, 2.0), "steel.plate", "ray_bracket")
            _beam(b, tuple(c - N * 1.3), tuple(c + N * 0.2), _poly(10.6, 8, math.pi / 8), _poly(10.6, 8, math.pi / 8), "livery.livery2", "mirror_back")
            _tube(b, tuple(c - N * 0.6), tuple(c + N * 1.1), 11.4, 10.3, 8, "steel.dark", "mirror_rim", floor=False, phase=math.pi / 8)
            _disc(b, tuple(c + N * 0.3), tuple(N), 9.9, 8, "amber.spark", "mirror_face", phase=math.pi / 8)
            # The rails, the bore between them, their hoops and the steam line down each.
            Y0, Y1 = GY + 3.0, GY + 54.0
            for s in (-1.0, 1.0):
                x0, x1 = sorted((s * 2.0, s * 5.0))
                b.box(x0, x1, Y0, Y1, GZ - 2.6, GZ + 2.6, "steel.plate", "ray_rail")
                b.prism("y", s * 6.6, (Y0 + Y1) / 2.0 - 3.0, GZ - 2.0, 1.4, Y1 - Y0 - 8.0, "livery.livery2", 6, "ray_line")
            b.box(-2.0, 2.0, Y0, Y1 - 0.5, GZ - 1.0, GZ + 1.4, "amber.heat", "ray_bore")
            for y in (GY + 9.0, GY + 22.0, GY + 35.0, GY + 48.0):
                b.box(-8.2, 8.2, y - 1.3, y + 1.3, GZ - 4.0, GZ + 0.2, "steel.dark", "ray_hoop")
                for s in (-1.0, 1.0):   # the hoop's cheeks up the rails' flanks, the bore left open to the sky
                    x0, x1 = sorted((s * 5.0, s * 8.2))
                    b.box(x0, x1, y - 1.3, y + 1.3, GZ + 0.2, GZ + 3.4, "steel.dark", "ray_hoop")
            for k, y in enumerate(RELAYS):
                side = 1.0 if k % 2 == 0 else -1.0   # on the left rail and the right by turns, each tipped in over the bore and up at the sky
                rn = Vector((-side * 0.5, 0.2, 1.0)).normalized()
                rc = Vector((side * 6.2, GY + y + 5.5, GZ + 8.2))
                b.prism("z", side * 6.2, GY + y + 5.5, GZ + 5.6, 1.0, 4.0, "steel.dark", 6, "ray_relay_post")
                _beam(b, tuple(rc - rn * 0.9), tuple(rc), _poly(4.6, 4, math.pi / 4), _poly(4.6, 4, math.pi / 4), "steel.dark", "ray_relay_back")
                _disc(b, tuple(rc + rn * 0.08), tuple(rn), 4.0, 4, "amber.spark", "ray_relay_%d" % (k + 1), phase=math.pi / 4)
            _tube(b, (0.0, Y1 - 1.5, GZ), (0.0, Y1 + 4.0, GZ), 7.4, 4.8, 8, "steel.dark", "ray_muzzle", floor=False, phase=math.pi / 8)
            _disc(b, (0.0, Y1 + 3.0, GZ), (0.0, 1.0, 0.0), 4.7, 8, "amber.spark", "ray_lens", phase=math.pi / 8)
    # The boiler on the waist (abdomen): a fat pressure vessel in the maker's brown, eight-sided,
    # hooped in dark iron, dished to its end; a sight glass down its spine banked with heat; a
    # gauge on its end; a valve wheel on its back on a spindle (valve), spokes so its turn reads;
    # the manifold's pipe down each flank feeding two vents on each shoulder, a broadside angled
    # forward and out, set back behind the hind thighs' sweep.
    BZ = 51.0
    b.prism("y", 0.0, -15.0, 50.0, 11.0, 4.0, "steel.dark", 8, "waist", phase=math.pi / 8)
    abdomen = b.joint("abdomen", (0.0, -15.0, 50.0), limits={"pitch": (-16.0, 10.0), "yaw": (-14.0, 14.0)})   # its pitch negative tips the boiler's end up; its yaw positive swings the end right
    abdomen.__enter__()
    b.loft([(-58.0, _oct(BZ + 2.0, 16.0, 12.0)), (-54.0, _oct(BZ + 1.0, 34.0, 24.0)), (-49.0, _oct(BZ, 52.0, 34.0)), (-17.0, _oct(BZ, 52.0, 34.0))],
           "livery.livery2", "boiler")
    for y in (-24.0, -36.5, -49.0):
        b.loft([(y - 1.1, _oct(BZ, 53.6, 35.6)), (y + 1.1, _oct(BZ, 53.6, 35.6))], "steel.dark", "hoop")
    TOP = BZ + 17.0 * math.sin(3.0 * math.pi / 8.0)   # the top flat
    b.box(-2.2, 2.2, -36.7, -18.3, TOP - 0.3, TOP + 0.7, "steel.dark", "glass_frame")
    b.box(-1.4, 1.4, -36.0, -19.0, TOP + 0.1, TOP + 1.0, "amber.heat", "gauge_glass")
    b.prism("y", 0.0, -58.2, BZ + 2.0, 3.6, 1.2, "steel.dark", 8, "gauge", phase=math.pi / 8)
    b.prism("y", 0.0, -58.9, BZ + 2.0, 2.8, 0.4, "amber.light", 8, "gauge_face", phase=math.pi / 8)
    VY = -44.0
    b.prism("z", 0.0, VY, TOP + 1.6, 1.1, 3.2, "steel.dark", 6, "valve_stem")
    with b.joint("valve", (0.0, VY, TOP + 3.4), axis="yaw"):   # a spindle that turns without end: no limits
        _tube(b, (0.0, VY, TOP + 2.9), (0.0, VY, TOP + 3.9), 5.6, 4.7, 8, "steel.plate", "valve_wheel", floor=False, phase=math.pi / 8)
        b.prism("z", 0.0, VY, TOP + 3.4, 1.3, 1.4, "steel.dark", 6, "valve_hub")
        for k in range(3):
            a = math.radians(90.0 + 120.0 * k)
            _beam(b, (0.0, VY, TOP + 3.4), (5.0 * math.cos(a), VY + 5.0 * math.sin(a), TOP + 3.4), _sq(1.1, 0.8), _sq(1.1, 0.8), "steel.dark", "valve_spoke")
        b.box(-0.9, 0.9, VY + 4.6, VY + 6.2, TOP + 3.0, TOP + 5.6, "steel.dark", "valve_knob")
    for s in (-1.0, 1.0):   # the mains' ends on the boiler's shoulder, meeting the cab's at the waist
        _beam(b, (s * 6.0, -23.0, BZ + 15.2), (s * 6.0, -17.6, 56.5), _poly(2.5, 6), _poly(2.5, 6), "livery.livery2", "ray_main")
        b.prism("y", s * 6.0, -17.6, 56.5, 3.2, 1.2, "steel.dark", 6, "ray_main_flange")
    vents = []
    VENT_UP = 47.0   # the vents' lift off the level: 35 until 11 November (Ryan: "a teeny bit more vertical, to better clear the knees")
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        b.prism("y", s * 25.3, -34.0, BZ, 2.0, 28.0, "steel.dark", 6, "manifold")
        for k, y in ((1, -30.25), (2, -42.75)):
            base = (s * 17.0, y, 62.1)
            _beam(b, (s * 25.3, y, BZ), (s * 19.6, y, 59.6), _poly(1.6, 6), _poly(1.6, 6), "steel.dark", "manifold_feed")
            d = (s * math.cos(math.radians(VENT_UP)) * math.sin(math.radians(55.0)), math.cos(math.radians(VENT_UP)) * math.cos(math.radians(55.0)), math.sin(math.radians(VENT_UP)))
            vents.append((side + str(k), _whip_scorpion_vent(b, side + str(k), base, d), d))
    abdomen.__exit__(None, None, None)

    # Idle acts (four, loud, never in step, every joint holding still before it turns back; a
    # heavy walker's servos, b.move). Degrees and seconds; a key is (t, value) on the joint's own
    # axis, (t, pitch, yaw, roll), or that with a slide (dx, dy, dz) after it; a body key is
    # (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k), k the light added
    # over rest (-1 dark). The feet stay planted while the body moves over them (_planted, its
    # poses keyed ten a second so nothing drifts between them; _steps for a stamp; _footwork for
    # the jolts and the turns on the spot); a turret keyed in an act played linear keeps its keys
    # sparse, so it slews evenly under the turret rule.
    LEGS = ("fl", "fr", "ml", "mr", "hl", "hr")
    limb = lambda leg: {"hip": "hip_" + leg, "knee": "knee_" + leg, "ankle": "ankle_" + leg, "at": legs[leg]}
    limbs = [limb(leg) for leg in LEGS]
    by_name = {leg: limb(leg) for leg in LEGS}
    HEAT = 196.0   # the heat tile's light at its height: #ff7800 under the phone's eased light, as the Polar Bear's vents
    # The ray (the Heliographic Death Ray): it squats and braces, the boiler's end tipping up and
    # its pressure climbing the sight glass and the gun's gauge; the gun lifts off its rest and
    # the collector flashes twice at the sky; then the light runs down the gun, relay by relay,
    # the bore between the rails going white behind it, and the lens fires, the gun kicked back
    # along its line and held, the whole machine jolting on its planted feet; the bore banks down,
    # the gun runs out and settles, and it rises again.
    FIRE = 3.1
    tracks, body = _planted(limbs, _dense([(0.3, 0.0, 0.0, 0.0), (1.5, 0.0, -1.2, -2.2), (FIRE - 0.02, 0.0, -1.2, -2.2), (FIRE + 0.08, 0.0, -3.4, -2.6),
                                           (FIRE + 0.6, 0.0, -1.6, -2.2), (5.2, 0.0, -1.2, -2.0), (6.6, 0.0, 0.0, 0.0)], 10.0))
    tracks.update({
        "ray": _dense([(0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (1.7, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0), (FIRE - 0.02, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0), (FIRE + 0.06, 7.5, 0.0, 0.0, 0.0, -5.0, 0.0),
                       (FIRE + 0.45, 7.5, 0.0, 0.0, 0.0, -5.0, 0.0), (FIRE + 1.5, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0), (5.4, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0), (6.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)]),
        "turret_l": [(0.8, 0.0), (1.8, 24.0), (5.2, 24.0), (6.3, 0.0)],
        "turret_r": [(0.9, 0.0), (1.9, -24.0), (5.3, -24.0), (6.4, 0.0)],
        "abdomen": _dense([(0.5, 0.0, 0.0, 0.0), (1.6, -6.0, 0.0, 0.0), (FIRE - 0.02, -6.0, 0.0, 0.0), (FIRE + 0.1, -9.0, 0.0, 0.0), (FIRE + 0.7, -5.0, 0.0, 0.0), (5.4, -5.0, 0.0, 0.0), (6.5, 0.0, 0.0, 0.0)]),
    })
    FLASH = 24.0   # the glass's light at a flash: past white under the phone's eased light
    blink = lambda t, d, k=FLASH: [(round(t, 3), 1.0), (round(t + 0.05, 3), k), (round(t + d - 0.05, 3), k), (round(t + d, 3), 1.0)]
    glow = [(["mirror_face"], [(1.6, 0.0)] + blink(1.75, 0.2) + blink(2.1, 0.2) + blink(2.45, 0.9) + [(4.2, 0.0)]),
            (["ray_lens"], [(FIRE - 0.1, 0.0)] + blink(FIRE - 0.04, 0.6) + [(4.4, 0.0)]),
            (["ray_bore"], [(0.6, 0.0), (2.4, 30.0), (FIRE - 0.04, 60.0), (FIRE, HEAT), (FIRE + 0.5, HEAT), (5.0, 30.0), (6.4, 0.0)]),
            (["gauge_glass"], [(0.5, 0.0), (1.6, 40.0), (FIRE - 0.05, 120.0), (FIRE + 0.1, 0.0)]),
            (["gauge_face", "ray_gauge_face"], [(0.5, 0.0), (1.6, 5.0), (FIRE - 0.05, 9.0), (FIRE + 0.3, 2.0), (6.0, 0.0)]),
            (["lamp", "floodlight"], [(0.5, 0.0), (1.2, 6.0), (5.4, 6.0), (6.2, 0.0)])]
    for k in range(3):
        t = 2.62 + 0.15 * k
        glow.append((["ray_relay_%d" % (k + 1)], [(t - 0.1, 0.0)] + blink(t, FIRE + 0.5 - t) + [(4.2, 0.0)]))
    b.act("ray", 6.8, tracks, body=body, ease="linear", heft=0.08, glow=glow)
    # The blast (the Thermal Ejection Manifold's release, a firing alone since 12 November, never
    # played at rest: a broadside at rest would read as a release that never came; Ryan, 12
    # November: "the blast should be hooked up, same as the ray animation"): the pilot spins the
    # valve wheel open a whole turn as the machine squats and braces, the boiler's end pumping up and its pressure building in
    # the sight glass and every bore; then the broadside fires, the right pair and then the left,
    # each barrel kicking back into its boss as its bore and collar flare from a dull ember, the
    # whole machine jolting off each shot on its planted feet and the boiler's end swinging away
    # from each pair and holding; the bores bank down, the wheel is spun shut and it rises again.
    SHOTS = [("r1", 2.4), ("r2", 2.95), ("l1", 3.9), ("l2", 4.45)]
    SQUAT = (0.0, -0.5, -2.4, 0.0, -1.2, 0.0)
    keys = [(0.3, (0.0,) * 6), (1.7, SQUAT), (2.35, SQUAT)]
    for tag, t in SHOTS:
        s = 1.0 if tag[0] == "r" else -1.0
        keys += [(round(t + 0.06, 3), (round(-s * 0.8, 3), -1.2, -2.1, round(-s * 0.9, 3), -0.6, round(-s * 1.4, 3))),
                 (round(t + 0.45, 3), (0.0, -0.6, -2.4, 0.0, -1.2, 0.0))]
    keys += [(5.6, SQUAT), (6.9, (0.0,) * 6)]
    legs_t, body = _footwork(by_name, keys, [], until=7.2, hz=20.0)
    tracks = dict(legs_t)
    for tag, jn, d in vents:
        t = dict(SHOTS)[tag]
        back = tuple(round(-3.8 * v, 3) for v in d)   # kicked back into its boss, the collar still clear of it, and held a beat
        tracks[jn] = _dense([(0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (round(t - 0.02, 3), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (round(t + 0.05, 3), 0.0, 0.0, 0.0) + back,
                             (round(t + 0.2, 3), 0.0, 0.0, 0.0) + back, (round(t + 0.75, 3), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (7.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)])
    # The end swings away from each pair's kick (a right vent's swings it left, the yaw negative)
    # and holds until the other pair fires.
    tracks["abdomen"] = _dense([(0.3, 0.0, 0.0, 0.0), (1.7, -6.0, 0.0, 0.0), (2.35, -6.0, 0.0, 0.0), (2.52, -4.0, -4.0, 0.0), (2.95, -4.0, -4.0, 0.0),
                                (3.07, -4.0, -5.0, 0.0), (3.9, -4.0, -5.0, 0.0), (4.02, -4.0, 4.0, 0.0), (4.45, -4.0, 4.0, 0.0), (4.57, -4.0, 5.0, 0.0),
                                (5.2, -4.0, 5.0, 0.0), (5.8, -5.0, 0.0, 0.0), (6.4, -5.0, 0.0, 0.0), (7.0, 0.0, 0.0, 0.0)])
    tracks["valve"] = _dense([(0.3, 0.0), (1.5, 360.0), (5.6, 360.0), (6.8, 0.0)])
    BANKED = 16.0   # the bores' heat building before the shots and banked after them: a dull ember, so each shot jumps to the full orange
    glow = [(["gauge_glass"], [(0.4, 0.0), (1.6, 40.0), (2.35, 120.0), (4.6, HEAT), (5.3, 60.0), (6.9, 0.0)]),
            (["gauge_face"], [(0.4, 0.0), (1.6, 5.0), (4.6, 9.0), (5.3, 5.0), (6.9, 0.0)])]
    for tag, t in SHOTS:
        glow.append((["vent_bore_%s_floor" % tag, "vent_heat_%s" % tag], [(0.4, 0.0), (1.6, BANKED), (round(t - 0.02, 3), BANKED), (round(t + 0.04, 3), HEAT), (round(t + 0.45, 3), HEAT),
                                                                         (round(t + 1.1, 3), BANKED), (5.7, BANKED), (6.9, 0.0)]))
    b.act("blast", 7.4, tracks, body=body, ease="linear", heft=0.06, glow=glow, idle=False)
    # The stamp: it rocks its weight back onto its other legs, lifts its fore-left foot high and
    # holds it, then stamps it down hard, the whole body dropping onto it and the boiler's end
    # slamming down on its waist, the lamps and floodlights flaring and the heat jolted up the
    # sight glass; it settles, and does the same with its fore-right. The ray's head turns to
    # watch each foot, the glass tipped down at it, and the shoulder guns swing out for balance.
    # On quicker servos than its own (the act's heft), so the stamp stops dead.
    FL, FR = legs["fl"][2], legs["fr"][2]
    rest = lambda e: (e[1], e[2])
    raised = lambda e, more=0.0: (e[1] + 6.0 + more, e[2] + 20.0 + more)
    BACK, BACK2, DROP, REBOUND, HOME = (-2.4, 1.6, 3.6), (-2.6, 1.8, 3.9), (0.6, -1.6, -1.8), (0.2, -0.5, -0.6), (0.0, 0.0, 0.0)
    body_keys = [(0.4, HOME, False), (1.4, BACK, False), (2.2, BACK2, False), (2.45, DROP, True), (2.75, REBOUND, False), (3.5, HOME, False),
                 (4.5, BACK, False), (5.3, BACK2, False), (5.55, DROP, True), (5.85, REBOUND, False), (6.6, HOME, False)]
    fl_keys = [(0.5, rest(FL), False), (1.4, raised(FL), False), (2.2, raised(FL, 0.6), False), (2.45, rest(FL), True)]
    fr_keys = [(3.6, rest(FR), False), (4.5, raised(FR), False), (5.3, raised(FR, 0.6), False), (5.55, rest(FR), True)]
    frames = [(round(0.4 + i / 20.0, 3),) for i in range(int(round(6.4 * 20.0)) + 1)]
    frames = [(t, _whip_scorpion_eased(body_keys, t), {"fl": _whip_scorpion_eased(fl_keys, t), "fr": _whip_scorpion_eased(fr_keys, t)}) for (t,) in frames]
    tracks, body = _steps(by_name, frames)
    tracks.update({
        "abdomen": _dense([(0.5, 0.0, 0.0, 0.0), (1.4, -3.0, 0.0, 0.0), (2.2, -3.0, 0.0, 0.0)] + [(tt, *v) for tt, v in _slam(2.2, (-3.0, 0.0, 0.0), 2.45, (4.0, 0.0, 0.0))] +
                          [(3.05, 4.0, 0.0, 0.0), (3.6, 0.0, 0.0, 0.0), (4.5, -3.0, 0.0, 0.0), (5.3, -3.0, 0.0, 0.0)] + [(tt, *v) for tt, v in _slam(5.3, (-3.0, 0.0, 0.0), 5.55, (4.0, 0.0, 0.0))] +
                          [(6.15, 4.0, 0.0, 0.0), (6.8, 0.0, 0.0, 0.0)]),
        "turret_ray": [(0.6, 0.0), (1.6, 25.0), (3.0, 25.0), (4.6, -25.0), (6.0, -25.0), (6.9, 0.0)],
        "ray": [(0.6, 0.0), (1.6, -6.0), (6.0, -6.0), (7.0, 0.0)],
        "turret_l": [(0.8, 0.0), (1.8, 20.0), (6.2, 20.0), (7.0, 0.0)],
        "turret_r": [(0.9, 0.0), (1.9, -20.0), (6.3, -20.0), (7.1, 0.0)],
    })
    flare = [(0.4, 0.0), (1.2, 4.0), (2.42, 4.0), (2.48, 12.0), (2.95, 5.0), (5.52, 5.0), (5.58, 12.0), (6.05, 5.0), (7.2, 0.0)]
    b.act("stamp", 8.0, tracks, body=body, ease="linear", heft=0.08,
          glow=[(["lamp", "floodlight"], flare),
                (["gauge_glass"], [(2.4, 0.0), (2.5, 120.0), (3.3, 0.0), (5.5, 0.0), (5.6, 120.0), (6.4, 0.0)])])
    # The survey: it turns on the spot to look round, stepping each foot in turn (a round of six
    # steps, the sides by turns), twelve degrees left and holding, then right through the middle
    # to twelve degrees right in two rounds, holding, and home; a little lower as it steps. The
    # shoulder guns and the ray's head lead the turn round and hold on what it watches, the
    # glass tipped up at the field, the lamps and floodlights up. On quicker servos than its own
    # (the act's heft), so each step lifts clear.
    turn = lambda yaw, dz=0.0: (0.0, 0.0, dz, yaw, 0.0, 0.0)
    pose = [(0.4, turn(0.0)), (1.9, turn(12.0, -1.2)), (3.5, turn(12.0)), (5.0, turn(0.0, -1.2)), (6.5, turn(-12.0, -1.2)), (8.1, turn(-12.0)), (9.6, turn(0.0, -1.2)), (10.0, turn(0.0))]
    keys = []
    for (t0, a), (t1, c) in zip(pose, pose[1:]):   # eased between poses, ten a second
        for i in range(int(round((t1 - t0) * 10.0))):
            u = i / ((t1 - t0) * 10.0)
            w = u * u * (3.0 - 2.0 * u)
            keys.append((round(t0 + i / 10.0, 3), tuple(round(x + (y - x) * w, 4) for x, y in zip(a, c))))
    keys.append(pose[-1])
    LEFT, RIGHT = ("hl", "fr", "ml", "hr", "fl", "mr"), ("hr", "fl", "mr", "hl", "fr", "ml")
    steps = (_whip_scorpion_round(LEFT, 0.4, 1.9) + _whip_scorpion_round(RIGHT, 3.5, 5.0) + _whip_scorpion_round(RIGHT, 5.0, 6.5) +
             _whip_scorpion_round(LEFT, 8.1, 9.6))
    legs_t, body = _footwork(by_name, keys, steps, until=10.0, hz=20.0)
    tracks = dict(legs_t)
    tracks.update({
        "turret_l": [(0.6, 0.0), (2.0, 30.0), (3.6, 30.0), (5.3, -26.0), (8.2, -26.0), (9.4, 0.0)],
        "turret_r": [(0.7, 0.0), (2.1, 26.0), (3.7, 26.0), (5.4, -30.0), (8.3, -30.0), (9.5, 0.0)],
        "turret_ray": [(0.6, 0.0), (1.8, 40.0), (3.6, 40.0), (6.0, -40.0), (8.2, -40.0), (9.4, 0.0)],
        "ray": _dense([(0.6, 0.0), (1.6, 10.0), (8.6, 10.0), (9.6, 0.0)]),
    })
    b.act("survey", 10.4, tracks, body=body, ease="linear", heft=0.08,
          glow=[(["lamp", "floodlight"], [(0.4, 0.0), (1.0, 6.0), (9.2, 6.0), (9.9, 0.0)])])
    # The pressure check (Ryan's pick of 12 November, one of two idle acts added once the broadside
    # became the release's alone): the pilot cracks the valve wheel a quarter turn and back, twice;
    # the boiler's end shudders on its waist while it stands open, the machine settling a little on
    # its legs as the pressure comes off, the sight glass bobbing up and settling and the gauge's
    # face flickering. No vent kicks and no bore glows, so it never reads as a release.
    CRACKS = ((0.6, 1.1, 1.7, 2.1), (3.0, 3.5, 4.1, 4.5))   # each: turning, open, held to, shut
    shudder = [(0.4, 0.0, 0.0, 0.0)]
    for t_turn, t_open, t_held, t_shut in CRACKS:
        shudder.append((t_turn, 0.0, 0.0, 0.0))
        n = int(round((t_held - t_open) / 0.08))
        for k in range(n):
            s_ = 1.0 if k % 2 == 0 else -1.0
            shudder.append((round(t_open + k * 0.08, 3), round(-1.4 + 0.5 * s_, 3), round(1.6 * s_, 3), 0.0))
        shudder += [(round(t_held + 0.1, 3), -0.8, 0.0, 0.0), (t_shut, 0.0, 0.0, 0.0)]
    shudder.append((6.2, 0.0, 0.0, 0.0))
    tracks, body = _planted(limbs, _dense([(0.3, 0.0, 0.0, 0.0), (1.1, 0.0, 0.0, 0.0), (1.7, 0.0, -0.7, 0.0), (2.4, 0.0, 0.0, 0.0), (3.5, 0.0, 0.0, 0.0),
                                           (4.1, 0.0, -0.9, 0.0), (4.9, 0.0, 0.0, 0.0), (6.2, 0.0, 0.0, 0.0)], 10.0))   # (t, dy, dz, pitch)
    tracks.update({
        "valve": _dense([(0.3, 0.0), (0.6, 0.0), (1.1, 90.0), (1.7, 90.0), (2.1, 0.0), (3.0, 0.0), (3.5, 90.0), (4.1, 90.0), (4.5, 0.0), (6.0, 0.0)]),
        "abdomen": _dense(shudder),
    })
    flicker = lambda t: [(round(t, 3), 0.0), (round(t + 0.1, 3), 4.0), (round(t + 0.2, 3), 0.5), (round(t + 0.35, 3), 4.0), (round(t + 0.6, 3), 0.0)]
    b.act("pressure_check", 6.6, tracks, body=body, ease="linear", heft=0.08,
          glow=[(["gauge_glass"], [(0.5, 0.0), (1.1, 0.0), (1.5, 40.0), (2.0, 10.0), (2.6, 0.0), (3.5, 0.0), (3.9, 48.0), (4.4, 12.0), (5.2, 0.0)]),
                (["gauge_face"], [(0.5, 0.0)] + flicker(1.1) + flicker(3.5) + [(5.0, 0.0)])])
    # The heliograph sighting (Ryan's pick of 12 November): the ray's head swings slowly round to
    # the left with the gun lifted as far as it goes, then across the sky to the right, stopping
    # where the sun stands for the collector to catch it in one bright glint, and on round; it
    # holds there and comes home, standing a little taller while it sights. The relays and the lens
    # stay dark, so it never reads as the ray charging.
    tracks, body = _planted(limbs, _dense([(0.4, 0.0, 0.0, 0.0), (1.8, 0.0, 1.0, 0.0), (7.2, 0.0, 1.0, 0.0), (8.6, 0.0, 0.0, 0.0)], 10.0))   # (t, dy, dz, pitch)
    tracks.update({
        "turret_ray": [(0.6, 0.0), (2.0, -40.0), (2.8, -40.0), (4.2, 5.0), (5.0, 5.0), (6.2, 45.0), (7.0, 45.0), (8.4, 0.0)],
        "ray": _dense([(0.6, 0.0), (1.8, 10.0), (7.2, 10.0), (8.4, 0.0)]),
    })
    b.act("heliograph_sighting", 8.8, tracks, body=body, ease="linear", heft=0.08,
          glow=[(["mirror_face"], [(4.3, 0.0), (4.45, FLASH), (4.62, round(FLASH * 0.7, 1)), (4.95, 0.0)])])
    # Movement: a heavy creep on six legs, one foot at a time on each side from the hind to the
    # fore, the two sides half a stride apart, so four feet or more stand at once, each planted
    # while the body passes over it, lifted, carried and stamped down; the body level but for its
    # drop onto each foot, the fores dipping the nose and the hinds lifting it; the boiler swaying
    # on its waist and nodding with the stride.
    DUTY = 0.7
    order = {"hl": 0.0, "ml": 1.0 / 3.0, "fl": 2.0 / 3.0, "hr": 0.5, "mr": 5.0 / 6.0, "fr": 1.0 / 6.0}
    walk = [dict(limb(leg), phase=order[leg], shift={"f": 2.0, "m": 0.0, "h": -2.0}[leg[0]], nod={"f": 0.6, "m": 0.1, "h": -0.4}[leg[0]]) for leg in LEGS]
    tracks, body, stride = _plant(walk, sweep=34.0, duty=DUTY, lift=8.0, crouch=0.3, dip=1.0, nod=0.5, reach=0.96, airborne=0.97, smooth=0.02, n=120)
    tracks["abdomen"] = ([(i / 40.0, round(0.8 * math.sin(4.0 * math.pi * i / 40.0), 3), round(2.5 * math.sin(2.0 * math.pi * i / 40.0), 3), 0.0) for i in range(41)], 0.0)
    b.gait(stride=stride, tracks=tracks, body=body, ease="linear")
    b.move(accel=1.4, heft=0.22)
    # Its Heliographic Death Ray fires with a slice of its ray: the collector's last flash, the
    # light down the relays, the blow as the lens fires, the gun kicked back and running out. Its
    # passive's release fires the broadside, keyed by the passive's id: the valve wheel's last
    # quarter turn and the squat, the blow on every foe as the first gun fires, the other three
    # after it, and the bores flaring until the last gun's kick has run out.
    b.fires = {"heliographic_death_ray": ("ray", 2.3, 5.0, FIRE),
               "thermal_ejection_manifold": ("blast", 1.2, 5.3, SHOTS[0][1])}
    # Its manifold's four vents wear the halo every glowing vent does (Ryan, 31 October: "applied to all
    # 'hot' things - so all glowing boosters and vents"; found bare on 3 November), the collar and the
    # bore's floor lit together as its blast flares them.
    b.halo = ["vent_heat_" + t for t in ("l1", "l2", "r1", "r2")] + ["vent_bore_%s_floor" % t for t in ("l1", "l2", "r1", "r2")]

whip_scorpion.maker = "wainwright_sutler"


def buzzard(b):
    """Kestrel "Buzzard" (K-9 Mk II Attack Airframe): a medium-large airframe, endurance over
    burst. Second pass (Ryan, 29 September): a wider span on a shorter body, a smaller
    canopy, weapons clear of the wings, no traditional tail: the boosters ride the aft
    fuselage's shoulders as nacelles, each carrying a fin canted outward, and the cannon is
    a wide short bore tucked under the nose in a fairing that runs back along the belly to
    the engines it draws heat from (the Afterburner Cannon, fixed, no pin). Pins under the
    wings: hp_1 left inner (the Overclocked Railgun) and hp_2 right inner (the Transonic Rifle),
    each a gun in its pod, hp_3 left outer (the Arc-fault Cannon, two prongs), hp_4 right
    outer an empty pod (the stock's Canopy shows nowhere; its Deflector's dish went with the
    old stock, Ryan's go of 28 October); hp_5 bare under the belly aft of the cannon (the Ram-air Scoop is the dorsal intake,
    detail, no mount). Ryan, 30 September: the cannon recessed behind the nose, a wide low
    oval bore, its fairing blended into the fuselage. Centred on z = 0 like the Kite."""
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
            # A class on a pod's nose: a round launcher for a rack, as a rocket pod; the wide
            # classes a little smaller so they sit on a pod rather than swallow it.
            POD_FITS = {"rack": ("rack_round", 0.75), "twin_barrel": 0.8, "blade": 0.8, "dish": 0.8}
            wz = wing_z(px)
            pz = wz - 1.0 - r - 2.0   # the pod hangs clear under the wing on a pylon
            b.box(s * px - 1.2, s * px + 1.2, -1.0, 7.0, pz + r - 0.5, wz - 0.6, "steel.plate", "pylon")
            n = (1 if s < 0 else 2) if k == 0 else (3 if s < 0 else 4)
            # The pod is airframe and stays when its gun is swapped (Ryan's go of 2 November: a
            # swap had taken the pod with it and hung the class under the wing, where the camera
            # lost it); the mount is the pod's nose, so a fitted class rides ahead of the wing.
            b.prism("y", s * px, 3.0, pz, r, 18.0, "steel.dark", 6, "pod")
            nose = (s * px, 12.0, pz)
            if n == 4:
                b.pin("hp_4", nose, scale=0.7, carries="", fits=POD_FITS)
                continue
            # Each stock gun is its class on the nose (Ryan, 11 November: no stock gun is built by hand).
            b.stock("hp_%d" % n, nose, {1: "barrel", 2: "barrel", 3: "twin_barrel"}[n], scale=0.7, carries={1: "overclocked_railgun", 2: "transonic_rifle", 3: "arc_fault_cannon"}[n], fits=POD_FITS)
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
       # Both nacelles thrust through the turn, the one swung down the hotter (Ryan, 31 October:
       # "Vector turn doesn't glow the boosters"; only the one swung down had lit, its exhaust
       # facing the ground, away from every camera).
       glow=[(["joint_nacelle_l"], [(0.8, 0.0), (1.3, 8.0), (2.4, 8.0), (2.9, 6.0), (3.9, 6.0), (4.5, 0.0)]),
             (["joint_nacelle_r"], [(0.8, 0.0), (1.3, 6.0), (2.4, 6.0), (2.9, 8.0), (3.9, 8.0), (4.5, 0.0)])])
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
    # The halo's trial machine (Ryan, 30 October, of a real bloom for lit parts: "Sure, let's try
    # it"): the nacelles' boosters, hot as every machine's are, and the cannon, its vents and bore
    # (31 October: "the cannon is hot since it's a heat cannon"; the spine's cells "aren't vents").
    b.halo = ["vent_glow", "barrel_groove", "cannon_bore", "cannon_glow", ("joint_nacelle_l", KESTREL_HALO), ("joint_nacelle_r", KESTREL_HALO)]
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
    # Through a turn the nacelles split as in vector_turn (Ryan, 7 October, the eighteenth notes:
    # should it use its vectoring in its turns? Yes): each pitches by the turn, 15 degrees a
    # radian a second eased toward its limits, opposite ways, the left back and the right
    # forward turning right as the act turns it; the one pitching forward stops at its limit,
    # two past the hold, so in a hard turn the other swings back about 30 (b.gait's steer, on
    # the joint's own axis).
    b.gait(hold={"nacelle_l": -12.0, "nacelle_r": -12.0}, steer={"nacelle_l": -15.0, "nacelle_r": 15.0},
           glow={"parts": ["joint_nacelle_l", "joint_nacelle_r"], "k": KESTREL_BURN},
           body_hold=(0.0, 0.0, 0.0, 0.0, -5.0, 0.0))
    # Its cannon fires with an act of its own, the idle charge sped up (Ryan, 3 November, the second
    # notes: "charge spine up, cannon flares to life, then fades out fast as it discharges"; "the
    # booster flare can be cut from that fire animation as well as the nose lift"): the spine lights
    # tail to nose in under a second, the cannon flickers up to its full heat and the blow comes
    # there, a weapon that "won't be fired every round" being "worth a little longer time" (the
    # first notes), and everything is out within a third of a second of it, the shot kicking the
    # machine back a touch. The slice of the idle charge it fired with before held the spine lit
    # past the turn back (that day: "everything is still lit and doesn't fade until after its
    # returned").
    blow = 1.5
    shot_heat = [([("heat_%d" % (i + 1))], [(0.05, 0.0), (round(0.12 + 0.08 * i, 2), 0.0), (round(0.2 + 0.08 * i, 2), 26.0),
                                            (round(0.32 + 0.08 * i, 2), 16.0), (blow, 18.0), (blow + 0.3, 0.0)]) for i in range(9)]
    b.act("fire_cannon", 2.4, glow=shot_heat + [
        (["vent_glow", "barrel_groove", "cannon_bore", "cannon_glow"], [(0.7, 0.0), (0.85, 5.0), (0.95, 1.5), (1.05, 11.0), (1.15, 4.0), (1.4, 26.0),
                                                                        (blow, 26.0), (blow + 0.12, 7.0), (blow + 0.35, 0.0)])],
        body=[(blow, 0.0, 0.0, 0.0), (blow + 0.06, 0.0, -1.5, 0.0), (2.4, 0.0, 0.0, 0.0)], idle=False)
    b.fires = {"afterburner_cannon": ("fire_cannon", 0.0, 2.4, blow)}
    b.move(slide=0.3, bank=36.0, accel=0.9, heft=0.12, oversteer=0.3)   # larger and slower than the Kite: slides less, banks well (Ryan, 5 October: more); the nose a little into its corners (the fifth notes)

buzzard.maker = "kestrel"


# ---------------------------------------------------------------- the Swallowtail (31 October)
# Wainwright & Sutler's helicarrier, from the look Ryan picked on 13 October (the third of the
# multi-rotor's looks, tools/lowforge/looks/ws_multirotor.py's wslook_deck, docs/looks/
# ws_multirotor.png): a flat iron deck held up by four rotors at its corners, an island on the
# starboard edge, the crane at the stern with its hook under the hull. The second round (2
# November) sank the rotors into wells in housings swept out of the deck's corners.

def _swallowtail_boxes(b, specs, material, label):
    """Several boxes as one part, each (x0, x1, y0, y1, z0, z1): a set of lamps that light
    together draws in one call (a weld leaves a lit part whole), or a row of like pieces."""
    bm = bmesh.new()
    for x0, x1, y0, y1, z0, z1 in specs:
        vs = [bm.verts.new(v) for v in ((x0, y0, z0), (x1, y0, z0), (x1, y1, z0), (x0, y1, z0),
                                        (x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1))]
        for f in ((0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)):
            bm.faces.new([vs[i] for i in f])
    return b._finish(bm, material, label)


def _swallowtail_band(b, a, c, w, normal, label, material="steel.stripe"):
    """A flat strip from `a` to `c`, `w` wide, facing `normal`, wearing the tile's middle band
    across its width at square texels, so the hazard stripe's dashes run the length of it
    wherever the world grid falls: the landing square's frame, the hook block's sides."""
    a, c, up = Vector(a), Vector(c), Vector(normal).normalized()
    d = (c - a).normalized()
    n = up.cross(d).normalized()
    pts = [a - n * (w / 2.0), c - n * (w / 2.0), c + n * (w / 2.0), a + n * (w / 2.0)]
    s = w / 0.28
    return _quad(b, [tuple(p) for p in pts], material, label, (a - n * (w / 2.0 + 0.36 * s), n, d, up, (s, s)))


def _swallowtail_inset(pts, d):
    """An outline of (x, y) points, counter-clockwise, moved in by `d` all round (out, for a
    `d` under nought): each edge offset and its neighbours met, right for a convex outline and
    for the deck's gentle concave corners at its waist."""
    lines = []
    for i in range(len(pts)):
        (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % len(pts)]
        ex, ey = x1 - x0, y1 - y0
        k = d / math.hypot(ex, ey)
        lines.append(((x0 - ey * k, y0 + ex * k), (ex, ey)))
    out = []
    for i in range(len(lines)):
        (p, e), (q, f) = lines[i - 1], lines[i]
        t = ((q[0] - p[0]) * f[1] - (q[1] - p[1]) * f[0]) / (e[0] * f[1] - e[1] * f[0])
        out.append((p[0] + t * e[0], p[1] + t * e[1]))
    return out


def _swallowtail_hull(points):
    """The convex hull of (x, y) points, counter-clockwise (the monotone chain)."""
    pts = sorted(set(points))
    cross = lambda o, a, c: (a[0] - o[0]) * (c[1] - o[1]) - (a[1] - o[1]) * (c[0] - o[0])
    lower, upper = [], []
    for q in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], q) <= 0:
            lower.pop()
        lower.append(q)
    for q in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], q) <= 0:
            upper.pop()
        upper.append(q)
    return lower[:-1] + upper[:-1]


def _swallowtail_ngon(c, r, n=16, phase=math.pi / 16):
    """A regular `n`-gon of (x, y) points about `c`, counter-clockwise: a housing or its
    well (the phase matches a _tube's sixteen about z, so a lining sits square in its well)."""
    return [(round(c[0] + r * math.cos(phase + 2.0 * math.pi * k / n), 4), round(c[1] + r * math.sin(phase + 2.0 * math.pi * k / n), 4)) for k in range(n)]


def _swallowtail_sweep(c, r, start, end):
    """A rotor's housing swept into the deck: the outline from `start`, a point on the deck's
    edge, round the outside of the housing of radius `r` about `c` to `end`, counter-clockwise,
    its straight runs tangent to the housing (the convex hull of the three), so the deck's side
    flows out into the housing and back."""
    h = _swallowtail_hull([start, end] + _swallowtail_ngon(c, r))
    i, j = h.index(start), h.index(end)
    out = [h[i]]
    while i != j:
        i = (i + 1) % len(h)
        out.append(h[i])
    return out


def _swallowtail_rotor(b, name, cx, cy, cz, radius, hand, blades=4, chord=4.8, phase=0.4):
    """A great rotor drawn as blades, never a disc (the look's): a hub, long tapering blades
    with hazard tips (the stripe fitted along each tip's top, so every tip wears it), on a yaw
    joint so it can spin (b.spin); `hand` -1 pitches the blades for a rotor turning the other
    way."""
    with b.joint(name, (cx, cy, cz), axis="yaw"):
        b.prism("z", cx, cy, cz, 3.2, 3.0, "steel.dark", 8, "rotor_hub")
        b.prism("z", cx, cy, cz + 2.0, 1.8, 1.2, "steel.plate", 8, "hub_cap")
        for k in range(blades):
            a = phase + k * 2.0 * math.pi / blades
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(a, 4, "Z") @ Matrix.Rotation(0.12 * hand, 4, "Y")
            tip = radius * 0.82
            b.loft([(2.5, rect(0.0, chord, -0.55, 0.55)), (tip, rect(0.0, chord * 0.8, -0.45, 0.45))], "steel.dark", "blade", m)
            b.loft([(tip, rect(0.0, chord * 0.8, -0.45, 0.45)), (radius, rect(0.0, chord * 0.75, -0.4, 0.4))], "steel.dark", "blade_tip", m)
            _swallowtail_band(b, tuple(m @ Vector((0.0, tip + 0.1, 0.5))), tuple(m @ Vector((0.0, radius - 0.1, 0.45))), chord * 0.72,
                              tuple(m.to_3x3() @ Vector((0.0, 0.0, 1.0))), "blade_band")


def swallowtail(b):
    """Wainwright & Sutler "Swallowtail" (Pattern 20 Field Headquarters): the helicarrier, a
    muster its pieces spend (Ryan's go, 21 October; its brief: git show 5d989be:docs/briefs/
    ws_multirotor.md). The maker's first tier three, an assault flyer: "the apex of
    steampunk-silly military technology" (Ryan, 20 October), a mobile headquarters that
    carries the squad, directs its fire, refuels it and gives it a lift. First cut, 31 October,
    from the look Ryan picked on 13 October (the helicarrier deck, wslook_deck in
    tools/lowforge/looks/ws_multirotor.py) and his to-do line: a long flat iron deck with a
    blunt bow on a keel of riveted slab sides banded in the livery, a livery coaming round
    its edge so the maker's brown reads from above, a centre line in hazard dashes and a
    landing square framed in hazard stripes aft to port; a rotor at each corner, drawn as
    blades, always turning, the diagonal pairs against each other. Second round, 2 November
    (Ryan, of the first cut's rings on arms: "the fans look tacked on. The overall shape is
    good, but it's a barge with fans glued to the side right now"): each rotor turns in a
    well through the deck, its housing swept out of the deck's corner by straight runs
    tangent to it, so the deck's plate, its edge and its coaming carry round the four, and
    under each housing a sponson grows out of the hull's side to carry the well below the
    deck, banded in the livery as the hull is; the wells lined in dark iron, a cross of
    girders under each hub. The island on the starboard edge,
    its bridge glazed round, a mast with a lamp and a stack on its roof. The four locked
    pieces modelled in, no pins: the Mooring Screens' projectors, a squared post at each
    corner of the deck with a cup on a mast that rises out of it, its lens banked in the
    corona's blue-white and a rail of it along the coaming between them; the Spotting
    Flare's rack, three tubes stood near upright on the island's roof, a red flare round in
    each mouth; the Sutler's Hoist, the crane at the stern a little to starboard (Ryan, 15
    October: "as the look builds it"), its house and winch on a turntable, the jib swung aft
    past the stern and its hook block on a line hanging below the hull, the tell for the
    passive; and the Reveille Horn, a great horn on a post at the roof's aft corner, its long
    pipe flaring to a bell turned out over the deck toward the squad, the bell lined in the
    vents' heat so its mouth burns orange when it sounds. Mounts in the die's order: hp_1 the
    port bow gun (the stock's Howitzer as its barrel class), hp_2 the starboard bow (the Twin
    Autoguns), hp_3 bare on the port edge amidships (the Canopy shows nowhere), each on a
    turret on a bolted pedestal. It flies as a carrier: it faces its heading, drifts and
    slips through its turns, and never banks or pitches, under way or in its acts (Ryan, 2
    November: "it's a carrier, so it shouldn't bank at all, unlike other fliers. Drift and slip
    yes, but no bank and pitch"). Every number is a proportion Ryan may change; the look, the
    rig, the acts and the gait are his to judge running."""
    DECK = 27.0                # the flight deck's top
    # The hull: a keel under the deck, slab sides of riveted iron, its bottom corners
    # chamfered, blunt at the bow (its livery band goes on with the sponsons', below).
    keel = lambda w, z0, z1, c: [(-w / 2 + c, z0), (w / 2 - c, z0), (w / 2, z0 + c), (w / 2, z1), (-w / 2, z1), (-w / 2, z0 + c)]
    b.loft([(-47.0, keel(40.0, 11.0, 22.0, 4.0)), (34.0, keel(40.0, 11.0, 22.0, 4.0)), (52.0, keel(20.0, 15.0, 22.0, 2.0))], "steel.panel", "hull")
    # The plan: the deck's rectangle and blunt bow as the look has them, its corners swept out
    # into the four rotor housings (the fore pair from the waist and the bow's taper, the aft
    # pair from the waist and the stern), a well through each; the deck one plate round them.
    F, A, RH, RW = (37.0, 28.0), (37.0, -36.0), 18.5, 15.0     # the starboard housings' centres, their radius and their wells'
    right = (_swallowtail_sweep(A, RH, (20.0, -52.0), (27.0, -14.0)) + _swallowtail_sweep(F, RH, (27.0, 6.0), (20.0, 50.0)) + [(13.0, 60.0)])
    outline = right + [(-x, y) for x, y in reversed(right)]
    wells = [(sx * c[0], c[1]) for c in (F, A) for sx in (-1.0, 1.0)]
    at = lambda pts, z: [(x, y, z) for x, y in pts]
    for z in (22.0, DECK):
        _plate(b, at(outline, z), [at(_swallowtail_ngon(c, RW), z) for c in wells], "steel.plate", "deck")
    _rings(b, [at(outline, 22.0), at(outline, DECK)], "steel.plate", "deck", cap=False)
    # A sponson under each housing, out of the hull's side: walls standing from the deck's
    # underside to a chamfer, a floor round the well's mouth, the livery band carried round it.
    for c, roots in ((F, ((18.0, 2.0), (18.0, 34.0))), (A, ((18.0, -46.0), (18.0, -10.0)))):
        for sx in (-1.0, 1.0):
            cc = (sx * c[0], c[1])
            top = _swallowtail_hull([(sx * x, y) for x, y in roots] + _swallowtail_ngon(cc, RH - 0.6))
            low = _swallowtail_inset(top, 1.6)
            _rings(b, [at(low, 13.4), at(top, 16.0), at(top, 22.4)], "steel.panel", "sponson", cap=False)
            _plate(b, at(low, 13.4), [at(_swallowtail_ngon(cc, RW), 13.4)], "steel.panel", "sponson")
            band = _swallowtail_inset(top, -0.3)
            _rings(b, [at(band, 16.6), at(band, 19.6)], "livery.livery2", "band", cap=False)
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 20.0, s * 20.4))
        b.box(x0, x1, -10.5, 3.0, 16.6, 19.6, "livery.livery2", "band")
    # The coaming: a low livery rim round the deck's edge, the housings' with it.
    inner = _swallowtail_inset(outline, 1.6)
    _rings(b, [[(x, y, DECK - 0.01) for x, y in outline], [(x, y, DECK + 1.3) for x, y in outline],
               [(x, y, DECK + 1.3) for x, y in inner], [(x, y, DECK - 0.01) for x, y in inner]], "livery.livery2", "coaming", cap=False)
    # The deck's markings: the centre line in hazard dashes, the landing square aft to port
    # framed in hazard stripes.
    b.box(-1.0, 1.0, -48.0, 36.0, DECK, DECK + 0.3, "steel.stripe", "centre_line")
    LX0, LX1, LY0, LY1, LW = -17.0, -3.0, -40.0, -26.0, 2.6
    for y in (LY0, LY1):
        _swallowtail_band(b, (LX0 - LW / 2, y, DECK + 0.15), (LX1 + LW / 2, y, DECK + 0.15), LW, (0.0, 0.0, 1.0), "landing")
    for x in (LX0, LX1):
        _swallowtail_band(b, (x, LY0 + LW / 2, DECK + 0.15), (x, LY1 - LW / 2, DECK + 0.15), LW, (0.0, 0.0, 1.0), "landing")
    # The lamps: a pair on the bow, the tail lights on the stern.
    _swallowtail_boxes(b, [(s * 8.0 - 1.8, s * 8.0 + 1.8, 59.4, 60.7, 23.4, 26.4) for s in (-1.0, 1.0)], "amber.light", "bow_lamp")
    _swallowtail_boxes(b, [(s * 12.0 - 2.4, s * 12.0 + 2.4, -52.7, -51.6, 22.8, 26.2) for s in (-1.0, 1.0)], "amber.light", "tail_light")
    # The wells: each lined in dark iron from below the sponson's floor to a lip just proud of
    # the deck, a cross of girders under the hub, the rotor turning in it a little under the
    # deck's plane.
    for sx in (-1.0, 1.0):
        for tag, c, hand in (("f", F, -sx), ("a", A, sx)):
            cx, cy = sx * c[0], c[1]
            _tube(b, (cx, cy, 13.0), (cx, cy, DECK + 0.4), RW + 0.2, RW - 0.6, 16, "steel.dark", "well", floor=False, phase=math.pi / 16)
            _swallowtail_boxes(b, [(cx - 1.3, cx + 1.3, cy - RW + 0.4, cy + RW - 0.4, 21.4, 23.0), (cx - RW + 0.4, cx + RW - 0.4, cy - 1.3, cy + 1.3, 21.4, 23.0)],
                               "steel.dark", "well_girder")
            _swallowtail_rotor(b, "rotor_%s%s" % ("l" if sx < 0 else "r", tag), cx, cy, 24.5, 14.0, hand)
    # The island on the starboard edge: a riveted block, the bridge glazed round under its roof.
    IX0, IX1, IY0, IY1, ITOP = 16.0, 26.0, -14.0, 12.0, 42.0
    b.box(IX0, IX1, IY0, IY1, DECK, ITOP, "steel.panel", "island")
    b.box(IX0 - 0.3, IX1 + 0.3, IY0 + 1.2, IY1 - 1.2, 36.6, 40.2, "glass.glass", "bridge")
    b.box(IX0 + 1.2, IX1 - 1.2, IY0 - 0.3, IY1 + 0.3, 36.6, 40.2, "glass.glass", "bridge")
    b.box(IX0 - 0.6, IX1 + 0.6, IY0 - 0.6, IY1 + 0.6, ITOP, ITOP + 1.2, "steel.plate", "island_roof")
    # On the roof: the mast with its lamp and a yard, the stack aft to starboard.
    b.prism("z", 21.0, -2.0, ITOP + 7.0, 0.9, 12.0, "steel.dark", 6, "island_mast")
    b.box(17.4, 24.6, -2.5, -1.5, ITOP + 9.0, ITOP + 9.8, "steel.dark", "yard")
    b.box(19.8, 22.2, -3.2, -0.8, ITOP + 12.6, ITOP + 15.0, "amber.light", "mast_lamp")
    b.box(21.4, 25.8, -13.0, -6.6, ITOP + 1.2, ITOP + 8.5, "steel.dark", "stack")
    b.box(21.0, 26.2, -13.4, -6.2, ITOP + 8.5, ITOP + 9.4, "steel.plate", "stack_cap")
    # The Spotting Flare (fixed, no pin): a rack of three tubes in a cradle on the roof's fore
    # end, stood near upright and leaning forward, a red flare round in each mouth on its own
    # slide (fire_1 to fire_3), which it pops out of the tube burning to fire and draws back
    # spent; the rack rears to the upright first.
    FX, FY, FZ = 21.0, 6.0, ITOP + 1.2
    b.box(FX - 5.0, FX + 5.0, FY - 3.4, FY + 3.4, FZ, FZ + 1.4, "steel.dark", "flare_base")
    with b.joint("elev_flare", (FX, FY, FZ + 2.6), limits=(-5.0, 25.0)):
        rack = Matrix.Translation((FX, FY, FZ + 2.6)) @ Matrix.Rotation(math.radians(70.0), 4, "X")
        along = rack.to_3x3() @ Vector((0.0, 1.0, 0.0))
        for s in (-1.0, 1.0):
            x0, x1 = sorted((s * 5.0, s * 5.9))
            b.box(x0, x1, -2.4, 7.0, -2.6, 2.6, "livery.livery2", "flare_cheek", rack)
        b.box(-5.0, 5.0, -1.8, 0.0, -2.4, 2.4, "steel.dark", "flare_cradle", rack)
        for k, x in enumerate((-3.3, 0.0, 3.3)):
            _tube(b, tuple(rack @ Vector((x, -1.8, 0.0))), tuple(rack @ Vector((x, 7.4, 0.0))), 1.65, 1.35, 8, "steel.dark", "flare_tube", phase=math.pi / 8)
            with b.joint("fire_%d" % (k + 1), tuple(rack @ Vector((x, 0.0, 0.0))), slide=tuple(along)):
                b.loft([(1.6, _poly(1.25, 8, math.pi / 8)), (7.0, _poly(1.25, 8, math.pi / 8))], "amber.ember", "flare_round_%d" % (k + 1), rack @ Matrix.Translation((x, 0.0, 0.0)))
        b.box(-5.0, 5.0, 3.6, 4.8, -1.9, 1.9, "steel.dark", "flare_strap", rack)
        # The flares it fires (Ryan, 4 November: "Go for some micro models and let's see what they
        # look like"): from each round's tip at the top of its pop a burning star flies up and out
        # over the bow, the three fanned a little apart, slowing as it climbs and curving over, then
        # hangs there sinking as under its chute, lit and haloed, until it dies and is gone; the
        # round left in its tube goes dark as the star leaves (the act's burn). Made at the rack's
        # rest, so each line is turned back the twenty degrees the rack rears to fire.
        for k, x in enumerate((-3.3, 0.0, 3.3)):
            a, el = math.radians((k - 1) * 14.0), math.radians(62.0)
            line = Matrix.Rotation(math.radians(-20.0), 3, "X") @ Vector((math.sin(a) * math.cos(el), math.cos(a) * math.cos(el), math.sin(el)))
            tip = rack @ Vector((x, 17.0, 0.0))
            with b.launch("spotting_flare", tuple(tip), tuple(line), reach=40.0, seconds=0.85, delay=round(1.04 + 0.5 * k, 2),
                          ease="out", drop=8.0, hang=1.5, sink=6.0, fade=0.35, light=16.0):
                # A ball of a star, so its halo grows round (a short prism's grew as a frosted box).
                b.loft([(y, _poly(r, 8, math.pi / 8)) for y, r in ((-2.2, 0.5), (-1.5, 1.7), (0.0, 2.3), (1.5, 1.7), (2.2, 0.5))], "amber.ember", "flare_star",
                       Matrix.Translation(tip) @ pin_frame(line).to_4x4())
    # The Reveille Horn (fixed, no pin): a great horn on a post at the roof's aft corner to
    # port, a long pipe flaring to a wide bell turned out over the deck toward the squad and a
    # little up, so its profile reads from above and behind; it swings on the post, its throat
    # lit when it sounds.
    HX, HY, HZ = 18.6, -9.6, ITOP + 1.2
    b.prism("z", HX, HY, HZ + 0.5, 2.6, 1.0, "steel.dark", 8, "horn_ring", phase=math.pi / 8)
    with b.joint("horn", (HX, HY, HZ + 1.0), axis="yaw", limits=(-60.0, 60.0)):
        b.prism("z", HX, HY, HZ + 2.6, 1.3, 3.2, "steel.plate", 6, "horn_post")
        up = Matrix.Translation((HX, HY, HZ + 4.6)) @ Matrix.Rotation(math.pi / 2, 4, "Z") @ Matrix.Rotation(math.radians(14.0), 4, "X")
        bell = [(-1.6, 1.0), (5.0, 1.15), (8.0, 1.8), (10.5, 3.0), (12.0, 4.6), (12.8, 6.0)]
        b.loft([(y, _poly(r, 12)) for y, r in bell], "livery.livery2", "horn_bell", up, cap=False)
        b.loft([(-1.6, _poly(1.0, 12)), (-1.4, _poly(1.0, 12))], "steel.dark", "horn_cap", up)
        for y0 in (0.6, 4.2):
            b.loft([(y0, _poly(1.5, 12)), (y0 + 1.0, _poly(1.5, 12))], "steel.dark", "horn_collar", up)
        # The bell's lining: the vents' heat, near black at rest and burning orange when it
        # sounds, so the whole mouth lights to whoever it faces.
        b.loft([(y, _poly(r * 0.9, 12)) for y, r in bell if y >= 5.0], "amber.heat", "horn_throat", up, cap=False)
        b.loft([(5.0, _poly(1.0, 12)), (5.1, _poly(1.0, 12))], "amber.heat", "horn_throat", up)
    # The Sutler's Hoist (fixed, no pin): the crane at the stern a little to starboard. A
    # turntable, the house on it with the winch drum across its back, a stout mast; the jib
    # pinned at the mast's head, swung aft past the stern and falling a little to its sheave;
    # the hook block on its line under the sheave, hanging below the hull. The line is two:
    # the upper from the sheave, the lower with the block, sliding along it as the hook drops.
    CX, CY = 8.0, -43.0
    b.prism("z", CX, CY, DECK + 0.6, 4.8, 1.2, "steel.dark", 8, "crane_ring", phase=math.pi / 8)
    with b.joint("crane", (CX, CY, DECK + 1.2), axis="yaw", limits=(-100.0, 100.0)):
        b.box(CX - 3.8, CX + 3.8, CY - 2.0, CY + 6.0, DECK + 1.2, DECK + 7.0, "steel.panel", "crane_house")
        b.box(CX - 3.4, CX + 3.4, CY - 1.6, CY + 5.6, DECK + 7.0, DECK + 7.6, "livery.livery2", "crane_roof")
        b.prism("x", CX, CY + 3.6, DECK + 9.4, 1.8, 6.0, "steel.dark", 8, "winch")
        for s in (-1.0, 1.0):
            b.prism("x", CX + s * 3.2, CY + 3.6, DECK + 9.4, 2.4, 0.6, "livery.livery2", 8, "winch_flange")
        b.prism("z", CX, CY - 1.0, DECK + 11.0, 1.6, 8.0, "steel.dark", 6, "crane_mast")
        b.box(CX - 1.4, CX + 1.4, CY - 2.9, CY - 2.6, DECK + 12.0, DECK + 14.0, "amber.light", "crane_lamp")
        heel = Vector((CX, CY - 1.0, DECK + 15.0))
        with b.joint("jib", tuple(heel), limits=(-15.0, 20.0)):
            fall = math.radians(12.0)
            tip = heel + Vector((0.0, -math.cos(fall), -math.sin(fall))) * 22.0
            _beam(b, tuple(heel), tuple(tip), _sq(3.4, 3.6), _sq(2.2, 2.2), "livery.livery2", "jib")
            b.box(tip.x - 1.6, tip.x + 1.6, tip.y - 1.6, tip.y + 1.6, tip.z - 1.6, tip.z + 1.6, "steel.dark", "sheave")
            HZ0 = 3.0      # the hook block's foot at rest
            with b.joint("hook", tuple(tip), limits={"pitch": (-30.0, 30.0), "roll": (-30.0, 30.0)}):
                b.prism("z", tip.x, tip.y, (tip.z + HZ0 + 18.0) / 2.0, 0.4, tip.z - HZ0 - 18.0, "steel.dark", 4, "crane_line")
                with b.joint("hook_drop", (tip.x, tip.y, HZ0 + 4.4), slide=(0.0, 0.0, 1.0)):
                    b.prism("z", tip.x, tip.y, HZ0 + 4.4 + 12.0, 0.34, 24.0, "steel.dark", 4, "crane_line")
                    b.box(tip.x - 2.2, tip.x + 2.2, tip.y - 2.2, tip.y + 2.2, HZ0 + 1.2, HZ0 + 4.4, "steel.dark", "hook_block")
                    for n_ in ((1.0, 0.0, 0.0), (-1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, -1.0, 0.0)):
                        nv = Vector(n_)
                        side = Vector((n_[1], -n_[0], 0.0))
                        cface = Vector((tip.x, tip.y, HZ0 + 2.8)) + nv * 2.25
                        _swallowtail_band(b, tuple(cface - side * 2.2), tuple(cface + side * 2.2), 3.2, n_, "hook_band")
                    b.box(tip.x - 0.8, tip.x + 0.8, tip.y - 0.8, tip.y + 0.8, HZ0 - 0.6, HZ0 + 1.2, "steel.dark", "hook")
                    b.box(tip.x - 0.8, tip.x + 0.8, tip.y - 2.6, tip.y - 2.2, HZ0 + 2.2, HZ0 + 3.6, "amber.light", "hook_lamp")
    # The Mooring Screens (fixed, no pin): a squared post at each corner of the deck, a cup on
    # a mast that rises out of it, its lens banked in the corona's blue-white; a rail of the
    # same along the coaming's inner edge between them and round the housings, inside each
    # well's lip, so the screens raised draw the deck's outline lit.
    for tag, x, y in (("fl", -22.0, 42.5), ("fr", 22.0, 42.5), ("al", -18.5, -45.5), ("ar", 18.5, -45.5)):
        b.box(x - 2.6, x + 2.6, y - 2.6, y + 2.6, DECK, DECK + 4.6, "steel.panel", "screen_post")
        b.box(x - 3.1, x + 3.1, y - 3.1, y + 3.1, DECK + 3.6, DECK + 4.6, "livery.livery2", "screen_collar")
        with b.joint("screen_" + tag, (x, y, DECK + 4.6), slide=(0.0, 0.0, 1.0)):
            b.prism("z", x, y, DECK + 3.35, 1.3, 8.7, "steel.dark", 6, "screen_mast")   # long enough to stay in its post raised
            b.loft([(DECK + 7.6, _poly(1.6, 8, math.pi / 8)), (DECK + 8.6, _poly(3.4, 8, math.pi / 8)), (DECK + 9.4, _poly(4.2, 8, math.pi / 8))],
                   "steel.plate", "screen_cup", Matrix.Translation((x, y, 0.0)) @ Matrix.Rotation(math.pi / 2, 4, "X"), cap=False)
            _disc(b, (x, y, DECK + 8.7), (0.0, 0.0, 1.0), 2.6, 8, "amber.spark", "screen_lens_" + tag, phase=math.pi / 8)
    rail, rail_in = _swallowtail_inset(outline, 1.75), _swallowtail_inset(outline, 2.95)   # 1.2 wide, between the coaming and a well's lip
    _rings(b, [at(rail, DECK + 0.05), at(rail, DECK + 0.6), at(rail_in, DECK + 0.6), at(rail_in, DECK + 0.05)], "amber.spark", "screen_rail", cap=False)
    # The mounts, bolted on and squared off: a pedestal, a dark ring, the turret on it. In the
    # die's order: hp_1 the port bow (the Howitzer as its barrel class), hp_2 the starboard
    # bow (the Twin Autoguns), hp_3 bare on the port edge amidships (the Canopy shows
    # nowhere). Each traverses outward.
    S = 0.85
    for k, x, y, shape, cid, lim in ((1, -9.5, 43.0, "barrel", "howitzer", (-10.0, 70.0)), (2, 9.5, 43.0, "twin_barrel", "twin_autoguns", (-70.0, 10.0)),
                                     (3, -19.0, 4.0, None, "", (-10.0, 70.0))):
        b.box(x - 5.0, x + 5.0, y - 5.5, y + 4.5, DECK, DECK + 2.4, "steel.panel", "pedestal")
        b.prism("z", x, y, DECK + 2.9, 4.4, 1.0, "steel.dark", 8, "mount_ring", phase=math.pi / 8)
        with b.joint("turret_%d" % k, (x, y, DECK + 3.4), limits=lim):
            b.box(x - 4.6, x + 4.6, y - 5.0, y + 3.0, DECK + 3.4, DECK + 7.0, "steel.plate", "turret")
            b.box(x - 4.7, x + 4.7, y - 5.1, y - 3.6, DECK + 3.4, DECK + 7.0, "livery.livery2", "turret_band")
            if shape:
                b.stock("hp_%d" % k, (x, y + 1.0, DECK + 7.0 + 4.0 * S), shape, scale=S, carries=cid)
            else:
                b.pad("hp_%d" % k, (x, y + 1.0, DECK + 8.0), scale=S, size=(7.0, 1.0))

    # Idle acts (four, loud, never in step; a heavy deck's servos, b.move). Degrees and
    # seconds; a key is (t, value) on the joint's own axis, (t, pitch, yaw, roll), or that
    # with a slide (dx, dy, dz) after it; a body key is (t, dx, dy, dz) or (t, dx, dy, dz,
    # yaw, pitch, roll); a glow key is (t, k), k the light added over rest (-1 dark).
    # The hoist: the crane slews out over the port quarter, the hook swinging behind it and
    # past as it stops, the jib dipping to reach; the hook drops with its lamp flashing and the
    # deck sinks as the load comes on, then it rises, the deck lifts back, and the crane slews
    # home, the hook swinging again. (A crane slewing clockwise leaves its hook to roll
    # negative.) The deck stays level throughout, as a carrier does.
    slack = lambda t, pitch, roll: (t, pitch, 0.0, roll)
    b.act("hoist", 9.0, {
        "crane": [(0.5, 0.0), (2.4, -55.0), (5.9, -55.0), (7.8, 0.0)],
        "jib": [(2.0, 0.0), (2.9, 9.0), (5.6, 9.0), (6.6, 0.0)],
        "hook": [slack(0.5, 0.0, 0.0), slack(1.2, 0.0, -7.0), slack(2.0, 0.0, -4.0), slack(2.4, -4.0, 2.0), slack(2.9, -9.0, 6.0), slack(3.5, -9.0, -3.0),
                 slack(4.2, -9.0, 1.5), slack(4.8, -9.0, 0.0), slack(5.6, -9.0, 0.0), slack(6.6, 0.0, 6.0), slack(7.8, 0.0, 2.0),
                 slack(8.3, 0.0, -4.0), slack(8.8, 0.0, 0.0)],
        "hook_drop": [(2.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (3.7, 0.0, 0.0, 0.0, 0.0, 0.0, -10.0), (4.5, 0.0, 0.0, 0.0, 0.0, 0.0, -10.0), (5.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)],
    }, body=[(2.6, 0.0, 0.0, 0.0), (3.8, 0.0, 0.0, -1.8), (4.5, 0.0, 0.0, -1.6), (5.6, 0.0, 0.0, 0.4), (6.3, 0.0, 0.0, 0.0)],   # it sinks as the load comes on, level
       glow=[(["crane_lamp"], [(0.2, 0.0), (0.5, 8.0), (7.9, 8.0), (8.5, 0.0)]),
             (["hook_lamp"], [(2.6, 0.0), (2.8, 10.0), (3.1, 1.0), (3.4, 10.0), (3.7, 1.0), (4.0, 10.0), (5.4, 10.0), (5.9, 0.0)])])
    # The screens: the posts' cups rise in turn round the deck, each lens flaring as it tops
    # out, the rail lighting the deck's outline; a flicker runs through them all, they hold,
    # and sink in turn as the deck, lifted a touch, settles.
    rise = lambda t0, t1: [(t0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (t0 + 0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0), (t1, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0), (t1 + 0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)]
    flare = lambda t0, t1: [(t0 + 0.4, 0.0), (t0 + 0.7, 12.0), (t0 + 1.0, 6.0), (2.7, 8.0), (2.85, 0.5), (3.0, 12.0), (3.15, 2.0), (3.4, 10.0), (t1, 10.0), (t1 + 0.7, 0.0)]
    b.act("screens", 7.0, {
        "screen_fl": rise(0.4, 4.8), "screen_fr": rise(0.6, 5.0), "screen_ar": rise(0.8, 5.2), "screen_al": rise(1.0, 5.4),
    }, body=[(0.6, 0.0, 0.0, 0.0), (1.9, 0.0, 0.0, 1.6), (4.9, 0.0, 0.0, 1.3), (6.4, 0.0, 0.0, 0.0)],
       glow=[(["screen_lens_fl"], flare(0.4, 4.8)), (["screen_lens_fr"], flare(0.6, 5.0)), (["screen_lens_ar"], flare(0.8, 5.2)), (["screen_lens_al"], flare(1.0, 5.4)),
             (["screen_rail"], [(1.4, 0.0), (1.9, 12.0), (2.7, 12.0), (2.85, 0.0), (3.0, 14.0), (3.15, 1.0), (3.4, 12.0), (4.9, 12.0), (5.9, 0.0)])])
    # The flare: the deck swings its bow a little toward the mark, the rack rears to the
    # upright and fires its three in turn, each round popping out of its tube white-hot as the
    # deck kicks, then drawn back spent and dark; the mast lamp blinks the mark; the rack
    # settles and the rounds come back lit. On a sharp servo, as a shot is.
    kick = lambda t: [(t, 0.0, 0.0, 0.0, 7.0, 0.0, 0.0), (t + 0.08, 0.0, -0.6, 0.6, 7.0, 0.0, 0.0), (t + 0.35, 0.0, 0.0, 0.0, 7.0, 0.0, 0.0)]   # a shove and a lift, never a pitch
    pop = lambda t: [(t, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)] + [(tt, 0.0, 0.0, 0.0) + tuple(round(v * d, 3) for v in along) for tt, d in ((t + 0.14, 11.0), (t + 0.75, 11.0), (t + 2.0, 0.0))]   # held 0.6 s at the top before it turns back
    burn = lambda t: [(t - 0.02, 0.0), (t + 0.08, 18.0), (t + 0.16, 4.0), (t + 0.45, -1.0), (5.2, -1.0), (5.8, 0.0)]   # its star away at the top of the pop (the launches), the round dark
    b.act("flare", 6.4, {
        "elev_flare": [(0.6, 0.0), (1.6, 20.0), (4.4, 20.0), (5.4, 0.0)],
        "fire_1": pop(1.9), "fire_2": pop(2.4), "fire_3": pop(2.9),
    }, body=[(0.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (1.5, 0.0, 0.0, 0.0, 7.0, 0.0, 0.0)] + kick(1.9) + kick(2.4) + kick(2.9) + [(4.4, 0.0, 0.0, 0.0, 7.0, 0.0, 0.0), (5.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)],
       heft=0.09, glow=[(["flare_round_1"], burn(1.9)), (["flare_round_2"], burn(2.4)), (["flare_round_3"], burn(2.9)),
                        (["mast_lamp"], [(3.3, 0.0), (3.45, 10.0), (3.65, 0.0), (3.85, 10.0), (4.05, 0.0), (4.25, 10.0), (4.9, 10.0), (5.5, 0.0)])])
    # Reveille: the horn swings aft over the deck and sounds, three blasts, the throat burning
    # and the island shuddering with each; the guns traverse out to their stations in turn,
    # the bow lamps up; the horn swings forward and sounds once more, and all stand down.
    blast = lambda t, n: [(t + 0.0, 0.0, 0.0, 0.0), (t + 0.08, 0.0, 0.0, 0.6), (t + 0.2, 0.0, 0.0, -0.4), (t + 0.34, 0.0, 0.0, 0.3), (t + n, 0.0, 0.0, 0.0)]   # a shudder up and down, level
    b.act("reveille", 8.0, {
        "horn": [(0.4, 0.0), (1.4, 28.0), (3.4, 28.0), (4.8, -30.0), (6.2, -30.0), (7.2, 0.0)],   # its mouth aft over the deck, then forward
        "turret_1": [(2.0, 0.0), (3.2, 35.0), (5.4, 35.0), (6.6, 0.0)],
        "turret_2": [(2.3, 0.0), (3.5, -35.0), (5.7, -35.0), (6.9, 0.0)],
        "turret_3": [(2.6, 0.0), (4.0, 45.0), (6.0, 45.0), (7.4, 0.0)],
    }, body=blast(1.5, 0.6) + blast(2.2, 0.6) + blast(2.9, 0.6) + blast(5.0, 0.9),
       glow=[(["horn_throat"], [(1.45, 0.0), (1.55, 220.0), (2.0, 160.0), (2.15, 20.0), (2.25, 220.0), (2.7, 160.0), (2.85, 20.0), (2.95, 220.0), (3.4, 180.0), (3.7, 0.0),
                                (4.95, 0.0), (5.05, 220.0), (5.8, 180.0), (6.1, 0.0)]),
             (["bow_lamp"], [(1.9, 0.0), (2.2, 8.0), (6.6, 8.0), (7.2, 0.0)])])
    # The rotors turn all the time, the diagonal pairs against each other, faster under way.
    for name, hand in (("rotor_lf", 1.0), ("rotor_rf", -1.0), ("rotor_la", -1.0), ("rotor_ra", 1.0)):
        b.spin(name, 400.0 * hand, 640.0 * hand)
    # Movement: a carrier's (Ryan, 2 November: "it shouldn't bank at all, unlike other fliers.
    # Drift and slip yes, but no bank and pitch"): heavy and slow to gather way, it faces its
    # heading, drifts off its path through a turn and steps its tail out, and the deck stays
    # level, no bank, no nose down under way, no nose up to stop; under way it rides a long
    # heave, two slow waves a stride so it never ticks, and nothing else.
    heave = lambda p: (round(p, 3), 0.0, 0.0, round(1.1 * math.sin(2.0 * math.pi * p) + 0.4 * math.sin(4.0 * math.pi * p + 1.0), 2))
    b.gait(stride=220.0, body=[heave(k / 12.0) for k in range(13)])
    b.move(slide=0.45, bank=0.0, accel=1.8, heft=0.28, oversteer=0.3)
    # Its flare and its equipment play slices of their acts as they fire and are used (Ryan, 31
    # October: the cheapest first; found unfired on 3 November): the Spotting Flare's launcher up
    # and its rounds away, the blow on the first; the Mooring Screens out and lit; the Sutler's
    # Hoist swinging its crane out and lowering the hook; the Reveille Horn turned and sounded.
    b.fires = {"spotting_flare": ("flare", 1.0, 3.6, 1.98), "mooring_screens": ("screens", 0.6, 3.6),
               "sutlers_hoist": ("hoist", 1.2, 5.6), "reveille_horn": ("reveille", 0.8, 3.6)}
    b.halo = [("flare_star", 2.0)]   # the stars it fires burn hot, haloed (the launches above)

swallowtail.maker = "wainwright_sutler"


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
    shoulders, forearms and knees. Its fixed fists (the Knuckle of Fury) are modelled in, with no pins.
    Third pass (Ryan, 30 September): a humanoid's arms, elbows bent and the spiked fists
    forward, no gun on the hand; a hip cannon in the Atlas way; traps like the Hulk's; the
    core's port striped like a vent. Mounts: hp_1 the waist cannon (the Plasma Arquebus, the
    Carbine renamed), hp_2 the right shoulder's mount, hp_3 and hp_4 two chest ports flanking
    the core; the Ward Plate stays on the left pauldron and the Entropy Condenser on the back
    as detail (armour and vents take no mount). Since the stock pass (22 October): the
    Blazethrower on the shoulder's mount where the Meteor Artillery's tubes rode, raised on a
    post clear of the pauldron, and the Retribution Thurible and the Oblation Mantle as dishes
    in the chest ports, each as its class shape (Ryan's go, 28 October)."""
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
    b.prism("y", 0.0, 13.6, 69.0, 5.8, 1.2, "amber.furnace", 8, "core_fire", phase=math.pi / 8)   # plain fire, no pattern (Ryan, 1 October), an even orange that reads hot (31 October)
    for z in (64.4, 67.0, 69.6, 72.2):
        b.box(-5.6, 5.6, 14.2, 15.2, z, z + 1.1, "steel.dark", "core_bar")
    # Two chest ports flanking the core high on the pectoral plates, recessed rings, each
    # carrying a stock dish as its class: the Retribution Thurible (hp_3 left) and the
    # Oblation Mantle (hp_4 right).
    for s, n in ((-1.0, 3), (1.0, 4)):
        b.prism("y", s * 12.0, 12.5, 73.0, 3.6, 2.0, "steel.dark", 8, "port_ring", phase=math.pi / 8)
        b.prism("y", s * 12.0, 12.6, 73.0, 2.6, 1.6, "bore.dark", 8, "port_throat", phase=math.pi / 8)
        b.stock("hp_%d" % n, (s * 12.0, 13.5, 73.0), "dish", scale=0.5, carries="retribution_thurible" if n == 3 else "oblation_mantle")
    # The helm: hooded, low between the shoulders, a visor slit (lit, as every Arsenal
    # cockpit's glass is: Ryan, 29 October; it flares in the roar and its other fierce acts,
    # the same day) and two horns.
    b.box(-8.0, 8.0, -7.0, 12.0, 82.0, 92.0, "steel.panel", "helm")   # runs back to meet the traps
    b.loft([(-4.0, rect(0.0, 18.0, 90.0, 94.0)), (14.0, rect(0.0, 14.0, 88.0, 92.0))], "steel.plate", "hood")
    b.box(-6.0, 6.0, 12.0, 13.0, 85.0, 87.0, "glass.glass", "visor")
    for s in (-1.0, 1.0):
        _spike(b, (s * 6.0, 2.0, 93.0), (s * 12.0, -2.0, 104.0), 2.2, "steel.dark", "horn")
    # Shoulders: asymmetric. The left a massive slab pauldron with a crown of spikes and
    # the Ward Plate riding on it (detail); the right a smaller, angled pauldron.
    L = -1.0
    b.loft([(-14.0, rect(L * 36.0, 20.0, 72.0, 86.0)), (10.0, rect(L * 36.0, 24.0, 70.0, 88.0))], "steel.panel", "pauldron_l")
    for k in range(4):
        y = -10.0 + k * 6.0
        _spike(b, (L * 40.0, y, 88.0), (L * 46.0, y - 2.0, 98.0 - k * 1.5), 2.2, "steel.dark", "pauldron_spike")
    b.box(L * 46.0, L * 28.0, -12.0, 8.0, 88.0, 91.0, "livery.livery2", "ward_plate")   # detail: armour takes no mount
    b.box(L * 44.0, L * 30.0, -10.0, 6.0, 91.0, 92.0, "steel.plate", "ward_inscription")
    b.loft([(-8.0, rect(30.0, 14.0, 74.0, 84.0)), (8.0, rect(30.0, 12.0, 74.0, 82.0))], "steel.plate", "pauldron_r")
    _spike(b, (32.0, 0.0, 84.0), (36.0, -2.0, 92.0), 1.8, "steel.dark", "pauldron_spike_r")
    # The right shoulder's mount behind the pauldron (hp_2): the stock's Blazethrower as its
    # class, forward on a post that lifts it clear of the pauldron, elevating there; the
    # Meteor Artillery's tubes rode this rack until the stock pass (Ryan's go, 28 October).
    b.box(20.0, 34.0, -20.0, -12.0, 64.0, 78.0, "steel.panel", "rack")
    b.box(24.0, 30.0, -18.0, -12.0, 78.0, 84.5, "steel.dark", "post")
    with b.joint("elev_shoulder", (27.0, -15.0, 87.7), limits=(-18.0, 16.0)):
        b.stock("hp_2", (27.0, -13.0, 87.7), "barrel", scale=0.8, carries="blazethrower")
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
    # The waist cannon (hp_1): a mount on the right of the waist, the stock's Plasma Arquebus
    # forward off it as its class (Ryan, 30 September: on the waist, not the hip; 11 November:
    # no stock gun is built by hand).
    b.box(13.0, 23.0, -7.0, 5.0, 51.0, 59.0, "steel.plate", "waist_mount")
    b.stock("hp_1", (18.0, 5.0, 55.0), "barrel", carries="plasma_arquebus")
    # The Entropy Condenser on the lower back, a dark block with lit slots (hp_4).
    b.box(-12.0, 12.0, -20.0, -10.0, 60.0, 74.0, "steel.dark", "condenser")   # detail: a vent takes no mount; up on the back (Ryan, 1 October)
    for z in (64.0, 68.0, 71.5):
        b.box(-9.0, 9.0, -20.8, -20.0, z, z + 1.5, "amber.fume", "condenser_slot")   # the Arsenal's sickly vent light (Ryan, 3 November)
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
          glow=[(["core_fire", "condenser_slot", "visor"], [(2.27, 0.0), (2.33, 13.0), (2.6, 4.0), (2.92, 3.0), (2.98, 16.0), (4.1, 9.0), (5.0, 0.0)])])   # the core and the visor flaring at each blow
    tracks, body = _planted(feet, [(1.2, -2.0, 0.0, 7.0), (3.8, -2.2, 0.0, 7.5), (5.2, 0.0, 0.0, 0.0)])
    tracks.update({
        "shoulder_l": [(1.2, 60.0, 60.0, 0.0), (3.8, 62.0, 62.0, 0.0), (5.0, 0.0, 0.0, 0.0)],
        "shoulder_r": [(1.2, 60.0, -60.0, 0.0), (3.8, 62.0, -62.0, 0.0), (5.0, 0.0, 0.0, 0.0)],
        "elbow_l": [(1.2, -20.0), (3.8, -22.0), (5.0, 0.0)],
        "elbow_r": [(1.2, -20.0), (3.8, -22.0), (5.0, 0.0)],
    })
    b.act("roar", 5.6, tracks, body=body,   # the arms flung wide and up, the body rearing back on its planted feet, the core blazing
          glow=[(["core_fire", "condenser_slot"], [(0.6, 0.0), (1.2, 10.0), (3.8, 10.0), (4.8, 0.0)]),
                (["visor"], [(0.5, 0.0), (0.95, 16.0), (1.3, 11.0), (2.4, 13.0), (3.6, 11.0), (4.6, 0.0)])])   # the visor flares as it rears and burns through the roar (Ryan, 29 October: "some flare during relevant animations, like roar")
    # The meteor, angrier: it stamps into a firing stance, leaning in and turned on its mark
    # (the turn the waist's, Ryan, 5 October: the feet slid round under it),
    # the right arm flung clear and the left fist thrust at the target, the shoulder gun
    # snapping up and loading hot, then two shots, each one kicking it and the body (the
    # Meteor Artillery's tubes until the stock pass; the act keeps its name).
    # The stance is a real one now (Ryan, 20 October: lateral motion for the bipeds, on the
    # funnel-web's planted footwork): the right foot steps back and out as the whole machine
    # turns ten degrees toward its mark on its planted left foot, braced, the waist's turn on
    # top of that; the feet stay through the shots and the right one steps home as it comes
    # back round (_footwork).
    feet6 = {sd: feet[i] for i, sd in enumerate(("l", "r"))}
    brace = lambda dz, pitch, yaw=-10.0: (0.0, 0.0, dz, yaw, pitch, 0.0)
    tracks, body = _footwork(feet6, [(0.3, (0.0,) * 6), (0.5, brace(-2.6, -4.0, -4.0)), (0.8, brace(-2.0, -3.2)), (2.4, brace(-2.2, -3.5)), (2.55, brace(-3.4, -2.0)),
                                     (2.9, brace(-2.2, -3.4)), (3.35, brace(-3.4, -2.0)), (3.7, brace(-2.2, -3.4)), (4.4, brace(-2.0, -3.0)), (4.7, brace(-2.0, -3.0, -8.0)),
                                     (5.4, (0.0,) * 6)],
                             [("r", 0.35, 0.75, ("under", 0.8, (5.0, -8.0)), 6.0), ("r", 4.6, 5.0, ("under", 5.4), 5.0)], until=5.6)
    tracks.update({
        "waist": _dense([(0.5, -3.0, -16.0, 0.0), (0.8, -2.0, -15.0, 0.0), (2.4, -2.0, -16.0, 0.0), (2.55, 2.0, -15.0, 0.0), (2.9, -2.0, -16.0, 0.0), (3.35, 2.0, -15.0, 0.0),
                         (3.7, -2.0, -16.0, 0.0), (4.4, -1.0, -15.0, 0.0), (5.4, 0.0, 0.0, 0.0)]),   # turned on its mark on the waist too; each shot kicks it back
        "elev_shoulder": _dense([(0.4, 0.0), (0.9, 16.0), (2.4, 15.0), (2.5, 6.0), (2.9, 15.0), (3.35, 6.0), (3.75, 15.0), (4.4, 15.0), (5.1, 0.0)]),
        "shoulder_r": _dense([(0.5, 10.0, -50.0, 0.0), (4.4, 12.0, -52.0, 0.0), (5.2, 0.0, 0.0, 0.0)]),
        "shoulder_l": _dense([(0.6, 58.0, -14.0, 0.0), (2.4, 60.0, -16.0, 0.0), (2.55, 55.0, -14.0, 0.0), (3.35, 55.0, -14.0, 0.0), (4.4, 58.0, -15.0, 0.0), (5.2, 0.0, 0.0, 0.0)]),
        "elbow_l": _dense([(0.6, 10.0), (4.4, 12.0), (5.2, 0.0)]),
    })
    b.act("raise_meteor", 5.6, tracks, body=body, ease="linear",
          glow=[(["sight"], [(0.6, 0.0), (1.0, 5.0), (1.3, 2.0), (1.6, 7.0), (1.9, 3.0), (2.2, 9.0), (2.4, 9.0), (2.5, 14.0), (2.8, 5.0), (3.3, 9.0),
                                  (3.35, 14.0), (3.7, 5.0), (4.6, 0.0)]),
                (["core_fire", "condenser_slot"], [(0.4, 0.0), (0.8, 6.0), (4.4, 6.0), (5.0, 0.0)]),
                (["visor"], [(2.45, 0.0), (2.5, 14.0), (2.9, 0.0), (3.3, 0.0), (3.35, 14.0), (3.75, 0.0)])])   # the visor flashing white-hot with each shot (a red light already at full red flares toward white: held in between it reads pink)
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
          glow=[(["core_fire", "condenser_slot", "visor"], [(1.65, 0.0), (1.8, 7.0), (2.25, 1.0), (3.5, 7.0), (3.95, 3.0), (4.35, 12.0), (5.05, 10.0), (5.95, 0.0)])])   # the core and the visor flaring at each crack and the slam
    # Squaring up (Ryan, 20 October: lateral motion for an angry boy on planted footwork; a
    # sideways pace was built first and looked like dancing, so this instead): something comes
    # at it from its left and it squares up to it, the left foot stamping out wide and back as
    # the whole machine turns on its planted right foot and drops into the stance, the fists up
    # before the chest, the torso leaning in and wound a little further on the waist, the core
    # burning while it glares; then the left foot stamps back round and it stands as it was.
    TURN = 26.0
    sq = lambda yaw, dz, pitch=0.0: (0.0, 0.0, dz, yaw, pitch, 0.0)
    tracks, body = _footwork(feet6, [(0.3, (0.0,) * 6), (0.5, sq(2.0, -0.5)), (0.95, sq(TURN, -3.0, -2.0)), (1.1, sq(TURN, -4.6, -2.5)), (1.4, sq(TURN, -3.4, -2.0)),
                                     (3.4, sq(TURN + 1.0, -3.6, -2.2)), (3.6, sq(TURN, -3.0, -1.5)), (4.05, sq(1.0, -1.0)), (4.2, sq(0.0, -2.2)), (4.7, (0.0,) * 6)],
                             [("l", 0.5, 0.95, ("under", 0.95, (-6.0, -6.0)), 7.0), ("l", 3.6, 4.05, ("under", 4.7), 6.0)], until=4.9)
    GUARD = (22.0, -50.0, 38.0, -2.0)   # the fists clenched before the chest, apart
    for side in ("l", "r"):
        g = GUARD if side == "l" else (GUARD[0], -GUARD[1], -GUARD[2], GUARD[3])
        tracks["shoulder_" + side] = _dense([(0.5, 0.0, 0.0, 0.0), (1.1, g[0], g[1], g[2]), (3.5, g[0] + 2.0, g[1], g[2]), (4.6, 0.0, 0.0, 0.0)])
        tracks["elbow_" + side] = _dense([(0.5, 0.0), (1.1, g[3]), (3.5, g[3] - 2.0), (4.6, 0.0)])
    tracks["waist"] = _dense([(0.5, 0.0, 0.0, 0.0), (1.2, -4.0, 8.0, 0.0), (3.4, -5.0, 11.0, 0.0), (3.7, -3.0, 6.0, 0.0), (4.6, 0.0, 0.0, 0.0)])   # leaning in, wound a little further round than the feet
    b.act("square_up", 5.2, tracks, body=body, ease="linear", heft=0.06,
          glow=[(["core_fire", "condenser_slot"], [(0.9, 0.0), (1.15, 9.0), (3.4, 9.0), (4.3, 0.0)]),
                (["visor"], [(0.9, 0.0), (1.15, 12.0), (3.4, 12.0), (4.3, 0.0)])])   # the visor glaring hotter than the core
    # Movement (Ryan, 4 October, the third pass: stomp and plod, MechWarrior and not Gundam,
    # no weight thrown side to side): a long heavy stride, each sabaton planted flat while
    # the body passes over it, lifted and stamped down; the arms swinging evenly against the
    # legs, the forearms carried up; the body dropping and nodding onto each foot.
    tracks, body, stride = _plant([
        {"hip": "hip_" + side, "knee": "knee_" + side, "ankle": "ankle_" + side, "at": legs[side], "phase": 0.0 if side == "l" else 0.5}
        for side in ("l", "r")], sweep=30.0, lift=8.0, crouch=0.5, dip=1.8, nod=1.2)
    tracks["shoulder_l"] = (_swing(5.0, 0.5), 0.0)   # a little swing (Ryan, 5 October: less arm movement; the plod is good)
    tracks["shoulder_r"] = (_swing(5.0, 0.0), 0.0)
    # The chest furnace and the condenser venting it out the back, hot and always lit (Ryan, 31
    # October: the chest "has to look HOT"; the rear vent "always on, and a little less than you
    # have it in the animations. It's an Arsenal signature, I think, a creepy glowing exhaust").
    b.halo = [("core_fire", 1.5), "condenser_slot"]
    # Hot at rest, really hot as the acts flare (Ryan, 31 October: "not burn crazy hot all the time. Just
    # like, hot, then really hot"); the vent "still too much" at eight on the lit tile's yellow, up from
    # three on its own sickly amber (3 November, the second notes: "Resting glow on the standard Arsenal
    # vents can come up").
    b.standing = {"core_fire": 3.5, "condenser_slot": 5.0}
    b.gait(stride=stride, tracks=tracks, hold={"elbow_l": 9.0, "elbow_r": 9.0}, body=body, ease="linear")
    # The punch (Ryan, 3 November: "Nemesis needs to actually punch, not pound"): from its guard, a
    # fist driven straight at its mark as the torso twists in behind it and the body leans onto it,
    # stopped dead at full reach, the core and the visor flaring on the blow, the other fist kept
    # up; then back to the guard and down. A jab with the left and a cross with the right, taking
    # turns as its fists fire, each winding up a third of a second before its blow. A weapon's
    # firing alone (idle=False): an angry boy shadow-boxing at rest would wear the read out.
    # The second notes the same day: "Nemesis punch can extend a bit more": the shoulder drives the
    # fist out at the blow (the pose's last number, a slide forward in world units), the torso twists
    # further in behind it and the body leans further onto it, the arm a touch higher and straight
    # (64 degrees up had read as a pound from above, the first notes).
    GUARD_P = (22.0, -50.0, 38.0, -2.0, 0.0)   # square_up's guard: the fists clenched before the chest
    CHAMBER = (14.0, -44.0, 34.0, 22.0, -1.5)  # the fist drawn back a little, the elbow cocked, the shoulder with it
    REACH = (52.0, -8.0, 4.0, 0.0, 3.5)        # the arm out at the mark and straight, the shoulder driven forward behind it
    for name, side, twist in (("jab", "l", -15.0), ("cross", "r", 20.0)):
        mir = (lambda p: p) if side == "l" else (lambda p: (p[0], -p[1], -p[2], p[3], p[4]))
        other = "r" if side == "l" else "l"
        mo = (lambda p: p) if other == "l" else (lambda p: (p[0], -p[1], -p[2], p[3], p[4]))
        rest = (0.0, 0.0, 0.0, 0.0, 0.0)
        keys = [(0.1, rest), (0.32, mir(GUARD_P)), (0.42, mir(CHAMBER))] + _slam(0.42, mir(CHAMBER), 0.62, mir(REACH)) + \
               [(0.8, mir(REACH)), (1.05, mir(GUARD_P)), (1.5, rest)]
        guard = [(0.1, rest), (0.32, mo(GUARD_P)), (1.1, mo(GUARD_P)), (1.5, rest)]
        tracks, body = _planted(feet, [(0.1, 0.0, 0.0, 0.0), (0.42, -0.6, 0.2, 1.2)] + [(t, *v) for t, v in _slam(0.42, (-0.6, 0.2, 1.2), 0.62, (2.4, -0.8, -4.5))] +
                                [(0.8, 2.0, -0.7, -4.0), (1.5, 0.0, 0.0, 0.0)])   # (forward, up, pitch): rocked back a touch, then onto the punch
        tracks["shoulder_" + side] = [(t, p2, y2, r2, 0.0, s2, 0.0) for t, (p2, y2, r2, e2, s2) in keys]
        tracks["elbow_" + side] = [(t, e2) for t, (p2, y2, r2, e2, s2) in keys]
        tracks["shoulder_" + other] = [(t, p2, y2, r2) for t, (p2, y2, r2, e2, s2) in guard]
        tracks["elbow_" + other] = [(t, e2) for t, (p2, y2, r2, e2, s2) in guard]
        tracks["waist"] = [(0.1, 0.0, 0.0, 0.0), (0.42, 0.0, -twist * 0.4, 0.0)] + [(t, *v) for t, v in _slam(0.42, (0.0, -twist * 0.4, 0.0), 0.62, (-3.0, twist, 0.0))] + \
                          [(0.8, -3.0, twist, 0.0), (1.5, 0.0, 0.0, 0.0)]   # cocked the other way, then twisted in behind the fist
        b.act(name, 1.7, tracks, body=body, heft=0.05, idle=False,
              glow=[(["core_fire", "condenser_slot", "visor"], [(0.58, 0.0), (0.63, 14.0), (0.9, 5.0), (1.3, 0.0)])])
    b.fires = {"knuckle_of_fury": [("jab", 0.3, 1.5, 0.62), ("cross", 0.3, 1.5, 0.62)]}   # its fists fire with a punch each, left and right in turn, its blow at full reach
    # The chest flares hotter than the vent and the visor it lights with (Ryan, 3 November, the second
    # notes: "Nemesis chest vent can get bumped up even more when it flares"), the vent cooler on its
    # brighter tile (_flare_scale).
    _flare_scale(b, "core_fire", CHEST_FLARE)
    _flare_scale(b, "condenser_slot", VENT_FLARE)
    b.move(accel=1.2, heft=0.24)

nemesis.maker = "arsenal"


def _musk_ox_prisms(b, specs, material, label):
    """Several low prisms as one part, each (axis, (cx, cy, cz), radius, length, sides, phase)
    laid as Build.prism lays one: a lit set that draws in one call (a weld leaves a lit part
    whole, so eleven lenses as eleven parts would be eleven draws), or a row of like pieces."""
    bm = bmesh.new()
    for axis, (cx, cy, cz), r, length, n, phase in specs:
        if axis == "y":
            m = Matrix.Translation((cx, cy, cz))
        elif axis == "x":
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(math.pi / 2, 4, "Z")
        else:
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(-math.pi / 2, 4, "X")
        rings = [[bm.verts.new(m @ Vector((r * math.cos(phase + 2.0 * math.pi * k / n), y, r * math.sin(phase + 2.0 * math.pi * k / n))))
                  for k in range(n)] for y in (-length / 2.0, length / 2.0)]
        for k in range(n):
            k2 = (k + 1) % n
            bm.faces.new([rings[0][k], rings[0][k2], rings[1][k2], rings[1][k]])
        bm.faces.new(rings[0])
        bm.faces.new(rings[1])
    return b._finish(bm, material, label)


def _musk_ox_fitted(b, corner, along, across, size, material, label):
    """One rectangle from `corner`, `size` = (across, along) long, wearing exactly one whole
    tile, so a banked fire (the ember) shows its hot middle and dark rim on the face whatever
    the world grid says: the Musk Ox's back-blasts and forge mouths."""
    o, al, ac = Vector(corner), Vector(along), Vector(across)
    w, h = size
    pts = [o, o + ac * w, o + ac * w + al * h, o + al * h]
    return _quad(b, [tuple(p) for p in pts], material, label, (o, al, ac, ac.cross(al).normalized(), (w, h)))


def _musk_ox_wheel(b, cx, cy, r, w, s):
    """One of the Musk Ox's big wheels across x, its outer face on side `s`: a ten-sided tyre,
    a pressed rim stepping out of the outer face, a hub proud of it, and five ribs across the
    rim so a turn reads from the side."""
    b.prism("x", cx, cy, r, r, w, "bore.tread", 10, "tyre", phase=math.pi / 10)
    b.prism("x", cx + s * 1.5, cy, r, r * 0.62, w - 2.0, "steel.plate", 10, "rim", phase=math.pi / 10)
    b.prism("x", cx + s * 2.0, cy, r, r * 0.28, w, "steel.dark", 8, "hub", phase=math.pi / 8)
    face = cx + s * (w / 2.0 + 0.5)   # the rim's outer face
    for k in range(5):
        a = math.radians(90.0 + 72.0 * k)
        p0 = (face + s * 0.4, cy + r * 0.3 * math.cos(a), r + r * 0.3 * math.sin(a))
        p1 = (face + s * 0.4, cy + r * 0.6 * math.cos(a), r + r * 0.6 * math.sin(a))
        _beam(b, p0, p1, _sq(0.8, 2.4), _sq(0.8, 1.8), "steel.dark", "rib")


def musk_ox(b):
    """Wainwright & Sutler "Musk Ox" (Pattern 24 Field Battery): the artillery, its guns fired
    from forged ammo (Ryan's go, 21 October; its brief: git show bc97727:docs/briefs/ws_artillery.md).
    Ryan's picture: "a cross between a Big Bertha, a M270 MLRS, and/or a truck-mounted MEADS
    launcher. Big. Big wheels", wide ("Wide is good"), the old cannon on the centreline and the
    high-tech guns on flank sponsons: the "high-tech" W&S design, "where they tried to resolve
    their inherent bias against energy weapons"; the brief's look, the energy guns fired from
    cartridges, a rack of glowing cells feeding the flanks and an act that ejects a spent one
    (the maker never trusted a reactor, so it put the lasers on cartridges). First cut, 31
    October, from his to-do line: a wide, low ironclad hull on four big bare wheels at its
    corners, as tall as the hull, the fronts steering; on the centreline the Shrapnel
    Recuperator (fixed, no pin), an old built-up howitzer, hooped, stepped and swelled at the
    muzzle under a slotted brake, its recuperator cylinders over the barrel, on a carriage that
    traverses a touch, elevates and recoils along its line; ahead of it a low cab with two visor
    slits, shell lockers beside it and a winch on the nose; aft, the Unrestricted Expenditure
    (fixed, no pin), an MLRS launcher of two big pods on a turntable, hinged at the tail to
    elevate, the tubes on their fronts and the back-blast banked on their backs, the forge's
    flue grilles either side of it; either side of the cannon a dark rack of six cells, each lit in its upper third in the
    Storm Petrel's electric white (the one lit colour on the machine that is no flame), piped
    across to a sponson on each flank between the wheels, a capacitor on its roof ringed with
    coils; behind each rack a mouth of the Desublimation Forge, banked fire, into which an act
    ejects a spent cell from the right rack and out of which a fresh one rises. Mounts in the
    die's order: hp_1 the left sponson's casemate gun (the stock's Thermal Ray as its class),
    hp_2 the right's (the Enfilade Beam), each on a mantlet that traverses; hp_3 and hp_4 bare,
    on rings on the sponsons' roofs behind them, superfiring (the Coolant Jacket and the Canopy
    show nowhere). The Quick Reload shows nowhere, a vent. Second round, 2 November, on Ryan's
    notes of the first ("missile racks can be bigger. There's things sitting on top of vents at
    the back. Horns aren't necessary."): the pods bigger, the flue grilles cleared (the forge's
    stack stood in one and the antenna's base on the other), the horns gone and their boss with
    them; the cells as they were, his question whether they track the ammo open. The look, the
    rig, the acts and the gait are Ryan's to judge running."""
    R, W = 17.0, 14.0          # the wheels: big (Ryan: "Big. Big wheels"), their tops level with the deck
    HX, AY = 44.0, 30.0        # the hubs across and the axles fore and aft
    DECK = 34.0                # the hull's top
    # The wheels, outside the chassis joint so they stay planted while the hull rocks over
    # them: each spins on its hub, the fronts on a knuckle that steers.
    for yw, fr in ((AY, "f"), (-AY, "r")):
        for s in (-1.0, 1.0):
            w = fr + ("l" if s < 0 else "r")
            hub = (s * HX, yw, R)
            if fr == "f":
                with b.joint("steer_%s" % w, hub, limits=(-25.0, 25.0)):
                    with b.joint("wheel_%s" % w, hub):
                        _musk_ox_wheel(b, hub[0], yw, R, W, s)
            else:
                with b.joint("wheel_%s" % w, hub):
                    _musk_ox_wheel(b, hub[0], yw, R, W, s)
    chassis = b.joint("chassis", (0.0, 0.0, R), limits={"pitch": (-5.0, 5.0), "roll": (-5.0, 5.0)}, swing=False)
    chassis.__enter__()
    # The hull: a wide, low casemate, its deck level, a steep glacis falling to a nose plate
    # between the front wheels; the axles under it. No fenders: the tyres stand bare, their tops
    # level with the deck, so the wheels read big from above (Big Bertha's are bare).
    b.loft([(-44.0, _case(66.0, 13.0, DECK, 5.0)), (30.0, _case(66.0, 12.0, DECK, 5.0)), (39.0, _case(62.0, 12.0, 21.0, 3.0)), (41.0, _case(60.0, 13.0, 17.0, 2.0))],
           "steel.panel", "hull")
    for yw in (AY, -AY):
        b.prism("x", 0.0, yw, R, 3.2, 2.0 * (HX - W / 2.0) + 1.0, "steel.dark", 6, "axle")
    # The nose: a winch drum across it between end plates over a bumper bar, the wagon-builder's,
    # a livery plate down the glacis's middle and a headlamp either side of it.
    glacis_z = lambda y: DECK - (y - 30.0) * 13.0 / 9.0
    b.box(-26.0, 26.0, 40.0, 43.0, 12.5, 15.5, "steel.dark", "bumper")
    b.prism("x", 0.0, 41.6, 18.6, 2.6, 20.0, "steel.dark", 6, "winch")
    on_glacis = lambda x0, x1, y0, y1, lift: [[(x0, y, glacis_z(y) - 0.6), (x1, y, glacis_z(y) - 0.6), (x1, y, glacis_z(y) + lift), (x0, y, glacis_z(y) + lift)] for y in (y0, y1)]
    for s in (-1.0, 1.0):
        b.box(min(s * 10.0, s * 11.4), max(s * 10.0, s * 11.4), 39.4, 43.6, 15.5, 21.8, "steel.plate", "winch_cheek")
        x0, x1 = sorted((s * 11.0, s * 19.0))
        _rings(b, on_glacis(x0 - 0.8, x1 + 0.8, 30.4, 34.6, 0.8), "steel.dark", "lamp_housing")
        _rings(b, on_glacis(x0, x1, 30.9, 34.1, 1.1), "amber.lit", "lamp")
    _rings(b, on_glacis(-8.0, 8.0, 30.4, 37.6, 0.5), "livery.livery2", "glacis_panel")
    # The cab: across the front of the deck under the cannon's barrel, its face raked, two
    # visor slits either side of the barrel's line, the radio's whip antenna up off its rear
    # corner. The bone horns and the boss they rose from are gone (Ryan, 2 November: "Horns
    # aren't necessary"; the boss without them was a mount for nothing).
    CABZ = 42.5
    b.loft([(14.0, rect(0.0, 36.0, DECK - 0.5, CABZ)), (25.0, rect(0.0, 36.0, DECK - 0.5, CABZ)), (30.0, rect(0.0, 34.0, DECK - 0.5, CABZ - 5.0))], "steel.panel", "cab")
    face_z = lambda y: CABZ - (y - 25.0)
    for x0, x1 in ((-15.0, -4.0), (4.0, 15.0)):
        _rings(b, [[(x0, y, face_z(y) - 0.5), (x1, y, face_z(y) - 0.5), (x1, y, face_z(y) + 0.5), (x0, y, face_z(y) + 0.5)] for y in (25.8, 28.4)],
               "glass.glass", "visor")
    # A shell locker on each front corner of the deck beside the cab, its lid in the livery.
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 21.0, s * 28.0))
        b.box(x0, x1, 12.5, 23.5, DECK, DECK + 4.0, "steel.panel", "locker")
        b.box(x0 + 0.6, x1 - 0.6, 13.1, 22.9, DECK + 4.0, DECK + 4.5, "livery.livery2", "locker_lid")
    # The antenna on the cab's left rear corner, where it stood on the left flue grille at the
    # tail until the second round (Ryan, 2 November: things sat on top of the vents at the back).
    b.box(-17.5, -14.5, 14.6, 17.6, CABZ, CABZ + 1.6, "steel.dark", "antenna_base")
    b.prism("z", -16.0, 16.1, CABZ + 11.6, 0.5, 20.0, "steel.dark", 4, "antenna")
    # The flanks: a sponson on each between the wheels, a riveted casemate standing above the
    # deck, its outer face bevelled top and bottom with a livery panel on it. The casemate gun
    # on a mantlet in its front face, traversing (hp_1 left, the Thermal Ray; hp_2 right, the
    # Enfilade Beam), high enough to fire over the front tyre; a bare mount on a ring on its
    # roof behind (hp_3 left, hp_4 right), superfiring over it; a capacitor along the roof's
    # inner edge ringed with two coils, banked dark and lit by the charge; three feeds across
    # from the cell rack into its inner face, a lit sight glass on each.
    prof = [(29.0, 14.0), (43.0, 14.0), (47.0, 20.0), (47.0, 40.0), (44.0, 46.0), (29.0, 46.0)]
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        pts = [(s * x, z) for x, z in (prof if s > 0 else prof[::-1])]
        b.loft([(-11.0, pts), (11.0, pts)], "steel.panel", "sponson")
        b.box(min(s * 47.0, s * 47.3), max(s * 47.0, s * 47.3), -8.5, 8.5, 23.0, 37.0, "livery.livery2", "sponson_panel")
        gx = s * 40.0
        with b.joint("turret_" + side, (gx, 10.0, 38.5), limits=(-15.0, 50.0) if s < 0 else (-50.0, 15.0)):
            b.box(gx - 4.0, gx + 4.0, 8.0, 12.6, 33.5, 43.5, "steel.plate", "mantlet")
            b.stock("hp_%d" % (1 if s < 0 else 2), (gx, 12.6, 38.5), "barrel", scale=0.85, carries="thermal_ray" if s < 0 else "enfilade_beam")
        ax = s * 39.5
        b.prism("z", ax, -4.0, 46.6, 4.6, 1.2, "steel.dark", 8, "aft_ring", phase=math.pi / 8)
        with b.joint("turret_%s_aft" % side, (ax, -4.0, 47.2), limits=(-20.0, 45.0) if s < 0 else (-45.0, 20.0)):
            b.prism("z", ax, -4.0, 48.0, 3.8, 1.6, "steel.plate", 8, "aft_mount", phase=math.pi / 8)
            b.pad("hp_%d" % (3 if s < 0 else 4), (ax, -4.0, 50.0), scale=0.85, size=(6.5, 1.2))
        cx = s * 32.0
        b.prism("y", cx, -2.0, 48.4, 2.2, 16.0, "steel.dark", 6, "capacitor")
        for yy in (-10.4, 6.4):
            b.prism("y", cx, yy, 48.4, 2.6, 0.8, "steel.plate", 6, "capacitor_cap")
        _musk_ox_prisms(b, [("y", (cx, yy, 48.4), 2.6, 1.8, 6, 0.0) for yy in (-6.0, 2.0)], "amber.spark", "coil_" + side)
        for yy in (2.5, -2.5, -7.5):
            b.prism("x", s * 27.0, yy, 38.5, 1.1, 4.4, "steel.dark", 6, "feed_pipe")
        _musk_ox_prisms(b, [("x", (s * 27.0, yy, 38.5), 1.5, 1.4, 6, 0.0) for yy in (2.5, -2.5, -7.5)], "amber.spark", "feed_" + side)
        # The cell rack beside the cannon: a dark iron tray with low walls, so the lit cells
        # stand out of a dark ground, two columns of three standing in it; the forge mouth
        # behind it, a box of low walls round a pit of banked fire.
        x0, x1 = sorted((s * 12.0, s * 25.0))
        b.box(x0, x1, -12.5, 6.5, DECK, DECK + 1.4, "steel.dark", "rack_tray")
        for ya, yb in ((5.0, 6.5), (-12.5, -11.0)):
            b.box(x0, x1, ya, yb, DECK, DECK + 6.0, "steel.dark", "rack_wall")
        for xa, xb in ((12.0, 13.4), (23.6, 25.0)):
            b.box(min(s * xa, s * xb), max(s * xa, s * xb), -11.0, 5.0, DECK, DECK + 6.0, "steel.dark", "rack_wall")
        # The walls low and the fire high in them, so the pit shows to a camera thirty degrees
        # down from behind (a deeper pit hid its whole floor behind its near wall).
        hx0, hx1 = sorted((s * 13.6, s * 24.4))
        b.box(hx0, hx1, -18.4, -17.0, DECK, DECK + 2.0, "steel.panel", "forge_wall")
        for xa, xb in ((13.6, 15.0), (23.0, 24.4)):
            b.box(min(s * xa, s * xb), max(s * xa, s * xb), -17.0, -12.5, DECK, DECK + 2.0, "steel.panel", "forge_wall")
        fx0, fx1 = sorted((s * 15.0, s * 23.0))
        _musk_ox_fitted(b, (fx0, -17.0, DECK + 1.3), (0.0, 1.0, 0.0), (1.0, 0.0, 0.0), (fx1 - fx0, 4.5), "amber.ember", "forge_mouth")
        if s > 0.0:
            b.landing("forge", (s * 19.0, -14.75, DECK + 0.2))   # the Shrapnel Recuperator's casings fall in here (below), down into the fire
    # The cells: a dark body each, its upper third a lit core; the right rack's rear outer cell
    # is the one an act ejects, on a joint at its middle so it tumbles about it. The right, since
    # the codex and the skirmish both show that flank, and the skirmish's camera, behind it,
    # sees the right forge mouth past the launcher (the left one it hides). Its core slides
    # down into its body as it is spent (the corona's own colour shows unlit, so a core that
    # only went dark flew pale), and up again out of sight, so a dark canister is thrown and
    # a lit cell comes back.
    CZ0, CZ1, LZ1 = DECK + 1.4, DECK + 7.0, DECK + 9.4
    seats = [(s * x, y) for s in (-1.0, 1.0) for x in (16.0, 21.0) for y in (2.5, -2.5, -7.5)]
    spent = (21.0, -7.5)
    kept = [p for p in seats if p != spent]
    _musk_ox_prisms(b, [("z", (x, y, (CZ0 + CZ1) / 2.0), 2.3, CZ1 - CZ0, 6, 0.0) for x, y in kept], "steel.dark", "cell")
    _musk_ox_prisms(b, [("z", (x, y, (CZ1 + LZ1) / 2.0), 2.15, LZ1 - CZ1, 6, 0.0) for x, y in kept], "amber.corona", "cell_lens")
    with b.joint("cell_eject", (spent[0], spent[1], (CZ0 + LZ1) / 2.0)):
        b.prism("z", spent[0], spent[1], (CZ0 + CZ1) / 2.0, 2.3, CZ1 - CZ0, "steel.dark", 6, "cell")
        with b.joint("cell_core", (spent[0], spent[1], CZ1), slide=(0.0, 0.0, 1.0)):
            b.prism("z", spent[0], spent[1], (CZ1 + LZ1) / 2.0, 2.15, LZ1 - CZ1, "amber.corona", 6, "cell_spent_lens")
    # The Shrapnel Recuperator: a carriage of two rails and cheeks on a ring, traversing a touch;
    # the cradle elevating on trunnions, its two recuperator cylinders over it; the barrel, its
    # breech block and its brake sliding in the cradle along their line (the recoil), a
    # built-up barrel stepped down at a hoop to the chase and swelled at the muzzle.
    CY, CZ = 8.0, 48.0         # the trunnions
    b.prism("z", 0.0, CY, DECK + 0.9, 9.5, 1.8, "steel.dark", 8, "gun_ring", phase=math.pi / 8)
    with b.joint("turret_cannon", (0.0, CY, DECK + 1.8), limits=(-14.0, 14.0)):
        for s in (-1.0, 1.0):
            x0, x1 = sorted((s * 5.8, s * 9.2))
            b.box(x0, x1, CY - 9.0, CY + 10.0, DECK + 1.8, DECK + 6.0, "steel.panel", "carriage")
            b.box(x0, x1, CY - 6.0, CY + 6.0, DECK + 6.0, CZ + 3.5, "steel.plate", "cheek")
            b.prism("x", s * 9.7, CY, CZ, 2.4, 1.0, "steel.dark", 6, "trunnion")
        b.box(-9.2, 9.2, CY + 6.5, CY + 10.0, DECK + 1.8, DECK + 5.0, "steel.panel", "carriage")
        b.box(-8.8, -6.2, CY + 2.5, CY + 5.0, CZ + 3.5, CZ + 5.0, "amber.light", "gun_sight")
        with b.joint("elev_cannon", (0.0, CY, CZ), limits=(0.0, 42.0)):
            b.box(-5.4, 5.4, CY - 5.0, CY + 15.0, CZ - 5.0, CZ + 4.6, "steel.panel", "cradle")
            for s in (-1.0, 1.0):
                b.prism("y", s * 2.6, CY + 6.0, CZ + 6.4, 1.8, 22.0, "steel.plate", 6, "recuperator")
                b.prism("y", s * 2.6, CY + 17.4, CZ + 6.4, 1.2, 0.8, "steel.dark", 6, "recuperator_cap")
            # What it fires (Ryan, 4 November: "Go for some micro models and let's see what they look
            # like"): the shell out of the muzzle at the shot, a lit tracer on its base, straight and at
            # one speed down the barrel's line; and as the barrel runs out again its spent casing out of
            # the breech, its mouth still hot, tumbling up and over into the right forge mouth (the
            # forge pulls the casings back as ammo: the piece's fantasy), which flares as it takes it
            # (fire_howitzer). The shell rides the elevation and leaves where the barrel points; the
            # casing rides the recoil and is thrown from wherever the breech stands, the engine taking
            # its line to the forge as it leaves, however the gun has turned.
            with b.launch("shrapnel_recuperator", (0.0, CY + 47.0, CZ), (0.0, 1.0, 0.0), reach=260.0, seconds=0.7, delay=0.75, ease="line"):
                b.loft([(CY + 44.0, _oct(CZ, 4.4, 4.4)), (CY + 48.6, _oct(CZ, 4.4, 4.4)), (CY + 50.6, _oct(CZ, 1.4, 1.4))], "steel.plate", "shell")
                b.loft([(CY + 43.4, _oct(CZ, 3.2, 3.2)), (CY + 44.0, _oct(CZ, 3.2, 3.2))], "amber.lit", "shell_tracer")
            with b.joint("recoil_cannon", (0.0, CY, CZ), slide=(0.0, 1.0, 0.0)):
                breech = Vector((0.0, CY - 10.6, CZ))
                toss = (Vector((19.0, -14.75, DECK + 0.2)) - breech + Vector((0.0, 0.0, 40.0))).normalized()   # the line launch() takes for the forge at rest
                with b.launch("shrapnel_recuperator", tuple(breech), tuple(toss), seconds=0.8, delay=1.0, ease="line", drop=40.0, spin=1080.0, light=10.0, lands="forge"):
                    # Dark iron, so it shows over the light deck, its open end still glowing.
                    frame = Matrix.Translation(breech) @ pin_frame(toss).to_4x4()
                    b.loft([(-4.0, _poly(2.4, 8, math.pi / 8)), (1.4, _poly(2.4, 8, math.pi / 8))], "steel.dark", "casing", frame)
                    b.loft([(1.4, _poly(2.4, 8, math.pi / 8)), (4.0, _poly(2.4, 8, math.pi / 8)), (4.3, _poly(1.8, 8, math.pi / 8))], "amber.ember", "casing_mouth", frame)
                b.box(-5.5, 5.5, CY - 10.0, CY - 4.0, CZ - 5.4, CZ + 5.4, "steel.panel", "breech")
                b.prism("x", 6.0, CY - 7.0, CZ, 2.0, 0.8, "steel.dark", 6, "breech_wheel")
                oc = lambda r: _oct(CZ, 2.0 * r, 2.0 * r)
                b.loft([(CY - 4.0, oc(4.3)), (CY + 20.0, oc(4.0)), (CY + 20.0, oc(3.5)), (CY + 40.0, oc(3.3)), (CY + 40.0, oc(3.9)), (CY + 44.0, oc(3.9))], "steel.dark", "barrel")
                b.loft([(CY + 18.5, oc(4.7)), (CY + 21.0, oc(4.7))], "steel.plate", "hoop")
                b.box(-4.6, 4.6, CY + 44.0, CY + 50.0, CZ - 4.2, CZ + 4.2, "steel.plate", "muzzle_brake")
                for s in (-1.0, 1.0):
                    b.box(min(s * 4.6, s * 5.0), max(s * 4.6, s * 5.0), CY + 45.0, CY + 49.0, CZ - 2.6, CZ + 2.6, "steel.dark", "brake_port")
                b.loft([(CY + 50.0, oc(2.7)), (CY + 50.15, oc(2.7))], "bore.dark", "bore")
    # The Unrestricted Expenditure: a turntable at the tail, a base on it, and two pods hinged
    # low at their tails between the base's brackets, the tube face on each pod's front, the
    # back-blast on its back, an arming lamp on its nose, livery down its outer side and on
    # its top, a strap over both. The second round's pods are bigger (Ryan, 2 November:
    # "missile racks can be bigger"): a third wider, a third taller and two longer than the
    # first cut's, the whole tail of the deck, the tubes one big tile to a face, so bigger
    # rockets and not more of them; the tallest thing on the machine at rest.
    TY = -32.0
    PZ0, PZ1 = DECK + 4.6, DECK + 18.6         # the pods' foot and top
    PY0, PY1 = -44.5, -20.5                    # their tails, flush with the rear plate, and their noses
    PX0, PX1 = 1.0, 16.5                       # each pod across, from the centreline out
    FACE = PZ1 - PZ0                           # the tube face: one tile, as tall as the pod
    b.prism("z", 0.0, TY, DECK + 0.9, 12.0, 1.8, "steel.dark", 8, "launcher_ring", phase=math.pi / 8)
    with b.joint("turret_racks", (0.0, TY, DECK + 1.8), limits=(-60.0, 60.0)):
        b.box(-17.5, 17.5, PY0 + 0.5, PY1 - 3.5, DECK + 1.8, DECK + 4.4, "steel.panel", "launcher_base")
        for s in (-1.0, 1.0):
            x0, x1 = sorted((s * (PX1 + 0.3), s * (PX1 + 1.8)))
            b.box(x0, x1, PY0 + 0.5, PY0 + 6.5, DECK + 4.4, PZ0 + 2.4, "steel.dark", "launcher_hinge")
            b.prism("x", s * (PX1 + 2.1), PY0 + 0.9, PZ0 + 0.4, 1.6, 0.8, "steel.plate", 6, "hinge_pin")
        # Hinged at the pods' heel, so they rise clear of the base and never dip into it.
        with b.joint("elev_racks", (0.0, PY0 + 0.4, PZ0 + 0.4), limits=(0.0, 50.0)):
            for s in (-1.0, 1.0):
                side = "l" if s < 0 else "r"
                x0, x1 = sorted((s * PX0, s * PX1))
                b.box(x0, x1, PY0, PY1, PZ0, PZ1, "steel.panel", "pod")
                cxp = s * (PX0 + PX1) / 2.0
                _missile_face(b, (cxp - FACE / 2.0, PY1 + 0.05, PZ0), Vector((0.0, 0.0, 1.0)), Vector((1.0, 0.0, 0.0)), Vector((0.0, 1.0, 0.0)), FACE, "pod_face")
                # Its rockets (Ryan, 4 November: "Go for some micro models"; the piece: "The rocket racks
                # emptied at once, every tube"): one behind each of the face's nine tubes (the missile
                # tile's three by three), out along the pod's line gathering speed, a lit tail on each,
                # the pod's nine in two bursts on its two back-blasts in the ripple, the middle and the
                # corners first. Each waits inside the pod, so it shows coming out of its tube.
                bursts = (3.08, 3.73) if s < 0 else (3.38, 4.03)   # the ripple's flashes on this pod's back-blast
                order = (4, 0, 8, 2, 6, 1, 7, 3, 5)
                for i, tube in enumerate(order):
                    tx = cxp + (tube % 3 - 1) * FACE * 21.0 / 64.0
                    tz = PZ0 + FACE * (11.0 + 21.0 * (tube // 3)) / 64.0
                    t0 = bursts[0] + 0.06 * i if i < 5 else bursts[1] + 0.06 * (i - 5)
                    y0 = PY1 - 8.5
                    with b.launch("unrestricted_expenditure", (tx, y0 + 4.0, tz), (0.0, 1.0, 0.0), reach=230.0, seconds=0.8, delay=round(t0 - 1.6, 3)):
                        b.loft([(y0, _hexr(tx, tz, 1.05)), (y0 + 6.6, _hexr(tx, tz, 1.05)), (y0 + 8.0, _hexr(tx, tz, 0.3))], "steel.plate", "rocket")
                        b.loft([(y0 - 4.2, _hexr(tx, tz, 0.15)), (y0, _hexr(tx, tz, 0.95))], "amber.exhaust", "rocket_tail")   # its flame, a cone back from the tail
                b.box(min(s * PX1, s * (PX1 + 0.3)), max(s * PX1, s * (PX1 + 0.3)), PY0 + 3.0, PY1 - 3.0, PZ0 + 2.0, PZ1 - 2.0, "livery.livery2", "pod_panel")
                b.box(cxp - 6.2, cxp + 6.2, PY0 + 3.0, PY1 - 5.0, PZ1, PZ1 + 0.3, "livery.livery2", "pod_panel")
                _musk_ox_fitted(b, (cxp + 6.5, PY0 - 0.1, PZ0 + 1.2), (0.0, 0.0, 1.0), (-1.0, 0.0, 0.0), (13.0, FACE - 2.4), "amber.ember", "blast_" + side)
                b.box(min(s * (PX1 - 3.0), s * (PX1 - 0.4)), max(s * (PX1 - 3.0), s * (PX1 - 0.4)), PY1 - 2.4, PY1 - 0.2, PZ1, PZ1 + 1.0, "amber.light", "arm_lamp")
            b.box(-(PX1 + 0.2), PX1 + 0.2, TY - 3.0, TY + 0.5, PZ1, PZ1 + 0.8, "steel.dark", "pod_strap")
    # The tail: the forge's flues in the deck either side of the launcher, clear of everything
    # (Ryan, 2 November: "There's things sitting on top of vents at the back": the forge's stack
    # stood in the right one and the antenna's base on the left one; the stack is gone and the
    # antenna is on the cab); on the rear plate two trail spades folded up on a hinge bar, a
    # hitch, the tail lights.
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 19.8, s * 27.6))
        b.box(x0, x1, -42.0, -22.0, DECK, DECK + 0.6, "steel.vent", "flue_grille")
        b.box(min(s * 24.0, s * 28.5), max(s * 24.0, s * 28.5), -44.8, -44.0, 27.0, 30.5, "amber.light", "tail_light")
        x0, x1 = sorted((s * 8.0, s * 20.0))
        b.box(x0, x1, -45.6, -44.0, 15.0, 29.0, "steel.plate", "spade")
    b.prism("x", 0.0, -45.0, 29.6, 1.2, 42.0, "steel.dark", 6, "spade_hinge")
    b.box(-2.0, 2.0, -48.5, -44.0, 15.0, 18.0, "steel.dark", "hitch")
    chassis.__exit__(None, None, None)

    # Idle acts (four, loud, never in step; a heavy battery's servos, b.move). Degrees and
    # seconds; a key is (t, value) on the joint's own axis, (t, pitch, yaw, roll), or that with
    # a slide (dx, dy, dz) after it; a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw,
    # pitch, roll); a glow key is (t, k), k the light added over rest (-1 dark).
    wheels = ("wheel_fl", "wheel_fr", "wheel_rl", "wheel_rr")
    ROLL = math.degrees(1.0 / R)   # wheel degrees a unit rolled
    # The spent cell: it goes dark in its seat, its core sinking into it, is kicked up out of the
    # rack, tumbles back over the rack's wall and drops into the forge mouth behind it, which
    # flares as it takes it; out of sight under the deck it rights itself, its core lit and up
    # again, and rises into the empty seat, a fresh one, the right sponson's coils flickering
    # as it feeds. On a sharp servo, as a kick is. The
    # path keeps the cell clear of the walls: upside down, end first, into the mouth, and every
    # pose it takes under the deck lies below it (the cell is eight long about its middle).
    b.act("eject_cell", 6.4, {
        "cell_eject": [(0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (1.1, 8.0, 0.0, -4.0, -0.2, -0.4, 9.0), (1.45, 70.0, 0.0, -10.0, -0.6, -3.0, 11.5),
                       (1.8, 140.0, 0.0, -12.0, -1.0, -6.0, 9.5), (2.1, 180.0, 0.0, -8.0, -1.2, -7.25, 5.0), (2.4, 180.0, 0.0, -4.0, -1.2, -7.25, -1.0),
                       (2.75, 180.0, 0.0, 0.0, -1.2, -7.25, -11.0), (3.4, 300.0, 0.0, 0.0, 0.0, 0.0, -11.0), (3.7, 360.0, 0.0, 0.0, 0.0, 0.0, -10.5),
                       (4.4, 360.0, 0.0, 0.0, 0.0, 0.0, 0.0)],
        "cell_core": [(0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (0.75, 0.0, 0.0, 0.0, 0.0, 0.0, -2.6), (3.3, 0.0, 0.0, 0.0, 0.0, 0.0, -2.6), (3.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)],   # the core 2.4 tall, sunk wholly under the body's top
        "chassis": [(1.0, 0.0, 0.0, 0.0), (1.15, 0.0, 0.0, 1.2), (1.5, 0.0, 0.0, 1.0), (2.2, 0.0, 0.0, 0.0)],
    }, heft=0.08, glow=[
        (["cell_spent_lens"], [(0.25, 0.0), (0.7, -1.0), (3.5, -1.0), (3.8, 0.0)]),
        (["forge_mouth"], [(2.2, 0.0), (2.45, 10.0), (2.8, 4.0), (3.2, 8.0), (3.9, 0.0)]),
        (["coil_r"], [(4.2, 0.0), (4.35, 7.0), (4.5, 1.0), (4.65, 8.0), (5.4, 0.0)]),
    ])
    # Laying the gun: the battery inches forward onto its mark, the wheels turning, the cab's
    # lamps up and the nose dipping as it stops; the Shrapnel Recuperator traverses a touch and
    # rises to a low angle, its sight lit; a test of its recoil, the barrel slammed back along
    # its line and the recuperator easing it home as the hull squats on its tail; then up to a
    # howitzer's angle, held, and down; and the battery backs onto its spot, tail lights lit.
    creep = 6.0
    roll = round(-creep * ROLL, 2)
    back = round(roll + ROLL, 2)   # the recoil shoves it back a unit
    lay_wheels = [(0.4, 0.0), (1.8, roll), (3.55, roll), (3.68, back), (4.4, roll), (7.4, roll), (8.8, 0.0)]
    b.act("lay_gun", 9.6, {
        **{w: lay_wheels for w in wheels},
        "turret_cannon": [(1.9, 0.0), (2.5, 10.0), (6.6, 10.0), (7.2, 0.0)],
        "elev_cannon": [(2.1, 0.0), (3.1, 14.0), (4.7, 14.0), (5.7, 34.0), (6.5, 34.0), (7.7, 0.0)],
        "recoil_cannon": [(3.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (3.6, 0.0, 0.0, 0.0, 0.0, -6.0, 0.0), (3.75, 0.0, 0.0, 0.0, 0.0, -6.0, 0.0), (4.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)],
        "chassis": [(1.6, 0.0, 0.0, 0.0), (1.95, -1.6, 0.0, 0.0), (2.3, -1.4, 0.0, 0.0), (2.9, 0.0, 0.0, 0.0), (3.55, 0.0, 0.0, 0.0), (3.65, 2.4, 0.0, 0.0), (3.9, 2.2, 0.0, 0.0), (4.7, 0.0, 0.0, 0.0),
                    (8.6, 0.0, 0.0, 0.0), (8.95, 1.2, 0.0, 0.0), (9.15, 1.1, 0.0, 0.0), (9.5, 0.0, 0.0, 0.0)],
    }, body=[(0.4, 0.0, 0.0, 0.0), (1.8, 0.0, creep, 0.0), (3.55, 0.0, creep, 0.0), (3.68, 0.0, creep - 1.0, 0.0), (4.4, 0.0, creep, 0.0), (7.4, 0.0, creep, 0.0), (8.8, 0.0, 0.0, 0.0)],
       heft=0.12, glow=[(["gun_sight"], [(1.9, 0.0), (2.3, 6.0), (7.0, 6.0), (7.6, 0.0)]),
                        (["lamp"], [(0.2, 0.0), (0.5, 6.0), (2.0, 6.0), (2.4, 0.0)]),
                        (["tail_light"], [(7.2, 0.0), (7.4, 6.0), (8.8, 6.0), (9.2, 0.0)])])
    # The ripple: the launcher rises on its hinge and swings out to the left, so its back-blasts
    # turn toward the skirmish's camera behind the right flank, the arming lamps blinking, and
    # fires its pods in turn, each back-blast flaring as the hull shrugs back from it; it swings
    # home and settles.
    b.act("ripple", 7.6, {
        "elev_racks": [(0.5, 0.0), (1.9, 34.0), (5.6, 34.0), (7.0, 0.0)],
        "turret_racks": [(1.7, 0.0), (2.7, 28.0), (4.7, 28.0), (5.7, 0.0)],
        "chassis": [(3.0, 0.0, 0.0, 0.0), (3.15, 1.3, 0.0, -0.5), (4.4, 1.5, 0.0, -0.6), (5.1, 0.0, 0.0, 0.0)],
    }, body=[(3.0, 0.0, 0.0, 0.0), (3.3, 0.0, -0.8, 0.0), (4.4, 0.0, -1.0, 0.0), (5.3, 0.0, 0.0, 0.0)],
       glow=[(["arm_lamp"], [(1.9, 0.0), (2.05, 8.0), (2.25, 0.5), (2.45, 8.0), (2.65, 0.5), (2.85, 8.0), (4.6, 8.0), (5.2, 0.0)]),
             (["blast_l"], [(3.0, 0.0), (3.08, 16.0), (3.4, 3.0), (3.65, 0.5), (3.73, 16.0), (4.05, 3.0), (4.6, 0.0)]),
             (["blast_r"], [(3.3, 0.0), (3.38, 16.0), (3.7, 3.0), (3.95, 0.5), (4.03, 16.0), (4.35, 3.0), (4.9, 0.0)])])
    # The charge: the cells draw down as their light runs out along the feeds into the
    # sponsons, whose coils burn hot; the casemate guns swing out, facing out as a musk ox
    # herd's ring does, the roof mounts after them, and the hull settles under the load; held,
    # home.
    b.act("charge", 7.8, {
        "turret_l": [(1.9, 0.0), (3.1, 40.0), (4.9, 40.0), (6.1, 0.0)],
        "turret_r": [(2.1, 0.0), (3.3, -40.0), (5.1, -40.0), (6.3, 0.0)],
        "turret_l_aft": [(2.5, 0.0), (3.5, 25.0), (4.7, 25.0), (5.7, 0.0)],
        "turret_r_aft": [(2.7, 0.0), (3.7, -25.0), (4.9, -25.0), (5.9, 0.0)],
        "chassis": [(1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (2.4, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0), (5.8, 0.0, 0.0, 0.0, 0.0, 0.0, -1.1), (6.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)],
    }, glow=[(["cell_lens", "cell_spent_lens"], [(0.4, 0.0), (0.6, -0.7), (0.8, 0.0), (1.0, -0.7), (1.2, 0.0)]),
             (["feed_l"], [(0.6, 0.0), (0.75, 9.0), (0.95, 2.0), (1.1, 10.0), (5.8, 10.0), (6.6, 0.0)]),
             (["feed_r"], [(0.75, 0.0), (0.9, 9.0), (1.1, 2.0), (1.25, 10.0), (5.95, 10.0), (6.75, 0.0)]),
             (["coil_l"], [(1.0, 0.0), (1.5, 6.0), (2.2, 12.0), (5.8, 12.0), (6.8, 0.0)]),
             (["coil_r"], [(1.15, 0.0), (1.65, 6.0), (2.35, 12.0), (5.95, 12.0), (6.95, 0.0)])])
    # Movement: the wheels spin by their radius, the fronts steer into the turns, the hull
    # noses up a little pulling away; slow to get going, as a battery is.
    b.gait(wheels={w: R for w in wheels}, steer={"steer_fl": 12.0, "steer_fr": 12.0}, rock=2.5)
    b.move(accel=1.8, heft=0.24)
    # Its guns and its reload fire (Ryan, 31 October: the cheapest first; found unfired on 3
    # November): the Unrestricted Expenditure with a slice of its ripple, the racks up and swung out
    # and every pod away, the blow on the first, at nothing in particular, so nothing aims it; the
    # Quick Reload with a slice of its cell ejection, the spent cell out and the forge cast; the
    # Shrapnel Recuperator with a short act of its own, since laying the gun creeps the whole
    # machine forward: the turret onto its mark (b.aims), the barrel up, the shot and the barrel's
    # recoil, the chassis rocking and the hull shoved back.
    b.act("fire_howitzer", 3.0, {
        "elev_cannon": [(0.1, 0.0), (0.55, 18.0), (1.3, 18.0), (2.0, 0.0)],
        "recoil_cannon": [(0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (0.75, 0.0, 0.0, 0.0, 0.0, -6.0, 0.0), (0.85, 0.0, 0.0, 0.0, 0.0, -6.0, 0.0),
                          (1.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)],
        "chassis": [(0.7, 0.0), (0.78, 2.4), (0.95, 2.2), (1.7, 0.0)],
    }, body=[(0.72, 0.0, 0.0, 0.0), (0.8, 0.0, -1.0, 0.0), (1.6, 0.0, 0.0, 0.0)], heft=0.1, idle=False,
       glow=[(["gun_sight"], [(0.1, 0.0), (0.3, 6.0), (1.5, 6.0), (2.0, 0.0)]),
             (["forge_mouth"], [(1.72, 0.0), (1.86, 10.0), (2.15, 4.0), (2.45, 8.0), (2.95, 0.0)])])   # the casing in (its launch), as the cell does in eject_cell
    b.aims = {"shrapnel_recuperator": "turret_cannon"}
    b.fires = {"shrapnel_recuperator": ("fire_howitzer", 0.0, 3.0, 0.75), "unrestricted_expenditure": ("ripple", 1.6, 4.8, 3.08),
               "quick_reload": ("eject_cell", 0.7, 4.0)}

musk_ox.maker = "wainwright_sutler"


def ammit(b):
    """The Arsenal "Ammit" (Arsenal Instrument VII): a sinister digitigrade figure with four
    clawed arms, the middle pair a second pair of legs, a low snout of a cockpit. Second pass
    (Ryan, 29 September): the back spines lie flat along the spine; the upper arms rest
    higher and point forward, out of the way; the eyes are long glass strips down the snout,
    cockpit glass; no guns on the arms, shoulder cannons instead; the heel spurs grow from
    the ankle and the rear vent from the pelvis. The four Soulcutter Talons are the four
    clawed hands (fixed, no pins). Mounts: hp_1 the right shoulder cannon (Plasma Carbine),
    hp_2 the left shoulder cannon (Blazethrower), hp_3 and hp_4 two throat ports either
    side of the vent under the jaw, bare (Ryan, 30 September), the left carrying the stock's
    Oblation Mantle as a dish since the stock pass (hp_3; Ryan's go, 28 October); the Ward
    Plate on the back and the throat vent (the Entropy Condenser, heat exhaled) are detail; the plate lies flat
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
        b.box(-6.0, 6.0, -24.8, -24.0, z, z + 1.3, "amber.fume", "tail_slot")   # the Arsenal's sickly vent light (Ryan, 3 November)
    # The waist (Ryan, 5 October, the fifth notes: walkers turn with a waist, never by
    # sliding their feet round): the torso, the snout, the back and its guns and the upper
    # arms turn and lean on it over the pelvis. The middle arms stay off it: they carry the
    # machine's weight like legs, so they hang from the pelvis's frame.
    waist = b.joint("waist", (0.0, -10.0, 38.0), axis="yaw", limits={"yaw": (-20.0, 20.0), "pitch": (-12.0, 12.0), "roll": (-8.0, 8.0)}, swing=False)
    waist.__enter__()
    _rings(b, [_deck(26.0, 20.0, -8.0, 38.0, 4.0), _deck(32.0, 24.0, 0.0, 44.0, 5.0),
               _deck(34.0, 24.0, 8.0, 50.0, 5.0), _deck(26.0, 18.0, 14.0, 54.0, 4.0)], "steel.panel", "torso")
    # The snout: a long hexagonal muzzle out of the chest's top, two long glass strips down
    # its top ridges (the cockpit's eyes, lit as every Arsenal cockpit's glass is since 29
    # October, so they flare with the throat in its acts), a dark tip; under the jaw the
    # Entropy Condenser's throat vent, slotted and lit (hp_4).
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
    # forward and a little down: the left carries the stock's Oblation Mantle as its class
    # (hp_3), the right is bare (hp_4).
    for s, n in ((-1.0, 3), (1.0, 4)):
        px = s * 6.5
        _beam(b, (px, 24.0, 47.0), (px, 30.0, 45.0), _poly(3.0, 8), _poly(3.0, 8), "steel.dark", "throat_port")
        _beam(b, (px, 29.0, 45.3), (px, 31.0, 44.7), _poly(2.2, 8), _poly(2.2, 8), "bore.dark", "port_throat")
        if n == 3:
            b.stock("hp_3", (px, 30.0, 45.0), "dish", forward=(0.0, 0.949, -0.316), scale=0.45, carries="oblation_mantle")
        else:
            b.pin("hp_4", (px, 30.0, 45.0), forward=(0.0, 0.949, -0.316), carries="")
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
            # Each stock gun is its class (Ryan, 11 November: no stock gun is built by hand); the
            # Blazethrower's fire is its class's, a burn weapon's (31 October).
            b.stock("hp_1" if s > 0 else "hp_2", tuple(gun), "barrel", forward=tuple(U), carries="plasma_arquebus" if s > 0 else "blazethrower")
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
          glow=[(["throat_slot", "tail_slot", "eye_strip"], [(W1 - 0.15, 0.0), (W1 + 0.02, 12.0), (W1 + 0.3, 5.0), (W2 - 0.05, 4.0), (W2 + 0.02, 13.0), (W2 + 0.7, 3.0), (4.6, 0.0)])])
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
    b.act("raise_cannons", 9.2, tracks, body=body)
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
          glow=[(["throat_slot", "tail_slot", "eye_strip"], [(0.6, 0.0), (1.2, 6.0), (1.58, 11.0), (1.88, 12.0), (2.5, 10.0), (2.9, 3.0), (3.7, 0.0)])])
    # Circling (Ryan, 20 October: lateral motion for a creepy stalker, on the funnel-web's
    # planted footwork): it circles its prey with the snout kept on it, the body sliding round
    # an arc about a point ahead and turning to face it, the feet and the hands scuttling
    # sideways under it, the hands two short steps to a foot's one as in its walk (they stand
    # near straight and could not take a long one); two moves round to one side, a pause, and
    # two back (Ryan: one each way, through the centre, read weaker). Low and nose down, the
    # upper claws at their guard
    # with the talons spread and slowly working, the eyes lit and the throat breathing at the
    # pauses (_footwork: every hip and shoulder takes the yaw and roll that keep its end
    # planted and pointing where it landed).
    P, DZ, PITCH, SWING = 60.0, -2.5, -3.0, 12.0
    arc = lambda th: (P * math.sin(math.radians(th)), P * (1.0 - math.cos(math.radians(th))), DZ, th, PITCH, 0.0)

    def quarter(t0, th0, th1):
        """Steps and body keys sliding round from th0 to th1 over 1.4 s from t0: the feet once
        each, the hands twice, the side it moves toward leading."""
        lead = "r" if th1 > th0 else "l"
        trail = "l" if lead == "r" else "r"
        steps = [(lead, t0, round(t0 + 0.35, 3), ("under", "mid"), 5.0), (trail, round(t0 + 0.7, 3), round(t0 + 1.05, 3), ("under", "mid"), 5.0)]
        for k, hand in enumerate(("low_" + lead, "low_" + trail, "low_" + lead, "low_" + trail)):
            ta = round(t0 + 0.175 + k * 0.35, 3)
            steps.append((hand, ta, round(ta + 0.26, 3), ("under", "mid"), 4.0))
        return steps, [(t0, arc(th0)), (round(t0 + 1.4, 3), arc(th1))]
    steps, keys = [], [(0.4, (0.0,) * 6), (0.7, arc(0.0))]
    for t0, th0, th1 in ((0.7, 0.0, SWING), (2.3, SWING, 2.0 * SWING), (4.3, 2.0 * SWING, SWING), (5.9, SWING, 0.0)):
        st, ks = quarter(t0, th0, th1)
        steps += st
        keys += ks
    keys += [(7.6, arc(0.0)), (8.1, (0.0,) * 6)]
    tracks, body = _footwork({**hind, **{"low_" + k: v for k, v in mid_arms.items()}}, keys, steps, until=8.3)
    tracks["waist"] = _dense([(0.6, 0.0, 0.0, 0.0), (1.0, -4.0, 0.0, 0.0), (7.5, -4.0, 0.0, 0.0), (8.0, 0.0, 0.0, 0.0)])   # nose down, the body's turn keeps the snout on the prey
    for side, y in (("l", 1.0), ("r", -1.0)):
        tracks["shoulder_" + side] = _dense([(0.5, 0.0, 0.0, 0.0), (1.0, 30.0, 16.0 * y, 0.0), (7.5, 31.0, 17.0 * y, 0.0), (8.1, 0.0, 0.0, 0.0)])   # the threat's guard
        tracks["elbow_" + side] = _dense([(0.5, 0.0), (1.0, -22.0), (7.5, -23.0), (8.1, 0.0)])
        tracks["hand_" + side] = _dense([(0.5, 0.0), (1.0, -8.0), (7.5, -9.0), (8.1, 0.0)])
        for k, (w, (pitch, yaw)) in enumerate((("out", (44.0, 22.0 * y)), ("mid", (-40.0, 0.0)), ("in", (36.0, -8.8 * y)))):
            half = pitch + (-12.0 - pitch) * 0.5   # halfway to shut
            ks = [(0.5, 0.0, 0.0, 0.0), (round(1.0 + 0.2 * k, 3), pitch, yaw, 0.0)]
            t = 1.0 + 0.2 * k
            while t + 1.4 < 7.3:
                ks += [(round(t + 0.7, 3), half, yaw * 0.5, 0.0), (round(t + 1.4, 3), pitch, yaw, 0.0)]
                t += 1.4
            ks += [(7.5, pitch, yaw, 0.0), (8.1, 0.0, 0.0, 0.0)]
            tracks["talon_%s_%s" % (side, w)] = _dense(ks)
    b.act("circle", 8.6, tracks, body=body, ease="linear", heft=0.08,
          glow=[(["throat_slot", "tail_slot", "eye_strip"], [(0.8, 0.0), (1.2, 5.0), (3.7, 5.0), (3.95, 10.0), (4.3, 5.0), (7.3, 5.0), (7.55, 10.0), (7.9, 5.0), (8.3, 0.0)])])
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
    b.halo = ["tail_slot"]   # the vent at its tail (the condenser's twin), hot (Ryan, 31 October); the Blazethrower's fire is its class's
    b.standing = {"tail_slot": 5.0}   # the rear vent always lit, the Arsenal's creepy glowing exhaust, hot under its flares (Ryan, 31 October), brighter at rest on its own sickly amber (3 November, the second notes); the throat under the jaw is never seen
    b.gait(stride=stride, tracks=tracks, hold={"shoulder_l": 12.0, "shoulder_r": 12.0}, body=body, ease="linear")
    # Its talons fire with the threat's bite and the rear's rake in turn (Ryan, 3 November: it "can
    # also afford two different Claw animations since it's got 4 and will use them often"), each
    # holding its blow till the claw lands: the bite's first thrust, the rake's first cut.
    # Its Soul Siphon (12 November, a first cut for Ryan's eye: the piece fired with nothing) with
    # the threat's coil alone, the body drawing down as the throat, the eyes and the tail vent
    # light, cut before the bite.
    b.fires = {"soulcutter_talons": [("threat", 1.1, 2.6, 1.55), ("rear", 1.75, 3.3, W1)],
               "soul_siphon": ("threat", 0.4, 1.5)}
    _flare_scale(b, "tail_slot", VENT_FLARE)   # its rear vent's flares kept gold on its sickly amber (Ryan, 3 November, the second notes)
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
    _tube(b, (cx, cy, zfloor), (cx, cy, z1), r + 0.5, r - 0.8, 12, "steel.dark", "fan_duct", floor_material="amber.furnace", floor_depth=0.4)
    # A lining lit round the blades, just inside the duct's wall (Ryan, 31 October: "Anything to be
    # done about the stingray fans?"): the downwash blows under the wing, where no camera looks, so
    # the fan reads hot from above by its walls. The floor and the lining in the furnace's even
    # orange: the glow tile's hot centre, held always on, read yellow.
    _tube(b, (cx, cy, zfloor + 0.45), (cx, cy, z1 - 0.2), r - 0.82, r - 0.9, 12, "amber.furnace", "fan_lining", floor=False)
    zf = z1 - 1.9
    rotor = b.joint(joint, (cx, cy, zf), axis="yaw") if joint else None
    if rotor:
        rotor.__enter__()
    b.prism("z", cx, cy, zf, 2.0, 2.6, "steel.dark", 8, "fan_hub")
    b.prism("z", cx, cy, zf + 1.4, 1.2, 0.6, "steel.plate", 8, "hub_cap")
    ri, ro = 2.0, r - 1.2   # the tips clear the lit lining's flats
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
    (fixed, no pin) out of the dome turret's slot (Ryan, 28 October: the locked lance on the
    dome; it lay under the nose where a ray's mouth is). Second pass (Ryan, 2 October: too
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
    order since the stock pass, each stock part as its class (Ryan, 28 October: the lance on
    the dome, the rest his "whatever"): hp_1 the Laser Carbine on the keel mount under the
    nose where the lance lay, hp_2 the Halo Shield's dish out of the right forewing's
    underside, hp_3 the Twin Autoguns at the right wing tip, hp_4 the Ankle Mortar's rack at
    the left, hp_5 bare out of the left forewing (the Coolant Jacket shows nowhere). Eighth pass (Ryan, 5 October): the tail still read as two
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
    # The keel mount under the nose (hp_1), where the Photosphere Lance lay until it went up
    # to the dome (Ryan, 28 October): the stock's Laser Carbine as its class, a beam in the
    # ray's mouth.
    b.box(-4.0, 4.0, 10.0, 24.0, 5.5, 9.5, "steel.panel", "keel_mount")
    b.stock("hp_1", (0.0, 27.0, 7.5), "barrel", scale=0.7, carries="laser_carbine")

    def forewing_pod(s, name):
        """A pod lying along a forewing's underside, buried under the plateau and emerging
        where the leading edge's lower slope rises past it, its muzzle ahead of the edge
        (Ryan, 3 October): hp_2 the Halo Shield's dish on the right, hp_5 bare on the left."""
        px, pz = s * 16.0, 9.6
        b.prism("y", px, 24.0, pz, 2.0, 24.0, "steel.dark", 6, "wing_pod")   # y 12 to 36; the wing's leading edge is near y 34 here
        b.prism("y", px, 36.4, pz, 2.3, 1.2, "steel.plate", 6, "pod_collar")
        if name == "hp_2":
            b.stock(name, (px, 37.0, pz), "dish", scale=0.6, carries="halo_projector")
        else:
            b.pad(name, (px, 37.0, pz), scale=0.7, size=(3.6, 1.4))

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
    # layout), each a stock part as its class at the size the tip carries: the Ankle
    # Mortar's rack at the left (hp_4), the Twin Autoguns at the right (hp_3); the deck keeps
    # the dome alone; the forewing pods stay.
    for s in (-1.0, 1.0):
        px, py, pz = tip_pod(s)
        b.stock("hp_4" if s < 0 else "hp_3", (px, py, pz), "rack" if s < 0 else "twin_barrel", scale=0.55, carries="ankle_mortar" if s < 0 else "twin_autoguns")
        forewing_pod(s, "hp_2" if s > 0 else "hp_5")
    # The turret behind the canopy: a wide dome faired to the crown on a dark ring, turning
    # whole on its joint, the gun leaving a dark slot in the dome's forward slope (Ryan, 2
    # October, late: the gun comes out of the edge of something sleek). Fifth pass: the gun
    # two units further back and the dome taller, so it leaves the slot from deeper and still
    # clears the canopy's crown (Ryan, 3 October). The gun is the Photosphere Lance since 28
    # October (Ryan: the locked lance on the dome turret), so the dome is no hardpoint.
    gz = top(0.0, -10.0)
    b.prism("z", 0.0, -10.0, gz + 0.5, 9.2, 1.6, "steel.dark", 8, "turret_ring", phase=math.pi / 8)
    with b.joint("turret", (0.0, -10.0, gz + 1.3)):
        b.loft([(gz + 1.2, _poly(8.8, 8, math.pi / 8)), (gz + 3.6, _poly(8.4, 8, math.pi / 8)), (gz + 6.4, _poly(5.8, 8, math.pi / 8)), (gz + 7.8, _poly(3.2, 8, math.pi / 8))],
               "steel.plate", "turret_dome", Matrix.Translation((0.0, -10.0, 0.0)) @ Matrix.Rotation(math.pi / 2, 4, "X"))
        b.box(-2.8, 2.8, -8.4, -1.0, gz + 3.2, gz + 6.9, "steel.dark", "emitter_slot")
        b.prism("z", 0.0, -10.0, gz + 8.0, 1.8, 0.8, "amber.engine", 8, "dome_light", phase=math.pi / 8)
        # The lance from deep in the dome out of the slot, its red collar at the slot's mouth
        # and its muzzle lit, clearing the canopy's crown as the emitter did.
        b.prism("y", 0.0, 7.0, gz + 5.0, 2.0, 30.0, "steel.dark", 6, "lance")
        b.prism("y", 0.0, -0.6, gz + 5.0, 2.6, 3.0, "livery.livery2", 6, "lance_collar")
        b.prism("y", 0.0, 22.7, gz + 5.0, 1.6, 1.4, "amber.engine", 6, "lance_muzzle")

    # Idle acts, third pass (Ryan, 4 October: turrets too fast and wild; real machines with
    # inertia): curves a part runs on through, the servos' heft (b.move), and the emitter's
    # turret slow and short with a pause before it turns back (the builder's rule). Degrees
    # and seconds; a key is (t, value) on the joint's own axis or (t, pitch, yaw, roll); a
    # body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k),
    # k the light added over rest.
    b.act("scan_emitter", 7.8, {"turret": [(0.5, 0.0), (2.1, 55.0), (2.8, 55.0), (5.7, -45.0), (6.4, -45.0), (7.7, 0.0)]},   # the lance scans out one way, pauses, across to the other, pauses, home, the ray leaning after it like a helicopter
          body=[(2.1, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0), (2.8, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0), (5.7, -2.0, 0.0, 0.0, 0.0, 0.0, -4.0), (6.4, -2.0, 0.0, 0.0, 0.0, 0.0, -4.0), (7.8, 0.0, 0.0, 0.0)],
          glow=[(["lance_muzzle", "dome_light"], [(0.6, 0.0), (1.0, 6.0), (7.0, 6.0), (7.8, 0.0)])])
    b.act("lance_charge", 4.6, glow=[(["lance_muzzle", "eye"], [(0.3, 0.0), (1.0, 4.0), (1.4, 1.0), (2.0, 7.0), (2.4, 3.0), (3.0, 10.0), (3.6, 10.0), (4.3, 0.0)])],
          body=[(1.8, 0.0, 0.0, 0.0, 0.0, -4.0, 0.0), (3.6, 0.0, -3.0, 0.0, 0.0, -6.0, 0.0), (4.6, 0.0, 0.0, 0.0)])
    b.act("thrusters_surge", 4.4, body=[   # surges forward nose down, brakes nose up, settles: a helicopter's
        (0.5, 0.0, 0.0, 0.0), (1.3, 0.0, 12.0, -1.0, 0.0, -12.0, 0.0), (2.3, 0.0, 12.0, 0.0, 0.0, 10.0, 0.0), (3.1, 0.0, 0.0, 0.0, 0.0, -3.0, 0.0), (4.4, 0.0, 0.0, 0.0)],
          glow=[(["nozzle_glow"], [(0.3, 0.0), (0.9, 8.0), (1.6, 8.0), (2.4, 2.0), (3.6, 0.0)]),
                (["fan_duct_floor", "fan_lining"], [(0.3, 0.0), (0.9, 22.0), (1.6, 22.0), (2.4, 9.0), (3.6, 0.0)])])
    b.act("sidestep", 4.8, body=[   # slides a step to one side, rolling into it, and straight on across to the other
        (0.9, -6.0, 0.0, 0.0, 0.0, 0.0, -12.0), (1.6, -14.0, 0.0, 0.0, 0.0, 0.0, 2.0), (2.6, 2.0, 0.0, 0.0, 0.0, 0.0, 12.0),
        (3.4, 14.0, 0.0, 0.0, 0.0, 0.0, -2.0), (4.8, 0.0, 0.0, 0.0)])
    # Movement (Ryan, 5 October, retiring the helicopter of 3 October: it turned to its final
    # facing and held it, where it need not move so differently from the Dingo and the
    # Puffin): it faces its heading and oversteers through corners like them, banking a
    # little, and noses down hard into its travel, since its fans are its propulsion (the
    # tilt: nose down going forward, a side down to slip that way).
    # Its exhaust and its lift fans, hot, the fans' downwash lit with the exhaust (Ryan, 31
    # October: "Stingray fans hot", and "always on with heat glow"); the exhaust's halo at its plain
    # size (twice it made "a big ring around it").
    # The fans (Ryan, 3 November: "Stingray fans still aren't that glowy on screen ... When they surge,
    # they don't seem to glow more, they just kind of bleed through the fan walls"): burning at eight
    # rests over their own, the furnace tile sat near its full orange already, so a surge only clipped
    # its red and hardly showed, and their halos, drawn toward the eye as a part in a slot's are, grew
    # through the duct walls. Banked to three at rest so a surge (to twenty-two) jumps, and brighter
    # under way with the exhaust; their halos drawn where they are (ahead 0), out of the mouth only.
    b.halo = ["nozzle_glow", ("fan_duct_floor", 0.9, 0.0), ("fan_lining", 0.9, 0.0)]
    # The exhaust's plume (Ryan, 31 October: "can it be directional? If not, then we can tone it back
    # down"; his go of 3 November): a flame trailing out of the mouth along the thrust, in place of the
    # ring its halo made, lit with the exhaust; a trial, RIFTGATE_PLUME=off to compare.
    b.plume("nozzle_glow", (0.0, -49.4, 15.0), (0.0, -1.0, 0.0), reach=25.0, breadth=10.0)   # a tiny bit smaller (Ryan, 3 November: "a tiny bit too big for the Stingray")
    b.standing = {"fan_duct_floor": 3.0, "fan_lining": 3.0}   # the fans always on with their heat (Ryan, 31 October), banked to leave a surge room
    b.gait(glow={"parts": ["nozzle_glow", "fan_duct_floor", "fan_lining"], "k": 5.0})
    # The lift fans turn all the time, counter-rotating, and faster under way (Ryan, 6 October,
    # the seventh notes, the model locked: "the thing the Stingray really needs"). Slow enough a
    # frame that five blades never strobe backward at 30 frames a second.
    b.spin("fan_l", -480.0, -840.0)
    b.spin("fan_r", 480.0, 840.0)
    # The eighteenth notes (Ryan, 7 October: it moves as a helicopter, so it should turn as the
    # jets do, banking into the corner and not sliding so much): the Buzzard's cornering, a
    # little oversteer and a hard bank (36 degrees, from 14), where it drifted as the Dingo
    # and the Puffin do (oversteer 1.2 since the seventh notes); its nose-down tilt kept.
    # The nineteenth notes (Ryan, 7 October: it would not keep its nose down so far in the
    # corner; a helicopter banks, then pulls into the turn as a plane does): it sheds seven
    # tenths of its nose-down at a full bank's turn rate (the tilt's third number).
    b.fires = {"photosphere_lance": ("lance_charge", 2.5, 3.9)}   # its fixed weapon fires with a slice of its act: the lance's last charge and its blaze (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.move(slide=0.3, bank=36.0, tilt=(26.0, 10.0, 0.7), accel=0.9, heft=0.12, oversteer=0.3)

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



# ---------------------------------------------------------------- the Kestrel line's next four (23 October)
# Ryan, 23 October: models for the four machines decided on 21 October, each silhouette apart
# from the Kestrel roster's. The roster from above, the view the player reads: the Kite a dart
# on forward-swept wings with a V tail; the Buzzard a broad plank of wing, tailless, its nacelles
# on its shoulders; the Puffin a blunt hull on stubs and two giant boosters; the Lammergeier,
# then unbuilt, a flying wing since 28 October. So the Skua is the line's one conventional jet, back-swept
# wings that move over tailplanes; the Needletail a needle on a short stub wing with its boosters
# at the tips, standing upright at rest; the Storm Petrel a narrow hull under two raised plates
# and a mast; the Giant Petrel a long ship with its engines on the bow and a T-tail. Claude's
# first cut; the looks, as every number, Ryan's.

def _disc(b, centre, normal, r, n, material, label, phase=0.0):
    """A flat `n`-sided disc at `centre` facing `normal`, one whole tile fitted over it: a
    booster's mouth facing up or down, where a loft's cap along y cannot face."""
    c, nv = Vector(centre), Vector(normal).normalized()
    hint = Vector((0.0, 1.0, 0.0)) if abs(nv.y) < 0.9 else Vector((1.0, 0.0, 0.0))
    u = hint.cross(nv).normalized()
    v = nv.cross(u).normalized()
    pts = [c + u * (r * math.cos(phase + i * 2.0 * math.pi / n)) + v * (r * math.sin(phase + i * 2.0 * math.pi / n)) for i in range(n)]
    return _quad(b, [tuple(p) for p in pts], material, label, (c - u * r - v * r, v, u, nv, (2.0 * r, 2.0 * r)))


def _hexr(cx, cz, r):
    """A six-sided section as (x, z) points with a vertex at the top, the way a prism with a
    phase of a twelfth of a turn lies, for a booster's mouth lofted to match its drum."""
    return [(cx + r * math.cos(math.pi / 6 + i * math.pi / 3), cz + r * math.sin(math.pi / 6 + i * math.pi / 3)) for i in range(6)]


def _blade_section(x, y_le, y_te, z, t, lead=0.35):
    """A wing's section at the span station `x`, as 3D points: sharp at both edges, thickest
    (`t` above and below) a `lead` share of the chord back from the leading edge."""
    ym = y_le - (y_le - y_te) * lead
    return [(x, y_te, z), (x, ym, z + t), (x, y_le, z), (x, ym, z - t)]


def _fin_section(x, y_le, y_te, z, t, lead=0.35):
    """An upright fin's section at the height `z`, as 3D points, its thickness across x."""
    ym = y_le - (y_le - y_te) * lead
    return [(x, y_te, z), (x + t, ym, z), (x, y_le, z), (x - t, ym, z)]



def _iris_blade(n=6, rp=0.9, h=0.06, window=0.5, d_open=0.54, d_shut=0.1, over=6.0, nphi=5, nang=6, grow=0.012):
    """One blade of a segmented iris of `n` (the Needletail's lamp; Ryan, 13 November: "a
    segmented iris opening that widens and narrows"), in the iris's plane as (u, v) about its
    middle, for the blade whose edge faces +u when shut: each blade turns on a pin `rp` out,
    its straight edge `h` inboard of the pin, so turning them all alike opens or closes a
    regular n-sided hole whose edges stand `d` off the middle. Its outline is the hull of
    what it must cover through the whole turn (the window, `window` across, beyond its edge
    and within its share of the turn round, `over` degrees of overlap with each neighbour),
    so the blades between them close the window outside the hole at every opening and none
    reaches past the housing's rim. Returns the outline (shut), the pin, the turn
    (counter-clockwise radians) from shut to `d_open`, and the pin's angle off the edge's
    normal; the turn from shut for an opening `d` is that angle less acos((d + h) / rp)."""
    def turn(p, c, a):
        sn, cs = math.sin(a), math.cos(a)
        x, y = p[0] - c[0], p[1] - c[1]
        return (c[0] + x * cs - y * sn, c[1] + x * sn + y * cs)
    b0 = math.acos((d_shut + h) / rp)
    phi_open = b0 - math.acos((d_open + h) / rp)
    pin = (rp * math.cos(b0), rp * math.sin(b0))
    half = math.pi / n + math.radians(over)
    reach = window + 0.05
    pts = []
    for i in range(nphi):
        phi = phi_open * i / (nphi - 1.0)
        d = rp * math.cos(b0 - phi) - h
        for j in range(nang + 1):
            ang = phi - half + 2.0 * half * j / float(nang)
            r0 = d / math.cos(ang - phi)
            if r0 < reach:
                pts += [turn((r * math.cos(ang), r * math.sin(ang)), pin, -phi) for r in (r0, reach)]
    pts = sorted(set((round(x, 6), round(y, 6)) for x, y in pts))

    def cross(o, a, c):
        return (a[0] - o[0]) * (c[1] - o[1]) - (a[1] - o[1]) * (c[0] - o[0])
    lo, hi = [], []
    for p in pts:
        while len(lo) >= 2 and cross(lo[-2], lo[-1], p) <= 0.0:
            lo.pop()
        lo.append(p)
    for p in reversed(pts):
        while len(hi) >= 2 and cross(hi[-2], hi[-1], p) <= 0.0:
            hi.pop()
        hi.append(p)
    hull = lo[:-1] + hi[:-1]
    mid = (sum(p[0] for p in hull) / len(hull), sum(p[1] for p in hull) / len(hull))
    edge = rp * math.cos(b0) - h   # the shut edge, u = edge
    out = []
    for p in hull:
        k = grow / max(1e-6, math.hypot(p[0] - mid[0], p[1] - mid[1]))
        out.append((max(edge, p[0] + (p[0] - mid[0]) * k), p[1] + (p[1] - mid[1]) * k))
    return out, pin, phi_open, b0


def needletail(b):
    """Kestrel "Needletail" (K-17 Mk I Tilt-Jet Spotter): each round a weapon and an equipment,
    the Fovea Designator its one equipment, so it marks every round. Ryan's design of 12 November,
    in his words: "In hover mode, two sets of vertical boosters on swivels. Front boosters are
    smaller, on the ends of short canards. Rear boosters are larger, and sit at the tip of
    horizontal tailfins. Four other tailfins are arranged in an X pattern. No apparent main
    wings. When changed into flight mode, all four boosters rotate to horizontal and the wings
    they are on retract so the boosters are tight to the body. Triangular wings swing out of the
    middle fuselage. In flight mode, no weapons are visible. In hover mode, weapons appear: two
    weapon pods extrude out, mounted on the diagonals of the fuselage, one on either side, both
    behind the canopy. In front of the canopy, two round ports open, and weapons slide out, just
    like the Polar Bear. The locked piece sits on top of the nose, flipped up like a hidden
    headlight on a sports car. That means 4 hardpoints and one locked." The pods on the upper
    diagonals (his pick, the same day). His notes on the first cut, the same evening: the canopy
    amidships and the whole body much shorter; the pods with "a clear slot/opening/recess for them
    to retract into", following "the shape of the fuselage where they retract"; in flight the
    fuselage "streamlined like a rocket" behind "a rounded clamshell covering the muzzle", the
    halves splitting top and bottom on a horizontal seam to let the muzzle slide out; wings whose
    inner face tapers up; shorter boosters; the rear pair on fins among the X fins ("like 6
    tailfins"), settling between the upper and lower sets when retracted. And on the second cut's
    round body: "I didn't literally mean round like a rocket, I just meant no exposed weapons or
    ports"; the clamshells "the only part of the weapon port be visible, i.e. no visible tube",
    "the hinge on the axis parallel to the line of the weapons, folding into the sides of the
    fuselage instead of the front", the halves "like teardrop shaped, with the point facing the
    nose. The whole effect being an aerodynamic profile when closed, just a little bulge coming
    out of each side of the nose." On the third cut, 13 November: the nose tapering "more
    smoothly to the needle tip, which would let more of the guns live inside the fuselage", the
    clamshell then covering only "the barrel tip"; the rear tailfins longer; the pop-up after his
    picture of a sports car's, not swivelling or pitching, "more sleek". And on the fourth, the
    same day: the rear boosters thicker; the canards further forward; the cheek guns "exactly the
    right idea, but the barrels are clipping. It needs to be cut in more. Tapering the nose
    sharper should help with that, maybe?"; the lens "a segmented iris opening that widens and
    narrows"; the canopy "longer, carrying back more. It's a small spotter ship, it needs a good
    viewing range"; the rear face "a cut-out exhaust, with the needle coming out of the middle,
    even longer than it is now". And on the fifth (whose guns had gone inside the nose on a misread
    of "cut in"): "There was no clipping on the outer surface, the guns just didn't actually clear
    the nose, they were half embedded in it when extended"; the rear boosters extending "further when
    fully extended"; the wings "a bit bigger", with "no gap between them and the fuselage when
    extended". And on the sixth: the guns and ports "back further on the fuselage", so the nose can
    "get rid of that ridge and come to a smooth point"; the rear boosters to "attach properly to their
    mounts, and don't float", spread "even bigger", their wings free of the tailfins' planform; "a
    little decoration" round the exhaust, which "could also glow hotter during flight mode"; the wings
    "closer to the canards", bigger, "a bit more angle to the rear edges", and pointed again. And on
    the seventh: the rear boosters "too long now. Only needed a little more than last time"; the guns
    "extend too far when opened, they end up floating in front"; the cut ahead of each clamshell
    covered when closed, "just to smooth it out more"; the wings "just a smaller flat top" rather than
    a point; the front boosters "extend a little more when hovering". And on the eighth: the body "just
    a bit off. It feels too long, still, and could be flatter". And on the ninth: "racks, blades
    and dishes still float out of the front gun ports". And on the tenth: the pods' mounts "angled to
    match the angle of the pod they sit in"; "it needs more of the tapered part of the nose, and less
    body. If the canards moved up, that should give you room, right?" And on the eleventh: the
    front boosters toed in along the nose "causing the canards to poke through. Also straight is
    better"; "Is there any way to reduce the max width the fuselage reaches?"; "the canopy could be
    a bit flatter"; "The rear and nose needles can actually be longer". And on the twelfth: the
    wings stowed so "the forward edge was visible as a strip along the side of the fuselage".

    Built at rest in hover mode, the pose it holds standing and in every fight: a jet's chined
    fuselage, eight-sided (a flat top and belly, chamfers, a short upright band at the chine),
    the nose one long smooth taper to its point, reaching the body's width only at the canopy's
    front third; each cheek
    gun's teardrop recess back on the side where the nose's side crosses its line, the halves rolled
    up and down into the fuselage's side on the gun's own line (shell_lt, shell_lb, shell_rt,
    shell_rb), the gun run out of it (run_l, run_r) through a short trough, its muzzle clear of the
    skin beyond it, and every other class rooted in the bay and run out of the port (the port rack,
    the port dish on its mast, the blade's bracket and the twin barrels' receiver in the bay); the trough's flush cover slid into the nose (trough_l, trough_r); the Designator a low wedge popped up on the nose's top (lamp, hinged at
    its back), its round lamp facing ahead behind a six-bladed iris (iris_1 to iris_6, each
    blade turning on its own pin in the lamp's rim); the long canopy amidships, two bows across
    it; the two pods on the
    upper chamfers behind it, each a slab of the chamfer raised out of its dark slot (pod_l,
    pod_r), its gun out of its face (run_pod_l, run_pod_r), the mount leaning with the pod; the front
    boosters (booster_fl, booster_fr) upright at the tips of the canards, beside the pop-up and just
    behind the cheeks' recesses, the rear (booster_rl,
    booster_rr), thicker, far out on long tailplanes below the X fins, each turning on a hub at its
    tailplane's tip, each on a slide (slide_fl, slide_fr, slide_rl, slide_rr) that carries the rear
    tailplanes' outer panels with it; the swept wings (wing_l, wing_r), each a small flat tip, stowed
    inside the middle but for the leading edge, a cobalt strip down each chine;
    astern, the whole rear face a dark cut-out exhaust in a dark rim behind a cobalt band, lit at its
    floor, the long needle running out of its middle. Flight mode is the gait (MechRig.drive):
    as it gathers speed the cheek guns run back, the blisters' halves roll shut over the barrels' tips and the
    troughs' covers slide out flush, the
    pods' guns run back into the pods and the pods sink flush into their slots, the iris shuts and the pop-up folds
    flat, the boosters swivel level and run in along their fins to sit against the body (the front
    pair's canards running into the body with them, the rear pair between the upper and lower X fins, the tailplanes' outer panels running into the body with
    them), the wings swing out, their roots in the fuselage, and the exhaust burns hot; slowing,
    it all comes back. Mounts in the die's order: hp_1 the left cheek (the Transonic Rifle), hp_2
    the right (the Laser Carbine), hp_3 the left pod (the Twin Autoguns), hp_4 the right pod (the
    second Laser Carbine). Centred on z = 0 like the Kite."""
    # The body: a jet's chined fuselage, (y, width, top, belly, the upright band's half height at
    # the chine) nose to tail; the nose one smooth taper to its point, long, reaching the body's
    # width only at the canopy's front third, so the straight body behind it is short (Ryan, 13
    # November: "it needs more of the tapered part of the nose, and less body"), the cheek guns'
    # recesses back on its sides where it still narrows fast enough to bury them (Ryan, 13
    # November: "Move the front guns and ports back further on the fuselage ... get rid of that
    # ridge and come to a smooth point"); astern the tail ends square, its whole face the exhaust.
    # Short and flat for its width, a fifth lower than the eighth cut ("It feels too long, still, and
    # could be flatter"), and at its widest 15.8 where it was 17.4 (Ryan, 13 November: "Is there any
    # way to reduce the max width the fuselage reaches?"), what the stowed wings and the canopy on
    # the flat top still leave room for.
    BODY = [(39.86, 0.7, 0.25, 0.2, 0.05), (37.5, 2.2, 0.75, 0.65, 0.35), (34.7, 3.7, 1.2, 1.0, 0.6), (31.5, 5.3, 1.65, 1.35, 0.85),
            (28.6, 6.8, 2.05, 1.6, 1.05), (25.7, 8.4, 2.45, 1.85, 1.25), (23.0, 10.0, 2.8, 2.1, 1.4), (20.2, 11.7, 3.15, 2.3, 1.5),
            (17.2, 13.1, 3.5, 2.5, 1.55), (14.0, 13.79, 3.8, 2.7, 1.55), (9.8, 14.47, 4.25, 2.9, 1.5),
            (4.0, 15.09, 4.8, 3.1, 1.4), (-0.5, 15.41, 5.35, 3.25, 1.3), (-6.0, 15.8, 5.8, 3.4, 1.2), (-24.0, 15.8, 5.8, 3.4, 1.2),
            (-29.0, 12.4, 4.2, 2.8, 0.55), (-39.5, 12.4, 4.0, 2.7, 0.5), (-43.5, 10.8, 3.6, 2.5, 0.45)]   # straight the pods' whole length, so each pod's gun runs back under a full face

    def sec(w, top, bottom, s):
        return [(w / 2, -s), (w / 2, s), (w / 4, top), (-w / 4, top), (-w / 2, s), (-w / 2, -s), (-w / 4, -bottom), (w / 4, -bottom)]

    def at(y):
        """The body at `y`: [width, top, belly, band]."""
        return _lerp_at(BODY, y)

    def face(y):
        """The body's chine at `y`, its widest."""
        return at(y)[0] / 2.0
    body = b.loft([(y, sec(w, t, bt, s)) for (y, w, t, bt, s) in BODY], "steel.plate", "fuselage")
    b.loft([(39.4, diamond(0.0, 0.0, 0.8, 0.5)), (47.5, diamond(0.0, 0.0, 0.06, 0.06))], "steel.dark", "nose_tip")   # long (Ryan, 13 November: "The rear and nose needles can actually be longer")
    # The exhaust: the tail's whole face cut out and lined dark, its floor lit, and the needle
    # running out of its middle, long (Ryan, 13 November: "that whole thing could be a cut-out
    # exhaust, with the needle coming out of the middle, even longer than it is now").
    YT, ZC = BODY[-1][0], 0.55   # the tail's face, the exhaust's middle's height
    FLOOR = YT + 2.6             # the exhaust's floor

    def mouth(y, k=1.0):
        w, t, bt, s = at(YT)
        return [(x * 0.78 * k, y, ZC + (z - ZC) * 0.74 * k) for (x, z) in sec(w, t, bt, s)]
    b.cut_hull([body], mouth(YT - 0.6) + mouth(FLOOR))
    _rings(b, [mouth(YT + 0.04, 0.995), mouth(FLOOR - 0.05, 0.995)], "bore.void", "tail_well", cap=False)
    hot = mouth(FLOOR, 0.99)
    x0, x1, z0, z1 = min(p[0] for p in hot), max(p[0] for p in hot), min(p[2] for p in hot), max(p[2] for p in hot)
    _rings(b, [mouth(FLOOR - 0.1, 0.99), mouth(FLOOR + 0.05, 0.99)], "amber.exhaust", "tail_exhaust",
           frame=(Vector((x0, FLOOR, z0)), Vector((0.0, 1.0, 0.0)), Vector((1.0, 0.0, 0.0)), Vector((0.0, 0.0, 1.0)), (x1 - x0, z1 - z0)))   # one whole flame tile across it, white-hot in the middle round the needle
    b.loft([(FLOOR + 0.3, diamond(0.0, ZC, 2.6, 2.2)), (YT - 4.0, diamond(0.0, ZC, 1.4, 1.1)), (YT - 16.0, diamond(0.0, ZC, 0.08, 0.08))], "steel.dark", "needle")
    # A nozzle's dark rim standing round the mouth, and a cobalt band round the tail just ahead of
    # it (Ryan, 13 November: "a little decoration on the fuselage where it sits").
    _rings(b, [mouth(YT + 0.03, 1.13), mouth(YT - 0.32, 1.13), mouth(YT - 0.32, 1.0), mouth(YT + 0.03, 1.0), mouth(YT + 0.03, 1.13)], "steel.dark", "nozzle_rim", cap=False)
    b.loft([(y, [(x * 1.025, z * 1.025) for (x, z) in sec(*at(y))]) for y in (YT + 4.3, YT + 2.5)], "livery.livery", "tail_band", cap=False)   # a sleeve: a cap would close the exhaust
    # The canopy amidships, long and tall, carrying well back (Ryan, 13 November: "It's a small
    # spotter ship, it needs a good viewing range for the canopy"), two bows across it.
    CANOPY = [(8.5, 0.85, 0.38), (5.5, 2.7, 2.0), (1.0, 3.4, 2.8), (-5.0, 3.6, 3.08), (-11.0, 3.6, 3.0), (-16.0, 3.3, 2.55),
              (-19.5, 2.4, 1.58), (-21.5, 1.2, 0.6), (-22.5, 0.55, 0.22)]   # a quarter lower than it was (Ryan, 13 November: "I also think the canopy could be a bit flatter")
    _jet_canopy(b, [(y, w, t, bt) for (y, w, t, bt, s) in BODY], CANOPY, -3.0, frames=(-12.5,))

    # The cheeks: each gun lies inside the nose on a run, its line where the nose's side crosses
    # it, so in flight only its barrel's tip stands proud of the skin, under a short teardrop
    # clamshell, point forward, a little bulge. Shut it is the outer part of a teardrop of
    # revolution about the gun's line, split on a horizontal seam; each half hinges on that line (a
    # roll joint) and in hover is rolled up (or down) and in, into the fuselage's side behind the
    # recess's dark lining, and the gun runs far out ahead through a short trough, clear of the skin
    # beyond it (Ryan, 13 November: "they were half embedded in it when extended"), the nose
    # narrowing fastest just there.
    YC = 23.0                      # the port's point, where the nose's side crosses the gun's line, back where the nose is wide (Ryan, 13 November: "Move the front guns and ports back further on the fuselage"), on the longer taper where it still narrows fast enough for a small blister
    AX = face(YC)                  # the gun's line out from the middle
    TIP_B, WIDE, NARROW, TIP_F = YC - 4.0, YC - 2.6, YC - 1.3, YC   # the blister's back tip, its widest, the start of its point, its point
    RM = 1.42                      # its radius at its widest
    TH, OPEN = 0.22, 120.0         # the halves' thickness, and how far each rolls in to open
    RUN = 6.0                      # how far the gun runs back in flight, its muzzle under the blister (Ryan, 13 November: "extend too far when opened, they end up floating in front")
    PIN = YC - 1.5 + RUN - 7.68    # the gun's mount at rest, run out, its muzzle just clear of the nose (the port gun is 7.68 long here)
    # Each class rooted in the open bay and run out of the port, none ahead of it on nothing (Ryan,
    # 13 November: "racks, blades and dishes still float out of the front gun ports"): the port
    # rack's drum and the port dish's sleeve from one root at the bay's back, just ahead of the
    # gun's, at one diameter (of the Kite's, 12 November: "same diameter as the rack"), the blade's
    # bracket filling the bay, the twin barrels' receiver in it.
    CHEEK_FITS = {"barrel": ("barrel_port", 1.0), "twin_barrel": ("twin_barrel", 0.55, -6.4), "rack": ("rack_port", 0.65, -0.5),
                  "dish": ("dish_port", 0.65, -0.5), "blade": ("blade", 0.55, -4.0)}

    def drop(y):
        """The blister's radius at `y`: a round back buried in the skin, its widest over the
        muzzle, then a point."""
        if y <= TIP_B or y >= TIP_F:
            return 0.04
        if y <= WIDE:
            return max(0.04, RM * math.sqrt(max(0.0, 1.0 - ((WIDE - y) / (WIDE - TIP_B)) ** 2)))
        if y <= NARROW:
            return RM
        t = (y - NARROW) / (TIP_F - NARROW)
        return max(0.04, RM * (1.0 - t) * (1.0 + 0.7 * t))
    STATIONS = [TIP_B + (WIDE - TIP_B) * f for f in (0.0, 0.025, 0.1, 0.25, 0.45, 0.7)] + [WIDE, (WIDE + NARROW) / 2.0, NARROW] + \
               [NARROW + (TIP_F - NARROW) * f for f in (0.25, 0.5, 0.75, 0.92, 1.0)]
    TROUGH = (YC - 0.8, next(y / 100.0 for y in range(int(YC * 100), int(BODY[0][0] * 100)) if face(y / 100.0) <= AX - 1.1) + 0.3, 1.1)   # where the barrel leaves the recess, along a short trough of this radius about its line, till the nose has narrowed clear of it
    SINK = 1.6                     # how far the trough's cover slides in, behind the trough's floor, in hover

    def edge(y, r):
        """How far round from the outboard side (degrees) the blister's surface meets the nose's
        side at `y`, the gun's line lying inside it there."""
        return math.degrees(math.acos(max(-1.0, min(1.0, (face(y) - AX) / max(r, 1e-6)))))

    def arc(s, y, r, a0, a1, n=8):
        """Points on the circle of radius `r` about the gun's line at `y`, from a0 to a1 degrees
        (from the outboard side, positive up), on side `s`."""
        return [(s * (AX + r * math.cos(math.radians(a0 + (a1 - a0) * k / n))), y, r * math.sin(math.radians(a0 + (a1 - a0) * k / n))) for k in range(n + 1)]
    for s, n, carries in ((-1.0, 1, "transonic_rifle"), (1.0, 2, "laser_carbine")):
        side = "l" if s < 0 else "r"
        axis_at = Vector((s * AX, 0.0, 0.0))
        # The recess: the blister's whole teardrop cut out of the body, its inboard part lined dark.
        hull = []
        for y in STATIONS:
            hull += arc(s, y, drop(y) + 0.05, 0.0, 360.0, 15)[:-1]
        b.cut_hull([body], hull)
        b.cut_hull([body], arc(s, TROUGH[0], TROUGH[2], 0.0, 360.0, 15)[:-1] + arc(s, TROUGH[1], TROUGH[2], 0.0, 360.0, 15)[:-1])
        # The trough's cover: a flush lens of the nose's side over the trough, slid in behind its
        # floor in hover and out flush in flight, so the closed nose is smooth from the blister on
        # (Ryan, 13 November: "encompass the whole cut section, just to smooth it out more when
        # closed"); its slot cut through the floor along its travel.
        lens = []
        for k in range(11):
            y = TROUGH[0] + (TROUGH[1] - TROUGH[0]) * k / 10.0
            h = math.sqrt(max(0.0, TROUGH[2] ** 2 - (face(y) - AX) ** 2))
            lens.append((y, face(y), h))
        b.cut_hull([body], [(s * (x + dx), y, z) for (y, x, h) in lens for dx in (0.05, -SINK - 0.25) for z in (-h - 0.03, h + 0.03)])
        with b.joint("trough_" + side, (s * (face(YC) - SINK), YC, 0.0), slide=(1.0, 0.0, 0.0)):
            rings = []
            for (y, x, h) in lens:
                ring = [(s * (x - SINK), y, -h), (s * (x - SINK), y, h), (s * (x - SINK - 0.18), y, h), (s * (x - SINK - 0.18), y, -h)]
                rings.append(ring if s > 0 else list(reversed(ring)))
            _rings(b, rings, "steel.plate", "trough_cover")
        _rings(b, [arc(s, y, max(0.02, drop(y) - 0.3), edge(y, drop(y)), 360.0 - edge(y, drop(y)))
                   + list(reversed(arc(s, y, max(0.01, drop(y) - 0.36), edge(y, drop(y)), 360.0 - edge(y, drop(y))))) for y in STATIONS],
               "bore.void", "cheek_bay")
        # The two halves, each built rolled open into the side (hover).
        for half, sign in (("t", 1.0), ("b", -1.0)):
            roll = -s * sign * OPEN   # the roll that opens it: up and in for the top, down and in for the bottom
            turn = Matrix.Rotation(math.radians(roll), 3, "Y")
            rings = []
            for y in STATIONS:
                r = drop(y)
                e = edge(y, r)
                a0, a1 = (0.0, e) if sign > 0 else (-e, 0.0)
                ring = arc(s, y, r, a0, a1) + list(reversed(arc(s, y, max(0.01, r - TH), a0, a1)))
                rings.append([tuple(axis_at + turn @ (Vector(p) - axis_at)) for p in ring])
            close = -roll
            with b.joint("shell_%s%s" % (side, half), (s * AX, (TIP_B + TIP_F) / 2.0, 0.0), axis="roll",
                         limits=(min(0.0, close) - 5.0, max(0.0, close) + 5.0)):
                _rings(b, rings, "steel.plate", "shell")
        with b.joint("run_" + side, (s * AX, PIN, 0.0), slide=(0.0, 1.0, 0.0)):
            b.stock("hp_%d" % n, (s * AX, PIN, 0.0), "barrel", scale=0.32, carries=carries, fits=CHEEK_FITS)

    # The Fovea Designator (fixed): a pop-up on the nose's top between the cheeks, after a sports
    # car's hidden headlight (Ryan's picture, 13 November: "Should be more sleek"): a low wedge
    # hinged at its back, its top a panel of the nose's own plating, its sides dark triangles, the
    # round lamp in its upright face. Up, the panel rises forward from the hinge and the lamp
    # faces ahead; folded, the panel lies flush in the nose's top and the wedge sinks into its
    # well. It neither swivels nor tips; its lamp looks out through a six-bladed iris that widens
    # and narrows as it paints (Ryan, 13 November: "a segmented iris opening that widens and
    # narrows"), each blade turning on a pin in the lamp's rim under a housing ring.
    HY, LP, RISE, FACE, HW = 11.7, 4.4, 24.0, 2.4, 1.6   # the hinge's station; the panel's length and rise; the face's height; half the width
    top = lambda y: at(y)[1]
    hinge = Vector((0.0, HY, top(HY)))
    lean = math.degrees(math.atan((top(HY) - top(HY + LP)) / LP))   # the nose's top falling ahead of the hinge
    LAMP_FOLD = -(RISE + lean)
    ft = hinge + Vector((0.0, LP * math.cos(math.radians(RISE)), LP * math.sin(math.radians(RISE))))   # the face's top edge, up
    fb = ft - Vector((0.0, 0.0, FACE))                                                                 # its foot, a little under the skin
    fold = Matrix.Rotation(math.radians(LAMP_FOLD), 3, "X")
    ftc, fbc = hinge + fold @ (ft - hinge), hinge + fold @ (fb - hinge)                               # the same, folded
    well = []
    for x in (-HW - 0.15, HW + 0.15):
        for (y, z) in ((HY - 0.2, top(HY) + 1.2), (HY - 0.2, top(HY) - 0.35), (fbc.y, fbc.z - 0.25), (fbc.y + 1.0, fbc.z - 0.25),
                       (ftc.y + 0.35, ftc.z - 0.6), (ftc.y + 0.35, ftc.z + 1.2)):
            well.append((x, y, z))
    b.cut_hull([body], well)
    _slab(b, [(-HW - 0.12, fbc.y - 0.3, fbc.z - 0.15), (HW + 0.12, fbc.y - 0.3, fbc.z - 0.15), (HW + 0.12, ftc.y + 0.3, ftc.z - 0.5), (-HW - 0.12, ftc.y + 0.3, ftc.z - 0.5)],
          (0.0, -(ftc.z - fbc.z - 0.35), (ftc.y - fbc.y + 0.6)), 0.12, "bore.void", "lamp_well")
    IRIS, PIN_R, EDGE_IN = 6, 0.9, 0.06                     # the blades; their pins out from the middle; each edge inboard of its pin
    WINDOW, HOUSING = 0.5, 1.08                             # the housing ring's hole and rim
    BLADE, PIN_AT, OPEN_TURN, B0 = _iris_blade(IRIS, PIN_R, EDGE_IN, WINDOW, WINDOW + 0.04, 0.1)

    def iris_turn(d):
        """The blades' turn (degrees, counter-clockwise from shut) that opens the hole to `d`."""
        return math.degrees(B0 - math.acos((d + EDGE_IN) / PIN_R))
    IRIS_REST = iris_turn(0.3)
    IRIS_OPEN, IRIS_SHUT = -(iris_turn(WINDOW + 0.04) - IRIS_REST), IRIS_REST   # as rolls from rest: a roll turns the other way
    with b.joint("lamp", tuple(hinge), limits=(LAMP_FOLD - 4.0, 6.0)):
        _rings(b, [[(x, p.y, p.z) for p in (hinge, ft, fb)] for x in (-HW, HW)], "steel.dark", "lamp_pod")
        lid_n = Vector((0.0, -(ft.z - hinge.z), ft.y - hinge.y)).normalized()   # the panel's normal, up and back
        _slab(b, [tuple(Vector((x, p.y, p.z)) + lid_n * 0.07) for (x, p) in ((-HW - 0.05, hinge), (HW + 0.05, hinge), (HW + 0.05, ft), (-HW - 0.05, ft))],
              tuple(lid_n), 0.12, "steel.plate", "lamp_lid")
        lc = Vector((0.0, ft.y, (ft.z + fb.z) / 2.0 + 0.15))   # the lamp's middle on the face
        _disc(b, tuple(lc + Vector((0.0, 0.04, 0.0))), (0.0, 1.0, 0.0), 1.0, 12, "steel.dark", "lamp_back")
        _disc(b, tuple(lc + Vector((0.0, 0.08, 0.0))), (0.0, 1.0, 0.0), 0.82, 12, "glass.glass", "lens")
        _disc(b, tuple(lc + Vector((0.0, 0.12, 0.0))), (0.0, 1.0, 0.0), 0.42, 12, "amber.lit", "fovea")
        # The iris: six blades in the face's plane (u across, v up), each a little ahead of the
        # last, built at rest half open; a blade's roll turns it on its pin.
        rest = math.radians(IRIS_REST)
        for k in range(IRIS):
            th = 2.0 * math.pi * k / IRIS
            ck, sk = math.cos(th), math.sin(th)
            pin = (PIN_AT[0] * ck - PIN_AT[1] * sk, PIN_AT[0] * sk + PIN_AT[1] * ck)
            pts = []
            for (u, v) in BLADE:
                u, v = u * ck - v * sk, u * sk + v * ck                       # round to this blade's place
                du, dv = u - pin[0], v - pin[1]
                u, v = pin[0] + du * math.cos(rest) - dv * math.sin(rest), pin[1] + du * math.sin(rest) + dv * math.cos(rest)   # turned to rest
                pts.append((lc.x + u, lc.y + 0.16 + 0.014 * k, lc.z + v))
            with b.joint("iris_%d" % (k + 1), (lc.x + pin[0], lc.y + 0.16 + 0.014 * k, lc.z + pin[1]), axis="roll",
                         limits=(IRIS_OPEN - 4.0, IRIS_SHUT + 4.0)):
                _slab(b, pts, (0.0, 1.0, 0.0), 0.008, "steel.dark", "iris")
        ring = lambda r, y: [(lc.x + r * math.cos(math.pi * i / 6.0), lc.y + y, lc.z + r * math.sin(math.pi * i / 6.0)) for i in range(12)]
        _rings(b, [ring(HOUSING, 0.26), ring(HOUSING, 0.33), ring(WINDOW, 0.33), ring(WINDOW, 0.26), ring(HOUSING, 0.26)], "steel.plate", "lamp_bezel", cap=False)

    # The boosters: each a hexagonal drum, intake up and exhaust down in hover, shorter than the
    # first cut's (Ryan: "All 4 boosters can be shorter"); `k` its girth, `L` its length.
    def booster(tag, nx, ny, nz, k, L):
        with b.joint("booster_" + tag, (nx, ny, nz), limits=(-95.0, 22.0)):
            b.prism("z", nx, ny, nz - 2.5 * L, 4.4 * k, 17.0 * L, "steel.dark", 6, "booster", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 8.0 * L, 4.7 * k, 6.0 * L, "steel.plate", 6, "booster_cowl", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 1.5 * L, 4.6 * k, 3.0 * L, "livery.livery", 6, "booster_band", phase=math.pi / 6)
            b.prism("z", nx, ny, nz + 11.0 * L + 0.4 * k, 5.1 * k, 0.8 * k, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
            _disc(b, (nx, ny, nz + 11.0 * L + 0.85 * k), (0.0, 0.0, 1.0), 4.3 * k, 6, "bore.dark", "intake", phase=math.pi / 6)
            b.prism("z", nx, ny, nz - 11.0 * L - 0.6 * k, 4.9 * k, 1.4 * k, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
            _disc(b, (nx, ny, nz - 11.0 * L - 1.35 * k), (0.0, 0.0, -1.0), 4.5 * k, 6, "amber.exhaust", "exhaust", phase=math.pi / 6)

    def tucked(k, L, y_pivot):
        """Where a booster's axis sits level and run in against the body (its intake leading):
        each hexagon's flat side (the lip at the intake's end, the ring at the exhaust's) clear of
        the chine wherever along its length it lies."""
        out = 0.0
        for (dy, r) in ((11.0 * L + 0.8 * k, 5.1 * k), (8.0 * L, 4.7 * k), (0.0, 4.4 * k), (-11.0 * L - 1.3 * k, 4.9 * k)):
            out = max(out, face(y_pivot + dy) + r * math.cos(math.pi / 6) + 0.05)
        return out
    # Each front booster runs in on a slide until it sits against the body, its canard riding in with
    # it, into the body (his design: "the wings they are on retract"), so the canard's tip stays
    # inside the booster (Ryan, 13 November, of the boosters toed in along the nose: "it's causing
    # the canards to poke through. Also straight is better"). Each rear booster turns on a hub at the tip of a
    # long tailplane of its own planform (Ryan, 13 November: "the wings they're attached to don't have
    # to strictly match the other tailfins"): a fixed root stub off the body and an outer panel riding
    # on the booster's slide, so in flight the panel runs into the body with the booster (his design:
    # "the wings they are on retract so the boosters are tight to the body"), and nothing floats or is
    # left standing past it ("Make sure the rear boosters attach properly to their mounts").
    KF, LF = 0.62, 0.45          # the front boosters' girth and length
    KR, LR = 1.05, 0.61          # the rear's (Ryan, 13 November: "rear boosters can be thicker")
    FY, FX = 14.0, 15.5          # the canards' station, beside the pop-up and just behind the cheeks' recesses (Ryan: "can the canards afford to be further forward now?"; 13 November, of the longer taper: "If the canards moved up, that should give you room"), and their boosters' pivot ("could extend a little more when hovering")
    RY, RX = -37.0, 21.5         # the tailplanes' (Ryan, 13 November: "too long now. Only needed a little more than last time")
    FIN = FX - tucked(KF, LF, FY)
    RIN = RX - tucked(KR, LR, RY)
    ROOT_LE, ROOT_TE, TIP_LE, TIP_TE, SPAN = -28.5, -40.0, -37.5, -43.0, 10.0   # the X fins' planform: root chord, tip chord, span (Ryan, 13 November: "Can the rear tailfins be longer?")
    FIN_RAKE = 52.0   # the X fins' angle off the horizontal, steep enough to clear the rear boosters up and tucked
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        tip = FX - 4.4 * KF * math.cos(math.pi / 6) + 0.4
        with b.joint("slide_f" + side, (s * FX, FY, 0.0), slide=(1.0, 0.0, 0.0)):
            _rings(b, [_blade_section(s * (face(FY) - 0.2), FY + 3.5, FY - 3.5, 0.0, 0.7), _blade_section(s * tip, FY + 2.0, FY - 2.0, 0.0, 0.5)],
                   "livery.livery", "canard")
            booster("f" + side, s * FX, FY, 0.0, KF, LF)
        root = face(RY + 3.0) - 0.06
        _rings(b, [_blade_section(s * root, RY + 7.5, RY - 4.6, 0.0, 0.85), _blade_section(s * 12.4, RY + 4.5, RY - 4.3, 0.0, 0.7)], "livery.livery", "tailplane")
        inner = RX - 4.4 * KR * math.cos(math.pi / 6)   # the booster's inner face
        zp = 0.18 * s   # the two panels pass each other inside the body when in
        with b.joint("slide_r" + side, (s * RX, RY, 0.0), slide=(1.0, 0.0, 0.0)):
            _rings(b, [_blade_section(s * 11.0, RY + 4.4, RY - 4.0, zp, 0.45), _blade_section(s * (inner + 0.3), RY + 2.1, RY - 2.3, zp, 0.4)], "livery.livery", "tailplane")
            b.prism("x", s * (inner - 0.5), RY, 0.0, 1.3, 1.2, "steel.dark", 6, "booster_hub", phase=math.pi / 6)
            booster("r" + side, s * RX, RY, 0.0, KR, LR)

    # The X fins off the tail's chamfers with the tailplanes: six fins, the rear boosters settling
    # between the upper and the lower pair in flight.
    for sx in (-1.0, 1.0):
        for sz in (-1.0, 1.0):
            d = Vector((sx * math.cos(math.radians(FIN_RAKE)), 0.0, sz * math.sin(math.radians(FIN_RAKE))))
            t = Vector((-d.z, 0.0, d.x)) * 0.3   # the fin's thickness, across its span

            def fin(y_le, y_te, out, d=d, t=t, sx=sx, sz=sz):
                w, tp, bt, s = at((y_le + y_te) / 2.0)
                c = Vector((sx * w * 3.0 / 8.0, 0.0, sz * ((s + tp) / 2.0 if sz > 0 else (s + bt) / 2.0))) + d * out
                ym = y_le - (y_le - y_te) * 0.35
                return [(c.x, y_te, c.z), (c.x + t.x, ym, c.z + t.z), (c.x, y_le, c.z), (c.x - t.x, ym, c.z - t.z)]
            _rings(b, [fin(ROOT_LE, ROOT_TE, -0.3), fin(TIP_LE, TIP_TE, SPAN)], "livery.livery", "tail_fin")

    # The wings: each a flat cobalt quadrilateral, swept, its inner edge tapering up to its leading
    # root (Ryan: "The inner face can taper up"), built swung in about a pivot on its leading edge, so
    # stowed the wing lies inside the middle but for its leading edge, which runs down the chine as a
    # strip standing a little out of the side (Ryan, 13 November: "if the forward edge was visible as
    # a strip along the side of the fuselage, that would really sell it. And add some visual interest
    # to hover mode"); in flight it swings out about 45 degrees. The two lie across each other inside
    # at one height, so the strips match. Out, its root lies inside the fuselage all along, the
    # leading edge carried a little past the pivot into the body, no gap at the side (Ryan, 13
    # November: "a bit bigger, and make sure there's no gap between them and the fuselage when
    # extended"); near the canards, bigger, its trailing edge swept back ("closer to the canards, and
    # get a bit bigger even, with a bit more angle to the rear edges"), a small flat tip ("I was
    # wrong about the wings coming to a point, maybe just a smaller flat top from what it was").
    ZW, PIVOT_Y, STRIP = -0.4, 6.0, 1.0   # the wings' height, in the band just under the pods' slots; the pivot's station; how far the strip's ends stand out of the side
    TIP_LE, TIP_TE, ROOT_TE = (29.0, -14.0), (29.0, -16.8), (6.6, -10.5)   # the deployed planform's outer corners and its root's trailing corner, the right wing's
    yf, ya = PIVOT_Y + 2.0, PIVOT_Y - 28.7   # the strip's ends, near enough: the leading edge from two past the pivot to the tip
    slope = (face(ya) - face(yf)) / (yf - ya)   # the strip's lean out, aft, so it stands as far out of the side at both ends
    px = face(yf) + STRIP + (yf - PIVOT_Y) * slope
    SWING = 90.0 - math.degrees(math.atan(slope)) + math.degrees(math.atan2(TIP_LE[1] - PIVOT_Y, TIP_LE[0] - px))
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        piv = Vector((s * px, PIVOT_Y, ZW))
        tip_le = Vector((s * TIP_LE[0], TIP_LE[1], ZW))
        le = (tip_le - piv).normalized()
        out = [piv - le * 2.0, tip_le, Vector((s * TIP_TE[0], TIP_TE[1], ZW)), Vector((s * ROOT_TE[0], ROOT_TE[1], ZW))]   # the deployed planform
        turn = Matrix.Rotation(math.radians(SWING if s < 0 else -SWING), 3, "Z")
        stowed = [tuple(piv + turn @ (p - piv)) for p in out]
        with b.joint("wing_" + side, tuple(piv), axis="yaw", limits=(-SWING - 5.0, 0.0) if s < 0 else (0.0, SWING + 5.0)):
            _slab(b, list(reversed(stowed)) if s > 0 else stowed, (0.0, 0.0, 1.0), 0.6, "livery.livery", "wing")

    # The pods on the upper chamfers behind the canopy: each a slab of the chamfer itself (a band
    # across it, PT deep) lofted along the body so it follows the chamfer where it lies, raised out
    # of its slot (cut into the body and lined dark) along the chamfer's normal at rest, its gun out
    # of its face; in flight the gun runs back into the pod and the pod sinks flush, a dark seam
    # round it.
    PY0, PY1, PT, OUT = -11.0, -23.0, 3.4, 3.0   # the pod's front and back, its depth, how far it stands out at rest
    F0, F1 = 0.32, 0.9                           # the band of the chamfer it is, from the chine's band up, high enough that its slot clears the wings stowed under it
    GUN = 1.7                                    # the gun's line under the pod's face, every class inside the pod
    RUNP = 8.0                                   # how far a pod's gun runs back into it in flight
    POD_FITS = {"barrel": "barrel_port", "twin_barrel": ("twin_barrel", 0.65), "rack": ("rack_round", 0.7, 8.1),
                "dish": ("dish", 0.6, 4.2), "blade": ("blade", 0.75)}

    def chamfer(y):
        """The right upper chamfer at `y`: its foot (the band's top), its unit run up it, its
        length and its outward normal, in (x, z)."""
        w, tp, bt, s = at(y)
        p0 = Vector((w / 2.0, s))
        run = Vector((w / 4.0, tp)) - p0
        length = run.length
        u = run / length
        return p0, u, length, Vector((u.y, -u.x))

    def band(s, y, f0, f1, d0, d1, out=0.0, inset=0.0):
        """A slab of the chamfer at `y`, from f0 to f1 up it and from d1 (outside) down to d0
        along its normal, `out` along the normal, `inset` drawn in round its middle, as (x, z)
        for side `s`, wound the same way on both sides."""
        p0, u, length, n = chamfer(y)
        pts = [p0 + u * length * f0 + n * (d1 + out), p0 + u * length * f1 + n * (d1 + out),
               p0 + u * length * f1 + n * (d0 + out), p0 + u * length * f0 + n * (d0 + out)]
        if inset:
            m = sum(pts, Vector((0.0, 0.0))) / 4.0
            pts = [m + (p - m) * (1.0 - inset) for p in pts]
        pts = [(s * p.x, p.y) for p in pts]
        return pts if s > 0 else list(reversed(pts))
    for s, n, shape, carries in ((-1.0, 3, "twin_barrel", "twin_autoguns"), (1.0, 4, "barrel", "laser_carbine")):
        side = "l" if s < 0 else "r"
        # The slot: a cut a hair wider, longer and deeper than the pod; its lining a hair inside.
        cut = []
        for y in (PY0 + 0.4, PY1 - 0.4):
            cut += [(x, y, z) for (x, z) in band(s, y, F0 - 0.035, F1 + 0.035, -PT - 0.4, 1.4)]
        b.cut_hull([body], cut)
        ya, yb = PY0 + 0.25, PY1 - 0.25
        for (f0, f1, d0, d1, y0, y1) in ((F0 - 0.03, F1 + 0.03, -PT - 0.25, -PT - 0.1, ya, yb),       # the floor
                                         (F0 - 0.03, F0 - 0.012, -PT - 0.25, 0.2, ya, yb),            # the walls
                                         (F1 + 0.012, F1 + 0.03, -PT - 0.25, 0.2, ya, yb),
                                         (F0 - 0.03, F1 + 0.03, -PT - 0.25, 0.2, ya, ya - 0.15),     # the ends
                                         (F0 - 0.03, F1 + 0.03, -PT - 0.25, 0.2, yb + 0.15, yb)):
            b.loft([(y0, band(s, y0, f0, f1, d0, d1)), (y1, band(s, y1, f0, f1, d0, d1))], "bore.dark", "pod_well")
        p0, u, length, nrm = chamfer(PY0)
        g = p0 + u * length * (F0 + F1) / 2.0 + nrm * (OUT - GUN)   # the gun's line, the pod's face's middle
        gx, gz = s * g.x, g.y
        with b.joint("pod_" + side, (gx, (PY0 + PY1) / 2.0, gz), slide=(s * nrm.x, 0.0, nrm.y)):
            b.loft([(PY0, band(s, PY0, F0, F1, -PT, 0.0, OUT, inset=0.1)), (PY0 - 1.2, band(s, PY0 - 1.2, F0, F1, -PT, 0.0, OUT)),
                    (PY1 + 1.0, band(s, PY1 + 1.0, F0, F1, -PT, 0.0, OUT)), (PY1, band(s, PY1, F0, F1, -PT, 0.0, OUT, inset=0.07))], "steel.plate", "pod")
            b.loft([(y, band(s, y, F0 - 0.006, F1 + 0.006, -PT - 0.05, 0.08, OUT)) for y in (PY0 - 3.0, PY0 - 4.6)], "livery.livery", "pod_band")
            _disc(b, (gx, PY0 + 0.05, gz), (0.0, 1.0, 0.0), 1.15, 8, "bore.dark", "pod_muzzle")
            with b.joint("run_pod_" + side, (gx, PY0 + 0.2, gz), slide=(0.0, 1.0, 0.0)):
                # The mount leans with its pod, its up the chamfer's outward normal, so a class sits
                # square in the pod's face (Ryan, 13 November: "Can the upper pod mounts be angled to
                # match the angle of the pod they sit in?").
                b.stock("hp_%d" % n, (gx, PY0 + 0.2, gz), shape, scale=0.36, carries=carries, fits=POD_FITS, up=(s * nrm.x, 0.0, nrm.y))
    PN = chamfer(PY0)[3]   # the pods' line out, the right one's

    # Flight mode, the joints' pose at full speed (the gait below) and in the transition act.
    BOOST = ["booster_fl", "booster_fr", "booster_rl", "booster_rr"]
    LEVEL = -88.0
    FLIGHT = {j: (LEVEL, 0.0, 0.0, 0.0, 0.0, 0.0) for j in BOOST}
    FLIGHT.update({"slide_fl": (0.0, 0.0, 0.0, FIN, 0.0, 0.0), "slide_fr": (0.0, 0.0, 0.0, -FIN, 0.0, 0.0),
                   "slide_rl": (0.0, 0.0, 0.0, RIN, 0.0, 0.0), "slide_rr": (0.0, 0.0, 0.0, -RIN, 0.0, 0.0),
                   "wing_l": (0.0, -SWING, 0.0, 0.0, 0.0, 0.0), "wing_r": (0.0, SWING, 0.0, 0.0, 0.0, 0.0),
                   "pod_l": (0.0, 0.0, 0.0, PN.x * OUT, 0.0, -PN.y * OUT), "pod_r": (0.0, 0.0, 0.0, -PN.x * OUT, 0.0, -PN.y * OUT),
                   "run_pod_l": (0.0, 0.0, 0.0, 0.0, -RUNP, 0.0), "run_pod_r": (0.0, 0.0, 0.0, 0.0, -RUNP, 0.0),
                   "run_l": (0.0, 0.0, 0.0, 0.0, -RUN, 0.0), "run_r": (0.0, 0.0, 0.0, 0.0, -RUN, 0.0),
                   "shell_lt": (0.0, 0.0, -OPEN, 0.0, 0.0, 0.0), "shell_rt": (0.0, 0.0, OPEN, 0.0, 0.0, 0.0),
                   "shell_lb": (0.0, 0.0, OPEN, 0.0, 0.0, 0.0), "shell_rb": (0.0, 0.0, -OPEN, 0.0, 0.0, 0.0),
                   "lamp": (LAMP_FOLD, 0.0, 0.0, 0.0, 0.0, 0.0)})
    FLIGHT.update({"iris_%d" % (k + 1): (0.0, 0.0, IRIS_SHUT, 0.0, 0.0, 0.0) for k in range(IRIS)})   # the iris shut under the folded lid
    FLIGHT.update({"trough_l": (0.0, 0.0, 0.0, -SINK, 0.0, 0.0), "trough_r": (0.0, 0.0, 0.0, SINK, 0.0, 0.0)})   # the troughs' covers out flush

    def held(pose):
        return {j: [(0.0,) + tuple(v), (1.0,) + tuple(v)] for j, v in pose.items()}

    # The change as keys, in order (the guns in, the iris shut and the lamp down first, then the blisters' halves
    # roll shut and the pods sink; then the boosters swivel, run in along their fins and the wings
    # swing out; back the other way round), from `t0` over `span` seconds, or from flight back to
    # hover when `back`.
    STAGE = {"run_l": 0.0, "run_r": 0.0, "run_pod_l": 0.0, "run_pod_r": 0.0, "lamp": 0.1,
             "shell_lt": 0.4, "shell_lb": 0.4, "shell_rt": 0.4, "shell_rb": 0.4, "pod_l": 0.3, "pod_r": 0.3,
             "booster_fl": 0.4, "booster_fr": 0.4, "booster_rl": 0.4, "booster_rr": 0.4,
             "slide_fl": 0.5, "slide_fr": 0.5, "slide_rl": 0.5, "slide_rr": 0.5, "wing_l": 0.55, "wing_r": 0.55}
    STAGE.update({"iris_%d" % (k + 1): 0.0 for k in range(IRIS)})
    STAGE.update({"trough_l": 0.45, "trough_r": 0.45})

    def change(t0, span, back=False):
        out = {}
        for j, v in FLIGHT.items():
            k0 = STAGE[j] if not back else 0.55 - STAGE[j]
            a, z = (0.0,) * 6, tuple(v)
            ta, tb = t0 + span * k0, t0 + span * (k0 + 0.45)
            out[j] = [(ta,) + (z if back else a), (tb,) + (a if back else z)]
        return out

    # Idle acts (four, loud, never in step; a light airframe's servos). Degrees and seconds; a
    # body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k).
    boosters = ["booster_ring", "exhaust"]
    burn = boosters + ["tail_exhaust"]   # the boosters and the exhaust astern
    # The transition: it changes into flight mode on the spot, surges forward nose down as a jet,
    # the exhaust burning, holds, and changes back as it flares onto its station.
    tracks = change(0.3, 1.4)
    back = change(3.4, 1.4, back=True)
    for j in tracks:
        tracks[j] = tracks[j] + back[j]
    b.act("transition", 5.4, tracks,
          body=[(1.2, 0.0, 0.0, 0.0), (1.9, 0.0, 8.0, -1.0, 0.0, -6.0, 0.0), (2.7, 0.0, 14.0, -0.5, 0.0, -5.0, 0.0), (3.4, 0.0, 12.0, 0.5, 0.0, 2.0, 0.0),
                (4.2, 0.0, 4.0, 1.0, 0.0, 6.0, 0.0), (5.4, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.6, 0.0), (1.4, 6.0), (3.4, 6.0), (4.4, 1.0), (5.0, 0.0)]),
                (["tail_exhaust"], [(0.6, 0.0), (1.5, 11.0), (3.3, 11.0), (4.4, 1.0), (5.0, 0.0)])])
    # The sidestep: omnidirectional, it slides a step to one side rolling into it and straight on
    # across to the other, the boosters leaning a touch forward through it.
    lean = [(0.4, 0.0), (0.9, -12.0), (3.4, -12.0), (4.0, 0.0)]
    b.act("sidestep", 4.6, {j: lean for j in BOOST},
          body=[(0.6, -7.0, 0.0, 0.0, 0.0, 0.0, -12.0), (1.3, -14.0, 0.0, 0.5, 0.0, 0.0, 3.0), (2.4, 1.0, 0.0, 0.0, 0.0, 0.0, 12.0),
                (3.2, 14.0, 0.0, 0.5, 0.0, 0.0, -3.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.4, 0.0), (0.8, 4.0), (3.4, 4.0), (4.0, 0.0)])])
    # Designating: the machine turns its nose a little onto the mark, the iris opens wide to look,
    # snaps down to a pinpoint as the fovea flares and paints, widens and narrows again as it holds
    # the mark (Ryan, 13 November: "a segmented iris opening that widens and narrows"), the pop-up
    # itself still ("It doesn't need to swivel or pitch"); then home.
    look = [(0.5, 0.0), (1.1, IRIS_OPEN), (1.5, IRIS_OPEN), (1.8, IRIS_SHUT * 0.85), (2.4, IRIS_SHUT * 0.85), (2.8, IRIS_OPEN * 0.45),
            (3.2, IRIS_OPEN * 0.45), (3.5, IRIS_SHUT * 0.7), (4.0, IRIS_SHUT * 0.7), (4.8, 0.0)]
    b.act("designate", 5.6, {"iris_%d" % (k + 1): look for k in range(IRIS)},
          body=[(1.0, 0.0, 0.0, 0.0), (1.8, 0.0, -1.5, 0.3, 6.0, -1.5, 0.0), (3.6, 0.0, -1.5, 0.3, 6.0, -1.5, 0.0), (4.8, 0.0, 0.0, 0.0)],
          glow=[(["fovea"], [(1.6, 0.0), (1.9, 9.0), (2.1, 3.0), (2.4, 12.0), (3.6, 12.0), (4.2, 0.0)])])
    # Backpedalling: the boosters tip past upright and it flies backward nose up, then they swing
    # forward and it runs back onto its station: a jet that can reverse.
    tip = [(0.4, 0.0), (1.0, 18.0), (2.0, 18.0), (2.6, -40.0), (3.4, -40.0), (4.0, 0.0)]
    b.act("backpedal", 4.8, {j: tip for j in BOOST},
          body=[(0.6, 0.0, 0.0, 0.0), (1.6, 0.0, -14.0, 0.5, 0.0, 6.0, 0.0), (2.2, 0.0, -15.0, 0.5, 0.0, 5.0, 0.0), (3.2, 0.0, -2.0, 0.0, 0.0, -6.0, 0.0), (4.8, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.5, 0.0), (1.0, 5.0), (2.0, 4.0), (2.6, 7.0), (3.4, 6.0), (4.2, 0.0)])])
    # Movement: it sets off in hover, the boosters leaning forward, and changes into flight mode
    # as it gathers speed, a jet at full pace (crossfaded by speed); slowing, it changes back.
    glow = {"parts": burn, "k": KESTREL_BURN}
    b.gait_option("hover", tracks=held({j: (-15.0, 0.0, 0.0, 0.0, 0.0, 0.0) for j in BOOST}), glow=glow)
    b.halo = [("booster_ring", KESTREL_HALO), ("exhaust", KESTREL_HALO), ("tail_exhaust", 3.0)]   # its boosters hot, its exhaust hotter, its bloom wide at full burn (Ryan, 13 November: "It could also glow hotter during flight mode")
    b.gait(tracks=held(FLIGHT), glow=glow, body_hold=(0.0, 0.0, 0.0, 0.0, -4.0, 0.0), start=("hover", 0.25, 0.85))
    b.fires = {"fovea_designator": ("designate", 1.4, 2.9)}   # its fixed weapon fires with a slice of its act: the iris snapping down and the fovea's flare (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.move(slide=0.35, bank=32.0, accel=0.7, heft=0.1, oversteer=0.4)

needletail.maker = "kestrel"



def _gp_gun_house(b, name, pin, shape, carries, cx, ty, tz, w, l, h, facing=0.0, limits=(-75.0, 75.0), fits=None):
    """A faceted gun house on a yaw joint over a dark ring: its face raked, its flanks leaning
    in, its back stepped down; the stock gun its class out of its face (the Giant Petrel's look
    test of 31 October, tools/lowforge/looks/kestrel_looks6.py). `facing` turns the whole house
    to its left as built, in degrees (ninety faces it out to the left), so its gun rests pointing
    there and swings from there."""
    b.prism("z", cx, ty, tz + 0.4, w * 0.55, 1.0, "steel.dark", 8, "turret_ring", phase=math.pi / 8)
    turn = Matrix.Translation((cx, ty, 0.0)) @ Matrix.Rotation(math.radians(facing), 4, "Z")
    fwd = Vector((-math.sin(math.radians(facing)), math.cos(math.radians(facing)), 0.0))
    with b.joint(name, (cx, ty, tz + 0.9), axis="yaw", limits=limits):
        a = w / 2.0
        secs = [(l * 0.55, a * 0.6, tz + h * 0.4), (l * 0.2, a, tz + h), (-l * 0.3, a, tz + h), (-l * 0.5, a * 0.8, tz + h * 0.7)]
        b.loft([(y, [(-aa, tz + 0.8), (aa, tz + 0.8), (aa * 0.7, z1), (-aa * 0.7, z1)]) for (y, aa, z1) in secs], "steel.plate", "turret_house", turn)
        at = Vector((cx, ty, tz + h * 0.62)) + fwd * (l * 0.3)
        b.stock(pin, tuple(at), shape, forward=tuple(fwd), scale=0.8, carries=carries, fits=fits)


def _gp_dome_mount(b, name, pin, shape, carries, cx, cy, cz, r, facing=0.0, limits=(-75.0, 75.0), fits=None, scale=0.5, lift=0.0):
    """An omnidirectional gun mount for a roof: a low faceted dome on a yaw joint over a dark ring,
    a cobalt band round it, the stock gun its class out of its front, half sunk in it (the Giant
    Petrel's back quarters; Ryan, 13 November: "omnidirectional mounts strapped to or embedded into
    the back quarters of the crew area"). `facing` turns it to its left as built, in degrees (180
    faces it aft), so its gun rests pointing there and swings from there. The dome's height goes
    with its radius (3 to a radius of 3); `lift` stands the ring up as a pedestal that tall, so
    every class's receiver clears the roof as it turns."""
    k = r / 3.0
    ring = lambda rr, z: [(cx + rr * math.cos(math.pi / 8 + i * math.pi / 4), cy + rr * math.sin(math.pi / 8 + i * math.pi / 4), z) for i in range(8)]
    z0 = cz + lift
    b.prism("z", cx, cy, cz + (lift + 0.4 * k - 0.1) / 2.0, r + 0.5, lift + 0.4 * k + 0.1, "steel.dark", 8, "turret_ring", phase=math.pi / 8)
    fwd = Vector((-math.sin(math.radians(facing)), math.cos(math.radians(facing)), 0.0))
    with b.joint(name, (cx, cy, z0 + 0.4 * k), axis="yaw", limits=limits):
        _rings(b, [ring(r, z0 + 0.3 * k), ring(r * 0.97, z0 + 1.4 * k), ring(r * 0.8, z0 + 2.4 * k), ring(r * 0.42, z0 + 3.0 * k)], "steel.plate", "turret_house")
        _rings(b, [ring(r * 0.99, z0 + 0.85 * k), ring(r * 0.99, z0 + 1.2 * k)], "livery.livery", "turret_band", cap=False)
        at = Vector((cx, cy, z0 + 1.35 * k)) + fwd * (r * 0.9)
        b.stock(pin, tuple(at), shape, forward=tuple(fwd), scale=scale, carries=carries, fits=fits)


def _gp_ses_booster(b, cx, cz, y0, y1, w, h):
    """The Navy SES's booster closing a hull astern, its mouth flattened: a wide flat hexagonal
    drum from `y0` back to `y1`, the lit ring and the exhaust at its end (the look test's)."""
    b.loft([(y0, hexagon(cx, cz, w, h)), (y1, hexagon(cx, cz, w, h))], "steel.dark", "booster")
    b.loft([(y1 + 1.6, hexagon(cx, cz, w + 0.8, h + 0.6)), (y1 - 0.2, hexagon(cx, cz, w + 0.8, h + 0.6))], "amber.engine", "booster_ring")
    b.loft([(y1 - 0.3, hexagon(cx, cz, w + 0.2, h + 0.1)), (y1 - 0.8, hexagon(cx, cz, w - 1.4, h - 1.0))], "amber.exhaust", "exhaust")


def _gp_windows(b, face, y0, y1, n, f0, f1, gap=0.4, label="window"):
    """A row of `n` windows along a leaning face from `y0` back to `y1`, each a thin pane of the
    bridge's glass a `gap` share of its pitch apart; `face(y)` gives the face's foot and head as
    ((x, z), (x, z)) at y, and `f0`..`f1` the band up it the panes fill."""
    pitch = (y0 - y1) / float(n)
    for k in range(n):
        ya = y0 - pitch * k - pitch * gap * 0.5
        yb = ya - pitch * (1.0 - gap)
        pts = []
        for (y, f) in ((ya, f0), (yb, f0), (yb, f1), (ya, f1)):
            (x0, z0), (x1, z1) = face(y)
            pts.append((x0 + (x1 - x0) * f, y, z0 + (z1 - z0) * f))
        (x0, z0), (x1, z1) = face((ya + yb) / 2.0)
        nrm = Vector((z1 - z0, 0.0, x0 - x1)).normalized()
        if nrm.dot(Vector((x0, 0.0, 0.0))) < 0.0:
            nrm = -nrm
        _slab(b, [tuple(Vector(p) + nrm * 0.12) for p in pts], tuple(nrm), 0.24, "glass.glass", label)


def _gp_salvo_rack(b, tag, cx, y_front, y_back, z_roof, w, cols=2):
    """One rack of the Spindrift Salvo: a box of tubes (`cols` columns of two) sunk in the roof
    with only its lid proud, hinged at its back (joint salvo_<tag>) so its face rises out of the
    roof to fire; each tube's floor and its back-blast vent banked dark at rest and lit as it fires
    (salvo_<tag><n>, the top row first, left to right)."""
    zl = z_roof + 0.4
    hinge = (cx, y_back, z_roof - 2.0)
    with b.joint("salvo_" + tag, hinge, axis="pitch", limits=(-2.0, 34.0)):
        sec = [(cx - w / 2.0, z_roof - 5.4), (cx + w / 2.0, z_roof - 5.4), (cx + w / 2.0, zl - 0.6), (cx + w / 2.0 - 0.6, zl), (cx - w / 2.0 + 0.6, zl), (cx - w / 2.0, zl - 0.6)]
        b.loft([(y_front, sec), (y_back, sec)], "steel.plate", "salvo_box")
        b.loft([(y_front - 0.6, rect(cx, w - 2.0, zl - 0.1, zl + 0.15)), (y_back + 0.6, rect(cx, w - 2.0, zl - 0.1, zl + 0.15))], "livery.livery", "salvo_lid")
        n = 0
        for z in (z_roof - 1.3, z_roof - 3.8):
            for c in range(cols):
                n += 1
                x = cx + (c - (cols - 1) / 2.0) * (w / cols)
                _tube(b, (x, y_front - 6.0, z), (x, y_front + 0.3, z), 1.1, 0.8, 8, "steel.dark", "salvo_%s%d" % (tag, n), floor_material="amber.ember", floor_depth=0.8)
                _disc(b, (x, y_back - 0.15, z), (0.0, -1.0, 0.0), 1.0, 8, "amber.ember", "salvo_%s%d_blast" % (tag, n))


def _gp_uplink(b, uy, uz, panel=5.6):
    """The Reheat Uplink: a flat hexagonal array on a yaw joint over a short drum, facing forward
    and a little up, its core lit."""
    b.prism("z", 0.0, uy, uz + 0.8, 2.0, 1.6, "steel.dark", 6, "uplink_mast")
    with b.joint("sensor_uplink", (0.0, uy, uz + 1.6), axis="yaw", limits=(-150.0, 150.0)):
        b.box(-0.9, 0.9, -1.0, 1.0, uz + 1.4, uz + panel + 1.2, "steel.dark", "uplink_yoke", Matrix.Translation((0.0, uy, 0.0)))
        tilt = Matrix.Translation((0.0, uy + 1.2, uz + panel + 1.4)) @ Matrix.Rotation(math.radians(15.0), 4, "X")
        b.loft([(-0.6, _poly(panel, 6, math.pi / 6)), (0.6, _poly(panel, 6, math.pi / 6))], "steel.plate", "uplink_dish", tilt)
        b.loft([(0.55, _poly(panel * 0.82, 6, math.pi / 6)), (0.75, _poly(panel * 0.78, 6, math.pi / 6))], "livery.livery", "uplink_face", tilt)
        b.loft([(0.7, _poly(1.8, 6, math.pi / 6)), (1.3, _poly(1.3, 6, math.pi / 6))], "amber.lit", "uplink_core", tilt)


def _gp_giant_booster(b, cx, cz, y_front, y_back, r, band=(1.2, 4.8), nose=0.0):
    """One of the line's giant boosters: a hexagonal drum, a vertex at its top, from `y_front`
    back to `y_back`; a cobalt band round it near its front, painted on rather than proud; the
    lit ring at its end and the exhaust's mouth inside the ring; `nose`, given, a faceted cone
    that long ahead of the drum, tapering to a small hexagon."""
    ph = math.pi / 6
    if nose > 0.0:
        b.loft([(y_front + nose, _hexr(cx, cz, r * 0.3)), (y_front + nose * 0.45, _hexr(cx, cz, r * 0.78)), (y_front, _hexr(cx, cz, r))], "steel.plate", "booster_nose")
    b.prism("y", cx, (y_front + y_back) / 2.0, cz, r, y_front - y_back, "steel.dark", 6, "booster", phase=ph)
    b.prism("y", cx, y_front - (band[0] + band[1]) / 2.0, cz, r + 0.1, band[1] - band[0], "livery.livery", 6, "booster_band", phase=ph)
    b.prism("y", cx, y_back, cz, r + 0.4, 1.6, "amber.engine", 6, "booster_ring", phase=ph)
    b.loft([(y_back - 0.8, _hexr(cx, cz, r + 0.2)), (y_back - 1.3, _hexr(cx, cz, r - 0.6))], "amber.exhaust", "exhaust")


def giant_petrel(b):
    """Kestrel "Giant Petrel" (K-21 Mk I Ground-Effect Flagship): the formation leader, banking
    the team's rerolls and selling them as actions (Ryan's go, 21 October: Kestrel's capital, an
    assault hover, aggressive where the Swallowtail is the supportive mobile HQ). Its hull from
    the look tests of 31 October (Ryan: "Something more like a military catamaran"; the second
    round's sheet, docs/looks/kestrel_giant3.png), mixed on his word of 12 November: "The engines
    and rear spoiler of the racer, on the command ship body of the Navy SES take", the Navy SES as
    reviewed for its topside (his pick, the same day). His notes on that first cut, the same
    evening: "Its a command ship, more weapons should be able to cover its sides and rear" (so the
    bow and both quarters, his pick); the missile rack "would just shoot into the mast. Swap their
    places"; the racer's engines "just kind of clip into the hull. They should be integrated
    better", and the rear deck "needs something in between the boosters"; "Bring back the SES
    boosters, too, so it has 4 total"; "Windows along the side, as well, where appropriate." And on
    the second cut, 13 November: the side windows "too small, like an airliner, implying
    compartments"; the rear cannons "a resting position in line with the ship. It's not a slow
    carrier"; the skirt pieces "look too boat and not flying hovercraft"; the salvo "a pair of
    racks, or even 3, to really give that ripple fire effect from a command ship"; the mast moved
    back and "slanted, a bit more Kestrel aerodynamic". And on the third cut, the same day: "i
    meant 3 racks in line down the body, not across, back at the size they were"; the deckhouse's
    front sleeker, "to make the windshield wrap around the front, and not just a slab on the front
    of the ship". And on the fourth: "The rear guns clip right through the rear spoiler. They'll
    need a different approach"; the front "a more angular take to match the rest of the body"; the
    ripple "a bit more desynced"; the bows' livery "a little meh". And on the fifth: the spoiler on
    its fins again ("It was more aquatic, this one is like a race car"); "we have to move the rear
    guns entirely ... mount them on omnidirectional mounts strapped to or embedded into the back
    quarters of the crew area"; the windshield "still too 'soft.' Not fast or sharp enough looking".
    And on the sixth: the quarters' guns "can face forward as well, right?", and "could be bigger,
    you could lower the spoiler a tad to make room for them to fire overtop instead of under";
    "there's something really messed up with the front windscreen". And on the seventh: "default
    the aft guns to facing forward, or the skirmish animations will be awkward"; "The windscreen
    pokes through the sides. [It] can sit lower on the front anyway, more vertically centered"; the
    spoiler "back up so the guns firing line is under it. So I guess the whole spoiler can be bigger".
    And on the eighth: the "front windshield still poking out the sides"; the spoiler's side struts
    raked back harder, their tops kept and their feet drawn forward.

    The Navy SES's body: two knife hulls, their stems raked back as a wave piercer's, dark below
    the chine and chrome above, a cobalt chine stripe and straight deck stripes, each closing
    astern onto the navy's flattened booster; the cross deck between them over the air cushion,
    open fore and aft, lift glowing under it; a raised centre bow between the knives carrying the
    fore gun house, a cobalt spearhead down each bow's deck; the deckhouse spanning the deck, every
    face leaning in, its front a sharp prow raked steeply back, each facet of it a smooth twisted
    surface from its foot to the roof's edge, the bridge's glass following it a band up its middle,
    a raked pane each side of the prow, and four long windows down each flank; on its roof the Spindrift Salvo's
    three racks flush in line down the middle, each the size of the second cut's one rack (fixed,
    no pin; salvo_f, salvo_m, salvo_a, their faces rising out of the roof one after another to fire
    over the bow, eighteen tubes rippling, each rack at its own pace), the integrated mast behind them, a swept faceted fin
    raked aft, carrying the Reheat Uplink's array on its tip (fixed, no pin; sensor_uplink). Astern of the deckhouse, between the hulls: a raised aft deckhouse in the
    same style, a long window down each flank and a hatch in its raked back, and either side of it
    one of the racer's giant boosters (with the navy's pair, the Immelmann Booster, fixed, no pin),
    each on its own plinth on the deck, a faceted nose ahead of it and a pylon to the aft
    deckhouse; over them the racer's swept cobalt aerofoil spanning the hulls on two fins standing
    on the hulls' outer edges astern, big and high, the quarters' line of fire astern under it. On
    each of the deckhouse roof's back quarters, either side of the mast, an omnidirectional mount,
    a faceted dome on a short pedestal, resting facing forward in line with the ship, its arc round
    the outboard side to dead aft. Mounts in the
    die's order: hp_1 the fore gun house on the centre bow (the Overclocked Railgun), hp_2 the left
    quarter's dome (the Twin Autoguns), hp_3 the right quarter's (the Twin Autoguns, a placeholder in
    the vent's old slot since the refit pass).
    Floats: the keels at z = 6."""
    HX = 22.0
    HULL = [(78.0, 0.8, 7.6, 8.6), (72.0, 3.2, 6.8, 12.4), (62.0, 7.6, 6.2, 17.8), (48.0, 11.4, 6.0, 20.0),
            (20.0, 13.0, 6.0, 20.0), (-40.0, 13.0, 6.0, 20.0), (-56.0, 12.4, 6.4, 20.0), (-62.0, 11.4, 7.0, 19.4)]   # (y, w, keel, deck), bow to stern

    def deck(y):
        return _lerp_at(HULL, y)[2]

    def side(w, z0, z1, s, upper):
        zc = z0 + (z1 - z0) * 0.38
        pts = ([(HX - w * 0.46, zc), (HX + w * 0.5, zc), (HX + w * 0.34, z1), (HX - w * 0.36, z1)] if upper else
               [(HX - w * 0.12, z0), (HX + w * 0.12, z0), (HX + w * 0.5, zc), (HX - w * 0.46, zc)])
        return pts if s > 0 else [(-x, z) for (x, z) in reversed(pts)]

    for s in (-1.0, 1.0):
        b.loft([(y, side(w, z0, z1, s, False)) for (y, w, z0, z1) in HULL], "steel.dark", "hull_low")
        b.loft([(y, side(w, z0, z1, s, True)) for (y, w, z0, z1) in HULL], "steel.plate", "hull")
        secs = []
        for (y, w, z0, z1) in HULL[2:-1]:
            zc, x = z0 + (z1 - z0) * 0.38, HX + w * 0.5
            pts = [(x + 0.4, zc), (x - 0.3, zc + 0.8), (x - 1.2, zc), (x - 0.3, zc - 0.8)]
            secs.append((y, pts if s > 0 else [(-xx, z) for (xx, z) in reversed(pts)]))
        b.loft(secs, "livery.livery", "chine_stripe")
        # The afterdeck's stripe, its gun house gone up to the deckhouse's roof; on the foredeck, a cobalt spearhead
        # laid down the bow, narrowing with the deck to a point over the stem, its back cut on a slant
        # (Ryan, 13 November: the plain stripe there "a little meh").
        b.loft([(y, rect(s * HX, 3.6, deck(y) - 0.4, deck(y) + 0.3)) for y in (-36.0, -48.0, -60.0)], "livery.livery", "deck_stripe")
        spear = [(43.0, 6.4), (50.0, 5.6), (56.0, 4.6), (62.0, 3.4), (66.0, 2.0), (69.0, 0.4)]   # (y, width) back to front
        rings = []
        for k, (y, w) in enumerate(spear):
            back = 3.6 if k == 0 else 0.0   # the back cut on a slant, its outer corner furthest aft
            pts = [(s * (HX - w / 2.0), y + back, deck(y + back) - 0.4), (s * (HX + w / 2.0), y, deck(y) - 0.4),
                   (s * (HX + w / 2.0), y, deck(y) + 0.3), (s * (HX - w / 2.0), y + back, deck(y + back) + 0.3)]
            rings.append(pts if s > 0 else list(reversed(pts)))
        _rings(b, rings, "livery.livery", "deck_stripe")
        # Astern, the hull closes onto the navy's flattened booster.
        y, w, z0, z1 = HULL[-1]
        b.loft([(y, [(s * HX + p[0], p[1]) for p in hexagon(0.0, (z0 + z1) / 2.0, w, z1 - z0)]), (y - 4.0, hexagon(s * HX, 13.4, 11.6, 7.4))], "steel.plate", "tail_fairing")
        _gp_ses_booster(b, s * HX, 13.4, y - 4.0, y - 10.0, 11.0, 7.0)
    # The cross deck over the cushion, open fore and aft (Ryan, 13 November: the skirt's fingers and
    # bags "look too boat and not flying hovercraft"), the lift glowing under it.
    b.loft([(45.0, rect(0.0, 2 * HX - 4.0, 13.0, 20.0)), (-57.0, rect(0.0, 2 * HX - 4.0, 13.0, 20.0))], "steel.plate", "cross_deck")
    for (x, y) in ((-8.0, 24.0), (8.0, 24.0), (0.0, 0.0), (-8.0, -26.0), (8.0, -26.0)):
        _disc(b, (x, y, 12.9), (0.0, 0.0, -1.0), 2.8, 6, "amber.engine", "lift_nozzle")
    # The centre bow between the knives: a raised wedge, the fore gun house on it (hp_1).
    CB = [(62.0, 1.2, 17.6, 19.4), (55.0, 12.0, 15.0, 20.0), (45.0, 2 * HX - 5.0, 13.0, 20.0)]
    b.loft([(y, [(-w * 0.2, z0), (w * 0.2, z0), (w * 0.5, (z0 + z1) / 2.0), (w * 0.44, z1), (-w * 0.44, z1), (-w * 0.5, (z0 + z1) / 2.0)]) for (y, w, z0, z1) in CB],
           "steel.plate", "centre_bow")
    _gp_gun_house(b, "turret_fore", "hp_1", "barrel", "overclocked_railgun", 0.0, 51.0, 20.0, 9.0, 12.0, 5.0)
    # The deckhouse: every face leaning in, four long windows down each flank, a gallery's (Ryan,
    # 13 November: the row of small ones read "like an airliner, implying compartments"). Its front
    # a sharp prow in plan, its foot and its roof's edge the same corners, the roof's set far back, so
    # the face between them rakes steeply back all the way round; the bridge's glass a raked pane
    # each side of the prow's crease, its outer pillar swept back, and a swept pane down each side
    # coming to a point aft (Ryan, 13 November: "make the windshield wrap around the front"; "still
    # too 'soft.' Not fast or sharp enough looking").
    DZ = 20.0
    DH = [(28.0, 26.2, 15.1, 31.05), (4.0, 26.4, 16.0, 31.6), (-26.0, 26.4, 16.0, 31.6), (-33.0, 26.2, 12.0, 25.0)]   # (y, base half width, roof half width, roof)
    b.loft([(y, [(-a, DZ), (a, DZ), (t, zt), (-t, zt)]) for (y, a, t, zt) in DH], "steel.panel", "deckhouse")
    FY0, BROW = 28.0, 0.18   # where the front leaves the run; how far forward the roof's edge reaches, as a share of the foot's reach
    FRONT = [(26.2, 28.0), (24.2, 33.5), (0.0, 43.5)]   # the foot's corners, the right flank round to the prow's point
    a0, t0, zt0 = _lerp_at(DH, FY0)
    foot = [(x, y, DZ) for (x, y) in FRONT] + [(-x, y, DZ) for (x, y) in reversed(FRONT[:-1])]
    brow = [(x * t0 / a0, FY0 + (y - FY0) * BROW, zt0) for (x, y, z) in foot]   # the roof's edge, the same corners drawn in and set back
    # Each facet runs straight from its foot to its brow, but the brow's edges are not parallel to
    # the foot's, so a facet twists: built whole it was two flat triangles creased across it that
    # the glass cut through (Ryan, 13 November: "there's something really messed up with the front
    # windscreen"). So each is laid as the smooth surface it is, finely, and the glass follows it.
    mid = Vector((0.0, FY0, (DZ + zt0) / 2.0))
    NK, NF = 10, 8

    def facet(i, k, f):
        return Vector(foot[i]).lerp(Vector(foot[i + 1]), k).lerp(Vector(brow[i]).lerp(Vector(brow[i + 1]), k), f)

    def facet_out(i, k, f):
        dk = Vector(foot[i + 1]).lerp(Vector(brow[i + 1]), f) - Vector(foot[i]).lerp(Vector(brow[i]), f)
        df = Vector(brow[i]).lerp(Vector(brow[i + 1]), k) - Vector(foot[i]).lerp(Vector(foot[i + 1]), k)
        n = dk.cross(df).normalized()
        return n if n.dot(facet(i, k, f) - mid) > 0.0 else -n
    _rings(b, [[tuple(facet(i, m / NK, j / NF)) for i in range(len(foot) - 1) for m in range(NK)] + [tuple(facet(len(foot) - 2, 1.0, j / NF))]
               for j in range(NF + 1)], "steel.panel", "deckhouse", cap=False)
    _slab(b, [(x, y, zt0 - 0.1) for (x, y, z) in brow], (0.0, 0.0, 1.0), 0.2, "steel.panel", "deckhouse")
    # The glass, (along the facet, up it): a raked pane each side of the prow, its outer pillar swept
    # back, a thin mullion on the crease, each a thin shell over its facet's surface; a band up the
    # middle of the front, its foot a quarter up and its head three quarters (Ryan, 13 November: it
    # "can sit lower on the front anyway, more vertically centered"). Nothing on the short facets
    # each side of the prow, which face out to the flanks, so no glass shows from the sides or astern
    # ("front windshield still poking out the sides"), and each pane's outer edge held a little in
    # from its corner.
    PANES = {1: [(0.08, 0.25), (0.985, 0.25), (0.985, 0.75), (0.22, 0.75)],
             2: [(0.015, 0.25), (0.92, 0.25), (0.78, 0.75), (0.015, 0.75)]}   # the facet's index round the front: its corners
    NU, NV = 8, 5
    for i, (c0, c1, c2, c3) in PANES.items():
        def kf(u, v):
            lo, hi = ((1 - u) * c0[0] + u * c1[0], (1 - u) * c0[1] + u * c1[1]), ((1 - u) * c3[0] + u * c2[0], (1 - u) * c3[1] + u * c2[1])
            return (1 - v) * lo[0] + v * hi[0], (1 - v) * lo[1] + v * hi[1]
        bm = bmesh.new()
        shell = []
        for d in (0.08, 0.28):   # its inner face just off the facet, its outer a pane's thickness out
            grid = []
            for a in range(NU + 1):
                row = []
                for c in range(NV + 1):
                    k, f = kf(a / NU, c / NV)
                    row.append(bm.verts.new(facet(i, k, f) + facet_out(i, k, f) * d))
                grid.append(row)
            shell.append(grid)
        inner, outer = shell
        for a in range(NU):
            for c in range(NV):
                bm.faces.new([outer[a][c], outer[a + 1][c], outer[a + 1][c + 1], outer[a][c + 1]])
                bm.faces.new([inner[a][c + 1], inner[a + 1][c + 1], inner[a + 1][c], inner[a][c]])
        rim = [(a, 0) for a in range(NU)] + [(NU, c) for c in range(NV)] + [(a, NV) for a in range(NU, 0, -1)] + [(0, c) for c in range(NV, 0, -1)]
        for (ra, rc), (rb, rd) in zip(rim, rim[1:] + rim[:1]):
            bm.faces.new([inner[ra][rc], inner[rb][rd], outer[rb][rd], outer[ra][rc]])
        # One glass tile across the pane, its gradient corner to corner, so a pane facing the
        # light shows its sheen rather than one flat tone.
        o = facet(i, *kf(0.0, 0.0))
        across = facet(i, *kf(1.0, 0.0)) - o
        over = facet_out(i, *kf(0.5, 0.5))
        along = over.cross(across).normalized()
        if along.dot(facet(i, *kf(0.0, 1.0)) - o) < 0.0:
            along = -along
        height = max((facet(i, *kf(u, 1.0)) - facet(i, *kf(u, 0.0))).dot(along) for u in (0.0, 0.5, 1.0))
        b._finish(bm, "glass.glass", "bridge_glass", frame=(o, along, across.normalized(), over, (across.length, max(0.5, height))))
    for s in (-1.0, 1.0):
        b.loft([(28.6, rect(s * 13.4, 2.0, 31.4, 31.9)), (-16.5, rect(s * 13.4, 2.0, 31.4, 31.9))], "livery.livery", "roof_stripe")

        def flank(y, s=s):
            a, t, zt = _lerp_at(DH, y)
            return (s * a, DZ), (s * t, zt)
        _gp_windows(b, flank, 27.0, -23.0, 4, 0.30, 0.62, gap=0.1)
    # On the roof the salvo's three racks flush in line down the middle, each the second cut's one
    # rack again, six tubes, firing over the bow in a ripple (Ryan, 13 November: "i meant 3 racks
    # in line down the body, not across, back at the size they were"), and the integrated mast
    # behind them, moved back and raked, a swept faceted fin (his word: "slanted, a bit more
    # Kestrel aerodynamic"), the uplink's array on its tip.
    MZ = 31.4
    for tag, yf in (("f", 26.5), ("m", 14.5), ("a", 2.5)):
        _gp_salvo_rack(b, tag, 0.0, yf, yf - 9.0, _lerp_at(DH, yf - 4.5)[2], 13.0, cols=3)
    MB = [(0.0, -10.0), (5.2, -14.0), (5.2, -22.5), (0.0, -25.5), (-5.2, -22.5), (-5.2, -14.0)]    # its foot on the roof, a point fore and aft
    MT = [(0.0, -22.0), (1.9, -23.5), (1.9, -27.0), (0.0, -28.5), (-1.9, -27.0), (-1.9, -23.5)]   # its tip, raked well aft
    MTOP = MZ + 10.6

    def mast_ring(t, grow=1.0):
        c = Vector((0.0, -18.0, 0.0)).lerp(Vector((0.0, -25.25, 0.0)), t)
        return [(c.x + (a[0] + (b2[0] - a[0]) * t) * grow, c.y + ((a[1] + (b2[1] - a[1]) * t) - c.y) * grow, MZ + (MTOP - MZ) * t) for a, b2 in zip(MB, MT)]
    _rings(b, [mast_ring(0.0), mast_ring(1.0)], "steel.panel", "mast")
    _rings(b, [mast_ring(0.74, 1.04), mast_ring(0.8, 1.04)], "livery.livery", "mast_band")
    _gp_uplink(b, -25.25, MTOP)
    # Astern of the deckhouse, between the hulls: the aft deckhouse, every face leaning in, a long
    # window down each flank and a hatch in its raked back; either side of it a giant booster on
    # its plinth, a faceted nose ahead of it and a pylon to the aft deckhouse.
    AD = [(-28.0, 5.0, 3.0, 28.4), (-47.0, 5.0, 3.0, 28.4), (-55.0, 4.6, 2.4, 21.4)]   # (y, base half width, roof half width, roof)
    b.loft([(y, [(-a, DZ), (a, DZ), (t, zt), (-t, zt)]) for (y, a, t, zt) in AD], "steel.panel", "aft_deckhouse")
    b.loft([(-31.0, rect(0.0, 1.6, 28.2, 28.7)), (-46.6, rect(0.0, 1.6, 28.2, 28.7))], "livery.livery", "roof_stripe")
    for s in (-1.0, 1.0):
        def aflank(y, s=s):
            a, t, zt = _lerp_at(AD, y)
            return (s * a, DZ), (s * t, zt)
        _gp_windows(b, aflank, -32.5, -46.5, 1, 0.30, 0.68, gap=0.06)
    # The hatch: a dark door in the raked back, a cobalt frame round it and a lamp over it.
    def back(f, x):
        """A point on the raked back, `f` up it from its foot, at `x` across."""
        y = -55.0 + 8.0 * f
        return (x, y, _lerp_at(AD, y)[2])
    rn = Vector((0.0, -7.0, 8.0)).normalized()   # the back's normal, out and up
    _slab(b, [tuple(Vector(back(f, x)) + rn * 0.1) for (f, x) in ((0.12, -1.9), (0.12, 1.9), (0.78, 1.9), (0.78, -1.9))], tuple(rn), 0.2, "livery.livery", "hatch_frame")
    _slab(b, [tuple(Vector(back(f, x)) + rn * 0.22) for (f, x) in ((0.16, -1.5), (0.16, 1.5), (0.74, 1.5), (0.74, -1.5))], tuple(rn), 0.2, "steel.dark", "hatch")
    _slab(b, [tuple(Vector(back(f, x)) + rn * 0.15) for (f, x) in ((0.84, -0.8), (0.84, 0.8), (0.92, 0.8), (0.92, -0.8))], tuple(rn), 0.3, "amber.lit", "hatch_lamp")
    BX, BZ, BR = 11.0, 25.4, 5.2   # the giant boosters' axis and size
    hw = BR * math.cos(math.pi / 6)   # a drum's half width, its side faces upright
    for s in (-1.0, 1.0):
        cx = s * BX
        _gp_giant_booster(b, cx, BZ, -40.0, -62.0, BR, nose=5.5)
        plinth = lambda w, z: [(cx - w, DZ), (cx + w, DZ), (cx + w * 0.84, z), (cx - w * 0.84, z)]
        b.loft([(-37.5, plinth(3.0, 21.0)), (-40.5, plinth(5.4, BZ - BR / 2.0)), (-56.0, plinth(5.4, BZ - BR / 2.0)), (-58.5, plinth(3.0, 21.0))], "steel.dark", "plinth")
        # The pylon: a web from the aft deckhouse's flank to the drum's inner face.
        x0, x1 = s * 3.4, s * (BX - hw + 0.2)
        web = lambda z0, z1: [(min(x0, x1), z0), (max(x0, x1), z0), (max(x0, x1), z1), (min(x0, x1), z1)]
        b.loft([(-38.0, web(24.6, 25.4)), (-41.0, web(23.6, 27.0)), (-50.0, web(23.6, 27.0)), (-53.0, web(24.6, 25.4))], "steel.dark", "pylon")
    # The quarters: an omnidirectional dome on each of the deckhouse roof's back quarters, either side
    # of the mast (Ryan, 13 November: "we have to move the rear guns entirely ... mount them on
    # omnidirectional mounts strapped to or embedded into the back quarters of the crew area"),
    # resting facing forward in line with the ship ("default the aft guns to facing forward, or the
    # skirmish animations will be awkward"), their arc from dead ahead round the outboard side to a
    # little inboard of dead aft, where the other quarter's gun closes it. Bigger, on short pedestals
    # ("I feel like they could be bigger"), every class's receiver clear of the roof, so they fire
    # over the boosters astern and under the aerofoil (hp_2, hp_3).
    QX, QY, QR = 11.0, -21.0, 4.2
    QUARTER_FITS = {"rack": ("rack_round", 0.45), "dish": 0.4, "blade": 0.8}   # each clear of the roof under its gun's line
    for s, pin, name in ((-1.0, "hp_2", "turret_l"), (1.0, "hp_3", "turret_r")):
        lim = (0.0, 195.0) if s < 0 else (-195.0, 0.0)   # outboard is a left-hand turn for the left one, facing forward
        _gp_dome_mount(b, name, pin, "twin_barrel", "twin_autoguns", s * QX, QY, _lerp_at(DH, QY)[2], QR, facing=0.0, limits=lim,
                       fits=QUARTER_FITS, scale=0.7, lift=1.0)
    # The racer's stern wing: a swept cobalt aerofoil spanning the hulls on the tips of two fins
    # standing on the hulls' outer edges astern, a little canted (Ryan, 13 November: "I liked the
    # other spoiler better. It was more aquatic, this one is like a race car"), high, so the
    # quarters' line of fire astern runs under it, and big, the fins and the wing both, the guns no
    # longer resting in its way (Ryan, 13 November: "The sides of the rear spoiler could be bigger,
    # now the the guns aren't in the way. And I actually take it back, put the spoiler back up so the
    # guns firing line is under it. So I guess the whole spoiler can be bigger").
    WZ2, FIN_X, TIP_X = 37.0, 26.0, 29.0   # the aerofoil's height, over the quarters' line astern; the fins' feet and tips across
    for s in (-1.0, 1.0):
        # Each fin's foot drawn forward under its top, its leading edge more than its trailing, so both
        # rake back harder (Ryan, 13 November: "Keep the top of the spoiler where is is in space,
        # shift the bottom vertices of each side strut forward towards the nose, moving the forward
        # vertex more than the rear").
        _rings(b, [_fin_section(s * FIN_X, -38.0, -58.0, deck(-56.0) - 0.5, 0.8), _fin_section(s * TIP_X, -51.0, -66.0, WZ2, 0.6)], "livery.livery", "fin")
    WING = [(-TIP_X, -51.5, -66.0, 0.55), (-12.0, -46.5, -61.0, 0.9), (0.0, -42.0, -57.5, 1.1), (12.0, -46.5, -61.0, 0.9), (TIP_X, -51.5, -66.0, 0.55)]
    _rings(b, [_blade_section(x, le, te, WZ2, t) for (x, le, te, t) in WING], "livery.livery", "stern_wing")

    # Idle acts (four, loud, never in step; a capital's heavy servos). Degrees and seconds; a body
    # key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k).
    boosters = ["booster_ring", "exhaust"]
    # The salvo: the three racks' faces rise out of the roof one after another, front to back,
    # then the eighteen tubes ripple down them, each rack firing at its own pace and in its own
    # order, out of step with the others (Ryan, 13 November: "a bit more desynced"), each
    # back-blast flaring as the hull shrugs back; the racks come down again.
    PACE = {"f": (2.05, 0.23, (1, 5, 3, 6, 2, 4), (0.0, 0.03, -0.02, 0.04, 0.0, -0.03)),
            "m": (2.24, 0.29, (6, 2, 4, 1, 5, 3), (0.02, -0.03, 0.0, 0.05, -0.02, 0.0)),
            "a": (2.13, 0.19, (3, 4, 1, 6, 2, 5), (-0.02, 0.04, 0.01, -0.03, 0.02, 0.0))}   # first shot, beat, order, a nudge to each shot
    ripple = []
    for tag, (t0, beat, order, nudge) in PACE.items():
        for k, n in enumerate(order):
            t1 = round(t0 + beat * k + nudge[k], 3)
            ripple.append((["salvo_%s%d_floor" % (tag, n), "salvo_%s%d_blast" % (tag, n)], [(t1, 0.0), (t1 + 0.12, 16.0), (t1 + 0.55, 2.0), (t1 + 1.3, 0.0)]))
    rise = lambda d, up: [(0.4 + d, 0.0), (0.4 + d + up, 30.0), (5.1 + d, 30.0), (6.2 + d, 0.0)]
    b.act("salvo", 7.2, {"salvo_f": rise(0.0, 1.1), "salvo_m": rise(0.25, 1.3), "salvo_a": rise(0.5, 1.0)},
          body=[(2.0, 0.0, 0.0, 0.0), (2.3, 0.0, -0.5, 0.0, 0.0, 0.7, 0.0), (2.9, 0.0, -0.9, 0.0, 0.0, 1.0, 0.0), (3.5, 0.0, -1.2, 0.0, 0.0, 1.0, 0.0),
                (4.2, 0.0, -0.4, 0.0), (6.8, 0.0, 0.0, 0.0)],
          glow=ripple)
    # The Immelmann: the four boosters burn hot and the hull lifts on the blast and surges a
    # little, nose up; then they settle and it comes down with a heave.
    b.act("immelmann", 6.0, body=[(0.8, 0.0, 0.0, 0.0), (2.0, 0.0, 4.0, 3.0, 0.0, 2.0, 0.0), (3.8, 0.0, 6.0, 3.5, 0.0, 1.5, 0.0), (4.8, 0.0, 1.0, -1.0, 0.0, -1.0, 0.0), (6.0, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.5, 0.0), (1.2, 6.0), (1.8, 12.0), (3.8, 12.0), (4.6, 0.0)])])
    # The uplink: the array swings onto an ally and the reheat goes out, its core pulsing and
    # burning; then it swings home.
    b.act("uplink", 5.6, {"sensor_uplink": [(0.5, 0.0), (1.9, 70.0), (3.6, 70.0), (5.0, 0.0)]},
          glow=[(["uplink_core"], [(1.8, 0.0), (2.1, 10.0), (2.4, 2.0), (2.7, 12.0), (3.6, 12.0), (4.4, 0.0)])])
    # The traverse: the fore gun house slews out to one side and back to the other, the quarters'
    # swing out from dead ahead together (mirrored) and back, a beat apart, each pausing before it
    # turns back (the builder's turret rule).
    b.act("traverse", 7.4, {
        "turret_fore": [(0.6, 0.0), (2.0, 46.0), (2.8, 46.0), (5.2, -34.0), (6.0, -34.0), (7.2, 0.0)],
        "turret_l": [(0.8, 0.0), (2.2, 45.0), (3.0, 45.0), (4.6, 0.0)],
        "turret_r": [(0.9, 0.0), (2.3, -45.0), (3.1, -45.0), (4.7, 0.0)],
    })
    # Movement: slow and heavy, its boosters brightening, its nose a touch up as a ground-effect
    # craft runs; it drifts through its corners and never banks (a hovercraft keeps flat).
    b.halo = [("booster_ring", KESTREL_HALO), ("exhaust", KESTREL_HALO)]   # its boosters, hot
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, 2.0, 0.0), glow={"parts": boosters, "k": KESTREL_HEAVY}, rock=2.0)
    # Its fixed weapon fires with a slice of its act, the three launches (Ryan, 31 October: "go for
    # ones that are cheapest to do first"), and its fixed equipment with theirs as it is used (Ryan's
    # go of 3 November): the boosters burning for the Immelmann, the array swinging onto an ally for
    # the uplink.
    b.fires = {"spindrift_salvo": ("salvo", 2.0, 4.0), "immelmann_booster": ("immelmann", 1.0, 3.8), "reheat_uplink": ("uplink", 1.2, 3.6)}
    b.move(slide=0.3, bank=0.0, accel=1.6, heft=0.25, oversteer=0.5)

giant_petrel.maker = "kestrel"

# ---------------------------------------------------------------- the Kestrel line's second round (Ryan's picks, 27 October)

def _lerp_at(table, y):
    """Linear interpolation through a table of (y, *values), y descending: a hull's or a
    planform's stations read at any y."""
    for a, b in zip(table, table[1:]):
        if b[0] <= y <= a[0]:
            t = (a[0] - y) / (a[0] - b[0])
            return [p + (q - p) * t for p, q in zip(a[1:], b[1:])]
    return list(table[0][1:]) if y > table[0][0] else list(table[-1][1:])


def _fuse_top(fuse, y):
    """A fuselage's top at `y`, from its (y, w, top, bottom) sections."""
    for (y0, w0, t0, b0), (y1, w1, t1, b1) in zip(fuse, fuse[1:]):
        if y1 <= y <= y0:
            return t0 + (t1 - t0) * (y0 - y) / (y0 - y1)
    return fuse[-1][2]


def _jet_canopy(b, fuse, rows, frame_y, label="canopy", frames=()):
    """A jet's canopy on the fuselage's top through `rows` of (y, half width, height), a frame
    band across it at `frame_y`; `frames`, given, more bands, each sized to the canopy where it
    lies (a long canopy's bows: the Needletail's)."""
    def cab(y, hw, h, grow=0.0):
        z, hw = _fuse_top(fuse, y), hw + grow
        return [(-hw, z - 0.6), (hw, z - 0.6), (hw, z + h * 0.55 + grow), (hw * 0.6, z + h + grow), (-hw * 0.6, z + h + grow), (-hw, z + h * 0.55 + grow)]
    b.loft([(y, cab(y, hw, h)) for (y, hw, h) in rows], "glass.glass", label)
    hw, h = max((r[1], r[2]) for r in rows)
    b.loft([(frame_y + 0.6, cab(frame_y + 0.6, hw, h, 0.3)), (frame_y - 0.6, cab(frame_y - 0.6, hw, h, 0.3))], "steel.dark", label + "_frame")
    for fy in frames:
        fhw, fh = _lerp_at(rows, fy)
        b.loft([(fy + 0.45, cab(fy + 0.45, fhw, fh, 0.25)), (fy - 0.45, cab(fy - 0.45, fhw, fh, 0.25))], "steel.dark", label + "_frame")


def _boat_cab(b, deck, rows, frame_y):
    """A hovercraft's fighter canopy settled onto the deck through `rows` of (y, width at the
    deck, height over it), its base sunk into the hull, a frame band across it at `frame_y`."""
    def cab(y, grow=0.0):
        w, h = _lerp_at(rows, y)
        z, hw = deck(y), w / 2.0 + grow
        return [(-hw, z - 0.8), (hw, z - 0.8), (hw, z + h * 0.45 + grow), (hw * 0.5, z + h + grow), (-hw * 0.5, z + h + grow), (-hw, z + h * 0.45 + grow)]
    b.loft([(y, cab(y)) for (y, w, h) in rows], "glass.glass", "canopy")
    b.loft([(frame_y + 0.6, cab(frame_y + 0.6, 0.35)), (frame_y - 0.6, cab(frame_y - 0.6, 0.35))], "steel.dark", "canopy_frame")


def _mirror(pts, s):
    """A section drawn for the right side, mirrored for the left with its winding kept."""
    return [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]

def skua(b):
    """Kestrel "Skua" (K-13 Mk I Swing-Wing Strafer): Kestrel's second tier one (Ryan's go, 21
    October: a swing-wing, the strafing jet by trade), "Ramping Dakka" since his rewrite of 11
    November (Ricochet; its lock the Hypersonic Swoop, equipment that shows nowhere). Second
    round, the jaeger (Ryan, 26 October, on the first
    cut's F-14: "I'm ok for a homage, but that has no originality in it whatsoever"; the jaeger
    "pretty cool", then "a bit too bird-like", then "go back to the previous Jaeger" with a jet's
    nose, the wings low, the fin back and taller; 27 October, "Skua as the Jaeger is good, ditch
    the little bent tip at the tip of the nose"): the bird's wings as the swing. A short deep
    fuselage running into one big booster astern; a jet's straight radome with the jaeger's dark
    cap over its crown; intake cheeks under the canopy; the wings in two parts, a fixed cobalt
    arm running flat out from low on the flank to a wrist drum, and from the wrist a long narrow
    hand (joints wing_l and wing_r, yaw about the wrist) that sweeps back to lie along the body
    for the run and spreads past square to brake, the bone-white flash a bar across the hand's
    root; a V tail of two canted stabilisers; two long streamers off the tail (the jaeger's
    central tail feathers); the fin from the fairing back over the booster, swept and tall; the
    twin air intakes on the spine, dark mouths forward in steel lips (Ryan, 12 November: "Can we
    turn the skua's spine pods into intakes?"; they housed the Flechette Pod while it was its
    lock). On the move the hands sweep
    back as it gathers speed and spread as it slows. Mounts in the die's order: hp_1 under the
    left arm's root (the Laser Carbine), hp_2 under the right (the Twin Autoguns), hp_3 under the
    belly (the Flechette Pod, a rack, a strafer's centreline pod). Centred on z = 0 like the
    Kite."""
    FUSE = [(30.0, 7.0, 3.3, 3.3), (18.0, 10.0, 4.4, 4.0), (4.0, 11.4, 4.9, 4.4), (-10.0, 10.8, 4.8, 4.4), (-22.0, 9.4, 4.5, 4.3)]   # (y, w, top, bottom)
    NOSE = [(30.0, 7.0, 3.3, 3.3), (40.0, 5.2, 2.5, 2.5), (49.0, 3.0, 1.4, 1.4), (55.0, 1.2, 0.5, 0.5)]
    BY, BR = -36.0, 7.0   # the booster's centre and radius
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in NOSE], "steel.plate", "nose")
    # The tip: a radome's straight point (the hook of the earlier cuts gone).
    b.loft([(54.5, diamond(0.0, 0.0, 1.6, 1.2)), (60.0, diamond(0.0, 0.0, 0.3, 0.3))], "steel.dark", "nose_tip")
    # The dark cap the bird wears: a thin shell over the nose's crown, the radome's root to the canopy.
    b.loft([(y, [(-w * 0.46, t * 0.55), (w * 0.46, t * 0.55), (w * 0.26, t + 0.25), (-w * 0.26, t + 0.25)]) for (y, w, t, bt) in NOSE[:3]], "steel.dark", "cap")
    # The body flows into its one booster without a step.
    y0, w0, t0, b0 = FUSE[-1]
    b.loft([(y0, _fuse(w0, t0, b0)), (BY + 11.0, _hexr(0.0, 0.3, BR))], "steel.plate", "tail_fairing")
    b.prism("y", 0.0, BY, 0.3, BR, 22.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    b.prism("y", 0.0, BY - 10.0, 0.3, BR + 0.5, 2.4, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(BY - 11.2, _hexr(0.0, 0.3, BR + 0.4)), (BY - 11.8, _hexr(0.0, 0.3, BR - 0.6))], "amber.exhaust", "exhaust")
    _jet_canopy(b, FUSE + [(-40.0, 8.0, 4.0, 4.0)], [(27.0, 1.0, 0.6), (23.0, 2.5, 2.6), (16.0, 2.9, 3.4), (9.0, 2.5, 2.7), (5.0, 1.3, 1.0)], 16.0)
    for s in (-1.0, 1.0):
        b.loft([(12.0, rect(s * 6.2, 2.2, -2.4, 2.0)), (4.0, rect(s * 6.4, 2.6, -2.6, 2.4))], "steel.dark", "intake_cheek")
        b.box(s * 6.2 - 0.9, s * 6.2 + 0.9, 12.0, 12.4, -2.2, 1.8, "bore.dark", "intake")
    # The wings: the arm fixed and flat from low on the flank to the wrist, with a touch of
    # anhedral; the hand swinging about the wrist (the left turns left, so its sweep is
    # positive, the right's negative).
    WX, WY, WZ = 18.0, 2.0, -1.2
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 5.2, 6.0, -11.0, 0.0, 1.1), _blade_section(s * 12.0, 8.0, -7.0, -0.6, 0.9),
                   _blade_section(s * (WX + 0.8), 8.8, -4.4, WZ, 0.8)], "livery.livery", "wing_arm")
        with b.joint("wing_" + side, (s * WX, WY, WZ), axis="yaw", limits=(-8.0, 60.0) if s < 0 else (-60.0, 8.0)):
            _rings(b, [_blade_section(s * (WX - 0.4), 8.6, -4.3, WZ, 0.8), _blade_section(s * (WX + 5.0), 7.2, -4.6, WZ - 0.3, 0.7)], "livery.livery", "wing_hand")
            _rings(b, [_blade_section(s * (WX + 5.0), 7.2, -4.6, WZ - 0.3, 0.7), _blade_section(s * (WX + 10.0), 5.6, -4.8, WZ - 0.6, 0.62)], "bone.bone", "wing_flash")
            _rings(b, [_blade_section(s * (WX + 10.0), 5.6, -4.8, WZ - 0.6, 0.62), _blade_section(s * (WX + 24.0), -0.6, -6.2, WZ - 1.6, 0.4),
                       _blade_section(s * (WX + 37.0), -8.2, -9.2, WZ - 2.6, 0.18)], "livery.livery", "wing_hand")
        # The V tail, thirty degrees up from level; the streamers off its roots.
        ca = math.radians(30.0)
        _rings(b, [_blade_section(s * 5.0, -30.0, -43.0, 3.6, 0.5), [(s * (5.0 + 14.0 * math.cos(ca)), y, 3.6 + 14.0 * math.sin(ca) + dz) for (y, dz) in ((-45.0, 0.0), (-42.0, 0.25), (-39.0, 0.0), (-42.0, -0.25))]],
               "livery.livery", "stabiliser")
        _rings(b, [[(s * 1.6 - 0.9, -40.0, 7.7), (s * 1.6, -40.0, 8.1), (s * 1.6 + 0.9, -40.0, 7.7), (s * 1.6, -40.0, 7.3)],
                   [(s * 2.6 - 0.7, -56.0, 6.6), (s * 2.6, -56.0, 6.9), (s * 2.6 + 0.7, -56.0, 6.6), (s * 2.6, -56.0, 6.3)],
                   [(s * 3.6 - 0.05, -76.0, 5.8), (s * 3.6, -76.0, 5.85), (s * 3.6 + 0.05, -76.0, 5.8), (s * 3.6, -76.0, 5.75)]], "livery.livery", "streamer")
        b.box(s * 1.6 - 0.6, s * 1.6 + 0.6, -41.0, -31.0, 4.6, 8.0, "steel.plate", "streamer_root")
    # The fin: its root from the fairing back over the booster, swept and tall.
    _rings(b, [_fin_section(0.0, -18.0, -44.0, 5.0, 0.8), _fin_section(0.0, -37.0, -47.0, 20.0, 0.3)], "livery.livery", "fin")
    # The spine's twin intakes (Ryan, 12 November; the Flechette Pod's housings until then): each
    # a scoop fairing back into the spine, a dark mouth facing forward inside a steel lip.
    for px in (-3.0, 3.0):
        b.loft([(-16.0, rect(px, 1.8, 4.2, 6.5)), (-10.0, rect(px, 3.4, 4.4, 8.2)), (3.0, rect(px, 3.4, 4.4, 8.2))], "steel.panel", "intake")
        _quad(b, [(px - 1.3, 3.05, 4.8), (px + 1.3, 3.05, 4.8), (px + 1.3, 3.05, 7.8), (px - 1.3, 3.05, 7.8)], "bore.dark", "intake_mouth")
        for (za, zb) in ((7.9, 8.5), (4.1, 4.7)):
            b.box(px - 2.0, px + 2.0, 2.4, 3.4, za, zb, "steel.plate", "intake_lip")
        for (xa, xb) in ((px - 2.0, px - 1.4), (px + 1.4, px + 2.0)):
            b.box(xa, xb, 2.4, 3.4, 4.1, 8.5, "steel.plate", "intake_lip")
    # The mounts: a pylon under each arm's root, the gun ahead of the arm's edge; the third under
    # the belly, the Flechette Pod's rack on the centreline.
    for s in (-1.0, 1.0):
        b.box(s * 10.0 - 0.7, s * 10.0 + 0.7, -2.0, 5.0, -2.4, -0.4, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 10.0, 5.0, -3.0), "barrel" if s < 0 else "twin_barrel", scale=0.5, carries="laser_carbine" if s < 0 else "twin_autoguns")
    b.stock("hp_3", (0.0, -10.0, -5.0), "rack", scale=0.5, carries="flechette_pod")

    # Idle acts (five, like the Kite's, loud and never in step; Ryan, 28 October: the strafing
    # run and the sweep-dash read the same, and it wants the Kite's treatment, bigger
    # animations that show off its agility, some of them the Kite's own). Degrees and seconds;
    # a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k),
    # k the light added over rest.
    boosters = ["booster_ring", "exhaust"]
    SW = 52.0   # the hands' full sweep
    # The strafing run (Ryan, 28 October: the first cut "just kind of wiggles"): it climbs back
    # and up off its hex, wings over at the top with the hands sweeping back, dives steeply
    # forward and down on its foe, the pods firing twice at the bottom, pulls up hard and
    # climbs away rolled over, the hands spreading to brake it back onto its hex.
    # The strafing run, on the map (its travel leaves the hex, as the Kite's circle does; Ryan,
    # 28 October: the keyed run read as sudden changes of direction and a reverse back to its
    # start, and a flown path never reverses): one banked circle beside its hex, climbing over
    # the first third, the hands sweeping back as it rolls into a dive on the far side, climbing
    # out and sinking back onto its hex as the hands spread to brake.
    run = _over_ground(_survey_circle(r=60.0, bank=42.0, vmax=130.0, rise=0.0),
                       [(0.0, 0.0), (0.08, 2.0), (0.2, 16.0), (0.34, 34.0), (0.46, 22.0), (0.6, -8.0), (0.76, 8.0), (0.9, 5.0), (1.0, 0.0)])
    at = lambda u: _time_at(run, u)
    # The hands sweep over a fifth of the way round and spread as slowly: an aircraft's
    # surfaces move, never flick (Ryan, 28 October).
    b.act("strafing_run", run[-1][0], {"wing_l": [(at(0.26), 0.0), (at(0.46), SW), (at(0.62), SW), (at(0.78), 0.0), (at(0.9), -8.0), (run[-1][0], 0.0)],
                                       "wing_r": [(at(0.26), 0.0), (at(0.46), -SW), (at(0.62), -SW), (at(0.78), 0.0), (at(0.9), 8.0), (run[-1][0], 0.0)]},
          body=run, places=("map",),
          glow=[(boosters, [(0.3, 0.0), (1.0, 9.0), (run[-2][0] - 0.5, 6.0), (run[-1][0] - 0.1, 0.0)])])
    # The barrel roll, the Kite's, the hands spread (Ryan, 28 October: the wings stay extended
    # for a barrel roll): a dip and a kick to gather, once round on the fuselage and past, back
    # short of level and settled.
    b.act("barrel_roll", 3.2,
          body=_barrel_roll(t0=0.4, t1=1.6, over=28.0, duration=3.2, surge=8.0),
          glow=[(boosters, [(0.2, 0.0), (0.5, 8.0), (1.7, 8.0), (2.5, 0.0)])])
    # Harrying, on the map: the jaeger's stoops flown as a figure eight over its hex, a lobe to
    # each side, each lobe lifting and then stooping at its far end with the hands half swept,
    # crossing its hex at speed between them.
    eight = _over_ground(_figure_eight(radius=44.0, bank=-44.0, vmax=140.0, rise=0.0),
                         [(0.0, 0.0), (0.1, 6.0), (0.18, 8.0), (0.25, -14.0), (0.32, -6.0), (0.4, 6.0), (0.5, 0.0), (0.6, 6.0), (0.68, 8.0), (0.75, -14.0), (0.82, -6.0), (0.9, 6.0), (1.0, 0.0)])
    et = lambda u: _time_at(eight, u)
    b.act("harry", eight[-1][0], {"wing_l": [(et(0.06), 0.0), (et(0.2), 34.0), (et(0.3), 34.0), (et(0.44), 0.0), (et(0.56), 0.0), (et(0.7), 34.0), (et(0.8), 34.0), (et(0.94), 0.0)],
                                  "wing_r": [(et(0.06), 0.0), (et(0.2), -34.0), (et(0.3), -34.0), (et(0.44), 0.0), (et(0.56), 0.0), (et(0.7), -34.0), (et(0.8), -34.0), (et(0.94), 0.0)]},
          body=eight, places=("map",),
          glow=[(boosters, [(0.3, 0.0), (0.9, 7.0), (eight[-2][0] - 0.5, 6.0), (eight[-1][0] - 0.1, 0.0)])])
    # The loop, the Kite's, on the map only: it backs off, runs in with the hands swept and
    # pulls up through a full circle, over on its back and down, and brakes onto its hex a
    # whole turn on.
    b.act("loop", 5.2, {"wing_l": [(0.8, 0.0), (1.3, SW), (4.2, SW), (5.0, 0.0)], "wing_r": [(0.8, 0.0), (1.3, -SW), (4.2, -SW), (5.0, 0.0)]},
          body=_loop(r=42.0, t0=1.4, t1=4.1, duration=5.2, back=34.0, run=22.0), places=("map",),
          glow=[(boosters, [(0.9, 0.0), (1.4, 9.0), (4.2, 9.0), (4.9, 0.0)])])
    # The flare: the hands full forward and rocking, nose high and the booster dimmed as it sinks
    # like a jet coming aboard, then a kick of the booster and level.
    b.act("landing_flare", 5.0, {"wing_l": [(0.4, 0.0), (1.0, -8.0), (1.6, -5.0), (2.2, -8.0), (2.8, -5.0), (3.4, -8.0), (4.2, 0.0)],
                                 "wing_r": [(0.4, 0.0), (1.0, 8.0), (1.6, 5.0), (2.2, 8.0), (2.8, 5.0), (3.4, 8.0), (4.2, 0.0)]},
          body=[(0.4, 0.0, 0.0, 0.0), (1.2, 0.0, -8.0, 6.0, 0.0, 22.0, 6.0), (2.0, 0.0, -12.0, 2.0, 0.0, 20.0, -6.0), (2.8, 0.0, -14.0, -3.0, 0.0, 18.0, 5.0), (3.5, 0.0, -8.0, -1.0, 0.0, 6.0, 0.0), (5.0, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.4, 0.0), (1.2, -0.8), (2.8, -0.8), (3.3, 6.0), (4.2, 0.0)])])
    # Movement: the hands sweep back as it gathers speed and spread as it slows (a gait it sets
    # off and pulls up in, crossfaded by speed); the booster brightens, the nose drops, and it
    # banks and slides through its corners.
    glow = {"parts": boosters, "k": KESTREL_BURN}
    b.gait_option("spread", tracks={"wing_l": [(0.0, -4.0), (1.0, -4.0)], "wing_r": [(0.0, 4.0), (1.0, 4.0)]}, glow=glow,
                  body_hold=(0.0, 0.0, 0.0, 0.0, -3.0, 0.0))
    b.halo = [("booster_ring", KESTREL_HALO), ("exhaust", KESTREL_HALO)]   # its booster, hot
    b.gait(tracks={"wing_l": [(0.0, SW), (1.0, SW)], "wing_r": [(0.0, -SW), (1.0, -SW)]}, glow=glow,
           body_hold=(0.0, 0.0, 0.0, 0.0, -6.0, 0.0), start=("spread", 0.25, 0.85))
    b.move(slide=0.5, bank=44.0, accel=0.7, heft=0.08, oversteer=0.3)

skua.maker = "kestrel"

def puffin(b):
    """Kestrel "Puffin" (K-11 Mk I Ground-Effect Escort): Kestrel's one machine that touches
    the ground, the escort they thought was very cool and pilots named for the bird (the
    bible's makers row, 28 September; built 2 October, eight passes by 5 October: the wide low
    hull on two giant boosters with the vents on top, kept in git). The swap (Ryan, 26 October:
    the Storm Petrel's first cut, a speedboat with a mast, reads as a research boat, which is
    the Puffin, so the two traded bases; 27 October: "really looking like the Puffin", "looking
    good"): the long chined boat hull at the light size, the skirt the whole length bow to
    stern, a wave-piercing bow carrying the prow's band of light; the hull thicker amidships
    and its bottom rising to the prow and the stern (the boat's curve, the belly flat between
    for the cushion); a fighter canopy; one booster astern drawn in over the afterdeck, a tall
    swept fin on it; the Backwash Ionizer (fixed, no pin) a dish on a short mast amidships,
    sitting on the mast's yoke, that turns (joint projector). The side plates are repulsors
    and shield amplifiers both: hinged low on the flanks at the chine, they lie level under
    way as the lift surfaces that steer it, their outside faces (the undersides, level) carrying
    the lit repulsor discs, and they fold up in a fight to amplify the shield it projects,
    the amplifier strip and boss on their inside faces lighting (joints plate_l and plate_r,
    rolling about the hinge). Mounts in the die's order: hp_1 a pod under the left foredeck's
    edge (the Halo Shield, a dish), hp_2 the right shoulder (the Twin Autoguns), hp_3 the left
    shoulder (the Laser Carbine), hp_4 the pod under the right, bare, numbered last since the
    Coolant Jacket takes no mount (28 October). Floats: the lip at z = 6."""
    K = 0.86   # the boat at the light size
    HULL = [(y * K, w * K, 6.0 + (z0 - 6.0) * K, 6.0 + (z1 - 6.0) * K, c * K) for (y, w, z0, z1, c) in
            ((48.0, 3.0, 11.6, 13.6, 0.6), (40.0, 10.0, 9.6, 15.0, 1.4), (28.0, 18.0, 7.8, 16.8, 2.2), (12.0, 24.0, 6.6, 18.0, 2.8),
             (-12.0, 24.0, 6.6, 18.0, 2.8), (-30.0, 21.0, 7.6, 17.4, 2.4), (-42.0, 15.0, 9.6, 16.4, 2.0))]   # (y, w, z0, z1, c), bow to stern
    at = lambda y: tuple(_lerp_at([(y, w, z0, z1) for (y, w, z0, z1, c) in HULL], y))
    deck = lambda y: at(y)[2]
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "hull")
    # The skirt the whole length, bow to stern, climbing the bow's and the stern's rise.
    SKIRT = [(y, w + 1.0, z0 - 0.6, z0 + 1.4, 0.8) for (y, w, z0, z1, c) in HULL]
    SKIRT[0] = (HULL[0][0] + 1.5 * K, HULL[0][1] + 0.8, HULL[0][2] - 0.4, HULL[0][2] + 1.0, 0.5)
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.3)) for (y, w, z0, z1, c) in SKIRT], "steel.dark", "lip")
    # A cobalt stripe along the chine, bow to stern.
    for s in (-1.0, 1.0):
        secs = []
        for (y, w, z0, z1, c) in HULL[1:]:
            hw, zc = w / 2.0, z0 + (z1 - z0) * 0.42
            secs.append((y, _mirror([(hw + 0.4, zc), (hw - 0.3, zc + 0.7), (hw - 1.2, zc), (hw - 0.3, zc - 0.7)], s)))
        b.loft(list(reversed(secs)), "livery.livery", "chine_stripe")
    w0, z00, z01 = at(36.0)
    b.loft([(35.0, _hull_section(z00 + 0.3, z01 - 0.3, w0 + 0.3, 1.0)), (36.5, _hull_section(z00 + 0.5, z01 - 0.5, w0 - 0.4, 0.8))], "amber.shield", "prow_band")
    _boat_cab(b, deck, [(26.0, 4.5, 0.6), (21.0, 9.0, 2.6), (14.0, 11.0, 3.6), (7.0, 10.0, 3.3), (2.0, 7.0, 2.2)], 15.0)
    # The Ionizer's dish on a short mast amidships, its neck in the mast's yoke (Ryan, 27
    # October: the dish floated over the pole, and it can be lower).
    my, mz0, mtop = -6.0, deck(-6.0), 23.0
    _beam(b, (0.0, my, mz0 - 0.5), (0.0, my, mtop), _poly(1.3, 6), _poly(0.7, 6), "steel.dark", "mast")
    b.prism("z", 0.0, my, mtop - 0.6, 1.3, 1.4, "steel.plate", 6, "mast_yoke")
    with b.joint("projector", (0.0, my, mtop), axis="yaw", limits=(-150.0, 150.0)):
        tilt = Matrix.Translation((0.0, my, mtop - 0.2)) @ Matrix.Rotation(math.radians(70.0), 4, "X")
        b.loft([(-0.4, _poly(0.8, 8)), (1.0, _poly(1.0, 8)), (2.0, _poly(4.6, 8)), (2.8, _poly(5.0, 8))], "steel.plate", "projector_dish", tilt)
        b.loft([(1.8, _poly(1.3, 8)), (2.8, _poly(1.3, 8))], "amber.shield", "projector_core", tilt)
    # The plates: hinged at the chine on a short bracket, level at rest and under way (the
    # repulsors), folding up in a fight (the amplifiers). The inside face (the top, level) keeps
    # the amplifier strip and boss; the outside face (the underside) carries three lit repulsor
    # discs in dark rings.
    HY = -8.0 * K
    OUT = [(13.6, 0.0), (12.0, 3.4), (2.6, 11.0), (-12.0, 10.2), (-16.2, 4.2), (-13.6, 0.0)]   # (along y, out from the hinge)
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        w, hz0, hz1 = at(HY)
        hx, hz = s * (w / 2.0 + 1.4), hz0 + (hz1 - hz0) * 0.42
        d, n = Vector((s, 0.0, 0.0)), Vector((0.0, 0.0, 1.0))
        for u in (-11.0, 0.0, 11.0):
            b.box(min(hx - s * 1.8, hx), max(hx - s * 1.8, hx), HY + u - 1.2, HY + u + 1.2, hz - 0.9, hz + 0.9, "steel.dark", "hinge_bracket")
        b.prism("y", hx, HY, hz, 1.0, 28.0, "steel.dark", 6, "hinge")
        with b.joint("plate_" + side, (hx, HY, hz), axis="roll", limits=(-22.0, 88.0) if s < 0 else (-88.0, 22.0)):
            _rings(b, [[tuple(Vector((hx, HY + u, hz)) + d * v + n * off) for (u, v) in OUT] for off in (-0.45, 0.45)], "livery.livery2", "plate")
            cu, cv = sum(u for u, v in OUT) / len(OUT), sum(v for u, v in OUT) / len(OUT)
            boss = Vector((hx, HY + cu, hz)) + d * cv
            _disc(b, tuple(boss + n * 0.55), tuple(n), 2.2, 6, "steel.dark", "boss")
            _disc(b, tuple(boss + n * 0.65), tuple(n), 1.3, 6, "amber.shield", "amp_boss")
            (u0, v0), (u1, v1) = OUT[2], OUT[3]
            _beam(b, tuple(Vector((hx, HY + u0, hz)) + d * (v0 + 0.5)), tuple(Vector((hx, HY + u1, hz)) + d * (v1 + 0.5)), _sq(1.4, 0.7), _sq(1.4, 0.7), "amber.shield", "amp_edge")
            # The amplifier's rim: a lit line round the plate's outer edge, dark at rest, and
            # the discs underneath light with it when the plate stands up (Ryan, 28 October).
            # A label a glow names matches whole (amp_rim, never amp_rim_l by its prefix), so
            # only the discs carry a side, for the sideslip.
            for (ua, va), (ub, vb) in zip(OUT[1:4], OUT[2:5]):
                _beam(b, tuple(Vector((hx, HY + ua, hz)) + d * (va - 0.4) + n * 0.5), tuple(Vector((hx, HY + ub, hz)) + d * (vb - 0.4) + n * 0.5), _sq(0.8, 0.5), _sq(0.8, 0.5), "amber.shield", "amp_rim")
            # The discs inside the plate's outline (Ryan, 28 October: the forward one stuck out
            # of the plate's leading edge).
            for (u, v) in ((5.4, 4.8), (-1.5, 6.9), (-9.5, 5.6)):
                c = Vector((hx, HY + u, hz)) + d * v
                _disc(b, tuple(c - n * 0.55), tuple(-n), 2.4, 8, "steel.dark", "repulsor_ring")
                # Thinner, with a detail that is no orange across its face (Ryan, 3 November: "some
                # kind of non-orange detail to the puffin repulsors? Also, they could be thinner"):
                # a puck half as deep, a silver hub and two crossed vanes over the glow, a grille.
                _beam(b, tuple(c - n * 0.5), tuple(c - n * 1.1), _poly(1.8, 8), _poly(1.6, 8), "amber.furnace", "repulsor_" + side)
                face = c - n * 1.14
                t = n.cross(d).normalized()
                for a in (d, t):
                    _beam(b, tuple(face - a * 1.55), tuple(face + a * 1.55), _sq(0.32, 0.18), _sq(0.32, 0.18), "steel.plate", "repulsor_vane")
                _disc(b, tuple(c - n * 1.24), tuple(-n), 0.62, 8, "steel.plate", "repulsor_hub")   # a puck standing proud of the plate (Ryan, 31 October: "if the solution is to give them geometry, then go ahead"), in one even orange: the engine tile's metal rim, landing on it, flared white
    # The pods under the foredeck's edges; the shoulder mounts aft of the canopy.
    for s in (-1.0, 1.0):
        px = s * 12.0 * K
        b.box(min(px - 0.8, px + 0.8), max(px - 0.8, px + 0.8), 12.0, 18.0, 8.4, 10.2, "steel.plate", "pod_pylon")
        b.prism("y", px, 15.0, 8.2, 1.5, 11.0, "steel.dark", 6, "pod")   # the pod is the chassis's and stays when its mount is fitted, as the Buzzard's (2 November)
        if s < 0:
            b.stock("hp_1", (px, 20.0, 8.2), "dish", scale=0.5, carries="halo_projector")   # the stock's Halo Projector as its class (Ryan, 11 November: no stock gun is built by hand)
        else:
            b.pin("hp_4", (px, 20.0, 8.2), scale=0.5, carries="")
        rx, ry = s * 6.5, -22.0
        dz = deck(ry)
        b.loft([(ry - 6.0, rect(rx, 2.6, dz - 0.6, dz + 1.0)), (ry + 5.0, rect(rx, 3.8, dz - 0.6, dz + 2.0))], "steel.panel", "shoulder_fairing")
        b.stock("hp_2" if s > 0 else "hp_3", (rx, ry + 5.5, dz + 1.3), "twin_barrel" if s > 0 else "barrel", scale=0.5, carries="twin_autoguns" if s > 0 else "laser_carbine")
    # The booster drawn in: its mouth over the afterdeck, its exhaust just past the stern.
    BY, BZ, BR = -27.0, 12.6, 6.0
    b.prism("y", 0.0, BY, BZ, BR, 24.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    b.prism("y", 0.0, BY + 4.0, BZ, BR + 0.3, 3.6, "livery.livery", 6, "booster_band", phase=math.pi / 6)
    b.prism("y", 0.0, BY + 12.4, BZ, BR + 0.6, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
    b.loft([(BY + 12.9, _hexr(0.0, BZ, BR - 0.2)), (BY + 13.1, _hexr(0.0, BZ, BR - 0.8))], "bore.dark", "intake")
    b.prism("y", 0.0, BY - 12.8, BZ, BR + 0.4, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(BY - 13.6, _hexr(0.0, BZ, BR + 0.2)), (BY - 14.1, _hexr(0.0, BZ, BR - 0.6))], "amber.exhaust", "exhaust")
    _rings(b, [_fin_section(0.0, BY + 8.0, BY - 8.0, BZ + BR - 0.8, 0.7), _fin_section(0.0, BY - 3.0, BY - 11.0, BZ + BR + 10.0, 0.35)], "livery.livery", "fin")
    for (nx, ny) in ((-6.0, 18.0), (6.0, 18.0), (-6.0, -16.0), (6.0, -16.0)):
        b.prism("z", nx, ny, 6.2, 2.0, 1.4, "amber.engine", 6, "lift_nozzle")

    # Idle acts (four, loud, never in step; a light hovercraft's servos). Degrees and seconds; a
    # body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k).
    boosters = ["booster_ring", "exhaust"]
    amps = ["amp_edge", "amp_boss", "projector_core", "prow_band"]
    reps = ["repulsor_l", "repulsor_r"]
    UP = 82.0   # the plates folded up for a fight, near plumb (Ryan, 28 October: more vertical)
    # Amplify: the plates fold up from level, the dish swings round, the amplifiers and the
    # band beat and hold; the plates lower again as the repulsors.
    b.act("amplify", 5.0, {"plate_l": [(0.4, 0.0), (1.3, UP), (3.6, UP), (4.5, 0.0)], "plate_r": [(0.4, 0.0), (1.3, -UP), (3.6, -UP), (4.5, 0.0)],
                           "projector": [(0.5, 0.0), (1.6, 60.0), (3.6, 60.0), (4.6, 0.0)]},
          body=[(0.4, 0.0, 0.0, 0.0), (1.3, 0.0, 0.0, -1.2), (3.6, 0.0, 0.0, -1.2), (4.6, 0.0, 0.0, 0.0)],
          # the repulsors on the plates wait for the plates to be up before they flare (Ryan, 3 November:
          # "Can the puffin's repulsors wait to flare until its wings are up"); the hull's nozzles lift with the fold
          glow=[(amps + ["amp_rim"], [(1.0, 0.0), (1.4, 26.0), (1.7, 6.0), (2.0, 30.0), (3.6, 30.0), (4.4, 0.0)]),
                (reps, [(1.45, 0.0), (1.8, 18.0), (3.6, 18.0), (4.5, 0.0)]),
                (["lift_nozzle"], [(1.1, 0.0), (1.5, 18.0), (3.6, 18.0), (4.5, 0.0)])])
    # The hop: up hard on the nozzles and the repulsors, the plates flapping with it, a roll at
    # the top, down onto a squash and a bounce.
    b.act("lift_hop", 4.6, {"plate_l": [(0.5, 0.0), (1.2, -16.0), (1.8, 12.0), (2.6, 0.0)], "plate_r": [(0.5, 0.0), (1.2, 16.0), (1.8, -12.0), (2.6, 0.0)]},
          body=[(0.5, 0.0, 0.0, -2.0, 0.0, 0.0, 0.0), (1.2, 0.0, 0.0, 16.0, 0.0, 6.0, 12.0), (1.8, 0.0, 0.0, 14.0, 0.0, -4.0, -10.0), (2.5, 0.0, 0.0, -3.0, 0.0, 0.0, 0.0),
                (2.9, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0), (3.4, 0.0, 0.0, -1.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(["lift_nozzle"] + reps, [(0.3, 0.0), (0.6, 10.0), (1.2, 10.0), (1.8, 3.0), (2.5, 8.0), (3.2, 0.0)])])
    # The sideslip: it slips to the left on its repulsors, the left plate dipping and its discs
    # flaring, the nose swinging after, and straight on across to the right.
    b.act("sideslip", 4.8, {"plate_l": [(0.6, 0.0), (1.0, -14.0), (1.7, -10.0), (2.4, 0.0), (3.0, 10.0), (3.7, 6.0), (4.4, 0.0)],
                            "plate_r": [(0.6, 0.0), (1.0, -10.0), (1.7, -6.0), (2.4, 0.0), (3.0, 14.0), (3.7, 10.0), (4.4, 0.0)]},
          body=[(1.0, -12.0, 0.0, 0.0, 12.0, 0.0, -8.0), (1.7, -14.0, 0.0, 0.0, 1.0, 0.0, -1.0), (3.0, 12.0, 0.0, 0.0, -12.0, 0.0, 8.0), (3.7, 14.0, 0.0, 0.0, -1.0, 0.0, 1.0), (4.8, 0.0, 0.0, 0.0)],
          glow=[(["repulsor_l"], [(0.6, 0.0), (1.0, 10.0), (1.9, 8.0), (2.6, 0.0)]), (["repulsor_r"], [(2.6, 0.0), (3.0, 10.0), (3.9, 8.0), (4.6, 0.0)]),
                (["lift_nozzle"], [(0.6, 0.0), (1.0, 5.0), (3.4, 5.0), (4.2, 0.0)])])
    # The backwash: the Ionizer's dish sweeps right round and back, its core building to a blaze
    # three beats long, the hull heaving up on its cushion under it.
    b.act("backwash", 4.8, {"projector": [(0.3, 0.0), (1.4, -140.0), (2.4, 140.0), (3.6, 140.0), (4.5, 0.0)]},
          body=[(0.6, 0.0, 0.0, 0.0), (1.4, 0.0, 0.0, 1.4, 0.0, 2.0, 0.0), (2.4, 0.0, 0.0, 1.6, 0.0, -2.0, 0.0), (3.6, 0.0, 0.0, 1.4), (4.8, 0.0, 0.0, 0.0)],
          glow=[(["projector_core"], [(0.3, 0.0), (0.7, 9.0), (1.1, 1.0), (1.5, 10.0), (1.9, 1.0), (2.4, 12.0), (3.6, 12.0), (4.4, 0.0)])])
    # Movement: the plates lie level as the repulsors, lit with the booster; the nose down a
    # touch; it oversteers through its corners like the Puffin always has, never banking (a
    # hovercraft keeps flat).
    # Its booster, lift nozzles and repulsors, hot (the repulsors judged in amplify, Ryan, 31
    # October: "too subtle", then, twice the size, "extended way far out": a flat disc's halo
    # stood off it as a copy, so they are pucks now). The repulsors always on, as it hovers.
    # The pucks stand proud of their plates, so their halos are drawn where they are, never pulled
    # toward the eye: pulled, they showed through the plates lying level over them, a violet wash.
    b.halo = [("booster_ring", KESTREL_HALO), ("exhaust", KESTREL_HALO), "lift_nozzle", ("repulsor_l", 1.0, 0.0), ("repulsor_r", 1.0, 0.0)]
    b.standing = {"repulsor_l": 4.0, "repulsor_r": 4.0}
    b.gait(hold={"plate_l": 0.0, "plate_r": 0.0}, body_hold=(0.0, 0.0, 0.0, 0.0, -5.0, 0.0), glow={"parts": boosters + reps, "k": KESTREL_BURN}, rock=3.0)
    b.move(slide=0.3, bank=14.0, accel=0.8, heft=0.13, oversteer=1.5)   # a little bank in its turns (Ryan, 3 November: "since it's more speedboat-ey now")
    # Its fixed equipment moves as it is used (Ryan's go of 3 November): the Ionizer's dish sweeping
    # round and back as its core blazes, a slice of its backwash.
    b.fires = {"backwash_ionizer": ("backwash", 1.0, 3.0)}

puffin.maker = "kestrel"

def storm_petrel(b):
    """Kestrel "Storm Petrel" (K-15 Mk I Air-Cushion Picket): Kestrel's tier-one body, its
    weapons burning shield in place of heat behind the Riot Field Generator (Ryan's go, 21
    October: a fast medium hovercraft, the small sea bird that patters across the water; hard
    shields used both for defence and for whacking things with). The swap (Ryan, 26 October:
    the Puffin's wide hull with the two giant boosters to the Storm Petrel, the off-tank, at
    the medium size; its bow plate "dumb"; 27 October: "a better take", "great"): the Puffin's
    chined hull grown to the medium size and its taper run on to a snub nose, the two giant
    booster drums half out of their faired nacelles with the louvred vent housings on their
    tops, the deck carried over them; a fighter canopy under a projector arch. The Riot Field
    is shown, never a plate: four emitter pylons on the cheeks and lit field rails along their
    creases, the arch over the canopy, all of which light as the field goes up. St. Elmo's
    Regenerator (fixed, no pin) is the open port in the nose, a chine-shaped intake with the
    corona burning inside it (the line's one light that is no flame), doubled when the nose
    was snubbed. The cheeks are each nacelle's shoulder grown forward along the flank as an
    armoured sponson, carrying the gun tubs; louvred vents on the prow's top and grilles on
    its flanks break its sweep. Mounts in the die's order: hp_1 the left cheek's tub (the
    Laser Carbine), hp_2 the afterdeck's left (the Ankle Mortar, a rack), hp_3 the right cheek's
    tub (the Twin Autoguns), hp_4 bare on the afterdeck's right (the self shield shows nowhere).
    Floats: the lip at z = 6."""
    K = 1.18   # the Puffin's hull at the medium size
    HULL = [(y * K, w * K, 6.0 + (z0 - 6.5) * K, 6.0 + (z1 - 6.5) * K, c * K) for (y, w, z0, z1, c) in
            ((40.0, 10.0, 10.2, 15.0, 1.6), (33.0, 15.0, 9.0, 16.2, 2.0), (26.0, 22.0, 8.2, 17.4, 2.6), (14.0, 32.0, 7.2, 19.0, 3.4), (4.0, 36.0, 7.0, 19.4, 3.5),
             (-12.0, 34.0, 7.0, 19.4, 3.5), (-26.0, 30.0, 8.0, 18.8, 3.0), (-36.0, 22.0, 10.0, 17.4, 2.5))]   # (y, w, z0, z1, c), nose to stern
    at = lambda y: tuple(_lerp_at([(y, w, z0, z1) for (y, w, z0, z1, c) in HULL], y))
    deck = lambda y: at(y)[2]
    # The hull is open at the nose, where the port's tunnel runs in (a capped loft would wall
    # the mouth), and closed at the stern by its own slab.
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "hull", cap=False)
    ys, ws, zs0, zs1, cs = HULL[-1]
    b.loft([(ys + 0.1, _chine_section(zs0, zs1, ws, cs)), (ys - 0.3, _chine_section(zs0 + 0.2, zs1 - 0.2, ws - 0.4, cs))], "steel.plate", "stern")
    SKIRT = [(y, w + 1.2, z0 - 0.7, z0 + 2.2, 0.9) for (y, w, z0, z1, c) in HULL]
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.3)) for (y, w, z0, z1, c) in SKIRT], "steel.dark", "lip")
    # The port: the nose's face is the hull's own section, an open mouth in a dark lip, a tunnel
    # running in to a dark floor with the corona burning inside it and a halo ring at the lip.
    y0, w0, z00, z01 = HULL[0][0], HULL[0][1], HULL[0][2], HULL[0][3]
    mouth = _chine_section(z00 + 0.5, z01 - 0.5, w0 - 0.8, 1.0)
    b.loft([(y0 - 0.2, _chine_section(z00 - 0.2, z01 + 0.2, w0 + 0.6, 1.4)), (y0 + 1.6, _chine_section(z00 + 0.1, z01 - 0.1, w0 + 0.2, 1.2))], "steel.dark", "port_lip", cap=False)
    _rings(b, [[(x, y0 + 1.6, z) for (x, z) in _chine_section(z00 + 0.1, z01 - 0.1, w0 + 0.2, 1.2)], [(x, y0 + 1.7, z) for (x, z) in mouth]], "steel.dark", "port_face", cap=False)
    b.loft([(y0 + 1.7, mouth), (y0 - 6.0, _chine_section(z00 + 1.4, z01 - 1.4, w0 * 0.5, 0.6))], "bore.dark", "port", cap=False)
    b.loft([(y0 - 5.8, _chine_section(z00 + 1.4, z01 - 1.4, w0 * 0.5, 0.6)), (y0 - 6.2, _chine_section(z00 + 1.6, z01 - 1.6, w0 * 0.44, 0.5))], "bore.dark", "port_floor")
    # St. Elmo's fire (Ryan, 28 October: the lit corona filling the mouth read as a white block,
    # and its act showed nothing): a small core deep in the dark mouth, and eight sparks round
    # the mouth's lip and a ring inside it that rest dim and crackle white when it fires.
    pz = (z00 + z01) / 2.0
    b.loft([(y0 - 3.6 + dy, _oct(pz, 2.4 * r, 1.6 * r, 0.0, 8)) for (dy, r) in ((-1.2, 0.5), (-0.4, 1.2), (0.5, 1.4), (1.4, 1.0), (2.0, 0.4))], "amber.corona", "corona")
    for i, (sx, sz) in enumerate(_chine_section(z00 + 1.0, z01 - 1.0, w0 - 2.0, 0.8)):
        b.prism("y", sx, y0 + 0.6, sz, 0.42, 1.8, "amber.spark", 6, "spark_%d" % i)
    b.loft([(y0 + 1.5, _chine_section(z00 + 0.7, z01 - 0.7, w0 - 1.3, 0.9)), (y0 + 0.7, _chine_section(z00 + 0.8, z01 - 0.8, w0 - 1.5, 0.9))], "amber.spark", "spark_ring", cap=False)
    # The livery (Ryan, 28 October: more of it): a cobalt stripe along the chine from the nose
    # to the nacelles, a panel down the prow's top between the vents, bands on the boosters.
    for s in (-1.0, 1.0):
        secs = []
        for y in (37.0, 30.0, 20.0, 8.0, -4.0):
            w, hz0, hz1 = at(y)
            hw, zc = w / 2.0, hz0 + (hz1 - hz0) * 0.42
            secs.append((y, _mirror([(hw + 0.4, zc), (hw - 0.3, zc + 0.8), (hw - 1.2, zc), (hw - 0.3, zc - 0.8)], s)))
        b.loft(list(reversed(secs)), "livery.livery", "chine_stripe")
    b.loft([(37.0, rect(0.0, 4.0, deck(37.0) - 0.2, deck(37.0) + 0.35)), (20.0, rect(0.0, 5.6, deck(20.0) - 0.2, deck(20.0) + 0.35))], "livery.livery", "prow_panel")
    # The prow's vents (Ryan, 27 October: a little less streamlined): a louvred housing either
    # side of the centreline on the nose's top, and a grille proud of each flank below the chine.
    for s in (-1.0, 1.0):
        vx0, vx1 = min(s * 3.6, s * 7.2), max(s * 3.6, s * 7.2)
        b.loft([(31.0, rect((vx0 + vx1) / 2.0, vx1 - vx0, deck(31.0) - 0.3, deck(31.0) + 0.7)), (23.0, rect((vx0 + vx1) / 2.0, vx1 - vx0, deck(23.0) - 0.3, deck(23.0) + 0.9))], "steel.dark", "vent_housing")
        lx0, lx1 = min(s * 4.0, s * 6.8), max(s * 4.0, s * 6.8)
        b.loft([(30.4, rect((lx0 + lx1) / 2.0, lx1 - lx0, deck(30.4) + 0.7, deck(30.4) + 1.1)), (23.6, rect((lx0 + lx1) / 2.0, lx1 - lx0, deck(23.6) + 0.9, deck(23.6) + 1.3))], "steel.vent", "vent_louvres")
        secs = []
        for y in (34.0, 26.0):
            w, hz0, hz1 = at(y)
            hw, zc = w / 2.0, hz0 + (hz1 - hz0) * 0.42
            secs.append((y, _mirror([(hw - 1.4, zc - 2.6), (hw + 0.5, zc - 2.6), (hw + 0.5, zc - 0.4), (hw - 0.4, zc - 0.4)], s)))
        b.loft(secs, "steel.dark", "flank_vent")
        # The field's strips: lit lines along the flanks above the chine, the nose to the cheeks,
        # dark at rest (Ryan, 28 October: more lit areas, and much brighter when lit).
        secs = []
        for y in (36.0, 28.0, 18.0, 10.0):
            w, hz0, hz1 = at(y)
            hw, zc = w / 2.0, hz0 + (hz1 - hz0) * 0.42
            secs.append((y, _mirror([(hw - 0.9, zc + 1.4), (hw - 0.4, zc + 1.4), (hw - 0.2, zc + 2.2), (hw - 0.7, zc + 2.2)], s)))
        b.loft(list(reversed(secs)), "amber.shield", "field_strip")
        secs = []
        for y in (33.2, 26.8):
            w, hz0, hz1 = at(y)
            hw, zc = w / 2.0, hz0 + (hz1 - hz0) * 0.42
            secs.append((y, _mirror([(hw + 0.5, zc - 2.3), (hw + 0.9, zc - 2.3), (hw + 0.9, zc - 0.7), (hw + 0.5, zc - 0.7)], s)))
        b.loft(secs, "steel.vent", "flank_louvres")
    _boat_cab(b, deck, [(18.0, 6.0, 0.6), (12.0, 11.0, 3.0), (4.0, 12.6, 4.0), (-5.0, 12.0, 3.6), (-11.0, 10.0, 2.6)], 8.0)
    # The projector arch over the canopy: a thin lit arch, dark at rest, under eight sleeves
    # of plate that leave its light showing between them (Ryan, 28 October: the glow ran
    # along the arch's underside, hidden).
    # Its feet stand on the deck (Ryan, 28 October: the arch floated), the sleeves about two
    # thirds of each span (his notes: longer than half, shorter than most), the end sleeves run
    # down into the feet.
    pts = [Vector((-9.0 * math.cos(math.pi * k / 8.0), 0.0, deck(0.0) + 0.4 + 8.0 * math.sin(math.pi * k / 8.0))) for k in range(9)]
    for fx in (-9.0, 9.0):
        b.box(fx - 1.3, fx + 1.3, -1.3, 1.3, deck(0.0) - 0.6, deck(0.0) + 1.4, "steel.plate", "arch_foot")
    for i, (p0, p1) in enumerate(zip(pts, pts[1:])):
        _beam(b, tuple(p0), tuple(p1), _poly(0.55, 6), _poly(0.55, 6), "amber.shield", "projector_glow")
        _beam(b, tuple(p0.lerp(p1, 0.0 if i == 0 else 0.17)), tuple(p0.lerp(p1, 1.0 if i == 7 else 0.83)), _poly(1.05, 6), _poly(1.05, 6), "steel.plate", "projector_arch")

    def nac_top(y):
        """The nacelle's top: the deck carried out over the booster, sloping down with the
        hull's taper to the drum's crown at the stern."""
        return deck(-6.0 * K) + (deck(-33.0 * K) - deck(-6.0 * K)) * (-6.0 * K - y) / (27.0 * K)
    for s in (-1.0, 1.0):
        # The cheeks: each nacelle's shoulder grown forward along the flank as an armoured
        # sponson that tapers into the hull at the bow, its crease carrying the field rail, its
        # top the tub and the emitters.
        CHEEK = [(24.0, 2.0, 11.0, 13.0), (10.0, 7.0, 10.0, 15.6), (-8.0, 9.0, 10.0, 16.4), (-20.0, 8.0, 10.0, 16.4)]   # (y, out from the hull's flank, z0, z1)
        secs = []
        for (y, out, z0, z1) in CHEEK:
            w, hz0, hz1 = at(y)
            hw = w / 2.0
            secs.append((y, _mirror([(hw - 1.0, z0 - 0.5), (hw + out, z0 + 1.0), (hw + out + 0.4, (z0 + z1) / 2.0), (hw + out - 0.6, z1), (hw - 1.0, z1 + 0.4)], s)))
        b.loft(secs, "steel.plate", "cheek")
        rail = []
        for (y, out, z0, z1) in CHEEK[1:]:
            w, hz0, hz1 = at(y)
            hw, zc = w / 2.0 + out, (z0 + z1) / 2.0
            rail.append((y, _mirror([(hw + 0.9, zc), (hw - 0.1, zc + 1.0), (hw - 0.8, zc), (hw - 0.1, zc - 1.0)], s)))
        b.loft(list(reversed(rail)), "amber.shield", "field_rail")
        # The emitters ahead of and behind the tub, clear of a gun's muzzle and its breech,
        # low pylons in the hull's colour on the cheek's top (Ryan, 28 October: the pylon ahead
        # of the tub was a livery chunk in the way of the mount).
        for ey in (13.0, -21.0):
            w, hz0, hz1 = at(ey)
            out, ctop = _lerp_at([(y, o, z1) for (y, o, z0, z1) in CHEEK], ey)
            ex = s * (w / 2.0 + out - 2.6)
            b.loft([(ey - 2.4, rect(ex, 2.4, ctop - 0.6, ctop + 1.6)), (ey + 2.4, rect(ex, 2.4, ctop - 0.6, ctop + 1.6))], "steel.plate", "emitter_pylon")
            b.loft([(ey - 2.0, rect(ex, 2.2, ctop + 1.6, ctop + 2.8)), (ey + 2.0, rect(ex, 2.2, ctop + 1.6, ctop + 2.8))], "amber.shield", "emitter")
        tx = s * (at(-10.0)[0] / 2.0 + 5.0)
        b.box(tx - 2.0, tx + 2.0, -12.0, -7.0, 16.2, 17.4, "steel.panel", "mount")
        b.stock("hp_%d" % (1 if s < 0 else 3), (tx, -7.0, 18.6), "barrel" if s < 0 else "twin_barrel", scale=0.5, carries="laser_carbine" if s < 0 else "twin_autoguns")
        # The nacelles and the giant boosters, the Puffin's grown to the size: the deck carried
        # over each drum, the louvred vent housing on its top, the drum's mouth ahead as the
        # intake, its lit ring and exhaust past the stern.
        bx, bz, br = s * 17.0 * K, 6.0 + (12.4 - 6.5) * K, 6.4 * K
        def nac(y, x_out):
            t = nac_top(y)
            return _mirror([(10.0 * K, 8.6), (x_out, 8.6), (x_out, t - 1.6), (x_out - 1.6, t), (10.0 * K, t)], s)
        b.loft([(-6.0 * K, nac(-6.0 * K, 22.2 * K)), (-20.0 * K, nac(-20.0 * K, 22.0 * K)), (-33.0 * K, nac(-33.0 * K, 21.2 * K))], "steel.plate", "nacelle")
        b.prism("y", bx, -20.5 * K, bz, br, 31.0 * K, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", bx, -31.5 * K, bz, br + 0.08, 3.6, "livery.livery", 6, "booster_band", phase=math.pi / 6)   # paint on the drum, not a chunk proud of it
        b.loft([(-5.0 * K, hexagon(bx, bz, 12.0 * K, 10.6 * K)), (-4.4 * K, hexagon(bx, bz, 10.6 * K, 9.4 * K))], "bore.dark", "intake")
        b.prism("y", bx, -4.8 * K, bz, 7.2 * K, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
        hx0, hx1 = min(s * 13.0 * K, s * 19.0 * K), max(s * 13.0 * K, s * 19.0 * K)
        b.loft([(-9.0 * K, rect((hx0 + hx1) / 2.0, hx1 - hx0, nac_top(-9.0 * K) - 0.3, nac_top(-9.0 * K) + 1.0)),
                (-29.0 * K, rect((hx0 + hx1) / 2.0, hx1 - hx0, nac_top(-29.0 * K) - 0.3, nac_top(-29.0 * K) + 1.0))], "steel.dark", "vent_housing")
        lx0, lx1 = min(s * 13.5 * K, s * 18.5 * K), max(s * 13.5 * K, s * 18.5 * K)
        b.loft([(-10.0 * K, rect((lx0 + lx1) / 2.0, lx1 - lx0, nac_top(-10.0 * K) + 1.0, nac_top(-10.0 * K) + 1.5)),
                (-28.0 * K, rect((lx0 + lx1) / 2.0, lx1 - lx0, nac_top(-28.0 * K) + 1.0, nac_top(-28.0 * K) + 1.5))], "steel.vent", "vent_louvres")
        b.prism("y", bx, -36.0 * K, bz, 7.3 * K, 1.2, "steel.plate", 6, "exhaust_lip", phase=math.pi / 6)
        b.prism("y", bx, -36.9 * K, bz, 6.9 * K, 1.4, "amber.engine", 6, "nozzle_ring", phase=math.pi / 6)
        b.loft([(-37.6 * K, hexagon(bx, bz, 11.2 * K, 9.8 * K)), (-38.1 * K, hexagon(bx, bz, 10.0 * K, 8.6 * K))], "amber.exhaust", "exhaust")
    b.box(-6.5, -2.5, -26.0, -22.0, deck(-24.0) - 0.6, deck(-24.0) + 0.9, "steel.panel", "mount")
    b.stock("hp_2", (-4.5, -22.0, deck(-24.0) + 2.0), "rack", scale=0.5, carries="ankle_mortar")
    b.pad("hp_4", (4.5, -24.0, deck(-24.0) + 1.0), scale=0.5, size=(4.0, 1.4))
    # Two canted fins on the afterdeck, tall and swept back.
    fh, fy0, fy1 = 14.0, -48.0, -39.0
    for s in (-1.0, 1.0):
        a = math.radians(s * 35.0)
        fx, fz = s * 8.0, deck(-35.0)
        root = [(fx, -40.0, fz - 0.8), (fx, -28.0, fz - 0.8), (fx, -28.0, fz + 0.2), (fx, -40.0, fz + 0.2)]
        tip = [(fx + fh * math.sin(a), fy0, fz + fh * math.cos(a)), (fx + fh * math.sin(a), fy1, fz + fh * math.cos(a)),
               (fx + fh * math.sin(a), fy1, fz + 0.5 + fh * math.cos(a)), (fx + fh * math.sin(a), fy0, fz + 0.5 + fh * math.cos(a))]
        _wing(b, root, tip, "livery.livery", "fin")
        tz = fz + fh * math.cos(a)
        b.box(fx + fh * math.sin(a) - 0.5, fx + fh * math.sin(a) + 0.5, fy0 - 0.2, fy1 + 0.2, tz + 0.4, tz + 1.2, "amber.shield", "field_tip")
    for (nx, ny) in ((-9.0, 12.0), (9.0, 12.0), (-9.0, -18.0), (9.0, -18.0)):
        b.prism("z", nx, ny, 6.4, 2.6, 1.4, "amber.engine", 6, "lift_nozzle")

    # Idle acts (four, loud, never in step; a medium hovercraft's servos). Degrees and seconds;
    # a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k).
    boosters = ["nozzle_ring", "exhaust"]
    field = ["field_rail", "emitter", "projector_glow", "field_strip", "field_tip", "spark_ring"]
    HOT = 28.0   # the field lit (Ryan, 28 October: much brighter when lit)
    # The field up: the emitters, the rails, the strips, the arch and the fin tips flare and
    # hold, and it squats braced behind the field; then it dies back.
    b.act("field_up", 5.0, body=[(0.5, 0.0, 0.0, 0.0), (1.3, 0.0, -1.0, -1.6, 0.0, 2.0, 0.0), (3.4, 0.0, -1.0, -1.6, 0.0, 2.0, 0.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(field, [(0.8, 0.0), (1.2, HOT), (1.5, 6.0), (1.8, HOT), (3.4, HOT), (4.3, 0.0)])])
    # The ram: it rears, lunges with the whole field flashing on the blow, and settles back.
    b.act("ram", 3.8, body=[(0.9, 0.0, -2.0, 0.5, 0.0, 2.0, 0.0), (1.4, 0.0, 12.0, -1.0, 0.0, -4.0, 0.0), (2.0, 0.0, 7.0, -0.5, 0.0, -1.0, 0.0), (3.8, 0.0, 0.0, 0.0)],
          glow=[(field + ["spark"], [(1.3, 0.0), (1.4, HOT + 8.0), (1.8, 4.0), (2.5, 0.0)]), (boosters, [(0.9, 0.0), (1.4, 8.0), (2.2, 2.0), (3.0, 0.0)])], heft=0.06)
    # St. Elmo's fire: the sparks round the port crackle one after another and build to a
    # blaze with the ring and the core, the hull heaving up on its cushion and shuddering;
    # then the field strips flicker as the shield mends, and it dies back.
    sparks = []
    for i in range(8):
        t = 0.4 + 0.11 * i
        sparks.append((["spark_%d" % i], [(t, 0.0), (t + 0.08, HOT), (t + 0.2, 2.0), (t + 0.5, HOT), (t + 0.62, 4.0), (t + 0.9, HOT), (2.6, HOT), (3.6, HOT), (4.3, 0.0)]))
    b.act("st_elmo", 4.8, body=[(0.4, 0.0, 0.0, 0.0), (1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 2.5), (1.3, 0.0, 0.0, 1.6, 0.0, 0.0, -2.5), (1.6, 0.0, 0.0, 2.4, 0.0, -2.0, 2.0), (1.9, 0.0, 0.0, 3.0, 0.0, 1.5, -1.5),
                                 (2.4, 0.0, 0.0, 3.4, 0.0, -1.0, 0.0), (3.6, 0.0, 0.0, 3.2, 0.0, 0.0, 0.0), (4.8, 0.0, 0.0, 0.0)],
          glow=sparks + [(["spark_ring"], [(1.2, 0.0), (1.4, HOT), (1.55, 5.0), (1.8, HOT), (3.6, HOT), (4.3, 0.0)]), (["corona"], [(1.4, 0.0), (2.2, 10.0), (3.6, 10.0), (4.3, 0.0)]),
                         (["field_strip", "field_rail"], [(2.4, 0.0), (2.6, HOT), (2.8, 3.0), (3.0, HOT), (3.2, 3.0), (3.5, HOT), (4.2, 0.0)])])
    # Pattering: three quick hops forward over the water, the emitters flicking with each as the
    # bird's wings do, then a glide back onto its station.
    b.act("patter", 4.2, body=[(0.4, 0.0, 0.0, 0.0), (0.6, 0.0, 3.0, 1.6, 0.0, -2.0, 0.0), (0.8, 0.0, 5.0, 0.0, 0.0, 1.0, 0.0), (1.0, 0.0, 8.0, 1.6, 0.0, -2.0, 0.0),
                               (1.2, 0.0, 10.0, 0.0, 0.0, 1.0, 0.0), (1.4, 0.0, 13.0, 1.6, 0.0, -2.0, 0.0), (1.6, 0.0, 15.0, 0.0, 0.0, 1.0, 0.0), (2.6, 0.0, 9.0, 0.0, 0.0, -1.0, 0.0),
                               (4.2, 0.0, 0.0, 0.0)],
          glow=[(["emitter", "field_tip"], [(0.5, 0.0), (0.6, HOT), (0.8, 0.0), (1.0, HOT), (1.2, 0.0), (1.4, HOT), (1.6, 0.0)]), (boosters, [(0.3, 0.0), (0.6, 6.0), (1.6, 6.0), (2.2, 0.0)])])
    # Movement: it runs flat and fast, nose down a touch, and drifts through its corners like
    # the Puffin, never banking (a hovercraft keeps flat).
    b.halo = [("nozzle_ring", KESTREL_HALO), ("exhaust", KESTREL_HALO), "projector_glow"]   # its boosters and the projector arch, hot (Ryan, 31 October)
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, -3.0, 0.0), glow={"parts": boosters, "k": KESTREL_BURN}, rock=3.0)
    b.fires = {"st_elmos_regenerator": ("st_elmo", 1.1, 2.7)}   # its fixed weapon fires with a slice of its act: the sparks' chase, the ring and the corona (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.move(slide=0.3, bank=0.0, accel=0.6, heft=0.14, oversteer=1.1)

storm_petrel.maker = "kestrel"

def lammergeier(b):
    """Kestrel "Lammergeier" (K-19 Mk I Flying-Wing Minelayer): the heavy flyer that mines the
    empty slots (Ryan, 27 October: the flying wing drawn for the Giant Petrel to the
    Lammergeier instead, airborne, "looks good but careful on the weapon mount placement so they
    don't clip"). One chrome chevron, a deeper centre body on it with the canopy far forward
    and the Fuse-delayed Bay under it (a recessed well, its doors ajar on a lit seam, the mines
    inside); four giant booster drums across the trailing edge; the Syrinx Drone's launcher
    tubes (fixed, no pin) recessed in the leading edge's roots; the Lorentz Contractor (fixed,
    no pin) a dish on a dorsal pylon aft that turns (joint sensor_contractor); cobalt fins
    canted out at the tips. The mounts stand on the wing's top in the bays between the drums,
    an inner pair ahead of the inner boosters and an outer pair on the outer wing, each clear
    of the drums, the tubes and the body with a swapped piece at its widest (the dish's class).
    Mounts in the die's order: hp_1 the left inner bay (the Incendiary Shells, a rack), hp_2 the
    right inner (the Enfilade Beam, a barrel), hp_3 the left outer wing (the Polarity Projector,
    a dish), hp_4 the right outer (the Arc-fault Cannon, twin barrels). Centred on z = 0 as
    the flyers are."""
    Z = 0.0
    LE = [(0.0, 52.0), (12.0, 46.0), (26.0, 38.0), (42.0, 28.0), (58.0, 18.0), (72.0, 10.0)]   # (x, y) of the leading edge, right half
    TE = [(72.0, 2.0), (58.0, -3.0), (42.0, -12.0), (26.0, -22.0), (12.0, -28.0), (0.0, -30.0)]
    le = lambda x: _lerp_at([(-p[0], p[1]) for p in LE], -abs(x))[0]
    te = lambda x: _lerp_at([(-p[0], p[1]) for p in reversed(TE)], -abs(x))[0]
    thick = lambda x: max(1.4, 7.0 - abs(x) * 0.075)
    _rings(b, [_blade_section(x, le(x), te(x), Z, thick(x), lead=0.42) for x in (-72.0, -58.0, -42.0, -26.0, -12.0, 0.0, 12.0, 26.0, 42.0, 58.0, 72.0)], "steel.plate", "wing")
    HULL = [(50.0, 7.0, -4.0, 4.0, 1.2), (40.0, 14.0, -7.0, 8.0, 2.4), (22.0, 20.0, -8.5, 10.0, 3.0), (0.0, 20.0, -8.5, 10.0, 3.0), (-20.0, 16.0, -7.0, 8.0, 2.4), (-34.0, 9.0, -4.0, 5.0, 1.4)]
    deck = lambda y: _lerp_at([(y, z1) for (y, w, z0, z1, c) in HULL], y)[0]
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "body")
    _boat_cab(b, deck, [(46.0, 4.0, 0.6), (42.0, 8.0, 2.4), (36.0, 11.0, 3.2), (29.0, 11.0, 2.8), (25.0, 8.0, 1.4)], 37.0)
    # The bomb bay under the body: a recessed well with its doors ajar and a lit seam.
    b.loft([(24.0, rect(0.0, 12.0, -9.6, -8.4)), (-18.0, rect(0.0, 12.0, -9.6, -8.4))], "steel.dark", "bay_frame")
    for s in (-1.0, 1.0):
        b.loft([(22.0, [(s * 1.4, -9.6), (s * 5.8, -9.6), (s * 6.4, -11.2), (s * 2.0, -11.2)]), (-16.0, [(s * 1.4, -9.6), (s * 5.8, -9.6), (s * 6.4, -11.2), (s * 2.0, -11.2)])], "steel.plate", "bay_door")
    b.loft([(22.0, rect(0.0, 2.6, -9.9, -9.4)), (-16.0, rect(0.0, 2.6, -9.9, -9.4))], "amber.ember", "bay_seam")
    # Four giant boosters across the trailing edge, their mouths on the wing's top.
    for x in (-44.0, -20.0, 20.0, 44.0):
        bz, br = Z + 2.0, 5.8
        ty = te(x)
        b.prism("y", x, ty + 9.0, bz, br, 26.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", x, ty + 22.6, bz, br + 0.6, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
        b.loft([(ty + 23.1, _hexr(x, bz, br - 0.2)), (ty + 23.3, _hexr(x, bz, br - 0.8))], "bore.dark", "intake")
        b.prism("y", x, ty - 5.0, bz, br + 0.4, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
        b.loft([(ty - 5.8, _hexr(x, bz, br + 0.2)), (ty - 6.3, _hexr(x, bz, br - 0.6))], "amber.exhaust", "exhaust")
        b.loft([(ty + 2.0, [(xx + x, z) for (xx, z) in _case(12.0, bz - 2.0, bz + 2.0, 1.0)]), (ty + 7.0, [(xx + x, z) for (xx, z) in _case(13.0, bz - 2.5, bz + 3.2, 1.2)])], "livery.livery", "booster_band")
    # The Syrinx Drone's launchers: a nacelle on each leading-edge root that carries the
    # wing's full thickness forward to a blunt face raked with the edge, top and bottom, the
    # two tubes let into the face over lit floors (Ryan, 28 October: the tubes let into the
    # bare edge showed the wing's skin inside them, and a pod sat on the wing's top read as a
    # box stuck on).
    # The nacelle rides on the wing's upper skin, its underside following the skin's rise from
    # the edge, and the tubes run above the skin the whole way (Ryan, 28 October, the fifth
    # time round: the wing's skin showed through the bores whenever they were open, since
    # the skin climbs 2.4 over the bore's depth; the caps had hidden it).
    TZ = Z + 4.2
    for s in (-1.0, 1.0):
        x0, x1 = s * 10.5, s * 23.5
        def ring(y_at, zb, zt):
            return [(x0, y_at(x0), zb), (x1, y_at(x1), zb), (x1, y_at(x1), zt - 0.9), (x1 * 0.92 + x0 * 0.08, y_at(x1), zt), (x0 * 0.92 + x1 * 0.08, y_at(x0), zt), (x0, y_at(x0), zt - 0.9)]
        back, face = ring(lambda x: le(17.0) - 14.0, Z + 1.8, Z + 7.0), ring(lambda x: le(x) + 0.6, Z - 0.4, Z + 6.4)
        _rings(b, [back, ring(lambda x: le(x) - 5.0, Z + 0.6, Z + 6.8), face], "steel.dark", "drone_pod", cap=False)
        _face(b, back, "steel.dark", "drone_pod")
        # The tubes are bored through the face: each mouth a hole in the face plate, flush with
        # it and following its rake, the bore twelve deep and dark (Ryan, 28 October: a mouth on the face read as an end cap, not
        # a hole; before that, square ends through the raked face had clipped).
        mouths = []
        for k in range(2):
            x = s * (14.0 + 6.0 * k)
            rake = lambda v, x=x: le(v.x) - le(x)
            _tube(b, (x, le(x) - 12.0, TZ), (x, le(x) + 0.6, TZ), 2.1, 1.6, 8, "bore.dark", "drone_tube", floor_material="amber.ember", floor_depth=0.8, rake=rake)   # a dark bore (Ryan, 28 October: not the hull's light plate)
            # The drone it fires (Ryan, 3 November: "Lammergeier needs something for the launch drone. I
            # guess a new drone model that fires out, something simple"): a small dart in the tube's
            # mouth, hidden at rest, flying out along the bore as the Syrinx Drone fires, its tail lit,
            # the inner pair as the floors first flash and the outer as they flash again.
            y0 = le(x) + 0.6
            with b.launch("syrinx_drone", (x, y0 - 3.4, TZ), (0.0, 1.0, 0.0), reach=150.0, seconds=0.6, delay=0.3 if k == 0 else 0.65):
                b.prism("y", x, y0 - 3.6, TZ, 1.5, 5.2, "steel.plate", 6, "drone_body", phase=math.pi / 6)   # as wide as the bore takes, to read at a fight's size
                b.loft([(y0 - 1.0, _hexr(x, TZ, 1.5)), (y0 + 0.8, _hexr(x, TZ, 0.4))], "steel.dark", "drone_nose")
                for fx_, fz_ in ((2.3, 0.16), (0.16, 2.3)):
                    b.box(x - fx_, x + fx_, y0 - 6.2, y0 - 4.6, TZ - fz_, TZ + fz_, "steel.dark", "drone_fin")
                b.prism("y", x, y0 - 6.4, TZ, 1.05, 0.5, "amber.exhaust", 6, "drone_thruster", phase=math.pi / 6)
            mouths.append([(x + 2.1 * math.cos(i * math.pi / 4.0), le(x + 2.1 * math.cos(i * math.pi / 4.0)) + 0.6, TZ + 2.1 * math.sin(i * math.pi / 4.0)) for i in range(8)])
        _plate(b, face, mouths, "steel.dark", "drone_pod")
    # The Lorentz Contractor's dish on a dorsal pylon aft of the body's crown.
    uy, uz = -10.0, deck(-10.0)
    b.loft([(-6.0, rect(0.0, 4.0, uz - 0.4, uz + 3.0)), (-14.0, rect(0.0, 3.0, uz - 0.4, uz + 3.6))], "steel.dark", "contractor_mast")
    with b.joint("sensor_contractor", (0.0, uy, uz + 3.6), axis="yaw", limits=(-120.0, 120.0)):
        tilt = Matrix.Translation((0.0, uy, uz + 3.2)) @ Matrix.Rotation(math.radians(40.0), 4, "X")
        b.loft([(0.0, _poly(1.0, 8)), (1.6, _poly(1.1, 8)), (2.8, _poly(6.0, 8)), (3.8, _poly(6.4, 8))], "steel.plate", "contractor_dish", tilt)
        b.loft([(2.6, _poly(1.3, 8)), (3.6, _poly(1.3, 8))], "amber.lit", "contractor_core", tilt)
    # The mounts on the wing's top: the inner pair in the bays between the body and the inner
    # drums (x 32, where the drum at 20 reaches 25.8 and the rack's class at its scale 27.1), the
    # outer pair on the outer wing past the outer drums (x 57, where the drum at 44 reaches 49.8
    # and the dish's class 51.9); the drone tubes end at y 31 and more, the inner mounts at 10.
    for s, pin, kind, cid in ((-1.0, "hp_1", "rack", "incendiary_shells"), (1.0, "hp_2", "barrel", "enfilade_beam")):
        tx, ty = s * 32.0, 10.0
        tz = Z + thick(tx) * 0.5
        b.box(tx - 1.8, tx + 1.8, ty - 3.0, ty + 1.0, tz - 0.4, tz + 1.0, "steel.panel", "mount")
        b.stock(pin, (tx, ty + 1.5, tz + 1.8), kind, scale=0.7, carries=cid)
    for s, pin, kind, cid in ((-1.0, "hp_3", "dish", "polarity_projector"), (1.0, "hp_4", "twin_barrel", "arc_fault_cannon")):
        tx, ty = s * 57.0, 6.0
        tz = Z + thick(tx) * 0.5
        b.box(tx - 1.8, tx + 1.8, ty - 3.0, ty + 1.0, tz - 0.4, tz + 1.0, "steel.panel", "mount")
        b.stock(pin, (tx, ty + 1.5, tz + 1.8), kind, scale=0.7, carries=cid)
    for s in (-1.0, 1.0):
        a = math.radians(s * 30.0)
        _rings(b, [[(s * 70.0, 10.0, Z), (s * 70.4, 6.0, Z), (s * 70.0, 2.0, Z), (s * 69.6, 6.0, Z)],
                   [(s * 70.0 + 10.0 * math.sin(a), 3.0, Z + 10.0 * math.cos(a)), (s * 70.0 + 10.0 * math.sin(a) + s * 0.2, 0.5, Z + 10.0 * math.cos(a)),
                    (s * 70.0 + 10.0 * math.sin(a), -2.0, Z + 10.0 * math.cos(a)), (s * 70.0 + 10.0 * math.sin(a) - s * 0.2, 0.5, Z + 10.0 * math.cos(a))]], "livery.livery", "fin")

    # Idle acts (four, loud, never in step; a heavy airframe's servos). Degrees and seconds; a
    # body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll); a glow key is (t, k).
    boosters = ["booster_ring", "exhaust"]
    # Laying mines: a slow run forward nose down, the bay's seam flashing three times as the
    # mines drop, then it lifts clear.
    b.act("lay_mines", 5.4, body=[(0.6, 0.0, 0.0, 0.0), (1.4, 0.0, 6.0, -1.0, 0.0, -4.0, 0.0), (3.6, 0.0, 10.0, -1.0, 0.0, -3.0, 0.0), (4.6, 0.0, 2.0, 0.5, 0.0, 2.0, 0.0), (5.4, 0.0, 0.0, 0.0)],
          glow=[(["bay_seam"], [(1.0, 0.0), (1.4, 12.0), (1.8, 4.0), (2.2, 14.0), (2.6, 4.0), (3.0, 14.0), (3.6, 14.0), (4.4, 0.0)]), (boosters, [(0.5, 0.0), (1.2, 6.0), (3.8, 6.0), (4.6, 0.0)])])
    # The contraction: the dish swings onto its mark and its core builds to a blaze and holds,
    # the wing settling a touch under the pull.
    b.act("contract", 5.6, {"sensor_contractor": [(0.5, 0.0), (1.9, 60.0), (3.6, 60.0), (5.0, 0.0)]},
          body=[(0.5, 0.0, 0.0, 0.0), (1.9, 0.0, 0.0, -0.8, 0.0, 1.5, 0.0), (3.6, 0.0, 0.0, -0.8, 0.0, 1.5, 0.0), (5.0, 0.0, 0.0, 0.0)],
          glow=[(["contractor_core"], [(1.8, 0.0), (2.1, 10.0), (2.4, 2.0), (2.7, 12.0), (3.6, 12.0), (4.4, 0.0)])])
    # The Syrinx launch: a shudder as the drones leave the tubes, their floors flashing, and a
    # small yaw after them.
    b.act("syrinx_launch", 4.4, body=[(0.6, 0.0, 0.0, 0.0), (1.0, 0.0, -2.0, 0.6, 0.0, 2.0, 0.0), (1.3, 0.0, -1.0, 0.0, -4.0, 0.0, -3.0), (1.8, 0.0, 1.0, 0.4, 4.0, -1.0, 3.0),
                                      (2.6, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0), (4.4, 0.0, 0.0, 0.0)],
          glow=[(["drone_tube_floor"], [(0.7, 0.0), (0.9, 14.0), (1.1, 2.0), (1.25, 14.0), (1.5, 2.0), (2.2, 0.0)]), (boosters, [(0.6, 0.0), (1.0, 4.0), (2.4, 4.0), (3.2, 0.0)])])
    # The wheel: a long banked turn to the left and a shallower one back, the outer boosters
    # brighter in each.
    b.act("wheel", 5.6, {"sensor_contractor": [(0.8, 0.0), (2.2, -40.0), (4.0, 30.0), (5.2, 0.0)]},
          body=[(0.5, 0.0, 0.0, 0.0), (1.6, -10.0, 4.0, 1.0, 14.0, -2.0, -22.0), (2.8, -14.0, 2.0, 2.0, 6.0, 0.0, -16.0), (4.0, 8.0, 2.0, 1.0, -10.0, -1.0, 14.0),
                (5.6, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.5, 0.0), (1.4, 7.0), (4.2, 7.0), (5.0, 0.0)])])
    # Movement: a heavy flyer, banking into its turns and slow to gather way, nose down a touch.
    b.halo = [("booster_ring", KESTREL_HALO), ("exhaust", KESTREL_HALO), "drone_tube_floor"]   # its boosters and drone tubes, hot (Ryan, 31 October)
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, -2.0, 0.0), glow={"parts": boosters, "k": KESTREL_HEAVY})
    b.fires = {"lorentz_contractor": ("contract", 1.5, 3.0), "syrinx_drone": ("syrinx_launch", 0.6, 2.0)}   # its fixed weapons fire with slices of its acts: the contractor's flare; the drones' launch (Ryan, 31 October: "go for ones that are cheapest to do first")
    b.move(slide=0.4, bank=22.0, accel=1.2, heft=0.2, oversteer=0.4)

lammergeier.maker = "kestrel"


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


def _slab(b, pts, normal, thick, material, label):
    """A flat polygon given in world space, `thick` deep along `normal` and centred on it."""
    n = Vector(normal).normalized() * (thick / 2.0)
    bm = bmesh.new()
    top = [bm.verts.new(Vector(p) + n) for p in pts]
    bot = [bm.verts.new(Vector(p) - n) for p in pts]
    bm.faces.new(top)
    bm.faces.new(list(reversed(bot)))
    for i in range(len(pts)):
        j = (i + 1) % len(pts)
        bm.faces.new([bot[i], bot[j], top[j], top[i]])
    return b._finish(bm, material, label)


def _plug(b, tag, centre, axis, r, depth, n=3, thick=0.6, material="steel.stripe"):
    """A port's iris plug (the Polar Bear's Lockdown Shutters): `n` leaves of a disc of radius
    `r` about `centre`, square to `axis`, each a hair off the centre so the iris's seams read
    dark, all on one joint (`shutter_<tag>`, sliding along `axis`) that rests `depth` down the
    port's line, under its floor and out of sight in the shell. A form slides it home: it
    rises out of the floor once the gun has sunk and closes the mouth (Ryan, 29 October: the
    leaves drawn back across the shell showed, "it's no good like this"; a port on a sloping
    shell has no room beside its mouth to hide them). Returns (joint, its slide home), world
    units."""
    axis = Vector(axis).normalized()
    up = Vector((0.0, 0.0, 1.0))
    side = Vector((1.0, 0.0, 0.0)) if abs(axis.dot(up)) > 0.999 else axis.cross(up).normalized()
    over = side.cross(axis).normalized()
    rest = Vector(centre) - axis * depth
    span = 2.0 * math.pi / n
    name = "shutter_%s" % tag
    with b.joint(name, tuple(rest), slide=tuple(axis)):
        for k in range(n):
            a = math.pi / 2.0 + k * span   # the first leaf's bisector up the port's face
            tip = rest + (side * math.cos(a) + over * math.sin(a)) * 0.15
            pts = [tip] + [tip + (side * math.cos(a - span / 2.0 + j * span / 4.0) + over * math.sin(a - span / 2.0 + j * span / 4.0)) * r
                           for j in range(5)]
            _slab(b, pts, axis, thick, material, "shutter")
    return name, tuple(axis * depth)


def _hatch(b, tag, centre, inner, wall, proud, leaf=0.4, recess=0.25, well=1.25, seam=0.3, built_open=False,
           material="steel.stripe", leaf_material="steel.panel", cut=None, cut_dz=0.0):
    """A square port shut by trapdoors (the Clydesdale's batteries; Ryan, 11 November: "Sure,
    square ports, and either trapdoors or split middle - slide open, both could work. Depends on
    geometry"): a stripe frame round a square mouth `inner` from `centre` to each side, `wall`
    thick and standing `proud` of the deck (`centre` on the deck's top), a dark floor `well`
    under its rim, and two leaves across the mouth `recess` under the rim, meeting in the middle
    across a dark `seam`. Each leaf hangs from its bottom edge on the frame's front or back wall
    (`shutter_<tag>f`, `shutter_<tag>b`, pitch joints), so it drops open into the dark and hangs
    against its wall, out of a rising gun's way: trapdoors, since a deck with nothing cut out of
    it and its ports a hand apart has nowhere a sliding leaf could go. Built shut, or hanging
    open if `built_open`. Given `cut` (the parts the deck is), the mouth is a real well, cut
    through them down to its floor and lined dark, so the leaves hang in it where they can be seen
    (Ryan, 12 November: they had dropped "into the hull right under it, not into a hole"); `cut_dz`
    is the lift a raised block gives the parts after they are built, which a cutter does not
    get. Returns [(joint, its swing to the other state)], the front leaf's first, degrees on the
    joint's pitch."""
    cx, cy, cz = centre
    top = cz + proud
    outer = inner + wall
    b.box(cx - outer, cx + outer, cy + inner, cy + outer, cz - 0.1, top, material, "port_rim")
    b.box(cx - outer, cx + outer, cy - outer, cy - inner, cz - 0.1, top, material, "port_rim")
    for s in (-1.0, 1.0):
        b.box(min(cx + s * inner, cx + s * outer), max(cx + s * inner, cx + s * outer), cy - inner, cy + inner, cz - 0.1, top, material, "port_rim")
    floor = top - well
    if cut:
        lining = 0.3
        for s in (-1.0, 1.0):
            b.box(cx - inner - lining, cx + inner + lining, min(cy + s * inner, cy + s * (inner + lining)), max(cy + s * inner, cy + s * (inner + lining)),
                  floor - 0.3, cz - 0.05, "steel.dark", "port_well")
            b.box(min(cx + s * inner, cx + s * (inner + lining)), max(cx + s * inner, cx + s * (inner + lining)), cy - inner, cy + inner,
                  floor - 0.3, cz - 0.05, "steel.dark", "port_well")
        b.cut_box(cut, cx - inner - 0.15, cx + inner + 0.15, cy - inner - 0.15, cy + inner + 0.15, floor - 0.25 + cut_dz, cz + 0.3 + cut_dz)
    b.box(cx - inner + 0.02, cx + inner - 0.02, cy - inner + 0.02, cy + inner - 0.02, min(cz - 0.05, floor - 0.3), floor, "bore.dark", "port_floor")
    z1 = top - recess
    z0 = z1 - leaf
    out = []
    for s, end in ((1.0, "f"), (-1.0, "b")):
        hinge = (cx, cy + s * (inner - 0.05), z0)
        opens = 90.0 * s   # a positive pitch drops the front leaf, which lies behind its hinge, and lifts the back one
        swing = -opens if built_open else opens
        turn = None
        if built_open:
            turn = Matrix.Translation(hinge) @ Matrix.Rotation(math.radians(opens), 4, "X") @ Matrix.Translation(tuple(-v for v in hinge))
        name = "shutter_%s%s" % (tag, end)
        with b.joint(name, hinge, axis="pitch", limits=(-90.0, 90.0)):   # both ways from either state, so an act can crack a leaf open shut or not (the hatch check)
            y_seam = cy + s * seam / 2.0
            b.box(cx - inner + 0.1, cx + inner - 0.1, min(y_seam, hinge[1]), max(y_seam, hinge[1]), z0, z1, leaf_material, "shutter", transform=turn)
        out.append((name, swing))
    return out


def _vent(b, cutting, origin, alpha, width, height, slats, prefix, rest, opens, wall=1.0, depth=3.6, rim=0.4, proud=0.6, pivot=0.7, thick=0.5, housing=None, back=0.0, flank=None, heat="vent_box_floor"):
    """An armoured louvred vent (the Polar Bear's radiators): a dark steel box `width` by
    `height` with heat banked in its floor (the part a glow names, labelled `heat`), a
    stripe rim round its mouth, and `slats` heavy louvres across the mouth, each on a pitch
    joint `<prefix><k>`, the lowest first. Sunk into a face of the shell, a hole cut through
    `cutting` for it, the rim standing `proud` of the face; or, given a `housing` material,
    standing out of the shell as an armoured box in it, its walls running `back` behind the
    mouth to a closed back planted in the shell, nothing cut, the hollow clear of the shell
    (Ryan, 29 October: "big boxy radiators sticking out at an angle"). `origin` is the mouth's
    centre, its face
    rising `alpha` degrees from flat toward the front and facing back (90 a rear face, 0 a
    top). A louvre stands `rest` degrees out of the face (positive lifts its upper edge out),
    so its joint's 0 is that rest; it shuts flat at `-rest` and opens to `opens` degrees out
    of the face at `opens - rest`. `flank`, given (-1 the left, 1 the right), lays the vent
    on that flank's 45-degree chamfer instead (the Polar Bear's radiators since Ryan's notes
    of 30 October), `width` along the machine and `height` up the slope, `alpha` unused: its
    louvres run along the machine on roll joints, the upper edge the one toward the spine.
    Returns [(joint, its shut swing, its open swing)], the lowest first, in the joint's own
    sense."""
    if flank is None:
        a = math.radians(alpha)
        X, U, N = Vector((1.0, 0.0, 0.0)), Vector((0.0, math.cos(a), math.sin(a))), Vector((0.0, -math.sin(a), math.cos(a)))
        axis, sense = "pitch", 1.0
    else:
        r = math.sqrt(0.5)
        U, N = Vector((-flank * r, 0.0, r)), Vector((flank * r, 0.0, r))
        X = U.cross(N)   # forward on the right flank, back on the left, so a turn about X lifts U toward N
        axis, sense = "roll", flank   # a roll turns about forward: about X on the right, against it on the left
    o = Vector(origin)
    at = lambda x, u, n: o + X * x + U * u + N * n
    frame = lambda hw, hh, n: [at(-hw, -hh, n), at(hw, -hh, n), at(hw, hh, n), at(-hw, hh, n)]
    hw, hh = width / 2.0, height / 2.0
    iw, ih = hw - wall, hh - wall
    if cutting:
        b.cut(cutting, tuple(at(0.0, 0.0, -depth)), tuple(at(0.0, 0.0, 0.5)), 0.0, section=[(-iw - 0.2, -ih - 0.2), (iw + 0.2, -ih - 0.2), (iw + 0.2, ih + 0.2), (-iw - 0.2, ih + 0.2)])
    tiles = (o, N, X, U, None)
    if housing:   # the armoured box out of the shell, closed at the back; the dark lining inside it
        _rings(b, [frame(hw, hh, -back), frame(hw, hh, proud - 0.3)], housing, "vent_housing", tiles, cap=False)
        _rings(b, [frame(hw, hh, -back - 0.3), frame(hw, hh, -back)], housing, "vent_housing", tiles)
        _rings(b, [frame(iw, ih, proud - 0.9), frame(iw, ih, -depth)], "steel.dark", "vent_box", tiles, cap=False)
    else:
        _rings(b, [frame(hw, hh, -depth), frame(hw, hh, proud - 0.3), frame(iw, ih, proud - 0.3), frame(iw, ih, -depth)], "steel.dark", "vent_box", tiles)
    _rings(b, [frame(hw, hh, proud - 0.9), frame(hw + rim, hh + rim, proud - 0.9), frame(hw + rim, hh + rim, proud), frame(iw, ih, proud), frame(iw, ih, proud - 0.9)],
           "steel.stripe", "vent_rim", tiles, cap=False)   # a lip under it, so no slot shows between the rim and the box
    _rings(b, [frame(iw - 0.05, ih - 0.05, -depth + 0.2), frame(iw - 0.05, ih - 0.05, -depth + 0.4)], "amber.heat", heat, tiles)
    pitch = 2.0 * ih / slats
    th = math.radians(rest)
    w, m = U * math.cos(th) + N * math.sin(th), N * math.cos(th) - U * math.sin(th)
    across = X.cross(Vector((0.0, 0.0, 1.0))).normalized()   # _beam's frame for a member along X
    over = across.cross(X).normalized()
    prof = [(v.dot(across), v.dot(over)) for v in (w * (-pitch / 2.0 + 0.05) - m * (thick / 2.0), w * (pitch / 2.0 - 0.05) - m * (thick / 2.0),
                                                   w * (pitch / 2.0 - 0.05) + m * (thick / 2.0), w * (-pitch / 2.0 + 0.05) + m * (thick / 2.0))]
    shut, swing = -rest * sense, (opens - rest) * sense
    lo, hi = min(shut, 1.1 * swing) - 3.0, max(shut, 1.1 * swing) + 3.0
    out = []
    for k in range(slats):
        c = at(0.0, -ih + pitch * (k + 0.5), -pivot)
        name = "%s%d" % (prefix, k + 1)
        with b.joint(name, tuple(c), axis=axis, limits={ax: ((lo, hi) if ax == axis else (0.0, 0.0)) for ax in ("pitch", "yaw", "roll")}):
            _beam(b, tuple(c - X * (iw - 0.15)), tuple(c + X * (iw - 0.15)), prof, prof, "steel.plate", "louvre")
        out.append((name, shut, swing))
    return out


def _popvent(b, cutting, centre, side, name, length=14.0, width=8.0, out=6.0, slats=5, heat="vent_box_floor"):
    """A vent on a flank's 45-degree chamfer (the Polar Bear's side vents: Ryan, 29 October,
    "small rectangular protrusions when sealed" that "slide out ... to show the vent face when
    venting", then "a larger footprint to sell"): a well cut into `cutting` and lined in dark steel under a stripe rim,
    and on a slide joint `name` along the slope's outward normal a dark cap `length` along the
    machine by `width` across the slope, standing a little proud of the rim at rest, over a
    stack as deep as the joint runs it `out`: `slats` thin dark slats ringed round a core of
    heat that glows between them (labelled `heat`, the part the vent act's glow names), dark posts at
    its corners. Home, the stack sits in the well under the cap; run out, all of it stands
    clear of the rim, the glow showing between the slats. `centre` is the vent's
    middle on the slope, `side` -1 for the left flank and 1 for the right. Returns (the
    joint, its line, how far it runs)."""
    nrm = Vector((side * math.sqrt(0.5), 0.0, math.sqrt(0.5)))   # out of the slope
    up = Vector((-side * math.sqrt(0.5), 0.0, math.sqrt(0.5)))   # up the slope, toward the spine
    along = Vector((0.0, 1.0, 0.0))
    c = Vector(centre)
    quad = lambda l0, l1, a0, a1, n: [c + along * l + up * a + nrm * n for l, a in ((l0, a0), (l1, a0), (l1, a1), (l0, a1))]
    rect = lambda hl, ha, n: quad(-hl, hl, -ha, ha, n)
    tiles = (c, nrm, along, up, None)
    hl, ha = length / 2.0, width / 2.0   # the cap
    wl, wa = hl - 0.4, ha - 0.4   # the well, inside the cap's edge
    floor = -out - 0.6   # the well's floor, under the stack when it is home
    b.cut(cutting, tuple(c + nrm * (floor - 0.2)), tuple(c + nrm * 0.5), 0.0, section=[(-wl - 0.15, -wa - 0.15), (wl + 0.15, -wa - 0.15), (wl + 0.15, wa + 0.15), (-wl - 0.15, wa + 0.15)])
    _rings(b, [rect(wl, wa, 0.05), rect(wl, wa, floor)], "steel.dark", "vent_well", tiles, cap=False)
    _rings(b, [rect(wl, wa, floor - 0.2), rect(wl, wa, floor)], "steel.dark", "vent_well", tiles)
    _rings(b, [rect(wl + 0.75, wa + 0.75, -0.2), rect(wl + 0.75, wa + 0.75, 0.35), rect(wl, wa, 0.35), rect(wl, wa, -0.2)], "steel.stripe", "vent_rim", tiles, cap=False)
    with b.joint(name, tuple(c), slide=tuple(nrm)):
        _rings(b, [rect(hl, ha, 0.3), rect(hl, ha, 1.3)], "steel.dark", "vent_cap", tiles)
        foot = 0.3 - out   # level with the rim once the joint runs out
        sl, sa = wl - 0.15, wa - 0.15   # the slats' outer faces, a hair inside the well
        pitch = out / slats
        # The slats stand a hair proud of the core, so the glow between them shows from a
        # glancing camera too (sunk a slat's depth, the cameras' 30 to 42 degrees hid it).
        for k in range(slats):   # the slats ringed round the core, thin, so the gaps between them carry most of its sides
            n0, n1 = foot + pitch * k, foot + pitch * (k + 0.3)
            _rings(b, [rect(sl, sa, n0), rect(sl, sa, n1), rect(sl - 0.3, sa - 0.3, n1), rect(sl - 0.3, sa - 0.3, n0), rect(sl, sa, n0)],
                   "steel.dark", "vent_slat", tiles, cap=False)
        for l0, a0 in ((-sl, -sa), (sl - 0.8, -sa), (sl - 0.8, sa - 0.8), (-sl, sa - 0.8)):   # the posts that carry the cap
            _rings(b, [quad(l0, l0 + 0.8, a0, a0 + 0.8, foot), quad(l0, l0 + 0.8, a0, a0 + 0.8, 0.3)], "steel.dark", "vent_post", tiles)
        _rings(b, [rect(sl - 0.12, sa - 0.12, foot), rect(sl - 0.12, sa - 0.12, 0.3)], "amber.heat", heat, tiles)
    return name, tuple(nrm), out


def _gear(cx, cz, r_out, r_in, teeth, phase=0.0):
    """A toothed section as (x, z) points about (cx, cz), counter-clockwise from +y: `teeth`
    teeth of radius r_out between roots of r_in (the Kite's pinions)."""
    return [(cx + (r_out if k % 2 == 0 else r_in) * math.cos(phase + k * math.pi / teeth),
             cz + (r_out if k % 2 == 0 else r_in) * math.sin(phase + k * math.pi / teeth)) for k in range(teeth * 2)]


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


def _tube(b, p0, p1, r_out, r_in, n, material, label, floor_material="bore.dark", floor_depth=0.5, floor=True, phase=0.0, rake=None):
    """A hollow cylinder from `p0` to `p1`, open at `p1`: an outer wall, the rim, an inner wall
    down to a dark floor just above `p0`. A recessed gun port: the mount sits on the floor
    and the barrel rises out of the mouth (Ryan, 30 September). `floor=False` leaves both
    ends open, for a rim ring over a port (its floor had been a lid over every port: Ryan,
    1 October). `rake`, given, is a function of a mouth vertex returning how far along the
    tube to carry it, so the mouth follows a face that is not square to the tube (the
    Lammergeier's launchers in their raked nacelle faces)."""
    d = (Vector(p1) - Vector(p0)).normalized()
    up = Vector((0.0, 0.0, 1.0))
    side = Vector((1.0, 0.0, 0.0)) if abs(d.dot(up)) > 0.999 else d.cross(up).normalized()
    over = side.cross(d).normalized()
    def ring(p, r):
        return [Vector(p) + side * (r * math.cos(phase + i * 2.0 * math.pi / n)) + over * (r * math.sin(phase + i * 2.0 * math.pi / n)) for i in range(n)]
    bm = bmesh.new()
    o0 = [bm.verts.new(v) for v in ring(p0, r_out)]
    o1 = [bm.verts.new(v + d * (rake(v) if rake else 0.0)) for v in ring(p1, r_out)]
    i1 = [bm.verts.new(v + d * (rake(v) if rake else 0.0)) for v in ring(p1, r_in)]
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


def _chamfered(cx, w, z0, z1, c):
    """A rectangle cross-section with its two top corners cut off by `c` across and down, as
    (x, z) points counter-clockwise seen from +y (rect()'s order with the corners cut): a box
    section made a little more streamlined (the Kite's tail)."""
    return [(cx - w / 2, z0), (cx + w / 2, z0), (cx + w / 2, z1 - c), (cx + w / 2 - c, z1), (cx - w / 2 + c, z1), (cx - w / 2, z1 - c)]


def _frame(b, outer, inner, y0, y1, material, label):
    """A rim round a mouth: the band between two outlines in the x-z plane with the same count
    of points, `outer` round `inner`, from `y0` to `y1` along y, so a mouth of any convex shape
    has a lip of its own shape (the Kite's intake on its chamfered tail)."""
    bm = bmesh.new()
    rings = [[bm.verts.new((x, y, z)) for x, z in pts] for pts in (outer, inner) for y in (y0, y1)]
    o0, o1, i0, i1 = rings
    n = len(outer)
    for k in range(n):
        j = (k + 1) % n
        bm.faces.new([o0[k], o0[j], i0[j], i0[k]])   # the band at y0
        bm.faces.new([o1[k], i1[k], i1[j], o1[j]])   # the band at y1
        bm.faces.new([o0[k], o1[k], o1[j], o0[j]])   # outside
        bm.faces.new([i0[k], i0[j], i1[j], i1[k]])   # inside the mouth
    return b._finish(bm, material, label)


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


def _face(b, pts, material, label):
    """One flat polygon through 3D points: a cap over an open loft."""
    bm = bmesh.new()
    bm.faces.new([bm.verts.new(Vector(p)) for p in pts])
    return b._finish(bm, material, label)


def _plate(b, outer, holes, material, label):
    """A flat polygon with holes in it, as 3D points: the outer outline and each hole's ring,
    tessellated (mathutils), so a bore shows as a true hole in a face rather than a disc on
    it (the Lammergeier's launchers)."""
    from mathutils.geometry import tessellate_polygon
    polys = [[Vector(p) for p in outer]] + [[Vector(p) for p in h] for h in holes]
    flat = [v for poly in polys for v in poly]
    bm = bmesh.new()
    verts = [bm.verts.new(v) for v in flat]
    for tri in tessellate_polygon(polys):
        bm.faces.new([verts[i] for i in tri])
    return b._finish(bm, material, label)


def _rings(b, rings, material, label, frame=None, cap=True):
    """A loft through any number of sections given as 3D point rings, capped at both ends
    unless `cap` is False (an annulus or an open tube: a cap would be a disc over the
    hole, which is what hid the Buzzard's muzzle until 1 October). `frame` maps the tiles
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
    the foot kept flat to the ground under a body pitched `pitch`. The knee bends the way the
    model's rest pose bends it (_bend), or the way a limb's "bend" says (Ryan, 7 October, the
    seventeenth notes: a leg standing nearly straight can fold either way)."""
    h3, k3, e3 = l["at"]
    h, k, e = (h3[1], h3[2]), (k3[1], k3[2]), (e3[1], e3[2])
    a, b = _ik2(h, k, e, target, l.get("bend", _bend(l["at"])))
    return a, b, -(a + b + pitch)


def _bend(at):
    """Which way a leg's knee folds, from its (hip, knee, end) points at rest: -1 with the knee
    ahead of the line from hip to end (the knee pointing forward), 1 behind it."""
    h3, k3, e3 = at
    h, k, e = (h3[1], h3[2]), (k3[1], k3[2]), (e3[1], e3[2])
    return 1.0 if math.sin(math.atan2(e[1] - k[1], e[0] - k[0]) - math.atan2(k[1] - h[1], k[0] - h[0])) >= 0.0 else -1.0


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


def _planted_over(limbs, base, body):
    """_planted for an act played over a held pose (a form's own acts: the sealed Polar Bear's,
    29 October): `base` the pose's (dy, dz, pitch), `body` the act's keys as offsets from it.
    The legs' keys are what each offset adds to the held pose's own angles (one axis each,
    so they add exactly in the engine), so the feet stay planted from the held pose."""
    held, _ = _planted(limbs, [(0.0,) + tuple(base)])
    full, _ = _planted(limbs, [(t, base[0] + dy, base[1] + dz, base[2] + p) for t, dy, dz, p in body])
    tracks = {jn: [(t, round(v - held[jn][0][1], 3)) for t, v in rows] for jn, rows in full.items()}
    return tracks, [(t, 0.0, dy, dz, 0.0, p, 0.0) for t, dy, dz, p in body]


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
    out wide, the Polar Bear's sumo stance, needs the hip to roll and the ankle with it). A
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
    Polar Bear widening its stance a foot at a time): `legs` maps a leg's name to its (hip,
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


def _plant(limbs, sweep, duty=0.55, lift=8.0, crouch=0.0, dip=1.2, nod=0.0, reach=0.96, n=40, airborne=None, smooth=0.0, stomp=False, carry=(0.12, 0.76)):
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
    at its landing, so a fore foot can dip the nose and a hind one lift it. `carry` is the
    share of the swing the foot's forward travel takes, (start, length): the foot lifts
    straight up until `start` of its swing and sets straight down after start + length, and
    crosses the sweep between, so a wider carry is a slower flick (the Funnel-web, 19
    October: its feet flicked forward). A limb's "coxa" is a joint between the body and its
    hip, turning on the limb's own axle, (joint name, pivot, angle): the angle a function of
    the limb's step phase (0 landing, `duty` lifting off) giving degrees, the coxa's own
    cyclic motion, and the solver plants the foot under it: the limb's rest points are turned
    about the pivot by the angle before each solve, so the hip and knee are relative to the
    coxa, and the foot stays flat under all three (the Funnel-web's row, Ryan's choice of 19
    October: the leg's base swings back through the stance and forward through the swing,
    so the whole leg sweeps as one and nothing in it is a bump). Returns (tracks, body,
    stride) for b.gait with ease "linear" (dense keys, n a cycle)."""
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
        u = min(1.0, max(0.0, (s - carry[0]) / carry[1]))
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

    for l in limbs:
        l["foot"] = lambda p, l=l: foot(l, p)   # where its foot is at a phase, and how far it reaches planted and in the air, for _transition
        l["span"] = (reach, airborne)

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
        rows = {"hip": [], "knee": [], "ankle": [], "coxa": []}
        coxa = l.get("coxa")
        k = int(l.get("cycles", 1))
        for i in range(n + 1):
            p = i / float(n)
            y, z, _down = foot(l, p)
            dz, pitch = pose[i]
            if coxa:
                th = float(coxa[2]((p * k - l["phase"]) % 1.0))
                a, b, c = _limb_angles(dict(l, at=_turned(l["at"], coxa[1], th)), _to_body(y, z, 0.0, dz, pitch), pitch)
                c -= th
                rows["coxa"].append((p, round(th, 3)))
            else:
                a, b, c = _limb_angles(l, _to_body(y, z, 0.0, dz, pitch), pitch)
            rows["hip"].append((p, round(a, 3)))
            rows["knee"].append((p, round(b, 3)))
            rows["ankle"].append((p, round(c, 3)))
        tracks[l["hip"]] = (rows["hip"], 0.0)
        tracks[l["knee"]] = (rows["knee"], 0.0)
        if l.get("ankle"):
            tracks[l["ankle"]] = (rows["ankle"], 0.0)
        if coxa:
            tracks[coxa[0]] = (rows["coxa"], 0.0)
    body = [(i / float(n), 0.0, 0.0, round(dz, 3), 0.0, round(pitch, 3), 0.0) for i, (dz, pitch) in enumerate(pose)]
    return tracks, body, stride


def _turned(at, pivot, degrees):
    """A limb's (hip, knee, end) rest points turned `degrees` about `pivot` on the limb's
    axle (x; positive raises the forward end, the joints' own sense), for a solve under a
    coxa that has turned so far."""
    c, s = math.cos(math.radians(degrees)), math.sin(math.radians(degrees))
    out = []
    for px, py, pz in at:
        dy, dz = py - pivot[1], pz - pivot[2]
        out.append((px, pivot[1] + dy * c - dz * s, pivot[2] + dy * s + dz * c))
    return tuple(out)


def _pivot(limbs, roots, yaw, pose, groups, until, lift=7.0, hz=20.0):
    """Leg tracks and body keys for an act that turns a walker on the spot in quick steps
    (the Funnel-web's skitter, Ryan, 19 and 20 October: a shuffle whose planted feet slid
    was no shuffle). Each leg has a yaw joint at its root ("yaw_" + its name, about up) over
    its planar chain, so its plane can turn: for a planted foot the yaw is solved each frame
    to keep the foot's world position in the leg's plane while the body yaws under it, and
    the planar solver takes the rest, so nothing slides. `yaw` is the body's yaw over the
    act as (t, degrees) keys, `pose` its (t, (dy, dz, pitch)) keys, `groups` the rounds of
    steps as (t0, t1, order): over t0..t1 each foot of `order` steps once in its own slot,
    lifted `lift` and set down where it stands at rest under the body as it will be at t1,
    so a round ends with every leg at rest under the turned body; `until` ends the keys.
    `limbs` maps a leg's name to its limb as _plant takes it, `roots` to its yaw joint's
    pivot. Dense keys, for ease "linear"."""
    def at(keys, t):
        return _lerp_keys(keys, t)
    def pose_at(t):
        ks = sorted(pose)
        if t <= ks[0][0]:
            return ks[0][1]
        for (t0, a), (t1, c) in zip(ks, ks[1:]):
            if t <= t1:
                u = (t - t0) / max(1e-9, t1 - t0)
                return tuple(x + (y - x) * u for x, y in zip(a, c))
        return ks[-1][1]
    def rot(v, deg):
        c, s_ = math.cos(math.radians(deg)), math.sin(math.radians(deg))
        return (v[0] * c - v[1] * s_, v[0] * s_ + v[1] * c)
    # Where each foot stands in the world (horizontal) at a time, and its leg's own
    # placement plan: before its step in a round it stands where the round began, after it
    # where the round ends; between rounds every foot stands at rest under the body.
    steps = {}   # leg -> [(t_lift, t_land, yaw_before, yaw_after)]
    for t0, t1, order in groups:
        dt = (t1 - t0) / len(order)
        for k, leg in enumerate(order):
            a = t0 + k * dt
            steps.setdefault(leg, []).append((a + dt * 0.08, a + dt * 0.92, at(yaw, t0), at(yaw, t1)))
    def world_foot(leg, t):
        """The foot's world (x, y) at t, planted; or (old, new, u) while it is in the air."""
        e = limbs[leg]["at"][2]
        rest = (e[0], e[1])
        stood = 0.0
        for t_lift, t_land, y0, y1 in steps.get(leg, []):
            if t < t_lift:
                break
            if t < t_land:
                return (rot(rest, stood), rot(rest, y1), (t - t_lift) / (t_land - t_lift))
            stood = y1
        return rot(rest, stood)
    def solve(leg, fw, theta, prev):
        """The leg's yaw (degrees) and its planar foot target (y) for a world foot `fw`
        under a body yawed `theta`: the one solution nearest `prev`."""
        r = roots[leg]
        e = limbs[leg]["at"][2]
        ex = e[0] - r[0]
        rw = rot((r[0], r[1]), theta)
        v = (fw[0] - rw[0], fw[1] - rw[1])
        rho = math.hypot(v[0], v[1])
        beta = math.atan2(v[1], v[0])
        g = math.acos(max(-1.0, min(1.0, ex / rho)))
        best = None
        for alpha in (beta - g, beta + g):
            phi = math.degrees(alpha) - theta
            phi = (phi + 180.0) % 360.0 - 180.0
            if best is None or abs(phi - prev) < abs(best[0] - prev):
                y_leg = -v[0] * math.sin(alpha) + v[1] * math.cos(alpha)
                best = (phi, r[1] + y_leg)
        return best
    tracks = {}
    for leg, l in limbs.items():
        for jn in ("yaw_" + leg, l["hip"], l["knee"], l["ankle"]):
            tracks[jn] = []
    body = []
    n = int(round(until * hz))
    prev = {leg: 0.0 for leg in limbs}
    for i in range(n + 1):
        t = round(i / hz, 3)
        theta = at(yaw, t)
        dy, dz, pitch = pose_at(t)
        for leg, l in limbs.items():
            e = l["at"][2]
            fw = world_foot(leg, t)
            if isinstance(fw[0], tuple):
                old, new, u = fw
                p0, p1 = solve(leg, old, theta, prev[leg]), solve(leg, new, theta, prev[leg])
                w = u * u * (3.0 - 2.0 * u)
                phi = p0[0] + (p1[0] - p0[0]) * w
                y = p0[1] + (p1[1] - p0[1]) * w
                z = e[2] + lift * math.sin(math.pi * u)
            else:
                phi, y = solve(leg, fw, theta, prev[leg])
                z = e[2]
            prev[leg] = phi
            a, k, c = _limb_angles(l, _to_body(y, z, dy, dz, pitch), pitch)
            tracks["yaw_" + leg].append((t, round(phi, 3)))
            tracks[l["hip"]].append((t, round(a, 3)))
            tracks[l["knee"]].append((t, round(k, 3)))
            tracks[l["ankle"]].append((t, round(c, 3)))
        body.append((t, 0.0, round(dy, 3), round(dz, 3), round(theta, 3), round(pitch, 3), 0.0))
    return tracks, body



def _leg_fk6(leg, q, body):
    """Where a hip-rooted leg puts its ankle (the model's axes), which way its foot's up faces
    and which way its foot points (Godot's axes): `q` the hip's (pitch, yaw, roll), the knee's
    pitch and the ankle's (pitch, roll), `body` the body's (dx, dy, dz, yaw, pitch, roll); the
    engine's own sums, so a foot planted here stays planted there."""
    h, k, e = (_godot(p) for p in leg)
    rh, rk, ra = _basis(q[0], q[1], q[2]), _basis(q[3], 0.0, 0.0), _basis(q[4], 0.0, q[5])
    rb = _basis(body[4], body[3], body[5])
    ke = _mv(rk, tuple(e[i] - k[i] for i in range(3)))
    he = _mv(rh, tuple(k[i] - h[i] + ke[i] for i in range(3)))
    w = _mv(rb, tuple(h[i] + he[i] for i in range(3)))
    w = (w[0] + body[0], w[1] + body[2], w[2] - body[1])
    r = _mm(_mm(_mm(rb, rh), rk), ra)
    return (w[0], -w[2], w[1]), _mv(r, (0.0, 1.0, 0.0)), _mv(r, (0.0, 0.0, -1.0))


def _leg_newton6(leg, target, heading, body, q0):
    """The six angles (_leg_fk6's q) that put a leg's ankle on `target` (the model's axes)
    with its foot flat and pointing `heading` (degrees about up, positive to the left), under
    a body posed `body`; Newton's method from `q0`."""
    d = (-math.sin(math.radians(heading)), math.cos(math.radians(heading)))
    def res(q):
        p, up, fw = _leg_fk6(leg, q, body)
        fm = (fw[0], -fw[2])
        return [p[0] - target[0], p[1] - target[1], p[2] - target[2], up[0] * 30.0, up[2] * 30.0, (fm[0] * d[1] - fm[1] * d[0]) * 30.0]
    q = list(q0)
    for _ in range(60):
        f = res(q)
        if max(abs(v) for v in f) < 1e-6:
            break
        jac = []
        for j in range(6):
            dq = list(q)
            dq[j] += 1e-4
            f2 = res(dq)
            jac.append([(f2[i] - f[i]) / 1e-4 for i in range(6)])
        m = [[jac[j][i] for j in range(6)] + [-f[i]] for i in range(6)]
        for c in range(6):
            r = max(range(c, 6), key=lambda r: abs(m[r][c]))
            m[c], m[r] = m[r], m[c]
            if abs(m[c][c]) < 1e-12:
                raise ValueError("a leg pose with no solution near the last")
            for r in range(6):
                if r != c:
                    k = m[r][c] / m[c][c]
                    m[r] = [m[r][i] - k * m[c][i] for i in range(7)]
        step = [m[i][6] / m[i][i] for i in range(6)]
        q = [q[i] + max(-10.0, min(10.0, step[i])) for i in range(6)]
    f = res(q)
    if math.hypot(f[0], f[1], f[2]) > 0.05 or max(abs(v) for v in f[3:]) > 0.03:
        raise ValueError("a planted foot out of reach at %s" % (tuple(round(v, 1) for v in target),))
    return q


def _leg_ik6(leg, target, heading, body, q0, fold):
    """_leg_newton6 from `q0`, the knee tried bent each way too and kept on the side it was
    (or on `fold`, the leg's own side, from straight)."""
    want = 1.0 if q0[3] > 1.0 else -1.0 if q0[3] < -1.0 else fold
    first = None
    for seed in (q0, [q0[0], q0[1], q0[2], q0[3] + 20.0 * want, q0[4] - 10.0 * want, q0[5]],
                 [q0[0], q0[1], q0[2], q0[3] - 20.0 * want, q0[4] + 10.0 * want, q0[5]]):
        try:
            q = _leg_newton6(leg, target, heading, body, seed)
        except ValueError:
            continue
        if abs(q[3]) < 1.0 or q[3] * want > 0.0:
            return q
        first = first or q
    if first is None:
        raise ValueError("a planted foot out of reach at %s" % (tuple(round(v, 1) for v in target),))
    return first


def _footwork(limbs, body, steps, until, hz=30.0):
    """Leg tracks and body keys for an act that moves a walker's body about over planted feet
    and steps some of them (Ryan, 20 October: the funnel-web's planted pivot for the rest of
    the walkers; the Polar Bear comes about, the Nemesis paces and braces, the Ammit circles
    its prey), the body free in every axis. `body` is its keys as (t, (dx, dy, dz, yaw,
    pitch, roll)), straight between them; `steps` the steps as (name, t_lift, t_land, where,
    lift), `where` ("under", t) for the foot's rest point under the body as it stands at t,
    ("under", t, (ox, oy)) that point moved (ox, oy) in the body's frame, ("under", "mid")
    the point under the body halfway between this landing and the limb's next lift (or at
    `until`), so a foot is never further from its rest than half the travel between its
    steps, or ("world", x, y) a point on the ground; the foot lands pointing the way the
    body faces there. Every limb is hip-rooted ("hip", "knee", "ankle", "at" as _plant
    takes it): the hip's own pitch, yaw and roll keep its foot where it stands and pointing
    where it landed, the knee and the ankle take the rest and the foot stays flat (the
    engine's own sums, _leg_fk6, so a planted foot stays planted). Dense keys at `hz` a
    second, for ease "linear". Returns joint -> keys and the body keys."""
    def pose_at(t):
        if t <= body[0][0]:
            return body[0][1]
        for (t0, a), (t1, c) in zip(body, body[1:]):
            if t <= t1:
                u = (t - t0) / max(1e-9, t1 - t0)
                return tuple(x + (y - x) * u for x, y in zip(a, c))
        return body[-1][1]
    def rot(v, deg):
        c, s_ = math.cos(math.radians(deg)), math.sin(math.radians(deg))
        return (v[0] * c - v[1] * s_, v[0] * s_ + v[1] * c)
    def under(name, t, off=(0.0, 0.0)):
        e = limbs[name]["at"][2]
        p = pose_at(t)
        x, y = rot((e[0] + off[0], e[1] + off[1]), p[3])
        return (x + p[0], y + p[1]), p[3]
    bylimb = {name: [] for name in limbs}
    for name, t_lift, t_land, where, lift in steps:
        bylimb[name].append((t_lift, t_land, where, lift))
    plan = {}
    for name, ss in bylimb.items():
        ss.sort()
        plan[name] = []
        for i, (t_lift, t_land, where, lift) in enumerate(ss):
            if where[0] == "under":
                at = where[1]
                if at == "mid":
                    at = (t_land + ss[i + 1][0]) / 2.0 if i + 1 < len(ss) else until
                xy, h = under(name, at, where[2] if len(where) > 2 else (0.0, 0.0))
            else:
                xy, h = (where[1], where[2]), pose_at(t_land)[3]
            plan[name].append((t_lift, t_land, xy, h, lift))
    def foot_at(name, t):
        e = limbs[name]["at"][2]
        xy, h = (e[0], e[1]), 0.0
        for t_lift, t_land, xy1, h1, lift in plan[name]:
            if t < t_lift:
                break
            if t < t_land:
                u = (t - t_lift) / (t_land - t_lift)
                w = u * u * (3.0 - 2.0 * u)
                return (xy[0] + (xy1[0] - xy[0]) * w, xy[1] + (xy1[1] - xy[1]) * w), h + (h1 - h) * w, e[2] + lift * math.sin(math.pi * u)
            xy, h = xy1, h1
        return xy, h, e[2]
    tracks = {}
    for l in limbs.values():
        for j in ("hip", "knee", "ankle"):
            tracks[l[j]] = []
    fold = {}
    for name, l in limbs.items():
        e = l["at"][2]
        fold[name] = 1.0 if _limb_angles(l, (e[1], e[2] + 3.0), 0.0)[1] > 0.0 else -1.0
    prev = {name: [0.0] * 6 for name in limbs}
    out = []
    n = int(round(until * hz))
    for i in range(n + 1):
        t = round(i / hz, 3)
        p = pose_at(t)
        for name, l in limbs.items():
            (x, y), h, z = foot_at(name, t)
            q = _leg_ik6(l["at"], (x, y, z), h, p, prev[name], fold[name])
            prev[name] = q
            tracks[l["hip"]].append((t, round(q[0], 3), round(q[1], 3), round(q[2], 3)))
            tracks[l["knee"]].append((t, round(q[3], 3)))
            tracks[l["ankle"]].append((t, round(q[4], 3), 0.0, round(q[5], 3)))
        out.append((t,) + tuple(round(v, 3) for v in p))
    return tracks, out


def _dense(keys, hz=30.0):
    """Sparse keys (t, v...) resampled `hz` a second with a smooth step between each pair,
    for the other tracks of an act keyed linear for its dense planted legs, so they keep the
    smooth ease they would have had."""
    out = []
    t0, t1 = keys[0][0], keys[-1][0]
    n = int(round((t1 - t0) * hz))
    for i in range(n + 1):
        t = round(t0 + i / hz, 3)
        for a, c in zip(keys, keys[1:]):
            if a[0] <= t <= c[0]:
                u = (t - a[0]) / max(1e-9, c[0] - a[0])
                w = u * u * (3.0 - 2.0 * u)
                out.append((t,) + tuple(round(x + (y - x) * w, 3) for x, y in zip(a[1:], c[1:])))
                break
    return out

def _coxa_row(duty, row):
    """A coxa's row for _plant: `row` degrees forward as the foot lands, swung smoothly back
    to `row` degrees behind as it lifts off, and forward again through the swing, each half
    a cosine so the base never snaps (the Funnel-web, 19 October)."""
    def angle(q):
        if q < duty:
            return row * math.cos(math.pi * q / duty)
        return -row * math.cos(math.pi * (q - duty) / (1.0 - duty))
    return angle


def _gallop(limbs, sweep, duty=0.34, lift=16.0, crouch=1.0, hop=3.0, rock=4.0, dip=2.0, reach=0.97, smooth=0.03, n=160, thud=False, airborne=None):
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
    "shift" its stance's centre. `thud` (Ryan, 7 October, the sixteenth notes: a lumbering
    giant) makes each landing a weight coming down: the hull sinks `dip` in a moment as the
    hoof strikes, then recovers slowly through a small damped rebound, where by default it
    eases down and up about the landing; `airborne`, a share of straight as _plant's, lets a
    hoof in the air bound the hull too, so one just off the ground or reaching for it is never
    out of reach as the hull heaves. Returns (tracks, body, stride) for b.gait, ease linear."""
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
        # A limb's "reach" (Ryan, 7 October, the eighteenth notes: no leg passed vertical into
        # the forward plane): late in the swing the hoof is thrown that far past where it lands
        # and drawn back onto it, the leg straightening out ahead of the hip before it plants.
        if l.get("reach", 0.0) > 0.0 and s > 0.5:
            y += l["reach"] * math.sin(math.pi * (s - 0.5) / 0.5)
        return y, z, False

    for l in limbs:
        l["foot"] = lambda p, l=l: foot(l, p)   # where its foot is at a phase, and how far it reaches planted and in the air, for _transition
        l["span"] = (reach, airborne)

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
            if thud:
                x = (p - land) % 1.0
                j = x / 0.025 if x < 0.025 else (math.exp(-(x - 0.025) / 0.07) * math.cos((x - 0.025) * 2.0 * math.pi / 0.22) if x < 0.4 else 0.0)
                want -= dip * 0.5 * j
            else:
                want -= dip * 0.5 * bump(p, land + 0.06, 0.12)
        cap = 1e9
        for l in limbs:
            y, z, down = foot(l, p)
            if not down and airborne is None:
                continue
            h3, k3, e3 = l["at"]
            span = (reach if down else airborne) * (math.hypot(k3[1] - h3[1], k3[2] - h3[2]) + math.hypot(e3[1] - k3[1], e3[2] - k3[2]))
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


def _transition(start, run, steps=1):
    """The stride a machine changes gait in, from the gait it sets off in to the one it runs in,
    worked out foot by foot (Ryan, 7 October, the twenty-second notes: the Clydesdale's trot
    crossfaded into its gallop wherever each leg was, so a hoof's third step came out fast and
    short; about two steps of trot). `start` and `run` are dicts of "limbs", "duty", "stride",
    "tracks" and "body", the limbs as _plant and _gallop took them (each has its "foot" and
    "span" after them) and the tracks and body as they returned. Each leg takes `steps` steps
    in the start gait (a limb's own "steps" over that), a swing it has begun as it sets off
    counting as one while under half done, or under a fifth for a limb whose step must be
    whole ("whole": the Clydesdale's hinds, which push off into the gallop; Ryan, 7 October,
    the twenty-third notes: one trot step, so long as the hinds' is a complete one). It sets
    off at a moment of the start gait's stride when no hoof is further through a swing than
    that, so none drops out of the air as it starts and no whole step comes out a half. Each
    then plants as that gait does and makes one swing of its own into the run, as high as the
    run lifts (its first stride of it): lifting from its stance (a little early,
    or for a hind a little late, where the run reaches further back) and landing where and when
    the run lands it, never sliding while planted. The run's phase, and when each hoof lifts,
    are chosen so no hoof moves faster fore and aft than in either gait's own swing and each is
    in the air between nine tenths of the start gait's time aloft and a tenth over the run's,
    then so the last is down soonest. The hull eases from the one gait's ride to the other's
    from the first lift to the last landing, never higher than the legs reach, and any other
    track (a head) with it. Returns {"from", "to", "length", "tracks", "body"} for b.gait's
    start: the start gait's phase at the set-off, the run's, the units the change takes, and
    its keys over them as a share (dense, linear)."""
    S, R = start, run
    s_stride, r_stride = S["stride"], R["stride"]
    s_air, r_air = (1.0 - S["duty"]) * s_stride, (1.0 - R["duty"]) * r_stride
    s_stance = S["duty"] * s_stride
    by_hip = {l["hip"]: l for l in R["limbs"]}

    def smooth(u):
        u = min(1.0, max(0.0, u))
        return u * u * (3.0 - 2.0 * u)

    def fore_aft(f, lo, hi, h=0.5):
        out, x, p = 0.0, lo, f(lo)[0]
        while x < hi:
            q = f(min(hi, x + h))[0]
            out, p, x = max(out, abs(q - p) / h), q, x + h
        return out

    height = {}
    for l in S["limbs"] + R["limbs"]:
        height[id(l)] = max(l["foot"](i / 200.0)[1] for i in range(200)) - l["at"][2][2]
    normal = {}
    for l in S["limbs"]:
        r = by_hip[l["hip"]]
        normal[l["hip"]] = max(fore_aft(lambda x: l["foot"](x / s_stride), 0.0, s_stride),
                               fore_aft(lambda x: r["foot"](x / r_stride), 0.0, r_stride))

    def swing(l, plan, x):
        """The changing hoof in the air: from where it lifts to where the run lands it, as
        high as the run lifts and reaching as the run's does (the twenty-second notes had
        the two gaits' average, which read as a second step of the start gait)."""
        r = by_hip[l["hip"]]
        s = (x - plan["lift"]) / (plan["land"] - plan["lift"])
        y = plan["from"] + (plan["to"] - plan["from"]) * smooth((s - 0.1) / 0.8)
        if r.get("reach", 0.0) > 0.0 and s > 0.5:
            y += r["reach"] * math.sin(math.pi * (s - 0.5) / 0.5)
        k = 1.0 - (1.0 - s / 0.3) ** 2 if s < 0.3 else (1.0 if s < 0.7 else 1.0 - ((s - 0.7) / 0.3) ** 2)
        return y, l["at"][2][2] + plan["high"] * k, False

    def plan_leg(l, s0, g0):
        r = by_hip[l["hip"]]
        t0 = None
        lift0 = ((l["phase"] + S["duty"] - s0) % 1.0) * s_stride
        n = int(l.get("steps", steps))
        begun = (0.2 if l.get("whole") else 0.5) * s_air      # how far into a swing it may be as it sets off for that to count as a step
        counted = [lift0 + k * s_stride for k in range(-1, n + 3) if lift0 + k * s_stride >= -begun]
        t0 = counted[n]                                      # where its hoof would lift into its next step
        y0 = l["foot"]((s0 + t0 / s_stride) - 1e-6)[0]
        back = r["foot"]((r["phase"] + R["duty"]) % 1.0 - 1e-6)[0]   # the run lifts from here
        best = None
        land0 = ((r["phase"] - g0) % 1.0) * r_stride
        for t1 in (land0 + k * r_stride for k in range(-1, steps + 4)):
            if t1 <= t0 - 0.6 * s_stance + 0.8 * s_air:
                continue
            want = t1 - min(max(t1 - t0, s_air), r_air)
            lift = max(0.0, min(max(want, t0 - 0.6 * s_stance), t0 + max(0.0, y0 - back)))
            plan = {"t0": t0, "y0": y0, "lift": lift, "land": t1, "high": height[id(r)],
                    "from": l["foot"](s0 + lift / s_stride)[0] if lift <= t0 else y0 - (lift - t0),
                    "to": r["foot"](g0 + t1 / r_stride)[0]}
            d = t1 - lift
            fast = fore_aft(lambda x: swing(l, plan, x), lift, t1) / normal[l["hip"]]
            bad = 5.0 * max(0.0, fast - 1.0) + max(0.0, 0.9 * s_air - d) / s_air + max(0.0, d - 1.1 * r_air) / r_air
            key = (round(bad, 2), round(t1, 3))
            if best is None or key < best[0]:
                best = (key, plan)
        return best

    def caught(s0):
        """Whether a hoof is more than halfway through a swing at this moment of the stride, or
        a limb whose step must be whole (its "whole") more than a fifth through one."""
        return any(((s0 - l["phase"]) % 1.0 - S["duty"]) / (1.0 - S["duty"]) > (0.2 if l.get("whole") else 0.5)
                   for l in S["limbs"])

    best = None
    for s0 in [i / 40.0 for i in range(40) if not caught(i / 40.0)]:
        for gi in range(100):
            g0 = gi / 100.0
            plans = {l["hip"]: plan_leg(l, s0, g0) for l in S["limbs"]}
            if any(p is None for p in plans.values()):
                continue
            key = (max(p[0][0] for p in plans.values()), max(p[0][1] for p in plans.values()))
            if best is None or key < best[0]:
                best = (key, s0, g0, {h: p[1] for h, p in plans.items()})
    _key, s0, g0, plans = best
    X = max(p["land"] for p in plans.values())
    first = min(min(p["lift"], p["t0"]) for p in plans.values())

    def cyc(keys, p):
        p %= 1.0
        xs = [k[0] for k in keys]
        i = max(0, min(bisect.bisect_right(xs, p) - 1, len(keys) - 2))
        a, b = keys[i], keys[i + 1]
        u = (p - a[0]) / max(1e-9, b[0] - a[0])
        return [a[j] + (b[j] - a[j]) * u for j in range(1, len(a))]

    def track(tracks, name, p):
        spec = tracks.get(name)
        if spec is None:
            return None
        keys, ph = spec if isinstance(spec, tuple) and len(spec) == 2 and not isinstance(spec[0], (int, float)) else (spec, 0.0)
        return cyc(keys, p + ph)

    legs = {j for l in S["limbs"] for j in (l["hip"], l["knee"], l.get("ankle")) if j}
    others = sorted((set(S["tracks"]) | set(R["tracks"])) - legs)
    n = int(math.ceil(X * 2.0))
    rows = {name: [] for name in sorted(legs) + others}
    body = []
    for i in range(n + 1):
        x = X * i / n
        w = smooth((x - first) / max(1e-6, X - first))
        sb, rb = cyc(S["body"], s0 + x / s_stride), cyc(R["body"], g0 + x / r_stride)
        dz, pitch = (1.0 - w) * sb[2] + w * rb[2], (1.0 - w) * sb[4] + w * rb[4]
        feet = {}
        for l in S["limbs"]:
            p = plans[l["hip"]]
            if x < min(p["t0"], p["lift"]):
                feet[l["hip"]] = l["foot"](s0 + x / s_stride)
            elif x < p["lift"]:
                feet[l["hip"]] = (p["y0"] - (x - p["t0"]), l["at"][2][2], True)   # still planted, going back with the ground
            elif x < p["land"]:
                feet[l["hip"]] = swing(l, p, x)
            else:
                feet[l["hip"]] = by_hip[l["hip"]]["foot"](g0 + x / r_stride)
        if w > 0.0:
            c, sn = math.cos(math.radians(pitch)), math.sin(math.radians(pitch))
            for l in S["limbs"]:
                y, z, down = feet[l["hip"]]
                ks, kr = l["span"][0 if down else 1], by_hip[l["hip"]]["span"][0 if down else 1]
                if ks is None or kr is None:
                    continue
                h3, k3, e3 = l["at"]
                span = ((1.0 - w) * ks + w * kr) * (math.hypot(k3[1] - h3[1], k3[2] - h3[2]) + math.hypot(e3[1] - k3[1], e3[2] - k3[2]))
                hy, hz = h3[1] * c - h3[2] * sn, h3[1] * sn + h3[2] * c
                dz = min(dz, z + math.sqrt(max(0.0, span * span - (hy - y) ** 2)) - hz)
        body.append((round(i / n, 5), 0.0, 0.0, round(dz, 3), 0.0, round(pitch, 3), 0.0))
        for l in S["limbs"]:
            y, z, _down = feet[l["hip"]]
            a, b, c3 = _limb_angles(by_hip[l["hip"]], _to_body(y, z, 0.0, dz, pitch), pitch)
            rows[l["hip"]].append((round(i / n, 5), round(a, 3)))
            rows[l["knee"]].append((round(i / n, 5), round(b, 3)))
            if l.get("ankle"):
                rows[l["ankle"]].append((round(i / n, 5), round(c3, 3)))
        for name in others:
            a, b = track(S["tracks"], name, s0 + x / s_stride), track(R["tracks"], name, g0 + x / r_stride)
            v = [(1.0 - w) * (a[j] if a else 0.0) + w * (b[j] if b else 0.0) for j in range(len(a or b))]
            rows[name].append(tuple([round(i / n, 5)] + [round(u, 3) for u in v]))
    return {"from": s0, "to": g0, "length": X, "tracks": rows, "body": body}


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


def _over_ground(keys, profile, gain=1.0, pitch_cap=40.0, pitch_rate=55.0):
    """A flown path (the circle's or the eight's keys) given a height along its way: `profile`
    is (share of the way, height) control points, a Catmull-Rom spline through them so the
    height and its slope run smooth through every point (eased segments flicked the nose at
    each point: Ryan, 28 October), and the nose follows the slope, `gain` times the true
    angle, smoothed over its neighbours, capped at `pitch_cap` and never turning faster than
    `pitch_rate` degrees a second (an aircraft's nose comes round, it never flicks: Ryan, the
    same day), so a pull-out spreads over the keys before and after it. Keys as the path's."""
    pts = [list(k) for k in keys]
    seg = [0.0]
    for a, b in zip(pts, pts[1:]):
        seg.append(seg[-1] + math.hypot(b[1] - a[1], b[2] - a[2]))
    total = seg[-1] or 1.0
    cp = [(0.0, profile[0][1])] + list(profile) + [(profile[-1][0] + (profile[-1][0] - profile[-2][0]), profile[-1][1])]

    def height(u):
        for i in range(1, len(cp) - 2):
            (u0, h0), (u1, h1) = cp[i], cp[i + 1]
            if u0 <= u <= u1:
                t = (u - u0) / (u1 - u0) if u1 > u0 else 1.0
                hm, hn = cp[i - 1][1], cp[i + 2][1]
                return 0.5 * ((2.0 * h0) + (-hm + h1) * t + (2.0 * hm - 5.0 * h0 + 4.0 * h1 - hn) * t * t + (-hm + 3.0 * h0 - 3.0 * h1 + hn) * t * t * t)
        return profile[-1][1] if u > profile[-1][0] else profile[0][1]

    hs = [height(d / total) for d in seg]
    raw = []
    for i in range(len(pts)):
        lo, hi = max(0, i - 1), min(len(pts) - 1, i + 1)
        ds = seg[hi] - seg[lo]
        raw.append(gain * math.degrees(math.atan2(hs[hi] - hs[lo], ds)) if ds > 1e-6 else 0.0)
    want = []
    for i in range(len(pts)):
        win = raw[max(0, i - 2):i + 3]
        want.append(max(-pitch_cap, min(pitch_cap, sum(win) / len(win))))
    for order in (range(1, len(pts)), range(len(pts) - 2, -1, -1)):   # forward, then back, so the limit leans on neither side
        for i in order:
            j = i - 1 if order.step > 0 else i + 1
            room = pitch_rate * abs(pts[i][0] - pts[j][0])
            want[i] = max(want[j] - room, min(want[j] + room, want[i]))
    out = []
    for i, k in enumerate(pts):
        k[3] = round(hs[i], 3)
        k[5] = round(k[5] + want[i], 3)
        out.append(tuple(k))
    return out


def _time_at(keys, u):
    """The time a flown path reaches the share `u` of its way (by the length between keys)."""
    seg = [0.0]
    for a, b in zip(keys, keys[1:]):
        seg.append(seg[-1] + math.hypot(b[1] - a[1], b[2] - a[2]))
    want = u * seg[-1]
    for i in range(1, len(keys)):
        if seg[i] >= want:
            f = (want - seg[i - 1]) / (seg[i] - seg[i - 1]) if seg[i] > seg[i - 1] else 1.0
            return round(keys[i - 1][0] + (keys[i][0] - keys[i - 1][0]) * f, 3)
    return keys[-1][0]


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
# scale sizes it to its machine (a Kite's pins are half size). Five classes: barrel,
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


# A class's variants (Ryan, 2 November: "maybe some hardpoints want circular missile racks,
# that fixes the armadillo and i'm sure is useful somewhere else"; "Can't we just model different
# shapes as options, as needed?"): the same class in another form, modelled for the mounts its
# standard shape does not fit, named for the form so any hardpoint may take it. A hardpoint
# declares, per class, the variant it wears and the scale it wears it at (b.pin's `fits`); every
# other hardpoint wears the class itself at its own scale. Content never sees a variant: a rack is
# a rack. `forge.py shapes` builds each in every maker's metal beside the classes.

def shape_rack_round(b, s=1.0):
    """A round launcher, for a round port or a pod's nose: a twelve-sided drum on the socket, a
    hazard band round its back, a plate face with seven tubes on it (one in the middle, six round
    it), each one tube of the square rack's missile tile, so the two read as the same launcher."""
    b.prism("y", 0.0, 4.4 * s, 0.0, 6.0 * s, 12.8 * s, "steel.panel", 12, "rack", phase=math.pi / 12)
    b.prism("y", 0.0, -0.25 * s, 0.0, 6.25 * s, 3.5 * s, "steel.stripe", 12, "rack_band", phase=math.pi / 12)
    b.prism("y", 0.0, 11.1 * s, 0.0, 5.7 * s, 0.6 * s, "steel.plate", 12, "rack_face", phase=math.pi / 12)
    for x, z in _ROUND_TUBES:
        _tile_cell(b, (x * s, 11.5 * s, z * s), 1.75 * s, 3.6 * s, "steel.missile", "rack_tube")


# The round launcher's seven tubes across its face: the middle and six round it.
_ROUND_TUBES = [(0.0, 0.0)] + [(3.6 * math.cos(k * math.pi / 3.0), 3.6 * math.sin(k * math.pi / 3.0)) for k in range(6)]


def _tile_cell(b, centre, radius, cell, material, label, sides=12, thick=0.1):
    """A thin disc facing +y at `centre` wearing the middle cell of a three-by-three tile (one
    cell `cell` across), so a round face can carry a square tile's tubes one at a time."""
    c = Vector(centre)
    right, up, fwd = Vector((1.0, 0.0, 0.0)), Vector((0.0, 0.0, 1.0)), Vector((0.0, 1.0, 0.0))
    bm = bmesh.new()
    rings = [[bm.verts.new(c + fwd * dy + right * (radius * math.cos(2.0 * math.pi * i / sides)) + up * (radius * math.sin(2.0 * math.pi * i / sides)))
              for i in range(sides)] for dy in (-thick, 0.0)]
    for i in range(sides):
        j = (i + 1) % sides
        bm.faces.new([rings[0][i], rings[0][j], rings[1][j], rings[1][i]])
    bm.faces.new(rings[0])
    bm.faces.new(list(reversed(rings[1])))
    o = c - right * (1.5 * cell) - up * (1.5 * cell)
    return b._finish(bm, material, label, None, (o, up, right, fwd, (3.0 * cell, 3.0 * cell)))

def shape_barrel_port(b, s=1.0):
    """A gun through a port: the standard gun's barrel and muzzle collar alone, starting at the
    socket, its receiver and sight being inside the hull behind the port's wall (the Kite's
    inset mount; Ryan, 12 November: "the actual mount block is hidden", then "let it poke out
    more")."""
    b.prism("y", 0.0, 11.0 * s, 0.0, 2.8 * s, 22.0 * s, "steel.dark", 6, "barrel")
    b.prism("y", 0.0, 23.0 * s, 0.0, 3.3 * s, 2.0 * s, "steel.plate", 6, "muzzle")


def shape_twin_barrel_port(b, s=1.0):
    """Twin guns through a port, as the port gun is: the two barrels and their muzzle collars
    alone, starting at the socket, the brace between them at the port's wall, their receiver
    inside the hull (Ryan, 12 November, of the standard pair sunk back to hide its receiver:
    "Twin barrel isn't sticking out as far as it was")."""
    for x in (-2.8, 2.8):
        b.prism("y", x * s, 10.0 * s, 0.0, 1.8 * s, 20.0 * s, "steel.dark", 6, "barrel")
        b.prism("y", x * s, 21.0 * s, 0.0, 2.2 * s, 2.0 * s, "steel.plate", 6, "muzzle")
    b.box(-4.0 * s, 4.0 * s, 0.0, 2.0 * s, -1.0 * s, 1.0 * s, "steel.dark", "brace")


def shape_rack_port(b, s=1.0):
    """A launcher through a port: the round launcher longer and thinner (Ryan, 12 November: "If
    you want to make a true 'port' version of the rack, it would look the same, but be a bit
    longer and thinner"), its drum from the socket so its root lies inside the hull behind the
    port's wall, the hazard band a third of the way along where it shows, the same seven tubes
    on its face drawn to its width."""
    w = 0.8 * s   # across, the round launcher's sections at four fifths
    b.prism("y", 0.0, 9.0 * s, 0.0, 6.0 * w, 18.0 * s, "steel.panel", 12, "rack", phase=math.pi / 12)
    b.prism("y", 0.0, 6.0 * s, 0.0, 6.25 * w, 3.0 * s, "steel.stripe", 12, "rack_band", phase=math.pi / 12)
    b.prism("y", 0.0, 18.3 * s, 0.0, 5.7 * w, 0.6 * s, "steel.plate", 12, "rack_face", phase=math.pi / 12)
    for x, z in _ROUND_TUBES:
        _tile_cell(b, (x * w, 18.7 * s, z * w), 1.75 * w, 3.6 * w, "steel.missile", "rack_tube")


def shape_dish_port(b, s=1.0):
    """An emitter through a port: the dish run out on a telescoping mast, a sleeve out of the
    socket and the mast out of the sleeve, so the dish stands clear of a hood over the port's
    mouth with its support in sight (Ryan, 12 November: "The dish will need an extension of
    some kind so it's not just covered"; of a dish set forward off nothing, "Dish also floats
    too far forward from the mount point")."""
    # The dish the port rack's diameter, its drum's 4.8 (Ryan, 12 November: "the dish model needs
    # to be a bit smaller, same diameter as the rack"), the standard dish's sections at that ratio.
    k = 4.8 / 7.0
    b.prism("y", 0.0, 3.0 * s, 0.0, 1.7 * s, 6.0 * s, "steel.plate", 6, "dish_sleeve")
    b.prism("y", 0.0, 9.5 * s, 0.0, 1.2 * s, 9.0 * s, "steel.dark", 6, "dish_mast")
    b.loft([(14.0 * s, _poly(7.0 * k * s, 8, math.pi / 8)), (16.0 * s, _poly(2.5 * k * s, 8, math.pi / 8))], "steel.plate", "dish")
    b.prism("y", 0.0, 16.5 * s, 0.0, 2.0 * k * s, 1.0 * s, "amber.engine", 8, "dish_core")


## Each variant by name: (its class, its builder).
VARIANTS = {"rack_round": ("rack", shape_rack_round), "barrel_port": ("barrel", shape_barrel_port), "twin_barrel_port": ("twin_barrel", shape_twin_barrel_port),
            "rack_port": ("rack", shape_rack_port), "dish_port": ("dish", shape_dish_port)}


def shape_builder(name):
    """A class's builder or a variant's, by name."""
    return SHAPES[name] if name in SHAPES else VARIANTS[name][1]


def shape_class(name):
    """The class a shape is: itself, or a variant's class."""
    return name if name in SHAPES else VARIANTS[name][0]


# A burn weapon's fire (Ryan, 31 October: "every burn-causing weapon", "on the actual swappable
# classes, not on the model ... So its not chassis-specific"; "Fire weapons, like the
# blazethrower, need a red glow, not a white one"): one lit part a class, built where that
# class's business end is, worn over the class on any mount whose component burns (content: its
# entry's keywords hold "burn"), dim at rest and flaring as it fires (MechView3D). `forge.py
# shapes` builds each into art/models/shapes/burn_<shape>.glb; a dish takes none, no burn
# weapon being one.

def burn_barrel(b, s=1.0):
    """A pilot flame in the muzzle's mouth."""
    b.prism("y", 0.0, 30.7 * s, 0.0, 2.4 * s, 1.4 * s, "amber.fire", 6, "burn_flame")


def burn_twin_barrel(b, s=1.0):
    """A pilot flame in each muzzle."""
    for x in (-2.8, 2.8):
        b.prism("y", x * s, 28.6 * s, 0.0, 1.6 * s, 1.2 * s, "amber.fire", 6, "burn_flame")


def burn_rack(b, s=1.0):
    """The shells glowing in their tubes: a lit tip in each of the face's nine."""
    for x in (-4.6, 0.0, 4.6):
        for z in (-4.6, 0.0, 4.6):
            b.prism("y", x * s, 11.3 * s, z * s, 1.3 * s, 0.6 * s, "amber.fire", 6, "burn_shell")


def burn_blade(b, s=1.0):
    """The edge hot: a lit strip down each side of the blade to its point."""
    for side in (-1.0, 1.0):
        b.loft([(1.5 * s, rect(side * 4.55 * s, 0.5 * s, -0.5 * s, 0.5 * s)), (14.0 * s, rect(side * 3.55 * s, 0.5 * s, -0.4 * s, 0.4 * s)),
                (23.5 * s, rect(side * 0.6 * s, 0.4 * s, -0.15 * s, 0.15 * s))], "amber.fire", "burn_edge")


def burn_barrel_port(b, s=1.0):
    """A pilot flame in the port gun's muzzle."""
    b.prism("y", 0.0, 24.7 * s, 0.0, 2.4 * s, 1.4 * s, "amber.fire", 6, "burn_flame")


def burn_twin_barrel_port(b, s=1.0):
    """A pilot flame in each of the port pair's muzzles."""
    for x in (-2.8, 2.8):
        b.prism("y", x * s, 22.6 * s, 0.0, 1.6 * s, 1.2 * s, "amber.fire", 6, "burn_flame")


def burn_rack_port(b, s=1.0):
    """The port rack's shells glowing: a lit tip down each of its seven tubes."""
    w = 0.8 * s
    for x, z in _ROUND_TUBES:
        b.prism("y", x * w, 18.9 * s, z * w, 1.05 * w, 0.5 * s, "amber.fire", 6, "burn_shell")


def burn_rack_round(b, s=1.0):
    """The round launcher's shells glowing: a lit tip down each of its seven tubes."""
    for x, z in _ROUND_TUBES:
        b.prism("y", x * s, 11.7 * s, z * s, 1.05 * s, 0.5 * s, "amber.fire", 6, "burn_shell")


## A class's fire and each variant's whose class burns (a variant of a dish takes none).
BURNS = {"barrel": burn_barrel, "twin_barrel": burn_twin_barrel, "rack": burn_rack, "blade": burn_blade, "rack_round": burn_rack_round, "barrel_port": burn_barrel_port, "twin_barrel_port": burn_twin_barrel_port, "rack_port": burn_rack_port}


# Where each class's muzzle flare blooms as its weapon fires (Ryan, 31 October: "If the flare
# colour of the weapons can follow their tags, that would be really cool"): (point, size) in the
# class's own frame, as the classes above are built, the size the flare's width there. A barrel's
# at its muzzle, a rack's over its tube face, a dish's off its core, a blade's at its point. One
# table for a swapped class and a stock one alike, since both hang on the pin the same way;
# `forge.py shapes` writes it into art/models/shapes/muzzles.json in the models' own frame, and
# the component's tags pick the flare's colour and beat (MuzzleFlare).
MUZZLES = {
    "barrel": [((0.0, 33.0, 0.0), 24.0)],
    "twin_barrel": [((-2.8, 31.0, 0.0), 17.0), ((2.8, 31.0, 0.0), 17.0)],
    "rack": [((0.0, 13.0, 0.0), 30.0)],
    "dish": [((0.0, 10.0, 0.0), 26.0)],
    "blade": [((0.0, 25.0, 0.0), 16.0)],
    "rack_round": [((0.0, 13.2, 0.0), 26.0)],
    "barrel_port": [((0.0, 27.0, 0.0), 24.0)],
    "twin_barrel_port": [((-2.8, 25.0, 0.0), 17.0), ((2.8, 25.0, 0.0), 17.0)],
    "rack_port": [((0.0, 20.4, 0.0), 21.0)],
    "dish_port": [((0.0, 19.0, 0.0), 18.0)],
}


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


# ---------------------------------------------------------------- the field's caches

def _tilt(roll=0.0, pitch=0.0, yaw=0.0, at=(0.0, 0.0, 0.0)):
    """A part's cant: turned about z, then pitched about x and rolled about y, then moved."""
    return (Matrix.Translation(at) @ Matrix.Rotation(math.radians(roll), 4, "Y")
            @ Matrix.Rotation(math.radians(pitch), 4, "X") @ Matrix.Rotation(math.radians(yaw), 4, "Z"))


def cache_derelict(b):
    """A Derelict, the field's commonest cache (content/loot.json): a machine's hulk left where
    it fell, canted and half sunk, a track thrown, its gun drooped, a hatch stood open and one
    lamp still lit. Low and wide: a machine standing on its hex hides it, and it must read from
    above as wreckage, never as a unit. A first cut."""
    b.tile_world = 40.0
    hull = _tilt(roll=-13.0, pitch=7.0, yaw=24.0, at=(-2.0, 1.0, 3.0))
    b.box(-15.0, 15.0, -11.0, 11.0, -3.0, 9.0, "steel.panel", "hull", hull)
    b.loft([(-11.0, rect(0.0, 30.0, 9.0, 9.2)), (-6.0, rect(0.0, 24.0, 9.0, 14.0)), (7.0, rect(0.0, 24.0, 9.0, 14.0)), (11.0, rect(0.0, 30.0, 9.0, 9.2))],
           "steel.plate", "deck", hull)
    b.box(-17.5, -15.0, -12.0, 12.0, -3.0, 6.0, "steel.tread", "track", hull)          # the track it kept, on its low side
    for wy in (-8.0, 0.0, 8.0):
        b.prism("x", 16.5, wy, 1.5, 4.0, 3.0, "steel.dark", 6, "wheel").matrix_world = hull @ b.objects[-1].matrix_world   # the bared road wheels on its high side
    b.box(-6.0, 6.0, -5.0, 5.0, 14.0, 19.0, "steel.panel", "turret", hull)
    b.prism("y", 0.0, 0.0, 0.0, 1.8, 20.0, "steel.dark", 6, "gun").matrix_world = hull @ _tilt(pitch=-24.0, at=(1.0, 13.0, 13.5))   # drooped over the bow
    b.box(-4.0, 4.0, -0.5, 0.5, 0.0, 8.0, "steel.plate", "hatch", hull @ _tilt(pitch=28.0, at=(-1.0, -4.5, 19.0)))   # stood open
    b.box(-3.0, 3.0, -3.5, 3.5, 18.6, 19.2, "bore.dark", "hatchway", hull)
    b.box(8.5, 11.5, -11.6, -11.0, 4.0, 6.5, "amber.light", "lamp", hull)             # the one lamp still lit, at its stern
    b.box(-11.5, -8.5, -11.6, -11.0, 4.0, 6.5, "steel.dark", "lamp_dead", hull)
    # What came off it: the thrown track laid out behind, a plate and a few lumps.
    b.box(-3.0, 3.0, -13.0, 13.0, 0.0, 1.6, "steel.tread", "thrown_track", _tilt(yaw=-38.0, at=(17.0, -12.0, 0.0)))
    b.box(-6.0, 6.0, -4.5, 4.5, 0.0, 1.2, "steel.plate", "plate", _tilt(roll=9.0, yaw=15.0, at=(-17.0, 13.0, 0.6)))
    for x, y, w, yaw in ((14.0, 15.0, 3.6, 20.0), (-20.0, -9.0, 2.8, 50.0), (6.0, -19.0, 2.4, 10.0), (-9.0, 19.0, 2.0, 65.0)):
        b.box(-w, w, -w * 0.8, w * 0.8, 0.0, w * 1.1, "steel.dark", "lump", _tilt(roll=14.0, yaw=yaw, at=(x, y, 0.0)))


cache_derelict.maker = "arsenal"


def _rib(b, y, reach, rise, thick, side, lean, label="rib"):
    """One rib, as a boat's: a crescent standing in the plane across the spine, from the spine out
    and up and curling back in over it, tapering to a point; `side` -1 or 1, leaned along the
    spine by `lean` degrees."""
    outer, inner = [], []
    n = 8
    for i in range(n + 1):
        f = i / n
        a = math.radians(5.0 + 150.0 * f)                 # from the spine, out through the widest, in over the top
        t = thick * (1.0 - 0.8 * f)
        outer.append((side * reach * math.sin(a), rise * 0.5 * (1.0 - math.cos(a))))
        inner.append((side * (reach - t) * math.sin(a), rise * 0.5 - (rise * 0.5 - t) * math.cos(a)))
    pts = outer + inner[::-1]
    if side < 0:
        pts = pts[::-1]
    return b.loft([(-thick * 0.5, pts), (thick * 0.5, pts)], "bone.bone", label, _tilt(pitch=lean, at=(0.0, y, 1.0)))


def cache_carcass(b):
    """A Carcass, the field's middle cache: one of theirs, dead in our ground and picked to the
    bone. A spine along the hex, a cage of ribs open to the sky, a long horned skull at one end
    and a tail of vertebrae at the other, dried hide still on the haunch. Bone is the picture: it
    must not read as a foe standing (they are flat pictures, never geometry). A first cut."""
    b.tile_world = 40.0
    # The spine: vertebrae from the skull's nape to the tail, sagging in the middle.
    for i in range(11):
        y = 15.0 - i * 3.6
        z = 3.2 - 1.4 * math.sin(math.pi * i / 10.0)
        w = 2.6 - 0.14 * i
        b.box(-w, w, -1.5, 1.5, 0.0, 2.6, "bone.bone", "vertebra", _tilt(yaw=4.0 * math.sin(i * 0.9), at=(0.6 * math.sin(i * 0.7), y, z)))
        if 1 <= i <= 8:
            b.box(-0.6, 0.6, -1.0, 1.0, 2.6, 5.4 - 0.25 * i, "bone.bone", "spine_spur", _tilt(pitch=-18.0, at=(0.6 * math.sin(i * 0.7), y, z)))
    # The ribs: five pairs, the largest amidships, each leaned back a little further.
    for k, (y, reach, rise) in enumerate(((11.0, 13.0, 15.0), (6.5, 16.0, 19.0), (2.0, 17.0, 21.0), (-2.5, 15.5, 19.0), (-7.0, 12.5, 15.0))):
        for side in (-1.0, 1.0):
            _rib(b, y, reach, rise, 2.4, side, -8.0 - 3.0 * k)
    # One rib broken off and fallen outside the cage.
    _rib(b, 0.0, 12.0, 14.0, 2.2, 1.0, 0.0, "rib_fallen").matrix_world = _tilt(roll=82.0, yaw=30.0, at=(21.0, -6.0, 1.5))
    # The skull: a long wedge on the ground past the nape, two horns swept back, dark sockets.
    skull = _tilt(pitch=-6.0, yaw=-14.0, at=(1.5, 21.0, 0.0))
    b.loft([(-6.0, rect(0.0, 11.0, 0.5, 10.0)), (1.0, rect(0.0, 10.0, 0.5, 9.0)), (12.0, rect(0.0, 4.5, 0.5, 4.5))], "bone.bone", "skull", skull)
    b.box(-4.2, 4.2, 3.0, 12.4, -0.4, 0.9, "bone.bone", "jaw", skull)
    for side in (-1.0, 1.0):
        b.box(side * 5.0 - 0.8, side * 5.0 + 0.8, -2.0, 2.4, 5.0, 8.6, "bore.dark", "socket", skull)   # a socket in each cheek
        b.box(side * 2.6 - 1.5, side * 2.6 + 1.5, -1.0, 2.6, 9.0, 9.9, "bore.dark", "socket_top", skull)
        b.loft([(0.0, rect(0.0, 3.0, -1.5, 1.5)), (8.0, rect(0.0, 2.0, -1.0, 1.0)), (15.0, rect(0.0, 0.5, -0.25, 0.25))], "bone.bone", "horn",
               skull @ _tilt(pitch=34.0, yaw=side * 150.0, at=(side * 4.2, -4.0, 8.6)))
    # The tail's last bones strewn, and the hide still on the haunch.
    for i, (x, y) in enumerate(((2.5, -25.0), (5.5, -28.0), (9.5, -29.5))):
        b.box(-1.6 + 0.3 * i, 1.6 - 0.3 * i, -1.3, 1.3, 0.0, 2.0 - 0.3 * i, "bone.bone", "tail_bone", _tilt(yaw=40.0 + 25.0 * i, at=(x, y, 0.0)))
    b.loft([(-6.0, rect(0.0, 7.0, 0.0, 0.8)), (0.0, rect(0.0, 12.0, 0.0, 5.0)), (5.0, rect(0.0, 9.0, 0.0, 1.0))], "steel.hide", "hide", _tilt(yaw=12.0, at=(-3.0, -14.0, 1.0)))
    b.box(-9.0, 9.0, -1.0, 1.0, 0.0, 0.6, "steel.hide", "hide_flap", _tilt(yaw=70.0, at=(-13.0, -12.0, 0.0)))
    # Laid across the hex with its skull toward the eye (the map looks from the south, the
    # model's -y), so the skull and the cage both read.
    lie = _tilt(yaw=148.0, at=(-2.0, 2.0, 0.0))
    for ob in b.objects:
        ob.matrix_world = lie @ ob.matrix_world


cache_carcass.maker = "arsenal"


def _shard(b, at, w, d, h, lean, yaw, label="shard", glyph=True):
    """A standing splinter of their stone: four-sided, tapering to an off-centre point, leaned,
    a seam of their light cut up its outward face."""
    m = _tilt(roll=lean, yaw=yaw, at=at)
    b.loft([(-d, [(-w, 0.0), (w, 0.0), (w * 0.72, h * 0.62), (w * 0.1, h), (-w * 0.55, h * 0.7)]),
            (d, [(-w * 0.8, 0.0), (w * 0.8, 0.0), (w * 0.5, h * 0.55), (w * 0.05, h * 0.9), (-w * 0.5, h * 0.6)])], "steel.stone", label, m)
    if glyph:
        b.box(-0.8, 0.8, -d - 0.5, -d + 0.1, h * 0.1, h * 0.42, "amber.rift", "seam_light", m)
        b.box(-0.8, 0.8, -d - 0.5, -d + 0.1, h * 0.48, h * 0.48 + 1.6, "amber.rift", "seam_light", m)   # a stroke and a point over it: no cross


def cache_relic(b):
    """A Relic, the field's rarest cache: a thing of theirs, never ours. Three splinters of black
    stone stood leaning round a hollow, a seam of their light cut in each, and in the hollow a
    core of that light hung clear of the ground, an eight-sided stone the map turns slowly (the
    part named `core`, Map3D). The one cache that glows: it is seen from across the field, which
    is where it lies. A first cut."""
    b.tile_world = 40.0
    b.prism("z", 0.0, 0.0, 0.6, 15.0, 1.2, "steel.stone", 6, "plinth", phase=math.pi / 6.0)
    b.prism("z", 0.0, 0.0, 1.5, 9.0, 0.7, "amber.rift", 6, "well", phase=math.pi / 6.0)
    _shard(b, (-13.0, 4.0, 0.0), 6.0, 3.2, 34.0, 12.0, 28.0)
    _shard(b, (12.0, 7.0, 0.0), 5.0, 2.8, 26.0, -14.0, -30.0)
    _shard(b, (2.0, -14.0, 0.0), 4.4, 2.6, 19.0, 6.0, 176.0)
    _shard(b, (17.0, -9.0, 0.0), 3.0, 2.0, 9.0, -30.0, 70.0, "shard_fallen", glyph=False)
    # The core: two four-sided points base to base, hung over the well.
    r, hh, cz = 5.2, 8.0, 17.0
    ring = [(r, 0.0), (0.0, r), (-r, 0.0), (0.0, -r)]
    tip = [(0.01, 0.0), (0.0, 0.01), (-0.01, 0.0), (0.0, -0.01)]
    # Built about its own centre and stood there by its object's place, so the map turns the
    # part about itself with no rig.
    b.loft([(-hh, tip), (0.0, ring), (hh, tip)], "amber.rift", "core", Matrix.Rotation(-math.pi / 2, 4, "X")).matrix_world = Matrix.Translation((0.0, 0.0, cz))


cache_relic.maker = "arsenal"


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

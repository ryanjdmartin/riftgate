"""Look tests for Minerva's mole (Ryan, 4 November: "Minerva: Some kind of drill-tank mole
machine"; 15 November: "The mole is the least far along, maybe just mock that one up a couple
different ways"; its brief, retired: git show f6f11185:docs/briefs/minerva_mole.md). Three silhouettes meant to differ at a glance, each
a mole machine in Minerva's steel and green, none of them a kit: the drill tank (one great cone for
a nose), the tunnel-borer (a full-face cutter head on a long segmented body) and the digger (two
shovel claws flanking a small snout drill, a mole's forepaws). Mounts are placeholders, three a
machine, set clear of the digging gear. Not content and not in models_low.py: built only by
build_look.py and sheet.py. x right, y forward, z up, the ground at z = 0, as in models_low.py.

Second round, 16 November: the rocket drill. Ryan's kit for it the same day (it burrows in its
reboot's place, and its locked piece, the Inertia Drill, is a rocket drill it fires into a foe,
Indirect, tunnelling to its target, back in the mole as it burrows again), and his word on the
look: "try your first design, but the trick is to make it look like it can fire the drill, but
also not look silly without it." So A's drill tank, shorter and lower, its drill a projectile
seated in a launch bore through the nose: the bore runs down a launch barrel along the hull's
spine, ringed with guide rings, a breech behind it with a loading hatch and blast vents; the
cab sits on the left deck so the barrel has the spine. Loaded, the drill's head stands proud of
the bore's reinforced rim. Fired, the nose is shown two ways: (A) armoured iris petals close
over the empty bore into a pointed prow; (B) the bore stays open, a heavy launch mouth with
guide rails inside and the rocket guide's glow deep in it, so empty it reads as a launcher. The
last row is the drill in flight, nose down out of the open bore, its plume behind it.

Third round, the same day, on his notes ("I think the cockpit needs a little something else,
something that implies it is able to go underground and not be just jammed full of dirt - maybe
a brow or more of a slit or something. All weapons should be able to retract, for burrowing ...
I think the head needs to be wider though ... two rings of drills? The actual tip, that fires,
and then a ring around it that makes the thing wider ... Make vents into real vents, like the
Polar bear"): round two's B with the nose a two-stage drill, the rocket tip in the bore and a
wide ring cutter round it on the nose itself, which stays when the tip fires, so the fired nose
is a drill and a launcher at once; the cab sealed, a raked armoured cupola under a peaked brow
with a slit no wider than a hand and periscopes on its roof, shutters over the slit when it
burrows; every mount in a well it drops into (a gun on a lift in the cab's roof, a rack and a
bare mount on lifts in armoured boxes on the left deck), lids shut over them when it burrows;
and its vents the Polar Bear's own, louvres on joints in housings cut into the breech and the
engine deck, shut when it burrows.

Fourth round, 17 November, on his notes ("The mole looks mean with the double drill, but the
proportions of the combined drill are off, it's a little wonky. And as much as I love the
proportions of the body as it is, we might need to try and make it thinner to fit a bit more
behind the cutter ring. It's almost believable. But it looks pretty badass in this form"): the
two drills one head. The ring and the tip are two lengths of one cone, the ring the frustum from
its root to a sharp lip round the throat and the tip the cap from that lip to the point, one
taper, one wind of facets and one spiral of flutes running on from the ring onto the tip, each
flute sized to the radius under it; a hazard collar on the tip and a crown of teeth on the ring's
lip make the seam, and the crown is what the fired nose shows round its open bore. The ring is
longer and the tip shorter than round three's. The body is narrowed to stand behind the ring head
on: the treads closer in, the hull, the barrel, the breech and the cheeks narrower, the cab, the
mounts' boxes and the vents moved in with them. The first row sets round three's loaded machine
beside round four's at one scale.

Fifth round, the same day, on his notes ("The thin mole still looks great. Maybe the answer to the
cockpit problem is to have it tuck in for digging and move out for unburrowed. Same with the
weapons, so that they clear the drill face. But it's very solid right now."): round four's
machine, its body, drill and vents as they are, with the cab and the two weapon boxes on runs.
Deployed, each rises and runs out over its tread on two hazard-striped rams out of collars in the
hull's side, the cab to the right and the boxes to the left, so head on the cab's slit and every
muzzle stand clear of the ring's circle; each leaves a black bay in a hazard rim on the deck, its
rams across it. Burrowed, each runs back in, a little in and down from round four's place so it
sits wholly behind the ring, its mounts down their wells under shut lids, the slit shuttered and
the periscopes drawn down into the brow. The runs are joints (cab_deploy, sponson_deploy,
fore_box_deploy), which nothing moves yet. The first row sets round four's loaded machine beside
round five's deployed one at one scale."""

import math

from mathutils import Matrix, Vector

from bl_low import boom, rect
from models_low import _beam, _chamfered, _disc, _poly, _rings, _slab, _spike, _sq, _tube, _vent

MN = "minerva"


def _oct(cx, cz, w, h, c):
    """A rectangle with all four corners cut by `c`: a barrel hull's section, (x, z) points."""
    hw, hh = w / 2.0, h / 2.0
    return [(cx - hw + c, cz - hh), (cx + hw - c, cz - hh), (cx + hw, cz - hh + c), (cx + hw, cz + hh - c),
            (cx + hw - c, cz + hh), (cx - hw + c, cz + hh), (cx - hw, cz + hh - c), (cx - hw, cz - hh + c)]


def _ngon(cx, cz, r, n=12, phase=None):
    """A round section of `n` sides as (x, z) points, a flat on top and bottom."""
    phase = math.pi / n if phase is None else phase
    return [(cx + r * math.cos(phase + i * 2.0 * math.pi / n), cz + r * math.sin(phase + i * 2.0 * math.pi / n)) for i in range(n)]


def _drill(b, root, length, r0, n=10, twist=1.3, flutes=2, turns=1.4, steps=12, tip=0.5,
           core="steel.dark", flute="steel.plate", label="drill"):
    """A drill bit along +y from `root`: a cone of `n` sides, each ring turned a little from the
    last so its facets wind, and `flutes` raised ridges wound `turns` times round it. Dark iron
    with its ridges worn bright reads as a screw from every side; the pale cone with dark ridges
    tried first read as a shell from the front."""
    cx, y0, cz = root

    def r(f):
        return r0 * (1.0 - f) + tip * f

    rings = []
    for k in range(steps + 1):
        f = k / float(steps)
        rings.append([(cx + r(f) * math.cos(twist * f + i * 2.0 * math.pi / n), y0 + length * f,
                       cz + r(f) * math.sin(twist * f + i * 2.0 * math.pi / n)) for i in range(n)])
    _rings(b, rings, core, label)
    m = steps * 3
    for j in range(flutes):
        ribbon = []
        for k in range(m + 1):
            f = 0.97 * k / float(m)
            a = turns * 2.0 * math.pi * f + j * 2.0 * math.pi / flutes
            out = Vector((math.cos(a), 0.0, math.sin(a)))
            h = 0.28 * r(f) + 0.5                              # the ridge's height off the cone
            w = (0.05 * (1.0 - 0.55 * f)) * length + 0.3       # half its width along the bit

            def at(dy, lift, f=f, out=out):
                ff = min(1.0, max(0.0, f + dy / length))
                return Vector((cx, y0 + length * f + dy, cz)) + out * (r(ff) + lift)

            ribbon.append([at(-w, -0.6), at(w, -0.6), at(w * 0.35, h), at(-w * 0.35, h)])
        _rings(b, ribbon, flute, label + "_flute")


def _treads(b, tx, tw, th, y0, y1, nose=6.0, skirt="steel.plate", tips=True):
    """A tread unit each side, chamfered both ends, a skirt plate over it with a hazard tip forward."""
    for s in (-1.0, 1.0):
        cx = s * tx
        b.loft([(y0, rect(cx, tw, th * 0.3, th * 0.65)), (y0 + nose, rect(cx, tw, 0.0, th)),
                (y1 - nose, rect(cx, tw, 0.0, th)), (y1, rect(cx, tw, th * 0.3, th * 0.65))], "bore.tread", "tread")
        if skirt:
            b.box(cx - tw / 2.0 - 1.0, cx + tw / 2.0 + 1.0, y0 + nose - 2.0, y1 - nose + 2.0, th - 1.0, th + 2.5, skirt, "skirt")
            if tips:
                b.box(cx - tw / 2.0 - 1.0, cx + tw / 2.0 + 1.0, y1 - nose - 4.0, y1 - nose + 2.0, th + 2.5, th + 4.0, "steel.stripe", "skirt_tip")


def mnlook_mole_a(b):
    """A, the drill tank: the classic. One great cone for a nose, as wide at its root as the
    barrel hull that tapers into it, spiral ridges wound round it, on a low pair of treads; a
    small cab on the back looking over the drill's shoulder, the engine deck behind. Mounts: hp_1
    on the cab's roof, hp_2 and hp_3 on the tread decks aft."""
    TX, TW, TH = 23.0, 18.0, 17.0
    _treads(b, TX, TW, TH, -38.0, 24.0)
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * (TX + TW / 2.0 + 1.0), s * (TX + TW / 2.0 + 3.0)))
        b.box(x0, x1, -26.0, 10.0, 5.0, TH - 2.0, "livery.livery2", "flank_plate")
    # The barrel hull between the treads, tapering to the drill's collar.
    CZ = 24.0
    b.loft([(-36.0, _oct(0.0, CZ - 1.0, 30.0, 26.0, 7.0)), (-28.0, _oct(0.0, CZ, 37.0, 32.0, 9.0)),
            (4.0, _oct(0.0, CZ, 37.0, 32.0, 9.0)), (20.0, _oct(0.0, CZ, 35.0, 33.0, 10.0))], "steel.panel", "hull")
    b.loft([(-20.0, _oct(0.0, CZ, 38.0, 33.0, 9.3)), (-12.0, _oct(0.0, CZ, 38.0, 33.0, 9.3))], "livery.livery", "hull_band")
    # The collar and the drill.
    b.prism("y", 0.0, 22.0, CZ, 20.5, 5.0, "steel.dark", 10, "collar")
    b.prism("y", 0.0, 26.2, CZ, 19.0, 3.6, "steel.stripe", 10, "collar_band")
    with b.joint("drill", (0.0, 28.0, CZ), axis="roll"):
        _drill(b, (0.0, 28.0, CZ), 52.0, 17.5, n=12, steps=14, turns=1.9, flutes=3)
    b.spin("drill", 40.0, 420.0)
    # The cab on the back, a brow over its glass, lamps on the brow.
    b.box(-9.0, 9.0, -20.0, -4.0, 38.0, 46.0, "steel.panel", "cab")
    b.loft([(-4.0, rect(0.0, 15.0, 40.5, 45.0)), (-2.6, rect(0.0, 13.0, 41.0, 44.5))], "glass.glass", "canopy")
    b.box(-10.5, 10.5, -21.0, -1.5, 46.0, 47.8, "steel.plate", "brow")
    for s in (-1.0, 1.0):
        b.box(s * 7.0 - 2.0, s * 7.0 + 2.0, -1.5, -0.5, 45.2, 47.4, "amber.light", "floodlight")
    # The engine deck: vents across the tail, two stacks.
    b.box(-12.0, 12.0, -37.5, -36.0, 14.0, 32.0, "steel.vent", "rear_vents")
    for s in (-1.0, 1.0):
        b.prism("z", s * 9.0, -29.0, 44.0, 2.6, 10.0, "steel.dark", 6, "stack")
    # Mounts: a gun on the cab's roof, firing over the drill; a rack and a bare mount on the tread decks aft.
    b.prism("z", 0.0, -12.0, 48.3, 5.5, 1.0, "steel.dark", 8, "gun_ring")
    b.stock("hp_1", (0.0, -12.0, 52.0), "barrel", scale=0.85, carries="rivet_gun")
    b.stock("hp_2", (-TX, -22.0, TH + 8.5), "rack", scale=0.8, carries="shotfire_rack")
    b.pad("hp_3", (TX, -22.0, TH + 3.5), size=(8.0, 1.0))


mnlook_mole_a.maker = MN


def mnlook_mole_b(b):
    """B, the tunnel-borer: a full-face cutter head, a toothed disc as wide and as tall as the
    shield behind it, on a long round body in two sections with a collar of thrust rams between
    them; four short crawler pods under its flanks, a cab on the second section looking over the
    first, a spoil conveyor up and out of the tail. Mounts: hp_1 on the shield's back, hp_2 and
    hp_3 on shelves at the second section's shoulders."""
    CZ, R = 25.5, 20.0
    # Four crawler pods, two a section.
    for y0, y1 in ((10.0, 40.0), (-42.0, -4.0)):
        for s in (-1.0, 1.0):
            cx = s * 19.0
            b.loft([(y0, rect(cx, 12.0, 4.0, 9.0)), (y0 + 5.0, rect(cx, 12.0, 0.0, 13.0)),
                    (y1 - 5.0, rect(cx, 12.0, 0.0, 13.0)), (y1, rect(cx, 12.0, 4.0, 9.0))], "bore.tread", "tread")
            x0, x1 = sorted((s * 24.0, s * 26.5))
            b.box(x0, x1, y0 + 4.0, y1 - 4.0, 3.0, 14.5, "steel.plate", "pod_plate")
    # The shield, the collar and its rams, the second section and its tail.
    b.loft([(12.0, _ngon(0.0, CZ, R)), (41.0, _ngon(0.0, CZ, R))], "steel.panel", "shield")
    b.loft([(33.0, _ngon(0.0, CZ, R + 0.8)), (39.0, _ngon(0.0, CZ, R + 0.8))], "steel.stripe", "shield_band")
    b.loft([(2.0, _ngon(0.0, CZ, 14.0)), (12.0, _ngon(0.0, CZ, 14.0))], "steel.dark", "collar")
    for k in range(8):
        a = math.pi / 8.0 + k * math.pi / 4.0
        b.prism("y", 17.0 * math.cos(a), 7.0, CZ + 17.0 * math.sin(a), 1.7, 12.0, "steel.plate", 6, "ram")
    b.loft([(-40.0, _ngon(0.0, CZ, R - 1.0)), (2.0, _ngon(0.0, CZ, R - 1.0))], "steel.panel", "body")
    b.loft([(-30.0, _ngon(0.0, CZ, R - 0.4)), (-20.0, _ngon(0.0, CZ, R - 0.4))], "livery.livery", "body_band")
    b.loft([(-48.0, _ngon(0.0, CZ, 12.0)), (-40.0, _ngon(0.0, CZ, R - 1.0))], "steel.plate", "tail")
    b.loft([(-49.0, _ngon(0.0, CZ, 9.0)), (-48.0, _ngon(0.0, CZ, 9.0))], "steel.vent", "tail_vent")
    # The cutter head: a dark disc, hazard spokes with picks on them, a ring of raked teeth
    # round its rim that shows from above, a pilot bit at its centre.
    FACE = 41.0
    with b.joint("cutter", (0.0, FACE, CZ), axis="roll"):
        b.prism("y", 0.0, FACE + 2.5, CZ, R + 2.0, 5.0, "steel.dark", 12, "cutter_head", phase=math.pi / 12.0)
        b.prism("y", 0.0, FACE + 7.0, CZ, 6.5, 4.0, "steel.plate", 8, "cutter_boss")
        _drill(b, (0.0, FACE + 9.0, CZ), 9.0, 4.6, n=8, steps=6, turns=1.0, label="pilot")
        for k in range(6):
            m = Matrix.Translation((0.0, FACE + 5.0, CZ)) @ Matrix.Rotation(k * math.pi / 3.0, 4, "Y")
            b.box(5.5, R + 1.0, 0.0, 2.6, -2.4, 2.4, "steel.stripe", "spoke", m)
            for rr in (9.5, 14.5, 19.0):
                _spike(b, tuple(m @ Vector((rr, 2.4, 0.0))), tuple(m @ Vector((rr, 7.4, 0.0))), 1.7, "steel.plate", "pick")
        for k in range(12):
            m = Matrix.Translation((0.0, FACE + 2.5, CZ)) @ Matrix.Rotation(k * math.pi / 6.0 + math.pi / 12.0, 4, "Y")
            _spike(b, tuple(m @ Vector((R + 0.5, 0.0, 0.0))), tuple(m @ Vector((R + 4.6, 5.5, 0.0))), 2.7, "steel.plate", "tooth")
    b.spin("cutter", 24.0, 200.0)
    # The cab on the second section, looking over the shield.
    b.box(-8.0, 8.0, -14.0, 0.0, CZ + R - 3.0, CZ + R + 6.5, "steel.panel", "cab")
    b.loft([(0.0, rect(0.0, 13.0, CZ + R + 1.0, CZ + R + 5.5)), (1.4, rect(0.0, 11.0, CZ + R + 1.5, CZ + R + 5.0))], "glass.glass", "canopy")
    b.box(-9.5, 9.5, -15.0, 2.2, CZ + R + 6.5, CZ + R + 8.0, "steel.plate", "brow")
    for s in (-1.0, 1.0):
        b.box(s * 6.5 - 1.8, s * 6.5 + 1.8, 2.2, 3.2, CZ + R + 5.8, CZ + R + 7.8, "amber.light", "floodlight")
    # The spoil conveyor: a boom up and back out of the tail, a belt on it, a chute at its end.
    start = (0.0, -34.0, CZ + R - 3.0)
    end, rot = boom(b, start, 34.0, -24.0, 180.0, 10.0, 3.0, 9.0, 3.0, "steel.dark", "conveyor")
    m = Matrix.Translation(Vector(start)) @ rot
    b.box(-3.6, 3.6, 1.0, 33.0, 1.4, 2.2, "bore.tread", "belt", m)
    for s in (-1.0, 1.0):
        b.box(s * 4.6 - 0.5, s * 4.6 + 0.5, 0.0, 34.0, 1.4, 3.6, "steel.stripe", "belt_rail", m)
    b.box(-5.5, 5.5, 32.0, 38.0, -4.0, 3.0, "steel.plate", "chute", m)
    _beam(b, (0.0, -47.0, CZ + 8.0), (end[0], end[1] + 12.0, end[2] - 5.0), _sq(2.4, 2.4), _sq(2.4, 2.4), "steel.dark", "conveyor_strut")
    # Mounts: a gun on the shield's back, stopping short of the cutter head; a rack and a bare
    # mount on shelves at the second section's shoulders.
    b.prism("z", 0.0, 18.0, CZ + R + 1.5, 6.0, 4.0, "steel.dark", 8, "gun_ring")
    b.stock("hp_1", (0.0, 18.0, CZ + R + 6.5), "barrel", scale=0.7, carries="rivet_gun")
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 8.0, s * 21.0))
        b.box(x0, x1, -31.0, -17.0, CZ + 11.0, CZ + 14.5, "steel.plate", "shelf")
    b.stock("hp_2", (-14.5, -26.0, CZ + 20.2), "rack", scale=0.78, carries="shotfire_rack")
    b.pad("hp_3", (14.5, -24.0, CZ + 15.5), size=(8.0, 1.0))


mnlook_mole_b.maker = MN


def _spade(b, wrist, yaw, pitch, s, width=25.0, length=19.0, tines=4, reach=14.0):
    """A mole's forepaw as a shovel claw: a broad spade widening forward from `wrist`, turned
    `yaw` degrees outward and tipped `pitch` degrees down, a hazard rib along its back, a knuckle
    bar at its root, `tines` thick claws off its leading edge."""
    m = Matrix.Translation(Vector(wrist)) @ Matrix.Rotation(math.radians(-yaw * s), 4, "Z") @ Matrix.Rotation(math.radians(-pitch), 4, "X")
    b.loft([(-5.0, rect(0.0, width * 0.62, -2.6, 2.6)), (length * 0.4, rect(0.0, width * 0.95, -2.3, 2.3)),
            (length, rect(0.0, width, -1.7, 1.7))], "steel.plate", "spade", m)
    b.box(-2.2, 2.2, -4.0, length - 2.0, 2.2, 4.2, "steel.stripe", "spade_rib", m)
    b.box(-width / 2.0 - 0.6, width / 2.0 + 0.6, length - 3.5, length, -2.4, 2.4, "steel.dark", "knuckle", m)
    for k in range(tines):
        x = (k - (tines - 1) / 2.0) * (width - 5.6) / (tines - 1)
        _spike(b, tuple(m @ Vector((x, length - 1.0, 0.2))), tuple(m @ Vector((x * 1.1, length + reach, -3.4))), 3.3, "steel.dark", "claw")


def mnlook_mole_c(b):
    """C, the digger: a low wedge of a hull, its hump at the back and its nose on the ground,
    with two shovel claws for forelimbs flanking a small snout drill: broad spade hands with thick
    tines on stub arms, a mole's forepaws. Treads under the rear two thirds, a visor slit across
    the slope, two small lamps close together by the snout, spoil chutes off the tail. Mounts:
    hp_1 on the hump, firing over the nose; hp_2 and hp_3 on sponsons at the hump's flanks."""
    TX, TW, TH = 17.5, 14.0, 14.0
    _treads(b, TX, TW, TH, -40.0, 10.0, nose=5.0, skirt=None)
    # The wedge: highest over the treads' middle, sloping to a low nose.
    b.loft([(-38.0, _chamfered(0.0, 40.0, 7.0, 29.0, 6.0)), (-24.0, _chamfered(0.0, 43.0, 6.0, 37.0, 7.0)),
            (-8.0, _chamfered(0.0, 43.0, 6.0, 35.0, 7.0)), (14.0, _chamfered(0.0, 38.0, 6.0, 24.0, 6.0)),
            (30.0, _chamfered(0.0, 24.0, 7.0, 17.0, 4.0))], "steel.panel", "hull")
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 21.4, s * 23.6))
        b.box(x0, x1, -34.0, -10.0, 15.0, 26.0, "livery.livery2", "flank_plate")
    # The visor across the slope, a brow over it; two small lamps close together by the snout.
    b.loft([(1.0, rect(0.0, 26.0, 30.2, 31.2)), (6.5, rect(0.0, 25.0, 27.6, 30.2))], "glass.glass", "visor")
    b.box(-15.0, 15.0, -3.0, 1.6, 31.6, 34.6, "steel.plate", "brow")
    for s in (-1.0, 1.0):
        b.box(s * 4.6 - 1.5, s * 4.6 + 1.5, 26.0, 28.0, 18.4, 20.4, "amber.light", "eye")
    # The snout: a dark housing and a small drill.
    b.prism("y", 0.0, 32.0, 12.5, 7.0, 6.0, "steel.dark", 8, "snout")
    b.prism("y", 0.0, 35.6, 12.5, 6.2, 1.6, "steel.stripe", 8, "snout_band")
    with b.joint("drill", (0.0, 36.0, 12.5), axis="roll"):
        _drill(b, (0.0, 36.0, 12.5), 17.0, 5.6, n=8, steps=8, turns=1.5)
    b.spin("drill", 60.0, 520.0)
    # The forelimbs: a shoulder housing on each flank, a stub arm reaching out and forward, a
    # wrist drum and the spade hand, turned outward as a mole's are.
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        x0, x1 = sorted((s * 17.0, s * 27.0))
        b.box(x0, x1, 0.0, 16.0, 9.0, 27.0, "steel.panel", "shoulder_block")
        b.prism("x", s * 27.5, 8.0, 19.0, 7.0, 6.0, "steel.dark", 8, "shoulder_hinge")
        sh = (s * 26.0, 10.0, 19.0)
        with b.joint("shoulder_%s" % side, sh, limits=(-10.0, 30.0)):
            wrist, _ = boom(b, sh, 15.0, 5.0, -24.0 * s, 10.0, 10.0, 9.0, 9.0, "livery.livery2", "arm")
            b.prism("x", wrist[0], wrist[1], wrist[2], 6.2, 13.0, "steel.dark", 8, "wrist")
            _spade(b, wrist, 14.0, 23.0, s)
    # The tail: spoil chutes thrown up and out of the hump's corners, vents between them.
    for s in (-1.0, 1.0):
        start = (s * 12.0, -30.0, 30.0)
        end, rot = boom(b, start, 13.0, -34.0, 180.0 - 22.0 * s, 8.0, 6.0, 9.0, 7.0, "steel.plate", "spoil_chute")
        m = Matrix.Translation(Vector(start)) @ rot
        b.box(-3.4, 3.4, 12.6, 13.2, -2.4, 2.4, "bore.dark", "chute_mouth", m)
    b.box(-9.0, 9.0, -39.5, -38.0, 10.0, 26.0, "steel.vent", "rear_vents")
    # Mounts: a gun on the hump, firing over the nose; a bare mount and a rack on sponsons at the hump's flanks.
    b.prism("z", 0.0, -16.0, 36.5, 6.0, 1.4, "steel.dark", 8, "gun_ring")
    b.stock("hp_1", (0.0, -16.0, 40.6), "twin_barrel", scale=0.85, carries="twin_autoguns")
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 10.0, s * 25.5))
        b.box(x0, x1, -40.0, -4.0, TH - 0.5, TH + 2.0, "steel.plate", "tread_deck")
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 15.0, s * 25.0))
        b.box(x0, x1, -27.0, -9.0, 27.0, 30.5, "steel.plate", "sponson")
    b.pad("hp_2", (-20.0, -18.0, 31.5), size=(8.0, 1.0))
    b.stock("hp_3", (20.0, -19.0, 36.2), "rack", scale=0.8, carries="shotfire_rack")


mnlook_mole_c.maker = MN

# ---------------------------------------------------------------- round two: the rocket drill

R2_TX, R2_TW, R2_TH = 24.0, 17.0, 16.0   # the treads: centre across, width, height
R2_CZ = 21.0                             # the launch bore's axis
R2_BORE = 10.6                           # the bore's radius
R2_BARREL = 14.0                         # the launch barrel's
R2_MOUTH = 30.6                          # where the bore opens, the rim's face
R2_RIM = 16.6                            # the reinforced rim's outer radius
R2_N = 12                                # the barrel's sides


def _r2_ring(y, r, cz=R2_CZ, n=R2_N):
    """A ring of `n` points round the bore's axis at `y`, phased as _ngon's sections are."""
    return [(r * math.cos(math.pi / n + i * 2.0 * math.pi / n), y, cz + r * math.sin(math.pi / n + i * 2.0 * math.pi / n)) for i in range(n)]


def _r2_band(b, y0, y1, r_out, r_in, material, label, cz=R2_CZ, n=R2_N):
    """A closed ring of square section round the bore's axis from `y0` to `y1`: a band that
    never caps the bore, so a look down it stays clear."""
    _rings(b, [_r2_ring(y0, r_in, cz, n), _r2_ring(y0, r_out, cz, n), _r2_ring(y1, r_out, cz, n),
               _r2_ring(y1, r_in, cz, n), _r2_ring(y0, r_in, cz, n)], material, label, cap=False)


def _r2_drill_head(b, y_root, cz=R2_CZ, label="drill"):
    """The Inertia Drill's head from `y_root` forward: round one's spiral cone, shorter, sized to
    the bore, and the hazard collar it seats on."""
    _r2_band(b, y_root - 2.6, y_root + 0.4, 10.3, 7.5, "steel.stripe", label + "_collar", cz)
    _drill(b, (0.0, y_root, cz), 24.0, 10.0, n=12, steps=12, turns=1.6, flutes=3, label=label)


def _r2_projectile(b, flame=False):
    """The whole Inertia Drill at the origin, along +y, its head's root at y = 0: the head, the
    rocket body behind it (a green band, four swept fins), four nozzles at its tail and, with
    `flame`, its plume."""
    _r2_drill_head(b, 0.0, cz=0.0)
    b.loft([(-21.0, _ngon(0.0, 0.0, 8.0, 12)), (-2.6, _ngon(0.0, 0.0, 8.6, 12))], "steel.plate", "drill_body")
    b.loft([(-14.0, _ngon(0.0, 0.0, 8.9, 12)), (-8.0, _ngon(0.0, 0.0, 8.9, 12))], "livery.livery", "drill_band")
    for k in range(4):
        a = math.pi / 4.0 + k * math.pi / 2.0
        out = Vector((math.cos(a), 0.0, math.sin(a)))
        side = Vector((0.0, 1.0, 0.0)).cross(out)
        root0, root1 = out * 7.8 + Vector((0.0, -21.0, 0.0)), out * 8.4 + Vector((0.0, -11.0, 0.0))
        tip0, tip1 = out * 13.0 + Vector((0.0, -23.0, 0.0)), out * 12.2 + Vector((0.0, -17.0, 0.0))
        _slab(b, [tuple(root0), tuple(root1), tuple(tip1), tuple(tip0)], tuple(side), 1.2, "steel.dark", "drill_fin")
    for k in range(4):
        a = math.pi / 4.0 + k * math.pi / 2.0
        cx, cz = 3.9 * math.cos(a), 3.9 * math.sin(a)
        b.loft([(-25.0, _ngon(cx, cz, 2.9, 8)), (-21.0, _ngon(cx, cz, 2.2, 8))], "steel.dark", "nozzle")
        b.loft([(-25.4, _ngon(cx, cz, 2.5, 8)), (-25.0, _ngon(cx, cz, 2.5, 8))], "amber.exhaust", "nozzle_mouth")
    if flame:
        b.loft([(-44.0, _ngon(0.0, 0.0, 0.6, 10)), (-31.0, _ngon(0.0, 0.0, 5.5, 10)), (-25.6, _ngon(0.0, 0.0, 7.8, 10))], "amber.glow", "plume")


def _r2_iris(b, depth=8.0, r=12.0):
    """Armoured iris petals closed over the empty bore: six plates from the rim's face to a point,
    a hazard seam between each, so the fired machine wears a whole prow."""
    apex = Vector((0.0, R2_MOUTH + depth, R2_CZ))
    pts = [Vector((r * math.cos(math.pi / 6.0 + i * math.pi / 3.0), R2_MOUTH + 0.1, R2_CZ + r * math.sin(math.pi / 6.0 + i * math.pi / 3.0))) for i in range(6)]
    for i in range(6):
        a, c = pts[i], pts[(i + 1) % 6]
        normal = (c - a).cross(apex - a).normalized()
        _slab(b, [tuple(a), tuple(c), tuple(apex)], tuple(normal), 1.2, "steel.plate", "iris_petal")
        _beam(b, tuple(a), tuple(apex), _sq(1.1, 0.9), _sq(0.7, 0.6), "steel.stripe", "iris_seam")
    b.prism("y", 0.0, R2_MOUTH + depth - 0.6, R2_CZ, 1.6, 2.0, "steel.dark", 6, "iris_hub")


def _mole2_hull(b, nose):
    """Round two's hull: A's drill tank shorter and lower, a drill-launcher. Treads, a lower hull
    between them, a launch barrel down the spine whose front half is the bore, guide rings round
    it, a reinforced rim at its mouth, a breech behind it (a loading hatch, blast vents), the
    engine deck and stacks at the tail, the cab on the left deck. `nose` is "loaded", "shut" or
    "bore": what the bore's mouth shows. Mounts: hp_1 on the cab's roof, hp_2 a rack on the right
    deck aft, hp_3 bare on the left deck forward."""
    TX, TW, TH, CZ = R2_TX, R2_TW, R2_TH, R2_CZ
    _treads(b, TX, TW, TH, -36.0, 24.0)
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * (TX + TW / 2.0 + 1.0), s * (TX + TW / 2.0 + 3.0)))
        b.box(x0, x1, -26.0, 12.0, 5.0, TH - 2.0, "livery.livery2", "flank_plate")
    # The lower hull between the treads, its lamps under the barrel's mouth.
    # (Under the bore it stays below the bore's floor, so a look down the empty bore is clear.)
    b.loft([(-36.0, rect(0.0, 31.0, 6.0, 20.0)), (-14.0, rect(0.0, 31.0, 6.0, 20.0))], "steel.panel", "lower_hull")
    b.loft([(-14.0, rect(0.0, 31.0, 5.0, CZ - R2_BORE - 1.0)), (20.0, rect(0.0, 31.0, 5.0, CZ - R2_BORE - 1.0)),
            (25.0, rect(0.0, 28.0, 6.0, CZ - R2_BORE - 2.0))], "steel.panel", "belly")
    for s in (-1.0, 1.0):
        b.box(s * 17.5 - 2.0, s * 17.5 + 2.0, 22.4, 23.4, TH + 0.5, TH + 2.5, "amber.light", "lamp")
    # The launch barrel: solid behind, the bore in front, open at its mouth.
    b.loft([(-14.0, _ngon(0.0, CZ, R2_BARREL, R2_N)), (4.0, _ngon(0.0, CZ, R2_BARREL, R2_N))], "steel.panel", "barrel")
    _tube(b, (0.0, 4.0, CZ), (0.0, R2_MOUTH - 0.2, CZ), R2_BARREL, R2_BORE, R2_N, "steel.panel", "bore", phase=math.pi / R2_N)
    # Inside the bore: four guide rails, two guide rings, the rocket guide's glow on its floor.
    for k in range(4):
        a = math.pi / 4.0 + k * math.pi / 2.0
        p0 = (9.6 * math.cos(a), 5.0, CZ + 9.6 * math.sin(a))
        p1 = (9.6 * math.cos(a), R2_MOUTH - 0.6, CZ + 9.6 * math.sin(a))
        _beam(b, p0, p1, _sq(1.9, 1.9), _sq(1.9, 1.9), "steel.plate", "guide_rail")
    for y in (11.0, 19.5):
        _r2_band(b, y, y + 1.4, R2_BORE + 0.1, 9.0, "steel.dark", "bore_ring")
    _disc(b, (0.0, 4.9, CZ), (0.0, 1.0, 0.0), 6.6, 10, "amber.glow", "bore_glow")
    # The reinforced rim at the mouth, a hazard band behind it, the guide rings down the barrel.
    _r2_band(b, 24.0, R2_MOUTH, R2_RIM, R2_BORE, "steel.dark", "rim")
    _r2_band(b, 22.0, 24.0, R2_BARREL + 1.3, R2_BARREL - 0.3, "steel.stripe", "rim_band")
    for y in (-11.5, -5.5):
        _r2_band(b, y, y + 2.2, R2_BARREL + 1.0, R2_BARREL - 0.3, "steel.dark", "guide_ring")
    _r2_band(b, -2.5, 1.0, R2_BARREL + 0.4, R2_BARREL - 0.3, "livery.livery", "barrel_band")
    # The cheeks: sloped armour either side of the bore's front half, from the tread decks up to
    # the barrel's shoulders, so the launcher sits in the hull and its top runs out as a ridge.
    for s in (-1.0, 1.0):
        sec = [(s * 8.5, CZ + 11.2), (s * 26.0, TH + 3.0), (s * 26.0, TH + 1.0), (s * 13.5, TH + 1.0)]
        sec = sec if s < 0 else list(reversed(sec))
        b.loft([(1.0, sec), (21.0, sec)], "livery.livery2", "cheek")
        b.loft([(21.0, sec), (22.4, [(x * 0.97, z - 0.4) for x, z in sec])], "steel.stripe", "cheek_edge")
    # The breech: a heavier block behind the barrel, a hazard band at its face, a loading hatch
    # on top, blast vents on its flanks and a blast deflector at its back.
    b.loft([(-27.0, _oct(0.0, CZ + 2.0, 32.0, 30.0, 7.0)), (-14.0, _oct(0.0, CZ + 2.0, 32.0, 30.0, 7.0))], "steel.plate", "breech")
    b.loft([(-15.6, _oct(0.0, CZ + 2.0, 32.8, 30.8, 7.2)), (-14.0, _oct(0.0, CZ + 2.0, 32.8, 30.8, 7.2))], "steel.stripe", "breech_band")
    b.box(-6.0, 6.0, -25.0, -17.0, CZ + 16.8, CZ + 18.2, "steel.panel", "loading_hatch")
    b.prism("x", 0.0, -25.0, CZ + 17.6, 1.0, 13.0, "steel.dark", 6, "hatch_hinge")
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 15.6, s * 16.6))
        b.box(x0, x1, -25.0, -17.0, CZ - 1.0, CZ + 8.0, "steel.vent", "blast_vent")
    b.box(-10.0, 10.0, -28.4, -26.8, CZ + 10.0, CZ + 18.0, "steel.vent", "blast_deflector")
    # The engine deck and its stacks.
    b.loft([(-37.0, rect(0.0, 31.0, 6.0, 28.0)), (-27.0, rect(0.0, 31.0, 6.0, 29.0))], "steel.panel", "engine_deck")
    b.box(-12.0, 12.0, -37.6, -36.0, 12.0, 27.0, "steel.vent", "rear_vents")
    for s in (-1.0, 1.0):
        b.prism("z", s * 10.0, -32.0, 34.0, 2.6, 12.0, "steel.dark", 6, "stack")
    # The cab on the left deck, its slit looking forward past the barrel, a brow and a lamp.
    cx = -TX
    b.box(cx - 7.5, cx + 6.5, -29.0, -11.0, TH + 2.5, TH + 15.5, "steel.panel", "cab")
    b.box(cx - 6.0, cx + 4.0, -11.2, -10.6, TH + 9.5, TH + 12.5, "glass.glass", "vision_slit")
    b.box(cx - 8.0, cx + 7.0, -12.6, -10.4, TH + 15.0, TH + 16.6, "steel.plate", "brow")
    b.box(cx - 1.5, cx + 1.5, -10.6, -9.8, TH + 13.2, TH + 14.8, "amber.light", "floodlight")
    # Stowage on the right deck forward, a tow eye at the nose.
    b.box(TX - 6.0, TX + 7.0, -2.0, 13.0, TH + 2.5, TH + 7.0, "steel.plate", "stowage")
    b.box(TX - 6.2, TX + 7.2, 10.0, 13.2, TH + 7.0, TH + 7.8, "steel.stripe", "stowage_lid")
    # The nose.
    if nose == "shut":
        _r2_iris(b)
    # Mounts: a gun on the cab's roof, firing forward beside the barrel; a rack on the right deck
    # aft; a bare mount on the left deck forward.
    b.prism("z", cx - 0.5, -20.0, TH + 16.1, 5.0, 1.0, "steel.dark", 8, "gun_ring")
    b.stock("hp_1", (cx - 0.5, -20.0, TH + 20.6), "barrel", scale=0.8, carries="rivet_gun")
    b.stock("hp_2", (TX, -22.0, TH + 2.5 + 6.0), "rack", scale=0.8, carries="shotfire_rack")
    b.pad("hp_3", (-TX, 4.0, TH + 3.5), size=(8.0, 1.0))
    b.pivots = True   # tracks: it turns on the spot to aim, as a tank's neutral turn
    b.move(slide=0.2, bank=0.0, accel=1.0, heft=0.3)


def mnlook_mole2_loaded(b):
    """The rocket drill seated: its head proud of the rim, its collar in the mouth, its rocket body
    down the bore."""
    _mole2_hull(b, "loaded")
    b.loft([(6.0, _ngon(0.0, R2_CZ, 8.4, 12)), (R2_MOUTH - 2.4, _ngon(0.0, R2_CZ, 8.4, 12))], "steel.plate", "drill_body")
    with b.joint("drill", (0.0, R2_MOUTH, R2_CZ), axis="roll"):
        _r2_drill_head(b, R2_MOUTH + 0.4)
    b.spin("drill", 40.0, 420.0)


mnlook_mole2_loaded.maker = MN


def mnlook_mole2_shut(b):
    """Fired, (A): the bore shut behind it, iris petals closed into a prow."""
    _mole2_hull(b, "shut")


mnlook_mole2_shut.maker = MN


def mnlook_mole2_bore(b):
    """Fired, (B): the bore open, a heavy launch mouth with its rails and its glow."""
    _mole2_hull(b, "bore")


mnlook_mole2_bore.maker = MN


def mnlook_mole2_flight(b):
    """The drill in flight: (B) with its bore empty, the drill out ahead of it nose down, its
    plume trailing back toward the mouth, about to go under."""
    _mole2_hull(b, "bore")
    start = len(b.objects)
    _r2_projectile(b, flame=True)
    m = Matrix.Translation((0.0, 72.0, 18.0)) @ Matrix.Rotation(math.radians(-16.0), 4, "X")
    for ob in b.objects[start:]:
        ob.matrix_world = m @ ob.matrix_world


mnlook_mole2_flight.maker = MN


# ---------------------------------------------------------------- round three: sealed for the dig

R3_CZ = 23.0                          # the bore's axis, two higher than round two's, for the wider head
R3_MOUTH = 30.6                       # where the tip's collar seats in the bore
R3_ROOT, R3_LIP = 25.0, 36.0          # the ring cutter's root and lip along y
R3_R0, R3_R1 = 21.0, 11.6             # its radius at the root and at the lip
R3_THROAT = 10.9                      # its throat, round the bore's mouth
R3_N = 16                             # its sides
R3_TWIST = 2.0 * math.pi / R3_N       # its facets wind one side from root to lip
R3_CAB_X = 24.0                       # the cab's centre across, on the right deck, the side the codex and skirmish cameras see


def _r3_ring(y, r, phase=0.0, cz=R3_CZ, n=R3_N):
    return [(r * math.cos(phase + math.pi / n + i * 2.0 * math.pi / n), y, cz + r * math.sin(phase + math.pi / n + i * 2.0 * math.pi / n)) for i in range(n)]


def _r3_ring_cutter(b, cz=R3_CZ):
    """The outer drill: a reamer crown round the bore's mouth on the nose itself, a frustum of
    sixteen sides wound one side from root to lip, four raised spiral flutes worn bright, a crown
    of teeth on its shoulder, and a throat that leaves the bore clear. It stays when the tip
    fires, so the fired nose is a drill and a launcher at once."""
    steps = 5
    L = R3_LIP - R3_ROOT
    rad = lambda f: R3_R0 + (R3_R1 - R3_R0) * f
    outer = [_r3_ring(R3_ROOT + L * k / steps, rad(k / steps), R3_TWIST * k / steps, cz) for k in range(steps + 1)]
    rings = outer + [_r3_ring(R3_LIP, R3_THROAT, R3_TWIST, cz), _r3_ring(R3_ROOT, R3_THROAT, 0.0, cz), outer[0]]
    _rings(b, rings, "steel.dark", "ring_cutter", cap=False)
    m = 16
    for j in range(4):
        ribbon = []
        for k in range(m + 1):
            f = 0.05 + 0.9 * k / float(m)
            a = 0.85 * 2.0 * math.pi * f + j * math.pi / 2.0
            out = Vector((math.cos(a), 0.0, math.sin(a)))

            def at(dy, lift, f=f, out=out):
                ff = min(1.0, max(0.0, f + dy / L))
                return Vector((0.0, R3_ROOT + L * f + dy, cz)) + out * (rad(ff) + lift)

            ribbon.append([at(-1.3, -0.6), at(1.3, -0.6), at(0.45, 2.3), at(-0.45, 2.3)])
        _rings(b, ribbon, "steel.plate", "ring_flute")
    # The gauge teeth on its shoulder, raked forward and out, each a bright point.
    for k in range(12):
        a = math.pi / 12.0 + k * 2.0 * math.pi / 12.0
        out = Vector((math.cos(a), 0.0, math.sin(a)))
        base = Vector((0.0, R3_ROOT + 1.6, cz)) + out * (R3_R0 - 1.6)
        tip = Vector((0.0, R3_ROOT + 4.6, cz)) + out * (R3_R0 + 0.9)
        _spike(b, tuple(base), tuple(tip), 1.2, "steel.plate", "ring_tooth")


def _r3_well(b, x, y, z, w, open_, label):
    """A mount's well in a deck at height `z`: a hazard rim round a dark recess, open (the lift
    standing in it) or shut under a flush lid with a seam across it."""
    b.box(x - w / 2.0 - 0.9, x + w / 2.0 + 0.9, y - w / 2.0 - 0.9, y + w / 2.0 + 0.9, z - 0.2, z + 0.45, "steel.stripe", label + "_rim")
    b.box(x - w / 2.0, x + w / 2.0, y - w / 2.0, y + w / 2.0, z - 3.0, z + 0.5, "steel.dark", label + "_well")
    if not open_:
        b.box(x - w / 2.0 + 0.15, x + w / 2.0 - 0.15, y - w / 2.0 + 0.15, y + w / 2.0 - 0.15, z + 0.3, z + 0.75, "steel.plate", label + "_lid")
        b.box(x - 0.25, x + 0.25, y - w / 2.0 + 0.4, y + w / 2.0 - 0.4, z + 0.74, z + 0.85, "steel.dark", label + "_seam")


def _r3_lift(b, x, y, z0, z1, r, label):
    """The lift a stowable mount rides up out of its well on: a dark column, a collar at its top."""
    b.prism("z", x, y, (z0 + z1) / 2.0, r, z1 - z0, "steel.dark", 8, label + "_lift")
    b.prism("z", x, y, z1 - 0.5, r + 1.0, 1.0, "steel.plate", 8, label + "_collar")


def _r3_cab(b, shut):
    """The cab on the right deck, sealed for the dig: an armoured cupola raked at its face, a heavy
    peaked brow overhanging it like a plough's share, flanges either side of its face, a vision
    slit no wider than a hand set to the outboard side (so the drill's ring never hides it head
    on), two periscopes on the brow, a floodlight under it; `shut`, an armoured shutter covers the
    slit and the lamp is dark."""
    cx, z0 = R3_CAB_X, R2_TH + 2.0
    cab = b.loft([(-30.0, rect(cx, 15.0, z0, 32.0)), (-15.0, rect(cx, 15.0, z0, 32.0)), (-10.0, rect(cx, 15.0, z0, 26.5))], "steel.panel", "cab")
    b.loft([(-18.0, rect(cx, 16.2, 31.2, 33.4)), (-13.5, rect(cx, 17.6, 31.8, 35.6)), (-9.2, rect(cx, 17.6, 30.8, 32.8))], "steel.plate", "brow")
    b.box(cx - 8.8, cx + 8.8, -10.2, -9.0, 30.4, 31.5, "steel.stripe", "brow_lip")
    for fx in (cx - 8.1, cx + 7.5):   # flanges either side of the face, under the brow's ends
        b.box(fx, fx + 0.6, -14.0, -9.2, R2_TH + 6.0, 31.2, "steel.plate", "cab_flange")
    # The raked face: z = 32 - 1.1 (y + 15) from y -15 to -10; the slit just under the brow.
    face_n = Vector((0.0, 1.1, 1.0)).normalized()
    on = lambda x, z, lift: tuple(Vector((x, -15.0 + (32.0 - z) / 1.1, z)) + face_n * lift)
    x0, x1 = cx - 2.5, cx + 6.5
    _slab(b, [on(x0 - 1.0, 26.6, 0.12), on(x1 + 1.0, 26.6, 0.12), on(x1 + 1.0, 28.9, 0.12), on(x0 - 1.0, 28.9, 0.12)], tuple(face_n), 0.3, "steel.dark", "slit_frame")
    _slab(b, [on(x0, 26.9, 0.3), on(x1, 26.9, 0.3), on(x1, 28.4, 0.3), on(x0, 28.4, 0.3)], tuple(face_n), 0.4, "glass.glass", "vision_slit")
    if shut:
        _slab(b, [on(x0 - 1.2, 26.55, 0.6), on(x1 + 1.2, 26.55, 0.6), on(x1 + 1.2, 29.0, 0.6), on(x0 - 1.2, 29.0, 0.6)], tuple(face_n), 0.6, "steel.plate", "shutter")
        _slab(b, [on(x0 - 1.2, 28.4, 0.85), on(x1 + 1.2, 28.4, 0.85), on(x1 + 1.2, 29.0, 0.85), on(x0 - 1.2, 29.0, 0.85)], tuple(face_n), 0.3, "steel.stripe", "shutter_edge")
    else:
        b.box(cx - 6.2, cx - 3.4, -10.05, -9.4, 24.2, 25.8, "amber.light", "floodlight")
    # Two periscopes standing on the brow's back, their glass forward over its peak.
    for px in (cx - 5.0, cx + 4.6):
        b.box(px - 1.4, px + 1.4, -17.6, -15.4, 32.6, 36.4, "steel.dark", "periscope")
        b.box(px - 1.0, px + 1.0, -15.5, -15.2, 34.6, 35.9, "glass.glass", "periscope_glass")
    return cab


def _mole3_hull(b, state):
    """Round three's hull: round two's B (the low hull, the launch barrel down the spine, the
    breech), its nose a two-stage drill and its cab sealed, every mount on a lift in a well, its
    vents the Polar Bear's own. `state` is "loaded", "fired", "burrowed" or "flight": "burrowed"
    stows every mount under its lid, shuts the cab's slit and the louvres and seats the tip."""
    TX, TW, TH, CZ = R2_TX, R2_TW, R2_TH, R3_CZ
    out = state != "burrowed"
    rest = 22.0 if out else 0.0
    _treads(b, TX, TW, TH, -36.0, 24.0)
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * (TX + TW / 2.0 + 1.0), s * (TX + TW / 2.0 + 3.0)))
        b.box(x0, x1, -26.0, 12.0, 5.0, TH - 2.0, "livery.livery2", "flank_plate")
        b.box(s * TX - 2.4, s * TX + 2.4, 19.9, 20.7, TH - 0.6, TH + 1.6, "amber.light", "lamp")
    # The lower hull between the treads, below the bore's floor.
    b.loft([(-36.0, rect(0.0, 31.0, 6.0, 20.0)), (-14.0, rect(0.0, 31.0, 6.0, 20.0))], "steel.panel", "lower_hull")
    b.loft([(-14.0, rect(0.0, 31.0, 5.0, CZ - R2_BORE - 1.0)), (21.0, rect(0.0, 31.0, 5.0, CZ - R2_BORE - 1.0)),
            (24.0, rect(0.0, 28.0, 6.0, CZ - R2_BORE - 2.0))], "steel.panel", "belly")
    # The launch barrel: solid behind, the bore in front, running on into the ring's throat.
    b.loft([(-14.0, _ngon(0.0, CZ, R2_BARREL, R2_N)), (4.0, _ngon(0.0, CZ, R2_BARREL, R2_N))], "steel.panel", "barrel")
    _tube(b, (0.0, 4.0, CZ), (0.0, R3_ROOT, CZ), R2_BARREL, R2_BORE, R2_N, "steel.panel", "bore", phase=math.pi / R2_N)
    for k in range(4):
        a = math.pi / 4.0 + k * math.pi / 2.0
        p0 = (9.6 * math.cos(a), 5.0, CZ + 9.6 * math.sin(a))
        p1 = (9.6 * math.cos(a), R3_MOUTH - 0.6, CZ + 9.6 * math.sin(a))
        _beam(b, p0, p1, _sq(1.9, 1.9), _sq(1.9, 1.9), "steel.plate", "guide_rail")
    for y in (11.0, 19.5):
        _r2_band(b, y, y + 1.4, R2_BORE + 0.1, 9.0, "steel.dark", "bore_ring", CZ)
    _disc(b, (0.0, 4.9, CZ), (0.0, 1.0, 0.0), 6.6, 10, "amber.glow", "bore_glow")
    for y in (-11.5, -5.5):
        _r2_band(b, y, y + 2.2, R2_BARREL + 1.0, R2_BARREL - 0.3, "steel.dark", "guide_ring", CZ)
    _r2_band(b, -2.5, 1.0, R2_BARREL + 0.4, R2_BARREL - 0.3, "livery.livery", "barrel_band", CZ)
    # The ring's bearing: a drum round the barrel's mouth that the cutter turns on, a hazard band.
    _r2_band(b, 20.6, R3_ROOT, 18.2, R3_THROAT, "steel.plate", "ring_bearing", CZ, R3_N)
    _r2_band(b, 19.6, 20.6, R2_BARREL + 1.6, R2_BARREL - 0.3, "steel.stripe", "bearing_band", CZ)
    with b.joint("ring", (0.0, R3_ROOT, CZ), axis="roll"):
        _r3_ring_cutter(b, CZ)
    b.spin("ring", -18.0, -150.0)   # slow, against the tip
    # The cheeks either side of the bore's front half, from the tread decks up to its shoulders.
    for s in (-1.0, 1.0):
        sec = [(s * 8.5, CZ + 11.2), (s * 26.0, TH + 3.0), (s * 26.0, TH + 1.0), (s * 13.5, TH + 1.0)]
        sec = sec if s < 0 else list(reversed(sec))
        b.loft([(1.0, sec), (19.2, sec)], "livery.livery2", "cheek")
        b.loft([(19.2, sec), (20.4, [(x * 0.97, z - 0.4) for x, z in sec])], "steel.stripe", "cheek_edge")
    # The breech: its vents the Polar Bear's, three louvres on each upper chamfer and a vent across
    # its back where the blast deflector stood; a loading hatch on top.
    breech = b.loft([(-27.0, _oct(0.0, CZ + 2.0, 32.0, 30.0, 7.0)), (-14.0, _oct(0.0, CZ + 2.0, 32.0, 30.0, 7.0))], "steel.plate", "breech")
    b.loft([(-15.6, _oct(0.0, CZ + 2.0, 32.8, 30.8, 7.2)), (-14.0, _oct(0.0, CZ + 2.0, 32.8, 30.8, 7.2))], "steel.stripe", "breech_band")
    b.box(-6.0, 6.0, -25.0, -17.0, CZ + 16.8, CZ + 18.2, "steel.panel", "loading_hatch")
    b.prism("x", 0.0, -25.0, CZ + 17.6, 1.0, 13.0, "steel.dark", 6, "hatch_hinge")
    for s, t in ((-1.0, "l"), (1.0, "r")):
        _vent(b, [breech], (s * 12.5, -21.0, CZ + 2.0 + 11.5), 0.0, 10.0, 6.0, 3, "louvre_b" + t, rest, 80.0, flank=s, heat="breech_heat_" + t)
    _vent(b, [breech], (0.0, -27.0, CZ + 10.5), 90.0, 12.0, 6.0, 3, "louvre_d", rest, 60.0, heat="breech_back_heat")
    # The engine deck, flat on top: two vents across its tail and one between its stacks.
    deck = b.loft([(-37.0, rect(0.0, 31.0, 6.0, 28.5)), (-27.0, rect(0.0, 31.0, 6.0, 28.5))], "steel.panel", "engine_deck")
    for s, t in ((-1.0, "l"), (1.0, "r")):
        _vent(b, [deck], (s * 7.5, -37.0, 17.5), 90.0, 11.0, 9.0, 4, "louvre_r" + t, rest * 0.5, 60.0, heat="rear_heat_" + t)
    _vent(b, [deck], (0.0, -32.5, 28.5), 0.0, 9.0, 7.0, 3, "louvre_t", rest, 80.0, heat="deck_heat")
    for s in (-1.0, 1.0):
        b.prism("z", s * 10.0, -32.0, 34.0, 2.6, 12.0, "steel.dark", 6, "stack")
    # The cab, and a locker on the right deck ahead of it.
    _r3_cab(b, shut=not out)
    b.box(16.6, 32.0, -8.0, 0.0, TH + 0.5, TH + 5.0, "steel.plate", "locker")
    b.box(16.4, 32.2, -1.0, 0.0, TH + 5.0, TH + 5.6, "steel.stripe", "locker_edge")
    # The left deck: an armoured box aft and one forward, each holding a mount's well.
    b.box(-32.5, -15.6, -34.0, -14.0, TH, 24.0, "steel.panel", "sponson")
    b.box(-31.5, -15.6, -12.0, 0.0, TH, 23.5, "steel.panel", "fore_box")
    # Mounts, every one on a lift in a well: hp_1 a gun in the cab's roof, hp_2 a rack in the
    # left sponson, hp_3 bare in the left fore box. Burrowed, each drops in and its lid shuts.
    cx = R3_CAB_X
    _r3_well(b, cx, -25.0, 32.0, 7.4, out, "gun")
    _r3_well(b, -24.0, -24.0, 24.0, 9.6, out, "rack")
    _r3_well(b, -23.5, -6.0, 23.5, 7.0, out, "pad")
    if out:
        _r3_lift(b, cx, -25.0, 31.0, 35.4, 2.4, "gun")
        b.stock("hp_1", (cx, -25.0, 39.0), "barrel", scale=0.8, carries="rivet_gun")
        _r3_lift(b, -24.0, -24.0, 23.0, 26.6, 2.8, "rack")
        b.stock("hp_2", (-24.0, -24.0, 33.0), "rack", scale=0.8, carries="shotfire_rack")
        _r3_lift(b, -23.5, -6.0, 22.5, 26.2, 2.2, "pad")
        b.pad("hp_3", (-23.5, -6.0, 27.2), size=(7.0, 1.0))
    else:
        b.pin("hp_1", (cx, -25.0, 29.0), carries="rivet_gun", hidden=True)
        b.pin("hp_2", (-24.0, -24.0, 21.0), carries="shotfire_rack", hidden=True)
        b.pin("hp_3", (-23.5, -6.0, 20.5), carries="", hidden=True)
    b.pivots = True   # tracks: it turns on the spot to aim, as a tank's neutral turn
    b.move(slide=0.2, bank=0.0, accel=1.0, heft=0.3)


def _r3_tip(b):
    """The rocket tip seated: its body down the bore, its collar in the mouth, its spiral head
    standing out of the ring's throat."""
    b.loft([(6.0, _ngon(0.0, R3_CZ, 8.4, 12)), (R3_MOUTH - 2.4, _ngon(0.0, R3_CZ, 8.4, 12))], "steel.plate", "drill_body")
    with b.joint("drill", (0.0, R3_MOUTH, R3_CZ), axis="roll"):
        _r2_drill_head(b, R3_MOUTH + 0.4, cz=R3_CZ)
    b.spin("drill", 40.0, 420.0)


def mnlook_mole3_loaded(b):
    """Loaded, its weapons out: the tip in the bore, the ring round it, one wide drill head."""
    _mole3_hull(b, "loaded")
    _r3_tip(b)


mnlook_mole3_loaded.maker = MN


def mnlook_mole3_fired(b):
    """Fired: the tip gone, the ring staying round the open bore, its weapons out."""
    _mole3_hull(b, "fired")


mnlook_mole3_fired.maker = MN


def mnlook_mole3_burrowed(b):
    """Burrowed, everything stowed: the tip seated, every mount down its well under a shut lid,
    the cab's slit shuttered, the louvres shut."""
    _mole3_hull(b, "burrowed")
    _r3_tip(b)


mnlook_mole3_burrowed.maker = MN


def mnlook_mole3_flight(b):
    """The tip in flight out of the ring, nose down, its plume trailing back into the throat."""
    _mole3_hull(b, "flight")
    start = len(b.objects)
    _r2_projectile(b, flame=True)
    m = Matrix.Translation((0.0, 80.0, 20.0)) @ Matrix.Rotation(math.radians(-14.0), 4, "X")
    for ob in b.objects[start:]:
        ob.matrix_world = m @ ob.matrix_world


mnlook_mole3_flight.maker = MN


# ---------------------------------------------------------------- round four: one drill, a body behind it

R4_TX, R4_TW, R4_TH = 18.0, 12.5, 16.0   # the treads: closer in and narrower than round three's 24 and 17
R4_CZ = 23.5                             # the bore's axis, half a unit over round three's, for the ring's clearance
R4_BARREL = 13.0                         # the launch barrel's radius (round three's 14), round the same bore
R4_N = 16                                # the drill's sides, the ring's and the tip's alike
R4_ROOT, R4_R0 = 25.0, 22.0              # the drill's root along y and its radius there, the ring's base
R4_APEX = 55.0                           # its point
R4_SLOPE = (R4_R0 - 0.6) / (R4_APEX - R4_ROOT)   # one taper from the root to the point
R4_THROAT = R2_BORE                      # the ring's throat, the bore's own radius, so the tip passes it
R4_LIP_R = 10.9                          # the ring's lip, a sharp edge round the throat
R4_LIP = R4_ROOT + (R4_R0 - R4_LIP_R) / R4_SLOPE   # where the ring ends and the tip begins, on the one cone
R4_TIP_IN = 0.6                          # the tip's core this far inside the cone's line, clear of the throat
R4_WIND = 0.42                           # the flutes' wind, radians a unit along the drill, ring and tip alike (round three's tip's)
R4_FACET = 0.04                          # the facets' gentler wind, ring and tip alike
R4_CAB_X, R4_CAB_W, R4_CAB_TOP = 17.0, 9.0, 27.5   # the cab's centre across, its width and its roof


def _r4_r(y):
    """The one cone's radius at `y`, from the ring's root to the tip's point."""
    return R4_R0 - R4_SLOPE * (y - R4_ROOT)


def _r4_ring(y, r, cz=R4_CZ, n=R4_N, dy=0.0):
    """A ring of the drill's sides at `y` (moved `dy` along it), its facets wound at the drill's one
    gentle rate, so the ring's facets run on into the tip's."""
    phase = math.pi / n + R4_FACET * (y - R4_ROOT)
    return [(r * math.cos(phase + i * 2.0 * math.pi / n), y + dy, cz + r * math.sin(phase + i * 2.0 * math.pi / n)) for i in range(n)]


def _r4_flutes(b, y0, y1, cz, inset, material, label, count=4, dy=0.0):
    """Raised spiral flutes on the one cone (less `inset`) from `y0` to `y1`, wound at the drill's
    one rate and phased from its root, so the ring's run on into the tip's as one spiral; each one's
    height and width taken from the radius under it, so the tip's are the ring's grown small, and
    eased in and out at its ends, so none stands proud as a hook."""
    L = y1 - y0
    m = max(6, int(L * 1.3))
    for j in range(count):
        ribbon = []
        for k in range(m + 1):
            y = y0 + L * k / float(m)
            a = R4_WIND * (y - R4_ROOT) + j * 2.0 * math.pi / count
            out = Vector((math.cos(a), 0.0, math.sin(a)))
            r = _r4_r(y) - inset
            ease = min(1.0, 0.3 + 0.7 * min(y - y0, y1 - y) / 1.8)
            h = (0.10 * r + 0.45) * ease
            w = 0.05 * r + 0.3

            def at(d, lift, y=y, out=out):
                yy = min(y1, max(y0, y + d))
                return Vector((0.0, yy + dy, cz)) + out * (max(0.3, _r4_r(yy) - inset) + lift)

            ribbon.append([at(-w, -0.6), at(w, -0.6), at(w * 0.35, h), at(-w * 0.35, h)])
        _rings(b, ribbon, material, label)


def _r4_ring_cutter(b, cz=R4_CZ):
    """The ring: the one cone from its root to a sharp lip round the throat, dark iron, its flutes
    worn bright, gauge teeth on its root's shoulder and a crown of teeth on its lip, raked forward
    and standing clear of the throat, so the fired nose is a toothed cutter round an open bore."""
    steps = 6
    L = R4_LIP - R4_ROOT
    outer = [_r4_ring(R4_ROOT + L * k / steps, _r4_r(R4_ROOT + L * k / steps), cz) for k in range(steps + 1)]
    rings = outer + [_r4_ring(R4_LIP, R4_THROAT, cz), _r4_ring(R4_ROOT, R4_THROAT, cz), outer[0]]
    _rings(b, rings, "steel.dark", "ring_cutter", cap=False)
    _r4_flutes(b, R4_ROOT + 3.0, R4_LIP - 0.4, cz, 0.0, "steel.plate", "ring_flute")
    for k in range(12):   # the gauge teeth on the root's shoulder, raked forward and out
        a = math.pi / 12.0 + k * 2.0 * math.pi / 12.0
        out = Vector((math.cos(a), 0.0, math.sin(a)))
        base = Vector((0.0, R4_ROOT + 1.6, cz)) + out * (R4_R0 - 1.9)
        tip = Vector((0.0, R4_ROOT + 4.4, cz)) + out * (R4_R0 + 0.5)
        _spike(b, tuple(base), tuple(tip), 1.2, "steel.plate", "ring_tooth")
    for k in range(10):   # the crown on the lip, raked forward round the throat and clear of it
        a = math.pi / 10.0 + k * 2.0 * math.pi / 10.0
        out = Vector((math.cos(a), 0.0, math.sin(a)))
        base = Vector((0.0, R4_LIP - 2.0, cz)) + out * (_r4_r(R4_LIP - 2.0) - 0.4)
        tip = Vector((0.0, R4_LIP + 2.5, cz)) + out * (R4_THROAT + 0.25)
        _spike(b, tuple(base), tuple(tip), 1.3, "steel.plate", "lip_tooth")


def _r4_tip_head(b, y_root, cz, label="drill"):
    """The rocket tip's head: the one cone's cap from the ring's lip to the point, a hair inside the
    cone's line so it clears the throat, its facets and flutes the ring's run on, and the hazard
    collar it seats on at the seam. Built where it sits loaded and moved to `y_root`."""
    dy = y_root - R4_LIP
    steps = 8
    rings = []
    for k in range(steps + 1):
        y = R4_LIP + (R4_APEX - R4_LIP) * k / steps
        rings.append(_r4_ring(y, max(0.35, _r4_r(y) - R4_TIP_IN), cz, dy=dy))
    _rings(b, rings, "steel.dark", label)
    _r4_flutes(b, R4_LIP + 1.0, R4_APEX - 1.6, cz, R4_TIP_IN, "steel.plate", label + "_flute", dy=dy)
    _r2_band(b, y_root - 2.6, y_root + 0.9, R4_LIP_R - 0.35, 7.5, "steel.stripe", label + "_collar", cz, R4_N)


def _r4_projectile(b, flame=False):
    """The whole Inertia Drill at the origin along +y, its head's root at y = 0: round two's rocket
    (its body, a green band, four swept fins, four nozzles and, with `flame`, its plume) under
    round four's head."""
    _r4_tip_head(b, 0.0, 0.0)
    b.loft([(-21.0, _ngon(0.0, 0.0, 8.0, 12)), (-2.6, _ngon(0.0, 0.0, 8.6, 12))], "steel.plate", "drill_body")
    b.loft([(-14.0, _ngon(0.0, 0.0, 8.9, 12)), (-8.0, _ngon(0.0, 0.0, 8.9, 12))], "livery.livery", "drill_band")
    for k in range(4):
        a = math.pi / 4.0 + k * math.pi / 2.0
        out = Vector((math.cos(a), 0.0, math.sin(a)))
        side = Vector((0.0, 1.0, 0.0)).cross(out)
        root0, root1 = out * 7.8 + Vector((0.0, -21.0, 0.0)), out * 8.4 + Vector((0.0, -11.0, 0.0))
        tip0, tip1 = out * 13.0 + Vector((0.0, -23.0, 0.0)), out * 12.2 + Vector((0.0, -17.0, 0.0))
        _slab(b, [tuple(root0), tuple(root1), tuple(tip1), tuple(tip0)], tuple(side), 1.2, "steel.dark", "drill_fin")
    for k in range(4):
        a = math.pi / 4.0 + k * math.pi / 2.0
        cx, cz = 3.9 * math.cos(a), 3.9 * math.sin(a)
        b.loft([(-25.0, _ngon(cx, cz, 2.9, 8)), (-21.0, _ngon(cx, cz, 2.2, 8))], "steel.dark", "nozzle")
        b.loft([(-25.4, _ngon(cx, cz, 2.5, 8)), (-25.0, _ngon(cx, cz, 2.5, 8))], "amber.exhaust", "nozzle_mouth")
    if flame:
        b.loft([(-44.0, _ngon(0.0, 0.0, 0.6, 10)), (-31.0, _ngon(0.0, 0.0, 5.5, 10)), (-25.6, _ngon(0.0, 0.0, 7.8, 10))], "amber.glow", "plume")


def _r4_cab(b, shut):
    """Round three's sealed cab, narrower and lower so it stands inside the ring head on: a cupola
    raked at its face under a peaked brow, flanges either side of the face, a slit set to its
    outboard side, two periscopes on the brow and a floodlight under it; `shut`, a shutter over
    the slit and the lamp dark."""
    cx, w, z0, top = R4_CAB_X, R4_CAB_W, R4_TH + 1.0, R4_CAB_TOP
    hw = w / 2.0
    cab = b.loft([(-30.0, rect(cx, w, z0, top)), (-15.0, rect(cx, w, z0, top)), (-10.0, rect(cx, w, z0, top - 5.5))], "steel.panel", "cab")
    b.loft([(-18.0, rect(cx, w + 0.6, top - 0.8, top + 1.4)), (-13.5, rect(cx, w + 1.0, top - 0.2, top + 3.0)),
            (-9.2, rect(cx, w + 1.0, top - 1.2, top + 0.6))], "steel.plate", "brow")
    b.box(cx - hw - 0.5, cx + hw + 0.5, -10.2, -9.0, top - 1.6, top - 0.5, "steel.stripe", "brow_lip")
    for fx in (cx - hw - 0.6, cx + hw):   # flanges either side of the face, under the brow's ends
        b.box(fx, fx + 0.6, -14.0, -9.2, z0 + 4.0, top - 0.8, "steel.plate", "cab_flange")
    # The raked face: z = top - 1.1 (y + 15) from y -15 to -10; the slit just under the brow.
    face_n = Vector((0.0, 1.1, 1.0)).normalized()
    on = lambda x, z, lift: tuple(Vector((x, -15.0 + (top - z) / 1.1, z)) + face_n * lift)
    x0, x1 = cx - 1.5, cx + 3.5
    _slab(b, [on(x0 - 0.8, top - 5.4, 0.12), on(x1 + 0.8, top - 5.4, 0.12), on(x1 + 0.8, top - 3.1, 0.12), on(x0 - 0.8, top - 3.1, 0.12)], tuple(face_n), 0.3, "steel.dark", "slit_frame")
    _slab(b, [on(x0, top - 5.1, 0.3), on(x1, top - 5.1, 0.3), on(x1, top - 3.6, 0.3), on(x0, top - 3.6, 0.3)], tuple(face_n), 0.4, "glass.glass", "vision_slit")
    if shut:
        _slab(b, [on(x0 - 1.0, top - 5.45, 0.6), on(x1 + 1.0, top - 5.45, 0.6), on(x1 + 1.0, top - 3.0, 0.6), on(x0 - 1.0, top - 3.0, 0.6)], tuple(face_n), 0.6, "steel.plate", "shutter")
        _slab(b, [on(x0 - 1.0, top - 3.6, 0.85), on(x1 + 1.0, top - 3.6, 0.85), on(x1 + 1.0, top - 3.0, 0.85), on(x0 - 1.0, top - 3.0, 0.85)], tuple(face_n), 0.3, "steel.stripe", "shutter_edge")
    else:
        b.box(cx - 3.8, cx - 1.6, -10.05, -9.4, top - 7.8, top - 6.2, "amber.light", "floodlight")
    for px in (cx - 2.3, cx + 2.1):   # two periscopes on the brow's back, their glass forward over its peak
        b.box(px - 1.2, px + 1.2, -17.6, -15.4, top + 0.6, top + 4.2, "steel.dark", "periscope")
        b.box(px - 0.8, px + 0.8, -15.5, -15.2, top + 2.4, top + 3.7, "glass.glass", "periscope_glass")
    return cab


def _mole4_hull(b, state):
    """Round four's hull: round three's narrowed to stand behind the ring head on, its nose one
    drill. `state` is "loaded", "fired", "burrowed" or "flight", as round three's."""
    _mole4_body(b, state)
    _mole4_upper(b, state)


def _mole4_body(b, state):
    """Round four's hull below its upper works: the treads, the hull, the barrel and the ring, the
    cheeks, the breech and the engine deck with their vents, which round five keeps as they are."""
    TX, TW, TH, CZ = R4_TX, R4_TW, R4_TH, R4_CZ
    out = state != "burrowed"
    rest = 22.0 if out else 0.0
    _treads(b, TX, TW, TH, -36.0, 24.0)
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * (TX + TW / 2.0 + 1.0), s * (TX + TW / 2.0 + 3.0)))
        b.box(x0, x1, -26.0, 12.0, 5.0, TH - 2.0, "livery.livery2", "flank_plate")
        b.box(s * TX - 2.2, s * TX + 2.2, 19.9, 20.7, TH - 0.6, TH + 1.6, "amber.light", "lamp")
    # The lower hull between the treads, below the bore's floor.
    b.loft([(-36.0, rect(0.0, 23.0, 6.0, 20.0)), (-14.0, rect(0.0, 23.0, 6.0, 20.0))], "steel.panel", "lower_hull")
    b.loft([(-14.0, rect(0.0, 23.0, 5.0, CZ - R2_BORE - 1.0)), (21.0, rect(0.0, 23.0, 5.0, CZ - R2_BORE - 1.0)),
            (24.0, rect(0.0, 20.0, 6.0, CZ - R2_BORE - 2.0))], "steel.panel", "belly")
    # The launch barrel, narrower round the same bore, running on into the ring's throat.
    b.loft([(-14.0, _ngon(0.0, CZ, R4_BARREL, R2_N)), (4.0, _ngon(0.0, CZ, R4_BARREL, R2_N))], "steel.panel", "barrel")
    _tube(b, (0.0, 4.0, CZ), (0.0, R4_ROOT, CZ), R4_BARREL, R2_BORE, R2_N, "steel.panel", "bore", phase=math.pi / R2_N)
    for k in range(4):
        a = math.pi / 4.0 + k * math.pi / 2.0
        p0 = (9.6 * math.cos(a), 5.0, CZ + 9.6 * math.sin(a))
        p1 = (9.6 * math.cos(a), R4_LIP - 3.2, CZ + 9.6 * math.sin(a))
        _beam(b, p0, p1, _sq(1.9, 1.9), _sq(1.9, 1.9), "steel.plate", "guide_rail")
    for y in (11.0, 19.5):
        _r2_band(b, y, y + 1.4, R2_BORE + 0.1, 9.0, "steel.dark", "bore_ring", CZ)
    _disc(b, (0.0, 8.0, CZ), (0.0, 1.0, 0.0), 7.6, 10, "amber.glow", "bore_glow")
    for y in (-9.0, -5.6):
        _r2_band(b, y, y + 2.2, R4_BARREL + 1.0, R4_BARREL - 0.3, "steel.dark", "guide_ring", CZ)
    _r2_band(b, -2.4, 1.0, R4_BARREL + 0.4, R4_BARREL - 0.3, "livery.livery", "barrel_band", CZ)
    # The ring's bearing, the drum it turns on, and the ring.
    _r2_band(b, 20.6, R4_ROOT, 19.0, R4_THROAT, "steel.plate", "ring_bearing", CZ, R4_N)
    _r2_band(b, 19.6, 20.6, R4_BARREL + 1.6, R4_BARREL - 0.3, "steel.stripe", "bearing_band", CZ)
    with b.joint("ring", (0.0, R4_ROOT, CZ), axis="roll"):
        _r4_ring_cutter(b, CZ)
    b.spin("ring", -18.0, -150.0)   # slow, against the tip
    # The cheeks, from the barrel's shoulders down to the tread decks, inside the ring head on.
    for s in (-1.0, 1.0):
        sec = [(s * 8.0, CZ + 10.4), (s * 20.5, TH + 3.0), (s * 20.5, TH + 1.0), (s * 12.6, TH + 1.0)]
        sec = sec if s < 0 else list(reversed(sec))
        b.loft([(1.0, sec), (19.2, sec)], "livery.livery2", "cheek")
        b.loft([(19.2, sec), (20.4, [(x * 0.97, z - 0.4) for x, z in sec])], "steel.stripe", "cheek_edge")
    # The breech, narrower and a little lower: its vents the Polar Bear's, three louvres on each
    # upper chamfer and a vent across its back; a loading hatch on top.
    breech = b.loft([(-27.0, _oct(0.0, CZ + 1.0, 28.0, 28.0, 7.0)), (-14.0, _oct(0.0, CZ + 1.0, 28.0, 28.0, 7.0))], "steel.plate", "breech")
    b.loft([(-15.6, _oct(0.0, CZ + 1.0, 28.8, 28.8, 7.2)), (-14.0, _oct(0.0, CZ + 1.0, 28.8, 28.8, 7.2))], "steel.stripe", "breech_band")
    b.box(-5.0, 5.0, -25.0, -17.0, CZ + 14.8, CZ + 16.2, "steel.panel", "loading_hatch")
    b.prism("x", 0.0, -25.0, CZ + 15.6, 1.0, 11.0, "steel.dark", 6, "hatch_hinge")
    for s, t in ((-1.0, "l"), (1.0, "r")):
        _vent(b, [breech], (s * 10.5, -21.0, CZ + 1.0 + 10.5), 0.0, 10.0, 6.0, 3, "louvre_b" + t, rest, 80.0, flank=s, heat="breech_heat_" + t)
    _vent(b, [breech], (0.0, -27.0, CZ + 9.5), 90.0, 11.0, 6.0, 3, "louvre_d", rest, 60.0, heat="breech_back_heat")
    # The engine deck, narrower: two vents across its tail and one between its stacks.
    deck = b.loft([(-37.0, rect(0.0, 25.0, 6.0, 28.5)), (-27.0, rect(0.0, 25.0, 6.0, 28.5))], "steel.panel", "engine_deck")
    for s, t in ((-1.0, "l"), (1.0, "r")):
        _vent(b, [deck], (s * 6.2, -37.0, 17.5), 90.0, 10.0, 9.0, 4, "louvre_r" + t, rest * 0.5, 60.0, heat="rear_heat_" + t)
    _vent(b, [deck], (0.0, -32.5, 28.5), 0.0, 8.0, 6.0, 3, "louvre_t", rest, 80.0, heat="deck_heat")
    for s in (-1.0, 1.0):
        b.prism("z", s * 8.6, -32.0, 34.0, 2.4, 12.0, "steel.dark", 6, "stack")


def _mole4_upper(b, state):
    """Round four's upper works: the cab and its locker on the right deck, the two mount boxes on
    the left, every mount on a lift in a well."""
    TH = R4_TH
    out = state != "burrowed"
    # The cab on the right deck, and a locker ahead of it.
    _r4_cab(b, shut=not out)
    b.box(13.6, 21.6, -8.0, 0.0, TH + 0.5, TH + 5.0, "steel.plate", "locker")
    b.box(13.4, 21.8, -1.0, 0.0, TH + 5.0, TH + 5.6, "steel.stripe", "locker_edge")
    # The left deck: an armoured box aft and one forward, each holding a mount's well.
    b.box(-22.0, -13.0, -34.0, -14.0, TH, 24.0, "steel.panel", "sponson")
    b.box(-21.5, -13.0, -12.0, 0.0, TH, 23.5, "steel.panel", "fore_box")
    # Mounts, every one on a lift in a well: hp_1 a gun in the cab's roof, hp_2 a rack in the left
    # sponson, hp_3 bare in the left fore box. Burrowed, each drops in and its lid shuts.
    cx, top = R4_CAB_X, R4_CAB_TOP
    _r3_well(b, cx, -25.0, top, 5.6, out, "gun")
    _r3_well(b, -17.5, -24.0, 24.0, 6.6, out, "rack")
    _r3_well(b, -17.25, -6.0, 23.5, 6.0, out, "pad")
    if out:
        _r3_lift(b, cx, -25.0, top - 1.0, top + 3.2, 2.0, "gun")
        b.stock("hp_1", (cx, -25.0, top + 6.6), "barrel", scale=0.75, carries="rivet_gun")
        _r3_lift(b, -17.5, -24.0, 23.0, 26.4, 2.4, "rack")
        b.stock("hp_2", (-17.5, -24.0, 32.2), "rack", scale=0.75, carries="shotfire_rack")
        _r3_lift(b, -17.25, -6.0, 22.5, 26.0, 2.0, "pad")
        b.pad("hp_3", (-17.25, -6.0, 27.0), size=(6.0, 1.0))
    else:
        b.pin("hp_1", (cx, -25.0, top - 3.0), carries="rivet_gun", hidden=True)
        b.pin("hp_2", (-17.5, -24.0, 21.0), carries="shotfire_rack", hidden=True)
        b.pin("hp_3", (-17.25, -6.0, 20.5), carries="", hidden=True)
    b.pivots = True   # tracks: it turns on the spot to aim, as a tank's neutral turn
    b.move(slide=0.2, bank=0.0, accel=1.0, heft=0.3)


def _r4_tip(b):
    """The rocket tip seated: its body down the bore and the throat, its collar at the ring's lip,
    its head the cone's cap out of it."""
    b.loft([(6.0, _ngon(0.0, R4_CZ, 8.4, 12)), (R4_LIP - 2.6, _ngon(0.0, R4_CZ, 8.4, 12))], "steel.plate", "drill_body")
    with b.joint("drill", (0.0, R4_LIP, R4_CZ), axis="roll"):
        _r4_tip_head(b, R4_LIP, R4_CZ)
    b.spin("drill", 40.0, 420.0)


def mnlook_mole4_loaded(b):
    """Loaded, its weapons out: the tip in the ring, one cone from the ring's root to the point."""
    _mole4_hull(b, "loaded")
    _r4_tip(b)


mnlook_mole4_loaded.maker = MN


def mnlook_mole4_fired(b):
    """Fired: the tip gone, the ring's crown of teeth round the open, glowing bore."""
    _mole4_hull(b, "fired")


mnlook_mole4_fired.maker = MN


def mnlook_mole4_burrowed(b):
    """Burrowed, everything stowed: the tip seated, every mount down its well under a shut lid,
    the cab's slit shuttered, the louvres shut."""
    _mole4_hull(b, "burrowed")
    _r4_tip(b)


mnlook_mole4_burrowed.maker = MN


def mnlook_mole4_flight(b):
    """The tip in flight out of the ring, nose down, its plume trailing back into the throat."""
    _mole4_hull(b, "flight")
    start = len(b.objects)
    _r4_projectile(b, flame=True)
    m = Matrix.Translation((0.0, 84.0, 17.0)) @ Matrix.Rotation(math.radians(-14.0), 4, "X")
    for ob in b.objects[start:]:
        ob.matrix_world = m @ ob.matrix_world


mnlook_mole4_flight.maker = MN


def mnlook_mole4_compare(b):
    """Round three's loaded machine beside round four's at one scale (the camera is orthographic):
    built into the same file and set off on a diagonal, so head on it stands on the left and from
    the side behind, clear of round four in both. Its cuts are applied here, since only the file's
    own build has its cuts applied at export, and its pins renamed so only round four's count."""
    mnlook_mole4_loaded(b)
    other = type(b)("round_three", b.tiles)
    other.materials = b.materials
    mnlook_mole3_loaded(other)
    other.apply_cuts()
    shift = Matrix.Translation((78.0, -112.0, 0.0))
    for ob in other.objects + other.pins:
        if ob.parent is None:
            ob.matrix_world = shift @ ob.matrix_world
    for e in other.pins:
        if e.name.startswith("hp_"):
            e.name = "round_three_" + e.name


mnlook_mole4_compare.maker = MN


# The fifth round: round four's machine, its cab and weapon boxes on runners.
R5_RUN = 11.0    # how far the cab and the weapon boxes run out across the treads, deployed
R5_LIFT = 5.0    # how far they rise as they run, so each stands clear of its deck on its rams
R5_TUCK = 1.5    # how far each sits in toward the spine and down from round four's place, burrowed
R5_DECK = R4_TH + 2.9   # the bays' floors, just over the tread skirts


def _r5_place(out, s):
    """How far a piece on side `s` (1 the cab's, -1 the boxes') stands from round four's place,
    across and up: run out and up, deployed; tucked in toward the spine and down, burrowed."""
    return (s * R5_RUN, R5_LIFT) if out else (-s * R5_TUCK, -R5_TUCK)


def _r5_shift(b, start, pstart, dx, dz):
    """Move what was built since `start` objects and `pstart` pins along x and z: a piece built
    where round four has it, set where its run puts it."""
    m = Matrix.Translation((dx, 0.0, dz))
    for ob in b.objects[start:] + b.pins[pstart:]:
        if ob.parent is None:
            ob.matrix_world = m @ ob.matrix_world


def _r5_bay(b, x0, x1, y0, y1, label):
    """The bay a running piece sits in: a black floor in a hazard rim, covered while the piece is
    tucked in and left bare when it runs out."""
    b.box(x0 - 0.9, x1 + 0.9, y0 - 0.9, y1 + 0.9, R5_DECK - 0.5, R5_DECK + 0.15, "steel.stripe", label + "_rim")
    b.box(x0, x1, y0, y1, R5_DECK - 0.4, R5_DECK + 0.3, "bore.void", label + "_bay")


def _r5_runner(b, s, y, x_hull, x_out, z_top, label):
    """One ram a piece runs out on (`s` the side): out of a collar in the hull's side at `x_hull`,
    across the bay, to under the piece's outboard edge at `x_out`, its top `z_top`, the piece's
    floor."""
    b.box(*sorted((x_hull - s * 1.5, x_out)), y - 1.1, y + 1.1, z_top - 1.6, z_top, "steel.hazard", label + "_ram")
    b.box(*sorted((x_hull - s * 0.6, x_hull + s * 1.2)), y - 1.8, y + 1.8, z_top - 2.2, z_top + 0.6, "steel.dark", label + "_collar")


def _r5_cab(b, out):
    """The cab and the gun in its roof (hp_1) on their run: built where round four has them and
    run out to the right and up, deployed, so its slit stands clear of the ring head on; burrowed,
    tucked in and down behind the ring, its periscopes drawn down into its brow."""
    TH, cx, top = R4_TH, R4_CAB_X, R4_CAB_TOP
    dx, dz = _r5_place(out, 1.0)
    with b.joint("cab_deploy", (cx + dx, -20.0, TH + 1.0 + dz)):
        start, pstart = len(b.objects), len(b.pins)
        _r4_cab(b, shut=not out)
        if not out:
            for ob in b.objects[start:]:
                if ob.name.startswith("periscope"):
                    ob.matrix_world = Matrix.Translation((0.0, 0.0, -3.2)) @ ob.matrix_world
        _r3_well(b, cx, -25.0, top, 5.6, out, "gun")
        if out:
            _r3_lift(b, cx, -25.0, top - 1.0, top + 3.2, 2.0, "gun")
            b.stock("hp_1", (cx, -25.0, top + 6.6), "barrel", scale=0.75, carries="rivet_gun")
        else:
            b.pin("hp_1", (cx, -25.0, top - 3.0), carries="rivet_gun", hidden=True)
        _r5_shift(b, start, pstart, dx, dz)


def _r5_boxes(b, out):
    """The left deck's two armoured boxes on their runs, the rack (hp_2) in the aft one and the bare
    mount (hp_3) in the fore one: built where round four has them and run out to the left and up,
    deployed, so each muzzle stands clear of the ring head on; burrowed, tucked in and down."""
    TH = R4_TH
    dx, dz = _r5_place(out, -1.0)
    with b.joint("sponson_deploy", (-17.5 + dx, -24.0, TH + dz)):
        start, pstart = len(b.objects), len(b.pins)
        b.box(-22.0, -13.0, -34.0, -14.0, TH, 24.0, "steel.panel", "sponson")
        _r3_well(b, -17.5, -24.0, 24.0, 6.6, out, "rack")
        if out:
            _r3_lift(b, -17.5, -24.0, 23.0, 26.4, 2.4, "rack")
            b.stock("hp_2", (-17.5, -24.0, 32.2), "rack", scale=0.75, carries="shotfire_rack")
        else:
            b.pin("hp_2", (-17.5, -24.0, 21.0), carries="shotfire_rack", hidden=True)
        _r5_shift(b, start, pstart, dx, dz)
    with b.joint("fore_box_deploy", (-17.25 + dx, -6.0, TH + dz)):
        start, pstart = len(b.objects), len(b.pins)
        b.box(-21.5, -13.0, -12.0, 0.0, TH, 23.5, "steel.panel", "fore_box")
        _r3_well(b, -17.25, -6.0, 23.5, 6.0, out, "pad")
        if out:
            _r3_lift(b, -17.25, -6.0, 22.5, 26.0, 2.0, "pad")
            b.pad("hp_3", (-17.25, -6.0, 27.0), size=(6.0, 1.0))
        else:
            b.pin("hp_3", (-17.25, -6.0, 20.5), carries="", hidden=True)
        _r5_shift(b, start, pstart, dx, dz)


def _mole5_hull(b, state):
    """Round five's hull: round four's body as it is, its cab and weapon boxes on runners. Deployed
    (every state but "burrowed"), each runs out over its tread and up, its mounts up out of their
    wells; burrowed, each is tucked in behind the ring, a little in and down from round four's
    place, its lid shut and the slit shuttered, and the rams are drawn into the hull."""
    TH = R4_TH
    out = state != "burrowed"
    _mole4_body(b, state)
    cx, hw, t = R4_CAB_X, R4_CAB_W / 2.0, R5_TUCK
    _r5_bay(b, cx - hw - t, cx + hw - t, -30.0, -10.0, "cab")
    _r5_bay(b, -22.0 + t, -13.0 + t, -34.0, -14.0, "sponson")
    _r5_bay(b, -21.5 + t, -13.0 + t, -12.0, 0.0, "fore_box")
    _r5_cab(b, out)
    _r5_boxes(b, out)
    if out:   # the rams, out of collars in the breech's sides, the engine deck's and the barrel's
        for y, xh in ((-25.0, 14.0), (-13.0, 12.6)):
            _r5_runner(b, 1.0, y, xh, cx + hw + R5_RUN - 1.0, TH + 1.0 + R5_LIFT, "cab")
        for y, xh in ((-30.0, -12.5), (-18.0, -14.0)):
            _r5_runner(b, -1.0, y, xh, -22.0 - R5_RUN + 1.0, TH + R5_LIFT, "sponson")
        for y in (-9.0, -3.0):
            _r5_runner(b, -1.0, y, -12.6, -21.5 - R5_RUN + 1.0, TH + R5_LIFT, "fore_box")
    # The locker ahead of the cab's bay stays where it is.
    b.box(13.6, 21.6, -8.0, 0.0, TH + 0.5, TH + 5.0, "steel.plate", "locker")
    b.box(13.4, 21.8, -1.0, 0.0, TH + 5.0, TH + 5.6, "steel.stripe", "locker_edge")
    b.pivots = True   # tracks: it turns on the spot to aim, as a tank's neutral turn
    b.move(slide=0.2, bank=0.0, accel=1.0, heft=0.3)


def mnlook_mole5_deployed(b):
    """Unburrowed, loaded: the tip in the ring, the cab and the weapon boxes run out and up, every
    mount up out of its well."""
    _mole5_hull(b, "loaded")
    _r4_tip(b)


mnlook_mole5_deployed.maker = MN


def mnlook_mole5_burrowed(b):
    """Burrowed: the tip seated, the cab and the weapon boxes tucked in behind the ring, every mount
    down its well under a shut lid, the slit shuttered, the louvres shut."""
    _mole5_hull(b, "burrowed")
    _r4_tip(b)


mnlook_mole5_burrowed.maker = MN


def mnlook_mole5_fired(b):
    """Fired, deployed: the tip gone, the ring's crown round the open bore, the cab and weapons out."""
    _mole5_hull(b, "fired")


mnlook_mole5_fired.maker = MN


def mnlook_mole5_flight(b):
    """The tip in flight out of the ring, the cab and weapons out."""
    _mole5_hull(b, "flight")
    start = len(b.objects)
    _r4_projectile(b, flame=True)
    m = Matrix.Translation((0.0, 84.0, 17.0)) @ Matrix.Rotation(math.radians(-14.0), 4, "X")
    for ob in b.objects[start:]:
        ob.matrix_world = m @ ob.matrix_world


mnlook_mole5_flight.maker = MN


def mnlook_mole5_compare(b):
    """Round four's loaded machine beside round five's deployed one at one scale: built into the same
    file and set off on a diagonal, so head on it stands on the left and from the skirmish angle
    behind on the right, clear of round five in both; its cuts applied here and its pins renamed,
    as round four's compare does."""
    mnlook_mole5_deployed(b)
    other = type(b)("round_four", b.tiles)
    other.materials = b.materials
    mnlook_mole4_loaded(other)
    other.apply_cuts()
    shift = Matrix.Translation((80.0, 70.0, 0.0))
    for ob in other.objects + other.pins:
        if ob.parent is None:
            ob.matrix_world = shift @ ob.matrix_world
    for e in other.pins:
        if e.name.startswith("hp_"):
            e.name = "round_four_" + e.name


mnlook_mole5_compare.maker = MN

LOOKS = ["mnlook_mole_a", "mnlook_mole_b", "mnlook_mole_c",
         "mnlook_mole2_loaded", "mnlook_mole2_shut", "mnlook_mole2_bore", "mnlook_mole2_flight",
         "mnlook_mole3_loaded", "mnlook_mole3_fired", "mnlook_mole3_burrowed", "mnlook_mole3_flight",
         "mnlook_mole4_loaded", "mnlook_mole4_fired", "mnlook_mole4_burrowed", "mnlook_mole4_flight", "mnlook_mole4_compare",
         "mnlook_mole5_deployed", "mnlook_mole5_burrowed", "mnlook_mole5_fired", "mnlook_mole5_flight", "mnlook_mole5_compare"]

_VIEWS = ["codex", "above", "skirmish", ("from the side", 90.0, 8.0)]
SHEET = {
    "title": "The mole, three ways, 15 November (look tests, not content)",
    "out": "docs/looks/minerva_mole.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_mole_a", "label": "A, the drill tank", "views": _VIEWS},
        {"model": "mnlook_mole_b", "label": "B, the tunnel-borer", "views": _VIEWS},
        {"model": "mnlook_mole_c", "label": "C, the digger", "views": _VIEWS},
    ],
}

_VIEWS2 = ["codex", "above", "skirmish", ("from the side", 90.0, 8.0)]
SHEET2 = {
    "title": "The mole, second round: the rocket drill, 16 November (look tests, not content)",
    "out": "docs/looks/minerva_mole2.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_mole2_loaded", "label": "Loaded", "views": _VIEWS2},
        {"model": "mnlook_mole2_shut", "label": "Fired, the bore shut (A)", "views": _VIEWS2 + ["front"]},
        {"model": "mnlook_mole2_bore", "label": "Fired, the bore a launcher (B)", "views": _VIEWS2 + ["front"]},
        {"model": "mnlook_mole2_flight", "label": "The drill in flight", "views": ["codex", ("from the side", 90.0, 8.0), "above"]},
    ],
}

_VIEWS3 = ["codex", "above", "skirmish", ("from the side", 90.0, 8.0)]
SHEET3 = {
    "title": "The mole, third round: the rocket drill, 16 November (look tests, not content)",
    "out": "docs/looks/minerva_mole3.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_mole3_loaded", "label": "Loaded, weapons out", "views": _VIEWS3 + ["front"]},
        {"model": "mnlook_mole3_fired", "label": "Fired, the ring stays", "views": _VIEWS3 + ["front"]},
        {"model": "mnlook_mole3_burrowed", "label": "Burrowed, everything stowed", "views": _VIEWS3},
        {"model": "mnlook_mole3_flight", "label": "The drill in flight", "views": ["codex", ("from the side", 90.0, 8.0), "above"]},
        {"model": "mnlook_mole3_loaded", "label": "The cab, open", "views": [("head on, close", 0.0, 14.0), ("front three-quarter, close", 28.0, 22.0)], "cell": (480, 400)},
        {"model": "mnlook_mole3_burrowed", "label": "The cab, shut", "views": [("head on, close", 0.0, 14.0), ("front three-quarter, close", 28.0, 22.0)], "cell": (480, 400)},
    ],
}

_VIEWS4 = ["codex", "above", "skirmish", ("from the side", 90.0, 8.0)]
SHEET4 = {
    "title": "The mole, fourth round: the rocket drill, 17 November (look tests, not content)",
    "out": "docs/looks/minerva_mole4.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_mole4_compare", "label": "Loaded, round three (left) and round four", "views": [("head on, level", 0.0, 0.0), ("from the side, level", 90.0, 0.0)], "cell": (780, 250)},
        {"model": "mnlook_mole4_loaded", "label": "Loaded, weapons out", "views": _VIEWS4 + ["front"]},
        {"model": "mnlook_mole4_fired", "label": "Fired, the ring stays", "views": _VIEWS4 + ["front"]},
        {"model": "mnlook_mole4_burrowed", "label": "Burrowed, everything stowed", "views": _VIEWS4},
        {"model": "mnlook_mole4_flight", "label": "The drill in flight", "views": ["codex", ("from the side", 90.0, 8.0), "above"]},
        {"model": "mnlook_mole4_loaded", "label": "The cab, open", "views": [("front three-quarter, close", 28.0, 22.0), ("right bow, low, close", 55.0, 10.0)], "cell": (480, 400)},
        {"model": "mnlook_mole4_burrowed", "label": "The cab, shut", "views": [("front three-quarter, close", 28.0, 22.0), ("right bow, low, close", 55.0, 10.0)], "cell": (480, 400)},
    ],
}

_VIEWS5 = ["codex", "above", "skirmish", ("from the side", 90.0, 8.0), "front"]
SHEET5 = {
    "title": "The mole, fifth round: out to fight, in to dig, 17 November (look tests, not content)",
    "out": "docs/looks/minerva_mole5.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_mole5_compare", "label": "Round four loaded beside round five out", "views": [("head on, level, round four on the left", 0.0, 0.0), ("skirmish angle, round four behind on the right", 155.0, 48.0)], "cell": (780, 330)},
        {"model": "mnlook_mole5_deployed", "label": "Unburrowed, cab and weapons out", "views": _VIEWS5},
        {"model": "mnlook_mole5_burrowed", "label": "Burrowed, all tucked in", "views": _VIEWS5},
        {"model": "mnlook_mole5_fired", "label": "Fired, deployed", "views": ["codex", "front"]},
        {"model": "mnlook_mole5_flight", "label": "The drill in flight", "views": ["codex", ("from the side", 90.0, 8.0), "above"]},
        {"model": "mnlook_mole5_deployed", "label": "The cab, out", "views": [("front three-quarter, close", 28.0, 22.0), ("right bow, low, close", 55.0, 10.0)], "cell": (480, 400)},
        {"model": "mnlook_mole5_burrowed", "label": "The cab, tucked in", "views": [("front three-quarter, close", 28.0, 22.0), ("right bow, low, close", 55.0, 10.0)], "cell": (480, 400)},
    ],
}

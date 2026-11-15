"""Look tests for Minerva's mole (Ryan, 4 November: "Minerva: Some kind of drill-tank mole
machine"; 15 November: "The mole is the least far along, maybe just mock that one up a couple
different ways"; docs/briefs/minerva_mole.md). Three silhouettes meant to differ at a glance, each
a mole machine in Minerva's steel and green, none of them a kit: the drill tank (one great cone for
a nose), the tunnel-borer (a full-face cutter head on a long segmented body) and the digger (two
shovel claws flanking a small snout drill, a mole's forepaws). Mounts are placeholders, three a
machine, set clear of the digging gear. Not content and not in models_low.py: built only by
build_look.py and sheet.py. x right, y forward, z up, the ground at z = 0, as in models_low.py."""

import math

from mathutils import Matrix, Vector

from bl_low import boom, rect
from models_low import _beam, _chamfered, _poly, _rings, _spike, _sq

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

LOOKS = ["mnlook_mole_a", "mnlook_mole_b", "mnlook_mole_c"]

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

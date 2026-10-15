"""Look tests for the Wainwright & Sutler multi-rotor (13 October, docs/briefs/ws_multirotor.md):
three silhouettes in the lowforge register, for Ryan to see before any is chosen
(docs/looks/ws_multirotor.png). Not content and not in models_low.py: a proposal's look,
built only by build_look.py. x right, y forward, z up, as in models_low.py."""

import math

from mathutils import Matrix

from bl_low import boom, rect
from models_low import _tube

WS = "wainwright_sutler"


def _sec(cx, w, z0, z1, top=0.28, mid=0.55):
    """A wagon-hood section: flat base, upright sides to `mid`, a flattened arch over."""
    h = z1 - z0
    return [(cx - w / 2, z0), (cx + w / 2, z0), (cx + w / 2, z0 + h * mid),
            (cx + w * top, z1), (cx - w * top, z1), (cx - w / 2, z0 + h * mid)]


def hood(b, cx, y0, y1, w, z0, z1, hoops=4):
    """The covered wagon's bonnet: bone canvas over iron hoops."""
    b.loft([(y0, _sec(cx, w, z0, z1)), (y1, _sec(cx, w, z0, z1))], "bone.bone", "canvas")
    for k in range(hoops):
        y = y0 + 1.5 + k * (y1 - y0 - 3.0) / max(1, hoops - 1)
        b.loft([(y - 0.7, _sec(cx, w + 1.0, z0, z1 + 0.6)), (y + 0.7, _sec(cx, w + 1.0, z0, z1 + 0.6))], "steel.dark", "hoop")


def rotor(b, name, cx, cy, cz, radius, blades=5, hand=1.0, chord=6.0, phase=0.0):
    """A great rotor drawn as blades, never a disc: a hub, long tapering blades with hazard
    tips, on a yaw joint so it can spin."""
    with b.joint(name, (cx, cy, cz), axis="yaw"):
        b.prism("z", cx, cy, cz, 3.2, 3.0, "steel.dark", 8, "rotor_hub")
        b.prism("z", cx, cy, cz + 2.0, 1.8, 1.2, "steel.plate", 8, "hub_cap")
        for k in range(blades):
            a = phase + k * 2.0 * math.pi / blades
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(a, 4, "Z") @ Matrix.Rotation(0.12 * hand, 4, "Y")
            tip = radius * 0.86
            b.loft([(2.5, rect(0.0, chord, -0.55, 0.55)), (tip, rect(0.0, chord * 0.8, -0.45, 0.45))], "steel.dark", "blade", m)
            b.loft([(tip, rect(0.0, chord * 0.8, -0.45, 0.45)), (radius, rect(0.0, chord * 0.75, -0.4, 0.4))], "steel.hazard", "blade_tip", m)
    b.spin(name, 300.0 * hand, 520.0 * hand)


def deck_gun(b, hp, x, y, z, twin=True):
    """A bolted-on deck mount with a gun on it, squared off, read from above."""
    with b.socket(hp, (x, y, z + 3.0)):
        b.box(x - 3.0, x + 3.0, y - 3.5, y + 3.0, z, z + 3.0, "steel.panel", "mount")
        for s in ((-1.3, 1.3) if twin else (0.0,)):
            b.prism("y", x + s, y + 7.0, z + 2.0, 0.9, 10.0, "steel.dark", 6, "barrel")


def crane(b, x, y, z, yaw, reach=20.0, drop=6.0):
    """The cargo boom: a mast, a jib swung out (`yaw` from forward, -90 to starboard), a hook
    on a line below the hull."""
    b.prism("z", x, y, z + 8.0, 1.4, 16.0, "steel.dark", 6, "crane_mast")
    end, _ = boom(b, (x, y, z + 15.0), reach, 14.0, yaw, 2.4, 2.0, 1.6, 1.4, "livery.livery2", "crane_jib")
    ex, ey, ez = end
    b.prism("z", ex, ey, (ez + drop) / 2.0, 0.35, ez - drop, "steel.dark", 4, "crane_line")
    b.box(ex - 1.4, ex + 1.4, ey - 1.4, ey + 1.4, drop - 3.0, drop, "steel.dark", "hook")


def wslook_v12(b):
    """The brief as written: a Mil V-12's flying wagon. A boxy fuselage, a high wing braced to
    the flanks, a great rotor at each tip turning against the other, their discs all but
    meeting over the spine; the canvas bay amidships, decks fore and aft, the crane aft."""
    b.loft([(-40.0, rect(0.0, 18.0, 18.0, 34.0)), (-30.0, rect(0.0, 22.0, 14.0, 36.0)),
            (34.0, rect(0.0, 22.0, 14.0, 36.0)), (44.0, rect(0.0, 20.0, 16.0, 30.0))], "steel.panel", "fuselage")
    b.loft([(44.0, rect(0.0, 20.0, 16.0, 30.0)), (52.0, rect(0.0, 14.0, 19.0, 27.0))], "steel.plate", "nose")
    b.loft([(38.0, rect(0.0, 20.5, 30.0, 36.5)), (46.0, rect(0.0, 18.0, 27.0, 31.0))], "glass.glass", "glazing")
    b.box(-11.3, 11.3, -36.0, 40.0, 22.0, 25.0, "livery.livery2", "band")
    b.box(-3.0, 3.0, 51.5, 52.5, 22.0, 25.0, "amber.light", "nose_lamp")
    # The tail: a boom, a tailplane and twin fins.
    b.loft([(-66.0, rect(0.0, 6.0, 26.0, 31.0)), (-40.0, rect(0.0, 12.0, 22.0, 33.0))], "steel.panel", "tail_boom")
    b.box(-18.0, 18.0, -66.0, -58.0, 29.0, 31.0, "steel.plate", "tailplane")
    for s in (-1.0, 1.0):
        b.box(s * 18.0 - 1.0, s * 18.0 + 1.0, -67.0, -57.0, 24.0, 42.0, "steel.plate", "fin")
    # The high wing, wider at the tips, braced to the flanks.
    wing = Matrix.Rotation(-math.pi / 2.0, 4, "Z")
    b.loft([(-46.0, rect(-1.0, 22.0, 36.0, 39.0)), (0.0, rect(-3.0, 14.0, 36.0, 39.5)), (46.0, rect(-1.0, 22.0, 36.0, 39.0))], "steel.plate", "wing", wing)
    for s in (-1.0, 1.0):
        boom(b, (s * 11.0, 4.0, 18.0), 34.0, -32.0, -90.0 * s, 2.2, 2.2, 2.2, 2.2, "steel.dark", "strut")
        b.box(s * 46.0 - 5.0, s * 46.0 + 5.0, -10.0, 16.0, 31.0, 42.0, "steel.panel", "nacelle")
        b.box(s * 46.0 - 2.0, s * 46.0 + 2.0, 16.0, 17.0, 34.0, 37.0, "amber.light", "tip_lamp")
        b.prism("z", s * 46.0, 3.0, 46.0, 2.0, 8.0, "steel.dark", 6, "mast")
        rotor(b, "rotor_%s" % ("l" if s < 0 else "r"), s * 46.0, 3.0, 50.0, 40.0, 5, hand=-s, phase=0.3)
    # The canvas bay amidships behind the wing; the decks fore and aft.
    hood(b, 0.0, -34.0, -8.0, 18.0, 36.0, 45.0)
    b.box(-11.0, 11.0, 10.0, 34.0, 36.0, 37.0, "steel.plate", "deck_fore")
    b.box(-10.0, 10.0, -40.0, -34.0, 34.0, 35.0, "steel.plate", "deck_aft")
    b.box(-8.0, 8.0, -39.0, -35.0, 35.0, 35.3, "steel.hazard", "landing")
    deck_gun(b, "hp_1", -8.0, 16.0, 37.0)
    deck_gun(b, "hp_2", 8.0, 16.0, 37.0)
    deck_gun(b, "hp_3", -8.0, 28.0, 37.0, twin=False)
    deck_gun(b, "hp_4", 8.0, 28.0, 37.0, twin=False)
    for k, s in ((5, -1.0), (6, 1.0)):
        b.pad("hp_%d" % k, (s * 13.0, -20.0, 30.0), forward=(s, 0.0, 0.0), size=(6.0, 1.0))
    crane(b, 6.0, -38.0, 35.0, -90.0, reach=22.0, drop=6.0)
    b.move(strafe=1.0, tilt=(8.0, 6.0, 0.5), accel=1.6, heft=0.28)


wslook_v12.maker = WS


def wslook_tandem(b):
    """A Chinook in W&S iron: a long boxcar hull under two great rotors fore and aft, the aft
    on a tall pylon so their discs overlap clear of each other; the wagon's canvas along the
    long back between them, mounts on the side sponsons, a ramp and a hook aft."""
    b.loft([(-56.0, rect(0.0, 24.0, 12.0, 36.0)), (40.0, rect(0.0, 24.0, 12.0, 36.0)),
            (48.0, rect(0.0, 21.0, 13.0, 33.0))], "steel.panel", "hull")
    b.loft([(48.0, rect(0.0, 21.0, 13.0, 33.0)), (58.0, rect(0.0, 14.0, 17.0, 27.0))], "steel.plate", "nose")
    b.loft([(44.0, rect(0.0, 21.5, 27.0, 34.0)), (54.0, rect(0.0, 16.0, 24.0, 28.5))], "glass.glass", "glazing")
    b.box(-12.3, 12.3, -52.0, 44.0, 22.0, 25.0, "livery.livery2", "band")
    b.box(-3.0, 3.0, 57.5, 58.5, 20.0, 23.0, "amber.light", "nose_lamp")
    for s in (-1.0, 1.0):
        x0, x1 = sorted((s * 12.0, s * 16.0))
        b.box(x0, x1, -34.0, 26.0, 12.0, 20.0, "steel.plate", "sponson")
    # The pylons: low forward, tall aft.
    b.loft([(32.0, rect(0.0, 12.0, 36.0, 44.0)), (46.0, rect(0.0, 10.0, 36.0, 42.0))], "steel.panel", "pylon_fore")
    b.loft([(-58.0, rect(0.0, 14.0, 36.0, 58.0)), (-38.0, rect(0.0, 16.0, 36.0, 52.0))], "steel.panel", "pylon_aft")
    b.box(-1.5, 1.5, -38.5, -37.5, 46.0, 49.0, "amber.light", "pylon_lamp")
    b.prism("z", 0.0, 40.0, 46.0, 2.0, 6.0, "steel.dark", 6, "mast_fore")
    b.prism("z", 0.0, -48.0, 60.0, 2.0, 6.0, "steel.dark", 6, "mast_aft")
    rotor(b, "rotor_fore", 0.0, 40.0, 49.0, 44.0, 3, hand=1.0, chord=6.5, phase=0.2)
    rotor(b, "rotor_aft", 0.0, -48.0, 63.0, 44.0, 3, hand=-1.0, chord=6.5, phase=1.1)
    # The wagon's canvas along the back, between the pylons.
    hood(b, 0.0, -36.0, 30.0, 20.0, 36.0, 46.0, hoops=6)
    # Mounts on the sponsons, and the ramp and hook aft.
    for k, (s, y) in enumerate(((-1.0, 18.0), (1.0, 18.0), (-1.0, 2.0), (1.0, 2.0), (-1.0, -14.0), (1.0, -14.0))):
        deck_gun(b, "hp_%d" % (k + 1), s * 14.0, y, 20.0, twin=(k < 4))
    b.loft([(-64.0, rect(0.0, 20.0, 8.0, 10.0)), (-56.0, rect(0.0, 20.0, 12.0, 14.0))], "steel.hazard", "ramp")
    b.prism("z", 0.0, -4.0, 8.5, 0.35, 7.0, "steel.dark", 4, "hook_line")
    b.box(-1.4, 1.4, -5.4, -2.6, 3.0, 5.0, "steel.dark", "hook")
    b.move(strafe=1.0, tilt=(8.0, 6.0, 0.5), accel=1.6, heft=0.28)


wslook_tandem.maker = WS


def wslook_deck(b):
    """The helicarrier played straight: a flat iron deck held up by four rotors in rings at
    its corners, an island on the starboard edge, a landing square aft, mounts round the
    deck's edge, the crane on the port quarter."""
    b.loft([(-46.0, rect(0.0, 40.0, 12.0, 22.0)), (36.0, rect(0.0, 40.0, 12.0, 22.0)),
            (52.0, rect(0.0, 20.0, 15.0, 22.0))], "steel.panel", "hull")
    b.loft([(-52.0, rect(0.0, 54.0, 22.0, 27.0)), (40.0, rect(0.0, 54.0, 22.0, 27.0)),
            (60.0, rect(0.0, 26.0, 23.0, 27.0))], "steel.plate", "deck")
    b.box(-20.3, 20.3, -44.0, 34.0, 15.0, 18.0, "livery.livery2", "band")
    b.box(-1.0, 1.0, -50.0, 40.0, 27.0, 27.3, "steel.stripe", "centre_line")
    b.box(-20.0, -2.0, -46.0, -28.0, 27.0, 27.3, "steel.hazard", "landing")
    for s in (-1.0, 1.0):
        b.box(s * 8.0 - 1.5, s * 8.0 + 1.5, 59.0, 60.5, 23.5, 26.0, "amber.light", "bow_lamp")
    # The island, starboard.
    b.box(16.0, 25.0, -12.0, 12.0, 27.0, 41.0, "steel.panel", "island")
    b.box(15.7, 25.3, -11.0, 11.0, 37.0, 40.0, "glass.glass", "bridge")
    b.box(17.0, 24.0, -10.0, 10.0, 41.0, 43.0, "steel.plate", "island_roof")
    b.prism("z", 20.5, -4.0, 48.0, 0.8, 10.0, "steel.dark", 6, "island_mast")
    b.box(19.5, 21.5, -5.0, -3.0, 52.0, 54.0, "amber.light", "mast_lamp")
    b.box(17.5, 23.5, 4.0, 9.0, 43.0, 49.0, "steel.dark", "stack")
    # Four rotors in iron rings at the corners, each on an arm from the hull.
    for sx in (-1.0, 1.0):
        for sy, yy in (("f", 30.0), ("a", -38.0)):
            cx = sx * 44.0
            _tube(b, (cx, yy, 17.0), (cx, yy, 25.0), 16.0, 14.4, 16, "steel.panel", "ring", floor=False)
            b.box(min(sx * 20.0, sx * 30.0), max(sx * 20.0, sx * 30.0), yy - 3.0, yy + 3.0, 18.0, 23.0, "steel.dark", "arm")
            b.box(cx - 1.2, cx + 1.2, yy - 15.0, yy + 15.0, 19.5, 21.0, "steel.dark", "ring_spar")
            rotor(b, "rotor_%s%s" % ("l" if sx < 0 else "r", sy), cx, yy, 22.0, 14.0, 4, hand=sx, chord=4.0, phase=0.4)
    for k, (x, y) in enumerate(((-23.0, 30.0), (23.0, 30.0), (-23.0, 6.0), (-23.0, -18.0), (8.0, 46.0), (-8.0, 46.0))):
        deck_gun(b, "hp_%d" % (k + 1), x, y, 27.0, twin=(k < 4))
    crane(b, 6.0, -46.0, 27.0, 180.0, reach=20.0, drop=4.0)
    b.move(strafe=1.0, tilt=(6.0, 5.0, 0.5), accel=1.8, heft=0.3)


wslook_deck.maker = WS

LOOKS = ["wslook_v12", "wslook_tandem", "wslook_deck"]

"""A look test for the siege battery (docs/briefs/minerva_siege_battery.md), Minerva's treaded
tier-three capstone, from Ryan's pitch of 15 October: "A gargantuan, true H-tank with 4 separate
tracks. Two massive double-barreled turrets, one in front, one behind, the chassis between the
rear two treads higher so the rear turret rises above the front turret, armoured panels above
the treads, gimbaled hardpoint mounts on each of them." The slowest machine in the game.

First round, 15 November (Ryan: "let's see what you come up with ... Doesn't have to be too
detailed since none are finalized"): the Wild Boar's H made true and doubled. Four track pods at
the corners, each under its own armoured panel, a hull slung between them and shorter than they
are at both ends, so from above the pods stand proud as the letter's strokes; the hull's rear
half a storey higher than its front; a main turret on each deck, the rear one's guns lying over
the front one's roof; a gimbal on each of the four panels (hp_1 front left, hp_2 front right,
hp_3 rear left, hp_4 rear right), each wearing a class so the mounts read as mounts. The two
turrets are its locked pieces, so their guns are built here by hand and take no pin. Session's
choices where his words are silent: a rangefinder bar across each turret's roof, a visor slit
on the glacis for the crew, the engine's grille and stacks at the tail, ladders up from the rear
panels. Not content: built only by build_look.py and sheet.py; x right, y forward, z up, the
ground at z = 0."""

import math

from mathutils import Matrix

from bl_low import rect
from models_low import _chamfered, _slab, _tube

MN = "minerva"

PX, PW, PH = 62.0, 40.0, 26.0     # a track pod: its centre across, its width, the tread's height
P0, P1 = 14.0, 104.0              # a front pod's span along y; the rear pods mirror it
PANEL = 6.0                       # the armoured panel over a tread: its thickness
FRONT, REAR = 46.0, 67.0          # the hull's two decks: the chassis between the rear treads stands higher
HALF = {"barrel": (4.0, 4.0), "twin_barrel": (6.0, 3.5), "rack": (8.0, 7.5), "dish": (7.0, 7.0)}   # a class's half width and half height at scale 1


def _pod(b, sx, sy, pin, shape, carries, scale):
    """One track pod, a front one built and a rear one mirrored: the tread, its bogies on the
    outer flank, the armoured panel over it with its skirts and hazard tip, the arms to the hull
    and the gimbal on the panel with its hardpoint."""
    cx = sx * PX
    side = ("f" if sy > 0 else "r") + ("l" if sx < 0 else "r")
    top = PH + PANEL

    def loft(sections, material, label):
        b.loft(sorted(((sy * y, pts) for y, pts in sections), key=lambda s: s[0]), material, label)

    def box(xa, xb, ya, yb, z0, z1, material, label):
        (x0, x1), (y0, y1) = sorted((xa, xb)), sorted((sy * ya, sy * yb))
        b.box(x0, x1, y0, y1, z0, z1, material, label)

    # The tread: its outer end raked up to climb, its inner end rounded off.
    loft([(P0, rect(cx, PW, 5.0, PH - 5.0)), (P0 + 8.0, rect(cx, PW, 0.0, PH)),
          (P1 - 15.0, rect(cx, PW, 0.0, PH)), (P1, rect(cx, PW, 10.0, PH - 4.0))], "bore.tread", "tread")
    # The running gear on the outer flank: five road wheels, an idler inboard, the sprocket at the raked end.
    out = sx * (PX + PW / 2.0)
    for y, z, r in [(19.5, 11.0, 5.0)] + [(30.0 + 13.0 * k, 7.5, 6.0) for k in range(5)] + [(95.0, 15.0, 6.2)]:
        b.prism("x", out + sx * 0.7, sy * y, z, r, 2.6, "steel.dark", 8, "road_wheel", phase=math.pi / 8)
        b.prism("x", out + sx * 1.2, sy * y, z, r * 0.42, 3.4, "steel.plate", 6, "wheel_hub")
    # The armoured panel over the tread, its outer end falling to a fender, a hazard tip on its
    # top, and its skirts hung down the outer flank in three slabs.
    loft([(P0 + 2.0, _chamfered(cx, PW + 4.0, PH - 0.5, top, 2.2)), (P1 - 24.0, _chamfered(cx, PW + 4.0, PH - 0.5, top, 2.2)),
          (P1 - 5.0, _chamfered(cx, PW + 4.0, PH - 4.5, PH + 0.5, 2.2))], "steel.plate", "panel")
    box(cx - PW / 2.0 + 0.4, cx + PW / 2.0 - 0.4, P1 - 40.0, P1 - 24.5, top, top + 0.5, "steel.stripe", "panel_tip")
    box(cx + sx * 4.0, cx + sx * 13.0, P0 + 8.0, P0 + 19.0, top, top + 0.9, "steel.panel", "panel_hatch")
    for ya, yb in ((26.0, 46.0), (49.0, 69.0), (72.0, 88.0)):
        box(out + sx * 0.4, out + sx * 3.2, ya, yb, 13.5, top - 1.5, "livery.livery2", "skirt")
    # Two stout arms to the hull: the pods are four machines' worth of running gear, each on its own.
    for y in (P0 + 24.0, P0 + 62.0):
        b.prism("x", sx * 37.0, sy * y, 17.0, 5.5, 14.0, "steel.dark", 8, "arm", phase=math.pi / 8)
    if sy > 0:
        # A driving lamp on each front panel, inboard.
        lx = cx - sx * 14.0
        box(lx - 3.5, lx + 3.5, P1 - 31.0, P1 - 25.0, top, top + 4.5, "steel.dark", "lamp_housing")
        box(lx - 2.6, lx + 2.6, P1 - 25.0, P1 - 24.4, top + 0.8, top + 3.8, "amber.light", "lamp")
    # The gimbal on the panel: a ring, a drum that traverses, a trunnion through the weapon, the
    # hardpoint on it wearing its class.
    gy = sy * 60.0
    half_w, half_h = HALF[shape]
    b.prism("z", cx, gy, top + 0.6, 10.5, 1.2, "steel.dark", 8, "gimbal_ring")
    with b.joint("turret_%s" % side, (cx, gy, top + 1.2), limits=(-150.0, 150.0)):
        b.prism("z", cx, gy, top + 3.9, 8.5, 5.4, "steel.plate", 8, "gimbal", phase=math.pi / 8)
        pz = top + 6.6 + half_h * scale + 0.2
        b.prism("x", cx, gy, pz, 2.3 * scale, (half_w * 2.0 + 5.0) * scale, "steel.dark", 6, "trunnion")
        for s in (-1.0, 1.0):
            x = cx + s * (half_w + 2.2) * scale
            b.box(x - 1.0, x + 1.0, gy - 3.4, gy + 3.4, top + 6.0, pz + 2.6 * scale, "steel.plate", "gimbal_cheek")
        b.stock(pin, (cx, gy, pz), shape, scale=scale, carries=carries)


def _turret(b, name, ty, deck, antenna=False):
    """A main turret, a locked piece: a ring on the deck, a wide faceted house on a yaw joint,
    the mantlet and two great guns side by side on its elevation, each a sleeve, a barrel with a
    fume extractor and a slotted brake with a true bore; a hatch, a cupola, a sight and a
    rangefinder bar across the roof, a grille in the bustle."""
    zb = deck + 2.0
    top = zb + 20.0
    zc = zb + 9.5
    b.prism("z", 0.0, ty, deck + 1.0, 31.5, 2.0, "steel.dark", 12, "turret_ring")
    with b.joint("turret_%s" % name, (0.0, ty, zb), axis="yaw", limits=(-135.0, 135.0)):
        b.loft([(ty - 34.0, _chamfered(0.0, 40.0, zb, zb + 14.0, 4.0)), (ty - 20.0, _chamfered(0.0, 62.0, zb, top, 7.0)),
                (ty + 12.0, _chamfered(0.0, 62.0, zb, top, 7.0)), (ty + 30.0, _chamfered(0.0, 46.0, zb + 1.0, zb + 17.0, 4.0))],
               "steel.panel", "turret_house")
        for s in (-1.0, 1.0):
            b.box(min(s * 31.0, s * 33.2), max(s * 31.0, s * 33.2), ty - 16.0, ty + 8.0, zb + 2.0, zb + 12.0, "livery.livery2", "turret_cheek")
        b.box(-14.0, 14.0, ty - 34.8, ty - 34.0, zb + 3.0, zb + 11.0, "steel.vent", "bustle_vent")
        with b.joint("elev_%s" % name, (0.0, ty + 30.0, zc), axis="pitch", limits=(-4.0, 22.0)):
            b.box(-21.0, 21.0, ty + 29.0, ty + 36.0, zc - 8.0, zc + 7.5, "steel.plate", "mantlet")
            for s in (-1.0, 1.0):
                x = s * 11.5
                b.prism("y", x, ty + 43.0, zc, 7.2, 14.0, "steel.plate", 8, "gun_sleeve", phase=math.pi / 8)
                b.prism("y", x, ty + 74.0, zc, 5.6, 48.0, "steel.dark", 8, "gun_barrel", phase=math.pi / 8)
                b.prism("y", x, ty + 66.0, zc, 7.0, 11.0, "steel.plate", 8, "gun_extractor", phase=math.pi / 8)
                _tube(b, (x, ty + 97.0, zc), (x, ty + 109.0, zc), 7.6, 4.6, 8, "steel.plate", "gun_brake", phase=math.pi / 8)
        # The roof: a hatch, a cupola with a glass band, a sight, the rangefinder's bar and ears.
        b.box(-20.0, -9.0, ty - 12.0, ty - 1.0, top, top + 1.0, "steel.plate", "hatch")
        b.prism("z", 19.0, ty - 6.0, top + 2.0, 5.5, 4.0, "steel.plate", 8, "cupola", phase=math.pi / 8)
        b.prism("z", 19.0, ty - 6.0, top + 2.4, 5.9, 1.3, "glass.glass", 8, "cupola_glass", phase=math.pi / 8)
        b.box(-23.0, -15.0, ty + 3.0, ty + 10.0, top, top + 4.0, "steel.dark", "sight_box")
        b.box(-22.0, -16.0, ty + 10.0, ty + 10.6, top + 0.8, top + 3.2, "amber.light", "sight")
        b.prism("x", 0.0, ty - 17.0, top + 2.4, 2.6, 76.0, "steel.dark", 6, "rangefinder")
        for s in (-1.0, 1.0):
            b.box(min(s * 35.0, s * 41.0), max(s * 35.0, s * 41.0), ty - 20.5, ty - 13.5, top - 0.6, top + 5.4, "steel.plate", "rangefinder_ear")
            b.box(min(s * 36.2, s * 39.8), max(s * 36.2, s * 39.8), ty - 13.5, ty - 12.9, top + 0.8, top + 4.2, "amber.light", "rangefinder_lens")
        if antenna:
            b.prism("z", -15.0, ty - 29.0, zb + 28.0, 0.55, 26.0, "steel.dark", 4, "antenna")


def mnlook_siege(b):
    """The H-tank: four pods, the hull between them on two decks, a main turret on each."""
    # The pods and their hardpoints, in the die's order.
    _pod(b, -1.0, 1.0, "hp_1", "twin_barrel", "twin_autoguns", 1.25)
    _pod(b, 1.0, 1.0, "hp_2", "barrel", "slugthrower", 1.25)
    _pod(b, -1.0, -1.0, "hp_3", "rack", "shotfire_rack", 1.05)
    _pod(b, 1.0, -1.0, "hp_4", "rack", "shotfire_rack", 1.05)
    # The hull slung between them: the front half low under its glacis, the rear half a storey
    # higher, its tail falling to the engine's grille. Shorter than the pods at both ends.
    b.loft([(-2.0, _chamfered(0.0, 64.0, 12.0, FRONT, 5.0)), (66.0, _chamfered(0.0, 64.0, 12.0, FRONT, 5.0)),
            (84.0, _chamfered(0.0, 58.0, 16.0, 28.0, 3.0))], "steel.panel", "hull_front")
    b.loft([(-94.0, _chamfered(0.0, 62.0, 18.0, REAR - 8.0, 6.0)), (-88.0, _chamfered(0.0, 68.0, 12.0, REAR, 6.0)),
            (-10.0, _chamfered(0.0, 68.0, 12.0, REAR, 6.0)), (-2.0, _chamfered(0.0, 66.0, 12.0, FRONT + 1.0, 5.0))], "steel.panel", "hull_rear")
    # The nose: a visor slit and a livery plate down the glacis, lamps and a tow bar on the nose plate.
    glacis = lambda y: FRONT - (y - 66.0)
    _slab(b, [(-13.0, 70.0, glacis(70.0)), (13.0, 70.0, glacis(70.0)), (13.0, 73.5, glacis(73.5)), (-13.0, 73.5, glacis(73.5))], (0.0, 1.0, 1.0), 1.0, "glass.glass", "visor")
    _slab(b, [(-17.0, 75.5, glacis(75.5)), (17.0, 75.5, glacis(75.5)), (17.0, 82.5, glacis(82.5)), (-17.0, 82.5, glacis(82.5))], (0.0, 1.0, 1.0), 0.8, "livery.livery2", "glacis_panel")
    b.box(-10.0, 10.0, 84.0, 87.5, 16.5, 19.5, "steel.dark", "tow_bar")
    for s in (-1.0, 1.0):
        b.box(min(s * 17.0, s * 25.0), max(s * 17.0, s * 25.0), 83.5, 84.6, 19.5, 26.5, "steel.dark", "lamp_housing")
        b.box(min(s * 18.0, s * 24.0), max(s * 18.0, s * 24.0), 84.6, 85.2, 20.5, 25.5, "amber.light", "lamp")
    # The flanks: appliqué slabs in the livery, and a ladder up each side from the rear panel to the high deck.
    for s in (-1.0, 1.0):
        b.box(min(s * 32.0, s * 34.2), max(s * 32.0, s * 34.2), 4.0, 58.0, 34.5, 40.5, "livery.livery2", "applique")
        for y0, y1 in ((-84.0, -56.0), (-52.0, -28.0)):
            b.box(min(s * 34.0, s * 36.6), max(s * 34.0, s * 36.6), y0, y1, 36.0, 60.0, "livery.livery2", "applique")
        b.box(min(s * 34.0, s * 34.9), max(s * 34.0, s * 34.9), -25.0, -11.0, 32.0, REAR - 6.0, "steel.ladder", "ladder")
    # The tail: the engine's grille across the back, a stack on each corner of the high deck.
    b.box(-22.0, 22.0, -95.0, -94.0, 24.0, 54.0, "steel.vent", "rear_vents")
    for s in (-1.0, 1.0):
        b.prism("z", s * 29.5, -86.0, REAR + 5.0, 3.6, 10.0, "steel.dark", 6, "stack")
        b.prism("z", s * 29.5, -86.0, REAR + 10.8, 4.5, 1.6, "steel.plate", 6, "stack_cap")
    # The two main turrets: the front on the low deck, the rear on the high one, its guns over the front's roof.
    _turret(b, "front", 34.0, FRONT)
    _turret(b, "rear", -48.0, REAR, antenna=True)
    b.pivots = True
    b.move(accel=0.6, heft=0.1)


mnlook_siege.maker = MN


def mnlook_siege_beside(b):
    """The H-tank with the Wild Boar, Minerva's H-tank as the game has it, standing off its
    right bow at the same scale: the one way a sheet shows "gargantuan", since each cell frames
    its model to fit. The Boar is the game's own model, built into the same file and moved; its
    pins are renamed so only the battery's four count."""
    import models_low
    mnlook_siege(b)
    other = type(b)("beside", b.tiles)
    other.materials = b.materials
    models_low.wild_boar(other)
    shift = Matrix.Translation((150.0, 36.0, 0.0))
    for ob in other.objects + other.pins:
        if ob.parent is None:
            ob.matrix_world = shift @ ob.matrix_world
    for e in other.pins:
        if e.name.startswith("hp_"):
            e.name = "beside_" + e.name


mnlook_siege_beside.maker = MN

LOOKS = ["mnlook_siege", "mnlook_siege_beside"]

SHEET = {
    "title": "The siege battery, first round, 15 November (look tests, not content)",
    "out": "docs/looks/minerva_siege.png",
    "cell": (400, 400),
    "rows": [
        {"model": "mnlook_siege", "label": "The H-tank", "views": ["codex", "above", "skirmish"]},
        {"model": "mnlook_siege", "label": "The H-tank", "views": [("from the side", 90.0, 8.0), "front", "rear"]},
        {"model": "mnlook_siege_beside", "label": "Beside the Wild Boar, to scale", "views": ["codex", "above", ("from the side", 90.0, 8.0)]},
    ],
}

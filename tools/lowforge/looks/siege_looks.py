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
turrets are its locked pieces, so their guns are built here by hand and take no pin. The decks
and the turrets are spaced so each turret can train: the front one's bustle swings clear of the
step, its guns pass over the front gimbals, and the rear one's guns pass over the front one's
roof. Session's choices where his words are silent: a rangefinder bar across each turret's
roof, a visor slit on the glacis for the crew, the engine's grille and stacks at the tail, a
ladder up each side from the rear panel. Two more models for the sheet: the battery trained to
port, and the battery beside the Wild Boar at the same scale. Not content: built only by
build_look.py and sheet.py; x right, y forward, z up, the ground at z = 0.

Second round, the same day, on his notes: "H tank - detail is good, the body is too high for the
treads. I get that you're trying to clear the mounts on top of the treads, and I didn't think of
that when I dictated it. Maybe they need to go somewhere else, not sure where. Don't necessarily
need to be able to swivel, so that could help." So the hull sits down between its treads: the low
deck a lip over the panels' tops (35 against round one's 48), the high deck one turret's height
above it (54 against 72), which is what the rear guns need to lie over the front turret's roof,
and the turrets a little flatter (18 against 20), so the rear roof stands at 74 where it stood
at 94. The four hardpoints leave the tops of the panels as fixed mounts, no gimbal and no
swivel, since the whole tank turns to aim as tracks do; he is not sure where, so the sheet shows
the same tank three ways (SHEET2, the mnlook_siege2_* models): A, a sponson on each pod's outer
flank, the rear pair hung higher so they fire over the front pair as the turrets do; B, kept on
the panels but fixed and low at the plan's four outer corners, a hood a gun fires out of on each
front panel and a canted cradle on each rear one; C, in the hull, a port in each corner of the
bow and a casemate on each shoulder of the high deck. A mount a weapon fires through wears the
classes' port forms (the Kite's and the Polar Bear's way). The front turret's roof is kept low
and bare where the rear guns lie over it, so the rangefinder bar is the rear turret's alone."""

import math

from mathutils import Matrix

from bl_low import rect
from models_low import _chamfered, _slab, _tube

MN = "minerva"

PX, PW, PH = 62.0, 40.0, 26.0     # a track pod: its centre across, its width, the tread's height
P0, P1 = 14.0, 108.0              # a front pod's span along y; the rear pods mirror it
PANEL = 6.0                       # the armoured panel over a tread: its thickness
FRONT, REAR = 48.0, 72.0          # the hull's two decks: the chassis between the rear treads stands higher
TF, TR = 40.0, -43.0              # the two turrets' centres along y
STEP = 1.0                        # where the step between the decks meets the low one
HALF = {"barrel": (4.0, 4.0), "twin_barrel": (6.0, 3.5), "rack": (8.0, 7.5), "dish": (7.0, 7.0)}   # a class's half width, and how far it hangs under its pin, at scale 1


def _pod(b, sx, sy, pin, shape, carries, scale):
    """One track pod, a front one built and a rear one mirrored: the tread, its running gear on
    the outer flank, the armoured panel over it with its skirts and hazard tip, the arms to the
    hull and the gimbal on the panel with its hardpoint."""
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
    # The running gear on the outer flank: an idler inboard, five road wheels, the sprocket at the raked end.
    out = sx * (PX + PW / 2.0)
    for y, z, r in [(19.5, 11.0, 5.0)] + [(30.0 + 13.6 * k, 7.5, 6.0) for k in range(5)] + [(P1 - 9.0, 15.0, 6.2)]:
        b.prism("x", out + sx * 0.7, sy * y, z, r, 2.6, "steel.dark", 8, "road_wheel", phase=math.pi / 8)
        b.prism("x", out + sx * 1.2, sy * y, z, r * 0.42, 3.4, "steel.plate", 6, "wheel_hub")
    # The armoured panel over the tread, bevelled, its outer end falling to a fender; a hazard
    # tip across its top (one band of the stripe tile: the tile repeats every fourteen units, its
    # band from 4.8 to 9.2 of them), a hatch at its inner end, and its skirts hung down the outer
    # flank in three slabs.
    loft([(P0 + 2.0, _chamfered(cx, PW + 4.0, PH - 0.5, top, 2.2)), (P1 - 24.0, _chamfered(cx, PW + 4.0, PH - 0.5, top, 2.2)),
          (P1 - 5.0, _chamfered(cx, PW + 4.0, PH - 4.5, PH + 0.5, 2.2))], "steel.plate", "panel")
    box(cx - PW / 2.0 + 0.4, cx + PW / 2.0 - 0.4, 73.0, 81.0, top, top + 0.5, "steel.stripe", "panel_tip")
    box(cx + sx * 4.0, cx + sx * 13.0, P0 + 8.0, P0 + 19.0, top, top + 0.9, "steel.panel", "panel_hatch")
    for ya, yb in ((26.0, 47.0), (50.0, 71.0), (74.0, P1 - 16.0)):
        box(out + sx * 0.4, out + sx * 3.2, ya, yb, 13.5, top - 1.5, "livery.livery2", "skirt")
    # Two stout arms to the hull: each pod its own running gear.
    for y in (P0 + 24.0, P0 + 66.0):
        b.prism("x", sx * 37.0, sy * y, 17.0, 5.5, 14.0, "steel.dark", 8, "arm", phase=math.pi / 8)
    if sy > 0:
        # A driving lamp at the head of each front panel, inboard, where the fender starts to fall.
        lx = cx - sx * 14.0
        box(lx - 3.5, lx + 3.5, P1 - 23.5, P1 - 18.0, top - 1.5, top + 4.0, "steel.dark", "lamp_housing")
        box(lx - 2.6, lx + 2.6, P1 - 18.0, P1 - 17.4, top - 0.4, top + 3.0, "amber.light", "lamp")
    # The gimbal on the panel: a ring, a drum that traverses, cheeks and a trunnion through the
    # weapon, and the hardpoint wearing its class.
    gy = sy * 60.0
    half_w, under = HALF[shape]
    b.prism("z", cx, gy, top + 0.6, 10.5, 1.2, "steel.dark", 8, "gimbal_ring")
    with b.joint("turret_%s" % side, (cx, gy, top + 1.2), limits=(-150.0, 150.0)):
        b.prism("z", cx, gy, top + 3.9, 8.5, 5.4, "steel.plate", 8, "gimbal", phase=math.pi / 8)
        pz = top + 6.6 + under * scale + 0.2
        b.prism("x", cx, gy, pz, 2.3 * scale, (half_w * 2.0 + 5.0) * scale, "steel.dark", 6, "trunnion")
        for s in (-1.0, 1.0):
            x = cx + s * (half_w + 2.2) * scale
            b.box(x - 1.0, x + 1.0, gy - 3.4, gy + 3.4, top + 6.0, pz + 2.6 * scale, "steel.plate", "gimbal_cheek")
        b.stock(pin, (cx, gy, pz), shape, scale=scale, carries=carries)


def _turret(b, name, ty, deck, antenna=False):
    """A main turret, a locked piece: a ring on the deck, a wide faceted house on a yaw joint,
    the mantlet and two great guns side by side on its elevation, each a sleeve, a barrel with a
    fume extractor and a brake with a true bore; a hatch, a cupola, a sight and a rangefinder
    bar across the roof, a grille in the bustle."""
    zb = deck + 2.0
    top = zb + 20.0
    zc = zb + 9.5
    b.prism("z", 0.0, ty, deck + 1.0, 31.5, 2.0, "steel.dark", 12, "turret_ring")
    with b.joint("turret_%s" % name, (0.0, ty, zb), axis="yaw", limits=(-135.0, 135.0)):
        b.loft([(ty - 31.0, _chamfered(0.0, 38.0, zb, zb + 14.0, 4.0)), (ty - 19.0, _chamfered(0.0, 62.0, zb, top, 7.0)),
                (ty + 12.0, _chamfered(0.0, 62.0, zb, top, 7.0)), (ty + 30.0, _chamfered(0.0, 46.0, zb + 1.0, zb + 17.0, 4.0))],
               "steel.panel", "turret_house")
        for s in (-1.0, 1.0):
            b.box(min(s * 31.0, s * 33.2), max(s * 31.0, s * 33.2), ty - 15.0, ty + 8.0, zb + 2.0, zb + 12.0, "livery.livery2", "turret_cheek")
        b.box(-13.0, 13.0, ty - 31.8, ty - 31.0, zb + 3.0, zb + 11.0, "steel.vent", "bustle_vent")
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
        b.prism("x", 0.0, ty - 15.0, top + 2.4, 2.6, 76.0, "steel.dark", 6, "rangefinder")
        for s in (-1.0, 1.0):
            b.box(min(s * 35.0, s * 41.0), max(s * 35.0, s * 41.0), ty - 18.5, ty - 11.5, top - 0.6, top + 5.4, "steel.plate", "rangefinder_ear")
            b.box(min(s * 36.2, s * 39.8), max(s * 36.2, s * 39.8), ty - 11.5, ty - 10.9, top + 0.8, top + 4.2, "amber.light", "rangefinder_lens")
        if antenna:
            b.prism("z", -14.0, ty - 27.0, zb + 28.0, 0.55, 26.0, "steel.dark", 4, "antenna")


def mnlook_siege(b):
    """The H-tank: four pods, the hull between them on two decks, a main turret on each."""
    # The pods and their hardpoints, in the die's order.
    _pod(b, -1.0, 1.0, "hp_1", "twin_barrel", "twin_autoguns", 1.25)
    _pod(b, 1.0, 1.0, "hp_2", "barrel", "slugthrower", 1.25)
    _pod(b, -1.0, -1.0, "hp_3", "rack", "shotfire_rack", 1.05)
    _pod(b, 1.0, -1.0, "hp_4", "rack", "shotfire_rack", 1.05)
    # The hull slung between them: the front half low under its glacis, the rear half a storey
    # higher, its tail falling to the engine's grille. Shorter than the pods at both ends.
    g0, g1 = TF + 32.0, TF + 50.0          # the glacis, from the deck's edge to the nose plate
    b.loft([(STEP - 2.0, _chamfered(0.0, 64.0, 12.0, FRONT, 5.0)), (g0, _chamfered(0.0, 64.0, 12.0, FRONT, 5.0)),
            (g1, _chamfered(0.0, 58.0, 16.0, 28.0, 3.0))], "steel.panel", "hull_front")
    tail = TR - 39.0                       # where the high deck ends behind the rear turret
    b.loft([(tail - 6.0, _chamfered(0.0, 62.0, 18.0, REAR - 8.0, 6.0)), (tail, _chamfered(0.0, 68.0, 12.0, REAR, 6.0)),
            (STEP - 8.0, _chamfered(0.0, 68.0, 12.0, REAR, 6.0)), (STEP, _chamfered(0.0, 66.0, 12.0, FRONT + 1.0, 5.0))], "steel.panel", "hull_rear")
    # The nose: a visor slit and a livery plate down the glacis, lamps and a tow bar on the nose plate.
    fall = (FRONT - 28.0) / (g1 - g0)
    glacis = lambda y: FRONT - (y - g0) * fall
    on = lambda x, y0, y1: [(-x, y0, glacis(y0)), (x, y0, glacis(y0)), (x, y1, glacis(y1)), (-x, y1, glacis(y1))]
    _slab(b, on(13.0, g0 + 4.0, g0 + 7.5), (0.0, fall, 1.0), 1.0, "glass.glass", "visor")
    _slab(b, on(17.0, g0 + 9.5, g0 + 16.5), (0.0, fall, 1.0), 0.8, "livery.livery2", "glacis_panel")
    b.box(-10.0, 10.0, g1, g1 + 3.5, 16.5, 19.5, "steel.dark", "tow_bar")
    for s in (-1.0, 1.0):
        b.box(min(s * 17.0, s * 25.0), max(s * 17.0, s * 25.0), g1 - 0.5, g1 + 0.6, 19.5, 26.5, "steel.dark", "lamp_housing")
        b.box(min(s * 18.0, s * 24.0), max(s * 18.0, s * 24.0), g1 + 0.6, g1 + 1.2, 20.5, 25.5, "amber.light", "lamp")
    # The flanks: appliqué slabs in the livery, and a ladder up each side from the rear panel to
    # the high deck (the ladder tile's rungs fall from 4.4 to 9.6 of every fourteen units).
    for s in (-1.0, 1.0):
        b.box(min(s * 32.0, s * 34.2), max(s * 32.0, s * 34.2), 8.0, g0 - 10.0, FRONT - 11.5, FRONT - 5.5, "livery.livery2", "applique")
        for y0, y1 in ((tail + 4.0, tail + 28.0), (tail + 32.0, -28.0)):
            b.box(min(s * 34.0, s * 36.6), max(s * 34.0, s * 36.6), y0, y1, 36.0, REAR - 8.0, "livery.livery2", "applique")
        b.box(min(s * 34.0, s * 34.9), max(s * 34.0, s * 34.9), -25.0, -17.0, 32.0, REAR - 6.0, "steel.ladder", "ladder")
    # The tail: the engine's grille across the back, a stack on each corner of the high deck.
    b.box(-22.0, 22.0, tail - 7.0, tail - 6.0, 24.0, REAR - 14.0, "steel.vent", "rear_vents")
    for s in (-1.0, 1.0):
        b.prism("z", s * 29.5, tail + 3.5, REAR + 2.0, 3.6, 16.0, "steel.dark", 6, "stack")   # down past the deck's bevel, which it stands over
        b.prism("z", s * 29.5, tail + 3.5, REAR + 10.8, 4.5, 1.6, "steel.plate", 6, "stack_cap")
    # The two main turrets: the front on the low deck, the rear on the high one, its guns over the front's roof.
    _turret(b, "front", TF, FRONT)
    _turret(b, "rear", TR, REAR, antenna=True)
    b.pivots = True
    b.move(accel=0.6, heft=0.1)


mnlook_siege.maker = MN


def mnlook_siege_posed(b):
    """The battery trained to port, the pose baked into the joints' rest: both turrets turned,
    the rear guns raised over the front turret, the four gimbals each on its own bearing."""
    import bpy
    mnlook_siege(b)
    for name, axis, degrees in (("elev_front", "X", 5.0), ("elev_rear", "X", 13.0), ("turret_front", "Z", 32.0), ("turret_rear", "Z", 32.0),
                                ("turret_fl", "Z", 58.0), ("turret_fr", "Z", 24.0), ("turret_rl", "Z", 72.0), ("turret_rr", "Z", 18.0)):
        e = bpy.data.objects["joint_" + name]
        e.matrix_basis = e.matrix_basis @ Matrix.Rotation(math.radians(degrees), 4, axis)


mnlook_siege_posed.maker = MN


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
    shift = Matrix.Translation((160.0, 34.0, 0.0))
    for ob in other.objects + other.pins:
        if ob.parent is None:
            ob.matrix_world = shift @ ob.matrix_world
    for e in other.pins:
        if e.name.startswith("hp_"):
            e.name = "beside_" + e.name


mnlook_siege_beside.maker = MN


# ---------------------------------------------------------------- the second round

F2, R2 = 35.0, 54.0               # round two's decks: the low one a lip over the panels' tops (32), the high one a turret's height above it
TH2 = 18.0                        # a main turret's height in round two (20 in round one)
PORT = {"barrel": "barrel_port", "twin_barrel": "twin_barrel_round", "rack": "rack_port", "dish": "dish_port"}   # what a class wears through a fixed mount's port
HOOD = {"barrel": "barrel_port", "twin_barrel": ("twin_barrel_round", 0.7), "rack": ("rack_port", 0.7), "dish": ("dish_port", 0.7)}   # the same through a low hood's smaller port
MOUNTS = [("hp_1", "twin_barrel", "twin_autoguns"), ("hp_2", "barrel", "slugthrower"), ("hp_3", "rack", "shotfire_rack"), ("hp_4", "rack", "shotfire_rack")]   # the die's order: front left, front right, rear left, rear right


def _port(b, at, r, depth=1.4):
    """A fixed mount's port in a face that looks forward: a dark collar proud of the face round a
    dark well, the weapon's port form through it from the pin at its floor."""
    x, y, z = at
    _tube(b, (x, y - 0.6, z), (x, y + depth, z), r + 1.2, r, 10, "steel.dark", "port_collar", phase=math.pi / 10)


def _pod2(b, sx, sy, where=None, mount=None):
    """Round two's track pod: round one's tread, running gear, panel and arms, with no gimbal on
    the panel. `where` puts the pod's hardpoint (`mount`: pin, class, component) on it, fixed:
    "flank", a sponson on its outer flank, hung low on a front pod and high on a rear one, so the
    rear pair fire over the front pair; "panel", low on the panel at the plan's outer corner, a
    hood a gun fires out of on a front pod and a canted cradle on a rear one. None leaves the
    panel a clean plate (the mounts are the hull's)."""
    cx = sx * PX
    top = PH + PANEL
    out = sx * (PX + PW / 2.0)
    front = sy > 0

    def loft(sections, material, label):
        b.loft(sorted(((sy * y, pts) for y, pts in sections), key=lambda s: s[0]), material, label)

    def box(xa, xb, ya, yb, z0, z1, material, label):
        (x0, x1), (y0, y1) = sorted((xa, xb)), sorted((sy * ya, sy * yb))
        b.box(x0, x1, y0, y1, z0, z1, material, label)

    loft([(P0, rect(cx, PW, 5.0, PH - 5.0)), (P0 + 8.0, rect(cx, PW, 0.0, PH)),
          (P1 - 15.0, rect(cx, PW, 0.0, PH)), (P1, rect(cx, PW, 10.0, PH - 4.0))], "bore.tread", "tread")
    for y, z, r in [(19.5, 11.0, 5.0)] + [(30.0 + 13.6 * k, 7.5, 6.0) for k in range(5)] + [(P1 - 9.0, 15.0, 6.2)]:
        b.prism("x", out + sx * 0.7, sy * y, z, r, 2.6, "steel.dark", 8, "road_wheel", phase=math.pi / 8)
        b.prism("x", out + sx * 1.2, sy * y, z, r * 0.42, 3.4, "steel.plate", 6, "wheel_hub")
    loft([(P0 + 2.0, _chamfered(cx, PW + 4.0, PH - 0.5, top, 2.2)), (P1 - 24.0, _chamfered(cx, PW + 4.0, PH - 0.5, top, 2.2)),
          (P1 - 5.0, _chamfered(cx, PW + 4.0, PH - 4.5, PH + 0.5, 2.2))], "steel.plate", "panel")
    box(cx + sx * 4.0, cx + sx * 13.0, P0 + 8.0, P0 + 19.0, top, top + 0.9, "steel.panel", "panel_hatch")
    for ya, yb in ((26.0, 47.0), (50.0, 71.0), (74.0, P1 - 16.0)):
        if where == "flank" and ya == 50.0:
            continue   # the sponson hangs where the middle skirt did
        box(out + sx * 0.4, out + sx * 3.2, ya, yb, 13.5, top - 1.5, "livery.livery2", "skirt")
    for y in (P0 + 24.0, P0 + 66.0):
        b.prism("x", sx * 37.0, sy * y, 17.0, 5.5, 14.0, "steel.dark", 8, "arm", phase=math.pi / 8)
    if front:
        lx = cx - sx * 14.0
        box(lx - 3.5, lx + 3.5, P1 - 23.5, P1 - 18.0, top - 1.5, top + 4.0, "steel.dark", "lamp_housing")
        box(lx - 2.6, lx + 2.6, P1 - 18.0, P1 - 17.4, top - 0.4, top + 3.0, "amber.light", "lamp")
    if where != "panel":
        # A clean plate: the hazard tip across it and a bolted access plate where round one's gimbal stood.
        box(cx - PW / 2.0 + 0.4, cx + PW / 2.0 - 0.4, 73.0, 81.0, top, top + 0.5, "steel.stripe", "panel_tip")
        box(cx - 9.0, cx + 9.0, 50.0, 66.0, top, top + 0.6, "steel.panel", "panel_plate")
    if where is None:
        return
    pin, shape, carries = mount
    if where == "flank":
        # The sponson: a casemate box on the outer flank, its nose raked, a port in its face.
        deep = 13.0
        z0, z1 = (7.0, 22.0) if front else (18.5, 33.5)
        sxc = out + sx * (0.4 + deep / 2.0)
        ya, yb = sorted((sy * 47.0, sy * 73.0))          # world y; the face that fires is the +y end
        b.loft([(ya, _chamfered(sxc, deep - 3.0, z0 + 2.0, z1 - 2.0, 2.0)), (ya + 4.0, _chamfered(sxc, deep, z0, z1, 2.5)),
                (yb - 4.0, _chamfered(sxc, deep, z0, z1, 2.5)), (yb, _chamfered(sxc, deep - 1.0, z0 + 0.8, z1 - 0.8, 2.0))], "steel.panel", "sponson")
        b.box(min(sxc - sx * (deep / 2.0 + 0.5), sxc + sx * (deep / 2.0 + 0.5)), max(sxc - sx * (deep / 2.0 + 0.5), sxc + sx * (deep / 2.0 + 0.5)),
              ya + 7.0, ya + 11.0, z0 - 0.3, z1 - 2.2, "steel.stripe", "sponson_band")
        zc = (z0 + z1) / 2.0 - 0.6
        _port(b, (sxc, yb, zc), 5.1)
        b.stock(pin, (sxc, yb + 0.2, zc), shape, carries=carries, fits=PORT)
    elif front:
        # The hood: a low armoured box at the panel's outer front corner, a gun out of its face,
        # all of it under the front guns' sweep (their barrels' undersides stand at 40.4).
        hx = cx + sx * 12.0
        b.loft([(60.0, _chamfered(hx, 13.0, top - 0.2, top + 5.6, 2.0)), (66.0, _chamfered(hx, 15.0, top - 0.2, top + 7.4, 2.4)),
                (82.0, _chamfered(hx, 15.0, top - 0.2, top + 7.4, 2.4)), (85.0, _chamfered(hx, 13.0, top - 0.2, top + 6.6, 2.0))], "steel.panel", "hood")
        b.box(hx - 7.8, hx + 7.8, 68.0, 72.0, top - 0.2, top + 5.2, "steel.stripe", "hood_band")
        box(cx - sx * (PW / 2.0 - 0.4), cx + sx * 3.0, 73.0, 81.0, top, top + 0.5, "steel.stripe", "panel_tip")   # the tip across the panel's inner part, beside the hood
        _port(b, (hx, 85.0, top + 3.6), 3.5, depth=1.0)
        b.stock(pin, (hx, 85.2, top + 3.6), shape, carries=carries, fits=HOOD)
    else:
        # The cradle: a wedge at the panel's outer rear corner, canted so what sits in it lofts
        # over the tank; nothing sweeps over a rear panel, so a class sits here at its own size.
        hx = cx + sx * 11.0
        y0, y1 = -80.0, -62.0
        b.loft([(y0, [(hx - 9.0, top - 0.2), (hx + 9.0, top - 0.2), (hx + 9.0, top + 1.2), (hx - 9.0, top + 1.2)]),
                (y1, [(hx - 9.0, top - 0.2), (hx + 9.0, top - 0.2), (hx + 9.0, top + 7.0), (hx - 9.0, top + 7.0)])], "steel.panel", "cradle")
        for s in (-1.0, 1.0):
            b.box(hx + s * 9.0 - 0.8, hx + s * 9.0 + 0.8, y0 + 1.0, y1 + 0.6, top - 0.2, top + 9.5, "steel.stripe", "cradle_cheek")
        box(cx - PW / 2.0 + 0.4, cx + PW / 2.0 - 0.4, 50.0, 58.0, top, top + 0.5, "steel.stripe", "panel_tip")
        cant = math.radians(18.0)
        fwd = (0.0, math.cos(cant), math.sin(cant))
        b.stock(pin, (hx, -72.0, top + 4.2 + 7.4), shape, forward=fwd, carries=carries)


def _turret2(b, name, ty, deck, bar=True, antenna=False):
    """Round two's main turret, round one's a little flatter. `bar` gives it the rangefinder's bar
    and tall ears; without, its roof stays low and bare where the rear guns lie over it (the
    cupola and the sight set outboard of them, its ears cut down)."""
    zb = deck + 2.0
    top = zb + TH2
    zc = zb + 9.0
    b.prism("z", 0.0, ty, deck + 1.0, 31.5, 2.0, "steel.dark", 12, "turret_ring")
    with b.joint("turret_%s" % name, (0.0, ty, zb), axis="yaw", limits=(-135.0, 135.0)):
        b.loft([(ty - 31.0, _chamfered(0.0, 38.0, zb, zb + 12.5, 4.0)), (ty - 19.0, _chamfered(0.0, 62.0, zb, top, 6.5)),
                (ty + 12.0, _chamfered(0.0, 62.0, zb, top, 6.5)), (ty + 30.0, _chamfered(0.0, 46.0, zb + 1.0, zb + 16.0, 4.0))],
               "steel.panel", "turret_house")
        for s in (-1.0, 1.0):
            b.box(min(s * 31.0, s * 33.2), max(s * 31.0, s * 33.2), ty - 15.0, ty + 8.0, zb + 2.0, zb + 11.0, "livery.livery2", "turret_cheek")
        b.box(-13.0, 13.0, ty - 31.8, ty - 31.0, zb + 3.0, zb + 10.0, "steel.vent", "bustle_vent")
        with b.joint("elev_%s" % name, (0.0, ty + 30.0, zc), axis="pitch", limits=(0.0, 22.0)):
            b.box(-21.0, 21.0, ty + 29.0, ty + 36.0, zc - 7.5, zc + 7.0, "steel.plate", "mantlet")
            for s in (-1.0, 1.0):
                x = s * 11.5
                b.prism("y", x, ty + 43.0, zc, 7.2, 14.0, "steel.plate", 8, "gun_sleeve", phase=math.pi / 8)
                b.prism("y", x, ty + 74.0, zc, 5.6, 48.0, "steel.dark", 8, "gun_barrel", phase=math.pi / 8)
                b.prism("y", x, ty + 66.0, zc, 7.0, 11.0, "steel.plate", 8, "gun_extractor", phase=math.pi / 8)
                _tube(b, (x, ty + 97.0, zc), (x, ty + 109.0, zc), 7.6, 4.6, 8, "steel.plate", "gun_brake", phase=math.pi / 8)
        b.box(-20.0, -9.0, ty - 12.0, ty - 1.0, top, top + 1.0, "steel.plate", "hatch")
        b.prism("z", 24.0, ty - 6.0, top + 1.6, 5.2, 3.2, "steel.plate", 8, "cupola", phase=math.pi / 8)
        b.prism("z", 24.0, ty - 6.0, top + 2.0, 5.6, 1.2, "glass.glass", 8, "cupola_glass", phase=math.pi / 8)
        b.box(-28.0, -21.0, ty + 3.0, ty + 10.0, top, top + 3.2, "steel.dark", "sight_box")
        b.box(-27.2, -21.8, ty + 10.0, ty + 10.6, top + 0.6, top + 2.6, "amber.light", "sight")
        ear = 5.4 if bar else 3.2
        if bar:
            b.prism("x", 0.0, ty - 15.0, top + 2.4, 2.6, 76.0, "steel.dark", 6, "rangefinder")
        for s in (-1.0, 1.0):
            b.box(min(s * 35.0, s * 41.0), max(s * 35.0, s * 41.0), ty - 18.5, ty - 11.5, top - 0.6 - (0.0 if bar else 2.6), top + ear, "steel.plate", "rangefinder_ear")
            b.box(min(s * 36.2, s * 39.8), max(s * 36.2, s * 39.8), ty - 11.5, ty - 10.9, top + ear - 4.6, top + ear - 1.2, "amber.light", "rangefinder_lens")
            if not bar:
                b.box(min(s * 30.0, s * 35.5), max(s * 30.0, s * 35.5), ty - 17.0, ty - 13.0, top - 3.0, top - 0.4, "steel.dark", "ear_arm")
        if antenna:
            b.prism("z", -14.0, ty - 27.0, zb + 26.0, 0.55, 26.0, "steel.dark", 4, "antenna")


def _tank2(b, where):
    """Round two's H-tank, the hull down between its treads, its four hardpoints fixed and off
    the tops of the panels: `where` is "flank" (a sponson on each pod's outer flank), "panel"
    (low on the panels, at the plan's outer corners) or "hull" (a port in each corner of the bow,
    a casemate on each shoulder of the high deck)."""
    on_pods = where in ("flank", "panel")
    for (sx, sy), mount in zip(((-1.0, 1.0), (1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)), MOUNTS):
        _pod2(b, sx, sy, where if on_pods else None, mount)
    # The hull: the low deck a lip over the panels, a blunt nose between the front pods; the
    # high deck a turret's height above it, its tail falling to the engine's grille.
    g0, g1 = TF + 32.0, TF + 50.0
    b.loft([(STEP - 2.0, _chamfered(0.0, 64.0, 12.0, F2, 4.0)), (g0, _chamfered(0.0, 64.0, 12.0, F2, 4.0)),
            (g1, _chamfered(0.0, 58.0, 15.0, 29.0, 3.0))], "steel.panel", "hull_front")
    tail = TR - 39.0
    b.loft([(tail - 6.0, _chamfered(0.0, 62.0, 16.0, R2 - 7.0, 6.0)), (tail, _chamfered(0.0, 68.0, 12.0, R2, 6.0)),
            (STEP - 8.0, _chamfered(0.0, 68.0, 12.0, R2, 6.0)), (STEP, _chamfered(0.0, 66.0, 12.0, F2 + 1.0, 5.0))], "steel.panel", "hull_rear")
    # The nose plate: the crew's visor across its top, a tow bar under it, and either the
    # driving lamps or, with the mounts in the hull, a port in each corner.
    b.box(-11.0, 11.0, g1 - 0.2, g1 + 0.5, 24.0, 27.4, "glass.glass", "visor")
    b.box(-10.0, 10.0, g1, g1 + 3.5, 15.5, 18.5, "steel.dark", "tow_bar")
    fall = (F2 - 29.0) / (g1 - g0)
    glacis = lambda y: F2 - (y - g0) * fall
    _slab(b, [(-17.0, g0 + 3.0, glacis(g0 + 3.0)), (17.0, g0 + 3.0, glacis(g0 + 3.0)), (17.0, g0 + 14.0, glacis(g0 + 14.0)), (-17.0, g0 + 14.0, glacis(g0 + 14.0))],
          (0.0, fall, 1.0), 0.8, "livery.livery2", "glacis_panel")
    for k, s in enumerate((-1.0, 1.0)):
        if where == "hull":
            pin, shape, carries = MOUNTS[k]
            _port(b, (s * 20.5, g1, 22.0), 5.1)
            b.stock(pin, (s * 20.5, g1 + 0.2, 22.0), shape, carries=carries, fits=PORT)
        else:
            b.box(min(s * 16.0, s * 25.0), max(s * 16.0, s * 25.0), g1 - 0.5, g1 + 0.6, 18.5, 26.0, "steel.dark", "lamp_housing")
            b.box(min(s * 17.0, s * 24.0), max(s * 17.0, s * 24.0), g1 + 0.6, g1 + 1.2, 19.5, 25.0, "amber.light", "lamp")
    # The high deck's flanks: applique in the livery, a ladder up each side, and with the mounts
    # in the hull a casemate on each shoulder, over the gap to the rear pod, firing forward past
    # the front turret's cheek.
    for k, s in enumerate((-1.0, 1.0)):
        b.box(min(s * 34.0, s * 36.6), max(s * 34.0, s * 36.6), tail + 4.0, tail + 28.0, 36.0, R2 - 8.0, "livery.livery2", "applique")
        if where == "hull":
            pin, shape, carries = MOUNTS[2 + k]
            cxc = s * 39.5
            b.loft([(-46.0, _chamfered(cxc, 9.0, 34.5, R2 - 7.0, 2.0)), (-42.0, _chamfered(cxc, 13.0, 33.0, R2 - 4.0, 3.0)),
                    (-16.0, _chamfered(cxc, 13.0, 33.0, R2 - 4.0, 3.0)), (-12.0, _chamfered(cxc, 12.0, 33.8, R2 - 5.0, 2.6))], "steel.panel", "casemate")
            b.box(min(cxc - s * 7.0, cxc + s * 7.0), max(cxc - s * 7.0, cxc + s * 7.0), -38.0, -34.0, 32.8, R2 - 6.8, "steel.stripe", "casemate_band")
            _port(b, (cxc, -12.0, 41.0), 5.1)
            b.stock(pin, (cxc, -11.8, 41.0), shape, carries=carries, fits=PORT)
            b.box(min(s * 34.0, s * 34.9), max(s * 34.0, s * 34.9), tail + 31.0, tail + 37.0, 32.0, R2 - 6.0, "steel.ladder", "ladder")
        else:
            b.box(min(s * 34.0, s * 36.6), max(s * 34.0, s * 36.6), tail + 32.0, -28.0, 36.0, R2 - 8.0, "livery.livery2", "applique")
            b.box(min(s * 34.0, s * 34.9), max(s * 34.0, s * 34.9), -25.0, -17.0, 32.0, R2 - 6.0, "steel.ladder", "ladder")
    # The tail: the engine's grille across the back, a stack on each corner of the high deck.
    b.box(-22.0, 22.0, tail - 7.0, tail - 6.0, 22.0, R2 - 12.0, "steel.vent", "rear_vents")
    for s in (-1.0, 1.0):
        b.prism("z", s * 29.5, tail + 3.5, R2 + 1.0, 3.6, 14.0, "steel.dark", 6, "stack")
        b.prism("z", s * 29.5, tail + 3.5, R2 + 8.8, 4.5, 1.6, "steel.plate", 6, "stack_cap")
    # The two main turrets: the front one's roof low and bare under the rear one's guns.
    _turret2(b, "front", TF, F2, bar=False)
    _turret2(b, "rear", TR, R2, bar=True, antenna=True)
    b.pivots = True
    b.move(accel=0.6, heft=0.1)


def mnlook_siege2_a(b):
    """Round two, A: a sponson on each pod's outer flank."""
    _tank2(b, "flank")


def mnlook_siege2_b(b):
    """Round two, B: fixed and low on the panels, at the plan's four outer corners."""
    _tank2(b, "panel")


def mnlook_siege2_c(b):
    """Round two, C: in the hull, the bow's corners and the high deck's shoulders."""
    _tank2(b, "hull")


def _beside(b, build):
    """A battery with the game's own Wild Boar off its right bow at one scale (round one's way)."""
    import models_low
    build(b)
    other = type(b)("beside", b.tiles)
    other.materials = b.materials
    models_low.wild_boar(other)
    shift = Matrix.Translation((176.0, 34.0, 0.0))
    for ob in other.objects + other.pins:
        if ob.parent is None:
            ob.matrix_world = shift @ ob.matrix_world
    for e in other.pins:
        if e.name.startswith("hp_"):
            e.name = "beside_" + e.name


def mnlook_siege2_beside(b):
    """Round two's tank beside the Wild Boar, to scale."""
    _beside(b, mnlook_siege2_b)


for _fn in (mnlook_siege2_a, mnlook_siege2_b, mnlook_siege2_c, mnlook_siege2_beside):
    _fn.maker = MN

LOOKS = ["mnlook_siege", "mnlook_siege_posed", "mnlook_siege_beside",
         "mnlook_siege2_a", "mnlook_siege2_b", "mnlook_siege2_c", "mnlook_siege2_beside"]

SHEET = {
    "title": "The siege battery, first round, 15 November (look tests, not content)",
    "out": "docs/looks/minerva_siege.png",
    "cell": (400, 400),
    "rows": [
        {"model": "mnlook_siege", "label": "The H-tank", "views": ["codex", "above", "skirmish"]},
        {"model": "mnlook_siege", "label": "The H-tank", "views": [("from the side", 90.0, 8.0), "front", "rear"]},
        {"model": "mnlook_siege_posed", "label": "Trained to port", "views": ["codex", "above", "front"]},
        {"model": "mnlook_siege_beside", "label": "Beside the Wild Boar, to scale", "views": ["codex", "above", "front"]},
    ],
}

_VIEWS2 = ["codex", "above", "side", "front"]
SHEET2 = {
    "title": "The siege battery, second round, 15 November (look tests, not content)",
    "out": "docs/looks/minerva_siege2.png",
    "cell": (380, 380),
    "rows": [
        {"model": "mnlook_siege2_a", "label": "A, mounts on the pods' flanks", "views": _VIEWS2},
        {"model": "mnlook_siege2_b", "label": "B, mounts fixed low on the panels", "views": _VIEWS2},
        {"model": "mnlook_siege2_c", "label": "C, mounts in the hull", "views": _VIEWS2},
        {"model": "mnlook_siege2_beside", "label": "B beside the Wild Boar, to scale", "views": ["codex", "above", "front"]},
        {"model": "mnlook_siege", "label": "Round one, for the height", "views": ["side", "front"]},
    ],
}

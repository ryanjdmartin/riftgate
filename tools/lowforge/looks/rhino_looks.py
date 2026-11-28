"""Look tests for the White Rhino (Minerva, tier one, the lure tank: docs/briefs/minerva_lure_tank.md),
on Ryan's notes of 27 November: "I think we should try a half-track for this one, it's not a
silhouette we have yet, right? I can't tell looks without seeing them, so I'll need mock ups";
"Make sure that the model isn't too on the nose for rhino, as with all models. It's tempting to
slap a huge horn on there as a defining feature, when the kit doesn't actually use one. We'll want
a drone model, too"; and of its lock, "it can be the 'horn' such as it is on the model".

So every look is a half-track (steered wheels forward under armoured wings, a track unit under
each side of the rear body), nicknamed for how it acts and never drawn as the animal: the rhino
reads in the mass and the lowered front, and its two kit pieces are its features. The lock's
projector stands where a horn would, a blunt squared emitter with coil collars down it and a lit
tip, its field the lock's; the Drone (its passive, a small ducted-fan spotter) rides a cradle,
the oxpecker on the rhino's back. Three ways to carry them:

    mnlook_rhino_a   the long head: a long armoured bonnet over the front axle, the projector off
                     the bonnet's tip angled up and forward, a cab under a brow, the rear body
                     over the tracks with a raised deck and the Drone's cradle on it
    mnlook_rhino_b   the shoulder: a short bonnet and a high armoured hump over the cab, the
                     projector on the hump's brow, the Drone perched on the hump's crest
    mnlook_rhino_c   the low ram: cab forward over the wheels, a flat armoured face, the
                     projector low between the wheels like a ram, a tall boxy body behind with
                     overlapping skirts down the tracks, the Drone on a post at the rear corner
    mnlook_rhino_drone   the Drone alone, enlarged: a ducted fan in a ring, a pod under it with a
                     lit lens and a stun prong at the nose, two grip legs to perch on a Sprite

Each wears its three hardpoints as placeholders, the stock's classes: hp_1 a barrel (the Rivet
Gun), hp_2 a rack (the Ankle Mortar), hp_3 a bare mount (the Shoring Jack). Minerva's steel and
green, nothing white: the white is in the name. Not content: built only by build_look.py and
sheet.py. x right, y forward, z up, the ground at z = 0.
"""

import math

from bl_low import rect
from models_low import _beam, _chamfered, _minerva_vents, _poly, _spike, _sq, _wheel

MN = "minerva"
FIELD = "amber.tesla"   # the projector's lit tip, a placeholder for the field's colour (gameplay information: checked when built)
LENS = "amber.lit"


def _lerp(p0, p1, t):
    return tuple(a + (b - a) * t for a, b in zip(p0, p1))


def _horn(b, base, tip, w0, w1):
    """The lock's projector: a blunt squared emitter from `base` to `tip`, tapering from `w0` to
    `w1` across, three coil collars down its length and a lit tip, its field's mouth."""
    _beam(b, base, _lerp(base, tip, 0.9), _sq(w0, w0), _sq(w1, w1), "steel.plate", "projector")
    for t, k in ((0.28, 1.18), (0.48, 1.16), (0.68, 1.14)):
        w = w0 + (w1 - w0) * t
        _beam(b, _lerp(base, tip, t - 0.05), _lerp(base, tip, t + 0.05), _sq(w * k, w * k), _sq(w * k, w * k), "steel.dark", "projector_coil")
    _beam(b, _lerp(base, tip, 0.88), tip, _sq(w1 * 1.35, w1 * 1.35), _sq(w1 * 0.9, w1 * 0.9), "steel.dark", "projector_mouth")
    _beam(b, _lerp(base, tip, 0.93), _lerp(base, tip, 1.02), _sq(w1 * 0.8, w1 * 0.8), _sq(w1 * 0.6, w1 * 0.6), FIELD, "projector_field")


def _duct(b, cx, cy, zr, R, k, tag=""):
    """A ducted fan: a hollow eight-sided green band of radius `R` at height `zr`, its floor
    dark, the fan's hub and three blades inside it."""
    n = 8
    for i in range(n):
        a0, a1 = 2.0 * math.pi * i / n + math.pi / 8, 2.0 * math.pi * (i + 1) / n + math.pi / 8
        p0 = (cx + R * math.cos(a0), cy + R * math.sin(a0), zr)
        p1 = (cx + R * math.cos(a1), cy + R * math.sin(a1), zr)
        _beam(b, p0, p1, _sq(0.9 * k, 1.5 * k), _sq(0.9 * k, 1.5 * k), "livery.livery2", "drone_ring" + tag)
    b.prism("z", cx, cy, zr - 0.6 * k, R - 0.4 * k, 0.3 * k, "bore.dark", 8, "drone_duct" + tag, phase=math.pi / 8)
    b.prism("z", cx, cy, zr, 1.0 * k, 1.4 * k, "steel.dark", 6, "drone_hub" + tag)
    for a in (0.3, 0.3 + math.pi * 2 / 3, 0.3 + math.pi * 4 / 3):
        dx, dy = math.cos(a) * (R - 0.8 * k), math.sin(a) * (R - 0.8 * k)
        _beam(b, (cx, cy, zr + 0.2 * k), (cx + dx, cy + dy, zr + 0.2 * k), _sq(1.0 * k, 0.25 * k), _sq(0.7 * k, 0.2 * k), "steel.plate", "drone_blade" + tag)


def _drone_body(b, P, k, pod_back=-3.0, pod_front=3.6):
    """The Drone's pod hung under its fans, forward to a lit lens and a stun prong, a tail fin, and
    two grip legs splayed under it to perch on. `P` maps the Drone's own (x, y, z) to the world."""
    _beam(b, P(0.0, pod_back, -1.6), P(0.0, pod_front, -1.9), _sq(2.6 * k, 2.0 * k), _sq(2.2 * k, 1.8 * k), "steel.panel", "drone_pod")
    _beam(b, P(0.0, pod_front, -1.9), P(0.0, pod_front + 1.8, -2.0), _sq(2.2 * k, 1.8 * k), _sq(1.4 * k, 1.2 * k), "steel.dark", "drone_nose")
    _beam(b, P(0.0, pod_front + 1.7, -1.9), P(0.0, pod_front + 2.3, -1.9), _sq(0.9 * k, 0.9 * k), _sq(0.8 * k, 0.8 * k), LENS, "drone_lens")
    _spike(b, P(0.0, pod_front + 1.0, -2.8), P(0.0, pod_front + 3.6, -3.6), 0.28 * k, "steel.dark", "drone_prong")
    _beam(b, P(0.0, pod_back, -1.2), P(0.0, pod_back - 1.4, 0.6), _sq(0.4 * k, 1.4 * k), _sq(0.3 * k, 0.8 * k), "steel.plate", "drone_fin")
    for s in (-1.0, 1.0):
        _beam(b, P(s * 0.9, 0.4, -2.4), P(s * 2.0, 0.9, -5.0), _sq(0.5 * k, 0.5 * k), _sq(0.4 * k, 0.4 * k), "steel.dark", "drone_leg")
        fx, fy, fz = P(s * 2.0, 0.9, -5.0)
        b.box(fx - 0.5 * k, fx + 0.5 * k, fy - 0.9 * k, fy + 1.1 * k, fz - 0.2 * k, fz + 0.2 * k, "steel.dark", "drone_foot")


def _drone_twin(b, o, k=1.0, layout="side"):
    """The Drone with twinned fans: two smaller ducts side by side on a bridge over the pod
    (`layout` "side"), or one ahead of the other along a longer pod ("tandem"), the same pod,
    lens, prong, fin and legs under them."""
    ox, oy, oz = o
    zr = oz + 5.2 * k

    def P(x, y, z):
        return (ox + x * k, oy + y * k, zr + z * k)

    R = 3.0 * k
    if layout == "side":
        for s, t in ((-1.0, "_l"), (1.0, "_r")):
            _duct(b, ox + s * 3.5 * k, oy, zr, R, k, t)
        _beam(b, P(-2.2, 0.0, -0.4), P(2.2, 0.0, -0.4), _sq(1.6 * k, 1.0 * k), _sq(1.6 * k, 1.0 * k), "steel.plate", "drone_bridge")
        _drone_body(b, P, k)
    else:
        for y, t in ((3.4, "_f"), (-3.4, "_b")):
            _duct(b, ox, oy + y * k, zr, R, k, t)
        _drone_body(b, P, k, pod_back=-5.2, pod_front=4.4)


def _drone(b, o, k=1.0):
    """The Drone at `o` (its feet's height is o's z), `k` its scale: a horizontal ducted fan in
    a green ring, a pod hung under the ring running forward to a lit lens, a stun prong under the
    nose, a small tail fin, and two grip legs splayed under the pod to perch on."""
    ox, oy, oz = o
    zr = oz + 5.2 * k   # the ring's height over the feet

    def P(x, y, z):
        return (ox + x * k, oy + y * k, zr + z * k)

    _duct(b, ox, oy, zr, 4.3 * k, k)
    _drone_body(b, P, k)


def _cradle(b, cx, cy, z, k=1.0, drone="single"):
    """The Drone's cradle: a low frame of two rails on short posts, the Drone standing on it."""
    for s in (-1.0, 1.0):
        b.box(cx + s * 2.0 * k - 0.6, cx + s * 2.0 * k + 0.6, cy - 3.0 * k, cy + 3.0 * k, z, z + 1.0, "steel.dark", "cradle_rail")
        b.box(cx + s * 2.0 * k - 0.5, cx + s * 2.0 * k + 0.5, cy - 0.5, cy + 0.5, z - 2.0, z, "steel.dark", "cradle_post")
    if drone == "single":
        _drone(b, (cx, cy, z + 1.0), k)
    else:
        _drone_twin(b, (cx, cy, z + 1.0), k, drone)


def _running_gear(b, ty0, ty1, tx, tw, th, wy, wr, ww, wx):
    """The half-track: a track unit under each side of the rear body from `ty0` to `ty1` (its
    centre `tx` out, `tw` wide, `th` tall, the front run climbing to its sprocket), road wheels
    showing on its face; the steered front axle at `wy`, two heavy wheels of radius `wr` and
    width `ww` at `wx` out."""
    for s in (-1.0, 1.0):
        cx = s * tx
        b.loft([(ty0, rect(cx, tw, 5.0, th - 5.0)), (ty0 + 6.0, rect(cx, tw, 0.0, th)), (ty1 - 8.0, rect(cx, tw, 0.0, th)),
                (ty1, rect(cx, tw, 6.0, th - 2.0))], "bore.tread", "tread")
        n = 4
        for i in range(n):
            y = ty0 + 9.0 + i * (ty1 - ty0 - 18.0) / (n - 1)
            b.prism("x", cx + s * (tw / 2.0 + 0.2), y, 6.5, 4.4, 1.2, "steel.dark", 8, "road_wheel", phase=math.pi / 8)
    b.box(-wx, wx, wy - 1.5, wy + 1.5, wr - 1.5, wr + 1.5, "steel.dark", "axle")
    for s in (-1.0, 1.0):
        _wheel(b, s * wx, wy, wr, ww, "wheel_front")


def _wing(b, s, x, w, wy, wr, z_top, front, back):
    """An armoured wing over a front wheel: a plate arched over the tyre's top from `back` to
    `front`, its outer edge dropping to the hub's height so the tyre's foot shows."""
    b.loft([(back, rect(x, w, wr + 1.0, z_top - 3.0)), (wy - wr * 0.55, rect(x, w, z_top - 0.5, z_top + 1.5)),
            (wy + wr * 0.55, rect(x, w, z_top - 0.5, z_top + 1.5)), (front, rect(x, w, wr + 1.0, z_top - 3.0))], "steel.plate", "wing")


def mnlook_rhino_a(b, drone="single"):
    """The long head: a long armoured bonnet over the front axle, the projector off its tip angled
    up and forward, a cab under a brow, the rear body over the tracks with a raised deck at the
    tail and the Drone's cradle on it."""
    _running_gear(b, -44.0, 4.0, 22.0, 16.0, 19.0, 30.0, 12.0, 11.0, 24.5)
    for s in (-1.0, 1.0):
        _wing(b, s, s * 24.5, 13.0, 30.0, 12.0, 25.0, 42.0, 16.0)
        b.box(min(s * 13.0, s * 30.5), max(s * 13.0, s * 30.5), -42.0, 2.0, 18.5, 21.0, "steel.plate", "skirt")
        b.box(min(s * 28.5, s * 31.0), max(s * 28.5, s * 31.0), -40.0, -2.0, 9.0, 19.0, "livery.livery2", "skirt_plate")
    # The frame, the rear body over the tracks and its raised deck at the tail.
    b.loft([(-42.0, rect(0.0, 28.0, 8.0, 17.0)), (14.0, rect(0.0, 28.0, 8.0, 17.0)), (42.0, rect(0.0, 18.0, 9.0, 15.0))], "steel.dark", "frame")
    b.loft([(-44.0, _chamfered(0.0, 42.0, 17.0, 28.0, 3.0)), (-38.0, _chamfered(0.0, 50.0, 16.0, 31.0, 4.0)), (2.0, _chamfered(0.0, 50.0, 16.0, 31.0, 4.0))], "steel.panel", "body")
    b.loft([(-44.5, _chamfered(0.0, 40.0, 27.0, 32.0, 3.0)), (-40.0, _chamfered(0.0, 44.0, 28.0, 33.5, 4.0)), (-18.0, _chamfered(0.0, 44.0, 28.0, 33.5, 4.0)), (-14.0, _chamfered(0.0, 40.0, 28.0, 31.0, 2.0))], "livery.livery2", "deck")
    wall = b.loft([(-45.5, rect(0.0, 40.0, 17.0, 31.0)), (-41.0, rect(0.0, 40.0, 17.0, 31.0))], "steel.panel", "rear_wall")
    _minerva_vents(b, [wall], (-10.0, 10.0), -45.5, 24.0, width=14.0, height=10.0, slats=4)
    # The cab: the high point, its shoulders broad, a raked slit under a brow.
    b.loft([(-2.0, _chamfered(0.0, 48.0, 16.0, 39.0, 7.0)), (10.0, _chamfered(0.0, 46.0, 16.0, 41.0, 7.0)), (17.0, _chamfered(0.0, 42.0, 15.0, 30.0, 5.0))], "livery.livery2", "cab")
    b.loft([(11.6, rect(0.0, 28.0, 33.0, 37.4)), (16.4, rect(0.0, 27.0, 28.0, 31.6))], "glass.glass", "slit")
    b.loft([(8.0, rect(0.0, 40.0, 40.0, 42.5)), (14.0, rect(0.0, 38.0, 38.5, 40.5))], "steel.plate", "brow")
    # The bonnet: long, lowered toward the nose, a grille on its face.
    b.loft([(17.0, _chamfered(0.0, 34.0, 12.0, 28.0, 4.0)), (30.0, _chamfered(0.0, 30.0, 11.0, 25.0, 4.0)), (42.0, _chamfered(0.0, 24.0, 11.0, 21.0, 3.0)), (46.0, _chamfered(0.0, 20.0, 12.0, 19.0, 2.0))], "steel.panel", "bonnet")
    b.box(-8.0, 8.0, 45.6, 46.6, 13.0, 17.5, "steel.vent", "grille")
    for s in (-1.0, 1.0):
        b.box(s * 7.5 - 1.6, s * 7.5 + 1.6, 45.8, 47.0, 17.8, 19.2, "amber.light", "lamp")
    b.box(-26.0, 26.0, 44.0, 46.5, 7.0, 11.0, "steel.dark", "bumper")
    _horn(b, (0.0, 40.0, 20.5), (0.0, 57.0, 31.0), 7.0, 4.2)
    # Mounts: the gun on a ring on the rear deck, a rack and a bare mount on the body's flanks;
    # the Drone rides the cab's roof, behind the brow.
    b.prism("z", 0.0, -29.0, 33.9, 6.5, 1.2, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, -29.0, 34.5)):
        b.prism("z", 0.0, -29.0, 36.5, 5.5, 4.0, "steel.plate", 8, "pulpit", phase=math.pi / 8)
        b.stock("hp_1", (0.0, -25.5, 36.7), "barrel", scale=0.85, carries="rivet_gun")
    b.stock("hp_2", (-27.0, -8.0, 31.5), "rack", scale=0.7, carries="ankle_mortar")
    b.pad("hp_3", (27.0, -8.0, 31.5), size=(7.0, 1.0))
    _cradle(b, 0.0, 2.0, 41.0, 1.4, drone)


mnlook_rhino_a.maker = MN


def mnlook_rhino_b(b, drone="single"):
    """The shoulder: a short bonnet and a high armoured hump over the cab, the projector on the
    hump's brow, the Drone perched on the hump's crest behind it."""
    _running_gear(b, -44.0, 2.0, 22.0, 16.0, 19.0, 26.0, 12.0, 11.0, 24.5)
    for s in (-1.0, 1.0):
        _wing(b, s, s * 24.5, 13.0, 26.0, 12.0, 25.0, 38.0, 12.0)
        b.box(min(s * 13.0, s * 30.5), max(s * 13.0, s * 30.5), -42.0, 0.0, 18.5, 21.0, "steel.plate", "skirt")
    b.loft([(-42.0, rect(0.0, 28.0, 8.0, 17.0)), (12.0, rect(0.0, 28.0, 8.0, 17.0)), (36.0, rect(0.0, 18.0, 9.0, 15.0))], "steel.dark", "frame")
    # The rear body, low, over the tracks, the engine deck stepping down to the tail.
    b.loft([(-44.0, _chamfered(0.0, 44.0, 17.0, 26.0, 3.0)), (-38.0, _chamfered(0.0, 50.0, 16.0, 29.0, 4.0)), (-12.0, _chamfered(0.0, 50.0, 16.0, 31.0, 4.0))], "steel.panel", "body")
    wall = b.loft([(-45.0, rect(0.0, 40.0, 17.0, 27.0)), (-41.0, rect(0.0, 40.0, 17.0, 27.0))], "steel.panel", "rear_wall")
    _minerva_vents(b, [wall], (-10.0, 10.0), -45.0, 22.0, width=14.0, height=8.0, slats=3)
    # The hump: high over the cab and shoulders, chamfered, falling to the bonnet in front.
    b.loft([(-14.0, _chamfered(0.0, 50.0, 16.0, 33.0, 6.0)), (-6.0, _chamfered(0.0, 50.0, 16.0, 44.0, 10.0)), (6.0, _chamfered(0.0, 48.0, 16.0, 46.0, 11.0)),
            (14.0, _chamfered(0.0, 44.0, 15.0, 40.0, 9.0)), (19.0, _chamfered(0.0, 40.0, 14.0, 30.0, 6.0))], "livery.livery2", "hump")
    b.loft([(12.6, rect(0.0, 26.0, 31.5, 35.0)), (17.6, rect(0.0, 25.0, 27.0, 30.0))], "glass.glass", "slit")
    b.loft([(19.0, _chamfered(0.0, 30.0, 12.0, 26.0, 4.0)), (32.0, _chamfered(0.0, 24.0, 11.0, 21.0, 3.0)), (38.0, _chamfered(0.0, 20.0, 12.0, 18.0, 2.0))], "steel.panel", "bonnet")
    b.box(-7.0, 7.0, 37.6, 38.6, 13.0, 16.5, "steel.vent", "grille")
    b.box(-26.0, 26.0, 36.0, 38.5, 7.0, 11.0, "steel.dark", "bumper")
    for s in (-1.0, 1.0):
        b.box(s * 18.0 - 1.6, s * 18.0 + 1.6, 18.0, 19.2, 26.0, 28.0, "amber.light", "lamp")
    _horn(b, (0.0, 12.0, 41.0), (0.0, 30.0, 47.0), 7.5, 4.4)
    # Mounts: the gun on a ring on the rear deck, a rack on the hump's flank, a bare mount.
    b.prism("z", 0.0, -26.0, 29.4, 6.5, 1.2, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, -26.0, 30.0)):
        b.prism("z", 0.0, -26.0, 32.0, 5.5, 4.0, "steel.plate", 8, "pulpit", phase=math.pi / 8)
        b.stock("hp_1", (0.0, -22.5, 32.2), "barrel", scale=0.85, carries="rivet_gun")
    b.stock("hp_2", (-27.5, 0.0, 33.0), "rack", scale=0.7, carries="ankle_mortar")
    b.pad("hp_3", (27.5, 0.0, 33.0), size=(7.0, 1.0))
    _cradle(b, 0.0, -4.0, 46.5, 1.4, drone)


mnlook_rhino_b.maker = MN


def mnlook_rhino_c(b, drone="single"):
    """The low ram: the cab forward over the wheels with a flat armoured face, the projector low
    between the wheels like a ram, a tall boxy body behind with overlapping skirts down the tracks,
    the Drone on a post at the rear corner."""
    _running_gear(b, -44.0, 6.0, 22.0, 16.0, 19.0, 28.0, 12.0, 11.0, 25.0)
    for s in (-1.0, 1.0):
        _wing(b, s, s * 25.0, 13.0, 28.0, 12.0, 26.0, 40.0, 15.0)
        for i, (y0, y1) in enumerate(((-43.0, -27.0), (-30.0, -14.0), (-17.0, -1.0), (-4.0, 8.0))):
            xo = s * (30.4 + 0.5 * (i % 2))
            b.box(min(xo, xo + s * 1.3), max(xo, xo + s * 1.3), y0, y1, 8.0, 21.0, "livery.livery2" if i % 2 else "steel.plate", "skirt_plate")
    b.loft([(-42.0, rect(0.0, 28.0, 8.0, 17.0)), (38.0, rect(0.0, 24.0, 8.0, 16.0))], "steel.dark", "frame")
    # The tall body over the tracks and the cab forward of it, one block, a flat face.
    b.loft([(-45.0, _chamfered(0.0, 48.0, 16.0, 38.0, 5.0)), (14.0, _chamfered(0.0, 52.0, 16.0, 40.0, 6.0)), (22.0, _chamfered(0.0, 48.0, 14.0, 38.0, 6.0)),
            (36.0, _chamfered(0.0, 44.0, 13.0, 32.0, 6.0)), (40.0, _chamfered(0.0, 40.0, 13.0, 26.0, 4.0))], "steel.panel", "body")
    b.loft([(35.0, rect(0.0, 30.0, 27.0, 30.0)), (38.6, rect(0.0, 28.0, 23.5, 26.0))], "glass.glass", "slit")
    b.loft([(30.0, rect(0.0, 42.0, 31.5, 33.5)), (37.0, rect(0.0, 40.0, 30.5, 32.0))], "steel.plate", "brow")
    wall = b.loft([(-46.0, rect(0.0, 42.0, 17.0, 36.0)), (-42.0, rect(0.0, 42.0, 17.0, 36.0))], "steel.panel", "rear_wall")
    _minerva_vents(b, [wall], (-10.0, 10.0), -46.0, 27.0, width=14.0, height=12.0, slats=4)
    b.box(-28.0, 28.0, 39.0, 42.0, 7.0, 12.0, "steel.dark", "bumper")
    for s in (-1.0, 1.0):
        b.box(s * 17.0 - 1.8, s * 17.0 + 1.8, 39.8, 41.0, 18.0, 21.0, "amber.light", "lamp")
    _horn(b, (0.0, 39.0, 13.0), (0.0, 58.0, 18.5), 7.5, 4.5)
    # Mounts: the gun on a ring on the roof, a rack and a bare mount on the shoulders.
    b.prism("z", 0.0, -4.0, 40.4, 6.5, 1.2, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, -4.0, 41.0)):
        b.prism("z", 0.0, -4.0, 43.0, 5.5, 4.0, "steel.plate", 8, "pulpit", phase=math.pi / 8)
        b.stock("hp_1", (0.0, -0.5, 43.2), "barrel", scale=0.85, carries="rivet_gun")
    b.stock("hp_2", (-20.0, 18.0, 40.5), "rack", scale=0.7, carries="ankle_mortar")
    b.pad("hp_3", (20.0, 18.0, 40.5), size=(7.0, 1.0))
    # The Drone's post at the rear left corner.
    b.box(-21.0, -18.0, -41.0, -38.0, 38.0, 46.0, "steel.dark", "drone_post")
    _cradle(b, -19.5, -39.5, 48.0, 1.4, drone)


mnlook_rhino_c.maker = MN


def mnlook_rhino_drone(b):
    """The Drone alone, enlarged five times, standing on its own feet."""
    _drone(b, (0.0, 0.0, 0.0), 5.0)


mnlook_rhino_drone.maker = MN


def mnlook_rhino_drone2_side(b):
    """The Drone with twinned fans side by side, enlarged five times."""
    _drone_twin(b, (0.0, 0.0, 0.0), 5.0, "side")


mnlook_rhino_drone2_side.maker = MN


def mnlook_rhino_drone2_tandem(b):
    """The Drone with twinned fans in tandem, enlarged five times."""
    _drone_twin(b, (0.0, 0.0, 0.0), 5.0, "tandem")


mnlook_rhino_drone2_tandem.maker = MN


def mnlook_rhino_b_twin(b):
    """The shoulder (B) with the side-by-side twin on its crest, to see the Drone at the size it rides."""
    mnlook_rhino_b(b, drone="side")


mnlook_rhino_b_twin.maker = MN


def mnlook_rhino_a_tandem(b):
    """The long head (A) with the tandem Drone on its cab."""
    mnlook_rhino_a(b, drone="tandem")


mnlook_rhino_a_tandem.maker = MN


def mnlook_rhino_b_tandem(b):
    """The shoulder (B) with the tandem Drone on its crest."""
    mnlook_rhino_b(b, drone="tandem")


mnlook_rhino_b_tandem.maker = MN


def mnlook_rhino_c_tandem(b):
    """The low ram (C) with the tandem Drone on its post."""
    mnlook_rhino_c(b, drone="tandem")


mnlook_rhino_c_tandem.maker = MN


## Round two (28 November), on Ryan's read of the first three: "A and C are best starting shapes
## but they're all pretty rough. C at least looks like it could take a hit, but it's otherwise
## very plain. A has visual interest but looks flimsy, it has humvee heritage. The Polarity field
## emitter...thing should be a defining feature but all 3 of them look tacked on there...like a
## horn. There's no reason for it to be where it is, and when it's the entire identity, it needs
## to make an impact on the silhouette. Also gun placements on A and B don't work, at all. And
## the drone needs a real dock, it's an extension of the chassis so it should have a real home to
## either dock into, connect to, or a shielded bay to eject out of"; of the Drone, "very crude and
## flimsy looking ... rugged and durable enough to endure in a combat situation"; and its roots,
## "something like SWAT roots (or the future-tech equivalent)".
##
## So each hull is built round its emitter, each gun has a clear field forward, each Drone has a
## home in the hull, and each Drone is an armoured body with its fans sunk in it:
##
##     mnlook_rhino_d   the yoke (from C): the hull's front is a horseshoe magnet, two armoured
##                      pole arms over the front wheels with coil windings at their roots and lit
##                      shoes, a lit core in the throat between them; a shielded bay sunk in the
##                      rear roof, its lids stood open, the Drone in it
##     mnlook_rhino_e   the turret (from A, armoured): boxed wheel housings, a blunt bonnet and a
##                      push bar; the emitter is its turret, a coil drum and a flared dish on
##                      trunnions over the cab, and the Drone rides a saddle on the turret's bustle
##     mnlook_rhino_f   the plates (from C): two great raked plates stand down the rear deck, the
##                      field's two poles, and the Drone docks in the trench between them
##     mnlook_rhino_drone_brick    two fan wells in one armoured lozenge (the tandem, made solid)
##     mnlook_rhino_drone_shield   four wells in a slab behind a broad front plate
##     mnlook_rhino_drone_drum     one well in a deep armoured drum under a roll cage


def _slab_x(b, x0, x1, outline, material, label):
    """A plate cut to a side-view `outline` of (y, z) points and extruded across x."""
    ring = [(-y, z) for y, z in outline]
    area = sum(ring[i][0] * ring[(i + 1) % len(ring)][1] - ring[(i + 1) % len(ring)][0] * ring[i][1] for i in range(len(ring)))
    if area < 0.0:
        ring.reverse()
    return _beam(b, (x0, 0.0, 0.0), (x1, 0.0, 0.0), ring, ring, material, label)


def _leaf(b, y0, y1, hinge, tip, t, material, label):
    """A flat lid from y0 to y1, hinged along `hinge` (x, z) and stood open to `tip`, `t` thick."""
    (hx, hz), (tx, tz) = hinge, tip
    d = math.hypot(tx - hx, tz - hz)
    nx, nz = -(tz - hz) / d * t / 2.0, (tx - hx) / d * t / 2.0
    pts = [(hx + nx, hz + nz), (hx - nx, hz - nz), (tx - nx, tz - nz), (tx + nx, tz + nz)]
    cx, cz = sum(p[0] for p in pts) / 4.0, sum(p[1] for p in pts) / 4.0
    pts.sort(key=lambda p: math.atan2(p[1] - cz, p[0] - cx))
    return b.loft([(y0, pts), (y1, pts)], material, label)


def _housing(b, s, x, w, wy, wr, z_top, back, front):
    """A boxed armoured housing over a front wheel: a flat top, a guard dropped behind the tyre
    and one ahead of it, and a plate hung down its outer face over the tyre's upper half."""
    b.loft([(back, rect(x, w, wr + 2.5, z_top - 2.5)), (back + 4.0, rect(x, w, 2.0 * wr + 1.0, z_top)),
            (front - 5.0, rect(x, w, 2.0 * wr + 1.0, z_top)), (front, rect(x, w, wr + 3.5, z_top - 3.5))], "steel.plate", "housing")
    xo = x + s * (w / 2.0)
    b.box(min(xo, xo + s * 1.2), max(xo, xo + s * 1.2), back + 3.0, front - 4.0, wr + 4.5, z_top - 0.6, "livery.livery2", "housing_plate")


def _skirts(b, s, x, runs, z0=8.0, z1=21.0):
    """Overlapping skirt plates down a track's outer face, alternating steel and the livery."""
    for i, (y0, y1) in enumerate(runs):
        xo = s * (x + 0.5 * (i % 2))
        b.box(min(xo, xo + s * 1.3), max(xo, xo + s * 1.3), y0, y1, z0, z1, "livery.livery2" if i % 2 else "steel.plate", "skirt_plate")


def _pushbar(b, y, w, z0, z1):
    """A push bar ahead of the bumper: two posts and two rails, a breaching vehicle's."""
    for s in (-1.0, 1.0):
        b.box(s * w / 2.0 - 1.3, s * w / 2.0 + 1.3, y, y + 2.0, z0, z1, "steel.dark", "pushbar_post")
    for z in (z1 - 2.6, (z0 + z1) / 2.0 - 1.0):
        b.box(-w / 2.0 - 2.5, w / 2.0 + 2.5, y + 0.4, y + 2.4, z, z + 2.2, "steel.dark", "pushbar_rail")


def _lightbar(b, cy, z, w):
    """A light bar across a roof: a dark base, a lamp at each end and one each side of centre."""
    b.box(-w / 2.0, w / 2.0, cy - 1.3, cy + 1.3, z, z + 1.0, "steel.dark", "lightbar")
    for x in (-w / 2.0 + 2.2, -w / 6.0, w / 6.0, w / 2.0 - 2.2):
        b.box(x - 1.8, x + 1.8, cy - 1.0, cy + 1.0, z + 1.0, z + 2.3, "amber.light", "lightbar_lamp")


def _cupola(b, cx, cy, z, shape="barrel", carries="rivet_gun", name="hp_1"):
    """A gun ring and its pulpit, the stock's barrel forward out of it."""
    b.prism("z", cx, cy, z + 0.5, 6.5, 1.2, "steel.dark", 8, "ring")
    with b.joint("gun_" + name, (cx, cy, z + 1.0)):
        b.prism("z", cx, cy, z + 3.0, 5.5, 4.0, "steel.plate", 8, "pulpit", phase=math.pi / 8)
        b.stock(name, (cx, cy + 3.5, z + 3.2), shape, scale=0.85, carries=carries)


# The Drone, three armoured bodies. Each takes its skids' height `o`, its scale `k`, and heads +y.

def _well(b, cx, cy, zr, R, k, h, tag="", band="livery.livery2", guard=True):
    """A fan well: a thick eight-sided shroud `h` deep round a dark floor, the hub and three
    blades in it, and a two-bar guard across its mouth."""
    n = 8
    for i in range(n):
        a0, a1 = 2.0 * math.pi * i / n + math.pi / 8, 2.0 * math.pi * (i + 1) / n + math.pi / 8
        p0 = (cx + R * math.cos(a0), cy + R * math.sin(a0), zr)
        p1 = (cx + R * math.cos(a1), cy + R * math.sin(a1), zr)
        _beam(b, p0, p1, _sq(1.3 * k, h), _sq(1.3 * k, h), band, "drone_shroud" + tag)
    b.prism("z", cx, cy, zr - h * 0.3, R - 0.3 * k, 0.3 * k, "bore.dark", 8, "drone_well" + tag, phase=math.pi / 8)
    b.prism("z", cx, cy, zr - h * 0.05, 0.9 * k, h * 0.6, "steel.dark", 6, "drone_hub" + tag)
    for a in (0.3, 0.3 + math.pi * 2 / 3, 0.3 + math.pi * 4 / 3):
        dx, dy = math.cos(a) * (R - 0.7 * k), math.sin(a) * (R - 0.7 * k)
        _beam(b, (cx, cy, zr), (cx + dx, cy + dy, zr), _sq(0.9 * k, 0.22 * k), _sq(0.6 * k, 0.18 * k), "steel.plate", "drone_blade" + tag)
    if guard:
        zg = zr + h / 2.0 - 0.1 * k
        for a in (math.pi / 4, -math.pi / 4):
            dx, dy = math.cos(a) * R, math.sin(a) * R
            _beam(b, (cx - dx, cy - dy, zg), (cx + dx, cy + dy, zg), _sq(0.34 * k, 0.3 * k), _sq(0.34 * k, 0.3 * k), "steel.dark", "drone_guard" + tag)


def _chin(b, P, k, y, z, fork=1.2):
    """The Drone's sensor under its nose: a squat armoured turret with a lit lens, and the stun
    fork ahead of it, two prongs."""
    cx, cy, cz = P(0.0, y, z)
    b.prism("z", cx, cy, cz, 1.5 * k, 1.5 * k, "steel.dark", 8, "drone_chin", phase=math.pi / 8)
    lx, ly, lz = P(0.0, y + 1.5, z)
    b.box(lx - 0.7 * k, lx + 0.7 * k, ly - 0.2 * k, ly + 0.35 * k, lz - 0.5 * k, lz + 0.5 * k, LENS, "drone_lens")
    for s in (-1.0, 1.0):
        _beam(b, P(s * fork, y - 0.4, z + 0.5), P(s * fork, y + 2.2, z + 0.3), _sq(0.8 * k, 0.8 * k), _sq(0.6 * k, 0.6 * k), "steel.plate", "drone_fork_root")
        _spike(b, P(s * fork, y + 2.2, z + 0.3), P(s * fork, y + 5.0, z - 0.1), 0.3 * k, "steel.dark", "drone_prong")


def _skids(b, P, k, x, y0, y1, z_body, z_foot):
    """Two skid rails under the Drone, each on two stout struts, their toes turned up."""
    for s in (-1.0, 1.0):
        _beam(b, P(s * x, y0, z_foot), P(s * x, y1, z_foot), _sq(0.7 * k, 0.6 * k), _sq(0.7 * k, 0.6 * k), "steel.dark", "drone_skid")
        _beam(b, P(s * x, y1, z_foot), P(s * x, y1 + 1.2, z_foot + 0.9), _sq(0.7 * k, 0.6 * k), _sq(0.6 * k, 0.5 * k), "steel.dark", "drone_skid_toe")
        for y in (y0 + (y1 - y0) * 0.2, y0 + (y1 - y0) * 0.8):
            _beam(b, P(s * (x - 0.6), y, z_body), P(s * x, y, z_foot + 0.2), _sq(0.8 * k, 0.9 * k), _sq(0.7 * k, 0.8 * k), "steel.plate", "drone_strut")


def _drone_brick(b, o, k=1.0):
    """The brick: two fan wells in tandem sunk in one armoured lozenge, flat flanks, a wedge nose
    and a squared tail with two stub fins, a keel under it, the chin and the fork, two skids."""
    ox, oy, oz = o
    zr = oz + 4.6 * k

    def P(x, y, z):
        return (ox + x * k, oy + y * k, zr + z * k)

    for y, t in ((3.6, "_f"), (-3.6, "_b")):
        _well(b, ox, oy + y * k, zr, 3.1 * k, k, 2.4 * k, t)
    for s in (-1.0, 1.0):
        x0, x1 = sorted((ox + s * 2.7 * k, ox + s * 4.2 * k))
        b.box(x0, x1, oy - 6.4 * k, oy + 6.4 * k, zr - 1.3 * k, zr + 1.2 * k, "steel.panel", "drone_flank")
        x0, x1 = sorted((ox + s * 4.1 * k, ox + s * 4.6 * k))
        b.box(x0, x1, oy - 4.6 * k, oy + 4.6 * k, zr - 0.9 * k, zr + 0.6 * k, "steel.plate", "drone_flank_plate")
    b.box(ox - 2.9 * k, ox + 2.9 * k, oy - 1.1 * k, oy + 1.1 * k, zr - 1.3 * k, zr + 1.5 * k, "steel.plate", "drone_saddle")
    b.box(ox - 0.7 * k, ox + 0.7 * k, oy - 0.5 * k, oy + 0.5 * k, zr + 1.5 * k, zr + 1.8 * k, LENS, "drone_beacon")
    b.loft([(oy + 6.0 * k, rect(ox, 8.4 * k, zr - 1.3 * k, zr + 1.2 * k)), (oy + 7.4 * k, rect(ox, 7.0 * k, zr - 1.4 * k, zr + 1.0 * k)),
            (oy + 9.0 * k, rect(ox, 3.8 * k, zr - 1.3 * k, zr + 0.2 * k))], "steel.plate", "drone_nose")
    b.loft([(oy - 7.8 * k, rect(ox, 6.6 * k, zr - 1.0 * k, zr + 0.8 * k)), (oy - 6.0 * k, rect(ox, 8.4 * k, zr - 1.3 * k, zr + 1.2 * k))], "steel.plate", "drone_tail")
    for s in (-1.0, 1.0):
        _beam(b, P(s * 2.6, -6.6, 1.0), P(s * 2.9, -8.2, 2.6), _sq(0.5 * k, 1.8 * k), _sq(0.4 * k, 1.0 * k), "livery.livery2", "drone_fin")
    _beam(b, P(0.0, -5.6, -1.9), P(0.0, 6.4, -1.9), _sq(2.8 * k, 1.5 * k), _sq(2.4 * k, 1.4 * k), "steel.dark", "drone_keel")
    _chin(b, P, k, 7.2, -2.3)
    _skids(b, P, k, 3.0, -5.0, 4.6, -1.4, -4.3)


def _drone_shield(b, o, k=1.0):
    """The shield: four fan wells at the corners of a slab, an armoured spine down the middle and
    a broad plate across the front with the lens in a slot, the fork under it."""
    ox, oy, oz = o
    zr = oz + 4.4 * k

    def P(x, y, z):
        return (ox + x * k, oy + y * k, zr + z * k)

    for x, y, t in ((3.5, 3.3, "_fr"), (-3.5, 3.3, "_fl"), (3.5, -3.3, "_br"), (-3.5, -3.3, "_bl")):
        _well(b, ox + x * k, oy + y * k, zr, 2.6 * k, k, 2.0 * k, t)
    b.loft([(oy - 6.8 * k, _chamfered(ox, 2.6 * k, zr - 1.5 * k, zr + 1.0 * k, 0.5 * k)), (oy - 5.0 * k, _chamfered(ox, 3.4 * k, zr - 1.7 * k, zr + 1.6 * k, 0.8 * k)),
            (oy + 5.4 * k, _chamfered(ox, 3.4 * k, zr - 1.7 * k, zr + 1.6 * k, 0.8 * k))], "steel.panel", "drone_spine")
    b.box(ox - 0.6 * k, ox + 0.6 * k, oy - 4.4 * k, oy + 3.0 * k, zr + 1.6 * k, zr + 1.85 * k, "livery.livery2", "drone_stripe")
    for s in (-1.0, 1.0):
        x0, x1 = sorted((ox + s * 6.2 * k, ox + s * 7.0 * k))
        b.box(x0, x1, oy - 5.6 * k, oy + 5.8 * k, zr - 1.1 * k, zr + 0.9 * k, "steel.plate", "drone_flank")
        b.box(min(ox + s * 1.4 * k, ox + s * 6.4 * k), max(ox + s * 1.4 * k, ox + s * 6.4 * k), oy - 0.9 * k, oy + 0.9 * k, zr - 1.1 * k, zr + 0.9 * k, "steel.plate", "drone_arm")
    b.box(ox - 6.6 * k, ox + 6.6 * k, oy - 6.6 * k, oy - 5.6 * k, zr - 1.0 * k, zr + 0.8 * k, "steel.plate", "drone_tail_bar")
    # The front plate, leant back a little, a slot for the lens through it.
    for x0, x1 in ((-7.2, -1.0), (1.0, 7.2)):
        _beam(b, P((x0 + x1) / 2.0, 6.3, -2.6), P((x0 + x1) / 2.0, 5.5, 1.6), _sq((x1 - x0) * k, 0.8 * k), _sq((x1 - x0) * k, 0.8 * k), "steel.panel", "drone_shield")
    _beam(b, P(0.0, 6.3, -2.6), P(0.0, 6.1, -1.4), _sq(2.0 * k, 0.8 * k), _sq(2.0 * k, 0.8 * k), "steel.panel", "drone_shield_sill")
    _beam(b, P(0.0, 5.75, 0.3), P(0.0, 5.5, 1.6), _sq(2.0 * k, 0.8 * k), _sq(2.0 * k, 0.8 * k), "steel.panel", "drone_shield_brow")
    lx, ly, lz = P(0.0, 6.0, -0.55)
    b.box(lx - 0.9 * k, lx + 0.9 * k, ly - 0.5 * k, ly + 0.2 * k, lz - 0.75 * k, lz + 0.75 * k, LENS, "drone_lens")
    for x in (-5.6, -3.2, 3.2, 5.6):
        sx, sy, sz = P(x, 6.45, -0.6)
        b.box(sx - 0.5 * k, sx + 0.5 * k, sy - 0.1 * k, sy + 0.5 * k, sz - 1.5 * k, sz + 1.7 * k, "livery.livery2", "drone_shield_stripe")
    for s in (-1.0, 1.0):
        _spike(b, P(s * 2.2, 6.2, -2.4), P(s * 2.2, 9.4, -2.9), 0.32 * k, "steel.dark", "drone_prong")
    _skids(b, P, k, 3.5, -5.0, 4.4, -1.1, -4.1)


def _drone_drum(b, o, k=1.0):
    """The drum: one fan well in a deep armoured drum, a roll cage arched over its mouth, four
    stout legs off its corners, a nose block with the lens and the fork, a pack on its tail."""
    ox, oy, oz = o
    zr = oz + 4.6 * k

    def P(x, y, z):
        return (ox + x * k, oy + y * k, zr + z * k)

    R = 4.3 * k
    _well(b, ox, oy, zr, R, k, 3.2 * k, "", "steel.panel", guard=False)
    b.prism("z", ox, oy, zr + 1.3 * k, R + 0.75 * k, 0.7 * k, "livery.livery2", 8, "drone_rim", phase=math.pi / 8)
    b.prism("z", ox, oy, zr + 1.35 * k, R - 0.5 * k, 0.72 * k, "bore.dark", 8, "drone_mouth", phase=math.pi / 8)
    b.prism("z", ox, oy, zr + 1.4 * k, 1.0 * k, 0.9 * k, "steel.dark", 6, "drone_hub_cap")
    for a in (0.3, 0.3 + math.pi * 2 / 3, 0.3 + math.pi * 4 / 3):
        dx, dy = math.cos(a) * (R - 0.9 * k), math.sin(a) * (R - 0.9 * k)
        _beam(b, (ox, oy, zr + 1.75 * k), (ox + dx, oy + dy, zr + 1.75 * k), _sq(0.9 * k, 0.2 * k), _sq(0.6 * k, 0.16 * k), "steel.plate", "drone_blade_top")
    # The roll cage: two hoops crossed over the mouth.
    for a in (math.pi / 4, -math.pi / 4):
        dx, dy = math.cos(a) * (R + 0.2 * k), math.sin(a) * (R + 0.2 * k)
        ends = [(ox - dx, oy - dy, zr + 1.5 * k), (ox - dx * 0.45, oy - dy * 0.45, zr + 3.4 * k), (ox + dx * 0.45, oy + dy * 0.45, zr + 3.4 * k), (ox + dx, oy + dy, zr + 1.5 * k)]
        for p0, p1 in zip(ends, ends[1:]):
            _beam(b, p0, p1, _sq(0.55 * k, 0.55 * k), _sq(0.55 * k, 0.55 * k), "steel.dark", "drone_cage")
    for sx in (-1.0, 1.0):
        for sy in (-1.0, 1.0):
            _beam(b, P(sx * 3.2, sy * 3.2, -0.8), P(sx * 4.6, sy * 4.6, -4.2), _sq(1.1 * k, 1.1 * k), _sq(0.9 * k, 0.9 * k), "steel.plate", "drone_leg")
            fx, fy, fz = P(sx * 4.6, sy * 4.6, -4.4)
            b.box(fx - 0.9 * k, fx + 0.9 * k, fy - 0.9 * k, fy + 0.9 * k, fz - 0.2 * k, fz + 0.3 * k, "steel.dark", "drone_foot")
    b.loft([(oy + 4.0 * k, rect(ox, 4.4 * k, zr - 1.9 * k, zr + 1.0 * k)), (oy + 6.2 * k, rect(ox, 3.6 * k, zr - 1.8 * k, zr + 0.6 * k)),
            (oy + 7.2 * k, rect(ox, 2.6 * k, zr - 1.6 * k, zr - 0.1 * k))], "steel.plate", "drone_nose")
    lx, ly, lz = P(0.0, 7.2, -0.9)
    b.box(lx - 0.8 * k, lx + 0.8 * k, ly - 0.2 * k, ly + 0.35 * k, lz - 0.5 * k, lz + 0.5 * k, LENS, "drone_lens")
    for s in (-1.0, 1.0):
        _spike(b, P(s * 1.5, 6.6, -1.6), P(s * 1.5, 9.8, -2.2), 0.32 * k, "steel.dark", "drone_prong")
    b.box(ox - 2.0 * k, ox + 2.0 * k, oy - 6.4 * k, oy - 4.2 * k, zr - 1.6 * k, zr + 0.9 * k, "livery.livery2", "drone_pack")


_DRONES = {"brick": _drone_brick, "shield": _drone_shield, "drum": _drone_drum}


def _pole(b, s, cx, w, y0, y1, zb, zt):
    """One arm of the yoke: an armoured pole from the hull's shoulder out over the front wheel,
    three coil windings round its root, a lit shoe on its tip and a lit strip down its inner face."""
    b.loft([(y0, rect(cx, w, zb, zt)), (y1 - 14.0, rect(cx, w, zb, zt - 0.5)), (y1 - 3.0, rect(cx, w - 1.0, zb + 0.5, zt - 3.0)),
            (y1, rect(cx, w - 4.0, zb + 2.0, zt - 5.5))], "steel.panel", "pole")
    for y in (y0 + 20.0, y0 + 25.5, y0 + 31.0):
        b.box(cx - w / 2.0 - 1.3, cx + w / 2.0 + 1.3, y, y + 3.4, zb - 0.9, zt + 1.3, "steel.dark", "pole_coil")
    b.box(cx - w / 2.0 - 0.4, cx + w / 2.0 + 0.4, y1 - 12.0, y1 - 8.0, zb - 0.3, zt - 0.1, "livery.livery2", "pole_band")
    b.box(cx - w / 2.0 + 3.2, cx + w / 2.0 - 3.2, y1 - 0.2, y1 + 0.9, zb + 3.4, zt - 6.8, FIELD, "pole_shoe")
    xi = cx - s * (w / 2.0)
    b.box(min(xi, xi - s * 0.9), max(xi, xi - s * 0.9), y1 - 20.0, y1 - 4.0, zb + 3.2, zt - 4.2, FIELD, "pole_strip")
    xo = cx + s * (w / 2.0)
    b.box(min(xo - s * 1.0, xo + s * 0.4), max(xo - s * 1.0, xo + s * 0.4), y0 + 36.0, y1 - 13.0, zb - 9.0, zb, "steel.plate", "pole_skirt")


def mnlook_rhino_d(b, drone="brick"):
    """The yoke: the hull's front is a horseshoe magnet. Two armoured pole arms reach forward over
    the front wheels, the field thrown from the gap between them; the cab looks down the gap over
    a lit core. The Drone lives in a shielded bay sunk in the rear roof, its lids stood open."""
    _running_gear(b, -44.0, 6.0, 22.0, 16.0, 19.0, 36.0, 12.0, 12.0, 25.5)
    for s in (-1.0, 1.0):
        _pole(b, s, s * 25.5, 15.0, -4.0, 58.0, 25.5, 38.5)
        _skirts(b, s, 30.4, ((-43.0, -27.0), (-30.0, -14.0), (-17.0, -1.0), (-4.0, 8.0)))
    b.loft([(-42.0, rect(0.0, 28.0, 8.0, 17.0)), (46.0, rect(0.0, 24.0, 8.0, 15.0))], "steel.dark", "frame")
    # The hull: the high block forward, the rear stepped down into the bay.
    b.loft([(-17.0, _chamfered(0.0, 52.0, 16.0, 41.0, 6.0)), (10.0, _chamfered(0.0, 52.0, 16.0, 41.0, 6.0)), (16.0, _chamfered(0.0, 50.0, 15.0, 39.0, 6.0))], "steel.panel", "body")
    b.loft([(-46.0, _chamfered(0.0, 46.0, 16.0, 31.0, 3.0)), (-41.0, _chamfered(0.0, 52.0, 16.0, 33.0, 3.0)), (-17.0, _chamfered(0.0, 52.0, 16.0, 33.0, 3.0))], "steel.panel", "body_rear")
    wall = b.loft([(-47.0, rect(0.0, 40.0, 17.0, 29.0)), (-43.0, rect(0.0, 40.0, 17.0, 29.0))], "steel.panel", "rear_wall")
    _minerva_vents(b, [wall], (-10.0, 10.0), -47.0, 23.0, width=14.0, height=9.0, slats=4)
    # The face: the slit under a visor, the core in the throat, a low glacis down the gap.
    b.box(-14.0, 14.0, 15.6, 16.6, 30.5, 35.0, "glass.glass", "slit")
    b.loft([(11.0, rect(0.0, 36.0, 37.6, 39.8)), (19.0, rect(0.0, 34.0, 35.6, 37.4))], "steel.plate", "visor")
    b.prism("y", 0.0, 17.0, 23.0, 7.6, 3.0, "steel.dark", 8, "core_ring", phase=math.pi / 8)
    b.prism("y", 0.0, 18.2, 23.0, 5.4, 2.2, FIELD, 8, "core", phase=math.pi / 8)
    b.loft([(16.0, rect(0.0, 34.0, 12.0, 17.0)), (42.0, rect(0.0, 32.0, 12.0, 16.0)), (49.0, rect(0.0, 28.0, 12.0, 14.0))], "steel.plate", "glacis")
    for y in (24.0, 31.0, 38.0):
        b.box(-15.0, 15.0, y, y + 2.4, 16.2, 17.6, "steel.dark", "keeper")
    b.box(-17.5, 17.5, 48.0, 50.5, 7.0, 12.5, "steel.dark", "bumper")
    for s in (-1.0, 1.0):
        b.box(s * 13.0 - 1.8, s * 13.0 + 1.8, 49.2, 50.8, 12.6, 14.6, "amber.light", "lamp")
    # The bay: armoured walls round a dark floor, a hazard lip, a lid stood open off each wall.
    for s in (-1.0, 1.0):
        b.box(min(s * 13.0, s * 26.0), max(s * 13.0, s * 26.0), -45.0, -17.0, 33.0, 40.0, "steel.panel", "bay_wall")
        b.box(min(s * 12.4, s * 14.0), max(s * 12.4, s * 14.0), -44.0, -17.0, 40.0, 40.6, "steel.hazard", "bay_lip")
        _leaf(b, -44.0, -18.0, (s * 15.0, 40.4), (s * 20.5, 51.0), 1.4, "livery.livery2", "bay_lid")
        for y in (-38.0, -24.0):
            _beam(b, (s * 22.5, y, 40.0), (s * 18.0, y, 46.0), _sq(0.9, 0.9), _sq(0.9, 0.9), "steel.dark", "bay_strut")
    b.box(-13.0, 13.0, -46.2, -43.4, 33.0, 37.0, "steel.panel", "bay_gate")
    b.box(-12.4, 12.4, -43.4, -17.2, 33.0, 33.5, "bore.dark", "bay_floor")
    for s in (-1.0, 1.0):
        b.box(s * 3.8 - 1.0, s * 3.8 + 1.0, -42.0, -19.0, 33.5, 34.1, "steel.plate", "bay_rail")
    _DRONES[drone](b, (0.0, -32.9, 34.1), 1.25)
    # The roof: the gun ring forward where it fires down the gap, a rack and a bare mount on the
    # shoulders behind it, a light bar on the brow.
    _cupola(b, 0.0, 0.0, 41.0)
    b.stock("hp_2", (-15.0, -9.0, 41.3), "rack", scale=0.7, carries="ankle_mortar")
    b.pad("hp_3", (15.0, -9.0, 41.3), size=(7.0, 1.0))
    _lightbar(b, 9.5, 41.0, 26.0)


mnlook_rhino_d.maker = MN


def _emitter_turret(b, cx, cy, z, drone="drum"):
    """The emitter as a turret: a low armoured house on a wide ring, trunnion cheeks at its front
    carrying a coil drum that flares to a lit dish, and a saddle on its bustle for the Drone."""
    b.prism("z", cx, cy, z + 0.6, 12.5, 1.4, "steel.dark", 8, "turret_ring", phase=math.pi / 8)
    with b.joint("turret", (cx, cy, z + 1.2)):
        b.loft([(cy - 33.0, _chamfered(cx, 21.0, z + 1.2, z + 7.5, 2.0)), (cy - 29.0, _chamfered(cx, 26.0, z + 1.2, z + 8.0, 3.0)),
                (cy + 7.0, _chamfered(cx, 26.0, z + 1.2, z + 8.0, 3.0)), (cy + 12.0, _chamfered(cx, 20.0, z + 1.2, z + 5.5, 3.0))], "steel.panel", "turret")
        for s in (-1.0, 1.0):
            _slab_x(b, cx + s * 9.2, cx + s * 12.6, [(cy - 4.0, z + 1.2), (cy + 13.0, z + 1.2), (cy + 15.0, z + 12.0), (cy + 11.0, z + 17.0), (cy + 3.0, z + 17.0), (cy - 4.0, z + 9.0)],
                    "livery.livery2", "trunnion")
            b.prism("x", cx + s * 13.0, cy + 8.0, z + 11.5, 3.0, 1.2, "steel.dark", 8, "trunnion_pin", phase=math.pi / 8)
        base, tip = (cx, cy + 1.0, z + 10.5), (cx, cy + 25.0, z + 13.5)
        _beam(b, base, _lerp(base, tip, 0.82), _poly(7.4, 8, math.pi / 8), _poly(7.0, 8, math.pi / 8), "steel.plate", "emitter_drum")
        for t in (0.16, 0.36, 0.56):
            _beam(b, _lerp(base, tip, t), _lerp(base, tip, t + 0.11), _poly(8.6, 8, math.pi / 8), _poly(8.6, 8, math.pi / 8), "steel.dark", "emitter_coil")
        _beam(b, _lerp(base, tip, 0.8), tip, _poly(7.6, 8, math.pi / 8), _poly(11.5, 8, math.pi / 8), "steel.dark", "emitter_dish")
        _beam(b, _lerp(base, tip, 0.98), _lerp(base, tip, 1.02), _poly(9.6, 8, math.pi / 8), _poly(9.6, 8, math.pi / 8), FIELD, "emitter_field")
        _beam(b, _lerp(base, tip, 1.0), _lerp(base, tip, 1.1), _poly(2.2, 8, math.pi / 8), _poly(1.4, 8, math.pi / 8), "steel.dark", "emitter_stub")
        _beam(b, _lerp(base, tip, -0.12), base, _poly(5.0, 8, math.pi / 8), _poly(7.4, 8, math.pi / 8), "steel.dark", "emitter_breech")
        # The saddle: two armoured rails and a back stop on the bustle, a hazard lip, the Drone in it.
        for s in (-1.0, 1.0):
            b.box(min(cx + s * 10.0, cx + s * 13.0), max(cx + s * 10.0, cx + s * 13.0), cy - 32.0, cy - 8.0, z + 8.0, z + 12.5, "steel.panel", "saddle_rail")
            b.box(min(cx + s * 9.6, cx + s * 10.8), max(cx + s * 9.6, cx + s * 10.8), cy - 31.6, cy - 8.4, z + 12.5, z + 13.0, "steel.hazard", "saddle_lip")
        b.box(cx - 10.0, cx + 10.0, cy - 33.4, cy - 31.4, z + 7.6, z + 11.5, "steel.panel", "saddle_stop")
        b.box(cx - 9.6, cx + 9.6, cy - 31.4, cy - 8.4, z + 8.0, z + 8.5, "bore.dark", "saddle_floor")
        _DRONES[drone](b, (cx, cy - 21.8, z + 8.5), 1.4)


def mnlook_rhino_e(b, drone="drum"):
    """The turret: an armoured carrier with a blunt bonnet, boxed wheel housings and a push bar,
    and the emitter is its turret, where a riot vehicle carries its cannon: a coil drum flaring to
    a lit dish over the cab, the Drone on a saddle on the turret's bustle behind it."""
    _running_gear(b, -44.0, 4.0, 22.0, 16.0, 19.0, 31.0, 12.5, 12.0, 25.0)
    for s in (-1.0, 1.0):
        _housing(b, s, s * 25.0, 14.0, 31.0, 12.5, 30.0, 15.0, 47.0)
        b.box(min(s * 13.0, s * 30.5), max(s * 13.0, s * 30.5), -42.0, 2.0, 18.5, 21.0, "steel.plate", "skirt")
        _skirts(b, s, 30.4, ((-42.0, -28.0), (-30.0, -16.0), (-18.0, -4.0)), 9.0, 19.0)
    b.loft([(-42.0, rect(0.0, 28.0, 8.0, 17.0)), (14.0, rect(0.0, 28.0, 8.0, 17.0)), (44.0, rect(0.0, 20.0, 9.0, 15.0))], "steel.dark", "frame")
    b.loft([(-45.0, _chamfered(0.0, 44.0, 17.0, 28.0, 3.0)), (-39.0, _chamfered(0.0, 52.0, 16.0, 30.0, 4.0)), (0.0, _chamfered(0.0, 52.0, 16.0, 30.0, 4.0))], "steel.panel", "body")
    wall = b.loft([(-46.0, rect(0.0, 40.0, 17.0, 28.0)), (-42.0, rect(0.0, 40.0, 17.0, 28.0))], "steel.panel", "rear_wall")
    _minerva_vents(b, [wall], (-10.0, 10.0), -46.0, 22.5, width=14.0, height=8.0, slats=4)
    for s in (-1.0, 1.0):
        b.box(min(s * 15.0, s * 24.0), max(s * 15.0, s * 24.0), -41.0, -27.0, 30.0, 34.0, "livery.livery2", "bin")
        b.box(min(s * 14.6, s * 24.4), max(s * 14.6, s * 24.4), -41.4, -26.6, 34.0, 34.8, "steel.plate", "bin_lid")
    # The cab: broad and square-shouldered, a slit under a brow, a port in each flank.
    b.loft([(-6.0, _chamfered(0.0, 52.0, 16.0, 40.0, 6.0)), (10.0, _chamfered(0.0, 50.0, 16.0, 40.0, 6.0)), (18.0, _chamfered(0.0, 46.0, 15.0, 31.0, 5.0))], "livery.livery2", "cab")
    b.loft([(11.4, rect(0.0, 30.0, 33.6, 37.4)), (17.2, rect(0.0, 29.0, 28.4, 31.6))], "glass.glass", "slit")
    b.loft([(8.0, rect(0.0, 42.0, 39.6, 41.6)), (14.0, rect(0.0, 40.0, 38.0, 39.8))], "steel.plate", "brow")
    for s in (-1.0, 1.0):
        b.box(min(s * 25.6, s * 26.4), max(s * 25.6, s * 26.4), -2.0, 6.0, 29.0, 32.5, "glass.glass", "port")
    # The bonnet: blunt and slab-sided, a slatted face, the push bar ahead of the bumper.
    b.loft([(18.0, _chamfered(0.0, 38.0, 12.0, 29.0, 4.0)), (38.0, _chamfered(0.0, 36.0, 12.0, 27.5, 4.0)), (45.0, _chamfered(0.0, 34.0, 12.0, 23.0, 3.0))], "steel.panel", "bonnet")
    b.box(-11.0, 11.0, 44.6, 45.6, 13.5, 20.0, "steel.vent", "grille")
    for s in (-1.0, 1.0):
        b.box(s * 14.0 - 1.8, s * 14.0 + 1.8, 44.8, 46.0, 16.5, 19.5, "amber.light", "lamp")
    b.box(-30.0, 30.0, 45.0, 48.0, 7.0, 12.0, "steel.dark", "bumper")
    _pushbar(b, 48.0, 20.0, 8.0, 25.0)
    _emitter_turret(b, 0.0, 2.0, 40.0, drone)
    # Mounts, each with the sky and the road ahead clear: the gun on the right housing, the rack
    # on the left, a bare mount on the bonnet.
    b.prism("z", 25.0, 31.0, 30.5, 5.0, 1.0, "steel.dark", 8, "ring")
    b.stock("hp_1", (25.0, 33.0, 31.2), "barrel", scale=0.8, carries="rivet_gun")
    b.stock("hp_2", (-25.0, 30.0, 30.6), "rack", scale=0.7, carries="ankle_mortar")
    b.pad("hp_3", (0.0, 31.0, 28.6), size=(7.0, 1.0))


mnlook_rhino_e.maker = MN


def _plate(b, s, cx, w, drone_y):
    """One of the two great plates: an armoured slab raked forward down the rear deck, coil bands
    round it, a lit strip under the inner edge of its cap and one up its leading edge."""
    x0, x1 = cx - w / 2.0, cx + w / 2.0
    _slab_x(b, x0, x1, [(-45.0, 29.0), (6.0, 29.0), (18.0, 47.0), (14.0, 53.0), (-27.0, 53.0), (-45.0, 41.0)], "steel.panel", "plate")
    for y, zt in ((-33.0, 49.0), (-22.0, 53.9), (-11.0, 53.9), (0.0, 53.9)):
        b.box(x0 - 0.9, x1 + 0.9, y, y + 3.6, 29.0, zt, "steel.dark", "plate_coil")
    b.box(x0 - 1.2, x1 + 1.2, -27.0, 14.5, 53.0, 54.8, "steel.plate", "plate_cap")
    _slab_x(b, x0 - 0.5, x1 + 0.5, [(-43.0, 29.0), (-14.0, 29.0), (-14.0, 34.0), (-43.0, 38.0)], "livery.livery2", "plate_foot")
    xi = cx - s * (w / 2.0)
    b.box(min(xi, xi - s * 0.9), max(xi, xi - s * 0.9), -25.0, 12.0, 46.5, 51.0, FIELD, "plate_strip")
    _beam(b, (cx, 6.9, 30.6), (cx, 17.9, 47.1), _sq(w - 3.0, 1.0), _sq(w - 3.0, 1.0), FIELD, "plate_edge")
    # A charging arm from the plate's inner face to the Drone's flank.
    _beam(b, (xi, drone_y, 38.0), (xi - s * 6.0, drone_y, 36.0), _sq(1.8, 1.4), _sq(1.5, 1.2), "steel.dark", "dock_arm")
    ax = xi - s * 6.0
    b.box(min(ax, ax - s * 1.6), max(ax, ax - s * 1.6), drone_y - 1.6, drone_y + 1.6, 34.6, 37.2, "steel.hazard", "dock_clamp")


def mnlook_rhino_f(b, drone="shield"):
    """The plates: the cab forward over the wheels, and down the rear deck two great raked plates,
    the field's two poles, the Drone docked in the trench between them where they charge it."""
    _running_gear(b, -44.0, 6.0, 22.0, 16.0, 19.0, 30.0, 12.5, 12.0, 25.5)
    for s in (-1.0, 1.0):
        _housing(b, s, s * 25.5, 14.0, 30.0, 12.5, 30.0, 14.0, 46.0)
        _skirts(b, s, 30.4, ((-43.0, -27.0), (-30.0, -14.0), (-17.0, -1.0), (-4.0, 8.0)))
    b.loft([(-42.0, rect(0.0, 28.0, 8.0, 17.0)), (40.0, rect(0.0, 24.0, 8.0, 16.0))], "steel.dark", "frame")
    b.loft([(-46.0, _chamfered(0.0, 46.0, 16.0, 27.0, 3.0)), (-41.0, _chamfered(0.0, 52.0, 16.0, 29.0, 3.0)), (9.0, _chamfered(0.0, 52.0, 16.0, 29.0, 3.0))], "steel.panel", "body")
    wall = b.loft([(-47.0, rect(0.0, 40.0, 17.0, 27.0)), (-43.0, rect(0.0, 40.0, 17.0, 27.0))], "steel.panel", "rear_wall")
    _minerva_vents(b, [wall], (-10.0, 10.0), -47.0, 22.0, width=14.0, height=8.0, slats=3)
    # The cab: one armoured block forward, a flat face, the slit under a brow, a push bar.
    b.loft([(8.0, _chamfered(0.0, 50.0, 16.0, 36.5, 6.0)), (30.0, _chamfered(0.0, 50.0, 14.0, 37.5, 6.0)), (40.0, _chamfered(0.0, 46.0, 13.0, 31.0, 6.0)),
            (44.0, _chamfered(0.0, 42.0, 13.0, 25.0, 4.0))], "livery.livery2", "cab")
    b.loft([(38.8, rect(0.0, 30.0, 27.4, 30.4)), (42.6, rect(0.0, 28.0, 23.6, 26.2))], "glass.glass", "slit")
    b.loft([(33.0, rect(0.0, 42.0, 34.6, 36.6)), (40.6, rect(0.0, 40.0, 30.6, 32.2))], "steel.plate", "brow")
    b.box(-28.0, 28.0, 43.0, 46.0, 7.0, 12.0, "steel.dark", "bumper")
    for s in (-1.0, 1.0):
        b.box(s * 16.0 - 1.8, s * 16.0 + 1.8, 43.8, 45.0, 17.0, 20.0, "amber.light", "lamp")
    _pushbar(b, 46.0, 18.0, 8.0, 23.0)
    # The plates and the trench between them: the Drone's pad, an engine house against the cab.
    for s in (-1.0, 1.0):
        _plate(b, s, s * 21.0, 7.0, -21.0)
    b.prism("z", 0.0, -21.0, 29.5, 14.0, 1.0, "steel.dark", 8, "dock_pad", phase=math.pi / 8)
    b.prism("z", 0.0, -21.0, 29.9, 12.4, 0.5, "steel.hazard", 8, "dock_mark", phase=math.pi / 8)
    b.prism("z", 0.0, -21.0, 30.1, 11.2, 0.5, "bore.dark", 8, "dock_floor", phase=math.pi / 8)
    _DRONES[drone](b, (0.0, -22.0, 30.3), 1.35)
    house = b.loft([(-3.0, _chamfered(0.0, 26.0, 29.0, 33.0, 2.0)), (8.0, _chamfered(0.0, 28.0, 29.0, 35.0, 2.0))], "steel.panel", "engine_house")
    b.box(-9.0, 9.0, -3.6, -2.8, 30.0, 32.4, "steel.vent", "engine_vent")
    b.box(-16.0, 16.0, -45.6, -43.6, 27.0, 31.5, "steel.plate", "tailgate")
    # The roof: the gun ring forward, a rack and a bare mount behind its shoulders, a light bar.
    _cupola(b, 0.0, 25.0, 37.3)
    b.stock("hp_2", (-13.0, 14.0, 37.2), "rack", scale=0.7, carries="ankle_mortar")
    b.pad("hp_3", (13.0, 14.0, 37.2), size=(7.0, 1.0))
    _lightbar(b, 33.5, 36.2, 24.0)


mnlook_rhino_f.maker = MN


def mnlook_rhino_drone_brick(b):
    """The brick alone, enlarged four times."""
    _drone_brick(b, (0.0, 0.0, 0.0), 4.0)


mnlook_rhino_drone_brick.maker = MN


def mnlook_rhino_drone_shield(b):
    """The shield alone, enlarged four times."""
    _drone_shield(b, (0.0, 0.0, 0.0), 4.0)


mnlook_rhino_drone_shield.maker = MN


def mnlook_rhino_drone_drum(b):
    """The drum alone, enlarged four times."""
    _drone_drum(b, (0.0, 0.0, 0.0), 4.0)


mnlook_rhino_drone_drum.maker = MN


LOOKS = ["mnlook_rhino_a", "mnlook_rhino_b", "mnlook_rhino_c", "mnlook_rhino_drone", "mnlook_rhino_drone2_side",
         "mnlook_rhino_drone2_tandem", "mnlook_rhino_b_twin", "mnlook_rhino_a_tandem", "mnlook_rhino_b_tandem",
         "mnlook_rhino_c_tandem", "mnlook_rhino_d", "mnlook_rhino_e", "mnlook_rhino_f", "mnlook_rhino_drone_brick",
         "mnlook_rhino_drone_shield", "mnlook_rhino_drone_drum"]

_VIEWS = ["codex", "above", "skirmish", ("from the side", 90, 8)]
SHEET = {
    "title": "The White Rhino, three half-tracks and its Drone, 27 November (look tests, not content)",
    "out": "docs/looks/minerva_white_rhino.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_rhino_a", "label": "A, long head", "views": _VIEWS},
        {"model": "mnlook_rhino_b", "label": "B, shoulder", "views": _VIEWS},
        {"model": "mnlook_rhino_c", "label": "C, low ram", "views": _VIEWS},
        {"model": "mnlook_rhino_drone", "label": "Drone, enlarged", "views": ["codex", ("side", 90, 8), ("front", 0, 12), "above"]},
    ],
}


_DRONE_VIEWS = ["codex", ("side", 90, 8), ("front", 0, 12), "above"]
SHEET2 = {
    "title": "The White Rhino's Drone with twinned fans, 27 November (look tests, not content)",
    "out": "docs/looks/minerva_white_rhino2.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_rhino_drone", "label": "One fan (the first sheet)", "views": _DRONE_VIEWS},
        {"model": "mnlook_rhino_drone2_side", "label": "Twinned, side by side", "views": _DRONE_VIEWS},
        {"model": "mnlook_rhino_drone2_tandem", "label": "Twinned, in tandem", "views": _DRONE_VIEWS},
        {"model": "mnlook_rhino_b_twin", "label": "B with the side-by-side twin", "views": ["codex", "above", "skirmish", ("from the side", 90, 8)]},
    ],
}


_LOOK_VIEWS = ["codex", "above", "skirmish", ("from the side", 90, 8)]
SHEET3 = {
    "title": "The White Rhino with the tandem Askari-class Enforcement Drone, 27 November (look tests, not content)",
    "out": "docs/looks/minerva_white_rhino3.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_rhino_drone2_tandem", "label": "The Enforcer, tandem, enlarged", "views": _DRONE_VIEWS},
        {"model": "mnlook_rhino_a_tandem", "label": "A, long head", "views": _LOOK_VIEWS},
        {"model": "mnlook_rhino_b_tandem", "label": "B, shoulder", "views": _LOOK_VIEWS},
        {"model": "mnlook_rhino_c_tandem", "label": "C, low ram", "views": _LOOK_VIEWS},
    ],
}



_HULL_VIEWS = ["codex", "above", "skirmish", ("from the side", 90, 8), "rear"]
SHEET4 = {
    "title": "The White Rhino, round two: three hulls built round the emitter, three docks, three Enforcers, 28 November (look tests, not content)",
    "out": "docs/looks/minerva_white_rhino4.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_rhino_d", "label": "D, the yoke (bay, brick)", "views": _HULL_VIEWS},
        {"model": "mnlook_rhino_e", "label": "E, the turret (saddle, drum)", "views": _HULL_VIEWS},
        {"model": "mnlook_rhino_f", "label": "F, the plates (trench, shield)", "views": _HULL_VIEWS},
        {"model": "mnlook_rhino_drone_brick", "label": "Enforcer, the brick", "views": _DRONE_VIEWS + ["skirmish"]},
        {"model": "mnlook_rhino_drone_shield", "label": "Enforcer, the shield", "views": _DRONE_VIEWS + ["skirmish"]},
        {"model": "mnlook_rhino_drone_drum", "label": "Enforcer, the drum", "views": _DRONE_VIEWS + ["skirmish"]},
    ],
}

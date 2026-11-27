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
from models_low import _beam, _chamfered, _minerva_vents, _spike, _sq, _wheel

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


def mnlook_rhino_a(b):
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
    _cradle(b, 0.0, 2.0, 41.0, 1.4)


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


def mnlook_rhino_c(b):
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
    _cradle(b, -19.5, -39.5, 48.0, 1.4)


mnlook_rhino_c.maker = MN


def mnlook_rhino_drone(b):
    """The Drone alone, enlarged five times, on a plinth so its legs read."""
    b.box(-9.0, 9.0, -9.0, 9.0, 0.0, 2.0, "steel.dark", "plinth")
    _drone(b, (0.0, 0.0, 2.0), 5.0)


mnlook_rhino_drone.maker = MN


def mnlook_rhino_drone2_side(b):
    """The Drone with twinned fans side by side, enlarged five times, on a plinth."""
    b.box(-11.0, 11.0, -9.0, 9.0, 0.0, 2.0, "steel.dark", "plinth")
    _drone_twin(b, (0.0, 0.0, 2.0), 5.0, "side")


mnlook_rhino_drone2_side.maker = MN


def mnlook_rhino_drone2_tandem(b):
    """The Drone with twinned fans in tandem, enlarged five times, on a plinth."""
    b.box(-9.0, 9.0, -11.0, 11.0, 0.0, 2.0, "steel.dark", "plinth")
    _drone_twin(b, (0.0, 0.0, 2.0), 5.0, "tandem")


mnlook_rhino_drone2_tandem.maker = MN


def mnlook_rhino_b_twin(b):
    """The shoulder (B) with the side-by-side twin on its crest, to see the Drone at the size it rides."""
    mnlook_rhino_b(b, drone="side")


mnlook_rhino_b_twin.maker = MN


LOOKS = ["mnlook_rhino_a", "mnlook_rhino_b", "mnlook_rhino_c", "mnlook_rhino_drone", "mnlook_rhino_drone2_side",
         "mnlook_rhino_drone2_tandem", "mnlook_rhino_b_twin"]

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


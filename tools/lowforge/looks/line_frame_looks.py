"""A look test for the line frame, Aphelion's Gundam-homage walker (docs/briefs/aphelion_line_frame.md;
Ryan, 11 October: "a Gundam-homage walker"; the round-one look he was "fine trying": a V-crest on a
small head, chest intakes, the kite shield on the forearm, saber hilts on the backpack; pearl and
red). First round, 15 November, on his word to see what comes of the chassis that have a direction
("Doesn't have to be too detailed since none are finalized").

The homage lives in the silhouette's cues and nowhere else: an upright hero frame with long legs, a
narrow waist under a broad chest and square pauldrons, in Aphelion's own pearl with its red for the
markings (no third colour, no real suit's head, chest or shield). It stands as a machine does, not
as a figure poses: boxy chamfered members between drum joints, greaves flared over armoured feet.
The cues: a small helm with a visor band under a red V-crest; two louvred intakes on the chest
either side of a red hatch; a kite shield on the left forearm, held forward of the arm with its
head tipped back so the map's eye sees its face; two saber hilts raked up off the backpack's
corners over two thrusters; the beam rifle in the right hand.

Mounts (none settled; the brief's are a hand mount stocking the rifle, the rest basic kit): hp_1 the
right hand (the rifle, built here as a look's stand-in), hp_2 the left hand (bare, behind the
shield), hp_3 the right pauldron's top (a small rack) and hp_4 the left pauldron's top (bare). The
saber and the shield are the locked pieces, so neither is a pin. The second model is the same frame
with the saber drawn: the blade lit in the right hand, the rifle racked across the rear skirt, the
shield brought up across the chest, one hilt gone from the pack. The legs are four units longer
than the first cut's (RISE), the upper body built as it was and raised onto them.

Not content: built only by build_look.py, x right, y forward, z up, feet at z = 0.

Second round (SHEET2), 16 November, on Ryan's read of the first: "The line frame is too stocky,
and too much like a bad clone of the RX. It needs its own identity. Let's go with a transforming
type of weaponry for its locked pieces: it has fists (use the baboon/nemesis as a base), that
retract and get replaced with guns for its beam rifles. It has beam blades mounted on its forearms,
that can turn on and off. It can project a shield made of light from each forearm, like a buckler
(the "beam shields"). It cycles through weapon combinations as it idles and as it fights. Other
weapons are mounted either on the shoulders, or on the chest pectorals. A small winged backpack
that it uses to boost along the ground, not true flight or hover. The rest is up to you, it's a
homage not a clone". So a new figure (`_frame2`): lean and tall, its legs well over half its
height, a dark inner frame bare at the waist, a compact wedge of a chest, slim shoulders and a
small helm under one swept blade of a crest; and on that lean frame two heavy gauntlets, which are
its silhouette and its locked weaponry, the same on both arms (`_gauntlet`): a fist at the wrist
(the Nemesis's, `_fist`, thumb up) that draws back into the gauntlet for a rifle's barrel to run
out in its place; an emitter along the forearm's top that throws a blade forward past the hand;
and a boss on the forearm's outer face that throws a hexagonal buckler of light off it. Four
placeholder mounts, none settled: hp_1 and hp_2 on the shoulders' tops, hp_3 and hp_4 in the
pectorals. The pack is small, two short wings over two boosters canted down and back, with a
booster on each calf: it boosts along the ground and does not fly. The sheet shows four of the
states it would cycle through, each a baked pose of the one figure; nothing animates."""

import math

from mathutils import Matrix, Vector

from bl_low import rect
from models_low import _Raised, _beam, _deck, _fist, _poly, _rings, _slab, _spike, _tube

AP = "aphelion"
RISE = 4.0   # how far the long legs lift the hips over the first cut's


def _cs(w, h, c):
    """A chamfered rectangle profile for `_beam`: (across, up) pairs, eight points."""
    a, u = w / 2.0, h / 2.0
    return [(-a + c, -u), (a - c, -u), (a, -u + c), (a, u - c), (a - c, u), (-a + c, u), (-a, u - c), (-a, -u + c)]


def _along(p0, p1, t):
    return tuple(p0[i] + (p1[i] - p0[i]) * t for i in range(3))


def _unit(p0, p1):
    return (Vector(p1) - Vector(p0)).normalized()


def _leg(b, s):
    """A long straight leg: an armoured foot, a greave flared toward the ankle, a red knee cap, a
    thigh up under the skirts."""
    ankle, knee, hip = (s * 12.5, -1.0, 7.5), (s * 12.0, 3.0, 26.5), (s * 8.5, -2.0, 39.0 + RISE)
    cx = ankle[0]
    b.loft([(-9.5, rect(cx, 10.0, 0.0, 5.0)), (-3.0, rect(cx, 12.0, 0.0, 8.0)), (6.0, rect(cx, 12.0, 0.0, 6.5)),
            (13.5, rect(cx, 9.5, 0.0, 3.2))], "steel.plate", "foot")
    b.box(cx - 5.1, cx + 5.1, 9.5, 14.2, 0.0, 3.6, "livery.livery", "toe_cap")
    b.box(cx - 5.4, cx + 5.4, -10.3, -6.5, 0.0, 4.2, "steel.dark", "heel")
    b.prism("x", ankle[0], ankle[1], ankle[2], 3.6, 13.0, "steel.dark", 6, "ankle")
    _beam(b, _along(ankle, knee, 0.08), knee, _cs(12.5, 14.0, 3.0), _cs(9.0, 10.0, 2.2), "steel.panel", "greave")
    cuff0, cuff1 = _along(ankle, knee, 0.06), _along(ankle, knee, 0.2)
    _beam(b, cuff0, cuff1, _cs(13.3, 14.8, 3.0), _cs(12.6, 14.0, 3.0), "livery.livery2", "greave_cuff")
    b.box(knee[0] - 2.6, knee[0] + 2.6, knee[1] - 8.2, knee[1] - 5.2, 13.0, 23.0, "steel.vent", "calf_vent")
    b.prism("x", knee[0], knee[1], knee[2], 4.2, 11.0, "steel.dark", 6, "knee")
    b.loft([(knee[1] + 3.0, rect(knee[0], 8.5, knee[2] - 5.0, knee[2] + 5.5)), (knee[1] + 6.8, rect(knee[0], 6.0, knee[2] - 3.0, knee[2] + 3.5))],
           "livery.livery", "knee_cap")
    _beam(b, knee, hip, _cs(9.0, 10.0, 2.2), _cs(10.0, 11.5, 2.4), "steel.plate", "thigh")
    b.prism("x", hip[0], hip[1], hip[2], 4.4, 8.0, "steel.dark", 6, "hip")


def _arm(b, s, shoulder, elbow, wrist):
    """An arm from under the pauldron: a boxy upper arm, an elbow drum, a heavier forearm with a
    red band, a dark fist. Returns the fist's middle and the forearm's line."""
    d = _unit(elbow, wrist)
    _beam(b, shoulder, elbow, _cs(8.0, 8.5, 2.0), _cs(7.2, 7.6, 1.8), "steel.panel", "upper_arm")
    b.prism("x", elbow[0], elbow[1], elbow[2], 3.8, 9.5, "steel.dark", 6, "elbow")
    _beam(b, elbow, wrist, _cs(9.0, 9.5, 2.2), _cs(7.8, 8.2, 2.0), "steel.plate", "forearm")
    _beam(b, _along(elbow, wrist, 0.22), _along(elbow, wrist, 0.42), _cs(9.7, 10.2, 2.2), _cs(9.3, 9.8, 2.2), "livery.livery", "forearm_band")
    tip = tuple(Vector(wrist) + d * 6.5)
    _beam(b, wrist, tip, _cs(6.6, 7.0, 1.6), _cs(6.0, 6.4, 1.6), "steel.dark", "fist")
    return tuple(Vector(wrist) + d * 3.4), d


def _rifle(b, at, forward, pin=None):
    """The beam rifle as a look's stand-in: a long body, a barrel to a lensed muzzle, a sight on
    top and a red cell under it. `at` is the grip, the body lying along `forward`; with `pin` it
    hangs under that hardpoint."""
    f = Vector(forward).normalized()
    up = Vector((0.0, 0.0, 1.0))
    side = f.cross(up).normalized()
    up = side.cross(f).normalized()
    o = Vector(at)

    def P(along, over):
        return tuple(o + f * along + up * over)

    def build():
        _beam(b, P(-8.0, 3.0), P(12.0, 3.0), _cs(3.8, 5.2, 1.0), _cs(3.8, 5.2, 1.0), "steel.plate", "rifle_body")
        _beam(b, P(-15.0, 2.2), P(-8.0, 2.6), _cs(2.4, 4.0, 0.6), _cs(2.6, 4.4, 0.6), "steel.dark", "rifle_stock")
        _beam(b, P(12.0, 3.4), P(25.0, 3.4), _poly(1.4, 6), _poly(1.4, 6), "steel.dark", "rifle_barrel")
        _beam(b, P(24.0, 3.4), P(27.5, 3.4), _cs(3.4, 4.2, 0.8), _cs(3.4, 4.2, 0.8), "steel.plate", "rifle_muzzle")
        _beam(b, P(27.5, 3.4), P(28.1, 3.4), _poly(1.1, 6), _poly(1.1, 6), "amber.lit", "rifle_lens")
        _beam(b, P(-2.0, 6.8), P(6.5, 6.8), _cs(2.4, 2.4, 0.6), _cs(2.4, 2.4, 0.6), "steel.dark", "rifle_sight")
        _beam(b, P(6.5, 6.8), P(7.0, 6.8), _cs(1.6, 1.6, 0.4), _cs(1.6, 1.6, 0.4), "glass.glass", "sight_lens")
        _beam(b, P(3.0, -1.2), P(8.5, -1.2), _cs(3.2, 3.6, 0.8), _cs(3.2, 3.6, 0.8), "livery.livery", "rifle_cell")

    if pin:
        with b.socket(pin, P(4.0, 3.0), forward=tuple(f), carries="laser_carbine"):
            build()
    else:
        build()


def _shield(b, centre, facing, lean):
    """The kite shield: a tall plate, broad and clipped at its shoulders, down to a point; a red
    band across its head and a red point, a dark rib between them. `facing` is the way its face
    looks (level), `lean` the degrees its head tips that way."""
    n = Vector(facing).normalized()
    up = Vector((0.0, 0.0, 1.0))
    u = n.cross(up).normalized()
    a = math.radians(lean)
    v = (up * math.cos(a) + n * math.sin(a)).normalized()
    out = (n * math.cos(a) - up * math.sin(a)).normalized()
    c = Vector(centre)

    def ring(pts, proud=0.0):
        return [tuple(c + u * x + v * z + out * proud) for x, z in pts]

    _slab(b, ring([(-9.5, 13.0), (-7.0, 21.0), (7.0, 21.0), (9.5, 13.0), (9.5, 0.0), (0.0, -25.0), (-9.5, 0.0)]), out, 2.2, "steel.plate", "shield")
    _slab(b, ring([(-8.8, 13.4), (-6.7, 20.0), (6.7, 20.0), (8.8, 13.4)], 1.3), out, 0.6, "livery.livery", "shield_band")
    _slab(b, ring([(-6.2, -9.0), (6.2, -9.0), (0.0, -23.6)], 1.3), out, 0.6, "livery.livery", "shield_point")
    _slab(b, ring([(-1.3, -9.0), (1.3, -9.0), (1.3, 13.4), (-1.3, 13.4)], 1.3), out, 0.6, "steel.dark", "shield_rib")
    _slab(b, ring([(-6.5, 10.0), (6.5, 10.0), (6.5, -2.0), (0.0, -14.0), (-6.5, -2.0)], -1.3), out, 0.6, "steel.dark", "shield_back")
    return c, out


def _saber(b, hand, along):
    """A drawn saber: the hilt through the fist, a guard, the lit blade tapering to its tip."""
    h = Vector(along).normalized()
    o = Vector(hand)
    _beam(b, tuple(o - h * 4.0), tuple(o + h * 5.0), _poly(1.5, 6), _poly(1.5, 6), "steel.dark", "saber_hilt")
    _beam(b, tuple(o + h * 5.0), tuple(o + h * 6.4), _poly(2.5, 6), _poly(2.1, 6), "steel.plate", "saber_guard")
    _beam(b, tuple(o + h * 6.4), tuple(o + h * 38.0), _poly(2.1, 6), _poly(1.3, 6), "amber.lit", "saber_blade")
    _beam(b, tuple(o + h * 38.0), tuple(o + h * 42.0), _poly(1.3, 6), _poly(0.15, 6), "amber.lit", "saber_tip")


def _frame(b, drawn=False):
    for s in (-1.0, 1.0):
        _leg(b, s)
    with _Raised(b, RISE):
        _upper(b, drawn)


def _upper(b, drawn):
    """Everything above the hips, built with the hips at z = 39 and raised onto the legs."""
    # The pelvis under its skirts: two front plates either side of a red centre, side plates
    # over the hips, one across the back, a belt over them.
    b.box(-7.5, 7.5, -8.0, 5.0, 34.5, 43.0, "steel.dark", "pelvis")
    for s in (-1.0, 1.0):
        b.loft([(4.0, rect(s * 8.2, 9.6, 34.0, 43.6)), (7.6, rect(s * 8.6, 9.0, 32.4, 42.6))], "steel.plate", "skirt_front")
        b.box(min(s * 13.2, s * 16.6), max(s * 13.2, s * 16.6), -8.6, 3.6, 32.6, 43.6, "steel.plate", "skirt_side")
        b.box(min(s * 13.6, s * 17.0), max(s * 13.6, s * 17.0), -6.0, 1.0, 32.2, 34.6, "livery.livery", "skirt_trim")
    b.box(-2.7, 2.7, 4.6, 8.6, 33.4, 43.8, "livery.livery", "skirt_centre")
    b.box(-12.2, 12.2, -11.6, -8.4, 33.4, 43.6, "steel.plate", "skirt_rear")
    b.box(-13.8, 13.8, -9.6, 6.2, 42.6, 45.2, "steel.panel", "belt")
    b.prism("z", 0.0, -2.0, 46.2, 6.6, 3.0, "steel.dark", 8, "waist", phase=math.pi / 8)
    # The torso: narrow at the waist, broad at the chest, the chest block proud with its two
    # louvred intakes either side of a red hatch.
    _rings(b, [_deck(18.0, 14.0, -1.5, 47.0, 3.0), _deck(27.0, 19.0, -0.5, 51.5, 4.0), _deck(35.0, 22.0, 0.5, 55.5, 4.0),
               _deck(35.0, 22.0, 0.0, 60.5, 4.0), _deck(24.0, 16.0, -1.0, 63.2, 3.0)], "steel.panel", "torso")
    b.loft([(9.0, rect(0.0, 27.0, 53.4, 61.6)), (14.2, rect(0.0, 23.0, 54.8, 60.8))], "steel.plate", "chest")
    for s in (-1.0, 1.0):
        b.box(min(s * 3.8, s * 11.0), max(s * 3.8, s * 11.0), 13.6, 15.0, 55.2, 59.8, "steel.dark", "intake")
        for z in (56.2, 57.8):
            b.box(min(s * 3.8, s * 11.0), max(s * 3.8, s * 11.0), 14.6, 15.7, z, z + 0.8, "steel.plate", "intake_louvre")
        b.box(min(s * 3.4, s * 11.4), max(s * 3.4, s * 11.4), 13.4, 16.0, 59.8, 61.0, "livery.livery", "intake_brow")
    b.loft([(12.0, rect(0.0, 6.0, 51.6, 60.6)), (16.2, rect(0.0, 4.6, 53.0, 59.6))], "livery.livery2", "hatch")
    b.box(-4.6, 4.6, 8.4, 10.4, 47.4, 52.2, "steel.plate", "belly_plate")
    b.box(-8.4, 8.4, -6.0, 7.0, 62.6, 64.4, "steel.dark", "collar")
    # The head: small, a visor band under a brow, a red chin, and the V-crest, two red fins
    # rising off the brow, out and a little back.
    b.prism("z", 0.0, 0.5, 64.6, 3.0, 2.4, "steel.dark", 6, "neck")
    _rings(b, [_deck(8.4, 11.0, 0.4, 65.4, 2.0), _deck(10.0, 12.4, 0.6, 68.4, 2.6), _deck(9.6, 12.0, 0.4, 71.4, 2.6), _deck(6.6, 8.6, -0.4, 74.0, 2.0)],
           "steel.plate", "helm")
    b.box(-3.9, 3.9, 6.2, 7.4, 68.4, 70.8, "glass.glass", "visor")
    b.box(-2.2, 2.2, 5.6, 7.2, 65.4, 68.0, "steel.dark", "jaw")
    b.loft([(4.4, rect(0.0, 3.6, 71.0, 75.2)), (7.8, rect(0.0, 3.0, 71.2, 74.4))], "livery.livery", "brow")
    for s in (-1.0, 1.0):
        b.box(min(s * 4.9, s * 6.1), max(s * 4.9, s * 6.1), -2.4, 2.8, 67.6, 70.8, "steel.dark", "ear")
        # A crest fin: a long tapering blade off the brow, out, up and a little back.
        _slab(b, [(s * 0.6, 7.2, 71.8), (s * 3.6, 7.2, 75.4), (s * 15.5, -1.0, 89.0), (s * 14.4, -1.0, 85.6), (s * 3.2, 7.2, 71.8)],
              (0.0, 1.0, 0.5), 1.8, "livery.livery", "crest")
    b.box(-0.8, 0.8, -5.6, 3.6, 73.8, 75.6, "steel.dark", "helm_ridge")
    # The pauldrons: square, their outer corners clipped, a red stripe across each face and top.
    for s in (-1.0, 1.0):
        sec = [(s * 17.5, 54.6), (s * 29.0, 54.6), (s * 31.0, 57.6), (s * 31.0, 63.2), (s * 28.0, 67.0), (s * 17.5, 67.0)]
        b.loft([(-8.0, sec), (8.0, sec)], "steel.plate", "pauldron")
        b.box(min(s * 19.5, s * 31.4), max(s * 19.5, s * 31.4), 8.0, 8.7, 59.6, 62.8, "livery.livery", "pauldron_stripe")
        b.box(min(s * 19.5, s * 31.4), max(s * 19.5, s * 31.4), -8.7, -8.0, 59.6, 62.8, "livery.livery", "pauldron_stripe")
        b.prism("x", s * 19.0, 0.0, 58.0, 4.2, 8.0, "steel.dark", 6, "shoulder_joint")
    # The arms. At rest the right hand holds the rifle level at the hip and the left carries the
    # shield forward of its arm, low at the left side, its head tipped back; drawn, the right
    # raises the saber upright and a little outboard (held flatter it points down the codex's
    # eye and shows as a stub; straight up it stands across the head from that angle) and the
    # shield comes up across the chest.
    if drawn:
        right = ((24.0, 0.5, 55.0), (29.0, 2.5, 46.5), (28.5, 11.0, 53.0))
        left = ((-24.0, 1.0, 55.0), (-26.5, 6.0, 45.0), (-18.5, 14.5, 44.0))
    else:
        right = ((24.0, 0.0, 55.0), (25.5, -3.5, 44.5), (24.5, 8.0, 40.0))
        left = ((-24.0, 0.0, 55.0), (-26.5, -2.0, 44.5), (-24.8, 8.0, 41.2))
    rhand, rdir = _arm(b, 1.0, *right)
    lhand, ldir = _arm(b, -1.0, *left)
    if drawn:
        _saber(b, rhand, (0.3, 0.12, 0.95))
        b.pin("hp_1", tuple(Vector(rhand) + rdir * 3.2), forward=tuple(rdir), carries="")
        # The rifle racked across the rear skirt, muzzle to the left.
        _rifle(b, (3.0, -13.6, 37.0), (-1.0, 0.0, 0.0))
        b.box(-2.0, 2.0, -12.6, -11.4, 37.0, 42.0, "steel.dark", "rifle_rack")
        mid = _along(left[1], left[2], 0.55)
        c, out = _shield(b, (mid[0] - 1.5, mid[1] + 6.5, 45.5), (-0.3, 0.95, 0.0), -8.0)
    else:
        _rifle(b, (rhand[0], rhand[1], rhand[2] - 0.5), (0.0, 1.0, 0.0), "hp_1")
        mid = _along(left[1], left[2], 0.5)
        c, out = _shield(b, (mid[0] - 2.6, mid[1] + 13.0, 45.5), (-0.38, 0.92, 0.0), -14.0)
    _beam(b, mid, tuple(c - out * 1.0 + Vector((0.0, 0.0, mid[2] - c.z))), _cs(4.4, 4.4, 1.0), _cs(4.4, 4.4, 1.0), "steel.dark", "shield_arm")
    b.pin("hp_2", tuple(Vector(lhand) + ldir * 3.2), forward=tuple(ldir), carries="")
    # The backpack: a pack with red flanks and a vent, two thrusters canted down and back, and
    # the saber hilts crossed up off its top (the drawn one's socket left empty).
    b.box(-11.0, 11.0, -19.6, -10.0, 47.0, 62.6, "steel.panel", "pack")
    b.box(-6.0, 6.0, -20.4, -19.6, 54.5, 60.0, "steel.vent", "pack_vent")
    for s in (-1.0, 1.0):
        b.box(min(s * 11.0, s * 12.2), max(s * 11.0, s * 12.2), -18.6, -11.0, 49.0, 61.0, "livery.livery", "pack_flank")
        _tube(b, (s * 5.6, -17.0, 52.5), (s * 5.6, -26.0, 47.5), 4.8, 3.8, 8, "steel.dark", "thruster", floor_material="amber.exhaust", floor_depth=8.6, phase=math.pi / 8)
        _tube(b, (s * 5.6, -25.4, 47.83), (s * 5.6, -26.4, 47.28), 5.3, 3.8, 8, "amber.engine", "thruster_rim", floor=False, phase=math.pi / 8)
        root, tip = (s * 8.6, -15.4, 61.0), (s * 15.0, -19.0, 70.5)
        _beam(b, _along(root, tip, -0.08), _along(root, tip, 0.22), _poly(2.4, 6), _poly(2.4, 6), "steel.plate", "hilt_socket")
        if not (drawn and s > 0):
            _beam(b, root, tip, _poly(1.6, 6), _poly(1.6, 6), "steel.dark", "hilt")
            _beam(b, _along(root, tip, 0.5), _along(root, tip, 0.64), _poly(2.0, 6), _poly(2.0, 6), "livery.livery", "hilt_band")
            _beam(b, tip, _along(root, tip, 1.14), _poly(2.1, 6), _poly(1.7, 6), "steel.plate", "hilt_pommel")
    # The pauldrons' top mounts: a small rack on the right, a bare pad on the left.
    b.box(20.5, 28.5, -4.5, 4.5, 67.0, 68.0, "steel.dark", "mount_base")
    b.stock("hp_3", (24.5, -0.5, 68.0), "rack", scale=0.5, carries="ankle_mortar")
    b.pad("hp_4", (-24.5, 0.0, 68.0), size=(7.0, 1.0), material="steel.dark")


def aplook_line_frame(b):
    """The line frame at rest: the rifle at the hip, the shield at its side."""
    _frame(b, drawn=False)


def aplook_line_frame_saber(b):
    """The line frame with the saber drawn: blade lit, shield forward, the rifle racked aft."""
    _frame(b, drawn=True)


aplook_line_frame.maker = AP
aplook_line_frame_saber.maker = AP


# ------------------------------------------------------------------ the second round

G_LEN = 23.0   # a gauntlet, elbow to wrist

# An arm's pose: (shoulder, elbow, the forearm's line, where the forearm's outer face looks), for the
# right arm; the left mirrors it. The gauntlet's top, where the blade's emitter lies, follows from
# the last two.
POSES = {
    "rest": ((18.6, 0.0, 75.0), (21.2, -2.5, 62.5), (0.05, 0.50, -0.86), (1.0, 0.0, 0.0)),      # hanging, the hand ahead of the thigh
    "aim": ((18.6, 1.0, 75.0), (20.6, 3.5, 64.0), (-0.10, 0.99, 0.05), (1.0, 0.0, 0.0)),        # the forearm level, forward
    "blade": ((18.6, 1.0, 75.0), (24.0, 2.5, 64.0), (0.30, 0.86, 0.40), (1.0, 0.0, 0.0)),       # thrust forward, out and up
    "guard": ((18.6, 2.0, 75.0), (22.5, 12.0, 64.0), (-0.62, 0.20, 0.76), (0.0, 1.0, 0.12)),    # across the body, its outer face to the enemy
    "low": ((18.6, 0.5, 75.0), (23.5, 0.0, 63.0), (0.42, 0.74, -0.52), (1.0, 0.0, 0.0)),        # swept down and out
}


def _gauntlet(b, s, elbow, line, outer, hand="fist", blade=False, shield=False):
    """One heavy forearm and what it carries, built along +y from the elbow in its own frame
    (z its top, s * x its outer face) and then laid on the arm's line: the gauntlet with its red
    band; at the wrist the fist (`hand` "fist": the Nemesis's, turned thumb up) or, the fist drawn
    back inside, the beam rifle's barrel run out through the wrist ("rifle"); along the top a rail
    to the blade's emitter, and with `blade` the beam thrown forward past the hand; on the outer
    face a boss, and with `shield` a hexagonal buckler of light standing off it."""
    y = Vector(line).normalized()
    o = Vector(outer)
    o = (o - y * o.dot(y)).normalized()
    x = o * s
    z = x.cross(y).normalized()
    m = Matrix(((x.x, y.x, z.x, elbow[0]), (x.y, y.y, z.y, elbow[1]), (x.z, y.z, z.z, elbow[2]), (0.0, 0.0, 0.0, 1.0)))
    start = len(b.objects)
    b.loft([(0.5, _cs(8.4, 9.0, 2.0)), (5.5, _cs(10.8, 11.6, 2.6)), (19.0, _cs(10.8, 11.6, 2.6)), (G_LEN, _cs(9.0, 9.6, 2.2))], "steel.plate", "gauntlet")
    b.loft([(7.5, _cs(11.4, 12.2, 2.8)), (10.5, _cs(11.4, 12.2, 2.8))], "livery.livery", "gauntlet_band")
    b.loft([(G_LEN - 0.4, _cs(8.0, 8.6, 2.0)), (G_LEN + 1.4, _cs(7.2, 7.8, 1.8))], "steel.dark", "wrist_collar")
    if hand == "fist":
        f0 = len(b.objects)
        _fist(b, 0.0, G_LEN + 1.0, G_LEN + 9.5, -4.0, 4.0, 7.6, -s)
        c = Vector((0.0, G_LEN + 5.25, 0.0))
        turn = Matrix.Translation(c) @ Matrix.Rotation(s * math.pi / 2.0, 4, "Y") @ Matrix.Translation(-c)
        for ob in b.objects[f0:]:
            ob.matrix_world = turn @ ob.matrix_world
    else:
        b.loft([(G_LEN + 0.6, _cs(6.6, 6.6, 1.6)), (G_LEN + 5.5, _cs(5.4, 5.4, 1.3))], "steel.plate", "rifle_shroud")
        b.prism("y", 0.0, G_LEN + 9.5, 0.0, 2.2, 13.0, "steel.dark", 6, "rifle_barrel")
        b.prism("y", 0.0, G_LEN + 16.6, 0.0, 2.9, 1.8, "steel.plate", 6, "rifle_muzzle")
        b.prism("y", 0.0, G_LEN + 17.7, 0.0, 1.5, 0.5, "amber.lit", 6, "rifle_lens")
        b.box(-1.0, 1.0, G_LEN + 1.5, G_LEN + 6.0, 3.0, 4.3, "livery.livery", "rifle_sight")
    # The blade's rail and emitter along the top.
    b.box(-1.5, 1.5, 3.5, 20.5, 5.6, 7.2, "steel.dark", "blade_rail")
    b.loft([(19.5, rect(0.0, 4.4, 5.4, 8.4)), (24.6, rect(0.0, 3.4, 5.8, 8.0))], "steel.plate", "blade_emitter")
    b.box(-1.2, 1.2, 24.6, 25.0, 6.2, 7.6, "amber.lit" if blade else "steel.dark", "blade_mouth")
    if blade:
        _beam(b, (0.0, 25.0, 6.9), (0.0, 56.0, 6.9), _poly(2.7, 6), _poly(1.7, 6), "amber.lit", "beam_blade")
        _beam(b, (0.0, 56.0, 6.9), (0.0, 62.0, 6.9), _poly(1.7, 6), _poly(0.15, 6), "amber.lit", "beam_blade_tip")
    # The shield's boss on the outer face.
    b.prism("x", s * 5.9, 12.0, 0.0, 2.6, 1.4, "steel.dark", 8, "shield_boss")
    b.prism("x", s * 6.8, 12.0, 0.0, 1.3, 0.5, "amber.corona" if shield else "steel.plate", 8, "shield_lens")
    if shield:
        R, X = 11.5, s * 9.4
        ring = lambda r, dx: [(X + s * dx, 12.0 + r * math.cos(k * math.pi / 3.0), r * math.sin(k * math.pi / 3.0)) for k in range(6)]
        _slab(b, ring(R, 0.0), (s, 0.0, 0.0), 0.5, "amber.corona", "beam_shield")
        for pts, w, label in ((ring(R, 0.0), 0.6, "beam_shield_rim"), (ring(R * 0.5, 0.45), 0.4, "beam_shield_ring")):
            for k in range(6):
                _beam(b, pts[k], pts[(k + 1) % 6], _poly(w, 4), _poly(w, 4), "bone.bone", label)
    for ob in b.objects[start:]:
        ob.matrix_world = m @ ob.matrix_world


def _arm2(b, s, pose, hand="fist", blade=False, shield=False):
    """A slim upper arm off the shoulder, an elbow drum, and the gauntlet in its state."""
    sh, el, line, outer = POSES[pose]
    sh, el = (s * sh[0], sh[1], sh[2]), (s * el[0], el[1], el[2])
    line, outer = (s * line[0], line[1], line[2]), (s * outer[0], outer[1], outer[2])
    _beam(b, sh, el, _cs(5.6, 6.0, 1.4), _cs(5.0, 5.4, 1.2), "steel.dark", "upper_arm")   # the inner frame, bare: the gauntlet is the arm's weight
    b.prism("x", el[0], el[1], el[2], 3.0, 6.6, "steel.dark", 6, "elbow")
    _gauntlet(b, s, el, line, outer, hand, blade, shield)


def _leg2(b, s):
    """A long slim leg: a narrow foot, a shin with a red blade down its front and a booster on
    its calf, a knee guard drawn up to a point, a slim thigh to a dark hip."""
    ankle, knee, hip = (s * 7.6, -1.5, 6.0), (s * 7.2, 2.5, 29.5), (s * 6.5, -1.0, 54.0)
    cx = ankle[0]
    b.loft([(-8.5, rect(cx, 7.0, 0.0, 4.2)), (-3.5, rect(cx, 8.4, 0.0, 6.6)), (5.0, rect(cx, 8.4, 0.0, 5.4)), (13.0, rect(cx, 6.4, 0.0, 2.6))],
           "steel.plate", "foot")
    b.box(cx - 3.5, cx + 3.5, 9.6, 13.6, 0.0, 3.0, "steel.dark", "toe_cap")
    b.box(cx - 3.8, cx + 3.8, -9.2, -6.0, 0.0, 3.6, "steel.dark", "heel")
    b.prism("x", ankle[0], ankle[1], ankle[2], 2.9, 9.4, "steel.dark", 6, "ankle")
    _beam(b, _along(ankle, knee, 0.07), knee, _cs(7.4, 9.4, 2.0), _cs(8.6, 10.4, 2.2), "steel.panel", "shin")
    f0, f1 = _along(ankle, knee, 0.18), _along(ankle, knee, 0.82)
    _beam(b, (f0[0], f0[1] + 4.9, f0[2]), (f1[0], f1[1] + 5.4, f1[2]), _cs(2.6, 1.4, 0.4), _cs(3.4, 1.6, 0.4), "livery.livery", "shin_blade")
    # The calf's booster: a dark housing behind the shin, its nozzle down and back.
    c0 = _along(ankle, knee, 0.62)
    b.box(c0[0] - 2.6, c0[0] + 2.6, c0[1] - 7.6, c0[1] - 4.4, c0[2] - 5.5, c0[2] + 4.5, "steel.dark", "calf_housing")
    _tube(b, (c0[0], c0[1] - 6.0, c0[2] - 4.5), (c0[0], c0[1] - 8.2, c0[2] - 9.0), 2.5, 1.9, 8, "steel.dark", "calf_booster",
          floor_material="amber.exhaust", floor_depth=3.6, phase=math.pi / 8)
    b.prism("x", knee[0], knee[1], knee[2], 3.4, 8.6, "steel.dark", 6, "knee")
    b.loft([(knee[1] + 2.6, rect(knee[0], 7.4, knee[2] - 4.6, knee[2] + 4.6)), (knee[1] + 5.4, rect(knee[0], 5.0, knee[2] - 2.8, knee[2] + 3.6))],
           "steel.plate", "knee_guard")
    _spike(b, (knee[0], knee[1] + 3.8, knee[2] + 3.4), (knee[0], knee[1] + 2.4, knee[2] + 12.5), 1.9, "livery.livery", "knee_point")
    _beam(b, knee, hip, _cs(7.6, 8.6, 2.0), _cs(8.2, 9.4, 2.2), "steel.plate", "thigh")
    b.prism("x", hip[0], hip[1], hip[2], 3.6, 6.4, "steel.dark", 6, "hip")


def _frame2(b, right, left):
    """The second round's figure. `right` and `left` are each arm's state: (pose, hand, blade, shield)."""
    for s in (-1.0, 1.0):
        _leg2(b, s)
    # The pelvis: the dark frame, a small plate with a red line down it in front, a tasset over
    # each hip, a plate behind, a belt.
    b.box(-6.0, 6.0, -5.5, 4.0, 50.5, 58.5, "steel.dark", "pelvis")
    b.loft([(3.5, rect(0.0, 6.5, 50.0, 58.8)), (7.0, rect(0.0, 4.0, 51.5, 58.0))], "steel.plate", "pelvis_plate")
    b.box(-1.2, 1.2, 6.6, 7.5, 52.0, 58.0, "livery.livery", "pelvis_line")
    b.box(-6.5, 6.5, -8.0, -5.5, 50.5, 58.5, "steel.plate", "pelvis_rear")
    for s in (-1.0, 1.0):
        _slab(b, [(s * 10.6, -5.0, 59.0), (s * 10.6, 3.5, 59.0), (s * 12.8, 2.5, 47.5), (s * 12.8, -3.5, 49.5)], (s, 0.0, 0.18), 1.3, "steel.plate", "tasset")
        _slab(b, [(s * 12.4, -3.4, 50.6), (s * 12.5, 2.4, 48.9), (s * 13.2, 2.5, 46.9), (s * 13.2, -3.5, 48.9)], (s, 0.0, 0.18), 1.5, "livery.livery", "tasset_edge")
    b.box(-8.6, 8.6, -6.6, 5.0, 58.0, 60.0, "steel.panel", "belt")
    # The waist: the inner frame bare, a column and a strut either side.
    b.prism("z", 0.0, -1.0, 63.0, 4.2, 6.4, "steel.dark", 8, "waist", phase=math.pi / 8)
    for s in (-1.0, 1.0):
        b.prism("z", s * 5.4, 1.2, 63.0, 1.0, 6.4, "steel.vent", 6, "waist_strut")
    # The chest: a wedge, narrow at the waist and widest under the shoulders, a pectoral block
    # each side of a red sternum, a small plate over the belly.
    _rings(b, [_deck(13.0, 10.0, -0.5, 65.6, 2.5), _deck(22.0, 14.0, 0.5, 70.0, 3.2), _deck(27.0, 15.5, 1.0, 74.5, 3.6),
               _deck(24.0, 13.5, 0.0, 78.6, 3.2), _deck(15.0, 10.0, -1.0, 80.6, 2.6)], "steel.panel", "torso")
    for s in (-1.0, 1.0):
        b.loft([(7.0, rect(s * 6.6, 9.6, 71.4, 77.6)), (10.6, rect(s * 6.5, 7.8, 72.2, 77.0))], "steel.plate", "pectoral")
        b.box(min(s * 4.3, s * 8.7), max(s * 4.3, s * 8.7), 10.6, 11.0, 73.0, 76.2, "steel.dark", "pectoral_port")
    b.box(-1.4, 1.4, 8.4, 9.9, 69.6, 78.2, "livery.livery2", "sternum")
    b.box(-3.6, 3.6, 5.4, 7.2, 66.4, 69.8, "steel.plate", "belly_plate")
    b.box(-5.6, 5.6, -5.0, 5.0, 80.2, 81.6, "steel.dark", "collar")
    # hp_3 and hp_4, the pectorals: a small gun out of each port.
    b.stock("hp_3", (6.5, 10.8, 74.6), "barrel", scale=0.26, carries="laser_carbine")
    b.stock("hp_4", (-6.5, 10.8, 74.6), "twin_barrel", scale=0.26, carries="twin_autoguns")
    # The head: a small helm, a visor band round its face, dark cheeks and chin, and one blade of a
    # crest from the brow, swept up and back over the crown.
    b.prism("z", 0.0, 0.3, 82.6, 2.2, 2.4, "steel.dark", 6, "neck")
    _rings(b, [_deck(6.4, 8.4, 0.6, 83.6, 1.6), _deck(7.6, 9.6, 0.8, 86.2, 2.0), _deck(7.2, 9.2, 0.5, 89.0, 2.0), _deck(4.6, 6.4, -0.3, 91.0, 1.5)],
           "steel.plate", "helm")
    b.box(-3.3, 3.3, 5.0, 5.9, 86.4, 88.2, "glass.glass", "visor")
    b.box(-1.7, 1.7, 4.4, 5.6, 83.6, 85.8, "steel.dark", "chin")
    for s in (-1.0, 1.0):
        b.box(min(s * 3.3, s * 4.0), max(s * 3.3, s * 4.0), 2.2, 5.4, 86.4, 88.2, "glass.glass", "visor_side")
        b.box(min(s * 3.6, s * 4.7), max(s * 3.6, s * 4.7), -2.0, 1.8, 85.2, 88.0, "steel.dark", "cheek")
    _slab(b, [(0.0, 4.6, 89.4), (0.0, 5.8, 91.6), (0.0, -4.0, 99.6), (0.0, -8.5, 96.4), (0.0, -3.4, 91.2)], (1.0, 0.0, 0.0), 2.4, "livery.livery", "crest")
    b.loft([(1.6, rect(0.0, 4.4, 89.0, 92.2)), (6.3, rect(0.0, 2.4, 89.2, 91.6))], "steel.plate", "crest_root")
    # The shoulders: a small clipped cap each, a red line along its top edge, the mount on top.
    for s in (-1.0, 1.0):
        sec = [(s * 14.0, 72.6), (s * 21.5, 72.6), (s * 23.0, 75.0), (s * 23.0, 78.6), (s * 20.5, 80.6), (s * 14.0, 80.6)]
        b.loft([(-5.5, sec), (5.5, sec)], "steel.plate", "shoulder")
        b.box(min(s * 20.6, s * 23.3), max(s * 20.6, s * 23.3), -5.8, 5.8, 78.0, 79.2, "livery.livery", "shoulder_line")
        b.prism("x", s * 14.6, 0.0, 76.0, 3.2, 4.6, "steel.dark", 6, "shoulder_joint")
        b.box(min(s * 15.4, s * 21.6), max(s * 15.4, s * 21.6), -4.0, 4.0, 80.6, 81.5, "steel.dark", "shoulder_mount")
    # hp_1 and hp_2, the shoulders' tops: a small launcher on the right, an emitter on the left.
    b.stock("hp_1", (18.5, -1.0, 84.1), "rack", scale=0.36, carries="ankle_mortar")
    b.stock("hp_2", (-18.5, -0.5, 84.1), "dish", scale=0.4, carries="halo_projector")
    # The arms, each in its state.
    _arm2(b, 1.0, *right)
    _arm2(b, -1.0, *left)
    # The pack: small, a vent on its back, two short wings swept up and back off its shoulders and
    # two boosters under it canted down and back: it boosts along the ground and does not fly.
    b.box(-6.0, 6.0, -12.6, -6.6, 66.5, 78.6, "steel.panel", "pack")
    b.box(-4.0, 4.0, -12.0, -7.2, 78.6, 79.6, "livery.livery", "pack_cap")
    b.box(-3.5, 3.5, -13.1, -12.6, 70.5, 76.0, "steel.vent", "pack_vent")
    for s in (-1.0, 1.0):
        wing = [(s * 5.5, -7.8, 75.6), (s * 21.5, -13.6, 72.4), (s * 20.0, -18.0, 70.4), (s * 5.5, -12.6, 71.2)]
        n = (Vector(wing[1]) - Vector(wing[0])).cross(Vector(wing[3]) - Vector(wing[0])).normalized()
        _slab(b, wing, tuple(n), 1.2, "steel.plate", "pack_wing")
        _beam(b, wing[0], wing[1], _cs(1.8, 2.0, 0.4), _cs(1.4, 1.6, 0.3), "livery.livery", "pack_wing_edge")
        _tube(b, (s * 3.4, -11.0, 69.0), (s * 3.4, -17.0, 63.0), 3.0, 2.3, 8, "steel.dark", "booster", floor_material="amber.exhaust", floor_depth=5.6,
              phase=math.pi / 8)
        _tube(b, (s * 3.4, -16.6, 63.4), (s * 3.4, -17.4, 62.6), 3.4, 2.3, 8, "amber.engine", "booster_rim", floor=False, phase=math.pi / 8)


def aplook_line_frame2_rest(b):
    """Round two at rest: both fists out, the blades and the bucklers dark."""
    _frame2(b, ("rest", "fist", False, False), ("rest", "fist", False, False))


def aplook_line_frame2_rifles(b):
    """Both fists drawn back, both rifles run out and laid on the enemy."""
    _frame2(b, ("aim", "rifle", False, False), ("aim", "rifle", False, False))


def aplook_line_frame2_blade_shield(b):
    """A blade lit on the right arm, thrust forward; a buckler up on the left, across the body."""
    _frame2(b, ("blade", "fist", True, False), ("guard", "fist", False, True))


def aplook_line_frame2_blades(b):
    """Both blades lit: the right thrust forward, the left swept low."""
    _frame2(b, ("blade", "fist", True, False), ("low", "fist", True, False))


for _fn in (aplook_line_frame2_rest, aplook_line_frame2_rifles, aplook_line_frame2_blade_shield, aplook_line_frame2_blades):
    _fn.maker = AP

LOOKS = ["aplook_line_frame", "aplook_line_frame_saber",
         "aplook_line_frame2_rest", "aplook_line_frame2_rifles", "aplook_line_frame2_blade_shield", "aplook_line_frame2_blades"]

SHEET = {
    "title": "The line frame, first round, 15 November (look tests, not content)",
    "out": "docs/looks/aphelion_line_frame.png",
    "cell": (320, 400),
    "rows": [
        {"model": "aplook_line_frame", "label": "At rest", "views": ["codex", "above", "skirmish", "front", ("from the side", 90.0, 8.0)]},
        {"model": "aplook_line_frame_saber", "label": "Saber drawn", "views": ["codex", "above", "skirmish", "front", ("from the side", 90.0, 8.0)]},
    ],
}

SHEET2 = {
    "title": "The line frame, second round, 16 November (look tests, not content)",
    "out": "docs/looks/aphelion_line_frame2.png",
    "cell": (320, 400),
    "rows": [
        {"model": "aplook_line_frame2_rest", "label": "Fists, at rest", "views": ["codex", "above", "skirmish", "front", ("from the side", 90.0, 8.0)]},
        {"model": "aplook_line_frame2_rifles", "label": "Rifles out", "views": ["codex", "front", ("from the side", 90.0, 8.0)]},
        {"model": "aplook_line_frame2_blade_shield", "label": "A blade and a buckler", "views": ["codex", "front", "skirmish"]},
        {"model": "aplook_line_frame2_blades", "label": "Twin blades", "views": ["codex", "front", "above"]},
    ],
}

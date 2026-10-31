"""A look test for the Giant Petrel's hull (Ryan, 31 October, of the catamaran of 26 October:
"far from finished ... try a scratch version, but not a traditional catamaran. Something more
like a military catamaran, or even the James Bond stealth ship from Tomorrow Never Dies").
Two scratch hulls along that line. The navy's: a surface-effect catamaran in the stealth
register (the Skjold class's air cushion between two knife hulls, a raised centre bow, a
faceted deckhouse whose flanks lean in, an integrated mast), in Kestrel's chrome. The film's:
the stealth ship itself, one dark faceted wedge lifted on two canted struts over its lift
pontoons (the Sea Shadow's shape, which Carver's ship borrowed). Both keep the flagship's fixed
pieces and mounts: the Immelmann Booster as boosters astern, their mouths flattened for
stealth; the Spindrift Salvo's six tubes in a box sunk flush in the roof that rises to fire,
the back-blast venting astern; the Reheat Uplink's array on the mast, on a yaw joint; hp_1 a
faceted gun house forward (the Overclocked Railgun), hp_2 one aft (the Twin Autoguns), hp_3
bare (the Bleed Valve shows nowhere). Not content: built only by build_look.py, x right, y
forward, z up, as in models_low.py. Floats: the lowest point at z = 6."""

import math

from mathutils import Matrix, Vector

from bl_low import hexagon, rect
from models_low import _disc, _poly, _rings, _slab, _tube

KT = "kestrel"
BOOSTERS = ["booster_ring", "exhaust"]


def _gun_house(b, name, pin, shape, carries, cx, ty, tz, w, l, h):
    """A faceted gun house on a yaw joint over a dark ring: its face raked, its flanks leaning
    in, its back stepped down; the stock gun out of its face."""
    b.prism("z", cx, ty, tz + 0.4, w * 0.55, 1.0, "steel.dark", 8, "turret_ring", phase=math.pi / 8)
    with b.joint(name, (cx, ty, tz + 0.9), axis="yaw", limits=(-75.0, 75.0)):
        a = w / 2.0
        secs = [(ty + l * 0.55, a * 0.6, tz + h * 0.4), (ty + l * 0.2, a, tz + h), (ty - l * 0.3, a, tz + h), (ty - l * 0.5, a * 0.8, tz + h * 0.7)]
        b.loft([(y, [(cx - aa, tz + 0.8), (cx + aa, tz + 0.8), (cx + aa * 0.7, z1), (cx - aa * 0.7, z1)]) for (y, aa, z1) in secs],
               "steel.plate", "turret_house")
        b.stock(pin, (cx, ty + l * 0.3, tz + h * 0.62), shape, scale=0.8, carries=carries)


def _booster(b, cx, cz, y0, y1, w, h):
    """A booster with its mouth flattened for stealth: a wide flat hexagonal drum from `y0`
    back to `y1`, the lit ring and the exhaust at its end."""
    b.loft([(y0, hexagon(cx, cz, w, h)), (y1, hexagon(cx, cz, w, h))], "steel.dark", "booster")
    b.loft([(y1 + 1.6, hexagon(cx, cz, w + 0.8, h + 0.6)), (y1 - 0.2, hexagon(cx, cz, w + 0.8, h + 0.6))], "amber.engine", "booster_ring")
    b.loft([(y1 - 0.3, hexagon(cx, cz, w + 0.2, h + 0.1)), (y1 - 0.8, hexagon(cx, cz, w - 1.4, h - 1.0))], "amber.exhaust", "exhaust")


def _salvo_box(b, y_front, y_back, z_roof, w):
    """The Spindrift Salvo: a box of six tubes (three pairs, a column each, fired left to
    right) sunk in the roof with only its lid proud, hinged at its back (joint salvo) so its
    face rises out of the roof to fire; each tube's floor and its back-blast vent banked dark
    at rest and lit as its pair fires."""
    zl = z_roof + 0.4
    hinge = (0.0, y_back, z_roof - 2.0)
    with b.joint("salvo", hinge, axis="pitch", limits=(-2.0, 34.0)):
        sec = [(-w / 2.0, z_roof - 5.4), (w / 2.0, z_roof - 5.4), (w / 2.0, zl - 0.6), (w / 2.0 - 0.6, zl), (-w / 2.0 + 0.6, zl), (-w / 2.0, zl - 0.6)]
        b.loft([(y_front, sec), (y_back, sec)], "steel.plate", "salvo_box")
        b.loft([(y_front - 0.6, rect(0.0, w - 2.4, zl - 0.1, zl + 0.15)), (y_back + 0.6, rect(0.0, w - 2.4, zl - 0.1, zl + 0.15))], "livery.livery", "salvo_lid")
        for k, tag in enumerate("abc"):
            x = (k - 1) * (w / 3.0)
            for z in (z_roof - 1.3, z_roof - 3.8):
                _tube(b, (x, y_front - 6.0, z), (x, y_front + 0.3, z), 1.1, 0.8, 8, "steel.dark", "salvo_" + tag, floor_material="amber.ember", floor_depth=0.8)
                _disc(b, (x, y_back - 0.15, z), (0.0, -1.0, 0.0), 1.0, 8, "amber.ember", "salvo_%s_blast" % tag)


def _uplink(b, uy, uz, panel=5.6):
    """The Reheat Uplink: a flat hexagonal array on a yaw joint over a short drum, facing
    forward and a little up, its core lit."""
    b.prism("z", 0.0, uy, uz + 0.8, 2.0, 1.6, "steel.dark", 6, "uplink_mast")
    with b.joint("sensor_uplink", (0.0, uy, uz + 1.6), axis="yaw", limits=(-150.0, 150.0)):
        b.box(-0.9, 0.9, -1.0, 1.0, uz + 1.4, uz + panel + 1.2, "steel.dark", "uplink_yoke", Matrix.Translation((0.0, uy, 0.0)))
        tilt = Matrix.Translation((0.0, uy + 1.2, uz + panel + 1.4)) @ Matrix.Rotation(math.radians(15.0), 4, "X")
        b.loft([(-0.6, _poly(panel, 6, math.pi / 6)), (0.6, _poly(panel, 6, math.pi / 6))], "steel.plate", "uplink_dish", tilt)
        b.loft([(0.55, _poly(panel * 0.82, 6, math.pi / 6)), (0.75, _poly(panel * 0.78, 6, math.pi / 6))], "livery.livery", "uplink_face", tilt)
        b.loft([(0.7, _poly(1.8, 6, math.pi / 6)), (1.3, _poly(1.3, 6, math.pi / 6))], "amber.lit", "uplink_core", tilt)


def _acts(b, fore, aft):
    """The flagship's four idle acts and its run, the first cut's, on these joints."""
    b.act("salvo", 6.4, {"salvo": [(0.4, 0.0), (1.6, 30.0), (4.6, 30.0), (5.8, 0.0)]},
          body=[(1.8, 0.0, 0.0, 0.0), (2.2, 0.0, -0.6, 0.0, 0.0, 0.8, 0.0), (2.7, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0), (3.2, 0.0, -1.3, 0.0, 0.0, 1.0, 0.0),
                (4.0, 0.0, -0.5, 0.0), (6.4, 0.0, 0.0, 0.0)],
          glow=[(["salvo_a_floor", "salvo_a_blast"], [(2.0, 0.0), (2.15, 16.0), (2.6, 2.0), (3.4, 0.0)]),
                (["salvo_b_floor", "salvo_b_blast"], [(2.5, 0.0), (2.65, 16.0), (3.1, 2.0), (3.9, 0.0)]),
                (["salvo_c_floor", "salvo_c_blast"], [(3.0, 0.0), (3.15, 16.0), (3.6, 2.0), (4.4, 0.0)])])
    b.act("immelmann", 6.0, body=[(0.8, 0.0, 0.0, 0.0), (2.0, 0.0, 4.0, 3.0, 0.0, 2.0, 0.0), (3.8, 0.0, 6.0, 3.5, 0.0, 1.5, 0.0), (4.8, 0.0, 1.0, -1.0, 0.0, -1.0, 0.0), (6.0, 0.0, 0.0, 0.0)],
          glow=[(BOOSTERS, [(0.5, 0.0), (1.2, 6.0), (1.8, 12.0), (3.8, 12.0), (4.6, 0.0)])])
    b.act("uplink", 5.6, {"sensor_uplink": [(0.5, 0.0), (1.9, 70.0), (3.6, 70.0), (5.0, 0.0)]},
          glow=[(["uplink_core"], [(1.8, 0.0), (2.1, 10.0), (2.4, 2.0), (2.7, 12.0), (3.6, 12.0), (4.4, 0.0)])])
    b.act("traverse", 7.4, {fore: [(0.6, 0.0), (2.0, 46.0), (2.8, 46.0), (5.2, -34.0), (6.0, -34.0), (7.2, 0.0)],
                            aft: [(1.0, 0.0), (2.4, -40.0), (3.2, -40.0), (5.4, 30.0), (6.2, 30.0), (7.2, 0.0)]})
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, 2.0, 0.0), glow={"parts": BOOSTERS, "k": 4.0}, rock=2.0)
    b.move(slide=0.3, bank=0.0, accel=1.6, heft=0.25, oversteer=0.5)


def ktlook_giant_ses(b):
    """The navy's: a surface-effect catamaran. Two knife hulls, their stems raked back as a wave
    piercer's so the keels run out ahead of the deck, dark below the chine and chrome above,
    the flanks leaning in to the deck; a cross deck between them over the air cushion, sealed
    by a row of skirt fingers at the bow and three bags astern, lift glowing under it; a raised
    centre bow between the knives carrying the fore gun house (hp_1). The deckhouse spans the
    deck, every face leaning in, the bridge's glass a band across its raked face; an
    integrated mast, a faceted pyramid, carries the uplink's array; the salvo's box sits flush
    in the roof behind it; the aft gun house (hp_2) on the quarterdeck, hp_3 bare beside it;
    a flattened booster closing each hull astern."""
    HX = 22.0
    HULL = [(78.0, 0.8, 7.6, 8.6), (72.0, 3.2, 6.8, 12.4), (62.0, 7.6, 6.2, 17.8), (48.0, 11.4, 6.0, 20.0),
            (20.0, 13.0, 6.0, 20.0), (-40.0, 13.0, 6.0, 20.0), (-56.0, 12.4, 6.4, 20.0), (-62.0, 11.4, 7.0, 19.4)]   # (y, w, keel, deck), bow to stern

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
        for (ya, yb) in ((58.0, 40.0), (-34.0, -54.0)):
            b.loft([(ya, rect(s * HX, 3.6, 19.6, 20.3)), (yb, rect(s * HX, 3.6, 19.6, 20.3))], "livery.livery", "deck_stripe")
        # Astern, the hull's tail closes onto its booster.
        y, w, z0, z1 = HULL[-1]
        b.loft([(y, [(s * HX + p[0], p[1]) for p in hexagon(0.0, (z0 + z1) / 2.0, w, z1 - z0)]), (y - 4.0, hexagon(s * HX, 13.4, 11.6, 7.4))], "steel.plate", "tail_fairing")
        _booster(b, s * HX, 13.4, y - 4.0, y - 10.0, 11.0, 7.0)
    # The cross deck over the cushion, its seals and the lift under it.
    b.loft([(45.0, rect(0.0, 2 * HX - 4.0, 13.0, 20.0)), (-57.0, rect(0.0, 2 * HX - 4.0, 13.0, 20.0))], "steel.plate", "cross_deck")
    for k in range(13):
        x = (k - 6) * 2.6
        b.box(x - 1.1, x + 1.1, 42.6, 44.6, 6.8, 13.2, "steel.dark", "bow_seal")
    for z in (8.2, 10.6):
        b.prism("x", 0.0, -55.8, z, 1.5, 2 * HX - 9.0, "steel.dark", 8, "stern_seal")
    for (x, y) in ((-8.0, 24.0), (8.0, 24.0), (0.0, 0.0), (-8.0, -26.0), (8.0, -26.0)):
        _disc(b, (x, y, 12.9), (0.0, 0.0, -1.0), 2.8, 6, "amber.engine", "lift_nozzle")
    # The centre bow between the knives: a raised wedge, the fore gun house on it.
    CB = [(62.0, 1.2, 17.6, 19.4), (55.0, 12.0, 15.0, 20.0), (45.0, 2 * HX - 5.0, 13.0, 20.0)]
    b.loft([(y, [(-w * 0.2, z0), (w * 0.2, z0), (w * 0.5, (z0 + z1) / 2.0), (w * 0.44, z1), (-w * 0.44, z1), (-w * 0.5, (z0 + z1) / 2.0)]) for (y, w, z0, z1) in CB],
           "steel.plate", "centre_bow")
    _gun_house(b, "turret_fore", "hp_1", "barrel", "overclocked_railgun", 0.0, 51.0, 20.0, 9.0, 12.0, 5.0)
    # The deckhouse: every face leaning in, the bridge across its raked face.
    DZ = 20.0
    DH = [(39.0, 25.6, 11.0, 23.0), (31.0, 26.2, 15.0, 31.0), (4.0, 26.4, 16.0, 31.6), (-26.0, 26.4, 16.0, 31.6), (-33.0, 26.2, 12.0, 25.0)]   # (y, base half width, roof half width, roof)
    b.loft([(y, [(-a, DZ), (a, DZ), (t, zt), (-t, zt)]) for (y, a, t, zt) in DH], "steel.panel", "deckhouse")
    n = Vector((0.0, 8.0, 8.0)).normalized()

    def face(t, s):
        p = Vector((s * 11.0, 39.0, 23.0)).lerp(Vector((s * 15.0, 31.0, 31.0)), t)
        return p.x * 0.8, p.y, p.z
    _slab(b, [face(0.38, -1.0), face(0.38, 1.0), face(0.78, 1.0), face(0.78, -1.0)], tuple(n), 0.3, "glass.glass", "bridge_glass")
    for s in (-1.0, 1.0):
        b.loft([(30.0, rect(s * 13.4, 2.0, 31.4, 31.9)), (-25.0, rect(s * 13.4, 2.0, 31.4, 31.9))], "livery.livery", "roof_stripe")
    # The integrated mast, a faceted pyramid on the roof, and the uplink's array on it.
    MZ = 31.4
    _rings(b, [[(-7.0, -14.0, MZ), (7.0, -14.0, MZ), (7.0, 4.0, MZ), (-7.0, 4.0, MZ)],
               [(-2.8, -8.0, MZ + 11.0), (2.8, -8.0, MZ + 11.0), (2.8, -3.0, MZ + 11.0), (-2.8, -3.0, MZ + 11.0)]], "steel.panel", "mast")
    _uplink(b, -5.5, MZ + 11.0)
    _salvo_box(b, -16.5, -25.5, 31.6, 13.0)
    # The quarterdeck: the aft gun house, hp_3 bare beside it.
    _gun_house(b, "turret_aft", "hp_2", "twin_barrel", "twin_autoguns", 0.0, -43.0, DZ, 8.0, 10.0, 4.4)
    b.pad("hp_3", (12.5, -47.0, DZ + 1.0), scale=0.8, size=(4.4, 1.4))
    _acts(b, "turret_fore", "turret_aft")

ktlook_giant_ses.maker = KT


def ktlook_giant_shadow(b):
    """The film's: the stealth ship. One dark faceted wedge, its point forward and every face
    leaning in to a narrow roof, lifted on two canted struts over two slim lift pontoons that
    glow under them; a cobalt edge along the roof. The bridge a slit of glass across the bow's
    raked facets, the fore gun house (hp_1) on the roof ahead of it; a low faceted mast with the
    uplink's array; the salvo's box flush in the roof behind it; the aft gun house (hp_2), hp_3
    bare; two flattened boosters let into the stern face."""
    Z0 = 18.0
    # The pontoons and the struts, both canted in.
    for s in (-1.0, 1.0):
        P = [(40.0, 0.6, 0.6), (32.0, 4.6, 3.4), (22.0, 6.0, 4.6), (-48.0, 6.0, 4.6), (-58.0, 4.4, 3.4), (-64.0, 1.0, 1.0)]   # (y, w, h)
        b.loft([(y, hexagon(s * 20.0, 8.8, w, h + 1.0)) for (y, w, h) in P], "steel.dark", "pontoon")
        for (x, y) in ((s * 20.0, 16.0), (s * 20.0, -14.0), (s * 20.0, -42.0)):
            _disc(b, (x, y, 6.25), (0.0, 0.0, -1.0), 2.4, 6, "amber.engine", "lift_nozzle")
        STRUT = [(26.0, 0.6), (18.0, 1.6), (-44.0, 1.6), (-52.0, 0.6)]
        b.loft([(y, [(s * 20.0 - t, 10.8), (s * 20.0 + t, 10.8), (s * 16.5 + t * 0.8, Z0 + 0.4), (s * 16.5 - t * 0.8, Z0 + 0.4)]) for (y, t) in STRUT], "steel.dark", "strut")
    # The wedge: from the point at the bow to its full beam, every face leaning in.
    BODY = [(70.0, 0.6, 0.3, Z0 + 1.0), (52.0, 11.0, 3.6, Z0 + 7.0), (30.0, 23.0, 9.0, Z0 + 12.0), (14.0, 28.0, 13.0, Z0 + 14.0),
            (-50.0, 28.0, 13.0, Z0 + 14.0), (-58.0, 25.0, 11.5, Z0 + 12.6), (-62.0, 21.0, 10.0, Z0 + 11.0)]   # (y, half beam at the bottom, roof half width, roof)
    b.loft([(y, [(-a, Z0), (a, Z0), (t, zt), (-t, zt)]) for (y, a, t, zt) in BODY], "steel.dark", "body")
    for s in (-1.0, 1.0):
        b.loft([(y, [(s * (t - 0.8), zt - 0.2), (s * (t + 0.4), zt - 0.4), (s * (t + 0.2), zt + 0.25), (s * (t - 1.0), zt + 0.25)][::int(s)])
                for (y, a, t, zt) in BODY[1:-1]], "livery.livery", "roof_edge")
    # The bridge: a slit of glass across the bow's raked roof facet.
    n = Vector((0.0, 6.0, 16.0)).normalized()

    def face(t, s):
        p = Vector((s * 3.6, 52.0, Z0 + 7.0)).lerp(Vector((s * 9.0, 30.0, Z0 + 12.0)), t)
        return p.x * 0.86, p.y, p.z
    _slab(b, [face(0.56, -1.0), face(0.56, 1.0), face(0.82, 1.0), face(0.82, -1.0)], tuple(n), 0.3, "glass.glass", "bridge_glass")
    _gun_house(b, "turret_fore", "hp_1", "barrel", "overclocked_railgun", 0.0, 21.0, Z0 + 13.2, 9.0, 12.0, 5.0)
    # The mast, low and faceted, and the uplink's array on it.
    MZ = Z0 + 14.0
    _rings(b, [[(-6.0, -12.0, MZ), (6.0, -12.0, MZ), (6.0, 4.0, MZ), (-6.0, 4.0, MZ)],
               [(-2.6, -7.0, MZ + 7.0), (2.6, -7.0, MZ + 7.0), (2.6, -2.0, MZ + 7.0), (-2.6, -2.0, MZ + 7.0)]], "steel.dark", "mast")
    _uplink(b, -4.5, MZ + 7.0)
    _salvo_box(b, -15.0, -24.0, MZ, 13.0)
    _gun_house(b, "turret_aft", "hp_2", "twin_barrel", "twin_autoguns", 0.0, -38.0, MZ, 8.0, 10.0, 4.4)
    b.pad("hp_3", (8.0, -49.0, MZ + 1.0), scale=0.8, size=(4.4, 1.4))
    # Two boosters let into the stern face, their mouths flattened.
    for s in (-1.0, 1.0):
        _booster(b, s * 9.5, Z0 + 5.4, -54.0, -63.0, 12.0, 5.6)
    _acts(b, "turret_fore", "turret_aft")

ktlook_giant_shadow.maker = KT


LOOKS = ["ktlook_giant_ses", "ktlook_giant_shadow"]

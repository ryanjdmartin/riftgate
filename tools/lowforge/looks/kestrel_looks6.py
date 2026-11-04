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
bare (the Bleed Valve shows nowhere). The second round, the same day (below the first): the
navy's again with the line's flair, and a racing catamaran built Kestrel's from the start. Not
content: built only by build_look.py, x right, y forward, z up, as in models_low.py. Floats:
the lowest point at z = 6."""

import math

from mathutils import Matrix, Vector

from bl_low import hexagon, rect
from models_low import _blade_section, _chine_section, _disc, _fin_section, _hexr, _jet_canopy, _lerp_at, _poly, _rings, _slab, _tube

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


# ---------------------------------------------------------------- the second round (31 October)
# Ryan, 31 October, of the two above: "Catamaran - navy version is a good start, and I like it,
# see if you can add more Kestrel flair to it. But it is good, I'd be happy with how it is. At
# the same time, let's try that direction, and try again but way more Kestrel from the start,
# sleek, fast-looking." So the navy's once more with the line's marks, and a fresh military
# catamaran built from Kestrel's register outward.

def _giant_booster(b, cx, cz, y_front, y_back, r, band=(1.2, 4.8)):
    """One of the line's giant boosters: a hexagonal drum, a vertex at its top, from `y_front`
    back to `y_back`; a cobalt band round it near its front, painted on rather than proud;
    the lit ring at its end and the exhaust's mouth inside the ring."""
    ph = math.pi / 6
    b.prism("y", cx, (y_front + y_back) / 2.0, cz, r, y_front - y_back, "steel.dark", 6, "booster", phase=ph)
    b.prism("y", cx, y_front - (band[0] + band[1]) / 2.0, cz, r + 0.1, band[1] - band[0], "livery.livery", 6, "booster_band", phase=ph)
    b.prism("y", cx, y_back, cz, r + 0.4, 1.6, "amber.engine", 6, "booster_ring", phase=ph)
    b.loft([(y_back - 0.8, _hexr(cx, cz, r + 0.2)), (y_back - 1.3, _hexr(cx, cz, r - 0.6))], "amber.exhaust", "exhaust")


def _chevron(b, cx, apex_y, span, sweep, width, zf, label="chevron"):
    """A cobalt chevron laid on a surface, pointing forward: its apex at (cx, apex_y), its arms
    `span` out to each side and swept `sweep` back, `width` deep; `zf(x, y)` the surface."""
    pts = [(cx, apex_y), (cx + span, apex_y - sweep), (cx + span, apex_y - sweep - width), (cx, apex_y - width),
           (cx - span, apex_y - sweep - width), (cx - span, apex_y - sweep)]
    return _slab(b, [(x, y, zf(x, y) + 0.15) for (x, y) in pts], (0.0, 0.0, 1.0), 0.4, "livery.livery", label)


def ktlook_giant_ses2(b):
    """The navy's with the line's flair: ktlook_giant_ses's shape and register kept whole (the
    knife hulls and their raked stems, the cushion and its seals, the raised centre bow with
    the fore gun house, the full-beam deckhouse leaning in, the integrated mast and the salvo
    flush in the roof) and Kestrel's marks added where the navy's ship had stealth's. Each
    hull's tail closes onto one of the line's giant boosters in place of the flattened slot: a
    hexagonal drum with a cobalt band, the lit ring and the exhaust; a canted cobalt fin on
    each drum, swept back. The bridge is a jet's canopy rising out of the deckhouse's raked
    face onto the roof, a frame band across it, where the band of glass was. Cobalt speed
    chevrons on each hull's foredeck in place of the straight stripe; the mast raked aft.
    Swept speed stripes on the deckhouse's flanks were tried and left out: from the codex
    angle the house's lean stood them up as two bars."""
    HX = 22.0
    HULL = [(78.0, 0.8, 7.6, 8.6), (72.0, 3.2, 6.8, 12.4), (62.0, 7.6, 6.2, 17.8), (48.0, 11.4, 6.0, 20.0),
            (20.0, 13.0, 6.0, 20.0), (-40.0, 13.0, 6.0, 20.0), (-56.0, 12.4, 6.4, 20.0), (-59.0, 11.9, 6.7, 19.7)]   # (y, w, keel, deck), bow to stern

    def at(y):
        return _lerp_at(HULL, y)

    def side(w, z0, z1, s, upper):
        zc = z0 + (z1 - z0) * 0.38
        pts = ([(HX - w * 0.46, zc), (HX + w * 0.5, zc), (HX + w * 0.34, z1), (HX - w * 0.36, z1)] if upper else
               [(HX - w * 0.12, z0), (HX + w * 0.12, z0), (HX + w * 0.5, zc), (HX - w * 0.46, zc)])
        return pts if s > 0 else [(-x, z) for (x, z) in reversed(pts)]

    BZ, BR, BY0, BY1 = 14.6, 8.0, -62.0, -77.0   # the drums: centre height, radius, front, back
    for s in (-1.0, 1.0):
        b.loft([(y, side(w, z0, z1, s, False)) for (y, w, z0, z1) in HULL], "steel.dark", "hull_low")
        b.loft([(y, side(w, z0, z1, s, True)) for (y, w, z0, z1) in HULL], "steel.plate", "hull")
        secs = []
        for (y, w, z0, z1) in HULL[2:-1]:
            zc, x = z0 + (z1 - z0) * 0.38, HX + w * 0.5
            pts = [(x + 0.4, zc), (x - 0.3, zc + 0.8), (x - 1.2, zc), (x - 0.3, zc - 0.8)]
            secs.append((y, pts if s > 0 else [(-xx, z) for (xx, z) in reversed(pts)]))
        b.loft(secs, "livery.livery", "chine_stripe")
        # Speed chevrons on the foredeck in place of its stripe; the afterdeck's stripe kept.
        for ay in (58.0, 53.0, 48.0):
            _chevron(b, s * HX, ay, at(ay - 2.2)[0] * 0.3, 2.2, 1.6, lambda x, y: at(y)[2], "deck_chevron")
        b.loft([(-34.0, rect(s * HX, 3.6, 19.6, 20.3)), (-54.0, rect(s * HX, 3.6, 19.6, 20.3))], "livery.livery", "deck_stripe")
        # Astern, the hull's tail closes onto its drum: the deck, the chines and the keel drawn
        # onto the drum's six corners.
        y, w, z0, z1 = HULL[-1]
        zc = z0 + (z1 - z0) * 0.38
        end = [(w * 0.34, z1), (0.0, z1), (-w * 0.36, z1), (-w * 0.46, zc), (0.0, z0), (w * 0.5, zc)]
        drum = [(BR * math.cos(math.pi / 6 + i * math.pi / 3), BZ + BR * math.sin(math.pi / 6 + i * math.pi / 3)) for i in range(6)]
        b.loft([(y, [(s * (HX + u), z) for (u, z) in end]), (BY0, [(s * (HX + u), z) for (u, z) in drum])], "steel.plate", "tail_fairing")
        _giant_booster(b, s * HX, BZ, BY0, BY1, BR)
        # A canted fin on the drum, swept back.
        _rings(b, [_fin_section(s * HX, BY0 + 1.0, BY1 + 1.0, BZ + BR - 0.8, 0.8), _fin_section(s * (HX + 5.0), BY1 + 3.5, BY1 - 2.0, BZ + BR + 10.0, 0.35)],
               "livery.livery", "fin")
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
    # The deckhouse: every face leaning in.
    DZ = 20.0
    DH = [(39.0, 25.6, 11.0, 23.0), (31.0, 26.2, 15.0, 31.0), (4.0, 26.4, 16.0, 31.6), (-26.0, 26.4, 16.0, 31.6), (-33.0, 26.2, 12.0, 25.0)]   # (y, base half width, roof half width, roof)
    b.loft([(y, [(-a, DZ), (a, DZ), (t, zt), (-t, zt)]) for (y, a, t, zt) in DH], "steel.panel", "deckhouse")
    # The bridge: a jet's canopy rising out of the raked face onto the roof, a frame band across it.
    roof = lambda y: _lerp_at([(39.0, 23.0), (31.0, 31.0), (4.0, 31.6)], y)[0]
    CAN = [(37.6, 2.2, 0.3), (35.0, 4.6, 1.4), (31.0, 6.0, 2.6), (25.0, 6.2, 3.0), (18.0, 5.2, 2.4), (13.0, 3.2, 1.2), (10.0, 1.2, 0.3)]   # (y, half width, height over the house)

    def cab(y, hw, h, grow=0.0):
        z, hw = roof(y), hw + grow
        return [(-hw, z - 0.8), (hw, z - 0.8), (hw, z + h * 0.5 + grow), (hw * 0.55, z + h + grow), (-hw * 0.55, z + h + grow), (-hw, z + h * 0.5 + grow)]
    b.loft([(y, cab(y, hw, h)) for (y, hw, h) in CAN], "glass.glass", "canopy")
    hw, h = _lerp_at(CAN, 27.5)
    b.loft([(28.1, cab(28.1, hw, h, 0.3)), (26.9, cab(26.9, hw, h, 0.3))], "steel.dark", "canopy_frame")
    for s in (-1.0, 1.0):
        b.loft([(30.0, rect(s * 13.4, 2.0, 31.4, 31.9)), (-25.0, rect(s * 13.4, 2.0, 31.4, 31.9))], "livery.livery", "roof_stripe")
    # The integrated mast, a faceted pyramid on the roof raked aft, and the uplink's array on it.
    MZ = 31.4
    _rings(b, [[(-7.0, -12.0, MZ), (7.0, -12.0, MZ), (7.0, 6.0, MZ), (-7.0, 6.0, MZ)],
               [(-2.8, -9.0, MZ + 11.0), (2.8, -9.0, MZ + 11.0), (2.8, -4.0, MZ + 11.0), (-2.8, -4.0, MZ + 11.0)]], "steel.panel", "mast")
    _uplink(b, -6.5, MZ + 11.0)
    _salvo_box(b, -16.5, -25.5, 31.6, 13.0)
    # The quarterdeck: the aft gun house, hp_3 bare beside it.
    _gun_house(b, "turret_aft", "hp_2", "twin_barrel", "twin_autoguns", 0.0, -43.0, DZ, 8.0, 10.0, 4.4)
    b.pad("hp_3", (12.5, -47.0, DZ + 1.0), scale=0.8, size=(4.4, 1.4))
    _acts(b, "turret_fore", "turret_aft")

ktlook_giant_ses2.maker = KT


def ktlook_giant_racer(b):
    """A fresh try in the same direction, Kestrel's from the start: an offshore racing
    catamaran crossed with a jet and a warship. Two long, low knife hulls, slimmer and lower
    than the navy's, their stems raked back under a long fine entry, dark below the chine and
    chrome above, a cobalt chine stripe and speed chevrons on the foredecks. Between them a
    ram wing as the tunnel's roof (the ground-effect racer's lifting deck), its leading edge
    swept back from the pod's nose to the hulls, a cobalt band along it, lift glowing under it.
    On it the centre pod, a jet's chined fuselage tapering to a dark radome at the bow: the
    fore gun house (hp_1) on its nose, a fighter's canopy with a frame band, the salvo's box
    flush in the spine behind it (its tubes clear the canopy as it rises), the uplink's array,
    and the aft gun house (hp_2) on a raised tail deck, its barrels over the bare spine. Two
    giant boosters astern either side of the pod's tail, their nacelles rising out of the ram
    wing; over them a swept cobalt aerofoil spanning the hulls on the tips of two canted fins
    standing on the hulls' sterns, as tunnel-hull racers carry. hp_3 bare on the ram wing.
    Floats: the keels at z = 6."""
    HX = 24.0
    HULL = [(86.0, 0.6, 15.0, 15.8), (80.0, 2.8, 11.6, 16.3), (70.0, 5.8, 8.2, 16.8), (56.0, 8.4, 6.4, 17.0),
            (36.0, 9.6, 6.0, 17.0), (-34.0, 9.6, 6.0, 16.6), (-52.0, 9.0, 6.3, 16.2), (-62.0, 8.0, 6.8, 15.6)]   # (y, w, keel, deck), bow to stern

    def at(y):
        return _lerp_at(HULL, y)

    def side(w, z0, z1, s, upper):
        zc = z0 + (z1 - z0) * 0.42
        pts = ([(HX - w * 0.46, zc), (HX + w * 0.5, zc), (HX + w * 0.3, z1), (HX - w * 0.3, z1)] if upper else
               [(HX - w * 0.1, z0), (HX + w * 0.1, z0), (HX + w * 0.5, zc), (HX - w * 0.46, zc)])
        return pts if s > 0 else [(-x, z) for (x, z) in reversed(pts)]

    for s in (-1.0, 1.0):
        b.loft([(y, side(w, z0, z1, s, False)) for (y, w, z0, z1) in HULL], "steel.dark", "hull_low")
        b.loft([(y, side(w, z0, z1, s, True)) for (y, w, z0, z1) in HULL], "steel.plate", "hull")
        secs = []
        for (y, w, z0, z1) in HULL[1:-1]:
            zc, x = z0 + (z1 - z0) * 0.42, HX + w * 0.5
            pts = [(x + 0.4, zc), (x - 0.3, zc + 0.7), (x - 1.2, zc), (x - 0.3, zc - 0.7)]
            secs.append((y, pts if s > 0 else [(-xx, z) for (xx, z) in reversed(pts)]))
        b.loft(secs, "livery.livery", "chine_stripe")
        for ay in (52.0, 47.0, 42.0):
            _chevron(b, s * HX, ay, at(ay - 2.0)[0] * 0.27, 2.0, 1.4, lambda x, y: at(y)[2], "deck_chevron")
    # The ram wing: the tunnel's roof as a lifting deck, its ends inside the hulls, its leading
    # edge swept back from the pod's nose to the hulls.
    WZ = 14.4
    RAM = [(-21.5, 26.0, -30.0, 1.8), (-7.0, 50.0, -30.0, 2.4), (0.0, 58.0, -30.0, 2.4), (7.0, 50.0, -30.0, 2.4), (21.5, 26.0, -30.0, 1.8)]   # (x, leading edge, trailing edge, half thickness)
    _rings(b, [_blade_section(x, le, te, WZ, t, lead=0.3) for (x, le, te, t) in RAM], "steel.plate", "ram_wing")

    def ram_at(x):
        le, te, t = _lerp_at([(-abs(xx), le, te, t) for (xx, le, te, t) in RAM[2:]], -abs(x))
        return le, te, t, le - (le - te) * 0.3

    def ram(x, y, upper=True):
        """The ram wing's top (or underside) at (x, y)."""
        le, te, t, ym = ram_at(x)
        k = (y - te) / (ym - te) if y < ym else (le - y) / (le - ym)
        return WZ + (t if upper else -t) * max(0.0, min(1.0, k))
    # A cobalt band along the leading edge, the arrow's outline from above.
    band = []
    for (x, le, te, t) in RAM:
        y0, y1 = le - 0.2, le - 3.6
        band.append([(x, y0, ram(x, y0) + 0.15), (x, y1, ram(x, y1) + 0.15), (x, y1, ram(x, y1) - 0.3), (x, y0, ram(x, y0) - 0.3)])
    _rings(b, band, "livery.livery", "ram_band")
    for (x, y) in ((-12.0, 24.0), (12.0, 24.0), (-12.0, -6.0), (12.0, -6.0), (0.0, 36.0)):
        _disc(b, (x, y, ram(x, y, False) - 0.15), (0.0, 0.0, -1.0), 2.6, 6, "amber.engine", "lift_nozzle")
    # The centre pod: a jet's chined fuselage on the ram wing, a cobalt stripe on each chine, its
    # tail a raised deck between the boosters for the aft gun house.
    POD = [(76.0, 1.0, 15.0, 16.0), (68.0, 5.4, 13.4, 18.6), (56.0, 10.0, 12.2, 21.2), (42.0, 13.0, 12.0, 22.8), (24.0, 14.0, 12.0, 23.4),
           (4.0, 13.6, 12.0, 23.0), (-16.0, 12.0, 12.2, 22.2), (-34.0, 9.6, 12.6, 21.6), (-42.0, 5.0, 13.6, 19.4)]   # (y, w, belly, top)
    top = lambda y: _lerp_at([(y, z1) for (y, w, z0, z1) in POD], y)[0]
    b.loft([(y, _chine_section(z0, z1, w, 0.0)) for (y, w, z0, z1) in POD], "steel.plate", "pod")
    w, z0, z1 = _lerp_at(POD, 71.0)
    b.loft([(71.0, _chine_section(z0 - 0.15, z1 + 0.15, w + 0.3, 0.0)), (79.0, _chine_section(15.3, 15.8, 0.5, 0.0, belly=0.1))], "steel.dark", "nose_tip")
    for s in (-1.0, 1.0):
        secs = []
        for (y, w, z0, z1) in POD[1:-2]:
            zc, x = z0 + (z1 - z0) * 0.42, w / 2.0
            pts = [(x + 0.3, zc), (x - 0.3, zc + 0.6), (x - 1.0, zc), (x - 0.3, zc - 0.6)]
            secs.append((y, pts if s > 0 else [(-xx, z) for (xx, z) in reversed(pts)]))
        b.loft(secs, "livery.livery", "pod_stripe")
    # Along the spine, bow to stern: the fore gun house on the nose, the canopy, the salvo's box
    # (its tubes clearing the canopy as it rises), the uplink, and the aft gun house on the tail
    # deck, its barrels over the bare spine.
    _gun_house(b, "turret_fore", "hp_1", "barrel", "overclocked_railgun", 0.0, 54.0, top(54.0), 8.0, 10.0, 4.4)
    _jet_canopy(b, [(y, w, z1, z0) for (y, w, z0, z1) in POD], [(46.0, 1.2, 0.6), (41.0, 3.8, 3.0), (34.0, 4.6, 4.4), (27.0, 4.4, 4.0), (21.0, 3.0, 2.0), (17.0, 1.2, 0.5)], 33.0)
    _salvo_box(b, 14.0, 4.0, top(9.0), 10.0)
    _uplink(b, -1.0, top(-1.0), panel=4.6)
    _gun_house(b, "turret_aft", "hp_2", "twin_barrel", "twin_autoguns", 0.0, -30.0, top(-30.0), 8.0, 9.0, 4.0)
    b.pad("hp_3", (12.5, 6.0, ram(12.5, 6.0) + 1.0), scale=0.8, size=(4.4, 1.4))
    # The giant boosters either side of the pod's tail, each nacelle rising out of the ram wing.
    DX, DZ, DR, DY0, DY1 = 11.5, 14.6, 6.4, -26.0, -58.0
    for s in (-1.0, 1.0):
        b.loft([(-8.0, _hexr(s * DX, DZ + 0.6, 1.4)), (DY0, _hexr(s * DX, DZ, DR))], "steel.plate", "nacelle")
        _giant_booster(b, s * DX, DZ, DY0, DY1, DR)
    # The stern wing: a swept cobalt aerofoil spanning the hulls on the tips of two canted fins
    # that stand on the hulls' sterns, swept back.
    WZ2, FX = 28.0, 6.0   # the wing's height, and the fins' cant outward at it
    for s in (-1.0, 1.0):
        _rings(b, [_fin_section(s * HX, -34.0, -60.0, at(-48.0)[2] - 0.5, 0.9), _fin_section(s * (HX + FX), -51.0, -61.0, WZ2, 0.5)], "livery.livery", "fin")
    WING = [(-(HX + FX), -51.5, -60.0, 0.4), (-12.0, -46.0, -55.6, 0.7), (0.0, -42.0, -52.4, 0.85), (12.0, -46.0, -55.6, 0.7), (HX + FX, -51.5, -60.0, 0.4)]
    _rings(b, [_blade_section(x, le, te, WZ2, t) for (x, le, te, t) in WING], "livery.livery", "stern_wing")
    _acts(b, "turret_fore", "turret_aft")

ktlook_giant_racer.maker = KT


LOOKS = ["ktlook_giant_ses", "ktlook_giant_shadow", "ktlook_giant_ses2", "ktlook_giant_racer"]

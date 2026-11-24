"""Look tests for the echidna (Minerva, tier two, a tank that fights and wants to be struck:
its brief, retired with its model of 24 November, in git), the same machine two ways, as Ryan named them on 15 November:
"Echidna I had two general ideas, either a half track, or a heavily armored car with protected
wheels." His frame for it, 15 October: "a wheeled crawler ... relatively fast for a Minerva, more
offensive, play up the 'knuckles the echidna' soft reference."

Both carry the echidna the same way, so the sheet compares the running gear and the hull: a back
of thick quills raked toward the tail over a green shell, longer toward the tail so the whole
machine rakes forward; a long low snout ending in a needle; and a ram block with two blunt spikes
on each front corner, a fist's two knuckles, the soft nod as a cue and no character's likeness.
Lower and longer than the Badger, in Minerva's own steel and green.

    mnlook_echidna_halftrack   steered wheels in the open either side of a long bonnet for a
                               snout, a track unit under the rear body, a gun ring over the cab
    mnlook_echidna_car         six heavy wheels, each in its own boxed housing with only its foot
                               showing, a faceted hull with a wedge glacis, a low turret

Nothing about its kit is settled, so each wears three hardpoints as placeholders: hp_1 a gun
forward (the cab's ring, the car's turret), hp_2 a rack and hp_3 a bare mount on the flanks. Not
content: built only by build_look.py and sheet.py. x right, y forward, z up, the ground at z = 0.

The second round (SHEET2), on his notes of 15 November: "Echidna - I like the armoured car. How
does it turn? Like a tank? I don't think the spines need to be so on the nose - remember the
machines were nicknamed after animals they resemble or act like, not designed to look like a
particular animal." So the armoured car alone, as a fighting vehicle that earns the nickname and
is no model of the animal: the same hull, glacis, turret and six boxed wheel stations, the
animal's snout cut back to a blunt wedge prow with a cap, the green shell lowered to an engine
cover, the rams' spikes blunted to two bosses. It turns as a tank does, by skid steer: each
side's three wheels are driven together and the sides against each other, so nothing steers,
the housings stay rigid and tight on one sill, a drive case runs between the stations and the
hubs are heavy (`pivots`: the whole machine turns on the spot to aim). The bristle three ways,
in steel and the maker's green, nothing bone white:

    mnlook_echidna2_a   the bristle as its kit: two raked banks of short emitter rods along the
                        engine cover, dark with lit tips, a driver between them and one emitter
                        off the prow (a guess at the Sonic Needle's emitters)
    mnlook_echidna2_b   the bristle as its armour: a comb of raked plates across the engine
                        cover, longer toward the tail, a ridged back from above
    mnlook_echidna2_c   barely there: the plain car, its low domed cover with its grilles and a
                        few whip aerials, the nickname left to how it acts
"""

import math

from mathutils import Vector

from bl_low import rect
from models_low import _beam, _chamfered, _spike, _sq, _wheel

MN = "minerva"
QUILL, QUILL_TIP = "bone.bone", "steel.dark"   # a pale shaft and a dark point, as the animal's: the back has to read from above


def _at(table, y):
    """A value read off (y, value) stations, straight between them and held past the ends."""
    table = sorted(table)
    if y <= table[0][0]:
        return table[0][1]
    for (y0, v0), (y1, v1) in zip(table, table[1:]):
        if y <= y1:
            return v0 + (v1 - v0) * (y - y0) / (y1 - y0)
    return table[-1][1]


def _quill(b, base, length, rake, splay=0.0, half=2.3):
    """One spine: a thick four-sided quill rooted at `base`, `rake` degrees up off the deck toward
    the tail and `splay` degrees out to the side (positive to the right), its shaft tapering to a
    dark point."""
    r, s = math.radians(rake), math.radians(splay)
    d = Vector((math.sin(s) * math.cos(r), -math.cos(s) * math.cos(r), math.sin(r)))
    root = Vector(base) - d * 1.5
    mid = Vector(base) + d * (length * 0.58)
    tip = Vector(base) + d * length
    _beam(b, tuple(root), tuple(mid), _sq(half * 2.0, half * 2.0), _sq(half * 1.3, half * 1.3), QUILL, "quill")
    _spike(b, tuple(mid), tuple(tip), half * 0.65, QUILL_TIP, "quill_tip")


def _spine_back(b, crown, ys, half_top, shoulder, flank=None, tail=None, bare_last=False):
    """The echidna's back: rows of quills over the shell at the stations `ys`, front to back,
    longer toward the tail. Three and two across the crown by turns (`crown` is the shell's top
    as (y, z) stations, `half_top` half its flat), one on each shoulder splayed out (`shoulder`:
    how far out it roots and how far under the crown), a low row on each flank from the row
    `flank` names back (x, z, first row), and two off the tail (`tail`: its y and z).
    `bare_last` leaves the last row its crown quills alone, where the shell has narrowed."""
    n = len(ys)
    for r, y in enumerate(ys):
        f = r / (n - 1.0)
        length = 11.0 + 6.5 * f
        z = _at(crown, y) - 0.4
        for u in ((-0.72, 0.0, 0.72) if r % 2 == 0 else (-0.38, 0.38)):
            _quill(b, (u * half_top, y, z), length, 36.0, splay=16.0 * u)
        if bare_last and r == n - 1:
            continue
        sx, sdz = shoulder
        for s in (-1.0, 1.0):
            _quill(b, (s * sx, y - 2.5, z - sdz), length * 0.9, 28.0, splay=s * 36.0)
            if flank is not None and r >= flank[2]:
                _quill(b, (s * flank[0], y + 1.0, flank[1]), length * 0.8, 14.0, splay=s * 58.0)
    if tail is not None:
        for s in (-1.0, 1.0):
            _quill(b, (s * 5.5, tail[0], tail[1]), 15.0, 24.0, splay=s * 12.0)


def _knuckle(b, s, x, y0, y1, z0, z1, w=11.0):
    """A ram block on a front corner with two blunt spikes off its face: the soft nod, a fist's
    two knuckles."""
    b.box(x - w / 2.0, x + w / 2.0, y0, y1, z0, z1, "livery.livery2", "knuckle")
    b.box(x - w / 2.0 - 0.6, x + w / 2.0 + 0.6, y0 + 1.0, y0 + 3.6, z0 - 0.6, z1 + 0.6, "steel.dark", "knuckle_strap")
    zc = (z0 + z1) / 2.0
    for k in (-1.0, 1.0):
        px = x + k * w * 0.25
        _beam(b, (px, y1 - 0.5, zc), (px + s * 1.4, y1 + 8.5, zc + 1.0), _sq(4.8, 5.8), _sq(1.5, 1.9), "steel.dark", "knuckle_spike")


def _snout(b, sections, nose_from):
    """The long low snout: the hull's sections drawn out to a point, its last stretch a dark
    nose with the needle off its tip. `sections` are (y, width, z0, z1, chamfer) stations and
    `nose_from` the index the dark nose starts at."""
    secs = [(y, _chamfered(0.0, w, z0, z1, c)) for y, w, z0, z1, c in sections]
    b.loft(secs[:nose_from + 1], "steel.panel", "snout")
    b.loft(secs[nose_from:], "steel.dark", "nose")
    y, w, z0, z1, _c = sections[-1]
    zc = (z0 + z1) / 2.0
    _spike(b, (0.0, y - 0.5, zc), (0.0, y + 9.0, zc - 0.6), 0.9, "steel.dark", "needle")


def mnlook_echidna_halftrack(b):
    """The half-track: two heavy steered wheels in the open either side of a long bonnet that is
    the snout, a narrow wing over each tyre's inner edge alone; a track unit under each side of the
    rear body, the cab between with a raked windscreen under a brow and a gun ring on its roof, the
    quills over the rear body."""
    TX, TW, TH = 21.0, 14.0, 16.0   # the track units: centre, width, height
    for s in (-1.0, 1.0):
        cx = s * TX
        b.loft([(-40.0, rect(cx, TW, 5.0, 11.0)), (-34.0, rect(cx, TW, 0.0, TH)), (1.0, rect(cx, TW, 0.0, TH)), (9.0, rect(cx, TW, 7.0, 15.0))], "bore.tread", "tread")   # the front run climbing to its sprocket
        # A fender over the track's inner half alone, so its outer run shows from above as a track.
        b.box(min(s * 13.0, s * 24.5), max(s * 13.0, s * 24.5), -37.0, 4.0, TH - 1.0, TH + 1.5, "steel.plate", "fender")
    # The frame rail forward to the front axle, the rear body over the tracks, the shell on it.
    b.loft([(-38.0, rect(0.0, 26.0, 7.0, 16.0)), (10.0, rect(0.0, 26.0, 7.0, 16.0)), (38.0, rect(0.0, 16.0, 8.0, 13.0))], "steel.dark", "chassis")
    b.loft([(-40.0, _chamfered(0.0, 38.0, 16.0, 23.0, 3.0)), (-35.0, _chamfered(0.0, 44.0, 15.0, 26.0, 3.0)), (4.0, _chamfered(0.0, 44.0, 15.0, 26.0, 3.0))], "steel.panel", "body")
    b.box(-14.0, 14.0, -40.7, -39.8, 16.5, 22.0, "steel.vent", "rear_vents")
    crown = [(-43.0, 27.0), (-36.0, 32.0), (-3.0, 33.0), (4.0, 30.0)]
    b.loft([(-43.0, _chamfered(0.0, 28.0, 21.0, 27.0, 4.0)), (-36.0, _chamfered(0.0, 42.0, 25.0, 32.0, 6.0)),
            (-3.0, _chamfered(0.0, 42.0, 25.0, 33.0, 6.0)), (4.0, _chamfered(0.0, 36.0, 25.0, 30.0, 4.0))], "livery.livery2", "carapace")
    # The cab: a raked windscreen under a brow, lamps on its face either side of the bonnet.
    b.loft([(4.0, _chamfered(0.0, 40.0, 15.0, 31.0, 5.0)), (12.0, _chamfered(0.0, 38.0, 15.0, 30.0, 5.0)), (19.0, _chamfered(0.0, 34.0, 14.0, 23.0, 3.0))], "steel.panel", "cab")
    b.loft([(12.6, rect(0.0, 24.0, 26.2, 29.9)), (17.6, rect(0.0, 23.0, 21.2, 24.9))], "glass.glass", "windscreen")
    b.loft([(8.0, rect(0.0, 30.0, 30.4, 32.0)), (14.0, rect(0.0, 28.0, 29.4, 31.0))], "steel.plate", "brow")
    for s in (-1.0, 1.0):
        b.box(s * 15.3 - 1.6, s * 15.3 + 1.6, 18.4, 20.0, 16.5, 20.0, "amber.light", "lamp")
    # The bonnet drawn out into the snout, a vent on its back.
    _snout(b, [(19.0, 27.0, 10.0, 22.0, 3.0), (31.0, 19.0, 10.0, 18.5, 2.5), (40.0, 10.0, 11.0, 15.5, 1.5), (46.0, 4.5, 12.0, 14.2, 0.6)], 2)
    b.loft([(21.0, rect(0.0, 12.0, 20.6, 21.9)), (29.5, rect(0.0, 10.0, 18.2, 19.5))], "steel.vent", "bonnet_vent")
    # The front axle: two heavy wheels in the open.
    b.box(-24.0, 24.0, 25.5, 28.5, 9.5, 12.5, "steel.dark", "axle")
    for s in (-1.0, 1.0):
        cx = s * 24.0
        _wheel(b, cx, 27.0, 11.0, 10.0, "wheel_front")
        # The wing: a strip off the cab's front corner over the tyre's inner edge and down to the
        # bumper, so the tyre stays in the open from the side and from above.
        gx = s * 19.75
        b.loft([(18.0, rect(gx, 5.5, 21.4, 22.9)), (23.0, rect(gx, 5.5, 23.3, 24.6)), (31.0, rect(gx, 5.5, 23.3, 24.6)),
                (36.5, rect(gx, 5.5, 19.5, 20.8)), (39.6, rect(gx, 5.5, 12.6, 13.9))], "steel.plate", "mudguard")
        # An apron from the bonnet's flank out to the wing, over the axle, so the nose is one body from above.
        ax = s * 12.5
        b.loft([(19.0, rect(ax, 9.5, 17.0, 18.5)), (31.0, rect(ax, 9.5, 14.5, 16.0)), (36.5, rect(ax, 9.5, 13.0, 14.5))], "steel.panel", "apron")
    # The bumper under the snout and a knuckle on each end, ahead of the wheels.
    b.box(-27.0, 27.0, 37.6, 40.0, 7.0, 11.5, "steel.dark", "bumper")
    for s in (-1.0, 1.0):
        _knuckle(b, s, s * 22.0, 37.2, 44.5, 4.0, 15.0)
    # Mounts, placeholders: a gun on a ring over the cab, a rack and a bare mount on shelves beside the cab.
    b.prism("z", 0.0, 9.0, 31.0, 6.5, 1.2, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, 9.0, 31.6)):
        b.prism("z", 0.0, 9.0, 33.6, 5.5, 4.0, "steel.plate", 8, "pulpit", phase=math.pi / 8)
        b.stock("hp_1", (0.0, 12.5, 33.8), "barrel", scale=0.8, carries="slugthrower")
    for s in (-1.0, 1.0):
        b.box(min(s * 19.0, s * 27.5), max(s * 19.0, s * 27.5), 4.5, 14.5, 20.0, 22.5, "steel.plate", "shelf")
    b.stock("hp_2", (-23.5, 9.5, 22.5), "rack", scale=0.7, carries="shotfire_rack")
    b.pad("hp_3", (23.5, 9.5, 23.5), size=(7.0, 1.0))
    _spine_back(b, crown, [-4.0, -11.5, -19.0, -26.5, -34.0], 15.0, (18.0, 2.6), flank=(21.5, 23.5, 2), tail=(-40.0, 28.5))


mnlook_echidna_halftrack.maker = MN


def mnlook_echidna_car(b):
    """The armoured car: six heavy wheels, each in its own boxed housing off the hull's flank
    with only its foot showing, a plate and a hub cap on the housing's face; a faceted hull with
    a wedge glacis over a vision slit, the snout out between the front housings, a low turret
    ahead of the quills."""
    for s in (-1.0, 1.0):
        for yc in (27.0, 0.0, -27.0):
            hx = s * 24.0
            _wheel(b, s * 23.0, yc, 10.0, 11.0)
            b.loft([(yc - 12.5, rect(hx, 13.0, 11.5, 17.0)), (yc - 9.0, rect(hx, 13.0, 7.5, 22.0)),
                    (yc + 9.0, rect(hx, 13.0, 7.5, 22.0)), (yc + 12.5, rect(hx, 13.0, 11.5, 17.0))], "steel.plate", "housing")
            xo = s * 30.5
            b.box(min(xo, xo + s * 1.4), max(xo, xo + s * 1.4), yc - 8.0, yc + 8.0, 9.5, 20.5, "livery.livery2", "housing_plate")
            b.prism("x", xo + s * 1.6, yc, 13.0, 4.6, 1.8, "steel.dark", 8, "hub_cap", phase=math.pi / 8)
    # The belly between the wheels and the faceted hull over it, its glacis wedged down to the snout.
    b.loft([(-39.0, rect(0.0, 36.0, 9.0, 15.0)), (-34.0, rect(0.0, 36.0, 6.0, 16.0)), (34.0, rect(0.0, 36.0, 6.0, 16.0)), (40.0, rect(0.0, 30.0, 9.0, 15.0))], "steel.dark", "belly")
    b.loft([(-41.0, _chamfered(0.0, 34.0, 14.0, 23.0, 5.0)), (-35.0, _chamfered(0.0, 42.0, 13.0, 29.0, 6.0)), (9.0, _chamfered(0.0, 42.0, 13.0, 29.0, 6.0)),
            (29.0, _chamfered(0.0, 36.0, 12.0, 20.0, 4.0))], "steel.panel", "hull")
    b.box(-13.0, 13.0, -41.8, -40.9, 15.0, 21.0, "steel.vent", "rear_vents")
    b.loft([(12.0, rect(0.0, 28.0, 24.0, 28.1)), (17.0, rect(0.0, 27.0, 22.0, 25.9))], "glass.glass", "slit")
    b.loft([(7.5, rect(0.0, 32.0, 28.6, 30.2)), (12.5, rect(0.0, 31.0, 27.5, 29.0))], "steel.plate", "brow")
    _snout(b, [(29.0, 36.0, 12.0, 20.0, 4.0), (36.0, 16.0, 11.0, 17.0, 2.5), (45.0, 9.0, 11.5, 15.5, 1.5), (50.0, 4.5, 12.0, 14.2, 0.6)], 2)
    for s in (-1.0, 1.0):
        b.box(s * 12.5 - 2.0, s * 12.5 + 2.0, 30.4, 32.4, 14.0, 17.5, "amber.light", "lamp")
    # The bumper under the snout and a knuckle on the front of each front housing.
    b.box(-24.0, 24.0, 39.5, 42.0, 7.0, 11.0, "steel.dark", "bumper")
    for s in (-1.0, 1.0):
        _knuckle(b, s, s * 24.0, 39.0, 46.0, 4.5, 16.0)
    # The shell over the rear two thirds, the turret ahead of it.
    crown = [(-44.0, 27.0), (-37.0, 34.0), (-12.0, 35.0), (-6.0, 32.0)]
    b.loft([(-44.0, _chamfered(0.0, 28.0, 21.0, 27.0, 4.0)), (-37.0, _chamfered(0.0, 44.0, 25.0, 34.0, 7.0)),
            (-12.0, _chamfered(0.0, 44.0, 25.0, 35.0, 7.0)), (-6.0, _chamfered(0.0, 38.0, 26.0, 32.0, 5.0))], "livery.livery2", "carapace")
    # Mounts, placeholders: the turret's gun, a rack and a bare mount on the middle housings.
    b.prism("z", 0.0, 2.0, 29.5, 9.5, 1.2, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, 2.0, 30.0)):
        b.prism("z", 0.0, 2.0, 33.2, 8.5, 6.0, "steel.panel", 8, "turret", phase=math.pi / 8)
        b.box(-5.0, 5.0, 8.0, 11.0, 31.0, 35.5, "steel.plate", "mantlet")
        b.box(-3.0, 3.0, -3.5, 1.5, 36.2, 37.0, "steel.plate", "hatch")
        b.stock("hp_1", (0.0, 11.0, 33.2), "barrel", scale=0.85, carries="slugthrower")
    b.stock("hp_2", (-24.0, -1.0, 22.0), "rack", scale=0.62, carries="shotfire_rack")
    b.pad("hp_3", (24.0, 0.0, 23.0), size=(7.0, 1.0))
    _spine_back(b, crown, [-12.0, -19.0, -26.0, -33.0, -39.5], 14.0, (18.5, 3.0), flank=(21.0, 24.0, 2), bare_last=True)


mnlook_echidna_car.maker = MN


# ---------------------------------------------------------------- the second round (15 November)

BEAD = "amber.lit"                       # an emitter's lit tip
STATIONS = (27.0, 0.0, -27.0)            # the three wheel stations a side, evenly spaced
COVER = [(-44.0, 26.0), (-37.0, 31.0), (-12.0, 32.0), (-6.0, 30.0)]   # the engine cover's crown, (y, z)


def _raked(rake, splay=0.0):
    """A direction `rake` degrees up off the deck toward the tail, `splay` degrees out to the
    side (positive to the right)."""
    r, s = math.radians(rake), math.radians(splay)
    return Vector((math.sin(s) * math.cos(r), -math.cos(s) * math.cos(r), math.sin(r)))


def _rod(b, base, d, length, half=0.7, bead=0.85, collar="z"):
    """An emitter rod: a collar where it roots (a ring about `collar`'s axis), a dark rod along
    `d`, a small lit bead on its tip."""
    p, d = Vector(base), Vector(d).normalized()
    if collar == "z":
        b.prism("z", p.x, p.y, p.z + 0.7, 1.8, 1.4, "steel.plate", 6, "emitter_collar")
    else:
        b.prism("y", p.x, p.y + 0.8, p.z, 1.8, 1.6, "steel.plate", 6, "emitter_collar")
    tip = p + d * length
    _beam(b, tuple(p - d * 0.6), tuple(tip), _sq(half * 2.0, half * 2.0), _sq(half * 1.1, half * 1.1), "steel.dark", "emitter")
    _beam(b, tuple(tip - d * 0.2), tuple(tip + d * (bead * 1.8)), _sq(bead * 2.0, bead * 2.0), _sq(bead * 1.3, bead * 1.3), BEAD, "emitter_tip")


def _whip(b, base, height, lean=10.0, splay=0.0):
    """A whip aerial on a spring base, leaning a little toward the tail."""
    l, s = math.radians(lean), math.radians(splay)
    d = Vector((math.sin(s) * math.sin(l), -math.cos(s) * math.sin(l), math.cos(l)))
    p = Vector(base)
    b.prism("z", p.x, p.y, p.z + 1.0, 1.3, 2.0, "steel.dark", 6, "aerial_base")
    _beam(b, tuple(p + Vector((0.0, 0.0, 1.6))), tuple(p + d * height), _sq(0.95, 0.95), _sq(0.55, 0.55), "steel.dark", "aerial")


def _ram(b, s, x, y0, y1, z0, z1, w=11.0):
    """Round two's ram block on a front corner: round one's block and strap, its two knuckles
    blunt bosses in place of spikes, so it reads as a ram first and a fist second."""
    b.box(x - w / 2.0, x + w / 2.0, y0, y1, z0, z1, "livery.livery2", "ram")
    b.box(x - w / 2.0 - 0.6, x + w / 2.0 + 0.6, y0 + 1.0, y0 + 3.6, z0 - 0.6, z1 + 0.6, "steel.dark", "ram_strap")
    zc = (z0 + z1) / 2.0
    for k in (-1.0, 1.0):
        px = x + k * w * 0.25
        _beam(b, (px, y1 - 0.5, zc), (px, y1 + 3.0, zc), _sq(4.6, 6.6), _sq(3.0, 4.4), "steel.dark", "ram_boss")


def _car2(b):
    """Round two's armoured car, the same under every bristle: round one's hull, glacis, turret
    and six boxed wheel stations, made a fighting vehicle first. The stations are fixed and
    driven, three a side on one sill with a drive case between them and a heavy hub on each: it
    turns as a tank does, by skid steer, so nothing steers and the housings stay tight. The
    snout is cut back to a blunt wedge prow with a cap, the shell lowered to an engine cover,
    the rams' spikes blunted to bosses, a whip aerial on the turret. Returns the cover's crown
    height at a y."""
    for s in (-1.0, 1.0):
        xo = s * 30.5
        for yc in STATIONS:
            hx = s * 24.0
            _wheel(b, s * 23.0, yc, 10.0, 11.0)
            b.loft([(yc - 12.5, rect(hx, 13.0, 11.5, 17.0)), (yc - 9.0, rect(hx, 13.0, 7.5, 22.0)),
                    (yc + 9.0, rect(hx, 13.0, 7.5, 22.0)), (yc + 12.5, rect(hx, 13.0, 11.5, 17.0))], "steel.plate", "housing")
            b.box(min(xo, xo + s * 1.4), max(xo, xo + s * 1.4), yc - 8.0, yc + 8.0, 10.5, 20.5, "livery.livery2", "housing_plate")
            b.prism("x", xo + s * 1.9, yc, 12.0, 4.8, 2.2, "steel.dark", 8, "hub", phase=math.pi / 8)
            b.prism("x", xo + s * 3.3, yc, 12.0, 2.3, 1.2, "steel.plate", 8, "hub_cap", phase=math.pi / 8)
        # One sill along the foot of the three housings and a drive case between the stations: one
        # frame, one drive a side.
        b.box(min(xo, xo + s * 1.6), max(xo, xo + s * 1.6), -37.5, 37.5, 7.5, 9.8, "steel.dark", "sill")
        b.box(min(s * 19.0, s * 29.0), max(s * 19.0, s * 29.0), -30.0, 30.0, 9.0, 15.0, "steel.dark", "drive_case")
    # The belly between the wheels and the faceted hull over it, its glacis wedged down to the prow.
    b.loft([(-39.0, rect(0.0, 36.0, 9.0, 15.0)), (-34.0, rect(0.0, 36.0, 6.0, 16.0)), (34.0, rect(0.0, 36.0, 6.0, 16.0)), (40.0, rect(0.0, 30.0, 9.0, 15.0))], "steel.dark", "belly")
    b.loft([(-41.0, _chamfered(0.0, 34.0, 14.0, 23.0, 5.0)), (-35.0, _chamfered(0.0, 42.0, 13.0, 29.0, 6.0)), (9.0, _chamfered(0.0, 42.0, 13.0, 29.0, 6.0)),
            (29.0, _chamfered(0.0, 36.0, 12.0, 20.0, 4.0))], "steel.panel", "hull")
    b.box(-13.0, 13.0, -41.8, -40.9, 15.0, 21.0, "steel.vent", "rear_vents")
    b.loft([(12.0, rect(0.0, 28.0, 24.0, 28.1)), (17.0, rect(0.0, 27.0, 22.0, 25.9))], "glass.glass", "slit")
    b.loft([(7.5, rect(0.0, 32.0, 28.6, 30.2)), (12.5, rect(0.0, 31.0, 27.5, 29.0))], "steel.plate", "brow")
    # The prow: a blunt wedge off the glacis's foot with a dark cap, a vehicle's bow and no snout.
    b.loft([(29.0, _chamfered(0.0, 36.0, 12.0, 20.0, 4.0)), (37.0, _chamfered(0.0, 21.0, 11.0, 17.5, 3.0)), (44.0, _chamfered(0.0, 10.0, 11.5, 15.6, 1.6))], "steel.panel", "prow")
    b.loft([(44.0, _chamfered(0.0, 10.0, 11.5, 15.6, 1.6)), (46.5, _chamfered(0.0, 6.0, 12.2, 14.8, 0.8))], "steel.dark", "prow_cap")
    for s in (-1.0, 1.0):
        b.box(s * 13.0 - 2.2, s * 13.0 + 2.2, 26.2, 28.6, 20.4, 23.2, "amber.light", "lamp")
    # The bumper under the prow and a ram on the front of each front housing.
    b.box(-24.0, 24.0, 39.5, 42.0, 7.0, 11.0, "steel.dark", "bumper")
    for s in (-1.0, 1.0):
        _ram(b, s, s * 24.0, 39.0, 46.0, 4.5, 16.0)
    # The engine cover over the rear two thirds: the shell brought down to a low dome.
    b.loft([(-44.0, _chamfered(0.0, 28.0, 21.0, 26.0, 4.0)), (-37.0, _chamfered(0.0, 42.0, 25.0, 31.0, 6.0)),
            (-12.0, _chamfered(0.0, 42.0, 25.0, 32.0, 6.0)), (-6.0, _chamfered(0.0, 36.0, 26.0, 30.0, 4.0))], "livery.livery2", "engine_cover")
    # Mounts, placeholders: the turret's gun, a rack and a bare mount on the middle housings.
    b.prism("z", 0.0, 2.0, 29.5, 9.5, 1.2, "steel.dark", 8, "ring")
    with b.joint("turret", (0.0, 2.0, 30.0)):
        b.prism("z", 0.0, 2.0, 33.2, 8.5, 6.0, "steel.panel", 8, "turret", phase=math.pi / 8)
        b.box(-5.0, 5.0, 8.0, 11.0, 31.0, 35.5, "steel.plate", "mantlet")
        b.box(-3.0, 3.0, -3.5, 1.5, 36.2, 37.0, "steel.plate", "hatch")
        b.stock("hp_1", (0.0, 11.0, 33.2), "barrel", scale=0.85, carries="slugthrower")
        _whip(b, (-5.6, -2.6, 36.0), 13.0, lean=12.0, splay=-10.0)
    b.stock("hp_2", (-24.0, -1.0, 22.0), "rack", scale=0.62, carries="shotfire_rack")
    b.pad("hp_3", (24.0, 0.0, 23.0), size=(7.0, 1.0))
    b.pivots = True   # skid steer: each side's three wheels driven together, the sides against each other, so it turns on the spot as a tank's neutral turn
    return lambda y: _at(COVER, y)


def mnlook_echidna2_a(b):
    """The bristle as its kit: two raked banks of six short emitter rods along the engine
    cover, dark with lit tips and longer toward the tail, a driver box between the banks, and
    one emitter off the prow's cap: a guess at the Sonic Needle's emitters."""
    _car2(b)
    for s in (-1.0, 1.0):
        x = s * 11.5
        b.box(x - 1.8, x + 1.8, -39.0, -9.0, 30.4, 33.0, "steel.dark", "emitter_rail")
        d = _raked(58.0, s * 16.0)
        for k in range(6):
            _rod(b, (x, -11.5 - 5.0 * k, 33.0), d, 10.5 + 0.6 * k)
        # A tie bar across the bank at half height: an array on one bus, no rack of rockets.
        tie = [Vector((x, -11.5 - 5.0 * k, 33.0)) + d * ((10.5 + 0.6 * k) * 0.52) for k in (0, 5)]
        _beam(b, tuple(tie[0] + Vector((0.0, 1.6, 0.0))), tuple(tie[1] - Vector((0.0, 1.6, 0.0))), _sq(0.9, 1.3), _sq(0.9, 1.3), "steel.plate", "emitter_tie")
    b.box(-5.0, 5.0, -33.0, -17.0, 31.0, 34.4, "steel.dark", "emitter_driver")
    b.box(-3.6, 3.6, -31.5, -18.5, 34.4, 34.9, "steel.vent", "driver_grille")
    _rod(b, (0.0, 46.3, 13.5), (0.0, math.cos(math.radians(6.0)), math.sin(math.radians(6.0))), 8.0, collar="y")


mnlook_echidna2_a.maker = MN


def mnlook_echidna2_b(b):
    """The bristle as its armour: a comb of seven raked plates across the engine cover, on a
    rail each side, each a little longer than the one ahead of it and dark along its edge:
    spaced armour or heat fins as you like, a ridged back from above and a saw's edge from the
    side."""
    top = _car2(b)
    a = math.radians(63.0)
    for s in (-1.0, 1.0):
        b.box(s * 15.2 - 1.1, s * 15.2 + 1.1, -40.0, -8.0, 29.6, 32.4, "steel.dark", "fin_rail")
    for k in range(7):
        y0, h, w = -9.5 - 4.7 * k, 6.0 + 0.5 * k, 31.0 - 0.9 * k
        z0 = top(y0) - 0.4
        y1, z1 = y0 - h * math.cos(a), z0 + h * math.sin(a)
        b.loft([(y1, rect(0.0, w, z1 - 0.9, z1 + 0.9)), (y0, rect(0.0, w, z0 - 0.9, z0 + 0.9))], "steel.plate", "fin")
        ye, ze = y1 - 1.4 * math.cos(a), z1 + 1.4 * math.sin(a)
        b.loft([(ye, rect(0.0, w + 0.8, ze - 1.1, ze + 1.1)), (y1, rect(0.0, w + 0.8, z1 - 1.1, z1 + 1.1))], "steel.dark", "fin_edge")


mnlook_echidna2_b.maker = MN


def mnlook_echidna2_c(b):
    """Barely there: the plain car. Its low domed engine cover with two grilles and a spine rib,
    and three whip aerials, one on the turret and two off the cover's tail; the nickname is left
    to how it acts."""
    _car2(b)
    for s in (-1.0, 1.0):
        b.box(s * 8.5 - 5.0, s * 8.5 + 5.0, -34.0, -15.0, 30.8, 32.5, "steel.vent", "engine_grille")
    b.box(-2.0, 2.0, -36.0, -13.0, 30.8, 33.0, "steel.plate", "spine_rib")
    _whip(b, (-13.0, -36.0, 30.6), 16.0, lean=14.0, splay=-12.0)
    _whip(b, (13.0, -36.0, 30.6), 11.0, lean=14.0, splay=12.0)


mnlook_echidna2_c.maker = MN

# ---------------------------------------------------------------- the third round (22 November)

# Ryan, 22 November, of A: "can we make the spines shorter, thicker (means less probably), and more
# slanted to the sides of the vehicle (keeping their backwards slant)?" So four spines a bank in
# place of six, about three fifths the length and twice the thickness, each keeping round two's
# lean toward the tail as the side view shows it (31 degrees off upright) and leaning out to its
# flank besides, two ways: 35 and 55 degrees.

BACK_LEAN = 31.0   # round two's rods' lean toward the tail, off upright, as the side view shows it


def _leaned(back, side, s):
    """A direction leaning `back` degrees off upright toward the tail and `side` degrees out to
    the flank (`s` the side's sign), each lean read on its own plane, so a spine splayed to the
    side keeps the backward lean the side view shows."""
    return Vector((s * math.tan(math.radians(side)), -math.tan(math.radians(back)), 1.0)).normalized()


def _spine(b, base, d, length, half=1.5, bead=1.3):
    """Round three's spine: a thick dark emitter rooted in a broad collar, tapering to a lit
    bead on its tip."""
    p, d = Vector(base), Vector(d).normalized()
    b.prism("z", p.x, p.y, p.z + 0.8, half * 1.6, 1.6, "steel.plate", 6, "emitter_collar")
    tip = p + d * length
    _beam(b, tuple(p - d * 0.6), tuple(tip), _sq(half * 2.0, half * 2.0), _sq(half * 1.2, half * 1.2), "steel.dark", "emitter")
    _beam(b, tuple(tip - d * 0.2), tuple(tip + d * (bead * 1.6)), _sq(bead * 2.0, bead * 2.0), _sq(bead * 1.2, bead * 1.2), BEAD, "emitter_tip")


def _bristle3(b, side_lean, count=4, first=-12.5, last=-35.3):
    """Round three's A: round two's car, driver box and prow emitter, its two banks of `count`
    short thick spines each on a broader rail, from `first` to `last` along it, leaning back as
    before and out to their flank by `side_lean` degrees, 6.5 long at the front to 8 at the tail;
    no tie bar, since thick short spines read as no rack of rockets."""
    _car2(b)
    for s in (-1.0, 1.0):
        x = s * 12.5
        b.box(x - 2.4, x + 2.4, -39.0, -9.0, 30.4, 33.0, "steel.dark", "emitter_rail")
        d = _leaned(BACK_LEAN, side_lean, s)
        for k in range(count):
            t = k / (count - 1)
            _spine(b, (x, first + (last - first) * t, 33.0), d, 6.5 + 1.5 * t)
    b.box(-5.0, 5.0, -33.0, -17.0, 31.0, 34.4, "steel.dark", "emitter_driver")
    b.box(-3.6, 3.6, -31.5, -18.5, 34.4, 34.9, "steel.vent", "driver_grille")
    _rod(b, (0.0, 46.3, 13.5), (0.0, math.cos(math.radians(6.0)), math.sin(math.radians(6.0))), 8.0, collar="y")


def mnlook_echidna3_a35(b):
    """A, its spines shorter and thicker, four a bank, splayed 35 degrees to the flank."""
    _bristle3(b, 35.0)


mnlook_echidna3_a35.maker = MN


def mnlook_echidna3_a55(b):
    """A, its spines shorter and thicker, four a bank, splayed 55 degrees to the flank."""
    _bristle3(b, 55.0)


mnlook_echidna3_a55.maker = MN

# ---------------------------------------------------------------- the fourth round (22 November)

# Ryan, the same day, of round three: "I like the 35. Can we squeeze in 5 a bank?" So the 35
# degree splay with five spines a bank, the bank a little longer down the rail.


def mnlook_echidna4_a35x5(b):
    """A, splayed 35 degrees, five spines a bank."""
    _bristle3(b, 35.0, count=5, first=-11.5, last=-36.5)


mnlook_echidna4_a35x5.maker = MN

LOOKS = ["mnlook_echidna_halftrack", "mnlook_echidna_car", "mnlook_echidna2_a", "mnlook_echidna2_b", "mnlook_echidna2_c",
         "mnlook_echidna3_a35", "mnlook_echidna3_a55", "mnlook_echidna4_a35x5"]

SHEET = {
    "title": "The echidna, two ways, 15 November (look tests, not content)",
    "out": "docs/looks/minerva_echidna.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_echidna_halftrack", "label": "Half-track", "views": ["codex", "above", "skirmish", ("from the side", 90, 8)]},
        {"model": "mnlook_echidna_car", "label": "Armoured car, protected wheels", "views": ["codex", "above", "skirmish", ("from the side", 90, 8)]},
    ],
}


_VIEWS2 = ["codex", "above", "skirmish", ("from the side", 90, 8)]
SHEET2 = {
    "title": "The echidna, second round, 15 November (look tests, not content)",
    "out": "docs/looks/minerva_echidna2.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_echidna2_a", "label": "A, the bristle as its kit", "views": _VIEWS2},
        {"model": "mnlook_echidna2_b", "label": "B, the bristle as its armour", "views": _VIEWS2},
        {"model": "mnlook_echidna2_c", "label": "C, barely there", "views": _VIEWS2},
    ],
}


_VIEWS3 = ["codex", "above", "skirmish", ("from the side", 90, 8), ("from behind", 180, 12)]
SHEET3 = {
    "title": "The echidna, A again, 22 November: its spines shorter and thicker, four a bank, leaning back as before and out to the flank (look tests, not content)",
    "out": "docs/looks/minerva_echidna3.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_echidna2_a", "label": "A as it was (15 November)", "views": _VIEWS3},
        {"model": "mnlook_echidna3_a35", "label": "A, splayed 35 degrees", "views": _VIEWS3},
        {"model": "mnlook_echidna3_a55", "label": "A, splayed 55 degrees", "views": _VIEWS3},
    ],
}


SHEET4 = {
    "title": "The echidna, A at 35 degrees, 22 November: four spines a bank or five (look tests, not content)",
    "out": "docs/looks/minerva_echidna4.png",
    "cell": (320, 320),
    "rows": [
        {"model": "mnlook_echidna3_a35", "label": "A, four a bank", "views": _VIEWS3},
        {"model": "mnlook_echidna4_a35x5", "label": "A, five a bank", "views": _VIEWS3},
    ],
}

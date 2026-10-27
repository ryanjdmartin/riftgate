"""Look tests for the Kestrel line's fourth round (Ryan, 27 October, on the third): the Needletail
as the dart's diamond body with the lance's everything else; the jaeger less bird; the scissor
remade as two pairs of swing wings, one sweeping back and one forward, no centre pivot; the Puffin
on the boat with the side plates kept as variable wings and shield amplifiers; the Storm Petrel on
the Puffin's hull with no bow plate, its role shown as a shield-based off-tank and St. Elmo's fire
a glowing open port in the nose. Not content: built only by build_look.py (docs/looks/)."""

import math

from mathutils import Matrix, Vector

from bl_low import diamond, hexagon, rect
from kestrel_looks import _canopy, _nt_motion, _top
from kestrel_looks2 import (_boat_cab, _boat_hull, _lerp_at, _needle_nose, _needle_tip_sensor, _rot_z, _skua_acts, _skua_body,
                            _skua_pods, _stern_booster)
from models_low import (_beam, _blade_section, _case, _chine_section, _disc, _fin_section, _fuse, _hexr, _hull_section, _oct,
                        _poly, _rings, _sq, _wing)

KT = "kestrel"


# ---------------------------------------------------------------- the Needletail: the diamond and the lance

def _nt_nacelle(b, side, nx, ny, nz, r=4.0):
    with b.joint("nacelle_" + side, (nx, ny, nz), axis="pitch", limits=(-95.0, 22.0)):
        b.prism("z", nx, ny, nz - 2.0, r, 15.0, "steel.dark", 6, "nacelle", phase=math.pi / 6)
        b.prism("z", nx, ny, nz + 7.0, r + 0.3, 5.0, "steel.plate", 6, "nacelle_cowl", phase=math.pi / 6)
        b.prism("z", nx, ny, nz + 1.5, r + 0.2, 2.6, "livery.livery", 6, "nacelle_band", phase=math.pi / 6)
        b.prism("z", nx, ny, nz + 9.9, r + 0.7, 1.0, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
        _disc(b, (nx, ny, nz + 10.45), (0.0, 0.0, 1.0), r - 0.1, 6, "bore.dark", "intake", phase=math.pi / 6)
        b.prism("z", nx, ny, nz - 10.2, r + 0.5, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
        _disc(b, (nx, ny, nz - 11.1), (0.0, 0.0, -1.0), r + 0.1, 6, "amber.exhaust", "exhaust", phase=math.pi / 6)


def ktlook_needle_diamond(b):
    """Ryan's pick of 27 October: the dart's faceted diamond body with the lance's everything
    else. The Fovea Designator is the needle's tip, a sensor ball set in a nose a body long; the
    body widens into the diamond at the centre of mass, where the nacelles stand at its corners on
    short anhedral stubs; the cockpit far aft on the diamond's spine; a Y tail. The nacelles still
    tilt (his question of the tilt-jets is in chat)."""
    FUSE = [(30.0, 3.4, 1.7, 1.6), (24.0, 6.0, 2.6, 2.4), (14.0, 12.0, 3.8, 3.3), (2.0, 20.0, 4.6, 3.9), (-6.0, 22.0, 5.0, 4.2),
            (-16.0, 17.0, 4.8, 3.9), (-28.0, 9.0, 3.6, 3.0), (-38.0, 3.6, 1.8, 1.6), (-44.0, 2.2, 1.2, 1.1)]
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    _needle_nose(b, 29.5, 78.0, 3.4, 50.0, tip=False)
    _needle_tip_sensor(b, 78.0, 2.4)
    _canopy(b, FUSE, [(-6.0, 1.2, 0.8), (-10.0, 2.8, 3.2), (-17.0, 3.2, 4.0), (-24.0, 2.8, 3.2), (-29.0, 1.8, 1.4)], -16.6)
    b.loft([(-29.0, rect(0.0, 2.8, _top(FUSE, -29.0) - 0.4, _top(FUSE, -29.0) + 1.2)), (-40.0, rect(0.0, 1.4, _top(FUSE, -40.0) - 0.3, _top(FUSE, -40.0) + 0.7))], "steel.dark", "spine")
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 10.0, 3.0, -10.0, 0.2, 1.0), _blade_section(s * 23.0, 0.6, -8.0, -2.6, 0.8)], "livery.livery", "stub_wing")
        b.prism("x", s * 23.5, -4.0, -3.0, 2.8, 2.6, "steel.dark", 8, "nacelle_root", phase=math.pi / 8)
        _nt_nacelle(b, side, s * 26.0, -4.0, -3.0)
        b.box(s * 13.0 - 0.7, s * 13.0 + 0.7, -4.0, 4.0, -4.0, -2.2, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 13.0, 3.0, -4.6), "barrel" if s < 0 else "dish", scale=0.5)
    b.pad("hp_3", (0.0, -18.0, -4.4), scale=0.5, size=(4.0, 1.2))
    _rings(b, [_fin_section(0.0, -32.0, -43.0, _top(FUSE, -36.0), 0.5), _fin_section(0.0, -40.0, -45.0, _top(FUSE, -36.0) + 9.0, 0.25)], "livery.livery", "fin")
    for s in (-1.0, 1.0):
        a = math.radians(40.0)
        _rings(b, [[(s * 1.0, -32.0, -1.0), (s * 1.2, -38.0, -1.0), (s * 1.0, -43.0, -1.0), (s * 0.8, -38.0, -1.0)],
                   [(s * 8.0 * math.sin(a), -39.0, -1.0 - 8.0 * math.cos(a)), (s * 8.0 * math.sin(a) + s * 0.2, -42.0, -1.0 - 8.0 * math.cos(a)),
                    (s * 8.0 * math.sin(a), -45.0, -1.0 - 8.0 * math.cos(a)), (s * 8.0 * math.sin(a) - s * 0.2, -42.0, -1.0 - 8.0 * math.cos(a))]], "livery.livery", "ventral_fin")
    _nt_motion(b)

ktlook_needle_diamond.maker = KT


# ---------------------------------------------------------------- the Skua: the jaeger less bird, and the twin swing

def ktlook_skua_jaeger3(b):
    """The jaeger with the bird taken down (Ryan, 27 October: "a bit too bird-like"): the nose a
    straight chined jet nose, no droop and no cap; the tail streamers gone; the white flash a
    chrome band. Kept: the one booster the body flows into, the arms cranked up to the wrists and
    the hands that swing, the V tail, the twin pods."""
    FUSE = [(30.0, 7.0, 3.3, 3.3), (18.0, 10.0, 4.4, 4.0), (4.0, 11.4, 4.9, 4.4), (-10.0, 10.8, 4.8, 4.4), (-22.0, 9.4, 4.5, 4.3)]
    NOSE = [(30.0, 7.0, 3.3, 3.3, 0.0), (40.0, 5.0, 2.4, 2.4, 0.0), (49.0, 2.8, 1.3, 1.3, 0.0), (55.0, 1.2, 0.5, 0.5, 0.0)]
    boosters = _skua_body(b, FUSE, NOSE, -36.0, 7.0, cap=False)
    _canopy(b, FUSE + [(-40.0, 8.0, 4.0, 4.0)], [(27.0, 1.0, 0.6), (23.0, 2.5, 2.6), (16.0, 2.9, 3.4), (9.0, 2.5, 2.7), (5.0, 1.3, 1.0)], 16.0)
    for s in (-1.0, 1.0):
        b.loft([(12.0, rect(s * 6.2, 2.2, -2.4, 2.0)), (4.0, rect(s * 6.4, 2.6, -2.6, 2.4))], "steel.dark", "intake_cheek")
        b.box(s * 6.2 - 0.9, s * 6.2 + 0.9, 12.0, 12.4, -2.2, 1.8, "bore.dark", "intake")
    WX, WY, WZ = 17.0, 2.0, 7.0
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 5.0, 4.0, -11.0, 3.4, 1.1), _blade_section(s * 11.0, 7.0, -7.8, 5.6, 0.9),
                   _blade_section(s * (WX + 0.8), 8.2, -5.0, WZ, 0.8)], "livery.livery", "wing_arm")
        b.prism("z", s * WX, WY, WZ, 2.3, 2.6, "steel.dark", 8, "wrist", phase=math.pi / 8)
        with b.joint("wing_" + side, (s * WX, WY, WZ), axis="yaw", limits=(-6.0, 58.0) if s < 0 else (-58.0, 6.0)):
            _rings(b, [_blade_section(s * (WX - 0.4), 8.0, -4.9, WZ, 0.8), _blade_section(s * (WX + 5.0), 6.8, -5.1, WZ - 0.3, 0.7)], "livery.livery", "wing_hand")
            _rings(b, [_blade_section(s * (WX + 5.0), 6.8, -5.1, WZ - 0.3, 0.7), _blade_section(s * (WX + 9.0), 5.6, -5.3, WZ - 0.55, 0.64)], "steel.plate", "wing_band")
            _rings(b, [_blade_section(s * (WX + 9.0), 5.6, -5.3, WZ - 0.55, 0.64), _blade_section(s * (WX + 23.0), 0.0, -6.6, WZ - 1.6, 0.4),
                       _blade_section(s * (WX + 36.0), -7.4, -9.2, WZ - 2.8, 0.18)], "livery.livery", "wing_hand")
        ca = math.radians(30.0)
        _rings(b, [_blade_section(s * 5.0, -30.0, -43.0, 3.6, 0.5), [(s * (5.0 + 14.0 * math.cos(ca)), y, 3.6 + 14.0 * math.sin(ca) + dz) for (y, dz) in ((-45.0, 0.0), (-42.0, 0.25), (-39.0, 0.0), (-42.0, -0.25))]],
               "livery.livery", "stabiliser")
    _rings(b, [_fin_section(0.0, -14.0, -32.0, 4.6, 0.7), _fin_section(0.0, -29.0, -36.0, 13.0, 0.3)], "livery.livery", "fin")
    _skua_pods(b, [-3.0, 3.0], -10.0, 3.0, 4.4, 3.8)
    for s in (-1.0, 1.0):
        b.box(s * 10.0 - 0.7, s * 10.0 + 0.7, -4.0, 4.0, 1.6, 4.4, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 10.0, 4.0, 1.0), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    b.pad("hp_3", (0.0, -8.0, -4.8), scale=0.5, size=(5.0, 1.4))
    _skua_acts(b, [("wing_l", 1.0), ("wing_r", -1.0)], 52.0, boosters)

ktlook_skua_jaeger3.maker = KT


def ktlook_skua_twinswing(b):
    """Ryan's remake of the scissor (27 October): two pairs of swing wings and no centre pivot,
    the aft pair sweeping back as the F-14's do and the fore pair swinging forward toward the
    nose, each from its own glove. At rest both pairs stand a little splayed, so from above the
    four arms make a shallow X split between two stations; on the run the aft pair sweeps back
    and the fore pair forward, a four-pointed star. The jaeger's body under them, one booster."""
    FUSE = [(30.0, 7.2, 3.4, 3.2), (18.0, 10.4, 4.5, 4.0), (4.0, 11.6, 4.9, 4.4), (-10.0, 11.0, 4.8, 4.4), (-22.0, 9.6, 4.5, 4.3)]
    NOSE = [(30.0, 7.2, 3.4, 3.2, 0.0), (40.0, 5.2, 2.5, 2.4, 0.0), (49.0, 3.0, 1.4, 1.3, 0.0), (55.0, 1.2, 0.5, 0.5, 0.0)]
    boosters = _skua_body(b, FUSE, NOSE, -36.0, 7.0, cap=False)
    _canopy(b, FUSE + [(-40.0, 8.0, 4.0, 4.0)], [(28.0, 1.0, 0.6), (24.0, 2.5, 2.6), (17.0, 2.9, 3.4), (10.0, 2.5, 2.7), (6.0, 1.3, 1.0)], 17.0)
    # The gloves: a fore one under the canopy's tail and an aft one before the booster, each a
    # flat shoulder out of the flank carrying its pivot drums.
    for (gy0, gy1, gw) in ((8.0, -2.0, 18.0), (-14.0, -24.0, 18.0)):
        b.loft([(gy0, _case(gw, 1.0, 4.6, 1.2)), (gy1, _case(gw, 1.0, 4.6, 1.2))], "steel.plate", "glove")
    REST = math.radians(14.0)
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        for (name, py, sgn, span, chord) in (("fore_" + side, 3.0, -1.0, 26.0, 9.0), ("aft_" + side, -19.0, 1.0, 32.0, 10.0)):
            px, pz = s * 8.0, 2.8
            b.prism("z", px, py, pz + 1.0, 2.0, 2.4, "steel.dark", 8, "pivot", phase=math.pi / 8)
            # The panel straight out from its pivot, then turned to its rest splay: the fore pair's
            # tips toward the nose, the aft pair's toward the tail.
            straight = [_blade_section(px + s * dx, py + chord * 0.5 - dx * 0.08, py - chord * 0.5 - dx * 0.1, pz + 1.2 - dx * 0.05, 0.75 - dx * 0.016)
                        for dx in (0.0, span * 0.5, span)]
            rings = [_rot_z(r, -s * sgn * REST, px, py) for r in straight]
            lim = (0.0, 50.0) if -s * sgn > 0 else (-50.0, 0.0)
            with b.joint(name, (px, py, pz), axis="yaw", limits=lim):
                _rings(b, rings, "livery.livery", "wing")
                band = [_rot_z(_blade_section(px + s * dx, py + chord * 0.5 - dx * 0.08, py - chord * 0.5 - dx * 0.1, pz + 1.22 - dx * 0.05, 0.77 - dx * 0.016), -s * sgn * REST, px, py)
                        for dx in (span * 0.55, span * 0.7)]
                _rings(b, band, "steel.plate", "wing_band")
        _rings(b, [_blade_section(s * 5.0, -31.0, -43.0, 3.6, 0.5), _blade_section(s * 14.0, -40.0, -46.0, 3.2, 0.25)], "livery.livery", "stabiliser")
        b.box(s * 6.0 - 0.7, s * 6.0 + 0.7, 10.0, 20.0, -4.0, -2.2, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 6.0, 19.0, -4.6), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    _rings(b, [_fin_section(0.0, -14.0, -32.0, 4.6, 0.7), _fin_section(0.0, -29.0, -36.0, 13.0, 0.3)], "livery.livery", "fin")
    _skua_pods(b, [-3.0, 3.0], -11.0, 0.0, 4.6, 3.6)
    b.pad("hp_3", (0.0, -8.0, -4.8), scale=0.5, size=(5.0, 1.4))
    # The run: the aft pair sweeps back, the fore pair forward (each joint's sign from its side).
    _skua_acts(b, [("fore_l", -1.0), ("fore_r", 1.0), ("aft_l", 1.0), ("aft_r", -1.0)], 42.0, boosters, spread=0.0)

ktlook_skua_twinswing.maker = KT


# ---------------------------------------------------------------- the swap, second stab

def ktlook_puffin_boat2(b):
    """The Puffin on the boat, with the boat's side plates kept (Ryan, 27 October: he did not
    mind them, as variable wings rather than shields, and the Puffin is a shield support, so
    shield amplifiers make sense): two cobalt plates hinged along the deck's edges, held up in a
    shallow V as variable wings (joints plate_l, plate_r), each carrying an amplifier strip along
    its top edge and an emitter boss, lit as it projects; the mast shorter, the Backwash Ionizer's
    dish at its head; the prow's band kept. The pods under the hull's flanks (hp_1, hp_2), the
    Coil's dish on the right shoulder (hp_3), the left bare (hp_4)."""
    K = 0.86
    HULL = [(y * K, w * K, 6.0 + (z0 - 6.0) * K, 6.0 + (z1 - 6.0) * K, c * K) for (y, w, z0, z1, c) in
            ((48.0, 3.0, 10.6, 12.6, 0.6), (40.0, 10.0, 8.8, 14.0, 1.4), (28.0, 18.0, 7.2, 15.6, 2.2), (12.0, 24.0, 6.6, 16.4, 2.8),
             (-12.0, 24.0, 6.6, 16.4, 2.8), (-30.0, 21.0, 7.0, 16.0, 2.4), (-42.0, 15.0, 8.0, 15.2, 2.0))]
    at = _boat_hull(b, HULL)
    deck = lambda y: at(y)[2]
    w0, z00, z01 = at(36.0)
    b.loft([(35.0, _hull_section(z00 + 0.3, z01 - 0.3, w0 + 0.3, 1.0)), (36.5, _hull_section(z00 + 0.5, z01 - 0.5, w0 - 0.4, 0.8))], "amber.light", "prow_band")
    _boat_cab(b, deck, [(26.0, 4.5, 0.6), (21.0, 9.0, 2.6), (14.0, 11.0, 3.6), (7.0, 10.0, 3.3), (2.0, 7.0, 2.2)], 15.0)
    my, mz0, mtop = -6.0, deck(-6.0), 28.0
    _beam(b, (0.0, my, mz0 - 0.5), (0.0, my, mtop), _poly(1.3, 6), _poly(0.7, 6), "steel.dark", "mast")
    with b.joint("projector", (0.0, my, mtop), axis="yaw", limits=(-120.0, 120.0)):
        tilt = Matrix.Translation((0.0, my, mtop + 1.6)) @ Matrix.Rotation(math.radians(70.0), 4, "X")
        b.loft([(0.0, _poly(0.9, 8)), (1.2, _poly(4.6, 8)), (2.0, _poly(5.0, 8))], "steel.plate", "projector_dish", tilt)
        b.loft([(1.0, _poly(1.3, 8)), (2.0, _poly(1.3, 8))], "amber.engine", "projector_core", tilt)
    # The plates as variable wings: thinner than the Storm Petrel's, held up at twenty-two
    # degrees, an amplifier strip along each top edge and an emitter boss on the face.
    HY, ANG = -8.0 * K, math.radians(22.0)
    OUT = [(16.0, 0.0), (14.0, 4.0), (3.0, 13.0), (-14.0, 12.0), (-19.0, 5.0), (-16.0, 0.0)]
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        hx, hz = s * 9.4 * K, deck(HY) - 0.2
        d = Vector((s * math.cos(ANG), 0.0, math.sin(ANG)))
        n = d.cross(Vector((0.0, 1.0, 0.0))).normalized()
        b.prism("y", hx, HY, hz, 1.1, 30.0, "steel.dark", 6, "hinge")
        with b.joint("plate_" + side, (hx, HY, hz), axis="roll", limits=(-30.0, 50.0) if s < 0 else (-50.0, 30.0)):
            _rings(b, [[tuple(Vector((hx, HY + u, hz)) + d * v + n * off) for (u, v) in OUT] for off in (-0.45, 0.45)], "livery.livery2", "plate")
            up = n if n.z > 0.0 else -n
            cu, cv = sum(u for u, v in OUT) / len(OUT), sum(v for u, v in OUT) / len(OUT)
            boss = Vector((hx, HY + cu, hz)) + d * cv
            _disc(b, tuple(boss + up * 0.55), tuple(up), 2.2, 6, "steel.dark", "boss_" + side)
            _disc(b, tuple(boss + up * 0.65), tuple(up), 1.3, 6, "amber.engine", "amp_boss_" + side)
            (u0, v0), (u1, v1) = OUT[2], OUT[3]
            _beam(b, tuple(Vector((hx, HY + u0, hz)) + d * (v0 + 0.5)), tuple(Vector((hx, HY + u1, hz)) + d * (v1 + 0.5)),
                  _sq(1.4, 0.7), _sq(1.4, 0.7), "amber.engine", "amp_edge_" + side)
        px = s * 12.0 * K
        b.box(min(px - 0.8, px + 0.8), max(px - 0.8, px + 0.8), 12.0, 18.0, 8.4, 10.2, "steel.plate", "pod_pylon")
        with b.socket("hp_%d" % (1 if s < 0 else 2), (px, 20.0, 8.2), scale=0.5):
            b.prism("y", px, 15.0, 8.2, 1.5, 11.0, "steel.dark", 6, "pod")
            if s < 0:
                b.prism("y", px, 25.0, 8.2, 0.8, 10.0, "steel.dark", 6, "laser_carbine")
            else:
                b.prism("y", px, 22.5, 8.2, 3.0, 1.2, "steel.plate", 8, "dish")
                b.prism("y", px, 23.3, 8.2, 1.2, 0.8, "amber.engine", 8, "dish_core")
        rx, ry = s * 6.5, -22.0
        dz = deck(ry)
        b.loft([(ry - 6.0, rect(rx, 2.6, dz - 0.6, dz + 1.0)), (ry + 5.0, rect(rx, 3.8, dz - 0.6, dz + 2.0))], "steel.panel", "shoulder_fairing")
        if s > 0:
            b.stock("hp_3", (rx, ry + 5.5, dz + 1.3), "dish", scale=0.5)
        else:
            b.pad("hp_4", (rx, ry + 5.5, dz + 1.3), scale=0.5, size=(3.6, 1.3))
    _stern_booster(b, -32.0, 12.6, 6.0)
    for (nx, ny) in ((-6.0, 18.0), (6.0, 18.0), (-6.0, -16.0), (6.0, -16.0)):
        b.prism("z", nx, ny, 6.2, 2.0, 1.4, "amber.engine", 6, "lift_nozzle")
    boosters = ["booster_ring", "exhaust"]
    amps = ["amp_edge", "amp_boss", "projector_core", "prow_band"]
    b.act("amplify", 4.8, {"plate_l": [(0.4, 0.0), (1.2, 30.0), (3.4, 30.0), (4.2, 0.0)], "plate_r": [(0.4, 0.0), (1.2, -30.0), (3.4, -30.0), (4.2, 0.0)],
                           "projector": [(0.5, 0.0), (1.6, 50.0), (3.4, 50.0), (4.4, 0.0)]},
          glow=[(amps, [(1.0, 0.0), (1.3, 9.0), (1.6, 2.0), (1.9, 12.0), (3.4, 12.0), (4.2, 0.0)])])
    b.act("lift_hop", 4.6, {"plate_l": [(0.5, 0.0), (1.2, -14.0), (1.8, 10.0), (2.6, 0.0)], "plate_r": [(0.5, 0.0), (1.2, 14.0), (1.8, -10.0), (2.6, 0.0)]},
          body=[(0.5, 0.0, 0.0, -2.0, 0.0, 0.0, 0.0), (1.2, 0.0, 0.0, 16.0, 0.0, 6.0, 12.0), (1.8, 0.0, 0.0, 14.0, 0.0, -4.0, -10.0), (2.5, 0.0, 0.0, -3.0, 0.0, 0.0, 0.0),
                (2.9, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0), (3.4, 0.0, 0.0, -1.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(["lift_nozzle"], [(0.3, 0.0), (0.6, 10.0), (1.2, 10.0), (1.8, 3.0), (2.5, 8.0), (3.2, 0.0)])])
    b.gait(hold={"plate_l": -16.0, "plate_r": 16.0}, body_hold=(0.0, 0.0, 0.0, 0.0, -5.0, 0.0), glow={"parts": boosters, "k": 5.0}, rock=3.0)
    b.move(slide=0.3, bank=0.0, accel=0.8, heft=0.13, oversteer=1.5)

ktlook_puffin_boat2.maker = KT


def ktlook_storm_hull2(b):
    """The Storm Petrel on the Puffin's hull, second stab (Ryan, 27 October: the bow plate dumb,
    the role to show another way, a shield-based off-tank; St. Elmo's fire not a masthead, a
    glowing open port in the nose where the prow feature was). The hull and the giant boosters
    at the medium size; the Riot Field Generator shown as the field itself: four emitter pylons
    on the deck's edges with a lit field rail run along each chine between them, and a projector
    ring over the canopy, all lit as the field rises; the nose an open hexagonal port, dark
    collared, with St. Elmo's corona burning inside it; the sponsons carry the gun tubs."""
    K = 1.18
    HULL = [(y * K, w * K, 6.0 + (z0 - 6.5) * K, 6.0 + (z1 - 6.5) * K, c * K) for (y, w, z0, z1, c) in
            ((30.0, 14.0, 10.0, 14.6, 2.0), (20.0, 28.0, 8.0, 17.6, 3.0), (6.0, 36.0, 7.0, 19.4, 3.5), (-12.0, 34.0, 7.0, 19.4, 3.5),
             (-26.0, 30.0, 8.0, 18.8, 3.0), (-36.0, 22.0, 10.0, 17.4, 2.5))]
    at = lambda y: tuple(_lerp_at([(y, w, z0, z1) for (y, w, z0, z1, c) in HULL], y))
    deck = lambda y: at(y)[2]
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "hull")
    SKIRT = [(y, w + 1.2, z0 - 0.7, z0 + 2.2, 0.9) for (y, w, z0, z1, c) in HULL]
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.3)) for (y, w, z0, z1, c) in SKIRT], "steel.dark", "lip")
    # The prow: a short chined wedge, its face an open hexagonal port with the corona inside.
    y0, w0, z00, z01 = HULL[0][0], HULL[0][1], HULL[0][2], HULL[0][3]
    b.loft([(y0, _chine_section(z00, z01, w0, 1.6)), (y0 + 6.0, _chine_section(z00 + 1.0, z01 - 0.6, w0 * 0.78, 1.2))], "steel.plate", "prow")
    pz = (z00 + z01) / 2.0 + 0.4
    b.prism("y", 0.0, y0 + 6.6, pz, w0 * 0.3 + 0.6, 1.4, "steel.dark", 6, "port_collar", phase=math.pi / 6)
    b.loft([(y0 + 7.3, _hexr(0.0, pz, w0 * 0.3)), (y0 + 2.0, _hexr(0.0, pz, w0 * 0.22))], "bore.dark", "port")
    b.loft([(y0 + 4.5 + dy, _oct(pz, 2.0 * r, 2.0 * r, 0.0, 8)) for (dy, r) in ((-1.8, 0.7), (-0.9, 1.9), (0.6, 2.3), (1.8, 1.5), (2.6, 0.5))], "amber.corona", "corona")
    _rings(b, [[(2.9 * math.cos(a), y0 + 7.0, pz + 2.9 * math.sin(a)) for a in [i * math.pi / 6 for i in range(12)]],
               [(2.2 * math.cos(a), y0 + 7.0, pz + 2.2 * math.sin(a)) for a in [i * math.pi / 6 for i in range(12)]]], "amber.corona", "corona_halo", cap=False)
    _boat_cab(b, deck, [(18.0, 6.0, 0.6), (12.0, 11.0, 3.0), (4.0, 12.6, 4.0), (-5.0, 12.0, 3.6), (-11.0, 10.0, 2.6)], 8.0)
    # The projector ring over the canopy: an arch of chrome with an ember underside.
    for (mat, r, lab) in (("steel.plate", 1.0, "projector_arch"), ("amber.ember", 0.5, "projector_glow")):
        pts = []
        for k in range(9):
            a = math.pi * k / 8.0
            pts.append((-9.0 * math.cos(a), 0.0, deck(0.0) + 1.0 + 8.0 * math.sin(a)))
        for p0, p1 in zip(pts, pts[1:]):
            _beam(b, (p0[0], p0[1], p0[2] - (0.0 if mat == "steel.plate" else 0.8)), (p1[0], p1[1], p1[2] - (0.0 if mat == "steel.plate" else 0.8)), _poly(r, 6), _poly(r, 6), mat, lab)
    # The field: emitter pylons on the deck's edges and the rail along each chine between them.
    for s in (-1.0, 1.0):
        for ey in (16.0, -22.0):
            w, z0, z1 = at(ey)
            ex = s * (w / 2.0 - 1.4)
            b.loft([(ey - 2.5, rect(ex, 2.4, z1 - 0.4, z1 + 2.6)), (ey + 2.5, rect(ex, 2.4, z1 - 0.4, z1 + 2.6))], "steel.dark", "emitter_pylon")
            b.loft([(ey - 1.8, rect(ex, 1.6, z1 + 2.6, z1 + 3.4)), (ey + 1.8, rect(ex, 1.6, z1 + 2.6, z1 + 3.4))], "amber.ember", "emitter")
        secs = []
        for y in (22.0, 12.0, 0.0, -12.0, -24.0):
            w, z0, z1 = at(y)
            hw, zc = w / 2.0, z0 + (z1 - z0) * 0.42
            pts = [(hw + 0.9, zc), (hw - 0.2, zc + 1.1), (hw - 1.0, zc), (hw - 0.2, zc - 1.1)]
            secs.append((y, [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]))
        b.loft(list(reversed(secs)), "amber.ember", "field_rail")
    # The nacelles, the giant boosters and the sponsons with the gun tubs, the Puffin's scaled.
    def nac_top(y):
        return deck(-6.0 * K) + (deck(-33.0 * K) - deck(-6.0 * K)) * (-6.0 * K - y) / (27.0 * K)
    for s in (-1.0, 1.0):
        bx, bz, br = s * 17.0 * K, 6.0 + (12.4 - 6.5) * K, 6.4 * K
        def nac(y, x_out):
            t = nac_top(y)
            pts = [(10.0 * K, 8.6), (x_out, 8.6), (x_out, t - 1.6), (x_out - 1.6, t), (10.0 * K, t)]
            return [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]
        b.loft([(-6.0 * K, nac(-6.0 * K, 22.2 * K)), (-20.0 * K, nac(-20.0 * K, 22.0 * K)), (-33.0 * K, nac(-33.0 * K, 21.2 * K))], "steel.plate", "nacelle")
        b.prism("y", bx, -20.5 * K, bz, br, 31.0 * K, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.loft([(-5.0 * K, hexagon(bx, bz, 12.0 * K, 10.6 * K)), (-4.4 * K, hexagon(bx, bz, 10.6 * K, 9.4 * K))], "bore.dark", "intake")
        b.prism("y", bx, -4.8 * K, bz, 7.2 * K, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
        b.prism("y", bx, -36.0 * K, bz, 7.3 * K, 1.2, "steel.plate", 6, "exhaust_lip", phase=math.pi / 6)
        b.prism("y", bx, -36.9 * K, bz, 6.9 * K, 1.4, "amber.engine", 6, "nozzle_ring", phase=math.pi / 6)
        b.loft([(-37.6 * K, hexagon(bx, bz, 11.2 * K, 9.8 * K)), (-38.1 * K, hexagon(bx, bz, 10.0 * K, 8.6 * K))], "amber.exhaust", "exhaust")
        sx0, sx1 = sorted((s * 22.0 * K, s * 34.0 * K))
        mid = (sx0 + sx1) / 2.0
        b.loft([(-4.0, [(x + mid, z) for (x, z) in _case(sx1 - sx0, 10.0, 15.0, 1.6)]), (-22.0, [(x + mid, z) for (x, z) in _case(sx1 - sx0, 10.0, 15.0, 1.6)]),
                (-30.0, [(x + mid, z) for (x, z) in _case((sx1 - sx0) * 0.6, 10.5, 14.0, 1.2)])], "livery.livery", "sponson")
        b.box(mid - 2.0, mid + 2.0, -14.0, -9.0, 14.8, 16.2, "steel.panel", "mount")
        b.stock("hp_%d" % (1 if s < 0 else 3), (mid, -9.0, 17.4), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    b.box(-6.5, -2.5, -26.0, -22.0, deck(-24.0) - 0.6, deck(-24.0) + 0.9, "steel.panel", "mount")
    b.stock("hp_2", (-4.5, -22.0, deck(-24.0) + 2.0), "rack", scale=0.5)
    b.pad("hp_4", (4.5, -24.0, deck(-24.0) + 1.0), scale=0.5, size=(4.0, 1.4))
    fh, fy0, fy1 = 14.0, -48.0, -39.0
    for s in (-1.0, 1.0):
        a = math.radians(s * 35.0)
        fx, fz = s * 8.0, deck(-35.0)
        root = [(fx, -40.0, fz - 0.8), (fx, -28.0, fz - 0.8), (fx, -28.0, fz + 0.2), (fx, -40.0, fz + 0.2)]
        tip = [(fx + fh * math.sin(a), fy0, fz + fh * math.cos(a)), (fx + fh * math.sin(a), fy1, fz + fh * math.cos(a)),
               (fx + fh * math.sin(a), fy1, fz + 0.5 + fh * math.cos(a)), (fx + fh * math.sin(a), fy0, fz + 0.5 + fh * math.cos(a))]
        _wing(b, root, tip, "livery.livery", "fin")
    for (nx, ny) in ((-9.0, 12.0), (9.0, 12.0), (-9.0, -18.0), (9.0, -18.0)):
        b.prism("z", nx, ny, 6.4, 2.6, 1.4, "amber.engine", 6, "lift_nozzle")
    boosters = ["nozzle_ring", "exhaust"]
    field = ["field_rail", "emitter", "projector_glow"]
    b.act("field_up", 5.0, body=[(0.5, 0.0, 0.0, 0.0), (1.3, 0.0, -1.0, -1.6, 0.0, 2.0, 0.0), (3.4, 0.0, -1.0, -1.6, 0.0, 2.0, 0.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(field, [(0.8, 0.0), (1.3, 10.0), (1.6, 4.0), (1.9, 12.0), (3.4, 12.0), (4.3, 0.0)])])
    b.act("ram", 3.8, body=[(0.9, 0.0, -2.0, 0.5, 0.0, 2.0, 0.0), (1.4, 0.0, 12.0, -1.0, 0.0, -4.0, 0.0), (2.0, 0.0, 7.0, -0.5, 0.0, -1.0, 0.0), (3.8, 0.0, 0.0, 0.0)],
          glow=[(field + ["corona"], [(1.3, 0.0), (1.4, 16.0), (1.8, 3.0), (2.5, 0.0)])], heft=0.06)
    b.act("st_elmo", 4.6, body=[(0.6, 0.0, 0.0, 0.0), (1.6, 0.0, 0.0, 1.2), (3.4, 0.0, 0.0, 1.2), (4.6, 0.0, 0.0, 0.0)],
          glow=[(["corona"], [(0.3, 0.0), (0.6, 6.0), (0.75, 1.0), (1.0, 9.0), (1.15, 2.0), (1.5, 12.0), (1.7, 5.0), (2.0, 14.0), (3.4, 14.0), (4.2, 0.0)])])
    b.act("patter", 4.2, body=[(0.4, 0.0, 0.0, 0.0), (0.6, 0.0, 3.0, 1.6, 0.0, -2.0, 0.0), (0.8, 0.0, 5.0, 0.0, 0.0, 1.0, 0.0), (1.0, 0.0, 8.0, 1.6, 0.0, -2.0, 0.0),
                                (1.2, 0.0, 10.0, 0.0, 0.0, 1.0, 0.0), (1.4, 0.0, 13.0, 1.6, 0.0, -2.0, 0.0), (1.6, 0.0, 15.0, 0.0, 0.0, 1.0, 0.0), (2.6, 0.0, 9.0, 0.0, 0.0, -1.0, 0.0), (4.2, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.3, 0.0), (0.6, 6.0), (1.6, 6.0), (2.2, 0.0)])])
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, -3.0, 0.0), glow={"parts": boosters, "k": 5.0}, rock=3.0)
    b.move(slide=0.3, bank=0.0, accel=0.6, heft=0.14, oversteer=1.1)

ktlook_storm_hull2.maker = KT


LOOKS = ["ktlook_needle_diamond", "ktlook_skua_jaeger3", "ktlook_skua_twinswing", "ktlook_puffin_boat2", "ktlook_storm_hull2"]

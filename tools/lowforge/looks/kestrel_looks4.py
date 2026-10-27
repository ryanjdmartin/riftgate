"""Look tests for the Kestrel line's fifth round (Ryan, 27 October, on the fourth). The jaeger from
its second cut with a jet's straight nose, the wings mounted low with no rise on the fixed arms,
the fin carried further back and taller; the scissor from scratch on a body built round its hub;
the Needletail for two modes (in fast, mark, hover and vector to dodge, out fast: "a fox in a
henhouse") in the existing direction and a scratch one, a tail-sitter; the Puffin on the boat with
the skirt to the nose and the booster drawn in; the Storm Petrel with the port an intake that
follows the body, the nose carried smoothly, the sponsons made purposeful, the emitters on the
deck; and the flying wing as an airborne Lammergeier. Not content: built only by build_look.py."""

import math

from mathutils import Matrix, Vector

from bl_low import diamond, hexagon, rect
from kestrel_looks import _canopy, _nt_motion, _nt_xtail, _top
from kestrel_looks2 import (_boat_cab, _boat_hull, _lerp_at, _needle_nose, _needle_tip_sensor, _planform, _rot_z, _skua_acts,
                            _skua_body, _skua_pods, _stern_booster)
from kestrel_looks3 import _nt_nacelle
from models_low import (_beam, _blade_section, _case, _chine_section, _disc, _fin_section, _fuse, _hexr, _hull_section, _oct,
                        _poly, _rings, _sq, _tube, _wing)

KT = "kestrel"


# ---------------------------------------------------------------- the Skua

def ktlook_skua_jaeger4(b):
    """The second jaeger (the cap, the streamers, the white flash) with Ryan's notes of 27 October:
    the nose straightened to a jet's radome; the wings mounted low on the fuselage, the fixed arms
    running flat out to the wrists with a touch of anhedral instead of rising; the fin carried
    further back over the booster and taller."""
    FUSE = [(30.0, 7.0, 3.3, 3.3), (18.0, 10.0, 4.4, 4.0), (4.0, 11.4, 4.9, 4.4), (-10.0, 10.8, 4.8, 4.4), (-22.0, 9.4, 4.5, 4.3)]
    NOSE = [(30.0, 7.0, 3.3, 3.3, 0.0), (40.0, 5.2, 2.5, 2.5, 0.0), (49.0, 3.0, 1.4, 1.4, 0.0), (55.0, 1.2, 0.5, 0.5, 0.0)]
    boosters = _skua_body(b, FUSE, NOSE, -36.0, 7.0, cap=True)
    _canopy(b, FUSE + [(-40.0, 8.0, 4.0, 4.0)], [(27.0, 1.0, 0.6), (23.0, 2.5, 2.6), (16.0, 2.9, 3.4), (9.0, 2.5, 2.7), (5.0, 1.3, 1.0)], 16.0)
    for s in (-1.0, 1.0):
        b.loft([(12.0, rect(s * 6.2, 2.2, -2.4, 2.0)), (4.0, rect(s * 6.4, 2.6, -2.6, 2.4))], "steel.dark", "intake_cheek")
        b.box(s * 6.2 - 0.9, s * 6.2 + 0.9, 12.0, 12.4, -2.2, 1.8, "bore.dark", "intake")
    WX, WY, WZ = 18.0, 2.0, -1.2   # the wrists low, below the fuselage's waist
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        _rings(b, [_blade_section(s * 5.2, 6.0, -11.0, 0.0, 1.1), _blade_section(s * 12.0, 8.0, -7.0, -0.6, 0.9),
                   _blade_section(s * (WX + 0.8), 8.8, -4.4, WZ, 0.8)], "livery.livery", "wing_arm")
        b.prism("z", s * WX, WY, WZ, 2.3, 2.6, "steel.dark", 8, "wrist", phase=math.pi / 8)
        with b.joint("wing_" + side, (s * WX, WY, WZ), axis="yaw", limits=(-6.0, 58.0) if s < 0 else (-58.0, 6.0)):
            _rings(b, [_blade_section(s * (WX - 0.4), 8.6, -4.3, WZ, 0.8), _blade_section(s * (WX + 5.0), 7.2, -4.6, WZ - 0.3, 0.7)], "livery.livery", "wing_hand")
            _rings(b, [_blade_section(s * (WX + 5.0), 7.2, -4.6, WZ - 0.3, 0.7), _blade_section(s * (WX + 10.0), 5.6, -4.8, WZ - 0.6, 0.62)], "bone.bone", "wing_flash")
            _rings(b, [_blade_section(s * (WX + 10.0), 5.6, -4.8, WZ - 0.6, 0.62), _blade_section(s * (WX + 24.0), -0.6, -6.2, WZ - 1.6, 0.4),
                       _blade_section(s * (WX + 37.0), -8.2, -9.2, WZ - 2.6, 0.18)], "livery.livery", "wing_hand")
        ca = math.radians(30.0)
        _rings(b, [_blade_section(s * 5.0, -30.0, -43.0, 3.6, 0.5), [(s * (5.0 + 14.0 * math.cos(ca)), y, 3.6 + 14.0 * math.sin(ca) + dz) for (y, dz) in ((-45.0, 0.0), (-42.0, 0.25), (-39.0, 0.0), (-42.0, -0.25))]],
               "livery.livery", "stabiliser")
        _rings(b, [[(s * 1.6 - 0.9, -40.0, 7.7), (s * 1.6, -40.0, 8.1), (s * 1.6 + 0.9, -40.0, 7.7), (s * 1.6, -40.0, 7.3)],
                   [(s * 2.6 - 0.7, -56.0, 6.6), (s * 2.6, -56.0, 6.9), (s * 2.6 + 0.7, -56.0, 6.6), (s * 2.6, -56.0, 6.3)],
                   [(s * 3.6 - 0.05, -76.0, 5.8), (s * 3.6, -76.0, 5.85), (s * 3.6 + 0.05, -76.0, 5.8), (s * 3.6, -76.0, 5.75)]], "livery.livery", "streamer")
        b.box(s * 1.6 - 0.6, s * 1.6 + 0.6, -41.0, -31.0, 4.6, 8.0, "steel.plate", "streamer_root")
    # The fin: its root from the fairing back over the booster, swept, taller than before.
    _rings(b, [_fin_section(0.0, -18.0, -44.0, 5.0, 0.8), _fin_section(0.0, -37.0, -47.0, 20.0, 0.3)], "livery.livery", "fin")
    _skua_pods(b, [-3.0, 3.0], -10.0, 3.0, 4.4, 3.8)
    for s in (-1.0, 1.0):
        b.box(s * 10.0 - 0.7, s * 10.0 + 0.7, -2.0, 5.0, -2.4, -0.4, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 10.0, 5.0, -3.0), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    b.pad("hp_3", (0.0, -10.0, -5.0), scale=0.5, size=(5.0, 1.4))
    _skua_acts(b, [("wing_l", 1.0), ("wing_r", -1.0)], 52.0, boosters)

ktlook_skua_jaeger4.maker = KT


def ktlook_skua_scissor2(b):
    """The scissor from scratch (Ryan: the concept right, the fuselage wrong for it): a body built
    round its hub. A short, deep lifting body, wide and flat, with a big armoured hub amidships
    at the centre of mass, the two straight wings stacked on it (wing_u, wing_d), the cockpit a
    bubble forward of the hub, cheek intakes feeding one big booster straight aft between twin
    canted fins. At rest the wings cross in a wide X; on the run both slew to close the arms into
    a dart. The pods ride the hub's flanks."""
    FUSE = [(26.0, 6.0, 2.4, 2.2), (16.0, 14.0, 3.8, 3.4), (4.0, 20.0, 4.6, 4.0), (-8.0, 20.0, 4.6, 4.0), (-18.0, 15.0, 4.0, 3.8), (-26.0, 11.0, 3.6, 3.6)]
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    b.loft([(26.0, diamond(0.0, 0.1, 5.4, 4.2)), (36.0, diamond(0.0, 0.1, 1.0, 0.8))], "steel.dark", "nose")
    _canopy(b, FUSE, [(22.0, 1.0, 0.6), (18.0, 2.6, 2.8), (12.0, 3.0, 3.6), (7.0, 2.4, 2.8), (4.0, 1.4, 1.0)], 12.0)
    for s in (-1.0, 1.0):
        b.loft([(14.0, rect(s * 7.4, 3.0, -2.6, 2.4)), (4.0, rect(s * 8.2, 3.6, -2.8, 2.8))], "steel.dark", "intake_cheek")
        b.box(s * 7.4 - 1.3, s * 7.4 + 1.3, 14.0, 14.4, -2.4, 2.2, "bore.dark", "intake")
    # The booster straight aft, the body flowing onto its drum; twin canted fins on the fairing.
    y0, w0, t0, b0 = FUSE[-1]
    b.loft([(y0, _fuse(w0, t0, b0)), (-32.0, _hexr(0.0, 0.0, 6.8))], "steel.plate", "tail_fairing")
    b.prism("y", 0.0, -42.0, 0.0, 6.8, 20.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    b.prism("y", 0.0, -52.0, 0.0, 7.3, 2.4, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(-53.2, _hexr(0.0, 0.0, 7.2)), (-53.8, _hexr(0.0, 0.0, 6.4))], "amber.exhaust", "exhaust")
    for s in (-1.0, 1.0):
        a = math.radians(s * 28.0)
        _rings(b, [[(s * 5.0, -22.0, 3.0), (s * 5.3, -30.0, 3.0), (s * 5.0, -38.0, 3.0), (s * 4.7, -30.0, 3.0)],
                   [(s * 5.0 + 13.0 * math.sin(a), -34.0, 3.0 + 13.0 * math.cos(a)), (s * 5.0 + 13.0 * math.sin(a) + s * 0.15, -39.0, 3.0 + 13.0 * math.cos(a)),
                    (s * 5.0 + 13.0 * math.sin(a), -43.0, 3.0 + 13.0 * math.cos(a)), (s * 5.0 + 13.0 * math.sin(a) - s * 0.15, -39.0, 3.0 + 13.0 * math.cos(a))]], "livery.livery", "fin")
    # The hub: a big chamfered drum rising out of the body's back at the centre of mass, dark,
    # with a chrome cap; the two wings stacked in its band.
    HY, HZ = -2.0, 4.4
    b.loft([(HZ - 0.4, _poly(9.0, 10)), (HZ + 1.0, _poly(8.4, 10)), (HZ + 4.6, _poly(8.4, 10)), (HZ + 5.4, _poly(7.0, 10))], "steel.dark", "hub",
           Matrix.Translation((0.0, HY, 0.0)) @ Matrix.Rotation(math.pi / 2, 4, "X"))
    b.loft([(HZ + 5.4, _poly(6.0, 10)), (HZ + 6.2, _poly(3.0, 10))], "steel.plate", "hub_cap", Matrix.Translation((0.0, HY, 0.0)) @ Matrix.Rotation(math.pi / 2, 4, "X"))
    REST = math.radians(28.0)
    for (name, z, sgn) in (("wing_u", HZ + 3.6, 1.0), ("wing_d", HZ + 1.6, -1.0)):
        straight = [_blade_section(x, 5.0 - abs(x) * 0.05, -3.4 - abs(x) * 0.04, z, 0.75 - abs(x) * 0.01) for x in (-46.0, -23.0, 0.0, 23.0, 46.0)]
        with b.joint(name, (0.0, HY, z), axis="yaw", limits=(-6.0, 40.0) if sgn > 0 else (-40.0, 6.0)):
            _rings(b, [_rot_z(r, sgn * REST, 0.0, HY) for r in straight], "livery.livery", "wing")
            for x in (-32.0, 32.0):
                _rings(b, [_rot_z(_blade_section(xx, 5.0 - abs(xx) * 0.05, -3.4 - abs(xx) * 0.04, z + 0.02, 0.77 - abs(xx) * 0.01), sgn * REST, 0.0, HY) for xx in (x - 3.0, x + 3.0)], "bone.bone", "wing_band")
    _skua_pods(b, [-11.0, 11.0], -8.0, 4.0, 2.4, 3.2)
    for s in (-1.0, 1.0):
        b.box(s * 6.0 - 0.7, s * 6.0 + 0.7, 6.0, 16.0, -4.2, -2.4, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 6.0, 15.0, -4.8), "barrel" if s < 0 else "twin_barrel", scale=0.5)
    b.pad("hp_3", (0.0, -14.0, -4.4), scale=0.5, size=(5.0, 1.4))
    _skua_acts(b, [("wing_u", 1.0), ("wing_d", -1.0)], 36.0, ["booster_ring", "exhaust"], spread=5.0)

ktlook_skua_scissor2.maker = KT


# ---------------------------------------------------------------- the Needletail: two modes

def _fox_acts(b, extra_tracks_hover=None, extra_tracks_jet=None):
    """The two modes as acts: the dash in (jet), the mark and the hover-and-vector (hover), the
    dash out; the gait tilting with speed as before."""
    hov = dict(extra_tracks_hover or {})
    jet = dict(extra_tracks_jet or {})
    boosters = ["booster_ring", "exhaust"]
    b.act("dash_in", 4.6, {"nacelle_l": [(0.3, 0.0), (0.9, -88.0), (3.4, -88.0), (4.2, 0.0)], "nacelle_r": [(0.3, 0.0), (0.9, -88.0), (3.4, -88.0), (4.2, 0.0)], **jet},
          body=[(0.4, 0.0, 0.0, 0.0), (1.2, 0.0, 14.0, -1.0, 0.0, -8.0, 0.0), (2.6, 0.0, 22.0, -0.5, 0.0, -6.0, 0.0), (3.6, 0.0, 8.0, 1.0, 0.0, 6.0, 0.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.3, 0.0), (0.8, 9.0), (3.0, 9.0), (3.8, 0.0)])])
    b.act("mark_and_dodge", 6.0, {"sensor": [(0.4, 0.0), (1.2, 38.0), (4.6, 38.0), (5.4, 0.0)], "eye": [(0.8, 0.0), (1.4, -16.0), (4.6, -16.0), (5.2, 0.0)],
                                  "nacelle_l": [(1.6, 0.0), (2.0, 14.0), (2.8, -16.0), (3.6, 12.0), (4.4, -10.0), (5.2, 0.0)],
                                  "nacelle_r": [(1.6, 0.0), (2.0, -16.0), (2.8, 14.0), (3.6, -10.0), (4.4, 12.0), (5.2, 0.0)], **hov},
          body=[(1.4, 0.0, 0.0, 0.0), (2.0, -9.0, 0.0, 1.0, 0.0, 0.0, -14.0), (2.8, 8.0, 2.0, 2.0, 0.0, 0.0, 12.0), (3.6, -7.0, -2.0, 1.0, 0.0, 0.0, -10.0),
                (4.4, 6.0, 0.0, 2.0, 0.0, 0.0, 8.0), (5.4, 0.0, 0.0, 0.0)],
          glow=[(["fovea"], [(1.0, 0.0), (1.3, 9.0), (1.5, 3.0), (1.8, 12.0), (4.6, 12.0), (5.2, 0.0)]), (boosters, [(1.6, 0.0), (2.0, 5.0), (4.8, 5.0), (5.4, 0.0)])])
    glow = {"parts": boosters, "k": 5.0}
    b.gait_option("hover", tracks={"nacelle_l": [(0.0, -12.0), (1.0, -12.0)], "nacelle_r": [(0.0, -12.0), (1.0, -12.0)], **{k: [(0.0, v[0][1]), (1.0, v[0][1])] for k, v in hov.items()}}, glow=glow)
    b.gait(tracks={"nacelle_l": [(0.0, -86.0), (1.0, -86.0)], "nacelle_r": [(0.0, -86.0), (1.0, -86.0)], **{k: [(0.0, v[1][1]), (1.0, v[1][1])] for k, v in jet.items()}}, glow=glow,
           body_hold=(0.0, 0.0, 0.0, 0.0, -4.0, 0.0), start=("hover", 0.25, 0.85))
    b.move(slide=0.35, bank=32.0, accel=0.7, heft=0.1, oversteer=0.4)


def ktlook_needle_fox(b):
    """The existing direction made to read its two modes (Ryan, 27 October: in fast, mark, hover
    and vector to dodge, out fast; a fox in a henhouse). The flipped body (a long nose, the
    cockpit aft) with the nacelles grown into the machine's main mass, big tilting drums on short
    stubs at the centre of mass; jet-mode wings that fold up out of the way for the hover (joints
    wing_l, wing_r roll up to 70), so hovering it is a narrow thing on two upright drums and flying
    it is a wide dart; the designator's ball under the nose on a chin turret, looking down at its
    mark while it hovers."""
    FUSE = [(40.0, 3.4, 1.7, 1.6), (30.0, 6.4, 2.8, 2.6), (16.0, 10.0, 4.0, 3.6), (2.0, 12.6, 4.8, 4.2), (-10.0, 13.4, 5.2, 4.4),
            (-22.0, 11.6, 4.8, 4.0), (-32.0, 7.6, 3.4, 2.8), (-40.0, 3.4, 1.8, 1.6)]
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    _needle_nose(b, 39.5, 74.0, 3.4, 54.0)
    b.loft([(-39.5, diamond(0.0, 0.1, 2.4, 2.2)), (-50.0, diamond(0.0, 0.1, 0.3, 0.3))], "steel.dark", "needle")
    _canopy(b, FUSE, [(-4.0, 1.2, 0.8), (-8.0, 2.8, 3.2), (-15.0, 3.2, 4.0), (-22.0, 3.0, 3.4), (-27.0, 2.0, 1.4)], -14.6)
    # The chin turret: the designator's ball under the nose's root, turning and nodding.
    cy, cz = 22.0, -3.6
    b.prism("z", 0.0, cy, cz + 1.0, 1.4, 2.0, "steel.dark", 6, "chin_mast")
    with b.joint("sensor", (0.0, cy, cz), axis="yaw", limits=(-80.0, 80.0)):
        with b.joint("eye", (0.0, cy, cz), axis="pitch", limits=(-60.0, 20.0)):
            b.loft([(cy + dy, _oct(cz - 1.0, 2.0 * r, 2.0 * r, 0.0, 10)) for (dy, r) in ((-3.2, 0.9), (-2.2, 2.2), (-0.4, 2.8), (1.4, 2.3), (2.2, 1.4))], "steel.plate", "sensor_ball")
            b.prism("y", 0.0, cy + 2.4, cz - 1.0, 1.6, 0.8, "glass.glass", 10, "lens")
            b.prism("y", 0.0, cy + 2.85, cz - 1.0, 0.8, 0.6, "amber.lit", 10, "fovea")
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        # The stubs to the drums, short and thick; the drums big.
        _rings(b, [_blade_section(s * 6.0, 4.0, -8.0, 0.0, 1.6), _blade_section(s * 16.0, 2.0, -6.0, -0.6, 1.2)], "steel.plate", "stub")
        b.prism("x", s * 17.0, -2.0, -0.6, 3.6, 3.0, "steel.dark", 8, "nacelle_root", phase=math.pi / 8)
        _nt_nacelle(b, side, s * 21.5, -2.0, -0.6, r=5.4)
        # The jet-mode wings: cobalt, out from the drums' roots behind the stubs, folding up on a
        # roll joint for the hover.
        with b.joint("wing_" + side, (s * 15.0, -9.0, 0.4), axis="roll", limits=(0.0, 75.0) if s < 0 else (-75.0, 0.0)):
            _rings(b, [_blade_section(s * 15.5, -4.0, -14.0, 0.4, 0.8), _blade_section(s * 34.0, -9.0, -16.0, 0.0, 0.5), _blade_section(s * 44.0, -12.0, -17.0, -0.2, 0.25)], "livery.livery", "wing")
        b.box(s * 9.0 - 0.7, s * 9.0 + 0.7, 2.0, 10.0, -4.4, -2.6, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 9.0, 9.0, -5.0), "barrel" if s < 0 else "dish", scale=0.5)
    b.pad("hp_3", (0.0, -18.0, -4.8), scale=0.5, size=(4.0, 1.2))
    _nt_xtail(b, (0.8, -29.0, -39.0), (8.0, -35.0, -41.0))
    _fox_acts(b, extra_tracks_hover={"wing_l": [(1.4, 0.0), (2.0, 66.0), (4.8, 66.0), (5.6, 0.0)], "wing_r": [(1.4, 0.0), (2.0, -66.0), (4.8, -66.0), (5.6, 0.0)]},
              extra_tracks_jet={"wing_l": [(0.3, 0.0), (0.9, 0.0)], "wing_r": [(0.3, 0.0), (0.9, 0.0)]})

ktlook_needle_fox.maker = KT


def ktlook_needle_tailsitter(b):
    """The scratch direction: a tail-sitter. A slim dart that flies level at full speed and, to
    hover, pitches its whole body nose-up to stand on its tail boosters, two big drums at the
    stern with four fins between them that are its legs; the designator's ball on a chin turret
    looks down the nose in flight and swings under it to look at the mark while it stands; the
    cockpit a bubble high on the spine so the pilot sees out in both. The two modes are the whole
    machine's pose, nothing tilts but the turret (the act 'hover' pitches the body up)."""
    FUSE = [(44.0, 2.8, 1.4, 1.3), (34.0, 5.6, 2.6, 2.4), (20.0, 9.0, 4.0, 3.6), (4.0, 11.0, 4.8, 4.2), (-12.0, 11.0, 4.8, 4.2), (-26.0, 10.0, 4.6, 4.0), (-36.0, 9.0, 4.4, 4.0)]
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    b.loft([(44.0, diamond(0.0, 0.0, 2.6, 2.4)), (56.0, diamond(0.0, 0.0, 0.3, 0.3))], "steel.dark", "nose_tip")
    _canopy(b, FUSE, [(18.0, 1.2, 0.8), (13.0, 2.8, 3.4), (6.0, 3.2, 4.2), (-2.0, 2.8, 3.4), (-7.0, 1.8, 1.4)], 6.0)
    # The chin turret, under the nose's root.
    cy, cz = 26.0, -3.2
    b.prism("z", 0.0, cy, cz + 1.0, 1.3, 2.0, "steel.dark", 6, "chin_mast")
    with b.joint("sensor", (0.0, cy, cz), axis="yaw", limits=(-80.0, 80.0)):
        with b.joint("eye", (0.0, cy, cz), axis="pitch", limits=(-95.0, 20.0)):
            b.loft([(cy + dy, _oct(cz - 1.0, 2.0 * r, 2.0 * r, 0.0, 10)) for (dy, r) in ((-3.0, 0.9), (-2.0, 2.1), (-0.4, 2.6), (1.3, 2.1), (2.0, 1.3))], "steel.plate", "sensor_ball")
            b.prism("y", 0.0, cy + 2.2, cz - 1.0, 1.5, 0.8, "glass.glass", 10, "lens")
            b.prism("y", 0.0, cy + 2.65, cz - 1.0, 0.75, 0.6, "amber.lit", 10, "fovea")
    # Short cobalt wings at the centre of mass, and the two stern drums with the four fin-legs.
    for s in (-1.0, 1.0):
        _rings(b, [_blade_section(s * 5.0, 6.0, -12.0, 0.0, 1.1), _blade_section(s * 26.0, -4.0, -13.0, -0.4, 0.5)], "livery.livery", "wing")
        bx = s * 8.0
        b.prism("y", bx, -38.0, 0.0, 5.0, 22.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", bx, -28.0, 0.0, 5.3, 2.6, "livery.livery", 6, "booster_band", phase=math.pi / 6)
        b.prism("y", bx, -49.0, 0.0, 5.4, 1.8, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
        b.loft([(-49.9, _hexr(bx, 0.0, 5.3)), (-50.4, _hexr(bx, 0.0, 4.6))], "amber.exhaust", "exhaust")
        b.box(s * 9.0 - 0.7, s * 9.0 + 0.7, 2.0, 10.0, -4.2, -2.4, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 9.0, 9.0, -4.8), "barrel" if s < 0 else "dish", scale=0.5)
    for k in range(4):
        a = math.radians(45.0 + 90.0 * k)
        dx, dz = math.cos(a), math.sin(a)
        tx, tz = -dz * 0.3, dx * 0.3
        def sec(rad, y_le, y_te):
            ym = y_le - (y_le - y_te) * 0.35
            cx, cz2 = dx * rad, dz * rad
            return [(cx, y_te, cz2), (cx + tx, ym, cz2 + tz), (cx, y_le, cz2), (cx - tx, ym, cz2 - tz)]
        _rings(b, [sec(4.0, -30.0, -44.0), sec(15.0, -40.0, -52.0)], "livery.livery", "fin_leg")
        b.box(dx * 15.0 - 1.2, dx * 15.0 + 1.2, -53.0, -51.0, dz * 15.0 - 1.2, dz * 15.0 + 1.2, "steel.dark", "foot")
    b.pad("hp_3", (0.0, -18.0, -4.8), scale=0.5, size=(4.0, 1.2))
    boosters = ["booster_ring", "exhaust"]
    b.act("dash_in", 4.6, body=[(0.4, 0.0, 0.0, 0.0), (1.2, 0.0, 16.0, -1.0, 0.0, -8.0, 0.0), (2.6, 0.0, 24.0, -0.5, 0.0, -6.0, 0.0), (3.6, 0.0, 8.0, 1.0, 0.0, 6.0, 0.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.3, 0.0), (0.8, 10.0), (3.0, 10.0), (3.8, 0.0)])])
    # The hover: the whole machine rears up onto its tail, the turret swinging under the nose to
    # look at the mark, and it sways on its boosters dodging; then it tips over and runs.
    b.act("hover", 7.0, {"eye": [(1.2, 0.0), (2.0, -80.0), (5.4, -80.0), (6.2, 0.0)], "sensor": [(2.0, 0.0), (2.8, 30.0), (3.8, -25.0), (4.8, 20.0), (5.6, 0.0)]},
          body=[(0.5, 0.0, 0.0, 0.0), (1.6, 0.0, -6.0, 14.0, 0.0, 70.0, 0.0), (2.6, -6.0, -4.0, 16.0, 0.0, 74.0, -8.0), (3.6, 6.0, -6.0, 15.0, 0.0, 68.0, 8.0),
                (4.6, -4.0, -4.0, 16.0, 0.0, 72.0, -6.0), (5.6, 0.0, -2.0, 14.0, 0.0, 70.0, 0.0), (6.4, 0.0, 6.0, 2.0, 0.0, -6.0, 0.0), (7.0, 0.0, 0.0, 0.0)],
          glow=[(["fovea"], [(1.8, 0.0), (2.1, 9.0), (2.3, 3.0), (2.6, 12.0), (5.4, 12.0), (6.0, 0.0)]), (boosters, [(0.6, 0.0), (1.6, 7.0), (5.6, 7.0), (6.6, 0.0)])])
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, -4.0, 0.0), glow={"parts": boosters, "k": 5.0})
    b.move(slide=0.35, bank=36.0, accel=0.7, heft=0.1, oversteer=0.4)

ktlook_needle_tailsitter.maker = KT


# ---------------------------------------------------------------- the swap, third stab

def ktlook_puffin_boat3(b):
    """The Puffin on the boat (Ryan, 27 October: "really looking like the Puffin"), the skirt
    carried all the way to the nose and the booster drawn in so it no longer sticks out past the
    stern. Otherwise the second stab: the plates as variable wings and amplifiers, the Ionizer's
    dish on a short mast, the prow's band."""
    K = 0.86
    HULL = [(y * K, w * K, 6.0 + (z0 - 6.0) * K, 6.0 + (z1 - 6.0) * K, c * K) for (y, w, z0, z1, c) in
            ((48.0, 3.0, 10.6, 12.6, 0.6), (40.0, 10.0, 8.8, 14.0, 1.4), (28.0, 18.0, 7.2, 15.6, 2.2), (12.0, 24.0, 6.6, 16.4, 2.8),
             (-12.0, 24.0, 6.6, 16.4, 2.8), (-30.0, 21.0, 7.0, 16.0, 2.4), (-42.0, 15.0, 8.0, 15.2, 2.0))]
    at = lambda y: tuple(_lerp_at([(y, w, z0, z1) for (y, w, z0, z1, c) in HULL], y))
    deck = lambda y: at(y)[2]
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "hull")
    # The skirt the whole length, bow to stern, climbing the bow's rise.
    SKIRT = [(y, w + 1.0, z0 - 0.6, z0 + 1.4, 0.8) for (y, w, z0, z1, c) in HULL]
    SKIRT[0] = (HULL[0][0] + 1.5 * K, HULL[0][1] + 0.8, HULL[0][2] - 0.4, HULL[0][2] + 1.0, 0.5)
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.3)) for (y, w, z0, z1, c) in SKIRT], "steel.dark", "lip")
    for s in (-1.0, 1.0):
        secs = []
        for (y, w, z0, z1, c) in HULL[1:]:
            hw, zc = w / 2.0, z0 + (z1 - z0) * 0.42
            pts = [(hw + 0.4, zc), (hw - 0.3, zc + 0.7), (hw - 1.2, zc), (hw - 0.3, zc - 0.7)]
            secs.append((y, [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]))
        b.loft(list(reversed(secs)), "livery.livery", "chine_stripe")
    w0, z00, z01 = at(36.0)
    b.loft([(35.0, _hull_section(z00 + 0.3, z01 - 0.3, w0 + 0.3, 1.0)), (36.5, _hull_section(z00 + 0.5, z01 - 0.5, w0 - 0.4, 0.8))], "amber.light", "prow_band")
    _boat_cab(b, deck, [(26.0, 4.5, 0.6), (21.0, 9.0, 2.6), (14.0, 11.0, 3.6), (7.0, 10.0, 3.3), (2.0, 7.0, 2.2)], 15.0)
    my, mz0, mtop = -6.0, deck(-6.0), 28.0
    _beam(b, (0.0, my, mz0 - 0.5), (0.0, my, mtop), _poly(1.3, 6), _poly(0.7, 6), "steel.dark", "mast")
    with b.joint("projector", (0.0, my, mtop), axis="yaw", limits=(-120.0, 120.0)):
        tilt = Matrix.Translation((0.0, my, mtop + 1.6)) @ Matrix.Rotation(math.radians(70.0), 4, "X")
        b.loft([(0.0, _poly(0.9, 8)), (1.2, _poly(4.6, 8)), (2.0, _poly(5.0, 8))], "steel.plate", "projector_dish", tilt)
        b.loft([(1.0, _poly(1.3, 8)), (2.0, _poly(1.3, 8))], "amber.engine", "projector_core", tilt)
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
            _beam(b, tuple(Vector((hx, HY + u0, hz)) + d * (v0 + 0.5)), tuple(Vector((hx, HY + u1, hz)) + d * (v1 + 0.5)), _sq(1.4, 0.7), _sq(1.4, 0.7), "amber.engine", "amp_edge_" + side)
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
    # The booster drawn in: shorter, its mouth further forward over the afterdeck, its exhaust
    # just past the stern.
    BY, BZ, BR = -27.0, 12.6, 6.0
    b.prism("y", 0.0, BY, BZ, BR, 24.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    b.prism("y", 0.0, BY + 4.0, BZ, BR + 0.3, 3.6, "livery.livery", 6, "booster_band", phase=math.pi / 6)
    b.prism("y", 0.0, BY + 12.4, BZ, BR + 0.6, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
    b.loft([(BY + 12.9, _hexr(0.0, BZ, BR - 0.2)), (BY + 13.1, _hexr(0.0, BZ, BR - 0.8))], "bore.dark", "intake")
    b.prism("y", 0.0, BY - 12.8, BZ, BR + 0.4, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(BY - 13.6, _hexr(0.0, BZ, BR + 0.2)), (BY - 14.1, _hexr(0.0, BZ, BR - 0.6))], "amber.exhaust", "exhaust")
    _rings(b, [_fin_section(0.0, BY + 8.0, BY - 8.0, BZ + BR - 0.8, 0.7), _fin_section(0.0, BY - 3.0, BY - 11.0, BZ + BR + 10.0, 0.35)], "livery.livery", "fin")
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

ktlook_puffin_boat3.maker = KT


def ktlook_storm_hull3(b):
    """The Storm Petrel on the Puffin's hull, third stab (Ryan, 27 October: a better take; the port
    to follow the body's shape, a glowing intake rather than a hexagon; the body carried smoothly
    to the nose with no jutting beak; the sponsons purposeful; the forward emitters on the
    chassis). The hull's sections now run on to the nose in one taper, the port a chine-shaped
    mouth recessed in the nose's face with St. Elmo's corona inside; the emitter pylons stand on
    the deck proper; the sponsons are the nacelles' shoulders grown forward along the flanks into
    armoured cheeks, carrying the gun tubs on their tops and the field rails along their crease."""
    K = 1.18
    HULL = [(y * K, w * K, 6.0 + (z0 - 6.5) * K, 6.0 + (z1 - 6.5) * K, c * K) for (y, w, z0, z1, c) in
            ((44.0, 5.0, 11.2, 13.6, 1.0), (36.0, 12.0, 9.4, 15.8, 1.8), (26.0, 22.0, 8.2, 17.4, 2.6), (14.0, 32.0, 7.2, 19.0, 3.4), (4.0, 36.0, 7.0, 19.4, 3.5),
             (-12.0, 34.0, 7.0, 19.4, 3.5), (-26.0, 30.0, 8.0, 18.8, 3.0), (-36.0, 22.0, 10.0, 17.4, 2.5))]
    at = lambda y: tuple(_lerp_at([(y, w, z0, z1) for (y, w, z0, z1, c) in HULL], y))
    deck = lambda y: at(y)[2]
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "hull")
    SKIRT = [(y, w + 1.2, z0 - 0.7, z0 + 2.2, 0.9) for (y, w, z0, z1, c) in HULL]
    b.loft([(y, _hull_section(z0, z1, w, c, belly=0.3)) for (y, w, z0, z1, c) in SKIRT], "steel.dark", "lip")
    # The port: the nose's face is the hull's own section, recessed as a mouth with a dark lip,
    # the corona burning inside it.
    y0, w0, z00, z01 = HULL[0][0], HULL[0][1], HULL[0][2], HULL[0][3]
    b.loft([(y0 + 0.2, _chine_section(z00 - 0.2, z01 + 0.2, w0 + 0.6, 1.0)), (y0 + 1.6, _chine_section(z00 + 0.1, z01 - 0.1, w0 + 0.2, 0.8))], "steel.dark", "port_lip")
    b.loft([(y0 + 1.7, _chine_section(z00 + 0.4, z01 - 0.4, w0 - 0.6, 0.6)), (y0 - 4.0, _chine_section(z00 + 1.0, z01 - 1.0, w0 * 0.5, 0.4))], "bore.dark", "port")
    pz = (z00 + z01) / 2.0
    b.loft([(y0 - 2.5 + dy, _oct(pz, 2.0 * r, 1.3 * r, 0.0, 8)) for (dy, r) in ((-1.4, 0.6), (-0.6, 1.5), (0.6, 1.9), (1.8, 1.3), (2.6, 0.5))], "amber.corona", "corona")
    b.loft([(y0 + 1.0, _chine_section(z00 + 0.6, z01 - 0.6, w0 - 1.2, 0.5)), (y0 + 1.3, _chine_section(z00 + 0.9, z01 - 0.9, w0 - 2.0, 0.4))], "amber.corona", "corona_halo")
    _boat_cab(b, deck, [(18.0, 6.0, 0.6), (12.0, 11.0, 3.0), (4.0, 12.6, 4.0), (-5.0, 12.0, 3.6), (-11.0, 10.0, 2.6)], 8.0)
    for (mat, r, lab, drop) in (("steel.plate", 1.0, "projector_arch", 0.0), ("amber.ember", 0.5, "projector_glow", 0.8)):
        pts = [(-9.0 * math.cos(math.pi * k / 8.0), 0.0, deck(0.0) + 1.0 + 8.0 * math.sin(math.pi * k / 8.0) - drop) for k in range(9)]
        for p0, p1 in zip(pts, pts[1:]):
            _beam(b, p0, p1, _poly(r, 6), _poly(r, 6), mat, lab)
    # The cheeks: each nacelle's shoulder grown forward along the flank as an armoured sponson
    # that tapers into the hull at the bow, its crease carrying the field rail, its top the tub.
    def nac_top(y):
        return deck(-6.0 * K) + (deck(-33.0 * K) - deck(-6.0 * K)) * (-6.0 * K - y) / (27.0 * K)
    for s in (-1.0, 1.0):
        CHEEK = [(24.0, 2.0, 11.0, 13.0), (10.0, 7.0, 10.0, 15.6), (-8.0, 9.0, 10.0, 16.4), (-20.0, 8.0, 10.0, 16.4)]   # (y, out from the hull's flank, z0, z1)
        secs = []
        for (y, out, z0, z1) in CHEEK:
            w, hz0, hz1 = at(y)
            hw = w / 2.0
            pts = [(hw - 1.0, z0 - 0.5), (hw + out, z0 + 1.0), (hw + out + 0.4, (z0 + z1) / 2.0), (hw + out - 0.6, z1), (hw - 1.0, z1 + 0.4)]
            secs.append((y, [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]))
        b.loft(secs, "steel.plate", "cheek")
        rail = []
        for (y, out, z0, z1) in CHEEK[1:]:
            w, hz0, hz1 = at(y)
            hw, zc = w / 2.0 + out, (z0 + z1) / 2.0
            pts = [(hw + 0.9, zc), (hw - 0.1, zc + 1.0), (hw - 0.8, zc), (hw - 0.1, zc - 1.0)]
            rail.append((y, [(s * x, z) for (x, z) in (pts if s > 0 else list(reversed(pts)))]))
        b.loft(list(reversed(rail)), "amber.ember", "field_rail")
        for ey in (4.0, -16.0):
            w, hz0, hz1 = at(ey)
            out = _lerp_at([(y, o) for (y, o, z0, z1) in CHEEK], ey)[0]
            ex = s * (w / 2.0 + out - 2.6)
            b.loft([(ey - 2.2, rect(ex, 2.2, 16.0, 18.6)), (ey + 2.2, rect(ex, 2.2, 16.0, 18.6))], "steel.dark", "emitter_pylon")
            b.loft([(ey - 1.6, rect(ex, 1.5, 18.6, 19.3)), (ey + 1.6, rect(ex, 1.5, 18.6, 19.3))], "amber.ember", "emitter")
        tx = s * (at(-10.0)[0] / 2.0 + 5.0)
        b.box(tx - 2.0, tx + 2.0, -12.0, -7.0, 16.2, 17.4, "steel.panel", "mount")
        b.stock("hp_%d" % (1 if s < 0 else 3), (tx, -7.0, 18.6), "barrel" if s < 0 else "twin_barrel", scale=0.5)
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
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, -3.0, 0.0), glow={"parts": boosters, "k": 5.0}, rock=3.0)
    b.move(slide=0.3, bank=0.0, accel=0.6, heft=0.14, oversteer=1.1)

ktlook_storm_hull3.maker = KT


# ---------------------------------------------------------------- the flying wing airborne, as the Lammergeier

def ktlook_lammergeier_wing(b):
    """Ryan's thought of 27 October: the flying wing to the Lammergeier, the catamaran to the
    Giant Petrel. The chevron as an airborne heavy: no skirt and no lift nozzles, a deeper centre
    body with the bomb bay under it (its doors a lit seam, the mines inside), the Lorentz
    Contractor's dish on a dorsal pylon and the Syrinx Drone's launcher tubes in the leading
    edge's roots; four giant boosters across the trailing edge; the mounts on the wing tops. The
    heavy class's size, the chevron a little narrower than the flagship's."""
    Z = 0.0
    LE = [(0.0, 52.0), (12.0, 46.0), (26.0, 38.0), (42.0, 28.0), (58.0, 18.0), (72.0, 10.0)]
    TE = [(72.0, 2.0), (58.0, -3.0), (42.0, -12.0), (26.0, -22.0), (12.0, -28.0), (0.0, -30.0)]
    le = lambda x: _lerp_at([(-p[0], p[1]) for p in LE], -abs(x))[0]
    te = lambda x: _lerp_at([(-p[0], p[1]) for p in reversed(TE)], -abs(x))[0]
    thick = lambda x: max(1.4, 7.0 - abs(x) * 0.075)
    _rings(b, [_blade_section(x, le(x), te(x), Z, thick(x), lead=0.42) for x in (-72.0, -58.0, -42.0, -26.0, -12.0, 0.0, 12.0, 26.0, 42.0, 58.0, 72.0)], "steel.plate", "wing")
    HULL = [(50.0, 7.0, -4.0, 4.0, 1.2), (40.0, 14.0, -7.0, 8.0, 2.4), (22.0, 20.0, -8.5, 10.0, 3.0), (0.0, 20.0, -8.5, 10.0, 3.0), (-20.0, 16.0, -7.0, 8.0, 2.4), (-34.0, 9.0, -4.0, 5.0, 1.4)]
    deck = lambda y: _lerp_at([(y, z1) for (y, w, z0, z1, c) in HULL], y)[0]
    b.loft([(y, _chine_section(z0, z1, w, c)) for (y, w, z0, z1, c) in HULL], "steel.plate", "body")
    _boat_cab(b, deck, [(46.0, 4.0, 0.6), (42.0, 8.0, 2.4), (36.0, 11.0, 3.2), (29.0, 11.0, 2.8), (25.0, 8.0, 1.4)], 37.0)
    # The bomb bay under the body: a recessed well with its doors ajar and a lit seam.
    b.loft([(24.0, rect(0.0, 12.0, -9.6, -8.4)), (-18.0, rect(0.0, 12.0, -9.6, -8.4))], "steel.dark", "bay_frame")
    for s in (-1.0, 1.0):
        b.loft([(22.0, [(s * 1.4, -9.6), (s * 5.8, -9.6), (s * 6.4, -11.2), (s * 2.0, -11.2)]), (-16.0, [(s * 1.4, -9.6), (s * 5.8, -9.6), (s * 6.4, -11.2), (s * 2.0, -11.2)])], "steel.plate", "bay_door")
    b.loft([(22.0, rect(0.0, 2.6, -9.9, -9.4)), (-16.0, rect(0.0, 2.6, -9.9, -9.4))], "amber.ember", "bay_seam")
    for x in (-44.0, -20.0, 20.0, 44.0):
        bz, br = Z + 2.0, 5.8
        ty = te(x)
        b.prism("y", x, ty + 9.0, bz, br, 26.0, "steel.dark", 6, "booster", phase=math.pi / 6)
        b.prism("y", x, ty + 22.6, bz, br + 0.6, 1.2, "steel.plate", 6, "intake_lip", phase=math.pi / 6)
        b.loft([(ty + 23.1, _hexr(x, bz, br - 0.2)), (ty + 23.3, _hexr(x, bz, br - 0.8))], "bore.dark", "intake")
        b.prism("y", x, ty - 5.0, bz, br + 0.4, 1.6, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
        b.loft([(ty - 5.8, _hexr(x, bz, br + 0.2)), (ty - 6.3, _hexr(x, bz, br - 0.6))], "amber.exhaust", "exhaust")
        b.loft([(ty + 2.0, [(xx + x, z) for (xx, z) in _case(12.0, bz - 2.0, bz + 2.0, 1.0)]), (ty + 7.0, [(xx + x, z) for (xx, z) in _case(13.0, bz - 2.5, bz + 3.2, 1.2)])], "livery.livery", "booster_band")
    # The Syrinx Drone's launchers in the leading edge's roots; the Lorentz Contractor's dish aft.
    for s in (-1.0, 1.0):
        for k in range(2):
            x = s * (14.0 + 6.0 * k)
            p1, p0 = Vector((x, le(x) - 0.2, Z + 0.4)), Vector((x, le(x) - 10.0, Z + 0.4))
            _tube(b, tuple(p0), tuple(p1), 2.2, 1.7, 8, "steel.dark", "drone_tube", floor_material="amber.ember", floor_depth=1.0)
    uy, uz = -10.0, deck(-10.0)
    b.loft([(-6.0, rect(0.0, 4.0, uz - 0.4, uz + 3.0)), (-14.0, rect(0.0, 3.0, uz - 0.4, uz + 3.6))], "steel.dark", "contractor_mast")
    with b.joint("sensor_contractor", (0.0, uy, uz + 3.6), axis="yaw", limits=(-120.0, 120.0)):
        tilt = Matrix.Translation((0.0, uy, uz + 6.0)) @ Matrix.Rotation(math.radians(40.0), 4, "X")
        b.loft([(0.0, _poly(1.0, 8)), (1.2, _poly(6.0, 8)), (2.2, _poly(6.4, 8))], "steel.plate", "contractor_dish", tilt)
        b.loft([(1.0, _poly(1.3, 8)), (2.0, _poly(1.3, 8))], "amber.lit", "contractor_core", tilt)
    for s, pin, kind in ((-1.0, "hp_1", "rack"), (1.0, "hp_2", "barrel")):
        tx, ty = s * 34.0, 4.0
        tz = Z + thick(tx) * 0.5
        b.box(tx - 1.8, tx + 1.8, ty - 3.0, ty + 1.0, tz - 0.4, tz + 1.0, "steel.panel", "mount")
        b.stock(pin, (tx, ty + 1.5, tz + 1.8), kind, scale=0.7)
    for s, pin, kind in ((-1.0, "hp_3", "twin_barrel"), (1.0, "hp_4", "dish")):
        tx, ty = s * 50.0, -2.0
        tz = Z + thick(tx) * 0.5
        b.box(tx - 1.8, tx + 1.8, ty - 3.0, ty + 1.0, tz - 0.4, tz + 1.0, "steel.panel", "mount")
        b.stock(pin, (tx, ty + 1.5, tz + 1.8), kind, scale=0.7)
    for s in (-1.0, 1.0):
        a = math.radians(s * 30.0)
        _rings(b, [[(s * 70.0, 10.0, Z), (s * 70.4, 6.0, Z), (s * 70.0, 2.0, Z), (s * 69.6, 6.0, Z)],
                   [(s * 70.0 + 10.0 * math.sin(a), 3.0, Z + 10.0 * math.cos(a)), (s * 70.0 + 10.0 * math.sin(a) + s * 0.2, 0.5, Z + 10.0 * math.cos(a)),
                    (s * 70.0 + 10.0 * math.sin(a), -2.0, Z + 10.0 * math.cos(a)), (s * 70.0 + 10.0 * math.sin(a) - s * 0.2, 0.5, Z + 10.0 * math.cos(a))]], "livery.livery", "fin")
    boosters = ["booster_ring", "exhaust"]
    b.act("lay_mines", 5.4, body=[(0.6, 0.0, 0.0, 0.0), (1.4, 0.0, 6.0, -1.0, 0.0, -4.0, 0.0), (3.6, 0.0, 10.0, -1.0, 0.0, -3.0, 0.0), (4.6, 0.0, 2.0, 0.5, 0.0, 2.0, 0.0), (5.4, 0.0, 0.0, 0.0)],
          glow=[(["bay_seam"], [(1.0, 0.0), (1.4, 12.0), (1.8, 4.0), (2.2, 14.0), (2.6, 4.0), (3.0, 14.0), (3.6, 14.0), (4.4, 0.0)]), (boosters, [(0.5, 0.0), (1.2, 6.0), (3.8, 6.0), (4.6, 0.0)])])
    b.act("contract", 5.6, {"sensor_contractor": [(0.5, 0.0), (1.9, 60.0), (3.6, 60.0), (5.0, 0.0)]},
          glow=[(["contractor_core"], [(1.8, 0.0), (2.1, 10.0), (2.4, 2.0), (2.7, 12.0), (3.6, 12.0), (4.4, 0.0)])])
    b.gait(body_hold=(0.0, 0.0, 0.0, 0.0, -2.0, 0.0), glow={"parts": boosters, "k": 4.0})
    b.move(slide=0.4, bank=22.0, accel=1.2, heft=0.2, oversteer=0.4)

ktlook_lammergeier_wing.maker = KT


LOOKS = ["ktlook_skua_jaeger4", "ktlook_skua_scissor2", "ktlook_needle_fox", "ktlook_needle_tailsitter", "ktlook_puffin_boat3", "ktlook_storm_hull3", "ktlook_lammergeier_wing"]

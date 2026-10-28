"""A look test for the Kestrel line's sixth round (Ryan, 27 October, on the fifth): the scissor
swing wing tried again, not as the Skua but as a candidate for one of the two unspecced designs
(the Magpie or the Snowy Owl). His brief: no central hub ("it looks like a helicopter"); two
F-14 style sets of swing wings, one aft as normal and one forward and flipped so it swings
toward the nose to collapse; each pair on its own pivot inside the fuselage; open, something
like a tandem wing but not parallel, "maybe open, it's an ornithopter, actually, and closed
it's a speedy blade"; a different body shape to accommodate it and make it believable. Not
content: built only by build_look.py, x right, y forward, z up, as in models_low.py."""

import math

from bl_low import diamond, rect
from kestrel_looks2 import _rot_z
from models_low import _blade_section, _fin_section, _fuse, _hexr, _jet_canopy, _rings

KT = "kestrel"


def ktlook_ornithopter(b):
    """The ornithopter blade. A long slim fuselage, deep and sharp-spined, with two wing bays
    let into it: a fore glove ahead of the canopy and an aft glove behind it, each a flat
    wedge the pair's pivots sit inside, the fore pair's a step above the aft pair's. Each wing
    swings on its own yaw pivot (sweep_fl, sweep_fr, sweep_al, sweep_ar) and beats on a roll
    hinge nested in it (flap_*). Built open: the fore pair raked fifteen degrees forward and
    the aft pair fifteen back, an X of four wings, the tandem that is not parallel; the
    ornithopter beats them in antiphase, the fore pair up as the aft pair comes down. Closed
    (the run's gait), the fore pair swings sixty degrees forward to lie along the nose and the
    aft pair sixty back along the tail, the four wings and the body one blade. One booster
    astern between two canted fins; mounts hp_1 and hp_2 under the aft glove's roots, hp_3
    bare under the nose."""
    FUSE = [(46.0, 1.4, 0.9, 0.6), (36.0, 3.6, 2.2, 1.6), (26.0, 5.4, 3.2, 2.6), (18.0, 6.6, 3.6, 3.0), (10.0, 7.2, 3.8, 3.2), (0.0, 7.2, 3.8, 3.2),
            (-8.0, 7.0, 3.6, 3.1), (-18.0, 6.2, 3.2, 2.8), (-30.0, 5.0, 2.8, 2.4), (-38.0, 4.2, 2.4, 2.0)]
    b.loft([(y, _fuse(w, t, bt)) for (y, w, t, bt) in FUSE], "steel.plate", "fuselage")
    # The spine: a sharp dorsal ridge the length of the body, the blade's back.
    b.loft([(y, diamond(0.0, t + 0.2, 0.9, 1.4)) for (y, w, t, bt) in FUSE[1:-1]], "steel.dark", "spine")
    b.loft([(45.5, diamond(0.0, 0.1, 1.5, 1.4)), (52.0, diamond(0.0, 0.1, 0.3, 0.3))], "steel.dark", "nose_tip")
    _jet_canopy(b, FUSE, [(9.0, 0.9, 0.5), (6.0, 2.2, 2.2), (0.0, 2.6, 2.8), (-6.0, 2.2, 2.2), (-9.5, 1.1, 0.9)], 1.0)
    # The gloves: flat wedges let into the flanks at each pivot station, the fore pair's a step
    # above the aft pair's so the closed wings layer rather than meet.
    def glove(y0, y1, w, z, t, taper):
        b.loft([(y1, [(-w * taper / 2.0, z - t / 2.0), (w * taper / 2.0, z - t / 2.0), (w * taper / 2.0, z + t / 2.0), (-w * taper / 2.0, z + t / 2.0)]),
                ((y0 + y1) / 2.0, [(-w / 2.0, z - t / 2.0), (w / 2.0, z - t / 2.0), (w / 2.0, z + t / 2.0), (-w / 2.0, z + t / 2.0)]),
                (y0, [(-w * taper / 2.0, z - t / 2.0), (w * taper / 2.0, z - t / 2.0), (w * taper / 2.0, z + t / 2.0), (-w * taper / 2.0, z + t / 2.0)])], "steel.dark", "glove")
    FY, FZ, AY, AZ = 16.0, 1.2, -12.0, -0.2   # the fore and aft pivot stations and heights
    glove(FY - 6.0, FY + 7.0, 15.0, FZ - 0.9, 1.6, 0.55)
    glove(AY - 7.0, AY + 6.0, 15.0, AZ - 0.9, 1.6, 0.55)
    PX = 5.6   # the pivots' half spacing, inside the glove
    OPEN = 15.0

    def wing(s, y, z, rake, label):
        """A wing from the pivot at (s * PX, y, z) out along s * x, raked `rake` degrees (a right
        wing's tip toward +y for a positive rake), thin and sharp, tapering to a point."""
        rings = []
        for (dx, le, te, dz, t) in ((0.0, 4.2, -3.4, 0.0, 0.6), (8.0, 3.6, -3.0, -0.1, 0.5), (18.0, 2.4, -2.2, -0.4, 0.36), (26.0, 0.8, -0.9, -0.8, 0.14)):
            rings.append(_rot_z(_blade_section(s * (PX + dx), y + le, y + te, z + dz, t), math.radians(s * rake), s * PX, y))
        _rings(b, rings, "livery.livery", label)
        strip = [_rot_z([(s * (PX + dx), y + le - 0.3, z + dz + 0.05), (s * (PX + dx), y + le - 0.3, z + dz + 0.45), (s * (PX + dx), y + le - 1.3, z + dz + 0.45), (s * (PX + dx), y + le - 1.3, z + dz + 0.05)],
                        math.radians(s * rake), s * PX, y) for (dx, le, te, dz, t) in ((2.0, 4.0, -3.3, 0.0, 0.6), (20.0, 2.0, -2.0, -0.5, 0.3))]
        _rings(b, strip, "amber.ember", label + "_edge")
    for s in (-1.0, 1.0):
        side = "l" if s < 0 else "r"
        # The fore pair: open is raked forward; it closes by swinging further forward along the nose.
        fore_lim = (-62.0, 0.0) if s > 0 else (0.0, 62.0)
        with b.joint("sweep_f" + side, (s * PX, FY, FZ), axis="yaw", limits=fore_lim):
            with b.joint("flap_f" + side, (s * PX, FY, FZ), axis="roll", limits=(-32.0, 32.0)):
                wing(s, FY, FZ, OPEN, "wing_fore")
        # The aft pair: open is raked back; it closes by swinging back along the tail.
        aft_lim = (0.0, 62.0) if s > 0 else (-62.0, 0.0)
        with b.joint("sweep_a" + side, (s * PX, AY, AZ), axis="yaw", limits=aft_lim):
            with b.joint("flap_a" + side, (s * PX, AY, AZ), axis="roll", limits=(-32.0, 32.0)):
                wing(s, AY, AZ, -OPEN, "wing_aft")
        b.prism("z", s * PX, FY, FZ + 0.2, 1.3, 1.2, "steel.plate", 8, "pivot_cap", phase=math.pi / 8)
        b.prism("z", s * PX, AY, AZ + 0.2, 1.3, 1.2, "steel.plate", 8, "pivot_cap", phase=math.pi / 8)
        # The fins: canted out thirty degrees at the tail.
        ca = math.radians(30.0)
        _rings(b, [_fin_section(s * 2.2, -28.0, -38.0, 2.4, 0.5), [(s * (2.2 + 9.0 * math.sin(ca)), y, 2.4 + 9.0 * math.cos(ca) + dz) for (y, dz) in ((-38.5, 0.0), (-35.0, 0.25), (-31.5, 0.0), (-35.0, -0.25))]],
               "livery.livery", "fin")
    # The booster astern.
    y0, w0, t0, b0 = FUSE[-1]
    b.loft([(y0, _fuse(w0, t0, b0)), (-42.0, _hexr(0.0, 0.1, 2.3))], "steel.plate", "tail_fairing")
    b.prism("y", 0.0, -46.0, 0.1, 2.3, 9.0, "steel.dark", 6, "booster", phase=math.pi / 6)
    b.prism("y", 0.0, -50.0, 0.1, 2.7, 1.4, "amber.engine", 6, "booster_ring", phase=math.pi / 6)
    b.loft([(-50.8, _hexr(0.0, 0.1, 2.5)), (-51.3, _hexr(0.0, 0.1, 1.7))], "amber.exhaust", "exhaust")
    # The mounts: under the aft glove's roots, and bare under the nose.
    for s in (-1.0, 1.0):
        b.box(s * 4.0 - 0.6, s * 4.0 + 0.6, AY - 2.0, AY + 3.0, AZ - 2.2, AZ - 0.9, "steel.plate", "pylon")
        b.stock("hp_%d" % (1 if s < 0 else 2), (s * 4.0, AY + 3.0, AZ - 2.6), "barrel" if s < 0 else "twin_barrel", scale=0.4)
    b.pad("hp_3", (0.0, 28.0, -2.8), scale=0.4, size=(3.0, 1.0))

    boosters = ["booster_ring", "exhaust"]
    CL = 60.0   # the sweep from open to the blade (a positive yaw carries a right wing's tip back)
    closed = {"sweep_fr": -CL, "sweep_fl": CL, "sweep_ar": CL, "sweep_al": -CL}
    def sweep_keys(t0, t1, t2, t3):
        """Every sweep from open to closed by t1, held to t2, open again by t3."""
        return {k: [(t0, 0.0), (t1, v), (t2, v), (t3, 0.0)] for k, v in closed.items()}
    def beat(t0, n, amp, period):
        """`n` beats of the flaps from t0, the fore pair up as the aft pair comes down."""
        out = {}
        for k, sgn in (("flap_fl", -1.0), ("flap_fr", 1.0), ("flap_al", 1.0), ("flap_ar", -1.0)):
            keys = [(t0, 0.0)]
            for i in range(n):
                keys.append((t0 + period * (i + 0.5), sgn * amp))
                keys.append((t0 + period * (i + 1.0), -sgn * amp * 0.6))
            keys.append((t0 + period * (n + 0.4), 0.0))
            out[k] = keys
        return out
    # The blade: it folds to the blade, dashes nose down, and unfolds into two beats.
    tracks = sweep_keys(0.3, 1.1, 2.6, 3.5)
    tracks.update(beat(3.6, 2, 24.0, 0.7))
    b.act("blade_dash", 5.6, tracks,
          body=[(0.3, 0.0, 0.0, 0.0), (1.1, 0.0, 2.0, -0.5, 0.0, -6.0, 0.0), (1.6, 0.0, 14.0, -1.5, 0.0, -9.0, 0.0), (2.6, 0.0, 18.0, -1.0, 0.0, -4.0, 0.0),
                (3.5, 0.0, 8.0, 1.0, 0.0, 6.0, 0.0), (4.3, 0.0, 2.0, 2.0, 0.0, 2.0, 0.0), (5.6, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.3, 0.0), (1.1, 9.0), (2.6, 9.0), (3.5, 1.0), (4.4, 0.0)])])
    # The beat: three beats of the four wings in antiphase, the body lifting on each.
    b.act("beat", 4.6, beat(0.5, 3, 30.0, 0.8),
          body=[(0.5, 0.0, 0.0, 0.0), (0.9, 0.0, 0.0, 2.0, 0.0, 3.0, 0.0), (1.3, 0.0, 0.0, 0.5, 0.0, -1.0, 0.0), (1.7, 0.0, 0.0, 2.5, 0.0, 3.0, 0.0), (2.1, 0.0, 0.0, 1.0, 0.0, -1.0, 0.0),
                (2.5, 0.0, 0.0, 3.0, 0.0, 3.0, 0.0), (3.2, 0.0, 0.0, 1.5, 0.0, 0.0, 0.0), (4.6, 0.0, 0.0, 0.0)],
          glow=[(["wing_fore_edge", "wing_aft_edge"], [(0.5, 0.0), (0.9, 8.0), (1.3, 2.0), (1.7, 8.0), (2.1, 2.0), (2.5, 8.0), (3.4, 0.0)])])
    # The hover turn: open, it yaws thirty degrees left on a slow beat and back, the wings on
    # the inside dipping.
    tracks = {"flap_fl": [(0.6, 0.0), (1.4, -14.0), (2.6, -14.0), (3.4, 0.0)], "flap_al": [(0.6, 0.0), (1.4, -10.0), (2.6, -10.0), (3.4, 0.0)],
              "flap_fr": [(0.6, 0.0), (1.4, 10.0), (2.6, 10.0), (3.4, 0.0)], "flap_ar": [(0.6, 0.0), (1.4, 8.0), (2.6, 8.0), (3.4, 0.0)]}
    b.act("hover_turn", 4.8, tracks,
          body=[(0.6, 0.0, 0.0, 0.0), (1.6, -3.0, 1.0, 1.0, 30.0, 0.0, -10.0), (2.6, -3.0, 1.0, 1.0, 30.0, 0.0, -10.0), (3.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (4.8, 0.0, 0.0, 0.0)],
          glow=[(boosters, [(0.6, 0.0), (1.4, 4.0), (2.8, 4.0), (3.6, 0.0)])])
    # The sweep check: the fore pair folds and opens alone, then the aft pair, the pilot
    # cycling each; a twitch of the flaps as each pair comes home.
    tracks = {"sweep_fr": [(0.4, 0.0), (1.1, -CL), (1.7, -CL), (2.4, 0.0)], "sweep_fl": [(0.4, 0.0), (1.1, CL), (1.7, CL), (2.4, 0.0)],
              "sweep_ar": [(2.3, 0.0), (3.0, CL), (3.6, CL), (4.3, 0.0)], "sweep_al": [(2.3, 0.0), (3.0, -CL), (3.6, -CL), (4.3, 0.0)],
              "flap_fl": [(2.3, 0.0), (2.5, -10.0), (2.8, 0.0)], "flap_fr": [(2.3, 0.0), (2.5, 10.0), (2.8, 0.0)],
              "flap_al": [(4.2, 0.0), (4.4, 10.0), (4.7, 0.0)], "flap_ar": [(4.2, 0.0), (4.4, -10.0), (4.7, 0.0)]}
    b.act("sweep_check", 5.2, tracks, body=[(0.4, 0.0, 0.0, 0.0), (1.1, 0.0, 0.0, 0.0, 0.0, -2.0, 0.0), (2.4, 0.0, 0.0, 0.0), (3.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0), (4.3, 0.0, 0.0, 0.0)])
    # Under way it runs as the blade, every wing folded along the body, nose down, banking hard;
    # the ornithopter gait, an option, runs open with the wings beating.
    glow = {"parts": boosters, "k": 5.0}
    flap = {}
    for k, sgn in (("flap_fl", -1.0), ("flap_fr", 1.0), ("flap_al", 1.0), ("flap_ar", -1.0)):
        flap[k] = [(0.0, sgn * 22.0), (0.25, 0.0), (0.5, -sgn * 16.0), (0.75, 0.0), (1.0, sgn * 22.0)]
    b.gait_option("ornithopter", stride=30.0, tracks=flap, glow={"parts": ["wing_fore_edge", "wing_aft_edge"], "k": 4.0}, body_hold=(0.0, 0.0, 0.0, 0.0, 3.0, 0.0))
    b.gait(tracks={k: [(0.0, v), (1.0, v)] for k, v in closed.items()}, glow=glow, body_hold=(0.0, 0.0, 0.0, 0.0, -7.0, 0.0))
    b.move(slide=0.5, bank=40.0, accel=0.6, heft=0.07, oversteer=0.3)

ktlook_ornithopter.maker = KT


LOOKS = ["ktlook_ornithopter"]

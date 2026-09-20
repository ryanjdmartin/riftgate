"""The gate and the walls, as blendforge specs: Arsenal-built, heavily armoured, weathered,
slightly gothic, meant to have survived worse than this. Massing in the same conventions as
the archetypes (x right, y forward toward the enemy, z up, materials by role, "detail" on
small parts), sized so a gate spans three hexes and a wall segment one.

The gate keeps giant demons out and has to look it (Ryan, 20 September): tall rather than
wide, a narrow pointed mouth in stepped reveals, towers well above the wall, and blades along
every top edge instead of crenellations, which read as sand-castle squares.

    forge.py structures            # build models/gate.blend and models/wall.blend, export both glTFs
"""

from archetypes import Build

WALL_H = 70.0      # top of the wall body, shared by the gate and the wall segments
BLADE_H = 16.0     # the blade crown above it


def _blades(m, x0, x1, y, z, step=10.0, w=2.4, d=7.0, h=BLADE_H):
    """A row of upright blades along a top edge, each a wedge that leans back (its thick
    end on the far side of the parapet), so the crown reads as a saw rather than teeth."""
    x = x0
    while x + w <= x1 + 0.01:
        m.wedge(x, x + w, y - d / 2, y + d / 2, z, z + h, "steel_dark", slope="y-", detail=True)
        x += step


def _ribs(m, x0, x1, y, z0, z1, step=14.0, side=1.0):
    x = x0
    while x <= x1 + 0.01:
        m.box(x - 1.2, x + 1.2, y, y + 2.0 * side, z0, z1, "steel_dark", detail=True)
        x += step


def _gun(m, x, y, z):
    """A turret ring, a mount and one heavy barrel, pointing north (+y)."""
    m.cyl("z", x, y, z + 2.5, 12.0, 5.0, "steel_dark")
    m.box(x - 7.0, x + 7.0, y - 8.0, y + 8.0, z + 5.0, z + 15.0, "steel")
    m.cyl("y", x, y + 20.0, z + 11.0, 3.6, 34.0, "steel_dark")
    m.cyl("y", x, y + 37.4, z + 11.0, 4.4, 2.0, "bore", detail=True)
    m.box(x - 4.0, x + 4.0, y - 11.0, y - 8.0, z + 6.0, z + 13.0, "amber", detail=True)   # the sight


def gate():
    import math
    m = Build("gate")
    W = 92.0     # half width: three hexes (181.8 units) plus a little, so the walls meet it
    D = 16.0     # half depth of the wall body
    H = WALL_H
    m.box(-W, W, -D - 8.0, D + 8.0, 0.0, 6.0, "steel_dark")             # plinth
    m.box(-W, W, -D, D, 6.0, H, "steel")                                # the wall
    # The gatehouse: a block between the towers that rises above the wall, so the mouth
    # sits in something taller than the line it guards.
    GW, GH = 46.0, H + 22.0
    m.box(-GW, GW, -D - 3.0, D + 3.0, 6.0, GH, "steel")
    # The mouth: tall and narrow, a pointed slot in three stepped reveals, dark to the back.
    MW, MH = 15.0, 64.0
    m.box(-MW, MW, -D - 4.0, D + 4.0, 6.0, MH, "bore")
    for i, (rw, rh, rd) in enumerate(((MW + 4.0, MH + 6.0, 4.0), (MW + 8.0, MH + 12.0, 5.0), (MW + 12.0, MH + 18.0, 6.0))):
        for f in (-1.0, 1.0):
            y0, y1 = f * (D + 3.0), f * (D + 3.0 + rd)
            m.box(-rw, -rw + 4.0, y0, y1, 6.0, rh, "steel_dark")                      # jambs
            m.box(rw - 4.0, rw, y0, y1, 6.0, rh, "steel_dark")
            m.wedge(-rw, 0.0, y0, y1, rh, rh + rw * 0.55, "steel_dark", slope="x-")   # the point
            m.wedge(0.0, rw, y0, y1, rh, rh + rw * 0.55, "steel_dark", slope="x+")
    for i in range(5):                                                                 # portcullis bars, north face
        x = -12.0 + i * 6.0
        m.box(x - 0.9, x + 0.9, D + 2.0, D + 4.0, 6.0, MH, "steel_dark", detail=True)
    # The Arsenal's device over the mouth, both faces, and a lintel band above it.
    for s in (-1.0, 1.0):
        m.box(-22.0, 22.0, s * (D + 3.0), s * (D + 5.0), GH - 18.0, GH - 6.0, "livery")
    m.box(-GW - 2.0, GW + 2.0, -D - 5.0, D + 5.0, GH - 6.0, GH, "steel_dark")
    _blades(m, -GW + 2.0, GW - 2.0, D - 1.0, GH, step=8.0, h=BLADE_H + 6.0)
    _blades(m, -GW + 2.0, GW - 2.0, -D + 1.0, GH, step=8.0, h=BLADE_H + 6.0)
    # Lamps either side of the mouth, both faces.
    for s in (-1.0, 1.0):
        for f in (-1.0, 1.0):
            m.box(s * 30.0, s * 34.0, f * (D + 3.0), f * (D + 5.0), 30.0, 36.0, "amber", detail=True)
    # Towers: tall, finned, capped, with a gun on each.
    TR, TT = 20.0, 112.0
    for s in (-1.0, 1.0):
        x = s * 66.0
        m.cyl("z", x, 0.0, (6.0 + TT) / 2.0, TR, TT - 6.0, "steel")
        for k in range(8):                                                             # the fins
            a = k * math.pi / 4.0 + math.pi / 8.0
            fx, fy = TR * math.cos(a), TR * math.sin(a)
            m.box(x + fx - 2.0, x + fx + 2.0, fy - 2.0, fy + 2.0, 12.0, TT + 10.0, "steel_dark", detail=True)
        m.cyl("z", x, 0.0, TT + 1.5, TR + 2.0, 3.0, "steel_dark")                      # the cap
        _gun(m, x, 0.0, TT + 3.0)
        # Bastions front and back, sloping out to the plinth.
        for bx in (x - 30.0, x + 30.0):
            if abs(bx) < W - 4.0 and abs(bx) > GW + 2.0:
                m.wedge(bx - 5.0, bx + 5.0, D, D + 14.0, 6.0, H - 6.0, "steel_dark", slope="y+")
                m.wedge(bx - 5.0, bx + 5.0, -D - 14.0, -D, 6.0, H - 6.0, "steel_dark", slope="y-")
    for side in (1.0, -1.0):
        _blades(m, -W + 2.0, -88.0, side * (D - 2.0), H)
        _blades(m, 88.0, W - 2.0, side * (D - 2.0), H)
    _ribs(m, -W + 6.0, -88.0, D, 8.0, H - 2.0)
    _ribs(m, 88.0, W - 6.0, D, 8.0, H - 2.0)
    _ribs(m, -W + 6.0, -88.0, -D, 8.0, H - 2.0, side=-1.0)
    _ribs(m, 88.0, W - 6.0, -D, 8.0, H - 2.0, side=-1.0)
    return m


def wall():
    m = Build("wall")
    W = 31.0     # half width: a hex is 60.6 wide, so neighbours overlap a hair
    D = 12.0
    H = WALL_H   # the gate's wall height, so the line reads as one wall
    m.box(-W, W, -D - 6.0, D + 6.0, 0.0, 6.0, "steel_dark")
    m.box(-W, W, -D, D, 6.0, H, "steel")
    for f in (-1.0, 1.0):
        m.box(-W, W, f * (D + 0.2), f * (D + 1.4), 20.0, 25.0, "livery", detail=True)   # a hazard band, both faces
    m.wedge(-5.0, 5.0, D, D + 12.0, 6.0, H - 6.0, "steel_dark", slope="y+")
    m.wedge(-5.0, 5.0, -D - 12.0, -D, 6.0, H - 6.0, "steel_dark", slope="y-")
    _blades(m, -W + 1.0, W - 1.0, D - 2.0, H)
    _blades(m, -W + 1.0, W - 1.0, -D + 2.0, H)
    _ribs(m, -W + 7.0, W - 7.0, D, 8.0, H - 2.0, step=12.0)
    _ribs(m, -W + 7.0, W - 7.0, -D, 8.0, H - 2.0, step=12.0, side=-1.0)
    return m


STRUCTURES = {"gate": gate, "wall": wall}

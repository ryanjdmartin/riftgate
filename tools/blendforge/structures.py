"""The gate and the walls, as blendforge specs: Arsenal-built, heavily armoured, weathered,
slightly gothic, meant to have survived worse than this. Massing in the same conventions as
the archetypes (x right, y forward toward the enemy, z up, materials by role, "detail" on
small parts), sized so a gate spans three hexes and a wall segment one.

    forge.py structures            # build models/gate.blend and models/wall.blend, export both glTFs
"""

from archetypes import Build


def _crenellations(m, x0, x1, y, z, step=12.0, w=6.0, d=4.0, h=5.0):
    x = x0
    while x + w <= x1 + 0.01:
        m.box(x, x + w, y - d / 2, y + d / 2, z, z + h, "steel_dark", detail=True)
        x += step


def _ribs(m, x0, x1, y, z0, z1, step=14.0, side=1.0):
    x = x0
    while x <= x1 + 0.01:
        m.box(x - 1.0, x + 1.0, y, y + 1.6 * side, z0, z1, "steel_dark", detail=True)
        x += step


def _gun(m, x, y, z):
    """A turret ring, a mount and one heavy barrel, pointing north (+y)."""
    m.cyl("z", x, y, z + 2.0, 9.0, 4.0, "steel_dark")
    m.box(x - 5.0, x + 5.0, y - 6.0, y + 6.0, z + 4.0, z + 11.0, "steel")
    m.cyl("y", x, y + 14.0, z + 8.0, 2.6, 24.0, "steel_dark")
    m.cyl("y", x, y + 26.2, z + 8.0, 3.2, 1.6, "bore", detail=True)
    m.box(x - 3.0, x + 3.0, y - 8.0, y - 6.0, z + 5.0, z + 10.0, "amber", detail=True)   # the sight


def gate():
    m = Build("gate")
    W = 76.0     # half width: three hexes
    D = 13.0     # half depth of the wall body
    H = 34.0     # wall top
    m.box(-W, W, -D - 8.0, D + 8.0, 0.0, 6.0, "steel_dark")             # plinth
    m.box(-W, W, -D, D, 6.0, H, "steel")                                # the wall
    # The gate mouth: a dark recess with a portcullis, and a pointed lintel above it.
    m.box(-14.0, 14.0, -D - 1.0, D + 1.0, 6.0, 28.0, "bore")
    for i in range(5):
        x = -12.0 + i * 6.0
        m.box(x - 0.8, x + 0.8, D - 0.4, D + 1.4, 6.0, 28.0, "steel_dark", detail=True)
    m.wedge(-18.0, 0.0, -D - 1.5, D + 1.5, 28.0, 36.0, "steel_dark", slope="x-")
    m.wedge(0.0, 18.0, -D - 1.5, D + 1.5, 28.0, 36.0, "steel_dark", slope="x+")
    m.box(-22.0, 22.0, D + 0.5, D + 2.0, 36.0, 44.0, "livery")           # the Arsenal's device over the gate
    m.box(-24.0, 24.0, -D - 1.0, D + 2.5, 44.0, 47.0, "steel_dark")
    # Lamps either side of the mouth.
    for s in (-1.0, 1.0):
        m.box(s * 19.0, s * 22.0, D + 0.5, D + 2.0, 18.0, 22.0, "amber", detail=True)
    # Towers, capped, with guns on top.
    for s in (-1.0, 1.0):
        x = s * 48.0
        m.cyl("z", x, 0.0, 22.0, 15.0, 44.0, "steel")
        m.cyl("z", x, 0.0, 45.5, 17.0, 3.0, "steel_dark")
        for k in range(8):
            import math
            a = k * math.pi / 4.0
            m.box(x + 15.0 * math.cos(a) - 2.5, x + 15.0 * math.cos(a) + 2.5, 15.0 * math.sin(a) - 2.5, 15.0 * math.sin(a) + 2.5, 47.0, 52.0, "steel_dark", detail=True)
        _gun(m, x, 0.0, 47.0)
        # Buttresses front and back, sloping out to the plinth.
        for bx in (x - 24.0, x + 24.0):
            if abs(bx) < W - 4.0:
                m.wedge(bx - 4.0, bx + 4.0, D, D + 10.0, 6.0, H - 4.0, "steel_dark", slope="y+")
                m.wedge(bx - 4.0, bx + 4.0, -D - 10.0, -D, 6.0, H - 4.0, "steel_dark", slope="y-")
    _crenellations(m, -W + 2.0, -30.0, D - 2.0, H)
    _crenellations(m, 26.0, W - 2.0, D - 2.0, H)
    _crenellations(m, -W + 2.0, -30.0, -D + 2.0, H)
    _crenellations(m, 26.0, W - 2.0, -D + 2.0, H)
    _ribs(m, -W + 8.0, -32.0, D, 8.0, H - 2.0)
    _ribs(m, 32.0, W - 8.0, D, 8.0, H - 2.0)
    _ribs(m, -W + 8.0, W - 8.0, -D, 8.0, H - 2.0, side=-1.0)
    return m


def wall():
    m = Build("wall")
    W = 26.0
    D = 10.0
    H = 30.0
    m.box(-W, W, -D - 6.0, D + 6.0, 0.0, 6.0, "steel_dark")
    m.box(-W, W, -D, D, 6.0, H, "steel")
    m.box(-W, W, D + 0.2, D + 1.2, 12.0, 15.0, "livery", detail=True)   # a hazard band, the Arsenal's
    m.wedge(-4.0, 4.0, D, D + 9.0, 6.0, H - 4.0, "steel_dark", slope="y+")
    m.wedge(-4.0, 4.0, -D - 9.0, -D, 6.0, H - 4.0, "steel_dark", slope="y-")
    _crenellations(m, -W + 1.0, W - 1.0, D - 2.0, H, step=12.0)
    _crenellations(m, -W + 1.0, W - 1.0, -D + 2.0, H, step=12.0)
    _ribs(m, -W + 8.0, W - 8.0, D, 8.0, H - 2.0, step=12.0)
    _ribs(m, -W + 8.0, W - 8.0, -D, 8.0, H - 2.0, step=12.0, side=-1.0)
    return m


STRUCTURES = {"gate": gate, "wall": wall}

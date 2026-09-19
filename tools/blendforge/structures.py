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
    import math
    m = Build("gate")
    W = 92.0     # half width: three hexes (181.8 units) plus a little, so the walls meet it
    D = 14.0     # half depth of the wall body
    H = 46.0     # wall top
    m.box(-W, W, -D - 8.0, D + 8.0, 0.0, 6.0, "steel_dark")             # plinth
    m.box(-W, W, -D, D, 6.0, H, "steel")                                # the wall
    # The gate mouth: a mech could drive through it. A dark recess with a portcullis on the
    # north face, and a pointed lintel with the Arsenal's device above it, on both faces.
    MW, MH = 22.0, 40.0
    m.box(-MW, MW, -D - 1.0, D + 1.0, 6.0, MH, "bore")
    for i in range(7):
        x = -18.0 + i * 6.0
        m.box(x - 0.8, x + 0.8, D - 0.4, D + 1.4, 6.0, MH, "steel_dark", detail=True)
    m.wedge(-MW - 6.0, 0.0, -D - 1.5, D + 1.5, MH, MH + 10.0, "steel_dark", slope="x-")
    m.wedge(0.0, MW + 6.0, -D - 1.5, D + 1.5, MH, MH + 10.0, "steel_dark", slope="x+")
    for s in (-1.0, 1.0):
        m.box(-30.0, 30.0, s * (D + 0.5), s * (D + 2.0), MH + 10.0, MH + 20.0, "livery")   # the device, both faces
    m.box(-32.0, 32.0, -D - 2.5, D + 2.5, MH + 20.0, MH + 24.0, "steel_dark")
    # Lamps either side of the mouth, both faces.
    for s in (-1.0, 1.0):
        for f in (-1.0, 1.0):
            m.box(s * 27.0, s * 31.0, f * (D + 0.5), f * (D + 2.0), 24.0, 29.0, "amber", detail=True)
    # Towers, capped, with guns on top.
    for s in (-1.0, 1.0):
        x = s * 60.0
        m.cyl("z", x, 0.0, 30.0, 17.0, 60.0, "steel")
        m.cyl("z", x, 0.0, 61.5, 19.0, 3.0, "steel_dark")
        for k in range(8):
            a = k * math.pi / 4.0
            m.box(x + 17.0 * math.cos(a) - 2.5, x + 17.0 * math.cos(a) + 2.5, 17.0 * math.sin(a) - 2.5, 17.0 * math.sin(a) + 2.5, 63.0, 68.0, "steel_dark", detail=True)
        _gun(m, x, 0.0, 63.0)
        # Buttresses front and back, sloping out to the plinth.
        for bx in (x - 26.0, x + 26.0):
            if abs(bx) < W - 4.0 and abs(bx) > MW + 8.0:
                m.wedge(bx - 4.0, bx + 4.0, D, D + 10.0, 6.0, H - 4.0, "steel_dark", slope="y+")
                m.wedge(bx - 4.0, bx + 4.0, -D - 10.0, -D, 6.0, H - 4.0, "steel_dark", slope="y-")
    for side in (1.0, -1.0):
        _crenellations(m, -W + 2.0, -78.0, side * (D - 2.0), H)
        _crenellations(m, 78.0, W - 2.0, side * (D - 2.0), H)
    _ribs(m, -W + 8.0, -80.0, D, 8.0, H - 2.0)
    _ribs(m, 80.0, W - 8.0, D, 8.0, H - 2.0)
    _ribs(m, -W + 8.0, -40.0, -D, 8.0, H - 2.0, side=-1.0)
    _ribs(m, 40.0, W - 8.0, -D, 8.0, H - 2.0, side=-1.0)
    return m


def wall():
    m = Build("wall")
    W = 31.0     # half width: a hex is 60.6 wide, so neighbours overlap a hair
    D = 11.0
    H = 46.0     # the gate's wall height, so the line reads as one wall
    m.box(-W, W, -D - 6.0, D + 6.0, 0.0, 6.0, "steel_dark")
    m.box(-W, W, -D, D, 6.0, H, "steel")
    for f in (-1.0, 1.0):
        m.box(-W, W, f * (D + 0.2), f * (D + 1.2), 14.0, 18.0, "livery", detail=True)   # a hazard band, both faces
    m.wedge(-4.0, 4.0, D, D + 9.0, 6.0, H - 4.0, "steel_dark", slope="y+")
    m.wedge(-4.0, 4.0, -D - 9.0, -D, 6.0, H - 4.0, "steel_dark", slope="y-")
    _crenellations(m, -W + 1.0, W - 1.0, D - 2.0, H, step=12.0)
    _crenellations(m, -W + 1.0, W - 1.0, -D + 2.0, H, step=12.0)
    _ribs(m, -W + 7.0, W - 7.0, D, 8.0, H - 2.0, step=12.0)
    _ribs(m, -W + 7.0, W - 7.0, -D, 8.0, H - 2.0, step=12.0, side=-1.0)
    return m


STRUCTURES = {"gate": gate, "wall": wall}

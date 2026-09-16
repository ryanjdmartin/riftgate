"""Starter silhouettes for Ryan to open in Blender and reshape, one per vehicle type.

Each is a few dozen boxes, cylinders and wedges in the blendforge conventions (origin, on
z = 0, facing +y, materials by role, "detail" on small parts) at the spriter's scale (about
46 wide, 50 tall). They are generic types, not any particular design: the point is that the
proportions, the part split and the material roles are already there, so a new mech starts
by dragging vertices rather than by staring at an empty scene.

    forge.py archetypes            # build every .blend and render a review sheet
    forge.py archetypes tank apc   # just these

Coordinates: x right, y forward, z up. `wedge(..., slope)` is a box whose top edge on the
`slope` side drops to the floor of the box, so "y+" is a glacis sloping down to the front.
"""

from dataclasses import dataclass, field


@dataclass
class Build:
    name: str
    parts: list = field(default_factory=list)

    def box(self, x0, x1, y0, y1, z0, z1, material, detail=False):
        self.parts.append({"type": "box", "lo": [min(x0, x1), min(y0, y1), min(z0, z1)],
                           "hi": [max(x0, x1), max(y0, y1), max(z0, z1)], "material": material, "detail": detail})

    def wedge(self, x0, x1, y0, y1, z0, z1, material, slope="y+", detail=False):
        self.parts.append({"type": "wedge", "lo": [min(x0, x1), min(y0, y1), min(z0, z1)],
                           "hi": [max(x0, x1), max(y0, y1), max(z0, z1)], "material": material,
                           "slope": slope, "detail": detail})

    def cyl(self, axis, cx, cy, cz, radius, length, material, detail=False):
        self.parts.append({"type": "cyl", "axis": axis, "center": [cx, cy, cz], "radius": radius,
                           "length": length, "material": material, "detail": detail})

    def mirror(self, fn):
        fn(-1.0)
        fn(1.0)

    def lift(self, dz):
        for p in self.parts:
            if p["type"] == "cyl":
                p["center"][2] += dz
            else:
                p["lo"][2] += dz
                p["hi"][2] += dz

    def spec(self):
        return {"name": self.name, "parts": self.parts}


# ---------------------------------------------------------------- ground: tracked

def tracks(m, x_in, x_out, y0, y1, h, skirt=3):
    """A pair of track runs with skirts and end sprockets."""
    def one(s):
        m.box(s * x_in, s * x_out, y0, y1, 0, h, "rubber")
        m.box(s * x_in, s * x_out, y0, y1, h, h + skirt, "steel_dark")
        r = h / 2.0
        m.cyl("x", s * (x_in + x_out) / 2, y1 - r, r, r, x_out - x_in + 0.5, "steel_dark", detail=True)
        m.cyl("x", s * (x_in + x_out) / 2, y0 + r, r, r, x_out - x_in + 0.5, "steel_dark", detail=True)
    m.mirror(one)


def tank():
    m = Build("tank")
    tracks(m, 10, 18, -18, 18, 8)
    m.box(-11, 11, -16, 12, 6, 16, "steel")                      # hull
    m.wedge(-11, 11, 12, 21, 6, 16, "livery", "y+")              # glacis
    m.box(-11, 11, -20, -16, 6, 13, "steel_dark")                # rear deck
    m.box(-8, 8, -8, 7, 16, 24, "steel")                         # turret
    m.wedge(-8, 8, 7, 12, 16, 24, "livery", "y+")                # turret face
    m.cyl("y", 0, 19, 20, 2.0, 18, "steel_dark")                 # gun, y 10..28
    m.cyl("y", 0, 28.4, 20, 1.2, 1.0, "bore", detail=True)
    m.cyl("z", -3, -3, 24.6, 2.5, 1.4, "steel_dark", detail=True)  # hatch
    m.box(4, 6, -6, -2, 24, 27, "steel_dark", detail=True)      # sight
    m.box(4.5, 5.5, -2, 5, 25, 26, "steel_dark", detail=True)   # coax gun
    m.box(-2, 2, 11, 12, 17, 19, "amber", detail=True)          # marking
    return m


def h_tank():
    m = Build("h_tank")
    def pod(s):
        m.box(s * 13, s * 22, -20, 20, 0, 9, "rubber")
        m.box(s * 13, s * 22, -20, 20, 9, 13, "steel_dark")
        m.wedge(s * 13, s * 22, 16, 22, 5, 13, "livery", "y+")    # pod nose
        m.cyl("x", s * 17.5, 16, 4.5, 4.5, 9.5, "steel_dark", detail=True)
        m.cyl("x", s * 17.5, -16, 4.5, 4.5, 9.5, "steel_dark", detail=True)
        m.box(s * 14, s * 21, -21, -19, 6, 12, "bore", detail=True)  # exhaust
    m.mirror(pod)
    m.box(-13, 13, -9, 9, 7, 16, "steel")                        # bridge between the pods
    m.box(-9, 9, -9, 9, 16, 25, "steel")                         # turret
    m.wedge(-9, 9, 9, 14, 16, 25, "livery", "y+")
    m.cyl("y", -4, 18, 21, 1.8, 14, "steel_dark")                # twin guns
    m.cyl("y", 4, 18, 21, 1.8, 14, "steel_dark")
    m.cyl("y", -4, 25.4, 21, 1.0, 1.0, "bore", detail=True)
    m.cyl("y", 4, 25.4, 21, 1.0, 1.0, "bore", detail=True)
    m.box(-3, 3, -8, -2, 25, 30, "steel_dark")                   # sensor mast
    m.box(-2, 2, -7, -3, 30, 31.5, "amber", detail=True)
    return m


def hover_tank():
    m = Build("hover_tank")
    m.box(-15, 15, -18, 18, 0, 3, "rubber")                      # skirt
    m.box(-13, 13, -16, 14, 3, 11, "steel")                      # hull
    m.wedge(-13, 13, 14, 22, 3, 11, "livery", "y+")              # bow
    m.wedge(-13, 13, -22, -16, 3, 11, "steel_dark", "y-")        # stern
    m.box(-7, 7, -6, 6, 11, 17, "steel")                         # low turret
    m.wedge(-7, 7, 6, 10, 11, 17, "livery", "y+")
    m.cyl("y", 0, 14, 14, 1.8, 16, "steel_dark")
    m.cyl("y", 0, 22.4, 14, 1.0, 1.0, "bore", detail=True)
    def thruster(s):
        m.cyl("y", s * 10, -16, 8, 3.0, 8, "steel_dark")
        m.cyl("y", s * 10, -20.4, 8, 2.2, 1.0, "hot", detail=True)
    m.mirror(thruster)
    m.box(-4, 4, 8, 9, 12, 14, "glass", detail=True)             # driver's slit
    m.lift(5)
    return m


def missile_platform():
    m = Build("missile_platform")
    tracks(m, 10, 18, -19, 19, 7)
    m.box(-11, 11, -20, 20, 5, 13, "steel")                      # chassis
    m.box(-11, 11, 8, 20, 13, 21, "steel")                       # cab
    m.wedge(-11, 11, 20, 24, 13, 21, "livery", "y+")
    m.box(-8, 8, 19.5, 20.5, 15, 20, "glass", detail=True)       # windscreen
    m.box(-10, 10, -19, 2, 15, 27, "steel_dark")                 # launcher pod
    m.wedge(-10, 10, 2, 12, 15, 27, "livery", "y+")              # sloped front of the pod
    m.box(-10, 10, -19, 6, 13, 15, "steel")                      # cradle
    for x in (-6.5, 0, 6.5):
        for z in (18, 23.5):
            m.box(x - 2.2, x + 2.2, -19.6, -18.8, z - 1.8, z + 1.8, "bore", detail=True)  # tube ends
    m.box(-2, 2, -6, 2, 27, 30, "steel_dark", detail=True)      # aiming mast
    return m


# ---------------------------------------------------------------- ground: wheeled

def wheel(m, x, y, z, r, w):
    m.cyl("x", x, y, z, r, w, "rubber")
    m.cyl("x", x, y, z, r * 0.45, w + 0.6, "steel_dark", detail=True)


def apc_6x6():
    m = Build("apc_6x6")
    for y in (-14, 0, 14):
        wheel(m, -12.5, y, 5, 5, 4)
        wheel(m, 12.5, y, 5, 5, 4)
    m.box(-11, 11, -21, 19, 6, 17, "steel")                      # hull
    m.wedge(-11, 11, 19, 26, 6, 17, "livery", "y+")              # nose
    m.wedge(-11, 11, -21, -17, 14, 17, "steel_dark", "y-")       # rear slope
    m.box(-9, 9, 12, 18, 17, 20, "steel")                        # cab top
    m.box(-8, 8, 18, 19, 17.5, 19.5, "glass", detail=True)       # windscreen
    m.cyl("z", 0, -6, 18.5, 4.5, 3, "steel_dark")                # turret ring
    m.cyl("y", 0, 0, 19.5, 1.0, 8, "steel_dark", detail=True)   # turret gun
    m.box(-2, 2, 21, 22, 12, 14, "amber", detail=True)          # headlights
    m.box(-9, -6, -20, -14, 17, 18.5, "steel_dark", detail=True)  # stowage
    return m


def buggy_4x4():
    m = Build("buggy_4x4")
    for y in (-11, 11):
        wheel(m, -11, y, 6, 6, 5)
        wheel(m, 11, y, 6, 6, 5)
    m.box(-8, 8, -15, 8, 6, 11, "steel")                         # tub
    m.wedge(-8, 8, 8, 17, 6, 12, "livery", "y+")                 # bonnet
    m.box(-5, 5, 2, 8, 11, 15, "glass")                          # windscreen
    def cage(s):
        m.box(s * 6.5, s * 8, -12, -10.5, 11, 19, "steel_dark")  # rear post
        m.box(s * 6.5, s * 8, 1, 2.5, 11, 19, "steel_dark")      # front post
        m.box(s * 6.5, s * 8, -12, 2.5, 18, 19.5, "steel_dark")  # rail
    m.mirror(cage)
    m.box(-8, 8, -12, -10.5, 18, 19.5, "steel_dark")             # rear cross bar
    m.cyl("z", 0, -6, 13, 1.0, 5, "steel_dark", detail=True)    # gun post
    m.cyl("y", 0, -2, 20.5, 1.2, 10, "steel_dark")               # ring gun
    m.cyl("y", 0, 3.4, 20.5, 0.7, 1.0, "bore", detail=True)
    m.box(-7, -5, -15.5, -14.5, 7, 9, "amber", detail=True)    # tail light
    return m


# ---------------------------------------------------------------- walkers

def spider_tank():
    m = Build("spider_tank")
    m.box(-10, 10, -11, 9, 10, 20, "steel")                      # body
    m.wedge(-10, 10, 9, 15, 10, 20, "livery", "y+")              # face
    m.box(-4, 4, 12, 13, 15, 18, "glass", detail=True)           # eye slit
    m.cyl("y", 0, 14, 12, 1.6, 10, "steel_dark")                 # chin gun
    m.cyl("y", 0, 19.4, 12, 0.9, 1.0, "bore", detail=True)
    m.cyl("z", 0, -4, 20.6, 4, 1.2, "steel_dark", detail=True)  # top hatch
    def leg(sx, sy):
        m.cyl("x", sx * 11, sy * 6, 15, 2.5, 4, "steel_dark", detail=True)  # hip pin
        m.box(sx * 10, sx * 19, sy * 4, sy * 9, 13, 18, "livery")     # upper leg, out
        m.box(sx * 17, sx * 21, sy * 4, sy * 9, 2, 16, "steel_dark")  # lower leg, down
        m.box(sx * 16, sx * 22, sy * 3, sy * 10, 0, 2, "rubber")     # foot
    for sx in (-1, 1):
        for sy in (-1, 1):
            leg(sx, sy)
    return m


def walker_plantigrade():
    m = Build("walker_plantigrade")
    def leg(s):
        m.box(s * 4, s * 12, -6, 8, 0, 3, "steel_dark")          # flat foot
        m.box(s * 5, s * 11, -3, 3, 3, 16, "steel")              # shin
        m.cyl("x", s * 8, 0, 16.5, 3.5, 7, "steel_dark")         # knee
        m.box(s * 5, s * 11, -3, 4, 17, 27, "livery")            # thigh
    m.mirror(leg)
    m.box(-13, 13, -5, 5, 26, 31, "steel_dark")                  # pelvis
    m.box(-12, 12, -6, 7, 31, 44, "steel")                       # torso
    m.wedge(-12, 12, 7, 11, 34, 44, "livery", "y+")              # chest plate
    m.box(-4, 4, 9.5, 10.5, 39, 43, "glass", detail=True)        # cockpit
    m.box(-3, 3, -2, 4, 44, 49, "steel_dark")                    # head
    m.box(-2, 2, 4, 4.8, 45.5, 47.5, "amber", detail=True)      # sensor
    def arm(s):
        m.box(s * 12, s * 19, -5, 5, 36, 45, "steel")            # shoulder
        m.box(s * 13, s * 18, -4, 14, 30, 37, "steel_dark")      # weapon pod, forward
        m.cyl("y", s * 15.5, 14.4, 33.5, 1.8, 1.0, "bore", detail=True)
    m.mirror(arm)
    return m


def walker_digitigrade():
    m = Build("walker_digitigrade")
    m.box(-11, 11, -8, 9, 26, 38, "steel")                       # torso
    m.wedge(-11, 11, 9, 15, 28, 38, "livery", "y+")              # nose
    m.box(-4, 4, 12, 13, 32, 36, "glass", detail=True)           # cockpit slit
    m.box(-4, 4, -12, -8, 28, 36, "steel_dark")                  # rear radiator
    def leg(s):
        m.cyl("x", s * 12.5, -2, 30, 3.5, 5, "steel_dark")       # hip
        m.box(s * 10, s * 15, -2, 8, 20, 30, "livery")           # thigh, forward
        m.box(s * 10, s * 15, -12, -4, 10, 22, "steel_dark")     # shin, back (reverse knee)
        m.cyl("x", s * 12.5, -4, 21, 3, 5.5, "steel", detail=True)  # knee
        m.box(s * 10, s * 15, -8, 2, 3, 12, "steel")             # ankle
        m.box(s * 8, s * 17, -4, 10, 0, 3, "steel_dark")         # foot
        m.box(s * 8, s * 10, 10, 13, 0, 2, "steel_dark", detail=True)   # toes
        m.box(s * 15, s * 17, 10, 13, 0, 2, "steel_dark", detail=True)
    m.mirror(leg)
    def pod(s):
        m.box(s * 11, s * 19, -6, 10, 30, 38, "steel")           # weapon pod
        m.cyl("y", s * 15, 10.4, 34, 2.2, 1.0, "bore", detail=True)
        m.box(s * 12, s * 18, -5, 3, 38, 40.5, "livery", detail=True)  # missile box lid
    m.mirror(pod)
    return m


def walker_quad():
    m = Build("walker_quad")
    m.box(-10, 10, -16, 14, 30, 44, "steel")                     # body
    m.box(-9, 9, -14, 12, 44, 45.5, "livery", detail=True)       # top plate
    m.box(-4, 4, 14, 20, 34, 40, "steel_dark")                   # neck
    m.box(-7, 7, 20, 30, 32, 42, "livery")                       # head
    m.box(-5, 5, 29.5, 30.5, 36, 39, "glass", detail=True)       # visor
    m.cyl("y", -4, 31, 34, 1.2, 4, "steel_dark", detail=True)    # chin guns
    m.cyl("y", 4, 31, 34, 1.2, 4, "steel_dark", detail=True)
    def leg(sx, sy):
        m.box(sx * 7, sx * 12, sy * 8, sy * 14, 18, 32, "steel")       # thigh
        m.cyl("x", sx * 9.5, sy * 11, 18.5, 3.0, 6, "steel_dark", detail=True)  # knee
        m.box(sx * 8, sx * 12, sy * 9, sy * 13, 3, 18, "steel_dark")   # shin
        m.box(sx * 6, sx * 14, sy * 7, sy * 15, 0, 3, "rubber")        # foot
    for sx in (-1, 1):
        for sy in (-1, 1):
            leg(sx, sy)
    return m


# ---------------------------------------------------------------- air

def fighter():
    m = Build("fighter")
    m.box(-4, 4, -18, 12, 10, 17, "steel")                       # fuselage
    m.wedge(-4, 4, 12, 24, 10, 17, "steel_dark", "y+")           # nose
    m.box(-3, 3, 0, 9, 17, 20, "glass")                          # canopy
    m.box(-4, 4, -10, 0, 17, 18.5, "livery")                     # spine
    m.box(-22, 22, -10, -4, 12, 14, "livery")                    # wing, outer
    m.box(-14, 14, -4, 2, 12, 14, "livery")                      # wing, root
    m.box(-11, 11, -18, -13, 12, 13.5, "steel")                  # tailplane
    def fin(s):
        m.box(s * 4.5, s * 6, -18, -10, 17, 26, "livery")
        m.box(s * 4.3, s * 6.2, -18, -15, 24.5, 26, "amber", detail=True)
    m.mirror(fin)
    def engine(s):
        m.cyl("y", s * 4.5, -15, 12, 3.0, 12, "steel_dark")
        m.cyl("y", s * 4.5, -21.4, 12, 2.2, 1.0, "hot", detail=True)
    m.mirror(engine)
    def missile(s):
        m.cyl("y", s * 17, -5, 11, 1.2, 10, "steel_dark", detail=True)
    m.mirror(missile)
    m.lift(8)
    return m


def fighter_forward_swept():
    m = Build("fighter_forward_swept")
    m.box(-4, 4, -18, 12, 10, 17, "steel")
    m.wedge(-4, 4, 12, 24, 10, 17, "steel_dark", "y+")
    m.box(-3, 3, 1, 10, 17, 20, "glass")
    m.box(-9, 9, -14, -6, 12, 14, "livery")                      # wing root, at the back
    m.box(-16, 16, -8, -2, 12, 14, "livery")                     # mid
    m.box(-22, 22, -2, 4, 12, 14, "livery")                      # tips, forward of the root
    m.box(-9, 9, 8, 12, 13, 14.5, "steel")                       # canards
    m.box(-1, 1, -18, -9, 17, 27, "livery")                      # single fin
    m.box(-1.2, 1.2, -18, -15, 25.5, 27, "amber", detail=True)
    def engine(s):
        m.cyl("y", s * 4.5, -15, 12, 3.0, 12, "steel_dark")
        m.cyl("y", s * 4.5, -21.4, 12, 2.2, 1.0, "hot", detail=True)
    m.mirror(engine)
    m.lift(8)
    return m


def gunship():
    m = Build("gunship")
    m.box(-14, 14, -22, 16, 8, 22, "steel")                      # hull
    m.wedge(-14, 14, 16, 26, 8, 22, "livery", "y+")              # bow
    m.box(-6, 6, -6, 4, 22, 28, "steel")                         # bridge
    m.box(-5, 5, 4, 5, 24, 27, "glass", detail=True)
    def battery(s):
        m.box(s * 14, s * 19, -4, 8, 11, 19, "steel_dark")       # side turret housing
        m.cyl("y", s * 16.5, 10, 15, 2.2, 10, "steel_dark")      # gun
        m.cyl("y", s * 16.5, 15.4, 15, 1.2, 1.0, "bore", detail=True)
    m.mirror(battery)
    def nacelle(s):
        m.cyl("y", s * 10, -20, 13, 4.5, 12, "steel_dark")
        m.cyl("y", s * 10, -26.4, 13, 3.4, 1.0, "hot", detail=True)
    m.mirror(nacelle)
    m.cyl("z", 0, -14, 22.8, 4, 1.6, "steel_dark", detail=True)  # dorsal turret
    m.cyl("y", 0, -8, 24, 1.0, 8, "steel_dark", detail=True)
    m.box(-2, 2, 25, 26, 14, 16, "amber", detail=True)          # bow light
    m.lift(10)
    return m


def helicopter_heavy():
    m = Build("helicopter_heavy")
    m.box(-5, 5, -8, 12, 8, 18, "steel")                         # fuselage
    m.wedge(-5, 5, 12, 20, 8, 18, "glass", "y+")                 # nose glazing
    m.box(-2.5, 2.5, -24, -8, 12, 16, "steel_dark")              # tail boom
    m.box(-1, 1, -26, -20, 14, 24, "livery")                     # tail fin
    m.cyl("x", 3, -23, 20, 4, 0.6, "steel_dark", detail=True)   # tail rotor
    m.box(-14, 14, 0, 5, 11, 13, "livery")                       # stub wings
    def pod(s):
        m.cyl("y", s * 11, 2, 9.5, 2.0, 9, "steel_dark")
        m.cyl("y", s * 11, 6.9, 9.5, 1.2, 1.0, "bore", detail=True)
    m.mirror(pod)
    m.cyl("z", 0, 2, 19.5, 1.5, 3, "steel_dark", detail=True)   # rotor mast
    m.box(-20, 20, 1.5, 2.5, 21, 21.8, "steel_dark")             # blades
    m.box(-0.5, 0.5, -18, 22, 21, 21.8, "steel_dark")
    m.cyl("y", 0, 2, 21.4, 1.8, 2.4, "steel_dark", detail=True)  # hub
    def skid(s):
        m.box(s * 5.5, s * 6.5, -6, 8, 5, 6, "steel_dark")
        m.box(s * 5.5, s * 6.5, -2, 4, 6, 8, "steel_dark", detail=True)
    m.mirror(skid)
    m.lift(3)
    return m


def helicopter_fan():
    m = Build("helicopter_fan")
    m.box(-4, 4, -12, 14, 8, 16, "steel")                        # sleek fuselage
    m.wedge(-4, 4, 14, 22, 8, 16, "glass", "y+")                 # nose glazing
    m.box(-20, 20, -4, 6, 11, 13.5, "livery")                    # wing
    def fan(s):
        m.cyl("z", s * 13, 1, 12.25, 6.0, 2.6, "steel_dark")     # duct
        m.cyl("z", s * 13, 1, 13.6, 4.4, 0.4, "bore", detail=True)  # the fan opening
    m.mirror(fan)
    m.box(-2, 2, -22, -12, 11, 14, "steel_dark")                 # tail boom
    def tailfin(s):
        m.box(s * 3, s * 4.2, -22, -16, 13, 20, "livery")
    m.mirror(tailfin)
    m.cyl("y", 0, -14, 13, 4.0, 2.0, "steel_dark")               # pusher fan
    m.cyl("y", 0, -15.3, 13, 3.0, 0.4, "bore", detail=True)
    m.box(-1.5, 1.5, 4, 10, 16, 17, "amber", detail=True)       # roof light
    m.lift(7)
    return m


def freighter():
    m = Build("freighter")
    m.box(-10, 10, -14, 6, 8, 22, "steel")                       # main hull
    m.box(-12, 12, -12, 2, 4, 8, "steel_dark")                   # cargo belly
    m.box(-9, 9, -10, 4, 22, 23.5, "livery", detail=True)        # top panel
    m.box(-4, 4, 6, 14, 12, 18, "steel_dark")                    # neck
    m.box(-5, 5, 14, 24, 12, 20, "steel")                        # forward cockpit
    m.wedge(-5, 5, 24, 26, 12, 20, "glass", "y+")                # cockpit glazing
    def pod(s):
        m.box(s * 10, s * 13, -8, -2, 12, 16, "steel")           # stub
        m.cyl("y", s * 16, -6, 14, 4.5, 18, "steel_dark")        # engine pod
        m.cyl("y", s * 16, -15.4, 14, 3.4, 1.0, "hot", detail=True)
    m.mirror(pod)
    m.cyl("y", 0, -19, 15, 6.0, 8, "steel_dark")                 # main drive
    m.cyl("y", 0, -23.4, 15, 4.6, 1.0, "hot", detail=True)
    m.box(-2, 2, 26, 26.6, 15, 17, "amber", detail=True)        # nav light
    m.lift(8)
    return m


ARCHETYPES = {
    "tank": tank,
    "h_tank": h_tank,
    "hover_tank": hover_tank,
    "spider_tank": spider_tank,
    "apc_6x6": apc_6x6,
    "buggy_4x4": buggy_4x4,
    "missile_platform": missile_platform,
    "walker_plantigrade": walker_plantigrade,
    "walker_digitigrade": walker_digitigrade,
    "walker_quad": walker_quad,
    "fighter": fighter,
    "fighter_forward_swept": fighter_forward_swept,
    "gunship": gunship,
    "helicopter_heavy": helicopter_heavy,
    "helicopter_fan": helicopter_fan,
    "freighter": freighter,
}

"""Lowforge, the Blender side: the mid-nineties 3D register (Descent, MechWarrior 2), tried
21 September. A model is a few hundred deliberate facets, flat shaded, wearing small tiled
textures (64 px, generated here: brushed metal, panels, stripes, vents, lights, glass,
treads, engines) applied by box projection, so nothing is ever unwrapped.

    Blender -b -P bl_low.py -- --model honey_badger --out art/models/honey_badger.glb --tiles tools/lowforge/tiles

Conventions as the rest of the art: x right, y forward toward the enemy, z up; a mech is
about one hex (60 units) wide. Materials are named "<role>.<tile>" so the engine's toon and
ink passes still know the role.
"""

import math
import os
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

TILE = 64          # texels per tile
TILE_WORLD = 14.0  # world units one tile covers, so a mech gets about four texels per unit


def _args():
    argv = sys.argv[sys.argv.index("--") + 1:]
    return {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv), 2)}


# ---------------------------------------------------------------- tiles

## The primary differentiator between makers (Ryan, 21 September): the metal itself.
## grey is the base value, streak the brushed banding, mottle the grain, tint the cast,
## livery the maker's colour, rivets the panel stud spacing (0 for none).
## Ryan's tones (21 September): Minerva steel and military greens, matte; Kestrel chrome,
## silver and blues; Wainwright & Sutler iron and warm browns; Aphelion whites and reds;
## the Arsenal dark steel and gunmetal.
MAKERS = {
    "minerva": {"grey": 0.40, "streak": 0.05, "mottle": 0.03, "tint": (0.86, 0.90, 0.87), "livery": (0.42, 0.50, 0.28), "rivets": 12},
    "kestrel": {"grey": 0.70, "streak": 0.04, "mottle": 0.012, "tint": (0.92, 0.95, 1.0), "livery": (0.16, 0.40, 0.88), "rivets": 0},
    "wainwright_sutler": {"grey": 0.42, "streak": 0.045, "mottle": 0.025, "tint": (1.0, 0.88, 0.76), "livery": (0.52, 0.29, 0.16), "rivets": 8},   # calmer grain than the first cut: it read as wood (Ryan, 22 September)
    "aphelion": {"grey": 0.80, "streak": 0.02, "mottle": 0.01, "tint": (1.0, 1.0, 1.0), "livery": (0.86, 0.12, 0.12), "rivets": 0},
    "arsenal": {"grey": 0.28, "streak": 0.025, "mottle": 0.012, "tint": (0.88, 0.90, 0.96), "livery": (0.36, 0.38, 0.42), "rivets": 16},
}


class Tiles:
    """Generated 64 px tiles in a maker's metal, cached by name, saved as PNG for review."""

    def __init__(self, out_dir, maker="minerva", seed=7):
        self.maker = maker
        self.p = MAKERS.get(maker, MAKERS["minerva"])
        self.out_dir = os.path.join(out_dir, maker)
        self.rng = np.random.default_rng(seed)
        self.images = {}
        os.makedirs(self.out_dir, exist_ok=True)

    def metal(self, grey=None, streak=None, tint=(1.0, 1.0, 1.0), mottle=None, cast=None):
        p = self.p
        cast = p["tint"] if cast is None else cast
        grey = p["grey"] if grey is None else grey
        streak = p["streak"] if streak is None else streak
        mottle = p["mottle"] if mottle is None else mottle
        rows = self.rng.uniform(-streak, streak, size=(TILE, 1, 1)).astype(np.float32)
        noise = self.rng.uniform(-mottle, mottle, size=(TILE, TILE, 1)).astype(np.float32)
        smear = np.zeros_like(noise)
        for i in range(7):
            smear += np.roll(noise, i, axis=1)
        img = np.full((TILE, TILE, 3), grey, np.float32) + rows + smear
        return np.clip(img * np.array(cast, np.float32) * np.array(tint, np.float32), 0.0, 1.0)

    def _seam(self, img, dark=0.28):
        img[0:2, :, :] *= dark
        img[:, 0:2, :] *= dark
        return img

    def _rivets(self, img, step=None, inset=4, dark=0.45):
        step = self.p["rivets"] if step is None else step
        if step <= 0:
            return img
        for y in range(inset, TILE, step):
            for x in range(inset, TILE, step):
                img[y:y + 2, x:x + 2, :] *= dark
                img[y - 1:y, x:x + 2, :] = np.minimum(img[y - 1:y, x:x + 2, :] * 1.3, 1.0)
        return img

    def get(self, name):
        if name in self.images:
            return self.images[name]
        kind = name.split("_")[0]
        g = self.p["grey"]
        if kind == "metal":
            img = self.metal()
        elif kind == "panel":
            img = self._rivets(self._seam(self.metal()))
        elif kind == "plate":
            img = self._seam(self.metal(g * 1.08, self.p["streak"] * 0.6))
        elif kind == "dark":
            img = self.metal(g * 0.55, 0.05)
        elif kind == "vent":
            # Grilles read by contrast, not grain: a calm base and deep slits.
            img = self.metal(g * 0.85, 0.03, mottle=0.015)
            for y in range(6, TILE - 4, 10):
                img[y:y + 4, 6:TILE - 6, :] *= 0.15
                img[y - 1:y, 6:TILE - 6, :] = np.minimum(img[y - 1:y, 6:TILE - 6, :] * 1.6, 1.0)
        elif kind == "stripe":
            img = self.metal(g, 0.06)
            for y in range(TILE):
                for x in range(TILE):
                    if 22 <= y < 42:
                        band = ((x + y) // 8) % 2 == 0
                        img[y, x, :] = np.array([0.95, 0.75, 0.10], np.float32) * (0.9 + img[y, x, 0] * 0.2) if band else np.array([0.10, 0.10, 0.10], np.float32)
        elif kind == "strip":
            # A light strip: dark housing with one bright amber line, for the emissive role.
            img = self.metal(g * 0.5, 0.03, mottle=0.01)
            img[28:36, :, :] = np.array([1.0, 0.80, 0.30], np.float32)
            img[30:34, :, :] = np.array([1.0, 0.95, 0.70], np.float32)
        elif kind == "light":
            img = self.metal(0.25, 0.04)
            img[14:50, 10:54, :] = np.array([1.0, 0.92, 0.62], np.float32)
            img[18:46, 14:50, :] = np.array([1.0, 0.98, 0.85], np.float32)
        elif kind == "glass":
            # Cockpit glass: a cool blue gradient with a diagonal glint, or red for the
            # Arsenal (Ryan, 30 September: red glass is the Arsenal's staple).
            img = np.zeros((TILE, TILE, 3), np.float32)
            red = self.maker == "arsenal"
            for y in range(TILE):
                for x in range(TILE):
                    t = (x + y) / (2.0 * TILE)
                    if red:
                        img[y, x, :] = np.array([0.45 + 0.50 * t, 0.04 + 0.10 * t, 0.06 + 0.10 * t], np.float32)
                    else:
                        img[y, x, :] = np.array([0.10 + 0.25 * t, 0.30 + 0.35 * t, 0.42 + 0.45 * t], np.float32)
            img[:, :, :] *= 0.85
            for d in range(-4, 4):
                for y in range(TILE):
                    x = (TILE - y + d) % TILE
                    img[y, x, :] = np.minimum(img[y, x, :] * 1.6, 1.0)
        elif kind == "tread":
            # Dark rubber with low cleats: darker than any vent, so the two never read alike.
            img = self.metal(0.13, 0.015, mottle=0.008)
            for x in range(0, TILE, 8):
                img[:, x:x + 3, :] *= 0.55
                img[:, x + 3:x + 4, :] = np.minimum(img[:, x + 3:x + 4, :] * 1.35, 1.0)
        elif kind == "engine":
            img = self.metal(0.28, 0.05)
            img[8:56, 8:56, :] = np.array([0.55, 0.05, 0.03], np.float32)
            img[14:50, 14:50, :] = np.array([0.95, 0.12, 0.05], np.float32)
            img[22:42, 22:42, :] = np.array([1.0, 0.45, 0.20], np.float32)
        elif kind == "missile":
            img = self.metal(g * 0.9, 0.03, mottle=0.01)
            for cy in (11, 32, 53):
                for cx in (11, 32, 53):
                    yy, xx = np.mgrid[0:TILE, 0:TILE]
                    r = np.sqrt((yy - cy) ** 2 + (xx - cx) ** 2)
                    img[r < 8.0] = np.array([0.55, 0.55, 0.58], np.float32)
                    img[r < 6.0] = np.array([0.08, 0.08, 0.09], np.float32)
        elif kind == "ladder":
            img = self.metal(g, 0.05)
            img[:, 20:24, :] *= 0.4
            img[:, 40:44, :] *= 0.4
            for y in range(4, TILE, 10):
                img[y:y + 3, 20:44, :] = np.minimum(img[y:y + 3, 20:44, :] * 1.6, 1.0)
        elif kind == "livery":
            img = self.metal(0.70, self.p["streak"], tint=self.p["livery"])
        elif kind == "livery2":
            img = self._seam(self.metal(0.70, self.p["streak"], tint=self.p["livery"]))
        elif kind == "bone":
            # Bone is paint, not the maker's metal: the same white for everyone, no cast.
            img = self._seam(self.metal(0.74, self.p["streak"] * 0.5, tint=(0.96, 0.93, 0.85), mottle=0.012, cast=(1.0, 1.0, 1.0)))
        elif kind == "fist":
            # The front of a closed fist, one tile a face (Ryan, 28 September, third try): the
            # arm hangs, the knuckles face forward, so the four fingers stand side by side as
            # columns down the face, split by three grooves, a lit knuckle at the top of each,
            # and the thumb lies as a band across the bottom, curled over the fingers. Image
            # row 0 is the bottom of the tile.
            img = self.metal(g * 1.04, self.p["streak"] * 0.5, mottle=0.008)
            for x in (16, 32, 48):
                img[16:TILE - 3, x - 1:x + 2, :] *= 0.3
            img[TILE - 8:TILE - 5, 3:TILE - 3, :] = np.minimum(img[TILE - 8:TILE - 5, 3:TILE - 3, :] * 1.3, 1.0)
            img[TILE - 3:TILE, :, :] *= 0.4
            img[14:16, 2:TILE - 2, :] *= 0.3
            img[2:14, :, :] = self.metal(g * 1.0, self.p["streak"] * 0.5, mottle=0.008)[2:14, :, :]
            img[9:11, 2:TILE - 6, :] = np.minimum(img[9:11, 2:TILE - 6, :] * 1.25, 1.0)
            img[2:14, TILE - 6:TILE - 4, :] *= 0.35
            img[0:2, :, :] *= 0.4
        elif kind == "thumb":
            # The inside of the fist: the thumb bent, coming down from the wrist and turning
            # forward along the bottom (u runs back to front, v up), lit along its ridge; the
            # rest plain metal.
            img = self.metal(g * 1.0, self.p["streak"] * 0.5, mottle=0.008)
            band = self.metal(g * 1.06, self.p["streak"] * 0.5, mottle=0.008)
            img[22:TILE, 34:48, :] = band[22:TILE, 34:48, :]          # down from the wrist
            img[8:24, 34:TILE - 2, :] = band[8:24, 34:TILE - 2, :]    # the bend, forward
            img[22:TILE, 32:34, :] *= 0.3
            img[22:TILE, 48:50, :] *= 0.3
            img[24:26, 48:TILE - 2, :] *= 0.3
            img[6:8, 34:TILE - 2, :] *= 0.3
            img[8:24, 32:34, :] *= 0.3
            img[26:TILE, 40:42, :] = np.minimum(img[26:TILE, 40:42, :] * 1.2, 1.0)
        elif kind == "hazard":
            img = self.metal(g, 0.05)
            img[26:38, :, :] = np.array([0.95, 0.75, 0.10], np.float32)
        else:
            img = self.metal()
        image = bpy.data.images.new(name, TILE, TILE, alpha=True)
        rgba = np.ones((TILE, TILE, 4), np.float32)
        rgba[..., :3] = img
        image.pixels = rgba.ravel().tolist()
        image.filepath_raw = os.path.join(self.out_dir, name + ".png")
        image.file_format = "PNG"
        image.save()
        self.images[name] = image
        return image


# ---------------------------------------------------------------- geometry

def rect(cx, w, z0, z1):
    """A rectangle cross-section as (x, z) points, counter-clockwise seen from +y."""
    return [(cx - w / 2, z0), (cx + w / 2, z0), (cx + w / 2, z1), (cx - w / 2, z1)]


def hexagon(cx, cz, w, h):
    """A flattened hexagon cross-section, wide across x."""
    return [(cx + w / 2, cz), (cx + w / 4, cz + h / 2), (cx - w / 4, cz + h / 2),
            (cx - w / 2, cz), (cx - w / 4, cz - h / 2), (cx + w / 4, cz - h / 2)]


def diamond(cx, cz, w, h):
    return [(cx + w / 2, cz), (cx, cz + h / 2), (cx - w / 2, cz), (cx, cz - h / 2)]


class Build:
    """Parts as separate objects, each one material (one tile), all facets flat."""

    def __init__(self, name, tiles):
        self.name = name
        self.tiles = tiles
        self.materials = {}
        self.objects = []
        self.tile_world = TILE_WORLD   # a structure sets this higher: it is seen at true scale on the map

    def material(self, name):
        if name in self.materials:
            return self.materials[name]
        role, _, tile = name.partition(".")
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Roughness"].default_value = 0.9
        bsdf.inputs["Specular IOR Level"].default_value = 0.2 if "Specular IOR Level" in bsdf.inputs else 0.2
        tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
        tex.image = self.tiles.get(tile or "metal")
        tex.interpolation = "Closest"
        mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
        self.materials[name] = mat
        return mat

    def _finish(self, bm, material, label, transform=None, frame=None):
        """Tiles are mapped by projection. Without a `frame`, along the world axis nearest
        each face's normal, which suits anything axis-aligned and puts seams at the same
        world lines on every part. A `frame` (origin, along, across, over, scale) maps a
        member in its own axes instead (Ryan, 26 September: on a slanted arm the world
        seams cut diagonally across the plates), so panel lines run along and around the
        member; `scale` is (u, v) world units per tile, so a fist's face can carry exactly
        one tile of its own."""
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        if transform is not None:
            bmesh.ops.transform(bm, matrix=transform, verts=bm.verts)
        uv = bm.loops.layers.uv.verify()
        for f in bm.faces:
            f.smooth = False
            n = f.normal
            if frame is None:
                ax = max(range(3), key=lambda i: abs(n[i]))
                a, b = [i for i in range(3) if i != ax]
                for loop in f.loops:
                    co = loop.vert.co
                    loop[uv].uv = (co[a] / self.tile_world, co[b] / self.tile_world)
                continue
            origin, along, across, over, scale = frame
            su, sv = scale if scale is not None else (self.tile_world, self.tile_world)
            dots = [abs(n.dot(along)), abs(n.dot(across)), abs(n.dot(over))]
            if dots[0] >= dots[1] and dots[0] >= dots[2]:
                ua, va = across, over          # a cap: across and over
            elif dots[1] >= dots[2]:
                ua, va = over, along           # a side face: over and along the member
            else:
                ua, va = across, along         # a front or back face: across and along
            for loop in f.loops:
                rel = loop.vert.co - origin
                loop[uv].uv = (rel.dot(ua) / su, rel.dot(va) / sv)
        mesh = bpy.data.meshes.new(label)
        bm.to_mesh(mesh)
        bm.free()
        ob = bpy.data.objects.new(label, mesh)
        ob.data.materials.append(self.material(material))
        bpy.context.scene.collection.objects.link(ob)
        self.objects.append(ob)
        return ob

    def loft(self, sections, material, label="part", transform=None, cap=True):
        """Sections: [(y, [(x, z), ...]), ...] with the same point count, ordered along y."""
        bm = bmesh.new()
        rings = []
        for y, pts in sections:
            rings.append([bm.verts.new((x, y, z)) for x, z in pts])
        n = len(rings[0])
        for r0, r1 in zip(rings, rings[1:]):
            for i in range(n):
                quad = [r0[i], r0[(i + 1) % n], r1[(i + 1) % n], r1[i]]
                if len({v.co.to_tuple(3) for v in quad}) >= 3:
                    try:
                        bm.faces.new(quad)
                    except ValueError:
                        pass
        if cap:
            for ring in (rings[0], rings[-1]):
                if len({v.co.to_tuple(3) for v in ring}) >= 3:
                    try:
                        bm.faces.new(ring)
                    except ValueError:
                        pass
        return self._finish(bm, material, label, transform)

    def box(self, x0, x1, y0, y1, z0, z1, material, label="box", transform=None):
        return self.loft([(y0, rect((x0 + x1) / 2, x1 - x0, z0, z1)), (y1, rect((x0 + x1) / 2, x1 - x0, z0, z1))], material, label, transform)

    def prism(self, axis, cx, cy, cz, radius, length, material, sides=6, label="prism", phase=0.0):
        """A low-count cylinder along an axis: six sides is the register's barrel."""
        pts = []
        for i in range(sides):
            a = phase + i * 2.0 * math.pi / sides
            pts.append((radius * math.cos(a), radius * math.sin(a)))
        sections = [(-length / 2, pts), (length / 2, pts)]
        if axis == "y":
            m = Matrix.Translation((cx, cy, cz))
        elif axis == "x":
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(math.pi / 2, 4, "Z")
        else:
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(-math.pi / 2, 4, "X")
        return self.loft(sections, material, label, m)

    def pin(self, name, at, forward=(0.0, 1.0, 0.0), scale=1.0, parts=()):
        """A socket: an Empty named `hp_<n>` at `at`, its own +y along `forward` (where the
        weapon points) and its scale the size a mounted component wears there, so the
        engine can hang a component's shape under it with no arithmetic. `parts` are the
        stock component's objects: parented under the pin, keeping their world transform,
        so MechView3D.mount() hides them when another component is fitted."""
        e = bpy.data.objects.new(name, None)
        e.empty_display_size = 2.0
        m = Matrix.Translation(Vector(at)) @ pin_frame(forward).to_4x4() @ Matrix.Scale(scale, 4)
        e.matrix_world = m
        bpy.context.scene.collection.objects.link(e)
        inv = m.inverted()
        for ob in parts:
            ob.parent = e
            ob.matrix_parent_inverse = inv
        return e

    def socket(self, name, at, forward=(0.0, 1.0, 0.0), scale=1.0):
        """`with b.socket("hp_1", at, forward): ...` builds the stock component inside the
        block and pins it: every object made in the block hangs under the pin."""
        return _Socket(self, name, at, forward, scale)

    def pad(self, name, at, forward=(0.0, 1.0, 0.0), scale=1.0, size=(8.0, 3.0), material="steel.panel"):
        """A bare gun mount: a hardpoint whose stock loadout puts nothing there (the rule,
        30 September: armour and vents show nowhere, so a machine with more hardpoints than
        stock guns carries empty mounts). A low block at the socket so a fitted gun sits on
        something, and the pin with no stock part under it. `size` is (across, thick) in
        world units, the block lying under the pin along its forward."""
        w, t = size
        m = Matrix.Translation(Vector(at)) @ pin_frame(forward).to_4x4()
        start = len(self.objects)
        self.box(-w / 2.0, w / 2.0, -w / 2.0, w / 2.0, -t, 0.0, material, "pad")
        for ob in self.objects[start:]:
            ob.matrix_world = m
        return self.pin(name, at, forward, scale)

    def stock(self, name, at, shape, forward=(0.0, 1.0, 0.0), scale=1.0):
        """A pin whose stock component is one of the silhouette classes (models_low.SHAPES),
        built at the origin along +y and moved onto the pin's frame at its scale: the way a
        swapped component will sit there, so the machine is judged wearing one."""
        import models_low
        start = len(self.objects)
        models_low.SHAPES[shape](self, 1.0)
        m = Matrix.Translation(Vector(at)) @ pin_frame(forward).to_4x4() @ Matrix.Scale(scale, 4)
        parts = self.objects[start:]
        for ob in parts:
            ob.matrix_world = m
        return self.pin(name, at, forward, scale, parts)


class _Socket:
    def __init__(self, b, name, at, forward, scale):
        self.b, self.name, self.at, self.forward, self.scale = b, name, at, forward, scale

    def __enter__(self):
        self.start = len(self.b.objects)
        return self

    def __exit__(self, *exc):
        if exc[0] is None:
            self.b.pin(self.name, self.at, self.forward, self.scale, self.b.objects[self.start:])
        return False


def pin_frame(forward):
    """The rotation that turns +y onto `forward`, keeping +z as up where it can (a pin
    pointing straight up or down takes -y or +y as its up, so a rack firing upward wears
    its top toward the tail)."""
    f = Vector(forward).normalized()
    hint = Vector((0.0, 0.0, 1.0))
    if abs(f.dot(hint)) > 0.999:
        hint = Vector((0.0, -1.0, 0.0)) if f.z > 0 else Vector((0.0, 1.0, 0.0))
    z = (hint - f * hint.dot(f)).normalized()
    x = f.cross(z).normalized()
    return Matrix(((x.x, f.x, z.x), (x.y, f.y, z.y), (x.z, f.z, z.z)))


def boom(b, start, length, pitch_deg, yaw_deg, w0, h0, w1, h1, material, label):
    """An excavator-boom segment: a tapered box from `start`, pitched down and yawed, along
    its own y. Returns the far end in world space."""
    sections = [(0.0, rect(0.0, w0, -h0 / 2, h0 / 2)), (length, rect(0.0, w1, -h1 / 2, h1 / 2))]
    rot = Matrix.Rotation(math.radians(yaw_deg), 4, "Z") @ Matrix.Rotation(math.radians(-pitch_deg), 4, "X")
    m = Matrix.Translation(Vector(start)) @ rot
    b.loft(sections, material, label, m)
    end = m @ Vector((0.0, length, 0.0))
    return (end.x, end.y, end.z), rot


# ---------------------------------------------------------------- main

def terrain_tiles(out_dir, seed=11):
    """The battlefield's materials, in the same register as the units: dirt, gravel,
    rubble, cracked concrete, water and rock, 64 px each, written as PNGs for Godot."""
    rng = np.random.default_rng(seed)
    os.makedirs(out_dir, exist_ok=True)

    def base(col, mottle, streak=0.0):
        img = np.tile(np.array(col, np.float32), (TILE, TILE, 1))
        img += rng.uniform(-mottle, mottle, size=(TILE, TILE, 1)).astype(np.float32)
        if streak > 0.0:
            img += rng.uniform(-streak, streak, size=(TILE, 1, 1)).astype(np.float32)
        return img

    def specks(img, n, size, k_lo, k_hi):
        for _ in range(n):
            y, x = rng.integers(0, TILE - size, 2)
            img[y:y + size, x:x + size, :] *= rng.uniform(k_lo, k_hi)
        return img

    tiles = {}
    tiles["dirt"] = specks(base((0.36, 0.33, 0.27), 0.03), 40, 2, 0.75, 1.2)
    tiles["gravel"] = specks(specks(base((0.40, 0.40, 0.37), 0.03), 50, 3, 0.6, 0.85), 30, 2, 1.15, 1.35)
    # Scrub: broken ground with dark tufts and bushes, the 3D face of what the other world
    # paints as forest.
    scrub = base((0.33, 0.32, 0.24), 0.03)
    for _ in range(18):
        y, x = rng.integers(0, TILE - 5, 2)
        w, h = rng.integers(3, 6, 2)
        scrub[y:y + h, x:x + w, :] = np.array([0.20, 0.30, 0.16], np.float32) * rng.uniform(0.8, 1.15)
        scrub[y:y + 1, x:x + w, :] = np.array([0.30, 0.42, 0.22], np.float32)
    tiles["scrub"] = specks(scrub, 20, 2, 0.8, 1.15)
    rubble = base((0.27, 0.28, 0.30), 0.03)
    for _ in range(9):
        y, x = rng.integers(2, TILE - 12, 2)
        w, h = rng.integers(5, 12, 2)
        rubble[y:y + h, x:x + w, :] *= 0.72
        rubble[y:y + 2, x:x + w, :] *= 1.45
    tiles["rubble"] = rubble
    # A road of the future: near-black deck plate with faint seams, a worn pale guide line
    # and a row of guide lamps, most of them dead (Ryan, 21 September).
    concrete = base((0.11, 0.12, 0.13), 0.01, 0.008)
    concrete[0:1, :, :] *= 1.6
    concrete[:, 0:1, :] *= 1.6
    concrete[31:32, :, :] *= 1.4
    concrete[:, 31:32, :] *= 1.4
    concrete[30:32, :, :] = np.array([0.30, 0.32, 0.30], np.float32)
    for x in range(4, TILE, 16):
        lit = rng.random() < 0.35
        concrete[14:17, x:x + 3, :] = np.array([1.0, 0.75, 0.30], np.float32) if lit else np.array([0.20, 0.16, 0.10], np.float32)
        concrete[46:49, x + 8:x + 11, :] = np.array([1.0, 0.75, 0.30], np.float32) if rng.random() < 0.35 else np.array([0.20, 0.16, 0.10], np.float32)
    tiles["concrete"] = concrete
    # Roads are drawn in the engine (road.gdshader) so they join; the concrete tile above
    # is their shoulder.
    tiles["concrete"] = specks(base((0.36, 0.36, 0.35), 0.02), 20, 2, 0.85, 1.1)
    water = base((0.13, 0.24, 0.40), 0.015, 0.03)
    for _ in range(8):
        y, x = rng.integers(0, TILE, 2)
        w = rng.integers(8, 20)
        for i in range(w):
            water[y, (x + i) % TILE, :] = np.minimum(water[y, (x + i) % TILE, :] * 1.5, 1.0)
    tiles["water"] = water
    rock = base((0.30, 0.29, 0.31), 0.03, 0.07)
    for y in range(0, TILE, rng.integers(5, 9)):
        rock[y:y + 1, :, :] *= 0.6
    tiles["rock"] = specks(rock, 20, 2, 0.8, 1.25)
    tiles["crag"] = np.minimum(tiles["rock"] * 1.25, 1.0)
    for name, img in tiles.items():
        image = bpy.data.images.new("terrain_" + name, TILE, TILE, alpha=True)
        rgba = np.ones((TILE, TILE, 4), np.float32)
        rgba[..., :3] = np.clip(img, 0.0, 1.0)
        image.pixels = rgba.ravel().tolist()
        image.filepath_raw = os.path.join(out_dir, name + ".png")
        image.file_format = "PNG"
        image.save()
    print(f"lowforge: terrain tiles -> {out_dir}: {', '.join(tiles)}")


def _export(out):
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", export_apply=True, export_yup=True,
                              export_image_format="AUTO", use_selection=True)


def main():
    a = _args()
    if "terrain" in a:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        terrain_tiles(a["terrain"])
        return
    if "shapes" in a:
        # The silhouette classes (decided 29 September), one file a class a maker, so a
        # swapped component wears its own maker's metal: art/models/shapes/<shape>_<maker>.glb.
        import models_low
        for maker in MAKERS:
            for shape, fn in models_low.SHAPES.items():
                bpy.ops.wm.read_factory_settings(use_empty=True)
                tiles = Tiles(a.get("tiles", os.path.join(HERE, "tiles")), maker)
                builder = Build("%s_%s" % (shape, maker), tiles)
                fn(builder, 1.0)
                _export(os.path.join(a["shapes"], "%s_%s.glb" % (shape, maker)))
        print(f"lowforge: {len(MAKERS) * len(models_low.SHAPES)} shapes -> {a['shapes']}")
        return
    out = a["out"]
    if "blend" in a and "model" not in a:
        # Export a hand-edited working file as it is: joints (joint_*) and pins (hp_*) are
        # Empties and come through as nodes, materials keep their "<role>.<tile>" names.
        bpy.ops.wm.open_mainfile(filepath=a["blend"])
        _export(out)
        meshes = [ob for ob in bpy.data.objects if ob.type == "MESH"]
        tris = sum(sum(len(p.vertices) - 2 for p in ob.data.polygons) for ob in meshes)
        print(f"lowforge: {a['blend']} -> {out}, {len(meshes)} parts, {tris} triangles")
        return
    bpy.ops.wm.read_factory_settings(use_empty=True)
    import models_low
    fn = getattr(models_low, a["model"])
    tiles = Tiles(a.get("tiles", os.path.join(HERE, "tiles")), getattr(fn, "maker", "minerva"))
    builder = Build(a["model"], tiles)
    fn(builder)
    _export(out)
    if "blend" in a:
        # The working file for hand edits in Blender, tiles packed inside. A rebuild from
        # code overwrites it: save a hand-edited copy under another name.
        os.makedirs(os.path.dirname(a["blend"]) or ".", exist_ok=True)
        bpy.ops.file.pack_all()
        bpy.ops.wm.save_as_mainfile(filepath=a["blend"])
    tris = sum(sum(len(p.vertices) - 2 for p in ob.data.polygons) for ob in builder.objects)
    print(f"lowforge: {a['model']} -> {out}, {len(builder.objects)} parts, {tris} triangles, {len(tiles.images)} tiles")


if __name__ == "__main__":
    main()

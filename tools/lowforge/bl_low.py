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
    "minerva": {"grey": 0.36, "streak": 0.12, "mottle": 0.05, "tint": (0.84, 0.92, 0.80), "livery": (0.42, 0.50, 0.28), "rivets": 12},
    "kestrel": {"grey": 0.70, "streak": 0.04, "mottle": 0.012, "tint": (0.92, 0.95, 1.0), "livery": (0.16, 0.40, 0.88), "rivets": 0},
    "wainwright_sutler": {"grey": 0.42, "streak": 0.10, "mottle": 0.07, "tint": (1.0, 0.86, 0.72), "livery": (0.58, 0.30, 0.14), "rivets": 8},
    "aphelion": {"grey": 0.80, "streak": 0.02, "mottle": 0.01, "tint": (1.0, 1.0, 1.0), "livery": (0.86, 0.12, 0.12), "rivets": 0},
    "arsenal": {"grey": 0.26, "streak": 0.08, "mottle": 0.03, "tint": (0.88, 0.90, 0.96), "livery": (0.36, 0.38, 0.42), "rivets": 16},
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

    def metal(self, grey=None, streak=None, tint=(1.0, 1.0, 1.0), mottle=None):
        p = self.p
        grey = p["grey"] if grey is None else grey
        streak = p["streak"] if streak is None else streak
        mottle = p["mottle"] if mottle is None else mottle
        rows = self.rng.uniform(-streak, streak, size=(TILE, 1, 1)).astype(np.float32)
        noise = self.rng.uniform(-mottle, mottle, size=(TILE, TILE, 1)).astype(np.float32)
        smear = np.zeros_like(noise)
        for i in range(7):
            smear += np.roll(noise, i, axis=1)
        img = np.full((TILE, TILE, 3), grey, np.float32) + rows + smear
        cast = np.array(p["tint"], np.float32) * np.array(tint, np.float32)
        return np.clip(img * cast, 0.0, 1.0)

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
        elif kind == "light":
            img = self.metal(0.25, 0.04)
            img[14:50, 10:54, :] = np.array([1.0, 0.92, 0.62], np.float32)
            img[18:46, 14:50, :] = np.array([1.0, 0.98, 0.85], np.float32)
        elif kind == "glass":
            img = np.zeros((TILE, TILE, 3), np.float32)
            for y in range(TILE):
                for x in range(TILE):
                    t = (x + y) / (2.0 * TILE)
                    img[y, x, :] = np.array([0.10 + 0.25 * t, 0.30 + 0.35 * t, 0.42 + 0.45 * t], np.float32)
            img[:, :, :] *= 0.85
            for d in range(-4, 4):
                for y in range(TILE):
                    x = (TILE - y + d) % TILE
                    img[y, x, :] = np.minimum(img[y, x, :] * 1.6, 1.0)
        elif kind == "tread":
            img = self.metal(0.24, 0.02, mottle=0.01)
            for x in range(0, TILE, 8):
                img[:, x:x + 3, :] *= 0.3
                img[:, x + 3:x + 5, :] = np.minimum(img[:, x + 3:x + 5, :] * 1.7, 1.0)
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
            img = self._seam(self.metal(0.74, self.p["streak"] * 0.5, tint=(0.96, 0.93, 0.85)))
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

    def _finish(self, bm, material, label, transform=None):
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        if transform is not None:
            bmesh.ops.transform(bm, matrix=transform, verts=bm.verts)
        uv = bm.loops.layers.uv.verify()
        for f in bm.faces:
            f.smooth = False
            n = f.normal
            ax = max(range(3), key=lambda i: abs(n[i]))
            a, b = [i for i in range(3) if i != ax]
            for loop in f.loops:
                co = loop.vert.co
                loop[uv].uv = (co[a] / TILE_WORLD, co[b] / TILE_WORLD)
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

    def pin(self, name, at, forward=(0.0, 1.0, 0.0)):
        e = bpy.data.objects.new(name, None)
        e.empty_display_size = 2.0
        e.location = at
        bpy.context.scene.collection.objects.link(e)
        return e


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

def main():
    a = _args()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    import models_low
    fn = getattr(models_low, a["model"])
    tiles = Tiles(a.get("tiles", os.path.join(HERE, "tiles")), getattr(fn, "maker", "minerva"))
    builder = Build(a["model"], tiles)
    fn(builder)
    out = a["out"]
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", export_apply=True, export_yup=True,
                              export_image_format="AUTO", use_selection=True)
    tris = sum(sum(len(p.vertices) - 2 for p in ob.data.polygons) for ob in builder.objects)
    print(f"lowforge: {a['model']} -> {out}, {len(builder.objects)} parts, {tris} triangles, {len(tiles.images)} tiles")


if __name__ == "__main__":
    main()

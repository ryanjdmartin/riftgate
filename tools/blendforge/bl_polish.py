"""Runs inside Blender. The polish pass: takes a massing model (boxes and cylinders with role
materials) and adds the finish a modeller would, by rule, so Ryan's job stays massing.

    Blender -b in.blend -P bl_polish.py -- --out out.blend

Rules, by what a part is:
  plates (boxes)         bevelled edges so every edge catches a highlight band
  big plate faces        a recessed panel inset, and a rivet at each corner
  tracks (rubber boxes)  rounded ends, cleats along the top and outer face, road wheels
  cylinders              chamfered caps
Everything added is named with ".detail" where it should drop from the 24 px map token.
The file is written to a new path; the massing file is never touched.
"""

import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Vector

PLATE_ROLES = {"steel", "steel_dark", "livery", "white"}
PANEL_MIN_AREA = 60.0        # faces bigger than this get a recessed panel and rivets
RIVET_INSET = 1.4


def args():
    argv = sys.argv[sys.argv.index("--") + 1:]
    return {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv), 2)}


def role_of(obj):
    if not obj.data.materials or obj.data.materials[0] is None:
        return "steel"
    return obj.data.materials[0].name.split(".")[0].lower()


def material(name):
    for m in bpy.data.materials:
        if m.name.split(".")[0].lower() == name:
            return m
    m = bpy.data.materials.new(name)
    return m


def world_bbox(obj):
    # From the vertices, not obj.bound_box: the cached box is stale right after a
    # transform apply and put every cleat and wheel in the wrong place.
    pts = [obj.matrix_world @ v.co for v in obj.data.vertices]
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    return lo, hi


def apply_transforms(objs):
    # Parts in a collection excluded from the view layer cannot be selected; link them to
    # the scene root so the operators can reach them (the renderer draws them anyway).
    vl = bpy.context.view_layer
    for o in objs:
        if o.name not in vl.objects:
            bpy.context.scene.collection.objects.link(o)
        o.hide_set(False)
        o.hide_viewport = False
    # Bake the author's own modifiers (an Array of bolt holes, say) as they stand, before
    # any transform is applied: a node modifier re-evaluated against a changed scale can
    # scatter its copies across the scene.
    for o in objs:
        if o.data.users > 1:
            o.data = o.data.copy()
        for m in list(o.modifiers):
            bpy.context.view_layer.objects.active = o
            try:
                bpy.ops.object.modifier_apply(modifier=m.name)
            except Exception as e:
                print("blendforge: could not apply", o.name, m.name, e)
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    bpy.context.view_layer.update()
    # A mirrored copy (scale -1) has its normals flipped once the scale is applied.
    for o in objs:
        bm = bmesh.new()
        bm.from_mesh(o.data)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        bm.to_mesh(o.data)
        bm.free()


def add_box(name, lo, hi, mat, detail=True):
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    o = bpy.context.object
    o.location = [(lo[k] + hi[k]) / 2.0 for k in range(3)]
    o.scale = [max(hi[k] - lo[k], 1e-3) for k in range(3)]
    o.name = name + (".detail" if detail else "")
    o.data.materials.append(mat)
    bpy.ops.object.transform_apply(scale=True)
    return o


def add_cyl(name, axis, centre, radius, length, mat, detail=True, verts=16):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=length, location=centre)
    o = bpy.context.object
    if axis == "x":
        o.rotation_euler = (0.0, math.radians(90.0), 0.0)
    elif axis == "y":
        o.rotation_euler = (math.radians(90.0), 0.0, 0.0)
    o.name = name + (".detail" if detail else "")
    o.data.materials.append(mat)
    bpy.ops.object.transform_apply(rotation=True)
    return o


def bevel_modifier(obj, width, segments, angle=30.0):
    m = obj.modifiers.new("polish_bevel", "BEVEL")
    m.width = width
    m.segments = segments
    m.limit_method = "ANGLE"
    m.angle_limit = math.radians(angle)
    m.harden_normals = False


def is_box(obj):
    return len(obj.data.polygons) == 6


def is_cylinder(obj):
    n = len(obj.data.polygons)
    return n >= 10 and n != 6


# ---------------------------------------------------------------- plates

def polish_plate(obj):
    lo, hi = world_bbox(obj)
    dims = hi - lo
    smallest = min(dims.x, dims.y, dims.z)
    width = max(0.3, min(0.7, smallest * 0.12))
    role = role_of(obj)
    # Recessed panels and rivets on the big faces, before the bevel so the bevel also
    # softens the panel's own edge.
    big_faces = []
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.faces.ensure_lookup_table()
    bm.normal_update()
    for f in bm.faces:
        if f.calc_area() >= PANEL_MIN_AREA:
            big_faces.append(f)
    rivets = []
    if big_faces and role in ("livery", "steel"):
        for f in big_faces:
            n = f.normal.copy()
            centre = obj.matrix_world @ f.calc_center_median()
            # corners for rivets: pull each vertex toward the centre by RIVET_INSET
            for v in f.verts:
                p = obj.matrix_world @ v.co
                d = (centre - p)
                if d.length > 2.0 * RIVET_INSET:
                    rivets.append((p + d.normalized() * RIVET_INSET, n))
        res = bmesh.ops.inset_individual(bm, faces=big_faces, thickness=0.8, depth=-0.25, use_even_offset=True)
    bm.to_mesh(obj.data)
    bm.free()
    for i, (p, n) in enumerate(rivets):
        axis = "x" if abs(n.x) > 0.9 else ("y" if abs(n.y) > 0.9 else "z")
        c = p + n * 0.2
        add_cyl(f"rivet_{obj.name}_{i}", axis, c, 0.5, 0.7, material("steel_dark"), verts=8)
    bevel_modifier(obj, width, 2)


# ---------------------------------------------------------------- tracks

def polish_track(obj):
    lo, hi = world_bbox(obj)
    dims = hi - lo
    height = dims.z
    outer = 1.0 if (lo.x + hi.x) * 0.5 > 0 else -1.0     # which side faces out
    # Round the ends: the four edges parallel to x get a wide bevel, so the run reads as a
    # loop around the sprockets instead of a brick.
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    x_edges = [e for e in bm.edges if abs((e.verts[0].co - e.verts[1].co).normalized().x) > 0.9]
    bmesh.ops.bevel(bm, geom=x_edges, offset=height * 0.42, segments=4, affect="EDGES", profile=0.5)
    bm.to_mesh(obj.data)
    bm.free()
    obj.data.materials[0] = material("tread")
    # Cleats: thin bars across the top and down the outer face, every three units.
    dark = material("steel_dark")
    n = int(dims.y // 3.0)
    start = lo.y + (dims.y - (n - 1) * 3.0) * 0.5
    for i in range(n):
        y = start + i * 3.0
        if abs(y - lo.y) < height * 0.4 or abs(hi.y - y) < height * 0.4:
            continue     # not on the rounded ends
        # Nothing thinner than a unit: at the sprite's scale a unit is about a pixel, and a
        # part thinner than that survives the downsample only as stray dots.
        add_box(f"cleat_top_{obj.name}_{i}", (lo.x + 0.4, y - 0.6, hi.z - 0.3), (hi.x - 0.4, y + 0.6, hi.z + 0.7), dark)
        xo = hi.x if outer > 0 else lo.x
        add_box(f"cleat_side_{obj.name}_{i}", (min(xo - outer * 0.3, xo + outer * 0.8), y - 0.6, lo.z + height * 0.25),
                (max(xo - outer * 0.3, xo + outer * 0.8), y + 0.6, hi.z - height * 0.25), dark)
    # Road wheels on the outer face, between the sprockets, sunk half into the run.
    cy = (lo.y + hi.y) * 0.5
    cz = lo.z + height * 0.5
    xo = (hi.x if outer > 0 else lo.x) + outer * 0.4
    for k in (-1, 0, 1):
        add_cyl(f"roadwheel_{obj.name}_{k + 1}", "x", (xo, cy + k * dims.y * 0.24, cz), height * 0.32, 1.6, dark, verts=12)


# ---------------------------------------------------------------- main

def main():
    a = args()
    out = Path(a["out"])
    objs = [o for o in bpy.data.objects if o.type == "MESH"]
    apply_transforms(objs)
    counts = {"plates": 0, "tracks": 0, "cylinders": 0, "left": 0}
    for o in list(objs):
        role = role_of(o)
        if role == "rubber" and is_box(o):
            polish_track(o)
            counts["tracks"] += 1
        elif role in PLATE_ROLES and is_box(o):
            polish_plate(o)
            counts["plates"] += 1
        elif is_cylinder(o) and role != "glass":
            bevel_modifier(o, 0.25, 1, angle=60.0)
            counts["cylinders"] += 1
        else:
            counts["left"] += 1
    # Everything stays flat-shaded. Smoothing by angle bleeds the bevel bands into the big
    # plates and turns a flat panel into a gradient, which the toon shader then bands.
    # Two-segment bevels give three flat facets per edge, which is the highlight we want.
    out.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(out), compress=True)
    print("blendforge: polished", counts, "->", out)


main()

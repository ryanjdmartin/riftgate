"""Runs inside Blender. The polish pass: takes a massing model (boxes and cylinders with role
materials) and adds the finish a modeller would, by rule, so Ryan's job stays massing.

    Blender -b in.blend -P bl_polish.py -- --out out.blend --profile '{...}'

The profile (tools/blendforge/profiles.py) carries the maker's manner and the chassis's kit,
so a Minerva machine comes out bolted and chamfered and a Kestrel airframe comes out flush.

Rules, by what a part is:
  plates (boxes)         chamfered or rounded edges, per the maker
  big plate faces        a recessed panel and a bolt at each corner (corners only, never rows)
  the hull (biggest box) rim bars along its top edges, a vent block on its rear deck
  arms (parts that reach past the hull)  a hydraulic ram back to the hull
  stacks (vertical cylinders above the hull)  a collar ring and an open cap
  tracks (rubber boxes)  rounded ends, cleats, road wheels; the run becomes `tread`
  cylinders              chamfered caps
Chassis kit: work_lights (amber lamps on the cab roof), tow_lugs (lugs on the hull's rear).
Everything added is named with ".detail" where it should drop from the 24 px map token.
The active scene only; the file is written to a new path and the massing file never touched.
"""

import json
import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Vector

PLATE_ROLES = {"steel", "steel_dark", "livery", "white"}
PANEL_MIN_AREA = 60.0        # faces bigger than this get a recessed panel and bolts
RIVET_INSET = 1.4
P = {}                       # the profile, set in main


def args():
    argv = sys.argv[sys.argv.index("--") + 1:]
    return {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv), 2)}


def kp(x):
    return x * P["plate_strength"]


def kt(x):
    return x * P["track_strength"]


def role_of(obj):
    if not obj.data.materials or obj.data.materials[0] is None:
        return "steel"
    return obj.data.materials[0].name.split(".")[0].lower()


def material(name):
    for m in bpy.data.materials:
        if m.name.split(".")[0].lower() == name:
            return m
    return bpy.data.materials.new(name)


def world_bbox(obj):
    # From the vertices, not obj.bound_box: the cached box is stale right after a transform
    # apply and put every cleat and wheel in the wrong place.
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
    o.location = [(lo[i] + hi[i]) / 2.0 for i in range(3)]
    o.scale = [max(hi[i] - lo[i], 1e-3) for i in range(3)]
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


def add_rod(name, a, b, radius, mat, verts=10):
    """A cylinder from point a to point b: a piston, a strut."""
    a, b = Vector(a), Vector(b)
    d = b - a
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=max(d.length, 1e-3), location=(a + b) / 2.0)
    o = bpy.context.object
    o.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
    o.name = name + ".detail"
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
    width = max(kp(0.3), min(kp(0.7), smallest * 0.12 * P["plate_strength"]))
    role = role_of(obj)
    # Recessed panels and bolts on the big faces, before the bevel so the bevel also
    # softens the panel's own edge. Bolts at corners only: rows of rivets read as a toy.
    big_faces = []
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.faces.ensure_lookup_table()
    bm.normal_update()
    for f in bm.faces:
        if f.calc_area() >= PANEL_MIN_AREA:
            big_faces.append(f)
    bolts = []
    if big_faces and role in ("livery", "steel"):
        for f in big_faces:
            n = f.normal.copy()
            centre = obj.matrix_world @ f.calc_center_median()
            for v in f.verts:
                p = obj.matrix_world @ v.co
                d = (centre - p)
                if d.length > 2.0 * kp(RIVET_INSET):
                    bolts.append((p + d.normalized() * kp(RIVET_INSET), n))
        bmesh.ops.inset_individual(bm, faces=big_faces, thickness=kp(0.8), depth=-kp(0.25), use_even_offset=True)
    bm.to_mesh(obj.data)
    bm.free()
    r = 0.5 * P["rivet_scale"]
    if r > 0.0:
        for i, (p, n) in enumerate(bolts):
            axis = "x" if abs(n.x) > 0.9 else ("y" if abs(n.y) > 0.9 else "z")
            add_cyl(f"bolt_{obj.name}_{i}", axis, p + n * kp(0.2), kp(r), kp(0.7), material("steel_dark"), verts=6)
    bevel_modifier(obj, width, int(P["bevel_segments"]))


# ---------------------------------------------------------------- the hull and what hangs off it

def hull_of(plates):
    """The biggest box is the hull; everything else is placed relative to it."""
    best, vol = None, 0.0
    for o in plates:
        lo, hi = world_bbox(o)
        d = hi - lo
        if d.x * d.y * d.z > vol:
            best, vol = o, d.x * d.y * d.z
    return best


def rims(hull):
    """Raised bars along the hull's top front and rear edges: bumpers, the brick-house tell."""
    lo, hi = world_bbox(hull)
    t = kp(0.6)
    dark = material("steel_dark")
    for name, y0, y1 in (("rim_front", hi.y - t, hi.y + t * 0.5), ("rim_rear", lo.y - t * 0.5, lo.y + t)):
        add_box(f"{name}_{hull.name}", (lo.x - t * 0.3, y0, hi.z - t * 0.6), (hi.x + t * 0.3, y1, hi.z + t * 0.9), dark)


def vent(hull):
    """A radiator grille sunk into the rear third of the hull's top deck."""
    lo, hi = world_bbox(hull)
    dims = hi - lo
    w = dims.x * 0.6
    d = max(dims.y * 0.18, 3.0)
    x0 = (lo.x + hi.x) / 2.0 - w / 2.0
    y0 = lo.y + dims.y * 0.08
    frame = material("steel_dark")
    add_box(f"vent_frame_{hull.name}", (x0, y0, hi.z - 0.2), (x0 + w, y0 + d, hi.z + kp(0.35)), frame)
    slats = max(3, int(w // 3.0))
    for i in range(slats):
        sx = x0 + (i + 0.5) * w / slats
        add_box(f"vent_slat_{hull.name}_{i}", (sx - 0.35, y0 + 0.4, hi.z + kp(0.35)), (sx + 0.35, y0 + d - 0.4, hi.z + kp(0.35) + 0.3), material("bore"))


def pistons(hull, plates):
    """A ram from any part that reaches past the hull's flanks back to the hull's top edge."""
    hlo, hhi = world_bbox(hull)
    dark = material("steel_dark")
    n = 0
    for o in plates:
        if o is hull:
            continue
        lo, hi = world_bbox(o)
        dims = hi - lo
        reach = max(hlo.x - lo.x, hi.x - hhi.x)
        if reach < 5.0 or max(dims.x, dims.y) < 2.0 * dims.z * 0.5:
            continue
        side = 1.0 if hi.x > hhi.x else -1.0
        inner_x = lo.x if side > 0 else hi.x
        a = (inner_x + side * dims.x * 0.35, (lo.y + hi.y) / 2.0, hi.z - dims.z * 0.2)
        b = (hhi.x if side > 0 else hlo.x, (lo.y + hi.y) / 2.0, hhi.z + kp(0.8))
        add_rod(f"ram_{o.name}", b, a, kp(0.5), dark)
        add_rod(f"ram_rod_{o.name}", (Vector(a) + Vector(b)) / 2.0, a, kp(0.3), material("steel"))
        n += 1
    return n


def collars(cylinders, hull):
    """A ring and an open cap on any vertical cylinder standing above the hull: stacks."""
    hlo, hhi = world_bbox(hull)
    n = 0
    for o in cylinders:
        lo, hi = world_bbox(o)
        d = hi - lo
        # A stack is tall, round in section, and stands above the hull: a tall thin claw
        # plate is none of those, however many polygons it has.
        if d.z < 1.3 * max(d.x, d.y) or hi.z < hhi.z + 2.0 or min(d.x, d.y) < 0.75 * max(d.x, d.y) or len(o.data.polygons) < 16:
            continue
        r = max(d.x, d.y) / 2.0
        c = ((lo.x + hi.x) / 2.0, (lo.y + hi.y) / 2.0, lo.z + d.z * 0.72)
        add_cyl(f"collar_{o.name}", "z", c, r * 1.25, kp(0.9), material("steel_dark"))
        add_cyl(f"cap_{o.name}", "z", ((lo.x + hi.x) / 2.0, (lo.y + hi.y) / 2.0, hi.z + 0.1), r * 0.8, 0.3, material("bore"))
        n += 1
    return n


# ---------------------------------------------------------------- tracks

def polish_track(obj):
    lo, hi = world_bbox(obj)
    dims = hi - lo
    height = dims.z
    outer = 1.0 if (lo.x + hi.x) * 0.5 > 0 else -1.0     # which side faces out
    # Round the ends so the run reads as a loop around the sprockets instead of a brick.
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    x_edges = [e for e in bm.edges if abs((e.verts[0].co - e.verts[1].co).normalized().x) > 0.9]
    bmesh.ops.bevel(bm, geom=x_edges, offset=height * 0.42, segments=4, affect="EDGES", profile=0.5)
    bm.to_mesh(obj.data)
    bm.free()
    obj.data.materials[0] = material("tread")
    dark = material("steel_dark")
    spacing = float(P["cleat_spacing"])
    n = int(dims.y // spacing)
    start = lo.y + (dims.y - (n - 1) * spacing) * 0.5
    for i in range(n):
        y = start + i * spacing
        if abs(y - lo.y) < height * 0.4 or abs(hi.y - y) < height * 0.4:
            continue     # not on the rounded ends
        # Nothing thinner than a unit: at the sprite's scale a unit is about a pixel.
        add_box(f"cleat_top_{obj.name}_{i}", (lo.x + 0.4, y - kt(0.6), hi.z - 0.3), (hi.x - 0.4, y + kt(0.6), hi.z + kt(0.7)), dark)
        xo = hi.x if outer > 0 else lo.x
        add_box(f"cleat_side_{obj.name}_{i}", (min(xo - outer * 0.3, xo + outer * kt(0.8)), y - kt(0.6), lo.z + height * 0.25),
                (max(xo - outer * 0.3, xo + outer * kt(0.8)), y + kt(0.6), hi.z - height * 0.25), dark)
    # Road wheels on the outer face, between the sprockets, sunk half into the run.
    cy = (lo.y + hi.y) * 0.5
    cz = lo.z + height * 0.5
    xo = (hi.x if outer > 0 else lo.x) + outer * kt(0.4)
    wheels = int(P["wheels"])
    for j in range(wheels):
        off = (j - (wheels - 1) / 2.0) * dims.y * (0.48 / max(1, wheels - 1)) if wheels > 1 else 0.0
        add_cyl(f"roadwheel_{obj.name}_{j}", "x", (xo, cy + off, cz), height * 0.32, kt(1.6), dark, verts=12)


# ---------------------------------------------------------------- chassis kit

def kit_work_lights(plates, glass):
    """Two amber lamps on the roof of the cab, the plate that carries the glass."""
    if glass is None:
        return 0
    glo, ghi = world_bbox(glass)
    # The cab is whatever holds the glass: spans it in x and z, and is the front-most such part.
    cab, best = None, -1e9
    for o in plates:
        lo, hi = world_bbox(o)
        if lo.x <= (glo.x + ghi.x) / 2.0 <= hi.x and hi.z >= ghi.z - 0.5 and lo.z <= glo.z + 0.5 and hi.y > best:
            cab, best = o, hi.y
    if cab is None:
        return 0
    lo, hi = world_bbox(cab)
    amber = material("amber")
    dark = material("steel_dark")
    s = kp(0.6)
    for sx in (lo.x + s * 1.5, hi.x - s * 1.5):
        add_box(f"lamp_house_{cab.name}_{sx:.0f}", (sx - s, hi.y - s * 1.6, hi.z), (sx + s, hi.y + s * 0.2, hi.z + s * 1.4), dark)
        add_box(f"lamp_{cab.name}_{sx:.0f}", (sx - s * 0.8, hi.y + s * 0.2, hi.z + s * 0.2), (sx + s * 0.8, hi.y + s * 0.5, hi.z + s * 1.2), amber)
    return 2


def kit_tow_lugs(hull):
    """Two tow lugs low on the hull's rear face: the mining heritage nobody removed."""
    lo, hi = world_bbox(hull)
    dark = material("steel_dark")
    s = kp(0.7)
    z0 = lo.z + (hi.z - lo.z) * 0.25
    for sx in (lo.x + (hi.x - lo.x) * 0.22, hi.x - (hi.x - lo.x) * 0.22):
        add_box(f"lug_{hull.name}_{sx:.0f}", (sx - s, lo.y - s * 1.6, z0), (sx + s, lo.y + 0.2, z0 + s * 1.8), dark)
        add_cyl(f"lug_eye_{hull.name}_{sx:.0f}", "x", (sx, lo.y - s * 0.9, z0 + s * 0.9), s * 0.4, s * 2.2, material("bore"), verts=8)
    return 2


# ---------------------------------------------------------------- main

def main():
    global P
    a = args()
    out = Path(a["out"])
    P = json.loads(a.get("profile", "{}"))
    for key, default in (("plate_strength", 1.0), ("track_strength", 1.0), ("bevel_segments", 2), ("cleat_spacing", 3.0),
                         ("wheels", 3), ("rivet_scale", 1.0), ("rims", False), ("vents", False), ("pistons", False),
                         ("collars", False), ("kit", [])):
        P.setdefault(key, default)
    # The active scene only: a file can hold a scratch scene of parts borrowed from an
    # archetype, and those must not ride along (a tank gun once did).
    objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    apply_transforms(objs)
    plates = [o for o in objs if role_of(o) in PLATE_ROLES and is_box(o)]
    tracks = [o for o in objs if role_of(o) == "rubber" and is_box(o)]
    cylinders = [o for o in objs if is_cylinder(o) and role_of(o) != "glass"]
    glass = next((o for o in objs if role_of(o) == "glass"), None)
    hull = hull_of(plates)
    counts = {"plates": len(plates), "tracks": len(tracks), "cylinders": len(cylinders)}
    # Placement rules first, while the plates are still plain boxes.
    if hull is not None:
        if P["rims"]:
            rims(hull)
        if P["vents"]:
            vent(hull)
        if P["pistons"]:
            counts["rams"] = pistons(hull, plates)
        if P["collars"]:
            counts["collars"] = collars(cylinders, hull)
        if "work_lights" in P["kit"]:
            counts["lamps"] = kit_work_lights([o for o in objs if role_of(o) in PLATE_ROLES], glass)
        if "tow_lugs" in P["kit"]:
            counts["lugs"] = kit_tow_lugs(hull)
    for o in tracks:
        polish_track(o)
    for o in plates:
        polish_plate(o)
    for o in cylinders:
        bevel_modifier(o, kp(0.25), 1, angle=60.0)
    # Everything stays flat-shaded: smoothing by angle bleeds the bevel bands into the big
    # plates and turns a flat panel into a gradient, which the toon shader then bands.
    out.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(out), compress=True)
    print("blendforge: polished", counts, "->", out)


main()

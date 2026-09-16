"""Runs inside Blender. Renders data passes of a mech .blend for tools/blendforge/forge.py.

    Blender -b model.blend -P bl_render.py -- --spec spec.json --out DIR

Nothing here shades. Every material is swapped for an emission shader that encodes what the
spriter's raster needs, so the driver can light, tone, crease and outline the mesh with the
exact code that draws the primitive mechs:

    <view>_nrm.png   RGB = world normal * 0.5 + 0.5, A = coverage
    <view>_aux.png   R = material index (1-based), G = depth across the model's depth range

The camera is orthographic. It stays in the spriter's frame: it looks along +y, tilted
`pitch` degrees down, and a view's `yaw` turns it about z the opposite way, which is the
same picture as turning the model. The file is never saved, so the edits are harmless.
"""

import json
import math
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector

ROLES = ["steel", "steel_dark", "rubber", "glass", "amber", "hot", "bore", "white", "livery"]


def args():
    argv = sys.argv[sys.argv.index("--") + 1:]
    out = {}
    for i in range(0, len(argv), 2):
        out[argv[i].lstrip("-")] = argv[i + 1]
    return out


def mesh_objects():
    return [o for o in bpy.context.scene.objects if o.type == "MESH" and not o.hide_render]


def is_detail(obj):
    return "detail" in obj.name.lower()


def world_vertices(objs):
    dg = bpy.context.evaluated_depsgraph_get()
    pts = []
    for o in objs:
        ev = o.evaluated_get(dg)
        me = ev.to_mesh()
        mw = ev.matrix_world
        pts.extend(mw @ v.co for v in me.vertices)
        ev.to_mesh_clear()
    return pts


def screen_extent(pts, yaw, pitch):
    """Width and height in units of the model's projection, plus the lowest and highest
    screen heights relative to the origin, for a view turned `yaw` and tilted `pitch`."""
    r = math.radians(yaw)
    p = math.radians(pitch)
    up = Vector((0.0, math.sin(p), math.cos(p)))
    rot = Matrix.Rotation(r, 3, "Z")
    xs, ys = [], []
    for v in pts:
        w = rot @ v
        xs.append(w.x)
        ys.append(w.dot(up))
    return max(xs) - min(xs), max(ys) - min(ys)


def role_of(mat):
    name = mat.name.lower()
    if "." in name and name.rsplit(".", 1)[1].isdigit():
        name = name.rsplit(".", 1)[0]
    return name if name in ROLES else None


def base_colour(mat):
    """The colour the author set, for materials that are not a named role."""
    if mat.use_nodes and mat.node_tree:
        for n in mat.node_tree.nodes:
            if n.type == "BSDF_PRINCIPLED":
                c = n.inputs["Base Color"].default_value
                return [c[0], c[1], c[2]]
    c = mat.diffuse_color
    return [c[0], c[1], c[2]]


def ensure_materials(objs):
    """Every face gets a material; a missing one is steel. Returns the ordered list."""
    default = bpy.data.materials.get("steel") or bpy.data.materials.new("steel")
    for o in objs:
        if not o.data.materials:
            o.data.materials.append(default)
        for i, m in enumerate(o.data.materials):
            if m is None:
                o.data.materials[i] = default
    mats = []
    for o in objs:
        for m in o.data.materials:
            if m not in mats:
                mats.append(m)
    return mats


def clear_tree(mat):
    mat.use_nodes = True
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    em = nt.nodes.new("ShaderNodeEmission")
    em.inputs["Strength"].default_value = 1.0
    nt.links.new(em.outputs[0], out.inputs[0])
    return nt, em


def normal_tree(mat):
    nt, em = clear_tree(mat)
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    mad = nt.nodes.new("ShaderNodeVectorMath")
    mad.operation = "MULTIPLY_ADD"
    mad.inputs[1].default_value = (0.5, 0.5, 0.5)
    mad.inputs[2].default_value = (0.5, 0.5, 0.5)
    nt.links.new(geo.outputs["Normal"], mad.inputs[0])
    nt.links.new(mad.outputs[0], em.inputs["Color"])


def aux_tree(mat, index, near, far):
    nt, em = clear_tree(mat)
    cam = nt.nodes.new("ShaderNodeCameraData")
    rng = nt.nodes.new("ShaderNodeMapRange")
    rng.inputs["From Min"].default_value = near
    rng.inputs["From Max"].default_value = far
    comb = nt.nodes.new("ShaderNodeCombineColor")
    comb.inputs["Red"].default_value = index / 255.0
    comb.inputs["Blue"].default_value = 0.0
    nt.links.new(cam.outputs["View Z Depth"], rng.inputs["Value"])
    nt.links.new(rng.outputs["Result"], comb.inputs["Green"])
    nt.links.new(comb.outputs[0], em.inputs["Color"])


def setup_scene(scene):
    engines = [i.identifier for i in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items]
    scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in engines else "BLENDER_EEVEE"
    scene.render.film_transparent = True
    scene.render.resolution_percentage = 100
    scene.render.filter_size = 0.0
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.image_settings.color_depth = "8"
    scene.render.dither_intensity = 0.0
    scene.view_settings.view_transform = "Raw"
    scene.view_settings.look = "None"
    scene.view_settings.exposure = 0.0
    scene.view_settings.gamma = 1.0
    if hasattr(scene, "eevee"):
        scene.eevee.taa_render_samples = 1
    if scene.world is None:
        scene.world = bpy.data.worlds.new("void")
    scene.world.use_nodes = False
    scene.world.color = (0.0, 0.0, 0.0)
    cam_data = bpy.data.cameras.new("spriter_cam")
    cam_data.type = "ORTHO"
    cam_data.clip_start = 0.1
    cam_data.clip_end = 100000.0
    cam = bpy.data.objects.new("spriter_cam", cam_data)
    scene.collection.objects.link(cam)
    scene.camera = cam
    return cam


def place_camera(cam, yaw, pitch, ppu, width_px, height_px, baseline_units, distance):
    """Orthographic camera looking along +y and `pitch` down, turned by -yaw about z. The
    view centre sits so the origin's z=0 plane is `baseline_units` above the bottom edge."""
    p = math.radians(pitch)
    fwd = Vector((0.0, math.cos(p), -math.sin(p)))
    up = Vector((0.0, math.sin(p), math.cos(p)))
    centre_h = height_px / ppu / 2.0 - baseline_units
    loc = up * centre_h - fwd * distance
    rot = Matrix.Rotation(math.radians(-yaw), 3, "Z")
    cam.location = rot @ loc
    cam.rotation_euler = (math.radians(90.0 - pitch), 0.0, math.radians(-yaw))
    cam.data.ortho_scale = max(width_px, height_px) / ppu
    cam.data.sensor_fit = "AUTO"


def main():
    a = args()
    spec = json.loads(Path(a["spec"]).read_text())
    out = Path(a["out"])
    out.mkdir(parents=True, exist_ok=True)
    scene = bpy.context.scene
    objs = mesh_objects()
    if not objs:
        raise SystemExit("no mesh objects to render")
    mats = ensure_materials(objs)
    materials = [{"index": i + 1, "name": m.name, "role": role_of(m), "colour": base_colour(m)} for i, m in enumerate(mats)]

    pts = world_vertices(objs)
    radius = max(v.length for v in pts) + 1.0
    distance = radius * 4.0 + 10.0
    near, far = distance - radius, distance + radius
    cam = setup_scene(scene)

    # Pixels per unit per group, so a mech is the same size in each of its turns. The
    # group's largest projection fits its frame less the outline margin, times `fill`.
    ppu = {}
    for group, g in spec["groups"].items():
        if g.get("ppu"):
            ppu[group] = float(g["ppu"])
            continue
        views = [v for v in spec["views"] if v["group"] == group]
        wmax = hmax = 0.0
        for v in views:
            w, h = screen_extent(pts if v["detail"] else world_vertices([o for o in objs if not is_detail(o)]), v["yaw"], v["pitch"])
            wmax, hmax = max(wmax, w), max(hmax, h)
        # Five pixels of slack: the outline adds one each side, and the driver's crop wants
        # a further clear pixel around that before it calls the frame full.
        fit = min((g["width"] - 5) / max(wmax, 1e-6), (g["height"] - 5) / max(hmax, 1e-6))
        if g.get("ratio_of"):
            fit = min(fit, ppu[g["ratio_of"]] * g["ratio"])
        ppu[group] = fit * g.get("fill", 1.0)

    meta = {"materials": materials, "depth_near": near, "depth_far": far, "ppu": ppu, "views": {}}
    detail_objs = [o for o in objs if is_detail(o)]
    for v in spec["views"]:
        g = spec["groups"][v["group"]]
        ss = v["supersample"]
        pad = v["pad"]
        width_px = (g["width"] + 2 * pad) * ss
        height_px = (g["height"] + 2 * pad) * ss
        p = ppu[v["group"]] * ss
        baseline_units = (g["baseline"] + pad) / ppu[v["group"]]
        scene.render.resolution_x = width_px
        scene.render.resolution_y = height_px
        place_camera(cam, v["yaw"], v["pitch"], p, width_px, height_px, baseline_units, distance)
        for o in detail_objs:
            o.hide_render = not v["detail"]
        for m in mats:
            normal_tree(m)
        scene.render.filepath = str(out / f"{v['name']}_nrm.png")
        bpy.ops.render.render(write_still=True)
        for i, m in enumerate(mats):
            aux_tree(m, i + 1, near, far)
        scene.render.filepath = str(out / f"{v['name']}_aux.png")
        bpy.ops.render.render(write_still=True)
        meta["views"][v["name"]] = {"width_px": width_px, "height_px": height_px, "ppu": p}
    (out / "meta.json").write_text(json.dumps(meta, indent=1))
    print("blendforge: rendered", len(spec["views"]), "views to", out)


main()

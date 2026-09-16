"""Runs inside Blender. Builds a .blend from a JSON list of boxes and cylinders.

    Blender -b -P bl_build.py -- --parts parts.json --out model.blend

The driver writes the JSON from a spriter model, so the same Bulwark exists as primitives and
as a .blend and the two pipelines can be compared. The file it makes is also the template for
hand-modelled mechs: one object per part, at the origin, standing on z=0, facing +y, materials
named by role, and ".detail" on the name of anything the map token should drop.
"""

import json
import math
import sys
from pathlib import Path

import bpy

# Viewport colours only, so the file reads sensibly when opened. The renderer ignores them
# and uses the role's tone ramp.
VIEW_COLOURS = {
    "steel": "#737d8a", "steel_dark": "#4a525e", "rubber": "#35393f", "glass": "#6fe3ff",
    "amber": "#e8a93a", "hot": "#e0473a", "bore": "#14171c", "white": "#d8d2c2", "livery": "#8a2430",
}


def args():
    argv = sys.argv[sys.argv.index("--") + 1:]
    return {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv), 2)}


def material(role):
    m = bpy.data.materials.get(role)
    if m is None:
        m = bpy.data.materials.new(role)
        h = VIEW_COLOURS.get(role, "#737d8a").lstrip("#")
        r, g, b = (int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
        m.diffuse_color = (r, g, b, 1.0)
    return m


def add_part(i, part):
    if part["type"] in ("box", "wedge"):
        lo, hi = part["lo"], part["hi"]
        bpy.ops.mesh.primitive_cube_add(size=1.0)
        o = bpy.context.object
        o.location = [(lo[k] + hi[k]) / 2.0 for k in range(3)]
        o.scale = [max(hi[k] - lo[k], 1e-3) for k in range(3)]
        if part["type"] == "wedge":
            # Drop the top edge on the slope side to the floor, in the cube's own
            # coordinates (half-extents of 0.5), so the scale takes care of the rest.
            axis = 0 if part["slope"][0] == "x" else 1
            sign = 1.0 if part["slope"][1] == "+" else -1.0
            for v in o.data.vertices:
                if v.co.z > 0 and v.co[axis] * sign > 0:
                    v.co.z = -0.5
    else:
        c = part["center"]
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=part["radius"], depth=part["length"], location=c)
        o = bpy.context.object
        if part["axis"] == "x":
            o.rotation_euler = (0.0, math.radians(90.0), 0.0)
        elif part["axis"] == "y":
            o.rotation_euler = (math.radians(90.0), 0.0, 0.0)
    o.name = f"{part['material']}_{i:02d}" + (".detail" if part.get("detail") else "")
    o.data.materials.append(material(part["material"]))
    return o


def main():
    a = args()
    spec = json.loads(Path(a["parts"]).read_text())
    bpy.ops.wm.read_factory_settings(use_empty=True)
    for i, part in enumerate(spec["parts"]):
        add_part(i, part)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    out = Path(a["out"])
    out.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(out), compress=True)
    print("blendforge: wrote", out, "with", len(spec["parts"]), "parts")


main()

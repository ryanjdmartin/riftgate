"""Runs inside Blender. Bakes wear data into vertex colours, then exports the active scene
to glTF for the in-engine 3D view.

    Blender -b model.blend -P bl_export.py -- --out art/models/<chassis>.glb [--bake 1]

The wear layer is one colour attribute, "wear": R is ambient occlusion (0 in a crevice, 1 in
the open) and G is pointiness (0.5 on a flat face, higher on a convex edge, lower in a
concave corner). The toon shader reads it in the clean look: grime where R is low, worn
bright metal where G is high. Nothing here changes the file; the bakes live in the export.
"""

import sys
from pathlib import Path

import bpy


def args():
    argv = sys.argv[sys.argv.index("--") + 1:]
    return {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv), 2)}


def mesh_objects():
    return [o for o in bpy.context.scene.objects if o.type == "MESH" and not o.hide_render]


def colour_attr(me, name):
    a = me.color_attributes.get(name)
    if a is None:
        a = me.color_attributes.new(name, "FLOAT_COLOR", "CORNER")
    me.color_attributes.active_color = a
    return a


def emission_material(name, pointiness):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    em = nt.nodes.new("ShaderNodeEmission")
    nt.links.new(em.outputs[0], out.inputs[0])
    if pointiness:
        geo = nt.nodes.new("ShaderNodeNewGeometry")
        nt.links.new(geo.outputs["Pointiness"], em.inputs["Color"])
    return m


def bake(objs):
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 24
    scene.cycles.use_denoising = False
    scene.render.bake.target = "VERTEX_COLORS"
    scene.render.bake.use_selected_to_active = False
    pointy_mat = emission_material("bake_pointiness", True)
    for o in objs:
        me = o.data
        if me.users > 1:
            o.data = me = me.copy()
        bpy.ops.object.select_all(action="DESELECT")
        o.select_set(True)
        bpy.context.view_layer.objects.active = o
        # AO into "ao", with the object's own materials (they do not matter for AO).
        colour_attr(me, "ao")
        bpy.ops.object.bake(type="AO", target="VERTEX_COLORS")
        # Pointiness into "pointy", with every slot swapped for the emission material.
        saved = [s.material for s in o.material_slots]
        if not o.material_slots:
            me.materials.append(pointy_mat)
        for s in o.material_slots:
            s.material = pointy_mat
        colour_attr(me, "pointy")
        bpy.ops.object.bake(type="EMIT", target="VERTEX_COLORS")
        for s, m in zip(o.material_slots, saved):
            s.material = m
        if not saved:
            me.materials.pop(index=0)
        # Combine into "wear": R = ao, G = pointiness, and make it the only colour layer so
        # the exporter writes it as COLOR_0.
        ao = me.color_attributes["ao"]
        po = me.color_attributes["pointy"]
        wear = colour_attr(me, "wear")
        for i in range(len(wear.data)):
            wear.data[i].color = (ao.data[i].color[0], po.data[i].color[0], 0.0, 1.0)
        me.color_attributes.remove(me.color_attributes["ao"])
        me.color_attributes.remove(me.color_attributes["pointy"])
        me.color_attributes.active_color = me.color_attributes["wear"]
        me.color_attributes.render_color_index = me.color_attributes.find("wear")


def main():
    a = args()
    out = Path(a["out"])
    objs = mesh_objects()
    if a.get("bake", "1") == "1":
        bake(objs)
        print("blendforge: baked wear into", len(objs), "meshes")
    out.parent.mkdir(parents=True, exist_ok=True)
    kw = dict(filepath=str(out), export_format="GLB", export_apply=True, export_materials="EXPORT",
              export_yup=True, use_selection=False, use_visible=False, export_animations=False)
    try:
        bpy.ops.export_scene.gltf(export_vertex_color="ACTIVE", export_active_vertex_color_when_no_material=True, **kw)
    except TypeError:
        bpy.ops.export_scene.gltf(**kw)
    print("blendforge: exported", out)


main()

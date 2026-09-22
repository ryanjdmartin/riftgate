class_name TraceLines
extends RefCounted

## The display's trace, shared by the battlefield and the skirmish: a mesh's feature edges
## as a line mesh (welded by position, kept where faces meet at an angle or stand alone),
## and the material that draws them as light (trace.gdshader) or as black ink.

const EDGE_ANGLE := 28.0
static var _cache: Dictionary = {}   # mesh rid -> ArrayMesh of lines, or null


## "light": everything as light. "ink": everything as black ink. "assets": the player's
## things (mechs, gate, walls) in ink, the field (props, grid) in light (Ryan's trial, 22
## September). RIFTGATE_INK=dark|assets picks at start; the map tuner switches live.
static func mode() -> String:
	match OS.get_environment("RIFTGATE_INK"):
		"dark":
			return "ink"
		"assets":
			return "assets"
	return "light"


## Whether a thing of `kind` ("asset" or "prop") draws in ink under `mode`.
static func inked(mode_name: String, kind: String) -> bool:
	return mode_name == "ink" or (mode_name == "assets" and kind == "asset")


## Hang a trace off every mesh under `node`. Returns the trace instances, so a caller can
## swap their material or hide them later.
static func attach(node: Node, material: Material) -> Array:
	var out: Array = []
	var targets: Array = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		targets.append(node)
	for child in targets:
		var mi: MeshInstance3D = child
		if mi.mesh == null:
			continue
		var edges := edge_mesh(mi.mesh)
		if edges == null:
			continue
		var em := MeshInstance3D.new()
		em.mesh = edges
		em.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		em.material_override = material
		mi.add_child(em)
		out.append(em)
	return out


static func light_material(color: Color) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load("res://game/battle/trace.gdshader")
	m.set_shader_parameter("color", color)
	return m


static func ink_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Palette.BG
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


static func edge_mesh(mesh: Mesh) -> ArrayMesh:
	var key := mesh.get_rid()
	if _cache.has(key):
		return _cache[key]
	var edges: Dictionary = {}   # "a|b" -> [Vector3 a, Vector3 b, Array normals]
	var limit := cos(deg_to_rad(EDGE_ANGLE))
	for s in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(s)
		if arrays.is_empty():
			continue
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var n := idx.size() if idx.size() > 0 else verts.size()
		for f in range(0, n - 2, 3):
			var a: Vector3 = verts[idx[f]] if idx.size() > 0 else verts[f]
			var b: Vector3 = verts[idx[f + 1]] if idx.size() > 0 else verts[f + 1]
			var c: Vector3 = verts[idx[f + 2]] if idx.size() > 0 else verts[f + 2]
			var nrm := (b - a).cross(c - a)
			if nrm.length_squared() < 1e-8:
				continue
			nrm = nrm.normalized()
			for pair in [[a, b], [b, c], [c, a]]:
				var ka := _vkey(pair[0])
				var kb := _vkey(pair[1])
				var k := ka + "|" + kb if ka < kb else kb + "|" + ka
				if not edges.has(k):
					edges[k] = [pair[0], pair[1], []]
				(edges[k][2] as Array).append(nrm)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	var any := false
	for k in edges.keys():
		var e: Array = edges[k]
		var normals: Array = e[2]
		var keep := normals.size() == 1
		if not keep:
			for i in range(normals.size()):
				for j in range(i + 1, normals.size()):
					if (normals[i] as Vector3).dot(normals[j]) < limit:
						keep = true
		if keep:
			st.add_vertex(e[0])
			st.add_vertex(e[1])
			any = true
	var out: ArrayMesh = st.commit() if any else null
	_cache[key] = out
	return out


static func _vkey(v: Vector3) -> String:
	return "%d,%d,%d" % [roundi(v.x * 50.0), roundi(v.y * 50.0), roundi(v.z * 50.0)]

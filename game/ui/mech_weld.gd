class_name MechWeld
extends RefCounted

## A machine's parts welded at load (the bible's battery plan, section 11): the parts that
## move with the same thing (the body, a joint, a weapon's pin) and wear the same material
## become one mesh, so a machine draws in a few dozen calls instead of several a part. A
## phone pays per draw call far more than per vertex, and every part paid for each pass that
## drew it (two in a skirmish view; on the map its outline too, and again in the machines'
## layer) and once more for its trace (docs/measurements.md, 25 October).
##
## What stays a part: whatever the rig drives by name (the sidecar's `glow_parts`, written
## for this: an act's or a gait's glowing pieces and the treads, whose materials it lights
## and scrolls), anything hidden, a trace, a mesh with children, a tagged node. The joints
## and the pins stay where they were with the welded meshes under them, so the rig, a mount
## and a bared socket find what they found before.
##
## Nothing on screen changes. Each welded mesh keeps its parts' scale on its own node (an
## outline grows in a mesh's own units); a group's trace is its parts' own edges, carried by
## its first welded mesh (TraceLines.seed_edges), so a joint draws its trace in one call and
## no line is lost where two parts touch; and a framing reads the parts' boxes (`corners`).
## The geometry is built once a model and shared by every instance (`_plans`).
## RIFTGATE_WELD=off leaves every part as authored, to compare.

const META := "weld"               # on a welded mesh: its parts' box corners in its own space (corners)
const META_TRACE := "weld_trace"   # on a group's first welded mesh: its parts' traces' box corners there
const SHUNNED := Mesh.ARRAY_FORMAT_BONES | Mesh.ARRAY_FORMAT_WEIGHTS | Mesh.ARRAY_FORMAT_CUSTOM0 | Mesh.ARRAY_FORMAT_CUSTOM1 | Mesh.ARRAY_FORMAT_CUSTOM2 | Mesh.ARRAY_FORMAT_CUSTOM3
const CARRIED := Mesh.ARRAY_FORMAT_NORMAL | Mesh.ARRAY_FORMAT_TANGENT | Mesh.ARRAY_FORMAT_TEX_UV | Mesh.ARRAY_FORMAT_TEX_UV2 | Mesh.ARRAY_FORMAT_COLOR

## The model key (its scene and the parts taken) -> the weld, built once: one entry a welded
## mesh, {"group": NodePath, "first": the part whose material it wears, "surface", "scale",
## "mesh": ArrayMesh, "corners": PackedVector3Array}, a group's first also "trace_corners".
static var _plans: Dictionary = {}


## Whether machines weld: RIFTGATE_WELD=off keeps every part as authored.
static func enabled() -> bool:
	return OS.get_environment("RIFTGATE_WELD") != "off"


## The parts a model's sidecar says the rig drives by name (its `glow_parts`), which a weld
## keeps apart. A joint or a pin named there is a group already, its welded meshes under it.
static func kept_parts(model_id: String) -> Array:
	var out: Array = []
	for p in MechRig.load_sidecar(model_id).get("glow_parts", []):
		if MechRig.parse_tag(str(p)).is_empty():
			out.append(str(p))
	return out


## Weld `root`'s parts by material within each moving group: after its materials are on
## (MechView3D.toon), before the rig, the traces or a framing read it. `keep` names the parts
## left alone (kept_parts). Returns how many meshes it took away; a second weld takes none.
static func weld(root: Node3D, keep: Array = []) -> int:
	if not enabled() or root == null:
		return 0
	var parts: Array = []   # [part, its group, its transform in the group], in tree order
	_gather(root, root, keep, parts)
	if parts.is_empty():
		return 0
	var sig := PackedStringArray([root.scene_file_path])
	for p in parts:
		var part: MeshInstance3D = p[0]
		sig.append("%s:%d:%d" % [root.get_path_to(part), part.layers, part.cast_shadow])
	var key := "|".join(sig)
	var plan: Array = _plans.get(key, [])
	if plan.is_empty():
		plan = _plan(root, parts)
		if not root.scene_file_path.is_empty():
			_plans[key] = plan
	for k in range(plan.size()):
		var w: Dictionary = plan[k]
		var first: MeshInstance3D = parts[int(w["first"])][0]
		var mi := MeshInstance3D.new()
		mi.name = "weld_%d" % k
		mi.mesh = w["mesh"]
		mi.scale = Vector3.ONE * float(w["scale"])
		mi.set_surface_override_material(0, first.get_active_material(int(w["surface"])))
		mi.layers = first.layers
		mi.cast_shadow = first.cast_shadow
		mi.set_meta(META, w["corners"])
		if w.has("trace_corners"):
			mi.set_meta(META_TRACE, w["trace_corners"])
		(root.get_node(w["group"]) as Node3D).add_child(mi)
	for p in parts:
		var part: MeshInstance3D = p[0]
		part.get_parent().remove_child(part)
		part.free()
	return parts.size() - plan.size()


## A mesh's box corners in its own space, for a framing: the boxes it stood for before any
## weld, so a weld never moves a machine in its frame (a framing reads their extent and
## their middle). A welded mesh answers for its parts' boxes, the trace it carries for its
## parts' traces' boxes, anything else for its own.
static func corners(mi: MeshInstance3D) -> PackedVector3Array:
	if mi.has_meta(META):
		return mi.get_meta(META)
	var holder := mi.get_parent()
	if mi.has_meta("is_trace") and holder != null and holder.has_meta(META_TRACE):
		return holder.get_meta(META_TRACE)
	var out := PackedVector3Array()
	var box := mi.get_aabb()
	for i in range(8):
		out.append(box.get_endpoint(i))
	return out


## The parts a weld may take, each with the group it moves with (the nearest joint or pin
## above it, else the root) and its transform there, which must be one uniform scale and a
## turn, so the welded mesh can carry the scale. A hidden node keeps everything under it.
static func _gather(node: Node, group: Node3D, keep: Array, out: Array) -> void:
	for c in node.get_children():
		if c is Node3D and not (c as Node3D).visible:
			continue
		if c is MeshInstance3D and _weldable(c as MeshInstance3D, keep):
			var rel := _rel(c, group)
			if _scale_of(rel) > 0.0:
				out.append([c, group, rel])
				continue
		_gather(c, c as Node3D if c is Node3D and not MechRig.parse_tag(str(c.name)).is_empty() else group, keep, out)


static func _weldable(mi: MeshInstance3D, keep: Array) -> bool:
	if not (mi.mesh is ArrayMesh) or mi.get_child_count() > 0 or mi.has_meta("is_trace") or mi.has_meta(META):
		return false
	if not MechRig.parse_tag(str(mi.name)).is_empty() or mi.material_override != null or mi.material_overlay != null or mi.skin != null or mi.transparency > 0.0:
		return false
	var am: ArrayMesh = mi.mesh
	if am.get_blend_shape_count() > 0:
		return false
	for s in range(am.get_surface_count()):
		if am.surface_get_primitive_type(s) != Mesh.PRIMITIVE_TRIANGLES or am.surface_get_format(s) & SHUNNED:
			return false
	for part in keep:
		if MechRig.labelled(str(mi.name), str(part)):
			return false
	return true


## A node's transform relative to an ancestor, by its parent chain (usable outside the tree).
static func _rel(node: Node, ancestor: Node) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var n := node
	while n != null and n != ancestor:
		if n is Node3D:
			xf = (n as Node3D).transform * xf
		n = n.get_parent()
	return xf


## The uniform scale a transform carries (a turn, perhaps a mirror, times one scale), or 0
## for a skew or a stretch.
static func _scale_of(xf: Transform3D) -> float:
	var s := pow(absf(xf.basis.determinant()), 1.0 / 3.0)
	if s < 1e-6:
		return 0.0
	return s if (xf.basis.orthonormalized() * Basis.from_scale(Vector3.ONE * s)).is_equal_approx(xf.basis) else 0.0


## Build the weld for `parts`: one mesh for each group, material, scale and instance setting,
## its parts baked into its own space, and a group's trace on its first one.
static func _plan(root: Node3D, parts: Array) -> Array:
	var buckets: Dictionary = {}   # key -> {"group", "group_node", "first", "surface", "scale", "src", "members": [[part index, surface]]}
	for i in range(parts.size()):
		var part: MeshInstance3D = parts[i][0]
		var group: Node3D = parts[i][1]
		var s := _scale_of(parts[i][2])
		var am: ArrayMesh = part.mesh
		for sfc in range(am.get_surface_count()):
			var src := am.surface_get_material(sfc)
			var k := "%d/%d/%d/%d/%d/%s" % [group.get_instance_id(), src.get_instance_id() if src != null else 0, part.layers, part.cast_shadow,
				am.surface_get_format(sfc) & CARRIED, str(snappedf(s, 0.0001))]
			if not buckets.has(k):
				buckets[k] = {"group": root.get_path_to(group), "group_node": group, "first": i, "surface": sfc, "scale": s, "src": src, "members": []}
			(buckets[k]["members"] as Array).append([i, sfc])
	var plan: Array = []
	var carrier: Dictionary = {}   # group -> [its first welded mesh's entry, the parts in the group]
	for b in buckets.values():
		var unscale := Transform3D(Basis.from_scale(Vector3.ONE / float(b["scale"])), Vector3.ZERO)
		var mesh := _bake(parts, b["members"], unscale)
		mesh.surface_set_material(0, b["src"])
		TraceLines.seed_edges(mesh, PackedVector3Array())
		var box := PackedVector3Array()
		var held := {}
		for m in b["members"]:
			held[int(m[0])] = true
		for i in held.keys():
			var xf: Transform3D = unscale * (parts[i][2] as Transform3D)
			var aabb := (parts[i][0] as MeshInstance3D).get_aabb()
			for k in range(8):
				box.append(xf * aabb.get_endpoint(k))
		var w := {"group": b["group"], "first": b["first"], "surface": b["surface"], "scale": b["scale"], "mesh": mesh, "corners": box}
		plan.append(w)
		if not carrier.has(b["group_node"]):
			carrier[b["group_node"]] = [w, {}]
		for i in held.keys():
			carrier[b["group_node"]][1][i] = true
	# A group's trace rides its first welded mesh: every part's own edges, in that mesh's space,
	# and each part's trace's box for a framing (corners).
	for pair in carrier.values():
		var w: Dictionary = pair[0]
		var unscale := Transform3D(Basis.from_scale(Vector3.ONE / float(w["scale"])), Vector3.ZERO)
		var pts := PackedVector3Array()
		var box := PackedVector3Array()
		for i in pair[1].keys():
			var own := TraceLines.edge_points((parts[i][0] as MeshInstance3D).mesh)
			if own.is_empty():
				continue
			var xf: Transform3D = unscale * (parts[i][2] as Transform3D)
			pts.append_array(xf * own)
			var aabb := AABB(own[0], Vector3.ZERO)
			for p in own:
				aabb = aabb.expand(p)
			for k in range(8):
				box.append(xf * aabb.get_endpoint(k))
		TraceLines.seed_edges(w["mesh"], pts)
		w["trace_corners"] = box
	return plan


## One surface from the members' surfaces, each moved into the welded mesh's space by
## `unscale` times its own transform: positions, normals (by the inverse transpose),
## tangents, the UVs and colours as they were, the indices offset, and a mirrored part's
## triangles turned back round. The parts' own levels of detail (the importer makes them)
## come along: a level at every edge length any part has, each part showing there its own
## finest level at or under it. An orthographic camera picks a level by a mesh's scale alone,
## which the welded mesh keeps, so every part shows the level it showed before.
static func _bake(parts: Array, members: Array, unscale: Transform3D) -> ArrayMesh:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var t := PackedFloat32Array()
	var uv := PackedVector2Array()
	var uv2 := PackedVector2Array()
	var col := PackedColorArray()
	var idx := PackedInt32Array()
	var rows: Array = []   # per member: [its first vertex, mirrored, its indices, its levels [[edge length, indices]]]
	for m in members:
		var am: ArrayMesh = (parts[int(m[0])][0] as MeshInstance3D).mesh
		var a := am.surface_get_arrays(int(m[1]))
		var xf: Transform3D = unscale * (parts[int(m[0])][2] as Transform3D)
		var flip := xf.basis.determinant() < 0.0
		var base := v.size()
		var src_v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		v.append_array(xf * src_v)
		if a[Mesh.ARRAY_NORMAL] != null:
			var moved: PackedVector3Array = Transform3D(xf.basis.inverse().transposed(), Vector3.ZERO) * (a[Mesh.ARRAY_NORMAL] as PackedVector3Array)
			for j in range(moved.size()):
				n.append(moved[j].normalized())
		if a[Mesh.ARRAY_TANGENT] != null:
			var src_t: PackedFloat32Array = a[Mesh.ARRAY_TANGENT]
			for j in range(0, src_t.size(), 4):
				var d := (xf.basis * Vector3(src_t[j], src_t[j + 1], src_t[j + 2])).normalized()
				t.append(d.x)
				t.append(d.y)
				t.append(d.z)
				t.append(-src_t[j + 3] if flip else src_t[j + 3])
		if a[Mesh.ARRAY_TEX_UV] != null:
			uv.append_array(a[Mesh.ARRAY_TEX_UV])
		if a[Mesh.ARRAY_TEX_UV2] != null:
			uv2.append_array(a[Mesh.ARRAY_TEX_UV2])
		if a[Mesh.ARRAY_COLOR] != null:
			col.append_array(a[Mesh.ARRAY_COLOR])
		var tri: PackedInt32Array = a[Mesh.ARRAY_INDEX] if a[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		if tri.is_empty():
			tri = PackedInt32Array(range(src_v.size()))
		_triangles(idx, base, tri, flip)
		rows.append([base, flip, tri, _levels(am, int(m[1]))])
	var edges: Array = []
	for r in rows:
		for l in r[3]:
			if not edges.has(l[0]):
				edges.append(l[0])
	edges.sort()
	var lods := {}
	for e in edges:
		var level := PackedInt32Array()
		for r in rows:
			var pick: PackedInt32Array = r[2]
			for l in r[3]:
				if float(l[0]) <= float(e):
					pick = l[1]
			_triangles(level, int(r[0]), pick, bool(r[1]))
		lods[e] = level
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = v
	arrays[Mesh.ARRAY_INDEX] = idx
	if not n.is_empty():
		arrays[Mesh.ARRAY_NORMAL] = n
	if not t.is_empty():
		arrays[Mesh.ARRAY_TANGENT] = t
	if not uv.is_empty():
		arrays[Mesh.ARRAY_TEX_UV] = uv
	if not uv2.is_empty():
		arrays[Mesh.ARRAY_TEX_UV2] = uv2
	if not col.is_empty():
		arrays[Mesh.ARRAY_COLOR] = col
	var mesh := ArrayMesh.new()
	mesh.resource_name = "weld"
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], lods)
	return mesh


## A part's triangles appended to `out`, offset to where its vertices start, a mirrored one's
## turned back round.
static func _triangles(out: PackedInt32Array, base: int, tri: PackedInt32Array, flip: bool) -> void:
	for j in range(0, tri.size() - 2, 3):
		out.append(base + tri[j])
		out.append(base + (tri[j + 2] if flip else tri[j + 1]))
		out.append(base + (tri[j + 1] if flip else tri[j + 2]))


## A surface's levels of detail as [edge length, indices], shortest edge first: the renderer
## keeps them with the surface, as two or four bytes an index like its own.
static func _levels(am: ArrayMesh, s: int) -> Array:
	var out: Array = []
	var surf := RenderingServer.mesh_get_surface(am.get_rid(), s)
	var count := int(surf.get("index_count", 0))
	var raw: PackedByteArray = surf.get("index_data", PackedByteArray())
	if count <= 0 or raw.is_empty():
		return out
	var wide := raw.size() / count
	for l in surf.get("lods", []):
		var data: PackedByteArray = l["index_data"]
		var ids := PackedInt32Array()
		if wide == 4:
			ids = data.to_int32_array()
		else:
			for j in range(0, data.size(), 2):
				ids.append(data.decode_u16(j))
		out.append([float(l["edge_length"]), ids])
	out.sort_custom(func(x, y): return float(x[0]) < float(y[0]))
	return out

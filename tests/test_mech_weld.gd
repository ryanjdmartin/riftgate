extends TestCase

## The weld (MechWeld): a machine's parts merged by material within each moving group at
## load, the bible's battery plan. Headless, the models instantiate and their arrays read
## back, so the real files are welded and measured: every group's geometry where it was, the
## rig's joints, pins, treads and glows found as before, the trace's edges and the framing's
## boxes kept. Small built models check the cases no machine has yet (a mirror, a scaled
## part, levels of detail on several parts).

const MACHINES := ["badger", "sparrowhawk", "clydesdale", "baboon", "armadillo", "wild_boar", "prairie_dog", "dingo", "goshawk", "nemesis", "ammit", "stingray", "puffin", "funnel_web"]


func _model(id: String) -> Node3D:
	var scene: PackedScene = load("res://art/models/%s.glb" % id)
	var node: Node3D = scene.instantiate()
	var maker := str(ContentDB.load_default().chassis.get(id, {}).get("maker", "minerva"))
	MechView3D.toon(node, maker, "clean")   # as the game does first: the weld groups by the parts' materials
	return node


## The joint or pin a mesh moves with, by name, or "" for the body.
func _group_of(mi: Node, root: Node) -> String:
	var p := mi.get_parent()
	while p != null and p != root:
		if not MechRig.parse_tag(str(p.name)).is_empty():
			return str(p.name)
		p = p.get_parent()
	return ""


## Moments of points: [count, sum, sum of squares, sum of cross products], to compare two
## clouds without rounding them into keys.
func _moments(points: PackedVector3Array) -> Array:
	var s := Vector3.ZERO
	var q := Vector3.ZERO
	var x := Vector3.ZERO
	for p in points:
		s += p
		q += p * p
		x += Vector3(p.x * p.y, p.y * p.z, p.z * p.x)
	return [points.size(), s, q, x]


func _close(a: Array, b: Array) -> bool:
	if a.size() != b.size() or int(a[0]) != int(b[0]):
		return false
	for i in range(1, a.size()):
		var u: Vector3 = a[i]
		var v: Vector3 = b[i]
		if (u - v).length() > 1e-4 * maxf(1.0, maxf(u.length(), v.length())):
			return false
	return true


## Every triangle corner under `root` in its space, by the group it moves with and its
## material: "group|material" -> moments.
func _geometry(root: Node3D) -> Dictionary:
	var pts := {}
	for c in root.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = c
		if mi.has_meta("is_trace") or not mi.visible:
			continue
		var xf := MechWeld._rel(mi, root)
		var am: ArrayMesh = mi.mesh
		for s in range(am.get_surface_count()):
			var src := am.surface_get_material(s)
			var key := "%s|%s" % [_group_of(mi, root), src.resource_name if src != null else ""]
			var a := am.surface_get_arrays(s)
			var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var acc: PackedVector3Array = pts.get(key, PackedVector3Array())
			for i in (a[Mesh.ARRAY_INDEX] as PackedInt32Array):
				acc.append(xf * v[i])
			pts[key] = acc
	var out := {}
	for k in pts.keys():
		out[k] = _moments(pts[k])
	return out


## The trace's segment ends under `root` in its space, by group (TraceLines.edge_points, as
## TraceLines.attach would hang them).
func _edges(root: Node3D) -> Dictionary:
	var pts := {}
	for c in root.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = c
		if mi.has_meta("is_trace") or not mi.visible:
			continue
		var key := _group_of(mi, root)
		var acc: PackedVector3Array = pts.get(key, PackedVector3Array())
		acc.append_array(MechWeld._rel(mi, root) * TraceLines.edge_points(mi.mesh))
		pts[key] = acc
	var out := {}
	for k in pts.keys():
		out[k] = _moments(pts[k])
	return out


## The box corners a framing reads (MechWeld.corners) under `root`, traces included.
func _corners(root: Node3D) -> PackedVector3Array:
	var out := PackedVector3Array()
	for c in root.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = c
		if mi.visible:
			out.append_array(MechWeld._rel(mi, root) * MechWeld.corners(mi))
	return out


func test_every_machine_welds_to_fewer_meshes_with_each_groups_geometry_where_it_was() -> void:
	for id in MACHINES:
		var node := _model(id)
		var before := node.find_children("*", "MeshInstance3D", true, false).size()
		var want := _geometry(node)
		var removed := MechWeld.weld(node, MechWeld.kept_parts(id))
		var after := node.find_children("*", "MeshInstance3D", true, false).size()
		assert_true(removed > 0 and after == before - removed, "%s welds (%d meshes to %d)" % [id, before, after])
		var got := _geometry(node)
		assert_eq(got.keys().size(), want.keys().size(), "%s: every group keeps its materials" % id)
		for k in want.keys():
			assert_true(got.has(k) and _close(got[k], want[k]), "%s: %s's triangles are where they were" % [id, k])
		assert_eq(MechWeld.weld(node, MechWeld.kept_parts(id)), 0, "%s: a second weld takes nothing" % id)
		node.free()


func test_the_rig_finds_on_a_welded_machine_what_it_found_before() -> void:
	for id in MACHINES:
		var plain := _model(id)
		var welded := _model(id)
		MechWeld.weld(welded, MechWeld.kept_parts(id))
		var r0 := MechRig.new()
		r0.setup(plain, id, plain, 1)
		var r1 := MechRig.new()
		r1.setup(welded, id, welded, 1)
		assert_eq(r1.joints.keys(), r0.joints.keys(), "%s: every joint" % id)
		assert_eq(r1.hardpoints.keys(), r0.hardpoints.keys(), "%s: every pin" % id)
		for n in r0.hardpoints.keys():
			assert_eq(r1.joint_of(r1.hardpoints[n]), r0.joint_of(r0.hardpoints[n]), "%s: pin %d rides the same joint" % [id, n])
		assert_eq(r1._tread_mats.size(), r0._tread_mats.size(), "%s: the treads scroll the same materials" % id)
		assert_eq(r1._move_glow.size() > 0, r0._move_glow.size() > 0, "%s: the move's glow finds its lights" % id)
		for part in MechRig.load_sidecar(id).get("glow_parts", []):
			var lit0 := r0._lit_materials(str(part))
			var lit1 := r1._lit_materials(str(part))
			assert_eq(lit1.is_empty(), lit0.is_empty(), "%s: the glow %s finds its lights" % [id, part])
			if MechRig.parse_tag(str(part)).is_empty():
				assert_eq(lit1.size(), lit0.size(), "%s: the kept part %s keeps its own materials" % [id, part])
		plain.free()
		welded.free()


func test_the_trace_keeps_every_parts_edges_on_one_mesh_a_group() -> void:
	for id in MACHINES:
		var node := _model(id)
		var want := _edges(node)
		MechWeld.weld(node, MechWeld.kept_parts(id))
		var got := _edges(node)
		for k in want.keys():
			assert_true(got.has(k) and _close(got[k], want[k]), "%s: %s's trace keeps its parts' edges" % [id, k if not k.is_empty() else "the body"])
		var carriers := {}
		for c in node.find_children("*", "MeshInstance3D", true, false):
			var mi: MeshInstance3D = c
			if mi.has_meta(MechWeld.META) and not TraceLines.edge_points(mi.mesh).is_empty():
				var g := _group_of(mi, node)
				assert_false(carriers.has(g), "%s: %s's trace rides one welded mesh" % [id, g])
				carriers[g] = true
		node.free()


func test_the_framing_reads_the_boxes_it_read_before_the_weld() -> void:
	for id in MACHINES:
		var plain := _model(id)
		var welded := _model(id)
		MechWeld.weld(welded, MechWeld.kept_parts(id))
		var ink := TraceLines.ink_material()
		TraceLines.attach(plain, ink)
		TraceLines.attach(welded, ink)
		var a := _corners(plain)
		var b := _corners(welded)
		assert_true(_close(_moments(b), _moments(a)), "%s: the same boxes, traces included (a framing's extent and middle)" % id)
		plain.free()
		welded.free()


func test_a_second_instance_shares_the_first_ones_weld() -> void:
	var a := _model("badger")
	var b := _model("badger")
	MechWeld.weld(a, MechWeld.kept_parts("badger"))
	MechWeld.weld(b, MechWeld.kept_parts("badger"))
	var ma: Array = a.find_children("weld_*", "MeshInstance3D", true, false).map(func(n): return (n as MeshInstance3D).mesh)
	var mb: Array = b.find_children("weld_*", "MeshInstance3D", true, false).map(func(n): return (n as MeshInstance3D).mesh)
	assert_true(not ma.is_empty() and ma == mb, "the welded meshes are built once a model and shared")
	var wa: MeshInstance3D = a.find_children("weld_*", "MeshInstance3D", true, false)[0]
	var wb: MeshInstance3D = b.find_children("weld_*", "MeshInstance3D", true, false)[0]
	assert_ne(wa.get_active_material(0), wb.get_active_material(0), "each instance wears its own material (a repaint, a glow)")
	a.free()
	b.free()


# ---------------------------------------------------------------- built models

func _part(name: String, mat: Material, xf: Transform3D, lods: Dictionary = {}) -> MeshInstance3D:
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, BoxMesh.new().get_mesh_arrays(), [], lods)
	am.surface_set_material(0, mat)
	var mi := MeshInstance3D.new()
	mi.name = name
	mi.mesh = am
	mi.transform = xf
	return mi


func _named(root: Node, name: String) -> Node:
	return root.find_child(name, true, false)


func test_a_scaled_or_mirrored_part_welds_with_its_scale_kept_and_its_faces_out() -> void:
	var steel := StandardMaterial3D.new()
	var root := Node3D.new()
	var arm := Node3D.new()
	arm.name = "joint_arm"
	arm.position = Vector3(3, 0, 0)
	root.add_child(arm)
	arm.add_child(_part("plate", steel, Transform3D(Basis.from_scale(Vector3.ONE * 2.0), Vector3(1, 0, 0))))
	arm.add_child(_part("plate_001", steel, Transform3D(Basis(Vector3.UP, 0.5).scaled(Vector3.ONE * 2.0), Vector3(0, 2, 0))))
	arm.add_child(_part("plate_002", steel, Transform3D(Basis.from_scale(Vector3(-1, 1, 1)), Vector3(0, -2, 0))))
	root.add_child(_part("hull", steel, Transform3D.IDENTITY))
	var want := _geometry(root)
	assert_eq(MechWeld.weld(root), 1, "four parts become three meshes: the arm's doubled pair, its mirror, the hull")
	var got := _geometry(root)
	for k in want.keys():
		assert_true(got.has(k) and _close(got[k], want[k]), "%s's triangles where they were" % k)
	var scales: Array = arm.get_children().map(func(n): return snappedf((n as Node3D).scale.x, 0.001))
	scales.sort()
	assert_eq(scales, [1.0, 2.0], "the doubled pair's mesh is doubled itself, so an outline grows as it did")
	for c in arm.get_children():
		var mi: MeshInstance3D = c
		var a := mi.mesh.surface_get_arrays(0)
		var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		var nrm: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
		var idx: PackedInt32Array = a[Mesh.ARRAY_INDEX]
		var agree := 0
		for j in range(0, idx.size(), 3):
			var face := (v[idx[j + 1]] - v[idx[j]]).cross(v[idx[j + 2]] - v[idx[j]])
			if face.dot(nrm[idx[j]]) < 0.0:   # Godot's front faces wind clockwise: the cross product points in
				agree += 1
		assert_eq(agree, idx.size() / 3, "every triangle of %s still faces out (a mirror's turned back round)" % ("the mirror" if snappedf(mi.scale.x, 0.001) == 1.0 else "the pair"))
	root.free()


func test_kept_hidden_and_tagged_parts_stay_as_they_are() -> void:
	var steel := StandardMaterial3D.new()
	var root := Node3D.new()
	var lamp := _part("lamp_001", steel, Transform3D.IDENTITY)
	var hidden := _part("cover", steel, Transform3D.IDENTITY)
	hidden.visible = false
	var shut := Node3D.new()
	shut.name = "hatch"
	shut.visible = false
	var inside := _part("hatch_plate", steel, Transform3D.IDENTITY)
	var pin := Node3D.new()
	pin.name = "hp_1"
	for n in [lamp, hidden, shut, pin]:
		root.add_child(n)
	shut.add_child(inside)
	pin.add_child(_part("barrel", steel, Transform3D.IDENTITY))
	pin.add_child(_part("barrel_001", steel, Transform3D(Basis.IDENTITY, Vector3(0, 1, 0))))
	root.add_child(_part("hull", steel, Transform3D.IDENTITY))
	root.add_child(_part("hull_001", steel, Transform3D(Basis.IDENTITY, Vector3(0, 0, 2))))
	MechWeld.weld(root, ["lamp"])
	assert_true(is_instance_valid(lamp) and lamp.get_parent() == root, "a part the rig drives by name stays itself")
	assert_true(is_instance_valid(hidden) and is_instance_valid(inside), "a hidden part, and one under a hidden node, stay")
	assert_eq(pin.get_child_count(), 1, "the pin's stock welds under the pin, so baring the socket hides it")
	assert_true(pin.get_child(0).has_meta(MechWeld.META), "and that one child is the weld")
	assert_eq(root.find_children("hull*", "MeshInstance3D", true, false).size(), 0, "the body's parts welded")
	root.free()


func test_a_welded_surface_carries_every_parts_levels_of_detail() -> void:
	var steel := StandardMaterial3D.new()
	var full: PackedInt32Array = BoxMesh.new().get_mesh_arrays()[Mesh.ARRAY_INDEX]
	var coarse := full.slice(0, 6)    # two triangles
	var coarser := full.slice(0, 3)   # one
	var root := Node3D.new()
	root.add_child(_part("a", steel, Transform3D.IDENTITY, {2.0: coarse}))
	root.add_child(_part("b", steel, Transform3D(Basis.IDENTITY, Vector3(3, 0, 0)), {2.0: coarse, 5.0: coarser}))
	root.add_child(_part("c", steel, Transform3D(Basis.IDENTITY, Vector3(6, 0, 0))))
	MechWeld.weld(root)
	var w: MeshInstance3D = root.get_child(0)
	var surf := RenderingServer.mesh_get_surface(w.mesh.get_rid(), 0)
	var levels: Array = surf.get("lods", [])
	var edges: Array = levels.map(func(l): return snappedf(float(l["edge_length"]), 0.001))
	assert_eq(edges, [2.0, 5.0], "a level at every edge length a part has")
	var wide := (surf["index_data"] as PackedByteArray).size() / int(surf["index_count"])
	var counts: Array = levels.map(func(l): return (l["index_data"] as PackedByteArray).size() / wide)
	assert_eq(counts, [6 + 6 + full.size(), 6 + 3 + full.size()], "each part shows its own finest level at or under each, the plain part whole")
	root.free()


func test_the_switch_leaves_every_part_as_authored() -> void:
	var node := _model("dingo")
	var before := node.find_children("*", "MeshInstance3D", true, false).size()
	OS.set_environment("RIFTGATE_WELD", "off")
	var removed := MechWeld.weld(node, MechWeld.kept_parts("dingo"))
	OS.unset_environment("RIFTGATE_WELD")
	assert_eq(removed, 0, "RIFTGATE_WELD=off welds nothing")
	assert_eq(node.find_children("*", "MeshInstance3D", true, false).size(), before, "every part still there")
	node.free()

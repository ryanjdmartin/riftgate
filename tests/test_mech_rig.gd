extends TestCase

## The rig (MechRig): a machine's joints read from its model and its sidecar, the idle acts
## picked and played, the limits, the strikes. Headless: the models instantiate without a
## renderer, so the joints' nesting and the sidecars are checked against the real files;
## only the drawing needs a window.

const MACHINES := ["badger", "kite", "clydesdale", "baboon", "polar_bear", "wild_boar", "prairie_dog", "dingo", "buzzard", "nemesis", "ammit", "stingray", "puffin", "funnel_web",
	"skua", "needletail", "storm_petrel", "giant_petrel", "lammergeier", "musk_ox",
	"cassowary", "cottonmouth", "swallowtail", "whip_scorpion"]


func _rig_for(model_id: String, seed_value: int = 1) -> Array:
	var scene: PackedScene = load("res://art/models/%s.glb" % model_id)
	var model: Node3D = scene.instantiate()
	var rig := MechRig.new()
	rig.setup(model, model_id, model, seed_value)
	return [rig, model]


func test_authored_axes_become_the_nodes_euler() -> void:
	assert_eq(MechRig.axis_for("turret_l"), "yaw", "a turret traverses about up")
	assert_eq(MechRig.axis_for("caster_fl"), "yaw", "a caster swings about up")
	assert_eq(MechRig.axis_for("steer_fr"), "yaw", "a steering knuckle too")
	assert_eq(MechRig.axis_for("head"), "yaw", "a head turns")
	assert_eq(MechRig.axis_for("shoulder_l"), "pitch", "a limb swings about the axle line")
	assert_eq(MechRig.axis_for("wheel_rl"), "pitch", "a wheel spins about the axle line")
	assert_eq(MechRig.axis_vector("pitch"), Vector3(1, 0, 0), "pitch is the node's x")
	assert_eq(MechRig.axis_vector("yaw"), Vector3(0, 1, 0), "yaw is the node's y")
	assert_eq(MechRig.axis_vector("roll"), Vector3(0, 0, -1), "roll is about forward, which came through as -z")
	var e := MechRig.euler_of(Vector3(90.0, 0.0, 10.0))
	assert_true(is_equal_approx(e.x, PI / 2.0) and is_equal_approx(e.z, -deg_to_rad(10.0)), "degrees to radians, roll flipped")
	assert_eq(MechRig.offset_of(Vector3(1.0, 2.0, 3.0)), Vector3(1.0, 3.0, -2.0), "a slide: right stays, up becomes y, forward becomes -z")


func test_limits_clamp_only_the_axes_they_name() -> void:
	var lim := {"yaw": [0.0, 110.0]}
	assert_eq(MechRig.clamp_degrees(Vector3(5.0, -40.0, 3.0), lim), Vector3(5.0, 0.0, 3.0), "an outward-only turret never turns in")
	assert_eq(MechRig.clamp_degrees(Vector3(5.0, 200.0, 3.0), lim), Vector3(5.0, 110.0, 3.0), "and stops at its stop")
	assert_eq(MechRig.clamp_degrees(Vector3(99.0, 0.0, 0.0), {}), Vector3(99.0, 0.0, 0.0), "no limits, no clamp")


func test_sampling_rests_at_both_ends_and_eases_between_keys() -> void:
	var keys := [[1.0, 10.0], [2.0, 10.0]]
	assert_eq(MechRig.sample(keys, 0.0, 3.0), [0.0], "rest at the start")
	assert_eq(MechRig.sample(keys, 1.0, 3.0), [10.0], "the first key")
	assert_eq(MechRig.sample(keys, 1.5, 3.0), [10.0], "held between equal keys")
	assert_eq(MechRig.sample(keys, 3.0, 3.0), [0.0], "rest again at the end")
	assert_eq(MechRig.sample(keys, 9.0, 3.0), [0.0], "and after it")
	var mid: float = MechRig.sample(keys, 0.5, 3.0)[0]
	assert_true(is_equal_approx(mid, 5.0), "halfway up the ramp: 5")
	var quarter: float = MechRig.sample(keys, 0.25, 3.0)[0]
	assert_true(quarter < 2.5, "smooth: slow off the mark (%f)" % quarter)
	var lin: float = MechRig.sample(keys, 0.25, 3.0, "linear")[0]
	assert_true(is_equal_approx(lin, 2.5), "linear: a straight ramp")
	# A wheel's last key at the act's end never unwinds: the end is that key, not rest.
	var spin := [[0.3, 0.0], [2.6, -360.0]]
	assert_eq(MechRig.sample(spin, 2.6, 2.6), [-360.0], "a whole turn at the end stays a whole turn")
	var wide := [[1.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0]]
	assert_eq(MechRig.sample(wide, 1.0, 2.0), [1.0, 2.0, 3.0, 4.0, 5.0, 6.0], "seven-wide keys sample six values")
	assert_eq(MechRig.sample([[1.0, 4.0]], 1.0, 2.0).size(), 1, "a two-wide key samples one")


func test_every_sidecar_names_joints_the_model_has_and_several_acts() -> void:
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		assert_true(not side.is_empty(), "%s has a rig sidecar" % id)
		var pair := _rig_for(id)
		var rig: MechRig = pair[0]
		var side_joints: Dictionary = side.get("joints", {})
		for name in side_joints.keys():
			assert_true(rig.joints.has(name), "%s: the sidecar's joint %s is in the model" % [id, name])
			var parent := str(side_joints[name].get("parent", ""))
			if not parent.is_empty():
				assert_eq(rig.joint_of(rig.joints[name]), parent, "%s: %s nests under %s" % [id, name, parent])
			assert_true(str(side_joints[name].get("axis", "")) in ["pitch", "yaw", "roll"], "%s: %s has an axis" % [id, name])
		for name in rig.joints.keys():
			assert_true(side_joints.has(name), "%s: the model's joint %s is in the sidecar" % [id, name])
		var acts: Array = side.get("acts", [])
		assert_true(acts.size() >= 2, "%s has several acts (Ryan, 2 October: a requirement), got %d" % [id, acts.size()])
		var names := {}
		for a in acts:
			assert_true(float(a.get("duration", 0.0)) > 0.0, "%s: act %s lasts" % [id, a.get("name", "?")])
			assert_false(names.has(a["name"]), "%s: act names are unique (%s)" % [id, a["name"]])
			names[a["name"]] = true
			for jn in a.get("tracks", {}).keys():
				assert_true(rig.joints.has(jn), "%s: act %s keys joint %s, which the model has" % [id, a["name"], jn])
				for key in a["tracks"][jn]:
					assert_true((key as Array).size() == 7, "%s: a track key is seven wide" % id)
					var deg := Vector3(float(key[1]), float(key[2]), float(key[3]))
					var lim: Dictionary = side_joints[jn].get("limits", {})
					assert_eq(MechRig.clamp_degrees(deg, lim), deg, "%s: act %s keeps %s inside its limits at t=%s" % [id, a["name"], jn, key[0]])
		assert_true(rig.alive(), "%s: a rig with acts is alive" % id)
		pair[1].free()


func test_the_glow_parts_name_lit_meshes_in_every_model() -> void:
	# Headless, the materials are not applied, so the lit surfaces cannot be found by their
	# emission; the names at least must be meshes in the model, or sockets and joints.
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		var pair := _rig_for(id)
		var rig: MechRig = pair[0]
		var model: Node3D = pair[1]
		for part in side.get("glow_parts", []):
			var tag := MechRig.parse_tag(str(part))
			if tag.size() == 2:
				assert_true((rig.joints.has(tag[1]) if tag[0] == "joint" else rig.hardpoints.has(tag[1])), "%s: glow group %s exists" % [id, part])
			else:
				var found := false
				for mi in model.find_children("*", "MeshInstance3D", true, false):
					if MechRig.labelled(str(mi.name), str(part)):
						found = true
						break
				assert_true(found, "%s: a mesh labelled %s carries the glow (the label whole, never a prefix)" % [id, part])
		model.free()


func test_a_standing_glow_holds_its_light_and_a_flare_rises_past_it() -> void:
	var rig := MechRig.new()
	var lit := StandardMaterial3D.new()
	lit.emission_energy_multiplier = 2.0
	rig._standing[lit] = 5.0
	rig._light_to(lit, MechRig._rest_of(lit), 1.0)
	assert_true(absf(lit.emission_energy_multiplier - 2.0 * MechRig.light(5.0)) < 0.0001, "at rest it holds its standing glow")
	rig._light_to(lit, MechRig._rest_of(lit), 9.0)
	assert_true(absf(lit.emission_energy_multiplier - 2.0 * MechRig.light(9.0)) < 0.0001, "an act's flare rises past it")
	assert_true(absf(MechRig._rest_of(lit) - 2.0) < 0.0001, "its rest is kept under the raised light")


func test_a_halo_names_only_parts_a_glow_lights() -> void:
	# A part a glow lights, or a lit part a launch carries, which its flight lights (the Swallowtail's
	# flare stars: lowforge's launch()).
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		var halo = side.get("halo", [])
		assert_true(halo is Array, "%s: the halo is a list of parts" % id)
		var flown := []
		if not (side.get("launches", {}) as Dictionary).is_empty():
			var model: Node3D = (load("res://art/models/%s.glb" % id) as PackedScene).instantiate()
			for rows in (side["launches"] as Dictionary).values():
				for l in rows:
					var n := model.find_child(str(l.get("node", "")), true, false)
					for mi in (n.find_children("*", "MeshInstance3D", true, false) if n != null else []):
						flown.append(str(mi.name))
			model.free()
		for entry in (halo if halo is Array else []):
			var p = entry[0] if entry is Array else entry
			var lit := (side.get("glow_parts", []) as Array).has(p)
			var carried := flown.any(func(f): return MechRig.labelled(f, str(p)))
			assert_true(lit or carried, "%s: the halo's %s is a part a glow lights or a launch carries" % [id, p])


func test_a_halo_closes_round_a_flat_part_and_shows_only_as_its_light_climbs() -> void:
	# Each corner of the shell takes the sum of the faces meeting there, so a flat-shaded box's
	# shell grows out along its diagonals, closed, never split open along its edges.
	var box := ArrayMesh.new()
	box.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, BoxMesh.new().get_mesh_arrays())
	var shell := MechRig._halo_mesh(box, 0).surface_get_arrays(0)
	var verts: PackedVector3Array = shell[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = shell[Mesh.ARRAY_NORMAL]
	var out := 0
	for i in range(verts.size()):
		if normals[i].dot(verts[i].normalized()) > 0.999:
			out += 1
	assert_true(verts.size() >= 24, "a box's shell keeps its faces' corners")
	assert_eq(out, verts.size(), "every corner of a box's shell points straight out from its middle")
	# A flat part's shell spreads round its rim, never floating off its face: a quad's corners lean
	# outward in its plane as well as off it.
	var quad := ArrayMesh.new()
	quad.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, QuadMesh.new().get_mesh_arrays())
	var flat := MechRig._halo_mesh(quad, 0).surface_get_arrays(0)
	var fv: PackedVector3Array = flat[Mesh.ARRAY_VERTEX]
	var fn: PackedVector3Array = flat[Mesh.ARRAY_NORMAL]
	var leaning := 0
	for i in range(fv.size()):
		if fn[i].dot(Vector3(fv[i].x, fv[i].y, 0.0).normalized()) > 0.5 and absf(fn[i].z) > 0.3:
			leaning += 1
	assert_eq(leaning, fv.size(), "every corner of a flat quad's shell leans out round its rim")
	# At rest a lit part wears no halo; it fades in as the part's light climbs over its rest,
	# whole at HALO_FULL rests over, burning at the part's own light.
	var rig := MechRig.new()
	var lit := StandardMaterial3D.new()
	var halo := ShaderMaterial.new()
	halo.shader = MechRig.HALO_SHADER
	rig._halos[lit] = [halo]
	rig._light_to(lit, 2.0, 1.0)
	assert_eq(halo.get_shader_parameter("presence"), 0.0, "no halo at rest")
	rig._light_to(lit, 2.0, 1.0 + MechRig.HALO_FULL / 2.0)
	assert_true(absf(float(halo.get_shader_parameter("presence")) - 0.5) < 0.001, "half a halo halfway to full")
	rig._light_to(lit, 2.0, 1.0 + MechRig.HALO_FULL * 3.0)
	assert_eq(halo.get_shader_parameter("presence"), 1.0, "a whole halo past full")
	assert_true(absf(float(halo.get_shader_parameter("light")) - lit.emission_energy_multiplier) < 0.0001, "the halo burns at its part's light")


func test_a_halo_is_drawn_toward_the_eye_unless_its_part_names_its_own_distance() -> void:
	# A part in a slot glows out over its walls; a part standing proud of a thin plate names nought,
	# so its halo never shows through the plate when it faces away.
	var rig := MechRig.new()
	rig.model = Node3D.new()
	var shells := {}
	for part in ["slot", "puck"]:
		var mi := MeshInstance3D.new()
		mi.name = part
		mi.mesh = BoxMesh.new()
		var lit := StandardMaterial3D.new()
		lit.emission_enabled = true
		mi.set_surface_override_material(0, lit)
		rig.model.add_child(mi)
		shells[part] = mi
	rig._setup_halos({"halo": ["slot", ["puck", 1.0, 0.0]]})
	for part in shells.keys():
		var worn: Array = (shells[part] as Node).find_children("halo", "MeshInstance3D", false, false)
		assert_eq(worn.size(), 1, "the %s wears one halo" % part)
		if worn.size() == 1:
			var ahead := float(((worn[0] as MeshInstance3D).material_override as ShaderMaterial).get_shader_parameter("ahead"))
			assert_eq(ahead, MechRig.HALO_AHEAD if part == "slot" else 0.0, "the %s's halo is drawn its distance toward the eye" % part)
	rig.model.free()   # the rig is RefCounted and goes with its last reference


func test_only_the_weapon_that_fired_kicks_after_its_aim() -> void:
	# The Prairie Dog's twin autoguns ride its turret; its other mounts sit on the chassis.
	var pair := _rig_for("prairie_dog")
	var rig: MechRig = pair[0]
	rig.strike(true, ["turret"], Vector3.ZERO, 0.1)
	for st in rig._strikes:
		assert_eq(str(st["joint"]), "turret", "only the joint carrying the weapon that fired kicks")
	assert_false(rig._strikes.is_empty(), "and it does kick")
	assert_eq(MechRig._strike_envelope(rig._strikes[0]), 0.0, "held while the machine turns onto its target")
	rig._step(0.15)
	assert_true(MechRig._strike_envelope(rig._strikes[0]) > 0.0, "then the blow")
	assert_eq(rig.aim_joint_over(rig.hardpoints[1]), "turret", "the turret aims the gun on it")
	assert_eq(rig.aim_joint_over(rig.hardpoints[2]), "", "a gun on the chassis aims by nothing")
	pair[1].free()
	# A fixed gun whose business end rides a joint carrying no mount (the Badger's fragmenter on its
	# wrist) still kicks when it fires, since the strike names that joint; an unnamed shot leaves it.
	var checked := 0
	for f in DirAccess.get_files_at("res://art/models"):
		if not f.ends_with(".rig.json"):
			continue
		var model_id := f.trim_suffix(".rig.json")
		var side := MechRig.load_sidecar(model_id)
		var fx = side.get("fx", {})
		if not (fx is Dictionary) or (fx as Dictionary).is_empty():
			continue
		pair = _rig_for(model_id)
		rig = pair[0]
		var nodes := MechView3D.fx_of(pair[1], side)
		for cid in nodes.keys():
			var owner := rig.joint_of(nodes[cid])
			var carries := owner.is_empty()
			for n in rig.hardpoints.keys():
				if rig.joint_of(rig.hardpoints[n]) == owner:
					carries = true
			if carries:
				continue
			rig._strikes.clear()
			rig.strike(true)
			assert_true(rig._strikes.filter(func(st) -> bool: return str(st["joint"]) == owner).is_empty(), "%s: a shot naming no joint kicks only those carrying mounts, never %s" % [model_id, owner])
			rig._strikes.clear()
			rig.strike(true, [owner])
			assert_eq(rig._strikes.filter(func(st) -> bool: return str(st["joint"]) == owner).size(), 1, "%s: its %s kicks the %s carrying it, mount or none" % [model_id, cid, owner])
			checked += 1
		pair[1].free()
	assert_true(checked > 0, "some fixed gun rides a joint carrying no mount")
	pair = _rig_for("polar_bear")
	rig = pair[0]
	assert_eq(rig.aim_joint_over(rig.hardpoints[1]), "", "a quad's port guns never turn to aim (Ryan: don't bother)")
	pair[1].free()
	pair = _rig_for("nemesis")
	rig = pair[0]
	assert_eq(rig.aim_joint_over(rig.hardpoints[2]), "waist", "past the shoulder's elevation, the waist")
	rig.aim("waist", 20.0, 1.0)
	rig._step(MechRig.AIM_UP + 0.05)
	rig._pose()
	var turned := rad_to_deg(rig.joints["waist"].rotation.y - rig._rest["waist"].y)
	assert_true(absf(turned - 20.0) < 1.0, "the waist turns its aim to the left (%.1f)" % turned)
	rig._step(1.0 + MechRig.AIM_DOWN)
	assert_true(rig._aim.is_empty(), "and lets it go once the blow has landed")
	pair[1].free()


func test_a_fixed_weapon_fires_with_a_slice_of_its_own_act() -> void:
	# Every firing a sidecar names is one of its chassis's fixed components, or its passive where the
	# passive fires (a release: the Whip Scorpion's broadside, 12 November), on an act it has, so a
	# renamed component, passive or act fails here until the model follows.
	var db := ContentDB.load_default()
	var named := 0
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		var fires = side.get("fires", {})
		var fixed: Array = db.chassis.get(id, {}).get("fixed", [])
		var passive = db.chassis.get(id, {}).get("passive", null)
		var passive_id := str(passive.get("id", "")) if passive is Dictionary else ""
		var releases := passive is Dictionary and (passive.get("effects", []) as Array).any(func(e) -> bool: return e is Dictionary and str(e.get("effect", "")) == "pass_release")
		var acts := {}
		for a in side.get("acts", []):
			acts[str(a["name"])] = float(a.get("duration", 0.0))
		for cid in (fires as Dictionary).keys():
			named += 1
			if not passive_id.is_empty() and cid == passive_id:
				assert_true(releases, "%s: its passive %s fires with an act, and fires something (a release)" % [id, cid])
			else:
				assert_true(fixed.has(cid), "%s: %s fires with an act, and is one of its fixed weapons" % [id, cid])
			var slices: Array = fires[cid] if fires[cid] is Array else [fires[cid]]
			for f in slices:
				assert_true(acts.has(str(f["act"])), "%s: %s's act %s is one of its own" % [id, cid, f["act"]])
				assert_true(float(f["from"]) < float(f["to"]) and float(f["to"]) <= float(acts.get(str(f["act"]), 0.0)), "%s: %s's slice lies inside its act" % [id, cid])
				if f.has("blow"):
					assert_true(float(f["from"]) <= float(f["blow"]) and float(f["blow"]) <= float(f["to"]), "%s: %s's blow lies inside its slice" % [id, cid])
	assert_true(named >= 10, "the cheapest locked weapons fire with their acts (%d)" % named)
	# The slice plays from its start and ends at its end, cutting the act short.
	var pair := _rig_for("nemesis")
	var rig: MechRig = pair[0]
	var cid := str((rig.fires as Dictionary).keys()[0])
	var f: Dictionary = rig.fire_slice(cid)
	assert_true(rig.fire_act(cid), "the fixed weapon fires with its act")
	assert_eq(str(rig._current["name"]), str(f["act"]), "the act it names plays")
	assert_true(absf(rig._t - float(f["from"])) < 0.001, "from the slice's start")
	rig._step(float(f["to"]) - float(f["from"]) - 0.05)
	assert_false(rig._current.is_empty(), "through the slice")
	rig._step(0.1)
	assert_true(rig._current.is_empty(), "and no further than its end")
	assert_false(rig.fire_act("no_such_weapon"), "a weapon with no firing act strikes as before")
	pair[1].free()


func test_no_stock_gun_is_built_by_hand_and_every_aim_joint_turns() -> void:
	# Every stock component a mount carries wears its class, as a fitted one does (Ryan, 11
	# November: "There's no reason to keep hand build guns anywhere"), the class content gives
	# it, so it flares at its class's muzzles; a hidden mount shows nothing (the Cottonmouth's
	# guns inside its drum). A fixed weapon's named aim joint turns about its up axis.
	var db := ContentDB.load_default()
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		var pins: Dictionary = side.get("pins", {})
		var shapes: Dictionary = side.get("stock_shapes", {})
		var hidden = side.get("hidden_pins", [])
		assert_false(side.has("muzzles"), "%s: no stock gun of its carries muzzles of its own" % id)
		for pin in pins.keys():
			var cid := str(pins[pin])
			if cid.is_empty() or (hidden is Array and (hidden as Array).has(pin)):
				continue
			var shape := str(db.components.get(cid, {}).get("shape", ContentDB.SHAPE_NONE))
			if shape.is_empty() or shape == ContentDB.SHAPE_NONE:
				continue
			assert_eq(str(shapes.get(pin, "")), shape, "%s: the stock %s on %s wears its class, never a part built by hand" % [id, cid, pin])
		var joints: Dictionary = side.get("joints", {})
		var aims: Dictionary = side.get("aims", {})
		for cid in aims.keys():
			assert_eq(str(joints.get(str(aims[cid]), {}).get("axis", "")), "yaw", "%s: %s aims with a joint that turns about its up axis" % [id, cid])


func test_the_nested_joints_the_bible_asked_for_are_in_the_models() -> void:
	var want := {
		"badger": [["elbow_l", "shoulder_l"], ["wrist_l", "elbow_l"], ["jaw_upper", "wrist_l"], ["jaw_lower", "wrist_l"], ["elbow_r", "shoulder_r"], ["wrist_r", "elbow_r"]],
		"clydesdale": [["head", ""], ["knee_fl", "hip_fl"], ["knee_hr", "hip_hr"], ["ankle_fl", "knee_fl"], ["ankle_hr", "knee_hr"], ["turret_1", "lift_1"], ["elev_1", "turret_1"], ["turret_5", "lift_5"], ["elev_5", "turret_5"]],
		"baboon": [["waist", ""], ["shoulder_l", "waist"], ["elbow_l", "shoulder_l"], ["wrist_l", "elbow_l"], ["ankle_l", "knee_l"], ["knee_l", "hip_l"], ["elev_r", "waist"]],
		"polar_bear": [["knee_fl", "hip_fl"], ["ankle_fl", "knee_fl"], ["ankle_hl", "knee_hl"], ["run_l", ""], ["run_r", ""], ["run_fl", ""], ["run_rack", ""], ["shutter_rl", ""], ["louvre_l1", ""], ["louvre_r3", ""], ["louvre_cl1", ""], ["louvre_cr4", ""], ["vent_pop_l", ""]],
		"wild_boar": [["elev", "turret"], ["plow", ""], ["elev_pod", ""]],
		"prairie_dog": [["wheel_fl", "steer_fl"], ["wheel_rl", ""], ["sensor", "chassis"], ["turret", "chassis"]],
		"dingo": [["wheel_fl", "caster_fl"], ["harpoon", "chassis"], ["turret_rack", "chassis"], ["elev_rack", "turret_rack"]],
		"buzzard": [["nacelle_l", ""], ["nacelle_r", ""]],
		"nemesis": [["waist", ""], ["shoulder_r", "waist"], ["elbow_r", "shoulder_r"], ["knee_l", "hip_l"], ["ankle_l", "knee_l"], ["ankle_r", "knee_r"], ["elev_shoulder", "waist"]],
		"ammit": [["waist", ""], ["shoulder_l", "waist"], ["hand_l", "elbow_l"], ["talon_l_out", "hand_l"], ["talon_r_mid", "hand_r"], ["talon_r_in", "hand_r"], ["elbow_l", "shoulder_l"], ["ankle_r", "knee_r"],
			["shoulder_low_r", ""], ["elbow_low_r", "shoulder_low_r"], ["hand_low_r", "elbow_low_r"], ["elev_l", "waist"]],
	}
	for id in want.keys():
		var pair := _rig_for(id)
		var rig: MechRig = pair[0]
		for row in want[id]:
			assert_true(rig.joints.has(row[0]), "%s has joint %s" % [id, row[0]])
			if rig.joints.has(row[0]):
				assert_eq(rig.joint_of(rig.joints[row[0]]), row[1], "%s: %s hangs under '%s'" % [id, row[0], row[1]])
		pair[1].free()
	# The Clydesdale's batteries (Ryan, 11 November): each gun on its elevation, in its turret, on
	# the lift that sinks it, the first battery's and the second's alike.
	var pair := _rig_for("clydesdale")
	var rig: MechRig = pair[0]
	assert_eq(rig.joint_of(rig.hardpoints[1]), "elev_1", "a first-battery gun is on its elevation")
	assert_eq(rig.joint_of(rig.hardpoints[5]), "elev_5", "and a second-battery gun on its own")
	assert_eq(rig.joint_of(rig.joints["elev_1"]), "turret_1", "which nests in the turret")
	assert_eq(rig.joint_of(rig.joints["turret_1"]), "lift_1", "which rides the lift")
	pair[1].free()
	# The Dingo's launcher rides its roof gimbal (Ryan, 29 October): the socket on the elevation, in the yoke that turns.
	pair = _rig_for("dingo")
	rig = pair[0]
	assert_eq(rig.joint_of(rig.hardpoints[1]), "elev_rack", "the Dingo's launcher elevates on its gimbal")
	pair[1].free()
	# The lower pair of the Ammit's arms never swing on a blow; the upper pair do.
	pair = _rig_for("ammit")
	rig = pair[0]
	assert_true(bool(rig.meta["shoulder_l"]["swing"]), "the Ammit's upper arm swings")
	assert_false(bool(rig.meta["shoulder_low_l"]["swing"]), "its planted lower arm does not")
	pair[1].free()


func test_a_form_is_held_while_set_and_let_go_after() -> void:
	# A pose a model holds while its machine carries the status of the same name (the
	# Polar Bear's seal: its guns sink and its irises shut): it turns in when set, no act
	# starts while it turns, held it plays its own acts if it has any and otherwise none that
	# moves a joint it holds, and letting it go brings them home.
	var with_form := ""
	for id in MACHINES:
		if not (MechRig.load_sidecar(id).get("forms", {}) as Dictionary).is_empty():
			with_form = id
			break
	assert_false(with_form.is_empty(), "a model holds a form")
	var pair := _rig_for(with_form)
	var rig: MechRig = pair[0]
	var name := str(rig.forms.keys()[0])
	var held: Dictionary = rig.forms[name]["curves"]
	assert_false(held.is_empty(), "%s: the form holds joints" % with_form)
	var rest := {}
	for jn in held.keys():
		if jn != MechRig.BODY:
			rest[jn] = [(rig.joints[jn] as Node3D).position, (rig.joints[jn] as Node3D).rotation]
	rig.set_form(name, true)
	assert_true(rig.form_held(name), "set, it is held")
	rig.tick(0.1)
	assert_true(rig.choose().is_empty(), "%s: no act starts while the form turns" % with_form)
	rig.tick(float(rig.forms[name]["duration"]) + 0.5)
	for jn in held.keys():
		if jn == MechRig.BODY:
			continue
		var j: Node3D = rig.joints[jn]
		assert_true(j.position.distance_to(rest[jn][0]) > 0.5 or j.rotation.distance_to(rest[jn][1]) > 0.01, "%s: %s has turned to its held pose" % [with_form, jn])
	var own := {}
	for a in rig.forms[name]["acts"]:
		own[str(a["name"])] = true
	for i in range(30):
		var a := rig.choose()
		assert_false(a.is_empty(), "%s: held, it still plays" % with_form)
		if not own.is_empty():
			assert_true(own.has(str(a.get("name", ""))), "%s: held, it plays only the form's own acts (%s)" % [with_form, a.get("name", "?")])
		else:
			for jn in (a.get("tracks", {}) as Dictionary).keys():
				assert_false(held.has(jn), "%s: no act that moves a held joint is chosen (%s keys %s)" % [with_form, a.get("name", "?"), jn])
		rig.last_act = str(a.get("name", ""))
	rig.set_form(name, false)
	assert_false(rig.form_held(name), "let go, it is not held")
	rig.tick(float(rig.forms[name]["duration"]) + 0.3)
	for jn in held.keys():
		if jn == MechRig.BODY:
			continue
		assert_true((rig.joints[jn] as Node3D).position.distance_to(rest[jn][0]) < 0.05, "%s: %s is home once the form is let go" % [with_form, jn])
	var mine := {}
	for a in rig.acts:
		mine[str(a["name"])] = true
	for i in range(20):
		var a := rig.choose()
		assert_true(mine.has(str(a.get("name", ""))), "%s: let go, the machine's own acts are back (%s)" % [with_form, a.get("name", "?")])
		rig.last_act = str(a.get("name", ""))
	pair[1].free()


func test_a_held_form_may_move_the_body_and_its_own_acts_play_over_it() -> void:
	# The sealed Polar Bear hunkers (Ryan, 29 October: "its base pose should be hunkered down
	# in a defensive position"): a form may carry the whole machine with it, and an act of
	# its own plays as an offset over that pose and ends back on it, never on the rest.
	var id := ""
	var name := ""
	for m in MACHINES:
		var forms: Dictionary = MechRig.load_sidecar(m).get("forms", {})
		for f in forms.keys():
			if not (forms[f].get("body", []) as Array).is_empty() and not (forms[f].get("acts", []) as Array).is_empty():
				id = m
				name = str(f)
	assert_false(id.is_empty(), "a model's form moves the body and carries acts of its own")
	var pair := _rig_for(id, 3)
	var rig: MechRig = pair[0]
	var model: Node3D = pair[1]
	var base := model.position
	var base_rot := model.rotation
	rig.set_form(name, true)
	rig.tick(float(rig.forms[name]["duration"]) + 0.5)
	var held := model.position
	assert_true(held.distance_to(base) > 1.0 or model.rotation.distance_to(base_rot) > 0.01, "%s: held, the form moves the body (%s)" % [id, held])
	var a: Dictionary = rig.forms[name]["acts"][0]
	assert_true(rig.play(str(a["name"])), "%s: its own act plays" % id)
	assert_true(rig.in_act(), "and is playing")
	rig.tick(float(a["duration"]) + 2.5)
	assert_false(rig.in_act(), "%s: the act is over" % id)
	assert_true(model.position.distance_to(held) < 0.05, "%s: the act ends back on the held pose (%s, held %s)" % [id, model.position, held])
	rig.set_form(name, false)
	rig.tick(float(rig.forms[name]["duration"]) + 0.5)
	assert_true(model.position.distance_to(base) < 0.05 and model.rotation.distance_to(base_rot) < 0.001, "%s: let go, the body is home" % id)
	pair[1].free()


func test_a_gun_that_runs_in_its_port_kicks_back_along_its_line_and_never_turns() -> void:
	# Ryan, 29 October (the Polar Bear's weapons: "they should only move along their axis of
	# firing, in and out"): a joint given a line runs along it alone; every turn is held to
	# nothing, and a shot kicks it back along the line instead of pitching it.
	var checked := 0
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		var lines := {}
		for jn in (side.get("joints", {}) as Dictionary).keys():
			if (side["joints"][jn].get("slide", []) as Array).size() == 3:
				lines[jn] = side["joints"][jn]["slide"]
		if lines.is_empty():
			continue
		var pair := _rig_for(id, 2)
		var rig: MechRig = pair[0]
		var armed := {}
		for n in rig.hardpoints.keys():
			armed[rig.joint_of(rig.hardpoints[n])] = true
		rig.strike(true)
		rig.tick(0.05)
		for jn in lines.keys():
			var j: Node3D = rig.joints[jn]
			assert_true(j.rotation.is_equal_approx(rig._rest[jn]), "%s: %s never turns, a shot or not" % [id, jn])
			if not armed.has(jn):
				continue
			var line := MechRig.offset_of(Vector3(float(lines[jn][0]), float(lines[jn][1]), float(lines[jn][2])))
			var moved: Vector3 = j.position - rig._rest_pos[jn]
			assert_true(moved.length() > 0.3 and moved.normalized().dot(-line.normalized()) > 0.99, "%s: a shot kicks %s back along its line (%s against %s)" % [id, jn, moved, line])
			checked += 1
		rig.tick(1.0)
		for jn in lines.keys():
			assert_true((rig.joints[jn] as Node3D).position.distance_to(rig.home_position(jn)) < 0.01, "%s: %s runs home after the kick (ajar, where it stands ajar)" % [id, jn])
		pair[1].free()
	assert_true(checked > 0, "a gun that runs in its port is checked")


func test_acts_are_picked_at_random_and_never_twice_running() -> void:
	var pair := _rig_for("clydesdale", 5)
	var rig: MechRig = pair[0]
	var seen := {}
	var last := ""
	for i in range(60):
		var a := rig.choose()
		assert_ne(str(a["name"]), last, "never the same act twice running")
		last = str(a["name"])
		rig.last_act = last
		seen[last] = true
	assert_true(seen.size() >= 3, "the pilot gets round to several acts in sixty picks")
	# Two rigs of one machine on different seeds do not open with the same wait.
	var other := _rig_for("clydesdale", 99)
	assert_ne(rig._wait, (other[0] as MechRig)._wait, "out of step from the first act")
	pair[1].free()
	other[1].free()


func test_an_act_moves_its_joints_and_returns_them_to_rest() -> void:
	var pair := _rig_for("badger", 3)
	var rig: MechRig = pair[0]
	var jaw: Node3D = rig.joints["jaw_upper"]
	var rest := jaw.rotation
	assert_true(rig.play("test_claw"), "the Badger tests its claw")
	var duration := float(rig._current["duration"])
	var open_at := 0.0   # the act's first wide-open key, whatever the content says
	for key in rig._current["tracks"]["jaw_upper"]:
		if float(key[1]) > 30.0:
			open_at = float(key[0])
			break
	rig.tick(open_at + 0.25)   # the servo a moment behind the key
	assert_true(jaw.rotation.x > rest.x + deg_to_rad(30.0), "the fingers lift about the pin to open (%f)" % rad_to_deg(jaw.rotation.x - rest.x))
	assert_true((rig.joints["jaw_lower"] as Node3D).rotation.x < rest.x - deg_to_rad(30.0), "the tines drop")
	assert_true((rig.joints["shoulder_l"] as Node3D).rotation.x > deg_to_rad(10.0), "the boom lifts the claw")
	assert_true(is_zero_approx((rig.joints["shoulder_r"] as Node3D).rotation.x), "the other boom stands")
	rig.tick(duration - open_at + 2.0)   # past the end, and time for the servos to bring it home
	assert_true(jaw.rotation.is_equal_approx(rest), "back at rest after the act ends")
	assert_true(rig._servo.is_empty(), "every part home and still")
	assert_eq(rig.last_act, "test_claw", "remembered, so the next pick differs")
	pair[1].free()


func test_the_curve_runs_on_through_a_key_and_stops_only_to_turn_or_hold() -> void:
	# Ryan, 4 October, the third pass: a bank, a hard stop, a bank, a hard stop.
	var keys := [[1.0, 10.0], [2.0, 20.0], [3.0, 20.0], [4.0, -10.0]]
	var c := MechRig.curve(keys, 5.0)
	var speed := func(t: float) -> float: return (float(MechRig.curve_at(c, t + 0.001)[0]) - float(MechRig.curve_at(c, t - 0.001)[0])) / 0.002
	assert_true(float(speed.call(1.0)) > 5.0, "on its way up through 10 it keeps moving (%f a second)" % float(speed.call(1.0)))
	assert_true(absf(float(speed.call(2.0))) < 0.1, "it stops where it holds")
	assert_true(absf(float(speed.call(4.0))) < 0.1, "and where it turns back")
	var lo := 1e9
	var hi := -1e9
	var t := 0.0
	while t <= 5.0:
		var v := float(MechRig.curve_at(c, t)[0])
		lo = minf(lo, v)
		hi = maxf(hi, v)
		t += 0.01
	assert_true(hi <= 20.0 + 0.001 and lo >= -10.0 - 0.001, "and never runs past a key (%f to %f)" % [lo, hi])
	var cyc := MechRig.cycle_curve([[0.0, 0.0], [0.25, 10.0], [0.5, 20.0], [0.75, 10.0]])
	var across := (float(MechRig.curve_at(cyc, 0.26)[0]) - float(MechRig.curve_at(cyc, 0.24)[0])) / 0.02
	assert_true(across > 5.0, "a cycle runs on through a key too (%f)" % across)
	assert_true(is_equal_approx(float(MechRig.curve_at(cyc, 0.0)[0]), float(MechRig.curve_at(cyc, 0.9999)[0])) or absf(float(MechRig.curve_at(cyc, 0.0)[0]) - float(MechRig.curve_at(cyc, 0.9999)[0])) < 0.05, "and closes on itself")


func test_a_part_carries_its_weight_toward_what_the_act_asks() -> void:
	# The servos: a part lags its key, gives a touch past it, settles, and a heavier machine
	# lags more.
	var lags := []
	for heft in [0.08, 0.26]:
		var pair := _rig_for("clydesdale", 3)
		var rig: MechRig = pair[0]
		rig.heft = heft
		rig.acts = [{"name": "probe", "duration": 3.0, "ease": "smooth", "tracks": {"turret_1": [[0.6, 0.0, 30.0, 0.0, 0.0, 0.0, 0.0], [2.0, 0.0, 30.0, 0.0, 0.0, 0.0, 0.0]]}, "body": [], "glow": []}]
		var tr: Node3D = rig.joints["turret_1"]
		assert_true(rig.play("probe"), "a probe act")
		rig.tick(0.3)
		var wanted := float(MechRig.sample(rig.acts[0]["tracks"]["turret_1"], 0.3, 3.0)[1])
		var got := rad_to_deg(tr.rotation.y)
		assert_true(got < wanted and got > 0.0, "halfway up the ramp it is on its way but behind (%f of %f)" % [got, wanted])
		lags.append(wanted - got)
		var most := 0.0
		for i in range(90):
			rig.tick(1.0 / 60.0)
			most = maxf(most, rad_to_deg(tr.rotation.y))
		assert_true(most > 30.0 and most < 31.5, "it gives a touch past its mark and no more (%f)" % most)
		rig.tick(4.0)
		assert_true(is_zero_approx(tr.rotation.y), "and settles home once the act is over")
		pair[1].free()
	assert_true(float(lags[1]) > float(lags[0]) * 1.5, "a heavy machine lags its pilot more than a light one (%f against %f)" % [lags[1], lags[0]])


func test_every_turret_turns_slowly_not_far_and_pauses_before_turning_back() -> void:
	# Ryan, 4 October, the third pass: turret swivels too fast and wild. The builder refuses
	# an act that breaks the rule; this reads the sidecars to be sure none slipped through. A
	# turret whose model names a wider reach (the sidecar's `reach`: the Giant Petrel's quarters
	# swing to dead astern; Ryan, 14 November) is held to that, its slew and pause still the rule's.
	var slew := 35.0
	var pause := 0.6
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		for a in side.get("acts", []):
			for jn in a.get("tracks", {}).keys():
				if not str(jn).begins_with("turret"):
					continue
				var axis := ["pitch", "yaw", "roll"].find(str(side["joints"][jn]["axis"]))
				var reach := float(side["joints"][jn].get("reach", 70.0))
				assert_true(reach <= 180.0, "%s: %s's reach is at most a half turn" % [id, jn])
				var pts: Array = []
				if float(a["tracks"][jn][0][0]) > 0.0:
					pts.append([0.0, 0.0])
				for key in a["tracks"][jn]:
					pts.append([float(key[0]), float(key[1 + axis])])
				if float(pts[pts.size() - 1][0]) < float(a["duration"]):
					pts.append([float(a["duration"]), 0.0])
				var last_dir := 0
				var last_end := 0.0
				for i in range(pts.size()):
					assert_true(absf(float(pts[i][1])) <= reach + 0.001, "%s %s: %s within %s degrees" % [id, a["name"], jn, reach])
					if i == 0 or float(pts[i][1]) == float(pts[i - 1][1]):
						continue
					var dt := float(pts[i][0]) - float(pts[i - 1][0])
					var rate := absf(float(pts[i][1]) - float(pts[i - 1][1])) / dt
					assert_true(rate <= slew + 0.001, "%s %s: %s at %s degrees a second" % [id, a["name"], jn, rate])
					var dir := 1 if float(pts[i][1]) > float(pts[i - 1][1]) else -1
					if last_dir != 0 and dir != last_dir:
						assert_true(float(pts[i - 1][0]) - last_end >= pause - 0.001, "%s %s: %s pauses before turning back" % [id, a["name"], jn])
					last_dir = dir
					last_end = float(pts[i][0])


func test_a_body_track_moves_the_model_and_a_wheel_never_unwinds() -> void:
	var pair := _rig_for("prairie_dog", 2)
	var rig: MechRig = pair[0]
	var model: Node3D = pair[1]
	var base := model.position
	assert_true(rig.play("rev"), "the Prairie Dog revs")
	rig.tick(1.0)
	assert_true(model.position.z < base.z - 2.0, "it rolls forward (toward -z) a few units")
	var wheel: Node3D = rig.joints["wheel_fl"]
	assert_true(wheel.rotation.x < -1.0, "the wheels spin forward")
	var chassis: Node3D = rig.joints["chassis"]
	assert_true(chassis.position.y < rig._rest_pos["chassis"].y, "the body squats on its wheels")
	rig.tick(1.5)
	assert_true(wheel.rotation.x < -5.0 or is_equal_approx(fmod(wheel.rotation.x, TAU), 0.0), "at the end the wheel sits a whole turn on, not unwound")
	rig.tick(float(rig._current.get("duration", 0.0)) if not rig._current.is_empty() else 1.0)
	assert_true(model.position.is_equal_approx(base), "and the car is back on its hex")
	pair[1].free()


func test_a_whole_turn_in_an_act_comes_home_without_unwinding() -> void:
	# Ryan, 5 October: a loop, a barrel roll and a spin on the spot end a whole turn on, which
	# is the pose they started in; the rig takes every angle the short way home at the act's
	# end, so nothing spins back round.
	var pair := _rig_for("dingo", 2)
	var rig: MechRig = pair[0]
	var model: Node3D = pair[1]
	rig.acts = [{"name": "probe", "duration": 2.0, "ease": "smooth", "tracks": {}, "body": [[1.5, 0.0, 0.0, 0.0, 360.0, 0.0, 0.0], [2.0, 0.0, 0.0, 0.0, 360.0, 0.0, 0.0]], "glow": []}]
	assert_true(rig.play("probe"), "a whole turn")
	rig.tick(1.0)
	assert_true(rad_to_deg(model.rotation.y) > 90.0, "it is on its way round (%f)" % rad_to_deg(model.rotation.y))
	rig.tick(1.0)
	var most := 0.0
	for i in range(120):
		rig.tick(1.0 / 60.0)
		most = maxf(most, absf(rad_to_deg(model.rotation.y)))
	assert_true(most < 20.0, "and from the act's end it settles where it began, never turning back (%f)" % most)
	assert_true(is_zero_approx(model.rotation.y), "home")
	pair[1].free()


func test_an_act_may_be_for_one_place_and_may_carry_its_own_heft() -> void:
	# Ryan, 5 October: the Kite's loop and circle are for the map; a blow wants to be
	# sharper than a heavy machine's weight allows.
	var pair := _rig_for("clydesdale", 4)
	var rig: MechRig = pair[0]
	rig.acts = [{"name": "map_only", "duration": 1.0, "tracks": {}, "body": [], "glow": [], "places": ["map"]},
				{"name": "anywhere", "duration": 1.0, "tracks": {}, "body": [], "glow": []}]
	rig.place = "skirmish"
	for i in range(12):
		rig.last_act = ""
		assert_eq(str(rig.choose().get("name", "")), "anywhere", "the skirmish never picks a map-only act")
	rig.place = "map"
	var seen := {}
	for i in range(40):
		rig.last_act = ""
		seen[str(rig.choose().get("name", ""))] = true
	assert_true(seen.has("map_only") and seen.has("anywhere"), "the map picks either")
	var lags := []
	for h in [-1.0, 0.05]:
		rig.acts = [{"name": "probe", "duration": 3.0, "ease": "smooth", "tracks": {"turret_1": [[0.6, 0.0, 30.0, 0.0, 0.0, 0.0, 0.0], [2.0, 0.0, 30.0, 0.0, 0.0, 0.0, 0.0]]}, "body": [], "glow": []}]
		if h > 0.0:
			rig.acts[0]["heft"] = h
		rig.tick(5.0)
		assert_true(rig.play("probe"), "a probe")
		rig.tick(0.4)
		lags.append(30.0 * 0.4 / 0.6 - rad_to_deg((rig.joints["turret_1"] as Node3D).rotation.y))
		rig.tick(3.0)
	assert_true(float(lags[1]) < float(lags[0]) * 0.5, "an act with its own light heft follows its keys more closely (%f against %f)" % [lags[1], lags[0]])
	pair[1].free()


func test_limits_hold_a_one_way_mount_and_the_strike_kicks_the_way_it_may() -> void:
	var pair := _rig_for("clydesdale", 4)
	var rig: MechRig = pair[0]
	# A shot kicks the joint carrying its gun (the Clydesdale's elevations since its batteries, 11
	# November), toward the side its limits allow; no model's mount turns one way alone since its
	# outward-only turrets went, so two elevations are held to one side here.
	rig.meta["elev_1"]["limits"] = {"pitch": [0.0, 110.0]}
	rig.meta["elev_2"]["limits"] = {"pitch": [-110.0, 0.0]}
	var tr: Node3D = rig.joints["elev_2"]
	rig.strike(true)
	rig.tick(0.05)
	assert_true(tr.rotation.x < 0.0, "a mount that turns only down kicks down on a shot (%f)" % tr.rotation.x)
	var tl: Node3D = rig.joints["elev_1"]
	assert_true(tl.rotation.x > 0.0, "and one that turns only up, up")
	assert_true((rig.joints["elev_3"] as Node3D).rotation.x != 0.0, "a gun's elevation kicks")
	assert_true(is_zero_approx((rig.joints["hip_fl"] as Node3D).rotation.x), "a leg does not")
	rig.tick(1.0)
	assert_true(is_zero_approx(tr.rotation.x), "settled")
	rig.strike(false)
	rig.tick(0.1)
	assert_true(is_zero_approx(tr.rotation.x), "a melee blow leaves a gun's mount alone")
	assert_true(is_zero_approx((rig.joints["knee_fl"] as Node3D).rotation.x), "and the legs")
	pair[1].free()
	pair = _rig_for("badger", 4)
	rig = pair[0]
	rig.strike(false)
	rig.tick(0.1)
	assert_true((rig.joints["shoulder_l"] as Node3D).rotation.x < -deg_to_rad(10.0), "the Badger's booms slam on a blow")
	assert_true(is_zero_approx((rig.joints["elbow_l"] as Node3D).rotation.x), "from the shoulder; the elbow holds")
	pair[1].free()


func test_a_model_without_a_sidecar_has_no_acts_and_stands_still() -> void:
	var pair := _rig_for("shapes/barrel_minerva")
	var rig: MechRig = pair[0]
	assert_true(rig.acts.is_empty(), "a shape has no acts")
	assert_false(rig.alive(), "nothing to tick")
	rig.tick(1.0)
	pair[1].free()
	assert_eq(MechRig.load_sidecar("no_such_model"), {}, "no file, no sidecar")


func test_the_debug_switch_names_one_act() -> void:
	var pair := _rig_for("nemesis", 7)
	var rig: MechRig = pair[0]
	var named := str(rig.acts[rig.acts.size() - 1]["name"])   # whichever act the model lists last
	rig.debug = named
	for i in range(5):
		assert_eq(str(rig.choose()["name"]), named, "the named act, every time")
	rig.debug = "1"
	rig.last_act = named
	assert_ne(str(rig.choose()["name"]), named, "'1' is every act, back to back, still never twice running")
	pair[1].free()


func _drive(rig: MechRig, speed: float, seconds: float, aim: float = 0.0, turn: float = 0.0, step: float = 1.0 / 60.0) -> void:
	var t := 0.0
	while t < seconds:
		rig.drive(speed, aim, turn, step)
		t += step


func test_cycle_sampling_wraps() -> void:
	var keys := [[0.0, 14.0], [0.5, -14.0], [1.0, 14.0]]
	assert_eq(MechRig.sample_cycle(keys, 0.0), [14.0], "the start")
	assert_eq(MechRig.sample_cycle(keys, 0.5), [-14.0], "half way")
	assert_eq(MechRig.sample_cycle(keys, 1.0), [14.0], "a whole stride is the start again")
	assert_eq(MechRig.sample_cycle(keys, 1.5), [-14.0], "and it wraps")
	var partial := [[0.5, 0.0], [0.7, -30.0], [1.0, 0.0]]
	assert_eq(MechRig.sample_cycle(partial, 0.2), [0.0], "before the first key the track holds the last")
	var mid: float = MechRig.sample_cycle(partial, 0.6)[0]
	assert_true(mid < -5.0 and mid > -30.0, "between keys (%f)" % mid)


func test_a_long_frame_never_runs_every_wait_out_at_once() -> void:
	# A hitch (a screen opening) spends a frame's worth of the gap, not the whole of it, so
	# machines waiting different times still start at different times (Ryan, 7 October).
	var a := _rig_for("clydesdale", 3)
	var b := _rig_for("clydesdale", 4)
	var act := {"name": "nod", "duration": 0.5, "tracks": {}, "body": [], "glow": []}
	for r in [a[0], b[0]]:
		(r as MechRig).debug = ""
		(r as MechRig).acts = [act]
	(a[0] as MechRig)._wait = 1.0
	(b[0] as MechRig)._wait = 3.0
	(a[0] as MechRig).tick(5.0)
	(b[0] as MechRig).tick(5.0)
	assert_false((a[0] as MechRig).in_act() or (b[0] as MechRig).in_act(), "a five-second frame starts neither")
	for i in range(66):
		(a[0] as MechRig).tick(1.0 / 60.0)
		(b[0] as MechRig).tick(1.0 / 60.0)
	assert_true((a[0] as MechRig).in_act(), "the shorter wait runs out in ordinary frames")
	assert_false((b[0] as MechRig).in_act(), "and the longer one is still waiting")
	a[1].free()
	b[1].free()


func test_machines_set_up_together_open_one_after_another() -> void:
	# A screen's machines open in turn, OPEN_GAP apart at least, not at random over the first
	# gap (Ryan, 7 October). A place of the test's own; the debug switch off.
	MechRig._opening.erase("open_test")
	var waits := []
	var opens := []
	var models := []
	for i in range(4):
		var model: Node3D = (load("res://art/models/clydesdale.glb") as PackedScene).instantiate()
		var rig := MechRig.new()
		rig.place = "open_test"
		rig.setup(model, "clydesdale", model, i)
		models.append(model)
		if not rig.debug.is_empty():
			break
		waits.append(rig._wait)
		opens.append(Time.get_ticks_msec() / 1000.0 + rig._wait)   # when it opens, on the clock the spacing keeps
	for i in range(1, opens.size()):
		assert_true(float(opens[i]) >= float(opens[i - 1]) + MechRig.OPEN_GAP - 0.01, "each opens after the last (%s)" % str(opens))
	if not waits.is_empty():
		assert_true(float(waits[0]) <= MechRig.OPEN_FIRST, "and the first soon after the screen loads")
	MechRig._opening.erase("open_test")
	for m in models:
		m.free()


## A node's place in the model's own frame (the model root's parent), composed by hand: the
## models are never in a tree here.
func _in_model(node: Node3D, model: Node3D) -> Transform3D:
	var xf := node.transform
	var p := node.get_parent()
	while p != null and p != model.get_parent():
		xf = (p as Node3D).transform * xf
		p = p.get_parent()
	return xf


func test_a_walker_steps_and_settles() -> void:
	var pair := _rig_for("clydesdale", 2)
	var rig: MechRig = pair[0]
	var model: Node3D = pair[1]
	assert_true(not rig.gait.is_empty(), "the Clydesdale has a gait")
	var fl: Node3D = rig.joints["hip_fl"]
	var fr: Node3D = rig.joints["hip_fr"]
	_drive(rig, rig.top_speed, 0.6)
	assert_true(rig.moving, "under way")
	var widest := 0.0
	var left_leads := false
	var right_leads := false
	for i in range(60):
		rig.drive(rig.top_speed, 0.0, 0.0, 1.0 / 60.0)
		widest = maxf(widest, absf(fl.rotation.x))
		# Each side's hip swings ahead of the other's in turn (a hip need not swing either side
		# of its rest: the Clydesdale's, under forward knees, stays mostly ahead of it).
		left_leads = left_leads or fl.rotation.x - fr.rotation.x > deg_to_rad(10.0)
		right_leads = right_leads or fr.rotation.x - fl.rotation.x > deg_to_rad(10.0)
	assert_true(widest > deg_to_rad(10.0), "the hips swing (%f at the widest)" % rad_to_deg(widest))
	assert_true(left_leads and right_leads, "the other pair is half a stride behind")
	_drive(rig, 0.0, 1.0)
	assert_false(rig.moving, "stopped")
	assert_true(is_zero_approx(fl.rotation.x) and is_zero_approx(fr.rotation.x), "the legs settle to rest")
	assert_true(model.position.is_equal_approx(rig._body_rest_pos), "and the body")
	pair[1].free()


func test_a_walker_plants_its_feet_and_never_rolls() -> void:
	# Ryan, 4 October, the third pass: stomp and plod; the weight believable, no weight shift
	# side to side. A foot down on the ground stays where it was put while the body travels
	# over it, and the body never rolls.
	for id in ["clydesdale", "polar_bear", "nemesis", "baboon", "ammit"]:
		var pair := _rig_for(id, 2)
		var rig: MechRig = pair[0]
		var model: Node3D = pair[1]
		for key in rig.gait.get("body", []):
			assert_true(is_zero_approx(float(key[6])), "%s: the walk's body never rolls" % id)
		var foot: Node3D = rig.joints["ankle_l" if rig.joints.has("ankle_l") else "ankle_fl"]
		var rest_h := _in_model(foot, model).origin.y
		_drive(rig, rig.top_speed, 1.0)   # up to speed and the gait fully in
		var lowest := 1e9
		var samples: Array = []
		var stride := float(rig.gait["stride"])
		var t := 0.0
		while t < stride / rig.top_speed:
			rig.drive(rig.top_speed, 0.0, 0.0, 1.0 / 240.0)
			var at := _in_model(foot, model).origin
			samples.append([at.y, at.z - rig._dist])   # forward is -z: the ground under it runs back as the model travels
			lowest = minf(lowest, at.y)
			t += 1.0 / 240.0
		# Each run of samples with the foot down is one stance (a stride's window can catch the
		# end of one and the start of the next, a stride apart).
		var runs: Array = [[]]
		for sm in samples:
			if float(sm[0]) < lowest + 0.3:
				(runs[runs.size() - 1] as Array).append(float(sm[1]))
			elif not (runs[runs.size() - 1] as Array).is_empty():
				runs.append([])
		# Its share down over the gait's whole cycle, however many steps it takes in it (the
		# Ammit's legs take two to a cycle, its hands three: Ryan, 5 October, the sixth notes).
		var down := 0
		for run in runs:
			down += (run as Array).size()
			if (run as Array).size() >= 5:
				var slide: float = (run as Array).max() - (run as Array).min()
				assert_true(slide < 0.8, "%s: a planted foot stays put while the body passes over it (%f units)" % [id, slide])
		assert_true(down > samples.size() / 3, "%s: the foot is down for a good share of the stride (%d of %d)" % [id, down, samples.size()])
		assert_true(absf(lowest - rest_h) < 0.6, "%s: down on the ground where it stands at rest (%f against %f)" % [id, lowest, rest_h])
		pair[1].free()


func test_the_debug_walk_runs_at_the_machine_s_own_pace_on_the_map() -> void:
	# The hangar's Walk and RIFTGATE_MOVE_DEBUG ran every machine at one pace, two or three
	# times a walker's on the map. A machine's full speed is its step on the map over the
	# map's time for its move.
	var fit := Map3D.fit_for("heavy")
	var expect := sqrt(3.0) * 100.0 / (2.0 * fit) / BattleMapView.mech_seconds_per_hex(2.0)
	assert_true(is_equal_approx(MechRig.map_speed(100.0, 2, fit), expect), "a slow walker's pace")
	assert_true(MechRig.map_speed(100.0, 5, fit) > MechRig.map_speed(100.0, 2, fit) * 4.0, "a 5 runs four and a half times a 2")
	# Ryan, 5 October: the moves of 2 and 3 slower than the third pass's pace, 4 and 5 faster
	# (keyed by hexes since 28 October, every machine at the pace it had).
	assert_true(BattleMapView.mech_seconds_per_hex(2.0) > 1.38 and BattleMapView.mech_seconds_per_hex(3.0) > 0.92, "the 2s and 3s plod slower")
	assert_true(BattleMapView.mech_seconds_per_hex(4.0) < 0.69 and BattleMapView.mech_seconds_per_hex(5.0) < 0.55, "the 4s and 5s run faster")
	assert_true(is_equal_approx(BattleMapView.mech_seconds_per_hex(3.5), lerpf(BattleMapView.mech_seconds_per_hex(3.0), BattleMapView.mech_seconds_per_hex(4.0), 0.5)), "straight between the keys")
	assert_true(MechRig.map_speed(100.0, 5, Map3D.fit_for("light")) > MechRig.map_speed(100.0, 5, Map3D.fit_for("assault")), "a light machine is drawn smaller, so a hex is more of itself")
	var pair := _rig_for("polar_bear", 2)
	var rig: MechRig = pair[0]
	rig.top_speed = 64.0
	rig.debug_move = true
	rig.tick(0.5)
	assert_true(absf(rig._speed - 64.0) < 1.0, "the debug drive runs at the machine's own pace (%f)" % rig._speed)
	pair[1].free()


func test_wheels_spin_by_radius_and_casters_aim_along_the_travel() -> void:
	var pair := _rig_for("dingo", 2)
	var rig: MechRig = pair[0]
	var wheel: Node3D = rig.joints["wheel_fl"]
	var caster: Node3D = rig.joints["caster_fl"]
	_drive(rig, 100.0, 2.0, deg_to_rad(80.0))   # strafing left
	var r := float(rig.gait["wheels"]["wheel_fl"])
	var turns := rig._dist / (TAU * r)
	assert_true(turns > 2.0, "a couple of turns in two seconds at that radius (%f)" % turns)
	var expect := -fposmod(rig._dist / r, TAU)
	assert_true(absf(wrapf(wheel.rotation.x - expect, -PI, PI)) < 0.01, "the wheel's angle is the distance over its radius, forward negative")
	assert_true(absf(caster.rotation.y - deg_to_rad(80.0)) < deg_to_rad(2.0), "the casters point along the travel (%f)" % rad_to_deg(caster.rotation.y))
	_drive(rig, 100.0, 1.0, deg_to_rad(120.0))
	assert_true(absf(caster.rotation.y - deg_to_rad(85.0)) < deg_to_rad(1.0), "and stop at their limit")
	pair[1].free()
	pair = _rig_for("prairie_dog", 2)
	rig = pair[0]
	var steer: Node3D = rig.joints["steer_fl"]
	_drive(rig, 200.0, 1.0, 0.0, 1.0)   # turning left at a radian a second
	assert_true(steer.rotation.y > deg_to_rad(5.0), "the fronts steer into the turn (%f)" % rad_to_deg(steer.rotation.y))
	assert_true(is_zero_approx((rig.joints["wheel_rl"] as Node3D).rotation.y), "the rears do not steer")
	pair[1].free()


func test_held_offsets_rock_and_bank() -> void:
	var pair := _rig_for("badger", 2)
	var rig: MechRig = pair[0]
	var model: Node3D = pair[1]
	var sh: Node3D = rig.joints["shoulder_l"]
	_drive(rig, MechRig.MOVE_REF_SPEED, 0.1)
	assert_true(model.rotation.x > deg_to_rad(1.5), "pulling away rocks the nose up (%f)" % rad_to_deg(model.rotation.x))
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.0)
	var held := float(rig.gait["hold"]["shoulder_l"][0])
	assert_true(absf(sh.rotation.x - deg_to_rad(held)) < deg_to_rad(0.5), "the boom holds the claw clear while driving (%s degrees)" % held)
	assert_true(absf(model.rotation.x) < deg_to_rad(1.0), "level once up to speed")
	_drive(rig, 0.0, 0.1)
	assert_true(model.rotation.x < -deg_to_rad(1.5), "stopping dips it")
	_drive(rig, 0.0, 1.5)
	assert_true(is_zero_approx(sh.rotation.x) and absf(model.rotation.x) < 0.001, "settled")
	pair[1].free()
	pair = _rig_for("buzzard", 2)
	rig = pair[0]
	model = pair[1]
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.5, 0.0, 1.0)   # a left turn
	assert_true(model.rotation.z > deg_to_rad(5.0), "a flyer banks into a left turn, the left wing down (%f)" % rad_to_deg(model.rotation.z))
	assert_true((rig.joints["nacelle_l"] as Node3D).rotation.x < -deg_to_rad(5.0), "the nacelles tilt forward under way")
	pair[1].free()
	pair = _rig_for("clydesdale", 2)
	rig = pair[0]
	assert_eq(float(rig.move.get("bank", 0.0)), 0.0, "a walker never banks")
	var sway := 0.0
	for key in rig.gait.get("body", []):
		sway = maxf(sway, absf(float(key[6])))
	var widest := 0.0
	for i in range(90):
		rig.drive(MechRig.MOVE_REF_SPEED, 0.0, 1.0, 1.0 / 60.0)
		widest = maxf(widest, absf(pair[1].rotation.z))
	assert_true(widest <= deg_to_rad(sway) + 0.001, "through a hard turn it only rolls its own sway (%f, sway %f)" % [rad_to_deg(widest), sway])
	pair[1].free()


func test_every_gait_names_joints_and_parts_the_model_has() -> void:
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		var g: Dictionary = side.get("gait", {})
		var pair := _rig_for(id)
		var rig: MechRig = pair[0]
		for d in ["tracks", "wheels", "steer", "aim", "hold"]:
			for jn in g.get(d, {}).keys():
				assert_true(rig.joints.has(jn), "%s: the gait's %s names joint %s" % [id, d, jn])
		for jn in g.get("tracks", {}).keys():
			var lim: Dictionary = side["joints"][jn].get("limits", {})
			for key in g["tracks"][jn]["keys"]:
				var deg := Vector3(float(key[1]), float(key[2]), float(key[3]))
				assert_eq(MechRig.clamp_degrees(deg, lim), deg, "%s: the stride keeps %s inside its limits" % [id, jn])
		for part in g.get("treads", {}).get("parts", []):
			var found := false
			for mi in pair[1].find_children("*", "MeshInstance3D", true, false):
				if MechRig.labelled(str(mi.name), str(part)):
					found = true
			assert_true(found, "%s: a tread mesh named %s" % [id, part])
		pair[1].free()
	assert_true(MechRig.labelled("tread_001", "tread"), "the importer's numbering is the same label")
	assert_false(MechRig.labelled("tread_deck", "tread"), "another label is not")


func test_a_pilot_on_the_move_starts_no_act() -> void:
	var pair := _rig_for("nemesis", 3)
	var rig: MechRig = pair[0]
	rig.debug = "1"
	for i in range(120):
		rig.drive(MechRig.MOVE_REF_SPEED, 0.0, 0.0, 1.0 / 60.0)
		rig.tick(1.0 / 60.0)
	assert_eq(rig.last_act, "", "two seconds under way with the debug switch on and no act began")
	_drive(rig, 0.0, 1.0)
	for i in range(8 * 60):   # longer than the longest gap between acts
		rig.tick(1.0 / 60.0)
	assert_ne(rig.last_act, "", "standing again, the acts resume")
	pair[1].free()


func test_a_turret_turns_with_the_hull_on_the_move() -> void:
	# Ryan, 4 October, the third pass: holding the aim was not worth the complexity.
	for id in ["wild_boar", "prairie_dog"]:
		var pair := _rig_for(id, 2)
		var rig: MechRig = pair[0]
		assert_false(rig.gait.has("hold_aim"), "%s: no held aim in the sidecar" % id)
		_drive(rig, MechRig.MOVE_REF_SPEED, 0.5, 0.0, 1.0)   # half a second turning left at a radian a second
		assert_true(is_zero_approx((rig.joints["turret"] as Node3D).rotation.y), "%s: the turret stays with the hull through a turn" % id)
		pair[1].free()


func test_a_slide_drifts_the_body_off_its_path() -> void:
	var pair := _rig_for("dingo", 2)
	var rig: MechRig = pair[0]
	var model: Node3D = pair[1]
	var slide := float(rig.move.get("slide", 0.0))
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.0, deg_to_rad(90.0))   # a step square to the left of its facing
	assert_true(model.position.x > 0.8 * slide * MechRig.DRIFT_UNITS, "the body sits off the path on the outside, to the right (%f)" % model.position.x)
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.5, 0.0)
	assert_true(absf(model.position.x) < 0.3, "back over its path once the travel is straight ahead")
	pair[1].free()
	pair = _rig_for("clydesdale", 2)
	rig = pair[0]
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.0, deg_to_rad(90.0))
	assert_true(is_zero_approx(pair[1].position.x), "a machine with no slide never drifts")
	pair[1].free()


func test_steering_eases_in_and_a_gait_starts_in_another() -> void:
	# Ryan, 7 October, the nineteenth notes: the Prairie Dog's front wheels jumped from straight to
	# full lock (the gain was read per degree a second); the Clydesdale took off straight into
	# its gallop. A knuckle now comes round on a servo, eased toward its limit, and a gait can
	# name an option it starts and stops in.
	var pair := _rig_for("prairie_dog", 2)
	var rig: MechRig = pair[0]
	var steer: Node3D = rig.joints["steer_fl"]
	var last := steer.rotation_degrees.y
	var worst := 0.0
	for i in range(30):
		rig.drive(200.0, 0.0, 3.0, 1.0 / 60.0)   # a hard left turn, all at once
		worst = maxf(worst, absf(steer.rotation_degrees.y - last))
		last = steer.rotation_degrees.y
	assert_true(worst < 6.0, "no jump to full lock: at most %f degrees a frame" % worst)
	assert_true(last > 20.0 and last < 32.0, "and it comes round toward full lock (%f)" % last)
	pair[1].free()
	pair = _rig_for("clydesdale", 2)
	rig = pair[0]
	rig.top_speed = 66.0
	for i in range(60):
		rig.drive(6.0, 0.0, 0.0, 1.0 / 60.0)
	assert_true(rig.start_weight() > 0.99, "barely moving, it trots (%f of it)" % rig.start_weight())
	for i in range(30):
		rig.drive(66.0, 0.0, 0.0, 1.0 / 60.0)
	assert_true(rig.changing(), "at full speed off the mark it plays the stride it changes gait in (the twenty-second notes)")
	for i in range(150):
		rig.drive(66.0, 0.0, 0.0, 1.0 / 60.0)
	assert_true(not rig.changing() and rig.start_weight() < 0.01, "then it gallops (%f trot)" % rig.start_weight())
	pair[1].free()


## The most each leg joint turns in a frame over `frames` frames of a run from a standstill
## to 66 units a second over 1.4 s, counted from `after`.
func _leg_turns(rig: MechRig, frames: int, after: int) -> Dictionary:
	rig.top_speed = 66.0
	var out := {}
	var last := {}
	for i in range(frames):
		rig.drive(minf(66.0, 66.0 * i / 60.0 / 1.4), 0.0, 0.0, 1.0 / 60.0)
		for l in ["fl", "fr", "hl", "hr"]:
			for j in ["hip_", "knee_", "ankle_"]:
				var v := (rig._gait_rot.get(j + l, Vector3.ZERO) as Vector3).x
				if i > after and last.has(j + l):
					out[j + l] = maxf(float(out.get(j + l, 0.0)), absf(v - float(last[j + l])))
				last[j + l] = v
	return out


func test_changing_gait_never_flicks_a_leg() -> void:
	# Ryan, 7 October, the twenty-second notes: off the mark the Clydesdale's trot crossfaded into
	# its gallop wherever each leg was, and a hoof's third step came out fast and short. Its
	# change of gait is now a stride worked out foot by foot, so no leg joint turns faster in a
	# frame than the faster of its two gaits run steadily at that pace.
	var pair := _rig_for("clydesdale", 2)
	var start := _leg_turns(pair[0], 240, 0)
	pair[1].free()
	pair = _rig_for("clydesdale", 2)
	var gallop := _leg_turns(pair[0], 360, 240)
	pair[1].free()
	pair = _rig_for("clydesdale", 2)
	(pair[0] as MechRig).use_gait((pair[0] as MechRig).gait_options["trot"])
	var trot := _leg_turns(pair[0], 360, 120)
	pair[1].free()
	for name in start.keys():
		var most := maxf(float(gallop[name]), float(trot[name]))
		assert_true(float(start[name]) <= most * 1.05, "%s turns at most %.1f degrees a frame setting off (%.1f; the gaits %.1f and %.1f)" % [name, most, start[name], gallop[name], trot[name]])


func test_turning_in_place_steps_the_legs_round_and_nothing_banks_standing() -> void:
	# Ryan, 7 October, the twentieth notes: a machine turns onto its way before it sets off, so a
	# walker turning on the spot steps round rather than sliding on its feet, and a flyer yawing
	# in place keeps level.
	var pair := _rig_for("clydesdale", 2)
	var rig: MechRig = pair[0]
	var d0 := rig._dist
	for i in range(60):
		rig.drive(0.0, 0.0, 1.5, 1.0 / 60.0)
	assert_true(rig.moving and rig._dist - d0 > 10.0, "it steps as it turns (%f units of stride)" % (rig._dist - d0))
	assert_true(rig._dist - d0 <= MechRig.PIVOT_CAP * rig.top_speed + 0.01, "never faster than it walks, well under (%f in a second)" % (rig._dist - d0))
	for i in range(120):
		rig.drive(0.0, 0.0, 0.05, 1.0 / 60.0)
	assert_true(not rig.moving, "a slow settle is not a step")
	pair[1].free()
	pair = _rig_for("buzzard", 2)
	rig = pair[0]
	for i in range(60):
		rig.drive(0.0, 0.0, 1.5, 1.0 / 60.0)
	assert_true(absf(rig._bank) < 0.5, "a flyer yawing in place does not bank (%f)" % rig._bank)
	for i in range(60):
		rig.drive(150.0, 0.0, 1.5, 1.0 / 60.0)
	assert_true(absf(rig._bank) > 20.0, "and banks at speed (%f)" % rig._bank)
	pair[1].free()


func test_the_hovercraft_have_acts_and_cornering_numbers() -> void:
	for id in ["stingray", "puffin"]:
		var side := MechRig.load_sidecar(id)
		assert_true(side.get("acts", []).size() >= 3, "%s has several acts" % id)
	# Ryan, 5 October: both oversteer through corners, like the Dingo; the Stingray faces its
	# heading (no longer a helicopter holding its final facing) and noses down into its travel.
	# Ryan, 3 November: the Puffin, "more speedboat-ey now", banks a little in its turns (the fifth
	# notes had kept it flat), far less than the jets.
	var puffin: Dictionary = MechRig.load_sidecar("puffin")["move"]
	assert_true(float(puffin.get("bank", 0.0)) > 0.0 and float(puffin.get("bank", 0.0)) < 20.0 and float(puffin.get("oversteer", 0.0)) > 0.0, "the Puffin oversteers and banks a little")
	var stingray: Dictionary = MechRig.load_sidecar("stingray")["move"]
	assert_true(float(stingray.get("oversteer", 0.0)) > 0.0 and is_zero_approx(float(stingray.get("strafe", 0.0))), "the Stingray oversteers and faces its heading")
	assert_true(stingray.has("tilt") and float(stingray["tilt"][0]) > 20.0, "and noses down hard into its travel, its fans its propulsion")
	assert_true(float(MechRig.load_sidecar("dingo")["move"].get("oversteer", 0.0)) >= 1.0, "the Dingo oversteers most")


func test_the_stingray_noses_into_its_travel() -> void:
	# The tilt (a helicopter's, 3 October): it leans into its travel by its speed. Ryan, 5
	# October: the Stingray keeps it, harder forward, since its fans are its propulsion.
	var pair := _rig_for("stingray", 2)
	var rig: MechRig = pair[0]
	var model: Node3D = pair[1]
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.5)   # straight ahead
	assert_true(model.rotation.x < -deg_to_rad(15.0), "forward: the nose drops hard (%f)" % rad_to_deg(model.rotation.x))
	assert_true(absf(model.rotation.z) < deg_to_rad(0.5), "level across")
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.5, PI)   # backing
	assert_true(model.rotation.x > deg_to_rad(8.0), "backward: the nose comes up (%f)" % rad_to_deg(model.rotation.x))
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.5, deg_to_rad(90.0))   # slipping left
	# The node's z points backward, so a positive turn about it drops the left side (the same
	# sign the Buzzard's bank into a left turn reads).
	assert_true(model.rotation.z > deg_to_rad(4.0), "left: the left side drops (%f)" % rad_to_deg(model.rotation.z))
	_drive(rig, 0.0, 3.0)
	assert_true((model.rotation - rig._body_rest_rot).length() < deg_to_rad(0.3), "level again on station")
	pair[1].free()
	pair = _rig_for("puffin", 2)
	rig = pair[0]
	assert_true(is_zero_approx(float(rig.move.get("strafe", 0.0))), "the Puffin faces its heading")
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.5, 0.0, 1.0)
	assert_true(pair[1].rotation.z > deg_to_rad(2.0) and pair[1].rotation.z < deg_to_rad(15.0), "and leans a little into a left turn (%f)" % rad_to_deg(pair[1].rotation.z))
	pair[1].free()


func test_an_oversteering_nose_leads_into_the_corner() -> void:
	# Ryan, 5 October: the Dingo lagged through its turns where it should drift into them, and
	# the hovercraft the same: oversteer, not understeer. The nose aims past where the path
	# will head a moment on, into the turn and before it, within a limit; none without
	# oversteer.
	assert_true(Map3D.oversteer_lead(1.0, 1.0) > 0.2, "a path turning left puts the nose further left")
	assert_true(Map3D.oversteer_lead(-1.0, 1.0) < -0.2, "and right, right")
	assert_true(is_equal_approx(Map3D.oversteer_lead(50.0, 1.0), Map3D.oversteer_max(1.0)), "within a limit")
	assert_true(is_equal_approx(Map3D.oversteer_max(0.35), Map3D.OVERSTEER_MAX) and is_equal_approx(Map3D.oversteer_ahead(0.35), Map3D.OVERSTEER_AHEAD) and is_equal_approx(Map3D.oversteer_gain(0.35), Map3D.OVERSTEER_GAIN), "a jet's as it was")
	assert_true(Map3D.oversteer_window(2.0) > Map3D.OVERSTEER_WINDOW and Map3D.oversteer_rate(2.0) < Map3D.OVERSTEER_RATE, "a drifter averages a longer stretch and turns in on a softer spring")
	assert_true(is_zero_approx(Map3D.oversteer_lead(1.0, 0.0)), "nothing without oversteer")
	assert_true(Map3D.oversteer_lead(1.0, 0.5) < Map3D.oversteer_lead(1.0, 1.0), "less for less")


func test_the_map_turns_a_strafing_machine_to_its_final_facing() -> void:
	var heading := 1.0
	var final := -2.0
	assert_true(is_equal_approx(Map3D.facing_target(heading, final, 0.0), heading), "no strafe: the nose follows the heading")
	assert_true(is_equal_approx(Map3D.facing_target(heading, final, 1.0), final), "a full strafe: the nose goes where the move ends facing")
	var yaw_north := Map3D.facing_yaw(1)
	var yaw_south := Map3D.facing_yaw(4)
	assert_true(absf(wrapf(yaw_north - yaw_south, -PI, PI)) > PI - 0.01, "the six facings are yaws, opposite ones half a turn apart")


func test_a_hovercraft_balances_on_its_cushion() -> void:
	# Ryan, 5 October: a hovercraft's idle is not the flyers' bob but a platform on the water,
	# its attitude adjusting every way as the currents change, trying to stay level.
	var a := HoverBalance.new(3)
	var b := HoverBalance.new(3)
	var lo := Vector3(INF, INF, INF)
	var hi := Vector3(-INF, -INF, -INF)
	var moved := 0.0
	var last := Vector3.ZERO
	for i in range(60 * 30):
		a.step(1.0 / 60.0)
		b.step(1.0 / 30.0 if i % 2 == 0 else 0.0)
		var now := Vector3(a.pitch, a.roll, a.heave)
		lo = lo.min(now)
		hi = hi.max(now)
		moved += (now - last).length()
		last = now
	assert_true(is_equal_approx(a.pitch, b.pitch) and is_equal_approx(a.roll, b.roll), "the same seed balances the same whatever the frame rate")
	assert_true(lo.x < -0.02 and hi.x > 0.02 and lo.y < -0.02 and hi.y > 0.02, "it tips every way: nose and tail, either side (%s to %s)" % [lo, hi])
	assert_true(maxf(absf(lo.x), hi.x) < 0.2 and maxf(absf(lo.y), hi.y) < 0.2, "and catches itself near level")
	assert_true(hi.z - lo.z > 0.5, "it rides up and down too")
	assert_true(moved > 1.0, "never still")
	var c := HoverBalance.new(4)
	for i in range(600):
		c.step(1.0 / 60.0)
	assert_false(is_equal_approx(c.pitch, a.pitch), "another seed, another beat")


func test_a_machine_is_drawn_as_big_as_its_class() -> void:
	# Ryan, 5 October: the machines' scale. Every chassis has a class by mass; the map draws
	# a heavier class wider and the skirmish fills more of a slot with it, lightest first.
	var db := ContentDB.load_default()
	var last_fit := 0.0
	var last_fill := 0.0
	for size in ContentDB.SIZES:
		assert_true(Map3D.SIZE_FIT.has(size) and MechView3D.SIZE_FILL.has(size), "%s has a width on the map and a fill in the skirmish" % size)
		assert_true(Map3D.fit_for(size) > last_fit and float(MechView3D.SIZE_FILL[size]) > last_fill, "%s is drawn bigger than the class below it" % size)
		last_fit = Map3D.fit_for(size)
		last_fill = float(MechView3D.SIZE_FILL[size])
	assert_true(is_equal_approx(Map3D.fit_for("no such class"), Map3D.fit_for("heavy")), "an unknown class is drawn as a heavy, the old width")
	for id in db.chassis.keys():
		assert_true(ContentDB.SIZES.has(str(db.chassis[id].get("size", ""))), "%s has a class by mass" % id)
	var extent := Vector2(80.0, 96.0)
	var shown := MechView3D.view_height(extent, 160.0 / 192.0, float(MechView3D.SIZE_FILL["light"]))
	assert_true(is_equal_approx(extent.y / shown, MechView3D.FILL * float(MechView3D.SIZE_FILL["light"])), "a light machine fills that share of its slot's height in the skirmish")
	assert_true(is_equal_approx(MechView3D.view_height(extent, 160.0 / 192.0), extent.y / MechView3D.FILL), "and the codex frames it whole")


func test_a_hovercraft_eases_down_and_takes_no_gust_through_an_act() -> void:
	# Ryan, 5 October, the sixth notes: a gust jerked the Stingray in the middle of its scan. A
	# gust is a push over half a second, never a knock in a frame, and through an act none comes
	# and the balance eases down to a share of itself.
	var free := HoverBalance.new(9)
	var calm := HoverBalance.new(9)
	calm.quiet = true
	var dt := 1.0 / 60.0
	var widest_free := 0.0
	var widest_calm := 0.0
	var worst_jolt := 0.0
	var last := Vector2.ZERO
	var last_rate := Vector2.ZERO
	for i in range(60 * 20):
		free.step(dt)
		calm.step(dt)
		if i > 120:
			widest_free = maxf(widest_free, Vector2(free.pitch, free.roll).length())
			widest_calm = maxf(widest_calm, Vector2(calm.pitch, calm.roll).length())
		var now := Vector2(free.pitch, free.roll)
		var rate := (now - last) / dt
		if i > 2:
			worst_jolt = maxf(worst_jolt, (rate - last_rate).length())
		last = now
		last_rate = rate
	assert_true(widest_calm < widest_free * 0.5, "an act's balance is a share of the free one (%f against %f)" % [widest_calm, widest_free])
	assert_true(worst_jolt < 0.02, "and a gust never changes the attitude's rate at a stroke (%f radians a second in a frame)" % worst_jolt)


func test_a_count_display_lights_its_first_parts_and_a_fall_flares_them() -> void:
	# The Cassowary's capacitor (Ryan, 2 November: "charging up for the sixth hit of its passive"):
	# a cell lights for each counted shot, and the sixth shot, the one that counts double,
	# discharges them, all six flaring and going dark. Headless the cells have no lit surfaces, so
	# their light is read off the display itself.
	var pair := _rig_for("cassowary", 2)
	var rig: MechRig = pair[0]
	assert_eq(rig.count_displays.size(), 1, "one count display")
	var d: Dictionary = rig.count_displays[0]
	assert_eq(str(d["source"]), "shots", "showing the counted shots")
	assert_eq((d["parts"] as Array).size(), 6, "on six cells")
	var on := float(d["on"])
	var off := float(d["off"])
	var flare := float(d["flare"])
	assert_true(flare > on and on > off, "a flare brighter than a charged cell, a charged one brighter than a spent one")
	var lit := func(i: int) -> float: return rig.count_light("shots", i)
	var settle := func(seconds: float) -> void:
		var t := 0.0
		while t < seconds:
			rig.tick(1.0 / 60.0)
			t += 1.0 / 60.0
	for i in range(6):
		assert_eq(lit.call(i), off, "dark before anything is counted (cell %d)" % (i + 1))
	assert_true(rig.show_counts({"shots": 2}), "the first look")
	assert_eq([lit.call(0), lit.call(1), lit.call(2)], [on, on, off], "shows its number as it stands")
	assert_false(rig.show_counts({"shots": 2}), "the same number changes nothing")
	assert_false(rig.show_counts({"ammo": 9}), "nor a number it does not show")
	assert_true(rig.show_counts({"shots": 5}), "three shots more")
	settle.call(0.05)
	assert_true(lit.call(2) > off and lit.call(2) < on, "a cell lights over a moment (%f)" % lit.call(2))
	settle.call(0.6)
	assert_eq(rig.count_shown("shots"), 5, "five lit")
	assert_eq([lit.call(4), lit.call(5)], [on, off], "the sixth dark: the next shot is the one that counts")
	assert_true(rig.show_counts({"shots": 0}), "the sixth shot")
	for i in range(6):
		assert_eq(lit.call(i), flare, "flares every cell (%d)" % (i + 1))
	settle.call(0.3)
	assert_true(lit.call(0) > off and lit.call(0) < flare, "and fades (%f)" % lit.call(0))
	settle.call(2.0)
	for i in range(6):
		assert_eq(lit.call(i), off, "dark again (cell %d)" % (i + 1))
	assert_true(rig.show_counts({"shots": 9}) and rig.count_shown("shots") == 6, "a number past its cells lights them all")
	# RIFTGATE_COUNT_DEBUG counts it up a cell a second until it falls, to judge it running.
	rig.show_counts({"shots": 0})
	rig.count_debug = true
	settle.call(1.05)
	assert_eq(rig.count_shown("shots"), 1, "the switch counts a cell a second")
	settle.call(6.0)
	assert_eq(rig.count_shown("shots"), 0, "past its last cell it falls")
	pair[1].free()
	var plain := _rig_for("clydesdale", 2)
	assert_false((plain[0] as MechRig).show_counts({"shots": 3, "ammo": 3}), "a model with no display shows nothing")
	plain[1].free()


func test_a_spin_is_held_while_the_machine_carries_its_status() -> void:
	# The Cassowary's capacitor turns while it is Spun Up, the status its Spin-Up grants (Ryan, 2
	# November: "It could spin for the spin up component"): up to speed as the status lands, run
	# down and still once it is spent.
	var pair := _rig_for("cassowary", 2)
	var rig: MechRig = pair[0]
	assert_true(rig.held_spins.has("spun_up") and (rig.held_spins["spun_up"] as Dictionary).has("capacitor"), "the capacitor spins while Spun Up")
	rig.acts = []   # an act turns the capacitor too: the held spin alone here
	var cap: Node3D = rig.joints["capacitor"]
	var speed := float(rig.held_spins["spun_up"]["capacitor"])
	var turned := func(seconds: float) -> float:
		var total := 0.0
		var t := 0.0
		while t < seconds:
			var before := cap.rotation.z
			rig.tick(1.0 / 60.0)
			total += absf(wrapf(cap.rotation.z - before, -PI, PI))
			t += 1.0 / 60.0
		return rad_to_deg(total) / seconds
	assert_true(turned.call(0.5) < 0.01, "still while nothing holds it")
	assert_true(rig.hold_spin("spun_up", true), "Spun Up lands")
	assert_false(rig.hold_spin("spun_up", true), "held once")
	assert_true(rig.spin_held("spun_up") and rig.alive(), "held, and the rig keeps ticking")
	turned.call(1.5)
	var fast: float = turned.call(1.0)
	assert_true(absf(fast - speed) < speed * 0.05, "up to its speed (%f a second)" % fast)
	assert_true(rig.hold_spin("spun_up", false), "the spin is spent")
	var slowing: float = turned.call(0.4)
	assert_true(slowing > 30.0 and slowing < fast, "it runs down rather than stopping dead (%f a second)" % slowing)
	turned.call(3.0)
	assert_true(turned.call(0.5) < 0.01, "and stands still")
	# RIFTGATE_SPIN_DEBUG holds it and lets it go in turn, to judge it running.
	rig.spin_debug = true
	turned.call(MechRig.SPIN_DEBUG_PERIOD + 1.5)
	assert_true(rig.spin_held("spun_up") and turned.call(0.5) > speed * 0.8, "the switch holds it after a period")
	turned.call(MechRig.SPIN_DEBUG_PERIOD)
	assert_false(rig.spin_held("spun_up"), "and lets it go after another")
	pair[1].free()
	var plain := _rig_for("clydesdale", 2)
	assert_false((plain[0] as MechRig).hold_spin("spun_up", true), "a model with no held spin holds none")
	plain[1].free()


func test_every_count_display_and_held_spin_names_what_the_game_passes() -> void:
	# A count display shows a number the skirmish passes (MechRig.COUNT_SOURCES, as
	# MechView3D.count_values reads them) and a held spin lasts while a status in sim/effects.gd
	# does, so a renamed source or status fails here rather than leaving a capacitor dark or still.
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		for c in side.get("counts", []):
			assert_true(MechRig.COUNT_SOURCES.has(str(c.get("source", ""))), "%s: its count display shows %s, a number the game passes" % [id, c.get("source", "")])
		for status in (side.get("spin_held", {}) as Dictionary).keys():
			assert_true(Effects.STATUS.has(str(status)), "%s: its spin is held by %s, a status the game lays" % [id, status])
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive({"id": "test_count", "name": "Count", "description": "", "effects": [{"trigger": "on_attack", "effect": "multiply_damage", "value": 2, "when": "nth_shot", "every": 6}]})
	Effects.stack(u, Effects.STATUS["shots"], Effects.SKIRMISH, "count", 7, Effects.DECAY_NONE)
	var ms := Skirmish.MechState.new()
	ms.unit = u
	ms.ammo = 3
	var values := MechView3D.count_values(ms)
	assert_eq(values.keys(), MechRig.COUNT_SOURCES, "every source the displays may show, and no other")
	assert_eq(values, {"shots": 1, "ammo": 3}, "the shots toward the next that counts (seven shots, a sixth counted: one), the magazine")


func test_the_cassowary_plants_its_toes_and_rolls_onto_them() -> void:
	# Its stride (31 October): each foot's toes planted flat while the body passes over them, the
	# heel lifting into the push-off before they leave the ground, the body never rolling.
	var pair := _rig_for("cassowary", 2)
	var rig: MechRig = pair[0]
	var model: Node3D = pair[1]
	for key in rig.gait.get("body", []):
		assert_true(is_zero_approx(float(key[6])), "the walk's body never rolls")
	var ball: Node3D = rig.joints["toe_l"]
	var hock: Node3D = rig.joints["ankle_l"]
	var rest_h := _in_model(ball, model).origin.y
	_drive(rig, rig.top_speed, 1.0)
	var samples: Array = []
	var lowest := 1e9
	var t := 0.0
	while t < 2.0 * float(rig.gait["stride"]) / rig.top_speed:
		rig.drive(rig.top_speed, 0.0, 0.0, 1.0 / 240.0)
		var at := _in_model(ball, model).origin
		samples.append([at.y, at.z - rig._dist, _in_model(hock, model).origin.y])
		lowest = minf(lowest, at.y)
		t += 1.0 / 240.0
	var runs: Array = [[]]
	for sm in samples:
		if float(sm[0]) < lowest + 0.3:
			(runs[runs.size() - 1] as Array).append(sm)
		elif not (runs[runs.size() - 1] as Array).is_empty():
			runs.append([])
	var whole := 0
	for run in runs:
		if (run as Array).size() < 5 or run == runs[0] or run == runs[runs.size() - 1]:
			continue   # a stance the window cut into
		whole += 1
		var ys: Array = (run as Array).map(func(sm): return float(sm[1]))
		assert_true(float(ys.max()) - float(ys.min()) < 0.8, "the toes stay put while the body passes over them (%f units)" % (float(ys.max()) - float(ys.min())))
		var heights: Array = (run as Array).map(func(sm): return float(sm[2]))
		assert_true(float(heights[heights.size() - 1]) - float(heights.min()) > 1.5, "the heel lifts before they leave the ground (%f)" % (float(heights[heights.size() - 1]) - float(heights.min())))
	assert_true(whole >= 1, "a whole stance in two strides")
	assert_true(absf(lowest - rest_h) < 0.6, "down on the ground where it stands at rest (%f against %f)" % [lowest, rest_h])
	pair[1].free()


func test_a_spinner_turns_without_end_and_faster_under_way() -> void:
	# Ryan, 6 October, the seventh notes: the Stingray's lift fans turn. A spinner (b.spin) turns
	# on its own axis whatever the machine does, at its idle rate standing and its moving rate
	# once under way, wrapped rather than clamped; the two fans counter-rotate.
	var pair := _rig_for("stingray", 3)
	var rig: MechRig = pair[0]
	assert_true(rig.spinners.has("fan_l") and rig.spinners.has("fan_r"), "the fans are spinners")
	var fan_l: Node3D = rig.joints["fan_l"]
	var fan_r: Node3D = rig.joints["fan_r"]
	var turned := func(node: Node3D, seconds: float, moving: bool) -> float:
		var total := 0.0
		var dt := 1.0 / 60.0
		var t := 0.0
		while t < seconds:
			var before := node.rotation.y
			if moving:
				rig.drive(rig.top_speed if rig.top_speed > 0.0 else 60.0, 0.0, 0.0, dt)
			rig.tick(dt)
			total += wrapf(node.rotation.y - before, -PI, PI)
			t += dt
		return rad_to_deg(total) / seconds
	var idle: float = turned.call(fan_r, 1.0, false)
	assert_true(absf(idle - float(rig.spinners["fan_r"][0])) < 20.0, "standing, a fan turns at its idle rate (%f a second)" % idle)
	assert_true(signf(turned.call(fan_l, 0.5, false)) != signf(idle), "and its twin the other way")
	turned.call(fan_r, 2.0, true)   # under way, the move blended in
	var under_way: float = turned.call(fan_r, 1.0, true)
	assert_true(absf(under_way - float(rig.spinners["fan_r"][1])) < 40.0, "under way it turns at its moving rate (%f a second)" % under_way)
	pair[1].free()


## The Polar Bear's vents stand ajar while its shell is open (Ryan, 2 November: "When unsealed, the
## vents should be open, and then more open during the vent animation"): at rest each louvre stands
## its ajar share open, the seal turning in shuts it, and a vent act's swing takes the share's place
## so the act still peaks where it was authored to.
func test_the_vents_stand_ajar_while_open_and_shut_with_the_seal() -> void:
	var with_ajar := ""
	for id in MACHINES:
		if not (MechRig.load_sidecar(id).get("ajar", {}) as Dictionary).is_empty():
			with_ajar = id
			break
	assert_false(with_ajar.is_empty(), "a model stands ajar")
	var pair := _rig_for(with_ajar)
	var rig: MechRig = pair[0]
	assert_false(rig.ajar.is_empty(), "%s: its ajar joints read" % with_ajar)
	assert_eq(rig.ajar_open(), 1.0, "open at rest")
	var jn := str(rig.ajar.keys()[0])
	var off: Vector3 = rig.ajar[jn][0]
	var j: Node3D = rig.joints[jn]
	var built: Vector3 = rig._rest[jn]
	if off != Vector3.ZERO:
		assert_true(j.rotation.distance_to(built) > 0.1, "%s: %s stands open past its built rest" % [with_ajar, jn])
	rig.set_form(rig.ajar_unless, true)
	rig.tick(float(rig.forms[rig.ajar_unless]["duration"]) + 0.5)
	assert_eq(rig.ajar_open(), 0.0, "sealed, the ajar pose is gone")
	var span: Vector3 = rig._ajar_span[jn][0]
	assert_eq(MechRig.ajar_share(off, span, Vector3.ZERO), off, "the whole share at rest")
	assert_eq(MechRig.ajar_share(off, span, span), Vector3.ZERO, "none once an act has it at its furthest")
	for k in range(3):
		if span[k] != 0.0:
			assert_true(absf(off[k]) < absf(span[k]) and signf(off[k]) == signf(span[k]), "%s: the share opens the way the act does, and less far" % jn)
	pair[1].free()


func _boxed_rig(lit: bool = false) -> Array:
	var root := Node3D.new()
	var body := Node3D.new()
	root.add_child(body)
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(10.0, 10.0, 10.0)
	mi.mesh = box
	if lit:
		var m := StandardMaterial3D.new()
		m.emission_enabled = true
		m.emission_energy_multiplier = 2.0
		mi.set_surface_override_material(0, m)
	body.add_child(mi)
	var rig := MechRig.new()
	rig.model = root
	rig.body = body
	return [rig, root, body, mi]


func test_a_blow_on_the_hull_shoves_the_machine_back_and_settles() -> void:
	# The to-do's hit reaction (Ryan's go of 3 November): the body shoved back a share of
	# its longest side, its nose rocking up, on its servo, settling back to rest.
	var r := _boxed_rig()
	var rig: MechRig = r[0]
	var body: Node3D = r[2]
	rig.jolt(Vector3(0.0, 0.0, 1.0), 1.0)
	rig.tick(MechRig.JOLT_UP)
	assert_true(absf(body.position.z - MechRig.JOLT_SHARE * 10.0) < 0.05, "shoved back its share of its size at the top")
	assert_true(body.rotation.x > 0.0, "its nose rocks up")
	rig.tick(MechRig.JOLT_DOWN + 0.05)
	assert_true(body.position.length() < 0.001 and absf(body.rotation.x) < 0.001, "and settles back to rest")
	rig.jolt(Vector3(0.0, 0.0, 1.0), 0.5)
	rig.tick(MechRig.JOLT_UP)
	assert_true(absf(body.position.z - MechRig.JOLT_SHARE * 5.0) < 0.05, "a blow the armour turned shoves at half")
	(r[1] as Node).free()


func test_a_machine_lost_guts_its_lit_parts_and_stops_its_acts() -> void:
	var r := _boxed_rig(true)
	var rig: MechRig = r[0]
	var m: StandardMaterial3D = (r[3] as MeshInstance3D).get_surface_override_material(0)
	rig.acts = [{"name": "wave", "duration": 1.0, "tracks": {}, "body": [], "glow": []}]
	rig.kill()
	assert_true(rig.dead, "it is lost")
	rig.tick(MechRig.GUTTER * 0.25)
	assert_true(m.emission_energy_multiplier < 2.0, "its light gutters as it goes")
	rig.tick(MechRig.GUTTER)
	assert_eq(m.emission_energy_multiplier, 0.0, "and is out once the beat is done")
	rig.tick(5.0)
	assert_true(rig._current.is_empty(), "a lost machine starts no act")
	rig.revive()
	assert_false(rig.dead, "lit again")
	assert_true(absf(m.emission_energy_multiplier - 2.0) < 0.001, "its light back at its rest")
	assert_eq(MechRig.gutter_k(MechRig.GUTTER), 0.0, "nothing left at the beat's end")
	assert_true(MechRig.gutter_k(0.0) > 0.0, "and all of it at its start")
	(r[1] as Node).free()


func test_a_locked_spin_parks_on_a_step_ahead_and_runs_on_from_there() -> void:
	# Ryan, 2 November, of the Cottonmouth's drum: "Keep the idle turn ... Quickly spin it forward a
	# fixed number of barrels when it fires", and "only ever light the top barrel mouth", so a
	# barrel must stand on top when a shot fires. A spinner with a step (b.spin's step, the
	# sidecar's spin_step) that an act locks (its `locks`) parks on its next step ahead as the act
	# starts, never turning back, and holds there while the act plays, the act's own turn adding
	# whole steps; when the act ends the idle turn takes up again from where it stands, nothing
	# unwound. An act that locks nothing leaves the spin turning.
	var id := ""
	var act := ""
	var jn := ""
	var free := ""
	for m in MACHINES:
		var side := MechRig.load_sidecar(m)
		for a in side.get("acts", []):
			for j in a.get("locks", []):
				if id.is_empty() and (side.get("spin_step", {}) as Dictionary).has(j) and (side.get("spin", {}) as Dictionary).has(j) and (a.get("tracks", {}) as Dictionary).has(j):
					id = m
					act = str(a["name"])
					jn = str(j)
	assert_false(id.is_empty(), "a model locks a stepped spin in an act")
	if id.is_empty():
		return
	for a in MechRig.load_sidecar(id).get("acts", []):
		if free.is_empty() and not (a.get("locks", []) as Array).has(jn) and not (a.get("tracks", {}) as Dictionary).has(jn):
			free = str(a["name"])
	var pair := _rig_for(id, 5)
	var rig: MechRig = pair[0]
	rig._wait = 1.0e9   # no act of its own choosing: only those played here
	var step := float(rig.spin_steps.get(jn, 0.0))
	assert_true(step > 0.0, "%s: %s has its step" % [id, jn])
	var ax := ["pitch", "yaw", "roll"].find(str(rig.meta[jn]["axis"]))
	var rate := float(rig.spinners[jn][0])
	var total := func() -> float: return float(rig._spun[jn]) + (rig._act_rot.get(jn, Vector3.ZERO) as Vector3)[ax]
	var dt := 1.0 / 60.0
	# Idle, mid-step.
	var t := 0.0
	while t < 0.4 or absf(fposmod(float(rig._spun[jn]), step)) < 2.0 or absf(fposmod(float(rig._spun[jn]), step) - step) < 2.0:
		rig.tick(dt)
		t += dt
	var s0 := float(rig._spun[jn])
	var parked := (ceilf(s0 / step) if rate >= 0.0 else floorf(s0 / step)) * step
	assert_true(rig.play(act), "%s plays %s" % [id, act])
	assert_true(rig.spin_locked(jn), "%s: %s locks %s" % [id, act, jn])
	var last := s0
	var backwards := false
	t = 0.0
	while t < MechRig.PARK_TIME + 0.1:
		rig.tick(dt)
		t += dt
		var now := float(rig._spun[jn])
		if (now - last) * signf(rate) < -0.001:
			backwards = true
		last = now
	assert_false(backwards, "%s: the park never turns back" % id)
	assert_true(absf(float(rig._spun[jn]) - parked) < 0.01, "%s: parked on the next step ahead (%f from %f, want %f)" % [id, float(rig._spun[jn]), s0, parked])
	var held := float(rig._spun[jn])
	var duration := 0.0
	for a in rig.acts:
		if str(a["name"]) == act:
			duration = float(a["duration"])
	while t < duration - 0.05:
		rig.tick(dt)
		t += dt
	assert_true(absf(float(rig._spun[jn]) - held) < 0.001, "%s: the idle turn holds still while the act plays" % id)
	var before: float = total.call()
	assert_true(absf(fposmod(before, step)) < 0.5 or absf(fposmod(before, step) - step) < 0.5, "%s: the act's own turn ends on whole steps (%f)" % [id, before])
	while rig.in_act():
		rig.tick(dt)
	assert_false(rig.spin_locked(jn), "%s: the lock goes with the act" % id)
	var after: float = total.call()
	assert_true(absf(wrapf(after - before, -180.0, 180.0)) < 2.0, "%s: nothing jumps or unwinds as the act ends (%f to %f)" % [id, before, after])
	var from := float(rig._spun[jn])
	for i in range(30):
		rig.tick(dt)
	assert_true(absf(wrapf(float(rig._spun[jn]) - from, -180.0, 180.0) - rate * 0.5) < 2.0, "%s: the idle turn takes up again from where it stands" % id)
	if not free.is_empty():
		assert_true(rig.play(free), "%s plays %s" % [id, free])
		assert_false(rig.spin_locked(jn), "%s: %s locks nothing" % [id, free])
		var s1 := float(rig._spun[jn])
		for i in range(30):
			rig.tick(dt)
		assert_true(absf(wrapf(float(rig._spun[jn]) - s1, -180.0, 180.0) - rate * 0.5) < 2.0, "%s: an act that locks nothing leaves the spin turning" % id)
	pair[1].free()


func test_a_weapons_slices_take_turns_and_wind_up_to_their_blow() -> void:
	# Ryan, 3 November: the Ammit "can also afford two different Claw animations", and a weapon fired
	# seldom is "worth a little longer time". Synthetic acts and slices.
	var r := _boxed_rig()
	var rig: MechRig = r[0]
	rig.acts = [{"name": "a", "duration": 2.0, "tracks": {}, "body": [], "glow": []}, {"name": "b", "duration": 2.0, "tracks": {}, "body": [], "glow": [], "idle": false}]
	rig.fires = {"claws": [{"act": "a", "from": 0.2, "to": 1.2, "blow": 0.6}, {"act": "b", "from": 0.4, "to": 1.0}]}
	assert_eq(str(rig.fire_slice("claws")["act"]), "a", "the first slice first")
	assert_true(absf(rig.fire_wind("claws") - 0.4) < 0.001, "it winds up from its start to its blow")
	assert_true(absf(rig.fire_span("claws") - 1.0) < 0.001, "and plays its whole span")
	assert_true(rig.fire_act("claws"), "fired")
	assert_eq(str(rig._current["name"]), "a", "playing its act")
	assert_eq(str(rig.fire_slice("claws")["act"]), "b", "the other next")
	assert_eq(rig.fire_wind("claws"), 0.0, "a slice naming no blow starts on it")
	assert_true(rig.fire_act("claws"), "fired again")
	assert_eq(str(rig._current["name"]), "b", "the other plays")
	assert_eq(str(rig.fire_slice("claws")["act"]), "a", "then round again")
	rig.fires = {"gun": {"act": "a", "from": 0.2, "to": 1.2}}
	assert_eq(rig.fire_slices("gun").size(), 1, "one slice as before")
	assert_true(rig.fire_slices("none").is_empty() and rig.fire_wind("none") == 0.0, "a weapon with none has none")
	# An act that is a weapon's firing alone never plays at rest.
	rig._end_act()
	var chosen := {}
	for k in range(12):
		chosen[str(rig.choose().get("name", ""))] = true
	assert_eq(chosen.keys(), ["a"], "an act marked idle false is never an idle")
	(r[1] as Node).free()


func test_a_lost_machine_slumps_and_its_spins_run_down() -> void:
	# Ryan, 3 November: after the lights go, "they should slump or collapse after, limbs dropping,
	# flyers and hovers landing, fans stopping, idle spins stopping"; the second notes the same day:
	# "don't fall through the floor, and don't do weird impossible leans ... it can keep its feet
	# planted and just sink using its ankles and knees. Same with the bipeds, sink using knees and
	# ankles and only slump forward at the waist. The bipeds also swing their arms behind them when
	# they should just go slack at the elbows".
	# The baseline every model goes through that has no death pose of its own (16 November: the
	# machines here have one, so it is taken off to read the slump beneath it).
	var pair := _rig_for("nemesis")
	var rig: MechRig = pair[0]
	rig.forms.erase(MechRig.DEATH)
	var feet := {}
	for side in ["l", "r"]:
		feet[side] = rig._in_model(rig.joints["ankle_" + side])
	rig.kill()
	rig.tick(MechRig.COLLAPSE_AT + 3.0)
	assert_true(rig.body.position.y < -3.0, "a walker sinks (%.2f)" % rig.body.position.y)
	assert_true(rig.body.rotation.length() < 0.001, "straight down: nothing tips it")
	for side in ["l", "r"]:
		var now: Transform3D = rig._in_model(rig.joints["ankle_" + side])
		var moved: float = (now.origin + rig.body.position).distance_to((feet[side] as Transform3D).origin)
		var turned := rad_to_deg(now.basis.get_rotation_quaternion().angle_to((feet[side] as Transform3D).basis.get_rotation_quaternion()))
		assert_true(moved < 0.3 and turned < 1.0, "each foot stays where it stands and as it stands (%s: %.2f, %.1f degrees)" % [side, moved, turned])
	assert_true(float(rig._want_rot.get("waist", Vector3.ZERO).x) < -10.0, "a biped slumps forward at the waist")
	for side in ["l", "r"]:
		assert_true(absf(float(rig._want_rot.get("shoulder_" + side, Vector3.ZERO).x)) < 15.0, "its arm hangs where it is, never swung back (%s)" % side)
		assert_true(absf(float(rig._want_rot.get("elbow_" + side, Vector3.ZERO).x)) > 20.0, "it goes slack at the elbow (%s)" % side)
	assert_true(rig._lowest_under(rig.model) + rig.body.position.y > -0.5, "and nothing goes through the floor")
	rig.revive()
	rig.tick(2.0)
	assert_true(rig._want_rot.is_empty() and absf(rig.body.position.y) < 0.05, "and stands again, revived")
	pair[1].free()
	# A tracked machine sinks nowhere; what it carries hangs, kept above the floor.
	pair = _rig_for("badger")
	rig = pair[0]
	rig.forms.erase(MechRig.DEATH)
	var low := rig._lowest_under(rig.model)
	rig.kill()
	rig.tick(MechRig.COLLAPSE_AT + 3.0)
	assert_true(absf(rig.body.position.y) < 0.01, "a machine on tracks stays on them")
	assert_true(rig._lowest_under(rig.model) > minf(0.0, low) - 0.3, "and its claw rests on the floor, never through it")
	pair[1].free()
	# A flyer comes down onto what hangs lowest once it has slumped (MechView3D lands it there).
	pair = _rig_for("buzzard")
	rig = pair[0]
	rig.forms.erase(MechRig.DEATH)
	rig.airborne = true
	rig.kill()
	rig.tick(MechRig.COLLAPSE_AT + 3.0)
	assert_true(absf(rig.body.position.y) < 0.01, "an airborne machine does not sink on itself")
	assert_true(absf(rig.collapse_floor - rig._lowest_under(rig.model)) < 0.5, "it lands on its lowest point (%.2f, %.2f)" % [rig.collapse_floor, rig._lowest_under(rig.model)])
	pair[1].free()
	pair = _rig_for("stingray")
	rig = pair[0]
	var turned := func(seconds: float) -> float:
		var a := float(rig._spun["fan_r"])
		rig.tick(seconds)
		return absf(fposmod(float(rig._spun["fan_r"]) - a + 180.0, 360.0) - 180.0)
	assert_true(turned.call(0.05) > 1.0, "its fans turn while it stands")
	rig.kill()
	rig.tick(MechRig.SPIN_STOP + 0.1)
	assert_true(turned.call(0.05) < 0.001, "and stop once it is lost")
	pair[1].free()




## The lowest point of what a rig's body carries, where the body stands (in its parent's frame).
func _lowest_standing(rig: MechRig) -> float:
	var low := INF
	for mi in rig.model.find_children("*", "MeshInstance3D", true, false):
		var shown := true
		var n: Node = mi
		while n != null and n != rig.model:
			shown = shown and (not (n is Node3D) or (n as Node3D).visible)   # a hidden subtree shows nothing (a launch, a hidden pin's part)
			n = n.get_parent()
		if not shown or (mi as MeshInstance3D).mesh == null or mi.has_meta("halo") or mi.has_meta("plume") or mi.has_meta("is_trace"):
			continue
		var xf := rig.body.transform * rig._in_model(mi)
		var bb := (mi as MeshInstance3D).get_aabb()
		for k in range(8):
			low = minf(low, (xf * bb.get_endpoint(k)).y)
	return low


func test_a_death_pose_goes_in_place_of_the_slump_and_rests_on_the_floor() -> void:
	# Ryan, 16 November: "The slump was supposed to be a general guideline so that everything got an
	# adequate baseline death animation and pose. There's nothing to say that they can't be improved on
	# a case by case basis, like the Clydesdale falling onto its face like the AT-AT that influenced
	# it": a model's death pose (lowforge's b.death, the sidecar's death) turns in as it is lost, in
	# place of the slump, held, set down on its own lowest point; a revive stands it up at once.
	for id in ["clydesdale", "funnel_web", "kite", "polar_bear"]:
		var pair := _rig_for(id)
		var rig: MechRig = pair[0]
		assert_true(rig.forms.has(MechRig.DEATH), "%s has a death of its own" % id)
		rig.airborne = id == "kite"
		rig.kill()
		rig.tick(float(rig.forms[MechRig.DEATH]["duration"]) + 1.0)
		assert_true(rig.form_held(MechRig.DEATH), "%s: its death pose held" % id)
		assert_true(rig._want_rot.is_empty() and rig._collapse < 0.0, "%s: no slump beside it" % id)
		assert_eq(rig.collapse_floor, 0.0, "%s: nothing for the view to land but onto the floor" % id)
		var low := _lowest_standing(rig)
		assert_true(absf(low - rig._body_rest_pos.y) < 0.6, "%s: it rests on the floor, neither through it nor floating (%.2f against %.2f)" % [id, low, rig._body_rest_pos.y])
		rig.set_form(MechRig.DEATH, false)
		assert_true(rig.form_held(MechRig.DEATH), "%s: no status lets it go" % id)
		rig.revive()
		rig.tick(0.05)
		assert_false(rig.form_held(MechRig.DEATH), "%s: revived, it stands again" % id)
		pair[1].free()
	var pair := _rig_for("clydesdale")
	var rig: MechRig = pair[0]
	rig.kill()
	rig.tick(float(rig.forms[MechRig.DEATH]["duration"]) + 1.0)
	assert_true(rig.body.rotation.x < -0.15, "the Clydesdale goes down on its face (%.2f)" % rig.body.rotation.x)
	pair[1].free()


func test_every_death_pose_names_what_its_model_has() -> void:
	var named := 0
	for f in DirAccess.get_files_at("res://art/models"):
		if not f.ends_with(".rig.json"):
			continue
		var id := f.trim_suffix(".rig.json")
		var side := MechRig.load_sidecar(id)
		var d = side.get("death", {})
		if not (d is Dictionary) or (d as Dictionary).is_empty():
			continue
		named += 1
		assert_true(float(d.get("duration", 0.0)) > 0.0, "%s: its death takes time" % id)
		for jn in (d.get("tracks", {}) as Dictionary).keys():
			assert_true((side.get("joints", {}) as Dictionary).has(jn), "%s: its death moves its own %s" % [id, jn])
	assert_true(named >= 20, "the roster goes down its own ways (%d)" % named)

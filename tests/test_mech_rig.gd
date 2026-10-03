extends TestCase

## The rig (MechRig): a machine's joints read from its model and its sidecar, the idle acts
## picked and played, the limits, the strikes. Headless: the models instantiate without a
## renderer, so the joints' nesting and the sidecars are checked against the real files;
## only the drawing needs a window.

const MACHINES := ["badger", "sparrowhawk", "clydesdale", "baboon", "armadillo", "wild_boar", "prairie_dog", "dingo", "goshawk", "nemesis", "ammit"]


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
					if str(mi.name).begins_with(str(part)):
						found = true
						break
				assert_true(found, "%s: a mesh named %s* carries the glow" % [id, part])
		model.free()


func test_the_nested_joints_the_bible_asked_for_are_in_the_models() -> void:
	var want := {
		"badger": [["elbow_l", "shoulder_l"], ["jaw_upper", "elbow_l"], ["jaw_lower", "elbow_l"], ["elbow_r", "shoulder_r"]],
		"clydesdale": [["head", ""], ["knee_fl", "hip_fl"], ["knee_hr", "hip_hr"], ["elev_mortar", "turret_mortar"], ["elev_howitzer", "turret_howitzer"]],
		"baboon": [["elbow_l", "shoulder_l"], ["ankle_l", "knee_l"], ["knee_l", "hip_l"], ["elev_r", ""]],
		"armadillo": [["knee_fl", "hip_fl"], ["elev_l", ""], ["elev_r", ""], ["elev_cell", ""]],
		"wild_boar": [["elev", "turret"], ["plow", ""], ["elev_pod", ""]],
		"prairie_dog": [["wheel_fl", "steer_fl"], ["wheel_rl", ""], ["sensor", "chassis"], ["turret", "chassis"]],
		"dingo": [["wheel_fl", "caster_fl"], ["harpoon", "chassis"], ["elev_mortar", "chassis"]],
		"goshawk": [["nacelle_l", ""], ["nacelle_r", ""]],
		"nemesis": [["elbow_r", "shoulder_r"], ["knee_l", "hip_l"], ["elev_meteor", ""]],
		"ammit": [["hand_l", "elbow_l"], ["elbow_l", "shoulder_l"], ["ankle_r", "knee_r"], ["elbow_low_r", "shoulder_low_r"], ["elev_l", ""]],
	}
	for id in want.keys():
		var pair := _rig_for(id)
		var rig: MechRig = pair[0]
		for row in want[id]:
			assert_true(rig.joints.has(row[0]), "%s has joint %s" % [id, row[0]])
			if rig.joints.has(row[0]):
				assert_eq(rig.joint_of(rig.joints[row[0]]), row[1], "%s: %s hangs under '%s'" % [id, row[0], row[1]])
		pair[1].free()
	# The Clydesdale's cheek mounts ride its head; its hoof is under the knee under the hip.
	var pair := _rig_for("clydesdale")
	var rig: MechRig = pair[0]
	assert_eq(rig.joint_of(rig.hardpoints[7]), "head", "the left cheek mount turns with the head")
	assert_eq(rig.joint_of(rig.hardpoints[4]), "elev_mortar", "the mortar's socket is on its elevation, inside the traverse")
	assert_eq(rig.joint_of(rig.joints["elev_mortar"]), "turret_mortar", "which nests in the turret")
	pair[1].free()
	# The lower pair of the Ammit's arms never swing on a blow; the upper pair do.
	pair = _rig_for("ammit")
	rig = pair[0]
	assert_true(bool(rig.meta["shoulder_l"]["swing"]), "the Ammit's upper arm swings")
	assert_false(bool(rig.meta["shoulder_low_l"]["swing"]), "its planted lower arm does not")
	pair[1].free()


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
	rig.tick(1.4)   # the jaw wide open
	assert_true(jaw.rotation.x > rest.x + deg_to_rad(30.0), "the fingers lift about the pin to open (%f)" % rad_to_deg(jaw.rotation.x - rest.x))
	assert_true((rig.joints["jaw_lower"] as Node3D).rotation.x < rest.x - deg_to_rad(30.0), "the tines drop")
	assert_true((rig.joints["shoulder_l"] as Node3D).rotation.x > deg_to_rad(10.0), "the boom lifts the claw")
	assert_true(is_zero_approx((rig.joints["shoulder_r"] as Node3D).rotation.x), "the other boom stands")
	rig.tick(2.5)   # past the end
	assert_true(jaw.rotation.is_equal_approx(rest), "back at rest when the act ends")
	assert_eq(rig.last_act, "test_claw", "remembered, so the next pick differs")
	pair[1].free()


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
	rig.tick(1.0)
	assert_true(model.position.is_equal_approx(base), "and the car is back on its hex")
	pair[1].free()


func test_limits_hold_an_outward_only_turret_and_the_strike_flinches_outward() -> void:
	var pair := _rig_for("clydesdale", 4)
	var rig: MechRig = pair[0]
	var tr: Node3D = rig.joints["turret_r"]
	rig.strike(true)
	rig.tick(0.05)
	assert_true(tr.rotation.y < 0.0, "the right turret, which turns only right, flinches right on a shot (%f)" % tr.rotation.y)
	var tl: Node3D = rig.joints["turret_l"]
	assert_true(tl.rotation.y > 0.0, "and the left one left")
	assert_true((rig.joints["lance"] as Node3D).rotation.x != 0.0, "the lance kicks")
	assert_true(is_zero_approx((rig.joints["hip_fl"] as Node3D).rotation.x), "a leg does not")
	rig.tick(1.0)
	assert_true(is_zero_approx(tr.rotation.y), "settled")
	rig.strike(false)
	rig.tick(0.1)
	assert_true(is_zero_approx(tr.rotation.y), "a melee blow leaves turrets alone")
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
	rig.debug = "core_flare"
	for i in range(5):
		assert_eq(str(rig.choose()["name"]), "core_flare", "the named act, every time")
	rig.debug = "1"
	rig.last_act = "core_flare"
	assert_ne(str(rig.choose()["name"]), "core_flare", "'1' is every act, back to back, still never twice running")
	pair[1].free()

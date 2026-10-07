extends TestCase

## The rig (MechRig): a machine's joints read from its model and its sidecar, the idle acts
## picked and played, the limits, the strikes. Headless: the models instantiate without a
## renderer, so the joints' nesting and the sidecars are checked against the real files;
## only the drawing needs a window.

const MACHINES := ["badger", "sparrowhawk", "clydesdale", "baboon", "armadillo", "wild_boar", "prairie_dog", "dingo", "goshawk", "nemesis", "ammit", "stingray", "puffin"]


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
		"badger": [["elbow_l", "shoulder_l"], ["wrist_l", "elbow_l"], ["jaw_upper", "wrist_l"], ["jaw_lower", "wrist_l"], ["elbow_r", "shoulder_r"], ["wrist_r", "elbow_r"]],
		"clydesdale": [["head", ""], ["knee_fl", "hip_fl"], ["knee_hr", "hip_hr"], ["ankle_fl", "knee_fl"], ["ankle_hr", "knee_hr"], ["elev_mortar", "turret_mortar"], ["elev_howitzer", "turret_howitzer"]],
		"baboon": [["waist", ""], ["shoulder_l", "waist"], ["elbow_l", "shoulder_l"], ["wrist_l", "elbow_l"], ["ankle_l", "knee_l"], ["knee_l", "hip_l"], ["elev_r", "waist"]],
		"armadillo": [["knee_fl", "hip_fl"], ["ankle_fl", "knee_fl"], ["ankle_hl", "knee_hl"], ["elev_l", ""], ["elev_r", ""], ["elev_cell", ""]],
		"wild_boar": [["elev", "turret"], ["plow", ""], ["elev_pod", ""]],
		"prairie_dog": [["wheel_fl", "steer_fl"], ["wheel_rl", ""], ["sensor", "chassis"], ["turret", "chassis"]],
		"dingo": [["wheel_fl", "caster_fl"], ["harpoon", "chassis"], ["elev_mortar", "chassis"]],
		"goshawk": [["nacelle_l", ""], ["nacelle_r", ""]],
		"nemesis": [["waist", ""], ["shoulder_r", "waist"], ["elbow_r", "shoulder_r"], ["knee_l", "hip_l"], ["ankle_l", "knee_l"], ["ankle_r", "knee_r"], ["elev_meteor", "waist"]],
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
		rig.acts = [{"name": "probe", "duration": 3.0, "ease": "smooth", "tracks": {"turret_l": [[0.6, 0.0, 30.0, 0.0, 0.0, 0.0, 0.0], [2.0, 0.0, 30.0, 0.0, 0.0, 0.0, 0.0]]}, "body": [], "glow": []}]
		var tr: Node3D = rig.joints["turret_l"]
		assert_true(rig.play("probe"), "a probe act")
		rig.tick(0.3)
		var wanted := float(MechRig.sample(rig.acts[0]["tracks"]["turret_l"], 0.3, 3.0)[1])
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
	# an act that breaks the rule; this reads the sidecars to be sure none slipped through.
	var reach := 70.0
	var slew := 35.0
	var pause := 0.6
	for id in MACHINES:
		var side := MechRig.load_sidecar(id)
		for a in side.get("acts", []):
			for jn in a.get("tracks", {}).keys():
				if not str(jn).begins_with("turret"):
					continue
				var axis := ["pitch", "yaw", "roll"].find(str(side["joints"][jn]["axis"]))
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
	# Ryan, 5 October: the Sparrowhawk's loop and circle are for the map; a blow wants to be
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
		rig.acts = [{"name": "probe", "duration": 3.0, "ease": "smooth", "tracks": {"turret_l": [[0.6, 0.0, 30.0, 0.0, 0.0, 0.0, 0.0], [2.0, 0.0, 30.0, 0.0, 0.0, 0.0, 0.0]]}, "body": [], "glow": []}]
		if h > 0.0:
			rig.acts[0]["heft"] = h
		rig.tick(5.0)
		assert_true(rig.play("probe"), "a probe")
		rig.tick(0.4)
		lags.append(30.0 * 0.4 / 0.6 - rad_to_deg((rig.joints["turret_l"] as Node3D).rotation.y))
		rig.tick(3.0)
	assert_true(float(lags[1]) < float(lags[0]) * 0.5, "an act with its own light heft follows its keys more closely (%f against %f)" % [lags[1], lags[0]])
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
	for id in ["clydesdale", "armadillo", "nemesis", "baboon", "ammit"]:
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
	var expect := sqrt(3.0) * 100.0 / (2.0 * fit) / BattleMapView.mech_seconds_per_hex(20.0)
	assert_true(is_equal_approx(MechRig.map_speed(100.0, 20, fit), expect), "a slow walker's pace")
	assert_true(MechRig.map_speed(100.0, 50, fit) > MechRig.map_speed(100.0, 20, fit) * 4.0, "a 50 runs four and a half times a 20")
	# Ryan, 5 October: the 20s and 30s slower than the third pass's pace, the 40s and 50s faster.
	assert_true(BattleMapView.mech_seconds_per_hex(20.0) > 1.38 and BattleMapView.mech_seconds_per_hex(30.0) > 0.92, "the 20s and 30s plod slower")
	assert_true(BattleMapView.mech_seconds_per_hex(40.0) < 0.69 and BattleMapView.mech_seconds_per_hex(50.0) < 0.55, "the 40s and 50s run faster")
	assert_true(is_equal_approx(BattleMapView.mech_seconds_per_hex(35.0), lerpf(BattleMapView.mech_seconds_per_hex(30.0), BattleMapView.mech_seconds_per_hex(40.0), 0.5)), "straight between the tens")
	assert_true(MechRig.map_speed(100.0, 50, Map3D.fit_for("light")) > MechRig.map_speed(100.0, 50, Map3D.fit_for("assault")), "a light machine is drawn smaller, so a hex is more of itself")
	var pair := _rig_for("armadillo", 2)
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
	pair = _rig_for("goshawk", 2)
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
	pair = _rig_for("goshawk", 2)
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
	# The fifth notes: a hovercraft keeps flat, so the Puffin no longer banks.
	var puffin: Dictionary = MechRig.load_sidecar("puffin")["move"]
	assert_true(is_zero_approx(float(puffin.get("bank", 0.0))) and float(puffin.get("oversteer", 0.0)) > 0.0, "the Puffin oversteers and does not bank")
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
	# sign the Goshawk's bank into a left turn reads).
	assert_true(model.rotation.z > deg_to_rad(4.0), "left: the left side drops (%f)" % rad_to_deg(model.rotation.z))
	_drive(rig, 0.0, 3.0)
	assert_true((model.rotation - rig._body_rest_rot).length() < deg_to_rad(0.3), "level again on station")
	pair[1].free()
	pair = _rig_for("puffin", 2)
	rig = pair[0]
	assert_true(is_zero_approx(float(rig.move.get("strafe", 0.0))), "the Puffin faces its heading")
	_drive(rig, MechRig.MOVE_REF_SPEED, 1.5, 0.0, 1.0)
	assert_true(absf(pair[1].rotation.z) < deg_to_rad(0.5), "and stays flat through a left turn (%f)" % rad_to_deg(pair[1].rotation.z))
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

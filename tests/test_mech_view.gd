extends TestCase

## The 3D mech view's reading of a model's tags: `joint_<name>` and `hp_<n>` Empties come
## through the glTF as node names, sometimes with an importer suffix. Rendering itself needs
## a window, so only the name parsing and the model choice run here.


func test_parse_tag_reads_joints_and_hardpoints() -> void:
	assert_eq(MechView3D.parse_tag("joint_shoulder_l"), ["joint", "shoulder_l"], "a joint by name")
	assert_eq(MechView3D.parse_tag("hp_1"), ["hp", 1], "a hardpoint by number")
	assert_eq(MechView3D.parse_tag("hp_12"), ["hp", 12], "two digits")
	assert_eq(MechView3D.parse_tag("hp_3_001"), ["hp", 3], "an importer suffix does not change the pin")
	assert_eq(MechView3D.parse_tag("body"), [], "a part is not a tag")
	assert_eq(MechView3D.parse_tag("hp_"), [], "a pin needs a number")
	assert_eq(MechView3D.parse_tag("joint_"), [], "a joint needs a name")
	assert_eq(MechView3D.parse_tag("hydraulic_shoulder_l.detail"), [], "hydraulics are parts")


func test_model_for_falls_back_to_the_stand_in() -> void:
	# The stand-in comes from content, never a named id: the first chassis in content's order
	# with a model of its own.
	var modelled: Array = []
	for id in ContentDB.load_default().chassis.keys():
		if MechView3D.has_model(str(id)):
			modelled.append(str(id))
	assert_true(modelled.size() >= 2, "two chassis have models")
	assert_eq(MechView3D.stand_in(), modelled[0], "the stand-in is the first modelled chassis in content's order")
	assert_eq(MechView3D.model_for(modelled[1]), modelled[1], "a modelled chassis draws its own")
	assert_eq(MechView3D.model_for("no_such_chassis"), modelled[0], "an unmodelled chassis borrows the stand-in")
	assert_eq(MechView3D.model_for("no_such_chassis", modelled[1]), modelled[1], "or the fallback a screen names")


func test_the_metal_tables_name_exactly_contents_makers() -> void:
	# A table of metals keyed by maker is the one place code names a content id, so a renamed
	# or new maker fails here rather than drawing in the first maker's colours.
	var makers: Array = ContentDB.load_default().makers.keys()
	for table in [MechView3D.LIVERY, MechView3D.FINISH, MechView3D.GLOSS]:
		for maker in makers:
			assert_true(table.has(maker), "maker %s has an entry" % maker)
		for key in table.keys():
			assert_true(makers.has(key), "%s is a maker in content" % key)


func test_every_silhouette_class_has_a_model_in_every_makers_metal() -> void:
	# The classes content may name (ContentDB.SHAPES) are built by `forge.py shapes` into
	# art/models/shapes/<shape>_<maker>.glb; a missing one would leave a swapped component
	# invisible on the machine.
	var db := ContentDB.load_default()
	for shape in ContentDB.SHAPES:
		if shape == ContentDB.SHAPE_NONE:
			continue
		for maker in db.makers.keys():
			assert_true(MechView3D.has_model(MechView3D.shape_model(shape, maker)), "%s in %s is built" % [shape, maker])


func test_mount_plan_names_only_the_mounts_that_differ_from_stock() -> void:
	var db := ContentDB.load_default()
	# Stock: a gun, a rack, a gun, and a jack that takes no mount: three mounts filled.
	var stock := ["slugthrower", "shotfire_rack", "twin_autoguns", "shoring_jack"]
	var die := db.build_die(["chainsaw_claw", "chainsaw_claw"], stock, 4)
	assert_eq(MechView3D.mount_plan(die, stock, db), [], "the stock kit changes nothing")
	# The jack swapped for a vent: still no mount touched.
	die.faces[5] = db.build_face(db.components["coolant_jacket"]["face"])
	die.faces[5].component = "coolant_jacket"
	assert_eq(MechView3D.mount_plan(die, stock, db), [], "a component without a shape shows nowhere")
	# The rack (die entry 4, mount 2) refitted with a Kestrel gun, the autoguns emptied: the
	# next shaped entry is the vent, which takes no mount, so mount 3 goes bare.
	die.faces[3] = db.build_face(db.components["enfilade_beam"]["face"])
	die.faces[3].component = "enfilade_beam"
	die.faces[4] = Face.empty_slot()
	var plan := MechView3D.mount_plan(die, stock, db)
	assert_eq(plan, [[2, "enfilade_beam", "barrel", "wainwright_sutler"], [3, "", "", ""]], "mounts are counted over shaped entries, in the die's order, in the component's own metal")
	# The vent swapped for a shield projector: a dish takes the next mount, the fourth.
	die.faces[4] = db.build_face(db.components["twin_autoguns"]["face"])
	die.faces[4].component = "twin_autoguns"
	die.faces[5] = db.build_face(db.components["laminar_deflector"]["face"])
	die.faces[5].component = "laminar_deflector"
	assert_eq(MechView3D.mount_plan(die, stock, db), [[2, "enfilade_beam", "barrel", "wainwright_sutler"], [4, "laminar_deflector", "dish", "kestrel"]], "a projector is gun-shaped enough to take a mount")
	assert_eq(MechView3D.mount_plan(null, stock, db), [], "no die, no plan")


func test_the_pins_plan_reads_what_each_pin_was_built_carrying() -> void:
	# Against a model's own record (Ryan's go, 28 October), not content's stock: a stock that
	# has moved on since the model was built shows its class shapes, and a bare mount
	# numbered among the guns never shifts the die's order.
	var db := ContentDB.load_default()
	var stock := ["slugthrower", "shotfire_rack", "twin_autoguns", "shoring_jack"]
	var die := db.build_die(["chainsaw_claw", "chainsaw_claw"], stock, 4)
	assert_eq(MechView3D.pins_plan(die, ["slugthrower", "shotfire_rack", "twin_autoguns", ""], db), [], "a model built carrying the die changes nothing")
	assert_eq(MechView3D.pins_plan(die, ["rivet_gun", "shotfire_rack", "twin_autoguns", ""], db), [[1, "slugthrower", "barrel", "minerva"]], "a pin built with another gun wears the fitted one's class")
	assert_eq(MechView3D.pins_plan(die, ["slugthrower", "", "shotfire_rack", "twin_autoguns"], db), [[2, "shotfire_rack", "rack", "minerva"], [3, "twin_autoguns", "twin_barrel", "wainwright_sutler"], [4, "", "", ""]], "a bare mount among the guns: the die still takes the pins in its order, the last bared")
	assert_eq(MechView3D.pins_plan(die, ["slugthrower", "shotfire_rack", "twin_autoguns", "laminar_deflector", ""], db), [[4, "", "", ""]], "a pin whose built part the die no longer has is bared")
	assert_eq(MechView3D.pins_plan(null, [], db), [], "no die, no plan")


func test_plan_for_reads_the_models_record_else_contents_stock() -> void:
	var db := ContentDB.load_default()
	var with_record := ""
	var without := ""
	for id in db.chassis.keys():
		if with_record.is_empty() and MechView3D.pin_record(str(id)) != null:
			with_record = str(id)
		if without.is_empty() and not MechView3D.has_model(str(id)):
			without = str(id)
	assert_false(with_record.is_empty(), "a modelled chassis records its pins")
	var u := db.make_mech(with_record)
	assert_eq(MechView3D.plan_for(u, db), MechView3D.pins_plan(u.die, MechView3D.pin_record(with_record), db), "a machine with a model plans against the model's record")
	if not without.is_empty():
		var v := db.make_mech(without)
		assert_eq(MechView3D.pin_record(without), null, "a chassis with no model has no record")
		assert_eq(MechView3D.plan_for(v, db), [], "with none, a fresh machine plans against content's stock and wears it")
	assert_eq(MechView3D.plan_from_spec("1:enfilade_beam, 2:, x:y, 3:no_such, 4:coolant_jacket", db), [[1, "enfilade_beam", "barrel", "wainwright_sutler"], [2, "", "", ""]], "the debug spec: a fit, a bared mount, junk and unshaped equipment skipped")


func test_every_model_names_what_each_of_its_pins_carries() -> void:
	# lowforge refuses a rigged model whose pin names nothing (bl_low.py's rig()); here the
	# record and the model's pins agree, and a model has as many pins as its chassis has
	# hardpoints, so a hardpoint count that moves fails here until the model follows.
	var db := ContentDB.load_default()
	for id in db.chassis.keys():
		if not MechView3D.has_model(str(id)):
			continue
		var rec = MechView3D.pin_record(str(id))
		assert_true(rec != null, "%s: its sidecar records its pins" % id)
		if rec == null:
			continue
		var model: Node3D = (load("res://art/models/%s.glb" % id) as PackedScene).instantiate()
		var pins := MechView3D.pins_of(model)
		assert_eq(pins.size(), int(db.chassis[id].get("hardpoints", 0)), "%s: a pin for every hardpoint, no more (the content's count)" % id)
		assert_eq((rec as Array).size(), pins.size(), "%s: a record for every pin" % id)
		for n in pins.keys():
			assert_true(int(n) >= 1 and int(n) <= (rec as Array).size(), "%s: hp_%d is recorded" % [id, int(n)])
		model.free()


func test_a_turret_joint_traverses_and_a_limb_swings() -> void:
	assert_eq(MechView3D.joint_axis("turret"), Vector3(0, 1, 0), "a turret turns about its up axis")
	assert_eq(MechView3D.joint_axis("turret_l"), Vector3(0, 1, 0), "a named turret too")
	assert_eq(MechView3D.joint_axis("shoulder_l"), Vector3(1, 0, 0), "a limb swings about the axle line")


func test_a_models_textures_read_their_mipmaps() -> void:
	# Ryan, 30 October: "a lot of aliasing on models" on the phone. A machine drawn small on
	# the map read one texel of its 64-pixel tiles a screen pixel and sparkled; nearest from
	# its mipmaps keeps the texels up close and the calm far off, in every AA mode.
	var node: Node = (load("res://art/models/%s.glb" % MechView3D.stand_in()) as PackedScene).instantiate()
	MechView3D.toon(node, ContentDB.load_default().makers.keys()[0], "toon")
	var seen: Array = []
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = child
		for i in range(mi.get_surface_override_material_count()):
			var m := mi.get_surface_override_material(i)
			if m is StandardMaterial3D and (m as StandardMaterial3D).albedo_texture != null and not seen.has(m.texture_filter):
				seen.append(m.texture_filter)
	node.free()
	assert_eq(seen, [BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS], "every textured part reads its mipmaps")


func test_the_aa_mode_sets_the_msaa_and_the_fxaa() -> void:
	# The player's AA MODE (Ryan, 30 October: "Can we add an AA mode setting, not just for
	# debug?"), MSAA 4x by default, a phone's too: Godot 4.8 fixed the Compatibility renderer's
	# MSAA leak on Android (godotengine/godot#124643).
	var was_env := OS.get_environment("RIFTGATE_AA")
	var was: Variant = Settings.display.get("aa_mode", "msaa4")
	OS.unset_environment("RIFTGATE_AA")
	assert_eq(str(Settings.DISPLAY_DEFAULTS["aa_mode"]), "msaa4", "MSAA 4x by default")
	var want := {"off": [SubViewport.MSAA_DISABLED, false], "fxaa": [SubViewport.MSAA_DISABLED, true],
		"msaa2": [SubViewport.MSAA_2X, false], "msaa4": [SubViewport.MSAA_4X, false]}
	assert_eq(want.keys().size(), Settings.AA_MODES.size(), "every mode is checked")
	for mode in Settings.AA_MODES:
		Settings.display["aa_mode"] = mode
		assert_eq(Hud.msaa_3d(), int(want[mode][0]), "%s: its MSAA" % mode)
		assert_eq(Hud.fxaa(), bool(want[mode][1]), "%s: the map's FXAA only in the FXAA mode" % mode)
		assert_true(Settings.AA_LABELS.has(mode), "%s has a label" % mode)
	Settings.display["aa_mode"] = "msaa16"
	assert_eq(Hud.aa_mode(), "msaa4", "a saved mode the game no longer knows reads as the default")
	Settings.display["aa_mode"] = "msaa4"
	OS.set_environment("RIFTGATE_AA", "fxaa")
	assert_true(Hud.fxaa() and Hud.msaa_3d() == SubViewport.MSAA_DISABLED, "RIFTGATE_AA=<mode> forces one for a run")
	OS.unset_environment("RIFTGATE_AA")
	if not was_env.is_empty():
		OS.set_environment("RIFTGATE_AA", was_env)
	Settings.display["aa_mode"] = was


func test_the_settings_page_offers_every_aa_mode() -> void:
	var menu := PauseMenu.new()
	menu._show_page("settings")
	var labels: Array = []
	for b in menu._rows.find_children("*", "", true, false):
		if b is HudButton:
			labels.append(str((b as HudButton).text))
	for mode in Settings.AA_MODES:
		assert_true(labels.has(str(Settings.AA_LABELS[mode])), "the settings page offers %s" % Settings.AA_LABELS[mode])
	menu.free()


func test_a_burn_weapon_wears_its_fire_on_its_class_and_nothing_else_does() -> void:
	var db := ContentDB.new()
	db.components = {"fire_gun": {"shape": "barrel", "face": {"keywords": ["burn"]}},
		"cold_gun": {"shape": "barrel", "face": {"keywords": ["pierce"]}},
		"bare_gun": {"shape": "barrel", "face": {}}}
	assert_true(MechView3D.burning("fire_gun", db), "a component whose entry's keywords hold burn burns")
	assert_false(MechView3D.burning("cold_gun", db), "one without burn does not")
	assert_false(MechView3D.burning("bare_gun", db), "nor one whose entry names no keywords")
	var rows := [[1, "fire_gun", "barrel", "minerva"], [2, "cold_gun", "barrel", "minerva"]]
	assert_eq(MechView3D.burn_rows("", rows, db), [[1, "fire_gun", "barrel"]], "a swapped burn weapon's mount takes its class's fire, and only it")


func test_a_flash_rises_holds_and_settles_back_to_rest() -> void:
	var rig := MechRig.new()
	var node := MeshInstance3D.new()
	node.mesh = BoxMesh.new()
	var lit := StandardMaterial3D.new()
	lit.emission_enabled = true
	lit.emission_energy_multiplier = 1.5
	node.set_surface_override_material(0, lit)
	rig.flash_under(node)
	rig._step(MechRig.FLASH_UP + MechRig.FLASH_HOLD * 0.5)
	assert_true(absf(lit.emission_energy_multiplier - 1.5 * MechRig.light(1.0 + MechRig.FLASH_PEAK)) < 0.001, "at its top it burns FLASH_PEAK rests over its own")
	rig._step(MechRig.FLASH_HOLD + MechRig.FLASH_DOWN)
	assert_true(absf(lit.emission_energy_multiplier - 1.5) < 0.001, "and settles back to its rest")
	node.free()



func test_a_weapon_flares_on_its_class_in_its_tags_look_and_equipment_never() -> void:
	var db := ContentDB.new()
	db.components = {"gun": {"shape": "twin_barrel", "tags": ["ballistic", "flame"], "face": {"kind": "attack"}},
		"lance": {"shape": "barrel", "tags": ["beam"], "face": {"kind": "attack"}},
		"ward": {"shape": "dish", "tags": [], "face": {"kind": "shield"}},
		"built": {"shape": "barrel", "tags": ["plasma"], "face": {"kind": "attack"}}}
	var pins := {1: Node3D.new(), 2: Node3D.new(), 3: Node3D.new(), 4: Node3D.new()}
	var by_hand := [[Vector3(0.0, 1.0, -20.0), 10.0]]
	var rows := [[1, "gun", "twin_barrel", MuzzleFlare.places("twin_barrel")], [2, "lance", "barrel", MuzzleFlare.places("barrel")],
		[3, "ward", "dish", MuzzleFlare.places("dish")], [4, "built", "", by_hand]]
	var flares := MechView3D.wear_flares(pins, rows, db)
	var by := {}
	for fl in flares:
		by[str(fl[1])] = int(by.get(str(fl[1]), 0)) + 1
		assert_false((fl[0] as Node3D).visible, "a flare waits hidden until its weapon fires")
	assert_eq(by.get("gun", 0), MuzzleFlare.places("twin_barrel").size() * 2, "a twin barrel flares at each muzzle, a layer a tag")
	assert_eq(by.get("lance", 0), 1, "a barrel at its one, in its one look")
	assert_false(by.has("ward"), "a shield's dish is no weapon and takes none")
	assert_eq(by.get("built", 0), 1, "a gun built by hand flares where its model says")
	for fl in flares:
		if str(fl[1]) == "gun":
			var first := str(fl[2]) == "ballistic"
			assert_eq(float(fl[3]), 0.0 if first else MuzzleFlare.LAYER_DELAY, "the shell flashes first, its fire a beat behind")
		if str(fl[1]) == "built":
			assert_eq((fl[0] as Node3D).position, Vector3(0.0, 1.0, -20.0), "at the place its model names")
	for n in pins.keys():
		(pins[n] as Node3D).free()


func test_the_tags_pick_a_flare_and_every_class_has_its_places() -> void:
	assert_eq(MuzzleFlare.looks_for(["arc", "ballistic"], "barrel"), ["ballistic", "arc"], "the slug's flash, then its lightning")
	assert_eq(MuzzleFlare.looks_for(["melee", "blade"], "blade"), ["blade"], "a melee piece throws a blade's sparks, once")
	assert_eq(MuzzleFlare.looks_for([], "rack"), ["missile"], "a rack with no tag puffs as a launcher")
	assert_eq(MuzzleFlare.looks_for([], "barrel"), ["ballistic"], "a barrel with none flashes as a gun")
	for t in MuzzleFlare.ORDER:
		assert_true(MuzzleFlare.BEATS.has("blade" if t == "melee" else t), "the tag %s has a beat" % t)
	for shape in ContentDB.SHAPES:
		if shape == ContentDB.SHAPE_NONE:
			continue
		assert_false(MuzzleFlare.places(shape).is_empty(), "the class %s has a muzzle to flare at" % shape)
	for look in MuzzleFlare.BEATS.keys():
		assert_eq(MuzzleFlare.strength(look, -0.01), 0.0, "%s: nothing before it fires" % look)
		assert_eq(MuzzleFlare.strength(look, MuzzleFlare.lasts(look)), 0.0, "%s: nothing once it is over" % look)
		var b: Dictionary = MuzzleFlare.BEATS[look]
		assert_true(MuzzleFlare.strength(look, float(b["up"]) + float(b["hold"]) * 0.5) > 0.2, "%s: lit through its hold" % look)


func test_each_weapon_turns_what_can_aim_it_and_a_quad_fires_where_it_points() -> void:
	# A fixed weapon turns the joint its model names (the sidecar's `aims`) or a waist; a machine
	# that turns on the spot (its sidecar's `pivots`: tracks, casters) turns its body for a gun on
	# its hull; a quad with neither fires where it points (Ryan, 31 October: "don't bother").
	var named := 0
	for id in ["badger", "clydesdale", "baboon", "armadillo", "wild_boar", "prairie_dog", "dingo", "nemesis", "ammit", "funnel_web"]:
		var view := MechView3D.make(id, "", "clean", "", MechView3D.YAW_FRONT, Vector2i(64, 64))
		var side := MechRig.load_sidecar(id)
		for cid in (side.get("aims", {}) as Dictionary).keys():
			named += 1
			assert_eq(view.aim_joint_for(str(cid)), str(side["aims"][cid]), "%s: %s turns its named joint" % [id, cid])
		var pins: Dictionary = side.get("pins", {})
		for pin in pins.keys():
			var cid := str(pins[pin])
			if cid.is_empty():
				continue
			var joint := view.aim_joint_for(cid)
			if bool(side.get("pivots", false)):
				assert_false(joint.is_empty(), "%s: %s aims, a turret or the body turning" % [id, cid])
			if id == "armadillo":
				assert_eq(joint, "", "the Armadillo's %s fires where it points" % cid)
		view.free()
	assert_true(named >= 2, "the fixed weapons riding a head or a turret name it (%d)" % named)


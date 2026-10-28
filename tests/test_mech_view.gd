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
	# record and the model's pins agree, so the engine never guesses a model's kit.
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
		assert_eq((rec as Array).size(), pins.size(), "%s: a record for every pin" % id)
		for n in pins.keys():
			assert_true(int(n) >= 1 and int(n) <= (rec as Array).size(), "%s: hp_%d is recorded" % [id, int(n)])
		model.free()


func test_a_turret_joint_traverses_and_a_limb_swings() -> void:
	assert_eq(MechView3D.joint_axis("turret"), Vector3(0, 1, 0), "a turret turns about its up axis")
	assert_eq(MechView3D.joint_axis("turret_l"), Vector3(0, 1, 0), "a named turret too")
	assert_eq(MechView3D.joint_axis("shoulder_l"), Vector3(1, 0, 0), "a limb swings about the axle line")

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


func test_model_for_falls_back_to_the_badger() -> void:
	assert_eq(MechView3D.model_for("badger", "badger"), "badger", "the Badger has a model")
	assert_eq(MechView3D.model_for("no_such_chassis", "badger"), "badger", "an unmodelled chassis borrows the fallback")


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
	# Stock: a gun, a rack, a gun, and plating that takes no mount: three mounts filled.
	var stock := ["slug_cannon", "missile_rack", "twin_autoguns", "ablative_plating"]
	var die := db.build_die(["chainsaw_claw", "chainsaw_claw"], stock, 4)
	assert_eq(MechView3D.mount_plan(die, stock, db), [], "the stock kit changes nothing")
	# The plating swapped for a vent: still no mount touched.
	die.faces[5] = db.build_face(db.components["heat_sink"]["face"])
	die.faces[5].component = "heat_sink"
	assert_eq(MechView3D.mount_plan(die, stock, db), [], "equipment without a shape shows nowhere")
	# The rack (die entry 4, mount 2) refitted with a Kestrel gun, the autoguns emptied: the
	# next shaped entry is the vent, which takes no mount, so mount 3 goes bare.
	die.faces[3] = db.build_face(db.components["lance"]["face"])
	die.faces[3].component = "lance"
	die.faces[4] = Face.empty_slot()
	var plan := MechView3D.mount_plan(die, stock, db)
	assert_eq(plan, [[2, "lance", "barrel", "wainwright_sutler"], [3, "", "", ""]], "mounts are counted over shaped entries, in the die's order, in the component's own metal")
	# Plating swapped for a shield projector: a dish takes the next mount, the fourth.
	die.faces[4] = db.build_face(db.components["twin_autoguns"]["face"])
	die.faces[4].component = "twin_autoguns"
	die.faces[5] = db.build_face(db.components["deflector"]["face"])
	die.faces[5].component = "deflector"
	assert_eq(MechView3D.mount_plan(die, stock, db), [[2, "lance", "barrel", "wainwright_sutler"], [4, "deflector", "dish", "kestrel"]], "a projector is gun-shaped enough to take a mount")
	assert_eq(MechView3D.mount_plan(null, stock, db), [], "no die, no plan")


func test_plan_for_reads_the_chassis_stock_from_content() -> void:
	var db := ContentDB.load_default()
	var u := db.make_mech("badger")
	assert_eq(MechView3D.plan_for(u, db), [], "a fresh machine wears its stock")
	var hp := 0
	for i in range(u.die.faces.size()):
		if not u.die.faces[i].fixed:
			hp = i
			break
	u.die.faces[hp] = db.build_face(db.components["pocket_mortar"]["face"])
	u.die.faces[hp].component = "pocket_mortar"
	assert_eq(MechView3D.plan_for(u, db), [[1, "pocket_mortar", "rack", "wainwright_sutler"]], "the first mount refitted")
	assert_eq(MechView3D.plan_from_spec("1:lance, 2:, x:y, 3:no_such, 4:heat_sink", db), [[1, "lance", "barrel", "wainwright_sutler"], [2, "", "", ""]], "the debug spec: a fit, a bared mount, junk and unshaped equipment skipped")


func test_a_turret_joint_traverses_and_a_limb_swings() -> void:
	assert_eq(MechView3D.joint_axis("turret"), Vector3(0, 1, 0), "a turret turns about its up axis")
	assert_eq(MechView3D.joint_axis("turret_l"), Vector3(0, 1, 0), "a named turret too")
	assert_eq(MechView3D.joint_axis("shoulder_l"), Vector3(1, 0, 0), "a limb swings about the axle line")

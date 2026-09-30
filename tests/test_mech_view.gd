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
		for maker in db.makers.keys():
			assert_true(MechView3D.has_model(MechView3D.shape_model(shape, maker)), "%s in %s is built" % [shape, maker])


func test_mount_plan_names_only_the_pins_that_differ_from_stock() -> void:
	var db := ContentDB.load_default()
	var stock := ["slug_cannon", "missile_rack", "twin_autoguns", "ablative_plating"]
	var die := db.build_die(["chainsaw_claw", "chainsaw_claw"], stock, 4)
	assert_eq(MechView3D.mount_plan(die, stock, db), [], "the stock kit changes nothing")
	# The third hardpoint refitted with a Kestrel gun, the fourth emptied.
	die.faces[4] = db.build_face(db.components["lance"]["face"])
	die.faces[4].component = "lance"
	die.faces[5] = Face.empty_slot()
	var plan := MechView3D.mount_plan(die, stock, db)
	assert_eq(plan.size(), 2, "two sockets change")
	assert_eq(plan[0], [3, "lance", str(db.components["lance"]["shape"]), "wainwright_sutler"], "the pin is numbered past the fixed entries, and the shape and metal are the component's own")
	assert_eq(plan[1], [4, "", "", ""], "an emptied socket bares its stock")
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
	u.die.faces[hp] = db.build_face(db.components["heat_sink"]["face"])
	u.die.faces[hp].component = "heat_sink"
	assert_eq(MechView3D.plan_for(u, db), [[1, "heat_sink", "vent_block", "wainwright_sutler"]], "the first hardpoint refitted")
	assert_eq(MechView3D.plan_from_spec("1:lance, 2:, x:y, 3:no_such", db), [[1, "lance", "barrel", "wainwright_sutler"], [2, "", "", ""]], "the debug spec: a fit, a bared socket, junk skipped")

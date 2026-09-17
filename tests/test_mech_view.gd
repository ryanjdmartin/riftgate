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

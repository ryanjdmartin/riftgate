extends TestCase

## The skirmish's looks of 29 October, judged as options (RIFTGATE_SKIRMISH_BG and
## RIFTGATE_SKIRMISH_LAYOUT, a debug build's GROUND and LAYOUT): every domain's bleed has a
## backdrop, the painter is the same for a seed, every look builds in both layouts, and the
## face-off stands the machines under the foes with the console under them.


func _screen(look: Dictionary) -> SkirmishScreen:
	Settings.look = look
	var db := ContentDB.load_default()
	var sk := Skirmish.new(3)
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		sk.add_mech(db.make_mech(id))
	var ghouls := Unit.pack(1, "ghouls", Vector2i.ZERO, "marsh", 2, 4, "revenant")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var screen := SkirmishScreen.new()
	screen.setup(sk)
	return screen


func test_every_domain_has_a_backdrop() -> void:
	# The palettes are keyed by a domain's bleed in content: a renamed bleed fails here until
	# the painter follows.
	var db := ContentDB.load_default()
	for fac in db.factions.keys():
		var bleed := str(db.factions[fac].get("bleed", ""))
		assert_true(BattleBackdrop.PALETTES.has(bleed), "%s's bleed %s has a backdrop" % [fac, bleed])


func test_the_backdrop_is_the_size_asked_and_the_same_for_a_seed() -> void:
	for biome in BattleBackdrop.PALETTES.keys():
		for t in BattleMap.TERRAIN_NAMES.keys():
			var img := BattleBackdrop.paint(str(biome), int(t), 5, Vector2i(180, 110), 30)
			assert_eq(img.get_size(), Vector2i(180, 110), "%s on %s is the size asked" % [biome, BattleMap.TERRAIN_NAMES[t]])
	var a := BattleBackdrop.paint("plains", BattleMap.Terrain.RUINS, 5, Vector2i(180, 110), 30)
	var b := BattleBackdrop.paint("plains", BattleMap.Terrain.RUINS, 5, Vector2i(180, 110), 30)
	assert_eq(a.get_data(), b.get_data(), "a seed paints the same backdrop every time")
	var c := BattleBackdrop.paint("plains", BattleMap.Terrain.RUINS, 6, Vector2i(180, 110), 30)
	assert_true(a.get_data() != c.get_data(), "another seed another")
	var first := str(BattleBackdrop.PALETTES.keys()[0])
	var unknown := BattleBackdrop.paint("no_such_bleed", BattleMap.Terrain.PLAIN, 5, Vector2i(180, 110), 30)
	var fallback := BattleBackdrop.paint(first, BattleMap.Terrain.PLAIN, 5, Vector2i(180, 110), 30)
	assert_eq(unknown.get_data(), fallback.get_data(), "a bleed with no palette paints the first")


func test_every_look_builds_in_both_layouts() -> void:
	var was: Dictionary = Settings.look.duplicate()
	for ground in Settings.LOOK_GROUNDS:
		for layout in Settings.LOOK_LAYOUTS:
			var s := _screen({"ground": ground, "layout": layout})
			assert_false(s._bg.grounds.is_empty(), "%s in the %s layout lays a ground" % [ground, layout])
			var foe: UnitView = s._slot_views[0][0]
			assert_eq(foe.ground_shadow, ground != "classic", "%s stands the foes on a floor or not" % ground)
			assert_eq(s._mech_views[0].ground_shadow, ground != "classic", "and the machines")
			s.free()
	Settings.look = was


func test_the_classic_look_is_the_overworld_bands() -> void:
	var was: Dictionary = Settings.look.duplicate()
	var s := _screen({"ground": "classic", "layout": "classic"})
	assert_eq(str(s._bg.grounds[0][3]), "other", "the foes on the other world's overworld")
	assert_eq(str(s._bg.grounds[1][3]), "seam", "the machines on the seam")
	assert_true(s._bg.glass.is_empty(), "no glass: the console stands on black")
	s.free()
	Settings.look = was


func test_the_face_off_stands_the_machines_under_the_foes() -> void:
	var was: Dictionary = Settings.look.duplicate()
	var s := _screen({"ground": "field", "layout": "faceoff"})
	assert_true(s.MECH_Y >= s.FRONT_Y + SkirmishScreen.SLOT_SIZE.y, "the machines stand under the front rank")
	assert_true(s.LOG_Y >= s.MECH_Y + SkirmishScreen.MECH_SIZE.y, "the log under the machines")
	assert_true(s.DIE_Y >= s.LOG_Y + SkirmishScreen.LOG_H, "the dice under the log")
	assert_true(s.REROLL_Y + SkirmishScreen.REROLL_SIZE.y <= s.BOTTOM_Y - 16.0, "Reroll clear of the bottom row")
	for i in range(s._dice.size()):
		assert_true(s._dice[i].position.y > s._mech_views[i].position.y + SkirmishScreen.MECH_SIZE.y, "die %d under its machine" % i)
		assert_true(absf(s._dice[i].position.x + SkirmishScreen.DIE_SIZE * 0.5 - (s._mech_views[i].position.x + SkirmishScreen.MECH_SIZE.x * 0.5)) < 30.0, "and in its column")
	# One scene: the floor runs from over the back rank to under the machines, nothing between.
	var field: Rect2 = s._bg.grounds[0][0]
	assert_true(field.position.y <= s.BACK_Y and field.end.y >= s.MECH_Y + SkirmishScreen.MECH_SIZE.y, "one floor under both sides")
	assert_true(s._bg.glass.is_empty(), "the console stands on black under the scene")
	s.free()
	Settings.look = was

extends TestCase


func _db() -> ContentDB:
	return ContentDB.load_default()


func test_content_loads() -> void:
	var db := _db()
	assert_true(db.load_errors.is_empty(), "no load errors: %s" % str(db.load_errors))
	assert_true(db.vocabulary.size() > 30, "vocabulary has entries")
	assert_true(db.chassis.size() >= 3, "chassis present")
	assert_true(db.components.size() >= 10, "components present")
	assert_true(db.foes.size() >= 6, "foes present")
	assert_eq(db.factions.size(), 3, "three factions")


func test_content_validates_clean() -> void:
	var errs := _db().validate()
	for e in errs:
		failures.append("content: " + e)
	checks += 1


func test_every_chassis_builds_a_full_die() -> void:
	var db := _db()
	for id in db.chassis.keys():
		var u := db.make_mech(id)
		assert_eq(u.die.size(), int(db.chassis[id]["hardpoints"]), "%s die size equals hardpoints" % id)
		for f in u.die.faces:
			assert_true(f.kind != Face.Kind.BLANK, "%s ships with no cracked faces" % id)


func test_raptor_loadout_matches_design() -> void:
	var db := _db()
	var u := db.make_mech("raptor")
	assert_eq(u.movespeed, 5, "raptor is fast")
	assert_true(u.traits.has("flyer"), "raptor flies")
	assert_false(u.can_block(), "and therefore does not block")
	var hot := 0
	for f in u.die.faces:
		if f.has(Face.Keyword.OVERCHARGE):
			hot += 1
	assert_eq(hot, 1, "one overcharge face")
	var p: Dictionary = db.chassis["raptor"]["passive"]
	assert_eq(p["rules"].size(), 2, "two rule lines")
	assert_true(not db.chassis["raptor"].has("passives"), "still counts as one passive")


func test_faction_pattern_unpacks_squads() -> void:
	var db := _db()
	var sq := Unit.squad(7, "risen", Vector2i.ZERO, "undead", 2, 6)
	var foes := db.foes_for(sq)
	assert_eq(foes.size(), 6, "six foes from strength six")
	var necros := 0
	for f in foes:
		assert_eq(f.squad_id, 7, "foe remembers its squad")
		if f.display_name == "Necromancer":
			necros += 1
			assert_true(f.prefers_back, "necromancer holds the back")
			assert_eq(f.injures, "corrode", "necromancer corrodes")
	assert_eq(necros, 1, "one necromancer per four")


func test_elite_squad_brings_a_massive_foe() -> void:
	var db := _db()
	var sq := Unit.squad(7, "risen", Vector2i.ZERO, "undead", 2, 4)
	sq.elite = true
	var foes := db.foes_for(sq)
	assert_eq(foes.size(), 5, "four from the pattern plus the elite")
	assert_true(foes[0].is_massive(), "elite comes first so it takes a column")
	assert_eq(foes[0].display_name, "Bone Colossus", "undead elite")
	var boss := Unit.boss(8, "colossus", Vector2i.ZERO, "demonic")
	var only := db.foes_for(boss)
	assert_eq(only.size(), 1, "a boss unpacks to just its elite")
	assert_eq(only[0].display_name, "Pit Lord", "demonic elite")


func test_content_mech_survives_a_skirmish_round() -> void:
	var db := _db()
	var sk := Skirmish.new(5)
	sk.add_mech(db.make_mech("bulwark"))
	sk.add_mech(db.make_mech("sentinel"))
	var sq := Unit.squad(1, "risen", Vector2i.ZERO, "undead", 2, 6)
	sk.add_foes(db.foes_for(sq), sq)
	sk.begin()
	sk.start_round()
	for i in range(sk.mechs.size()):
		var t := sk.targets_for(i)
		if not t.is_empty():
			sk.assign(i, t[0])
		else:
			sk.assign(i, null)
	var out := sk.end_round()
	assert_eq(out, Skirmish.Outcome.NONE, "fight continues after one round")
	assert_true(sk.survivors_for(sq) <= 6, "survivor count sane")


func test_keyword_cap_is_enforced() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var comp: Dictionary = db.components["lance"].duplicate(true)
	comp["faces"][0]["keywords"] = ["pierce", "burn", "chain", "execute"]
	db.components["too_many"] = comp
	var errs := db.validate()
	var hit := false
	for e in errs:
		if e.begins_with("component too_many") and e.contains("authored cap"):
			hit = true
	assert_true(hit, "four keywords on an authored face is reported")


func test_passive_rule_cap_is_enforced() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["raptor"].duplicate(true)
	c["passive"]["rules"] = ["a", "b", "c", "d"]
	db.chassis["bloated"] = c
	var errs := db.validate()
	var hit := false
	for e in errs:
		if e.begins_with("chassis bloated") and e.contains("rule lines"):
			hit = true
	assert_true(hit, "four rule lines in one passive is reported")


func test_raptor_passive_doubles_damage_and_heat() -> void:
	var db := _db()
	var u := db.make_mech("raptor")
	assert_false(u.passive.is_empty(), "raptor carries its passive")
	u.die = Die.single(Face.attack(3, Face.Reach.LINE, [], 1))
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([Foe.make("ghoul", 9, 1)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 3, "power 3 became 6")
	assert_eq(sk.mechs[0].heat, 2, "heat 1 became 2")


func test_unsupported_passive_effect_is_rejected() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["raptor"].duplicate(true)
	c["passive"]["effects"] = [{"trigger": "on_attack", "effect": "summon_dragon", "value": 1}]
	db.chassis["dreamer"] = c
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis dreamer") and e.contains("not implemented"):
			hit = true
	assert_true(hit, "an effect the engine cannot run is reported")


func test_face_round_trips_through_json() -> void:
	var f := Face.attack(3, Face.Reach.INDIRECT, [Face.Keyword.BURN, Face.Keyword.SUPPRESS], 2)
	var back := Face.from_dict(f.to_dict())
	assert_eq(back.describe(), f.describe(), "describe matches after round trip")
	assert_true(back.has(Face.Keyword.BURN) and back.has(Face.Keyword.SUPPRESS), "both keywords kept")

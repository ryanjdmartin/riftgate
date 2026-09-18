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
		var c: Dictionary = db.chassis[id]
		assert_eq(u.die.size(), c.get("fixed", []).size() + int(c["hardpoints"]), "%s die size is fixed plus hardpoints" % id)
		assert_eq(u.hardpoints, int(c["hardpoints"]), "%s knows its free slots" % id)
		for f in u.die.faces:
			assert_true(f.kind != Face.Kind.BLANK, "%s ships with every hardpoint filled and nothing broken" % id)
			assert_false(f.component.is_empty(), "%s: every entry names its component" % id)
		for i in range(c.get("fixed", []).size()):
			assert_eq(u.die.faces[i].component, str(c["fixed"][i]), "%s: fixed components come first" % id)


func test_build_die_leaves_empty_hardpoints_empty() -> void:
	var db := _db()
	var d := db.build_die(["chainsaw_claw"], ["slug_cannon"], 3)
	assert_eq(d.size(), 4, "one fixed plus three hardpoints")
	assert_eq(d.faces[0].component, "chainsaw_claw", "the fixed claw first")
	assert_eq(d.faces[1].component, "slug_cannon", "then the loadout")
	assert_true(d.faces[2].empty and d.faces[3].empty, "two hardpoints left empty stay empty")
	assert_true(d.faces[0].fixed and not d.faces[1].fixed and not d.faces[2].fixed, "only the claw is fixed; the rest are hardpoints")
	assert_eq(d.faces[2].describe(), "empty hardpoint", "and say so")


func test_chassis_validator_guards_hardpoints() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["raptor"].duplicate(true)
	c["loadout"] = ["deflector", "deflector", "deflector", "deflector", "deflector"]
	db.chassis["over"] = c
	var f: Dictionary = db.chassis["badger"].duplicate(true)
	f["loadout"] = ["chainsaw_claw"]
	db.chassis["twice"] = f
	var g: Dictionary = db.chassis["raptor"].duplicate(true)
	g["filler"] = {"kind": "shield", "power": 10}
	db.chassis["stuffed"] = g
	var over := false
	var twice := false
	var stuffed := false
	for e in db.validate():
		if e.begins_with("chassis over") and e.contains("into 4 hardpoints"):
			over = true
		if e.begins_with("chassis twice") and e.contains("is fixed"):
			twice = true
		if e.begins_with("chassis stuffed") and e.contains("filler is gone"):
			stuffed = true
	assert_true(over, "more components than hardpoints is refused")
	assert_true(twice, "a fixed component in the loadout is refused")
	assert_true(stuffed, "filler is refused")


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
	assert_eq(p["effects"].size(), 2, "two effects, one idea")
	assert_true(not p.has("rules"), "no rules text: the description says what it does")
	assert_true(not db.chassis["raptor"].has("passives"), "still counts as one passive")


func test_squads_unpack_by_foe_type() -> void:
	var db := _db()
	var ghouls := Unit.squad(7, "ghouls", Vector2i.ZERO, "undead", 2, 6, "ghoul")
	var foes := db.foes_for(ghouls)
	assert_eq(foes.size(), 6, "six ghouls from strength six")
	for f in foes:
		assert_eq(f.display_name, "Ghoul", "all the same type")
		assert_eq(f.squad_id, 7, "foe remembers its squad")
	var necros := Unit.squad(8, "necromancers", Vector2i.ZERO, "undead", 2, 2, "necromancer")
	var backs := db.foes_for(necros)
	assert_eq(backs.size(), 2, "two necromancers")
	assert_true(backs[0].prefers_back, "necromancer holds the back")
	var untyped := Unit.squad(9, "whatever", Vector2i.ZERO, "demonic", 2, 3)
	var fallback := db.foes_for(untyped)
	assert_eq(fallback.size(), 3, "a squad with no type falls back to the faction's first spawn entry")
	assert_eq(fallback[0].display_name, "Brute", "which is the brute for demons")


func test_boss_unpacks_to_the_faction_boss() -> void:
	var db := _db()
	var boss := Unit.boss(8, "colossus", Vector2i.ZERO, "undead")
	var only := db.foes_for(boss)
	assert_eq(only.size(), 1, "a boss unpacks to just its massive foe")
	assert_eq(only[0].display_name, "Bone Colossus", "undead boss")
	assert_true(only[0].is_massive(), "and it is massive")
	var pit := db.foes_for(Unit.boss(9, "lord", Vector2i.ZERO, "demonic"))
	assert_eq(pit[0].display_name, "Pit Lord", "demonic boss")


func test_spawn_table_lists_the_factions_formation() -> void:
	var db := _db()
	var table := db.spawn_table("undead")
	assert_eq(table.size(), 3, "three squads come through together")
	assert_eq(table[0][0], "ghoul", "ghouls first")
	assert_eq(table[2][0], "necromancer", "necromancers behind them")
	assert_eq(table[2][1], 3, "three of them")
	assert_eq(db.faction_of_foe("hellcaster"), "demonic", "foe to faction lookup")


func test_content_mech_survives_a_skirmish_round() -> void:
	var db := _db()
	var sk := Skirmish.new(5)
	sk.add_mech(db.make_mech("badger"))
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
	comp["face"]["keywords"] = ["pierce", "burn", "chain", "execute"]
	db.components["too_many"] = comp
	var errs := db.validate()
	var hit := false
	for e in errs:
		if e.begins_with("component too_many") and e.contains("authored cap"):
			hit = true
	assert_true(hit, "four keywords on an authored face is reported")


func test_passive_effect_cap_is_enforced() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["raptor"].duplicate(true)
	var eff: Dictionary = c["passive"]["effects"][0]
	c["passive"]["effects"] = [eff, eff, eff, eff]
	db.chassis["bloated"] = c
	var errs := db.validate()
	var hit := false
	for e in errs:
		if e.begins_with("chassis bloated") and e.contains("effects, cap"):
			hit = true
	assert_true(hit, "four effects in one passive is reported")


func test_internal_text_cannot_sit_at_the_top_level() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["raptor"].duplicate(true)
	c["fantasy"] = "would be shown"
	db.chassis["leaky"] = c
	var f: Dictionary = db.foes["ghoul"].duplicate(true)
	f.erase("design")
	db.foes["bare"] = f
	var errs := db.validate()
	var leak := false
	var bare := false
	for e in errs:
		if e.begins_with("chassis leaky") and e.contains("belongs under design"):
			leak = true
		if e.begins_with("foe bare") and e.contains("missing design"):
			bare = true
	assert_true(leak, "fantasy at the top level is refused")
	assert_true(bare, "an entry without design is refused")


func test_raptor_passive_doubles_damage_and_heat() -> void:
	var db := _db()
	var u := db.make_mech("raptor")
	assert_false(u.passive.is_empty(), "raptor carries its passive")
	u.die = Die.single(Face.attack(30, Face.Reach.LINE, [], 10))
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([Foe.make("ghoul", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 30, "power 30 became 60")
	assert_eq(sk.mechs[0].heat, 20, "heat 10 became 20")


func test_min_damage_passive_raises_the_floor() -> void:
	# The engine's damage floor, on a synthetic passive: content is Ryan's and changes.
	var floor_passive := {"id": "floor", "name": "Floor", "description": "", "effects": [{"trigger": "on_attack", "effect": "min_damage", "value": 30}]}
	assert_eq(Passives.on_attack(floor_passive, 12, 0), [30, 0], "a 12 is lifted to 30")
	assert_eq(Passives.on_attack(floor_passive, 45, 5), [45, 5], "a 45 stays")


func test_planned_passive_is_kept_but_not_run() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["raptor"].duplicate(true)
	c["passive"] = {"id": "draft", "name": "Draft", "description": "Not built yet.", "status": "planned",
		"effects": [{"trigger": "on_sunrise", "effect": "immune_destroy", "value": 1}]}
	db.chassis["drafted"] = c
	var errs := db.validate()
	for e in errs:
		assert_false(e.begins_with("chassis drafted"), "a planned passive with an unbuilt effect validates clean: %s" % e)
	assert_eq(Passives.on_attack(c["passive"], 10, 0), [10, 0], "the engine ignores a planned passive")
	assert_false(Passives.active(c["passive"]), "not active")
	c["passive"]["status"] = "implemented"
	db.chassis["drafted"] = c
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis drafted") and e.contains("unknown trigger"):
			hit = true
	assert_true(hit, "the same passive marked implemented is refused until the engine has the trigger")


func test_anvil_passive_burns_on_crit() -> void:
	var db := _db()
	var u := db.make_mech("anvil")
	u.die = Die.single(Face.attack(20, Face.Reach.INDIRECT, [], 0, 0, 100))
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([Foe.make("ghoul", 200, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 160, "20 crit for 40")
	assert_eq(sk.front[0].burn, 1, "Hot Load added a burn stack")


func test_content_dice_are_in_tens_and_kinetic_faces_roll() -> void:
	var db := _db()
	var kinetic := 0
	var energy := 0
	for id in db.components.keys():
		var c: Dictionary = db.components[id]
		for fd in [c.get("face", {})]:
			assert_true(int(fd.get("power", 0)) % 10 == 0, "%s power is a multiple of ten" % id)
			if str(fd.get("kind", "")) != "attack":
				continue
			var tags: Array = c.get("tags", [])
			if tags.has("kinetic"):
				kinetic += 1
				assert_true(int(fd.get("power_max", 0)) > int(fd["power"]), "%s kinetic face has a range" % id)
			if tags.has("energy"):
				energy += 1
				assert_false(fd.has("power_max"), "%s energy face is static" % id)
				assert_eq(int(fd.get("crit", 0)), 0, "%s energy face never crits" % id)
	assert_true(kinetic >= 5 and energy >= 3, "both weapon classes present")


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


func test_every_foe_has_an_action_roster_and_player_text() -> void:
	var db := ContentDB.load_default()
	for id in db.foes.keys():
		var f: Dictionary = db.foes[id]
		assert_true(not str(f.get("codex", "")).is_empty(), "%s has codex text" % id)
		assert_true(not str(f.get("flavour", "")).is_empty(), "%s has its own flavour line" % id)
		var implemented := 0
		for a in f.get("actions", []):
			if a.get("status") == "implemented":
				implemented += 1
				assert_eq(int(a.get("value", -1)), int(f["attack"]), "%s basic attack matches its attack" % id)
		assert_eq(implemented, 1, "%s has exactly one implemented action" % id)
	var foe := db.make_foe("ghoul")
	var entry := db.codex_for_foe(foe)
	assert_true(entry["actions"].contains("CLAW"), "codex lists the implemented action")
	assert_false(entry["actions"].contains("GET BACK UP"), "and hides the planned one")
	assert_eq(entry["flavour"], db.foes["ghoul"]["flavour"], "codex quotes the foe, not the faction")


func test_planned_actions_cannot_claim_to_be_implemented() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var f: Dictionary = db.foes["ghoul"].duplicate(true)
	f["actions"][1]["status"] = "implemented"
	db.foes["ghoul"] = f
	var hit := false
	for e in db.validate():
		if e.begins_with("foe ghoul action get_back_up") and e.contains("only attack"):
			hit = true
	assert_true(hit, "a non-attack action marked implemented is reported")


func test_face_round_trips_through_json() -> void:
	var f := Face.attack(3, Face.Reach.INDIRECT, [Face.Keyword.BURN, Face.Keyword.SUPPRESS], 2)
	var back := Face.from_dict(f.to_dict())
	assert_eq(back.describe(), f.describe(), "describe matches after round trip")
	assert_true(back.has(Face.Keyword.BURN) and back.has(Face.Keyword.SUPPRESS), "both keywords kept")

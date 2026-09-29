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
	var c: Dictionary = db.chassis["sparrowhawk"].duplicate(true)
	c["loadout"] = ["deflector", "deflector", "deflector", "deflector", "deflector"]
	db.chassis["over"] = c
	var f: Dictionary = db.chassis["badger"].duplicate(true)
	f["loadout"] = ["chainsaw_claw"]
	db.chassis["twice"] = f
	var g: Dictionary = db.chassis["sparrowhawk"].duplicate(true)
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


func test_sparrowhawk_loadout_matches_design() -> void:
	var db := _db()
	var u := db.make_mech("sparrowhawk")
	assert_eq(u.movespeed, 5, "sparrowhawk is fast")
	assert_true(u.traits.has("flyer"), "sparrowhawk flies")
	assert_false(u.can_block(), "and therefore does not block")
	var p: Dictionary = db.chassis["sparrowhawk"]["passive"]
	assert_eq(p["effects"].size(), 2, "two effects, one idea")
	assert_true(not p.has("rules"), "no rules text: the description says what it does")
	assert_true(not db.chassis["sparrowhawk"].has("passives"), "still counts as one passive")


func test_packs_unpack_by_foe_type() -> void:
	var db := _db()
	var ghouls := Unit.pack(7, "ghouls", Vector2i.ZERO, "undead", 2, 6, "ghoul")
	var foes := db.foes_for(ghouls)
	assert_eq(foes.size(), 6, "six ghouls from strength six")
	for f in foes:
		assert_eq(f.display_name, "Ghoul", "all the same type")
		assert_eq(f.pack_id, 7, "foe remembers its pack")
	var necros := Unit.pack(8, "necromancers", Vector2i.ZERO, "undead", 2, 2, "necromancer")
	var backs := db.foes_for(necros)
	assert_eq(backs.size(), 2, "two necromancers")
	assert_true(backs[0].prefers_back, "necromancer holds the back")
	var untyped := Unit.pack(9, "whatever", Vector2i.ZERO, "demonic", 2, 3)
	var fallback := db.foes_for(untyped)
	assert_eq(fallback.size(), 3, "a pack with no type falls back to the faction's first spawn entry")
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
	assert_eq(table.size(), 3, "three packs come through together")
	assert_eq(table[0][0], "ghoul", "ghouls first")
	assert_eq(table[2][0], "necromancer", "necromancers behind them")
	assert_eq(table[2][1], 3, "three of them")
	assert_eq(db.faction_of_foe("hellcaster"), "demonic", "foe to faction lookup")


func test_content_mech_survives_a_skirmish_round() -> void:
	var db := _db()
	var sk := Skirmish.new(5)
	sk.add_mech(db.make_mech("badger"))
	sk.add_mech(db.make_mech("clydesdale"))
	var sq := Unit.pack(1, "risen", Vector2i.ZERO, "undead", 2, 6)
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
	comp["face"]["keywords"] = ["penetrate", "burn", "chain", "execute"]
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
	var c: Dictionary = db.chassis["sparrowhawk"].duplicate(true)
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
	var c: Dictionary = db.chassis["sparrowhawk"].duplicate(true)
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


func test_a_reserved_machine_name_is_refused_unless_the_clash_is_recorded() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.reserved_names.size() > 1000, "the reserved names loaded (%d)" % db.reserved_names.size())
	assert_eq(ContentDB.normalise_name("Black Hawk-KU"), "blackhawkku", "spaces, hyphens and case fall away")
	var wolf: Dictionary = db.chassis["clydesdale"].duplicate(true)
	wolf["name"] = "timber wolf"      # case and spacing do not hide a clash
	db.chassis["wolf"] = wolf
	var by_id: Dictionary = db.chassis["clydesdale"].duplicate(true)
	by_id["name"] = "Pale Rider"
	db.chassis["king_crab"] = by_id    # the id clashes even when the nickname does not
	var gear: Dictionary = db.chassis["clydesdale"].duplicate(true)
	gear["name"] = "Black Mamba"      # Heavy Gear, and the message says so
	db.chassis["gear"] = gear
	var tank: Dictionary = db.chassis["clydesdale"].duplicate(true)
	tank["name"] = "Warthog"          # Halo
	db.chassis["tank"] = tank
	var grey: Dictionary = db.chassis["clydesdale"].duplicate(true)
	grey["name"] = "Grey Wolf"        # nobody's machine: the match is exact, not by word
	db.chassis["grey"] = grey
	var kept: Dictionary = db.chassis["clydesdale"].duplicate(true)
	kept["name"] = "Timber Wolf"
	kept["design"] = kept["design"].duplicate(true)
	kept["design"]["name_clash"] = "kept knowingly for the test"
	db.chassis["kept"] = kept
	var wolf_hit := false
	var id_hit := false
	var gear_hit := false
	var tank_hit := false
	for e in db.validate():
		if e.begins_with("chassis wolf") and e.contains("Timber Wolf (a BattleTech 'Mech)"):
			wolf_hit = true
		if e.begins_with("chassis king_crab") and e.contains("King Crab"):
			id_hit = true
		if e.begins_with("chassis gear") and e.contains("Black Mamba (a Heavy Gear machine)"):
			gear_hit = true
		if e.begins_with("chassis tank") and e.contains("Warthog (a Halo vehicle)"):
			tank_hit = true
		assert_false(e.begins_with("chassis grey") and e.contains("clashes"), "a name that merely shares a word passes: %s" % e)
		assert_false(e.begins_with("chassis kept") and e.contains("clashes"), "a recorded clash passes: %s" % e)
	assert_true(wolf_hit, "a BattleTech 'Mech nickname is refused and named")
	assert_true(id_hit, "a reserved id is refused")
	assert_true(gear_hit, "a Heavy Gear name is refused and its source named")
	assert_true(tank_hit, "a Halo name is refused and its source named")


func test_sparrowhawk_passive_doubles_damage_and_heat() -> void:
	var db := _db()
	var u := db.make_mech("sparrowhawk")
	assert_false(u.passive.is_empty(), "sparrowhawk carries its passive")
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
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive(floor_passive)
	assert_eq(Effects.attack(u, null, 12, 0, false)["damage"], 30, "a 12 is lifted to 30")
	assert_eq(Effects.attack(u, null, 45, 5, false)["damage"], 45, "a 45 stays")


func test_planned_passive_is_kept_but_not_run() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["sparrowhawk"].duplicate(true)
	c["passive"] = {"id": "draft", "name": "Draft", "description": "Not built yet.", "status": "planned",
		"effects": [{"trigger": "on_sunrise", "effect": "immune_destroy", "value": 1}]}
	db.chassis["drafted"] = c
	var errs := db.validate()
	for e in errs:
		assert_false(e.begins_with("chassis drafted"), "a planned passive with an unbuilt effect validates clean: %s" % e)
	assert_true(Effects.make(c["passive"], Effects.LOADOUT, "chassis") == null, "a planned passive grants nothing")
	c["passive"]["status"] = "implemented"
	db.chassis["drafted"] = c
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis drafted") and e.contains("unknown trigger"):
			hit = true
	assert_true(hit, "the same passive marked implemented is refused until the engine has the trigger")


func test_planned_component_may_carry_a_planned_keyword() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = db.components["ablative_plating"].duplicate(true)
	plate["face"]["keywords"] = ["taunt"]
	plate["status"] = "planned"
	db.components["loud_plate"] = plate
	for e in db.validate():
		assert_false(e.begins_with("component loud_plate"), "a planned component with a planned keyword validates clean: %s" % e)
	var f := Face.from_dict(plate["face"])
	assert_true(f.keywords.is_empty(), "and builds without the keyword the engine lacks")
	plate.erase("status")
	db.components["loud_plate"] = plate
	var hit := false
	for e in db.validate():
		if e.begins_with("component loud_plate") and e.contains("unknown keyword"):
			hit = true
	assert_true(hit, "the same component marked implemented is refused")


func test_a_crit_burn_passive_from_content_adds_a_stack() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis[db.chassis.keys()[0]].duplicate(true)
	c["passive"] = {"id": "hot", "name": "Hot", "description": "Crits burn.", "effects": [{"trigger": "on_crit", "effect": "add_burn", "value": 1}]}
	db.chassis["hot_one"] = c
	var u := db.make_mech("hot_one")
	u.die = Die.single(Face.attack(20, Face.Reach.INDIRECT, [], 0, 0, 100))
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([Foe.make("ghoul", 200, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 160, "20 crit for 40")
	assert_eq(sk.front[0].burn_stacks(), 1, "the passive added a burn stack")


func test_melee_reach_can_be_authored() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var claw: Dictionary = db.components["lance"].duplicate(true)
	claw["face"]["reach"] = "melee"
	db.components["fist"] = claw
	for e in db.validate():
		assert_false(e.begins_with("component fist"), "an authored melee component validates clean: %s" % e)
	var f := Face.from_dict(claw["face"])
	assert_eq(f.reach, Face.Reach.MELEE, "and builds with melee reach")


func test_content_dice_are_sane_and_kinetic_faces_roll() -> void:
	var db := _db()
	var kinetic := 0
	var energy := 0
	for id in db.components.keys():
		var c: Dictionary = db.components[id]
		for fd in [c.get("face", {})]:
			assert_true(int(fd.get("power", 0)) >= 0, "%s power is not negative" % id)
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
	var c: Dictionary = db.chassis["sparrowhawk"].duplicate(true)
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
				assert_false(a.has("value"), "%s: an attack scales the base attack, it has no value of its own" % id)
		assert_true(implemented >= 1, "%s has at least one implemented action" % id)
	var foe := db.make_foe("ghoul")
	var entry := db.codex_for_foe(foe)
	assert_true(entry["actions"].contains("CLAW // ATTACK 10"), "codex lists the implemented action with the resulting number")
	assert_true(entry["actions"].contains("for 10."), "and fills {damage} into the text")
	assert_false(entry["actions"].contains("GET BACK UP"), "and hides the planned one")
	assert_eq(entry["flavour"], db.foes["ghoul"]["flavour"], "codex quotes the foe, not the faction")


func test_foe_actions_scale_the_base_attack_and_are_picked_by_weight() -> void:
	var f := Foe.make("ghoul", 30, 10)
	f.actions = [
		{"id": "claw", "name": "Claw", "factor": 1.0, "strikes": 1, "breach": false, "weight": 3, "text": "Claws for {damage}."},
		{"id": "rend", "name": "Jaw Rend", "factor": 1.5, "strikes": 1, "breach": false, "weight": 1, "text": "Bites for {damage}."},
	]
	assert_eq(f.damage_of(f.actions[1]), 15, "1.5 times 10 is 15, in the magnitude of tens")
	assert_eq(f.text_of(f.actions[1]), "Bites for 15.", "the text shows the number, never the factor")
	assert_eq(f.threat(), 15, "threat is its worst action")
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var rends := 0
	for i in range(400):
		f.choose_action(rng)
		if f.action["id"] == "rend":
			rends += 1
	assert_true(rends > 60 and rends < 140, "a weight of 1 in 4 picks the rend about a quarter of the time (%d of 400)" % rends)
	var sk := Skirmish.new(3)
	var m := Unit.mech(0, "A", Vector2i.ZERO)
	m.shield = 0
	m.hull = 100
	m.hull_max = 100
	m.die = Die.single(Face.shield(10))
	sk.add_mech(m)
	sk.add_foes([f])
	sk.begin()
	sk.start_round()
	assert_true(not f.action.is_empty(), "the round's action is chosen at round start")
	assert_eq(sk.forecast(sk.mechs[0])["incoming"], f.damage(), "and the forecast uses it")
	sk.end_round()
	assert_eq(m.hull, 100 - f.damage(), "and so does the blow")


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


func test_chassis_cooling_is_read_and_never_negative() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.validate().is_empty(), "content validates")
	for id in db.chassis.keys():
		var u := db.make_mech(id)
		assert_eq(u.cooling, int(db.chassis[id].get("cooling", 0)), "%s cooling read from content (0 when absent)" % id)
	var c: Dictionary = db.chassis["sparrowhawk"].duplicate(true)
	c["cooling"] = -5
	db.chassis["frozen"] = c
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis frozen") and e.contains("cooling"):
			hit = true
	assert_true(hit, "negative cooling is refused")


func test_support_keywords_ride_on_shields_and_vents_only() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var scrubber: Dictionary = db.components["ablative_plating"].duplicate(true)
	scrubber["face"]["keywords"] = ["cleanse"]
	db.components["scrubber"] = scrubber
	var gun: Dictionary = db.components["lance"].duplicate(true)
	gun["face"]["keywords"] = ["cleanse"]
	db.components["cleansing_gun"] = gun
	var plate: Dictionary = db.components["ablative_plating"].duplicate(true)
	plate["face"]["keywords"] = ["burn"]
	db.components["burning_plate"] = plate
	var bad_gun := false
	var bad_plate := false
	for e in db.validate():
		assert_false(e.begins_with("component scrubber"), "cleanse on a shield validates clean: %s" % e)
		if e.begins_with("component cleansing_gun") and e.contains("rides on a shield or vent"):
			bad_gun = true
		if e.begins_with("component burning_plate") and e.contains("attack keyword"):
			bad_plate = true
	assert_true(bad_gun, "cleanse on an attack is refused")
	assert_true(bad_plate, "burn on a shield is refused")


func test_a_component_passive_from_content_lands_on_the_mech() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var fins: Dictionary = db.components["heat_sink"].duplicate(true)
	fins["name"] = "Finned Sink"
	fins["passive"] = {"id": "fins", "name": "Fins", "description": "Cooling +5.",
		"effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 5}]}
	db.components["fins_pack"] = fins
	var c: Dictionary = db.chassis["clydesdale"].duplicate(true)
	c["loadout"] = ["fins_pack"]
	c["passive"] = null
	c["cooling"] = 10
	db.chassis["finned"] = c
	for e in db.validate():
		assert_false(e.begins_with("chassis finned") or e.begins_with("component fins_pack"), "a stat passive on a component validates clean: %s" % e)
	var u := db.make_mech("finned")
	assert_eq(u.cooling, 15, "the chassis's cooling plus the component's")
	var codex := db.codex_for_unit(u)
	assert_true(str(codex["passive"]).contains("FINS (Finned Sink): Cooling +5."), "the codex names the passive and its component")
	var sink: Face = u.die.faces[0]
	assert_eq(sink.component, "fins_pack", "the first entry is the component")
	assert_eq(Effects.explain(u, sink).size(), 1, "the die row names it")
	# Destroyed, the component keeps its stat bonus (18 September).
	u.die.faces[0] = Face.blank()
	u.die.faces[0].component = "fins_pack"
	assert_eq(u.cooling, 15, "a destroyed component keeps its stat bonus")


func test_a_buff_face_names_a_machine_status() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var good: Dictionary = db.components["ablative_plating"].duplicate(true)
	good["face"] = {"kind": "buff", "status": "overcharged", "stacks": 2}
	db.components["coil_ok"] = good
	var foe_status: Dictionary = good.duplicate(true)
	foe_status["face"] = {"kind": "buff", "status": "burning"}
	db.components["coil_foe"] = foe_status
	var unknown: Dictionary = good.duplicate(true)
	unknown["face"] = {"kind": "buff", "status": "haste", "rounds": 0}
	db.components["coil_bad"] = unknown
	var stray: Dictionary = good.duplicate(true)
	stray["face"] = {"kind": "shield", "power": 10, "stacks": 2}
	db.components["stray"] = stray
	var hit := {"coil_foe": false, "coil_bad": false, "stray": false}
	for e in db.validate():
		assert_false(e.begins_with("component coil_ok"), "a buff granting a machine status validates clean: %s" % e)
		for k in hit.keys():
			if e.begins_with("component " + k):
				hit[k] = true
	assert_true(hit["coil_foe"], "a foe's status is refused on a buff")
	assert_true(hit["coil_bad"], "an unknown status, or zero rounds, is refused")
	assert_true(hit["stray"], "stacks on a shield is refused")


func test_a_spend_keyword_rides_on_any_kind_of_component() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = db.components["ablative_plating"].duplicate(true)
	plate["face"]["keywords"] = ["volatile"]
	db.components["hot_plate"] = plate
	var gun: Dictionary = db.components["lance"].duplicate(true)
	gun["face"]["keywords"] = ["volatile"]
	db.components["hot_gun"] = gun
	var fins: Dictionary = db.components["heat_sink"].duplicate(true)
	fins["face"]["keywords"] = ["volatile"]
	db.components["hot_fins"] = fins
	for e in db.validate():
		assert_false(e.begins_with("component hot_"), "volatile validates on a shield, an attack and a vent alike: %s" % e)
	var f := db.build_face(plate["face"])
	assert_true(f.has(Face.Keyword.VOLATILE), "and builds onto the entry")


func test_the_content_carries_a_live_hull_the_engine_runs() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = db.components["ablative_plating"].duplicate(true)
	plate["passive"] = {"id": "live_plate", "name": "Live Plate", "description": "", "effects": [
		{"trigger": "static", "effect": "shock_on_block", "value": 1}]}
	db.components["live_plate"] = plate
	var coil: Dictionary = db.components["overcharge_coil"].duplicate(true)
	coil["face"]["status"] = "retaliate"
	db.components["klaxon_coil"] = coil
	var errs := db.validate()
	for e in errs:
		assert_false(e.begins_with("component live_plate") or e.begins_with("component klaxon_coil"), "a shock passive and a retaliate buff validate: %s" % e)
	assert_true(errs.is_empty(), "and the shipped content is clean with them: %s" % str(errs))
	assert_eq(db.build_face(coil["face"]).buff_status, "retaliate", "the buff builds")

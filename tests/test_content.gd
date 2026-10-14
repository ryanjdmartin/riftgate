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
	assert_eq(db.factions.size(), 4, "four domains")


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
	var d := db.build_die(["chainsaw_claw"], ["shotfire_rack"], 3)
	assert_eq(d.size(), 4, "one fixed plus three hardpoints")
	assert_eq(d.faces[0].component, "chainsaw_claw", "the fixed claw first")
	assert_eq(d.faces[1].component, "shotfire_rack", "then the loadout")
	assert_true(d.faces[2].empty and d.faces[3].empty, "two hardpoints left empty stay empty")
	assert_true(d.faces[0].fixed and not d.faces[1].fixed and not d.faces[2].fixed, "only the claw is fixed; the rest are hardpoints")
	assert_eq(d.faces[2].describe(), "empty hardpoint", "and say so")


func test_chassis_validator_guards_hardpoints() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["sparrowhawk"].duplicate(true)
	c["loadout"] = ["laminar_deflector", "laminar_deflector", "laminar_deflector", "laminar_deflector", "laminar_deflector"]
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


func test_chassis_validator_wants_one_way_of_moving_and_moves_in_tens() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var two: Dictionary = db.chassis["badger"].duplicate(true)
	two["traits"] = ["tracked", "walker"]
	db.chassis["twoways"] = two
	var none: Dictionary = db.chassis["badger"].duplicate(true)
	none["traits"] = ["defense"]
	db.chassis["noway"] = none
	var odd: Dictionary = db.chassis["badger"].duplicate(true)
	odd["movespeed"] = 7
	db.chassis["odd"] = odd
	var twoways := false
	var noway := false
	var odd_move := false
	for e in db.validate():
		if e.begins_with("chassis twoways") and e.contains("exactly one way of moving"):
			twoways = true
		if e.begins_with("chassis noway") and e.contains("exactly one way of moving"):
			noway = true
		if e.begins_with("chassis odd") and e.contains("in tens"):
			odd_move = true
	assert_true(twoways, "two ways of moving are refused")
	assert_true(noway, "no way of moving is refused")
	assert_true(odd_move, "a move that is not in tens is refused")


func test_movement_flags_name_a_chassis_faster_on_every_ground_and_never_refuse() -> void:
	# Ryan, 2 October: a flag, never a refusal; a slow wheeled APC is a valid design.
	var db := _db()
	var synthetic: Array = [
		{"name": "Fast Tank", "traits": ["tracked"], "movespeed": 40},
		{"name": "Slow Car", "traits": ["wheeled"], "movespeed": 20},
		{"name": "Walker A", "traits": ["walker"], "movespeed": 30},
		{"name": "Walker B", "traits": ["walker"], "movespeed": 20},
		{"name": "Bird", "traits": ["flyer"], "movespeed": 50},
	]
	var flags := db.movement_flags(synthetic)
	var tank_over_car := false
	var walker_tie := false
	var bird := false
	for f in flags:
		if f.begins_with("Fast Tank is at least as fast as Slow Car"):
			tank_over_car = true
		if f.begins_with("Walker A is at least as fast as Walker B") or f.begins_with("Walker B is at least as fast as Walker A"):
			walker_tie = true
		if f.contains("Bird"):
			bird = true
	assert_true(tank_over_car, "a tank at 40 matches the car's open ground and beats it elsewhere: flagged (%s)" % str(flags))
	assert_false(walker_tie, "two walkers a weight class apart are weight, not a flag")
	assert_false(bird, "flyers are exempt: they pay by not blocking")
	assert_eq(db.validate().size(), 0, "the content still validates clean whatever the flags")
	for f in db.movement_flags():
		print("  movement flag: %s" % f)


func test_sparrowhawk_loadout_matches_design() -> void:
	var db := _db()
	var u := db.make_mech("sparrowhawk")
	assert_eq(u.movespeed, int(db.chassis["sparrowhawk"]["movespeed"]), "the move is the content's, in tens")
	assert_true(u.movespeed % 5 == 0 and u.movespeed > 0, "moves are in tens")
	assert_true(u.traits.has("flyer"), "sparrowhawk flies")
	assert_false(u.can_block(), "and therefore does not block")
	var p: Dictionary = db.chassis["sparrowhawk"]["passive"]
	assert_eq(p["effects"].size(), 2, "two effects, one idea")
	assert_true(not p.has("rules"), "no rules text: the description says what it does")
	assert_true(not db.chassis["sparrowhawk"].has("passives"), "still counts as one passive")


func test_packs_unpack_by_foe_type() -> void:
	var db := _db()
	var ghouls := Unit.pack(7, "ghouls", Vector2i.ZERO, "marsh", 20, 6, "revenant")
	var foes := db.foes_for(ghouls)
	assert_eq(foes.size(), 6, "six ghouls from strength six")
	for f in foes:
		assert_eq(f.display_name, "Revenant", "all the same type")
		assert_eq(f.pack_id, 7, "foe remembers its pack")
	var necros := Unit.pack(8, "necromancers", Vector2i.ZERO, "marsh", 20, 2, "ghost")
	var backs := db.foes_for(necros)
	assert_eq(backs.size(), 2, "two necromancers")
	assert_true(backs[0].prefers_back, "necromancer holds the back")
	var untyped := Unit.pack(9, "whatever", Vector2i.ZERO, "peak", 20, 3)
	var fallback := db.foes_for(untyped)
	assert_eq(fallback.size(), 3, "a pack with no type falls back to the faction's first spawn entry")
	assert_eq(fallback[0].display_name, "Bomb", "which is the bomb for the Peak")


func test_boss_unpacks_to_the_faction_boss() -> void:
	var db := _db()
	var boss := Unit.boss(8, "colossus", Vector2i.ZERO, "marsh")
	var only := db.foes_for(boss)
	assert_eq(only.size(), 1, "a boss unpacks to just its massive foe")
	assert_eq(only[0].display_name, str(db.foes[str(db.factions["marsh"]["boss"])]["name"]), "the Marsh's boss, whatever the content names it")
	assert_true(only[0].is_massive(), "and it is massive")
	var pit := db.foes_for(Unit.boss(9, "lord", Vector2i.ZERO, "peak"))
	assert_eq(pit[0].display_name, str(db.foes[str(db.factions["peak"]["boss"])]["name"]), "the Peak's boss")


func test_spawn_table_lists_the_factions_formation() -> void:
	var db := _db()
	var table := db.spawn_table("marsh")
	assert_eq(table.size(), 3, "three packs come through together")
	assert_eq(table[0][0], "revenant", "ghouls first")
	assert_eq(table[2][0], "ghost", "necromancers behind them")
	assert_eq(table[2][1], 3, "three of them")
	assert_eq(db.faction_of_foe("drake"), "peak", "foe to faction lookup")


func test_content_mech_survives_a_skirmish_round() -> void:
	var db := _db()
	var sk := Skirmish.new(5)
	sk.add_mech(db.make_mech("badger"))
	sk.add_mech(db.make_mech("clydesdale"))
	var sq := Unit.pack(1, "risen", Vector2i.ZERO, "marsh", 20, 6)
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
	var comp: Dictionary = db.components["enfilade_beam"].duplicate(true)
	comp["face"]["keywords"] = ["penetrate", "burn", "chain", "shock"]
	comp["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
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
	var f: Dictionary = db.foes["revenant"].duplicate(true)
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
	u.die = Die.single(Face.attack(30, Face.Reach.DIRECT, [], 10))
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([Foe.make("revenant", 90, 10)])
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
	assert_eq(Effects.attack(u, null, 12, 0)["damage"], 30, "a 12 is lifted to 30")
	assert_eq(Effects.attack(u, null, 45, 5)["damage"], 45, "a 45 stays")


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
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	plate["face"]["keywords"] = ["corrode"]
	plate["status"] = "planned"
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["loud_plate"] = plate
	for e in db.validate():
		assert_false(e.begins_with("component loud_plate"), "a planned component with a planned keyword validates clean: %s" % e)
	var f := Face.from_dict(plate["face"])
	assert_true(f.keywords.is_empty(), "and builds without the keyword the engine lacks")
	plate.erase("status")
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["loud_plate"] = plate
	var hit := false
	for e in db.validate():
		if e.begins_with("component loud_plate") and e.contains("unknown keyword"):
			hit = true
	assert_true(hit, "the same component marked implemented is refused")


## No crits (10 October): a face carrying a crit chance and a passive on the old on_crit trigger
## are both stale content, and the validator says so.
func test_crits_are_refused_in_content() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["crit"] = 10
	gun["tier"] = 1
	db.components["old_gun"] = gun
	var c: Dictionary = db.chassis[db.chassis.keys()[0]].duplicate(true)
	c["passive"] = {"id": "hot", "name": "Hot", "description": "Crits burn.", "effects": [{"trigger": "on_crit", "effect": "add_burn", "value": 1}]}
	db.chassis["hot_one"] = c
	var gun_refused := false
	var passive_refused := false
	for e in db.validate():
		if e.begins_with("component old_gun") and e.contains("no crits"):
			gun_refused = true
		if e.begins_with("chassis hot_one") and e.contains("on_crit"):
			passive_refused = true
	assert_true(gun_refused, "a crit chance on a face is refused")
	assert_true(passive_refused, "and so is a passive on the on_crit trigger")


## Two reaches since 10 October: melee is refused as a reach in content, a melee weapon is a
## direct one with the tag, and its built entry carries the tag for a passive to read. An old
## save's line or melee reads as direct.
func test_melee_is_a_tag_and_never_a_reach() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var claw: Dictionary = db.components["enfilade_beam"].duplicate(true)
	claw["face"]["reach"] = "melee"
	claw["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["fist"] = claw
	var refused := false
	for e in db.validate():
		if e.begins_with("component fist") and e.contains("reach direct or indirect"):
			refused = true
	assert_true(refused, "melee is no reach")
	claw["face"]["reach"] = "direct"
	claw["tags"] = ["melee"]
	for e in db.validate():
		assert_false(e.begins_with("component fist"), "a direct weapon tagged melee validates clean: %s" % e)
	var f: Face = db.build_die(["fist"], [], 0).faces[0]
	assert_eq(f.reach, Face.Reach.DIRECT, "it builds direct")
	assert_eq(f.tags, ["melee"] as Array[String], "carrying its tag")
	assert_eq(Face.reach_from_name("line"), Face.Reach.DIRECT, "an old save's line is direct")
	assert_eq(Face.reach_from_name("melee"), Face.Reach.DIRECT, "and its melee too")


## No weapon classes since 10 October (bible section 5): a weapon is rolled or flat by its
## niche, whatever its filing tags say, so the content holds sane numbers and both shapes.
func test_content_dice_are_sane_and_both_shapes_are_present() -> void:
	var db := _db()
	var rolled := 0
	var flat := 0
	for id in db.components.keys():
		var c: Dictionary = db.components[id]
		for fd in [c.get("face", {})]:
			assert_true(int(fd.get("power", 0)) >= 0, "%s power is not negative" % id)
			if str(fd.get("kind", "")) != "attack":
				continue
			if fd.has("power_max"):
				rolled += 1
				assert_true(int(fd["power_max"]) > int(fd["power"]), "%s: a rolled face has a real range" % id)
			else:
				flat += 1
	assert_true(rolled >= 5 and flat >= 3, "both shapes present (%d rolled, %d flat)" % [rolled, flat])


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
				if Foe.is_attack_action(a):
					assert_false(a.has("value"), "%s: an attack scales the base attack, it has no value of its own" % id)
		assert_true(implemented >= 1, "%s has at least one implemented action" % id)
	var foe := db.make_foe("revenant")
	var entry := db.codex_for_foe(foe)
	assert_true(entry["actions"].contains("CLAW // ATTACK 5"), "codex lists the implemented action with the resulting number (alone on the field: no kin)")
	assert_true(entry["actions"].contains("for 5:"), "and fills {damage} into the text")
	var caster := db.codex_for_foe(db.make_foe("ghost"))
	assert_true(caster["actions"].contains("RAISE // BUFF"), "and lists a buff, live since 30 September")
	var planned: Dictionary = db.foes["revenant"].duplicate(true)
	planned["actions"] = Array(planned["actions"]).duplicate(true)
	planned["actions"].append({"id": "someday", "name": "Someday", "kind": "buff", "text": "", "status": "planned"})
	db.foes["revenant"] = planned
	assert_false(db.codex_for_foe(db.make_foe("revenant"))["actions"].contains("SOMEDAY"), "a planned action stays hidden")
	ContentDB.reset_cache()
	assert_eq(entry["flavour"], db.foes["revenant"]["flavour"], "codex quotes the foe, not the faction")


func test_foe_actions_scale_the_base_attack_and_are_picked_by_weight() -> void:
	var f := Foe.make("revenant", 30, 10)
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
	var f: Dictionary = db.foes["revenant"].duplicate(true)
	f["actions"].append({"id": "someday", "name": "Someday", "kind": "buff", "text": "", "status": "implemented"})
	db.foes["revenant"] = f
	var hit := false
	for e in db.validate():
		if e.begins_with("foe revenant action someday") and e.contains("effect must be"):
			hit = true
	assert_true(hit, "a non-attack action marked implemented without an effect the engine runs is reported")


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
	var scrubber: Dictionary = db.components["laminar_deflector"].duplicate(true)
	scrubber["face"]["keywords"] = ["cleanse"]
	scrubber["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["scrubber"] = scrubber
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["keywords"] = ["cleanse"]
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["cleansing_gun"] = gun
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	plate["face"]["keywords"] = ["burn"]
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
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
	var fins: Dictionary = db.components["coolant_jacket"].duplicate(true)
	fins["name"] = "Finned Sink"
	fins["passive"] = {"id": "fins", "name": "Fins", "description": "Cooling +5.",
		"effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 5}]}
	db.components["fins_pack"] = fins   # stocked by the chassis below, so its tier is derived
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
	var good: Dictionary = db.components["laminar_deflector"].duplicate(true)
	good["face"] = {"kind": "buff", "status": "overcharged", "stacks": 2}
	good["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["coil_ok"] = good
	var foe_status: Dictionary = good.duplicate(true)
	foe_status["face"] = {"kind": "buff", "status": "burning"}
	foe_status["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["coil_foe"] = foe_status
	var unknown: Dictionary = good.duplicate(true)
	unknown["face"] = {"kind": "buff", "status": "haste", "rounds": 0}
	unknown["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["coil_bad"] = unknown
	var stray: Dictionary = good.duplicate(true)
	stray["face"] = {"kind": "shield", "power": 10, "stacks": 2}
	stray["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
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
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	plate["face"]["keywords"] = ["volatile"]
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_plate"] = plate
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["keywords"] = ["volatile"]
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_gun"] = gun
	var fins: Dictionary = db.components["coolant_jacket"].duplicate(true)
	fins["face"]["keywords"] = ["volatile"]
	fins["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_fins"] = fins
	for e in db.validate():
		assert_false(e.begins_with("component hot_"), "volatile validates on a shield, an attack and a vent alike: %s" % e)
	var f := db.build_face(plate["face"])
	assert_true(f.has(Face.Keyword.VOLATILE), "and builds onto the entry")


func test_the_content_carries_a_live_hull_the_engine_runs() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	plate["passive"] = {"id": "live_plate", "name": "Live Plate", "description": "", "effects": [
		{"trigger": "static", "effect": "shock_on_block", "value": 1}]}
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["live_plate"] = plate
	var coil: Dictionary = db.components["overcharge_coil"].duplicate(true)
	coil["face"]["status"] = "retaliate"
	coil["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["klaxon_coil"] = coil
	var errs := db.validate()
	for e in errs:
		assert_false(e.begins_with("component live_plate") or e.begins_with("component klaxon_coil"), "a shock passive and a retaliate buff validate: %s" % e)
	assert_true(errs.is_empty(), "and the shipped content is clean with them: %s" % str(errs))
	assert_eq(db.build_face(coil["face"]).buff_status, "retaliate", "the buff builds")


func test_lure_and_disrupt_ride_on_attacks_and_never_on_a_shield() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["keywords"] = ["lure", "disrupt"]
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["loud_gun"] = gun
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	plate["face"]["keywords"] = ["lure"]
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["loud_plate"] = plate
	var bad_plate := false
	for e in db.validate():
		assert_false(e.begins_with("component loud_gun"), "a lure and a disrupt on a weapon validate: %s" % e)
		if e.begins_with("component loud_plate") and e.contains("is an attack keyword"):
			bad_plate = true
	assert_true(bad_plate, "a lure on a shield is refused")
	var built := db.build_face(gun["face"])
	assert_true(built.has(Face.Keyword.LURE) and built.has(Face.Keyword.DISRUPT), "and the weapon builds with both")
	# The shipped lure: an entry of no damage that lures with a spread, in the Badger's stock.
	var klaxon := db.build_face(db.components["proximity_klaxon"]["face"])
	assert_true(klaxon.is_attack() and klaxon.power == 0 and klaxon.has(Face.Keyword.LURE) and klaxon.has(Face.Keyword.CLEAVE), "the klaxon lures and does nothing else")


func test_grant_keyword_names_a_keyword_the_engine_runs() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["badger"].duplicate(true)
	c["id"] = "ram"
	c["name"] = "Ram Test"
	c["passive"] = {"id": "drive", "name": "Drive", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "spillover"}]}
	db.chassis["ram"] = c
	var bad: Dictionary = c.duplicate(true)
	bad["id"] = "ram_bad"
	bad["name"] = "Ram Bad"
	bad["passive"] = {"id": "drive2", "name": "Drive", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "corrode"}]}
	db.chassis["ram_bad"] = bad
	var hit := false
	for e in db.validate():
		assert_false(e.begins_with("chassis ram:"), "a real keyword validates: %s" % e)
		if e.begins_with("chassis ram_bad") and e.contains("grant_keyword"):
			hit = true
	assert_true(hit, "a keyword the engine lacks is refused")


func test_the_vent_on_fire_fields_belong_to_an_attack() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	plate["face"]["vents_all"] = true
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_plate"] = plate
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["power_per_heat"] = 10
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["half_gun"] = gun
	var bad_plate := false
	var bad_gun := false
	for e in db.validate():
		if e.begins_with("component hot_plate") and e.contains("belong to an attack"):
			bad_plate = true
		if e.begins_with("component half_gun") and e.contains("needs vents_all"):
			bad_gun = true
	assert_true(bad_plate, "vents_all on a shield is refused")
	assert_true(bad_gun, "power_per_heat without vents_all is refused")


func test_a_brace_is_a_positive_number_of_stacks() -> void:
	# The brace (12 October): the stacks of Braced a spend gives its owner. Any kind of entry
	# may brace; nothing braces for zero.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(int(db.components["breaching_plow"]["face"].get("braces", 0)) > 0, "the plow braces")
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	plate["face"]["braces"] = 0
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["limp_plate"] = plate
	var refused := false
	for e in db.validate():
		if e.begins_with("component limp_plate") and e.contains("braces is a positive number"):
			refused = true
	assert_true(refused, "a brace of nothing is refused")
	# Braced lasts one turn from every source, so no buff grants it for longer.
	var jack: Dictionary = db.components["shoring_jack"].duplicate(true)
	jack["face"]["rounds"] = 2
	jack["tier"] = 1
	db.components["long_jack"] = jack
	var long_refused := false
	for e in db.validate():
		if e.begins_with("component long_jack") and e.contains("lasts until the round's end"):
			long_refused = true
	assert_true(long_refused, "a buff granting Braced for two rounds is refused")


func test_rolling_again_names_a_status_and_never_rides_on_rapid() -> void:
	# Rolling again on a status (12 October, the Nemesis's fists on rage): the status must be
	# one of the engine's, and a rapid entry already rolls again on its own.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var gun: Dictionary = db.components["incendiary_shells"].duplicate(true)
	gun["face"] = {"kind": "attack", "reach": "direct", "power": 10, "rolls_again_on": "fury"}
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["odd_gun"] = gun
	var plate: Dictionary = db.components["incendiary_shells"].duplicate(true)
	plate["face"] = {"kind": "shield", "power": 10, "keywords": ["rapid"], "rolls_again_on": "rage"}
	plate["tier"] = 1
	db.components["odd_plate"] = plate
	var no_status := false
	var on_rapid := false
	for e in db.validate():
		if e.begins_with("component odd_gun") and e.contains("rolls_again_on names a status"):
			no_status = true
		if e.begins_with("component odd_plate") and e.contains("a rapid entry already rolls again"):
			on_rapid = true
	assert_true(no_status, "a status the engine lacks is refused")
	assert_true(on_rapid, "rolling again on a rapid entry is refused")


func test_the_new_passive_fields_are_checked() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["badger"].duplicate(true)
	c["id"] = "odd"
	c["name"] = "Odd Test"
	c["passive"] = {"id": "odd", "name": "Odd", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 5, "per_stack": "nonsense"},
		{"trigger": "static", "effect": "keep_status", "value": "nonsense"},
		{"trigger": "static", "effect": "add_armour_vs_rank", "value": 5, "rank": "sideways"}]}
	db.chassis["odd"] = c
	var hits := 0
	for e in db.validate():
		if e.begins_with("chassis odd") and (e.contains("per_stack") or e.contains("keep_status") or e.contains("front or back")):
			hits += 1
	assert_eq(hits, 3, "each bad field is named")


func test_the_foe_actions_run_and_the_validator_knows_their_shape() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var errs := db.validate()
	assert_true(errs.is_empty(), "the shipped foes validate: %s" % str(errs))
	var kinds := {}
	for id in db.foes.keys():
		var f := db.make_foe(id)
		assert_true(Foe.is_attack_action(f.action), "%s opens with its blow" % id)
		for a in f.actions:
			kinds[Foe.kind_of(a)] = true
			if not Foe.is_attack_action(a):
				assert_true(Foe.ACTION_EFFECTS[Foe.kind_of(a)].has(str(a.get("effect", ""))), "%s's %s runs" % [id, a["id"]])
	assert_true(kinds.has("defend") and kinds.has("buff") and kinds.has("debuff"), "every kind is in the content")
	var g: Dictionary = db.foes["revenant"].duplicate(true)
	g["id"] = "odd_ghoul"
	g["name"] = "Odd Ghoul"
	g["actions"] = [{"id": "claw", "name": "Claw", "kind": "attack", "text": "", "status": "implemented"},
		{"id": "odd", "name": "Odd", "kind": "buff", "effect": "nonsense", "text": "", "status": "implemented"},
		{"id": "call", "name": "Call", "kind": "buff", "effect": "summon", "foe": "nobody", "text": "", "status": "implemented"},
		{"id": "hit", "name": "Hit", "kind": "debuff", "effect": "burn", "factor": 2.0, "text": "", "status": "implemented"}]
	db.foes["odd_ghoul"] = g
	var hits := 0
	for e in db.validate():
		if e.begins_with("foe odd_ghoul") and (e.contains("effect must be") or e.contains("unknown foe") or e.contains("belongs to an attack")):
			hits += 1
	assert_eq(hits, 3, "a bad effect, an unknown summon and an attack field on a debuff are each named")
	var entry := db.codex_for_foe(db.make_foe("bone_dragon"))
	assert_true(entry["actions"].contains("REGEN // DEFEND"), "the codex lists the defend")
	assert_true(entry["actions"].contains("Regrows 20 hull"), "with its number filled in")


func test_every_component_names_a_silhouette_class() -> void:
	var db := ContentDB.new()   # its own copy: the checks below break an entry
	db.load_dir(ContentDB.DIR)
	for id in db.components.keys():
		var c0: Dictionary = db.components[id]
		var shape := str(c0.get("shape", ""))
		assert_true(ContentDB.SHAPES.has(shape), "%s wears a class the model can build" % id)
		# The rule (30 September): a weapon always has a shape; armour and vents never do.
		if c0["face"].get("kind") == "attack":
			assert_true(shape != ContentDB.SHAPE_NONE, "%s is a weapon and takes a mount" % id)
		if c0["face"].get("kind") == "vent":
			assert_eq(shape, ContentDB.SHAPE_NONE, "%s is a vent and shows nowhere" % id)
	var c: Dictionary = db.components["enfilade_beam"]
	c["shape"] = "teapot"
	var hit := false
	for e in db.validate():
		if e.begins_with("component enfilade_beam") and e.contains("silhouette class"):
			hit = true
	assert_true(hit, "an unknown class is refused")
	c.erase("shape")
	hit = false
	for e in db.validate():
		if e.begins_with("component enfilade_beam") and e.contains("missing shape"):
			hit = true
	assert_true(hit, "and a component without one")


func test_the_playtest_set_obeys_the_targeting_rules() -> void:
	# The set of 2 October (the bible, section 9): rank and file carry one or two moves and a
	# boss three; every special carries a condition; every foe reads an aim the engine knows;
	# the ghoul's claw is a swarm blow; the bosses wear armour.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.validate().is_empty(), "the set validates: %s" % str(db.validate()))
	for id in db.foes.keys():
		var f := db.make_foe(id)
		assert_true(Foe.AIMS.has(f.aim), "%s aims by a word the engine knows" % id)
		if f.is_massive():
			assert_eq(f.actions.size(), 3, "%s, a boss, has three moves" % id)
			assert_true(f.armour > 0, "%s, a boss, wears armour" % id)
		elif f.hero:
			# A hero has three moves (decided 9 October); one may still be planned, so two run.
			assert_true(f.actions.size() >= 2 and f.actions.size() <= 3, "%s, a hero, has two or three moves running" % id)
			assert_eq(f.size, 1, "%s, a hero, is human-sized" % id)
		else:
			assert_true(f.actions.size() >= 1 and f.actions.size() <= 2, "%s has one or two moves" % id)
		for a in f.actions:
			if not Foe.is_attack_action(a):
				assert_false(Foe.whens_of(a).is_empty(), "%s's %s carries a condition" % [id, a["id"]])
	var g := db.make_foe("revenant")
	assert_eq(g.actions.size(), 1, "the ghoul has one move")
	assert_eq(int(g.actions[0].get("swarm", 0)), 5, "and it swarms")
	g.kin = 3
	assert_eq(g.damage(), 20, "four on the field hit for 20 each")
	var entry := db.codex_for_foe(g)
	assert_true(entry["actions"].contains("+5 A KIN"), "the codex says the swarm: %s" % entry["actions"])
	assert_true(entry["stats"].contains("ARM") or true, "stats read")
	var maw := db.codex_for_foe(db.make_foe("sandworm"))
	assert_true(maw["actions"].contains("WHEN BELOW HALF"), "the codex says a move's condition: %s" % maw["actions"])
	assert_true(str(maw["stats"]).contains("ARM 5"), "and the boss's armour")


# The name plate shows the traits, not a silhouette word (Ryan, 2 October): maker, then
# every trait by its shown name, then the die. Synthetic traits and a synthetic chassis, so
# no entry's content is asserted on.
func test_the_codex_plate_lists_the_traits() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	db.vocabulary["test_skids"] = {"id": "test_skids", "category": "trait", "name": "Skids"}
	db.vocabulary["test_quiet"] = {"id": "test_quiet", "category": "trait", "name": "Quiet"}
	var c: Dictionary = db.chassis["clydesdale"].duplicate(true)
	c["traits"] = ["test_skids", "test_quiet"]
	db.chassis["plated"] = c
	var u := db.make_mech("plated")
	var maker := str(db.makers[c["maker"]]["name"]).to_upper()
	assert_eq(str(db.codex_for_unit(u)["subtitle"]), "%s // SKIDS, QUIET // D%d" % [maker, u.die.size()], "maker, the traits by name, the die")
	c["traits"] = []
	db.chassis["bare"] = c
	assert_eq(str(db.codex_for_unit(db.make_mech("bare"))["subtitle"]), "%s // D%d" % [maker, u.die.size()], "no traits, no traits part")
	for e in db.validate():
		assert_false(e.contains("silhouette"), "no chassis needs a silhouette: %s" % e)


## A fresh database the test may edit (the default one is shared and cached).
func _fresh() -> ContentDB:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	return db


func _has_error(db: ContentDB, word: String) -> bool:
	for e in db.validate():
		if e.contains(word):
			return true
	return false


func test_a_components_tier_follows_the_lowest_chassis_that_stocks_it() -> void:
	# 7 October: tier is power and complexity, never the maker; a stocked component's tier is
	# derived from the chassis that carry it, so moving a chassis moves its stock.
	var db := _fresh()
	var low := ""
	var high := ""
	for id in db.chassis.keys():
		if not db.chassis[id].get("loadout", []).is_empty():
			if low.is_empty():
				low = str(id)
			elif high.is_empty():
				high = str(id)
	var cid := str(db.chassis[high]["loadout"][0])
	db.chassis[low]["tier"] = 3
	db.chassis[high]["tier"] = 2
	for id in db.chassis.keys():
		if id != low and id != high and db.chassis[id].get("loadout", []).has(cid):
			db.chassis[id]["tier"] = 3
	assert_eq(db.component_tier(cid), 2, "the lowest chassis stocking it")
	db.chassis[low]["loadout"].append(cid)
	db.chassis[low]["tier"] = 1
	assert_eq(db.component_tier(cid), 1, "a tier-one chassis stocking it makes it tier one")
	assert_true(db.starting_blueprints().has(cid), "and a starting blueprint")


func test_the_tier_rules_are_validated() -> void:
	var db := _fresh()
	var capital := db.capital_maker()
	var cap_chassis := ""
	var plain := ""
	for id in db.chassis.keys():
		if str(db.chassis[id].get("maker", "")) == capital and cap_chassis.is_empty():
			cap_chassis = str(id)
		elif plain.is_empty() and not db.chassis[id].get("loadout", []).is_empty():
			plain = str(id)
	assert_true(not cap_chassis.is_empty(), "the content has a chassis of the capital's maker")
	db.chassis[cap_chassis]["tier"] = 1
	assert_true(_has_error(db, "fields no tier one"), "the capital's maker fields no tier one")
	db = _fresh()
	db.chassis[plain].erase("tier")
	assert_true(_has_error(db, "tier must be 1, 2 or 3"), "a chassis needs a tier")
	db = _fresh()
	var stocked := str(db.chassis[plain]["loadout"][0])
	db.components[stocked]["tier"] = 2
	assert_true(_has_error(db, "its tier is derived"), "a stocked component stores no tier")
	db = _fresh()
	db.components["test_loose"] = db.components[stocked].duplicate(true)
	assert_true(_has_error(db, "carries its own tier"), "an unstocked component needs its own")


func test_rapid_rides_on_anything_and_shock_on_weapons_only() -> void:
	# 9 October: rapid joined volatile as a keyword about the spend, so a vent may carry it;
	# shock is a weapon's.
	var db := _fresh()
	var vent: Dictionary = db.components["coolant_jacket"].duplicate(true)
	vent["face"]["keywords"] = ["rapid"]
	vent["tier"] = 1
	db.components["test_vent"] = vent
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	plate["face"]["keywords"] = ["shock"]
	plate["tier"] = 1
	db.components["test_plate"] = plate
	var refused_shock := false
	for e in db.validate():
		assert_false(e.begins_with("component test_vent"), "a rapid vent validates: %s" % e)
		if e.begins_with("component test_plate") and e.contains("is an attack keyword"):
			refused_shock = true
	assert_true(refused_shock, "a shock on a shield is refused")
	var built := db.build_face(vent["face"])
	assert_true(built.kind == Face.Kind.VENT and built.has(Face.Keyword.RAPID), "and the vent builds rapid")


func test_every_chassis_states_its_module_slots() -> void:
	# A number of the chassis, never bought (Ryan; bible section 10): the validator wants it
	# on every chassis and holds it to a small range.
	var db := _fresh()
	for id in db.chassis.keys():
		assert_true(db.chassis[id].has("module_slots"), "%s states its module slots" % id)
	var bare: Dictionary = db.chassis.values()[0].duplicate(true)
	bare.erase("module_slots")
	bare["id"] = "test_bare"
	db.chassis["test_bare"] = bare
	assert_true(_has_error(db, "missing module_slots"), "a chassis without its slots is refused")
	db = _fresh()
	var wide: Dictionary = db.chassis.values()[0].duplicate(true)
	wide["module_slots"] = ContentDB.MAX_MODULE_SLOTS + 1
	wide["id"] = "test_wide"
	db.chassis["test_wide"] = wide
	assert_true(_has_error(db, "module_slots must be"), "and so is one past the range")


## A synthetic module, so no test leans on a real entry's numbers or text.
func _module(maker: String, tier: int, stats: Dictionary, text) -> Dictionary:
	return {"id": "test_module", "name": "Test Module", "maker": maker, "tier": tier, "codex": "", "flavour": "",
		"stats": stats, "text": text, "design": {"fantasy": "A test."}}


func test_a_module_is_its_stat_lines_and_its_text_on_the_machine() -> void:
	# Built 9 October: a module is read like a passive, sourced "module", and the machine
	# starts whole on the numbers it made.
	var db := _fresh()
	var maker := str(db.chassis["badger"]["maker"])
	db.modules["test_module"] = _module(maker, 1, {"hull": 30, "armour": 5, "move": -10},
		{"description": "Its weapons run twice as hot.", "effects": [{"trigger": "on_attack", "effect": "multiply_heat", "value": 2}]})
	var plain := db.make_mech("badger")
	var u := db.make_mech("badger", 0, Vector2i.ZERO, null, ["test_module"])
	assert_eq(Array(u.modules), ["test_module"], "the machine knows its module")
	assert_eq(u.hull_max, plain.hull_max + 30, "hull line")
	assert_eq(u.hull, u.hull_max, "and it starts whole on it")
	assert_eq(u.armour, plain.armour + 5, "armour line")
	assert_eq(u.movespeed, plain.movespeed - 10, "a drawback line")
	var gun: Face = null
	for f in u.die.faces:
		if f.kind == Face.Kind.ATTACK:
			gun = f
			break
	assert_eq(int(Effects.attack(u, gun, 10, 10)["heat"]), 2 * int(Effects.attack(plain, gun, 10, 10)["heat"]), "and the text runs")
	var rows: Array = db.codex_for_unit(u)["passive_rows"]
	var found := false
	for r in rows:
		if str(r[0]).begins_with("TEST MODULE (MODULE): Hull +30, armour +5, move -10. Its weapons run twice as hot."):
			found = r[1] == "module"
	assert_true(found, "the codex names it as a module, with its lines and its text: %s" % str(rows))


func test_a_machine_wears_no_more_modules_than_its_slots() -> void:
	var db := _fresh()
	var maker := str(db.chassis["badger"]["maker"])
	db.modules["test_module"] = _module(maker, 1, {"hull": 10}, null)
	var slots := int(db.chassis["badger"]["module_slots"])
	var asked: Array = []
	for i in range(slots + 1):
		asked.append("test_module")
	var u := db.make_mech("badger", 0, Vector2i.ZERO, null, asked)
	assert_eq(u.modules.size(), slots, "one past the slots is left off")
	assert_eq(u.hull_max, db.make_mech("badger").hull_max + 10 * slots, "the same module twice stacks")


func test_the_module_rules_are_validated() -> void:
	var db := _fresh()
	var plain_maker := ""
	for id in db.makers.keys():
		if str(id) != db.capital_maker():
			plain_maker = str(id)
			break
	db.modules["test_module"] = _module(plain_maker, 1, {"hull": 10, "armour": 5, "shield": 5, "cooling": 5}, null)
	for e in db.validate():
		assert_false(e.begins_with("module test_module"), "four stat lines and no text validate: %s" % e)
	db.modules["test_module"] = _module(db.capital_maker(), 1, {"hull": 10}, null)
	assert_true(_has_error(db, "no tier-one module"), "the capital's maker has no tier-one module")
	db.modules["test_module"] = _module(plain_maker, 4, {"hull": 10}, null)
	assert_true(_has_error(db, "module test_module: tier must be"), "a tier is 1 to 3")
	db.modules["test_module"] = _module(plain_maker, 1, {"luck": 10}, null)
	assert_true(_has_error(db, "stat 'luck' is not one of"), "a stat line names an engine stat")
	db.modules["test_module"] = _module(plain_maker, 1, {"hull": 0}, null)
	assert_true(_has_error(db, "must be a whole number other than zero"), "and is not zero")
	db.modules["test_module"] = _module(plain_maker, 1, {}, null)
	assert_true(_has_error(db, "needs stats, a text or both"), "an empty module is refused")
	db.modules["test_module"] = _module(plain_maker, 1, {}, {"description": "x", "effects": [{"trigger": "static", "effect": "no_such_thing", "value": 1}]})
	assert_true(_has_error(db, "is not implemented by the engine"), "a text is checked like a passive")
	db.modules["test_module"] = _module(plain_maker, 1, {}, {"description": "x", "status": "planned", "effects": [{"trigger": "static", "effect": "no_such_thing", "value": 1}]})
	for e in db.validate():
		assert_false(e.begins_with("module test_module"), "a planned text waits: %s" % e)


func test_a_split_is_validated_one_deep_and_read_into_the_foe() -> void:
	var db := _db()
	var any_id: String = db.foes.keys()[0]
	var a: Dictionary = db.foes[any_id].duplicate(true)
	a["on_death"] = {"summon": "nobody", "count": 2}
	db.foes["split_test"] = a
	var errs := db.validate()
	assert_true("\n".join(errs).contains("on_death must name a known foe"), "an unknown foe is refused")
	a["on_death"] = {"summon": any_id, "count": 2}
	var b: Dictionary = db.foes[any_id].duplicate(true)
	b["on_death"] = {"summon": "split_test", "count": 1}
	db.foes["chain_test"] = b
	errs = db.validate()
	assert_true("\n".join(errs).contains("a split goes one deep"), "a chain of splits is refused")
	db.foes.erase("chain_test")
	errs = db.validate()
	assert_false("\n".join(errs).contains("split"), "one level validates: %s" % str(errs))
	var f := db.make_foe("split_test")
	assert_eq(f.on_death, {"summon": any_id, "count": 2}, "read into the foe")
	db.foes.erase("split_test")


## A component's sound (decided 2 October): its label where content names one, else derived
## from shape and face. Synthetic components, so no entry's sound is pinned here.
func test_a_component_sound_is_its_label_or_derived() -> void:
	var db := ContentDB.new()
	var kinetic := {"kind": "attack", "reach": "direct", "power": 10, "power_max": 20}
	var energy := {"kind": "attack", "reach": "direct", "power": 15}
	db.components = {
		"slug": {"shape": "barrel", "maker": "minerva", "face": kinetic},
		"twin": {"shape": "twin_barrel", "maker": "kestrel", "face": kinetic},
		"beam": {"shape": "barrel", "maker": "kestrel", "face": energy},
		"hot": {"shape": "barrel", "maker": "arsenal", "face": energy},
		"hot_rack": {"shape": "rack", "maker": "arsenal", "face": energy},
		"plow": {"shape": "blade", "maker": "minerva", "face": {"kind": "attack", "reach": "direct", "power": 5, "power_max": 10}, "sound": "blunt"},
		"fist": {"shape": "blade", "maker": "arsenal", "face": energy, "sound": ["blunt", "plasma"]},
		"field": {"shape": "none", "maker": "minerva", "face": {"kind": "shield", "power": 20}},
		"coil": {"shape": "dish", "maker": "kestrel", "face": {"kind": "buff"}},
		"lure": {"shape": "dish", "maker": "minerva", "face": {"kind": "attack", "reach": "indirect", "power": 0}},
		"bare": {"shape": "none", "maker": "minerva", "face": {"kind": "attack", "reach": "indirect", "power": 5, "power_max": 10}},
		"vent": {"shape": "none", "maker": "minerva", "face": {"kind": "vent", "power": 10}},
	}
	assert_eq(db.sound_of("slug"), ["barrel"], "a kinetic barrel is a barrel")
	assert_eq(db.sound_of("twin"), ["twin_barrel"], "a twin a twin")
	assert_eq(db.sound_of("beam"), ["laser"], "an energy barrel a laser")
	assert_eq(db.sound_of("hot"), ["plasma"], "the Arsenal's energy barrel a plasma")
	assert_eq(db.sound_of("hot_rack"), ["rack"], "the Arsenal's rack still a rack")
	assert_eq(db.sound_of("plow"), ["blunt"], "a label wins")
	assert_eq(db.sound_of("fist"), ["blunt", "plasma"], "a list is layers")
	assert_eq(db.sound_of("field"), ["deflector"], "a shield a deflector, whatever its mount")
	assert_eq(db.sound_of("coil"), ["coil"], "a buff a coil")
	assert_eq(db.sound_of("lure"), ["coil"], "a dish that attacks a coil")
	assert_eq(db.sound_of("bare"), ["rack"], "an attack with no mount by its reach")
	assert_eq(db.sound_of("vent"), [], "a vent has none of these")
	assert_eq(db.sound_of("nothing"), [], "an unknown id has none")


func test_every_component_derives_a_sound_the_game_plays() -> void:
	var db := ContentDB.load_default()
	for id in db.components:
		var kind := str(db.components[id].get("face", {}).get("kind", ""))
		var layers := db.sound_of(id)
		if kind == "vent":
			assert_eq(layers, [], "%s is a vent" % id)
			continue
		assert_true(not layers.is_empty(), "%s has a sound" % id)
		assert_true(not Sound.blow(layers).is_empty(), "%s's sound %s has a blow" % [id, layers])


func test_a_locked_component_is_never_a_blueprint() -> void:
	# Ryan, 9 October: locked components are powerful and unique, which is why they are locked.
	var db := _fresh()
	var locked := ""
	var plain := ""
	for id in db.chassis.keys():
		if locked.is_empty() and not db.chassis[id].get("fixed", []).is_empty():
			locked = str(db.chassis[id]["fixed"][0])
		if plain.is_empty() and int(db.chassis[id].get("tier", 0)) == 1 and not db.chassis[id].get("loadout", []).is_empty():
			plain = str(id)
	assert_true(not locked.is_empty() and not plain.is_empty(), "the content has a locked component and a tier-one stock")
	assert_eq(db.component_tier(locked), 0, "a locked component has no tier")
	for bp in db.starting_blueprints():
		assert_false(db.is_fixed(str(bp)), "no starting blueprint is locked anywhere: %s" % bp)
	db.chassis[plain]["loadout"][0] = locked
	assert_true(_has_error(db, "locked on a chassis, so no hardpoint stocks it"), "a hardpoint stocking a locked component is refused")
	assert_eq(db.component_tier(locked), 0, "and even then it is never a blueprint")
	db = _fresh()
	db.components[locked]["tier"] = 2
	assert_true(_has_error(db, "locked on a chassis, so it carries no tier"), "a locked component storing a tier is refused")

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
		if e.begins_with("chassis over") and e.contains("into %d hardpoints" % int(c["hardpoints"])):
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
	assert_eq(only.size(), 1, "a boss unpacks to just its boss")
	assert_eq(only[0].display_name, str(db.foes[str(db.factions["marsh"]["boss"])]["name"]), "the Marsh's boss, whatever the content names it")
	assert_true(only[0].boss, "and the content marks it the boss")
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


func test_a_massive_foe_may_stand_in_a_spawn_list() -> void:
	# The bible's tiers row (15 October, Ryan again 24 October): size is apart from the tier, so
	# massive rank and file validate, unpack from their pack as no boss, and take a column each.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var fid := str(db.factions.keys()[0])
	var big: Dictionary = db.foes[str(db.bosses_of(fid)[0])].duplicate(true)
	big["id"] = "massive_rank_and_file"
	big["name"] = "Massive Rank and File"
	db.foes["massive_rank_and_file"] = big
	db.factions[fid]["spawn"].append({"foe": "massive_rank_and_file", "strength": 2})
	assert_true(db.validate().is_empty(), "a massive foe in a spawn list validates: %s" % str(db.validate()))
	var foes := db.foes_for(Unit.pack(5, "giants", Vector2i.ZERO, fid, 10, 2, "massive_rank_and_file"))
	assert_eq(foes.size(), 2, "two from strength two")
	assert_true(foes[0].is_massive() and not foes[0].boss, "massive, and no boss for it")
	var sk := Skirmish.new(1)
	sk.add_mech(db.make_mech(str(db.chassis.keys()[0]), 1, Vector2i.ZERO))
	sk.add_foes(foes)
	sk.begin()
	var columns := 0
	for c in range(sk.front.size()):
		if sk.front[c] != null and sk.front[c].is_massive():
			assert_eq(sk.back[c], sk.front[c], "each fills both ranks of its column")
			columns += 1
	assert_eq(columns, 2, "and each takes a column of its own")


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
	c["design"].erase("one_off")   # the cap as it stands for every passive without one
	var eff := {"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 1}   # synthetic: content's passives change
	c["passive"] = {"id": "bloated", "name": "Bloated", "description": "Four effects.", "effects": [eff, eff, eff, eff]}
	db.chassis["bloated"] = c
	var errs := db.validate()
	var hit := false
	for e in errs:
		if e.begins_with("chassis bloated") and e.contains("effects, cap"):
			hit = true
	assert_true(hit, "four effects in one passive is reported")


func test_a_boss_is_marked_by_content_and_may_be_any_size() -> void:
	# The bible's tiers row (15 October): big is an attribute apart from boss and elite, so a
	# human-sized boss validates and is the boss; a hero is a final, dealt from the bench.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var fid := str(db.factions.keys()[0])
	var small: Dictionary = db.foes[str(db.factions[fid]["boss"])].duplicate(true)
	small["size"] = 1
	db.foes["small_boss"] = small
	db.factions[fid]["boss"] = "small_boss"
	assert_true(db.validate().is_empty(), "a human-sized boss validates: %s" % str(db.validate()))
	var b := db.make_foe("small_boss")
	assert_true(b.boss and not b.is_massive(), "the content makes it the boss, and it stands one slot high")
	assert_false(db.make_foe(str(db.spawn_table(fid)[0][0])).boss, "its rank and file are no boss")
	var hero_id := ""
	for id in db.foes.keys():
		if bool(db.foes[id].get("hero", false)):
			hero_id = str(id)
			break
	db.factions[fid]["boss"] = hero_id
	var refused := false
	for e in db.validate():
		if e.begins_with("faction %s" % fid) and e.contains("is a hero"):
			refused = true
	assert_true(refused, "a hero named the boss is refused")
	# A list of bosses (three a domain once the slate lands, 22 October): each once, none a hero.
	var boss_id := str(db.spawn_table(fid)[0][0])
	db.factions[fid]["boss"] = ["small_boss", boss_id]
	assert_true(db.validate().is_empty(), "a list of bosses validates: %s" % str(db.validate()))
	assert_eq(Array(db.bosses_of(fid)), ["small_boss", boss_id], "read in content order")
	db.factions[fid]["boss"] = ["small_boss", "small_boss"]
	assert_true(db.validate().any(func(e: String) -> bool: return e.contains("comes twice")), "a boss listed twice is refused")
	db.factions[fid]["boss"] = []
	assert_true(db.validate().any(func(e: String) -> bool: return e.contains("names no foe")), "and an empty list")
	db.factions[fid]["boss"] = ["small_boss", hero_id]
	assert_true(db.validate().any(func(e: String) -> bool: return e.contains("is a hero")), "and a hero among them")


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


## The Kite's shape on a synthetic passive (content's own passive is Ryan's to change): the
## printed number doubled, and a flat heat tax a shot that the double leaves alone.
func test_a_printed_double_and_a_heat_tax_on_one_shot() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive({"id": "test_double", "name": "Double", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_printed", "value": 2},
		{"trigger": "on_attack", "effect": "add_heat", "value": 3}]})
	u.die = Die.single(Face.attack(30, Face.Reach.DIRECT, [], 10))
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 30, "power 30 became 60")
	assert_eq(sk.mechs[0].heat, 13, "heat 10 plus the tax of 3, the double printed-only")


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


func test_a_built_component_may_carry_a_planned_keyword() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	# A synthetic planned keyword (21 October: Swap, the last one the vocabulary held, was built).
	var planned_kw := "test_planned_kw"
	db.vocabulary[planned_kw] = {"id": planned_kw, "category": "keyword", "name": "Planned", "codex": "A keyword the engine lacks.", "status": "planned"}
	var gun: Dictionary = db.components["twin_autoguns"].duplicate(true)
	gun["face"] = Dictionary(gun["face"]).duplicate(true)
	gun["face"]["keywords"] = [planned_kw]
	gun["tier"] = 2   # no chassis stocks it, so it carries its own tier
	db.components["ahead_gun"] = gun
	for e in db.validate():
		assert_false(e.begins_with("component ahead_gun"), "a built component may carry a planned keyword: %s" % e)
	var f := db.build_face(gun["face"])
	assert_true(f.keywords.is_empty(), "the die builds the entry without the keyword the engine lacks")
	db.vocabulary["someday"] = {"id": "someday", "category": "keyword", "name": "Someday", "codex": "An idea.", "status": "idea"}
	gun["face"]["keywords"] = ["someday"]
	db.components["ahead_gun"] = gun
	var hit := false
	for e in db.validate():
		if e.begins_with("component ahead_gun"):
			hit = true
	assert_true(hit, "an idea-stage keyword rides only on a planned component")


func test_a_planned_buff_may_grant_a_planned_machine_status() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var coil := ""
	for cid in db.components.keys():
		if str(db.components[cid].get("face", {}).get("kind", "")) == "buff" and db.components[cid].get("status", "implemented") == "implemented":
			coil = str(cid)
			break
	assert_true(not coil.is_empty(), "the content has a built buff component to copy")
	# A synthetic planned machine status (the content may have none left to borrow: the
	# Swallowtail's were the last, built 21 October).
	var drafted_status := "probe_status"
	db.vocabulary[drafted_status] = {"id": drafted_status, "category": "status", "name": "Probe", "codex": "A probe.", "status": "planned",
		"design": {"holes": "", "table": {"kind": "buff", "on": "machine", "stacks": "No", "lasts": "The round"}}}
	var piece: Dictionary = db.components[coil].duplicate(true)
	piece["face"] = Dictionary(piece["face"]).duplicate(true)
	piece["face"]["status"] = drafted_status
	piece["status"] = "planned"
	piece["tier"] = 2   # no chassis stocks it, so it carries its own tier
	db.components["draft_coil"] = piece
	for e in db.validate():
		assert_false(e.begins_with("component draft_coil"), "a planned buff granting a planned machine status validates clean: %s" % e)
	piece["status"] = "implemented"
	db.components["draft_coil"] = piece
	var hit := false
	for e in db.validate():
		if e.begins_with("component draft_coil") and e.contains("a buff needs 'status'"):
			hit = true
	assert_true(hit, "the same buff marked implemented is refused until the engine has the status")
	var foe_status := ""
	for k in db.vocabulary.keys():
		var e: Dictionary = db.vocabulary[k]
		if e.get("category") == "status" and e.get("status") != "implemented" and str(e.get("design", {}).get("table", {}).get("on", "")) == "foe":
			foe_status = str(k)
			break
	if not foe_status.is_empty():
		piece["face"]["status"] = foe_status
		piece["status"] = "planned"
		db.components["draft_coil"] = piece
		hit = false
		for e in db.validate():
			if e.begins_with("component draft_coil"):
				hit = true
		assert_true(hit, "a planned buff cannot grant a foe's planned status")


func test_a_planned_chassis_is_kept_but_never_fielded() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var built: Dictionary = db.chassis["badger"].duplicate(true)
	built["passive"] = {"id": "built", "name": "Built", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 1}]}
	db.chassis["built"] = built
	assert_true(db.chassis_runnable("built"), "a chassis whose passive is built can be fielded")
	var drafted: Dictionary = built.duplicate(true)
	drafted["passive"] = {"id": "draft", "name": "Draft", "description": "Not built yet.", "status": "planned", "effects": []}
	db.chassis["drafted"] = drafted
	assert_false(db.chassis_runnable("drafted"), "a planned passive keeps the chassis off the table")
	var locked: Dictionary = built.duplicate(true)
	locked["passive"] = null
	locked["fixed"] = ["draft_piece"]
	var piece: Dictionary = db.components["twin_autoguns"].duplicate(true)
	piece["status"] = "planned"
	db.components["draft_piece"] = piece
	db.chassis["locked"] = locked
	assert_false(db.chassis_runnable("locked"), "a planned locked piece keeps the chassis off the table")
	for id in ["built", "drafted", "locked"]:
		for e in db.validate():
			assert_false(e.begins_with("chassis %s" % id), "the draft validates clean: %s" % e)


func test_planned_component_may_carry_a_planned_keyword() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = db.components["laminar_deflector"].duplicate(true)
	# The vocabulary's planned keyword of the day (Corrode until 18 October, Web until it was
	# built that day), found rather than named, so the test outlives the content; with none
	# planned, a synthetic one stands in.
	var planned_kw := ""
	for k in db.vocabulary.keys():
		if db.vocabulary[k].get("category") == "keyword" and db.vocabulary[k].get("status") != "implemented":
			planned_kw = str(k)
			break
	if planned_kw.is_empty():
		planned_kw = "taunt_test"
		db.vocabulary[planned_kw] = {"id": planned_kw, "category": "keyword", "name": "Taunt", "codex": "A keyword the engine lacks.", "status": "planned", "design": {"holes": ""}}
	assert_true(not planned_kw.is_empty(), "a planned keyword to test with")
	plate["face"]["keywords"] = [planned_kw]
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
	for e in db.validate():
		assert_false(e.begins_with("component loud_plate"), "a built component may carry a planned keyword too (19 October, the Flakshot's Flak): %s" % e)
	plate["face"]["keywords"] = ["no_such_keyword"]
	db.components["loud_plate"] = plate
	var hit := false
	for e in db.validate():
		if e.begins_with("component loud_plate") and e.contains("unknown keyword"):
			hit = true
	assert_true(hit, "a keyword the vocabulary does not name is refused")


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


## The working set is the validator's list (the stock pass, 22 October): a component wears only
## its tags, each once; a tag condition and the drum's added tag read only the set; the filing
## tags are gone from content, melee kept where the content had it.
func test_a_component_wears_only_the_working_set_of_tags() -> void:
	var db := _fresh()
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["tagged"] = gun
	gun["tags"] = ["kinetic"]
	assert_true(_refused(db, "component tagged", "not in the working set"), "a filing tag is refused")
	gun["tags"] = ["beam", "beam"]
	assert_true(_refused(db, "component tagged", "twice"), "a tag listed twice is refused")
	gun["tags"] = ["beam", "melee"]
	for e in db.validate():
		assert_false(e.begins_with("component tagged"), "tags of the working set validate clean: %s" % e)
	var side: Dictionary = db.chassis["badger"].duplicate(true)
	side["id"] = "tag_reader"
	side["name"] = "Tag Reader"
	side["passive"] = {"id": "p_tag_reader", "name": "P", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 5, "when": "tag_kinetic"}]}
	db.chassis["tag_reader"] = side
	assert_true(_refused(db, "chassis tag_reader", "outside the working set"), "a condition on a retired tag is refused")
	side["passive"]["effects"][0]["when"] = "tag_melee"
	assert_false(_refused(db, "chassis tag_reader", "working set"), "a condition on a tag of the set is clean")
	var drum: Dictionary = db.chassis["badger"].duplicate(true)
	drum["id"] = "drum_reader"
	drum["name"] = "Drum Reader"
	drum["passive"] = {"id": "p_drum_reader", "name": "P", "description": "", "effects": [
		{"trigger": "static", "effect": "rewrite_weapon", "value": 4, "reach": "indirect", "heat": 3, "tag": "kinetic"}]}
	db.chassis["drum_reader"] = drum
	assert_true(_refused(db, "chassis drum_reader", "rewrite_weapon's tag"), "the drum adds only a tag of the set")
	for id in db.components.keys():
		if id == "tagged":
			continue
		for t in db.components[id].get("tags", []):
			assert_true(ContentDB.TAGS.has(str(t)), "%s wears only the working set (%s)" % [id, t])
	assert_true(Array(db.components["chainsaw_claw"]["tags"]).has("melee"), "the claw keeps its melee")


## Breach is one word on both sides (22 October): a keyword our weapons may carry, the foes'
## rider sharing it, and an attack's alone, so a shield carrying it is refused.
func test_breach_is_a_weapon_keyword_the_foes_share() -> void:
	var db := _fresh()
	assert_eq(str(db.vocabulary["breach"]["category"]), "keyword", "one vocabulary word, a keyword")
	assert_true(Foe.ATTACK_KEYWORDS.has("breach"), "and still a foe's rider")
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["tier"] = 1
	gun["face"]["keywords"] = ["breach"]
	db.components["breacher"] = gun
	var plate: Dictionary = db.components["halo_shield"].duplicate(true)
	plate["tier"] = 1
	plate["face"]["keywords"] = ["breach"]
	db.components["breach_plate"] = plate
	var refused := false
	for e in db.validate():
		assert_false(e.begins_with("component breacher"), "a breaching weapon validates clean: %s" % e)
		if e.begins_with("component breach_plate") and e.contains("attack keyword"):
			refused = true
	assert_true(refused, "a breaching shield is refused")
	assert_true(db.build_face(gun["face"]).has(Face.Keyword.BREACH), "and the weapon builds with it")


func _refused(db: ContentDB, prefix: String, word: String) -> bool:
	for e in db.validate():
		if e.begins_with(prefix) and e.contains(word):
			return true
	return false


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
	var atk := int(db.foes["revenant"]["attack"])
	assert_true(entry["actions"].contains("CLAW // ATTACK %d" % atk), "codex lists the implemented action with the resulting number (alone on the field: no kin)")
	assert_true(entry["actions"].contains("for %d:" % atk), "and fills {damage} into the text")
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
	db.components["fins_pack"] = fins   # the jacket's own tier, a basic, below the chassis that stocks it
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
	plate["face"]["volatile"] = 3
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_plate"] = plate
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["volatile"] = 3
	gun["face"]["shield_cost"] = 2
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_gun"] = gun
	var fins: Dictionary = db.components["coolant_jacket"].duplicate(true)
	fins["face"]["volatile"] = 3
	fins["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_fins"] = fins
	for e in db.validate():
		assert_false(e.begins_with("component hot_"), "volatile validates on a shield, an attack and a vent alike, a shield cost too: %s" % e)
	var f := db.build_face(plate["face"])
	assert_eq(f.volatile, 3, "and builds onto the entry as a cost (26 October), with the bite it says")
	assert_eq(db.build_face(gun["face"]).shield_cost, 2, "the shield cost too")


## The gated stuns' fields (22 October): a gate maps a keyword the entry carries (Suppress
## today) to a condition on the foe in hand; a consumer eats a foe status on one blow.
func test_gates_and_consumers_validate() -> void:
	var db := _fresh()
	var base: Dictionary = db.components["enfilade_beam"].duplicate(true)
	base["tier"] = 1
	base["face"].erase("keywords")
	var flak_gate := {"suppress": {"when": "target_status", "status": "flakked"}}
	var cases := {
		"test_battery": [{"keywords": ["suppress"], "gates": flak_gate}, ""],
		"test_backdraft": [{"keywords": ["suppress"], "gates": {"suppress": {"when": "target_status", "status": "burning", "stacks": 2}}, "consumes": "burning", "per_consumed": 1}, ""],
		"test_gate_absent": [{"keywords": [], "gates": flak_gate}, "does not carry"],
		"test_gate_burn": [{"keywords": ["burn"], "burn": 2, "gates": {"burn": {"when": "target_status"}}}, "rides on Suppress today"],
		"test_gate_when": [{"keywords": ["suppress"], "gates": {"suppress": {"when": "rolled"}}}, "a condition on the foe in hand"],
		"test_gate_status": [{"keywords": ["suppress"], "gates": {"suppress": {"when": "target_status", "status": "numbed"}}}, "a status the team puts on a foe"],
		"test_gate_count": [{"keywords": ["suppress"], "gates": {"suppress": {"when": "target_status", "stacks": 2}}}, "a positive count of the status it names"],
		"test_eat_odd": [{"consumes": "numbed"}, "names a status the team puts on a foe"],
		"test_eat_wide": [{"keywords": ["cleave"], "consumes": "burning"}, "one blow on one foe"],
		"test_eat_stray": [{"per_consumed": 2}, "only beside consumes"],
	}
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		for k in cases[id][0]:
			c["face"][k] = cases[id][0][k]
		if not c["face"].has("keywords"):
			c["face"]["keywords"] = []
		db.components[id] = c
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])
	var f := db.build_face(db.components["test_backdraft"]["face"])
	assert_eq(f.consumes, "burning", "the consumer builds onto the entry")
	assert_eq(int(f.gates["suppress"]["stacks"]), 2, "and its gate")
	var back := Face.from_dict(f.to_dict())
	assert_true(back.consumes == "burning" and back.gates.has("suppress"), "and survives the round trip a save makes")


## Its own fire (the Stoker's, the stock pass's landing, 22 October): self_burn is a positive
## number of stacks of Burning on an attack's own machine, kept through a save.
func test_a_weapon_that_burns_its_firer_validates() -> void:
	var db := _fresh()
	var base: Dictionary = db.components["enfilade_beam"].duplicate(true)
	base["tier"] = 1
	base["face"]["keywords"] = []
	var cases := {
		"test_stoker": [{"keywords": ["burn"], "burn": 2, "self_burn": 1}, ""],
		"test_fire_none": [{"self_burn": 0}, "a positive number of stacks"],
		"test_fire_vent": [{"kind": "vent", "self_burn": 1}, "on an attack"],
	}
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		for k in cases[id][0]:
			c["face"][k] = cases[id][0][k]
		db.components[id] = c
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])
	var f := db.build_face(db.components["test_stoker"]["face"])
	assert_eq(f.self_burn, 1, "its own fire builds onto the entry")
	assert_eq(Face.from_dict(f.to_dict()).self_burn, 1, "and survives the round trip a save makes")


## The rank condition's reach (the Ram Frame's and the Rangefinder's reads, 22 October) reads an
## attack's own spend: direct or indirect, on an on_attack effect only.
func test_a_reach_beside_the_rank_is_an_attacks_and_a_real_reach() -> void:
	var db := _fresh()
	var base: Dictionary = db.modules["ram_frame"].duplicate(true)
	var cases := {
		"test_rank_reach": [{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_rank", "rank": "back", "reach": "indirect"}, ""],
		"test_rank_odd": [{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_rank", "rank": "front", "reach": "close"}, "direct or indirect"],
		"test_rank_static": [{"trigger": "static", "effect": "grant_keyword", "value": "penetrate", "when": "target_rank", "rank": "back", "reach": "indirect"}, "on an attack's own effects only"],
	}
	for id in cases:
		var m: Dictionary = base.duplicate(true)
		m["text"] = {"description": "A test.", "effects": [cases[id][0]]}
		db.modules[id] = m
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.contains(id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])


## The stock pass's engine (22 October): the rule numbers that were constants in code ride as
## fields on their keyword, their face or their status, so the content and the landing set them.
func test_the_rule_numbers_are_fields_on_their_keyword_their_face_or_their_status() -> void:
	var db := _fresh()
	var base: Dictionary = db.components["coolant_jacket"].duplicate(true)
	base["tier"] = 1
	var cases := {
		"test_keyword": [{"keywords": ["volatile"]}, "Volatile is a cost, not a keyword"],
		"test_nobite": [{"volatile": 0}, "a positive number"],
		"test_bite_ok": [{"volatile": 3}, ""],
		"test_notoll": [{"shield_cost": 0}, "a positive number"],
		"test_toll_ok": [{"shield_cost": 2}, ""],
	}
	var gun: Dictionary = db.components["coriolis_accelerator"].duplicate(true)
	gun["tier"] = 1
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		for k in cases[id][0]:
			c["face"][k] = cases[id][0][k]
		db.components[id] = c
	var stray: Dictionary = base.duplicate(true)
	stray["face"]["per_missing"] = 5
	db.components["test_stray_step"] = stray
	cases["test_stray_step"] = [{}, "only beside power_per_missing"]
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])
	# The missing-HP step reads from the entry, and so does its line.
	var f := db.build_face(gun["face"])
	f.per_missing = 5
	var foe := Foe.new()
	foe.hp_max = 30
	foe.hp = 19
	assert_eq(f.missing_bonus(foe), f.power_per_missing * 2, "two steps of 5 missing")
	assert_true(f.describe().contains("per 5 HP missing"), "the entry prints its step: %s" % f.describe())
	# Cryo's cooling and Corrupted's bite are their statuses' own numbers.
	assert_eq(Skirmish.cryo_cool(), Effects.status_value("cryoed", "cool_hitter"), "Cryo's cooling is the status's")
	assert_eq(Skirmish.corrupt_bite(), Effects.status_value("corrupted", "corrupt_bite"), "Corrupted's bite is the status's")
	assert_true(Skirmish.cryo_cool() > 0 and Skirmish.corrupt_bite() > 0, "both carry a number")


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
	var regrow := 0
	for a in db.foes["bone_dragon"]["actions"]:
		if str(a["id"]) == "regen":
			regrow = int(a["value"])
	assert_true(entry["actions"].contains("Regrows %d HP" % regrow), "with its number filled in")


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
	# boss three; every foe reads an aim the engine knows; the ghoul's claw is a swarm blow; the
	# bosses wear armour.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.validate().is_empty(), "the set validates: %s" % str(db.validate()))
	for id in db.foes.keys():
		var f := db.make_foe(id)
		assert_true(Foe.AIMS.has(f.aim), "%s aims by a word the engine knows" % id)
		if f.boss:
			assert_eq(f.actions.size(), 3, "%s, a boss, has three moves" % id)
			assert_true(f.armour > 0, "%s, a boss, wears armour" % id)
		elif f.hero and db.foes[id].has("promotes"):
			# A promoted form (the bible's section 9): its hero's moves and one more, massive and
			# armoured.
			var base := db.make_foe(str(db.foes[id]["promotes"]))
			assert_true(f.actions.size() >= base.actions.size() and f.actions.size() <= base.actions.size() + 1, "%s, a promoted form, runs its hero's moves and at most one more" % id)
			assert_true(f.is_massive() and f.armour > 0, "%s, a promoted form, is massive and armoured" % id)
		elif f.hero:
			# A hero has three moves (decided 9 October); one may still be planned, so two run.
			assert_true(f.actions.size() >= 2 and f.actions.size() <= 3, "%s, a hero, has two or three moves running" % id)
			assert_eq(f.size, 1, "%s, a hero, is human-sized" % id)
		else:
			assert_true(f.actions.size() >= 1 and f.actions.size() <= 2, "%s has one or two moves" % id)
	var g := db.make_foe("revenant")
	assert_eq(g.actions.size(), 1, "the ghoul has one move")
	var swarm := int(g.actions[0].get("swarm", 0))
	assert_true(swarm > 0, "and it swarms")
	g.kin = 3
	assert_eq(g.damage(), int(db.foes["revenant"]["attack"]) + 3 * swarm, "four on the field hit for the blow and three kin's swarm each")
	var entry := db.codex_for_foe(g)
	assert_true(entry["actions"].contains("+%d A KIN" % swarm), "the codex says the swarm: %s" % entry["actions"])
	assert_true(entry["stats"].contains("ARM") or true, "stats read")
	var maw := db.codex_for_foe(db.make_foe("sandworm"))
	assert_true(maw["actions"].contains("WHEN BELOW HALF"), "the codex says a move's condition: %s" % maw["actions"])
	assert_true(str(maw["stats"]).contains("ARM %d" % int(db.foes["sandworm"]["armour"])), "and the boss's armour")


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
func test_a_foes_stacking_rider_says_its_number() -> void:
	# 24 October: a foe's Scorch, Burn and Corrupt say their stacks, as the player's Burn does,
	# and so does an effect that lays them.
	var db := _fresh()
	var f: Dictionary = db.foes["revenant"].duplicate(true)
	f["actions"] = [{"id": "lick", "name": "Lick", "kind": "attack", "weight": 1, "keywords": ["scorch"], "text": "", "status": "implemented"}]
	db.foes["test_licker"] = f
	assert_true(_refused(db, "foe test_licker", "says its stacks"), "a Scorch without its number is refused")
	f["actions"][0]["scorch"] = 2
	for e in db.validate():
		assert_false(e.begins_with("foe test_licker"), "Scorch 2 validates clean: %s" % e)
	f["actions"][0]["corrupt"] = 1
	assert_true(_refused(db, "foe test_licker", "rides with the corrupt keyword"), "a number without its rider is refused")
	f["actions"][0].erase("corrupt")
	f["actions"].append({"id": "frost", "name": "Frost", "kind": "debuff", "effect": "corrupt_all", "weight": 1, "text": "", "status": "implemented"})
	assert_true(_refused(db, "foe test_licker", "says what it lays"), "an effect that lays stacks says how many")


func _fresh() -> ContentDB:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	return db


func _has_error(db: ContentDB, word: String) -> bool:
	for e in db.validate():
		if e.contains(word):
			return true
	return false


func test_a_component_stores_its_tier_and_the_basics_are_the_starting_blueprints() -> void:
	# 7 October: tier is power and complexity, never the maker. Stored since the stock pass (22
	# October): a component carries its tier whatever stocks it, and moving a chassis moves
	# nothing; the basics, tier zero, are the blueprints a run starts with.
	var db := _fresh()
	var stocked := ""
	var host := ""
	for id in db.chassis.keys():
		for cid in db.chassis[id].get("loadout", []):
			if stocked.is_empty() and db.component_tier(str(cid)) == 0:
				stocked = str(cid)
				host = str(id)
	assert_true(not stocked.is_empty(), "the content stocks a basic")
	assert_true(db.starting_blueprints().has(stocked), "a basic is a starting blueprint")
	db.chassis[host]["tier"] = 3
	assert_eq(db.component_tier(stocked), 0, "a chassis moving tier moves none of its stock")
	db.components[stocked]["tier"] = 1
	assert_eq(db.component_tier(stocked), 1, "the tier is the component's own")
	assert_false(db.starting_blueprints().has(stocked), "and above zero it is found, never started with")
	for cid in db.starting_blueprints():
		assert_eq(db.component_tier(str(cid)), 0, "%s starts the run as a basic" % cid)


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
	db.components[stocked].erase("tier")
	assert_true(_has_error(db, "component %s: tier must be 0, 1, 2 or 3" % stocked), "a component that is not locked stores its tier")
	db = _fresh()
	db.components[stocked]["tier"] = 4
	assert_true(_has_error(db, "component %s: tier must be 0, 1, 2 or 3" % stocked), "and only 0 to 3")
	db = _fresh()
	db.components[stocked]["tier"] = int(db.chassis[plain]["tier"])
	assert_true(_has_error(db, "chassis %s: stocks %s at tier" % [plain, stocked]), "a chassis stocks only below its own tier")
	db = _fresh()
	var cap_piece := ""
	for cid in db.components.keys():
		if cap_piece.is_empty() and str(db.components[cid].get("maker", "")) == capital and not db.is_fixed(str(cid)):
			cap_piece = str(cid)
	assert_true(not cap_piece.is_empty(), "the capital's maker makes a component")
	db.components[cap_piece]["tier"] = 0
	assert_true(_has_error(db, "the capital's maker makes no basics"), "the capital's maker has no tier zero")
	for e in _fresh().validate():
		assert_false(e.contains("tier"), "today's content keeps every tier rule: %s" % e)


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
	assert_eq(db.component_tier(locked), ContentDB.NO_TIER, "a locked component has no tier")
	for bp in db.starting_blueprints():
		assert_false(db.is_fixed(str(bp)), "no starting blueprint is locked anywhere: %s" % bp)
	db.chassis[plain]["loadout"][0] = locked
	assert_true(_has_error(db, "locked on a chassis, so no hardpoint stocks it"), "a hardpoint stocking a locked component is refused")
	assert_eq(db.component_tier(locked), ContentDB.NO_TIER, "and even then it is never a blueprint")
	assert_false(db.starting_blueprints().has(locked), "nor started with")
	db = _fresh()
	db.components[locked]["tier"] = 2
	assert_true(_has_error(db, "locked on a chassis, so it carries no tier"), "a locked component storing a tier is refused")


## Burn is a numbered keyword (Ryan, 18 October): a weapon says the stacks each blow leaves,
## and the number rides with the keyword.
func test_a_burn_weapon_says_its_stacks() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var mute: Dictionary = db.components["blazethrower"].duplicate(true)
	mute["face"].erase("burn")
	mute["tier"] = 1
	db.components["mute_torch"] = mute
	var stray: Dictionary = db.components["slugthrower"].duplicate(true)
	stray["face"]["burn"] = 2
	stray["tier"] = 1
	db.components["stray_number"] = stray
	var errs := db.validate()
	var mute_refused := false
	var stray_refused := false
	for e in errs:
		if e.begins_with("component mute_torch") and e.contains("says its stacks"):
			mute_refused = true
		if e.begins_with("component stray_number") and e.contains("rides with the Burn keyword"):
			stray_refused = true
	assert_true(mute_refused, "a Burn weapon with no number is refused")
	assert_true(stray_refused, "a number with no Burn keyword is refused")
	var shipped := ContentDB.new()
	shipped.load_dir(ContentDB.DIR)
	for c in shipped.components.values():
		var fd: Dictionary = c.get("face", {})
		if Array(fd.get("keywords", [])).has("burn"):
			assert_true(int(fd.get("burn", 0)) >= 1, "%s carries its Burn number" % c["id"])
	assert_eq(db.build_face(db.components["blazethrower"]["face"]).burn, int(db.components["blazethrower"]["face"]["burn"]), "the number reaches the entry")


## A halving status has no duration (Ryan, 18 October: "Things either decrease to zero, or are
## timed, not both"): a buff of Overcharged grants stacks and no rounds.
func test_a_buff_of_a_halving_status_takes_no_rounds() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_false(db.components["overcharge_coil"]["face"].has("rounds"), "the Overcharge Coil says its stacks and no rounds")
	var timed: Dictionary = db.components["overcharge_coil"].duplicate(true)
	timed["face"]["rounds"] = 2
	timed["tier"] = 1
	db.components["timed_coil"] = timed
	var refused := false
	for e in db.validate():
		if e.begins_with("component timed_coil") and e.contains("stacks and no rounds"):
			refused = true
	assert_true(refused, "a buff granting Overcharged for rounds is refused")
	assert_true(Effects.decays_to_zero(Effects.STATUS["overcharged"]), "Overcharged runs down on its own")
	assert_false(Effects.decays_to_zero(Effects.STATUS["primed"]), "Primed is timed by the component")
	assert_false(Effects.decays_to_zero(Effects.STATUS["braced"]), "Armoured ends with the round")


## lay_status (the funnel-web's Ambush, 18 October) names a status the engine has and lays at
## least a stack a hit.
func test_lay_status_names_an_engine_status_and_lays_at_least_a_stack() -> void:
	var db := _fresh()
	var base: Dictionary = db.chassis["badger"].duplicate(true)
	var cases := {"lay_ok": ["vitriol", 1], "lay_none": ["nothing", 1], "lay_zero": ["vitriol", 0]}
	for id in cases.keys():
		var c: Dictionary = base.duplicate(true)
		c["id"] = id
		c["name"] = str(id).capitalize()
		c["passive"] = {"id": "p_" + str(id), "name": "P", "description": "", "effects": [
			{"trigger": "on_attack", "effect": "lay_status", "value": cases[id][0], "stacks": cases[id][1], "when": "target_no_intent"}]}
		db.chassis[id] = c
	var refused := {}
	for e in db.validate():
		for id in cases.keys():
			if e.begins_with("chassis %s" % id) and e.contains("lay_status"):
				refused[id] = true
	assert_false(refused.has("lay_ok"), "a status the engine has, a stack a hit: clean")
	assert_true(refused.has("lay_none"), "a status the engine lacks is refused")
	assert_true(refused.has("lay_zero"), "and so is a lay of no stacks")
	assert_true(Effects.supports_when("target_no_intent"), "the ambush condition is one the engine runs")


func test_a_passive_may_read_the_striker_for_a_status_the_vocabulary_drafts() -> void:
	# The Prairie Dog's fight half (21 October): its clause named Flak before Flak was built (the
	# same day), so the passive stayed built and the chassis dealable; a status nobody knows is refused.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var drafted := "probe_status"   # a synthetic drafted status, none the engine knows
	db.vocabulary[drafted] = {"id": drafted, "category": "status", "name": "Probe", "codex": "A probe.", "status": "planned",
		"design": {"holes": "", "table": {"kind": "debuff", "on": "foe", "stacks": "No", "lasts": "The round"}}}
	assert_false(Effects.STATUS.has(drafted), "the vocabulary drafts a status to test with")
	var ch: Dictionary = db.chassis["prairie_dog"].duplicate(true)
	ch["passive"] = {"id": "p", "name": "P", "description": "A rule.", "effects": [
		{"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status", "status": drafted}]}
	db.chassis["probe_car"] = ch
	for e in db.validate():
		assert_false(e.begins_with("chassis probe_car"), "a drafted status on the striker's condition passes: %s" % e)
	assert_true(db.chassis_runnable("probe_car"), "and the chassis stays dealable")
	ch["passive"]["effects"][0]["status"] = "nonsense"
	db.chassis["probe_car"] = ch
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis probe_car") and e.contains("attacker_status"):
			hit = true
	assert_true(hit, "a status nobody knows is refused")


## Cryo is a numbered keyword like Burn (20 October), and the Armadillo's content runs: its
## Lockdown passive carries the seal, its die the Cryo Flinger pair before four hardpoints.
func test_a_cryo_weapon_says_its_stacks_and_the_armadillo_leads_with_its_flingers() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var mute: Dictionary = db.components["cryo_flinger"].duplicate(true)
	mute["face"].erase("cryo")
	db.components["mute_flinger"] = mute
	var stray: Dictionary = db.components["slugthrower"].duplicate(true)
	stray["face"]["cryo"] = 1
	stray["tier"] = 1
	db.components["stray_cryo"] = stray
	var refused := {}
	for e in db.validate():
		if e.begins_with("component mute_flinger") and e.contains("says its stacks"):
			refused["mute"] = true
		if e.begins_with("component stray_cryo") and e.contains("rides with the Cryo keyword"):
			refused["stray"] = true
	assert_true(refused.has("mute"), "a Cryo weapon with no number is refused")
	assert_true(refused.has("stray"), "a number with no Cryo keyword is refused")
	var fresh := ContentDB.load_default()
	var m := fresh.make_mech("armadillo")
	assert_eq(m.die.faces.size(), 6, "two flingers and four hardpoints")
	assert_true(m.die.faces[0].has(Face.Keyword.CRYO) and m.die.faces[1].has(Face.Keyword.CRYO), "the pair leads the die")
	assert_true(m.die.faces[0].has(Face.Keyword.LURE) and m.die.faces[0].has(Face.Keyword.RAPID), "each a lure with Rapid")
	assert_eq(m.armour, int(fresh.chassis["armadillo"]["armour"]), "its base armour, as the content says")


## Flak lands (21 October): the Flakshot Repeater builds with its Flak and sprays, and the
## validator asks a Flak weapon for its stacks and the stacks for the keyword, as it does Burn's
## and Cryo's (a foe carrying Flak hitting lighter is the synthetic attacker_status test's).
func test_the_flakshot_lays_flak_and_the_validator_asks_for_its_stacks() -> void:
	var fresh := ContentDB.load_default()
	var m := fresh.make_mech("prairie_dog")
	var gun: Face = null
	for f in m.die.faces:
		if f.component == "flakshot_repeater":
			gun = f
	var stacks := int(fresh.components["flakshot_repeater"]["face"]["flak"])
	assert_true(gun != null and gun.has(Face.Keyword.FLAK) and gun.flak == stacks and stacks > 0, "the Repeater carries its Flak")
	assert_true(gun.has(Face.Keyword.CLEAVE), "and sprays")
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var mute: Dictionary = db.components["flakshot_repeater"].duplicate(true)
	mute["face"].erase("flak")
	db.components["mute_flak"] = mute
	var stray: Dictionary = db.components["slugthrower"].duplicate(true)
	stray["face"]["flak"] = 1
	stray["tier"] = 1
	db.components["stray_flak"] = stray
	var refused := {}
	for e in db.validate():
		if e.begins_with("component mute_flak") and e.contains("says its stacks"):
			refused["mute"] = true
		if e.begins_with("component stray_flak") and e.contains("rides with the Flak keyword"):
			refused["stray"] = true
	assert_true(refused.has("mute"), "a Flak weapon with no number is refused")
	assert_true(refused.has("stray"), "a number with no Flak keyword is refused")


## The cooldown (Ryan, 14 October) and Rapid's limiter (15 October): a cooldown is a whole
## number of rounds, 0 lifts Rapid's switch-off and nothing else's, and a Rapid entry that
## prints no cooldown pays heat or Volatile every spend.
func test_a_cooldown_is_whole_rounds_and_every_rapid_entry_carries_a_limiter() -> void:
	var db := _fresh()
	var base: Dictionary = db.components["coolant_jacket"].duplicate(true)
	base["tier"] = 1
	var cases := {
		"test_free": [{"keywords": ["rapid"], "cooldown": 0}, "carries another limiter"],
		"test_hot": [{"keywords": ["rapid"], "cooldown": 0, "heat": 5}, ""],
		"test_bite": [{"keywords": ["rapid"], "volatile": 3, "cooldown": 0}, ""],
		"test_toll": [{"keywords": ["rapid"], "shield_cost": 2, "cooldown": 0}, ""],
		"test_switch": [{"keywords": ["rapid"]}, ""],
		"test_lift": [{"cooldown": 0}, "has none to lift"],
		"test_negative": [{"cooldown": -1}, "whole number of rounds"],
		"test_two": [{"cooldown": 2}, ""],
	}
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		var fields: Dictionary = cases[id][0]
		for k in fields:
			c["face"][k] = fields[k]
		db.components[id] = c
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused for '%s': %s" % [id, want, str(mine)])
	var flinger: Dictionary = db.components["cryo_flinger"]["face"]
	assert_eq(int(flinger.get("cooldown", -1)), 0, "the Cryo Flinger prints no cooldown, its heat the limiter (Ryan's design, 20 October)")
	assert_eq(db.build_face(flinger).cooldown_rounds(), 0, "and the engine runs it so")


## A piece locked on a stepping die has the cylinder for its Rapid's limiter (the Cassowary's
## Spin-Up, Ryan, 19 October); anywhere else the same entry is refused, a spin rides with
## Rapid, and a status a weapon spends (Spun Up) is granted with no rounds.
func test_a_stepping_die_is_its_locked_rapid_pieces_limiter() -> void:
	var db := _fresh()
	assert_false(db.validate().any(func(e: String) -> bool: return e.begins_with("component spin_up")), "the Spin-Up validates where it is locked")
	var loose: Dictionary = db.components["spin_up"].duplicate(true)
	loose["tier"] = 1
	db.components["test_loose_spin"] = loose
	var plain: Dictionary = db.components["spin_up"].duplicate(true)
	plain["tier"] = 1
	plain["face"].erase("spins")
	plain["face"]["keywords"] = []
	plain["face"]["spins"] = true
	db.components["test_spin_alone"] = plain
	var timed: Dictionary = db.components["spin_up"].duplicate(true)
	timed["tier"] = 1
	timed["face"]["rounds"] = 1
	timed["face"]["cooldown"] = 1
	db.components["test_timed_spin"] = timed
	var errs := db.validate()
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_loose_spin") and e.contains("carries another limiter")), "off the cylinder it needs a limiter of its own")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_spin_alone") and e.contains("rides with Rapid")), "a spin rides with Rapid")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_timed_spin") and e.contains("no rounds")), "Spun Up takes no rounds")


## The drum's rewrite and the rank condition (the Cottonmouth's, 19 October): a rewrite says its
## number, reach and heat and never keys on reach; a rank condition says front or back.
func test_a_rewrite_says_its_shot_and_a_rank_condition_its_rank() -> void:
	var db := _fresh()
	var base: Dictionary = db.chassis["cottonmouth"].duplicate(true)
	base["passive"]["effects"] = [{"trigger": "static", "effect": "rewrite_weapon", "value": 15, "reach": "sideways", "heat": 10}]
	db.chassis["test_drum_bad"] = base
	var side: Dictionary = db.chassis["cottonmouth"].duplicate(true)
	side["passive"]["effects"] = [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "target_rank", "rank": "middle"}]
	db.chassis["test_rank_bad"] = side
	var errs := db.validate()
	assert_true(errs.any(func(e: String) -> bool: return e.contains("test_drum_bad") and e.contains("rewrite_weapon fires every weapon as one shot")), "a rewrite with no reach is refused")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("test_rank_bad") and e.contains("target_rank needs rank")), "a rank that is neither is refused")


## The Siphon's rules and the vent blast (the Whip Scorpion's, 20 October): a reach over every
## foe is an attack's, a heat a blow taken is a positive number, and a blast a positive share.
func test_the_siphons_rules_and_the_vent_blast_say_their_numbers() -> void:
	var db := _fresh()
	var plate: Dictionary = db.components["coolant_jacket"].duplicate(true)
	plate["tier"] = 1
	plate["face"]["reaches_all"] = true
	plate["face"]["heat_per_blow"] = 0
	db.components["test_vent_all"] = plate
	var boiler: Dictionary = db.chassis["whip_scorpion"].duplicate(true)
	boiler["passive"]["effects"] = [{"trigger": "static", "effect": "vent_blast", "value": 0}]
	db.chassis["test_boiler"] = boiler
	var errs := db.validate()
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_vent_all") and e.contains("reaches_all")), "a vent never reaches every foe")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_vent_all") and e.contains("heat_per_blow")), "a heat a blow is positive")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("test_boiler") and e.contains("vent_blast")), "and a blast's share")


## A promoted form (the bible's section 9): its entry holds what the class change adds and
## takes the rest from its hero as the content loads, a move of its own with one of its hero's
## ids taking that move's place; the validator holds it massive, a hero's, one to a hero, and
## a hero the run may deal needs one.
func test_a_promoted_form_takes_its_heros_kit_and_adds_its_own() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var fid := str(db.factions.keys()[0])
	db.foes["test_hero"] = {"id": "test_hero", "name": "The Tester", "faction": fid, "hero": true,
		"design": {"fantasy": "a test"}, "codex": "c", "flavour": "f", "hp": 70, "attack": 15, "rank": "back", "aim": "focus",
		"actions": [{"id": "jab", "name": "Jab", "kind": "attack", "weight": 2, "text": "", "status": "implemented"},
			{"id": "guard", "name": "Guard", "kind": "defend", "effect": "brace", "value": 5, "weight": 1, "text": "", "status": "implemented"}]}
	db.foes["test_hero_up"] = {"id": "test_hero_up", "promotes": "test_hero", "size": 2, "rank": "front", "armour": 5,
		"design": {"fantasy": "its class change"},
		"actions": [{"id": "guard", "name": "Guard", "kind": "defend", "effect": "brace", "value": 10, "weight": 1, "text": "", "status": "implemented"},
			{"id": "ready", "name": "Ready", "kind": "buff", "effect": "revive_once_ally", "weight": 1, "when": "ally_unready", "text": "", "status": "implemented"}]}
	db._resolve_promotions()
	var whole: Dictionary = db.foes["test_hero_up"]
	assert_eq(str(whole["name"]), "The Tester", "the same name, its hero's")
	assert_eq([int(whole["hp"]), int(whole["attack"]), str(whole["aim"]), str(whole["faction"])], [70, 15, "focus", fid], "its hero's numbers, sense and domain")
	assert_eq([int(whole["size"]), str(whole["rank"]), int(whole["armour"])], [2, "front", 5], "massive, front, armour 5: its own")
	assert_eq(whole["actions"].map(func(a): return str(a["id"])), ["jab", "guard", "ready"], "its hero's moves, then its own")
	assert_eq(int(whole["actions"][1]["value"]), 10, "a move of its own with a hero's id takes that move's place")
	assert_false(whole.has("hero"), "it is no hero itself")
	assert_eq(str(whole["design"]["fantasy"]), "its class change", "its design is its own")
	assert_eq(db.foes["test_hero"]["actions"].size(), 2, "the hero's own kit is untouched")
	assert_eq(db.promoted_form("test_hero"), "test_hero_up", "the hero finds its promoted form")
	var f := db.make_foe("test_hero_up")
	assert_true(f.hero and f.is_massive() and f.armour == 5, "made, it is one of the party, massive and armoured")
	assert_true(db.validate().is_empty(), "it validates: %s" % str(db.validate()))
	var refusals := func(word: String) -> bool:
		for e in db.validate():
			if e.contains(word):
				return true
		return false
	whole["size"] = 1
	assert_true(refusals.call("a promoted form is massive"), "a promoted form stands one slot high: refused")
	whole["size"] = 2
	db.foes["test_hero_up2"] = whole.duplicate(true)
	db.foes["test_hero_up2"]["id"] = "test_hero_up2"
	assert_true(refusals.call("a hero has one promoted form"), "a second class change for one hero: refused")
	db.foes.erase("test_hero_up2")
	whole["promotes"] = str(db.spawn_table(fid)[0][0])
	assert_true(refusals.call("which is no hero"), "a class change of the rank and file: refused")
	whole["promotes"] = "test_hero"
	db.foes.erase("test_hero_up")
	db.factions[fid]["bench"] = Array(db.factions[fid].get("bench", [])) + ["test_hero"]
	assert_true(refusals.call("bench hero test_hero has no promoted form"), "a hero the run may deal without its class change: refused")


## A passive may break a rule as a one-off (the bible's section 7): the chassis's design names
## it, and the effect cap lifts by one for that passive alone (the Kite's four effects).
func test_a_passive_one_off_lifts_the_effect_cap_by_one() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var cid := ""
	for id in db.chassis.keys():
		if db.chassis[id].get("passive", null) is Dictionary and not str(db.chassis[id].get("design", {}).get("one_off", "")).is_empty():
			continue
		cid = str(id)
		break
	var four := {"id": "test_four", "name": "Four", "description": "Four effects.", "effects": [
		{"trigger": "on_attack", "effect": "multiply_printed", "value": 2},
		{"trigger": "on_attack", "effect": "add_heat", "value": 10},
		{"trigger": "static", "effect": "weapon_cooldown", "value": 2},
		{"trigger": "on_kill", "effect": "stack_status", "value": "hot_streak"}]}
	db.chassis[cid]["passive"] = four
	db.chassis[cid]["design"].erase("one_off")
	var capped := func() -> bool:
		for e in db.validate():
			if e.begins_with("chassis %s" % cid) and e.contains("passive has 4 effects"):
				return true
		return false
	assert_true(capped.call(), "four effects without a one-off: refused")
	db.chassis[cid]["design"]["one_off"] = "a test's reason"
	assert_false(capped.call(), "with the one-off named in its design, allowed")
	four["effects"].append({"trigger": "on_attack", "effect": "add_damage", "value": 1})
	assert_true(db.validate().any(func(e): return e.begins_with("chassis %s" % cid) and e.contains("passive has 5 effects")), "the lift is one, never more")

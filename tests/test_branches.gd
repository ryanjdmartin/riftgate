extends TestCase

## An upgrade's branches (the bible's tiers row: a pick of one from two that tweaks a locked piece,
## two directions each two steps deep, Ryan's shape; the Storm Petrel the first to carry them, 17
## November), on a synthetic frame: the picks a machine's tier allows, each step laid as a modifier
## sourced "branch" on its locked piece and read through the pipeline, what the codex, a save and
## the harness keep of them, and the validator's hold on the shape.

const K := Face.Keyword


## A tier-`tier` frame of the content's own shape (the Storm Petrel's of 18 November): its lure the
## locked piece, laying Hardened Light 1 up to 3, a gun on its one hardpoint, two directions as deep
## as the tier picks (Guard: a Ward and a cap of 4, then Spread with a stack for each foe hit and a
## cap of 5; Spark: Chain 2 and Charged 1, then Chain 3 and Charged 2).
func _db(tier: int = 1) -> ContentDB:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	db.components["test_lure"] = {"id": "test_lure", "name": "Test Lure", "face": {"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"], "heat": 3,
		"self_statuses": [{"status": "hardened", "stacks": 1, "cap": 3}]}}
	db.components["test_gun"] = {"id": "test_gun", "name": "Test Gun", "face": {"kind": "attack", "reach": "direct", "power": 3, "heat": 1}}
	var ward := {"trigger": "static", "effect": "self_status", "status": "ward", "value": 1, "entry": "test_lure"}
	var hold := {"trigger": "static", "effect": "self_status", "status": "hardened", "value": 1, "cap": 4, "entry": "test_lure"}
	var wide := {"trigger": "static", "effect": "grant_keyword", "value": "cleave", "entry": "test_lure"}
	var each := {"trigger": "static", "effect": "self_status", "status": "hardened", "value": 1, "per_foe": true, "cap": 5, "entry": "test_lure"}
	var chain2 := {"trigger": "static", "effect": "grant_keyword", "value": "chain", "number": 2, "entry": "test_lure"}
	var charge1 := {"trigger": "static", "effect": "self_status", "status": "charged", "value": 1, "entry": "test_lure"}
	var chain3 := {"trigger": "static", "effect": "grant_keyword", "value": "chain", "number": 3, "entry": "test_lure"}
	var charge2 := {"trigger": "static", "effect": "self_status", "status": "charged", "value": 2, "entry": "test_lure"}
	var deep := maxi(0, 3 - tier)
	db.chassis["test_frame"] = {"id": "test_frame", "name": "Test Frame", "designation": "TF-1", "codex": "", "flavour": "", "tier": tier,
		"hull": 20, "shield": 10, "armour": 0, "heat_max": 12, "movespeed": 3, "size": "medium", "traits": ["hover"],
		"hardpoints": 1, "module_slots": 0, "fixed": ["test_lure"], "loadout": ["test_gun"], "passive": null,
		"branches": [
			{"id": "guard", "name": "Guard", "steps": [{"description": "Guard one.", "effects": [ward, hold]}, {"description": "Guard two.", "effects": [wide, each]}].slice(0, deep)},
			{"id": "spark", "name": "Spark", "steps": [{"description": "Spark one.", "effects": [chain2, charge1]}, {"description": "Spark two.", "effects": [chain3, charge2]}].slice(0, deep)}]}
	return db


## Grants in status order, so a check reads what is laid and not the order it was gathered in.
func _sorted(grants: Array) -> Array:
	var out := grants.duplicate(true)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["status"]) < str(b["status"]))
	return out


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1, 4)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


func test_a_tier_one_picks_twice_along_two_directions_and_a_tier_two_once() -> void:
	var db := _db(1)
	for picks in [[], ["guard"], ["spark"], ["guard", "guard"], ["guard", "spark"], ["spark", "guard"], ["spark", "spark"]]:
		assert_eq(db.branch_error("test_frame", picks), "", "%s: a tier one's picks, specialized or mixed" % str(picks))
	assert_false(db.branch_error("test_frame", ["guard", "guard", "spark"]).is_empty(), "a tier one picks twice, no more")
	assert_false(db.branch_error("test_frame", ["fire"]).is_empty(), "a direction the chassis has not")
	assert_eq(db.branch_builds("test_frame"), [[], ["guard"], ["spark"], ["guard", "guard"], ["guard", "spark"], ["spark", "spark"]],
		"six builds as a machine reaches them, the mixed one once whichever way it was taken")
	var names: Array = db.branch_steps("test_frame", ["spark", "guard"]).map(func(s: Dictionary) -> String: return str(s["name"]))
	assert_eq(names, ["Spark I", "Guard I"], "each pick its direction's next step, named by its numeral")
	assert_eq(db.branch_steps("test_frame", ["spark", "spark"]).map(func(s: Dictionary) -> String: return str(s["description"])), ["Spark one.", "Spark two."], "the deeper step only after the first")
	var two := _db(2)
	assert_eq(two.branch_error("test_frame", ["spark"]), "", "a tier two picks once")
	assert_false(two.branch_error("test_frame", ["spark", "spark"]).is_empty(), "and only once: its directions are a step deep")
	assert_eq(two.branch_builds("test_frame").size(), 3, "none, or either direction's single step")
	assert_false(_db(3).branch_error("test_frame", ["spark"]).is_empty(), "a tier three never picks")
	assert_false(db.branch_error("badger", ["guard"]).is_empty(), "a chassis with no branches takes no pick")


func test_each_step_tweaks_its_locked_piece_through_the_pipeline_and_the_die_keeps_it_printed() -> void:
	var db := _db(1)
	var u := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["guard", "guard"])
	assert_eq(Array(u.branches), ["guard", "guard"], "its picks, in the order taken")
	assert_eq(u.modifiers.filter(func(m) -> bool: return m.source == "branch").size(), 2, "each step a modifier sourced branch, never a write to the piece")
	var lure: Face = u.die.faces[0]
	var gun: Face = u.die.faces[1]
	assert_false(lure.has(K.CLEAVE), "the die keeps the piece as printed")
	assert_eq(lure.self_statuses, [{"status": "hardened", "stacks": 1, "per_foe": false, "cap": 3}], "the piece prints its own grant")
	var spent := Effects.effective_face(u, lure)
	assert_true(spent.has(K.CLEAVE), "the lure as spent spreads")
	assert_eq(_sorted(spent.self_statuses), [{"status": "hardened", "stacks": 1, "per_foe": true, "cap": 5}, {"status": "ward", "stacks": 1, "per_foe": false, "cap": 0}],
		"and lays Hardened Light a stack for each foe hit up to 5, and its Ward: each step takes the piece's own grant further")
	assert_true(Effects.effective_face(u, gun).self_statuses.is_empty() and not Effects.effective_face(u, gun).has(K.CLEAVE), "the gun beside it untouched")
	var mixed := db.make_mech("test_frame", 2, Vector2i.ZERO, null, [], ["guard", "spark"])
	var m := Effects.effective_face(mixed, mixed.die.faces[0])
	assert_eq(_sorted(m.self_statuses), [{"status": "charged", "stacks": 1, "per_foe": false, "cap": 0}, {"status": "hardened", "stacks": 1, "per_foe": false, "cap": 4},
		{"status": "ward", "stacks": 1, "per_foe": false, "cap": 0}], "a mixed build: the Ward and a cap of 4, and Charged 1")
	assert_true(m.has(K.CHAIN) and m.chain == 2 and not m.has(K.CLEAVE), "its Chain 2, and no Spread")
	var striker := db.make_mech("test_frame", 3, Vector2i.ZERO, null, [], ["spark", "spark"])
	var s := Effects.effective_face(striker, striker.die.faces[0])
	assert_true(s.has(K.CHAIN) and s.chain == 3, "the deeper Spark step: Chain 3 in place of 2")
	assert_eq(_sorted(s.self_statuses)[0], {"status": "charged", "stacks": 2, "per_foe": false, "cap": 0}, "and Charged 2 in place of 1")
	assert_true(db.make_mech("test_frame", 4, Vector2i.ZERO, null, [], ["guard", "guard", "guard"]).branches.is_empty(), "picks its chassis does not allow lay nothing")
	assert_true(db.make_mech("test_frame").branches.is_empty(), "a machine at its chassis's tier has none")


func test_a_built_machine_lures_three_and_hardens_for_each_and_its_striker_arcs_to_the_shocked() -> void:
	var db := _db(1)
	var u := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["guard", "guard"])
	var sk := _fight([u], [Foe.make("revenant", 300, 5), Foe.make("revenant", 300, 5), Foe.make("revenant", 300, 5)])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, sk.foe_at(0, 1)), "the lure at the middle foe")
	assert_eq(Effects.stacks_of(u, "hardened"), 3, "Hardened Light 3: a stack for each foe its Spread hit")
	assert_true(Effects.has(u, "ward"), "and its Ward")
	assert_true(sk.field_foes().all(func(f: Foe) -> bool: return f.target == ms), "all three turn on it")
	var v := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["spark", "spark"])
	var s2 := _fight([v, db.make_mech("test_frame", 2)], [Foe.make("revenant", 30, 2), Foe.make("revenant", 30, 2), Foe.make("revenant", 30, 2)])
	var vs: Skirmish.MechState = s2.mechs[0]
	vs.face_index = 0
	for foe in s2.field_foes():
		foe.target = s2.mechs[1]   # every foe aims at the other machine, so a lure shows as a turn
	var c: Foe = s2.foe_at(0, 2)
	Effects.stack(c, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_true(s2.assign(0, s2.foe_at(0, 0)), "the lure at a foe that carries no Shock")
	assert_eq(c.hp, 27, "its arc lands 3 on the Shocked foe")
	assert_eq(c.target, s2.mechs[1], "and lures nothing: an arc is its blow alone")
	assert_eq(s2.foe_at(0, 0).target, vs, "the lure turns its target alone")
	assert_eq(Effects.stacks_of(v, "charged"), 2, "Charged 2 on itself, the lure spending none")
	assert_eq(Effects.stacks_of(v, "hardened"), 1, "and the piece's own Hardened Light 1")


func test_the_codex_a_save_and_the_harness_keep_the_picks() -> void:
	var db := _db(1)
	var u := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["spark", "guard"])
	var rules: Array = db.codex_for_unit(u)["face_rules"][0]
	assert_true(rules.has("Spark I: Spark one.") and rules.has("Guard I: Guard one."), "each step on its locked piece's row: %s" % str(rules))
	assert_true((db.codex_for_unit(u)["face_rules"][1] as Array).is_empty(), "none on the gun's")
	var back := SaveGame._unit_from(SaveGame._unit_dict(u))
	assert_eq(Array(back.branches), ["spark", "guard"], "a save keeps its picks")
	assert_eq(Effects.self_grants(back, back.die.faces[0]), Effects.self_grants(u, u.die.faces[0]), "and what they lay")
	var setup := HarnessSetup.new(db)
	setup.team = ["test_frame"]
	setup.set_branches("test_frame", ["guard", "spark"])
	var again := HarnessSetup.from_dict(setup.to_dict(), db)
	assert_eq(again.branch_picks("test_frame"), ["guard", "spark"], "the harness keeps them between launches")
	assert_eq(Array(again.make_team()[0].branches), ["guard", "spark"], "and fields the machine with them")
	again.set_branches("test_frame", ["guard", "guard", "spark"])
	assert_true(again.branch_picks("test_frame").is_empty(), "picks its chassis does not allow forget the edit")


func test_the_validator_holds_a_branch_to_a_tweak_of_a_locked_piece() -> void:
	var db := _db(1)
	var errs: Array[String] = []
	db._validate_branches("chassis test_frame", db.chassis["test_frame"], errs)
	assert_eq(errs, [] as Array[String], "two directions two steps deep, each a tweak of the lure")
	var cases := {
		"one direction": func(c: Dictionary) -> void: c["branches"] = [c["branches"][0]],
		"a step short": func(c: Dictionary) -> void: c["branches"][0]["steps"] = [c["branches"][0]["steps"][0]],
		"a stat": func(c: Dictionary) -> void: c["branches"][1]["steps"][0]["effects"] = [{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 2, "entry": "test_lure"}],
		"off the lock": func(c: Dictionary) -> void: c["branches"][1]["steps"][1]["effects"][0]["entry"] = "test_gun",
		"no words": func(c: Dictionary) -> void: c["branches"][0]["steps"][0]["description"] = "",
		"a stray key": func(c: Dictionary) -> void: c["branches"][0]["steps"][0]["face"] = {},
		"a tier three": func(c: Dictionary) -> void: c["tier"] = 3,
	}
	for name in cases.keys():
		var c: Dictionary = db.chassis["test_frame"].duplicate(true)
		(cases[name] as Callable).call(c)
		var e: Array[String] = []
		db._validate_branches("chassis test_frame", c, e)
		assert_false(e.is_empty(), "%s is refused" % name)
	var real := ContentDB.load_default()
	for cid in real.chassis.keys():
		if real.chassis[cid].has("branches"):
			for b in real.branch_builds(str(cid)):
				assert_eq(real.make_mech(str(cid), 1, Vector2i.ZERO, null, [], b).branches.size(), (b as Array).size(), "%s builds with %s" % [cid, str(b)])


## A step may tweak as many pieces as it needs (Ryan, 19 November: "Things that limit design space
## should never be a rule"): one on the passive and a locked piece at once validates, rides the
## passive, each effect still on its own piece, and its line stands under the passive in the codex.
func test_a_step_may_tweak_the_passive_and_a_locked_piece_at_once() -> void:
	var db := _db(1)
	var c: Dictionary = db.chassis["test_frame"]
	c["passive"] = {"id": "test_passive", "name": "Test Passive", "description": "Plain.", "effects": [
		{"trigger": "static", "effect": "shield_zap", "value": 2, "cost": 2, "slot": "zap"}]}
	c["branches"][0]["steps"][0]["effects"] = [
		{"trigger": "static", "effect": "shield_zap", "value": 3, "cost": 2, "slot": "zap"},
		{"trigger": "static", "effect": "self_status", "status": "ward", "value": 1, "entry": "test_lure"}]
	var errs: Array[String] = []
	db._validate_branches("chassis test_frame", c, errs)
	assert_eq(errs, [] as Array[String], "the passive's slot and the lure in one step")
	var u := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["guard"])
	var step: Effects.Modifier = null
	for m in u.modifiers:
		if m.source == "branch":
			step = m
	assert_true(step != null and step.component.is_empty(), "on two pieces, it rides the passive")
	assert_eq(int(Effects.zap_of(u, u.die.faces[1])["damage"]), 3, "the passive's slot takes the step's number")
	assert_true(Effects.self_grants(u, u.die.faces[0]).any(func(g: Dictionary) -> bool: return g["status"] == "ward"), "and the lure lays its Ward")
	var codex := db.codex_for_unit(u)
	assert_true((codex["passive_rows"] as Array).any(func(r: Array) -> bool: return str(r[0]) == "GUARD I: Guard one."), "its line under the passive: %s" % str(codex["passive_rows"]))
	for rules in codex["face_rules"]:
		assert_false((rules as Array).has("Guard I: Guard one."), "and on no piece's row")


## The die shows a piece's upgrades (Ryan, 19 November: "I agree on the chevron"): a chevron for
## each step taken on it, counted once a step however many of its effects name the piece; a step on
## the passive alone is on no piece, and a destroyed piece shows none.
func test_each_step_taken_on_a_piece_is_a_chevron_beside_its_place() -> void:
	var db := _db(1)
	for picks in [[], ["guard"], ["guard", "guard"], ["guard", "spark"]]:
		var u := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], picks)
		assert_eq(Effects.steps_on(u, u.die.faces[0]), (picks as Array).size(), "%s: a chevron a step on the lure" % str(picks))
		assert_eq(Effects.steps_on(u, u.die.faces[1]), 0, "%s: none on the gun" % str(picks))
		assert_eq(db.codex_for_unit(u)["face_steps"], [(picks as Array).size(), 0], "%s: the codex's rows" % str(picks))
	var c: Dictionary = db.chassis["test_frame"]
	c["passive"] = {"id": "test_passive", "name": "Test Passive", "description": "Plain.", "effects": [
		{"trigger": "static", "effect": "shield_zap", "value": 2, "cost": 2, "slot": "zap"}]}
	c["branches"][1]["steps"][0]["effects"] = [{"trigger": "static", "effect": "shield_zap", "value": 3, "cost": 2, "slot": "zap"}]
	var on_passive := db.make_mech("test_frame", 2, Vector2i.ZERO, null, [], ["spark"])
	assert_eq(Effects.steps_on(on_passive, on_passive.die.faces[0]), 0, "a step on the passive alone is on no piece")
	var worn := db.make_mech("test_frame", 3, Vector2i.ZERO, null, [], ["guard", "guard"])
	var sk := Skirmish.new(1, 4)
	sk.add_mech(worn)
	sk.add_foes([Foe.make("revenant", 30, 0)])
	sk.begin()
	sk.start_round()
	sk._injure_entry(sk.mechs[0], 0)
	assert_eq(Effects.steps_on(worn, worn.die.faces[0]), 0, "a destroyed piece shows none")


## A step may name the piece it upgrades (Ryan, 19 November: "I intended the gundam to change its
## equipment names for the booster and the offhand"; "the upgrade decisions should be represented on
## the die somehow"): the die's readout and the codex call it by the step's name, the die keeping the
## piece as printed.
func test_a_step_may_name_the_piece_it_upgrades() -> void:
	var db := _db(1)
	var c: Dictionary = db.chassis["test_frame"]
	c["branches"][0]["steps"][0]["effects"] = [{"trigger": "static", "effect": "self_status", "status": "ward", "value": 1, "entry": "test_lure", "name": "Test Lance"}]
	var errs: Array[String] = []
	db._validate_branches("chassis test_frame", c, errs)
	assert_eq(errs, [] as Array[String], "a name on an effect that names its piece")
	var u := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["guard"])
	var lure: Face = u.die.faces[0]
	assert_eq(Effects.entry_name(u, lure), "Test Lance", "the step's name for its piece")
	assert_eq(Effects.effective_face(u, lure).renamed, "Test Lance", "the entry as shown carries it")
	assert_eq(lure.renamed, "", "the die keeps the piece as printed")
	assert_eq(Effects.entry_name(u, u.die.faces[1]), "", "and no other piece takes it")
	var lines := EntryReadout.lines_for(Effects.effective_face(u, lure), 1, -1, lure, [], [], db)
	assert_eq(str(lines[0]["text"]), "TEST LANCE", "the readout's title")
	var rows: Array = db.codex_for_unit(u)["faces"]
	assert_eq([(rows[0] as Face).renamed, (rows[1] as Face).renamed], ["Test Lance", ""], "the codex's rows")
	assert_eq(str(EntryReadout.codex_lines(rows[0], db)[0]["text"]), "TEST LANCE", "and its row's name")
	var plain := db.make_mech("test_frame", 2, Vector2i.ZERO)
	assert_eq(Effects.entry_name(plain, plain.die.faces[0]), "", "unpicked, its own")
	var bad: Array[String] = []
	db._validate_passive("passive x", {"id": "x", "name": "X", "description": "x", "effects": [{"trigger": "static", "effect": "self_status", "status": "ward", "value": 1, "name": "Stray"}]}, bad)
	assert_true(bad.any(func(e: String) -> bool: return e.contains("the name its piece takes")), "a name with no piece to name is refused")


## The harness's UPG line (under a machine's hardpoints): every build its chassis allows, one pick,
## the setup's and the row's at once; Stock takes it off with the rest.
func test_the_harness_offers_every_build_and_the_row_names_the_one_picked() -> void:
	var db := _db(1)
	var s := HarnessSetup.new(db)
	s.team = []
	var h: Control = preload("res://game/harness.gd").new()
	h.build(s)
	h._rows["test_frame"]["check"].button_pressed = true
	h._toggle_loadout("test_frame")
	var upg: OptionButton = null
	for line in h._rows["test_frame"]["editor"].get_children():
		if line.get_child_count() > 1 and line.get_child(0) is Label and (line.get_child(0) as Label).text == "UPG":
			upg = line.get_child(1)
	assert_true(upg != null, "a chassis with branches has its UPG line")
	assert_eq(upg.item_count, 6, "the six builds, none first")
	var at := -1
	for i in range(upg.item_count):
		if upg.get_item_metadata(i) == ["guard", "guard"]:
			at = i
	assert_true(at > 0 and upg.get_item_text(at) == "Guard I, Guard II", "each build by its steps' names")
	upg.select(at)
	upg.item_selected.emit(at)
	assert_eq(s.branch_picks("test_frame"), ["guard", "guard"], "the pick is the setup's")
	assert_true(h._rows["test_frame"]["status"].text.contains("upgrades: Guard I, Guard II"), "and the row names it: %s" % h._rows["test_frame"]["status"].text)
	h.free()


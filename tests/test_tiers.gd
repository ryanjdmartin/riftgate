extends TestCase

## A machine's tier (the bible's tiers row: "Machines level is tier. Everything is tier."; the
## locked pieces' footing, 20 November), on a synthetic frame and a synthetic lift: a machine
## arrives at its chassis's tier, each tier above it bought with its branch's pick, and each lifts
## the whole machine, its stat lines and its locked weapons' own numbers, as a modifier sourced
## "tier" read through the pipeline, never a write; what the codex, the saves and the runs keep of
## it; and the validator's hold on the lift.

const LIFT := {"stats": {"hull": 5, "shield": 3}, "locked_power": 2}


## A frame of tier `tier`: a locked gun of 3 and a locked lure of 0, a plain gun on its one
## hardpoint, two directions as deep as its tier picks, and the lift above as content's standard.
func _db(tier: int = 1) -> ContentDB:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	db.tier_lift = LIFT.duplicate(true)
	db.components["test_lock_gun"] = {"id": "test_lock_gun", "name": "Test Lock Gun", "face": {"kind": "attack", "reach": "direct", "power": 3, "heat": 2}}
	db.components["test_lock_lure"] = {"id": "test_lock_lure", "name": "Test Lock Lure", "face": {"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"], "heat": 1}}
	db.components["test_plain_gun"] = {"id": "test_plain_gun", "name": "Test Plain Gun", "tier": 1, "face": {"kind": "attack", "reach": "direct", "power": 3, "heat": 1}}
	var chain := {"trigger": "static", "effect": "grant_keyword", "value": "chain", "number": 2, "entry": "test_lock_gun"}
	var cleave := {"trigger": "static", "effect": "grant_keyword", "value": "cleave", "entry": "test_lock_gun"}
	var deep := maxi(0, 3 - tier)
	db.chassis["test_frame"] = {"id": "test_frame", "name": "Test Frame", "designation": "TF-1", "codex": "", "flavour": "", "tier": tier,
		"maker": str(db.makers.keys()[0]), "hull": 20, "shield": 10, "armour": 0, "heat_max": 12, "movespeed": 3, "size": "medium",
		"hardpoints": 1, "module_slots": 0, "fixed": ["test_lock_gun", "test_lock_lure"], "loadout": ["test_plain_gun"], "passive": null,
		"branches": [
			{"id": "arc", "name": "Arc", "steps": [{"description": "Arc one.", "effects": [chain]}, {"description": "Arc two.", "effects": [chain]}].slice(0, deep)},
			{"id": "wide", "name": "Wide", "steps": [{"description": "Wide one.", "effects": [cleave]}, {"description": "Wide two.", "effects": [cleave]}].slice(0, deep)}]}
	return db


func _face(u: Unit, component: String) -> Face:
	for f in u.die.faces:
		if f.component == component:
			return f
	return null


func test_a_machine_arrives_at_its_chassis_tier_and_lifts_nothing() -> void:
	for t in [1, 2, 3]:
		var db := _db(t)
		var u := db.make_mech("test_frame", 1)
		assert_eq(u.tier, t, "a tier-%d chassis arrives at tier %d" % [t, t])
		assert_eq([u.hull_max, u.shield_max], [20, 10], "its stat line its chassis's")
		assert_eq(u.modifiers.filter(func(m) -> bool: return m.source == "tier").size(), 0, "no tier modifier")
		assert_eq(Effects.effective_face(u, _face(u, "test_lock_gun")).power, 3, "its locked gun as printed")


func test_each_tier_above_lifts_the_stat_line_and_the_locked_weapons() -> void:
	var db := _db(1)
	for t in [2, 3]:
		var u := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], [], t)
		var steps: int = t - 1
		assert_eq(u.tier, t, "bought up to tier %d" % t)
		assert_eq([u.hull_max, u.shield_max], [20 + 5 * steps, 10 + 3 * steps], "the lift's stat lines a step")
		assert_eq([u.hull, u.shield], [u.hull_max, u.shield_max], "and it starts whole on them")
		assert_eq(u.modifiers.filter(func(m) -> bool: return m.source == "tier").size(), steps, "a modifier sourced tier a step, never a write")
		assert_eq(int(u.base["hull"]), 20, "the base is the chassis's own")
		var gun := _face(u, "test_lock_gun")
		assert_eq(gun.power, 3, "the die keeps the locked gun as printed")
		assert_eq(Effects.effective_face(u, gun).power, 3 + 2 * steps, "the entry as spent at its machine's tier")
		assert_eq(Effects.effective_face(u, _face(u, "test_lock_lure")).power, 0, "a lure deals nothing at any tier")
		assert_eq(Effects.effective_face(u, _face(u, "test_plain_gun")).power, 3, "a hardpoint's piece is its own tier's, never lifted")
		var codex := db.codex_for_unit(u)
		var shown: Array = (codex["faces"] as Array).filter(func(f: Face) -> bool: return f.component == "test_lock_gun")
		assert_eq((shown[0] as Face).power, 3 + 2 * steps, "the codex shows the locked gun at its machine's tier")
		assert_true(str(codex["subtitle"]).contains("TIER %d" % t), "the plate says the tier: %s" % codex["subtitle"])
		for e in codex["effects"]:
			assert_false(str(e["name"]).begins_with("TIER"), "the lift is no reward row")


func test_each_pick_is_an_upgrade_and_a_tier_holds_no_more_picks_than_it_bought() -> void:
	var db := _db(1)
	assert_eq(db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["arc"]).tier, 2, "a pick is a tier bought")
	assert_eq(db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["arc", "wide"]).tier, 3, "two, two")
	var held := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["arc", "wide"], 2)
	assert_eq(held.tier, 2, "a tier named holds")
	assert_eq(held.branches, ["arc"] as Array[String], "and only the picks its tiers bought")
	assert_eq(db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], [], 9).tier, 3, "no tier above three")
	assert_eq(_db(2).make_mech("test_frame", 1, Vector2i.ZERO, null, [], [], 1).tier, 2, "and none below its chassis's")
	assert_eq(db.machine_tier("test_frame", ["arc"]), 2, "machine_tier reads the same")


func test_a_saved_fight_and_run_keep_the_tier() -> void:
	var db := _db(1)
	var u := db.make_mech("test_frame", 1, Vector2i.ZERO, null, [], ["arc"])
	var back := SaveGame._unit_from(SaveGame._unit_dict(u))
	assert_eq(back.tier, 2, "a saved fight's machine keeps its tier")
	assert_eq(back.hull_max, u.hull_max, "and its lift, the modifiers it carries")
	var c := Campaign.new(1)
	var m := Campaign.Machine.new()
	m.uid = 9
	m.chassis = "test_frame"
	m.tier = 2
	m.branches = ["arc"]
	c.roster.append(m)
	c.db = db
	var c2 := SaveGame.campaign_from_dict(SaveGame.campaign_to_dict(c))
	var got: Campaign.Machine = c2.roster.filter(func(x) -> bool: return x.uid == 9)[0]
	assert_eq([got.tier, got.branches], [2, ["arc"]], "a saved run's machine keeps its tier and its picks")


func test_the_validator_holds_the_lift() -> void:
	var db := _db(1)
	for e in db.validate():
		assert_false(e.begins_with("tier_lift"), "the lift validates: %s" % e)
	db.tier_lift = {"stats": {"luck": 1}, "locked_power": 1}
	assert_true(db.validate().any(func(e) -> bool: return str(e).begins_with("tier_lift: stats luck")), "a stat the engine lacks is refused")
	db.tier_lift = {"stats": {"hull": 1.5}, "locked_power": 0.5}
	var errs := db.validate()
	assert_true(errs.any(func(e) -> bool: return str(e).begins_with("tier_lift: stats hull")), "a part number is refused")
	assert_true(errs.any(func(e) -> bool: return str(e).begins_with("tier_lift: locked_power")), "on the locked power too")


func test_the_hangar_buys_a_machine_up_a_tier_with_its_pick_behind_the_convergence() -> void:
	var c := Campaign.new(1)
	c.db = _db(1)
	var m := c.add_machine("test_frame")
	assert_eq(c.machine_tier(m), 1, "it arrives at its chassis's tier, stock")
	c.salvage = Campaign.UPGRADE_PRICE * 3
	assert_eq(c.upgrade_error(m.uid, "arc"), "tier 2 opens with tier-2 rifts", "the Convergence is the gate")
	c.convergence = Campaign.TIER_EVERY
	assert_eq(c.upgrade_error(m.uid), "an upgrade takes a branch's pick", "its branch comes with it as the choice")
	assert_eq(c.db.upgrade_picks("test_frame", m.branches), ["arc", "wide"], "either direction's first step")
	assert_true(c.upgrade(m.uid, "arc"), "bought up to tier two")
	assert_eq([c.machine_tier(m), m.branches, c.salvage], [2, ["arc"], Campaign.UPGRADE_PRICE * 2], "its tier, its pick and the price")
	assert_false(c.upgrade(m.uid, "wide"), "tier three waits on tier-three rifts")
	c.convergence = Campaign.TIER_EVERY * 2
	c.salvage = Campaign.UPGRADE_PRICE - 1
	assert_eq(c.upgrade_error(m.uid, "wide"), "%d salvage" % Campaign.UPGRADE_PRICE, "and on the price")
	c.salvage = Campaign.UPGRADE_PRICE
	m.shop = 1
	assert_true(c.upgrade(m.uid, "wide"), "a wreck in the shop may be bought up, mixed")
	assert_eq(c.upgrade_error(m.uid, "arc"), "at the top tier", "and no further")
	var u: Unit = c.db.make_mech(m.chassis, m.uid, Vector2i.ZERO, m.loadout, [], m.branches.duplicate(), m.tier)
	assert_eq([u.tier, Array(u.branches), u.hull_max], [3, ["arc", "wide"], 20 + 5 * 2], "the battle fields it at its tier")


func test_a_chassis_with_no_branches_is_bought_up_without_a_pick() -> void:
	var c := Campaign.new(1)
	c.db = _db(1)
	c.db.chassis["test_frame"].erase("branches")
	var m := c.add_machine("test_frame")
	c.convergence = Campaign.TIER_EVERY
	c.salvage = Campaign.UPGRADE_PRICE
	assert_eq(c.upgrade_error(m.uid, "arc"), "test_frame has no branches", "no pick where there is no branch")
	assert_true(c.upgrade(m.uid), "the lift alone")
	assert_eq(c.machine_tier(m), 2, "at tier two")


func test_the_quick_campaign_buys_up_on_the_same_verb_at_no_price() -> void:
	var r := QuickRun.new(1)
	r.db = _db(1)
	var m := QuickRun.Machine.new()
	m.uid = 99
	m.chassis = "test_frame"
	r.roster.append(m)
	r.state = QuickRun.HANGAR
	r.battle = 0
	assert_eq(r.upgrade_error(99, "arc"), "tier 2 opens with tier-2 rifts", "the first battles' tier opens none")
	r.battle = QuickRun.TIER_EVERY
	assert_true(r.upgrade(99, "arc"), "the next battle at tier two opens it")
	assert_eq([r.machine_tier(m), m.branches], [2, ["arc"]], "its tier and its pick")

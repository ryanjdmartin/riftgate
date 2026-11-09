extends TestCase

## The refit pass's what-if (sim/refit.gd; docs/briefs/refit_pass.md, Ryan's direction of 9
## November): the model laid over a loaded ContentDB, the copy in memory and never the files.
## These hold what it promises the runners, on whatever content says: no id is named.


func _own() -> ContentDB:
	var db := ContentDB.new()   # its own copy: the what-if edits it
	db.load_dir(ContentDB.DIR)
	return db


func _kind(db: ContentDB, cid) -> String:
	return str(db.components.get(str(cid), {}).get("face", {}).get("kind", ""))


func test_a_spec_parses_its_parts_and_all_is_the_model_as_leaned() -> void:
	var all := Refit.parse("all")
	assert_true(bool(all["die"]) and bool(all["heat1"]), "all: the model's die and the basics at heat one")
	assert_eq(str(all["regen"]), "half", "all: half the gauge a round")
	var some := Refit.parse("regen=3, cooling=-1")
	assert_false(bool(some["die"]), "a part not named is off")
	assert_eq([str(some["regen"]), int(some["cooling"])], ["3", -1], "a flat regen and an offset as written")
	assert_eq(Refit.parse(""), {"die": false, "regen": "", "cooling": 0, "heat1": false, "barrier": "", "vents": ""}, "nothing asked, nothing set")
	assert_eq(str(Refit.parse("die,barrier=off")["barrier"]), "off", "the Barrier basic's rule as written")
	assert_eq(str(Refit.parse("all,vents=guns")["vents"]), "guns", "and what a vent's slot takes")


## The model's die: no chassis it fields stocks a shield or a vent, each that stocked one holds a
## Barrier or an Armoured piece in its place, every die keeps its size and its other entries where
## they stood, and the chassis whose kit reads a shield or a vent spent are left undealt.
func test_the_models_die_swaps_every_stock_shield_and_vent_and_leaves_the_rest() -> void:
	var before := _own()
	var db := _own()
	var notes := Refit.apply(db, Refit.parse("die"))
	assert_false(notes.is_empty(), "it says what it did")
	var barrier := Refit.basic_granting(db, Refit.BARRIER)
	var armoured := Refit.basic_granting(db, Refit.ARMOURED)
	assert_false(barrier.is_empty() or armoured.is_empty() or Refit.basic_gun(db).is_empty(), "content has a slottable Barrier, an Armoured piece and a basic gun")
	var back := Refit.sent_back(before)
	assert_false(back.is_empty(), "content has machines whose kit reads a shield or a vent spent")
	var swapped := 0
	for id in db.chassis.keys():
		var was: Array = before.chassis[id].get("loadout", [])
		var now: Array = db.chassis[id].get("loadout", [])
		if back.has(str(id)):
			assert_false(db.chassis_runnable(str(id)), "%s is back in design: not fielded under the model" % id)
			assert_true(before.chassis_runnable(str(id)), "%s is fielded as content stands" % id)
			assert_eq(now, was, "%s: its stock is left as it was" % id)
			continue
		assert_true(db.chassis_runnable(str(id)) == before.chassis_runnable(str(id)), "%s: fielded as before" % id)
		assert_eq(now.size(), was.size(), "%s: its die keeps its size" % id)
		var defended := false
		for i in range(mini(now.size(), was.size())):
			var k := _kind(before, was[i])
			if k == "shield" or k == "vent":
				swapped += 1
				assert_true(_kind(db, now[i]) in ["buff", "attack"], "%s: slot %d holds equipment or a gun where a %s stood" % [id, i, k])
			else:
				assert_eq(now[i], was[i], "%s: slot %d is left as it was" % [id, i])
			defended = defended or str(now[i]) == barrier or str(now[i]) == armoured
		for cid in now:
			assert_false(_kind(db, cid) in ["shield", "vent"], "%s stocks no shield and no vent" % id)
		var had: bool = was.any(func(cid) -> bool: return _kind(before, cid) in ["shield", "vent"])
		if had:
			assert_true(defended, "%s: a defensive basic stands where its shield or vent stood" % id)
			assert_true(int(db.chassis[id].get("cooling", 0)) >= 1 or not was.any(func(cid) -> bool: return _kind(before, cid) == "vent"), "%s: a chassis that stocked a vent cools one at least" % id)
	assert_true(swapped > 0, "content stocks shields and vents to swap")
	# The files' own copy is untouched: the what-if edits the copy it is handed.
	var fresh := _own()
	for id in fresh.chassis.keys():
		assert_eq(fresh.chassis[id].get("loadout", []), before.chassis[id].get("loadout", []), "%s: content as loaded is as it was" % id)


func test_the_regen_the_cooling_and_the_basics_heat_are_each_their_own_part() -> void:
	var before := _own()
	var db := _own()
	Refit.apply(db, Refit.parse("regen=half"))
	for id in db.chassis.keys():
		var shield := int(before.chassis[id].get("shield", 0))
		assert_eq(int(db.chassis[id].get("shield_regen", 0)), mini(9, int(ceil(shield / 2.0))), "%s: half its shield a round, rounded up" % id)
		assert_eq(db.chassis[id].get("loadout", []), before.chassis[id].get("loadout", []), "%s: the regen alone moves no die" % id)
	var some_id := str(db.chassis.keys()[0])
	var u := db.make_mech(some_id, 1)
	assert_eq(u.shield_regen, int(db.chassis[some_id]["shield_regen"]), "a machine made from it regains that much a round")
	var flat := _own()
	Refit.apply(flat, Refit.parse("regen=3,cooling=2"))
	for id in flat.chassis.keys():
		assert_eq(int(flat.chassis[id].get("shield_regen", 0)), 3, "%s: a flat three" % id)
		assert_eq(int(flat.chassis[id].get("cooling", 0)), int(before.chassis[id].get("cooling", 0)) + 2, "%s: two more cooling a round" % id)
	var warm := _own()
	Refit.apply(warm, Refit.parse("heat1"))
	var basics := 0
	for cid in warm.components.keys():
		var face = warm.components[cid].get("face", null)
		if warm.component_tier(str(cid)) == 0 and face is Dictionary and str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
			basics += 1
			assert_true(int(face.get("heat", 0)) >= 1, "%s, a basic gun, makes a heat at least" % cid)
		elif face is Dictionary:
			assert_eq(int(face.get("heat", 0)), int(before.components[cid].get("face", {}).get("heat", 0)), "%s is no basic gun: its heat is left" % cid)
	assert_true(basics > 0, "content has basic guns")


## The model as leaned plays: a team of the first chassis it fields fights a pack to its end on
## the model's dice, its shields regaining each round and no vent or shield spent.
func test_a_fight_plays_on_the_models_dice() -> void:
	var db := _own()
	Refit.apply(db, Refit.parse("all"))
	var team: Array = []
	for id in db.chassis.keys():
		if db.chassis_runnable(str(id)) and team.size() < 3:
			team.append(str(id))
	var sk := Skirmish.new(5)
	var uid := 0
	for cid in team:
		uid += 1
		sk.add_mech(db.make_mech(cid, uid))
	var fid := str(db.factions.keys()[0])
	var spawn: Array = db.spawn_table(fid, 1)
	var foes: Array = []
	for n in range(4):
		foes.append(db.make_foe(str(spawn[0][0])))
	sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
	sk.add_foes(foes)
	sk.begin()
	var pol := Policy.make(Policy.GREEDY, 5)
	var outcome := pol.play(sk)
	assert_true(outcome == Skirmish.Outcome.VICTORY or outcome == Skirmish.Outcome.DEFEAT or pol.stalled, "the fight runs to an end")
	for kind in pol.spends.keys():
		var c: Dictionary = db.components.get(str(kind), {})
		assert_false(str(c.get("face", {}).get("kind", "")) in ["shield", "vent"], "%s: no shield and no vent is spent" % kind)
	assert_true(sk.destroyed == 0, "and nothing is destroyed, the injury rule off")


## The Barrier basic's price is a question the reads ask (a free one on every stock die is spent
## every round it is rolled): with none among the basics no chassis the model fields stocks a
## Barrier it did not stock before, and its slot holds the Armoured piece or a gun; with a
## cooldown or a heat the piece itself carries the price.
func test_the_barrier_basics_rule_is_a_part_of_the_die() -> void:
	var before := _own()
	var barrier := Refit.basic_granting(before, Refit.BARRIER)
	var off := _own()
	Refit.apply(off, Refit.parse("die,barrier=off"))
	var back := Refit.sent_back(before)
	for id in off.chassis.keys():
		if back.has(str(id)):
			continue   # back in design: its stock is left as it was
		var was: Array = before.chassis[id].get("loadout", [])
		var now: Array = off.chassis[id].get("loadout", [])
		assert_eq(now.count(barrier), was.count(barrier), "%s: no Barrier it did not stock already" % id)
		for cid in now:
			assert_false(_kind(off, cid) in ["shield", "vent"], "%s stocks no shield and no vent" % id)
	var dark := _own()
	Refit.apply(dark, Refit.parse("die,barrier=cooldown"))
	assert_eq(int(dark.components[barrier]["face"].get("cooldown", 0)), 2, "the next round dark once spent (a cooldown counts the round of the spend)")
	var hot := _own()
	Refit.apply(hot, Refit.parse("die,barrier=heat3"))
	assert_eq(int(hot.components[barrier]["face"].get("heat", 0)), 3, "three heat a spend")
	assert_eq(int(before.components[barrier]["face"].get("heat", 0)), 0, "and content's own makes none")
	# The audit's own deal (vents=guns): a vent's slot takes a gun, so the die holds a defensive
	# basic only where a shield stood.
	var lean := _own()
	Refit.apply(lean, Refit.parse("die,vents=guns"))
	var armoured := Refit.basic_granting(before, Refit.ARMOURED)
	var guns := 0
	for id in lean.chassis.keys():
		if back.has(str(id)):
			continue
		var was: Array = before.chassis[id].get("loadout", [])
		var now: Array = lean.chassis[id].get("loadout", [])
		assert_eq(now.size(), was.size(), "%s: every slot keeps its place" % id)
		for i in range(was.size()):
			var kind := _kind(before, was[i])
			if kind == "vent":
				assert_true(_kind(lean, now[i]) == "attack" and int(lean.components[now[i]]["face"].get("power", 0)) > 0, "%s: a gun where its vent stood" % id)
				guns += 1
			elif kind != "shield":
				assert_eq(now[i], was[i], "%s: a piece that is no shield and no vent stays" % id)
			else:
				assert_true(now[i] == barrier or now[i] == armoured or _kind(lean, now[i]) == "attack", "%s: a defensive basic (or a gun, the die holding both) where its shield stood" % id)
	assert_true(guns > 0, "some stock die held a vent")
	# A Ward in its place: the die's Barrier slots hold the Ward piece, and no Barrier is added.
	var ward := Refit.basic_granting(before, Refit.WARD)
	if ward.is_empty():
		return
	var warded := _own()
	Refit.apply(warded, Refit.parse("die,barrier=ward"))
	var model := _own()
	Refit.apply(model, Refit.parse("die"))
	var held := 0
	for id in warded.chassis.keys():
		if back.has(str(id)):
			continue
		var plain: Array = model.chassis[id].get("loadout", [])
		var now: Array = warded.chassis[id].get("loadout", [])
		var was: Array = before.chassis[id].get("loadout", [])
		assert_eq(now.count(barrier), was.count(barrier), "%s: no Barrier it did not stock already" % id)
		assert_eq(now.count(ward) - was.count(ward), plain.count(barrier) - was.count(barrier), "%s: a Ward wherever the model's die put a Barrier" % id)
		held += now.count(ward)
	assert_true(held > 0, "some stock die holds the Ward")


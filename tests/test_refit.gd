extends TestCase

## The refit pass's model as content holds it (docs/briefs/refit_pass.md; landed 10 November on
## Ryan's "The re-deal with regen and heat ... seems like the correct way to go ... start with the
## minimal swaps"), and the what-ifs sim/refit.gd still lays over a loaded ContentDB, the copy in
## memory and never the files. These hold what the model promises on whatever content says: no id
## is named.


func _own() -> ContentDB:
	var db := ContentDB.new()   # its own copy: the what-if edits it
	db.load_dir(ContentDB.DIR)
	return db


func _kind(db: ContentDB, cid) -> String:
	return str(db.components.get(str(cid), {}).get("face", {}).get("kind", ""))


## Shields and vents left the die: no chassis stocks one, no slottable one is dealt (each is a
## planned draft until the component pass makes it what the audit says or removes it), and the
## two defensive basics a stock die may hold stand at tier zero, the Barrier's and the Armoured.
func test_no_stock_die_holds_a_shield_or_a_vent_and_none_is_dealt() -> void:
	var db := ContentDB.load_default()
	var defensive := 0
	for id in db.chassis.keys():
		for cid in db.chassis[id].get("loadout", []):
			assert_false(_kind(db, cid) in ["shield", "vent"], "%s stocks %s, a %s: shields and vents left the die" % [id, cid, _kind(db, cid)])
			assert_true(str(db.components[cid].get("status", "implemented")) != "planned", "%s stocks %s, a piece nothing deals" % [id, cid])
			var face: Dictionary = db.components[cid].get("face", {})
			if str(face.get("kind", "")) == "buff" and str(face.get("status", "")) in ["barrier", "braced"]:
				defensive += 1
	assert_true(defensive > 0, "the stock dice carry the defensive basics where a shield stood")
	for cid in db.components.keys():
		if _kind(db, cid) in ["shield", "vent"] and db.component_tier(str(cid)) != ContentDB.NO_TIER:
			assert_eq(str(db.components[cid].get("status", "implemented")), "planned", "%s is slottable and a %s: undealt since the model landed" % [cid, _kind(db, cid)])
	for status in ["barrier", "braced"]:
		var basic := Refit.basic_granting(db, status)
		assert_true(not basic.is_empty(), "content has a slottable piece granting %s" % status)
		assert_eq(db.component_tier(basic), 0, "and it is a basic, tier zero, so a tier-one chassis may stock it")
	for t in [0, 1, 2, 3]:
		for cid in db.loot_pool(t):
			assert_false(_kind(db, cid) in ["shield", "vent"], "no loot pool deals %s" % cid)


## Every chassis regains its own shield regen a round, one to three, the larger on the smaller
## gauge (Ryan, 10 November: "a smaller shield that regens fast, a fatter shield that regens
## slow, some variation of the middle"); every chassis cools; and every basic weapon makes heat.
func test_every_chassis_regains_its_own_regen_cools_and_the_basics_make_heat() -> void:
	var db := ContentDB.load_default()
	var by_regen := {}
	for id in db.chassis.keys():
		var c: Dictionary = db.chassis[id]
		var regen := int(c.get("shield_regen", 0))
		assert_true(regen >= 1 and regen <= 3, "%s regains %d a round: one to three" % [id, regen])
		if not by_regen.has(regen):
			by_regen[regen] = []
		by_regen[regen].append(int(c.get("shield", 0)))
		var u := db.make_mech(str(id), 1)
		if db.chassis_runnable(str(id)):
			# A machine whose pass releases its heat has that as its way down (the boiler's rule).
			assert_true(int(c.get("cooling", 0)) >= 1 or not Effects.pass_release(u).is_empty(), "%s cools: with no vent on the die, cooling or a release is its way down" % id)
		assert_eq(u.shield_regen, regen, "%s: the machine carries its chassis's regen" % id)
	assert_eq(by_regen.size(), 3, "all three speeds are in use")
	var mean := func(a: Array) -> float:
		var t := 0.0
		for x in a:
			t += float(x)
		return t / float(a.size())
	assert_true(mean.call(by_regen[3]) < mean.call(by_regen[2]) and mean.call(by_regen[2]) < mean.call(by_regen[1]), "the faster the regen, the smaller the gauge on average (%.1f, %.1f, %.1f)" % [mean.call(by_regen[3]), mean.call(by_regen[2]), mean.call(by_regen[1])])
	for cid in db.components.keys():
		var face: Dictionary = db.components[cid].get("face", {})
		if db.component_tier(str(cid)) == 0 and str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
			assert_true(int(face.get("heat", 0)) >= 1, "%s is a basic weapon and makes heat" % cid)


## The machines back in design are undealt, by a status of their own on the chassis: the tender
## and the runners skip them, and their kits still build, so their sessions and their tests have
## them. A passive that reads a shield or a vent spent has nothing left to read: every chassis
## carrying one is among them. The Polar Bear's seal reads equipment since 11 November, so it is
## dealt again.
func test_the_machines_back_in_design_are_undealt_and_still_build() -> void:
	var db := ContentDB.load_default()
	var back: Array = []
	for id in db.chassis.keys():
		if str(db.chassis[id].get("status", "implemented")) == "planned":
			back.append(str(id))
			assert_false(db.chassis_runnable(str(id)), "%s is back in design: nothing deals it" % id)
			var u := db.make_mech(str(id), 1)
			assert_true(u != null and u.die != null and u.die.faces.size() > 0, "%s still builds, kit and all" % id)
	assert_true(back.size() > 0, "the refit pass sent machines back")
	for id in db.chassis.keys():
		var dead := false
		var p = db.chassis[id].get("passive", null)
		if p is Dictionary:
			for e in p.get("effects", []):
				if str(e.get("trigger", "")) == "on_shield_granted":
					dead = true
		for cid in db.chassis[id].get("fixed", []):
			var face: Dictionary = db.components.get(cid, {}).get("face", {})
			if str(face.get("kind", "")) == "shield" or (str(face.get("kind", "")) == "vent" and int(face.get("reloads_ammo", 0)) <= 0):
				dead = true
		if dead:
			assert_true(back.has(str(id)), "%s reads a shield or a vent the die no longer has: back in design" % id)
	var copy := _own()
	copy.chassis[back[0]].erase("status")
	assert_true(copy.chassis_runnable(back[0]), "and its session hands it back by taking the status off")
	copy.chassis[back[0]]["status"] = "elsewhere"
	var refused := false
	for e in copy.validate():
		if e.contains("status is one of"):
			refused = true
	assert_true(refused, "a status content does not know is refused")


func test_a_spec_parses_its_parts() -> void:
	var s := Refit.parse("regen=2,cooling=-1,hotter=2,barrier=cooldown")
	assert_eq([str(s["regen"]), int(s["cooling"]), int(s["hotter"]), str(s["barrier"])], ["2", -1, 2, "cooldown"], "each part is its own")
	var none := Refit.parse("")
	assert_eq([str(none["regen"]), int(none["cooling"]), int(none["hotter"]), str(none["barrier"])], ["", 0, 0, ""], "nothing asked, nothing set")
	assert_true(Refit.apply(_own(), none).is_empty(), "and nothing changed")


## The what-ifs left over the landed model: a flat regen in place of each chassis's own, an
## offset on the cooling, every weapon hotter, and a price on the Barrier basic.
func test_the_what_ifs_move_the_regen_the_cooling_the_heat_and_the_barriers_price() -> void:
	var before := ContentDB.load_default()
	var db := _own()
	var notes := Refit.apply(db, Refit.parse("regen=0"))
	assert_eq(notes.size(), 1, "one line for the one change")
	for id in db.chassis.keys():
		assert_eq(int(db.chassis[id].get("shield_regen", -1)), 0, "%s: a flat nought in place of its own" % id)
	db = _own()
	Refit.apply(db, Refit.parse("regen=half"))
	for id in db.chassis.keys():
		assert_eq(int(db.chassis[id]["shield_regen"]), int(ceil(float(int(db.chassis[id]["shield"])) / 2.0)), "%s: half its gauge, rounded up" % id)
	db = _own()
	Refit.apply(db, Refit.parse("cooling=1"))
	var cooled := 0
	for id in db.chassis.keys():
		var own := int(before.chassis[id].get("cooling", 0))
		if own > 0:
			cooled += 1
			assert_eq(int(db.chassis[id].get("cooling", 0)), own + 1, "%s cools one more" % id)
		else:
			assert_eq(int(db.chassis[id].get("cooling", 0)), 0, "%s cools nothing by its rule, and no offset moves it" % id)
	assert_true(cooled > 0, "the chassis that cool cooled more")
	db = _own()
	Refit.apply(db, Refit.parse("hotter=2"))
	var hot := 0
	for cid in db.components.keys():
		var face: Dictionary = db.components[cid].get("face", {})
		var was: Dictionary = before.components[cid].get("face", {})
		if str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
			assert_eq(int(face.get("heat", 0)), int(was.get("heat", 0)) + 2, "%s runs two hotter" % cid)
			hot += 1
		else:
			assert_eq(int(face.get("heat", 0)), int(was.get("heat", 0)), "%s is no weapon and runs as it did" % cid)
	assert_true(hot > 0, "the weapons ran hotter")
	# A passive that rewrites its machine's weapons into one shot: the shot's heat moves with them.
	for id in db.chassis.keys():
		var effects: Array = (db.chassis[id].get("passive", {}) as Dictionary).get("effects", [])
		var were: Array = (before.chassis[id].get("passive", {}) as Dictionary).get("effects", [])
		for k in range(effects.size()):
			if str(effects[k].get("effect", "")) == "rewrite_weapon" and effects[k].has("heat"):
				assert_eq(int(effects[k]["heat"]), int(were[k]["heat"]) + 2, "%s's rewritten shot runs two hotter with the weapons" % id)
	var barrier := Refit.basic_granting(before, "barrier")
	db = _own()
	Refit.apply(db, Refit.parse("barrier=cooldown"))
	assert_eq(int(db.components[barrier]["face"].get("cooldown", 0)), 1, "the Barrier basic sits out the round after it is spent, a cooldown's own count")
	Refit.apply(db, Refit.parse("barrier=cooldown2"))
	assert_eq(int(db.components[barrier]["face"].get("cooldown", 0)), 2, "or as many rounds as asked")
	Refit.apply(db, Refit.parse("barrier=cooldown0"))
	assert_true(not (db.components[barrier]["face"] as Dictionary).has("cooldown"), "and none at all, whatever content gives it")
	db = _own()
	Refit.apply(db, Refit.parse("barrier=heat3"))
	assert_eq(int(db.components[barrier]["face"].get("heat", 0)), 3, "or it costs heat")
	assert_eq(int(before.components[barrier]["face"].get("heat", 0)), 0, "and the game's own copy is untouched")


func test_a_fight_plays_on_the_models_dice() -> void:
	var db := ContentDB.load_default()
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
	var shields: Array = []
	for ms in sk.mechs:
		shields.append(ms.unit.shield)
	var pol := Policy.make(Policy.GREEDY, 5)
	var outcome := pol.play(sk)
	assert_true(outcome == Skirmish.Outcome.VICTORY or outcome == Skirmish.Outcome.DEFEAT or pol.stalled, "the fight runs to an end")
	for kind in pol.spends.keys():
		var c: Dictionary = db.components.get(str(kind), {})
		assert_false(str(c.get("face", {}).get("kind", "")) in ["shield", "vent"], "%s: no shield and no vent is spent" % kind)
	assert_true(sk.destroyed == 0, "and nothing is destroyed, the injury rule off")

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
		assert_true(db.is_basic(basic), "and it is a basic, a tier-one piece every run starts with")
	for t in [1, 2, 3]:
		for cid in db.loot_pool(t):
			assert_false(_kind(db, cid) in ["shield", "vent"], "no loot pool deals %s" % cid)


## No chassis regains shield or cools by itself (the reboot, folded in 15 November: the regen of
## one to three a chassis and the cooling of the model went with it), and every basic weapon
## makes heat.
func test_no_chassis_regains_or_cools_of_its_own_and_the_basics_make_heat() -> void:
	var db := ContentDB.load_default()
	for id in db.chassis.keys():
		var c: Dictionary = db.chassis[id]
		assert_false(c.has("shield_regen") or c.has("cooling"), "%s names no regen and no cooling" % id)
		var u := db.make_mech(str(id), 1)
		assert_eq([u.shield_regen, u.cooling], [0, 0], "%s: the machine carries none as stocked" % id)
	for cid in db.components.keys():
		var face: Dictionary = db.components[cid].get("face", {})
		if db.is_basic(str(cid)) and str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
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
	# Handed back, a machine whose kit is built runs; one whose kit is a draft too (a new machine
	# landed planned, its passive and locked piece drafts with it) waits on its kit as well.
	var copy := _own()
	var built := ""
	for id in back:
		var drafted := false
		var p = copy.chassis[id].get("passive", null)
		if p is Dictionary and str(p.get("status", "implemented")) == "planned":
			drafted = true
		for cid in copy.chassis[id].get("fixed", []):
			if str(copy.components.get(cid, {}).get("status", "implemented")) == "planned":
				drafted = true
		if not drafted and built.is_empty():
			built = str(id)
	assert_false(built.is_empty(), "a machine back in design has a kit that runs")
	copy.chassis[built].erase("status")
	assert_true(copy.chassis_runnable(built), "and its session hands it back by taking the status off")
	copy.chassis[built]["status"] = "elsewhere"
	var refused := false
	for e in copy.validate():
		if e.contains("status is one of"):
			refused = true
	assert_true(refused, "a status content does not know is refused")


func test_a_spec_parses_its_parts() -> void:
	assert_eq(str(Refit.parse("barrier=none")["barrier"]), "none", "the Barrier basic off the stock dice parses as its rule")
	var s := Refit.parse("hotter=2,barrier=cooldown")
	assert_eq([int(s["hotter"]), str(s["barrier"])], [2, "cooldown"], "each part is its own")
	assert_false(s.has("regen") or s.has("cooling"), "the regen's and the cooling's parts left with the chassis's own (15 November)")
	var none := Refit.parse("")
	assert_eq([int(none["hotter"]), str(none["barrier"])], [0, ""], "nothing asked, nothing set")
	assert_eq(int(none["top"]), 0, "the top basic's part with them")
	assert_false(none.has("basics") or none.has("breach"), "the vanilla's point and breach's cut are content since 15 November, their parts gone")
	assert_true(Refit.apply(_own(), none).is_empty(), "and nothing changed")
	var guns := Refit.parse("top=2,hotter=-2")
	assert_eq([int(guns["top"]), int(guns["hotter"])], [2, -2], "the top basic's heat and a cooler price each parse")


## The top basic's what-if (Ryan, 14 November: the gun that deals one more paid in heat): more
## heat on the basic guns that deal more than the plainest alone, nothing else moved. The pieces
## are found by what they are, tier zero and a weapon that deals damage, never by id. The
## vanilla's own point is content since 15 November: the plainest basic gun deals 3.
func test_the_top_basic_runs_hotter_and_the_plain_basics_deal_three() -> void:
	var db := _own()
	var guns := Refit.basic_guns(db)
	assert_true(guns.size() >= 2, "content has basic guns to read: %s" % str(guns))
	var before := {}
	for cid in db.components.keys():
		before[cid] = (db.components[cid].get("face", {}) as Dictionary).duplicate(true)
	var plain := 99
	for cid in guns:
		assert_true(db.is_basic(cid), "%s is a basic" % cid)
		plain = mini(plain, int(before[cid]["power"]))
	assert_eq(plain, 3, "the vanilla is 3 (Ryan, 15 November: \"3 against 5 or 3 against 4 as the options\")")
	var notes := Refit.apply(db, Refit.parse("top=2"))
	assert_eq(notes.size(), 1, "one line says what moved: %s" % str(notes))
	var hotter := 0
	for cid in db.components.keys():
		var face: Dictionary = db.components[cid].get("face", {})
		if guns.has(str(cid)):
			var over := int(before[cid]["power"]) > plain
			assert_eq(int(face.get("heat", 0)), int(before[cid].get("heat", 0)) + (2 if over else 0), "%s: %s" % [cid, "over the plainest, two hotter" if over else "the plainest, its heat kept"])
			assert_eq(int(face["power"]), int(before[cid]["power"]), "its damage kept")
			hotter += 1 if over else 0
		else:
			assert_eq(face, before[cid], "%s, no basic gun, is as content has it" % cid)
	assert_true(hotter >= 1 and hotter < guns.size(), "some basic gun deals more than the plainest, and not every one (%d of %d)" % [hotter, guns.size()])
	var db2 := _own()
	Refit.apply(db2, Refit.parse("top=2,hotter=-2"))
	for cid in guns:
		var face: Dictionary = db2.components[cid]["face"]
		var over := int(before[cid]["power"]) > plain
		assert_eq(int(face.get("heat", 0)), maxi(0, int(before[cid].get("heat", 0)) - 2) + (2 if over else 0), "the two together: two cooler with every weapon, the top basic's price on top")


## The standard foe's what-if (Ryan, 15 November: "Ok let's go 3 against 5 or 3 against 4 as
## the options"): tier one's rank and file a hit point up, found by what they are, every foe a
## tier-one formation fields that is no massive, no elite and no boss, and what such a foe
## leaves as it falls. Every other foe is as content has it, and a foe made from the content
## after it carries the point.
func test_tier_ones_rank_and_file_gain_a_hit_point_and_no_other_foe_moves() -> void:
	var db := _own()
	var rank := Refit.rank_and_file(db)
	assert_true(rank.size() >= 4, "content has a rank and file to read: %s" % str(rank))
	var before := {}
	for fid in db.foes.keys():
		before[fid] = int(db.foes[fid].get("hp", 0))
	for fid in rank:
		assert_true(int(db.foes[fid].get("size", 1)) < 2 and not db.is_elite(fid) and not db.is_boss(fid), "%s is no massive, no elite and no boss" % fid)
	var fielded := 0
	for faction in db.factions.keys():
		for c in db.compositions(str(faction), 1, "formation"):
			for member in c["members"]:
				var fid := str(member[0])
				if int(db.foes[fid].get("size", 1)) >= 2:
					assert_false(rank.has(fid), "%s, a massive foe, is not rank and file" % fid)
				else:
					fielded += 1
					assert_true(rank.has(fid), "%s stands in a tier-one formation: rank and file" % fid)
	assert_true(fielded > 0, "tier one's formations field them")
	assert_eq(int(Refit.parse("foehp=1")["foehp"]), 1, "the part parses")
	var notes := Refit.apply(db, Refit.parse("foehp=1"))
	assert_eq(notes.size(), 1, "one line says what moved: %s" % str(notes))
	for fid in db.foes.keys():
		var up := 1 if rank.has(str(fid)) else 0
		assert_eq(int(db.foes[fid].get("hp", 0)), int(before[fid]) + up, "%s: %s" % [fid, "a hit point more" if up == 1 else "as content has it"])
	var first := str(rank[0])
	assert_eq(db.make_foe(first).hp_max, int(before[first]) + 1, "a foe made after the what-if stands a point taller")
	var db2 := _own()
	Refit.apply(db2, Refit.parse("foehp=-9"))
	for fid in rank:
		assert_eq(int(db2.foes[fid]["hp"]), 1, "%s never falls under one hit point" % fid)
	assert_eq(Refit.apply(_own(), Refit.parse("")), [], "and no part moves nothing")


## Breach is cut on both sides (Ryan, 15 November: "Sure, let's cut breach"): no foe's move
## carries the word, and none of ours does: a piece that ignores armour says so as a rule
## written on it.
func test_no_move_and_no_piece_carries_breach() -> void:
	var db := _own()
	for fid in db.foes.keys():
		for a in db.foes[fid].get("actions", []):
			assert_false(Array(a.get("keywords", [])).has("breach"), "%s's %s is a plain blow" % [fid, str(a.get("id", ""))])
	var written := 0
	for cid in db.components.keys():
		var face: Dictionary = db.components[cid].get("face", {})
		assert_false(Array(face.get("keywords", [])).has("breach"), "%s carries no breach" % cid)
		written += 1 if bool(face.get("ignores_armour", false)) else 0
	assert_true(written >= 1, "and content has a piece that ignores armour by its own rule (%d)" % written)
	assert_false(Foe.ATTACK_KEYWORDS.has("breach"), "the engine knows no such rider")


## The what-ifs left over the landed model: a flat regen in place of each chassis's own, an
## offset on the cooling, every weapon hotter, and a price on the Barrier basic.
func test_the_what_ifs_move_the_heat_and_the_barriers_price() -> void:
	var before := ContentDB.load_default()
	var db := _own()
	var notes := Refit.apply(db, Refit.parse("hotter=2"))
	assert_eq(notes.size(), 1, "one line for the one change")
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
	# Or it leaves the stock dice (its place is open since 12 November), the Armoured basic in its
	# slot on every die that held it, the piece itself as it was.
	db = _own()
	var jack := Refit.basic_granting(before, "braced")
	var held := 0
	for id in before.chassis.keys():
		held += (before.chassis[id].get("loadout", []) as Array).count(barrier)
	assert_true(held > 0, "content stocks the Barrier basic on some die")
	var said := Refit.apply(db, Refit.parse("barrier=none"))
	assert_true(said.size() == 1 and said[0].contains("on %d" % held), "the what-if says how many dice it moved")
	for id in db.chassis.keys():
		var now: Array = db.chassis[id].get("loadout", [])
		var was: Array = before.chassis[id].get("loadout", [])
		assert_eq(now.count(barrier), 0, "%s stocks no Barrier basic" % id)
		assert_eq(now.count(jack), was.count(jack) + was.count(barrier), "%s holds the Armoured basic in each such slot" % id)
		assert_eq(now.size(), was.size(), "%s's die is as long as it was" % id)
	assert_eq(str(db.components[barrier]["face"].get("status", "")), "barrier", "the piece itself is untouched")
	assert_true((before.chassis.values() as Array).any(func(c) -> bool: return (c.get("loadout", []) as Array).has(barrier)), "and the game's own copy still stocks it")


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
	assert_true(sk.destroyed == 0, "and nothing is destroyed: no foe's blow carries Destroy")

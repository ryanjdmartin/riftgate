extends TestCase

## The caches lying on the field (the bible's loot rows; Ryan, 7 November: "have all the loot on
## the field round 1"; 8 November: "place the loot, farther away it is means more likely to spawn a
## higher tier cache, and don't build any seam interaction yet"): seeded with the map short of the
## wall, the better kinds likelier the farther from the wall, claimed by a machine standing on one
## as the turn ends or as the battle is won, its contents its kind's and the battle tier's, banked
## by the campaign as the kills are, kept by a save, and read on a tap. Content-agnostic: the kinds
## and their numbers are the content's, every id read from it.

func _team() -> Array:
	var db := ContentDB.load_default()
	var out: Array = []
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		out.append(db.make_mech(id))
	return out


func _battle(seed_value: int = 3) -> Battle:
	var b := Battle.new(seed_value)
	b.setup(_team(), "marsh", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
	quiet_start(b)
	return b


## A hex a machine's move reaches, with nothing on it and room for a cache.
func _reachable(b: Battle, m: Unit) -> Vector2i:
	for h in b.destinations_for(m).keys():
		if b.field.cache_at(h).is_empty() and b.field.unit_at(h) == null:
			return h
	return Battlefield.NO_HEX


func test_the_caches_lie_on_the_field_from_the_start_short_of_the_wall() -> void:
	var db := ContentDB.load_default()
	var per := int(db.loot_rules["per_battle"])
	assert_true(per > 0 and db.loot_kinds().size() >= 2, "the content seeds caches of several kinds")
	var seen_kinds := {}
	var differs := false
	var first: Array = []
	for sd in [3, 4, 5, 6, 7, 8]:
		var b := Battle.new(sd)
		b.setup(_team(), "marsh", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
		var f := b.field
		assert_true(f.caches.size() > 0 and f.caches.size() <= per, "seed %d: the field holds its caches from the first turn (%d)" % [sd, f.caches.size()])
		var lo := int(db.loot_rules["rift_gap"])
		var hi := f.apron_row() - int(db.loot_rules["wall_gap"])
		for c in f.caches:
			var h: Vector2i = c["pos"]
			var row := Hex.axial_to_offset(h).y
			assert_true(row >= lo and row <= hi, "seed %d: a cache in the rows %d to %d, never that close to the wall (row %d)" % [sd, lo, hi, row])
			assert_true(f.map.has(h) and not f.map.is_structure(h), "on the field")
			assert_eq(BattleMap.step_cost(int(f.map.terrain[h]), []), BattleMap.STEP, "on open ground a machine can end a move on")
			assert_true(f.unit_at(h) == null, "on no unit")
			assert_false(db.loot_kind_of_tier(int(c["tier"])).is_empty(), "of one of the content's kinds")
			assert_false(c.has("flattened"), "the seam does nothing to a cache (8 November)")
			seen_kinds[int(c["tier"])] = true
			for o in f.caches:
				if o != c:
					assert_true(Hex.distance(o["pos"], h) > 1, "none beside another")
		var again := Battle.new(sd)
		again.setup(_team(), "marsh", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
		assert_eq(again.field.caches, f.caches, "seed %d: the same caches from the same seed" % sd)
		if first.is_empty():
			first = f.caches
		elif f.caches != first:
			differs = true
	assert_true(differs, "and other seeds lay others")
	assert_true(seen_kinds.size() >= 2, "more than one kind comes up")


## A cache's kind follows its depth (Ryan, 8 November): each kind's weight is read between its
## wall's-end and rift's-end values by the row, so a kind weighted nothing at the wall never lies in
## the nearest row, and over many battles the better kinds lie deeper.
func test_a_caches_kind_is_likelier_the_better_the_farther_from_the_wall() -> void:
	var db := ContentDB.load_default()
	var kinds := db.loot_kinds()
	var top := str(kinds[kinds.size() - 1])
	var low := str(kinds[0])
	assert_eq(float(db.loot[top]["weight"][0]), 0.0, "the content's top kind is weighted nothing at the wall's end")
	assert_true(float(db.loot[low]["weight"][0]) > float(db.loot[low]["weight"][1]), "and its lowest kind leans to the wall")
	var rows := {}   # tier -> [rows]
	var last := 0
	for sd in range(1, 25):
		var b := Battle.new(sd)
		b.setup(_team(), "marsh", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
		last = b.field.apron_row() - int(db.loot_rules["wall_gap"])
		for c in b.field.caches:
			var row := Hex.axial_to_offset(c["pos"]).y
			if int(c["tier"]) == int(db.loot[top]["tier"]):
				assert_true(row < last, "seed %d: the top kind never lies in the row nearest the wall" % sd)
			if not rows.has(int(c["tier"])):
				rows[int(c["tier"])] = []
			(rows[int(c["tier"])] as Array).append(row)
	assert_true(rows.has(int(db.loot[top]["tier"])) and rows.has(int(db.loot[low]["tier"])), "both kinds come up over 24 battles")
	var mean := func(xs: Array) -> float:
		var t := 0.0
		for x in xs:
			t += float(x)
		return t / maxf(1.0, float(xs.size()))
	assert_true(mean.call(rows[int(db.loot[top]["tier"])]) < mean.call(rows[int(db.loot[low]["tier"])]), "the top kind lies deeper (a lower row) than the lowest, on the whole")


## A battle won mid-turn (the boss's fall) banks the last turn's fetch (8 November): a machine
## standing on a cache as the boss dies claims it as it would at the turn's end.
func test_a_cache_under_a_machine_is_claimed_as_the_battle_is_won() -> void:
	var b := _battle()
	b.field.caches.clear()
	var m: Unit = b.mechs()[0]
	b.field.caches.append({"id": 7, "tier": 1, "pos": m.pos})
	b.field.units.erase(b.boss)   # the boss's fight won, as finish_skirmish leaves it
	assert_true(b._check_outcome(), "the battle is decided")
	assert_eq(b.outcome, Battle.Outcome.VICTORY, "won")
	assert_eq(b.loot.size(), 1, "the cache under the machine claimed with the win")
	assert_true(b.field.caches.is_empty(), "and off the field")


func test_a_machine_standing_on_a_cache_claims_it_as_the_turn_ends() -> void:
	var b := _battle()
	var db := ContentDB.load_default()
	b.field.caches.clear()
	var m: Unit = b.mechs()[0]
	var h := _reachable(b, m)
	assert_ne(h, Battlefield.NO_HEX, "a hex its move reaches")
	var kind := db.loot_kind_of_tier(1)
	b.field.caches.append({"id": 7, "tier": 1, "pos": h})
	assert_false(b.move_to(m, h).is_empty(), "the machine moves onto it")
	assert_false(b.field.cache_at(h).is_empty(), "the cache waits for the turn's end: an undo never shows what it holds")
	assert_true(b.loot.is_empty(), "nothing claimed yet")
	b.undo()
	assert_ne(m.pos, h, "an undo takes the move back")
	assert_false(b.field.cache_at(h).is_empty(), "and the cache is still there")
	b.move_to(m, h)
	var want := b.open_cache(b.field.cache_at(h))
	b.forced = []   # no hunter's catch in the way of the turn's end
	b.end_turn()
	assert_true(b.field.cache_at(h).is_empty(), "claimed as the turn ends: off the field")
	assert_eq(b.loot.size(), 1, "the battle holds what it held")
	var got: Dictionary = b.loot[0]
	assert_eq(str(got["kind"]), kind, "the kind it stood as")
	assert_eq(int(got["by"]), m.id, "claimed by the machine on it")
	var e: Dictionary = db.loot[kind]
	assert_true(int(got["salvage"]) >= int(e["salvage"][0]) and int(got["salvage"]) <= int(e["salvage"][1]), "its kind's salvage")
	var pool := db.loot_pool(b.tier + 1)
	assert_eq((got["components"] as Array).size(), int(e["components"]) if not pool.is_empty() else 0, "its kind's count of components")
	for cid in got["components"]:
		assert_true(pool.has(str(cid)), "of the battle's tier")
	assert_eq(got["salvage"], want["salvage"], "what it holds is drawn from the battle's seed and the cache, the same whenever it is opened")
	assert_eq(got["components"], want["components"], "the same components")
	assert_true(b.field.log.any(func(l) -> bool: return str(l).contains("claims a %s" % str(e["name"]))), "the log says who claimed what")
	b.field.caches.append({"id": 8, "tier": 1, "pos": Hex.offset_to_axial(0, 1)})
	b.forced = []
	b.end_turn()
	assert_eq(b.loot.size(), 1, "a cache nobody stands on stays where it lies")


func test_a_caches_blueprint_is_one_the_run_lacks() -> void:
	var b := _battle()
	var db := ContentDB.load_default()
	var bp_tier := 0
	for k in db.loot_kinds():
		if float(db.loot[k].get("blueprint", 0.0)) > 0.0:
			bp_tier = int(db.loot[k]["tier"])
	assert_true(bp_tier > 0, "a kind holds a chance at a blueprint")
	var pool := db.loot_pool(b.tier + 1)
	assert_true(pool.size() >= 2, "the tier has components to find")
	var lacked := str(pool[0])
	b.blueprints_known = pool.slice(1)
	var found := 0
	for id in range(1, 41):
		var got := b.open_cache({"id": id, "tier": bp_tier, "pos": Vector2i.ZERO})
		if not str(got["blueprint"]).is_empty():
			found += 1
			assert_eq(str(got["blueprint"]), lacked, "the one blueprint the run lacks")
	assert_true(found > 0, "the chance comes up across caches")
	b.blueprints_known = pool.duplicate()
	for id in range(1, 41):
		assert_eq(str(b.open_cache({"id": id, "tier": bp_tier, "pos": Vector2i.ZERO})["blueprint"]), "", "none when the run holds them all")
	var low := b.open_cache({"id": 1, "tier": 1, "pos": Vector2i.ZERO})
	if float(db.loot[db.loot_kind_of_tier(1)].get("blueprint", 0.0)) <= 0.0:
		assert_eq(str(low["blueprint"]), "", "a kind with no chance holds none")


func test_the_campaign_banks_the_loot_as_it_banks_the_kills() -> void:
	var db := ContentDB.load_default()
	var c := Campaign.new(5)
	var uids: Array = []
	for m in c.ready_machines().slice(0, Campaign.SQUAD):
		uids.append(m.uid)
	var front := str(c.fronts()[0])
	var b := c.start_battle(front, uids)
	assert_eq(b.blueprints_known, c.blueprints, "the battle knows the run's blueprints")
	var pool := db.loot_pool(b.tier + 1)
	var new_bp := ""
	for cid in pool:
		if not c.blueprints.has(cid):
			new_bp = str(cid)
	var cid := str(pool[0])
	b.loot = [{"kind": db.loot_kind_of_tier(1), "tier": 1, "salvage": 25, "components": [cid], "blueprint": new_bp, "by": int(uids[0])}]
	var before := int(c.components.get(cid, 0))
	b.outcome = Battle.Outcome.VICTORY
	b.state = Battle.State.DONE
	var r := c.finish_battle()
	assert_eq(c.salvage, Campaign.START_SALVAGE + 25, "its salvage banked beside the kills' (none killed here)")
	assert_eq(int(r["loot_salvage"]), 25, "the report says how much was the loot's")
	assert_eq(int(c.components.get(cid, 0)), before + 1, "a component found is one copy in the stores")
	if not new_bp.is_empty():
		assert_true(c.blueprints.has(new_bp), "a blueprint found is the run's")
	assert_eq((r["loot"] as Array).size(), 1, "and the report lists what was claimed")
	# A fall loses it, as it loses the kills'.
	var c2 := Campaign.new(5)
	var b2 := c2.start_battle(str(c2.fronts()[0]), uids)
	b2.loot = [{"kind": db.loot_kind_of_tier(1), "tier": 1, "salvage": 25, "components": [cid], "blueprint": "", "by": int(uids[0])}]
	b2.field.gate_hp = 0
	b2.outcome = Battle.Outcome.GATE_FALLEN
	b2.state = Battle.State.DONE
	c2.finish_battle()
	assert_eq(c2.salvage, Campaign.START_SALVAGE, "a fallen city banks nothing")
	assert_eq(int(c2.components.get(cid, 0)), 0, "nor what was claimed")


func test_a_save_keeps_the_caches_and_what_was_claimed() -> void:
	var b := _battle()
	assert_false(b.field.caches.is_empty(), "caches on the field")
	b.loot = [{"kind": "x", "tier": 2, "salvage": 12, "components": ["a", "b"], "blueprint": "c", "by": 3}]
	b.blueprints_known = ["a", "c"]
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(back.field.caches, b.field.caches, "the caches where they lie")
	assert_eq(back.loot, b.loot, "what was claimed")
	assert_eq(back.blueprints_known, b.blueprints_known, "and the run's blueprints it opened against")


func test_the_content_refuses_a_bad_kind() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.validate().filter(func(e) -> bool: return str(e).begins_with("loot")).is_empty(), "the content's kinds are sound")
	var ids: Array = db.loot_kinds()
	db.loot[ids[1]]["tier"] = int(db.loot[ids[0]]["tier"])
	db.loot[ids[0]]["salvage"] = [9, 3]
	db.loot[ids[0]]["blueprint"] = 1.5
	db.loot[ids[0]]["fantasy"] = "shown by mistake"
	var errs := db.validate().filter(func(e) -> bool: return str(e).begins_with("loot"))
	assert_true(errs.any(func(e) -> bool: return str(e).contains("one kind a tier")), "two kinds of one tier")
	assert_true(errs.any(func(e) -> bool: return str(e).contains("salvage is [lo, hi]")), "salvage the wrong way round")
	assert_true(errs.any(func(e) -> bool: return str(e).contains("blueprint is a chance")), "a chance past one")
	assert_true(errs.any(func(e) -> bool: return str(e).contains("belongs under design")), "internal text at the top")


func test_a_tap_on_a_cache_says_its_kind_and_likely_contents() -> void:
	var b := _battle()
	var db := ContentDB.load_default()
	var c := {"id": 5, "tier": 1, "pos": Vector2i.ZERO}
	var lines := BattleScreen.cache_lines(b.field, c)
	var said := "\n".join(lines.map(func(l) -> String: return str(l.get("text", ""))))
	var e: Dictionary = db.loot[db.loot_kind_of_tier(1)]
	assert_true(said.contains(str(e["name"]).to_upper()), "its kind")
	assert_true(said.contains("%d to %d" % [int(e["salvage"][0]), int(e["salvage"][1])]), "its kind's salvage, a range, never the number")
	assert_false(said.contains("seam"), "nothing of the seam: it does nothing to a cache")
	assert_true(said.contains("claims it"), "how it is claimed")
	var top := db.loot_top_tier()
	var up := BattleScreen.cache_lines(b.field, {"id": 6, "tier": top, "pos": Vector2i.ZERO})
	var said_up := "\n".join(up.map(func(l) -> String: return str(l.get("text", ""))))
	assert_true(said_up.contains(str(db.loot[db.loot_kind_of_tier(top)]["name"]).to_upper()), "the top kind by its name")

extends TestCase

## The caches lying on the field (the bible's loot rows; Ryan, 7 November: "have all the loot on
## the field round 1, and anything that is flattened, or gets flattened, gets 'upgraded.' So fetch
## lesser loot while it's safe, or fetch better loot later at greater risk"): seeded with the map
## short of the wall, a kind up once the seam passes, claimed by a machine standing on one as the
## turn ends, its contents its kind's and the battle tier's, banked by the campaign as the kills
## are, kept by a save, and read on a tap. Content-agnostic: the kinds and their numbers are the
## content's, every id read from it.


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
			assert_eq(bool(c["flattened"]), row < f.seam_row, "flattened from the start where the seam has already passed")
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


func test_a_cache_the_seam_flattens_stands_a_kind_up_once() -> void:
	var b := _battle()
	var f := b.field
	var db := ContentDB.load_default()
	var top := db.loot_top_tier()
	var col := 2
	var at := Hex.offset_to_axial(col, f.seam_row)   # on the seam's row: not yet passed
	f.caches = [{"id": 90, "tier": 1, "pos": at, "flattened": false}, {"id": 91, "tier": top, "pos": Hex.offset_to_axial(col + 4, f.seam_row), "flattened": false}]
	assert_eq(f.cache_tier(f.caches[0]), 1, "the lowest kind while the seam has not passed it")
	f.peak()
	assert_true(f.seam_row > Hex.axial_to_offset(at).y, "the seam creeps past it")
	assert_true(bool(f.caches[0]["flattened"]), "flattened")
	assert_eq(f.cache_tier(f.caches[0]), 2, "it stands a kind up: lesser loot while it is safe, better later")
	assert_eq(f.cache_tier(f.caches[1]), top, "the top kind stays the top")
	assert_true(f.log.any(func(l) -> bool: return str(l).contains("flattens a cache")), "the log says so")
	f.peak()
	assert_eq(f.cache_tier(f.caches[0]), 2, "once: the seam passing further adds nothing")


func test_a_machine_standing_on_a_cache_claims_it_as_the_turn_ends() -> void:
	var b := _battle()
	var db := ContentDB.load_default()
	b.field.caches.clear()
	var m: Unit = b.mechs()[0]
	var h := _reachable(b, m)
	assert_ne(h, Battlefield.NO_HEX, "a hex its move reaches")
	var kind := db.loot_kind_of_tier(1)
	b.field.caches.append({"id": 7, "tier": 1, "pos": h, "flattened": false})
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
	b.field.caches.append({"id": 8, "tier": 1, "pos": Hex.offset_to_axial(0, 1), "flattened": false})
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
		var got := b.open_cache({"id": id, "tier": bp_tier, "pos": Vector2i.ZERO, "flattened": false})
		if not str(got["blueprint"]).is_empty():
			found += 1
			assert_eq(str(got["blueprint"]), lacked, "the one blueprint the run lacks")
	assert_true(found > 0, "the chance comes up across caches")
	b.blueprints_known = pool.duplicate()
	for id in range(1, 41):
		assert_eq(str(b.open_cache({"id": id, "tier": bp_tier, "pos": Vector2i.ZERO, "flattened": false})["blueprint"]), "", "none when the run holds them all")
	var low := b.open_cache({"id": 1, "tier": 1, "pos": Vector2i.ZERO, "flattened": false})
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
	b.field.caches[0]["flattened"] = true
	b.loot = [{"kind": "x", "tier": 2, "salvage": 12, "components": ["a", "b"], "blueprint": "c", "by": 3}]
	b.blueprints_known = ["a", "c"]
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(back.field.caches, b.field.caches, "the caches where they lie, flattened or not")
	assert_eq(back.field.cache_top, b.field.cache_top, "and the top kind")
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
	var top := db.loot_top_tier()
	var c := {"id": 5, "tier": 1, "pos": Vector2i.ZERO, "flattened": false}
	b.field.cache_top = top
	var lines := BattleScreen.cache_lines(b.field, c)
	var said := "\n".join(lines.map(func(l) -> String: return str(l.get("text", ""))))
	var e: Dictionary = db.loot[db.loot_kind_of_tier(1)]
	assert_true(said.contains(str(e["name"]).to_upper()), "its kind")
	assert_true(said.contains("%d to %d" % [int(e["salvage"][0]), int(e["salvage"][1])]), "its kind's salvage, a range, never the number")
	assert_true(said.contains("Once the seam flattens it"), "that the seam would stand it a kind up")
	assert_true(said.contains("claims it"), "how it is claimed")
	c["flattened"] = true
	var up := BattleScreen.cache_lines(b.field, c)
	var said_up := "\n".join(up.map(func(l) -> String: return str(l.get("text", ""))))
	assert_true(said_up.contains(str(db.loot[db.loot_kind_of_tier(2)]["name"]).to_upper()), "flattened, the kind a tier up")
	assert_true(said_up.contains("Flattened by the seam"), "and why")

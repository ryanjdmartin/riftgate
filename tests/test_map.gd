extends TestCase


func test_same_seed_same_map() -> void:
	var a := BattleMap.generate(7, 13, 42)
	var b := BattleMap.generate(7, 13, 42)
	for h in a.all_hexes():
		assert_eq(b.terrain[h], a.terrain[h], "terrain at %s" % str(h))


func test_different_seed_different_map() -> void:
	var a := BattleMap.generate(7, 13, 1)
	var b := BattleMap.generate(7, 13, 2)
	var diff := 0
	for h in a.all_hexes():
		if a.terrain[h] != b.terrain[h]:
			diff += 1
	assert_true(diff > 10, "seeds 1 and 2 differ in more than ten hexes")


func test_gate_south_rift_north() -> void:
	var m := BattleMap.generate(7, 13, 7)
	assert_eq(Hex.axial_to_offset(m.gate).y, 12, "gate on the south row")
	assert_eq(Hex.axial_to_offset(m.rift).y, 0, "rift on the north row")
	assert_eq(m.terrain[m.gate], BattleMap.Terrain.PLAIN, "gate is plain")
	assert_eq(m.terrain[m.rift], BattleMap.Terrain.PLAIN, "rift is plain")
	assert_eq(m.all_hexes().size(), 7 * 13, "hex count")


func test_ground_path_always_exists() -> void:
	for s in range(1, 80):
		var m := BattleMap.generate(7, 13, s)
		var path := m.find_path(m.gate, m.rift, [])
		assert_true(not path.is_empty(), "ground path exists for seed %d" % s)
		if not path.is_empty():
			assert_eq(path[path.size() - 1], m.rift, "path ends at the rift for seed %d" % s)


func test_words_by_way_of_moving() -> void:
	# Decided 2 October: each way of moving calls each ground fast, normal or slow, and the
	# horde (no trait) crosses any land at normal pace with water and crags as walls.
	var T := BattleMap.Terrain
	var M := BattleMap
	assert_eq(M.move_cost(T.PLAIN, ["wheeled"]), M.FAST, "wheels run fast on open ground")
	assert_eq(M.move_cost(T.ROAD, ["wheeled"]), M.FAST, "a road is open ground")
	assert_eq(M.move_cost(T.ROUGH, ["wheeled"]), M.SLOW, "wheels are slow in rough")
	assert_eq(M.move_cost(T.WATER, ["wheeled"]), M.SLOW, "wheels are slow in water")
	assert_eq(M.move_cost(T.RUINS, ["tracked"]), M.SLOW, "rubble throws a track")
	assert_eq(M.move_cost(T.ROUGH, ["tracked"]), M.NORMAL, "tracks plough through forest")
	assert_eq(M.move_cost(T.WATER, ["tracked"]), M.NORMAL, "tracks ford at normal pace")
	assert_eq(M.move_cost(T.RUINS, ["walker"]), M.NORMAL, "legs step over rubble")
	assert_eq(M.move_cost(T.WATER, ["walker"]), M.SLOW, "water stops a walker")
	assert_eq(M.move_cost(T.WATER, ["hover"]), M.FAST, "hover skims water")
	assert_eq(M.move_cost(T.RUINS, ["hover"]), M.SLOW, "hover is slow in rubble")
	assert_eq(M.move_cost(T.MOUNTAIN, ["flyer"]), M.NORMAL, "a flyer crosses a crag at normal pace")
	assert_eq(M.move_cost(T.WATER, ["flyer"]), M.NORMAL, "a flyer is the same everywhere")
	assert_eq(M.move_cost(T.WATER, []), M.WALL, "water is a wall to the horde")
	assert_eq(M.move_cost(T.RUINS, []), M.NORMAL, "the horde crosses rubble at full pace")
	assert_false(M.passable(T.MOUNTAIN, []), "ground cannot cross mountain")
	assert_true(M.passable(T.MOUNTAIN, ["flyer"]), "flyer crosses mountain")
	assert_false(M.passable(T.WATER, []), "a pack never enters water")
	assert_true(M.passable(T.WATER, ["walker"]), "a walker may enter water")
	for w in M.WAYS:
		assert_eq(M.move_cost(T.ROAD, [w]), M.move_cost(T.PLAIN, [w]), "road and plain are one ground for %s" % w)
	assert_eq(M.way_of(["defense", "wheeled"]), "wheeled", "the way of moving is found among the traits")
	assert_eq(M.way_of(["defense"]), "", "no way of moving is the horde's rule")
	assert_eq(M.move_word(T.WATER, ["walker"]), "slow", "the word for the codex")
	assert_true(M.ground_ways(T.RUINS).has(["slow", ["tracked", "wheeled", "hover"]]), "the ways grouped by word: %s" % str(M.ground_ways(T.RUINS)))
	assert_eq(M.ground_ways(T.MOUNTAIN), [["normal", ["flyer"]], ["wall", ["tracked", "walker", "wheeled", "hover"]]], "fastest first, every way once")


func test_spend_ends_the_move_on_a_slow_hex() -> void:
	var T := BattleMap.Terrain
	var M := BattleMap
	assert_eq(M.spend(T.PLAIN, ["walker"], 30), 10, "a normal hex spends 10")
	assert_eq(M.spend(T.PLAIN, ["wheeled"], 30), 5, "a fast hex spends 5")
	assert_eq(M.spend(T.PLAIN, ["walker"], 5), -1, "a normal hex needs 10 left")
	assert_eq(M.spend(T.WATER, ["walker"], 30), 30, "a slow hex spends everything left")
	assert_eq(M.spend(T.WATER, ["walker"], 5), 5, "a slow hex can be entered with any move left")
	assert_eq(M.spend(T.WATER, ["walker"], 0), -1, "but not with none")
	assert_eq(M.spend(T.WATER, [], 30), -1, "a wall cannot be entered")
	assert_eq(M.spend(T.MOUNTAIN, ["walker"], 30), -1, "nor a crag")
	var m := BattleMap.generate(7, 14, 5)
	assert_true(m.margin.size() > 0, "a generated map has scenery past its edges")
	for hx in m.margin.keys():
		assert_false(m.has(hx), "margin hex %s is not part of the field" % str(hx))


func test_the_horde_always_has_a_way_three_hexes_wide() -> void:
	# At the game's size (7x20). Water and crags together cut the rift from the gate on seven
	# of the first 200 seeds before the guarantee read the horde's rule (36, 37, 51, 92, 113,
	# 165, 199), and one land hex was the only route on a quarter of maps, so one machine
	# would have held every pack (measured 2 October). Since 3 October no two hexes cut it.
	var seeds: Array = [36, 37, 51, 92, 113, 165, 199]
	for s in range(1, 41):
		seeds.append(s)
	for s in seeds:
		var m := BattleMap.generate(7, 20, s)
		var path := m.find_path(m.gate, m.rift, [])
		assert_true(not path.is_empty(), "the horde reaches the gate for seed %d" % s)
		for h in path:
			if not m.is_structure(h):
				assert_true(BattleMap.passable(m.terrain[h], []), "the horde's route never crosses water for seed %d" % s)
		assert_true(m.narrowest_crossing() >= BattleMap.CROSSING_WIDTH, "the narrowest crossing is three wide for seed %d: %d, cut by %s" % [s, m.narrowest_crossing(), str(m.horde_cut(9))])


func test_one_water_feature_a_map() -> void:
	# Decided 2 October, built 3 October: one river or lake band a map in place of puddles.
	# A river runs off both edges of the field, a lake band off the side it reaches in from,
	# or off neither when it lies in the middle; none of it in the rift's mouth or on the
	# team's ground.
	var kinds := {}
	for s in range(1, 41):
		var m := BattleMap.generate(7, 20, s)
		kinds[m.water_feature] = true
		var field_water := 0
		for hx in m.all_hexes():
			if m.terrain[hx] == BattleMap.Terrain.WATER:
				field_water += 1
				var row := Hex.axial_to_offset(hx).y
				assert_true(row >= 4 and row <= 20 - BattleMap.GATE_ROWS - 3, "seed %d: water on row %d" % [s, row])
		assert_true(field_water > 0, "seed %d has water on the field" % s)
		var west := false
		var east := false
		for hx in m.margin.keys():
			if m.margin[hx] == BattleMap.Terrain.WATER:
				var col := Hex.axial_to_offset(hx).x
				west = west or col < 0
				east = east or col >= 7
		match m.water_feature:
			"river":
				assert_true(west and east, "seed %d: a river runs off both edges" % s)
			"lake west":
				assert_true(west and not east, "seed %d: a lake from the west runs off the west edge only" % s)
			"lake east":
				assert_true(east and not west, "seed %d: a lake from the east runs off the east edge only" % s)
			"lake middle":
				assert_true(not west and not east, "seed %d: a lake in the middle stays on the field" % s)
			_:
				assert_true(false, "seed %d has a water feature: %s" % [s, m.water_feature])
	assert_true(kinds.has("river"), "rivers come up")
	assert_true(kinds.size() >= 3, "and lakes too: %s" % str(kinds.keys()))


func test_map_kinds_tell_apart_and_stay_playable() -> void:
	# 4 October: named map types as presets of the generator's knobs, the intel the player
	# will read. Each must lean the way its name says against the mixed ground, keep the
	# horde's crossing, and leave every way of moving a path to the rift.
	var share := func(kind: String, t: int) -> float:
		var hexes := 0
		var hit := 0
		for s in range(1, 21):
			var m := BattleMap.generate(7, 20, s, kind)
			for hx in m.all_hexes():
				if m.is_structure(hx):
					continue
				hexes += 1
				if m.terrain[hx] == t or (t == BattleMap.Terrain.PLAIN and m.terrain[hx] == BattleMap.Terrain.ROAD):
					hit += 1
		return float(hit) / float(hexes)
	assert_true(share.call("steppe", BattleMap.Terrain.PLAIN) > share.call("mixed", BattleMap.Terrain.PLAIN) + 0.1, "the steppe is more open")
	assert_true(share.call("rubble", BattleMap.Terrain.RUINS) > share.call("mixed", BattleMap.Terrain.RUINS) + 0.05, "the rubble field has more ruins")
	assert_true(share.call("badlands", BattleMap.Terrain.MOUNTAIN) > share.call("mixed", BattleMap.Terrain.MOUNTAIN) + 0.04, "the badlands have more crags")
	assert_true(share.call("flooded", BattleMap.Terrain.WATER) > share.call("mixed", BattleMap.Terrain.WATER) + 0.05, "the flooded map has more water")
	for kind in BattleMap.KINDS.keys():
		for s in range(1, 21):
			var m := BattleMap.generate(7, 20, s, kind)
			assert_eq(m.kind, kind, "the map says its kind")
			assert_true(m.narrowest_crossing() >= BattleMap.CROSSING_WIDTH, "%s seed %d: the horde's crossing is three wide" % [kind, s])
			var start := m.gate_hexes[0]
			for way in BattleMap.WAYS:
				assert_true(not m.find_path(start, m.rift, [way]).is_empty(), "%s seed %d: a %s has a way to the rift" % [kind, s, way])
	assert_eq(BattleMap.generate(7, 20, 3, "no such kind").kind, "mixed", "an unknown kind is the mixed ground")
	var a := BattleMap.generate(7, 20, 3)
	var b := BattleMap.generate(7, 20, 3, "mixed")
	for hx in a.all_hexes():
		assert_eq(b.terrain[hx], a.terrain[hx], "mixed is the default")


func test_the_narrowest_crossing_counts_the_cut() -> void:
	# A wall of crags across the field with gaps: the crossing's width is the gaps' total,
	# and the cut is exactly the gap hexes.
	var m := BattleMap.flat(7, 20)
	for col in range(7):
		m.terrain[Hex.offset_to_axial(col, 9)] = BattleMap.Terrain.MOUNTAIN
	assert_eq(m.narrowest_crossing(), 0, "a full wall cuts the horde off")
	var gap := [Hex.offset_to_axial(2, 9), Hex.offset_to_axial(5, 9)]
	for h in gap:
		m.terrain[h] = BattleMap.Terrain.PLAIN
	assert_eq(m.narrowest_crossing(), 2, "two gaps, two routes")
	var cut := m.horde_cut(3)
	cut.sort()
	gap.sort()
	assert_eq(cut, gap, "and the gaps are the cut")
	assert_eq(m.horde_cut(2).size(), 0, "no cut narrower than two")
	assert_eq(BattleMap.flat(7, 20).narrowest_crossing(), 5, "an open field is as wide as the rift's open hexes allow")
	# Widened: the guarantee opens the fewest crags to route the horde round the cut.
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	m._ensure_ground_path(rng)
	assert_eq(m.narrowest_crossing(), 3, "one crag opened makes it three")
	var crags := 0
	for col in range(7):
		if m.terrain[Hex.offset_to_axial(col, 9)] == BattleMap.Terrain.MOUNTAIN:
			crags += 1
	assert_eq(crags, 4, "and only one")


func test_path_respects_blocked() -> void:
	var m := BattleMap.flat(5, 5)
	var from := Hex.offset_to_axial(2, 4)
	var to := Hex.offset_to_axial(2, 0)
	var open := m.find_path(from, to, [])
	assert_eq(open.size(), 4, "straight run is four steps")
	var blocked := {}
	blocked[open[0]] = true
	var detour := m.find_path(from, to, [], blocked)
	assert_true(not detour.is_empty(), "detour exists")
	assert_false(detour.has(open[0]), "detour avoids the blocked hex")


func test_walls_fill_the_bottom_row_beside_the_gate_and_block() -> void:
	var m := BattleMap.flat(7, 20)
	assert_eq(m.gate_hexes.size(), 7, "a four-hex apron over a three-hex gate")
	assert_eq(m.wall_hexes.size(), 7, "walls on the other hexes of both rows: three beside the apron, four beside the gate")
	for w in m.wall_hexes:
		assert_true(m.is_structure(w), "a wall hex is a structure: nobody stands on it")
		assert_false(m.gate_hexes.has(w), "and it is not the gate")
	for col in range(7):
		assert_true(m.is_structure(Hex.offset_to_axial(col, 19)), "the bottom row is all structure")
		assert_true(m.is_structure(Hex.offset_to_axial(col, 18)), "so is the apron row above it")
		assert_false(m.is_structure(Hex.offset_to_axial(col, 17)), "the row above the apron is open ground")
	var g := BattleMap.generate(7, 20, 3)
	assert_eq(g.wall_hexes.size(), 7, "generated maps have them too")


func test_roads_are_laid_as_paths_with_gaps() -> void:
	# Roads are never rolled at random: a trunk runs north from the gate, mostly connected,
	# with slabs missing here and there. Over many seeds every map has a road, and most
	# road hexes touch another road hex.
	var touching := 0
	var total := 0
	for s in range(1, 40):
		var m := BattleMap.generate(7, 14, s)
		var roads: Array[Vector2i] = []
		for h in m.all_hexes():
			if m.terrain[h] == BattleMap.Terrain.ROAD:
				roads.append(h)
		assert_true(roads.size() >= 3, "seed %d has a road" % s)
		for r in roads:
			total += 1
			for n in Hex.neighbors(r):
				if roads.has(n):
					touching += 1
					break
	assert_true(touching * 10 >= total * 6, "most road hexes connect to another (%d of %d)" % [touching, total])
	# No lone slabs, and roads all at one level.
	var m2 := BattleMap.generate(7, 14, 9)
	for h in m2.all_hexes():
		if m2.terrain[h] != BattleMap.Terrain.ROAD:
			continue
		var joined := false
		for n in Hex.neighbors(h):
			if m2.terrain.get(n, -1) == BattleMap.Terrain.ROAD or m2.gate_hexes.has(n):
				joined = true
		assert_true(joined, "road hex %s joins a road or the gate" % str(h))
		assert_eq(m2.elevation[h], 0, "road hex %s is at ground level" % str(h))


func test_the_road_starts_in_front_of_the_gate_and_leaves_no_lone_slab() -> void:
	# Found 2 October, fixed 6 October: the trunk's first slab, in front of the gate, was
	# paved over by the gate clearing on every map, and the lone-slab pass had already run.
	var lone := 0
	for s in range(1, 60):
		var m := BattleMap.generate(7, 20, s)
		var gate_o := Hex.axial_to_offset(m.gate)
		var first := Hex.offset_to_axial(gate_o.x, gate_o.y - BattleMap.GATE_ROWS)
		assert_eq(m.terrain[first], BattleMap.Terrain.ROAD, "seed %d: the road's first slab stands in front of the gate" % s)
		for h in m.all_hexes():
			if m.terrain[h] != BattleMap.Terrain.ROAD:
				continue
			var joined := false
			for n in Hex.neighbors(h):
				if m.terrain.get(n, -1) == BattleMap.Terrain.ROAD or m.gate_hexes.has(n):
					joined = true
			if not joined:
				lone += 1
	assert_eq(lone, 0, "no lone slab on 59 maps")

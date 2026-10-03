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
	assert_eq(M.way_of(["stealth", "wheeled"]), "wheeled", "the way of moving is found among the traits")
	assert_eq(M.way_of(["stealth"]), "", "no way of moving is the horde's rule")
	assert_eq(M.move_word(T.WATER, ["walker"]), "slow", "the word for the codex")
	assert_true(M.ground_words(T.WATER).contains("packs never enter"), "the terrain tap says what the horde does")
	assert_true(M.ground_words(T.RUINS).contains("slow for tracked, wheeled, hover"), "the ways grouped by word: %s" % M.ground_words(T.RUINS))


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


func test_the_horde_always_has_a_way_no_single_hex_plugs() -> void:
	# At the game's size (7x20). Water and crags together cut the rift from the gate on seven
	# of the first 200 seeds before the guarantee read the horde's rule (36, 37, 51, 92, 113,
	# 165, 199), and one land hex was the only route on a quarter of maps, so one machine
	# would have held every pack (measured 2 October).
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
		assert_eq(m.plugs().size(), 0, "no single hex plugs the horde's route for seed %d: %s" % [s, str(m.plugs())])


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

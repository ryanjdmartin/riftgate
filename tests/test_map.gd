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


func test_passability() -> void:
	var T := BattleMap.Terrain
	assert_false(BattleMap.passable(T.MOUNTAIN, []), "ground cannot cross mountain")
	assert_true(BattleMap.passable(T.MOUNTAIN, ["flyer"]), "flyer crosses mountain")
	assert_false(BattleMap.passable(T.WATER, []), "ground cannot cross water")
	assert_true(BattleMap.passable(T.WATER, ["hover"]), "hover crosses water")
	assert_eq(BattleMap.move_cost(T.ROUGH, []), 2, "rough costs 2")
	assert_eq(BattleMap.move_cost(T.ROUGH, ["walker"]), 1, "walker ignores rough")
	assert_eq(BattleMap.move_cost(T.ROUGH, ["flyer"]), 1, "flyer ignores rough")


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
	assert_eq(m.gate_hexes.size(), 3, "a three-hex gate")
	assert_eq(m.wall_hexes.size(), 4, "walls on the other four bottom-row hexes")
	for w in m.wall_hexes:
		assert_true(m.is_structure(w), "a wall hex is a structure: nobody stands on it")
		assert_false(m.gate_hexes.has(w), "and it is not the gate")
	var g := BattleMap.generate(7, 20, 3)
	assert_eq(g.wall_hexes.size(), 4, "generated maps have them too")

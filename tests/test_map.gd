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


func test_the_crossing_table() -> void:
	# Ryan, 27 and 28 October: a step a hex, and ground is ground. Open ground, rough and ruins
	# are a step to everyone; water is the one priced ground, waded at two by the ground ways
	# and crossed at one by hover and flyers; crags are the flyer's; the horde (no trait) crosses
	# any land, water and crags walls; a winged pack crosses both as a flyer does.
	var T := BattleMap.Terrain
	var M := BattleMap
	for w in M.WAYS + ["winged", ""]:
		for t in [T.PLAIN, T.ROAD, T.ROUGH, T.RUINS]:
			assert_eq(M.step_cost(t, [w]), M.STEP, "%s is a step for %s" % [BattleMap.TERRAIN_NAMES[t], w if w != "" else "the horde"])
		assert_eq(M.step_cost(T.ROAD, [w]), M.step_cost(T.PLAIN, [w]), "road and plain are one ground for %s" % w)
	for w in ["tracked", "walker", "wheeled"]:
		assert_eq(M.step_cost(T.WATER, [w]), M.WADE, "%s wades water" % w)
		assert_eq(M.step_cost(T.MOUNTAIN, [w]), M.WALL, "a crag is a wall to %s" % w)
	assert_eq(M.step_cost(T.WATER, ["hover"]), M.STEP, "hover crosses water at a step")
	assert_eq(M.step_cost(T.MOUNTAIN, ["hover"]), M.WALL, "and a crag stops it")
	assert_eq(M.step_cost(T.WATER, ["flyer"]), M.STEP, "a flyer crosses water")
	assert_eq(M.step_cost(T.MOUNTAIN, ["flyer"]), M.STEP, "and crags")
	assert_eq(M.step_cost(T.WATER, ["winged"]), M.STEP, "a winged pack crosses water as a flyer does")
	assert_eq(M.step_cost(T.MOUNTAIN, ["winged"]), M.STEP, "and crags")
	assert_eq(M.step_cost(T.WATER, []), M.WALL, "water is a wall to the horde")
	assert_eq(M.step_cost(T.MOUNTAIN, []), M.WALL, "and so is a crag")
	assert_false(M.passable(T.MOUNTAIN, []), "ground cannot cross mountain")
	assert_true(M.passable(T.MOUNTAIN, ["flyer"]), "flyer crosses mountain")
	assert_false(M.passable(T.WATER, []), "a pack never enters water")
	assert_true(M.passable(T.WATER, ["walker"]), "a walker may enter water")
	assert_true(M.passable(T.WATER, ["winged"]), "a winged pack may")
	assert_eq(M.way_of(["defense", "wheeled"]), "wheeled", "the way of moving is found among the traits")
	assert_eq(M.way_of(["defense"]), "", "no way of moving is the horde's rule")
	assert_eq(M.way_of(["winged"]), "winged", "a winged pack's word")
	assert_false(M.WAYS.has("winged"), "and never a chassis's way of moving")
	assert_eq(M.ground_ways(T.RUINS), [["cross", ["tracked", "walker", "wheeled", "hover", "flyer"]]], "ruins are ground to every machine")
	assert_eq(M.ground_ways(T.WATER), [["wade", ["tracked", "walker", "wheeled"]], ["cross", ["hover", "flyer"]]], "water: the ground ways wade, the rest cross")
	assert_eq(M.ground_ways(T.MOUNTAIN), [["cross", ["flyer"]], ["wall", ["tracked", "walker", "wheeled", "hover"]]], "a crag: the flyer crosses, every other way is walled")


func test_spend_wades_water_with_whatever_is_left() -> void:
	# Q1 of the movement proposal (Ryan, 28 October): a water hex costs a ground machine two of
	# its move and can always be entered with whatever is left, so a move of 3 wades two hexes.
	var T := BattleMap.Terrain
	var M := BattleMap
	assert_eq(M.spend(T.PLAIN, ["walker"], 3), 1, "a step spends one")
	assert_eq(M.spend(T.RUINS, ["wheeled"], 3), 1, "rubble is a step for wheels too")
	assert_eq(M.spend(T.PLAIN, ["walker"], 0), -1, "nothing is entered with no move left")
	assert_eq(M.spend(T.WATER, ["walker"], 3), 2, "a wade spends two")
	assert_eq(M.spend(T.WATER, ["walker"], 1), 1, "and can be entered with the one left")
	assert_eq(M.spend(T.WATER, ["walker"], 0), -1, "but not with none")
	assert_eq(M.spend(T.WATER, ["hover"], 3), 1, "a hover crosses water at one")
	assert_eq(M.spend(T.WATER, [], 3), -1, "a wall cannot be entered")
	assert_eq(M.spend(T.MOUNTAIN, ["walker"], 3), -1, "nor a crag")
	assert_eq(M.spend(T.MOUNTAIN, ["flyer"], 3), 1, "but a flyer crosses it")
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


## The rows a shape lays water and walls on: past the rift's mouth (rows 0 to 3), short of the
## team's two rows above the gate's apron.
func _hi(h: int) -> int:
	return h - BattleMap.GATE_ROWS - 3


## The field's hexes of a terrain on one map.
func _field(m: BattleMap, t: int) -> Array:
	var out: Array = []
	for hx in m.all_hexes():
		if not m.is_structure(hx) and m.terrain[hx] == t:
			out.append(hx)
	return out


func test_each_shape_lays_what_its_name_says() -> void:
	# Ryan, 28 and 29 October: six shapes, the name on the front card the whole intel. A river
	# across with fords, a fjord down the field with a lane either side, the badlands' mesas and
	# ponds, the steppe nearly clear, the city's bands of towers with gaps, the gorge's cliffs
	# down the field; none of it in the rift's mouth or on the team's ground.
	for w in [7, 9]:
		for s in range(1, 21):
			for kind in BattleMap.KINDS.keys():
				var m := BattleMap.generate(w, 20, s, kind)
				var water := _field(m, BattleMap.Terrain.WATER)
				var walls := _field(m, BattleMap.Terrain.MOUNTAIN)
				for hx in water + walls:
					var row := Hex.axial_to_offset(hx).y
					assert_true(row >= BattleMap.MOUTH_ROWS and row <= _hi(20), "%s %dx20 seed %d: water or a wall on row %d" % [kind, w, s, row])
				var west := false
				var east := false
				for hx in m.margin.keys():
					if m.margin[hx] == BattleMap.Terrain.WATER:
						west = west or Hex.axial_to_offset(hx).x < 0
						east = east or Hex.axial_to_offset(hx).x >= w
				var tag := "%s %dx20 seed %d" % [kind, w, s]
				match kind:
					"river":
						assert_true(west and east, "%s: the river runs off both edges" % tag)
						assert_true(m.fords.size() >= 1 and m.fords.size() <= 2, "%s: one ford or two" % tag)
						for hx in walls:
							assert_eq(m.wall_look[hx], "crags", "%s: a bank's wall is a crag" % tag)
						assert_true(walls.size() <= 2, "%s: a crag on a bank at most" % tag)
					"fjord":
						assert_false(west or east, "%s: the fjord stays on the field" % tag)
						assert_true(walls.is_empty(), "%s: no wall" % tag)
						for row in range(BattleMap.MOUTH_ROWS, _hi(20) + 1):
							var cols: Array = []
							for col in range(w):
								if m.terrain[Hex.offset_to_axial(col, row)] == BattleMap.Terrain.WATER:
									cols.append(col)
							assert_true(cols.size() >= 2, "%s: water on row %d" % [tag, row])
							if not cols.is_empty():
								assert_true(cols.min() >= 2 and cols.max() <= w - 3, "%s: a lane two wide either side on row %d: %s" % [tag, row, str(cols)])
					"badlands":
						assert_true(walls.size() >= 4, "%s: mesas in groups" % tag)
						for hx in walls:
							assert_eq(m.wall_look[hx], "mesas", "%s: the walls are mesas" % tag)
						assert_true(water.size() >= 2, "%s: ponds" % tag)
					"steppe":
						assert_true(walls.size() <= 1, "%s: a lone crag at most" % tag)
						assert_true(water.size() <= 3, "%s: a pond at most" % tag)
					"city":
						assert_true(water.is_empty(), "%s: no water" % tag)
						for hx in walls:
							assert_eq(m.wall_look[hx], "towers", "%s: the walls are towers" % tag)
						var bands := 0
						for row in range(BattleMap.MOUTH_ROWS, _hi(20) + 1):
							var n := 0
							for col in range(w):
								if m.terrain[Hex.offset_to_axial(col, row)] == BattleMap.Terrain.MOUNTAIN:
									n += 1
							if n >= w - 4:
								bands += 1
						assert_true(bands >= 1, "%s: a band of towers across, its gaps four wide at most" % tag)
						assert_true(m.gaps.size() >= 1 and m.gaps.size() <= 4, "%s: one or two gaps a band" % tag)
					"gorge":
						assert_true(water.is_empty(), "%s: no water" % tag)
						for row in range(BattleMap.MOUTH_ROWS, _hi(20) + 1):
							var n := 0
							for col in range(w):
								var hx := Hex.offset_to_axial(col, row)
								if m.terrain[hx] == BattleMap.Terrain.MOUNTAIN:
									n += 1
									assert_eq(m.wall_look[hx], "cliffs", "%s: the walls are cliffs" % tag)
							assert_true(n >= 1, "%s: a cliff down the field on row %d" % [tag, row])
						assert_eq(m.margin.get(Hex.offset_to_axial(-1, 8), -1), BattleMap.Terrain.MOUNTAIN, "%s: the gorge's own side past the west edge" % tag)


func test_every_shape_stays_playable() -> void:
	# Each shape keeps the horde's crossing three wide and leaves every way of moving a path from
	# the gate to the rift, at the game's width and at seven.
	for kind in BattleMap.KINDS.keys():
		for w in [7, 9]:
			for s in range(1, 21):
				var m := BattleMap.generate(w, 20, s, kind)
				assert_eq(m.kind, kind, "the map says its shape")
				assert_true(m.narrowest_crossing() >= BattleMap.CROSSING_WIDTH, "%s %dx20 seed %d: the horde's crossing is three wide" % [kind, w, s])
				for way in BattleMap.WAYS:
					assert_true(not m.find_path(m.gate_hexes[0], m.rift, [way]).is_empty(), "%s %dx20 seed %d: a %s has a way to the rift" % [kind, w, s, way])


func test_a_battle_that_names_no_shape_draws_one_by_its_seed() -> void:
	# The campaign's way (29 October): every shape alike, the same seed the same shape.
	var seen := {}
	for s in range(1, 61):
		var k := BattleMap.kind_for_seed(s)
		assert_true(BattleMap.KINDS.has(k), "seed %d draws a shape" % s)
		assert_eq(BattleMap.kind_for_seed(s), k, "and the same one again")
		seen[k] = int(seen.get(k, 0)) + 1
	assert_eq(seen.size(), BattleMap.KINDS.size(), "sixty seeds draw every shape: %s" % str(seen))
	assert_eq(BattleMap.generate(7, 20, 3, "no such kind").kind, BattleMap.kind_for_seed(3), "an unknown shape is the seed's")
	var a := BattleMap.generate(7, 20, 3)
	var b := BattleMap.generate(7, 20, 3, BattleMap.kind_for_seed(3))
	for hx in a.all_hexes():
		assert_eq(b.terrain[hx], a.terrain[hx], "none named is the seed's shape")


func test_walls_are_named_by_what_they_are() -> void:
	# Ryan, 29 October: "the busted skyscraper that serves as a ruins crag, shouldn't be called
	# a crag". One rule under every name; the ground tap and a fight's label read the look.
	var looks := {}
	for kind in BattleMap.KINDS.keys():
		for s in range(1, 11):
			var m := BattleMap.generate(9, 20, s, kind)
			for hx in m.wall_look.keys():
				looks[m.wall_look[hx]] = true
				assert_eq(m.terrain_of(hx), BattleMap.Terrain.MOUNTAIN, "%s seed %d: a look only on a wall" % [kind, s])
				assert_eq(m.ground_id(hx), m.wall_look[hx], "the wall's word is its look")
			for hx in m.all_hexes():
				if m.terrain[hx] == BattleMap.Terrain.MOUNTAIN:
					assert_true(m.wall_look.has(hx), "%s seed %d: every wall has a look" % [kind, s])
				elif not m.is_structure(hx):
					assert_eq(m.ground_id(hx), BattleMap.TERRAIN_NAMES[m.terrain[hx]], "and the rest is its terrain's word")
	assert_eq(looks.size(), BattleMap.WALL_LOOKS.size(), "every look stands somewhere: %s" % str(looks.keys()))
	assert_false(BattleMap.ground_ids().has("mountain"), "the wall class is never shown")
	for look in BattleMap.WALL_LOOKS:
		assert_true(BattleMap.ground_ids().has(look), "%s is a ground word" % look)


func test_the_relief_is_the_shapes() -> void:
	# Ryan, 29 October: "I like the look but maybe it's a bit too much for the phone screen".
	# At most two steps on the field and three in the scenery, never a lone hex, and the lanes
	# level: the field is level but for the badlands' mesas on their shoulders and the steppe's
	# one rise; the roads, the team's rows and the ground in front of the gate and the rift
	# are level.
	for kind in BattleMap.KINDS.keys():
		for s in range(1, 21):
			var m := BattleMap.generate(9, 20, s, kind)
			var tag := "%s seed %d" % [kind, s]
			var raised: Array = []
			for hx in m.elevation.keys():
				var e: int = m.elevation[hx]
				if m.terrain_of(hx) == BattleMap.Terrain.WATER:
					assert_eq(e, -1, "%s: water is sunk" % tag)
					continue
				assert_true(e >= 0 and e <= (2 if m.has(hx) else 3), "%s: %d steps at %s" % [tag, e, str(hx)])
				var row := Hex.axial_to_offset(hx).y
				if m.has(hx) and (m.terrain[hx] == BattleMap.Terrain.ROAD or row > _hi(20)):
					assert_eq(e, 0, "%s: roads and the team's rows are level" % tag)
				if m.has(hx) and e > 0 and m.terrain[hx] != BattleMap.Terrain.MOUNTAIN:
					raised.append(hx)
				var land := 0
				var same := false
				for n in Hex.neighbors(hx):
					if m.elevation.has(n) and int(m.elevation[n]) >= 0:
						land += 1
						same = same or int(m.elevation[n]) == e
				assert_true(same or land < 3, "%s: %s stands alone" % [tag, str(hx)])
			for r in m.rift_hexes + m.gate_hexes:
				for n in Hex.neighbors(r):
					if m.has(n):
						assert_eq(int(m.elevation[n]), 0, "%s: the ground in front of the gate and the rift is level" % tag)
			match kind:
				"badlands":
					# A mesa's shoulder, or a pit among shoulders that no lone hex filled.
					for hx in raised:
						var by_mesa := false
						for n in BattleMap._within(hx, 2):
							by_mesa = by_mesa or m.terrain_of(n) == BattleMap.Terrain.MOUNTAIN
						assert_true(by_mesa, "%s: a raised hex is a mesa's shoulder: %s" % [tag, str(hx)])
				"steppe":
					var seen := {}
					var regions := 0
					for hx in raised:
						if seen.has(hx):
							continue
						regions += 1
						var queue: Array = [hx]
						seen[hx] = true
						while not queue.is_empty():
							var cur: Vector2i = queue.pop_front()
							for n in Hex.neighbors(cur):
								if raised.has(n) and not seen.has(n):
									seen[n] = true
									queue.append(n)
					assert_true(regions <= 1, "%s: one rise at most, %d found" % [tag, regions])
				_:
					assert_true(raised.is_empty(), "%s: the field is level: %s" % [tag, str(raised)])


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
	# Roads are never rolled at random, and they lead somewhere (Ryan, 29 October): the river's
	# to its fords, the steppe's one road north, the city's streets through its gaps; the fjord,
	# the badlands and the gorge lay none. Over many seeds every map that lays one has a road,
	# most road hexes touch another, none is a lone slab and all are level.
	for kind in ["river", "steppe", "city"]:
		var touching := 0
		var total := 0
		for s in range(1, 30):
			var m := BattleMap.generate(7, 14, s, kind)
			var roads := _field(m, BattleMap.Terrain.ROAD)
			assert_true(roads.size() >= 3, "%s seed %d has a road" % [kind, s])
			for r in roads:
				total += 1
				var joined := false
				for n in Hex.neighbors(r):
					if roads.has(n):
						touching += 1
						break
				for n in Hex.neighbors(r):
					joined = joined or m.terrain.get(n, -1) == BattleMap.Terrain.ROAD or m.gate_hexes.has(n)
				assert_true(joined, "%s seed %d: road hex %s joins a road or the gate" % [kind, s, str(r)])
				assert_eq(m.elevation[r], 0, "%s seed %d: road hex %s is level" % [kind, s, str(r)])
		assert_true(touching * 10 >= total * 6, "%s: most road hexes connect to another (%d of %d)" % [kind, touching, total])
	for kind in ["fjord", "badlands", "gorge"]:
		for s in range(1, 11):
			assert_true(_field(BattleMap.generate(9, 20, s, kind), BattleMap.Terrain.ROAD).is_empty(), "%s seed %d lays no road" % [kind, s])


func test_the_roads_lead_to_the_fords_and_through_the_gaps() -> void:
	# A river's road reaches each ford, a city's streets run through its gaps (a slab may be
	# missing, so most rather than all).
	var reached := 0
	var places := 0
	for s in range(1, 41):
		for kind in ["river", "city"]:
			var m := BattleMap.generate(9, 20, s, kind)
			for place in (m.fords if kind == "river" else m.gaps):
				places += 1
				var near := false
				for hx in place:
					for n in [hx] + Array(Hex.neighbors(hx)):
						near = near or m.terrain.get(n, -1) == BattleMap.Terrain.ROAD
				if near:
					reached += 1
	assert_true(reached * 10 >= places * 9, "a road at %d of %d fords and gaps" % [reached, places])


func test_the_road_starts_in_front_of_the_gate() -> void:
	# Found 2 October, fixed 6 October: the trunk's first slab, in front of the gate, was paved
	# over by the gate clearing on every map. On every shape that lays a road it is there.
	for kind in ["river", "steppe", "city"]:
		for s in range(1, 30):
			var m := BattleMap.generate(7, 20, s, kind)
			var gate_o := Hex.axial_to_offset(m.gate)
			var first := Hex.offset_to_axial(gate_o.x, gate_o.y - BattleMap.GATE_ROWS)
			assert_eq(m.terrain[first], BattleMap.Terrain.ROAD, "%s seed %d: the road's first slab stands in front of the gate" % [kind, s])

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
	# any land and wades water as a ground machine does (Ryan, 29 October), walls its wall; a
	# winged pack crosses both as a flyer does.
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
	assert_eq(M.step_cost(T.WATER, []), M.WADE, "the horde wades water as a ground machine does")
	assert_eq(M.step_cost(T.MOUNTAIN, []), M.WALL, "and a crag is its wall")
	assert_false(M.passable(T.MOUNTAIN, []), "ground cannot cross mountain")
	assert_true(M.passable(T.MOUNTAIN, ["flyer"]), "flyer crosses mountain")
	assert_true(M.passable(T.WATER, []), "a pack may enter water")
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
	assert_eq(M.spend(T.WATER, [], 3), 2, "the horde wades at two too")
	assert_eq(M.spend(T.MOUNTAIN, [], 3), -1, "a wall cannot be entered")
	assert_eq(M.spend(T.MOUNTAIN, ["walker"], 3), -1, "nor a crag")
	assert_eq(M.spend(T.MOUNTAIN, ["flyer"], 3), 1, "but a flyer crosses it")
	var m := BattleMap.generate(7, 14, 5)
	assert_true(m.margin.size() > 0, "a generated map has scenery past its edges")
	for hx in m.margin.keys():
		assert_false(m.has(hx), "margin hex %s is not part of the field" % str(hx))


func test_the_horde_always_has_a_way_three_hexes_wide() -> void:
	# At the game's size (7x20). One land hex was the only route on a quarter of maps before
	# the guarantee, so one machine would have held every pack (measured 2 October); since 3
	# October no two hexes cut it, and since 29 October only walls can, the horde wading water.
	var seeds: Array = [36, 37, 51, 92, 113, 165, 199]
	for s in range(1, 41):
		seeds.append(s)
	for s in seeds:
		var m := BattleMap.generate(7, 20, s)
		var path := m.find_path(m.gate, m.rift, [])
		assert_true(not path.is_empty(), "the horde reaches the gate for seed %d" % s)
		for h in path:
			if not m.is_structure(h):
				assert_true(m.terrain[h] != BattleMap.Terrain.MOUNTAIN, "the horde's route never crosses a wall for seed %d" % s)
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


## The sizes the shapes are read at: the old field (seven and nine wide, twenty deep), the long
## wall's (twenty by twelve, the ramp's placeholder) and two the ramp might deal (thirty by ten,
## twenty-four by fourteen).
const SIZES := [[7, 20], [9, 20], [20, 12], [30, 10], [24, 14], [20, 14], [20, 16]]   # the last two the field trial's depths (Settings.FIELD_DEPTHS)


func test_the_shapes_lay_to_the_rifts_row() -> void:
	# Ryan, 10 November, after his play: "the flattened side needs features, all the way to the
	# back". The rift's mouth is the ground beside the rift and nothing more, so a shape lays from
	# the rift's row and has every row but the team's two: eight at twelve deep, sixteen at twenty.
	assert_eq(BattleMap.flat(20, 12).mouth_rows(), 0, "a shape lays from the rift's row")
	assert_eq(BattleMap.flat(20, 12)._open_rows(), 8, "eight open rows at twelve deep")
	assert_eq(BattleMap.flat(9, 20)._open_rows(), 16, "sixteen at twenty")
	var back := 0
	for kind in BattleMap.KINDS.keys():
		for s in range(1, 21):
			var m := BattleMap.generate(20, 12, s, kind)
			for hx in m.all_hexes():
				var t: int = m.terrain[hx]
				if Hex.axial_to_offset(hx).y <= 1 and (t == BattleMap.Terrain.WATER or t == BattleMap.Terrain.MOUNTAIN):
					back += 1
					break
			for r in m.rift_hexes:
				for n in Hex.neighbors(r):
					if m.has(n):
						var t2: int = m.terrain[n]
						assert_true(t2 != BattleMap.Terrain.WATER and t2 != BattleMap.Terrain.MOUNTAIN, "%s seed %d: no water and no wall beside the rift" % [kind, s])
	assert_true(back >= 40, "features reach the rift's two rows on most maps of the shapes that lay any: %d of 120" % back)


func test_each_shape_lays_what_its_name_says() -> void:
	# Ryan, 28 and 29 October: six shapes, the name on the front card the whole intel; since 9
	# November laid for the long wall at any size the ramp deals, and reworked on his play of 10
	# November, and on his notes of 16 November. A fat river winding through with two narrows, a
	# delta's channels fingering down between tongues of land, the steppe clear but never bare,
	# and the
	# three wall shapes a spectrum by the mass of what blocks you (Ryan, 9 November): the gorge's
	# channels through cliff mass, the city's streets between large blocks, the badlands' small
	# obstacles on open ground in groups; none of it on the team's ground.
	for size in SIZES:
		var w: int = size[0]
		var h: int = size[1]
		for s in range(1, 21):
			for kind in BattleMap.KINDS.keys():
				var m := BattleMap.generate(w, h, s, kind)
				var lo := m.mouth_rows()
				var hi := _hi(h)
				var water := _field(m, BattleMap.Terrain.WATER)
				var walls := _field(m, BattleMap.Terrain.MOUNTAIN)
				var tag := "%s %dx%d seed %d" % [kind, w, h, s]
				for hx in water + walls:
					var row := Hex.axial_to_offset(hx).y
					assert_true(row >= lo and row <= hi, "%s: water or a wall on row %d" % [tag, row])
				var west := false
				var east := false
				for hx in m.margin.keys():
					if m.margin[hx] == BattleMap.Terrain.WATER:
						west = west or Hex.axial_to_offset(hx).x < 0
						east = east or Hex.axial_to_offset(hx).x >= w
				match kind:
					"river":
						# Ryan, 10 November: the river winds through the whole map and crosses the
						# centre, with narrows (water fords) in place of land fords; 16 November: "no
						# tributaries. Just a fat winding river with a couple narrower portions".
						assert_true(west and east, "%s: the river runs off both edges" % tag)
						assert_eq(m.narrows.size(), m.narrow_widths.size(), "%s: a length for every narrow" % tag)
						assert_true(m.narrows.size() >= (2 if w >= 12 else 1) and m.narrows.size() <= 2, "%s: two narrows: %d" % [tag, m.narrows.size()])
						if m._open_rows() >= 6 and w >= 12:
							# Fat: three hexes thick down its course, its narrows aside (a field under
							# twelve wide leaves too few columns to read).
							var cols := {}
							for hx in water:
								cols[Hex.axial_to_offset(hx).x] = int(cols.get(Hex.axial_to_offset(hx).x, 0)) + 1
							for narrow in m.narrows:
								for hx in narrow:
									cols.erase(Hex.axial_to_offset(hx).x)
							# The rift's mouth is bared whatever runs through it.
							for c in range(Hex.axial_to_offset(m.rift).x - 2, Hex.axial_to_offset(m.rift).x + 3):
								cols.erase(c)
							var thick := 0
							for c in cols.keys():
								if cols[c] >= 3:
									thick += 1
							assert_true(thick * 4 >= cols.size() * 3, "%s: the river three thick in its columns but its narrows' and the rift's: %d of %d" % [tag, thick, cols.size()])
						for i in range(m.narrows.size()):
							var narrow: Array = m.narrows[i]
							assert_true(narrow.size() >= 1 and narrow.size() <= 3, "%s: a narrow one to three hexes long" % tag)
							for hx in narrow:
								assert_eq(m.terrain[hx], BattleMap.Terrain.WATER, "%s: a narrow is water" % tag)
								var wet_beside := 0
								for n in Hex.neighbors(hx):
									if m.terrain_of(n) == BattleMap.Terrain.WATER:
										wet_beside += 1
								assert_true(wet_beside <= 4, "%s: a narrow is a hex thick: %d wet beside %s" % [tag, wet_beside, str(hx)])
								assert_true(m.terrain_of(hx + Vector2i(0, 1)) != BattleMap.Terrain.WATER or m.terrain_of(hx + Vector2i(1, -1)) != BattleMap.Terrain.WATER, "%s: nothing thickens a narrow at %s" % [tag, str(hx)])
						for hx in walls:
							assert_eq(m.wall_look[hx], "crags", "%s: a bank's wall is a crag" % tag)
						assert_true(walls.size() <= 2, "%s: a crag on a bank at most" % tag)
						var centre := Hex.offset_to_axial(w / 2, (lo + hi) / 2)
						var near_centre := false
						for hx in water:
							near_centre = near_centre or Hex.distance(hx, centre) <= 1
						assert_true(near_centre, "%s: the river crosses the field's centre" % tag)
						assert_true(water.size() >= w, "%s: a river across the width" % tag)
					"delta":
						# Ryan, 16 November, of the fjord before it: "too much water, there aren't
						# enough land paths from the gate to the rift ... more of a River Delta with
						# lots of inlets": channels fingering down, the land between them dry ways.
						assert_true(west and east, "%s: the delta fans on past both edges" % tag)
						assert_true(walls.is_empty(), "%s: no wall" % tag)
						var band := _band(m)
						assert_true(water.size() * 10 >= band and water.size() * 10 <= band * 4, "%s: water one to four tenths of the band: %d of %d" % [tag, water.size(), band])
						assert_true(m.dry_crossing(3) >= 3, "%s: three dry ways from the rift to the gate at least: %d" % [tag, m.dry_crossing(3)])
					"badlands":
						# An open field of small obstacles (Ryan, 9 November): many mesas of one to three
						# hexes, never touching, so no straight path crosses; two or three ponds.
						assert_true(walls.size() >= 10, "%s: many mesas: %d" % [tag, walls.size()])
						for hx in walls:
							assert_eq(m.wall_look[hx], "mesas", "%s: the walls are mesas" % tag)
						var grouped := 0
						for group in _groups(walls):
							assert_true((group as Array).size() <= 5, "%s: a group is two to five hexes: %d" % [tag, (group as Array).size()])
							if (group as Array).size() >= 2:
								grouped += 1
						assert_true(grouped >= 2, "%s: the mesas stand in groups: %d" % [tag, grouped])
						# On a field under nine wide the rift's five hexes and the ground bared round them
						# (10 November) take most of the first rows' width, so a pond laid there may go:
						# one is the floor there, two everywhere the game deals.
						assert_true(water.size() >= (2 if w >= 9 else 1) and water.size() <= 12, "%s: ponds: %d" % [tag, water.size()])
					"steppe":
						# Ryan, 16 November: "Open steppe is still too sparse. Does it not have a Crag? It
						# doesn't need much, just a few more things to break up the field".
						# Wide fields always have both; a field under twelve wide may have no room for one.
						assert_true(walls.size() >= (1 if w >= 12 else 0) and walls.size() <= 3 * maxi(1, w / 6), "%s: a crag of one to three for every six columns: %d" % [tag, walls.size()])
						assert_true(water.size() >= (1 if w >= 12 else 0) and water.size() <= 4 * maxi(1, w / 8), "%s: a pond of two to four for every eight columns: %d" % [tag, water.size()])
						var band := _band(m)
						var rough := _field(m, BattleMap.Terrain.ROUGH).size()
						assert_true(rough * 20 >= band and rough * 10 <= band * 4, "%s: scrub in belts, never bare and never a field of it: %d of %d" % [tag, rough, band])
					"city":
						# Channels broken by side streets between large blocks (Ryan, 9 November): towers
						# are most of the band, the streets open, a road down the main avenue from the gate.
						for hx in walls:
							assert_eq(m.wall_look[hx], "towers", "%s: the walls are towers" % tag)
						var band := _band(m)
						assert_true(walls.size() * 10 >= band * 3 and walls.size() * 10 <= band * 8, "%s: towers between three and eight tenths of the band: %d of %d" % [tag, walls.size(), band])
						assert_true(water.is_empty(), "%s: no water (Ryan, 16 November: \"Lets take all water out\"): %d" % [tag, water.size()])
						assert_true(m.streets.size() >= 1, "%s: streets" % tag)
						var front := Hex.offset_to_axial(Hex.axial_to_offset(m.gate).x, Hex.axial_to_offset(m.gate).y - BattleMap.GATE_ROWS)
						assert_eq(m.terrain[front], BattleMap.Terrain.ROAD, "%s: the main avenue starts in front of the gate" % tag)
					"gorge":
						# Winding, branching channels through cliff mass (Ryan, 9 November): cliffs are
						# most of the band and the channels a quarter at least; the gorge's own sides past
						# both edges; a flooded stretch at most two.
						for hx in walls:
							assert_eq(m.wall_look[hx], "cliffs", "%s: the walls are cliffs" % tag)
						var band := _band(m)
						assert_true(walls.size() * 10 >= band * 3, "%s: cliff mass three tenths of the band at least: %d of %d" % [tag, walls.size(), band])
						assert_true((band - walls.size()) * 4 >= band, "%s: channels a quarter of the band at least: %d of %d" % [tag, band - walls.size(), band])
						assert_true(water.size() <= 6, "%s: a flooded stretch or two: %d" % [tag, water.size()])
						assert_eq(m.margin.get(Hex.offset_to_axial(-1, lo + 1), -1), BattleMap.Terrain.MOUNTAIN, "%s: the gorge's own side past the west edge" % tag)


## The field's hexes between the mouth and the team's rows, the structures aside: the band a
## shape lays in.
func _band(m: BattleMap) -> int:
	var n := 0
	for hx in m.all_hexes():
		var row := Hex.axial_to_offset(hx).y
		if row >= m.mouth_rows() and row <= _hi(m.height) and not m.is_structure(hx):
			n += 1
	return n


## The connected groups among `hexes`, each an Array.
func _groups(hexes: Array) -> Array:
	var seen := {}
	var out: Array = []
	for hx in hexes:
		if seen.has(hx):
			continue
		var group: Array = [hx]
		seen[hx] = true
		var queue: Array = [hx]
		while not queue.is_empty():
			var cur: Vector2i = queue.pop_front()
			for n in Hex.neighbors(cur):
				if hexes.has(n) and not seen.has(n):
					seen[n] = true
					group.append(n)
					queue.append(n)
		out.append(group)
	return out


func test_the_shapes_second_ground_lies_along_their_landforms() -> void:
	# The shapes relaid (9 November): a river's gravel bars, a delta's shingle and a gorge's
	# scree are rough ground laid in stretches beside the water or the cliffs, never elsewhere
	# on the field; the city lays none (its ground is rubble), the steppe its scrub belts.
	for kind in ["river", "delta", "gorge", "city"]:
		for s in range(1, 11):
			var m := BattleMap.generate(20, 12, s, kind)
			var rough := _field(m, BattleMap.Terrain.ROUGH)
			var tag := "%s seed %d" % [kind, s]
			if kind == "city":
				assert_true(rough.is_empty(), "%s: no rough ground" % tag)
				continue
			var beside: int = BattleMap.Terrain.MOUNTAIN if kind == "gorge" else BattleMap.Terrain.WATER
			for hx in rough:
				var by := false
				for n in Hex.neighbors(hx):
					by = by or m.terrain_of(n) == beside
				assert_true(by, "%s: rough ground at %s lies beside its landform" % [tag, str(hx)])
			assert_true(rough.size() >= 3, "%s: the second ground is laid: %d hexes" % [tag, rough.size()])


func test_every_shape_stays_playable() -> void:
	# Each shape keeps the horde's crossing three wide and leaves every way of moving a path from
	# the gate to the rift, at every size the shapes are read at (SIZES).
	for kind in BattleMap.KINDS.keys():
		for size in SIZES:
			var w: int = size[0]
			var h: int = size[1]
			for s in range(1, 21):
				var m := BattleMap.generate(w, h, s, kind)
				assert_eq(m.kind, kind, "the map says its shape")
				assert_true(m.narrowest_crossing() >= BattleMap.CROSSING_WIDTH, "%s %dx%d seed %d: the horde's crossing is three wide" % [kind, w, h, s])
				for way in BattleMap.WAYS:
					assert_true(not m.find_path(m.gate_hexes[0], m.rift, [way]).is_empty(), "%s %dx%d seed %d: a %s has a way to the rift" % [kind, w, h, s, way])


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
	# to its narrows, the steppe's one road north, the city's streets (its avenues and side
	# streets, the main avenue from the gate); the delta, the badlands and the gorge lay none. Over many seeds every map that lays one has a road,
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
	for kind in ["delta", "badlands", "gorge"]:
		for s in range(1, 11):
			assert_true(_field(BattleMap.generate(9, 20, s, kind), BattleMap.Terrain.ROAD).is_empty(), "%s seed %d lays no road" % [kind, s])


func test_the_roads_lead_to_the_narrows_and_along_the_streets() -> void:
	# A river's road reaches each narrow (the water fords, 10 November), a city's streets are
	# paved (a slab may be missing, so most rather than all).
	var reached := 0
	var places := 0
	var paved := 0
	var street_hexes := 0
	for s in range(1, 41):
		for kind in ["river", "city"]:
			var m := BattleMap.generate(9, 20, s, kind)
			var roaded: Array = []
			if kind == "city":
				for street in m.streets:
					for hx in street:
						if m.has(hx) and m.terrain[hx] != BattleMap.Terrain.WATER:
							street_hexes += 1
							if m.terrain[hx] == BattleMap.Terrain.ROAD:
								paved += 1
			if kind == "river":
				roaded = m.narrows
			for place in roaded:
				places += 1
				var near := false
				for hx in place:
					for n in [hx] + Array(Hex.neighbors(hx)):
						near = near or m.terrain.get(n, -1) == BattleMap.Terrain.ROAD
				if near:
					reached += 1
	assert_true(reached * 20 >= places * 17, "a road at %d of %d narrows (a narrow dry ground cannot reach has none)" % [reached, places])
	assert_true(paved * 10 >= street_hexes * 6, "the streets paved: %d of %d hexes" % [paved, street_hexes])


func test_the_road_starts_in_front_of_the_gate() -> void:
	# Found 2 October, fixed 6 October: the trunk's first slab, in front of the gate, was paved
	# over by the gate clearing on every map. On every shape that lays a road it is there.
	for kind in ["river", "steppe", "city"]:
		for s in range(1, 30):
			var m := BattleMap.generate(7, 20, s, kind)
			var gate_o := Hex.axial_to_offset(m.gate)
			var first := Hex.offset_to_axial(gate_o.x, gate_o.y - BattleMap.GATE_ROWS)
			assert_eq(m.terrain[first], BattleMap.Terrain.ROAD, "%s seed %d: the road's first slab stands in front of the gate" % [kind, s])

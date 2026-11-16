extends TestCase

## Each domain paints its own tileset (Ryan, 29 October: "They all need their own tileset, first
## of all. Shouldn't all be painting green meadows"; 30 October: "walls and water certainly
## should change with tileset"; the grounds "not wildly different like it was", yet "the
## different types need different backgrounds"): the painted map dresses every hex by the lead
## domain's bleed, each ground a tone of the domain's, in sprites inked in the domain's colours,
## and a road runs to the roads beside it; a wall is a piece of a range that joins its look's
## walls beside it (16 November: "A mountain range should look like a continuous range, not a
## bunch of isolated chunks").

const DECORATIVE := [BattleMap.Terrain.PLAIN, BattleMap.Terrain.ROAD, BattleMap.Terrain.ROUGH, BattleMap.Terrain.RUINS]


func _battle(faction: String) -> Battle:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "clydesdale", "kite"]:
		team.append(db.make_mech(id))
	var b := Battle.new(3)
	b.setup(team, faction)
	return b


## A sprite as the colours it is drawn in, so two domains' art compares by what shows.
func _inked(key: String, name: String) -> String:
	var out := ""
	for row in DomainGround.SPRITES[key][name]:
		for ch in str(row):
			out += "." if ch == "." else str(DomainGround.INKS[key][ch])
		out += "/"
	return out


func test_every_domain_has_a_tileset() -> void:
	var db := ContentDB.load_default()
	for id in db.factions.keys():
		var bleed := str(db.factions[id].get("bleed", ""))
		assert_true(DomainGround.TILESETS.has(bleed), "%s's bleed '%s' has a tileset" % [id, bleed])
		assert_true(DomainGround.SPRITES.has(bleed) and DomainGround.INKS.has(bleed), "and its sprites and inks")
	var first := str(db.factions.values()[0].get("bleed", ""))
	assert_eq(DomainGround.key_of("no such bleed"), first, "a bleed with no tileset paints the first domain's in content")


func test_a_domains_grounds_are_one_family() -> void:
	for key in DomainGround.TILESETS.keys():
		var ground := Color(str(DomainGround.TILESETS[key]["ground"]))
		var tones := {}
		for t in DECORATIVE:
			var c := DomainGround.fill(str(key), t)
			# Steps of the posterize grid a channel (bleed.gdshader's six levels).
			var steps := [roundi(absf(c.r - ground.r) * 5.0), roundi(absf(c.g - ground.g) * 5.0), roundi(absf(c.b - ground.b) * 5.0)]
			assert_true(steps.max() <= 2 and steps[0] + steps[1] + steps[2] <= 3, "%s's %s is a tone of the domain's ground, never wildly apart" % [key, BattleMap.TERRAIN_NAMES[t]])
			tones[c.to_html()] = true
		assert_true(tones.size() >= 3, "%s's grounds are told apart by their tone too" % key)


func test_water_and_the_walls_are_each_domains_own() -> void:
	# Ryan, 30 October: "walls and water certainly should change with tileset": each domain's
	# water is its own liquid, and its walls its own rock and its own crags' shape.
	var waters := {}
	var rocks := {}
	for key in DomainGround.TILESETS.keys():
		var ts: Dictionary = DomainGround.TILESETS[key]
		var water := DomainGround.fill(str(key), BattleMap.Terrain.WATER).to_html()
		assert_false(waters.has(water), "%s's water is its own liquid" % key)
		waters[water] = true
		assert_true(water != Color(str(ts["ground"])).to_html(), "and not its ground")
		assert_true(DomainGround.RANGE_INKS.has(key), "%s has a rock for its walls" % key)
		var ink: Dictionary = DomainGround.RANGE_INKS[key]
		var rock := "%s/%s/%s/%s" % [ink["top"], ink["face"], ink["seam"], ink["peak"]]
		assert_false(rocks.has(rock), "%s's walls are its own (%s)" % [key, rock])
		rocks[rock] = true
		assert_true(DomainGround.PEAK_SIZES.has(str(ink["peak"])), "%s's crags stand up a shape that has its sizes" % key)


## Both views, each check run in each and the setting put back.
func _in_both_views(check: Callable) -> void:
	var was := MapOrient.wall_left
	for left in [true, false]:
		MapOrient.wall_left = left
		check.call("wall at the left" if left else "wall at the bottom")
	MapOrient.wall_left = was


func test_the_walls_stand_out_of_the_top_of_their_hex() -> void:
	# Ryan, 30 October: "The wall objects on all can be larger, or at least taller. Can they
	# extend out of the top of their hex": a lone crag's tallest peak stands past the top of its
	# hex into the hexes above, in either view.
	_in_both_views(func(view: String) -> void:
		var r := 24.0
		var top := INF
		for p in MapOrient.corners(Vector2.ZERO, r):
			top = minf(top, p.y)
		for key in DomainGround.TILESETS.keys():
			var rng := RandomNumberGenerator.new()
			rng.seed = 11
			var highest := INF
			for p in DomainGround._range_props(str(key), "crags", 0, 24.0, 1, rng):
				if not bool(p["lies"]):
					highest = minf(highest, (p["at"] as Vector2).y)
			assert_true(highest < top, "%s's crag stands out of its hex, %s (its top %d, the hex's %d)" % [key, view, highest, top]))


## The colour of one pixel of a texture.
func _px(tex: Texture2D, x: int, y: int) -> Color:
	return tex.get_image().get_pixel(x, y)


## How many pixels of a texture are its range's edge: `c`, the dark ink, beside an empty pixel or
## the texture's border (a fleck in the same ink, inside, is no edge).
func _edge(tex: Texture2D, c: Color) -> int:
	var img := tex.get_image()
	var w := img.get_width()
	var h := img.get_height()
	var n := 0
	for y in range(h):
		for x in range(w):
			var p := img.get_pixel(x, y)
			if p.a < 0.5 or not p.is_equal_approx(c):
				continue
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var q: Vector2i = Vector2i(x, y) + d
				if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h or img.get_pixel(q.x, q.y).a < 0.5:
					n += 1
					break
	return n


func test_a_wall_joins_the_walls_of_its_look_beside_it() -> void:
	# A wall's range runs on into the walls of its own look beside it, on the field or in the
	# scenery, and stops at ground or at another look's wall.
	var m := BattleMap.flat(9, 12)
	var at := Hex.offset_to_axial(4, 5)
	var east := at + Hex.DIRECTIONS[0]
	var nw := at + Hex.DIRECTIONS[2]
	var sw := at + Hex.DIRECTIONS[4]
	for h in [at, east, nw, sw]:
		m.terrain[h] = BattleMap.Terrain.MOUNTAIN
		m.wall_look[h] = "cliffs"
	m.wall_look[sw] = "towers"
	assert_eq(DomainGround.wall_links(m, at), (1 << 0) | (1 << 2), "joined to the cliffs east and north-west, not the towers south-west")
	assert_eq(DomainGround.wall_links(m, sw), 0, "and the towers stand alone")
	var edge := Hex.offset_to_axial(0, 5)
	var past := edge + Hex.DIRECTIONS[3]
	m.terrain[edge] = BattleMap.Terrain.MOUNTAIN
	m.wall_look[edge] = "cliffs"
	m.margin[past] = BattleMap.Terrain.MOUNTAIN
	m.wall_look[past] = "cliffs"
	assert_eq(DomainGround.wall_links(m, edge) & (1 << 3), 1 << 3, "a field's wall joins the scenery's past its edge")


func test_a_range_is_edged_only_where_it_ends() -> void:
	# A wall's base fills its hex and joins its neighbours' with no edge between: a hex joined
	# on every side has no dark edge and no face at all; one standing alone is edged all round
	# and faced only on the sides the view sees, below its top; one joined on a side has less
	# edge than one alone. In every domain, every look, either view.
	_in_both_views(func(view: String) -> void:
		for key in DomainGround.TILESETS.keys():
			var ink: Dictionary = DomainGround._range_inks(str(key))
			for look in BattleMap.WALL_LOOKS:
				var whole: Dictionary = DomainGround._range_base(str(key), look, 63, 24.0, 1)
				var alone: Dictionary = DomainGround._range_base(str(key), look, 0, 24.0, 1)
				var one: Dictionary = DomainGround._range_base(str(key), look, 1 << 1, 24.0, 1)
				var tag := "%s's %s, %s" % [key, look, view]
				assert_eq(_edge(whole["tex"], ink["out"]), 0, "%s: joined all round, no edge" % tag)
				var around := _edge(alone["tex"], ink["out"])
				assert_true(around > 40, "%s: alone, edged all round (%d)" % [tag, around])
				assert_true(_edge(one["tex"], ink["out"]) < around, "%s: joined on a side, less edge than alone" % tag)
				# The faces lie below the top: the top's middle is the top's colour.
				var at: Vector2 = alone["at"]
				var lift := int(DomainGround.RANGE_LOOKS[look]["lift"])
				var mid := _px(alone["tex"], int(-at.x), int(-at.y) - lift)
				var top_ink: Color = ink[str(DomainGround.RANGE_LOOKS[look]["top"])]
				if top_ink == Color(str(DomainGround.TILESETS[key]["ground"])):
					top_ink = ink["top"]
				assert_true(mid.is_equal_approx(top_ink) or mid.is_equal_approx(ink[str(DomainGround.RANGE_LOOKS[look]["fleck"])]) or mid.is_equal_approx(ink["seam"]), "%s: its top in the middle (%s)" % [tag, mid.to_html()]))


func test_a_crags_peaks_run_on_across_its_joined_hexes() -> void:
	# A ridge runs on: a crag joined to its neighbour stands a peak at the saddle on the edge
	# between them (the hex on the edge's first three directions' side standing it), as well as
	# its tallest about its middle.
	_in_both_views(func(view: String) -> void:
		var r := 24.0
		var lift := float(DomainGround.RANGE_LOOKS["crags"]["lift"])
		for d in range(3):
			var rng := RandomNumberGenerator.new()
			rng.seed = 5 + d
			var saddle := MapOrient.to_pixel(Hex.DIRECTIONS[d], r) * 0.5 - Vector2(0.0, lift)
			var near := INF
			for p in DomainGround._range_props("plains", "crags", 1 << d, r, 1, rng):
				if not bool(p["lies"]):
					near = minf(near, (p["foot"] as Vector2).distance_to(saddle))
			assert_true(near <= 4.0, "a peak stands at the saddle toward direction %d, %s (%.1f away)" % [d, view, near]))


func test_the_painted_mesas_and_towers_are_the_reconstructions_own_pieces() -> void:
	# The badlands' mesas and the city's towers stand in the painting where the 3D stands them, the
	# same pieces drawn from the same seed (Ryan, 16 November: "In Badlands, the connected mesas of
	# the painted and the rock features of the 3D don't really mesh"), each piece's foot where the
	# camera sees it, in either view.
	_in_both_views(func(view: String) -> void:
		var hex_px := 48.0
		var s := DomainGround.scale_of(hex_px)
		var k := (hex_px / Map3D.HEX_WORLD) / float(s)
		var sp := sin(deg_to_rad(Map3D.PITCH))
		for look in ["mesas", "towers"]:
			for seed_value in range(6):
				var rng := RandomNumberGenerator.new()
				rng.seed = seed_value
				var pieces := Map3D.wall_pieces(look, rng)
				rng.seed = seed_value
				var stands: Array = []
				for p in DomainGround._range_props("plains", look, 0, hex_px, s, rng):
					if not bool(p["lies"]):
						stands.append(p)
				assert_eq(stands.size(), pieces.size(), "%s seed %d, %s: a piece in the painting for every piece in 3D" % [look, seed_value, view])
				for i in range(mini(stands.size(), pieces.size())):
					var want := Vector2(float(pieces[i]["x"]) * k, float(pieces[i]["z"]) * sp * k)
					assert_true((stands[i]["foot"] as Vector2).distance_to(want) < 0.1, "%s seed %d, %s: piece %d stands where the 3D stands it" % [look, seed_value, view, i]))


func test_a_city_hex_holds_one_or_two_great_towers() -> void:
	# Fewer, larger buildings (Ryan, 16 November: "pull the scale back a bit and make the city
	# relatively larger than the machines. So less buildings in each hex, but they're larger"): a
	# hex's towers are one or two, the great one half the hex across at least, and every tower
	# stands taller than a machine's hex is wide.
	var hex_across := Map3D.HEX_WORLD * sqrt(3.0)
	for seed_value in range(40):
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		var towers := {}   # a tower's middle -> [its half width at the foot, its top]
		for p in Map3D.wall_pieces("towers", rng):
			var at := Vector2(float(p["x"]), float(p["z"]))
			var was: Array = towers.get(at, [0.0, 0.0])
			towers[at] = [maxf(float(was[0]), float(p["r0"])), maxf(float(was[1]), float(p["to"]))]
		assert_true(towers.size() >= 1 and towers.size() <= 2, "seed %d: one or two towers a hex: %d" % [seed_value, towers.size()])
		var great := 0.0
		for t in towers.values():
			great = maxf(great, float(t[0]))
			assert_true(float(t[1]) > hex_across * 0.7, "seed %d: a tower taller than a machine's hex is wide (%.0f)" % [seed_value, float(t[1])])
		assert_true(great * 2.0 >= hex_across * 0.45, "seed %d: the great tower half the hex across or so (%.0f of %.0f)" % [seed_value, great * 2.0, hex_across])


func test_every_sprite_is_inked_and_every_name_drawn() -> void:
	for key in DomainGround.TILESETS.keys():
		var sprites: Dictionary = DomainGround.SPRITES[key]
		var ink: Dictionary = DomainGround.INKS[key]
		for name in sprites.keys():
			var stray := ""
			for row in sprites[name]:
				for ch in str(row):
					if ch != "." and not ink.has(ch) and not stray.contains(ch):
						stray += ch
			assert_eq(stray, "", "%s's %s is inked in its domain's colours" % [key, name])
		var ts: Dictionary = DomainGround.TILESETS[key]
		var named: Array = []
		for ground in ["plain", "rough", "ruins"]:
			for e in ts[ground]:
				named.append(e[0])
		named.append_array(ts["ripples"] + ts["flat"] + ts["fixed"] + DomainGround.RANGE_INKS[key]["lies"])
		if DomainGround.RANGE_INKS[key]["peak"] == "volcanic":
			named.append("steam")   # a crater breathes it (DomainGround.draw_ranges)
		if ts.has("road_stone"):
			named.append(ts["road_stone"])
		for host in DomainGround.ATTACH.get(key, {}).keys():
			named.append(host)
			named.append(DomainGround.ATTACH[key][host][0])
		for n in named:
			assert_true(sprites.has(n) or (sprites.has(str(n) + "0") and sprites.has(str(n) + "1")), "%s draws a sprite '%s'" % [key, n])


func test_every_colour_sits_on_the_posterize_grid() -> void:
	# The map's compositor posterizes the painted world to six levels a channel (bleed.gdshader),
	# so a colour off the grid would show as another.
	for key in DomainGround.TILESETS.keys():
		var ts: Dictionary = DomainGround.TILESETS[key]
		var colours: Array = [ts["ground"], ts["grid"], ts["rim"]]
		colours.append_array(ts["grounds"].values() + ts["specks"] + ts["road"] + DomainGround.INKS[key].values())
		for role in DomainGround.RANGE_COLOURS:
			colours.append(DomainGround.RANGE_INKS[key][role])
		colours.append_array(DomainGround.BANK_INKS[key].values())
		for h in colours:
			var c := Color(str(h))
			for ch in [c.r8, c.g8, c.b8]:
				assert_eq(int(ch) % 51, 0, "%s's #%s is on the grid" % [key, h])


func test_a_ranges_inks_are_its_domains_own() -> void:
	# A wall's rock is inked in colours its domain's sprites already wear (INKS), so no colour the
	# colourblind checks never saw comes in with the ranges (docs/measurements.md, 30 October).
	for key in DomainGround.TILESETS.keys():
		var inks := {}
		for v in DomainGround.INKS[key].values():
			inks[Color(str(v)).to_html(false)] = true
		for role in DomainGround.RANGE_COLOURS:
			var h := str(DomainGround.RANGE_INKS[key][role])
			assert_true(inks.has(Color(h).to_html(false)), "%s's %s #%s is one of its inks" % [key, role, h])


func test_a_road_runs_to_the_roads_beside_it() -> void:
	var map := _battle(str(ContentDB.load_default().factions.keys()[0])).field.map
	var seen := 0
	for h in map.all_hexes() + map.margin.keys():
		if map.terrain_of(h) != BattleMap.Terrain.ROAD:
			continue
		var want := 0
		for i in range(Hex.DIRECTIONS.size()):
			var n: Vector2i = h + Hex.DIRECTIONS[i]
			if (map.has(n) or map.margin.has(n)) and map.terrain_of(n) == BattleMap.Terrain.ROAD:
				want |= 1 << i
		assert_eq(DomainGround.road_links(map, h), want, "the road at %s runs to the roads beside it" % h)
		seen += 1
	assert_true(seen > 0, "the battle has roads to read")


func test_a_battle_paints_its_lead_domains_tileset() -> void:
	var db := ContentDB.load_default()
	for id in db.factions.keys():
		var b := _battle(str(id))
		var bleed := str(db.factions[id].get("bleed", ""))
		assert_eq(DomainGround.biome_of(b.field), bleed, "a battle %s leads paints its bleed" % id)
		var painted := PaintedMap.new()
		painted.setup(b.field, Vector2.ZERO, 48.0)
		assert_eq(painted.biome, bleed, "and the painted map takes it")
		painted.free()
	assert_eq(DomainGround.biome_of(null), "", "no battle, no tileset")


func test_the_debug_switch_gives_the_whole_field_to_the_painting() -> void:
	var b := _battle(str(ContentDB.load_default().factions.keys()[0]))
	var south := Bleed.axis() * 5000.0   # far past the rift's gradient, toward the wall in either view
	var was := Bleed.everywhere
	Bleed.everywhere = false
	assert_true(Bleed.at(south, Bleed.gradient(b.field, Vector2.ZERO, 48.0), PackedVector3Array()) < 0.01, "the reconstruction stands far from the rift")
	Bleed.everywhere = true
	assert_true(Bleed.at(south, Bleed.gradient(b.field, Vector2.ZERO, 48.0), PackedVector3Array()) > 0.99, "RIFTGATE_BLEED_DEBUG paints it all")
	Bleed.everywhere = was


func test_the_fights_backdrop_keeps_its_palette_beside_the_tileset() -> void:
	# One home for a domain's colours (30 October: the fight's lava had stayed the yellow-orange
	# Ryan called acid after the map's went orange-red): every domain with a tileset has its
	# backdrop here, and the fight's water is the map's liquid.
	assert_eq(BattleBackdrop.PALETTES, DomainGround.BACKDROPS, "the fight reads the palettes kept with the tilesets")
	for key in DomainGround.TILESETS.keys():
		assert_true(DomainGround.BACKDROPS.has(key) and DomainGround.LIQUIDS.has(key), "%s has a backdrop and a liquid" % key)
		var water: Array = DomainGround.BACKDROPS[key]["water"]
		assert_eq(Color(str(water[1])), DomainGround.fill(str(key), BattleMap.Terrain.WATER), "%s: the fight's lake is the map's water" % key)
	var lava: Dictionary = DomainGround.LIQUIDS["lava"]
	assert_true(Array(DomainGround.BACKDROPS["lava"]["glow"]).has(lava["body"]), "the Peak's glow is its lava's")
	assert_eq(Color(str(DomainGround.BACKDROPS["lava"]["crust"][0])), Color(str(lava["deep"])), "and its crust the lava's deep")


func test_no_domain_wears_the_enemys_violet() -> void:
	# Violet is the rift's and the enemy's register (30 October: "keep purple for enemy
	# activities"), so no ground, sprite or backdrop paints it: the Marsh's poison purple left.
	for key in DomainGround.TILESETS.keys():
		var colours: Array = []
		var ts: Dictionary = DomainGround.TILESETS[key]
		colours.append_array([ts["ground"], ts["grid"], ts["rim"]] + ts["grounds"].values() + ts["specks"] + ts["road"])
		colours.append_array(DomainGround.INKS[key].values())
		for k in DomainGround.BACKDROPS[key].keys():
			var v: Variant = DomainGround.BACKDROPS[key][k]
			if v is Array:
				colours.append_array(v)
			elif v is String:
				colours.append(v)
		for hex in colours:
			var c := Color(str(hex))
			var violet := c.h * 360.0 >= 245.0 and c.h * 360.0 <= 300.0 and c.s > 0.15 and c.v > 0.1
			assert_false(violet, "%s paints no violet (%s)" % [key, hex])


func test_the_painting_at_heights_stands_each_hex_at_its_columns_height() -> void:
	# The mock-up of the painting at the reconstruction's heights (Ryan, 16 November: "what it would
	# look like if the painted world used the same terrain 'heights?'"): a hex's top stands where the
	# reconstruction's column puts it on screen (Map3D: its relief step, water sunk), within half a
	# design pixel, on the design pixels' grid.
	var map := BattleMap.generate(20, 12, 7, "delta")   # water sunk and the scenery rising
	var hex_px := 48.0
	var s := DomainGround.scale_of(hex_px)
	var seen := {}
	for h in map.all_hexes() + map.margin.keys():
		var e: int = map.elevation.get(h, 0)
		var units: float = Map3D.WATER_DROP if e < 0 else float(e) * Map3D.STEP
		var want := units * cos(deg_to_rad(Map3D.PITCH)) * hex_px / Map3D.HEX_WORLD
		var lift := DomainGround.lift_of(map, h, hex_px)
		assert_true(absf(float(lift) - want) <= float(s) * 0.5 + 0.001, "the hex at %s stands within half a design pixel of its column (%d, %.1f)" % [h, lift, want])
		assert_eq(lift % s, 0, "on the design pixels' grid")
		seen[e] = true
	assert_true(seen.has(-1) and seen.has(0) and seen.size() > 2, "the map has water and a rise to read")


func test_a_raised_hex_has_a_bank_where_it_drops_toward_the_view() -> void:
	# A bank under a raised hex on each side the view sees where its neighbour is lower, none where
	# nothing drops or the side faces away, in either view; and its inks are the domain's own.
	_in_both_views(func(view: String) -> void:
		var edges := DomainGround._hex_edges(24.0)
		for key in DomainGround.TILESETS.keys():
			var flat := PackedInt32Array([4, 4, 4, 4, 4, 4])
			assert_true(DomainGround._column_faces(str(key), 4, flat, 48.0, 2, 0).is_empty(), "%s: no bank where nothing drops, %s" % [key, view])
			for k in range(6):
				var drops := PackedInt32Array([4, 4, 4, 4, 4, 4])
				drops[k] = 0
				var banks := DomainGround._column_faces(str(key), 4, drops, 48.0, 2, 0)
				var n: Vector2 = edges[k]["n"]
				var seen := n.y >= 0.2 and absf((edges[k]["b"] as Vector2).x - (edges[k]["a"] as Vector2).x) > 0.01
				assert_eq(not banks.is_empty(), seen, "%s: a bank on side %d only where the view sees it, %s" % [key, k, view])
			var down := PackedInt32Array([0, 0, 0, 0, 0, 0])
			var img := (DomainGround._column_faces(str(key), 4, down, 48.0, 2, 1)["tex"] as Texture2D).get_image()
			var inks := {}
			for v in DomainGround.INKS[key].values():
				inks[Color(str(v)).to_html(false)] = true
			for y in range(img.get_height()):
				for x in range(img.get_width()):
					var p := img.get_pixel(x, y)
					if p.a > 0.5:
						assert_true(inks.has(p.to_html(false)), "%s's banks are inked in its own colours (#%s)" % [key, p.to_html(false)]))


func test_the_painting_at_heights_is_a_debug_switch() -> void:
	# The mock-up is off unless RIFTGATE_PAINTED_HEIGHTS=1 asks for it: the painting stays flat.
	assert_eq(DomainGround.heights, OS.get_environment("RIFTGATE_PAINTED_HEIGHTS") == "1", "the switch reads the environment")

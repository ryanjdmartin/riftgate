extends TestCase

## Each domain paints its own tileset (Ryan, 29 October: "They all need their own tileset, first
## of all. Shouldn't all be painting green meadows"; 30 October: "walls and water certainly
## should change with tileset"; the grounds "not wildly different like it was", yet "the
## different types need different backgrounds"): the painted map dresses every hex by the lead
## domain's bleed, each ground a tone of the domain's, in sprites inked in the domain's colours,
## and a road runs to the roads beside it.

const DECORATIVE := [BattleMap.Terrain.PLAIN, BattleMap.Terrain.ROAD, BattleMap.Terrain.ROUGH, BattleMap.Terrain.RUINS]


func _battle(faction: String) -> Battle:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "clydesdale", "sparrowhawk"]:
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
	var waters := {}
	var walls := {}
	for key in DomainGround.TILESETS.keys():
		var ts: Dictionary = DomainGround.TILESETS[key]
		var water := DomainGround.fill(str(key), BattleMap.Terrain.WATER).to_html()
		assert_false(waters.has(water), "%s's water is its own liquid" % key)
		waters[water] = true
		assert_true(water != Color(str(ts["ground"])).to_html(), "and not its ground")
		assert_true(ts["walls"].size() >= 1, "%s has a range for its walls" % key)
		for name in ts["walls"]:
			var art := _inked(str(key), str(name))
			assert_false(walls.has(art), "%s's %s is its own" % [key, name])
			walls[art] = true


func test_the_walls_stand_out_of_the_top_of_their_hex() -> void:
	# Ryan, 30 October: "The wall objects on all can be larger, or at least taller. Can they
	# extend out of the top of their hex"; a range stands on its foot low in the hex, so its
	# peaks reach past the hex's top corner into the hexes above.
	var hex := 48.0
	var reach := hex * (1.0 + DomainGround.WALL_FOOT)
	for key in DomainGround.TILESETS.keys():
		for name in DomainGround.TILESETS[key]["walls"]:
			var tall: float = DomainGround.SPRITES[key][name].size() * DomainGround.scale_of(hex)
			assert_true(tall > reach, "%s's %s stands out of its hex (%d px from a foot %d px below the top)" % [key, name, tall, reach])


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
		named.append_array(ts["walls"] + ts["ripples"] + ts["flat"] + ts["fixed"])
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
		for h in colours:
			var c := Color(str(h))
			for ch in [c.r8, c.g8, c.b8]:
				assert_eq(int(ch) % 51, 0, "%s's #%s is on the grid" % [key, h])


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
	var south := Vector2(0.0, 5000.0)   # far past the rift's gradient
	var was := Bleed.everywhere
	Bleed.everywhere = false
	assert_true(Bleed.at(south, Bleed.gradient(b.field, Vector2.ZERO, 48.0), PackedVector3Array()) < 0.01, "the reconstruction stands far from the rift")
	Bleed.everywhere = true
	assert_true(Bleed.at(south, Bleed.gradient(b.field, Vector2.ZERO, 48.0), PackedVector3Array()) > 0.99, "RIFTGATE_BLEED_DEBUG paints it all")
	Bleed.everywhere = was

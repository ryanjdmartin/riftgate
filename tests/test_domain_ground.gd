extends TestCase

## Each domain paints its own tileset (Ryan, 29 October: "They all need their own tileset, first
## of all. Shouldn't all be painting green meadows"): the painted map dresses its decorative
## grounds by the lead domain's bleed, and water and the walls read alike in every domain.


func _battle(faction: String) -> Battle:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		team.append(db.make_mech(id))
	var b := Battle.new(3)
	b.setup(team, faction)
	return b


func test_every_domain_has_a_tileset() -> void:
	var db := ContentDB.load_default()
	for id in db.factions.keys():
		var bleed := str(db.factions[id].get("bleed", ""))
		assert_true(bleed == DomainGround.PLAINS or DomainGround.TILESETS.has(bleed), "%s's bleed '%s' has a tileset" % [id, bleed])


func test_water_and_the_walls_read_alike_in_every_domain() -> void:
	var decorative := [BattleMap.Terrain.PLAIN, BattleMap.Terrain.ROAD, BattleMap.Terrain.ROUGH, BattleMap.Terrain.RUINS]
	for biome in [DomainGround.PLAINS] + DomainGround.TILESETS.keys():
		for t in [BattleMap.Terrain.WATER, BattleMap.Terrain.MOUNTAIN]:
			assert_true(DomainGround.shared(t), "%s is drawn alike everywhere" % BattleMap.TERRAIN_NAMES[t])
			assert_eq(DomainGround.fill(str(biome), t), TerrainArt.OTHER[t], "%s's %s is the plains'" % [biome, BattleMap.TERRAIN_NAMES[t]])
		var seen := {}
		for t in decorative:
			assert_false(DomainGround.shared(t), "%s is the domain's to dress" % BattleMap.TERRAIN_NAMES[t])
			var col := DomainGround.fill(str(biome), t)
			assert_false(seen.has(col.to_html()), "%s's %s has a fill of its own" % [biome, BattleMap.TERRAIN_NAMES[t]])
			seen[col.to_html()] = true
			if biome != DomainGround.PLAINS:
				assert_true(col != TerrainArt.OTHER[t], "%s's %s is its own, not the plains'" % [biome, BattleMap.TERRAIN_NAMES[t]])


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

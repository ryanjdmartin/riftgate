class_name DomainGround
extends RefCounted

## The other world's ground in each domain's own tileset (Ryan, 29 October: "They all need
## their own tileset, first of all. Shouldn't all be painting green meadows"). A domain, by its
## `bleed` in content, re-dresses the four decorative grounds (plain, road, rough, ruins) in its
## idiom; water and the walls are drawn alike in every domain (TerrainArt.draw_other_hex), so a
## domain's paint never changes how a hex's rule looks. The plains are the overworld TerrainArt
## has always drawn. Flat, bright and chunky as the painted map is (Ryan, 20 September), every
## colour a placeholder judged running: RIFTGATE_BLEED_DEBUG=1 gives the whole field to the
## painted world (Bleed.gradient), and tools/tileset_shot.gd draws every tileset side by side.
## Every colour sits on the compositor's posterize grid (six levels a channel, bleed.gdshader),
## so what is drawn is what the map shows; each was picked by the three colourblind simulations
## against the HUD options, the enemy red, the rift's violets, water and the walls as shown,
## none worse than the plains' own, and a lava crack's core is the light yellow glow, since an
## orange folds into the enemy red for a deutan (docs/measurements.md, 30 October).

## The domain whose tileset TerrainArt draws.
const PLAINS := "plains"

## A tileset a bleed: each decorative ground's fill, the hex outline, and the colours its marks
## are drawn in.
const TILESETS := {
	"sand": {
		"fill": {BattleMap.Terrain.PLAIN: "cc9933", BattleMap.Terrain.ROAD: "ffcc99", BattleMap.Terrain.ROUGH: "663300", BattleMap.Terrain.RUINS: "993300"},
		"grid": "333300",
		"dune": "663300", "dune_light": "ffcc66", "pebble": "663300",
		"track": "ffcc66", "rut": "cc9966", "stone": "cc9933",
		"cactus": "339933", "cactus_light": "66cc66", "cactus_dark": "336633", "shadow": "333300", "rock": "333300",
		"block": "ffcc99", "block_shade": "cc9966", "block_dark": "663300", "bone": "ffffff",
	},
	"marsh": {
		"fill": {BattleMap.Terrain.PLAIN: "336666", BattleMap.Terrain.ROAD: "333300", BattleMap.Terrain.ROUGH: "333333", BattleMap.Terrain.RUINS: "669999"},
		"grid": "003333",
		"reed": "99cc66", "reed_dark": "003333", "puddle": "003333", "glint": "cccccc",
		"plank": "cc9966", "plank_light": "ffcc99", "plank_gap": "333300", "post": "663300",
		"trunk": "666666", "branch": "999999", "moss": "669933",
		"tomb": "cccccc", "tomb_shade": "999999", "tomb_dark": "333333", "mound": "336666", "mist": "cccccc",
	},
	"lava": {
		"fill": {BattleMap.Terrain.PLAIN: "666666", BattleMap.Terrain.ROAD: "cccccc", BattleMap.Terrain.ROUGH: "333333", BattleMap.Terrain.RUINS: "663300"},
		"grid": "000000",
		"ash": "999999", "cinder": "333333", "ember": "ffcc33",
		"flag": "999999", "flag_light": "cccccc", "joint": "666666",
		"rim": "993300", "glow": "ffcc33", "glow_hot": "ffff99", "crust": "000000",
		"char": "000000", "char_light": "666666", "smoke": "999999",
	},
}


## The bleed of the domain leading the battle on `field` (its `spawn_faction`), "" for none.
static func biome_of(field: Battlefield) -> String:
	if field == null or field.spawn_faction.is_empty():
		return ""
	return str(ContentDB.load_default().factions.get(field.spawn_faction, {}).get("bleed", ""))


## Whether a ground is drawn alike in every domain: water and the walls, whose rule a domain's
## paint never changes.
static func shared(t: int) -> bool:
	return t == BattleMap.Terrain.WATER or t == BattleMap.Terrain.MOUNTAIN


## The flat colour a ground takes in a domain's tileset: TerrainArt's for water, the walls and
## the plains (or a bleed with no tileset of its own).
static func fill(biome: String, t: int) -> Color:
	if shared(t) or not TILESETS.has(biome):
		return TerrainArt.OTHER.get(t, TerrainArt.OTHER[BattleMap.Terrain.PLAIN])
	return Color(str(TILESETS[biome]["fill"].get(t, TILESETS[biome]["fill"][BattleMap.Terrain.PLAIN])))


## One hex of the other world in a domain's tileset, as TerrainArt.draw_other_hex draws the
## plains': a flat fill and a few chunky marks, the second frame nudging what moves.
static func draw_hex(ci: CanvasItem, c: Vector2, hex_px: float, t: int, seed_value: int, frame: int, biome: String) -> void:
	if shared(t) or not TILESETS.has(biome):
		TerrainArt.draw_other_hex(ci, c, hex_px, t, seed_value, frame)
		return
	var ts: Dictionary = TILESETS[biome]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var pts := Hex.corners(c, hex_px - 1.5)
	ci.draw_colored_polygon(pts, fill(biome, t))
	var r := hex_px * 0.7
	match biome:
		"sand":
			_sand(ci, c, hex_px, r, t, rng, frame, ts)
		"marsh":
			_marsh(ci, c, hex_px, r, t, rng, frame, ts)
		"lava":
			_lava(ci, c, hex_px, r, t, rng, frame, ts)
	Hud.stroke_poly(ci, pts, Color(Color(str(ts["grid"])), 0.35), 1.0)


static func _k(ts: Dictionary, name: String) -> Color:
	return Color(str(ts[name]))


static func _at(rng: RandomNumberGenerator, c: Vector2, rx: float, ry: float) -> Vector2:
	return (c + Vector2(rng.randf_range(-rx, rx), rng.randf_range(-ry, ry))).floor()


## The Waste: dunes rippled by the wind, a pale caravan track, cacti in rows all facing the
## same way (its fantasy's), and red-rock ruins with sandstone pillars and bleached bones.
static func _sand(ci: CanvasItem, c: Vector2, hex_px: float, r: float, t: int, rng: RandomNumberGenerator, frame: int, ts: Dictionary) -> void:
	var f2 := float(frame)
	match t:
		BattleMap.Terrain.PLAIN:
			for i in range(4):
				var p := _at(rng, c, r * 0.7, r * 0.62)
				var w := rng.randf_range(12.0, 17.0)
				# A ripple: a shadowed crest and its lit lip, the wind's way.
				ci.draw_polyline(PackedVector2Array([p, p + Vector2(w * 0.35, -3.0), p + Vector2(w * 0.7, 0.0), p + Vector2(w, -3.0)]), _k(ts, "dune"), 3.0)
				ci.draw_polyline(PackedVector2Array([p + Vector2(0.0, -3.0), p + Vector2(w * 0.35, -6.0), p + Vector2(w * 0.7, -3.0)]), _k(ts, "dune_light"), 2.0)
			for i in range(4):
				ci.draw_rect(Rect2(_at(rng, c, r, r * 0.7) + Vector2(2.0 * f2, 0.0), Vector2(3.0, 2.0)), _k(ts, "pebble"))
		BattleMap.Terrain.ROAD:
			ci.draw_colored_polygon(Hex.corners(c, hex_px - 6.0), _k(ts, "track"))
			for dx in [-r * 0.3, r * 0.3]:
				for k in range(5):
					var y := c.y - r * 0.8 + k * r * 0.4
					ci.draw_rect(Rect2(Vector2(c.x + dx - 1.0, y).floor(), Vector2(3.0, r * 0.24)), _k(ts, "rut"))
			for i in range(5):
				ci.draw_rect(Rect2(_at(rng, c, r * 0.8, r * 0.6), Vector2(4.0, 3.0)), _k(ts, "stone"))
		BattleMap.Terrain.ROUGH:
			# Three saguaros in a loose row, every arm to the east.
			var y0 := c.y + rng.randf_range(-r * 0.15, r * 0.15)
			for i in range(3):
				var x := c.x - r * 0.7 + (r * 1.4) * (float(i) + 0.5) / 3.0 + rng.randf_range(-3.0, 3.0)
				var h := rng.randf_range(18.0, 24.0)
				var base := Vector2(x, y0 + rng.randf_range(-4.0, 4.0) + h * 0.5).floor()
				ci.draw_rect(Rect2(base + Vector2(-6.0, -2.0), Vector2(15.0, 4.0)), _k(ts, "shadow"))
				ci.draw_rect(Rect2(base + Vector2(-3.0, -h), Vector2(7.0, h)), _k(ts, "cactus"))
				ci.draw_rect(Rect2(base + Vector2(-3.0, -h + 1.0), Vector2(2.0, h - 2.0)), _k(ts, "cactus_light"))
				ci.draw_rect(Rect2(base + Vector2(2.0, -h + 1.0), Vector2(2.0, h - 1.0)), _k(ts, "cactus_dark"))
				var arm := base + Vector2(4.0, -h * 0.55)
				ci.draw_rect(Rect2(arm, Vector2(5.0, 4.0)), _k(ts, "cactus"))
				ci.draw_rect(Rect2(arm + Vector2(3.0, -8.0), Vector2(5.0, 12.0)), _k(ts, "cactus"))
				ci.draw_rect(Rect2(arm + Vector2(3.0, -8.0), Vector2(2.0, 9.0)), _k(ts, "cactus_light"))
			for i in range(3):
				ci.draw_rect(Rect2(_at(rng, c, r * 0.8, r * 0.7), Vector2(4.0, 3.0)), _k(ts, "rock"))
		BattleMap.Terrain.RUINS:
			for i in range(2):
				# A broken sandstone pillar, lit on the west, its capital and a fallen block.
				var p := _at(rng, c, r * 0.45, r * 0.25) + Vector2(-r * 0.25 + i * r * 0.55, 0.0)
				var h := rng.randf_range(15.0, 21.0)
				ci.draw_rect(Rect2(p + Vector2(0.0, -h), Vector2(10.0, h)), _k(ts, "block_shade"))
				ci.draw_rect(Rect2(p + Vector2(0.0, -h), Vector2(4.0, h)), _k(ts, "block"))
				ci.draw_rect(Rect2(p + Vector2(-2.0, -h - 3.0), Vector2(14.0, 4.0)), _k(ts, "block"))
				ci.draw_rect(Rect2(p + Vector2(12.0, -6.0), Vector2(12.0, 6.0)), _k(ts, "block_dark"))
				ci.draw_rect(Rect2(p + Vector2(12.0, -6.0), Vector2(12.0, 2.0)), _k(ts, "block"))
			# Bleached bones: a ribcage and a skull, the dust drifting past.
			var b := _at(rng, c, r * 0.35, r * 0.2) + Vector2(-6.0, r * 0.42)
			ci.draw_rect(Rect2(b + Vector2(-1.0, 0.0), Vector2(16.0, 2.0)), _k(ts, "bone"))
			for k in range(4):
				ci.draw_rect(Rect2(b + Vector2(k * 4.0, 2.0), Vector2(2.0, 5.0)), _k(ts, "bone"))
			ci.draw_rect(Rect2(b + Vector2(18.0, -2.0), Vector2(7.0, 6.0)), _k(ts, "bone"))
			ci.draw_rect(Rect2(b + Vector2(19.0, 0.0), Vector2(2.0, 2.0)), _k(ts, "block_dark"))
			ci.draw_rect(Rect2(b + Vector2(22.0, 0.0), Vector2(2.0, 2.0)), _k(ts, "block_dark"))
			ci.draw_rect(Rect2(_at(rng, c, r * 0.7, r * 0.6) + Vector2(3.0 * f2, -f2), Vector2(3.0, 2.0)), _k(ts, "block"))


## The Marsh: bog with reeds and dark pools, a boardwalk over the mud, dead trees hung with moss,
## and a graveyard of tombstones and a cross.
static func _marsh(ci: CanvasItem, c: Vector2, hex_px: float, r: float, t: int, rng: RandomNumberGenerator, frame: int, ts: Dictionary) -> void:
	var f2 := float(frame)
	match t:
		BattleMap.Terrain.PLAIN:
			for i in range(2):
				var p := _at(rng, c, r * 0.6, r * 0.5)
				ci.draw_rect(Rect2(p + Vector2(-7.0, -3.0), Vector2(15.0, 7.0)), _k(ts, "puddle"))
				ci.draw_rect(Rect2(p + Vector2(-4.0, -5.0), Vector2(9.0, 11.0)), _k(ts, "puddle"))
				ci.draw_rect(Rect2(p + Vector2(-3.0 + 4.0 * f2, -2.0), Vector2(3.0, 2.0)), _k(ts, "glint"))
			for i in range(5):
				# A tuft of reeds, its tips leaning with the frame.
				var q := _at(rng, c, r * 0.85, r * 0.7)
				for k in range(3):
					var x := q.x + k * 3.0
					ci.draw_line(Vector2(x, q.y), Vector2(x + 2.0 * f2 - 1.0 + (k - 1), q.y - 7.0 - (k % 2) * 3.0), _k(ts, "reed"), 2.0)
				ci.draw_rect(Rect2(q + Vector2(-2.0, 0.0), Vector2(10.0, 2.0)), _k(ts, "reed_dark"))
		BattleMap.Terrain.ROAD:
			# Duckboards across the mud: planks with their gaps, two posts.
			var y := c.y - r * 0.6
			while y < c.y + r * 0.55:
				var half := r * 0.6
				ci.draw_rect(Rect2(Vector2(c.x - half, y).floor(), Vector2(half * 2.0, 5.0)), _k(ts, "plank"))
				ci.draw_rect(Rect2(Vector2(c.x - half, y).floor(), Vector2(half * 2.0, 2.0)), _k(ts, "plank_light"))
				ci.draw_rect(Rect2(Vector2(c.x - half, y + 5.0).floor(), Vector2(half * 2.0, 2.0)), _k(ts, "plank_gap"))
				y += 7.0
			for dx in [-r * 0.7, r * 0.7 - 4.0]:
				ci.draw_rect(Rect2(Vector2(c.x + dx, c.y - r * 0.75).floor(), Vector2(4.0, r * 1.45)), _k(ts, "post"))
		BattleMap.Terrain.ROUGH:
			for i in range(2):
				# A dead tree: a grey trunk and bare branches, moss hanging and swaying.
				var p := _at(rng, c, r * 0.25, r * 0.2) + Vector2(-r * 0.32 + i * r * 0.62, r * 0.45)
				var h := rng.randf_range(20.0, 26.0)
				ci.draw_rect(Rect2(p + Vector2(-6.0, -1.0), Vector2(13.0, 3.0)), _k(ts, "puddle"))
				ci.draw_rect(Rect2(p + Vector2(-2.0, -h), Vector2(4.0, h)), _k(ts, "trunk"))
				var top := p + Vector2(0.0, -h)
				ci.draw_line(top + Vector2(0.0, 6.0), top + Vector2(-9.0, -2.0), _k(ts, "branch"), 3.0)
				ci.draw_line(top + Vector2(-9.0, -2.0), top + Vector2(-11.0, -7.0), _k(ts, "branch"), 2.0)
				ci.draw_line(top + Vector2(1.0, 9.0), top + Vector2(10.0, 2.0), _k(ts, "branch"), 3.0)
				ci.draw_line(top + Vector2(10.0, 2.0), top + Vector2(13.0, -4.0), _k(ts, "branch"), 2.0)
				ci.draw_line(top + Vector2(0.0, 1.0), top + Vector2(2.0, -6.0), _k(ts, "branch"), 2.0)
				ci.draw_rect(Rect2(top + Vector2(-9.0 + f2, -1.0), Vector2(2.0, 6.0)), _k(ts, "moss"))
				ci.draw_rect(Rect2(top + Vector2(9.0 + f2, 3.0), Vector2(2.0, 7.0)), _k(ts, "moss"))
		BattleMap.Terrain.RUINS:
			for i in range(3):
				# A tombstone, round-topped, its shadow and its worn line.
				var p := _at(rng, c, r * 0.6, r * 0.42)
				ci.draw_rect(Rect2(p + Vector2(-2.0, 11.0), Vector2(14.0, 3.0)), _k(ts, "mound"))
				ci.draw_rect(Rect2(p + Vector2(0.0, 2.0), Vector2(10.0, 10.0)), _k(ts, "tomb"))
				ci.draw_circle(p + Vector2(5.0, 3.0), 5.0, _k(ts, "tomb"))
				ci.draw_rect(Rect2(p + Vector2(7.0, 2.0), Vector2(3.0, 10.0)), _k(ts, "tomb_shade"))
				ci.draw_rect(Rect2(p + Vector2(2.0, 5.0), Vector2(5.0, 2.0)), _k(ts, "tomb_dark"))
			var x := _at(rng, c, r * 0.35, r * 0.3)
			ci.draw_rect(Rect2(x + Vector2(4.0, -9.0), Vector2(4.0, 17.0)), _k(ts, "tomb"))
			ci.draw_rect(Rect2(x + Vector2(0.0, -5.0), Vector2(12.0, 4.0)), _k(ts, "tomb"))
			ci.draw_rect(Rect2(x + Vector2(6.0, -9.0), Vector2(2.0, 17.0)), _k(ts, "tomb_shade"))
			# A wisp of mist drifting over the graves.
			var m := _at(rng, c, r * 0.6, r * 0.5)
			ci.draw_rect(Rect2(m + Vector2(4.0 * f2, 0.0), Vector2(11.0, 2.0)), Color(_k(ts, "mist"), 0.75))
			ci.draw_rect(Rect2(m + Vector2(3.0 + 4.0 * f2, -3.0), Vector2(6.0, 2.0)), Color(_k(ts, "mist"), 0.55))


## The Peak: an ash plain with embers rising, basalt flagstones, a field of black crust split by
## glowing cracks, and charred ruins smoking.
static func _lava(ci: CanvasItem, c: Vector2, hex_px: float, r: float, t: int, rng: RandomNumberGenerator, frame: int, ts: Dictionary) -> void:
	var f2 := float(frame)
	match t:
		BattleMap.Terrain.PLAIN:
			for i in range(7):
				ci.draw_rect(Rect2(_at(rng, c, r, r * 0.75), Vector2(4.0, 2.0)), _k(ts, "ash"))
			for i in range(3):
				ci.draw_rect(Rect2(_at(rng, c, r * 0.8, r * 0.6), Vector2(6.0, 4.0)), _k(ts, "cinder"))
			for i in range(3):
				ci.draw_rect(Rect2(_at(rng, c, r * 0.7, r * 0.5) + Vector2(f2, -3.0 * f2), Vector2(3.0, 3.0)), _k(ts, "ember"))
		BattleMap.Terrain.ROAD:
			# Worn basalt flagstones, odd sizes and set loose, lit along their tops, the dark
			# joints showing between: paving, never courses that would read as a wall.
			for i in range(7):
				var p := _at(rng, c, r * 0.72, r * 0.6)
				var size := Vector2(rng.randf_range(8.0, 13.0), rng.randf_range(6.0, 9.0)).floor()
				ci.draw_rect(Rect2(p - size * 0.5 + Vector2(1.0, 1.0), size), _k(ts, "joint"))
				ci.draw_rect(Rect2(p - size * 0.5, size), _k(ts, "flag"))
				ci.draw_rect(Rect2(p - size * 0.5, Vector2(size.x, 2.0)), _k(ts, "flag_light"))
		BattleMap.Terrain.ROUGH:
			for i in range(3):
				ci.draw_rect(Rect2(_at(rng, c, r * 0.8, r * 0.6), Vector2(6.0, 4.0)), _k(ts, "crust"))
			for i in range(2):
				# A crack across the crust: a dark rim and the glow in it, brighter on the
				# second frame. The glow is the light one, never the hot orange: that folds into
				# the enemy red for a deutan.
				var p := _at(rng, c, r * 0.3, r * 0.2) + Vector2(-r * 0.62, -r * 0.3 + i * r * 0.6)
				var pts := PackedVector2Array([p])
				for k in range(4):
					p += Vector2(rng.randf_range(7.0, 11.0), rng.randf_range(-6.0, 6.0))
					pts.append(p.floor())
				ci.draw_polyline(pts, _k(ts, "rim"), 6.0)
				ci.draw_polyline(pts, _k(ts, "glow_hot") if frame == 1 else _k(ts, "glow"), 3.0)
		BattleMap.Terrain.RUINS:
			for i in range(2):
				# A charred wall, its top broken, and a smoke wisp rising from it.
				var p := _at(rng, c, r * 0.3, r * 0.2) + Vector2(-r * 0.6 + i * r * 0.6, r * 0.2)
				var w := rng.randf_range(15.0, 19.0)
				ci.draw_rect(Rect2(p + Vector2(0.0, -12.0), Vector2(w, 12.0)), _k(ts, "char"))
				ci.draw_rect(Rect2(p + Vector2(0.0, -17.0), Vector2(w * 0.45, 5.0)), _k(ts, "char"))
				ci.draw_rect(Rect2(p + Vector2(0.0, -17.0), Vector2(w * 0.45, 2.0)), _k(ts, "char_light"))
				ci.draw_rect(Rect2(p + Vector2(w * 0.55, -12.0), Vector2(w * 0.45, 2.0)), _k(ts, "char_light"))
				ci.draw_rect(Rect2(p + Vector2(w * 0.7, -7.0), Vector2(3.0, 4.0)), _k(ts, "rim"))
				ci.draw_rect(Rect2(p + Vector2(3.0, -21.0 - 3.0 * f2), Vector2(3.0, 3.0)), _k(ts, "smoke"))
				ci.draw_rect(Rect2(p + Vector2(6.0, -26.0 - 3.0 * f2), Vector2(3.0, 3.0)), _k(ts, "smoke"))

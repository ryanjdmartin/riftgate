class_name TerrainArt
extends RefCounted

## Procedural texture for terrain, drawn with a few primitives per hex so the map reads as
## ground rather than flat colour, and reused by the skirmish backdrop so a fight on rough
## ground looks like it. Deterministic per seed, so a hex never flickers between frames.

const COLOUR := {
	BattleMap.Terrain.PLAIN: Color("2a3628"),
	BattleMap.Terrain.ROAD: Color("46422f"),
	BattleMap.Terrain.ROUGH: Color("3a3824"),
	BattleMap.Terrain.RUINS: Color("393c39"),
	BattleMap.Terrain.WATER: Color("1a2f4a"),
	BattleMap.Terrain.MOUNTAIN: Color("23212a"),
}


static func colour(terrain: int) -> Color:
	return COLOUR.get(terrain, COLOUR[BattleMap.Terrain.PLAIN])


## The marks of one hex of terrain around `c`, within radius `r`, at `alpha`.
static func draw(ci: CanvasItem, c: Vector2, r: float, terrain: int, seed_value: int, alpha: float = 1.0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var base := colour(terrain)
	var light := Color(base.lightened(0.18), alpha)
	var dark := Color(base.darkened(0.28), alpha)
	if terrain == BattleMap.Terrain.PLAIN:
		# Tufts: short paired strokes, a few per hex.
		for i in range(5):
			var p := c + _in_hex(rng, r * 0.7)
			ci.draw_line(p, p + Vector2(-2.0, -4.0), light, 1.2)
			ci.draw_line(p + Vector2(2.0, 0.0), p + Vector2(3.0, -4.0), light, 1.2)
	elif terrain == BattleMap.Terrain.ROAD:
		# Two faint ruts running north to south, and a pothole.
		for dx in [-r * 0.28, r * 0.28]:
			ci.draw_line(c + Vector2(dx, -r * 0.8), c + Vector2(dx, r * 0.8), dark, 1.5)
		var p := c + _in_hex(rng, r * 0.4)
		ci.draw_circle(p, 2.5, dark)
	elif terrain == BattleMap.Terrain.ROUGH:
		# Rocks: small dark polygons with a lit top edge.
		for i in range(4):
			var p := c + _in_hex(rng, r * 0.7)
			var s := rng.randf_range(3.0, 6.0)
			var pts := PackedVector2Array([p + Vector2(-s, s * 0.5), p + Vector2(-s * 0.4, -s * 0.6), p + Vector2(s * 0.7, -s * 0.3), p + Vector2(s, s * 0.5)])
			ci.draw_colored_polygon(pts, dark)
			ci.draw_line(pts[1], pts[2], light, 1.2)
		for i in range(6):
			ci.draw_circle(c + _in_hex(rng, r * 0.8), 1.2, dark)
	elif terrain == BattleMap.Terrain.RUINS:
		# Rubble: broken rectangles and a wall stub.
		for i in range(3):
			var p := c + _in_hex(rng, r * 0.65)
			var w := rng.randf_range(5.0, 11.0)
			var h := rng.randf_range(3.0, 6.0)
			ci.draw_rect(Rect2(p, Vector2(w, h)), dark)
			ci.draw_rect(Rect2(p, Vector2(w, 1.2)), light)
		var q := c + _in_hex(rng, r * 0.5)
		ci.draw_rect(Rect2(q, Vector2(2.5, rng.randf_range(8.0, 14.0))), light)
	elif terrain == BattleMap.Terrain.WATER:
		# Ripples: short horizontal arcs, lighter.
		for i in range(4):
			var p := c + _in_hex(rng, r * 0.7)
			var w := rng.randf_range(6.0, 12.0)
			ci.draw_line(p, p + Vector2(w * 0.4, -1.5), light, 1.2)
			ci.draw_line(p + Vector2(w * 0.4, -1.5), p + Vector2(w, 0.0), light, 1.2)
	elif terrain == BattleMap.Terrain.MOUNTAIN:
		# A ridge: a dark peak with a lit face.
		var p := c + Vector2(rng.randf_range(-6.0, 6.0), rng.randf_range(2.0, 8.0))
		var peak := PackedVector2Array([p + Vector2(-r * 0.6, r * 0.35), p + Vector2(-r * 0.1, -r * 0.5), p + Vector2(r * 0.55, r * 0.35)])
		ci.draw_colored_polygon(peak, dark)
		ci.draw_colored_polygon(PackedVector2Array([peak[1], peak[2], p + Vector2(r * 0.2, r * 0.35)]), light)


## The battlefield's tile for each terrain (art/terrain/<name>.png), as the 3D map wears it.
const TILE := {
	BattleMap.Terrain.PLAIN: "dirt", BattleMap.Terrain.ROAD: "concrete",
	BattleMap.Terrain.ROUGH: "scrub", BattleMap.Terrain.RUINS: "rubble",
	BattleMap.Terrain.WATER: "water", BattleMap.Terrain.MOUNTAIN: "rock",
}
static var _tiles: Dictionary = {}


## A band of ground for the skirmish, in step with the map (Ryan, 21 September): the same
## terrain tile the 3D columns wear, dimmed, under the display's hex grid in the HUD colour,
## fading in from the band's edges. Falls back to the old marks with no tile.
static func draw_ground(ci: CanvasItem, rect: Rect2, terrain: int, seed_value: int, hex: float = 30.0) -> void:
	var name: String = TILE.get(terrain, "dirt")
	if not _tiles.has(name):
		var path := "res://art/terrain/%s.png" % name
		_tiles[name] = load(path) if ResourceLoader.exists(path) else null
	var tile: Texture2D = _tiles[name]
	if tile != null:
		ci.draw_texture_rect(tile, rect, true, Color(0.62, 0.62, 0.62, 1.0))
	else:
		ci.draw_rect(rect, Color(colour(terrain), 0.5))
	var w := sqrt(3.0) * hex
	var row := 0
	var y := rect.position.y + hex
	var k := 0
	while y < rect.end.y + hex:
		var x := rect.position.x + (w * 0.5 if row % 2 == 1 else 0.0)
		while x < rect.end.x + w:
			var c := Vector2(x, y)
			var edge := minf(c.y - rect.position.y, rect.end.y - c.y) / (rect.size.y * 0.5)
			var fade := clampf(edge * 1.6, 0.0, 1.0)
			if fade > 0.05:
				ci.draw_polyline(Hex.corners(c, hex - 1.5), Color(Palette.HUD, 0.28 * fade), 1.0, true)
				if tile == null:
					draw(ci, c, hex, terrain, seed_value + k * 7919, 0.55 * fade)
			x += w
			k += 1
		y += hex * 1.5
		row += 1
	# The band's edges soften into the panel, top and bottom.
	var steps := 6
	for i in range(steps):
		var a := 0.55 * (1.0 - float(i) / float(steps))
		var h := rect.size.y * 0.06
		ci.draw_rect(Rect2(rect.position.x, rect.position.y + i * h, rect.size.x, h), Color(Palette.BG, a))
		ci.draw_rect(Rect2(rect.position.x, rect.end.y - (i + 1) * h, rect.size.x, h), Color(Palette.BG, a))


static func _in_hex(rng: RandomNumberGenerator, r: float) -> Vector2:
	return Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.8, r * 0.8))

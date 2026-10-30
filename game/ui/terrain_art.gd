class_name TerrainArt
extends RefCounted

## Procedural texture for terrain, drawn with a few primitives per hex so the map reads as
## ground rather than flat colour (the other world's hexes are DomainGround's).
## Deterministic per seed, so a hex never flickers between frames.

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


## The battlefield's tile for each terrain (art/terrain/<name>.png), as the 3D map wears it;
## the skirmish's floor lays the same (HudBackdrop's floor).
const TILE := {
	BattleMap.Terrain.PLAIN: "dirt", BattleMap.Terrain.ROAD: "concrete",
	BattleMap.Terrain.ROUGH: "scrub", BattleMap.Terrain.RUINS: "rubble",
	BattleMap.Terrain.WATER: "water", BattleMap.Terrain.MOUNTAIN: "rock",
}


static func _in_hex(rng: RandomNumberGenerator, r: float) -> Vector2:
	return Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.8, r * 0.8))

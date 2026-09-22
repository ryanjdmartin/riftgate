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


## A band of ground for the skirmish (Ryan, 21 September: the fight is on the enemy's
## ground, or on the seam). Three styles:
##   "other":  the other world's flat bright overworld, two frames, under the foes.
##   "seam":   the reconstruction's tile with the other world eating into it from the top
##             edge through a dithered, pixel-stepped boundary, under the mechs.
##   "ground": the reconstruction's tile alone.
## All wear the display's hex grid in the HUD colour, fading from the band's edges.
static func draw_ground(ci: CanvasItem, rect: Rect2, terrain: int, seed_value: int, hex: float = 44.0, style: String = "ground", frame: int = 0, time: float = 0.0, marks: bool = true) -> void:
	var name: String = TILE.get(terrain, "dirt")
	if not _tiles.has(name):
		var path := "res://art/terrain/%s.png" % name
		_tiles[name] = load(path) if ResourceLoader.exists(path) else null
	var tile: Texture2D = _tiles[name]
	var w := sqrt(3.0) * hex
	if style == "other":
		_overworld(ci, rect, terrain, seed_value, hex, frame, marks)
		_tear(ci, rect, time)
	else:
		if tile != null:
			ci.draw_texture_rect(tile, rect, true, Color(0.62, 0.62, 0.62, 1.0))
		else:
			ci.draw_rect(rect, Color(colour(terrain), 0.5))
		if style == "seam":
			# The other world down to a fifth of the band, then a dithered edge of cells
			# where it and the tile trade places, the map's seam brought in close (Ryan, 22
			# September: higher, so more of the machines' own ground shows).
			var seam := rect.position.y + rect.size.y * 0.2
			var cell := 6.0
			var band := cell * 5.0
			_overworld(ci, Rect2(rect.position, Vector2(rect.size.x, seam - rect.position.y)), terrain, seed_value, hex, frame, marks)
			var cy := seam
			var row_i := 0
			while cy < seam + band:
				var cx := rect.position.x
				var col_i := 0
				var t := (cy - seam) / band   # 0 at the seam, 1 at the tile's own ground
				while cx < rect.end.x:
					if _bayer(col_i, row_i) > t:
						# This cell is still the other world: one cell of its flat colour.
						ci.draw_rect(Rect2(cx, cy, cell, cell), _other_fill(terrain, Vector2(cx, cy), seed_value))
					cx += cell
					col_i += 1
				cy += cell
				row_i += 1
	# The display's grid, faint, on the same lattice as the ground's own hexes.
	var row := 0
	var y := rect.position.y + hex * 0.5
	while y < rect.end.y + hex:
		var x := rect.position.x + (w * 0.5 if row % 2 == 1 else 0.0)
		while x < rect.end.x + w:
			var c := Vector2(x, y)
			var edge := minf(c.y - rect.position.y, rect.end.y - c.y) / (rect.size.y * 0.5)
			var fade := clampf(edge * 1.6, 0.0, 1.0)
			if fade > 0.05:
				ci.draw_polyline(Hex.corners(c, hex - 1.5), Color(Palette.HUD, 0.14 * fade), 1.0, true)
			x += w
		y += hex * 1.5
		row += 1
	# The band's edges soften into the panel, top and bottom.
	var steps := 6
	for i in range(steps):
		var a := 0.55 * (1.0 - float(i) / float(steps))
		var h := rect.size.y * 0.06
		ci.draw_rect(Rect2(rect.position.x, rect.position.y + i * h, rect.size.x, h), Color(Palette.BG, a))
		ci.draw_rect(Rect2(rect.position.x, rect.end.y - (i + 1) * h, rect.size.x, h), Color(Palette.BG, a))


## The corrupted side's tear, as the map's compositor does it: now and then one thin band
## darkens for a tick.
static func _tear(ci: CanvasItem, rect: Rect2, t: float) -> void:
	var tick := floorf(t * 6.0)
	var y := rect.position.y
	var band := 0
	while y < rect.end.y:
		var h := fmod(sin(float(band) * 12.9898 + tick * 7.31) * 43758.5453, 1.0)
		if absf(h) > 0.9985:
			ci.draw_rect(Rect2(rect.position.x, y, rect.size.x, 6.0), Color(0, 0, 0, 0.12))
		y += 6.0
		band += 1


## The other world's overworld across a rect: the painted map's hexes, its fills and
## marks, at its two-frame animation (shared with PaintedMap), on the display grid's lattice.
static func _overworld(ci: CanvasItem, rect: Rect2, terrain: int, seed_value: int, hex: float, frame: int, marks: bool = true) -> void:
	ci.draw_rect(rect, _other_fill(terrain, rect.position, seed_value))
	var w := sqrt(3.0) * hex
	var row := 0
	var y := rect.position.y + hex * 0.5
	var k := 0
	while y < rect.end.y + hex:
		var x := rect.position.x + (w * 0.5 if row % 2 == 1 else 0.0)
		while x < rect.end.x + w:
			draw_other_hex(ci, Vector2(x, y), hex, terrain, seed_value + k * 7919, frame, Rect2(), 0.18, marks)
			x += w
			k += 1
		y += hex * 1.5
		row += 1


static func _other_fill(terrain: int, _at: Vector2, _seed_value: int) -> Color:
	return OTHER.get(terrain, OTHER[BattleMap.Terrain.PLAIN])


static func _bayer(x: int, y: int) -> float:
	var m := [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
	return (float(m[y % 4][x % 4]) + 0.5) / 16.0


## The other world's palette: overworld colours, saturated on purpose, each ground its own
## fill so a tile reads as what it is when a picture covers its marks.
const OTHER := {
	BattleMap.Terrain.PLAIN: Color("48b038"),
	BattleMap.Terrain.ROAD: Color("e0c890"),
	BattleMap.Terrain.ROUGH: Color("1f6a22"),
	BattleMap.Terrain.RUINS: Color("9a9a8c"),
	BattleMap.Terrain.WATER: Color("2860e8"),
	BattleMap.Terrain.MOUNTAIN: Color("a8905a"),
}
const OTHER_GRID := Color("1a3a12")


## One hex of the other world: a flat bright fill and a few chunky marks at a coarse
## scale; the second frame nudges what moves (waves, leaves, grass, smoke). `clip`, when
## given, keeps marks inside a band.
static func draw_other_hex(ci: CanvasItem, c: Vector2, hex_px: float, t: int, seed_value: int, frame: int = 0, clip: Rect2 = Rect2(), grid_alpha: float = 0.35, marks: bool = true) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var base: Color = OTHER.get(t, OTHER[BattleMap.Terrain.PLAIN])
	var pts := Hex.corners(c, hex_px - 1.5)
	if clip.size != Vector2.ZERO and not clip.has_point(c):
		return
	ci.draw_colored_polygon(pts, base)
	var r := hex_px * 0.7
	var f2 := float(frame)
	# The skirmish's bands ask for no marks (Ryan, 22 September: a wall of mountains behind
	# the foes overwhelmed the view); the flat colour and the grid say what ground it is.
	match t if marks else -1:
		BattleMap.Terrain.PLAIN:
			for i in range(8):
				var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.75, r * 0.75))
				ci.draw_rect(Rect2(p.floor() + Vector2(2.0 * f2, 0.0), Vector2(3.0, 2.0)), Color("6ad04a"))
		BattleMap.Terrain.ROAD:
			ci.draw_colored_polygon(Hex.corners(c, hex_px - 6.0), Color("d4b878"))
			for i in range(6):
				var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.7, r * 0.7))
				ci.draw_rect(Rect2(p.floor(), Vector2(3.0, 2.0)), Color("b89858"))
		BattleMap.Terrain.ROUGH:
			for i in range(7):
				var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.7, r * 0.7))
				ci.draw_circle(p + Vector2(0.0, 3.0), 9.0, Color("144a14"))
				ci.draw_circle(p, 8.0, Color("2a8a28"))
				ci.draw_circle(p + Vector2(-2.0 + 3.0 * f2, -3.0), 4.0, Color("4cc040"))
		BattleMap.Terrain.RUINS:
			for i in range(3):
				var p := c + Vector2(rng.randf_range(-r, r * 0.5), rng.randf_range(-r * 0.6, r * 0.4))
				ci.draw_rect(Rect2(p, Vector2(13.0, 10.0)), Color("d8d8e0"))
				ci.draw_rect(Rect2(p + Vector2(-1.0, -4.0), Vector2(15.0, 5.0)), Color("c04030"))
				ci.draw_rect(Rect2(p + Vector2(5.0, 4.0), Vector2(3.0, 6.0)), Color("404050"))
				ci.draw_rect(Rect2(p + Vector2(10.0, -7.0 - 2.0 * f2), Vector2(2.0, 2.0)), Color("e8e8f0"))
		BattleMap.Terrain.WATER:
			Hud.stroke_poly(ci, Hex.corners(c, hex_px - 5.0), Color("7ab8ff"), 3.0)
			for i in range(6):
				var p := c + Vector2(rng.randf_range(-r * 0.8, r * 0.8), rng.randf_range(-r * 0.6, r * 0.6)) + Vector2(3.0 * f2, -2.0 * f2)
				ci.draw_rect(Rect2(p.floor(), Vector2(4.0, 2.0)), Color("a8d0ff"))
				ci.draw_rect(Rect2(p.floor() + Vector2(1.0, 2.0), Vector2(2.0, 1.0)), Color("1848b8"))
		BattleMap.Terrain.MOUNTAIN:
			for i in range(3):
				var p := c + Vector2(-r * 0.6 + i * r * 0.6, rng.randf_range(2.0, 10.0))
				var w := r * 0.55
				var peak := PackedVector2Array([p + Vector2(-w, w * 0.7), p + Vector2(0.0, -w * 1.1), p + Vector2(w, w * 0.7)])
				ci.draw_colored_polygon(peak, Color("6a4020"))
				ci.draw_colored_polygon(PackedVector2Array([peak[1], peak[2], p + Vector2(w * 0.2, w * 0.7)]), Color("a06a38"))
				ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-w * 0.3, -w * 0.45), p + Vector2(0.0, -w * 1.1), p + Vector2(w * 0.3, -w * 0.45)]), Color("f8f8f8"))
	Hud.stroke_poly(ci, pts, Color(OTHER_GRID, grid_alpha), 1.0)


static func _in_hex(rng: RandomNumberGenerator, r: float) -> Vector2:
	return Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.8, r * 0.8))

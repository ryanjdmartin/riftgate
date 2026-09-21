class_name PaintedMap
extends Control

## The battlefield painted flat, once, into a texture the size of the whole map, in one of
## two styles (Ryan, 20 September: the clash should jar).
##   "ground": the reconstruction's ground, gritty, muted, realistically coloured, fine grain
##             and cracks. The 3D columns' tops wear it (ground.gdshader).
##   "other":  the rift's world, an old overworld: flat, bright, saturated, chunky marks at
##             a coarse scale, no pretence of detail. The bleed shows it through.
## No structures and no units in either: the walls collapse into it and the foes are drawn
## over it.

var field: Battlefield
var origin := Vector2.ZERO
var hex_px: float = 44.0
var style := "ground"

## The other world's palette: overworld colours, saturated on purpose. Green carries no
## meaning in the palette rules, so it may be this green.
const OTHER := {
	BattleMap.Terrain.PLAIN: Color("48b038"),
	BattleMap.Terrain.ROAD: Color("e0c890"),
	BattleMap.Terrain.ROUGH: Color("2e8a2a"),
	BattleMap.Terrain.RUINS: Color("48b038"),
	BattleMap.Terrain.WATER: Color("2860e8"),
	BattleMap.Terrain.MOUNTAIN: Color("48b038"),
}
const OTHER_GRID := Color("1a3a12")


func setup(f: Battlefield, o: Vector2, hex_size: float, which: String = "ground") -> void:
	field = f
	origin = o
	hex_px = hex_size
	style = which
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if field == null:
		return
	var map := field.map
	for h in map.all_hexes():
		var c: Vector2 = origin + Hex.to_pixel(h, hex_px)
		var t: int = map.terrain[h]
		var seed_value: int = h.x * 131 + h.y * 7919
		# Opaque under the whole hex, so strokes blend and the ground samples true colours;
		# transparent outside, so the bleed's dither never shows off the map.
		draw_colored_polygon(Hex.corners(c, hex_px), Palette.BG)
		if style == "other":
			_draw_other(c, t, seed_value)
		else:
			_draw_ground(c, t, seed_value)


## The reconstruction's ground in the ally register (21 September): muted, realistically
## coloured, and chunky. This style is rendered at half resolution and sampled nearest, so
## every mark here is a block of at least two pixels; nothing thin, no grain.
func _draw_ground(c: Vector2, t: int, seed_value: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var base := TerrainArt.colour(t)
	var grey := Color(base.get_luminance(), base.get_luminance(), base.get_luminance())
	var muted := base.lerp(grey, 0.25)
	var light := muted.lightened(0.16)
	var dark := muted.darkened(0.3)
	var pts := Hex.corners(c, hex_px - 1.5)
	draw_colored_polygon(pts, muted)
	var r := hex_px * 0.72
	# A sparse speckle of blocks, the texel grain of the register.
	for i in range(10):
		var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.8, r * 0.8))
		draw_rect(Rect2(p.floor(), Vector2(3.0, 2.0)), light if rng.randf() < 0.5 else dark)
	match t:
		BattleMap.Terrain.ROAD:
			for dx in [-r * 0.3, r * 0.3]:
				draw_rect(Rect2(Vector2(c.x + dx - 1.5, c.y - r), Vector2(3.0, r * 2.0)), dark)
		BattleMap.Terrain.ROUGH:
			for i in range(4):
				var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.7, r * 0.7))
				draw_rect(Rect2(p, Vector2(7.0, 5.0)), dark)
				draw_rect(Rect2(p, Vector2(7.0, 2.0)), light)
		BattleMap.Terrain.RUINS:
			for i in range(3):
				var p := c + Vector2(rng.randf_range(-r, r * 0.6), rng.randf_range(-r * 0.6, r * 0.5))
				draw_rect(Rect2(p, Vector2(rng.randf_range(8.0, 14.0), 5.0)), dark)
				draw_rect(Rect2(p, Vector2(4.0, 2.0)), light)
		BattleMap.Terrain.WATER:
			for i in range(3):
				var p := c + Vector2(rng.randf_range(-r * 0.7, r * 0.5), -r * 0.5 + i * r * 0.5)
				draw_rect(Rect2(p.floor(), Vector2(12.0, 2.0)), light)
		BattleMap.Terrain.MOUNTAIN:
			var p := c + Vector2(0.0, 8.0)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-r * 0.7, r * 0.4), p + Vector2(0.0, -r * 0.6), p + Vector2(r * 0.7, r * 0.4)]), dark)
			draw_colored_polygon(PackedVector2Array([p + Vector2(0.0, -r * 0.6), p + Vector2(r * 0.7, r * 0.4), p + Vector2(r * 0.15, r * 0.4)]), light)
	Hud.stroke_poly(self, pts, Color(Palette.HUD, 0.12), 2.0)


## The overworld: a flat bright fill and a few chunky marks, drawn at a coarse scale.
func _draw_other(c: Vector2, t: int, seed_value: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var base: Color = OTHER[t]
	var pts := Hex.corners(c, hex_px - 1.5)
	draw_colored_polygon(pts, base)
	var r := hex_px * 0.7
	match t:
		BattleMap.Terrain.PLAIN:
			# Grass: a light speckle, the way the old overworld tiles shimmer.
			for i in range(8):
				var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.75, r * 0.75))
				draw_rect(Rect2(p.floor(), Vector2(3.0, 2.0)), Color("6ad04a"))
		BattleMap.Terrain.ROAD:
			# Sand: a beige patch with a darker rim and a few darker grains.
			draw_colored_polygon(Hex.corners(c, hex_px - 6.0), Color("d4b878"))
			for i in range(6):
				var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.7, r * 0.7))
				draw_rect(Rect2(p.floor(), Vector2(3.0, 2.0)), Color("b89858"))
		BattleMap.Terrain.ROUGH:
			# Forest: round canopies packed tight, dark undersides, a lit top on each.
			for i in range(7):
				var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.7, r * 0.7))
				draw_circle(p + Vector2(0.0, 3.0), 9.0, Color("144a14"))
				draw_circle(p, 8.0, Color("2a8a28"))
				draw_circle(p + Vector2(-2.0, -3.0), 4.0, Color("4cc040"))
		BattleMap.Terrain.RUINS:
			# A town: little roofs and walls on the grass.
			for i in range(3):
				var p := c + Vector2(rng.randf_range(-r, r * 0.5), rng.randf_range(-r * 0.6, r * 0.4))
				draw_rect(Rect2(p, Vector2(13.0, 10.0)), Color("d8d8e0"))
				draw_rect(Rect2(p + Vector2(-1.0, -4.0), Vector2(15.0, 5.0)), Color("c04030"))
				draw_rect(Rect2(p + Vector2(5.0, 4.0), Vector2(3.0, 6.0)), Color("404050"))
		BattleMap.Terrain.WATER:
			# Sea: a pale shore band and wave dots.
			Hud.stroke_poly(self, Hex.corners(c, hex_px - 5.0), Color("7ab8ff"), 3.0)
			for i in range(6):
				var p := c + Vector2(rng.randf_range(-r * 0.8, r * 0.8), rng.randf_range(-r * 0.6, r * 0.6))
				draw_rect(Rect2(p.floor(), Vector2(4.0, 2.0)), Color("a8d0ff"))
				draw_rect(Rect2(p.floor() + Vector2(1.0, 2.0), Vector2(2.0, 1.0)), Color("1848b8"))
		BattleMap.Terrain.MOUNTAIN:
			# A ridge: brown peaks in a row, dark faces, white tips.
			for i in range(3):
				var p := c + Vector2(-r * 0.6 + i * r * 0.6, rng.randf_range(2.0, 10.0))
				var w := r * 0.55
				var peak := PackedVector2Array([p + Vector2(-w, w * 0.7), p + Vector2(0.0, -w * 1.1), p + Vector2(w, w * 0.7)])
				draw_colored_polygon(peak, Color("6a4020"))
				draw_colored_polygon(PackedVector2Array([peak[1], peak[2], p + Vector2(w * 0.2, w * 0.7)]), Color("a06a38"))
				draw_colored_polygon(PackedVector2Array([p + Vector2(-w * 0.3, -w * 0.45), p + Vector2(0.0, -w * 1.1), p + Vector2(w * 0.3, -w * 0.45)]), Color("f8f8f8"))
	Hud.stroke_poly(self, pts, Color(OTHER_GRID, 0.35), 1.0)

class_name PaintedMap
extends Control

## The battlefield as the other world holds it: an old overworld, flat, bright, saturated,
## chunky marks at a coarse scale (Ryan, 20 September), drawn once into a texture the size
## of the whole map. The bleed shows it through (bleed.gdshader). No structures and no
## units: the walls collapse into it and the foes are drawn over it.

var field: Battlefield
var origin := Vector2.ZERO
var hex_px: float = 44.0
var frame: int = 0   # 0 or 1: the overworld's two-frame animation (Ryan, 21 September)

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


func setup(f: Battlefield, o: Vector2, hex_size: float, which_frame: int = 0) -> void:
	field = f
	origin = o
	hex_px = hex_size
	frame = which_frame
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if field == null:
		return
	var map := field.map
	var hexes: Array = map.all_hexes().duplicate()
	hexes.append_array(map.margin.keys())
	for h in hexes:
		var c: Vector2 = origin + Hex.to_pixel(h, hex_px)
		# Opaque under the whole hex, transparent outside, so the bleed's dither never
		# shows off the map.
		draw_colored_polygon(Hex.corners(c, hex_px), Palette.BG)
		_draw_other(c, map.terrain_of(h), h.x * 131 + h.y * 7919)


## The overworld: a flat bright fill and a few chunky marks, drawn at a coarse scale.
func _draw_other(c: Vector2, t: int, seed_value: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var base: Color = OTHER[t]
	var pts := Hex.corners(c, hex_px - 1.5)
	draw_colored_polygon(pts, base)
	var r := hex_px * 0.7
	var f2 := float(frame)   # the second frame nudges what moves: waves, leaves, grass
	match t:
		BattleMap.Terrain.PLAIN:
			# Grass: a light speckle, the way the old overworld tiles shimmer.
			for i in range(8):
				var p := c + Vector2(rng.randf_range(-r, r), rng.randf_range(-r * 0.75, r * 0.75))
				draw_rect(Rect2(p.floor() + Vector2(2.0 * f2, 0.0), Vector2(3.0, 2.0)), Color("6ad04a"))
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
				draw_circle(p + Vector2(-2.0 + 3.0 * f2, -3.0), 4.0, Color("4cc040"))   # the leaves turn
		BattleMap.Terrain.RUINS:
			# A town: little roofs and walls on the grass.
			for i in range(3):
				var p := c + Vector2(rng.randf_range(-r, r * 0.5), rng.randf_range(-r * 0.6, r * 0.4))
				draw_rect(Rect2(p, Vector2(13.0, 10.0)), Color("d8d8e0"))
				draw_rect(Rect2(p + Vector2(-1.0, -4.0), Vector2(15.0, 5.0)), Color("c04030"))
				draw_rect(Rect2(p + Vector2(5.0, 4.0), Vector2(3.0, 6.0)), Color("404050"))
				draw_rect(Rect2(p + Vector2(10.0, -7.0 - 2.0 * f2), Vector2(2.0, 2.0)), Color("e8e8f0"))   # chimney smoke rises
		BattleMap.Terrain.WATER:
			# Sea: a pale shore band and wave dots.
			Hud.stroke_poly(self, Hex.corners(c, hex_px - 5.0), Color("7ab8ff"), 3.0)
			for i in range(6):
				var p := c + Vector2(rng.randf_range(-r * 0.8, r * 0.8), rng.randf_range(-r * 0.6, r * 0.6)) + Vector2(3.0 * f2, -2.0 * f2)
				draw_rect(Rect2(p.floor(), Vector2(4.0, 2.0)), Color("a8d0ff"))   # the waves move
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

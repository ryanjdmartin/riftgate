class_name PaintedMap
extends Control

## The battlefield as the other world holds it: an old overworld, flat, bright, saturated,
## chunky marks at a coarse scale (Ryan, 20 September), drawn once into a texture the size
## of the whole map, one frame of two. The bleed shows it through (bleed.gdshader). The
## drawing itself lives in TerrainArt.draw_other_hex.

var field: Battlefield
var origin := Vector2.ZERO
var hex_px: float = 44.0
var frame: int = 0


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
		TerrainArt.draw_other_hex(self, c, hex_px, map.terrain_of(h), h.x * 131 + h.y * 7919, frame)

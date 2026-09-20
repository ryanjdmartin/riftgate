class_name PaintedMap
extends Control

## The battlefield as the other world holds it: the flat painted map, hex fills with the
## terrain marks and the grid, drawn once into a texture the size of the whole map. The 3D
## ground wears it (ground.gdshader) and the bleed shows it through (bleed.gdshader). No
## structures and no units: the walls collapse into it and the foes are drawn over it.

var field: Battlefield
var origin := Vector2.ZERO
var hex_px: float = 44.0


func setup(f: Battlefield, o: Vector2, hex_size: float) -> void:
	field = f
	origin = o
	hex_px = hex_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if field == null:
		return
	var map := field.map
	for h in map.all_hexes():
		var c: Vector2 = origin + Hex.to_pixel(h, hex_px)
		# Opaque under the whole hex, so the grid strokes blend and the 3D ground samples
		# true colours; transparent outside, so the bleed's dither never shows off the map.
		draw_colored_polygon(Hex.corners(c, hex_px), Palette.BG)
		var pts := Hex.corners(c, hex_px - 1.5)
		draw_colored_polygon(pts, TerrainArt.colour(map.terrain[h]))
		TerrainArt.draw(self, c, hex_px, map.terrain[h], h.x * 131 + h.y * 7919, 0.9)
		Hud.stroke_poly(self, pts, Color(Palette.HUD, 0.10), 1.0)

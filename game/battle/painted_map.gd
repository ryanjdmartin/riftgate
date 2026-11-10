class_name PaintedMap
extends Control

## The battlefield as the other world holds it: an old overworld, flat, bright, saturated,
## chunky marks at a coarse scale (Ryan, 20 September), drawn once into a texture the size
## of the whole map, one frame of two. The bleed shows it through (bleed.gdshader). The
## drawing itself lives in DomainGround.draw_hex, in the tileset of the battle's lead domain.

var field: Battlefield
var origin := Vector2.ZERO
var hex_px: float = 44.0
var frame: int = 0
var biome := ""   # the lead domain's bleed (DomainGround.biome_of): whose tileset it paints


func setup(f: Battlefield, o: Vector2, hex_size: float, which_frame: int = 0) -> void:
	field = f
	origin = o
	hex_px = hex_size
	frame = which_frame
	biome = DomainGround.biome_of(f)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if field == null:
		return
	var map := field.map
	var hexes: Array = map.all_hexes().duplicate()
	hexes.append_array(map.margin.keys())
	var walls: Array = []
	for h in hexes:
		var c: Vector2 = origin + MapOrient.to_pixel(h, hex_px)
		# Opaque under the whole hex, transparent outside, so the bleed's dither never
		# shows off the map.
		draw_colored_polygon(MapOrient.corners(c, hex_px), Palette.BG)
		var t := map.terrain_of(h)
		var links := DomainGround.road_links(map, h) if t == BattleMap.Terrain.ROAD else 0
		DomainGround.draw_hex(self, c, hex_px, t, h.x * 131 + h.y * 7919, frame, biome, links)
		if t == BattleMap.Terrain.MOUNTAIN:
			walls.append(h)
	# The walls' ranges stand taller than their hexes, so they go down last, the ones highest
	# on screen first, each in front of the ground and the ranges above it (in either view:
	# MapOrient).
	walls.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var pa := MapOrient.to_pixel(a, hex_px)
		var pb := MapOrient.to_pixel(b, hex_px)
		return pa.y < pb.y or (is_equal_approx(pa.y, pb.y) and pa.x < pb.x))
	for h in walls:
		DomainGround.draw_walls(self, origin + MapOrient.to_pixel(h, hex_px), hex_px, h.x * 131 + h.y * 7919, frame, biome, str(map.wall_look.get(h, BattleMap.WALL_LOOKS[0])))

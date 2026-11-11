class_name PaintedMap
extends Control

## The battlefield as the other world holds it: an old overworld, flat, bright, saturated,
## chunky marks at a coarse scale (Ryan, 20 September), drawn once into a texture the size
## of the whole map, one frame of two. The bleed shows it through (bleed.gdshader). The
## drawing itself lives in DomainGround.draw_hex, in the tileset of the battle's lead domain.
##
## The field and the scenery past it are told apart under the painting too (Ryan, 10 November:
## "need to make sure that the out-of-play areas on the flattened parts of the map are made
## clear"; every hex was painted alike, where the reconstruction has its grid on the field alone):
## a hex of the field is a bright cell with its dark edge; the scenery (the margin past the
## field's sides and past the rift, the city) is one unbroken ground with no cells, in shade
## (SCENERY_SHADE), its ranges with it. By structure and by lightness, never a hue.

## The scenery's shade, multiplied into everything painted past the field: hot, for the phone.
const SCENERY_SHADE := Color(0.36, 0.36, 0.42)

var field: Battlefield
var origin := Vector2.ZERO
var hex_px: float = 44.0
var frame: int = 0
var biome := ""   # the lead domain's bleed (DomainGround.biome_of): whose tileset it paints
var _scenery: Control = null   # the scenery's ground, behind the field's, shaded whole by its modulate


## The scenery's ground: a layer of its own behind the field's, so one modulate shades all of it
## evenly (a shade laid hex by hex over the paint doubles where two hexes' edges meet, and the
## cells come back as lines).
class Scenery extends Control:
	var painted: PaintedMap

	func _draw() -> void:
		if painted != null:
			painted.draw_ground(self, true)


func setup(f: Battlefield, o: Vector2, hex_size: float, which_frame: int = 0) -> void:
	field = f
	origin = o
	hex_px = hex_size
	frame = which_frame
	biome = DomainGround.biome_of(f)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _scenery == null:
		var sc := Scenery.new()
		sc.painted = self
		sc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sc.show_behind_parent = true
		sc.modulate = SCENERY_SHADE
		add_child(sc)
		_scenery = sc
	_scenery.size = size
	_scenery.queue_redraw()
	queue_redraw()


## Whether a hex is scenery: beside the field, never played on.
func is_scenery(h: Vector2i) -> bool:
	return not field.map.has(h)


## The ground of the field's hexes, or of the scenery's, onto `ci`.
func draw_ground(ci: CanvasItem, scenery: bool) -> void:
	var map := field.map
	var hexes: Array = map.margin.keys() if scenery else map.all_hexes()
	for h in hexes:
		if is_scenery(h) != scenery:
			continue
		var c: Vector2 = origin + MapOrient.to_pixel(h, hex_px)
		var t := map.terrain_of(h)
		# Opaque under the whole hex, transparent outside, so the bleed's dither never
		# shows off the map: the dark the field's cells are cut from, or the scenery's own
		# ground run a little past its hex, so no line parts one scenery hex from the next.
		if scenery:
			ci.draw_colored_polygon(MapOrient.corners(c, hex_px + 1.0), DomainGround.fill(biome, t))
		else:
			ci.draw_colored_polygon(MapOrient.corners(c, hex_px), Palette.BG)
		var links := DomainGround.road_links(map, h) if t == BattleMap.Terrain.ROAD else 0
		DomainGround.draw_hex(ci, c, hex_px, t, h.x * 131 + h.y * 7919, frame, biome, links, not scenery)


func _draw() -> void:
	if field == null:
		return
	var map := field.map
	draw_ground(self, false)
	var walls: Array = []
	var hexes: Array = []
	hexes.append_array(map.all_hexes())
	hexes.append_array(map.margin.keys())
	for h in hexes:
		if map.terrain_of(h) == BattleMap.Terrain.MOUNTAIN:
			walls.append(h)
	# The walls' ranges stand taller than their hexes, so they go down last, the ones highest
	# on screen first, each in front of the ground and the ranges above it (in either view:
	# MapOrient); the scenery's in its shade.
	walls.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var pa := MapOrient.to_pixel(a, hex_px)
		var pb := MapOrient.to_pixel(b, hex_px)
		return pa.y < pb.y or (is_equal_approx(pa.y, pb.y) and pa.x < pb.x))
	for h in walls:
		DomainGround.draw_walls(self, origin + MapOrient.to_pixel(h, hex_px), hex_px, h.x * 131 + h.y * 7919, frame, biome, SCENERY_SHADE if is_scenery(h) else Color.WHITE, str(map.wall_look.get(h, BattleMap.WALL_LOOKS[0])))

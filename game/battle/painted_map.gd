class_name PaintedMap
extends Control

## The battlefield as the other world holds it: an old overworld, flat, bright, saturated,
## chunky marks at a coarse scale (Ryan, 20 September), drawn once into a texture the size
## of the whole map, one frame of two. The bleed shows it through (bleed.gdshader). The
## drawing itself lives in DomainGround, in the tileset of the battle's lead domain, every hex at
## the reconstruction's own height (DomainGround.draw_columns; Ryan, 16 November: "Lock the
## painted world height change, its subtle but things make more sense").
##
## The field and the scenery past it are told apart under the painting too (Ryan, 10 November:
## "need to make sure that the out-of-play areas on the flattened parts of the map are made
## clear"; every hex was painted alike, where the reconstruction has its grid on the field alone):
## a hex of the field is a bright cell with its dark edge; the scenery (the margin past the
## field's sides and past the rift, the city) is ground with no cells, in shade (SCENERY_SHADE,
## multiplied into each of its hexes as it is drawn), its ranges with it. By structure and by
## lightness, never a hue.

## The scenery's shade, multiplied into everything painted past the field: hot, for the phone.
const SCENERY_SHADE := Color(0.36, 0.36, 0.42)

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


## Whether a hex is scenery: beside the field, never played on.
func is_scenery(h: Vector2i) -> bool:
	return not field.map.has(h)


## Every hex, the field's and the scenery's, on its own height over its banks, the farthest first,
## the walls' ranges among them (DomainGround.draw_columns), in either view (MapOrient).
func _draw() -> void:
	if field == null:
		return
	var map := field.map
	var cols: Array = []
	var every: Array = []
	every.append_array(map.all_hexes())
	every.append_array(map.margin.keys())
	for h in every:
		cols.append(DomainGround.column(map, h, origin + MapOrient.to_pixel(h, hex_px), hex_px, not is_scenery(h), SCENERY_SHADE if is_scenery(h) else Color.WHITE))
	DomainGround.draw_columns(self, cols, hex_px, frame, biome)

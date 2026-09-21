class_name Bleed
extends RefCounted

## The other world's bleed into the reconstruction (decided 19 September): how much of the
## third dimension is gone at a point of the map, from 0 (solid geometry) to 1 (the flat
## painted world). Two sources, and they stack: the rift's own bleed, a gradient that fades
## out south of it, and a radius around every squad that moves with it. The same function
## lives in `bleed.gdshader` for the pixels that turn 2D; keep the two identical.
##
## Later knobs: the gradient could grow with Rift Pressure, so the corruption spreads south
## as the clock runs.

const SQUAD_RADIUS_HEX := 1.45
const BOSS_RADIUS_HEX := 2.6
const RIFT_RADIUS_HEX := 2.6
const GRADIENT_ROWS := 5.0      # the rift's bleed is total on its row and gone this many rows south
const FLAT_AT := 0.42           # columns are fully collapsed by this much bleed, just before the seam
const MAX_SOURCES := 32         # the shader's array size


## Where the rift's gradient is total and where it is gone, as map-pixel y (no scroll).
static func gradient(field: Battlefield, origin: Vector2, hex_px: float) -> Vector2:
	var y_full := origin.y + Hex.to_pixel(field.map.rift, hex_px).y
	return Vector2(y_full, y_full + GRADIENT_ROWS * 1.5 * hex_px)


## The sources of bleed as (x, y, radius) in map pixels: the rift, then every squad.
static func sources(field: Battlefield, origin: Vector2, hex_px: float) -> PackedVector3Array:
	var out := PackedVector3Array()
	var r := origin + Hex.to_pixel(field.map.rift, hex_px)
	out.append(Vector3(r.x, r.y, RIFT_RADIUS_HEX * hex_px))
	for sq in field.squads():
		if out.size() >= MAX_SOURCES:
			break
		var p := origin + Hex.to_pixel(sq.pos, hex_px)
		out.append(Vector3(p.x, p.y, (BOSS_RADIUS_HEX if sq.is_multi_hex() else SQUAD_RADIUS_HEX) * hex_px))
	return out


## The bleed at a map pixel, 0 to 1.
static func at(px: Vector2, grad: Vector2, src: PackedVector3Array) -> float:
	var m := 1.0 - clampf((px.y - grad.x) / maxf(1.0, grad.y - grad.x), 0.0, 1.0)
	for s in src:
		var d := px.distance_to(Vector2(s.x, s.y))
		m = maxf(m, 1.0 - smoothstep(s.z * 0.55, s.z, d))
	return m


## How much of a prop's height still stands under this much bleed: 1 whole, 0 flat. Props
## are flat before the pixels turn 2D, so a mountain sinks into its painting, never sliced.
static func standing(bleed: float) -> float:
	return 1.0 - clampf(bleed / FLAT_AT, 0.0, 1.0)

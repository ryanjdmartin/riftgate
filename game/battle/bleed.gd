class_name Bleed
extends RefCounted

## The other world's bleed into the reconstruction (decided 19 September): how much of the
## third dimension is gone at a point of the map, from 0 (solid geometry) to 1 (the flat
## painted world). Two sources, and they stack: the rift's own bleed, a gradient that fades
## out south of it, and a radius around every pack that moves with it. The same function
## lives in `bleed.gdshader` for the pixels that turn 2D; keep the two identical.
##
## The gradient reaches the field's seam (Battlefield.seam_row), which creeps south a peak of
## Rift Pressure (the pacing session, 30 October): the flattening is the clock's picture, and
## the tears open on it; no rule reads the flattened hexes.

static var pack_radius_hex := 1.45   # a var, so the map tuner can move it live
const BOSS_RADIUS_HEX := 2.6
const RIFT_RADIUS_HEX := 2.6
const GRADIENT_ROWS := 5.0      # the rift's bleed is total on its row and gone this many rows south before the seam creeps (Battlefield.SEAM_START)
const FLAT_AT := 0.42           # columns are fully collapsed by this much bleed, just before the seam
const MAX_SOURCES := 32         # the shader's array size


## RIFTGATE_BLEED_DEBUG=1 (any run) gives the whole field to the painted world, to judge a
## domain's tileset in place (DomainGround).
static var everywhere := OS.get_environment("RIFTGATE_BLEED_DEBUG") == "1"


## Where the rift's gradient is total and where it is gone, as map-pixel y (no scroll).
static func gradient(field: Battlefield, origin: Vector2, hex_px: float) -> Vector2:
	if everywhere:
		return Vector2(1.0e7, 1.0e7 + 1.0)   # total down past the city
	var y_full := origin.y + Hex.to_pixel(field.map.rift, hex_px).y
	return Vector2(y_full, y_full + float(field.seam_row) * 1.5 * hex_px)


## The sources of bleed as (x, y, radius) in map pixels: the rift, then every pack.
## `moving` maps a unit id to its pixel offset from hex (0,0) while a move plays, so the
## bleed travels with a pack (Ryan, 22 September).
static func sources(field: Battlefield, origin: Vector2, hex_px: float, moving: Dictionary = {}) -> PackedVector3Array:
	var out := PackedVector3Array()
	var r := origin + Hex.to_pixel(field.map.rift, hex_px)
	out.append(Vector3(r.x, r.y, RIFT_RADIUS_HEX * hex_px))
	for sq in field.packs():
		if out.size() >= MAX_SOURCES:
			break
		var p: Vector2 = origin + (moving[sq.id] if moving.has(sq.id) else Hex.to_pixel(sq.pos, hex_px))
		out.append(Vector3(p.x, p.y, (BOSS_RADIUS_HEX if sq.is_multi_hex() else pack_radius_hex) * hex_px))
	return out


## The bleed at a map pixel, 0 to 1.
## How much of the reconstruction is left at a map pixel: 1 on solid ground, 0 under the
## painting, across the compositor's own threshold. The one place the question is answered
## (a flyer's height, a hex's lift, a mark's height all ask it).
static func solid(px: Vector2, grad: Vector2, src: PackedVector3Array) -> float:
	return 1.0 - smoothstep(0.42, 0.58, at(px, grad, src))


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

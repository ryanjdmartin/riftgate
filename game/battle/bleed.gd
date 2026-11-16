class_name Bleed
extends RefCounted

## The other world's bleed into the reconstruction (decided 19 September): how much of the
## third dimension is gone at a point of the map, from 0 (solid geometry) to 1 (the flat
## painted world). Two sources, and they stack: the rift's own bleed, a gradient that fades
## out south of it, and a radius around every pack that moves with it. The same function
## lives in `bleed.gdshader` for the pixels that turn 2D; keep the two identical.
##
## The gradient's edge is the field's seam (Battlefield.seam_row), which creeps toward the wall a
## peak of Rift Pressure (the pacing session, 30 October): the flattening is the clock's picture,
## and the tears open on it; no rule reads the flattened hexes. The painting takes the ground
## where the bleed is past half, so half is what stands on the seam: the seam's own row is the
## painting's front row and the row past it is solid (Ryan, 10 November: "The point of the seam
## was to visually represent where the tears can open"; the gradient once ran from total on the
## rift's row to nothing on the seam's, so the edge seen stood at half the seam's distance and a
## tear opened on ground that looked untouched).

## A pack's own bleed and the boss's, in hexes (the circle's outer edge; the painting stands out to
## about three quarters of it). Wide enough that a pack stands in its world with most of the hexes
## round it (Ryan, 16 November: "the effect is more subtle than I thought. Can we increase the
## bleed radius that surrounds enemy packs?"; at 1.45 the painting reached barely past the pack's
## own hex; at 3 it took the whole ring round it, then "Pull the enemy bleed radius back a bit"),
## the boss's a hex wider.
static var pack_radius_hex := 2.5   # a var, so the map tuner can move it live
const BOSS_RADIUS_HEX := 3.5
const RIFT_RADIUS_HEX := 2.6
const SEAM_RUN_ROWS := 4.0      # the rows the gradient falls over, half of them either side of the seam's edge: the dithered band about two thirds of a row wide, as it was at a battle's start
const FLAT_AT := 0.42           # columns are fully collapsed by this much bleed, just before the seam
const MAX_SOURCES := 32         # the shader's array size


## RIFTGATE_BLEED_DEBUG=1 (any run) gives the whole field to the painted world, to judge a
## domain's tileset in place (DomainGround).
static var everywhere := OS.get_environment("RIFTGATE_BLEED_DEBUG") == "1"


## The gradient's axis on the map: from the rift toward the wall, down the screen with the wall
## at the bottom and leftward with it at the left (MapOrient). `gradient` and the shader read a
## map pixel's place along it.
static func axis() -> Vector2:
	return -MapOrient.toward_rift()


## Where the rift's gradient is total and where it is gone, as places along `axis` (map pixels,
## no scroll): half either side of the seam's edge. `seam` is the row the map shows the seam on
## while its creep waits or plays (BattleMapView.seam_shown, a row and a part); under 0, the
## field's own.
static func gradient(field: Battlefield, origin: Vector2, hex_px: float, seam: float = -1.0) -> Vector2:
	if everywhere:
		return Vector2(1.0e7, 1.0e7 + 1.0)   # total down past the city
	var edge := seam_edge(field, origin, hex_px, seam)
	var half := SEAM_RUN_ROWS * 0.5 * 1.5 * hex_px
	return Vector2(edge - half, edge + half)


## The seam's edge as a place along `axis`: the far side of the seam's row from the rift, where
## its hexes meet the next row's, so the whole of the seam's row is the painting's.
static func seam_edge(field: Battlefield, origin: Vector2, hex_px: float, seam: float = -1.0) -> float:
	var row := seam if seam >= 0.0 else float(field.seam_row)
	return (origin + MapOrient.to_pixel(field.map.rift, hex_px)).dot(axis()) + (row + 0.5) * 1.5 * hex_px


## The sources of bleed as (x, y, radius) in map pixels: the rift, then every pack.
## `moving` maps a unit id to its pixel offset from hex (0,0) while a move plays, so the
## bleed travels with a pack (Ryan, 22 September).
static func sources(field: Battlefield, origin: Vector2, hex_px: float, moving: Dictionary = {}) -> PackedVector3Array:
	var out := PackedVector3Array()
	var r := origin + MapOrient.to_pixel(field.map.rift, hex_px)
	out.append(Vector3(r.x, r.y, RIFT_RADIUS_HEX * hex_px))
	for sq in field.packs():
		if out.size() >= MAX_SOURCES:
			break
		var p: Vector2 = origin + (moving[sq.id] if moving.has(sq.id) else MapOrient.to_pixel(sq.pos, hex_px))
		out.append(Vector3(p.x, p.y, (BOSS_RADIUS_HEX if sq.is_multi_hex() else pack_radius_hex) * hex_px))
	return out


## The bleed at a map pixel, 0 to 1.
## How much of the reconstruction is left at a map pixel: 1 on solid ground, 0 under the
## painting, across the compositor's own threshold. The one place the question is answered
## (a flyer's height, a hex's lift, a mark's height all ask it).
static func solid(px: Vector2, grad: Vector2, src: PackedVector3Array) -> float:
	return 1.0 - smoothstep(0.42, 0.58, at(px, grad, src))


static func at(px: Vector2, grad: Vector2, src: PackedVector3Array) -> float:
	var m := 1.0 - clampf((px.dot(axis()) - grad.x) / maxf(1.0, grad.y - grad.x), 0.0, 1.0)
	for s in src:
		var d := px.distance_to(Vector2(s.x, s.y))
		m = maxf(m, 1.0 - smoothstep(s.z * 0.55, s.z, d))
	return m


## How much of a prop's height still stands under this much bleed: 1 whole, 0 flat. Props
## are flat before the pixels turn 2D, so a mountain sinks into its painting, never sliced.
static func standing(bleed: float) -> float:
	return 1.0 - clampf(bleed / FLAT_AT, 0.0, 1.0)

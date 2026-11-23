class_name Bleed
extends RefCounted

## The other world's bleed into the reconstruction (decided 19 September): how much of the
## third dimension is gone at a point of the map, from 0 (solid geometry) to 1 (the flat
## painted world). Three sources, and they stack: the seam, a circle about the rift that grows
## a round; a radius around every pack that moves with it; and a radius round every tear. The
## same function lives in `bleed.gdshader` for the pixels that turn 2D; keep the two identical.
##
## The seam is a picture and nothing else (Ryan, 23 November: "I think the seam should be
## circular, radiating out from the rift. Same as the packs do, just bigger, and expanding. It
## should start with a radius that encompasses the boss shield, and maybe one or two hexes around
## it"; "the seam should move every round, but not a big fuss about it"; "The seam is visual only.
## Tears are still spawned by the same logic they are now. Tears have their own dither radius,
## larger than a pack"): no rule reads the flattened hexes, the tears open by their own row
## (Battlefield.tear_row), and the painting stops at the wall's foot however far the circle has
## grown. The painting takes the ground where the bleed is past half, so half is what stands on
## the circle's edge. The form it retires: an edge straight across the field on the tears' row,
## creeping two rows a peak under a sweep and a plaque (30 October; 10 November: "The point of the
## seam was to visually represent where the tears can open"), which tied the picture to a rule.

## A pack's own bleed and the boss's, in hexes (the circle's outer edge; the painting stands out to
## about three quarters of it). Wide enough that a pack stands in its world with most of the hexes
## round it (Ryan, 16 November: "the effect is more subtle than I thought. Can we increase the
## bleed radius that surrounds enemy packs?"; at 1.45 the painting reached barely past the pack's
## own hex; at 3 it took the whole ring round it, then "Pull the enemy bleed radius back a bit"),
## the boss's a hex wider.
static var pack_radius_hex := 2.5   # a var, so the map tuner can move it live
const BOSS_RADIUS_HEX := 3.5
const RIFT_RADIUS_HEX := 2.6
## A tear's own bleed, in the same measure: larger than a pack's, its painting out over the ring
## round its hex and most of the ring past that. A placeholder for his eye (the map tuner's TEAR).
static var tear_radius_hex := 4.0
## The seam, in hex steps (a hex's centre to its neighbour's) from the rift's middle to the
## painting's edge: where it stands as a battle opens, and how far it moves out a round. The
## shell's seven hexes reach two steps out and their far corners a little over two and a half, so
## four leaves a hex and a half of painting round them. Placeholders for his eye (the map
## tuner's SEAM and SEAM GROW).
static var seam_start_hex := 4.0
static var seam_grow_hex := 0.5
const SEAM_RUN_HEX := 3.4       # the hex steps the seam's edge falls over, half of them either side of it: the dithered band about two thirds of a row wide, as it has been
const WALL_RUN_ROWS := 1.0      # the rows the painting's stop at the wall falls over
const MAX_SOURCES := 32         # the shader's array size


## RIFTGATE_BLEED_DEBUG=1 (any run) gives the whole field to the painted world, to judge a
## domain's tileset in place (DomainGround).
static var everywhere := OS.get_environment("RIFTGATE_BLEED_DEBUG") == "1"


## The axis from the rift toward the wall on the map: down the screen with the wall at the bottom
## and leftward with it at the left (MapOrient). `wall` and the shader read a map pixel's place
## along it.
static func axis() -> Vector2:
	return -MapOrient.toward_rift()


## Where the seam's painting stops, as places along `axis` (map pixels, no scroll): whole on the
## field's side and gone past the far side of the row before the wall, so the wall and the city
## stand in the reconstruction whatever the circle has reached.
static func wall(field: Battlefield, origin: Vector2, hex_px: float) -> Vector2:
	if everywhere:
		return Vector2(1.0e7, 1.0e7 + 1.0)   # whole down past the city
	var edge := (origin + MapOrient.to_pixel(field.map.rift, hex_px)).dot(axis()) + (float(field.apron_row()) + 0.5) * 1.5 * hex_px
	var half := WALL_RUN_ROWS * 0.5 * 1.5 * hex_px
	return Vector2(edge - half, edge + half)


## The seam's radius in map pixels at `turn` (a turn and a part, while its growth plays:
## BattleMapView.seam_shown); under 0, the field's own turn.
static func seam_radius(field: Battlefield, hex_px: float, turn: float = -1.0) -> float:
	var t := turn if turn >= 0.0 else float(field.phase)
	return (seam_start_hex + seam_grow_hex * t) * sqrt(3.0) * hex_px


## The seam's circle: its centre (the rift's middle), its radius and the run its edge falls over,
## in map pixels.
static func seam(field: Battlefield, origin: Vector2, hex_px: float, turn: float = -1.0) -> Vector4:
	var c := origin + MapOrient.to_pixel(field.map.rift, hex_px)
	if everywhere:
		return Vector4(c.x, c.y, 1.0e7, 1.0)
	return Vector4(c.x, c.y, seam_radius(field, hex_px, turn), SEAM_RUN_HEX * sqrt(3.0) * hex_px)


## The sources of bleed as (x, y, radius) in map pixels: the rift, then the tears, then every
## pack. `moving` maps a unit id to its pixel offset from hex (0,0) while a move plays, so the
## bleed travels with a pack (Ryan, 22 September). `tears` is how many of the field's tears are
## shown (BattleMapView.tears_shown: one opened this turn waits for its opening); under 0, all.
static func sources(field: Battlefield, origin: Vector2, hex_px: float, moving: Dictionary = {}, tears: int = -1) -> PackedVector3Array:
	var out := PackedVector3Array()
	var r := origin + MapOrient.to_pixel(field.map.rift, hex_px)
	out.append(Vector3(r.x, r.y, RIFT_RADIUS_HEX * hex_px))
	var n := field.tears.size() if tears < 0 else mini(tears, field.tears.size())
	for i in range(n):
		if out.size() >= MAX_SOURCES:
			break
		var t: Vector2 = origin + MapOrient.to_pixel(field.tears[i]["pos"], hex_px)
		out.append(Vector3(t.x, t.y, tear_radius_hex * hex_px))
	for sq in field.packs():
		if out.size() >= MAX_SOURCES:
			break
		var p: Vector2 = origin + (moving[sq.id] if moving.has(sq.id) else MapOrient.to_pixel(sq.pos, hex_px))
		out.append(Vector3(p.x, p.y, (BOSS_RADIUS_HEX if sq.is_multi_hex() else pack_radius_hex) * hex_px))
	return out


## How much of the reconstruction is left at a map pixel: 1 on solid ground, 0 under the
## painting, across the compositor's own threshold. The one place the question is answered
## (a flyer's height, a hex's lift, a mark's height all ask it).
static func solid(px: Vector2, wall_clip: Vector2, seam_circle: Vector4, src: PackedVector3Array) -> float:
	return 1.0 - smoothstep(0.42, 0.58, at(px, wall_clip, seam_circle, src))


## The bleed at a map pixel, 0 to 1: the seam's circle, cut off at the wall, and every source.
static func at(px: Vector2, wall_clip: Vector2, seam_circle: Vector4, src: PackedVector3Array) -> float:
	var held := 1.0 - clampf((px.dot(axis()) - wall_clip.x) / maxf(1.0, wall_clip.y - wall_clip.x), 0.0, 1.0)
	var ring := 1.0 - clampf((px.distance_to(Vector2(seam_circle.x, seam_circle.y)) - (seam_circle.z - seam_circle.w * 0.5)) / maxf(1.0, seam_circle.w), 0.0, 1.0)
	var m := minf(held, ring)
	for s in src:
		var d := px.distance_to(Vector2(s.x, s.y))
		m = maxf(m, 1.0 - smoothstep(s.z * 0.55, s.z, d))
	return m

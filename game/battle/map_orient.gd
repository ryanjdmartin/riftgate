class_name MapOrient
extends RefCounted

## The battle map's orientation, a view setting (the long wall brief 7.1; Ryan, 6 November: "a
## purely visual option between wall left + gate right and wall bottom + gate top. Just because
## some people like playing up instead of sideways"): the wall at the left with the rift at the
## right (flat-top hexes, the wall a straight column, the scroll down the wall), or the wall at
## the bottom with the rift at the top (pointy-top, the scroll along the wall). One field and one
## sim; the view turns. Every hex the battle map draws, paints, builds in 3D or reads a finger on
## goes through here, so the overlays, the painted world, the reconstruction and the gestures
## turn together. The setting is Settings.map_view; the screen sets `wall_left` from it before
## it builds a map. The default is the wall at the left (a placeholder: Ryan's call, the brief's
## open item 7, judged on the phone).

static var wall_left := true


## The setting onto the view (Settings.map_view), or RIFTGATE_MAP_VIEW=left|bottom for a run (the
## screenshot tool, a test of both). A screen calls it before it builds a map.
static func apply_setting() -> void:
	Settings.apply()
	var forced := OS.get_environment("RIFTGATE_MAP_VIEW")
	if forced == "left" or forced == "bottom":
		wall_left = forced == "left"
		return
	wall_left = str(Settings.display.get("map_view", "wall_left")) != "wall_bottom"


## A hex's centre in the view's map pixels, before the view's origin.
static func to_pixel(h: Vector2i, size: float) -> Vector2:
	return Hex.to_pixel_flat(h, size) if wall_left else Hex.to_pixel(h, size)


static func from_pixel(p: Vector2, size: float) -> Vector2i:
	return Hex.from_pixel_flat(p, size) if wall_left else Hex.from_pixel(p, size)


static func corners(center: Vector2, size: float) -> PackedVector2Array:
	return Hex.corners_flat(center, size) if wall_left else Hex.corners(center, size)


## A vector laid out for the pointy-top view (the rift up, the wall down) into this view.
static func turn(v: Vector2) -> Vector2:
	return Hex.turn(v) if wall_left else v


## The view's unit vector from the wall toward the rift: up the screen with the wall at the
## bottom, rightward with it at the left.
static func toward_rift() -> Vector2:
	return turn(Vector2(0.0, -1.0))


## A model's yaw on the 3D map turned with the view: the pixel plane turns a quarter clockwise,
## so a yaw laid out for the wall at the bottom loses a quarter turn (Map3D.facing_yaw's sign).
static func yaw(base: float) -> float:
	return base - PI * 0.5 if wall_left else base

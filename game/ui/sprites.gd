class_name Sprites
extends RefCounted

## Finds sprite art for chassis and foe ids under res://art. Everything is optional: a missing
## file returns null and the views fall back to their placeholder shapes, so content can be
## added before its art exists.
##
## Layout on disk (all transparent PNGs, imported with nearest filtering):
##   art/mechs/<chassis>_combat_front.png          48x64 combat sprite, facing the camera (3x on screen)
##   art/mechs/<chassis>_combat_front_left.png     three-quarter turns (optional)
##   art/mechs/<chassis>_combat_front_right.png
##   art/mechs/<chassis>_map_strip.png             six 24x28 map frames in Hex.DIRECTIONS order
##   art/foes/<foe>_combat.png                     enemy combat sprite (optional)
##   art/foes/<foe>_map.png                        enemy map sprite, one frame (optional)

const MAP_FRAME := Vector2i(24, 28)
const FACINGS := 6

static var _cache: Dictionary = {}


static func combat_mech(chassis_id: String, turn: String = "front") -> Texture2D:
	return _load("res://art/mechs/%s_combat_%s.png" % [chassis_id, turn])


static func combat_foe(foe_id: String) -> Texture2D:
	return _load("res://art/foes/%s_combat.png" % foe_id)


## One frame of a mech's map strip for a facing index (0..5, Hex.DIRECTIONS order).
static func map_mech(chassis_id: String, facing: int) -> Texture2D:
	var key := "map:%s:%d" % [chassis_id, facing]
	if _cache.has(key):
		return _cache[key]
	var strip := _load("res://art/mechs/%s_map_strip.png" % chassis_id)
	var tex: Texture2D = null
	if strip != null:
		var frames := int(strip.get_width()) / MAP_FRAME.x
		var at := AtlasTexture.new()
		at.atlas = strip
		at.region = Rect2(Vector2((posmod(facing, FACINGS) % maxi(1, frames)) * MAP_FRAME.x, 0), Vector2(MAP_FRAME))
		tex = at
	_cache[key] = tex
	return tex


static func map_foe(foe_id: String) -> Texture2D:
	return _load("res://art/foes/%s_map.png" % foe_id)


static func _load(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	_cache[path] = tex
	return tex

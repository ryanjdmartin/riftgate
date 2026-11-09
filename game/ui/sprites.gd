class_name Sprites
extends RefCounted

## Finds sprite art for foe ids under res://art. Everything is optional: a missing file
## returns null and the views fall back to their placeholder shapes, so content can be
## added before its art exists. Mechs are models (art/models, `MechView3D`), never sprites;
## the mech sprite loaders went on 22 September.
##
## Layout on disk (all transparent PNGs, imported with nearest filtering):
##   art/foes/<foe>_combat.png                     enemy combat sprite (optional)
##   art/foes/<foe>_map.png                        enemy map sprite, one frame (optional)
##   art/loot/<kind>_map.png                       a cache's map token, for flattened ground (optional)

static var _cache: Dictionary = {}


static func combat_foe(foe_id: String) -> Texture2D:
	return _foe("res://art/foes/%s_combat.png", foe_id)


static func map_foe(foe_id: String) -> Texture2D:
	return _foe("res://art/foes/%s_map.png", foe_id)


## A foe's art, or a promoted form's hero's while it has none of its own (its boss register
## waits on Ryan's picks).
static func _foe(pattern: String, foe_id: String) -> Texture2D:
	var tex := _load(pattern % foe_id)
	if tex == null:
		var base := str(ContentDB.load_default().foes.get(foe_id, {}).get("promotes", ""))
		if not base.is_empty():
			tex = _load(pattern % base)
	return tex


## A cache's flat token, for a hex the painting has taken (tools/loot_tokens.py), or null.
static func map_cache(kind: String) -> Texture2D:
	return _load("res://art/loot/%s_map.png" % kind)


## The rift on the map: a strip of three frames (tools/foeforge `cut-rift`), or null.
static func rift() -> Texture2D:
	return _load("res://art/terrain/rift.png")


## The opaque part of a sprite, in texture pixels, so views can hug the drawing rather than
## the frame. Falls back to the whole texture when the image cannot be read.
static func used_rect(tex: Texture2D) -> Rect2:
	if tex == null:
		return Rect2()
	var key := "used:%d" % tex.get_instance_id()
	if _cache.has(key):
		return _cache[key]
	var rect := Rect2(Vector2.ZERO, tex.get_size())
	var img := tex.get_image()
	if img != null and not img.is_empty():
		var used := img.get_used_rect()
		if used.size.x > 0 and used.size.y > 0:
			rect = Rect2(used.position, used.size)
		_cache[key] = rect
	# A viewport texture has no image until its first frame; do not cache the whole-frame
	# fallback, so the next look gets the real drawing.
	return rect


static func _load(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	_cache[path] = tex
	return tex

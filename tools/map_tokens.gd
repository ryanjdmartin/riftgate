extends SceneTree

## Map tokens from the 3D model: renders art/models/<chassis>.glb in the pixel look at the
## map frame (24x28) from the six hex facings and writes art/mechs/<chassis>_map_strip.png,
## the strip Sprites.map_mech reads. Replaces the spriter's strip for a chassis that has a
## model, so the token on the battlefield is the same machine as the mech in the skirmish.
## Needs a window (the dummy renderer draws nothing); then --import.
##   godot --path . --resolution 360x640 -s tools/map_tokens.gd -- badger [anvil ...]
## Also writes tools/blendforge/out/<chassis>_tokens.png, the strip at 4x, to look at.

const PITCH := 42.0   # the spriter's map tilt: steeper than the combat view, reads from above
# Godot yaw per facing in Hex.DIRECTIONS order (E, NE, NW, W, SW, SE). The view's yaw 0 faces
# the camera (south, down the screen); the spriter's yaw 0 faces north, hence the 180.
const YAWS := [90.0, 150.0, 210.0, 270.0, 330.0, 30.0]
const SETTLE_FRAMES := 4

var _ids: Array = []
var _views: Array = []   # per chassis: Array[MechView3D]
var _frames := 0


func _init() -> void:
	_ids = OS.get_cmdline_user_args()
	if _ids.is_empty():
		_ids = ["badger"]
	var db := ContentDB.load_default()
	for id in _ids:
		if not MechView3D.has_model(id):
			push_error("no model for %s (art/models/%s.glb)" % [id, id])
			quit(2)
			return
		var maker := str(db.chassis.get(id, {}).get("maker", "minerva"))
		var row: Array = []
		for yaw in YAWS:
			var v := MechView3D.new()
			v.mode = "pixel"
			v.yaw = yaw
			v.pitch = PITCH
			v.token = true
			v.frame_override = Sprites.MAP_FRAME
			v._setup(id, maker)
			root.add_child(v)
			row.append(v)
		_views.append(row)
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames < SETTLE_FRAMES:
		return
	process_frame.disconnect(_tick)
	var w := Sprites.MAP_FRAME.x
	var h := Sprites.MAP_FRAME.y
	for k in range(_ids.size()):
		var strip := Image.create(w * 6, h, false, Image.FORMAT_RGBA8)
		for i in range(6):
			var img: Image = (_views[k][i] as MechView3D).texture.get_image()
			img.convert(Image.FORMAT_RGBA8)
			strip.blit_rect(img, Rect2i(0, 0, w, h), Vector2i(i * w, 0))
		var out := "res://art/mechs/%s_map_strip.png" % _ids[k]
		var err := strip.save_png(out)
		print("saved %s (%s)" % [out, error_string(err)])
		var big := strip.duplicate()
		big.resize(w * 6 * 4, h * 4, Image.INTERPOLATE_NEAREST)
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/blendforge/out"))
		big.save_png("res://tools/blendforge/out/%s_tokens.png" % _ids[k])
	quit(0)

extends SceneTree

## Battlefield sprites for the structures: the gate (three hexes wide) and a wall segment
## (one hex), rendered from art/models/<name>.glb in the pixel look from the map's angle
## (pitch 42, facing north, so the player sees the south face) and written to
## art/structures/<name>.png at map scale (a hex is 24 px wide in the art, drawn at 2x).
## Needs a window; then --import.
##   godot --path . --resolution 360x640 -s tools/structure_sprites.gd

const PITCH := 42.0
const YAW := 180.0   # facing north, away from the camera
## Widths set the hex scale (three hexes and one); heights follow each model's projected
## aspect at this pitch, so the fit is tight both ways and the sprite stands on its hex.
const FRAMES := {"gate": Vector2i(92, 70), "wall": Vector2i(31, 48)}
const SETTLE := 4

var _views: Dictionary = {}
var _frames := 0


func _init() -> void:
	for name in FRAMES.keys():
		if not MechView3D.has_model(name):
			push_error("no model for %s; run forge.py structures first" % name)
			quit(2)
			return
		var v := MechView3D.new()
		v.mode = "pixel"
		v.yaw = YAW
		v.pitch = PITCH
		v.token = true
		v.hide_detail = false
		v.frame_override = FRAMES[name]
		v._setup(name, "arsenal")
		root.add_child(v)
		_views[name] = v
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames < SETTLE:
		return
	process_frame.disconnect(_tick)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://art/structures"))
	for name in _views.keys():
		var img: Image = (_views[name] as MechView3D).texture.get_image()
		img.convert(Image.FORMAT_RGBA8)
		var out := "res://art/structures/%s.png" % name
		print("saved %s (%s)" % [out, error_string(img.save_png(out))])
	quit(0)

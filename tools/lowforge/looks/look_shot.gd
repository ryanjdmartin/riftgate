extends SceneTree

## A look test through the game's own 3D view, as tools/hero_shot.gd, with the camera's
## pitch settable so a machine can be seen from above as the map sees it.
##   godot --path . -s tools/lowforge/looks/look_shot.gd -- <model> <maker> out.png <yaw> <pitch> <width> <height>
## Yaw 45 and pitch 30 are the codex angle; yaw 180 and pitch 75 show it from above, nose up.

var _frames := 0
var _view: MechView3D
var _out := "look.png"


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	_out = a[2]
	_view = MechView3D.make(a[0], a[1], "clean", "badger", float(a[3]), Vector2i(int(a[5]), int(a[6])), false, {}, [])
	_view.pitch = float(a[4])
	_view.strip_silhouette()
	root.add_child(_view)
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames < 8:
		return
	var err := _view.get_texture().get_image().save_png(_out)
	print("saved %s (%s)" % [_out, "OK" if err == OK else str(err)])
	quit(0)

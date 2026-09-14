extends SceneTree

## Renders a scene into a 720x1280 offscreen viewport and saves a PNG. Needs a window
## (not headless) because the dummy renderer produces no pixels.
##   godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn out.png

var _frames := 0
var _vp: SubViewport
var _out := "screenshot.png"


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var scene_path := "res://game/skirmish/skirmish_screen.tscn"
	if args.size() >= 1:
		scene_path = args[0]
	if args.size() >= 2:
		_out = args[1]
	_vp = SubViewport.new()
	_vp.size = Vector2i(720, 1280)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("cannot load %s" % scene_path)
		quit(2)
		return
	_vp.add_child(scene.instantiate())
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames < 6:
		return
	process_frame.disconnect(_tick)
	var img := _vp.get_texture().get_image()
	var err := img.save_png(_out)
	print("saved %s (%s)" % [_out, error_string(err)])
	quit(0 if err == OK else 1)

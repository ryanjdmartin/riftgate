extends SceneTree

## Renders a scene into a 720x1280 offscreen viewport and saves a PNG. Needs a window
## (not headless) because the dummy renderer produces no pixels.
##   godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn out.png [pose]
## Poses put the skirmish screen into a state before the capture: codex (a foe's entry),
## mechcodex, diecodex, hold (a die's readout), confirm (the end-turn question), lock.

var _frames := 0
var _vp: SubViewport
var _out := "screenshot.png"
var _pose := ""
var _node: Node


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var scene_path := "res://game/skirmish/skirmish_screen.tscn"
	if args.size() >= 1:
		scene_path = args[0]
	if args.size() >= 2:
		_out = args[1]
	if args.size() >= 3:
		_pose = args[2]
	_vp = SubViewport.new()
	_vp.size = Vector2i(720, 1280)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("cannot load %s" % scene_path)
		quit(2)
		return
	_node = scene.instantiate()
	_vp.add_child(_node)
	process_frame.connect(_tick)


func _apply_pose() -> void:
	if _pose.is_empty() or not (_node is SkirmishScreen):
		return
	var s: SkirmishScreen = _node
	match _pose:
		"codex":
			s._on_foe_double_tapped(s._foe_view_for(s.sk.front[0]))
		"mechcodex":
			s._on_mech_double_tapped(0)
		"diecodex":
			s._on_die_double_tapped(1)
		"hold":
			s._on_die_held(1)
		"confirm":
			s._on_end_turn()
		"lock":
			s._on_die_tapped(0)
			s._toggle_all_arrows(true)


func _tick() -> void:
	_frames += 1
	if _frames == 2:
		_apply_pose()
	if _frames < 6:
		return
	process_frame.disconnect(_tick)
	var img := _vp.get_texture().get_image()
	var err := img.save_png(_out)
	print("saved %s (%s)" % [_out, error_string(err)])
	quit(0 if err == OK else 1)

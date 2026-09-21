extends SceneTree

## Renders one chassis model large through the game's own 3D view and saves a PNG, for
## judging polish and manner at a size the codex cannot show. Needs a window.
##   godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- <chassis> <maker> out.png [front|rear] [width height]

var _frames := 0
var _view: MechView3D
var _out := "hero.png"


func _init() -> void:
	if OS.get_environment("RIFTGATE_MECH3D_WIRE") == "1":
		RenderingServer.set_debug_generate_wireframes(true)   # before any mesh loads
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("usage: <chassis> <maker> out.png [front|rear] [width height]")
		quit(2)
		return
	var chassis: String = args[0]
	var maker: String = args[1]
	_out = args[2]
	var yaw := MechView3D.YAW_FRONT if args.size() < 4 or args[3] != "rear" else MechView3D.YAW_REAR
	var frame := Vector2i(480, 576)
	if args.size() >= 6:
		frame = Vector2i(int(args[4]), int(args[5]))
	_view = MechView3D.make(chassis, maker, "clean", "badger", yaw, frame, false)
	root.add_child(_view)
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames < 6:
		return
	var img := _view.get_texture().get_image()
	var err := img.save_png(_out)
	print("saved %s (%s)" % [_out, "OK" if err == OK else str(err)])
	quit(0)

extends SceneTree

## Renders one chassis model large through the game's own 3D view and saves a PNG, for
## judging polish and manner at a size the codex cannot show. Needs a window.
##   godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- <chassis> <maker> out.png [front|rear|<yaw degrees>] [width height]
## Rendered bare, without the display's outline (RIFTGATE_OUTLINE_KEEP=1 keeps it).
## RIFTGATE_FIT="1:lance,4:blazethrower" hangs components' silhouette classes on the mounts in
## place of the stock parts ("2:" bares a socket), to judge a swap; a class on its own is
## a model too: <chassis> shapes/barrel_minerva.

var _frames := 0
var _view: MechView3D
var _out := "hero.png"


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("usage: <chassis> <maker> out.png [front|rear|<yaw degrees>] [width height]")
		quit(2)
		return
	var chassis: String = args[0]
	var maker: String = args[1]
	_out = args[2]
	var yaw := MechView3D.YAW_FRONT
	if args.size() >= 4 and args[3] == "rear":
		yaw = MechView3D.YAW_REAR
	elif args.size() >= 4 and args[3].is_valid_float():
		yaw = float(args[3])   # any angle, for checking a finish around the spin
	var frame := Vector2i(480, 576)
	if args.size() >= 6:
		frame = Vector2i(int(args[4]), int(args[5]))
	var plan: Array = []
	var fit := OS.get_environment("RIFTGATE_FIT")
	if not fit.is_empty():
		plan = MechView3D.plan_from_spec(fit, ContentDB.load_default())
	_view = MechView3D.make(chassis, maker, "clean", "badger", yaw, frame, false, {}, plan)
	if OS.get_environment("RIFTGATE_OUTLINE_KEEP") != "1":
		_view.strip_silhouette()   # the viewer's renders show the machine bare (Ryan, 30 September); RIFTGATE_OUTLINE_KEEP=1 keeps the display's edge
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

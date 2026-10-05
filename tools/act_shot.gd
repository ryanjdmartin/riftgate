extends SceneTree

## One machine frozen partway through one of its idle acts (MechRig; the acts are in the
## model's art/models/<id>.rig.json), saved as a PNG, for checking a pose without a running
## build. Judge the acts running where you can (RIFTGATE_ACTS_DEBUG=1 godot --path .); this
## is for a sign or a reach, one frame at a time.
##   godot --path . --resolution 360x640 --position 2000,2000 -s tools/act_shot.gd -- <chassis> <maker> <act> <seconds> out.png [front|rear|<yaw degrees>]
## An act name of "-" renders the rest pose; "gait" renders the machine that many seconds
## into a straight run at its full speed on the map (its stride). Needs a window (xvfb-run does, on a Linux box).

var _frames := 0
var _view: MechView3D
var _out := "act.png"


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var yaw := MechView3D.YAW_FRONT
	if args.size() >= 6 and args[5] == "rear":
		yaw = MechView3D.YAW_REAR
	elif args.size() >= 6 and args[5].is_valid_float():
		yaw = float(args[5])
	_out = args[4]
	_view = MechView3D.make(args[0], args[1], "clean", "badger", yaw, Vector2i(420, 420), false, {}, [])
	_view.strip_silhouette()
	root.add_child(_view)
	_view.set_process(false)
	if args[2] == "gait":
		# Under way at its own full speed on the map for that long, frame by frame: a stride's pose.
		var t := 0.0
		while t < float(args[3]):
			_view.rig.drive(_view.rig.top_speed, 0.0, 0.0, 1.0 / 60.0)
			t += 1.0 / 60.0
	elif args[2] != "-":
		if not _view.rig.play(args[2]):
			push_error("no act " + args[2])
		_view.rig.tick(float(args[3]))
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames < 6:
		return
	var err := _view.get_texture().get_image().save_png(_out)
	print("saved %s (%s)" % [_out, "OK" if err == OK else str(err)])
	quit()

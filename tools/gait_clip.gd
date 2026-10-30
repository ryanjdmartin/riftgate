extends SceneTree

## One machine walking in place at its own full speed on the map, every frame saved as a PNG,
## to be put together as a clip (ffmpeg) and judged running: a gait against an option of it
## side by side, say (Ryan, 5 October: the Ammit's arms and legs at different speeds). The
## rig is driven 1/fps of a second a frame, so the clip plays at the map's pace whatever the
## render costs.
##   godot --path . --resolution 360x640 -s tools/gait_clip.gd -- <chassis> <maker> <out prefix> <seconds> [front|rear|skirmish|<yaw degrees>] [<w>x<h>] [<gait option>] [<fps>]
## Writes <out prefix>_0000.png onwards; then, say:
##   ffmpeg -framerate 30 -i <out prefix>_%04d.png -pix_fmt yuv420p clip.mp4
## Needs a window (xvfb-run does, on a Linux box).

var _view: MechView3D
var _prefix := ""
var _frames := 0
var _total := 0
var _step := 1.0 / 30.0


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 4:
		push_error("gait_clip: <chassis> <maker> <out prefix> <seconds> [view] [WxH] [option] [fps]")
		quit(1)
		return
	var yaw := MechView3D.YAW_FRONT
	if args.size() >= 5:
		if args[4] == "rear":
			yaw = MechView3D.YAW_REAR
		elif args[4] == "skirmish":
			yaw = MechView3D.YAW_SKIRMISH
		elif args[4].is_valid_float():
			yaw = float(args[4])
	var frame := Vector2i(420, 420)
	if args.size() >= 6 and args[5].contains("x"):
		frame = Vector2i(int(args[5].get_slice("x", 0)), int(args[5].get_slice("x", 1)))
	if args.size() >= 8 and args[7].is_valid_float():
		_step = 1.0 / float(args[7])
	_prefix = args[2]
	_total = int(ceil(float(args[3]) / _step))
	_view = MechView3D.make(args[0], args[1], "clean", "", yaw, frame, false, {}, [])
	root.add_child(_view)
	_view.set_process(false)
	if args.size() >= 7 and not args[6].is_empty() and args[6] != "-":
		if not _view.rig.gait_options.has(args[6]):
			push_error("gait_clip: %s has no gait option %s" % [args[0], args[6]])
			quit(1)
			return
		_view.rig.use_gait(_view.rig.gait_options[args[6]])
	# Under way first, so the clip opens mid-stride and not on the pull away.
	for i in range(int(2.0 / _step)):
		_view.rig.drive(_view.rig.top_speed, 0.0, 0.0, _step)
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames < 4:
		return   # the first frames render before the view has framed itself
	var k := _frames - 4
	if k > 0:
		_view.get_texture().get_image().save_png("%s_%04d.png" % [_prefix, k - 1])
	if k >= _total:
		print("gait_clip: %d frames to %s_*.png" % [_total, _prefix])
		quit()
		return
	_view.rig.drive(_view.rig.top_speed, 0.0, 0.0, _step)

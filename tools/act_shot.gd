extends SceneTree

## One machine frozen partway through one of its idle acts (MechRig; the acts are in the
## model's art/models/<id>.rig.json), saved as a PNG, for checking a pose without a running
## build. Judge the acts running where you can (RIFTGATE_ACTS_DEBUG=1 godot --path .); this
## is for a sign or a reach, one frame at a time.
##   godot --path . --resolution 360x640 --position 2000,2000 -s tools/act_shot.gd -- <chassis> <maker> <act> <seconds> out.png [front|rear|skirmish|<yaw degrees>] [<w>x<h>]
## The frame is 420 square unless a size is given; "skirmish 160x192" is the skirmish's own
## view (its angle, its frame fitted to the machine at rest), to see what an act leaves of it.
## An act name of "-" renders the rest pose; "gait" renders the machine that many seconds
## into a straight run at its full speed on the map (its stride); "lose" that many seconds after
## it is lost (MechView3D.lose: its lights out and its slump). RIFTGATE_FORM=<name> holds
## that form first, all the way in, so the act is one of its own (the sealed Polar Bear's) or
## "-" its held pose; RIFTGATE_FORM_AT=<seconds> stops it that far into its turn instead, to see
## a frame of the form going in (the Mole's burrow). RIFTGATE_FIT="1:rivet_gun,2:shotfire_rack" hangs
## those components' classes on the mounts in place of the stock parts, as tools/hero_shot.gd does,
## to see a swap through an act or a form (a machine whose guns stow). RIFTGATE_PITCH=<degrees> tilts
## the camera down that far in place of the view's own (0 level, to see under a machine). An act of "fire:<component>" fires that weapon (MechView3D.strike: a fixed one
## with its act's slice and what it fires out of the machine, lowforge's launches) and renders it that
## many seconds on. Needs a window (xvfb-run does, on a Linux box).

var _frames := 0
var _view: MechView3D
var _out := "act.png"
var _fire := ""        # a weapon to fire once the view is up ("fire:<component>"), and how long after to render
var _fire_t := 0.0


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var yaw := MechView3D.YAW_FRONT
	if args.size() >= 6 and args[5] == "rear":
		yaw = MechView3D.YAW_REAR
	elif args.size() >= 6 and args[5] == "skirmish":
		yaw = MechView3D.YAW_SKIRMISH
	elif args.size() >= 6 and args[5].is_valid_float():
		yaw = float(args[5])
	var frame := Vector2i(420, 420)
	if args.size() >= 7 and args[6].contains("x"):
		frame = Vector2i(int(args[6].get_slice("x", 0)), int(args[6].get_slice("x", 1)))
	_out = args[4]
	var fit := OS.get_environment("RIFTGATE_FIT")
	var plan: Array = MechView3D.plan_from_spec(fit, ContentDB.load_default()) if not fit.is_empty() else []
	_view = MechView3D.make(args[0], args[1], "clean", "badger", yaw, frame, false, {}, plan)
	var pitch := OS.get_environment("RIFTGATE_PITCH")
	if pitch.is_valid_float():
		_view.pitch = float(pitch)   # framed as it enters the tree
	root.add_child(_view)
	_view.set_process(false)
	var form := OS.get_environment("RIFTGATE_FORM")
	if not form.is_empty():
		_view.rig.set_form(form, true)
		var at := OS.get_environment("RIFTGATE_FORM_AT")
		_view.rig.tick(float(at) if at.is_valid_float() else float(_view.rig.forms.get(form, {}).get("duration", 1.0)) + 0.05)
	if args[2] == "gait":
		# Under way at its own full speed on the map for that long, frame by frame: a stride's pose.
		var t := 0.0
		while t < float(args[3]):
			_view.rig.drive(_view.rig.top_speed, 0.0, 0.0, 1.0 / 60.0)
			t += 1.0 / 60.0
	elif args[2] == "lose":
		_view.lose()
		_view.rig.tick(float(args[3]))
	elif args[2].begins_with("fire:"):
		_fire = args[2].trim_prefix("fire:")
		_fire_t = float(args[3])
	elif args[2] != "-":
		if not _view.rig.play(args[2]):
			push_error("no act " + args[2])
		_view.rig.tick(float(args[3]))
	process_frame.connect(_tick)


func _tick() -> void:
	# The view's _ready, run with the first frame, turns its processing back on, and the act
	# would run on through the frames before the save (a frame at "0.3 s" showed 0.6).
	_view.set_process(false)
	_frames += 1
	if _frames == 2 and not _fire.is_empty():
		# Fired once the view is in the tree, so a launch leaves from where its parent stands; then
		# the rig and the launches run on frame by frame to the moment asked.
		_view.strike(true, _fire)
		var t := 0.0
		while t < _fire_t:
			_view.rig.tick(1.0 / 60.0)
			_view._fly(1.0 / 60.0)
			t += 1.0 / 60.0
	if _frames < 6:
		return
	var err := _view.get_texture().get_image().save_png(_out)
	print("saved %s (%s)" % [_out, "OK" if err == OK else str(err)])
	quit()

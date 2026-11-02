extends SceneTree

## The fit sheet (Ryan, 2 November: "Hardpoint just needs to declare shape (if offered) and
## scaling"; every hardpoint checked wearing every class before a model comes to him): a row a
## machine, its stock first, then each silhouette class on all of its mounts at once, through
## the game's own view and its own wear (each mount's declared variant and scale), into one PNG.
## A class that jams, sinks into the hull or hides under a wing shows here before a player
## fits it. Needs a window.
##   godot --path . --resolution 360x640 -s tools/fit_sheet.gd -- out.png [chassis ...] [--cell 220]
## With no chassis named, every chassis drawn by a model of its own.

const CLASSES := ["barrel", "twin_barrel", "rack", "dish", "blade"]
const GROUND := Color(0.04, 0.05, 0.06)

var _cell := 220
var _out := "fit_sheet.png"
var _jobs: Array = []      # [row, column, chassis, maker, plan, label]
var _sheet: Image
var _view: MechView3D
var _frames := 0


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var names: Array = []
	var i := 0
	while i < args.size():
		if args[i] == "--cell" and i + 1 < args.size():
			_cell = maxi(64, int(args[i + 1]))
			i += 2
			continue
		if args[i].ends_with(".png"):
			_out = args[i]
		else:
			names.append(args[i])
		i += 1
	var db := ContentDB.load_default()
	var wears := _one_of_each(db)
	if names.is_empty():
		for id in db.chassis.keys():
			if MechView3D.model_for(str(id), "") == str(id) and MechView3D.pin_record(str(id)) != null:
				names.append(str(id))
	var row := 0
	for id in names:
		if not db.chassis.has(id):
			push_error("no chassis %s" % id)
			continue
		var maker := str(db.chassis[id].get("maker", ""))
		var pins = MechView3D.pin_record(id)
		var count: int = (pins as Array).size() if pins is Array else 0
		_jobs.append([row, 0, id, maker, [], "%s stock" % id])
		for c in range(CLASSES.size()):
			var cls: String = CLASSES[c]
			var plan: Array = []
			if wears.has(cls):
				var cid: String = wears[cls]
				for n in range(1, count + 1):
					plan.append([n, cid, cls, str(db.components[cid].get("maker", ""))])
			_jobs.append([row, c + 1, id, maker, plan, "%s %s" % [id, cls.replace("_", " ")]])
		row += 1
	_sheet = Image.create(_cell * (CLASSES.size() + 1), _cell * maxi(1, row), false, Image.FORMAT_RGBA8)
	_sheet.fill(GROUND)
	print("fit sheet: %d machines, %d cells -> %s" % [row, _jobs.size(), _out])
	process_frame.connect(_tick)


## A component of each class to hang (content's first of that shape that is not a draft): only
## its class and its maker's metal show, never which component it is.
static func _one_of_each(db: ContentDB) -> Dictionary:
	var out := {}
	var ids: Array = db.components.keys()
	ids.sort()
	for id in ids:
		var c: Dictionary = db.components[id]
		var shape := str(c.get("shape", ""))
		if CLASSES.has(shape) and not out.has(shape) and str(c.get("status", "")) != "planned":
			out[shape] = str(id)
	return out


func _tick() -> void:
	if _view == null:
		if _jobs.is_empty():
			_sheet.save_png(_out)
			print("saved %s" % _out)
			quit(0)
			return
		var job: Array = _jobs[0]
		_view = MechView3D.make(str(job[2]), str(job[3]), "clean", "", MechView3D.YAW_FRONT, Vector2i(_cell, _cell), false, {}, job[4])
		var label := Label.new()
		label.text = str(job[5])
		label.position = Vector2(6, 4)
		label.add_theme_font_size_override("font_size", 13)
		_view.add_child(label)
		root.add_child(_view)
		_frames = 0
		return
	_frames += 1
	if _frames < 6:
		return
	var job: Array = _jobs.pop_front()
	var img := _view.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	if img.get_width() != _cell or img.get_height() != _cell:
		img.resize(_cell, _cell, Image.INTERPOLATE_BILINEAR)
	var cell := Image.create(_cell, _cell, false, Image.FORMAT_RGBA8)
	cell.fill(GROUND)
	cell.blend_rect(img, Rect2i(0, 0, _cell, _cell), Vector2i.ZERO)
	_sheet.blit_rect(cell, Rect2i(0, 0, _cell, _cell), Vector2i(int(job[1]) * _cell, int(job[0]) * _cell))
	_view.queue_free()
	_view = null

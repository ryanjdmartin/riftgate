extends SceneTree

## The die's iconography on one sheet, drawn by the game's own die (DieFaceView), still: every
## main icon an entry wears, whom a piece reaches written under it, and the rest of a face's
## marks (its costs, its states, the chips down its edge). Ryan asked to see the set whole (2
## November: "Can you show me the complete set of main die face iconography?"); run it again
## whenever a glyph changes.
##
##   xvfb-run -a -s "-screen 0 2000x2000x24" godot --rendering-method gl_compatibility --path . \
##     --resolution 1360x1540 -s tools/die_sheet.gd -- build/die_sheet.png
##
## The window's size is the sheet's in design pixels (one to one, whatever the project's stretch).

const COLS := 8   # the targets' rows hold two kinds of four
const CELL := Vector2(164, 222)
const MARGIN := 24.0
const HEAD := 46.0

var _out := "build/die_sheet.png"
var _frames := 0
var _sheet: Control
var _labels: Array = []     # [position, text, size, colour]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		_out = args[0]
	_sheet = Control.new()
	_sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sheet.draw.connect(_draw_sheet)
	root.add_child(_sheet)
	var y := MARGIN
	y = _section(y, "WHAT AN ENTRY IS: THE MAIN ICON", _kinds())
	y = _section(y, "WHOM IT REACHES: WRITTEN UNDER THE ICON WHEN NARROWED (2 NOVEMBER)", _targets())
	y = _section(y, "THE REST OF A FACE: COSTS, STATES, THE CHIPS DOWN ITS EDGE", _rest())
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames == 1:
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		root.content_scale_factor = 1.0
	if _frames == 2:
		_sheet.size = Vector2(root.size)
		_sheet.queue_redraw()
	if _frames < 8:
		return
	DirAccess.make_dir_recursive_absolute(_out.get_base_dir())
	var img := root.get_texture().get_image()
	img.save_png(_out)
	print("die sheet: ", _out, " ", img.get_size())
	quit()


func _draw_sheet() -> void:
	_sheet.draw_rect(Rect2(Vector2.ZERO, _sheet.size), Palette.BG)
	for l in _labels:
		_sheet.draw_string(Hud.mono(), l[0], l[1], HORIZONTAL_ALIGNMENT_LEFT, CELL.x - 8.0 if int(l[2]) < 16 else -1, int(l[2]), l[3])


## A heading and its cells, COLS a row: each cell a name over a die and a line under it.
func _section(y: float, title: String, cells: Array) -> float:
	_labels.append([Vector2(MARGIN, y + 22.0), title, 18, Palette.INK])
	y += HEAD
	for i in range(cells.size()):
		var at := Vector2(MARGIN + (i % COLS) * CELL.x, y + (i / COLS) * CELL.y)
		var cell: Array = cells[i]
		_labels.append([at + Vector2(0, 12.0), str(cell[0]), 13, Palette.INK])
		var d: DieFaceView = cell[2]
		d.animate = false
		d.position = at + Vector2(0, 36.0)
		_sheet.add_child(d)
		var y2 := at.y + 36.0 + DieFaceView.FACE + 22.0
		for line in str(cell[1]).split("\n"):
			_labels.append([Vector2(at.x, y2), line, 11, Palette.MUTED])
			y2 += 14.0
	return y + ceili(cells.size() / float(COLS)) * CELL.y + 12.0


func _die(f: Face) -> DieFaceView:
	var d := DieFaceView.new()
	d.set_face(f)
	return d


func _kinds() -> Array:
	var rolled := Face.attack(2, Face.Reach.DIRECT, [], 0, 6)
	var burst := Face.attack(3)
	burst.strikes = 3
	var reload := Face.vent(0)
	reload.reloads_ammo = 2
	var down := _die(Face.attack(4))
	down.dead = true
	return [
		["Weapon, direct", "a crosshair: Direct,\nthe front rank first", _die(Face.attack(4))],
		["Weapon, indirect", "an arc: Indirect,\nany foe", _die(Face.attack(4, Face.Reach.INDIRECT))],
		["Weapon, rolled", "rolls in its range\nas it is spent", _die(rolled)],
		["Weapon, strikes", "three blows a spend,\neach rolled on its own", _die(burst)],
		["Debuff, direct", "the crosshair with the\nstatus mark: no damage", _die(Face.attack(0))],
		["Debuff, indirect", "the arc with the\nstatus mark", _die(Face.attack(0, Face.Reach.INDIRECT))],
		["Shield", "spent on a machine:\nshield", _die(Face.shield(4))],
		["Vent", "spent on a machine:\nheat off", _die(Face.vent(3))],
		["Reload", "a vent that fills the\nmagazine (the Musk Ox)", _die(reload)],
		["Buff", "spent on a machine:\na status, stacks", _die(Face.buff("overcharged", 2))],
		["Blank", "an empty hardpoint, or\na destroyed component", _die(Face.empty_slot())],
		["Machine down", "its die, wrecked", down],
	]


func _targets() -> Array:
	var out: Array = []
	var kinds := [["Shield", func() -> Face: return Face.shield(4)], ["Vent", func() -> Face: return Face.vent(3)],
		["Buff", func() -> Face: return Face.buff("overcharged", 2)], ["Reload", func() -> Face:
			var r := Face.vent(0)
			r.reloads_ammo = 2
			return r]]
	for k in kinds:
		var make: Callable = k[1]
		var plain: Face = make.call()
		var own: Face = make.call()
		own.targets = Face.Target.SELF
		var give: Face = make.call()
		give.targets = Face.Target.ALLY
		var every: Face = make.call()
		every.targets = Face.Target.ALLY
		every.reaches_all = true
		out.append(["%s, default" % k[0], "itself or an ally:\nunmarked", _die(plain)])
		out.append(["%s, SELF" % k[0], "its own machine only", _die(own)])
		out.append(["%s, ALLY" % k[0], "any other ally only", _die(give)])
		out.append(["%s, EVERY ALLY" % k[0], "every ally at once", _die(every)])
	return out


func _rest() -> Array:
	var hot := Face.attack(5)
	hot.heat = 2
	var costly := Face.attack(5)
	costly.volatile = 2
	costly.shield_cost = 2
	var short := Face.shield(4)
	short.shield_cost = 3
	short.short = true
	var dry := Face.attack(6)
	dry.ammo = 2
	dry.dry = true
	var burn := Face.attack(4)
	burn.burns = 2
	var both := Face.vent(2)
	both.shields = 3
	var blast_vent := _die(Face.vent(3))
	blast_vent.blast = 4
	var locked := _die(Face.attack(4))
	locked.locked = true
	var charged := _die(Face.shield(4))
	charged.charged = true
	var dark_face := Face.attack(4)
	dark_face.disabled = true
	var dark := _die(dark_face)
	dark.dark = 2
	var chips := Face.attack(4)
	chips.add_keyword(Face.Keyword.BURN)
	chips.add_keyword(Face.Keyword.CLEAVE)
	chips.label = "a rule of its own"
	var chipped := _die(chips)
	chipped.corrupted = 2
	var stepping := _die(Face.attack(3))
	stepping.next_face = Face.attack(6)
	var seal := _die(Face.shield(3))
	seal.form_mark = "seal"
	var unseal := _die(Face.vent(3))
	unseal.form_mark = "unseal"
	return [
		["Heat", "the heat a spend adds", _die(hot)],
		["Hull and shield costs", "paid first, from its\nown machine", _die(costly)],
		["SHORT", "the shield cannot pay:\nstruck through", _die(short)],
		["Ammo, DRY", "a forging gun's price;\nthe magazine cannot pay", _die(dry)],
		["Burn", "the Storm Petrel's: shield\npays the heat", _die(burn)],
		["Shield too", "a vent that also\nshields", _die(both)],
		["Blast", "a vent's blow at a\nrandom foe", blast_vent],
		["LOCKED", "a reroll skips it", locked],
		["CHARGED", "armed for its charged\nform (the Swallowtail)", charged],
		["Turns left", "dark: a cooldown or a\nfoe's switch-off", dark],
		["Chips", "keywords, the star for a\nrule, a corruption", chipped],
		["Next chamber", "a stepping die's next\nentry (the Cassowary)", stepping],
		["Seals", "spent on itself, the\nArmadillo shuts", seal],
		["Opens", "spent, the Armadillo's\nshell opens", unseal],
	]

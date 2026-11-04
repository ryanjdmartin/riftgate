extends SceneTree

## The die's iconography on one sheet, drawn by the game's own die (DieFaceView), still: every
## main mark an entry wears and what it holds, whom a piece reaches, and the rest of a face's
## marks (its costs, its states, the chips down its edge). Ryan asked to see the set whole (2
## November: "Can you show me the complete set of main die face iconography?"); run it again
## whenever a glyph changes.
##
##   xvfb-run -a godot --rendering-method gl_compatibility --path . -s tools/die_sheet.gd -- build/die_sheet.png [scale]
##
## Drawn at the phone's density (Ryan, 3 November: "Why aren't we drawing the dice at native
## size?"): `scale` device pixels a design pixel, 1.5 by default, a 1080-wide phone's, through a
## SubViewport as the screenshot tool's RIFTGATE_SHOT_SCALE draws, so the lines and the text are
## rasterised at that density as the device's canvas_items stretch rasterises them, never a
## design-pixel sheet that shows every die at two thirds of its size on the glass.

const SHEET := Vector2i(1360, 1540)   # the sheet in design pixels
const COLS := 8
const CELL := Vector2(164, 222)
const MARGIN := 24.0
const HEAD := 46.0

var _out := "build/die_sheet.png"
var _scale := 1.5
var _frames := 0
var _vp: SubViewport
var _sheet: Control
var _labels: Array = []     # [position, text, size, colour]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		_out = args[0]
	if args.size() > 1 and float(args[1]) > 0.0:
		_scale = float(args[1])
	_vp = SubViewport.new()
	_vp.size = Vector2i(roundi(SHEET.x * _scale), roundi(SHEET.y * _scale))
	_vp.size_2d_override = SHEET
	_vp.size_2d_override_stretch = true
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	_sheet = Control.new()
	_sheet.size = Vector2(SHEET)
	_sheet.draw.connect(_draw_sheet)
	_vp.add_child(_sheet)
	var y := MARGIN
	y = _section(y, "WHAT AN ENTRY IS: ITS MAIN MARK HOLDING WHAT IT DELIVERS, WHOM IT IS AIMED AT UNDER IT", _kinds())
	y = _section(y, "A PIECE SPENT ON MACHINES: THREE HEXES UNDER ITS MARK, THE MIDDLE ITS OWN, A FILLED ONE A MACHINE IT REACHES", _targets(), 6)
	y = _section(y, "THE REST OF A FACE: COSTS ALONG THE FOOT (A MARK AND A NUMBER), STATES, THE CHIPS", _rest())
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames == 2:
		_sheet.queue_redraw()
	if _frames < 8:
		return
	DirAccess.make_dir_recursive_absolute(_out.get_base_dir())
	var img := _vp.get_texture().get_image()
	img.save_png(_out)
	print("die sheet: ", _out, " ", img.get_size())
	quit()


func _draw_sheet() -> void:
	_sheet.draw_rect(Rect2(Vector2.ZERO, _sheet.size), Palette.BG)
	for l in _labels:
		_sheet.draw_string(Hud.mono(), l[0], l[1], HORIZONTAL_ALIGNMENT_LEFT, CELL.x - 8.0 if int(l[2]) < 16 else -1, int(l[2]), l[3])


## A heading and its cells, `cols` a row: each cell a name over a die and a line under it.
func _section(y: float, title: String, cells: Array, cols: int = COLS) -> float:
	_labels.append([Vector2(MARGIN, y + 22.0), title, 18, Palette.INK])
	y += HEAD
	for i in range(cells.size()):
		var at := Vector2(MARGIN + (i % cols) * CELL.x, y + (i / cols) * CELL.y)
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
	return y + ceili(cells.size() / float(cols)) * CELL.y + 12.0


var _slots := 0


## A die showing `f`, its place on its die counted along the sheet (I to IX, again), so every
## mark is seen beside the numeral it shares the face with.
func _die(f: Face) -> DieFaceView:
	var d := DieFaceView.new()
	d.set_face(f)
	_slots += 1
	d.slot = (_slots - 1) % 9 + 1
	return d


func _kinds() -> Array:
	var burst := Face.attack(2)
	burst.strikes = 4
	var sweep := Face.attack(2, Face.Reach.SWEEP)
	sweep.strikes = 4
	var petrel := Face.attack(4)
	petrel.burns = 2
	var zap := _die(petrel)
	zap.after_blow = 2
	var reload := Face.vent(0)
	reload.reloads_ammo = 2
	var wake := Face.vent(3)
	wake.shields = 3
	var hoist := Face.shield(3)
	hoist.vents = 2
	hoist.targets = Face.Target.ALLY
	var screens := Face.shield(2)
	screens.targets = Face.Target.EVERY_ALLY
	var down := _die(Face.attack(4))
	down.dead = true
	return [
		["Weapon, direct", "the sight, its blow inside;\nthe line straight: Direct", _die(Face.attack(4))],
		["Weapon, indirect", "the line lobbed:\nIndirect, any foe", _die(Face.attack(4, Face.Reach.INDIRECT))],
		["Weapon, sweep", "lobbed, any rank: a\nstrike for each column", _die(sweep)],
		["Weapon, strikes", "a strike's blow inside,\nits strikes beside", _die(burst)],
		["Weapon, over a foe", "its passive's box: the Storm\nPetrel's blow after it", zap],
		["Debuff, direct", "gear, what it lays inside\n(Suppress): no number", _die(Face.attack(0, Face.Reach.DIRECT, [Face.Keyword.SUPPRESS]))],
		["Debuff, indirect", "the gear holding Lure,\nthe line lobbed", _die(Face.attack(0, Face.Reach.INDIRECT, [Face.Keyword.LURE]))],
		["Debuff, every foe", "the enemy's formation lit:\nevery foe (the Siphon)", _die(Face.attack(0, Face.Reach.EVERY_FOE, [Face.Keyword.LURE]))],
		["Buff", "spent on a machine: its\nstatus inside, its stacks", _die(Face.buff("overcharged", 2))],
		["Shield", "spent on a machine:\nshield", _die(Face.shield(4))],
		["Shield, every ally", "the arch over the team:\nevery other machine", _die(screens)],
		["Vent", "its plate holding the heat\noff, steam rising off it", _die(Face.vent(3))],
		["Shield and vent", "both at once (the Wake\nDiffuser): shield | cool", _die(wake)],
		["Shield and vent, ally", "the Sutler's Hoist: the\nsteam over the cooling", _die(hoist)],
		["Reload", "cools nothing: its shells\nand its ammo (the Musk Ox)", _die(reload)],
		["Blank", "an empty hardpoint, or\na destroyed component", _die(Face.empty_slot())],
		["Machine down", "its die, wrecked", down],
	]


func _targets() -> Array:
	var out: Array = []
	var kinds := [["Shield", func() -> Face: return Face.shield(4)], ["Vent", func() -> Face: return Face.vent(3)],
		["Equipment", func() -> Face: return Face.buff("overcharged", 2)], ["Reload", func() -> Face:
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
		out.append(["%s, either" % k[0], "all three: itself\nor an ally", _die(plain)])
		out.append(["%s, self" % k[0], "the middle: its own\nmachine only", _die(own)])
		out.append(["%s, ally" % k[0], "the two beside it:\nits allies only", _die(give)])
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
	var blast_vent := _die(Face.vent(3))
	blast_vent.blast = 4
	var locked := _die(Face.attack(4))
	locked.locked = true
	var charged := _die(Face.shield(4))
	charged.charged = true
	var dark := _die(Face.disabled_stand_in(Face.attack(4)))
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
		["Short", "the shield cannot pay:\nstruck through", _die(short)],
		["Ammo, dry", "a forging gun's price;\nthe magazine cannot pay", _die(dry)],
		["Burn", "the Storm Petrel's: its box\nthe shield paid, no cost", _die(burn)],
		["Blast", "its passive's box: a blast\nat a random foe", blast_vent],
		["LOCKED", "a reroll skips it", locked],
		["CHARGED", "armed for its charged\nform (the Swallowtail)", charged],
		["Dark", "a cooldown or a switch-\noff: the clock, its turns", dark],
		["Chips", "keywords, the star for a\nrule, a corruption", chipped],
		["Next chamber", "its passive's box: the\nnext entry (the Cassowary)", stepping],
		["Seals", "spent on itself, the\nArmadillo shuts", seal],
		["Opens", "spent, the Armadillo's\nshell opens", unseal],
	]

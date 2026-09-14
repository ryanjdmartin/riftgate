class_name SkirmishScreen
extends Control

## The skirmish screen, minimal chrome. Portrait, 720x1280 logical, positioned absolutely so
## every coordinate is a plain number.
##
##   header      round, pool, reroll count, and the eye button that shows every intent arrow
##   formation   two ranks of three unit views; a massive foe spans both ranks of its column
##   log         kept in the centre for now
##   mechs       unit views with floating bars
##   dice        tap to lock, hold for details, drag onto a target to spend
##   buttons     Reroll / End round / Withdraw
##
## Holding a foe shows its numbers and its arrow. Holding a mech shows its numbers and every
## arrow aimed at it.

signal finished(outcome: int)
signal back_requested

const W := 720.0
const H := 1280.0
const COL_X := [150.0, 360.0, 570.0]
const BACK_Y := 80.0
const FRONT_Y := 220.0
const SLOT_SIZE := Vector2(150, 130)
const MASSIVE_SIZE := Vector2(150, 270)
const MECH_Y := 610.0
const MECH_SIZE := Vector2(150, 160)
const DIE_Y := 810.0
const DIE_SIZE := 120.0

var sk: Skirmish
var locked: Array[bool] = []
var show_all_arrows: bool = false

var _header: Label
var _reroll_label: Label
var _eye: Button
var _log: Label
var _slot_views: Array = []          # [rank][col] -> UnitView
var _massive_views: Array = []       # [col] -> UnitView
var _view_foe: Dictionary = {}       # UnitView -> Foe
var _mech_views: Array[UnitView] = []
var _dice: Array[DieFaceView] = []
var _ghost: DieFaceView
var _arrows: ArrowLayer
var _details: PanelContainer
var _details_label: Label
var _codex_shade: Control
var _codex: PanelContainer
var _codex_title: Label
var _codex_sub: Label
var _codex_fantasy: Label
var _codex_stats: Label
var _codex_question: Label
var _codex_passive: Label
var _codex_flavour: Label
var _hint: Label
var _reroll_btn: Button
var _end_btn: Button
var _withdraw_btn: Button
var _overlay: Control
var _overlay_title: Label
var _overlay_text: Label
var _drag_from: int = -1
var _hold_foe: Foe = null
var _hold_mech: int = -1


func setup(skirmish: Skirmish) -> void:
	sk = skirmish
	locked.clear()
	for m in sk.mechs:
		locked.append(false)
	if sk.state == Skirmish.State.SETUP:
		sk.begin()
	if sk.state == Skirmish.State.ROUND_START:
		sk.start_round()
	_build()
	_refresh()


func _ready() -> void:
	if sk == null:
		setup(_default_skirmish())
	elif _header == null:
		_build()
		_refresh()


## Standalone default, used when the scene runs on its own (screenshots, quick checks).
## RIFTGATE_TEAM=bulwark,sentinel,raptor,anvil overrides the team; RIFTGATE_ELITE=1 adds the
## faction's massive elite.
static func _default_skirmish() -> Skirmish:
	var db := ContentDB.load_default()
	var s := Skirmish.new(7)
	var team: Array = ["bulwark", "sentinel", "raptor"]
	var env := OS.get_environment("RIFTGATE_TEAM")
	if not env.is_empty():
		team = env.split(",")
	for id in team:
		if db.chassis.has(id):
			s.add_mech(db.make_mech(id))
	var sq := Unit.squad(1, "risen", Vector2i.ZERO, "undead", 2, 8)
	sq.elite = OS.get_environment("RIFTGATE_ELITE") == "1"
	s.add_foes(db.foes_for(sq), sq)
	return s


# ---------------------------------------------------------------- build

func _build() -> void:
	for c in get_children():
		c.queue_free()
	_slot_views = [[null, null, null], [null, null, null]]
	_massive_views = [null, null, null]
	_mech_views.clear()
	_dice.clear()
	custom_minimum_size = Vector2(W, H)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Header
	_header = _label("", 22, Palette.INK)
	_place(_header, Vector2(24, 18), Vector2(400, 32))
	_reroll_label = _label("", 16, Palette.MUTED)
	_place(_reroll_label, Vector2(24, 50), Vector2(400, 24))
	_eye = Button.new()
	_eye.toggle_mode = true
	_eye.text = "◎"
	_eye.tooltip_text = "Show every intent arrow"
	_eye.add_theme_font_size_override("font_size", 24)
	_eye.toggled.connect(_toggle_all_arrows)
	_place(_eye, Vector2(636, 16), Vector2(60, 48))

	# Formation: rank labels, six slot views, three massive views (hidden until needed).
	var back_tag := _label("BACK", 12, Palette.MUTED)
	_place(back_tag, Vector2(16, BACK_Y + 50), Vector2(60, 20))
	var front_tag := _label("FRONT", 12, Palette.MUTED)
	_place(front_tag, Vector2(16, FRONT_Y + 50), Vector2(60, 20))
	for col in range(Skirmish.COLUMNS):
		for rank in range(2):
			var v := UnitView.new()
			v.is_enemy = true
			var y := FRONT_Y if rank == 0 else BACK_Y
			_place(v, Vector2(COL_X[col] - SLOT_SIZE.x * 0.5, y), SLOT_SIZE)
			v.held.connect(_on_foe_held.bind(v))
			v.hold_released.connect(_on_hold_released)
			v.double_tapped.connect(_on_foe_double_tapped.bind(v))
			_slot_views[rank][col] = v
		var mv := UnitView.new()
		mv.is_enemy = true
		mv.massive = true
		mv.visible = false
		_place(mv, Vector2(COL_X[col] - MASSIVE_SIZE.x * 0.5, BACK_Y), MASSIVE_SIZE)
		mv.held.connect(_on_foe_held.bind(mv))
		mv.hold_released.connect(_on_hold_released)
		mv.double_tapped.connect(_on_foe_double_tapped.bind(mv))
		_massive_views[col] = mv

	# Log
	_log = _label("", 15, Palette.MUTED)
	_log.autowrap_mode = TextServer.AUTOWRAP_WORD
	_log.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_place(_log, Vector2(40, 396), Vector2(640, 196))

	# Mechs and dice
	var n := sk.mechs.size()
	for i in range(n):
		var cx := W * 0.5 + (i - (n - 1) * 0.5) * 172.0
		var ms: Skirmish.MechState = sk.mechs[i]
		var v := UnitView.new()
		v.display_name = ms.unit.display_name
		_place(v, Vector2(cx - MECH_SIZE.x * 0.5, MECH_Y), MECH_SIZE)
		v.held.connect(_on_mech_held.bind(i))
		v.hold_released.connect(_on_hold_released)
		v.double_tapped.connect(_on_mech_double_tapped.bind(i))
		_mech_views.append(v)
		var d := DieFaceView.new()
		_place(d, Vector2(cx - DIE_SIZE * 0.5, DIE_Y), Vector2(DIE_SIZE, DIE_SIZE))
		d.tapped.connect(_on_die_tapped.bind(i))
		d.held.connect(_on_die_held.bind(i))
		d.hold_released.connect(_on_hold_released)
		d.drag_started.connect(_on_drag_started.bind(i))
		d.drag_moved.connect(_on_drag_moved)
		d.drag_ended.connect(_on_drag_ended)
		_dice.append(d)
	_hint = _label("tap a die to lock it · hold for details · drag onto a target", 13, Palette.MUTED)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place(_hint, Vector2(0, DIE_Y + DIE_SIZE + 14), Vector2(W, 20))

	# Buttons
	_reroll_btn = _button("Reroll", _on_reroll)
	_end_btn = _button("End round", _on_end_round)
	_withdraw_btn = _button("Withdraw", _on_withdraw)
	_withdraw_btn.tooltip_text = "Available between rounds, after the enemy has acted."
	_place(_reroll_btn, Vector2(24, 1180), Vector2(214, 60))
	_place(_end_btn, Vector2(253, 1180), Vector2(214, 60))
	_place(_withdraw_btn, Vector2(482, 1180), Vector2(214, 60))

	# Overlays: arrows, drag ghost, details, outcome.
	_arrows = ArrowLayer.new()
	_arrows.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_arrows)
	_ghost = DieFaceView.new()
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.modulate = Color(1, 1, 1, 0.85)
	_ghost.visible = false
	_place(_ghost, Vector2.ZERO, Vector2(DIE_SIZE, DIE_SIZE))
	_details = PanelContainer.new()
	var dsb := StyleBoxFlat.new()
	dsb.bg_color = Palette.PANEL_RAISED
	dsb.border_color = Palette.RULE
	dsb.set_border_width_all(1)
	dsb.set_corner_radius_all(8)
	dsb.set_content_margin_all(12)
	_details.add_theme_stylebox_override("panel", dsb)
	_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_details.visible = false
	add_child(_details)
	_details_label = _label("", 16, Palette.INK)
	_details_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_details.add_child(_details_label)

	# Codex: a double-tap on a unit opens it; a tap anywhere outside closes it.
	_codex_shade = Control.new()
	_codex_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_codex_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_codex_shade.visible = false
	_codex_shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			_close_codex())
	add_child(_codex_shade)
	_codex = PanelContainer.new()
	var csb := StyleBoxFlat.new()
	csb.bg_color = Palette.PANEL_RAISED
	csb.border_color = Palette.ACCENT
	csb.set_border_width_all(2)
	csb.set_corner_radius_all(10)
	csb.set_content_margin_all(20)
	_codex.add_theme_stylebox_override("panel", csb)
	_codex.visible = false
	_place(_codex, Vector2(40, 380), Vector2(640, 0))
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 8)
	_codex.add_child(cv)
	_codex_title = _label("", 30, Palette.INK)
	_codex_sub = _label("", 15, Palette.MUTED)
	_codex_fantasy = _label("", 18, Palette.INK)
	_codex_stats = _label("", 15, Palette.MUTED)
	_codex_question = _label("", 16, Palette.INK)
	_codex_passive = _label("", 16, Palette.ACCENT)
	_codex_flavour = _label("", 16, Palette.MUTED)
	for l in [_codex_title, _codex_sub, _codex_fantasy, _codex_stats, _codex_question, _codex_passive, _codex_flavour]:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		cv.add_child(l)
	var close := _button("Close", _close_codex)
	cv.add_child(close)

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.72)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	add_child(_overlay)
	var oc := CenterContainer.new()
	oc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(oc)
	var op := PanelContainer.new()
	var osb := StyleBoxFlat.new()
	osb.bg_color = Palette.PANEL_RAISED
	osb.set_corner_radius_all(12)
	osb.set_content_margin_all(28)
	op.add_theme_stylebox_override("panel", osb)
	oc.add_child(op)
	var ov := VBoxContainer.new()
	ov.add_theme_constant_override("separation", 14)
	op.add_child(ov)
	_overlay_title = _label("", 40, Palette.INK)
	_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ov.add_child(_overlay_title)
	_overlay_text = _label("", 18, Palette.MUTED)
	_overlay_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	_overlay_text.custom_minimum_size = Vector2(420, 0)
	ov.add_child(_overlay_text)
	ov.add_child(_button("Back", func() -> void: back_requested.emit()))


func _place(c: Control, pos: Vector2, sz: Vector2) -> void:
	c.position = pos
	c.size = sz
	add_child(c)


func _label(text: String, size_px: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _button(text: String, on_pressed: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 56)
	b.add_theme_font_size_override("font_size", 20)
	b.pressed.connect(on_pressed)
	return b


# ---------------------------------------------------------------- refresh

func _refresh() -> void:
	_header.text = "Round %d      Pool %d" % [sk.round, sk.pool.size()]
	_reroll_label.text = "Rerolls left: %d" % sk.rerolls_left
	_view_foe.clear()

	var targets: Array[Foe] = []
	var support := false
	if _drag_from >= 0:
		var f := sk.mechs[_drag_from].face()
		if f != null and f.is_attack():
			targets = sk.targets_for(_drag_from)
		elif f != null and f.kind != Face.Kind.BLANK:
			support = true

	for col in range(Skirmish.COLUMNS):
		var front_foe := sk.foe_at(0, col)
		var massive := front_foe != null and front_foe.is_massive()
		var mv: UnitView = _massive_views[col]
		mv.visible = massive
		if massive:
			_fill_foe_view(mv, front_foe, targets)
			_view_foe[mv] = front_foe
		for rank in range(2):
			var v: UnitView = _slot_views[rank][col]
			v.visible = not massive
			if massive:
				continue
			var foe := sk.foe_at(rank, col)
			if foe == null:
				v.display_name = ""
				v.bars = []
				v.intent = "exposed" if rank == 1 else ""
				v.intent_glyph = ""
				v.highlight = false
				v.dead = false
				v.modulate = Color(1, 1, 1, 0.25)
				v.queue_redraw()
				continue
			v.modulate = Color.WHITE
			_fill_foe_view(v, foe, targets)
			_view_foe[v] = foe

	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		var v := _mech_views[i]
		v.bars = [
			[ms.unit.hull, ms.unit.hull_max, Palette.HULL],
			[ms.unit.shield, ms.unit.shield_max, Palette.SHIELD],
			[ms.heat, ms.heat_max, Palette.HEAT],
		]
		v.dead = not ms.alive()
		v.highlight = support and ms.alive()
		v.intent = ""
		v.queue_redraw()
		var d := _dice[i]
		d.set_face(ms.face())
		d.spent = ms.assigned
		d.dead = not ms.alive()
		d.locked = locked[i]
		d.usable = ms.alive() and not ms.assigned and sk.state == Skirmish.State.ASSIGN
		d.queue_redraw()

	var lines: Array[String] = []
	var start := maxi(0, sk.log.size() - 7)
	for j in range(start, sk.log.size()):
		lines.append(sk.log[j])
	_log.text = "\n".join(lines)

	var assigning := sk.state == Skirmish.State.ASSIGN
	_reroll_btn.text = "Reroll (%d)" % sk.rerolls_left
	_reroll_btn.disabled = not assigning or sk.rerolls_left <= 0
	_end_btn.disabled = not assigning and sk.state != Skirmish.State.ROUND_START
	_withdraw_btn.disabled = not sk.can_withdraw()
	_refresh_arrows()


func _fill_foe_view(v: UnitView, foe: Foe, targets: Array[Foe]) -> void:
	v.display_name = foe.display_name
	v.bars = [[foe.hp, foe.hp_max, Palette.ENEMY]]
	v.dead = not foe.alive()
	v.highlight = targets.has(foe)
	if foe.suppressed:
		v.intent = "suppressed"
		v.intent_glyph = "suppress"
	elif foe.target != null:
		v.intent = "%d" % foe.attack
		v.intent_glyph = "line"
	else:
		v.intent = ""
		v.intent_glyph = ""
	if foe.burn > 0:
		v.intent += "  burn %d" % foe.burn
	v.queue_redraw()


func _foe_view_for(foe: Foe) -> UnitView:
	for v in _view_foe.keys():
		if _view_foe[v] == foe:
			return v
	return null


func _refresh_arrows() -> void:
	var list: Array = []
	var inv := _arrows.get_global_transform().affine_inverse()
	for foe in sk.field_foes():
		if foe.target == null or foe.suppressed:
			continue
		var target_index := sk.mechs.find(foe.target)
		if target_index < 0:
			continue
		var wanted := show_all_arrows or foe == _hold_foe or target_index == _hold_mech
		if not wanted:
			continue
		var fv := _foe_view_for(foe)
		if fv == null:
			continue
		var from: Vector2 = inv * fv.anchor_global()
		var to: Vector2 = inv * _mech_views[target_index].anchor_global()
		list.append([from, to, Palette.ENEMY])
	_arrows.set_arrows(list)


func _show_details(text: String, near: Control) -> void:
	_details_label.text = text
	_details.visible = true
	_details.reset_size()
	var pos := near.position + Vector2(near.size.x + 8.0, 0)
	if pos.x + 300.0 > W:
		pos.x = near.position.x - 308.0
	_details.position = pos


# ---------------------------------------------------------------- gestures

func _on_die_tapped(i: int) -> void:
	if sk.state != Skirmish.State.ASSIGN:
		return
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive() or ms.assigned:
		return
	locked[i] = not locked[i]
	_refresh()


func _on_die_held(i: int) -> void:
	var ms: Skirmish.MechState = sk.mechs[i]
	var f := ms.face()
	var text := "%s\n%s" % [ms.unit.display_name, f.describe() if f != null else ""]
	text += "\nhull %d/%d · shield %d/%d · heat %d/%d" % [ms.unit.hull, ms.unit.hull_max, ms.unit.shield, ms.unit.shield_max, ms.heat, ms.heat_max]
	if not ms.unit.passive.is_empty():
		text += "\n%s: %s" % [ms.unit.passive.get("name", ""), "; ".join(ms.unit.passive.get("rules", []))]
	_show_details(text, _dice[i])


func _on_foe_held(v: UnitView) -> void:
	var foe: Foe = _view_foe.get(v, null)
	if foe == null:
		return
	_hold_foe = foe
	var text := "%s\nhp %d/%d · attack %d" % [foe.display_name, foe.hp, foe.hp_max, foe.attack]
	if foe.target != null:
		text += "\n→ %s" % foe.target.unit.display_name
	if not foe.injures.is_empty():
		text += "\ninjures: %s" % foe.injures
	if foe.is_massive():
		text += "\nmassive: fills the column"
	_show_details(text, v)
	_refresh_arrows()


func _on_mech_held(i: int) -> void:
	_hold_mech = i
	var ms: Skirmish.MechState = sk.mechs[i]
	var text := "%s\nhull %d/%d · shield %d/%d · heat %d/%d" % [ms.unit.display_name, ms.unit.hull, ms.unit.hull_max, ms.unit.shield, ms.unit.shield_max, ms.heat, ms.heat_max]
	var incoming := 0
	for foe in sk.field_foes():
		if foe.target == ms and not foe.suppressed:
			incoming += foe.attack
	text += "\nincoming this round: %d" % incoming
	if not ms.unit.passive.is_empty():
		text += "\n%s" % ms.unit.passive.get("name", "")
	_show_details(text, _mech_views[i])
	_refresh_arrows()


func _on_foe_double_tapped(v: UnitView) -> void:
	var foe: Foe = _view_foe.get(v, null)
	if foe != null:
		_open_codex(ContentDB.load_default().codex_for_foe(foe))


func _on_mech_double_tapped(i: int) -> void:
	_open_codex(ContentDB.load_default().codex_for_unit(sk.mechs[i].unit))


func _open_codex(entry: Dictionary) -> void:
	_details.visible = false
	_hold_foe = null
	_hold_mech = -1
	_refresh_arrows()
	_codex_title.text = str(entry.get("title", ""))
	_codex_sub.text = str(entry.get("subtitle", ""))
	_codex_fantasy.text = str(entry.get("fantasy", ""))
	_codex_stats.text = str(entry.get("stats", ""))
	_codex_question.text = str(entry.get("question", ""))
	_codex_passive.text = str(entry.get("passive", ""))
	_codex_passive.visible = not _codex_passive.text.is_empty()
	_codex_flavour.text = str(entry.get("flavour", ""))
	_codex_flavour.visible = not _codex_flavour.text.is_empty()
	_codex_shade.visible = true
	_codex.visible = true
	_codex.reset_size()


func _close_codex() -> void:
	_codex.visible = false
	_codex_shade.visible = false


func _toggle_all_arrows(on: bool) -> void:
	show_all_arrows = on
	_refresh_arrows()


func _on_hold_released() -> void:
	_details.visible = false
	_hold_foe = null
	_hold_mech = -1
	_refresh_arrows()


func _on_drag_started(i: int) -> void:
	_drag_from = i
	_ghost.set_face(sk.mechs[i].face())
	_ghost.visible = true
	_refresh()


func _on_drag_moved(global_pos: Vector2) -> void:
	if not _ghost.visible:
		return
	var local: Vector2 = get_global_transform().affine_inverse() * global_pos
	_ghost.position = local - _ghost.size * 0.5


func _on_drag_ended(global_pos: Vector2) -> void:
	var i := _drag_from
	_drag_from = -1
	_ghost.visible = false
	if i < 0:
		_refresh()
		return
	var target = _drop_target_at(global_pos)
	if target != null:
		_use_die(i, target)
	_refresh()


## What sits under a global point: a Foe, a MechState, or null.
func _drop_target_at(global_pos: Vector2):
	for v in _view_foe.keys():
		if v.visible and v.get_global_rect().has_point(global_pos):
			return _view_foe[v]
	for j in range(_mech_views.size()):
		if _mech_views[j].get_global_rect().has_point(global_pos):
			return sk.mechs[j]
	return null


## Spend die `i` on `target` (a Foe or a MechState). Returns whether the simulation accepted it.
func _use_die(i: int, target) -> bool:
	if sk.state != Skirmish.State.ASSIGN:
		return false
	var ok := sk.assign(i, target)
	if ok:
		locked[i] = false
	_refresh()
	return ok


func _on_reroll() -> void:
	var idx: Array = []
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		if ms.alive() and not ms.assigned and not locked[i]:
			idx.append(i)
	sk.reroll(idx)
	_refresh()


func _on_end_round() -> void:
	if sk.state == Skirmish.State.ROUND_START:
		_start_next_round()
		return
	if sk.state != Skirmish.State.ASSIGN:
		return
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		if ms.alive() and not ms.assigned and ms.face() != null and ms.face().kind == Face.Kind.BLANK:
			sk.assign(i, null)
	var outcome := sk.end_round()
	if outcome != Skirmish.Outcome.NONE:
		_show_outcome(outcome)
	else:
		_end_btn.text = "Next round"
		_refresh()


func _start_next_round() -> void:
	if sk.state != Skirmish.State.ROUND_START:
		return
	sk.start_round()
	for i in range(locked.size()):
		locked[i] = false
	_end_btn.text = "End round"
	_refresh()


func _on_withdraw() -> void:
	if sk.withdraw():
		_show_outcome(sk.outcome)


func _show_outcome(outcome: int) -> void:
	_refresh()
	match outcome:
		Skirmish.Outcome.VICTORY:
			_overlay_title.text = "VICTORY"
			_overlay_text.text = "The squad is gone. Rift pressure rose by %d." % sk.round
		Skirmish.Outcome.DEFEAT:
			_overlay_title.text = "WRECKED"
			_overlay_text.text = "Every machine is down. Survivors of the squad march on."
		_:
			_overlay_title.text = "WITHDREW"
			_overlay_text.text = "%d foes remain on the field and %d wait in the pool. They keep marching." % [sk.field_foes().size(), sk.pool.size()]
	_overlay.visible = true
	finished.emit(outcome)

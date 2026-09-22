class_name BattleScreen
extends Control

## The battle: the battlefield map with the phase loop around it, in the overlay style.
## Portrait, 720x1280 logical, absolute layout.
##
##   header   phase, gate hull, Rift Pressure; plan readout beside it
##   map      drag to scroll; tap a mech to select it and light up where it can go; tap a lit
##            hex to plot the route there; tap the mech again to clear it; hold a unit for
##            its numbers
##   log      what the last phase did
##   bottom   Resolve bottom-left, Clear routes bottom-right
##
## Contact opens the skirmish screen over the map. Its Back button applies the result and
## either opens the next skirmish or returns to the plan.

signal back_requested

const SKIRMISH_SCENE := preload("res://game/skirmish/skirmish_screen.tscn")

const W := 720.0
const H := 1280.0
const MAP_Y := 56.0
const LOG_Y := 1076.0
const INFO_H := 112.0   # the readout's own strip between the map and the log
const LOG_H := 104.0
const BOTTOM_Y := 1196.0
const BOTTOM_BTN := Vector2(210, 60)
const LOG_LINES := 4

var battle: Battle

var _header: HudButton
var _sub_label: Label
var _map: BattleMapView
var _log: RichTextLabel
var _resolve_btn: HudButton
var _clear_btn: HudButton
var _details: HudPanel
var _details_label: Label
var _tuner: MapTuner = null
var _scan: ScanBar = null


## The screen's scan bar: the skirmish backdrop's band, drawn last so it rides over every
## control, and told where the map is so the map can light the traces under it.
class ScanBar extends Control:
	const SPEED := 140.0
	var map: BattleMapView
	var map_y: float = 0.0
	var _t := 0.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_process(true)

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		# A sweep, then a pause (Ryan, 22 September: back to back was busy).
		if map != null and not map.sweep_on:
			map.sweep_at(-1.0e6)   # the scan is off: no band, and the lights go out
			return
		var sweep := (size.y + 120.0) / SPEED
		var t := fmod(_t, sweep + HudBackdrop.SCAN_PAUSE)
		# The band keeps travelling below the screen through the pause, so the traces'
		# tails fade out on their own; switching the sweep off snapped them to black
		# (Ryan, 22 September).
		var y := t * SPEED - 60.0
		if t > sweep:
			if map != null:
				map.sweep_at(y - map_y)
			return
		for i in range(-2, 3):
			draw_rect(Rect2(0.0, y + i * 3.0, size.x, 1.0), Color(1, 1, 1, 0.07 - 0.015 * absi(i)))
		if map != null:
			map.sweep_at(y - map_y)
var _overlay: Control
var _overlay_title: Label
var _overlay_text: Label
var _skirmish: SkirmishScreen = null


func setup(b: Battle) -> void:
	battle = b
	_build()
	_refresh()


func _ready() -> void:
	Settings.apply()
	if battle == null:
		setup(_default_battle())
	elif _header == null:
		_build()
		_refresh()


## Standalone default, used when the scene runs on its own (screenshots, quick checks).
## RIFTGATE_TEAM=badger,clydesdale,sparrowhawk,anvil overrides the team; RIFTGATE_FACTION picks
## the enemy.
static func _default_battle() -> Battle:
	var db := ContentDB.load_default()
	var b := Battle.new(7)
	var team: Array = []
	var ids: Array = db.default_team()
	var env := OS.get_environment("RIFTGATE_TEAM")
	if not env.is_empty():
		ids = env.split(",")
	for id in ids:
		if db.chassis.has(id):
			team.append(db.make_mech(id))
	var fac := OS.get_environment("RIFTGATE_FACTION")
	if fac.is_empty() or not db.factions.has(fac):
		fac = db.default_faction()
	b.setup(team, fac)
	return b


# ---------------------------------------------------------------- build

var _codex: CodexBox = null


func _build() -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = Vector2(W, H)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := HudBackdrop.new()
	bg.scan = false   # this screen's one scan bar is drawn on top of everything, below
	bg.rules = [MAP_Y - 6.0, LOG_Y - 10.0 - INFO_H, LOG_Y - 10.0, BOTTOM_Y - 16.0]
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_header = _tag("", 13, true)
	_place(_header, Vector2(12, 14), Vector2(300, 28))
	var menu_btn := HudButton.new("MENU", _open_menu)
	_place(menu_btn, Vector2(W - 96, 10), Vector2(84, 34))
	if OS.get_environment("RIFTGATE_TUNE") == "1":
		# The map's live knobs, a development tool; the player's knobs are in the menu.
		var tune_btn := HudButton.new("TUNE", _toggle_tuner)
		_place(tune_btn, Vector2(W - 190, 10), Vector2(84, 34))
	_sub_label = Hud.label("", 12, Color(Palette.HUD, 0.7), Hud.mono())
	_place(_sub_label, Vector2(326, 20), Vector2(380, 20))

	_map = BattleMapView.new()
	_place(_map, Vector2(0, MAP_Y), Vector2(W, LOG_Y - 10.0 - INFO_H - MAP_Y))
	_map.set_field(battle.field)
	_map.hex_tapped.connect(_on_hex_tapped)
	_map.hex_double_tapped.connect(_on_hex_double_tapped)
	_map.unit_held.connect(_on_unit_held)
	_apply_display()
	_map.hold_released.connect(_on_hold_released)

	var log_tag := _tag("LOG", 10, true)
	_place(log_tag, Vector2(12, LOG_Y), Vector2(52, 18))
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_active = false
	_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_log.add_theme_font_override("normal_font", Hud.mono())
	_log.add_theme_font_size_override("normal_font_size", 14)
	_log.add_theme_color_override("default_color", Palette.HUD)
	_place(_log, Vector2(20, LOG_Y + 22), Vector2(W - 40, LOG_H - 22))

	_resolve_btn = HudButton.new("RESOLVE", _on_resolve)
	_resolve_btn.filled = true
	_place(_resolve_btn, Vector2(16, BOTTOM_Y), BOTTOM_BTN)
	_clear_btn = HudButton.new("CLEAR ROUTES", _on_clear)
	_clear_btn.ghost = true
	_place(_clear_btn, Vector2(W - 16 - BOTTOM_BTN.x, BOTTOM_Y), BOTTOM_BTN)

	# The readout lives in one place, docked over the bottom of the map (thumbs, not a
	# mouse: Ryan, 21 September), and a tap on it dismisses it.
	_details = HudPanel.new(14.0)
	_details.mouse_filter = Control.MOUSE_FILTER_STOP
	_details.visible = false
	_details.custom_minimum_size = Vector2(W - 24.0, 0)
	_details.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_details.visible = false
			_details.accept_event())
	add_child(_details)
	_details_label = Hud.label("", 16, Palette.INK)
	_details.add_child(_details_label)
	# One scan bar over the whole screen, on the top layer: it crosses the map and the
	# controls alike, and whatever geometry lies under it lights (Ryan, 21 September).
	_codex = CodexBox.new()
	add_child(_codex)
	_scan = ScanBar.new()
	_scan.map = _map
	_scan.map_y = MAP_Y
	_place(_scan, Vector2.ZERO, Vector2(W, H))

	_build_outcome()


func _build_outcome() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.72)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	add_child(_overlay)
	var oc := CenterContainer.new()
	oc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(oc)
	var op := HudPanel.new(28.0)
	oc.add_child(op)
	var ov := VBoxContainer.new()
	ov.add_theme_constant_override("separation", 14)
	op.add_child(ov)
	_overlay_title = Hud.label("", 44, Palette.HUD, Hud.display_bold())
	_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ov.add_child(_overlay_title)
	_overlay_text = Hud.label("", 18, Palette.MUTED)
	_overlay_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	_overlay_text.custom_minimum_size = Vector2(420, 0)
	ov.add_child(_overlay_text)
	var back := HudButton.new("BACK", func() -> void: back_requested.emit())
	back.custom_minimum_size = Vector2(0, 54)
	ov.add_child(back)


func _place(c: Control, pos: Vector2, sz: Vector2) -> void:
	c.position = pos
	c.size = sz
	add_child(c)


func _tag(text: String, size_px: int, mono: bool) -> HudButton:
	var t := HudButton.new(text)
	t.filled = true
	t.mono = mono
	t.font_size = size_px
	t.slant_px = 8.0
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


# ---------------------------------------------------------------- refresh

func _refresh() -> void:
	var f := battle.field
	var planning := battle.state == Battle.State.PLAN
	# Plain words (Ryan, 22 September): the round, and how long until the rift spawns. The
	# gate's integrity is on the map, under the gate.
	_header.text = "ROUND %02d // NEXT SPAWN IN %d" % [f.phase + 1, f.rift_pressure_max - f.rift_pressure]
	_header.queue_redraw()
	match battle.state:
		Battle.State.PLAN:
			_sub_label.text = "ORDERS // %d OF %d SET" % [battle.routes.size(), battle.mechs().size()]
		Battle.State.SKIRMISH:
			_sub_label.text = "CONTACT"
		_:
			_sub_label.text = "BATTLE OVER"
	_map.routes = battle.routes
	_map.pending = battle.pending if battle.state == Battle.State.SKIRMISH else []
	_map.queue_redraw()
	_refresh_log()
	_resolve_btn.set_enabled(planning)
	_clear_btn.set_enabled(planning and not battle.routes.is_empty())


func _refresh_log() -> void:
	var lines: Array[String] = battle.field.log
	var start := maxi(0, lines.size() - LOG_LINES)
	var count := lines.size() - start
	var out := ""
	if count == 0:
		out = "[color=#%s]> round %d // %d squads on the field // give orders, then resolve[/color]" % [
			Color(Palette.HUD, 0.45).to_html(true), battle.field.phase + 1, battle.field.squads().size()]
	for j in range(start, lines.size()):
		var age := j - start
		var a := 1.0 if count <= 1 else lerpf(0.4, 1.0, float(age) / float(count - 1))
		out += "[color=#%s]> %s[/color]\n" % [Color(Palette.HUD, a).to_html(true), lines[j]]
	_log.text = out


func _select(u: Unit) -> void:
	_map.selected = u
	_map.destinations = battle.destinations_for(u) if u != null else {}


# ---------------------------------------------------------------- gestures

## Tap a mech to select it; tap a lit hex to plot its route; tap the selected mech again to
## clear its route; tap anything else to deselect.
func _on_hex_tapped(h: Vector2i) -> void:
	if battle.state != Battle.State.PLAN:
		return
	_details.visible = false
	var u := battle.field.unit_at(h)
	_map.gate_selected = false
	if battle.field.map.gate_hexes.has(h) and (_map.selected == null or not _map.destinations.has(h)):
		# The gate is selectable for its integrity (Ryan, 22 September).
		_select(null)
		_map.gate_selected = true
		_show_details(gate_text(battle.field), Vector2.ZERO)
		_map.queue_redraw()
		return
	if _map.selected != null and u != _map.selected and _map.destinations.has(h):
		# A hex a machine plotted earlier is leaving is a destination too (Ryan, 22
		# September): plotting in order makes it free, so the tap routes there rather
		# than selecting the machine still drawn on it.
		battle.set_route(_map.selected, h)
		_select(null)
	elif u != null and u.is_player() and not u.is_static():
		if _map.selected == u:
			battle.clear_route(u.id)
			_select(null)
		else:
			_select(u)
			_on_unit_held(u)   # its shield, hull and move, in the readout
	elif u != null and u.is_enemy():
		_on_unit_held(u)   # a quick label for the enemy; double-tap for the codex
	elif _map.selected != null and _map.destinations.has(h):
		battle.set_route(_map.selected, h)
		_select(null)
	elif _map.selected == null and u == null and battle.field.map.has(h) and not battle.field.map.is_structure(h):
		# Nothing to route: the tap asks what the ground is (Ryan, 21 September). Its
		# properties will grow with the terrain rules.
		var t: int = battle.field.map.terrain[h]
		var who: Array[String] = []
		for pair in [["ground", []], ["hover", ["hover"]], ["flyer", ["flyer"]]]:
			if BattleMap.passable(t, pair[1]):
				who.append(pair[0])
		var text := "%s\nmove %d · %s" % [str(BattleMap.TERRAIN_NAMES.get(t, "ground")).to_upper(), BattleMap.move_cost(t, []), " · ".join(who) if not who.is_empty() else "impassable"]
		_show_details(text, _map.position + _map.to_screen(_map.center(h)))
		return
	else:
		_select(null)
	_refresh()


func _on_unit_held(u: Unit) -> void:
	var text := ""
	if u.is_player():
		text = "%s\nshield %d/%d · hull %d/%d · move %d" % [u.display_name, u.shield, u.shield_max, u.hull, u.hull_max, u.movespeed]
		if u.damaged_component_count() > 0:
			text += "\n%d damaged component%s" % [u.damaged_component_count(), "" if u.damaged_component_count() == 1 else "s"]
	else:
		var db := ContentDB.load_default()
		var foe_name := str(db.foes.get(u.foe_id, {}).get("name", u.foe_id))
		if u.elite:
			text = "%s\nmassive · %s" % [u.display_name, "hunting" if u.aggro else "to the gate"]
		else:
			text = "%s\n%s ×%d · move %d\n%s" % [u.display_name, foe_name, u.strength, u.movespeed, "hunting the nearest machine" if u.aggro else "marching on the gate"]
	_show_details(text, _map.position + _map.to_screen(_map.center(u.pos)))


func _on_hold_released() -> void:
	_details.visible = false


# ---------------------------------------------------------------- the menu

var _menu: PauseMenu = null
var _built_hud := ""   # the HUD colour this screen was built with; a change rebuilds it

func _open_menu() -> void:
	if _menu == null:
		_menu = PauseMenu.new()
		_menu.display_changed.connect(func(_key: String, _value: Variant) -> void: _apply_display())
		_menu.hud_changed.connect(_rebuild)
		add_child(_menu)
	_menu.move_to_front()
	_menu.open()


## The player's display knobs onto the map: the compositor's uniforms, the scene's glow,
## the scan bar, and the pace of moves.
func _apply_display() -> void:
	var d := Settings.display
	_map.tune("brightness", float(d["brightness"]))
	_map.tune("flicker", 1.0 if bool(d["glitch"]) else 0.0)
	_map.sweep_on = bool(d["scan"])   # off: the bar stays hidden and the traces rest as ink
	BattleMapView.pace = float(d["pace"])
	_built_hud = Settings.hud


## A colour change rebuilds the screen from the battle (the skirmish, if one is open,
## rebuilds itself and this screen catches up when it returns).
func _rebuild() -> void:
	if _skirmish != null:
		return
	_build()
	_refresh()


func _toggle_tuner() -> void:
	if _tuner == null:
		_tuner = MapTuner.new(_map)
		add_child(_tuner)
		_tuner.position = Vector2(W - 380.0, MAP_Y + 12.0)
	else:
		_tuner.visible = not _tuner.visible


## Double-tap a unit for its codex (Ryan, 22 September: the player needs that on the map
## as much as in the fight). A machine's entry is its own; a squad's is its foe type's,
## headed by the squad.
func _on_hex_double_tapped(h: Vector2i) -> void:
	if battle.state == Battle.State.DONE:
		return
	var u := battle.field.unit_at(h)
	if u == null and battle.field.map.gate_hexes.has(h):
		_details.visible = false
		_codex.move_to_front()
		_codex.open(gate_codex_entry(battle.field))
		return
	if u == null:
		return
	_details.visible = false
	_codex.move_to_front()
	_codex.open(codex_entry_for(u))


## The gate's readout and codex entry. The text is the rule, not lore: CARE's voice for
## the projector is Ryan's to write.
static func gate_text(f: Battlefield) -> String:
	return "THE GATE\nintegrity %d/%d\nfield projector · a squad on the apron strikes it" % [f.gate_hp, f.gate_hp_max]


static func gate_codex_entry(f: Battlefield) -> Dictionary:
	return {
		"title": "The Gate",
		"designation": "CARE FIELD PROJECTOR",
		"subtitle": "THE CITY'S ENCLOSURE // THE LINE THE MACHINES HOLD",
		"stat_items": [["integrity", "%d/%d" % [f.gate_hp, f.gate_hp_max]], ["rows", str(BattleMap.GATE_ROWS)]],
		"body": "The projector that holds the field over the city. A squad that reaches the apron strikes it for a third of its strength each phase, at least ten; when its integrity is gone the field is down and the battle is lost. Machines may stand on it; nothing else may.",
		"flavour": "",
	}


static func codex_entry_for(u: Unit) -> Dictionary:
	var db := ContentDB.load_default()
	if u.is_player():
		var entry := db.codex_for_unit(u)
		entry["paint"] = u.paint
		return entry
	var fid := BattleMapView.foe_sprite_id(u)
	if not db.foes.has(fid):
		return {"title": u.display_name, "subtitle": str(u.faction).to_upper(), "body": ""}
	var entry := db.codex_for_foe(db.make_foe(fid))
	entry["title"] = u.display_name
	entry["subtitle"] = "%s // %s" % [entry["subtitle"], ("BOSS" if u.elite else "×%d // MOVE %d" % [u.strength, u.movespeed])]
	return entry


## Readout beside a point on the screen, kept inside the frame.
func _show_details(text: String, _near: Vector2) -> void:
	_details_label.text = text
	_details.visible = true
	_details.reset_size()
	_details.position = Vector2(12.0, LOG_Y - 10.0 - INFO_H + 6.0)


# ---------------------------------------------------------------- the loop

func _on_clear() -> void:
	battle.clear_routes()
	_select(null)
	_refresh()


func _on_resolve() -> void:
	if battle.state != Battle.State.PLAN:
		return
	_select(null)
	_details.visible = false
	# Capture where everyone meant to go, resolve, then play what actually happened: each
	# path cut at the hex the unit really reached (a block or a rejection stops it short).
	var planned: Dictionary = {}
	for m in battle.mechs():
		planned[m.id] = [m.pos] + Array(battle.routes.get(m.id, []))
	var starts: Dictionary = {}
	for sq in battle.field.squads():
		starts[sq.id] = sq.pos
	# The squads' paths are the resolve's own, planned after the machines moved.
	var result := battle.commit()
	for sid in starts.keys():
		planned[sid] = [starts[sid]] + Array(result.intents.get(sid, []))
	var mech_moves: Array = []
	var squad_moves: Array = []
	for u in battle.field.units:
		if not planned.has(u.id):
			continue
		var path: Array = planned[u.id]
		var at: int = path.find(u.pos)
		var played: Array = path.slice(0, at + 1) if at >= 0 else [path[0], u.pos]
		if u.is_player():
			mech_moves.append([u.id, played])
		else:
			squad_moves.append([u.id, played])
	if DisplayServer.get_name() == "headless":
		_after_step()
	else:
		_map.play_moves(mech_moves, squad_moves, _after_step)


func _after_step() -> void:
	match battle.state:
		Battle.State.SKIRMISH:
			_show_contacts()
		Battle.State.DONE:
			_refresh()
			_show_outcome()
		_:
			_refresh()


## The contacts this phase, before any opens (Ryan, 22 September): how many, who is in
## each, and the player picks which to fight first and confirms. The map keeps showing
## them tagged behind the panel.
func _show_contacts() -> void:
	_refresh()
	if _contacts != null:
		_contacts.queue_free()
		_contacts = null
	# First the warning, big and red over the map; then the panel slides in and the map
	# zooms to the first contact (Ryan, 22 September: dramatic, and in the player's face).
	# On a black band with red rules across the map, and the map dimmed under it: red on
	# the terrain alone never reads (Ryan, 22 September).
	var warn := Control.new()
	warn.position = Vector2(0, MAP_Y)
	warn.size = Vector2(W, LOG_Y - 10.0 - INFO_H - MAP_Y)
	warn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.size = warn.size
	warn.add_child(dim)
	var band := ColorRect.new()
	band.color = Color(0, 0, 0, 0.92)
	band.position = Vector2(0, 260.0)
	band.size = Vector2(W, 150.0)
	warn.add_child(band)
	for y in [band.position.y, band.position.y + band.size.y - 4.0]:
		var rule := ColorRect.new()
		rule.color = Palette.ENEMY
		rule.position = Vector2(0, y)
		rule.size = Vector2(W, 4.0)
		warn.add_child(rule)
	var text := Hud.label("CONTACT", 84, Palette.ENEMY, Hud.display_bold())
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.position = band.position
	text.size = band.size
	warn.add_child(text)
	var sub := Hud.label("%d SKIRMISH%s // ENGAGE" % [battle.pending.size(), "" if battle.pending.size() == 1 else "ES"], 16, Palette.INK, Hud.mono())
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, band.position.y + band.size.y - 34.0)
	sub.size = Vector2(W, 20)
	warn.add_child(sub)
	warn.modulate = Color(1, 1, 1, 0)
	add_child(warn)
	var tw := create_tween()
	# Two beats, drawn out (Ryan, 22 September: one flash looked accidental).
	tw.tween_property(warn, "modulate", Color(1, 1, 1, 1), 0.3)
	tw.tween_interval(0.6)
	for _i in range(1):
		tw.tween_property(warn, "modulate", Color(1, 1, 1, 0.1), 0.15)
		tw.tween_interval(0.12)
		tw.tween_property(warn, "modulate", Color(1, 1, 1, 1), 0.15)
		tw.tween_interval(0.55)
	tw.tween_property(warn, "modulate", Color(1, 1, 1, 0), 0.4)
	tw.tween_callback(warn.queue_free)
	tw.tween_callback(_build_contact_panel)
	if DisplayServer.get_name() == "headless":
		tw.kill()
		warn.queue_free()
		_build_contact_panel()


## The contact panel: one contact at a time, with portraits, paged with arrows; paging
## zooms the map to that fight and lights its hexes.
var _contact_index := 0

func _build_contact_panel() -> void:
	_contact_index = 0
	_contacts = HudPanel.new(16.0)
	_contacts.position = Vector2(12.0, LOG_Y - 10.0 - INFO_H - 200.0)
	_contacts.custom_minimum_size = Vector2(W - 24.0, 300.0)
	add_child(_contacts)
	_fill_contact_panel()
	var start := _contacts.position + Vector2(0, 240.0)
	var end := _contacts.position
	_contacts.position = start
	var tw := create_tween()
	tw.tween_property(_contacts, "position", end, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _fill_contact_panel() -> void:
	for c in _contacts.get_children():
		c.queue_free()
	var n := battle.pending.size()
	_contact_index = clampi(_contact_index, 0, n - 1)
	var group: Array = battle.pending[_contact_index]
	var rows := VBoxContainer.new()
	rows.position = Vector2(14, 12)
	rows.size = Vector2(W - 52.0, 276.0)
	rows.add_theme_constant_override("separation", 8)
	_contacts.add_child(rows)
	# Header: which contact this is, and the arrows.
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	var prev_btn := HudButton.new("◀", func() -> void:
		_contact_index = (_contact_index - 1 + n) % n
		_fill_contact_panel())
	prev_btn.custom_minimum_size = Vector2(54, 40)
	prev_btn.visible = n > 1
	head.add_child(prev_btn)
	var title := Hud.label("CONTACT %d OF %d" % [_contact_index + 1, n], 22, Palette.ENEMY, Hud.display_bold())
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_child(title)
	var next_btn := HudButton.new("▶", func() -> void:
		_contact_index = (_contact_index + 1) % n
		_fill_contact_panel())
	next_btn.custom_minimum_size = Vector2(54, 40)
	next_btn.visible = n > 1
	head.add_child(next_btn)
	rows.add_child(head)
	# Portraits: the machines, a VS, the squads.
	var faces := HBoxContainer.new()
	faces.alignment = BoxContainer.ALIGNMENT_CENTER
	faces.add_theme_constant_override("separation", 10)
	var db := ContentDB.load_default()
	for u in group:
		if not u.is_player():
			continue
		faces.add_child(_portrait_mech(u, db))
	var vs := Hud.label("VS", 26, Palette.MUTED, Hud.display_bold())
	vs.custom_minimum_size = Vector2(60, 0)
	vs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	faces.add_child(vs)
	for u in group:
		if not u.is_enemy():
			continue
		faces.add_child(_portrait_squad(u))
	rows.add_child(faces)
	var gap := Control.new()   # the portraits say who; ENGAGE sits at the foot of the panel
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(gap)
	var btn := HudButton.new("ENGAGE", _open_skirmish.bind(_contact_index))
	btn.filled = true
	btn.custom_minimum_size = Vector2(0, 54)
	rows.add_child(btn)
	# The map looks at this fight and dims the others.
	var hexes: Array = []
	var mid := Vector2.ZERO
	for u in group:
		hexes.append(u.pos)
		mid += _map.center(u.pos)
	mid /= float(group.size())
	_map.set_highlight(hexes)
	_map.focus_on(mid + Vector2(0, 90.0), 1.9)


func _portrait_mech(u: Unit, db: ContentDB) -> Control:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var maker := str(db.chassis.get(u.chassis_id, {}).get("maker", "minerva"))
	var view := MechView3D.make(u.chassis_id, maker, "clean", "badger", MechView3D.YAW_FRONT, Vector2i(96, 96), false, u.paint)
	add_child(view)
	view.strip_silhouette()
	var tr := TextureRect.new()
	tr.texture = view.texture
	tr.custom_minimum_size = Vector2(96, 96)
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(tr)
	var lbl := Hud.label(str(u.display_name), 11, Palette.HUD, Hud.mono())
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(lbl)
	return box


func _portrait_squad(u: Unit) -> Control:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var tr := TextureRect.new()
	var fid := BattleMapView.foe_sprite_id(u)
	tr.texture = Sprites.combat_foe(fid)   # the battle sprite, as the skirmish shows it
	if tr.texture == null:
		tr.texture = Sprites.map_foe(fid)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.custom_minimum_size = Vector2(96, 96)
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	box.add_child(tr)
	var lbl := Hud.label("%s ×%d" % [u.display_name, u.strength] if u.strength > 0 else str(u.display_name).to_upper(), 11, Palette.ENEMY, Hud.mono())
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(lbl)
	return box


var _contacts: Control = null


func _open_skirmish(index: int = 0) -> void:
	if _contacts != null:
		_contacts.queue_free()
		_contacts = null
	var group: Array = battle.pending[clampi(index, 0, battle.pending.size() - 1)] if not battle.pending.is_empty() else []
	var sk := battle.open_skirmish_at(index)
	if sk == null:
		_map.set_highlight([])
		_after_step()
		return
	var screen: SkirmishScreen = SKIRMISH_SCENE.instantiate()
	screen.sk = sk
	screen.back_label = "BACK TO THE FIELD"
	screen.setup(sk)
	screen.back_requested.connect(_on_skirmish_back)
	_skirmish = screen
	if DisplayServer.get_name() == "headless":
		_map.set_highlight([])
		add_child(screen)
		_refresh()
		return
	_play_handover(group, screen)


## The handover into the skirmish (decided 22 September): the reconstruction dives onto
## the contact, the other world's bleed grows out of the squad until the ground there has
## gone flat and bright, the display cuts to black, and the skirmish's feed fades up.
const HANDOVER_DIVE := 1.0
const HANDOVER_FLAT := 1.6      # the spread runs on past the dive before the cut (Ryan, 22 September)
const HANDOVER_FLAT_HEX := 7.5

func _play_handover(group: Array, screen: SkirmishScreen) -> void:
	var hexes: Array = []
	var mid := Vector2.ZERO
	var squad_mid := Vector2.ZERO
	var squads := 0
	for u in group:
		hexes.append(u.pos)
		mid += _map.center(u.pos)
		if u.is_enemy():
			squad_mid += _map._origin + Hex.to_pixel(u.pos, BattleMapView.HEX_SIZE)   # unlifted: what the bleed reads
			squads += 1
	mid /= maxf(1.0, float(group.size()))
	squad_mid = squad_mid / float(squads) if squads > 0 else mid
	_map.set_highlight(hexes)
	_map.pending = [group]        # the map stays frozen on this fight until the cut
	_map.flatten_at = squad_mid   # map pixels, as the bleed reads them
	_map.flatten_r = 0.0
	var z0 := _map.zoom
	var scroll0 := Vector2(_map.scroll_x, _map.scroll_y)
	var scrim := ColorRect.new()
	scrim.color = Color.BLACK
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.modulate = Color(1, 1, 1, 0)
	add_child(scrim)
	var tw := create_tween().set_parallel(true)
	tw.tween_method(func(t: float) -> void:
		_map.focus_on(mid, lerpf(z0, BattleMapView.ZOOM_MAX, t)), 0.0, 1.0, HANDOVER_DIVE).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_map, "flatten_r", HANDOVER_FLAT_HEX, HANDOVER_FLAT).set_delay(0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_property(scrim, "modulate", Color(1, 1, 1, 1), 0.3)
	tw.chain().tween_callback(func() -> void:
		add_child(screen)
		scrim.move_to_front()
		_map.flatten_r = 0.0
		_map.set_highlight([])
		_map.zoom = z0
		_map.scroll_x = scroll0.x
		_map.scroll_y = scroll0.y
		_map._clamp_scroll()
		_refresh())
	tw.chain().tween_property(scrim, "modulate", Color(1, 1, 1, 0), 0.4)
	tw.chain().tween_callback(scrim.queue_free)


## The skirmish's Back button: apply the result, then the next contact or back to the plan.
func _on_skirmish_back() -> void:
	if _skirmish != null:
		_skirmish.queue_free()
		_skirmish = null
	battle.finish_skirmish()
	if _built_hud != Settings.hud:
		_build()   # the colour changed in the skirmish's menu: this screen catches up
	_after_step()


func _show_outcome() -> void:
	var f := battle.field
	match battle.outcome:
		Battle.Outcome.VICTORY:
			_overlay_title.text = "RIFT SEALED"
			_overlay_text.text = "The %s is down. The gate holds at %d after %d phases and %d skirmishes." % [
				battle.boss.display_name if battle.boss != null else "boss", f.gate_hp, f.phase, battle.skirmishes_fought]
		Battle.Outcome.GATE_FALLEN:
			_overlay_title.text = "GATE FALLEN"
			_overlay_text.text = "The horde is in the city. Phase %d." % f.phase
		_:
			_overlay_title.text = "ALL WRECKED"
			_overlay_text.text = "Every machine is scrap. The gate stands at %d, undefended." % f.gate_hp
	_overlay.visible = true

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
		var sweep := (size.y + 120.0) / SPEED
		var t := fmod(_t, sweep + HudBackdrop.SCAN_PAUSE)
		if t > sweep:
			if map != null:
				map.sweep_at(-1.0e6)
			return
		var y := t * SPEED - 60.0
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
	# TUNE opens the map's live knobs (not a player feature).
	var tune_btn := HudButton.new("TUNE", _toggle_tuner)
	_place(tune_btn, Vector2(W - 96, 10), Vector2(84, 34))
	_sub_label = Hud.label("", 12, Color(Palette.HUD, 0.7), Hud.mono())
	_place(_sub_label, Vector2(326, 20), Vector2(380, 20))

	_map = BattleMapView.new()
	_place(_map, Vector2(0, MAP_Y), Vector2(W, LOG_Y - 10.0 - INFO_H - MAP_Y))
	_map.set_field(battle.field)
	_map.hex_tapped.connect(_on_hex_tapped)
	_map.hex_double_tapped.connect(_on_hex_double_tapped)
	_map.unit_held.connect(_on_unit_held)
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
	_header.text = "PHASE %02d // GATE %d // RIFT %d/%d" % [f.phase + 1, f.gate_hp, f.rift_pressure, f.rift_pressure_max]
	_header.queue_redraw()
	match battle.state:
		Battle.State.PLAN:
			_sub_label.text = "PLAN // %d OF %d ROUTES SET" % [battle.routes.size(), battle.mechs().size()]
		Battle.State.SKIRMISH:
			_sub_label.text = "CONTACT"
		_:
			_sub_label.text = "BATTLE OVER"
	_map.routes = battle.routes
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
		out = "[color=#%s]> phase %d // %d squads on the field // plot routes, then resolve[/color]" % [
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
	if u != null and u.is_player() and not u.is_static():
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


func _toggle_tuner() -> void:
	if _tuner == null:
		_tuner = MapTuner.new(_map)
		add_child(_tuner)
		_tuner.position = Vector2(W - 380.0, MAP_Y + 12.0)
	else:
		_tuner.visible = not _tuner.visible


## Double-tap a unit for its codex. The battle screen has no codex of its own yet, so for
## now it shows the full readout; the skirmish's codex is the one to host here.
func _on_hex_double_tapped(h: Vector2i) -> void:
	if battle.state != Battle.State.PLAN:
		return
	var u := battle.field.unit_at(h)
	if u != null:
		_on_unit_held(u)


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
	for sq in battle.field.squads():
		planned[sq.id] = [sq.pos] + Array(battle.field.intents.get(sq.id, []))
	battle.commit()
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
	_contacts = HudPanel.new(14.0)
	_contacts.custom_minimum_size = Vector2(W - 24.0, 0)
	var rows := VBoxContainer.new()
	rows.position = Vector2(12, 10)
	rows.add_theme_constant_override("separation", 6)
	_contacts.add_child(rows)
	var n := battle.pending.size()
	rows.add_child(Hud.label("%d CONTACT%s // CHOOSE THE FIRST" % [n, "" if n == 1 else "S"], 14, Palette.ENEMY))
	for i in range(n):
		var group: Array = battle.pending[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var btn := HudButton.new("ENGAGE", _open_skirmish.bind(i))
		btn.custom_minimum_size = Vector2(150, 34)
		row.add_child(btn)
		row.add_child(Hud.label(BattleMapView.contact_text(group), 13, Palette.INK))
		rows.add_child(row)
	add_child(_contacts)
	_contacts.reset_size()
	_contacts.position = Vector2(12.0, LOG_Y - 10.0 - INFO_H + 6.0)


var _contacts: HudPanel = null


func _open_skirmish(index: int = 0) -> void:
	if _contacts != null:
		_contacts.queue_free()
		_contacts = null
	var sk := battle.open_skirmish_at(index)
	if sk == null:
		_after_step()
		return
	var screen: SkirmishScreen = SKIRMISH_SCENE.instantiate()
	screen.sk = sk
	screen.setup(sk)
	screen.back_requested.connect(_on_skirmish_back)
	_skirmish = screen
	add_child(screen)
	_refresh()


## The skirmish's Back button: apply the result, then the next contact or back to the plan.
func _on_skirmish_back() -> void:
	if _skirmish != null:
		_skirmish.queue_free()
		_skirmish = null
	battle.finish_skirmish()
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

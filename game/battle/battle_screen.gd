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
	bg.rules = [MAP_Y - 6.0, LOG_Y - 10.0, BOTTOM_Y - 16.0]
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_header = _tag("", 13, true)
	_place(_header, Vector2(12, 14), Vector2(300, 28))
	_sub_label = Hud.label("", 12, Color(Palette.HUD, 0.7), Hud.mono())
	_place(_sub_label, Vector2(326, 20), Vector2(380, 20))

	_map = BattleMapView.new()
	_place(_map, Vector2(0, MAP_Y), Vector2(W, LOG_Y - 10.0 - MAP_Y))
	_map.set_field(battle.field)
	_map.hex_tapped.connect(_on_hex_tapped)
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

	_details = HudPanel.new(14.0)
	_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_details.visible = false
	_details.custom_minimum_size = Vector2(340, 0)
	add_child(_details)
	_details_label = Hud.label("", 16, Palette.INK)
	_details.add_child(_details_label)

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
	var u := battle.field.unit_at(h)
	if u != null and u.is_player() and not u.is_static():
		if _map.selected == u:
			battle.clear_route(u.id)
			_select(null)
		else:
			_select(u)
	elif _map.selected != null and _map.destinations.has(h):
		battle.set_route(_map.selected, h)
		_select(null)
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
	_show_details(text, _map.position + _map.center(u.pos))


func _on_hold_released() -> void:
	_details.visible = false


## Readout beside a point on the screen, kept inside the frame.
func _show_details(text: String, near: Vector2) -> void:
	_details_label.text = text
	_details.visible = true
	_details.reset_size()
	var width := 340.0
	var pos := near + Vector2(BattleMapView.HEX_SIZE, -BattleMapView.HEX_SIZE)
	if pos.x + width > W - 8.0:
		pos.x = near.x - BattleMapView.HEX_SIZE - width
	pos.x = clampf(pos.x, 8.0, W - width - 8.0)
	var height := maxf(_details.size.y, 80.0)
	pos.y = clampf(pos.y, MAP_Y + 8.0, LOG_Y - 8.0 - height)
	_details.position = pos


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
	battle.commit()
	_after_step()


func _after_step() -> void:
	match battle.state:
		Battle.State.SKIRMISH:
			_open_skirmish()
		Battle.State.DONE:
			_refresh()
			_show_outcome()
		_:
			_refresh()


func _open_skirmish() -> void:
	var sk := battle.open_next_skirmish()
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
	if battle.state == Battle.State.SKIRMISH:
		_open_skirmish()
	else:
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

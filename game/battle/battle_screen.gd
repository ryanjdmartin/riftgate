class_name BattleScreen
extends Control

## The battle: the battlefield map with the turn around it, in the overlay style (bible
## section 4, the round row). Portrait, 720x1280 logical, absolute layout.
##
##   header   the turn and Rift Pressure; the turn's readout beside it
##   map      drag to scroll; tap a machine to select it and light where it can move; tap a
##            lit hex (or draw a route from it) and it moves there at once; with a machine in
##            hand, tap a pack (or drag the machine onto one) and it moves into range and is
##            ordered onto that fight; hold a unit for its numbers. Every pack's walk on the
##            enemy's turn shows, a hunter's lock on its prey, and the next fight: its target,
##            the packs whose ring covers it, the machines ordered onto it
##   bottom   ENGAGE (while a fight is ready) or END TURN bottom-left, Undo move bottom-right
##
## A fight opens the skirmish screen over the map. Its Back button applies the result, and
## the turn goes on; End turn plays the enemy's turn.

signal back_requested
signal quit_requested   # the menu's QUIT, on this screen or in an open skirmish: out to the harness

const SKIRMISH_SCENE := preload("res://game/skirmish/skirmish_screen.tscn")

const W := 720.0
const BASE_H := 1280.0   # the design's height; a taller phone gives the extra to the map
var H := BASE_H
const MAP_Y := 56.0
var LOG_Y := 1076.0
const INFO_H := 112.0   # the readout's own strip between the map and the log
const LOG_H := 104.0   # the log's old strip; the board and the readout have it now
var STRIP_Y := 954.0
var STRIP_H := 226.0
var BOTTOM_Y := 1196.0
const BOTTOM_BTN := Vector2(210, 60)
const LOG_LINES := 4

var battle: Battle
## Save the battle after every change (user://battle.json, `SaveGame`), so it resumes where
## it stood. On for a battle the harness starts or resumes; off for standalone runs and
## tests, which must never overwrite a real one.
var autosave_enabled := false
var save_path: String = SaveGame.PATH   # where the autosave goes; the tests point it elsewhere

var _header: HudButton
var _sub_label: Label
var _map: BattleMapView
var _resolve_btn: HudButton
var _clear_btn: HudButton
var _details: HudPanel
var _details_label: Label
var _board: OrdersBoard
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
	Hud.oversample(get_window())   # standalone runs too: text at the glass's density
	if battle == null:
		setup(_default_battle())
	elif _header == null or H != Hud.screen_height(self):
		_build()   # built here for the screen's real height (a taller phone than the design)
		_refresh()
	# The loop from the top, and only once the map has been built and drawn (a new battle
	# is not a fight's return, which resumes where the map's music left off).
	_start_music.call_deferred()
	_resume_where_it_was()
	_autosave()


## A battle handed over mid-flight (a save read back): a fight under way opens straight
## into the skirmish, no handover; a decided battle shows its outcome. A turn needs nothing:
## the map shows its orders and any catch, and the button reads ENGAGE.
func _resume_where_it_was() -> void:
	if battle.current != null:
		_enter_skirmish(battle.current, [], false)
	elif battle.state == Battle.State.DONE:
		_after_step()


## The battle as it stands, to the save, when saving is on; a decided battle clears it.
func _autosave() -> void:
	if not autosave_enabled or battle == null:
		return
	if battle.state == Battle.State.DONE:
		SaveGame.clear(save_path)
	else:
		SaveGame.save(battle, save_path)


func _start_music() -> void:
	Sound.music("map", true)
	Sound.say("battle_open")


## Standalone default, used when the scene runs on its own (screenshots, quick checks).
## RIFTGATE_TEAM=badger,clydesdale,sparrowhawk,baboon overrides the team; RIFTGATE_FACTION picks
## the enemy; RIFTGATE_MAP_KIND=rubble picks the map's type (BattleMap.KINDS).
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
	var kind := OS.get_environment("RIFTGATE_MAP_KIND")
	if BattleMap.KINDS.has(kind):
		b.map_kind = kind
	b.setup(team, fac)
	return b


# ---------------------------------------------------------------- build

var _codex: CodexBox = null


func _build() -> void:
	for c in get_children():
		if c != _menu:   # the menu outlives a rebuild it asked for (a colour change)
			c.queue_free()
	H = Hud.screen_height(self)
	LOG_Y = 1076.0 + (H - BASE_H)   # the map takes the extra height; the strip and buttons keep to the bottom
	BOTTOM_Y = 1196.0 + (H - BASE_H)
	STRIP_Y = LOG_Y - 10.0 - INFO_H          # the strip under the map: the orders board, or a held readout
	STRIP_H = BOTTOM_Y - 16.0 - STRIP_Y      # down to the buttons' rule; the log's old space is in it
	custom_minimum_size = Vector2(W, H)
	Hud.inset_screen(self)   # clear of the phone's corners, cutout and gesture zone
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR   # text is sampled linear (Ryan, 29 September: nearest at a phone's stretch left the strokes uneven); the map and every sprite pin nearest on themselves

	var bg := HudBackdrop.new()
	bg.scan = false   # this screen's one scan bar is drawn on top of everything, below
	bg.rules = [MAP_Y - 6.0, LOG_Y - 10.0 - INFO_H, BOTTOM_Y - 16.0]
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_header = _tag("", 13, true)
	_place(_header, Vector2(12, 14), Vector2(300, 28))
	var menu_btn := HudButton.new("MENU", _open_menu)
	menu_btn.sound = ""   # the menu's own breaker is the sound
	menu_btn.hit_pad = Vector2(12.0, 10.0)   # answers over the whole bar's height and out to the edge
	_place(menu_btn, Vector2(W - 96, 10), Vector2(84, 34))
	if OS.get_environment("RIFTGATE_TUNE") == "1":
		# The map's live knobs, a development tool; the player's knobs are in the menu.
		var tune_btn := HudButton.new("TUNE", _toggle_tuner)
		_place(tune_btn, Vector2(W - 190, 10), Vector2(84, 34))
	else:
		# The music ticker fills the bar between the readout and MENU (Ryan, 25 September);
		# the tuner's button takes that space when it is on.
		_place(MusicTicker.new(), Vector2(486, 20), Vector2(W - 108 - 486, 20))
	_sub_label = Hud.label("", 12, Color(Palette.HUD, 0.7), Hud.mono())
	_place(_sub_label, Vector2(326, 20), Vector2(160, 20))

	_map = BattleMapView.new()
	_place(_map, Vector2(0, MAP_Y), Vector2(W, LOG_Y - 10.0 - INFO_H - MAP_Y))
	_map.set_field(battle.field)
	_map.hex_tapped.connect(_on_hex_tapped)
	_map.hex_double_tapped.connect(_on_hex_double_tapped)
	_map.unit_held.connect(_on_unit_held)
	_map.route_drag_started.connect(_on_route_drag_started)
	_map.route_drag_to.connect(_on_route_drag_to)
	_map.route_drag_ended.connect(_on_route_drag_ended)
	_apply_display()
	_map.hold_released.connect(_on_hold_released)

	_resolve_btn = HudButton.new("END TURN", _on_main_button)
	_resolve_btn.sound = ""   # the lever is the sound
	_resolve_btn.filled = true
	_place(_resolve_btn, Vector2(16, BOTTOM_Y), BOTTOM_BTN)
	_clear_btn = HudButton.new("UNDO MOVE", _on_undo)
	_clear_btn.sound = ""   # the undo plays its own dismiss
	_clear_btn.ghost = true
	_place(_clear_btn, Vector2(W - 16 - BOTTOM_BTN.x, BOTTOM_Y), BOTTOM_BTN)

	# The strip between the map and the log carries the orders board while no readout is
	# held (Ryan, 28 September); the readout, when held, sits over it.
	_board = OrdersBoard.new()
	_board.battle = battle
	_board.walks = func() -> Dictionary: return _map.walks
	_board.playing = _map.is_playing
	_board.covered = func() -> bool: return _details != null and _details.visible
	_place(_board, Vector2(12.0, STRIP_Y + 6.0), Vector2(W - 24.0, STRIP_H - 12.0))
	# The log is off the screen (Ryan, 29 September: only for debugging; the board took its
	# strip): the LOG button at the board's corner opens every event full screen.
	var log_btn := HudButton.new("LOG", _toggle_log_full)
	log_btn.mono = true
	log_btn.font_size = 10
	log_btn.slant_px = 6.0
	log_btn.hit_pad = Vector2(8.0, 8.0)
	_place(log_btn, Vector2(W - 12.0 - 60.0, STRIP_Y + 8.0), Vector2(52.0, 18.0))

	# The readout lives in one place, docked over the bottom of the map (thumbs, not a
	# mouse: Ryan, 21 September), and a tap on it dismisses it.
	_details = HudPanel.new(14.0)
	_details.mouse_filter = Control.MOUSE_FILTER_STOP
	_details.visible = false
	_details.custom_minimum_size = Vector2(W - 24.0, STRIP_H - 12.0)   # fills its strip (Ryan, 29 September: short, it looked odd)
	_details.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			# Dismissing the readout also drops the selection (Ryan, 29 September: the tap
			# read as cancelling the unit, and the highlights staying read as a bug).
			_details.visible = false
			_select(null)
			_map.gate_selected = false
			_map.inspected = Vector2i(-9999, -9999)
			_refresh()
			_details.accept_event())
	add_child(_details)
	_details_label = Hud.label("", 16, Palette.INK)
	_details_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_details_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_details.add_child(_details_label)
	_build_log_full()
	# One scan bar over the whole screen, on the top layer: it crosses the map and the
	# controls alike, and whatever geometry lies under it lights (Ryan, 21 September).
	_codex = CodexBox.new()
	add_child(_codex)
	_scan = ScanBar.new()
	_scan.map = _map
	_scan.map_y = MAP_Y
	_place(_scan, Vector2.ZERO, Vector2(W, H))

	_build_outcome()
	if _menu != null:
		_menu.move_to_front()


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
	back.sound = "ui_back"
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
	var playing := _map.is_playing()
	# Plain words (Ryan, 22 September): the turn, and how long until the rift spawns. The
	# gate's integrity is on the map, under the gate.
	_header.text = "TURN %02d // NEXT SPAWN IN %d" % [f.phase + 1, f.rift_pressure_max - f.rift_pressure]
	_header.queue_redraw()
	match battle.state:
		Battle.State.PLAN:
			var ready := 0
			for m in battle.mechs():
				if battle.actions_left(m) > 0:
					ready += 1
			if not battle.forced.is_empty():
				_sub_label.text = "CAUGHT // FIGHT FIRST"
			elif not battle.orders.is_empty():
				_sub_label.text = "ORDERS // %d IN" % battle.orders.size()
			else:
				_sub_label.text = "READY // %d OF %d" % [ready, battle.mechs().size()]
		Battle.State.SKIRMISH:
			_sub_label.text = "BOSS // FIGHT" if battle.boss_fight else "FIGHT"
		_:
			_sub_label.text = "BATTLE OVER"
	# Every pack's walk on the enemy's turn, from where the machines stand now.
	_map.walks = f.plan_walks() if planning and not playing else {}
	_map.forced = battle.forced if planning else []
	var spent := {}
	for m in battle.mechs():
		if battle.actions_left(m) <= 0:
			spent[m.id] = true
	_map.spent = spent
	_map.orders = battle.orders if planning else {}
	_map.attack = _fight_preview() if planning and not playing else {}
	_map.route_drawing = planning and not playing
	_map.queue_redraw()
	_refresh_log()
	# The one button: ENGAGE while a fight is ready (a catch, or a machine ordered onto a pack),
	# END TURN otherwise.
	var fight := battle.next_fight() if planning else {}
	_resolve_btn.text = "ENGAGE" if not fight.is_empty() else "END TURN"
	_resolve_btn.queue_redraw()
	_resolve_btn.set_enabled(planning and not playing)
	_clear_btn.set_enabled(planning and not playing and _undo_target() != null)


func _refresh_log() -> void:
	if _log_full_text == null:
		return
	var lines: Array[String] = battle.field.log
	var out := ""
	if lines.is_empty():
		out = "[color=#%s]> turn %d // %d packs on the field // move and fight, then end the turn[/color]" % [
			Color(Palette.HUD, 0.45).to_html(true), battle.field.phase + 1, battle.field.packs().size()]
	for line in lines:
		out += "[color=#%s]> %s[/color]\n" % [Color(Palette.HUD, 1.0).to_html(true), line]
	_log_full_text.text = out


var _log_full: Control = null
var _log_full_text: RichTextLabel = null
var _log_full_scroll: ScrollContainer = null

## Every event of the battle, full screen, from the board's LOG button; a tap outside or
## CLOSE puts it away (the skirmish's log has the same shape).
func _build_log_full() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.visible = false
	shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			_toggle_log_full())
	add_child(shade)
	_log_full = shade
	var panel := HudPanel.new(18.0)
	panel.position = Vector2(16, 40)
	panel.size = Vector2(W - 32, H - 80)
	shade.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	var head := _tag("LOG // EVERY EVENT", 12, true)
	head.custom_minimum_size = Vector2(220, 26)
	head.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(head)
	_log_full_scroll = ScrollContainer.new()
	_log_full_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_log_full_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_log_full_scroll)
	_log_full_text = RichTextLabel.new()
	_log_full_text.bbcode_enabled = true
	_log_full_text.fit_content = true
	_log_full_text.scroll_active = false
	_log_full_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_log_full_text.add_theme_font_override("normal_font", Hud.mono())
	_log_full_text.add_theme_font_size_override("normal_font_size", 16)
	_log_full_text.add_theme_color_override("default_color", Palette.HUD)
	_log_full_scroll.add_child(_log_full_text)
	var close := HudButton.new("CLOSE", _toggle_log_full)
	close.sound = "ui_back"
	close.custom_minimum_size = Vector2(0, 52)
	col.add_child(close)


func _toggle_log_full() -> void:
	if _log_full == null:
		return
	_log_full.visible = not _log_full.visible
	if _log_full.visible:
		_refresh_log()
		await get_tree().process_frame
		if _log_full_scroll != null:
			_log_full_scroll.scroll_vertical = int(_log_full_scroll.get_v_scroll_bar().max_value)


func _select(u: Unit) -> void:
	_map.selected = u
	_map.destinations = battle.destinations_for(u) if u != null else {}


# ---------------------------------------------------------------- gestures

## Tap a machine to select it; tap a lit hex and it moves there, staying in hand while it can
## still act; tap it again to let it go. With a machine in hand, a tap on a pack orders it onto
## that fight, moving it into range first (and a second tap on the pack it is ordered onto
## takes the order back). With nothing in hand, a tap on a pack shows its fight.
func _on_hex_tapped(h: Vector2i) -> void:
	if battle.state != Battle.State.PLAN or _map.is_playing():
		return
	_details.visible = false
	var u := battle.field.unit_at(h)
	var sel: Unit = _map.selected
	# A second tap on what is selected unselects it (Ryan, 29 September): the gate, a hex
	# asked about, a pack looked at.
	var was_gate := _map.gate_selected and battle.field.map.gate_hexes.has(h)
	var was_inspected := _map.inspected == h
	_map.gate_selected = false
	_map.inspected = Vector2i(-9999, -9999)
	_inspect_pack = null
	if sel != null and u != null and u.is_enemy():
		_order_attack(sel, u, [])
		return
	if was_gate or was_inspected:
		_select(null)
		Sound.play("ui_back")
		_refresh()
		return
	if battle.field.map.gate_hexes.has(h) and (sel == null or not _map.destinations.has(h)):
		# The gate is selectable for its integrity (Ryan, 22 September).
		_select(null)
		_map.gate_selected = true
		_show_details(gate_text(battle.field), Vector2.ZERO)
		_refresh()
		Sound.play("map_select")
		return
	if sel != null and u == null and _map.destinations.has(h):
		var from := sel.pos
		var route := battle.move_to(sel, h)
		if not route.is_empty():
			_play_move(sel, from, route)
			return
	elif u != null and u.is_player() and not u.is_static():
		if sel == u:
			_select(null)
			Sound.play("ui_back")
		else:
			_select(u)
			_on_unit_held(u)   # its shield, hull, move and actions, in the readout
			Sound.play("map_select")
	elif u != null and u.is_enemy():
		# Nothing in hand: the pack's fight is shown, who would join and who is ordered in.
		_select(null)
		_inspect_pack = u
		_map.inspected = h
		_on_unit_held(u)
		Sound.play("map_select")
	elif sel == null and u == null and battle.field.map.has(h) and not battle.field.map.is_structure(h):
		# Nothing to move: the tap asks what the ground is (Ryan, 21 September).
		var t: int = battle.field.map.terrain[h]
		# Each way of moving's word for this ground (decided 2 October), then the horde's rule.
		var text := "%s\n%s" % [str(BattleMap.TERRAIN_NAMES.get(t, "ground")).to_upper(), BattleMap.ground_words(t)]
		_map.inspected = h   # the hex lit, so what was tapped is plain (Ryan, 29 September)
		_show_details(text, _map.position + _map.to_screen(_map.center(h)))
		Sound.play("map_select")
	else:
		_select(null)
	_refresh()


var _draft_unit: Unit = null   # the machine whose route is being drawn by hand
var _drag_target: Unit = null  # the pack under the finger as the route is drawn: an attack on release


## A route drawn by hand (Ryan, 25 September): drag from a machine through the hexes it
## should walk. The tap takes the cheapest route; the drag says which way round. Each hex
## the finger reaches extends the draft along the cheapest continuation that fits the move
## left, a hex already on it cuts back to there, and letting go walks it. Letting go over a
## pack orders the machine onto it from the draft's end (bible section 5; Abalon's drag onto
## an enemy), or from the farthest hex in range when nothing was drawn.
func _on_route_drag_started(u: Unit) -> void:
	if battle.state != Battle.State.PLAN or _map.is_playing() or battle.actions_left(u) <= 0:
		return
	_details.visible = false
	_map.gate_selected = false
	_select(u)   # its destinations light while the finger draws
	_draft_unit = u
	_drag_target = null
	_map.draft = []
	_map.draft_move = battle.moves_left(u)
	_map.draft_spend = Vector2i(0, 0)
	Sound.play("map_select")


func _on_route_drag_to(h: Vector2i) -> void:
	if _draft_unit == null:
		return
	var over := battle.field.unit_at(h)
	var target: Unit = over if over != null and over.is_enemy() else null
	if target != _drag_target:
		_drag_target = target
		if target != null:
			Sound.play("ui_tap", -6.0)
		_refresh()
	if target != null:
		return   # the finger is on a pack: the draft stands, the fight it would join shows
	if not battle.can_move(_draft_unit):
		return
	var before := _map.draft.size()
	_map.draft = battle.draft_step(_draft_unit, _map.draft, h)
	_map.draft_spend = battle.draft_spend(_draft_unit, _map.draft)
	_map.queue_redraw()   # silent while it grows (the console's rule: no clicky ticks with no story)


func _on_route_drag_ended(commit: bool) -> void:
	var u := _draft_unit
	var draft: Array = _map.draft
	var target := _drag_target
	_draft_unit = null
	_drag_target = null
	_map.draft = []
	_map.draft_spend = Vector2i(-1, 0)
	if u != null and commit and target != null:
		_order_attack(u, target, draft)
		return
	if u != null and commit and not draft.is_empty():
		var from := u.pos
		if battle.move_along(u, draft):
			_play_move(u, from, draft)
			return
		_refuse()
	_select(null)
	_refresh()


## A move refused: the refusal, and Jenny now and then.
func _refuse() -> void:
	Sound.play("refuse")
	Sound.say("refuse")


func _on_unit_held(u: Unit) -> void:
	var text := ""
	if u.is_player():
		text = "%s\nshield %d/%d · hull %d/%d · move %d · %d of %d action%s left" % [u.display_name, u.shield, u.shield_max, u.hull, u.hull_max, u.movespeed,
			battle.actions_left(u), Battlefield.actions_for(u), "" if Battlefield.actions_for(u) == 1 else "s"]
		if u.damaged_component_count() > 0:
			text += "\n%d damaged component%s" % [u.damaged_component_count(), "" if u.damaged_component_count() == 1 else "s"]
	else:
		var db := ContentDB.load_default()
		var foe_name := str(db.foes.get(u.foe_id, {}).get("name", u.foe_id))
		if u.is_boss:
			# The boss's size is its own (content), apart from its being the boss (15 October); a
			# final's hero brings its wildlife, and the finale's line is the party.
			var boss_id := BattleMapView.foe_sprite_id(u)
			var massive := int(db.foes.get(boss_id, {}).get("size", 1)) >= 2
			var brings := ""
			if u.lineup.size() > 1:
				brings = " · %d of the party" % u.lineup.size()
			if u.strength > 0:
				brings += " · with %s ×%d" % [str(db.foes.get(u.foe_id, {}).get("name", u.foe_id)), u.strength]
			text = "%s\nboss%s%s · ring %d · %s" % [u.display_name, " · massive" if massive else "", brings, u.zone, _behaviour_text(u)]
		else:
			text = "%s\n%s ×%d · move %d · ring %d\n%s" % [u.display_name, foe_name, u.strength, u.movespeed, u.zone, _behaviour_text(u)]
	_show_details(text, _map.position + _map.to_screen(_map.center(u.pos)))


## What a pack is doing, in the hold's words: the two behaviours (bible section 5).
func _behaviour_text(u: Unit) -> String:
	if u.is_boss:
		return "holds the rift"
	match u.behaviour:
		"hunt":
			var prey := battle.field.unit_by_id(u.prey)
			return "hunts the %s: %s" % [u.hunts, prey.display_name if prey != null else "nobody yet"]
		_:
			return "marching on the gate"


func _on_hold_released() -> void:
	_details.visible = false


# ---------------------------------------------------------------- the menu

var _menu: PauseMenu = null
var _built_hud := ""   # the HUD colour this screen was built with; a change rebuilds it

func _open_menu() -> void:
	if _menu == null:
		_menu = PauseMenu.new()
		_menu.display_changed.connect(func(key: String, _value: Variant) -> void:
			if key == "fine_map":
				_map.set_field(battle.field)   # the scene and the compositor rebuilt at the new density
				_refresh()
			_apply_display())
		_menu.hud_changed.connect(_rebuild)
		_menu.quit_requested.connect(func() -> void: quit_requested.emit())
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
## as much as in the fight). A machine's entry is its own; a pack's is its foe type's,
## headed by the pack.
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
	return "THE GATE\nintegrity %d/%d\nfield projector · a pack on the apron strikes it" % [f.gate_hp, f.gate_hp_max]


static func gate_codex_entry(f: Battlefield) -> Dictionary:
	return {
		"title": "The Gate",
		"designation": "CARE FIELD PROJECTOR",
		"subtitle": "THE CITY'S ENCLOSURE // THE LINE THE MACHINES HOLD",
		"stat_items": [["integrity", "%d/%d" % [f.gate_hp, f.gate_hp_max]], ["rows", str(BattleMap.GATE_ROWS)]],
		"body": "The projector that holds the field over the city. A pack that reaches the apron strikes it for a third of its strength each phase, at least ten; when its integrity is gone the field is down and the battle is lost. Machines may stand on it; nothing else may.",
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
	entry["subtitle"] = "%s // %s" % [entry["subtitle"], ("BOSS" if u.is_boss else "×%d // MOVE %d" % [u.strength, u.movespeed])]
	return entry


## Readout beside a point on the screen, kept inside the frame.
func _show_details(text: String, _near: Vector2) -> void:
	_details_label.text = text
	_details.visible = true
	_details.size = Vector2(W - 24.0, STRIP_H - 12.0)
	_details.position = Vector2(12.0, STRIP_Y + 6.0)


# ---------------------------------------------------------------- the turn

var _last_moved: Unit = null   # the machine moved last, for UNDO MOVE when none is selected


## The machine UNDO MOVE puts back: the selected one, else the one moved last.
func _undo_target() -> Unit:
	if _map.selected != null and battle.can_undo(_map.selected):
		return _map.selected
	if _last_moved != null and battle.field.units.has(_last_moved) and battle.can_undo(_last_moved):
		return _last_moved
	return null


func _on_undo() -> void:
	var u := _undo_target()
	if u == null or _map.is_playing():
		return
	battle.undo_move(u)
	if u == _last_moved:
		_last_moved = null
	Sound.play("ui_back")
	_select(null)
	_refresh()
	_autosave()


## A machine has moved (the battle already has it there): play its walk. It stays in hand
## while it can still act, so a tap on a pack next is its attack from where it now stands
## (Abalon's move, then pick a target).
func _play_move(u: Unit, from: Vector2i, route: Array, keep: bool = true) -> void:
	_last_moved = u
	Sound.play("plot")
	_select(u if keep and battle.actions_left(u) > 0 else null)
	_details.visible = false
	if DisplayServer.get_name() == "headless" or route.is_empty():
		_refresh()
		_autosave()
		return
	_map.play_moves([[u.id, [from] + route]], [], func() -> void:
		_refresh()
		_autosave())
	_refresh()


## End the turn: the enemy's turn plays (bible section 4), the packs walking where the map
## showed, then the next turn opens, with any fight a hunter forced.
func _on_end_turn() -> void:
	if battle.state != Battle.State.PLAN or _map.is_playing() or not battle.forced.is_empty():
		return   # a second press while the walk plays would end the next turn over it
	_select(null)
	_details.visible = false
	var starts: Dictionary = {}
	for sq in battle.field.packs():
		starts[sq.id] = sq.pos
	Sound.play("resolve")
	# Jenny on the turn's orders: every machine committed (moved or fought), or some.
	var committed := 0
	var free := 0
	for m in battle.mechs():
		if m.is_static() or not m.alive():
			continue
		free += 1
		if battle.action_from.has(m.id) or int(battle.spent.get(m.id, 0)) > 0:
			committed += 1
	if committed > 0:
		Sound.say("resolve_all" if committed == free else "resolve_move")
	var gate_before := battle.field.gate_hp
	var walks := battle.end_turn()
	_gate_struck = battle.field.gate_hp < gate_before
	_spawned = battle.last_spawned
	_last_moved = null
	var pack_moves: Array = []
	for sid in walks.keys():
		var w: Battlefield.Walk = walks[sid]
		if starts.has(sid) and not w.path.is_empty():
			pack_moves.append([sid, [starts[sid]] + Array(w.path)])
	if DisplayServer.get_name() == "headless":
		_after_step()
	else:
		_map.play_moves([], pack_moves, _after_step)
		_refresh()   # the buttons grey until the walk has played


var _gate_struck := false   # the enemy's turn just played hit the gate: heard when the walk has played
var _spawned := false       # and the rift spawned

func _after_step() -> void:
	if _gate_struck:
		Sound.play("gate_hit")
		Sound.say("gate")
	if _spawned:
		Sound.play_after(0.35 if _gate_struck else 0.0, Sound.family("spawn", battle.faction))
	_gate_struck = false
	_spawned = false
	match battle.state:
		Battle.State.DONE:
			_refresh()
			_show_outcome()
		_:
			_refresh()
			if battle.state == Battle.State.PLAN and not battle.forced.is_empty():
				_show_caught()
	_autosave()


## A hunter has caught a machine (bible section 5): the warning, big and red over the map;
## the catch stays lit and the button reads ENGAGE until it is fought. On a black band with red rules across
## the map, and the map dimmed under it: red on the terrain alone never reads (Ryan, 22
## September).
func _show_caught() -> void:
	_refresh()
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
	var text := Hud.label("CAUGHT", 84, Palette.ENEMY, Hud.display_bold())
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.position = band.position
	text.size = band.size
	warn.add_child(text)
	var n := battle.forced.size()
	var sub := Hud.label("%d MACHINE%s HUNTED DOWN // FIGHT FIRST" % [n, "" if n == 1 else "S"], 16, Palette.INK, Hud.mono())
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, band.position.y + band.size.y - 34.0)
	sub.size = Vector2(W, 20)
	warn.add_child(sub)
	warn.modulate = Color(1, 1, 1, 0)
	add_child(warn)
	Sound.play("contact")
	Sound.play_after(1.02, "contact", -2.0)   # the second beat, with the blink
	Sound.say("contact")
	var tw := create_tween()
	# Two beats, drawn out (Ryan, 22 September: one flash looked accidental).
	tw.tween_property(warn, "modulate", Color(1, 1, 1, 1), 0.3)
	tw.tween_interval(0.6)
	tw.tween_property(warn, "modulate", Color(1, 1, 1, 0.1), 0.15)
	tw.tween_interval(0.12)
	tw.tween_property(warn, "modulate", Color(1, 1, 1, 1), 0.15)
	tw.tween_interval(0.55)
	tw.tween_property(warn, "modulate", Color(1, 1, 1, 0), 0.4)
	tw.tween_callback(warn.queue_free)
	if DisplayServer.get_name() == "headless":
		tw.kill()
		warn.queue_free()


# ---------------------------------------------------------------- orders and the fight

## A pack looked at with nothing in hand: its fight is shown on the map.
var _inspect_pack: Unit = null


## Order a machine onto a pack (bible section 5): along a drawn route first, if one was drawn,
## then the fight from the route's end if the pack is in range there; with no route, from the
## farthest hex in range its move left reaches, or where it stands. A second tap on the pack it
## is already ordered onto takes the order back.
func _order_attack(m: Unit, target: Unit, draft: Array) -> void:
	if draft.is_empty() and battle.order_of(m) == target:
		battle.cancel_order(m)
		Sound.play("ui_back")
		_select(null)
		_refresh()
		_autosave()
		return
	if not battle.can_target(target) or battle.actions_left(m) <= 0:
		Sound.play("ui_back")
		if not battle.forced.is_empty():
			_show_details("A HUNTER'S CATCH COMES FIRST\norder machines onto the hunter, then ENGAGE", Vector2.ZERO)
		_refresh()
		return
	var from := m.pos
	var route: Array = []
	if not draft.is_empty():
		if not battle.move_along(m, draft):
			Sound.play("ui_back")
			_select(null)
			_refresh()
			return
		route = draft
	else:
		var h := battle.attack_hex(m, target)
		if h == Battle.NO_HEX:
			Sound.play("ui_back")
			_show_details("OUT OF REACH\n%s cannot get within %d of it this turn" % [m.display_name, m.attack_range], Vector2.ZERO)
			_refresh()
			return
		if h != m.pos:
			route = battle.move_to(m, h)
	var ordered := battle.order(m, target)
	if not ordered:
		Sound.play("ui_back")   # the drawn route ended out of range: it moved, and no order
	if route.is_empty():
		if ordered:
			Sound.play("plot")
		_select(null)
		_refresh()
		_autosave()
		return
	_play_move(m, from, route, false)


## The fight the map shows: the pack the finger is on while a route is drawn, with the machine
## drawing it; else the next fight ENGAGE opens; else a pack looked at. The roster (Battle.roster)
## and "committed", the machines in it.
func _fight_preview() -> Dictionary:
	if _draft_unit != null and _drag_target != null and battle.can_target(_drag_target):
		var r := battle.roster(_drag_target)
		if not r.is_empty():
			var team: Array = _ordered_onto(r["targets"])
			if not team.has(_draft_unit):
				team.append(_draft_unit)
			r["committed"] = team
			return r
	var f := battle.next_fight()
	if not f.is_empty():
		var r := battle.roster(f["target"])
		if not r.is_empty():
			var team: Array = f["machines"].duplicate()
			if r["pinned"] != null and not team.has(r["pinned"]):
				team.push_front(r["pinned"])
			r["committed"] = team
			return r
	if _inspect_pack != null and battle.field.units.has(_inspect_pack):
		var r := battle.roster(_inspect_pack)
		if not r.is_empty():
			r["committed"] = _ordered_onto(r["targets"])
			return r
	return {}


func _ordered_onto(targets: Array) -> Array:
	var out: Array = []
	for uid in battle.orders.keys():
		if targets.has(battle.orders[uid]):
			out.append(battle.field.unit_by_id(int(uid)))
	return out


## The one button: ENGAGE while a fight is ready, END TURN otherwise.
func _on_main_button() -> void:
	if battle.state != Battle.State.PLAN or _map.is_playing():
		return
	if battle.next_fight().is_empty():
		_on_end_turn()
	else:
		_engage()


## ENGAGE: the next fight opens with the machines ordered onto it; the boss's fight plays its
## reveal.
func _engage() -> void:
	var f := battle.next_fight()
	if f.is_empty():
		return
	var r := battle.roster(f["target"])
	if r.is_empty():
		return
	var group: Array = []
	group.append_array(r["targets"])
	group.append_array(r["joins"])
	if r["pinned"] != null:
		group.append(r["pinned"])
	for m in f["machines"]:
		if not group.has(m):
			group.append(m)
	_select(null)
	_details.visible = false
	_inspect_pack = null
	var sk := battle.engage()
	if sk == null:
		Sound.play("ui_back")
		_refresh()
		return
	_map.attack = {}
	if battle.boss_fight:
		_play_boss_reveal(sk, group)
	else:
		_enter_skirmish(sk, group, true)


## The boss's fight (Ryan, 25 September): the family's theme starts from its top, the map
## looks at the boss, the reveal plays over it (BossReveal), and the handover runs on its own
## into the fight. Headless, the fight opens at once.
var _reveal: BossReveal = null

func _play_boss_reveal(sk: Skirmish, group: Array) -> void:
	_refresh()
	var bs := Sound.boss_set(battle.faction)
	if not bs.is_empty():
		Sound.music(bs, true)
	if DisplayServer.get_name() == "headless":
		_enter_skirmish(sk, group, true)
		return
	var boss := battle.boss
	_map.set_highlight([boss.pos])
	_map.focus_on(_map.center(boss.pos) + Vector2(0, 60.0), 1.6)
	var reveal := BossReveal.new()
	reveal.position = Vector2(0, MAP_Y)
	reveal.size = Vector2(W, LOG_Y - 10.0 - INFO_H - MAP_Y)
	reveal.boss_name = str(boss.display_name)
	reveal.family = str(battle.db.factions.get(battle.faction, {}).get("name", battle.faction))
	var fid := BattleMapView.foe_sprite_id(boss)
	reveal.tex = Sprites.combat_foe(fid)
	if reveal.tex == null:
		reveal.tex = Sprites.map_foe(fid)
	var map_tex := Sprites.map_foe(fid)
	reveal.from = _map.position + _map.to_screen(_map.center(boss.pos)) - reveal.position
	reveal.from_size = (map_tex.get_size() * BattleMapView.SPRITE_SCALE if map_tex != null else Vector2(40, 40)) * _map.zoom
	reveal.finished.connect(func() -> void:
		if _reveal != null:
			_reveal.queue_free()
			_reveal = null
		_enter_skirmish(sk, group, true))
	_reveal = reveal
	add_child(reveal)
	Sound.play("reveal")
	Sound.say("boss")


## Open the skirmish screen on a fight: with the handover for a contact just made, or
## straight in for a fight resumed from a save.
func _enter_skirmish(sk: Skirmish, group: Array, handover: bool) -> void:
	var screen: SkirmishScreen = SKIRMISH_SCENE.instantiate()
	screen.sk = sk
	screen.back_label = "BACK TO THE FIELD"
	if battle.boss_fight and not Sound.boss_set(battle.faction).is_empty():
		screen.music_set = Sound.boss_set(battle.faction)   # the theme already playing since contact carries on
	screen.setup(sk)
	screen.back_requested.connect(_on_skirmish_back)
	screen.quit_requested.connect(func() -> void: quit_requested.emit())   # QUIT in the fight leaves the battle too, straight out to the harness
	screen.autosave = _autosave
	_skirmish = screen
	_autosave()
	if not handover or DisplayServer.get_name() == "headless":
		_map.set_highlight([])
		add_child(screen)
		_refresh()
		return
	_play_handover(group, screen)


## The handover into the skirmish (decided 22 September): the reconstruction dives onto
## the contact, the other world's bleed grows out of the pack until the ground there has
## gone flat and bright, the display cuts to black, and the skirmish's feed fades up.
const HANDOVER_DIVE := 1.0
const HANDOVER_FLAT := 1.6      # the spread runs on past the dive before the cut (Ryan, 22 September)
const HANDOVER_FLAT_HEX := 7.5

func _play_handover(group: Array, screen: SkirmishScreen) -> void:
	var hexes: Array = []
	var mid := Vector2.ZERO
	if battle.boss_fight and battle.boss != null:
		# The boss's fight holds every machine, so the group's centroid is the middle of the
		# field: the dive aims at the boss's hex alone (Ryan, 29 September: the spread came
		# out of the centre of the map, not the boss's tile).
		hexes.append(battle.boss.pos)
		mid = _map.center(battle.boss.pos)
	else:
		for u in group:
			hexes.append(u.pos)
			mid += _map.center(u.pos)
		mid /= maxf(1.0, float(group.size()))
	_map.set_highlight(hexes)
	_map.fight_group = group      # the map stays frozen on this fight until the cut
	# The spread grows out of the ground the fight is on, the same hex the skirmish
	# takes its terrain from (Ryan, 22 September: it came out of the wrong tile).
	_map.flatten_at = _map._origin + Hex.to_pixel(Battle.ground_hex(group), BattleMapView.HEX_SIZE)
	_map.flatten_r = 0.0
	var z0 := _map.zoom
	var scroll0 := Vector2(_map.scroll_x, _map.scroll_y)
	var scrim := ColorRect.new()
	scrim.color = Color.BLACK
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.modulate = Color(1, 1, 1, 0)
	add_child(scrim)
	Sound.play("engage")
	if not battle.boss_fight:   # the boss has its reveal and its own line
		Sound.say("engage")
	var tw := create_tween().set_parallel(true)
	tw.tween_method(func(t: float) -> void:
		_map.focus_on(mid, lerpf(z0, BattleMapView.ZOOM_MAX, t)), 0.0, 1.0, HANDOVER_DIVE).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_map, "flatten_r", HANDOVER_FLAT_HEX, HANDOVER_FLAT).set_delay(0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_property(scrim, "modulate", Color(1, 1, 1, 1), 0.3)
	tw.chain().tween_callback(func() -> void:
		Sound.play("cut")
		add_child(screen)
		scrim.move_to_front()
		_map.flatten_r = 0.0
		_map.fight_group = []
		_map.set_highlight([])
		_map.zoom = z0
		_map.scroll_x = scroll0.x
		_map.scroll_y = scroll0.y
		_map._clamp_scroll()
		_refresh())
	tw.chain().tween_property(scrim, "modulate", Color(1, 1, 1, 0), 0.4)
	tw.chain().tween_callback(scrim.queue_free)


## Freed mid-handover (the screenshot tool's engage pose quits then), the skirmish screen
## is still waiting in `_skirmish` for the tween to add it to the tree: an orphan with
## three 3D worlds in it, which the renderer reported leaked at exit. Free it with us.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _skirmish != null and is_instance_valid(_skirmish) and _skirmish.get_parent() == null:
		_skirmish.free()
		_skirmish = null


## The skirmish's Back button: apply the result, then back to the turn (or the next fight a
## hunter forced, straight to its panel).
func _on_skirmish_back() -> void:
	if _skirmish != null:
		_skirmish.queue_free()
		_skirmish = null
	battle.finish_skirmish()
	Sound.music("map")
	if _built_hud != Settings.hud:
		_build()   # the colour changed in the skirmish's menu: this screen catches up
	_refresh()
	if battle.state == Battle.State.DONE:
		_show_outcome()
	_autosave()


func _show_outcome() -> void:
	var f := battle.field
	Sound.play("victory" if battle.outcome == Battle.Outcome.VICTORY else "defeat")
	if battle.outcome == Battle.Outcome.VICTORY:
		Sound.say("victory")
	elif battle.outcome == Battle.Outcome.GATE_FALLEN:
		Sound.say("loss_gate")
	match battle.outcome:
		Battle.Outcome.VICTORY:
			_overlay_title.text = "RIFT SEALED"
			_overlay_text.text = "The %s is down. The gate holds at %d after %d turns and %d skirmishes." % [
				battle.boss.display_name if battle.boss != null else "boss", f.gate_hp, f.phase, battle.skirmishes_fought]
		Battle.Outcome.GATE_FALLEN:
			_overlay_title.text = "GATE FALLEN"
			_overlay_text.text = "The horde is in the city. Turn %d." % (f.phase + 1)
		_:
			_overlay_title.text = "ALL WRECKED"
			_overlay_text.text = "Every machine is scrap. The gate stands at %d, undefended." % f.gate_hp
	_overlay.visible = true

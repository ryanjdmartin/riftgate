class_name BattleScreen
extends Control

## The battle: the battlefield map with the turn around it, in the overlay style (bible
## section 4, the round row). Portrait, 720x1280 logical, absolute layout.
##
##   header   the three gauges always on screen (TopBar: the gate, the rift's spawn, the
##            Fractures), MENU at the right
##   map      drag to scroll; tap a machine to select it and light where it can move and bracket
##            the packs it could be ordered onto; tap a lit hex (or draw a route from it)
##            and the move is planned, its route drawn from where the machine stands; with a
##            machine in hand, tap a pack (or drag the machine onto one) and it is planned into
##            range and ordered onto that fight; hold a unit for its numbers. Every pack's walk
##            on the enemy's turn, a hunter's lock on its prey and its ring round where its walk
##            ends, and the next fight: its target and the machines ordered onto it
##   bottom   ENGAGE (while a fight is ready), EXECUTE (while planned moves wait to play) or END
##            TURN bottom-left, pulsing when nothing is left to do; UNDO bottom-right, the last
##            move or order, in the order they were made, a move that has played included; what
##            is playing between them
##
## The planned moves play on EXECUTE and the turn goes on (Ryan, 2 November: "Movement should be
## able to be executed in sequence if the player wants, and undone"); ENGAGE and END TURN play
## them first too (Ryan, 25 October), then the fight opens or the enemy walks. END TURN asks first
## while a machine can still move or fight. A fight opens the skirmish screen over the map. Its
## Back button applies the result, and the turn goes on; End turn plays the enemy's turn.

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
const DETAILS_PAD := 14.0   # the readout panel's margin, round its lines

var battle: Battle
## Save the battle after every change (user://battle.json, `SaveGame`), so it resumes where
## it stood. On for a battle the harness starts or resumes; off for standalone runs and
## tests, which must never overwrite a real one.
var autosave_enabled := false
var save_path: String = SaveGame.PATH   # where the autosave goes; the tests point it elsewhere

var _top: TopBar
var _map: BattleMapView
var _resolve_btn: HudButton
var _clear_btn: HudButton
var _details: HudPanel
var _details_entry: EntryReadout   # the held thing's lines, as the fight's holds read
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


## RIFTGATE_CACHE_DEBUG=1: a new battle lies one cache of every kind beside the team, on solid
## ground, and one of every kind by the rift, under the painting, in place of the caches its seed
## dealt, so each kind's model and its flat token are judged side by side in one look (Ryan, 9
## November: "models (and art, when flattened), for loot caches on map"). A battle read back
## from a save keeps its own.
static var CACHE_DEBUG := OS.get_environment("RIFTGATE_CACHE_DEBUG") == "1"


func setup(b: Battle) -> void:
	battle = b
	if CACHE_DEBUG and b.field.phase == 0:
		_debug_caches(b)
	_build()
	_refresh()


func _debug_caches(b: Battle) -> void:
	var f := b.field
	var kinds := b.db.loot_kinds()
	if kinds.is_empty() or b.mechs().is_empty():
		return
	f.caches = []
	for from in [b.mechs()[0].pos, f.map.rift]:
		var open: Array = f.map.all_hexes().filter(func(h: Vector2i) -> bool: return Hex.distance(h, from) >= 2)
		open.sort_custom(func(x: Vector2i, y: Vector2i) -> bool: return Hex.distance(x, from) < Hex.distance(y, from))
		var k := 0
		for h in open:
			if k >= kinds.size():
				break
			if f._cache_fits(h):
				f.caches.append({"id": f.caches.size() + 1, "tier": int(b.db.loot[kinds[k]].get("tier", 1)), "pos": h})
				k += 1


func _ready() -> void:
	Settings.apply()
	Hud.oversample(get_window())   # standalone runs too: text at the glass's density
	if battle == null:
		setup(_default_battle())
	elif _top == null or H != Hud.screen_height(self):
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
## RIFTGATE_TEAM=badger,clydesdale,kite,baboon overrides the team; RIFTGATE_FACTION picks
## the enemy; RIFTGATE_MAP_KIND=gorge picks the map's shape (BattleMap.KINDS; none draws one by
## the seed) and RIFTGATE_SEED=<n> the battle's seed (7).
static func _default_battle() -> Battle:
	Settings.field_trial()   # RIFTGATE_FIELD_DEPTH and RIFTGATE_OPENING, for a shot or a scene run alone
	var db := ContentDB.load_default()
	var seed_env := OS.get_environment("RIFTGATE_SEED")
	var b := Battle.new(int(seed_env) if seed_env.is_valid_int() else 7)
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

	# The top bar: the three gauges always on screen (Ryan, 9 November: "the three important pieces
	# of information that always needs to be visible is the gate/wall integrity, the rift spawn bar
	# and the fracture bar. We don't need the turn number up there, nor the ready/orders display,
	# since that shows up in the lower panel now. The music display could be moved too").
	_top = TopBar.new()
	_top.battle = battle
	_place(_top, Vector2(12, 6), Vector2(W - 12.0 - 106.0, MAP_Y - 12.0))
	var menu_btn := HudButton.new("MENU", _open_menu)
	menu_btn.sound = ""   # the menu's own breaker is the sound
	menu_btn.hit_pad = Vector2(12.0, 10.0)   # answers over the whole bar's height and out to the edge
	_place(menu_btn, Vector2(W - 96, 11), Vector2(84, 34))

	_map = BattleMapView.new()
	_place(_map, Vector2(0, MAP_Y), Vector2(W, LOG_Y - 10.0 - INFO_H - MAP_Y))
	MapOrient.apply_setting()   # the wall at the left or the bottom, before anything is laid out
	_map.set_field(battle.field)
	_map.hex_tapped.connect(_on_hex_tapped)
	_map.hex_double_tapped.connect(_on_hex_double_tapped)
	_map.unit_held.connect(_on_unit_held)
	_map.route_drag_started.connect(_on_route_drag_started)
	_map.route_drag_to.connect(_on_route_drag_to)
	_map.route_drag_ended.connect(_on_route_drag_ended)
	_map.peak_beat.connect(_on_peak_beat)
	_map.cutscene_changed.connect(_on_cutscene)
	_apply_display()
	_map.hold_released.connect(_on_hold_released)

	_resolve_btn = HudButton.new("END TURN", _on_main_button)
	_resolve_btn.sound = ""   # the lever is the sound
	_resolve_btn.filled = true
	_place(_resolve_btn, Vector2(16, BOTTOM_Y), BOTTOM_BTN)
	_clear_btn = HudButton.new("UNDO", _on_undo)
	_clear_btn.sound = ""   # the undo plays its own dismiss
	_clear_btn.state_marked = true   # on and off by structure (Ryan, 9 November: "map undo needs to be more obvious when it's active versus disabled")
	_clear_btn.badge_size = 16
	_place(_clear_btn, Vector2(W - 16 - BOTTOM_BTN.x, BOTTOM_Y), BOTTOM_BTN)
	# What is playing, between the two buttons (moved off the top bar, which holds the gauges);
	# the map's tuner takes its place there when it is on.
	var mid := Rect2(16.0 + BOTTOM_BTN.x + 12.0, BOTTOM_Y, W - 2.0 * (16.0 + BOTTOM_BTN.x + 12.0), BOTTOM_BTN.y)
	if OS.get_environment("RIFTGATE_TUNE") == "1":
		# The map's live knobs, a development tool; the player's knobs are in the menu.
		var tune_btn := HudButton.new("TUNE", _toggle_tuner)
		_place(tune_btn, Vector2(mid.get_center().x - 42.0, mid.position.y + 13.0), Vector2(84, 34))
	else:
		var ticker := MusicTicker.new()
		ticker.centred = true
		_place(ticker, Vector2(mid.position.x, mid.get_center().y - 10.0), Vector2(mid.size.x, 20))

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
	_details = HudPanel.new(DETAILS_PAD)
	_details.mouse_filter = Control.MOUSE_FILTER_STOP
	_details.visible = false
	_details.custom_minimum_size = Vector2(W - 24.0, STRIP_H - 12.0)   # fills its strip (Ryan, 29 September: short, it looked odd)
	_details.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			# Dismissing the readout also drops the selection (Ryan, 29 September: the tap
			# read as cancelling the unit, and the highlights staying read as a bug).
			_details.visible = false
			_select(null)
			_map.inspected = Vector2i(-9999, -9999)
			_refresh()
			_details.accept_event())
	add_child(_details)
	_details_entry = EntryReadout.new()
	_details_entry.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_details.add_child(_details_entry)
	_build_log_full()
	# One scan bar over the whole screen, on the top layer: it crosses the map and the
	# controls alike, and whatever geometry lies under it lights (Ryan, 21 September).
	_codex = CodexBox.new()
	add_child(_codex)
	_scan = ScanBar.new()
	_scan.map = _map
	_scan.map_y = MAP_Y
	_place(_scan, Vector2.ZERO, Vector2(W, H))

	_build_confirm()
	_build_outcome()
	if _menu != null:
		_menu.move_to_front()


var _confirm_shade: Control
var _confirm: HudPanel
var _confirm_text: Label
var _confirm_action := Callable()


## The question END TURN asks while a machine can still act: the fight's confirm (the skirmish
## screen's, over unspent dice), a panel over a shade, NO and YES; a tap on the shade is NO.
func _build_confirm() -> void:
	_confirm_action = Callable()   # a rebuild (a colour change) drops a question left open
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.6)
	_confirm_shade = shade
	_confirm_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirm_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_confirm_shade.visible = false
	_confirm_shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			_hide_confirm())
	add_child(_confirm_shade)
	_confirm = HudPanel.new(22.0)
	_confirm.custom_minimum_size = Vector2(520, 0)
	_confirm.visible = false
	_place(_confirm, Vector2(100, H * 0.5 - 90.0), Vector2(520, 0))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	_confirm.add_child(v)
	_confirm_text = Hud.label("", 20, Palette.INK)
	_confirm_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	_confirm_text.custom_minimum_size = Vector2(470, 0)
	v.add_child(_confirm_text)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	v.add_child(row)
	var no := HudButton.new("NO", _hide_confirm)
	no.sound = "ui_back"
	no.custom_minimum_size = Vector2(0, 54)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(no)
	var yes := HudButton.new("YES", _confirm_yes)
	yes.sound = "confirm"
	yes.filled = true
	yes.custom_minimum_size = Vector2(0, 54)
	yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(yes)


func _ask(text: String, on_yes: Callable) -> void:
	_confirm_text.text = text
	_confirm_action = on_yes
	_confirm_shade.visible = true
	_confirm.visible = true
	_confirm.reset_size()


func _hide_confirm() -> void:
	_confirm.visible = false
	_confirm_shade.visible = false
	_confirm_action = Callable()


func _confirm_yes() -> void:
	var action := _confirm_action
	_hide_confirm()
	if action.is_valid():
		action.call()


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

## RIFTGATE_PEAK_DEBUG=1: Rift Pressure peaks every enemy turn, so the tears, the seam's creep
## and the mouths' sends can be judged running within a few turns (the pacing session, 30
## October; placeholders all).
static var PEAK_DEBUG := OS.get_environment("RIFTGATE_PEAK_DEBUG") == "1"


func _refresh() -> void:
	var f := battle.field
	if PEAK_DEBUG:
		f.rift_pressure_max = 1
	var planning := battle.state == Battle.State.PLAN
	var playing := _map.is_playing()
	_top.queue_redraw()   # the gate, the rift's spawn and the Fractures, read off the battle
	# Every pack's walk on the enemy's turn, from where the machines stand now.
	_map.walks = f.plan_walks() if planning and not playing else {}
	_map.forced = battle.forced if planning else []
	_map.orders = battle.orders if planning else {}
	# The plan as it stands; while it plays the map keeps where it has each machine.
	if not playing:
		_map.plans = battle.plan_pieces() if planning else []
		_map.shown = battle.shown_positions() if planning else {}
	_map.attack = _fight_preview() if planning and not playing else {}
	_map.route_drawing = planning and not playing
	_map.queue_redraw()
	_refresh_log()
	# The one button: ENGAGE while a fight is ready (a catch, or a machine ordered onto a pack),
	# EXECUTE while planned moves wait to play (Ryan, 2 November: "It should show "execute" when
	# a move command is entered, and only end turn if no order is entered"), and while the moves
	# it took play; END TURN otherwise.
	var fight := battle.next_fight() if planning else {}
	var waiting: Array = battle.fights_waiting() if planning else []
	_map.queue = waiting
	if not fight.is_empty():
		# One button for the queue (the long wall brief 7.4): it says how many fights wait, the
		# next first; no dialog on a split, nothing about staying grouped.
		_resolve_btn.text = "ENGAGE" if waiting.size() <= 1 else "ENGAGE 1 OF %d" % waiting.size()
	elif _executing or (planning and not battle.planned.is_empty()):
		_resolve_btn.text = "EXECUTE"
	else:
		_resolve_btn.text = "END TURN"
	_resolve_btn.queue_redraw()
	_resolve_btn.set_enabled(planning and not playing)
	if waiting.is_empty() or not planning:
		_queue_pulse = false
	_resolve_btn.set_pulse(planning and not playing and (battle.nothing_left() or _queue_pulse))   # every machine done, or back from a fight with more waiting: the button is next
	_clear_btn.set_enabled(planning and not playing and battle.can_undo())
	_clear_btn.badge = "×%d" % battle.history.size() if planning and battle.can_undo() else ""   # how far it reaches, as the fight's says


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
	_queue_pulse = false   # the player is doing something else: the queue waits quietly
	_map.selected = u
	# A machine with a move planned or an order given shows what it could do instead (Ryan, 10
	# November: "I should be able to re-order them by tapping on them again"): its reach from
	# where it started, as if its plan were taken back; a move or an order given there replaces it.
	var reach: Array = battle.reach_if_retaken(u) if u != null else [{}, {}]
	_map.destinations = reach[0]
	_map.threat = reach[1]


# ---------------------------------------------------------------- gestures

## A select's and a deselect's sounds on the map, turned down (Ryan, 10 November: "Select and
## deselect on the map need to be quieter"): taps that only look, never the sounds of a thing
## done (a move planned, an order given, a refusal).
const MAP_TAP_DB := -10.0

## Tap a machine to select it; tap a lit hex and it moves there, staying in hand while it can
## still act; tap it again to take its order back (a planned move, an order onto a pack) and
## let it go; a machine with an order shows its reach from where it started, and a new move or
## order there replaces the old one. With a machine in hand, a tap on a pack orders it onto
## that fight, moving it into range first (and a second tap on the pack it is ordered onto
## takes the order back). With nothing in hand, a tap on a pack shows its fight.
func _on_hex_tapped(h: Vector2i) -> void:
	if battle.state != Battle.State.PLAN or _map.is_playing():
		return
	_details.visible = false
	var u := _map.unit_at_shown(h)
	var sel: Unit = _map.selected
	# A second tap on what is selected unselects it (Ryan, 29 September): a hex asked about, a
	# pack looked at. The gate and the rift are no selection (Ryan, 9 November: "The rift and wall
	# no longer need to show their bars, nor be selectable"): a tap there lets go of what was held,
	# as any structure's does, and their numbers are the top bar's.
	var was_inspected := _map.inspected == h
	_map.inspected = Vector2i(-9999, -9999)
	_inspect_pack = null
	if sel != null and u != null and u.is_enemy():
		_order_attack(sel, u, [])
		return
	if was_inspected:
		_select(null)
		Sound.play("ui_back", MAP_TAP_DB)
		_refresh()
		return
	if sel != null and u == null and _map.destinations.has(h):
		if not battle.move_again(sel, h).is_empty():   # a machine with a plan gives it up for this one
			_planned(sel)
			return
	elif u != null and u.is_player() and not u.is_static():
		if sel == u and battle.retake(u):
			# A tap on the machine in hand takes its order back and lets it go (Ryan, 10 November:
			# "Tapping on them when they are selected should cancel the order"; "When I tap a unit
			# to cancel its order, it should deselect"). The order's own undo: the UNDO count drops.
			_select(null)
			Sound.play("ui_back", MAP_TAP_DB)
			_refresh()
			_autosave()
			return
		if sel == u:
			_select(null)
			Sound.play("ui_back", MAP_TAP_DB)
		else:
			_select(u)
			_on_unit_held(u)   # its shield, hull, move and actions, in the readout
			Sound.play("map_select", MAP_TAP_DB)
	elif u != null and u.is_enemy():
		# Nothing in hand: the pack's fight is shown, who would join and who is ordered in.
		_select(null)
		_inspect_pack = u
		_map.inspected = h
		_on_unit_held(u)
		Sound.play("map_select", MAP_TAP_DB)
	elif sel == null and u == null and battle.field.map.has(h) and not battle.field.map.is_structure(h):
		# Nothing to move: the tap asks what the ground is (Ryan, 21 September), and what lies on
		# it (a cache: its kind and its likely contents, never the contents; the bible's loot row).
		_map.inspected = h   # the hex lit, so what was tapped is plain (Ryan, 29 September)
		var cache := battle.field.cache_at(h)
		var lines: Array = cache_lines(battle.field, cache) if not cache.is_empty() else []
		lines.append_array(ground_lines(battle.field.map.terrain[h], battle.field.map.ground_id(h)))
		_show_details(lines)
		Sound.play("map_select", MAP_TAP_DB)
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
	_select(u)   # its destinations light while the finger draws
	_draft_unit = u
	_drag_target = null
	_map.draft = []
	Sound.play("map_select", MAP_TAP_DB)


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
	_map.draft_land = battle.draft_landing(_draft_unit, _map.draft)   # a carrier's block at the end, marked where it does not fit
	_map.queue_redraw()   # silent while it grows (the console's rule: no clicky ticks with no story)


func _on_route_drag_ended(commit: bool) -> void:
	var u := _draft_unit
	var draft: Array = _map.draft
	var target := _drag_target
	_draft_unit = null
	_drag_target = null
	_map.draft = []
	_map.draft_land = {}
	if u != null and commit and target != null:
		_order_attack(u, target, draft)
		return
	if u != null and commit and not draft.is_empty():
		if battle.move_along(u, draft):
			_planned(u)
			return
		_refuse()
	_select(null)
	_refresh()


## A move refused: the refusal, and Jenny now and then.
func _refuse() -> void:
	Sound.play("refuse")
	Sound.say("refuse")


func _on_unit_held(u: Unit) -> void:
	_show_details(mech_lines(u) if u.is_player() else pack_lines(u))


## A machine's readout on the map (Ryan, 26 October: the map's readouts looked like blocks of
## text; they read as the fight's holds do): its name, its hull as a gauge with its numbers (no
## shield: the shield is the fight's, full as every fight opens, the long wall brief 7.5), a
## maximum anything moved coloured with its arrow, its move as the codex has it (the base, the
## change beside it), its actions left, and a chip for its destroyed components.
func mech_lines(u: Unit) -> Array:
	var out: Array = [_title(u.display_name)]
	out.append(EntryReadout.bar_line("Hull", u.hull, u.hull_max, int(u.base["hull"]), Palette.HULL))
	var n := Battlefield.actions_for(u)
	out.append(EntryReadout.parts_line("effect", [EntryReadout.word("Move")] + ContentDB.stat_parts(int(u.base["move"]), u.movespeed)
		+ [EntryReadout.word("·"), EntryReadout.word("%d of %d action%s left" % [battle.actions_left(u), n, "" if n == 1 else "s"])]))
	var damaged := u.damaged_component_count()
	if damaged > 0:
		out.append(EntryReadout.chip_line("crack", Palette.HUD, "%d destroyed component%s: blank for the battle" % [damaged, "" if damaged == 1 else "s"]))
	return out


## A pack's readout the same way: its name, its foe and strength and its move, then
## what it is doing. The boss's: its name as the boss, its size (its own in content, apart from
## its being the boss, 15 October) and ring, what it brings (a final's hero its wildlife, the
## finale's line the party), and its holding the rift.
func pack_lines(u: Unit) -> Array:
	var db := ContentDB.load_default()
	var foe_name := str(db.foes.get(u.foe_id, {}).get("name", u.foe_id))
	if not u.is_boss:
		# A composition's members in order, the lead first (30 October); a one-type pack is one.
		var parts: Array = []
		for m in u.member_list():
			if not parts.is_empty():
				parts.append("·")
			parts.append_array([str(db.foes.get(str(m[0]), {}).get("name", str(m[0]))), "×%d" % int(m[1])])
		parts.append_array(["·", "Move", str(u.movespeed)])
		if u.traits.has("winged"):
			parts.append_array(["·", "Winged"])   # it crosses water and crags as a flyer does
		var lines: Array = [_title(u.display_name), _squad_line(u), _words(parts), _behaviour_line(u)]
		var w: Battlefield.Walk = _map.walks.get(u.id, null) if _map != null else null
		var when := _way_line(u, w)
		if not when.is_empty():
			lines.append(when)
		return lines
	var out: Array = [_title(u.display_name, "Boss"), _squad_line(u)]
	var stats: Array[String] = []
	if int(db.foes.get(BattleMapView.foe_sprite_id(u), {}).get("size", 1)) >= 2:
		stats.append("Massive")
	if not stats.is_empty():
		out.append(_words(stats))
	var brings: Array[String] = []
	if u.lineup.size() > 1:
		brings.append("%d of the party" % u.lineup.size())
	if not u.members.is_empty():
		for m in u.members:   # a hand-tailored escort, by member
			brings.append("%s ×%d" % [str(db.foes.get(str(m[0]), {}).get("name", str(m[0]))), int(m[1])])
	elif u.strength > 0:
		brings.append("%s ×%d" % [foe_name, u.strength])
	if not brings.is_empty():
		out.append(_said("With", ", ".join(brings)))
	out.append(_behaviour_line(u))
	return out


## A pack's threat rating in words, the first line after its name (the long wall brief 3.7):
## the machines it is intended for.
static func _squad_line(u: Unit) -> Dictionary:
	var words := ["one", "two", "three", "four"]
	return _words(["A fight for %s" % words[clampi(u.squad, 1, 4) - 1]])


## What a pack is doing (the two behaviours, bible section 5), its verb in bold as a chip's
## name is.
func _behaviour_line(u: Unit) -> Dictionary:
	if u.is_boss:
		if u.sealed:
			return _said("Sealed", "holds the rift; its seal breaks at the Rupture")
		return _said("Holds", "the rift")
	match u.behaviour:
		"hunt":
			var prey := battle.field.unit_by_id(u.prey)
			return _said("Hunts", "the %s: %s" % [u.hunts, prey.display_name if prey != null else "nobody yet"])
		_:
			# What leaving it alone costs: its strike at the wall, by its threat rating and what a
			# fight has left of it (Battlefield.strike_of; Ryan, 10 November).
			return _said("Marches", "on the gate, striking it for %d" % Battlefield.strike_of(u))


## When a pack gets where its whole way goes, as the field stands (the map draws the way, its
## turns numbered, while it is tapped): a pusher at the wall, a hunter catching what it comes for;
## {} for a pack going nowhere, or already there.
func _way_line(u: Unit, w: Battlefield.Walk) -> Dictionary:
	if w == null or w.route.is_empty():
		return {}
	var turns := 1 if w.path.size() >= w.route.size() else battle.field.turn_ends(u, w).size() + 1
	var when := "this turn" if turns == 1 else "in %d turns" % turns
	if w.prey != 0:
		var prey := battle.field.unit_by_id(w.prey)
		if not battle.field.catches_at(u, w.route[w.route.size() - 1], prey):
			return _said("Closes", "on it, as near as it gets %s" % when)   # past any walk: as near as it gets
		return _said("Catches", "it %s, as the field stands" % when)
	return _said("At the wall", "%s, as the field stands" % when)


## A readout's first line: the name, and beside it what kind of thing it is where that says
## something (the boss, the gate, the ground).
static func _title(name: String, kind: String = "") -> Dictionary:
	return {"style": "title", "text": name.to_upper(), "type": kind, "parts": [], "place": ""}


## A line of plain words.
static func _words(list: Array) -> Dictionary:
	var parts: Array = []
	for t in list:
		parts.append(EntryReadout.word(str(t)))
	return EntryReadout.parts_line("effect", parts)


## A line whose first words are bold, as a chip's name is: what it is, then what it says.
static func _said(head: String, rest: String) -> Dictionary:
	return EntryReadout.parts_line("effect", [{"text": head, "trend": 0, "gain": false, "bold": true}, EntryReadout.word(rest)])


## The ground's readout (Ryan, 21 September: a tap asks what the ground is): its name (a wall
## by what it is, Ryan, 29 October: crags, mesas, towers or cliffs; `word`, the map's ground_id),
## then a line for each word the crossing table gives it, read from the table so it never
## disagrees with the rule (Ryan, 28 October: a step a hex, water waded at two, walls the
## flyer's), the ways under each by their shown names; then the packs' rule.
static func ground_lines(t: int, word: String = "") -> Array:
	var db := ContentDB.load_default()
	var id := word
	if id.is_empty():
		id = str(BattleMap.WALL_LOOKS[0]) if t == BattleMap.Terrain.MOUNTAIN else str(BattleMap.TERRAIN_NAMES.get(t, "plain"))
	var out: Array = [_title(db.term_name(id), "Ground")]
	for pair in BattleMap.ground_ways(t):
		var ways: Array[String] = []
		for way in pair[1]:
			ways.append(str(db.vocabulary.get(way, {}).get("name", EntryReadout.capital(way))))
		var said := ", ".join(ways)
		match str(pair[0]):
			"wade":
				out.append(_said("Wade:", said + " (two move a hex)"))
			"wall":
				out.append(_said("Wall:", said))
			_:
				out.append(_said("Cross:", "every machine" if (pair[1] as Array).size() == BattleMap.WAYS.size() else said))
	var packs := "Packs cross it"
	if BattleMap.step_cost(t, []) == BattleMap.WADE:
		packs = "Packs wade it (two move a hex); a winged pack crosses it" if BattleMap.step_cost(t, ["winged"]) == BattleMap.STEP else "Packs wade it (two move a hex)"
	elif not BattleMap.passable(t, []):
		packs = "Packs never enter it; a winged pack crosses it" if BattleMap.passable(t, ["winged"]) else "Packs never enter it"
	out.append(EntryReadout.text_line("effect", packs))
	return out


## A cache's readout (the bible's loot row: "A tap shows its kind and likely contents, never the
## contents"): its kind, what such a kind holds by its numbers, and how it is claimed.
static func cache_lines(_f: Battlefield, c: Dictionary) -> Array:
	var db := ContentDB.load_default()
	var t := int(c.get("tier", 1))
	var kind := db.loot_kind_of_tier(t)
	var e: Dictionary = db.loot.get(kind, {})
	var out: Array = [_title(str(e.get("name", kind)), "Cache")]
	var sv: Array = e.get("salvage", [0, 0])
	out.append(_said("Salvage:", "%d to %d" % [int(sv[0]), int(sv[1])]))
	var n := int(e.get("components", 0))
	if n > 0:
		out.append(_said("Components:", "%d of the battle's tier" % n))
	var bp := float(e.get("blueprint", 0.0))
	if bp > 0.0:
		out.append(_said("Blueprint:", "a %d%% chance at one the run lacks" % roundi(bp * 100.0)))
	if not str(e.get("codex", "")).is_empty():
		out.append(EntryReadout.text_line("effect", str(e["codex"])))
	out.append(EntryReadout.text_line("effect", "A machine standing on it as the turn ends claims it"))
	return out


## A refused order's readout: what stopped it, then what to do.
static func notice_lines(title: String, text: String) -> Array:
	return [_title(title), EntryReadout.text_line("effect", text)]


func _on_hold_released() -> void:
	_details.visible = false


# ---------------------------------------------------------------- the menu

var _menu: PauseMenu = null
var _built_hud := ""   # the HUD colour this screen was built with; a change rebuilds it
var _built_map := ""   # the switches the map was built with (_map_switches); a change in the skirmish's menu remakes it on the way back

func _open_menu() -> void:
	if _menu == null:
		_menu = PauseMenu.new()
		_menu.display_changed.connect(func(key: String, _value: Variant) -> void:
			if key == "weld" or key == "aa_mode" or key == "map_view":
				MapOrient.apply_setting()
				_map.set_field(battle.field)   # the machines with the weld on or off, the anti-aliasing, or the map turned
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
	_built_map = _map_switches()


## What the map is built with that a settings switch changes: the AA mode, the map's view, and a
## debug build's weld.
func _map_switches() -> String:
	return str([MechWeld.enabled(), Hud.aa_mode(), Settings.display.get("map_view", "wall_left")])


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
	var u := _map.unit_at_shown(h)
	if u == null:
		return   # the gate and the rift carry no entry on the map (Ryan, 9 November: not selectable)
	_details.visible = false
	_codex.move_to_front()
	_codex.open(codex_entry_for(u))


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
	entry["subtitle"] = "%s // %s" % [entry["subtitle"], (("BOSS // SEALED" if u.sealed else "BOSS") if u.is_boss else "×%d // MOVE %d" % [u.strength, u.movespeed])]
	if u.traits.has("winged"):
		entry["subtitle"] += " // WINGED"   # it crosses water and crags as a flyer does
	return entry


## The readout, docked over the strip under the map (thumbs, not a mouse): the held thing's
## lines at the panel's width. Lines taller than the strip grow it up over the map.
func _show_details(lines: Array) -> void:
	_details_entry.set_lines(lines, W - 24.0 - 2.0 * DETAILS_PAD)
	_details.visible = true
	var h := maxf(STRIP_H - 12.0, _details_entry.custom_minimum_size.y + 2.0 * DETAILS_PAD)
	_details.size = Vector2(W - 24.0, h)
	_details.position = Vector2(12.0, STRIP_Y + 6.0 + (STRIP_H - 12.0) - h)


# ---------------------------------------------------------------- the turn

## UNDO: the last move or order, whoever made it (Ryan, 25 October: "the undo stack is stored
## in order, and undos in order, always"), its machine back in hand while it can still move.
func _on_undo() -> void:
	if _map.is_playing() or not battle.can_undo():
		return
	var u := battle.undo()
	Sound.play("ui_back")
	_details.visible = false
	_select(u if u != null and battle.can_move(u) else null)
	_refresh()
	_autosave()


## A move planned (the battle already has the machine at its route's end): the route shows from
## where it stands, and it plays on EXECUTE, ENGAGE or END TURN (Ryan, 25 October: no waiting on
## a walk to do the next thing). It stays in hand while it can still act, so a tap on a pack next
## is its attack from the route's end (Abalon's move, then pick a target).
func _planned(u: Unit, keep: bool = true) -> void:
	Sound.play("plot")
	_select(u if keep and battle.actions_left(u) > 0 else null)
	_details.visible = false
	_refresh()
	_autosave()


## The plan played on the map, then `then`: the pieces in their phases, and after them the
## packs' walks when there are any. Headless, nothing plays and `then` runs at once.
func _play_plan(plan: Array, pack_moves: Array, then: Callable) -> void:
	var phases := BattleMapView.plan_phases(plan)
	if not pack_moves.is_empty():
		phases.append(pack_moves)
	if DisplayServer.get_name() == "headless" or phases.is_empty():
		_map.shown = {}
		then.call()
		return
	if not plan.is_empty():
		Sound.play("plot")
	_map.plans = []
	_map.play_phases(phases, then)
	_refresh()   # the buttons grey until the plan has played


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
		if battle.moved.has(m.id) or int(battle.spent.get(m.id, 0)) > 0 or battle.orders.has(m.id):
			committed += 1
	if committed > 0:
		Sound.say("resolve_all" if committed == free else "resolve_move")
	var gate_before := battle.field.gate_hp
	var plan := battle.take_plan()   # the machines' planned moves play first, then the packs walk
	_map.hold_peak()   # a peak this turn is shown after the walks (_after_step): the seam and the tears stand as they were until then
	var walks := battle.end_turn()
	_gate_struck = battle.field.gate_hp < gate_before
	_spawned = battle.last_spawned
	var pack_moves: Array = []
	for sid in walks.keys():
		var w: Battlefield.Walk = walks[sid]
		if starts.has(sid) and not w.path.is_empty():
			pack_moves.append([sid, [starts[sid]] + Array(w.path)])
	_play_plan(plan, pack_moves, _after_step)


var _gate_struck := false   # the enemy's turn just played hit the gate: heard when the walk has played
var _spawned := false       # and the rift spawned

func _after_step() -> void:
	if _gate_struck:
		Sound.play("gate_hit")
		Sound.say("gate")
		_top.flash("gate")   # the gauge that moved says so, wherever the map is scrolled
	if _spawned:
		Sound.play_after(0.35 if _gate_struck else 0.0, Sound.family("spawn", battle.faction))
		_top.flash("rift")
	_gate_struck = false
	_spawned = false
	if battle.state == Battle.State.DONE:
		_map.play_peak(Callable())   # nothing to show over the outcome: the hold is let go
		_refresh()
		_show_outcome()
		_autosave()
		return
	# A peak's cutscene first (the seam's creep, a tear opening: BattleMapView.play_peak), then
	# what the turn opens with; at once when the turn held no peak.
	_refresh()
	_map.play_peak(_after_peak)
	if _map.cutscene_playing():
		_refresh()   # the buttons grey while it plays


## While the map plays a cutscene nothing on the screen takes a touch (Ryan, 10 November: "I feel
## like I glitched one out by tapping, we should remove interactions while they run"): a clear
## sheet over everything swallows them, the menu too, for the few seconds it runs.
var _cut_block: Control = null

func _on_cutscene(playing: bool) -> void:
	if _cut_block == null:
		_cut_block = Control.new()
		_cut_block.mouse_filter = Control.MOUSE_FILTER_STOP
		_cut_block.position = Vector2.ZERO
		_cut_block.size = Vector2(W, H)
		add_child(_cut_block)
	_cut_block.visible = playing
	if playing:
		_cut_block.move_to_front()


## A beat of the peak's cutscene, heard: the seam's creep starting, a tear opening. Borrowed
## sounds until each has its own (the audio to-do).
func _on_peak_beat(what: String) -> void:
	if what == "tear":
		Sound.play("reveal")
	else:
		Sound.play("contact", -4.0)
	_top.flash("rift")


## The peak shown (or none to show): every hunter that turned on a machine this turn is declared,
## the map gliding in on each in turn (BattleMapView.play_locks), then the turn opens.
func _after_peak() -> void:
	if battle.state == Battle.State.DONE:
		_refresh()
		_show_outcome()
		_autosave()
		return
	_refresh()
	# The hunter stands clear under the band, whatever the glass's height.
	_map.play_locks(battle.take_locks(), _show_lock, _after_locks, maxf(_map.size.y * 0.5, WARN_BAND_Y + WARN_BAND_H + 130.0))
	if _map.cutscene_playing():
		_refresh()   # the buttons grey while it plays


## The locks declared (or none): the next turn opens, with any catch.
func _after_locks() -> void:
	_refresh()
	if battle.state == Battle.State.PLAN and not battle.forced.is_empty():
		_show_caught()
	_autosave()


## A hunter turns on a machine (Ryan, 8 November: "Declare when a hunter selects a target. Maybe
## zoom on it and declare the target on screen"; 10 November: "We should pan and zoom to hunters
## when they acquire as well"): the map has glided in on the hunter (play_locks) and the band
## says who turns on whom, the catch's band in its shape; every lock of the turn in its turn,
## each in the log too. A roar from the enemy belongs here (noted, not made: the audio to-do).
func _show_lock(hunter: Unit, prey: Unit) -> void:
	_warn_band("HUNTED", "%s TURNS ON %s" % [hunter.display_name.to_upper(), prey.display_name.to_upper()], false)


## A hunter has caught a machine (bible section 5): the warning, big and in the enemy's violet over
## the map; the catch stays lit and the button reads ENGAGE until it is fought. On a black band with
## violet rules across the map, and the map dimmed under it: a colour on the terrain alone never
## reads (Ryan, 22 September, of the red then).
func _show_caught() -> void:
	_refresh()
	var caught := {}
	for f in battle.forced:
		caught[(f["prey"] as Unit).id] = true   # a fight a hunter, a machine caught twice counted once
	var n := caught.size()
	var fights := battle.forced.size()
	_warn_band("CAUGHT", "%d MACHINE%s HUNTED DOWN // %d FIGHT%s FIRST" % [n, "" if n == 1 else "S", fights, "" if fights == 1 else "S"], true)


## The warning band over the map: a black band with violet rules across it, the map dimmed under
## it, the title big in the enemy's violet and a line under it; two beats, drawn out (Ryan, 22
## September: one flash looked accidental), the catch's second contact beat and its line with it.
const WARN_BAND_Y := 260.0   # the band's top in the map's rect
const WARN_BAND_H := 150.0

func _warn_band(title: String, sub_text: String, catch: bool, sound: String = "contact") -> void:
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
	band.position = Vector2(0, WARN_BAND_Y)
	band.size = Vector2(W, WARN_BAND_H)
	warn.add_child(band)
	for y in [band.position.y, band.position.y + band.size.y - 4.0]:
		var rule := ColorRect.new()
		rule.color = Palette.ENEMY
		rule.position = Vector2(0, y)
		rule.size = Vector2(W, 4.0)
		warn.add_child(rule)
	var text := Hud.label(title, 84, Palette.ENEMY, Hud.display_bold())
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.position = band.position
	text.size = band.size
	warn.add_child(text)
	var sub := Hud.label(sub_text, 16, Palette.INK, Hud.mono())
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, band.position.y + band.size.y - 34.0)
	sub.size = Vector2(W, 20)
	warn.add_child(sub)
	warn.modulate = Color(1, 1, 1, 0)
	add_child(warn)
	Sound.play(sound)
	if catch:
		Sound.play_after(1.02, "contact", -2.0)   # the second beat, with the blink
		Sound.say("contact")
	var tw := create_tween()
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


## Order a machine onto a pack (bible section 5; Battle.order_onto): along a drawn route first,
## if one was drawn, then the fight from the route's end if the pack is in range there; with no
## route, from the farthest hex in range its move left reaches, or where it stands. A second tap
## on the pack it is already ordered onto takes the order back. The move into range is planned
## and one UNDO takes back the move and the order together.
func _order_attack(m: Unit, target: Unit, draft: Array) -> void:
	match battle.order_onto(m, target, draft):
		"ordered":
			Sound.play("plot")
			_select(null)
		"moved":
			Sound.play("ui_back")   # the drawn route ended out of range: it moved, and no order
			_select(null)
		"cancelled":
			Sound.play("ui_back")
			_select(null)
		"refused":
			Sound.play("ui_back")
			if not battle.forced.is_empty():
				_show_details(notice_lines("A hunter's catch comes first", "Order machines onto the hunter, then ENGAGE"))
			_refresh()
			return
		"out_of_reach":
			Sound.play("ui_back")
			_show_details(notice_lines("Out of reach", "%s cannot get within %d of it this turn" % [m.display_name, m.attack_range]))
			_refresh()
			return
		"no_room":
			_refuse()
			_select(null)
		_:
			Sound.play("ui_back")
			_select(null)
	_refresh()
	_autosave()


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
			r["committed"] = (r["eligible"] as Array).duplicate() if bool(r.get("all_in", false)) else team   # the boss's fight takes every machine
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
			r["committed"] = (r["eligible"] as Array).duplicate() if bool(r.get("all_in", false)) else _ordered_onto(r["targets"])
			r["inspect"] = true   # its own ring shows, lit, in place of where a machine must stand
			return r
	return {}


func _ordered_onto(targets: Array) -> Array:
	var out: Array = []
	for uid in battle.orders.keys():
		if targets.has(battle.orders[uid]):
			out.append(battle.field.unit_by_id(int(uid)))
	return out


## The one button: ENGAGE while a fight is ready, EXECUTE while planned moves wait to play, END
## TURN otherwise.
func _on_main_button() -> void:
	if battle.state != Battle.State.PLAN or _map.is_playing():
		return
	if not battle.next_fight().is_empty():
		_engage()
	elif not battle.planned.is_empty():
		_execute()
	else:
		_ask_end_turn()


var _executing := false   # the moves EXECUTE took are playing: the button keeps its word until they have
var _queue_pulse := false  # back from a fight with orders still waiting: the button pulses until the player does something else (the long wall brief 7.4)


## EXECUTE: the planned moves play on the map and the turn goes on, with no enemy turn (Ryan, 2
## November: "Movement should be able to be executed in sequence if the player wants, and
## undone"). UNDO still takes them back, in order, each machine set back where it stood
## (Battle.take_plan). Its reach goes dark as it plays (Ryan, 16 November: "When Execute is
## clicked, the movement range overlay should turn off if visible"): it was drawn from where the
## machine stood before. A machine's move is spent then but not its action (one move, then a
## fight), so the machine in hand stays in hand once its move has played only while a pack is in
## reach of where it stopped, that pack bracketed; with none it is let go.
func _execute() -> void:
	var plan := battle.take_plan()
	if plan.is_empty():
		return
	_details.visible = false
	_map.destinations = {}
	_map.threat = {}
	_map.queue_redraw()
	Sound.say("resolve_move")   # "in transit", "moving to intercept"
	_autosave()   # the battle has every machine where its plan ends already
	_executing = true
	_play_plan(plan, [], func() -> void:
		_executing = false
		var held: Unit = _map.selected
		if held != null:
			_select(held if _can_still_fight(held) else null)
		_refresh())


## Whether a machine may still be ordered onto a pack this turn: its action left and a pack in
## reach of where it stands or of where its move could still take it (Battle.threat_for, as the
## map brackets them).
func _can_still_fight(u: Unit) -> bool:
	var reach := battle.threat_for(u)
	if reach.is_empty():
		return false
	for sq in battle.field.packs():
		for x in sq.hexes():
			if reach.has(x) or Hex.distance(x, u.pos) <= u.attack_range:
				return true
	return false


## END TURN: at once with nothing left to do; while a machine can still move or fight it asks
## first, as the fight's END TURN does over unspent dice (Ryan, 2 November: "If end turn is hit
## and there are movements/actions remaining, it should alert the player").
func _ask_end_turn() -> void:
	var n := battle.still_to_act().size()
	if n == 0:
		_on_end_turn()
		return
	Sound.play("ui_tap")
	_ask("%d %s still move or fight. End the turn anyway?" % [n, "machine can" if n == 1 else "machines can"], _on_end_turn)


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
	# The planned moves play first, and the fight opens once they have (Ryan, 25 October); the
	# boss's fight takes every machine wherever it stands and ends the battle, so nothing moves
	# first and the reveal plays at once ("just go right into the boss animation").
	var plan := battle.take_plan()
	if battle.next_fight_is_boss():
		plan = []
		_map.shown = {}
	_play_plan(plan, [], func() -> void:
		var sk := battle.engage()
		if sk == null:
			Sound.play("ui_back")
			_refresh()
			return
		_map.attack = {}
		if battle.boss_fight:
			_play_boss_reveal(sk, group)
		else:
			_enter_skirmish(sk, group, true))


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
	# The order says who is in: the machines ordered onto the boss, every one when all are.
	var committed := 0
	for u in group:
		if (u as Unit).is_player():
			committed += 1
	var free := 0
	for m in battle.mechs():
		if not m.is_static():
			free += 1
	reveal.order_text = ("ALL UNITS" if committed >= free else "%d UNIT%s" % [committed, "" if committed == 1 else "S"]) + " COMMITTED // ENGAGING"
	reveal.family = str(battle.db.factions.get(battle.faction, {}).get("name", battle.faction))
	var fid := BattleMapView.foe_sprite_id(boss)
	reveal.tex = Sprites.combat_foe(fid)
	var map_tex := BattleMapView.foe_picture(boss)
	if reveal.tex == null:
		reveal.tex = map_tex
	reveal.from = _map.position + _map.to_screen(_map.center(boss.pos)) - reveal.position
	reveal.from_size = BattleMapView.sprite_size(boss, map_tex) * _map.zoom
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
		# The dive aims at the boss's hex alone, wherever the machines on it stand (Ryan, 29
		# September: the spread came out of the centre of the map, not the boss's tile).
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
	_map.flatten_at = _map._origin + MapOrient.to_pixel(Battle.ground_hex(group), BattleMapView.HEX_SIZE)
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
	Sound.music(screen.music_set)   # the pair flips to the fight's half from ENGAGE, in place (a boss theme already playing carries on)
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
	var fractures_before := battle.fractures
	var sealed_before := battle.is_sealed()
	var elites_before := battle.elites_spawned.size()
	battle.finish_skirmish()
	Sound.music("map")
	_queue_pulse = not battle.fights_waiting().is_empty()   # the remaining orders stand, and the button says the next is waiting
	if _built_hud != Settings.hud:
		_build()   # the colour changed in the skirmish's menu: this screen catches up
	elif _built_map != _map_switches():
		MapOrient.apply_setting()
		_map.set_field(battle.field)   # a switch changed in the skirmish's menu (the AA mode, the weld, the traces, the map's view): the map remade
		_apply_display()
	_refresh()
	if battle.state == Battle.State.DONE:
		_show_outcome()
	elif battle.fractures > fractures_before or (sealed_before and not battle.is_sealed()):
		_show_fracture(battle.elites_spawned.size() > elites_before)
	_autosave()


## A Fracture earned, announced (Ryan, 9 November: "Fractures need to be announced"): the warning
## band over the map, FRACTURE with its count and what it brings, an elite out of the rift (the
## map glides in on it as it arrives and the band names it) or nothing more; the last, THE RUPTURE, the seal broken and the boss open to
## a fight; and the top bar's gauge flashes. Several earned by one fight are one band, its count the
## last.
func _show_fracture(elite: bool) -> void:
	_top.flash("fractures")
	var n := battle.thresholds.size()
	if not battle.is_sealed():
		if battle.boss != null:
			_map.scroll_to_unit(battle.boss)
		_warn_band("RUPTURE", "THE SEAL BREAKS // THE BOSS CAN BE FOUGHT", false, "reveal")
		return
	var said := "FRACTURE %d OF %d" % [battle.fractures, n]
	if elite:
		# The elite is introduced as it arrives (Ryan, 10 November: "After fracture, we should zoom
		# and introduce the elite as it spawns"): unseen until the map has glided in on its hex,
		# zoomed, then it bursts out of the ground under the band, which names it.
		var sq := _newest_elite()
		var named := (" // " + sq.display_name.to_upper()) if sq != null else ""
		_map.hold_spawn(sq)
		_map.play_spawn(sq, func() -> void:
			_warn_band("FRACTURE", said + " // AN ELITE EMERGES" + named, false)
			Sound.play_after(0.35, Sound.family("spawn", battle.faction)), _refresh, maxf(_map.size.y * 0.5, WARN_BAND_Y + WARN_BAND_H + 130.0))
		if _map.cutscene_playing():
			_refresh()   # the buttons grey while it plays
	else:
		_warn_band("FRACTURE", said + " // %d MORE TO THE RUPTURE" % (n - battle.fractures), false)


## The elite the last Fracture sent out of the rift: the last pack on the field of the last elite
## composition spawned, null when none stands.
func _newest_elite() -> Unit:
	if battle.elites_spawned.is_empty():
		return null
	var id := str(battle.elites_spawned[battle.elites_spawned.size() - 1])
	var found: Unit = null
	for sq in battle.field.packs():
		if sq.composition == id:
			found = sq
	return found


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

class_name PauseMenu
extends Control

## The pause menu (Ryan, 22 September): MENU on either screen opens it over a scrim that
## swallows input. Three pages. PAUSED: resume, settings, quit. SETTINGS: the display's
## colour and the knobs a player may want (brightness, the pace of moves, the pace of the
## enemy's turn, the glitch, the scan bar; Ryan, 22 September: saturation and bloom made no
## difference a player would want), saved through `Settings` and applied live by the host
## screen. QUIT asks first, then `quit_requested` (Ryan, 23 September): the host leaves for
## the harness; a battle started from the harness is saved where it stands (SaveGame).
##
## A colour change rebuilds the host screen, which is not instant: the menu stays up, a
## mask says so, and the host must keep this node through its rebuild (it is a child).
##
## Under the PAUSED page, in the scrim's empty space, a second plate is the music: what is
## playing, by title and working label, with previous and next through the screen's set
## (Ryan, 25 September: on the page itself, not a settings item).
##
## KEYWORDS (Ryan, 26 October: "We need a keywords list in the pause menu"): every term the
## dice and the chips print, by kind, each with its codex line, in a scroller. In play a term in
## shown text takes a tap for its own line (KeywordTip), so the list lives here alone (Ryan, 30
## October: "if we have contextual help that can get repurposed or removed and just live in the
## menu"; "And yes remove keywords button").
##
## COLOURS, a debug build's page under SETTINGS (Ryan, 30 October: "put in a whole colour wheel
## or hex entry"; then "simplified to only what we need"): the colours that carry a meaning and
## the HUD presets (ColourTuner), each with its swatch, which opens a picker (wheel, sliders and
## hex), its hex and RESET; PEEK hides the menu until a tap, COPY puts the changed colours on the
## clipboard as text, RESET ALL asks twice.

signal resumed
signal display_changed(key: String, value: Variant)
signal hud_changed
signal quit_requested

const WIDTH := 560.0
const MUSIC_GAP := 18.0   # between the menu's panel and the music plate
const TOP_LIST := 64.0     # the keywords page's panel top
const LIST_CHROME := 230.0 # its title, button, margins and a gap under it: the rest is the list
const TOOL_ROW := 66.0     # the colours page's row of tools above its BACK

## The keywords list's kinds, in the order the page shows them: the vocabulary's category and the
## page's heading for it.
const GLOSSARY := [["reach", "REACH"], ["keyword", "KEYWORDS"], ["component_property", "RULES ON A COMPONENT"], ["status", "STATUSES"], ["foe", "FOES' MOVES"]]

var _scrim: ColorRect
var _panel: HudPanel
var _rows: VBoxContainer
var _mask: Control
var _music: HudPanel
var _music_label: Label
var _music_title: Label
var _music_prev: HudButton
var _music_next: HudButton
var _music_loop := "?"    # the loop the plate shows; "?" so the first poll draws it
var _page := "paused"
var _busy := false
var _list: ScrollContainer = null   # the keywords, colours or trials page's scroller, sized to the glass in _fit
var _peeking := false     # the colours page's PEEK: the menu hidden until a tap
var _peek_tag: HudPanel
var _reset_armed := false # RESET ALL asks twice


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_scrim = ColorRect.new()
	_scrim.color = Color(0, 0, 0, 0.7)
	_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_scrim.gui_input.connect(func(e: InputEvent) -> void:
		if _peeking and e is InputEventMouseButton and e.pressed:
			_peek(false)
		elif e is InputEventMouseButton and e.pressed and _page == "paused" and not _busy:
			close())
	add_child(_scrim)
	_panel = HudPanel.new(24.0)
	_panel.custom_minimum_size = Vector2(WIDTH, 0)
	_panel.position = Vector2(80, 240)
	_panel.size = Vector2(WIDTH, 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 12)
	_panel.add_child(_rows)
	_music = _music_plate()
	add_child(_music)
	_peek_tag = HudPanel.new(10.0)
	_peek_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_peek_tag.add_child(Hud.label("PEEK // TAP TO RETURN", 14, Palette.HUD, Hud.mono()))
	_peek_tag.position = Vector2(220, 8)
	_peek_tag.visible = false
	add_child(_peek_tag)
	_mask = BusyMask.new()
	_mask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mask.visible = false
	add_child(_mask)


## Open on PAUSED, from MENU.
func open() -> void:
	_music_loop = "?"
	_show_page("paused")
	visible = true
	Sound.play("menu_open")
	Sound.duck(true)


func close() -> void:
	visible = false
	Sound.play("menu_close")
	Sound.duck(false)
	resumed.emit()


func is_open() -> bool:
	return visible


func _show_page(page: String) -> void:
	# A page shown again over itself (a dial pressed) keeps its scroller where the thumb left it.
	var kept := _list.scroll_vertical if page == _page and _list != null and is_instance_valid(_list) else 0
	_page = page
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	match page:
		"paused":
			_title("PAUSED")
			_button("RESUME", close, true, "")   # close() plays the menu closing
			_button("KEYWORDS", func() -> void: _show_page("keywords"))
			_button("SETTINGS", func() -> void: _show_page("settings"))
			_button("QUIT", func() -> void: _show_page("quit"))
		"settings":
			_title("SETTINGS")
			_colour_row()
			_slider("BRIGHTNESS", "brightness")
			_slider("MOVE PACE", "pace")
			_slider("ENEMY PACE", "enemy_pace")
			_toggle("GLITCH", "glitch")
			_toggle("SCAN BAR", "scan")
			_choice_row("SKIRMISH CONTROLS", "skirmish_controls", Settings.SKIRMISH_CONTROLS)
			_choice_row("AA MODE", "aa_mode", Settings.AA_MODES, Settings.AA_LABELS)   # the 3D's anti-aliasing (Hud.aa_mode)
			_choice_row("MAP VIEW", "map_view", Settings.MAP_VIEWS, Settings.MAP_VIEW_LABELS)   # the battle map's orientation (MapOrient)
			_slider("MUSIC", "music")
			_slider("EFFECTS", "effects")
			_slider("VOICE", "voice")
			_credit("Voice: Jenny (Dioco)")   # her licence asks for it (CREDITS.md is the record)
			if OS.is_debug_build():
				_toggle("EVERY LINE", "voice_test")   # Jenny on every hook, every time: to hear them all on the phone
				_choice_row("CHIPS", "chip_style", UnitView.CHIP_STYLES)   # how a status chip carries its number: over its corner, on a plate at its corner, or beside it (UnitView.chip_style)
				_toggle("WELD", "weld")   # the machines' parts welded (MechWeld); off draws them as authored, to compare the look and the heat on the phone
				_button("TRIALS", func() -> void: _show_page("trials"))   # the trial dials, each a number still to be picked by play (the page's own note lists them), a page of their own so the settings fit every glass
				_button("COLOURS", func() -> void: _show_page("colours"))   # the colours that carry a meaning and the HUD presets, by wheel or hex (ColourTuner)
			_button("BACK", func() -> void: _show_page("paused"), false, "ui_back")
		"trials":
			# A debug build's dials for the numbers still to be picked by play, the game's own
			# until one is: when Phased lands, the field's depth, the opening's distance, the
			# fodder's worth on the Rupture meter, the meter's size, the tide's density, the wall
			# strike, the packs' pace, the rift's count, the start's tears, the leaders' step, the
			# tide as fodder and the pack bonus (each read as the next battle starts), under two
			# sets that lay several at once. A dial leaves this page with
			# its question: the pick lands in content or in the engine and the what-if is cut (the
			# heat's, the top basic's, the rank and file's, the overheat's and the Barrier basic's
			# left on 23 November, each as built).
			_title("TRIALS")
			# The dials stand in a scroller, as the keywords do, so a glass of any height holds
			# them (14 November: at twelve rows the page had outgrown the 1280 glass, and the
			# basics' two came): the rows below go to its column, then the page's own take BACK.
			_list = _scroller()
			_rows.add_child(_list)
			var page_rows := _rows
			_rows = _list.get_child(0)
			_set_row("SET", [["FODDER TIDE", Settings.FODDER_SET], ["AS BUILT", _trials_as_built()]])   # his first set of 23 November in one press, and every dial back to the game's own
			_credit("Fodder tide: FORMATIONS FODDER, PACK BONUS +½, STRIKE 5, START TEARS TWO, over the rest as set.")
			_choice_row("PHASED", "phased_form", Settings.PHASED_FORMS, Settings.PHASED_FORM_LABELS)   # when a machine's Phased lands (Skirmish.phase_at_once; Ryan, 20 November: "Set the debug toggle for phased")
			_credit("A machine's Phased as the round ends, through the next; or at once, until the round ends. Next battle.")
			_choice_row("FIELD DEPTH", "field_depth", Settings.FIELD_DEPTHS)   # the field's depth in rows, twelve the game's (Ramp.depth_trial; Ryan, 10 November: "I think the map is a bit too shallow")
			_choice_row("OPENING", "field_opening", Settings.FIELD_OPENINGS, Settings.FIELD_OPENING_LABELS)   # how many moves farther from the wall the opening's packs stand (Battle.opening_trial): depth alone leaves their first walk on the wall
			_credit("Rows from rift to wall; moves farther out the first packs stand. Next battle.")
			_choice_row("FODDER", "fodder_worth", Settings.FODDER_WORTHS, Settings.FODDER_WORTH_LABELS)   # what a rank-and-file kill fills of the Rupture meter (Battle.fodder_trial; Ryan, 10 November: "If fracture rewards were a little lower for fodder")
			_credit("A pack's worth on the Rupture meter, an elite's untouched. Next battle.")
			_choice_row("RUPTURE", "rupture_beats", Settings.RUPTURE_BEATS, Settings.RUPTURE_BEATS_LABELS)   # how many peaks of the tide the Rupture's field part runs through, two the game's (Ramp.beats_trial; Ryan, 11 November: "Try your lean first")
			_credit("Waves of the tide the Rupture takes, an elite's four on top. Next battle.")
			_choice_row("TIDE", "tide_density", Settings.TIDES, Settings.TIDE_LABELS)   # how many packs the opening places and each wave sends against the game's own, the Rupture's size left (Ramp.tide_trial; Ryan, 11 November: "noticeably more spawns then the minimum number required")
			_credit("Packs at the opening and each wave; the Rupture asks no more. Next battle.")
			_choice_row("STRIKE", "wall_strike", Settings.STRIKES)   # what a pip of threat rating strikes the wall for, ten the game's (Battlefield.strike_trial; the same day: "even if it means that each needs to do less to the wall")
			_credit("What a pip of threat rating strikes the wall for. Next battle.")
			_choice_row("PACE", "pack_pace", Settings.PACES, Settings.PACE_LABELS)   # hexes added to every pack's move (Battlefield.pace_trial; Ryan, 23 November: "I'd probably give everything +1 right now and see what that does")
			_credit("Every pack's move, as built or more. The opening stands a move out, so farther. Next battle.")
			_choice_row("RIFT SENDS", "rift_sends", Settings.RIFT_SENDS, Settings.RIFT_SENDS_LABELS)   # the compositions the rift sends a peak, each to its own stretch of wall (Battlefield.rift_sends_trial; the same day: "each headed a different direction")
			_credit("Packs the rift sends a wave, each its own way; the Rupture asks no more. Next battle.")
			_choice_row("START TEARS", "flank_tears", Settings.FLANK_TEARS, Settings.FLANK_TEARS_LABELS)   # tears open across the width from the first turn (Battlefield.flank_tears_trial; the same day: "starting tears at the top and bottom"; "Tears need to spread wide")
			_credit("Tears open from turn one: two at the wall's ends, or four across it; the Rupture asks no more. Next battle.")
			_choice_row("LEADERS", "leader_step", Settings.LEADER_STEPS, Settings.LEADER_STEP_LABELS)   # an elite's and a boss's hit points more for each Convergence past its tier's first (ContentDB.leader_step_trial; Ryan, 23 November: "if they don't scale with me they'll become a joke at C4")
			_credit("An elite's and a boss's hit points more each battle into a tier: C2 one step, C4 three. Next battle.")
			_choice_row("FORMATIONS", "formation_form", Settings.FORMATION_FORMS, Settings.FORMATION_FORM_LABELS)   # the tide as fodder: every formation come apart into packs for one machine and for two, the tears sending one in turn (Battlefield.fodder_tide; the same day: "All fodder safer to fight ... choices of pack sizes and pack types")
			_credit("Fodder: a formation as two or three packs for one machine or two, from its own foes; the tears send them too. Next battle.")
			_choice_row("PACK BONUS", "pack_bonus", Settings.PACK_BONUSES, Settings.PACK_BONUS_LABELS)   # what a pack pays the Rupture meter as it falls, on top of its rating (Battle.pack_bonus_trial; the same day: "a flat fracture bonus to a pack on top of the per-foe weight")
			_credit("Pips a pack pays the Rupture as it falls, over its rating; the Rupture grows to match. Next battle.")
			_rows = page_rows
			_list.set_deferred("scroll_vertical", kept)
			_button("BACK", func() -> void: _show_page("settings"), false, "ui_back")
		"colours":
			_title("COLOURS")
			_list = _colours_list()
			_rows.add_child(_list)
			_colour_tools()
			_button("BACK", func() -> void: _show_page("settings"), false, "ui_back")
		"keywords":
			_title("KEYWORDS")
			_list = _keywords_list()
			_rows.add_child(_list)
			_button("BACK", func() -> void: _show_page("paused"), false, "ui_back")
		"quit":
			_title("QUIT?")
			var l := Hud.label("Leave for the harness. A battle is kept where it stands.", 18, Palette.MUTED)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.autowrap_mode = TextServer.AUTOWRAP_WORD
			_rows.add_child(l)
			_button("STAY", func() -> void: _show_page("paused"), true, "ui_back")
			_button("QUIT", func() -> void:
				visible = false
				Sound.duck(false)
				quit_requested.emit(), false, "confirm")
	_fit()
	_fit.call_deferred()


func _fit() -> void:
	# The keywords and colours pages stand tall from near the top, each scroller taking what the
	# glass has.
	var listed := _page == "keywords" or _page == "colours" or _page == "trials"
	_panel.position.y = TOP_LIST if listed else 240.0
	if listed and _list != null:
		var tall := size.y if size.y > 0.0 else 1280.0
		var chrome := LIST_CHROME + (TOOL_ROW if _page == "colours" else 0.0)
		_list.custom_minimum_size = Vector2(WIDTH - 48.0, maxf(320.0, tall - TOP_LIST - chrome))
	_panel.reset_size()
	_panel.size = Vector2(WIDTH, _panel.get_combined_minimum_size().y)
	_music.visible = _page == "paused"
	_music.reset_size()
	_music.size = Vector2(WIDTH, _music.get_combined_minimum_size().y)
	_music.position = Vector2(_panel.position.x, _panel.position.y + _panel.size.y + MUSIC_GAP)


## The plate follows the music while the menu is up: a skip changes the title at once, and
## a set that rolls over under the menu changes it too.
func _process(_delta: float) -> void:
	if not visible:
		return
	var loop := Sound.track()
	if loop == _music_loop:
		return
	_music_loop = loop
	if loop.is_empty():
		_music_label.text = "MUSIC"
		_music_title.text = "NOTHING PLAYING"
		_music_title.add_theme_color_override("font_color", Palette.MUTED)
	else:
		_music_label.text = "NOW PLAYING // %s" % Sound.label(loop).to_upper()
		_music_title.text = Sound.title(loop).to_upper()
		_music_title.add_theme_color_override("font_color", Palette.HUD)
	var can_skip := Sound.can_skip()
	_music_prev.set_enabled(can_skip)
	_music_next.set_enabled(can_skip)


## The music plate: previous, the readout (label over title), next.
func _music_plate() -> HudPanel:
	var plate := HudPanel.new(14.0)
	plate.custom_minimum_size = Vector2(WIDTH, 0)
	plate.mouse_filter = Control.MOUSE_FILTER_STOP
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_music_prev = HudButton.new("", func() -> void: Sound.skip(-1))
	_music_prev.glyph = "prev"
	_music_prev.custom_minimum_size = Vector2(60, 60)
	row.add_child(_music_prev)
	var mid := VBoxContainer.new()
	mid.add_theme_constant_override("separation", 2)
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.alignment = BoxContainer.ALIGNMENT_CENTER
	_music_label = Hud.label("", 12, Palette.MUTED, Hud.mono())
	_music_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mid.add_child(_music_label)
	_music_title = Hud.label("", 26, Palette.HUD, Hud.display_bold())
	_music_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_music_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	mid.add_child(_music_title)
	row.add_child(mid)
	_music_next = HudButton.new("", func() -> void: Sound.skip(1))
	_music_next.glyph = "next"
	_music_next.custom_minimum_size = Vector2(60, 60)
	row.add_child(_music_next)
	plate.add_child(row)
	return plate


func _title(text: String) -> void:
	var l := Hud.label(text, 30, Palette.HUD, Hud.display_bold())
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rows.add_child(l)


## A menu button: forward is the press (the default), back is a dismiss, and an action the
## menu commits to is a confirm (the palette: the menu's forward, back and select).
func _button(text: String, on_pressed: Callable, filled: bool = false, sound: String = "ui_tap") -> void:
	var b := HudButton.new(text, on_pressed)
	b.sound = sound
	b.filled = filled
	b.custom_minimum_size = Vector2(0, 54)
	_rows.add_child(b)


func _caption(text: String) -> Label:
	var l := Hud.label(text, 12, Palette.MUTED, Hud.mono())
	l.custom_minimum_size = Vector2(130, 0)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l


## The display's colour: one swatch per chrome, the current one filled. Changing it
## rebuilds the host screen behind the mask; the menu stays on this page.
func _colour_row() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(_caption("DISPLAY"))
	for id in Settings.HUD_OPTIONS.keys():
		var b := HudButton.new(str(id).to_upper())
		b.font_size = 14
		b.color_override = Settings.HUD_OPTIONS[id]
		b.filled = Settings.hud == id
		b.custom_minimum_size = Vector2(0, 40)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func() -> void:
			if Settings.hud != id and not _busy:
				_change_hud(str(id)))
		row.add_child(b)
	_rows.add_child(row)


## The mask gets two frames on screen before the rebuild blocks the thread, then the host
## rebuilds, then the page is drawn again in the new colour.
func _change_hud(id: String) -> void:
	_busy = true
	_mask.visible = true
	_mask.move_to_front()
	if is_inside_tree():
		await get_tree().process_frame
		await get_tree().process_frame
	Settings.set_hud(id)
	hud_changed.emit()
	if not is_instance_valid(self):
		return
	_show_page(_page)
	_mask.visible = false
	_busy = false


func _slider(caption: String, key: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(_caption(caption))
	var s := HSlider.new()
	var range_v: Vector2 = Settings.DISPLAY_RANGES[key]
	s.min_value = range_v.x
	s.max_value = range_v.y
	s.step = (range_v.y - range_v.x) / 40.0
	s.value = float(Settings.display[key])
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.custom_minimum_size = Vector2(0, 28)
	s.value_changed.connect(func(v: float) -> void:
		Settings.set_display(key, v)
		if key in ["music", "effects", "voice"]:
			Sound.apply_settings()
		display_changed.emit(key, v))
	row.add_child(s)
	_rows.add_child(row)


## A small line of credit under the knob it belongs to.
func _credit(text: String) -> void:
	var l := Hud.label(text, 11, Palette.MUTED, Hud.mono())
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_rows.add_child(l)


func _toggle(caption: String, key: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(_caption(caption))
	var c := CheckButton.new()
	c.button_pressed = bool(Settings.display[key])
	c.toggled.connect(func(on: bool) -> void:
		Settings.set_display(key, on)
		if key == "voice_test":
			Sound.apply_settings()
		display_changed.emit(key, on))
	row.add_child(c)
	_rows.add_child(row)


## A setting with a few named options (where the skirmish's controls sit, the AA mode): one
## button an option, labelled from `labels` or the option upper-cased, the current one filled,
## as the display's colours are. A screen on show rebuilds behind the menu.
func _choice_row(caption: String, key: String, options: Array, labels: Dictionary = {}) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(_caption(caption))
	for id in options:
		var b := HudButton.new(str(labels.get(id, str(id).to_upper())))
		b.font_size = 14
		b.filled = str(Settings.display.get(key, Settings.DISPLAY_DEFAULTS[key])) == id
		b.custom_minimum_size = Vector2(0, 40)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if _list != null and _list.is_ancestor_of(_rows):
			b.mouse_filter = Control.MOUSE_FILTER_PASS   # in a scroller a finger's drag that starts on a dial scrolls the page (the trials')
		b.pressed.connect(func() -> void:
			if str(Settings.display.get(key, Settings.DISPLAY_DEFAULTS[key])) == id:
				return
			Settings.set_display(key, id)
			display_changed.emit(key, id)
			_show_page(_page))
		row.add_child(b)
	_rows.add_child(row)


## A row of sets on the trials' page: each button lays several dials at once (its dictionary of
## settings) and draws the page again, filled while every dial of its set stands as it lays it.
func _set_row(caption: String, sets: Array) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(_caption(caption))
	for entry in sets:
		var values: Dictionary = entry[1]
		var b := HudButton.new(str(entry[0]))
		b.font_size = 14
		b.filled = values.keys().all(func(k) -> bool: return str(Settings.display.get(k, Settings.DISPLAY_DEFAULTS[k])) == str(values[k]))
		b.custom_minimum_size = Vector2(0, 40)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if _list != null and _list.is_ancestor_of(_rows):
			b.mouse_filter = Control.MOUSE_FILTER_PASS
		b.pressed.connect(func() -> void:
			Settings.set_displays(values)
			for k in values.keys():
				display_changed.emit(str(k), values[k])
			_show_page(_page))
		row.add_child(b)
	_rows.add_child(row)


## Every trial dial at the game's own (the trials' page's AS BUILT).
func _trials_as_built() -> Dictionary:
	var out := {}
	for key in Settings.TRIAL_KEYS:
		out[key] = Settings.DISPLAY_DEFAULTS[key]
	return out


## The mask over the menu while the host rebuilds: a dark shade, a line of mono text and a
## hex ring, in the colour being switched to. It swallows every tap.
class BusyMask extends Control:
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.75))
		var c := size * 0.5
		var hud := Palette.HUD
		draw_polyline(Hex.corners(c + Vector2(0, -30), 26.0) + PackedVector2Array([Hex.corners(c + Vector2(0, -30), 26.0)[0]]), hud, 2.0, true)
		draw_polyline(Hex.corners(c + Vector2(0, -30), 14.0) + PackedVector2Array([Hex.corners(c + Vector2(0, -30), 14.0)[0]]), Color(hud, 0.5), 1.5, true)
		draw_string(Hud.mono(), Vector2(0, c.y + 30.0), "RECONFIGURING DISPLAY", HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, hud)


## The keywords list as data: each kind's heading and its terms, [name, codex, id] sorted by
## name; only what the engine runs (a planned term is never shown), and of the foes' words only the
## keywords their moves carry, those with an icon of their own (Terms), never the engine's (its aim,
## its menace). The statuses are filed by what each is to its unit (Ryan, 9 November: buffs and
## debuffs "clearly labeled as such, so that it's clear what gets purged"): the words about them
## first, then the buffs, the debuffs and the abilities, each under its own heading.
const STATUS_GROUPS := [["", "STATUSES"], ["buff", "BUFFS // A PURGE TAKES THEM"], ["debuff", "DEBUFFS"], ["ability", "ABILITIES // NOTHING STRIPS THEM"]]

static func glossary(db: ContentDB) -> Array:
	var out: Array = []
	for kind in GLOSSARY:
		var entries: Array = []
		for id in db.vocabulary.keys():
			var e: Dictionary = db.vocabulary[id]
			if str(e.get("category", "")) == str(kind[0]) and str(e.get("status", "")) == "implemented":
				if str(kind[0]) == "foe" and not Terms.has(str(id)):
					continue
				entries.append([str(e.get("name", id)), str(e.get("codex", "")), str(id)])
		entries.sort_custom(func(a: Array, b: Array) -> bool: return str(a[0]).naturalnocasecmp_to(str(b[0])) < 0)
		if entries.is_empty():
			continue
		if str(kind[0]) != "status":
			out.append({"title": kind[1], "entries": entries})
			continue
		for g in STATUS_GROUPS:
			var held: Array = []
			for en in entries:
				var what := Effects.status_kind(Terms.engine_status(str(en[2])))
				if what == str(g[0]) or (str(g[0]).is_empty() and not ["buff", "debuff", "ability"].has(what)):
					held.append(en)
			if not held.is_empty():
				out.append({"title": g[1], "entries": held})
	return out


## The keywords page's scroller: a heading a kind, then each term's icon and name in its colour
## over its codex line (Terms; Ryan, 30 October), the terms a line names highlighted and opening
## their own entries where they stand (KeywordTip), as everywhere.
func _keywords_list() -> ScrollContainer:
	var sc := _scroller()
	var col: VBoxContainer = sc.get_child(0)
	var width := WIDTH - 48.0 - 20.0   # inside the panel's margins, clear of the bar
	for kind in glossary(ContentDB.load_default()):
		var head := Hud.label(str(kind["title"]), 15, Palette.HUD, Hud.mono())
		col.add_child(head)
		for e in kind["entries"]:
			var term := EntryReadout.new()   # a name over its line, close together
			term.set_lines([EntryReadout.term_line(str(e[2])), EntryReadout.prose_line(str(e[1]), 17, Palette.INK.lerp(Palette.MUTED, 0.35))], width)
			col.add_child(term)
	return sc



## A page's scroller in the HUD's colours, holding one column.
func _scroller() -> ScrollContainer:
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	var bar := sc.get_v_scroll_bar()
	var track := StyleBoxFlat.new()
	track.bg_color = Color(Palette.HUD, 0.12)
	var grab := StyleBoxFlat.new()
	grab.bg_color = Color(Palette.HUD, 0.7)
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("grabber", grab)
	bar.add_theme_stylebox_override("grabber_highlight", grab)
	bar.add_theme_stylebox_override("grabber_pressed", grab)
	bar.custom_minimum_size = Vector2(8, 0)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(col)
	return sc


## The colours page's scroller: a heading a group, then a row a colour: its name, its swatch
## (a tap opens the picker), its hex, RESET once it is set, and what it paints.
func _colours_list() -> ScrollContainer:
	var sc := _scroller()
	var col: VBoxContainer = sc.get_child(0)
	var width := WIDTH - 48.0 - 20.0
	var heading := ""
	for s in ColourTuner.SLOTS:
		var key: String = s[0]
		if s[1] != heading:
			heading = s[1]
			col.add_child(Hud.label(heading, 15, Palette.HUD, Hud.mono()))
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 10)
		var name_l := Hud.label(key.replace("_", " ").to_upper(), 18, Palette.INK, Hud.display_bold())
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_l.clip_text = true
		line.add_child(name_l)
		var swatch := ColorPickerButton.new()
		swatch.color = ColourTuner.value(key)
		swatch.edit_alpha = false
		swatch.custom_minimum_size = Vector2(96, 40)
		var picker := swatch.get_picker()
		picker.picker_shape = ColorPicker.SHAPE_HSV_WHEEL
		picker.sampler_visible = false
		if "edit_intensity" in picker:
			picker.set("edit_intensity", false)   # no HDR here
		_picker_popup(swatch.get_popup())
		swatch.popup_closed.connect(func() -> void: _pick(key, swatch.color))
		line.add_child(swatch)
		var hex := Hud.label("#" + ColourTuner.value(key).to_html(false).to_upper(), 13,
				Palette.HUD if ColourTuner.is_set(key) else Palette.MUTED, Hud.mono())
		hex.custom_minimum_size = Vector2(118, 0)
		hex.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(hex)
		var reset := HudButton.new("RESET", func() -> void: _recolour(func() -> void: ColourTuner.reset(key)))
		reset.font_size = 12
		reset.custom_minimum_size = Vector2(76, 40)
		reset.modulate.a = 1.0 if ColourTuner.is_set(key) else 0.0
		reset.mouse_filter = Control.MOUSE_FILTER_STOP if ColourTuner.is_set(key) else Control.MOUSE_FILTER_IGNORE
		line.add_child(reset)
		row.add_child(line)
		var note := Hud.label(str(s[4]), 14, Palette.INK.lerp(Palette.MUTED, 0.35))
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.custom_minimum_size = Vector2(width, 0)
		row.add_child(note)
		col.add_child(row)
	return sc


## The picker's window: opaque on the HUD's panel, and half again as big, for a thumb.
func _picker_popup(pop: PopupPanel) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Palette.PANEL_RAISED
	box.border_color = Palette.HUD
	box.set_border_width_all(2)
	box.set_content_margin_all(12)
	pop.add_theme_stylebox_override("panel", box)
	pop.content_scale_factor = 1.5


## PEEK, COPY and RESET ALL in a row over BACK.
func _colour_tools() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var peek := HudButton.new("PEEK", func() -> void: _peek(true))
	# Each button is made before its press is connected, so the press sees the button: a lambda
	# keeps the value a local had when it was made.
	var copy := HudButton.new("COPY")
	copy.pressed.connect(func() -> void:
		var text := ColourTuner.export_text()
		DisplayServer.clipboard_set(text)
		print("COLOURS\n", text)
		copy.text = "COPIED"
		copy.queue_redraw()
		get_tree().create_timer(1.5).timeout.connect(func() -> void:
			if is_instance_valid(copy):
				copy.text = "COPY"
				copy.queue_redraw()))
	var reset_all := HudButton.new("RESET ALL")
	reset_all.pressed.connect(func() -> void:
		if not _reset_armed:
			_reset_armed = true
			reset_all.text = "SURE? AGAIN"
			reset_all.queue_redraw()
			get_tree().create_timer(3.0).timeout.connect(func() -> void:
				_reset_armed = false
				if is_instance_valid(reset_all):
					reset_all.text = "RESET ALL"
					reset_all.queue_redraw())
			return
		_reset_armed = false
		_recolour(func() -> void: ColourTuner.reset_all()))
	for b in [peek, copy, reset_all]:
		b.font_size = 14
		b.custom_minimum_size = Vector2(0, 54)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	_rows.add_child(row)


## A colour picked: set it if it changed, and rebuild behind the mask.
func _pick(key: String, c: Color) -> void:
	if Color(c, 1.0).to_html(false) == ColourTuner.value(key).to_html(false):
		return
	_recolour(func() -> void: ColourTuner.set_colour(key, c))


## A change to the colours, then the host rebuilt behind the mask as a display colour change
## is, and the page drawn again where it was scrolled.
func _recolour(change: Callable) -> void:
	if _busy:
		return
	_busy = true
	var at := _list.scroll_vertical if _list != null else 0
	_mask.visible = true
	_mask.move_to_front()
	if is_inside_tree():
		await get_tree().process_frame
		await get_tree().process_frame
	change.call()
	hud_changed.emit()
	if not is_instance_valid(self):
		return
	_show_page(_page)
	if is_inside_tree():
		await get_tree().process_frame
	if _list != null:
		_list.scroll_vertical = at
	_mask.visible = false
	_busy = false


## PEEK: the menu out of the way until a tap on the scrim, which goes clear meanwhile.
func _peek(on: bool) -> void:
	_peeking = on
	_panel.visible = not on
	_scrim.color = Color(0, 0, 0, 0.0 if on else 0.7)
	_peek_tag.visible = on
	if on:
		_peek_tag.move_to_front()

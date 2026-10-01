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

signal resumed
signal display_changed(key: String, value: Variant)
signal hud_changed
signal quit_requested

const WIDTH := 560.0
const MUSIC_GAP := 18.0   # between the menu's panel and the music plate

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


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_scrim = ColorRect.new()
	_scrim.color = Color(0, 0, 0, 0.7)
	_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_scrim.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and _page == "paused" and not _busy:
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
	_mask = BusyMask.new()
	_mask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mask.visible = false
	add_child(_mask)


func open() -> void:
	_music_loop = "?"
	_show_page("paused")
	visible = true
	Sound.play("menu_open")
	Sound.duck(true)


func close() -> void:
	visible = false
	Sound.play("ui_back")
	Sound.duck(false)
	resumed.emit()


func is_open() -> bool:
	return visible


func _show_page(page: String) -> void:
	_page = page
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	match page:
		"paused":
			_title("PAUSED")
			_button("RESUME", close, true)
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
			_toggle("FINE MAP", "fine_map")   # the map at the glass's density: sharper, costlier; a phone judges its frame rate
			_slider("MUSIC", "music")
			_slider("EFFECTS", "effects")
			_button("BACK", func() -> void: _show_page("paused"))
		"quit":
			_title("QUIT?")
			var l := Hud.label("Leave for the harness. A battle is kept where it stands.", 18, Palette.MUTED)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.autowrap_mode = TextServer.AUTOWRAP_WORD
			_rows.add_child(l)
			_button("STAY", func() -> void: _show_page("paused"), true)
			_button("QUIT", func() -> void:
				visible = false
				Sound.duck(false)
				quit_requested.emit())
	_fit()
	_fit.call_deferred()


func _fit() -> void:
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
	var loops: Array = Sound.SETS.get(Sound.set_playing(), [])
	var can_skip := loops.size() > 1
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


func _button(text: String, on_pressed: Callable, filled: bool = false) -> void:
	var b := HudButton.new(text, on_pressed)
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
		if key in ["music", "effects"]:
			Sound.apply_settings()
		display_changed.emit(key, v))
	row.add_child(s)
	_rows.add_child(row)


func _toggle(caption: String, key: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(_caption(caption))
	var c := CheckButton.new()
	c.button_pressed = bool(Settings.display[key])
	c.toggled.connect(func(on: bool) -> void:
		Settings.set_display(key, on)
		display_changed.emit(key, on))
	row.add_child(c)
	_rows.add_child(row)


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

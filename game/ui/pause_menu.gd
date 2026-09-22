class_name PauseMenu
extends Control

## The pause menu (Ryan, 22 September): MENU on either screen opens it over a scrim that
## swallows input. Two pages. PAUSED: resume, settings. SETTINGS: the display's colour and
## the knobs a player may want (brightness, the pace of moves, the glitch, the scan bar;
## Ryan, 22 September: saturation and bloom made no difference a player would want),
## saved through `Settings` and applied live by the host screen.

signal resumed
signal display_changed(key: String, value: Variant)
signal hud_changed

const WIDTH := 560.0

var _scrim: ColorRect
var _panel: HudPanel
var _rows: VBoxContainer
var _page := "paused"


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_scrim = ColorRect.new()
	_scrim.color = Color(0, 0, 0, 0.7)
	_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_scrim.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and _page == "paused":
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


func open() -> void:
	_show_page("paused")
	visible = true


func close() -> void:
	visible = false
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
		"settings":
			_title("SETTINGS")
			_colour_row()
			_slider("BRIGHTNESS", "brightness")
			_slider("MOVE PACE", "pace")
			_toggle("GLITCH", "glitch")
			_toggle("SCAN BAR", "scan")
			_button("BACK", func() -> void: _show_page("paused"))
	_fit()
	_fit.call_deferred()


func _fit() -> void:
	_panel.reset_size()
	_panel.size = Vector2(WIDTH, _panel.get_combined_minimum_size().y)


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
## rebuilds the host screen.
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
			if Settings.hud != id:
				Settings.set_hud(str(id))
				hud_changed.emit())
		row.add_child(b)
	_rows.add_child(row)


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

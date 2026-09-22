class_name MapTuner
extends HudPanel

## Live knobs for the battlefield's look (Ryan, 21 September): not for players, for
## tuning the display by eye without a rebuild. Opened by TUNE on the battle screen.

var _map: BattleMapView
var _rows: VBoxContainer


func _init(map: BattleMapView) -> void:
	super(14.0)
	_map = map
	custom_minimum_size = Vector2(340, 0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rows = VBoxContainer.new()
	_rows.position = Vector2(12, 10)
	_rows.add_theme_constant_override("separation", 4)
	add_child(_rows)
	_option("TRACE", ["light", "ink", "off"], func(i: int) -> void: _m3d().set_trace_mode(["light", "ink", "off"][i]))
	_slider("TRACE GAIN", 0.0, 2.5, 1.0, func(v: float) -> void: _m3d().set_trace_gain(v))
	_slider("BLOOM", 0.0, 2.0, 0.8, func(v: float) -> void: _m3d().set_glow(v))
	_slider("GRID", 0.0, 1.6, 0.7, func(v: float) -> void: _m3d().set_grid(v))
	_slider("SATURATION", 0.0, 1.6, 1.0, func(v: float) -> void: _map.tune("saturation", v))
	_slider("BRIGHTNESS", 0.4, 1.6, 1.0, func(v: float) -> void: _map.tune("brightness", v))
	_slider("FAR BLUR", 0.0, 6.0, 3.0, func(v: float) -> void: _map.tune("blur_max", v))
	_slider("EDGE RAMP", 10.0, 300.0, 30.0, func(v: float) -> void: _map.tune("edge_fade", v))   # smaller is harder
	_slider("EDGE BLUR", 0.0, 8.0, 1.6, func(v: float) -> void: _map.tune("edge_blur", v))
	_slider("FRAME", 0.0, 1.0, 0.5, func(v: float) -> void:
		_map.frame_alpha = v
		_map.queue_redraw())
	_slider("POSTERIZE", 2.0, 10.0, 5.0, func(v: float) -> void: _map.tune("levels", v))
	_slider("FLICKER", 0.0, 3.0, 1.0, func(v: float) -> void: _map.tune("flicker", v))
	_slider("FRAME RATE", 0.2, 6.0, 1.6, func(v: float) -> void: _map.tune("anim_rate", v))
	_slider("BLEED RADIUS", 0.6, 3.0, Bleed.squad_radius_hex, func(v: float) -> void:
		Bleed.squad_radius_hex = v
		_map.queue_redraw())
	_toggle("SCAN", true, func(on: bool) -> void:
		_map.sweep_on = on
		_map.queue_redraw())
	reset_size()


func _m3d() -> Map3D:
	return _map._map3d


func _label(text: String) -> Label:
	var l := Hud.label(text, 12, Palette.MUTED)
	l.custom_minimum_size = Vector2(110, 0)
	return l


func _slider(name: String, lo: float, hi: float, start: float, on_change: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_child(_label(name))
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = (hi - lo) / 100.0
	s.value = start
	s.custom_minimum_size = Vector2(190, 20)
	s.value_changed.connect(on_change)
	row.add_child(s)
	_rows.add_child(row)


func _option(name: String, items: Array, on_change: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_child(_label(name))
	var o := OptionButton.new()
	for it in items:
		o.add_item(str(it).to_upper())
	o.item_selected.connect(on_change)
	row.add_child(o)
	_rows.add_child(row)


func _toggle(name: String, start: bool, on_change: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_child(_label(name))
	var c := CheckButton.new()
	c.button_pressed = start
	c.toggled.connect(on_change)
	row.add_child(c)
	_rows.add_child(row)

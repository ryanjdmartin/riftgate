class_name TapPanel
extends PanelContainer

## A panel that emits `tapped` on a click or touch, with a swappable border colour.

signal tapped

var _style := StyleBoxFlat.new()


func _init(bg: Color = Palette.PANEL, border: Color = Palette.RULE) -> void:
	_style.bg_color = bg
	_style.border_color = border
	_style.set_border_width_all(2)
	_style.set_corner_radius_all(8)
	_style.set_content_margin_all(8)
	add_theme_stylebox_override("panel", _style)
	mouse_filter = Control.MOUSE_FILTER_STOP


func set_border(color: Color, width: int = 2) -> void:
	_style.border_color = color
	_style.set_border_width_all(width)


func set_bg(color: Color) -> void:
	_style.bg_color = color


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit()
		accept_event()

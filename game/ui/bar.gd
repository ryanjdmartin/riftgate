class_name Bar
extends Control

## A labelled value bar: "HULL 8/14" over a filled track.

var label: String = ""
var value: int = 0
var max_value: int = 1
var color: Color = Palette.HULL
var font_size: int = 13


func _init(lbl: String = "", col: Color = Palette.HULL) -> void:
	label = lbl
	color = col
	custom_minimum_size = Vector2(0, 22)


func set_values(v: int, m: int) -> void:
	value = v
	max_value = maxi(1, m)
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var track := Rect2(Vector2(0, 14), Vector2(size.x, 7))
	draw_rect(track, Palette.RULE)
	var frac := clampf(float(value) / float(max_value), 0.0, 1.0)
	if frac > 0.0:
		draw_rect(Rect2(track.position, Vector2(track.size.x * frac, track.size.y)), color)
	draw_string(font, Vector2(0, 11), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Palette.MUTED)
	var txt := "%d/%d" % [value, max_value]
	draw_string(font, Vector2(0, 11), txt, HORIZONTAL_ALIGNMENT_RIGHT, size.x, font_size, Palette.INK)

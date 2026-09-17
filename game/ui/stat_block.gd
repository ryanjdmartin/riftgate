class_name StatBlock
extends Control

## The core numbers of a unit as a small grid: a small caption with a big value under it,
## two per row. Replaces a one-line stats string in the codex, where the line wrapped and
## read like a subtitle although it is the critical information.

const ROW_H := 50.0
const COLS := 2

var items: Array = []     # [[caption, value], ...]


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_items(list: Array) -> void:
	items = list
	var rows := ceili(float(items.size()) / float(COLS))
	custom_minimum_size = Vector2(0, ROW_H * rows)
	size.y = custom_minimum_size.y
	visible = not items.is_empty()
	queue_redraw()


func _draw() -> void:
	var bold := Hud.display_bold()
	var mono := Hud.mono()
	var col_w := size.x / float(COLS)
	for i in range(items.size()):
		var x := float(i % COLS) * col_w
		var y := float(i / COLS) * ROW_H
		var value := str(items[i][1])
		var caption := str(items[i][0]).to_upper()
		draw_string(mono, Vector2(x, y + 13.0), caption, HORIZONTAL_ALIGNMENT_LEFT, col_w - 8.0, 11, Color(Palette.HUD, 0.7))
		draw_string(bold, Vector2(x, y + 40.0), value, HORIZONTAL_ALIGNMENT_LEFT, col_w - 8.0, 24, Palette.HUD)

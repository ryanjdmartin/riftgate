class_name StatBlock
extends Control

## The core numbers of a unit as a small grid of tiles: a big value with a small caption
## under it, two per row. Replaces a one-line stats string in the codex, where the line
## wrapped and read like a subtitle although it is the critical information.

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
		Hud.tick(self, Vector2(x + 2.0, y + 8.0), Color(Palette.HUD, 0.6))
		draw_string(bold, Vector2(x + 14.0, y + 26.0), value, HORIZONTAL_ALIGNMENT_LEFT, col_w - 16.0, 24, Palette.HUD)
		draw_string(mono, Vector2(x + 14.0, y + 42.0), caption, HORIZONTAL_ALIGNMENT_LEFT, col_w - 16.0, 11, Color(Palette.HUD, 0.7))

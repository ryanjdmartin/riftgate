class_name StatBlock
extends Control

## The core numbers of a unit as a small grid: a small caption with a big value under it,
## two per row. Replaces a one-line stats string in the codex, where the line wrapped and
## read like a subtitle although it is the critical information. A value is text, or parts
## (ContentDB.stat_parts): the base number in ink, and where the loadout or the battle moves
## it, what it is now in a bracket beside it, green for the player's gain and red for a loss,
## its arrow on it (Ryan, 26 October).

const ROW_H := 50.0
const COLS := 2
const INSET := 4.0   # glyphs have a left bearing; without this the first digit clips at the panel edge
const PX := 24       # a value
const BRACKET_PX := 19   # what it is now, beside it

var items: Array = []     # [[caption, value or parts], ...]


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_items(list: Array) -> void:
	items = list
	var rows := ceili(float(items.size()) / float(COLS))
	custom_minimum_size = Vector2(0, ROW_H * rows)
	size.y = custom_minimum_size.y
	visible = not items.is_empty()
	queue_redraw()


## An item's value as text, a moved number with its arrow ("36 (40▲)"), for tests.
static func value_text(item: Array) -> String:
	if not (item[1] is Array):
		return str(item[1])
	return EntryReadout.line_text({"parts": item[1]})


func _draw() -> void:
	var bold := Hud.display_bold()
	var mono := Hud.mono()
	var col_w := size.x / float(COLS)
	for i in range(items.size()):
		var x := float(i % COLS) * col_w + INSET
		var y := float(i / COLS) * ROW_H
		var caption := str(items[i][0]).to_upper()
		draw_string(mono, Vector2(x, y + 13.0), caption, HORIZONTAL_ALIGNMENT_LEFT, col_w - 8.0, 11, Color(Palette.HUD, 0.7))
		var parts: Array = items[i][1] if items[i][1] is Array else [{"text": str(items[i][1])}]
		var at := x
		for k in range(parts.size()):
			var p: Dictionary = parts[k]
			# The base in ink, the bracket a size down; a moved number in its trend's ink with its
			# arrow, the brackets around it plain.
			var px := PX if k == 0 else BRACKET_PX
			var text := str(p["text"])
			if k > 0 and not bool(p.get("glue", false)):
				at += bold.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			var ink := EntryReadout.trend_ink(p, Palette.INK if k == 0 else Color(Palette.INK, 0.85))
			draw_string(bold, Vector2(at, y + 40.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, px, ink)
			at += bold.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			if int(p.get("trend", 0)) != 0:
				EntryReadout.draw_arrow(self, Vector2(at + EntryReadout.ARROW_GAP, y + 40.0), float(px), int(p["trend"]), ink)
				at += EntryReadout.arrow_width(float(px))

class_name StatBlock
extends Control

## The core numbers of a unit as a small grid: a small caption with a big value under it,
## two per row. Replaces a one-line stats string in the codex, where the line wrapped and
## read like a subtitle although it is the critical information. A value is text, or parts
## (ContentDB.stat_parts): the base number in ink, and where the loadout or the battle moves
## it, the change in a bracket beside it, green where it is good for the unit and red where it
## is bad, its arrow on it (Ryan, 26 October: "Base (+/- change)").

const ROW_H := 50.0
const COLS := 2
const INSET := 4.0   # glyphs have a left bearing; without this the first digit clips at the panel edge
const PX := 24       # a value
const BRACKET_PX := 19   # the change, beside it

var items: Array = []     # [[caption, value or parts], ...]


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_items(list: Array) -> void:
	items = list
	_refit()
	visible = not items.is_empty()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_refit()


## Its height for the rows its items take at the width it has.
func _refit() -> void:
	var rows: int = _layout(maxf(size.x, custom_minimum_size.x))[1]
	custom_minimum_size.y = ROW_H * rows
	size.y = custom_minimum_size.y


## Where each item is drawn, as [[row, column], ...] and the rows they take: two to a row, and a
## value too long for its column on a row of its own, so nothing is ever drawn over its
## neighbour (a foe's aim, the row it had until 17 November, ran into the size beside it on a
## phone).
func _layout(width: float) -> Array:
	var bold := Hud.display_bold()
	var col_w := width / float(COLS)
	var cells: Array = []
	var row := 0
	var col := 0
	for item in items:
		var wide := _value_width(item, bold) > col_w - INSET - 8.0
		if wide and col > 0:
			row += 1
			col = 0
		cells.append([row, col])
		if wide or col == COLS - 1:
			row += 1
			col = 0
		else:
			col += 1
	return [cells, row + (1 if col > 0 else 0)]


## The width an item's value draws at: its parts as _draw sets them, a moved number's arrow
## included.
static func _value_width(item: Array, bold: Font) -> float:
	var parts: Array = item[1] if item[1] is Array else [{"text": str(item[1])}]
	var w := 0.0
	for k in range(parts.size()):
		var p: Dictionary = parts[k]
		var px := PX if k == 0 else BRACKET_PX
		if k > 0 and not bool(p.get("glue", false)):
			w += bold.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		w += bold.get_string_size(str(p["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		if int(p.get("trend", 0)) != 0:
			w += EntryReadout.arrow_width(float(px))
	return w


## An item's value as text, a moved number with its arrow ("36 (40▲)"), for tests.
static func value_text(item: Array) -> String:
	if not (item[1] is Array):
		return str(item[1])
	return EntryReadout.line_text({"parts": item[1]})


func _draw() -> void:
	var bold := Hud.display_bold()
	var mono := Hud.mono()
	var col_w := size.x / float(COLS)
	var cells: Array = _layout(size.x)[0]
	for i in range(items.size()):
		var x := float(int(cells[i][1])) * col_w + INSET
		var y := float(int(cells[i][0])) * ROW_H
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

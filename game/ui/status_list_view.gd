class_name StatusListView
extends Control

## Statuses and warnings as rows of icon plus text, for the hold readout. A row is
## [glyph id, text] or [glyph id, text, Color].

const ROW := 26.0

var rows: Array = []


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_rows(list: Array) -> void:
	rows = list
	custom_minimum_size = Vector2(0, ROW * rows.size())
	size.y = custom_minimum_size.y
	visible = not rows.is_empty()
	queue_redraw()


func _draw() -> void:
	var disp := Hud.display()
	for i in range(rows.size()):
		var r: Array = rows[i]
		var col: Color = r[2] if r.size() >= 3 else Palette.HUD
		var y := i * ROW
		var chip := Rect2(Vector2(0, y + 3.0), Vector2(20.0, 20.0))
		Hud.box(self, chip, 3.0, Color(Palette.BG, 0.92), col, 1.0)
		Glyphs.draw(self, str(r[0]), chip.get_center(), 12, col, 1.6)
		draw_string(disp, Vector2(30.0, y + ROW * 0.5 + 6.0), str(r[1]), HORIZONTAL_ALIGNMENT_LEFT, size.x - 32.0, 16, Palette.INK)

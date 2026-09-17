class_name FaceListView
extends Control

## Every face of a die in a column: a small face on the left, its description to the right.
## The current face is bracketed and drawn bright; the rest are dimmed. Used by the die's hold
## readout and by the codex.

const ROW := 54.0
const MINI := 44.0

var faces: Array = []     # Face
var current: int = -1
var columns: int = 1      # the codex runs two columns; the die readout one


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_faces(list: Array, cur: int) -> void:
	faces = list
	current = cur
	custom_minimum_size = Vector2(0, ROW * ceili(float(faces.size()) / float(maxi(1, columns))))
	size.y = custom_minimum_size.y
	queue_redraw()


func _draw() -> void:
	var mono := Hud.mono()
	var disp := Hud.display()
	var cols := maxi(1, columns)
	var rows := ceili(float(faces.size()) / float(cols))
	var col_w := size.x / float(cols)
	# Each column's content (face plus its widest line) is centred in its share of the width,
	# so two columns read as one centred block rather than one hugging each edge.
	var offsets: Array[float] = []
	for c in range(cols):
		var widest := 0.0
		for i in range(c * rows, mini(faces.size(), (c + 1) * rows)):
			widest = maxf(widest, disp.get_string_size(faces[i].describe(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x)
		var content := MINI + 22.0 + widest
		offsets.append(maxf(0.0, (col_w - content) * 0.5) if cols > 1 else 0.0)
	for i in range(faces.size()):
		var f: Face = faces[i]
		var column := i / rows
		var x0 := float(column) * col_w + offsets[column]      # fill down the first column, then the next
		var y := float(i % rows) * ROW
		var rect := Rect2(Vector2(x0 + 6.0, y + 5.0), Vector2(MINI, MINI))
		var cur := i == current
		var col := Palette.HUD if cur else Color(Palette.HUD, 0.5)
		if f.kind == Face.Kind.BLANK:
			col = Palette.ENEMY_DIM
		Hud.box(self, rect, 8.0, Palette.PANEL_RAISED if cur else Palette.PANEL, col, 2.0 if cur else 1.0)
		if cur:
			Hud.brackets(self, rect.grow(5.0), 9.0, Palette.HUD, 1.0)
		if f.kind == Face.Kind.BLANK:
			Glyphs.draw(self, "blank", rect.get_center(), 18.0, Palette.ENEMY_DIM, 2.5)
		else:
			Glyphs.draw(self, Glyphs.primary_for(f), rect.position + Vector2(10.0, 10.0), 10.0, col, 1.4)
			var num := f.number_text()
			draw_string(mono, Vector2(rect.position.x, rect.position.y + 35.0), num, HORIZONTAL_ALIGNMENT_CENTER, MINI, 13 if f.is_ranged() else 17, col)
			if f.cracked:
				draw_line(rect.position + Vector2(6.0, MINI - 6.0), rect.position + Vector2(MINI - 6.0, 6.0), Palette.ENEMY, 1.5)
		var ink := Palette.INK if cur else Palette.MUTED
		draw_string(disp, Vector2(x0 + MINI + 22.0, y + ROW * 0.5 + 6.0), f.describe(), HORIZONTAL_ALIGNMENT_LEFT, col_w - MINI - 26.0, 17, ink)

class_name FaceListView
extends Control

## Every face of a die in a column: a small face on the left, its description to the right.
## The current face is bracketed and drawn bright; the rest are dimmed. Each row opens on the
## entry's place on its die, a grey Roman numeral as on the die itself. The codex draws one
## entry's tile at a time (`tiles_only`), its lines beside it an EntryReadout (26 October); the
## die's hold shows the entry showing alone (EntryReadout, 25 October).

const ROW := 54.0
const MINI := 44.0
const GUTTER := 26.0      # the place's numeral, right-aligned left of the tile
const LINE := 19.0        # a description's line height when it takes two

var faces: Array = []     # Face
var current: int = -1
var columns: int = 1
var labels: Array = []    # optional, one per face: the component's name above its description
var first_place: int = 1  # the first face's place on its die
var tiles_only := false   # the numeral and the tile, no description (the codex's rows)
var numerals: bool = true # each row's place on its die; off for a list of pieces that are no die (the quick campaign's stores and picks)
var upgrades: Array = []  # optional, one per face: the branch's steps its machine has taken on it, a chevron each under its place (the die's own)


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
		var content := GUTTER + MINI + 22.0 + widest
		offsets.append(maxf(0.0, (col_w - content) * 0.5) if cols > 1 else 0.0)
	for i in range(faces.size()):
		var f: Face = faces[i]
		var column := i / rows
		var x0 := float(column) * col_w + offsets[column]      # fill down the first column, then the next
		var y := float(i % rows) * ROW
		if numerals:
			draw_string(Hud.quote(), Vector2(x0, y + 5.0 + MINI * 0.5 + 6.0), Hud.roman(i + first_place), HORIZONTAL_ALIGNMENT_RIGHT, GUTTER - 3.0, 17,
					Color(Palette.MUTED, 1.0 if i == current else 0.75))
			var steps := int(upgrades[i]) if i < upgrades.size() else 0
			if steps > 0:
				DieFaceView.draw_chevrons(self, Vector2(x0 + GUTTER - 3.0 - DieFaceView.CHEVRON_W * 0.8, y + 5.0 + MINI * 0.5 + 12.0), steps, Palette.INK, 0.8)
		x0 += GUTTER
		var rect := Rect2(Vector2(x0 + 6.0, y + 5.0), Vector2(MINI, MINI))
		var cur := i == current
		var col := Palette.HUD if cur else Color(Palette.HUD, 0.5)
		if f.kind == Face.Kind.BLANK and not f.empty:
			col = Palette.LOSS_DIM
		# A hardpoint is a socket: a dashed frame around the tile, so a free slot reads as a
		# slot and an empty one as an empty slot. A fixed component has no frame; it is the
		# machine itself.
		if not f.fixed:
			var socket := rect.grow(3.0)
			var dash := Color(Palette.HUD, 0.35 if not cur else 0.6)
			var seg := 6.0
			for edge in [[socket.position, Vector2(socket.end.x, socket.position.y)], [Vector2(socket.end.x, socket.position.y), socket.end],
					[socket.end, Vector2(socket.position.x, socket.end.y)], [Vector2(socket.position.x, socket.end.y), socket.position]]:
				var a: Vector2 = edge[0]
				var b: Vector2 = edge[1]
				var n := int(a.distance_to(b) / (seg * 2.0))
				for s in range(n + 1):
					var p0 := a.lerp(b, float(s * 2) * seg / a.distance_to(b))
					var p1 := a.lerp(b, minf(1.0, float(s * 2 + 1) * seg / a.distance_to(b)))
					draw_line(p0, p1, dash, 1.0)
		if f.empty:
			draw_rect(rect, Color(Palette.HUD, 0.06), true)
			draw_string(mono, Vector2(rect.position.x, rect.position.y + MINI * 0.5 + 4.0), "EMPTY", HORIZONTAL_ALIGNMENT_CENTER, MINI, 9, Color(Palette.HUD, 0.5))
		else:
			Hud.box(self, rect, 8.0, Palette.PANEL_RAISED if cur else Palette.PANEL, col, 2.0 if cur else 1.0)
		if cur:
			Hud.brackets(self, rect.grow(5.0), 9.0, Palette.HUD, 1.0)
		if f.empty:
			pass
		elif f.kind == Face.Kind.BLANK:
			Glyphs.draw(self, "blank", rect.get_center(), 18.0, Palette.LOSS_DIM, 2.5)
		else:
			Glyphs.draw(self, Glyphs.primary_for(f), rect.position + Vector2(10.0, 10.0), 10.0, col, 1.4)
			var num := f.number_text()
			draw_string(mono, Vector2(rect.position.x, rect.position.y + 35.0), num, HORIZONTAL_ALIGNMENT_CENTER, MINI, 17, col)
		if tiles_only:
			continue
		var ink := Palette.INK if cur else Palette.MUTED
		if i < labels.size() and not str(labels[i]).is_empty():
			draw_string(mono, Vector2(x0 + MINI + 22.0, y + 21.0), str(labels[i]), HORIZONTAL_ALIGNMENT_LEFT, col_w - GUTTER - MINI - 26.0, 11, Color(Palette.HUD, 0.8 if cur else 0.5))
			draw_string(disp, Vector2(x0 + MINI + 22.0, y + 42.0), f.describe(), HORIZONTAL_ALIGNMENT_LEFT, col_w - GUTTER - MINI - 26.0, 17, ink)
		else:
			# The codex's two columns are narrow: a long description takes a second line rather
			# than running off its column.
			var lines := _wrapped(disp, f.describe(), col_w - GUTTER - MINI - 26.0, 17, 2)
			var base := y + ROW * 0.5 + 6.0 - float(lines.size() - 1) * LINE * 0.5
			for k in range(lines.size()):
				draw_string(disp, Vector2(x0 + MINI + 22.0, base + k * LINE), lines[k], HORIZONTAL_ALIGNMENT_LEFT, col_w - GUTTER - MINI - 26.0, 17, ink)


## `text` broken at spaces into at most `max_lines` lines no wider than `width`; the last line
## keeps whatever is left.
static func _wrapped(font: Font, text: String, width: float, size_px: int, max_lines: int) -> PackedStringArray:
	var out: PackedStringArray = []
	var line := ""
	for word in text.split(" "):
		var trial := word if line.is_empty() else line + " " + word
		if line.is_empty() or out.size() == max_lines - 1 or font.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x <= width:
			line = trial
		else:
			out.append(line)
			line = word
	out.append(line)
	return out

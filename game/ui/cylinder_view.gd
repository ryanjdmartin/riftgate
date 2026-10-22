class_name CylinderView
extends Control

## A stepping die's chambers as a revolver's cylinder seen end on (the Cassowary's; Ryan asked
## for a ring in the hold, 19 October; built 22 October): every entry on a ring in its order,
## clockwise from the top, each a chamber with its primary glyph and number, its place's
## numeral outside it as on the die. In the die's hold the chamber showing is lit and
## bracketed, and an arrow runs round the ring from it to the next, the chamber the dial turns
## to; in the codex, between fights, nothing is lit and every gap carries a faint arrow, so the
## ring reads as the order the die keeps. Shown only for a die that steps.

const SIDE := 200.0        # the cylinder's square box: small enough that a d6's hold still sits above its die
const CHAMBER := 18.0      # a chamber's radius
const RIM := 0.33          # the ring's radius, as a share of the box, chamber centre to centre

var faces: Array = []      # Face, in the die's order
var current: int = -1      # the chamber showing; -1 for none (the codex)
var next: int = -1         # the chamber the next step turns to; -1 draws every gap's arrow


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(SIDE, SIDE)


func set_cylinder(list: Array, cur: int = -1, nxt: int = -1) -> void:
	faces = list
	current = cur
	next = nxt
	queue_redraw()


## The centre of chamber `i` of `n`, clockwise from the top.
func chamber_at(i: int, n: int) -> Vector2:
	var a := -PI * 0.5 + float(i) * TAU / float(maxi(1, n))
	return _centre() + Vector2(cos(a), sin(a)) * SIDE * RIM


func _centre() -> Vector2:
	return Vector2(size.x * 0.5, SIDE * 0.5)


func _draw() -> void:
	var n := faces.size()
	if n == 0:
		return
	var c := _centre()
	var rim := SIDE * RIM
	# The cylinder's body: a dark disc under the chambers and a ring through their centres.
	draw_circle(c, rim + CHAMBER + 6.0, Color(Palette.BG, 0.6))
	draw_arc(c, rim + CHAMBER + 6.0, 0.0, TAU, 48, Color(Palette.HUD, 0.35), 1.5)
	draw_circle(c, 7.0, Color(Palette.HUD, 0.35))
	var step := TAU / float(n)
	# The arrows round the ring: the one from the chamber showing to the next, bright; in the
	# codex every gap's, faint.
	for i in range(n):
		var to := (i + 1) % n
		var lit := i == current and to == next
		if next >= 0 and not lit:
			continue
		var a0 := -PI * 0.5 + float(i) * step
		var a1 := a0 + step
		var gap := (CHAMBER + 4.0) / rim   # clear of the chambers at both ends
		if a1 - a0 <= gap * 2.0:
			continue
		var col := Color(Palette.HUD, 1.0 if lit else 0.35)
		var w := 3.0 if lit else 1.5
		draw_arc(c, rim, a0 + gap, a1 - gap, 12, col, w)
		var tip := c + Vector2(cos(a1 - gap), sin(a1 - gap)) * rim
		var along := Vector2(-sin(a1 - gap), cos(a1 - gap))   # clockwise, the way the die turns
		var side := along.orthogonal()
		var head := 9.0 if lit else 6.0
		draw_colored_polygon(PackedVector2Array([tip + along * head * 0.4, tip - along * head + side * head * 0.6, tip - along * head - side * head * 0.6]), col)
	var mono := Hud.mono()
	for i in range(n):
		var f: Face = faces[i]
		var p := chamber_at(i, n)
		var cur := i == current
		var col := Palette.HUD if cur or current < 0 else Color(Palette.HUD, 0.55)
		if f.kind == Face.Kind.BLANK and not f.empty:
			col = Palette.ENEMY_DIM
		draw_circle(p, CHAMBER, Palette.PANEL_RAISED if cur else Palette.PANEL)
		draw_arc(p, CHAMBER, 0.0, TAU, 28, col, 2.5 if cur else 1.2)
		if cur:
			Hud.brackets(self, Rect2(p - Vector2(CHAMBER + 5.0, CHAMBER + 5.0), Vector2(CHAMBER + 5.0, CHAMBER + 5.0) * 2.0), 8.0, Palette.HUD, 1.2)
		if f.empty:
			draw_string(mono, p + Vector2(-CHAMBER, 4.0), "EMPTY", HORIZONTAL_ALIGNMENT_CENTER, CHAMBER * 2.0, 8, Color(Palette.HUD, 0.5))
		elif f.kind == Face.Kind.BLANK:
			Glyphs.draw(self, "blank", p, 14.0, Palette.ENEMY_DIM, 2.0)
		else:
			Glyphs.draw(self, Glyphs.primary_for(f), p + Vector2(0, -6.0), 12.0, col, 1.5)
			draw_string(mono, p + Vector2(-CHAMBER, 12.0), f.number_text(), HORIZONTAL_ALIGNMENT_CENTER, CHAMBER * 2.0, 10 if f.is_ranged() else 12, col)
		# The place's numeral outside the chamber, radially, in the die's grey italic.
		var out := (p - c).normalized()
		var at := p + out * (CHAMBER + 12.0)
		draw_string(Hud.quote(), at + Vector2(-16.0, 6.0), Hud.roman(i + 1), HORIZONTAL_ALIGNMENT_CENTER, 32.0, 15, Color(Palette.MUTED, 1.0 if cur else 0.8))

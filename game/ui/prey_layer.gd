class_name PreyLayer
extends Control

## The predator sense (Ryan, 17 October: "pulsing eyes over eligible foes actually helps sell
## the fantasy, in addition to helping the player. Could go all in and dim the screen slightly
## in a predator-sense kind of way"; the funnel-web's row, 18 October): while an ambusher's
## die is held or dragged, the foes' ground dims and every foe the entry showing can reach that
## shows no intent on the machine gets a pair of narrowed eyes pulsing over its head. Motion
## and a glyph, never a hue (Ryan is colourblind): the eyes are ink on a dark edge, the HUD
## colour only a glow breathing behind them. Started hot, since every effect judged on the
## phone has come back hotter; RIFTGATE_PREY_DEBUG=1 keeps it on, to judge it running.
##
## Its second style, the blast's marks (the Whip Scorpion's vents, 22 October): every foe a vent
## may blast wears a dashed ring turning round it, the dashes saying "one of these" and the turn
## saying it is live, with what the blast would deal there on a dark plate at its middle; the
## ground stays as it is. RIFTGATE_BLAST_DEBUG=1 keeps them on.

const DIM := 0.62        # the ground's shade while the sense is on (hot first; a placeholder)
const RATE := 1.4        # pulses a second
const EYE_W := 0.17      # an eye's half-width, as a share of the drawing's width
const EYE_H := 0.42      # its half-height, as a share of its half-width
const APART := 0.15      # each eye's centre this far from the drawing's middle, a share of its width
const HEAD := 0.22       # the eyes sit this far down the drawing, a share of its height
const BROW := 0.42       # the inner corner sits this far below the outer, a share of the half-width: narrowed, hunting
const RING := 0.56       # the blast's ring, its radius as a share of the drawing's longer side (hot first; placeholders)
const DASHES := 12       # the ring's dashes
const SPIN := 0.3        # its turns a second
const NUMBER := 26       # the number's size on its plate

var on := false
var marks: Array = []    # the eligible foes' drawings, as global rects
var style := "eyes"      # "eyes", the predator sense; "blast", the blast's marks
var labels: Array = []   # with "blast", each mark's number, by the marks' order
var _t := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


## The sense on, over these drawings (global rects); with none, the ground still dims. The
## blast's style draws its rings and `numbers` instead, and dims nothing.
func show_marks(global_rects: Array, mark_style: String = "eyes", numbers: Array = []) -> void:
	marks = global_rects
	style = mark_style
	labels = numbers
	on = true
	set_process(true)
	queue_redraw()


func hide_marks() -> void:
	on = false
	marks = []
	set_process(false)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	if not on:
		return
	if style != "blast":
		draw_rect(Rect2(Vector2.ZERO, size), Color(Palette.BG, DIM))
	var xf := get_global_transform().affine_inverse()
	var pulse := 0.5 + 0.5 * sin(_t * TAU * RATE)
	for k in range(marks.size()):
		var g: Rect2 = marks[k]
		var local := Rect2(xf * g.position, xf.get_scale() * g.size)
		if style == "blast":
			_ring(local, str(labels[k]) if k < labels.size() else "", pulse)
		else:
			_eyes(local, pulse)


## A blast's mark: a dashed ring turning round the drawing, each dash on a dark edge, in heat's
## colour (the blast is the machine's heat fired), and the number it would deal there on a dark
## plate at the drawing's middle.
func _ring(rect: Rect2, label: String, pulse: float) -> void:
	var c := rect.get_center()
	var r := maxf(rect.size.x, rect.size.y) * RING
	var col := Color(Palette.HEAT, 0.7 + 0.3 * pulse)
	var step := TAU / float(DASHES)
	var turn := _t * TAU * SPIN
	for k in range(DASHES):
		var a0 := turn + k * step
		draw_arc(c, r, a0, a0 + step * 0.55, 6, Color(Palette.BG, 0.9), 7.0)
		draw_arc(c, r, a0, a0 + step * 0.55, 6, col, 4.0)
	if label.is_empty():
		return
	var mono := Hud.mono()
	var w := mono.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, NUMBER).x
	var plate := Rect2(c - Vector2(w * 0.5 + 9.0, NUMBER * 0.5 + 6.0), Vector2(w + 18.0, NUMBER + 12.0))
	Hud.box(self, plate, 6.0, Color(Palette.BG, 0.94), col, 2.5)
	draw_string(mono, Vector2(plate.position.x + 9.0, plate.end.y - 9.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, NUMBER, Palette.INK)


## Two narrowed eyes over the head of a drawing: a glow in the HUD colour, a dark edge, the ink
## lens, and a slit pupil, all breathing with the pulse.
func _eyes(rect: Rect2, pulse: float) -> void:
	var y := rect.position.y + rect.size.y * HEAD
	var hw := rect.size.x * EYE_W * (0.92 + 0.16 * pulse)
	var hh := hw * EYE_H
	for side: float in [-1.0, 1.0]:
		var c := Vector2(rect.get_center().x + side * rect.size.x * APART, y)
		var tilt: float = -side * atan(BROW)
		Hud.fill_poly(self, _lens(c, hw * 1.9, hh * 2.6, tilt), Color(Palette.HUD, 0.10 + 0.22 * pulse))
		Hud.fill_poly(self, _lens(c, hw + 2.0, hh + 2.0, tilt), Color(Palette.BG, 0.95))
		Hud.fill_poly(self, _lens(c, hw, hh, tilt), Color(Palette.INK, 0.72 + 0.28 * pulse))
		draw_line(c + Vector2(0, -hh * 0.9), c + Vector2(0, hh * 0.9), Color(Palette.BG, 0.95), maxf(1.5, hw * 0.16))


## An almond: two parabolic arcs meeting at the corners, turned by `angle` about its centre.
static func _lens(c: Vector2, hw: float, hh: float, angle: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := 10
	for i in range(n + 1):
		var x := -hw + 2.0 * hw * float(i) / float(n)
		pts.append(Vector2(x, -hh * (1.0 - pow(x / hw, 2.0))))
	for i in range(n - 1, 0, -1):
		var x := -hw + 2.0 * hw * float(i) / float(n)
		pts.append(Vector2(x, hh * (1.0 - pow(x / hw, 2.0))))
	for i in range(pts.size()):
		pts[i] = c + pts[i].rotated(angle)
	return pts

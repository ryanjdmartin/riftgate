class_name ReserveView
extends Control

## The reinforcements waiting, by rank (Ryan, 15 October: wanted; built 22 October): in the
## gutter at the formation's right edge, a plaque at each rank's height with an arrow pointing
## into the formation over the count of foes waiting to step into that rank, and between the
## ranks, when one waits, a tall plaque for the massive foes that take a whole column. A rank
## with none waiting shows its plaque dim at nought while any foe waits, so a mine is laid
## against a count; with the reserve empty nothing shows. Ink on a dark ground, the enemy's
## red only on its edge and arrow, the structure (an arrow, a tall frame) carrying the read.

const ARROW := 6.0          # the arrow's half-height over the count
const NUMBER := 17          # the count's size
const MASSIVE_H := 0.36     # the massive plaque's height, a share of the gap between the ranks' centres

var back_y := Vector2.ZERO  # the back rank's top and bottom, in this control's space
var front_y := Vector2.ZERO
var counts := {}            # {"front": n, "back": n, "massive": n}


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_counts(c: Dictionary) -> void:
	if c != counts:
		counts = c
		queue_redraw()


func _draw() -> void:
	var front := int(counts.get("front", 0))
	var back := int(counts.get("back", 0))
	var massive := int(counts.get("massive", 0))
	if front + back + massive <= 0:
		return
	var mid_back := (back_y.x + back_y.y) * 0.5
	var mid_front := (front_y.x + front_y.y) * 0.5
	_plaque(mid_back, back, false)
	_plaque(mid_front, front, false)
	if massive > 0:
		_plaque((mid_back + mid_front) * 0.5, massive, true)


## One rank's plaque, centred at `y`: the arrow into the formation over the count; a massive
## one is taller, its frame doubled, a column's mark (a tall bar) in place of the arrow.
func _plaque(y: float, n: int, massive: bool) -> void:
	var w := size.x - 2.0
	var h := (absf(front_y.x - back_y.x) * MASSIVE_H) if massive else 46.0
	var r := Rect2(Vector2(1.0, y - h * 0.5), Vector2(w, h))
	var live := n > 0
	var edge := Color(Palette.ENEMY, 1.0 if live else 0.35)
	var ink := Color(Palette.INK, 1.0 if live else 0.4)
	Hud.box(self, r, 4.0, Color(Palette.BG, 0.9), edge, 2.0 if live else 1.0)
	if massive:
		Hud.stroke_poly(self, Hud.cut(r.grow(-3.0), 3.0), edge, 1.0)
		var bar := Rect2(Vector2(r.get_center().x - 3.0, r.position.y + 7.0), Vector2(6.0, 14.0))
		draw_rect(bar, edge, true)
	else:
		var c := Vector2(r.get_center().x, r.position.y + 11.0)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-ARROW, 0.0), c + Vector2(ARROW * 0.8, -ARROW), c + Vector2(ARROW * 0.8, ARROW)]), edge)
	var label := str(n)
	draw_string(Hud.mono(), Vector2(r.position.x, r.end.y - 7.0), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, NUMBER, ink)

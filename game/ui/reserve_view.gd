class_name ReserveView
extends Control

## The reinforcements waiting, by rank (Ryan, 15 October: wanted; built 22 October): at the
## formation's right edge, a plaque at each rank's height with an arrow pointing into the
## formation over the count of foes waiting to step into that rank, and between the ranks, when
## one waits, a tall plaque for the massive foes that take a whole column. A rank with none
## waiting shows its plaque dim at nought while any foe waits, so a mine is laid against a count;
## with the reserve empty nothing shows. Ink on a dark ground, the enemy's violet on its edge and
## arrow, the structure (an arrow, a tall frame) carrying the read. Big enough to read and to
## tap (Ryan, 2 November: "reinforcement icons need to be bigger and more obvious. Ideally we can
## tap them to pull them out and see the queue"): a tap on any plaque asks the screen for the
## waiting foes' list (`tapped`), and the plaques light while it is out.

signal tapped

const ARROW := 10.0         # the arrow's half-height over the count
const NUMBER := 28          # the count's size
const PLAQUE_H := 76.0      # a rank's plaque
const MASSIVE_H := 0.36     # the massive plaque's height, a share of the gap between the ranks' centres
const TAP_GROW := 8.0       # a plaque's tap area past its frame, for a thumb
const TAP_SLOP := 14.0      # how far a press may travel and still be a tap

var back_y := Vector2.ZERO  # the back rank's top and bottom, in this control's space
var front_y := Vector2.ZERO
var counts := {}            # {"front": n, "back": n, "massive": n}
var open := false           # the waiting foes' list is out: the plaques lit
## Foes on their way into the pool (Ryan, 25 October: a foe joining it needs an animation): the
## screen flies each in, and its count goes up with a burst as it lands (arrive).
var pending := {"front": 0, "back": 0, "massive": 0}
var _bursts: Dictionary = {}   # kind -> seconds since a foe landed in that plaque
const BURST_SECONDS := 0.7
var _rects: Array[Rect2] = []  # the plaques as last drawn, for a tap
var _press_at := Vector2.ZERO
var _pressed := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP   # on its plaques alone (_has_point): the rest of the gutter lets taps through
	set_process(false)


func set_counts(c: Dictionary) -> void:
	if c != counts:
		counts = c
		queue_redraw()


## How many wait, the ones on their way in still uncounted.
func waiting() -> int:
	var n := 0
	for k in ["front", "back", "massive"]:
		n += int(counts.get(k, 0)) - int(pending.get(k, 0))
	return n


## Where a rank's plaque sits, in this control's space: "front", "back" or "massive".
func plaque_center(kind: String) -> Vector2:
	var mid_back := (back_y.x + back_y.y) * 0.5
	var mid_front := (front_y.x + front_y.y) * 0.5
	var y := mid_back if kind == "back" else (mid_front if kind == "front" else (mid_back + mid_front) * 0.5)
	return Vector2(size.x * 0.5, y)


## A foe flown in has landed: its count goes up, and the plaque bursts.
func arrive(kind: String) -> void:
	pending[kind] = maxi(0, int(pending.get(kind, 0)) - 1)
	_bursts[kind] = 0.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	for k in _bursts.keys():
		_bursts[k] += delta
		if _bursts[k] > BURST_SECONDS:
			_bursts.erase(k)
	if _bursts.is_empty():
		set_process(false)
	queue_redraw()


## A tap lands on a plaque alone; the gutter round them lets it through to what lies under.
func _has_point(point: Vector2) -> bool:
	for r in _rects:
		if r.grow(TAP_GROW).has_point(point):
			return true
	return false


func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or (event as InputEventMouseButton).button_index != MOUSE_BUTTON_LEFT:
		return
	var mb := event as InputEventMouseButton
	accept_event()
	if mb.pressed:
		_pressed = true
		_press_at = mb.position
	elif _pressed:
		_pressed = false
		if mb.position.distance_to(_press_at) <= TAP_SLOP:
			tapped.emit()


func _draw() -> void:
	_rects.clear()
	var front := int(counts.get("front", 0)) - int(pending.get("front", 0))
	var back := int(counts.get("back", 0)) - int(pending.get("back", 0))
	var massive := int(counts.get("massive", 0)) - int(pending.get("massive", 0))
	if front + back + massive <= 0:
		return
	var mid_back := (back_y.x + back_y.y) * 0.5
	var mid_front := (front_y.x + front_y.y) * 0.5
	_plaque(mid_back, back, false)
	_plaque(mid_front, front, false)
	if massive > 0:
		_plaque((mid_back + mid_front) * 0.5, massive, true)
	# A foe landing in a plaque: the frame flashes hot, a ring bursts off it and a +1 rises.
	for kind in _bursts.keys():
		var t := clampf(float(_bursts[kind]) / BURST_SECONDS, 0.0, 1.0)
		var c := plaque_center(str(kind))
		var r := Rect2(c - Vector2(size.x * 0.5 - 1.0, PLAQUE_H * 0.5), Vector2(size.x - 2.0, PLAQUE_H))
		Hud.box(self, r.grow(2.0 + 14.0 * t), 5.0, Color(0, 0, 0, 0), Color(Palette.ENEMY, 1.0 - t), 3.0 * (1.0 - t) + 1.0)
		if t < 0.3:
			Hud.box(self, r, 4.0, Color(Palette.ENEMY, (0.3 - t) * 2.0), Color(0, 0, 0, 0), 0.0)
		var y := r.position.y - 6.0 - 22.0 * t
		draw_string_outline(Hud.mono(), Vector2(r.position.x, y), "+1", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 22, 4, Color(Palette.BG, 1.0 - t))
		draw_string(Hud.mono(), Vector2(r.position.x, y), "+1", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 22, Color(Palette.ENEMY, 1.0 - t))


## One rank's plaque, centred at `y`: the arrow into the formation over the count; a massive
## one is taller, its frame doubled, a column's mark (a tall bar) in place of the arrow. Lit
## while the list is out, so the plaque reads as the list's handle.
func _plaque(y: float, n: int, massive: bool) -> void:
	var w := size.x - 2.0
	var h := (absf(front_y.x - back_y.x) * MASSIVE_H) if massive else PLAQUE_H
	var r := Rect2(Vector2(1.0, y - h * 0.5), Vector2(w, h))
	_rects.append(r)
	var live := n > 0
	var edge := Color(Palette.ENEMY, 1.0 if live else 0.4)
	var ink := Color(Palette.INK, 1.0 if live else 0.45)
	var fill := Color(Palette.ENEMY, 0.3) if open else Color(Palette.BG, 0.92)
	Hud.box(self, r, 5.0, fill, edge, 3.0 if live else 1.5)
	if massive:
		Hud.stroke_poly(self, Hud.cut(r.grow(-4.0), 4.0), edge, 1.5)
		var bar := Rect2(Vector2(r.get_center().x - 4.0, r.position.y + 9.0), Vector2(8.0, 18.0))
		draw_rect(bar, edge, true)
	else:
		var c := Vector2(r.get_center().x, r.position.y + 18.0)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-ARROW, 0.0), c + Vector2(ARROW * 0.8, -ARROW), c + Vector2(ARROW * 0.8, ARROW)]), edge)
	draw_string(Hud.mono(), Vector2(r.position.x, r.end.y - 12.0), str(n), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, NUMBER, ink)

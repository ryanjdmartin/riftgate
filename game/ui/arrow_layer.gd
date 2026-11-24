class_name ArrowLayer
extends Control

## Draws the foes' intent lines over the screen. Ignores input. Points are in this control's local
## space. A line runs from the foe's feet to the top of its machine's gauges, no head on it, its
## dashes crawling toward the machine as the aim's tether does (Ryan, 24 November: "can we try
## adding some animation to enemy intent lines, like what the target drag does? ... doesn't need an
## arrowhead"). An intent's dashes run over a faint line of their own; a preview's (a lure that
## would turn the foe, 22 October, or the blow that spills to the next machine) run over nothing,
## so what would happen parts from what will by its structure.

const DASH := 14.0       # a dash and the gap after it, in pixels
const GAP := 9.0
const WIDTH := 5.0
const CRAWL := 36.0      # pixels a second the dashes travel toward the machine

var arrows: Array = []   # [from: Vector2, to: Vector2, color: Color, dashed: bool (optional)]


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_arrows(list: Array) -> void:
	arrows = list
	set_process(not arrows.is_empty())
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var shift := fmod(Time.get_ticks_msec() / 1000.0 * CRAWL, DASH + GAP)
	var dark := Color(Palette.BG, 0.8)
	for a in arrows:
		var from: Vector2 = a[0]
		var to: Vector2 = a[1]
		var color: Color = a[2]
		var preview: bool = a.size() > 3 and bool(a[3])
		var length := from.distance_to(to)
		if length < 1.0:
			continue
		var dir := (to - from) / length
		if not preview:
			draw_line(from, to, Color(Palette.BG, 0.5), WIDTH + 2.0)
			draw_line(from, to, Color(color, 0.35), WIDTH - 1.0)
		var d := shift - (DASH + GAP)
		while d < length:
			var p := maxf(d, 0.0)
			var q := minf(d + DASH, length)
			if q > p:
				draw_line(from + dir * p, from + dir * q, dark, WIDTH + 3.0)
				draw_line(from + dir * p, from + dir * q, color, WIDTH)
			d += DASH + GAP

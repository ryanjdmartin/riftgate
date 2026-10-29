class_name ArrowLayer
extends Control

## Draws intent arrows over the screen. Ignores input. Points are in this control's local space.
## A preview's arrow (a lure that would turn the foe, 22 October) is dashed: what would happen,
## parted from what will by its structure.

const DASH := 14.0       # a preview's dash and the gap after it, in pixels
const GAP := 9.0

var arrows: Array = []   # [from: Vector2, to: Vector2, color: Color, dashed: bool (optional)]


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_arrows(list: Array) -> void:
	arrows = list
	queue_redraw()


func _draw() -> void:
	for a in arrows:
		var from: Vector2 = a[0]
		var to: Vector2 = a[1]
		var color: Color = a[2]
		var dir := (to - from).normalized()
		var tip := to - dir * 14.0
		if a.size() > 3 and bool(a[3]):
			var length := from.distance_to(tip)
			var at := 0.0
			while at < length:
				draw_line(from + dir * at, from + dir * minf(length, at + DASH), color, 3.0)
				at += DASH + GAP
		else:
			draw_line(from, tip, color, 3.0)
		var left := tip - dir * 12.0 + dir.orthogonal() * 8.0
		var right := tip - dir * 12.0 - dir.orthogonal() * 8.0
		draw_colored_polygon(PackedVector2Array([to, left, right]), color)

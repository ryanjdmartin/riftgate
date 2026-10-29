class_name ArrowLayer
extends Control

## Draws intent arrows over the screen. Ignores input. Points are in this control's local space.
## A preview's arrow (a lure that would turn the foe, 22 October) is dashed: what would happen,
## parted from what will by its structure. Every arrow runs on a deep-red edge, as the map's red
## lines do, so it reads on the field's bright grounds (29 October) for any kind of colour vision.

const DASH := 14.0       # a preview's dash and the gap after it, in pixels
const GAP := 9.0

var arrows: Array = []   # [from: Vector2, to: Vector2, color: Color, dashed: bool (optional)]
var edge := Palette.ENEMY_EDGE
const EDGE_W := 3.0      # the edge's width each side of a line, and round the head


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
		var under := Color(edge, edge.a * color.a)
		var left := tip - dir * 12.0 + dir.orthogonal() * 8.0
		var right := tip - dir * 12.0 - dir.orthogonal() * 8.0
		var head := PackedVector2Array([to, left, right])
		# The head's edge: the triangle grown about its middle.
		var mid := (to + left + right) / 3.0
		var grown := PackedVector2Array()
		for p in head:
			grown.append(mid + (p - mid) * (1.0 + EDGE_W / maxf(1.0, (p - mid).length())))
		if a.size() > 3 and bool(a[3]):
			var length := from.distance_to(tip)
			for pass_i in range(2):
				var at := 0.0
				while at < length:
					var p0 := from + dir * at
					var p1 := from + dir * minf(length, at + DASH)
					if pass_i == 0:
						draw_line(p0 - dir * EDGE_W * 0.5, p1 + dir * EDGE_W * 0.5, under, 3.0 + EDGE_W * 2.0)
					else:
						draw_line(p0, p1, color, 3.0)
					at += DASH + GAP
		else:
			draw_line(from, tip, under, 3.0 + EDGE_W * 2.0)
			draw_line(from, tip, color, 3.0)
		draw_colored_polygon(grown, under)
		draw_colored_polygon(head, color)

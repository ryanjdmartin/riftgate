class_name ArrowLayer
extends Control

## Draws intent arrows over the screen. Ignores input. Points are in this control's local space.

var arrows: Array = []   # [from: Vector2, to: Vector2, color: Color]


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
		draw_line(from, tip, color, 3.0)
		var left := tip - dir * 12.0 + dir.orthogonal() * 8.0
		var right := tip - dir * 12.0 - dir.orthogonal() * 8.0
		draw_colored_polygon(PackedVector2Array([to, left, right]), color)

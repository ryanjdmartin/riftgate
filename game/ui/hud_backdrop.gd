class_name HudBackdrop
extends Control

## The screen's ground: near-black with faint scanlines and a few dim section rules.

var rules: Array[float] = []   # y positions of faint horizontal rules


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Palette.BG)
	Hud.scanlines(self, rect)
	for y in rules:
		draw_line(Vector2(12.0, y), Vector2(size.x - 12.0, y), Color(Palette.HUD, 0.22), 1.0)

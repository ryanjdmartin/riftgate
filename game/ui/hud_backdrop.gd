class_name HudBackdrop
extends Control

## The screen's ground: near-black with faint scanlines, a few dim section rules, a slow
## scan band drifting down the screen so the HUD never sits perfectly still, and, when a
## screen asks for it, bands of textured ground in the terrain the fight is on.

var rules: Array[float] = []   # y positions of faint horizontal rules
var grounds: Array = []        # [[Rect2, terrain, seed], ...]
var scan: bool = true          # the drifting band
var _t := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	set_process(scan)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Palette.BG)
	for g in grounds:
		var style: String = g[3] if g.size() > 3 else "ground"
		TerrainArt.draw_ground(self, g[0], int(g[1]), int(g[2]), 30.0, style, int(_t * 1.6) % 2)
	Hud.scanlines(self, rect)
	if scan:
		# A soft band that takes about nine seconds to cross the screen.
		var y := scan_y()
		for i in range(-2, 3):
			draw_rect(Rect2(0.0, y + i * 3.0, size.x, 1.0), Color(1, 1, 1, 0.07 - 0.015 * absi(i)))


## Where the band is right now, in this control's pixels.
func scan_y() -> float:
	return fmod(_t * 140.0, size.y + 120.0) - 60.0
	for y in rules:
		draw_line(Vector2(12.0, y), Vector2(size.x - 12.0, y), Color(Palette.HUD, 0.22), 1.0)

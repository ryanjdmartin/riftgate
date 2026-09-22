class_name HudBackdrop
extends Control

## The screen's ground: near-black with faint scanlines, a few dim section rules, a scan
## band that sweeps down the screen now and then so the HUD never sits perfectly still,
## and, when a screen asks for it, bands of ground in the terrain the fight is on. Each
## ground band is its own clipped child, so nothing it draws spills past its edges.

const SCAN_SPEED := 140.0     # pixels per second
const SCAN_PAUSE := 6.0       # seconds between sweeps (Ryan, 22 September: too often was busy)

var rules: Array[float] = []   # y positions of faint horizontal rules
var grounds: Array = []        # [[Rect2, terrain, seed, style], ...]
var scan: bool = true          # the sweeping band
var _t := 0.0
var _bands: Array = []
var _overlay: Control = null


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	for g in grounds:
		var band := GroundBand.new()
		band.rect = g[0]
		band.terrain = int(g[1])
		band.seed_value = int(g[2])
		band.style = g[3] if g.size() > 3 else "ground"
		band.owner_bg = self
		band.position = (g[0] as Rect2).position
		band.size = (g[0] as Rect2).size
		add_child(band)
		_bands.append(band)
	_overlay = Overlay.new()
	_overlay.owner_bg = self
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	for b in _bands:
		b.queue_redraw()
	if _overlay != null:
		_overlay.queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Palette.BG)


## Where the band is right now, in this control's pixels, or far off-screen between sweeps.
func scan_y() -> float:
	if not scan:
		return -1.0e6
	var sweep := (size.y + 120.0) / SCAN_SPEED
	var t := fmod(_t, sweep + SCAN_PAUSE)
	if t > sweep:
		return -1.0e6
	return t * SCAN_SPEED - 60.0


func time() -> float:
	return _t


## One band of ground, clipped to its rect.
class GroundBand extends Control:
	var rect := Rect2()
	var terrain: int = 0
	var seed_value: int = 0
	var style := "ground"
	var owner_bg: HudBackdrop

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip_contents = true

	func _draw() -> void:
		var t := owner_bg.time() if owner_bg != null else 0.0
		TerrainArt.draw_ground(self, Rect2(Vector2.ZERO, size), terrain, seed_value, 44.0, style, int(t * 1.6) % 2, t)


## Scanlines, rules and the scan band, over everything.
class Overlay extends Control:
	var owner_bg: HudBackdrop

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		Hud.scanlines(self, Rect2(Vector2.ZERO, size))
		for y in owner_bg.rules:
			draw_line(Vector2(12.0, y), Vector2(size.x - 12.0, y), Color(Palette.HUD, 0.22), 1.0)
		var y := owner_bg.scan_y()
		if y > -1.0e5:
			for i in range(-2, 3):
				draw_rect(Rect2(0.0, y + i * 3.0, size.x, 1.0), Color(1, 1, 1, 0.07 - 0.015 * absi(i)))

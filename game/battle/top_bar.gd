class_name TopBar
extends Control

## The battle's top bar (Ryan, 9 November: "The fracture meter needs to be a prominent, always
## visible UI component. I would rework the top bar, the three important pieces of information
## that always needs to be visible is the gate/wall integrity, the rift spawn bar and the fracture
## bar"): three gauges side by side, always on screen whatever the map's scroll, where the gate's
## and the rift's bars on the map scrolled away with their ground.
##
##   GATE       the wall's integrity, a true bar with its scale; the loss colour under a third
##   RIFT       Rift Pressure toward the next spawn, a box a turn of the beat, filled as it builds
##   FRACTURES  the Rupture meter: the menace killed toward the last Fracture, a notch at each,
##              the ones earned lit; THE RUPTURE once the seal is broken
##
## The two violet gauges part by structure, boxes against a fill with notches, and by their words,
## never by hue alone (Ryan is colourblind). A gauge that changes flashes (flash): the gate struck,
## the rift sending, a Fracture earned. No turn number and no READY count: the board under the map
## says both. Drawn in screen space; reads the battle as it stands every frame.

var battle: Battle

const GAP := 8.0          # between two gauges
const PAD := 8.0          # a gauge's margin inside its plate
const FONT_PX := 13
const BAR_H := 12.0
const BOX_GAP := 3.0      # between two of the rift's boxes
const FLASH_S := 1.6      # a gauge's flash, seconds

var _flash: Dictionary = {}   # "gate" | "rift" | "fractures" -> seconds since it began
var _t := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	for k in _flash.keys():
		_flash[k] = float(_flash[k]) + delta
		if float(_flash[k]) > FLASH_S:
			_flash.erase(k)
	queue_redraw()


## A gauge flashes: its plate floods bright and a ring breathes out past it, twice, by motion as
## well as light, so a change is seen without reading the number (hot, for the phone).
func flash(which: String) -> void:
	_flash[which] = 0.0
	queue_redraw()


## The three gauges' rects, left to right: the gate, the rift, the Fractures.
func gauge_rects() -> Array:
	var w := (size.x - GAP * 2.0) / 3.0
	return [Rect2(0.0, 0.0, w, size.y), Rect2(w + GAP, 0.0, w, size.y), Rect2((w + GAP) * 2.0, 0.0, w, size.y)]


func _draw() -> void:
	if battle == null:
		return
	var rects := gauge_rects()
	_draw_gate(rects[0])
	_draw_rift(rects[1])
	_draw_fractures(rects[2])


## The gate: its integrity as a fill with its scale, the HUD's light, the loss colour under a third.
func _draw_gate(r: Rect2) -> void:
	var f := battle.field
	var frac := float(f.gate_hp) / maxf(1.0, float(f.gate_hp_max))
	var col := Palette.HUD if frac > 0.34 else Palette.LOSS
	var bar := _plate(r, col, "gate", "GATE", "%d/%d" % [f.gate_hp, f.gate_hp_max])
	draw_rect(bar, Color(col, 0.18))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(frac, 0.0, 1.0), bar.size.y)), col)
	Hud.ticks(self, bar, f.gate_hp, f.gate_hp_max, col)


## The rift: a box a turn of the beat, filled as Rift Pressure builds; when the last fills, it sends.
func _draw_rift(r: Rect2) -> void:
	var f := battle.field
	var n := maxi(1, f.rift_pressure_max)
	var left := maxi(0, f.rift_pressure_max - f.rift_pressure)
	var col := Palette.ENEMY
	var bar := _plate(r, col, "rift", "RIFT", "SPAWN IN %d" % left)
	var bw := (bar.size.x - BOX_GAP * float(n - 1)) / float(n)
	for k in range(n):
		var box := Rect2(bar.position.x + float(k) * (bw + BOX_GAP), bar.position.y, bw, bar.size.y)
		if k < f.rift_pressure:
			draw_rect(box, col)
		else:
			draw_rect(box, Color(col, 0.16))
			draw_rect(box, Color(col, 0.8), false, 1.5)


## The Fractures: the menace killed toward the last threshold as one fill, a notch at each
## Fracture, those earned drawn long and bright and those ahead short and dim; THE RUPTURE once
## the seal is broken, full. A battle with no meter (the harness's with no boss) shows it empty.
func _draw_fractures(r: Rect2) -> void:
	var col := Palette.ENEMY
	var thresholds: Array = battle.thresholds
	if thresholds.is_empty():
		var empty := _plate(r, Color(col, 0.5), "fractures", "FRACTURES", "NONE")
		draw_rect(empty, Color(col, 0.1))
		return
	var last := maxi(1, int(thresholds[thresholds.size() - 1]))
	var sealed := battle.is_sealed()
	var bar := _plate(r, col, "fractures", "FRACTURES" if sealed else "THE RUPTURE", ("%d/%d" % [battle.fractures, thresholds.size()]) if sealed else "SEAL BROKEN")
	var frac := clampf(float(battle.menace_killed) / float(last), 0.0, 1.0) if sealed else 1.0
	draw_rect(bar, Color(col, 0.18))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * frac, bar.size.y)), col)
	for k in range(thresholds.size()):
		var x := bar.position.x + bar.size.x * clampf(float(int(thresholds[k])) / float(last), 0.0, 1.0)
		var earned := k < battle.fractures or not sealed
		var reach := 4.0 if earned else 1.0
		draw_line(Vector2(x, bar.position.y - reach), Vector2(x, bar.end.y + reach), Palette.BG, 4.0)
		draw_line(Vector2(x, bar.position.y - reach), Vector2(x, bar.end.y + reach), Palette.INK if earned else Color(col, 0.9), 2.0)


## A gauge's plate: a dark box edged in its colour, its name at the left and its number at the
## right on the first line, and the bar's rect under them, returned. Flashing, the box floods and a
## ring breathes out past it.
func _plate(r: Rect2, col: Color, key: String, name: String, value: String) -> Rect2:
	var hot := 0.0
	if _flash.has(key):
		var p := float(_flash[key]) / FLASH_S
		hot = (0.5 + 0.5 * cos(p * TAU * 2.0)) * (1.0 - p)   # two beats, fading
		for k in range(2):
			var ph := fmod(p * 2.0 + k * 0.5, 1.0)
			var grow := 2.0 + 10.0 * ph
			Hud.box(self, r.grow(grow), 6.0, Color(0, 0, 0, 0), Color(col, 0.8 * (1.0 - ph) * (1.0 - p)), 2.0)
	Hud.box(self, r, 6.0, Color(Palette.BG, 0.94).lerp(Color(col, 0.45), hot), Color(col, 0.75 + 0.25 * hot), 1.5 + 1.5 * hot)
	var font := Hud.mono()
	var y := r.position.y + PAD + font.get_ascent(FONT_PX) - 2.0
	var ink := Palette.INK.lerp(Color.WHITE, hot)
	draw_string(font, Vector2(r.position.x + PAD, y), name, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX, Color(col, 1.0).lerp(Color.WHITE, hot))
	draw_string(font, Vector2(r.position.x + PAD, y), value, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - PAD * 2.0, FONT_PX, ink)
	return Rect2(r.position.x + PAD, r.end.y - PAD - BAR_H, r.size.x - PAD * 2.0, BAR_H)

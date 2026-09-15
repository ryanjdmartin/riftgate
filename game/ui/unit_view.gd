class_name UnitView
extends Control

## A unit on the skirmish screen: the sprite, its gauges, its intent, and its statuses.
## Gauges hug the drawing (the opaque part of the sprite), not the frame. Mechs carry their
## gauges above the sprite; foes carry one small floating gauge at the top-right. Under every
## sprite runs one row of chips: a foe's intent (fantasy icon plus number) and its statuses;
## a mech's statuses and its warning signs. No names: hold or double-tap for those.
##
## A gauge entry is [value, max, Color] or [value, max, Color, pending]; a pending value
## draws a pulsing overlay over the part of the bar about to change.
##
## Gestures: tap -> `tapped`, double-tap -> `double_tapped`, hold -> `held` / `hold_released`.

signal tapped
signal double_tapped
signal held
signal hold_released

const HOLD_SECONDS := 0.45
const DOUBLE_TAP_SECONDS := 0.35
const STATUS_H := 26.0
const CHIP_H := 20.0
const BAR_H := 8.0
const BAR_STEP := 11.0

var display_name: String = ""     # for the codex and readouts; never drawn here
var is_enemy: bool = false
var massive: bool = false
var bars: Array = []              # [[value, max, Color, (pending)], ...]
var bars_above: bool = false      # true: full-width gauges above the sprite; false: floating
var intent_kind: String = ""      # "attack", "defend", "heal", "buff", "debuff", or ""
var intent_value: int = 0
var intent: String = ""           # quiet text for an empty slot, e.g. "EXPOSED"
var intent_dim: bool = false
var statuses: Array = []          # [[glyph id, chip text, (Color)], ...] under the sprite
var highlight: bool = false       # valid drop target while dragging a die
var dead: bool = false
var sprite: Texture2D = null      # pixel art drawn at an integer scale; null draws a placeholder

var _pressed := false
var _press_at := 0.0
var _holding := false
var _last_tap_at := -10.0
var _t := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(false)


## Centre of the drawing, in global coordinates, for arrows.
func anchor_global() -> Vector2:
	return get_global_transform() * _visible().get_center()


func _bars_height() -> float:
	return (bars.size() * BAR_STEP + 2.0) if bars_above and not bars.is_empty() else 0.0


func _scale() -> float:
	if sprite == null:
		return 1.0
	var top := _bars_height() + 2.0
	var avail := size.y - top - STATUS_H
	var ts := sprite.get_size()
	return maxf(1.0, floorf(minf(size.x / ts.x, avail / ts.y)))


## The whole sprite frame, anchored to the bottom of the sprite area.
func _silhouette() -> Rect2:
	var top := (_bars_height() + 2.0) if sprite != null else size.y * 0.12 + _bars_height()
	var avail := size.y - top - STATUS_H
	if sprite != null:
		var s := _scale()
		var ts := sprite.get_size() * s
		return Rect2(Vector2(floorf((size.x - ts.x) * 0.5), floorf(top + avail - ts.y)), ts)
	var w := size.x * 0.46
	var h := minf(avail, size.y * (0.78 if massive else 0.62))
	return Rect2(Vector2((size.x - w) * 0.5, top + avail - h), Vector2(w, h))


## The opaque part of the drawing on screen: what gauges and chips hug.
func _visible() -> Rect2:
	var sil := _silhouette()
	if sprite == null:
		return sil
	var used := Sprites.used_rect(sprite)
	var s := _scale()
	return Rect2(sil.position + used.position * s, used.size * s)


func _has_pending() -> bool:
	for b in bars:
		if b.size() >= 4 and int(b[3]) != int(b[0]):
			return true
	return false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressed = true
			_holding = false
			_press_at = Time.get_ticks_msec() / 1000.0
			set_process(true)
		else:
			if _holding:
				hold_released.emit()
			elif _pressed:
				var now := Time.get_ticks_msec() / 1000.0
				if now - _last_tap_at <= DOUBLE_TAP_SECONDS:
					_last_tap_at = -10.0
					double_tapped.emit()
				else:
					_last_tap_at = now
					tapped.emit()
			_pressed = false
			_holding = false
			set_process(_has_pending())
		accept_event()


func _process(delta: float) -> void:
	if _pressed and not _holding and Time.get_ticks_msec() / 1000.0 - _press_at >= HOLD_SECONDS:
		_holding = true
		held.emit()
	if _has_pending() and visible and not dead:
		_t += delta
		queue_redraw()
	elif not _pressed:
		set_process(false)


func queue_refresh() -> void:
	if _has_pending():
		set_process(true)
	queue_redraw()


func _draw() -> void:
	var hud := Palette.HUD
	var mono := Hud.mono()
	var sil := _silhouette()
	var vis := _visible()
	if sprite != null:
		draw_texture_rect(sprite, sil, false, Color(0.3, 0.3, 0.3) if dead else Color.WHITE)
	else:
		var edge := Color(Palette.ENEMY_DIM if dead else hud, 0.4)
		Hud.box(self, sil, 10.0, Color(Palette.PANEL_RAISED, 0.9), edge, 1.0)
	if dead:
		draw_line(vis.position, vis.end, Palette.ENEMY_DIM, 2.0)
		draw_line(Vector2(vis.position.x, vis.end.y), Vector2(vis.end.x, vis.position.y), Palette.ENEMY_DIM, 2.0)
	if highlight:
		Hud.brackets(self, vis.grow(6.0), 14.0, Palette.TARGET, 2.0)

	if not bars.is_empty() and not dead:
		if bars_above:
			# Full-width gauges stacked right above the drawing: hull, shield, heat.
			var bx := size.x * 0.1
			var bw := size.x * 0.8
			var y := vis.position.y - 4.0 - bars.size() * BAR_STEP
			for b in bars:
				_gauge(Rect2(bx, y, bw, BAR_H), b)
				y += BAR_STEP
		else:
			# One small gauge floating at the drawing's top-right.
			var y := vis.position.y - 12.0
			var bx := minf(vis.end.x - 30.0, size.x - 54.0)
			for b in bars:
				_gauge(Rect2(bx, y, 52.0, BAR_H), b)
				y -= 10.0
			Hud.tick(self, Vector2(vis.end.x - 4.0, vis.position.y + 2.0), Color(hud, 0.6))

	# Quiet readout for an empty slot.
	if not intent.is_empty() and not dead and sprite == null and intent_kind.is_empty():
		draw_string(mono, Vector2(0, sil.get_center().y + 5.0), "[%s]" % intent, HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, Color(hud, 0.45 if intent_dim else 0.95))

	# The chip row under the sprite: intent first, then statuses, centred.
	if dead:
		return
	var chips: Array = []
	if not intent_kind.is_empty():
		chips.append([Glyphs.intent_for(intent_kind), str(intent_value) if intent_value > 0 else "", Palette.ENEMY if is_enemy else hud])
	for s in statuses:
		chips.append([s[0], str(s[1]), s[2] if s.size() >= 3 else hud])
	if chips.is_empty():
		return
	var widths: Array[float] = []
	var total := 0.0
	for ch in chips:
		var txt: String = ch[1]
		var w := 20.0 + (mono.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 6.0 if not txt.is_empty() else 0.0)
		widths.append(w)
		total += w + 4.0
	total -= 4.0
	var x := floorf((size.x - total) * 0.5)
	var cy := sil.end.y + 4.0 + CHIP_H * 0.5
	for i in range(chips.size()):
		var ch: Array = chips[i]
		var col: Color = ch[2]
		var rect := Rect2(x, cy - CHIP_H * 0.5, widths[i], CHIP_H)
		Hud.box(self, rect, 3.0, Color(Palette.BG, 0.92), col, 1.0)
		Glyphs.draw(self, ch[0], Vector2(x + 10.0, cy), 12, col, 1.6)
		if not ch[1].is_empty():
			draw_string(mono, Vector2(x + 20.0, cy + 4.0), ch[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		x += widths[i] + 4.0


## A gauge with, when a pending value is given, a pulsing overlay on the part about to change:
## red where a bar will fall, the bar's own colour where it will rise.
func _gauge(rect: Rect2, b: Array) -> void:
	var mx := float(maxi(1, int(b[1])))
	var frac: float = clampf(float(b[0]) / mx, 0.0, 1.0)
	var col: Color = b[2]
	Hud.gauge(self, rect, frac, col)
	if b.size() < 4 or int(b[3]) == int(b[0]):
		return
	var pending: float = clampf(float(b[3]) / mx, 0.0, 1.0)
	var lo := minf(frac, pending)
	var hi := maxf(frac, pending)
	var inner := rect.grow(-2.0)
	var pulse := 0.45 + 0.35 * sin(_t * 6.0)
	var overlay := Color(Palette.ENEMY if pending < frac else col, pulse)
	var seg := Rect2(inner.position + Vector2(inner.size.x * lo, 0), Vector2(maxf(2.0, inner.size.x * (hi - lo)), inner.size.y))
	Hud.fill_poly(self, Hud.slant(seg, 2.4), overlay)

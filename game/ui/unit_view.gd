class_name UnitView
extends Control

## A unit on the skirmish screen under the tactical overlay: the sprite (or a placeholder box),
## slanted gauges, a name, a bracketed readout such as [ATK 10] below foes, and status chips on
## the sprite itself. Mechs carry three full-width gauges above the sprite; foes carry one small
## gauge floating at the sprite's top-right. Tap and hold gestures only.

signal tapped
signal double_tapped
signal held
signal hold_released

const HOLD_SECONDS := 0.45
const DOUBLE_TAP_SECONDS := 0.35

var display_name: String = ""
var is_enemy: bool = false
var massive: bool = false
var bars: Array = []            # [[value, max, Color], ...]
var bars_above: bool = false    # true: full-width gauges above the sprite; false: floating
var intent: String = ""         # readout text such as "ATK 10", drawn as [ATK 10]
var intent_dim: bool = false    # quiet readout (exposed slot)
var statuses: Array = []        # [[glyph id, text or ""], ...] drawn on the sprite
var highlight: bool = false     # valid drop target while dragging a die
var dead: bool = false
var sprite: Texture2D = null    # pixel art drawn at an integer scale; null draws a placeholder

var _pressed := false
var _press_at := 0.0
var _holding := false
var _last_tap_at := -10.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(false)


## Centre of the sprite, in global coordinates, for arrows.
func anchor_global() -> Vector2:
	return get_global_transform() * _silhouette().get_center()


func _bars_height() -> float:
	return (6.0 + bars.size() * 11.0) if bars_above and not bars.is_empty() else 0.0


func _silhouette() -> Rect2:
	var top := size.y * 0.12 + _bars_height()
	var avail := size.y - top - 24.0
	if sprite != null:
		# Largest integer scale that fits between the gauges and the name.
		top = _bars_height() + 4.0
		avail = size.y - top - 24.0
		var ts := sprite.get_size()
		var scale := floorf(minf(size.x / ts.x, avail / ts.y))
		scale = maxf(1.0, scale)
		var w := ts.x * scale
		var h := ts.y * scale
		return Rect2(Vector2(floorf((size.x - w) * 0.5), floorf(top + avail - h)), Vector2(w, h))
	var w := size.x * 0.46
	var h := minf(avail, size.y * (0.78 if massive else 0.62))
	return Rect2(Vector2((size.x - w) * 0.5, top), Vector2(w, h))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressed = true
			_holding = false
			_press_at = Time.get_ticks_msec() / 1000.0
			set_process(true)
		else:
			set_process(false)
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
		accept_event()


func _process(_delta: float) -> void:
	if _pressed and not _holding and Time.get_ticks_msec() / 1000.0 - _press_at >= HOLD_SECONDS:
		_holding = true
		set_process(false)
		held.emit()


func _draw() -> void:
	var hud := Palette.HUD
	var mono := Hud.mono()
	var disp := Hud.display()
	var sil := _silhouette()
	if sprite != null:
		draw_texture_rect(sprite, sil, false, Color(0.3, 0.3, 0.3) if dead else Color.WHITE)
	else:
		var edge := Color(Palette.ENEMY_DIM if dead else hud, 0.4)
		Hud.box(self, sil, 10.0, Color(Palette.PANEL_RAISED, 0.9), edge, 1.0)
	if dead:
		draw_line(sil.position, sil.end, Palette.ENEMY_DIM, 2.0)
		draw_line(Vector2(sil.position.x, sil.end.y), Vector2(sil.end.x, sil.position.y), Palette.ENEMY_DIM, 2.0)
	if highlight:
		Hud.brackets(self, sil.grow(5.0), 14.0, Palette.TARGET, 2.0)
	var name_y := sil.end.y + 17.0
	draw_string(disp, Vector2(0, name_y), display_name, HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, Color(hud, 0.85 if not dead else 0.4))
	if not bars.is_empty() and not dead:
		if bars_above:
			# Full-width gauges stacked above the sprite: hull, shield, heat.
			var bx := size.x * 0.1
			var bw := size.x * 0.8
			var y := 3.0
			for b in bars:
				var frac: float = clampf(float(b[0]) / float(maxi(1, b[1])), 0.0, 1.0)
				Hud.gauge(self, Rect2(bx, y, bw, 8.0), frac, b[2])
				y += 11.0
		else:
			# One small gauge floating at the sprite's top-right.
			var y := sil.position.y - 12.0
			var bx := sil.end.x - 30.0
			for b in bars:
				var frac: float = clampf(float(b[0]) / float(maxi(1, b[1])), 0.0, 1.0)
				Hud.gauge(self, Rect2(bx, y, 52.0, 8.0), frac, b[2])
				y -= 10.0
			Hud.tick(self, Vector2(sil.end.x - 4.0, sil.position.y + 2.0), Color(hud, 0.6))
	# Status chips on the sprite, bottom-left, stacked upward.
	if not dead:
		var sy := sil.end.y - 14.0
		for s in statuses:
			var glyph: String = s[0]
			var txt: String = str(s[1])
			var chip_w := 20.0 + (mono.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 6.0 if not txt.is_empty() else 0.0)
			var chip_rect := Rect2(sil.position.x + 3.0, sy - 9.0, chip_w, 18.0)
			Hud.box(self, chip_rect, 3.0, Color(Palette.BG, 0.9), hud, 1.0)
			Glyphs.draw(self, glyph, Vector2(sil.position.x + 13.0, sy), 11, hud, 1.6)
			if not txt.is_empty():
				draw_string(mono, Vector2(sil.position.x + 22.0, sy + 4.0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, hud)
			sy -= 20.0
	# Readout below the name: [ATK 10], [SUPPRESSED], [EXPOSED].
	if not intent.is_empty() and not dead:
		var col := Color(hud, 0.45 if intent_dim else 0.95)
		draw_string(mono, Vector2(0, name_y + 17.0), "[%s]" % intent, HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, col)

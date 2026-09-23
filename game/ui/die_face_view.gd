class_name DieFaceView
extends Control

## A die drawn as an object under the tactical overlay. The face is a chamfered square that
## bobs gently; its keywords sit as small annotation chips hugging its right edge, one per
## keyword, bright and flickering now and then. On the face, as Ryan sketched it: the primary
## glyph large at the top centre, the number or range beneath it, heat bottom-left, crit
## bottom-right, the lock top-right. A locked die gets bracket corners and a LOCKED readout.
## A unique effect adds a star chip.
##
## Gestures:
##   tap   -> `tapped`         lock or unlock
##   hold  -> `held` / `hold_released`   show details while the finger stays down
##   drag  -> `drag_started` / `drag_moved(pos)` / `drag_ended(pos)`   spend the face on a target

signal tapped
signal double_tapped
signal held
signal hold_released
signal drag_started
signal drag_moved(global_pos: Vector2)
signal drag_ended(global_pos: Vector2)

const HOLD_SECONDS := 0.45
const DRAG_THRESHOLD := 14.0
const DOUBLE_TAP_SECONDS := 0.35

const FACE := 120.0        # the square face
const RAIL := 18.0         # how far the chips hang past the right edge
const CHIP := Vector2(26, 24)
const TAG_STEP := 28.0
const BOB_PX := 3.0
const CUT := 16.0
const FLICKER_PERIOD := 4.5   # seconds between dips, per chip

var face: Face = null
var locked: bool = false
var spent: bool = false
var dead: bool = false
var can_tap: bool = true     # tap locks
var can_drag: bool = true    # drag spends
var animate: bool = true

var _pressed := false
var _press_pos := Vector2.ZERO
var _press_at := 0.0
var _dragging := false
var _holding := false
var _last_tap_at := -10.0
var _t := 0.0
var _phase := 0.0


func _init() -> void:
	custom_minimum_size = view_size()
	mouse_filter = Control.MOUSE_FILTER_STOP
	_phase = randf() * FLICKER_PERIOD
	set_process(true)


static func view_size() -> Vector2:
	return Vector2(FACE + RAIL, FACE)


func set_face(f: Face) -> void:
	face = f
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressed = true
			_dragging = false
			_holding = false
			_press_pos = event.global_position
			_press_at = Time.get_ticks_msec() / 1000.0
		else:
			if _dragging:
				drag_ended.emit(event.global_position)
			elif _holding:
				hold_released.emit()
			elif _pressed:
				var now := Time.get_ticks_msec() / 1000.0
				if now - _last_tap_at <= DOUBLE_TAP_SECONDS:
					_last_tap_at = -10.0
					double_tapped.emit()
				else:
					_last_tap_at = now
					if can_tap:
						tapped.emit()
			_pressed = false
			_dragging = false
			_holding = false
		accept_event()
	elif event is InputEventMouseMotion and _pressed and not _holding:
		if not _dragging and can_drag and event.global_position.distance_to(_press_pos) > DRAG_THRESHOLD:
			_dragging = true
			drag_started.emit()
		if _dragging:
			drag_moved.emit(event.global_position)
		accept_event()


var _recalc: float = -1.0        # seconds since the display began recomputing this face; negative when idle
var _recalc_for := 0.7           # how long the recomputation shows


## The display recomputes this face for a moment (Ryan, 23 September: the feed being read):
## static runs across it and the frame flashes once. Nothing about the face changes and
## the number never does.
func recalc(seconds: float = 0.7) -> void:
	_recalc = 0.0
	_recalc_for = seconds
	queue_redraw()


func _process(delta: float) -> void:
	if _pressed and not _dragging and not _holding:
		if Time.get_ticks_msec() / 1000.0 - _press_at >= HOLD_SECONDS:
			_holding = true
			held.emit()
	if _recalc >= 0.0:
		_recalc += delta
		if _recalc > _recalc_for:
			_recalc = -1.0
		queue_redraw()
	if animate and visible and not dead:
		_t += delta
		queue_redraw()


## Chip i is steady, with a brief dip every few seconds.
func _flicker(i: int) -> float:
	var ph := fmod(_t + i * 1.37 + _phase, FLICKER_PERIOD)
	if ph < 0.06:
		return 0.25
	if ph < 0.13:
		return 0.7
	return 1.0


func _draw() -> void:
	var bob := sin(_t * 1.6 + _phase) * BOB_PX if animate else 0.0
	var rect := Rect2(Vector2(0, bob), Vector2(FACE, FACE))
	var hud := Palette.HUD
	var alpha := 0.35 if spent else 1.0
	var border := Color(hud, alpha)
	var fill := Palette.PANEL
	if dead:
		border = Palette.ENEMY_DIM
		fill = Palette.PANEL
	# A soft shadow under the object, so the bob reads as height.
	Hud.fill_poly(self, Hud.cut(Rect2(Vector2(4, 8 + bob * 0.4), Vector2(FACE, FACE)), CUT), Color(0, 0, 0, 0.4))
	Hud.box(self, rect, CUT, fill, border, 3.0 if (locked and not spent) else 1.5)
	if locked and not spent and not dead:
		Hud.brackets(self, rect.grow(6.0), 14.0, hud, 1.5)
		draw_string(Hud.mono(), Vector2(0, FACE + 12.0), "LOCKED", HORIZONTAL_ALIGNMENT_CENTER, FACE, 10, hud)
	if face == null or dead:
		if dead:
			Glyphs.draw(self, "blank", Vector2(FACE * 0.5, FACE * 0.5 + bob), 44, Palette.ENEMY_DIM, 4.0)
		return
	var ink := Color(hud, alpha)
	var mono := Hud.mono()
	Glyphs.draw(self, Glyphs.primary_for(face), Vector2(FACE * 0.5, 34.0 + bob), 34, ink, 2.6)
	var num := face.number_text()
	var num_size := 28 if face.is_ranged() else 38
	if _recalc >= 0.0:
		# Static across the face while the display recomputes it: the number stays what it
		# is and stays readable (Ryan, 23 September: a digit scramble here was wrong), its
		# ink dipping a little under the noise, the frame flashing once.
		var rt := _recalc / _recalc_for
		var tick := int(_recalc * 20.0)
		ink.a *= 0.7 + 0.3 * Hud.noise(tick * 0.7 + 0.3)
		Hud.stroke_poly(self, Hud.cut(rect.grow(-3.0), CUT), Color(Palette.INK, 0.5 * (1.0 - rt)), 1.0)
		for j in range(12):
			var yy := rect.position.y + 6.0 + Hud.noise(tick * 0.9 + j * 0.61) * (FACE - 12.0)
			var x0 := rect.position.x + 6.0 + Hud.noise(tick * 1.7 + j * 0.23) * (FACE - 12.0) * 0.6
			var w := (FACE - 12.0) * (0.15 + 0.35 * Hud.noise(tick * 0.4 + j * 0.83))
			draw_rect(Rect2(x0, yy, w, 1.0), Color(hud, (0.18 + 0.3 * Hud.noise(tick + j * 0.5)) * alpha))
	draw_string(mono, Vector2(0, 92.0 + bob), num, HORIZONTAL_ALIGNMENT_CENTER, FACE, num_size, ink)
	if face.strikes > 1:
		# Blows per use, small, to the right of the number: "10 ×3" reads as a burst.
		var w := mono.get_string_size(num, HORIZONTAL_ALIGNMENT_CENTER, -1, num_size).x
		draw_string(mono, Vector2(FACE * 0.5 + w * 0.5 + 2.0, 92.0 + bob), "×%d" % face.strikes, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ink)
	if face.heat > 0:
		var hc := Color(Palette.HEAT, alpha)
		draw_string(mono, Vector2(10.0, FACE - 9.0 + bob), "+%d HEAT" % face.heat, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, hc)
	if face.crit > 0:
		var cc := Color(Palette.SELECT, alpha)
		draw_string(mono, Vector2(0, FACE - 9.0 + bob), "✦%d" % face.crit, HORIZONTAL_ALIGNMENT_RIGHT, FACE - 10.0, 12, cc)
	if locked and not spent:
		Glyphs.draw(self, "lock", Vector2(FACE - 20.0, 20.0 + bob), 14, hud, 2.0)
	# Annotation chips hugging the right edge, one per keyword, star for a unique effect.
	var tags: Array[String] = []
	for k in face.keywords:
		tags.append(Face.KEYWORD_NAMES[k])
	if not face.label.is_empty():
		tags.append("star")
	for i in range(tags.size()):
		var col := Glyphs.colour_for(tags[i])
		col.a = (_flicker(i) if animate else 1.0) * (0.45 if spent else 1.0)
		var chip_rect := Rect2(Vector2(FACE - CHIP.x + RAIL - 2.0, 8.0 + i * TAG_STEP + bob * 0.5), CHIP)
		Hud.box(self, chip_rect, 4.0, Color(Palette.BG, 0.94), col, 1.0)
		Glyphs.draw(self, tags[i], chip_rect.get_center(), 13, col, 1.8)

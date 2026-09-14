class_name DieFaceView
extends Control

## Draws one die face in the four fixed positions and turns raw input into three gestures:
##   tap   -> `tapped`         lock or unlock
##   hold  -> `held` / `hold_released`   show details while the finger stays down
##   drag  -> `drag_started` / `drag_moved(pos)` / `drag_ended(pos)`   spend the face on a target

signal tapped
signal held
signal hold_released
signal drag_started
signal drag_moved(global_pos: Vector2)
signal drag_ended(global_pos: Vector2)

const HOLD_SECONDS := 0.45
const DRAG_THRESHOLD := 14.0

var face: Face = null
var locked: bool = false
var spent: bool = false
var dead: bool = false
var usable: bool = true      # false blocks tap and drag; hold still works

var _pressed := false
var _press_pos := Vector2.ZERO
var _press_at := 0.0
var _dragging := false
var _holding := false


func _init() -> void:
	custom_minimum_size = Vector2(120, 120)
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(false)


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
			set_process(true)
		else:
			set_process(false)
			if _dragging:
				drag_ended.emit(event.global_position)
			elif _holding:
				hold_released.emit()
			elif _pressed and usable:
				tapped.emit()
			_pressed = false
			_dragging = false
			_holding = false
		accept_event()
	elif event is InputEventMouseMotion and _pressed and not _holding:
		if not _dragging and usable and event.global_position.distance_to(_press_pos) > DRAG_THRESHOLD:
			_dragging = true
			set_process(false)
			drag_started.emit()
		if _dragging:
			drag_moved.emit(event.global_position)
		accept_event()


func _process(_delta: float) -> void:
	if _pressed and not _dragging and not _holding:
		if Time.get_ticks_msec() / 1000.0 - _press_at >= HOLD_SECONDS:
			_holding = true
			set_process(false)
			held.emit()


func _draw() -> void:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(16)
	sb.set_border_width_all(3)
	sb.bg_color = Palette.PANEL_RAISED
	sb.border_color = Palette.RULE
	if dead:
		sb.bg_color = Palette.PANEL
		sb.border_color = Palette.ENEMY_DIM
	elif spent:
		sb.bg_color = Palette.PANEL
		sb.border_color = Palette.RULE
	elif locked:
		sb.border_color = Palette.SELECT
		sb.set_border_width_all(4)
	draw_style_box(sb, Rect2(Vector2.ZERO, size))
	if face == null or dead:
		return
	var ink := Palette.MUTED if spent else Palette.INK
	var font := ThemeDB.fallback_font
	Glyphs.draw(self, Glyphs.primary_for(face), Vector2(26, 26), 26, ink, 2.5)
	var num := "" if face.kind == Face.Kind.BLANK else str(face.power)
	draw_string(font, Vector2(0, size.y * 0.5 + 20), num, HORIZONTAL_ALIGNMENT_CENTER, size.x, 54, ink)
	var x := size.x - 22.0
	for k in face.keywords:
		Glyphs.draw(self, Face.KEYWORD_NAMES[k], Vector2(x, 22), 16, Palette.ACCENT if not spent else ink, 2.0)
		x -= 22.0
	if face.heat > 0:
		var hc := Palette.HEAT if not spent else ink
		Glyphs.draw(self, "heat", Vector2(18, size.y - 20), 14, hc, 2.0)
		draw_string(font, Vector2(30, size.y - 13), str(face.heat), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, hc)
	if not face.label.is_empty():
		Glyphs.draw(self, "star", Vector2(size.x - 20, size.y - 20), 16, Palette.RIFT, 2.0)
	if locked and not spent:
		Glyphs.draw(self, "lock", Vector2(size.x - 20, size.y - 18), 12, Palette.SELECT, 2.0)

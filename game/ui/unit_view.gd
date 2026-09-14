class_name UnitView
extends Control

## A unit on the skirmish screen with minimal chrome: a sprite placeholder, a small floating
## bar box at its top-right, an intent chip below, and a name. Tap and hold gestures only.

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
var intent: String = ""         # short chip text such as "ATK 2"
var intent_glyph: String = ""   # optional glyph id drawn in the chip
var highlight: bool = false     # valid drop target while dragging a die
var dead: bool = false

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


func _silhouette() -> Rect2:
	var w := size.x * 0.46
	var h := size.y * (0.78 if massive else 0.62)
	return Rect2(Vector2((size.x - w) * 0.5, size.y * 0.12), Vector2(w, h))


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
	var font := ThemeDB.fallback_font
	var sil := _silhouette()
	var body := Color("2a3a2a") if is_enemy else Color("233040")
	var edge := Color("4a6a4a") if is_enemy else Color("3d5470")
	if dead:
		body = Palette.PANEL
		edge = Palette.ENEMY_DIM
	var sb := StyleBoxFlat.new()
	sb.bg_color = body
	sb.border_color = Palette.TARGET if highlight else edge
	sb.set_border_width_all(3 if highlight else 1)
	sb.set_corner_radius_all(6)
	draw_style_box(sb, sil)
	if dead:
		draw_line(sil.position, sil.end, Palette.ENEMY_DIM, 2.0)
		draw_line(Vector2(sil.position.x, sil.end.y), Vector2(sil.end.x, sil.position.y), Palette.ENEMY_DIM, 2.0)
	var name_y := sil.end.y + 16.0
	draw_string(font, Vector2(0, name_y), display_name, HORIZONTAL_ALIGNMENT_CENTER, size.x, 14, Palette.MUTED)
	# Floating bar box, top-right of the sprite.
	if not bars.is_empty() and not dead:
		var bw := 44.0
		var bh := 4.0 + bars.size() * 6.0
		var bx := sil.end.x - 10.0
		var by := sil.position.y - 8.0
		draw_rect(Rect2(bx, by, bw, bh), Palette.BG)
		draw_rect(Rect2(bx, by, bw, bh), Palette.RULE, false, 1.0)
		var y := by + 2.0
		for b in bars:
			var frac: float = clampf(float(b[0]) / float(maxi(1, b[1])), 0.0, 1.0)
			draw_rect(Rect2(bx + 2.0, y, bw - 4.0, 4.0), Palette.PANEL_RAISED)
			if frac > 0.0:
				draw_rect(Rect2(bx + 2.0, y, (bw - 4.0) * frac, 4.0), b[2])
			y += 6.0
		draw_line(Vector2(sil.end.x - 6.0, sil.position.y + 4.0), Vector2(bx, by + bh), Palette.RULE, 1.0)
	# Intent chip below the sprite.
	if not intent.is_empty() and not dead:
		var tw := font.get_string_size(intent, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		var cw := tw + 14.0 + (16.0 if not intent_glyph.is_empty() else 0.0)
		var cx := (size.x - cw) * 0.5
		var cy := name_y + 6.0
		var chip := StyleBoxFlat.new()
		chip.bg_color = Palette.BG
		chip.border_color = Palette.ACCENT
		chip.set_border_width_all(1)
		chip.set_corner_radius_all(9)
		draw_style_box(chip, Rect2(cx, cy, cw, 18))
		var tx := cx + 7.0
		if not intent_glyph.is_empty():
			Glyphs.draw(self, intent_glyph, Vector2(cx + 12.0, cy + 9.0), 10, Palette.ACCENT, 1.5)
			tx += 16.0
		draw_string(font, Vector2(tx, cy + 13.0), intent, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.ACCENT)

class_name HudButton
extends BaseButton

## A button in the overlay style: a slanted outline in the HUD colour with display-face text,
## or filled (primary action) with dark text. `glyph` draws a Glyphs id instead of, or before,
## the text; `badge` is a small mono readout in the corner (the reroll count). `ghost` is the
## quiet variant for actions the player rarely wants (withdraw). Disabled draws at a third.

var text: String = ""
var glyph: String = ""
var badge: String = ""
var filled: bool = false
var ghost: bool = false
var font_size: int = 20
var slant_px: float = 10.0
var mono: bool = false                      # mono face for readout tags
var color_override: Color = Color(0, 0, 0, 0)   # zero alpha: use the HUD colour


func _init(label: String = "", on_pressed: Callable = Callable()) -> void:
	text = label
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	if on_pressed.is_valid():
		pressed.connect(on_pressed)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	toggled.connect(func(_on: bool) -> void: queue_redraw())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)


func set_enabled(on: bool) -> void:
	disabled = not on
	queue_redraw()


func _draw() -> void:
	var base := color_override if color_override.a > 0.0 else Palette.HUD
	var col := base
	var alpha := 0.32 if disabled else (0.55 if ghost else 1.0)
	col.a = alpha
	var rect := Rect2(Vector2.ZERO, size)
	var pts := Hud.slant(rect, slant_px)
	var active := button_pressed or is_pressed()
	var ink := col
	if filled:
		Hud.fill_poly(self, pts, Color(base, alpha * (0.75 if active else 1.0)))
		ink = Color(Palette.BG, 1.0)
	else:
		if active:
			Hud.fill_poly(self, pts, Color(base, 0.22 * alpha))
		elif is_hovered() and not disabled:
			Hud.fill_poly(self, pts, Color(base, 0.08))
		Hud.stroke_poly(self, pts, col, 1.5 if not ghost else 1.0)
	var font := Hud.mono() if mono else Hud.display_bold()
	var cx := size.x * 0.5
	if not glyph.is_empty():
		var gs := minf(size.x, size.y) * 0.42
		var gc := Vector2(cx, size.y * 0.5) if text.is_empty() else Vector2(size.y * 0.5, size.y * 0.5)
		Glyphs.draw(self, glyph, gc, gs, ink, 2.2)
		if text.is_empty() and not badge.is_empty():
			draw_string(Hud.mono(), Vector2(0, size.y - 8.0), badge, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 10.0, 15, ink)
			return
	if not text.is_empty():
		var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var tx := cx - tw * 0.5 + (size.y * 0.35 if not glyph.is_empty() else 0.0)
		var ty := size.y * 0.5 + font.get_ascent(font_size) * 0.5 - font.get_descent(font_size) * 0.5
		draw_string(font, Vector2(tx, ty), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink)
	if not badge.is_empty():
		draw_string(Hud.mono(), Vector2(0, size.y - 7.0), badge, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 12.0, 13, ink)

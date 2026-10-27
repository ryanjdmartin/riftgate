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
var badge_size: int = 13
var center_text: bool = false               # centre the text over the whole button even with a glyph
var slant_px: float = 10.0
var mono: bool = false                      # mono face for readout tags
var color_override: Color = Color(0, 0, 0, 0)   # zero alpha: use the HUD colour
var sound: String = "ui_tap"                # heard on press; "" for a button whose action has its own sound
var hit_pad: Vector2 = Vector2.ZERO         # how far past its drawing the button answers a touch, each side (MENU on a phone: the whole bar)
## The button is the next thing to press (Ryan, 25 October: END TURN pulses when nothing is
## left to do): rings breathe out past its edge and its face brightens, by motion as well as
## light. Set with set_pulse.
var pulse: bool = false
var _pulse_t := 0.0
const PULSE_RATE := 1.1   # rings a second
## RIFTGATE_PULSE_DEBUG=1: every button asked whether to pulse pulses, to judge it running.
static var PULSE_DEBUG := OS.get_environment("RIFTGATE_PULSE_DEBUG") == "1"


## A touch a little off the drawing still lands (Ryan, 25 September: MENU on the phone was
## hard to press); the drawing itself stays its size.
func _has_point(point: Vector2) -> bool:
	return Rect2(-hit_pad, size + hit_pad * 2.0).has_point(point)


func _init(label: String = "", on_pressed: Callable = Callable()) -> void:
	text = label
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	if on_pressed.is_valid():
		pressed.connect(on_pressed)
	button_down.connect(func() -> void:
		if not sound.is_empty():
			Sound.play(sound))
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	toggled.connect(func(_on: bool) -> void: queue_redraw())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)


func set_enabled(on: bool) -> void:
	disabled = not on
	queue_redraw()


func _ready() -> void:
	set_process(pulse)   # a script with _process processes from the start; only a pulse needs it


func set_pulse(on: bool) -> void:
	on = on or PULSE_DEBUG
	if pulse == on:
		return
	pulse = on
	_pulse_t = 0.0
	set_process(on)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_t += delta
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
	var pulsing := pulse and not disabled
	if pulsing:
		# Two rings breathing out past the edge, half a beat apart, fading as they go; hot, since
		# every mark judged on the phone has come back wanting more.
		for k in range(2):
			var ph := fmod(_pulse_t * PULSE_RATE + k * 0.5, 1.0)
			var grow := 3.0 + 18.0 * ph
			Hud.stroke_poly(self, Hud.slant(rect.grow(grow), slant_px + grow * 0.4), Color(base, 0.9 * (1.0 - ph)), 3.0 - 1.5 * ph)
	if filled:
		var face := Color(base, alpha * (0.75 if active else 1.0))
		if pulsing:
			face = face.lerp(Color.WHITE, 0.3 * (0.5 + 0.5 * sin(_pulse_t * TAU * PULSE_RATE)))
		Hud.fill_poly(self, pts, face)
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
		var tx := cx - tw * 0.5 + (size.y * 0.35 if (not glyph.is_empty() and not center_text) else 0.0)
		var ty := size.y * 0.5 + font.get_ascent(font_size) * 0.5 - font.get_descent(font_size) * 0.5
		draw_string(font, Vector2(tx, ty), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink)
	if not badge.is_empty():
		var bfont := Hud.mono()
		var by := size.y * 0.5 + bfont.get_ascent(badge_size) * 0.5 - bfont.get_descent(badge_size) * 0.5
		draw_string(bfont, Vector2(0, by), badge, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 16.0, badge_size, ink)

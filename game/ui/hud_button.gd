class_name HudButton
extends BaseButton

## A button in the overlay style: a slanted outline in the HUD colour with display-face text,
## or filled (primary action) with dark text. `glyph` draws a Glyphs id instead of, or before,
## the text; `badge` is a small mono readout in the corner (the reroll count). `ghost` is the
## quiet variant for actions the player rarely wants (CLEAR, the quick campaign's LEAVE and
## CANCEL). Disabled draws at a third. `state_marked` parts on from off by structure as well as
## light (the UNDOs; Ryan, 9 November: "map undo needs to be more obvious when it's active versus
## disabled"): on, a heavy solid edge over a faint fill at full strength; off, a dashed edge, faint.
## `socket` makes it a drop's target, which its owner sets to pass every touch through: dashed
## while it rests, at full strength while it is live, solid while it pulses.

var text: String = ""
var glyph: String = ""
var badge: String = ""
var filled: bool = false
var ghost: bool = false
var state_marked: bool = false   # on and off told apart by structure: a heavy solid edge, or a faint dashed one
var socket: bool = false         # with state_marked, a drop's target and no button (the reboot's): live and at rest it keeps the dashed edge, at full strength, and wears the solid one only while it pulses, the thing it takes in hand
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
## The die in hand would change what this button counts (a reroll the spend grants: Ryan, 15
## November, "highlighting the reroll button as part of the preview, if one will be granted"):
## it pulses as the next thing to press does, whether or not it may be pressed now, since a team
## with no reroll left is the one that most wants to see it. Set with set_granting.
var granting: bool = false
## What this button counts is being taken (a foe's drain on the team's rerolls: Ryan, 15
## November, "There should be an effect on the reroll button when this happens"): a note under
## its badge says what and when, and while the loss is only announced rings close in on the
## edge, the grant's own rings run backwards, so the two are told apart by motion as well as
## by the note's sign and colour. Set with set_draining; strike() flashes it as a loss lands.
var note: String = ""
var note_size: int = 13
var draining: bool = false
var _strike_t := -1.0   # seconds since a loss landed, -1 with none to show
const STRIKE_SPAN := 0.45
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
	set_process(_animates())   # a script with _process processes from the start; only a pulse needs it


func _animates() -> bool:
	return pulse or granting or draining or _strike_t >= 0.0


func set_pulse(on: bool) -> void:
	on = on or PULSE_DEBUG
	if pulse == on:
		return
	pulse = on
	_pulse_t = 0.0
	set_process(_animates())
	queue_redraw()


func set_granting(on: bool) -> void:
	if granting == on:
		return
	granting = on
	_pulse_t = 0.0
	set_process(_animates())
	queue_redraw()


## The note under the badge, and whether the loss it names is still only announced (rings
## closing in while it is: it may yet be stopped).
func set_draining(text_: String, announced: bool) -> void:
	if note == text_ and draining == announced:
		return
	note = text_
	if draining != announced:
		_pulse_t = 0.0
	draining = announced
	set_process(_animates())
	queue_redraw()


## A loss lands: the button flashes once in the taker's colour.
func strike() -> void:
	_strike_t = 0.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_t += delta
	if _strike_t >= 0.0:
		_strike_t += delta
		if _strike_t > STRIKE_SPAN:
			_strike_t = -1.0
			set_process(_animates())
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
	var pulsing := (pulse and not disabled) or granting
	if pulsing:
		# Two rings breathing out past the edge, half a beat apart, fading as they go; hot, since
		# every mark judged on the phone has come back wanting more.
		for k in range(2):
			var ph := fmod(_pulse_t * PULSE_RATE + k * 0.5, 1.0)
			var grow := 3.0 + 18.0 * ph
			Hud.stroke_poly(self, Hud.slant(rect.grow(grow), slant_px + grow * 0.4), Color(base, 0.9 * (1.0 - ph)), 3.0 - 1.5 * ph)
	if draining:
		# The grant's rings run backwards: two close in on the edge from outside, growing
		# stronger as they arrive, in the taker's colour. Hot, like every mark on a phone.
		for k in range(2):
			var ph := fmod(_pulse_t * PULSE_RATE + k * 0.5, 1.0)
			var grow := 3.0 + 18.0 * (1.0 - ph)
			Hud.stroke_poly(self, Hud.slant(rect.grow(grow), slant_px + grow * 0.4), Color(Palette.ENEMY, 0.25 + 0.7 * ph), 1.5 + 1.5 * ph)
	if _strike_t >= 0.0:
		# A loss landing: the face floods in the taker's colour and drains away.
		Hud.fill_poly(self, pts, Color(Palette.ENEMY, 0.85 * (1.0 - _strike_t / STRIKE_SPAN)))
	if state_marked and not filled:
		if disabled:
			# Off: nothing to take back. A dashed edge, faint, and faint text: absent, by its shape.
			col.a = 0.3
			ink = col
			_dashed_poly(pts, col, 1.5)
		elif socket and not pulsing:
			# A drop's target at rest: live, so at full strength, and dashed, so nothing to press.
			col.a = 1.0
			ink = col
			_dashed_poly(pts, col, 2.0)
		else:
			# On: a heavy solid edge over a faint fill, at full strength, so it reads as live.
			col.a = 1.0
			ink = col
			Hud.fill_poly(self, pts, Color(base, 0.3 if active else 0.14))
			Hud.stroke_poly(self, pts, col, 3.0)
	elif filled:
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
		var lift := 0.0 if note.is_empty() else 8.0   # the badge rides up to leave the note its line
		var by := size.y * 0.5 + bfont.get_ascent(badge_size) * 0.5 - bfont.get_descent(badge_size) * 0.5 - lift
		draw_string(bfont, Vector2(0, by), badge, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 16.0, badge_size, ink)
	if not note.is_empty():
		# What is being taken, in the taker's colour at full strength whatever the button's
		# own state: a team with no reroll left still reads why.
		draw_string(Hud.mono(), Vector2(0, size.y - 6.0), note, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 16.0, note_size, Palette.ENEMY)


## A closed outline in dashes, each dash on the button's own edge (a state-marked button's off).
func _dashed_poly(pts: PackedVector2Array, col: Color, width: float) -> void:
	var dash := 8.0
	var gap := 6.0
	for i in range(pts.size()):
		var a := pts[i]
		var b := pts[(i + 1) % pts.size()]
		var length := a.distance_to(b)
		var dir := (b - a) / maxf(1.0, length)
		var t := 0.0
		while t < length:
			draw_line(a + dir * t, a + dir * minf(t + dash, length), col, width)
			t += dash + gap

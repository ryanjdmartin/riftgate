class_name BossReveal
extends Control

## The boss's contact on the field (Ryan, 25 September): before the handover the display
## makes a show of who it has found. Over the dimmed map a black band with violet rules slides in;
## the boss's picture flies up out of its hex and grows to fill the band's left, three violet
## afterimages behind it; brackets collapse onto it as the feed acquires it; its family
## types in, its name resolves out of a scramble, and the order to engage types under, saying how
## many machines are committed (the boss is fought like any pack, by the machines ordered on); the
## picture tears every third of a second while it is held. Then it fades and `finished`
## fires, and the owner runs the ordinary handover into the skirmish. A tap ends it early.
## The boss theme starts under it, from its top, so the intro plays over the reveal and the
## dive and the fight arrives in the groove (Sound.LOOP_FROM). Drawn in this control's
## clock, so RIFTGATE_REVEAL_T=<seconds> pins a frame for a screenshot.

signal finished

const LENGTH := 4.4        # seconds to `finished`
const FADE := 0.4          # the fade out at its end
const BAND_Y := 150.0
const BAND_H := 380.0
const SPRITE_H := 230.0    # the picture's height once landed
const SPRITE_X := 190.0    # and its centre
const TEXT_X := 356.0
const TEXT_W := 340.0
const TEAR_PERIOD := 0.34
const TEAR_SECONDS := 0.12
const GLYPHS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#/<>"

var boss_name := ""
var family := ""
var tex: Texture2D = null
var from := Vector2.ZERO           # the picture on the map, in this control's pixels
var from_size := Vector2(32, 32)
var order_text := "ENGAGING"       # the order typed under the name: who is committed (the screen sets it)

var _t := 0.0
var _pinned := false
var _done := false
var _family_label: Label
var _name_label: Label
var _sub_label: Label


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # the boss's picture is pixel art
	_family_label = Hud.label("", 15, Color(Palette.HUD, 0.85), Hud.mono())
	_family_label.position = Vector2(TEXT_X, BAND_Y + 64.0)
	_family_label.size = Vector2(TEXT_W, 22)
	add_child(_family_label)
	_name_label = Hud.label("", 52, Palette.ENEMY, Hud.display_bold())
	_name_label.position = Vector2(TEXT_X, BAND_Y + 92.0)
	_name_label.size = Vector2(TEXT_W, 150)
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_name_label)
	_sub_label = Hud.label("", 15, Palette.INK, Hud.mono())
	_sub_label.position = Vector2(TEXT_X, BAND_Y + BAND_H - 74.0)
	_sub_label.size = Vector2(TEXT_W, 22)
	add_child(_sub_label)
	var env := OS.get_environment("RIFTGATE_REVEAL_T")
	if not env.is_empty():
		_t = float(env)
		_pinned = true
	set_process(true)


func _process(delta: float) -> void:
	if not _pinned:
		_t += delta
	if _t >= LENGTH:
		_finish()
		return
	_family_label.text = _typed(family.to_upper() + " // BOSS", 0.8, 0.5)
	_name_label.text = _resolved(boss_name.to_upper(), 1.0, 0.7)
	_sub_label.text = _typed(order_text, 1.8, 0.7)
	modulate = Color(1, 1, 1, _alpha())
	queue_redraw()


func _alpha() -> float:
	var a := clampf(_t / 0.3, 0.0, 1.0)
	return a * clampf((LENGTH - _t) / FADE, 0.0, 1.0)


## Text arriving a character at a time from `at`, over `dur` seconds.
func _typed(txt: String, at: float, dur: float) -> String:
	var n := int(clampf((_t - at) / dur, 0.0, 1.0) * txt.length())
	return txt.substr(0, n)


## Text settling out of a scramble: the first characters resolve first, the rest churn.
func _resolved(txt: String, at: float, dur: float) -> String:
	if _t < at:
		return ""
	var n := int(clampf((_t - at) / dur, 0.0, 1.0) * txt.length())
	var frame := int(_t * 20.0)
	var out := ""
	for k in range(txt.length()):
		if k < n or txt[k] == " ":
			out += txt[k]
		else:
			out += GLYPHS[absi(hash(frame * 31 + k * 7)) % GLYPHS.length()]
	return out


func _draw() -> void:
	var w := size.x
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.55))
	# The band, sliding down into place.
	var slide := 1.0 - pow(1.0 - clampf(_t / 0.3, 0.0, 1.0), 3.0)
	var band := Rect2(0.0, BAND_Y + lerpf(-BAND_H - 20.0, 0.0, slide), w, BAND_H)
	draw_rect(band, Color(0, 0, 0, 0.92))
	draw_rect(Rect2(band.position, Vector2(w, 4.0)), Palette.ENEMY)
	draw_rect(Rect2(band.position + Vector2(0, BAND_H - 4.0), Vector2(w, 4.0)), Palette.ENEMY)
	Hud.scanlines(self, band, 0.04)
	# The picture's flight: out of its hex, up into the band, growing as it comes.
	var landed := _sprite_rect(band)
	var u := 1.0 - pow(1.0 - clampf((_t - 0.15) / 0.75, 0.0, 1.0), 3.0)
	for k in [3, 2, 1]:
		var uk := 1.0 - pow(1.0 - clampf((_t - 0.15 - 0.07 * k) / 0.75, 0.0, 1.0), 3.0)
		if uk < u:
			_draw_picture(_lerp_rect(Rect2(from - from_size * 0.5, from_size), landed, uk), Color(Palette.ENEMY, 0.32 / k), -1.0)
	var here := _lerp_rect(Rect2(from - from_size * 0.5, from_size), landed, u)
	_draw_picture(here, Color.WHITE, _t if u >= 1.0 else -1.0)
	# The feed acquires it: brackets collapsing from the band onto the picture.
	if _t > 0.9:
		var v := 1.0 - pow(1.0 - clampf((_t - 0.9) / 0.5, 0.0, 1.0), 2.0)
		var target := here.grow(14.0)
		var r := _lerp_rect(band.grow(-10.0), target, v)
		Hud.brackets(self, r, 24.0, Palette.ENEMY, 2.0)
		if v >= 1.0:
			Hud.box(self, target, 4.0, Color(0, 0, 0, 0), Color(Palette.ENEMY, 0.35), 1.0)
	# The cursor after the order, blinking: a block drawn here, never a character, since the
	# mono face has no block and the fallback's taller line bobbed the order up and down with
	# every blink (Ryan, 25 October).
	if _t > 1.8 and fmod(_t, 0.8) < 0.4:
		var font := Hud.mono()
		var tw := font.get_string_size(_sub_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		var top := _sub_label.position.y + (_sub_label.size.y - 15.0) * 0.5
		draw_rect(Rect2(_sub_label.position.x + tw + 3.0, top, 8.0, 15.0), Palette.INK)


func _sprite_rect(band: Rect2) -> Rect2:
	var sz := Vector2(SPRITE_H, SPRITE_H)
	if tex != null:
		var used := Sprites.used_rect(tex)
		var k := SPRITE_H / maxf(1.0, used.size.y)
		sz = used.size * k
		if sz.x > 300.0:
			sz *= 300.0 / sz.x
	return Rect2(Vector2(SPRITE_X, band.position.y + BAND_H * 0.5) - sz * 0.5, sz)


static func _lerp_rect(a: Rect2, b: Rect2, u: float) -> Rect2:
	return Rect2(a.position.lerp(b.position, u), a.size.lerp(b.size, u))


## The boss's picture in `rect`: its combat sprite, or the map's big diamond when it has
## none yet. With a clock `t` (landed), it tears in slices every TEAR_PERIOD for a moment.
func _draw_picture(rect: Rect2, tint: Color, t: float) -> void:
	if tex == null:
		var c := rect.get_center()
		var r := rect.size.y * 0.5
		var diamond := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
		draw_colored_polygon(diamond, Color(Palette.ENEMY, tint.a))
		var inner := PackedVector2Array([c + Vector2(0, -r + 18.0), c + Vector2(r - 18.0, 0), c + Vector2(0, r - 18.0), c + Vector2(-r + 18.0, 0)])
		Hud.stroke_poly(self, inner, Color(Palette.BG, tint.a), 4.0)
		return
	var src := Sprites.used_rect(tex)
	var slot := floorf(t / TEAR_PERIOD)
	var tearing := t >= 0.0 and Hud.noise(slot * 7.3 + 0.2) > 0.4 and fmod(t, TEAR_PERIOD) < TEAR_SECONDS
	if not tearing:
		draw_texture_rect_region(tex, rect, src, tint)
		return
	var n := 7
	var tick := floorf(fmod(t, TEAR_PERIOD) * 30.0)
	for i in range(n):
		var y0 := float(i) / n
		var y1 := float(i + 1) / n
		var part := Rect2(src.position + Vector2(0, src.size.y * y0), Vector2(src.size.x, src.size.y * (y1 - y0)))
		var dst := Rect2(rect.position + Vector2(0, rect.size.y * y0), Vector2(rect.size.x, rect.size.y * (y1 - y0)))
		var torn := Hud.noise(slot * 3.1 + i * 0.37) > 0.55
		if torn:
			dst.position.x += (Hud.noise(slot * 5.9 + i * 0.71 + tick * 1.3) - 0.5) * 44.0
		draw_texture_rect_region(tex, dst, part, Color(1.0, 0.75 if torn else 1.0, 0.75 if torn else 1.0, tint.a))


func _gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		accept_event()
		_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	set_process(false)
	finished.emit()

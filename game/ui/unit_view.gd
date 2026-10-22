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
const STATUS_H := 38.0
const CHIP_H := 30.0
const CHIP_GLYPH := 18.0
const CHIP_TEXT := 16
const BAR_H := 11.0
const BAR_STEP := 14.0
const FLOAT_BAR_W := 60.0
const GAP := 10.0          # between the drawing and its gauges above or its chips below
const FLOAT_LIFT := 16.0   # a foe's floating gauge: how far its bottom row sits above the drawing (any higher and it crowds the rank above)
const LEADER := 16.0       # the floating gauge's leader, in x and in y; it runs onto the sprite, which is allowed
const PIP_H := 9.0         # the pips' row under the gauges, and the step it adds to them

var display_name: String = ""     # for the codex and readouts; never drawn here
var is_enemy: bool = false
var massive: bool = false
var bars: Array = []              # [[value, max, Color, (pending)], ...]
var bars_above: bool = false      # true: full-width gauges above the sprite; false: floating
var pips: Array = []              # [count, of]: a count drawn as pips under the gauges (the Cassowary's sixth shot), the last lit when it is next; empty for none
var boxes: Array = []             # [count, cap, colour, glyph]: a capped store's boxes under the gauges, lit to its count (the Nemesis's rage, Ryan, 22 October); empty for none
var sprite_density := 1.0         # a machine's render is this much larger than the frame it stands for (MechView3D.density); pixel art is 1
var intent_kind: String = ""      # "attack", "defend", "heal", "buff", "debuff", or ""
var intent_value: int = 0
var intent_note: String = ""      # after the number: "×2" for a double strike, "!" for a breach
var intent: String = ""           # quiet text for an empty slot, e.g. "EXPOSED"
var intent_dim: bool = false
var statuses: Array = []          # [[glyph id, chip text, (Color), (kind)], ...] under the sprite; kind "resist" is no status (Numbed)
var highlight: bool = false       # valid drop target while dragging a die
var mined: bool = false           # an empty slot with mines waiting (the Lammergeier's): a dashed outline round it, never a hue alone
var dead: bool = false
var sprite: Texture2D = null      # pixel art drawn at an integer scale; null draws a placeholder
var pixel_snap := false           # a foe's pixel art: scaled by whole device pixels, not design pixels (below)
var used_override := Rect2()      # the drawing's extent inside the sprite, when the caller knows it (a 3D view's model bounds)
var breathe: bool = false         # a slow vertical bob from the feet: a painted foe alive
var flip_h: bool = false          # mirror the sprite, so an enemy painted facing right faces left
var breathe_phase: float = 0.0
var _shatter: float = -1.0        # seconds since the shield broke on this unit; negative when idle
const SHATTER_SECONDS := 0.55
var _acquire: float = -1.0        # seconds since the display locked onto this unit's intent; negative when idle
const ACQUIRE_SECONDS := 0.3
const SCRAMBLE_PART := 0.55       # the first part of the acquire, while the number is still settling
var _glitch: float = -1.0         # seconds since this unit's picture tore; negative when idle
var _glitch_kind := "tear"        # "tear": slices jump sideways; "drop": the signal goes, static and a tag
var _glitch_for := 0.5            # how long this tear lasts
var _spend: float = -1.0          # seconds since a store's stack went from a chip (the Nemesis's rage); negative when idle
var _spend_glyph := ""           # the chip it went from
const SPEND_SECONDS := 0.55
var _chip_rects := {}             # glyph -> [rect, colour] as last drawn, so a chip's last stack bursts where the chip was

var _pressed := false
var _press_at := 0.0
var _holding := false
var _last_tap_at := -10.0
var _t := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # the sprite is pixel art; the screen's text is linear
	set_process(false)


## Centre of the drawing, in global coordinates, for arrows.
func anchor_global() -> Vector2:
	return get_global_transform() * _visible().get_center()


func _bars_height() -> float:
	return (bars.size() * BAR_STEP + _pips_step() + _boxes_step() + GAP) if bars_above and not bars.is_empty() else 0.0


func _pips_step() -> float:
	return PIP_H + 3.0 if pips.size() >= 2 and int(pips[1]) > 0 else 0.0


func _boxes_step() -> float:
	return PIP_H + 3.0 if boxes.size() >= 2 and int(boxes[1]) > 0 else 0.0


func _scale() -> float:
	if sprite == null:
		return 1.0
	var top := _bars_height() + 2.0
	var avail := size.y - top - STATUS_H
	var ts := _sprite_size()
	if pixel_snap:
		# A foe's sprite pixel lands on a whole number of device pixels (decided 9 October,
		# with the 72x96 frame): on the 1080 phone, two; a denser glass may take three and
		# draw a little larger, the design's 720 one. Scaling by whole design pixels instead
		# put a 72-wide sprite at 1.5 device pixels a pixel, which the nearest filter draws
		# unevenly.
		var d := _device_scale()
		var k := maxf(1.0, floorf(minf(size.x * d / ts.x, avail * d / ts.y)))
		return k / d
	return maxf(1.0, floorf(minf(size.x / ts.x, avail / ts.y)))


## Device pixels per local pixel: the canvas and the window's stretch together; 1 off the
## tree (headless tests), where the design is the glass.
func _device_scale() -> float:
	if not is_inside_tree():
		return 1.0
	var xf := get_viewport().get_final_transform() * get_global_transform_with_canvas()
	return maxf(0.01, xf.get_scale().y)


## The sprite's size in design pixels: its texture's, over the density it was rendered at.
func _sprite_size() -> Vector2:
	return sprite.get_size() / sprite_density


## The opaque part of the sprite, in sprite pixels: told by the caller, or read from the
## image (pixel art only; a viewport texture would be read back from the GPU every frame).
func _used() -> Rect2:
	if used_override.size.x > 0.0 and used_override.size.y > 0.0:
		return Rect2(used_override.position / sprite_density, used_override.size / sprite_density)
	return Sprites.used_rect(sprite)


## The drawn frame on screen (unflipped), for a ghost of the sprite when the unit dies.
func sprite_frame() -> Rect2:
	return _silhouette()


## The whole sprite frame, centred in the sprite area so units of different heights line up
## on their middles. Gauges and chips hug the drawing inside the frame, not the frame.
func _silhouette() -> Rect2:
	var top := (_bars_height() + 2.0) if sprite != null else size.y * 0.12 + _bars_height()
	var avail := size.y - top - STATUS_H
	if sprite != null:
		var s := _scale()
		var ts := _sprite_size() * s
		var used := _used()
		# Centre the drawing, not the frame: shift by the frame's own transparent margins.
		var margin_top := used.position.y * s
		var margin_bottom := (_sprite_size().y - used.end.y) * s
		var y := top + (avail - ts.y) * 0.5 + (margin_bottom - margin_top) * 0.5
		return Rect2(Vector2(floorf((size.x - ts.x) * 0.5), floorf(y)), ts)
	var w := size.x * 0.46
	var h := minf(avail, size.y * (0.78 if massive else 0.62))
	return Rect2(Vector2((size.x - w) * 0.5, top + (avail - h) * 0.5), Vector2(w, h))


## The opaque part of the drawing on screen: what gauges and chips hug.
func _visible() -> Rect2:
	var sil := _silhouette()
	if sprite == null:
		return sil
	var used := _used()
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
	if _shatter >= 0.0:
		_shatter += delta
		if _shatter > SHATTER_SECONDS:
			_shatter = -1.0
		queue_redraw()
	if _acquire >= 0.0:
		_acquire += delta
		if _acquire > ACQUIRE_SECONDS:
			_acquire = -1.0
		queue_redraw()
	if _glitch >= 0.0:
		_glitch += delta
		if _glitch > _glitch_for:
			_glitch = -1.0
		queue_redraw()
	if _spend >= 0.0:
		_spend += delta
		if _spend > SPEND_SECONDS:
			_spend = -1.0
		queue_redraw()
	if (_has_pending() or breathe) and visible and not dead:
		_t += delta
		queue_redraw()
	elif not _pressed and _shatter < 0.0 and _acquire < 0.0 and _glitch < 0.0 and _spend < 0.0:
		set_process(false)


func queue_refresh() -> void:
	if _has_pending() or breathe:
		set_process(true)
	queue_redraw()


## The shield just broke on this unit: a hex ring bursts outward and shards fly, in the
## shield's colour, over the drawing. Called by the skirmish screen as the blow lands.
func shatter_shield() -> void:
	_shatter = 0.0
	set_process(true)
	queue_redraw()


## The display locks onto this unit's intent (Ryan, 23 September: a feed being read, not a
## print): bracket corners collapse onto the intent chip, its number settles from a
## scramble, and the gauge's leader draws itself. Called when a round's intents appear and
## when a foe arrives.
func acquire() -> void:
	_acquire = 0.0
	set_process(true)
	queue_redraw()


## This unit's picture is input the display cannot hold for a moment (Ryan, 23 September:
## the corrupted side's tear on one unit, not only across the whole side). "tear": the
## sprite's slices jump sideways; "drop": the signal goes, the sprite fades under static
## and a tag says so.
func glitch(kind: String = "tear", seconds: float = 0.5) -> void:
	_glitch = 0.0
	_glitch_kind = kind
	_glitch_for = seconds
	set_process(true)
	queue_redraw()


## A stack spent from one of this unit's chips (the Nemesis's rage rolling its die again,
## Ryan, 13 October): the chip flashes hot, a ring and sparks burst off it and a "-1" rises.
## Called by the skirmish screen as the stack goes, before the die rolls.
func spend_chip(glyph: String) -> void:
	_spend = 0.0
	_spend_glyph = glyph
	# A capped store's stack goes from its boxes (the rage, 22 October): the burst is on the box
	# that just emptied, the count having already dropped.
	if boxes.size() >= 4 and str(boxes[3]) == glyph and int(boxes[1]) > 0:
		var at := clampi(int(boxes[0]), 0, int(boxes[1]) - 1)
		_chip_rects[glyph] = [_box_rect(at).grow(3.0), boxes[2]]
	set_process(true)
	queue_redraw()


## The opaque part of the drawing, in this view's pixels, for anything drawn around the
## unit from outside (the feed's analysis boxes).
func drawing_rect() -> Rect2:
	return _visible()


## The sprite drawn torn: seven slices, most holding, a few thrown sideways and one tinted;
## a dropped signal draws them faint under static with a tag.
func _draw_glitched(frame: Rect2) -> void:
	var drop := _glitch_kind == "drop"
	var tick := int(_glitch * 24.0)   # the slices hold a new position for a few frames each
	var ts := sprite.get_size()
	var n := 7
	for k in range(n):
		var f0 := float(k) / float(n)
		var f1 := float(k + 1) / float(n)
		var src := Rect2(0.0, ts.y * f0, ts.x, ts.y * (f1 - f0))
		# A tear throws slices sideways; a dropped signal barely moves them (Ryan, 23 September:
		# the two read alike), it fades the picture and fills it with static.
		var off := (Hud.noise(tick * 1.3 + k * 0.77 + breathe_phase) - 0.5) * (6.0 if drop else 18.0)
		if Hud.noise(tick * 2.1 + k * 0.31 + breathe_phase) < (0.7 if drop else 0.4):
			off = 0.0
		var dst := Rect2(Vector2(frame.position.x + off, frame.position.y + frame.size.y * f0), Vector2(frame.size.x, frame.size.y * (f1 - f0)))
		var mod := Color.WHITE
		if drop:
			mod = Color(1, 1, 1, 0.12 + 0.18 * Hud.noise(tick + k * 0.5))
		elif Hud.noise(tick * 3.3 + k * 0.17) > 0.8:
			mod = Color(1.5, 0.55, 0.55)
		draw_texture_rect_region(sprite, dst, src, mod)
	if drop:
		var r := frame.abs()
		for j in range(22):
			var yy := r.position.y + Hud.noise(tick * 0.7 + j * 0.61) * r.size.y
			var x0 := r.position.x + Hud.noise(tick * 1.9 + j * 0.23) * r.size.x * 0.6
			var w := r.size.x * (0.15 + 0.4 * Hud.noise(tick * 0.4 + j * 0.83))
			draw_rect(Rect2(x0, yy, w, 1.0), Color(Palette.HUD, 0.3 + 0.3 * Hud.noise(tick * 1.1 + j)))
		# The tag on a dark plate, in the enemy's colour, blinking slowly.
		if int(_glitch * 3.0) % 2 == 0:
			var font := Hud.display_bold()
			var tw := font.get_string_size("SIG LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
			var plate := Rect2(r.get_center().x - tw * 0.5 - 8.0, r.get_center().y - 13.0, tw + 16.0, 26.0)
			Hud.box(self, plate, 4.0, Color(Palette.BG, 0.9), Palette.ENEMY, 1.2)
			draw_string(font, Vector2(plate.position.x, plate.get_center().y + 6.0), "SIG LOST", HORIZONTAL_ALIGNMENT_CENTER, plate.size.x, 16, Palette.ENEMY)


func _draw_shatter(vis: Rect2) -> void:
	var t := clampf(_shatter / SHATTER_SECONDS, 0.0, 1.0)
	var c := vis.get_center()
	var r0 := minf(vis.size.x, vis.size.y) * 0.42
	var ring := Color(Palette.SHIELD, (1.0 - t) * 0.9)
	draw_polyline(Hex.corners(c, r0 * (1.0 + t * 0.9)), ring, 2.5 * (1.0 - t * 0.6), true)
	if t < 0.5:
		draw_polyline(Hex.corners(c, r0 * (1.0 + t * 0.4)), Color(Color.WHITE, (0.5 - t) * 1.2), 1.5, true)
	for k in range(8):
		var ang := TAU * float(k) / 8.0 + 0.3
		var dir := Vector2(cos(ang), sin(ang))
		var a := c + dir * r0 * (0.6 + t * 1.6)
		var b := a + dir * (10.0 + 14.0 * (1.0 - t))
		draw_line(a, b, Color(Palette.SHIELD, (1.0 - t) * 0.8), 2.0)


## The stack going (spend_chip): hot and loud, since every effect judged on the phone has come
## back hotter. Drawn over the chip, or where the chip was when that was its last stack.
func _draw_spend(mono: Font) -> void:
	if _spend < 0.0 or not _chip_rects.has(_spend_glyph):
		return
	var t := clampf(_spend / SPEND_SECONDS, 0.0, 1.0)
	var rect: Rect2 = _chip_rects[_spend_glyph][0]
	var col: Color = _chip_rects[_spend_glyph][1]
	var c := rect.get_center()
	# The flash: the chip floods with its colour, white at the core for the first moment.
	Hud.fill_poly(self, Hud.cut(rect.grow(3.0 * (1.0 - t)), 4.0), Color(col, 0.9 * (1.0 - t)))
	if t < 0.35:
		Hud.fill_poly(self, Hud.cut(rect.grow(-5.0), 3.0), Color(Color.WHITE, (0.35 - t) * 2.6))
	# The ring, bursting off the chip, and the sparks flying ahead of it.
	Hud.stroke_poly(self, Hud.cut(rect.grow(4.0 + 34.0 * t), 6.0), Color(col, 1.0 - t), 3.5 * (1.0 - t * 0.5))
	for k in range(10):
		var ang := TAU * float(k) / 10.0 + 0.2
		var dir := Vector2(cos(ang), sin(ang) * 0.7)
		var a := c + dir * (rect.size.x * 0.5 + 40.0 * t)
		draw_line(a, a + dir * (9.0 + 13.0 * (1.0 - t)), Color(col, (1.0 - t) * 0.95), 2.5)
	# The count going: a -1 rising off the chip, on a dark edge so it holds over any ground.
	var y := rect.position.y - 8.0 - 30.0 * t
	draw_string_outline(mono, Vector2(rect.position.x, y), "-1", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, 4, Color(Palette.BG, (1.0 - t * t) * 0.9))
	draw_string(mono, Vector2(rect.position.x, y), "-1", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Color(col, 1.0 - t * t))


func _draw() -> void:
	var hud := Palette.HUD
	var mono := Hud.mono()
	var sil := _silhouette()
	var vis := _visible()
	if sprite != null:
		var frame := sil
		if breathe and not dead:
			# A 2% rise from the feet and a small lean, slow and out of phase between foes: enough
			# to be seen as deliberate, not enough to animate a painted sprite.
			# Each foe at its own rate as well as its own phase, so neighbours drift apart
			# instead of falling into step (Ryan, 23 September; and a touch less of it).
			var rate := 1.35 + 0.5 * Hud.noise(breathe_phase * 0.37 + 0.11)
			var k := 1.0 + 0.022 * sin(_t * rate + breathe_phase)
			var lean := 0.007 * sil.size.x * sin(_t * rate * 0.55 + breathe_phase * 0.7)
			frame = Rect2(Vector2(sil.position.x + lean, sil.end.y - sil.size.y * k), Vector2(sil.size.x, sil.size.y * k))
		if flip_h:
			frame = Rect2(Vector2(frame.end.x, frame.position.y), Vector2(-frame.size.x, frame.size.y))
		if _glitch >= 0.0 and not dead:
			_draw_glitched(frame)
		else:
			draw_texture_rect(sprite, frame, false, Color(0.3, 0.3, 0.3) if dead else Color.WHITE)
	else:
		var edge := Color(Palette.ENEMY_DIM if dead else hud, 0.4)
		Hud.box(self, sil, 10.0, Color(Palette.PANEL_RAISED, 0.9), edge, 1.0)
	if dead:
		draw_line(vis.position, vis.end, Palette.ENEMY_DIM, 2.0)
		draw_line(Vector2(vis.position.x, vis.end.y), Vector2(vis.end.x, vis.position.y), Palette.ENEMY_DIM, 2.0)
	if mined and sprite == null:
		_draw_dashed(sil.grow(5.0), Palette.HEAT, 3.0)
	if highlight:
		Hud.brackets(self, vis.grow(6.0), 14.0, Palette.TARGET, 2.0)
	if _shatter >= 0.0:
		_draw_shatter(vis)

	# Every gauge has a dark ground of its own shape (Ryan, 23 September: the plate under the
	# stack was a box; the bars keep the chamfer and the ground keeps them readable on
	# terrain). Gauges and chips stand a little off the drawing, not against it.
	if not bars.is_empty() and not dead:
		if bars_above:
			# Full-width gauges stacked above the drawing: hull, shield, heat.
			var bx := size.x * 0.1
			var bw := size.x * 0.8
			var y := vis.position.y - GAP - bars.size() * BAR_STEP - _pips_step() - _boxes_step()
			for b in bars:
				_gauge(Rect2(bx, y, bw, BAR_H), b)
				y += BAR_STEP
			if _pips_step() > 0.0:
				_draw_pips(Rect2(bx, y, bw, PIP_H))
				y += _pips_step()
			if _boxes_step() > 0.0:
				_draw_boxes(Rect2(bx, y, bw, PIP_H))
		else:
			# One small gauge floating above the drawing's top-right, with a leader dropping
			# from a third of the way along its underside, diagonally down-left onto the sprite.
			# On acquire the leader draws itself.
			var bx := minf(vis.end.x - 10.0, size.x - FLOAT_BAR_W - 2.0)
			var y := vis.position.y - FLOAT_LIFT
			var from := Vector2(bx + FLOAT_BAR_W / 3.0, y + BAR_H)
			var reach := 1.0 if _acquire < 0.0 else clampf(_acquire / (ACQUIRE_SECONDS * 0.6), 0.0, 1.0)
			if reach > 0.0:
				# Thicker, on a dark edge, so it holds on the phone and on the other world's
				# green when the HUD is green (Ryan, 28 September).
				var tip := from + Vector2(-LEADER, LEADER) * reach
				draw_line(from, tip, Color(Palette.BG, 0.7), 5.0)
				draw_line(from, tip, Color(hud, 1.0), 3.0)
			for b in bars:
				_gauge(Rect2(bx, y, FLOAT_BAR_W, BAR_H), b)
				y -= BAR_STEP

	# Quiet readout for an empty slot.
	if not intent.is_empty() and not dead and sprite == null and intent_kind.is_empty():
		draw_string(mono, Vector2(0, sil.get_center().y + 5.0), "[%s]" % intent, HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, Color(hud, 0.45 if intent_dim else 0.95))

	# The chip row under the drawing: intent first, then statuses, centred.
	if dead:
		return
	var chips: Array = []
	if not intent_kind.is_empty():
		chips.append([Glyphs.intent_for(intent_kind), (str(intent_value) + intent_note) if intent_value > 0 else "", Palette.ENEMY if is_enemy else hud])
	for s in statuses:
		chips.append([s[0], str(s[1]), s[2] if s.size() >= 3 else hud, s[3] if s.size() >= 4 else "status"])
	if chips.is_empty():
		_draw_spend(mono)
		return
	var widths: Array[float] = []
	var total := 0.0
	for ch in chips:
		var txt: String = ch[1]
		var w := CHIP_H + (mono.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, CHIP_TEXT).x + 8.0 if not txt.is_empty() else 0.0)
		widths.append(w)
		total += w + 6.0
	total -= 6.0
	var x := floorf((size.x - total) * 0.5)
	var cy := minf(vis.end.y + GAP, size.y - 2.0) + CHIP_H * 0.5
	cy = minf(cy, size.y - CHIP_H * 0.5 - 1.0)
	var acq := clampf(_acquire / ACQUIRE_SECONDS, 0.0, 1.0) if _acquire >= 0.0 else 1.0
	for i in range(chips.size()):
		var ch: Array = chips[i]
		var col: Color = ch[2]
		var rect := Rect2(x, cy - CHIP_H * 0.5, widths[i], CHIP_H)
		_chip_rects[ch[0]] = [rect, col]
		if ch.size() >= 4 and ch[3] == "resist":
			# A resistance is no status (Numbed, 10 October): bracket corners on a bare ground,
			# never the box a status wears, so the difference is the frame, not a hue.
			Hud.fill_poly(self, Hud.cut(rect, 4.0), Color(Palette.BG, 0.94))
			Hud.brackets(self, rect, 5.0, col, 1.6)
		else:
			Hud.box(self, rect, 4.0, Color(Palette.BG, 0.94), col, 1.2)
		Glyphs.draw(self, ch[0], Vector2(x + CHIP_H * 0.5, cy), CHIP_GLYPH, col, 2.0)
		var txt: String = ch[1]
		var locking := i == 0 and not intent_kind.is_empty() and acq < 1.0
		if locking and acq < SCRAMBLE_PART:
			txt = Hud.scramble(txt, int(Time.get_ticks_msec() / 45), get_instance_id() % 97)
		if not txt.is_empty():
			draw_string(mono, Vector2(x + CHIP_H - 2.0, cy + CHIP_TEXT * 0.36), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, CHIP_TEXT, col)
		if locking:
			# The lock: bracket corners collapsing onto the chip, fading as they land.
			Hud.brackets(self, rect.grow(2.0 + 18.0 * (1.0 - acq)), 8.0, Color(col, 1.0 - acq * 0.7), 1.5)
		x += widths[i] + 6.0
	_draw_spend(mono)


## A rect drawn in dashes (a mined slot's outline): structure, so it never rests on its hue.
func _draw_dashed(rect: Rect2, color: Color, width: float) -> void:
	var dash := 9.0
	var gap := 6.0
	var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	for k in range(4):
		var a: Vector2 = corners[k]
		var b: Vector2 = corners[(k + 1) % 4]
		var length := a.distance_to(b)
		var dir := (b - a) / maxf(1.0, length)
		var t := 0.0
		while t < length:
			draw_line(a + dir * t, a + dir * minf(t + dash, length), Color(Palette.BG, 0.8), width + 2.0)
			draw_line(a + dir * t, a + dir * minf(t + dash, length), color, width)
			t += dash + gap


## A gauge on its own dark ground, with, when a pending value is given, a pulsing overlay on
## the part about to change. The overlay is ink white with a dark edge, never a hue: it has
## to read against any bar colour and for any kind of colour vision. Where it sits says
## which way the bar moves: inside the fill, that much is about to go; past the fill, that
## much is coming.
## The count as pips across the gauges' width (the Cassowary's sixth shot, 21 October: six
## under the heat bar, Ryan's spot): a filled pip a shot, the last a diamond, so it reads as
## the one that counts by shape as well as colour, lit in the heat's colour when it is next.
func _draw_pips(rect: Rect2) -> void:
	var of := int(pips[1])
	var count := int(pips[0]) % of
	var step := rect.size.x / float(of)
	var hud := Palette.HUD
	for k in range(of):
		var c := Vector2(rect.position.x + step * (k + 0.5), rect.get_center().y)
		var r := minf(rect.size.y * 0.5, step * 0.32)
		var last := k == of - 1
		var lit := last and count == of - 1
		var col: Color = Palette.HEAT if lit else hud
		if last:
			var pts := PackedVector2Array([c + Vector2(0, -r - 1.5), c + Vector2(r + 1.5, 0), c + Vector2(0, r + 1.5), c + Vector2(-r - 1.5, 0)])
			draw_colored_polygon(pts, Color(Palette.BG, 0.9))
			if lit:
				draw_colored_polygon(pts, col)
			pts.append(pts[0])
			draw_polyline(pts, col, 1.5)
		else:
			var box := Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0)
			draw_rect(box.grow(1.0), Color(Palette.BG, 0.9))
			if k < count:
				draw_rect(box, col)
			draw_rect(box, col, false, 1.5)


## A capped store as boxes across the gauges' width (Ryan, 22 October: the rage, individual
## boxes up to the cap), one lit for each stack it holds, so the count reads by how many are
## filled. The last lit box is where a stack's spend bursts (spend_chip), as the chip it
## replaces was.
func _draw_boxes(rect: Rect2) -> void:
	var cap := int(boxes[1])
	var count := clampi(int(boxes[0]), 0, cap)
	var col: Color = boxes[2] if boxes.size() >= 3 else Palette.HUD
	for k in range(cap):
		var box := _box_rect(k, rect)
		draw_rect(box.grow(1.5), Color(Palette.BG, 0.9))
		if k < count:
			draw_rect(box, col)
		draw_rect(box, col, false, 1.5)


## Box `k` of a capped store's row, in `row` or where the gauges put the row.
func _box_rect(k: int, row: Rect2 = Rect2()) -> Rect2:
	if row.size == Vector2.ZERO:
		var vis := _visible()
		row = Rect2(size.x * 0.1, vis.position.y - GAP - _boxes_step(), size.x * 0.8, PIP_H)
	var cap := maxi(1, int(boxes[1]))
	var step := row.size.x / float(cap)
	var side := minf(row.size.y + 2.0, step * 0.7)
	var c := Vector2(row.position.x + step * (k + 0.5), row.get_center().y)
	return Rect2(c - Vector2(side, side) * 0.5, Vector2(side, side))


func _gauge(rect: Rect2, b: Array) -> void:
	var mx := float(maxi(1, int(b[1])))
	var frac: float = clampf(float(b[0]) / mx, 0.0, 1.0)
	var col: Color = b[2]
	Hud.fill_poly(self, Hud.slant(rect.grow(1.0), 4.0), Color(Palette.BG, 0.9))
	Hud.gauge(self, rect, frac, col)
	Hud.stroke_poly(self, Hud.slant(rect, 4.0), Color(col, 0.95), 1.0)   # a full-strength edge, so an empty bar still shows
	# Shield past its maximum (Overshield, 5 October): the excess stands beyond the bar's
	# end as a hatched block in the bar's colour on its own dark ground, by structure, not
	# hue, so a full bar and an overfull one never read alike. It fades at the round's end.
	var over_now := maxf(0.0, (float(b[0]) - mx) / mx)
	var over_pending := maxf(0.0, (float(b[3]) - mx) / mx) if b.size() >= 4 else over_now
	var over := maxf(over_now, over_pending)
	if over > 0.0:
		var ext := Rect2(rect.end.x + 3.0, rect.position.y, maxf(4.0, rect.size.x * minf(over, 0.6)), rect.size.y)
		Hud.fill_poly(self, Hud.slant(ext.grow(1.0), 4.0), Color(Palette.BG, 0.9))
		var solid := over_now / over if over > 0.0 else 0.0
		if solid > 0.0:
			Hud.fill_poly(self, Hud.slant(Rect2(ext.position, Vector2(ext.size.x * solid, ext.size.y)), 4.0), Color(col, 0.95))
		Hud.stroke_poly(self, Hud.slant(ext, 4.0), Color(col, 0.95), 1.0)
		var hx := ext.position.x + 2.0
		while hx < ext.end.x:
			draw_line(Vector2(hx, ext.end.y), Vector2(hx + ext.size.y, ext.position.y), Color(Palette.INK, 0.8), 1.0)
			hx += 4.0
	# A banked bar's charges (the Swallowtail's Muster, a fifth element the points a charge): a
	# notch at each charge across the bar, so its count reads by structure.
	if b.size() >= 5 and int(b[4]) > 0:
		var step := float(int(b[4])) / mx
		var at := step
		while at < 0.999:
			var x := rect.position.x + rect.size.x * at
			draw_line(Vector2(x, rect.position.y - 1.0), Vector2(x, rect.end.y + 1.0), Color(Palette.BG, 0.95), 3.0)
			at += step
	if b.size() < 4 or int(b[3]) == int(b[0]):
		return
	var pending: float = clampf(float(b[3]) / mx, 0.0, 1.0)
	var lo := minf(frac, pending)
	var hi := maxf(frac, pending)
	var inner := rect.grow(-2.0)
	# One clock for every gauge on screen (Ryan, 22 September: bars that breathe together
	# are easier to read), not this view's own, which starts when its first pending shows.
	var clock := Time.get_ticks_msec() / 1000.0
	var pulse := 0.72 + 0.22 * sin(clock * 3.2)
	var seg := Rect2(inner.position + Vector2(inner.size.x * lo, 0), Vector2(maxf(3.0, inner.size.x * (hi - lo)), inner.size.y))
	var pts := Hud.slant(seg, 2.4)
	if pending < frac:
		# A loss: the part about to go breathes between dimmed and lit in ink, a full swing,
		# so it is seen to pulse on any bar colour (Ryan, 22 September: it had faded to a
		# faint dimming).
		var beat := 0.5 + 0.5 * sin(clock * 3.2)
		Hud.fill_poly(self, pts, Color(Palette.BG, 0.65 * (1.0 - beat)))
		Hud.fill_poly(self, pts, Color(Palette.INK, 0.55 * beat))
		Hud.stroke_poly(self, pts, Color(Palette.INK, 0.6 + 0.4 * beat), 1.0)
	else:
		# A gain: hatched in the bar's own colour, so it reads as "coming", not "there".
		Hud.stroke_poly(self, pts, Color(col, pulse), 1.0)
		var x := seg.position.x + 3.0
		while x < seg.end.x:
			draw_line(Vector2(x, seg.end.y), Vector2(x + seg.size.y, seg.position.y), Color(col, pulse * 0.8), 1.0)
			x += 4.0

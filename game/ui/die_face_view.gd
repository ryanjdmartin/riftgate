class_name DieFaceView
extends Control

## A die drawn as an object under the tactical overlay. The face is a chamfered square that
## bobs gently; its keywords sit as small annotation chips hugging its right edge, one per
## keyword, bright and flickering now and then. On the face, as Ryan sketched it: the primary
## glyph large at the top centre, the number or range beneath it, heat bottom-left, the lock
## top-right, the entry's place on its die top-left. A locked die gets bracket corners and a
## LOCKED readout. A unique effect adds a star chip.
##
## Gestures (the skirmish's, Ryan, 30 October):
##   tap         -> `tapped`          read the die: its readout opens, or closes
##   double-tap  -> `double_tapped`   lock or unlock
##   hold        -> `held` / `hold_released`   lock or unlock
##   drag        -> `drag_started` / `drag_moved(pos)` / `drag_ended(pos)`   spend the face on a target
## With `confirm_taps` a tap lands only once the double-tap window has passed with no second tap,
## so a double-tap never shows a tap's work; the face lights from the touch until the tap lands.

signal tapped
signal double_tapped
signal held
signal hold_released
signal drag_started
signal drag_moved(global_pos: Vector2)
signal drag_ended(global_pos: Vector2)

const HOLD_SECONDS := 0.45
const DRAG_THRESHOLD := 14.0
const DOUBLE_TAP_SECONDS := 0.3   # Android's own double-tap window

const FACE := 120.0        # the square face
const RAIL := 18.0         # how far the chips hang past the right edge
const CHIP := Vector2(26, 24)
const TAG_STEP := 28.0
const BOB_PX := 3.0
const CUT := 16.0
const FLICKER_PERIOD := 4.5   # seconds between dips, per chip
const SLOT_AT := Vector2(13, 30)   # the place's numeral, its baseline tucked under the cut corner
const SLOT_SIZE := 18

var face: Face = null
var shown_number: String = ""   # what the blow will deal now, or against the foe it is held over (10 October)
var corrupted: int = 0       # Corrupted stacks on the entry showing: a chip in the enemy's colour, with the count
var dark: int = 0            # a dark entry (a cooldown, a foe's disable): the rounds it has left, this one included, drawn as its number
var next_face: Face = null   # a stepping die's next chamber (the Cassowary's), as a chip at the rail's foot; null for a die that rolls
var slot: int = 0            # the entry's place on its die, from one; 0 draws none
var locked: bool = false
var charged: bool = false      # armed for its charged form, a muster paid at the spend (the Swallowtail's): a double frame and the word above
var blast: int = 0             # a vent's blast on its own machine (the Whip Scorpion's): the blow it fires at a random foe, its mark and number in the bottom row
var shut: Array[int] = []      # keywords whose gate is shut over the foe in hand (the gated stuns, 22 October): their chips struck through and dimmed
var spent: bool = false
var dead: bool = false
var can_tap: bool = true     # a tap reads the die
var confirm_taps: bool = false   # a tap waits out the double-tap window before it lands (the tray's dice, whose double-tap locks)
var can_drag: bool = true    # drag spends
var animate: bool = true

var _pressed := false
var _press_pos := Vector2.ZERO
var _press_at := 0.0
var _dragging := false
var _holding := false
var _last_tap_at := -10.0
var _tap_due := -1.0         # when a tap waiting out the double-tap window lands; negative, none
var _t := 0.0
var _phase := 0.0


func _init() -> void:
	custom_minimum_size = view_size()
	mouse_filter = Control.MOUSE_FILTER_STOP
	_phase = randf() * FLICKER_PERIOD
	set_process(true)


static func view_size() -> Vector2:
	return Vector2(FACE + RAIL, FACE)


func set_face(f: Face, shown: String = "") -> void:
	face = f
	shown_number = shown
	queue_redraw()


## The number the blow will deal (Skirmish.shown_number_text), in place of the component's
## own; empty draws the component's own number.
func set_number(shown: String) -> void:
	if shown != shown_number:
		shown_number = shown
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
					_tap_due = -1.0   # the double-tap stands in for its first tap
					double_tapped.emit()
				else:
					_last_tap_at = now
					_land_tap()   # a tap still waiting (its window ran out under this press) lands first
					if confirm_taps:
						_tap_due = now + DOUBLE_TAP_SECONDS
					elif can_tap:
						tapped.emit()
			_pressed = false
			_dragging = false
			_holding = false
			queue_redraw()
		accept_event()
	elif event is InputEventMouseMotion and _pressed and not _holding:
		if not _dragging and can_drag and event.global_position.distance_to(_press_pos) > DRAG_THRESHOLD:
			_dragging = true
			_tap_due = -1.0   # a tap and then a drag is the drag
			drag_started.emit()
		if _dragging:
			drag_moved.emit(event.global_position)
		accept_event()


var _recalc: float = -1.0        # seconds since the display began recomputing this face; negative when idle
const STATIC_RATE := 60.0        # new static positions a second (Ryan, 23 September: 20 was too slow, 48 still a little)
var _recalc_for := 0.7           # how long the recomputation shows


## The display recomputes this face for a moment (Ryan, 23 September: the feed being read):
## static runs across it and the frame flashes once. Nothing about the face changes and
## the number never does.
func recalc(seconds: float = 0.7) -> void:
	_recalc = 0.0
	_recalc_for = seconds
	queue_redraw()


var _wobble: float = -1.0        # seconds since the die's picture began to wobble; negative when idle
var _wobble_for := 0.6
var _shear: TearLayer = null     # reads the die back and redraws its slices displaced, while it wobbles
const WOBBLE_BANDS := 6


## The die's picture wobbles for a moment, as a foe's does when its signal drops (Ryan, 23
## September): the drawing is read back in horizontal slices and a few of them sit
## sideways, a new set every few frames, sideways only. Nothing about the face changes.
func wobble(seconds: float = 0.6) -> void:
	_wobble = 0.0
	_wobble_for = seconds
	if _shear == null:
		_shear = TearLayer.new()
		_shear.manual = true
		_shear.position = Vector2(-2.0, -BOB_PX - 2.0)
		_shear.size = Vector2(FACE + 4.0, FACE + 2.0 * BOB_PX + 4.0)
		add_child(_shear)
	queue_redraw()


## The wobble's slices for this instant, in the shear layer's pixels: the face's height in
## bands, a few of them thrown sideways.
func _wobble_slices(bob: float) -> Array:
	var tick := int(_wobble * 24.0)
	var out: Array = []
	var band_h := FACE / WOBBLE_BANDS
	for k in range(WOBBLE_BANDS):
		if Hud.noise(tick * 2.1 + k * 0.31 + _phase) < 0.55:
			continue
		var shift := (Hud.noise(tick * 1.3 + k * 0.77 + _phase) - 0.5) * 12.0
		out.append({"rect": Rect2(2.0, BOB_PX + 2.0 + bob + k * band_h, FACE, band_h), "shift": shift})
	return out


func _process(delta: float) -> void:
	if _pressed and not _dragging and not _holding:
		if Time.get_ticks_msec() / 1000.0 - _press_at >= HOLD_SECONDS:
			_holding = true
			_tap_due = -1.0   # a tap and then a hold is the hold
			held.emit()
	if _tap_due >= 0.0 and not _pressed and Time.get_ticks_msec() / 1000.0 >= _tap_due:
		_land_tap()
	if _recalc >= 0.0:
		_recalc += delta
		if _recalc > _recalc_for:
			_recalc = -1.0
		queue_redraw()
	if _wobble >= 0.0:
		_wobble += delta
		if _wobble > _wobble_for:
			_wobble = -1.0
			if _shear != null:
				_shear.set_slices([])
		queue_redraw()
	if animate and visible and not dead:
		_t += delta
		queue_redraw()


## A tap waiting out the double-tap window lands now, if one is waiting.
func _land_tap() -> void:
	if _tap_due < 0.0:
		return
	_tap_due = -1.0
	queue_redraw()
	if can_tap:
		tapped.emit()


## The touch answered at once (Ryan, 30 October): lit while the finger is on the face, and while
## its tap waits out the double-tap window, so the beat before the readout never reads as lag.
func _lit() -> bool:
	return (_pressed and not _dragging) or _tap_due >= 0.0


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
	if _wobble >= 0.0 and _shear != null:
		_shear.set_slices(_wobble_slices(bob))
	var hud := Palette.HUD
	var alpha := 0.35 if spent else 1.0
	var border := Color(hud, alpha)
	var fill := Palette.PANEL
	if dead:
		border = Palette.LOSS_DIM
		fill = Palette.PANEL
	# A soft shadow under the object, so the bob reads as height.
	Hud.fill_poly(self, Hud.cut(Rect2(Vector2(4, 8 + bob * 0.4), Vector2(FACE, FACE)), CUT), Color(0, 0, 0, 0.4))
	Hud.box(self, rect, CUT, fill, border, 3.0 if (locked and not spent) else 1.5)
	if _lit() and not dead:
		Hud.fill_poly(self, Hud.cut(rect.grow(-1.5), CUT), Color(hud, 0.24))
		Hud.stroke_poly(self, Hud.cut(rect, CUT), hud, 3.0)
	if locked and not spent and not dead:
		Hud.brackets(self, rect.grow(6.0), 14.0, hud, 1.5)
		draw_string(Hud.mono(), Vector2(0, FACE + 12.0), "LOCKED", HORIZONTAL_ALIGNMENT_CENTER, FACE, 10, hud)
	if charged and not spent and not dead:
		# Armed (the Swallowtail's muster): a second frame outside the first and the word, so the
		# charged die reads by its structure as well as the colour.
		Hud.stroke_poly(self, Hud.cut(rect.grow(4.0), CUT + 2.0), Palette.SELECT, 3.0)
		draw_string(Hud.mono(), Vector2(0, bob - 6.0), "CHARGED", HORIZONTAL_ALIGNMENT_CENTER, FACE, 10, Palette.SELECT)
	if face != null and slot > 0:
		# Which entry of the die this is, as a grey Roman numeral in the quotes' condensed
		# italic: quiet by its colour and its face rather than its size, and never a stat
		# (Ryan, 15 October). A reroll onto a copy shows by it; so does a stepping die's order.
		draw_string(Hud.quote(), SLOT_AT + Vector2(0, bob), Hud.roman(slot), HORIZONTAL_ALIGNMENT_LEFT, -1, SLOT_SIZE, Color(Palette.MUTED, alpha))
	if face == null or dead:
		if dead:
			Glyphs.draw(self, "blank", Vector2(FACE * 0.5, FACE * 0.5 + bob), 44, Palette.LOSS_DIM, 4.0)
		return
	var ink := Color(hud, alpha)
	var mono := Hud.mono()
	Glyphs.draw(self, Glyphs.primary_for(face), Vector2(FACE * 0.5, 34.0 + bob), 34, ink, 2.6)
	var num := shown_number if not shown_number.is_empty() else face.number_text()
	if face.disabled and dark > 0:
		# Dark with the turns left (the cooldown row, 14 October; Ryan's "turns", 26 October): the
		# count where the number sits and what it counts beneath, so it never reads as the
		# component's number.
		num = str(dark)
		draw_string(mono, Vector2(0, FACE - 9.0 + bob), "TURN LEFT" if dark == 1 else "TURNS LEFT", HORIZONTAL_ALIGNMENT_CENTER, FACE, 11, ink)
	var num_size := 28 if num.contains("–") else 38
	if _recalc >= 0.0:
		# The display recomputes this face: its ink dips a little and the frame flashes once;
		# the static itself is drawn last, over the whole die (`_draw_static`). The number
		# stays what it is and stays readable (Ryan, 23 September: a scramble here was wrong).
		var rt := _recalc / _recalc_for
		ink.a *= 0.75 + 0.25 * Hud.noise(int(_recalc * STATIC_RATE) * 0.7 + 0.3)
		Hud.stroke_poly(self, Hud.cut(rect.grow(-3.0), CUT), Color(Palette.INK, 0.5 * (1.0 - rt)), 1.0)
	draw_string(mono, Vector2(0, 92.0 + bob), num, HORIZONTAL_ALIGNMENT_CENTER, FACE, num_size, ink)
	if face.strikes > 1:
		# Blows per use, small, to the right of the number: "10 ×3" reads as a burst.
		var w := mono.get_string_size(num, HORIZONTAL_ALIGNMENT_CENTER, -1, num_size).x
		draw_string(mono, Vector2(FACE * 0.5 + w * 0.5 + 2.0, 92.0 + bob), "×%d" % face.strikes, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ink)
	var slot_x := 10.0
	if face.ammo > 0:
		# A forging machine's gun (the Musk Ox's, 21 October): its price in ammo where the heat
		# sits, the shells' mark beside it; struck through and DRY when the magazine cannot pay.
		var ac := Color(Palette.LOSS if face.dry else Palette.SELECT, alpha)
		Glyphs.draw(self, "ammo", Vector2(slot_x + 6.0, FACE - 13.0 + bob), 11, ac, 1.6)
		var ammo_text := ("%d DRY" if face.dry else "%d AMMO") % face.ammo
		draw_string(mono, Vector2(slot_x + 14.0, FACE - 9.0 + bob), ammo_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ac)
		var aw := mono.get_string_size(ammo_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		if face.dry:
			draw_line(Vector2(slot_x, FACE - 13.0 + bob), Vector2(slot_x + 16.0 + aw, FACE - 13.0 + bob), ac, 2.0)
		slot_x += aw + 22.0
	if face.heat > 0:
		var hc := Color(Palette.HEAT, alpha)
		var heat_text := "+%d HEAT" % face.heat
		draw_string(mono, Vector2(slot_x, FACE - 9.0 + bob), heat_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, hc)
		slot_x += mono.get_string_size(heat_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 8.0
	if face.volatile > 0 and not (face.disabled and dark > 0):
		# A hull cost (Volatile, a cost beside the heat since 26 October, Ryan: "converting it
		# from a keyword with a chip to a cost, alongside heat"): the hull's colour, what it spends, as
		# heat and shield costs wear theirs (Ryan, 30 October, agreeing Claude's lean).
		var vc := Color(Palette.HULL, alpha)
		var hull_text := "-%d HULL" % face.volatile
		draw_string(mono, Vector2(slot_x, FACE - 9.0 + bob), hull_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, vc)
		slot_x += mono.get_string_size(hull_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 8.0
	if face.shield_cost > 0 and not (face.disabled and dark > 0):
		# A shield cost (26 October): the shield's colour while the shield can pay; struck through
		# and SHORT in the red-red when it cannot and the entry is locked (the dry gun's pattern).
		var cc := Color(Palette.LOSS if face.short else Palette.SHIELD, alpha)
		var cost_text := ("-%d SHORT" if face.short else "-%d SHIELD") % face.shield_cost
		draw_string(mono, Vector2(slot_x, FACE - 9.0 + bob), cost_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, cc)
		var cw := mono.get_string_size(cost_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		if face.short:
			draw_line(Vector2(slot_x, FACE - 13.0 + bob), Vector2(slot_x + cw, FACE - 13.0 + bob), cc, 2.0)
		slot_x += cw + 8.0
	if face.shields > 0 and not (face.disabled and dark > 0):
		# The combined entry's second half (Ryan's go, 20 October): the shield it also gives, its
		# own glyph and number beside the heat slot, so the two numbers part by structure.
		var sc := Color(Palette.SHIELD, alpha)
		Glyphs.draw(self, "shield", Vector2(slot_x + 6.0, FACE - 13.0 + bob), 11, sc, 1.6)
		draw_string(mono, Vector2(slot_x + 14.0, FACE - 9.0 + bob), "%d" % face.shields, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, sc)
		slot_x += 14.0 + mono.get_string_size("%d" % face.shields, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 8.0
	if blast > 0 and face.kind == Face.Kind.VENT and not (face.disabled and dark > 0):
		# A vent's blast (the Whip Scorpion's Thermal Ejection Manifold, 22 October): spent on its
		# own machine it fires the heat it takes off at a random foe, so the die prints that blow
		# by its own mark, an arc landing in a burst, apart from the heat slot's word.
		var bc := Color(Palette.HEAT, alpha)
		Glyphs.draw(self, "blast", Vector2(slot_x + 7.0, FACE - 13.0 + bob), 13, bc, 1.8)
		draw_string(mono, Vector2(slot_x + 16.0, FACE - 9.0 + bob), "%d" % blast, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, bc)
	if locked and not spent:
		Glyphs.draw(self, "lock", Vector2(FACE - 20.0, 20.0 + bob), 14, hud, 2.0)
	# Annotation chips hugging the right edge, one per keyword, star for a unique effect. A
	# keyword a passive grants written out (the Boar's spill) is the star, never its own chip.
	var tags: Array[String] = []
	var struck: Array[int] = []   # the chips a shut gate strikes, by their place on the rail
	for k in face.keywords:
		if not face.printed.has(k):
			if shut.has(k):
				struck.append(tags.size())
			tags.append(Face.KEYWORD_NAMES[k])
	if face.has_unique_rule():
		tags.append("star")      # a rule printed on the entry: the hold reads it out
	if face.targets == Face.Target.SELF:
		tags.append("self")      # a piece that reaches only its own machine
	elif face.targets == Face.Target.ALLY:
		tags.append("ally")      # or only its allies
	if corrupted > 0 and face.kind != Face.Kind.BLANK:
		tags.append("corrupt")   # what a foe did to the entry, last on the rail, in its colour
	for i in range(tags.size()):
		var col := Glyphs.colour_for(tags[i])
		col.a = (_flicker(i) if animate else 1.0) * (0.45 if spent else 1.0)
		var chip_rect := Rect2(Vector2(FACE - CHIP.x + RAIL - 2.0, 8.0 + i * TAG_STEP + bob * 0.5), CHIP)
		if struck.has(i):
			col.a *= 0.45   # a shut gate: the keyword will not land on this foe
		Hud.box(self, chip_rect, 4.0, Color(Palette.BG, 0.94), col, 1.0)
		Glyphs.draw(self, tags[i], chip_rect.get_center(), 13, col, 1.8)
		if struck.has(i):
			# Struck through corner to corner, structure as well as the dimming (Ryan reads by
			# structure: never a mark parted by hue alone).
			draw_line(chip_rect.position + Vector2(2.0, CHIP.y - 2.0), chip_rect.position + Vector2(CHIP.x - 2.0, 2.0), Color(Palette.INK, 0.9), 2.5)
		if tags[i] == "corrupt" and corrupted > 1:
			draw_string(mono, chip_rect.position + Vector2(CHIP.x + 2.0, CHIP.y - 7.0), "×%d" % corrupted, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, col)
	if next_face != null:
		_draw_next(bob, tags.size())
	if _recalc >= 0.0:
		_draw_static(rect)


## A stepping die's next chamber (21 October): at the rail's foot, an arrow into a chip with
## that entry's primary glyph, so the dial (a reroll steps it) is read before it is turned. Its
## frame is dashed, unlike every keyword chip, so it never reads as one of this entry's.
func _draw_next(bob: float, above: int) -> void:
	var col := Color(Palette.HUD, (0.45 if spent else 1.0))
	var y := maxf(FACE - CHIP.y - 6.0, 8.0 + above * TAG_STEP)   # below the keyword chips, however many
	var chip_rect := Rect2(Vector2(FACE - CHIP.x + RAIL - 2.0, y + bob * 0.5), CHIP)
	Hud.fill_poly(self, Hud.cut(chip_rect, 4.0), Color(Palette.BG, 0.94))
	var corners := [chip_rect.position, Vector2(chip_rect.end.x, chip_rect.position.y), chip_rect.end, Vector2(chip_rect.position.x, chip_rect.end.y)]
	for k in range(4):
		var a: Vector2 = corners[k]
		var b: Vector2 = corners[(k + 1) % 4]
		var t := 0.0
		while t < 1.0:
			draw_line(a.lerp(b, t), a.lerp(b, minf(1.0, t + 0.18)), col, 1.2)
			t += 0.3
	var tip := chip_rect.position + Vector2(-3.0, CHIP.y * 0.5)
	draw_colored_polygon(PackedVector2Array([tip + Vector2(-7.0, -5.0), tip, tip + Vector2(-7.0, 5.0)]), col)
	Glyphs.draw(self, Glyphs.primary_for(next_face), chip_rect.get_center(), 13, col, 1.8)


## Static over the die's face while it is recomputed: the signal-drop noise a foe gets,
## more subtle, in the display's colour, no tag (Ryan, 23 September). Kept to the face
## itself, edge to edge and inside its chamfers: a dash near the cut top-left or bottom-right
## corner starts or stops where the cut does.
func _draw_static(face_rect: Rect2) -> void:
	var tick := int(_recalc * STATIC_RATE)
	for j in range(22):
		var yy := face_rect.position.y + 1.0 + Hud.noise(tick * 0.9 + j * 0.61) * (face_rect.size.y - 2.0)
		var x_min := face_rect.position.x + 1.0
		var x_max := face_rect.end.x - 1.0
		var from_top := yy - face_rect.position.y
		if from_top < CUT:
			x_min += CUT - from_top
		var from_bottom := face_rect.end.y - yy
		if from_bottom < CUT:
			x_max -= CUT - from_bottom
		var span := x_max - x_min
		var w := span * (0.4 + 0.6 * Hud.noise(tick * 0.4 + j * 0.83))
		var x0 := x_min + Hud.noise(tick * 1.7 + j * 0.23) * (span - w)
		draw_rect(Rect2(x0, yy, w, 1.0), Color(Palette.HUD, 0.12 + 0.25 * Hud.noise(tick + j * 0.5)))

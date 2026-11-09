class_name DieFaceView
extends Control

## A die drawn as an object under the tactical overlay. The face is a chamfered square that
## bobs gently; its keywords sit as small annotation chips hugging its right edge, one per
## keyword, bright and flickering now and then. On the face, as Ryan sketched it: the main mark
## large at the top centre saying what it is (a weapon's sight, equipment's gear, a shield, a
## vent's steam, the shield and the steam together) holding what it delivers (its number, or the
## status or keyword equipment lays), whom it is aimed at under it (an arrow or three hexes), its
## costs along the foot as marks and numbers (its cooldown's clock among them), the lock
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
## The double-tap window, from a tap's release to the next touch (Android's own measure, whose 0.3
## read as lag on a single tap): a tap lands this long after it lets go with no second touch.
## Ryan, 2 November: "Lower to 0.2 and I'll try again"; 9 November: "die face single press delay
## can be a bit faster, even". Counted to the second touch rather than its release, so the
## second press's own length no longer eats the window and a double-tap is no harder at 0.15.
const DOUBLE_TAP_SECONDS := 0.15

const FACE := 120.0        # the square face
const RAIL := 18.0         # how far the chips hang past the right edge
const CHIP := Vector2(26, 24)
const TAG_STEP := 28.0
const BOB_PX := 3.0
const CUT := 16.0
const FLICKER_PERIOD := 4.5   # seconds between dips, per chip
const SLOT_AT := Vector2(10, 28)   # the place's numeral, its baseline tucked under the cut corner, clear of the main mark
const SLOT_SIZE := 18
const MAIN_Y := 45.0       # the main mark's centre, what the entry delivers inside it, clear of the place's numeral
const MAIN_W := 60.0       # the sight's width, its ring holding NUMBER_ROOM, as wide as the gear (a strike's count beside it, not inside)
const COMBO_W := 60.0      # the shield with the steam, seated COMBO_DY lower (its top clear of the place's numeral)
const COMBO_DY := 0.0
const COMBO_SIZE := 24     # its two numbers, a size down so the pair has room (Ryan, 3 November: "The shield-vent combo is squished")
const SHIELD_W := 54.0     # the shield alone, seated SHIELD_DY lower, its top corner clear of the numeral (VIII)
const SHIELD_DY := 2.0
const GEAR_W := 60.0       # the gear's, its teeth weighing more than the sight's ticks, clear of the numeral too
## Every number a main mark holds is one size, the size the widest of them fits (Ryan, 3 November:
## "you can measure max width just with the multi-strikes text"; 4 November, the strikes beside
## the sight as equipment's stacks are: "Would let the crosshair fit better, wouldn't it, if we
## don't need a X in there?"): a two-digit blow, 30 pixels in the mono face at 28, the room 32; a
## test measures it. Past it (the Storm Petrel's blow and zap over a foe, "4+2") a number steps
## down until it fits.
const NUMBER_SIZE := 28
const NUMBER_ROOM := 32.0
const AIM_Y := 86.0        # whom it reaches, under the main mark, clear of the costs below (Ryan, 3 November: "leaving space for the bottom costs row to breathe")
const AIM_W := 34.0        # every targeting mark one width, the lines of fire and the three hexes alike (Ryan, 2 November)
const VENT_W := 60.0       # the vent's plate and its steam, its number in the plate (Glyphs.VENT_NUMBER)
const LINING := 4.0        # the frame's lining, this far inside its border (Ryan, 3 November: "The actual chamfered outer box of the die can be adjusted too")
const ACCENT := 9.0        # the arms of the accents outside the frame's square corners
const ACCENT_OUT := 3.5    # how far outside the border the accents stand
const BESIDE := Vector2(28.0, 30.0)   # what else a spend does, from the main mark's centre: its strikes, a status's stacks, a blast
const BESIDE_SIZE := 18    # its text, a size up so it reads (Ryan, 4 November: equipment's "X2 ... a bit hard to see")
const BESIDE_STEP := 19.0  # one above another
const PASSIVE_SIZE := 17   # a number in the passive's box at the rail's foot (passive_marks)
const PASSIVE_OUT := 18.0  # how far past the rail the passive's box hangs, clear of the costs along the foot (Ryan, 4 November: "can we move the passive box to the right?"; the gap to the next die is 52, to the screen's edge from the last 42)
const COST_Y := 111.0      # the costs' baseline along the foot, clear of the frame's lining (Ryan, 4 November: "Make sure the costs row doesn't touch the bottom")
const COST_ICON := 14.0    # a cost's mark
const COST_SIZE := 16      # and its number

var face: Face = null
var shown_number: String = ""   # what the blow will deal now, or against the foe it is held over (10 October)
var corrupted: int = 0       # Corrupted stacks on the entry showing: a chip in the enemy's colour, with the count
var dark: int = 0            # a dark entry (a cooldown, a foe's disable): the rounds it has left, this one included, its clock along the foot
var cooldown: int = -1       # the rounds a spend darkens it, its machine's passives in (Skirmish.cooldown_of); -1 reads the entry's own
var next_face: Face = null   # a stepping die's next chamber (the Cassowary's), in the passive box at the rail's foot; null for a die that rolls
var next_number: String = "" # the blow that next entry will deal now, as the screen reads it (Skirmish.shown_number_text); "" reads its own
var after_blow: int = -1     # the blow its machine's passive adds after the strikes (the Storm Petrel's), its number in the passive box; -1 reads the entry's own (Skirmish.after_blow off a foe)
var slot: int = 0            # the entry's place on its die, from one; 0 draws none
var locked: bool = false
var charged: bool = false      # armed for its charged form, a muster paid at the spend (the Swallowtail's): a double frame and the word above
var blast: int = 0             # a vent's blast on its own machine (the Whip Scorpion's): the blow it fires at a random foe, its mark and number in the passive box
var form_mark: String = ""     # "seal" or "unseal": spending the entry shuts its machine's shell or opens it (the Armadillo's Lockdown), a chip on the rail
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
var _second := false         # this touch came inside the window after a tap: its release is the double-tap
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
			_second = _press_at - _last_tap_at <= DOUBLE_TAP_SECONDS   # the window runs from the last tap's release to this touch
		else:
			if _dragging:
				drag_ended.emit(event.global_position)
			elif _holding:
				hold_released.emit()
			elif _pressed:
				var now := Time.get_ticks_msec() / 1000.0
				if _second:
					_second = false
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
	_dress(rect, border, not ((locked or charged) and not spent and not dead))
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
	# One standard face (Ryan, 2 November: "We need a standard format, using combined or layered
	# icons, that works for every component across the board and doesn't crowd the die"): one main
	# mark saying what it is, what it delivers inside it (3 November: "moving the number inside of
	# the icon and putting targeting underneath, since the targeting icons are narrower"), whom it
	# is aimed at under it, its costs along the foot as a mark and a number each, its keywords
	# down the rail.
	var mark := Glyphs.primary_for(face)
	var mc := Vector2(FACE * 0.5, MAIN_Y + bob)
	var dark_now := face.disabled and dark > 0
	var dip := 1.0
	if _recalc >= 0.0:
		# The display recomputes this face: its ink dips a little and the frame flashes once;
		# the static itself is drawn last, over the whole die (`_draw_static`). The number
		# stays what it is and stays readable (Ryan, 23 September: a scramble here was wrong).
		var rt := _recalc / _recalc_for
		dip = 0.75 + 0.25 * Hud.noise(int(_recalc * STATIC_RATE) * 0.7 + 0.3)
		ink.a *= dip
		Hud.stroke_poly(self, Hud.cut(rect.grow(-3.0), CUT), Color(Palette.INK, 0.5 * (1.0 - rt)), 1.0)
	var faded := func(c: Color) -> Color: return Color(c, c.a * alpha * dip)
	match mark:
		"vent":
			Glyphs.draw(self, "vent", mc, VENT_W, ink, 2.4)
		"ammo":
			pass   # a reload cools nothing: its shells and its number are the whole mark
		"blank":
			Glyphs.draw(self, "blank", mc + Vector2(0.0, 8.0), 40, ink, 3.0)
		"shield":
			Glyphs.draw(self, mark, mc + Vector2(0.0, SHIELD_DY), SHIELD_W, ink, 2.4)
		"shield_vent":
			Glyphs.draw(self, mark, mc + Vector2(0.0, COMBO_DY), COMBO_W, ink, 2.4)
		"equipment":
			Glyphs.draw(self, mark, mc, GEAR_W, ink, 2.4)
		_:
			Glyphs.draw(self, mark, mc, MAIN_W, ink, 2.4)
	# What it delivers, inside the mark: a weapon's blow (or what it will deal over the foe in
	# hand), a shield's shield, a vent's cooling under its steam, both for an entry that does both
	# (shield | cool, each under its own mark, in its own colour: Ryan, 3 November), a reload's
	# ammo by its shells; equipment what it grants or lays, its status's or its keyword's mark
	# (inside_effect), never a number (2 November: "Equipment don't generally need numbers").
	# What a weapon will deal now is the screen's to say (Skirmish.shown_number_text); every other
	# entry prints its own, a reload's ammo with no sign (Ryan, 2 November: no +/- on a die).
	var num := "" if dark_now else (shown_number if face.is_weapon() and not shown_number.is_empty() else die_number(face))
	var mono_px := func(t: String, room: float, top: int) -> int:
		var px := top
		while px > 12 and mono.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > room:
			px -= 1
		return px
	var beside: Array = []   # [mark, text, colour]: what else a spend does, small beside the main mark
	match mark:
		"equipment":
			var inside := inside_effect(face)
			if not inside.is_empty() and not dark_now:
				var col: Color = Glyphs.colour_for(inside) if inside == "star" else Terms.colour(inside)
				Glyphs.draw(self, chip_glyph(inside), mc, 22, faded.call(col), 2.2)
				if face.kind == Face.Kind.BUFF and face.buff_stacks > 1:
					beside.append(["", "×%d" % face.buff_stacks, faded.call(col)])
		"shield_vent":
			if not dark_now:
				var held := [str(face.power if face.kind == Face.Kind.SHIELD else face.shields), str(face.vents if face.kind == Face.Kind.SHIELD else face.power)]
				var half := COMBO_W * 0.5
				var px: int = mini(mono_px.call(held[0], half * 0.75, COMBO_SIZE), mono_px.call(held[1], half * 0.75, COMBO_SIZE))
				var at := mc + Vector2(0.0, COMBO_DY + 3.0)
				_number(mono, held[0], at + Vector2(-half * 0.46, 0.0), px, faded.call(Palette.SHIELD))
				draw_line(at + Vector2(0.0, -px * 0.36), at + Vector2(0.0, px * 0.4), faded.call(Palette.MUTED), 1.6)
				_number(mono, held[1], at + Vector2(half * 0.46, 0.0), px, faded.call(Palette.HEAT))
		"ammo":
			if not num.is_empty():
				var px: int = mono_px.call(num, NUMBER_ROOM, NUMBER_SIZE)   # its own room, beside its shells
				var w := mono.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
				var x0 := mc.x - (26.0 + w) * 0.5
				Glyphs.draw(self, "ammo", Vector2(x0 + 10.0, mc.y), 22, faded.call(Palette.SELECT), 2.2)
				_number(mono, num, Vector2(x0 + 26.0 + w * 0.5, mc.y), px, faded.call(Palette.SELECT))
		"weapon", "shield", "vent":
			if not num.is_empty():
				var text := num
				var at := mc + (Vector2(0.0, SHIELD_DY - 4.0) if mark == "shield" else (Vector2(0.0, VENT_W * 0.5 * Glyphs.VENT_NUMBER) if mark == "vent" else Vector2.ZERO))
				var col := Palette.SHIELD if mark == "shield" else (Palette.HEAT if mark == "vent" else Palette.HUD)
				_number(mono, text, at, mono_px.call(text, NUMBER_ROOM, NUMBER_SIZE), faded.call(col))
	# What else the spend does, small beside the main mark, each by its mark: a weapon's strikes (4
	# November: as equipment's stacks are, "how would that look for weapons?"), a status's stacks,
	# the ammo a vent also loads. What a machine's passive adds is its box's (passive_marks).
	if face.strikes > 1 and face.is_weapon() and not dark_now:
		beside.push_front(["", "×%d" % face.strikes, ink])
	if face.reloads_ammo > 0 and face.power > 0 and not dark_now:
		beside.append(["ammo", str(face.reloads_ammo), faded.call(Palette.SELECT)])
	for i in range(beside.size()):
		var a: Array = beside[i]
		var at := mc + BESIDE + Vector2(0.0, -i * BESIDE_STEP)
		var tx := at.x
		if not str(a[0]).is_empty():
			Glyphs.draw(self, str(a[0]), Vector2(at.x + 6.0, at.y - 6.0), 14, a[2], 1.8)
			tx += 15.0
		draw_string(mono, Vector2(tx, at.y), str(a[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, BESIDE_SIZE, a[2])
	# Whom it is aimed at, under the main mark, one width (Ryan, 2 and 3 November): a line of fire
	# breaking into dashes, straight (Direct) or lobbed (Indirect); the three hexes for a piece
	# spent on machines.
	var aim := Glyphs.aim_for(face)
	if not aim.is_empty():
		Glyphs.draw(self, aim, Vector2(FACE * 0.5, AIM_Y + bob), AIM_W, ink, 2.4 if aim in ["aim_direct", "aim_indirect", "aim_sweep"] else 1.8)
	var costs := cost_marks()
	var cx := 10.0
	for cst in costs:
		var cc := Color(cst[2], alpha)
		Glyphs.draw(self, str(cst[0]), Vector2(cx + 7.0, COST_Y - 6.0 + bob), COST_ICON, cc, 1.8)
		var t := str(cst[1])
		draw_string(mono, Vector2(cx + COST_ICON + 2.0, COST_Y + bob), t, HORIZONTAL_ALIGNMENT_LEFT, -1, COST_SIZE, cc)
		var tw := COST_ICON + 2.0 + mono.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, COST_SIZE).x
		if bool(cst[3]):
			draw_line(Vector2(cx - 1.0, COST_Y - 6.0 + bob), Vector2(cx + tw + 1.0, COST_Y - 6.0 + bob), cc, 2.0)
		cx += tw + 8.0
	if locked and not spent:
		Glyphs.draw(self, "lock", Vector2(FACE - 20.0, 20.0 + bob), 14, hud, 2.0)
	var tags := rail_tags()
	var struck: Array[int] = []   # the chips a shut gate strikes, by their place on the rail
	for i in range(tags.size()):
		if shut.has(Face.keyword_from_name(tags[i])):
			struck.append(i)
	for i in range(tags.size()):
		var col := Glyphs.colour_for(tags[i])
		col.a = (_flicker(i) if animate else 1.0) * (0.45 if spent else 1.0)
		var chip_rect := Rect2(Vector2(FACE - CHIP.x + RAIL - 2.0, 8.0 + i * TAG_STEP + bob * 0.5), CHIP)
		if struck.has(i):
			col.a *= 0.45   # a shut gate: the keyword will not land on this foe
		Hud.box(self, chip_rect, 4.0, Color(Palette.BG, 0.94), col, 1.0)
		Glyphs.draw(self, chip_glyph(tags[i]), chip_rect.get_center(), 13, col, 1.8)
		if struck.has(i):
			# Struck through corner to corner, structure as well as the dimming (Ryan reads by
			# structure: never a mark parted by hue alone).
			draw_line(chip_rect.position + Vector2(2.0, CHIP.y - 2.0), chip_rect.position + Vector2(CHIP.x - 2.0, 2.0), Color(Palette.INK, 0.9), 2.5)
		if tags[i] == "corrupt" and corrupted > 1:
			draw_string(mono, chip_rect.position + Vector2(CHIP.x + 2.0, CHIP.y - 7.0), "×%d" % corrupted, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, col)
	_draw_passive(bob, tags.size())
	if _recalc >= 0.0:
		_draw_static(rect)


## The frame dressed as the marks inside it are (Ryan, 3 November: "so the whole thing doesn't
## read cheap line drawing"): a lining inside its border, its chamfers kept, as every main mark
## wears one; accents standing outside its four corners (the accents inside "look a little like a
## mistake. Maybe they're accents on the outside"), an L off each square corner and a stroke off
## each cut one. A locked or a charged die wears its own frame outside instead (`accents` false).
func _dress(rect: Rect2, border: Color, accents: bool) -> void:
	Hud.stroke_poly(self, Hud.cut(rect.grow(-LINING), CUT - LINING * 0.42), Color(border, border.a * 0.3), 1.0)
	if not accents:
		return
	var p := rect.position
	var e := rect.end
	var o := ACCENT_OUT
	draw_polyline(PackedVector2Array([Vector2(e.x - ACCENT, p.y - o), Vector2(e.x + o, p.y - o), Vector2(e.x + o, p.y + ACCENT)]), border, 2.0)
	draw_polyline(PackedVector2Array([Vector2(p.x - o, e.y - ACCENT), Vector2(p.x - o, e.y + o), Vector2(p.x + ACCENT, e.y + o)]), border, 2.0)
	var off := Vector2(-1.0, -1.0).normalized() * o * 1.2
	var a0 := Vector2(p.x, p.y + CUT)
	var a1 := Vector2(p.x + CUT, p.y)
	draw_line(a0.lerp(a1, 0.18) + off, a0.lerp(a1, 0.82) + off, border, 2.0)
	var b0 := Vector2(e.x, e.y - CUT)
	var b1 := Vector2(e.x - CUT, e.y)
	draw_line(b0.lerp(b1, 0.18) - off, b0.lerp(b1, 0.82) - off, border, 2.0)


## A number centred on `c`, its digits' middle there.
func _number(font: Font, t: String, c: Vector2, px: int, col: Color) -> void:
	var w := font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	draw_string(font, Vector2(c.x - w * 0.5, c.y + font.get_ascent(px) * 0.36), t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, col)


## How much a spend does, as the die prints it inside its main mark: a weapon's blow or range, a
## shield's or a vent's number, the ammo a reload adds; nothing for equipment (Ryan, 2 November:
## "Equipment don't generally need numbers": what it grants or lays sits inside its gear) or a
## blank. A shield and a vent in one entry print both (the main mark's two halves).
static func die_number(f: Face) -> String:
	if f == null or f.kind == Face.Kind.BUFF:
		return ""
	if f.kind == Face.Kind.VENT and f.power <= 0 and f.reloads_ammo > 0:
		return str(f.reloads_ammo)
	return f.number_text()


## The mark the number wears before it when it counts something other than its kind's own: a
## reload's ammo, its shells (the Musk Ox's Quick Reload, a vent that cools nothing, so its
## shells are its whole main mark); "" else.
static func number_mark(f: Face) -> String:
	if f != null and f.kind == Face.Kind.VENT and f.power <= 0 and f.reloads_ammo > 0:
		return "ammo"
	return ""


## What equipment holds inside its gear (Ryan, 3 November: the number inside the main mark, and
## equipment has none): the status a buff grants (its term's id); a debuff's first keyword that
## does something to a foe, in content's order (a reach, an area or Rapid stays on the rail); the
## star when what it does is a rule of its own (the Lorentz Contractor's mines, the Reveille Horn's
## charged turn); "" for any other entry. The rail never shows it twice.
static func inside_effect(f: Face) -> String:
	if f == null or not f.is_equipment():
		return ""
	if f.kind == Face.Kind.BUFF:
		var granted := status_chip(f)
		if not granted.is_empty():
			return granted
	else:
		for k in f.keywords:
			if f.printed.has(k):
				continue
			var name: String = Face.KEYWORD_NAMES[k]
			if Terms.has(name) and Terms.group(name) != "plain" and not Terms.glyph(name).is_empty():
				return name
	return "star" if f.has_unique_rule() else ""


## The status a piece of equipment spent on a machine grants, as its mark inside the gear and
## beside its readout line (its term's id; "" for any other entry or a status the list does not
## define).
static func status_chip(f: Face) -> String:
	if f == null or f.kind != Face.Kind.BUFF or f.buff_status.is_empty():
		return ""
	var term := Terms.of_status(f.buff_status)
	return term if not term.is_empty() and not Terms.glyph(term).is_empty() else ""


## The annotation chips hugging the right edge, top down: one per keyword, the star for a unique
## effect, the shell's seal or opening, a corruption last. Each is a term's id or a glyph's
## (chip_glyph). What equipment grants or lays sits inside its gear (inside_effect), never here
## too; a keyword a passive grants written out (the Boar's spill) is the star, never its own chip;
## whom it reaches is no chip (the targeting mark under the main mark, Glyphs.aim_for).
func rail_tags() -> Array[String]:
	var tags: Array[String] = []
	if face == null:
		return tags
	var inside := inside_effect(face)
	for k in face.keywords:
		if not face.printed.has(k) and Face.KEYWORD_NAMES[k] != inside:
			tags.append(Face.KEYWORD_NAMES[k])
	if face.has_unique_rule() and inside != "star":
		tags.append("star")      # a rule printed on the entry: the hold reads it out
	if not form_mark.is_empty():
		tags.append(form_mark)   # it seals its machine, or opens it (the Armadillo's, 2 November)
	if corrupted > 0 and face.kind != Face.Kind.BLANK:
		tags.append("corrupt")   # what a foe did to the entry, last on the rail, in its colour
	return tags


## The glyph a rail chip draws: a term's icon (a status's, Overcharged's), else the id itself (a
## keyword's, the star, the seal, a corruption).
static func chip_glyph(tag: String) -> String:
	return Terms.glyph(tag) if Terms.has(tag) and not Terms.glyph(tag).is_empty() else tag


## Its costs along the foot, [mark, number, colour, struck] each, no word and no sign (Ryan, 2
## November: "For costs (heat, shield, hull), don't spell out the word. Use an icon + number. We
## don't need +/- symbols either"; "Cooldown should be a cost in the bottom section as well"): a
## forging gun's ammo, the heat that reaches the gauge, the hull, a shield cost, the rounds it goes
## dark; struck through in the red-red when its pool cannot pay (DRY, SHORT). A dark entry shows
## its clock there with the turns it has left. Only what must be paid stands here: the shield a
## passive pays a weapon's heat with is no cost, since the spend goes ahead without it, its number
## the passive box's (Ryan, 4 November: "Storm petrel having shield as a cost isn't entirely
## correct, since it uses up the shield it has but still let's the attack go, unlike a 'true'
## shield cost ... the passive shield cost can't go there").
func cost_marks() -> Array:
	var costs: Array = []
	if face == null or dead:
		return costs
	if face.disabled and dark > 0:
		costs.append(["cooldown", dark, Palette.INK, false])
		return costs
	if face.ammo > 0:
		costs.append(["ammo", face.ammo, Palette.LOSS if face.dry else Palette.SELECT, face.dry])
	if face.heat > 0:
		costs.append(["heat", face.heat, Palette.HEAT, false])
	if face.volatile > 0:
		costs.append(["hull", face.volatile, Palette.HULL, false])
	if face.shield_cost > 0:
		costs.append(["shield", face.shield_cost, Palette.LOSS if face.short else Palette.SHIELD, face.short])
	var cd := cooldown if cooldown >= 0 else face.cooldown_rounds()
	if cd > 0:
		costs.append(["cooldown", cd, Palette.INK, false])
	return costs


## What the machine's passive adds to the entry, a box each, [mark, text, colour] (Ryan, 4
## November: "Can't we just put the number in the cassowary-type box, call that the 'passive helper
## box' for all these types of effects?"): a stepping die's next chamber, its main mark (the
## Cassowary's); the blow the passive adds after the strikes, its number beside the shield's mark
## in the shield's colour, since the shield pays it, no sign (the Storm Petrel's: "that's not a
## mechanic term, it doesn't need an icon nor should it be using the shock icon", then "next to, a
## shield icon ... or at least colour the number shield colour"; "the tap popup will clarify");
## over a foe the blow's share with that foe's armour off, as the main number is; a vent's blast at a random
## foe, its mark and number in heat's colour, since a bare number beside a vent would read as
## more cooling (the Whip Scorpion's). The readout heads its line for each with the same box
## (EntryReadout.passive_mark).
func passive_marks() -> Array:
	var out: Array = []
	if face == null or dead:
		return out
	var dark_now := face.disabled and dark > 0
	if not dark_now:
		var after := after_blow if after_blow >= 0 else Skirmish.after_blow(null, face)
		if after > 0 and face.is_weapon():
			out.append(["shield", str(after), Palette.SHIELD])   # by the shield's mark, in its colour, no sign (Ryan, 4 November: "can we fit the number inside, or next to, a shield icon in the helper box? or at least colour the number shield colour?")
		if blast > 0 and face.kind == Face.Kind.VENT:
			out.append(["blast", str(blast), Palette.HEAT])
	if next_face != null:
		out.append(next_mark(next_face, next_number))
	return out


## A stepping die's next entry as its passive box shows it (Ryan, 4 November: "looks a little muddy
## for some icons and not all that useful ... Maybe icon+face number?"): its main mark drawn small
## and the number that entry will show (`shown`, the screen's live blow for a weapon; else its
## own), both in its kind's colour as the box's other marks wear their source's; a shield and a
## vent in one entry its two numbers alone in their colours, no mark ("since it will get wide
## otherwise"); for equipment, which shows no number, what it grants or lays, by its mark; a blank
## its cross. A reload is the Musk Ox's alone and never steps ("cassowary won't have reload"), so
## it has no form here of its own.
static func next_mark(nf: Face, shown: String = "") -> Array:
	if nf == null:
		return []
	var mark := Glyphs.primary_for(nf)
	match mark:
		"blank":
			return ["blank", "", Palette.HUD]
		"equipment":
			# Its gear and what it grants or lays where a number would stand (Ryan, 4 November: "Why
			# drop the equipment gear icon?": the effect's mark alone retired, every kind wearing its
			# own mark there).
			var inside := inside_effect(nf)
			if inside.is_empty():
				return ["equipment", "", Palette.HUD]
			var col: Color = Glyphs.colour_for(inside) if inside == "star" else Terms.colour(inside)
			return ["equipment", [["", col, chip_glyph(inside)]], Palette.HUD]
		"shield":
			return ["shield", die_number(nf), Palette.SHIELD]
		"shield_vent":
			var held := [str(nf.power if nf.kind == Face.Kind.SHIELD else nf.shields), str(nf.vents if nf.kind == Face.Kind.SHIELD else nf.power)]
			return ["", [[held[0], Palette.SHIELD], ["|", Palette.MUTED], [held[1], Palette.HEAT]], Palette.HUD]
		"vent":
			return ["vent", die_number(nf), Palette.HEAT]
		"weapon":
			return ["weapon", shown if not shown.is_empty() else die_number(nf), Palette.HUD]
	return [mark, die_number(nf), Palette.HUD]


## A passive box's text as runs of [text, colour] or [text, colour, glyph]: a plain string in the
## mark's ink, or the runs it already is (a shield and a vent's two numbers; equipment's effect, a
## glyph standing where a number would).
static func passive_runs(text: Variant, ink: Color) -> Array:
	if text is Array:
		return text
	return [[str(text), ink]] if not str(text).is_empty() else []


## How wide one run of a passive box's text is, at `px` in `font`: a glyph run its mark's room.
static func run_width(run: Array, font: Font, px: int) -> float:
	if run.size() > 2 and not str(run[2]).is_empty():
		return float(px)
	return font.get_string_size(str(run[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x


## A run of a passive box's text drawn at `at`, its baseline's left: a glyph run its mark, centred
## on the text's middle, else its text.
static func draw_run(ci: CanvasItem, run: Array, at: Vector2, font: Font, px: int, ink: Color) -> void:
	if run.size() > 2 and not str(run[2]).is_empty():
		Glyphs.draw(ci, str(run[2]), at + Vector2(px * 0.5, -font.get_ascent(px) * 0.36), px * 0.9, ink, 1.7)
	else:
		ci.draw_string(font, at, str(run[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, px, ink)


## A passive box's text as one string, its runs joined.
static func passive_plain(text: Variant) -> String:
	var out := ""
	for r in passive_runs(text, Palette.HUD):
		out += str(r[0])
	return out


## The passive's boxes at the rail's foot, the lowest first and the rest above it, below the keyword
## chips however many (21 October, the next chamber's first): a dashed frame, unlike every keyword
## chip, so it never reads as one of the entry's own, with an arrow into it; rectangular, as wide
## as what it holds ("It also doesn't have to be square, since it's not a true chip").
func _draw_passive(bob: float, above: int) -> void:
	var marks := passive_marks()
	if marks.is_empty():
		return
	var frame := Color(Palette.HUD, (0.45 if spent else 1.0))
	var mono := Hud.mono()
	var y := maxf(FACE - CHIP.y - 6.0, 8.0 + (above + marks.size() - 1) * TAG_STEP)
	for m in marks:
		var glyph := str(m[0])
		var ink := Color(m[2] as Color, frame.a)
		var runs := passive_runs(m[1], ink)
		var tw := 0.0
		for r in runs:
			tw += run_width(r, mono, PASSIVE_SIZE)
		var inner := (16.0 if not glyph.is_empty() else 0.0) + (3.0 if not glyph.is_empty() and tw > 0.0 else 0.0) + tw
		var w := maxf(CHIP.x, inner + 12.0)
		var box := Rect2(Vector2(FACE + RAIL - 2.0 + PASSIVE_OUT - w, y + bob * 0.5), Vector2(w, CHIP.y))
		Hud.fill_poly(self, Hud.cut(box, 4.0), Color(Palette.BG, 0.94))
		var corners := [box.position, Vector2(box.end.x, box.position.y), box.end, Vector2(box.position.x, box.end.y)]
		for k in range(4):
			var a: Vector2 = corners[k]
			var b: Vector2 = corners[(k + 1) % 4]
			var step := 7.0 / maxf(1.0, a.distance_to(b))   # dashes about as long whatever the side
			var t := 0.0
			while t < 1.0:
				draw_line(a.lerp(b, t), a.lerp(b, minf(1.0, t + step * 0.6)), frame, 1.2)
				t += step
		var tip := box.position + Vector2(-3.0, CHIP.y * 0.5)
		draw_colored_polygon(PackedVector2Array([tip + Vector2(-7.0, -5.0), tip, tip + Vector2(-7.0, 5.0)]), frame)
		var x := box.get_center().x - inner * 0.5
		if not glyph.is_empty():
			Glyphs.draw(self, glyph, Vector2(x + 8.0, box.get_center().y), 15, ink, 1.8)
			x += 19.0
		for r in runs:
			draw_run(self, r, Vector2(x, box.get_center().y + mono.get_ascent(PASSIVE_SIZE) * 0.36), mono, PASSIVE_SIZE, Color(r[1] as Color, frame.a))
			x += run_width(r, mono, PASSIVE_SIZE)
		y -= TAG_STEP


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

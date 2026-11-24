class_name AimLayer
extends Control

## The aim of a die in hand (Ryan, 22 November: "when dragging a die, the finger covers the
## preview making it worthless. I think instead of dragging the die, it stays stationary, and
## instead we drag a targeting crosshairs, with a dashed line tethering it to the center of the
## die face"): the die stays in its tray showing what it will deal, a crosshair rides the finger,
## and a dashed tether runs between them. Over somewhere the die may be spent the crosshair locks
## (drawn in, heavier, bracket corners breathing round it); a spend
## waiting on its second target (a Swap) keeps the crosshair pinned on its first.
##
## The tether runs from the die's middle, over the die, to the crosshair (Ryan, 24 November: "lock
## in 'over' for the tether and remove the control"). The whole aim is drawn in the HUD's colour,
## and heavy corners wrap the die's own face, never the chips on its rail (24 November). `die` is
## the face's rect and `to` the finger, in this layer's space; nothing shows while `active` is false.

## The crosshair rides under the finger, large, so it shows all round a fingertip (Ryan, 22
## November: "Crosshair under finger, but it can be large for visibility"; 24 November: "can be
## bigger. Don't shrink the reticle when hovering a target").
const RADIUS := 70.0        # its ring, the same over a target, its brackets outside it there
const DASH := 12.0
const GAP := 8.0
const TETHER_W := 4.0
const RATE := 6.0           # the dashes' crawl toward the crosshair and the lock's breath, radians a second
const CORNER := 16.0        # the arms of the die's corners, short of the chips at the rail's head and foot
const CORNER_OUT := 3.0     # how far outside the face they stand

var active := false
var from := Vector2.ZERO
var die := Rect2()          # the die in hand's rect
var to := Vector2.ZERO
var locked := false         # over somewhere the die may be spent
var pinned := false         # held on a Swap's first target
var colour := Color.WHITE


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func aim(die_rect: Rect2, at_to: Vector2, is_locked: bool, col: Color, is_pinned: bool = false) -> void:
	active = true
	die = die_rect
	from = die_rect.get_center()
	to = at_to
	locked = is_locked
	pinned = is_pinned
	colour = col
	set_process(true)
	queue_redraw()


func clear() -> void:
	if not active:
		return
	active = false
	set_process(false)
	queue_redraw()


func _process(_delta: float) -> void:
	if active:
		queue_redraw()


func _draw() -> void:
	if not active:
		return
	var t := Time.get_ticks_msec() / 1000.0
	var dark := Color(Palette.BG, 0.85)
	var col := colour if locked or pinned else Color(colour, 0.85)
	var r := RADIUS
	# The tether: dashes from the die's middle to the crosshair's ring, crawling toward it, each on
	# a dark edge so it holds on the sky, the field, the tray and the die alike.
	var span := to - from
	var length := span.length()
	var dir := span / maxf(length, 0.001)
	if length > r + 4.0:
		var run := length - r - 2.0
		var d := fmod(t * RATE * 6.0, DASH + GAP) - (DASH + GAP)
		while d < run:
			var a := maxf(d, 0.0)
			var b := minf(d + DASH, run)
			if b > a:
				draw_line(from + dir * a, from + dir * b, dark, TETHER_W + 3.0)
				draw_line(from + dir * a, from + dir * b, col, TETHER_W)
			d += DASH + GAP
	# The die in hand: heavy corners round it.
	Hud.brackets(self, die.grow(CORNER_OUT), CORNER, dark, 7.0)
	Hud.brackets(self, die.grow(CORNER_OUT), CORNER, col, 4.0)
	# The crosshair: a ring, four ticks reaching in, and a dot at its heart; locked, heavier, with
	# bracket corners breathing round it.
	var w := 5.0 if locked or pinned else 4.0
	draw_arc(to, r, 0.0, TAU, 48, dark, w + 3.0, true)
	draw_arc(to, r, 0.0, TAU, 48, col, w, true)
	for k in range(4):
		var u := Vector2.RIGHT.rotated(k * PI * 0.5)
		draw_line(to + u * (r + 9.0), to + u * (r * 0.45), dark, w + 3.0)
		draw_line(to + u * (r + 9.0), to + u * (r * 0.45), col, w)
	draw_circle(to, 6.0, dark)
	draw_circle(to, 4.0, col)
	if locked or pinned:
		var breath := 0.5 + 0.5 * sin(t * RATE)
		var box := Rect2(to - Vector2.ONE * (r + 14.0 + 5.0 * breath), Vector2.ONE * 2.0 * (r + 14.0 + 5.0 * breath))
		Hud.brackets(self, box, 20.0, dark, 8.0)
		Hud.brackets(self, box, 20.0, col, 5.0)


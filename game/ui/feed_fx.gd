class_name FeedFX
extends Control

## The display reading the fight (Ryan, 23 September): every few seconds one brief,
## one-shot analysis event on a random unit or die, so the skirmish HUD feels like a feed
## being analysed in real time rather than a print. Infrequent and varied on purpose, so it
## never becomes a rhythm and never competes with the pending-gauge pulse. The events:
##
##   scanbox   bracket corners settle onto a foe, a meter fills beneath it, bytes tick above
##   databox   a small telemetry box beside a foe, three lines of gibberish, its leader ending
##             in a select box that moves between parts of the foe
##   readout   a live chart beside a machine: bars rolling in on a fixed leader
##   recalc    static runs across a die's face and its frame flashes once; the number holds
##   tear      a foe's picture tears for a quarter second (the unit's own glitch)
##   signal    a foe's signal drops: the picture fades under static, "SIG LOST"
##
## The host gives three callables returning what is alive right now; the tear and signal
## events go off with the glitch setting. Draws over the units, under the panels; takes no
## input. Nothing here changes state.

var foe_views: Callable = Callable()    # -> Array of UnitView
var mech_views: Callable = Callable()   # -> Array of UnitView
var dice: Callable = Callable()         # -> Array of DieFaceView

const GAP_MIN := 4.0
const GAP_MAX := 9.0
const WEIGHTS := {"scanbox": 3, "databox": 3, "readout": 2, "recalc": 2, "tear": 2, "signal": 1}
# Drawn out (Ryan, 23 September: the first cut, at a second or under, was too quick to read).
const DURATION := {"scanbox": 2.6, "databox": 2.8, "readout": 2.8, "recalc": 0.7, "tear": 0.5, "signal": 1.3}
const SETTLE := 0.35        # seconds the brackets and the boxes take to land
const SCAN_HOLD := 0.7      # the scanbox's meter fills over this share of its time, then it blinks "complete"
const BOX := Vector2(72.0, 48.0)     # the foe's telemetry box
const CHART := Vector2(96.0, 54.0)   # the machine's live chart
const READ_EVERY := 0.9     # a telemetry box moves to another part of the unit this often
## RIFTGATE_FEED_DEBUG=1: an event every half second or so, and the ground tears every
## couple of seconds, to judge them by eye.
static var DEBUG := OS.get_environment("RIFTGATE_FEED_DEBUG") == "1"

var _wait := 3.0
var _ev: Dictionary = {}   # type, view, t, dur, salt
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rng.randomize()
	set_process(true)


func _process(delta: float) -> void:
	if not _ev.is_empty():
		_ev["t"] += delta
		if _ev["t"] >= _ev["dur"] or not is_instance_valid(_ev["view"]):
			_ev = {}
			_wait = _rng.randf_range(0.4, 0.9) if DEBUG else _rng.randf_range(GAP_MIN, GAP_MAX)
		queue_redraw()
		return
	_wait -= delta
	if _wait <= 0.0:
		_start()


## Start one event of `type` now (screenshots and tests).
func force(type: String) -> void:
	_ev = {}
	_start(type)


## Pick an event by weight and a live target for it; a kind with no target waits a second.
func _start(forced: String = "") -> void:
	var glitch_ok := bool(Settings.display.get("glitch", true))
	var pool: Array = []
	for kind in WEIGHTS.keys():
		if not glitch_ok and kind in ["tear", "signal"]:
			continue
		for i in range(int(WEIGHTS[kind])):
			pool.append(kind)
	var type: String = forced if DURATION.has(forced) else pool[_rng.randi() % pool.size()]
	var view: Control = null
	match type:
		"scanbox", "databox", "tear", "signal":
			view = _pick(foe_views)
		"readout":
			view = _pick(mech_views)
		"recalc":
			view = _pick(dice)
	if view == null:
		_wait = 1.0
		return
	_ev = {"type": type, "view": view, "t": 0.0, "dur": float(DURATION[type]), "salt": int(_rng.randi() % 1000)}
	if type == "databox":
		# The parts the box reads in turn: points on the drawing, as fractions of it.
		var spots: Array = []
		for i in range(3):
			spots.append(Vector2(_rng.randf_range(0.2, 0.8), _rng.randf_range(0.15, 0.85)))
		_ev["spots"] = spots
	match type:
		"tear":
			view.glitch("tear", _ev["dur"])
		"signal":
			view.glitch("drop", _ev["dur"])
		"recalc":
			view.recalc(_ev["dur"])
	queue_redraw()


func _pick(source: Callable) -> Control:
	if not source.is_valid():
		return null
	var list: Array = source.call()
	if list.is_empty():
		return null
	return list[_rng.randi() % list.size()]


## A unit's drawing, in this overlay's pixels (the overlay fills the screen the views sit on).
func _unit_rect(v: UnitView) -> Rect2:
	var r := v.drawing_rect()
	return Rect2(v.position + r.position, r.size)


func _draw() -> void:
	if _ev.is_empty():
		return
	var v: Control = _ev["view"]
	if not is_instance_valid(v) or not v.visible:
		return
	var secs: float = _ev["t"]
	var t: float = secs / _ev["dur"]
	var frame := int(Time.get_ticks_msec() / 90)
	var salt: int = _ev["salt"]
	var hud := Palette.HUD
	var mono := Hud.mono()
	# In over a few frames, out over the last sixth.
	var a := minf(1.0, secs * 10.0) * (1.0 if t < 0.84 else (1.0 - t) / 0.16)
	var settle := clampf(secs / SETTLE, 0.0, 1.0)
	match _ev["type"]:
		"scanbox":
			var r := _unit_rect(v)
			var grow := 4.0 + 14.0 * (1.0 - settle)
			# The meter fills, then everything blinks a few times: scan complete (Ryan, 23
			# September), and it is gone on the last blink.
			var done := t >= SCAN_HOLD
			var sa := a
			var label := Hud.hex_bytes(3, frame, salt)
			if done:
				var blink := int((secs - SCAN_HOLD * _ev["dur"]) / 0.14)
				sa = 1.0 if blink % 2 == 1 else 0.12
				label = "SCAN OK"
			Hud.brackets(self, r.grow(grow), 10.0, Color(hud, sa), 1.5)
			# The meter and the bytes sit top-left, clear of the intent chip below the foe and
			# of its gauge top-right.
			var meter := Rect2(r.position.x - 4.0, r.position.y - grow - 4.0, r.size.x * 0.55, 3.0)
			draw_rect(meter, Color(hud, 0.25 * sa))
			draw_rect(Rect2(meter.position, Vector2(meter.size.x * minf(1.0, t / SCAN_HOLD), meter.size.y)), Color(hud, sa))
			draw_string(mono, Vector2(r.position.x - 4.0, r.position.y - grow - 8.0), label, HORIZONTAL_ALIGNMENT_LEFT, r.size.x + 8.0, 10, Color(hud, sa))
		"databox":
			var r := _unit_rect(v)
			# The box reads one part of the foe at a time: the leader ends in a small select
			# box on it and moves on every READ_EVERY seconds, the lines changing with it.
			var spots: Array = _ev["spots"]
			var which := int(secs / READ_EVERY) % spots.size()
			var spot: Vector2 = r.position + (spots[which] as Vector2) * r.size
			var s2 := salt + which * 17
			var lines: Array[String] = ["TRK %02X" % (s2 % 256), Hud.hex_bytes(2, frame, s2), "SIG .%02d" % (absi(hash(frame * 3 + s2)) % 100)]
			# Out gently: the box fades over the last third of a second and the leader draws back.
			var fade := clampf((_ev["dur"] - secs) / 0.35, 0.0, 1.0) * minf(1.0, secs * 10.0)
			var right := r.end.x + 14.0 + BOX.x <= size.x
			var bx := r.end.x + 14.0 if right else r.position.x - 14.0 - BOX.x
			var by := clampf(r.position.y + 6.0, 0.0, size.y - BOX.y)
			var box := Rect2(bx, by, BOX.x, BOX.y)
			Hud.box(self, box, 5.0, Color(Palette.BG, 0.9 * fade), Color(hud, 0.85 * fade), 1.0)
			var from := Vector2(bx if right else bx + BOX.x, by + 9.0)
			var reach := settle * fade
			var to := from.lerp(spot, reach)
			draw_line(from, to, Color(hud, 0.7 * fade), 1.0)
			if reach > 0.95:
				Hud.brackets(self, Rect2(spot - Vector2(6.0, 6.0), Vector2(12.0, 12.0)), 4.0, Color(hud, fade), 1.2)
			for i in range(lines.size()):
				draw_string(mono, Vector2(bx + 7.0, by + 15.0 + i * 14.0), lines[i], HORIZONTAL_ALIGNMENT_LEFT, BOX.x - 14.0, 10, Color(hud, fade))
		"readout":
			# A machine's readout is a live chart (Ryan, 23 September: not the foe's box
			# again): a system tag over a row of bars that roll in from the right, one every
			# tenth of a second, on a fixed leader to the machine's side.
			var r := _unit_rect(v)
			var fade := clampf((_ev["dur"] - secs) / 0.35, 0.0, 1.0) * minf(1.0, secs * 10.0)
			var right := r.end.x + 14.0 + CHART.x <= size.x
			var bx := r.end.x + 14.0 if right else r.position.x - 14.0 - CHART.x
			var by := clampf(r.get_center().y - CHART.y * 0.5, 0.0, size.y - CHART.y)
			var box := Rect2(bx, by, CHART.x, CHART.y)
			Hud.box(self, box, 5.0, Color(Palette.BG, 0.9 * fade), Color(hud, 0.85 * fade), 1.0)
			draw_string(mono, Vector2(bx + 7.0, by + 13.0), "SYS %02X" % (salt % 256), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(hud, fade))
			draw_string(mono, Vector2(bx, by + 13.0), "%3d" % (absi(hash(int(secs / 0.1) + salt)) % 100 + 400), HORIZONTAL_ALIGNMENT_RIGHT, CHART.x - 7.0, 10, Color(hud, 0.8 * fade))
			var chart := Rect2(bx + 7.0, by + 19.0, CHART.x - 14.0, CHART.y - 26.0)
			draw_line(Vector2(chart.position.x, chart.end.y), chart.end, Color(hud, 0.4 * fade), 1.0)
			var nbars := 16
			var bw := chart.size.x / nbars
			var step := int(secs / 0.1)
			for i in range(nbars):
				var h := chart.size.y * (0.1 + 0.9 * Hud.noise((step + i) * 0.61 + salt * 0.013))
				draw_rect(Rect2(chart.position.x + i * bw + 1.0, chart.end.y - h, bw - 2.0, h), Color(hud, (0.45 + 0.55 * float(i) / nbars) * fade))
			var from := Vector2(bx if right else bx + CHART.x, by + CHART.y * 0.5)
			var to := Vector2(r.end.x if right else r.position.x, by + CHART.y * 0.5)
			draw_line(from, from.lerp(to, settle), Color(hud, 0.7 * fade), 1.0)
		_:
			pass   # tear, signal, recalc: the unit or die draws itself

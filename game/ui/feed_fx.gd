class_name FeedFX
extends Control

## The display reading the fight (Ryan, 23 September): brief one-shot analysis events on
## random units and dice, so the skirmish HUD feels like a feed being analysed in real time
## rather than a print. Infrequent and varied on purpose, so it never becomes a rhythm and
## never competes with the pending-gauge pulse. Two independent lanes, one for the foes and
## one for the machines and dice, each with its own clock (Ryan, 23 September: on one clock
## the foes, having more kinds, took most of the turns and the bottom of the screen went
## quiet). The events:
##
##   foe lane
##   scanbox   bracket corners settle onto a foe, a meter fills, bytes tick, then it blinks "SCAN OK"
##   databox   a small telemetry box beside a foe, three lines of gibberish, its leader ending
##             in a select box that moves between parts of the foe
##   tear      a foe's picture tears for half a second (the unit's own glitch)
##   signal    a foe's signal drops: the picture fades under static, a plated "SIG LOST" blinks
##
##   ally lane
##   readout   a live chart beside a machine: bars rolling in on a fixed leader
##   levels    three chunky horizontal bars beside a machine, growing and shrinking like an equaliser
##   recalc    static runs across a die's face and its frame flashes once; the number holds
##   wobble    a die's picture jolts and tilts for half a second, as a torn sprite's slices jump
##
## The host gives three callables returning what is alive right now; the tear and signal
## events go off with the glitch setting. Draws over the units, under the panels; takes no
## input. Nothing here changes state.

var foe_views: Callable = Callable()    # -> Array of UnitView
var mech_views: Callable = Callable()   # -> Array of UnitView
var dice: Callable = Callable()         # -> Array of DieFaceView

## Seconds between two events on a lane, drawn evenly between these (5 to 11 until 23 November:
## "Reduce the base frequency of flavour animations in the skirmish, slightly").
const GAP_MIN := 6.0
const GAP_MAX := 13.0
const LANES := {
	"foe": {"scanbox": 3, "databox": 3, "tear": 2, "signal": 1},
	"ally": {"readout": 3, "levels": 2, "recalc": 3, "wobble": 2},
}
# Drawn out (Ryan, 23 September: the first cut, at a second or under, was too quick to read).
const DURATION := {"scanbox": 2.6, "databox": 2.8, "readout": 3.6, "levels": 3.6, "recalc": 0.7, "wobble": 0.6, "tear": 0.5, "signal": 1.3}
const SETTLE := 0.35        # seconds the brackets and the boxes take to land
const SCAN_HOLD := 0.7      # the scanbox's meter fills over this share of its time, then it blinks "complete"
const BOX := Vector2(72.0, 48.0)     # the foe's telemetry box
const CHART := Vector2(68.0, 54.0)   # the machine's live chart and its levels
const READ_EVERY := 0.9     # a telemetry box moves to another part of the unit this often
## RIFTGATE_FEED_DEBUG=1: an event every half second or so on each lane, and the ground
## tears every couple of seconds, to judge them by eye.
static var DEBUG := OS.get_environment("RIFTGATE_FEED_DEBUG") == "1"

var _lanes: Dictionary = {   # lane -> {wait, ev}; ev: type, view, t, dur, salt, (spots)
	"foe": {"wait": 3.0, "ev": {}},
	"ally": {"wait": 5.5, "ev": {}},
}
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rng.randomize()
	set_process(true)


func _process(delta: float) -> void:
	var busy := false
	for lane in _lanes.keys():
		var st: Dictionary = _lanes[lane]
		var ev: Dictionary = st["ev"]
		if not ev.is_empty():
			ev["t"] += delta
			if ev["t"] >= ev["dur"] or not is_instance_valid(ev["view"]):
				st["ev"] = {}
				st["wait"] = _rng.randf_range(0.4, 0.9) if DEBUG else _rng.randf_range(GAP_MIN, GAP_MAX)
			busy = true
			continue
		st["wait"] -= delta
		if st["wait"] <= 0.0:
			_start(lane)
			busy = true
	if busy:
		queue_redraw()


## Start one event of `type` now (screenshots and tests).
func force(type: String) -> void:
	for lane in LANES.keys():
		if LANES[lane].has(type):
			_lanes[lane]["ev"] = {}
			_start(lane, type)
			return


## Pick an event on `lane` by weight and a live target for it; a kind with no target waits
## a second.
func _start(lane: String, forced: String = "") -> void:
	var st: Dictionary = _lanes[lane]
	var weights: Dictionary = LANES[lane]
	var glitch_ok := bool(Settings.display.get("glitch", true))
	var pool: Array = []
	for kind in weights.keys():
		if not glitch_ok and kind in ["tear", "signal"]:
			continue
		for i in range(int(weights[kind])):
			pool.append(kind)
	var type: String = forced if weights.has(forced) else pool[_rng.randi() % pool.size()]
	var view: Control = null
	match type:
		"scanbox", "databox", "tear", "signal":
			view = _pick(foe_views)
		"readout", "levels":
			view = _pick(mech_views)
		"recalc", "wobble":
			view = _pick(dice)
	if view == null:
		st["wait"] = 1.0
		return
	var ev := {"type": type, "view": view, "t": 0.0, "dur": float(DURATION[type]), "salt": int(_rng.randi() % 1000)}
	if type == "databox":
		# The parts the box reads in turn: points on the drawing, as fractions of it.
		var spots: Array = []
		for i in range(3):
			spots.append(Vector2(_rng.randf_range(0.2, 0.8), _rng.randf_range(0.15, 0.85)))
		ev["spots"] = spots
	match type:
		"tear":
			view.glitch("tear", ev["dur"])
		"signal":
			view.glitch("drop", ev["dur"])
		"recalc":
			view.recalc(ev["dur"])
		"wobble":
			view.wobble(ev["dur"])
	st["ev"] = ev
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
	for lane in _lanes.keys():
		var ev: Dictionary = _lanes[lane]["ev"]
		if not ev.is_empty():
			_draw_event(ev)


func _draw_event(ev: Dictionary) -> void:
	var v: Control = ev["view"]
	if not is_instance_valid(v) or not v.visible:
		return
	var secs: float = ev["t"]
	var dur: float = ev["dur"]
	var t: float = secs / dur
	var frame := int(Time.get_ticks_msec() / 90)
	var salt: int = ev["salt"]
	var hud := Palette.HUD
	var mono := Hud.mono()
	# In over a few frames, out over the last sixth.
	var a := minf(1.0, secs * 10.0) * (1.0 if t < 0.84 else (1.0 - t) / 0.16)
	var settle := clampf(secs / SETTLE, 0.0, 1.0)
	# The boxes go out gently: a fade over the last third of a second.
	var fade := clampf((dur - secs) / 0.35, 0.0, 1.0) * minf(1.0, secs * 10.0)
	match ev["type"]:
		"scanbox":
			var r := _unit_rect(v)
			var grow := 4.0 + 14.0 * (1.0 - settle)
			# The meter fills, then everything blinks a few times: scan complete (Ryan, 23
			# September), and it is gone on the last blink.
			var done := t >= SCAN_HOLD
			var sa := a
			var label := Hud.hex_bytes(3, frame, salt)
			if done:
				var blink := int((secs - SCAN_HOLD * dur) / 0.14)
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
			var spots: Array = ev["spots"]
			var which := int(secs / READ_EVERY) % spots.size()
			var spot: Vector2 = r.position + (spots[which] as Vector2) * r.size
			var s2 := salt + which * 17
			var lines: Array[String] = ["TRK %02X" % (s2 % 256), Hud.hex_bytes(2, frame, s2), "SIG .%02d" % (absi(hash(frame * 3 + s2)) % 100)]
			var right := r.end.x + 14.0 + BOX.x <= size.x
			var bx := r.end.x + 14.0 if right else r.position.x - 14.0 - BOX.x
			var by := clampf(r.position.y + 6.0, 0.0, size.y - BOX.y)
			var box := Rect2(bx, by, BOX.x, BOX.y)
			Hud.box(self, box, 5.0, Color(Palette.BG, 0.9 * fade), Color(hud, 0.85 * fade), 1.0)
			var from := Vector2(bx if right else bx + BOX.x, by + 9.0)
			var reach := settle * fade
			var to := from.lerp(spot, reach)
			draw_line(from, to, Color(hud, 0.9 * fade), 2.0)   # a hairline at 0.7 vanished on the phone's ground (Ryan, 28 September)
			if reach > 0.95:
				Hud.brackets(self, Rect2(spot - Vector2(6.0, 6.0), Vector2(12.0, 12.0)), 4.0, Color(hud, fade), 1.2)
			for i in range(lines.size()):
				draw_string(mono, Vector2(bx + 7.0, by + 15.0 + i * 14.0), lines[i], HORIZONTAL_ALIGNMENT_LEFT, BOX.x - 14.0, 10, Color(hud, fade))
		"readout", "levels":
			# A machine's readout is a live chart (Ryan, 23 September: not the foe's box
			# again), on a fixed leader to the machine's side: a system tag over a row of bars
			# rolling in from the right, one every tenth of a second; or three chunky level
			# bars growing and shrinking like an equaliser.
			var r := _unit_rect(v)
			var right := r.end.x + 14.0 + CHART.x <= size.x
			var bx := r.end.x + 14.0 if right else r.position.x - 14.0 - CHART.x
			var by := clampf(r.get_center().y - CHART.y * 0.5, 0.0, size.y - CHART.y)
			var box := Rect2(bx, by, CHART.x, CHART.y)
			Hud.box(self, box, 5.0, Color(Palette.BG, 0.9 * fade), Color(hud, 0.85 * fade), 1.0)
			draw_string(mono, Vector2(bx + 7.0, by + 13.0), "SYS %02X" % (salt % 256), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(hud, fade))
			var inner := Rect2(bx + 7.0, by + 19.0, CHART.x - 14.0, CHART.y - 26.0)
			if ev["type"] == "readout":
				draw_string(mono, Vector2(bx, by + 13.0), "%3d" % (absi(hash(int(secs / 0.1) + salt)) % 100 + 400), HORIZONTAL_ALIGNMENT_RIGHT, CHART.x - 7.0, 10, Color(hud, 0.8 * fade))
				draw_line(Vector2(inner.position.x, inner.end.y), inner.end, Color(hud, 0.4 * fade), 1.0)
				var nbars := 10
				var bw := inner.size.x / nbars
				var step := int(secs / 0.1)
				for i in range(nbars):
					var h := inner.size.y * (0.1 + 0.9 * Hud.noise((step + i) * 0.61 + salt * 0.013))
					draw_rect(Rect2(inner.position.x + i * bw + 1.0, inner.end.y - h, bw - 2.0, h), Color(hud, (0.45 + 0.55 * float(i) / nbars) * fade))
			else:
				# Each level glides between readings taken every third of a second.
				var step := secs / 0.33
				var k := int(step)
				var mix := step - k
				var rows := ["L1", "L2", "L3"]
				var row_h := inner.size.y / rows.size()
				for i in range(rows.size()):
					var lo := Hud.noise((k + i * 7) * 0.53 + salt * 0.017)
					var hi := Hud.noise((k + 1 + i * 7) * 0.53 + salt * 0.017)
					var level := lerpf(lo, hi, smoothstep(0.0, 1.0, mix))
					var y := inner.position.y + i * row_h
					draw_string(mono, Vector2(inner.position.x, y + row_h * 0.5 + 3.0), rows[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(hud, 0.8 * fade))
					var track := Rect2(inner.position.x + 16.0, y + row_h * 0.5 - 3.0, inner.size.x - 16.0, 6.0)
					draw_rect(track, Color(hud, 0.18 * fade))
					draw_rect(Rect2(track.position, Vector2(track.size.x * (0.1 + 0.9 * level), track.size.y)), Color(hud, fade))
			var from := Vector2(bx if right else bx + CHART.x, by + CHART.y * 0.5)
			var to := Vector2(r.end.x if right else r.position.x, by + CHART.y * 0.5)
			draw_line(from, from.lerp(to, settle), Color(hud, 0.9 * fade), 2.0)   # the readout's leader: a hairline vanished on the phone (Ryan, 28 September)
		_:
			pass   # tear, signal, recalc: the unit or die draws itself

class_name FeedFX
extends Control

## The display reading the fight (Ryan, 23 September): every few seconds one brief,
## one-shot analysis event on a random unit or die, so the skirmish HUD feels like a feed
## being analysed in real time rather than a print. Infrequent and varied on purpose, so it
## never becomes a rhythm and never competes with the pending-gauge pulse. The events:
##
##   scanbox   bracket corners settle onto a foe, a meter fills beneath it, bytes tick above
##   databox   a small telemetry box beside a foe, three lines of gibberish, a leader to it
##   readout   the same box beside a machine
##   recalc    a die's number scrambles and settles, its frame flashing once
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
const DURATION := {"scanbox": 1.0, "databox": 0.9, "readout": 0.9, "recalc": 0.35, "tear": 0.25, "signal": 0.3}
const BOX := Vector2(100.0, 48.0)

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
			_wait = _rng.randf_range(GAP_MIN, GAP_MAX)
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
	match type:
		"tear":
			view.glitch("tear")
		"signal":
			view.glitch("drop")
		"recalc":
			view.recalc()
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
	var t: float = _ev["t"] / _ev["dur"]
	var frame := int(Time.get_ticks_msec() / 90)
	var salt: int = _ev["salt"]
	var hud := Palette.HUD
	var mono := Hud.mono()
	# In fast, out over the last sixth.
	var a := minf(1.0, t * 8.0) * (1.0 if t < 0.84 else (1.0 - t) / 0.16)
	match _ev["type"]:
		"scanbox":
			var r := _unit_rect(v)
			var grow := 4.0 + 12.0 * maxf(0.0, 1.0 - t * 4.0)
			Hud.brackets(self, r.grow(grow), 10.0, Color(hud, a), 1.5)
			var meter := Rect2(r.position.x, r.end.y + grow + 4.0, r.size.x, 4.0)
			draw_rect(meter, Color(hud, 0.25 * a))
			draw_rect(Rect2(meter.position, Vector2(meter.size.x * minf(1.0, t / 0.84), meter.size.y)), Color(hud, a))
			draw_string(mono, Vector2(r.position.x - 4.0, r.position.y - grow - 5.0), Hud.hex_bytes(3, frame, salt), HORIZONTAL_ALIGNMENT_LEFT, r.size.x + 8.0, 10, Color(hud, a))
		"databox", "readout":
			var r := _unit_rect(v)
			var lines: Array[String] = []
			if _ev["type"] == "databox":
				lines = ["TRK %02X" % (salt % 256), Hud.hex_bytes(3, frame, salt), "SIG 0.%02d" % (absi(hash(frame * 3 + salt)) % 100)]
			else:
				lines = ["SYS %02X" % (salt % 256), Hud.hex_bytes(3, frame, salt), "TMP %03d" % (absi(hash(frame * 5 + salt)) % 400 + 200)]
			var right := r.end.x + 10.0 + BOX.x <= size.x
			var bx := r.end.x + 10.0 if right else r.position.x - 10.0 - BOX.x
			var by := clampf(r.position.y + 6.0, 0.0, size.y - BOX.y)
			var box := Rect2(bx, by, BOX.x, BOX.y)
			Hud.box(self, box, 5.0, Color(Palette.BG, 0.9 * a), Color(hud, 0.85 * a), 1.0)
			var from := Vector2(bx if right else bx + BOX.x, by + 9.0)
			var to := Vector2(r.end.x if right else r.position.x, by + 9.0)
			draw_line(from, to, Color(hud, 0.6 * a), 1.0)
			for i in range(lines.size()):
				draw_string(mono, Vector2(bx + 7.0, by + 15.0 + i * 14.0), lines[i], HORIZONTAL_ALIGNMENT_LEFT, BOX.x - 14.0, 10, Color(hud, a))
		_:
			pass   # tear, signal, recalc: the unit or die draws itself

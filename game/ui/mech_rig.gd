class_name MechRig
extends RefCounted

## A machine's joints and what its pilot does with them: the idle acts (decided 2 October,
## the bible's idle-acts row) and the strikes. One rig drives one instanced model, in the
## skirmish (MechView3D) or on the map (Map3D), from the model's own sidecar,
## art/models/<id>.rig.json, written by tools/lowforge beside the glTF: every joint's
## axis, its limits and its parent, the acts as keyframes, and the cornering numbers. No
## runtime code keys on a chassis id; a model with no sidecar has joints by name alone and
## no acts, and stands still.
##
## The model's tags (tools/lowforge/bl_low.py): `joint_<name>` is a pivot with the limb's
## parts under it, nested where it rides another joint; `hp_<n>` is a weapon socket with its
## stock part under it. Both come through the glTF as plain Node3Ds by name.
##
## Angles are authored in the machine's own terms and turned into the node's Euler here:
## pitch about the axle line (x; positive raises the forward end), yaw about up (y; positive
## turns left), roll about forward (positive drops the right side). Blender's y forward is
## Godot's -z, so a roll of +r is rotation.z = -r and a slide (dx, dy, dz) is (dx, dz, -dy).
##
## A grounded machine never sways or bobs (Ryan, 2 October): every few seconds it plays one
## of its own acts, never the same one twice running, each instance on its own clock so a
## team is never in step. RIFTGATE_ACTS_DEBUG=1 plays the acts back to back for judging
## them running; RIFTGATE_ACTS_DEBUG=<act name> loops that one act.
##
## Weight (Ryan, 4 October, the third pass: some acts stilted, bank and hard stop; real
## machines with real physics, limbs and weapons heavy, with inertia): an act's keys are a
## curve that runs on through a key a part passes on its way (it stops only to turn back or
## to hold), and what the curve asks of each part is chased by a servo, a mass on a damped
## spring, the machine's `heft` its time constant: a part gathers speed, carries a touch past
## its mark and settles, and a heavy machine lags its pilot more than a light one.
##
## Movement (the joints row, 2 October): while the map moves a machine, `drive` feeds the rig
## its speed, the bearing it is travelling on relative to its facing, and how fast its facing
## is turning, and the sidecar's gait answers: cycles keyed by distance travelled (a walk,
## stride by stride, so a slow machine steps slowly), wheels spun by their radius, treads
## scrolled, steering knuckles turned with the turn and casters pointed along the travel,
## offsets held while moving (the Badger's booms lifting the claw), boosters brightening, a
## rock on pulling away and stopping, and a bank into turns for what flies. The map's
## cornering module owes the rig the numbers (Map3D). A helicopter-style machine (Ryan, 3
## October: the Stingray, and one or two more to come) keeps its facing and tilts toward
## its travel instead: nose down to go forward, nose up to go back, a side down to go that
## way (`tilt` in its cornering numbers; the map holds its facing through `strafe`). A
## turret turns with the hull on the move (Ryan, 4 October: holding its aim was not worth
## the complexity). RIFTGATE_MOVE_DEBUG=1 drives every machine constantly at its own full
## speed on the map (`top_speed`, map_speed), on both screens, for judging a gait running.

const GAP_MIN := 2.5          # seconds between acts, at least
const GAP_MAX := 6.5          # and at most
const GAP_DEBUG := 0.4        # with the debug switch on
const CUE_GAP := 1.0          # seconds between any two acts starting in one place: the machines there take turns
const CUE_JITTER := 0.8       # and a machine kept waiting tries again up to this much later, so the queue never lines up
const GLOW_BASE := 1.8        # the amber role's emission at rest (MechView3D.toon)
const MOVE_REF_SPEED := 150.0 # model units a second the slide and the tilt are authored at (a machine's own full speed on the map is `top_speed`)
const MOVE_BLEND_IN := 0.25   # seconds a gait takes to come up from standing
const MOVE_BLEND_OUT := 0.35  # and to settle back when the machine stops
const ROCK_ACCEL := 200.0     # model units a second squared that earns the whole rock: a machine reaching full speed in under a second (MovePath accelerates; was 1500 when moves started at full speed)
const BANK_TURN := 1.2        # radians a second of turning that earns the whole bank (the curve's corners turn about this fast)
const STEER_EASE := 0.12      # seconds a steered joint (a knuckle, a nacelle) takes to follow the turn: its servo
# Turning in place steps the legs round (Ryan, 7 October, the twentieth notes: a machine turns
# onto its way before it sets off, and a walker turning on the spot slid round on its feet):
# the turn counts toward the gait's travel as though each foot went round a circle PIVOT_STEP
# of a stride across, never faster than PIVOT_CAP of its own full speed (the twenty-first
# notes: some stepped round faster than they walk, which read as skating; 0.5 and no cap
# before; the twenty-second: 0.4 was too slow, up to three quarters), fading out as the
# machine gathers PIVOT_FADE units a second of its own; a turn
# slower than PIVOT_MIN radians a second is a settle, not a step. Nothing banks standing: the
# bank comes in with BANK_SPEED units a second.
const PIVOT_STEP := 0.35
const PIVOT_CAP := 0.75
const PIVOT_FADE := 20.0
const PIVOT_MIN := 0.15
const BANK_SPEED := 37.5
const DRIFT_UNITS := 12.0     # model units a machine with a slide of 1 drifts off its path when the travel is square to its facing
const HEFT_DEFAULT := 0.12    # seconds: the inertia of a machine whose sidecar names none (`move.heft`)
const DAMPING := 0.7          # the joints' servos: a touch under critical, so a heavy part gives a little past its mark and settles
const STEP := 1.0 / 60.0      # the longest step the acts and the servos advance by, so a long tick (a frozen frame) plays the same as frames

var joints: Dictionary = {}        # "shoulder_l" -> Node3D
var hardpoints: Dictionary = {}    # 1 -> Node3D
var meta: Dictionary = {}          # joint name -> {"axis", "limits", "swing", "parent"} (the sidecar; a bare default for an untagged joint)
var acts: Array = []               # the sidecar's acts, in authoring order
var move: Dictionary = {}          # the cornering numbers: {"slide", "bank"}
var model: Node3D = null           # the glTF's root
var body: Node3D = null            # the node a body track moves (the model root unless told otherwise)
var gait: Dictionary = {}          # the sidecar's gait: how this machine moves (see drive)
var gait_options: Dictionary = {}  # other ways it could move, built beside it for judging (b.gait_option); the game uses one only as a gait's start
var _start_gait: Dictionary = {}   # the gait it starts and stops in, when its gait names one: {"gait", "curves", "below", "full"}, and the stride it changes in: "from", "to" and "handoff" (a gait whose stride is its length)
var _travel := 0.0                 # model units travelled since it last stood still
var _start_offset := 0.0           # model units added to the travel for the start gait's phase (it sets off at its handoff's "from")
var _main_offset := 0.0            # and for the gait's own (at the handoff's "to" as it sets off)
var _handoff_at := 0.0             # the travel (`_dist`) the stride it changes in counts from
var _handing := false              # whether it is rolling and the handoff counts (false standing)
var spinners: Dictionary = {}      # joint -> [idle, moving] degrees a second: turned without end on its own axis (b.spin: the Stingray's fans)
var _spun: Dictionary = {}         # joint -> degrees turned so far, wrapped
var debug: String = ""             # RIFTGATE_ACTS_DEBUG, read at setup
var debug_move: bool = false       # RIFTGATE_MOVE_DEBUG: driven constantly
var last_act: String = ""          # the act played last (never played twice running)
var moving: bool = false           # whether the last drive had any speed

var _rest: Dictionary = {}         # joint -> rest rotation
var _rest_pos: Dictionary = {}     # joint -> rest position
var _body_rest_pos := Vector3.ZERO
var _body_rest_rot := Vector3.ZERO
var _act_rot: Dictionary = {}      # joint -> degrees (pitch, yaw, roll) from the act playing
var _act_slide: Dictionary = {}    # joint -> world-unit slide (dx, dy, dz, Blender's axes)
var _strikes: Array = []           # [{joint, vec (degrees), up, down, t}]
var _glow: Array = []              # [{mats: [StandardMaterial3D], base: [float]}] per glow track of the act playing
var _glow_cache: Dictionary = {}   # part prefix -> [StandardMaterial3D]
var _body_act_rot := Vector3.ZERO  # the act's body track, degrees (pitch, yaw, roll)
var _body_act_slide := Vector3.ZERO
var _body_move_rot := Vector3.ZERO # the gait's body: bob, rock, bank
var _body_move_slide := Vector3.ZERO
var _gait_rot: Dictionary = {}     # joint -> degrees from the gait (cycles, wheels, steering, holds)
var _gait_slide: Dictionary = {}
var _dist := 0.0                   # model units travelled since setup (wheels and strides read it)
var _speed := 0.0                  # model units a second, smoothed
var _blend := 0.0                  # 0 standing, 1 moving: the gait's weight
var _accel := 0.0                  # the smoothed change of speed, for the rock
var _bank := 0.0                   # degrees of roll into the turn, eased
var _tilt := Vector2.ZERO          # degrees of (pitch, roll) toward the travel, a helicopter's, eased
var _steer: Dictionary = {}        # joint -> degrees a steered joint has turned with the turn, eased
var _drift := 0.0                  # model units the body sits off its path, right positive, eased (the slide)
var _tread_mats: Array = []        # [[StandardMaterial3D, base uv offset]] the treads scroll
var _move_glow: Array = []         # [[StandardMaterial3D, base]] the boosters brighten
var _current: Dictionary = {}      # the act playing, or empty
var _curves: Dictionary = {}       # the act playing as curves: joint -> curve, BODY -> curve
var _t := 0.0                      # time into the act playing
var _wait := 0.0                   # seconds until the next act starts
var _rng := RandomNumberGenerator.new()
static var _cue: Dictionary = {}   # place -> the msec clock when an act last started there (the shared cue)
var heft := HEFT_DEFAULT           # seconds: how long a joint or the body takes to catch up with what the pilot asks (the sidecar's `move.heft`)
var place: String = ""             # where this machine stands, "map" or "skirmish": an act may be for one of them only (its `places`); empty plays them all
var _act_heft := HEFT_DEFAULT      # the heft while the act playing asks for its own (a blow sharper than the machine's weight)
var top_speed := MOVE_REF_SPEED    # model units a second at this machine's full speed on the map (map_speed; the debug drive's pace)
var _want_rot: Dictionary = {}     # joint -> degrees the act asks for now; the servos chase it into _act_rot
var _want_slide: Dictionary = {}
var _body_want_rot := Vector3.ZERO
var _body_want_slide := Vector3.ZERO
var _servo: Dictionary = {}        # joint (or BODY) -> [rot, rot speed, slide, slide speed]: where each part is and how fast it moves
var _spin: Dictionary = {}         # the gait's wheels: an act turns them directly, never through a servo (a spin never unwinds)
var _gait_curves: Dictionary = {}  # the gait's cycles as curves: joint -> curve, BODY -> curve

const BODY := "@body"


## The sidecar of a model, or an empty dictionary when it has none.
static func load_sidecar(model_id: String) -> Dictionary:
	var path := "res://art/models/%s.rig.json" % model_id
	if not FileAccess.file_exists(path):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


## What a node name in the model means: ["joint", "shoulder_l"], ["hp", 1], or [] for a part.
## Godot's importer may append a suffix to keep names unique; the tag survives that.
static func parse_tag(node_name: String) -> Array:
	if node_name.begins_with("joint_") and node_name.length() > 6:
		return ["joint", node_name.substr(6)]
	if node_name.begins_with("hp_"):
		var rest := node_name.substr(3)
		var digits := ""
		for ch in rest:
			if ch.is_valid_int():
				digits += ch
			else:
				break
		if not digits.is_empty():
			return ["hp", int(digits)]
	return []


## The axis a joint turns about when the sidecar names none: a turret, a caster, a steering
## knuckle, a head or a sensor about up; anything else about the axle line (lowforge's rule).
static func axis_for(name: String) -> String:
	for prefix in ["turret", "caster", "steer", "head", "sensor"]:
		if name.begins_with(prefix):
			return "yaw"
	return "pitch"


## The node-space direction of an authored axis: pitch is the node's x, yaw its y, roll its
## -z (Blender's forward came through as -z).
static func axis_vector(axis: String) -> Vector3:
	match axis:
		"yaw":
			return Vector3(0.0, 1.0, 0.0)
		"roll":
			return Vector3(0.0, 0.0, -1.0)
	return Vector3(1.0, 0.0, 0.0)


## Authored degrees (pitch, yaw, roll) as the node's Euler offset in radians.
static func euler_of(deg: Vector3) -> Vector3:
	return Vector3(deg_to_rad(deg.x), deg_to_rad(deg.y), -deg_to_rad(deg.z))


## An authored slide (dx right, dy forward, dz up) as the node's offset.
static func offset_of(slide: Vector3) -> Vector3:
	return Vector3(slide.x, slide.z, -slide.y)


## Degrees clamped to a joint's limits: {"pitch": [lo, hi], "yaw": [...], "roll": [...]},
## an axis without a pair left free.
static func clamp_degrees(deg: Vector3, limits: Dictionary) -> Vector3:
	var out := deg
	for i in range(3):
		var axis: String = ["pitch", "yaw", "roll"][i]
		if limits.has(axis) and limits[axis] is Array and (limits[axis] as Array).size() == 2:
			out[i] = clampf(out[i], float(limits[axis][0]), float(limits[axis][1]))
	return out


## An act's keys as a curve: each key is [t, v1, v2, ...]; the track rests (every value
## zero) at time 0 and again at `duration` unless a key is authored there, so an act always
## returns the machine to its pose. "smooth" runs a monotone cubic through the keys (Ryan, 4
## October, the third pass: a part passing a key on its way keeps its speed through it, so
## only a turn or a hold stops it, and nothing overshoots a key); "linear" runs straight
## between them (a wheel spinning). Sample it with curve_at.
static func curve(keys: Array, duration: float, ease: String = "smooth") -> Dictionary:
	var width := 1
	for k in keys:
		width = maxi(width, (k as Array).size())
	var zero: Array = []
	for i in range(width):
		zero.append(0.0)
	var pts: Array = []
	if keys.is_empty() or float(keys[0][0]) > 0.0:
		pts.append(zero.duplicate())
	for k in keys:
		var row: Array = (k as Array).duplicate()
		while row.size() < width:
			row.append(0.0)
		pts.append(row)
	if float(pts[pts.size() - 1][0]) < duration:
		var end := zero.duplicate()
		end[0] = duration
		pts.append(end)
	return _through(pts, ease)


## Cyclic keys over a phase of 0 to 1 as a curve: the track wraps, so a key at 1 is the key
## at 0 unless that one is authored too, and the curve runs through the wrap without a stop.
static func cycle_curve(keys: Array, ease: String = "smooth") -> Dictionary:
	if keys.is_empty():
		return {}
	var rows: Array = []
	var at := {}
	for k in keys:
		var row: Array = (k as Array).duplicate()
		row[0] = float(row[0])
		if row[0] < 1.0:
			rows.append(row)
			at[snappedf(row[0], 0.0001)] = true
	for k in keys:
		var row: Array = (k as Array).duplicate()
		row[0] = float(row[0])
		if row[0] >= 1.0 and not at.has(snappedf(row[0] - 1.0, 0.0001)):
			row[0] -= 1.0
			rows.append(row)
	rows.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	var width := 1
	for r in rows:
		width = maxi(width, (r as Array).size())
	for r in rows:
		while (r as Array).size() < width:
			(r as Array).append(0.0)
	# Two keys of the cycle before and two after, so every key inside a stride has neighbours
	# on both sides and its slope is the cycle's own.
	var n := rows.size()
	var pts: Array = []
	for i in range(-2, n + 2):
		var row: Array = (rows[posmod(i, n)] as Array).duplicate()
		row[0] = float(row[0]) + float(floori(float(i) / n))
		pts.append(row)
	return _through(pts, ease)


## The slopes of a monotone cubic through `pts` ([t, v...] rows in time order): zero at a
## turn, a hold and the two ends, the weighted harmonic mean of the neighbouring secants
## where the track runs on through a key (Fritsch and Butland).
static func _through(pts: Array, ease: String) -> Dictionary:
	var n := pts.size()
	var width := (pts[0] as Array).size() - 1
	var times := PackedFloat64Array()
	var vals: Array = []
	var slopes: Array = []
	for p in pts:
		times.append(float(p[0]))
		var v := PackedFloat64Array()
		for j in range(1, width + 1):
			v.append(float(p[j]))
		vals.append(v)
	var linear := ease == "linear"
	for i in range(n):
		var m := PackedFloat64Array()
		m.resize(width)
		if not linear and i > 0 and i < n - 1:
			var h0 := times[i] - times[i - 1]
			var h1 := times[i + 1] - times[i]
			for j in range(width):
				if h0 <= 0.0 or h1 <= 0.0:
					continue
				var d0: float = (float(vals[i][j]) - float(vals[i - 1][j])) / h0
				var d1: float = (float(vals[i + 1][j]) - float(vals[i][j])) / h1
				if d0 * d1 <= 0.0:
					continue
				var w0 := 2.0 * h1 + h0
				var w1 := h1 + 2.0 * h0
				m[j] = (w0 + w1) / (w0 / d0 + w1 / d1)
		slopes.append(m)
	return {"t": times, "v": vals, "m": slopes, "linear": linear, "width": width}


## A curve's values at time `t`, held at its first and last keys outside them.
static func curve_at(c: Dictionary, t: float) -> Array:
	var out: Array = []
	if c.is_empty():
		return out
	var times: PackedFloat64Array = c["t"]
	var vals: Array = c["v"]
	var width := int(c["width"])
	var n := times.size()
	var row: PackedFloat64Array
	if t <= times[0]:
		row = vals[0]
	elif t >= times[n - 1]:
		row = vals[n - 1]
	else:
		var i := clampi(times.bsearch(t, false) - 1, 0, n - 2)
		var h := times[i + 1] - times[i]
		var u := 1.0 if h <= 0.0 else (t - times[i]) / h
		var a: PackedFloat64Array = vals[i]
		var b: PackedFloat64Array = vals[i + 1]
		if bool(c["linear"]):
			for j in range(width):
				out.append(lerpf(a[j], b[j], u))
			return out
		var ma: PackedFloat64Array = c["m"][i]
		var mb: PackedFloat64Array = c["m"][i + 1]
		var u2 := u * u
		var u3 := u2 * u
		var h00 := 2.0 * u3 - 3.0 * u2 + 1.0
		var h10 := u3 - 2.0 * u2 + u
		var h01 := -2.0 * u3 + 3.0 * u2
		var h11 := u3 - u2
		for j in range(width):
			out.append(h00 * a[j] + h10 * h * ma[j] + h01 * b[j] + h11 * h * mb[j])
		return out
	for j in range(width):
		out.append(row[j])
	return out


## Keys sampled at `t` (the curve through them, at once): for one look, not a frame loop.
static func sample(keys: Array, t: float, duration: float, ease: String = "smooth") -> Array:
	return curve_at(curve(keys, duration, ease), t)


## A machine's full speed on the map in its own model units a second: the map fits it to
## `fit` hex widths at its widest (Map3D.fit_for, by its class by mass) and a step at full
## speed takes the map's pace for its move (BattleMapView.mech_seconds_per_hex). What the
## debug drive and the hangar's Walk run at, so a stride is seen at the pace the map gives
## it: the smaller a machine is drawn, the more of itself a hex is, the more strides it takes.
static func map_speed(widest: float, movespeed: int, fit: float) -> float:
	var step := sqrt(3.0) * widest / (2.0 * maxf(0.01, fit))
	return step / BattleMapView.mech_seconds_per_hex(float(movespeed))


## Move by `g` from now on: the sidecar's gait (setup does this) or one of its options, for a
## tool or a page judging one running (tools/gait_clip.gd).
func use_gait(g: Dictionary) -> void:
	gait = g
	_spin = {}
	for name in gait.get("wheels", {}).keys():
		_spin[name] = true
	_gait_curves = _cycle_curves(gait)
	# A gait may start and stop in another (Ryan, 7 October, the nineteenth notes: the
	# Clydesdale took off straight into its gallop): `start` names one of the options, moved by
	# wholly under `below` of its full speed, by its own gait over `full`, crossfading between.
	# Its handoff (the twenty-second notes) sets it off in that gait at `from` and plays the
	# stride it changes in, worked out foot by foot over `length` units, into its own at `to`.
	_start_gait = {}
	_main_offset = 0.0
	_start_offset = 0.0
	_handing = false
	var st: Variant = gait.get("start", {})
	if st is Dictionary and gait_options.get(str(st.get("option", "")), null) is Dictionary:
		var opt: Dictionary = gait_options[str(st["option"])]
		_start_gait = {"gait": opt, "curves": _cycle_curves(opt), "below": float(st.get("below", 0.3)), "full": float(st.get("full", 0.8))}
		var h: Variant = st.get("handoff", {})
		if h is Dictionary and float((h as Dictionary).get("length", 0.0)) > 0.0:
			var change := {"stride": float(h["length"]), "ease": "linear", "tracks": h.get("tracks", {}), "body": h.get("body", [])}
			change["curves"] = _once_curves(change)
			_start_gait["from"] = float(h.get("from", 0.0))
			_start_gait["to"] = float(h.get("to", 0.0))
			_start_gait["handoff"] = change


## The cyclic curves of a gait's tracks and body.
func _cycle_curves(g: Dictionary) -> Dictionary:
	var out := {}
	var ease := str(g.get("ease", "smooth"))
	var cycles: Dictionary = g.get("tracks", {})
	for name in cycles.keys():
		out[name] = cycle_curve((cycles[name] as Dictionary).get("keys", []), ease)
	if not g.get("body", []).is_empty():
		out[BODY] = cycle_curve(g["body"], ease)
	return out


## The stride a gait changes in as curves: once through, its first key the start gait's pose
## and its last the gait's own, never wrapping (cycle_curve would read its end as its start).
func _once_curves(g: Dictionary) -> Dictionary:
	var out := {}
	var tracks: Dictionary = g.get("tracks", {})
	for name in tracks.keys():
		out[name] = curve((tracks[name] as Dictionary).get("keys", []), 1.0, "linear")
	if not g.get("body", []).is_empty():
		out[BODY] = curve(g["body"], 1.0, "linear")
	return out


## Read the model's tags and its sidecar. Call once the materials are applied (the glows
## look for the lit surfaces) and before anything moves; `phase` seeds this instance's
## clock so two machines of one kind never act in step.
func setup(root: Node3D, model_id: String, body_node: Node3D = null, phase: int = -1) -> void:
	model = root
	body = body_node if body_node != null else root
	joints.clear()
	hardpoints.clear()
	_rest.clear()
	_rest_pos.clear()
	_collect(root)
	var side := load_sidecar(model_id)
	meta = {}
	var sm: Dictionary = side.get("joints", {})
	for name in joints.keys():
		var m: Dictionary = sm.get(name, {})
		meta[name] = {
			"axis": str(m.get("axis", axis_for(name))),
			"limits": m.get("limits", {}),
			"swing": bool(m.get("swing", str(name).begins_with("shoulder"))),
			"parent": str(m.get("parent", "")),
		}
	acts = []
	for a in side.get("acts", []):
		if a is Dictionary and a.has("name"):
			acts.append(a)
	move = side.get("move", {})
	heft = float(move.get("heft", HEFT_DEFAULT))
	gait_options = side.get("gait_options", {}) if side.get("gait_options", {}) is Dictionary else {}
	spinners = {}
	_spun = {}
	var sp: Dictionary = side.get("spin", {}) if side.get("spin", {}) is Dictionary else {}
	for name in sp.keys():
		if joints.has(name) and sp[name] is Array and (sp[name] as Array).size() >= 2:
			spinners[name] = [float(sp[name][0]), float(sp[name][1])]
			_spun[name] = 0.0
	use_gait(side.get("gait", {}) if side.get("gait", {}) is Dictionary else {})
	_body_rest_pos = body.position
	_body_rest_rot = body.rotation
	_rng.seed = hash(model_id) ^ (randi() if phase < 0 else phase * 7919)
	debug = OS.get_environment("RIFTGATE_ACTS_DEBUG")
	debug_move = OS.get_environment("RIFTGATE_MOVE_DEBUG") == "1"
	_wait = GAP_DEBUG if not debug.is_empty() else _rng.randf_range(0.6, GAP_MAX)
	_glow_cache.clear()
	_tread_mats = []
	_move_glow = []
	_dist = 0.0
	_speed = 0.0
	_blend = 0.0
	_accel = 0.0
	_bank = 0.0
	_tilt = Vector2.ZERO
	_steer.clear()
	_travel = 0.0
	_handing = false
	_drift = 0.0
	_current = {}
	_curves = {}
	_want_rot.clear()
	_want_slide.clear()
	_body_want_rot = Vector3.ZERO
	_body_want_slide = Vector3.ZERO
	_servo.clear()
	_act_rot.clear()
	_act_slide.clear()
	_gait_rot.clear()
	_gait_slide.clear()
	var treads: Dictionary = gait.get("treads", {})
	for part in treads.get("parts", []):
		_tread_named(root, str(part))
	var mg: Dictionary = gait.get("glow", {})
	for part in mg.get("parts", []):
		for m in _lit_materials(str(part)):
			_move_glow.append([m, (m as StandardMaterial3D).emission_energy_multiplier])


func _collect(node: Node) -> void:
	var tag := parse_tag(node.name)
	if tag.size() == 2 and node is Node3D:
		if tag[0] == "joint":
			joints[tag[1]] = node
			_rest[tag[1]] = (node as Node3D).rotation
			_rest_pos[tag[1]] = (node as Node3D).position
		else:
			hardpoints[tag[1]] = node
	for c in node.get_children():
		_collect(c)


## Whether anything here moves on its own: acts to play, a part still settling, a strike
## still swinging, a gait under the debug switch.
## Whether an act is playing now (a hovercraft's balance quietens through one).
func in_act() -> bool:
	return not _current.is_empty()


func alive() -> bool:
	return not acts.is_empty() or not _strikes.is_empty() or not _current.is_empty() or not _servo.is_empty() or (debug_move and not gait.is_empty())


## Advance the clock: the act playing, the gap to the next one, the servos and the strikes,
## in steps no longer than STEP, so a long tick lands where frames would have.
func tick(delta: float) -> void:
	if model == null:
		return
	var moved := false
	var left := delta
	while left > 0.0:
		var dt := minf(left, STEP)
		left -= dt
		if _step(dt):
			moved = true
	# What turns without end turns whatever else is happening, faster as the move blends in.
	for name in spinners.keys():
		var r: Array = spinners[name]
		_spun[name] = fposmod(float(_spun[name]) + lerpf(float(r[0]), float(r[1]), _blend) * delta, 360.0)
		moved = true
	if debug_move and not gait.is_empty():
		drive(top_speed, 0.0, 0.0, delta)
	elif moved:
		_pose()


func _step(dt: float) -> bool:
	var moved := false
	if not _current.is_empty():
		_t += dt
		_evaluate_act()
		moved = true
		if _t >= float(_current.get("duration", 0.0)):
			_end_act()
	elif not acts.is_empty() and not moving:   # a pilot on the move has no hands free for an act
		_wait -= dt
		if _wait <= 0.0:
			var next := choose()
			if not next.is_empty() and not _cued():
				_wait = _rng.randf_range(0.0, CUE_JITTER)   # another machine here just started: wait a turn
			elif not next.is_empty():
				_start(next)
				_evaluate_act()
				moved = true
	if not _servo.is_empty() or not _want_rot.is_empty() or _body_want_rot != Vector3.ZERO or _body_want_slide != Vector3.ZERO:
		_follow(dt)
		moved = true
	if not _strikes.is_empty():
		for st in _strikes:
			st["t"] = float(st["t"]) + dt
		_strikes = _strikes.filter(func(st): return float(st["t"]) < float(st["up"]) + float(st["down"]))
		moved = true
	return moved


## Whether this machine may start an act now: its own wait is spent and no other machine in
## its place started one in the last CUE_GAP (Ryan, 7 October: independent clocks put two
## machines' acts together far too often, and any stagger at the start drifts back into
## chance within a few acts). Kept on the real clock, shared by every rig in the place; a
## rig with no place (the tests, the tools) and the debug switch skip it.
func _cued() -> bool:
	if place.is_empty() or not debug.is_empty():
		return true
	var now := Time.get_ticks_msec()
	if _cue.has(place) and now - int(_cue[place]) < int(CUE_GAP * 1000.0):
		return false
	_cue[place] = now
	return true


## The next act: random among the machine's own, never the one just played (Ryan, 2
## October). With the debug switch naming an act, that act.
func choose() -> Dictionary:
	if acts.is_empty():
		return {}
	if not debug.is_empty() and debug != "1":
		for a in acts:
			if str(a["name"]) == debug:
				return a
	# An act may be for the map or the skirmish alone (Ryan, 5 October: the Sparrowhawk's loop
	# and circle mean nothing in the skirmish's frame); this machine plays what fits its place.
	var here: Array = acts.filter(func(a): return place.is_empty() or (a.get("places", []) as Array).is_empty() or (a.get("places", []) as Array).has(place))
	if here.is_empty():
		return {}
	if here.size() == 1:
		return here[0]
	var pool: Array = here.filter(func(a): return str(a["name"]) != last_act)
	return pool[_rng.randi_range(0, pool.size() - 1)]


## Start a named act now; false when the machine has no act of that name.
func play(name: String) -> bool:
	for a in acts:
		if str(a["name"]) == name:
			_start(a)
			_evaluate_act()
			_pose()
			return true
	return false


func _start(a: Dictionary) -> void:
	_current = a
	_t = 0.0
	last_act = str(a["name"])
	var duration := float(a.get("duration", 0.0))
	var ease := str(a.get("ease", "smooth"))
	_act_heft = float(a.get("heft", heft))
	_curves = {}
	var tracks: Dictionary = a.get("tracks", {})
	for name in tracks.keys():
		if joints.has(name):
			_curves[name] = curve(tracks[name], duration, ease)
	if not a.get("body", []).is_empty():
		_curves[BODY] = curve(a["body"], duration, ease)
	_glow = []
	for g in a.get("glow", []):
		var mats: Array = []
		for part in g.get("parts", []):
			mats.append_array(_lit_materials(str(part)))
		var base: Array = []
		for m in mats:
			base.append((m as StandardMaterial3D).emission_energy_multiplier)
		_glow.append({"curve": curve(g.get("keys", []), duration, ease), "mats": mats, "base": base})


## The act is over: its glows go back to rest and its asks to nothing, and the servos bring
## every part home from wherever its weight has carried it, each angle first taken the short
## way round (a loop or a spin ends a whole turn on, which is the pose it started in, so it
## never unwinds; Ryan, 5 October).
func _end_act() -> void:
	for name in _servo.keys():
		var st: Array = _servo[name]
		var r: Vector3 = st[0]
		st[0] = Vector3(wrapf(r.x, -180.0, 180.0), wrapf(r.y, -180.0, 180.0), wrapf(r.z, -180.0, 180.0))
	for g in _glow:
		for i in range(g["mats"].size()):
			(g["mats"][i] as StandardMaterial3D).emission_energy_multiplier = float(g["base"][i])
	_glow = []
	_current = {}
	_curves = {}
	_want_rot.clear()
	_want_slide.clear()
	_body_want_rot = Vector3.ZERO
	_body_want_slide = Vector3.ZERO
	_wait = GAP_DEBUG if not debug.is_empty() else _rng.randf_range(GAP_MIN, GAP_MAX)


## What the act asks of each part at this moment: the servos chase it (_follow).
func _evaluate_act() -> void:
	for name in _curves.keys():
		var v := curve_at(_curves[name], _t)
		if name == BODY:
			_body_want_slide = Vector3(float(v[0]), float(v[1]), float(v[2]))
			_body_want_rot = Vector3(float(v[4]), float(v[3]), float(v[5])) if v.size() >= 6 else Vector3.ZERO   # authored (yaw, pitch, roll)
			continue
		_want_rot[name] = Vector3(float(v[0]), float(v[1]), float(v[2]))
		_want_slide[name] = Vector3(float(v[3]), float(v[4]), float(v[5])) if v.size() >= 6 else Vector3.ZERO
	for g in _glow:
		var k := float(curve_at(g["curve"], _t)[0]) + 1.0   # the keys are offsets from rest: 0 is the base light
		for i in range(g["mats"].size()):
			(g["mats"][i] as StandardMaterial3D).emission_energy_multiplier = float(g["base"][i]) * maxf(0.0, k)


## The machine's weight (Ryan, 4 October, the third pass: heavy, with inertia, real machines
## and not toys): every part an act moves, and the body, is driven to what the act asks by
## a servo, a mass on a spring a touch under critical damping, so it gathers speed, carries
## a little past its mark and settles, `heft` seconds its time constant. A wheel the gait
## spins takes the act's keys as they are. A part home and still drops out.
func _follow(dt: float) -> void:
	var w := 1.0 / maxf(0.02, _act_heft if not _current.is_empty() else heft)
	var names := {}
	for name in _servo.keys():
		names[name] = true
	for name in _want_rot.keys():
		names[name] = true
	if _body_want_rot != Vector3.ZERO or _body_want_slide != Vector3.ZERO:
		names[BODY] = true
	for name in names.keys():
		var want_r: Vector3 = _body_want_rot if name == BODY else _want_rot.get(name, Vector3.ZERO)
		var want_s: Vector3 = _body_want_slide if name == BODY else _want_slide.get(name, Vector3.ZERO)
		var st: Array
		if _spin.has(name):
			st = [want_r, Vector3.ZERO, want_s, Vector3.ZERO]
		else:
			st = _servo.get(name, [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO])
			var vr: Vector3 = st[1] + (w * w * (want_r - (st[0] as Vector3)) - 2.0 * DAMPING * w * (st[1] as Vector3)) * dt
			var vs: Vector3 = st[3] + (w * w * (want_s - (st[2] as Vector3)) - 2.0 * DAMPING * w * (st[3] as Vector3)) * dt
			st = [(st[0] as Vector3) + vr * dt, vr, (st[2] as Vector3) + vs * dt, vs]
		var home: bool = want_r == Vector3.ZERO and want_s == Vector3.ZERO and (st[0] as Vector3).length() < 0.02 \
			and (st[1] as Vector3).length() < 0.05 and (st[2] as Vector3).length() < 0.005 and (st[3] as Vector3).length() < 0.01
		if home:
			_servo.erase(name)
			st = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
		else:
			_servo[name] = st
		if name == BODY:
			_body_act_rot = st[0]
			_body_act_slide = st[2]
		elif home:
			_act_rot.erase(name)
			_act_slide.erase(name)
		else:
			_act_rot[name] = st[0]
			_act_slide[name] = st[2]


## Rest plus the act plus the gait plus the strikes, clamped to the joint's limits, on every
## joint; the body's rest plus its act and gait tracks.
func _pose() -> void:
	for name in joints.keys():
		var j: Node3D = joints[name]
		var deg: Vector3 = _act_rot.get(name, Vector3.ZERO) + _gait_rot.get(name, Vector3.ZERO)
		for st in _strikes:
			if st["joint"] == name:
				deg += (st["vec"] as Vector3) * _strike_envelope(st)
		var m: Dictionary = meta.get(name, {})
		deg = clamp_degrees(deg, m.get("limits", {}))
		if _spun.has(name):
			deg[["pitch", "yaw", "roll"].find(str(m.get("axis", "yaw")))] += float(_spun[name])
		j.rotation = _rest[name] + euler_of(deg)
		var slide: Vector3 = _act_slide.get(name, Vector3.ZERO) + _gait_slide.get(name, Vector3.ZERO)
		if slide != Vector3.ZERO or j.position != _rest_pos[name]:
			j.position = _rest_pos[name] + offset_of(slide)
	if body != null:
		body.position = _body_rest_pos + offset_of(_body_act_slide + _body_move_slide)
		body.rotation = _body_rest_rot + euler_of(_body_act_rot + _body_move_rot)


# ---------------------------------------------------------------- movement

## Cyclic keys sampled at a phase (the curve through them, at once): for one look, not a
## frame loop; the rig keeps its gait's curves from setup.
static func sample_cycle(keys: Array, phase: float, ease: String = "smooth") -> Array:
	if keys.is_empty():
		return []
	return curve_at(cycle_curve(keys, ease), fposmod(phase, 1.0))


## One frame of movement. `speed` is model units a second along the travel; `aim` the bearing
## of the travel relative to the body's facing, radians, positive left (a Dingo strafing
## left aims its casters +90 degrees); `turn` how fast the facing is turning, radians a
## second, positive left. Zero speed is standing, and the gait settles back over a moment.
func drive(speed: float, aim: float, turn: float, delta: float) -> void:
	if model == null or delta <= 0.0:
		return
	var prev := _speed
	_speed = lerpf(_speed, maxf(0.0, speed), 1.0 - exp(-delta / 0.12))
	_accel = lerpf(_accel, (_speed - prev) / delta, 1.0 - exp(-delta / 0.15))
	var pivot := minf(absf(turn) * PIVOT_STEP * maxf(1.0, float(gait.get("stride", 40.0))), PIVOT_CAP * top_speed) * (1.0 - clampf(_speed / PIVOT_FADE, 0.0, 1.0)) if absf(turn) > PIVOT_MIN else 0.0
	moving = speed > 0.5 or pivot > 0.0
	var target := 1.0 if moving else 0.0
	var rate := MOVE_BLEND_IN if moving else MOVE_BLEND_OUT
	var stood := _blend < 0.05   # the gait not yet showing as this frame begins
	_blend = move_toward(_blend, target, delta / rate)
	_dist += (_speed + pivot) * delta
	if speed > 0.5 or _speed > 0.5:
		if _travel <= 0.0:
			_set_off(stood)
		_travel += _speed * delta
	else:
		_travel = 0.0
		_handing = false
	var bank_want := float(move.get("bank", 0.0)) * clampf(-turn / BANK_TURN, -1.0, 1.0) * clampf(_speed / BANK_SPEED, 0.0, 1.0)   # a left turn drops the left wing: roll negative
	_bank = lerpf(_bank, bank_want, 1.0 - exp(-delta / 0.3))
	# A helicopter's tilt: it leans into its travel by its speed, nose down going forward,
	# nose up going back, the left side down going left (the roll is positive right-down). A
	# third number is the share of the nose-down it sheds in a turn, as it banks and pulls into
	# the corner (Ryan, 7 October, the nineteenth notes: a helicopter pulls into the turn after
	# banking, as a plane does), all of it at the turn rate that earns the whole bank.
	var tilt_spec: Array = move.get("tilt", [])
	if tilt_spec.size() >= 2:
		var share := clampf(_speed / MOVE_REF_SPEED, 0.0, 1.0)
		var pull := float(tilt_spec[2]) * clampf(absf(turn) / BANK_TURN, 0.0, 1.0) if tilt_spec.size() >= 3 else 0.0
		var want := Vector2(-float(tilt_spec[0]) * cos(aim) * (1.0 - pull), -float(tilt_spec[1]) * sin(aim)) * share
		_tilt = _tilt.lerp(want, 1.0 - exp(-delta / 0.35))
	# Steered joints follow the turn on a servo, easing toward their limits (Ryan, 7 October,
	# the nineteenth notes: the Prairie Dog's wheels jumped from straight to full lock).
	var steer: Dictionary = gait.get("steer", {})
	for name in steer.keys():
		_steer[name] = lerpf(float(_steer.get(name, 0.0)), steer_soft(name, turn * float(steer[name])), 1.0 - exp(-delta / STEER_EASE))
	# The slide: a body with inertia sits off a path that turned under it, on the outside,
	# by how square the travel is to its facing (the Dingo's drift; a hovercraft's a little).
	var drift_want := float(move.get("slide", 0.0)) * DRIFT_UNITS * sin(aim) * clampf(_speed / MOVE_REF_SPEED, 0.0, 1.0)
	_drift = lerpf(_drift, drift_want, 1.0 - exp(-delta / 0.3))
	_evaluate_gait(aim, turn)
	_pose()


## Setting off from a standstill with a start gait that hands over: the start gait set to its
## handoff's moment, when it is not yet showing (a machine that stepped round on the spot
## first keeps its step, and the change counts from that moment of its stride nearest now),
## and the gait's own phase set to meet the change's end.
func _set_off(stood: bool) -> void:
	if not _start_gait.has("handoff"):
		return
	var s := maxf(1.0, float((_start_gait["gait"] as Dictionary).get("stride", 40.0)))
	if stood:
		_start_offset = float(_start_gait["from"]) * s - _dist
		_handoff_at = _dist
	else:
		var past := fposmod((_dist + _start_offset) / s - float(_start_gait["from"]) + 0.5, 1.0) - 0.5
		_handoff_at = _dist - past * s
	_main_offset = float(_start_gait["to"]) * maxf(1.0, float(gait.get("stride", 40.0))) - _handoff_at
	_handing = true


## How much of its moving is the gait it starts and stops in, by its share of its full
## speed: 1 under the start's `below`, 0 over its `full` (0 for a gait that names none); and
## wholly that gait standing, and off the mark until the stride it changes in begins.
func start_weight() -> float:
	if _start_gait.is_empty():
		return 0.0
	if _start_gait.has("handoff") and (not _handing or _dist < _handoff_at):
		return 1.0
	return 1.0 - smoothstep(float(_start_gait["below"]), float(_start_gait["full"]), _speed / maxf(1.0, top_speed))


## Whether the stride a machine changes gait in is playing (the twenty-second notes): from
## its handoff's start to its length, after which the gait's own cycle takes over where the
## change ends.
func changing() -> bool:
	return _handing and _start_gait.has("handoff") and _dist >= _handoff_at and _dist - _handoff_at < float(_start_gait["handoff"]["stride"])


## A gait's cycles at `weight` (its tracks and its body's bob, each at its stride's phase,
## `offset` units on), added to the gait's joints and to `body` ([slide, turn]).
func _add_cycles(g: Dictionary, curves: Dictionary, weight: float, offset: float, body_out: Array) -> void:
	if weight <= 0.0:
		return
	var phase := fposmod((_dist + offset) / maxf(1.0, float(g.get("stride", 40.0))), 1.0)
	var k := _blend * weight
	var tracks: Dictionary = g.get("tracks", {})
	for name in tracks.keys():
		if not joints.has(name) or not curves.has(name):
			continue
		var tr: Dictionary = tracks[name]
		var v := curve_at(curves[name], fposmod(phase + float(tr.get("phase", 0.0)), 1.0))
		if v.size() >= 3:
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(float(v[0]), float(v[1]), float(v[2])) * k
		if v.size() >= 6:
			_gait_slide[name] = _gait_slide.get(name, Vector3.ZERO) + Vector3(float(v[3]), float(v[4]), float(v[5])) * k
	if curves.has(BODY):
		var v := curve_at(curves[BODY], phase)
		if v.size() >= 6:
			body_out[0] += Vector3(float(v[0]), float(v[1]), float(v[2])) * k
			body_out[1] += Vector3(float(v[4]), float(v[3]), float(v[5])) * k   # authored (yaw, pitch, roll)


## Degrees a steered joint turns for `raw` (its gain times the turn rate): eased toward its
## limit on its axis that way rather than stopped hard at it, so a knuckle comes round to full
## lock as the turn builds.
func steer_soft(name: String, raw: float) -> float:
	var m: Dictionary = meta.get(name, {})
	var lim: Dictionary = m.get("limits", {})
	var axis := str(m.get("axis", "yaw"))
	if not (lim.has(axis) and lim[axis] is Array and (lim[axis] as Array).size() == 2):
		return raw
	var edge := absf(float(lim[axis][1] if raw > 0.0 else lim[axis][0]))
	return raw if edge <= 0.0 else edge * tanh(raw / edge)


func _evaluate_gait(aim: float, turn: float) -> void:
	_gait_rot.clear()
	_gait_slide.clear()
	# The cycles: a walk, stride by stride, and the gait it starts and stops in by its share
	# of the speed (use_gait), each at its own stride's phase.
	# Off the mark, the stride it changes gait in plays in place of its own (use_gait).
	var start_w := start_weight()
	var cyc_body := [Vector3.ZERO, Vector3.ZERO]   # the body's (slide, turn) from the cycles
	if changing():
		_add_cycles(_start_gait["handoff"], _start_gait["handoff"]["curves"], 1.0 - start_w, -_handoff_at, cyc_body)
	else:
		_add_cycles(gait, _gait_curves, 1.0 - start_w, _main_offset, cyc_body)
	if start_w > 0.0:
		_add_cycles(_start_gait["gait"], _start_gait["curves"], start_w, _start_offset, cyc_body)
	# Wheels spin by their radius, forward a negative pitch, and never unwind.
	var wheels: Dictionary = gait.get("wheels", {})
	for name in wheels.keys():
		if joints.has(name):
			var r := maxf(0.1, float(wheels[name]))
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(-fposmod(rad_to_deg(_dist / r), 360.0), 0.0, 0.0)
	# Steering knuckles turn with the turn, each about its own axis (a knuckle yaws; the Goshawk's
	# nacelles pitch, vectoring through a turn: Ryan, 7 October, the eighteenth notes), as far
	# as their servo has followed it (drive); casters point along the travel.
	var steer: Dictionary = gait.get("steer", {})
	for name in steer.keys():
		if joints.has(name):
			var by := Vector3.ZERO
			by[maxi(0, ["pitch", "yaw", "roll"].find(str(meta.get(name, {}).get("axis", "yaw"))))] = float(_steer.get(name, 0.0)) * _blend
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + by
	var casters: Dictionary = gait.get("aim", {})
	for name in casters.keys():
		if joints.has(name):
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(0.0, rad_to_deg(aim) * float(casters[name]) * _blend, 0.0)
	# Offsets held while moving: a claw carried clear of the ground, nacelles tilted.
	var hold: Dictionary = gait.get("hold", {})
	for name in hold.keys():
		if joints.has(name):
			var h: Array = hold[name]
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(float(h[0]), float(h[1]), float(h[2])) * _blend
	# The body: a bob over the cycle, a held attitude, the rock on pulling away and
	# stopping, and the bank into a turn.
	var body_rot: Vector3 = cyc_body[1]
	var body_slide: Vector3 = cyc_body[0]
	var bh: Array = gait.get("body_hold", [])
	if bh.size() >= 6:
		body_slide += Vector3(float(bh[0]), float(bh[1]), float(bh[2])) * _blend
		body_rot += Vector3(float(bh[4]), float(bh[3]), float(bh[5])) * _blend
	var rock := float(gait.get("rock", 0.0))
	if rock != 0.0:
		body_rot.x += rock * clampf(_accel / ROCK_ACCEL, -1.0, 1.0)   # pulling away rocks the nose up
	body_rot.z += _bank + _tilt.y
	body_rot.x += _tilt.x
	body_slide.x += _drift
	_body_move_rot = body_rot
	_body_move_slide = body_slide
	# Treads scroll with the distance; boosters brighten with the move.
	var treads: Dictionary = gait.get("treads", {})
	if not _tread_mats.is_empty():
		var scroll := float(treads.get("scroll", 1.0)) * _dist / 14.0   # one tile (TILE_WORLD) per fourteen model units
		for row in _tread_mats:
			var m: StandardMaterial3D = row[0]
			m.uv1_offset = (row[1] as Vector3) + Vector3(fposmod(scroll, 1.0), 0.0, 0.0)
	if not _move_glow.is_empty():
		var k := 1.0 + float(gait.get("glow", {}).get("k", 1.0)) * _blend
		for row in _move_glow:
			(row[0] as StandardMaterial3D).emission_energy_multiplier = float(row[1]) * k


## The tread materials, by the meshes' names: scrolling their first UV runs the tread.
func _tread_named(node: Node, part: String) -> void:
	if node is MeshInstance3D and labelled(node.name, part):
		var mi: MeshInstance3D = node
		for i in range(mi.get_surface_override_material_count()):
			var sm := mi.get_surface_override_material(i)
			if sm is StandardMaterial3D:
				_tread_mats.append([sm, (sm as StandardMaterial3D).uv1_offset])
	for c in node.get_children():
		_tread_named(c, part)


static func _strike_envelope(st: Dictionary) -> float:
	var t := float(st["t"])
	var up := float(st["up"])
	var down := float(st["down"])
	if t < up:
		var f := t / up
		return 1.0 - (1.0 - f) * (1.0 - f)   # out: fast away
	var g := clampf((t - up) / down, 0.0, 1.0)
	return 1.0 - g * g * (3.0 - 2.0 * g)   # in-out: settling back


## A blow. Melee: the joints that swing (the shoulders, by the sidecar or by name) throw the
## arms forward. Ranged: every joint that carries a weapon socket kicks about its own axis,
## a recoil, toward whichever side its limits allow (a Clydesdale turret flinches outward).
## Does nothing on an untagged model.
func strike(ranged: bool) -> void:
	if joints.is_empty():
		return
	var armed := {}
	for n in hardpoints.keys():
		var owner := joint_of(hardpoints[n])
		if not owner.is_empty():
			armed[owner] = true
	for name in joints.keys():
		var m: Dictionary = meta.get(name, {})
		var axis := str(m.get("axis", axis_for(name)))
		var swing_deg: float
		if ranged:
			if not armed.has(name):
				continue
			swing_deg = 5.0
		elif not bool(m.get("swing", false)):
			continue
		else:
			swing_deg = -29.0
		var lim: Dictionary = m.get("limits", {})
		if lim.has(axis) and lim[axis] is Array and (lim[axis] as Array).size() == 2:
			var lo := float(lim[axis][0])
			var hi := float(lim[axis][1])
			if swing_deg > 0.0 and hi <= 0.0 and lo < 0.0:
				swing_deg = -swing_deg
			elif swing_deg < 0.0 and lo >= 0.0 and hi > 0.0:
				swing_deg = -swing_deg
		var vec := Vector3.ZERO
		vec[["pitch", "yaw", "roll"].find(axis)] = swing_deg
		_strikes.append({"joint": name, "vec": vec, "up": 0.05 if ranged else 0.10, "down": 0.2 if ranged else 0.28, "t": 0.0})
	_pose()


## The joint a node hangs under, by name, or "" when it is on the body.
func joint_of(node: Node) -> String:
	var p := node.get_parent()
	while p != null and p != model:
		var tag := parse_tag(p.name)
		if tag.size() == 2 and tag[0] == "joint":
			return str(tag[1])
		p = p.get_parent()
	return ""


## The lit surfaces a glow track drives: every emissive override material on the meshes
## whose name begins with `part` (a lowforge label), or under the joint or socket named
## (`joint_turret`, `hp_3`). Per instance: MechView3D.toon duplicates every material.
func _lit_materials(part: String) -> Array:
	if _glow_cache.has(part):
		return _glow_cache[part]
	var out: Array = []
	var tag := parse_tag(part)
	if tag.size() == 2:
		var root: Node = joints.get(tag[1], null) if tag[0] == "joint" else hardpoints.get(tag[1], null)
		if root != null:
			_lit_under(root, out)
	else:
		_lit_named(model, part, out)
	_glow_cache[part] = out
	return out


## Whether a node carries a lowforge label: the label itself, or the label with the
## importer's numbering ("tread_001"), never another label that merely starts the same
## ("tread_deck").
static func labelled(node_name: String, part: String) -> bool:
	if node_name == part:
		return true
	if not node_name.begins_with(part):
		return false
	var rest := node_name.substr(part.length())
	return rest.begins_with("_") and rest.substr(1).is_valid_int() or (rest.begins_with(".") and rest.substr(1).is_valid_int())


func _lit_named(node: Node, part: String, out: Array) -> void:
	if node is MeshInstance3D and labelled(node.name, part):
		_lit_under(node, out)
	else:
		for c in node.get_children():
			_lit_named(c, part, out)


func _lit_under(node: Node, out: Array) -> void:
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		for i in range(mi.get_surface_override_material_count()):
			var sm := mi.get_surface_override_material(i)
			if sm is StandardMaterial3D and (sm as StandardMaterial3D).emission_enabled and not out.has(sm):
				out.append(sm)
	for c in node.get_children():
		_lit_under(c, out)

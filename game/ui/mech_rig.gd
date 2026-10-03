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
## way (`tilt` in its cornering numbers; the map holds its facing through `strafe`).
## RIFTGATE_MOVE_DEBUG=1 drives every machine constantly at the reference speed, on both
## screens, for judging a gait running.

const GAP_MIN := 2.5          # seconds between acts, at least
const GAP_MAX := 6.5          # and at most
const GAP_DEBUG := 0.4        # with the debug switch on
const GLOW_BASE := 1.8        # the amber role's emission at rest (MechView3D.toon)
const MOVE_REF_SPEED := 300.0 # model units a second: about a hex in the map's fastest step (BattleMapView.MOVE_SECONDS_PER_HEX)
const MOVE_BLEND_IN := 0.25   # seconds a gait takes to come up from standing
const MOVE_BLEND_OUT := 0.35  # and to settle back when the machine stops
const ROCK_ACCEL := 1500.0    # model units a second squared that earns the whole rock
const BANK_TURN := 2.0        # radians a second of turning that earns the whole bank
const DRIFT_UNITS := 12.0     # model units a machine with a slide of 1 drifts off its path when the travel is square to its facing
const AIM_HOLD_MAX := 170.0   # degrees a turret may wind up holding its aim against a turning hull
const AIM_RELAX := 0.8        # seconds for a held aim to come back to centre once the hull stops turning

var joints: Dictionary = {}        # "shoulder_l" -> Node3D
var hardpoints: Dictionary = {}    # 1 -> Node3D
var meta: Dictionary = {}          # joint name -> {"axis", "limits", "swing", "parent"} (the sidecar; a bare default for an untagged joint)
var acts: Array = []               # the sidecar's acts, in authoring order
var move: Dictionary = {}          # the cornering numbers: {"slide", "bank"}
var model: Node3D = null           # the glTF's root
var body: Node3D = null            # the node a body track moves (the model root unless told otherwise)
var gait: Dictionary = {}          # the sidecar's gait: how this machine moves (see drive)
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
var _drift := 0.0                  # model units the body sits off its path, right positive, eased (the slide)
var _aim_hold: Dictionary = {}     # joint -> degrees of yaw a turret holds against the hull's turning
var _tread_mats: Array = []        # [[StandardMaterial3D, base uv offset]] the treads scroll
var _move_glow: Array = []         # [[StandardMaterial3D, base]] the boosters brighten
var _current: Dictionary = {}      # the act playing, or empty
var _t := 0.0                      # time into the act playing
var _wait := 0.0                   # seconds until the next act starts
var _rng := RandomNumberGenerator.new()


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


## Keys sampled at `t`: each key is [t, v1, v2, ...]; the track rests (every value zero) at
## time 0 and again at `duration`, so an act always returns the machine to its pose. Between
## keys the values ease ("smooth") or run straight ("linear", a wheel spinning).
static func sample(keys: Array, t: float, duration: float, ease: String = "smooth") -> Array:
	var width := 1
	for k in keys:
		width = maxi(width, (k as Array).size())
	var zero: Array = []
	for i in range(width):
		zero.append(0.0)
	var pts: Array = []
	if keys.is_empty() or float(keys[0][0]) > 0.0:
		pts.append(zero)
	for k in keys:
		var row: Array = (k as Array).duplicate()
		while row.size() < width:
			row.append(0.0)
		pts.append(row)
	if float(pts[pts.size() - 1][0]) < duration:
		var end := zero.duplicate()
		end[0] = duration
		pts.append(end)
	if t <= float(pts[0][0]):
		return pts[0].slice(1)
	for i in range(1, pts.size()):
		var a: Array = pts[i - 1]
		var b: Array = pts[i]
		if t <= float(b[0]):
			var span := float(b[0]) - float(a[0])
			var f := 1.0 if span <= 0.0 else (t - float(a[0])) / span
			if ease != "linear":
				f = f * f * (3.0 - 2.0 * f)
			var out: Array = []
			for j in range(1, width):
				out.append(lerpf(float(a[j]), float(b[j]), f))
			return out
	return pts[pts.size() - 1].slice(1)


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
	gait = side.get("gait", {}) if side.get("gait", {}) is Dictionary else {}
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
	_drift = 0.0
	_aim_hold.clear()
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


## Whether anything here moves on its own: acts to play, a strike still swinging, a gait
## under the debug switch.
func alive() -> bool:
	return not acts.is_empty() or not _strikes.is_empty() or not _current.is_empty() or (debug_move and not gait.is_empty())


## Advance the clock: the act playing, the gap to the next one, and the strikes.
func tick(delta: float) -> void:
	if model == null:
		return
	var moved := false
	if not _current.is_empty():
		_t += delta
		_evaluate_act()
		moved = true
		if _t >= float(_current.get("duration", 0.0)):
			_end_act()
	elif not acts.is_empty() and not moving:   # a pilot on the move has no hands free for an act
		_wait -= delta
		if _wait <= 0.0:
			var next := choose()
			if not next.is_empty():
				_start(next)
				_evaluate_act()
				moved = true
	if not _strikes.is_empty():
		for st in _strikes:
			st["t"] = float(st["t"]) + delta
		_strikes = _strikes.filter(func(st): return float(st["t"]) < float(st["up"]) + float(st["down"]))
		moved = true
	if debug_move and not gait.is_empty():
		drive(MOVE_REF_SPEED, 0.0, 0.0, delta)
	elif moved:
		_pose()


## The next act: random among the machine's own, never the one just played (Ryan, 2
## October). With the debug switch naming an act, that act.
func choose() -> Dictionary:
	if acts.is_empty():
		return {}
	if not debug.is_empty() and debug != "1":
		for a in acts:
			if str(a["name"]) == debug:
				return a
	if acts.size() == 1:
		return acts[0]
	var pool: Array = acts.filter(func(a): return str(a["name"]) != last_act)
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
	_glow = []
	for g in a.get("glow", []):
		var mats: Array = []
		for part in g.get("parts", []):
			mats.append_array(_lit_materials(str(part)))
		var base: Array = []
		for m in mats:
			base.append((m as StandardMaterial3D).emission_energy_multiplier)
		_glow.append({"keys": g.get("keys", []), "mats": mats, "base": base})


func _end_act() -> void:
	for g in _glow:
		for i in range(g["mats"].size()):
			(g["mats"][i] as StandardMaterial3D).emission_energy_multiplier = float(g["base"][i])
	_glow = []
	_current = {}
	_act_rot.clear()
	_act_slide.clear()
	_body_act_rot = Vector3.ZERO
	_body_act_slide = Vector3.ZERO
	_wait = GAP_DEBUG if not debug.is_empty() else _rng.randf_range(GAP_MIN, GAP_MAX)
	_pose()


func _evaluate_act() -> void:
	var duration := float(_current.get("duration", 0.0))
	var ease := str(_current.get("ease", "smooth"))
	var tracks: Dictionary = _current.get("tracks", {})
	for name in tracks.keys():
		if not joints.has(name):
			continue
		var v := sample(tracks[name], _t, duration, ease)
		_act_rot[name] = Vector3(float(v[0]), float(v[1]), float(v[2]))
		_act_slide[name] = Vector3(float(v[3]), float(v[4]), float(v[5])) if v.size() >= 6 else Vector3.ZERO
	var body_keys: Array = _current.get("body", [])
	if not body_keys.is_empty():
		var v := sample(body_keys, _t, duration, ease)
		_body_act_slide = Vector3(float(v[0]), float(v[1]), float(v[2]))
		_body_act_rot = Vector3(float(v[4]), float(v[3]), float(v[5]))   # authored (yaw, pitch, roll)
	for g in _glow:
		var k := float(sample(g["keys"], _t, duration, ease)[0]) + 1.0   # the keys are offsets from rest: 0 is the base light
		for i in range(g["mats"].size()):
			(g["mats"][i] as StandardMaterial3D).emission_energy_multiplier = float(g["base"][i]) * maxf(0.0, k)


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
		j.rotation = _rest[name] + euler_of(deg)
		var slide: Vector3 = _act_slide.get(name, Vector3.ZERO) + _gait_slide.get(name, Vector3.ZERO)
		if slide != Vector3.ZERO or j.position != _rest_pos[name]:
			j.position = _rest_pos[name] + offset_of(slide)
	if body != null:
		body.position = _body_rest_pos + offset_of(_body_act_slide + _body_move_slide)
		body.rotation = _body_rest_rot + euler_of(_body_act_rot + _body_move_rot)


# ---------------------------------------------------------------- movement

## Cyclic keys sampled at a phase in [0, 1): the track wraps, so the key at 1 is the key at 0
## unless one is authored there; eased between keys like an act's.
static func sample_cycle(keys: Array, phase: float, ease: String = "smooth") -> Array:
	if keys.is_empty():
		return []
	var pts: Array = []
	for k in keys:
		pts.append((k as Array).duplicate())
	pts.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	var first: Array = pts[0]
	if float(first[0]) > 0.0:
		var k0 := first.duplicate()
		k0[0] = float(pts[pts.size() - 1][0]) - 1.0   # the last key, wrapped round before the start
		for i in range(1, k0.size()):
			k0[i] = pts[pts.size() - 1][i]
		pts.push_front(k0)
	if float(pts[pts.size() - 1][0]) < 1.0:
		var k1: Array = pts[0].duplicate() if float(pts[0][0]) >= 0.0 else pts[1].duplicate()
		k1[0] = float(k1[0]) + 1.0
		pts.append(k1)
	var p := fposmod(phase, 1.0)
	return sample(pts, p, 2.0, ease)


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
	moving = speed > 0.5
	var target := 1.0 if moving else 0.0
	var rate := MOVE_BLEND_IN if moving else MOVE_BLEND_OUT
	_blend = move_toward(_blend, target, delta / rate)
	_dist += _speed * delta
	var bank_want := float(move.get("bank", 0.0)) * clampf(-turn / BANK_TURN, -1.0, 1.0)   # a left turn drops the left wing: roll negative
	_bank = lerpf(_bank, bank_want, 1.0 - exp(-delta / 0.3))
	# A helicopter's tilt: it leans into its travel by its speed, nose down going forward,
	# nose up going back, the left side down going left (the roll is positive right-down).
	var tilt_spec: Array = move.get("tilt", [])
	if tilt_spec.size() >= 2:
		var share := clampf(_speed / MOVE_REF_SPEED, 0.0, 1.0)
		var want := Vector2(-float(tilt_spec[0]) * cos(aim), -float(tilt_spec[1]) * sin(aim)) * share
		_tilt = _tilt.lerp(want, 1.0 - exp(-delta / 0.35))
	# The slide: a body with inertia sits off a path that turned under it, on the outside,
	# by how square the travel is to its facing (the Dingo's drift; a hovercraft's a little).
	var drift_want := float(move.get("slide", 0.0)) * DRIFT_UNITS * sin(aim) * clampf(_speed / MOVE_REF_SPEED, 0.0, 1.0)
	_drift = lerpf(_drift, drift_want, 1.0 - exp(-delta / 0.3))
	# A turret holding its aim while the hull turns under it: it winds against the turn and
	# relaxes back to centre once the hull runs straight (the Wild Boar, the Prairie Dog).
	for name in gait.get("hold_aim", {}).keys():
		var held := float(_aim_hold.get(name, 0.0))
		if absf(turn) > 0.15:
			held = clampf(held - rad_to_deg(turn) * delta * float(gait["hold_aim"][name]), -AIM_HOLD_MAX, AIM_HOLD_MAX)
		else:
			held = lerpf(held, 0.0, 1.0 - exp(-delta / AIM_RELAX))
		_aim_hold[name] = held
	_evaluate_gait(aim, turn)
	_pose()


func _evaluate_gait(aim: float, turn: float) -> void:
	_gait_rot.clear()
	_gait_slide.clear()
	var stride := maxf(1.0, float(gait.get("stride", 40.0)))
	var phase := fposmod(_dist / stride, 1.0)
	var ease := str(gait.get("ease", "smooth"))
	# The cycles: a walk, stride by stride.
	var tracks: Dictionary = gait.get("tracks", {})
	for name in tracks.keys():
		if not joints.has(name):
			continue
		var tr: Dictionary = tracks[name]
		var v := sample_cycle(tr.get("keys", []), phase + float(tr.get("phase", 0.0)), ease)
		if v.size() >= 3:
			_gait_rot[name] = Vector3(float(v[0]), float(v[1]), float(v[2])) * _blend
		if v.size() >= 6:
			_gait_slide[name] = Vector3(float(v[3]), float(v[4]), float(v[5])) * _blend
	# Wheels spin by their radius, forward a negative pitch, and never unwind.
	var wheels: Dictionary = gait.get("wheels", {})
	for name in wheels.keys():
		if joints.has(name):
			var r := maxf(0.1, float(wheels[name]))
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(-fposmod(rad_to_deg(_dist / r), 360.0), 0.0, 0.0)
	# Steering knuckles turn with the turn; casters point along the travel.
	var steer: Dictionary = gait.get("steer", {})
	for name in steer.keys():
		if joints.has(name):
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(0.0, rad_to_deg(turn) * float(steer[name]) * _blend, 0.0)
	var casters: Dictionary = gait.get("aim", {})
	for name in casters.keys():
		if joints.has(name):
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(0.0, rad_to_deg(aim) * float(casters[name]) * _blend, 0.0)
	for name in _aim_hold.keys():
		if joints.has(name):
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(0.0, float(_aim_hold[name]), 0.0)
	# Offsets held while moving: a claw carried clear of the ground, nacelles tilted.
	var hold: Dictionary = gait.get("hold", {})
	for name in hold.keys():
		if joints.has(name):
			var h: Array = hold[name]
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(float(h[0]), float(h[1]), float(h[2])) * _blend
	# The body: a bob over the cycle, a held attitude, the rock on pulling away and
	# stopping, and the bank into a turn.
	var body_rot := Vector3.ZERO
	var body_slide := Vector3.ZERO
	var body_keys: Array = gait.get("body", [])
	if not body_keys.is_empty():
		var v := sample_cycle(body_keys, phase, ease)
		if v.size() >= 6:
			body_slide += Vector3(float(v[0]), float(v[1]), float(v[2])) * _blend
			body_rot += Vector3(float(v[4]), float(v[3]), float(v[5])) * _blend   # authored (yaw, pitch, roll)
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

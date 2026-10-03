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

const GAP_MIN := 2.5          # seconds between acts, at least
const GAP_MAX := 6.5          # and at most
const GAP_DEBUG := 0.4        # with the debug switch on
const GLOW_BASE := 1.8        # the amber role's emission at rest (MechView3D.toon)

var joints: Dictionary = {}        # "shoulder_l" -> Node3D
var hardpoints: Dictionary = {}    # 1 -> Node3D
var meta: Dictionary = {}          # joint name -> {"axis", "limits", "swing", "parent"} (the sidecar; a bare default for an untagged joint)
var acts: Array = []               # the sidecar's acts, in authoring order
var move: Dictionary = {}          # the cornering numbers: {"slide", "bank"}
var model: Node3D = null           # the glTF's root
var body: Node3D = null            # the node a body track moves (the model root unless told otherwise)
var debug: String = ""             # RIFTGATE_ACTS_DEBUG, read at setup
var last_act: String = ""          # the act played last (never played twice running)

var _rest: Dictionary = {}         # joint -> rest rotation
var _rest_pos: Dictionary = {}     # joint -> rest position
var _body_rest_pos := Vector3.ZERO
var _body_rest_rot := Vector3.ZERO
var _act_rot: Dictionary = {}      # joint -> degrees (pitch, yaw, roll) from the act playing
var _act_slide: Dictionary = {}    # joint -> world-unit slide (dx, dy, dz, Blender's axes)
var _strikes: Array = []           # [{joint, vec (degrees), up, down, t}]
var _glow: Array = []              # [{mats: [StandardMaterial3D], base: [float]}] per glow track of the act playing
var _glow_cache: Dictionary = {}   # part prefix -> [StandardMaterial3D]
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
	_body_rest_pos = body.position
	_body_rest_rot = body.rotation
	_rng.seed = hash(model_id) ^ (randi() if phase < 0 else phase * 7919)
	debug = OS.get_environment("RIFTGATE_ACTS_DEBUG")
	_wait = GAP_DEBUG if not debug.is_empty() else _rng.randf_range(0.6, GAP_MAX)
	_glow_cache.clear()


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


## Whether anything here moves on its own: acts to play, or a strike still swinging.
func alive() -> bool:
	return not acts.is_empty() or not _strikes.is_empty() or not _current.is_empty()


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
	elif not acts.is_empty():
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
	if moved:
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
	if not body_keys.is_empty() and body != null:
		var v := sample(body_keys, _t, duration, ease)
		body.position = _body_rest_pos + offset_of(Vector3(float(v[0]), float(v[1]), float(v[2])))
		body.rotation = _body_rest_rot + euler_of(Vector3(float(v[4]), float(v[3]), float(v[5])))   # authored (yaw, pitch, roll)
	for g in _glow:
		var k := float(sample(g["keys"], _t, duration, ease)[0]) + 1.0   # the keys are offsets from rest: 0 is the base light
		for i in range(g["mats"].size()):
			(g["mats"][i] as StandardMaterial3D).emission_energy_multiplier = float(g["base"][i]) * maxf(0.0, k)


## Rest plus the act plus the strikes, clamped to the joint's limits, on every joint.
func _pose() -> void:
	for name in joints.keys():
		var j: Node3D = joints[name]
		var deg: Vector3 = _act_rot.get(name, Vector3.ZERO)
		for st in _strikes:
			if st["joint"] == name:
				deg += (st["vec"] as Vector3) * _strike_envelope(st)
		var m: Dictionary = meta.get(name, {})
		deg = clamp_degrees(deg, m.get("limits", {}))
		j.rotation = _rest[name] + euler_of(deg)
		var slide: Vector3 = _act_slide.get(name, Vector3.ZERO)
		if slide != Vector3.ZERO or j.position != _rest_pos[name]:
			j.position = _rest_pos[name] + offset_of(slide)


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


func _lit_named(node: Node, part: String, out: Array) -> void:
	if node is MeshInstance3D and node.name.begins_with(part):
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

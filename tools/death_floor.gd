extends SceneTree

## Where each machine lies once it is lost (MechRig.kill: its own death, or the slump), read by
## MechRig.rest_of once the death has played out: how far its lowest point is off the floor, the
## joints whose parts touch it, and whether it rests on what touches (its middle inside the outline
## of what lies on the floor; below zero, the way it would tip). A pose propped on an arm's tip, or
## one whose legs float with its fists on the ground, tips (16 November).
##   perl -e 'alarm 600; exec @ARGV' godot --headless --path . -s tools/death_floor.gd -- [ids,comma,separated] [--joints] [--try variants.json]
## With no ids, every chassis with a model. Heights and margins are shares of the machine's size.
## --joints prints every joint's place at rest and once lost (y up off the floor, -z forward) and
## the lowest point it carries. --try reads a list of variants, each {"id", "label", "tracks":
## {joint: [pitch, yaw, roll] or keys [[t, pitch, yaw, roll], ...]}, "body": [dx, dy, dz, yaw,
## pitch, roll] or keys [[t, dx, dy, dz, yaw, pitch, roll], ...], "duration", "hang": [joints],
## "ease", "report": [joints whose place to print, off its middle: x right, y up, z back, shares
## of its size]}, laid over the machine's own death (a joint named turns to its values from rest, or
## rides its keys; one not named keeps its track), each read in its turn: a pose tried without a
## rebuild. "drift" is how far its middle has moved off where it stood, a share of its size.

const SETTLE_S := 4.0     # seconds after the kill to read the pose: every death and slump done

var _variant := {}     # the variant being read (--try), laid over the machine's death
var _joints := false   # --joints


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var ids: Array = []
	var tries: Array = []
	var i := 0
	while i < args.size():
		if args[i] == "--joints":
			_joints = true
			i += 1
			continue
		if args[i] == "--try" and i + 1 < args.size():
			tries = JSON.parse_string(FileAccess.get_file_as_string(args[i + 1]))
			i += 2
			continue
		for s in args[i].split(","):
			if not s.is_empty():
				ids.append(s)
		i += 1
	var db := ContentDB.load_default()
	if not tries.is_empty():
		for v in tries:
			_variant = v
			var r := read(str(v["id"]), db)
			if not r.is_empty():
				print("%-24s %s" % [str(v.get("label", "")), line(r)])
		quit()
		return
	if ids.is_empty():
		for id in db.chassis.keys():
			if ResourceLoader.exists("res://art/models/%s.glb" % id):
				ids.append(id)
	var tips := 0
	for id in ids:
		var r := read(str(id), db)
		if r.is_empty():
			continue
		print(line(r))
		if float(r["margin"]) <= 0.0:
			tips += 1
	print("%d of %d rest on what touches the floor" % [ids.size() - tips, ids.size()])
	quit()


## One machine lost and read (MechRig.rest_of, with "id" and "death").
func read(id: String, db: ContentDB) -> Dictionary:
	var maker := str(db.chassis.get(id, {}).get("maker", ""))
	var view := MechView3D.make(id, maker, "clean", "badger", MechView3D.YAW_FRONT, Vector2i(64, 64), false, {}, [])
	root.add_child(view)
	view.set_process(false)
	var rig: MechRig = view.rig
	if rig == null or rig.model == null:
		view.queue_free()
		return {}
	if not _variant.is_empty():
		rig.forms[MechRig.DEATH] = rig._form_entry(_laid_over(id, _variant))
	var at_rest := {}
	for jn in rig.joints.keys():
		at_rest[jn] = _in_frame(rig, rig.joints[jn]).origin
	var stood := _middle(rig)
	view.lose()
	var t := 0.0
	while t < SETTLE_S:
		rig.tick(1.0 / 60.0)
		t += 1.0 / 60.0
	var r := rig.rest_of()
	if not r.is_empty():
		r["drift"] = _middle(rig).distance_to(stood) / float(r["size"])
		var at: Array = []
		for jn in _variant.get("report", []):
			if rig.joints.has(str(jn)):
				var o := _in_frame(rig, rig.joints[str(jn)]).origin
				var m := _middle(rig)
				at.append("%s (%+.0f, %+.0f, %+.0f)" % [jn, 100.0 * (o.x - m.x) / float(r["size"]), 100.0 * (o.y - float(rig.get("_body_rest_pos").y)) / float(r["size"]), 100.0 * (o.z - m.y) / float(r["size"])])
		r["at"] = ", ".join(at)
	if _joints:
		var floor_y := float(rig.get("_body_rest_pos").y) + rig.collapse_floor
		var names := rig.joints.keys()
		names.sort()
		for jn in names:
			var now := _in_frame(rig, rig.joints[jn]).origin
			var was: Vector3 = at_rest[jn]
			print("   %-16s rest (%6.2f %6.2f %6.2f)  lost (%6.2f %6.2f %6.2f)  lowest under it %+6.2f" % [jn, was.x, was.y - floor_y, was.z, now.x, now.y - floor_y, now.z,
				rig._lowest_under(rig.joints[jn], _in_frame(rig, rig.model)) - floor_y])
	view.queue_free()
	if r.is_empty():
		return {}
	r["id"] = id
	r["death"] = rig.forms.has(MechRig.DEATH)
	return r


func line(r: Dictionary) -> String:
	var touching: Array = r["touching"]
	touching.sort()
	return "%-14s %-6s low %+5.1f%% top %5.1f%% drift %4.1f%%  %s by %+5.1f%% · touching: %s" % [r["id"], "death" if r["death"] else "slump", 100.0 * float(r["low"]), 100.0 * float(r["top"]),
		100.0 * float(r.get("drift", 0.0)), "RESTS" if float(r["margin"]) > 0.0 else ("TIPS %-7s" % r["tips"]), 100.0 * float(r["margin"]), ", ".join(touching)] + \
		((" · at: " + str(r["at"])) if not str(r.get("at", "")).is_empty() else "")


## A node's transform in the frame the body moves in (the tree is not running in _init, so no
## global transforms).
static func _in_frame(rig: MechRig, node: Node) -> Transform3D:
	var frame: Node = rig.body.get_parent()
	var xf := Transform3D.IDENTITY
	var n := node
	while n != null and n != frame:
		if n is Node3D:
			xf = (n as Node3D).transform * xf
		n = n.get_parent()
	return xf


## The middle of what the machine shows, on the floor's plane: every vertex's, as rest_of reads it.
static func _middle(rig: MechRig) -> Vector2:
	var sum := Vector3.ZERO
	var n := 0
	for mi in rig.model.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		var shown := true
		var up: Node = m
		while up != null and up != rig.model:
			shown = shown and (not (up is Node3D) or (up as Node3D).visible)
			up = up.get_parent()
		if not shown or m.mesh == null or m.has_meta("halo") or m.has_meta("plume") or m.has_meta("is_trace"):
			continue
		var c: Array = rig._centroid_of(m.mesh)
		sum += (rig.body.transform * rig._in_model(m) * (c[0] as Vector3)) * float(c[1])
		n += int(c[1])
	var p := sum / float(maxi(1, n))
	return Vector2(p.x, p.z)


## A variant (--try) laid over the machine's own death, in the sidecar's form: each joint it names
## turns from rest to its values over the duration, the body likewise; the rest as built.
static func _laid_over(id: String, v: Dictionary) -> Dictionary:
	var side = JSON.parse_string(FileAccess.get_file_as_string("res://art/models/%s.rig.json" % id))
	var base: Dictionary = ((side as Dictionary).get("death", {}) as Dictionary).duplicate(true) if side is Dictionary else {}
	var d := float(v.get("duration", base.get("duration", 1.0)))
	base["duration"] = d
	var tracks: Dictionary = base.get("tracks", {})
	var named: Dictionary = v.get("tracks", {})
	for jn in named.keys():
		var to: Array = named[jn]
		if not to.is_empty() and to[0] is Array:
			tracks[jn] = to.duplicate(true)   # its own keys
		else:
			tracks[jn] = [[0.0, 0.0, 0.0, 0.0], [d, float(to[0]), float(to[1]) if to.size() > 1 else 0.0, float(to[2]) if to.size() > 2 else 0.0]]
	base["tracks"] = tracks
	if v.has("body"):
		var b: Array = v["body"]
		base["body"] = b.duplicate(true) if not b.is_empty() and b[0] is Array else [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [d] + b]
	if v.has("hang"):
		base["hang"] = (v["hang"] as Array).duplicate()
	if v.has("ease"):
		base["ease"] = str(v["ease"])
	return base

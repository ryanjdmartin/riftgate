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
## "ease", "plant": [joint or [joint, from, to]], "untrack": [joints whose tracks to
## drop], "report": [joints whose place to
## print, off its middle: x right, y up, z back, shares
## of its size]}, laid over the machine's own death (a joint named turns to its values from rest, or
## rides its keys; one not named keeps its track), each read in its turn: a pose tried without a
## rebuild. "drift" is how far its middle has moved off where it stood, a share of its size.
## --slide follows every part that stands on the floor at rest (a foot, a planted hand) through
## the fall, 60 times a second: how far the points it stands on move along the floor while they
## touch it, from where they stood or last came down (a share of its size; a biped's feet may not
## slide at all, a quad's one pair at most: Ryan, 16 November, the fifth notes), and how often it
## lifted and came down again (a step); and "clear", how high the hull (what no joint carries)
## ends above the floor, where a body held up on splayed legs reads as floating.
## --clip lists the pairs of parts (by the joint that carries each) whose surfaces cross where
## it lies and did not at rest, or cross far more than at rest (the fifth notes: "Every limb clips
## through every other limb"), with how many edges cross; two parts either side of one joint meeting at
## it (a shin's end in its foot's housing as the ankle bends) count only past JOINED edges.

const SETTLE_S := 4.0     # seconds after the kill to read the pose: every death and slump done
const TOUCH := 0.02       # a share of its size: a point this near the floor stands on it (rest_of's)
const PIVOT := 0.005      # a share of its size: the points of a foot this near its lowest are what it turns on
const JOINED := 8         # edges two parts on either side of one joint may cross more than at rest, meeting at it (--clip)

var _variant := {}     # the variant being read (--try), laid over the machine's death
var _joints := false   # --joints
var _slide := false    # --slide
var _clip := false     # --clip
var _tris := {}        # mesh -> [its triangles' corners, its edges' ends] in its own frame (--clip)


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
		if args[i] == "--slide":
			_slide = true
			i += 1
			continue
		if args[i] == "--clip":
			_clip = true
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
	var meshes := _meshes_of(rig)
	var floor_y := float(rig.get("_body_rest_pos").y)
	var size := rig._model_size()
	var feet := _feet_at_rest(rig, meshes, floor_y, size) if _slide else {}
	var rest_snap := _snapshot(rig, meshes) if _clip else {}
	view.lose()
	var t := 0.0
	while t < SETTLE_S:
		rig.tick(1.0 / 60.0)
		t += 1.0 / 60.0
		if _slide:
			_follow_feet(rig, feet, floor_y, size)
	var r := rig.rest_of()
	if not r.is_empty() and _slide:
		var rows: Array = []
		var names := feet.keys()
		names.sort()
		for owner in names:
			var f: Dictionary = feet[owner]
			rows.append("%s %.1f%%%s" % [owner, 100.0 * float(f["max"]) / size, (" (came down %d)" % int(f["steps"])) if int(f["steps"]) > 0 else ""])
		r["slides"] = ", ".join(rows)
		var clear := INF
		for row in meshes:
			if str(row[1]) == "hull":
				clear = minf(clear, _lowest_of(rig, row[0]))
		r["clear"] = (clear - floor_y) / size if clear != INF else -1.0
	if not r.is_empty() and _clip:
		r["clips"] = _crossings(rest_snap, _snapshot(rig, meshes), meshes, rig.meta)
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
		var jfloor := float(rig.get("_body_rest_pos").y) + rig.collapse_floor
		var names := rig.joints.keys()
		names.sort()
		for jn in names:
			var now := _in_frame(rig, rig.joints[jn]).origin
			var was: Vector3 = at_rest[jn]
			print("   %-16s rest (%6.2f %6.2f %6.2f)  lost (%6.2f %6.2f %6.2f)  lowest under it %+6.2f" % [jn, was.x, was.y - jfloor, was.z, now.x, now.y - jfloor, now.z,
				rig._lowest_under(rig.joints[jn], _in_frame(rig, rig.model)) - jfloor])
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
		((" · at: " + str(r["at"])) if not str(r.get("at", "")).is_empty() else "") + \
		(("\n   slides: %s · clear %.1f%%" % [str(r["slides"]), 100.0 * float(r["clear"])]) if r.has("slides") else "") + \
		(("\n   clips: " + (", ".join(r["clips"]) if not (r["clips"] as Array).is_empty() else "none")) if r.has("clips") else "")


## Every shown surface of the machine and the joint that carries it ("hull" for none), as rest_of reads them.
static func _meshes_of(rig: MechRig) -> Array:
	var by_node := {}
	for jn in rig.joints.keys():
		by_node[rig.joints[jn]] = str(jn)
	var out: Array = []
	for mi in rig.model.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null or m.has_meta("halo") or m.has_meta("plume") or m.has_meta("is_trace"):
			continue
		var shown := true
		var owner := "hull"
		var up: Node = m
		while up != null and up != rig.model:
			shown = shown and (not (up is Node3D) or (up as Node3D).visible)
			if owner == "hull" and up != m and by_node.has(up):
				owner = by_node[up]
			up = up.get_parent()
		if shown:
			out.append([m, owner])
	return out


## A surface's lowest point where it lies now, in the frame the body moves in.
static func _lowest_of(rig: MechRig, mi: MeshInstance3D) -> float:
	var xf := rig.body.transform * rig._in_model(mi)
	var low := INF
	for v in rig._hull_of(mi.mesh):
		low = minf(low, (xf * v).y)
	return low


## The parts that stand on the floor at rest, by the joint that carries them: {owner: {"pts": [[mesh,
## point in its own frame], ...], "anchor": where each stood on the floor, "down", "max", "steps"}}.
static func _feet_at_rest(rig: MechRig, meshes: Array, floor_y: float, size: float) -> Dictionary:
	var feet := {}
	for row in meshes:
		var mi: MeshInstance3D = row[0]
		var xf := rig.body.transform * rig._in_model(mi)
		for v in rig._hull_of(mi.mesh):
			var p := xf * v
			if p.y <= floor_y + TOUCH * size:
				if not feet.has(row[1]):
					feet[row[1]] = {"pts": [], "anchor": PackedVector2Array(), "down": true, "max": 0.0, "steps": 0}
				feet[row[1]]["pts"].append([mi, v])
				feet[row[1]]["anchor"].append(Vector2(p.x, p.z))
	return feet


## One frame of the fall for every foot: down when its lowest point is on the floor; while down, how far
## the points it turns on (its lowest) have moved along the floor from where they stood or came down.
static func _follow_feet(rig: MechRig, feet: Dictionary, floor_y: float, size: float) -> void:
	for owner in feet.keys():
		var f: Dictionary = feet[owner]
		var now := PackedVector3Array()
		var lo := INF
		var xfs := {}
		for pv in f["pts"]:
			var mi: MeshInstance3D = pv[0]
			if not xfs.has(mi):
				xfs[mi] = rig.body.transform * rig._in_model(mi)
			var p: Vector3 = (xfs[mi] as Transform3D) * (pv[1] as Vector3)
			now.append(p)
			lo = minf(lo, p.y)
		var down := lo <= floor_y + TOUCH * size
		if not down:
			f["down"] = false
			continue
		if not bool(f["down"]):
			f["down"] = true
			f["steps"] = int(f["steps"]) + 1
			var again := PackedVector2Array()
			for p in now:
				again.append(Vector2(p.x, p.z))
			f["anchor"] = again
		var sum := 0.0
		var n := 0
		for k in range(now.size()):
			if now[k].y <= lo + PIVOT * size:
				sum += Vector2(now[k].x, now[k].z).distance_to((f["anchor"] as PackedVector2Array)[k])
				n += 1
		if n > 0:
			f["max"] = maxf(float(f["max"]), sum / float(n))


## Every surface's triangles and edges where it lies now, with its box, in the frame the body moves in.
func _snapshot(rig: MechRig, meshes: Array) -> Dictionary:
	var out := {}
	for row in meshes:
		var mi: MeshInstance3D = row[0]
		if not _tris.has(mi.mesh):
			var tris := PackedVector3Array()
			for si in range(mi.mesh.get_surface_count()):
				var arr = mi.mesh.surface_get_arrays(si)
				var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				var idx = arr[Mesh.ARRAY_INDEX]
				if idx is PackedInt32Array and (idx as PackedInt32Array).size() > 0:
					for k in idx:
						tris.append(verts[k])
				else:
					tris.append_array(verts)
			var seen := {}
			var edges := PackedVector3Array()
			for k in range(0, tris.size(), 3):
				for e in [[tris[k], tris[k + 1]], [tris[k + 1], tris[k + 2]], [tris[k + 2], tris[k]]]:
					var a: Vector3 = e[0]
					var b: Vector3 = e[1]
					var key := ("%s|%s" % [a.snappedf(0.001), b.snappedf(0.001)]) if a < b else ("%s|%s" % [b.snappedf(0.001), a.snappedf(0.001)])
					if seen.has(key):
						continue
					seen[key] = true
					edges.append(a)
					edges.append(b)
			_tris[mi.mesh] = [tris, edges]
		var xf := rig.body.transform * rig._in_model(mi)
		var wt := PackedVector3Array()
		var box := AABB()
		var first := true
		for v in (_tris[mi.mesh][0] as PackedVector3Array):
			var p := xf * v
			wt.append(p)
			if first:
				box = AABB(p, Vector3.ZERO)
				first = false
			else:
				box = box.expand(p)
		var we := PackedVector3Array()
		for v in (_tris[mi.mesh][1] as PackedVector3Array):
			we.append(xf * v)
		out[mi] = {"tris": wt, "edges": we, "box": box}
	return out


## The pairs of joints whose surfaces cross in `pose` and did not in `rest`, or cross at more than twice as
## many edges and four more, surface by surface: "owner × owner n (m at rest)", the most edges first.
func _crossings(rest: Dictionary, pose: Dictionary, meshes: Array, rig_meta: Dictionary = {}) -> Array:
	var by_pair := {}   # "owner × owner" -> [edges crossing where it lies, at rest]
	for i in range(meshes.size()):
		for j in range(i + 1, meshes.size()):
			if str(meshes[i][1]) == str(meshes[j][1]):
				continue
			var a: Dictionary = pose[meshes[i][0]]
			var b: Dictionary = pose[meshes[j][0]]
			if not (a["box"] as AABB).grow(0.01).intersects(b["box"]):
				continue
			var n := _edges_through(a["edges"], b["tris"], b["box"]) + _edges_through(b["edges"], a["tris"], a["box"])
			if n == 0:
				continue
			var ra: Dictionary = rest[meshes[i][0]]
			var rb: Dictionary = rest[meshes[j][0]]
			var m := 0
			if (ra["box"] as AABB).grow(0.01).intersects(rb["box"]):
				m = _edges_through(ra["edges"], rb["tris"], rb["box"]) + _edges_through(rb["edges"], ra["tris"], ra["box"])
			var oa := str(meshes[i][1])
			var ob := str(meshes[j][1])
			var next_to: bool = str((rig_meta.get(oa, {}) as Dictionary).get("parent", "")) == ob or str((rig_meta.get(ob, {}) as Dictionary).get("parent", "")) == oa
			if next_to and n < JOINED + 2 * m:
				continue   # two parts meeting at the joint between them (a shin's end in its foot's housing), not a limb through a limb
			if m == 0 or n > 2 * m + 4:
				var names := [str(meshes[i][1]), str(meshes[j][1])]
				names.sort()
				var key := "%s × %s" % names
				var was: Array = by_pair.get(key, [0, 0])
				by_pair[key] = [int(was[0]) + n, int(was[1]) + m]
	var found := by_pair.keys()
	found.sort_custom(func(x, y): return int(by_pair[x][0]) > int(by_pair[y][0]))
	var out: Array = []
	for key in found:
		out.append("%s %d%s" % [key, int(by_pair[key][0]), (" (%d at rest)" % int(by_pair[key][1])) if int(by_pair[key][1]) > 0 else ""])
	return out


## How many of these edges pass through any of these triangles.
static func _edges_through(edges: PackedVector3Array, tris: PackedVector3Array, box: AABB) -> int:
	var n := 0
	var grown := box.grow(0.001)
	for e in range(0, edges.size(), 2):
		var p := edges[e]
		var q := edges[e + 1]
		if not AABB(p, Vector3.ZERO).expand(q).grow(0.001).intersects(grown):
			continue
		for t in range(0, tris.size(), 3):
			if Geometry3D.segment_intersects_triangle(p, q, tris[t], tris[t + 1], tris[t + 2]) != null:
				n += 1
				break
	return n


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
	for jn in v.get("untrack", []):
		tracks.erase(str(jn))
	base["tracks"] = tracks
	if v.has("body"):
		var b: Array = v["body"]
		base["body"] = b.duplicate(true) if not b.is_empty() and b[0] is Array else [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [d] + b]
	if v.has("hang"):
		base["hang"] = (v["hang"] as Array).duplicate()
	if v.has("ease"):
		base["ease"] = str(v["ease"])
	if v.has("plant"):
		base["plant"] = v["plant"]
	return base

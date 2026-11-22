extends SceneTree

## What every piece does as the game's codex prints it, for the hangar page (Ryan, 20 November:
## "there is pretty important hidden text. Bullion fragmenter, for instance, nowhere lists what it
## actually DOES in the hangar - the game says 'Fires the hopper, +2 a load (2 a shot)'"). The
## lines the code composes from a piece's numbers (sim/face.gd's rule phrases, the readout's
## attributes and keywords, a foe move's riders and conditions) are no text anyone writes, so the
## page's text inventory leaves them out; this writes them as the game's own code composes them,
## so the page shows them beside the texts and never drifts from the game:
##   every component, its codex row at its own numbers (EntryReadout.codex_lines): its attributes
##   (what it is, its number, heat, costs, cooldown and target), its keywords and its own rules,
##   and the templates each row is built from (tpl), for the Chassis sheet to edit beside them;
##   every foe, each move the codex lists, its last act after (EntryReadout.codex_move_lines);
##   every template (content/templates.json) those lines and a component's compact line filled,
##   with the pieces that print it and its words there, so the Text tab shows each template beside
##   the lines it makes.
## tools/hangar_data.py runs it into build/hangar/readouts.json; by hand:
##   godot --headless --path . -s tools/hangar_readouts.gd -- [out.json]

const OUT := "res://build/hangar/readouts.json"


func _init() -> void:
	var out := OUT
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out = args[0]
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var data := build(db)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out.get_base_dir()) if out.begins_with("res://") else out.get_base_dir())
	var f := FileAccess.open(out, FileAccess.WRITE)
	if f == null:
		push_error("cannot write %s" % out)
		quit(1)
		return
	f.store_string(JSON.stringify(data, " ", true) + "\n")
	f.close()
	print("readouts: %d components, %d foes into %s" % [(data["components"] as Dictionary).size(), (data["foes"] as Dictionary).size(), out])
	quit(0)


## The readouts as one dictionary: {"components": {id: {"attr", "kw", "rule"}}, "foes": {id:
## [{"id", "name", "attr", "kw", "rule"}]}}, each row the plain words the game draws: its
## attributes, its keywords (a move's riders), its own rules (a move's text among them).
static func build(db: ContentDB) -> Dictionary:
	var comps := {}
	var used := {}
	Templates.tracing = true
	for cid in db.components.keys():
		var comp: Dictionary = db.components[cid]
		var face := db.build_face(comp.get("face", {}))
		face.component = str(cid)
		for t in comp.get("tags", []):
			face.tags.append(str(t))
		var rows := {}
		Templates.traced.clear()
		for l in EntryReadout.codex_lines(face, db, []):
			var g := str(l.get("group", ""))
			if g in ["attr", "kw", "rule"]:
				rows[g] = words(l)
		rows["tpl"] = by_row(rows, Templates.traced)
		comps[str(cid)] = rows
		face.describe()   # its compact line's words too (the quick campaign's lists, a charged form, the log)
		_note(used, db.component_name(str(cid)), "pieces")
	var foes := {}
	for fid in db.foes.keys():
		var foe := db.make_foe(str(fid))
		var moves: Array = []
		for a in db.codex_for_foe(foe).get("moves", []):
			Templates.traced.clear()
			var lines := EntryReadout.codex_move_lines(foe, a, db)
			var move := {"id": str(a.get("id", "")), "name": words(lines[0]) if not lines.is_empty() else str(a.get("name", ""))}
			for l in lines.slice(1):
				var g := str(l.get("group", ""))
				if g in ["attr", "kw", "rule"]:
					move[g] = words(l)
			moves.append(move)
			_note(used, "%s, %s" % [str(db.foes[fid].get("name", fid)), str(a.get("name", move["id"]))], "moves")
		foes[str(fid)] = moves
	Templates.tracing = false
	Templates.traced.clear()
	return {
		"_about": "What every piece does as the game's codex prints it, composed by the game's own code from content (EntryReadout.codex_lines for a component at its own numbers: its attributes, its keywords, its own rules; EntryReadout.codex_move_lines for each foe move and its last act), its words the templates' (content/templates.json); templates is each template those lines and a component's compact line (Face.describe) filled: how many components (pieces) and foe moves (moves) print it, count the two together, and the first few, with its words there. Written by tools/hangar_readouts.gd, which tools/hangar_data.py runs; the page shows the lines beside each piece and each template's beside it on the Text tab, where the templates are edited.",
		"components": comps,
		"foes": foes,
		"templates": used,
	}


## Which of a piece's rows each template its codex lines filled builds (Ryan, 20 November: "Need
## to be able to hop to/edit the template from the Chassis tab when viewing a chassis"): a row's
## templates are those whose words stand in its words, read in the order attributes, keywords,
## rules, a template going to the first row holding it; one in none of them is "other".
static func by_row(rows: Dictionary, traced: Array) -> Dictionary:
	var out := {}
	for t in traced:
		var said := _plain(str(t[1]))
		if said.is_empty():
			continue
		var at := "other"
		for g in ["attr", "kw", "rule"]:
			if _plain(str(rows.get(g, ""))).contains(said):
				at = g
				break
		var list: Array = out.get(at, [])
		if not list.has(str(t[0])):
			list.append(str(t[0]))
		out[at] = list
	return out


## Words as a row is matched: lower case, one space between words.
static func _plain(t: String) -> String:
	return " ".join(t.to_lower().split(" ", false))


## The templates one piece's lines filled (Templates.traced), noted against it: each template's
## count of pieces and the first few with its words there.
const EXAMPLES := 6


static func _note(used: Dictionary, piece: String, side: String) -> void:
	var seen := {}
	for t in Templates.traced:
		var id := str(t[0])
		if seen.has(id):
			continue
		seen[id] = true
		var u: Dictionary = used.get(id, {"count": 0, "pieces": 0, "moves": 0, "on": []})
		u["count"] = int(u["count"]) + 1
		u[side] = int(u[side]) + 1
		if (u["on"] as Array).size() < EXAMPLES:
			(u["on"] as Array).append({"piece": piece, "words": str(t[1])})
		used[id] = u


## A readout line's plain words: its text, or its parts' words joined as the screen sets them.
static func words(l: Dictionary) -> String:
	var parts: Array = l.get("parts", [])
	if parts.is_empty():
		return str(l.get("text", "")).strip_edges()
	var said: Array[String] = []
	for p in parts:
		var t := str((p as Dictionary).get("text", "")).strip_edges()
		if not t.is_empty():
			said.append(t)
	return " ".join(said)

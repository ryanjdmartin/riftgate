extends SceneTree

## What every piece does as the game's codex prints it, for the hangar page (Ryan, 20 November:
## "there is pretty important hidden text. Bullion fragmenter, for instance, nowhere lists what it
## actually DOES in the hangar - the game says 'Fires the hopper, +2 a load (2 a shot)'"). The
## lines the code composes from a piece's numbers (sim/face.gd's rule phrases, the readout's
## attributes and keywords, a foe move's riders and conditions) are no text anyone writes, so the
## page's text inventory leaves them out; this writes them as the game's own code composes them,
## so the page shows them beside the texts and never drifts from the game:
##   every component, its codex row at its own numbers (EntryReadout.codex_lines): its attributes
##   (what it is, its number, heat, costs, cooldown and target), its keywords and its own rules;
##   every foe, each move the codex lists, its last act after (EntryReadout.codex_move_lines).
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
	for cid in db.components.keys():
		var comp: Dictionary = db.components[cid]
		var face := db.build_face(comp.get("face", {}))
		face.component = str(cid)
		for t in comp.get("tags", []):
			face.tags.append(str(t))
		var rows := {}
		for l in EntryReadout.codex_lines(face, db, []):
			var g := str(l.get("group", ""))
			if g in ["attr", "kw", "rule"]:
				rows[g] = words(l)
		comps[str(cid)] = rows
	var foes := {}
	for fid in db.foes.keys():
		var foe := db.make_foe(str(fid))
		var moves: Array = []
		for a in db.codex_for_foe(foe).get("moves", []):
			var lines := EntryReadout.codex_move_lines(foe, a, db)
			var move := {"id": str(a.get("id", "")), "name": words(lines[0]) if not lines.is_empty() else str(a.get("name", ""))}
			for l in lines.slice(1):
				var g := str(l.get("group", ""))
				if g in ["attr", "kw", "rule"]:
					move[g] = words(l)
			moves.append(move)
		foes[str(fid)] = moves
	return {
		"_about": "What every piece does as the game's codex prints it, composed by the game's own code from content (EntryReadout.codex_lines for a component at its own numbers: its attributes, its keywords, its own rules; EntryReadout.codex_move_lines for each foe move and its last act). Written by tools/hangar_readouts.gd, which tools/hangar_data.py runs; read only on the page, since the words are the code's.",
		"components": comps,
		"foes": foes,
	}


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

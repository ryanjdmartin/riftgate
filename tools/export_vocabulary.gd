extends SceneTree

## Writes docs/vocabulary.md from content/vocabulary.json so the readable view never drifts
## from the data the game and the validator use.
##   godot --headless --path . -s tools/export_vocabulary.gd

const OUT := "res://docs/vocabulary.md"


func _init() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var lines: Array[String] = []
	lines.append("# Riftgate vocabulary")
	lines.append("")
	lines.append("Generated from `content/vocabulary.json` by `tools/export_vocabulary.gd`. Do not edit by hand; edit the JSON and re-run the tool.")
	lines.append("")
	var counts := {"implemented": 0, "planned": 0, "idea": 0}
	for id in db.vocabulary.keys():
		var s: String = db.vocabulary[id].get("status", "idea")
		counts[s] = counts.get(s, 0) + 1
	lines.append("Status: %d implemented, %d planned, %d idea." % [counts["implemented"], counts["planned"], counts["idea"]])
	lines.append("")
	for cat in db.categories:
		var rows: Array = []
		for id in db.vocabulary.keys():
			if db.vocabulary[id].get("category") == cat:
				rows.append(db.vocabulary[id])
		if rows.is_empty():
			continue
		lines.append("## %s" % str(cat).replace("_", " ").capitalize())
		lines.append("")
		lines.append("| Term | Codex | Status |")
		lines.append("|---|---|---|")
		for e in rows:
			lines.append("| **%s** | %s | %s |" % [e["name"], e["codex"], e["status"]])
		lines.append("")
	lines.append("## Holes")
	lines.append("")
	lines.append("Every entry whose `design.holes` is not empty. This is the list of things the mechanics do not do yet.")
	lines.append("")
	for id in db.vocabulary.keys():
		var e: Dictionary = db.vocabulary[id]
		var h := str(e.get("design", {}).get("holes", ""))
		if not h.is_empty():
			lines.append("- **%s** (%s): %s" % [e["name"], e["status"], h])
	lines.append("")
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	if f == null:
		push_error("cannot write %s" % OUT)
		quit(1)
		return
	f.store_string("\n".join(lines))
	f.close()
	print("wrote %s (%d entries)" % [OUT, db.vocabulary.size()])
	quit(0)

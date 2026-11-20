extends TestCase

## The hangar's readouts (tools/hangar_readouts.gd, 20 November, Ryan: "Bullion fragmenter, for
## instance, nowhere lists what it actually DOES in the hangar - the game says 'Fires the hopper,
## +2 a load (2 a shot)'"): the page shows every piece's lines as the game's own codex composes
## them, so the export must keep running against the code that composes them. Every component has
## its attributes, a piece with a rule of its own prints it, and every foe's moves are listed with
## their lines, in the codex's order.

const READOUTS := preload("res://tools/hangar_readouts.gd")


func test_every_component_and_foe_move_reads_as_the_game_prints_it() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var data: Dictionary = READOUTS.build(db)
	var comps: Dictionary = data["components"]
	assert_eq(comps.size(), db.components.size(), "every component has its readout")
	for cid in db.components.keys():
		var rows: Dictionary = comps.get(str(cid), {})
		assert_false(str(rows.get("attr", "")).is_empty(), "%s prints its attributes" % cid)
	# A piece with a rule of its own prints it: one written into the export for every entry the
	# die stars, read off the engine's own phrases, never a list kept here.
	for cid in db.components.keys():
		var face := db.build_face(db.components[cid].get("face", {}))
		if not face.rule_phrases().is_empty():
			assert_false(str((comps[str(cid)] as Dictionary).get("rule", "")).is_empty(), "%s prints its own rule" % cid)
	# Each row names the templates it is built from, so the Chassis sheet edits them beside it: a
	# piece's rule row its rule's templates, every one a template content holds.
	for cid in db.components.keys():
		var rows: Dictionary = comps[str(cid)]
		var tpl: Dictionary = rows.get("tpl", {})
		var face := db.build_face(db.components[cid].get("face", {}))
		if not face.rule_phrases().is_empty():
			assert_false((tpl.get("rule", []) as Array).is_empty(), "%s names its rule's templates: %s" % [cid, str(tpl)])
		assert_false((tpl.get("attr", []) as Array).is_empty(), "%s names its attributes' templates" % cid)
		for g in tpl.keys():
			for id in tpl[g]:
				assert_true(Templates.has(str(id)), "%s's %s row names a template content holds: %s" % [cid, g, id])
	var foes: Dictionary = data["foes"]
	assert_eq(foes.size(), db.foes.size(), "every foe has its moves")
	for fid in db.foes.keys():
		var foe := db.make_foe(str(fid))
		var listed: Array = foes[str(fid)]
		assert_eq(listed.size(), (db.codex_for_foe(foe).get("moves", []) as Array).size(), "%s lists every move the codex does" % fid)
		for m in listed:
			assert_false(str((m as Dictionary).get("name", "")).is_empty(), "%s's moves are named" % fid)
			assert_false(str((m as Dictionary).get("attr", "")).is_empty(), "%s's %s prints its attributes" % [fid, str(m.get("name", ""))])


## A line's words are its parts' as the screen sets them, or its text.
func test_a_readout_line_reads_as_its_words() -> void:
	assert_eq(READOUTS.words({"parts": [{"text": "Attack"}, {"text": "4"}, {"text": "·"}, {"text": "Heat"}, {"text": "5"}]}), "Attack 4 · Heat 5", "parts joined")
	assert_eq(READOUTS.words({"text": "Fires the hopper"}), "Fires the hopper", "a text line")

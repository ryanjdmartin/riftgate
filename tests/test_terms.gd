extends TestCase

## The one term table (Terms) and shown text's terms (Ryan, 30 October: "standardize the keyword
## colours ... Just groups that kind of make sense ... Stay away from HUD colour"; "highlighting
## keywords in their colour when applicable, and even including the iconography"; "Try bold in
## the colour first"; "Tapping a keyword is exactly what we need"). Names come from the
## vocabulary, never written here, so a rename moves the tests with it.


## The terms the keywords list shows, as it shows them (PauseMenu.glossary).
func _listed(db: ContentDB) -> Array[String]:
	var out: Array[String] = []
	for kind in PauseMenu.glossary(db):
		for e in kind["entries"]:
			out.append(str(e[2]))
	return out


## The ids Glyphs.draw has an arm for, read off its source: any other draws a bare square.
func _drawn_glyphs() -> Array[String]:
	var src := FileAccess.get_file_as_string("res://game/ui/glyphs.gd").split("static func colour_for")[0]
	var arm := RegEx.new()
	arm.compile("(?m)^\\t\\t(\"[a-z_]+\"(?:, \"[a-z_]+\")*):\\s*$")
	var quoted := RegEx.new()
	quoted.compile("\"([a-z_]+)\"")
	var out: Array[String] = []
	for m in arm.search_all(src):
		for q in quoted.search_all(m.get_string(1)):
			out.append(q.get_string(1))
	return out


func _name(id: String) -> String:
	return str(Terms.entry(id)["name"])


func _word(r: EntryReadout, text: String) -> Dictionary:
	for w in r._words:
		if str(w["text"]) == text:
			return w
	return {}


func test_every_term_the_list_shows_has_its_row_and_only_they() -> void:
	var db := ContentDB.load_default()
	var listed := _listed(db)
	assert_true(listed.size() > 50, "the keywords list holds its terms")
	for id in listed:
		assert_true(Terms.has(id), "%s, in the keywords list, has its icon and its colour" % id)
	for id in Terms.TABLE.keys():
		assert_true(db.vocabulary.has(str(id)), "%s is a vocabulary term" % id)
		assert_true(listed.has(str(id)) or str(db.vocabulary[str(id)].get("status", "")) != "implemented", "%s shows in the list" % id)
	# Every reach, keyword, rule and status the engine runs is listed; of the foes' words, the move
	# keywords the table carries, never the engine's own (the table has no row for them).
	for id in db.vocabulary.keys():
		var e: Dictionary = db.vocabulary[id]
		if str(e.get("status", "")) == "implemented" and str(e.get("category", "")) in ["reach", "keyword", "component_property", "status"]:
			assert_true(listed.has(str(id)), "%s, a %s, is listed" % [id, e.get("category", "")])
	var foes := 0
	for id in listed:
		if str(db.vocabulary[id].get("category", "")) == "foe":
			foes += 1
	assert_true(foes >= 8, "the foes' move keywords have a heading of their own")


func test_a_term_draws_a_real_icon_in_a_meaning_never_a_hud_preset() -> void:
	var drawn := _drawn_glyphs()
	assert_true(drawn.size() > 40, "Glyphs' arms read")
	for id in Terms.TABLE.keys():
		var g := Terms.glyph(str(id))
		assert_true(g.is_empty() or drawn.has(g), "%s's icon (%s) is one Glyphs draws" % [id, g])
		assert_true(Terms.group(str(id)) in ["heat", "guard", "enemy", "harm", "hull", "plain"], "%s sits in a group" % id)
		for preset in Settings.HUD_OPTIONS.keys():
			assert_ne(Terms.colour(str(id)), Settings.HUD_OPTIONS[preset], "%s never wears the %s preset" % [id, preset])


func test_the_die_and_the_chips_wear_each_terms_one_colour() -> void:
	for k in Face.KEYWORD_NAMES.keys():
		var id := str(Face.KEYWORD_NAMES[k])
		if not id.is_empty():
			assert_eq(Glyphs.colour_for(id), Terms.colour(id), "the die's %s mark in its term's colour" % id)
	var checked := 0
	for sid in Effects.STATUS.keys():
		var term := Terms.of_status(str(sid))
		if term.is_empty():
			continue
		checked += 1
		assert_eq(SkirmishScreen._foe_chip_colour(str(sid)), Terms.colour(term), "a foe's %s chip in its term's colour" % sid)
		assert_eq(SkirmishScreen._chip_colour(str(sid)), Terms.colour(term), "a machine's %s chip in its term's colour" % sid)
	assert_true(checked > 25, "the engine's statuses map to their terms")


func test_shown_text_cuts_out_its_terms() -> void:
	var brittle := _name("brittle")
	var spread := _name("cleave")
	var found := {}
	for seg in Terms.split("A foe carrying %s takes more, and %s 2 hits beside it." % [brittle, spread]):
		if not (seg["terms"] as Array).is_empty():
			found[str(seg["text"])] = seg["terms"]
	assert_true(found.has(brittle) and (found[brittle] as Array).has("brittle"), "a keyword by its name")
	assert_true(found.has(spread + " 2"), "with its number")
	if _name("brittled") == brittle:
		assert_eq(found[brittle], ["brittle", "brittled"], "a name two terms share: the keyword's, then its status's")
	var verb: String = Terms.verb_forms(_name("suppress"))[0]
	var segs := Terms.split("It %s the foe." % verb)
	assert_true(segs.size() == 3 and (segs[1]["terms"] as Array).has("suppress"), "a keyword's verb form (%s)" % verb)
	assert_true((Terms.split(spread.to_lower() + " it")[0]["terms"] as Array).is_empty(), "a word in lower case is no term")
	# A name that holds a term's word (a component's, a foe's) is no term there, unless the
	# name is a term's own.
	var db := ContentDB.load_default()
	var read := 0
	for table in [db.components, db.modules, db.chassis, db.foes]:
		for key in (table as Dictionary).keys():
			var n := str((table as Dictionary)[key].get("name", "")) if (table as Dictionary)[key] is Dictionary else ""
			if n.is_empty():
				continue
			read += 1
			var at := 0
			for seg in Terms.split("the %s fires" % n):
				var t := str(seg["text"])
				if not (seg["terms"] as Array).is_empty() and at >= 4 and at < 4 + n.length():
					assert_eq(t, n, "no term inside %s" % n)
				at += t.length()
	assert_true(read > 50, "every name read")


func test_a_term_reads_bold_in_its_colour_with_its_icon() -> void:
	var name := _name("ablating")
	var r := EntryReadout.new()
	r.set_lines([EntryReadout.prose_line("It leaves %s on the foe." % name)], 400.0)
	var w := _word(r, name)
	assert_false(w.is_empty(), "the term laid out as a word of its own")
	assert_eq(w.get("font"), Hud.display_bold(), "bold")
	assert_eq(w.get("ink"), Terms.colour("ablating"), "in its colour")
	assert_eq(str(w.get("glyph")), Terms.glyph("ablating"), "its icon before it")
	assert_eq(w.get("glyph_ink"), Terms.colour("ablating"), "in the same colour")
	assert_true(float(w.get("icon", 0.0)) > 0.0, "the icon taking its room")
	assert_eq(_word(r, "It").get("ink"), Palette.INK, "the words round it plain")
	assert_eq(r.text(), "It leaves %s on the foe." % name, "the line's text unchanged")
	# Against a bracket or a comma it stays against it.
	r.set_lines([EntryReadout.prose_line("knocks it out (%s), and" % name)], 400.0)
	var open := _word(r, "(")
	var term := _word(r, name)
	var after := _word(r, "),")
	assert_eq(float(term.get("x", -1.0)), float(open.get("x", 0.0)) + float(open.get("w", 0.0)), "the bracket against it")
	assert_eq(float(after.get("x", -1.0)), float(term.get("x", 0.0)) + float(term.get("w", 0.0)), "and the comma after it")
	# A chip's own name wears its colour without a second icon: its box is beside it.
	r.set_lines([EntryReadout.chip_line(Terms.glyph("ablating"), Terms.colour("ablating"), "%s: it burns" % name)], 400.0)
	var head := _word(r, name)
	assert_eq(head.get("ink"), Terms.colour("ablating"), "the chip's name in its colour")
	assert_eq(float(head.get("icon", 0.0)), 0.0, "and no icon of its own")
	r.free()


func test_a_tap_on_a_term_opens_its_entry_and_a_tap_off_it_falls_through() -> void:
	var r := EntryReadout.new()
	var name := _name("shocked")
	r.set_lines([EntryReadout.prose_line("A plain start, then %s." % name)], 400.0)
	assert_eq(r._hits.size(), 1, "one term to tap")
	var at: Vector2 = (r._hits[0]["rect"] as Rect2).get_center()
	assert_true(r._has_point(at), "a tap on the term is the readout's")
	assert_false(r._has_point(_word(r, "plain")["at"]), "a tap on a plain word falls through to what lies under")
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = at
	r._gui_input(press)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = at + Vector2(3.0, 2.0)
	r._gui_input(release)
	var tip := KeywordTip.current()
	assert_true(tip != null and tip.terms == ["shocked"], "the tap opens its tip")
	var codex := str(Terms.entry("shocked")["codex"])
	assert_true(tip != null and tip.text().contains(name) and tip.text().contains(codex.substr(0, 24)), "its name over its line from the keywords list")
	# A term in the tip opens its own in its place.
	var brittle := _name("brittle")
	r.open_tip(["brittle", "brittled"], Rect2(10, 10, 40, 20))
	assert_true(KeywordTip.current() == tip and tip.terms == ["brittle", "brittled"], "the open tip moves to the next term, both of a shared name")
	KeywordTip.close_open()
	assert_true(KeywordTip.current() == null, "and it closes")
	# A press that travels is a drag, never a tap.
	r._gui_input(press)
	release.position = at + Vector2(0.0, 40.0)
	r._gui_input(release)
	assert_true(KeywordTip.current() == null, "a drag opens nothing")
	assert_true(brittle.length() > 0, "names from the vocabulary")
	r.free()


func test_the_keywords_list_heads_each_term_with_its_icon_in_its_colour() -> void:
	var menu := PauseMenu.new()
	menu._show_page("keywords")
	var heads := 0
	var col: Node = menu._list.get_child(0)
	for c in col.get_children():
		if c is EntryReadout:
			var l: Dictionary = (c as EntryReadout).lines[0]
			if str(l.get("style", "")) == "term":
				heads += 1
				var w := _word(c, str(l["text"]).split(" ")[0])
				assert_eq(w.get("ink"), Terms.colour(str(l["term"])), "%s in its colour" % l["text"])
	assert_eq(heads, _listed(ContentDB.load_default()).size(), "a head a term")
	menu.free()


## The keywords list files every status by what it is to its unit (Ryan, 9 November), and a term's
## tip says so over it: a buff's, that a Purge takes it.
func test_the_keywords_list_files_the_statuses_by_buff_debuff_and_ability() -> void:
	var db := ContentDB.load_default()
	var seen := {}
	for kind in PauseMenu.glossary(db):
		var title := str(kind["title"])
		for e in kind["entries"]:
			var what := Effects.status_kind(Terms.engine_status(str(e[2])))
			if title.begins_with("BUFFS"):
				assert_eq(what, "buff", "%s under BUFFS is a buff" % e[0])
			elif title.begins_with("DEBUFFS"):
				assert_eq(what, "debuff", "%s under DEBUFFS is a debuff" % e[0])
			elif title.begins_with("ABILITIES"):
				assert_eq(what, "ability", "%s under ABILITIES is an ability" % e[0])
			seen[title.split(" ")[0]] = true
	for t in ["BUFFS", "DEBUFFS", "ABILITIES"]:
		assert_true(seen.has(t), "a heading for the %s" % t.to_lower())
	assert_true(str(Terms.entry("overcharged", db)["heading"]).begins_with("BUFF"), "a buff's tip says so")
	assert_true(str(Terms.entry("ablating", db)["heading"]).begins_with("DEBUFF"), "and a debuff's")
	assert_true(str(Terms.entry("sealed", db)["heading"]).begins_with("ABILITY"), "and an ability's")


## A tip says the sum its unit carries (Ryan, 23 November: "All buffs and debuffs need to have
## their current sum mentioned in their in-game tips"): {N} filled from the unit whose readout is
## open, and {caster} with who laid it; with none open the sum's aside goes and N stands in.
func test_a_tip_fills_the_sum_its_unit_carries() -> void:
	var line := "On Hit: +1 damage per stack ({N}).\nTurn End: Reduce stacks by half, rounded down."
	assert_eq(KeywordTip.filled("overcharged", line, {"overcharged": {"N": 4}}), "On Hit: +1 damage per stack (4).\nTurn End: Reduce stacks by half, rounded down.", "the unit's sum")
	assert_eq(KeywordTip.filled("overcharged", line, {}), "On Hit: +1 damage per stack.\nTurn End: Reduce stacks by half, rounded down.", "with no unit, no aside")
	assert_eq(KeywordTip.filled("penetrate", "dealing {N} damage", {}), "dealing N damage", "a keyword's number stands as N")
	assert_eq(KeywordTip.filled("swallowed", "upon {caster} losing", {"swallowed": {"N": 2, "caster": "Floraison"}}), "upon Floraison losing", "who laid it")
	assert_eq(KeywordTip.filled("swallowed", "upon {caster} losing", {}), "upon its caster losing", "or its caster")
	var was := Templates.self_name
	Templates.self_name = ""
	assert_eq(KeywordTip.filled("lure", "Hit: Change intended target to {self}.", {}), "Hit: Change intended target to this Frame.", "{self} with no Frame open")
	Templates.self_name = Templates.self_of(Unit.mech(1, "Nemesis", Vector2i.ZERO))
	assert_eq(KeywordTip.filled("lure", "Hit: Change intended target to {self}.", {}), "Hit: Change intended target to the Nemesis.", "and the Frame open, by name (27 November)")
	Templates.self_name = was
	var db := ContentDB.load_default()
	for id in db.vocabulary.keys():
		var said := KeywordTip.filled(str(id), str(db.vocabulary[id].get("codex", "")), {})
		assert_false(said.contains("{"), "%s's tip leaves no mark unfilled: %s" % [id, said])
	KeywordTip.fills = {}


## Every glossary tip follows the standard's mechanical parts (docs/text_standard.md; Ryan,
## 24 November: "New content additions need to know and follow the format"): no semicolon, the
## words that left the text (foe, machine, enemy, blow, strike, falls), {N} on a status only where
## a line counts per stack, and a capital after every label. What a tip says is his; this only
## holds its shape.
func test_every_tip_keeps_the_standards_shape() -> void:
	var db := ContentDB.load_default()
	var gone := RegEx.new()
	gone.compile("(?i)\\b(foes?|foe's|machines?|machine's|enemy|enemies|blows?|strikes?|struck|falls|fell|felled)\\b")
	# Damage lands three ways, each its verb (Ryan, 24 November: "I like hit for N, suffer N damage,
	# and lose N hull as the format examples that we want"): "take N damage" says none of them.
	var took := RegEx.new()
	took.compile("(?i)\\b(takes?|deals?) (\\d+|\\{N\\}) (hull )?damage\\b")
	var labels := ["Turn Start", "Turn End", "Round End", "Commit", "On Hit", "When Hit", "After Hit", "After Being Hit", "Resolve",
		"When defeated", "On Reboot", "Shield Broken", "Hull Damaged", "Skirmish Start", "On Suppressed", "On Burrowed",
		"Hit By Weapon", "Hit"]
	var shown := 0
	for kind in PauseMenu.GLOSSARY:
		for id in db.vocabulary.keys():
			var e: Dictionary = db.vocabulary[id]
			if str(e.get("category", "")) != str(kind[0]) or str(e.get("status", "")) != "implemented":
				continue
			shown += 1
			var tip := str(e.get("codex", ""))
			assert_false(tip.contains(";"), "%s: no semicolon (%s)" % [id, tip])
			var m := gone.search(tip)
			assert_true(m == null, "%s: says '%s', a word the standard retired" % [id, m.get_string() if m != null else ""])
			var t := took.search(tip)
			assert_true(t == null, "%s: says '%s': a hit is 'hit for N', the rest 'suffer N damage' or 'lose N Hull' (the standard's rule 39)" % [id, t.get_string() if t != null else ""])
			# A status that never stacks is consumed or removed, never reduced (Ryan, 24 November:
			# "non-stacking statuses shouldn't say 'reduce to 0,' they can just say 'Consumed' or
			# 'Removed' just like Shock"): one that renews, counts nothing and keeps no timer.
			if str(kind[0]) == "status":
				var sid := Terms.engine_status(str(id))
				var d: Dictionary = Effects.STATUS.get(sid, {})
				if not d.is_empty() and Effects.status_stacking(d) == "renew" and not Effects.is_timer(sid) and not Effects.is_counted(sid):
					assert_false(tip.to_lower().contains("stacks"), "%s never stacks: its tip says Consumed or Removed (%s)" % [id, tip])
			# A grant is a block (Ryan, 26 November: "I want the block of things applied to the weapon or
			# whatever to be visually blocked"): an indented line hangs under an "X Gain:" line or another
			# of its block, and "On Hit" is gone with the block's bare events.
			var in_block := false
			for raw in tip.split("\n"):
				var line := raw.strip_edges(true, false)
				if raw.begins_with(EntryReadout.BLOCK_MARK):
					assert_true(in_block, "%s: an indented line hangs under an \"X Gain:\" line: %s" % [id, tip])
				else:
					in_block = line.ends_with("Gain:") or line.ends_with("Gains:")
				assert_false(line.begins_with("On Hit:") or line.begins_with("On Weapon Hit:"), "%s: a grant's hit is \"Hit:\" in its block, a component's own too (rule 41): %s" % [id, line])
				if str(kind[0]) == "status" and line.contains("{N}"):
					assert_true(line.contains("per stack ({N})"), "%s: a status's {N} follows a per-stack amount: %s" % [id, line])
				for label in labels:
					if line.begins_with(label + ": "):
						var rest: String = line.substr(label.length() + 2)
						assert_true(not rest.is_empty() and rest[0] == rest[0].to_upper(), "%s: a capital after %s: %s" % [id, label, line])
	assert_true(shown > 100, "every tip read: %d" % shown)


## A grant's block draws in from its "X Gain:" line, beside one bar (Ryan, 26 November: "I want the
## block of things applied to the weapon or whatever to be visually blocked").
func test_a_grants_block_draws_indented_beside_a_bar() -> void:
	var lines := [EntryReadout.prose_line("Weapons Gain:"), EntryReadout.prose_line("  Hit: +2 damage dealt per stack (3)."),
		EntryReadout.prose_line("  Resolve: Reduce stacks to 0."), EntryReadout.prose_line("Turn End: Removed.")]
	assert_true(bool(lines[1].get("block", false)) and str(lines[1]["text"]).begins_with("Hit:"), "an indented line is the block's, its spaces off its words")
	assert_false(bool(lines[0].get("block", false)) or bool(lines[3].get("block", false)), "the lines around it are not")
	var r := EntryReadout.new()
	r.set_lines(lines, 400.0)
	assert_eq(r._blocks.size(), 2, "a bar beside each of the block's lines")
	assert_true((r._blocks[1] as Rect2).position.y <= (r._blocks[0] as Rect2).end.y + 0.5, "the second joined to the first: one bar down the block")
	r.free()


## A Frame's text names it with {self}, never "this Frame" or "this machine" (Ryan, 27 November:
## "Use self everywhere, it's more future proof"; the text standard's rule 3): every shown text in
## content, the glossary's tips, the chassis' passives and upgrades, the components' and modules'
## words and the templates, the trigger notes the player never reads aside.
func test_shown_text_names_its_frame_with_self() -> void:
	var db := ContentDB.load_default()
	var said := RegEx.new()
	said.compile("\\b[Tt]his (Frame|machine)\\b")
	var found: Array[String] = []
	for id in db.vocabulary.keys():
		var e: Dictionary = db.vocabulary[id]
		if str(e.get("category", "")) != "trigger" and said.search(str(e.get("codex", ""))) != null:
			found.append("vocabulary %s" % id)
	for id in db.chassis.keys():
		var c: Dictionary = db.chassis[id]
		if said.search(str((c.get("passive", {}) as Dictionary).get("description", ""))) != null:
			found.append("passive %s" % id)
		for b in c.get("branches", []):
			for st in (b as Dictionary).get("steps", []):
				if said.search(str((st as Dictionary).get("description", ""))) != null:
					found.append("upgrade %s" % id)
	for id in db.components.keys():
		var comp: Dictionary = db.components[id]
		if said.search(str(comp.get("codex", "")) + " " + JSON.stringify(comp.get("text", {}))) != null:
			found.append("component %s" % id)
	for id in db.modules.keys():
		if said.search(JSON.stringify((db.modules[id] as Dictionary).get("text", {}))) != null:
			found.append("module %s" % id)
	for id in Templates.table().keys():
		if str(id) != "self.none" and said.search(JSON.stringify(Templates.table()[id].get("text", ""))) != null:
			found.append("template %s" % id)
	assert_eq(found, [] as Array[String], "every Frame's text says {self}")


## A passive, an upgrade and a module rule granted to a Frame name it where they say {self}, filled
## as they are granted, so every readout that lists them reads its name.
func test_a_granted_passive_names_its_frame() -> void:
	var u := Unit.mech(1, "Nemesis", Vector2i.ZERO)
	u.grant_passive({"id": "test_rage", "name": "Fury", "description": "Turn Start: {self} gains Rage.", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 0, "line": "When Hit: {self} gains 1 Heat."}]})
	var rows := Effects.describe(u)
	var row: Array = rows.filter(func(r) -> bool: return str(r[5]) == "test_rage")[0]
	assert_eq(str(row[1]), "Turn Start: The Nemesis gains Rage.", "its description names it, a capital after the label")
	var m = u.modifiers.filter(func(x) -> bool: return x.id == "test_rage")[0]
	assert_eq(str(m.effects[0]["line"]), "When Hit: The Nemesis gains 1 Heat.", "and a rule's own line")


## A status never grows itself (Ryan, 27 November, of Paradox: "I don't think stacks should be able
## to multiply themselves, so it should be the baboon applying it, as the source"; the standard's
## rule 37: "A status's trigger lives on what grants it"): no status's tip gains its own stacks.
## Its stacks come from what lays them, which says so: the Baboon's passive, the Ammit's, the
## Echidna's, the Nob's Enrage.
func test_no_status_grows_itself() -> void:
	var db := ContentDB.load_default()
	var found: Array[String] = []
	for id in db.vocabulary.keys():
		var e: Dictionary = db.vocabulary[id]
		if str(e.get("category", "")) != "status":
			continue
		var name := str(e.get("name", id))
		var own := RegEx.new()
		own.compile("\\bGains? (\\d+|\\{N\\}|a) (stacks?|%s)\\b|stacks? (gained|applied)" % name)
		for line in str(e.get("codex", "")).split("\n"):
			if own.search(line) != null:
				found.append("%s: %s" % [id, line])
	assert_eq(found, [] as Array[String], "every status's stacks come from what lays them")


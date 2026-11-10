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
	var flak := _name("flak")
	var spread := _name("cleave")
	var found := {}
	for seg in Terms.split("A foe carrying %s takes more, and %s 2 hits beside it." % [flak, spread]):
		if not (seg["terms"] as Array).is_empty():
			found[str(seg["text"])] = seg["terms"]
	assert_true(found.has(flak) and (found[flak] as Array).has("flak"), "a keyword by its name")
	assert_true(found.has(spread + " 2"), "with its number")
	if _name("flakked") == flak:
		assert_eq(found[flak], ["flak", "flakked"], "a name two terms share: the keyword's, then its status's")
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
	var name := _name("burning")
	var r := EntryReadout.new()
	r.set_lines([EntryReadout.prose_line("It leaves %s on the foe." % name)], 400.0)
	var w := _word(r, name)
	assert_false(w.is_empty(), "the term laid out as a word of its own")
	assert_eq(w.get("font"), Hud.display_bold(), "bold")
	assert_eq(w.get("ink"), Terms.colour("burning"), "in its colour")
	assert_eq(str(w.get("glyph")), Terms.glyph("burning"), "its icon before it")
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
	r.set_lines([EntryReadout.chip_line(Terms.glyph("burning"), Terms.colour("burning"), "%s: it burns" % name)], 400.0)
	var head := _word(r, name)
	assert_eq(head.get("ink"), Terms.colour("burning"), "the chip's name in its colour")
	assert_eq(float(head.get("icon", 0.0)), 0.0, "and no icon of its own")
	r.free()


func test_keyword_ink_puts_the_word_in_ink_and_keeps_the_icon_its_colour() -> void:
	var was: bool = bool(Settings.display.get("keyword_ink", false))
	Settings.display["keyword_ink"] = true
	var name := _name("suppressed")
	var r := EntryReadout.new()
	r.set_lines([EntryReadout.prose_line("It is %s now." % name)], 400.0)
	var w := _word(r, name)
	if OS.is_debug_build():
		assert_eq(w.get("ink"), Palette.INK, "the word in ink")
	else:
		assert_eq(w.get("ink"), Terms.colour("suppressed"), "a release build keeps the colour")
	assert_eq(w.get("glyph_ink"), Terms.colour("suppressed"), "its icon still its colour")
	Settings.display["keyword_ink"] = was
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
	var flak := _name("flak")
	r.open_tip(["flak", "flakked"], Rect2(10, 10, 40, 20))
	assert_true(KeywordTip.current() == tip and tip.terms == ["flak", "flakked"], "the open tip moves to the next term, both of a shared name")
	KeywordTip.close_open()
	assert_true(KeywordTip.current() == null, "and it closes")
	# A press that travels is a drag, never a tap.
	r._gui_input(press)
	release.position = at + Vector2(0.0, 40.0)
	r._gui_input(release)
	assert_true(KeywordTip.current() == null, "a drag opens nothing")
	assert_true(flak.length() > 0, "names from the vocabulary")
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
	assert_true(str(Terms.entry("burning", db)["heading"]).begins_with("DEBUFF"), "and a debuff's")
	assert_true(str(Terms.entry("sealed", db)["heading"]).begins_with("ABILITY"), "and an ability's")

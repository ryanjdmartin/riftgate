extends TestCase

## The words the game composes from a piece's numbers are content (content/templates.json, read
## by Templates; Ryan, 20 November: "I need to be able to change it, and how would it ever get
## localized? The foe ability templates are exposed, weapon chips need to be too"). The code and
## the file stay in step: every template the code asks for is in the file, every one in the file
## is asked for (a spare is a leftover, as a cut rule's is), and a template fills its braces with
## the values the code gives, in the form its count picks. Synthetic templates where the rule is
## the filling's, never an entry's words.

const PREFIXES := ["rule", "entry", "readout", "target", "kind", "gate", "rank", "cost", "hold", "state", "move", "aim", "when", "foe_target", "term", "count"]


## Every template id written out in the engine's and the screens' code.
func _named_in_code() -> Dictionary:
	var out := {}
	var re := RegEx.new()
	re.compile("\"((?:%s)\\.[a-z_]+)\"" % "|".join(PREFIXES))
	for dir in ["res://sim", "res://game"]:
		for path in _scripts(dir):
			for m in re.search_all(FileAccess.get_file_as_string(path)):
				out[m.get_string(1)] = path
	return out


func _scripts(dir: String) -> Array[String]:
	var out: Array[String] = []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir + "/" + f)
	for sub in d.get_directories():
		out.append_array(_scripts(dir + "/" + sub))
	return out


## The templates the code picks by an engine word rather than by name: a move's aim and its
## condition, whom a move that is no blow acts on, a move's kind, a gate's rank.
func _by_engine_word() -> Dictionary:
	var out := {}
	for w in Foe.AIMS:
		out["aim." + str(w)] = true
	for w in Foe.WHENS:
		out["when." + str(w)] = true
	for k in EntryReadout.MOVE_TARGETS.values():
		if str(k) != "every_machine":   # said by the term's name (Every Machine)
			out["foe_target." + str(k)] = true
	for k in ContentDB.ACTION_KINDS:
		if str(k) != "attack":   # a blow's line is its kind.attack, by name
			out["kind." + str(k)] = true
	for r in ["front", "back"]:
		out["rank." + r] = true
	return out


func test_every_template_the_code_asks_for_is_in_content_and_none_is_spare() -> void:
	var named := _named_in_code()
	var by_word := _by_engine_word()
	var table := Templates.table()
	assert_true(table.size() > 100, "the file holds the readout's words (%d templates)" % table.size())
	for id in named.keys():
		assert_true(table.has(id), "%s names the template %s, and content/templates.json holds it" % [named[id], id])
	for id in by_word.keys():
		assert_true(table.has(id), "an engine word's template is in content: %s" % id)
	for id in table.keys():
		assert_true(named.has(id) or by_word.has(id), "%s is asked for by the code or an engine word: a template nothing prints is a leftover" % id)


func test_content_validates_and_a_brace_with_no_fill_is_refused() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var mine := db.validate().filter(func(e: String) -> bool: return e.begins_with("template ") or e.contains("templates.json"))
	assert_eq(mine, [], "the templates validate: %s" % str(mine))
	db.templates = {
		"test.loose": {"id": "test.loose", "text": "fires {n} at {who}", "fills": ["n"]},
		"test.forms": {"id": "test.forms", "text": {"one": "a {n}"}, "fills": ["n"]},
		"test.odd": {"id": "test.odd", "text": {"one": "a", "other": "b", "lots": "c"}, "fills": ["n"], "count": "n"},
		"test.key": {"id": "test.key", "text": "plain", "fills": [], "note": "a stray key"},
	}
	var errs := db.validate()
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("template test.loose") and e.contains("{who}")), "a brace the code fills nothing into is refused: %s" % str(errs))
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("template test.forms") and e.contains("other form")), "forms keep the other form")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("template test.forms") and e.contains("(count)")), "and name their count")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("template test.odd") and e.contains("lots")), "a form is a plural category")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("template test.key") and e.contains("note")), "a template's keys are its own")


func test_a_template_fills_by_name_in_one_pass() -> void:
	assert_eq(Templates.fill("+{n} per {per} heat", {"n": 2, "per": 3}), "+2 per 3 heat", "each brace its value")
	assert_eq(Templates.fill("{a} then {b}", {"a": "{b}", "b": "x"}), "{b} then x", "a value is never read again as a template")
	assert_eq(Templates.fill("keeps {unknown}", {}), "keeps {unknown}", "a brace with no value stands, so it shows")
	assert_eq(Templates.fill("{n}", {"n": {"text": "7", "trend": 1}}), "7", "a part fills with its words")
	assert_eq(Templates.braces("a {b} c {d}"), ["b", "d"] as Array[String], "the braces a text holds, in order")


func test_a_count_picks_its_form() -> void:
	# The engine's own: a count of one and of more, in each of English's two forms.
	assert_eq(Templates.say("rule.kill_rerolls", {"n": 1}), Templates.fill(str(Templates.table()["rule.kill_rerolls"]["text"]["one"]), {"n": 1}), "one takes the one form")
	assert_eq(Templates.say("rule.kill_rerolls", {"n": 3}), Templates.fill(str(Templates.table()["rule.kill_rerolls"]["text"]["other"]), {"n": 3}), "more takes the other")
	assert_eq(Templates.plural(1), "one", "English: one for 1")
	for n in [0, 2, 11, 21]:
		assert_eq(Templates.plural(n), "other", "and other for %d" % n)


func test_a_readout_keeps_its_parts() -> void:
	# A moved number is a part of its own, the run its brace stands in; the words around it run together.
	var moved := {"text": "", "trend": 1, "gain": true}
	var e: Dictionary = Templates.table().get("readout.grants", {})
	assert_false(e.is_empty(), "the grant's template is content's")
	var parts := Templates.parts("readout.grants", {"status": "Empowered", "n": moved})
	assert_eq(parts.size(), 2, "the words and the number: %s" % str(parts))
	assert_eq(int(parts[1]["trend"]), 1, "the number keeps its trend")
	assert_false(str(parts[1]["text"]).contains("{"), "and is filled: %s" % str(parts[1]["text"]))
	assert_true(str(parts[0]["text"]).contains("Empowered"), "a value given as words runs with the words around it")


func test_the_die_readout_reads_its_words_from_content() -> void:
	# A rule line is the template's words at the piece's numbers, capitalised as the readout heads it.
	var f := Face.attack(4, Face.Reach.DIRECT)
	f.fires_hopper = 2
	f.power_per_load = 3
	var said := Templates.say("rule.fires_hopper", {"per_load": 3, "loads": 2})
	assert_true(f.rule_phrases().has(said), "the rule phrase is the template filled: %s" % str(f.rule_phrases()))
	var rules := EntryReadout.effects_of(f).filter(func(l: Dictionary) -> bool: return str(l.get("group", "")) == "rule")
	assert_true(rules.any(func(l: Dictionary) -> bool: return str(l["text"]) == EntryReadout.capital(said)), "and the readout prints it: %s" % str(rules))
	assert_true(f.describe().contains(said), "and the compact line: %s" % f.describe())

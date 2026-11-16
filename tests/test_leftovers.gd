extends TestCase

## A rule leaves the engine with its last piece (Ryan, 12 November, on seven rules that had lost
## theirs in five days and stayed in the engine: "Yeah go ahead and fix it"). These hold the
## engine to the content both ways: whatever the engine runs that no piece prints is on a KEPT
## list below with its reason, and whatever is on a KEPT list is still unprinted, so a list can
## be neither skipped nor left to go stale.
##
## A piece is anything in content/*.json, a planned draft included (a draft is the piece to
## come), or one of the engine's own statuses (their effects are written in sim/).
##
## A failure here is settled one of two ways. Cut the rule: its engine path, its validator
## check, its term and glyph, its bot weight, its tools' rows and the tests of the rule itself,
## moving a test that only used it to observe something else onto a synthetic piece. Or, where it
## is no piece's rule, list it here and say what it is: a step of the one pipeline, the general
## path; a rule a planned draft or a brief's settled answer names; a field the engine sets
## itself. "It may be wanted some day" is no reason: a piece that wants a cut rule back has it
## built then, and git keeps the old form.

## Effect kinds a passive may print that none does.
const KEPT_EFFECTS := {
	"suppress": "the pipeline's step 0, a live effect turning another off (the Effects header, decided 18 September): the general path, no piece's rule",
	"min_damage": "the pipeline's floor: the general path",
	"set_reach": "the pipeline's override: the general path",
	"vent_heat": "one of the three plain things an event may grant, beside a status and a shield: the table's general path",
}
## Events that fire for no piece.
const KEPT_TRIGGERS := {
	"on_shield_gain": "a gauge's event, the pair of on_heat_gain: the table's general path",
}
## Keys a die entry reads that no piece prints.
const KEPT_KEYS := {
	"shield_cost": "the Buzzard's and the Storm Petrel's settled briefs pay in shield (docs/briefs/kestrel_buzzard.md), and the to-do's Ryan list asks which piece carries it",
	"cools_all": "set by the engine: a charged form's vents all (the Sutler's Hoist), read back from a save",
	"fills_shield": "set by the engine: a charged form's shield full (the Sutler's Hoist), read back from a save",
}
## Keywords the engine names that no piece prints.
const KEPT_KEYWORDS := {}   # Spillover, the last, is the Overrun Gearing's since 12 November (Ryan: "Spillover can be a module")

var _effects := {}    # effect kind -> true: printed by a piece, or by one of the engine's statuses
var _triggers := {}
var _keys := {}       # a die entry's keys, a charged form's among them
var _keywords := {}
var _read := false


func _note_face(f: Dictionary) -> void:
	for k in f.keys():
		_keys[str(k)] = true
		if str(k) == "keywords" and f[k] is Array:
			for w in f[k]:
				_keywords[str(w)] = true
		if str(k) == "charged" and f[k] is Dictionary:
			_note_face(f[k])


func _walk(o) -> void:
	if o is Dictionary:
		if o.has("trigger") and o.has("effect"):
			_effects[str(o["effect"])] = true
			_triggers[str(o["trigger"])] = true
			if str(o["effect"]) == "grant_keyword":
				_keywords[str(o.get("value", ""))] = true
		for k in o.keys():
			if str(k) == "design":
				continue   # notes, never rules
			var v = o[k]
			if str(k) == "face" and v is Dictionary:
				_note_face(v)
			if (str(k) == "keywords" or str(k) == "riders") and v is Array:
				for w in v:
					if w is String:
						_keywords[w] = true
			_walk(v)
	elif o is Array:
		for v in o:
			_walk(v)


## Everything the content prints and the engine's own statuses use, read once.
func _read_all() -> void:
	if _read:
		return
	_read = true
	var dir := DirAccess.open(ContentDB.DIR)
	for f in dir.get_files():
		if not f.ends_with(".json") or f == "vocabulary.json" or f == "reserved_names.json":
			continue   # the vocabulary says the rules, it prints none
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(ContentDB.DIR.path_join(f)))
		assert_true(parsed != null, "%s parses" % f)
		_walk(parsed)
	var pair := RegEx.create_from_string("\"trigger\":\\s*\"(\\w+)\",\\s*\"effect\":\\s*\"(\\w+)\"")
	var sim := DirAccess.open("res://sim")
	for f in sim.get_files():
		if not f.ends_with(".gd"):
			continue
		for m in pair.search_all(FileAccess.get_file_as_string("res://sim".path_join(f))):
			_triggers[m.get_string(1)] = true
			_effects[m.get_string(2)] = true


## What `have` runs that `used` never prints, against the list kept for it, both ways.
func _hold(what: String, have: Array, used: Dictionary, kept: Dictionary) -> void:
	var idle: Array = []
	for name in have:
		if not used.has(str(name)):
			idle.append(str(name))
	idle.sort()
	for name in idle:
		assert_true(kept.has(name), "%s %s has lost its last piece: cut it from the engine, or list it here with what it is" % [what, name])
	for name in kept.keys():
		assert_true(idle.has(str(name)), "%s %s is listed as unprinted and is printed again, or is gone from the engine: take it off the list" % [what, name])
		assert_true(str(kept[name]).length() > 20, "%s %s says why it stays" % [what, name])


func test_every_effect_kind_the_engine_runs_has_a_piece_or_a_reason() -> void:
	_read_all()
	var kinds := {}
	for trigger in Effects.SUPPORTED_EFFECTS.keys():
		for effect in Effects.SUPPORTED_EFFECTS[trigger]:
			kinds[str(effect)] = true
	assert_true(kinds.size() > 40, "the table is read")
	_hold("the effect", kinds.keys(), _effects, KEPT_EFFECTS)


func test_every_trigger_the_engine_fires_has_a_piece_or_a_reason() -> void:
	_read_all()
	_hold("the trigger", Effects.SUPPORTED_EFFECTS.keys(), _triggers, KEPT_TRIGGERS)


func test_every_key_a_die_entry_reads_is_printed_or_has_a_reason() -> void:
	_read_all()
	var source := FileAccess.get_file_as_string("res://sim/face.gd")
	var from := source.find("static func from_dict(")
	assert_true(from >= 0, "the entry's reader is found")
	var until := source.find("\nfunc ", from)
	var next_static := source.find("\nstatic func ", from + 1)
	if next_static >= 0 and (until < 0 or next_static < until):
		until = next_static
	var body := source.substr(from, until - from)
	var keys := {}
	for pattern in ["d\\.get\\(\"(\\w+)\"", "d\\.has\\(\"(\\w+)\"\\)", "d\\[\"(\\w+)\"\\]"]:
		for m in RegEx.create_from_string(pattern).search_all(body):
			keys[m.get_string(1)] = true
	assert_true(keys.size() > 40, "its keys are read (%d)" % keys.size())
	_hold("the entry key", keys.keys(), _keys, KEPT_KEYS)


## A switch that leaves the engine leaves its runners too (15 November: the reboot's fold-in
## took Skirmish.reboot and left tools/balance.gd reading it, so the runner would not parse and
## no test said so). Every script under tools/ compiles against the engine as it stands.
func test_every_tool_script_parses_against_the_engine() -> void:
	var seen := 0
	for f in DirAccess.open("res://tools").get_files():
		if not f.ends_with(".gd"):
			continue
		seen += 1
		var script = load("res://tools".path_join(f))
		assert_true(script != null and (script as Script).can_instantiate(), "tools/%s parses" % f)
	assert_true(seen > 10, "the tools are read (%d)" % seen)


## A foe's rider no move carries, as a keyword of ours no piece prints.
const KEPT_RIDERS := {
	"destroy": "the vocabulary pass's settled answer (docs/vocabulary_pass_proposal.md, section 18; Ryan, 15 November: \"This can be a boss-level rider, that destroys the visible face if it damages hull at all. Only promoted form or superboss-level\"): the injury rule's one form, its carrier the foes' pass's",
}


func test_every_rider_a_foes_blow_may_carry_is_printed_or_has_a_reason() -> void:
	_read_all()
	assert_true(Foe.ATTACK_KEYWORDS.size() > 5, "the riders are read")
	_hold("the foes' rider", Foe.ATTACK_KEYWORDS, _keywords, KEPT_RIDERS)


func test_every_keyword_the_engine_names_is_printed_or_has_a_reason() -> void:
	_read_all()
	var names: Array = []
	for k in Face.KEYWORD_NAMES.keys():
		if not str(Face.KEYWORD_NAMES[k]).is_empty():   # NONE has no name
			names.append(str(Face.KEYWORD_NAMES[k]))
	assert_true(names.size() > 15, "the keywords are read")
	_hold("the keyword", names, _keywords, KEPT_KEYWORDS)

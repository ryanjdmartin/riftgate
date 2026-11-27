class_name Templates
extends RefCounted

## The words the game composes from a piece's numbers, read from content (content/templates.json;
## Ryan, 20 November: "That's literally the gameplay explanation of how the weapon works. I need
## to be able to change it, and how would it ever get localized? The foe ability templates are
## exposed, weapon chips need to be too"). A template is its text with a brace for each value
## the code fills ("fires the hopper, +{per_load} a load ({loads} a shot)"), or its forms by a
## count ({"one": "braces", "other": "braces ×{n}"}), so no English grammar is left in the code:
## no plural "s" added, no word order fixed. The code asks for a template by its id and gives its
## values by name; the content's `fills` says which names that is, and the validator holds every
## brace to it (ContentDB.validate_templates).
##
## The table is read once from res://content/templates.json, whichever content a ContentDB loads,
## so the engine's words never depend on a test's synthetic content.

const FILE := "res://content/templates.json"

static var _table: Dictionary = {}   # id -> its entry: {"id", "text" (String or {form: String}), "fills", "count"}
static var _loaded := false
## While on, every template filled is noted as [id, its words] (tools/hangar_readouts.gd: which
## piece's lines use which template, for the hangar's Text tab).
static var tracing := false
static var traced: Array = []
## Whom {self} names in a text (Ryan, 27 November: "Use self everywhere, it's more future proof"):
## the unit whose readout is open, by self_of, set by the screen showing it and cleared as it
## closes, as the tips' sums are (KeywordTip.fills); "" for none, where {self} reads "this Frame".
## A roster holds one of each chassis, so a Frame's name is one Frame.
static var self_name := ""


static func table() -> Dictionary:
	if not _loaded:
		_loaded = true
		_table = {}
		if FileAccess.file_exists(FILE):
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(FILE))
			if parsed is Dictionary:
				for e in parsed.get("entries", []):
					if e is Dictionary and e.has("id"):
						_table[str(e["id"])] = e
	return _table


static func has(id: String) -> bool:
	return table().has(id)


## The template `id` filled with `values` (name -> value): its text, or the form its count picks.
## An id content lacks says itself, so the gap shows on the screen and a test finds it.
static func say(id: String, values: Dictionary = {}) -> String:
	var t = form(id, values)
	var out := fill(t, values)
	if tracing:
		traced.append([id, out])
	return out


## The words {self} stands for with no unit given: the unit in context (self_name), else
## "this Frame" (the template self.none).
static func self_word() -> String:
	return self_name if not self_name.is_empty() else say("self.none")


## A unit's {self}: a Frame by its chassis's name ("the Nemesis", the template self.frame), a
## Sprite "this Sprite" (self.sprite: two of one Sprite is their design, so a name names none),
## nothing "this Frame" (self.none).
static func self_of(u) -> String:
	if u == null:
		return say("self.none")
	if u is Foe:
		return say("self.sprite")
	return say("self.frame", {"name": str(u.get("display_name"))})


## `text` with every {self} as the words it stands for: `values`' "self" when given, else
## self_word; capitalised where it opens the text, a line or a block's line, or follows a label's
## colon or a full stop. Resolved over the whole text before any brace is filled, so a template
## laid out as parts still reads its sentence.
static func with_self(text: String, values: Dictionary = {}) -> String:
	if text.find("{self}") < 0:
		return text
	var who := str(values["self"]) if values.has("self") else self_word()
	var out := ""
	var i := 0
	while true:
		var at := text.find("{self}", i)
		if at < 0:
			out += text.substr(i)
			break
		out += text.substr(i, at - i)
		var before := text.substr(0, at)
		var opens := before.is_empty() or before.ends_with("\n") or before.ends_with("\n  ") or before.ends_with(": ") or before.ends_with(". ")
		out += (who.substr(0, 1).to_upper() + who.substr(1)) if opens else who
		i = at + "{self}".length()
	return out


## The template's text before it is filled: the form its count picks among its forms.
static func form(id: String, values: Dictionary = {}) -> String:
	var e: Dictionary = table().get(id, {})
	if e.is_empty():
		push_error("Templates: content/templates.json has no %s" % id)
		return id
	var t = e.get("text", "")
	if t is Dictionary:
		var k := plural(_count(values.get(str(e.get("count", "n")), 0)))
		return str(t.get(k, t.get("other", "")))
	return str(t)


## A count's number: an int as given, a part's or a text's digits.
static func _count(v) -> int:
	if v is int:
		return v
	if v is Dictionary:
		return str((v as Dictionary).get("text", "0")).to_int()
	return str(v).to_int()


## The form a count takes (CLDR's plural categories; English has two: one for 1, other for every
## other count). A translation keyed by another language's categories reads its own rule here.
static func plural(n: int) -> String:
	return "one" if n == 1 else "other"


## `text` with each {name} replaced by its value, in one pass, so a value is never read again
## as a template; a brace with no value is left as it stands. {self} is always filled
## (with_self).
static func fill(text: String, values: Dictionary) -> String:
	text = with_self(text, values)
	var out := ""
	var i := 0
	while i < text.length():
		var open := text.find("{", i)
		if open < 0:
			out += text.substr(i)
			break
		var close := text.find("}", open)
		if close < 0:
			out += text.substr(i)
			break
		var key := text.substr(open + 1, close - open - 1)
		out += text.substr(i, open - i)
		if values.has(key):
			var v = values[key]
			out += str((v as Dictionary).get("text", "")) if v is Dictionary else str(v)
		else:
			out += text.substr(open, close - open + 1)
		i = close + 1
	return out


## The template as a readout's parts ({text, trend, gain}, EntryReadout.word's shape): a value
## given as a part (a number a live source moved, EntryReadout.num) is a part of its own, its
## text the whitespace-bounded run its brace stands in ("×{n}" is one part, "×2", moved as the
## number moved); the words around it, values given as plain text among them, run together as
## one plain part, so a line keeps the parts the readout lays it out by.
static func parts(id: String, values: Dictionary = {}) -> Array:
	var text := with_self(form(id, values), values)
	var filled := fill(text, values)
	if tracing:
		traced.append([id, filled])
	var out: Array = []
	var run: Array[String] = []
	for token in text.split(" ", false):
		var part: Dictionary = {}
		var k := token.find("{")
		while k >= 0:
			var close := token.find("}", k)
			if close < 0:
				break
			var v = values.get(token.substr(k + 1, close - k - 1))
			if v is Dictionary:
				part = v
				break
			k = token.find("{", close)
		if part.is_empty():
			run.append(fill(token, values))
			continue
		if not run.is_empty():
			out.append({"text": " ".join(run), "trend": 0, "gain": false})
			run.clear()
		var p: Dictionary = part.duplicate()
		p["text"] = fill(token, values)
		out.append(p)
	if not run.is_empty():
		out.append({"text": " ".join(run), "trend": 0, "gain": false})
	return out


## Every brace a text holds, in order: what the validator holds to a template's fills.
static func braces(text: String) -> Array[String]:
	var out: Array[String] = []
	var i := text.find("{")
	while i >= 0:
		var close := text.find("}", i)
		if close < 0:
			break
		out.append(text.substr(i + 1, close - i - 1))
		i = text.find("{", close)
	return out


## Every form a template's text holds: its text alone, or each of its forms.
static func forms_of(t) -> Array[String]:
	var out: Array[String] = []
	if t is Dictionary:
		for k in (t as Dictionary).keys():
			out.append(str(t[k]))
	else:
		out.append(str(t))
	return out

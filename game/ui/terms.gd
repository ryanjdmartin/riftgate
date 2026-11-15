class_name Terms
extends RefCounted

## The terms the keywords list defines (its reach, keywords, rules on a component, statuses and
## the keywords a foe's move carries: PauseMenu.GLOSSARY), each with its icon and its colour: the one table the die's marks, the
## chips and shown text read, so a term looks the same wherever it shows (Ryan, 30 October:
## "standardize the keyword colours ... We don't need a unique colour for each keyword,
## obviously. Just groups that kind of make sense. Neutral white or grey or whatever is also
## available ... Stay away from HUD colour obviously"). A group is one of Palette's meanings,
## never the HUD colour, which is decoration:
##   heat   heat's red-orange: fire, heat and what hits harder
##   guard  the shield's blue: what protects or holds (a shield, armour, a ward, a stun, a lure)
##   enemy  the enemy's violet: what only a foe does
##   harm   the red-red: harm to a unit (Exposed, a destroyed component)
##   hull   the hull's colour: a price paid in hull
##   plain  ink: a shape, a reach or a rule
## Ids are the vocabulary's (content/vocabulary.json); a test ties the table to it, so a term
## added or renamed there fails the build until it has its row here. A glyph "" draws none.
const TABLE := {
	# Reach.
	"direct": ["aim_direct", "plain"], "indirect": ["aim_indirect", "plain"],
	# Keywords.
	"cleave": ["cleave", "plain"], "penetrate": ["penetrate", "plain"], "splash": ["splash", "plain"],
	"every_foe": ["aim_every_foe", "plain"], "every_ally": ["aim_every_ally", "plain"], "every_other_ally": ["aim_every_other_ally", "plain"],
	"spillover": ["spillover", "plain"], "rapid": ["rapid", "plain"], "instant": ["instant", "plain"],
	"burn": ["burn", "heat"], "shock": ["shock", "heat"], "chain": ["chain", "heat"],
	"flak": ["flak", "heat"], "breach": ["breach", "heat"], "sap": ["sap", "guard"],
	"cryo": ["cryo", "guard"], "lure": ["lure", "guard"], "disrupt": ["disrupt", "guard"],
	"suppress": ["suppress", "guard"], "web": ["web", "guard"], "swap": ["swap", "guard"],
	"dispel": ["dispel", "guard"], "cleanse": ["cleanse", "guard"], "overshield": ["overshield", "guard"],
	"expose": ["expose", "harm"],
	"disable": ["blank", "enemy"], "corrupt": ["corrupt", "enemy"], "steal": ["steal", "enemy"],
	# Rules on a component.
	"targets": ["", "plain"], "strikes": ["", "plain"],
	"gated": ["", "plain"], "consumes": ["", "plain"], "power_per_missing": ["", "plain"], "finisher": ["", "plain"],
	"cooldown": ["cooldown", "plain"],
	"hopper_property": ["hopper", "plain"],
	"volatile": ["hull", "hull"], "shield_cost": ["shield", "guard"], "brace_property": ["shield", "guard"],
	"self_burn": ["burn", "heat"], "vents_all": ["vent", "heat"],
	"gather": ["mine", "heat"], "detonate": ["mine", "heat"],
	"regenerates": ["regenerating", "guard"], "ally_action": ["reroll", "plain"], "rolls_target": ["reroll", "plain"],
	"kill_rerolls": ["reroll", "plain"],
	# Statuses.
	"burning": ["burn", "heat"], "scorched": ["scorch", "heat"], "primed": ["primed", "heat"],
	"overcharged": ["overcharge", "heat"], "kindled": ["overcharge", "heat"], "enraged": ["overcharge", "heat"], "golden": ["overcharge", "heat"], "shocked": ["shocked", "heat"],
	"charged": ["shocked", "heat"], "supercooled": ["cryo", "guard"],
	"flakked": ["flak", "heat"], "vitriol": ["vitriol", "heat"], "spun_up": ["spin", "heat"], "ricochet": ["ricochet", "heat"],
	"mine": ["mine", "heat"],
	"souls": ["soul", "heat"], "pinned_empowered": ["pin_empower", "heat"],   # the Ammit's count and its Siphon's hold (12 November), with Empowered's group: what hits harder
	"braced": ["shield", "guard"], "barrier": ["barrier", "guard"], "ward": ["ward", "guard"],
	"phased": ["phased", "guard"], "guarded": ["lock", "guard"], "sealed": ["seal", "guard"], "changed_over": ["reroll", "plain"],
	"retaliate": ["shocked", "guard"], "suppressed": ["suppress", "guard"], "webbed": ["web", "guard"],
	"numbed": ["numbed", "guard"], "paradox": ["paradox", "guard"], "cryoed": ["cryo", "guard"],
	"exposure": ["exposed", "harm"], "pinned": ["pin_flak", "heat"], "sapped": ["sap", "guard"], "juggernaut_breach": ["breach", "heat"], "pinned_burning": ["pin_burn", "heat"], "destroyed_component": ["crack", "harm"],
	"corrupted": ["corrupt", "enemy"], "crushed": ["flak", "enemy"], "disabled": ["blank", "enemy"], "silenced": ["silence", "enemy"],
	"risen": ["star", "enemy"], "regenerating": ["regenerating", "guard"], "swallowed": ["swallowed", "enemy"],
	"ability": ["", "plain"],   # a unit's own mechanic, no buff or debuff (8 November): its chips carry their own marks
	"rallied": ["reroll", "plain"], "quick_turned": ["rapid", "plain"],
	"overheated": ["heat", "heat"], "broken": ["shieldbreak", "guard"], "rebooting": ["shield_vent", "plain"],   # the reboot's three states (13 November), read off the gauges: no status of the engine's table
	# A foe's moves: the keywords they carry, the list's last heading. A foe-side word without a row
	# here (its aim, its menace, the seal) is the engine's and stays out of the list.
	"scorch": ["scorch", "heat"], "crush": ["flak", "enemy"], "golden_rage": ["overcharge", "heat"], "silence": ["silence", "enemy"], "swallow": ["swallowed", "enemy"],
	"self_destruct": ["blast", "enemy"], "all": ["all", "enemy"], "countdown": ["warning", "enemy"],
	"follow_up": ["next", "enemy"], "last_act": ["skull", "enemy"], "parts": ["parts", "enemy"],
	"drain": ["heart", "enemy"],   # the Vampire Lord's (31 October): a blow that regrows what it took from the hull
}

## An engine status keyed apart from its term: a machine's Burning, the Badger's hopper.
const ALIASES := {"burning_mech": "burning", "hopper": "hopper_property"}

## Terms never matched in prose: names a shown text uses as a plain word in their place
## ("Targets any front-rank foe", a move that "Strikes twice").
const UNMATCHED := ["targets", "strikes"]

static var _rx: RegEx = null          # every matched name, longest first, with a number after it
static var _skip_rx: RegEx = null     # names of things that hold a term's word (the Web Bomb)
static var _by_name: Dictionary = {}  # a shown name or form -> its term ids, the keyword's first


static func has(id: String) -> bool:
	return TABLE.has(id)


static func glyph(id: String) -> String:
	return str(TABLE.get(id, ["", "plain"])[0])


static func group(id: String) -> String:
	return str(TABLE.get(id, ["", "plain"])[1])


## A group's colour, read live, so a debug build's COLOURS page moves it (ColourTuner).
static func group_colour(g: String) -> Color:
	match g:
		"heat":
			return Palette.HEAT
		"guard":
			return Palette.SHIELD
		"enemy":
			return Palette.ENEMY
		"harm":
			return Palette.LOSS
		"hull":
			return Palette.HULL
	return Palette.INK


static func colour(id: String) -> Color:
	return group_colour(group(id))


## The term an engine status stands for: its own id, an alias's, or a component's mark by its
## prefix ("corrupted_2"); "" when the list defines none (the Nemesis's rage, a store).
static func of_status(status_id: String) -> String:
	if ALIASES.has(status_id):
		return str(ALIASES[status_id])
	for prefix in ["corrupted", "disabled"]:
		if status_id.begins_with(prefix):
			return prefix
	return status_id if TABLE.has(status_id) else ""


## A status's colour on its chip: its term's, or ink when the list defines none.
static func status_colour(status_id: String) -> Color:
	var term := of_status(status_id)
	return colour(term) if not term.is_empty() else Palette.INK


## What one term is, over its tip: the list's headings (PauseMenu.GLOSSARY) for one.
const KINDS := {"reach": "REACH", "keyword": "KEYWORD", "component_property": "RULE ON A COMPONENT", "status": "STATUS", "foe": "A FOE'S MOVE"}
## A status's heading by what it is to its unit (Effects.status_kind; Ryan, 9 November: buffs and
## debuffs "clearly labeled as such, so that it's clear what gets purged").
const STATUS_KINDS := {"buff": "BUFF // A PURGE TAKES IT", "debuff": "DEBUFF", "ability": "ABILITY // NOTHING STRIPS IT"}


## The list's entry for a term, for its tip: its name, its line and what kind of term it is, a
## status's by what it is to its unit.
static func entry(id: String, db: ContentDB = null) -> Dictionary:
	if db == null:
		db = ContentDB.load_default()
	var e: Dictionary = db.vocabulary.get(id, {})
	var heading := str(KINDS.get(str(e.get("category", "")), ""))
	if str(e.get("category", "")) == "status":
		heading = str(STATUS_KINDS.get(Effects.status_kind(engine_status(id)), heading))
	return {"id": id, "name": str(e.get("name", id)), "codex": str(e.get("codex", "")), "heading": heading}


## The engine's status a status term names: its own id, or the engine's where an alias keys it apart
## (the hopper's term, a machine's Burning reading as the foe's).
static func engine_status(term_id: String) -> String:
	for k in ALIASES.keys():
		if str(ALIASES[k]) == term_id and Effects.STATUS.has(str(k)) and not Effects.STATUS.has(term_id):
			return str(k)
	return term_id


## `text` cut into runs, each {text, terms}: a term the list defines, by its name or a keyword's
## verb form ("Exposes"), with a number after it ("Spread 2", "Flak N"), carries its ids (two
## where a keyword and the status it leaves share a name: Cryo, Flak); the rest has none. A name
## inside the name of a component, a module, a chassis, a passive or a foe (the Web Bomb, the
## Pocket Paradox) is no term there.
## Case counts: shown text writes a term with its capital, so a plain "shield" stays a word.
static func split(text: String) -> Array:
	_build()
	var out: Array = []
	if text.is_empty() or _rx == null:
		return [{"text": text, "terms": []}]
	var skips: Array = []
	if _skip_rx != null:
		for m in _skip_rx.search_all(text):
			skips.append(Vector2i(m.get_start(), m.get_end()))
	var at := 0
	for m in _rx.search_all(text):
		var start := m.get_start()
		var inside := false
		for s in skips:
			if start >= s.x and start < s.y:
				inside = true
				break
		if inside or start < at:
			continue
		if start > at:
			out.append({"text": text.substr(at, start - at), "terms": []})
		out.append({"text": m.get_string(), "terms": _by_name.get(m.get_string(1), [])})
		at = m.get_end()
	if at < text.length():
		out.append({"text": text.substr(at), "terms": []})
	return out


## The matcher, built once from the vocabulary: every implemented term the list shows by its
## name, a keyword by its verb forms too ("Suppresses", "Suppressing"), longest first.
static func _build() -> void:
	if _rx != null:
		return
	var db := ContentDB.load_default()
	var names: Array[String] = []
	_by_name.clear()
	for kind in PauseMenu.GLOSSARY:
		for id in db.vocabulary.keys():
			var e: Dictionary = db.vocabulary[id]
			if str(e.get("category", "")) != str(kind[0]) or str(e.get("status", "")) != "implemented" or UNMATCHED.has(str(id)):
				continue
			if str(kind[0]) == "foe" and not TABLE.has(str(id)):
				continue   # a foe-side word that is the engine's (its aim, its menace), never a move's keyword
			var name := str(e.get("name", ""))
			if name.is_empty():
				continue
			var forms: Array[String] = [name]
			if str(kind[0]) == "keyword":
				forms.append_array(verb_forms(name))
			for f in forms:
				if not _by_name.has(f):
					_by_name[f] = []
					names.append(f)
				if not (_by_name[f] as Array).has(str(id)):
					(_by_name[f] as Array).append(str(id))
	names.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())
	var alt: PackedStringArray = []
	for n in names:
		alt.append(_escape(n))
	_rx = RegEx.new()
	_rx.compile("\\b(" + "|".join(alt) + ")(?: (?:\\d+|N))?\\b")
	# The names of things that hold a term's word without being one: a piece's, a chassis's and
	# its passive's ("Pocket Paradox"), a foe's.
	var holders: Array[String] = []
	for table in [db.components, db.modules, db.chassis, db.foes]:
		for key in (table as Dictionary).keys():
			var e = (table as Dictionary)[key]
			if not (e is Dictionary):
				continue
			var said: Array[String] = [str(e.get("name", ""))]
			if e.get("passive") is Dictionary:
				said.append(str((e["passive"] as Dictionary).get("name", "")))
			for n in said:
				if not n.is_empty() and not _by_name.has(n) and _rx.search(n) != null and not holders.has(n):
					holders.append(n)
	holders.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())
	if not holders.is_empty():
		var halt: PackedStringArray = []
		for n in holders:
			halt.append(_escape(n))
		_skip_rx = RegEx.new()
		_skip_rx.compile("(" + "|".join(halt) + ")")


## A keyword's verb forms as shown text writes them: "Exposes", "Exposing"; "Suppresses".
static func verb_forms(name: String) -> Array[String]:
	if name.contains(" "):
		return []
	var stem := name.substr(0, name.length() - 1) if name.ends_with("e") else name
	var s := name + ("es" if name.ends_with("s") or name.ends_with("sh") or name.ends_with("ch") or name.ends_with("x") else "s")
	return [s, stem + "ing"]


## Rebuild the matcher (a test that swaps the content).
static func reset() -> void:
	_rx = null
	_skip_rx = null
	_by_name.clear()


static func _escape(s: String) -> String:
	var out := ""
	for ch in s:
		out += ("\\" + ch) if "\\^$.|?*+()[]{}".contains(ch) else ch
	return out

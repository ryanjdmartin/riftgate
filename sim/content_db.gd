class_name ContentDB
extends RefCounted

## Loads content/*.json, validates it against the design rules, and builds runtime objects.
## Content is authored fantasy-first in JSON; the validator is the vetting pass that runs
## in the test suite, so a concept that breaks a rule fails the build.

const DIR := "res://content/"

# Design knobs. Loosen or tighten here; the validator and the bible should agree.
const MAX_AUTHORED_KEYWORDS := 3    # per authored face; upgrades may exceed this at runtime
const MAX_MOVE := 6                 # a move in hexes, chassis or foe, is 1 to this (a placeholder bound, 28 October)
const HUNTER_RING := 2              # a hunter's ring at least: it pounces (Ryan, 29 October)
const MIN_DIE := 3                  # the Kite is a d3 (its row, Ryan's go of 21 October: every dark entry felt)
const MAX_DIE := 10                 # the Clydesdale carries nine (Ryan, 28 September); ten leaves it room
## A chassis's class by mass, lightest first (Ryan, 5 October: the machines' scale on the map
## and in the skirmish): how big it is drawn, Map3D.SIZE_FIT and MechView3D.SIZE_FILL.
const SIZES := ["light", "medium", "heavy", "assault"]
## The measures a run tallies for Sponsorship (the bible's row; Battle.sponsorship and
## Skirmish.sponsorship keep them): hexes moved on the map, damage taken on shield and armour,
## dice spent on entries that deal damage, and on entries that deal none.
const SPONSORSHIP_MEASURES := ["hexes_moved", "guarded", "damaging_spends", "quiet_spends"]
const MAX_PASSIVE_EFFECTS := 3      # effects in one passive; a benefit and its cost is one passive
const MAX_MODULE_SLOTS := 4         # a chassis's module slots: two as a rule, three on the Clydesdale (Ryan); room to move
## Internal design text lives under `design` and is never shown. These keys at the top level
## of an entry are the old layout, or a leak waiting to happen, so the validator refuses them.
const DESIGN_ONLY_KEYS := ["fantasy", "question", "niche", "rule", "holes", "signature", "answer", "notes"]
const VALID_STATUS := ["implemented", "planned", "idea"]

static var _cache: ContentDB = null

var vocabulary: Dictionary = {}   # id -> entry
var factions: Dictionary = {}
var foes: Dictionary = {}
var chassis: Dictionary = {}
var components: Dictionary = {}
var modules: Dictionary = {}
var makers: Dictionary = {}
var categories: Array = []
## Machine names from the properties our designs sit nearest (content/reserved_names.json:
## every BattleTech 'Mech, Heavy Gear, Warhammer 40k, Halo), keyed by their normalised form
## (see normalise_name) with "Name (a BattleTech 'Mech)" for the message. A chassis nickname
## or id that lands on one fails validation (Ryan, 28 September: ours or a homage, never a copy).
var reserved_names: Dictionary = {}
var _menace: Dictionary = {}      # foe id -> its menace, read once (menace)
var load_errors: Array[String] = []


static func load_default() -> ContentDB:
	if _cache == null:
		var db := ContentDB.new()
		db.load_dir(DIR)
		_cache = db
	return _cache


static func reset_cache() -> void:
	_cache = null


func load_dir(dir: String) -> void:
	var v := _read(dir + "vocabulary.json")
	vocabulary = _index(v)
	categories = v.get("categories", [])
	factions = _index(_read(dir + "factions.json"))
	foes = _index(_read(dir + "foes.json"))
	_resolve_promotions()
	var c := _read(dir + "chassis.json")
	chassis = _index(c)
	makers = {}
	for m in c.get("makers", []):
		makers[m["id"]] = m
	components = _index(_read(dir + "components.json"))
	modules = _index(_read(dir + "modules.json"))
	reserved_names = {}
	var reserved := _read(dir + "reserved_names.json")
	var sources: Dictionary = reserved.get("sources", {})
	for source in sources.keys():
		var label := str(sources[source].get("label", source))
		for n in sources[source].get("names", []):
			var key := normalise_name(str(n))
			if not reserved_names.has(key):   # the first source to claim a name labels it
				reserved_names[key] = "%s (%s)" % [str(n), label]
	if not reserved.is_empty() and reserved_names.size() < 1000:
		load_errors.append("reserved_names.json holds %d names; the four catalogues had over a thousand" % reserved_names.size())


## Letters and digits only, lower case, so "Black Hawk-KU", "black_hawk_ku" and "BlackHawk KU"
## are one name. Accented letters are kept as they are.
static func normalise_name(s: String) -> String:
	var out := ""
	for ch in s.to_lower():
		if ch != " " and ch != "-" and ch != "_" and ch != "'" and ch != "." and ch != "," and ch != "(" and ch != ")":
			out += ch
	return out


func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		load_errors.append("missing file %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		load_errors.append("%s is not valid JSON" % path)
		return {}
	return parsed


## A promoted form's entry holds what its class change adds (the bible's section 9: massive,
## armour 5, one move more) and takes the rest from its hero as the content loads, so every
## reader sees a whole entry: each field it does not set, and the hero's moves before its own
## (a move of its own with a hero's move's id takes that move's place). `hero` and `design`
## stay its own. An entry naming no hero is left as written, for the validator to refuse.
func _resolve_promotions() -> void:
	for id in foes.keys():
		var e: Dictionary = foes[id]
		var base_id := str(e.get("promotes", ""))
		if base_id.is_empty() or not foes.has(base_id) or foes[base_id].has("promotes"):
			continue
		var whole: Dictionary = foes[base_id].duplicate(true)
		whole.erase("hero")
		whole.erase("design")
		for k in e.keys():
			if k != "actions":
				whole[k] = e[k]
		var own: Array = e.get("actions", []) if e.get("actions", []) is Array else []
		var by_id := {}
		for o in own:
			if o is Dictionary:
				by_id[str(o.get("id", ""))] = o
		var acts: Array = []
		var taken := {}
		for a in foes[base_id].get("actions", []):
			var aid := str(a.get("id", "")) if a is Dictionary else ""
			if by_id.has(aid):
				acts.append(by_id[aid].duplicate(true))
				taken[aid] = true
			else:
				acts.append(a.duplicate(true) if a is Dictionary else a)
		for o in own:
			if not (o is Dictionary and taken.has(str(o.get("id", "")))):
				acts.append(o.duplicate(true) if o is Dictionary else o)
		whole["actions"] = acts
		foes[id] = whole


func _index(d: Dictionary) -> Dictionary:
	var out := {}
	for e in d.get("entries", []):
		if e is Dictionary and e.has("id"):
			if out.has(e["id"]):
				load_errors.append("duplicate id %s" % e["id"])
			out[e["id"]] = e
	return out


# ---------------------------------------------------------------- building

func build_face(d: Dictionary) -> Face:
	return Face.from_dict(d)


## Assemble a die: the chassis's fixed components first, then the loadout into its
## hardpoints, then an empty entry for every hardpoint left. One component is one entry.
func build_die(fixed_ids: Array, loadout_ids: Array, hardpoints: int) -> Die:
	var die := Die.new()
	for cid in fixed_ids + loadout_ids:
		var comp: Dictionary = components.get(cid, {})
		var f := build_face(comp.get("face", {}))
		f.component = str(cid)
		for t in comp.get("tags", []):
			f.tags.append(str(t))
		f.fixed = fixed_ids.has(cid)
		die.faces.append(f)
	for i in range(maxi(0, hardpoints - loadout_ids.size())):
		die.faces.append(Face.empty_slot())
	return die


## A machine as the content builds it. `loadout` is the hardpoint components fitted, in
## order; null means the chassis's stock loadout (the campaign passes its roster's own).
func make_mech(chassis_id: String, uid: int = 0, at: Vector2i = Vector2i.ZERO, loadout = null, fitted_modules: Array = []) -> Unit:
	var c: Dictionary = chassis[chassis_id]
	var fitted: Array = c.get("loadout", []) if loadout == null else loadout
	var u := Unit.mech(uid, str(c["name"]), at, int(c.get("movespeed", Unit.MECH_MOVE)))
	u.hull = int(c.get("hull", 100))
	u.hull_max = u.hull
	u.shield = int(c.get("shield", 40))
	u.shield_max = u.shield
	u.heat_max = int(c.get("heat_max", 60))
	for t in c.get("traits", []):
		u.traits.append(str(t))
	u.hardpoints = int(c.get("hardpoints", 6))
	u.armour = int(c.get("armour", 0))
	u.recharge_field = int(c.get("recharge_field", 0))
	u.cooling = int(c.get("cooling", 0))
	u.die = build_die(c.get("fixed", []), fitted, u.hardpoints)
	u.chassis_id = chassis_id
	var p = c.get("passive", null)
	if p is Dictionary:
		u.passive = p
		u.grant_passive(p, "chassis")
	# Fitted components bring their own passives; a destroyed one keeps its bonuses only.
	for cid in c.get("fixed", []) + fitted:
		var cp = components.get(cid, {}).get("passive", null)
		if cp is Dictionary:
			u.grant_passive(cp, cid, cid)
	# Modules, as many as the chassis has slots; then the machine starts whole on the numbers
	# they made.
	for mid in fitted_modules.slice(0, int(c.get("module_slots", 0))):
		fit_module(u, str(mid))
	u.hull = u.hull_max
	u.shield = u.shield_max
	return u


## A module fitted to a machine: its stat lines and its text as one passive, a loadout-long
## modifier sourced "module" (Effects; never written to a stat). No component carries it, so
## nothing on the die can take it away. Fitting the same module twice stacks it.
func fit_module(u: Unit, module_id: String) -> void:
	var m: Dictionary = modules.get(module_id, {})
	if m.is_empty():
		return
	u.modules.append(module_id)
	u.grant_passive(module_passive(module_id), "module")


## A module as the passive the engine runs: an add_stat per stat line, then the text's
## effects (none while the text is planned).
func module_passive(module_id: String) -> Dictionary:
	var m: Dictionary = modules.get(module_id, {})
	var effects: Array = []
	var stats: Dictionary = m.get("stats", {})
	for k in stats.keys():
		effects.append({"trigger": "static", "effect": "add_stat", "stat": str(k), "value": int(stats[k])})
	var text = m.get("text", null)
	if text is Dictionary and str(text.get("status", "implemented")) == "implemented":
		effects.append_array(text.get("effects", []))
	return {"id": "module:" + module_id, "name": str(m.get("name", module_id)), "description": module_description(module_id), "effects": effects}


## What the player reads for a module: its stat lines, then its text.
func module_description(module_id: String) -> String:
	var m: Dictionary = modules.get(module_id, {})
	var bits: Array[String] = []
	var stats: Dictionary = m.get("stats", {})
	for k in stats.keys():
		var v := int(stats[k])
		bits.append("%s %s%d" % [STAT_WORDS.get(str(k), str(k)), "+" if v > 0 else "", v])
	var line := ", ".join(bits)
	var text = m.get("text", null)
	if text is Dictionary and str(text.get("status", "implemented")) == "implemented":
		var d := str(text.get("description", ""))
		line = d if line.is_empty() else "%s. %s" % [line.substr(0, 1).to_upper() + line.substr(1), d]
	elif not line.is_empty():
		line = line.substr(0, 1).to_upper() + line.substr(1) + "."
	return line


## The words a stat line is shown with.
const STAT_WORDS := {"hull": "hull", "shield": "shield", "heat": "heat max", "armour": "armour", "move": "move", "recharge": "field recharge", "cooling": "cooling"}


func module_name(module_id: String) -> String:
	return str(modules.get(module_id, {}).get("name", module_id))


## A vocabulary term's shown name (the ground's word on the tap, a fight's label), its id when
## the vocabulary has none.
func term_name(id: String) -> String:
	return str(vocabulary.get(id, {}).get("name", id))


func component_name(cid: String) -> String:
	return str(components.get(cid, {}).get("name", cid))


func make_foe(foe_id: String) -> Foe:
	var d: Dictionary = foes[foe_id]
	var f := Foe.make(str(d["name"]), int(d["hp"]), int(d["attack"]), str(d.get("rank", "front")) == "back")
	f.size = int(d.get("size", 1))
	f.armour = maxi(0, int(d.get("armour", 0)))
	f.armour_step = maxi(0, int(d.get("armour_step", 0)))
	f.wanders = bool(d.get("wanders", false))
	f.aim = str(d.get("aim", Foe.AIM_ANYTHING))
	f.hero = bool(d.get("hero", false)) or d.has("promotes")   # one of the party: a hero, or its promoted form
	f.boss = is_boss(foe_id)
	# A boss in parts (15 October): its parts' types, its guard and how its parts grow back.
	f.part_ids = Array(d.get("parts", [])).map(func(x): return str(x))
	f.guard = str(d.get("guard", ""))
	f.regrow_parts = maxi(0, int(d.get("regrow_parts", 0)))
	var od = d.get("on_death", {})
	if od is Dictionary:
		# A split (the Gel) and a last act (15 October, the Behemoth's Meteor), either or both.
		var made := {}
		if od.has("summon"):
			made["summon"] = str(od["summon"])
			made["count"] = maxi(1, int(od.get("count", 1)))
			if bool(od.get("pair", false)):
				made["pair"] = true   # its two halves stand as a pair in its slot (the Gel's, 26 October)
		if od.get("blow", null) is Dictionary:
			made["blow"] = Foe.death_blow_from(od["blow"])
		f.on_death = made
	var acts: Array = []
	for a in d.get("actions", []):
		if str(a.get("status", "")) != "implemented":
			continue
		var kind := str(a.get("kind", "attack"))
		var act: Dictionary
		if kind == "attack":
			act = {"id": str(a.get("id", "attack")), "name": str(a.get("name", "Attack")), "kind": "attack", "factor": float(a.get("factor", 1.0)),
				"strikes": int(a.get("strikes", 1)), "weight": int(a.get("weight", 1)), "keywords": Array(a.get("keywords", [])), "text": str(a.get("text", ""))}
			if a.has("swarm"):
				act["swarm"] = int(a["swarm"])
			for k in Foe.NUMBERED_RIDERS:
				if a.has(k):
					act[k] = int(a[k])   # the stacks the rider lays a blow
			if a.has("countdown"):
				act["countdown"] = int(a["countdown"])
			if a.has("power"):
				act["power"] = str(a["power"])   # a borrowed swing: the number of what a steal took (30 October)
			if a.has("per_kill"):
				act["per_kill"] = int(a["per_kill"])   # a point a foe the team has killed this fight (the Pilgrim's Karma, 30 October)
		else:
			# A defend, buff or debuff: its effect and the fields it reads (Foe.ACTION_EFFECTS).
			act = {"id": str(a.get("id", kind)), "name": str(a.get("name", kind.capitalize())), "kind": kind, "effect": str(a.get("effect", "")),
				"value": int(a.get("value", 0)), "weight": int(a.get("weight", 1)), "text": str(a.get("text", ""))}
			if a.has("foe"):
				act["foe"] = Foe.kinds_named(a) if a["foe"] is Array else str(a["foe"])   # a merge names a list of kinds
			if a.has("count"):
				act["count"] = int(a["count"])
		# The move's own sense and condition (2 October), when it has them.
		if a.has("aim"):
			act["aim"] = str(a["aim"])
		if a.has("when"):
			act["when"] = Foe.whens_of(a)
		if a.has("then"):
			act["then"] = str(a["then"])   # the follow-up it announces next round (30 October)
		if bool(a.get("once", false)):
			act["once"] = true   # a special used once a fight (30 October)
		acts.append(act)
	# The first attack leads, so a foe's opening intent is its blow; the rest keep content's
	# order, the pattern a Disrupt steps through (Skirmish.disrupt_next).
	for i in range(acts.size()):
		if str(acts[i].get("kind", "")) == "attack":
			if i > 0:
				var lead: Dictionary = acts.pop_at(i)
				acts.insert(0, lead)
			break
	if not acts.is_empty():
		f.actions = acts
		f.action = acts[0]
	f.content_id = foe_id
	return f


## Codex text for a foe: its codex entry, its numbers at its own (each in a bracket where this
## foe's differ from its kind's), its implemented moves and its last act (the screen lays each
## out as the die's codex rows, EntryReadout.codex_move_lines), and its quote. Nothing from
## `design` is ever read here.
func codex_for_foe(f: Foe) -> Dictionary:
	var d: Dictionary = foes.get(f.content_id, {})
	var fac: Dictionary = factions.get(str(d.get("faction", "")), {})
	var stats := "HP %d // ATK %d // %s RANK" % [f.hp_max, f.attack, "BACK" if f.prefers_back else "FRONT"]
	if f.armour > 0:
		stats += " // ARM %d" % f.armour
	if f.is_massive():
		stats += " // MASSIVE"
	var moves: Array = []
	for a in f.actions:
		moves.append(a)
	if not f.last_act().is_empty():
		moves.append(f.last_act())
	var faction_name := str(fac.get("name", "")).strip_edges()
	if faction_name.is_empty():
		faction_name = str(d.get("faction", "")).capitalize()
	if bool(d.get("wanders", false)):
		faction_name = "Any domain"   # a wanderer walks out of any rift (31 October)
	var items: Array = [["hp", stat_parts(int(d.get("hp", f.hp_max)), f.hp_max)], ["attack", stat_parts(int(d.get("attack", f.attack)), f.attack)]]
	if f.armour > 0 or int(d.get("armour", 0)) > 0:
		var arm := stat_parts(int(d.get("armour", 0)), f.armour)
		if f.armour_step > 0:
			arm.append({"text": "+%d A TIER" % f.armour_step, "trend": 0, "gain": false})
		items.append(["armour", arm])
	items.append(["rank", "BACK" if f.prefers_back else "FRONT"])
	if f.aim != Foe.AIM_ANYTHING:
		items.append(["sense", str(Foe.AIM_TEXT.get(f.aim, f.aim)).to_upper()])
	if f.is_massive():
		items.append(["size", "MASSIVE"])
	return {
		"title": f.display_name,
		"subtitle": faction_name.to_upper(),
		"body": str(d.get("codex", "")),
		"stats": stats,
		"stat_items": items,
		"moves": moves,   # its implemented moves, the first attack first, then its last act
		"foe": f,
		"passive": "",
		"faces": [],
		"current": -1,
		"flavour": str(d.get("flavour", "")),
		"sprite_id": f.content_id,
	}


## A stat as parts the screen draws (EntryReadout's: text, trend, gain, glue): the base alone,
## or the base with the change in a bracket beside it, signed, the arrow the way it moved (Ryan,
## 26 October: "just go Base (+/- change) like I said, ... with the change value coloured with
## the arrow and the base in the normal white"): "20 (+18▲)". The colour is the unit's, never
## the player's: more is its gain unless `less_is_gain`. `prefix` goes before the base ("+" on
## a rate).
static func stat_parts(base: int, now: int, prefix: String = "", less_is_gain: bool = false) -> Array:
	var out: Array = [{"text": prefix + str(base), "trend": 0, "gain": false}]
	if now != base:
		out.append({"text": "(", "trend": 0, "gain": false})
		out.append({"text": "%+d" % (now - base), "trend": signi(now - base), "gain": (now < base) if less_is_gain else (now > base), "glue": true})
		out.append({"text": ")", "trend": 0, "gain": false, "glue": true})
	return out


## Codex text for a mech: chassis codex, maker, numbers, faces (for a visual list), passive,
## and flavour.
## The name plate's subtitle, part by part: the maker, the chassis's traits by their shown
## names (Ryan, 2 October: the traits are rules the player needs, a silhouette word beside a
## turning model was not), and the die. A chassis with no trait shows no traits part.
func _plate_parts(c: Dictionary, maker: Dictionary, u: Unit) -> Array[String]:
	var parts: Array[String] = [str(maker.get("name", "")).to_upper()]
	var names: Array[String] = []
	for t in c.get("traits", []):
		names.append(str(vocabulary.get(str(t), {}).get("name", str(t))).to_upper())
	if not names.is_empty():
		parts.append(", ".join(names))
	parts.append("D%d" % (u.die.size() if u.die != null else 0))
	return parts


## The maker a chassis is built by: its own, else the first maker in content's order, so no
## runtime default names a maker (CLAUDE.md: defaults come from content).
func maker_of(chassis_id: String) -> String:
	var m := str(chassis.get(chassis_id, {}).get("maker", ""))
	if makers.has(m):
		return m
	return str(makers.keys()[0]) if not makers.is_empty() else ""


func codex_for_unit(u: Unit) -> Dictionary:
	var c: Dictionary = chassis.get(u.chassis_id, {})
	var maker: Dictionary = makers.get(str(c.get("maker", "")), {})
	# The codex is the machine between fights (Ryan, 26 September): each number is the chassis's
	# own, with what its loadout and the battle make of it in a bracket where they move it (26
	# October), never a combat effect; the hold in the fight has those.
	var now := {}
	for k in Effects.STATS:
		now[k] = Effects.stat(u, k, Effects.BATTLE)
	var stats := "SHIELD %d (+%d A PHASE OUT OF COMBAT) // HULL %d // ARMOUR %d // HEAT %d (-%d A TURN) // MOVE %d // %d HARDPOINTS // D%d" % [
		now["shield"], now["recharge"], now["hull"], now["armour"], now["heat"], now["cooling"], now["move"], u.hardpoints, u.die.size() if u.die != null else 0]
	# The die as built: the codex shows each component at its own numbers (26 October).
	var faces: Array = []
	var face_rules: Array = []   # each entry's component passive, its lines on the component's row
	if u.die != null:
		for f in u.die.faces:
			faces.append(f)
			face_rules.append([])
	# The chassis passive is the passive row; a component's passive rides on its row; everything
	# else the machine carries between fights (a module, a battle's reward, a status the battle
	# keeps) is an active effect, listed under them (Ryan, 26 October: "non-chip effects granted
	# not as part of the passive, such as modules, auras, battle effects from fracture rewards").
	# Each row says where it comes from, and the codex colours it by that.
	var rows: Array = []
	var effects: Array = []
	for d in Effects.describe(u):
		if d[3] != Effects.LOADOUT and d[3] != Effects.BATTLE:
			continue
		var head: String = str(d[0]).to_upper()
		if d[2] == "chassis":
			rows.append(["%s: %s" % [head, d[1]], "chassis"])
		elif components.has(d[2]):
			for i in range(faces.size()):
				if faces[i].component == d[2]:
					face_rules[i].append("%s: %s" % [str(d[0]), d[1]])
		elif d[2] == "module":
			effects.append({"name": head, "text": str(d[1]), "kind": "module", "note": "MODULE"})
		elif Effects.is_status(str(d[5])):
			# A status the battle keeps (the Ammit's Overcharged, 16 October): its count, kept for
			# the battle.
			effects.append({"name": head + (" ×%d" % int(d[4]) if int(d[4]) > 1 else ""), "text": str(d[1]), "kind": "reward", "note": "KEPT FOR THE BATTLE"})
		else:
			effects.append({"name": head, "text": str(d[1]), "kind": "reward", "note": "REWARD"})
	var passive_lines: Array[String] = []
	for r in rows:
		passive_lines.append(str(r[0]))
	return {
		"title": u.display_name,
		"subtitle": " // ".join(_plate_parts(c, maker, u)),
		"designation": str(c.get("designation", "")),   # the maker's long name; the title is the nickname
		"body": str(c.get("codex", "")),   # never fantasy: that field is design notes and homages
		"stats": stats,
		# Hardpoints are not a number here: the component list shows them as sockets.
		# The machine's numbers, never its state (Ryan, 22 September: the codex is the spec
		# plate; the gauges say how it is doing): maxima with their rates beside them.
		"stat_items": [["shield max", stat_parts(int(u.base["shield"]), now["shield"])], ["recharge", stat_parts(int(u.base["recharge"]), now["recharge"], "+")],
			["hull max", stat_parts(int(u.base["hull"]), now["hull"])], ["armour", stat_parts(int(u.base["armour"]), now["armour"])],
			["heat max", stat_parts(int(u.base["heat"]), now["heat"])], ["cooling", stat_parts(int(u.base["cooling"]), now["cooling"])],
			["move", stat_parts(int(u.base["move"]), now["move"])]],
		"actions": "",
		"passive": "\n".join(passive_lines),
		"passive_rows": rows,   # [text, "chassis"]: the chassis's own
		"effects": effects,     # {name, text, kind ("module" | "reward"), note}: what else it carries between fights
		"faces": faces,
		"face_rules": face_rules,
		"current": -1,
		"steps": Effects.steps_die(u),   # a die that steps (the Cassowary's) shows its chambers as a cylinder
		"flavour": str(c.get("flavour", "")),
		"sprite_id": u.chassis_id,
		"paint": u.paint,
		"unit": u,   # the model shows the fitted loadout (MechView3D.plan_for)
	}


## What the map needs of a foe type (bible section 5): its pack's ring (the `zone` key), its
## behaviour and caveat, its move and its shown name. Keyed by foe id, for
## Battlefield.foe_profiles; a boss's entry serves the boss unit. Defaults are the engine's when
## the content says nothing.
func pack_profiles() -> Dictionary:
	var out: Dictionary = {}
	for id in foes.keys():
		var f: Dictionary = foes[id]
		var p: Dictionary = {"zone": int(f.get("zone", 1)), "behaviour": str(f.get("behaviour", "push")), "hunts": str(f.get("hunts", "nearest"))}
		p["movespeed"] = int(f.get("movespeed", Unit.PACK_MOVE))
		p["name"] = str(f.get("name", id))
		if bool(f.get("winged", false)):
			p["winged"] = true   # its pack crosses water and crags as a flyer does (Battlefield.dress_pack)
		out[id] = p
	return out


## Unpack a battlefield pack into skirmish foes: its foe type times its strength. A boss
## pack (`is_boss`) unpacks into its commanders first, each marked `commands`: its lineup (a
## final's hero, the finale's line), or the faction's boss without one; then its escort, its
## foe type times its strength, each marked `escorts`. A pack with no foe type falls back to
## the first entry of its faction's spawn list.
func foes_for(sq: Unit) -> Array[Foe]:
	var out: Array[Foe] = []
	if sq.is_boss:
		var lead: Array = sq.lineup if not sq.lineup.is_empty() else bosses_of(sq.faction).slice(0, 1)
		for cid in lead:
			if not foes.has(str(cid)):
				continue
			var b := make_foe(str(cid))
			b.pack_id = sq.id
			b.commands = true
			scale_boss(b, sq.boss_tier)
			out.append(b)
			for part in parts_for(b):
				scale_boss(part, sq.boss_tier)
				out.append(part)
		if sq.foe_id.is_empty() and sq.members.is_empty():
			# Its escort unnamed, the tier's own units of its domain (escort_units).
			for f in escort_units(sq.faction, sq.boss_tier, sq.strength):
				f.pack_id = sq.id
				f.escorts = true
				out.append(f)
			return out
	# A pack's members, each its foe type times its strength (one type when it has no list; a
	# boss unit's members are its escort): the foes' fresh start, 30 October.
	for e in sq.member_list():
		var fid := str(e[0])
		if fid.is_empty():
			var spawn := spawn_table(sq.faction, 1)   # a pack that names no foe: the first of today's list
			if not spawn.is_empty():
				fid = str(spawn[0][0])
		if not foes.has(fid):
			continue
		for i in range(int(e[1])):
			var f := make_foe(fid)
			if is_elite(fid):
				scale_boss(f, sq.boss_tier)   # every elite stands at its battle's tier as a boss does (Ryan, 2 November)
			f.pack_id = sq.id
			f.escorts = sq.is_boss
			out.append(f)
			out.append_array(parts_for(f))
	return out


## A boss unit at its battle's tier, 0 to 2 (Ryan, 25 and 26 October: bosses scale to the tier,
## "scaling stats and upgrading the escort", while the rank and file are never inflated, "a fine
## compromise for the sake of run diversity"): its commanders' HP multiplied and their attack
## raised, a domain's boss, a final's hero and the finale's line alike, and its escort grown by
## the tier's own units. Placeholders.
const BOSS_TIERS := [
	{"hp": 1.0, "attack": 0, "escort": 0},
	{"hp": 1.25, "attack": 1, "escort": 2},
	{"hp": 1.5, "attack": 2, "escort": 4},
]


static func boss_tier(t: int) -> Dictionary:
	return BOSS_TIERS[clampi(t, 0, BOSS_TIERS.size() - 1)]


## The escort a boss unit brings at a tier beyond its own.
static func escort_at(t: int) -> int:
	return int(boss_tier(t)["escort"])


## A commander at its battle's tier: its HP and attack as the tier gives them, set as it is made,
## so the plaque, the codex and a save read them as its own. A boss whose kit is armour grows it
## by its `armour_step` a tier above one, from a lighter start (Ryan, 31 October: "just the ones
## that have it", since a tier-one team has little against armour; the Cinder Tortoise's 1, 2, 3).
func scale_boss(f: Foe, t: int) -> void:
	var s := boss_tier(t)
	f.hp_max = maxi(1, roundi(f.hp_max * float(s["hp"])))
	f.hp = f.hp_max
	f.attack += int(s["attack"])
	f.armour += f.armour_step * clampi(t, 0, BOSS_TIERS.size() - 1)


## A boss's escort from its domain's units of the tier (Ryan, 26 October: "Make sure that boss
## escorts are composed of units from the tier. I expect they will be hand tailored at some point
## though"): the foes of the domain's spawn list at the battle's tier (`t` counting 0 to 2, the
## list the tier's, since 28 October), in spawn order and round robin, n of them; never a massive
## foe, the columns being few. Empty when the domain has none.
func escort_units(faction_id: String, t: int, n: int) -> Array[Foe]:
	var out: Array[Foe] = []
	var units: Array = []
	for e in spawn_table(faction_id, t + 1):
		var fid := str(e[0])
		if not foes.has(fid) or int(foes[fid].get("size", 1)) > 1 or is_boss(fid) or units.has(fid):
			continue
		units.append(fid)
	if units.is_empty():
		return out
	for i in range(n):
		out.append(make_foe(str(units[i % units.size()])))
	return out


## A hero's promoted form (the bible's section 9: the class change, its own entry, fought at
## the finale): the entry whose `promotes` names it, or "" when it has none.
func promoted_form(hero_id: String) -> String:
	for id in foes.keys():
		if str(foes[id].get("promotes", "")) == hero_id:
			return str(id)
	return ""


## The heroes the run's start may deal a domain (its `bench`), in content order.
func bench_of(faction_id: String) -> Array:
	var out: Array = []
	for h in factions.get(faction_id, {}).get("bench", []):
		if foes.has(str(h)):
			out.append(str(h))
	return out


## Defaults come from the content in file order, never from a hardcoded id, so the ids are
## Ryan's to rename. The first chassis in the file are the starting team; the first faction
## is the one the standalone screens and the harness fight.
func default_team(count: int = 3) -> Array:
	return chassis.keys().slice(0, count)


## The maker whose city is the capital (the Council's own house, `capital` on its entry in
## chassis.json, decided 5 October: the capital hosts the Council and the Arsenal), and the
## makers who each host one of the cities around it, in file order.
func capital_maker() -> String:
	for id in makers.keys():
		if bool(makers[id].get("capital", false)):
			return str(id)
	return ""


func city_makers() -> Array:
	var out: Array = []
	for id in makers.keys():
		if not bool(makers[id].get("capital", false)):
			out.append(str(id))
	return out


## Tiers (bible section 10, the ledger, 7 October; stored since the stock pass, 22 October). A
## chassis carries its tier, 1 to 3; every component that is not locked carries its own, 0 to
## 3: 0 the basics, whose blueprints a run starts with, 1 to 3 found or brought by a bought
## chassis, and a chassis stocks only components below its own tier. A locked component has
## none (NO_TIER).
const NO_TIER := -1


func chassis_tier(chassis_id: String) -> int:
	return int(chassis.get(chassis_id, {}).get("tier", 0))


func component_tier(component_id: String) -> int:
	if is_fixed(component_id):
		return NO_TIER   # locked: powerful and unique, never a blueprint (Ryan, 9 October)
	var t = components.get(component_id, {}).get("tier", null)
	return int(t) if (t is float or t is int) else NO_TIER


## Is this component locked on some chassis (its `fixed` list)? A locked component is the
## machine's own: no hardpoint stocks it, it has no tier, and it is never a blueprint.
func is_fixed(component_id: String) -> bool:
	for id in chassis.keys():
		if chassis[id].get("fixed", []).has(component_id):
			return true
	return false


## The chassis of one tier, in content order, planned drafts included (chassis_runnable
## says which the engine can field).
func chassis_of_tier(t: int) -> Array:
	var out: Array = []
	for id in chassis.keys():
		if int(chassis[id].get("tier", 0)) == t:
			out.append(str(id))
	return out


## Can the engine field this chassis today? Not while its passive or one of its locked
## components is a planned draft (19 October): a draft is kept in content so it can be written
## ahead of its engine, but dealt it would put a plain die with a dead piece in the player's
## hands, and measured it would read the body without the kit. The tender, the campaign
## runner and the balance runner skip what this refuses.
func chassis_runnable(chassis_id: String) -> bool:
	var c: Dictionary = chassis.get(chassis_id, {})
	var p = c.get("passive")
	if p is Dictionary and str(p.get("status", "implemented")) == "planned":
		return false
	for cid in c.get("fixed", []):
		if str(components.get(cid, {}).get("status", "implemented")) == "planned":
			return false
	return true


## The blueprints a run starts with: every basic, a component of tier zero (Ryan, 7 October:
## each maker's basic defaults; the basics tier zero since the stock pass, 22 October).
func starting_blueprints() -> Array:
	var out: Array = []
	for cid in components.keys():
		if component_tier(str(cid)) == 0:
			out.append(str(cid))
	return out


func default_faction() -> String:
	return str(factions.keys()[0]) if not factions.is_empty() else ""


## The distinct foe ids in a faction's spawn list at a tier, in order: rank and file first.
func spawn_foes(faction_id: String, tier: int) -> Array:
	var out: Array = []
	for entry in spawn_table(faction_id, tier):
		if not out.has(entry[0]):
			out.append(entry[0])
	return out


## A core's parts, made to stand with it in its pack (the boss in parts, 15 October).
func parts_for(core: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	for pid in core.part_ids:
		if foes.has(pid):
			var p := make_foe(str(pid))
			p.pack_id = core.pack_id
			p.joined = true   # a part stands with its core, never one of the pack's own
			out.append(p)
	return out


## Whether a foe type is a domain's boss: the content says so in a faction's `boss`, never
## its size (the bible's tiers row, 15 October: big is an attribute, apart from boss and elite).
func is_boss(foe_id: String) -> bool:
	for fid in factions.keys():
		if bosses_of(str(fid)).has(foe_id):
			return true
	return false


## A faction's bosses, in content order (its `boss`: one foe id, or a list of them; three a
## domain once the slate lands, each battle drawing one its domain has not ended on this run:
## decided 15 October, built 22 October). Known foes only, each once.
func bosses_of(faction_id: String) -> Array[String]:
	var out: Array[String] = []
	var b = factions.get(faction_id, {}).get("boss", null)
	var ids: Array = b if b is Array else ([b] if b != null else [])
	for id in ids:
		if foes.has(str(id)) and not out.has(str(id)):
			out.append(str(id))
	return out


## A boss pack for a faction, named after its boss: `boss_id`, or its first.
func make_boss(uid: int, faction_id: String, boss_id: String = "") -> Unit:
	if boss_id.is_empty():
		var all := bosses_of(faction_id)
		boss_id = all[0] if not all.is_empty() else ""
	var boss_name := str(foes.get(boss_id, {}).get("name", "boss")).to_lower()
	return Unit.boss(uid, boss_name, Vector2i.ZERO, faction_id)


## The sizes a composition may be (the foes' fresh start, 30 October): a patrol (one or two
## front types, three to five foes, a detachment's fight), a formation (a front and a back, the
## body's fight and the unit the Fractures are counted in), an elite (the guaranteed curveball a
## Fracture spawns, led by a foe flagged `elite`) and an escort (a boss's hand-tailored escort at
## a tier; none written yet, so the tier's units stand in).
const COMPOSITION_SIZES := ["patrol", "formation", "elite", "escort"]


## A faction's compositions of a size at a tier (1 to 3, the shown number), in content order,
## each as {"id", "size", "faction", "members": [[foe_id, strength], ...]}; every size in turn
## when `size` is empty. A tier with none of a size takes the highest tier's under it, as the
## spawn lists did (the ladder's brief, D3), so a domain written for tier one fights at every
## tier. Nothing when the faction has none.
func compositions(faction_id: String, tier: int, size: String = "") -> Array:
	var out: Array = []
	var sizes: Array = [size] if not size.is_empty() else COMPOSITION_SIZES
	for sz in sizes:
		for t in range(clampi(tier, 1, 3), 0, -1):
			var found := _compositions_at(faction_id, t, str(sz))
			if not found.is_empty():
				out.append_array(found)
				break
	return out


func _compositions_at(faction_id: String, tier: int, size: String) -> Array:
	var out: Array = []
	for c in factions.get(faction_id, {}).get("compositions", []):
		if not (c is Dictionary) or str(c.get("size", "")) != size or not composition_tiers(c).has(tier):
			continue
		var members: Array = []
		for m in c.get("members", []):
			if m is Dictionary and foes.has(str(m.get("foe", ""))):
				members.append([str(m["foe"]), maxi(1, int(m.get("strength", 1)))])
		if members.is_empty():
			continue
		out.append({"id": str(c.get("id", "")), "size": size, "faction": faction_id, "members": members, "boss": str(c.get("boss", ""))})
	return out


## The tiers a composition may be dealt at, as ints (content writes them as a list; one by
## default).
static func composition_tiers(c: Dictionary) -> Array:
	var out: Array = []
	var tiers = c.get("tiers", [1])
	for t in (tiers if tiers is Array else [tiers]):
		out.append(int(t))
	return out


## A faction's elite compositions at a tier, in content order: the elites its Fractures spawn.
func elite_compositions(faction_id: String, tier: int) -> Array:
	return compositions(faction_id, tier, "elite").filter(func(c) -> bool: return not is_wandering(c))


## The chance a Fracture sends a wanderer in place of the domain's next own elite (Ryan,
## 2 November: a wanderer never waits for a domain's own to run out); a placeholder.
const WANDER_CHANCE := 1.0 / 3.0


## The wanderers at a tier: every domain's elite compositions led by a foe that wanders
## (`wanders`), each once, in content order, so one composition in one domain's list walks
## out of every rift (Gilgamesh, 31 October and 2 November).
func wandering_compositions(tier: int) -> Array:
	var out: Array = []
	var seen: Array = []
	for fid in factions.keys():
		for c in compositions(str(fid), tier, "elite"):
			if is_wandering(c) and not seen.has(str(c["id"])):
				seen.append(str(c["id"]))
				out.append(c)
	return out


## Is an elite composition a wanderer's: its lead foe wanders.
func is_wandering(c: Dictionary) -> bool:
	var members: Array = c.get("members", [])
	return not members.is_empty() and bool(foes.get(str(members[0][0]), {}).get("wanders", false))


## The elite composition a Fracture sends (Ryan, 2 November): the domain's next own not yet
## sent this battle, or a wanderer not yet sent on a `roll` (0 to 1) under WANDER_CHANCE; a
## wanderer always once the domain's own are spent, and nothing when both are. Which wanderer
## is the roll's too (3 November, the pool past one): the roll's place in its band picks among
## those not yet sent, so a resumed battle draws the same and the player never learns an order.
## An elite may come again in a later battle, never twice in one; a boss never twice in a run.
func next_elite(faction_id: String, tier: int, sent: Array, roll: float) -> Dictionary:
	var own: Array = elite_compositions(faction_id, tier).filter(func(c) -> bool: return not sent.has(str(c["id"])))
	var wanderers: Array = wandering_compositions(tier).filter(func(c) -> bool: return not sent.has(str(c["id"])))
	if own.is_empty():
		return _wanderer_at(wanderers, roll) if not wanderers.is_empty() else {}
	if not wanderers.is_empty() and roll < WANDER_CHANCE:
		return _wanderer_at(wanderers, roll / WANDER_CHANCE)
	return own[0]


## One of the wanderers by a share `t` (0 to 1) of the pool: the roll spread over those left.
static func _wanderer_at(pool: Array, t: float) -> Dictionary:
	var i := clampi(int(floor(clampf(t, 0.0, 0.999999) * pool.size())), 0, pool.size() - 1)
	return pool[i]


## An elite composition by id at a tier: the domain's own or a wanderer's, else empty.
func elite_composition(faction_id: String, tier: int, id: String) -> Dictionary:
	for c in elite_compositions(faction_id, tier) + wandering_compositions(tier):
		if str(c["id"]) == id:
			return c
	return {}


## A boss's hand-tailored escort at a tier (an `escort` composition), or empty: the tier's units
## stand in round robin (escort_units). An escort may name its `boss` (30 October: the King Gel's
## Gels, which its merge takes in); the boss's own comes first, then one that names none.
func escort_composition(faction_id: String, tier: int, boss_id: String = "") -> Dictionary:
	var found := compositions(faction_id, tier, "escort")
	for c in found:
		if not boss_id.is_empty() and str(c.get("boss", "")) == boss_id:
			return c
	for c in found:
		if str(c.get("boss", "")).is_empty():
			return c
	return {}


## Whether a foe leads an elite composition (content `elite`): a mini-boss event a Fracture
## spawns, outside the spawn lists, scaled by the tier as a boss is (the bible's tiers row).
func is_elite(foe_id: String) -> bool:
	return bool(foes.get(foe_id, {}).get("elite", false))


## A foe's menace, the one weight the Rupture meter, Anathema and salvage count a kill at (the
## foes' fresh start, 30 October): its heaviest implemented blow (damage times strikes, a breach
## one more: the engine's threat, which already orders the deployment) plus a quarter of its HP,
## rounded up; an elite's doubled. Read off the content, so no new number is written per foe.
func menace(foe_id: String) -> int:
	if _menace.has(foe_id):
		return int(_menace[foe_id])
	if not foes.has(foe_id):
		return 0
	var f := make_foe(foe_id)
	var m := f.threat() + int(ceil(float(f.hp_max) / 4.0))
	if is_elite(foe_id):
		m *= 2
	_menace[foe_id] = m
	return m


## A composition's menace: every member's times its strength.
func composition_menace(c: Dictionary) -> int:
	var m := 0
	for e in c.get("members", []):
		m += menace(str(e[0])) * int(e[1])
	return m


## The units a faction sends through the rift at a tier (1 to 3, the shown number), as
## [[foe_id, strength], ...]: derived from its compositions since 30 October (the tier's
## formations' then patrols' members, each foe once, first seen first), for the harness, the
## runners' cells and a boss's escort; the map places and sends the compositions themselves.
func spawn_table(faction_id: String, tier: int) -> Array:
	var out: Array = []
	var seen := {}
	for c in compositions(faction_id, tier, "formation") + compositions(faction_id, tier, "patrol"):
		for m in c["members"]:
			if not seen.has(m[0]):
				seen[m[0]] = true
				out.append([str(m[0]), int(m[1])])
	return out


func faction_of_foe(foe_id: String) -> String:
	return str(foes.get(foe_id, {}).get("faction", ""))


# ---------------------------------------------------------------- validation

## Every rule the content must obey. Returns a list of human-readable problems; empty is clean.
func validate() -> Array[String]:
	var errs: Array[String] = []
	errs.append_array(load_errors)
	_validate_vocabulary(errs)
	_validate_components(errs)
	_validate_chassis(errs)
	_validate_modules(errs)
	_validate_foes(errs)
	_validate_factions(errs)
	return errs


func _validate_vocabulary(errs: Array[String]) -> void:
	for id in vocabulary.keys():
		var e: Dictionary = vocabulary[id]
		_validate_design("vocabulary %s" % id, e, errs, false)   # a rule needs holes at most, no pitch (18 September)
		for key in ["category", "name", "codex", "status"]:
			if not e.has(key) or str(e[key]).is_empty():
				errs.append("vocabulary %s: missing %s" % [id, key])
		if not categories.has(e.get("category", "")):
			errs.append("vocabulary %s: unknown category %s" % [id, e.get("category", "")])
		if not VALID_STATUS.has(e.get("status", "")):
			errs.append("vocabulary %s: status must be one of %s" % [id, str(VALID_STATUS)])
	# Engine keywords and vocabulary keywords must agree in both directions.
	for k in Face.KEYWORD_NAMES.keys():
		if k == Face.Keyword.NONE:
			continue
		var name: String = Face.KEYWORD_NAMES[k]
		if not vocabulary.has(name):
			errs.append("engine keyword '%s' has no vocabulary entry" % name)
		elif vocabulary[name].get("status") != "implemented":
			errs.append("engine keyword '%s' is coded but vocabulary says %s" % [name, vocabulary[name].get("status")])
	for id in vocabulary.keys():
		var e: Dictionary = vocabulary[id]
		if e.get("category") == "keyword" and e.get("status") == "implemented":
			if Face.keyword_from_name(id) < 0 and not Foe.ATTACK_KEYWORDS.has(id):
				errs.append("vocabulary keyword '%s' is marked implemented but the engine has no such keyword" % id)
	# The map's ground words (each terrain's, and a wall by its look: BattleMap.ground_ids) and
	# the vocabulary's terrain agree in both directions, so a rename on either side fails the
	# build until the other follows.
	var grounds := BattleMap.ground_ids()
	for g in grounds:
		if not vocabulary.has(g) or vocabulary[g].get("category") != "terrain":
			errs.append("the map's ground '%s' has no terrain entry in the vocabulary" % g)
	for id in vocabulary.keys():
		if vocabulary[id].get("category") == "terrain" and vocabulary[id].get("status") == "implemented" and not grounds.has(id):
			errs.append("vocabulary terrain '%s' is no ground the map shows" % id)


## A charged form (the Swallowtail's locked pieces, 21 October): what a muster buys, its keys the
## engine reads (Face.charged_form) and nothing else.
const CHARGED_KEYS := ["muster", "status", "stacks", "rounds", "reaches_all", "not_acted", "keywords", "shield", "vents", "cleanse", "act_again"]


func _validate_charged(where: String, kind: String, cd, errs: Array[String]) -> void:
	if not (cd is Dictionary) or (cd as Dictionary).is_empty():
		errs.append("%s: charged is the form a muster buys, a dictionary of %s" % [where, ", ".join(CHARGED_KEYS)])
		return
	for key in cd.keys():
		if not CHARGED_KEYS.has(str(key)):
			errs.append("%s: charged has no '%s' (it knows %s)" % [where, key, ", ".join(CHARGED_KEYS)])
	if int(cd.get("muster", 1)) < 1:
		errs.append("%s: a charged form costs at least one muster" % where)
	if cd.has("status") and not Effects.MECH_STATUSES.has(str(cd["status"])):
		errs.append("%s: a charged status is one of the machines' (%s)" % [where, ", ".join(Effects.MECH_STATUSES)])
	if cd.has("shield") and (str(cd["shield"]) != "full" or kind != "shield"):
		errs.append("%s: a charged shield fills it (\"full\"), on a shield" % where)
	if cd.has("vents") and str(cd["vents"]) != "all":
		errs.append("%s: a charged cooling takes the heat to nothing (\"all\")" % where)
	if cd.has("act_again") and str(cd["act_again"]) != "ally":
		errs.append("%s: a charged act_again is an ally's (\"ally\")" % where)
	for k in cd.get("keywords", []):
		if Face.keyword_from_name(str(k)) <= 0:
			errs.append("%s: charged keyword '%s' is no keyword the engine runs" % [where, k])


func _validate_face(where: String, fd: Dictionary, errs: Array[String], planned: bool = false, stepped: bool = false) -> void:
	var kind := str(fd.get("kind", ""))
	if Face.kind_from_name(kind) < 0 or kind == "blank":
		errs.append("%s: bad face kind '%s'" % [where, kind])
	if kind == "attack":
		# Two reaches since 10 October (Ryan): Close (melee) is removed, and melee is a tag.
		var reach := str(fd.get("reach", ""))
		if not ["direct", "indirect"].has(reach):
			errs.append("%s: attack face needs reach direct or indirect, got '%s'" % [where, reach])
	if int(fd.get("power", 0)) < 0:
		errs.append("%s: power cannot be negative" % where)
	if int(fd.get("strikes", 1)) < 1:
		errs.append("%s: strikes must be at least 1" % where)
	if int(fd.get("strikes", 1)) > 1 and kind != "attack":
		errs.append("%s: only attacks strike more than once" % where)
	if fd.has("power_max") and int(fd["power_max"]) < int(fd.get("power", 0)):
		errs.append("%s: power_max below power" % where)
	# No crits since 10 October (bible section 5, the damage ranges row): chances live on
	# riders, so a face that still carries one is stale content.
	if fd.has("crit") or fd.has("crit_bonus"):
		errs.append("%s: there are no crits (10 October); drop crit and crit_bonus" % where)
	if (fd.has("vents_all") or fd.has("power_per_heat")) and kind != "attack":
		errs.append("%s: vents_all and power_per_heat belong to an attack" % where)
	if fd.has("power_per_heat") and not bool(fd.get("vents_all", false)):
		errs.append("%s: power_per_heat needs vents_all (the heat it adds for is the heat it fires)" % where)
	if int(fd.get("power_per_heat", 0)) < 0:
		errs.append("%s: power_per_heat cannot be negative" % where)
	if fd.has("per_heat") and (not fd.has("power_per_heat") or int(fd["per_heat"]) <= 0):
		errs.append("%s: per_heat is the heat a step of power_per_heat stands for: positive, and only beside power_per_heat" % where)
	if fd.has("power_per_missing") and (kind != "attack" or int(fd["power_per_missing"]) <= 0):
		errs.append("%s: power_per_missing is a positive number on an attack" % where)
	if fd.has("per_missing") and (not fd.has("power_per_missing") or int(fd["per_missing"]) <= 0):
		errs.append("%s: per_missing is the HP a step of power_per_missing stands for: positive, and only beside power_per_missing" % where)
	# Volatile is a cost, not a keyword (Ryan, 26 October): `volatile`, the hull a spend bites, a
	# positive number beside the heat; and a shield cost the same way (`shield_cost`), the shield
	# a spend takes first, the entry unplayable while the shield is short of it.
	if Array(fd.get("keywords", [])).has("volatile"):
		errs.append("%s: Volatile is a cost, not a keyword: volatile, a number, and nothing in keywords" % where)
	if fd.has("volatile") and int(fd.get("volatile", 0)) <= 0:
		errs.append("%s: volatile is the hull a spend bites: a positive number" % where)
	if fd.has("shield_cost") and int(fd.get("shield_cost", 0)) <= 0:
		errs.append("%s: shield_cost is the shield a spend takes first: a positive number" % where)
	# The hopper (11 October): a weapon fills it by the foes it reaches, another fires a few
	# loads a shot for a bonus each.
	if fd.has("devours") and (kind != "attack" or int(fd["devours"]) <= 0):
		errs.append("%s: devours is the stacks of Overcharged a kill gives its owner: a positive number on an attack" % where)
	if Array(fd.get("keywords", [])).has("devour"):
		errs.append("%s: devour is no keyword since 11 October: write devours: <the stacks a kill gives>" % where)
	# Burn is a numbered keyword (Ryan, 18 October): an entry says the stacks each hit leaves.
	if Array(fd.get("keywords", [])).has("burn") and int(fd.get("burn", 0)) <= 0:
		errs.append("%s: an entry with Burn says its stacks: burn, a positive number" % where)
	if fd.has("burn") and not Array(fd.get("keywords", [])).has("burn"):
		errs.append("%s: burn (the stacks) rides with the Burn keyword" % where)
	# Cryo is numbered the same way (20 October): the stacks each foe reached gains.
	if Array(fd.get("keywords", [])).has("cryo") and int(fd.get("cryo", 0)) <= 0:
		errs.append("%s: an entry with Cryo says its stacks: cryo, a positive number" % where)
	if fd.has("cryo") and not Array(fd.get("keywords", [])).has("cryo"):
		errs.append("%s: cryo (the stacks) rides with the Cryo keyword" % where)
	# And Flak (21 October): the stacks each foe hit gains.
	if Array(fd.get("keywords", [])).has("flak") and int(fd.get("flak", 0)) <= 0:
		errs.append("%s: an entry with Flak says its stacks: flak, a positive number" % where)
	if fd.has("flak") and not Array(fd.get("keywords", [])).has("flak"):
		errs.append("%s: flak (the stacks) rides with the Flak keyword" % where)
	# Area by shape, numbered (Ryan, 28 October; the half retired): a weapon's Spread, Penetrate
	# or Splash says the number each foe past its target takes (cleave, penetrate, splash); a
	# debuff's area deals nothing, so it says none. Splash is the row and the column at one
	# number, so it never rides beside Spread or Penetrate, and the two at one number are Splash.
	var kw_names := Array(fd.get("keywords", []))
	var debuff := kind == "attack" and Face.from_dict(fd).is_debuff()
	for name: String in ["cleave", "penetrate", "splash"]:
		var label: String = "Spread" if name == "cleave" else str(name).capitalize()
		if kw_names.has(name) and kind == "attack" and not debuff and int(fd.get(name, 0)) <= 0:
			errs.append("%s: a weapon with %s says what each foe past its target takes: %s, a positive number" % [where, label, name])
		if fd.has(name) and not kw_names.has(name):
			errs.append("%s: %s (the number) rides with the %s keyword" % [where, name, label])
		if fd.has(name) and debuff:
			errs.append("%s: a debuff's %s deals nothing, so it carries no number (%s)" % [where, label, name])
	if kw_names.has("splash") and (kw_names.has("cleave") or kw_names.has("penetrate")):
		errs.append("%s: Splash is the row and the column together: it never rides beside Spread or Penetrate" % where)
	# Chain (Ryan, 28 October; the kill and repeat retired): a weapon's keyword with a number, the
	# blow every other Shocked foe on the field takes; a debuff's arc would carry its riders to
	# every conductor for no blow, so a debuff carries none.
	if kw_names.has("chain") and kind == "attack" and debuff:
		errs.append("%s: Chain is a weapon's keyword, an arc of a blow; a debuff carries none" % where)
	elif kw_names.has("chain") and kind == "attack" and int(fd.get("chain", 0)) <= 0:
		errs.append("%s: Chain says the number every other Shocked foe takes: chain, a positive number" % where)
	if fd.has("chain") and not kw_names.has("chain"):
		errs.append("%s: chain (the number) rides with the Chain keyword" % where)
	if kw_names.has("cleave") and kw_names.has("penetrate") and int(fd.get("cleave", 0)) == int(fd.get("penetrate", 0)):
		errs.append("%s: Spread and Penetrate at one number are Splash: write splash" % where)
	# A reach over every foe is equipment's (the Siphon's lure-all): the foes past the target take
	# no number, so a weapon reaches wide by Spread, Penetrate or Splash instead.
	if bool(fd.get("reaches_all", false)) and kind == "attack" and not debuff:
		errs.append("%s: a reach over every foe is a debuff's; a weapon's area is Spread, Penetrate or Splash with its number" % where)
	# A gated keyword (the stock pass's engine, 22 October): keyword name to the condition it
	# lands under, a condition on the foe in hand, read through the effects' conditions. Suppress
	# alone today (the stun row's gated stuns); another keyword's gate waits for its first piece.
	if fd.has("gates"):
		var gates = fd["gates"]
		if not (gates is Dictionary) or (gates as Dictionary).is_empty():
			errs.append("%s: gates maps a keyword it carries to the condition it lands under" % where)
		else:
			for kname in gates.keys():
				var g = gates[kname]
				if str(kname) != "suppress":
					errs.append("%s: a gate rides on Suppress today (gates.%s); another keyword's gate waits for its first piece" % [where, kname])
				elif not Array(fd.get("keywords", [])).has(str(kname)):
					errs.append("%s: gates.%s gates a keyword the entry does not carry" % [where, kname])
				if not (g is Dictionary) or not ["target_status", "target_rank", "target_no_intent"].has(str(g.get("when", ""))):
					errs.append("%s: gates.%s is a condition on the foe in hand: target_status, target_rank or target_no_intent" % [where, kname])
					continue
				if str(g["when"]) == "target_status" and g.has("status") and not Effects.FOE_STATUSES.has(str(g["status"])):
					errs.append("%s: gates.%s reads a status the team puts on a foe (%s), not '%s'" % [where, kname, ", ".join(Effects.FOE_STATUSES), str(g["status"])])
				if g.has("stacks") and (int(g["stacks"]) <= 0 or not g.has("status")):
					errs.append("%s: gates.%s's stacks are a positive count of the status it names" % [where, kname])
				if str(g["when"]) == "target_rank" and not ["front", "back"].has(str(g.get("rank", ""))):
					errs.append("%s: gates.%s's target_rank needs rank, front or back" % [where, kname])
		if kind != "attack":
			errs.append("%s: gates belong to an attack, spent on a foe" % where)
	# A consumer (the Backdraft Charge's, 22 October): one blow on one foe, eating every stack of
	# a status the team puts on foes, a point more a stack (per_consumed).
	if fd.has("consumes"):
		if kind != "attack" or not Effects.FOE_STATUSES.has(str(fd["consumes"])):
			errs.append("%s: consumes names a status the team puts on a foe (%s), on an attack" % [where, ", ".join(Effects.FOE_STATUSES)])
		if int(fd.get("strikes", 1)) > 1 or bool(fd.get("reaches_all", false)):
			errs.append("%s: a consumer is one blow on each foe it strikes, each eating its own: no strikes past one or reach over every foe" % where)
	if fd.has("per_consumed") and (not fd.has("consumes") or int(fd["per_consumed"]) <= 0):
		errs.append("%s: per_consumed is the damage a stack consumed adds: positive, and only beside consumes" % where)
	# Its own fire (the Stoker's, the stock pass's landing, 22 October): an attack that sets its
	# machine Burning as it is spent, a positive number of stacks.
	if fd.has("self_burn") and (kind != "attack" or int(fd["self_burn"]) <= 0):
		errs.append("%s: self_burn is a positive number of stacks of Burning on its own machine, on an attack" % where)
	for key in ["fills_hopper", "fires_hopper"]:
		if fd.has(key) and (kind != "attack" or int(fd[key]) <= 0):
			errs.append("%s: %s is a positive number on an attack" % [where, key])
	if fd.has("fires_hopper") != fd.has("power_per_load") or (fd.has("power_per_load") and int(fd["power_per_load"]) <= 0):
		errs.append("%s: fires_hopper and a positive power_per_load go together" % where)
	# The brace (12 October): spending the entry Armours its owner until the round's end.
	if fd.has("braces") and int(fd["braces"]) <= 0:
		errs.append("%s: braces is a positive number of stacks of Armoured, an armour point each" % where)
	# Rolling again on a status (12 October, the Nemesis's fists on rage): the status it
	# spends must be one of the engine's, and Rapid already rolls again on its own.
	if fd.has("rolls_again_on"):
		if not Effects.STATUS.has(str(fd["rolls_again_on"])):
			errs.append("%s: rolls_again_on names a status, one of %s" % [where, ", ".join(Effects.STATUS.keys())])
		if Array(fd.get("keywords", [])).has("rapid"):
			errs.append("%s: a rapid entry already rolls again; rolls_again_on is for one that pays a status" % where)
	# The cooldown (Ryan, 14 October): a printed property, the rounds the entry goes dark once
	# spent, this one included. Rapid's switch-off is a cooldown of one unless the entry prints
	# its own, and a cooldown of 0 says none, which only a Rapid entry has to lift.
	var rapid := Array(fd.get("keywords", [])).has("rapid")
	if fd.has("cooldown"):
		var cd = fd["cooldown"]
		if not (cd is int or cd is float) or float(cd) < 0.0 or float(cd) != floorf(float(cd)):
			errs.append("%s: cooldown is a whole number of rounds, 0 or more" % where)
		elif int(cd) == 0 and not rapid:
			errs.append("%s: cooldown 0 lifts Rapid's switch-off, and an entry without Rapid has none to lift" % where)
	# Every Rapid piece carries a limiter (Ryan, 15 October): a cooldown, heat or Volatile, so
	# no chain is free; one that prints no cooldown pays heat or hull every spend. A piece locked
	# on a stepping die has the cylinder and its odds for its limiter (the Cassowary's Spin-Up,
	# Ryan, 19 October: a combo piece, its spin a true roll that lands on itself one time in its
	# die's size, to be spent again, the high roll he allowed; the exit, a stepping-die piece that
	# ever chains for sure gets a limiter of its own).
	if rapid and not planned and not stepped and fd.has("cooldown") and int(fd["cooldown"]) == 0 \
			and int(fd.get("heat", 0)) <= 0 and int(fd.get("volatile", 0)) <= 0 and int(fd.get("shield_cost", 0)) <= 0:
		errs.append("%s: a Rapid entry with no cooldown carries another limiter, heat, Volatile or a shield cost (the bible's Rapid row)" % where)
	# The Siphon's rules (the Whip Scorpion's, 20 October): a reach over every foe in the fight,
	# an attack's; and a heat every blow taken that round adds, any entry's.
	# On a shield or a buff it is every machine it may land on (the Swallowtail's team shield, built 21
	# October), never a vent's.
	if fd.has("reaches_all") and (not (fd["reaches_all"] is bool) or kind == "vent" or kind == "blank"):
		errs.append("%s: reaches_all (true) is an attack's reach over every foe in the fight, or a shield's or a buff's over every ally" % where)
	# The Swallowtail's locked pieces (21 October): a shield's cooling half, a buff on every ally
	# yet to act, an ally acting again, and the charged form a muster buys.
	if fd.has("vents") and (kind != "shield" or not (fd["vents"] is float or fd["vents"] is int) or int(fd["vents"]) <= 0):
		errs.append("%s: vents is a shield's cooling half: the heat it takes off the machine it shields, first, a positive number" % where)
	if (fd.has("fills_shield") or fd.has("cools_all")) and kind != "shield":
		errs.append("%s: fills_shield and cools_all are a shield's (the full reset)" % where)
	if fd.has("not_acted") and (kind != "buff" or not bool(fd.get("reaches_all", false))):
		errs.append("%s: not_acted narrows a buff reaching every ally to those yet to act" % where)
	if fd.has("act_again") and kind != "buff":
		errs.append("%s: act_again is a buff's: an ally whose die is spent acts again" % where)
	if fd.has("charged"):
		_validate_charged(where, kind, fd["charged"], errs)
	# The Musk Ox's pieces (21 October): a refund, the salvo, random targets, a reload.
	if fd.has("ammo_per_foe_hit") and (kind != "attack" or int(fd["ammo_per_foe_hit"]) <= 0):
		errs.append("%s: ammo_per_foe_hit is an attack's, a weapon's or a debuff's: the ammo back for every foe its blows reach, a positive number" % where)
	for key in ["spends_magazine", "random_targets"]:
		if fd.has(key) and (kind != "attack" or not (fd[key] is bool)):
			errs.append("%s: %s (true) is an attack's, a weapon's or a debuff's" % [where, key])
	if fd.has("reloads_ammo") and (kind == "attack" or kind == "blank" or int(fd["reloads_ammo"]) <= 0):
		errs.append("%s: reloads_ammo is a machine piece's: the ammo it adds to its forging machine, a positive number" % where)
	if fd.has("heat_per_blow") and int(fd["heat_per_blow"]) <= 0:
		errs.append("%s: heat_per_blow is the heat every blow taken this round adds: a positive number" % where)
	if fd.has("shields") and (kind != "vent" or int(fd["shields"]) <= 0):
		errs.append("%s: shields is a vent's shield half (the combined entry): the shield it gives after its vent, a positive number" % where)
	if fd.has("resets_on_kill") and (kind != "attack" or not (fd["resets_on_kill"] is bool)):
		errs.append("%s: resets_on_kill (true) is an attack's: if its spend kills, every dark entry comes back and its machine acts again" % where)
	if fd.has("pulls_mines") and (kind != "attack" or not (fd["pulls_mines"] is bool)):
		errs.append("%s: pulls_mines (true) is an attack's, a weapon's or a debuff's: every mine on the field gathers into the slot it is spent on" % where)
	if fd.has("drones") and (kind != "attack" or not (fd["drones"] is bool)):
		errs.append("%s: drones (true) is an attack's, a weapon's or a debuff's: the foe carries the Syrinx Drone" % where)
	# The spray (the Skua's Flechette Pod, built 25 October): the strikes after the first fall on
	# random foes in reach, so a spray strikes at least twice.
	if fd.has("spray") and (kind != "attack" or not (fd["spray"] is bool) or int(fd.get("strikes", 1)) < 2):
		errs.append("%s: spray (true) is an attack's of two strikes or more: each strike after the first falls on a random foe in reach" % where)
	# The spin (the Spin-Up's, 19 October): Rapid's free reroll as a true roll over every entry.
	if fd.has("spins") and (not (fd["spins"] is bool) or not rapid):
		errs.append("%s: spins (true) makes Rapid's free reroll a true spin, so it rides with Rapid" % where)
	# The Petrels' locked pieces (Ryan's go, 21 October; built 30 October): the rider on its own
	# spender (the St. Elmo's Regenerator), an ally's action bought with the team's rerolls (the
	# Immelmann Booster), a roll on the machine a buff lands on (the Reheat Uplink), and the rerolls
	# a kill brings (the Spindrift Salvo).
	if fd.has("regenerates"):
		var rg = fd["regenerates"]
		if kind != "attack" or not (rg is Dictionary) or str(rg.get("status", "")) != "regenerating" \
				or int(rg.get("shield", 0)) <= 0 or int(rg.get("rounds", 0)) <= 0:
			errs.append("%s: regenerates is an attack's rider on its own machine: {status: regenerating, shield and rounds, positive}" % where)
	if fd.has("ally_action"):
		var deal = fd["ally_action"]
		if kind != "buff" or not (deal is Dictionary) or int(deal.get("rerolls", 0)) <= 0:
			errs.append("%s: ally_action is a buff's: {rerolls}, the team's rerolls an ally's action costs, positive" % where)
		elif str(fd.get("targets", "self_ally")) == "self":
			errs.append("%s: ally_action buys an ally's action, so the buff reaches allies" % where)
		elif bool(fd.get("act_again", false)):
			errs.append("%s: ally_action prices an ally's action, act_again gives one free: one or the other" % where)
	if fd.has("rolls_target") and (kind != "buff" or not (fd["rolls_target"] is bool)):
		errs.append("%s: rolls_target (true) is a buff's: the die of the machine it lands on rolls again" % where)
	if fd.has("kill_rerolls") and (kind != "attack" or int(fd["kill_rerolls"]) <= 0):
		errs.append("%s: kill_rerolls is an attack's: the rerolls a kill brings the team, a positive number" % where)
	if kind == "buff":
		# A buff grants one of the machines' statuses: it must exist and be theirs. A planned
		# component may grant a machine status the vocabulary names but the engine lacks (the
		# Spin-Up's Spun Up, 19 October), as it may carry a planned keyword: spent, it grants
		# nothing until the engine has the status.
		var st := str(fd.get("status", ""))
		var drafted_status: bool = planned and vocabulary.has(st) and vocabulary[st].get("status") != "implemented" \
			and vocabulary[st].get("category") == "status" and str(vocabulary[st].get("design", {}).get("table", {}).get("on", "")) == "machine"
		if drafted_status:
			pass
		elif not Effects.STATUS.has(st):
			errs.append("%s: a buff needs 'status', one of %s" % [where, ", ".join(Effects.MECH_STATUSES)])
		elif not Effects.MECH_STATUSES.has(st):
			errs.append("%s: '%s' is a foe's status; a buff grants one of %s" % [where, st, ", ".join(Effects.MECH_STATUSES)])
		if int(fd.get("stacks", 1)) < 1 or int(fd.get("rounds", 1)) < 1:
			errs.append("%s: a buff's stacks and rounds are at least 1" % where)
		# Braced lasts one turn from every source (Ryan, 12 October): a status that decays
		# whole at the round's end is never granted for longer.
		if str(Effects.STATUS.get(st, {}).get("decay", "")) == "round" and int(fd.get("rounds", 1)) > 1:
			errs.append("%s: %s lasts until the round's end, so a buff grants it for one round" % [where, st])
		# A status that decays to zero on its own clock (Overcharged halving) has no duration
		# (Ryan, 18 October: "Things either decrease to zero, or are timed, not both").
		if Effects.decays_to_zero(Effects.STATUS.get(st, {})) and fd.has("rounds"):
			errs.append("%s: %s halves at the round's end on its own, so a buff grants it stacks and no rounds" % [where, st])
		# One a use spends (Spun Up, spent by the next weapon) lasts until then.
		if Effects.STATUS.get(st, {}).has("spent_by") and fd.has("rounds"):
			errs.append("%s: %s lasts until a use spends it, so a buff grants it stacks and no rounds" % [where, st])
	elif fd.has("status") or fd.has("stacks") or fd.has("rounds"):
		errs.append("%s: status, stacks and rounds belong to a buff face" % where)
	if fd.has("targets"):
		var t := Face.target_from_name(str(fd["targets"]))
		if kind == "attack":
			errs.append("%s: an attack always targets foes; 'targets' is for a shield, a vent or a buff" % where)
		elif t < 0 or t == Face.Target.FOE:
			errs.append("%s: targets must be self_ally, self or ally, got '%s'" % [where, fd["targets"]])
	var kws: Array = fd.get("keywords", [])
	if kws.size() > MAX_AUTHORED_KEYWORDS:
		errs.append("%s: %d keywords, authored cap is %d" % [where, kws.size(), MAX_AUTHORED_KEYWORDS])
	for k in kws:
		# A planned component may carry a keyword the vocabulary names but the engine lacks
		# (taunt, corrode once; Web now), and a built component may carry a planned one (the
		# Flakshot Repeater's Flak from 19 to 21 October): Face.from_dict builds the entry without that
		# keyword until it is coded, so content is written ahead of the engine either way,
		# the keyword never shown and never run. An idea-stage keyword rides only on a draft.
		var drafted: bool = vocabulary.has(str(k)) and vocabulary[str(k)].get("status") != "implemented"
		if drafted and (planned or vocabulary[str(k)].get("status") == "planned"):
			continue
		var kw := Face.keyword_from_name(str(k))
		if kw <= 0:
			errs.append("%s: unknown keyword '%s'" % [where, k])
		elif vocabulary.get(str(k), {}).get("status") != "implemented":
			errs.append("%s: keyword '%s' is not implemented yet" % [where, k])
		elif Face.ANY_KEYWORDS.has(kw):
			pass   # about the spend, not its target: any kind of component may carry it
		elif kind == "attack" and Face.SUPPORT_KEYWORDS.has(kw):
			errs.append("%s: '%s' rides on a shield or vent component, not an attack" % [where, k])
		elif kind != "attack" and not Face.SUPPORT_KEYWORDS.has(kw):
			errs.append("%s: '%s' is an attack keyword; a %s component cannot carry it" % [where, k, kind])
		elif kind != "shield" and Face.SHIELD_ONLY_KEYWORDS.has(kw):
			errs.append("%s: '%s' rides on a shield component only; a %s has nothing to pass" % [where, k, kind])


## `one_off`: the chassis's design names the rule its passive breaks as a one-off (the bible's
## section 7: a passive may break a rule, the rule bending for one machine), which lifts the
## effect cap by one: the Kite's double, its heat, its dark rounds and its tax, two lines.
func _validate_passive(where: String, p, errs: Array[String], one_off: bool = false) -> void:
	if p == null:
		return
	if not (p is Dictionary):
		errs.append("%s: passive must be an object or null" % where)
		return
	# name and description are shown (the codex prints NAME: description); effects are what
	# the engine runs. There is no rules text: the description says what it does.
	for key in ["id", "name", "description", "effects"]:
		if not p.has(key):
			errs.append("%s: passive missing %s" % [where, key])
	for key in ["rules", "fantasy"]:
		if p.has(key):
			errs.append("%s: passive has '%s'; say it in description and put design notes on the entry's design object" % [where, key])
	# A passive in the works carries "status": "planned" (like a foe action): its name and
	# description are kept, the engine ignores it, the codex does not show it, and its
	# effects are not checked, so a trigger the engine lacks does not break the build.
	var status := str(p.get("status", "implemented"))
	if not ACTION_STATUSES.has(status):
		errs.append("%s: passive status must be implemented or planned" % where)
	if status == "planned":
		return
	var effects: Array = p.get("effects", [])
	if effects.is_empty():
		errs.append("%s: passive has no effects" % where)
	var cap := MAX_PASSIVE_EFFECTS + (1 if one_off else 0)
	if effects.size() > cap:
		errs.append("%s: passive has %d effects, cap is %d (one idea per passive%s)" % [where, effects.size(), cap, "; its one-off lifts it by one" if one_off else ""])
	for eff in effects:
		var trig := str(eff.get("trigger", ""))
		if not vocabulary.has(trig) or vocabulary[trig].get("category") != "trigger":
			errs.append("%s: passive effect uses unknown trigger '%s'" % [where, trig])
		var effect := str(eff.get("effect", ""))
		if not Effects.supports(trig, effect):
			errs.append("%s: passive effect '%s' on '%s' is not implemented by the engine" % [where, effect, trig])
		if (effect == "add_stat" or effect == "multiply_stat") and not Effects.STATS.has(str(eff.get("stat", ""))):
			errs.append("%s: a stat effect needs 'stat', one of %s" % [where, ", ".join(Effects.STATS)])
		if effect == "suppress" and str(eff.get("value", "")).is_empty():
			errs.append("%s: suppress needs the id or tag it turns off as its value" % where)
		if eff.has("per_stack") and not Effects.STATUS.has(str(eff["per_stack"])):
			errs.append("%s: per_stack names no engine status ('%s')" % [where, eff["per_stack"]])
		if eff.has("per_heat") and int(eff["per_heat"]) <= 0:
			errs.append("%s: per_heat is heat per step and must be positive" % where)
		if (effect == "keep_status" or effect == "stack_status" or effect == "lay_status") and not Effects.STATUS.has(str(eff.get("value", ""))):
			errs.append("%s: %s needs an engine status as its value" % [where, effect])
		# A lay that asks for a weapon's hit (the Ambush's Vitriol, Ryan, 25 October) says so on the
		# effect and in its passive's text; any other lays on every hit, equipment's included.
		if effect == "lay_status" and eff.has("damaging") and not (eff["damaging"] is bool):
			errs.append("%s: lay_status's damaging is true or false (a weapon's hit only, said in the passive's text)" % where)
		if effect == "lay_status" and eff.has("stacks") and int(eff["stacks"]) < 1:
			errs.append("%s: lay_status lays at least one stack a hit" % where)
		if effect == "stack_status" and eff.has("cap") and int(eff["cap"]) < 1:
			errs.append("%s: stack_status's cap is the most stacks it banks, at least 1" % where)
		# The Cottonmouth's drum (19 October): every weapon and debuff fired as one shot of a flat number,
		# a reach and a heat; never keyed on reach, which reads the rewrite.
		if effect == "rewrite_weapon":
			if int(eff.get("value", 0)) <= 0 or not ["direct", "indirect"].has(str(eff.get("reach", ""))) or int(eff.get("heat", -1)) < 0:
				errs.append("%s: rewrite_weapon fires every weapon and debuff as one shot: value (its flat number, positive), reach (direct or indirect) and heat (0 or more)" % where)
			if str(eff.get("when", "")).begins_with("reach_"):
				errs.append("%s: a rewrite never keys on reach, since the reach reads the rewrite" % where)
			if eff.has("tag") and not TAGS.has(str(eff["tag"])):
				errs.append("%s: rewrite_weapon's tag '%s' is not in the working set (%s)" % [where, eff["tag"], ", ".join(TAGS)])
		# The Skua's Split-cycle Breech (25 October): every weapon and debuff strikes that many times
		# as often, a whole number of two or more.
		if effect == "split_strikes" and (not (eff.get("value") is int or eff.get("value") is float) or int(eff["value"]) < 2 or float(eff["value"]) != floorf(float(eff["value"]))):
			errs.append("%s: split_strikes divides each roll among that many strikes: a whole number, 2 or more" % where)
		if (effect == "weapon_cooldown" and int(eff.get("value", 0)) < 1) or (effect == "multiply_printed" and float(eff.get("value", 0)) <= 0.0):
			errs.append("%s: %s needs a positive value (the rounds every weapon and debuff goes dark; the multiply on the printed number)" % [where, effect])
		# The Musk Ox's Forge (21 October): its magazine, the opening load, the trickle, the heat an
		# ammo stands for, the reloads of a vent and a shield on itself.
		if effect == "forge" and (int(eff.get("value", 0)) < 1 or int(eff.get("per_heat", 0)) < 1 \
				or int(eff.get("start", 0)) < 0 or int(eff.get("per_round", 0)) < 0 or int(eff.get("vent", 0)) < 0 or int(eff.get("shield", 0)) < 0):
			errs.append("%s: forge needs value (the magazine, positive), per_heat (the heat an ammo stands for, positive), and start, per_round, vent and shield, 0 or more" % where)
		# The Swallowtail's Muster (21 October): points a charge, a cap in charges, points a kill.
		if effect == "muster" and (int(eff.get("value", 0)) < 1 or int(eff.get("cap", 0)) < 1 or int(eff.get("kill", 0)) < 0):
			errs.append("%s: muster needs value (the points a charge, positive), cap (the charges it holds, positive) and kill (the points a kill by its own guns gives, 0 or more)" % where)
		if effect == "vent_blast" and float(eff.get("value", 0)) <= 0.0:
			errs.append("%s: vent_blast is the share of the heat a vent takes off that it blasts: a positive number" % where)
		# The Petrels' passives (built 30 October): the shield paying a weapon's heat point for
		# point (the Storm Petrel's), and the most rerolls a bank carries (the Giant Petrel's).
		if effect == "burn_shield" and int(eff.get("value", 0)) != 1:
			errs.append("%s: burn_shield's value is 1: a point of shield for each point of heat" % where)
		if effect == "bank_rerolls" and int(eff.get("value", 0)) < 1:
			errs.append("%s: bank_rerolls's value is the most rerolls the bank carries, at least 1" % where)
		# The Honey Badger's Ore Hopper (31 October): the loads a foe damaged puts in and the most
		# the hopper holds; what the loads held are worth, a value for every `per` loads.
		if effect == "fill_hopper" and (int(eff.get("value", 0)) < 1 or int(eff.get("cap", 0)) < 1):
			errs.append("%s: fill_hopper needs value (the loads a foe damaged puts in, positive) and cap (the most the hopper holds, positive)" % where)
		if effect == "hopper_plate" and (int(eff.get("value", 0)) < 1 or int(eff.get("per", 1)) < 1):
			errs.append("%s: hopper_plate needs value (the armour, positive) for each per loads held (positive, 1 by default)" % where)
		if str(eff.get("when", "")) == "target_rank" and not ["front", "back"].has(str(eff.get("rank", ""))):
			errs.append("%s: target_rank needs rank, front or back" % where)
		# A reach beside the rank (the Ram Frame's and the Rangefinder's reads, 22 October) reads
		# the spend's reach, so only on an attack's own effects: a static one the reach reads would
		# read itself.
		if str(eff.get("when", "")) == "target_rank" and eff.has("reach"):
			if not ["direct", "indirect"].has(str(eff["reach"])):
				errs.append("%s: target_rank's reach is direct or indirect" % where)
			if str(eff.get("trigger", "")) != "on_attack":
				errs.append("%s: target_rank reads a reach on an attack's own effects only (on_attack)" % where)
		if effect == "add_armour_vs_rank" and not ["front", "back"].has(str(eff.get("rank", "front"))):
			errs.append("%s: add_armour_vs_rank's rank is front or back" % where)
		if effect == "seal_form" and (int(eff.get("value", 0)) <= 0 or int(eff.get("heat", 0)) < 0):
			errs.append("%s: seal_form's value is the armour the seal grants, positive, and heat what it runs hotter a turn, not negative" % where)
		if effect == "paradox" and int(eff.get("value", 0)) < 1:
			errs.append("%s: paradox's value is the count that knocks a foe out, at least 1" % where)
		if effect == "grant_keyword" and eff.has("printed") and not (eff["printed"] is bool):
			errs.append("%s: grant_keyword's printed is true or false (a grant written out, drawn as the star)" % where)
		if effect == "grant_keyword":
			var kw := str(eff.get("value", ""))
			if Face.keyword_from_name(kw) <= 0:
				errs.append("%s: grant_keyword names no engine keyword ('%s')" % [where, kw])
			elif vocabulary.get(kw, {}).get("status") != "implemented":
				errs.append("%s: grant_keyword names '%s', which is not implemented yet" % [where, kw])
			# A numbered keyword's grant may say its number (the drum's Spread 2), and an area
			# keyword's must (Ryan, 28 October); a keyword with no number takes none.
			var numbered := Face.NUMBER_FIELDS.has(Face.keyword_from_name(kw))
			if eff.has("number") and (not numbered or int(eff["number"]) <= 0):
				errs.append("%s: grant_keyword's number is a positive number for a numbered keyword (Burn, Cryo, Flak, Spread, Penetrate, Splash, Chain)" % where)
			if ["cleave", "penetrate", "splash"].has(kw) and not eff.has("number"):
				errs.append("%s: a grant of %s says what each foe past the target takes: number" % [where, "Spread" if kw == "cleave" else kw.capitalize()])
			if kw == "chain" and not eff.has("number"):
				errs.append("%s: a grant of Chain says what every other Shocked foe takes: number" % where)
		var when := str(eff.get("when", ""))
		if not Effects.supports_when(when):
			errs.append("%s: passive condition '%s' is not implemented by the engine" % [where, when])
		elif when.begins_with("tag_") and not TAGS.has(when.substr(4)):
			errs.append("%s: condition '%s' reads a tag outside the working set (%s)" % [where, when, ", ".join(TAGS)])
		if when == "attacker_status" and eff.has("status"):
			# The status named may be the engine's or one the vocabulary drafts (the Prairie
			# Dog read Flak from 19 to 21 October, before Flak was built): a drafted status never holds, so the
			# clause waits inert, and the passive stays built, so the chassis stays dealable.
			var st := str(eff["status"])
			var drafted: bool = vocabulary.has(st) and vocabulary[st].get("category") == "status" and vocabulary[st].get("status") != "implemented"
			if not Effects.STATUS.has(st) and not drafted:
				errs.append("%s: attacker_status names no status the engine or the vocabulary knows ('%s')" % [where, st])
		if trig == "static" and when.begins_with("reach_"):
			errs.append("%s: a static reach change cannot be conditioned on reach (it would chase its own tail)" % where)


## Every entry keeps its internal text under `design` (fantasy at least) and nothing
## internal at the top level, so what is shown and what is not can be told by shape alone.
func _validate_design(where: String, e: Dictionary, errs: Array[String], need_fantasy: bool = true) -> void:
	var d = e.get("design", null)
	if not (d is Dictionary):
		errs.append("%s: missing design object (internal text: fantasy, niche, ...)" % where)
	elif need_fantasy and not d.has("fantasy"):
		errs.append("%s: design has no fantasy" % where)
	for key in DESIGN_ONLY_KEYS:
		if e.has(key):
			errs.append("%s: '%s' at the top level would be shown; it belongs under design" % [where, key])
	# design.stage says whether Ryan has signed the entry off (Ryan, 26 September: nothing is
	# design-locked yet, and the flag saves the conversation): draft until he says final.
	if d is Dictionary and d.has("stage") and not ["draft", "final"].has(str(d["stage"])):
		errs.append("%s: design.stage must be draft or final" % where)


## The silhouette classes a fitted component's model wears (decided 29 September, the rule
## settled 30 September): hardpoints are gun mounts on the model, and a component with a
## shape takes the next mount in the die's order, in its own maker's metal
## (art/models/shapes/<shape>_<maker>.glb, built by tools/lowforge; models_low.SHAPES is the
## same list). "none" is for what is applied to the whole machine and shows nowhere: armour
## panels and vents take a die entry and no mount.
const SHAPES := ["barrel", "twin_barrel", "rack", "blade", "dish", "none"]
const SHAPE_NONE := "none"

## The tags a component may wear (the working set, decided 10 and 12 October; the stock pass's
## validator list, 22 October): build flavour shown in the codex, never a rule of their own. A
## module or a passive reads one through a `tag_<tag>` condition, the screen's lunge reads
## `melee`, and the Cottonmouth's drum adds `ballistic` to the shot it fires. The old internal
## filing tags (kinetic, energy, single, support and the rest) are retired; the stock pass's
## landing assigns these by each piece's fantasy.
const TAGS := ["ballistic", "missile", "beam", "plasma", "flame", "arc", "blade", "melee"]

## The sound a component's blow plays, where its shape and face are not enough to say
## (decided 2 October: content carries a label for the effects): `sound`, a word from SOUNDS
## or a list of them. A list means layers (Ryan, 2 October): the first word is the blow and
## every word after it rides on the landing, so the Gravity Knuckles say ["blunt", "plasma"],
## the mass arriving with the hot splash on it. The list is game effects, never gameplay
## properties: it is not derived from keywords or tags and does not feed them (a stretch goal:
## a modification that adds burn or shock could add its layer). Absent, the game derives one
## word: a barrel is a barrel, a twin a twin, a rack a rack, a blade a blade, a dish a
## deflector or a coil by its face, an energy barrel a laser and the Arsenal's a plasma.
## Content names only the exceptions.
const SOUNDS := ["barrel", "twin_barrel", "rack", "blade", "blunt", "laser", "plasma", "deflector", "coil"]


## The sound a component's use plays, as layers (the first the blow, each after it riding on
## the landing): its `sound` where content names one, else derived as SOUNDS says. A shield
## is a deflector and a buff a coil, whatever the mount; an attack is its shape, an energy
## barrel a laser and the Arsenal's a plasma (the flat face: no power_max above
## power); a dish that attacks (the Klaxon's lure) is a coil; an attack with no
## mount sounds by its reach. A vent, or an id content does not know, is [].
func sound_of(component_id: String) -> Array[String]:
	var out: Array[String] = []
	var c: Dictionary = components.get(component_id, {})
	if c.is_empty():
		return out
	if c.has("sound"):
		for w in (c["sound"] if c["sound"] is Array else [c["sound"]]):
			out.append(str(w))
		return out
	var face: Dictionary = c.get("face", {}) if c.get("face", null) is Dictionary else {}
	var kind := str(face.get("kind", ""))
	if kind == "shield":
		out.append("deflector")
		return out
	if kind == "buff":
		out.append("coil")
		return out
	if kind != "attack":
		return out
	var shape := str(c.get("shape", SHAPE_NONE))
	var power := int(face.get("power", 0))
	var energy := int(face.get("power_max", power)) <= power
	if shape == "barrel" and energy:
		out.append("plasma" if str(c.get("maker", "")) == "arsenal" else "laser")
	elif shape == "dish":
		out.append("coil")
	elif ["barrel", "twin_barrel", "rack", "blade"].has(shape):
		out.append(shape)
	else:
		out.append("rack" if str(face.get("reach", "direct")) == "indirect" else "barrel")
	return out


func _validate_components(errs: Array[String]) -> void:
	for id in components.keys():
		var c: Dictionary = components[id]
		var where := "component %s" % id
		for key in ["name", "codex", "flavour", "face", "shape"]:
			if not c.has(key):
				errs.append("%s: missing %s" % [where, key])
		if c.has("shape") and not SHAPES.has(str(c["shape"])):
			errs.append("%s: shape '%s' is not a silhouette class (%s)" % [where, c["shape"], ", ".join(SHAPES)])
		if c.has("sound"):
			var layers: Array = c["sound"] if c["sound"] is Array else [c["sound"]]
			if layers.is_empty():
				errs.append("%s: sound is an empty list; leave it out to derive the sound" % where)
			for k in range(layers.size()):
				var w := str(layers[k])
				if not SOUNDS.has(w):
					errs.append("%s: sound '%s' is not one the forge builds (%s)" % [where, w, ", ".join(SOUNDS)])
				elif layers.find(w) != k:
					errs.append("%s: sound lists '%s' twice" % [where, w])
		for key in ["hardpoints", "slots", "faces"]:
			if c.has(key):
				errs.append("%s: '%s' is gone; a component is exactly one entry, its 'face'" % [where, key])
		var tags = c.get("tags", [])
		if not (tags is Array):
			errs.append("%s: tags must be a list" % where)
		else:
			for k in range((tags as Array).size()):
				var t := str(tags[k])
				if not TAGS.has(t):
					errs.append("%s: tag '%s' is not in the working set (%s)" % [where, t, ", ".join(TAGS)])
				elif (tags as Array).find(tags[k]) != k:
					errs.append("%s: tags list '%s' twice" % [where, t])
		_validate_design(where, c, errs)
		# A component the engine cannot run yet carries "status": "planned" (like a passive or a
		# foe action): kept, its face checked for shape, its unbuilt keywords allowed.
		var status := str(c.get("status", "implemented"))
		if not ACTION_STATUSES.has(status):
			errs.append("%s: status must be implemented or planned" % where)
		if c.get("face", null) is Dictionary:
			_validate_face("%s face" % where, c["face"], errs, status == "planned", _locked_on_stepping_die(str(id)))
		else:
			errs.append("%s: face must be an object" % where)
		if c.has("maker") and not makers.has(c["maker"]):
			errs.append("%s: unknown maker %s" % [where, c["maker"]])
		_validate_passive(where, c.get("passive", null), errs)


## Whether a component is locked on a chassis whose die steps (the Cassowary's): its Rapid's
## limiter is the cylinder and its odds, so it needs none of its own (the bible's Rapid row).
func _locked_on_stepping_die(cid: String) -> bool:
	for id in chassis.keys():
		var ch: Dictionary = chassis[id]
		if not Array(ch.get("fixed", [])).has(cid):
			continue
		var p = ch.get("passive", null)
		if p is Dictionary and str(p.get("status", "implemented")) == "implemented":
			for eff in p.get("effects", []):
				if str(eff.get("effect", "")) == "step_die":
					return true
	return false


## Modules (built 9 October from the modules row's working rules): stats are any number of
## stat lines; the text is at most one passive's worth, checked as a passive; every module
## carries a tier, and the capital's maker has no tier one. The archetypes are a guide and
## never checked (Ryan: enforcing them only restricts the design space).
func _validate_modules(errs: Array[String]) -> void:
	var capital := capital_maker()
	for id in modules.keys():
		var m: Dictionary = modules[id]
		var where := "module %s" % id
		for key in ["name", "maker", "tier", "codex", "flavour", "stats", "text"]:
			if not m.has(key):
				errs.append("%s: missing %s" % [where, key])
		_validate_design(where, m, errs)
		if m.has("maker") and not makers.has(m["maker"]):
			errs.append("%s: unknown maker %s" % [where, m["maker"]])
		var t = m.get("tier", null)
		if not (t is float or t is int) or int(t) < 1 or int(t) > 3:
			errs.append("%s: tier must be 1, 2 or 3" % where)
		elif str(m.get("maker", "")) == capital and int(t) == 1:
			errs.append("%s: the capital's maker has no tier-one module" % where)
		var stats = m.get("stats", {})
		if not (stats is Dictionary):
			errs.append("%s: stats must be an object of stat lines" % where)
			stats = {}
		for k in stats.keys():
			if not Effects.STATS.has(str(k)):
				errs.append("%s: stat '%s' is not one of %s" % [where, k, ", ".join(Effects.STATS)])
			var v = stats[k]
			if not (v is float or v is int) or int(v) == 0 or float(v) != floorf(float(v)):
				errs.append("%s: stat %s must be a whole number other than zero" % [where, k])
		var text = m.get("text", null)
		if text != null and not (text is Dictionary):
			errs.append("%s: text must be an object or null" % where)
		elif text is Dictionary:
			for key in ["name", "id", "rules", "fantasy"]:
				if text.has(key):
					errs.append("%s: text has '%s'; a module's text is its description and effects" % [where, key])
			var p: Dictionary = text.duplicate()
			p["id"] = str(id)
			p["name"] = str(m.get("name", id))
			_validate_passive(where + " text", p, errs)
		if (stats as Dictionary).is_empty() and not (text is Dictionary):
			errs.append("%s: a module needs stats, a text or both" % where)


func _validate_chassis(errs: Array[String]) -> void:
	var capitals := 0
	for id in makers.keys():
		if bool(makers[id].get("capital", false)):
			capitals += 1
	if not makers.is_empty() and capitals != 1:
		errs.append("makers: exactly one maker sits at the capital (\"capital\": true); %d do" % capitals)
	# Sponsorship (the bible's row): a maker names the measure the run tallies for it, one the
	# engine keeps (SPONSORSHIP_MEASURES), or none.
	for id in makers.keys():
		if makers[id].has("sponsorship") and not SPONSORSHIP_MEASURES.has(str(makers[id]["sponsorship"])):
			errs.append("maker %s: sponsorship names a measure the run tallies, one of %s" % [id, ", ".join(SPONSORSHIP_MEASURES)])
	# Tiers (7 October; stored since the stock pass, 22 October): every chassis 1 to 3, and the
	# capital's maker fields no tier one; every component that is not locked stores its tier, 0
	# to 3, and a locked one none; the capital's maker makes no basics (tier zero); a chassis
	# stocks only components below its own tier.
	var capital := capital_maker()
	var stocked_ids := {}
	var fixed_ids := {}
	for id in chassis.keys():
		var t = chassis[id].get("tier", null)
		if not (t is float or t is int) or int(t) < 1 or int(t) > 3:
			errs.append("chassis %s: tier must be 1, 2 or 3" % id)
		elif str(chassis[id].get("maker", "")) == capital and int(t) == 1:
			errs.append("chassis %s: the capital's maker fields no tier one" % id)
		for cid in chassis[id].get("loadout", []):
			stocked_ids[cid] = true
		for cid in chassis[id].get("fixed", []):
			fixed_ids[cid] = true
	for cid in fixed_ids.keys():
		# Locked components are powerful and unique (Ryan, 9 October): never a blueprint, so
		# no hardpoint stocks one and none carries a tier.
		if stocked_ids.has(cid):
			errs.append("component %s: locked on a chassis, so no hardpoint stocks it (a locked component is never a blueprint)" % cid)
		if components.get(cid, {}).has("tier"):
			errs.append("component %s: locked on a chassis, so it carries no tier" % cid)
	for cid in components.keys():
		var c: Dictionary = components[cid]
		if fixed_ids.has(cid):
			continue
		var ct = c.get("tier", null)
		if not (ct is float or ct is int) or float(ct) != floorf(float(ct)) or int(ct) < 0 or int(ct) > 3:
			errs.append("component %s: tier must be 0, 1, 2 or 3 (0 the basics, whose blueprints a run starts with)" % cid)
		elif not capital.is_empty() and str(c.get("maker", "")) == capital and int(ct) == 0:
			errs.append("component %s: the capital's maker makes no basics (tier zero)" % cid)
	for id in chassis.keys():
		var own := int(chassis[id].get("tier", 0))
		for cid in chassis[id].get("loadout", []):
			var ct := component_tier(str(cid))
			if components.has(cid) and not fixed_ids.has(cid) and ct >= own:
				errs.append("chassis %s: stocks %s at tier %d, and a chassis stocks only below its own tier (%d)" % [id, cid, ct, own])
	for id in chassis.keys():
		var c: Dictionary = chassis[id]
		var where := "chassis %s" % id
		# designation: the maker's long name on the spec plate (Ryan, 26 September: every
		# chassis carries one; the bible's section 7 row says the shape per maker).
		for key in ["name", "designation", "codex", "flavour", "hull", "shield", "armour", "movespeed", "hardpoints", "loadout", "recharge_field", "size", "module_slots"]:
			if not c.has(key):
				errs.append("%s: missing %s" % [where, key])
		# Module slots are a number of the chassis, never bought (Ryan: two as a rule, three on
		# the Clydesdale as its identifying feature; the runner may move the baseline).
		if c.has("module_slots") and (int(c["module_slots"]) < 0 or int(c["module_slots"]) > MAX_MODULE_SLOTS):
			errs.append("%s: module_slots must be 0 to %d" % [where, MAX_MODULE_SLOTS])
		if c.has("designation") and str(c["designation"]).strip_edges().is_empty():
			errs.append("%s: designation is empty" % where)
		_validate_name_clash(where, str(id), c, errs)
		if c.has("recharge_combat"):
			errs.append("%s: recharge_combat is gone; in a fight shield comes only from components (a passive may say otherwise)" % where)
		if int(c.get("recharge_field", 0)) < 0 or int(c.get("armour", 0)) < 0 or int(c.get("cooling", 0)) < 0:
			errs.append("%s: armour, the field recharge rate and cooling cannot be negative" % where)
		_validate_design(where, c, errs)
		var hp := int(c.get("hardpoints", 0))
		if c.has("filler"):
			errs.append("%s: filler is gone; an empty hardpoint is empty, fit a component or leave it" % where)
		var fixed: Array = c.get("fixed", [])
		for cid in fixed:
			if not components.has(cid):
				errs.append("%s: unknown fixed component %s" % [where, cid])
		var die_size: int = fixed.size() + hp
		if die_size < MIN_DIE or die_size > MAX_DIE:
			errs.append("%s: die of %d (%d fixed + %d hardpoints), must be %d to %d" % [where, die_size, fixed.size(), hp, MIN_DIE, MAX_DIE])
		var loadout: Array = c.get("loadout", [])
		for cid in loadout:
			if not components.has(cid):
				errs.append("%s: unknown component %s" % [where, cid])
			if fixed.has(cid):
				errs.append("%s: %s is fixed and cannot also be in the loadout" % [where, cid])
		if loadout.size() > hp:
			errs.append("%s: loadout fits %d components into %d hardpoints" % [where, loadout.size(), hp])
		var ways := 0
		for t in c.get("traits", []):
			if not vocabulary.has(str(t)) or vocabulary[str(t)].get("category") != "trait":
				errs.append("%s: unknown trait %s" % [where, t])
			if BattleMap.WAYS.has(str(t)):
				ways += 1
		if ways != 1:
			errs.append("%s: a chassis has exactly one way of moving (%s)" % [where, ", ".join(BattleMap.WAYS)])
		if c.has("movespeed") and (int(c["movespeed"]) < 1 or int(c["movespeed"]) > MAX_MOVE):
			errs.append("%s: movespeed is in hexes, 1 to %d" % [where, MAX_MOVE])
		if c.has("size") and not SIZES.has(str(c["size"])):
			errs.append("%s: size is one of %s" % [where, ", ".join(SIZES)])
		if c.has("maker") and not makers.has(c["maker"]):
			errs.append("%s: unknown maker %s" % [where, c["maker"]])
		if c.has("passives"):
			errs.append("%s: use 'passive' (zero or one), not 'passives'" % where)
		var one_off := str(c.get("design", {}).get("one_off", "")) if c.get("design", {}) is Dictionary else ""
		_validate_passive(where, c.get("passive", null), errs, not one_off.is_empty())


## A chassis nickname (or id) that is a machine's name in BattleTech, Heavy Gear, Warhammer
## 40k or Halo is refused (Ryan, 28 September; content/reserved_names.json). The match is
## exact after normalising, so "Timber Wolf" and "timber_wolf" both trip and "Grey Wolf" does
## not. To keep a clashing name knowingly, the entry records why under design.name_clash; the
## fact stays in the content, the build goes green.
func _validate_name_clash(where: String, id: String, c: Dictionary, errs: Array[String]) -> void:
	var hits := {}
	for candidate in [str(c.get("name", "")), id]:
		var key := normalise_name(candidate)
		if not key.is_empty() and reserved_names.has(key):
			hits[reserved_names[key]] = true
	if hits.is_empty():
		return
	var d = c.get("design", null)
	var waiver := str(d.get("name_clash", "")).strip_edges() if d is Dictionary else ""
	if waiver.is_empty():
		errs.append("%s: '%s' clashes with %s; rename it, or record why it stays under design.name_clash" % [where, c.get("name", id), ", ".join(hits.keys())])


const ACTION_KINDS := ["attack", "defend", "buff", "debuff"]
const ACTION_STATUSES := ["implemented", "planned"]


## A foe's roster of actions: at least one implemented attack (its blow, and the number the
## player reads), and any defend, buff or debuff actions the engine runs, each picked by
## weight in its turn; an action the engine cannot run yet is marked planned.
func _validate_actions(where: String, f: Dictionary, errs: Array[String]) -> void:
	var acts = f.get("actions", [])
	if not (acts is Array):
		errs.append("%s: actions must be a list" % where)
		return
	var implemented_attacks := 0
	for a in acts:
		if not (a is Dictionary):
			errs.append("%s: each action must be an object" % where)
			continue
		var aw := "%s action %s" % [where, str(a.get("id", "?"))]
		for key in ["id", "name", "kind", "text", "status"]:
			if not a.has(key):
				errs.append("%s: missing %s" % [aw, key])
		if not ACTION_KINDS.has(str(a.get("kind", ""))):
			errs.append("%s: kind must be one of %s" % [aw, ", ".join(ACTION_KINDS)])
		if not ACTION_STATUSES.has(str(a.get("status", ""))):
			errs.append("%s: status must be implemented or planned" % aw)
		# A move's own sense and its condition (2 October), checked whatever its status.
		if a.has("aim") and not Foe.AIMS.has(str(a["aim"])):
			errs.append("%s: aim must be one of %s, got '%s'" % [aw, ", ".join(Foe.AIMS), str(a["aim"])])
		if a.has("when"):
			var whens := Foe.whens_of(a)
			if whens.is_empty():
				errs.append("%s: when must be a word or a list of words from %s" % [aw, ", ".join(Foe.WHENS)])
			for w in whens:
				if not Foe.WHENS.has(str(w)):
					errs.append("%s: unknown condition '%s' (moves know %s)" % [aw, str(w), ", ".join(Foe.WHENS)])
		if a.has("swarm") and (str(a.get("kind", "")) != "attack" or int(a["swarm"]) < 0):
			errs.append("%s: swarm is an attack's, so much more per kin on the field, never negative" % aw)
		# A special used once a fight (30 October: the Vampire Lord readies its rise once).
		if a.has("once") and (not (a["once"] is bool) or str(a.get("kind", "attack")) == "attack"):
			errs.append("%s: once is a special's, true or left out" % aw)
		# An opener (3 November, the Nob's Bellow): the foe's first move of the fight, so a
		# special used once; a blow or a repeatable move opens nothing.
		if a.has("opens") and (not (a["opens"] is bool) or not bool(a.get("once", false))):
			errs.append("%s: opens is a special's used once (once true), true or left out" % aw)
		# A grudge (30 October): an attack a point heavier for every foe the team has killed this fight.
		if a.has("per_kill") and (str(a.get("kind", "attack")) != "attack" or int(a["per_kill"]) < 1):
			errs.append("%s: per_kill is an attack's, its number a foe the team has killed this fight: 1 or more" % aw)
		# A condition reading a fallen part (30 October) means something only on a core with parts.
		if Foe.whens_of(a).has("part_fallen") and (f.get("parts", []) as Array).is_empty():
			errs.append("%s: part_fallen reads its parts, and this foe has none" % aw)
		# A follow-up (30 October): `then` names another move of the same foe, which comes only the
		# round after this one lands; one deep, so the move it names names none of its own.
		if a.has("then"):
			var named := str(a["then"])
			var found: Dictionary = {}
			for o in acts:
				if o is Dictionary and str(o.get("id", "")) == named:
					found = o
			if named == str(a.get("id", "")):
				errs.append("%s: then names the move itself" % aw)
			elif found.is_empty():
				errs.append("%s: then names '%s', which is no move of this foe" % [aw, named])
			elif found.has("then"):
				errs.append("%s: then names '%s', which names a follow-up of its own; follow-ups are one deep" % [aw, named])
			elif str(found.get("status", "")) != str(a.get("status", "")):
				errs.append("%s: then names '%s', whose status differs; a move and its follow-up land together" % [aw, named])
		# A borrowed swing (30 October): an attack whose number is what a steal took, so it comes
		# only as the follow-up of a blow that steals.
		if a.has("power"):
			if str(a["power"]) != "held" or str(a.get("kind", "attack")) != "attack":
				errs.append("%s: power is an attack's, and the one word it knows is held" % aw)
			else:
				var stolen_by := false
				for o in acts:
					if o is Dictionary and str(o.get("then", "")) == str(a.get("id", "")) and Array(o.get("keywords", [])).has("steal"):
						stolen_by = true
				if not stolen_by:
					errs.append("%s: a borrowed swing (power held) is the follow-up of a blow that steals; name it in that blow's then" % aw)
		if str(a.get("status", "")) == "implemented":
			if str(a.get("kind", "")) != "attack":
				# A defend, buff or debuff names an effect the engine runs and the fields it reads.
				var kind := str(a.get("kind", ""))
				var effect := str(a.get("effect", ""))
				if not Foe.ACTION_EFFECTS.get(kind, []).has(effect):
					errs.append("%s: a %s action's effect must be one of %s, got '%s'" % [aw, kind, ", ".join(Foe.ACTION_EFFECTS.get(kind, [])), effect])
				# A priming and a regrowth say their number; a Barrier and a Ward say none (28 October).
				if (effect == "prime" or effect == "regenerate" or effect == "enrage" or effect == "golden") and int(a.get("value", 0)) < 1:
					errs.append("%s: %s says its number: value, 1 or more" % [aw, effect])
				# A golden rage (4 November) lasts the rounds it says, 1 to 5, three unsaid.
				if effect == "golden" and a.has("rounds") and (int(a["rounds"]) < 1 or int(a["rounds"]) > 5):
					errs.append("%s: golden's rounds are the rounds the rage lasts, 1 to 5" % aw)
				if (effect == "barrier" or effect == "ward_all") and a.has("value"):
					errs.append("%s: %s takes no value" % [aw, effect])
				# A cleanse (28 October) takes every mark the team laid, so it says no number, and
				# its condition, if any, is the one it needs.
				if effect == "cleanse":
					if a.has("value"):
						errs.append("%s: a cleanse takes every mark the team laid: no value" % aw)
					for w in Foe.whens_of(a):
						if str(w) != "ally_marked":
							errs.append("%s: a cleanse's condition, if any, is ally_marked, got '%s'" % [aw, str(w)])
				if effect == "summon" and not foes.has(str(a.get("foe", ""))):
					errs.append("%s: summon names unknown foe '%s'" % [aw, str(a.get("foe", ""))])
				# A merge (30 October) names the kinds it takes in, one id or a list, and the lift a
				# kind gives its next move.
				if effect == "merge":
					var kinds := Foe.kinds_named(a)
					if kinds.is_empty():
						errs.append("%s: a merge names the kinds it takes in: foe, an id or a list" % aw)
					for k in kinds:
						if not foes.has(str(k)):
							errs.append("%s: merge names unknown foe '%s'" % [aw, str(k)])
					if int(a.get("value", 0)) < 1:
						errs.append("%s: a merge says how much harder its next move hits a foe taken in: value, 1 or more" % aw)
				# A brace is armour in stacks of Armoured (16 October), a point a stack since 18
				# October, so its value is its stacks: a positive number.
				if effect == "brace" or effect == "brace_all":
					var v := int(a.get("value", 0))
					if v <= 0:
						errs.append("%s: a brace's value is the armour it grants, in stacks of Armoured: a positive number, got %d" % [aw, v])
				if int(a.get("value", 0)) < 0 or int(a.get("count", 1)) < 1 or int(a.get("weight", 1)) < 1:
					errs.append("%s: value cannot be negative; count and weight are at least 1" % aw)
				# What an effect lays, it says: the stacks, or the rerolls a theft takes (24 October).
				if ["burn", "scorch_all", "corrupt_all", "drain_rerolls"].has(effect) and int(a.get("value", 0)) <= 0:
					errs.append("%s: %s says what it lays: value, a positive number" % [aw, effect])
				# A swallow (30 October) says the rounds its machine is out, 1 to 3: hard control on
				# the team, held short.
				if effect == "swallow" and (int(a.get("value", 0)) < 1 or int(a.get("value", 0)) > 3):
					errs.append("%s: a swallow's value is the rounds its machine is out, 1 to 3" % aw)
				for key in ["factor", "strikes", "keywords", "countdown"] + Foe.NUMBERED_RIDERS:
					if a.has(key):
						errs.append("%s: '%s' belongs to an attack action" % [aw, key])
			else:
				implemented_attacks += 1
				# An attack scales the foe's base attack: factor, not a value of its own, so the
				# base number stays the player's read of how hard it hits.
				if a.has("value"):
					errs.append("%s: 'value' is gone; an attack scales the base attack with 'factor' (default 1.0)" % aw)
				if float(a.get("factor", 1.0)) <= 0.0:
					errs.append("%s: factor must be positive" % aw)
				if int(a.get("strikes", 1)) < 1:
					errs.append("%s: strikes must be at least 1" % aw)
				if int(a.get("weight", 1)) < 1:
					errs.append("%s: weight must be at least 1" % aw)
				if a.has("breach"):
					errs.append("%s: breach is a tag, put it in keywords" % aw)
				if a.has("countdown") and (int(a["countdown"]) < 1 or int(a["countdown"]) > 5):
					errs.append("%s: countdown is the rounds a move gathers before it lands, 1 to 5" % aw)
				for k in a.get("keywords", []):
					if Foe.SPECIALS_ONLY.has(str(k)):
						errs.append("%s: '%s' is a special, never a rider on a blow (28 October)" % [aw, k])
					elif not Foe.ATTACK_KEYWORDS.has(str(k)):
						errs.append("%s: unknown attack keyword '%s' (foe attacks know %s)" % [aw, k, ", ".join(Foe.ATTACK_KEYWORDS)])
				# A rider that lays stacks says how many (24 October, as the player's Burn N does).
				for k in Foe.NUMBERED_RIDERS:
					var carried := Array(a.get("keywords", [])).has(k)
					if carried and int(a.get(k, 0)) <= 0:
						errs.append("%s: a %s rider says its stacks: %s, a positive number" % [aw, k, k])
					if a.has(k) and not carried:
						errs.append("%s: %s (the stacks) rides with the %s keyword" % [aw, k, k])
	if implemented_attacks < 1:
		errs.append("%s: needs at least one implemented attack action" % where)


func _validate_foes(errs: Array[String]) -> void:
	for id in foes.keys():
		var f: Dictionary = foes[id]
		var where := "foe %s" % id
		for key in ["name", "codex", "flavour", "actions", "hp", "attack", "rank"]:
			if not f.has(key):
				errs.append("%s: missing %s" % [where, key])
		_validate_design(where, f, errs)
		if int(f.get("hp", 0)) <= 0:
			errs.append("%s: hp must be positive" % where)
		if int(f.get("armour", 0)) < 0:
			errs.append("%s: armour cannot be negative" % where)
		if f.has("armour_step"):
			# A boss whose kit is armour grows it a tier (31 October): only a foe that scales in
			# place with the tier, a domain's boss, one of the party or an elite (2 November),
			# carries a step.
			if not (f["armour_step"] is float or f["armour_step"] is int) or int(f["armour_step"]) < 1:
				errs.append("%s: armour_step must be a whole number of at least 1" % where)
			elif not (is_boss(str(id)) or bool(f.get("hero", false)) or f.has("promotes") or bool(f.get("elite", false))):
				errs.append("%s: armour_step only on a foe that scales with the tier (a boss, a hero, an elite)" % where)
		if f.has("aim") and not Foe.AIMS.has(str(f["aim"])):
			errs.append("%s: aim must be one of %s, got '%s'" % [where, ", ".join(Foe.AIMS), str(f["aim"])])
		_validate_actions(where, f, errs)
		if not ["front", "back"].has(str(f.get("rank", ""))):
			errs.append("%s: rank must be front or back" % where)
		var sz := int(f.get("size", 1))
		if sz < 1 or sz > 2:
			errs.append("%s: size must be 1 or 2 (massive)" % where)
		if sz == 2 and str(f.get("rank", "")) == "back":
			errs.append("%s: a massive foe fills both ranks and must be rank front" % where)
		if f.has("tier") and (int(f["tier"]) < 1 or int(f["tier"]) > 3):
			errs.append("%s: tier must be 1 to 3" % where)
		if f.has("injures"):
			errs.append("%s: 'injures' is gone; component injuries are a global rule" % where)
		if f.has("stun_resist"):
			errs.append("%s: no foe resists a suppress by nature (10 October); drop stun_resist" % where)
		if f.has("zone") and (int(f["zone"]) < 1 or int(f["zone"]) > 4):
			errs.append("%s: zone is the pack's ring in hexes, 1 to 4" % where)
		if f.has("behaviour") and not ["push", "hunt"].has(str(f["behaviour"])):
			errs.append("%s: behaviour is push or hunt" % where)
		if f.has("hunts") and not ["nearest", "weakest", "strongest", "slowest", "fastest"].has(str(f["hunts"])):
			errs.append("%s: hunts is nearest, weakest, strongest, slowest or fastest" % where)
		if f.has("hunts") and str(f.get("behaviour", "push")) != "hunt":
			errs.append("%s: hunts is a hunter's caveat; set behaviour to hunt" % where)
		# A hunter pounces (Ryan, 29 October: "a minimum range of 2 instead of 1 (wolfs pounce,
		# etc.)"; "If it's overbearing then we send the engage range back down").
		if str(f.get("behaviour", "push")) == "hunt" and int(f.get("zone", 1)) < HUNTER_RING:
			errs.append("%s: a hunter's ring is %d at least; it pounces" % [where, HUNTER_RING])
		if f.has("movespeed") and (int(f["movespeed"]) < 1 or int(f["movespeed"]) > MAX_MOVE):
			errs.append("%s: movespeed is in hexes, 1 to %d" % [where, MAX_MOVE])
		# A hero only ever commands the boss unit, which patrols a hex a turn and never hunts
		# (Ryan, 28 October, of the Thief's move: "it's a boss so it doesn't need it").
		if bool(f.get("hero", false)):
			for key in ["movespeed", "behaviour", "hunts"]:
				if f.has(key):
					errs.append("%s: a hero only commands the boss unit, which patrols a hex a turn; drop %s" % [where, key])
		if f.has("elite") and not (f["elite"] is bool):
			errs.append("%s: elite is true or false" % where)
		if bool(f.get("elite", false)) and bool(f.get("hero", false)):
			errs.append("%s: a hero is a domain's final, never an elite" % where)
		if f.has("wanders") and not (f["wanders"] is bool):
			errs.append("%s: wanders is true or false" % where)
		elif bool(f.get("wanders", false)) and not bool(f.get("elite", false)):
			errs.append("%s: only an elite wanders (31 October: the one elite any domain fields, scaled by the tier)" % where)
		if f.has("winged") and not (f["winged"] is bool):
			errs.append("%s: winged is true or false" % where)
		for key in ["strikes", "breach"]:
			if f.has(key):
				errs.append("%s: '%s' belongs on an attack action, not the foe" % [where, key])
		if f.has("faction") and not factions.has(f["faction"]):
			errs.append("%s: unknown faction %s" % [where, f["faction"]])
		if f.has("hero") and bool(f["hero"]) and sz != 1:
			errs.append("%s: a hero is human-sized (size 1); the massive thing it commands is its own foe" % where)
		if f.has("promotes"):
			# A hero's promoted form (the bible's section 9): its own entry, massive, in its hero's
			# domain, one to a hero, never a hero itself (a hero is human-sized) nor a boss.
			var base := str(f["promotes"])
			if not foes.has(base) or not bool(foes[base].get("hero", false)):
				errs.append("%s: promotes names %s, which is no hero" % [where, base])
			elif str(foes[base].get("faction", "")) != str(f.get("faction", "")):
				errs.append("%s: a promoted form stands in its hero's domain (%s)" % [where, str(foes[base].get("faction", ""))])
			if sz != 2:
				errs.append("%s: a promoted form is massive (size 2)" % where)
			if bool(f.get("hero", false)):
				errs.append("%s: a promoted form is no hero itself; promotes says whose it is" % where)
			if is_boss(str(id)):
				errs.append("%s: a promoted form is a hero's, never a domain's boss" % where)
			for other in foes.keys():
				if str(other) < str(id) and str(foes[other].get("promotes", "")) == base:
					errs.append("%s: %s already promotes %s; a hero has one promoted form" % [where, str(other), base])
		if f.has("parts"):
			# A boss in parts (15 October): known foes, one deep, with a guard the engine runs.
			if not (f["parts"] is Array) or Array(f["parts"]).is_empty():
				errs.append("%s: parts is a list of foe ids" % where)
			else:
				for pid in f["parts"]:
					if not foes.has(str(pid)):
						errs.append("%s: part names unknown foe %s" % [where, str(pid)])
					elif foes[str(pid)].has("parts"):
						errs.append("%s: part %s has parts of its own; parts are one deep" % [where, str(pid)])
		if f.has("guard") and not ["all", "any"].has(str(f["guard"])):
			errs.append("%s: guard is all (no damage while every part stands) or any (while one does)" % where)
		if (f.has("guard") or f.has("regrow_parts")) and not f.has("parts"):
			errs.append("%s: guard and regrow_parts belong to a foe with parts" % where)
		if f.has("regrow_parts") and (int(f["regrow_parts"]) < 1 or int(f["regrow_parts"]) > 5):
			errs.append("%s: regrow_parts is the rounds a fallen part takes to grow back, 1 to 5" % where)
		if f.has("on_death"):
			# A split (the Gel): destroyed, it summons; what it summons never splits again.
			var od = f["on_death"]
			if od is Dictionary and od.has("blow"):
				# A last act (15 October): an attack's shape, landed the moment the foe falls.
				var b = od["blow"]
				if not (b is Dictionary) or str(b.get("name", "")).is_empty() or float(b.get("factor", 1.0)) <= 0.0 or int(b.get("strikes", 1)) < 1:
					errs.append("%s: on_death blow is an attack: a name, a positive factor, strikes at least 1" % where)
				elif b is Dictionary:
					for k in b.get("keywords", []):
						if Foe.SPECIALS_ONLY.has(str(k)):
							errs.append("%s: on_death blow: '%s' is a special, never a rider, and a last act never purges (28 October)" % [where, k])
						elif not Foe.ATTACK_KEYWORDS.has(str(k)):
							errs.append("%s: on_death blow: unknown attack keyword '%s'" % [where, k])
			if od is Dictionary and od.has("blow") and not od.has("summon"):
				pass
			elif not (od is Dictionary) or not foes.has(str(od.get("summon", ""))):
				errs.append("%s: on_death must name a known foe to summon" % where)
			elif int(od.get("count", 1)) < 1:
				errs.append("%s: on_death count is at least 1" % where)
			elif foes[str(od["summon"])].has("on_death"):
				errs.append("%s: on_death summons %s, which splits too; a split goes one deep" % [where, od["summon"]])
			elif bool(od.get("pair", false)) and (int(od.get("count", 1)) != 2 or int(foes[str(od["summon"])].get("size", 1)) >= 2):
				errs.append("%s: on_death pair stands two halves in one slot: count 2, and no massive half" % where)


func _validate_factions(errs: Array[String]) -> void:
	for id in factions.keys():
		var f: Dictionary = factions[id]
		var where := "faction %s" % id
		for key in ["name", "compositions"]:
			if not f.has(key):
				errs.append("%s: missing %s" % [where, key])
		_validate_design(where, f, errs)
		for old in ["pattern", "elite", "injury"]:
			if f.has(old):
				errs.append("%s: '%s' is gone; use compositions and boss" % [where, old])
		if f.has("spawn"):
			errs.append("%s: spawn is gone (30 October); the lists by tier are derived from compositions" % where)
		# A domain never sets or leans the map's shape (Ryan, 30 October: "That's just less
		# variety and more subtle balance to tweak"): a battle draws its shape by its seed.
		if f.has("map_kind"):
			errs.append("%s: map_kind is gone; a domain names no map shape, a battle's seed draws it" % where)
		# The compositions (the foes' fresh start, 30 October): each a size, the tiers that may
		# deal it and its members; a tier-one formation and patrol at least, so every tier fights.
		var comps = f.get("compositions", [])
		if not (comps is Array) or (comps as Array).is_empty():
			errs.append("%s: compositions is a list of {id, size, tiers, members}" % where)
			comps = []
		var comp_ids := {}
		var tier_one := {"formation": false, "patrol": false}
		for c in comps:
			if not (c is Dictionary):
				errs.append("%s: each composition is an object" % where)
				continue
			var cw := "%s composition %s" % [where, str(c.get("id", "?"))]
			for key in ["id", "size", "members"]:
				if not c.has(key):
					errs.append("%s: missing %s" % [cw, key])
			if comp_ids.has(str(c.get("id", ""))):
				errs.append("%s: its id comes twice" % cw)
			comp_ids[str(c.get("id", ""))] = true
			var size := str(c.get("size", ""))
			if not COMPOSITION_SIZES.has(size):
				errs.append("%s: size is one of %s, got '%s'" % [cw, ", ".join(COMPOSITION_SIZES), size])
			var tiers = c.get("tiers", [1])
			if not (tiers is Array) or (tiers as Array).is_empty():
				errs.append("%s: tiers is a list of the tiers that may deal it, 1 to 3" % cw)
			else:
				for t in tiers:
					if int(t) < 1 or int(t) > 3:
						errs.append("%s: tiers are 1 to 3, got %s" % [cw, str(t)])
			var members = c.get("members", [])
			if not (members is Array) or (members as Array).is_empty():
				errs.append("%s: members is a list of {foe, strength}, one at least" % cw)
				members = []
			var first := true
			for m in members:
				if not (m is Dictionary) or not foes.has(str(m.get("foe", ""))):
					errs.append("%s: member names unknown foe %s" % [cw, str(m)])
					first = false
					continue
				var fid := str(m["foe"])
				if int(m.get("strength", 0)) < 1:
					errs.append("%s: member %s needs a strength of at least 1" % [cw, fid])
				if bool(foes[fid].get("hero", false)):
					errs.append("%s: hero %s is never in a composition; it is dealt from the bench" % [cw, fid])
				# An elite composition is led by its elite; an elite stands in no other (the bible's
				# tiers row: outside the usual spawn list).
				if size == "elite" and first and not bool(foes[fid].get("elite", false)):
					errs.append("%s: an elite composition's first member is its elite, flagged elite; %s is none" % [cw, fid])
				if size != "elite" and bool(foes[fid].get("elite", false)):
					errs.append("%s: %s is an elite and stands only in an elite composition" % [cw, fid])
				first = false
			if c.has("boss"):
				# An escort written for one boss (30 October); no other composition names one.
				var named_boss := str(c["boss"])
				var listed: Array = f.get("boss", []) if f.get("boss", []) is Array else [f.get("boss", "")]
				if size != "escort":
					errs.append("%s: only an escort names its boss" % cw)
				elif not listed.has(named_boss):
					errs.append("%s: boss '%s' is none of this domain's bosses" % [cw, named_boss])
			if tier_one.has(size) and composition_tiers(c).has(1):
				tier_one[size] = true
		for size in ["formation", "patrol"]:
			if not tier_one[size] and not comps.is_empty():
				errs.append("%s: needs a tier-one %s, so every tier fights" % [where, size])
		if f.has("boss"):
			# One foe id, or a list of them (three a domain once the slate lands), each once.
			var ids: Array = f["boss"] if f["boss"] is Array else [f["boss"]]
			if ids.is_empty():
				errs.append("%s: boss names no foe; leave it out for a domain without one" % where)
			var seen: Array = []
			for bid in ids:
				if not (bid is String):
					errs.append("%s: boss is a foe id or a list of them" % where)
				elif seen.has(bid):
					errs.append("%s: boss %s comes twice" % [where, bid])
				elif not foes.has(bid):
					errs.append("%s: boss names unknown foe %s" % [where, bid])
				elif bool(foes[bid].get("hero", false)):
					errs.append("%s: boss %s is a hero; a hero is a domain's final, dealt from the bench" % [where, bid])
				seen.append(bid)
		# The bench (decided 9 October): the heroes the campaign's start may deal to this domain.
		var bench: Array = f.get("bench", [])
		if not (f.get("bench", []) is Array):
			errs.append("%s: bench is a list of hero ids" % where)
		for h in bench:
			if not foes.has(str(h)):
				errs.append("%s: bench names unknown foe %s" % [where, str(h)])
			elif not bool(foes[str(h)].get("hero", false)):
				errs.append("%s: bench entry %s is not a hero" % [where, str(h)])
			elif promoted_form(str(h)).is_empty():
				# The finale fields the dealt party promoted (the bible's section 9: a job costs
				# two drawings), so a hero the run may deal needs its class change.
				errs.append("%s: bench hero %s has no promoted form (an entry whose promotes names it)" % [where, str(h)])

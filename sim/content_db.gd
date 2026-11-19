class_name ContentDB
extends RefCounted

## Loads content/*.json, validates it against the design rules, and builds runtime objects.
## Content is authored fantasy-first in JSON; the validator is the vetting pass that runs
## in the test suite, so a concept that breaks a rule fails the build.

const DIR := "res://content/"

# Design knobs. Loosen or tighten here; the validator and the bible should agree.
const MAX_AUTHORED_KEYWORDS := 3    # per authored face; upgrades may exceed this at runtime
## The machine buffs a spend may lay on its own machine (Face.self_statuses; the Storm Petrel's
## Hardlight Pulse and its branches, a Ward on itself in its Defence direction since 18 November;
## the Macaque's offhand, its Beam Buckler's Barrier, Ward and Parry, Ryan, 19 November).
const SELF_GRANTS := ["hardened", "ward", "charged", "supercooled", "primed", "overcharged", "braced", "regenerating", "barrier", "parry"]
const MAX_MOVE := 6                 # a move in hexes, chassis or foe, is 1 to this (a placeholder bound, 28 October)
## The caveats a hunting composition may name (`hunts`): whom its pack locks. The fastest left on
## 16 November with nothing hunting by it (the rule of 12 November).
const HUNT_CAVEATS := ["nearest", "weakest", "strongest", "slowest"]
const MIN_DIE := 4                  # a d3 was the first Kite's one-off (21 October to 11 November); no machine rolls one today
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
## The caches a battle's field holds (content/loot.json, built 7 November): kind id -> entry,
## and the file's rules (per_battle, rift_gap, wall_gap, behind_shell).
var loot: Dictionary = {}
var loot_rules: Dictionary = {}
var makers: Dictionary = {}
var categories: Array = []
## Machine names from the properties our designs sit nearest (content/reserved_names.json:
## every BattleTech 'Mech, Heavy Gear, Warhammer 40k, Halo), keyed by their normalised form
## (see normalise_name) with "Name (a BattleTech 'Mech)" for the message. A chassis nickname
## or id that lands on one fails validation (Ryan, 28 September: ours or a homage, never a copy).
var reserved_names: Dictionary = {}
var _weight: Dictionary = {}      # foe id -> its weight by its own numbers, read once (weight)
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
	var lf := _read(dir + "loot.json")
	loot = _index(lf)
	loot_rules = {"per_battle": int(lf.get("per_battle", 0)), "rift_gap": int(lf.get("rift_gap", 3)), "wall_gap": int(lf.get("wall_gap", 2)), "behind_shell": int(lf.get("behind_shell", 0))}
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
## `branch_picks` are its upgrades' picks along its chassis's branches (branch_error), none for a
## machine at its chassis's own tier.
func make_mech(chassis_id: String, uid: int = 0, at: Vector2i = Vector2i.ZERO, loadout = null, fitted_modules: Array = [], branch_picks: Array = []) -> Unit:
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
	fit_branches(u, branch_picks)
	# Modules, as many as the chassis has slots; then the machine starts whole on the numbers
	# they made.
	for mid in fitted_modules.slice(0, int(c.get("module_slots", 0))):
		fit_module(u, str(mid))
	u.hull = u.hull_max
	u.shield = u.shield_max
	return u


## A machine's picks along its chassis's branches (the bible's tiers row: an upgrade's branch is a
## pick of one from two that tweaks a locked piece, two directions each two steps deep, Ryan's
## shape; the Storm Petrel the first to carry them, 17 November): the direction ids in the order
## taken, a direction's first pick its first step and its second its deeper one, so [a, a] is
## specialized and [a, b] or [b, a] mixed, the deeper step only ever offered to a machine that took
## the first. A tier one picks twice, a tier two once and a tier three never (3 less its tier). ""
## when the picks are legal, else what is wrong.
func branch_error(chassis_id: String, picks: Array) -> String:
	if picks.is_empty():
		return ""
	var c: Dictionary = chassis.get(chassis_id, {})
	var dirs: Array = c.get("branches", []) if c.get("branches", []) is Array else []
	if dirs.is_empty():
		return "%s has no branches" % chassis_id
	var most := maxi(0, 3 - int(c.get("tier", 1)))
	if picks.size() > most:
		return "a tier %d machine picks %d time%s, not %d" % [int(c.get("tier", 1)), most, "" if most == 1 else "s", picks.size()]
	var taken := {}
	for p in picks:
		var d := _direction(c, str(p))
		if d.is_empty():
			return "%s has no direction %s" % [chassis_id, str(p)]
		taken[str(p)] = int(taken.get(str(p), 0)) + 1
		if int(taken[str(p)]) > (d.get("steps", []) as Array).size():
			return "the %s direction is %d step%s deep" % [str(p), (d.get("steps", []) as Array).size(), "" if (d.get("steps", []) as Array).size() == 1 else "s"]
	return ""


## The steps a machine's legal picks have taken, in order: each {direction, step (0 its first),
## name (the direction's, with the step's numeral: Defence I), description, effects}.
func branch_steps(chassis_id: String, picks: Array) -> Array:
	var out: Array = []
	if not branch_error(chassis_id, picks).is_empty():
		return out
	var c: Dictionary = chassis.get(chassis_id, {})
	var taken := {}
	for p in picks:
		var d := _direction(c, str(p))
		var at := int(taken.get(str(p), 0))
		taken[str(p)] = at + 1
		var step: Dictionary = d["steps"][at]
		out.append({"direction": str(p), "step": at, "name": "%s %s" % [str(d.get("name", p)), "I" if at == 0 else "II"],
			"description": str(step.get("description", "")), "effects": step.get("effects", [])})
	return out


## Every set of picks a machine of this chassis may hold, the empty one first, then each in the
## order a machine reaches it: what the harness offers.
func branch_builds(chassis_id: String) -> Array:
	var c: Dictionary = chassis.get(chassis_id, {})
	var dirs: Array = c.get("branches", []) if c.get("branches", []) is Array else []
	var out: Array = [[]]
	var most := maxi(0, 3 - int(c.get("tier", 1)))
	var frontier: Array = [[]]
	for i in range(most):
		var next: Array = []
		for picks in frontier:
			for d in dirs:
				var more: Array = (picks as Array) + [str(d.get("id", ""))]
				if branch_error(chassis_id, more).is_empty() and not _has_build(out, more):
					next.append(more)
					out.append(more)
		frontier = next
	return out


## Is this build already listed, its picks in any order (a mixed build is one build either way)?
static func _has_build(builds: Array, picks: Array) -> bool:
	var want := picks.duplicate()
	want.sort()
	for b in builds:
		var have: Array = (b as Array).duplicate()
		have.sort()
		if have == want:
			return true
	return false


func _direction(c: Dictionary, id: String) -> Dictionary:
	for d in c.get("branches", []):
		if d is Dictionary and str(d.get("id", "")) == id:
			return d
	return {}


## A machine's picks laid on it: each step's effects one passive sourced "branch", tied to the
## piece it tweaks, read through the pipeline like a module's (never written to a stat or a
## component), so a destroyed piece takes its tweaks with it. Illegal picks lay nothing.
func fit_branches(u: Unit, picks: Array) -> void:
	for s in branch_steps(u.chassis_id, picks):
		# The piece the step rides: the one every effect names, so a destroyed piece takes its
		# tweaks with it; a step on the passive, or on more than one piece, rides the passive, each
		# effect still scoped to its own piece (a destroyed piece's entry is blank, and takes none).
		var on := {}
		for eff in s["effects"]:
			if eff is Dictionary:
				on[str(eff.get("entry", ""))] = true
		var entry: String = str(on.keys()[0]) if on.size() == 1 else ""
		u.grant_passive({"id": "branch:%s:%s:%d" % [u.chassis_id, s["direction"], int(s["step"]) + 1], "name": s["name"],
			"description": s["description"], "effects": (s["effects"] as Array).duplicate(true)}, "branch", entry)
		u.branches.append(str(s["direction"]))


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
## effects (none while the text is planned). A rule its text writes on its machine's entries
## (the Overrun Gearing's spill) carries the text's own line, so the star reads the rule and
## never the stat lines.
func module_passive(module_id: String) -> Dictionary:
	var m: Dictionary = modules.get(module_id, {})
	var effects: Array = []
	var stats: Dictionary = m.get("stats", {})
	for k in stats.keys():
		effects.append({"trigger": "static", "effect": "add_stat", "stat": str(k), "value": int(stats[k])})
	var text = m.get("text", null)
	if text is Dictionary and str(text.get("status", "implemented")) == "implemented":
		for e in text.get("effects", []):
			var eff: Dictionary = (e as Dictionary).duplicate(true)
			if str(eff.get("effect", "")) == "spillover":
				eff["line"] = str(text.get("description", ""))
			effects.append(eff)
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
const STAT_WORDS := {"hull": "hull", "shield": "shield", "heat": "heat max", "armour": "armour", "move": "move", "cooling": "cooling", "shield_regen": "shield regen"}


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
	f.resist = int(d.get("resist", -1))   # its stun resist (2 November): content's, else by its size
	f.armour_step = maxi(0, int(d.get("armour_step", 0)))
	f.rage = maxi(0, int(d.get("rage", 0)))   # its own from the fight's start (the Goblin Nob's, Ryan, 8 November: "It's not innate? ... unbelievably incorrect")
	f.drains = bool(d.get("drains", false))   # its own too: every blow of its regrows what it took from the hull (the Vampire Lord's, 16 November)
	# What never lands on it (17 November, on Ryan's yes to the bench's rows): a Suppress or a
	# Disrupt, always (true) or while the move it names gathers.
	var im = d.get("immune", null)
	if im is Dictionary:
		for k in (im as Dictionary).keys():
			f.immune[str(k)] = true if im[k] is bool else str(im[k])
	f.wanders = bool(d.get("wanders", false))
	f.hero = bool(d.get("hero", false)) or d.has("promotes")   # one of the party: a hero, or its promoted form
	f.boss = is_boss(foe_id)
	f.elite = is_elite(foe_id)   # a mini-boss: its stun resist is a boss's (3 November)
	# A boss in parts (15 October): its parts' types, its guard and how its parts grow back.
	f.part_ids = Array(d.get("parts", [])).map(func(x): return str(x))
	f.guard = str(d.get("guard", ""))
	f.regrow_parts = maxi(0, int(d.get("regrow_parts", 0)))
	var od = d.get("on_death", {})
	if od is Dictionary:
		# A split (the Gel) and a fall, either or both: a last act's blow (15 October, the
		# Gargantuan King's Meteor) or one special in its place, each with what it does also (16
		# November: a fall is a short list of steps, as a move is).
		var made := {}
		if od.has("summon"):
			made["summon"] = str(od["summon"])
			made["count"] = maxi(1, int(od.get("count", 1)))
			if bool(od.get("pair", false)):
				made["pair"] = true   # its two halves stand as a pair in its slot (the Gel's, 26 October)
		if od.get("blow", null) is Dictionary:
			made["blow"] = Foe.death_blow_from(od["blow"])
		elif od.get("act", null) is Dictionary:
			made["act"] = Foe.fall_act_from(od["act"])
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
			if bool(a.get("aloft", false)):
				act["aloft"] = true   # its foe is Aloft while the move gathers: no die may be dropped on it (the Roc's Stoop, 16 November)
			if a.has("power"):
				act["power"] = str(a["power"])   # a borrowed swing: its number is a status of the foe's own, what it took (30 October; Appropriated since 16 November)
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
			if a.has("rounds"):
				act["rounds"] = int(a["rounds"])   # a golden rage's rounds
		# What the move does also (16 November: a move is a short list of steps), each a special's
		# effect with the fields it reads, speaking under the move's name.
		var also := Foe.also_from(a.get("also", null), str(act["name"]))
		if not also.is_empty():
			act["also"] = also
		# What its blow does before it lands (18 November), an attack's alone.
		if kind == "attack":
			var before := Foe.also_from(a.get("before", null), str(act["name"]))
			if not before.is_empty():
				act["before"] = before
		# The move's own word for whom it goes for (17 November) and its condition (2 October),
		# when it has them.
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
	if not f.fall().is_empty():
		moves.append(f.fall())
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
	# A chassis has no shield regen and no cooling of its own (the reboot), so each shows only
	# where the loadout grants it.
	var regen := (" (+%d A ROUND)" % int(now["shield_regen"])) if int(now["shield_regen"]) != 0 else ""
	var cools := (" (-%d A TURN)" % int(now["cooling"])) if int(now["cooling"]) != 0 else ""
	var stats := "SHIELD %d%s // HULL %d // ARMOUR %d // HEAT %d%s // MOVE %d // %d HARDPOINTS // D%d" % [
		now["shield"], regen, now["hull"], now["armour"], now["heat"], cools, now["move"], u.hardpoints, u.die.size() if u.die != null else 0]
	var items: Array = [["shield max", stat_parts(int(u.base["shield"]), now["shield"])]]
	if int(now["shield_regen"]) != 0:
		items.append(["shield regen", stat_parts(0, now["shield_regen"], "+")])
	items.append_array([["hull max", stat_parts(int(u.base["hull"]), now["hull"])], ["armour", stat_parts(int(u.base["armour"]), now["armour"])],
		["heat max", stat_parts(int(u.base["heat"]), now["heat"])]])
	if int(now["cooling"]) != 0:
		items.append(["cooling", stat_parts(0, now["cooling"])])
	items.append(["move", stat_parts(int(u.base["move"]), now["move"])])
	# The die as built: the codex shows each component at its own numbers (26 October).
	var faces: Array = []
	var face_rules: Array = []   # each entry's component passive, its lines on the component's row
	if u.die != null:
		for f in u.die.faces:
			faces.append(Effects.upgraded_face(u, f))   # at its own numbers, as its steps make it (the Aile Blitzer)
			face_rules.append([])
	# The chassis passive is the passive row; a component's passive rides on its row; everything
	# else the machine carries between fights (a module, a battle's reward, a status the battle
	# keeps) is an active effect, listed under them (Ryan, 26 October: "non-chip effects granted
	# not as part of the passive, such as modules, auras, battle effects from fracture rewards").
	# Each row says where it comes from, and the codex colours it by that.
	var rows: Array = []
	var stepped: Array = []   # the steps on the passive, listed after it in the order taken
	var effects: Array = []
	var kept := {}   # a kept status's row by its id, its stacks summed
	var piece_steps: Array = []   # each piece's steps, listed after its own lines in the order taken
	for i in range(faces.size()):
		piece_steps.append([])
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
		elif d[2] == "branch" and str(d[6]).is_empty():
			# A step on the passive, or on more than one piece (the Macaque's offhand and its Aile
			# Booster): under the passive, after it.
			stepped.push_front(["%s: %s" % [head, d[1]], "chassis"])   # the latest is read first: so I stands before II
		elif d[2] == "branch":
			# An upgrade's step (the Storm Petrel's branches, 17 November): on the row of the piece
			# it tweaks, as that piece's own passive rides there, after it, I before II.
			for i in range(faces.size()):
				if faces[i].component == str(d[6]):
					(piece_steps[i] as Array).push_front("%s: %s" % [str(d[0]), d[1]])
		elif d[2] == "module":
			effects.append({"name": head, "text": str(d[1]), "kind": "module", "note": "MODULE"})
		elif Effects.is_status(str(d[5])):
			# A status the battle keeps (the Ammit's Essence; its Empowered from 16 October until its
			# rework of 12 November): its count, kept for the battle, one row a status whatever
			# granted each stack.
			# A count says itself at one too (the Ammit's Essence), bare; a buff's stacks from two.
			var counted := Effects.is_counted(str(d[5]))
			if kept.has(str(d[5])):
				var row: Dictionary = kept[str(d[5])]
				row["stacks"] = int(row["stacks"]) + int(d[4])
				row["name"] = head + ((" %d" % int(row["stacks"])) if counted else (" ×%d" % int(row["stacks"]) if int(row["stacks"]) > 1 else ""))
				continue
			var kept_row := {"name": head + ((" %d" % int(d[4])) if counted else (" ×%d" % int(d[4]) if int(d[4]) > 1 else "")), "text": str(d[1]), "kind": "reward", "note": "KEPT FOR THE BATTLE", "stacks": int(d[4])}
			kept[str(d[5])] = kept_row
			effects.append(kept_row)
		else:
			effects.append({"name": head, "text": str(d[1]), "kind": "reward", "note": "REWARD"})
	rows.append_array(stepped)
	for i in range(faces.size()):
		(face_rules[i] as Array).append_array(piece_steps[i])
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
		"stat_items": items,
		"actions": "",
		"passive": "\n".join(passive_lines),
		"passive_rows": rows,   # [text, "chassis"]: the chassis's own
		"effects": effects,     # {name, text, kind ("module" | "reward"), note}: what else it carries between fights
		"faces": faces,
		"face_steps": faces.map(func(f: Face) -> int: return Effects.steps_on(u, f)),   # the branch's steps taken on each piece, a chevron each beside its place
		"face_rules": face_rules,
		"current": -1,
		"steps": Effects.steps_die(u),   # a die that steps (the Cassowary's) shows its chambers as a cylinder
		"stowed": Effects.stowed_entries(u, u.die),   # a folded die's battery down (the Clydesdale's): its rows dimmed
		"flavour": str(c.get("flavour", "")),
		"sprite_id": u.chassis_id,
		"paint": u.paint,
		"unit": u,   # the model shows the fitted loadout (MechView3D.plan_for)
	}


## What the map needs of a foe type (bible section 5): its move, its wings and its shown name.
## Keyed by foe id, for Battlefield.foe_profiles; a boss's entry serves the boss unit. Defaults
## are the engine's when the content says nothing. Whether a pack hunts is its composition's
## (`hunts`, Battlefield.pack_of), never a foe's, and no foe carries a ring (a hunter catches at Unit.ENGAGE_RANGE).
func pack_profiles() -> Dictionary:
	var out: Dictionary = {}
	for id in foes.keys():
		var f: Dictionary = foes[id]
		var p: Dictionary = {}
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
## raised, a domain's boss, a final's hero and the finale's line alike. Its escort is the tier's
## curated composition (an `escort` naming it), never grown by count (Ryan, 7 November: "packs
## don't auto scale, so why would a bosses? Should be treated the same way"). Placeholders: the
## HP step a tenth and a quarter since 10 November (a quarter and a half before), a guess with
## the elites' and bosses' numbers for the refit pass's model, on which the old step walled a
## stock four at tiers two and three (docs/measurements.md).
const BOSS_TIERS := [
	{"hp": 1.0, "attack": 0},
	{"hp": 1.1, "attack": 1},
	{"hp": 1.25, "attack": 2},
]


static func boss_tier(t: int) -> Dictionary:
	return BOSS_TIERS[clampi(t, 0, BOSS_TIERS.size() - 1)]


## A fight's slots: four columns of two ranks, the ranks holding (a front foe never stands in the
## back), a massive foe a whole column. A pack is what they hold (no reinforcement inside a
## fight, 6 November): content is validated to fit, so the engine never trims a pack.
const GRID_COLUMNS := 4


## Foes as a fight's slots hold them, in the order given (commanders and their parts first): a
## foe its rank has no room for is left out. The harness's alone, for the fight it builds by hand,
## so that fight is one the game could deal; content is validated to fit instead.
static func fit_grid(list: Array[Foe]) -> Array[Foe]:
	var out: Array[Foe] = []
	var massive := 0
	var front := 0
	var back := 0
	for f in list:
		var m := massive + (1 if f.is_massive() else 0)
		var fr := front + (1 if not f.is_massive() and not f.prefers_back else 0)
		var bk := back + (1 if not f.is_massive() and f.prefers_back else 0)
		if m + fr > GRID_COLUMNS or m + bk > GRID_COLUMNS:
			continue
		massive = m
		front = fr
		back = bk
		out.append(f)
	return out


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
## chassis, and a chassis stocks components up to its own tier, a tier three to tier two
## (stock_tier). A locked component has
## none (NO_TIER).
const NO_TIER := -1


func chassis_tier(chassis_id: String) -> int:
	return int(chassis.get(chassis_id, {}).get("tier", 0))


## The highest tier of component a chassis of tier `own` stocks (the bible's tiers row): its own
## at tiers one and two, and tier two for a tier three, so a tier-three component is only ever
## found.
static func stock_tier(own: int) -> int:
	return mini(own, 2)


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
## hands, and measured it would read the body without the kit. Nor while the chassis itself is
## back in design ("status": "planned" on its entry, the refit pass's four since 10 November):
## its kit still runs and its tests still build it, but nothing deals it until its session hands
## it back. The tender, the harness, the campaign runner and the balance runner skip what this
## refuses.
func chassis_runnable(chassis_id: String) -> bool:
	var c: Dictionary = chassis.get(chassis_id, {})
	if str(c.get("status", "implemented")) == "planned":
		return false
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
		if component_tier(str(cid)) == 0 and component_dealt(str(cid)):
			out.append(str(cid))
	return out


## Is this component in the game's hands today? Not while it is a planned draft: one the
## engine cannot run yet, or one the refit pass retired or sent back to design (the shields and
## vents, undealt since 10 November). A draft is no blueprint, no loot and no basic.
func component_dealt(component_id: String) -> bool:
	return components.has(component_id) and str(components[component_id].get("status", "implemented")) != "planned"


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


## A composition's threat rating, the machines it is intended for (the long wall brief 3.7; Ryan,
## 6 November: "The one thing we should do is show the threat rating of a formation on the map.
## For how many units it's intended for"; "a 'true' 4 should be reserved for elites and bosses,
## with formations a 3"): its own `squad` where content writes one, else by its size.
const SQUAD_BY_SIZE := {"patrol": 1, "formation": 3, "elite": 4, "escort": 4}
const SQUAD_DEFAULT := 3   # a pack of no composition (the harness's composed side)


static func squad_of(c: Dictionary) -> int:
	if c.has("squad"):
		return clampi(int(c["squad"]), 1, 4)
	return int(SQUAD_BY_SIZE.get(str(c.get("size", "")), SQUAD_DEFAULT))


## A composition's grid (one declaration since 8 November, the long wall brief's layout and
## members made one): front and back, four cells each, null or a foe id the content has; a
## front-rank foe in a front cell and a back-rank foe in a back cell (the ranks hold), a massive
## foe in a front cell with the back cell behind it null; no hero; an elite only in an elite
## composition, whose lead is one; a core's parts each in a cell of its own, once a core, and a
## part never without its core; a lead that stands in the grid. Nothing beside the grid counts a
## foe, so the pack is what it holds.
func _validate_grid(cw: String, c: Dictionary, size: String, errs: Array) -> void:
	for r in ["front", "back"]:
		if not (c.get(r, null) is Array) or (c[r] as Array).size() != 4:
			errs.append("%s: %s is four cells, left to right, each null or a foe id" % [cw, r])
			return
	var named := {}
	var cores := {}
	for r in ["front", "back"]:
		for col in range(4):
			var cell = c[r][col]
			if cell == null:
				continue
			if not (cell is String):
				errs.append("%s: %s cell %d is null or a foe id" % [cw, r, col])
				continue
			var fid := str(cell)
			if not foes.has(fid):
				errs.append("%s: %s cell %d names unknown foe %s" % [cw, r, col, fid])
				continue
			named[fid] = int(named.get(fid, 0)) + 1
			var f: Dictionary = foes[fid]
			if bool(f.get("hero", false)):
				errs.append("%s: hero %s is never in a composition; it is dealt from the bench" % [cw, fid])
			if size != "elite" and bool(f.get("elite", false)):
				errs.append("%s: %s is an elite and stands only in an elite composition" % [cw, fid])
			if int(f.get("size", 1)) >= 2:
				if r == "back":
					errs.append("%s: back cell %d names the massive %s, which stands in a front cell" % [cw, col, fid])
				elif c["back"][col] != null:
					errs.append("%s: front cell %d holds the massive %s, so the back cell behind it is null" % [cw, col, fid])
			elif str(f.get("rank", "front")) == "back" and r == "front":
				errs.append("%s: front cell %d names %s, which stands in the back rank" % [cw, col, fid])
			elif str(f.get("rank", "front")) != "back" and r == "back":
				errs.append("%s: back cell %d names %s, which stands in the front rank" % [cw, col, fid])
			for pid in f.get("parts", []):
				cores[str(pid)] = int(cores.get(str(pid), 0)) + 1
	for pid in cores.keys():
		if int(named.get(pid, 0)) != int(cores[pid]):
			errs.append("%s: %s has %d core%s in the grid and %d cell%s; a core's parts each take a cell of their own, once a core" % [cw, pid, int(cores[pid]), "" if int(cores[pid]) == 1 else "s", int(named.get(pid, 0)), "" if int(named.get(pid, 0)) == 1 else "s"])
	for fid in named.keys():
		if not cores.has(fid) and is_part(fid):
			errs.append("%s: %s is a part and stands only beside its core" % [cw, fid])
	if named.is_empty():
		errs.append("%s: front and back name nobody" % cw)
	var lead := str(c.get("lead", ""))
	if c.has("lead") and not named.has(lead):
		errs.append("%s: lead '%s' stands nowhere in its grid" % [cw, lead])
	if size == "elite":
		var members := grid_members(c)
		if not members.is_empty() and not bool(foes.get(str(members[0][0]), {}).get("elite", false)):
			errs.append("%s: an elite composition is led by its elite; %s is none" % [cw, str(members[0][0])])


## Whether a foe is some core's part (content `parts`).
func is_part(foe_id: String) -> bool:
	for id in foes.keys():
		if foes[id].get("parts", []).has(foe_id):
			return true
	return false


## A faction's compositions of a size at a tier (1 to 3, the shown number), in content order,
## each as {"id", "size", "faction", "members": [[foe_id, strength], ...] read off its grid, "layout": its eight cells, "lead", and "squad", "ramp" and "hunts" where content writes them}; every size in turn
## when `size` is empty. A tier with none of a size has none: nothing stands in (Ryan, 8 November:
## "we've either defined the escort or we haven't"; the content tests want every size at every tier), as the
## spawn lists did (the ladder's brief, D3), so a domain written for tier one fights at every
## tier. Nothing when the faction has none.
func compositions(faction_id: String, tier: int, size: String = "", ramp: int = -1) -> Array:
	var out: Array = []
	var sizes: Array = [size] if not size.is_empty() else COMPOSITION_SIZES
	for sz in sizes:
		out.append_array(_compositions_at(faction_id, clampi(tier, 1, 3), str(sz), ramp))
	return out


func _compositions_at(faction_id: String, tier: int, size: String, ramp: int = -1) -> Array:
	var out: Array = []
	for c in factions.get(faction_id, {}).get("compositions", []):
		if not (c is Dictionary) or str(c.get("size", "")) != size or not composition_tiers(c).has(tier):
			continue
		if ramp >= 0 and not ramp_holds(c, ramp):
			continue
		var cells := layout_cells(c)
		var members := grid_members(c)
		if members.is_empty():
			continue
		var entry := {"id": str(c.get("id", "")), "size": size, "faction": faction_id, "members": members, "layout": cells, "boss": str(c.get("boss", "")), "lead": str(members[0][0])}
		for key in ["squad", "ramp", "hunts"]:   # the threat rating (the long wall brief 3.7), the ramp gate (7 November) and the hunt (8 November), as content writes them
			if c.has(key):
				entry[key] = c[key]
		out.append(entry)
	return out


## A composition's grid as eight cells, the front rank's four then the back's, each a foe id or
## "" for empty (the composition's own declaration since 8 November: its front and back).
static func layout_cells(c: Dictionary) -> Array:
	var out: Array = []
	for r in ["front", "back"]:
		var row = c.get(r, [])
		for col in range(4):
			var cell = row[col] if row is Array and col < (row as Array).size() else null
			out.append(str(cell) if cell is String else "")
	return out


## A composition's members read off its grid, [[foe id, count], ...]: each foe once with its
## cells' count, the lead first (`lead`, else the first in reading order), a core's parts left out
## (they come with their core: parts_for), so the pack on the map counts what the grid holds.
func grid_members(c: Dictionary) -> Array:
	var cells := layout_cells(c)
	var parts := {}
	for cell in cells:
		for pid in foes.get(cell, {}).get("parts", []):
			parts[str(pid)] = true
	var order: Array = []
	var counts := {}
	for cell in cells:
		if cell.is_empty() or parts.has(cell) or not foes.has(cell):
			continue
		if not counts.has(cell):
			order.append(cell)
		counts[cell] = int(counts.get(cell, 0)) + 1
	var lead := str(c.get("lead", ""))
	if order.has(lead):
		order.erase(lead)
		order.push_front(lead)
	var out: Array = []
	for fid in order:
		out.append([fid, int(counts[fid])])
	return out


## The ramp gates cover their tiers (7 November): where any of a domain's compositions of a size at
## a tier (an escort's, of its boss) carries one, every Convergence that tier is fought at, its first
## to the top, is held by one of them, so a battle never runs out of what to deal; an ungated one
## holds them all.
func _validate_ramp_gates(errs: Array[String]) -> void:
	for fid in factions.keys():
		var groups := {}   # "size|tier|boss" -> its compositions
		for c in factions[fid].get("compositions", []):
			if not (c is Dictionary):
				continue
			for t in composition_tiers(c):
				var key := "%s|%d|%s" % [str(c.get("size", "")), int(t), str(c.get("boss", ""))]
				if not groups.has(key):
					groups[key] = []
				(groups[key] as Array).append(c)
		for key in groups.keys():
			var list: Array = groups[key]
			if not list.any(func(c) -> bool: return c.get("ramp", null) is Array):
				continue
			var parts := str(key).split("|")
			for r in range(first_ramp_of(int(parts[1])), Ramp.TOP + 1):
				if not list.any(func(c) -> bool: return ramp_holds(c, r)):
					errs.append("faction %s: no %s at tier %s%s is dealt at Convergence %d; the ramp gates must hold every Convergence from the tier's first (%d) to %d" % [fid, parts[0], parts[1], (" for " + parts[2]) if not parts[2].is_empty() else "", r, first_ramp_of(int(parts[1])), Ramp.TOP])
					break


## Whether a composition is dealt at a ramp: its optional gate, `ramp` [lo, hi], the Convergences
## it is dealt at, both ends held (Ryan, 7 November: variants placed "in the tier-ramp curve"); one
## with no gate at every ramp. A ramp under 0 asks nothing (the harness's lists, the tools).
static func ramp_holds(c: Dictionary, ramp: int) -> bool:
	var g = c.get("ramp", null)
	if ramp < 0 or not (g is Array) or (g as Array).size() != 2:
		return true
	return ramp >= int(g[0]) and ramp <= int(g[1])   # the Convergence never passes the finale's: a turn cannot be passed once it is due (Campaign.pass_turn)


## The Convergence a tier is first fought at (tier 1 to 3): a rift keeps the tier it opened at and
## the ramp only rises, so a tier is fought from here to the top (Campaign.TIER_EVERY a tier).
static func first_ramp_of(tier: int) -> int:
	return Campaign.TIER_EVERY * (clampi(tier, 1, 3) - 1)


## The tiers a composition may be dealt at, as ints (content writes them as a list; one by
## default).
static func composition_tiers(c: Dictionary) -> Array:
	var out: Array = []
	var tiers = c.get("tiers", [1])
	for t in (tiers if tiers is Array else [tiers]):
		out.append(int(t))
	return out


## A faction's elite compositions at a tier, in content order: the elites its Fractures spawn.
func elite_compositions(faction_id: String, tier: int, ramp: int = -1) -> Array:
	return compositions(faction_id, tier, "elite", ramp).filter(func(c) -> bool: return not is_wandering(c))


## The chance a Fracture sends a wanderer in place of the domain's next own elite (Ryan,
## 2 November: a wanderer never waits for a domain's own to run out); a placeholder.
const WANDER_CHANCE := 1.0 / 3.0


## The wanderers at a tier: every domain's elite compositions led by a foe that wanders
## (`wanders`), each once, in content order, so one composition in one domain's list walks
## out of every rift (Gilgamesh, 31 October and 2 November).
func wandering_compositions(tier: int, ramp: int = -1) -> Array:
	var out: Array = []
	var seen: Array = []
	for fid in factions.keys():
		for c in compositions(str(fid), tier, "elite", ramp):
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
func next_elite(faction_id: String, tier: int, sent: Array, roll: float, ramp: int = -1) -> Dictionary:
	var own: Array = elite_compositions(faction_id, tier, ramp).filter(func(c) -> bool: return not sent.has(str(c["id"])))
	var wanderers: Array = wandering_compositions(tier, ramp).filter(func(c) -> bool: return not sent.has(str(c["id"])))
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


## A boss's curated escort at a tier (an `escort` composition), or empty: the boss stands alone,
## nothing grown by the tier (7 November). An escort may name its `boss` (30 October: the King
## Gel's Gels, which its merge takes in); the boss's own comes first, then one that names none.
func escort_composition(faction_id: String, tier: int, boss_id: String = "", ramp: int = -1) -> Dictionary:
	var found := compositions(faction_id, tier, "escort", ramp)
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


## Menace, the one weight the Rupture meter, Anathema and salvage count kills by, is a pack's
## threat rating (Ryan, 11 November: "Maybe just 1-2-3-4 for now to keep math simple ... We can
## tune difficulty to the value, within an acceptable band. It gives us an absolute unbiased
## benchmark"): a lone patrol one, a heavier patrol two, a formation three, an elite and a boss's
## unit four, whoever is in it and whatever its tier ("the value can stay unchanged by tier, as
## only salvage needs to scale"). Counted in hundredths of a pip, so a head's share of its pack
## is a whole number. The sum of each foe's own numbers that it was to that day (weight, below)
## made an elite's pack 22 to 49 by which came and a domain's kills worth what its stat blocks
## were.
const MENACE_PER_PIP := 100


static func worth_of(squad: int) -> int:
	return clampi(squad, 1, 4) * MENACE_PER_PIP


## A composition's menace: its threat rating's worth.
func composition_menace(c: Dictionary) -> int:
	return worth_of(squad_of(c))


## A foe's weight by its own numbers: its heaviest implemented blow (damage times strikes: the
## engine's threat, which already orders the deployment) plus a quarter of
## its HP, rounded up. What menace was until 11 November and what a kill no longer pays; kept as
## the other side of the benchmark, what a pack's stat blocks add up to against the rating its
## difficulty is tuned to (the balance report's column).
func weight(foe_id: String) -> int:
	if _weight.has(foe_id):
		return int(_weight[foe_id])
	if not foes.has(foe_id):
		return 0
	var f := make_foe(foe_id)
	var m := f.threat() + int(ceil(float(f.hp_max) / 4.0))
	_weight[foe_id] = m
	return m


## A composition's weight: every member's times its strength.
func composition_weight(c: Dictionary) -> int:
	var m := 0
	for e in c.get("members", []):
		m += weight(str(e[0])) * int(e[1])
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
	_validate_loot(errs)
	return errs


## The caches' kinds (content/loot.json): one a tier, from 1 up with none missing, each a shown
## name, a weight to be seeded by at [the wall's end, the rift's end] of the cache rows, salvage [lo, hi], a count of components and a blueprint
## chance from 0 to 1, its internal text under design.
func _validate_loot(errs: Array[String]) -> void:
	var tiers := {}
	for id in loot.keys():
		var e: Dictionary = loot[id]
		var w := "loot %s" % id
		_validate_design(w, e, errs, false)
		if str(e.get("name", "")).is_empty():
			errs.append("%s: missing name" % w)
		var t = e.get("tier", null)
		if not (t is float or t is int) or int(t) < 1:
			errs.append("%s: tier is a whole number from 1" % w)
		elif tiers.has(int(t)):
			errs.append("%s: tier %d is %s's too; one kind a tier" % [w, int(t), tiers[int(t)]])
		else:
			tiers[int(t)] = id
		var wt = e.get("weight", null)
		if not (wt is Array) or (wt as Array).size() != 2 or not (wt as Array).all(func(x) -> bool: return (x is float or x is int) and float(x) >= 0.0):
			errs.append("%s: weight is [at the wall, at the rift], each 0 or more" % w)
		var sv = e.get("salvage", null)
		if not (sv is Array) or (sv as Array).size() != 2 or not (sv as Array).all(func(x) -> bool: return x is float or x is int) or int(sv[0]) < 0 or int(sv[0]) > int(sv[1]):
			errs.append("%s: salvage is [lo, hi], 0 <= lo <= hi" % w)
		var n = e.get("components", null)
		if not (n is float or n is int) or int(n) < 0:
			errs.append("%s: components is a count, 0 or more" % w)
		var bp = e.get("blueprint", null)
		if not (bp is float or bp is int) or float(bp) < 0.0 or float(bp) > 1.0:
			errs.append("%s: blueprint is a chance from 0 to 1" % w)
		if not (e.get("codex", "") is String):
			errs.append("%s: codex is text" % w)
	for k in range(1, tiers.size() + 1):
		if not tiers.has(k):
			errs.append("loot: the kinds' tiers run from 1 with none missing (no tier %d)" % k)
	for key in ["per_battle", "rift_gap", "wall_gap", "behind_shell"]:
		if int(loot_rules.get(key, 0)) < 0:
			errs.append("loot: %s is 0 or more" % key)


## The caches' kinds by tier, lowest first.
func loot_kinds() -> Array:
	var out: Array = loot.keys()
	out.sort_custom(func(a, b) -> bool: return int(loot[a].get("tier", 0)) < int(loot[b].get("tier", 0)))
	return out


## The kind of a tier, "" for none.
func loot_kind_of_tier(t: int) -> String:
	for id in loot.keys():
		if int(loot[id].get("tier", 0)) == t:
			return str(id)
	return ""


## The highest kind's tier, 0 with none.
func loot_top_tier() -> int:
	var top := 0
	for id in loot.keys():
		top = maxi(top, int(loot[id].get("tier", 0)))
	return top


## The components a cache of a battle at `item_tier` (1 to 3) may hold, in content order: the
## tier's unlocked components the engine runs (a locked one is never loot, as never a blueprint).
func loot_pool(item_tier: int) -> Array:
	var out: Array = []
	for cid in components.keys():
		if component_tier(str(cid)) == item_tier and str(components[cid].get("status", "")) != "planned":
			out.append(str(cid))
	return out


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
const CHARGED_KEYS := ["muster", "store", "price", "status", "stacks", "rounds", "not_acted", "keywords", "shield", "vents", "cleanse", "act_again"]


func _validate_charged(where: String, kind: String, cd, errs: Array[String]) -> void:
	if not (cd is Dictionary) or (cd as Dictionary).is_empty():
		errs.append("%s: charged is the form a muster buys, a dictionary of %s" % [where, ", ".join(CHARGED_KEYS)])
		return
	for key in cd.keys():
		if not CHARGED_KEYS.has(str(key)):
			errs.append("%s: charged has no '%s' (it knows %s)" % [where, key, ", ".join(CHARGED_KEYS)])
	if int(cd.get("muster", 1)) < 1:
		errs.append("%s: a charged form costs at least one muster" % where)
	# Another store than the Muster (the Nemesis's rage, 11 November): a status tagged a store,
	# priced in its stacks, never beside a muster price.
	if cd.has("store"):
		var store := str(cd["store"])
		if not Effects.STATUS.has(store) or not (Effects.STATUS[store].get("tags", []) as Array).has("store") or store == "muster":
			errs.append("%s: a charged store is a status tagged a store, other than the Muster ('%s' is not)" % [where, store])
		if cd.has("muster"):
			errs.append("%s: a charged form on a store is priced in its stacks (price), never in musters" % where)
		if int(cd.get("price", 1)) < 1:
			errs.append("%s: a charged form costs at least one stack of its store" % where)
	elif cd.has("price"):
		errs.append("%s: a charged price is a store's stacks: it needs the store it draws on" % where)
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
		# Two reaches since 10 October (Ryan): Close (melee) is removed, and melee is a tag. Every
		# Foe a targeting mode since 4 November; Sweep, one from 3 November, went on the 12th
		# (Ryan: "let's remove it"; "it's just better spread").
		var reach := str(fd.get("reach", ""))
		if reach == "sweep":
			errs.append("%s: Sweep is gone (12 November): a weapon reaches wide by Spread or Penetrate, or lands on every foe (reach every_foe)" % where)
		elif not ["direct", "indirect", "every_foe"].has(reach):
			errs.append("%s: attack face needs reach direct, indirect or every_foe, got '%s'" % [where, reach])
	if int(fd.get("power", 0)) < 0:
		errs.append("%s: power cannot be negative" % where)
	if int(fd.get("strikes", 1)) < 1:
		errs.append("%s: strikes must be at least 1" % where)
	if int(fd.get("strikes", 1)) > 1 and kind != "attack":
		errs.append("%s: only attacks strike more than once" % where)
	if fd.has("power_max"):
		errs.append("%s: power_max is gone (2 November): a weapon is one number" % where)
	if fd.has("heat_per_blow"):
		errs.append("%s: heat_per_blow left the entry with the Siphon (12 November): a heat a blow taken is a passive's static heat_per_blow" % where)
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
	# A gun that fires its machine's whole shield (the Shield-burner Cannon since 18 November): an
	# attack's, a step of power_per_shield for every per_shield it fires, never beside vents_all
	# (one whole gauge a gun).
	if (fd.has("spends_shield") or fd.has("power_per_shield")) and kind != "attack":
		errs.append("%s: spends_shield and power_per_shield belong to an attack" % where)
	if fd.has("power_per_shield") and not bool(fd.get("spends_shield", false)):
		errs.append("%s: power_per_shield needs spends_shield (the shield it adds for is the shield it fires)" % where)
	if fd.has("per_shield") and (not fd.has("power_per_shield") or int(fd["per_shield"]) <= 0):
		errs.append("%s: per_shield is the shield a step of power_per_shield stands for: positive, and only beside power_per_shield" % where)
	if bool(fd.get("spends_shield", false)) and bool(fd.get("vents_all", false)):
		errs.append("%s: a gun fires its whole heat or its whole shield, never both" % where)
	if fd.has("power_per_missing") and (kind != "attack" or int(fd["power_per_missing"]) <= 0):
		errs.append("%s: power_per_missing is a positive number on an attack" % where)
	if fd.has("per_missing") and (not fd.has("power_per_missing") or int(fd["per_missing"]) <= 0):
		errs.append("%s: per_missing is the HP a step of power_per_missing stands for: positive, and only beside power_per_missing" % where)
	# The Pinion Driver's finish (the Kite's, 11 November): a weapon's number times this against a
	# foe at half its HP or less, a whole number of two or more.
	if fd.has("finisher") and (kind != "attack" or int(fd.get("power", 0)) <= 0 or int(fd["finisher"]) < 2 or float(fd["finisher"]) != floorf(float(fd["finisher"]))):
		errs.append("%s: finisher is a weapon's: its number times that, a whole number of 2 or more, against a foe at half its HP or less" % where)
	# Volatile is a cost, not a keyword (Ryan, 26 October): `volatile`, the hull a spend bites, a
	# positive number beside the heat; and a shield cost the same way (`shield_cost`), the shield
	# a spend takes first, the entry unplayable while the shield is short of it.
	if Array(fd.get("keywords", [])).has("volatile"):
		errs.append("%s: Volatile is a cost, not a keyword: volatile, a number, and nothing in keywords" % where)
	if fd.has("volatile") and int(fd.get("volatile", 0)) <= 0:
		errs.append("%s: volatile is the hull a spend bites: a positive number" % where)
	if fd.has("shield_cost") and int(fd.get("shield_cost", 0)) <= 0:
		errs.append("%s: shield_cost is the shield a spend takes first: a positive number" % where)
	# A buff that spends a count of its own machine's for its stacks (the Quintessence Tap, 12 November):
	# the status it spends, one the engine knows, and the most it takes, which is the most it
	# grants, so it says no stacks of its own.
	if fd.has("spends") or fd.has("spends_up_to"):
		if kind != "buff" or not Effects.STATUS.has(str(fd.get("spends", ""))):
			errs.append("%s: spends is a buff's: the status of its own machine it spends for its stacks, one of the engine's" % where)
		if int(fd.get("spends_up_to", 0)) < 1:
			errs.append("%s: spends_up_to is the most a spend takes, and so the most it grants: 1 or more, beside spends" % where)
		if fd.has("stacks"):
			errs.append("%s: a buff that spends a count grants a stack for each one spent, so it says spends_up_to and no stacks" % where)
		if str(fd.get("targets", "")) != "self":
			errs.append("%s: a buff that spends its own machine's count lands on itself (targets self)" % where)
	# A hold on the whole field (the Quintessence Tap's "No Empowered decays this round"): a status that
	# halves on its own clock, held on every unit through the round's end.
	if fd.has("holds_all") and (not Effects.decays_to_zero(Effects.STATUS.get(str(fd["holds_all"]), {})) or not Effects.ROUND_HOLDERS.has(str(fd["holds_all"]))):
		errs.append("%s: holds_all names a status that halves on its own and has a buff that holds it on every unit (Empowered: Essence Flare)" % where)
	# Ablate is a numbered keyword (Ryan, 18 October): an entry says the stacks each hit leaves.
	if Array(fd.get("keywords", [])).has("ablate") and int(fd.get("ablate", 0)) <= 0:
		errs.append("%s: an entry with Ablate says its stacks: ablate, a positive number" % where)
	if fd.has("ablate") and not Array(fd.get("keywords", [])).has("ablate"):
		errs.append("%s: ablate (the stacks) rides with the Ablate keyword" % where)
	# Cryo is numbered the same way (20 October): the stacks each foe reached gains.
	if Array(fd.get("keywords", [])).has("cryo") and int(fd.get("cryo", 0)) <= 0:
		errs.append("%s: an entry with Cryo says its stacks: cryo, a positive number" % where)
	if fd.has("cryo") and not Array(fd.get("keywords", [])).has("cryo"):
		errs.append("%s: cryo (the stacks) rides with the Cryo keyword" % where)
	# And Brittle (21 October): the stacks each foe hit gains.
	if Array(fd.get("keywords", [])).has("sap") and int(fd.get("sap", 0)) <= 0:
		errs.append("%s: Sap needs its number: the stacks of Sapped each foe hit gains" % where)
	if fd.has("sap") and not Array(fd.get("keywords", [])).has("sap"):
		errs.append("%s: sap is the Sap keyword's number: the entry needs the keyword" % where)
	if fd.has("disrupts_attackers") and kind != "buff":
		errs.append("%s: disrupts_attackers is a buff's: every foe aiming at the machine it lands on is Disrupted" % where)
	if Array(fd.get("keywords", [])).has("brittle") and int(fd.get("brittle", 0)) <= 0:
		errs.append("%s: an entry with Brittle says its stacks: brittle, a positive number" % where)
	if fd.has("brittle") and not Array(fd.get("keywords", [])).has("brittle"):
		errs.append("%s: brittle (the stacks) rides with the Brittle keyword" % where)
	# Area by shape, numbered (Ryan, 28 October; the half retired): a weapon's Spread or Penetrate
	# says the number each foe past its target takes (cleave, penetrate); a debuff's area deals
	# nothing, so it says none. A piece may carry both, at one number or two (Splash, the two
	# under one word, was cut on 15 November).
	var kw_names := Array(fd.get("keywords", []))
	var debuff := kind == "attack" and Face.from_dict(fd).is_debuff()
	for name: String in ["cleave", "penetrate"]:
		var label: String = "Spread" if name == "cleave" else str(name).capitalize()
		if kw_names.has(name) and kind == "attack" and not debuff and int(fd.get(name, 0)) <= 0:
			errs.append("%s: a weapon with %s says what each foe past its target takes: %s, a positive number" % [where, label, name])
		if fd.has(name) and not kw_names.has(name):
			errs.append("%s: %s (the number) rides with the %s keyword" % [where, name, label])
		if fd.has(name) and debuff:
			errs.append("%s: a debuff's %s deals nothing, so it carries no number (%s)" % [where, label, name])
	# Chain (Ryan, 28 October; the kill and repeat retired): a keyword with a number, the blow every
	# other Shocked foe on the field takes. A debuff's carries its number too since 17 November (the
	# Storm Petrel's lure, its Striker branch: "adds Chain 3 to the lure"): its arcs are blows, so
	# its riders reach every conductor with one, as any area carries a debuff's riders.
	# Purge is numbered (Ryan, 2 November: "lower everything by N"): the stacks every buff of each
	# foe reached loses, on a weapon or equipment alike.
	if kw_names.has("dispel") and int(fd.get("dispel", 0)) <= 0:
		errs.append("%s: an entry with Purge says its stacks: dispel, a positive number" % where)
	if fd.has("dispel") and not kw_names.has("dispel"):
		errs.append("%s: dispel (the stacks) rides with the Purge keyword" % where)
	elif kw_names.has("chain") and kind == "attack" and int(fd.get("chain", 0)) <= 0:
		errs.append("%s: Chain says the number every other Shocked foe takes: chain, a positive number" % where)
	if fd.has("chain") and not kw_names.has("chain"):
		errs.append("%s: chain (the number) rides with the Chain keyword" % where)
	# Every Foe on a weapon lands its number whole on every foe (12 November, the two gated
	# specials'), so an area keyword on it has no foe left to reach.
	if str(fd.get("reach", "")) == "every_foe" and kind == "attack" and (kw_names.has("cleave") or kw_names.has("penetrate")):
		errs.append("%s: Every Foe lands on every foe already: no Spread or Penetrate rides it" % where)
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
	# The foe in front (the Photosphere Lance's, 11 November): a buff that also lays a foe status,
	# stacks 1 or more, on the foe in front of the machine it lands on.
	if fd.has("in_front"):
		var front = fd["in_front"]
		if kind != "buff" or not (front is Dictionary) or not Effects.FOE_STATUSES.has(str(front.get("status", ""))) or int(front.get("stacks", 0)) < 1:
			errs.append("%s: in_front is a buff's: {status, stacks} laying a status the team puts on foes (%s), 1 stack or more, on the foe in front of the machine it lands on" % [where, ", ".join(Effects.FOE_STATUSES)])
	# A pin (the Hollow-point Harpoon's, 11 November): a status that halves, held on the target
	# through the round's end.
	if fd.has("holds") and (kind != "attack" or not Effects.HOLDERS.has(str(fd["holds"]))):
		errs.append("%s: holds names a status a pin can hold (%s), on an attack" % [where, ", ".join(Effects.HOLDERS.keys())])
	if fd.has("consumes"):
		if kind != "attack" or not Effects.FOE_STATUSES.has(str(fd["consumes"])):
			errs.append("%s: consumes names a status the team puts on a foe (%s), on an attack" % [where, ", ".join(Effects.FOE_STATUSES)])
		if int(fd.get("strikes", 1)) > 1 or str(fd.get("reach", "")) == "every_foe":
			errs.append("%s: a consumer is one blow on each foe it strikes, each eating its own: no strikes past one or Every Foe" % where)
	if fd.has("per_consumed") and (not fd.has("consumes") or int(fd["per_consumed"]) <= 0):
		errs.append("%s: per_consumed is the damage a stack consumed adds: positive, and only beside consumes" % where)
	# Its own fire (the Stoker's, the stock pass's landing, 22 October): an attack that sets its
	# machine Ablating as it is spent, a positive number of stacks.
	if fd.has("self_ablate") and (kind != "attack" or int(fd["self_ablate"]) <= 0):
		errs.append("%s: self_ablate is a positive number of stacks of Ablating on its own machine, on an attack" % where)
	# Ignores armour (Ryan, 15 November, where the Breach keyword stood on our side: "Ignores
	# armour can be an explicitly written out property"): a rule written on a weapon, true or
	# false, never on equipment, which deals nothing.
	if fd.has("ignores_armour") and (not (fd["ignores_armour"] is bool) or kind != "attack"):
		errs.append("%s: ignores_armour is true or false, on an attack" % where)
	# The two rules that were keywords until 15 November, each its one piece's own (the Combat
	# Translocator's swap, the Web Bomb's web): true or false, on an attack.
	for rule in ["swaps", "webs"]:
		if fd.has(rule) and (not (fd[rule] is bool) or kind != "attack"):
			errs.append("%s: %s is true or false, on an attack" % [where, rule])
	for key in ["fills_hopper", "fires_hopper"]:
		if fd.has(key) and (kind != "attack" or int(fd[key]) <= 0):
			errs.append("%s: %s is a positive number on an attack" % [where, key])
	if fd.has("fires_hopper") != fd.has("power_per_load") or (fd.has("power_per_load") and int(fd["power_per_load"]) <= 0):
		errs.append("%s: fires_hopper and a positive power_per_load go together" % where)
	# The brace (12 October): spending the entry Armours its owner until its side's next turn begins.
	if fd.has("braces") and int(fd["braces"]) <= 0:
		errs.append("%s: braces is a positive number of stacks of Armoured, an armour point each" % where)
	# Rolling again on a status (the Nemesis's fists on rage, 12 October to 11 November) and the
	# spin (the Spin-Up's, 19 October) retired on 12 November: Instant is the roll that may land on
	# itself, a spin on a stepping die, and a charged form on a store prices it (the Knuckle of
	# Fury's five rage).
	if fd.has("rolls_again_on"):
		errs.append("%s: rolls_again_on is retired (12 November): Instant is the roll that may land on itself, a charged form on a store its price" % where)
	if fd.has("spins"):
		errs.append("%s: spins is retired (12 November): Instant's roll is a spin on a stepping die" % where)
	# The cooldown (Ryan, 14 October; counted after the round of the spend since 12 November,
	# "change the count so 1 is how I intended"): a printed property, the rounds the entry sits
	# out once spent, a cost the die prints by its clock, so an entry with none leaves it out.
	# Rapid's own switch-off, dark for the rest of the round, is the keyword's and never printed
	# (Ryan, 12 November: "rapid gets its innate cooldown zero back without the explicit display").
	var keys := Array(fd.get("keywords", []))
	var rapid := keys.has("rapid")
	var instant := keys.has("instant")
	if fd.has("cooldown"):
		var cd = fd["cooldown"]
		if not (cd is int or cd is float) or float(cd) < 1.0 or float(cd) != floorf(float(cd)):
			errs.append("%s: cooldown is a whole number of rounds, 1 or more; an entry with none leaves it out" % where)
	# Rapid or Instant, never both: each gives the turn back its own way, so the charged form a store
	# buys never adds the other to its plain one either.
	var charged_keys: Array = (fd["charged"] as Dictionary).get("keywords", []) if fd.get("charged") is Dictionary else []
	if (rapid or charged_keys.has("rapid")) and (instant or charged_keys.has("instant")):
		errs.append("%s: an entry is Rapid or Instant, never both: each gives the machine its turn back its own way" % where)
	# Every chain carries a limiter (Ryan, 15 October: no chain is free). Rapid's is its own, the
	# entry dark for the rest of the round; Instant's roll may land on itself, so an Instant entry
	# prints a cooldown or pays heat, hull or shield every spend, or is the charged form a store
	# buys, its price the limit (the Knuckle of Fury's five rage). A piece locked on a stepping die
	# has the cylinder and its odds for its limiter (the Cassowary's Spin-Up, Ryan, 19 October: a
	# combo piece, its spin a true roll that lands on itself one time in its die's size, to be spent
	# again, the high roll he allowed; the exit, a stepping-die piece that ever chains for sure gets a
	# limiter of its own).
	if instant and not planned and not stepped and int(fd.get("cooldown", 0)) <= 0 \
			and int(fd.get("heat", 0)) <= 0 and int(fd.get("volatile", 0)) <= 0 and int(fd.get("shield_cost", 0)) <= 0:
		errs.append("%s: an Instant entry with no cooldown carries another limiter, heat, Volatile or a shield cost (the bible's Rapid row)" % where)
	# A reach over every foe or every ally is a targeting mode since 4 November (Ryan: "Silence
	# should not narrow targeting modes, that's why I'm switching them to targeting modes"; a
	# keyword from 2 November, a flag before): Every Foe a debuff's reach (the Shift Whistle's), Every Ally
	# a shield's or a buff's targets (the whole team, Every Ally, or every machine but its own, Every
	# Other Ally: the Swallowtail's team shield), never a vent's.
	if fd.has("reaches_all"):
		errs.append("%s: reaches_all is a targeting mode now: reach every_foe on a debuff, targets every_ally or every_other_ally on a shield or a buff" % where)
	for kw in ["every_foe", "every_ally"]:
		if Array(fd.get("keywords", [])).has(kw):
			errs.append("%s: %s is a targeting mode since 4 November, never a keyword: %s" % [where, kw, "reach every_foe" if kw == "every_foe" else "targets every_ally or every_other_ally"])
	if kind == "vent" and str(fd.get("targets", "")) in ["every_ally", "every_other_ally"]:
		errs.append("%s: Every Ally and Every Other Ally are a shield's or a buff's, never a vent's" % where)
	# The Swallowtail's locked pieces (21 October): a shield's cooling half, a buff on every ally
	# yet to act, an ally acting again, and the charged form a muster buys.
	if fd.has("vents") and (kind != "shield" or not (fd["vents"] is float or fd["vents"] is int) or int(fd["vents"]) <= 0):
		errs.append("%s: vents is a shield's cooling half: the heat it takes off the machine it shields, first, a positive number" % where)
	if (fd.has("fills_shield") or fd.has("cools_all")) and kind != "shield":
		errs.append("%s: fills_shield and cools_all are a shield's (the full reset)" % where)
	if fd.has("not_acted") and (kind != "buff" or not (str(fd.get("targets", "")) in ["every_ally", "every_other_ally"])):
		errs.append("%s: not_acted narrows a buff reaching every ally to those yet to act" % where)
	if fd.has("act_again") and kind != "buff":
		errs.append("%s: act_again is a buff's: an ally whose die is spent acts again" % where)
	if fd.has("charged"):
		_validate_charged(where, kind, fd["charged"], errs)
	# The Musk Ox's pieces (21 October): a refund, the salvo, random targets, a reload.
	if fd.has("ammo_per_foe_hit") and (kind != "attack" or int(fd["ammo_per_foe_hit"]) <= 0):
		errs.append("%s: ammo_per_foe_hit is an attack's, a weapon's or a debuff's: the ammo back for every foe its blows reach, a positive number" % where)
	if fd.has("spends_magazine") and (kind != "attack" or not (fd["spends_magazine"] is bool)):
		errs.append("%s: spends_magazine (true) is an attack's, a weapon's or a debuff's" % where)
	if fd.has("magazine_min") and (not bool(fd.get("spends_magazine", false)) or int(fd["magazine_min"]) < 1):
		errs.append("%s: magazine_min is the ammo a piece that spends the magazine needs to fire: 1 or more, beside spends_magazine" % where)
	if fd.has("reloads_ammo") and (kind == "attack" or kind == "blank" or int(fd["reloads_ammo"]) <= 0):
		errs.append("%s: reloads_ammo is a machine piece's: the ammo it adds to its forging machine, a positive number" % where)
	if fd.has("shields") and (kind != "vent" or int(fd["shields"]) <= 0):
		errs.append("%s: shields is a vent's shield half (the combined entry): the shield it gives after its vent, a positive number" % where)
	if fd.has("gathers_mines") and (kind != "attack" or not (fd["gathers_mines"] is bool)):
		errs.append("%s: gathers_mines (true) is an attack's, a weapon's or a debuff's: every Mine on the field's other foes joins its target's" % where)
	if fd.has("detonates") and (kind != "attack" or not (fd["detonates"] is bool)):
		errs.append("%s: detonates (true) is an attack's, a weapon's or a debuff's: its target's Mine blows now, on it and every foe round it" % where)
	# The slot mines retired with the Lammergeier's rework (Ryan, 9 November: "A chassis based around
	# opening an empty spot isn't a good design"): nothing is spent on an empty slot.
	if fd.has("pulls_mines") or fd.has("drones"):
		errs.append("%s: pulls_mines and drones are gone (9 November): the Lorentz Contractor gathers (gathers_mines) and the Syrinx Drone detonates (detonates)" % where)
	# The spray and the random targets of October, and Sweep after them, are gone.
	if fd.has("spray") or fd.has("random_targets"):
		errs.append("%s: spray and random_targets are gone (3 November)" % where)
	if Array(fd.get("keywords", [])).has("sweep"):
		errs.append("%s: Sweep is gone (12 November), as a reach and as a keyword" % where)
	# The Changeover (the Clydesdale's, 11 November): turning a folded die to its other battery is a
	# Rapid buff on itself, its free roll landing on the battery it raised.
	if fd.has("turns_die") and (not (fd["turns_die"] is bool) or kind != "buff" or not rapid or str(fd.get("targets", "")) != "self"):
		errs.append("%s: turns_die (true) is a Rapid buff on itself that turns a folded die" % where)
	# What a spend at a foe lays on its own machine (the Hardlight Pulse's Hardened Light 1, up to
	# 3: Ryan, 18 November): an attack's, each a machine buff from the engine's table, its stacks,
	# per_foe for a set of them for every foe the spend reached, and the most its machine holds
	# (cap, 0 or none for no cap); an upgrade's branch takes it further (self_status). The St.
	# Elmo's Regenerator's own key, `regenerates`, left with its rework of 17 November. The
	# Petrels' other locked pieces: an ally's action bought with the team's rerolls (the Immelmann
	# Booster), a roll on the machine a buff lands on (the Reheat Uplink), and the rerolls a kill
	# brings (the Spindrift Salvo).
	if fd.has("regenerates"):
		errs.append("%s: regenerates left the engine with the Storm Petrel's lock's Regenerating (17 November): a status on its own machine is self_statuses" % where)
	if fd.has("self_statuses"):
		var grants = fd["self_statuses"]
		if kind != "attack" or not (grants is Array) or (grants as Array).is_empty():
			errs.append("%s: self_statuses is an attack's: a list of {status, stacks, per_foe, cap}, what the spend lays on its own machine" % where)
		else:
			for g in grants:
				var sid := str(g.get("status", "")) if g is Dictionary else ""
				if not (g is Dictionary) or not SELF_GRANTS.has(sid) or int(g.get("stacks", 1)) < 1 \
						or (g.has("per_foe") and not (g["per_foe"] is bool)) or (g.has("cap") and int(g["cap"]) < int(g.get("stacks", 1))) \
						or (g as Dictionary).keys().any(func(k) -> bool: return not ["status", "stacks", "per_foe", "cap"].has(str(k))):
					errs.append("%s: a self_statuses grant is {status, stacks (1 or more), per_foe (true or false), cap (its stacks or more)}, its status one of %s" % [where, ", ".join(SELF_GRANTS)])
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
	# A reroll for the team is equipment's own rule (15 November, in the Rallied buff's place): a
	# positive number on a buff, which then grants no status.
	if fd.has("team_rerolls") and (kind != "buff" or int(fd["team_rerolls"]) <= 0 or fd.has("status")):
		errs.append("%s: team_rerolls is a buff's own rule, a positive number of rerolls, and it grants no status beside it" % where)
	if kind == "buff" and not bool(fd.get("turns_die", false)) and not (int(fd.get("team_rerolls", 0)) > 0 and not fd.has("status")) and not (bool(fd.get("disrupts_attackers", false)) and not fd.has("status")):
		# A buff grants one of the machines' statuses (the Changeover grants none: its rule is the
		# turn of a folded die): it must exist and be theirs. A planned
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
		# Armoured lasts one turn from every source (Ryan, 12 October): a status that goes whole
		# as its side's next turn begins is never granted for longer.
		if str(Effects.STATUS.get(st, {}).get("decay", "")) == "round" and int(fd.get("rounds", 1)) > 1:
			errs.append("%s: %s lasts until its side's next turn begins, so a buff grants it for one round" % [where, st])
		# A status that decays to zero on its own clock (Empowered halving) has no duration
		# (Ryan, 18 October: "Things either decrease to zero, or are timed, not both").
		if Effects.decays_to_zero(Effects.STATUS.get(st, {})) and fd.has("rounds"):
			errs.append("%s: %s halves on its own clock, so a buff grants it stacks and no rounds" % [where, st])
		# One a use spends (Spun Up, spent by the next weapon; a primer, a stack a weapon fired)
		# lasts until then.
		if Effects.STATUS.get(st, {}).has("spent_by") and fd.has("rounds"):
			errs.append("%s: %s lasts until a use spends it, so a buff grants it stacks and no rounds" % [where, st])
		if Effects.lasts_the_fight(Effects.STATUS.get(st, {})) and fd.has("rounds"):
			errs.append("%s: %s lasts the fight, so a buff grants it stacks and no rounds" % [where, st])
	elif fd.has("status") or fd.has("stacks") or fd.has("rounds"):
		errs.append("%s: status, stacks and rounds belong to a buff face" % where)
	if fd.has("targets"):
		var t := Face.target_from_name(str(fd["targets"]))
		if kind == "attack":
			errs.append("%s: an attack always targets foes; 'targets' is for a shield, a vent or a buff" % where)
		elif t < 0 or t == Face.Target.FOE:
			errs.append("%s: targets must be self_ally, self, ally, every_ally or every_other_ally, got '%s'" % [where, fd["targets"]])
	var kws: Array = fd.get("keywords", [])
	if kws.size() > MAX_AUTHORED_KEYWORDS:
		errs.append("%s: %d keywords, authored cap is %d" % [where, kws.size(), MAX_AUTHORED_KEYWORDS])
	for k in kws:
		# A planned component may carry a keyword the vocabulary names but the engine lacks
		# (taunt, corrode once), and a built component may carry a planned one (the
		# Flakshot Repeater's Brittle from 19 to 21 October): Face.from_dict builds the entry without that
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


## `one_off`: the chassis's design names the rule its passive breaks as a one-off (the bible's
## section 7: a passive may break a rule, the rule bending for one machine), which lifts the
## effect cap by one (the first Kite's double, its heat, its dark rounds and its tax, two lines; no
## chassis names one today).
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
		if (effect == "stack_status" or effect == "lay_status") and not Effects.STATUS.has(str(eff.get("value", ""))):
			errs.append("%s: %s needs an engine status as its value" % [where, effect])
		# A lay that asks for a weapon's hit (the Ambush's Vitriol, Ryan, 25 October) says so on the
		# effect and in its passive's text; any other lays on every hit, equipment's included.
		if effect == "lay_status" and eff.has("damaging") and not (eff["damaging"] is bool):
			errs.append("%s: lay_status's damaging is true or false (a weapon's hit only, said in the passive's text)" % where)
		if effect == "lay_status" and eff.has("stacks") and int(eff["stacks"]) < 1:
			errs.append("%s: lay_status lays at least one stack a hit" % where)
		if effect == "stack_status" and eff.has("cap") and int(eff["cap"]) < 1:
			errs.append("%s: stack_status's cap is the most stacks it banks, at least 1" % where)
		# A status a spend at a foe lays on its own machine (the Storm Petrel's branches, 17
		# November): a machine buff from the table, its stacks, and per_foe for a set of them for
		# every foe the spend reached. A Barrier and a Ward keep their pieces and their cooldowns.
		# The Buzzard's zap (18 November): what each weapon it fires pays in shield and adds to every
		# blow, both whole numbers, 1 or more.
		if effect == "shield_zap" and (trig != "static" or int(eff.get("value", 0)) < 1 or int(eff.get("cost", 0)) < 1):
			errs.append("%s: shield_zap is static: cost, the shield each weapon pays, and value, what it adds to every blow, each 1 or more" % where)
		if effect == "add_power" and (trig != "static" or int(eff.get("value", 0)) < 1):
			errs.append("%s: add_power is static: value, what a weapon's own number gains, 1 or more" % where)
		# A slot (18 November): an effect a later grant in the same slot replaces, its name a word.
		if eff.has("slot") and (not (eff["slot"] is String) or str(eff["slot"]).strip_edges().is_empty()):
			errs.append("%s: slot names the place a later grant replaces this effect in: a word" % where)
		if effect == "self_status":
			if not SELF_GRANTS.has(str(eff.get("status", ""))):
				errs.append("%s: self_status lays one of %s" % [where, ", ".join(SELF_GRANTS)])
			if not (eff.get("value") is int or eff.get("value") is float) or int(eff["value"]) < 1:
				errs.append("%s: self_status's value is the stacks it lays, 1 or more" % where)
			if eff.has("per_foe") and not (eff["per_foe"] is bool):
				errs.append("%s: self_status's per_foe is true or false (a set of stacks for every foe the spend reached)" % where)
			if eff.has("cap") and int(eff["cap"]) < maxi(1, int(eff.get("value", 1))):
				errs.append("%s: self_status's cap is the most stacks its machine holds, its value or more" % where)
			# Flat stacks beside a set a foe (the Beam Pavise's "Gain 1 Armoured, plus 1 Armoured for
			# every foe struck", Ryan, 19 November).
			if eff.has("plus") and (not bool(eff.get("per_foe", false)) or int(eff["plus"]) < 1):
				errs.append("%s: self_status's plus is the flat stacks laid beside per_foe's set a foe, 1 or more, with per_foe" % where)
		# The Macaque's offhand (Ryan, 19 November: "Only its offhand swaps"): a form of its cycle,
		# its id a content id, its name and its line shown (its chip, the rider on the die), its riders
		# the effects the form carries while it is up, read as any status's are.
		if effect == "offhand":
			if trig != "static":
				errs.append("%s: offhand is static: a form of the cycle" % where)
			if str(eff.get("id", "")).strip_edges().is_empty() or not str(eff.get("id", "")).is_valid_identifier():
				errs.append("%s: an offhand form has an id, a content id (beam_rifle)" % where)
			if str(eff.get("name", "")).strip_edges().is_empty() or str(eff.get("description", "")).strip_edges().is_empty():
				errs.append("%s: an offhand form has a name and a description, its chip's and its rider's line" % where)
			var riders = eff.get("riders", [])
			if not (riders is Array) or (riders as Array).is_empty():
				errs.append("%s: an offhand form carries its riders, one or more effects" % where)
			else:
				for r in riders:
					if not (r is Dictionary) or str((r as Dictionary).get("effect", "")) == "offhand":
						errs.append("%s: an offhand form's rider is an effect, never a form" % where)
				_validate_passive("%s form %s" % [where, str(eff.get("id", ""))], {"id": str(eff.get("id", "form")), "name": str(eff.get("name", "")), "description": str(eff.get("description", "")), "effects": riders}, errs)
		# The Beam Rifle's blow on the foe to the right with every strike, and the Beam Sword's hit again
		# after each, its share of the strike's blow in percent (the Beam Saber's 100).
		if effect == "side_strike" and (trig != "static" or int(eff.get("value", 0)) < 1):
			errs.append("%s: side_strike is static: value, what the foe to the right of the target takes with every strike, 1 or more" % where)
		if effect == "strike_again" and (trig != "static" or int(eff.get("value", 0)) < 1):
			errs.append("%s: strike_again is static: value, the share of each strike's blow its hit again carries, in percent, 1 or more" % where)
		# The name an effect gives the piece it is scoped to (the Aile Booster as its Blitzer or its
		# Assaulter, Ryan, 19 November): shown text, on an effect that names its piece.
		if eff.has("name") and effect != "offhand" and (not eff.has("entry") or str(eff["name"]).strip_edges().is_empty()):
			errs.append("%s: an effect's name is the name its piece takes: a word or two, beside the entry it names" % where)
		# A branch's status in a buff piece's own's place (the Aile Booster's Blitzer and Assaulter).
		if effect == "buff_status":
			if trig != "static" or not Effects.MECH_STATUSES.has(str(eff.get("value", ""))):
				errs.append("%s: buff_status is static: value, the machine buff its piece grants in place of its own, one of %s" % [where, ", ".join(Effects.MECH_STATUSES)])
			if not eff.has("entry") or str(components.get(str(eff.get("entry", "")), {}).get("face", {}).get("kind", "")) != "buff":
				errs.append("%s: buff_status names the buff piece it rewrites (entry)" % where)
		# An effect scaled by a status the machine carries may count it in steps (the Ammit's flare,
		# 12 November: an Empowered for every five Essence).
		if eff.has("stack_step") and (not eff.has("per_stack") or int(eff["stack_step"]) < 1):
			errs.append("%s: stack_step is the stacks of per_stack's status a step takes: 1 or more, beside per_stack" % where)
		# An effect that fires once a round (the Skua's stack of Ricochet for damaging a foe, Ryan,
		# 11 November: "once per turn"): a gate on what an event fires (Effects.fire), which the
		# pipeline's effects (static, on_attack, on_injury) never pass through.
		if eff.has("once") and (str(eff["once"]) != "round" or ["static", "on_attack", "on_injury"].has(trig)):
			errs.append("%s: once is \"round\", on an effect an event fires (never static, on_attack or on_injury)" % where)
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
		if effect == "multiply_printed" and float(eff.get("value", 0)) <= 0.0:
			errs.append("%s: multiply_printed needs a positive value, the multiply on the printed number" % where)
		# The Musk Ox's Forge (21 October): its magazine, the opening load, the trickle, the heat an
		# ammo stands for, the reloads of a vent and a shield on itself.
		if effect == "forge" and (int(eff.get("value", 0)) < 1 or int(eff.get("per_heat", 0)) < 1 \
				or int(eff.get("start", 0)) < 0 or int(eff.get("per_round", 0)) < 0 or int(eff.get("vent", 0)) < 0 or int(eff.get("shield", 0)) < 0):
			errs.append("%s: forge needs value (the magazine, positive), per_heat (the heat an ammo stands for, positive), and start, per_round, vent and shield, 0 or more" % where)
		# The Swallowtail's Muster (21 October): points a charge, a cap in charges, points a kill.
		if effect == "muster" and (int(eff.get("value", 0)) < 1 or int(eff.get("cap", 0)) < 1 or int(eff.get("kill", 0)) < 0):
			errs.append("%s: muster needs value (the points a charge, positive), cap (the charges it holds, positive) and kill (the points a kill by its own guns gives, 0 or more)" % where)
		# The Reverberant Payload (the Lammergeier's, Ryan, 9 November): the flat damage of the Mine
		# every spend aimed at a foe leaves, a whole number, 1 or more.
		if effect == "mine_on_spend" and (not (eff.get("value") is int or eff.get("value") is float) or int(eff["value"]) < 1 or float(eff["value"]) != floorf(float(eff["value"]))):
			errs.append("%s: mine_on_spend is the Mine's flat damage a spend: a whole number, 1 or more" % where)
		if effect == "reboot_release" and (int(eff.get("value", 0)) < 1 or int(eff.get("per", 0)) < 1 or eff.has("gate")):
			errs.append("%s: reboot_release is what every foe takes from a reboot's vent for every so much heat: value and per (the heat a step), whole numbers, 1 or more; it has no gate" % where)
		if effect == "shove_behind" and (not (eff.get("value") is int or eff.get("value") is float) or int(eff["value"]) < 1 or int(eff["value"]) > 100 or float(eff["value"]) != floorf(float(eff["value"]))):
			errs.append("%s: shove_behind is the share of a front foe's maximum HP its damaging blow drives into the foe behind, in percent: a whole number, 1 to 100" % where)
		# The Petrels' passives: shield for every point of heat gained (the Storm Petrel's since 17
		# November), and the most rerolls a bank carries (the Giant Petrel's, built 30 October).
		if effect == "shield_per_heat" and (int(eff.get("value", 0)) < 1 or trig != "on_heat_gain"):
			errs.append("%s: shield_per_heat is on_heat_gain's: value, the shield a point of heat gained stands up, 1 or more" % where)
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
		if effect == "seal_form" and (int(eff.get("value", 0)) <= 0 or int(eff.get("heat", 0)) < 0):
			errs.append("%s: seal_form's value is the armour the seal grants, positive, and heat what it runs hotter a turn, not negative" % where)
		if effect == "paradox" and int(eff.get("value", 0)) < 1:
			errs.append("%s: paradox's value is the count that knocks a foe out, at least 1" % where)
		if effect == "grant_keyword" and eff.has("printed"):
			errs.append("%s: 'printed' is gone; a rule written out is its own effect (spillover), never a keyword granted" % where)
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
				errs.append("%s: grant_keyword's number is a positive number for a numbered keyword (Ablate, Cryo, Brittle, Spread, Penetrate, Chain, Purge)" % where)
			# A grant that adds to the entry's own number (the Beam Bazooka's: "Two spreads on the same
			# weapon would combine", Ryan, 19 November), where a grant's number otherwise replaces it.
			if eff.has("adds") and (not (eff["adds"] is bool) or not eff.has("number")):
				errs.append("%s: grant_keyword's adds is true or false, beside its number (what it adds to the entry's own)" % where)
			# An area granted to one debuff (`entry`: the Cryo Flinger's Spread while sealed) carries
			# no number, as a debuff's printed one does: its effects reach those foes, and it deals
			# nothing. Any other area grant says what each foe past the target takes.
			var area := ["cleave", "penetrate"].has(kw)
			var on_debuff := _entry_is_debuff(eff)
			if area and not eff.has("number") and not on_debuff:
				errs.append("%s: a grant of %s says what each foe past the target takes: number" % [where, "Spread" if kw == "cleave" else kw.capitalize()])
			if area and eff.has("number") and on_debuff:
				errs.append("%s: a grant of %s to a debuff carries no number: its effects reach those foes, and it deals nothing" % [where, "Spread" if kw == "cleave" else kw.capitalize()])
			if kw == "chain" and not eff.has("number"):
				errs.append("%s: a grant of Chain says what every other Shocked foe takes: number" % where)
		# An effect scoped to one piece (`entry`) names a component the content holds.
		if eff.has("entry") and not components.has(str(eff["entry"])):
			errs.append("%s: entry names no component ('%s')" % [where, str(eff["entry"])])
		var when := str(eff.get("when", ""))
		if not Effects.supports_when(when):
			errs.append("%s: passive condition '%s' is not implemented by the engine" % [where, when])
		elif when.begins_with("tag_") and not TAGS.has(when.substr(4)):
			errs.append("%s: condition '%s' reads a tag outside the working set (%s)" % [where, when, ", ".join(TAGS)])
		if when == "attacker_status" and eff.has("status"):
			# The status named may be the engine's or one the vocabulary drafts (the Prairie
			# Dog read Brittle from 19 to 21 October, before Brittle was built): a drafted status never holds, so the
			# clause waits inert, and the passive stays built, so the chassis stays dealable.
			var st := str(eff["status"])
			var drafted: bool = vocabulary.has(st) and vocabulary[st].get("category") == "status" and vocabulary[st].get("status") != "implemented"
			if not Effects.STATUS.has(st) and not drafted:
				errs.append("%s: attacker_status names no status the engine or the vocabulary knows ('%s')" % [where, st])
		if trig == "static" and when.begins_with("reach_"):
			errs.append("%s: a static reach change cannot be conditioned on reach (it would chase its own tail)" % where)


## Whether an effect is scoped to one piece (`entry`) that is a debuff: equipment aimed at a foe,
## printing no number (Face.is_debuff's reading of the content's face).
func _entry_is_debuff(eff: Dictionary) -> bool:
	var cid := str(eff.get("entry", ""))
	if cid.is_empty() or not components.has(cid):
		return false
	var fd = components[cid].get("face", {})
	return fd is Dictionary and str(fd.get("kind", "")) == "attack" and int(fd.get("power", 0)) <= 0 \
		and not bool(fd.get("vents_all", false)) and not bool(fd.get("spends_shield", false)) and int(fd.get("fires_hopper", 0)) <= 0 and int(fd.get("power_per_missing", 0)) <= 0


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
## same list). "none" is for what takes no mount and so wears no class: armour panels and vents,
## applied to the whole machine, and a locked piece built into its machine as no class could
## draw it (the four melee pieces, once the blade's: the blade class retired on 15 November,
## when every melee piece left was locked; Ryan: "it's pretty safe to retire the Blade model").
const SHAPES := ["barrel", "twin_barrel", "rack", "dish", "none"]
const SHAPE_NONE := "none"

## The tags a component may wear (the working set, decided 10 and 12 October; the stock pass's
## validator list, 22 October): build flavour shown in the codex, never a rule of their own. A
## module or a passive reads one through a `tag_<tag>` condition, the screen's lunge reads
## `melee` (on a piece with no firing class and no tag that crosses the field: a shotgun fires), and the Cottonmouth's
## drum adds `ballistic` to the shot it fires. The old internal
## filing tags (kinetic, energy, single, support and the rest) are retired; the stock pass's
## landing assigns these by each piece's fantasy.
const TAGS := ["ballistic", "missile", "beam", "plasma", "flame", "arc", "blade", "melee"]

## The sound a component's blow plays, where its shape and face are not enough to say
## (decided 2 October: content carries a label for the effects): `sound`, a word from SOUNDS
## or a list of them. A list means layers (Ryan, 2 October): the first word is the blow and
## every word after it rides on the landing, so the Knuckle of Fury says ["blunt", "plasma"],
## the mass arriving with the hot splash on it. The list is game effects, never gameplay
## properties: it is not derived from keywords or tags and does not feed them (a stretch goal:
## a modification that adds burn or shock could add its layer). Absent, the game derives one
## word: a barrel is a barrel, a twin a twin, a rack a rack, a dish a
## deflector or a coil by its face, an energy barrel a laser and the Arsenal's a plasma.
## Content names only the exceptions.
const SOUNDS := ["barrel", "twin_barrel", "rack", "blade", "blunt", "laser", "plasma", "deflector", "coil"]


## The sound a component's use plays, as layers (the first the blow, each after it riding on
## the landing): its `sound` where content names one, else derived as SOUNDS says. A shield
## is a deflector and a buff a coil, whatever the mount; an attack is its shape, a barrel
## tagged Plasma a plasma and one tagged Beam a laser (by the tags since 2 November, when
## rolled damage went and flat stopped meaning energy); a dish that attacks (the Klaxon's lure) is a coil; an attack with no
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
	var tags: Array = c.get("tags", []) if c.get("tags", null) is Array else []
	if shape == "barrel" and tags.has("plasma"):
		out.append("plasma")
	elif shape == "barrel" and tags.has("beam"):
		out.append("laser")
	elif shape == "dish":
		out.append("coil")
	elif ["barrel", "twin_barrel", "rack"].has(shape):
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
	# stocks components up to its own tier at tiers one and two, and a tier three to tier two (the
	# bible's tiers row; the validator's half since 11 November, with the Skua's Pod), so a
	# tier-three component is only ever found.
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
			if components.has(cid) and not fixed_ids.has(cid) and ct > stock_tier(own):
				errs.append("chassis %s: stocks %s at tier %d, and a tier-%d chassis stocks up to tier %d" % [id, cid, ct, own, stock_tier(own)])
	for id in chassis.keys():
		var c: Dictionary = chassis[id]
		var where := "chassis %s" % id
		# designation: the maker's long name on the spec plate (Ryan, 26 September: every
		# chassis carries one; the bible's section 7 row says the shape per maker).
		for key in ["name", "designation", "codex", "flavour", "hull", "shield", "armour", "movespeed", "hardpoints", "loadout", "size", "module_slots"]:
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
		if c.has("recharge_field"):
			errs.append("%s: recharge_field is gone (the long wall brief, docs/briefs/long_wall_build.md 3.6): the shield is full as every fight opens and nothing returns on the map" % where)
		if int(c.get("armour", 0)) < 0:
			errs.append("%s: armour cannot be negative" % where)
		if c.has("cooling") or c.has("shield_regen"):
			errs.append("%s: cooling and shield_regen are gone from a chassis (the reboot, folded in 15 November): nothing cools or regenerates by itself, and a module, a passive or a status grants either" % where)
		if c.has("status") and not VALID_STATUS.has(str(c["status"])):
			errs.append("%s: status is one of %s (planned: back in design and undealt)" % [where, ", ".join(VALID_STATUS)])
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
		# A folded die (the Clydesdale's batteries, 11 November): two batteries of the passive's
		# number fill its hardpoints, and a fixed piece turns it, or it could never turn.
		var passive_c = c.get("passive", null)
		var fold := 0
		if passive_c is Dictionary:
			for eff in passive_c.get("effects", []):
				if eff is Dictionary and str(eff.get("effect", "")) == "fold_die":
					fold = int(eff.get("value", 0))
		if fold > 0:
			if hp != 2 * fold:
				errs.append("%s: a die folded into batteries of %d takes %d hardpoints, not %d" % [where, fold, 2 * fold, hp])
			var turns := false
			for cid in fixed:
				if bool(components.get(cid, {}).get("face", {}).get("turns_die", false)):
					turns = true
			if not turns:
				errs.append("%s: a folded die needs a fixed piece that turns it (turns_die)" % where)
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
		if c.has("branches"):
			_validate_branches(where, c, errs)


## An upgrade's branches (the bible's tiers row; the Storm Petrel the first to carry them, Ryan,
## 17 November): two directions, each a step a pick, as deep as the machine picks (a tier one's
## two steps, a tier two's one, a tier three none). A step is a description and the effects it
## lays, one passive's worth: a tweak to the locked pieces or the passive, as many as it needs, each
## effect on a piece scoped to it (`entry`, one of the chassis's fixed pieces), and never a stat
## ("more the job for Modules").
func _validate_branches(where: String, c: Dictionary, errs: Array[String]) -> void:
	var dirs = c["branches"]
	var tier := int(c.get("tier", 1))
	var deep := 3 - tier
	if not (dirs is Array) or (dirs as Array).size() != 2:
		errs.append("%s: branches are two directions (Ryan's shape: two directions, each a step a pick)" % where)
		return
	if deep <= 0:
		errs.append("%s: a tier %d chassis arrives at the top tier and picks no branch" % [where, tier])
		return
	var fixed: Array = c.get("fixed", [])
	var ids := {}
	for d in dirs:
		if not (d is Dictionary) or str(d.get("id", "")).is_empty() or str(d.get("name", "")).strip_edges().is_empty() or not (d.get("steps") is Array):
			errs.append("%s: a direction is {id, name, steps}" % where)
			continue
		var dw := "%s branch %s" % [where, str(d["id"])]
		if ids.has(str(d["id"])):
			errs.append("%s: two directions share the id" % dw)
		ids[str(d["id"])] = true
		for k in (d as Dictionary).keys():
			if not ["id", "name", "steps", "design"].has(str(k)):
				errs.append("%s: '%s' is no key of a direction (id, name, steps, design)" % [dw, str(k)])
		var steps: Array = d["steps"]
		if steps.size() != deep:
			errs.append("%s: a tier %d machine picks %d time%s, so a direction is %d step%s deep, not %d" % [dw, tier, deep, "" if deep == 1 else "s", deep, "" if deep == 1 else "s", steps.size()])
		for i in range(steps.size()):
			var st = steps[i]
			var sw := "%s step %d" % [dw, i + 1]
			if not (st is Dictionary):
				errs.append("%s: a step is {description, effects}" % sw)
				continue
			for k in (st as Dictionary).keys():
				if not ["description", "effects", "design"].has(str(k)):
					errs.append("%s: '%s' is no key of a step (description, effects, design)" % [sw, str(k)])
			_validate_passive(sw, {"id": "branch", "name": str(d["name"]), "description": st.get("description", ""), "effects": st.get("effects", [])}, errs)
			if str(st.get("description", "")).strip_edges().is_empty():
				errs.append("%s: a step says what it does (description)" % sw)
			for eff in st.get("effects", []):
				if not (eff is Dictionary):
					continue
				if ["add_stat", "multiply_stat"].has(str(eff.get("effect", ""))):
					errs.append("%s: a branch is never a stat (Ryan: \"more the job for Modules\")" % sw)
				# A step tweaks the locked pieces (`entry`) or the passive (no entry: Ryan, 18 November,
				# of the Buzzard, "since this passive has numbers in it, I think one direction buffs the
				# passive, one buffs the cannon"), as many as it needs (19 November: "Things that limit
				# design space should never be a rule").
				if eff.has("entry") and not fixed.has(str(eff["entry"])):
					errs.append("%s: a step tweaks a locked piece, %s, or the passive: an entry names one of them" % [sw, ", ".join(fixed) if not fixed.is_empty() else "none on this chassis"])


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
		# A move's word for whom it goes for (Ryan, 17 November: "the heat target is a property
		# of the attack, not the dragon itself") and its condition (2 October), checked whatever
		# its status. The word is for a move aimed at one machine; and a blow at every machine
		# takes no step aimed at one, since it draws no pick and nothing would show whom.
		var steps_read := true
		for list in STEP_LISTS:
			if a.has(list) and not (a[list] is Array and (a[list] as Array).all(func(st) -> bool: return st is Dictionary)):
				steps_read = false
		if a.has("aim") and not Foe.AIMS.has(str(a["aim"])):
			errs.append("%s: aim must be one of %s, got '%s'" % [aw, ", ".join(Foe.AIMS), str(a["aim"])])
		elif a.has("aim") and steps_read and not Foe.lands_on_one(a):
			errs.append("%s: aim is for a move aimed at one machine; a move at every machine or at nobody draws no pick" % aw)
		if steps_read and str(a.get("kind", "")) == "attack" and Array(a.get("keywords", [])).has("all"):
			for st in Foe.extra_steps(a):
				if not Foe.UNTARGETED_EFFECTS.has(str(st.get("effect", ""))) and not Foe.effect_kind(str(st.get("effect", ""))).is_empty():
					errs.append("%s: a blow at every machine draws no pick, so no step of it may be aimed at one machine (%s)" % [aw, str(st.get("effect", ""))])
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
		# A borrowed swing (30 October): an attack whose number is a status of the foe's own, what
		# it took (Appropriated), so it comes only as the follow-up of a move that takes.
		if a.has("power"):
			var held := str(a["power"])
			if not POWER_STATUSES.has(held) or str(a.get("kind", "attack")) != "attack":
				errs.append("%s: power is an attack's, and names the status its number is: one of %s" % [aw, ", ".join(POWER_STATUSES.keys())])
			else:
				var taken_by := false
				for o in acts:
					if o is Dictionary and str(o.get("then", "")) == str(a.get("id", "")) and Foe.does(o, str(POWER_STATUSES[held])):
						taken_by = true
				if not taken_by:
					errs.append("%s: a borrowed swing (power %s) is the follow-up of a move that takes (%s among its steps); name it in that move's then" % [aw, held, str(POWER_STATUSES[held])])
		# What a move does also (16 November: a move is a short list of steps): each a special's
		# effect with the fields it reads, after the move's first step, whatever that is. And
		# what a blow does before it lands (`before`, 18 November: the Pilgrim's knife purges
		# first), a list of the same shape on an attack alone.
		if a.has("before") and str(a.get("kind", "")) != "attack":
			errs.append("%s: before lists what a blow does before it lands; it belongs to an attack action" % aw)
		for list in STEP_LISTS:
			if not a.has(list):
				continue
			if not (a[list] is Array) or (a[list] as Array).is_empty():
				errs.append("%s: %s lists what the move does %s, each an object with its effect" % [aw, list, "before its blow lands" if list == "before" else "after its first step"])
			else:
				for st in a[list]:
					if not (st is Dictionary) or str(st.get("effect", "")).is_empty():
						errs.append("%s: each step of %s is an object that names its effect" % [aw, list])
						continue
					var sw := "%s %s %s" % [aw, list, str(st["effect"])]
					for key in (st as Dictionary).keys():
						if not ALSO_KEYS.has(str(key)):
							errs.append("%s: a step knows %s, got '%s'" % [sw, ", ".join(ALSO_KEYS), str(key)])
					if Foe.effect_kind(str(st["effect"])).is_empty():
						errs.append("%s: a step's effect is a special's, one of %s" % [sw, ", ".join(_all_effects())])
					elif str(a.get("status", "")) == "implemented":
						_validate_effect(sw, st, str(st["effect"]), errs)
		if str(a.get("status", "")) == "implemented":
			if str(a.get("kind", "")) != "attack":
				# A defend, buff or debuff names an effect the engine runs and the fields it reads.
				var kind := str(a.get("kind", ""))
				var effect := str(a.get("effect", ""))
				if not Foe.ACTION_EFFECTS.get(kind, []).has(effect):
					errs.append("%s: a %s action's effect must be one of %s, got '%s'" % [aw, kind, ", ".join(Foe.ACTION_EFFECTS.get(kind, [])), effect])
				_validate_effect(aw, a, effect, errs)
				# A cleanse's condition, if any, is the one it needs (28 October).
				if effect == "cleanse":
					for w in Foe.whens_of(a):
						if str(w) != "ally_marked":
							errs.append("%s: a cleanse's condition, if any, is ally_marked, got '%s'" % [aw, str(w)])
				if int(a.get("weight", 1)) < 1:
					errs.append("%s: value cannot be negative; count and weight are at least 1" % aw)
				for key in ["factor", "strikes", "keywords", "countdown", "aloft"] + Foe.NUMBERED_RIDERS:
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
				if a.has("countdown") and (int(a["countdown"]) < 1 or int(a["countdown"]) > 5):
					errs.append("%s: countdown is the rounds a move gathers before it lands, 1 to 5" % aw)
				# A move that climbs takes its foe out of the dice's reach while it gathers (16
				# November, the Roc's Stoop): it gathers a round, so the round it is announced stays
				# the window, and no longer, so no foe is out of reach two turns running.
				if a.has("aloft") and (not (a["aloft"] is bool) or int(a.get("countdown", 0)) != 1):
					errs.append("%s: aloft is true on a blow that gathers one round (countdown 1): its foe cannot be targeted while it climbs" % aw)
				for k in a.get("keywords", []):
					if Foe.SPECIALS_ONLY.has(str(k)):
						errs.append("%s: '%s' is a special, never a rider on a blow (28 October)" % [aw, k])
					elif not Foe.ATTACK_KEYWORDS.has(str(k)):
						errs.append("%s: unknown attack keyword '%s' (foe attacks know %s)" % [aw, k, ", ".join(Foe.ATTACK_KEYWORDS)])
				# A rider that lays stacks says how many (24 October, as the player's Ablate N does).
				for k in Foe.NUMBERED_RIDERS:
					var carried := Array(a.get("keywords", [])).has(k)
					if carried and int(a.get(k, 0)) <= 0:
						errs.append("%s: a %s rider says its stacks: %s, a positive number" % [aw, k, k])
					if a.has(k) and not carried:
						errs.append("%s: %s (the stacks) rides with the %s keyword" % [aw, k, k])
					if carried and _halves(k) and int(a.get(k, 0)) < HALVING_MINIMUM:
						errs.append("%s: a %s rider lays a status that halves, so it says %d at the least: one stack is gone at its first halving" % [aw, k, HALVING_MINIMUM])
	if implemented_attacks < 1:
		errs.append("%s: needs at least one implemented attack action" % where)


## What a fall's special (`on_death.act`) may carry.
const FALL_ACT_KEYS := ["name", "effect", "value", "count", "rounds", "text", "also"]


## One effect of a fall, its special or a step after: one of those a fall may do
## (Foe.FALL_EFFECTS), by that effect's own fields.
func _validate_fall_effect(aw: String, a: Dictionary, errs: Array[String]) -> void:
	var effect := str(a.get("effect", ""))
	if not Foe.FALL_EFFECTS.has(effect):
		errs.append("%s: a fall may do one of %s, got '%s' (never what its own body would carry, a summon, a swallow, a purge or an Expose)" % [aw, ", ".join(Foe.FALL_EFFECTS), effect])
	else:
		_validate_effect(aw, a, effect, errs)


## What a fall does also, after its blow or its special: steps as a move's are (`also`), each
## an effect a fall may do.
func _validate_fall_steps(aw: String, a: Dictionary, errs: Array[String]) -> void:
	if not a.has("also"):
		return
	if not (a["also"] is Array) or (a["also"] as Array).is_empty():
		errs.append("%s: also lists what the fall does after its first step, each an object with its effect" % aw)
		return
	for st in a["also"]:
		if not (st is Dictionary) or str(st.get("effect", "")).is_empty():
			errs.append("%s: each step of also is an object that names its effect" % aw)
			continue
		var sw := "%s also %s" % [aw, str(st["effect"])]
		for key in (st as Dictionary).keys():
			if not ALSO_KEYS.has(str(key)):
				errs.append("%s: a step knows %s, got '%s'" % [sw, ", ".join(ALSO_KEYS), str(key)])
		_validate_fall_effect(sw, st, errs)


## The statuses a move's `power` may name, each with the step that grants it: a borrowed swing's
## number is what its foe took (Appropriated, the `appropriate` step).
const POWER_STATUSES := {"appropriated": "appropriate"}
## What a step of `also` may carry beside its effect.
const ALSO_KEYS := ["effect", "value", "foe", "count", "rounds"]
## The lists of steps a move may carry beside itself: what its blow does before it lands, and
## what the move does also.
const STEP_LISTS := ["before", "also"]


## Every effect a special or a step may name, across the kinds.
static func _all_effects() -> Array:
	var out: Array = []
	for k in Foe.ACTION_EFFECTS.keys():
		out.append_array(Foe.ACTION_EFFECTS[k])
	return out


## One effect's own fields, as the engine reads them: a special's, or a step's of a move's
## `also`, by the same rules. `a` carries the effect's fields (value, foe, count, rounds).
func _validate_effect(aw: String, a: Dictionary, effect: String, errs: Array[String]) -> void:
	# A priming and a regrowth say their number; a Barrier and a Ward say none (28 October).
	if (effect == "prime" or effect == "regenerate" or effect == "golden") and int(a.get("value", 0)) < 1:
		errs.append("%s: %s says its number: value, 1 or more" % [aw, effect])
	# A golden rage (4 November) lasts the rounds it says, 1 to 5, three unsaid.
	if effect == "golden" and a.has("rounds") and (int(a["rounds"]) < 1 or int(a["rounds"]) > 5):
		errs.append("%s: golden's rounds are the rounds the rage lasts, 1 to 5" % aw)
	if (effect == "barrier" or effect == "ward_all" or effect == "appropriate" or effect == "phase" or effect == "unready_all") and a.has("value"):
		errs.append("%s: %s takes no value" % [aw, effect])
	# A cleanse (28 October) takes every mark the team laid, so it says no number.
	if effect == "cleanse" and a.has("value"):
		errs.append("%s: a cleanse takes every mark the team laid: no value" % aw)
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
	if int(a.get("value", 0)) < 0 or int(a.get("count", 1)) < 1:
		errs.append("%s: value cannot be negative; count and weight are at least 1" % aw)
	# What an effect lays, it says: the stacks, or the rerolls a theft takes (24 October).
	if ["ablate", "scorch_all", "corrupt_all", "drain_rerolls"].has(effect) and int(a.get("value", 0)) <= 0:
		errs.append("%s: %s says what it lays: value, a positive number" % [aw, effect])
	# A swallow (30 October) says the rounds its machine is out, 1 to 3: hard control on
	# the team, held short.
	if effect == "swallow" and (int(a.get("value", 0)) < 1 or int(a.get("value", 0)) > 3):
		errs.append("%s: a swallow's value is the rounds its machine is out, 1 to 3" % aw)
	if _halves(effect) and int(a.get("value", 0)) < HALVING_MINIMUM:
		errs.append("%s: %s lays a status that halves, so its value is %d at the least: one stack is gone at its first halving" % [aw, effect, HALVING_MINIMUM])


## What a foe's move lays that halves, by the rider or the special that lays
## it (Brittle on a machine, Empowered on its own side), and the least such a move may say
## (Ryan, 16 November: "Buffs and debuffs that decay at end of round should just have a minimum
## of 2"). One stack halves to none as the round it was laid in ends, so a rallier's own share
## and a Brittle 1 were gone before the foes' next turn. His exit, for a move several foes may
## roll at once: "we just tweak the ability to say something like "apply 2 if none, otherwise
## 1."" Read off the status's own clock, so a status that stops halving leaves the rule.
const HALVING_LAID := {"brittle": "brittled_mech", "rally": "kindled"}
const HALVING_MINIMUM := 2
static func _halves(move: String) -> bool:
	return HALVING_LAID.has(move) and Effects.decays_to_zero(Effects.STATUS.get(str(HALVING_LAID[move]), {}))


## A rank-and-file unit's battlefield role (Ryan, 9 November: a unit is made for a pusher's, a
## flanker's or a hunter's fight and tuned for it, so a goblin tuned for three machines is not
## the same goblin in a pack sent at one): a pusher's unless its entry says otherwise. A pusher
## stands in the formations that march on the wall, a flanker is a duel for one machine in a
## patrol, a hunter is a hunting pack's line. Internal: nothing shows it, the validator holds
## the compositions to it (_validate_roles). Elites, bosses and their escorts carry none.
const FOE_ROLES := ["pusher", "hunter", "flanker"]
const ROLE_DEFAULT := "pusher"


func role_of(foe_id: String) -> String:
	return str(foes.get(foe_id, {}).get("role", ROLE_DEFAULT))


## A patrol or a formation is held to its members' roles (the formation pass, 10 November). A
## pack that hunts is its lead's line and what keeps up with it (Ryan: "A pack of wolves and
## things that keep up with the wolves makes sense"): a hunter leads it, and every member moves
## at its lead's pace or faster and flies if it does. A formation that pushes fields pushers, a
## patrol that pushes fields flankers ("One spooky flanker revenant or whatever is a more
## interesting duel for a Skua or Kite than the Skua or Kite just mowing down less goblins").
## A crossing is deliberate, and the composition says why under design.crossing ("I'm not saying
## we can't cross lines between battlefield roles, just that I don't want it to come across as
## lazy"). Elites and escorts are written by other rules.
func _validate_roles(cw: String, c: Dictionary, size: String, errs: Array[String]) -> void:
	var cells: Array = []
	for r in ["front", "back"]:
		var row = c.get(r, [])
		if row is Array:
			for x in row:
				if x is String and foes.has(x):
					cells.append(str(x))
	if cells.is_empty():
		return
	var d = c.get("design", null)
	var crossing := str(d.get("crossing", "")).strip_edges() if d is Dictionary else ""
	if c.has("hunts"):
		var lead := str(c.get("lead", cells[0]))
		if not foes.has(lead):
			return
		if role_of(lead) != "hunter" and crossing.is_empty():
			errs.append("%s: a pack that hunts is led by a hunter; %s is a %s (say why under design.crossing)" % [cw, lead, role_of(lead)])
		var pace := int(foes[lead].get("movespeed", Unit.PACK_MOVE))
		var flies := bool(foes[lead].get("winged", false))
		for x in cells:
			if int(foes[x].get("movespeed", Unit.PACK_MOVE)) < pace:
				errs.append("%s: %s does not keep up with its lead (%s moves %d): a hunter is its line and what keeps up with it" % [cw, x, lead, pace])
			elif flies and not bool(foes[x].get("winged", false)):
				errs.append("%s: %s cannot follow its lead %s over walls and water" % [cw, x, lead])
		return
	var want := "pusher" if size == "formation" else "flanker"
	if not crossing.is_empty():
		return
	var said := {}
	for x in cells:
		if role_of(x) != want and not said.has(x):
			said[x] = true
			errs.append("%s: %s is a %s in a %s's %s (a crossing says why under design.crossing)" % [cw, x, role_of(x), want, size])


func _validate_foes(errs: Array[String]) -> void:
	for id in foes.keys():
		var f: Dictionary = foes[id]
		var where := "foe %s" % id
		if f.has("role") and not FOE_ROLES.has(str(f["role"])):
			errs.append("%s: role is one of %s (absent: a pusher's)" % [where, ", ".join(FOE_ROLES)])
		for key in ["name", "codex", "flavour", "actions", "hp", "attack", "rank"]:
			if not f.has(key):
				errs.append("%s: missing %s" % [where, key])
		_validate_design(where, f, errs)
		if int(f.get("hp", 0)) <= 0:
			errs.append("%s: hp must be positive" % where)
		if int(f.get("armour", 0)) < 0:
			errs.append("%s: armour cannot be negative" % where)
		if f.has("resist") and int(f.get("resist", 0)) < 0:
			errs.append("%s: resist is the Numbed it recovers from a stun with, a count, never negative" % where)
		if f.has("armour_step"):
			# A boss whose kit is armour grows it a tier (31 October): only a foe that scales in
			# place with the tier, a domain's boss, one of the party or an elite (2 November),
			# carries a step.
			if not (f["armour_step"] is float or f["armour_step"] is int) or int(f["armour_step"]) < 1:
				errs.append("%s: armour_step must be a whole number of at least 1" % where)
			elif not (is_boss(str(id)) or bool(f.get("hero", false)) or f.has("promotes") or bool(f.get("elite", false))):
				errs.append("%s: armour_step only on a foe that scales with the tier (a boss, a hero, an elite)" % where)
		# A rage (the Goblin Nob's): its own from the fight's start, every shield, vent or
		# equipment entry the team spends stacking that much Enraged on it while it stands.
		if f.has("rage") and (not (f["rage"] is float or f["rage"] is int) or int(f["rage"]) < 1 or float(f["rage"]) != floorf(float(f["rage"]))):
			errs.append("%s: rage is the Enraged a team's shield, vent or equipment spend stacks on it: a whole number, 1 or more" % where)
		# A drain (the Vampire Lord's): an Ability on the unit, every blow of its own regrowing
		# what it took from the hull; a rider on a blow until 16 November.
		if f.has("drains") and not (f["drains"] is bool and f["drains"]):
			errs.append("%s: drains is true or left out: every blow of the foe's regrows what it takes from a hull" % where)
		# An immunity (Ryan, 15 November: "not as a blanket for all bosses, but for ones who need
		# it for their fight to actually do something"): an Ability on the unit, a Suppress or a
		# Disrupt that never lands on it, always or while the move it names gathers.
		if f.has("immune"):
			var im = f["immune"]
			if not (im is Dictionary) or (im as Dictionary).is_empty():
				errs.append("%s: immune is an object: %s, each true or the id of a move of its own that gathers" % [where, " or ".join(Foe.IMMUNITIES)])
			else:
				for k in (im as Dictionary).keys():
					if not Foe.IMMUNITIES.has(str(k)):
						errs.append("%s: immune knows %s, got '%s'" % [where, ", ".join(Foe.IMMUNITIES), str(k)])
					elif not (im[k] is bool and im[k]):
						var gathers := false
						for a in f.get("actions", []):
							if a is Dictionary and str(a.get("id", "")) == str(im[k]) and int(a.get("countdown", 0)) > 0 and str(a.get("status", "")) == "implemented":
								gathers = true
						if not gathers:
							errs.append("%s: immune %s is true, or the id of a move of its own that gathers (a countdown), got '%s'" % [where, str(k), str(im[k])])
		# A foe has no aim of its own (Ryan, 17 November: "the heat target is a property of the
		# attack, not the dragon itself"): the word goes on the move.
		if f.has("aim"):
			errs.append("%s: a foe has no aim of its own; the word for whom an attack goes for is its move's (aim on the action)" % where)
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
			errs.append("%s: 'injures' is gone; a move that destroys a component carries the destroy keyword" % where)
		if f.has("stun_resist"):
			errs.append("%s: no foe resists a suppress by nature (10 October); drop stun_resist" % where)
		# The rings are gone and the hunt is a composition's (Ryan, 8 November: "The composition
		# should say if it hunts, not the units"): a foe carries neither, so the old fields are refused.
		if f.has("zone"):
			errs.append("%s: zone is gone (8 November): no foe carries a ring; a hunter catches at the engage range, %d (Unit.ENGAGE_RANGE)" % [where, Unit.ENGAGE_RANGE])
		for key in ["behaviour", "hunts"]:
			if f.has(key):
				errs.append("%s: %s is gone from the foe (8 November): a composition says whether its pack hunts (hunts)" % [where, key])
		if f.has("movespeed") and (int(f["movespeed"]) < 1 or int(f["movespeed"]) > MAX_MOVE):
			errs.append("%s: movespeed is in hexes, 1 to %d" % [where, MAX_MOVE])
		# A hero only ever commands the boss unit, which holds its hex and never hunts
		# (Ryan, 28 October, of the Thief's move: "it's a boss so it doesn't need it").
		if bool(f.get("hero", false)):
			for key in ["movespeed"]:
				if f.has(key):
					errs.append("%s: a hero only commands the boss unit, which holds its hex and never walks; drop %s" % [where, key])
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
		for key in ["strikes"]:
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
						elif str(k) == "expose":
							errs.append("%s: on_death blow: an Expose is announced, one machine at a time, so a fall lays none" % where)
						elif not Foe.ATTACK_KEYWORDS.has(str(k)):
							errs.append("%s: on_death blow: unknown attack keyword '%s'" % [where, k])
					_validate_fall_steps("%s: on_death blow" % where, b, errs)
			if od is Dictionary and od.has("act"):
				# A fall that is one special in a blow's place (16 November: a fall is a short list
				# of steps, as a move is): its name, its effect and that effect's own fields.
				var act = od["act"]
				if od.has("blow"):
					errs.append("%s: on_death is a blow or an act, the fall's first step, never both; what it does after goes in that one's also" % where)
				elif not (act is Dictionary) or str(act.get("name", "")).is_empty() or str(act.get("effect", "")).is_empty():
					errs.append("%s: on_death act is a special: a name and an effect" % where)
				else:
					var aw := "%s: on_death act" % where
					for key in (act as Dictionary).keys():
						if not FALL_ACT_KEYS.has(str(key)):
							errs.append("%s knows %s, got '%s'" % [aw, ", ".join(FALL_ACT_KEYS), str(key)])
					_validate_fall_effect(aw, act, errs)
					_validate_fall_steps(aw, act, errs)
			if od is Dictionary and (od.has("blow") or od.has("act")) and not od.has("summon"):
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
	_validate_ramp_gates(errs)
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
			errs.append("%s: compositions is a list of {id, size, tiers, front, back}" % where)
			comps = []
		var comp_ids := {}
		var tier_one := {"formation": false, "patrol": false}
		for c in comps:
			if not (c is Dictionary):
				errs.append("%s: each composition is an object" % where)
				continue
			var cw := "%s composition %s" % [where, str(c.get("id", "?"))]
			for key in ["id", "size", "front", "back"]:
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
			if c.has("members") or c.has("layout"):
				errs.append("%s: members and layout are gone (8 November); the grid, front and back, is the whole declaration" % cw)
			_validate_grid(cw, c, size, errs)
			# Exposed on a machine is a tier-two foe's at the least among the rank and file (Ryan, 15
			# November: "only in formations that feel thematic and fair, so that the player has tools
			# to answer by that point"): nothing dealt at tier one holds a foe of the line whose move
			# lays it. An elite is held to no tier, as a boss is not (Ryan, 16 November: "I think
			# elites can hold any mechanic at any tier, as a boss can"); a boss and its parts stand
			# in no grid, so the hold never reached them.
			if tiers is Array and composition_tiers(c).has(1) and c.get("front", null) is Array and c.get("back", null) is Array:
				var told := {}
				for cell in layout_cells(c):
					if is_elite(str(cell)) or is_boss(str(cell)):
						continue
					for a in foes.get(str(cell), {}).get("actions", []):
						if a is Dictionary and str(a.get("status", "implemented")) != "planned" and Foe.exposes(a) and not told.has(str(cell)):
							told[str(cell)] = true
							errs.append("%s: %s lays Exposed, and none of the rank and file dealt at tier one may (the player has no answer to it yet); an elite and a boss may at any tier" % [cw, str(cell)])
			# The formation pass's fields (10 November): what the player must answer, written down on
			# every patrol and formation (internal, under design, never shown), and the roles.
			if c.has("design") and not (c["design"] is Dictionary):
				errs.append("%s: design is an object (question, crossing, note)" % cw)
			elif size == "patrol" or size == "formation":
				var cd = c.get("design", null)
				if not (cd is Dictionary) or str(cd.get("question", "")).strip_edges().is_empty():
					errs.append("%s: design.question says what the player must answer (every patrol and formation poses one)" % cw)
				_validate_roles(cw, c, size, errs)
			# The long wall brief's fields (section 6): the squad it is intended for and the ramp gate.
			if c.has("squad"):
				var sv = c["squad"]
				if not ((sv is int or sv is float) and int(sv) == sv and int(sv) >= 1 and int(sv) <= 4):
					errs.append("%s: squad is 1, 2, 3 or 4, the machines it is intended for" % cw)
			if c.has("ramp"):
				var g = c["ramp"]
				if not (g is Array) or (g as Array).size() != 2 or not (g as Array).all(func(x) -> bool: return x is float or x is int) \
						or int(g[0]) < 0 or int(g[0]) > int(g[1]) or int(g[1]) > Ramp.TOP:
					errs.append("%s: ramp is [lo, hi], the Convergences it is dealt at, 0 <= lo <= hi <= %d" % [cw, Ramp.TOP])
			if c.has("hunts"):
				# Whether its pack hunts, and whom (Ryan, 8 November: "The composition should say if
				# it hunts, not the units"); an escort walks with its boss, which never hunts.
				if not HUNT_CAVEATS.has(str(c["hunts"])) or not (c["hunts"] is String):
					errs.append("%s: hunts is the caveat its pack hunts by: %s" % [cw, ", ".join(HUNT_CAVEATS)])
				if size == "escort":
					errs.append("%s: an escort walks with its boss, which never hunts; drop hunts" % cw)
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

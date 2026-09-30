class_name ContentDB
extends RefCounted

## Loads content/*.json, validates it against the design rules, and builds runtime objects.
## Content is authored fantasy-first in JSON; the validator is the vetting pass that runs
## in the test suite, so a concept that breaks a rule fails the build.

const DIR := "res://content/"

# Design knobs. Loosen or tighten here; the validator and the bible should agree.
const MAX_AUTHORED_KEYWORDS := 3    # per authored face; upgrades may exceed this at runtime
const MIN_DIE := 4
const MAX_DIE := 10                 # the Clydesdale carries nine (Ryan, 28 September); ten leaves it room
const MAX_PASSIVE_EFFECTS := 3      # effects in one passive; a benefit and its cost is one passive
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
var makers: Dictionary = {}
var categories: Array = []
## Machine names from the properties our designs sit nearest (content/reserved_names.json:
## every BattleTech 'Mech, Heavy Gear, Warhammer 40k, Halo), keyed by their normalised form
## (see normalise_name) with "Name (a BattleTech 'Mech)" for the message. A chassis nickname
## or id that lands on one fails validation (Ryan, 28 September: ours or a homage, never a copy).
var reserved_names: Dictionary = {}
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
	var c := _read(dir + "chassis.json")
	chassis = _index(c)
	makers = {}
	for m in c.get("makers", []):
		makers[m["id"]] = m
	components = _index(_read(dir + "components.json"))
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
		f.fixed = fixed_ids.has(cid)
		die.faces.append(f)
	for i in range(maxi(0, hardpoints - loadout_ids.size())):
		die.faces.append(Face.empty_slot())
	return die


func make_mech(chassis_id: String, uid: int = 0, at: Vector2i = Vector2i.ZERO) -> Unit:
	var c: Dictionary = chassis[chassis_id]
	var u := Unit.mech(uid, str(c["name"]), at, int(c.get("movespeed", 3)))
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
	u.die = build_die(c.get("fixed", []), c.get("loadout", []), u.hardpoints)
	u.chassis_id = chassis_id
	var p = c.get("passive", null)
	if p is Dictionary:
		u.passive = p
		u.grant_passive(p, "chassis")
	# Fitted components bring their own passives; a destroyed one keeps its bonuses only.
	for cid in c.get("fixed", []) + c.get("loadout", []):
		var cp = components.get(cid, {}).get("passive", null)
		if cp is Dictionary:
			u.grant_passive(cp, cid, cid)
	return u


func component_name(cid: String) -> String:
	return str(components.get(cid, {}).get("name", cid))


func make_foe(foe_id: String) -> Foe:
	var d: Dictionary = foes[foe_id]
	var f := Foe.make(str(d["name"]), int(d["hp"]), int(d["attack"]), str(d.get("rank", "front")) == "back")
	f.size = int(d.get("size", 1))
	f.stun_resist = clampi(int(d.get("stun_resist", 0)), 0, 100)
	var acts: Array = []
	for a in d.get("actions", []):
		if str(a.get("status", "")) != "implemented":
			continue
		var kind := str(a.get("kind", "attack"))
		if kind == "attack":
			acts.append({"id": str(a.get("id", "attack")), "name": str(a.get("name", "Attack")), "kind": "attack", "factor": float(a.get("factor", 1.0)),
				"strikes": int(a.get("strikes", 1)), "weight": int(a.get("weight", 1)), "keywords": Array(a.get("keywords", [])), "text": str(a.get("text", ""))})
		else:
			# A defend, buff or debuff: its effect and the fields it reads (Foe.ACTION_EFFECTS).
			var act := {"id": str(a.get("id", kind)), "name": str(a.get("name", kind.capitalize())), "kind": kind, "effect": str(a.get("effect", "")),
				"value": int(a.get("value", 0)), "weight": int(a.get("weight", 1)), "text": str(a.get("text", ""))}
			if a.has("foe"):
				act["foe"] = str(a["foe"])
			if a.has("count"):
				act["count"] = int(a["count"])
			acts.append(act)
	# The first attack leads, so a foe's opening intent is its blow.
	for i in range(acts.size()):
		if str(acts[i].get("kind", "")) == "attack" and i > 0:
			var lead: Dictionary = acts.pop_at(i)
			acts.insert(0, lead)
			break
	if not acts.is_empty():
		f.actions = acts
		f.action = acts[0]
	f.content_id = foe_id
	return f


## Codex text for a foe: its codex entry, numbers, implemented actions, and its quote. Nothing
## from `design` is ever read here.
func codex_for_foe(f: Foe) -> Dictionary:
	var d: Dictionary = foes.get(f.content_id, {})
	var fac: Dictionary = factions.get(str(d.get("faction", "")), {})
	var stats := "HP %d // ATK %d // %s RANK" % [f.hp_max, f.attack, "BACK" if f.prefers_back else "FRONT"]
	if f.is_massive():
		stats += " // MASSIVE"
	var acts: Array[String] = []
	for a in d.get("actions", []):
		if str(a.get("status", "")) != "implemented":
			continue
		var head := "%s // %s" % [str(a.get("name", "")).to_upper(), str(a.get("kind", "")).to_upper()]
		if str(a.get("kind", "")) == "attack":
			# The resulting number, never the factor: "Jaw Rend 15", not "1.5x".
			head += " %d" % f.damage_of(a)
			if int(a.get("strikes", 1)) > 1:
				head += " ×%d" % int(a["strikes"])
			for k in a.get("keywords", []):
				head += " // %s" % str(k).to_upper()
		acts.append("%s\n  %s" % [head, f.text_of(a)])
	var faction_name := str(fac.get("name", "")).strip_edges()
	if faction_name.is_empty():
		faction_name = str(d.get("faction", "")).capitalize()
	return {
		"title": f.display_name,
		"subtitle": faction_name.to_upper(),
		"body": str(d.get("codex", "")),
		"stats": stats,
		"stat_items": [["hp", str(f.hp_max)], ["attack", str(f.attack)],
			["rank", "BACK" if f.prefers_back else "FRONT"]] + ([["size", "MASSIVE"]] if f.is_massive() else []),
		"actions": "\n".join(acts),
		"passive": "",
		"faces": [],
		"current": -1,
		"flavour": str(d.get("flavour", "")),
		"sprite_id": f.content_id,
	}


## Codex text for a mech: chassis codex, maker, numbers, faces (for a visual list), passive,
## and flavour.
func codex_for_unit(u: Unit) -> Dictionary:
	var c: Dictionary = chassis.get(u.chassis_id, {})
	var maker: Dictionary = makers.get(str(c.get("maker", "")), {})
	# The codex is the machine's base state with its battle rewards, never its combat effects
	# (Ryan, 26 September): every number is asked up to the BATTLE scope, and the list below
	# carries loadout and battle modifiers only; the hold popup in the fight has the rest.
	var shield_max := Effects.stat(u, "shield", Effects.BATTLE)
	var hull_max := Effects.stat(u, "hull", Effects.BATTLE)
	var armour := Effects.stat(u, "armour", Effects.BATTLE)
	var heat_max := Effects.stat(u, "heat", Effects.BATTLE)
	var recharge := Effects.stat(u, "recharge", Effects.BATTLE)
	var cooling := Effects.stat(u, "cooling", Effects.BATTLE)
	var move := Effects.stat(u, "move", Effects.BATTLE)
	var stats := "SHIELD %d (+%d A PHASE OUT OF COMBAT) // HULL %d // ARMOUR %d // HEAT %d (-%d A TURN) // MOVE %d // %d HARDPOINTS // D%d" % [
		shield_max, recharge, hull_max, armour, heat_max, cooling, move, u.hardpoints, u.die.size() if u.die != null else 0]
	var faces: Array = []
	if u.die != null:
		for f in u.die.faces:
			faces.append(Effects.effective_face(u, f))   # its reach and keywords as the passives make them
	# Every live loadout and battle modifier: the chassis passive first, then what
	# components grant, then the battle's rewards; nothing from the fight itself.
	var lines: Array[String] = []
	for d in Effects.describe(u):
		if d[3] != Effects.LOADOUT and d[3] != Effects.BATTLE:
			continue
		var head: String = str(d[0]).to_upper()
		if d[2] != "chassis" and components.has(d[2]):
			head += " (%s)" % str(components[d[2]].get("name", d[2]))
		elif d[3] == Effects.BATTLE:
			head += " (REWARD)"
		lines.append("%s: %s" % [head, d[1]])
	var passive := "\n".join(lines)
	return {
		"title": u.display_name,
		"subtitle": "%s // %s // D%d" % [str(maker.get("name", "")).to_upper(), str(c.get("silhouette", "")).to_upper(), u.die.size() if u.die != null else 0],
		"designation": str(c.get("designation", "")),   # the maker's long name; the title is the nickname
		"body": str(c.get("codex", "")),   # never fantasy: that field is design notes and homages
		"stats": stats,
		# Hardpoints are not a number here: the component list shows them as sockets.
		# The machine's numbers, never its state (Ryan, 22 September: the codex is the spec
		# plate; the gauges say how it is doing): maxima with their rates beside them.
		"stat_items": [["shield max / recharge", "%d / +%d" % [shield_max, recharge]], ["hull max / armour", "%d / %d" % [hull_max, armour]],
			["heat max / cooling", "%d / %d" % [heat_max, cooling]], ["move speed", str(move)]],
		"actions": "",
		"passive": passive,
		"faces": faces,
		"current": -1,
		"flavour": str(c.get("flavour", "")),
		"sprite_id": u.chassis_id,
		"paint": u.paint,
	}


## Unpack a battlefield pack into skirmish foes: its foe type times its strength. A boss
## (elite) unpacks into the faction's massive boss first. A pack with no foe type falls back
## to the first entry of its faction's spawn list.
func foes_for(sq: Unit) -> Array[Foe]:
	var out: Array[Foe] = []
	var fac: Dictionary = factions.get(sq.faction, {})
	if sq.elite and fac.has("boss") and foes.has(fac["boss"]):
		var b := make_foe(str(fac["boss"]))
		b.pack_id = sq.id
		out.append(b)
	var fid := sq.foe_id
	if fid.is_empty():
		var spawn: Array = fac.get("spawn", [])
		if not spawn.is_empty():
			fid = str(spawn[0].get("foe", ""))
	if foes.has(fid):
		for i in range(sq.strength):
			var f := make_foe(fid)
			f.pack_id = sq.id
			out.append(f)
	return out


## Defaults come from the content in file order, never from a hardcoded id, so the ids are
## Ryan's to rename. The first chassis in the file are the starting team; the first faction
## is the one the standalone screens and the harness fight.
func default_team(count: int = 3) -> Array:
	return chassis.keys().slice(0, count)


func default_faction() -> String:
	return str(factions.keys()[0]) if not factions.is_empty() else ""


## The distinct foe ids in a faction's spawn list, in order: rank and file first.
func spawn_foes(faction_id: String) -> Array:
	var out: Array = []
	for entry in spawn_table(faction_id):
		if not out.has(entry[0]):
			out.append(entry[0])
	return out


## A boss pack for a faction, named after its massive elite.
func make_boss(uid: int, faction_id: String) -> Unit:
	var boss_id := str(factions.get(faction_id, {}).get("boss", ""))
	var boss_name := str(foes.get(boss_id, {}).get("name", "boss")).to_lower()
	return Unit.boss(uid, boss_name, Vector2i.ZERO, faction_id)


## The packs a faction sends through the rift together, as [[foe_id, strength], ...].
func spawn_table(faction_id: String) -> Array:
	var out: Array = []
	for e in factions.get(faction_id, {}).get("spawn", []):
		out.append([str(e.get("foe", "")), int(e.get("strength", 1))])
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


func _validate_face(where: String, fd: Dictionary, errs: Array[String], planned: bool = false) -> void:
	var kind := str(fd.get("kind", ""))
	if Face.kind_from_name(kind) < 0 or kind == "blank":
		errs.append("%s: bad face kind '%s'" % [where, kind])
	if kind == "attack":
		# Melee is authored too (26 September: a claw is a claw); until then it only ever
		# came from a passive's set_reach.
		var reach := str(fd.get("reach", ""))
		if not ["line", "indirect", "melee"].has(reach):
			errs.append("%s: attack face needs reach line, indirect or melee, got '%s'" % [where, reach])
	if int(fd.get("power", 0)) < 0:
		errs.append("%s: power cannot be negative" % where)
	if int(fd.get("strikes", 1)) < 1:
		errs.append("%s: strikes must be at least 1" % where)
	if int(fd.get("strikes", 1)) > 1 and kind != "attack":
		errs.append("%s: only attacks strike more than once" % where)
	if fd.has("power_max") and int(fd["power_max"]) < int(fd.get("power", 0)):
		errs.append("%s: power_max below power" % where)
	var crit := int(fd.get("crit", 0))
	if crit < 0 or crit > 100:
		errs.append("%s: crit must be 0 to 100" % where)
	if crit > 0 and kind != "attack":
		errs.append("%s: only attack faces crit" % where)
	if float(fd.get("crit_bonus", 0.0)) <= -Face.CRIT_MULT:
		errs.append("%s: crit_bonus would make crits do nothing or heal" % where)
	if (fd.has("vents_all") or fd.has("power_per_heat")) and kind != "attack":
		errs.append("%s: vents_all and power_per_heat belong to an attack" % where)
	if fd.has("power_per_heat") and not bool(fd.get("vents_all", false)):
		errs.append("%s: power_per_heat needs vents_all (the heat it adds for is the heat it fires)" % where)
	if int(fd.get("power_per_heat", 0)) < 0:
		errs.append("%s: power_per_heat cannot be negative" % where)
	if kind == "buff":
		# A buff grants one of the machines' statuses: it must exist and be theirs.
		var st := str(fd.get("status", ""))
		if not Effects.STATUS.has(st):
			errs.append("%s: a buff needs 'status', one of %s" % [where, ", ".join(Effects.MECH_STATUSES)])
		elif not Effects.MECH_STATUSES.has(st):
			errs.append("%s: '%s' is a foe's status; a buff grants one of %s" % [where, st, ", ".join(Effects.MECH_STATUSES)])
		if int(fd.get("stacks", 1)) < 1 or int(fd.get("rounds", 1)) < 1:
			errs.append("%s: a buff's stacks and rounds are at least 1" % where)
	elif fd.has("status") or fd.has("stacks") or fd.has("rounds"):
		errs.append("%s: status, stacks and rounds belong to a buff face" % where)
	if fd.has("targets"):
		var t := Face.target_from_name(str(fd["targets"]))
		if kind == "attack":
			errs.append("%s: a weapon always targets foes; 'targets' is for equipment" % where)
		elif t < 0 or t == Face.Target.FOE:
			errs.append("%s: targets must be self_ally, self or ally, got '%s'" % [where, fd["targets"]])
	var kws: Array = fd.get("keywords", [])
	if kws.size() > MAX_AUTHORED_KEYWORDS:
		errs.append("%s: %d keywords, authored cap is %d" % [where, kws.size(), MAX_AUTHORED_KEYWORDS])
	for k in kws:
		# A planned component may carry a keyword the vocabulary names but the engine lacks
		# (taunt, volatile, devour): Face.from_dict builds it without that keyword until it is coded.
		if planned and vocabulary.has(str(k)) and vocabulary[str(k)].get("status") != "implemented":
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


func _validate_passive(where: String, p, errs: Array[String]) -> void:
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
	if effects.size() > MAX_PASSIVE_EFFECTS:
		errs.append("%s: passive has %d effects, cap is %d (one idea per passive)" % [where, effects.size(), MAX_PASSIVE_EFFECTS])
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
		if (effect == "keep_status" or effect == "stack_status") and not Effects.STATUS.has(str(eff.get("value", ""))):
			errs.append("%s: %s needs an engine status as its value" % [where, effect])
		if effect == "add_armour_vs_rank" and not ["front", "back"].has(str(eff.get("rank", "front"))):
			errs.append("%s: add_armour_vs_rank's rank is front or back" % where)
		if effect == "grant_keyword":
			var kw := str(eff.get("value", ""))
			if Face.keyword_from_name(kw) <= 0:
				errs.append("%s: grant_keyword names no engine keyword ('%s')" % [where, kw])
			elif vocabulary.get(kw, {}).get("status") != "implemented":
				errs.append("%s: grant_keyword names '%s', which is not implemented yet" % [where, kw])
		var when := str(eff.get("when", ""))
		if not Effects.supports_when(when):
			errs.append("%s: passive condition '%s' is not implemented by the engine" % [where, when])
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


func _validate_components(errs: Array[String]) -> void:
	for id in components.keys():
		var c: Dictionary = components[id]
		var where := "component %s" % id
		for key in ["name", "codex", "flavour", "face"]:
			if not c.has(key):
				errs.append("%s: missing %s" % [where, key])
		for key in ["hardpoints", "slots", "faces"]:
			if c.has(key):
				errs.append("%s: '%s' is gone; a component is exactly one entry, its 'face'" % [where, key])
		_validate_design(where, c, errs)
		# A component the engine cannot run yet carries "status": "planned" (like a passive or a
		# foe action): kept, its face checked for shape, its unbuilt keywords allowed.
		var status := str(c.get("status", "implemented"))
		if not ACTION_STATUSES.has(status):
			errs.append("%s: status must be implemented or planned" % where)
		if c.get("face", null) is Dictionary:
			_validate_face("%s face" % where, c["face"], errs, status == "planned")
		else:
			errs.append("%s: face must be an object" % where)
		if c.has("maker") and not makers.has(c["maker"]):
			errs.append("%s: unknown maker %s" % [where, c["maker"]])
		_validate_passive(where, c.get("passive", null), errs)


func _validate_chassis(errs: Array[String]) -> void:
	for id in chassis.keys():
		var c: Dictionary = chassis[id]
		var where := "chassis %s" % id
		# designation: the maker's long name on the spec plate (Ryan, 26 September: every
		# chassis carries one; the bible's section 7 row says the shape per maker).
		for key in ["name", "designation", "codex", "flavour", "hull", "shield", "armour", "movespeed", "hardpoints", "loadout", "recharge_field"]:
			if not c.has(key):
				errs.append("%s: missing %s" % [where, key])
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
		for t in c.get("traits", []):
			if not vocabulary.has(str(t)) or vocabulary[str(t)].get("category") != "trait":
				errs.append("%s: unknown trait %s" % [where, t])
		if c.has("maker") and not makers.has(c["maker"]):
			errs.append("%s: unknown maker %s" % [where, c["maker"]])
		if c.has("passives"):
			errs.append("%s: use 'passive' (zero or one), not 'passives'" % where)
		_validate_passive(where, c.get("passive", null), errs)


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
		if str(a.get("status", "")) == "implemented":
			if str(a.get("kind", "")) != "attack":
				# A defend, buff or debuff names an effect the engine runs and the fields it reads.
				var kind := str(a.get("kind", ""))
				var effect := str(a.get("effect", ""))
				if not Foe.ACTION_EFFECTS.get(kind, []).has(effect):
					errs.append("%s: a %s action's effect must be one of %s, got '%s'" % [aw, kind, ", ".join(Foe.ACTION_EFFECTS.get(kind, [])), effect])
				if effect == "summon" and not foes.has(str(a.get("foe", ""))):
					errs.append("%s: summon names unknown foe '%s'" % [aw, str(a.get("foe", ""))])
				if int(a.get("value", 0)) < 0 or int(a.get("count", 1)) < 1 or int(a.get("weight", 1)) < 1:
					errs.append("%s: value cannot be negative; count and weight are at least 1" % aw)
				for key in ["factor", "strikes", "keywords"]:
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
				for k in a.get("keywords", []):
					if not Foe.ATTACK_KEYWORDS.has(str(k)):
						errs.append("%s: unknown attack keyword '%s' (foe attacks know %s)" % [aw, k, ", ".join(Foe.ATTACK_KEYWORDS)])
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
		_validate_actions(where, f, errs)
		if not ["front", "back"].has(str(f.get("rank", ""))):
			errs.append("%s: rank must be front or back" % where)
		var sz := int(f.get("size", 1))
		if sz < 1 or sz > 2:
			errs.append("%s: size must be 1 or 2 (massive)" % where)
		if sz == 2 and str(f.get("rank", "")) == "back":
			errs.append("%s: a massive foe fills both ranks and must be rank front" % where)
		if f.has("injures"):
			errs.append("%s: 'injures' is gone; component injuries are a global rule" % where)
		if f.has("stun_resist") and (int(f["stun_resist"]) < 0 or int(f["stun_resist"]) > 100):
			errs.append("%s: stun_resist is a percent, 0 to 100" % where)
		for key in ["strikes", "breach"]:
			if f.has(key):
				errs.append("%s: '%s' belongs on an attack action, not the foe" % [where, key])
		if f.has("faction") and not factions.has(f["faction"]):
			errs.append("%s: unknown faction %s" % [where, f["faction"]])


func _validate_factions(errs: Array[String]) -> void:
	for id in factions.keys():
		var f: Dictionary = factions[id]
		var where := "faction %s" % id
		for key in ["name", "spawn"]:
			if not f.has(key):
				errs.append("%s: missing %s" % [where, key])
		_validate_design(where, f, errs)
		for old in ["pattern", "elite", "injury"]:
			if f.has(old):
				errs.append("%s: '%s' is gone; use spawn and boss" % [where, old])
		var spawn: Array = f.get("spawn", [])
		if spawn.is_empty():
			errs.append("%s: empty spawn list" % where)
		for e in spawn:
			if not (e is Dictionary) or not foes.has(str(e.get("foe", ""))):
				errs.append("%s: spawn entry names unknown foe %s" % [where, str(e)])
			elif int(e.get("strength", 0)) < 1:
				errs.append("%s: spawn entry %s needs a strength of at least 1" % [where, e.get("foe")])
			elif int(foes[str(e["foe"])].get("size", 1)) > 1:
				errs.append("%s: massive foe %s belongs in 'boss', not spawn" % [where, e.get("foe")])
		if f.has("boss"):
			if not foes.has(f["boss"]):
				errs.append("%s: boss names unknown foe %s" % [where, f["boss"]])
			elif int(foes[f["boss"]].get("size", 1)) != 2:
				errs.append("%s: boss %s should be massive (size 2)" % [where, f["boss"]])

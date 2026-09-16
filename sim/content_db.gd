class_name ContentDB
extends RefCounted

## Loads content/*.json, validates it against the design rules, and builds runtime objects.
## Content is authored fantasy-first in JSON; the validator is the vetting pass that runs
## in the test suite, so a concept that breaks a rule fails the build.

const DIR := "res://content/"

# Design knobs. Loosen or tighten here; the validator and the bible should agree.
const MAX_AUTHORED_KEYWORDS := 3    # per authored face; upgrades may exceed this at runtime
const MIN_DIE := 4
const MAX_DIE := 8
const MAX_PASSIVE_RULES := 3        # lines in one passive; a benefit and its cost is one passive
const VALID_STATUS := ["implemented", "planned", "idea"]

static var _cache: ContentDB = null

var vocabulary: Dictionary = {}   # id -> entry
var factions: Dictionary = {}
var foes: Dictionary = {}
var chassis: Dictionary = {}
var components: Dictionary = {}
var makers: Dictionary = {}
var categories: Array = []
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


## Assemble a die from component ids. Faces beyond the components come from `filler`.
func build_die(component_ids: Array, hardpoints: int, filler: Dictionary = {}) -> Die:
	var die := Die.new()
	for cid in component_ids:
		var comp: Dictionary = components.get(cid, {})
		for fd in comp.get("faces", []):
			die.faces.append(build_face(fd))
	while die.faces.size() < hardpoints:
		die.faces.append(build_face(filler) if not filler.is_empty() else Face.shield(1))
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
	u.die = build_die(c.get("loadout", []), int(c.get("hardpoints", 6)), c.get("filler", {}))
	u.chassis_id = chassis_id
	var p = c.get("passive", null)
	if p is Dictionary:
		u.passive = p
	return u


func make_foe(foe_id: String) -> Foe:
	var d: Dictionary = foes[foe_id]
	var f := Foe.make(str(d["name"]), int(d["hp"]), int(d["attack"]), str(d.get("rank", "front")) == "back")
	f.size = int(d.get("size", 1))
	f.content_id = foe_id
	return f


## Codex text for a foe: fantasy, the question it poses, numbers, and faction flavour.
func codex_for_foe(f: Foe) -> Dictionary:
	var d: Dictionary = foes.get(f.content_id, {})
	var fac: Dictionary = factions.get(str(d.get("faction", "")), {})
	var stats := "HP %d/%d // ATK %d // %s RANK" % [f.hp, f.hp_max, f.attack, "BACK" if f.prefers_back else "FRONT"]
	if f.is_massive():
		stats += " // MASSIVE"
	var acts: Array[String] = []
	for a in d.get("actions", []):
		if str(a.get("status", "")) != "implemented":
			continue
		var head := "%s // %s" % [str(a.get("name", "")).to_upper(), str(a.get("kind", "")).to_upper()]
		if a.has("value"):
			head += " %d" % int(a["value"])
		acts.append("%s\n  %s" % [head, str(a.get("text", ""))])
	var faction_name := str(fac.get("name", "")).strip_edges()
	if faction_name.is_empty():
		faction_name = str(d.get("faction", "")).capitalize()
	return {
		"title": f.display_name,
		"subtitle": faction_name.to_upper(),
		"body": str(d.get("codex", "")),
		"stats": stats,
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
	var stats := "HULL %d/%d // SHIELD %d/%d // MOVE %d // %d HARDPOINTS" % [
		u.hull, u.hull_max, u.shield, u.shield_max, u.movespeed, u.die.size() if u.die != null else 0]
	var faces: Array = []
	if u.die != null:
		faces = u.die.faces.duplicate()
	var passive := ""
	if not u.passive.is_empty():
		passive = "%s: %s %s" % [str(u.passive.get("name", "")).to_upper(), u.passive.get("description", ""), " ".join(u.passive.get("rules", []))]
	return {
		"title": u.display_name,
		"subtitle": "%s // %s" % [str(maker.get("name", "")).to_upper(), str(c.get("silhouette", "")).to_upper()],
		"body": str(c.get("codex", "")),   # never fantasy: that field is design notes and homages
		"stats": stats,
		"actions": "",
		"passive": passive,
		"faces": faces,
		"current": -1,
		"flavour": str(c.get("flavour", "")),
		"sprite_id": u.chassis_id,
	}


## Unpack a battlefield squad into skirmish foes: its foe type times its strength. A boss
## (elite) unpacks into the faction's massive boss first. A squad with no foe type falls back
## to the first entry of its faction's spawn list.
func foes_for(sq: Unit) -> Array[Foe]:
	var out: Array[Foe] = []
	var fac: Dictionary = factions.get(sq.faction, {})
	if sq.elite and fac.has("boss") and foes.has(fac["boss"]):
		var b := make_foe(str(fac["boss"]))
		b.squad_id = sq.id
		out.append(b)
	var fid := sq.foe_id
	if fid.is_empty():
		var spawn: Array = fac.get("spawn", [])
		if not spawn.is_empty():
			fid = str(spawn[0].get("foe", ""))
	if foes.has(fid):
		for i in range(sq.strength):
			var f := make_foe(fid)
			f.squad_id = sq.id
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


## A boss squad for a faction, named after its massive elite.
func make_boss(uid: int, faction_id: String) -> Unit:
	var boss_id := str(factions.get(faction_id, {}).get("boss", ""))
	var boss_name := str(foes.get(boss_id, {}).get("name", "boss")).to_lower()
	return Unit.boss(uid, boss_name, Vector2i.ZERO, faction_id)


## The squads a faction sends through the rift together, as [[foe_id, strength], ...].
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
		for key in ["category", "name", "fantasy", "rule", "status"]:
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
			if Face.keyword_from_name(id) < 0:
				errs.append("vocabulary keyword '%s' is marked implemented but the engine has no such keyword" % id)


func _validate_face(where: String, fd: Dictionary, errs: Array[String]) -> void:
	var kind := str(fd.get("kind", ""))
	if Face.kind_from_name(kind) < 0 or kind == "blank":
		errs.append("%s: bad face kind '%s'" % [where, kind])
	if kind == "attack":
		var reach := str(fd.get("reach", ""))
		if not ["line", "indirect"].has(reach):
			errs.append("%s: attack face needs reach line or indirect, got '%s'" % [where, reach])
	if int(fd.get("power", 0)) <= 0:
		errs.append("%s: power must be positive" % where)
	if fd.has("power_max") and int(fd["power_max"]) < int(fd.get("power", 0)):
		errs.append("%s: power_max below power" % where)
	var crit := int(fd.get("crit", 0))
	if crit < 0 or crit > 100:
		errs.append("%s: crit must be 0 to 100" % where)
	if crit > 0 and kind != "attack":
		errs.append("%s: only attack faces crit" % where)
	var kws: Array = fd.get("keywords", [])
	if kws.size() > MAX_AUTHORED_KEYWORDS:
		errs.append("%s: %d keywords, authored cap is %d" % [where, kws.size(), MAX_AUTHORED_KEYWORDS])
	for k in kws:
		if Face.keyword_from_name(str(k)) <= 0:
			errs.append("%s: unknown keyword '%s'" % [where, k])
		elif vocabulary.get(str(k), {}).get("status") != "implemented":
			errs.append("%s: keyword '%s' is not implemented yet" % [where, k])


func _validate_passive(where: String, p, errs: Array[String]) -> void:
	if p == null:
		return
	if not (p is Dictionary):
		errs.append("%s: passive must be an object or null" % where)
		return
	# A passive's description is player-facing (the codex prints NAME: description rules);
	# `fantasy` on a passive would be shown, so it is not the field here.
	for key in ["id", "name", "description", "rules"]:
		if not p.has(key):
			errs.append("%s: passive missing %s" % [where, key])
	if p.has("fantasy"):
		errs.append("%s: passive has a fantasy field; use description (player-facing) and keep notes on the chassis" % where)
	var rules: Array = p.get("rules", [])
	if rules.is_empty():
		errs.append("%s: passive has no rules" % where)
	if rules.size() > MAX_PASSIVE_RULES:
		errs.append("%s: passive has %d rule lines, cap is %d (one idea per passive)" % [where, rules.size(), MAX_PASSIVE_RULES])
	for eff in p.get("effects", []):
		var trig := str(eff.get("trigger", ""))
		if not vocabulary.has(trig) or vocabulary[trig].get("category") != "trigger":
			errs.append("%s: passive effect uses unknown trigger '%s'" % [where, trig])
		var effect := str(eff.get("effect", ""))
		if not Passives.supports(trig, effect):
			errs.append("%s: passive effect '%s' on '%s' is not implemented by the engine" % [where, effect, trig])


func _validate_components(errs: Array[String]) -> void:
	for id in components.keys():
		var c: Dictionary = components[id]
		var where := "component %s" % id
		for key in ["name", "fantasy", "hardpoints", "faces"]:
			if not c.has(key):
				errs.append("%s: missing %s" % [where, key])
		var faces: Array = c.get("faces", [])
		if faces.is_empty():
			errs.append("%s: no faces" % where)
		if int(c.get("hardpoints", -1)) != faces.size():
			errs.append("%s: hardpoints %s but %d faces" % [where, str(c.get("hardpoints")), faces.size()])
		for i in range(faces.size()):
			_validate_face("%s face %d" % [where, i], faces[i], errs)
		if c.has("maker") and not makers.has(c["maker"]):
			errs.append("%s: unknown maker %s" % [where, c["maker"]])
		_validate_passive(where, c.get("passive", null), errs)


func _validate_chassis(errs: Array[String]) -> void:
	for id in chassis.keys():
		var c: Dictionary = chassis[id]
		var where := "chassis %s" % id
		for key in ["name", "fantasy", "codex", "flavour", "hull", "shield", "movespeed", "hardpoints", "loadout"]:
			if not c.has(key):
				errs.append("%s: missing %s" % [where, key])
		var hp := int(c.get("hardpoints", 0))
		if hp < MIN_DIE or hp > MAX_DIE:
			errs.append("%s: %d hardpoints, die size must be %d to %d" % [where, hp, MIN_DIE, MAX_DIE])
		var used := 0
		for cid in c.get("loadout", []):
			if not components.has(cid):
				errs.append("%s: unknown component %s" % [where, cid])
			else:
				used += int(components[cid].get("hardpoints", 0))
		if used > hp:
			errs.append("%s: loadout uses %d hardpoints of %d" % [where, used, hp])
		if used < hp and c.get("filler", {}).is_empty():
			errs.append("%s: loadout leaves %d empty hardpoints and no filler" % [where, hp - used])
		for t in c.get("traits", []):
			if not vocabulary.has(str(t)) or vocabulary[str(t)].get("category") != "trait":
				errs.append("%s: unknown trait %s" % [where, t])
		if c.has("maker") and not makers.has(c["maker"]):
			errs.append("%s: unknown maker %s" % [where, c["maker"]])
		if c.has("passives"):
			errs.append("%s: use 'passive' (zero or one), not 'passives'" % where)
		_validate_passive(where, c.get("passive", null), errs)


const ACTION_KINDS := ["attack", "defend", "buff", "debuff"]
const ACTION_STATUSES := ["implemented", "planned"]


## A foe's roster of actions. Today the engine runs only a basic attack, so exactly one
## implemented attack action is required and its value must match the foe's attack; every
## other action must be marked planned until the engine can run it.
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
				errs.append("%s: only attack actions are implemented by the engine so far" % aw)
			else:
				implemented_attacks += 1
				if int(a.get("value", -1)) != int(f.get("attack", 0)):
					errs.append("%s: implemented attack value must equal the foe's attack (%d)" % [aw, int(f.get("attack", 0))])
	if implemented_attacks != 1:
		errs.append("%s: needs exactly one implemented attack action, has %d" % [where, implemented_attacks])


func _validate_foes(errs: Array[String]) -> void:
	for id in foes.keys():
		var f: Dictionary = foes[id]
		var where := "foe %s" % id
		for key in ["name", "fantasy", "question", "codex", "flavour", "actions", "hp", "attack", "rank"]:
			if not f.has(key):
				errs.append("%s: missing %s" % [where, key])
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
			errs.append("%s: 'injures' is gone; face injuries are a global rule" % where)
		if f.has("faction") and not factions.has(f["faction"]):
			errs.append("%s: unknown faction %s" % [where, f["faction"]])


func _validate_factions(errs: Array[String]) -> void:
	for id in factions.keys():
		var f: Dictionary = factions[id]
		var where := "faction %s" % id
		for key in ["name", "fantasy", "signature", "answer", "spawn"]:
			if not f.has(key):
				errs.append("%s: missing %s" % [where, key])
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

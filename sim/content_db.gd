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
## A chassis's class by mass, lightest first (Ryan, 5 October: the machines' scale on the map
## and in the skirmish): how big it is drawn, Map3D.SIZE_FIT and MechView3D.SIZE_FILL.
const SIZES := ["light", "medium", "heavy", "assault"]
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


## A machine as the content builds it. `loadout` is the hardpoint components fitted, in
## order; null means the chassis's stock loadout (the campaign passes its roster's own).
func make_mech(chassis_id: String, uid: int = 0, at: Vector2i = Vector2i.ZERO, loadout = null) -> Unit:
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
	return u


func component_name(cid: String) -> String:
	return str(components.get(cid, {}).get("name", cid))


func make_foe(foe_id: String) -> Foe:
	var d: Dictionary = foes[foe_id]
	var f := Foe.make(str(d["name"]), int(d["hp"]), int(d["attack"]), str(d.get("rank", "front")) == "back")
	f.size = int(d.get("size", 1))
	f.armour = maxi(0, int(d.get("armour", 0)))
	f.aim = str(d.get("aim", Foe.AIM_EXPOSED))
	f.stun_resist = clampi(int(d.get("stun_resist", 0)), 0, 100)
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
		else:
			# A defend, buff or debuff: its effect and the fields it reads (Foe.ACTION_EFFECTS).
			act = {"id": str(a.get("id", kind)), "name": str(a.get("name", kind.capitalize())), "kind": kind, "effect": str(a.get("effect", "")),
				"value": int(a.get("value", 0)), "weight": int(a.get("weight", 1)), "text": str(a.get("text", ""))}
			if a.has("foe"):
				act["foe"] = str(a["foe"])
			if a.has("count"):
				act["count"] = int(a["count"])
		# The move's own sense and condition (2 October), when it has them.
		if a.has("aim"):
			act["aim"] = str(a["aim"])
		if a.has("when"):
			act["when"] = Foe.whens_of(a)
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
	if f.armour > 0:
		stats += " // ARM %d" % f.armour
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
			if int(a.get("swarm", 0)) > 0:
				head += " // +%d A KIN" % int(a["swarm"])
			for k in a.get("keywords", []):
				head += " // %s" % str(k).to_upper()
		# A move's own sense, where it differs from the foe's, and its condition.
		if a.has("aim") and str(a["aim"]) != f.aim:
			head += " // %s" % str(Foe.AIM_TEXT.get(str(a["aim"]), str(a["aim"]))).to_upper()
		var whens := Foe.whens_of(a)
		if not whens.is_empty():
			var said: Array[String] = []
			for w in whens:
				said.append(str(Foe.WHEN_TEXT.get(str(w), str(w))))
			head += " // %s" % " OR ".join(said).to_upper()
		acts.append("%s\n  %s" % [head, f.text_of(a)])
	var faction_name := str(fac.get("name", "")).strip_edges()
	if faction_name.is_empty():
		faction_name = str(d.get("faction", "")).capitalize()
	return {
		"title": f.display_name,
		"subtitle": faction_name.to_upper(),
		"body": str(d.get("codex", "")),
		"stats": stats,
		"stat_items": [["hp", str(f.hp_max)], ["attack", str(f.attack)]] + ([["armour", str(f.armour)]] if f.armour > 0 else []) + [
			["rank", "BACK" if f.prefers_back else "FRONT"], ["sense", str(Foe.AIM_TEXT.get(f.aim, f.aim)).to_upper()]] + ([["size", "MASSIVE"]] if f.is_massive() else []),
		"actions": "\n".join(acts),
		"passive": "",
		"faces": [],
		"current": -1,
		"flavour": str(d.get("flavour", "")),
		"sprite_id": f.content_id,
	}


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
	# components grant, then the battle's rewards; nothing from the fight itself. Each row
	# says where it comes from ("chassis", "component", "reward"), and the codex colours
	# it by that, so a granted passive never reads as the machine's own.
	var lines: Array[String] = []
	var rows: Array = []
	for d in Effects.describe(u):
		if d[3] != Effects.LOADOUT and d[3] != Effects.BATTLE:
			continue
		var head: String = str(d[0]).to_upper()
		var kind := "chassis"
		if d[2] != "chassis" and components.has(d[2]):
			head += " (%s)" % str(components[d[2]].get("name", d[2]))
			kind = "component"
		elif d[3] == Effects.BATTLE:
			head += " (REWARD)"
			kind = "reward"
		lines.append("%s: %s" % [head, d[1]])
		rows.append([lines[lines.size() - 1], kind])
	var passive := "\n".join(lines)
	return {
		"title": u.display_name,
		"subtitle": " // ".join(_plate_parts(c, maker, u)),
		"designation": str(c.get("designation", "")),   # the maker's long name; the title is the nickname
		"body": str(c.get("codex", "")),   # never fantasy: that field is design notes and homages
		"stats": stats,
		# Hardpoints are not a number here: the component list shows them as sockets.
		# The machine's numbers, never its state (Ryan, 22 September: the codex is the spec
		# plate; the gauges say how it is doing): maxima with their rates beside them.
		"stat_items": [["shield max / recharge", "%d / +%d" % [shield_max, recharge]], ["hull max / armour", "%d / %d" % [hull_max, armour]],
			["heat max / cooling", "%d / %d" % [heat_max, cooling]], ["move", "%d (%d open)" % [move, move / maxi(1, BattleMap.move_cost(BattleMap.Terrain.PLAIN, u.traits))]]],
		"actions": "",
		"passive": passive,
		"passive_rows": rows,   # [text, "chassis" | "component" | "reward"]
		"faces": faces,
		"current": -1,
		"flavour": str(c.get("flavour", "")),
		"sprite_id": u.chassis_id,
		"paint": u.paint,
		"unit": u,   # the model shows the fitted loadout (MechView3D.plan_for)
	}


## What the map needs of a foe type (decided 1 October): its pack's engagement zone, its
## behaviour and caveat, and its move. Keyed by foe id, for Battlefield.foe_profiles; a
## boss's entry serves the boss unit. Defaults are the engine's when the content says nothing.
func pack_profiles() -> Dictionary:
	var out: Dictionary = {}
	for id in foes.keys():
		var f: Dictionary = foes[id]
		var p: Dictionary = {"zone": int(f.get("zone", 1)), "behaviour": str(f.get("behaviour", "push")), "hunts": str(f.get("hunts", "nearest"))}
		p["movespeed"] = int(f.get("movespeed", Unit.PACK_MOVE))
		out[id] = p
	return out


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


## Tiers (bible section 10, the ledger, 7 October). A chassis carries its tier; a component
## stocked by any chassis takes the lowest tier of the chassis that stock it; one no chassis
## stocks carries its own; a fixed-only component has none (0).
func chassis_tier(chassis_id: String) -> int:
	return int(chassis.get(chassis_id, {}).get("tier", 0))


func component_tier(component_id: String) -> int:
	var best := 0
	for id in chassis.keys():
		if chassis[id].get("loadout", []).has(component_id):
			var t := int(chassis[id].get("tier", 0))
			if t > 0 and (best == 0 or t < best):
				best = t
	if best > 0:
		return best
	return int(components.get(component_id, {}).get("tier", 0))


## The chassis of one tier, in content order.
func chassis_of_tier(t: int) -> Array:
	var out: Array = []
	for id in chassis.keys():
		if int(chassis[id].get("tier", 0)) == t:
			out.append(str(id))
	return out


## The blueprints a run starts with: every tier-one component (Ryan, 7 October: each
## maker's basic defaults, which are the tier-one chassis's stock).
func starting_blueprints() -> Array:
	var out: Array = []
	for cid in components.keys():
		if component_tier(str(cid)) == 1:
			out.append(str(cid))
	return out


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
## A flag, never a refusal (Ryan, 2 October: a thematically slow wheeled APC is a valid
## design): every pair of ground chassis of different ways of moving where one crosses at
## least as many hexes a phase as the other on every ground and more on some, since that
## is a move buying through the other way's identity. Two machines of one way a weight
## class apart are not flagged: a heavier frame being slower is the point. Flyers are
## exempt, since they pay by not blocking. `entries` defaults to the content's chassis; a
## test passes its own.
func movement_flags(entries: Array = []) -> Array[String]:
	var list: Array = entries if not entries.is_empty() else chassis.values()
	var grounds := [BattleMap.Terrain.PLAIN, BattleMap.Terrain.ROUGH, BattleMap.Terrain.RUINS, BattleMap.Terrain.WATER]
	var rows: Array = []
	for c in list:
		var traits: Array = c.get("traits", [])
		if traits.has("flyer"):
			continue
		var move := int(c.get("movespeed", Unit.MECH_MOVE))
		var hexes: Array[int] = []
		for g in grounds:
			var cost := BattleMap.move_cost(g, traits)
			hexes.append(1 if cost == BattleMap.SLOW else (0 if cost == BattleMap.WALL else move / cost))
		rows.append([str(c.get("name", c.get("id", "?"))), hexes, BattleMap.way_of(traits)])
	var out: Array[String] = []
	for a in rows:
		for b in rows:
			if a == b or a[2] == b[2]:
				continue
			var all_ge := true
			var some_gt := false
			for i in range(grounds.size()):
				all_ge = all_ge and int(a[1][i]) >= int(b[1][i])
				some_gt = some_gt or int(a[1][i]) > int(b[1][i])
			if all_ge and some_gt:
				out.append("%s is at least as fast as %s on every ground (open/rough/ruins/water %s against %s)" % [a[0], b[0], str(a[1]), str(b[1])])
	return out


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
		elif kind != "shield" and Face.SHIELD_ONLY_KEYWORDS.has(kw):
			errs.append("%s: '%s' rides on a shield component only; a %s has nothing to pass" % [where, k, kind])
		elif kw == Face.Keyword.GUARD and str(fd.get("targets", "self_ally")) != "ally":
			errs.append("%s: a guard is spent on an ally (it takes that ally's blows); set targets to ally" % where)


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
		if eff.has("per_heat") and int(eff["per_heat"]) <= 0:
			errs.append("%s: per_heat is heat per step and must be positive" % where)
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


## The silhouette classes a fitted component's model wears (decided 29 September, the rule
## settled 30 September): hardpoints are gun mounts on the model, and a component with a
## shape takes the next mount in the die's order, in its own maker's metal
## (art/models/shapes/<shape>_<maker>.glb, built by tools/lowforge; models_low.SHAPES is the
## same list). "none" is for what is applied to the whole machine and shows nowhere: armour
## panels and vents take a die entry and no mount.
const SHAPES := ["barrel", "twin_barrel", "rack", "blade", "dish", "none"]
const SHAPE_NONE := "none"

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
	var capitals := 0
	for id in makers.keys():
		if bool(makers[id].get("capital", false)):
			capitals += 1
	if not makers.is_empty() and capitals != 1:
		errs.append("makers: exactly one maker sits at the capital (\"capital\": true); %d do" % capitals)
	# Tiers (7 October): every chassis 1 to 3; the capital's maker fields no tier one; a
	# stocked component's tier is derived, so it stores none; an unstocked one that is not
	# fixed stores its own; no component of the capital's maker is tier one.
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
	for cid in components.keys():
		var c: Dictionary = components[cid]
		if stocked_ids.has(cid) and c.has("tier"):
			errs.append("component %s: stocked by a chassis, so its tier is derived and stores none" % cid)
		elif not stocked_ids.has(cid) and not fixed_ids.has(cid) and not c.has("tier"):
			errs.append("component %s: no chassis stocks it, so it carries its own tier" % cid)
		if not capital.is_empty() and str(c.get("maker", "")) == capital and component_tier(str(cid)) == 1:
			errs.append("component %s: the capital's maker has no tier-one component" % cid)
	for id in chassis.keys():
		var c: Dictionary = chassis[id]
		var where := "chassis %s" % id
		# designation: the maker's long name on the spec plate (Ryan, 26 September: every
		# chassis carries one; the bible's section 7 row says the shape per maker).
		for key in ["name", "designation", "codex", "flavour", "hull", "shield", "armour", "movespeed", "hardpoints", "loadout", "recharge_field", "size"]:
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
		var ways := 0
		for t in c.get("traits", []):
			if not vocabulary.has(str(t)) or vocabulary[str(t)].get("category") != "trait":
				errs.append("%s: unknown trait %s" % [where, t])
			if BattleMap.WAYS.has(str(t)):
				ways += 1
		if ways != 1:
			errs.append("%s: a chassis has exactly one way of moving (%s)" % [where, ", ".join(BattleMap.WAYS)])
		if c.has("movespeed") and (int(c["movespeed"]) <= 0 or int(c["movespeed"]) % 5 != 0):
			errs.append("%s: movespeed is in tens, a positive multiple of 5" % where)
		if c.has("size") and not SIZES.has(str(c["size"])):
			errs.append("%s: size is one of %s" % [where, ", ".join(SIZES)])
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
		if int(f.get("armour", 0)) < 0:
			errs.append("%s: armour cannot be negative" % where)
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
		if f.has("injures"):
			errs.append("%s: 'injures' is gone; component injuries are a global rule" % where)
		if f.has("stun_resist") and (int(f["stun_resist"]) < 0 or int(f["stun_resist"]) > 100):
			errs.append("%s: stun_resist is a percent, 0 to 100" % where)
		if f.has("zone") and (int(f["zone"]) < 1 or int(f["zone"]) > 4):
			errs.append("%s: zone is the pack's engagement radius in hexes, 1 to 4" % where)
		if f.has("behaviour") and not ["push", "aggressive", "hunt"].has(str(f["behaviour"])):
			errs.append("%s: behaviour is push, aggressive or hunt" % where)
		if f.has("hunts") and not ["nearest", "weakest", "strongest", "slowest", "fastest"].has(str(f["hunts"])):
			errs.append("%s: hunts is nearest, weakest, strongest, slowest or fastest" % where)
		if f.has("hunts") and str(f.get("behaviour", "push")) != "hunt":
			errs.append("%s: hunts is a hunter's caveat; set behaviour to hunt" % where)
		if f.has("movespeed") and (int(f["movespeed"]) <= 0 or int(f["movespeed"]) % 5 != 0):
			errs.append("%s: movespeed is in tens, a positive multiple of 5" % where)
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

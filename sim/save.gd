class_name SaveGame
extends RefCounted

## One battle, whole, as plain data and back (built 30 September, for a phone that may be
## put down mid-fight): the map by its seed, every unit with its numbers, die, damage and
## live modifiers, the routes being plotted, the contacts waiting, and the skirmish under
## way with its dice, foes, ranks and both random streams, so a resumed fight plays on
## exactly as it would have. Headless, like everything in sim/: the screens only decide
## when to call it.
##
## The file is JSON under user://. Every number comes back as a float from JSON, so the
## reader casts; a random stream's state is a 64-bit integer, which JSON cannot hold, so
## it travels as a string. Nothing here is shown to the player.

const PATH := "user://battle.json"
const VERSION := 1


# ---------------------------------------------------------------- the file

static func exists(path: String = PATH) -> bool:
	return FileAccess.file_exists(path)


static func save(b: Battle, path: String = PATH) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(to_dict(b)))
	f.close()
	return true


## The saved battle, or null when there is none or it cannot be read.
static func load(path: String = PATH) -> Battle:
	if not FileAccess.file_exists(path):
		return null
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary) or int(parsed.get("version", 0)) != VERSION:
		return null
	return from_dict(parsed)


static func clear(path: String = PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


# ---------------------------------------------------------------- the battle

static func to_dict(b: Battle) -> Dictionary:
	var routes := {}
	for uid in b.routes.keys():
		routes[str(uid)] = _hexes(b.routes[uid])
	var pending: Array = []
	for group in b.pending:
		var ids: Array = []
		for u in group:
			ids.append(u.id)
		pending.append(ids)
	return {
		"version": VERSION,
		"seed": b.seed_value,
		"rng": str(b.rng.state),
		"faction": b.faction,
		"state": b.state,
		"outcome": b.outcome,
		"routes": routes,
		"pending": pending,
		"boss_contact": b.boss_contact,
		"boss": b.boss.id if b.boss != null else -1,
		"skirmishes_fought": b.skirmishes_fought,
		"columns": b.columns,
		"map": {"w": b.map.width, "h": b.map.height, "seed": b.map.map_seed},
		"field": _field_dict(b.field),
		"skirmish": _skirmish_dict(b.current, b.field) if b.current != null else null,
	}


static func from_dict(d: Dictionary) -> Battle:
	var b := Battle.new(int(d.get("seed", 1)))
	b.rng.state = str(d.get("rng", "0")).to_int()
	b.faction = str(d.get("faction", ""))
	b.state = int(d.get("state", Battle.State.PLAN))
	b.outcome = int(d.get("outcome", Battle.Outcome.NONE))
	var md: Dictionary = d.get("map", {})
	var w := int(md.get("w", Battle.DEFAULT_WIDTH))
	var h := int(md.get("h", Battle.DEFAULT_HEIGHT))
	var map_seed := int(md.get("seed", 0))
	b.map = BattleMap.generate(w, h, map_seed) if map_seed != 0 else BattleMap.flat(w, h)
	b.field = _field_from(d.get("field", {}), b.map)
	for uid in d.get("routes", {}).keys():
		b.routes[int(str(uid))] = _hexes_from(d["routes"][uid])
	for ids in d.get("pending", []):
		var group: Array = []
		for uid in ids:
			var u := b.field.unit_by_id(int(uid))
			if u != null:
				group.append(u)
		b.pending.append(group)
	b.boss_contact = bool(d.get("boss_contact", false))
	var boss_id := int(d.get("boss", -1))
	b.boss = b.field.unit_by_id(boss_id) if boss_id >= 0 else null
	b.skirmishes_fought = int(d.get("skirmishes_fought", 0))
	b.columns = int(d.get("columns", Skirmish.DEFAULT_COLUMNS))
	var sd = d.get("skirmish", null)
	if sd is Dictionary:
		b.current = _skirmish_from(sd, b.field)
	if b.state == Battle.State.PLAN:
		b.field.compute_intents()   # the packs' shown intents are derived, never stored
	return b


# ---------------------------------------------------------------- the field

static func _field_dict(f: Battlefield) -> Dictionary:
	var units: Array = []
	for u in f.units:
		units.append(_unit_dict(u))
	return {
		"gate_hp": f.gate_hp, "gate_hp_max": f.gate_hp_max,
		"rift_pressure": f.rift_pressure, "rift_pressure_max": f.rift_pressure_max,
		"spawn_faction": f.spawn_faction, "spawn_table": f.spawn_table, "spawn_index": f._spawn_index,
		"phase": f.phase, "log": f.log, "next_id": f._next_id,
		"units": units,
	}


static func _field_from(d: Dictionary, map: BattleMap) -> Battlefield:
	var f := Battlefield.new(map)
	f.gate_hp = int(d.get("gate_hp", f.gate_hp))
	f.gate_hp_max = int(d.get("gate_hp_max", f.gate_hp_max))
	f.rift_pressure = int(d.get("rift_pressure", 0))
	f.rift_pressure_max = int(d.get("rift_pressure_max", f.rift_pressure_max))
	f.spawn_faction = str(d.get("spawn_faction", f.spawn_faction))
	var table: Array = []
	for e in d.get("spawn_table", []):
		table.append([str(e[0]), int(e[1])])
	if not table.is_empty():
		f.spawn_table = table
	f._spawn_index = int(d.get("spawn_index", 0))
	f.phase = int(d.get("phase", 0))
	for line in d.get("log", []):
		f.log.append(str(line))
	for ud in d.get("units", []):
		f.units.append(_unit_from(ud))
	f._next_id = int(d.get("next_id", 1))
	return f


# ---------------------------------------------------------------- units

static func _unit_dict(u: Unit) -> Dictionary:
	var faces = null
	if u.die != null:
		faces = []
		for face in u.die.faces:
			faces.append(_face_dict(face))
	var damaged := {}
	for idx in u.damaged_faces.keys():
		damaged[str(idx)] = _face_dict(u.damaged_faces[idx])
	var paint := {}
	for k in u.paint.keys():
		paint[str(k)] = (u.paint[k] as Color).to_html()
	var mods: Array = []
	for m in u.modifiers:
		mods.append(_modifier_dict(m))
	return {
		"id": u.id, "name": u.display_name, "side": u.side, "pos": _hex(u.pos),
		"hull": u.hull, "shield": u.shield, "base": u.base, "modifiers": mods, "allies": u.allies,
		"traits": u.traits, "footprint": _hexes(u.footprint), "facing": u.facing,
		"faction": u.faction, "foe_id": u.foe_id, "strength": u.strength, "behaviour": u.behaviour, "hunts": u.hunts, "prey": u.prey, "elite": u.elite, "zone": u.zone,
		"die": faces, "paint": paint, "passive": u.passive, "chassis_id": u.chassis_id,
		"hardpoints": u.hardpoints, "damaged_faces": damaged,
	}


static func _unit_from(d: Dictionary) -> Unit:
	var u := Unit.new()
	u.id = int(d.get("id", 0))
	u.display_name = str(d.get("name", ""))
	u.side = int(d.get("side", Unit.Side.PLAYER))
	u.pos = _hex_from(d.get("pos", [0, 0]))
	u.hull = int(d.get("hull", 100))
	u.shield = int(d.get("shield", 0))
	var base: Dictionary = d.get("base", {})
	for k in base.keys():
		u.base[str(k)] = int(base[k])
	for md in d.get("modifiers", []):
		u.modifiers.append(_modifier_from(md))
	u.allies = int(d.get("allies", 0))
	u.traits.clear()
	for t in d.get("traits", []):
		u.traits.append(str(t))
	var fp: Array = d.get("footprint", [])
	if not fp.is_empty():
		u.footprint = _hexes_from(fp)
	u.facing = int(d.get("facing", 0))
	u.faction = str(d.get("faction", ""))
	u.foe_id = str(d.get("foe_id", ""))
	u.strength = int(d.get("strength", 0))
	u.behaviour = str(d.get("behaviour", "aggressive" if bool(d.get("aggro", false)) else "push"))
	u.hunts = str(d.get("hunts", "nearest"))
	u.prey = int(d.get("prey", 0))
	u.zone = int(d.get("zone", 1))
	u.elite = bool(d.get("elite", false))
	var faces = d.get("die", null)
	if faces is Array:
		var list: Array = []
		for fd in faces:
			list.append(_face_from(fd))
		u.die = Die.of(list)
	for k in d.get("paint", {}).keys():
		u.paint[str(k)] = Color.html(str(d["paint"][k]))
	var p = d.get("passive", {})
	u.passive = p if p is Dictionary else {}
	u.chassis_id = str(d.get("chassis_id", ""))
	u.hardpoints = int(d.get("hardpoints", 0))
	for idx in d.get("damaged_faces", {}).keys():
		u.damaged_faces[int(str(idx))] = _face_from(d["damaged_faces"][idx])
	return u


## A die entry with everything the die keeps beyond the content shape: its damage state,
## its component, whether it is fixed or an empty hardpoint.
static func _face_dict(f: Face) -> Dictionary:
	var d := f.to_dict()
	d["cracked"] = f.cracked
	d["component"] = f.component
	d["empty"] = f.empty
	d["fixed"] = f.fixed
	if not f.label.is_empty():
		d["label"] = f.label
	return d


static func _face_from(d: Dictionary) -> Face:
	var f := Face.from_dict(d)
	f.cracked = bool(d.get("cracked", false))
	f.component = str(d.get("component", ""))
	f.empty = bool(d.get("empty", false))
	f.fixed = bool(d.get("fixed", false))
	return f


static func _modifier_dict(m: Effects.Modifier) -> Dictionary:
	return {
		"id": m.id, "name": m.name, "description": m.description, "source": m.source,
		"component": m.component, "scope": m.scope, "expires_round": m.expires_round,
		"tags": m.tags, "effects": m.effects, "seq": m.seq, "stacks": m.stacks, "decay": m.decay,
	}


static func _modifier_from(d: Dictionary) -> Effects.Modifier:
	var m := Effects.Modifier.new()
	m.id = str(d.get("id", ""))
	m.name = str(d.get("name", ""))
	m.description = str(d.get("description", ""))
	m.source = str(d.get("source", ""))
	m.component = str(d.get("component", ""))
	m.scope = int(d.get("scope", Effects.LOADOUT))
	m.expires_round = int(d.get("expires_round", -1))
	for t in d.get("tags", []):
		m.tags.append(str(t))
	m.effects = d.get("effects", [])
	m.seq = int(d.get("seq", 0))
	m.stacks = int(d.get("stacks", 1))
	m.decay = int(d.get("decay", Effects.DECAY_NONE))
	# Grant order decides override ties; the counter carries on past the loaded ones.
	Effects._seq = maxi(Effects._seq, m.seq)
	return m


# ---------------------------------------------------------------- the skirmish

static func _skirmish_dict(sk: Skirmish, field: Battlefield) -> Dictionary:
	var mechs: Array = []
	for ms in sk.mechs:
		mechs.append({"unit": ms.unit.id, "heat": ms.heat, "heat_max": ms.heat_max, "face_index": ms.face_index,
			"locked": ms.locked, "assigned": ms.assigned, "free_rerolls": ms.free_rerolls})
	var packs: Array = []
	for sq in sk.packs:
		packs.append(sq.id)
	# Every foe once, on the field or waiting, by index; the ranks and the queue point at them.
	var foes: Array[Foe] = []
	for f in sk.field_foes():
		foes.append(f)
	for f in sk.reinforcements:
		if not foes.has(f):
			foes.append(f)
	var foe_dicts: Array = []
	for f in foes:
		foe_dicts.append(_foe_dict(f, sk))
	var front: Array = []
	var back: Array = []
	for col in range(sk.columns):
		front.append(foes.find(sk.front[col]) if sk.front[col] != null else -1)
		back.append(foes.find(sk.back[col]) if sk.back[col] != null else -1)
	var queue: Array = []
	for f in sk.reinforcements:
		queue.append(foes.find(f))
	return {
		"rng": str(sk.rng.state), "columns": sk.columns, "terrain": sk.terrain,
		"round": sk.round, "rerolls_left": sk.rerolls_left, "state": sk.state, "outcome": sk.outcome,
		"log": sk.log, "mechs": mechs, "packs": packs, "foes": foe_dicts, "front": front, "back": back,
		"reinforcements": queue,
	}


static func _skirmish_from(d: Dictionary, field: Battlefield) -> Skirmish:
	var sk := Skirmish.new(0, int(d.get("columns", Skirmish.DEFAULT_COLUMNS)))
	sk.rng.state = str(d.get("rng", "0")).to_int()
	sk.terrain = int(d.get("terrain", BattleMap.Terrain.PLAIN))
	sk.round = int(d.get("round", 0))
	sk.rerolls_left = int(d.get("rerolls_left", 0))
	sk.state = int(d.get("state", Skirmish.State.SETUP))
	sk.outcome = int(d.get("outcome", Skirmish.Outcome.NONE))
	for line in d.get("log", []):
		sk.log.append(str(line))
	for md in d.get("mechs", []):
		var u := field.unit_by_id(int(md.get("unit", 0)))
		if u == null:
			continue
		var ms := sk.add_mech(u)
		ms.heat = int(md.get("heat", 0))
		ms.heat_max = int(md.get("heat_max", ms.heat_max))
		ms.face_index = int(md.get("face_index", -1))
		ms.locked = bool(md.get("locked", false))
		ms.assigned = bool(md.get("assigned", false))
		ms.free_rerolls = int(md.get("free_rerolls", 0))
	for pid in d.get("packs", []):
		var sq := field.unit_by_id(int(pid))
		if sq != null:
			sk.packs.append(sq)
	var foes: Array[Foe] = []
	for fd in d.get("foes", []):
		foes.append(_foe_from(fd, sk))
	var front: Array = d.get("front", [])
	var back: Array = d.get("back", [])
	for col in range(sk.columns):
		var fi := int(front[col]) if col < front.size() else -1
		var bi := int(back[col]) if col < back.size() else -1
		sk.front[col] = foes[fi] if fi >= 0 and fi < foes.size() else null
		sk.back[col] = foes[bi] if bi >= 0 and bi < foes.size() else null
	for qi in d.get("reinforcements", []):
		var i := int(qi)
		if i >= 0 and i < foes.size():
			sk.reinforcements.append(foes[i])
	return sk


static func _foe_dict(f: Foe, sk: Skirmish) -> Dictionary:
	var mods: Array = []
	for m in f.modifiers:
		mods.append(_modifier_dict(m))
	var target := -1
	if f.target != null:
		target = sk.mechs.find(f.target)
	return {
		"name": f.display_name, "content_id": f.content_id, "hp": f.hp, "hp_max": f.hp_max, "attack": f.attack,
		"prefers_back": f.prefers_back, "pack_id": f.pack_id, "size": f.size, "stun_resist": f.stun_resist,
		"actions": f.actions, "rank": f.rank, "column": f.column, "target": target,
		"action": f.actions.find(f.action), "modifiers": mods,
	}


static func _foe_from(d: Dictionary, sk: Skirmish) -> Foe:
	var f := Foe.new()
	f.display_name = str(d.get("name", "foe"))
	f.content_id = str(d.get("content_id", ""))
	f.hp = int(d.get("hp", 30))
	f.hp_max = int(d.get("hp_max", f.hp))
	f.attack = int(d.get("attack", 10))
	f.prefers_back = bool(d.get("prefers_back", false))
	f.pack_id = int(d.get("pack_id", 0))
	f.size = int(d.get("size", 1))
	f.stun_resist = int(d.get("stun_resist", 0))
	f.actions = []
	for a in d.get("actions", []):
		var act: Dictionary = a.duplicate()
		for key in ["strikes", "weight"]:
			if act.has(key):
				act[key] = int(act[key])
		f.actions.append(act)
	if f.actions.is_empty():
		f.actions = [Foe.basic_action()]
	f.rank = int(d.get("rank", -1))
	f.column = int(d.get("column", -1))
	var ti := int(d.get("target", -1))
	f.target = sk.mechs[ti] if ti >= 0 and ti < sk.mechs.size() else null
	var ai := int(d.get("action", -1))
	f.action = f.actions[ai] if ai >= 0 and ai < f.actions.size() else f.actions[0]
	for md in d.get("modifiers", []):
		f.modifiers.append(_modifier_from(md))
	return f


# ---------------------------------------------------------------- hexes

static func _hex(h: Vector2i) -> Array:
	return [h.x, h.y]


static func _hex_from(a) -> Vector2i:
	return Vector2i(int(a[0]), int(a[1])) if a is Array and a.size() >= 2 else Vector2i.ZERO


static func _hexes(list) -> Array:
	var out: Array = []
	for h in list:
		out.append(_hex(h))
	return out


static func _hexes_from(list) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for a in list:
		out.append(_hex_from(a))
	return out

class_name SaveGame
extends RefCounted

## One battle, whole, as plain data and back (built 30 September, for a phone that may be
## put down mid-fight), and since 6 October the run around it (`user://campaign.json`, the
## battle under way inside it) and the profile that outlives every run (`user://profile.json`): the map by its seed, every unit with its numbers, die, damage and
## live modifiers, the player's turn (who has moved and fought, the fights hunters forced), and the skirmish under
## way with its dice, foes, ranks and both random streams, so a resumed fight plays on
## exactly as it would have. Headless, like everything in sim/: the screens only decide
## when to call it.
##
## The file is JSON under user://. Every number comes back as a float from JSON, so the
## reader casts; a random stream's state is a 64-bit integer, which JSON cannot hold, so
## it travels as a string. Nothing here is shown to the player.

const PATH := "user://battle.json"
const VERSION := 9   # 2: moves in tens (2 October); 3: the water feature and the map's kind (3 and 4 October); 4: the generator's roads changed under every seed, and the guest, kills and wrecks (6 October); 5: the redesigned round, a turn of actions and fights in place of routes and contacts (8 October); 6: moves in hexes, a move in one go (28 October's movement proposal); 7: the six map shapes, every seed's map laid anew (29 October); 8: the fords and streets three or four in all, every river and city laid anew, and the horde wading (29 October); 9: hunters at ring two, and a sealed-off prey's stand-in in place of the re-pick (29 October)


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
	var forced: Array = []
	for f in b.forced:
		var hunters: Array = []
		for h in f["hunters"]:
			hunters.append(h.id)
		forced.append({"prey": f["prey"].id, "hunters": hunters})
	var moved: Array = []
	for uid in b.moved.keys():
		moved.append(int(uid))
	return {
		"version": VERSION,
		"seed": b.seed_value,
		"rng": str(b.rng.state),
		"faction": b.faction,
		"guest": b.guest,
		"foes_killed": b.foes_killed,
		"menace_killed": b.menace_killed,
		"tier": b.tier, "ramp": b.ramp,
		"thresholds": b.thresholds, "fractures": b.fractures, "rupture_turn": b.rupture_turn, "stall_guard": b.stall_guard,
		"elites_spawned": b.elites_spawned, "field_menace": b.field_menace,
		"sponsorship": b.sponsorship,
		"action_hexes": _int_keys(b.action_hexes),
		"wrecks": _units(b.wrecks),
		"state": b.state,
		"outcome": b.outcome,
		"spent": _int_keys(b.spent),
		"fought": _int_keys(b.fought),
		"moved": moved,
		"history": b.history,   # the turn's undo, in order: snapshots kept JSON's way already
		"planned": b.planned,   # and the moves not yet played on the map
		"forced": forced,
		"orders": _order_ids(b.orders),
		"boss_fight": b.boss_fight,
		"boss": b.boss.id if b.boss != null else -1,
		"skirmishes_fought": b.skirmishes_fought,
		"columns": b.columns,
		"map": {"w": b.map.width, "h": b.map.height, "seed": b.map.map_seed, "kind": b.map.kind},
		"field": _field_dict(b.field),
		"skirmish": _skirmish_dict(b.current, b.field) if b.current != null else null,
		"lineup": b.lineup, "escort": b.escort,
	}


## Attack orders as mech id -> target id, with string keys for JSON.
static func _order_ids(orders: Dictionary) -> Dictionary:
	var out := {}
	for k in orders.keys():
		out[str(k)] = (orders[k] as Unit).id
	return out


## A dictionary keyed by unit id, with string keys for JSON.
static func _int_keys(d: Dictionary) -> Dictionary:
	var out := {}
	for k in d.keys():
		out[str(k)] = d[k]
	return out


static func _units(list: Array) -> Array:
	var out: Array = []
	for u in list:
		out.append(_unit_dict(u))
	return out


static func from_dict(d: Dictionary) -> Battle:
	var b := Battle.new(int(d.get("seed", 1)))
	b.rng.state = str(d.get("rng", "0")).to_int()
	b.faction = str(d.get("faction", ""))
	b.guest = str(d.get("guest", ""))
	b.foes_killed = int(d.get("foes_killed", 0))
	b.menace_killed = int(d.get("menace_killed", 0))
	b.tier = int(d.get("tier", 0))
	b.ramp = int(d.get("ramp", 0))
	for t in d.get("thresholds", []):
		b.thresholds.append(int(t))
	b.fractures = int(d.get("fractures", 0))
	b.rupture_turn = int(d.get("rupture_turn", -1))
	b.stall_guard = bool(d.get("stall_guard", false))
	b.elites_spawned = _strings(d.get("elites_spawned", []))
	b.field_menace = int(d.get("field_menace", 0))
	var tally: Dictionary = d.get("sponsorship", {})
	for k in tally.keys():
		b.sponsorship[str(k)] = int(tally[k])
	var hexes: Dictionary = d.get("action_hexes", {})
	for uid in hexes.keys():
		b.action_hexes[int(str(uid))] = int(hexes[uid])
	for wd in d.get("wrecks", []):
		b.wrecks.append(_unit_from(wd))
	b.state = int(d.get("state", Battle.State.PLAN))
	b.outcome = int(d.get("outcome", Battle.Outcome.NONE))
	var md: Dictionary = d.get("map", {})
	var w := int(md.get("w", Battle.DEFAULT_WIDTH))
	var h := int(md.get("h", Battle.DEFAULT_HEIGHT))
	var map_seed := int(md.get("seed", 0))
	b.map_kind = str(md.get("kind", ""))
	b.map = BattleMap.generate(w, h, map_seed, b.map_kind) if map_seed != 0 else BattleMap.flat(w, h)
	b.field = _field_from(d.get("field", {}), b.map)
	# What the map knows of each foe type, from the content as the setup gives it: a pack Rift
	# Pressure spawns after a resume is dressed by it, its ring, move and hunt (the mechanics
	# audit, 25 October: a resumed battle's spawns came out as plain pushers).
	b.field.foe_profiles = b.db.pack_profiles()
	for uid in d.get("spent", {}).keys():
		b.spent[int(str(uid))] = int(d["spent"][uid])
	for uid in d.get("fought", {}).keys():
		b.fought[int(str(uid))] = true
	for uid in d.get("moved", []):
		b.moved[int(uid)] = true
	# The undo and the plan (25 October), as they were; the snapshots read a JSON round trip's
	# floats and string keys themselves (Battle._restore, Battle.plan_pieces).
	b.history = (d.get("history", []) as Array).duplicate(true)
	b.planned = (d.get("planned", []) as Array).duplicate(true)
	for fd in d.get("forced", []):
		var prey := b.field.unit_by_id(int(fd.get("prey", -1)))
		var hunters: Array = []
		for hid in fd.get("hunters", []):
			var hunter := b.field.unit_by_id(int(hid))
			if hunter != null:
				hunters.append(hunter)
		if prey != null and not hunters.is_empty():
			b.forced.append({"prey": prey, "hunters": hunters})
	for uid in d.get("orders", {}).keys():
		var target := b.field.unit_by_id(int(d["orders"][uid]))
		if target != null:
			b.orders[int(str(uid))] = target
	b.boss_fight = bool(d.get("boss_fight", false))
	var boss_id := int(d.get("boss", -1))
	b.boss = b.field.unit_by_id(boss_id) if boss_id >= 0 else null
	b.skirmishes_fought = int(d.get("skirmishes_fought", 0))
	b.columns = int(d.get("columns", Skirmish.DEFAULT_COLUMNS))
	var sd = d.get("skirmish", null)
	if sd is Dictionary:
		b.current = _skirmish_from(sd, b.field)
		b.current.foe_factory = b.foe_factory()   # a resumed fight splits, summons and regrows as the fresh one did
	b.lineup = _strings(d.get("lineup", []))
	var esc: Array = d.get("escort", [])
	b.escort = [str(esc[0]), int(esc[1])] if esc.size() >= 2 else []
	return b


# ---------------------------------------------------------------- the field

static func _field_dict(f: Battlefield) -> Dictionary:
	var units: Array = []
	for u in f.units:
		units.append(_unit_dict(u))
	var tears: Array = []
	for t in f.tears:
		tears.append([(t["pos"] as Vector2i).x, (t["pos"] as Vector2i).y, int(t.get("opened", 0))])
	return {
		"gate_hp": f.gate_hp, "gate_hp_max": f.gate_hp_max,
		"rift_pressure": f.rift_pressure, "rift_pressure_max": f.rift_pressure_max,
		"spawn_faction": f.spawn_faction, "ramp": f.ramp,
		"cycle": f.cycle, "patrol_cycle": f.patrol_cycle, "cycle_index": f._cycle_index, "patrol_index": f._patrol_index,
		"seam_row": f.seam_row, "tears": tears, "peaks": f.peaks, "rift_spawns": f.rift_spawns, "tear_spawns": f.tear_spawns,
		"phase": f.phase, "log": f.log, "next_id": f._next_id,
		"units": units,
	}


## Compositions as the cycle holds them, read back from JSON (members as [id, count] pairs).
static func _compositions_from(list: Array) -> Array:
	var out: Array = []
	for c in list:
		if not (c is Dictionary):
			continue
		var members: Array = []
		for m in c.get("members", []):
			if m is Array and (m as Array).size() >= 2:
				members.append([str(m[0]), int(m[1])])
		out.append({"id": str(c.get("id", "")), "size": str(c.get("size", "patrol")), "faction": str(c.get("faction", "")), "members": members})
	return out


static func _field_from(d: Dictionary, map: BattleMap) -> Battlefield:
	var f := Battlefield.new(map)
	f.gate_hp = int(d.get("gate_hp", f.gate_hp))
	f.gate_hp_max = int(d.get("gate_hp_max", f.gate_hp_max))
	f.rift_pressure = int(d.get("rift_pressure", 0))
	f.rift_pressure_max = int(d.get("rift_pressure_max", f.rift_pressure_max))
	f.spawn_faction = str(d.get("spawn_faction", f.spawn_faction))
	f.ramp = int(d.get("ramp", 0))
	f.cycle = _compositions_from(d.get("cycle", []))
	f.patrol_cycle = _compositions_from(d.get("patrol_cycle", []))
	# A save from before the compositions (30 October) holds a spawn table: each entry a pack of
	# one type, cycled by the rift and the tears alike.
	for e in d.get("spawn_table", []):
		f.cycle.append(Battlefield.composition([[str(e[0]), int(e[1])]], str(e[2]) if e.size() > 2 else f.spawn_faction))
	if f.patrol_cycle.is_empty() and d.has("spawn_table"):
		f.patrol_cycle = f.cycle.duplicate(true)
	f._cycle_index = int(d.get("cycle_index", d.get("spawn_index", 0)))
	f._patrol_index = int(d.get("patrol_index", 0))
	f.seam_row = int(d.get("seam_row", Battlefield.SEAM_START))
	for t in d.get("tears", []):
		f.tears.append({"pos": Vector2i(int(t[0]), int(t[1])), "opened": int(t[2]) if t.size() > 2 else 0})
	f.peaks = int(d.get("peaks", 0))
	f.rift_spawns = int(d.get("rift_spawns", 0))
	f.tear_spawns = int(d.get("tear_spawns", 0))
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
		"faction": u.faction, "foe_id": u.foe_id, "strength": u.strength, "members": u.members, "composition": u.composition, "composition_size": u.composition_size, "behaviour": u.behaviour, "hunts": u.hunts, "prey": u.prey, "is_boss": u.is_boss, "sealed": u.sealed, "lineup": u.lineup, "boss_tier": u.boss_tier, "zone": u.zone, "attack_range": u.attack_range,
		"die": faces, "paint": paint, "passive": u.passive, "chassis_id": u.chassis_id,
		"hardpoints": u.hardpoints, "damaged_faces": damaged, "modules": u.modules,
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
	for m in d.get("members", []):   # a composition's members (30 October); a save from before has none
		if m is Array and (m as Array).size() >= 2:
			u.members.append([str(m[0]), int(m[1])])
	u.composition = str(d.get("composition", ""))
	u.composition_size = str(d.get("composition_size", ""))
	u.behaviour = str(d.get("behaviour", "push"))
	u.hunts = str(d.get("hunts", "nearest"))
	u.prey = int(d.get("prey", 0))
	u.zone = int(d.get("zone", 1))
	u.attack_range = int(d.get("attack_range", 2))
	u.is_boss = bool(d.get("is_boss", d.get("elite", false)))   # a save from before 15 October says elite
	u.sealed = bool(d.get("sealed", false))
	u.lineup = _strings(d.get("lineup", []))
	u.boss_tier = int(d.get("boss_tier", 0))
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
	for mid in d.get("modules", []):   # the fitted modules' ids, for the codex (their effects are the modifiers above)
		u.modules.append(str(mid))
	return u


## A die entry with everything the die keeps beyond the content shape: its component,
## whether it is fixed or an empty hardpoint (a destroyed one is a blank).
static func _face_dict(f: Face) -> Dictionary:
	var d := f.to_dict()
	d["component"] = f.component
	d["empty"] = f.empty
	d["fixed"] = f.fixed
	if not f.tags.is_empty():
		d["tags"] = f.tags
	if not f.label.is_empty():
		d["label"] = f.label
	return d


static func _face_from(d: Dictionary) -> Face:
	var f := Face.from_dict(d)
	f.component = str(d.get("component", ""))
	f.empty = bool(d.get("empty", false))
	f.fixed = bool(d.get("fixed", false))
	for t in d.get("tags", []):
		f.tags.append(str(t))
	return f


static func _modifier_dict(m: Effects.Modifier) -> Dictionary:
	return {
		"id": m.id, "name": m.name, "description": m.description, "source": m.source,
		"component": m.component, "scope": m.scope, "expires_round": m.expires_round,
		"tags": m.tags, "effects": m.effects, "seq": m.seq, "stacks": m.stacks, "decay": m.decay,
		"slept": m.slept,
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
	m.slept = bool(d.get("slept", false))
	# Grant order decides override ties; the counter carries on past the loaded ones.
	Effects._seq = maxi(Effects._seq, m.seq)
	return m


# ---------------------------------------------------------------- the skirmish

static func _skirmish_dict(sk: Skirmish, field: Battlefield) -> Dictionary:
	var mechs: Array = []
	for ms in sk.mechs:
		mechs.append({"unit": ms.unit.id, "heat": ms.heat, "heat_max": ms.heat_max, "face_index": ms.face_index,
			"locked": ms.locked, "assigned": ms.assigned, "free_rerolls": ms.free_rerolls, "ammo": ms.ammo, "ammo_max": ms.ammo_max})
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
	var paired: Array = []   # the twin slots (the Gel's halves): each slot and its right-hand half
	for at in sk.twins.keys():
		paired.append([at.x, at.y, foes.find(sk.twins[at])])
	# The mines (the Lammergeier's): each slot's shots in laid order, the slot as its rank and column.
	var mined: Array = []
	for slot in sk.mines.keys():
		mined.append({"rank": slot.x, "column": slot.y, "shots": sk.mines[slot]})
	return {
		"rng": str(sk.rng.state), "columns": sk.columns, "terrain": sk.terrain, "ground": sk.ground,
		"round": sk.round, "rerolls_left": sk.rerolls_left, "banked": sk.banked, "state": sk.state, "outcome": sk.outcome,
		"log": sk.log, "mechs": mechs, "packs": packs, "foes": foe_dicts, "front": front, "back": back,
		"reinforcements": queue, "mines": mined, "mine_seq": sk.mine_seq, "committed": sk.committed, "twins": paired,
		"joined_fallen": _int_keys(sk.joined_fallen),
		"joined_fallen_types": _typed_tallies(sk.joined_fallen_types),
		"came_with": _typed_tallies(sk.came_with),
		"team_kills": sk.team_kills,
	}


static func _skirmish_from(d: Dictionary, field: Battlefield) -> Skirmish:
	return _skirmish_build(d, func(uid: int) -> Unit: return field.unit_by_id(uid))


## A deep copy of a skirmish and its machines through the save's own round trip (the planner's
## rollouts, the stock pass's second chunk, 22 October): every unit and live modifier, the dice,
## the foes and their intents, the ranks, the queue, the mines and the random stream's state,
## so the copy plays on exactly as the original would. What the save leaves to the battle (the
## runner's targeting rule, the summoning factory, a roar's reroll debt) is carried across;
## the log is not. The copy finds its units by place, the machines first and the packs after,
## never by id: a test's machines may share one.
static func clone_skirmish(sk: Skirmish) -> Skirmish:
	var d := _skirmish_dict(sk, null)
	d["log"] = []
	var units: Array[Unit] = []
	for i in range(sk.mechs.size()):
		units.append(_unit_from(_unit_dict(sk.mechs[i].unit)))
		d["mechs"][i]["unit"] = units.size() - 1
	var packs: Array = []
	for sq in sk.packs:
		units.append(_unit_from(_unit_dict(sq)))
		packs.append(units.size() - 1)
	d["packs"] = packs
	var c := _skirmish_build(d, func(at: int) -> Unit: return units[at] if at >= 0 and at < units.size() else null)
	c.targeting_override = sk.targeting_override
	c.foe_factory = sk.foe_factory
	c.reroll_debt = sk.reroll_debt
	return c


## A skirmish from its dictionary, its units found by id through `lookup` (the battlefield's on
## a resume, a copy's own on a clone).
static func _skirmish_build(d: Dictionary, lookup: Callable) -> Skirmish:
	var sk := Skirmish.new(0, int(d.get("columns", Skirmish.DEFAULT_COLUMNS)))
	sk.rng.state = str(d.get("rng", "0")).to_int()
	sk.terrain = int(d.get("terrain", BattleMap.Terrain.PLAIN))
	sk.ground = str(d.get("ground", BattleMap.TERRAIN_NAMES.get(sk.terrain, "plain")))
	sk.round = int(d.get("round", 0))
	sk.rerolls_left = int(d.get("rerolls_left", 0))
	sk.banked = int(d.get("banked", 0))   # the rerolls Maverick's Playbook carries to the next round (30 October)
	sk.committed = bool(d.get("committed", false))
	sk.state = int(d.get("state", Skirmish.State.SETUP))
	sk.outcome = int(d.get("outcome", Skirmish.Outcome.NONE))
	for line in d.get("log", []):
		sk.log.append(str(line))
	for md in d.get("mechs", []):
		var u: Unit = lookup.call(int(md.get("unit", 0)))
		if u == null:
			continue
		var ms := sk.add_mech(u)
		ms.heat = int(md.get("heat", 0))
		ms.heat_max = int(md.get("heat_max", ms.heat_max))
		ms.face_index = int(md.get("face_index", -1))
		ms.locked = bool(md.get("locked", false))
		ms.assigned = bool(md.get("assigned", false))
		ms.free_rerolls = int(md.get("free_rerolls", 0))
		ms.ammo_max = int(md.get("ammo_max", ms.ammo_max))
		ms.ammo = int(md.get("ammo", ms.ammo))
	for pid in d.get("packs", []):
		var sq: Unit = lookup.call(int(pid))
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
	for tw in d.get("twins", []):
		var ti := int(tw[2])
		if ti >= 0 and ti < foes.size():
			sk.twins[Vector2i(int(tw[0]), int(tw[1]))] = foes[ti]
	for qi in d.get("reinforcements", []):
		var i := int(qi)
		if i >= 0 and i < foes.size():
			sk.reinforcements.append(foes[i])
	for md in d.get("mines", []):
		var shots: Array = []
		for sd in md.get("shots", []):
			var shot: Dictionary = (sd as Dictionary).duplicate(true)
			var kws: Array = []
			for k in shot.get("keywords", []):
				kws.append(int(k))
			shot["keywords"] = kws
			for key in ["damage", "seq", "burn", "cryo", "flak"]:
				shot[key] = int(shot.get(key, 0))
			for key in ["row", "column", "chain"]:
				if shot.has(key):
					shot[key] = int(shot[key])   # its area numbers and Chain's (28 October); a shot laid before them has none: its area lands half and it arcs nothing (Skirmish._mine_hit)
			shot["mech"] = int(shot.get("mech", -1))
			shot["by"] = str(shot.get("by", ""))
			var fd: Dictionary = shot.get("face", {})
			shot["face"] = Face.from_dict(fd).to_dict() if not fd.is_empty() else {}
			shots.append(shot)
		if not shots.is_empty():
			sk.mines[Vector2i(int(md.get("rank", 0)), int(md.get("column", 0)))] = shots
	sk.mine_seq = int(d.get("mine_seq", 0))
	var joined: Dictionary = d.get("joined_fallen", {})
	for pid in joined.keys():
		sk.joined_fallen[int(str(pid))] = int(joined[pid])
	sk.joined_fallen_types = _typed_tallies_from(d.get("joined_fallen_types", {}))
	sk.came_with = _typed_tallies_from(d.get("came_with", {}))
	sk.team_kills = int(d.get("team_kills", 0))   # the foes the team has killed this fight (30 October)
	return sk


## A tally by pack and type (pack id -> {content id: count}), with string keys for JSON.
static func _typed_tallies(t: Dictionary) -> Dictionary:
	var out := {}
	for pid in t.keys():
		var inner := {}
		for cid in (t[pid] as Dictionary).keys():
			inner[str(cid)] = int(t[pid][cid])
		out[str(pid)] = inner
	return out


static func _typed_tallies_from(d: Dictionary) -> Dictionary:
	var out := {}
	for pid in d.keys():
		var inner := {}
		for cid in (d[pid] as Dictionary).keys():
			inner[str(cid)] = int(d[pid][cid])
		out[int(str(pid))] = inner
	return out


static func _foe_dict(f: Foe, sk: Skirmish) -> Dictionary:
	var mods: Array = []
	for m in f.modifiers:
		mods.append(_modifier_dict(m))
	var target := -1
	if f.target != null:
		target = sk.mechs.find(f.target)
	return {
		"name": f.display_name, "content_id": f.content_id, "hp": f.hp, "hp_max": f.hp_max, "attack": f.attack,
		"prefers_back": f.prefers_back, "pack_id": f.pack_id, "size": f.size, "armour": f.armour, "aim": f.aim, "last_special": f.last_special, "kin": f.kin,
		"actions": f.actions, "rank": f.rank, "column": f.column, "target": target,
		"action": f.actions.find(f.action), "modifiers": mods,
		"boss": f.boss, "hero": f.hero, "commands": f.commands, "escorts": f.escorts, "on_death": f.on_death, "stays_down": f.stays_down, "joined": f.joined, "fresh": f.fresh,
		"pending": f.actions.find(f.pending) if not f.pending.is_empty() else -1, "charge": f.charge,
		"part_ids": f.part_ids, "guard": f.guard, "regrow_parts": f.regrow_parts, "regrow_due": f.regrow_due,
		"next_move": f.next_move, "committed": f.committed, "held": f.held, "grudge": f.grudge, "spent_once": f.spent_once, "swallow_mark": f.swallow_mark,
		"rage": f.rage, "golden_mark": f.golden_mark,
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
	f.armour = int(d.get("armour", 0))
	f.aim = str(d.get("aim", Foe.AIM_EXPOSED))
	f.last_special = str(d.get("last_special", ""))
	f.kin = int(d.get("kin", 0))
	f.boss = bool(d.get("boss", f.size >= 2))   # a save from before 15 October read a massive foe as the boss
	f.hero = bool(d.get("hero", false))
	f.commands = bool(d.get("commands", f.boss))   # a save from before 21 October: a boss commanded its unit
	f.escorts = bool(d.get("escorts", false))
	var od = d.get("on_death", {})
	if od is Dictionary and od.has("summon"):
		f.on_death = {"summon": str(od["summon"]), "count": maxi(1, int(od.get("count", 1)))}
		if bool(od.get("pair", false)):
			f.on_death["pair"] = true   # the halves stand as a pair in its slot (26 October)
	if od is Dictionary and od.get("blow", null) is Dictionary:
		f.on_death["blow"] = Foe.death_blow_from(od["blow"])   # a last act (15 October)
	f.stays_down = bool(d.get("stays_down", false))
	f.joined = bool(d.get("joined", false))
	f.fresh = bool(d.get("fresh", false))
	f.actions = []
	for a in d.get("actions", []):
		var act: Dictionary = a.duplicate()
		for key in ["strikes", "weight", "swarm", "value", "count", "countdown"]:
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
	f.part_ids = Array(d.get("part_ids", [])).map(func(x): return str(x))   # a boss in parts (15 October)
	f.guard = str(d.get("guard", ""))
	f.regrow_parts = int(d.get("regrow_parts", 0))
	f.regrow_due = Array(d.get("regrow_due", [])).map(func(x): return [str(x[0]), int(x[1])])
	f.next_move = str(d.get("next_move", ""))   # a follow-up it announces next round (30 October)
	f.committed = bool(d.get("committed", false))   # its action the announced follow-up, which no Disrupt turns (2 November)
	f.grudge = int(d.get("grudge", 0))   # the team's kills its grudge reads (30 October)
	f.spent_once = Array(d.get("spent_once", [])).map(func(x): return str(x))   # its moves used once a fight (30 October)
	f.swallow_mark = int(d.get("swallow_mark", -1))   # its HP as it swallowed, -1 holding none (31 October)
	f.rage = int(d.get("rage", 0))   # what the team's safe spends add to its blows once it has bellowed (3 November)
	f.golden_mark = int(d.get("golden_mark", -1))   # its HP as it went gold, -1 while calm (4 November)
	var hd = d.get("held", {})   # what a steal took (30 October)
	if hd is Dictionary and not hd.is_empty():
		f.held = {"name": str(hd.get("name", "")), "power": int(hd.get("power", 0)), "fake": bool(hd.get("fake", false))}
	var pi := int(d.get("pending", -1))   # a countdown move it was gathering (15 October)
	if pi >= 0 and pi < f.actions.size():
		f.pending = f.actions[pi]
		f.charge = int(d.get("charge", 0))
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


# ---------------------------------------------------------------- the run

const RUN_PATH := "user://campaign.json"
const RUN_VERSION := 8   # 2: the threat became the Convergence; 3: Favour and the starting blueprints (7 October); 4: the battle inside it in the redesigned round (8 October); 5: the battle inside it in hexes (28 October); 6: the battle inside it on the six map shapes (29 October); 7: the battle inside it with the fords and streets laid anew (29 October); 8: the battle inside it with the hunters at ring two (29 October)


static func save_campaign(c: Campaign, path: String = RUN_PATH) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(campaign_to_dict(c)))
	f.close()
	return true


## The saved run, or null when there is none or it cannot be read.
static func load_campaign(path: String = RUN_PATH) -> Campaign:
	if not FileAccess.file_exists(path):
		return null
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary) or int(parsed.get("version", 0)) != RUN_VERSION:
		return null
	return campaign_from_dict(parsed)


static func campaign_to_dict(c: Campaign) -> Dictionary:
	var cities: Array = []
	for city in c.cities.values():
		cities.append({"id": city.id, "capital": city.capital, "gate": city.gate, "gate_max": city.gate_max,
			"fallen": city.fallen, "quiet": city.quiet, "rift": city.rift})
	var roster: Array = []
	for m in c.roster:
		roster.append({"uid": m.uid, "chassis": m.chassis, "loadout": m.loadout, "shop": m.shop})
	return {
		"version": RUN_VERSION,
		"seed": c.seed_value,
		"rng": str(c.rng.state),
		"state": c.state, "won": c.won, "turn": c.turn, "convergence": c.convergence,
		"cities": cities, "roster": roster, "next_uid": c._next_uid,
		"components": c.components, "salvage": c.salvage, "favour": c.favour, "blueprints": c.blueprints,
		"tokens": c.tokens, "offers": c.offers, "bosses_beaten": c.bosses_beaten, "bosses_ended": c.bosses_ended, "finals_won": c.finals_won, "party": c.party,
		"anathema": c.anathema,
		"battle": to_dict(c.battle) if c.battle != null else null,
		"battle_city": c.battle_city, "squad": c.squad,
		"history": c.history,
		"sponsorship": c.sponsorship,
	}


static func campaign_from_dict(d: Dictionary) -> Campaign:
	var c := Campaign.new(int(d.get("seed", 1)))
	c.rng.state = str(d.get("rng", "0")).to_int()
	c.state = int(d.get("state", Campaign.PICK))
	c.won = bool(d.get("won", false))
	c.turn = int(d.get("turn", 0))
	c.convergence = int(d.get("convergence", 0))
	c.cities.clear()
	for cd in d.get("cities", []):
		var city := Campaign.City.new()
		city.id = str(cd.get("id", ""))
		city.capital = bool(cd.get("capital", false))
		city.gate = int(cd.get("gate", 0))
		city.gate_max = int(cd.get("gate_max", 0))
		city.fallen = bool(cd.get("fallen", false))
		city.quiet = int(cd.get("quiet", 0))
		var rift: Dictionary = cd.get("rift", {})
		city.rift = {} if rift.is_empty() else {"faction": str(rift.get("faction", "")), "guest": str(rift.get("guest", "")), "final": bool(rift.get("final", false)), "tier": int(rift.get("tier", 0))}
		c.cities[city.id] = city
	c.roster.clear()
	for md in d.get("roster", []):
		var m := Campaign.Machine.new()
		m.uid = int(md.get("uid", 0))
		m.chassis = str(md.get("chassis", ""))
		for cid in md.get("loadout", []):
			m.loadout.append(str(cid))
		m.shop = int(md.get("shop", 0))
		c.roster.append(m)
	c._next_uid = int(d.get("next_uid", c.roster.size() + 1))
	c.components.clear()
	var owned: Dictionary = d.get("components", {})
	for cid in owned.keys():
		c.components[str(cid)] = int(owned[cid])
	c.salvage = int(d.get("salvage", 0))
	c.favour = int(d.get("favour", 0))
	c.blueprints = _strings(d.get("blueprints", []))
	c.tokens = _strings(d.get("tokens", []))
	c.offers = _strings(d.get("offers", []))
	c.bosses_beaten.clear()
	var beaten: Dictionary = d.get("bosses_beaten", {})
	for f in beaten.keys():
		c.bosses_beaten[str(f)] = int(beaten[f])
	c.bosses_ended.clear()
	var ended: Dictionary = d.get("bosses_ended", {})   # a save from before 22 October has none: every boss open
	for f in ended.keys():
		c.bosses_ended[str(f)] = _strings(ended[f])
	c.finals_won = _strings(d.get("finals_won", []))
	c.anathema.clear()
	var ana: Dictionary = d.get("anathema", {})
	for f in ana.keys():
		c.anathema[str(f)] = int(ana[f])
	var dealt = d.get("party", null)
	if dealt is Dictionary:
		# A save from before 21 October keeps the deal its seed makes (Campaign.deal_party).
		c.party.clear()
		for fid in dealt.keys():
			c.party[str(fid)] = str(dealt[fid])
	var bd = d.get("battle", null)
	c.battle = from_dict(bd) if bd is Dictionary else null
	c.battle_city = str(d.get("battle_city", ""))
	c.squad.clear()
	for uid in d.get("squad", []):
		c.squad.append(int(uid))
	c.history.clear()
	for rd in d.get("history", []):
		c.history.append(_report_from(rd))
	c.sponsorship.clear()
	var tally: Dictionary = d.get("sponsorship", {})
	for k in tally.keys():
		c.sponsorship[str(k)] = int(tally[k])
	return c


## A battle's report as Campaign.finish_battle wrote it: JSON brings every number back as a
## float, so the counts are cast back.
static func _report_from(rd: Dictionary) -> Dictionary:
	var r := rd.duplicate(true)
	for k in ["turn", "gate_left", "phases", "salvage", "favour", "tier", "squad",
			"menace", "kills", "fractures", "fractures_of", "rupture_turn", "elites", "peaks", "rift_spawns", "tear_spawns", "tears"]:
		if r.has(k):
			r[k] = int(r[k])
	var wrecked: Array = []
	for uid in r.get("wrecked", []):
		wrecked.append(int(uid))
	r["wrecked"] = wrecked
	r["lost"] = _strings(r.get("lost", []))
	return r


static func _strings(list) -> Array:
	var out: Array = []
	for x in list:
		out.append(str(x))
	return out


# ---------------------------------------------------------------- the quick campaign

const QUICK_PATH := "user://quick_run.json"
const QUICK_VERSION := 1


static func quick_exists(path: String = QUICK_PATH) -> bool:
	return FileAccess.file_exists(path)


static func save_quick(r: QuickRun, path: String = QUICK_PATH) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(quick_to_dict(r)))
	f.close()
	return true


## The saved quick run, or null when there is none or it cannot be read.
static func load_quick(path: String = QUICK_PATH) -> QuickRun:
	if not FileAccess.file_exists(path):
		return null
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary) or int(parsed.get("version", 0)) != QUICK_VERSION:
		return null
	return quick_from_dict(parsed)


## The run whole: its roster and stores, the battle ahead or under way with the squad's machines
## as they stand (their damage, dice and live modifiers) and the fight open, if one is, with its
## random stream, so a resumed fight plays on exactly as it would have.
static func quick_to_dict(r: QuickRun) -> Dictionary:
	var roster: Array = []
	for m in r.roster:
		roster.append({"uid": m.uid, "chassis": m.chassis, "loadout": m.loadout, "modules": m.modules})
	return {
		"version": QUICK_VERSION,
		"seed": r.seed_value,
		"rng": str(r.rng.state),
		"state": r.state, "won": r.won, "battle": r.battle,
		"roster": roster, "next_uid": r._next_uid, "squad": r.squad,
		"components": r.components, "modules": r.modules,
		"party": r.party, "bosses_ended": r.bosses_ended, "finals_won": r.finals_won, "density": r.density,
		"lead": r.lead, "guest": r.guest, "encounters": r.encounters, "fight": r.fight,
		"units": _units(r.units),
		"skirmish": _skirmish_dict(r.current, null) if r.current != null else null,
		"rewards": r.rewards, "history": r.history, "lost_at": r.lost_at,
	}


static func quick_from_dict(d: Dictionary) -> QuickRun:
	var r := QuickRun.new(int(d.get("seed", 1)))
	r.rng.state = str(d.get("rng", "0")).to_int()
	r.state = int(d.get("state", QuickRun.DRAFT))
	r.won = bool(d.get("won", false))
	r.battle = int(d.get("battle", 0))
	for md in d.get("roster", []):
		var m := QuickRun.Machine.new()
		m.uid = int(md.get("uid", 0))
		m.chassis = str(md.get("chassis", ""))
		m.loadout = _strings(md.get("loadout", []))
		m.modules = _strings(md.get("modules", []))
		r.roster.append(m)
	r._next_uid = int(d.get("next_uid", r.roster.size() + 1))
	for uid in d.get("squad", []):
		r.squad.append(int(uid))
	for key in ["components", "modules"]:
		var store: Dictionary = r.components if key == "components" else r.modules
		var saved: Dictionary = d.get(key, {})
		for id in saved.keys():
			store[str(id)] = int(saved[id])
	var dealt: Dictionary = d.get("party", {})
	for fid in dealt.keys():
		r.party[str(fid)] = str(dealt[fid])
	var ended: Dictionary = d.get("bosses_ended", {})
	for fid in ended.keys():
		r.bosses_ended[str(fid)] = _strings(ended[fid])
	r.finals_won = _strings(d.get("finals_won", []))
	var dens: Array = d.get("density", [])
	if not dens.is_empty():
		r.density = dens.map(func(x) -> float: return float(x))
	r.lead = str(d.get("lead", ""))
	r.guest = str(d.get("guest", ""))
	r.encounters = []
	for e in d.get("encounters", []):
		var enc := {}
		for k in e.keys():
			if str(k) == "index":
				enc["index"] = int(e[k])   # which of the domain's formation compositions (30 October)
			else:
				enc[str(k)] = _strings(e[k]) if e[k] is Array else str(e[k])   # the finale's line is a list
		r.encounters.append(enc)
	r.fight = int(d.get("fight", 0))
	r.units = []
	for ud in d.get("units", []):
		r.units.append(_unit_from(ud))
	var sd = d.get("skirmish", null)
	if sd is Dictionary:
		var by_id := func(uid: int) -> Unit: return r.unit_of(uid)
		r.current = _skirmish_build(sd, by_id)
		r.current.committed = true   # every quick campaign fight
		r.current.foe_factory = func(foe_id: String) -> Foe: return r.db.make_foe(foe_id) if r.db.foes.has(foe_id) else null
	r.rewards = []
	for rd in d.get("rewards", []):
		var reward := {"kind": str(rd.get("kind", "")), "choices": []}
		if rd.has("maker"):
			reward["maker"] = str(rd["maker"])
		for it in rd.get("choices", []):
			reward["choices"].append({"kind": str(it.get("kind", "")), "id": str(it.get("id", ""))})
		r.rewards.append(reward)
	r.history = []
	for hd in d.get("history", []):
		var h: Dictionary = hd.duplicate(true)
		for k in ["battle", "tier", "fights"]:
			if h.has(k):
				h[k] = int(h[k])
		h["lost"] = _strings(h.get("lost", []))
		h["wrecked"] = Array(h.get("wrecked", [])).map(func(x) -> int: return int(x))
		r.history.append(h)
	var at: Dictionary = d.get("lost_at", {})
	r.lost_at = {}
	for k in at.keys():
		r.lost_at[str(k)] = int(at[k]) if (k == "battle" or k == "fight") else str(at[k])
	return r


# ---------------------------------------------------------------- the profile

const PROFILE_PATH := "user://profile.json"


static func save_profile(p: Profile, path: String = PROFILE_PATH) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(p.to_dict()))
	f.close()
	return true


## The saved profile, or a fresh one when there is none.
static func load_profile(path: String = PROFILE_PATH) -> Profile:
	if not FileAccess.file_exists(path):
		return Profile.new()
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return Profile.from_dict(parsed if parsed is Dictionary else {})

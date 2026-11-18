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
const VERSION := 40   # 2: moves in tens (2 October); 3: the water feature and the map's kind (3 and 4 October); 4: the generator's roads changed under every seed, and the guest, kills and wrecks (6 October); 5: the redesigned round, a turn of actions and fights in place of routes and contacts (8 October); 6: moves in hexes, a move in one go (28 October's movement proposal); 7: the six map shapes, every seed's map laid anew (29 October); 8: the fords and streets three or four in all, every river and city laid anew, and the horde wading (29 October); 9: hunters at ring two, and a sealed-off prey's stand-in in place of the re-pick (29 October); 10: the long wall (the field's size from the ramp, the tide, a pusher's wall segment, one pack one fight, no withdrawal, the shield the fight's, a pack's threat rating and dealt layout; 6 November); 11: no reinforcement inside a fight (a pack is what its slots hold, a regrowing foe's corpse holds its slot, a catch's overflow held back) and the compositions fitted to the ranks (7 November); 12: the field's caches, seeded with the map, and those claimed (7 November); 13: a hunter's catch a fight of its own, and no escort grown by the tier (7 November); 14: a cache's kind by its depth, the seam's upgrade gone (8 November); 15: a composition its grid, the cycle's entries carrying eight cells (8 November); 16: a composition saying whether its pack hunts, never its foes, and a hunter catching at the pounce alone, no pack carrying a ring (8 November); 17: the shapes relaid for the shallow field (the mouth a share of the depth, the fjords and cliffs by the width, the shores' rough ground), every seed's map laid anew (9 November); 18: the Armadillo's id the Polar Bear's, polar_bear (9 November), so a battle saved with the old id is set aside rather than drawn without its model; 19: every id still wearing an old name its name's (9 November): kite, buzzard, oblation_mantle, eleven foes and the compositions named for them; 20: the Lammergeier's Mines on foes, a foe status, in place of the slots' shots (9 November); 21: the refit pass's model landed (10 November): the stock dice with no shield or vent, the Halo Shield's id its name's (halo_projector), every chassis its own shield regen; 22: the rift five hexes, the two in front of its middle with its row's three, and the boss in front of them (10 November), every map's mouth laid anew, and the formation pass's compositions in place of the old (the same day); 23: the boss holding its hex in front of the rift, no patrol (10 November); 24: menace a pack's threat rating in hundredths of a pip (11 November), so a battle's tally and its thresholds are counted anew, with the Rupture sized in beats and the stall guard gone; 25: a cooldown counted after the round of its spend, Rapid's own switch-off back and Instant a keyword (12 November), so a die saved with a Rapid piece's printed cooldown, the Spin-Up's spin or a fist's Breach is set aside; 26: the rules no piece printed left the engine (12 November: Empowered a kill, a passive's keep of a status, Reset, an entry's heat a blow and label, the battle's fought record), so a die saved with one, or a machine saved holding kept Empowered, is set aside, and the readers for older saves' forms went with them; 27: the reboot the rule (15 November): no chassis regains shield or cools of its own, heat past the maximum stays and burns, and a machine's four reboot states are every fight's, so a fight saved under the rule before it is set aside; 28: the vocabulary pass's build (15 November): Ablate in Burn's place, a machine's Ablating damage where its Burning was heat, and the keywords and statuses the pass cut or renamed, so a fight saved under the old words is set aside; 29: the pass's renames (16 November): Jam and Jammed, Essence and the Quintessence Tap, Recover and Heal, and Swap, Web and Spillover as rules written on their pieces, so a fight saved under the ids before them is set aside; 30: the pass's first rule changes (16 November): Regenerating in stacks that fade and Primed a primer, so a fight saved with either on its old clock is set aside; 31: Brittle in place of Flak and Crushed (16 November), the keyword and both statuses under new ids, so a fight saved under the old ones is set aside; 32: a drain as its foe's own Ability (16 November), no rider on a blow, so a fight saved with the rider on its moves is set aside; 33: the four places a status ends (16 November), a machine's Regenerating, a Barrier, a Ward, a pin and Exposed each on a new clock, so a fight saved with one on its old clock is set aside; 34: a move as a list of steps (16 November), what a foe took a status of its own, Appropriated, so a fight saved with a steal's hold is set aside; 35: the shapes relaid on Ryan's notes of 16 November (one fat river with two narrows and no tributary, the fjord a river delta, the steppe's crags and ponds always laid, the city with no water), so a battle saved on a river, a fjord, a steppe or a city, whose map its seed now lays anew, is set aside; 36: his second notes of the day (the river's one narrow at the middle, the delta's channels the whole depth, the gorge's chunks of land between chasms, the city's cross-streets every third row and its suburb, the steppe drawing on every shape, the badlands' scrub thinned), so a battle saved before them is set aside; 37: his third (the delta a true delta of thin streams, the city's two open sections at most, the steppe's lakes and no chasm, soft ground on the aprons, and a machine's action ended by its move played with no order standing, the moves played kept apart on the save), so a battle saved before them is set aside; 38: the steppe's walls half cliffs and kept off the rift's mouth (his of the same evening), so a battle saved on a steppe before them is set aside; 39: the foes' targeting afresh (17 November): a pick drawn level or by its attack's own word, none held by a move at every machine or at nobody, and no foe carrying an aim, so a fight saved with the old aims' picks is set aside; 40: the foes' bench landed (17 November): moves gone from six foes and added to five, falls on six, a foe's Phased and a foe's immunities, so a fight saved before, whose foes' moves it names by their place, is set aside


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
	var played: Array = []
	for uid in b.played.keys():
		played.append(int(uid))
	return {
		"version": VERSION,
		"seed": b.seed_value,
		"rng": str(b.rng.state),
		"faction": b.faction,
		"guest": b.guest,
		"foes_killed": b.foes_killed,
		"menace_killed": b.menace_killed,
		"meter_held": b.meter_held,
		"pack_paid": _int_keys(b.pack_paid),   # what each standing pack's kills have paid of its rating (11 November)
		"tier": b.tier, "ramp": b.ramp,
		"thresholds": b.thresholds, "fractures": b.fractures, "rupture_turn": b.rupture_turn,
		"elites_spawned": b.elites_spawned, "field_menace": b.field_menace,
		"sponsorship": b.sponsorship,
		"loot": b.loot, "blueprints_known": b.blueprints_known,   # the caches claimed and the run's blueprints (7 November)
		"action_hexes": _int_keys(b.action_hexes),
		"wrecks": _units(b.field.wrecks),   # where each fell, its hexes held for the battle (16 November)
		"state": b.state,
		"outcome": b.outcome,
		"spent": _int_keys(b.spent),
		"moved": moved,
		"played": played,   # the machines whose move has played with an order standing (16 November)
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
	b.meter_held = int(d.get("meter_held", 0))
	for uid in d.get("pack_paid", {}).keys():
		b.pack_paid[int(str(uid))] = int(d["pack_paid"][uid])
	b.tier = int(d.get("tier", 0))
	b.ramp = int(d.get("ramp", 0))
	for t in d.get("thresholds", []):
		b.thresholds.append(int(t))
	b.fractures = int(d.get("fractures", 0))
	b.rupture_turn = int(d.get("rupture_turn", -1))
	b.elites_spawned = _strings(d.get("elites_spawned", []))
	b.field_menace = int(d.get("field_menace", 0))
	for ld in d.get("loot", []):
		if ld is Dictionary:
			b.loot.append({"kind": str(ld.get("kind", "")), "tier": int(ld.get("tier", 1)), "salvage": int(ld.get("salvage", 0)),
				"components": _strings(ld.get("components", [])), "blueprint": str(ld.get("blueprint", "")), "by": int(ld.get("by", 0))})
	b.blueprints_known = _strings(d.get("blueprints_known", []))
	var tally: Dictionary = d.get("sponsorship", {})
	for k in tally.keys():
		b.sponsorship[str(k)] = int(tally[k])
	var hexes: Dictionary = d.get("action_hexes", {})
	for uid in hexes.keys():
		b.action_hexes[int(str(uid))] = int(hexes[uid])
	b.state = int(d.get("state", Battle.State.PLAN))
	b.outcome = int(d.get("outcome", Battle.Outcome.NONE))
	var md: Dictionary = d.get("map", {})
	var w := int(md.get("w", Battle.DEFAULT_WIDTH))
	var h := int(md.get("h", Battle.DEFAULT_HEIGHT))
	var map_seed := int(md.get("seed", 0))
	b.map_kind = str(md.get("kind", ""))
	b.map = BattleMap.generate(w, h, map_seed, b.map_kind) if map_seed != 0 else BattleMap.flat(w, h)
	b.field = _field_from(d.get("field", {}), b.map)
	b.field.seed_value = b.seed_value   # a dealt layout's draw reads the battle's seed (section 6)
	for wd in d.get("wrecks", []):
		b.field.wrecks.append(_unit_from(wd))
	# What the map knows of each foe type, from the content as the setup gives it: a pack Rift
	# Pressure spawns after a resume is dressed by it, its ring, move and hunt (the mechanics
	# audit, 25 October: a resumed battle's spawns came out as plain pushers).
	b.field.foe_profiles = b.db.pack_profiles()
	for uid in d.get("spent", {}).keys():
		b.spent[int(str(uid))] = int(d["spent"][uid])
	for uid in d.get("moved", []):
		b.moved[int(uid)] = true
	for uid in d.get("played", []):
		b.played[int(uid)] = true
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
	b.field.set_shell(b.is_sealed())   # the rift's shell stands while the seal does
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
	var caches: Array = []   # the caches lying on the field (7 November)
	for c in f.caches:
		caches.append([int(c["id"]), int(c["tier"]), (c["pos"] as Vector2i).x, (c["pos"] as Vector2i).y])
	return {
		"gate_hp": f.gate_hp, "gate_hp_max": f.gate_hp_max,
		"rift_pressure": f.rift_pressure, "rift_pressure_max": f.rift_pressure_max,
		"spawn_faction": f.spawn_faction, "ramp": f.ramp,
		"cycle": f.cycle, "patrol_cycle": f.patrol_cycle, "cycle_index": f._cycle_index, "patrol_index": f._patrol_index,
		"seam_row": f.seam_row, "tears": tears, "caches": caches, "peaks": f.peaks, "rift_spawns": f.rift_spawns, "tear_spawns": f.tear_spawns,
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
		var entry := {"id": str(c.get("id", "")), "size": str(c.get("size", "patrol")), "faction": str(c.get("faction", "")), "members": members}
		for key in ["squad", "layout", "lead", "hunts"]:   # the long wall brief's composition fields (3.7, section 6) and the hunt (8 November)
			if c.has(key):
				entry[key] = c[key]
		out.append(entry)
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
	f.seam_row = int(d.get("seam_row", f.seam_start()))
	for t in d.get("tears", []):
		f.tears.append({"pos": Vector2i(int(t[0]), int(t[1])), "opened": int(t[2]) if t.size() > 2 else 0})
	for c in d.get("caches", []):
		if c is Array and (c as Array).size() >= 4:
			f.caches.append({"id": int(c[0]), "tier": int(c[1]), "pos": Vector2i(int(c[2]), int(c[3]))})
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
		"faction": u.faction, "foe_id": u.foe_id, "strength": u.strength, "members": u.members, "composition": u.composition, "composition_size": u.composition_size, "behaviour": u.behaviour, "hunts": u.hunts, "prey": u.prey, "goal_col": u.goal_col, "squad": u.squad, "full_strength": u.full_strength, "layout": u.layout, "is_boss": u.is_boss, "sealed": u.sealed, "lineup": u.lineup, "boss_tier": u.boss_tier, "attack_range": u.attack_range,
		"die": faces, "paint": paint, "passive": u.passive, "chassis_id": u.chassis_id,
		"hardpoints": u.hardpoints, "damaged_faces": damaged, "modules": u.modules, "branches": u.branches,
	}


static func _unit_from(d: Dictionary) -> Unit:
	var u := Unit.new()
	_unit_into(u, d)
	return u


## A unit's dictionary written into `u`: a fresh unit on a load, the field's own on an undo
## (restore_skirmish), so every collection it fills is emptied first.
static func _unit_into(u: Unit, d: Dictionary) -> void:
	u.id = int(d.get("id", 0))
	u.display_name = str(d.get("name", ""))
	u.side = int(d.get("side", Unit.Side.PLAYER))
	u.pos = _hex_from(d.get("pos", [0, 0]))
	u.hull = int(d.get("hull", 100))
	u.shield = int(d.get("shield", 0))
	var base: Dictionary = d.get("base", {})
	u.base.clear()
	for k in base.keys():
		u.base[str(k)] = int(base[k])
	u.modifiers.clear()
	u.modifiers.append_array(_modifiers_from(d.get("modifiers", [])))
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
	u.members.clear()
	for m in d.get("members", []):   # a composition's members (30 October); a save from before has none
		if m is Array and (m as Array).size() >= 2:
			u.members.append([str(m[0]), int(m[1])])
	u.composition = str(d.get("composition", ""))
	u.composition_size = str(d.get("composition_size", ""))
	u.behaviour = str(d.get("behaviour", "push"))
	u.hunts = str(d.get("hunts", "nearest"))
	u.prey = int(d.get("prey", 0))
	u.goal_col = int(d.get("goal_col", -1))
	u.squad = int(d.get("squad", ContentDB.SQUAD_DEFAULT))
	u.full_strength = int(d.get("full_strength", 0))   # a save from before 10 November has none: the pack strikes for its rating whole (Battlefield.strike_of)
	u.layout = []
	for cell in d.get("layout", []):
		u.layout.append(str(cell))
	u.attack_range = int(d.get("attack_range", 1))
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
	u.paint.clear()
	for k in d.get("paint", {}).keys():
		u.paint[str(k)] = Color.html(str(d["paint"][k]))
	var p = d.get("passive", {})
	u.passive = p if p is Dictionary else {}
	u.chassis_id = str(d.get("chassis_id", ""))
	u.hardpoints = int(d.get("hardpoints", 0))
	u.damaged_faces.clear()
	for idx in d.get("damaged_faces", {}).keys():
		u.damaged_faces[int(str(idx))] = _face_from(d["damaged_faces"][idx])
	u.modules.clear()
	for mid in d.get("modules", []):   # the fitted modules' ids, for the codex (their effects are the modifiers above)
		u.modules.append(str(mid))
	u.branches.clear()
	for pick in d.get("branches", []):   # its branches' picks, the same (a save from before 17 November has none)
		u.branches.append(str(pick))


## A die entry with everything the die keeps beyond the content shape: its component,
## whether it is fixed or an empty hardpoint (a destroyed one is a blank).
static func _face_dict(f: Face) -> Dictionary:
	var d := f.to_dict()
	d["component"] = f.component
	d["empty"] = f.empty
	d["fixed"] = f.fixed
	if not f.tags.is_empty():
		d["tags"] = f.tags
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


## A unit's or a foe's modifiers as saved. A save from before 8 November may hold a buff a purge
## put to sleep, whole or in part: it loads awake and whole, since a purge no longer sleeps
## anything (Ryan: "A stack is a stack"). One from before 10 November may hold the Honey Badger's
## Ore Plate, the ability the hopper's worth stood as: it loads as the hopper's grant of Armoured,
## stack for stack, gone at the round's end and granted again as the next opens.
static func _modifiers_from(list: Array) -> Array:
	var out: Array = []
	for md in list:
		var m := _modifier_from(md)
		m.stacks += int((md as Dictionary).get("slept_stacks", 0))
		if m.id == "ore_plate":
			var def: Dictionary = Effects.STATUS["braced"]
			var plate := Effects.make(def, Effects.SKIRMISH, Effects.HOPPER_PLATE)
			plate.stacks = m.stacks
			plate.decay = Effects.status_decay(def)
			plate.seq = m.seq
			m = plate
		out.append(m)
	return out


# ---------------------------------------------------------------- the skirmish

static func _skirmish_dict(sk: Skirmish, field: Battlefield) -> Dictionary:
	var mechs: Array = []
	for ms in sk.mechs:
		mechs.append({"unit": ms.unit.id, "heat": ms.heat, "heat_max": ms.heat_max, "face_index": ms.face_index,
			"locked": ms.locked, "assigned": ms.assigned, "free_rerolls": ms.free_rerolls, "ammo": ms.ammo, "ammo_max": ms.ammo_max,
			"hot_entry": ms.hot_entry, "spends": ms.spends, "rebooting": ms.rebooting, "shield_broken": ms.shield_broken, "overheated": ms.overheated,
			"killed_round": ms.killed_round})
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
	var held: Array = []   # the corpses holding their slots till their parts regrow (7 November)
	for slot in sk.corpses.keys():
		held.append({"rank": slot.x, "column": slot.y, "foe": _foe_dict(sk.corpses[slot], sk)})
	return {
		"rng": str(sk.rng.state), "columns": sk.columns, "terrain": sk.terrain, "ground": sk.ground,
		"round": sk.round, "rerolls_left": sk.rerolls_left, "banked": sk.banked, "state": sk.state, "outcome": sk.outcome,
		"log": sk.log, "mechs": mechs, "packs": packs, "foes": foe_dicts, "front": front, "back": back,
		"reinforcements": queue, "committed": sk.committed, "layout": sk.layout, "twins": paired, "corpses": held,
		"kills": _typed_tallies(sk.kills),
		"roll_marks": sk.roll_marks, "history": sk.history,   # the trail's bars and the undo's snapshots (2 November)
		"team_kills": sk.team_kills,
	}


static func _skirmish_from(d: Dictionary, field: Battlefield) -> Skirmish:
	return _skirmish_build(d, func(uid: int) -> Unit: return field.unit_by_id(uid))


## A fight and its units in one dictionary, the units by place (the machines first and the packs
## after, never by id: a test's machines may share one) under `units`, each machine's `unit` its
## index there; the undo's own stack left out. The clone's and the snapshot's shared source; its
## arrays are the fight's own until duplicated.
static func _fight_dict(sk: Skirmish) -> Dictionary:
	var d := _skirmish_dict(sk, null)
	d.erase("history")
	var units: Array = []
	for i in range(sk.mechs.size()):
		units.append(_unit_dict(sk.mechs[i].unit))
		d["mechs"][i]["unit"] = i
	var packs: Array = []
	for sq in sk.packs:
		units.append(_unit_dict(sq))
		packs.append(units.size() - 1)
	d["packs"] = packs
	d["units"] = units
	return d


## A deep copy of a skirmish and its machines through the save's own round trip (the planner's
## rollouts, the stock pass's second chunk, 22 October): every unit and live modifier, the dice,
## the foes and their intents (their Mines among their statuses), the ranks, the queue and the random stream's state,
## so the copy plays on exactly as the original would. What the save leaves to the battle (the
## runner's targeting rule, the summoning factory, a roar's reroll debt) is carried across;
## the log and the undo are not.
static func clone_skirmish(sk: Skirmish) -> Skirmish:
	var d := _fight_dict(sk)
	d["log"] = []
	var units: Array[Unit] = []
	for ud in d["units"]:
		units.append(_unit_from(ud))
	var c := _skirmish_build(d, func(at: int) -> Unit: return units[at] if at >= 0 and at < units.size() else null)
	c.foe_factory = sk.foe_factory
	c.reroll_debt = sk.reroll_debt
	c.drained = sk.drained
	return c


## The fight as it stands, for the undo (Skirmish.history, 2 November): the fight's dictionary
## with every unit's numbers inside, deep-copied, so the fight's own arrays (the log, a foe's
## statuses, a foe's moves) move on without it. The game's tallies ride under `tallies`, so an
## undone spend counts for nothing; the runner's own (reach_tally, taken_by_rank, mine_tally)
## are left out, since the runner never undoes.
static func snapshot_skirmish(sk: Skirmish) -> Dictionary:
	var d := _fight_dict(sk)
	d["tallies"] = {"destroyed": sk.destroyed, "seq": sk._seq, "reroll_debt": sk.reroll_debt, "drained": sk.drained,
		"sponsorship": sk.sponsorship}
	return d.duplicate(true)


## The fight put back as a snapshot had it, in place: the machines' units are the field's own,
## their numbers written back; the machines, the foes, the ranks, the queue, the
## stream and the log as they were; the packs' units, the callables and the undo stack stand.
## The last blow and acts, the screen's, are cleared: they were the spend's.
static func restore_skirmish(sk: Skirmish, d: Dictionary) -> void:
	var units: Array[Unit] = []
	for ms in sk.mechs:
		units.append(ms.unit)
	var dicts: Array = d.get("units", [])
	for i in range(mini(units.size(), dicts.size())):
		_unit_into(units[i], dicts[i])
	units.append_array(sk.packs)
	_skirmish_into(sk, d, func(at: int) -> Unit: return units[at] if at >= 0 and at < units.size() else null)
	var t: Dictionary = d.get("tallies", {})
	sk.destroyed = int(t.get("destroyed", sk.destroyed))
	sk._seq = int(t.get("seq", sk._seq))
	sk.reroll_debt = int(t.get("reroll_debt", sk.reroll_debt))
	sk.drained = int(t.get("drained", 0))   # this round's loss to a drain, for the REROLL button's note
	var sp = t.get("sponsorship", null)
	if sp is Dictionary:
		for k in sp.keys():
			sk.sponsorship[str(k)] = int(sp[k])
	sk.last_roll.clear()
	sk.last_acts.clear()


## A skirmish from its dictionary, its units found by id through `lookup` (the battlefield's on
## a resume, a copy's own on a clone).
static func _skirmish_build(d: Dictionary, lookup: Callable) -> Skirmish:
	var sk := Skirmish.new(0, int(d.get("columns", Skirmish.DEFAULT_COLUMNS)))
	_skirmish_into(sk, d, lookup)
	return sk


## A skirmish's dictionary written into `sk`: a fresh one on a load or a clone, the fight itself
## on an undo (restore_skirmish), so every collection it fills is emptied first. The undo stack
## is read only where the dictionary carries one (a save's): a snapshot carries none, and the
## undo keeps the stack it pops from.
static func _skirmish_into(sk: Skirmish, d: Dictionary, lookup: Callable) -> void:
	sk.rng.state = str(d.get("rng", "0")).to_int()
	sk.terrain = int(d.get("terrain", BattleMap.Terrain.PLAIN))
	sk.ground = str(d.get("ground", BattleMap.TERRAIN_NAMES.get(sk.terrain, "plain")))
	sk.round = int(d.get("round", 0))
	sk.rerolls_left = int(d.get("rerolls_left", 0))
	sk.banked = int(d.get("banked", 0))   # the rerolls Maverick's Playbook carries to the next round (30 October)
	sk.committed = bool(d.get("committed", false))
	sk.layout = []
	for cell in d.get("layout", []):
		sk.layout.append(str(cell))
	sk.state = int(d.get("state", Skirmish.State.SETUP))
	sk.outcome = int(d.get("outcome", Skirmish.Outcome.NONE))
	sk.log.clear()
	for line in d.get("log", []):
		sk.log.append(str(line))
	sk.mechs.clear()
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
		ms.hot_entry = int(md.get("hot_entry", -1))   # the overheat's culprit (a save from before 3 November has none)
		# The reboot's states.
		ms.spends = int(md.get("spends", 0))
		ms.rebooting = bool(md.get("rebooting", false))
		ms.shield_broken = bool(md.get("shield_broken", false))
		ms.overheated = bool(md.get("overheated", false))
		ms.killed_round = bool(md.get("killed_round", false))   # an attack of its own killed this round: its passive's flare as the round ends (16 November)
	sk.packs.clear()
	for pid in d.get("packs", []):
		var sq: Unit = lookup.call(int(pid))
		if sq != null:
			sk.packs.append(sq)
	sk.twins.clear()
	sk.reinforcements.clear()
	sk.corpses.clear()
	for cd in d.get("corpses", []):
		if cd is Dictionary and (cd as Dictionary).has("foe"):
			sk.corpses[Vector2i(int(cd.get("rank", 0)), int(cd.get("column", 0)))] = _foe_from(cd["foe"], sk)
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
	sk.kills = _typed_tallies_from(d["kills"]) if d.has("kills") else _kills_before_the_tally(sk, d)
	sk.roll_marks.clear()
	for m in d.get("roll_marks", []):
		sk.roll_marks.append(int(m))
	if d.has("history"):
		sk.history.clear()
		for h in d["history"]:
			if h is Dictionary:
				sk.history.append(h)
	sk.team_kills = int(d.get("team_kills", 0))   # the foes the team has killed this fight (30 October)


## A fight saved before the one kill tally (8 November): its kills worked out as they were then,
## what each pack came with less its own left on the field or waiting, and every foe that joined
## it and fell; a save from before the record of what came reads the pack itself (its members,
## a boss unit's lineup or its commanders).
static func _kills_before_the_tally(sk: Skirmish, d: Dictionary) -> Dictionary:
	var came_with := _typed_tallies_from(d.get("came_with", {}))
	var joined := _typed_tallies_from(d.get("joined_fallen_types", {}))
	var out := {}
	for sq in sk.packs:
		var came: Dictionary = came_with.get(sq.id, {})
		if came.is_empty():
			if sq.is_boss:
				for cid in sq.lineup:
					came[str(cid)] = int(came.get(str(cid), 0)) + 1
				if sq.lineup.is_empty():
					for f in sk.field_foes():
						if f.pack_id == sq.id and f.commands:
							came[f.content_id] = int(came.get(f.content_id, 0)) + 1
			for m in sq.member_list():
				if not str(m[0]).is_empty():
					came[str(m[0])] = int(came.get(str(m[0]), 0)) + int(m[1])
		var left := {}
		for f in sk.field_foes() + sk.reinforcements:
			if f.pack_id == sq.id and f.alive() and Skirmish.is_own(sq, f):
				left[f.content_id] = int(left.get(f.content_id, 0)) + 1
		var tally := {}
		for cid in came.keys():
			var n := int(came[cid]) - int(left.get(cid, 0))
			if n > 0:
				tally[str(cid)] = n
		var j: Dictionary = joined.get(sq.id, {})
		for cid in j.keys():
			tally[str(cid)] = int(tally.get(str(cid), 0)) + int(j[cid])
		if not tally.is_empty():
			out[sq.id] = tally
	return out


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
		"prefers_back": f.prefers_back, "pack_id": f.pack_id, "size": f.size, "armour": f.armour, "last_special": f.last_special, "kin": f.kin,
		"resist": f.resist,
		"actions": f.actions, "rank": f.rank, "column": f.column, "target": target,
		"action": f.actions.find(f.action), "modifiers": mods,
		"boss": f.boss, "hero": f.hero, "elite": f.elite, "commands": f.commands, "escorts": f.escorts, "on_death": f.on_death, "stays_down": f.stays_down, "joined": f.joined, "fresh": f.fresh,
		"pending": f.actions.find(f.pending) if not f.pending.is_empty() else -1, "charge": f.charge,
		"part_ids": f.part_ids, "guard": f.guard, "regrow_parts": f.regrow_parts, "regrow_due": f.regrow_due,
		"next_move": f.next_move, "committed": f.committed, "grudge": f.grudge, "spent_once": f.spent_once, "swallow_mark": f.swallow_mark,
		"rage": f.rage, "golden_mark": f.golden_mark, "drains": f.drains, "immune": f.immune,
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
	f.resist = int(d.get("resist", -1))   # its stun resist (2 November); a save from before reads the default by size
	f.last_special = str(d.get("last_special", ""))
	f.kin = int(d.get("kin", 0))
	f.boss = bool(d.get("boss", f.size >= 2))   # a save from before 15 October read a massive foe as the boss
	f.hero = bool(d.get("hero", false))
	f.elite = bool(d.get("elite", false))   # a mini-boss (3 November); a save from before has none
	f.commands = bool(d.get("commands", f.boss))   # a save from before 21 October: a boss commanded its unit
	f.escorts = bool(d.get("escorts", false))
	var od = d.get("on_death", {})
	if od is Dictionary and od.has("summon"):
		f.on_death = {"summon": str(od["summon"]), "count": maxi(1, int(od.get("count", 1)))}
		if bool(od.get("pair", false)):
			f.on_death["pair"] = true   # the halves stand as a pair in its slot (26 October)
	if od is Dictionary and od.get("blow", null) is Dictionary:
		f.on_death["blow"] = Foe.death_blow_from(od["blow"])   # a last act (15 October), with what it does also
	elif od is Dictionary and od.get("act", null) is Dictionary:
		f.on_death["act"] = Foe.fall_act_from(od["act"])   # a fall that is one special (16 November)
	f.stays_down = bool(d.get("stays_down", false))
	f.joined = bool(d.get("joined", false))
	f.fresh = bool(d.get("fresh", false))
	f.actions = []
	var moved := []   # each saved move's place in the list as loaded, -1 for one dropped
	var bellowed := 0
	for a in d.get("actions", []):
		var act: Dictionary = a.duplicate()
		for key in ["strikes", "weight", "swarm", "value", "count", "countdown"]:
			if act.has(key):
				act[key] = int(act[key])
		for list in ["before", "also"]:
			if not (act.get(list, null) is Array):
				continue
			# What the move does also (16 November) and what its blow does before it lands (18
			# November): each step's numbers whole again.
			var steps: Array = []
			for st in act[list]:
				if st is Dictionary:
					var step: Dictionary = (st as Dictionary).duplicate()
					for key in ["value", "count", "rounds"]:
						if step.has(key):
							step[key] = int(step[key])
					steps.append(step)
			act[list] = steps
		if str(act.get("effect", "")) == "enrage":
			# A Bellow saved before the Nob's rage was its own (8 November): the rage it gave, now
			# the foe's from the start, and the move gone.
			bellowed = maxi(1, int(act.get("value", 1)))
			moved.append(-1)
			continue
		moved.append(f.actions.size())
		f.actions.append(act)
	if f.actions.is_empty():
		f.actions = [Foe.basic_action()]
	f.rank = int(d.get("rank", -1))
	f.column = int(d.get("column", -1))
	var ti := int(d.get("target", -1))
	f.target = sk.mechs[ti] if ti >= 0 and ti < sk.mechs.size() else null
	var ai := int(d.get("action", -1))
	ai = int(moved[ai]) if ai >= 0 and ai < moved.size() else ai
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
	f.rage = maxi(int(d.get("rage", 0)), bellowed)   # what the team's safe spends add to its blows while it stands (3 November; its own from the start since 8 November)
	f.golden_mark = int(d.get("golden_mark", -1))   # its HP as it went gold, -1 while calm (4 November)
	f.drains = bool(d.get("drains", false))   # its blows regrow what they take from a hull, its own Ability (16 November)
	var im = d.get("immune", null)   # what never lands on it, its own Ability (17 November)
	if im is Dictionary:
		for k in (im as Dictionary).keys():
			f.immune[str(k)] = true if im[k] is bool else str(im[k])
	var pi := int(d.get("pending", -1))   # a countdown move it was gathering (15 October)
	pi = int(moved[pi]) if pi >= 0 and pi < moved.size() else pi
	if pi >= 0 and pi < f.actions.size():
		f.pending = f.actions[pi]
		f.charge = int(d.get("charge", 0))
	f.modifiers.append_array(_modifiers_from(d.get("modifiers", [])))
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
const RUN_VERSION := 33   # 2: the threat became the Convergence; 3: Favour and the starting blueprints (7 October); 4: the battle inside it in the redesigned round (8 October); 5: the battle inside it in hexes (28 October); 6: the battle inside it on the six map shapes (29 October); 7: the battle inside it with the fords and streets laid anew (29 October); 8: the battle inside it with the hunters at ring two (29 October); 9: the battle inside it on the long wall (6 November); 10: the battle inside it with no reinforcement inside a fight (7 November); 11: the battle inside it with the field's caches (7 November); 12: the battle inside it with a catch a fight a hunter (7 November); 13: its caches by depth (8 November); 14: its compositions grids (8 November); 15: its compositions saying whether they hunt, and no ring but the pounce (8 November); 16: the battle inside it on the relaid shapes (9 November); 17: the battle inside it, and its roster, with the Polar Bear's id (9 November); 18: the battle inside it, its roster and its fronts with every renamed id (9 November); 19: the battle inside it with the Lammergeier's Mines on foes (9 November); 20: the battle inside it and its roster on the refit pass's model (10 November): the stock dice, halo_projector, the regen; 21: the battle inside it with the rift's five hexes (10 November) and the formation pass's compositions; 22: the battle inside it with the boss holding its hex (10 November); 23: the battle inside it and its Anathema with menace a pack's threat rating (11 November); 24: the battle inside it and its roster with the cooldown counted after its spend, Rapid's own switch-off and Instant (12 November); 25: the battle inside it and its roster without Empowered a kill and the kept status (12 November); 26: the battle inside it and its roster under the reboot (15 November); 27: the battle inside it and its roster under the vocabulary pass's words (15 November); 28: the battle inside it and its roster under the pass's renames, the Ammit's pieces among them (16 November); 29: the battle inside it and its roster under the pass's first rule changes, Regenerating's stacks and Primed as a primer (16 November); 30: the battle inside it and its roster with Brittle in place of Flak and Crushed (16 November); 31: the battle inside it with a drain as its foe's own Ability (16 November); 32: the battle inside it on the four places a status ends (16 November); 33: the battle inside it with a foe's take as Appropriated (16 November)


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
			"menace", "kills", "fractures", "fractures_of", "rupture_turn", "elites", "peaks", "rift_spawns", "tear_spawns", "tears", "loot_salvage"]:
		if r.has(k):
			r[k] = int(r[k])
	if r.has("loot"):   # the caches the battle claimed (7 November)
		var loot: Array = []
		for l in r["loot"]:
			if l is Dictionary:
				loot.append({"kind": str(l.get("kind", "")), "tier": int(l.get("tier", 1)), "salvage": int(l.get("salvage", 0)),
					"components": _strings(l.get("components", [])), "blueprint": str(l.get("blueprint", "")), "by": int(l.get("by", 0))})
		r["loot"] = loot
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
const QUICK_VERSION := 16   # 2: its roster with the Polar Bear's id, polar_bear in place of armadillo (9 November); 3: its roster and fights with every renamed id, kite and buzzard among them (9 November); 4: its fights with the Lammergeier's Mines on foes (9 November); 5: its roster and fights on the refit pass's model (10 November): the stock dice, halo_projector, the regen, the basics six; 6: its fights on the formation pass's compositions (10 November); 7: its roster and fights with the cooldown counted after its spend, Rapid's own switch-off and Instant (12 November); 8: its roster and fights without Empowered a kill and the kept status (12 November); 9: its roster and fights under the reboot (15 November); 10: its roster and fights under the vocabulary pass's words (15 November); 11: its roster and fights under the pass's renames (16 November); 12: its roster and fights under the pass's first rule changes (16 November); 13: its roster and fights with Brittle in place of Flak and Crushed (16 November); 14: its fights with a drain as its foe's own Ability (16 November); 15: its fights on the four places a status ends (16 November); 16: its fights with a foe's take as Appropriated (16 November)


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
		"party": r.party, "bosses_ended": r.bosses_ended, "finals_won": r.finals_won,
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

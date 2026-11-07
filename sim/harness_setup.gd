class_name HarnessSetup
extends RefCounted

## What the harness launches (game/harness.gd is its view): the team in the order it
## deploys, each machine's hardpoints and modules, the enemy side (packs, a boss, a guest
## faction), the seed and the map's type. Pure, so the tests build the same fights the
## harness does.
## Kept in user://harness.json between launches; ids the content no longer has are dropped
## on load, never trusted.

const PATH := "user://harness.json"
const MAX_STRENGTH := 18
const MAX_SEED := 9999

var db: ContentDB
var team: Array = []            # chassis ids, in the order they deploy
## Chassis id -> one pick per hardpoint, a component id or "" for a hardpoint left empty.
## A machine with no entry wears its chassis's stock loadout.
var loadouts: Dictionary = {}
## Chassis id -> one pick per module slot, a module id or "" for a slot left empty. A machine
## with no entry wears none (modules are never stock).
var modules: Dictionary = {}
var packs: Array = []           # [[foe_id, strength], ...]: on the field at the start and the rift's cycle in a battle, all chained in a fight
var boss: String = ""           # a faction's boss by foe id, "" for none
var guest: String = ""          # a battle's guest faction, joining the rift's cycle; "" for none
var seed_value: int = 7
var map_kind: String = ""        # a map shape (BattleMap.KINDS), or "" for the one the seed draws
## A composition picked on the ENEMY tab (Ryan, 6 November: the harness "should load a formation
## from a selected tier and threat level (the machine count, 1-4 that includes elites). And ramp
## level"): FIGHT fights it alone, BATTLE opens a battle on it. "" for the packs above.
var composition: String = ""
var comp_faction: String = ""    # its domain, "" for the content's first
var tier: int = 1                # the tier it is dealt at, 1 to 3
var rating: int = 0              # the threat rating listed, 1 to 4; 0 lists every one
var ramp: int = 0                # the Convergence, 0 to Ramp.TOP: its members' density, and a battle's ramp


func _init(content: ContentDB = null) -> void:
	db = content if content != null else ContentDB.load_default()


## The content's defaults: its starting team in stock loadouts against the first faction's
## spawn list and boss.
static func defaults(content: ContentDB = null) -> HarnessSetup:
	var s := HarnessSetup.new(content)
	s.team = s.db.default_team()
	s.use_faction(s.db.default_faction())
	return s


## Fill the enemy side from a faction: its spawn list as the packs, its boss.
func use_faction(faction_id: String) -> void:
	packs = []
	for e in db.spawn_table(faction_id, 1):   # the harness fights tier one
		packs.append([str(e[0]), int(e[1])])
	var all := db.bosses_of(faction_id)
	boss = all[0] if not all.is_empty() else ""


## Every faction's boss, in content order: the boss picker's choices.
func bosses() -> Array:
	var out: Array = []
	for fid in db.factions.keys():
		for b in db.bosses_of(str(fid)):
			if not out.has(b):
				out.append(b)
	return out


## The foes a pack can be made of: every foe that is no faction's boss and no boss's part (a part
## stands only with its core, 30 October), in content order.
func pack_foes() -> Array:
	var skip := bosses()
	for fid in db.foes.keys():
		for part in db.foes[fid].get("parts", []):
			if not skip.has(str(part)):
				skip.append(str(part))
	var out: Array = []
	for fid in db.foes.keys():
		if not skip.has(fid):
			out.append(str(fid))
	return out


## The compositions the ENEMY tab lists: the domain's patrols, formations and elites as a battle at
## `tier` deals them (a lower tier's standing in where it has none, as in play), those rated
## `rating` (every one at 0), in content order; each ContentDB's dealt dictionary.
func compositions_listed() -> Array:
	var out: Array = []
	var fac := comp_faction if db.factions.has(comp_faction) else db.default_faction()
	for size in ["patrol", "formation", "elite"]:
		for c in db.compositions(fac, tier, size):
			if rating == 0 or ContentDB.squad_of(c) == rating:
				out.append(c)
	return out


## The composition picked, as listed now; empty when none is or it is no longer listed.
func picked_composition() -> Dictionary:
	if composition.is_empty():
		return {}
	for c in compositions_listed():
		if str(c["id"]) == composition:
			return c
	return {}


## The faction the battle is fought against: the boss's, else the first pack's, else the
## content's first. It picks the boss, the music and the reveal.
func lead_faction() -> String:
	if not boss.is_empty():
		return db.faction_of_foe(boss)
	for p in packs:
		var fac := db.faction_of_foe(str(p[0]))
		if not fac.is_empty():
			return fac
	return db.default_faction()


# ---------------------------------------------------------------- loadouts

## A chassis's stock loadout as one pick per hardpoint, "" for each hardpoint it leaves empty.
func stock_picks(chassis_id: String) -> Array:
	var c: Dictionary = db.chassis.get(chassis_id, {})
	var n := int(c.get("hardpoints", 0))
	var out: Array = []
	for cid in c.get("loadout", []):
		if out.size() < n:
			out.append(str(cid))
	while out.size() < n:
		out.append("")
	return out


## The picks a machine wears now: its edited loadout, else its stock.
func picks(chassis_id: String) -> Array:
	return loadouts[chassis_id].duplicate() if loadouts.has(chassis_id) else stock_picks(chassis_id)


## Put a component (or "" for none) on one hardpoint. A machine edited back to its stock
## forgets the edit.
func set_pick(chassis_id: String, slot: int, component_id: String) -> void:
	var p := picks(chassis_id)
	if slot < 0 or slot >= p.size():
		return
	p[slot] = component_id if db.components.has(component_id) else ""
	if p == stock_picks(chassis_id):
		loadouts.erase(chassis_id)
	else:
		loadouts[chassis_id] = p


func reset_loadout(chassis_id: String) -> void:
	loadouts.erase(chassis_id)


func is_refit(chassis_id: String) -> bool:
	return loadouts.has(chassis_id)


## A machine's module picks: one per slot of its chassis, "" for each slot left empty.
func module_picks(chassis_id: String) -> Array:
	var n := int(db.chassis.get(chassis_id, {}).get("module_slots", 0))
	var out: Array = modules[chassis_id].duplicate() if modules.has(chassis_id) else []
	out.resize(mini(out.size(), n))
	while out.size() < n:
		out.append("")
	return out


## Put a module (or "" for none) in one slot. A machine with every slot empty forgets the edit.
func set_module(chassis_id: String, slot: int, module_id: String) -> void:
	var p := module_picks(chassis_id)
	if slot < 0 or slot >= p.size():
		return
	p[slot] = module_id if db.modules.has(module_id) else ""
	if p.all(func(m) -> bool: return str(m).is_empty()):
		modules.erase(chassis_id)
	else:
		modules[chassis_id] = p


## The modules make_mech takes: the picks in slot order, the empty ones left out.
func fitted_modules(chassis_id: String) -> Array:
	return module_picks(chassis_id).filter(func(m) -> bool: return not str(m).is_empty())


## The loadout make_mech takes: the picks in hardpoint order, the empty ones left out (the
## die's empty entries are what the hardpoints leave over).
func fitted(chassis_id: String) -> Array:
	var out: Array = []
	for cid in picks(chassis_id):
		if not str(cid).is_empty():
			out.append(str(cid))
	return out


# ---------------------------------------------------------------- launching

func make_team() -> Array:
	var out: Array = []
	var uid := 1
	for id in team:
		if db.chassis.has(id):
			out.append(db.make_mech(str(id), uid, Vector2i.ZERO, fitted(str(id)), fitted_modules(str(id))))
			uid += 1
	return out


## One skirmish: the team against every pack and the boss chained into one fight. Null when
## either side is empty.
func make_skirmish() -> Skirmish:
	var mechs := make_team()
	if mechs.is_empty():
		return null
	var sk := Skirmish.new(seed_value)   # the formation is always four wide (Ryan, 23 September)
	for u in mechs:
		sk.add_mech(u)
	var c := picked_composition()
	if not c.is_empty():
		# The composition alone, as a battle deals it: its members at the ramp's density, its
		# elites at the tier, its layout drawn from the seed; a split, a summon and a regrown part
		# call content up as in play.
		var sq := Unit.pack(90, str(c["id"]).replace("_", " "), Vector2i.ZERO, str(c["faction"]), Unit.PACK_MOVE, 1, "")
		var scaled: Array = []
		for m in c["members"]:
			scaled.append([str(m[0]), int(m[1])])
		sq.set_members(scaled)
		sq.boss_tier = clampi(tier - 1, 0, 2)
		sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
		sk.add_foes(db.foes_for(sq), sq)
		if c.has("layout"):
			sk.layout = ContentDB.resolve_layout(c["layout"], seed_value, 0)
		return sk if not sk.reinforcements.is_empty() else null
	var sid := 90
	for p in packs:
		var fid := str(p[0])
		if not db.foes.has(fid):
			continue
		var sq := Unit.pack(sid, "%s pack" % str(db.foes[fid]["name"]).to_lower(), Vector2i.ZERO, db.faction_of_foe(fid), Unit.PACK_MOVE, int(p[1]), fid)
		sk.add_foes(db.foes_for(sq), sq)
		sid += 1
	if not boss.is_empty():
		var b := Unit.boss(sid, str(db.foes[boss]["name"]).to_lower(), Vector2i.ZERO, db.faction_of_foe(boss))
		b.lineup = [boss]   # the boss picked, whichever of its domain's (30 October: the slate lists several)
		# Its own escort, where content writes one that names it (the King Gel's Gels, which its
		# merge takes in), at the harness's tier one; a domain's other escorts are the packs' to pick.
		var own := db.escort_composition(db.faction_of_foe(boss), 1, boss)
		if str(own.get("boss", "")) == boss:
			b.set_members(own["members"])
		sk.add_foes(db.foes_for(b), b)
	if sk.reinforcements.is_empty():
		return null
	return sk


## A whole battle on a map from the seed: the packs are its formation and its rift's cycle,
## the boss (or none) the lead faction's. Null without a team or a pack, since the rift
## needs something to send.
func make_battle() -> Battle:
	var mechs := make_team()
	var c := picked_composition()
	if not mechs.is_empty() and not c.is_empty():
		# A battle on the composition picked: a battle as a run deals it, at its tier and the ramp
		# chosen, with that composition the opening's and every wave's, and its domain's boss.
		var cb := Battle.new(seed_value)
		cb.map_kind = map_kind
		cb.tier = clampi(tier - 1, 0, 2)
		cb.ramp = ramp
		cb.only = c
		cb.setup(mechs, str(c["faction"]))
		return cb
	if mechs.is_empty() or packs.is_empty():
		return null
	var b := Battle.new(seed_value)
	b.map_kind = map_kind
	b.formation = packs.duplicate(true)
	b.with_boss = not boss.is_empty()
	if not boss.is_empty():
		b.lineup = [boss]   # the boss picked, whichever of its domain's (30 October: the slate lists several)
	b.guest = guest
	b.setup(mechs, lead_faction())
	return b


# ---------------------------------------------------------------- keeping

func to_dict() -> Dictionary:
	return {"team": team, "loadouts": loadouts, "modules": modules, "packs": packs, "boss": boss, "guest": guest, "seed": seed_value, "map_kind": map_kind,
		"composition": composition, "comp_faction": comp_faction, "tier": tier, "rating": rating, "ramp": ramp}


## A setup from a saved dictionary, checked against the content: unknown ids drop out, a
## loadout is cut or padded to its chassis's hardpoints, numbers are clamped.
static func from_dict(d: Dictionary, content: ContentDB = null) -> HarnessSetup:
	var s := HarnessSetup.new(content)
	for id in d.get("team", []):
		if s.db.chassis.has(str(id)) and not s.team.has(str(id)):
			s.team.append(str(id))
	if s.team.is_empty():
		s.team = s.db.default_team()
	var lo = d.get("loadouts", {})
	if lo is Dictionary:
		for id in lo.keys():
			if not s.db.chassis.has(str(id)) or not (lo[id] is Array):
				continue
			var n := int(s.db.chassis[str(id)].get("hardpoints", 0))
			var p: Array = []
			for cid in lo[id]:
				if p.size() < n:
					p.append(str(cid) if s.db.components.has(str(cid)) else "")
			while p.size() < n:
				p.append("")
			if p != s.stock_picks(str(id)):
				s.loadouts[str(id)] = p
	var mo = d.get("modules", {})
	if mo is Dictionary:
		for id in mo.keys():
			if s.db.chassis.has(str(id)) and mo[id] is Array:
				for k in range((mo[id] as Array).size()):
					s.set_module(str(id), k, str(mo[id][k]))
	var foes := s.pack_foes()
	for p in d.get("packs", []):
		if p is Array and p.size() >= 2 and foes.has(str(p[0])):
			s.packs.append([str(p[0]), clampi(int(p[1]), 1, MAX_STRENGTH)])
	var b := str(d.get("boss", ""))
	s.boss = b if s.bosses().has(b) else ""
	var g := str(d.get("guest", ""))
	s.guest = g if s.db.factions.has(g) else ""
	s.seed_value = clampi(int(d.get("seed", 7)), 1, MAX_SEED)
	var k := str(d.get("map_kind", ""))
	s.map_kind = k if BattleMap.KINDS.has(k) else ""
	var cf := str(d.get("comp_faction", ""))
	s.comp_faction = cf if s.db.factions.has(cf) else ""
	s.tier = clampi(int(d.get("tier", 1)), 1, 3)
	s.rating = clampi(int(d.get("rating", 0)), 0, 4)
	s.ramp = clampi(int(d.get("ramp", 0)), 0, Ramp.TOP)
	s.composition = str(d.get("composition", ""))
	if s.picked_composition().is_empty():
		s.composition = ""
	return s


func save(path: String = PATH) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(to_dict(), "\t"))


## The setup last launched, or the content's defaults when there is none.
static func load_or_default(content: ContentDB = null, path: String = PATH) -> HarnessSetup:
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			return from_dict(parsed, content)
	return defaults(content)

class_name HarnessSetup
extends RefCounted

## What the harness launches (game/harness.gd is its view): the team in the order it
## deploys, each machine's hardpoints, the enemy side (packs, a boss, a guest faction), the
## seed and the map's type. Pure, so the tests build the same fights the harness does.
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
var packs: Array = []           # [[foe_id, strength], ...]: on the field at the start and the rift's cycle in a battle, all chained in a fight
var boss: String = ""           # a faction's boss by foe id, "" for none
var guest: String = ""          # a battle's guest faction, joining the rift's cycle; "" for none
var seed_value: int = 7
var map_kind: String = "mixed"


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
	for e in db.spawn_table(faction_id):
		packs.append([str(e[0]), int(e[1])])
	var b := str(db.factions.get(faction_id, {}).get("boss", ""))
	boss = b if db.foes.has(b) else ""


## Every faction's boss, in content order: the boss picker's choices.
func bosses() -> Array:
	var out: Array = []
	for fid in db.factions.keys():
		var b := str(db.factions[fid].get("boss", ""))
		if db.foes.has(b) and not out.has(b):
			out.append(b)
	return out


## The foes a pack can be made of: every foe that is no faction's boss, in content order.
func pack_foes() -> Array:
	var skip := bosses()
	var out: Array = []
	for fid in db.foes.keys():
		if not skip.has(fid):
			out.append(str(fid))
	return out


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
			out.append(db.make_mech(str(id), uid, Vector2i.ZERO, fitted(str(id))))
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
		sk.add_foes(db.foes_for(b), b)
	if sk.reinforcements.is_empty():
		return null
	return sk


## A whole battle on a map from the seed: the packs are its formation and its rift's cycle,
## the boss (or none) the lead faction's. Null without a team or a pack, since the rift
## needs something to send.
func make_battle() -> Battle:
	var mechs := make_team()
	if mechs.is_empty() or packs.is_empty():
		return null
	var b := Battle.new(seed_value)
	b.map_kind = map_kind
	b.formation = packs.duplicate(true)
	b.with_boss = not boss.is_empty()
	b.guest = guest
	b.setup(mechs, lead_faction())
	return b


# ---------------------------------------------------------------- keeping

func to_dict() -> Dictionary:
	return {"team": team, "loadouts": loadouts, "packs": packs, "boss": boss, "guest": guest, "seed": seed_value, "map_kind": map_kind}


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
	var foes := s.pack_foes()
	for p in d.get("packs", []):
		if p is Array and p.size() >= 2 and foes.has(str(p[0])):
			s.packs.append([str(p[0]), clampi(int(p[1]), 1, MAX_STRENGTH)])
	var b := str(d.get("boss", ""))
	s.boss = b if s.bosses().has(b) else ""
	var g := str(d.get("guest", ""))
	s.guest = g if s.db.factions.has(g) else ""
	s.seed_value = clampi(int(d.get("seed", 7)), 1, MAX_SEED)
	var k := str(d.get("map_kind", "mixed"))
	s.map_kind = k if BattleMap.KINDS.has(k) else "mixed"
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

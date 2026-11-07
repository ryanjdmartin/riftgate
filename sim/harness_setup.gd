class_name HarnessSetup
extends RefCounted

## What the harness launches (game/harness.gd is its view), a battle and a fight apart (Ryan, 7
## November: "battle and fight are two seperate things that need two separate tabs in the
## harness"): the team in the order it deploys, each machine's hardpoints and modules; a BATTLE as
## a run deals it, its domain, a guest, the tier, the ramp and which of the domain's bosses ("The
## Battle from the harness should be a battle, as it will be in the final game"); a FIGHT, a
## composition picked by its domain, tier and threat rating, or packs and a boss by hand; the seed
## and the map's shape both share. Pure, so the tests build the same battles and fights the
## harness does. Kept in user://harness.json between launches; ids the content no longer has are
## dropped on load, never trusted.

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
var seed_value: int = 7         # the battle's map and every fight's dice
var map_kind: String = ""        # a map shape (BattleMap.KINDS), or "" for the one the seed draws
# ---- the BATTLE tab: a battle as a run deals it
var battle_faction: String = ""  # the domain it is fought against, "" for the content's first
var battle_boss: String = ""     # which of its bosses, "" for its first
var guest: String = ""           # a guest domain, its compositions taking turns in the cycle; "" for none
var battle_tier: int = 1         # the tier, 1 to 3: who comes, the Fractures, the elites, the boss's numbers
var ramp: int = 0                # the Convergence, 0 to Ramp.TOP: the field's size, the opening's count, the beat
# ---- the FIGHT tab: one fight
## A composition picked by its domain, tier and threat rating (Ryan, 6 November: the harness
## "should load a formation from a selected tier and threat level (the machine count, 1-4 that
## includes elites)"): fought alone, its elites at the tier, its layout dealt. "" for the packs.
var composition: String = ""
var comp_faction: String = ""    # its domain, "" for the content's first
var fight_tier: int = 1          # the tier it is listed and dealt at, 1 to 3, and a boss's
var rating: int = 0              # the threat rating listed, 1 to 4; 0 lists every one
var packs: Array = []            # [[foe_id, strength], ...]: one pack's members, or the boss's escort when one is picked
var boss: String = ""            # a boss by foe id with its escort at the fight's tier, "" for none


func _init(content: ContentDB = null) -> void:
	db = content if content != null else ContentDB.load_default()


## The content's defaults: its starting team in stock loadouts; a battle against the first
## domain; a fight against its spawn list and boss.
static func defaults(content: ContentDB = null) -> HarnessSetup:
	var s := HarnessSetup.new(content)
	s.team = s.db.default_team()
	s.use_faction(s.db.default_faction())
	return s


## Fill the fight's packs from a faction: its spawn list as the packs, its boss.
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


## The domain a battle is fought against: the one picked, else the content's first.
func battle_domain() -> String:
	return battle_faction if db.factions.has(battle_faction) else db.default_faction()


## The battle domain's bosses, in content order: the BATTLE tab's boss picker.
func battle_bosses() -> Array:
	return db.bosses_of(battle_domain())


## The boss the battle brings: the one picked while it is the domain's, else the domain's first.
func battle_boss_id() -> String:
	var all := battle_bosses()
	if all.has(battle_boss):
		return battle_boss
	return str(all[0]) if not all.is_empty() else ""


## The compositions the FIGHT tab lists: the domain's patrols, formations and elites as a battle at
## `fight_tier` deals them (a lower tier's standing in where it has none, as in play), those rated
## `rating` (every one at 0), in content order; each ContentDB's dealt dictionary.
func compositions_listed() -> Array:
	var out: Array = []
	var fac := comp_faction if db.factions.has(comp_faction) else db.default_faction()
	for size in ["patrol", "formation", "elite"]:
		for c in db.compositions(fac, fight_tier, size):
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


## One fight: the team against the composition picked, or against the packs and the boss built by
## hand as one unit. Null when either side is empty.
func make_skirmish() -> Skirmish:
	var mechs := make_team()
	if mechs.is_empty():
		return null
	var sk := Skirmish.new(seed_value)   # the formation is always four wide (Ryan, 23 September)
	for u in mechs:
		sk.add_mech(u)
	var c := picked_composition()
	if not c.is_empty():
		# The composition alone, dealt as a battle deals it (Battlefield.pack_of): its members as
		# content writes them, its lead, its layout drawn from the seed and the pack what the draw
		# places; its elites at the tier; a split, a summon and a regrown part call content up as in
		# play.
		var sq := Battlefield.pack_of(c, seed_value, 0)
		if sq == null:
			return null
		sq.id = 90
		sq.display_name = str(c["id"]).replace("_", " ")
		sq.boss_tier = clampi(fight_tier - 1, 0, 2)
		sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
		sk.add_foes(db.foes_for(sq), sq)
		sk.layout = sq.layout.duplicate()
		return sk if not sk.reinforcements.is_empty() else null
	# By hand, one unit as the game deals one (one pack is one fight): the packs' foes as one
	# pack's members, or with a boss picked, the boss at the fight's tier with them as its escort
	# (its own curated escort at the tier when none are listed: the King Gel's Gels, which its merge
	# takes in; none grown by the tier). What its slots cannot hold is left out here, so the fight
	# is one the game could deal.
	var members: Array = []
	for p in packs:
		if db.foes.has(str(p[0])):
			members.append([str(p[0]), int(p[1])])
	var unit: Unit = null
	if not boss.is_empty():
		# The boss picked, whichever of its domain's (30 October: the slate lists several), as the
		# battle fields it (Battle.make_boss_unit); the packs listed, if any, its escort instead.
		unit = Battle.make_boss_unit(db, db.faction_of_foe(boss), clampi(fight_tier - 1, 0, 2), boss, [boss])
		unit.id = 90
		if not members.is_empty():
			unit.set_members(members)
	elif not members.is_empty():
		var lead := str(members[0][0])
		unit = Unit.pack(90, "%s pack" % str(db.foes[lead]["name"]).to_lower(), Vector2i.ZERO, db.faction_of_foe(lead), Unit.PACK_MOVE, 1, lead)
		unit.set_members(members)
	if unit == null:
		return null
	sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
	sk.add_foes(ContentDB.fit_grid(db.foes_for(unit)), unit)
	if sk.reinforcements.is_empty():
		return null
	return sk


## A whole battle on a map from the seed, as a run deals it (Campaign.start_battle): the domain's
## compositions at the tier, the guest's taking turns, the ramp's opening and beat, the boss picked
## at the tier with its escort. Null without a team.
func make_battle() -> Battle:
	var mechs := make_team()
	if mechs.is_empty():
		return null
	var fac := battle_domain()
	var b := Battle.new(seed_value)
	b.map_kind = map_kind
	b.tier = clampi(battle_tier - 1, 0, 2)
	b.ramp = ramp
	b.guest = guest if guest != fac else ""
	var bid := battle_boss_id()
	if not bid.is_empty():
		b.lineup = [bid]
	b.setup(mechs, fac)
	return b


# ---------------------------------------------------------------- keeping

func to_dict() -> Dictionary:
	return {"team": team, "loadouts": loadouts, "modules": modules, "seed": seed_value, "map_kind": map_kind,
		"battle_faction": battle_faction, "battle_boss": battle_boss, "guest": guest, "battle_tier": battle_tier, "ramp": ramp,
		"composition": composition, "comp_faction": comp_faction, "fight_tier": fight_tier, "rating": rating, "packs": packs, "boss": boss}


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
	var bf := str(d.get("battle_faction", ""))
	s.battle_faction = bf if s.db.factions.has(bf) else ""
	var bb := str(d.get("battle_boss", ""))
	s.battle_boss = bb if s.battle_bosses().has(bb) else ""
	s.battle_tier = clampi(int(d.get("battle_tier", 1)), 1, 3)
	s.ramp = clampi(int(d.get("ramp", 0)), 0, Ramp.TOP)
	var cf := str(d.get("comp_faction", ""))
	s.comp_faction = cf if s.db.factions.has(cf) else ""
	s.fight_tier = clampi(int(d.get("fight_tier", d.get("tier", 1))), 1, 3)   # "tier" before the tabs parted (7 November)
	s.rating = clampi(int(d.get("rating", 0)), 0, 4)
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

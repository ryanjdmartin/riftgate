class_name Loadouts
extends RefCounted

## Sample dice, mechs, and packs. Placeholder numbers for prototypes and tests.
## None of these are balanced. They exist so there is something to roll.

const L := Face.Reach.LINE
const I := Face.Reach.INDIRECT
const K := Face.Keyword


## Four hardpoints, all teeth. Kinetic, so it rolls. Numbers in tens.
static func brawler_die() -> Die:
	return Die.of([
		Face.attack(20, L, K.CLEAVE, 0, 40, 10),
		Face.attack(20, L, K.CLEAVE, 0, 40, 10),
		Face.attack(30, L, K.NONE, 10, 60, 15),
		Face.shield(20),
	])


## Six hardpoints. A bit of everything, so each face shows less often.
static func gunner_die() -> Die:
	return Die.of([
		Face.attack(10, L, [], 0, 30, 10),
		Face.attack(10, L, [], 0, 30, 10),
		Face.attack(30, L, K.PENETRATE, 10),
		Face.attack(10, I, [], 0, 30, 5),
		Face.shield(20),
		Face.vent(20),
	])


## Six hardpoints. Artillery and support: hits the back rank, keeps the team cool.
static func mortar_die() -> Die:
	return Die.of([
		Face.attack(20, I, [], 0, 50, 10),
		Face.attack(20, I, [], 0, 50, 10),
		Face.attack(10, I, K.BURN, 0, 30, 5),
		Face.attack(30, I, K.SUPPRESS, 20, 50, 10),
		Face.vent(30),
		Face.shield(10),
	])


## A skirmisher aircraft: big shield, low hull, few faces, runs hot. Energy, so static.
static func sparrowhawk_die() -> Die:
	return Die.of([
		Face.attack(100, L, [], 40),
		Face.attack(20, L, K.EXECUTE, 0, 40, 20),
		Face.attack(30, L, K.CHAIN, 10),
		Face.shield(30),
	])


## The starting team, built from content/chassis.json.
static func sample_mechs() -> Array[Unit]:
	var db := ContentDB.load_default()
	var out: Array[Unit] = []
	for id in db.default_team():
		out.append(db.make_mech(id))
	return out


## Unpack a battlefield pack into foes for a skirmish, from content/factions.json.
static func foes_for(sq: Unit) -> Array[Foe]:
	return ContentDB.load_default().foes_for(sq)


## Packs placed on open ground in the north third of the map, drawn from the factions'
## spawn lists so each is one foe type times a strength.
static func sample_packs(field: Battlefield, count: int, rng: RandomNumberGenerator) -> Array[Unit]:
	var db := ContentDB.load_default()
	var out: Array[Unit] = []
	var factions: Array = db.factions.keys()
	var tries := 0
	while out.size() < count and tries < 200:
		tries += 1
		var col := rng.randi_range(0, field.map.width - 1)
		var row := rng.randi_range(1, maxi(1, field.map.height / 3))
		var h := Hex.offset_to_axial(col, row)
		if h == field.map.rift or not field.is_free(h):
			continue
		if not BattleMap.passable(field.map.terrain[h], []):
			continue
		var fac: String = factions[rng.randi_range(0, factions.size() - 1)]
		var table := db.spawn_table(fac)
		if table.is_empty():
			continue
		var entry: Array = table[rng.randi_range(0, table.size() - 1)]
		var sq := Unit.pack(0, "%s pack" % str(entry[0]), h, fac, 2, int(entry[1]), str(entry[0]))
		sq.behaviour = "aggressive" if rng.randf() < 0.2 else "push"
		field.add_unit(sq)
		out.append(sq)
	return out

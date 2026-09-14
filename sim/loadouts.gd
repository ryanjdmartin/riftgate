class_name Loadouts
extends RefCounted

## Sample dice, mechs, and squads. Placeholder numbers for prototypes and tests.
## None of these are balanced. They exist so there is something to roll.

const L := Face.Reach.LINE
const I := Face.Reach.INDIRECT
const K := Face.Keyword


## Four hardpoints, all teeth. Reliable, short-reaching.
static func brawler_die() -> Die:
	return Die.of([
		Face.attack(3, L, K.CLEAVE),
		Face.attack(3, L, K.CLEAVE),
		Face.attack(4, L, K.NONE, 1),
		Face.shield(2),
	])


## Six hardpoints. A bit of everything, so each face shows less often.
static func gunner_die() -> Die:
	return Die.of([
		Face.attack(2, L),
		Face.attack(2, L),
		Face.attack(3, L, K.PIERCE, 1),
		Face.attack(2, I),
		Face.shield(2),
		Face.vent(2),
	])


## Six hardpoints. Artillery and support: hits the back rank, keeps the team cool.
static func mortar_die() -> Die:
	return Die.of([
		Face.attack(3, I),
		Face.attack(3, I),
		Face.attack(2, I, K.BURN),
		Face.attack(4, I, K.SUPPRESS, 2),
		Face.vent(3),
		Face.shield(1),
	])


## A skirmisher aircraft: big shield, low hull, few faces, runs hot.
static func raptor_die() -> Die:
	return Die.of([
		Face.attack(5, L, K.OVERCHARGE, 2),
		Face.attack(3, L, K.EXECUTE),
		Face.attack(3, L, K.CHAIN, 1),
		Face.shield(3),
	])


## The starting team, built from content/chassis.json.
static func sample_mechs() -> Array[Unit]:
	var db := ContentDB.load_default()
	var out: Array[Unit] = []
	for id in ["bulwark", "sentinel", "raptor"]:
		out.append(db.make_mech(id))
	return out


## Unpack a battlefield squad into foes for a skirmish, from content/factions.json.
static func foes_for(sq: Unit) -> Array[Foe]:
	return ContentDB.load_default().foes_for(sq)


## Squads placed on open ground in the north third of the map.
static func sample_squads(field: Battlefield, count: int, rng: RandomNumberGenerator) -> Array[Unit]:
	var out: Array[Unit] = []
	var factions := ["undead", "undead", "demonic", "eldritch"]
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
		var sq := Unit.squad(0, "%s squad" % fac, h, fac, 2, 6)
		sq.aggro = rng.randf() < 0.2
		field.add_unit(sq)
		out.append(sq)
	return out

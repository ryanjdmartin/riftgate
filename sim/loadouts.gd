class_name Loadouts
extends RefCounted

## Sample dice, and a pack's foes. Placeholder numbers for prototypes and tests.
## None of these are balanced. They exist so there is something to roll.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT
const K := Face.Keyword


## Four hardpoints, all teeth. Rolled numbers. Numbers in tens.
static func brawler_die() -> Die:
	return Die.of([
		Face.attack(20, L, K.CLEAVE, 0, 40),
		Face.attack(20, L, K.CLEAVE, 0, 40),
		Face.attack(30, L, K.NONE, 10, 60),
		Face.shield(20),
	])


## Six hardpoints. A bit of everything, so each face shows less often.
static func gunner_die() -> Die:
	return Die.of([
		Face.attack(10, L, [], 0, 30),
		Face.attack(10, L, [], 0, 30),
		Face.attack(30, L, K.PENETRATE, 10),
		Face.attack(10, I, [], 0, 30),
		Face.shield(20),
		Face.vent(20),
	])


## Six hardpoints. Artillery and support: hits the back rank, keeps the team cool.
static func mortar_die() -> Die:
	return Die.of([
		Face.attack(20, I, [], 0, 50),
		Face.attack(20, I, [], 0, 50),
		Face.attack(10, I, K.BURN, 0, 30),
		Face.attack(30, I, K.SUPPRESS, 20, 50),
		Face.vent(30),
		Face.shield(10),
	])


## A skirmisher aircraft: big shield, low hull, few faces, runs hot. Flat numbers.
static func sparrowhawk_die() -> Die:
	return Die.of([
		Face.attack(100, L, [], 40),
		Face.attack(20, L, [], 0, 40),
		Face.attack(30, L, K.CHAIN, 10),
		Face.shield(30),
	])


## Unpack a battlefield pack into foes for a skirmish, from content/factions.json.
static func foes_for(sq: Unit) -> Array[Foe]:
	return ContentDB.load_default().foes_for(sq)

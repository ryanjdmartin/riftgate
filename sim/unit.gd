class_name Unit
extends RefCounted

## A thing on the battlefield: a player mech, an enemy squad, or a city defense.

enum Side { PLAYER, ENEMY }

var id: int = 0
var display_name: String = ""
var side: int = Side.PLAYER
var pos: Vector2i = Vector2i.ZERO
var movespeed: int = 3
var hull: int = 100
var hull_max: int = 100
var shield: int = 40
var shield_max: int = 40
var heat_max: int = 60

## Chassis traits: "flyer", "hover", "walker", "tank", "defense".
var traits: Array[String] = []

## Hexes this unit covers, as axial offsets from pos. Squads and mechs are one hex; a massive
## boss is three in a triangle. Every footprint hex blocks, touches, and is a tap target.
var footprint: Array[Vector2i] = [Vector2i.ZERO]

## Presentation: index into Hex.DIRECTIONS of the last step taken.
var facing: int = 0

# Enemy squads only. A squad is one foe type times a strength; a boss is a squad with `elite`
# set, which unpacks into the faction's massive boss.
var faction: String = ""
var foe_id: String = ""      # content id of the foe this squad is made of
var strength: int = 6        # how many foes the squad holds
var aggro: bool = false      # hunts mechs instead of the gate
var elite: bool = false      # this unit is the faction's boss

const TRIANGLE: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]

# Skirmish loadout for mechs.
var die: Die = null
var passive: Dictionary = {}     # content passive, run by Passives; empty means none
var chassis_id: String = ""
var hardpoints: int = 0          # free slots; the die is these plus the chassis's fixed components
var recharge_combat: int = 0     # shield regained at the start of each skirmish round after the first
var recharge_field: int = 0      # shield regained each battlefield phase the mech spends out of combat

## Damaged components. A cracked or destroyed component is damaged and stays that way across
## skirmishes and battles until repaired in the hangar. Maps a die entry index to the
## original, undamaged component.
var damaged_faces: Dictionary = {}


static func mech(uid: int, name: String, at: Vector2i, speed: int = 3) -> Unit:
	var u := Unit.new()
	u.id = uid
	u.display_name = name
	u.side = Side.PLAYER
	u.pos = at
	u.movespeed = speed
	return u


static func squad(uid: int, name: String, at: Vector2i, fac: String = "undead", speed: int = 2, size: int = 6, foe: String = "") -> Unit:
	var u := Unit.new()
	u.id = uid
	u.display_name = name
	u.side = Side.ENEMY
	u.pos = at
	u.movespeed = speed
	u.faction = fac
	u.foe_id = foe
	u.strength = size
	u.shield = 0
	u.shield_max = 0
	return u


## A single huge enemy that covers three hexes and unpacks into its faction's massive elite.
static func boss(uid: int, name: String, at: Vector2i, fac: String = "undead", speed: int = 1) -> Unit:
	var u := squad(uid, name, at, fac, speed, 0)
	u.elite = true
	u.footprint = TRIANGLE.duplicate()
	u.hull = 1
	return u


static func defense(uid: int, name: String, at: Vector2i) -> Unit:
	var u := Unit.new()
	u.id = uid
	u.display_name = name
	u.side = Side.PLAYER
	u.pos = at
	u.movespeed = 0
	u.traits = ["defense"]
	return u


func is_player() -> bool:
	return side == Side.PLAYER


func is_enemy() -> bool:
	return side == Side.ENEMY


func is_static() -> bool:
	return traits.has("defense")


## Flyers engage but never hold ground.
func can_block() -> bool:
	return not traits.has("flyer")


func alive() -> bool:
	return hull > 0


func hexes() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for o in footprint:
		out.append(pos + o)
	return out


func occupies(h: Vector2i) -> bool:
	for o in footprint:
		if pos + o == h:
			return true
	return false


func is_multi_hex() -> bool:
	return footprint.size() > 1


## True if any hex of this unit is adjacent to any hex of `other`.
func touches(other: Unit) -> bool:
	if other == self:
		return false
	for a in hexes():
		for b in other.hexes():
			if Hex.are_adjacent(a, b):
				return true
	return false


## Shield comes back at two rates, both chassis stats: a little each skirmish round in
## combat, more each battlefield phase spent out of it. Never a full refill for free, so
## withdrawing and re-engaging is not a way to reset (Ryan, 18 September).
func recharge_shield(amount: int) -> int:
	var before := shield
	shield = mini(shield_max, shield + maxi(0, amount))
	return shield - before


func damaged_component_count() -> int:
	return damaged_faces.size()


## Meta-level repair: every damaged component goes back to what it was.
func repair_faces() -> void:
	if die == null:
		damaged_faces.clear()
		return
	for idx in damaged_faces.keys():
		if idx < die.faces.size():
			die.faces[idx] = damaged_faces[idx]
	damaged_faces.clear()

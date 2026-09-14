class_name Unit
extends RefCounted

## A thing on the battlefield: a player mech, an enemy squad, or a city defense.

enum Side { PLAYER, ENEMY }

var id: int = 0
var display_name: String = ""
var side: int = Side.PLAYER
var pos: Vector2i = Vector2i.ZERO
var movespeed: int = 3
var hull: int = 10
var hull_max: int = 10
var shield: int = 4
var shield_max: int = 4

## Chassis traits: "flyer", "hover", "quad", "tank", "defense".
var traits: Array[String] = []

## Hexes this unit covers, as axial offsets from pos. Squads and mechs are one hex; a massive
## boss is three in a triangle. Every footprint hex blocks, touches, and is a tap target.
var footprint: Array[Vector2i] = [Vector2i.ZERO]

## Presentation: index into Hex.DIRECTIONS of the last step taken.
var facing: int = 0

# Enemy squads only.
var faction: String = ""
var strength: int = 6        # how many foes the squad holds
var aggro: bool = false      # hunts mechs instead of the gate
var elite: bool = false      # brings its faction's massive elite into the skirmish

const TRIANGLE: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]

# Skirmish loadout for mechs.
var die: Die = null
var passive: Dictionary = {}     # content passive, run by Passives; empty means none
var chassis_id: String = ""


static func mech(uid: int, name: String, at: Vector2i, speed: int = 3) -> Unit:
	var u := Unit.new()
	u.id = uid
	u.display_name = name
	u.side = Side.PLAYER
	u.pos = at
	u.movespeed = speed
	return u


static func squad(uid: int, name: String, at: Vector2i, fac: String = "undead", speed: int = 2, size: int = 6) -> Unit:
	var u := Unit.new()
	u.id = uid
	u.display_name = name
	u.side = Side.ENEMY
	u.pos = at
	u.movespeed = speed
	u.faction = fac
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


func recharge_shield() -> void:
	shield = shield_max

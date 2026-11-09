class_name Unit
extends RefCounted

## A thing on the battlefield: a player mech, an enemy pack, or a city defense.

enum Side { PLAYER, ENEMY }

## Moves are in hexes (Ryan, 28 October): a step is one hex, water a ground machine wades two.
## The defaults a unit is made with before content dresses it; the content carries every real
## number.
const MECH_MOVE := 3
const PACK_MOVE := 2
const BOSS_MOVE := 1   # the boss patrols a hex a turn

var id: int = 0
var display_name: String = ""
var side: int = Side.PLAYER
var pos: Vector2i = Vector2i.ZERO
var hull: int = 100      # current points; the maximum is a question (see base)
var shield: int = 40

## Base numbers from the chassis. Every maximum and rate is read through Effects.stat, which
## adds every live modifier (fitted components, rewards, buffs) on top; writing hull_max or
## armour sets the base. Nothing stores a total (decided 18 September).
var base: Dictionary = {"hull": 100, "shield": 40, "heat": 60, "armour": 0, "move": 3, "cooling": 0, "shield_regen": 0}
var modifiers: Array = []   # Effects.Modifier list: loadout, battle, skirmish and timed effects
var recorder = null         # the round preview's copy alone (Skirmish.preview_round): an Array every grant and stack this unit gains is noted in (Effects._record); null in any fight that plays
var allies: int = 0         # live allies in the fight this unit is in, kept by the skirmish, for passives that read it
var hull_max: int:
	get:
		return Effects.stat(self, "hull")
	set(v):
		base["hull"] = v
var shield_max: int:
	get:
		return Effects.stat(self, "shield")
	set(v):
		base["shield"] = v
var heat_max: int:
	get:
		return Effects.stat(self, "heat")
	set(v):
		base["heat"] = v
var armour: int:
	get:
		return Effects.stat(self, "armour")
	set(v):
		base["armour"] = v
var movespeed: int:
	get:
		return Effects.stat(self, "move")
	set(v):
		base["move"] = v
## Heat shed at the start of every skirmish round, passively, before the roll: venting is a
## tactic, but a round spent on shields or cool weapons is a way of cooling too.
var cooling: int:
	get:
		return Effects.stat(self, "cooling")
	set(v):
		base["cooling"] = v
## Shield regained at the start of every skirmish round, after the cooling, up to the maximum (the
## long wall brief 3.6; Ryan, 5 November: "Base shield regen and cooling returning, as a
## build-strategy buffer"): a chassis stat beside cooling, which modules and passives may move.
## No chassis sets it yet.
var shield_regen: int:
	get:
		return Effects.stat(self, "shield_regen")
	set(v):
		base["shield_regen"] = v

## Chassis traits: a way of moving ("flyer", "hover", "walker", "tracked", "wheeled";
## BattleMap.WAYS), or "defense" for a static unit. A pack carries none and moves by the
## horde's rule, unless its foe is winged: then "winged", and it crosses as a flyer does.
var traits: Array[String] = []

## Hexes this unit covers, as axial offsets from pos. Packs and mechs are one hex; a massive
## boss is three in a triangle. Every footprint hex blocks, touches, and is a tap target.
var footprint: Array[Vector2i] = [Vector2i.ZERO]

## Presentation: index into Hex.DIRECTIONS of the last step taken.
var facing: int = 0

# Enemy packs only. A pack is one foe type times a strength; a boss is a pack with `is_boss`
# set, which holds the rift and unpacks into its commanders (its lineup, or the faction's boss
# whatever its size: big is apart from boss), then its escort, its foe type times its strength.
var faction: String = ""
var foe_id: String = ""      # content id of the foe this pack is made of (a boss's escort)
var strength: int = 6        # how many foes the pack holds (a boss: its escort, none for a boss alone)
var lineup: Array = []       # a boss unit's commanders, foe ids in order (a final's hero, the finale's line); empty for the faction's boss
var boss_tier: int = 0       # a boss unit's battle tier, 0 to 2: its commanders' numbers and its escort follow it (ContentDB.BOSS_TIERS); an elite's too, for a wandering elite's numbers (31 October)
## The pack's members (the foes' fresh start, 30 October): [[foe_id, strength], ...] in content
## order, the first the lead, whose sprite the pack wears; `foe_id` is the lead's
## and `strength` the count of every member, kept in step by set_members. Empty is the one-type
## pack, `foe_id` times `strength` (a test's, the harness's, a save's from before). A boss unit's
## members are its hand-tailored escort when one is written; empty, its escort is its `foe_id`
## times its `strength`, or the tier's units.
var members: Array = []
var composition: String = ""       # the composition it emerged as (content's id), "" for a one-type pack
var composition_size: String = ""  # its size: patrol, formation, elite or escort (ContentDB.COMPOSITION_SIZES); "" for a one-type pack
var behaviour: String = "push"   # push: walks toward the gate; hunt: walks toward one machine, its prey (bible section 5), when its composition says so (`hunts`; Battlefield.pack_of)
var hunts: String = "nearest"    # a hunter's caveat: nearest, weakest, strongest, slowest or fastest
var prey: int = 0                # a hunter's locked machine, by unit id; 0 until it has picked one
var layout: Array = []           # a dealt composition's grid, eight cells (the front rank's four, then the back's), each a foe id or "" (the long wall brief, section 6; ContentDB.resolve_layout); [] for none
var squad: int = 3               # the threat rating, the machines the pack is intended for, 1 to 4 (the long wall brief 3.7; ContentDB.squad_of)
var goal_col: int = -1           # a pusher's wall segment, the column of the apron hex it walks to (the long wall brief 3.3, Battlefield.assign_goal); -1 for none, which walks to the nearest apron hex
var is_boss: bool = false    # this unit commands the rift: the faction's boss, a final's hero or the finale's line (`elite` until 15 October, the word now the elites')
var sealed: bool = false     # a boss unit's seal (the pacing session, 30 October): while it holds, the unit cannot be ordered onto and joins no fight; the Rupture breaks it
var attack_range: int = 1    # placeholder (the long wall brief): adjacency; a machine may be committed to a fight on a pack within this many hexes

const TRIANGLE: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]

# Skirmish loadout for mechs.
var die: Die = null
var paint: Dictionary = {}       # optional repaint: {"primary": Color, "secondary": Color}; empty means the maker's livery
var passive: Dictionary = {}     # the chassis passive as content, for the codex; the engine runs modifiers
var chassis_id: String = ""
var hardpoints: int = 0          # free slots; the die is these plus the chassis's fixed components

## Damaged components. A destroyed component is damaged and stays that way across
## skirmishes and battles until repaired in the hangar. Maps a die entry index to the
## original, undamaged component.
var damaged_faces: Dictionary = {}

## Modules fitted (content ids, in slot order), for the codex and the hangar; the engine runs
## them as loadout modifiers sourced "module" (ContentDB.fit_module).
var modules: Array[String] = []


static func mech(uid: int, name: String, at: Vector2i, speed: int = MECH_MOVE) -> Unit:
	var u := Unit.new()
	u.id = uid
	u.display_name = name
	u.side = Side.PLAYER
	u.pos = at
	u.movespeed = speed
	return u


static func pack(uid: int, name: String, at: Vector2i, fac: String = "", speed: int = PACK_MOVE, size: int = 6, foe: String = "") -> Unit:
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


## A single enemy that covers three hexes and unpacks into its faction's boss.
## A boss stands on one hex for now (Ryan, 22 September: a wider footprint cannot path
## through a field of hexes, and the boss guards the rift rather than marching). The
## multi-hex footprint (`TRIANGLE`) stays in the engine for later.
static func boss(uid: int, name: String, at: Vector2i, fac: String = "", speed: int = BOSS_MOVE) -> Unit:
	var u := pack(uid, name, at, fac, speed, 0)
	u.is_boss = true
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


## Give the pack its members, the lead first: its foe type and its strength follow.
func set_members(list: Array) -> void:
	members = []
	var total := 0
	for m in list:
		if m is Array and (m as Array).size() >= 2 and int(m[1]) > 0:
			members.append([str(m[0]), int(m[1])])
			total += int(m[1])
	if not members.is_empty():
		foe_id = str(members[0][0])
	strength = total


## The members as the engine reads them: the list, or the one-type pack as one member.
func member_list() -> Array:
	if not members.is_empty():
		return members.duplicate(true)
	return [[foe_id, strength]] if strength > 0 else []


func member_ids() -> Array:
	var out: Array = []
	for m in member_list():
		out.append(str(m[0]))
	return out


func is_player() -> bool:
	return side == Side.PLAYER


func is_enemy() -> bool:
	return side == Side.ENEMY


func is_static() -> bool:
	return traits.has("defense")


## A flyer or a winged pack: it and a grounded unit pass each other and never meet but in a
## fight (Ryan, 29 October: "flyers and ground never interact except to fight").
func airborne() -> bool:
	return traits.has("flyer") or traits.has("winged")


## Flyers engage but never hold ground: nobody is stopped by an airborne unit.
func can_block() -> bool:
	return not airborne()


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


## Shield gained in a fight (a component, a module, a passive, the shield regen), up to the
## maximum or past it with Overshield. Nothing returns on the map: the shield is full as every
## fight opens (the long wall brief 3.6). Returns what stood up.
func recharge_shield(amount: int, overshield: bool = false) -> int:
	var before := shield
	if overshield:
		# Overshield (5 October): the shield may pass its maximum; the excess fades at the
		# round's end (Skirmish._trim_overshield). A shield already past it still gains.
		shield = shield + maxi(0, amount)
	else:
		shield = mini(shield_max, shield + maxi(0, amount)) if shield < shield_max else shield
	return shield - before


## Grant a content passive as a loadout modifier (tests and the hangar).
func grant_passive(p: Dictionary, source: String = "chassis", component: String = "") -> void:
	Effects.grant(self, Effects.make(p, Effects.LOADOUT, source, component))


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

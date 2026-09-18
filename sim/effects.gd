class_name Effects
extends RefCounted

## The one pipeline for everything that changes a mech's numbers or a component's
## properties: the chassis passive, component passives, battle-long rewards, skirmish-long
## buffs and debuffs, and effects timed to a round. Decided with Ryan, 18 September.
##
## Nothing is ever written to a stat or a component. Every read asks this pipeline, so an
## effect that is gone (its scope ended, its round passed, it was suppressed, its component
## was destroyed) simply stops answering, and the answer always has a source.
##
## A Modifier is a passive (the content shape: id, name, description, effects) with a
## lifetime (scope) and a source. Scopes, shortest-lived first:
##   ROUNDS    gone after the end of `expires_round` (a debuff "until end of next round")
##   SKIRMISH  gone when the skirmish ends (a buff "for this fight")
##   BATTLE    gone when the battle ends (a skirmish reward)
##   LOADOUT   the chassis passive and every fitted component's passive; until refitted
##
## Order of operations, the same for every query:
##   0. suppression: shortest scope to longest, a live modifier's `suppress` effect turns off
##      every modifier whose id or tag it names; a suppressed modifier suppresses nothing
##   1. gate: a modifier takes part only if it is live, not suppressed, its trigger fires now
##      (static: always; on_attack: any attack; on_crit: only a crit; on_injury: an injury),
##      its `when` holds, and, for an ability, its component is not destroyed (a destroyed
##      component keeps its stat bonuses and loses its abilities)
##   2. adds, every source summed
##   3. multiplies, every source multiplied
##   4. floors and caps (min_damage; a stat never below zero)
##   5. overrides (set_reach): the shortest-lived source wins, then the latest granted
## In an attack, the crit multiplier and the fixed keyword rules (overcharge, execute) are
## applied by the skirmish before step 2, so the pipeline's adds and multiplies come last.

const LOADOUT := 0
const BATTLE := 1
const SKIRMISH := 2
const ROUNDS := 3

## What the content may ask for, by trigger. The validator refuses anything else.
const SUPPORTED_EFFECTS := {
	"on_attack": ["multiply_damage", "add_damage", "min_damage", "multiply_heat", "add_heat"],
	"on_crit": ["multiply_damage", "add_damage", "add_burn", "vent_heat", "add_crit_damage"],
	"on_injury": ["no_destroy"],
	"static": ["set_reach", "add_stat", "multiply_stat", "add_damage_taken", "multiply_damage_taken", "suppress"],
}
const SUPPORTED_WHEN := ["component_cracked", "reach_melee", "reach_line", "reach_indirect"]
## Stats a static effect may change: the mech's base numbers by these names.
const STATS := ["hull", "shield", "heat", "armour", "move", "recharge"]
## Effects that are bonuses (a destroyed component keeps them) rather than abilities.
const BONUS_EFFECTS := ["add_stat", "multiply_stat"]

static var _seq := 0


class Modifier:
	extends RefCounted
	var id: String = ""
	var name: String = ""
	var description: String = ""
	var source: String = ""        # "chassis", a component id, "reward", "foe:<id>"...
	var component: String = ""     # the fitted component this came from, or ""
	var scope: int = LOADOUT
	var expires_round: int = -1    # ROUNDS only: gone after the end of this round
	var tags: Array[String] = []
	var effects: Array = []        # [{trigger, effect, value, (when), (stat)}]
	var seq: int = 0               # grant order, for override ties

	func matches(key: String) -> bool:
		return id == key or tags.has(key)


## A modifier from a content passive. A draft ("status": "planned") or an empty passive
## grants nothing.
static func make(passive: Dictionary, scope: int, source: String, component: String = "") -> Modifier:
	if passive.is_empty() or str(passive.get("status", "implemented")) != "implemented":
		return null
	var m := Modifier.new()
	m.id = str(passive.get("id", source))
	m.name = str(passive.get("name", ""))
	m.description = str(passive.get("description", ""))
	m.source = source
	m.component = component
	m.scope = scope
	for t in passive.get("tags", []):
		m.tags.append(str(t))
	m.effects = passive.get("effects", [])
	return m


static func grant(u, m: Modifier) -> Modifier:
	if m == null:
		return null
	_seq += 1
	m.seq = _seq
	u.modifiers.append(m)
	return m


## A timed effect: gone after the end of `round`.
static func grant_for_rounds(u, passive: Dictionary, source: String, round: int) -> Modifier:
	var m := make(passive, ROUNDS, source)
	if m != null:
		m.expires_round = round
	return grant(u, m)


static func supports(trigger: String, effect: String) -> bool:
	return SUPPORTED_EFFECTS.has(trigger) and SUPPORTED_EFFECTS[trigger].has(effect)


static func supports_when(when: String) -> bool:
	return when.is_empty() or SUPPORTED_WHEN.has(when)


# ---------------------------------------------------------------- lifetimes

static func end_round(u, round: int) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if not (m.scope == ROUNDS and m.expires_round <= round):
			keep.append(m)
	u.modifiers = keep


static func end_skirmish(u) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if m.scope != ROUNDS and m.scope != SKIRMISH:
			keep.append(m)
	u.modifiers = keep


static func end_battle(u) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if m.scope == LOADOUT:
			keep.append(m)
	u.modifiers = keep


# ---------------------------------------------------------------- the gate

## Live modifiers after suppression, shortest scope first, latest granted first within a
## scope: the order overrides are resolved in.
static func live(u) -> Array:
	var all: Array = u.modifiers.duplicate()
	all.sort_custom(func(a, b) -> bool: return a.scope > b.scope or (a.scope == b.scope and a.seq > b.seq))
	var off := {}
	for m in all:
		if off.has(m):
			continue
		for eff in m.effects:
			if str(eff.get("trigger", "")) == "static" and str(eff.get("effect", "")) == "suppress":
				var key := str(eff.get("value", ""))
				for other in all:
					if other != m and other.matches(key):
						off[other] = true
	var out: Array = []
	for m in all:
		if not off.has(m):
			out.append(m)
	return out


## A component-sourced ability is off while its component is destroyed; its bonuses stay.
static func _usable(u, m: Modifier, effect: String) -> bool:
	if m.component.is_empty() or BONUS_EFFECTS.has(effect) or u.die == null:
		return true
	var seen := false
	for f in u.die.faces:
		if f.component == m.component:
			seen = true
			if f.kind != Face.Kind.BLANK:
				return true
	return not seen


## Whether a trigger fires in the query asking: the caller asks on_injury only on an injury
## and on_attack only on an attack, so those always fire here; on_crit needs the crit.
static func _fires(trigger: String, crit: bool) -> bool:
	if trigger == "on_crit":
		return crit
	return SUPPORTED_EFFECTS.has(trigger)


## Does an effect's `when` hold for the component in hand? Reach conditions read the
## effective reach, so "+10% melee" follows a component the same passive sent to melee.
static func _holds(u, eff: Dictionary, face: Face) -> bool:
	match str(eff.get("when", "")):
		"":
			return true
		"component_cracked":
			return face != null and face.cracked
		"reach_melee":
			return face != null and effective_reach(u, face) == Face.Reach.MELEE
		"reach_line":
			return face != null and effective_reach(u, face) == Face.Reach.LINE
		"reach_indirect":
			return face != null and effective_reach(u, face) == Face.Reach.INDIRECT
	return false


## Every effect taking part in a query: [effect dictionary, modifier], gated as above.
static func _taking_part(u, trigger: String, face: Face, crit: bool = false) -> Array:
	var out: Array = []
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != trigger or not _fires(trigger, crit):
				continue
			var name := str(eff.get("effect", ""))
			if not _usable(u, m, name) or not _holds(u, eff, face):
				continue
			out.append([eff, m])
	return out


# ---------------------------------------------------------------- queries

## A mech stat: its base, plus every add, times every multiplier, never below zero.
static func stat(u, name: String) -> int:
	var base: float = float(u.base.get(name, 0))
	var add := 0.0
	var mult := 1.0
	for pair in _taking_part(u, "static", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("stat", "")) != name:
			continue
		match str(eff.get("effect", "")):
			"add_stat":
				add += float(eff.get("value", 0))
			"multiply_stat":
				mult *= float(eff.get("value", 1))
	return maxi(0, int(roundf((base + add) * mult)))


## What the pipeline adds to the crit multiplier (add_crit_damage, on a crit), summed.
static func crit_bonus(u, face: Face) -> float:
	var total := 0.0
	for pair in _taking_part(u, "on_crit", face, true):
		if str(pair[0].get("effect", "")) == "add_crit_damage":
			total += float(pair[0].get("value", 0))
	return total


## An attack after the crit multiplier and the keyword rules: adds, then multiplies, then
## floors, on damage and on heat; burn and vent from crit effects. Returns
## {damage, heat, burn, vent}.
static func attack(u, face: Face, dmg: int, heat: int, crit: bool) -> Dictionary:
	var d_add := 0.0
	var d_mult := 1.0
	var d_floor := 0
	var h_add := 0.0
	var h_mult := 1.0
	var burn := 0
	var vent := 0
	var parts: Array = _taking_part(u, "on_attack", face, crit)
	parts.append_array(_taking_part(u, "on_crit", face, crit))
	for pair in parts:
		var eff: Dictionary = pair[0]
		var v: float = float(eff.get("value", 0))
		match str(eff.get("effect", "")):
			"add_damage":
				d_add += v
			"multiply_damage":
				d_mult *= v
			"min_damage":
				d_floor = maxi(d_floor, int(v))
			"add_heat":
				h_add += v
			"multiply_heat":
				h_mult *= v
			"add_burn":
				burn += int(v)
			"vent_heat":
				vent += int(v)
	var out_dmg := maxi(d_floor, int(roundf((dmg + d_add) * d_mult)))
	var out_heat := maxi(0, int(roundf((heat + h_add) * h_mult)))
	return {"damage": out_dmg, "heat": out_heat, "burn": burn, "vent": vent}


## An incoming blow before shield and armour see it: adds, then multiplies, never below zero.
static func damage_taken(u, amount: int) -> int:
	var add := 0.0
	var mult := 1.0
	for pair in _taking_part(u, "static", null):
		var eff: Dictionary = pair[0]
		match str(eff.get("effect", "")):
			"add_damage_taken":
				add += float(eff.get("value", 0))
			"multiply_damage_taken":
				mult *= float(eff.get("value", 1))
	return maxi(0, int(roundf((amount + add) * mult)))


## A component's reach as it is right now: its own, unless a live set_reach holds. Static
## reach rules are read against the component itself (never against effective reach, which
## would loop), so they may key on cracked but not on reach. The first live modifier in
## override order (shortest scope, latest granted) wins.
static func effective_reach(u, face: Face) -> int:
	if face == null:
		return Face.Reach.NONE
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != "static" or str(eff.get("effect", "")) != "set_reach":
				continue
			if str(eff.get("when", "")).begins_with("reach_") or not _usable(u, m, "set_reach"):
				continue
			if _holds(u, eff, face):
				var r := Face.reach_from_name(str(eff.get("value", "")))
				if r >= 0:
					return r
	return face.reach


## Does the pipeline hold a cracked component short of destruction?
static func no_destroy(u, face: Face) -> bool:
	for pair in _taking_part(u, "on_injury", face):
		if str(pair[0].get("effect", "")) == "no_destroy":
			return true
	return false


## What the codex lists: every live modifier as [name, description, source, scope].
static func describe(u) -> Array:
	var out: Array = []
	for m in live(u):
		out.append([m.name, m.description, m.source, m.scope])
	return out

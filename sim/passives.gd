class_name Passives
extends RefCounted

## Minimal passive trigger runner. Passives are content dictionaries of the shape
## {"id", "name", "description", "effects": [{"trigger", "effect", "value", ("when")}]}.
## description is player-facing (the codex prints it after the name).
## Only the triggers, effects and conditions listed here are executed; the content validator
## refuses anything else so a passive never silently does nothing. A passive marked
## "status": "planned" is a draft: kept in content, ignored here.
##
## on_attack runs on every attack after the damage roll; on_crit runs only when it crit;
## on_injury runs when an injury lands on a component. `when` narrows an effect to a
## condition on the component being used.

const SUPPORTED_EFFECTS := {
	"on_attack": ["multiply_damage", "multiply_heat", "add_damage", "add_heat", "min_damage"],
	"on_crit": ["multiply_damage", "add_damage", "add_burn", "vent_heat", "add_crit_damage"],
	"on_injury": ["no_destroy"],
	"static": ["set_reach"],
}
const SUPPORTED_WHEN := ["component_cracked", "reach_melee", "reach_line", "reach_indirect"]


static func supports(trigger: String, effect: String) -> bool:
	return SUPPORTED_EFFECTS.has(trigger) and SUPPORTED_EFFECTS[trigger].has(effect)


static func supports_when(when: String) -> bool:
	return when.is_empty() or SUPPORTED_WHEN.has(when)


## A passive the engine runs: present and not marked "planned" (a draft in content).
static func active(passive: Dictionary) -> bool:
	return not passive.is_empty() and str(passive.get("status", "implemented")) == "implemented"


## Does this effect's `when` hold for the component in use? No `when` always holds.
static func _holds(eff: Dictionary, face: Face) -> bool:
	match str(eff.get("when", "")):
		"":
			return true
		"component_cracked":
			return face != null and face.cracked
		"reach_melee":
			return face != null and face.reach == Face.Reach.MELEE
		"reach_line":
			return face != null and face.reach == Face.Reach.LINE
		"reach_indirect":
			return face != null and face.reach == Face.Reach.INDIRECT
	return false


## A static (always-on) reach override for this component, or -1 for none. The condition is
## checked against the component as it is now, so a cracked one can be sent to melee.
static func static_reach(passive: Dictionary, face: Face) -> int:
	if not active(passive):
		return -1
	for eff in passive.get("effects", []):
		if str(eff.get("trigger", "")) == "static" and str(eff.get("effect", "")) == "set_reach" and _holds(eff, face):
			return Face.reach_from_name(str(eff.get("value", "")))
	return -1


## Apply on_attack effects for the component `face` being spent. Returns [damage, heat].
static func on_attack(passive: Dictionary, dmg: int, heat: int, face: Face = null) -> Array:
	if not active(passive):
		return [dmg, heat]
	for eff in passive.get("effects", []):
		if str(eff.get("trigger", "")) != "on_attack" or not _holds(eff, face):
			continue
		var v: float = float(eff.get("value", 0))
		match str(eff.get("effect", "")):
			"multiply_damage":
				dmg = int(roundf(dmg * v))
			"multiply_heat":
				heat = int(roundf(heat * v))
			"add_damage":
				dmg += int(v)
			"add_heat":
				heat += int(v)
			"min_damage":
				dmg = maxi(dmg, int(v))
	return [dmg, heat]


## What the passive adds to the crit multiplier (add_crit_damage effects, summed): applied
## with the base and the component's own bonus before any other on_crit effect.
static func crit_bonus(passive: Dictionary, face: Face = null) -> float:
	var total := 0.0
	if not active(passive):
		return total
	for eff in passive.get("effects", []):
		if str(eff.get("trigger", "")) == "on_crit" and str(eff.get("effect", "")) == "add_crit_damage" and _holds(eff, face):
			total += float(eff.get("value", 0))
	return total


## Apply on_crit effects after the multiplier. Returns {"damage", "burn", "vent"}: extra burn
## stacks for the target and heat vented from the attacker.
static func on_crit(passive: Dictionary, dmg: int, face: Face = null) -> Dictionary:
	var out := {"damage": dmg, "burn": 0, "vent": 0}
	if not active(passive):
		return out
	for eff in passive.get("effects", []):
		if str(eff.get("trigger", "")) != "on_crit" or not _holds(eff, face):
			continue
		var v: float = float(eff.get("value", 0))
		match str(eff.get("effect", "")):
			"multiply_damage":
				out["damage"] = int(roundf(out["damage"] * v))
			"add_damage":
				out["damage"] += int(v)
			"add_burn":
				out["burn"] += int(v)
			"vent_heat":
				out["vent"] += int(v)
	return out


## What the passive says about an injury landing on `face`. Returns {"no_destroy": bool}:
## true means a cracked component holds instead of being destroyed.
static func on_injury(passive: Dictionary, face: Face) -> Dictionary:
	var out := {"no_destroy": false}
	if not active(passive):
		return out
	for eff in passive.get("effects", []):
		if str(eff.get("trigger", "")) != "on_injury" or not _holds(eff, face):
			continue
		if str(eff.get("effect", "")) == "no_destroy":
			out["no_destroy"] = true
	return out

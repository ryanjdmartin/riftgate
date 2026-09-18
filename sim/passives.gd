class_name Passives
extends RefCounted

## Minimal passive trigger runner. Passives are content dictionaries of the shape
## {"id", "name", "description", "rules": [...], "effects": [{"trigger", "effect", "value"}]}.
## description is player-facing (the codex prints it after the name).
## Only the triggers and effects listed here are executed; the content validator refuses
## anything else so a passive never silently does nothing.
##
## on_attack runs on every attack after the damage roll; on_crit runs only when it crit.

const SUPPORTED_EFFECTS := {
	"on_attack": ["multiply_damage", "multiply_heat", "add_damage", "add_heat", "min_damage"],
	"on_crit": ["multiply_damage", "add_damage", "add_burn", "vent_heat"],
}


static func supports(trigger: String, effect: String) -> bool:
	return SUPPORTED_EFFECTS.has(trigger) and SUPPORTED_EFFECTS[trigger].has(effect)


## A passive the engine runs: present and not marked "planned" (a draft in content).
static func active(passive: Dictionary) -> bool:
	return not passive.is_empty() and str(passive.get("status", "implemented")) == "implemented"


## Apply on_attack effects. Returns [damage, heat].
static func on_attack(passive: Dictionary, dmg: int, heat: int) -> Array:
	if not active(passive):
		return [dmg, heat]
	for eff in passive.get("effects", []):
		if str(eff.get("trigger", "")) != "on_attack":
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


## Apply on_crit effects. Returns {"damage", "burn", "vent"}: extra burn stacks for the
## target and heat vented from the attacker.
static func on_crit(passive: Dictionary, dmg: int) -> Dictionary:
	var out := {"damage": dmg, "burn": 0, "vent": 0}
	if not active(passive):
		return out
	for eff in passive.get("effects", []):
		if str(eff.get("trigger", "")) != "on_crit":
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

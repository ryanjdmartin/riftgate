class_name Passives
extends RefCounted

## Minimal passive trigger runner. Passives are content dictionaries of the shape
## {"id", "name", "fantasy", "rules": [...], "effects": [{"trigger", "effect", "value"}]}.
## Only the triggers and effects listed here are executed; the content validator refuses
## anything else so a passive never silently does nothing.

const SUPPORTED_EFFECTS := {
	"on_attack": ["multiply_damage", "multiply_heat", "add_damage", "add_heat"],
}


static func supports(trigger: String, effect: String) -> bool:
	return SUPPORTED_EFFECTS.has(trigger) and SUPPORTED_EFFECTS[trigger].has(effect)


## Apply on_attack effects. Returns [damage, heat].
static func on_attack(passive: Dictionary, dmg: int, heat: int) -> Array:
	if passive.is_empty():
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
	return [dmg, heat]

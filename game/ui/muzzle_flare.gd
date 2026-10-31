class_name MuzzleFlare
extends RefCounted

## A weapon's muzzle flare (Ryan, 31 October: "If the flare colour of the weapons can follow
## their tags, that would be really cool"): a soft star where its class's business end is
## (art/models/shapes/muzzles.json, lowforge's MUZZLES), drawn toward the eye over the gun, its
## colour laid over the hull and past the machine's outline (flare.gdshader). The component's tags pick
## its look: a colour in the glows' language and a beat of its own, so two weapons part by how
## their flares move as well as by their colour (Ryan reads colour poorly; never hue alone). A
## component with two tags takes the first of ORDER it carries; one with none, its class's.
##
## Each colour is a static var so a debug build's COLOURS page (ColourTuner) can try another; the
## hangar's motion.js keeps the same table (FLARES) for its Shot button.

## Gunfire: an orange short of the one that reads yellow to Ryan.
static var BALLISTIC := Color("ff6a00")
## A rocket's launch: a redder orange.
static var MISSILE := Color("ff4c00")
## A fire weapon: the burn's red.
static var FLAME := Color("ff2400")
## A beam: a crimson, a little blue in the red, which a fire never has.
static var BEAM := Color("ff0a40")
## Plasma: a hot pink, clear of the enemy's violet by every simulation (docs/measurements.md).
static var PLASMA := Color("ff2a8c")
## Lightning: the electric cyan of the Dingo's coil.
static var ARC := Color("40d8ff")
## Steel on steel: a blade's sparks.
static var BLADE := Color("ff7800")

## The tags in the order one picks the look (content's working set, sim/content_db.gd).
const ORDER := ["flame", "arc", "plasma", "beam", "missile", "ballistic", "blade", "melee"]
## A class's look for a component with no tag.
const CLASS_LOOK := {"barrel": "ballistic", "twin_barrel": "ballistic", "rack": "missile", "dish": "arc", "blade": "blade"}

## The beat a look moves to: rays (0 a round bloom, 2 a streak across, 4 or more a star), the
## seconds it takes to bloom, to hold and to fade, a flicker's rate (0 for none; a strobe for the
## arc, softer for the flame), and a scale on its class's size.
const BEATS := {
	"ballistic": {"rays": 4, "up": 0.03, "hold": 0.04, "down": 0.16, "flicker": 0.0, "scale": 1.0},
	"missile": {"rays": 0, "up": 0.06, "hold": 0.10, "down": 0.45, "flicker": 0.0, "scale": 1.25},
	"flame": {"rays": 0, "up": 0.06, "hold": 0.28, "down": 0.35, "flicker": 14.0, "scale": 1.15},
	"beam": {"rays": 2, "up": 0.04, "hold": 0.32, "down": 0.18, "flicker": 0.0, "scale": 1.4},
	"plasma": {"rays": 6, "up": 0.14, "hold": 0.10, "down": 0.30, "flicker": 0.0, "scale": 1.2},
	"arc": {"rays": 5, "up": 0.02, "hold": 0.30, "down": 0.10, "flicker": 22.0, "scale": 1.0},
	"blade": {"rays": 8, "up": 0.02, "hold": 0.03, "down": 0.12, "flicker": 0.0, "scale": 0.8},
}


## The look a component's tags give it, on its class: a tag of ORDER (melee takes the blade's).
static func look_for(tags: Array, shape: String) -> String:
	for t in ORDER:
		if tags.has(t):
			return "blade" if t == "melee" else t
	return str(CLASS_LOOK.get(shape, "ballistic"))


static func colour(look: String) -> Color:
	match look:
		"missile": return MISSILE
		"flame": return FLAME
		"beam": return BEAM
		"plasma": return PLASMA
		"arc": return ARC
		"blade": return BLADE
	return BALLISTIC


## How bright a flare is `t` seconds after its weapon fired, 0 to 1: it blooms, holds and fades on
## its look's beat, a flicker laid over the hold.
static func strength(look: String, t: float) -> float:
	var b: Dictionary = BEATS.get(look, BEATS["ballistic"])
	var up := float(b["up"])
	var hold := float(b["hold"])
	var down := float(b["down"])
	if t < 0.0 or t >= up + hold + down:
		return 0.0
	var k := 1.0
	if t < up:
		var f := t / up
		k = 1.0 - (1.0 - f) * (1.0 - f)
	elif t >= up + hold:
		var g := (t - up - hold) / down
		k = 1.0 - g * g * (3.0 - 2.0 * g)
	var hz := float(b["flicker"])
	if hz > 0.0:
		var wave := sin(TAU * hz * t)
		k *= (1.0 if wave >= 0.0 else 0.25) if look == "arc" else 0.7 + 0.3 * wave
	return k


static func lasts(look: String) -> float:
	var b: Dictionary = BEATS.get(look, BEATS["ballistic"])
	return float(b["up"]) + float(b["hold"]) + float(b["down"])


static var _places: Dictionary = {}


## Each class's flare places, [[point, size], ...] in the class's frame under its pin.
static func places(shape: String) -> Array:
	if _places.is_empty():
		var f := FileAccess.open("res://art/models/shapes/muzzles.json", FileAccess.READ)
		var parsed = JSON.parse_string(f.get_as_text()) if f != null else null
		_places = parsed if parsed is Dictionary else {"_none": []}
	var out: Array = []
	for p in _places.get(shape, []):
		if p is Array and (p as Array).size() == 2 and p[0] is Array and (p[0] as Array).size() == 3:
			out.append([Vector3(float(p[0][0]), float(p[0][1]), float(p[0][2])), float(p[1])])
	return out

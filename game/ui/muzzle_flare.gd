class_name MuzzleFlare
extends RefCounted

## A weapon's muzzle flare (Ryan, 31 October: "If the flare colour of the weapons can follow
## their tags, that would be really cool"): a soft star where its gun's business end is (its
## class's places in art/models/shapes/muzzles.json, lowforge's MUZZLES, a stock gun's as a fitted
## one's), drawn toward the eye over the gun, its colour laid over the hull and past the
## machine's outline, its middle hot (flare.gdshader). Each tag a component carries has its look,
## a colour and a beat; a component with two blooms both at once, the way it delivers its blow
## first (a shell, a rocket, a beam, an edge) and what the blow carries over it, smaller and a
## beat behind (fire, plasma, lightning), so an incendiary shell flashes and then burns. One with
## no tag takes its class's look. The colours are what each kind of shot looks like and carry no
## meaning in play, so they are free of the colourblind rules (Ryan, 2 November: "Not worried about
## colourblind issues for things that carry no gameplay information like weapon effects. Choose
## colours that make sense"); the hangar's motion.js keeps the same table (FLARES).

## Each look's colour and how much its middle whitens: gunfire's yellow-orange flash, a rocket's
## orange, fire's orange-red, a laser's red, plasma's green, lightning's electric blue, sparks'
## yellow.
const COLOURS := {
	"ballistic": Color(1.0, 0.71, 0.24), "missile": Color(1.0, 0.48, 0.13), "flame": Color(1.0, 0.29, 0.06),
	"beam": Color(1.0, 0.13, 0.25), "plasma": Color(0.4, 1.0, 0.33), "arc": Color(0.54, 0.85, 1.0), "blade": Color(1.0, 0.84, 0.35),
}
const CORES := {"ballistic": 0.7, "missile": 0.5, "flame": 0.35, "beam": 0.6, "plasma": 0.55, "arc": 0.75, "blade": 0.8}

## The tags in the order a component's looks layer: how it delivers its blow, then what the blow
## carries (content's working set, sim/content_db.gd). Melee throws a blade's sparks, on a weapon
## that lunges (lunges): on one that fires, melee is its range and shows nothing of its own.
const ORDER := ["ballistic", "missile", "beam", "blade", "melee", "flame", "plasma", "arc"]
## The tags that send a blow across the field (a shell, a rocket, a beam), and the classes built
## to fire one.
const CROSSING := ["ballistic", "missile", "beam"]
const FIRING := ["barrel", "twin_barrel", "rack", "dish"]
## A class's look for a component with no tag.
const CLASS_LOOK := {"barrel": "ballistic", "twin_barrel": "ballistic", "rack": "missile", "dish": "arc"}
## Each layer after the first blooms this much later and this much smaller than the one before.
const LAYER_DELAY := 0.05
const LAYER_SCALE := 0.75

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


## Whether a weapon lunges at its foe rather than firing at it: melee (its tag: short range, a
## shotgun included) with nothing that sends its blow across the field, no tag of CROSSING and no
## firing class (none named: a locked melee piece, built into its machine). The rest fire as guns do, kicking back and
## flaring: a shotgun tagged melee and ballistic as the gun it is (Ryan, 3 November, of the Bullion
## Fragmenter: "It's a shotgun, thematically"), a flamethrower tagged melee as its stream, and a
## claw the Cottonmouth's drum fires as its shot (the drum adds Ballistic). The screen's lunge, the
## shot trail's none and a blade's sparks in the flare all read it.
static func lunges(tags: Array, shape: String = "") -> bool:
	if not tags.has("melee") or FIRING.has(shape):
		return false
	for t in CROSSING:
		if tags.has(t):
			return false
	return true


## Every look a component's tags give it, in the order they layer (ORDER), or its class's alone.
static func looks_for(tags: Array, shape: String) -> Array:
	var out: Array = []
	var edge := lunges(tags, shape)
	for t in ORDER:
		if t == "melee" and not edge:
			continue
		var look := "blade" if t == "melee" else str(t)
		if tags.has(t) and not out.has(look):
			out.append(look)
	if out.is_empty():
		out.append(str(CLASS_LOOK.get(shape, "ballistic")))
	return out


static func colour(look: String) -> Color:
	return COLOURS.get(look, COLOURS["ballistic"])


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

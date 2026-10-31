class_name Palette
extends RefCounted

## UI colours. The screen is a tactical overlay: near-black ground, chrome in one HUD colour
## the player picks in settings (see Settings), and one fixed set of semantic colours that
## never changes with the chrome. A register a meaning, and every state also carries a glyph or
## a shape, never colour alone: the rift's violet is the enemy's, for everything a foe does
## (Ryan, 30 October: "keep purple for enemy activities"); heat is a red-orange, for what heats
## or hits harder; a red-red is harm to a unit, GAIN's green the other way; shield is the only
## blue; good and selection are white. A red or an orange is red and green alone, never blue
## (Ryan, 29 October: moving the blue too when he asked for brighter or darker is what made the
## reds hard to judge), and leans red: a lighter, less red orange can read as green to him, and
## green is GAIN's (30 October), and past about #ff8200 an orange reads as yellow or green.
##
## Each colour is a static var so a debug build's COLOURS page (ColourTuner) can set it to try
## another (Ryan, 30 October); the values here are the defaults every other build draws with.

static var BG := Color("070907")
static var PANEL := Color("0c100c")
static var PANEL_RAISED := Color("121812")
static var RULE := Color("2c3a2c")
static var INK := Color("f2f4ee")
static var MUTED := Color("7b857c")
## The enemy's violet, the rift's light one, which the packs' routes have worn since 29 September
## (Ryan, 30 October: "keep purple for enemy activities"): everything a foe does, on a plate or
## straight on a ground: its intents, plaques, chips and readouts, the skirmish's arrows, the map's
## rings, bands, routes and marks, the rift's bars and tears, and what a foe did to a machine; on
## the map a deep edge under its lines and a deep and a bright of its own (BattleMapView's
## ENEMY_EDGE, ENEMY_DEEP and ENEMY_HOT). By the Machado simulations its worst case on a chip's
## black is 9.2:1 (protan), where the red it replaced stood 3.0; docs/measurements.md.
static var ENEMY := Color("c8a4ff")
static var HULL := Color("d8d2c4")
static var SHIELD := Color("2f63d8")
## Heat's red-orange (Ryan, 30 October: "Lighter, less red oranges sometimes look green to me ...
## when green can mean 'good,' that can be a problem. That's why I'd rather redden the heat
## colour"): the redder of his #ff3000 to #ff4000 by its protan contrast on a chip's black, 3.7:1
## to #ff3000's 3.4 (docs/measurements.md).
static var HEAT := Color("ff4000")
static var SELECT := Color("ffffff")
static var TARGET := Color("ffffff")
static var OK := Color("ffffff")
## A number moved in its unit's favour, in the holds and the codex, always with its arrow; the
## other way is LOSS (Ryan, 26 October: "If that means using green, this is the place for it";
## "Positive and negative are always relative to the unit, not the player"). Picked by the
## Machado simulation's worst case: against the red, deutan, lightness 87 to 60; against the
## ink, every simulation a clear step apart.
static var GAIN := Color("5cff6a")
## Harm to a unit, a red-red past heat's red-orange (Ryan, 30 October: "any other 'reds' can be
## either a slightly more red-red, the violet, or the heat orange-red on a case by case basis"):
## GAIN's other way, a kill or a wreck forecast, an entry that cannot pay (DRY, SHORT), a stop
## with no room, a foe Exposed, the gate's integrity low. A foe's doing is the violet, never this.
static var LOSS := Color("ff0000")
## A dead thing, dimmed: a blank or destroyed entry, a wrecked machine's die, a dying foe's ghost.
static var LOSS_DIM := Color("7a1400")

## The overlay colour. Settings.apply() sets it from the saved choice; this is the green
## preset's, the default.
static var HUD := Color("60ffb0")

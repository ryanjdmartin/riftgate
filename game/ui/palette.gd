class_name Palette
extends RefCounted

## UI colours. The screen is a tactical overlay: near-black ground, chrome in one HUD colour
## the player picks in settings (see Settings), and one fixed set of semantic colours that
## never changes with the chrome. Decided with Ryan on 18 September from swatches he judged
## by eye: no green or purple carries meaning but GAIN's; shield is the only blue; enemy and
## heat are both warm and a lightness band apart; good and selection are white; every state
## also carries a glyph or a shape, never colour alone. A red or an orange is red and green
## alone, never blue (Ryan, 29 October: moving the blue too when he asked for brighter or darker
## is what made the reds hard to judge), and an orange stays under about #ff8200, past which it
## reads as yellow or green to him.
##
## Each colour is a static var so a debug build's COLOURS page (ColourTuner) can set it to try
## another (Ryan, 30 October); the values here are the defaults every other build draws with.

static var BG := Color("070907")
static var PANEL := Color("0c100c")
static var PANEL_RAISED := Color("121812")
static var RULE := Color("2c3a2c")
static var INK := Color("f2f4ee")
static var MUTED := Color("7b857c")
static var ACCENT := Color("ff6000")      # the heat colour, used sparingly as an accent
static var ACCENT_INK := Color("070907")
## The enemy's red, pure (Ryan, 29 October, a try: "try just full ff0000 for me, please. no
## outlines"). By the Machado simulations its worst cases are 3.0:1 on a chip's black (protan)
## and ΔE2000 5.6 from heat's orange (deutan); docs/measurements.md has the read.
static var ENEMY := Color("ff0000")
## The enemy's red where it is drawn straight on a ground rather than on a plate: the skirmish's
## intent arrows, and the map's rings, bands, edges and marks. ENEMY's own value unless the
## colour tuner parts them, so a line can be tried in another colour than the chips.
static var ENEMY_ARROW := Color("ff0000")
static var ENEMY_MAP := Color("ff0000")
static var ENEMY_DIM := Color("7a1400")
static var HULL := Color("d8d2c4")
static var SHIELD := Color("2f63d8")
## Heat's orange (Ryan, 29 October: "I actually like ff6000"; the green steps 30, 40, 50 and 60
## past pure red are each distinct to him). docs/measurements.md has its read against the red.
static var HEAT := Color("ff6000")
static var SELECT := Color("ffffff")
static var TARGET := Color("ffffff")
static var OK := Color("ffffff")
## A number moved in its unit's favour, in the holds and the codex, always with its arrow; the
## other way is the enemy red (Ryan, 26 October: "If that means using green, this is the place
## for it"; "Positive and negative are always relative to the unit, not the player"). Picked by the Machado simulation's worst case: against the red, deutan, lightness
## 87 to 60; against the ink, every simulation a clear step apart.
static var GAIN := Color("5cff6a")

## The overlay colour. Settings.apply() sets it from the saved choice.
static var HUD := Color("5cff6a")

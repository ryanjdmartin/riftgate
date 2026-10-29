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

const BG := Color("070907")
const PANEL := Color("0c100c")
const PANEL_RAISED := Color("121812")
const RULE := Color("2c3a2c")
const INK := Color("f2f4ee")
const MUTED := Color("7b857c")
const ACCENT := Color("ff6000")      # the heat colour, used sparingly as an accent
const ACCENT_INK := Color("070907")
## The enemy's red, pure (Ryan, 29 October, a try: "try just full ff0000 for me, please. no
## outlines"). By the Machado simulations its worst cases are 3.0:1 on a chip's black (protan)
## and ΔE2000 5.6 from heat's orange (deutan); docs/measurements.md has the read.
const ENEMY := Color("ff0000")
const ENEMY_DIM := Color("7a1400")
const HULL := Color("d8d2c4")
const SHIELD := Color("2f63d8")
## Heat's orange (Ryan, 29 October: "I actually like ff6000"; the green steps 30, 40, 50 and 60
## past pure red are each distinct to him). docs/measurements.md has its read against the red.
const HEAT := Color("ff6000")
const SELECT := Color("ffffff")
const TARGET := Color("ffffff")
const OK := Color("ffffff")
## A number moved in its unit's favour, in the holds and the codex, always with its arrow; the
## other way is the enemy red (Ryan, 26 October: "If that means using green, this is the place
## for it"; "Positive and negative are always relative to the unit, not the player"). Picked by the Machado simulation's worst case: against the red, deutan, lightness
## 87 to 60; against the ink, every simulation a clear step apart.
const GAIN := Color("5cff6a")

## The overlay colour. Settings.apply() sets it from the saved choice.
static var HUD := Color("5cff6a")

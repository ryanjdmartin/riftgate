class_name Palette
extends RefCounted

## UI colours. The screen is a tactical overlay: near-black ground, chrome in one HUD colour
## the player picks in settings (see Settings), and one fixed set of semantic colours that
## never changes with the chrome. Decided with Ryan on 18 September from swatches he judged
## by eye: no green or purple carries meaning but GAIN's; shield is the only blue; enemy and
## heat are both warm, the enemy's a light red and heat's a saturated orange; good and
## selection are white; every state also carries a glyph or a shape, never colour alone.

const BG := Color("070907")
const PANEL := Color("0c100c")
const PANEL_RAISED := Color("121812")
const RULE := Color("2c3a2c")
const INK := Color("f2f4ee")
const MUTED := Color("7b857c")
const ACCENT := Color("ff6a00")      # the heat colour, used sparingly as an accent
const ACCENT_INK := Color("070907")
## The enemy's red, light so it reads on a chip's black and on the field for every kind of
## colour vision (Ryan, 29 October: the red chips were "hard to see on the new backgrounds"):
## by the Machado simulations' worst case it stands 6.2:1 on the chips where #ff1e1e stood
## 3.2:1 (protan), and further from the heat orange than #ff1e1e did (ΔE2000 7.5 tritan, the
## worst, where it was 6.1 deutan).
const ENEMY := Color("ff7c80")
## The edge under every red line and border drawn on a ground: deep red, not black (Ryan, 29
## September: black made candy canes).
const ENEMY_EDGE := Color("5a0e0e")
const ENEMY_DIM := Color("7a1414")
const HULL := Color("d8d2c4")
const SHIELD := Color("2f63d8")
const HEAT := Color("ff6a00")
const SELECT := Color("ffffff")
const TARGET := Color("ffffff")
const OK := Color("ffffff")
## A number moved in its unit's favour, in the holds and the codex, always with its arrow; the
## other way is the enemy red (Ryan, 26 October: "If that means using green, this is the place
## for it"; "Positive and negative are always relative to the unit, not the player"). Picked by the Machado simulation's worst case: against the red, deutan, ΔE2000 14
## (lightness 87 to 71); against the ink, every simulation a clear step apart.
const GAIN := Color("5cff6a")

## The overlay colour. Settings.apply() sets it from the saved choice.
static var HUD := Color("5cff6a")

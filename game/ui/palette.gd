class_name Palette
extends RefCounted

## UI colours. The screen is a tactical overlay: near-black ground, everything drawn in one
## HUD colour that the player picks in settings (see Settings), with a few semantic colours
## for heat, enemies and the rift.

const BG := Color("070907")
const PANEL := Color("0c100c")
const PANEL_RAISED := Color("121812")
const RULE := Color("2c3a2c")
const INK := Color("dfe8e0")
const MUTED := Color("6f8a74")
const ACCENT := Color("e3894b")      # hazard orange, used sparingly
const ACCENT_INK := Color("070907")
const ENEMY := Color("ff5c5c")
const ENEMY_DIM := Color("6e3434")
const HULL := Color("d8d2c4")
const SHIELD := Color("5aa9e6")
const HEAT := Color("ff6a3d")
const SELECT := Color("f2c14e")
const TARGET := Color("f2c14e")
const OK := Color("6fbf73")
const RIFT := Color("b48ce3")

## The overlay colour. Settings.apply() sets it from the saved choice.
static var HUD := Color("5cff6a")

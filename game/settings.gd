class_name Settings
extends RefCounted

## Player settings, saved to user://settings.cfg: the HUD colour and the display knobs
## (22 September: the map tuner's useful knobs, made the player's), and a debug build's colour
## picks (ColourTuner).

const PATH := "user://settings.cfg"

## HUD colour choices, in the order a picker shows them.
# Chrome only: the semantic colours in Palette never change with this, and no choice wears
# one (the enemy's violet, heat's red-orange, harm's red). A static var so a debug build's
# colour tuner can set them.
static var HUD_OPTIONS := {
	"green": Color("60ffb0"),   # minty since 30 October, so it parts from the amber for red-green vision (15 apart in the worst simulation where #33ff55 stood 2.4; Ryan: "Move to the minty, yes")
	"amber": Color("fff21a"),
	"blue": Color("5cd8ff"),
}
const DEFAULT_HUD := "green"

static var hud: String = DEFAULT_HUD
static var _loaded := false

## The display knobs: key -> default. Ranges for the sliders alongside. `enemy_pace` is the
## speed of the enemy turn's replay in the skirmish: its top is the old instant replay
## (Ryan, 23 September: that should be the fastest the slider goes).
const DISPLAY_DEFAULTS := {
	"brightness": 1.0, "glitch": true, "pace": 1.0, "enemy_pace": 1.0, "scan": true,
	"music": 1.0, "effects": 1.0, "voice": 1.0,   # Hold The Line at the full knob matches other games on the phone (Ryan, 8 October); the effects and the voice mastered up to sit over it
	"voice_test": false,   # a debug build's test mode: every one of Jenny's hooks speaks every time
	"weld": true,   # a debug build's comparison: off, the machines' parts are drawn as authored rather than welded (MechWeld), to judge the battery plan on the phone
	"traces": true,   # a debug build's comparison: off, the map draws none of its traces (the creases on the machines, the props and the gate), to judge the grain at zoom 1 on the phone
	"keyword_ink": false,   # a debug build's comparison: on, a term in shown text is bold in ink with its icon in its colour, against the word in its colour (EntryReadout)
	"aa_mode": "msaa4",   # AA_MODES: the 3D's anti-aliasing (Hud.aa_mode)
	"skirmish_controls": "middle",   # SKIRMISH_CONTROLS: where the skirmish's log, dice and Reroll sit
}
const DISPLAY_RANGES := {
	"brightness": Vector2(0.5, 1.5), "pace": Vector2(0.5, 2.0), "enemy_pace": Vector2(0.5, 3.75),
	"music": Vector2(0.0, 1.0), "effects": Vector2(0.0, 1.0), "voice": Vector2(0.0, 1.0),
}
static var display: Dictionary = DISPLAY_DEFAULTS.duplicate()
## Where the skirmish's controls sit (Ryan, 29 October: "Skirmish Controls", "bottom" or
## "middle"): the log, dice and Reroll between the foes and the machines, or under the machines
## with the two sides facing each other above them (SkirmishScreen.controls reads it).
const SKIRMISH_CONTROLS := ["middle", "bottom"]
## The 3D's anti-aliasing (Ryan, 30 October: "Can we add an AA mode setting, not just for
## debug?"): none, the battle map's FXAA (its compositor's own, so a skirmish draws as with none),
## or MSAA at 2x or 4x (Hud.aa_mode). The machines' textures read their mipmaps in every mode.
const AA_MODES := ["off", "fxaa", "msaa2", "msaa4"]
const AA_LABELS := {"off": "OFF", "fxaa": "FXAA", "msaa2": "MSAA 2X", "msaa4": "MSAA 4X"}


## Load once and push the choices into the palette. Safe to call repeatedly.
static func apply() -> void:
	if not _loaded:
		_loaded = true
		var cf := ConfigFile.new()
		if cf.load(PATH) == OK:
			var h := str(cf.get_value("hud", "colour", DEFAULT_HUD))
			if HUD_OPTIONS.has(h):
				hud = h
			for key in DISPLAY_DEFAULTS.keys():
				display[key] = cf.get_value("display", key, DISPLAY_DEFAULTS[key])
		ColourTuner.load_saved(cf)   # a debug build's colour picks (the pause menu's COLOURS page)
	# RIFTGATE_HUD=<green|amber|blue> forces the colour for a run without touching the saved
	# choice: the screenshot tool, to judge a mark against every HUD option.
	var forced := OS.get_environment("RIFTGATE_HUD")
	if HUD_OPTIONS.has(forced):
		hud = forced
	Palette.HUD = HUD_OPTIONS.get(hud, HUD_OPTIONS[DEFAULT_HUD])


static func set_hud(id: String) -> void:
	if not HUD_OPTIONS.has(id):
		return
	hud = id
	_loaded = true
	Palette.HUD = HUD_OPTIONS[id]
	var cf := ConfigFile.new()
	cf.load(PATH)
	cf.set_value("hud", "colour", id)
	cf.save(PATH)


static func set_display(key: String, value: Variant) -> void:
	if not DISPLAY_DEFAULTS.has(key):
		return
	display[key] = value
	_loaded = true
	var cf := ConfigFile.new()
	cf.load(PATH)
	cf.set_value("display", key, value)
	cf.save(PATH)


## Forget the saved knobs (tests).
static func reset_display() -> void:
	display = DISPLAY_DEFAULTS.duplicate()
	var cf := ConfigFile.new()
	cf.load(PATH)
	if cf.has_section("display"):
		cf.erase_section("display")
	cf.save(PATH)

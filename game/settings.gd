class_name Settings
extends RefCounted

## Player settings, saved to user://settings.cfg: the HUD colour and the display knobs
## (22 September: the map tuner's useful knobs, made the player's).

const PATH := "user://settings.cfg"

## HUD colour choices, in the order a picker shows them.
# Chrome only: the semantic colours in Palette never change with this. Red is not offered,
# since red is the enemy colour.
const HUD_OPTIONS := {
	"green": Color("33ff55"),
	"amber": Color("fff21a"),
	"blue": Color("5cd8ff"),
}
const DEFAULT_HUD := "green"

static var hud: String = DEFAULT_HUD
static var _loaded := false

## The display knobs: key -> default. Ranges for the sliders alongside.
const DISPLAY_DEFAULTS := {
	"brightness": 1.0, "glitch": true, "pace": 1.0, "scan": true,
}
const DISPLAY_RANGES := {
	"brightness": Vector2(0.5, 1.5), "pace": Vector2(0.5, 2.0),
}
static var display: Dictionary = DISPLAY_DEFAULTS.duplicate()


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

class_name Settings
extends RefCounted

## Player settings, saved to user://settings.cfg. Only the HUD colour so far.

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


## Load once and push the choices into the palette. Safe to call repeatedly.
static func apply() -> void:
	if not _loaded:
		_loaded = true
		var cf := ConfigFile.new()
		if cf.load(PATH) == OK:
			var h := str(cf.get_value("hud", "colour", DEFAULT_HUD))
			if HUD_OPTIONS.has(h):
				hud = h
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

class_name ColourTuner
extends RefCounted

## A debug build's colour tuner (Ryan, 30 October: "put in a whole colour wheel or hex entry, as
## I want to try out a lot of things"): the colours that carry a meaning, and the HUD's presets,
## set from the pause menu's COLOURS page and kept in user://settings.cfg, so a pick survives a
## restart and can be judged on the phone. Only what is still in play (Ryan, the same evening:
## "Make sure the colours tab is simplified to only what we need"): the enemy's four violets, the
## meanings and the presets; white, the neutrals and the plaque's look are settled and out of
## it. Only a debug build with a screen reads the saved picks; every other build, and every
## headless run (tests, tools), draws the scripts' defaults.

const SECTION := "colours"
const SETTINGS := "res://game/settings.gd"   # a HUD choice lives in Settings.HUD_OPTIONS
const PALETTE := "res://game/ui/palette.gd"
const MAP := "res://game/battle/battle_map_view.gd"

## [key, heading, script, variable, what it paints]: the page's rows, in order.
const SLOTS := [
	["hud_green", "HUD PRESETS", SETTINGS, "green", "The display colour GREEN: chrome, frames, the grid"],
	["hud_amber", "HUD PRESETS", SETTINGS, "amber", "The display colour AMBER"],
	["hud_blue", "HUD PRESETS", SETTINGS, "blue", "The display colour BLUE"],
	["ENEMY", "THE ENEMY'S VIOLET", PALETTE, "ENEMY", "Everything a foe does: intents, chips, plaques, arrows, rings, bands, routes, the rift's bars and tears"],
	["ENEMY_HOT", "THE ENEMY'S VIOLET", MAP, "ENEMY_HOT", "What the map's violet marks breathe toward; brackets, warnings, the tapped route's pulse"],
	["ENEMY_DEEP", "THE ENEMY'S VIOLET", MAP, "ENEMY_DEEP", "The intent field's dark stripes and a route's crawling gaps"],
	["ENEMY_EDGE", "THE ENEMY'S VIOLET", MAP, "ENEMY_EDGE", "The dark line under the map's violet rings, bands and tags"],
	["HEAT", "MEANINGS", PALETTE, "HEAT", "Heat and what hits harder: its chips, the gauge, a die's heat, a passive's name; on the map a fight to engage"],
	["LOSS", "MEANINGS", PALETTE, "LOSS", "Harm to a unit: a number moved against it, a kill or wreck forecast, DRY, SHORT, NO ROOM"],
	["LOSS_DIM", "MEANINGS", PALETTE, "LOSS_DIM", "A blank or destroyed entry, a wrecked machine's die, a dying foe's ghost"],
	["SHIELD", "MEANINGS", PALETTE, "SHIELD", "Shield: its gauge and chips"],
	["HULL", "MEANINGS", PALETTE, "HULL", "Hull: its gauge, a hull cost"],
	["GAIN", "MEANINGS", PALETTE, "GAIN", "A number moved in its unit's favour"],
]

static var _defaults := {}    # key -> Color, as the scripts declare them
static var _picks := {}       # key -> Color, the tuner's settings


## Whether this run keeps picks: a debug build with a screen.
static func enabled() -> bool:
	return OS.is_debug_build() and DisplayServer.get_name() != "headless"


static func slot(key: String) -> Array:
	for s in SLOTS:
		if s[0] == key:
			return s
	return []


## The value each slot's script declares, read once before any pick lands.
static func defaults() -> Dictionary:
	if _defaults.is_empty():
		for s in SLOTS:
			_defaults[s[0]] = _read(s)
	return _defaults


static func value(key: String) -> Color:
	var s := slot(key)
	return _read(s) if not s.is_empty() else Color.MAGENTA


static func is_set(key: String) -> bool:
	return _picks.has(key)


static func picks() -> Dictionary:
	return _picks.duplicate()


## The saved picks into the scripts (Settings.apply, once a run).
static func load_saved(cf: ConfigFile) -> void:
	defaults()
	_picks.clear()
	if enabled() and cf.has_section(SECTION):
		for key in cf.get_section_keys(SECTION):
			var hex := str(cf.get_value(SECTION, key, ""))
			if not slot(key).is_empty() and Color.html_is_valid(hex):
				_picks[key] = Color.html(hex)
	apply()


## Every slot to its pick, else to its default; then the HUD colour from its (perhaps picked)
## choice.
static func apply() -> void:
	var base := defaults()
	for s in SLOTS:
		var key: String = s[0]
		_write(s, _picks[key] if _picks.has(key) else base[key])
	Palette.HUD = Settings.HUD_OPTIONS.get(Settings.hud, Settings.HUD_OPTIONS[Settings.DEFAULT_HUD])


static func set_colour(key: String, c: Color, save := true) -> void:
	if slot(key).is_empty():
		return
	defaults()
	_picks[key] = Color(c, 1.0)
	apply()
	if save:
		_save()


static func reset(key: String, save := true) -> void:
	_picks.erase(key)
	apply()
	if save:
		_save()


static func reset_all(save := true) -> void:
	_picks.clear()
	apply()
	if save:
		_save()


## The picks as text to paste into a message: one line a slot, its key and its hex.
static func export_text() -> String:
	var lines := PackedStringArray()
	for s in SLOTS:
		if _picks.has(s[0]):
			lines.append("%s #%s" % [s[0], (_picks[s[0]] as Color).to_html(false)])
	return "\n".join(lines) if not lines.is_empty() else "No colours changed."


static func _read(s: Array) -> Color:
	if s[2] == SETTINGS:
		return Settings.HUD_OPTIONS.get(s[3], Color.MAGENTA)
	var v: Variant = (load(s[2]) as Script).get(s[3])
	return v if v is Color else Color.MAGENTA


static func _write(s: Array, c: Color) -> void:
	if s[2] == SETTINGS:
		Settings.HUD_OPTIONS[s[3]] = c
	else:
		(load(s[2]) as Script).set(s[3], c)


static func _save() -> void:
	if not enabled():
		return
	var cf := ConfigFile.new()
	cf.load(Settings.PATH)
	if cf.has_section(SECTION):
		cf.erase_section(SECTION)
	for key in _picks.keys():
		cf.set_value(SECTION, key, (_picks[key] as Color).to_html(false))
	cf.save(Settings.PATH)

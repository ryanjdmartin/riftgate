class_name ColourTuner
extends RefCounted

## A debug build's colour tuner (Ryan, 30 October: "put in a whole colour wheel or hex entry, as
## I want to try out a lot of things. Might as well put in switches for everything ... That
## includes the HUD colour choices, too"): every named colour the screens draw with, set from
## the pause menu's COLOURS page and kept in user://settings.cfg, so a pick survives a restart
## and can be judged on the phone. Only a debug build with a screen reads the saved picks;
## every other build, and every headless run (tests, tools), draws the scripts' defaults.
##
## A slot that follows another (the violet on the ground follows ENEMY, the accent HEAT) takes
## the other's value until it is set itself, so "change the violet entirely" is one pick and
## parting the arrows from the chips is a second.

const SECTION := "colours"
const SETTINGS := "res://game/settings.gd"   # a HUD choice lives in Settings.HUD_OPTIONS

## [key, heading, script, variable, follows, what it paints]: the page's rows, in order. A slot
## that follows another comes after it.
const SLOTS := [
	["hud_green", "HUD CHOICES", SETTINGS, "green", "", "The display colour GREEN: chrome, frames, the grid"],
	["hud_amber", "HUD CHOICES", SETTINGS, "amber", "", "The display colour AMBER"],
	["hud_blue", "HUD CHOICES", SETTINGS, "blue", "", "The display colour BLUE"],
	["ENEMY", "ENEMY", "res://game/ui/palette.gd", "ENEMY", "", "The enemy's violet on plates: intent chips, labels, readouts, plaques"],
	["ENEMY_ARROW", "ENEMY", "res://game/ui/palette.gd", "ENEMY_ARROW", "ENEMY", "The skirmish's intent arrows, straight on the field"],
	["ENEMY_MAP", "ENEMY", "res://game/ui/palette.gd", "ENEMY_MAP", "ENEMY", "The map's violet on the ground: rings, bands, outlines, the warning zones"],
	["ENEMY_HOT", "ENEMY", "res://game/battle/battle_map_view.gd", "ENEMY_HOT", "", "What the map's violet marks pulse toward; brackets, warnings"],
	["ENEMY_EDGE", "ENEMY", "res://game/battle/battle_map_view.gd", "ENEMY_EDGE", "", "The dark line under the map's violet rings and band edges"],
	["HEAT", "SEMANTIC", "res://game/ui/palette.gd", "HEAT", "", "Heat: its chips, the gauge, a die's heat, the mine"],
	["ACCENT", "SEMANTIC", "res://game/ui/palette.gd", "ACCENT", "HEAT", "The codex's passive accent"],
	["ACCENT_INK", "SEMANTIC", "res://game/ui/palette.gd", "ACCENT_INK", "", "Text on the accent"],
	["SHIELD", "SEMANTIC", "res://game/ui/palette.gd", "SHIELD", "", "Shield: its gauge and chips"],
	["HULL", "SEMANTIC", "res://game/ui/palette.gd", "HULL", "", "Hull: its gauge"],
	["GAIN", "SEMANTIC", "res://game/ui/palette.gd", "GAIN", "", "A number moved in its unit's favour"],
	["LOSS", "SEMANTIC", "res://game/ui/palette.gd", "LOSS", "", "Harm to a unit: a number moved against it, a kill or wreck forecast, DRY, SHORT, NO ROOM"],
	["LOSS_DIM", "SEMANTIC", "res://game/ui/palette.gd", "LOSS_DIM", "", "A blank or destroyed entry, a wrecked machine's die, a dying foe's ghost"],
	["SELECT", "SEMANTIC", "res://game/ui/palette.gd", "SELECT", "", "Selection"],
	["TARGET", "SEMANTIC", "res://game/ui/palette.gd", "TARGET", "", "A target"],
	["OK", "SEMANTIC", "res://game/ui/palette.gd", "OK", "", "Good"],
	["INK", "TEXT AND PANELS", "res://game/ui/palette.gd", "INK", "", "Text"],
	["MUTED", "TEXT AND PANELS", "res://game/ui/palette.gd", "MUTED", "", "Quiet text"],
	["BG", "TEXT AND PANELS", "res://game/ui/palette.gd", "BG", "", "The ground under the HUD"],
	["PANEL", "TEXT AND PANELS", "res://game/ui/palette.gd", "PANEL", "", "Panels and chips' plates"],
	["PANEL_RAISED", "TEXT AND PANELS", "res://game/ui/palette.gd", "PANEL_RAISED", "", "Raised panels"],
	["RULE", "TEXT AND PANELS", "res://game/ui/palette.gd", "RULE", "", "Rules and dividers"],
	["INTENT", "THE RIFT'S INTENT", "res://game/battle/battle_map_view.gd", "INTENT", "", "A pack's route at rest"],
	["INTENT_HOT", "THE RIFT'S INTENT", "res://game/battle/battle_map_view.gd", "INTENT_HOT", "", "The intent field's bright"],
	["INTENT_DEEP", "THE RIFT'S INTENT", "res://game/battle/battle_map_view.gd", "INTENT_DEEP", "", "The field's dark and the line's gaps"],
	["INTENT_PALE", "THE RIFT'S INTENT", "res://game/battle/battle_map_view.gd", "INTENT_PALE", "", "The top of the tapped pack's pulse"],
	["INTENT_DARK", "THE RIFT'S INTENT", "res://game/battle/battle_map_view.gd", "INTENT_DARK", "", "The bottom of the tapped pack's pulse, dark"],
	["INTENT_DIM", "THE RIFT'S INTENT", "res://game/battle/battle_map_view.gd", "INTENT_DIM", "", "The bottom of the tapped pack's pulse, light"],
	["INTENT_EDGE", "THE RIFT'S INTENT", "res://game/battle/battle_map_view.gd", "INTENT_EDGE", "", "The intent's edge (RIFTGATE_INTENT_EDGE=1)"],
	["RIFT_ART", "THE RIFT'S INTENT", "res://game/battle/battle_map_view.gd", "RIFT_ART", "", "How the rift itself looks"],
	["PLAQUE_WHITE", "THE FOES' PLAQUE", "res://game/ui/plaque.gd", "WHITE", "", "A named move's letters"],
	["PLAQUE_DARK", "THE FOES' PLAQUE", "res://game/ui/plaque.gd", "DARK", "", "The window's frame"],
	["PLAQUE_BLUE_TOP", "THE FOES' PLAQUE", "res://game/ui/plaque.gd", "BLUE_TOP", "", "The window's blue, top"],
	["PLAQUE_BLUE_BOTTOM", "THE FOES' PLAQUE", "res://game/ui/plaque.gd", "BLUE_BOTTOM", "", "The window's blue, bottom"],
	["PLAQUE_SHADOW", "THE FOES' PLAQUE", "res://game/ui/plaque.gd", "SHADOW", "", "The letters' shadow"],
	["OTHER_GRID", "THE MAP", "res://game/ui/terrain_art.gd", "OTHER_GRID", "", "The other world's hex lines on the map"],
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


## Every slot to its pick, else to the slot it follows, else to its default; then the HUD
## colour from its (perhaps picked) choice.
static func apply() -> void:
	var base := defaults()
	for s in SLOTS:
		var key: String = s[0]
		if _picks.has(key):
			_write(s, _picks[key])
		elif s[4] != "":
			_write(s, value(str(s[4])))
		else:
			_write(s, base[key])
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

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
	"aa_mode": "msaa4",   # AA_MODES: the 3D's anti-aliasing (Hud.aa_mode)
	"skirmish_controls": "middle",   # SKIRMISH_CONTROLS: where the skirmish's log, dice and Reroll sit
	"map_view": "wall_left",   # MAP_VIEWS: the battle map's orientation (MapOrient), a view only
	"field_depth": "12",   # FIELD_DEPTHS: a debug build's trial of the field's depth in rows (Ramp.depth_trial), read as a battle starts
	"wall_strike": "10",   # STRIKES: a debug build's trial of what a pip of threat rating strikes the wall for (Battlefield.strike_trial), read as a battle starts
	"tide_form": "built",   # TIDE_FORMS: a debug build's trial of the graded tide, packs dealt by where they make for (Battlefield.graded_tide), read as a battle starts
	"mouth_sends": "1",   # SENDS: a debug build's trial of the packs every mouth sends at a peak (Battlefield.sends_trial), read as a battle starts
	"pack_bonus": "0",   # PACK_BONUSES: a debug build's trial of what a pack pays the Rupture meter as it falls, on top of its rating, in hundredths of a pip (Battle.pack_bonus_trial), read as a battle starts
	"chip_style": "corner",   # UnitView.CHIP_STYLES: a debug build's comparison of how a status chip carries its number, read as the field draws
	"aim_tether": "edge",   # AimLayer.TETHERS: a debug build's comparison of the aim's tether, from the die's edge or over it from its middle
	"phased_form": "round_end",   # PHASED_FORMS: a debug build's trial of when a machine's Phased lands, as the round ends or as its entry is spent (Skirmish.phase_at_once), read as a battle starts
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
## The battle map's orientation (the long wall brief 7.1; Ryan, 6 November: "a purely visual
## option between wall left + gate right and wall bottom + gate top"): the wall at the left with
## the rift at the right, or at the bottom with the rift at the top; the default the left (a
## placeholder: his call, judged on the phone). MapOrient reads it; RIFTGATE_MAP_VIEW=left|bottom
## forces one for a run.
const MAP_VIEWS := ["wall_left", "wall_bottom"]
const MAP_VIEW_LABELS := {"wall_left": "WALL LEFT", "wall_bottom": "WALL BOTTOM"}
## Five dials left this page on 23 November with their questions, each as built (Ryan: "We can
## lock in the rank and file setting as 4, heat as built, top basic as built, and overheat at x1.
## That all felt fine enough as a starting point"; and "barrier basic yes, for now at least"): the
## vanilla 3 for 4 heat against a standard foe of 4, the Laser Carbine 4 for 5, a point of heat
## past the maximum burning a point of hull, the Barrier basic on the starting dice. The runners
## still lay each as a what-if (sim/refit.gd's --refit; RIFTGATE_OVERHEAT).
## When a machine's Phased lands, a debug build's trial (Ryan, 20 November: "Set the debug toggle
## for phased"; the reactive form, docs/domain_statuses_proposal.md, section 5): as the round ends,
## standing through the next, the game's; or at once as its entry is spent, standing until the
## round ends, the foes whose pick it was picking again (Skirmish.phase_at_once).
const PHASED_FORMS := ["round_end", "at_once"]
const PHASED_FORM_LABELS := {"round_end": "ROUND END", "at_once": "AT ONCE"}
## The trials' page, cut on 24 November to what is tried in person (Ryan: "clean up the trials
## tab. Remove anything no longer relevant. There's too many variables in there, we need to tone
## it down to just what is actually needed to try in person versus just chatting it out"). What
## stayed, each read as the next battle starts:
## - TIDE, the graded tide (his design of 23 November; Battlefield.graded_tide): packs rated one
##   to three dealt by where they make for, ones to the wall's ends, twos between, threes down
##   the middle.
## - SENDS, the packs every mouth sends at a peak, the rift and each tear alike ("If we enable
##   multiple simultaneous spawns from all spawn points, it gives us a very useful tuning dial
##   for convergences. More so then the beat, I think"; Battlefield.sends_trial).
## - STRIKE, what a pip of threat rating strikes the wall for, ten the game's ("Reduce foe damage
##   to the wall so that quantity matters").
## - PACK BONUS, what a pack pays the Rupture meter as it falls, over its rating ("Maybe add a
##   flat fracture bonus to a pack on top of the per-foe weight"; Battle.pack_bonus_trial).
## - FIELD DEPTH, the field's rows, twelve the game's ("I think 12, 14, and 16 unit field depths
##   all have their merit").
## GRADED_SET lays the graded tide's first set in one press and TRIAL_KEYS are what AS BUILT
## sets back. What left the page with its engine: the tide's density, the rift's own count (the
## sends took both), the fodder's worth on the meter (at half the middle still won, his play of
## 23 November), a flat hex on every pack's move (the pace is a pack's own) and the tears open
## from the start ("I wouldn't clutter the map with a ton of tears"). What left the page and
## stays a runner's what-if, as the basics' did: the opening's distance (RIFTGATE_OPENING), the
## Rupture's beats (RIFTGATE_BEATS) and the leaders' step (RIFTGATE_LEADERS).
const TIDE_FORMS := ["built", "graded"]
const TIDE_FORM_LABELS := {"built": "BUILT", "graded": "GRADED"}
const SENDS := ["1", "2", "3"]
const STRIKES := ["10", "5", "3"]
const PACK_BONUSES := ["0", "50", "100"]
const PACK_BONUS_LABELS := {"0": "NONE", "50": "+½", "100": "+1"}
const FIELD_DEPTHS := ["12", "14", "16"]
const GRADED_SET := {"tide_form": "graded", "mouth_sends": "2", "wall_strike": "5", "pack_bonus": "50"}
const TRIAL_KEYS := ["tide_form", "mouth_sends", "wall_strike", "pack_bonus", "field_depth", "phased_form"]


## Set the field's trial for the battles that start after this: RIFTGATE_GRADED (1),
## RIFTGATE_SENDS, RIFTGATE_STRIKE, RIFTGATE_PACK_BONUS, RIFTGATE_FIELD_DEPTH, RIFTGATE_PHASED
## (round_end or at_once), and the runners' own RIFTGATE_OPENING, RIFTGATE_BEATS, RIFTGATE_LEADERS
## and RIFTGATE_OVERHEAT, on any run; else a debug build's settings (TRIAL_KEYS) when `saved` (the
## game's own entry points pass it; a scene run alone and the tests read the environment only, so
## no machine's saved settings move a test's field). Nothing set is the game's own field, meter,
## tide and overheat.
static func field_trial(saved: bool = false) -> void:
	var graded := OS.get_environment("RIFTGATE_GRADED")
	var sends := OS.get_environment("RIFTGATE_SENDS")
	var strike := OS.get_environment("RIFTGATE_STRIKE")
	var bonus := OS.get_environment("RIFTGATE_PACK_BONUS")
	var depth := OS.get_environment("RIFTGATE_FIELD_DEPTH")
	var phased := OS.get_environment("RIFTGATE_PHASED")
	var opening := OS.get_environment("RIFTGATE_OPENING")
	var beats := OS.get_environment("RIFTGATE_BEATS")
	var leaders := OS.get_environment("RIFTGATE_LEADERS")
	var burn := OS.get_environment("RIFTGATE_OVERHEAT")
	if saved and OS.is_debug_build():
		if graded.is_empty() and str(display.get("tide_form", "")) == "graded":
			graded = "1"
		if sends.is_empty() and SENDS.has(str(display.get("mouth_sends", ""))):
			sends = str(display["mouth_sends"])
		if strike.is_empty() and STRIKES.has(str(display.get("wall_strike", ""))):
			strike = str(display["wall_strike"])
		if bonus.is_empty() and PACK_BONUSES.has(str(display.get("pack_bonus", ""))):
			bonus = str(display["pack_bonus"])
		if depth.is_empty() and FIELD_DEPTHS.has(str(display.get("field_depth", ""))):
			depth = str(display["field_depth"])
		if phased.is_empty() and PHASED_FORMS.has(str(display.get("phased_form", ""))):
			phased = str(display["phased_form"])
	Battlefield.graded_tide = graded == "1"
	Battlefield.sends_trial = clampi(int(sends), 1, 4) if sends.is_valid_int() else 1
	var pip := clampi(int(strike), 1, 20) if strike.is_valid_int() else 0
	Battlefield.strike_trial = 0 if pip == Battlefield.STRIKE_PER_PIP else pip
	Battle.pack_bonus_trial = clampi(int(bonus), 0, 400) if bonus.is_valid_int() else 0
	Ramp.depth_trial = clampi(int(depth), 10, 24) if depth.is_valid_int() else 0
	Skirmish.phase_at_once = phased == "at_once"
	Battle.opening_trial = clampi(int(opening), 0, 3) if opening.is_valid_int() else 0
	Ramp.beats_trial = clampi(int(beats), 1, 6) if beats.is_valid_int() else 0
	ContentDB.leader_step_trial = clampi(int(leaders), 0, 100) if leaders.is_valid_int() else 0
	Skirmish.overheat_scale = clampi(int(burn), 1, 10) if burn.is_valid_int() else 1


static var _env := {}

## A look a debug build compares (the chips, the aim's tether): its environment variable when set
## to one of `options`, else the setting `key`, else the first option.
static func look(env: String, key: String, options: Array) -> String:
	if not _env.has(env):
		_env[env] = OS.get_environment(env)
	if options.has(_env[env]):
		return str(_env[env])
	var st := str(display.get(key, options[0]))
	return st if options.has(st) else str(options[0])


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


## Set several of a debug build's dials at once and keep them (the trials' page's sets).
static func set_displays(values: Dictionary) -> void:
	for key in values.keys():
		set_display(str(key), values[key])


## Forget the saved knobs (tests).
static func reset_display() -> void:
	display = DISPLAY_DEFAULTS.duplicate()
	var cf := ConfigFile.new()
	cf.load(PATH)
	if cf.has_section("display"):
		cf.erase_section("display")
	cf.save(PATH)

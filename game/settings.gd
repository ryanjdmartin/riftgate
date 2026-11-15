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
	"shield_regen": "built",   # SHIELD_REGENS: a debug build's what-if, a flat shield regen on every chassis in place of each one's own (Refit), read at the next launch (docs/briefs/refit_pass.md)
	"field_depth": "12",   # FIELD_DEPTHS: a debug build's trial of the field's depth in rows (Ramp.depth_trial), read as a battle starts
	"field_opening": "0",   # FIELD_OPENINGS: a debug build's trial of how many moves farther from the wall the opening's packs stand (Battle.opening_trial), read as a battle starts
	"fodder_worth": "100",   # FODDER_WORTHS: a debug build's trial of what a rank-and-file kill fills of the Rupture meter, in hundredths (Battle.fodder_trial), read as a battle starts
	"rupture_beats": "2",   # RUPTURE_BEATS: a debug build's trial of the Rupture meter's size in beats of the tide (Ramp.beats_trial), read as a battle starts
	"tide_density": "100",   # TIDES: a debug build's trial of how many packs the opening places and the tide sends, in hundredths of the game's (Ramp.tide_trial), read as a battle starts
	"wall_strike": "10",   # STRIKES: a debug build's trial of what a pip of threat rating strikes the wall for (Battlefield.strike_trial), read as a battle starts
	"heat_trial": "0",   # HEATS: a debug build's what-if, every weapon a point or two cooler than content prices it, or a point hotter (HEAT_SPECS, Refit's hotter and cooling), read at the next launch
	"basic_guns": "0",   # BASIC_GUNS: a debug build's what-if, every basic gun dealing a point more than content gives it (Refit's basics), read at the next launch
	"top_basic_heat": "0",   # TOP_BASIC_HEATS: a debug build's what-if, more heat on the basic guns that deal more than the plainest (Refit's top), read at the next launch
	"rank_hp": "0",   # RANK_HPS: a debug build's what-if, a hit point more on tier one's rank and file (Refit's foehp), read at the next launch
	"foe_breach": "built",   # FOE_BREACHES: a debug build's what-if, every foe's breach cut so its blow meets the shield and the armour (Refit's breach=cut), read at the next launch
	"overheat_burn": "1",   # OVERHEATS: a debug build's trial of the hull an overheat burns a point of excess (Skirmish.overheat_scale), read as a battle starts
	"barrier_basic": "built",   # BARRIER_BASICS: a debug build's what-if, the Barrier basic off the stock dice with the Armoured basic in its slot (Refit's barrier=none), read at the next launch
	"shield_break": "off",   # SHIELD_BREAKS: a debug build's trial of the block, the blow that breaks a shield stopped whole (Skirmish.shield_break), read as a battle starts
	"reboot": "off",   # REBOOTS: a debug build's trial of the reboot, no regen or cooling of a chassis's own and a turn given for both gauges back (Skirmish.reboot), read as a battle starts
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
## The shield's regen as a what-if, a debug build's: as built, each chassis its own number
## (content's `shield_regen`, 1 to 3 since the refit pass landed on 10 November: "a smaller shield
## that regens fast, a fatter shield that regens slow, some variation of the middle"), or a flat
## number on every chassis in its place (his reads of the trial: at half the gauge "a nigh
## unkillable team", at two "I feel like even with zero regen I would be fine"). Read as the game
## starts (Harness.refit_trial), so at the next launch.
const SHIELD_REGENS := ["built", "0", "1", "2", "3"]
const SHIELD_REGEN_LABELS := {"built": "BUILT", "0": "0", "1": "1", "2": "2", "3": "3"}
## Heat's two dials, a debug build's (Ryan, 10 November: "Heat generation is too low"; 9 November:
## "run hot, and you're forced to wait and think about your decisions while you cool off"). The
## prices are content since 12 November, on his word for the anchor ("real tier 1 numbers for
## damage, defense and heat"): every weapon three hotter than it was and every chassis that
## cools cooling one more, the shape the fight bot's reads chose (docs/measurements.md, 12
## November: a formation fight brings a machine to its limit about once, in fights no longer).
## HEAT moves every weapon against that: one or two off on the same cooling, or a point more
## with one more cooling (it bites the same and sustains a little better). The same what-if the
## runners read (Refit's hotter and cooling), so read at the next launch.
## OVERHEAT is the hull a point of excess burns as the turn ends, one the game's: the bot
## overheats rather than holds at one and holds more at two, in longer fights, so what a hold
## is worth is his play's to find.
## Two cooler since 14 November: under the reboot nothing cools, and the prices of 12 November
## were sized against a cooling of two, so two off every weapon is the pace those prices meant
## (Ryan's play of the reboot: "I just know I overheated a lot").
const HEATS := ["-2", "-1", "0", "1"]
const HEAT_LABELS := {"-2": "−2", "-1": "−1", "0": "BUILT", "1": "+1"}
const HEAT_SPECS := {"-2": "hotter=-2", "-1": "hotter=-1", "1": "hotter=1,cooling=1"}
## The basics' own numbers, a debug build's what-ifs (Ryan, 14 November: "A 'standard' vanilla
## shot should be 1 less than our 'standard' fodder health"; the gun that deals one more "needs
## to bite appropriately", and "for basics, the only cost we should have is Heat"; the refit
## brief's section 23): BASIC GUNS a point of damage on every basic gun, which makes the plain
## ones 3 against a goblin's 4 and the hottest basic the gun that deals one more; TOP BASIC more
## heat on the basic guns that deal more than the plainest, that gun's price. The same what-if
## the runners read (Refit's basics and top), so read at the next launch.
const BASIC_GUNS := ["0", "1"]
const BASIC_GUN_LABELS := {"0": "BUILT", "1": "+1"}
const TOP_BASIC_HEATS := ["0", "2", "4"]
const TOP_BASIC_HEAT_LABELS := {"0": "BUILT", "2": "+2", "4": "+4"}
## The standard foe's hit points, a debug build's what-if beside BASIC GUNS (Ryan, 15 November:
## "Ok let's go 3 against 5 or 3 against 4 as the options"): a hit point more on every foe a
## tier-one formation fields that is no massive, so a vanilla of 3 meets a standard foe of 4 as
## built and of 5 with it. The same what-if the runners read (Refit's foehp), so read at the
## next launch.
const RANK_HPS := ["0", "1"]
const RANK_HP_LABELS := {"0": "BUILT", "1": "+1"}
## The foes' breach, a debug build's what-if (Ryan, 15 November, on whether the foes need it at
## all: "Sure, let's cut breach"): as built, a breaching blow passing the shield and the armour;
## or cut, every such blow a plain one that meets both. It plays the cut ahead of the reboot's
## fold-in, where the word leaves the engine and content. The same what-if the runners read
## (Refit's breach=cut), so read at the next launch.
const FOE_BREACHES := ["built", "cut"]
const FOE_BREACH_LABELS := {"built": "BUILT", "cut": "CUT"}
const OVERHEATS := ["1", "2", "3"]
const OVERHEAT_LABELS := {"1": "×1", "2": "×2", "3": "×3"}
## The block's trial, a debug build's (Ryan, 13 November: "What if we bring back that when a
## shield breaks, it absorbs the whole blow? It does not bleed into the hull"): as built, the
## honest shield, its number and the rest of the blow on the hull; or the blow that breaks a
## shield stopped whole (Skirmish.shield_break). Its other half that day, the broken shield
## resting some rounds before its regen started again, left with the reboot below. The fight
## bot's reads are docs/measurements.md, 13 November; nothing is decided.
const SHIELD_BREAKS := ["off", "on"]
const SHIELD_BREAK_LABELS := {"off": "BUILT", "on": "BLOCK"}
## The reboot's trial, a debug build's (Ryan, 13 November, his rules and rulings of that day;
## docs/briefs/refit_pass.md, section 22): as built; or no shield regen and no cooling of a
## chassis's own, a REBOOT a machine that has spent nothing may give its turn to (its shield
## down at once, both gauges back as the next round opens), heat past the maximum staying and
## burning hull every turn, the first overheat breaking the shield, and a broken shield gaining
## none until its machine reboots (Skirmish.reboot). OVERHEAT above prices a point of the burn.
const REBOOTS := ["off", "on"]
const REBOOT_LABELS := {"off": "BUILT", "on": "ON"}
## The Barrier basic's place as a what-if, a debug build's (Ryan, 12 November: "Is it toxic? ...
## Should it be rare or locked? An argument could be made that a chassis with barrier is a sub
## for a Tank on a team, and thus it's not widely available"): as built, on the stock dice where a
## shield for anyone once stood, or none, the Armoured basic in its slot on every stock die
## (Refit's barrier=none; the piece itself is untouched). The breaking shield is read beside it:
## the two together cost a squad half of what either does alone (docs/measurements.md, 13
## November). Read as the game starts (Harness.refit_trial), so at the next launch.
const BARRIER_BASICS := ["built", "none"]
const BARRIER_BASIC_LABELS := {"built": "BUILT", "none": "NONE"}
## The field's trial, a debug build's (Ryan, 10 November, after his play of the long wall: "I think
## the map is a bit too shallow ... If the map is a little deeper, and the seam starts a little
## farther out, it will feel more like I can actually plan a little bit ahead instead of panicking
## from the very start"): the field's depth in rows, twelve the game's, and how many moves farther
## from the wall the opening's packs stand, none the game's. The two go together: the opening is
## measured from the wall, so depth alone leaves a formation's first walk on the wall, and the
## rows a deeper field adds are what the opening has to stand farther out on.
const FIELD_DEPTHS := ["12", "14", "16"]
const FIELD_OPENINGS := ["0", "1", "2"]
const FIELD_OPENING_LABELS := {"0": "+0", "1": "+1", "2": "+2"}
## The fodder's trial beside them (the same play: "If fracture rewards were a little lower for
## fodder, then it becomes a bit more of a quantity game for non-elites and I'll feel more like
## sending my flankers out"): what a kill fills of the Rupture meter when its pack came as no
## elite, in hundredths, the whole the game's; an elite's fall fills its chunk whatever the dial.
## As the meter was first built the middle formation alone earned the first Fracture and three
## fights the Rupture; sized in beats since, the flank's patrols are part of it
## (docs/measurements.md, 10 and 11 November).
const FODDER_WORTHS := ["100", "75", "50"]
const FODDER_WORTH_LABELS := {"100": "FULL", "75": "3/4", "50": "HALF"}
## The meter's size beside it, in beats of the tide (Ryan, 11 November: "the 3 fractures, with
## the current rate of fill, felt short to me", then "Try your lean first" of two beats): how many
## peaks of Rift Pressure the Rupture's field part runs through, two the game's (Ramp.BEATS). One
## beat is the opening and the first wave; three brings the second composition and the first
## hunting packs, the runner's player's tenth turn (docs/measurements.md, 11 November). The two
## dials lengthen a battle from two sides: this one leaves a kill's worth alone.
const RUPTURE_BEATS := ["1", "2", "3"]
const RUPTURE_BEATS_LABELS := {"1": "1 BEAT", "2": "2 BEATS", "3": "3 BEATS"}
## The tide's density and the wall strike beside them (Ryan, 11 November: "I think we should try
## to lean for noticeably more spawns then the minimum number required for our target completion
## speed. When I was playing I felt the need to chase every pack down, since that felt possible.
## I think that's wrong. More pusher and flanker packs, even if it means that each needs to do
## less to the wall, is better"): how many packs the opening places and each wave sends against
## the game's own, half again or twice (whole packs: Ramp.dense, Ramp.dense_at), with the
## Rupture's size left on the game's own tide, so the extras are a choice and never more to
## kill; and what a pip of threat rating strikes the wall for, ten the game's. The bot's reads
## are docs/measurements.md, 11 November.
const TIDES := ["100", "150", "200"]
const TIDE_LABELS := {"100": "×1", "150": "×1.5", "200": "×2"}
const STRIKES := ["10", "7", "5", "3"]


## Set the field's trial for the battles that start after this: RIFTGATE_FIELD_DEPTH,
## RIFTGATE_OPENING, RIFTGATE_FODDER, RIFTGATE_BEATS, RIFTGATE_TIDE, RIFTGATE_STRIKE,
## RIFTGATE_OVERHEAT, RIFTGATE_SHIELD_BREAK (1, the block) and RIFTGATE_REBOOT (1, the reboot) on
## any run, else a debug build's nine settings when `saved` (the game's own
## entry points pass it; a scene run alone and the tests read the environment only, so no
## machine's saved settings move a test's field). Nothing set is the game's own field, meter,
## tide, overheat, shield and heat.
static func field_trial(saved: bool = false) -> void:
	var depth := OS.get_environment("RIFTGATE_FIELD_DEPTH")
	var opening := OS.get_environment("RIFTGATE_OPENING")
	var fodder := OS.get_environment("RIFTGATE_FODDER")
	var beats := OS.get_environment("RIFTGATE_BEATS")
	var tide := OS.get_environment("RIFTGATE_TIDE")
	var strike := OS.get_environment("RIFTGATE_STRIKE")
	var burn := OS.get_environment("RIFTGATE_OVERHEAT")
	var block := OS.get_environment("RIFTGATE_SHIELD_BREAK")
	var boot := OS.get_environment("RIFTGATE_REBOOT")
	if saved and OS.is_debug_build():
		if depth.is_empty() and FIELD_DEPTHS.has(str(display.get("field_depth", ""))):
			depth = str(display["field_depth"])
		if opening.is_empty() and FIELD_OPENINGS.has(str(display.get("field_opening", ""))):
			opening = str(display["field_opening"])
		if fodder.is_empty() and FODDER_WORTHS.has(str(display.get("fodder_worth", ""))):
			fodder = str(display["fodder_worth"])
		if beats.is_empty() and RUPTURE_BEATS.has(str(display.get("rupture_beats", ""))):
			beats = str(display["rupture_beats"])
		if tide.is_empty() and TIDES.has(str(display.get("tide_density", ""))):
			tide = str(display["tide_density"])
		if strike.is_empty() and STRIKES.has(str(display.get("wall_strike", ""))):
			strike = str(display["wall_strike"])
		if burn.is_empty() and OVERHEATS.has(str(display.get("overheat_burn", ""))):
			burn = str(display["overheat_burn"])
		if block.is_empty() and str(display.get("shield_break", "")) == "on":
			block = "1"
		if boot.is_empty() and str(display.get("reboot", "")) == "on":
			boot = "1"
	Ramp.depth_trial = clampi(int(depth), 10, 24) if depth.is_valid_int() else 0
	Battle.opening_trial = clampi(int(opening), 0, 3) if opening.is_valid_int() else 0
	Battle.fodder_trial = clampi(int(fodder), 10, 100) if fodder.is_valid_int() else 100
	Ramp.beats_trial = clampi(int(beats), 1, 6) if beats.is_valid_int() else 0
	Ramp.tide_trial = clampi(int(tide), 100, 400) if tide.is_valid_int() else 100
	var pip := clampi(int(strike), 1, 20) if strike.is_valid_int() else 0
	Battlefield.strike_trial = 0 if pip == Battlefield.STRIKE_PER_PIP else pip
	Skirmish.overheat_scale = clampi(int(burn), 1, 10) if burn.is_valid_int() else 1
	Skirmish.shield_break = block.is_valid_int() and int(block) > 0
	Skirmish.shield_break_min = 0
	Skirmish.reboot = boot.is_valid_int() and int(boot) > 0


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

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
	"field_opening": "0",   # FIELD_OPENINGS: a debug build's trial of how many moves farther from the wall the opening's packs stand (Battle.opening_trial), read as a battle starts
	"fodder_worth": "100",   # FODDER_WORTHS: a debug build's trial of what a rank-and-file kill fills of the Rupture meter, in hundredths (Battle.fodder_trial), read as a battle starts
	"rupture_beats": "2",   # RUPTURE_BEATS: a debug build's trial of the Rupture meter's size in beats of the tide (Ramp.beats_trial), read as a battle starts
	"tide_density": "100",   # TIDES: a debug build's trial of how many packs the opening places and the tide sends, in hundredths of the game's (Ramp.tide_trial), read as a battle starts
	"wall_strike": "10",   # STRIKES: a debug build's trial of what a pip of threat rating strikes the wall for (Battlefield.strike_trial), read as a battle starts
	"pack_pace": "0",   # PACES: a debug build's trial of hexes added to every pack's move (Battlefield.pace_trial), read as a battle starts
	"rift_sends": "1",   # RIFT_SENDS: a debug build's trial of the compositions the rift sends a peak, each leaving in its own direction (Battlefield.rift_sends_trial), read as a battle starts
	"flank_tears": "0",   # FLANK_TEARS: a debug build's trial of tears open at the wall's two ends from the first turn (Battlefield.flank_tears_trial), read as a battle starts
	"leader_step": "0",   # LEADER_STEPS: a debug build's trial of an elite's and a boss's hit points more for each Convergence past its tier's first, in hundredths (ContentDB.leader_step_trial), read as a battle starts
	"formation_form": "0",   # FORMATION_FORMS: a debug build's trial of every formation dealt as pickets rated one, two or three heads each (Battlefield.pickets_trial), read as a battle starts
	"chip_style": "corner",   # UnitView.CHIP_STYLES: a debug build's comparison of how a status chip carries its number, read as the field draws
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
## The dials of 23 November, from his play of the field's dials (each his words; the statics hold
## them): the packs' pace, a hex or two more on every pack's move ("I'd probably give everything +1
## right now and see what that does"); the rift sending two or three compositions a peak,
## each making for its own stretch of wall ("sending multiple packs out of the rift at once, each
## headed a different direction"); and two tears open at the wall's ends from the first turn
## ("Having starting tears at the top and bottom might make sense"). The last two leave the
## Rupture's size on the game's own tide, as TIDE does.
const PACES := ["0", "1", "2"]
const PACE_LABELS := {"0": "BUILT", "1": "+1", "2": "+2"}
const RIFT_SENDS := ["1", "2", "3"]
const RIFT_SENDS_LABELS := {"1": "×1", "2": "×2", "3": "×3"}
const FLANK_TEARS := ["0", "2"]
const FLANK_TEARS_LABELS := {"0": "NONE", "2": "TWO"}
## And the body as pickets, for a feel of his direction of the same day on today's units ("Fodder
## should pose a threat by quantity, not by hard hits"; Battlefield.pickets_trial): every formation
## as a pack rated one for each of its pips, each two or three of the domain's commonest
## front-liner.
## And the leaders by the Convergence (the same day: "if they don't scale with me they'll become a
## joke at C4"; ContentDB.leader_step_trial): an elite's and a boss's hit points a tenth or a
## fifth more for each battle into its tier, the fifth what a read of a squad carrying finds asks.
const LEADER_STEPS := ["0", "10", "20"]
const LEADER_STEP_LABELS := {"0": "BUILT", "10": "+10% A C", "20": "+20% A C"}
const FORMATION_FORMS := ["0", "2", "3"]
const FORMATION_FORM_LABELS := {"0": "BUILT", "2": "PICKETS ×2", "3": "PICKETS ×3"}


## Set the field's trial for the battles that start after this: RIFTGATE_FIELD_DEPTH,
## RIFTGATE_OPENING, RIFTGATE_FODDER, RIFTGATE_BEATS, RIFTGATE_TIDE, RIFTGATE_STRIKE,
## RIFTGATE_PACE, RIFTGATE_RIFT_SENDS, RIFTGATE_FLANK_TEARS,
## RIFTGATE_PICKETS, RIFTGATE_LEADERS, RIFTGATE_OVERHEAT and RIFTGATE_PHASED (round_end or
## at_once) on any run, else a debug build's fourteen settings when `saved` (the game's own
## entry points pass it; a scene run alone and the tests read the environment only, so no
## machine's saved settings move a test's field). Nothing set is the game's own field, meter,
## tide and overheat.
static func field_trial(saved: bool = false) -> void:
	var depth := OS.get_environment("RIFTGATE_FIELD_DEPTH")
	var opening := OS.get_environment("RIFTGATE_OPENING")
	var fodder := OS.get_environment("RIFTGATE_FODDER")
	var beats := OS.get_environment("RIFTGATE_BEATS")
	var tide := OS.get_environment("RIFTGATE_TIDE")
	var strike := OS.get_environment("RIFTGATE_STRIKE")
	var burn := OS.get_environment("RIFTGATE_OVERHEAT")
	var phased := OS.get_environment("RIFTGATE_PHASED")
	var pace := OS.get_environment("RIFTGATE_PACE")
	var sends := OS.get_environment("RIFTGATE_RIFT_SENDS")
	var flank := OS.get_environment("RIFTGATE_FLANK_TEARS")
	var pickets := OS.get_environment("RIFTGATE_PICKETS")
	var leaders := OS.get_environment("RIFTGATE_LEADERS")
	if saved and OS.is_debug_build():
		if leaders.is_empty() and LEADER_STEPS.has(str(display.get("leader_step", ""))):
			leaders = str(display["leader_step"])
		if pickets.is_empty() and FORMATION_FORMS.has(str(display.get("formation_form", ""))):
			pickets = str(display["formation_form"])
		if pace.is_empty() and PACES.has(str(display.get("pack_pace", ""))):
			pace = str(display["pack_pace"])
		if sends.is_empty() and RIFT_SENDS.has(str(display.get("rift_sends", ""))):
			sends = str(display["rift_sends"])
		if flank.is_empty() and FLANK_TEARS.has(str(display.get("flank_tears", ""))):
			flank = str(display["flank_tears"])
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
		if phased.is_empty() and PHASED_FORMS.has(str(display.get("phased_form", ""))):
			phased = str(display["phased_form"])
	Ramp.depth_trial = clampi(int(depth), 10, 24) if depth.is_valid_int() else 0
	Battle.opening_trial = clampi(int(opening), 0, 3) if opening.is_valid_int() else 0
	Battle.fodder_trial = clampi(int(fodder), 10, 100) if fodder.is_valid_int() else 100
	Ramp.beats_trial = clampi(int(beats), 1, 6) if beats.is_valid_int() else 0
	Ramp.tide_trial = clampi(int(tide), 100, 400) if tide.is_valid_int() else 100
	var pip := clampi(int(strike), 1, 20) if strike.is_valid_int() else 0
	Battlefield.strike_trial = 0 if pip == Battlefield.STRIKE_PER_PIP else pip
	Skirmish.overheat_scale = clampi(int(burn), 1, 10) if burn.is_valid_int() else 1
	Skirmish.phase_at_once = phased == "at_once"
	Battlefield.pace_trial = clampi(int(pace), 0, 4) if pace.is_valid_int() else 0
	Battlefield.rift_sends_trial = clampi(int(sends), 1, 4) if sends.is_valid_int() else 1
	Battlefield.flank_tears_trial = clampi(int(flank), 0, 6) if flank.is_valid_int() else 0
	Battlefield.pickets_trial = clampi(int(pickets), 0, 4) if pickets.is_valid_int() else 0
	ContentDB.leader_step_trial = clampi(int(leaders), 0, 100) if leaders.is_valid_int() else 0


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

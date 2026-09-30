class_name Sound
extends Node

## The game's sound. The direction (bible, 22 September): effects grounded and heavy,
## weight and machinery, never a space opera; music an industrial groove, driving but not
## fast. Every sound is a WAV under art/audio built by tools/soundforge from a written
## recipe, the way the models are built, and is asked for by name: `Sound.play("hit")`,
## `Sound.music("skirmish")`. Like `Settings`, a static face; the node behind it is made on
## first use and lives under the root. Headless there is no node and every call is a no-op,
## so the sim and the tests never touch audio.
##
## The mix lives in the forge: every file is written at its own level (a tap is quiet, the
## gate is not), so a hook passes a dB offset only when one moment is relatively louder or
## softer than the sound's usual one (the enemy's blows, a stack of kills).

const DIR := "res://art/audio/"
const VOICES := 10          # effects that can sound at once; the oldest is cut for the next
const FADE_OUT := 0.5       # the loop leaving
const FADE_IN := 0.9        # the loop arriving...
const FADE_IN_DELAY := 0.25 # ...a little after, so two tempos overlap less
const SET_FADE := 2.0       # one loop of a set into the next: out and in together, over this long
const DUCK_DB := -9.0       # how far the music drops under the pause menu
const SILENT_DB := -80.0
const VARY := 0.04          # random pitch on a blow or a knock, as a fraction

## Every name the game asks for, so a test can check the files exist and the forge writes them.
const NAMES := [
	"ui_tap", "ui_back", "plot", "codex_open", "codex_close", "menu_open",
	"die_pick", "die_drop", "die_roll", "die_lock", "shield_up", "vent",
	"hit", "hit_crit", "block", "shield_break", "kill", "arrival", "step", "resolve",
	"contact", "engage", "cut", "gate_hit", "spawn", "victory", "defeat", "withdraw",
	"overheat", "laser", "gunfire", "cannon", "slash", "slam",
	"music_far_bank", "music_hold_the_line", "music_low_ground", "music_night_shift", "music_crossing", "music_full_bore",
]

## What a screen's music is: a set of loops. A cycling set plays them in turn, one full
## loop each, the last crossfading into the first again: the map's, the two calm tracks,
## rift B and human B (Ryan, 25 September: both very good; one loop of each, then
## crossfade, to judge the crossfade). A picking set (PICK) takes one loop per visit, the
## next one each visit, and loops it: the skirmish's, human A, rift C and human C, since a
## fight must never crossfade tracks in the middle of itself (Ryan, the same day: fade in
## from the map, loop, fade back to the map on exit). The player may still skip: the pause
## menu's next and previous move within the screen's set (Ryan, 25 September).
##
## Boss themes (Ryan, 25 September): one per family, in the acts' order, since every battle
## ends on the same family's boss three or four times an act and the theme is the act's
## identity. A boss set is keyed "boss_<faction id>" and holds one loop; the battle screen
## starts it on the field the moment the boss is contacted, from its top, so the intro bars
## play under the reveal and the handover and the fight arrives in the groove. A family
## without a set falls back to the skirmish's pick (`boss_set`). The Far Bank is The
## Chorus's: the most choral and the most symphonic of the six, for the last act.
const SETS := {
	"map": ["music_low_ground", "music_night_shift"],
	"skirmish": ["music_hold_the_line", "music_crossing", "music_full_bore"],
	"boss_eldritch": ["music_far_bank"],
}
const PICK := ["skirmish"]

## Where a loop wraps to, in bars from its top, when it is not the top: a boss theme's intro
## plays once, under the reveal, and a long fight wraps into the groove instead (Ryan, 25
## September). Bars are the 4/4 bar's length at the loop's TEMPO. Absent means the top.
const LOOP_FROM := {"music_far_bank": 8, "music_hold_the_line": 8}   # Hold The Line wraps to the power chords, bar nine (Ryan, 29 September: its seam was the janky one; the bass's entrance at five was tried first)

## Every loop's shown title and its working label. The files are named for the titles
## (Ryan's picks, 25 September); the labels are creation order, human A B C and rift A B C,
## which is how listens are still discussed. The header's ticker shows the title; the
## pause menu shows both.
const TRACKS := {
	"music_hold_the_line": {"title": "Hold The Line", "label": "Human A"},
	"music_night_shift": {"title": "Night Shift", "label": "Human B"},
	"music_full_bore": {"title": "Full Bore", "label": "Human C"},
	"music_far_bank": {"title": "The Far Bank", "label": "Rift A"},
	"music_low_ground": {"title": "Low Ground", "label": "Rift B"},
	"music_crossing": {"title": "The Crossing", "label": "Rift C"},
}

## Pitched sounds (a horn, a chord, a drone) play at their written pitch; the rest get VARY.
const TONAL := ["contact", "victory", "defeat", "spawn", "engage", "overheat"]

## The moments that push the music down and let it climb back: name -> [depth dB, seconds
## to recover]. A cheap way to make a blow feel bigger than its file (Ryan, 23 September).
const DIP := {
	"contact": [-7.0, 0.7], "engage": [-9.0, 2.4], "cut": [-14.0, 1.6],
	"gate_hit": [-9.0, 1.4], "spawn": [-5.0, 1.3], "kill": [-6.0, 0.9],
	"shield_break": [-4.0, 0.5], "overheat": [-5.0, 1.0], "cannon": [-5.0, 0.7], "slam": [-4.0, 0.5],
	"victory": [-12.0, 3.0], "defeat": [-12.0, 3.0],
}

static var _node: Sound = null
static var muted := false   # tests and tools: nothing plays

## The loops' tempos, as tools/soundforge writes them, so a thing on screen can move on
## the beat (the rift's vortex, Ryan, 23 September: it had landed near the beat by chance).
const TEMPO := {"music_far_bank": 88.0, "music_hold_the_line": 104.0, "music_low_ground": 90.0, "music_night_shift": 94.0, "music_crossing": 126.0, "music_full_bore": 105.0}


## Beats elapsed in the loop that is playing, or -1 when nothing is.
static func beat() -> float:
	if _node == null or not is_instance_valid(_node) or not _node.is_inside_tree():
		return -1.0
	var p := _node._music[_node._music_live]
	if not p.playing or not TEMPO.has(_node._playing):
		return -1.0
	return p.get_playback_position() * float(TEMPO[_node._playing]) / 60.0

var _voices: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _music: Array[AudioStreamPlayer] = []   # two, so one loop fades into the next
var _music_live := 0
var _playing := ""
var _set := ""                               # the set a screen asked for ("map", "skirmish")
var _set_at: Dictionary = {}                 # set -> which of its loops is current
var _advance: Timer = null                   # fires SET_FADE before a set's loop ends, to go on to the next
var _loop_of: Array[String] = ["", ""]      # which loop each music player holds
var _pos: Dictionary = {}                    # loop -> where it was when it left, to resume there
var _fade: Tween = null                      # the crossfade in flight, killed by the next
var _streams: Dictionary = {}
var _ducked := false
var _duck_db := 0.0
var _dip_db := 0.0
var _duck_tween: Tween = null
var _dip_tween: Tween = null


# ---------------------------------------------------------------- the static face

## An effect, at `db` under its file's level. `vary` is the random pitch as a fraction;
## left negative it is VARY, or none for a TONAL sound.
static func play(name: String, db: float = 0.0, vary: float = -1.0) -> void:
	_call("_play", [name, db, vary])


## The same, `delay` seconds from now: the sound of a thing that lands after its animation.
static func play_after(delay: float, name: String, db: float = 0.0, vary: float = -1.0) -> void:
	_call("_play_after", [delay, name, db, vary])


## The music a screen wants: a set from SETS ("map", "skirmish"), a loop's own name
## ("crossing"), or "" for silence. Crossfades, and a set coming back resumes its current
## loop where it left (the map after a fight), unless `restart`: a new battle starts the set
## from its first loop's top (Ryan, 24 September: the map's music began mid-lift, where the
## last battle had left it). Asking for the set already playing does nothing.
static func music(name: String, restart: bool = false) -> void:
	_call("_music_to", [name, restart])


## The music drops under the pause menu and comes back after.
static func duck(on: bool) -> void:
	_call("_duck", [on])


## The pause menu's next (+1) and previous (-1): the neighbouring loop of the set that is
## playing, from its top, with the screen's own crossfade. A set of one loop, or silence,
## has nowhere to go.
static func skip(step: int) -> void:
	_call("_skip", [step])


## The loop playing (or arriving), by its full name, or "" when nothing is.
static func track() -> String:
	if _node == null or not is_instance_valid(_node):
		return ""
	return _node._playing


## The set a screen asked for ("map", "skirmish"), or "" when none is.
static func set_playing() -> String:
	if _node == null or not is_instance_valid(_node):
		return ""
	return _node._set


## The boss set for a family ("boss_eldritch"), or "" when the family has no theme yet and
## the fight takes the skirmish's pick.
static func boss_set(faction: String) -> String:
	var name := "boss_" + faction
	return name if SETS.has(name) else ""


## A loop's shown title, and its working label ("Human A"); "" for a loop without one.
static func title(loop: String) -> String:
	return str(TRACKS.get(loop, {}).get("title", ""))


static func label(loop: String) -> String:
	return str(TRACKS.get(loop, {}).get("label", ""))


## The volume knobs from Settings onto the buses.
static func apply_settings() -> void:
	_call("_apply", [])


## The node is made on the first call and joins the root deferred, since the first call
## usually comes from a screen's `_ready`, while the root is still setting that screen up
## and refuses children. Until it is in the tree, calls wait a frame with it.
static func _call(method: StringName, args: Array) -> void:
	if muted or DisplayServer.get_name() == "headless":
		return
	if _node == null or not is_instance_valid(_node):
		var tree := Engine.get_main_loop() as SceneTree
		if tree == null:
			return
		_node = Sound.new()
		_node.name = "Sound"
		tree.root.add_child.call_deferred(_node)
	if _node.is_inside_tree():
		_node.callv(method, args)
	else:
		_node.call_deferred("callv", method, args)


# ---------------------------------------------------------------- the node

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_bus("Music")
	_bus("Effects")
	for i in range(VOICES):
		var p := AudioStreamPlayer.new()
		p.bus = "Effects"
		add_child(p)
		_voices.append(p)
	for i in range(2):
		var p := AudioStreamPlayer.new()
		p.bus = "Music"
		p.volume_db = SILENT_DB
		add_child(p)
		_music.append(p)
	_advance = Timer.new()
	_advance.one_shot = true
	_advance.timeout.connect(_advance_set)
	add_child(_advance)
	_apply()


func _bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	var idx := AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")


func _stream(name: String) -> AudioStream:
	if _streams.has(name):
		return _streams[name]
	var path := DIR + name + ".wav"
	var s: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if s is AudioStreamWAV and name.begins_with("music_"):
		# The loops play round: the forge renders their tails across the seam. A loop with
		# a LOOP_FROM wraps to that bar instead of its top (the forge's wrapped tail then
		# lands on the intro, which plays once; the seam at the groove is bare).
		var w := s as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		var bars := int(LOOP_FROM.get(name, 0))
		w.loop_begin = int(round(bars * 4.0 * 60.0 / float(TEMPO.get(name, 120.0)) * w.mix_rate)) if bars > 0 else 0
		w.loop_end = int(round(w.get_length() * w.mix_rate))
	_streams[name] = s
	return s


func _play_after(delay: float, name: String, db: float, vary: float) -> void:
	if delay <= 0.0:
		_play(name, db, vary)
	else:
		get_tree().create_timer(delay).timeout.connect(_play.bind(name, db, vary))


func _play(name: String, db: float, vary: float) -> void:
	var s := _stream(name)
	if s == null:
		return
	if vary < 0.0:
		vary = 0.0 if TONAL.has(name) else VARY
	var p := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % VOICES
	p.stream = s
	p.volume_db = db
	p.pitch_scale = 1.0 + randf_range(-vary, vary)
	p.play()
	if DIP.has(name):
		_dip(float(DIP[name][0]), float(DIP[name][1]))


## A screen's set (or a single loop by name), with the screen's own crossfade.
func _music_to(name: String, restart: bool = false) -> void:
	if name.is_empty():
		_set = ""
		_fade_to("", FADE_OUT, FADE_IN, FADE_IN_DELAY)
		return
	var loops: Array = SETS.get(name, ["music_" + name])
	if restart:
		_set_at[name] = 0
		for loop in loops:
			_pos.erase(loop)
	if name == _set:
		return
	_set = name
	if PICK.has(name) and loops.size() > 1:
		# The next loop each visit; it starts from its top.
		_set_at[name] = (int(_set_at.get(name, -1)) + 1) % loops.size()
		_pos.erase(loops[int(_set_at[name])])
	_fade_to(loops[int(_set_at.get(name, 0)) % loops.size()], FADE_OUT, FADE_IN, FADE_IN_DELAY)


## SET_FADE before the current loop's end: the set's next loop, from its top, the two
## crossing over the seam. The loop that ends is forgotten, so its next turn starts from
## the top as well.
func _advance_set() -> void:
	var loops: Array = SETS.get(_set, [])
	if loops.size() < 2:
		return
	var ending := _playing
	var i := (int(_set_at.get(_set, 0)) + 1) % loops.size()
	_set_at[_set] = i
	_pos.erase(loops[i])
	_fade_to(loops[i], SET_FADE, SET_FADE, 0.0)
	_pos.erase(ending)


## A step through the playing set, from the player's hand. The loop left behind is
## forgotten like a loop that ended, so its next turn starts from the top; the set's
## counter moves with the step, so a picking set's next visit goes on from here.
func _skip(step: int) -> void:
	var loops: Array = SETS.get(_set, [])
	if loops.size() < 2 or _playing.is_empty():
		return
	var i := loops.find(_playing)
	if i < 0:
		i = int(_set_at.get(_set, 0))
	i = posmod(i + step, loops.size())
	_set_at[_set] = i
	var leaving := _playing
	_pos.erase(loops[i])
	_fade_to(loops[i], FADE_OUT, FADE_IN, FADE_IN_DELAY)
	_pos.erase(leaving)


## The crossfade. The one before is killed first: it would otherwise still stop the player
## it was fading out, which may be the very player the new loop now plays on (Ryan, 23
## September: the skirmish loop went missing about half the time, whenever the next fight
## began inside the last fade). A loop of a set of several arms the advance timer for
## SET_FADE before its end.
func _fade_to(full: String, fade_out: float, fade_in: float, delay: float) -> void:
	_advance.stop()
	if full == _playing:
		return
	_playing = full
	if _fade != null and _fade.is_valid():
		_fade.kill()
	var out := _music[_music_live]
	_music_live = 1 - _music_live
	var into := _music[_music_live]
	_fade = create_tween().set_parallel(true)
	if out.playing:
		_pos[_loop_of[1 - _music_live]] = out.get_playback_position()
		# Equal power, on linear gain: a tween of decibels from silence spent most of its
		# time inaudible, so a crossfade read as a gap and then a start (Ryan, 25 September).
		var x0 := acos(clampf(db_to_linear(out.volume_db), 0.0, 1.0)) / (PI / 2.0)
		_fade.tween_method(_fade_out_gain.bind(out), x0, 1.0, fade_out)
		_fade.tween_callback(out.stop).set_delay(fade_out)
	var s := _stream(full) if not full.is_empty() else null
	if s == null:
		into.stop()
		return
	into.stream = s
	into.volume_db = SILENT_DB
	_loop_of[_music_live] = full
	var pos := fmod(float(_pos.get(full, 0.0)), maxf(s.get_length(), 0.001))
	into.play(pos)
	_fade.tween_method(_fade_in_gain.bind(into), 0.0, 1.0, fade_in).set_delay(delay)
	if SETS.get(_set, []).size() > 1 and not PICK.has(_set):
		_advance.start(maxf(0.1, s.get_length() - pos - SET_FADE))


## The two halves of an equal-power crossfade: `x` runs 0 to 1, the leaving loop follows
## the cosine and the arriving one the sine, so the sum of powers holds through the cross.
func _fade_out_gain(x: float, p: AudioStreamPlayer) -> void:
	p.volume_db = _gain_db(cos(x * PI / 2.0))


func _fade_in_gain(x: float, p: AudioStreamPlayer) -> void:
	p.volume_db = _gain_db(sin(x * PI / 2.0))


static func _gain_db(v: float) -> float:
	return SILENT_DB if v <= 0.0005 else linear_to_db(v)


func _duck(on: bool) -> void:
	if _ducked == on:
		return
	_ducked = on
	if _duck_tween != null and _duck_tween.is_valid():
		_duck_tween.kill()
	_duck_tween = create_tween()
	_duck_tween.tween_method(_set_duck, _duck_db, DUCK_DB if on else 0.0, 0.35)


## A fast drop and a slow climb back, on top of whatever the duck is doing.
func _dip(depth: float, recover: float) -> void:
	if _dip_tween != null and _dip_tween.is_valid():
		_dip_tween.kill()
	var low := minf(_dip_db, depth)
	_dip_tween = create_tween()
	_dip_tween.tween_method(_set_dip, _dip_db, low, 0.03)
	_dip_tween.tween_method(_set_dip, low, 0.0, recover).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _set_duck(v: float) -> void:
	_duck_db = v
	_set_music_bus()


func _set_dip(v: float) -> void:
	_dip_db = v
	_set_music_bus()


## Settings onto the buses: a knob at 0 is silence, not merely quiet.
func _apply() -> void:
	_set_music_bus()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), _db(float(Settings.display.get("effects", 1.0))))


## The music bus is the knob, the duck and the dip together; each moves its own number and
## calls this, so none of them fights another's tween.
func _set_music_bus() -> void:
	var knob := _db(float(Settings.display.get("music", 0.8)))
	var v := SILENT_DB if knob <= SILENT_DB else knob + _duck_db + _dip_db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), v)


static func _db(v: float) -> float:
	return SILENT_DB if v <= 0.005 else linear_to_db(v)

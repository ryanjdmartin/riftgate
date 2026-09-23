class_name Sound
extends Node

## The game's sound. The direction (bible, 22 September): effects grounded and heavy,
## weight and machinery, never a space opera; music an industrial groove, driving but not
## fast. Every sound is a WAV under art/audio built by tools/soundforge from a written
## recipe, the way the models are built, and is asked for by name: `Sound.play("hit")`,
## `Sound.music("skirmish")`. Like `Settings`, a static face; the node behind it is made on
## first use and lives under the root. Headless there is no node and every call is a no-op,
## so the sim and the tests never touch audio.

const DIR := "res://art/audio/"
const VOICES := 10          # effects that can sound at once; the oldest is cut for the next
const CROSSFADE := 1.4      # seconds between one loop and the next
const DUCK_DB := -9.0       # how far the music drops under the pause menu
const SILENT_DB := -80.0

## Every name the game asks for, so a test can check the files exist and the forge writes them.
const NAMES := [
	"ui_tap", "ui_back", "plot", "codex_open", "codex_close", "menu_open",
	"die_pick", "die_drop", "die_roll", "die_lock", "shield_up", "vent",
	"hit", "hit_crit", "block", "shield_break", "kill", "arrival", "step", "resolve",
	"contact", "engage", "cut", "gate_hit", "spawn", "victory", "defeat", "withdraw",
	"music_map", "music_skirmish",
]

static var _node: Sound = null
static var muted := false   # tests and tools: nothing plays

## The loops' tempos, as tools/soundforge writes them, so a thing on screen can move on
## the beat (the rift's vortex, Ryan, 23 September: it had landed near the beat by chance).
const TEMPO := {"music_map": 92.0, "music_skirmish": 100.0}


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
var _streams: Dictionary = {}
var _ducked := false


# ---------------------------------------------------------------- the static face

## An effect, at `db` under its file's level, with a little random pitch (`vary`, as a
## fraction) so a repeated blow never sounds like a sample repeating.
static func play(name: String, db: float = 0.0, vary: float = 0.04) -> void:
	_call("_play", [name, db, vary])


## The same, `delay` seconds from now: the sound of a thing that lands after its animation.
static func play_after(delay: float, name: String, db: float = 0.0, vary: float = 0.04) -> void:
	_call("_play_after", [delay, name, db, vary])


## The loop a screen wants: "map", "skirmish", or "" for silence. Crossfades; asking for
## the loop already playing does nothing.
static func music(name: String) -> void:
	_call("_music_to", [name])


## The music drops under the pause menu and comes back after.
static func duck(on: bool) -> void:
	_call("_duck", [on])


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
		# The loops play round: the forge renders their tails across the seam.
		var w := s as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
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
	var p := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % VOICES
	p.stream = s
	p.volume_db = db
	p.pitch_scale = 1.0 + randf_range(-vary, vary)
	p.play()


func _music_to(name: String) -> void:
	var full := "" if name.is_empty() else "music_" + name
	if full == _playing:
		return
	_playing = full
	var out := _music[_music_live]
	_music_live = 1 - _music_live
	var into := _music[_music_live]
	var tw := create_tween().set_parallel(true)
	if out.playing:
		tw.tween_property(out, "volume_db", SILENT_DB, CROSSFADE).set_trans(Tween.TRANS_SINE)
		tw.chain().tween_callback(out.stop)
	var s := _stream(full) if not full.is_empty() else null
	if s == null:
		into.stop()
		return
	into.stream = s
	into.volume_db = SILENT_DB
	into.play()
	tw.tween_property(into, "volume_db", 0.0, CROSSFADE).set_trans(Tween.TRANS_SINE)


func _duck(on: bool) -> void:
	if _ducked == on:
		return
	_ducked = on
	_apply(0.35)


## Settings onto the buses: a knob at 0 is silence, not merely quiet.
func _apply(over: float = 0.0) -> void:
	var music_db := _db(float(Settings.display.get("music", 0.8))) + (DUCK_DB if _ducked else 0.0)
	var fx_db := _db(float(Settings.display.get("effects", 1.0)))
	var mi := AudioServer.get_bus_index("Music")
	var ei := AudioServer.get_bus_index("Effects")
	if over <= 0.0:
		AudioServer.set_bus_volume_db(mi, music_db)
	else:
		var tw := create_tween()
		tw.tween_method(func(v: float) -> void: AudioServer.set_bus_volume_db(mi, v), AudioServer.get_bus_volume_db(mi), music_db, over)
	AudioServer.set_bus_volume_db(ei, fx_db)


static func _db(v: float) -> float:
	return SILENT_DB if v <= 0.005 else linear_to_db(v)

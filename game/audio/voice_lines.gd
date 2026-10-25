class_name VoiceLines
extends RefCounted

## Jenny's lines as a system (Ryan, 7 and 8 October; tools/soundforge/voice_lines.py holds the
## pools and renders them into art/audio/voice with a lines.json this reads). She is the
## console's voice: infrequent and surprising, many phrases on many hooks, each hook speaking
## only sometimes, with room between lines so she never rattles off several at once.
##
## The rules, as the pools' file states them and Ryan settled them:
##   chance       a hook speaks on a trigger with its chance; an information hook (a machine
##                lost, a component damaged or destroyed, the two heat marks, a loss) every time.
##   pools        a hook draws from its own pool and any it merges (a Horde foe falling draws
##                the generic foe-down pool too; every unit committed, the moves' pool too).
##   variety      a shuffle bag per hook: nothing repeats until the bag is spent.
##   personality  a line that fires is replaced, one time in fifteen, by one from the merged
##                personality pool, where there is one.
##   spacing      one line at a time, never overlapping, SPACING seconds after the last one
##                ends; a line that waited STALE seconds is dropped unsaid, except an
##                information line, which waits only for the line in progress and INFO_GAP.
##   one a hook   a hook already waiting is not queued twice (three components destroyed in one
##                enemy turn say "component destroyed" once).
##   pre-emption  a loss clears the queue, cuts a line in progress and speaks at once (the
##                player's hands are off the controls anyway); the skirmish's win clears the
##                queue, so the final kill never gets a heat warning after it, and the victory
##                line waits for the victory screen; an overheat replaces a waiting heat warning.
##   signals      a hook may carry a console signal heard first, the line SIGNAL_GAP after it
##                (the warning's two blips at three quarters heat, the alarm past the cap).
##
## Pure logic with its own clock and dice, so tests drive it headless: `trigger` decides and
## queues, `next` says what to play when the player is free. The Sound node plays it.

const SPACING := 6.0
const STALE := 2.0
const INFO_GAP := 1.0
const SIGNAL_GAP := 0.25
const PERSONALITY := 1.0 / 15.0
const LOSSES := ["loss_gate", "loss_city"]

var hooks: Dictionary = {}       # hook -> {chance, info, lines: [{file, text}], personality: [...], merge: [...], signal}
var spacing := SPACING
var stale := STALE
var personality := PERSONALITY
var rng := RandomNumberGenerator.new()
## The test mode (a debug build's settings, 8 October: Ryan could not get the codex's one in
## twelve to fire on the phone): every hook speaks every time, each line a second after the
## last, nothing goes stale, so every hook can be heard on demand.
var always := false

var _queue: Array = []           # [{hook, file, text, at, info, signal}], oldest first
var _bags: Dictionary = {}       # hook -> remaining indices into its merged normal pool
var _pbags: Dictionary = {}      # hook -> remaining indices into its merged personality pool
var _busy_until := -1.0          # when the line in progress ends (seconds on the caller's clock)
var _last_end := -INF            # when the last line ended


## The table from lines.json (or a test's own).
func load_table(table: Dictionary) -> void:
	hooks = table.get("hooks", {})
	spacing = float(table.get("spacing", SPACING))
	stale = float(table.get("stale", STALE))
	personality = float(table.get("personality", PERSONALITY))
	_queue.clear()
	_bags.clear()
	_pbags.clear()


## A hook fired at time `now`. Returns true when a line was queued.
func trigger(hook: String, now: float) -> bool:
	if not hooks.has(hook):
		return false
	var h: Dictionary = hooks[hook]
	var info := bool(h.get("info", false))
	if not info and not always and rng.randf() >= float(h.get("chance", 1.0)):
		return false
	var line := _pick(hook)
	if line.is_empty():
		return false
	if LOSSES.has(hook):
		_queue.clear()
		_busy_until = -1.0          # the line in progress is cut (the caller stops its player)
		_last_end = -INF
	if hook == "overheat":
		_queue = _queue.filter(func(q: Dictionary) -> bool: return q["hook"] != "heat_high")
	for q in _queue:
		if q["hook"] == hook:
			return false
	_queue.append({"hook": hook, "file": str(line["file"]), "text": str(line.get("text", "")), "at": now,
		"info": info, "signal": str(h.get("signal", "")), "loss": LOSSES.has(hook)})
	return true


## A chance line the caller places itself, at time `at` (a spend's line: before the weapon on
## a blow that does not kill, as the kill's sound on one that does; Ryan, 9 October). Rolled
## and drawn now, and only when she is free then: no line in progress or waiting, and the
## spacing since the last kept. Returns the line, or {}; the caller plays it at `at` and calls
## `started(at, seconds)`, which holds every other line off until it ends.
func claim(hook: String, at: float) -> Dictionary:
	if not hooks.has(hook) or not _queue.is_empty():
		return {}
	var h: Dictionary = hooks[hook]
	if at < _busy_until or at < _last_end + (INFO_GAP if always else spacing):
		return {}
	if not always and rng.randf() >= float(h.get("chance", 1.0)):
		return {}
	var line := _pick(hook)
	if line.is_empty():
		return {}
	return {"hook": hook, "file": str(line["file"]), "text": str(line.get("text", ""))}


## Every waiting line dropped (the skirmish won); a line in progress finishes.
func clear() -> void:
	_queue.clear()


## What to play at time `now`, or {} for nothing yet: the oldest line still worth saying,
## once the line in progress has ended and its gap has passed. The caller says how long the
## line runs with `started`.
func next(now: float) -> Dictionary:
	if now < _busy_until:
		return {}
	while not _queue.is_empty():
		var q: Dictionary = _queue[0]
		if not q["info"] and not always and now - float(q["at"]) > stale:
			_queue.pop_front()
			continue
		var gap := 0.0 if q["loss"] else (INFO_GAP if q["info"] or always else spacing)
		if now < _last_end + gap:
			if not q["info"] and not always and (_last_end + gap) - float(q["at"]) > stale:
				_queue.pop_front()   # it would be stale by the time its turn came
				continue
			return {}
		_queue.pop_front()
		return q
	return {}


## The line just handed out runs `seconds` (its signal and gap included).
func started(now: float, seconds: float) -> void:
	_busy_until = now + seconds
	_last_end = _busy_until


func waiting() -> Array:
	return _queue.duplicate()


## A line from the hook's merged pool, or its merged personality pool one time in fifteen.
func _pick(hook: String) -> Dictionary:
	var pool := _merged(hook, "lines")
	var ppool := _merged(hook, "personality")
	if not ppool.is_empty() and (pool.is_empty() or rng.randf() < personality):
		return ppool[_draw(_pbags, hook, ppool.size())]
	if pool.is_empty():
		return {}
	return pool[_draw(_bags, hook, pool.size())]


func _merged(hook: String, key: String) -> Array:
	var out: Array = []
	var h: Dictionary = hooks.get(hook, {})
	out.append_array(h.get(key, []))
	for other in h.get("merge", []):
		out.append_array(hooks.get(other, {}).get(key, []))
	return out


## The shuffle bag: every index once in a random order, refilled when spent.
func _draw(bags: Dictionary, hook: String, n: int) -> int:
	var bag: Array = bags.get(hook, [])
	if bag.is_empty() or int(bag.max()) >= n:
		bag = range(n)
		for i in range(bag.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var t = bag[i]
			bag[i] = bag[j]
			bag[j] = t
	var pick: int = bag.pop_back()
	bags[hook] = bag
	return pick

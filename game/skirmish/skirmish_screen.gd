class_name SkirmishScreen
extends Control

## The skirmish screen as a tactical overlay. Portrait, 720x1280 logical, positioned
## absolutely so every coordinate is a plain number.
##
##   header      round and reinforcements tag, phase readout, MENU at the right
##   formation   two ranks of four unit views; a massive foe spans both ranks of its column;
##               under each foe its intent (fantasy icon and number) and its statuses
##   log         every event at full strength, scrollable, the new lines typing in; double-tap for it full screen;
##               the intent eye at its right, in the black between the two grounds
##   dice        tap to lock, hold to see every face, drag onto a target to spend; the wide
##               Reroll sits right under them, before or after attacking
##   mechs       gauges hugging the sprite, warning chips under it: shield break, component
##               risk, wreck, overheat; the gauges pulse where they are about to change
##   bottom      End turn bottom-left, asking first over unspent dice; Undo bottom-right
##
## No names on screen. Kinetic faces roll when they land and the number flashes over the
## target. Hold a unit for numbers, statuses and arrows, a die for every entry and what
## applies to it. Double-tap a unit for its codex entry.
##
## The enemy's turn is replayed blow by blow at the ENEMY PACE setting, the struck mech's
## gauges stepping down as each lands, before the next round's dice show or the outcome
## (Ryan, 23 September). Taps are held off while it plays.

signal finished(outcome: int)
signal back_requested
signal quit_requested   # the menu's QUIT: the host leaves for the harness

var back_label := "BACK"   # the outcome's button: the battle screen says where back leads
var music_set := "skirmish"   # what this fight plays: the battle's pair on its battle half, or a family's boss theme the battle screen already started at contact
var autosave: Callable = Callable()   # the battle screen's save, called after every change to the fight, so a phone put down mid-fight resumes here

const W := 720.0
const BASE_H := 1280.0   # the design's height; on a taller phone the rows spread out to fill it
var H := BASE_H
var BACK_Y := 72.0    # the foes' ground starts 14 above: 16 px of black under the header (Ryan, 23 September)
var FRONT_Y := 266.0
const SLOT_SIZE := Vector2(150, 194)     # floating gauge 18 + a 72x96 foe at two device pixels a pixel on the 1080 phone (96x128 design) + chip row 38
const MASSIVE_SIZE := Vector2(150, 388)  # 96x144 massive foes across both ranks, the same way
var EYE_Y := 510.0   # 12 px into the black under the foes' ground, the same as its margin from the right edge
const EYE := 60.0
var LOG_Y := 508.0
const LOG_H := 112.0
var DIE_Y := 630.0
const DIE_SIZE := 120.0
var REROLL_Y := 768.0
const REROLL_SIZE := Vector2(250, 54)
const UNDO_AFTER := 0.8   # the undo opens this long after a spend's blow has landed: its views have settled
const ROLL_BAR := "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"   # a roll's bar in the trail (Ryan, 2 November): where the undo stops
const REROLL_GAP := 30.0   # black between Reroll and the mechs' ground (Ryan, 23 September: 14 was too tight)
var MECH_Y := 852.0
const MECH_SIZE := Vector2(176, 284)   # gauges 46 + 80x96 sprite at 2x + chip row 38; neighbours overlap 4 px at PITCH
## Room under the machines for two more rows of chips past the first (Ryan, 2 November: "there needs
## to be space for 2-3 rows of chips under the player units specifically without bumping into the
## UI"): the rows wrap at a machine's width, so three hold six or more.
const CHIP_ROOM := 2.0 * (UnitView.CHIP_H + UnitView.ROW_GAP)
var BOTTOM_Y := 1210.0
## The rows' places on the 1280 design, scaled to the screen in `_build`. The machines stand 40 higher
## and END TURN 14 lower than until 2 November, so three rows of chips fit between them.
const ROWS := {"BACK_Y": 72.0, "FRONT_Y": 266.0, "EYE_Y": 510.0, "LOG_Y": 508.0, "DIE_Y": 630.0, "REROLL_Y": 768.0, "MECH_Y": 852.0, "BOTTOM_Y": 1210.0}
## The rows with the controls at the bottom (Ryan, 29 October: "Skirmish Controls", "bottom"
## or "middle", Settings): the foes where they were, the machines right under them in one
## scene, then the log, dice and Reroll, the log far enough down for three rows of chips under the
## machines. RIFTGATE_SKIRMISH_CONTROLS=bottom|middle forces it.
const ROWS_BOTTOM := {"BACK_Y": 72.0, "FRONT_Y": 266.0, "MECH_Y": 480.0, "LOG_Y": 850.0, "EYE_Y": 852.0, "DIE_Y": 972.0, "REROLL_Y": 1106.0, "BOTTOM_Y": 1210.0}
## The field (Ryan, 29 October: "it's 100% field"): one floor from the horizon to the machines'
## feet, the other world painted far under the foes and our ground near under the machines,
## seen by one level camera that the floor, the backdrop's bands and every machine's view
## share. It is set so a row of hexes PITCH wide runs through the machines' feet, seen
## FIELD_THETA down there; the squad stands in SLOTS hexes of it, a smaller one leaving its
## spots empty, so the floor never changes with the squad.
const FIELD_THETA := 30.0
const SLOTS := 4
const MECH_FOOT := 214.0    # a machine's hex centre below the top of its row
const MECH_WINDOW := Rect2(-22.0, 14.0, 220.0, 256.0)   # a machine's view in its row: the floor camera's window it is drawn through
const MECH_FILL := 0.96     # a machine's size in hexes at its class's full share (MechView3D.SIZE_FILL)
const FLYER_LIFT := 0.4     # hexes a flyer stands off the floor, and a hovercraft
const HOVER_LIFT := 0.06
const WINGED_LIFT := 16.0   # design pixels a winged foe floats over its feet line
const FIELD_TURN := 15.0    # degrees a machine turns toward the middle, those left of it to the right and those right of it to the left
var _cam := {}              # _field_camera
const BOTTOM_BTN := Vector2(210, 60)
const MECH_LOG_GAP := 18.0  # with the controls at the bottom, from the machines' row to the log
const PITCH := 172.0
const ENEMY_BEAT := 0.45   # seconds between the enemy's blows at ENEMY PACE 1; the setting divides it
const ACT_LEAD := 0.45     # how much of a beat the next foe is lit before its move lands
const PLAQUE_HOLD := 1.0   # seconds the replay holds on a named move's plaque (decided 9 October; a placeholder, judged running); the pace setting does not shorten a read
const PLAQUE_Y := -10.0    # the plaque's top, from the back rank's row: over the foes, where the other world is
## RIFTGATE_PLAQUE_DEBUG=1: the plaque fires one of the field's move names after another.
static var PLAQUE_DEBUG := OS.get_environment("RIFTGATE_PLAQUE_DEBUG") == "1"
## RIFTGATE_ACT_DEBUG=1: one foe after another lit as if acting, a beat each, to judge the
## highlight running (Ryan, 2 November: "enemies need to highlight during their attacks").
static var ACT_DEBUG := OS.get_environment("RIFTGATE_ACT_DEBUG") == "1"
## RIFTGATE_SEAL_DEBUG=1 (the model's own switch: its seal held and let go in turn): the sealed
## machine's shell and its burst follow the model, to judge them running together.
static var SEAL_DEBUG := OS.get_environment("RIFTGATE_SEAL_DEBUG") == "1"
var _act_debug_at := 0.0
## RIFTGATE_RAGE_DEBUG=1: the rage bar fills two a beat on the machine that banks rage (the
## Nemesis's since 11 November) and empties at its cap, so its notches, the die's charged mark
## at five and the bar's colour are judged running.
static var RAGE_DEBUG := OS.get_environment("RIFTGATE_RAGE_DEBUG") == "1"
## RIFTGATE_PREY_DEBUG=1: the predator sense stays on, over the foes the first ambusher's entry
## showing marks (or, with no ambusher on the team, the first machine's, the read forced), to
## judge it running.
static var PREY_DEBUG := OS.get_environment("RIFTGATE_PREY_DEBUG") == "1"
## RIFTGATE_BLAST_DEBUG=1: the blast's marks stay on, over every foe the first machine whose vents
## blast would fire at with its die's vent (its heat raised to fire it), to judge them running.
static var BLAST_DEBUG := OS.get_environment("RIFTGATE_BLAST_DEBUG") == "1"
## RIFTGATE_PREVIEW_DEBUG=1: every foe showing a blow wears the pulsing preview chip of a rally on
## its way (+1 where none is coming, its number unchanged), to judge the pulse running.
static var PREVIEW_DEBUG := OS.get_environment("RIFTGATE_PREVIEW_DEBUG") == "1"
## RIFTGATE_ABILITY_DEBUG=1: every foe and machine wears an ability's chip (its glyph on a solid
## tile, 8 November), to judge the look on the phone beside the buffs and debuffs.
static var ABILITY_DEBUG := OS.get_environment("RIFTGATE_ABILITY_DEBUG") == "1"
## RIFTGATE_MINE_DEBUG=1: every foe opens the fight carrying a Mine of 3 with Burn 1 and Shock (the
## Lammergeier's, 9 November), so any kill shows its blast land round the slot and the chips, to
## judge them running.
static var MINE_DEBUG := OS.get_environment("RIFTGATE_MINE_DEBUG") == "1"
## RIFTGATE_HIT_DEBUG=1: every second and a half a machine takes a blow, in turn a hull hit from the
## left, a blow its shield takes, a blow its armour turns and a hull hit from the right, and every
## fifth beat one is lost and comes back, to judge the hit reactions running (3 November).
static var HIT_DEBUG := OS.get_environment("RIFTGATE_HIT_DEBUG") == "1"
const HIT_DEBUG_KINDS := [["hull", -1.0], ["shield", 0.0], ["block", 0.6], ["hull", 1.0]]
var _hit_debug_at := 0.0
## RIFTGATE_MISS_DEBUG=1: every second and a half a Sweep's wasted shot lands on an empty slot of the
## enemy's formation, each in turn, to judge the impact running (7 November; a first cut).
static var MISS_DEBUG := OS.get_environment("RIFTGATE_MISS_DEBUG") == "1"
var _miss_debug_at := 0.0
var _miss_debug_n := 0
var _hit_debug_n := 0
const ROLL_AGAIN_AT := 0.3   # the die flips back this long after its stack bursts (a placeholder, judged running)
const HOME_FLIGHT := 0.22   # seconds a waiting Swap's die takes to fly home when a tap on nothing sets it back
var _rage_debug_at := -10.0

var sk: Skirmish
var locked: Array[bool] = []
var show_all_arrows: bool = false

var _header: HudButton
var _sub_label: Label
var _eye: HudButton
var _switch: HudButton               # the controls' quick switch, left of the eye
var _log: RichTextLabel
var _log_scroll: ScrollContainer
var _log_full: Control = null        # the log full screen: a shade with a panel
var _log_full_text: RichTextLabel
var _log_full_scroll: ScrollContainer
var _log_tap_at := -10.0
var _home: Dictionary = {}           # Control -> where it rests; every animation returns there
var _live_tweens: Dictionary = {}    # Control -> the tweens moving it now, killed before a new one starts
var _slot_views: Array = []          # [rank][col] -> UnitView
var _massive_views: Array = []       # [col] -> UnitView
var _twin_views: Array = []          # [rank][col] -> UnitView: a twin slot's right-hand half (the Gel's pair), hidden otherwise
var _pair_marks: PairMarks = null    # an area weapon's target brackets round a twin slot whole
var _half_sides: Dictionary = {}     # Foe -> 0 left, 1 right: the side of its slot each half of a pair was last shown on


## The brackets an area weapon draws round a twin slot's pair, one for the slot (Ryan, 26
## October: "show both halves selected as if they were a single slot", so a Spread plainly
## still reaches the neighbours and a Penetrate both halves), over the views.
class PairMarks extends Control:
	var rects: Array = []   # Rect2 in the screen's space

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_rects(r: Array) -> void:
		if r != rects:
			rects = r
			queue_redraw()

	func _draw() -> void:
		for r in rects:
			Hud.brackets(self, r, 14.0, Palette.TARGET, 2.0)
var _view_foe: Dictionary = {}       # UnitView -> Foe
var _mech_views: Array[UnitView] = []
var _dice: Array[DieFaceView] = []
var _ghost: DieFaceView
## A spend waiting on its second target (a Swap, the Dingo's Combat Translocator; Ryan, 21
## October: drag to the first target, drop, the seconds light, tap one): {"mech", "primary"}.
## The die sits over its first target; dragging it again picks it back up, to move or cancel.
var _pending: Dictionary = {}
var _arrows: ArrowLayer
var _details: HudPanel
var _details_label: Label
var _details_entry: EntryReadout     # the die's hold: the entry showing, its effects listed (Ryan, 25 October)
var _details_ring: CylinderView      # a stepping die's chambers in its readout (the Cassowary's)
var _codex: CodexBox                 # the spec plate, shared with the battle screen
var _mech_3d: Array[MechView3D] = [] # parallel to _mech_views; null where the mech is a sprite
var _bg: HudBackdrop = null
var _plaque: Plaque = null           # the other world's window: a foe's named move, announced
var _plaque_debug_at := 0.0
var _prey: PreyLayer = null          # the predator sense: the foes' ground dimmed, eyes on the foes looking away


var _fight_t := 0.0                  # seconds since the feed opened: the header's clock
var _clock_sec := -1
var _phase := "ASSIGN"               # the header's phase word; the clock rides after it
var _log_typing := false             # new lines typing in: the cursor waits


## Every frame: the scan band lights the mechs' traces as it crosses them (as on the map),
## the header's clock ticks, and the log's cursor blinks (Ryan, 23 September: the HUD as a
## feed being read in real time; the band lighting gauges and buttons too was tried the
## same day and cut, a horizontal band crossing a horizontal bar only blinks it).
func _process(delta: float) -> void:
	if _bg == null:
		return
	_fight_t += delta
	if RAGE_DEBUG and _fight_t - _rage_debug_at > 1.6:
		_rage_debug_at = _fight_t
		_rage_debug()
	if PLAQUE_DEBUG and _plaque != null and not _plaque.is_showing() and _fight_t - _plaque_debug_at > PLAQUE_HOLD + 1.2:
		_plaque_debug_at = _fight_t
		var names: Array = []
		for f in sk.field_foes():
			for a in f.actions:
				names.append(str(a.get("name", "")))
		if names.is_empty():
			names = ["Protect", "1000 Needles", "Self-Destruct", "Bone Storm"]
		_announce(str(names[int(_fight_t / (PLAQUE_HOLD + 1.2)) % names.size()]))
	if SEAL_DEBUG:
		for k in range(mini(_mech_3d.size(), _mech_views.size())):
			var mv3 := _mech_3d[k]
			if mv3 == null or mv3.rig == null or not mv3.rig.forms.has("sealed"):
				continue
			var held := mv3.rig.form_held("sealed")
			if held != _mech_views[k].shell:
				_mech_views[k].shell = held
				_mech_views[k].form_shift(held)
	if ACT_DEBUG and not _replay_shade.visible and _fight_t - _act_debug_at > 1.2:
		_act_debug_at = _fight_t
		var views := _live_foe_views()
		if not views.is_empty():
			var at := views.find(_lit)
			_spotlight(views[(at + 1) % views.size()])
	if HIT_DEBUG and _fight_t - _hit_debug_at > 1.5 and not _mech_views.is_empty():
		_hit_debug_at = _fight_t
		_hit_debug()
	if MISS_DEBUG and _fight_t - _miss_debug_at > 1.5:
		_miss_debug_at = _fight_t
		_miss_debug()
	if _undo_waiting and Time.get_ticks_msec() >= _undo_from:
		_undo_waiting = false
		_refresh_undo()   # the spend's blow has played: the undo opens
	var sec := int(_fight_t)
	if sec != _clock_sec:
		_clock_sec = sec
		_sub_label.text = _phase_text()
	if _log != null and not _log_typing:
		var total := _log.get_total_character_count()
		var want := total if fmod(_fight_t, 1.0) < 0.6 else total - 1
		if _log.visible_characters != want:
			_log.visible_characters = want
	var y := _bg.scan_y()
	for i in range(_mech_3d.size()):
		var view := _mech_3d[i]
		if view == null or i >= _mech_views.size():
			continue
		var v := _mech_views[i]
		if v.size.y <= 0.0:
			continue
		view.set_sweep_screen((y - v.position.y - v.sprite_at.position.y) * view.density)


## The feed's analysis events pick from what is alive right now.
func _live_foe_views() -> Array:
	var out: Array = []
	for v in _view_foe.keys():
		if v.visible and not v.dead:
			out.append(v)
	return out


func _live_mech_views() -> Array:
	var out: Array = []
	for v in _mech_views:
		if not v.dead:
			out.append(v)
	return out


func _live_dice() -> Array:
	var out: Array = []
	for d in _dice:
		if not d.dead and not d.spent and d.face != null:
			out.append(d)
	return out


func _phase_text() -> String:
	if not is_inside_tree() or _clock_sec < 0:
		return _phase
	return "%s // %02d:%02d" % [_phase, _clock_sec / 60, _clock_sec % 60]


func _set_phase(p: String) -> void:
	_phase = p
	_sub_label.text = _phase_text()


## The display locks onto every foe's intent: called as a round's intents appear, with the
## round opening's figure, once a round.
func _acquire_intents() -> void:
	if not is_inside_tree():
		return
	Sound.play("round_open")
	for v in _view_foe.keys():
		if v.visible and not v.dead:
			v.acquire()
var _confirm_shade: Control
var _confirm: HudPanel
var _confirm_text: Label
var _confirm_action: Callable = Callable()
var _reroll_btn: HudButton
## What the screen played for the last spend: {"dead": the foes it showed falling, "rose": those
## among them it showed getting back up}.
var spend_played: Dictionary = {"dead": [], "rose": []}
var _undo_btn: HudButton
var _undo_from: int = 0   # the tick (ms) the undo opens again after a spend, once its blow has played
var _undo_waiting := false   # a spend's blow is playing: _process opens the undo once the clock passes _undo_from
var _end_btn: HudButton
var _overlay: Control
var _overlay_title: Label
var _overlay_text: Label
var _replay_shade: Control            # swallows taps while the enemy's turn replays
var _fx: FeedFX = null                # the display's rare analysis events
var _drag_from: int = -1
var _log_seen: int = 0
## The unit or die whose readout a tap left open, one at a time (Ryan, 29 October: "a tap toggle,
## only one unit popup allowed at a time"; a die's too, 30 October): {"foe": Foe}, {"mech":
## index} or a die's {"die": index}; empty, none.
var _pop: Dictionary = {}
const POP_ALPHA := 0.85   # a unit's readout lets the arrows under it show through (Ryan, 29 October: "slightly translucent"; 2 November: "Increase the opacity of the popups in skirmish a bit", from 0.7)
const POP_GAP := 4.0      # a machine's readout over its gauges
var _drag_over = null                 # what the dragged die is over and may be spent on: a Foe, a MechState or an empty slot
var _round: Dictionary = {}           # the rest of the round as it stands (Skirmish.preview_round): every machine's gauges and warnings, every foe's HP after it
var _turns: Array[Foe] = []           # the foes a Lure in hand would turn, their arrows drawn dashed to the die's machine


func setup(skirmish: Skirmish) -> void:
	sk = skirmish
	sk.keeps_undo = true   # the screen's fight keeps the undo's snapshots (the runners never)
	_heat_warned.clear()
	locked.clear()
	for m in sk.mechs:
		locked.append(false)
	if sk.state == Skirmish.State.SETUP:
		sk.begin()
	if sk.state == Skirmish.State.ROUND_START:
		sk.start_round()
	if MINE_DEBUG:
		for foe in sk.field_foes():
			if Skirmish.mine_of(foe).is_empty():
				sk._add_mine(foe, 3, {"stacks": {"burning": 1}, "keywords": ["shock"]})
	_build()
	_refresh()


func _ready() -> void:
	Settings.apply()
	Hud.oversample(get_window())   # standalone runs too: text at the glass's density
	if sk == null:
		setup(_default_skirmish())
	elif _header == null or H != Hud.screen_height(self):
		_build()   # built here for the screen's real height (a taller phone than the design)
		_refresh()
	_scroll_to_end(_log_scroll)   # set up before entering the tree: the strip starts at its last line
	_acquire_intents()
	Sound.music(music_set)   # the flip ENGAGE started (or a boss theme from the field) carries on; a fight resumed from a save flips here


## Standalone default, used when the scene runs on its own (screenshots, quick checks): two
## chained packs of the first faction in content. RIFTGATE_TEAM=badger,clydesdale,kite,baboon overrides the team;
## RIFTGATE_BOSS=1 adds the faction's boss as a third unit; RIFTGATE_COLUMNS=4 widens the formation.
static func _default_skirmish() -> Skirmish:
	var db := ContentDB.load_default()
	var s := Skirmish.new(7, int(OS.get_environment("RIFTGATE_COLUMNS")) if not OS.get_environment("RIFTGATE_COLUMNS").is_empty() else Skirmish.DEFAULT_COLUMNS)
	var team: Array = db.default_team()
	var env := OS.get_environment("RIFTGATE_TEAM")
	if not env.is_empty():
		team = env.split(",")
	# RIFTGATE_PAINT=badger:ff8800/223344,kite:ffffff repaints for a look (primary/secondary).
	var paints := {}
	for spec in OS.get_environment("RIFTGATE_PAINT").split(",", false):
		var kv := spec.split(":")
		if kv.size() == 2:
			var cols := kv[1].split("/")
			var pd := {"primary": Color(cols[0])}
			if cols.size() > 1:
				pd["secondary"] = Color(cols[1])
			paints[kv[0]] = pd
	for id in team:
		if db.chassis.has(id):
			var u := db.make_mech(id)
			if paints.has(id):
				u.paint = paints[id]
			s.add_mech(u)
	# RIFTGATE_TERRAIN=ruins puts the fight on that ground (BattleMap.TERRAIN_NAMES), for a look.
	var ground := OS.get_environment("RIFTGATE_TERRAIN")
	for t in BattleMap.TERRAIN_NAMES.keys():
		if BattleMap.TERRAIN_NAMES[t] == ground:
			s.terrain = int(t)
	# The first faction's first and last spawn entries: its rank and file, then its support.
	# RIFTGATE_FOES=warrior,goblin:3,cleric puts those foes on instead, by content id and
	# count (heroes included), each its own pack: to see any sprite in the fight.
	var fac := db.default_faction()
	var table: Array = db.spawn_table(fac, 1)   # the standalone fight is tier one
	var uid := 1
	var foes_env := OS.get_environment("RIFTGATE_FOES")
	if not foes_env.is_empty():
		table = []
		for spec in foes_env.split(",", false):
			var kv := spec.split(":")
			if db.foes.has(kv[0]):
				table.append([kv[0], int(kv[1]) if kv.size() > 1 else 1])
		for entry in table:
			var fid := str(entry[0])
			var sq := Unit.pack(uid, "%s pack" % fid, Vector2i.ZERO, db.faction_of_foe(fid), 2, int(entry[1]), fid)
			s.add_foes(db.foes_for(sq), sq)
			uid += 1
		table = []
	for entry in [table[0], table[table.size() - 1]] if not table.is_empty() else []:
		var sq := Unit.pack(uid, "%s pack" % str(entry[0]), Vector2i.ZERO, fac, 2, int(entry[1]), str(entry[0]))
		s.add_foes(db.foes_for(sq), sq)
		uid += 1
	if OS.get_environment("RIFTGATE_BOSS") == "1":
		var boss := db.make_boss(uid, fac)
		s.add_foes(db.foes_for(boss), boss)
	return s


# ---------------------------------------------------------------- build

func _build() -> void:
	for c in get_children():
		if c != _menu:   # the menu outlives a rebuild it asked for (a colour change)
			c.queue_free()
	_slot_views = [[], []]
	for rank in range(2):
		_slot_views[rank].resize(sk.columns)
		_slot_views[rank].fill(null)
	_massive_views = []
	_massive_views.resize(sk.columns)
	_massive_views.fill(null)
	_twin_views = [[], []]
	for rank in range(2):
		_twin_views[rank].resize(sk.columns)
		_twin_views[rank].fill(null)
	_mech_views.clear()
	_mech_3d.clear()
	_dice.clear()
	_home.clear()
	_live_tweens.clear()
	_log_full = null
	H = Hud.screen_height(self)
	for key in ROWS.keys():
		set(key, float(ROWS[key]) * H / BASE_H)
	if controls() == "bottom":
		for key in ROWS_BOTTOM.keys():
			set(key, float(ROWS_BOTTOM[key]) * H / BASE_H)
		# The machines' row rests on the log, so a taller glass gives its height to the field and
		# the machines stand further from the foes, rather than black over the log (Ryan, 29
		# October: "extra black space above that doesn't need to be there").
		MECH_Y = LOG_Y - MECH_SIZE.y - MECH_LOG_GAP - CHIP_ROOM
	_cam = _field_camera()
	custom_minimum_size = Vector2(W, H)
	Hud.inset_screen(self)   # clear of the phone's corners, cutout and gesture zone
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR   # text linear; the ground bands and the sprites pin nearest on themselves

	var bg := HudBackdrop.new()
	_lay_ground(bg)
	bg.scan = bool(Settings.display["scan"])   # off: no band, and the machines' traces rest as ink
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_bg = bg
	set_process(true)

	# Header: round and reinforcements tag, phase readout beside it.
	_header = _tag("", 13, true)
	_place(_header, Vector2(12, 14), Vector2(300, 28))
	_sub_label = Hud.label("", 12, Color(Palette.HUD, 0.7), Hud.mono())
	_place(_sub_label, Vector2(326, 20), Vector2(160, 20))
	# The music ticker fills the rest of the bar up to MENU (Ryan, 25 September).
	_place(MusicTicker.new(), Vector2(486, 20), Vector2(W - 108 - 486, 20))
	# The intent eye sits right under the formation, at the right edge of the log's black
	# (Ryan, 23 September: off the ground band): toggled often, so it stays within a thumb's
	# reach of the foes it concerns. The log strip stops short of it.
	var menu_btn := HudButton.new("MENU", _open_menu)
	menu_btn.sound = ""   # the menu's own breaker is the sound
	menu_btn.hit_pad = Vector2(12.0, 10.0)   # answers over the whole bar's height and out to the edge
	_place(menu_btn, Vector2(W - 96, 10), Vector2(84, 34))
	_eye = HudButton.new("")
	_eye.glyph = "eye"
	_eye.slant_px = 0.0
	_eye.toggle_mode = true
	_eye.set_pressed_no_signal(show_all_arrows)   # a screen laid again (the controls moved) keeps it as it was
	_eye.tooltip_text = "Show every intent arrow"
	_eye.toggled.connect(_toggle_all_arrows)
	_place(_eye, Vector2(W - 12 - EYE, EYE_Y), Vector2(EYE, EYE))
	# The controls' quick switch (Ryan, 29 October: "a quick-switch that changes the control layout
	# position"), beside the eye: the controls to the bottom or back to the middle, saved as the
	# menu's Skirmish Controls is. Its glyph shows where they sit and which way a press moves them.
	_switch = HudButton.new("", _switch_controls)
	_switch.glyph = "controls_" + controls()
	_switch.slant_px = 0.0
	_switch.tooltip_text = "Move the controls to the bottom" if controls() == "middle" else "Move the controls to the middle"
	_place(_switch, Vector2(W - 12 - EYE * 2.0 - 8.0, EYE_Y), Vector2(EYE, EYE))

	# Formation: six slot views, three massive views (hidden until needed). Ranks need no
	# label; the back rank is the one behind.
	for col in range(sk.columns):
		for rank in range(2):
			var v := UnitView.new()
			v.is_enemy = true
			var y := FRONT_Y if rank == 0 else BACK_Y
			_stand(v, y, SLOT_SIZE.y)
			v.empty_pad = true
			v.chip_wrap = _chip_wrap(_rank_x(rank, col))   # a foe's chips wrap at its column, wider than its drawing
			_place(v, Vector2(_rank_x(rank, col) - SLOT_SIZE.x * 0.5, y), SLOT_SIZE)
			v.held.connect(_on_foe_held.bind(v))
			v.double_tapped.connect(_on_foe_double_tapped.bind(v))
			v.tapped.connect(_on_foe_tapped.bind(v, rank, col))
			_slot_views[rank][col] = v
			# A twin slot's right-hand half (26 October): the slot's right half while the pair
			# stands, the left half's view taking the other.
			var tv := UnitView.new()
			tv.is_enemy = true
			_stand(tv, y, SLOT_SIZE.y)
			tv.visible = false
			_place(tv, Vector2(_rank_x(rank, col), y), Vector2(SLOT_SIZE.x * 0.5, SLOT_SIZE.y))
			tv.held.connect(_on_foe_held.bind(tv))
			tv.double_tapped.connect(_on_foe_double_tapped.bind(tv))
			tv.tapped.connect(_on_foe_tapped.bind(tv, rank, col, true))
			_twin_views[rank][col] = tv
		var mv := UnitView.new()
		mv.is_enemy = true
		mv.massive = true
		_stand(mv, BACK_Y, MASSIVE_SIZE.y)
		mv.visible = false
		mv.chip_wrap = _col_pitch() - 6.0
		_place(mv, Vector2(_col_x(col) - MASSIVE_SIZE.x * 0.5, BACK_Y), MASSIVE_SIZE)
		mv.held.connect(_on_foe_held.bind(mv))
		mv.double_tapped.connect(_on_foe_double_tapped.bind(mv))
		mv.tapped.connect(_on_foe_tapped.bind(mv, -1, col))
		_massive_views[col] = mv
	_pair_marks = PairMarks.new()
	_place(_pair_marks, Vector2.ZERO, Vector2(W, H))
	# The corrupted side's tear, over the foes and their ground alike (Ryan, 23 September:
	# under the sprites it was lost): a screen-reading layer the size of the foes' ground.
	var tear := TearLayer.new()
	tear.clock = bg.time
	var foes_ground := _foes_ground()
	tear.position = foes_ground.position
	tear.size = foes_ground.size
	add_child(tear)
	# The predator sense (the funnel-web, 18 October): the foes' ground and the foes on it
	# dim while an ambusher's die is read or dragged, and the foes looking away get their eyes.
	_prey = PreyLayer.new()
	_prey.position = tear.position
	_prey.size = tear.size
	add_child(_prey)

	# Log between the formation and the dice: every line at full strength, scrolled to
	# the end whenever something happens; drag to read back, double-tap for it full screen
	# (Ryan, 22 September: the strip alone was too little to follow a round).
	var log_tag := _tag("LOG", 10, true)
	_place(log_tag, Vector2(12, LOG_Y), Vector2(52, 18))
	_log_scroll = _log_scroller()
	_log_scroll.tooltip_text = "Drag to read back; double-tap to expand"
	_place(_log_scroll, Vector2(20, LOG_Y + 22), Vector2(W - 60 - EYE * 2.0, LOG_H - 22))
	_log = _log_label(14)
	_log_scroll.add_child(_log)

	# Dice in the middle, each centred on its mech's spot.
	var n := sk.mechs.size()
	for i in range(n):
		var cx := _slot_x(_mech_slot(i))
		var d := DieFaceView.new()
		_place(d, Vector2(cx - DIE_SIZE * 0.5, DIE_Y), DieFaceView.view_size())
		# A tap reads the die once the double-tap window has passed, so a double-tap, which locks,
		# never flashes the readout open (Ryan, 30 October: "Yeah, agreed to all"); the face lights
		# from the touch so the beat never reads as lag. A hold locks too.
		d.confirm_taps = true
		d.tapped.connect(_on_die_tapped.bind(i))
		d.double_tapped.connect(_toggle_lock.bind(i))
		d.held.connect(_toggle_lock.bind(i))
		d.drag_started.connect(_on_drag_started.bind(i))
		d.drag_moved.connect(_on_drag_moved)
		d.drag_ended.connect(_on_drag_ended)
		_dice.append(d)

	# Reroll: one wide button centred right under the dice, the dice's own control. Far from
	# End turn, so a thumb going for one cannot land on the other.
	_reroll_btn = HudButton.new("REROLL", _on_reroll)
	_reroll_btn.sound = ""   # the reroll is its own figure
	_reroll_btn.glyph = "reroll"
	_reroll_btn.font_size = 20
	_reroll_btn.badge_size = 20
	_reroll_btn.center_text = true
	_reroll_btn.tooltip_text = "A reroll never shows the same component twice."
	_place(_reroll_btn, Vector2(W * 0.5 - REROLL_SIZE.x * 0.5, REROLL_Y), REROLL_SIZE)

	# Mechs: each on its hex of the floor, drawn by the floor's camera, gauges above, chips under.
	for i in range(n):
		var cx := _slot_x(_mech_slot(i))
		var hex_x := _slot_hex_x(_mech_slot(i))
		var ms: Skirmish.MechState = sk.mechs[i]
		var v := UnitView.new()
		v.display_name = ms.unit.display_name
		v.bars_above = true
		var db := ContentDB.load_default()
		var fill := MECH_FILL * float(MechView3D.SIZE_FILL.get(str(db.chassis.get(ms.unit.chassis_id, {}).get("size", "")), 1.0))   # the team in proportion
		var flies := ms.unit.traits.has("flyer")
		v.ground_shadow = true
		v.ground_at = Vector2(MECH_SIZE.x * 0.5, MECH_FOOT)
		v.shadow_rx = fill * PITCH * (0.4 if flies else 0.5)
		v.shadow_ratio = (_cam.row - _cam.horizon) / _cam.focal
		# Mechs are 3D (decided 16 September); headless (and RIFTGATE_MECH3D=off) draws the
		# placeholder shape. A chassis with no model uses the Badger's.
		var look := MechView3D.look_setting()
		_mech_3d.append(null)
		if not look.is_empty():
			var maker := db.maker_of(ms.unit.chassis_id)
			var window := Rect2(Vector2(cx - MECH_SIZE.x * 0.5, MECH_Y) + MECH_WINDOW.position, MECH_WINDOW.size)
			var lift := FLYER_LIFT if flies else (HOVER_LIFT if ms.unit.traits.has("hover") else 0.0)
			var view := MechView3D.make_on_floor(ms.unit.chassis_id, maker, look, {
				"focal": _cam.focal, "height": _cam.height, "principal": Vector2(W * 0.5, _cam.horizon),
				"at": Vector2(hex_x, _cam.depth), "window": window, "fill": fill, "lift": lift,
				"turn": _mech_turn(i),
			}, ms.unit.paint, MechView3D.plan_for(ms.unit, db))
			view.set_sheen(MechView3D.SHEEN_SKIRMISH)   # the rear pose needs more to shine like the codex
			view.pivots = flies or ms.unit.traits.has("hover")   # aims by turning its whole body
			v.sprite_at = MECH_WINDOW
			# Idle: an aircraft hovers, a hover chassis skims, a ground machine stands still
			# (its idle is limb movement, which waits on annotated joints).
			if ms.unit.traits.has("flyer"):
				view.sway = true
				view.sway_bob = 1.4
				view.sway_yaw = 0.06
			elif ms.unit.traits.has("hover"):
				# A hovercraft balances on its cushion as the currents shift it, every way at
				# once (Ryan, 5 October: not the flyers' bob; a platform on the water).
				view.sway = true
				view.sway_bob = 1.0
				view.sway_yaw = 0.04
				view.balance = HoverBalance.new(i + 1)
			view.sway_phase = i * 2.1
			# Hug the model by its framed bounds, never the render read back. The view frames
			# its camera on ready, so the bounds are taken then: connected before add_child,
			# because when the screen is already in the tree ready fires inside it.
			view.ready.connect(func() -> void:
				v.used_override = view.model_rect()
				v.queue_redraw())
			add_child(view)
			_mech_3d[i] = view
			v.sprite = view.texture
			v.sprite_density = view.density
			if look == "clean":
				v.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_place(v, Vector2(cx - MECH_SIZE.x * 0.5, MECH_Y), MECH_SIZE)
		v.held.connect(_on_mech_held.bind(i))
		v.tapped.connect(_on_mech_tapped.bind(i))
		v.double_tapped.connect(_on_mech_double_tapped.bind(i))
		_mech_views.append(v)

	# Bottom row: End turn bottom-left, Undo bottom-right, as the map's two are. There is no
	# withdrawal (the long wall brief 3.5 and 7.5): a fight ends in the pack's fall or the
	# machines' wreck, so no button pulls out of one, and Undo has its corner (Ryan, 9 November:
	# "with withdraw gone from skirmish, there's a lot of free real estate down there. Undo at least
	# should move there"), far from Reroll, whose draw it can never take back.
	_end_btn = HudButton.new("END TURN", _on_end_turn)
	_end_btn.sound = ""   # the lever is the sound
	_end_btn.filled = true
	_place(_end_btn, Vector2(16, BOTTOM_Y), BOTTOM_BTN)
	# Undo (Ryan, 2 November: "undo to your last roll"): its badge says how many spends it reaches,
	# and whether it can be pressed reads by structure (HudButton.state_marked).
	_undo_btn = HudButton.new("UNDO", _on_undo)
	_undo_btn.sound = ""   # the undo plays its own dismiss
	_undo_btn.state_marked = true
	_undo_btn.font_size = 20
	_undo_btn.badge_size = 20
	_undo_btn.tooltip_text = "Take back the last spend, back to the last roll."
	_place(_undo_btn, Vector2(W - 16.0 - BOTTOM_BTN.x, BOTTOM_Y), BOTTOM_BTN)

	# While the enemy's turn replays, nothing on the screen takes a tap.
	_replay_shade = Control.new()
	_replay_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_replay_shade.visible = false
	_replay_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_replay_shade)
	# The plaque sits over the foes' rows and above everything but the menu; it places
	# itself on each announcement, since its width is its name's.
	_plaque = Plaque.new()
	_plaque.px = 4.0 * H / BASE_H
	add_child(_plaque)

	# The display reading the fight: every few seconds one brief analysis event on a random
	# unit or die (brackets and a meter, a telemetry box, a tear, a recalculation).
	_fx = FeedFX.new()
	_fx.foe_views = _live_foe_views
	_fx.mech_views = _live_mech_views
	_fx.dice = _live_dice
	_fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fx)

	# Overlays: arrows, drag ghost, details, codex, confirm, outcome.
	_arrows = ArrowLayer.new()
	_arrows.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_arrows)
	_ghost = DieFaceView.new()
	_ghost.animate = false
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.drag_started.connect(_on_ghost_drag_started)
	_ghost.drag_moved.connect(_on_drag_moved)
	_ghost.drag_ended.connect(_on_drag_ended)
	_ghost.tapped.connect(_on_ghost_tapped)
	_ghost.held.connect(_on_ghost_held)
	_ghost.modulate = Color.WHITE   # solid: with its slot emptied, this is the die itself
	_ghost.visible = false
	_place(_ghost, Vector2.ZERO, DieFaceView.view_size())

	_details = HudPanel.new(14.0)
	_details.fill_alpha = 1.0   # the log's lines sit behind it; a readout of text reads over nothing
	# An open readout takes every tap that lands on it (Ryan, 2 November: "i managed to reroll when
	# trying to click a keyword on a unit popup since it was underneath. Popups intuitively should
	# prevent triggering things behind them, even other popup triggers"): a term opens its tip, and
	# a tap anywhere else on it does nothing, never reaching a button, a die or a unit beneath.
	_details.mouse_filter = Control.MOUSE_FILTER_STOP
	_details.visible = false
	_details.custom_minimum_size = Vector2(340, 0)
	add_child(_details)
	var dv := VBoxContainer.new()
	dv.add_theme_constant_override("separation", 8)
	dv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_details.add_child(dv)
	_details_label = Hud.label("", 16, Palette.INK)
	dv.add_child(_details_label)
	_details_ring = CylinderView.new()
	_details_ring.visible = false
	_details_ring.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	dv.add_child(_details_ring)
	_details_entry = EntryReadout.new()
	_details_entry.visible = false
	dv.add_child(_details_entry)

	_build_codex()
	_build_confirm()
	_build_outcome()
	_build_log_full()
	if _menu != null:
		_menu.move_to_front()


## Where the controls sit (Settings.SKIRMISH_CONTROLS): the environment's, else the setting.
static func controls() -> String:
	var env := OS.get_environment("RIFTGATE_SKIRMISH_CONTROLS")
	if Settings.SKIRMISH_CONTROLS.has(env):
		return env
	var v := str(Settings.display.get("skirmish_controls", "middle"))
	return v if Settings.SKIRMISH_CONTROLS.has(v) else "middle"


## The foes' ground: from above the back rank to the log, or with the controls at the bottom to
## the machines.
func _foes_ground() -> Rect2:
	var top := BACK_Y - 14.0
	var bottom := (MECH_Y + 4.0) if controls() == "bottom" else (LOG_Y - 10.0)
	return Rect2(0.0, top, W, bottom - top)


## The floor's camera (the field, above), for the rows as laid: the horizon a little above the
## back rank's feet, the machines' hex row MECH_FOOT into theirs. focal in design pixels,
## height and depth (to the machines' row) in hexes, shift the lattice's offset in depth so a
## row of hex centres runs through the machines' feet: the half-offset row (centres at x = n +
## 1/2) for an even number of spots, the other for an odd one.
func _field_camera() -> Dictionary:
	var horizon := BACK_Y + SLOT_SIZE.y * 0.38
	var row := MECH_Y + MECH_FOOT
	var d := row - horizon
	var focal := d / tan(deg_to_rad(FIELD_THETA))
	var depth := focal / PITCH
	var half := 0.5 if _slot_count() % 2 == 0 else 0.0
	var shift := depth - (roundf(depth / sqrt(3.0) - half) + half) * sqrt(3.0)
	return {"horizon": horizon, "row": row, "focal": focal, "height": d / PITCH, "depth": depth, "shift": shift}


## A point on the floor (x across, z deep, in hexes) on the screen.
func _on_floor(x: float, z: float) -> Vector2:
	return Vector2(W * 0.5 + _cam.focal * x / z, _cam.horizon + _cam.focal * _cam.height / z)


## The squad's spots: SLOTS, or more for a bigger squad.
func _slot_count() -> int:
	return maxi(SLOTS, sk.mechs.size())


## The spot machine `i` stands in: a squad of one or two in the middle hexes, the outer ones
## left empty (Ryan, 29 October), a squad of three from the left.
func _mech_slot(i: int) -> int:
	return i + floori((_slot_count() - sk.mechs.size()) * 0.5)


## How far machine `i` turns from facing the foes, toward the middle (Ryan, 29 October: "player
## units on the left side can face slightly to the right, and units on the right can face
## slightly left"): MechView3D's turn, positive to the machine's left.
func _mech_turn(i: int) -> float:
	return signf(_slot_hex_x(_mech_slot(i))) * FIELD_TURN


## A spot's place across the floor, in hexes from the middle, and on the screen.
func _slot_hex_x(i: int) -> float:
	return float(i) - float(_slot_count() - 1) * 0.5


func _slot_x(i: int) -> float:
	return W * 0.5 + _slot_hex_x(i) * PITCH


## A foe's view stands on its rank's feet line (or a massive one's), its shadow flattened as
## the floor is there.
func _stand(v: UnitView, top: float, tall: float) -> void:
	v.ground_shadow = true
	v.feet_y = tall - UnitView.STATUS_H
	v.shadow_ratio = clampf((top + v.feet_y - _cam.horizon) / _cam.focal, 0.14, 0.6)


## The field (the const block above): the other world's backdrop over the whole of it, our floor
## laid over that below its seam (under the console's glass in the middle, at the machines'
## backs at the bottom), the rules at its edges and the squad's hexes marked, an empty spot's
## dashed.
func _lay_ground(bg: HudBackdrop) -> void:
	var bottom := controls() == "bottom"
	var foes := _foes_ground()
	var end := (LOG_Y - 10.0) if bottom else (BOTTOM_Y - 16.0)
	var field := Rect2(0.0, foes.position.y, W, end - foes.position.y)
	var camera := {"horizon": _cam.horizon - field.position.y, "focal": _cam.focal, "height": _cam.height, "shift": _cam.shift}
	var backdrop := camera.duplicate()
	backdrop.merge({"biome": _biome(), "dim": 0.9})
	var floor := camera.duplicate()
	floor.merge({"seam": (foes.end.y if bottom else (LOG_Y + DIE_Y) * 0.5) - field.position.y, "seam_band": 34.0, "grid": 0.14, "grid_fade": 220.0})
	bg.grounds = [[field, sk.terrain, sk.rng.seed, "backdrop", backdrop], [field, sk.terrain, sk.rng.seed + 1, "floor", floor]]
	bg.rules = [field.position.y, field.end.y]
	if not bottom:
		# The console floats on the floor: dark glass under the log and under the dice.
		bg.glass = [Rect2(0.0, LOG_Y - 6.0, W, LOG_H + 6.0), Rect2(0.0, DIE_Y - 12.0, W, REROLL_Y + REROLL_SIZE.y + 12.0 - (DIE_Y - 12.0))]
	var r := 1.0 / sqrt(3.0)
	var corners := [Vector2(0.0, r), Vector2(0.5, r * 0.5), Vector2(0.5, -r * 0.5), Vector2(0.0, -r), Vector2(-0.5, -r * 0.5), Vector2(-0.5, r * 0.5)]
	bg.marks = []
	var first := _mech_slot(0)
	for i in range(_slot_count()):
		var pts := PackedVector2Array()
		for c in corners:
			pts.append(_on_floor(_slot_hex_x(i) + c.x, _cam.depth + c.y))
		bg.marks.append([pts, i < first or i >= first + sk.mechs.size()])


## The fight's domain, by its bleed in content: the domain most of the foes come from.
func _biome() -> String:
	var db := ContentDB.load_default()
	var count := {}
	for f in sk.field_foes() + sk.reinforcements:
		var fac := db.faction_of_foe(str(f.content_id))
		if not fac.is_empty():
			count[fac] = int(count.get(fac, 0)) + 1
	var best := db.default_faction()
	for fac in count.keys():
		if int(count[fac]) > int(count.get(best, 0)):
			best = fac
	return str(db.factions.get(best, {}).get("bleed", ""))


## A log body: bbcode, sized by its content, filling its scroller's width.
func _log_label(size_px: int) -> RichTextLabel:
	var l := RichTextLabel.new()
	l.bbcode_enabled = true
	l.fit_content = true
	l.scroll_active = false
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_override("normal_font", Hud.mono())
	l.add_theme_font_size_override("normal_font_size", size_px)
	l.add_theme_color_override("default_color", Palette.HUD)
	return l


## The log full screen: the whole fight so far in a bigger face, on a shade. A tap on the
## shade, a double-tap on the text, or CLOSE puts it away.
func _build_log_full() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.visible = false
	shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			_toggle_log_full())
	add_child(shade)
	_log_full = shade
	var panel := HudPanel.new(18.0)
	panel.position = Vector2(16, 40)
	panel.size = Vector2(W - 32, H - 80)
	shade.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	var head := _tag("LOG // EVERY EVENT", 12, true)
	head.custom_minimum_size = Vector2(220, 26)
	head.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(head)
	_log_full_scroll = _log_scroller()
	_log_full_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_log_full_scroll)
	_log_full_text = _log_label(18)
	_log_full_scroll.add_child(_log_full_text)
	var close := HudButton.new("CLOSE", _toggle_log_full)
	close.sound = "ui_back"
	close.custom_minimum_size = Vector2(0, 52)
	col.add_child(close)


## Two taps within the double-tap window on either log switch the full screen one.
func _on_log_input(e: InputEvent) -> void:
	if not (e is InputEventMouseButton) or e.button_index != MOUSE_BUTTON_LEFT or e.pressed:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - _log_tap_at <= UnitView.DOUBLE_TAP_SECONDS:
		_log_tap_at = -10.0
		_toggle_log_full()
	else:
		_log_tap_at = now


func _toggle_log_full() -> void:
	if _log_full == null:
		return
	_log_full.visible = not _log_full.visible
	if _log_full.visible:
		_log_full_text.text = _log_text()
		_scroll_to_end(_log_full_scroll)


func _build_codex() -> void:
	# Codex: a double-tap opens it; a tap anywhere outside closes it (`CodexBox`).
	_codex = CodexBox.new()
	add_child(_codex)


func _build_confirm() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.6)
	_confirm_shade = shade
	_confirm_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirm_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_confirm_shade.visible = false
	_confirm_shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			_hide_confirm())
	add_child(_confirm_shade)
	_confirm = HudPanel.new(22.0)
	_confirm.custom_minimum_size = Vector2(520, 0)
	_confirm.visible = false
	_place(_confirm, Vector2(100, 560), Vector2(520, 0))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	_confirm.add_child(v)
	_confirm_text = Hud.label("", 20, Palette.INK)
	_confirm_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	_confirm_text.custom_minimum_size = Vector2(470, 0)
	v.add_child(_confirm_text)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	v.add_child(row)
	var no := HudButton.new("NO", _hide_confirm)
	no.sound = "ui_back"
	no.custom_minimum_size = Vector2(0, 54)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(no)
	var yes := HudButton.new("YES", _confirm_yes)
	yes.sound = "confirm"
	yes.filled = true
	yes.custom_minimum_size = Vector2(0, 54)
	yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(yes)


func _build_outcome() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.72)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	add_child(_overlay)
	var oc := CenterContainer.new()
	oc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(oc)
	var op := HudPanel.new(28.0)
	oc.add_child(op)
	var ov := VBoxContainer.new()
	ov.add_theme_constant_override("separation", 14)
	op.add_child(ov)
	_overlay_title = Hud.label("", 44, Palette.HUD, Hud.display_bold())
	_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ov.add_child(_overlay_title)
	_overlay_text = Hud.label("", 18, Palette.MUTED)
	_overlay_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	_overlay_text.custom_minimum_size = Vector2(420, 0)
	ov.add_child(_overlay_text)
	var back := HudButton.new(back_label, func() -> void: back_requested.emit())
	back.sound = "ui_back"
	back.custom_minimum_size = Vector2(0, 54)
	ov.add_child(back)


## Enemy column centres: three columns at a wide pitch, four at a tight one. A massive foe stands
## here, filling both ranks of its column.
func _col_x(col: int) -> float:
	return W * 0.5 + (col - (sk.columns - 1) * 0.5) * _col_pitch()


## How far each rank stands off its column's centre: the front rank a little to the left and the
## back a little to the right (Ryan, 9 November: "the lines should come from the intent chip, and
## always from the intent chip's middle. A slight offset or squeezing would fix the rest, whether
## that's moving the front rank, back rank, or both"), so one column's two foes aiming at the
## machine below draw a narrow V from their intent chips, never one line, the back's passing clear
## of the front's intent chip. Both ranks move, so the parting is twice what either rank gives up;
## a squeeze would part the outer columns and barely the inner, where the pitch is narrowest.
const RANK_SHIFT := 18.0


## A foe's slot centre across the screen: its column's, its rank's slight shift off it.
func _rank_x(rank: int, col: int) -> float:
	return _col_x(col) + (-1.0 if rank == 0 else 1.0) * RANK_SHIFT


## How wide a foe's chip rows run before they wrap, for a view centred at `x`: its column's pitch
## less the gap between two columns' rows; an outer view the shift moved toward the screen's edge
## (the front rank's first, the back rank's last) loses only what its rows would hang past the glass,
## so a full row, held on the screen, keeps the same gap to its neighbour's as every other (Ryan, 9
## November: "What happens to back rank enemies with a lot of chips if they're that close to the
## right edge?").
func _chip_wrap(x: float) -> float:
	var w := _col_pitch() - 6.0
	var over := maxf(maxf(0.0, x + w * 0.5 - (W - 2.0)), maxf(0.0, 2.0 - (x - w * 0.5)))
	return w - over


## The formation's columns apart.
func _col_pitch() -> float:
	var n := sk.columns
	return 210.0 if n <= 3 else minf(176.0, (W - 16.0) / n)


func _place(c: Control, pos: Vector2, sz: Vector2) -> void:
	c.position = pos
	c.size = sz
	_home[c] = pos
	add_child(c)


## A filled, non-interactive readout tag such as "RND 01 // POOL 02".
func _tag(text: String, size_px: int, mono: bool) -> HudButton:
	var t := HudButton.new(text)
	t.filled = true
	t.mono = mono
	t.font_size = size_px
	t.slant_px = 8.0
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


# ---------------------------------------------------------------- refresh

func _refresh(save: bool = true) -> void:
	var assigning := sk.state == Skirmish.State.ASSIGN
	_update_preview()
	_update_round()
	_header.text = "RND %02d // %s" % [sk.round, ContentDB.load_default().term_name(sk.ground).to_upper()]
	_header.queue_redraw()
	_set_phase("ASSIGN" if assigning else "ENEMY PHASE")
	_view_foe.clear()

	var targets: Array[Foe] = []
	var support: Array[Skirmish.MechState] = []   # the machines a dragged shield, vent or buff may land on
	var seconds: Array = []   # a pending Swap's second targets: foes and empty slots (Vector2i)
	if not _pending.is_empty():
		seconds = sk.swap_targets(_pending["primary"])
		for x in seconds:
			if x is Foe:
				targets.append(x)
	elif _drag_from >= 0:
		var dm: Skirmish.MechState = sk.mechs[_drag_from]
		var f := sk.spend_face(dm)   # the charged form when it goes out charged
		if f != null and f.is_attack():
			targets = sk.targets_for_face(dm, f)
			# A sweep targets a rank (Ryan, 3 November: "fix the UI for sweep so its intuitively
			# targeting a rank"): over a foe, the rank it stands in is the target, lit whole and
			# bracketed (below), the other rank plain until the finger moves there.
			if sk.reach_of(dm, f) == Face.Reach.SWEEP and _drag_over is Foe:
				var swept_rank := sk.sweep_rank_of(_drag_over)
				targets = targets.filter(func(foe: Foe) -> bool: return sk.sweep_rank_of(foe) == swept_rank)
		elif f != null and f.on_machines():
			support = sk.machine_targets_for(dm, Effects.effective_face(dm.unit, f))

	var pairs: Array = []   # [left view, right view, left foe, right foe]: the twin slots shown this refresh
	for col in range(sk.columns):
		var front_foe := sk.foe_at(0, col)
		var massive := front_foe != null and front_foe.is_massive()
		var mv: UnitView = _massive_views[col]
		mv.visible = massive
		if massive:
			_fill_foe_view(mv, front_foe, targets, col)
			_view_foe[mv] = front_foe
		for rank in range(2):
			var v: UnitView = _slot_views[rank][col]
			v.visible = not massive
			var tv: UnitView = _twin_views[rank][col]
			var foe := sk.foe_at(rank, col)
			var twin: Foe = sk.twins.get(Vector2i(rank, col), null) if not massive and foe != null else null
			# A twin slot (the Gel's pair, 26 October): the left half's view takes the slot's left
			# half and the right half's view the other, each foe its own target; a plain slot is
			# one view across the whole.
			var at := Vector2(_rank_x(rank, col) - SLOT_SIZE.x * 0.5, FRONT_Y if rank == 0 else BACK_Y)
			if twin != null:
				_half_sides[foe] = 0
				_half_sides[twin] = 1
				_lay(v, at, Vector2(SLOT_SIZE.x * 0.5, SLOT_SIZE.y))
				_lay(tv, at + Vector2(SLOT_SIZE.x * 0.5, 0.0), Vector2(SLOT_SIZE.x * 0.5, SLOT_SIZE.y))
				tv.visible = true
				tv.modulate = Color.WHITE
				_fill_foe_view(tv, twin, targets, rank * sk.columns + col + 11)
				_view_foe[tv] = twin
				pairs.append([v, tv, foe, twin])
			elif foe != null and not massive and is_half(foe):
				# A half alone keeps its half of the slot, on its side (Ryan, 2 November: "a half unit
				# should not take the full unit slot when it's other half dies, only when both are
				# vacated does it return to a full size slot"); its twin's half stands empty.
				tv.visible = false
				_lay(v, at + Vector2(SLOT_SIZE.x * 0.5 * int(_half_sides.get(foe, 0)), 0.0), Vector2(SLOT_SIZE.x * 0.5, SLOT_SIZE.y))
			else:
				tv.visible = false
				_lay(v, at, SLOT_SIZE)
			if massive:
				continue
			if foe == null and sk.corpses.has(Vector2i(rank, col)):
				# A fallen part its core will regrow holds its slot (Ryan, 7 November: "anything
				# that regrows should leave it's corpse in place, to make it clear"): drawn as it
				# fell, dimmed and greyed, saying when it regrows; no target.
				var corpse: Foe = sk.corpses[Vector2i(rank, col)]
				_fill_foe_view(v, corpse, [], rank * sk.columns + col)
				v.dead = true
				v.intent = _regrow_text(corpse)
				v.intent_kind = ""
				v.highlight = false
				v.modulate = Color(1, 1, 1, 0.7)
				v.queue_redraw()
				continue
			if foe == null:
				# An empty slot.
				v.display_name = ""
				v.bars = []
				v.intent = ""
				v.intent_kind = ""
				v.statuses = []
				# A slot a pending Swap may move its foe into.
				v.highlight = seconds.has(Vector2i(rank, col))
				v.dead = false
				v.sprite = null
				_settle(v)   # a hit still playing on the foe that stood here would end at full brightness
				v.modulate = Color(1, 1, 1, 0.75 if v.highlight else 0.3)
				v.queue_redraw()
				continue
			v.modulate = Color.WHITE
			_fill_foe_view(v, foe, targets, rank * sk.columns + col)
			_view_foe[v] = foe

	# An area weapon in hand reads a twin slot as one: one bracket round the pair, never two,
	# whichever half it lands on behind the scenes.
	var marks: Array = []
	if _drag_from >= 0:
		var dm: Skirmish.MechState = sk.mechs[_drag_from]
		var df := sk.spend_face(dm)
		for p in pairs:
			var lv: UnitView = p[0]
			var rv: UnitView = p[1]
			if df == null or not df.is_attack() or not (lv.highlight and rv.highlight):
				continue
			var ef := Effects.effective_face(dm.unit, df, p[2])
			if not (ef.has_area() or ef.reaches_all):
				continue
			lv.highlight = false
			rv.highlight = false
			lv.queue_redraw()
			rv.queue_redraw()
			var a := lv.drawing_rect()
			var b := rv.drawing_rect()
			marks.append(Rect2(_home.get(lv, lv.position) + a.position, a.size).merge(Rect2(_home.get(rv, rv.position) + b.position, b.size)).grow(6.0))
	# A sweep's rank, bracketed whole while the die is over a foe in it (3 November): the strikes
	# walk the rank, so the rank is what the drop picks, one bracket round it as round a twin
	# slot's pair, its foes' own marks off so the rank reads as one target.
	if _drag_from >= 0 and _drag_over is Foe:
		var sm: Skirmish.MechState = sk.mechs[_drag_from]
		var sf := sk.spend_face(sm)
		if sf != null and sf.is_attack() and sk.reach_of(sm, sf) == Face.Reach.SWEEP:
			var swept_rank := sk.sweep_rank_of(_drag_over)
			var whole := Rect2()
			var any := false
			for v in _view_foe.keys():
				var foe: Foe = _view_foe[v]
				if not foe.alive() or sk.sweep_rank_of(foe) != swept_rank:
					continue
				var uv: UnitView = v
				uv.highlight = false
				uv.queue_redraw()
				var vr: Rect2 = uv.drawing_rect()
				var r := Rect2(_home.get(v, uv.position) + vr.position, vr.size)
				whole = r if not any else whole.merge(r)
				any = true
			if any:
				marks.append(whole.grow(6.0))
	if _pair_marks != null:
		_pair_marks.set_rects(marks)

	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		var v := _mech_views[i]
		# The forecast counts this die's own heat only while it is being dragged: shown
		# unasked, it read as something done to the mech rather than by the player.
		var fc: Dictionary = _forecast_for(i) if assigning and ms.alive() else {}
		# Shield above hull: it is what the enemy meets first, and it drops first.
		v.bars = [
			[ms.unit.shield, ms.unit.shield_max, Palette.SHIELD, fc.get("shield_after", ms.unit.shield)],
			[ms.unit.hull, ms.unit.hull_max, Palette.HULL, fc.get("hull_after", ms.unit.hull)],
			[ms.heat, ms.heat_max, Palette.HEAT, fc.get("heat_after", ms.heat)],
		]
		if _shown_gauges.has(i):
			# A last act on its way: the gauges hold what they were until it lands.
			var held: Array = _shown_gauges[i]
			v.bars[0] = [int(held[0]), ms.unit.shield_max, Palette.SHIELD, int(held[0])]
			v.bars[1] = [int(held[1]), ms.unit.hull_max, Palette.HULL, int(held[1])]
		# The Muster (the Swallowtail's, 21 October): a filling gauge under the heat, a notch a
		# charge, the points it holds against its cap.
		var rule := Effects.muster_rule(ms.unit)
		if not rule.is_empty():
			var per := maxi(1, int(rule.get("value", 30)))
			var held := Effects.stacks_of(ms.unit, "muster")
			v.bars.append([held, per * maxi(1, int(rule.get("cap", 3))), Palette.SELECT, held, per])
		# The magazine (the Musk Ox's, 21 October): a bar under the heat, a notch an ammo, the
		# dragged gun's price pending on it.
		if ms.ammo_max > 0:
			var after := ms.ammo
			if _drag_from == i and ms.face() != null:
				after = maxi(0, ms.ammo - sk.ammo_price_of(ms, sk.spend_face(ms)))
			v.bars.append([ms.ammo, ms.ammo_max, Palette.SELECT, after, 1])
		v.dead = not ms.alive()
		# What the model holds while the machine carries a status (the Polar Bear's seal, the
		# Cassowary's spin), and its numbers on its count displays (the Cassowary's capacitor).
		if i < _mech_3d.size() and _mech_3d[i] != null:
			_mech_3d[i].hold_statuses(ms.unit)
			_mech_3d[i].show_counts(ms)
		if not SEAL_DEBUG:
			v.shell = ms.alive() and Effects.is_sealed(ms.unit)   # the sealed form's shell (the Polar Bear's, 2 November)
		v.away = Skirmish.is_swallowed(ms)   # a foe's swallow (30 October): out of the fight, a ghost of itself
		# The sixth shot's count as pips under the heat bar (Ryan, 19 October: the best spot).
		var every := Effects.counts_shots(ms.unit)
		v.pips = [Effects.stacks_of(ms.unit, "shots"), every] if every > 0 else []
		# A capped store as a bar under the heat (Ryan, 21 and 22 October: every store a bar;
		# 10 November: in the heat bar's shape, a segment a stack up to its cap), in its chip's
		# colour and place. A store a charged piece spends in chunks (the Nemesis's rage, Ryan, 11
		# November: "a smooth resource bar like the swallowtail") fills as the Muster does, a
		# notch a chunk, the dragged piece's price pending on it.
		v.store = []
		var chunks := charge_chunks(ms)
		for id in Effects.STATUS.keys():
			var cap := Effects.store_cap(ms.unit, str(id)) if (Effects.STATUS[id].get("tags", []) as Array).has("store") else 0
			if cap <= 0:
				continue
			var held := Effects.banked(ms.unit, str(id))
			if chunks.has(str(id)):
				var after := held
				if _drag_from == i and sk.charge_lands(ms) and ms.face().charge_store() == str(id):
					after = maxi(0, held - ms.face().charge_price())
				v.bars.append([held, cap, _chip_colour(str(id)), after, int(chunks[str(id)])])
				continue
			v.store = [held, cap, _chip_colour(str(id)), status_glyph(str(id))]
			break
		v.highlight = support.has(ms)
		v.statuses = []
		for r in _mech_rows(i):
			v.statuses.append([r[0], r[1], r[3], r[4] if r.size() > 4 else "status", r[5] if r.size() > 5 else ""])
		v.queue_refresh()
		var d := _dice[i]
		# A locked piece goes out charged whenever a muster pays and it has somewhere to land
		# (the Swallowtail's, Ryan, 22 October): the die shows the form that will happen.
		d.charged = not ms.assigned and sk.charge_lands(ms)
		var sf := sk.shown_face(ms, sk.spend_face(ms))   # reach as the passive reads it now, the charged form when it goes out charged
		d.set_face(sf, sk.shown_number_text(ms, sf))   # and the number the blow will deal
		d.blast = sk.blast_number(ms, sk.blast_amount(ms, sf, ms)) if not ms.assigned and ms.alive() else 0   # a vent's blast on its own machine
		d.after_blow = -1   # the blow its passive adds after the strikes, as the entry carries it (no foe in hand)
		d.form_mark = form_mark(ms, sf) if not ms.assigned and ms.alive() else ""   # it seals its machine or opens it
		d.corrupted = Effects.corrupt_stacks(ms.unit, ms.face_index) if ms.face_index >= 0 else 0
		# A dark entry shows the rounds it has left, this one included (the cooldown row).
		d.dark = Effects.dark_rounds(ms.unit, ms.face_index, sk.round) if sf != null and sf.disabled else 0
		d.cooldown = sk.cooldown_of(ms, sf)   # the rounds a spend darkens it, its passives in: a cost along its foot
		d.next_face = sk.next_face(ms) if ms.alive() else null   # a stepping die's next chamber
		if d.next_face == null and ms.alive():
			d.next_face = sk.turn_face(ms)   # the entry a one-of-each die turns to once this is spent (the Needletail's), when one stands
		d.next_number = sk.shown_number_text(ms, d.next_face) if d.next_face != null and d.next_face.is_weapon() else ""   # its blow as it would deal it now
		d.slot = ms.face_index + 1   # its place on the die: a reroll onto a copy shows by it
		d.spent = ms.assigned
		d.dead = not ms.alive()
		d.locked = locked[i]
		d.can_tap = ms.alive() and _pending.get("mech", -1) != i   # a tap reads the die, spent too; the pending one's is its ghost's
		d.can_drag = assigning and ms.alive() and not ms.assigned and _pending.get("mech", -1) != i
		# While a die is dragged, the one under the finger is the die: its slot goes empty
		# (Ryan, 26 September: a copy dragged beside the original read as a copy). Modulate,
		# not visible: the view must keep receiving the drag's motion.
		d.modulate = Color(1, 1, 1, 0.0) if _drag_from == i or _pending.get("mech", -1) == i else Color.WHITE
		d.queue_redraw()

	_refresh_log()
	_reroll_btn.badge = "×%d" % sk.rerolls_left
	_reroll_btn.set_enabled(assigning and sk.can_reroll() and not _reroll_indices().is_empty())
	_refresh_undo()
	_end_btn.set_enabled(assigning)
	# Nothing left to spend, rerolls aside: END TURN is the next thing to press (Ryan, 25 October).
	var left := false
	for i in range(sk.mechs.size()):
		left = left or sk.can_spend(i)
	_end_btn.set_pulse(assigning and not left)
	_show_pop()
	_refresh_arrows()
	_refresh_prey()
	if save and autosave.is_valid():
		autosave.call()


## The round preview a machine's gauges and warnings read now (_update_round): the round as it
## stands, the dragged die's own spend counted over the foe under the finger, the lure's turn
## while a die in hand would turn foes. Empty for a wreck or outside the player's turn.
func _forecast_for(i: int) -> Dictionary:
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive() or sk.state != Skirmish.State.ASSIGN:
		return {}
	var all: Array = _round.get("mechs", [])
	return all[i] if i < all.size() else {}


## The lure preview (the Whip Scorpion's Siphon, 22 October): while a die whose entry Lures is
## dragged over a foe it may be spent on, or read or dragged anywhere when it reaches every foe,
## the foes it would turn draw their arrows dashed to its machine, and the round preview reads the
## round as the lure would leave it (_update_round): the lured blows, the brace, the heat a
## Siphon drinks from them.
func _update_preview() -> void:
	_turns = []
	if sk.state != Skirmish.State.ASSIGN or not _pending.is_empty():
		return
	var i := _drag_from if _drag_from >= 0 else _read_die()
	if i < 0 or i >= sk.mechs.size():
		return
	var ms: Skirmish.MechState = sk.mechs[i]
	var aimed: Foe = _drag_over if _drag_from >= 0 and _drag_over is Foe else null
	_turns = sk.lure_turns(ms, aimed)


## The round preview for this refresh (Skirmish.preview_round; Ryan, 26 October: it accounts for
## everything that will happen but chance and the player's own choices, and "Die faces only apply
## to the preview when hovered over a valid target"): the die in hand counts dragged over somewhere
## it may be spent, or read or dragged anywhere when its Lure reaches every foe (any foe it turns
## is its target, its pieces dealing no damage). While a Swap waits on its second target the round
## as it stands, the die uncounted (the audit's Bug 16: the gauges fell back to the bot's estimate
## there, which knows no coming chips, no next-in-line pick and no last act).
func _update_round() -> void:
	_round = {}
	if sk.state != Skirmish.State.ASSIGN:
		return
	var hm := -1
	var ht = null
	if _drag_from >= 0 and _drag_over != null:
		hm = _drag_from
		ht = _drag_over
	elif not _turns.is_empty():
		hm = _drag_from if _drag_from >= 0 else _read_die()
		ht = _turns[0]
	_round = sk.preview_round(hm, ht)


func _refresh_log() -> void:
	var fresh_lines := sk.log.size() > _log_seen
	_log.text = _log_text(true)   # every line at full; the new ones type in

	# New lines type in, so the eye is drawn to what just happened, and the strip scrolls
	# to them; a strip the player scrolled back stays put until something new happens.
	if fresh_lines and is_inside_tree():
		var total := _log.get_total_character_count()
		var fresh := PROMPT.length()   # the cursor line comes last, after the new lines
		for j in range(_log_seen, sk.log.size()):
			fresh += sk.log[j].length() + 3
		_log.visible_characters = maxi(0, total - fresh)
		_log_typing = true
		var tw := create_tween()
		tw.tween_property(_log, "visible_characters", total, minf(0.6, 0.012 * fresh))
		tw.tween_callback(func() -> void:
			_log.visible_characters = -1
			_log_typing = false)
	if fresh_lines or _log_seen == 0:
		_scroll_to_end(_log_scroll)
	if _log_full != null and _log_full.visible and fresh_lines:
		_log_full_text.text = _log_text()
		_scroll_to_end(_log_full_scroll)
	_log_seen = sk.log.size()


const PROMPT := "> _"   # the strip's last line: a terminal prompt whose cursor blinks (_process)

## The whole log as bbcode, one line per event, every line at full strength (Ryan, 9 November:
## "don't fade out the log text in the skirmish log"), a roll's bar where a draw was made, dimmer,
## under the lines (Ryan, 2 November: "undo to your last roll"; the round's roll, a reroll, a spend
## that drew), which is where the undo stops. `prompt` adds the cursor line at the end (the strip;
## never the full-screen log).
func _log_text(prompt: bool = false) -> String:
	var n := sk.log.size()
	var out := ""
	if n == 0:
		out = "[color=#%s]> round %d // awaiting orders[/color]\n" % [Color(Palette.HUD, 0.45).to_html(true), sk.round]
	for j in range(n + 1):
		if sk.roll_marks.has(j):
			out += "[color=#%s]%s[/color]\n" % [Color(Palette.HUD, 0.6).to_html(true), ROLL_BAR]   # a bar sits under the lines
		if j < n:
			out += "[color=#%s]> %s[/color]\n" % [Color(Palette.HUD, 1.0).to_html(true), sk.log[j]]
	if prompt:
		out += "[color=#%s]%s[/color]" % [Color(Palette.HUD, 0.8).to_html(true), PROMPT]
	return out


## Scroll a log to its last line once the new text has been laid out: the label sizes
## itself on its next process and the scroller sorts a frame after, so keep pushing to the
## end for a few frames rather than guessing which one.
func _scroll_to_end(sc: ScrollContainer) -> void:
	if sc == null or not is_inside_tree():
		return
	for k in range(3):
		await get_tree().process_frame
		if not is_instance_valid(sc) or not sc.is_inside_tree():
			return
		sc.scroll_vertical = int(sc.get_v_scroll_bar().max_value)


## A scroller in the overlay style: a thin track in the HUD colour, no arrows.
func _log_scroller() -> ScrollContainer:
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	sc.gui_input.connect(_on_log_input)
	var bar := sc.get_v_scroll_bar()
	var track := StyleBoxFlat.new()
	track.bg_color = Color(Palette.HUD, 0.12)
	track.content_margin_left = 2.0
	track.content_margin_right = 2.0
	var grab := StyleBoxFlat.new()
	grab.bg_color = Color(Palette.HUD, 0.7)
	var grab_hi := StyleBoxFlat.new()
	grab_hi.bg_color = Palette.HUD
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("grabber", grab)
	bar.add_theme_stylebox_override("grabber_highlight", grab_hi)
	bar.add_theme_stylebox_override("grabber_pressed", grab_hi)
	bar.custom_minimum_size = Vector2(8, 0)
	return sc


func _fill_foe_view(v: UnitView, foe: Foe, targets: Array[Foe], slot: int = 0) -> void:
	v.display_name = foe.display_name
	v.sprite = Sprites.combat_foe(foe.content_id)
	v.pixel_snap = true
	# Enemies face left, the convention; a sprite painted facing right says so in content.
	var entry: Dictionary = ContentDB.load_default().foes.get(foe.content_id, {})
	v.flip_h = bool(entry.get("flip", false))
	v.hover = WINGED_LIFT if bool(entry.get("winged", false)) else 0.0   # what flies floats over its shadow
	v.breathe = true
	# Breathing spread by slot at the golden angle, so no two neighbours are near in phase
	# (Ryan, 23 September: the instance-id phases read as in step).
	v.breathe_phase = slot * 2.39996 + 0.7
	# Its HP as the round will leave it (the round preview: its ticks, a heal, the die in hand over
	# it, its own self-destruct) pulses on its gauge as a machine's coming change does, a loss
	# dimming and lit, a heal hatched, the whole bar when it falls (Ryan, 26 October).
	var after := int(_round.get("foes", {}).get(foe, {}).get("hp", foe.hp)) if foe.alive() else foe.hp
	v.bars = [[foe.hp, foe.hp_max, Palette.HUD, after]]
	if _shown_hp.has(foe):
		# A spend's blows still landing: the gauge shows what they have left so far, no forecast.
		v.bars = [[int(_shown_hp[foe]), foe.hp_max, Palette.HUD, int(_shown_hp[foe])]]
	v.dead = not foe.alive()
	v.highlight = targets.has(foe)
	v.intent = ""
	v.intent_dim = false
	# The intent is this round's chosen attack: a sword, its damage, and a mark for a double
	# strike or a breach; a suppressed foe shows no intent, only the status; a dead one
	# threatens nothing.
	v.intent_kind = "" if (foe.is_suppressed() or foe.target == null or not foe.alive()) else Foe.kind_of(foe.action)
	# A move still gathering (a countdown) shows the blow it will land; its rounds are a chip.
	var read := _intent_read(foe)   # the readout's chip is _intent_chip's, the same read
	v.intent_value = read[0]
	v.intent_note = read[1]
	v.intent_riders = read[2]
	v.statuses = []
	for r in _foe_rows(foe):
		v.statuses.append([r[0], r[1], r[3], r[4] if r.size() > 4 else "status", r[5] if r.size() > 5 else ""])
	v.queue_redraw()


## Whether `foe` is one half of a pair (the Gel's), shown at half a slot even alone: a half this
## screen has shown in a pair, or, with none remembered (a resumed fight), a foe content stands up
## as a pair's half.
func is_half(foe: Foe) -> bool:
	if foe == null:
		return false
	if _half_sides.has(foe):
		return true
	return pair_halves().has(foe.content_id)


static var _pair_halves: Dictionary = {}

## The foes a split stands up as a pair, by content id (a foe whose `on_death` names a pair).
static func pair_halves() -> Dictionary:
	if _pair_halves.is_empty():
		var db := ContentDB.load_default()
		for id in db.foes.keys():
			var od = (db.foes[id] as Dictionary).get("on_death", {})
			if od is Dictionary and bool(od.get("pair", false)) and not str(od.get("summon", "")).is_empty():
				_pair_halves[str(od["summon"])] = true
	return _pair_halves


## The stores this machine's charged pieces spend in chunks (the Nemesis's rage since 11 November):
## store -> its price, the largest when two pieces differ; the Muster draws its own gauge.
static func charge_chunks(ms: Skirmish.MechState) -> Dictionary:
	var out := {}
	if ms == null or ms.unit == null or ms.unit.die == null:
		return out
	for f in ms.unit.die.faces:
		if f != null and not f.charged.is_empty() and f.charge_store() != "muster":
			out[f.charge_store()] = maxi(int(out.get(f.charge_store(), 0)), f.charge_price())
	return out


## Whether spending entry `f` changes its machine's form (Ryan, 2 November: "armadillo needs
## indication when a die face will transform it"): "seal" for a buff it may spend on itself while
## its shell is open (the Polar Bear's Lockdown seals it so), "unseal" for a weapon while it is
## sealed (it opens it), "" for anything else or a machine with no form.
static func form_mark(ms: Skirmish.MechState, f: Face) -> String:
	match Skirmish.form_change(ms, f, f != null and f.targets != Face.Target.ALLY):
		"seal":
			return "seal"
		"open":
			return "unseal"
	return ""


## The riders of a foe's blow, inside its intent chip after its number (Ryan, 2 November: "Enemy
## intents with a rider need to show that rider as part of the intent chip"): each keyword its
## move carries by its term's mark in its term's colour (Terms), a numbered one with its stacks
## (Scorch 2: two), so a breach, a scorch or a blow at every machine is read off the chip itself.
static func intent_riders(foe: Foe) -> Array:
	var out: Array = []
	if foe == null or not Foe.is_attack_action(foe.action):
		return out
	for k in foe.action.get("keywords", []):
		var id := str(k)
		if not Terms.has(id) or Terms.glyph(id).is_empty():
			continue
		out.append([Terms.glyph(id), str(foe.rider(foe.action, id)) if Foe.NUMBERED_RIDERS.has(id) else "", Terms.colour(id)])
	return out


## A foe's abilities (Ryan, 8 November: "Nob, and any other enemies with a passive ability, should
## have an unpurgable passive chip that points out what's going on ... It's not a Buff, it's not
## a Debuff, it's labelled as an Ability"), each its glyph on a solid tile, its readout naming it
## an Ability and saying what goes on, since the chip is the rule it plays by: the Nob's rage, a
## core's guard while its parts stand, a split, a last act and a golden rage while it lasts. No
## Purge reaches any of them.
func _foe_abilities(foe: Foe) -> Array:
	var rows: Array = []
	if foe.rage > 0:
		rows.append(["overcharge", "", "Ability, Enrage: every shield, vent or equipment you spend makes it Enraged +%d" % foe.rage, _foe_chip_colour("enraged"), "ability"])
	if Effects.has(foe, "guarded"):
		# A boss in parts (15 October): the lock while its parts stand, so the zero its die
		# shows has a reason on the foe itself.
		rows.append(["lock", "", "Ability, Guarded: no damage while its parts stand", _foe_chip_colour("guarded"), "ability"])
	if foe.on_death.has("summon"):
		rows.append(["splits", "", "Ability: it splits in two when it falls", Palette.ENEMY, "ability"])
	if not foe.last_act().is_empty():
		# A last act (15 October): the skull and what it lands the moment the foe falls.
		var la := foe.last_act()
		rows.append(["skull", str(foe.damage_of(la)), "Ability, Last Act: %s, %d%s" % [str(la.get("name", "")), foe.damage_of(la), " at Every Machine" if Array(la.get("keywords", [])).has("all") else ""], Palette.ENEMY, "ability"])
	if Effects.has(foe, "golden"):
		# A golden rage (4 November): the add it carries, the rounds left and the damage that
		# breaks it, so burst-or-shield reads off the chip.
		var gold := Effects.golden_value(foe)
		var rounds_left := sk.golden_rounds_left(foe)
		rows.append(["overcharge", "+%d" % gold, "Ability, Golden +%d, %d round%s, %d more damage breaks it" % [gold, rounds_left, "" if rounds_left == 1 else "s", Skirmish.golden_left(foe)], _foe_chip_colour("golden"), "ability"])
	if ABILITY_DEBUG and rows.is_empty():
		rows.append(["overcharge", "", "Ability, Enrage (RIFTGATE_ABILITY_DEBUG)", _foe_chip_colour("enraged"), "ability"])
	return rows


## Statuses on a foe as [glyph, chip text, readout text, colour], and a fifth "preview" for one
## on its way. The readout text is the chip's name and count, never what it does (Ryan, 2 November:
## "unit popups don't need the chips descriptions spelled out now that we can tap keywords"): its
## term opens its meaning on a tap, and only what the chip cannot say is added (the move a last act
## or a countdown lands, the neighbour a web catches, the machine a swallow holds).
func _foe_rows(foe: Foe) -> Array:
	var rows: Array = []
	# A fall the round will bring (the round preview; Ryan, 26 October: "It should get a destroyed
	# chip same as the player to indicate incoming death"): the machines' skull, its intent kept,
	# since its line still matters to what reads it.
	# A kill it comes back from takes the skull's place (Ryan, 7 November: "a revive or a split
	# SHOULD be a preview chip that shows up, taking the place of a death chip"): the rising arrow
	# for a foe that gets back up and stands at the round's end, the fork for one whose halves
	# step up; a foe that rises and falls again keeps the skull.
	var fate: Dictionary = _round.get("foes", {}).get(foe, {})
	var returns := str(fate.get("returns", ""))
	if foe.alive() and returns == "rises" and bool(fate.get("alive", true)):
		rows.append(["rises", "", "Gets back up this round", _foe_chip_colour("risen"), "preview"])
	elif foe.alive() and returns == "splits":
		rows.append(["splits", "", "Splits this round", _foe_chip_colour("risen"), "preview"])
	elif foe.alive() and not fate.is_empty() and not bool(fate.get("alive", true)):
		rows.append(["skull", "", "Destroyed this round", Palette.LOSS, "preview"])
	rows.append_array(_foe_abilities(foe))
	if foe.burn_stacks() > 0:
		rows.append(status_row("burning", "burn", str(foe.burn_stacks()), "Burning ×%d" % foe.burn_stacks(), _foe_chip_colour("burning")))
	var vitriol := Effects.stacks_of(foe, "vitriol")
	if vitriol > 0:
		# The funnel-web's acid (18 October): its stacks, and the share they eat at its action.
		rows.append(status_row("vitriol", "vitriol", str(vitriol), "Vitriol ×%d" % vitriol, _foe_chip_colour("vitriol")))
	var flak := Effects.stacks_of(foe, "flakked")
	if flak > 0:
		# Wainwright & Sutler's on-hit (21 October): the count is the extra every blow of a
		# weapon it takes deals.
		rows.append(status_row("flakked", "flak", str(flak), "Flak ×%d" % flak, _foe_chip_colour("flakked")))
	var cryo := Effects.stacks_of(foe, "cryoed")
	if cryo > 0:
		# The Polar Bear's mark (20 October; its chip from 21 October): what a weapon's hit on it
		# cools the hitter, the stacks it spends.
		rows.append(status_row("cryoed", "cryo", str(cryo), "Cryo ×%d" % cryo, _foe_chip_colour("cryoed")))
	if Effects.has(foe, "webbed"):
		# The funnel-web's web (18 October): the chip points at the neighbour the burst catches
		# (> the right-hand one, which acts after it; < the left-hand one, which has acted).
		var caught := sk.web_catch(foe)
		var mark := "" if caught == null else (">" if caught.column > foe.column else "<")
		rows.append(status_row("webbed", "web", mark, "Webbed" + ("" if caught == null else ": bursts on %s too" % caught.display_name), _foe_chip_colour("webbed")))
	if foe.is_suppressed():
		rows.append(status_row("suppressed", "suppress", "", "Suppressed", _foe_chip_colour("suppressed")))
	var holding := sk.swallowed_by(foe) if foe.swallow_mark >= 0 else null
	if holding != null:
		# A swallow (30 October) and its release (31 October): the damage still to deal before it
		# lets its machine go, a quarter of its HP counted from the swallow.
		var left := Skirmish.swallow_left(foe)
		rows.append([status_glyph("swallowed"), str(left), "Swallow: holds %s, %d more damage frees it" % [holding.unit.display_name, left], Palette.ENEMY])
	if foe.gathering():
		# A countdown (15 October): the warning glyph and the rounds before it lands.
		var when := "next round" if foe.charge == 1 else "in %d rounds" % foe.charge
		rows.append(["warning", str(foe.charge), "Countdown: %s lands %s" % [str(foe.pending.get("name", "")), when], Palette.ENEMY])
	if foe.committed:
		# An announced follow-up (2 November): committed, so no Disrupt turns it; a Suppress still takes it.
		rows.append(["lock", "", "Committed Follow-up: %s" % str(foe.action.get("name", "")), Palette.ENEMY])
	if Effects.has(foe, "braced"):
		# Armoured, the machines' status (16 October; Braced until 18 October): their chip's
		# glyph, with the armour every grant adds (its own brace, a Protect).
		var arm := Effects.foe_armour_bonus(foe)
		rows.append(status_row("braced", status_glyph("braced"), "+%d" % arm, "%s +%d" % [Effects.STATUS["braced"]["name"], arm], _foe_chip_colour("braced")))
	if Effects.has(foe, "kindled"):
		var kindled := Effects.foe_attack_bonus(foe)
		rows.append(status_row("kindled", "overcharge", "+%d" % kindled, "Empowered +%d" % kindled, _foe_chip_colour("kindled")))
	var raged := Effects.stacks_of(foe, "enraged")
	if raged > 0:
		# What the Nob's rage has gathered (3 November), a buff a Purge lowers; the rage itself is
		# its ability (_foe_abilities).
		rows.append(status_row("enraged", "overcharge", "+%d" % raged, "Enraged +%d" % raged, _foe_chip_colour("enraged")))
	# A rally on its way (Ryan, 26 October: "a pulsing version of the incoming buff as a preview
	# chip, so the player knows it's incoming and that's the reason for the increased damage"):
	# the Empowered the rallies will land before its blow, already in the number its intent
	# shows. The chip pulses on a dashed edge until the rally lands, so it never reads as one
	# the foe carries by hue alone; a foe showing no blow wears none, its move gaining nothing.
	var coming := sk.incoming_rally(foe)
	var shows_blow := foe.alive() and not foe.is_suppressed() and foe.target != null and (foe.attacks() or foe.gathering())
	var rally_chip := shows_blow and coming > 0
	if shows_blow and (coming > 0 or PREVIEW_DEBUG):
		var who: Array[String] = []
		for r in sk.rallies_on(foe):
			who.append(r.display_name)
		var from := ", ".join(who) if not who.is_empty() else "nobody (RIFTGATE_PREVIEW_DEBUG)"
		rows.append(status_row("kindled", "overcharge", "+%d" % maxi(1, coming), "Empowered +%d on its way, from %s" % [maxi(1, coming), from], _foe_chip_colour("kindled"), "preview"))
	if Effects.has(foe, "risen"):
		rows.append(status_row("risen", "star", "", str(Effects.STATUS["risen"]["name"]), _foe_chip_colour("risen")))
	# The four buffs a foe's specials grant (28 October), on the machines' chips: Primed's lit
	# flame, the shield with its wall or its struck ring, the heart regrowing.
	var primed := Effects.stacks_of(foe, "primed")
	if primed > 0:
		rows.append(status_row("primed", _foe_glyph("primed"), "×%d" % primed, "Primed ×%d" % primed, _foe_chip_colour("primed")))
	if Effects.has(foe, "barrier"):
		rows.append(status_row("barrier", _foe_glyph("barrier"), "", "Barrier", _foe_chip_colour("barrier")))
	if Effects.has(foe, "ward"):
		rows.append(status_row("ward", _foe_glyph("ward"), "", "Ward", _foe_chip_colour("ward")))
	var regrow := Effects.regrowth(foe)
	if regrow > 0:
		var left := 0
		for m in Effects.live(foe):
			if m.id == "regenerating":
				left = maxi(left, m.stacks)
		rows.append(status_row("regenerating", _foe_glyph("regenerating"), "+%d" % regrow, "Regenerating +%d, %d action%s to go" % [regrow, left, "" if left == 1 else "s"], _foe_chip_colour("regenerating")))
	var paradox := Effects.stacks_of(foe, "paradox")
	if paradox > 0:
		var at := sk.paradox_count()
		rows.append(status_row("paradox", "paradox", "%d/%d" % [paradox, at] if at > 0 else str(paradox), "Paradox %d%s" % [paradox, " of %d" % at if at > 0 else ""], _foe_chip_colour("paradox")))
	if Effects.has(foe, "shocked"):
		rows.append(status_row("shocked", "shocked", "×2", "Shocked", _foe_chip_colour("shocked")))
	var numbed := Effects.stacks_of(foe, "numbed")
	if numbed > 0:
		rows.append(status_row("numbed", "numbed", "×%d" % numbed, "Numbed ×%d" % numbed, _foe_chip_colour("numbed")))
	var mine := Skirmish.mine_of(foe)
	if not mine.is_empty():
		# A Mine (the Lammergeier's Reverberant Payload, Ryan, 9 November: "the chip shows the damage
		# instead of the stacks, with the tooltip showing the riders"): the sea mine's glyph with its
		# damage, its readout its keywords and what its fall does.
		rows.append(status_row("mine", "mine", str(int(mine["damage"])), "%s; blows on every foe round its slot when it falls" % Skirmish.mine_text(mine), _foe_chip_colour("mine")))
	if Effects.has(foe, "exposure"):
		# Exposed, the debuff (21 October): the formation's reticle with its armour zeroed. The
		# chip is the debuff's alone: a back-rank foe with nothing in front wears none (Ryan, 26
		# October: a chip for it "steps on the debuff and is very confusing"); a dragged Direct
		# weapon lighting it says it is in reach.
		rows.append(status_row("exposure", "exposed", "0", "Exposed", _foe_chip_colour("exposure")))
	# Every status the round will land on it (Ryan, 26 October: "All incoming chips should appear
	# as pulsing opacity versions"): the copy's grants, each a chip pulsing on a dashed edge with
	# the stacks it gains, beside the skull when the round kills it, since one may be the cause.
	# A Empowered lifting this round's blow is the rally chip above; one landing after its move
	# (for the next round's) is a chip like any other.
	if foe.alive():
		rows.append_array(_coming_rows(fate.get("coming", {}), ["kindled"] if rally_chip else [], _foe_glyph, _foe_chip_colour))
	return rows


## A status's row, as the chips and the hold read it: [glyph, chip text, readout text, colour, kind,
## what it is to its unit]. The readout says what it is ahead of its name (Ryan, 9 November:
## "Buffs and debuffs ... need to be clearly labeled as such, so that it's clear what gets
## purged"), "Buff, Empowered +2" or "Debuff, Burning ×2" as an ability's says "Ability, ...", and
## the chip wears its mark by the same word (UnitView.draw_chip); one that is neither keeps its
## words and wears none (Effects.status_kind).
static func status_row(status_id: String, glyph: String, chip_text: String, text: String, colour: Color, kind: String = "status") -> Array:
	var what := Effects.status_kind(status_id)
	var said := text
	match what:
		"buff":
			said = "Buff, " + text
		"debuff":
			said = "Debuff, " + text
	return [glyph, chip_text, said, colour, kind, what if what == "buff" or what == "debuff" else ""]


## The preview chips for the statuses a round preview says a unit gains: one a status, its
## glyph and colour from the callables, the stacks gained its number (none for a status that
## renews), the readout the status's own words.
static func _coming_rows(coming: Dictionary, skip: Array, glyph_of: Callable, colour_of: Callable) -> Array:
	var rows: Array = []
	for id in coming.keys():
		if skip.has(id):
			continue
		var c: Dictionary = coming[id]
		var renews := Effects.STATUS.has(id) and Effects.status_stacking(Effects.STATUS[id]) == "renew"
		var text := "" if renews else "+%d" % int(c["stacks"])
		rows.append(status_row(str(id), glyph_of.call(id), text, "%s%s on its way" % [str(c["name"]), "" if text.is_empty() else " " + text], colour_of.call(id), "preview"))
	return rows


## The glyph a foe's status wears on its chip (the rows above name them inline).
static func _foe_glyph(id: String) -> String:
	match id:
		"burning":
			return "burn"
		"flakked":
			return "flak"
		"cryoed":
			return "cryo"
		"webbed":
			return "web"
		"suppressed":
			return "suppress"
		"guarded":
			return "lock"
		"braced":
			return "shield"
		"kindled":
			return "overcharge"
		"risen":
			return "star"
		"exposure":
			return "exposed"
		"vitriol", "paradox", "shocked", "numbed", "mine":
			return id
	return status_glyph(id)


## A foe's status's colour on its chip: its term's, by its group (Terms, the one table the die,
## the chips and the text read; Ryan, 30 October: "standardize the keyword colours").
static func _foe_chip_colour(id: String) -> Color:
	return Terms.status_colour(id)


## The glyph a machine's status wears on its chip.
static func status_glyph(id: String) -> String:
	if id.begins_with("corrupted"):
		return "corrupt"
	if id.begins_with("disabled"):
		return "blank"
	match id:
		"burning_mech":
			return "burning"
		"scorched":
			return "scorch"
		"overcharged":
			return "overcharge"
		"rage":
			return "rapid"
		"braced":
			return "shield"
		"primed":
			return "primed"
		"regenerating":
			return "regenerating"
		"retaliate":
			return "shocked"
		"hopper":
			return "hopper"
		"sealed":
			return "seal"   # the shell's mark, as the die's chip that seals it (2 November)
		"phased":
			return "phased"
		"swallowed":
			return "swallowed"
		"rallied":
			return "reroll"
		"barrier":
			return "barrier"
		"ward":
			return "ward"
		"spun_up":
			return "spin"
		"siphoning":
			return "heat"
		"silenced":
			return "silence"
		"cryoed":
			return "cryo"
	return "star"


## Statuses and warnings on a mech as [glyph, chip text, readout text, colour], the readout text
## the chip's name and count (as a foe's, _foe_rows). Warnings come from the forecast: what the
## end of the round does if nothing changes.
## A machine status's colour on its chip, or on a capped store's bar: its term's (Terms), the
## Nemesis's rage, a store the keywords list holds no term for, in heat's, and any other in ink,
## never the HUD colour (Ryan, 30 October: "Stay away from HUD colour").
static func _chip_colour(id: String) -> Color:
	if id == "rage":
		return Palette.HEAT
	return Terms.status_colour(id)


func _mech_rows(i: int) -> Array:
	var ms: Skirmish.MechState = sk.mechs[i]
	var rows: Array = []
	if not ms.alive():
		return rows
	if locked[i]:
		rows.append(["lock", "", "Die locked", Palette.HUD])
	if ms.free_rerolls > 0 and not ms.assigned and sk.state == Skirmish.State.ASSIGN:
		rows.append(["reroll", "×%d" % ms.free_rerolls, "Free reroll ×%d, this die alone" % ms.free_rerolls, Palette.HUD])
	var damaged := ms.unit.damaged_component_count()
	if damaged > 0:
		rows.append(["crack", str(damaged), "%d destroyed component%s" % [damaged, "" if damaged == 1 else "s"], Terms.colour("destroyed_component")])
	# An on_foe_status passive is live all fight, so it reads here as an active effect (Ryan,
	# 28 September); its count is the chip (the Paradox meter, 10 October).
	var meter := Effects.paradox(ms.unit)
	if meter[1] > 0:
		var loop_names: Array[String] = []
		for m in Effects.live(ms.unit):
			for eff in m.effects:
				if str(eff.get("trigger", "")) == "on_foe_status" and not loop_names.has(m.name):
					loop_names.append(m.name)
		rows.append(["paradox", str(meter[1]), "%s: Paradox at %d" % [", ".join(loop_names), meter[1]], Terms.colour("paradox")])
	# Every in-combat effect on the machine (Ryan, 26 September: the codex is the base state;
	# the fight's statuses live here, as chips that the hold expands into their descriptions),
	# and every status whatever its scope (Ryan, 16 October: the Ammit is Empowered, "so
	# anything that interacts with overcharged needs it displayed"): the talons' kills' stacks kept for
	# the battle are a chip like a buff's for the round. A chassis passive, a module's rule or
	# a battle reward that is no status stays in the codex.
	# One chip a status, counting its stacks from every grant: a timed buff spent in two rounds
	# is two modifiers, each going when its own rounds run out (16 October), and one status.
	var order: Array[String] = []
	var first := {}
	var total := {}
	for d in Effects.describe(ms.unit):
		var id := str(d[5])
		if int(d[3]) < Effects.SKIRMISH and not Effects.is_status(id):
			continue
		if id == "shots" or id == "quick_turned" or id == "muster" or Effects.store_cap(ms.unit, id) > 0:
			continue   # a count shows as pips under the heat bar (the Cassowary's sixth shot), a capped store as its bar, and the gate by the Rapid it grants, never a chip
		if not first.has(id):
			order.append(id)
			first[id] = d
			total[id] = 0
		total[id] = int(total[id]) + int(d[4])
	# An ability (Ryan, 8 November: "It's not a Buff, it's not a Debuff, it's labelled as an
	# Ability, so it doesn't get purged"): the machine's own mechanic, the Polar Bear's seal,
	# Hot Streak, on a solid tile and named so in its readout, ahead of the buffs.
	var abilities: Array = []
	var at := rows.size()
	for id in order:
		var d: Array = first[id]
		var glyph := status_glyph(id)
		var colour := _chip_colour(id)
		var stacks := int(total[id])
		var named := str(d[0]) + ((" ×%d" % stacks) if stacks > 1 else "")
		if Effects.is_ability(id):
			abilities.append([glyph, ("×%d" % stacks) if stacks > 1 else "", "Ability, " + named, colour, "ability"])
		else:
			rows.append(status_row(id, glyph, ("×%d" % stacks) if stacks > 1 else "", named, colour))
	if ABILITY_DEBUG and abilities.is_empty():
		abilities.append([status_glyph("sealed"), "", "Ability, Sealed (RIFTGATE_ABILITY_DEBUG)", _chip_colour("sealed"), "ability"])
	for k in range(abilities.size()):
		rows.insert(at + k, abilities[k])
	if sk.state == Skirmish.State.ASSIGN:
		var fc := _forecast_for(i)
		# Every warning is a prediction, so each pulses as the incoming chips do (Ryan, 26 October:
		# the skull "is just another predicted chip, like any other. It just symbolizes death").
		if int(fc["overheat"]) > 0:
			# The heat burns as the turn ends, so there is still time to vent.
			rows.append(["heat", "-%d" % int(fc["overheat"]), "Overheating: hull -%d at the turn's end" % int(fc["overheat"]), Palette.HEAT, "preview"])
		if bool(fc["destroyed"]):
			rows.append(["skull", "", "Wrecked this round: %d incoming" % int(fc["incoming"]), Palette.LOSS, "preview"])
		elif bool(fc["component_risk"]):
			rows.append(["crack", "!", "A component at risk", Palette.LOSS, "preview"])
		# The shield-break chip went on 26 October (Ryan: "It's clutter, the bar previews are more
		# than enough"). Every status the round will land on it (Ryan, 26 October: "All incoming
		# chips should appear as pulsing opacity versions"), beside the skull when the round wrecks
		# it (one may be the cause: a Burning it lit on itself), the counts and stores that are no
		# chip left out.
		var skip: Array = ["shots", "quick_turned", "muster"]
		for id in fc.get("coming", {}).keys():
			if Effects.store_cap(ms.unit, id) > 0:
				skip.append(id)
		rows.append_array(_coming_rows(fc.get("coming", {}), skip, status_glyph, _chip_colour))
	return rows


## A corpse's word: how many rounds its core needs to regrow it, by the core's schedule.
func _regrow_text(corpse: Foe) -> String:
	for core in sk.field_foes():
		if core.pack_id != corpse.pack_id or not core.part_ids.has(corpse.content_id):
			continue
		for d in core.regrow_due:
			if str(d[0]) == corpse.content_id:
				var n := maxi(1, int(d[1]) - sk.round + 1)
				return "REGROWS IN %d" % n
	return "REGROWS"


func _foe_view_for(foe: Foe) -> UnitView:
	for v in _view_foe.keys():
		if _view_foe[v] == foe:
			return v
	return null


func _refresh_arrows() -> void:
	var list: Array = []
	var inv := _arrows.get_global_transform().affine_inverse()
	# During a lure preview every blow its machine would take shows: the foes on it already
	# solid, the ones the lure would turn dashed (below).
	var lurer := (_drag_from if _drag_from >= 0 else _read_die()) if not _turns.is_empty() else -1
	for foe in sk.field_foes():
		# A foe on a special that acts on nobody in particular (a regrow, a rally) has no arrow:
		# its pick means nothing, and the ambush read says so too (Foe.intent_on, 18 October).
		if foe.target == null or foe.is_suppressed() or not foe.alive() or foe.acts_on_nobody():
			continue
		if _turns.has(foe):
			continue   # its arrow is the lure preview's, below
		# A blow at every machine (`all`) draws an arrow to each live machine.
		var targets: Array[int] = []
		if foe.reaches_every_machine():
			for i in range(sk.mechs.size()):
				if sk.mechs[i].alive():
					targets.append(i)
		else:
			var target_index := sk.mechs.find(foe.target)
			if target_index < 0:
				continue
			targets.append(target_index)
		# Its machine falls before it acts, as the round stands, and it strikes another (the round
		# preview, 26 October: the next machine in line): a second arrow, dashed
		# the way a lure's turn is drawn, to the machine its blow lands on. Its own stays solid on
		# its pick (Ryan, 26 October: a dashed arrow in its place "masks the true intent", which
		# whatever reads the intent still needs; "We either need to show both arrows, or ... just
		# preview the damage, not the target cascade").
		var fv := _foe_view_for(foe)
		if fv == null:
			continue
		var spill: Array[int] = []
		for i in _round.get("foes", {}).get(foe, {}).get("struck", []):
			if not targets.has(int(i)) and int(i) >= 0 and int(i) < _mech_views.size():
				spill.append(int(i))
		for target_index in targets + spill:
			var wanted: bool = show_all_arrows or _pop.get("foe") == foe or target_index == int(_pop.get("mech", -1)) or target_index == lurer
			if not wanted:
				continue
			var from: Vector2 = inv * fv.intent_anchor_global()
			var to: Vector2 = inv * _mech_views[target_index].anchor_global()
			list.append([from, to, Palette.ENEMY, true] if spill.has(target_index) else [from, to, Palette.ENEMY])
	# The lure preview: every foe the die in hand would turn, dashed to its machine, shown unasked;
	# one whose blow lands elsewhere as the round stands (the lurer falls before it acts, and it
	# picks again) dashes to that machine too, so the lure reads as worked and the blow as landing.
	if lurer >= 0 and lurer < _mech_views.size():
		for foe in _turns:
			var fv := _foe_view_for(foe)
			if fv == null:
				continue
			list.append([inv * fv.intent_anchor_global(), inv * _mech_views[lurer].anchor_global(), Palette.ENEMY, true])
			for i in _round.get("foes", {}).get(foe, {}).get("struck", []):
				if int(i) != lurer and int(i) >= 0 and int(i) < _mech_views.size():
					list.append([inv * fv.intent_anchor_global(), inv * _mech_views[int(i)].anchor_global(), Palette.ENEMY, true])
	_arrows.set_arrows(list)


## Readout over a control: a text block (a mined slot's), or lines (EntryReadout): a die's
## entry showing with its effects listed, a stepping die's cylinder above it, or a unit's
## gauges, chips and intent. `top` is where the control's drawing starts inside it (a
## machine's gauges), `gap` the air between the readout and that.
func _show_details(text: String, near: Control, ring: Array = [], entry: Array = [], top: float = 0.0, gap: float = 10.0) -> void:
	_details_label.text = text
	_details_label.visible = not text.is_empty()
	# A stepping die's cylinder above its entries: [faces, the chamber showing, the next].
	_details_ring.visible = not ring.is_empty()
	if not ring.is_empty():
		_details_ring.set_cylinder(ring[0], int(ring[1]), int(ring[2]))
	var width := 360.0
	# The readout's lines at the panel's content width, so their wrapping is measured at the
	# width they are drawn.
	_details_entry.visible = not entry.is_empty()
	if not entry.is_empty():
		width = EntryReadout.WIDTH + 28.0
		_details_entry.set_lines(entry, EntryReadout.WIDTH)
	_details.custom_minimum_size = Vector2(width, 0)
	_details.visible = true
	# Size from the children's minimums now, not from the last frame's layout: the first
	# open of a differently shaped readout used to keep the previous panel's height.
	var wanted := _details.get_combined_minimum_size()
	_details.size = Vector2(width, wanted.y)
	var height := wanted.y
	# Over the control, centred on it, whenever it fits: the thumb holding the thing covers
	# what is beside and below it (Ryan, 22 September). Only when there is no room above
	# (the back rank) does it sit beside.
	var pos := Vector2(near.position.x + near.size.x * 0.5 - width * 0.5, near.position.y + top - height - gap)
	if pos.y < 8.0:
		pos = near.position + Vector2(near.size.x + 8.0, 0)
		if pos.x + width > W - 8.0:
			pos.x = near.position.x - width - 8.0
	pos.x = clampf(pos.x, 8.0, W - width - 8.0)
	pos.y = clampf(pos.y, 8.0, H - 8.0 - height)
	_details.position = pos


# ---------------------------------------------------------------- gestures

## A tap on a die reads it, as a tap on a unit does (Ryan, 30 October: "change lock/unlock to
## hold and double-tap, and tap to inspect for dice ... That way it's standard across the
## board"): its readout opens, a tap on it again closes it, a tap on another die or unit moves it
## there. The readout stays open, so its terms take a tap too. A hold or a double-tap locks, and
## leaves the readouts as they stand. A tap lands a beat late, so one that lands as the enemy's
## turn replays, or under a codex opened meanwhile, is dropped.
func _on_die_tapped(i: int) -> void:
	if _replay_shade.visible or _codex.is_open():
		return
	if _pop == {"die": i}:
		_close_pop()
	else:
		_open_pop({"die": i})


## A die locked or unlocked, for the reroll to keep or roll: while the player assigns, a live die
## not yet spent.
func _toggle_lock(i: int) -> void:
	if sk.state != Skirmish.State.ASSIGN:
		return
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive() or ms.assigned:
		return
	locked[i] = not locked[i]
	Sound.play("die_lock" if locked[i] else "die_unlock")
	_refresh()


## What holds on die entry `i` now, for its readout: a cooldown with its turns left (Ryan, 26
## October: "On Cooldown (X turns left)"), a foe's switch-off, its corruption. A
## stepping die's next chamber is its cylinder's arrow.
func _entry_states(ms: Skirmish.MechState, i: int) -> Array:
	var out: Array = []
	if i < 0 or i >= ms.die.faces.size():
		return out
	var f: Face = ms.die.faces[i]
	if Effects.is_entry_disabled(ms.unit, i):
		# By the clock the die shows along its foot with the turns left (Ryan, 2 November).
		var dark := Effects.dark_rounds(ms.unit, i, sk.round)
		out.append([("Disabled" if Effects.cleansable_disable(ms.unit, i) else "On Cooldown") \
			+ (" (%d turn%s left)" % [dark, "" if dark == 1 else "s"] if dark > 0 else ""), EntryReadout.mark("cooldown", Palette.INK, false)])
	return out


## The marked states of die entry `i`, for its readout: its words and the mark the die shows for
## them (Ryan, 2 November: every icon on a die face in the popup), the corruption's chip and, on
## the die in hand, the lock.
func _entry_marks(ms: Skirmish.MechState, i: int, die: int) -> Array:
	var out: Array = []
	if die >= 0 and die < locked.size() and locked[die] and not ms.assigned:
		out.append(["Locked: a reroll skips it", EntryReadout.mark("lock", Palette.HUD, false)])
	var rot := Effects.corrupt_stacks(ms.unit, i) if i >= 0 else 0
	if rot > 0:
		out.append(["Corrupted" + (" ×%d" % rot if rot > 1 else ""), EntryReadout.mark("corrupt", Glyphs.colour_for("corrupt"))])
	return out


## The die's entries as the player should see them (effective reach), for lists.
func _shown_faces(ms: Skirmish.MechState) -> Array:
	var out: Array = []
	for f in ms.die.faces:
		out.append(sk.shown_face(ms, f))
	return out


## A die's readout over its place in the tray, as its machine stands now: false when there is
## nothing to read (a wreck's die).
func _show_die(i: int) -> bool:
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive():
		return false
	# The entry showing, alone (Ryan, 25 October: "only show the visible component"; 26
	# October: "it just turns the iconography into text"): its place and name, what holds on
	# it now, its codex, a line for each mark on the die, a number the live sources moved
	# highlighted, its own rules last, its tags (EntryReadout).
	# The whole die is the codex's, a double-tap on the machine. A die that steps (the
	# Cassowary's) shows its chambers as a cylinder above it: the one showing lit, an arrow
	# round to the next (Ryan's ring, 19 October).
	var ring: Array = [_shown_faces(ms), ms.face_index, sk.next_index(ms)] if Effects.steps_die(ms.unit) else []
	var at := ms.face_index
	var f: Face = ms.die.faces[at] if at >= 0 and at < ms.die.faces.size() else null
	var entry: Array = []
	if f != null:
		var sf := sk.shown_face(ms, f)
		var shown: int = sk.shown_number(ms, sf) if sf.is_attack() and not sf.is_debuff() else -1
		# A vent's blast (the Whip Scorpion's): the die prints it in its passive's box, so the readout
		# heads its line with that box (Ryan, 2 November: every icon on a die face in the popup).
		var extra: Array = []
		var blast := _dice[i].blast if i < _dice.size() else 0
		if blast > 0 and sf.kind == Face.Kind.VENT:
			extra.append(EntryReadout.marked(EntryReadout.parts_line("effect", [EntryReadout.word("Blasts a random foe for"), EntryReadout.word(str(blast))], "attr"), [EntryReadout.passive_mark("blast", str(blast), Palette.HEAT)]))
		# A stepping die's next chamber (the Cassowary's), by the passive box the die shows it in
		# (Ryan, 4 November: "should also explain its next-chamber chip in the tap popup").
		var next_at := sk.next_index(ms)
		if next_at >= 0:
			extra.append(EntryReadout.next_chamber_line(sk.next_face(ms), next_at + 1, ContentDB.load_default()))
		# The entry a one-of-each die turns to once this is spent (the Needletail's two things a
		# round), by the same box.
		var turn_at := sk.turn_index(ms)
		if next_at < 0 and turn_at >= 0:
			extra.append(EntryReadout.turn_line(sk.turn_face(ms), turn_at + 1, ContentDB.load_default()))
		# Its machine's form (the Polar Bear's): the seal or the opening this entry brings, by the
		# chip the die shows for it, Sealed a term a tap opens.
		var shift := form_mark(ms, sf) if not ms.assigned else ""
		if not shift.is_empty():
			var said := "Seals it, spent on itself: Sealed" if shift == "seal" else "Opens it, spent: Sealed goes"
			extra.append(EntryReadout.marked(EntryReadout.text_line("effect", said, "rule"), [EntryReadout.mark(shift, Glyphs.colour_for(shift))]))
		var states: Array = _entry_states(ms, at)
		states.append_array(_entry_marks(ms, at, i))
		entry = EntryReadout.lines_for(sf, at + 1, shown, f, states, Effects.printed_grants(ms.unit, f), ContentDB.load_default(), EntryReadout.face_types(sf, ms.unit), extra, sk.cooldown_of(ms, sf))
	if entry.is_empty() and ring.is_empty():
		return false
	_show_details("", _dice[i], ring, entry)
	return true


## A tap on a foe opens its readout, a tap on it again closes it, a
## tap on another unit moves it there and a tap on nothing closes it (Ryan, 29 October: "a tap
## toggle, only one unit popup allowed at a time"); a hold opens it too. While a Swap waits for
## its second target, the tap picks that instead.
func _on_foe_tapped(v: UnitView, rank: int, col: int, twin: bool = false) -> void:
	if not _pending.is_empty():
		if twin:
			_on_twin_tapped(rank, col)
		elif rank >= 0:
			_on_slot_tapped(rank, col)
		return
	var what := _pop_for(v)
	if what.is_empty() or what == _pop:
		_close_pop()
	else:
		_open_pop(what)


func _on_foe_held(v: UnitView) -> void:
	var what := _pop_for(v)
	if not what.is_empty() and what != _pop:
		_open_pop(what)


func _on_mech_tapped(i: int) -> void:
	if _pop == {"mech": i}:
		_close_pop()
	else:
		_open_pop({"mech": i})


func _on_mech_held(i: int) -> void:
	if _pop != {"mech": i}:
		_open_pop({"mech": i})


## What a foe's view would open: its foe, or nothing.
func _pop_for(v: UnitView) -> Dictionary:
	var foe: Foe = _view_foe.get(v, null)
	if foe != null:
		return {"foe": foe}
	return {}


func _open_pop(what: Dictionary) -> void:
	var die := _pop.has("die") or what.has("die")
	_pop = what
	Sound.play("hold")
	if die:
		_refresh(false)   # the marks and a lure's preview read the die whose readout is open, or let it go
	else:
		_show_pop()
		_refresh_arrows()


func _close_pop() -> void:
	if _pop.is_empty():
		return
	var die := _pop.has("die")
	_pop = {}
	_details.visible = false
	if die:
		_refresh(false)   # its marks and its lure's preview go with it
	else:
		_refresh_arrows()


## The die whose readout is open, or -1: the marks and the lure's preview read it as the die in
## hand, as they read a dragged one.
func _read_die() -> int:
	return int(_pop.get("die", -1))


## The open readout drawn again over its unit or its die as it stands now (after a blow, a swap,
## a reroll, a new round), a unit's translucent so the arrows it brings show under it; its unit
## gone, or its die's machine, it closes.
func _show_pop() -> void:
	if _pop.is_empty():
		return
	_details.fill_alpha = 1.0 if _pop.has("die") else POP_ALPHA   # a die's over the log's lines: a readout of text reads over nothing
	_details.queue_redraw()
	if _pop.has("die"):
		if not _show_die(int(_pop["die"])):
			_pop = {}   # the refresh that drew it lets the marks go
			_details.visible = false
	elif _pop.has("foe"):
		var foe: Foe = _pop["foe"]
		var v := _foe_view_for(foe)
		if v == null:
			_close_pop()
			return
		_show_details("", v, [], _foe_hold_lines(foe))
	elif _pop.has("mech"):
		var i: int = _pop["mech"]
		var mv: UnitView = _mech_views[i]
		_show_details("", mv, [], _mech_hold_lines(i), mv.drawn_top(), POP_GAP)


## A tap on nothing (the ground, the black) closes an open readout; with none open, it sets a
## waiting Swap back in the tray (Ryan, 30 October), so closing the die's readout never throws
## the Swap away.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not _pop.is_empty():
			_close_pop()
		elif not _pending.is_empty():
			_send_second_home()


## A machine's hold (Ryan, 26 October: "the hold press on an ally or enemy should follow a
## similar format as the hold press on the die, showing resource bars with numbers and
## modification up/downs if they exist, a list of all chips on the unit"): its name; its
## gauges with their numbers, a maximum anything moved off the chassis's coloured with its
## arrow; its armour and cooling as the codex's stats, the base with the change beside it
## ("Armour 2 (+1▲)"); then every chip on it and the round's warnings, each by its name and count,
## its term opening what it does on a tap (Ryan, 2 November).
func _mech_hold_lines(i: int) -> Array:
	var ms: Skirmish.MechState = sk.mechs[i]
	var u := ms.unit
	var out: Array = [_hold_title(u.display_name)]
	if not ms.alive():
		out.append({"style": "state", "text": "Wrecked: out for the rest of the battle", "parts": [], "place": ""})
		return out
	out.append(EntryReadout.bar_line("Shield", u.shield, u.shield_max, int(u.base["shield"]), Palette.SHIELD))
	out.append(EntryReadout.bar_line("Hull", u.hull, u.hull_max, int(u.base["hull"]), Palette.HULL))
	out.append(EntryReadout.bar_line("Heat", ms.heat, ms.heat_max, int(u.base["heat"]), Palette.HEAT))
	if ms.ammo_max > 0:
		out.append(EntryReadout.bar_line("Ammo", ms.ammo, ms.ammo_max, ms.ammo_max, Palette.SELECT))
	out.append(EntryReadout.parts_line("effect", _stat("Armour", int(u.base["armour"]), u.armour) + [EntryReadout.word("·")] + _stat("Cooling", int(u.base["cooling"]), u.cooling)))
	for r in _mech_rows(i):
		out.append(EntryReadout.chip_line(str(r[0]), r[3], str(r[2])))
	return out


## A foe's hold, the same way: its name, its HP, its armour and its attack against its own, the
## colour the foe's (Ryan, 26 October: "Positive and negative are always relative to the unit,
## not the player": a foe hitting harder is green and up), every chip on it, then its intent as
## the die's hold lists an entry (Ryan: "for enemies their current intent in the same format as
## the die hold press for a component"), the machine it is aimed at named.
func _foe_hold_lines(foe: Foe) -> Array:
	var db := ContentDB.load_default()
	var own: Dictionary = db.foes.get(foe.content_id, {})
	var out: Array = [_hold_title(foe.display_name)]
	if not foe.alive():
		out.append({"style": "state", "text": "Destroyed: cleared at the end of the round", "parts": [], "place": ""})
		return out
	out.append(EntryReadout.bar_line("HP", foe.hp, foe.hp_max, int(own.get("hp", foe.hp_max)), Palette.HUD))
	var stats: Array = _stat("Armour", foe.armour, foe.armour_total()) + [EntryReadout.word("·")] + _stat("Attack", foe.attack, foe.attack + Effects.foe_attack_bonus(foe))
	if foe.is_massive():
		stats.append_array([EntryReadout.word("·"), EntryReadout.word("Massive: fills the column")])
	out.append(EntryReadout.parts_line("effect", stats))
	for r in _foe_rows(foe):
		out.append(EntryReadout.chip_line(str(r[0]), r[3], str(r[2])))
	# A suppressed foe's intent clears here too (Ryan, 14 October): its Suppressed chip says what
	# it does this round, as the chip does under its sprite.
	if foe.is_suppressed() or foe.action.is_empty():
		return out
	var target := ""
	if foe.target != null and not foe.acts_on_nobody() and not foe.reaches_every_machine():
		target = foe.target.unit.display_name
	out.append({"style": "caption", "text": "INTENT", "parts": [], "place": ""})
	var move := EntryReadout.move_lines(foe, foe.action, db, true, target)
	move[0]["style"] = "name"
	move[0]["tags"] = ""
	# Its intent chip heads the move, as it stands under the foe, riders and all (Ryan, 2 November,
	# of the Cinder Tortoise's Withdraw: "a chip I don't recognize ... and more importantly it doesn't
	# show in the popup").
	var chip := _intent_chip(foe)
	if not chip.is_empty():
		EntryReadout.marked(move[0], [EntryReadout.chip_mark(chip)])
	out.append_array(move)
	return out


## A foe's intent chip as the field draws it ([glyph, text, Color, kind, riders], UnitView.draw_chip),
## or empty when it shows none: its move's kind, its blow (or a special's value) with its strikes,
## its riders.
func _intent_chip(foe: Foe) -> Array:
	if foe.is_suppressed() or foe.target == null or not foe.alive() or foe.action.is_empty():
		return []
	var read := _intent_read(foe)
	var value: int = read[0]
	return [Glyphs.intent_for(Foe.kind_of(foe.action)), (str(value) + str(read[1])) if value > 0 else "", Palette.ENEMY, "intent", read[2]]


## What a foe's intent says, read once for the field's chip and the readout's: [its number (the
## engine's, Skirmish.intent_value), the mark for more strikes than one, its riders]. A move that
## strikes, or is still gathering to, carries the mark and the riders; any other shows its number
## alone.
func _intent_read(foe: Foe) -> Array:
	var blow := foe.attacks() or foe.gathering()
	return [sk.intent_value(foe), ("×%d" % foe.strikes()) if blow and foe.strikes() > 1 else "", intent_riders(foe) if blow else []]


## A stat in a hold, as the codex has it: its label, its base in ink and the change in a
## bracket beside it, coloured for the unit with its arrow (ContentDB.stat_parts).
static func _stat(label: String, base: int, now: int) -> Array:
	return [EntryReadout.word(label)] + ContentDB.stat_parts(base, now)


## A unit hold's first line: its name, as the die's hold heads an entry.
static func _hold_title(name: String) -> Dictionary:
	return {"style": "title", "text": name.to_upper(), "parts": [], "place": ""}


func _on_foe_double_tapped(v: UnitView) -> void:
	var foe: Foe = _view_foe.get(v, null)
	if foe != null:
		_open_codex(ContentDB.load_default().codex_for_foe(foe))


func _on_mech_double_tapped(i: int) -> void:
	var ms: Skirmish.MechState = sk.mechs[i]
	var entry := ContentDB.load_default().codex_for_unit(ms.unit)
	entry["current"] = ms.face_index
	_open_codex(entry)


## Fill and show the codex (see `CodexBox` for the entry keys).
func _open_codex(entry: Dictionary) -> void:
	_close_pop()
	_codex.open(entry)


func _close_codex() -> void:
	_codex.close()


var _menu: PauseMenu = null

## The pause menu, on PAUSED from MENU.
func _open_menu() -> void:
	if _menu == null:
		_menu = PauseMenu.new()
		_menu.display_changed.connect(func(key: String, value: Variant) -> void:
			if key == "pace":
				BattleMapView.pace = float(value)
			elif key == "scan" and _bg != null:
				_bg.scan = bool(value)
			elif key == "weld" or key == "aa_mode" or key == "skirmish_controls":
				_build()   # the machines remade, welded or as authored (a debug build's comparison) or at another AA mode, or the controls moved
				_refresh())
		_menu.hud_changed.connect(func() -> void:
			_build()
			_refresh())
		_menu.quit_requested.connect(func() -> void: quit_requested.emit())
		add_child(_menu)
	_menu.move_to_front()
	_menu.open()


func _toggle_all_arrows(on: bool) -> void:
	show_all_arrows = on
	_refresh_arrows()


## The quick switch: the controls to the other place, saved as the menu's setting is, and the
## screen laid again around the fight as it stands.
func _switch_controls() -> void:
	Settings.set_display("skirmish_controls", "bottom" if controls() == "middle" else "middle")
	_build()
	_refresh()


## The predator sense (Ryan, 17 October; the funnel-web's row, 18 October): while a die is read
## or dragged on a machine whose passive reads a foe's intent on it (the funnel-web's Ambush),
## the foes' ground dims and the foes the entry showing can reach that show no intent on the
## machine get their eyes. RIFTGATE_PREY_DEBUG=1 keeps it on.
func _refresh_prey() -> void:
	if _prey == null:
		return
	var blast := _blast_marks()
	if not blast.is_empty():
		_prey.show_marks(blast["rects"], "blast", blast["labels"])
		return
	var i := _drag_from if _drag_from >= 0 else _read_die()
	var force := false
	if i < 0 and PREY_DEBUG:
		for j in range(sk.mechs.size()):
			if sk.mechs[j].alive() and Effects.reads_intent(sk.mechs[j].unit):
				i = j
				break
		if i < 0 and not sk.mechs.is_empty():
			i = 0
			force = true
	if i < 0:
		_prey.hide_marks()
		return
	var foes := prey_for(i, force)
	if foes.is_empty() and not (PREY_DEBUG and _drag_from < 0 and _read_die() < 0):
		_prey.hide_marks()
		return
	var rects: Array = []
	for foe in foes:
		var fv := _foe_view_for(foe)
		if fv == null or not fv.visible:
			continue
		var r := fv.drawing_rect()
		var xf := fv.get_global_transform()
		rects.append(Rect2(xf * r.position, xf.get_scale() * r.size))
	_prey.show_marks(rects)


## The blast's marks (the Whip Scorpion's, 22 October): while a vent die on a machine whose vents
## blast is read, or dragged anywhere but over an ally, every foe the blast may land on (the draw
## is over every live foe) is marked with what it would deal there. Nothing for any other die,
## or a vent with nothing to fire. RIFTGATE_BLAST_DEBUG=1 keeps them on.
func _blast_marks() -> Dictionary:
	var i := _drag_from if _drag_from >= 0 else _read_die()
	var forced := false
	if i < 0 and BLAST_DEBUG:
		for j in range(sk.mechs.size()):
			var dm: Skirmish.MechState = sk.mechs[j]
			if dm.alive() and not dm.assigned and Effects.vent_blast(dm.unit) > 0.0 and dm.face() != null and dm.face().kind == Face.Kind.VENT:
				i = j
				forced = true
				break
	if i < 0 or i >= sk.mechs.size() or sk.state != Skirmish.State.ASSIGN:
		return {}
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive() or ms.assigned or ms.face() == null:
		return {}
	var who: Skirmish.MechState = _drag_over if _drag_from == i and _drag_over is Skirmish.MechState else null
	var vent := sk.shown_face(ms, sk.spend_face(ms))
	var amount := sk.blast_amount(ms, vent, who)
	if amount <= 0 and forced:
		amount = int(roundf(float(vent.power) * Effects.vent_blast(ms.unit)))   # the switch fires a full vent, cold or not
	if amount <= 0:
		return {}
	var rects: Array = []
	var labels: Array = []
	for foe in sk.blast_targets():
		var fv := _foe_view_for(foe)
		if fv == null or not fv.visible:
			continue
		var r := fv.drawing_rect()
		var xf := fv.get_global_transform()
		rects.append(Rect2(xf * r.position, xf.get_scale() * r.size))
		labels.append(str(sk.blast_number(ms, amount, foe)))
	return {"rects": rects, "labels": labels}


## The foes an ambusher's entry showing marks: those it can reach that show no intent on the
## machine, when the machine's passives read that (`force` reads it for any machine, the debug
## switch's); nothing for another machine, an entry not aimed at a foe, one whose hit the read
## passes by (a debuff, where the rule asks for a weapon's hit), or a spent die.
func prey_for(i: int, force: bool = false) -> Array[Foe]:
	var out: Array[Foe] = []
	if i < 0 or i >= sk.mechs.size():
		return out
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive() or ms.assigned:
		return out
	var f := sk.shown_face(ms, ms.face())
	if f == null or not f.is_attack() or not (force or Effects.reads_intent(ms.unit, f)):
		return out
	for foe in sk.targets_for_face(ms, f):
		if not foe.intent_on(ms.unit):
			out.append(foe)
	return out


func _on_drag_started(i: int) -> void:
	_drop_die_pop()
	_drag_from = i
	_drag_over = null
	Sound.play("die_pick")
	var sf := sk.shown_face(sk.mechs[i], sk.spend_face(sk.mechs[i]))
	_ghost.shut = []   # no foe in hand yet: every chip as printed
	_ghost.set_face(sf, sk.shown_number_text(sk.mechs[i], sf))
	_ghost.blast = sk.blast_number(sk.mechs[i], sk.blast_amount(sk.mechs[i], sf))
	_ghost.after_blow = -1
	_ghost.form_mark = form_mark(sk.mechs[i], sf)
	_ghost.cooldown = sk.cooldown_of(sk.mechs[i], sf)
	_ghost.charged = sk.charge_lands(sk.mechs[i])
	_ghost.corrupted = Effects.corrupt_stacks(sk.mechs[i].unit, sk.mechs[i].face_index)
	_ghost.slot = sk.mechs[i].face_index + 1
	_ghost.visible = true
	_refresh()



## A die picked up closes a die's readout: the drag reads the die in hand. The caller refreshes.
func _drop_die_pop() -> void:
	if _pop.has("die"):
		_pop = {}
		_details.visible = false
func _on_drag_moved(global_pos: Vector2) -> void:
	if not _ghost.visible:
		return
	var local: Vector2 = get_global_transform().affine_inverse() * global_pos
	_ghost.position = local - Vector2(DIE_SIZE * 0.5, DIE_SIZE * 0.5)
	# The hover hum while the die is over somewhere it may be spent (Ryan, 5 October).
	var target = _drop_target_at(global_pos)
	var can := target != null and _drag_from >= 0 and sk.can_assign(_drag_from, target)
	Sound.hover(can)
	# What the die is over decides what the gauges forecast (a lure's turn, a Cryo cash) and where
	# the blast's marks go: read again only when it changes, never saved mid-drag.
	var over = target if can else null
	if not _same_target(over, _drag_over):
		_drag_over = over
		_refresh(false)
	# Over a foe it may strike, the die shows what it will deal to that foe (10 October):
	# its missing hull, a status on it, its armour, and the keywords its rank grants (the
	# Cottonmouth's drum). A shield over a machine it may land on shows what it will give
	# there (the Puffin's ally heat, 21 October). Anywhere else, the plain entry and number.
	if _drag_from >= 0:
		var ms: Skirmish.MechState = sk.mechs[_drag_from]
		var over_foe: Foe = target if can and target is Foe else null
		var sf := sk.shown_face(ms, sk.spend_face(ms), over_foe)
		_ghost.shut = sk.shut_gates(ms, sf, over_foe)   # a gated keyword's chip struck where it will not land
		if can and target is Skirmish.MechState and sf != null and sf.kind == Face.Kind.SHIELD:
			_ghost.set_face(sf, str(sk.shield_amount(ms, sf, target)))
		else:
			_ghost.set_face(sf, sk.shown_number_text(ms, sf, over_foe))
		# The blow its passive adds after the strikes, over the foe through its armour, in the
		# passive's box (the Storm Petrel's; Ryan, 4 November).
		_ghost.after_blow = Skirmish.after_blow(ms, sf, over_foe) if over_foe != null else -1
		# A vent's blast fires only on its own machine: over an ally the die prints none. The heat
		# bar reads the net over a Cryo foe (Ryan, 16 October: on the bar, never the die) through
		# the forecast the refresh above reads (_forecast_for).
		_ghost.blast = sk.blast_number(ms, sk.blast_amount(ms, sf, target if can and target is Skirmish.MechState else null))


func _on_drag_ended(global_pos: Vector2) -> void:
	var i := _drag_from
	_drag_from = -1
	_drag_over = null
	_ghost.visible = false
	Sound.hover(false)
	if i < 0:
		_refresh()
		return
	var target = _drop_target_at(global_pos)
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if target is Foe and sk.needs_second(sk.mechs[i]) and sk.can_assign(i, target):
		_begin_second(i, target)
		return
	if target == null or not _use_die(i, target):
		Sound.play("die_drop")   # set back
	_refresh()


## A Swap dropped on its first target (Ryan, 21 October): the die sits over that foe, the
## second targets light (every other foe that moves, every empty slot), and a tap on one
## spends it; dragging the die again picks it back up; a tap reads it as ever.
func _begin_second(i: int, primary: Foe) -> void:
	_pending = {"mech": i, "primary": primary}
	var fv := _foe_view_for(primary)
	if fv != null:
		var local: Vector2 = get_global_transform().affine_inverse() * fv.get_global_rect().get_center()
		_ghost.position = local - Vector2(DIE_SIZE * 0.5, DIE_SIZE * 0.5)
	_ghost.visible = true
	_ghost.can_drag = true
	_ghost.mouse_filter = Control.MOUSE_FILTER_STOP
	Sound.play("die_drop")
	_refresh()


## The pending die picked back up off its first target: a drag like any, so it may land on
## another first target or be set back to cancel.
func _on_ghost_drag_started() -> void:
	if _pending.is_empty():
		return
	var i: int = _pending["mech"]
	_pending = {}
	_drop_die_pop()
	_drag_from = i
	_drag_over = null
	Sound.play("die_pick")
	_refresh()


## A tap on the pending die reads it, as a tap on the die in the tray does; a hold opens its
## readout too, as a hold on a unit does (it is being spent: there is nothing to lock).
func _on_ghost_tapped() -> void:
	if not _pending.is_empty():
		_on_die_tapped(int(_pending["mech"]))


func _on_ghost_held() -> void:
	if not _pending.is_empty() and _pop != {"die": int(_pending["mech"])}:
		_open_pop({"die": int(_pending["mech"])})


## A tap on a slot while a Swap waits for its second target: the foe there, or the empty slot,
## if it is one the Swap may take. Any other tap leaves the Swap waiting.
func _on_slot_tapped(rank: int, col: int) -> void:
	if _pending.is_empty():
		return
	var foe := sk.foe_at(rank, col)
	var second = foe if foe != null else Vector2i(rank, col)
	if not sk.swap_targets(_pending["primary"]).has(second):
		return
	var i: int = _pending["mech"]
	var primary: Foe = _pending["primary"]
	_cancel_second()
	if not _use_die(i, primary, second):
		Sound.play("die_drop")
	_refresh()


## A tap on a twin slot's right-hand half while a Swap waits for its second target.
func _on_twin_tapped(rank: int, col: int) -> void:
	var twin: Foe = sk.twins.get(Vector2i(rank, col), null)
	if _pending.is_empty() or twin == null or not sk.swap_targets(_pending["primary"]).has(twin):
		return
	var i: int = _pending["mech"]
	var primary: Foe = _pending["primary"]
	_cancel_second()
	if not _use_die(i, primary, twin):
		Sound.play("die_drop")
	_refresh()


## A control laid where it now rests, its animations settled first when that moves it.
func _lay(c: Control, pos: Vector2, sz: Vector2) -> void:
	if c.size == sz and _home.get(c, Vector2(-1.0e9, 0.0)) == pos:
		return
	_settle(c)
	c.position = pos
	c.size = sz
	_home[c] = pos


## The pending Swap put back in the tray, unspent.
func _cancel_second() -> void:
	_pending = {}
	_ghost.visible = false
	_ghost.can_drag = false
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE


## A tap on nothing sets the waiting Swap back (Ryan, 30 October): the die flies home to its place
## in the tray, unspent, with a drop on nowhere's sound. A copy flies, so the die is free to be
## picked up again the moment it is home.
func _send_second_home() -> void:
	var i: int = _pending["mech"]
	var from := _ghost.position
	_cancel_second()
	Sound.play("die_drop")
	_refresh(false)
	if not is_inside_tree():
		return
	var d := _dice[i]   # as the refresh above drew it
	var fly := DieFaceView.new()
	fly.animate = false
	fly.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fly.set_face(d.face, d.shown_number)
	fly.slot = d.slot
	fly.corrupted = d.corrupted
	fly.blast = d.blast
	fly.after_blow = d.after_blow
	fly.charged = d.charged
	fly.dark = d.dark
	fly.cooldown = d.cooldown
	fly.position = from
	fly.size = DieFaceView.view_size()
	add_child(fly)
	d.modulate.a = 0.0   # in flight until it lands
	var tw := create_tween()
	tw.tween_property(fly, "position", d.position, HOME_FLIGHT).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		fly.queue_free()
		_refresh(false))


## Two drop targets the same (a Foe, a MechState, an empty slot's Vector2i, or null), compared by
## type first, since GDScript refuses == across an object and a vector.
static func _same_target(a, b) -> bool:
	if typeof(a) != typeof(b):
		return false
	return typeof(a) == TYPE_NIL or a == b


## What sits under a global point: a Foe, an empty slot as Vector2i(rank, column) (a Swap's
## second target), a MechState, or null.
func _drop_target_at(global_pos: Vector2):
	for v in _view_foe.keys():
		if v.visible and v.get_global_rect().has_point(global_pos):
			return _view_foe[v]
	for rank in range(2):
		for col in range(sk.columns):
			var sv: UnitView = _slot_views[rank][col]
			if sv != null and sv.visible and sk.foe_at(rank, col) == null and sv.get_global_rect().has_point(global_pos):
				return Vector2i(rank, col)
	for j in range(_mech_views.size()):
		if _mech_views[j].get_global_rect().has_point(global_pos):
			return sk.mechs[j]
	return null


## A foe's blow this big or bigger lands as its family's heavy blow (a placeholder, like
## every number).
const HEAVY_DAMAGE := 20


## The sound of a component's use: by the weapon (ContentDB.sound_of: its shape, an energy
## barrel a laser, the Arsenal's a plasma, the label where content names one), a shield's
## deflector and a buff's coil. "" for none.
func _blow_sound(f: Face) -> String:
	if f == null or f.component.is_empty():
		return ""
	return Sound.blow(ContentDB.load_default().sound_of(f.component))


## The maker whose metal a machine is.
func _maker_of(ms: Skirmish.MechState) -> String:
	return ContentDB.load_default().maker_of(ms.unit.chassis_id)


## Each live machine's heat as a mark: 0 cool, 1 past three quarters, 2 over the cap (it will
## burn at the round's end).
func _heat_marks() -> Array:
	var out: Array = []
	for ms in sk.mechs:
		var m := 0
		if ms.alive() and ms.heat_max > 0:
			if ms.heat > ms.heat_max:
				m = 2
			elif ms.heat * 4 >= ms.heat_max * 3:
				m = 1
		out.append(m)
	return out


## Each machine's heat as the gauge holds it, to tell a spend that heated one.
func _heats() -> Array:
	var out: Array = []
	for ms in sk.mechs:
		out.append(ms.heat)
	return out


## The machines Jenny has warned are past three quarters heat (mech index -> true), each until it
## is seen back under (_heat_rearm).
var _heat_warned: Dictionary = {}


## A machine seen back under three quarters heat can be warned of it again: looked at as a
## round opens, once the machines have cooled, and after every spend.
func _heat_rearm() -> void:
	var marks := _heat_marks()
	for k in range(marks.size()):
		if int(marks[k]) == 0:
			_heat_warned.erase(k)


## Jenny on the heat a spend just added, one line for the spend (Ryan, 10 November: "The heat
## warning shouldn't fire every time, not anymore ... I think we only need to warn: -Every time
## we're overheating -The first time we reach over the warning threshold, but not again until
## we've got back under"). The overheat, every time: a spend that heats a machine and leaves it
## over its cap says so, whether it was over already or not. The warning, once: a machine past
## three quarters is warned the first time it gets there and not again until it has been seen
## back under, so a machine that stays hot, or comes down from an overheat to its cap, is not
## warned a second time. `before` is _heats() as the spend began.
func _heat_hook(before: Array) -> String:
	_heat_rearm()
	var marks := _heat_marks()
	var worst := 0
	for k in range(mini(before.size(), marks.size())):
		var m := int(marks[k])
		if m == 0:
			continue
		var first := not _heat_warned.has(k)
		_heat_warned[k] = true
		if m == 2 and (first or sk.mechs[k].heat > int(before[k])):
			worst = 2
		elif first:
			worst = maxi(worst, 1)
	return "overheat" if worst == 2 else ("heat_high" if worst == 1 else "")


## The chain a spend is heard in (Ryan, 8 and 9 October). The die is let go at once and the
## blow fires BLOW_AT after; the hit's flash, a kill and its death come where the blow lands
## (Sound.LAND). Jenny, when she speaks on it:
##   a blow that does not kill: before the weapon, confirming the input, the weapon firing
##     as her line closes, PRE_FIRE of the way through it (Ryan, 9 October: half a second was
##     not enough, she talks slow);
##   a blow that kills: the foe's short death where the blow lands, her line right after it
##     (Ryan, 9 October: at the landing she was early and buried, the death being the
##     machine's then; a foe's own is under a second);
##   a shield, a buff or a vent: before it, the same as a blow;
##   heat pushed past a mark: the warning in place of any of those, where the blow lands
##     (the damage applied), or after the death on a kill.
## The die that wins the fight has none of her.
const BLOW_AT := 0.08
const AIM_HOLD := 0.35       # a machine that turned to fire holds its aim this long past the blow's landing
const PRE_LINE_AT := 0.1     # her line, just after the die's own sound
const PRE_FIRE := 0.85       # the weapon, this far through her line
const AFTER_DEATH := 0.45   # her line, this long after a foe's death begins
## The enemy's turn: her component lines after the blow lands (a machine lost waits for its
## death at the turn's end).
const VOICE_AFTER_BLOW := 0.4


## Spend die `i` on `target` (a Foe or a MechState). Returns whether the simulation accepted it.
## Its blows land a strike at a time (Ryan, 2 November: "flechette pod and other multistrikes need
## to clearly show the strikes in order, with individual ticks of damage. The damage animation is
## individual, but the damage is not - damage needs to be timed to the animation across the
## board"): each strike fires on its own beat, STRIKE_GAP apart, and its blows land with it, every
## foe it struck flashing, its gauge stepping down to what the blow left and the blow's number
## rising off it; a foe the spend killed is stood in for, gauge and all, until its killing blow
## lands, then dies; a last act lands its damage on the machines as it is named.
## The foes that got back up since the engine's returns stood at `n` (Skirmish.returned): what the
## screen plays as a fall and a rise.
func _risen_since(n: int) -> Array:
	var out: Array = []
	for r in sk.returned.slice(n):
		if str(r.get("how", "")) == "rises":
			out.append(r["foe"])
	return out


func _use_die(i: int, target, second = null) -> bool:
	_flush_blows()
	# Every foe's view and look before the die lands: a kill clears its slot at once, so the
	# death is played from what stood there (a stand-in dressed as its view).
	var was: Dictionary = {}
	var hp_before: Dictionary = {}
	for foe in sk.field_foes():
		hp_before[foe] = foe.hp
		var fv := _foe_view_for(foe)
		if fv != null:
			was[foe] = [fv, fv.look(), _home.get(fv, fv.position)]
	var returns_before := sk.returned.size()
	var spent: Face = sk.mechs[i].face()
	var sealed_before := Effects.is_sealed(sk.mechs[i].unit)
	var heat_before := _heats()
	var fuel := spent.rolls_again_on if spent != null else ""
	var fuel_before := Effects.stacks_of(sk.mechs[i].unit, fuel) if not fuel.is_empty() else 0
	var ok := sk.assign(i, target, second)
	if ok:
		locked[i] = false
		if is_inside_tree():
			_undo_from = Time.get_ticks_msec() + int((BLOW_AT + 2.0) * 1000.0)   # until the blow's timing is known, below
	var blows: Array = sk.spend_blows.duplicate() if ok else []
	var dead: Array = []
	# The foes the spend felled that got back up, as the engine says (its returns; the audit's
	# eleventh bug, 8 November: never inferred from a lost Undying, which a Purge takes too).
	var rose: Array = _risen_since(returns_before) if ok else []
	if ok:
		for foe in was.keys():
			if not foe.alive() or rose.has(foe):
				dead.append(foe)   # a foe that got back up dies on screen first, then stands again
	spend_played = {"dead": dead, "rose": rose}
	# The gauges the blows struck hold what they showed until each blow lands, and a machine a last
	# act struck its gauges until the act lands.
	if ok and is_inside_tree():
		for b in blows:
			var foe: Foe = b["foe"]
			if hp_before.has(foe) and not dead.has(foe) and foe.alive():
				_shown_hp[foe] = int(hp_before[foe])
		for act in sk.last_acts:
			var g: Array = act.get("gauges", [])
			for k in range(mini(g.size(), (act["mechs"] as Array).size())):
				if not _shown_gauges.has(int(act["mechs"][k])):
					_shown_gauges[int(act["mechs"][k])] = g[k]
	_refresh()
	if ok:
		Sound.play("die_spend")   # the console letting the die go; the component's own sound lands after
	if ok and not fuel.is_empty() and not sk.mechs[i].assigned and Effects.stacks_of(sk.mechs[i].unit, fuel) < fuel_before:
		_roll_again(i, fuel)
	# The fight decided by this die: nothing queued during it is said after (the win clears
	# Jenny's queue, so the last kill never gets a heat warning behind it).
	var won := ok and sk.outcome == Skirmish.Outcome.VICTORY
	if won:
		Sound.voice_clear()
	var blow := _blow_sound(spent)
	var heat_hook := _heat_hook(heat_before) if ok and not won else ""
	var quiet := won or not heat_hook.is_empty()   # nothing but the heat may take her line
	var fire_at := BLOW_AT
	# A machine turns onto what it fires at before its weapon fires (Ryan, 2 November: "make sure
	# that the turns or aims happen before the sound effects. It's part of the whole immersion
	# package"): the blow, its kick and its sound wait on the turn.
	var aim_view: UnitView = null
	if ok and target is Foe:
		aim_view = was[target][0] if was.has(target) else null
	var aim := _aim_plan(i, aim_view, spent)
	fire_at += float(aim[1])
	# A fixed weapon whose firing slice winds up before its blow (MechRig.fire_wind: the Buzzard's
	# cannon charging up its spine) plays it from the turn's end, the blow and its sound waiting on it.
	var wind := _fire_wind(i, spent) if ok and target is Foe else 0.0
	fire_at += wind
	var landed := fire_at + Sound.lands(blow)   # where the first strike lands, from the die let go
	var strikes := _strikes_of(blows)
	if ok and target is Foe:
		var tv: UnitView = was[target][0] if was.has(target) else null
		var fallen := ""
		for foe in dead:
			fallen = ContentDB.load_default().faction_of_foe(foe.content_id)
		if not quiet:
			if dead.is_empty():
				var said := Sound.claim_line("die_spent", PRE_LINE_AT)
				if said > 0.0:
					fire_at = maxf(PRE_LINE_AT + said * PRE_FIRE, BLOW_AT + float(aim[1]) + wind)
			else:
				var hook := "foe_down_" + fallen
				Sound.claim_line(hook if Sound.FAMILIES.has(fallen) else "foe_down", landed + (strikes - 1) * STRIKE_GAP + AFTER_DEATH)
		landed = fire_at + Sound.lands(blow)
		# A weapon that lunges (melee with nothing that crosses the field, read from the tags it was
		# fired with) lunges; anything else kicks back, a shotgun tagged melee among them.
		var fired = sk.last_roll.get("tags", [])
		var shape := str(ContentDB.load_default().components.get(spent.component, {}).get("shape", "")) if spent != null else ""
		var ranged := not MuzzleFlare.lunges(fired if fired is Array else [], shape)
		var cid := spent.component if spent != null else ""
		# The turn holds until the last strike has landed.
		_aim_before(i, aim, fire_at - BLOW_AT - wind, landed + (strikes - 1) * STRIKE_GAP, cid)
		if wind > 0.0:
			_wind_up(i, ranged, cid, fire_at - BLOW_AT - wind)
		for k in range(strikes):
			# Each strike fires on its own beat: the machine kicks back (or lunges at the foe the
			# strike is aimed at) and the weapon sounds, so a burst reads as its strikes in order; a
			# fixed weapon its wind-up began plays its act once (_wind_up).
			_attack_at(fire_at - BLOW_AT + k * STRIKE_GAP, _mech_views[i], _view_struck(blows, k, was, tv), ranged, BLOW_AT + Sound.lands(blow), cid, wind > 0.0)
			Sound.play_after(fire_at + k * STRIKE_GAP, blow, 0.0 if k == 0 else -3.0)
	elif ok and spent != null:
		var vent := spent.kind == Face.Kind.VENT
		var effect := "vent" if vent else blow
		if spent.kind == Face.Kind.VENT or spent.kind == Face.Kind.SHIELD or spent.kind == Face.Kind.BUFF:
			var hook := "heat_vented" if vent else ("shield" if spent.kind == Face.Kind.SHIELD else "buff")
			var said := 0.0 if quiet else Sound.claim_line(hook, PRE_LINE_AT)
			fire_at = PRE_LINE_AT + said * PRE_FIRE if said > 0.0 else 0.0
			Sound.play_after(fire_at, effect, -3.0 if spent.kind == Face.Kind.BUFF else 0.0)
			landed = fire_at + Sound.lands(effect)
			# A fixed piece of equipment moves as it is used, with its slice of an act where the
			# model names one (Ryan's go of 3 November: the Puffin's Ionizer, the Giant Petrel's
			# boosters and uplink), starting with its sound.
			if i < _mech_3d.size() and _mech_3d[i] != null and is_inside_tree():
				if fire_at <= 0.0:
					_mech_3d[i].use(spent.component)
				else:
					var uw := create_tween()
					uw.tween_interval(fire_at)
					uw.tween_callback(_use_view.bind(_mech_3d[i], spent.component))
		if not blows.is_empty():
			_attack_at(maxf(0.0, fire_at - BLOW_AT), _mech_views[i], _view_struck(blows, 0, was, null), true)   # a vent's blast
	if ok and Effects.is_sealed(sk.mechs[i].unit) != sealed_before:
		# Its form shifts as the spend lands (Ryan, 2 November: "It also needs some highlight or
		# something when it is transforming").
		_form_shift_at(landed, i, not sealed_before)
	var ends := landed
	if ok:
		var deaths := _land_blows(blows, landed, was, dead, hp_before)
		for b in blows:
			ends = maxf(ends, _blow_time(b, landed))
		for k in range(dead.size()):
			var at := float(deaths.get(dead[k], ends))
			ends = maxf(ends, at)
			Sound.play_after(at + 0.07 * k, "kill", -2.0 * k)
	if not heat_hook.is_empty():
		Sound.say_after(ends + (AFTER_DEATH if not dead.is_empty() else 0.0), heat_hook)
	# A split's halves step up where it fell (the Gel's, 25 October), and a foe getting back up
	# stands again in its slot (26 October), in once the deaths have landed.
	if ok:
		var stepped := 0
		for foe in sk.field_foes():
			if not was.has(foe) or rose.has(foe):
				_animate_arrival(_foe_view_for(foe), ends + 0.3)
				Sound.play_after(ends + 0.55 + 0.09 * stepped, "arrival", -3.0 * stepped)
				stepped += 1
	if ok and sk.outcome != Skirmish.Outcome.NONE:
		# Decided by this die: the fight ends once the last blow has landed and played.
		if is_inside_tree():
			var tw := create_tween()
			tw.tween_interval(ends + 0.75)
			tw.tween_callback(_show_outcome.bind(sk.outcome))
		else:
			_show_outcome(sk.outcome)
	if ok and is_inside_tree():
		# The undo opens once the last blow has landed and played out: a view mid-tween takes no
		# refresh well, and the die should be seen to land before it is taken back. _process opens
		# it, reading the same clock that shut it: a tween timed to the same moment ran on the
		# frames' deltas, which run a frame ahead of the clock, so it fired just short of the mark
		# and left the button shut for good (Ryan, 9 November: "skirmish undo, it doesn't work
		# anymore").
		_undo_from = Time.get_ticks_msec() + int((ends + UNDO_AFTER) * 1000.0)
		_undo_waiting = true
		_refresh_undo()
	return ok


const STRIKE_GAP := 0.24   # seconds between a spend's strikes, each its own flash, tick and number (Ryan, 2 November; a placeholder, judged running)
var _shown_hp: Dictionary = {}       # Foe -> the HP its gauge shows while a spend's blows land
var _shown_gauges: Dictionary = {}   # machine index -> [shield, hull] its gauges show until a last act lands on it
var _stand_ins: Dictionary = {}      # Foe -> the view standing in for it, killed by a spend, until its death plays
var _blows_tw: Tween = null          # the spend's blows as they land


## Machine `i`'s form shifts `t` seconds from now: its view's burst, sealing or opening.
func _form_shift_at(t: float, i: int, sealing: bool) -> void:
	if not is_inside_tree() or i < 0 or i >= _mech_views.size():
		return
	var tw := create_tween()
	tw.tween_interval(maxf(0.0, t))
	tw.tween_callback(_mech_views[i].form_shift.bind(sealing))


## The strikes a spend's blows came in: one past the last strike any landed on (the zap and a
## Mine's blast after them aside: the machine fires once a strike, and a blast is no fire of its
## own), and one at least.
static func _strikes_of(blows: Array) -> int:
	var n := 1
	for b in blows:
		if str(b["kind"]) != "zap" and str(b["kind"]) != "mine":
			n = maxi(n, int(b["strike"]) + 1)
	return n


## When a blow lands, from the die let go: its strike's beat after the first strike lands.
static func _blow_time(b: Dictionary, landed: float) -> float:
	return landed + int(b["strike"]) * STRIKE_GAP


## The view a strike is aimed at, for the attacker's lunge: its first blow's foe as the spend found
## it, a wasted shot's empty slot, else `fallback`.
func _view_struck(blows: Array, k: int, was: Dictionary, fallback) -> UnitView:
	for b in blows:
		if int(b["strike"]) != k:
			continue
		if str(b["kind"]) == "miss":
			var v := _miss_view(b)
			if v != null:
				return v
		elif str(b["kind"]) in ["strike", "mine"]:
			var foe: Foe = b["foe"]
			if was.has(foe):
				return was[foe][0]
			return _foe_view_for(foe)
	return fallback


## The empty slot a wasted shot landed in, or null.
func _miss_view(b: Dictionary) -> UnitView:
	var at: Vector2i = b.get("slot", Vector2i(-1, -1))
	if at.x < 0 or at.x >= _slot_views.size() or at.y < 0 or at.y >= (_slot_views[at.x] as Array).size():
		return null
	var v: UnitView = _slot_views[at.x][at.y]
	return v if v != null and is_instance_valid(v) else null


## The attacker's move for a strike, `t` seconds from now: `lands`, `cid` and `wound` as
## _animate_attack takes them (the shot's landing from the move, the component fired, a wind-up
## that began its act), the hit the blows' own (_land_blows).
func _attack_at(t: float, attacker: UnitView, aimed, ranged: bool, lands: float = 0.08, cid: String = "", wound: bool = false) -> void:
	if not is_inside_tree() or t <= 0.001:
		_animate_attack(attacker, aimed, ranged, false, lands, cid, wound)
		return
	var tw := create_tween()
	tw.tween_interval(t)
	tw.tween_callback(_animate_attack.bind(attacker, aimed, ranged, false, lands, cid, wound))


## The spend's blows, landing (the spend's doc above): a stand-in for every foe it killed, then
## every blow at its strike's beat, every death at its killing blow, every last act after its
## foe's death, and the gauges let go after the last. Returns Foe -> when each killed foe dies.
## Off the tree it all lands at once (the gauges already read the fight).
func _land_blows(blows: Array, landed: float, was: Dictionary, dead: Array, hp_before: Dictionary) -> Dictionary:
	var deaths := {}
	var last := landed
	# The death check (Ryan, 7 November: "check death(s)" once the hits, or a Sweep's every shot,
	# are done): every foe the spend killed dies after its last blow, so a later hit or shot on it
	# lands on its stand-in first and nothing it took is cut short ("Anything truncated confuses
	# the player").
	var check := landed + (_strikes_of(blows) - 1) * STRIKE_GAP
	for b in blows:
		check = maxf(check, _blow_time(b, landed))
	for foe in dead:
		deaths[foe] = check
	if not is_inside_tree():
		return deaths
	for foe in dead:
		if not was.has(foe):
			continue
		var si := UnitView.new()
		si.dress(was[foe][1])
		si.mouse_filter = Control.MOUSE_FILTER_IGNORE
		si.highlight = false
		si.bars = [[int(hp_before.get(foe, foe.hp_max)), foe.hp_max, Palette.HUD, int(hp_before.get(foe, foe.hp_max))]]
		si.position = was[foe][2]
		add_child(si)
		move_child(si, _pair_marks.get_index())   # among the foes, under the arrows and the readouts
		si.queue_refresh()
		_stand_ins[foe] = si
	var events: Array = []   # [time, callable], played in time order
	var count := {}
	for b in blows:
		var foe: Foe = b["foe"]
		var key = foe if foe != null else b.get("slot", Vector2i(-1, -1))   # a wasted shot counts by its slot
		var n := int(count.get(key, 0))
		count[key] = n + 1
		events.append([_blow_time(b, landed), _land_spend_blow.bind(b, n)])
		last = maxf(last, _blow_time(b, landed))
	for foe in dead:
		events.append([float(deaths[foe]) + 0.01, _stand_in_dies.bind(foe)])
		last = maxf(last, float(deaths[foe]))
	for act in sk.last_acts:
		var at := float(deaths.get(act["foe"], last)) + 0.35
		events.append([at, _land_last_act.bind(act)])
		last = maxf(last, at)
	events.append([last + 0.05, _release_blows])
	events.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	_blows_tw = create_tween()
	var now := 0.0
	for e in events:
		if float(e[0]) > now:
			_blows_tw.tween_interval(float(e[0]) - now)
			now = float(e[0])
		_blows_tw.tween_callback(e[1])
	return deaths


## One blow landing: its foe's gauge steps down to what it left, the foe flashes and the blow's
## number rises off it, the `n`-th on that foe this spend set apart from the ones before.
func _land_spend_blow(b: Dictionary, n: int) -> void:
	if str(b.get("kind", "")) == "miss":
		_land_miss(b)
		return
	var foe: Foe = b["foe"]
	var v: UnitView = _stand_ins.get(foe, null)
	if v == null:
		v = _foe_view_for(foe)
	var hp := maxi(0, int(b["hp"]))
	if _shown_hp.has(foe):
		_shown_hp[foe] = hp
	if v == null or not is_instance_valid(v):
		return
	if not v.bars.is_empty():
		var bar: Array = v.bars[0]
		bar[0] = hp
		if bar.size() >= 4:
			bar[3] = hp
		v.queue_redraw()
	_animate_hit(v)
	_pop_damage(v, int(b["taken"]), n)


## A blow's number rising off the unit it struck, in ink on a dark edge (a blow that did nothing in
## grey), each after the first on that unit set a little aside so a burst's numbers stand apart.
func _pop_damage(v: UnitView, taken: int, n: int) -> void:
	var l := Hud.label(str(taken), 40, Palette.INK if taken > 0 else Palette.MUTED, Hud.mono())
	l.add_theme_constant_override("outline_size", 8)
	l.add_theme_color_override("font_outline_color", Color(Palette.BG, 0.9))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size = Vector2(120.0, 52.0)
	var d := v.drawing_rect()
	var base: Vector2 = v.position if _stand_ins.values().has(v) else _home.get(v, v.position)
	var at := base + Vector2(d.get_center().x - 60.0 + float(n % 3 - 1) * 20.0, d.position.y - 16.0 - n * 8.0)
	l.position = at
	add_child(l)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", at.y - 34.0, 0.9).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.45).set_delay(0.5)
	tw.set_parallel(false)
	tw.tween_callback(l.queue_free)


## A Sweep's shot at an empty column landing (Ryan, 7 November: "Animate wasted shots. Anything
## truncated confuses the player"): the empty slot jolts where the shot struck and a ring of dust
## is thrown off it, wide and thick on purpose for the phone, with no number, since nothing was
## there to take one. A first cut, judged running (RIFTGATE_MISS_DEBUG=1).
func _land_miss(b: Dictionary) -> void:
	var v := _miss_view(b)
	if v == null or not is_inside_tree():
		return
	_animate_hit(v)
	var r := v.drawing_rect()
	var reach := maxf(r.size.x, 60.0)
	var puff := Control.new()
	puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
	puff.position = _home.get(v, v.position) + r.get_center()
	add_child(puff)
	var state := {"t": 0.0}
	var ink := Palette.INK
	puff.draw.connect(func() -> void:
		var t: float = state["t"]
		var a := 1.0 - t
		var rad := lerpf(reach * 0.12, reach * 0.6, t)
		puff.draw_arc(Vector2.ZERO, rad, 0.0, TAU, 40, Color(ink, a), lerpf(7.0, 2.0, t))
		for i in range(10):
			var ang := TAU * float(i) / 10.0 + 0.3
			var d := Vector2(cos(ang), sin(ang))
			puff.draw_line(d * rad * 0.55, d * rad * 1.15, Color(ink, a * 0.85), lerpf(4.0, 1.5, t)))
	var tw := create_tween()
	tw.tween_method(func(t: float) -> void:
		state["t"] = t
		if is_instance_valid(puff):
			puff.queue_redraw(), 0.0, 1.0, 0.5).set_ease(Tween.EASE_OUT)
	tw.tween_callback(puff.queue_free)


## The miss debug switch's beat (MISS_DEBUG): the next empty slot of the formation takes a wasted
## shot's landing; none with the formation full.
func _miss_debug() -> void:
	var empty: Array[Vector2i] = []
	for rank in range(2):
		for col in range(sk.columns):
			if sk.foe_at(rank, col) == null:
				empty.append(Vector2i(rank, col))
	if empty.is_empty():
		return
	_land_miss({"slot": empty[_miss_debug_n % empty.size()], "kind": "miss"})
	_miss_debug_n += 1


## A killed foe's stand-in dies at the spend's death check, after its last blow: its marks go,
## its drawing flashes, drops and fades in the red-red, and it is gone.
func _stand_in_dies(foe: Foe) -> void:
	var si: UnitView = _stand_ins.get(foe, null)
	if si == null or not is_instance_valid(si):
		return
	si.bars = []
	si.statuses = []
	si.intent_kind = ""
	si.breathe = false
	si.queue_redraw()
	# Bound to the stand-in, not the screen: a flush of the blows (`_flush_blows`) that frees it
	# mid-fade kills its fade with it, where the fade's end used to free it a second time.
	var tw := si.create_tween()
	tw.tween_property(si, "modulate", Color(2.0, 1.2, 1.2), 0.06)
	tw.tween_property(si, "modulate", Color(Palette.LOSS_DIM, 1.0), 0.12)
	tw.set_parallel(true)
	tw.tween_property(si, "modulate", Color(Palette.LOSS_DIM, 0.0), 0.4)
	tw.tween_property(si, "position:y", si.position.y + 16.0, 0.4).set_ease(Tween.EASE_IN)
	tw.set_parallel(false)
	tw.tween_callback(func() -> void:
		if _stand_ins.get(foe, null) == si:
			_stand_ins.erase(foe)
		si.queue_free())


## A last act lands (15 October): named on the plaque after its foe's death, and the machines it
## struck take it now, their gauges let go to what it left.
func _land_last_act(act: Dictionary) -> void:
	_announce(str(act["name"]))
	for mi in act["mechs"]:
		if int(mi) >= 0 and int(mi) < _mech_views.size():
			_shown_gauges.erase(int(mi))
			_animate_hit(_mech_views[int(mi)], 0.1)
	_refresh(false)


## The spend's blows have all landed: the gauges read the fight again.
func _release_blows() -> void:
	_blows_tw = null
	_shown_hp.clear()
	_shown_gauges.clear()
	_refresh(false)


## Every blow still waiting lands at once (a new spend, the turn's end): the gauges read the fight
## and the stand-ins go.
func _flush_blows() -> void:
	if _blows_tw != null and _blows_tw.is_valid():
		_blows_tw.kill()
	_blows_tw = null
	var lagged := not _shown_hp.is_empty() or not _shown_gauges.is_empty()
	_shown_hp.clear()
	_shown_gauges.clear()
	for foe in _stand_ins.keys():
		var si = _stand_ins[foe]
		if is_instance_valid(si):
			si.queue_free()
	_stand_ins.clear()
	if lagged:
		_refresh(false)


# ---------------------------------------------------------------- filler animation
# Nothing here changes state. It makes the exchange readable: who struck, who was struck.

## A weapon that lunges (MuzzleFlare.lunges: melee with nothing that crosses the field) lunges the
## attacker at the target; anything else kicks it back, a shotgun tagged melee among them. The target
## flashes and shakes a beat later, when the blow lands. `cid`, the component that struck, flares a
## burn weapon's fire on its mount.
func _animate_attack(attacker: UnitView, target: UnitView, ranged: bool, hit: bool = true, lands: float = 0.08, cid: String = "", wound: bool = false) -> void:
	if not is_inside_tree() or attacker == null:
		return
	_settle(attacker)
	var origin: Vector2 = _home.get(attacker, attacker.position)
	var mi := _mech_views.find(attacker)
	if mi >= 0 and mi < _mech_3d.size() and _mech_3d[mi] != null and not wound:
		_mech_3d[mi].strike(ranged, cid)   # the weapon that fired kicks and flares, its aim already turned (_aim_before); a fixed one fires with its act, unless its wind-up began it (_wind_up)
	if mi >= 0 and ranged and target != null and not cid.is_empty() and ShotTrail.on():
		_shoot_trail(mi, target, cid, lands)
	var tw := _track(attacker, create_tween())
	if ranged or target == null:
		var kick := Vector2(0.0, 8.0) if attacker in _mech_views else Vector2(0.0, -8.0)
		tw.tween_property(attacker, "position", origin + kick, 0.05).set_ease(Tween.EASE_OUT)
		tw.tween_property(attacker, "position", origin, 0.18).set_ease(Tween.EASE_OUT)
	else:
		var dir := (target.anchor_global() - attacker.anchor_global()).normalized()
		tw.tween_property(attacker, "position", origin + dir * 18.0, 0.09).set_ease(Tween.EASE_OUT)
		tw.tween_property(attacker, "position", origin, 0.16).set_ease(Tween.EASE_IN_OUT)
	if target != null and hit:
		_animate_hit(target, lands)


## A shot crossing the field (ShotTrail; tabled, so off unless SHOT TRAILS or RIFTGATE_SHOTS=1
## turns it on): from the muzzle of the weapon machine `mi` fired, as its view projects it, to the
## middle of what it fired at, landing `lands` seconds from now as the blow's sound says it lands.
func _shoot_trail(mi: int, target: UnitView, cid: String, lands: float) -> void:
	var db := ContentDB.load_default()
	var c: Dictionary = db.components.get(cid, {})
	var k := maxi(ShotTrail.kind_for(c), ShotTrail.TRACER)   # fired as a gun though its own tags lunge (the drum's shot): a tracer
	if not is_inside_tree():
		return
	var v := _mech_views[mi]
	var from := v.anchor_global()
	if mi < _mech_3d.size() and _mech_3d[mi] != null and v.sprite_at.size.x > 0.0:
		from = v.get_global_transform() * (v.sprite_at.position + _mech_3d[mi].muzzle_px(cid))
	var tags = c.get("tags", [])
	var look: String = MuzzleFlare.looks_for(tags if tags is Array else [], str(c.get("shape", "")))[0]
	var back := get_global_transform().affine_inverse()
	add_child(ShotTrail.make(k, back * from, back * target.anchor_global(), MuzzleFlare.colour(look), 0.0, lands))


## How machine `i` turns to fire at `target`: [degrees to its left, the seconds the turn takes],
## the seconds nought when it fires where it points (no joint turns for the weapon spent, or the
## foe is dead ahead).
func _aim_plan(i: int, target: UnitView, spent: Face) -> Array:
	if target == null or spent == null or i < 0 or i >= _mech_3d.size() or _mech_3d[i] == null:
		return [0.0, 0.0]
	var deg := _aim_turn(i, target)
	if absf(deg) < 1.0 or _mech_3d[i].aim_joint_for(spent.component).is_empty():
		return [deg, 0.0]
	return [deg, MechRig.AIM_UP]


## Start machine `i`'s turn so it ends as its weapon fires (`attack_at` seconds from now) and holds
## until the blow has landed and a beat after.
func _aim_before(i: int, aim: Array, attack_at: float, landed: float, cid: String) -> void:
	if float(aim[1]) <= 0.0 or not is_inside_tree():
		return
	var view: MechView3D = _mech_3d[i]
	var start := maxf(0.0, attack_at - float(aim[1]))
	# Held until the blow has landed and its firing slice has played out, a beat after either (Ryan,
	# 3 November: the Buzzard's cannon "turns back before the hit is complete").
	var hold := maxf(0.0, maxf(landed, attack_at + view.fire_span(cid)) + AIM_HOLD - attack_at)
	if start <= 0.0:
		view.aim_at(cid, float(aim[0]), hold)
		return
	var tw := create_tween()
	tw.tween_interval(start)
	tw.tween_callback(_aim_view.bind(view, cid, float(aim[0]), hold))


func _use_view(view: MechView3D, cid: String) -> void:
	if is_instance_valid(view):
		view.use(cid)


## How long machine `i`'s spend winds up before its blow (MechView3D.fire_wind), nought with no 3D.
func _fire_wind(i: int, spent: Face) -> float:
	if spent == null or i < 0 or i >= _mech_3d.size() or _mech_3d[i] == null:
		return 0.0
	return _mech_3d[i].fire_wind(spent.component)


## Start machine `i`'s firing slice `at` seconds from now, its wind-up playing before the blow lands
## (the blow's kick, flash and landing come at the blow, _animate_attack told it is wound).
func _wind_up(i: int, ranged: bool, cid: String, at: float) -> void:
	if i < 0 or i >= _mech_3d.size() or _mech_3d[i] == null or not is_inside_tree():
		return
	if at <= 0.0:
		_mech_3d[i].strike(ranged, cid)
		return
	var tw := create_tween()
	tw.tween_interval(at)
	tw.tween_callback(_strike_view.bind(_mech_3d[i], ranged, cid))


func _strike_view(view: MechView3D, ranged: bool, cid: String) -> void:
	if is_instance_valid(view):
		view.strike(ranged, cid)


func _aim_view(view: MechView3D, cid: String, deg: float, hold: float) -> void:
	if is_instance_valid(view):
		view.aim_at(cid, deg, hold)


## How far machine `i` turns to its left to face `target` across the floor: the bearing from its
## hex to the foe's feet (the floor's camera run backward from the screen), less the turn it
## already stands at toward the middle.
func _aim_turn(i: int, target: UnitView) -> float:
	var origin: Vector2 = _home.get(target, target.position)
	var feet := origin + Vector2(target.size.x * 0.5, target.feet_y if target.feet_y >= 0.0 else target.size.y * 0.5)
	var below: float = feet.y - float(_cam.horizon)
	if below <= 1.0:
		return 0.0
	var z: float = float(_cam.focal) * float(_cam.height) / below
	var x: float = (feet.x - W * 0.5) * z / float(_cam.focal)
	var bearing := rad_to_deg(atan2(x - _slot_hex_x(_mech_slot(i)), z - float(_cam.depth)))   # to the right, as the floor's x runs
	return -bearing - _mech_turn(i)


## A foe dies: a ghost of its drawing, where it stood, flashes, drops and fades, in the
## enemy's colour. The slot itself is already empty (a kill clears it at once), so the ghost
## stands in for the foe until the blow lands (`lands`), then goes.
func _animate_death(v: UnitView, tex: Texture2D, frame: Rect2, flip: bool, lands: float = 0.0, home = null) -> void:
	if not is_inside_tree() or v == null or tex == null:
		return
	var ghost := TextureRect.new()
	ghost.texture = tex
	ghost.flip_h = flip
	ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost.stretch_mode = TextureRect.STRETCH_SCALE
	ghost.texture_filter = v.texture_filter
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.position = (home if home is Vector2 else _home.get(v, v.position)) + frame.position   # where the view stood as it died: a pair's view may since rest elsewhere
	ghost.size = frame.size
	add_child(ghost)
	var tw := create_tween()
	if lands > 0.0:
		tw.tween_interval(lands)
	tw.tween_property(ghost, "modulate", Color(2.0, 1.2, 1.2), 0.06)
	tw.tween_property(ghost, "modulate", Color(Palette.LOSS_DIM, 1.0), 0.12)
	tw.set_parallel(true)
	tw.tween_property(ghost, "modulate", Color(Palette.LOSS_DIM, 0.0), 0.4)
	tw.tween_property(ghost, "position:y", ghost.position.y + 16.0, 0.4).set_ease(Tween.EASE_IN)
	tw.set_parallel(false)
	tw.tween_callback(ghost.queue_free)


## What a control looks like at rest: an empty foe slot sits faint, everything else plain.
func _rest_modulate(v: Control) -> Color:
	if v is UnitView and v.is_enemy and not _view_foe.has(v) and not _stand_ins.values().has(v):
		return Color(1, 1, 1, 0.3)
	return Color.WHITE


## The struck unit flashes bright, then shakes side to side and settles. A machine drawn in 3D
## takes the blow on its model instead (the to-do's hit reaction, on Ryan's go of 3 November):
## `kind` "hull" or "block" shoves it back and flashes its hull in heat's colour, the
## armour's block at half (MechView3D.hit), "shield" ripples its shield in the shield's blue and
## moves nothing, "none" nothing at all (a shield that broke taking the whole blow, its shatter
## being the only mark); `side`, -1 to 1, where across the screen the blow came from.
func _animate_hit(v: UnitView, delay: float = 0.0, kind: String = "hull", side: float = 0.0) -> void:
	if not is_inside_tree() or v == null:
		return
	var mi := _mech_views.find(v)
	if mi >= 0 and mi < _mech_3d.size() and _mech_3d[mi] != null:
		if kind == "none":
			return
		if delay <= 0.0:
			_hit_machine(mi, kind, side)
		else:
			var hw := create_tween()
			hw.tween_interval(delay)
			hw.tween_callback(_hit_machine.bind(mi, kind, side))
		return
	_settle(v)
	var origin: Vector2 = _home.get(v, v.position)
	var tw := _track(v, create_tween())
	tw.tween_interval(delay)
	tw.tween_property(v, "modulate", Color(1.8, 1.4, 1.4), 0.04)
	tw.tween_property(v, "modulate", _rest_modulate(v), 0.22)
	var shake := _track(v, create_tween())
	shake.tween_interval(delay)
	for k in range(4):
		var dx := (5.0 - k * 1.2) * (1.0 if k % 2 == 0 else -1.0)
		shake.tween_property(v, "position", origin + Vector2(dx, 0.0), 0.035)
	shake.tween_property(v, "position", origin, 0.05)


## What took a blow on a machine, for its reaction (_animate_hit): a shield that held ("shield",
## its ripple), a shield that broke taking it all ("none": its shatter is the only mark), the hull
## ("hull": a jolt and heat's flash) or the armour turning it on the bare hull ("block", at half).
static func blow_took(held: bool, broke: bool, through: int) -> String:
	if held:
		return "shield"
	if broke and through <= 0:
		return "none"
	return "hull" if through > 0 else "block"


func _hit_machine(mi: int, kind: String, side: float) -> void:
	if mi < 0 or mi >= _mech_views.size():
		return
	if kind == "shield":
		_mech_views[mi].ripple_shield()
	elif mi < _mech_3d.size() and is_instance_valid(_mech_3d[mi]):
		_mech_3d[mi].hit(kind, side)


## Where across the screen `from` stands from `to`, -1 (far left) to 1 (far right): the side a blow
## came from, for the struck machine's flash and the way it is shoved.
func _side_of(from: Control, to: Control) -> float:
	if from == null or to == null:
		return 0.0
	var a: Vector2 = _home.get(from, from.position) + from.size * 0.5
	var b: Vector2 = _home.get(to, to.position) + to.size * 0.5
	return clampf((a.x - b.x) / (W * 0.4), -1.0, 1.0)


## The hit debug switch's beat (HIT_DEBUG): the next machine takes the next kind of blow, and every
## fifth beat one is lost and lit again two seconds later.
func _hit_debug() -> void:
	var i := _hit_debug_n % _mech_views.size()
	_hit_debug_n += 1
	if _hit_debug_n % 5 == 0 and i < _mech_3d.size() and _mech_3d[i] != null:
		_mech_3d[i].lose()
		var tw := create_tween()
		tw.tween_interval(2.0)
		tw.tween_callback(func() -> void:
			if is_instance_valid(_mech_3d[i]):
				_mech_3d[i].revive())
		return
	var k: Array = HIT_DEBUG_KINDS[_hit_debug_n % HIT_DEBUG_KINDS.size()]
	_animate_hit(_mech_views[i], 0.0, str(k[0]), float(k[1]))


## What the replay needs before the sim runs the enemy's turn: every field foe's view now (a
## slot a reinforcement takes afterwards must never lunge as if it had struck), and every
## mech's shield and hull as they stand, for the gauges to wind back to.
func _before_enemy_turn() -> Dictionary:
	var views: Dictionary = {}
	for foe in sk.field_foes():
		views[foe] = _foe_view_for(foe)
	var gauges: Array = []
	for ms in sk.mechs:
		gauges.append([ms.unit.shield, ms.unit.hull])
	return {"views": views, "gauges": gauges}


## Seconds between the enemy's blows: the ENEMY PACE setting divides the beat, so its top
## is the old instant replay.
func _enemy_beat() -> float:
	return ENEMY_BEAT / clampf(float(Settings.display.get("enemy_pace", 1.0)), 0.1, 10.0)


## The enemy's turn the sim just resolved, replayed one blow a beat: the foe lunges down at
## its mech, and as the blow lands the mech's shield and hull step down to what it left, a
## broken shield shattering. Then `then` runs: the next round, or the outcome. Off the tree
## (tests, headless) it all happens at once.
func _play_enemy_turn(before: Dictionary, then: Callable) -> void:
	var steps := _replay_steps(before)
	var hits: Array = []
	for st in steps:
		if not (st["blow"] as Array).is_empty():
			hits.append(st["blow"])
	if not is_inside_tree() or (steps.is_empty() and sk.overheats.is_empty()):
		then.call()
		return
	# The burn is the end of the player's own turn (11 October): it lands before the phase
	# turns over to the enemy.
	_set_phase("ASSIGN" if not sk.overheats.is_empty() else "ENEMY PHASE")
	_replay_shade.visible = true
	_replay_shade.move_to_front()
	if _menu != null:
		_menu.move_to_front()
	# The gauges wind back to before the turn, plain (no forecast pulse: it is happening).
	var gauges: Array = before["gauges"]
	for i in range(_mech_views.size()):
		var v := _mech_views[i]
		if v.bars.size() >= 2 and i < gauges.size():
			v.bars[0] = [gauges[i][0], v.bars[0][1], v.bars[0][2]]
			v.bars[1] = [gauges[i][1], v.bars[1][1], v.bars[1][2]]
			if v.bars.size() >= 3:
				v.bars[2] = v.bars[2].slice(0, 3)
			v.queue_redraw()
	# The machines that fall this turn, to a blow or to the burn, in the order they fall: each
	# dies at the end of the turn, one after another, with nothing over it (Ryan, 9 October).
	var deaths: Array = []
	_dying.clear()
	for ov in sk.overheats:
		var oi: int = ov["mech"]
		if oi >= 0 and oi < _mech_views.size() and int(ov["hull"]) <= 0 and not _mech_views[oi].dead and not _dying.has(_mech_views[oi]):
			_dying[_mech_views[oi]] = true
			deaths.append([_mech_views[oi], _maker_of(sk.mechs[oi])])
	for h in hits:
		if int(h[5]) <= 0 and not h[1].dead and not _dying.has(h[1]):
			_dying[h[1]] = true
			deaths.append([h[1], h[10]])
	var beat := _enemy_beat()
	# Each foe lights a beat before its move lands and stays lit through it (Ryan, 2 November:
	# "enemies need to highlight during their attacks, starting right before"); the next foe's lead
	# comes out of the beat after the last blow, so the turn keeps its pace.
	var lead := beat * ACT_LEAD
	var tw := create_tween()
	if not sk.overheats.is_empty():
		tw.tween_callback(_land_overheats)
		tw.tween_interval(beat)
		tw.tween_callback(_set_phase.bind("ENEMY PHASE"))
	for k in range(steps.size()):
		var st: Dictionary = steps[k]
		var actor = before["views"].get(st["foe"])
		if k == 0:
			tw.tween_callback(_spotlight.bind(actor))
			tw.tween_interval(lead)
		if not str(st["announce"]).is_empty():
			tw.tween_callback(_announce.bind(str(st["announce"])))
			tw.tween_interval(PLAQUE_HOLD)
		var switching: bool = k + 1 < steps.size() and before["views"].get(steps[k + 1]["foe"]) != actor
		if not (st["blow"] as Array).is_empty():
			tw.tween_callback(_land_blow.bind(st["blow"]))
			tw.tween_interval(beat - lead if switching else beat)
		if switching:
			# The next foe lights while this one's move settles, its lead out of the beat.
			tw.tween_callback(_spotlight.bind(before["views"].get(steps[k + 1]["foe"])))
			tw.tween_interval(lead)
	tw.tween_callback(_spotlight.bind(null))
	for d in deaths:
		tw.tween_callback(_land_death.bind(d[0], d[1]))
		tw.tween_interval(Sound.death_span(d[1]))
	tw.tween_interval(0.25)
	tw.tween_callback(func() -> void:
		_replay_shade.visible = false
		then.call())


## The enemy's turn as the replay plays it, in the order it happened: every blow (with the
## struck mech's gauges after it) and every special, merged by the sim's sequence numbers.
## Each step is {seq, announce, blow}: `announce` is the name the plaque shows first (a
## special's always; a boss's blow's and a blow at every machine's once per move, so a
## three-strike storm says it once; a plain blow's never), and `blow` is the blow to land after it, or empty for a special.
func _replay_steps(before: Dictionary) -> Array:
	var steps: Array = []
	for ev in sk.turn_events:
		var mi: int = ev["mech"]
		if mi < 0 or mi >= _mech_views.size():
			continue
		steps.append({"seq": int(ev.get("seq", steps.size())), "foe": ev["foe"], "name": str(ev.get("name", "")),
			"named": bool(ev.get("boss", false)) or bool(ev.get("all", false)), "announce": "",
			"blow": [before["views"].get(ev["foe"]), _mech_views[mi], bool(ev["broke_shield"]),
				bool(ev.get("blocked", false)), int(ev["shield"]), int(ev["hull"]),
				int(ev.get("absorbed", 0)) + int(ev.get("through", 0)),
				int(ev.get("through", 0)), str(ev.get("component", "")),
				ContentDB.load_default().faction_of_foe(ev["foe"].content_id) if ev["foe"] != null else "",
				_maker_of(sk.mechs[mi])]})
	for sp in sk.turn_specials:
		steps.append({"seq": int(sp.get("seq", 0)), "foe": sp["foe"], "name": str(sp.get("name", "")),
			"named": true, "announce": "", "blow": []})
	steps.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["seq"]) < int(b["seq"]))
	var last_foe = null
	var last_name := ""
	for st in steps:
		if bool(st["named"]) and not (st["foe"] == last_foe and str(st["name"]) == last_name):
			st["announce"] = str(st["name"])
		last_foe = st["foe"]
		last_name = str(st["name"])
	return steps


var _lit: UnitView = null   # the foe lit as it acts in the enemy's turn


## Light `v` as the foe acting now, and put out the one lit before; null puts it out.
func _spotlight(v) -> void:
	if _lit != null and is_instance_valid(_lit):
		_lit.acting = false
		_lit.queue_redraw()
	_lit = v if v is UnitView and is_instance_valid(v) else null
	if _lit != null:
		_lit.acting = true
		_lit.set_process(true)
		_lit.queue_redraw()


## The plaque: the move's name in the other world's window, centred over the foes' rows,
## above everything but the menu.
func _announce(name: String) -> void:
	if _plaque == null:
		return
	var sz := _plaque.size_for(name.to_upper())
	_plaque.position = Vector2((W - sz.x) * 0.5, BACK_Y + PLAQUE_Y * H / BASE_H)
	_plaque.announce(name, PLAQUE_HOLD)
	_plaque.move_to_front()
	if _menu != null:
		_menu.move_to_front()


## One blow of the replay: [foe view or null, mech view, broke shield, blocked, shield after,
## hull after, damage, through to hull, what an injury did, the striker's family, the struck
## machine's maker]. A striker whose slot has since emptied
## (killed by burn) still lands its blow.
##
## Heard as the family's blow (its heavy blow from HEAVY_DAMAGE), then what took it: a
## standing shield (the shield hit), the shield breaking, the armour turning it on bare hull
## (the maker's block), or the hull (the maker's hit), and a machine that falls its maker's
## kill. Jenny: a component destroyed. A machine the blow fells dies at the end of
## the turn (`_land_death`), not here.
func _land_blow(h: Array) -> void:
	var fv: UnitView = h[0]
	var mv: UnitView = h[1]
	var broke: bool = h[2]
	var held: bool = h[3]
	var shield_after: int = h[4]
	var hull_after: int = h[5]
	var through: int = h[7]
	var injury: String = h[8]
	var maker: String = h[10]
	var foe_blow := Sound.family("heavy" if int(h[6]) >= HEAVY_DAMAGE else "hit", h[9])
	var landed := maxf(0.08, Sound.lands(foe_blow))
	var took := blow_took(held, broke, through)
	if fv != null and fv.visible:
		_animate_attack(fv, mv, false, false, landed)
	_animate_hit(mv, landed, took, _side_of(fv, mv) if fv != null else 0.0)
	Sound.play(foe_blow)
	var struck := "shield_break" if broke else ("shield_hit" if held else (Sound.struck("hit", maker) if through > 0 else Sound.struck("block", maker)))
	Sound.play_after(landed, struck, 0.0 if broke else -3.0)
	if _dying.has(mv):
		pass   # its death comes at the end of the turn
	elif injury == "destroyed":
		Sound.say_after(landed + VOICE_AFTER_BLOW, "component_destroyed")
	var t2 := create_tween()
	t2.tween_interval(landed)
	t2.tween_callback(func() -> void:
		if mv.bars.size() >= 2:
			mv.bars[0][0] = shield_after
			mv.bars[1][0] = hull_after
		mv.queue_redraw()
		if broke:
			mv.shatter_shield())


## A machine lost, at the end of the enemy's turn: the wreck shown, its maker's death, and
## Jenny's "machine lost" in that death's gap (Sound.death_voice_at); the replay waits out
## Sound.death_span before anything else.
var _dying: Dictionary = {}

func _land_death(mv: UnitView, maker: String) -> void:
	Sound.play(Sound.struck("kill", maker))
	Sound.say_after(Sound.death_voice_at(maker), "machine_lost")
	# The kill's own beat (Ryan's go of 3 November): a machine drawn in 3D has its lit parts gutter
	# out and its outline dim (MechView3D.lose), the wreck shown once they have.
	var mi := _mech_views.find(mv)
	if mi >= 0 and mi < _mech_3d.size() and _mech_3d[mi] != null and is_inside_tree():
		_mech_3d[mi].lose()
		var tw := create_tween()
		tw.tween_interval(MechRig.GUTTER)
		tw.tween_callback(func() -> void:
			mv.dead = true
			mv.queue_redraw())
		return
	mv.dead = true
	mv.queue_redraw()


## The turn's overheats land together before the enemy's blows (the sim burns them as the
## player's turn ends, all at once): the machines that ran hot flinch and their hull steps
## down. Heard once, however many burn.
func _land_overheats() -> void:
	Sound.play("overheat")
	for ov in sk.overheats:
		var i: int = ov["mech"]
		if i < 0 or i >= _mech_views.size():
			continue
		var mv := _mech_views[i]
		_animate_hit(mv)
		if mv.bars.size() >= 2:
			mv.bars[1][0] = int(ov["hull"])
		mv.queue_redraw()   # one the burn fells dies at the end of the turn (`_land_death`)


## Every animation on a control returns it to where it was placed. Whatever is still
## moving it is stopped first, so a second blow landing mid-shake cannot carry the unit off
## (Ryan, 22 September: mechs drifted out of position under fire).
func _settle(v: Control) -> void:
	for tw in _live_tweens.get(v, []):
		if tw.is_valid():
			tw.kill()
	_live_tweens.erase(v)
	if _home.has(v):
		v.position = _home[v]
		v.modulate = _rest_modulate(v)


func _track(v: Control, tw: Tween) -> Tween:
	if not _live_tweens.has(v):
		_live_tweens[v] = []
	_live_tweens[v].append(tw)
	return tw


## A reinforcement steps in: it fades up and drops into its slot after `delay`, so a fresh
## foe in a slot whose last holder just died reads as an arrival, never a resurrection.
func _animate_arrival(v: UnitView, delay: float) -> void:
	if not is_inside_tree() or v == null:
		return
	_settle(v)
	var home: Vector2 = _home.get(v, v.position)
	v.modulate = Color(1, 1, 1, 0)
	v.position = home + Vector2(0, -28.0)
	var tw := _track(v, create_tween())
	tw.tween_interval(delay)
	tw.set_parallel(true)
	tw.tween_property(v, "modulate", Color.WHITE, 0.28)
	tw.tween_property(v, "position", home, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------- buttons and confirms

func _ask(text: String, on_yes: Callable) -> void:
	_confirm_text.text = text
	_confirm_action = on_yes
	_confirm_shade.visible = true
	_confirm.visible = true
	_confirm.reset_size()


func _hide_confirm() -> void:
	_confirm.visible = false
	_confirm_shade.visible = false
	_confirm_action = Callable()


func _confirm_yes() -> void:
	var action := _confirm_action
	_hide_confirm()
	if action.is_valid():
		action.call()


## The dice a REROLL rolls: every unspent, unlocked die of a machine still standing; with none,
## the button is dark (the audit's tenth bug, 8 November).
func _reroll_indices() -> Array:
	var idx: Array = []
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		if ms.alive() and not ms.assigned and not locked[i]:
			idx.append(i)
	return idx


func _on_reroll() -> void:
	if not _pending.is_empty():
		_cancel_second()   # a reroll takes the waiting die back to the tray first
	var idx := _reroll_indices()
	if not sk.reroll(idx):
		_refresh()
		return
	_refresh()
	if not idx.is_empty():
		Sound.play("die_roll")
	if is_inside_tree():
		for i in idx:
			var d := _dice[i]
			d.pivot_offset = d.size * 0.5
			d.scale = Vector2(0.15, 1.0)
			var tw := create_tween()
			tw.tween_property(d, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## UNDO's reach: the spends and rerolls since the last roll, its badge; off while a spend's
## blow still plays, while the enemy's turn replays, and with nothing to take back.
func _refresh_undo() -> void:
	if _undo_btn == null:
		return
	var depth := sk.undo_depth()
	_undo_btn.badge = "×%d" % depth if depth > 0 else ""
	_undo_btn.set_enabled(sk.can_undo() and not _replay_shade.visible and Time.get_ticks_msec() >= _undo_from)


## UNDO (Ryan, 2 November: "undo to your last roll"): the last spend or reroll taken back, in
## the order made, the fight as it was before it, never past a roll (the round's, a reroll's
## draw, a spend's own: Rapid's reroll, a roll again, the Scorpion's blast). A reading or a
## pending Swap is put away first.
func _on_undo() -> void:
	if _replay_shade.visible or not sk.can_undo() or Time.get_ticks_msec() < _undo_from:
		return
	if not _pending.is_empty():
		_cancel_second()
	_close_pop()
	_flush_blows()   # whatever of the last spend is still landing lands now, before the fight it struck is taken back
	sk.undo()
	Sound.play("ui_back")
	_refresh()


## A die rolled again by a stack it spent (the Nemesis's rage, Ryan, 13 October): the stack's
## chip bursts as it goes, then the die flips back with the reroll's own flip and sound. The
## die waits folded until then, so its new face is never seen before the roll.
func _roll_again(i: int, status: String) -> void:
	_mech_views[i].spend_chip(status_glyph(status))
	var d := _dice[i]
	if not is_inside_tree():
		return
	d.pivot_offset = d.size * 0.5
	d.scale = Vector2(0.06, 1.0)
	var tw := create_tween()
	tw.tween_interval(ROLL_AGAIN_AT)
	tw.tween_callback(func() -> void: Sound.play("die_roll"))
	tw.tween_property(d, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## RIFTGATE_RAGE_DEBUG: the rage bar on the machine that banks rage (the first machine when none
## does) fills two a beat and empties at its cap, so the bar's notches and the die's charged
## mark at five are seen to come and go. Nothing is spent by a spend.
func _rage_debug() -> void:
	var at := 0
	for k in range(sk.mechs.size()):
		if Effects.store_cap(sk.mechs[k].unit, "rage") > 0:
			at = k
	if sk.mechs.is_empty() or not sk.mechs[at].alive():
		return
	var u := sk.mechs[at].unit
	var cap := maxi(1, Effects.store_cap(u, "rage"))
	if Effects.stacks_of(u, "rage") >= cap:
		Effects.spend_stacks(u, "rage", Effects.stacks_of(u, "rage"))
	else:
		Effects.stack(u, Effects.STATUS["rage"], Effects.SKIRMISH, "debug", mini(2, cap - Effects.stacks_of(u, "rage")), Effects.DECAY_NONE)
	_refresh()


## Live dice that still hold a usable face.
func _unspent_count() -> int:
	var n := 0
	for i in range(sk.mechs.size()):
		if sk.can_spend(i):
			n += 1   # a die with somewhere to be spent, as END TURN's pulse reads it (the audit's twelfth bug, 8 November): a dry gun or an unpayable cost is no waste
	return n


## End turn asks first only when usable dice would go to waste.
func _on_end_turn() -> void:
	if sk.state != Skirmish.State.ASSIGN:
		return
	if not _pending.is_empty():
		_cancel_second()
	var n := _unspent_count()
	if n > 0:
		_ask("%d %s still unspent. End the turn anyway?" % [n, "die is" if n == 1 else "dice are"], _end_turn_now)
	else:
		_end_turn_now()


## Ends the player's turn: unspent blank faces are discarded, the enemy acts and its turn
## replays, then the next round shows so the player is straight back to their own dice.
func _end_turn_now() -> void:
	if sk.state != Skirmish.State.ASSIGN:
		return
	_flush_blows()   # the last spend's blows land before the enemy moves
	_close_pop()   # a readout is for planning the turn: the enemy's plays without one
	Sound.play("resolve", -4.0)
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		if ms.alive() and not ms.assigned and ms.face() != null and ms.face().kind == Face.Kind.BLANK:
			sk.assign(i, null)
	var before := _before_enemy_turn()
	var field_before: Array[Foe] = sk.field_foes()
	# The foes ready to get back up, as they look now: one that falls in the enemy's turn (to its
	# Burning, to a Mine's blast) and stands again is shown dying and rising
	# once the turn has played (26 October), as one killed by a die is.
	var readied := {}
	for foe in field_before:
		var rv := _foe_view_for(foe)
		if Effects.has(foe, "risen") and rv != null:
			readied[foe] = [rv, rv.sprite, rv.sprite_frame(), rv.flip_h, _home.get(rv, rv.position)]
	var returns_before := sk.returned.size()
	var outcome := sk.end_round()
	var rose_in_turn := _risen_since(returns_before)   # read before the next round's start clears the returns
	if outcome == Skirmish.Outcome.NONE:
		sk.start_round()
		_heat_rearm()   # the machines have cooled: one back under three quarters can be warned again
		for i in range(locked.size()):
			locked[i] = false
	_refresh_log()   # the blows type into the log as they play
	_play_enemy_turn(before, func() -> void:
		if outcome != Skirmish.Outcome.NONE:
			_show_outcome(outcome)
			return
		_refresh()
		_acquire_intents()
		# A foe that got back up in the enemy's turn falls on screen, then stands again.
		var rose := 0
		for foe in readied.keys():
			if not rose_in_turn.has(foe) or not sk.field_foes().has(foe):
				continue
			var w: Array = readied[foe]
			_animate_death(w[0], w[1], w[2], w[3], 0.05 + 0.2 * rose, w[4])
			Sound.play_after(0.05 + 0.2 * rose, "kill", -4.0)
			_animate_arrival(_foe_view_for(foe), 0.5 + 0.2 * rose)
			rose += 1
		# Then the reinforcements step in.
		var arrived := 0
		for foe in sk.field_foes():
			if not field_before.has(foe):
				_animate_arrival(_foe_view_for(foe), 0.1)
				Sound.play_after(0.36 + 0.09 * arrived, "arrival", -3.0 * arrived)
				arrived += 1)


func _show_outcome(outcome: int) -> void:
	_refresh()
	match outcome:
		Skirmish.Outcome.VICTORY:
			Sound.voice_clear()
			Sound.play("victory")
			_overlay_title.text = "VICTORY"
			_overlay_text.text = "The pack is gone."
		Skirmish.Outcome.DEFEAT:
			Sound.play("defeat")
			_overlay_title.text = "WRECKED"
			_overlay_text.text = "Every machine is down. Survivors of the pack march on."
		_:
			Sound.play("withdraw")
			_overlay_title.text = "WITHDREW"
			_overlay_text.text = "%d foes remain on the field. They keep marching." % sk.field_foes().size()
	_overlay.visible = true
	finished.emit(outcome)

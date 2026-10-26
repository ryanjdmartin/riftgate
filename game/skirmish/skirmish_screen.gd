class_name SkirmishScreen
extends Control

## The skirmish screen as a tactical overlay. Portrait, 720x1280 logical, positioned
## absolutely so every coordinate is a plain number.
##
##   header      round and reinforcements tag, phase readout, MENU at the right
##   formation   two ranks of four unit views; a massive foe spans both ranks of its column;
##               under each foe its intent (fantasy icon and number) and its statuses
##   log         every event, scrollable, the newest brightest; double-tap for it full screen;
##               the intent eye at its right, in the black between the two grounds
##   dice        tap to lock, hold to see every face, drag onto a target to spend; the wide
##               Reroll sits right under them, before or after attacking
##   mechs       gauges hugging the sprite, warning chips under it: shield break, component
##               risk, wreck, overheat; the gauges pulse where they are about to change
##   bottom      End turn bottom-left, Withdraw bottom-right; both ask first when it matters
##
## No names on screen. Kinetic faces roll when they land and the number flashes over the
## target. Hold a unit for numbers, statuses and arrows, a die for every entry and what
## applies to it. Double-tap a unit for its codex entry.
##
## The enemy's turn is replayed blow by blow at the ENEMY PACE setting, the struck mech's
## gauges stepping down as each lands, before the next round's dice show or the outcome
## (a withdrawal included: Ryan, 23 September). Taps are held off while it plays.

signal finished(outcome: int)
signal back_requested
signal quit_requested   # the menu's QUIT: the host leaves for the harness

var back_label := "BACK"   # the outcome's button: the battle screen says where back leads
var music_set := "skirmish"   # the set this fight plays: the skirmish's pick, or a family's boss theme the battle screen already started at contact
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
var DIE_Y := 640.0
const DIE_SIZE := 120.0
var REROLL_Y := 786.0
const REROLL_SIZE := Vector2(250, 54)
const REROLL_GAP := 30.0   # black between Reroll and the mechs' ground (Ryan, 23 September: 14 was too tight)
var MECH_Y := 892.0
const MECH_SIZE := Vector2(176, 284)   # gauges 46 + 80x96 sprite at 2x + chip row 38; neighbours overlap 4 px at PITCH
var BOTTOM_Y := 1196.0
## The rows' places on the 1280 design, scaled to the screen in `_build`.
const ROWS := {"BACK_Y": 72.0, "FRONT_Y": 266.0, "EYE_Y": 510.0, "LOG_Y": 508.0, "DIE_Y": 640.0, "REROLL_Y": 786.0, "MECH_Y": 892.0, "BOTTOM_Y": 1196.0}
const BOTTOM_BTN := Vector2(210, 60)
const PITCH := 172.0
const LOG_LINES := 7
const ENEMY_BEAT := 0.45   # seconds between the enemy's blows at ENEMY PACE 1; the setting divides it
const PLAQUE_HOLD := 1.0   # seconds the replay holds on a named move's plaque (decided 9 October; a placeholder, judged running); the pace setting does not shorten a read
const PLAQUE_Y := -10.0    # the plaque's top, from the back rank's row: over the foes, where the other world is
## RIFTGATE_PLAQUE_DEBUG=1: the plaque fires one of the field's move names after another.
static var PLAQUE_DEBUG := OS.get_environment("RIFTGATE_PLAQUE_DEBUG") == "1"
## RIFTGATE_POOL_DEBUG=1: every couple of seconds a foe on the field flies into the pool, to judge
## the join running (the counts land back where they were).
static var POOL_DEBUG := OS.get_environment("RIFTGATE_POOL_DEBUG") == "1"
var _pool_debug_at := 0.0
## RIFTGATE_RAGE_DEBUG=1: the rage's roll again plays over and over on the machine that
## spends rage (its chip bursts, its die flips back with the reroll's sound), to judge running.
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
const ROLL_AGAIN_AT := 0.3   # the die flips back this long after its stack bursts (a placeholder, judged running)
var _rage_debug_at := -10.0

var sk: Skirmish
var locked: Array[bool] = []
var show_all_arrows: bool = false

var _header: HudButton
var _sub_label: Label
var _eye: HudButton
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
var _details_faces: FaceListView
var _details_ring: CylinderView      # a stepping die's chambers in its hold (the Cassowary's)
var _details_status: StatusListView
var _roll_label: Label
var _codex: CodexBox                 # the spec plate, shared with the battle screen
var _mech_3d: Array[MechView3D] = [] # parallel to _mech_views; null where the mech is a sprite
var _bg: HudBackdrop = null
var _plaque: Plaque = null           # the other world's window: a foe's named move, announced
var _plaque_debug_at := 0.0
var _prey: PreyLayer = null          # the predator sense: the foes' ground dimmed, eyes on the foes looking away
var _reserve: ReserveView = null     # the reinforcements waiting, by rank, in the formation's right gutter
var _hold_die: int = -1              # the die being held, for the sense


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
	if POOL_DEBUG and _fight_t - _pool_debug_at > 2.2 and not sk.field_foes().is_empty():
		_pool_debug_at = _fight_t
		var live := sk.field_foes()
		var f: Foe = live[int(_fight_t) % live.size()]
		var kind := "massive" if f.is_massive() else ("back" if f.prefers_back else "front")
		_reserve.counts[kind] = int(_reserve.counts.get(kind, 0)) + 1   # shown as one more waiting, for the look
		_animate_pool_join(f, 0.0)
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
		view.set_sweep_screen((y - v.position.y) * float(view.size.y) / v.size.y)


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
var _end_btn: HudButton
var _withdraw_btn: HudButton
var _overlay: Control
var _overlay_title: Label
var _overlay_text: Label
var _replay_shade: Control            # swallows taps while the enemy's turn replays
var _fx: FeedFX = null                # the display's rare analysis events
var _drag_from: int = -1
var _log_seen: int = 0
var _hold_foe: Foe = null
var _hold_mech: int = -1
var _drag_over = null                 # what the dragged die is over and may be spent on: a Foe, a MechState or an empty slot
var _round: Dictionary = {}           # the rest of the round as it stands (Skirmish.preview_round): every machine's gauges and warnings, every foe's HP after it
var _turns: Array[Foe] = []           # the foes a Lure in hand would turn, their arrows drawn dashed to the die's machine


func setup(skirmish: Skirmish) -> void:
	sk = skirmish
	locked.clear()
	for m in sk.mechs:
		locked.append(false)
	if sk.state == Skirmish.State.SETUP:
		sk.begin()
	if sk.state == Skirmish.State.ROUND_START:
		sk.start_round()
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
	Sound.music(music_set)   # the set already playing (a boss theme from the field) carries on


## Standalone default, used when the scene runs on its own (screenshots, quick checks): two
## chained packs of the first faction in content. RIFTGATE_TEAM=badger,clydesdale,sparrowhawk,baboon overrides the team;
## RIFTGATE_BOSS=1 adds the faction's boss as a third unit; RIFTGATE_COLUMNS=4 widens the formation.
static func _default_skirmish() -> Skirmish:
	var db := ContentDB.load_default()
	var s := Skirmish.new(7, int(OS.get_environment("RIFTGATE_COLUMNS")) if not OS.get_environment("RIFTGATE_COLUMNS").is_empty() else Skirmish.DEFAULT_COLUMNS)
	var team: Array = db.default_team()
	var env := OS.get_environment("RIFTGATE_TEAM")
	if not env.is_empty():
		team = env.split(",")
	# RIFTGATE_PAINT=badger:ff8800/223344,sparrowhawk:ffffff repaints for a look (primary/secondary).
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
	# The first faction's first and last spawn entries: its rank and file, then its support.
	# RIFTGATE_FOES=warrior,goblin:3,white_mage puts those foes on instead, by content id and
	# count (heroes included), each its own pack: to see any sprite in the fight.
	var fac := db.default_faction()
	var table: Array = db.spawn_table(fac)
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
	custom_minimum_size = Vector2(W, H)
	Hud.inset_screen(self)   # clear of the phone's corners, cutout and gesture zone
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR   # text linear; the ground bands and the sprites pin nearest on themselves

	var bg := HudBackdrop.new()
	var seam_y := REROLL_Y + REROLL_SIZE.y + REROLL_GAP
	bg.rules = [BACK_Y - 14.0, LOG_Y - 10.0, seam_y, BOTTOM_Y - 16.0]
	# The fight is on the enemy's ground (Ryan, 21 September): the foes stand on the other
	# world's flat bright overworld of this terrain; the mechs stand on the seam, the
	# reconstruction's tile with the other world eating into it from above.
	bg.grounds = [
		[Rect2(0.0, BACK_Y - 14.0, W, LOG_Y - 10.0 - (BACK_Y - 14.0)), sk.terrain, sk.rng.seed, "other"],
		[Rect2(0.0, seam_y, W, BOTTOM_Y - 16.0 - seam_y), sk.terrain, sk.rng.seed + 1, "seam"],
	]
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
	_eye.tooltip_text = "Show every intent arrow"
	_eye.toggled.connect(_toggle_all_arrows)
	_place(_eye, Vector2(W - 12 - EYE, EYE_Y), Vector2(EYE, EYE))

	# Formation: six slot views, three massive views (hidden until needed). Ranks need no
	# label; the back rank is the one behind.
	for col in range(sk.columns):
		for rank in range(2):
			var v := UnitView.new()
			v.is_enemy = true
			var y := FRONT_Y if rank == 0 else BACK_Y
			_place(v, Vector2(_col_x(col) - SLOT_SIZE.x * 0.5, y), SLOT_SIZE)
			v.held.connect(_on_foe_held.bind(v))
			v.hold_released.connect(_on_hold_released)
			v.double_tapped.connect(_on_foe_double_tapped.bind(v))
			v.tapped.connect(_on_slot_tapped.bind(rank, col))
			_slot_views[rank][col] = v
			# A twin slot's right-hand half (26 October): the slot's right half while the pair
			# stands, the left half's view taking the other.
			var tv := UnitView.new()
			tv.is_enemy = true
			tv.visible = false
			_place(tv, Vector2(_col_x(col), y), Vector2(SLOT_SIZE.x * 0.5, SLOT_SIZE.y))
			tv.held.connect(_on_foe_held.bind(tv))
			tv.hold_released.connect(_on_hold_released)
			tv.double_tapped.connect(_on_foe_double_tapped.bind(tv))
			tv.tapped.connect(_on_twin_tapped.bind(rank, col))
			_twin_views[rank][col] = tv
		var mv := UnitView.new()
		mv.is_enemy = true
		mv.massive = true
		mv.visible = false
		_place(mv, Vector2(_col_x(col) - MASSIVE_SIZE.x * 0.5, BACK_Y), MASSIVE_SIZE)
		mv.held.connect(_on_foe_held.bind(mv))
		mv.hold_released.connect(_on_hold_released)
		mv.double_tapped.connect(_on_foe_double_tapped.bind(mv))
		_massive_views[col] = mv
	_pair_marks = PairMarks.new()
	_place(_pair_marks, Vector2.ZERO, Vector2(W, H))
	# The reinforcements waiting, by rank (Ryan, 15 October), in the gutter right of the formation:
	# a plaque at each rank's height, a tall one between them for a massive foe.
	_reserve = ReserveView.new()
	var right := _col_x(sk.columns - 1) + SLOT_SIZE.x * 0.5 + 2.0
	var gutter := minf(W - right - 1.0, 44.0)
	_place(_reserve, Vector2(W - 1.0 - gutter, BACK_Y), Vector2(gutter, FRONT_Y + SLOT_SIZE.y - BACK_Y))
	_reserve.back_y = Vector2(0.0, SLOT_SIZE.y)
	_reserve.front_y = Vector2(FRONT_Y - BACK_Y, FRONT_Y - BACK_Y + SLOT_SIZE.y)
	# The corrupted side's tear, over the foes and their ground alike (Ryan, 23 September:
	# under the sprites it was lost): a screen-reading layer the size of the foes' ground.
	var tear := TearLayer.new()
	tear.clock = bg.time
	tear.position = Vector2(0.0, BACK_Y - 14.0)
	tear.size = Vector2(W, LOG_Y - 10.0 - (BACK_Y - 14.0))
	add_child(tear)
	# The predator sense (the funnel-web, 18 October): the foes' ground and the foes on it
	# dim while an ambusher's die is held or dragged, and the foes looking away get their eyes.
	_prey = PreyLayer.new()
	_prey.position = tear.position
	_prey.size = tear.size
	add_child(_prey)

	# Log between the formation and the dice: every line, the newest brightest, scrolled to
	# the end whenever something happens; drag to read back, double-tap for it full screen
	# (Ryan, 22 September: the strip alone was too little to follow a round).
	var log_tag := _tag("LOG", 10, true)
	_place(log_tag, Vector2(12, LOG_Y), Vector2(52, 18))
	_log_scroll = _log_scroller()
	_log_scroll.tooltip_text = "Drag to read back; double-tap to expand"
	_place(_log_scroll, Vector2(20, LOG_Y + 22), Vector2(W - 52 - EYE, LOG_H - 22))
	_log = _log_label(14)
	_log_scroll.add_child(_log)

	# Dice in the middle, each centred on its mech.
	var n := sk.mechs.size()
	for i in range(n):
		var cx := _column_x(i, n)
		var d := DieFaceView.new()
		_place(d, Vector2(cx - DIE_SIZE * 0.5, DIE_Y), DieFaceView.view_size())
		d.tapped.connect(_on_die_tapped.bind(i))
		d.double_tapped.connect(_on_die_tapped.bind(i))   # a quick second tap is a tap: no die codex (Ryan, 22 September), hold shows everything
		d.held.connect(_on_die_held.bind(i))
		d.hold_released.connect(_on_hold_released)
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

	# Mechs: gauges hugging the sprite, three-quarter sprite, chip row beneath.
	for i in range(n):
		var cx := _column_x(i, n)
		var ms: Skirmish.MechState = sk.mechs[i]
		var v := UnitView.new()
		v.display_name = ms.unit.display_name
		v.bars_above = true
		# Mechs are 3D (decided 16 September); headless (and RIFTGATE_MECH3D=off) draws the
		# placeholder shape. A chassis with no model uses the Badger's.
		var look := MechView3D.look_setting()
		_mech_3d.append(null)
		if not look.is_empty():
			var db := ContentDB.load_default()
			var maker := db.maker_of(ms.unit.chassis_id)
			var view := MechView3D.make(ms.unit.chassis_id, maker, look, "", MechView3D.YAW_SKIRMISH, Vector2i.ZERO, false, ms.unit.paint, MechView3D.plan_for(ms.unit, db))
			view.set_sheen(MechView3D.SHEEN_SKIRMISH)   # the rear pose needs more to shine like the codex
			view.size_k = float(MechView3D.SIZE_FILL.get(str(db.chassis.get(ms.unit.chassis_id, {}).get("size", "")), 1.0))   # the team in proportion
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
			view.strip_silhouette()   # no light outline in the skirmish (Ryan, 22 September); the trace and its scan glow stay
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
		v.hold_released.connect(_on_hold_released)
		v.double_tapped.connect(_on_mech_double_tapped.bind(i))
		_mech_views.append(v)

	# Bottom row: End turn bottom-left, Withdraw bottom-right.
	_end_btn = HudButton.new("END TURN", _on_end_turn)
	_end_btn.sound = ""   # the lever is the sound
	_end_btn.filled = true
	_place(_end_btn, Vector2(16, BOTTOM_Y), BOTTOM_BTN)
	_withdraw_btn = HudButton.new("WITHDRAW", _on_withdraw)
	_withdraw_btn.ghost = true
	_withdraw_btn.tooltip_text = "Pull out: the enemy strikes once more, then the team flees."
	_place(_withdraw_btn, Vector2(W - 16 - BOTTOM_BTN.x, BOTTOM_Y), BOTTOM_BTN)

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

	# Overlays: arrows, drag ghost, roll flash, details, codex, confirm, outcome.
	_arrows = ArrowLayer.new()
	_arrows.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_arrows)
	_ghost = DieFaceView.new()
	_ghost.animate = false
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.can_tap = false
	_ghost.drag_started.connect(_on_ghost_drag_started)
	_ghost.drag_moved.connect(_on_drag_moved)
	_ghost.drag_ended.connect(_on_drag_ended)
	_ghost.held.connect(_on_ghost_held)
	_ghost.hold_released.connect(_on_hold_released)
	_ghost.modulate = Color.WHITE   # solid: with its slot emptied, this is the die itself
	_ghost.visible = false
	_place(_ghost, Vector2.ZERO, DieFaceView.view_size())
	_roll_label = Hud.label("", 44, Palette.INK, Hud.mono())
	_roll_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_roll_label.visible = false
	_place(_roll_label, Vector2.ZERO, Vector2(200, 60))

	_details = HudPanel.new(14.0)
	_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	_details_faces = FaceListView.new()
	_details_faces.visible = false
	_details_faces.custom_minimum_size = Vector2(400, 0)
	dv.add_child(_details_faces)
	_details_status = StatusListView.new()
	_details_status.visible = false
	_details_status.custom_minimum_size = Vector2(300, 0)
	dv.add_child(_details_status)

	_build_codex()
	_build_confirm()
	_build_outcome()
	_build_log_full()
	if _menu != null:
		_menu.move_to_front()


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
		_log_full_text.text = _log_text(0)   # nothing faded: it is there to be read
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


func _column_x(i: int, n: int) -> float:
	return W * 0.5 + (i - (n - 1) * 0.5) * PITCH


## Enemy column centres: three columns at a wide pitch, four at a tight one.
func _col_x(col: int) -> float:
	var n := sk.columns
	var pitch := 210.0 if n <= 3 else minf(176.0, (W - 16.0) / n)
	return W * 0.5 + (col - (n - 1) * 0.5) * pitch


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
	_header.text = "RND %02d // REINF %02d // %s" % [sk.round, sk.reinforcements.size(), str(BattleMap.TERRAIN_NAMES.get(sk.terrain, "plain")).to_upper()]
	_header.queue_redraw()
	if _reserve != null:
		_reserve.set_counts(sk.reserve_counts())
		_pool_joins()
	_set_phase("ASSIGN" if assigning else "ENEMY PHASE")
	_view_foe.clear()

	var targets: Array[Foe] = []
	var support: Array[Skirmish.MechState] = []   # the machines a dragged piece of equipment may land on
	var seconds: Array = []   # a pending Swap's second targets: foes and empty slots (Vector2i)
	var slots: Array = []     # the empty slots a dragged weapon may be spent on (the Lammergeier's mines, its pull)
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
			slots = sk.slot_targets(dm, Effects.effective_face(dm.unit, f))
		elif f != null and f.is_equipment():
			support = sk.equipment_targets_for(dm, Effects.effective_face(dm.unit, f))

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
			var at := Vector2(_col_x(col) - SLOT_SIZE.x * 0.5, FRONT_Y if rank == 0 else BACK_Y)
			if twin != null:
				_lay(v, at, Vector2(SLOT_SIZE.x * 0.5, SLOT_SIZE.y))
				_lay(tv, at + Vector2(SLOT_SIZE.x * 0.5, 0.0), Vector2(SLOT_SIZE.x * 0.5, SLOT_SIZE.y))
				tv.visible = true
				tv.modulate = Color.WHITE
				_fill_foe_view(tv, twin, targets, rank * sk.columns + col + 11)
				_view_foe[tv] = twin
				pairs.append([v, tv, foe, twin])
			else:
				tv.visible = false
				_lay(v, at, SLOT_SIZE)
			if massive:
				continue
			if foe == null:
				# An empty slot; with mines waiting (the Lammergeier's) its dashed outline, the
				# mine's glyph with the total waiting and a chip per keyword riding in them.
				var shots := sk.mines_at(Vector2i(rank, col))
				v.display_name = ""
				v.bars = []
				v.intent = "MINED" if not shots.is_empty() else ""
				v.intent_kind = ""
				v.statuses = _mine_chips(shots)
				v.mined = not shots.is_empty()
				# A slot a pending Swap may move its foe into, or one a dragged weapon may be spent on.
				v.highlight = seconds.has(Vector2i(rank, col)) or slots.has(Vector2i(rank, col))
				v.dead = false
				v.sprite = null
				_settle(v)   # a hit still playing on the foe that stood here would end at full brightness
				v.modulate = Color(1, 1, 1, 0.75 if v.highlight else (0.95 if v.mined else 0.3))
				v.queue_redraw()
				continue
			v.mined = false
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
			if not (ef.has(Face.Keyword.CLEAVE) or ef.has(Face.Keyword.PENETRATE) or ef.reaches_all):
				continue
			lv.highlight = false
			rv.highlight = false
			lv.queue_redraw()
			rv.queue_redraw()
			var a := lv.drawing_rect()
			var b := rv.drawing_rect()
			marks.append(Rect2(_home.get(lv, lv.position) + a.position, a.size).merge(Rect2(_home.get(rv, rv.position) + b.position, b.size)).grow(6.0))
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
		# The sixth shot's count as pips under the heat bar (Ryan, 19 October: the best spot).
		var every := Effects.counts_shots(ms.unit)
		v.pips = [Effects.stacks_of(ms.unit, "shots"), every] if every > 0 else []
		# A capped store as boxes under the heat (Ryan, 21 and 22 October: every store a bar, the
		# rage boxes up to its cap), in its chip's colour and place.
		v.boxes = []
		for id in Effects.STATUS.keys():
			var cap := Effects.store_cap(ms.unit, str(id)) if (Effects.STATUS[id].get("tags", []) as Array).has("store") else 0
			if cap > 0:
				v.boxes = [Effects.banked(ms.unit, str(id)), cap, _chip_colour(str(id)), status_glyph(str(id))]
				break
		v.highlight = support.has(ms)
		v.statuses = []
		for r in _mech_rows(i):
			v.statuses.append([r[0], r[1], r[3]])
		v.queue_refresh()
		var d := _dice[i]
		# A locked piece goes out charged whenever a muster pays and it has somewhere to land
		# (the Swallowtail's, Ryan, 22 October): the die shows the form that will happen.
		d.charged = not ms.assigned and sk.charge_lands(ms)
		var sf := sk.shown_face(ms, sk.spend_face(ms))   # reach as the passive reads it now, the charged form when it goes out charged
		d.set_face(sf, sk.shown_number_text(ms, sf))   # and the number the blow will deal
		d.blast = sk.blast_number(ms, sk.blast_amount(ms, sf, ms)) if not ms.assigned and ms.alive() else 0   # a vent's blast on its own machine
		d.corrupted = Effects.corrupt_stacks(ms.unit, ms.face_index) if ms.face_index >= 0 else 0
		# A dark entry shows the rounds it has left, this one included (the cooldown row).
		d.dark = Effects.dark_rounds(ms.unit, ms.face_index, sk.round) if sf != null and sf.disabled else 0
		d.next_face = sk.next_face(ms) if ms.alive() else null   # a stepping die's next chamber
		d.slot = ms.face_index + 1   # its place on the die: a reroll onto a copy shows by it
		d.spent = ms.assigned
		d.dead = not ms.alive()
		d.locked = locked[i]
		d.can_tap = assigning and ms.alive() and not ms.assigned
		d.can_drag = assigning and ms.alive() and not ms.assigned and _pending.get("mech", -1) != i
		# While a die is dragged, the one under the finger is the die: its slot goes empty
		# (Ryan, 26 September: a copy dragged beside the original read as a copy). Modulate,
		# not visible: the view must keep receiving the drag's motion.
		d.modulate = Color(1, 1, 1, 0.0) if _drag_from == i or _pending.get("mech", -1) == i else Color.WHITE
		d.queue_redraw()

	_refresh_log()
	_reroll_btn.badge = "×%d" % sk.rerolls_left
	_reroll_btn.set_enabled(assigning and sk.can_reroll())
	_end_btn.set_enabled(assigning)
	# Nothing left to spend, rerolls aside: END TURN is the next thing to press (Ryan, 25 October).
	var left := false
	for i in range(sk.mechs.size()):
		left = left or sk.can_spend(i)
	_end_btn.set_pulse(assigning and not left)
	_withdraw_btn.set_enabled(sk.can_withdraw())
	if sk.committed and _withdraw_btn.text != "NO RETREAT":
		_withdraw_btn.text = "NO RETREAT"   # the boss's fight: closing the rift or scrapped trying
		_withdraw_btn.queue_redraw()
	_refresh_arrows()
	_refresh_prey()
	if save and autosave.is_valid():
		autosave.call()


## The forecast a machine's gauges and warnings read now: the lure preview's while a die in hand
## would turn foes, else the round as it stands, the dragged die's own spend counted over the foe
## under the finger (a Cryo cash). Empty for a wreck or outside the player's turn.
func _forecast_for(i: int) -> Dictionary:
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive() or sk.state != Skirmish.State.ASSIGN:
		return {}
	var all: Array = _round.get("mechs", [])
	if i < all.size():
		return all[i]
	return sk.forecast(ms, false)   # no preview this refresh (a Swap's second target pending)


## The lure preview (the Whip Scorpion's Siphon, 22 October): while a die whose entry Lures is
## dragged over a foe it may be spent on, or held or dragged anywhere when it reaches every foe,
## the foes it would turn draw their arrows dashed to its machine, and the round preview reads the
## round as the lure would leave it (_update_round): the lured blows, the brace, the heat a
## Siphon drinks from them.
func _update_preview() -> void:
	_turns = []
	if sk.state != Skirmish.State.ASSIGN or not _pending.is_empty():
		return
	var i := _drag_from if _drag_from >= 0 else _hold_die
	if i < 0 or i >= sk.mechs.size():
		return
	var ms: Skirmish.MechState = sk.mechs[i]
	var aimed: Foe = _drag_over if _drag_from >= 0 and _drag_over is Foe else null
	_turns = sk.lure_turns(ms, aimed)


## The round preview for this refresh (Skirmish.preview_round; Ryan, 26 October: it accounts for
## everything that will happen but chance and the player's own choices, and "Die faces only apply
## to the preview when hovered over a valid target"): the die in hand counts dragged over somewhere
## it may be spent, or held or dragged anywhere when its Lure reaches every foe (any foe it turns
## is its target, its pieces dealing no damage). Nothing while a Swap waits on its second target.
func _update_round() -> void:
	_round = {}
	if sk.state != Skirmish.State.ASSIGN or not _pending.is_empty():
		return
	var hm := -1
	var ht = null
	if _drag_from >= 0 and _drag_over != null:
		hm = _drag_from
		ht = _drag_over
	elif not _turns.is_empty():
		hm = _drag_from if _drag_from >= 0 else _hold_die
		ht = _turns[0]
	_round = sk.preview_round(hm, ht)


func _refresh_log() -> void:
	var fresh_lines := sk.log.size() > _log_seen
	_log.text = _log_text(LOG_LINES, true)
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
		_log_full_text.text = _log_text(0)
		_scroll_to_end(_log_full_scroll)
	_log_seen = sk.log.size()


const PROMPT := "> _"   # the strip's last line: a terminal prompt whose cursor blinks (_process)

## The whole log as bbcode, one line per event, the last `bright` lines fading up to full
## and everything older at the dim end; `bright` 0 leaves every line at full. `prompt`
## adds the cursor line at the end (the strip; never the full-screen log).
func _log_text(bright: int, prompt: bool = false) -> String:
	var n := sk.log.size()
	var out := ""
	if n == 0:
		out = "[color=#%s]> round %d // %d in reserve // awaiting orders[/color]\n" % [Color(Palette.HUD, 0.45).to_html(true), sk.round, sk.reinforcements.size()]
	var start := maxi(0, n - bright)
	var count := n - start
	for j in range(n):
		var a := 1.0
		if bright > 0:
			if j < start:
				a = 0.4
			elif count > 1:
				a = lerpf(0.4, 1.0, float(j - start) / float(count - 1))
		out += "[color=#%s]> %s[/color]\n" % [Color(Palette.HUD, a).to_html(true), sk.log[j]]
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
	v.flip_h = bool(ContentDB.load_default().foes.get(foe.content_id, {}).get("flip", false))
	v.breathe = true
	# Breathing spread by slot at the golden angle, so no two neighbours are near in phase
	# (Ryan, 23 September: the instance-id phases read as in step).
	v.breathe_phase = slot * 2.39996 + 0.7
	# Its HP as the round will leave it (the round preview: its ticks, a heal, the die in hand over
	# it, its own self-destruct) pulses on its gauge as a machine's coming change does, a loss
	# dimming and lit, a heal hatched, the whole bar when it falls (Ryan, 26 October).
	var after := int(_round.get("foes", {}).get(foe, {}).get("hp", foe.hp)) if foe.alive() else foe.hp
	v.bars = [[foe.hp, foe.hp_max, Palette.HUD, after]]
	v.dead = not foe.alive()
	v.highlight = targets.has(foe)
	v.intent = ""
	v.intent_dim = false
	# The intent is this round's chosen attack: a sword, its damage, and a mark for a double
	# strike or a breach; a suppressed foe shows no intent, only the status; a dead one
	# threatens nothing.
	v.intent_kind = "" if (foe.is_suppressed() or foe.target == null or not foe.alive()) else Foe.kind_of(foe.action)
	# A move still gathering (a countdown) shows the blow it will land; its rounds are a chip.
	var blow := foe.attacks() or foe.gathering()
	v.intent_value = sk.foe_blow(foe) if blow else int(foe.action.get("value", 0))
	v.intent_note = (("×%d" % foe.strikes() if foe.strikes() > 1 else "") + ("!" if foe.breaches() else "")) if blow else ""
	v.statuses = []
	for r in _foe_rows(foe):
		v.statuses.append([r[0], r[1], r[3], r[4] if r.size() > 4 else "status"])
	v.queue_redraw()


## A mined slot's chips (the Lammergeier's): the mine with the total its shots deal as laid,
## then each keyword riding in them, a numbered one with its stacks.
func _mine_chips(shots: Array) -> Array:
	if shots.is_empty():
		return []
	var total := 0
	var kws: Array = []
	var stacks := {}
	for shot in shots:
		total += int(shot.get("damage", 0))
		for k in shot.get("keywords", []):
			if not kws.has(int(k)):
				kws.append(int(k))
		for key in ["burn", "cryo", "flak"]:
			stacks[key] = int(stacks.get(key, 0)) + int(shot.get(key, 0))
	var chips: Array = [["mine", str(total) if shots.size() == 1 else "%d·%d" % [total, shots.size()], Palette.HEAT]]
	for k in kws:
		var id := str(Face.KEYWORD_NAMES.get(k, ""))
		if id.is_empty():
			continue
		var n := int(stacks.get(id, 0))
		chips.append([id, str(n) if n > 0 else "", Glyphs.colour_for(id)])
	return chips


## What waits in a mined slot, for its hold: each shot in laid order, its number, its keywords
## and who laid it.
func _mine_text(rank: int, col: int, shots: Array) -> String:
	var text := "Mines: the %s rank's slot %d" % ["front" if rank == 0 else "back", col + 1]
	var n := 0
	for shot in shots:
		n += 1
		var bits: Array[String] = [str(int(shot.get("damage", 0)))]
		for k in shot.get("keywords", []):
			bits.append(Face.keyword_label(int(k)))
		text += "\n%d. %s (%s)" % [n, " ".join(bits), str(shot.get("by", ""))]
	return text + "\nwhoever steps in takes them all in laid order, before it acts"


## Statuses on a foe as [glyph, chip text, readout text, colour], and a fifth "resist" for a
## chip that is no status at all (Numbed, 10 October: drawn in brackets, never boxed).
func _foe_rows(foe: Foe) -> Array:
	var rows: Array = []
	# A fall the round will bring (the round preview; Ryan, 26 October: "It should get a destroyed
	# chip same as the player to indicate incoming death"): the machines' skull, its intent kept,
	# since its line still matters to what reads it.
	var fate: Dictionary = _round.get("foes", {}).get(foe, {})
	if foe.alive() and not fate.is_empty() and not bool(fate.get("alive", true)):
		rows.append(["skull", "", "Destroyed this round, as the round stands", Palette.ENEMY, "preview"])
	var tick := Effects.tick_preview(foe)
	if foe.burn_stacks() > 0:
		rows.append(["burn", str(foe.burn_stacks()), "Burning: %d damage a round, one stack less each round" % (int(tick["hp"]) - int(tick["share"])), Palette.HEAT])
	var vitriol := Effects.stacks_of(foe, "vitriol")
	if vitriol > 0:
		# The funnel-web's acid (18 October): its stacks, and the share they eat at its action.
		rows.append(["vitriol", str(vitriol), "Vitriol: loses %d at its action (%d%% of its current HP a stack, %d stack%s), past armour, after Burning, then a stack fades; it never finishes a foe" % [int(tick["share"]), Effects.status_value("vitriol", "tick_hp_share"), vitriol, "" if vitriol == 1 else "s"], Palette.HEAT])
	var flak := Effects.stacks_of(foe, "flakked")
	if flak > 0:
		# Wainwright & Sutler's on-hit (21 October): the count is the extra every blow of a
		# damaging weapon it takes deals, a 0 included, and what its clock keeps into the next
		# round (the status names the clock). The number leads: a row is one line, clipped.
		var halves := Effects.status_decay(Effects.STATUS["flakked"]) == Effects.DECAY_HALF
		rows.append(["flak", str(flak), "Flak: +%d to every damaging weapon's blow, a point a stack; %s (%d)" % [flak, "at the end of the round the stacks halve" if halves else "a stack fades at its action", Effects.stacks_next_round(Effects.STATUS["flakked"], flak)], Palette.HEAT])
	var cryo := Effects.stacks_of(foe, "cryoed")
	if cryo > 0:
		# The Armadillo's mark (20 October; its chip from 21 October): what a hit on it with a
		# damaging weapon cools the hitter, whatever the hit dealt, the stacks it spends; the
		# number first, since a row is one line, clipped.
		rows.append(["cryo", str(cryo), "Cryo: cools the hitter %d heat (%d a stack) when a damaging weapon hits it, spending every stack" % [cryo * Skirmish.cryo_cool(), Skirmish.cryo_cool()], Palette.HUD])
	if Effects.has(foe, "webbed"):
		# The funnel-web's web (18 October): the chip points at the neighbour the burst catches
		# (> the right-hand one, which acts after it; < the left-hand one, which has acted).
		var caught := sk.web_catch(foe)
		var mark := "" if caught == null else (">" if caught.column > foe.column else "<")
		var who := ", and nobody stands beside it" if caught == null else " and %s beside it%s" % [caught.display_name, ", which has acted and loses its next" if caught.column < foe.column else ""]
		rows.append(["web", mark, "Webbed: at the end of its action the web bursts, Suppressing it (its next action)%s" % who, Palette.SHIELD])
	if foe.is_suppressed():
		rows.append(["suppress", "", "Suppressed: loses its action this round", Palette.HUD])
	if not foe.last_act().is_empty():
		# A last act (15 October): the skull and what it lands the moment the foe falls.
		var la := foe.last_act()
		rows.append(["skull", str(foe.damage_of(la)), "Its last act: %s, %d %s, the moment it falls" % [str(la.get("name", "")), foe.damage_of(la), "at every machine" if Array(la.get("keywords", [])).has("all") else "at its pick"], Palette.ENEMY])
	if Effects.has(foe, "guarded"):
		# A boss in parts (15 October): the lock while its parts stand, so the zero its die
		# shows has a reason on the foe itself.
		rows.append(["lock", "", "Guarded: takes no damage while %s" % ("all its parts stand" if foe.guard == "all" else "any of its parts stands"), Palette.HUD])
	if foe.gathering():
		# A countdown (15 October): the warning glyph and the rounds before it lands.
		var when := "next round" if foe.charge == 1 else "in %d rounds" % foe.charge
		rows.append(["warning", str(foe.charge), "Gathering: %s lands %s" % [str(foe.pending.get("name", "")), when], Palette.ENEMY])
	if Effects.has(foe, "braced"):
		# Armoured, the machines' status (16 October; Braced until 18 October): their chip's
		# glyph, with the armour every grant adds (its own brace, a Protect).
		var arm := Effects.foe_armour_bonus(foe)
		rows.append([status_glyph("braced"), "+%d" % arm, "%s: armour +%d until its next action" % [Effects.STATUS["braced"]["name"], arm], Palette.SHIELD])
	if Effects.has(foe, "kindled"):
		var kindled := Effects.foe_attack_bonus(foe)
		rows.append(["overcharge", "+%d" % kindled, "Kindled: its next move hits %d harder, then it is spent (a special gains nothing from it; a countdown carries it to its blow)" % kindled, Palette.HEAT])
	# A rally on its way (Ryan, 26 October: "a pulsing version of the incoming buff as a preview
	# chip, so the player knows it's incoming and that's the reason for the increased damage"):
	# the Kindled the rallies will land before its blow, already in the number its intent
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
		rows.append(["overcharge", "+%d" % maxi(1, coming), "Kindled on its way: %s rall%s first, so its blow lands %d harder, in the number shown; gone if the rallier is killed, Suppressed or Disrupted before it acts" % [from, "ies" if who.size() == 1 else "y", coming], Palette.HEAT, "preview"])
	if Effects.has(foe, "risen"):
		rows.append(["star", "", "Getting back up: returns from the pool once after dying", Palette.ENEMY])
	var paradox := Effects.stacks_of(foe, "paradox")
	if paradox > 0:
		var at := sk.paradox_count()
		rows.append(["paradox", "%d/%d" % [paradox, at] if at > 0 else str(paradox), "Paradox: %d%s; at the count its past self knocks it out (Suppressed), and the Paradox clears" % [paradox, " of %d" % at if at > 0 else ""], Palette.SHIELD])
	if Effects.has(foe, "shocked"):
		rows.append(["shocked", "×2", "Shocked: the next blow it takes lands double", Palette.HEAT])
	var numbed := Effects.stacks_of(foe, "numbed")
	if numbed > 0:
		rows.append(["numbed", "%d%%" % foe.resist_total(), "Numbed, a resistance and not a buff or a debuff (nothing reads, deepens or clears it): shrugs off a suppress %d%% of the time, 10%% a stack, a stack less each of its turns (%d to go)" % [foe.resist_total(), numbed], Palette.SHIELD, "resist"])
	if Effects.has(foe, "syrinx_drone"):
		# The Syrinx Drone (the Lammergeier's, 21 October): its own chip, the killing shot to come.
		var drone: Dictionary = Effects.STATUS["syrinx_drone"]
		rows.append(["syrinx_drone", "", "%s: %s" % [drone["name"], drone["description"]], Palette.HUD])
	if Effects.has(foe, "exposure"):
		# Exposed, the debuff (21 October): the formation's reticle with its armour zeroed. The
		# chip is the debuff's alone: a back-rank foe with nothing in front wears none (Ryan, 26
		# October: a chip for it "steps on the debuff and is very confusing"); a dragged line
		# weapon lighting it says it is in reach.
		rows.append(["exposed", "0", "Exposed: every machine's line weapons reach it, and its armour counts for nothing, through the next round", Palette.ENEMY])
	# Every status the round will land on it (Ryan, 26 October: "All incoming chips should appear
	# as pulsing opacity versions"): the copy's grants, each a chip pulsing on a dashed edge with
	# the stacks it gains, beside the skull when the round kills it, since one may be the cause.
	# A Kindled lifting this round's blow is the rally chip above; one landing after its move
	# (for the next round's) is a chip like any other.
	if foe.alive():
		rows.append_array(_coming_rows(fate.get("coming", {}), ["kindled"] if rally_chip else [], _foe_glyph, _foe_chip_colour))
	return rows


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
		rows.append([glyph_of.call(id), text, "%s on its way: %s" % [str(c["name"]), str(c["description"])], colour_of.call(id), "preview"])
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
		"vitriol", "paradox", "shocked", "numbed", "syrinx_drone":
			return id
	return status_glyph(id)


## A foe's status's colour on its chip, as the rows above give them.
static func _foe_chip_colour(id: String) -> Color:
	if id in ["burning", "vitriol", "flakked", "kindled", "shocked"]:
		return Palette.HEAT
	if id in ["webbed", "braced", "numbed", "paradox"]:
		return Palette.SHIELD
	if id in ["risen", "exposure"]:
		return Palette.ENEMY
	return Palette.HUD


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
			return "burn"
		"retaliate":
			return "shocked"
		"hopper":
			return "hopper"
		"sealed":
			return "lock"
		"phased":
			return "phased"
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


## Statuses and warnings on a mech as [glyph, chip text, readout text, colour]. Warnings come
## from the forecast: what the end of the round does if nothing changes.
## A machine status's colour on its chip, or on a capped store's boxes: the heat's for what heats
## or hits harder, the enemy's for what a foe did to it, the shield's for armour and wards.
static func _chip_colour(id: String) -> Color:
	if id in ["burning_mech", "scorched", "overcharged", "primed", "rage", "spun_up", "siphoning"]:
		return Palette.HEAT
	if id.begins_with("corrupted") or id == "silenced":
		return Palette.ENEMY
	if id in ["braced", "retaliate", "barrier", "ward"]:
		return Palette.SHIELD
	return Palette.HUD


func _mech_rows(i: int) -> Array:
	var ms: Skirmish.MechState = sk.mechs[i]
	var rows: Array = []
	if not ms.alive():
		return rows
	if locked[i]:
		rows.append(["lock", "", "Die locked: reroll skips it", Palette.HUD])
	if ms.free_rerolls > 0 and not ms.assigned and sk.state == Skirmish.State.ASSIGN:
		rows.append(["reroll", "×%d" % ms.free_rerolls, "A free reroll of this die alone this round: lock the others and press REROLL", Palette.HUD])
	var damaged := ms.unit.damaged_component_count()
	if damaged > 0:
		rows.append(["crack", str(damaged), "%d damaged component%s: repair in the hangar" % [damaged, "" if damaged == 1 else "s"], Palette.HUD])
	# An on_foe_status passive is live all fight, so it reads here as an active effect (Ryan,
	# 28 September); its count is the chip (the Paradox meter, 10 October).
	var meter := Effects.paradox(ms.unit)
	if meter[1] > 0:
		var loop_names: Array[String] = []
		for m in Effects.live(ms.unit):
			for eff in m.effects:
				if str(eff.get("trigger", "")) == "on_foe_status" and not loop_names.has(m.name):
					loop_names.append(m.name)
		rows.append(["paradox", str(meter[1]), "%s: a foe gaining any status but Paradox gains Paradox; at %d its past self knocks it out (Suppressed), and the Paradox clears" % [", ".join(loop_names), meter[1]], Palette.SHIELD])
	# Every in-combat effect on the machine (Ryan, 26 September: the codex is the base state;
	# the fight's statuses live here, as chips that the hold expands into their descriptions),
	# and every status whatever its scope (Ryan, 16 October: the Ammit is Overcharged, "so
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
			continue   # a count shows as pips under the heat bar (the Cassowary's sixth shot), a capped store as its boxes, and the gate by the Rapid it grants, never a chip
		if not first.has(id):
			order.append(id)
			first[id] = d
			total[id] = 0
		total[id] = int(total[id]) + int(d[4])
	for id in order:
		var d: Array = first[id]
		var glyph := status_glyph(id)
		var colour := _chip_colour(id)
		var stacks := int(total[id])
		rows.append([glyph, ("×%d" % stacks) if stacks > 1 else "", "%s: %s" % [str(d[0]), str(d[1])], colour])
	if sk.state == Skirmish.State.ASSIGN:
		var fc := _forecast_for(i)
		# Every warning is a prediction, so each pulses as the incoming chips do (Ryan, 26 October:
		# the skull "is just another predicted chip, like any other. It just symbolizes death").
		if int(fc["overheat"]) > 0:
			# The heat burns as the turn ends, so there is still time to vent.
			rows.append(["heat", "-%d" % int(fc["overheat"]), "Overheating: hull -%d at the end of the turn unless vented" % int(fc["overheat"]), Palette.HEAT, "preview"])
		if int(fc.get("volatile", 0)) > 0:
			rows.append(["volatile", "-%d" % int(fc["volatile"]), "Volatile: spending this component costs hull -%d, past shield and armour" % int(fc["volatile"]), Palette.ENEMY, "preview"])
		if bool(fc["destroyed"]):
			rows.append(["skull", "", "Wrecked this round: %d incoming" % int(fc["incoming"]), Palette.ENEMY, "preview"])
		elif bool(fc["component_risk"]):
			rows.append(["crack", "!", "A hit that big injures a component: the die is rolled", Palette.ENEMY, "preview"])
		if bool(fc["breaks_shield"]):
			rows.append(["shieldbreak", "", "Incoming %d breaks the shield" % int(fc["incoming"]), Palette.ENEMY, "preview"])
		# Every status the round will land on it (Ryan, 26 October: "All incoming chips should
		# appear as pulsing opacity versions"), beside the skull when the round wrecks it (one may be
		# the cause: a Burning it lit on itself), the counts and stores that are no chip left out.
		var skip: Array = ["shots", "quick_turned", "muster"]
		for id in fc.get("coming", {}).keys():
			if Effects.store_cap(ms.unit, id) > 0:
				skip.append(id)
		rows.append_array(_coming_rows(fc.get("coming", {}), skip, status_glyph, _chip_colour))
	return rows


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
	var lurer := (_drag_from if _drag_from >= 0 else _hold_die) if not _turns.is_empty() else -1
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
		# preview, 26 October: the pick it will make, from the pick stream): a second arrow, dashed
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
			var wanted := show_all_arrows or foe == _hold_foe or target_index == _hold_mech or target_index == lurer
			if not wanted:
				continue
			var from: Vector2 = inv * fv.anchor_global()
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
			list.append([inv * fv.anchor_global(), inv * _mech_views[lurer].anchor_global(), Palette.ENEMY, true])
			for i in _round.get("foes", {}).get(foe, {}).get("struck", []):
				if int(i) != lurer and int(i) >= 0 and int(i) < _mech_views.size():
					list.append([inv * fv.anchor_global(), inv * _mech_views[int(i)].anchor_global(), Palette.ENEMY, true])
	_arrows.set_arrows(list)


## Hold readout beside a control: a text block, then for a die every face in a column, or
## for a unit its statuses and warnings as icon-and-text rows.
func _show_details(text: String, near: Control, faces: Array = [], current: int = -1, rows: Array = [], labels: Array = [], ring: Array = []) -> void:
	_details_label.text = text
	# A stepping die's cylinder above its entries: [faces, the chamber showing, the next].
	_details_ring.visible = not ring.is_empty()
	if not ring.is_empty():
		_details_ring.set_cylinder(ring[0], int(ring[1]), int(ring[2]))
	_details_faces.visible = not faces.is_empty()
	_details_faces.labels = labels
	if not faces.is_empty():
		_details_faces.set_faces(faces, current)
	_details_status.set_rows(rows)
	var width := 440.0 if not faces.is_empty() else 360.0
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
	var pos := Vector2(near.position.x + near.size.x * 0.5 - width * 0.5, near.position.y - height - 10.0)
	if pos.y < 8.0:
		pos = near.position + Vector2(near.size.x + 8.0, 0)
		if pos.x + width > W - 8.0:
			pos.x = near.position.x - width - 8.0
	pos.x = clampf(pos.x, 8.0, W - width - 8.0)
	pos.y = clampf(pos.y, 8.0, H - 8.0 - height)
	_details.position = pos


## The damage number pops over the struck foe, then fades.
func _flash_roll(fv: UnitView) -> void:
	if sk.last_roll.is_empty() or fv == null:
		return
	_roll_label.text = "%d" % int(sk.last_roll["final"])
	_roll_label.add_theme_color_override("font_color", Palette.INK)
	_roll_label.position = fv.position + Vector2(fv.size.x * 0.5 - 100.0, 4.0)
	_roll_label.modulate = Color.WHITE
	_roll_label.visible = true
	if is_inside_tree():
		var tw := create_tween()
		tw.tween_interval(0.5)
		tw.tween_property(_roll_label, "modulate:a", 0.0, 0.7)
		tw.tween_callback(func() -> void: _roll_label.visible = false)
		var rise := create_tween()
		rise.tween_property(_roll_label, "position:y", _roll_label.position.y - 22.0, 1.2).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------- gestures

func _on_die_tapped(i: int) -> void:
	if sk.state != Skirmish.State.ASSIGN:
		return
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive() or ms.assigned:
		return
	locked[i] = not locked[i]
	Sound.play("die_lock" if locked[i] else "die_unlock")
	_refresh()


## One label per die entry: the component's name, FIXED where it is built in, and, with
## `tags`, the effects that apply to it right now with their source.
func _face_labels(ms: Skirmish.MechState, tags: bool) -> Array:
	var db := ContentDB.load_default()
	var labels: Array = []
	for i in range(ms.die.faces.size()):
		var f: Face = ms.die.faces[i]
		if f.empty:
			labels.append("EMPTY HARDPOINT")
			continue
		var label := db.component_name(f.component).to_upper() + (" // FIXED" if f.fixed else "")
		if Effects.is_entry_disabled(ms.unit, i):
			var dark := Effects.dark_rounds(ms.unit, i, sk.round)
			label += (" // DISABLED" if Effects.cleansable_disable(ms.unit, i) else " // DARK") \
				+ (", %d ROUND%s LEFT" % [dark, "" if dark == 1 else "S"] if dark > 0 else "")
		var rot := Effects.corrupt_stacks(ms.unit, i)
		if rot > 0:
			label += " // CORRUPTED" + (" ×%d" % rot if rot > 1 else "")
		if Effects.steps_die(ms.unit) and ms.face_index >= 0 and i == (ms.face_index + 1) % ms.die.faces.size():
			label += " // NEXT"   # a stepping die's next chamber, in the hold
		if tags:
			var notes: Array[String] = Effects.explain(ms.unit, f)
			if not notes.is_empty():
				label += "  · " + " · ".join(notes)
		labels.append(label)
	return labels


## The die's entries as the player should see them (effective reach), for lists.
func _shown_faces(ms: Skirmish.MechState) -> Array:
	var out: Array = []
	for f in ms.die.faces:
		out.append(sk.shown_face(ms, f))
	return out


func _on_die_held(i: int) -> void:
	var ms: Skirmish.MechState = sk.mechs[i]
	# Every entry with what applies to it right now (a disabled entry, a passive's change,
	# a cracked component): the hold is the die's whole readout since the die codex went.
	# A die that steps (the Cassowary's) shows its chambers as a cylinder above the list: the one
	# showing lit, an arrow round to the next (Ryan's ring, 19 October).
	var ring: Array = [_shown_faces(ms), ms.face_index, sk.next_index(ms)] if Effects.steps_die(ms.unit) else []
	_show_details("%s // D%d" % [ms.unit.display_name.to_upper(), ms.die.size()], _dice[i], _shown_faces(ms), ms.face_index, [], _face_labels(ms, true), ring)
	Sound.play("hold")
	_hold_die = i
	_refresh(false)   # the marks and a lure's preview read the held die


func _on_foe_held(v: UnitView) -> void:
	var foe: Foe = _view_foe.get(v, null)
	if foe == null:
		# A mined empty slot (the Lammergeier's): what waits there.
		for rank in range(2):
			var col: int = _slot_views[rank].find(v)
			if col >= 0 and not sk.mines_at(Vector2i(rank, col)).is_empty():
				_show_details(_mine_text(rank, col, sk.mines_at(Vector2i(rank, col))), v, [], -1, [])
				Sound.play("hold")
		return
	_hold_foe = foe
	var text := "%s\nhp %d/%d · attack %d" % [foe.display_name, foe.hp, foe.hp_max, foe.attack]
	if not foe.alive():
		text += "\ndestroyed: cleared at the end of the round"
	elif not foe.is_suppressed():
		# A suppressed foe's intent clears here too (Ryan, 14 October): its Suppressed row
		# below says what it does this round, as the chip does under its sprite.
		if not foe.action.is_empty():
			if foe.gathering():
				text += "\n%s %d%s, lands %s" % [str(foe.action.get("name", "")), sk.foe_blow(foe), v.intent_note, "next round" if foe.charge == 1 else "in %d rounds" % foe.charge]
			elif foe.attacks():
				text += "\n%s %d%s" % [str(foe.action.get("name", "")), sk.foe_blow(foe), v.intent_note]
			else:
				text += "\n%s: %s" % [str(foe.action.get("name", "")), foe.text_of(foe.action)]
		if foe.target != null and foe.reaches_every_machine():
			text += "\n→ every machine"
		elif foe.target != null and not foe.acts_on_nobody():
			# The sense only where the foe carries one: a foe without one picks at random (24 October).
			var sense := foe.aim_of()
			text += "\n→ %s" % foe.target.unit.display_name
			if sense != Foe.AIM_ANYTHING:
				text += " (%s)" % str(Foe.AIM_TEXT.get(sense, sense))
	if foe.is_massive():
		text += "\nmassive: fills the column"
	_show_details(text, v, [], -1, _readout_rows(_foe_rows(foe)))
	Sound.play("hold")
	_refresh_arrows()


func _on_mech_held(i: int) -> void:
	_hold_mech = i
	var ms: Skirmish.MechState = sk.mechs[i]
	var text := "%s\nhull %d/%d · shield %d/%d · heat %d/%d" % [ms.unit.display_name, ms.unit.hull, ms.unit.hull_max, ms.unit.shield, ms.unit.shield_max, ms.heat, ms.heat_max]
	if ms.unit.cooling > 0:
		text += "\ncools %d at the start of each turn" % ms.unit.cooling
	_show_details(text, _mech_views[i], [], -1, _readout_rows(_mech_rows(i)))
	Sound.play("hold")
	_refresh_arrows()


## Status rows for the readout: [glyph, readout text, colour].
func _readout_rows(rows: Array) -> Array:
	var out: Array = []
	for r in rows:
		out.append([r[0], r[2], r[3]])
	return out


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
	_details.visible = false
	_hold_foe = null
	_hold_mech = -1
	_refresh_arrows()
	_codex.open(entry)


func _close_codex() -> void:
	_codex.close()


var _menu: PauseMenu = null

func _open_menu() -> void:
	if _menu == null:
		_menu = PauseMenu.new()
		_menu.display_changed.connect(func(key: String, value: Variant) -> void:
			if key == "pace":
				BattleMapView.pace = float(value)
			elif key == "scan" and _bg != null:
				_bg.scan = bool(value)
			elif key == "weld":
				_build()   # the machines remade, welded or as authored (a debug build's comparison)
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


func _on_hold_released() -> void:
	_details.visible = false
	_hold_foe = null
	_hold_mech = -1
	var was_die := _hold_die >= 0
	_hold_die = -1
	if was_die:
		_refresh(false)   # a held die's preview lets go of the gauges too
	else:
		_refresh_arrows()
		_refresh_prey()


## The predator sense (Ryan, 17 October; the funnel-web's row, 18 October): while a die is held
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
	var i := _drag_from if _drag_from >= 0 else _hold_die
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
	if foes.is_empty() and not (PREY_DEBUG and _drag_from < 0 and _hold_die < 0):
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
## blast is held, or dragged anywhere but over an ally, every foe the blast may land on (the draw
## is over every live foe) is marked with what it would deal there. Nothing for any other die,
## or a vent with nothing to fire. RIFTGATE_BLAST_DEBUG=1 keeps them on.
func _blast_marks() -> Dictionary:
	var i := _drag_from if _drag_from >= 0 else _hold_die
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
## switch's); nothing for another machine, an entry that is no weapon, or a spent die.
func prey_for(i: int, force: bool = false) -> Array[Foe]:
	var out: Array[Foe] = []
	if i < 0 or i >= sk.mechs.size():
		return out
	var ms: Skirmish.MechState = sk.mechs[i]
	if not ms.alive() or ms.assigned or not (force or Effects.reads_intent(ms.unit)):
		return out
	var f := sk.shown_face(ms, ms.face())
	if f == null or not f.is_attack():
		return out
	for foe in sk.targets_for_face(ms, f):
		if not foe.intent_on(ms.unit):
			out.append(foe)
	return out


func _on_drag_started(i: int) -> void:
	_drag_from = i
	_drag_over = null
	Sound.play("die_pick")
	var sf := sk.shown_face(sk.mechs[i], sk.spend_face(sk.mechs[i]))
	_ghost.shut = []   # no foe in hand yet: every chip as printed
	_ghost.set_face(sf, sk.shown_number_text(sk.mechs[i], sf))
	_ghost.blast = sk.blast_number(sk.mechs[i], sk.blast_amount(sk.mechs[i], sf))
	_ghost.charged = sk.charge_lands(sk.mechs[i])
	_ghost.corrupted = Effects.corrupt_stacks(sk.mechs[i].unit, sk.mechs[i].face_index)
	_ghost.slot = sk.mechs[i].face_index + 1
	_ghost.visible = true
	_refresh()


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
## spends it; dragging the die again picks it back up; a hold reads as ever.
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
	_drag_from = i
	_drag_over = null
	Sound.play("die_pick")
	_refresh()


## A hold on the pending die reads its die, as a hold on the die in the tray does.
func _on_ghost_held() -> void:
	if not _pending.is_empty():
		_on_die_held(int(_pending["mech"]))


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


## Two drop targets the same (a Foe, a MechState, an empty slot's Vector2i, or null), compared by
## type first, since GDScript refuses == across an object and a vector.
static func _same_target(a, b) -> bool:
	if typeof(a) != typeof(b):
		return false
	return typeof(a) == TYPE_NIL or a == b


## What sits under a global point: a Foe, an empty slot as Vector2i(rank, column) (the
## Lammergeier's mines), a MechState, or null.
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


## Jenny on the heat a spend just added: the overheat when a machine went over the cap, else
## the warning when one passed three quarters; one line for the spend.
func _heat_hook(before: Array) -> String:
	var after := _heat_marks()
	var worst := 0
	for k in range(mini(before.size(), after.size())):
		if int(after[k]) > int(before[k]):
			worst = maxi(worst, int(after[k]))
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
const PRE_LINE_AT := 0.1     # her line, just after the die's own sound
const PRE_FIRE := 0.85       # the weapon, this far through her line
const AFTER_DEATH := 0.45   # her line, this long after a foe's death begins
## The enemy's turn: her component lines after the blow lands (a machine lost waits for its
## death at the turn's end).
const VOICE_AFTER_BLOW := 0.4


## Spend die `i` on `target` (a Foe or a MechState). Returns whether the simulation accepted it.
func _use_die(i: int, target, second = null) -> bool:
	# Every foe's view and drawing before the die lands: a kill clears its slot at once, so
	# the death has to be played from what was there (the ghost of the sprite).
	var was: Dictionary = {}
	var readied: Array = []   # the foes ready to get back up: one that does falls and stands again in its slot
	for foe in sk.field_foes():
		var fv := _foe_view_for(foe)
		if fv != null:
			was[foe] = [fv, fv.sprite, fv.sprite_frame(), fv.flip_h]
		if Effects.has(foe, "risen"):
			readied.append(foe)
	var spent: Face = sk.mechs[i].face()
	var heat_before := _heat_marks()
	var fuel := spent.rolls_again_on if spent != null else ""
	var fuel_before := Effects.stacks_of(sk.mechs[i].unit, fuel) if not fuel.is_empty() else 0
	var ok := sk.assign(i, target, second)
	if ok:
		locked[i] = false
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
	var landed := fire_at + Sound.lands(blow)   # where the blow lands, from the die let go
	if ok and target is Foe:
		var tv: UnitView = was[target][0] if was.has(target) else null
		_flash_roll(tv)
		var dead: Array = []
		var fallen := ""
		for foe in was.keys():
			if not foe.alive() or (readied.has(foe) and not Effects.has(foe, "risen")):
				dead.append(foe)   # a foe that got back up dies on screen first, then stands again
				fallen = ContentDB.load_default().faction_of_foe(foe.content_id)
		if not quiet:
			if dead.is_empty():
				var said := Sound.claim_line("die_spent", PRE_LINE_AT)
				if said > 0.0:
					fire_at = PRE_LINE_AT + said * PRE_FIRE
			else:
				var hook := "foe_down_" + fallen
				Sound.claim_line(hook if Sound.FAMILIES.has(fallen) else "foe_down", landed + AFTER_DEATH)
		landed = fire_at + Sound.lands(blow)
		var ranged := not bool(sk.last_roll.get("melee", false))   # a melee weapon (the tag) lunges, anything else kicks back
		var hit := (target as Foe).alive()
		if fire_at > BLOW_AT and is_inside_tree():
			var tw := create_tween()   # the attacker moves when its weapon fires, into her line
			tw.tween_interval(fire_at - BLOW_AT)
			tw.tween_callback(_animate_attack.bind(_mech_views[i], tv, ranged, hit, BLOW_AT + Sound.lands(blow)))
		else:
			_animate_attack(_mech_views[i], tv, ranged, hit, landed)
		Sound.play_after(fire_at, blow)
		for k in range(dead.size()):
			var w: Array = was[dead[k]]
			_animate_death(w[0], w[1], w[2], w[3], landed)
			Sound.play_after(landed + 0.07 * k, "kill", -2.0 * k)
		# A last act (15 October): it lands as its foe falls, so the plaque names it after the
		# death and the machines it struck take it.
		if is_inside_tree():
			for act in sk.last_acts:
				var tw2 := create_tween()
				tw2.tween_interval(landed + 0.35)
				tw2.tween_callback(_announce.bind(str(act["name"])))
				for mi in act["mechs"]:
					if int(mi) >= 0 and int(mi) < _mech_views.size():
						tw2.tween_callback(_animate_hit.bind(_mech_views[int(mi)], 0.1))
	elif ok and target is Vector2i:
		# A shot laid in an empty slot (the Lammergeier's), or the pull's gather there: the
		# weapon fires and the machine kicks back, nothing struck.
		var slot: Vector2i = target
		_animate_attack(_mech_views[i], _slot_views[slot.x][slot.y], true, false, landed)
		Sound.play_after(fire_at, blow)
	elif ok and spent != null:
		var vent := spent.kind == Face.Kind.VENT
		var effect := "vent" if vent else blow
		if spent.kind == Face.Kind.VENT or spent.kind == Face.Kind.SHIELD or spent.kind == Face.Kind.BUFF:
			var hook := "heat_vented" if vent else ("shield" if spent.kind == Face.Kind.SHIELD else "buff")
			var said := 0.0 if quiet else Sound.claim_line(hook, PRE_LINE_AT)
			fire_at = PRE_LINE_AT + said * PRE_FIRE if said > 0.0 else 0.0
			Sound.play_after(fire_at, effect, -3.0 if spent.kind == Face.Kind.BUFF else 0.0)
			landed = fire_at + Sound.lands(effect)
	if not heat_hook.is_empty():
		Sound.say_after(landed + (AFTER_DEATH if target is Foe and not (target as Foe).alive() else 0.0), heat_hook)
	# A split's halves step up where it fell (the Gel's, 25 October), and a foe getting back up
	# stands again in its slot (26 October), in once the death has landed.
	if ok:
		var stepped := 0
		for foe in sk.field_foes():
			if not was.has(foe) or (readied.has(foe) and not Effects.has(foe, "risen")):
				_animate_arrival(_foe_view_for(foe), landed + 0.3)
				Sound.play_after(landed + 0.55 + 0.09 * stepped, "arrival", -3.0 * stepped)
				stepped += 1
	if ok and sk.outcome != Skirmish.Outcome.NONE:
		# Decided by this die: the fight ends once the last blow has landed and played.
		if is_inside_tree():
			var tw := create_tween()
			tw.tween_interval(landed + 0.75)
			tw.tween_callback(_show_outcome.bind(sk.outcome))
		else:
			_show_outcome(sk.outcome)
	return ok


# ---------------------------------------------------------------- filler animation
# Nothing here changes state. It makes the exchange readable: who struck, who was struck.

## A melee weapon (the tag) lunges the attacker at the target; anything else kicks it back. The target
## flashes and shakes a beat later, when the blow lands.
func _animate_attack(attacker: UnitView, target: UnitView, ranged: bool, hit: bool = true, lands: float = 0.08) -> void:
	if not is_inside_tree() or attacker == null:
		return
	_settle(attacker)
	var origin: Vector2 = _home.get(attacker, attacker.position)
	var mi := _mech_views.find(attacker)
	if mi >= 0 and mi < _mech_3d.size() and _mech_3d[mi] != null:
		_mech_3d[mi].strike(ranged)   # the arms swing when the model has joints
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


## A foe dies: a ghost of its drawing, where it stood, flashes, drops and fades, in the
## enemy's colour. The slot itself is already empty (a kill clears it at once), so the ghost
## stands in for the foe until the blow lands (`lands`), then goes.
func _animate_death(v: UnitView, tex: Texture2D, frame: Rect2, flip: bool, lands: float = 0.0) -> void:
	if not is_inside_tree() or v == null or tex == null:
		return
	var ghost := TextureRect.new()
	ghost.texture = tex
	ghost.flip_h = flip
	ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost.stretch_mode = TextureRect.STRETCH_SCALE
	ghost.texture_filter = v.texture_filter
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.position = _home.get(v, v.position) + frame.position
	ghost.size = frame.size
	add_child(ghost)
	var tw := create_tween()
	if lands > 0.0:
		tw.tween_interval(lands)
	tw.tween_property(ghost, "modulate", Color(2.0, 1.2, 1.2), 0.06)
	tw.tween_property(ghost, "modulate", Color(Palette.ENEMY_DIM, 1.0), 0.12)
	tw.set_parallel(true)
	tw.tween_property(ghost, "modulate", Color(Palette.ENEMY_DIM, 0.0), 0.4)
	tw.tween_property(ghost, "position:y", ghost.position.y + 16.0, 0.4).set_ease(Tween.EASE_IN)
	tw.set_parallel(false)
	tw.tween_callback(ghost.queue_free)


## What a control looks like at rest: an empty foe slot sits faint, everything else plain.
func _rest_modulate(v: Control) -> Color:
	if v is UnitView and v.is_enemy and not _view_foe.has(v):
		return Color(1, 1, 1, 0.3)
	return Color.WHITE


## The struck unit flashes bright, then shakes side to side and settles.
func _animate_hit(v: UnitView, delay: float = 0.0) -> void:
	if not is_inside_tree() or v == null:
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
	var tw := create_tween()
	if not sk.overheats.is_empty():
		tw.tween_callback(_land_overheats)
		tw.tween_interval(beat)
		tw.tween_callback(_set_phase.bind("ENEMY PHASE"))
	for st in steps:
		if not str(st["announce"]).is_empty():
			tw.tween_callback(_announce.bind(str(st["announce"])))
			tw.tween_interval(PLAQUE_HOLD)
		if not (st["blow"] as Array).is_empty():
			tw.tween_callback(_land_blow.bind(st["blow"]))
			tw.tween_interval(beat)
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
## kill. Jenny: a component damaged or destroyed. A machine the blow fells dies at the end of
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
	if fv != null and fv.visible:
		_animate_attack(fv, mv, false, true, landed)
	else:
		_animate_hit(mv, landed)
	Sound.play(foe_blow)
	var struck := "shield_break" if broke else ("shield_hit" if held else (Sound.struck("hit", maker) if through > 0 else Sound.struck("block", maker)))
	Sound.play_after(landed, struck, 0.0 if broke else -3.0)
	if _dying.has(mv):
		pass   # its death comes at the end of the turn
	elif injury == "destroyed":
		Sound.say_after(landed + VOICE_AFTER_BLOW, "component_destroyed")
	elif injury == "cracked":
		Sound.say_after(landed + VOICE_AFTER_BLOW, "component_damaged")
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
	mv.dead = true
	mv.queue_redraw()
	Sound.play(Sound.struck("kill", maker))
	Sound.say_after(Sound.death_voice_at(maker), "machine_lost")


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


func _on_reroll() -> void:
	if not _pending.is_empty():
		_cancel_second()   # a reroll takes the waiting die back to the tray first
	var idx: Array = []
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		if ms.alive() and not ms.assigned and not locked[i]:
			idx.append(i)
	sk.reroll(idx)
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


## RIFTGATE_RAGE_DEBUG: the roll again's look and sound on the machine that spends rage (the
## first machine when none does), a stack kept on it so its chip is there to burst. Nothing
## is spent and the die keeps its face.
func _rage_debug() -> void:
	var at := 0
	for k in range(sk.mechs.size()):
		for f in sk.mechs[k].die.faces:
			if f.rolls_again_on == "rage":
				at = k
	if sk.mechs.is_empty() or not sk.mechs[at].alive():
		return
	if Effects.stacks_of(sk.mechs[at].unit, "rage") < 3:
		Effects.stack(sk.mechs[at].unit, Effects.STATUS["rage"], Effects.SKIRMISH, "debug", 3, Effects.DECAY_NONE)
	Effects.spend_stacks(sk.mechs[at].unit, "rage", 1)   # spent as a fist spends it, so the burst is on the stack that went
	_refresh()
	_roll_again(at, "rage")


## Live dice that still hold a usable face.
func _unspent_count() -> int:
	var n := 0
	for ms in sk.mechs:
		if ms.alive() and not ms.assigned and ms.face() != null and ms.face().kind != Face.Kind.BLANK:
			n += 1
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
	Sound.play("resolve", -4.0)
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		if ms.alive() and not ms.assigned and ms.face() != null and ms.face().kind == Face.Kind.BLANK:
			sk.assign(i, null)
	var before := _before_enemy_turn()
	var field_before: Array[Foe] = sk.field_foes()
	var outcome := sk.end_round()
	if outcome == Skirmish.Outcome.NONE:
		sk.start_round()
		for i in range(locked.size()):
			locked[i] = false
	_refresh_log()   # the blows type into the log as they play
	_play_enemy_turn(before, func() -> void:
		if outcome != Skirmish.Outcome.NONE:
			_show_outcome(outcome)
			return
		_refresh()
		_acquire_intents()
		# Then the reinforcements step in.
		var arrived := 0
		for foe in sk.field_foes():
			if not field_before.has(foe):
				_animate_arrival(_foe_view_for(foe), 0.1)
				Sound.play_after(0.36 + 0.09 * arrived, "arrival", -3.0 * arrived)
				arrived += 1)


## A foe that joins the pool, whatever brought it there (a split with no room, a summon, a foe
## getting back up), is shown going in (Ryan, 25 October: "we need to make it clear when
## something joins the pool"): its picture lifts off where its pack stands (or appears at the
## formation's edge), shrinks into its rank's plaque in the gutter, and the count goes up there
## with a burst as it lands. The screen remembers who was waiting at its last look.
var _pool_last: Dictionary = {}   # Foe -> true: the pool as the screen last saw it
var _pool_primed := false         # the first look only remembers: the fight's opening pool is no join

func _pool_joins() -> void:
	var now := {}
	var joined: Array[Foe] = []
	for f in sk.reinforcements:
		now[f] = true
		if _pool_primed and not _pool_last.has(f):
			joined.append(f)
	_pool_last = now
	_pool_primed = true
	for k in range(joined.size()):
		_animate_pool_join(joined[k], 0.25 + 0.18 * k)


func _animate_pool_join(f: Foe, delay: float) -> void:
	var kind := "massive" if f.is_massive() else ("back" if f.prefers_back else "front")
	var tex := Sprites.combat_foe(f.content_id)
	if not is_inside_tree() or _reserve == null or tex == null:
		return
	_reserve.pending[kind] = int(_reserve.pending.get(kind, 0)) + 1
	_reserve.queue_redraw()
	var to := _reserve.position + _reserve.plaque_center(kind)
	var from := to + Vector2(-90.0, 0.0)
	for v in _view_foe.keys():
		var other: Foe = _view_foe[v]
		if other != null and other.pack_id == f.pack_id and other.alive():
			from = (v as Control).position + (v as Control).size * 0.5   # off its pack mate: the half beside it, the summoner
			break
	var used := Sprites.used_rect(tex)
	var sz := used.size * minf(1.0, 84.0 / maxf(used.size.x, used.size.y))
	var ghost := TextureRect.new()
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = used
	ghost.texture = at
	ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost.stretch_mode = TextureRect.STRETCH_SCALE
	ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.size = sz
	ghost.pivot_offset = sz * 0.5
	ghost.position = from - sz * 0.5
	ghost.modulate = Color(1.6, 0.8, 0.8, 0.0)
	add_child(ghost)
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_property(ghost, "modulate", Color(1.6, 0.8, 0.8, 1.0), 0.12)
	tw.tween_interval(0.18)
	tw.set_parallel(true)
	tw.tween_property(ghost, "position", to - sz * 0.5, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(ghost, "scale", Vector2(0.25, 0.25), 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(ghost, "modulate", Color(Palette.ENEMY, 0.5), 0.55)
	tw.set_parallel(false)
	tw.tween_callback(func() -> void:
		_reserve.arrive(kind)
		ghost.queue_free())
	Sound.play_after(delay + 0.85, "arrival", -6.0)


## Withdraw always asks first.
func _on_withdraw() -> void:
	if not sk.can_withdraw():
		return
	if not _pending.is_empty():
		_cancel_second()
	_ask("Withdraw? The enemy strikes once more as you pull out, and the pack keeps marching on the gate.", _withdraw_now)


## The enemy's parting blows play out before the team is seen to flee (Ryan, 23 September:
## the outcome came up over an unplayed turn).
func _withdraw_now() -> void:
	if not sk.can_withdraw():
		return
	var before := _before_enemy_turn()
	if sk.withdraw():
		_refresh_log()
		_play_enemy_turn(before, func() -> void: _show_outcome(sk.outcome))


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
			_overlay_text.text = "%d foes remain on the field and %d wait in reserve. They keep marching." % [sk.field_foes().size(), sk.reinforcements.size()]
	_overlay.visible = true
	finished.emit(outcome)

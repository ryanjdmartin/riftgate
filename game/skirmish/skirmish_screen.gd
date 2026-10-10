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
const SLOT_SIZE := Vector2(150, 194)     # floating gauge 18 + 48x64 foe at 2x + chip row 38
const MASSIVE_SIZE := Vector2(150, 388)  # 64x96 elites at 2x across both ranks
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
var _view_foe: Dictionary = {}       # UnitView -> Foe
var _mech_views: Array[UnitView] = []
var _dice: Array[DieFaceView] = []
var _ghost: DieFaceView
var _arrows: ArrowLayer
var _details: HudPanel
var _details_label: Label
var _details_faces: FaceListView
var _details_status: StatusListView
var _roll_label: Label
var _codex: CodexBox                 # the spec plate, shared with the battle screen
var _mech_3d: Array[MechView3D] = [] # parallel to _mech_views; null where the mech is a sprite
var _bg: HudBackdrop = null
var _plaque: Plaque = null           # the other world's window: a foe's named move, announced
var _plaque_debug_at := 0.0


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
	if PLAQUE_DEBUG and _plaque != null and not _plaque.is_showing() and _fight_t - _plaque_debug_at > PLAQUE_HOLD + 1.2:
		_plaque_debug_at = _fight_t
		var names: Array = []
		for f in sk.field_foes():
			for a in f.actions:
				names.append(str(a.get("name", "")))
		if names.is_empty():
			names = ["Protect", "1000 Needles", "Self-Destruct", "Bone Storm"]
		_announce(str(names[int(_fight_t / (PLAQUE_HOLD + 1.2)) % names.size()]))
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
## RIFTGATE_ELITE=1 adds the faction's boss as a third unit; RIFTGATE_COLUMNS=4 widens the formation.
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
	var fac := db.default_faction()
	var table: Array = db.spawn_table(fac)
	var uid := 1
	for entry in [table[0], table[table.size() - 1]] if not table.is_empty() else []:
		var sq := Unit.pack(uid, "%s pack" % str(entry[0]), Vector2i.ZERO, fac, 2, int(entry[1]), str(entry[0]))
		s.add_foes(db.foes_for(sq), sq)
		uid += 1
	if OS.get_environment("RIFTGATE_ELITE") == "1":
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
			_slot_views[rank][col] = v
		var mv := UnitView.new()
		mv.is_enemy = true
		mv.massive = true
		mv.visible = false
		_place(mv, Vector2(_col_x(col) - MASSIVE_SIZE.x * 0.5, BACK_Y), MASSIVE_SIZE)
		mv.held.connect(_on_foe_held.bind(mv))
		mv.hold_released.connect(_on_hold_released)
		mv.double_tapped.connect(_on_foe_double_tapped.bind(mv))
		_massive_views[col] = mv
	# The corrupted side's tear, over the foes and their ground alike (Ryan, 23 September:
	# under the sprites it was lost): a screen-reading layer the size of the foes' ground.
	var tear := TearLayer.new()
	tear.clock = bg.time
	tear.position = Vector2(0.0, BACK_Y - 14.0)
	tear.size = Vector2(W, LOG_Y - 10.0 - (BACK_Y - 14.0))
	add_child(tear)

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
			var maker := str(db.chassis.get(ms.unit.chassis_id, {}).get("maker", "minerva"))
			var view := MechView3D.make(ms.unit.chassis_id, maker, look, "badger", MechView3D.YAW_SKIRMISH, Vector2i.ZERO, false, ms.unit.paint, MechView3D.plan_for(ms.unit, db))
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

func _refresh() -> void:
	var assigning := sk.state == Skirmish.State.ASSIGN
	_header.text = "RND %02d // REINF %02d // %s" % [sk.round, sk.reinforcements.size(), str(BattleMap.TERRAIN_NAMES.get(sk.terrain, "plain")).to_upper()]
	_header.queue_redraw()
	_set_phase("ASSIGN" if assigning else "ENEMY PHASE")
	_view_foe.clear()

	var targets: Array[Foe] = []
	var support: Array[Skirmish.MechState] = []   # the machines a dragged piece of equipment may land on
	if _drag_from >= 0:
		var f := sk.mechs[_drag_from].face()
		if f != null and f.is_attack():
			targets = sk.targets_for(_drag_from)
		elif f != null and f.is_equipment():
			support = sk.equipment_targets_for(sk.mechs[_drag_from], f)

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
			if massive:
				continue
			var foe := sk.foe_at(rank, col)
			if foe == null:
				v.display_name = ""
				v.bars = []
				v.intent = ""
				v.intent_kind = ""
				v.statuses = []
				v.highlight = false
				v.dead = false
				v.sprite = null
				_settle(v)   # a hit still playing on the foe that stood here would end at full brightness
				v.modulate = Color(1, 1, 1, 0.3)
				v.queue_redraw()
				continue
			v.modulate = Color.WHITE
			_fill_foe_view(v, foe, targets, rank * sk.columns + col)
			_view_foe[v] = foe

	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		var v := _mech_views[i]
		# The forecast counts this die's own heat only while it is being dragged: shown
		# unasked, it read as something done to the mech rather than by the player.
		var fc: Dictionary = sk.forecast(ms, _drag_from == i) if assigning and ms.alive() else {}
		# Shield above hull: it is what the enemy meets first, and it drops first.
		v.bars = [
			[ms.unit.shield, ms.unit.shield_max, Palette.SHIELD, fc.get("shield_after", ms.unit.shield)],
			[ms.unit.hull, ms.unit.hull_max, Palette.HULL, fc.get("hull_after", ms.unit.hull)],
			[ms.heat, ms.heat_max, Palette.HEAT, fc.get("heat_after", ms.heat)],
		]
		v.dead = not ms.alive()
		v.highlight = support.has(ms)
		v.statuses = []
		for r in _mech_rows(i):
			v.statuses.append([r[0], r[1], r[3]])
		v.queue_refresh()
		var d := _dice[i]
		var sf := sk.shown_face(ms, ms.face())   # reach as the passive reads it now
		d.set_face(sf, sk.shown_number_text(ms, sf))   # and the number the blow will deal
		d.corrupted = Effects.corrupt_stacks(ms.unit, ms.face_index) if ms.face_index >= 0 else 0
		d.spent = ms.assigned
		d.dead = not ms.alive()
		d.locked = locked[i]
		d.can_tap = assigning and ms.alive() and not ms.assigned
		d.can_drag = assigning and ms.alive() and not ms.assigned
		# While a die is dragged, the one under the finger is the die: its slot goes empty
		# (Ryan, 26 September: a copy dragged beside the original read as a copy). Modulate,
		# not visible: the view must keep receiving the drag's motion.
		d.modulate = Color(1, 1, 1, 0.0) if _drag_from == i else Color.WHITE
		d.queue_redraw()

	_refresh_log()
	_reroll_btn.badge = "×%d" % sk.rerolls_left
	_reroll_btn.set_enabled(assigning and sk.can_reroll())
	_end_btn.set_enabled(assigning)
	_withdraw_btn.set_enabled(sk.can_withdraw())
	_refresh_arrows()
	if autosave.is_valid():
		autosave.call()


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
	# Enemies face left, the convention; a sprite painted facing right says so in content.
	v.flip_h = bool(ContentDB.load_default().foes.get(foe.content_id, {}).get("flip", false))
	v.breathe = true
	# Breathing spread by slot at the golden angle, so no two neighbours are near in phase
	# (Ryan, 23 September: the instance-id phases read as in step).
	v.breathe_phase = slot * 2.39996 + 0.7
	v.bars = [[foe.hp, foe.hp_max, Palette.HUD]]
	v.dead = not foe.alive()
	v.highlight = targets.has(foe)
	v.intent = ""
	v.intent_dim = false
	# The intent is this round's chosen attack: a sword, its damage, and a mark for a double
	# strike or a breach; a suppressed foe shows no intent, only the status; a dead one
	# threatens nothing.
	v.intent_kind = "" if (foe.is_suppressed() or foe.target == null or not foe.alive()) else Foe.kind_of(foe.action)
	v.intent_value = foe.damage() if foe.attacks() else int(foe.action.get("value", 0))
	v.intent_note = (("×%d" % foe.strikes() if foe.strikes() > 1 else "") + ("!" if foe.breaches() else "")) if foe.attacks() else ""
	v.statuses = []
	for r in _foe_rows(foe):
		v.statuses.append([r[0], r[1], r[3], r[4] if r.size() > 4 else "status"])
	v.queue_redraw()


## Statuses on a foe as [glyph, chip text, readout text, colour], and a fifth "resist" for a
## chip that is no status at all (Numbed, 10 October: drawn in brackets, never boxed).
func _foe_rows(foe: Foe) -> Array:
	var rows: Array = []
	if foe.burn_stacks() > 0:
		rows.append(["burn", str(foe.burn_stacks()), "Burning: %d damage a round, one stack less each round" % int(Effects.tick_preview(foe)["hp"]), Palette.HEAT])
	if foe.is_suppressed():
		rows.append(["suppress", "", "Suppressed: loses its action this round", Palette.HUD])
	if Effects.has(foe, "folded"):
		rows.append(["shield", "+%d" % Effects.foe_armour_bonus(foe), "Folded: armour +%d until its next action" % Effects.foe_armour_bonus(foe), Palette.SHIELD])
	if Effects.has(foe, "kindled"):
		rows.append(["overcharge", "+%d" % Effects.foe_attack_bonus(foe), "Kindled: hits %d harder this round" % Effects.foe_attack_bonus(foe), Palette.HEAT])
	if Effects.has(foe, "risen"):
		rows.append(["star", "", "Getting back up: returns from the pool once after dying", Palette.ENEMY])
	var paradox := Effects.stacks_of(foe, "paradox")
	if paradox > 0:
		var at := sk.paradox_count()
		rows.append(["paradox", "%d/%d" % [paradox, at] if at > 0 else str(paradox), "Paradox: %d%s; at the count its past self knocks it out (Suppressed), and the Paradox clears" % [paradox, " of %d" % at if at > 0 else ""], Palette.SHIELD])
	if Effects.has(foe, "shocked"):
		rows.append(["shocked", "×2", "Shocked: the next blow it takes lands double; striking bare hull again costs it %d" % Skirmish.SHOCK_DISCHARGE, Palette.HEAT])
	var numbed := Effects.stacks_of(foe, "numbed")
	if numbed > 0 or foe.stun_resist > 0:
		rows.append(["numbed", "%d%%" % foe.resist_total(), "Numbed, a resistance and not a status (nothing reads, deepens or clears it): shrugs off a suppress %d%% of the time (%d%% its own, 10%% a stack, a stack less each turn)" % [foe.resist_total(), foe.stun_resist], Palette.SHIELD, "resist"])
	if foe.rank == 1 and sk.is_exposed(foe.column):
		rows.append(["exposed", "", "Exposed: nothing in front, line weapons reach it", Palette.HUD])
	return rows


## Statuses and warnings on a mech as [glyph, chip text, readout text, colour]. Warnings come
## from the forecast: what the end of the round does if nothing changes.
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
	# the fight's statuses live here, as chips that the hold expands into their descriptions).
	for d in Effects.describe(ms.unit):
		if int(d[3]) < Effects.SKIRMISH:
			continue
		var id := str(d[5])
		var glyph := "heat" if id == "overheating" else ("corrupt" if id.begins_with("corrupted") else ("blank" if id.begins_with("disabled") else ("overcharge" if id == "overcharged" else ("shield" if id == "braced" else ("burn" if id == "primed" else ("shocked" if id == "retaliate" else ("reroll" if id == "scrambled" else "star")))))))
		var colour: Color = Palette.HEAT if id in ["overheating", "overcharged", "primed"] else (Palette.ENEMY if id.begins_with("corrupted") or id == "scrambled" else (Palette.SHIELD if id in ["braced", "retaliate"] else Palette.HUD))
		var stacks := int(d[4])
		rows.append([glyph, ("×%d" % stacks) if stacks > 1 else "", "%s: %s" % [str(d[0]), str(d[1])], colour])
	if sk.state == Skirmish.State.ASSIGN:
		var fc := sk.forecast(ms, _drag_from == i)
		if int(fc["overheat"]) > 0:
			# Overheating burns at the end of the round, so there is still time to vent.
			rows.append(["heat", "-%d" % int(fc["overheat"]), "Overheating: hull -%d at the end of the round unless vented" % int(fc["overheat"]), Palette.HEAT])
		if int(fc.get("volatile", 0)) > 0:
			rows.append(["volatile", "-%d" % int(fc["volatile"]), "Volatile: spending this component costs hull -%d, past shield and armour" % int(fc["volatile"]), Palette.ENEMY])
		if bool(fc["destroyed"]):
			rows.append(["skull", "", "Wrecked this round: %d incoming" % int(fc["incoming"]), Palette.ENEMY])
		elif bool(fc["component_risk"]):
			rows.append(["crack", "!", "A hit that big injures a component: the die is rolled", Palette.ENEMY])
		if bool(fc["breaks_shield"]):
			rows.append(["shieldbreak", "", "Incoming %d breaks the shield" % int(fc["incoming"]), Palette.ENEMY])
	return rows


func _foe_view_for(foe: Foe) -> UnitView:
	for v in _view_foe.keys():
		if _view_foe[v] == foe:
			return v
	return null


func _refresh_arrows() -> void:
	var list: Array = []
	var inv := _arrows.get_global_transform().affine_inverse()
	for foe in sk.field_foes():
		if foe.target == null or foe.is_suppressed() or not foe.alive():
			continue
		var target_index := sk.mechs.find(foe.target)
		if target_index < 0:
			continue
		var wanted := show_all_arrows or foe == _hold_foe or target_index == _hold_mech
		if not wanted:
			continue
		var fv := _foe_view_for(foe)
		if fv == null:
			continue
		var from: Vector2 = inv * fv.anchor_global()
		var to: Vector2 = inv * _mech_views[target_index].anchor_global()
		list.append([from, to, Palette.ENEMY])
	_arrows.set_arrows(list)


## Hold readout beside a control: a text block, then for a die every face in a column, or
## for a unit its statuses and warnings as icon-and-text rows.
func _show_details(text: String, near: Control, faces: Array = [], current: int = -1, rows: Array = [], labels: Array = []) -> void:
	_details_label.text = text
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
			label += " // DISABLED"
		var rot := Effects.corrupt_stacks(ms.unit, i)
		if rot > 0:
			label += " // CORRUPTED" + (" ×%d" % rot if rot > 1 else "")
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
	_show_details("%s // D%d" % [ms.unit.display_name.to_upper(), ms.die.size()], _dice[i], _shown_faces(ms), ms.face_index, [], _face_labels(ms, true))
	Sound.play("hold")


func _on_foe_held(v: UnitView) -> void:
	var foe: Foe = _view_foe.get(v, null)
	if foe == null:
		return
	_hold_foe = foe
	var text := "%s\nhp %d/%d · attack %d" % [foe.display_name, foe.hp, foe.hp_max, foe.attack]
	if not foe.alive():
		text += "\ndestroyed: cleared at the end of the round"
	else:
		if not foe.action.is_empty():
			if foe.attacks():
				text += "\n%s %d%s" % [str(foe.action.get("name", "")), foe.damage(), v.intent_note]
			else:
				text += "\n%s: %s" % [str(foe.action.get("name", "")), foe.text_of(foe.action)]
		if foe.target != null:
			text += "\n→ %s (%s)" % [foe.target.unit.display_name, str(Foe.AIM_TEXT.get(foe.aim_of(), foe.aim_of()))]
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
				_bg.scan = bool(value))
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
	_refresh_arrows()


func _on_drag_started(i: int) -> void:
	_drag_from = i
	Sound.play("die_pick")
	var sf := sk.shown_face(sk.mechs[i], sk.mechs[i].face())
	_ghost.set_face(sf, sk.shown_number_text(sk.mechs[i], sf))
	_ghost.corrupted = Effects.corrupt_stacks(sk.mechs[i].unit, sk.mechs[i].face_index)
	_ghost.visible = true
	_refresh()


func _on_drag_moved(global_pos: Vector2) -> void:
	if not _ghost.visible:
		return
	var local: Vector2 = get_global_transform().affine_inverse() * global_pos
	_ghost.position = local - Vector2(DIE_SIZE * 0.5, DIE_SIZE * 0.5)
	# The hover hum while the die is over somewhere it may be spent (Ryan, 5 October).
	var target = _drop_target_at(global_pos)
	var can := target != null and sk.can_assign(_drag_from, target)
	Sound.hover(can)
	# Over a foe it may strike, the die shows what it will deal to that foe (10 October):
	# its missing hull, a status on it, its armour. Anywhere else, the plain number.
	if _drag_from >= 0:
		var ms: Skirmish.MechState = sk.mechs[_drag_from]
		_ghost.set_number(sk.shown_number_text(ms, _ghost.face, target if can and target is Foe else null))


func _on_drag_ended(global_pos: Vector2) -> void:
	var i := _drag_from
	_drag_from = -1
	_ghost.visible = false
	Sound.hover(false)
	if i < 0:
		_refresh()
		return
	var target = _drop_target_at(global_pos)
	if target == null or not _use_die(i, target):
		Sound.play("die_drop")   # set back
	_refresh()


## What sits under a global point: a Foe, a MechState, or null.
func _drop_target_at(global_pos: Vector2):
	for v in _view_foe.keys():
		if v.visible and v.get_global_rect().has_point(global_pos):
			return _view_foe[v]
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
	return str(ContentDB.load_default().chassis.get(ms.unit.chassis_id, {}).get("maker", "minerva"))


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
func _use_die(i: int, target) -> bool:
	# Every foe's view and drawing before the die lands: a kill clears its slot at once, so
	# the death has to be played from what was there (the ghost of the sprite).
	var was: Dictionary = {}
	for foe in sk.field_foes():
		var fv := _foe_view_for(foe)
		if fv != null:
			was[foe] = [fv, fv.sprite, fv.sprite_frame(), fv.flip_h]
	var spent: Face = sk.mechs[i].face()
	var heat_before := _heat_marks()
	var ok := sk.assign(i, target)
	if ok:
		locked[i] = false
	_refresh()
	if ok:
		Sound.play("die_spend")   # the console letting the die go; the component's own sound lands after
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
			if not foe.alive():
				dead.append(foe)
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
	_set_phase("ENEMY PHASE")
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
	for h in hits:
		if int(h[5]) <= 0 and not h[1].dead and not _dying.has(h[1]):
			_dying[h[1]] = true
			deaths.append([h[1], h[10]])
	for ov in sk.overheats:
		var oi: int = ov["mech"]
		if oi >= 0 and oi < _mech_views.size() and int(ov["hull"]) <= 0 and not _mech_views[oi].dead and not _dying.has(_mech_views[oi]):
			_dying[_mech_views[oi]] = true
			deaths.append([_mech_views[oi], _maker_of(sk.mechs[oi])])
	var beat := _enemy_beat()
	var tw := create_tween()
	for st in steps:
		if not str(st["announce"]).is_empty():
			tw.tween_callback(_announce.bind(str(st["announce"])))
			tw.tween_interval(PLAQUE_HOLD)
		if not (st["blow"] as Array).is_empty():
			tw.tween_callback(_land_blow.bind(st["blow"]))
			tw.tween_interval(beat)
	if not sk.overheats.is_empty():
		tw.tween_callback(_land_overheats)
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
## special's always; a boss's blow's once per move, so a three-strike storm says it once; a
## plain blow's never), and `blow` is the blow to land after it, or empty for a special.
func _replay_steps(before: Dictionary) -> Array:
	var steps: Array = []
	for ev in sk.turn_events:
		var mi: int = ev["mech"]
		if mi < 0 or mi >= _mech_views.size():
			continue
		steps.append({"seq": int(ev.get("seq", steps.size())), "foe": ev["foe"], "name": str(ev.get("name", "")),
			"named": bool(ev.get("boss", false)), "announce": "",
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


## The round's overheats land together after the enemy's blows (the sim burns them at the
## round's end, all at once): the machines that ran hot flinch and their hull steps down.
## Heard once, however many burn.
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


## Withdraw always asks first.
func _on_withdraw() -> void:
	if not sk.can_withdraw():
		return
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
			_overlay_text.text = "The pack is gone. Rift pressure rose by %d." % sk.round
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

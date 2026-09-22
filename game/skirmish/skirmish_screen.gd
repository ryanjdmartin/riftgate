class_name SkirmishScreen
extends Control

## The skirmish screen as a tactical overlay. Portrait, 720x1280 logical, positioned
## absolutely so every coordinate is a plain number.
##
##   header      round and reinforcements tag, phase readout, the intent eye at the right
##   formation   two ranks of three unit views; a massive foe spans both ranks of its column;
##               under each foe its intent (fantasy icon and number) and its statuses
##   log         every event, scrollable, the newest brightest; double-tap for it full screen
##   dice        tap to lock, hold to see every face, drag onto a target to spend; the wide
##               Reroll sits right under them, before or after attacking
##   mechs       gauges hugging the sprite, warning chips under it: shield break, component
##               risk, wreck, overheat; the gauges pulse where they are about to change
##   bottom      End turn bottom-left, Withdraw bottom-right; both ask first when it matters
##
## No names on screen. Kinetic faces roll when they land and the number flashes over the
## target. Hold a unit for numbers, statuses and arrows, a die for every entry and what
## applies to it. Double-tap a unit for its codex entry.

signal finished(outcome: int)
signal back_requested

var back_label := "BACK"   # the outcome's button: the battle screen says where back leads

const W := 720.0
const H := 1280.0
const BACK_Y := 60.0
const FRONT_Y := 254.0
const SLOT_SIZE := Vector2(150, 194)     # floating gauge 18 + 48x64 foe at 2x + chip row 38
const MASSIVE_SIZE := Vector2(150, 388)  # 64x96 elites at 2x across both ranks
const EYE_Y := 452.0
const EYE := 44.0
const LOG_Y := 508.0
const LOG_H := 128.0
const DIE_Y := 656.0
const DIE_SIZE := 120.0
const REROLL_Y := 802.0
const REROLL_SIZE := Vector2(250, 54)
const MECH_Y := 892.0
const MECH_SIZE := Vector2(176, 284)   # gauges 46 + 80x96 sprite at 2x + chip row 38; neighbours overlap 4 px at PITCH
const BOTTOM_Y := 1196.0
const BOTTOM_BTN := Vector2(210, 60)
const PITCH := 172.0
const LOG_LINES := 7

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


## The backdrop's scan bar lights the mechs' traces as it crosses them, as on the map.
func _process(_delta: float) -> void:
	if _bg == null:
		return
	var y := _bg.scan_y()
	for i in range(_mech_3d.size()):
		var view := _mech_3d[i]
		if view == null or i >= _mech_views.size():
			continue
		var v := _mech_views[i]
		if v.size.y <= 0.0:
			continue
		view.set_sweep_screen((y - v.position.y) * float(view.size.y) / v.size.y)
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
	if sk == null:
		setup(_default_skirmish())
	elif _header == null:
		_build()
		_refresh()
	_scroll_to_end(_log_scroll)   # set up before entering the tree: the strip starts at its last line


## Standalone default, used when the scene runs on its own (screenshots, quick checks): two
## chained squads of the first faction in content. RIFTGATE_TEAM=badger,clydesdale,sparrowhawk,anvil overrides the team;
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
		var sq := Unit.squad(uid, "%s squad" % str(entry[0]), Vector2i.ZERO, fac, 2, int(entry[1]), str(entry[0]))
		s.add_foes(db.foes_for(sq), sq)
		uid += 1
	if OS.get_environment("RIFTGATE_ELITE") == "1":
		var boss := db.make_boss(uid, fac)
		s.add_foes(db.foes_for(boss), boss)
	return s


# ---------------------------------------------------------------- build

func _build() -> void:
	for c in get_children():
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
	custom_minimum_size = Vector2(W, H)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := HudBackdrop.new()
	bg.rules = [BACK_Y - 14.0, LOG_Y - 10.0, REROLL_Y + REROLL_SIZE.y + 14.0, BOTTOM_Y - 16.0]
	# The fight is on the enemy's ground (Ryan, 21 September): the foes stand on the other
	# world's flat bright overworld of this terrain; the mechs stand on the seam, the
	# reconstruction's tile with the other world eating into it from above.
	bg.grounds = [
		[Rect2(0.0, BACK_Y - 14.0, W, LOG_Y - 10.0 - (BACK_Y - 14.0)), sk.terrain, sk.rng.seed, "other"],
		[Rect2(0.0, REROLL_Y + REROLL_SIZE.y + 14.0, W, BOTTOM_Y - 16.0 - (REROLL_Y + REROLL_SIZE.y + 14.0)), sk.terrain, sk.rng.seed + 1, "seam"],
	]
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_bg = bg
	set_process(true)

	# Header: round and reinforcements tag, phase readout beside it.
	_header = _tag("", 13, true)
	_place(_header, Vector2(12, 14), Vector2(200, 28))
	_sub_label = Hud.label("", 12, Color(Palette.HUD, 0.7), Hud.mono())
	_place(_sub_label, Vector2(226, 20), Vector2(380, 20))
	# The intent eye sits right under the formation, at the right edge: toggled often, so it
	# stays within a thumb's reach of the foes it concerns.
	var menu_btn := HudButton.new("MENU", _open_menu)
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

	# Log between the formation and the dice: every line, the newest brightest, scrolled to
	# the end whenever something happens; drag to read back, double-tap for it full screen
	# (Ryan, 22 September: the strip alone was too little to follow a round).
	var log_tag := _tag("LOG", 10, true)
	_place(log_tag, Vector2(12, LOG_Y), Vector2(52, 18))
	_log_scroll = _log_scroller()
	_log_scroll.tooltip_text = "Drag to read back; double-tap to expand"
	_place(_log_scroll, Vector2(20, LOG_Y + 22), Vector2(W - 40, LOG_H - 22))
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
			var maker := str(ContentDB.load_default().chassis.get(ms.unit.chassis_id, {}).get("maker", "minerva"))
			var view := MechView3D.make(ms.unit.chassis_id, maker, look, "badger", MechView3D.YAW_SKIRMISH, Vector2i.ZERO, false, ms.unit.paint)
			# Idle: an aircraft hovers, a hover chassis skims, a ground machine stands still
			# (its idle is limb movement, which waits on annotated joints).
			if ms.unit.traits.has("flyer"):
				view.sway = true
				view.sway_bob = 1.4
				view.sway_yaw = 0.06
			elif ms.unit.traits.has("hover"):
				view.sway = true
				view.sway_bob = 0.6
				view.sway_yaw = 0.04
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
			if look == "clean":
				v.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_place(v, Vector2(cx - MECH_SIZE.x * 0.5, MECH_Y), MECH_SIZE)
		v.held.connect(_on_mech_held.bind(i))
		v.hold_released.connect(_on_hold_released)
		v.double_tapped.connect(_on_mech_double_tapped.bind(i))
		_mech_views.append(v)

	# Bottom row: End turn bottom-left, Withdraw bottom-right.
	_end_btn = HudButton.new("END TURN", _on_end_turn)
	_end_btn.filled = true
	_place(_end_btn, Vector2(16, BOTTOM_Y), BOTTOM_BTN)
	_withdraw_btn = HudButton.new("WITHDRAW", _on_withdraw)
	_withdraw_btn.ghost = true
	_withdraw_btn.tooltip_text = "Pull out: the enemy strikes once more, then the team flees."
	_place(_withdraw_btn, Vector2(W - 16 - BOTTOM_BTN.x, BOTTOM_Y), BOTTOM_BTN)

	# Overlays: arrows, drag ghost, roll flash, details, codex, confirm, outcome.
	_arrows = ArrowLayer.new()
	_arrows.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_arrows)
	_ghost = DieFaceView.new()
	_ghost.animate = false
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.modulate = Color(1, 1, 1, 0.85)
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
	no.custom_minimum_size = Vector2(0, 54)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(no)
	var yes := HudButton.new("YES", _confirm_yes)
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
	_header.text = "RND %02d // REINF %02d" % [sk.round, sk.reinforcements.size()]
	_header.queue_redraw()
	_sub_label.text = "ASSIGN" if assigning else "ENEMY PHASE"
	_view_foe.clear()

	var targets: Array[Foe] = []
	var support := false
	if _drag_from >= 0:
		var f := sk.mechs[_drag_from].face()
		if f != null and f.is_attack():
			targets = sk.targets_for(_drag_from)
		elif f != null and f.kind != Face.Kind.BLANK:
			support = true

	for col in range(sk.columns):
		var front_foe := sk.foe_at(0, col)
		var massive := front_foe != null and front_foe.is_massive()
		var mv: UnitView = _massive_views[col]
		mv.visible = massive
		if massive:
			_fill_foe_view(mv, front_foe, targets)
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
			_fill_foe_view(v, foe, targets)
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
		v.highlight = support and ms.alive()
		v.statuses = []
		for r in _mech_rows(i):
			v.statuses.append([r[0], r[1], r[3]])
		v.queue_refresh()
		var d := _dice[i]
		d.set_face(sk.shown_face(ms, ms.face()))   # reach as the passive reads it now
		d.spent = ms.assigned
		d.dead = not ms.alive()
		d.locked = locked[i]
		d.can_tap = assigning and ms.alive() and not ms.assigned
		d.can_drag = assigning and ms.alive() and not ms.assigned
		d.queue_redraw()

	_refresh_log()
	_reroll_btn.badge = "×%d" % sk.rerolls_left
	_reroll_btn.set_enabled(assigning and sk.rerolls_left > 0)
	_end_btn.set_enabled(assigning)
	_withdraw_btn.set_enabled(sk.can_withdraw())
	_refresh_arrows()


func _refresh_log() -> void:
	var fresh_lines := sk.log.size() > _log_seen
	_log.text = _log_text(LOG_LINES)
	# New lines type in, so the eye is drawn to what just happened, and the strip scrolls
	# to them; a strip the player scrolled back stays put until something new happens.
	if fresh_lines and is_inside_tree():
		var total := _log.get_total_character_count()
		var fresh := 0
		for j in range(_log_seen, sk.log.size()):
			fresh += sk.log[j].length() + 3
		_log.visible_characters = maxi(0, total - fresh)
		var tw := create_tween()
		tw.tween_property(_log, "visible_characters", total, minf(0.6, 0.012 * fresh))
		tw.tween_callback(func() -> void: _log.visible_characters = -1)
	if fresh_lines or _log_seen == 0:
		_scroll_to_end(_log_scroll)
	if _log_full != null and _log_full.visible and fresh_lines:
		_log_full_text.text = _log_text(0)
		_scroll_to_end(_log_full_scroll)
	_log_seen = sk.log.size()


## The whole log as bbcode, one line per event, the last `bright` lines fading up to full
## and everything older at the dim end; `bright` 0 leaves every line at full.
func _log_text(bright: int) -> String:
	var n := sk.log.size()
	if n == 0:
		return "[color=#%s]> round %d // %d in reserve // awaiting orders[/color]" % [Color(Palette.HUD, 0.45).to_html(true), sk.round, sk.reinforcements.size()]
	var start := maxi(0, n - bright)
	var count := n - start
	var out := ""
	for j in range(n):
		var a := 1.0
		if bright > 0:
			if j < start:
				a = 0.4
			elif count > 1:
				a = lerpf(0.4, 1.0, float(j - start) / float(count - 1))
		out += "[color=#%s]> %s[/color]\n" % [Color(Palette.HUD, a).to_html(true), sk.log[j]]
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


func _fill_foe_view(v: UnitView, foe: Foe, targets: Array[Foe]) -> void:
	v.display_name = foe.display_name
	v.sprite = Sprites.combat_foe(foe.content_id)
	# Enemies face left, the convention; a sprite painted facing right says so in content.
	v.flip_h = bool(ContentDB.load_default().foes.get(foe.content_id, {}).get("flip", false))
	v.breathe = true
	v.breathe_phase = float(foe.get_instance_id() % 97)
	v.bars = [[foe.hp, foe.hp_max, Palette.HUD]]
	v.dead = not foe.alive()
	v.highlight = targets.has(foe)
	v.intent = ""
	v.intent_dim = false
	# The intent is this round's chosen attack: a sword, its damage, and a mark for a double
	# strike or a breach; a suppressed foe shows no intent, only the status; a dead one
	# threatens nothing.
	v.intent_kind = "" if (foe.is_suppressed() or foe.target == null or not foe.alive()) else "attack"
	v.intent_value = foe.damage()
	v.intent_note = ("×%d" % foe.strikes() if foe.strikes() > 1 else "") + ("!" if foe.breaches() else "")
	v.statuses = []
	for r in _foe_rows(foe):
		v.statuses.append([r[0], r[1], r[3]])
	v.queue_redraw()


## Statuses on a foe as [glyph, chip text, readout text, colour].
func _foe_rows(foe: Foe) -> Array:
	var rows: Array = []
	if foe.burn_stacks() > 0:
		rows.append(["burn", str(foe.burn_stacks()), "Burning: %d damage a round, one stack less each round" % int(Effects.tick_preview(foe)["hp"]), Palette.HEAT])
	if foe.is_suppressed():
		rows.append(["suppress", "", "Suppressed: loses its action this round", Palette.HUD])
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
	var damaged := ms.unit.damaged_component_count()
	if damaged > 0:
		rows.append(["crack", str(damaged), "%d damaged component%s: repair in the hangar" % [damaged, "" if damaged == 1 else "s"], Palette.HUD])
	if sk.state == Skirmish.State.ASSIGN:
		var fc := sk.forecast(ms, _drag_from == i)
		if int(fc["overheat"]) > 0:
			# Overheating burns at the end of the round, so there is still time to vent.
			rows.append(["heat", "-%d" % int(fc["overheat"]), "Overheating: hull -%d at the end of the round unless vented" % int(fc["overheat"]), Palette.HEAT])
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


## The damage number pops over the struck foe, gold for a crit, then fades.
func _flash_roll(fv: UnitView) -> void:
	if sk.last_roll.is_empty() or fv == null:
		return
	var crit: bool = sk.last_roll["crit"]
	_roll_label.text = ("CRIT %d" if crit else "%d") % int(sk.last_roll["final"])
	_roll_label.add_theme_color_override("font_color", Palette.SELECT if crit else Palette.INK)
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
			text += "\n%s %d%s" % [str(foe.action.get("name", "")), foe.damage(), v.intent_note]
		if foe.target != null:
			text += "\n→ %s" % foe.target.unit.display_name
	if foe.is_massive():
		text += "\nmassive: fills the column"
	_show_details(text, v, [], -1, _readout_rows(_foe_rows(foe)))
	_refresh_arrows()


func _on_mech_held(i: int) -> void:
	_hold_mech = i
	var ms: Skirmish.MechState = sk.mechs[i]
	var text := "%s\nhull %d/%d · shield %d/%d · heat %d/%d" % [ms.unit.display_name, ms.unit.hull, ms.unit.hull_max, ms.unit.shield, ms.unit.shield_max, ms.heat, ms.heat_max]
	if ms.unit.cooling > 0:
		text += "\ncools %d at the start of each turn" % ms.unit.cooling
	_show_details(text, _mech_views[i], [], -1, _readout_rows(_mech_rows(i)))
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
				BattleMapView.pace = float(value))
		_menu.hud_changed.connect(func() -> void:
			_build()
			_refresh())
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
	_ghost.set_face(sk.shown_face(sk.mechs[i], sk.mechs[i].face()))
	_ghost.visible = true
	_refresh()


func _on_drag_moved(global_pos: Vector2) -> void:
	if not _ghost.visible:
		return
	var local: Vector2 = get_global_transform().affine_inverse() * global_pos
	_ghost.position = local - Vector2(DIE_SIZE * 0.5, DIE_SIZE * 0.5)


func _on_drag_ended(global_pos: Vector2) -> void:
	var i := _drag_from
	_drag_from = -1
	_ghost.visible = false
	if i < 0:
		_refresh()
		return
	var target = _drop_target_at(global_pos)
	if target != null:
		_use_die(i, target)
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


## Spend die `i` on `target` (a Foe or a MechState). Returns whether the simulation accepted it.
func _use_die(i: int, target) -> bool:
	# Every foe's view and drawing before the die lands: a kill clears its slot at once, so
	# the death has to be played from what was there (the ghost of the sprite).
	var was: Dictionary = {}
	for foe in sk.field_foes():
		var fv := _foe_view_for(foe)
		if fv != null:
			was[foe] = [fv, fv.sprite, fv.sprite_frame(), fv.flip_h]
	var ok := sk.assign(i, target)
	if ok:
		locked[i] = false
	_refresh()
	if ok and target is Foe:
		var tv: UnitView = was[target][0] if was.has(target) else null
		_flash_roll(tv)
		_animate_attack(_mech_views[i], tv, bool(sk.last_roll.get("ranged", false)), target.alive())
		for foe in was.keys():
			if not foe.alive():
				var w: Array = was[foe]
				_animate_death(w[0], w[1], w[2], w[3])
	if ok and sk.outcome != Skirmish.Outcome.NONE:
		# Decided by this die: the fight ends now, after the last blow has played.
		if is_inside_tree():
			var tw := create_tween()
			tw.tween_interval(0.75)
			tw.tween_callback(_show_outcome.bind(sk.outcome))
		else:
			_show_outcome(sk.outcome)
	return ok


# ---------------------------------------------------------------- filler animation
# Nothing here changes state. It makes the exchange readable: who struck, who was struck.

## A melee face lunges the attacker at the target; a ranged face kicks it back. The target
## flashes and shakes a beat later, when the blow lands.
func _animate_attack(attacker: UnitView, target: UnitView, ranged: bool, hit: bool = true) -> void:
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
		_animate_hit(target, 0.08)


## A foe dies: a ghost of its drawing, where it stood, flashes, drops and fades, in the
## enemy's colour. The slot itself is already empty (a kill clears it at once).
func _animate_death(v: UnitView, tex: Texture2D, frame: Rect2, flip: bool) -> void:
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


## The enemy's turn, replayed: each blow lunges its foe down at its mech in sequence, and a
## blow that broke the shield shatters it on the mech when it lands.
func _animate_enemy_turn(hits: Array) -> void:
	if not is_inside_tree():
		return
	var k := 0
	for h in hits:
		var fv: UnitView = h[0]
		var mv: UnitView = h[1]
		var broke: bool = h.size() > 2 and h[2]
		if mv == null:
			continue
		var tw := create_tween()
		tw.tween_interval(0.12 * k)
		tw.tween_callback(func() -> void:
			if fv != null:
				_animate_attack(fv, mv, false)
			else:
				_animate_hit(mv)   # the striker's slot has changed hands since: the blow still shows
			if broke:
				var t2 := create_tween()
				t2.tween_interval(0.08)
				t2.tween_callback(mv.shatter_shield))
		k += 1


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


## Ends the player's turn: unspent blank faces are discarded, the enemy acts, and the next
## round starts at once so the player is straight back to their own dice.
func _end_turn_now() -> void:
	if sk.state != Skirmish.State.ASSIGN:
		return
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		if ms.alive() and not ms.assigned and ms.face() != null and ms.face().kind == Face.Kind.BLANK:
			sk.assign(i, null)
	var before: Array[Foe] = sk.field_foes()
	var outcome := sk.end_round()
	if outcome != Skirmish.Outcome.NONE:
		_show_outcome(outcome)
		return
	sk.start_round()
	for i in range(locked.size()):
		locked[i] = false
	_refresh()
	# The blows the sim just resolved, in order, so the replay shows what happened: who
	# lunged at whom, and where a shield broke. Views are looked up after the refresh, so a
	# slot a reinforcement has since taken never lunges as if it had struck.
	var hits: Array = []
	for ev in sk.turn_events:
		var mi: int = ev["mech"]
		if mi >= 0 and mi < _mech_views.size():
			hits.append([_foe_view_for(ev["foe"]), _mech_views[mi], bool(ev["broke_shield"])])
	_animate_enemy_turn(hits)
	# Then the reinforcements step in, after the replay has played.
	var after_replay := 0.12 * hits.size() + 0.3
	for foe in sk.field_foes():
		if not before.has(foe):
			_animate_arrival(_foe_view_for(foe), after_replay)


## Withdraw always asks first.
func _on_withdraw() -> void:
	if not sk.can_withdraw():
		return
	_ask("Withdraw? The enemy strikes once more as you pull out, and the squad keeps marching on the gate.", _withdraw_now)


func _withdraw_now() -> void:
	if sk.withdraw():
		_show_outcome(sk.outcome)


func _show_outcome(outcome: int) -> void:
	_refresh()
	match outcome:
		Skirmish.Outcome.VICTORY:
			_overlay_title.text = "VICTORY"
			_overlay_text.text = "The squad is gone. Rift pressure rose by %d." % sk.round
		Skirmish.Outcome.DEFEAT:
			_overlay_title.text = "WRECKED"
			_overlay_text.text = "Every machine is down. Survivors of the squad march on."
		_:
			_overlay_title.text = "WITHDREW"
			_overlay_text.text = "%d foes remain on the field and %d wait in reserve. They keep marching." % [sk.field_foes().size(), sk.reinforcements.size()]
	_overlay.visible = true
	finished.emit(outcome)

class_name SkirmishScreen
extends Control

## The skirmish screen as a tactical overlay. Portrait, 720x1280 logical, positioned
## absolutely so every coordinate is a plain number.
##
##   header      round and reinforcements tag, phase readout, the intent eye at the right
##   formation   two ranks of three unit views; a massive foe spans both ranks of its column;
##               under each foe its intent (fantasy icon and number) and its statuses
##   log         the last few events, oldest dimmest
##   dice        tap to lock, hold to see every face, drag onto a target to spend; the wide
##               Reroll sits right under them, before or after attacking
##   mechs       gauges hugging the sprite, warning chips under it: shield break, component
##               risk, wreck, overheat; the gauges pulse where they are about to change
##   bottom      End turn bottom-left, Withdraw bottom-right; both ask first when it matters
##
## No names on screen. Kinetic faces roll when they land and the number flashes over the
## target. Hold a unit for numbers, statuses and arrows. Double-tap a unit or a die for its
## codex entry.

signal finished(outcome: int)
signal back_requested

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
const MECH_SIZE := Vector2(176, 272)   # gauges 35 + 80x96 sprite at 2x + chip row 38; neighbours overlap 4 px at PITCH
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
var _codex_shade: Control
var _codex: HudPanel
var _codex_title: Label
var _codex_sub: Label
var _codex_sprite: TextureRect
var _codex_body: Label
var _codex_designation: HudButton   # a stamped tag, not a label, so the plate does not read as three stacked lines
var _codex_stats: StatBlock
var _codex_view: MechView3D = null   # the spinning model, when mechs are 3D
var _mech_3d: Array[MechView3D] = [] # parallel to _mech_views; null where the mech is a sprite
var _codex_actions: Label
var _codex_passive: Label
var _codex_faces: FaceListView
var _codex_flavour: Label
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


## Standalone default, used when the scene runs on its own (screenshots, quick checks): two
## chained squads of the first faction in content. RIFTGATE_TEAM=badger,sentinel,raptor,anvil overrides the team;
## RIFTGATE_ELITE=1 adds the faction's boss as a third unit; RIFTGATE_COLUMNS=4 widens the formation.
static func _default_skirmish() -> Skirmish:
	var db := ContentDB.load_default()
	var s := Skirmish.new(7, int(OS.get_environment("RIFTGATE_COLUMNS")) if not OS.get_environment("RIFTGATE_COLUMNS").is_empty() else Skirmish.DEFAULT_COLUMNS)
	var team: Array = db.default_team()
	var env := OS.get_environment("RIFTGATE_TEAM")
	if not env.is_empty():
		team = env.split(",")
	for id in team:
		if db.chassis.has(id):
			s.add_mech(db.make_mech(id))
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
	custom_minimum_size = Vector2(W, H)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := HudBackdrop.new()
	bg.rules = [BACK_Y - 14.0, LOG_Y - 10.0, REROLL_Y + REROLL_SIZE.y + 14.0, BOTTOM_Y - 16.0]
	# Ground under each side, in the terrain the fight is on: the map's texture, carried in.
	bg.grounds = [
		[Rect2(0.0, BACK_Y - 14.0, W, LOG_Y - 10.0 - (BACK_Y - 14.0)), sk.terrain, sk.rng.seed],
		[Rect2(0.0, REROLL_Y + REROLL_SIZE.y + 14.0, W, BOTTOM_Y - 16.0 - (REROLL_Y + REROLL_SIZE.y + 14.0)), sk.terrain, sk.rng.seed + 1],
	]
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Header: round and reinforcements tag, phase readout beside it.
	_header = _tag("", 13, true)
	_place(_header, Vector2(12, 14), Vector2(200, 28))
	_sub_label = Hud.label("", 12, Color(Palette.HUD, 0.7), Hud.mono())
	_place(_sub_label, Vector2(226, 20), Vector2(380, 20))
	# The intent eye sits right under the formation, at the right edge: toggled often, so it
	# stays within a thumb's reach of the foes it concerns.
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

	# Log between the formation and the dice, oldest line dimmest.
	var log_tag := _tag("LOG", 10, true)
	_place(log_tag, Vector2(12, LOG_Y), Vector2(52, 18))
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_active = false
	_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_log.add_theme_font_override("normal_font", Hud.mono())
	_log.add_theme_font_size_override("normal_font_size", 14)
	_log.add_theme_color_override("default_color", Palette.HUD)
	_place(_log, Vector2(20, LOG_Y + 22), Vector2(W - 40, LOG_H - 22))

	# Dice in the middle, each centred on its mech.
	var n := sk.mechs.size()
	for i in range(n):
		var cx := _column_x(i, n)
		var d := DieFaceView.new()
		_place(d, Vector2(cx - DIE_SIZE * 0.5, DIE_Y), DieFaceView.view_size())
		d.tapped.connect(_on_die_tapped.bind(i))
		d.double_tapped.connect(_on_die_double_tapped.bind(i))
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
	_reroll_btn.tooltip_text = "A reroll never shows the same face twice."
	_place(_reroll_btn, Vector2(W * 0.5 - REROLL_SIZE.x * 0.5, REROLL_Y), REROLL_SIZE)

	# Mechs: gauges hugging the sprite, three-quarter sprite, chip row beneath.
	for i in range(n):
		var cx := _column_x(i, n)
		var ms: Skirmish.MechState = sk.mechs[i]
		var v := UnitView.new()
		v.display_name = ms.unit.display_name
		v.bars_above = true
		v.sprite = Sprites.combat_mech(ms.unit.chassis_id, "front_right")
		# Mechs are 3D (decided 16 September). RIFTGATE_MECH3D=pixel switches the look,
		# RIFTGATE_MECH3D=off falls back to the 2D sprites; a chassis with no model uses the Badger's.
		var look := MechView3D.look_setting()
		_mech_3d.append(null)
		if look == "pixel" or look == "clean":
			var maker := str(ContentDB.load_default().chassis.get(ms.unit.chassis_id, {}).get("maker", "minerva"))
			var view := MechView3D.make(ms.unit.chassis_id, maker, look, "badger", MechView3D.YAW_SKIRMISH)
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
	_withdraw_btn.tooltip_text = "Available at the start of a round, before spending a face."
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


func _build_codex() -> void:
	# Codex: a double-tap opens it; a tap anywhere outside closes it. Head-on sprite top-right,
	# across from the name.
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.6)
	_codex_shade = shade
	_codex_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_codex_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_codex_shade.visible = false
	_codex_shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			_close_codex())
	add_child(_codex_shade)
	_codex = HudPanel.new(24.0)
	_codex.custom_minimum_size = Vector2(640, 0)
	_codex.visible = false
	_place(_codex, Vector2(40, 150), Vector2(640, 0))
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 10)
	_codex.add_child(cv)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	cv.add_child(top)
	var head := VBoxContainer.new()
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_theme_constant_override("separation", 4)
	top.add_child(head)
	# Name plate: the maker's designation as a stamped tag, the nickname big in quotes, then
	# maker and silhouette as the subtitle. Like a spec plate on the hull.
	_codex_designation = _tag("", 12, true)
	_codex_designation.custom_minimum_size = Vector2(0, 24)
	_codex_designation.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_codex_title = Hud.label("", 34, Palette.INK, Hud.display_bold())
	_codex_sub = Hud.label("", 13, Color(Palette.HUD, 0.8), Hud.mono())
	_codex_sub.autowrap_mode = TextServer.AUTOWRAP_WORD
	_codex_sub.custom_minimum_size = Vector2(340, 0)
	_codex_sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_codex_designation)
	head.add_child(_codex_title)
	head.add_child(_codex_sub)
	_codex_sprite = TextureRect.new()
	_codex_sprite.custom_minimum_size = Vector2(200, 240)    # the corner portrait, top-right
	_codex_sprite.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_codex_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_codex_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_codex_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_codex_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(_codex_sprite)
	# The play half: the stat grid sits beside the portrait; the passive and any actions run
	# full width under both, so they need not wrap around the picture; the faces run in two
	# columns under that. A thin rule separates play from lore: codex text, then quote.
	_codex_stats = StatBlock.new()
	_codex_stats.custom_minimum_size = Vector2(340, 0)
	_codex_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_codex_passive = Hud.label("", 17, Palette.ACCENT)
	_codex_actions = Hud.label("", 14, Palette.INK, Hud.mono())
	_codex_body = Hud.label("", 19, Palette.INK)
	_codex_faces = FaceListView.new()
	_codex_faces.columns = 2
	_codex_flavour = Hud.label("", 18, Palette.MUTED, Hud.quote())
	# Wrapping labels need a width before their first layout pass, or they report the height
	# of every word on its own line and the panel opens far too tall the first time.
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	head.add_child(spacer)
	head.add_child(_codex_stats)
	for l in [_codex_passive, _codex_actions]:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.custom_minimum_size = Vector2(560, 0)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		cv.add_child(l)
	cv.add_child(_codex_faces)
	var rule := ColorRect.new()
	rule.color = Color(Palette.HUD, 0.25)
	rule.custom_minimum_size = Vector2(0, 1)
	cv.add_child(rule)
	for l in [_codex_body, _codex_flavour]:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.custom_minimum_size = Vector2(560, 0)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		cv.add_child(l)
	var gap := Control.new()   # air between the quote and the button
	gap.custom_minimum_size = Vector2(0, 8)
	cv.add_child(gap)
	var close := HudButton.new("CLOSE", _close_codex)
	close.custom_minimum_size = Vector2(0, 52)
	cv.add_child(close)


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
	var back := HudButton.new("BACK", func() -> void: back_requested.emit())
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
				v.modulate = Color(1, 1, 1, 0.3)
				v.queue_redraw()
				continue
			v.modulate = Color.WHITE
			_fill_foe_view(v, foe, targets)
			_view_foe[v] = foe

	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		var v := _mech_views[i]
		var fc: Dictionary = sk.forecast(ms) if assigning and ms.alive() else {}
		v.bars = [
			[ms.unit.hull, ms.unit.hull_max, Palette.HUD, fc.get("hull_after", ms.unit.hull)],
			[ms.unit.shield, ms.unit.shield_max, Color(Palette.HUD, 0.55), fc.get("shield_after", ms.unit.shield)],
			[ms.heat, ms.heat_max, Palette.HEAT, fc.get("heat_after", ms.heat)],
		]
		v.dead = not ms.alive()
		v.highlight = support and ms.alive()
		v.statuses = []
		for r in _mech_rows(i):
			v.statuses.append([r[0], r[1], r[3]])
		v.queue_refresh()
		var d := _dice[i]
		d.set_face(ms.face())
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
	var start := maxi(0, sk.log.size() - LOG_LINES)
	var count := sk.log.size() - start
	var out := ""
	if count == 0:
		out = "[color=#%s]> round %d // %d in reserve // awaiting orders[/color]" % [Color(Palette.HUD, 0.45).to_html(true), sk.round, sk.reinforcements.size()]
	for j in range(start, sk.log.size()):
		var age := j - start
		var a := 1.0 if count <= 1 else lerpf(0.4, 1.0, float(age) / float(count - 1))
		out += "[color=#%s]> %s[/color]\n" % [Color(Palette.HUD, a).to_html(true), sk.log[j]]
	_log.text = out
	# New lines type in, so the eye is drawn to what just happened.
	if sk.log.size() > _log_seen and is_inside_tree():
		var total := _log.get_total_character_count()
		var fresh := 0
		for j in range(_log_seen, sk.log.size()):
			fresh += sk.log[j].length() + 3
		_log.visible_characters = maxi(0, total - fresh)
		var tw := create_tween()
		tw.tween_property(_log, "visible_characters", total, minf(0.6, 0.012 * fresh))
		tw.tween_callback(func() -> void: _log.visible_characters = -1)
	_log_seen = sk.log.size()


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
	# The engine runs only the basic attack, so the intent is a sword and its damage; a
	# suppressed foe shows no intent, only the status.
	v.intent_kind = "" if (foe.suppressed or foe.target == null) else "attack"
	v.intent_value = foe.attack
	v.statuses = []
	for r in _foe_rows(foe):
		v.statuses.append([r[0], r[1], r[3]])
	v.queue_redraw()


## Statuses on a foe as [glyph, chip text, readout text, colour].
func _foe_rows(foe: Foe) -> Array:
	var rows: Array = []
	if foe.burn > 0:
		rows.append(["burn", str(foe.burn), "Burning: %d damage a round, one stack less each round" % (foe.burn * Skirmish.BURN_PER_STACK), Palette.HEAT])
	if foe.suppressed:
		rows.append(["suppress", "", "Suppressed: loses its action this round", Palette.HUD])
	if foe.rank == 1 and sk.is_exposed(foe.column):
		rows.append(["exposed", "", "Exposed: nothing in front, line faces reach it", Palette.HUD])
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
	if ms.heat >= ms.heat_max:
		rows.append(["heat", "MAX", "Heat at maximum: any more burns hull", Palette.HEAT])
	var damaged := ms.unit.damaged_face_count()
	if damaged > 0:
		rows.append(["crack", str(damaged), "%d damaged component%s: repair in the hangar" % [damaged, "" if damaged == 1 else "s"], Palette.HUD])
	if sk.state == Skirmish.State.ASSIGN:
		var fc := sk.forecast(ms)
		if int(fc["overheat"]) > 0:
			rows.append(["heat", "+%d" % int(fc["overheat"]), "This face overheats: hull -%d" % int(fc["overheat"]), Palette.HEAT])
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
		if foe.target == null or foe.suppressed:
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
func _show_details(text: String, near: Control, faces: Array = [], current: int = -1, rows: Array = []) -> void:
	_details_label.text = text
	_details_faces.visible = not faces.is_empty()
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
	var pos := near.position + Vector2(near.size.x + 8.0, 0)
	if pos.x + width > W - 8.0:
		pos.x = near.position.x - width - 8.0
	pos.x = clampf(pos.x, 8.0, W - width - 8.0)
	var height := wanted.y
	if pos.y + height > H - 8.0:
		pos.y = H - 8.0 - height
	_details.position = pos


## The damage number pops over the struck foe, gold for a crit, then fades.
func _flash_roll() -> void:
	if sk.last_roll.is_empty():
		return
	var foe: Foe = sk.last_roll["target"]
	var fv := _foe_view_for(foe)
	if fv == null:
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


func _on_die_double_tapped(i: int) -> void:
	# The first tap of the pair already toggled the lock; put it back, then open the codex.
	var ms: Skirmish.MechState = sk.mechs[i]
	if sk.state == Skirmish.State.ASSIGN and ms.alive() and not ms.assigned:
		locked[i] = not locked[i]
	var db := ContentDB.load_default()
	var entry := db.codex_for_unit(ms.unit)
	entry["title"] = "%s die" % ms.unit.display_name
	entry["designation"] = ""     # the die is not the machine: no spec-plate tag, no quotes
	entry["subtitle"] = "D%d // ONE FACE PER HARDPOINT // EACH FACE 1 IN %d PER ROLL // A REROLL NEVER REPEATS A FACE" % [ms.die.size(), ms.die.size()]
	entry["body"] = ""
	entry["stats"] = ""
	entry["stat_items"] = []
	entry["faces"] = ms.die.faces.duplicate()
	entry["current"] = ms.face_index
	entry["passive"] = ""
	entry["flavour"] = ""
	_open_codex(entry)


func _on_die_held(i: int) -> void:
	var ms: Skirmish.MechState = sk.mechs[i]
	_show_details("%s // D%d" % [ms.unit.display_name.to_upper(), ms.die.size()], _dice[i], ms.die.faces.duplicate(), ms.face_index)


func _on_foe_held(v: UnitView) -> void:
	var foe: Foe = _view_foe.get(v, null)
	if foe == null:
		return
	_hold_foe = foe
	var text := "%s\nhp %d/%d · attack %d" % [foe.display_name, foe.hp, foe.hp_max, foe.attack]
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


## Fill and show the codex. Entry keys: title, subtitle, body, stats, actions, passive, faces
## (Array of Face), current (index), flavour, sprite_id (a chassis or foe id).
func _open_codex(entry: Dictionary) -> void:
	_details.visible = false
	_hold_foe = null
	_hold_mech = -1
	_refresh_arrows()
	var designation := str(entry.get("designation", "")).to_upper()
	# A mech with a designation gets its nickname in quotes; a foe or a die keeps its name plain.
	_codex_title.text = ("“%s”" % str(entry.get("title", ""))) if not designation.is_empty() else str(entry.get("title", ""))
	_codex_sub.text = str(entry.get("subtitle", ""))
	_codex_designation.text = designation
	_codex_designation.custom_minimum_size.x = Hud.mono().get_string_size(designation, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 30.0
	_codex_designation.visible = not designation.is_empty()
	_codex_designation.queue_redraw()
	var sid := str(entry.get("sprite_id", ""))
	var tex: Texture2D = null
	if _codex_view != null:
		_codex_view.queue_free()
		_codex_view = null
	var look := MechView3D.look_setting()
	if not sid.is_empty() and (look == "pixel" or look == "clean") and MechView3D.has_model(sid):
		# Mechs in 3D: the codex gets the model itself, turning slowly.
		var maker := str(ContentDB.load_default().chassis.get(sid, {}).get("maker", "minerva"))
		_codex_view = MechView3D.make(sid, maker, "clean", "badger", MechView3D.YAW_FRONT, Vector2i(200, 240), true)
		add_child(_codex_view)
		tex = _codex_view.texture
	elif not sid.is_empty():
		tex = Sprites.combat_mech(sid, "front")
		if tex == null:
			tex = Sprites.combat_foe(sid)
	_codex_sprite.texture = tex
	_codex_sprite.visible = tex != null
	_codex_stats.set_items(entry.get("stat_items", []))
	for pair in [[_codex_body, "body"], [_codex_actions, "actions"], [_codex_passive, "passive"]]:
		var l: Label = pair[0]
		l.text = str(entry.get(pair[1], ""))
		l.visible = not l.text.is_empty()
	var faces: Array = entry.get("faces", [])
	_codex_faces.visible = not faces.is_empty()
	if not faces.is_empty():
		_codex_faces.set_faces(faces, int(entry.get("current", -1)))
	var quote := str(entry.get("flavour", ""))
	_codex_flavour.text = "“%s”" % quote if not quote.is_empty() else ""
	_codex_flavour.visible = not quote.is_empty()
	_codex_shade.visible = true
	_codex.visible = true
	_fit_codex()
	# Wrapping labels report their true height only after a layout pass at the panel's
	# width, so the first open used to come out the wrong size. Fit again once that has run.
	_fit_codex.call_deferred()


func _fit_codex() -> void:
	_codex.reset_size()
	_codex.size = Vector2(640, _codex.get_combined_minimum_size().y)


func _close_codex() -> void:
	_codex.visible = false
	_codex_shade.visible = false
	if _codex_view != null:
		_codex_view.queue_free()
		_codex_view = null


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
	_ghost.set_face(sk.mechs[i].face())
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
	var ok := sk.assign(i, target)
	if ok:
		locked[i] = false
	_refresh()
	if ok and target is Foe:
		_flash_roll()
		_animate_attack(_mech_views[i], _foe_view_for(target), bool(sk.last_roll.get("ranged", false)))
	return ok


# ---------------------------------------------------------------- filler animation
# Nothing here changes state. It makes the exchange readable: who struck, who was struck.

## A melee face lunges the attacker at the target; a ranged face kicks it back. The target
## flashes and shakes a beat later, when the blow lands.
func _animate_attack(attacker: UnitView, target: UnitView, ranged: bool) -> void:
	if not is_inside_tree() or attacker == null:
		return
	var origin := attacker.position
	var mi := _mech_views.find(attacker)
	if mi >= 0 and mi < _mech_3d.size() and _mech_3d[mi] != null:
		_mech_3d[mi].strike(ranged)   # the arms swing when the model has joints
	var tw := create_tween()
	if ranged or target == null:
		var kick := Vector2(0.0, 8.0) if attacker in _mech_views else Vector2(0.0, -8.0)
		tw.tween_property(attacker, "position", origin + kick, 0.05).set_ease(Tween.EASE_OUT)
		tw.tween_property(attacker, "position", origin, 0.18).set_ease(Tween.EASE_OUT)
	else:
		var dir := (target.anchor_global() - attacker.anchor_global()).normalized()
		tw.tween_property(attacker, "position", origin + dir * 18.0, 0.09).set_ease(Tween.EASE_OUT)
		tw.tween_property(attacker, "position", origin, 0.16).set_ease(Tween.EASE_IN_OUT)
	if target != null:
		_animate_hit(target, 0.08)


## The struck unit flashes bright, then shakes side to side and settles.
func _animate_hit(v: UnitView, delay: float = 0.0) -> void:
	if not is_inside_tree() or v == null:
		return
	var origin := v.position
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_property(v, "modulate", Color(1.8, 1.4, 1.4), 0.04)
	tw.tween_property(v, "modulate", Color.WHITE, 0.22)
	var shake := create_tween()
	shake.tween_interval(delay)
	for k in range(4):
		var dx := (5.0 - k * 1.2) * (1.0 if k % 2 == 0 else -1.0)
		shake.tween_property(v, "position", origin + Vector2(dx, 0.0), 0.035)
	shake.tween_property(v, "position", origin, 0.05)


## The enemy's turn, replayed: each foe that struck lunges down at its mech in sequence.
func _animate_enemy_turn(hits: Array) -> void:
	if not is_inside_tree():
		return
	var k := 0
	for h in hits:
		var fv: UnitView = h[0]
		var mv: UnitView = h[1]
		if fv == null or mv == null:
			continue
		var tw := create_tween()
		tw.tween_interval(0.12 * k)
		tw.tween_callback(func() -> void: _animate_attack(fv, mv, false))
		k += 1


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
	var hits: Array = []
	for i in range(sk.mechs.size()):
		var ms2: Skirmish.MechState = sk.mechs[i]
		if not ms2.alive():
			continue
		for foe in sk.attackers_of(ms2):
			hits.append([_foe_view_for(foe), _mech_views[i]])
	var outcome := sk.end_round()
	if outcome != Skirmish.Outcome.NONE:
		_show_outcome(outcome)
		return
	sk.start_round()
	for i in range(locked.size()):
		locked[i] = false
	_refresh()
	_animate_enemy_turn(hits)


## Withdraw always asks first.
func _on_withdraw() -> void:
	if not sk.can_withdraw():
		return
	_ask("Withdraw from the skirmish? The squad keeps marching on the gate.", _withdraw_now)


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

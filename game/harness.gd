extends Control

## Debug harness and main scene. Pick a team, then compose the enemy side the way the
## battlefield would: one or two packs (a foe type times a count) and optionally the faction's
## boss, all chained into one skirmish. Also opens the battlefield map viewer.

const SKIRMISH_SCENE := preload("res://game/skirmish/skirmish_screen.tscn")
const BATTLE_SCENE := preload("res://game/battle/battle_screen.tscn")
const MAP_SCENE := preload("res://game/main.tscn")

var db: ContentDB
var _chassis_checks: Dictionary = {}   # id -> CheckBox
var _foe_a: OptionButton
var _count_a: SpinBox
var _foe_b: OptionButton
var _count_b: SpinBox
var _boss: OptionButton
var _seed: SpinBox
var _menu: Control
var _current: Node = null


func _ready() -> void:
	Settings.apply()
	Hud.oversample(get_window())   # text rasterised at the glass's density, not the design's
	db = ContentDB.load_default()
	_build_menu()


func _build_menu() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR   # text, see Hud.oversample; pixel art pins nearest on itself
	# The harness must not swallow input meant for the scene it hosts (the map viewer reads
	# unhandled mouse events), so the root and its backdrop ignore the mouse.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	_menu = MarginContainer.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		_menu.add_theme_constant_override("margin_" + side, 32)
	add_child(_menu)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	_menu.add_child(col)

	col.add_child(_label("RIFTGATE", 44, Palette.INK))
	col.add_child(_label("skirmish harness", 18, Palette.MUTED))
	col.add_child(HSeparator.new())

	col.add_child(_label("Team", 20, Palette.INK))
	var ids: Array = db.chassis.keys()
	ids.sort()
	for id in ids:
		var c: Dictionary = db.chassis[id]
		var cb := CheckBox.new()
		var fixed_n: int = c.get("fixed", []).size()
		cb.text = "%s   (%s, %d hardpoints%s, move %d)" % [c["name"], c.get("silhouette", ""), int(c["hardpoints"]), " + %d fixed" % fixed_n if fixed_n > 0 else "", int(c["movespeed"])]
		cb.add_theme_font_size_override("font_size", 18)
		cb.button_pressed = id in db.default_team()
		col.add_child(cb)
		_chassis_checks[id] = cb

	col.add_child(_label("Enemy packs in contact", 20, Palette.INK))
	var regular: Array = []
	var bosses: Array = []
	var fids: Array = db.foes.keys()
	fids.sort()
	for fid in fids:
		if int(db.foes[fid].get("size", 1)) > 1:
			bosses.append(fid)
		else:
			regular.append(fid)
	var row_a := HBoxContainer.new()
	row_a.add_theme_constant_override("separation", 12)
	col.add_child(row_a)
	var spawn_foes: Array = db.spawn_foes(db.default_faction())   # rank and file first, then the rest
	_foe_a = _foe_picker(regular, false)
	_foe_a.select(_index_of(_foe_a, str(spawn_foes[0]) if not spawn_foes.is_empty() else ""))
	row_a.add_child(_foe_a)
	_count_a = _spin("x", 1, 18, 6)
	row_a.add_child(_count_a)
	var row_b := HBoxContainer.new()
	row_b.add_theme_constant_override("separation", 12)
	col.add_child(row_b)
	_foe_b = _foe_picker(regular, true)
	_foe_b.select(_index_of(_foe_b, str(spawn_foes[spawn_foes.size() - 1]) if not spawn_foes.is_empty() else ""))
	row_b.add_child(_foe_b)
	_count_b = _spin("x", 1, 18, 2)
	row_b.add_child(_count_b)
	var row_c := HBoxContainer.new()
	row_c.add_theme_constant_override("separation", 12)
	col.add_child(row_c)
	_boss = _foe_picker(bosses, true)
	_boss.select(0)
	row_c.add_child(_boss)
	_seed = _spin("seed", 1, 9999, 7)
	row_c.add_child(_seed)

	col.add_child(_label("HUD colour", 20, Palette.INK))
	var swatches := HBoxContainer.new()
	swatches.add_theme_constant_override("separation", 12)
	col.add_child(swatches)
	for id in Settings.HUD_OPTIONS.keys():
		var b := HudButton.new(str(id).to_upper())
		b.color_override = Settings.HUD_OPTIONS[id]
		b.filled = Settings.hud == id
		b.custom_minimum_size = Vector2(0, 48)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func() -> void:
			Settings.set_hud(str(id))
			for other in swatches.get_children():
				other.filled = other == b
				other.queue_redraw())
		swatches.add_child(b)

	col.add_child(HSeparator.new())
	col.add_child(_button("Battle", _on_battle))
	if SaveGame.exists():
		col.add_child(_button("Resume battle", _on_resume))
	col.add_child(_button("Fight (skirmish only)", _on_fight))
	col.add_child(_button("Battlefield viewer", _on_map))
	col.add_child(_label("Tests: godot --headless --path . -s tests/run_tests.gd", 13, Palette.MUTED))


func _foe_picker(ids: Array, allow_none: bool) -> OptionButton:
	var ob := OptionButton.new()
	ob.add_theme_font_size_override("font_size", 18)
	ob.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if allow_none:
		ob.add_item("none")
		ob.set_item_metadata(ob.item_count - 1, "")
	for fid in ids:
		var f: Dictionary = db.foes[fid]
		ob.add_item("%s  (%s, %s rank)" % [f["name"], f.get("faction", ""), f.get("rank", "front")])
		ob.set_item_metadata(ob.item_count - 1, fid)
	return ob


func _index_of(ob: OptionButton, fid: String) -> int:
	for i in range(ob.item_count):
		if str(ob.get_item_metadata(i)) == fid:
			return i
	return 0


func _spin(prefix: String, lo: int, hi: int, val: int) -> SpinBox:
	var s := SpinBox.new()
	s.prefix = prefix + " "
	s.min_value = lo
	s.max_value = hi
	s.value = val
	s.add_theme_font_size_override("font_size", 18)
	s.custom_minimum_size = Vector2(150, 0)
	return s


func _label(text: String, size_px: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	return l


func _button(text: String, on_pressed: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 60)
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(on_pressed)
	return b


func _on_fight() -> void:
	var sk := Skirmish.new(int(_seed.value))   # the formation is always four wide (Ryan, 23 September)
	var uid := 1
	for id in _chassis_checks.keys():
		if _chassis_checks[id].button_pressed:
			sk.add_mech(db.make_mech(id, uid))
			uid += 1
	if sk.mechs.is_empty():
		return
	var packs: Array = []
	var fa := str(_foe_a.get_item_metadata(_foe_a.selected))
	if not fa.is_empty():
		packs.append([fa, int(_count_a.value)])
	var fb := str(_foe_b.get_item_metadata(_foe_b.selected))
	if not fb.is_empty():
		packs.append([fb, int(_count_b.value)])
	var sid := 90
	for s in packs:
		var fac := db.faction_of_foe(s[0])
		var sq := Unit.pack(sid, "%s pack" % str(db.foes[s[0]]["name"]).to_lower(), Vector2i.ZERO, fac, 2, s[1], s[0])
		sk.add_foes(db.foes_for(sq), sq)
		sid += 1
	var boss_id := str(_boss.get_item_metadata(_boss.selected))
	if not boss_id.is_empty():
		var boss := Unit.boss(sid, str(db.foes[boss_id]["name"]).to_lower(), Vector2i.ZERO, db.faction_of_foe(boss_id))
		sk.add_foes(db.foes_for(boss), boss)
	if sk.reinforcements.is_empty():
		return
	var screen: SkirmishScreen = SKIRMISH_SCENE.instantiate()
	screen.sk = sk
	screen.setup(sk)
	screen.back_requested.connect(_back)
	screen.quit_requested.connect(_back)
	_show(screen)


## A whole battle: the checked team against the faction of the first pack picker, on a map
## generated from the seed.
func _on_battle() -> void:
	var team: Array = []
	var uid := 1
	for id in _chassis_checks.keys():
		if _chassis_checks[id].button_pressed:
			team.append(db.make_mech(id, uid))
			uid += 1
	if team.is_empty():
		return
	var fa := str(_foe_a.get_item_metadata(_foe_a.selected))
	var fac := db.faction_of_foe(fa)
	if fac.is_empty() or not db.factions.has(fac):
		fac = db.default_faction()
	var b := Battle.new(int(_seed.value))
	b.setup(team, fac)
	_show_battle(b)


## The saved battle, where it stood (user://battle.json; the button shows while one exists).
func _on_resume() -> void:
	var b := SaveGame.load()
	if b == null:
		return
	_show_battle(b)


func _show_battle(b: Battle) -> void:
	var screen: BattleScreen = BATTLE_SCENE.instantiate()
	screen.battle = b   # built in its _ready, once, at the screen's real height
	screen.autosave_enabled = true   # a real battle is kept where it stands; standalone runs and tests never write it
	screen.back_requested.connect(_back)
	screen.quit_requested.connect(_back)
	_show(screen)


func _on_map() -> void:
	var m := MAP_SCENE.instantiate()
	_show(m)


func _show(node: Node) -> void:
	if OS.has_feature("web"):
		# On a phone's browser (tools/phone.sh) the button press is the gesture that lets
		# the page go full screen, so the address bar leaves and the height is real.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_menu.visible = false
	_current = node
	add_child(node)


func _back() -> void:
	Sound.music("")
	if _current != null:
		_current.queue_free()
		_current = null
	_menu.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _current != null:
		_back()

extends Control

## Debug harness and main scene. Pick a team, a faction, a squad size, and a seed, then fight.
## Also opens the battlefield map viewer.

const SKIRMISH_SCENE := preload("res://game/skirmish/skirmish_screen.tscn")
const MAP_SCENE := preload("res://game/main.tscn")

var db: ContentDB
var _chassis_checks: Dictionary = {}   # id -> CheckBox
var _faction: OptionButton
var _strength: SpinBox
var _seed: SpinBox
var _elite: CheckBox
var _menu: Control
var _current: Node = null


func _ready() -> void:
	db = ContentDB.load_default()
	_build_menu()


func _build_menu() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_menu = MarginContainer.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		_menu.add_theme_constant_override("margin_" + side, 32)
	add_child(_menu)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
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
		cb.text = "%s   (%s, %d hardpoints, move %d)" % [c["name"], c.get("silhouette", ""), int(c["hardpoints"]), int(c["movespeed"])]
		cb.add_theme_font_size_override("font_size", 18)
		cb.button_pressed = id in ["bulwark", "sentinel", "raptor"]
		col.add_child(cb)
		_chassis_checks[id] = cb

	col.add_child(_label("Enemy", 20, Palette.INK))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	col.add_child(row)
	_faction = OptionButton.new()
	_faction.add_theme_font_size_override("font_size", 18)
	var fids: Array = db.factions.keys()
	fids.sort()
	for fid in fids:
		_faction.add_item("%s  (%s)" % [db.factions[fid]["name"], fid])
		_faction.set_item_metadata(_faction.item_count - 1, fid)
	_faction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_faction)
	_strength = _spin("squad", 2, 18, 8)
	row.add_child(_strength)
	_seed = _spin("seed", 1, 9999, 7)
	row.add_child(_seed)
	_elite = CheckBox.new()
	_elite.text = "Bring the faction's massive elite"
	_elite.add_theme_font_size_override("font_size", 18)
	col.add_child(_elite)

	col.add_child(HSeparator.new())
	var fight := _button("Fight", _on_fight)
	col.add_child(fight)
	var map := _button("Battlefield viewer", _on_map)
	col.add_child(map)
	col.add_child(_label("Tests: godot --headless --path . -s tests/run_tests.gd", 13, Palette.MUTED))


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
	var sk := Skirmish.new(int(_seed.value))
	var uid := 1
	for id in _chassis_checks.keys():
		if _chassis_checks[id].button_pressed:
			sk.add_mech(db.make_mech(id, uid))
			uid += 1
	if sk.mechs.is_empty():
		return
	var fid := str(_faction.get_item_metadata(_faction.selected))
	var sq := Unit.squad(99, "%s squad" % fid, Vector2i.ZERO, fid, 2, int(_strength.value))
	sq.elite = _elite.button_pressed
	sk.add_foes(db.foes_for(sq), sq)
	var screen: SkirmishScreen = SKIRMISH_SCENE.instantiate()
	screen.sk = sk
	screen.setup(sk)
	screen.back_requested.connect(_back)
	_show(screen)


func _on_map() -> void:
	var m := MAP_SCENE.instantiate()
	_show(m)


func _show(node: Node) -> void:
	_menu.visible = false
	_current = node
	add_child(node)


func _back() -> void:
	if _current != null:
		_current.queue_free()
		_current = null
	_menu.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _current != null:
		_back()

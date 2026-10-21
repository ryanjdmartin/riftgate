extends Control

## Debug harness and main scene. Three tabs over launch buttons that stay put however long a
## tab runs (8 October: one long column had run off the glass): TEAM, who deploys and each
## machine's hardpoints; ENEMY, the packs, the boss and a guest faction, loaded from a
## faction's spawn list and edited from there; SETUP, the seed, the map's type and the HUD
## colour. Battle plays the whole loop with that side as its formation and its rift's cycle,
## Fight chains it all into one skirmish. The choices are a HarnessSetup, kept between
## launches in user://harness.json.

const SKIRMISH_SCENE := preload("res://game/skirmish/skirmish_screen.tscn")
const BATTLE_SCENE := preload("res://game/battle/battle_screen.tscn")
const MAP_SCENE := preload("res://game/main.tscn")
const TABS := ["TEAM", "ENEMY", "SETUP"]
const ROW_H := 48.0

var db: ContentDB
var setup: HarnessSetup
var _menu: Control
var _current: Node = null
var _tabs: Array = []          # HudButton per tab
var _pages: Array = []         # ScrollContainer per tab
var _tab := 0
var _rows: Dictionary = {}     # chassis id -> {"check", "toggle", "status", "editor"}
var _open: String = ""         # the chassis whose hardpoints are open, "" for none
var _packs_box: VBoxContainer
var _boss: OptionButton
var _guest: OptionButton
var _seed_edit: LineEdit
var _kind: OptionButton
var _summary: Label
var _battle_btn: Button
var _fight_btn: Button
var _resume_btn: Button


func _ready() -> void:
	Settings.apply()
	Hud.oversample(get_window())   # text rasterised at the glass's density, not the design's
	build(HarnessSetup.load_or_default())


## Build the menu over a setup (the tests call this out of the tree, with their own).
func build(s: HarnessSetup) -> void:
	setup = s
	db = s.db
	for c in get_children():
		c.queue_free()
	_rows = {}
	_tabs = []
	_pages = []
	_open = ""
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

	# The launch buttons sit at the bottom of the glass, so they keep its safe band clear.
	var ins := Hud.safe_insets(self)
	_menu = MarginContainer.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu.add_theme_constant_override("margin_left", 24)
	_menu.add_theme_constant_override("margin_right", 24)
	_menu.add_theme_constant_override("margin_top", 20 + int(ins.x))
	_menu.add_theme_constant_override("margin_bottom", 20 + int(ins.y))
	add_child(_menu)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	_menu.add_child(col)

	var head := HBoxContainer.new()
	head.add_child(_label("RIFTGATE", 36, Palette.INK))
	var sub := _label("harness", 18, Palette.MUTED)
	sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sub.size_flags_vertical = Control.SIZE_SHRINK_END
	head.add_child(sub)
	col.add_child(head)

	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	col.add_child(bar)
	for i in range(TABS.size()):
		var b := HudButton.new(TABS[i], _select_tab.bind(i))
		b.custom_minimum_size = Vector2(0, 52)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.add_child(b)
		_tabs.append(b)

	for builder in [_build_team, _build_enemy, _build_setup]:
		var scroll := ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.scroll_deadzone = 16   # a finger's tap on a picker is not a scroll
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var page := VBoxContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.add_theme_constant_override("separation", 10)
		scroll.add_child(page)
		col.add_child(scroll)
		_pages.append(scroll)
		builder.call(page)

	col.add_child(HSeparator.new())
	_summary = _label("", 15, Palette.MUTED)
	_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_summary)
	var launch := HBoxContainer.new()
	launch.add_theme_constant_override("separation", 12)
	col.add_child(launch)
	_battle_btn = _button("Battle", _on_battle, 64, 22)
	launch.add_child(_battle_btn)
	_fight_btn = _button("Fight", _on_fight, 64, 22)
	launch.add_child(_fight_btn)
	var more := HBoxContainer.new()
	more.add_theme_constant_override("separation", 12)
	col.add_child(more)
	_resume_btn = _button("Resume battle", _on_resume, 52, 18)
	_resume_btn.visible = SaveGame.exists()
	more.add_child(_resume_btn)
	more.add_child(_button("Battlefield viewer", _on_map, 52, 18))

	_select_tab(_tab)
	_refresh_summary()


func _select_tab(i: int) -> void:
	_tab = i
	for k in range(_pages.size()):
		_pages[k].visible = k == i
		_tabs[k].filled = k == i
		_tabs[k].queue_redraw()


# ---------------------------------------------------------------- team

func _build_team(page: VBoxContainer) -> void:
	page.add_child(_hint("Tick who deploys; they go out in the order ticked. HARDPOINTS opens a machine's loadout and its module slots, and the battle and the fight both carry them."))
	var ids: Array = db.chassis.keys()
	ids.sort_custom(func(a, b) -> bool: return str(db.chassis[a]["name"]) < str(db.chassis[b]["name"]))
	for id in ids:
		page.add_child(HSeparator.new())
		page.add_child(_chassis_row(str(id)))


func _chassis_row(id: String) -> VBoxContainer:
	var c: Dictionary = db.chassis[id]
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	box.add_child(top)
	var cb := CheckBox.new()
	cb.text = str(c["name"])
	cb.add_theme_font_size_override("font_size", 20)
	for state in ["font_color", "font_hover_color", "font_focus_color"]:
		cb.add_theme_color_override(state, Palette.MUTED)   # the ticked ones read first, by the tick and the ink
	for state in ["font_pressed_color", "font_hover_pressed_color"]:
		cb.add_theme_color_override(state, Palette.INK)
	cb.custom_minimum_size = Vector2(0, ROW_H)
	cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cb.button_pressed = setup.team.has(id)
	cb.toggled.connect(_on_team_toggled.bind(id))
	top.add_child(cb)
	var toggle := _button("HARDPOINTS", _toggle_loadout.bind(id), ROW_H, 16)
	toggle.size_flags_horizontal = Control.SIZE_SHRINK_END
	toggle.custom_minimum_size.x = 170
	top.add_child(toggle)
	var fixed_n: int = c.get("fixed", []).size()
	var info := "%s · move %d · %d hardpoints%s · tier %d" % [" ".join(c.get("traits", [])), int(c["movespeed"]), int(c["hardpoints"]), " + %d fixed" % fixed_n if fixed_n > 0 else "", db.chassis_tier(id)]
	box.add_child(_hint(info))
	var status := _label("", 15, Palette.INK)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status)
	var editor := VBoxContainer.new()
	editor.add_theme_constant_override("separation", 6)
	editor.visible = false
	box.add_child(editor)
	_rows[id] = {"box": box, "check": cb, "toggle": toggle, "status": status, "editor": editor}
	_refresh_row(id)
	return box


func _on_team_toggled(on: bool, id: String) -> void:
	if on and not setup.team.has(id):
		setup.team.append(id)
	elif not on:
		setup.team.erase(id)
	_refresh_summary()


## One line under a machine: its kit in hardpoint order. A refit says so in words and in the
## HUD colour, never the colour alone.
func _refresh_row(id: String) -> void:
	var row: Dictionary = _rows[id]
	var names: Array = []
	for cid in setup.picks(id):
		names.append("—" if str(cid).is_empty() else db.component_name(str(cid)))
	var mods: Array = []
	for mid in setup.fitted_modules(id):
		mods.append(db.module_name(str(mid)))
	var refit := setup.is_refit(id) or not mods.is_empty()
	var status: Label = row["status"]
	status.text = ("REFIT  " if refit else "stock  ") + (", ".join(names) if not names.is_empty() else "no hardpoints") + ("  ·  modules: " + ", ".join(mods) if not mods.is_empty() else "")
	status.add_theme_color_override("font_color", Palette.HUD if refit else Palette.MUTED)
	(row["toggle"] as Button).text = "CLOSE" if _open == id else "HARDPOINTS"


func _toggle_loadout(id: String) -> void:
	var was := _open
	_open = "" if _open == id else id
	if not was.is_empty() and _rows.has(was):
		_close_editor(was)
	if not _open.is_empty():
		_fill_editor(_open)
		_scroll_to(_open)
	_refresh_row(id)


## Bring an opened machine to the top of the page once its editor has its height.
func _scroll_to(id: String) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if _rows.has(id) and is_instance_valid(_rows[id]["box"]):
		(_pages[0] as ScrollContainer).scroll_vertical = int((_rows[id]["box"] as Control).position.y)


func _close_editor(id: String) -> void:
	var editor: VBoxContainer = _rows[id]["editor"]
	for ch in editor.get_children():
		ch.queue_free()
	editor.visible = false
	_refresh_row(id)


## The hardpoint editor, built only while open: the fixed components as they are, then one
## picker per hardpoint, then stock and empty.
func _fill_editor(id: String) -> void:
	var editor: VBoxContainer = _rows[id]["editor"]
	for ch in editor.get_children():
		editor.remove_child(ch)
		ch.queue_free()
	editor.visible = true
	var c: Dictionary = db.chassis[id]
	var fixed: Array = []
	for cid in c.get("fixed", []):
		fixed.append(db.component_name(str(cid)))
	if not fixed.is_empty():
		editor.add_child(_hint("Fixed: " + ", ".join(fixed)))
	var p := setup.picks(id)
	for slot in range(p.size()):
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 10)
		var n := _label("HP %d" % (slot + 1), 16, Palette.MUTED)
		n.custom_minimum_size = Vector2(64, 0)
		line.add_child(n)
		var ob := _component_picker(str(p[slot]))
		ob.item_selected.connect(_on_pick.bind(ob, id, slot))
		line.add_child(ob)
		editor.add_child(line)
	var mp := setup.module_picks(id)
	for slot in range(mp.size()):
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 10)
		var n := _label("MOD %d" % (slot + 1), 16, Palette.MUTED)
		n.custom_minimum_size = Vector2(64, 0)
		line.add_child(n)
		var ob := _module_picker(str(mp[slot]))
		ob.item_selected.connect(_on_module_pick.bind(ob, id, slot))
		line.add_child(ob)
		editor.add_child(line)
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 12)
	tools.add_child(_button("Stock", func() -> void:
		setup.reset_loadout(id)
		setup.modules.erase(id)
		_fill_editor(id)
		_refresh_row(id)
		_refresh_summary(), ROW_H, 16))
	tools.add_child(_button("Empty all", func() -> void:
		for k in range(setup.picks(id).size()):
			setup.set_pick(id, k, "")
		_fill_editor(id)
		_refresh_row(id)
		_refresh_summary(), ROW_H, 16))
	editor.add_child(tools)


## Every component, grouped by maker; a built-in one (fixed on its chassis, stocked by no
## hardpoint) says so.
func _component_picker(selected: String) -> OptionButton:
	var ob := _picker()
	ob.add_item("— empty —")
	ob.set_item_metadata(0, "")
	var by_maker: Dictionary = {}
	for cid in db.components.keys():
		var m := str(db.components[cid].get("maker", ""))
		if not by_maker.has(m):
			by_maker[m] = []
		by_maker[m].append(str(cid))
	var order: Array = db.makers.keys()
	for m in by_maker.keys():
		if not order.has(m):
			order.append(m)
	for m in order:
		if not by_maker.has(m):
			continue
		ob.add_separator(str(db.makers.get(m, {}).get("name", m if not str(m).is_empty() else "other")))
		var list: Array = by_maker[m]
		list.sort_custom(func(a, b) -> bool: return db.component_name(a) < db.component_name(b))
		for cid in list:
			ob.add_item(db.component_name(cid) + ("  (built-in)" if db.component_tier(cid) == 0 else ""))
			ob.set_item_metadata(ob.item_count - 1, cid)
	ob.select(_index_of(ob, selected))
	return ob


## Every module, grouped by maker, with its tier and what it does on one line.
func _module_picker(selected: String) -> OptionButton:
	var ob := _picker()
	ob.add_item("— no module —")
	ob.set_item_metadata(0, "")
	for m in db.makers.keys():
		var list: Array = db.modules.keys().filter(func(mid) -> bool: return str(db.modules[mid].get("maker", "")) == str(m))
		if list.is_empty():
			continue
		ob.add_separator(str(db.makers[m].get("name", m)))
		list.sort_custom(func(a, b) -> bool: return db.module_name(a) < db.module_name(b))
		for mid in list:
			ob.add_item("%s  (T%d)  %s" % [db.module_name(mid), int(db.modules[mid].get("tier", 0)), db.module_description(mid)])
			ob.set_item_metadata(ob.item_count - 1, str(mid))
	ob.select(_index_of(ob, selected))
	return ob


func _on_module_pick(index: int, ob: OptionButton, id: String, slot: int) -> void:
	setup.set_module(id, slot, str(ob.get_item_metadata(index)))
	_refresh_row(id)
	_refresh_summary()


func _on_pick(index: int, ob: OptionButton, id: String, slot: int) -> void:
	setup.set_pick(id, slot, str(ob.get_item_metadata(index)))
	_refresh_row(id)
	_refresh_summary()


# ---------------------------------------------------------------- enemy

func _build_enemy(page: VBoxContainer) -> void:
	page.add_child(_section("From a faction"))
	page.add_child(_hint("Loads its spawn list and its boss; edit from there."))
	var facs := HBoxContainer.new()
	facs.add_theme_constant_override("separation", 10)
	page.add_child(facs)
	for fid in db.factions.keys():
		var b := _button(str(db.factions[fid].get("name", fid)), func() -> void:
			setup.use_faction(str(fid))
			_fill_packs()
			_boss.select(_index_of(_boss, setup.boss))
			_refresh_summary(), ROW_H, 16)
		b.clip_text = true
		facs.add_child(b)

	page.add_child(_section("Packs"))
	page.add_child(_hint("A battle places them at the start and the rift sends them in turn; a fight chains them all with the boss."))
	_packs_box = VBoxContainer.new()
	_packs_box.add_theme_constant_override("separation", 8)
	page.add_child(_packs_box)
	_fill_packs()
	var add := _button("+ Add pack", _on_add_pack, ROW_H, 18)
	page.add_child(add)

	page.add_child(_section("Boss"))
	_boss = _picker()
	_boss.add_item("none")
	_boss.set_item_metadata(0, "")
	for bid in setup.bosses():
		_boss.add_item("%s  (%s)" % [db.foes[bid]["name"], db.faction_of_foe(bid)])
		_boss.set_item_metadata(_boss.item_count - 1, bid)
	_boss.select(_index_of(_boss, setup.boss))
	_boss.item_selected.connect(func(i: int) -> void:
		setup.boss = str(_boss.get_item_metadata(i))
		_refresh_summary())
	page.add_child(_boss)
	page.add_child(_hint("The boss picks the faction a battle is fought against. None: the battle has no victory; leave it from the menu."))

	page.add_child(_section("Guest faction"))
	_guest = _picker()
	_guest.add_item("none")
	_guest.set_item_metadata(0, "")
	for fid in db.factions.keys():
		_guest.add_item(str(db.factions[fid].get("name", fid)))
		_guest.set_item_metadata(_guest.item_count - 1, str(fid))
	_guest.select(_index_of(_guest, setup.guest))
	_guest.item_selected.connect(func(i: int) -> void:
		setup.guest = str(_guest.get_item_metadata(i))
		_refresh_summary())
	page.add_child(_guest)
	page.add_child(_hint("Battle only: its spawn list joins the rift's cycle, alternating with the packs above."))


## One row per pack: its foe, its strength, and a remove.
func _fill_packs() -> void:
	for ch in _packs_box.get_children():
		_packs_box.remove_child(ch)
		ch.queue_free()
	var foes := setup.pack_foes()
	for i in range(setup.packs.size()):
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		var ob := _picker()
		for fid in foes:
			var f: Dictionary = db.foes[fid]
			# A promoted form shares its hero's name (Ryan, 21 October), so the picker says which.
			ob.add_item("%s  (%s, %s)" % [f["name"], f.get("faction", ""), "promoted" if f.has("promotes") else f.get("rank", "front")])
			ob.set_item_metadata(ob.item_count - 1, fid)
		ob.select(_index_of(ob, str(setup.packs[i][0])))
		ob.item_selected.connect(func(k: int) -> void:
			setup.packs[i][0] = str(ob.get_item_metadata(k))
			_refresh_summary())
		line.add_child(ob)
		line.add_child(_stepper(int(setup.packs[i][1]), 1, HarnessSetup.MAX_STRENGTH, func(v: int) -> void:
			setup.packs[i][1] = v
			_refresh_summary(), "x"))
		var rm := _button("✕", func() -> void:
			setup.packs.remove_at(i)
			_fill_packs()
			_refresh_summary(), ROW_H, 18)
		rm.custom_minimum_size.x = ROW_H
		rm.size_flags_horizontal = Control.SIZE_SHRINK_END
		line.add_child(rm)
		_packs_box.add_child(line)
	if setup.packs.is_empty():
		_packs_box.add_child(_hint("No packs: a fight takes the boss alone; a battle needs one."))


func _on_add_pack() -> void:
	var foes := setup.pack_foes()
	if foes.is_empty():
		return
	var fid := str(setup.packs[setup.packs.size() - 1][0]) if not setup.packs.is_empty() else str(foes[0])
	setup.packs.append([fid, 4])
	_fill_packs()
	_refresh_summary()


# ---------------------------------------------------------------- setup

func _build_setup(page: VBoxContainer) -> void:
	page.add_child(_section("Seed"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	page.add_child(row)
	_seed_edit = LineEdit.new()
	_seed_edit.text = str(setup.seed_value)
	_seed_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	_seed_edit.add_theme_font_size_override("font_size", 20)
	_seed_edit.custom_minimum_size = Vector2(0, ROW_H)
	_seed_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_seed_edit.text_changed.connect(func(t: String) -> void:
		if t.is_valid_int():
			setup.seed_value = clampi(int(t), 1, HarnessSetup.MAX_SEED)
			_refresh_summary())
	_seed_edit.text_submitted.connect(func(_t: String) -> void: _show_seed())
	_seed_edit.focus_exited.connect(_show_seed)
	row.add_child(_seed_edit)
	for step in [-1, 1]:
		var b := _button("−" if step < 0 else "+", func() -> void: _set_seed(setup.seed_value + step), ROW_H, 22)
		b.custom_minimum_size.x = ROW_H + 16
		b.size_flags_horizontal = Control.SIZE_SHRINK_END
		row.add_child(b)
	var rnd := _button("Random", func() -> void: _set_seed(randi_range(1, HarnessSetup.MAX_SEED)), ROW_H, 16)
	rnd.custom_minimum_size.x = 140
	rnd.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(rnd)
	page.add_child(_hint("The battle's map and every fight's dice come from it."))

	page.add_child(_section("Map type"))
	_kind = _picker()
	for k in BattleMap.KINDS.keys():
		_kind.add_item(str(BattleMap.KINDS[k]["name"]).capitalize())
		_kind.set_item_metadata(_kind.item_count - 1, k)
	_kind.select(_index_of(_kind, setup.map_kind))
	_kind.item_selected.connect(func(i: int) -> void:
		setup.map_kind = str(_kind.get_item_metadata(i))
		_refresh_summary())
	page.add_child(_kind)

	page.add_child(_section("HUD colour"))
	var swatches := HBoxContainer.new()
	swatches.add_theme_constant_override("separation", 12)
	page.add_child(swatches)
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
				other.queue_redraw()
			for t in _tabs:
				t.queue_redraw()
			for rid in _rows.keys():
				_refresh_row(rid))
		swatches.add_child(b)

	page.add_child(_section("Harness"))
	page.add_child(_button("Reset to defaults", func() -> void: build(HarnessSetup.defaults(db)), ROW_H, 18))
	page.add_child(_hint("The content's starting team in stock against its first faction. The harness keeps what was last launched."))
	page.add_child(_hint("Tests: godot --headless --path . -s tests/run_tests.gd"))


func _set_seed(v: int) -> void:
	setup.seed_value = clampi(v, 1, HarnessSetup.MAX_SEED)
	_show_seed()
	_refresh_summary()


func _show_seed() -> void:
	_seed_edit.text = str(setup.seed_value)


# ---------------------------------------------------------------- summary

## What the buttons will launch, in one place under every tab, and why one is greyed.
func _refresh_summary() -> void:
	var team: Array = []
	for id in setup.team:
		team.append(str(db.chassis[id]["name"]) + (" (refit)" if setup.is_refit(str(id)) or not setup.fitted_modules(str(id)).is_empty() else ""))
	var foes: Array = []
	for p in setup.packs:
		foes.append("%s ×%d" % [db.foes[p[0]]["name"], int(p[1])])
	if not setup.boss.is_empty():
		foes.append(str(db.foes[setup.boss]["name"]))
	var lines: Array = []
	lines.append(("TEAM  " + ", ".join(team)) if not team.is_empty() else "TEAM  none ticked")
	lines.append(("ENEMY  " + ", ".join(foes)) if not foes.is_empty() else "ENEMY  none")
	var extra := "SEED %d · %s" % [setup.seed_value, str(BattleMap.KINDS[setup.map_kind]["name"]).capitalize()]
	if not setup.guest.is_empty():
		extra += " · guest " + str(db.factions[setup.guest].get("name", setup.guest))
	lines.append(extra)
	_summary.text = "\n".join(lines)
	_battle_btn.disabled = setup.team.is_empty() or setup.packs.is_empty()
	_fight_btn.disabled = setup.team.is_empty() or (setup.packs.is_empty() and setup.boss.is_empty())


# ---------------------------------------------------------------- controls

func _picker() -> OptionButton:
	var ob := OptionButton.new()
	ob.add_theme_font_size_override("font_size", 18)
	ob.get_popup().add_theme_font_size_override("font_size", 20)
	ob.custom_minimum_size = Vector2(0, ROW_H)
	ob.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ob.clip_text = true
	ob.fit_to_longest_item = false
	return ob


func _index_of(ob: OptionButton, value: String) -> int:
	for i in range(ob.item_count):
		if not ob.is_item_separator(i) and str(ob.get_item_metadata(i)) == value:
			return i
	return 0


## A number with buttons a thumb can hit: − value +.
func _stepper(value: int, lo: int, hi: int, on_change: Callable, prefix: String = "") -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	var shown := _label("%s%d" % [prefix, value], 20, Palette.INK)
	shown.custom_minimum_size = Vector2(52, 0)
	shown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var v := [value]
	for step in [-1, 1]:
		var b := _button("−" if step < 0 else "+", func() -> void:
			var nv := clampi(int(v[0]) + step, lo, hi)
			if nv == int(v[0]):
				return
			v[0] = nv
			shown.text = "%s%d" % [prefix, nv]
			on_change.call(nv), ROW_H, 22)
		b.custom_minimum_size.x = ROW_H
		box.add_child(b)
		if step < 0:
			box.add_child(shown)
	return box


func _label(text: String, size_px: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	return l


func _section(text: String) -> Label:
	var l := _label(text, 20, Palette.INK)
	l.custom_minimum_size = Vector2(0, 34)
	l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return l


func _hint(text: String) -> Label:
	var l := _label(text, 15, Palette.MUTED)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _button(text: String, on_pressed: Callable, h: float = 60, size_px: int = 22) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, h)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", size_px)
	b.pressed.connect(on_pressed)
	return b


# ---------------------------------------------------------------- launching

func _on_fight() -> void:
	var sk := setup.make_skirmish()
	if sk == null:
		return
	setup.save()
	var screen: SkirmishScreen = SKIRMISH_SCENE.instantiate()
	screen.sk = sk
	screen.setup(sk)
	screen.back_requested.connect(_back)
	screen.quit_requested.connect(_back)
	_show(screen)


## A whole battle: the ticked team in its loadouts against the packs as the formation and
## the rift's cycle, on a map generated from the seed.
func _on_battle() -> void:
	var b := setup.make_battle()
	if b == null:
		return
	setup.save()
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
	_resume_btn.visible = SaveGame.exists()
	_menu.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _current != null:
		_back()

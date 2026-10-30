class_name QuickRunScreen
extends Control

## The quick campaign's screens (Ryan, 25 October; sim/quick_run.gd, the bible's quick campaign
## row): the draft, the hangar between battles (the game's first, trimmed: the squad, each
## machine's hardpoints and module slots fitted from the stores, no economy), the battle's track
## between its fights, the rewards when the boss falls, and the run's end. The fights are the
## skirmish screen's, without its withdrawal. Built in code, 720 wide like the other screens; the
## run saves after every change and resumes where it stood, a fight under way included.

signal back_requested   # LEAVE, or BACK at the run's end: the host goes back; the run stays saved
signal quit_requested   # QUIT from a fight's menu: the same

const SKIRMISH_SCENE := preload("res://game/skirmish/skirmish_screen.tscn")
const ROW := FaceListView.ROW
const SIDE_BTN := Vector2(112, 46)   # the hangar's FIT and SWAP beside a row: a thumb's target

var run: QuickRun = null
var autosave_enabled := false   # the harness turns it on; tests and standalone runs never write
var save_path: String = SaveGame.QUICK_PATH

var _db: ContentDB
var _title: Label
var _sub: Label
var _scroll: ScrollContainer
var _content: VBoxContainer
var _primary: HudButton
var _codex: CodexBox
var _chooser: Control = null
var _skirmish: SkirmishScreen = null
var _picked: Array = []    # the draft's picks, in order
var _choice := -1          # the reward card selected, -1 for none


## Build over a run out of the tree (the tests); in the tree `_ready` builds again at the
## glass's real height and safe bands.
func setup(r: QuickRun) -> void:
	run = r
	_build()


func _ready() -> void:
	Settings.apply()
	Hud.oversample(get_window())
	if run == null:
		run = QuickRun.new(1 + randi() % 99999)
	_build()
	if run.state == QuickRun.BATTLE and run.current != null:
		_enter_fight(run.current)   # a fight resumed from the save
	else:
		Sound.music("map")


# ---------------------------------------------------------------- the frame

func _build() -> void:
	for c in get_children():
		c.queue_free()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_db = run.db
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var ins := Hud.safe_insets(self)
	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 24)
	frame.add_theme_constant_override("margin_right", 24)
	frame.add_theme_constant_override("margin_top", 20 + int(ins.x))
	frame.add_theme_constant_override("margin_bottom", 20 + int(ins.y))
	add_child(frame)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	frame.add_child(col)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	col.add_child(head)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_theme_constant_override("separation", 2)
	head.add_child(titles)
	_title = Hud.label("", 32, Palette.INK, Hud.display_bold())
	titles.add_child(_title)
	_sub = Hud.label("", 15, Palette.HUD, Hud.mono())
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_sub)
	var leave := HudButton.new("LEAVE", func() -> void: back_requested.emit())
	leave.ghost = true
	leave.font_size = 18
	leave.custom_minimum_size = Vector2(120, 52)
	leave.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	leave.tooltip_text = "Back to the harness; the run is kept where it stands."
	head.add_child(leave)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.scroll_deadzone = 16   # a finger's tap on a card is not a scroll
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 14)
	_scroll.add_child(_content)
	_primary = HudButton.new("", _on_primary)
	_primary.filled = true
	_primary.font_size = 24
	_primary.custom_minimum_size = Vector2(0, 66)
	col.add_child(_primary)
	_codex = CodexBox.new()
	add_child(_codex)
	_refresh()


## Every view from the run as it stands.
func _refresh() -> void:
	_close_chooser()
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()
	_primary.badge = ""
	_primary.set_enabled(true)
	match run.state:
		QuickRun.DRAFT:
			_draft()
		QuickRun.HANGAR:
			_hangar()
		QuickRun.BATTLE:
			_between_fights()
		QuickRun.REWARDS:
			_rewards()
		_:
			_over()
	_scroll.scroll_vertical = 0


func _on_primary() -> void:
	match run.state:
		QuickRun.DRAFT:
			if run.choose(_picked):
				_picked = []
				_save()
				_refresh()
		QuickRun.HANGAR:
			if run.start_battle():
				_save()
				_refresh()
		QuickRun.BATTLE:
			var sk := run.open_fight()
			if sk != null:
				_save()
				_enter_fight(sk)
		QuickRun.REWARDS:
			if _choice >= 0 and run.take(_choice):
				_choice = -1
				_save()
				_refresh()
		_:
			if autosave_enabled:
				SaveGame.clear(save_path)
			back_requested.emit()


func _save() -> void:
	if not autosave_enabled:
		return
	if run.state == QuickRun.OVER:
		SaveGame.clear(save_path)
	else:
		SaveGame.save_quick(run, save_path)


# ---------------------------------------------------------------- the draft

func _draft() -> void:
	_title.text = "QUICK CAMPAIGN"
	_sub.text = "PICK THREE TIER-ONE MACHINES  %d/%d" % [_picked.size(), QuickRun.START_MACHINES]
	_content.add_child(_hint("%d battles, a tier every %d, then the finale. A battle is its fights back to back, then its boss; nothing mends until the boss falls. Then the loot, the boss's token and a maker's offer, and the hangar refits between battles. A fourth machine comes from an offer." % [QuickRun.BATTLES, QuickRun.TIER_EVERY]))
	for id in QuickRun.draft_choices(_db):
		var picked := _picked.has(id)
		var u := _db.make_mech(str(id))
		var card := _machine_panel(u, picked)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var pick := HudButton.new("PICKED" if picked else "PICK", _toggle_pick.bind(str(id)))
		pick.filled = picked
		pick.custom_minimum_size = Vector2(0, 52)
		pick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pick.set_enabled(picked or _picked.size() < QuickRun.START_MACHINES)
		row.add_child(pick)
		row.add_child(_codex_button(u))
		card.get_child(0).add_child(row)
		_content.add_child(card)
	_primary.text = "START"
	_primary.badge = "%d/%d" % [_picked.size(), QuickRun.START_MACHINES]
	_primary.set_enabled(_picked.size() == QuickRun.START_MACHINES)


func _toggle_pick(id: String) -> void:
	if _picked.has(id):
		_picked.erase(id)
	elif _picked.size() < QuickRun.START_MACHINES:
		_picked.append(id)
	var keep := _scroll.scroll_vertical
	_refresh()
	_scroll.set_deferred("scroll_vertical", keep)


# ---------------------------------------------------------------- the hangar

func _hangar() -> void:
	_title.text = "THE FINALE" if run.is_finale() else "BATTLE %d OF %d" % [run.battle, QuickRun.BATTLES]
	_sub.text = _battle_line() + "  ·  HANGAR"
	_content.add_child(_section("THE BATTLE AHEAD"))
	_content.add_child(_track(-1))
	_content.add_child(_section("THE SQUAD  %d/%d" % [run.squad.size(), QuickRun.SQUAD]))
	_content.add_child(_hint("Tap SWAP beside an entry to fit a piece from the stores (the basics are free), or a module. The squad is up to four, in the order they deploy."))
	for m in run.roster:
		_content.add_child(_hangar_card(m))
	_content.add_child(_section("THE STORES"))
	_content.add_child(_stores())
	_primary.text = "THE FINALE" if run.is_finale() else "INTO BATTLE %d" % run.battle
	_primary.set_enabled(not run.squad.is_empty())


func _battle_line() -> String:
	var line := "TIER %d  ·  %s" % [run.tier() + 1, _domain_name(run.lead)]
	if not run.guest.is_empty():
		line += "  ·  GUEST %s" % _domain_name(run.guest)
	return line


func _hangar_card(m: QuickRun.Machine) -> HudPanel:
	var u := _db.make_mech(m.chassis, m.uid, Vector2i.ZERO, m.loadout.duplicate(), m.modules.duplicate())
	var in_squad := run.squad.has(m.uid)
	var panel := HudPanel.new(16.0)
	if not in_squad:
		panel.border = Color(Palette.MUTED, 1.0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	box.add_child(head)
	var title := Hud.label(u.display_name.to_upper(), 26, Palette.INK if in_squad else Palette.MUTED, Hud.display_bold())
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var place := run.squad.find(m.uid)
	var toggle := HudButton.new(("SQUAD %s" % Hud.roman(place + 1)) if in_squad else "BENCH", _toggle_squad.bind(m.uid))
	toggle.filled = in_squad
	toggle.font_size = 18
	toggle.custom_minimum_size = Vector2(150, 48)
	toggle.set_enabled((in_squad and run.squad.size() > 1) or (not in_squad and run.squad.size() < QuickRun.SQUAD))
	head.add_child(toggle)
	head.add_child(_codex_button(u))
	box.add_child(Hud.label(_plate(m.chassis), 14, Palette.MUTED, Hud.mono()))
	# The die, an entry a row; a hardpoint row carries FIT or SWAP.
	var fixed_n: int = _db.chassis[m.chassis].get("fixed", []).size()
	var faces: Array = u.die.faces
	var rows := HBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	box.add_child(rows)
	var list := _face_list(faces, _labels(faces))
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_child(list)
	var side := VBoxContainer.new()
	side.add_theme_constant_override("separation", 0)
	rows.add_child(side)
	for i in range(faces.size()):
		var cell := Control.new()
		cell.custom_minimum_size = Vector2(SIDE_BTN.x, ROW)
		side.add_child(cell)
		if i < fixed_n:
			continue
		var slot := mini(i - fixed_n, m.loadout.size())
		var empty: bool = faces[i].empty
		var b := HudButton.new("FIT" if empty else "SWAP", _open_hardpoint.bind(m.uid, slot, i))
		b.font_size = 17
		b.ghost = not empty
		b.position = Vector2(0, (ROW - SIDE_BTN.y) * 0.5)
		b.size = SIDE_BTN
		cell.add_child(b)
	# The module slots.
	for slot in range(run.module_slots(m)):
		var mrow := HBoxContainer.new()
		mrow.add_theme_constant_override("separation", 8)
		box.add_child(mrow)
		var fitted := slot < m.modules.size()
		var text := "MODULE %s  ·  %s" % [Hud.roman(slot + 1), ("%s: %s" % [_db.module_name(str(m.modules[slot])), _db.module_description(str(m.modules[slot]))]) if fitted else "EMPTY"]
		var l := Hud.label(text, 17, Palette.INK if fitted else Palette.MUTED)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.custom_minimum_size = Vector2(0, SIDE_BTN.y)
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		mrow.add_child(l)
		var b := HudButton.new("SWAP" if fitted else "FIT", _open_module.bind(m.uid, slot))
		b.font_size = 17
		b.ghost = fitted
		b.custom_minimum_size = SIDE_BTN
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mrow.add_child(b)
	return panel


func _toggle_squad(uid: int) -> void:
	var s: Array = run.squad.duplicate()
	if s.has(uid):
		s.erase(uid)
	else:
		s.append(uid)
	if run.set_squad(s):
		_save()
	var keep := _scroll.scroll_vertical
	_refresh()
	_scroll.set_deferred("scroll_vertical", keep)


func _stores() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var ids: Array = run.components.keys()
	ids.sort_custom(func(a, b) -> bool: return _db.component_tier(a) > _db.component_tier(b) or (_db.component_tier(a) == _db.component_tier(b) and _db.component_name(a) < _db.component_name(b)))
	if ids.is_empty() and run.modules.is_empty():
		box.add_child(_hint("Nothing yet: the loot, the token and the offer come when a boss falls. The eight basics are always free."))
		return box
	var faces: Array = []
	var labels: Array = []
	for cid in ids:
		faces.append(_face_of(str(cid)))
		labels.append("%s  ·  T%d  ·  ×%d" % [_db.component_name(str(cid)).to_upper(), _db.component_tier(str(cid)), int(run.components[cid])])
	if not faces.is_empty():
		box.add_child(_face_list(faces, labels, false))
	for mid in run.modules.keys():
		var l := Hud.label("%s  ·  T%d  ·  ×%d  —  %s" % [_db.module_name(str(mid)).to_upper(), int(_db.modules[mid].get("tier", 0)), int(run.modules[mid]), _db.module_description(str(mid))], 17, Palette.INK)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(l)
	return box


# ---------------------------------------------------------------- the chooser

## The pieces a hardpoint may take: the stores' (best first), then the basics, free; LEAVE
## EMPTY when it holds one.
func _open_hardpoint(uid: int, slot: int, entry: int) -> void:
	var m := run.machine(uid)
	var options: Array = []   # [label, Face or null, the id to fit]
	if slot < m.loadout.size():
		options.append(["LEAVE EMPTY", null, ""])
	var ids: Array = run.components.keys()
	ids.sort_custom(func(a, b) -> bool: return _db.component_tier(a) > _db.component_tier(b) or (_db.component_tier(a) == _db.component_tier(b) and _db.component_name(a) < _db.component_name(b)))
	for cid in ids:
		options.append(["%s  ·  T%d  ·  ×%d" % [_db.component_name(str(cid)).to_upper(), _db.component_tier(str(cid)), int(run.components[cid])], _face_of(str(cid)), str(cid)])
	for cid in _db.starting_blueprints():
		options.append(["%s  ·  BASIC  ·  FREE" % _db.component_name(str(cid)).to_upper(), _face_of(str(cid)), str(cid)])
	_show_chooser("%s  ·  ENTRY %s" % [str(_db.chassis[m.chassis].get("name", m.chassis)).to_upper(), Hud.roman(entry + 1)], options,
		func(id: String) -> void: _fit(uid, slot, id))


func _fit(uid: int, slot: int, component_id: String) -> void:
	if run.fit(uid, slot, component_id):
		_save()
	var keep := _scroll.scroll_vertical
	_refresh()
	_scroll.set_deferred("scroll_vertical", keep)


func _open_module(uid: int, slot: int) -> void:
	var m := run.machine(uid)
	var options: Array = []
	if slot < m.modules.size():
		options.append(["LEAVE EMPTY", null, ""])
	for mid in run.modules.keys():
		options.append(["%s  ·  T%d  ·  ×%d  —  %s" % [_db.module_name(str(mid)).to_upper(), int(_db.modules[mid].get("tier", 0)), int(run.modules[mid]), _db.module_description(str(mid))], null, str(mid)])
	if options.is_empty():
		options.append(["NO MODULE IN THE STORES", null, "\u0001"])
	_show_chooser("%s  ·  MODULE %s" % [str(_db.chassis[m.chassis].get("name", m.chassis)).to_upper(), Hud.roman(slot + 1)], options,
		func(id: String) -> void: _fit_module(uid, slot, id))


func _fit_module(uid: int, slot: int, module_id: String) -> void:
	if module_id != "\u0001" and run.fit_module(uid, slot, module_id):
		_save()
	var keep := _scroll.scroll_vertical
	_refresh()
	_scroll.set_deferred("scroll_vertical", keep)


func _show_chooser(title: String, options: Array, on_pick: Callable) -> void:
	_close_chooser()
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.85)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	_chooser = shade
	var ins := Hud.safe_insets(self)
	var panel := HudPanel.new(18.0)
	panel.position = Vector2(20, 80 + ins.x)
	panel.size = Vector2(680, Hud.screen_height(self) - 160 - ins.x - ins.y)
	shade.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	col.add_child(Hud.label(title, 22, Palette.INK, Hud.display_bold()))
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.scroll_deadzone = 16
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	for opt in options:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		list.add_child(row)
		if opt[1] != null:
			var fl := _face_list([opt[1]], [opt[0]], false)
			fl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(fl)
		else:
			var l := Hud.label(str(opt[0]), 17, Palette.INK)
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			l.custom_minimum_size = Vector2(0, SIDE_BTN.y)
			l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row.add_child(l)
		if str(opt[2]) == "\u0001":
			continue
		var b := HudButton.new("FIT" if not str(opt[2]).is_empty() else "STRIP", on_pick.bind(str(opt[2])))
		b.font_size = 17
		b.custom_minimum_size = SIDE_BTN
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(b)
	var cancel := HudButton.new("CANCEL", _close_chooser)
	cancel.ghost = true
	cancel.custom_minimum_size = Vector2(0, 56)
	col.add_child(cancel)


func _close_chooser() -> void:
	if _chooser != null:
		_chooser.queue_free()
		_chooser = null


# ---------------------------------------------------------------- between fights

func _between_fights() -> void:
	_title.text = "THE FINALE" if run.is_finale() else "BATTLE %d OF %d" % [run.battle, QuickRun.BATTLES]
	var enc: Dictionary = run.encounters[run.fight]
	_sub.text = _battle_line() + "  ·  FIGHT %d OF %d" % [run.fight + 1, run.encounters.size()]
	_content.add_child(_section("THE BATTLE"))
	_content.add_child(_track(run.fight))
	_content.add_child(_section("THE SQUAD"))
	_content.add_child(_hint("Damage carries from fight to fight; each won fight gives back a field recharge of shield. Nothing else mends until the boss falls."))
	for u in run.units:
		_content.add_child(_squad_row(u))
	var kind := str(enc["kind"])
	_primary.text = "FIGHT THE LINE" if kind == "finale" else ("FIGHT THE BOSS" if kind == "boss" else ("FIGHT THE FINAL" if kind == "final" else "FIGHT"))


func _squad_row(u: Unit) -> Control:
	var row := _SquadRow.new()
	row.unit = u
	row.custom_minimum_size = Vector2(0, 58)
	return row


## A machine's hull and shield as the battle holds them, or WRECKED.
class _SquadRow extends Control:
	var unit: Unit

	func _draw() -> void:
		var wreck := unit.hull <= 0
		var ink := Palette.MUTED if wreck else Palette.INK
		draw_string(Hud.display_bold(), Vector2(0, 24), unit.display_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 250, 22, ink)
		if wreck:
			draw_string(Hud.mono(), Vector2(0, 48), "WRECKED: OUT UNTIL THE BOSS FALLS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.LOSS)
			draw_line(Vector2(0, 16), Vector2(250, 16), Palette.LOSS, 2.0)
			return
		var x := 260.0
		var w := size.x - x - 8.0
		Hud.gauge(self, Rect2(x, 6, w, 14), float(unit.hull) / float(maxi(1, unit.hull_max)), Palette.HULL)
		Hud.gauge(self, Rect2(x, 32, w, 14), float(unit.shield) / float(maxi(1, unit.shield_max)), Palette.SHIELD)
		draw_string(Hud.mono(), Vector2(0, 48), "HULL %d/%d  ·  SHIELD %d/%d" % [unit.hull, unit.hull_max, unit.shield, unit.shield_max], HORIZONTAL_ALIGNMENT_LEFT, 250, 13, Palette.MUTED)


## The battle's encounters, one a row: its place, its kind and whom it fields, WON for those
## done and NEXT for the one ahead (`done`: the fights won, -1 in the hangar).
func _track(done: int) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	for i in range(run.encounters.size()):
		var enc: Dictionary = run.encounters[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		box.add_child(row)
		var state := ""
		if done >= 0 and i < done:
			state = "WON"
		elif done >= 0 and i == done:
			state = "NEXT"
		var ink := Palette.MUTED if state == "WON" else Palette.INK
		var num := Hud.label(Hud.roman(i + 1), 18, Palette.MUTED, Hud.quote())
		num.custom_minimum_size = Vector2(44, 0)
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(num)
		var kind := Hud.label(str(enc["kind"]).to_upper(), 18, Palette.HUD if state != "WON" else Palette.MUTED, Hud.display_bold())
		kind.custom_minimum_size = Vector2(130, 0)
		row.add_child(kind)
		var who := Hud.label(_fielded(enc), 17, ink)
		who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		who.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(who)
		if not state.is_empty():
			var tag := HudButton.new(state)
			tag.filled = state == "NEXT"
			tag.mono = true
			tag.font_size = 13
			tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tag.custom_minimum_size = Vector2(72, 30)
			tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(tag)
	return box


## Whom an encounter fields, in words.
func _fielded(enc: Dictionary) -> String:
	var domain := _domain_name(str(enc["domain"]))
	var n := run.formation_foes(str(enc["domain"])).size()
	var escort := ContentDB.escort_at(run.tier())
	match str(enc["kind"]):
		"elite":
			return "%s LEADS %s'S FORMATION  ·  %d FOES" % [_foe_name(str(enc.get("foe", ""))), domain, n + 1]
		"boss":
			return "%s WITH %s'S FORMATION  ·  %d FOES" % [_foe_name(str(enc.get("foe", ""))), domain, n + 1 + escort]
		"final":
			return "%s'S FINAL: %s WITH ITS FORMATION  ·  %d FOES" % [domain, _foe_name(str(enc.get("foe", ""))), n + 1 + escort]
		"finale":
			return "THE PARTY'S LINE  ·  %d FOES" % (Array(enc.get("line", [])).size() + escort)
	return "%s'S FORMATION  ·  %d FOES" % [domain, n]


# ---------------------------------------------------------------- the rewards

func _rewards() -> void:
	var r: Dictionary = run.rewards[0]
	var loot_left := run.rewards.filter(func(x) -> bool: return x["kind"] == "loot").size()
	_title.text = "BATTLE %d WON" % run.battle
	match str(r["kind"]):
		"loot":
			_sub.text = "LOOT  ·  %d PICK%s LEFT, THEN THE TOKEN AND AN OFFER" % [loot_left, "" if loot_left == 1 else "S"]
		"token":
			_sub.text = "THE BOSS'S TOKEN  ·  ONE COMPONENT OF TIER %d" % (run.tier() + 1)
		_:
			_sub.text = "%s'S OFFER  ·  ONE TAKEN, FREE" % str(_db.makers.get(str(r.get("maker", "")), {}).get("name", r.get("maker", ""))).to_upper()
	if not run.history.is_empty() and str(r["kind"]) == "loot" and loot_left == run.encounters.size() - 1:
		var h: Dictionary = run.history[run.history.size() - 1]
		var lost: Array = h.get("lost", [])
		var line := "Hull mended."
		if not lost.is_empty():
			line += " Gone for good: %s." % ", ".join(lost.map(func(c) -> String: return _db.component_name(str(c))))
		_content.add_child(_hint(line))
	var choices: Array = r["choices"]
	for i in range(choices.size()):
		_content.add_child(_reward_card(choices[i], i))
	_primary.text = "TAKE"
	_primary.set_enabled(_choice >= 0 and _choice < choices.size())


func _reward_card(item: Dictionary, index: int) -> Control:
	var chosen := index == _choice
	var id := str(item["id"])
	var panel := HudPanel.new(16.0)
	if not chosen:
		panel.border = Color(Palette.HUD, 0.45)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	box.add_child(head)
	var kind := str(item["kind"])
	var tier := 0
	var maker := ""
	var called := ""
	match kind:
		"component":
			tier = _db.component_tier(id)
			maker = str(_db.components[id].get("maker", ""))
			called = _db.component_name(id)
		"module":
			tier = int(_db.modules[id].get("tier", 0))
			maker = str(_db.modules[id].get("maker", ""))
			called = _db.module_name(id)
		_:
			tier = _db.chassis_tier(id)
			maker = str(_db.chassis[id].get("maker", ""))
			called = str(_db.chassis[id].get("name", id))
	var title := Hud.label(called.to_upper(), 26, Palette.INK, Hud.display_bold())
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var pick := HudButton.new("CHOSEN" if chosen else "CHOOSE", _select_reward.bind(index))
	pick.filled = chosen
	pick.font_size = 18
	pick.custom_minimum_size = Vector2(150, 48)
	head.add_child(pick)
	box.add_child(Hud.label("%s  ·  TIER %d  ·  %s" % [kind.to_upper(), tier, str(_db.makers.get(maker, {}).get("name", maker)).to_upper()], 14, Palette.MUTED, Hud.mono()))
	match kind:
		"component":
			box.add_child(_face_list([_face_of(id)], [""], false))
		"module":
			var l := Hud.label(_db.module_description(id), 18, Palette.INK)
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			box.add_child(l)
		_:
			var u := _db.make_mech(id)
			box.add_child(Hud.label(_plate(id), 14, Palette.MUTED, Hud.mono()))
			if not u.passive.is_empty():
				var pl := Hud.label("%s: %s" % [str(u.passive.get("name", "")).to_upper(), str(u.passive.get("description", ""))], 17, Palette.ACCENT)
				pl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				box.add_child(pl)
			box.add_child(_face_list(u.die.faces, _labels(u.die.faces)))
			box.add_child(_codex_button(u))
	return panel


func _select_reward(index: int) -> void:
	_choice = index
	var keep := _scroll.scroll_vertical
	_refresh()
	_scroll.set_deferred("scroll_vertical", keep)


# ---------------------------------------------------------------- the end

func _over() -> void:
	_title.text = "RUN WON" if run.won else "RUN LOST"
	var won := run.history.filter(func(h) -> bool: return bool(h.get("won", false))).size()
	if run.won:
		_sub.text = "THE PARTY IS DOWN  ·  %d BATTLES WON" % won
		_content.add_child(_hint("Every battle and the finale won, the party's line broken."))
	else:
		var at := run.lost_at
		_sub.text = "BATTLE %d  ·  FIGHT %d  ·  %d BATTLES WON" % [int(at.get("battle", 0)), int(at.get("fight", 0)) + 1, won]
		_content.add_child(_hint("Every machine wrecked in battle %d's %s fight, against %s." % [int(at.get("battle", 0)), str(at.get("kind", "")),
			str(_db.factions.get(str(at.get("domain", "")), {}).get("name", at.get("domain", "")))]))
	_primary.text = "BACK"


# ---------------------------------------------------------------- a fight

func _enter_fight(sk: Skirmish) -> void:
	var screen: SkirmishScreen = SKIRMISH_SCENE.instantiate()
	screen.sk = sk
	screen.back_label = "BACK TO THE RUN"
	var kind := str(run.encounters[run.fight]["kind"]) if run.fight < run.encounters.size() else ""
	if kind == "boss" or kind == "final" or kind == "finale":
		var bs := Sound.boss_set(run.lead)
		if not bs.is_empty():
			Sound.music(bs, true)
			screen.music_set = bs
	screen.setup(sk)
	screen.back_requested.connect(_on_fight_back)
	screen.quit_requested.connect(func() -> void: quit_requested.emit())
	screen.autosave = _save
	_skirmish = screen
	add_child(screen)


## The fight's BACK: the run takes the result, then the next view.
func _on_fight_back() -> void:
	if _skirmish != null:
		_skirmish.queue_free()
		_skirmish = null
	run.finish_fight()
	_save()
	Sound.music("map")
	_refresh()


# ---------------------------------------------------------------- pieces

func _machine_panel(u: Unit, picked: bool) -> HudPanel:
	var panel := HudPanel.new(16.0)
	if not picked:
		panel.border = Color(Palette.HUD, 0.45)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(Hud.label(u.display_name.to_upper(), 26, Palette.INK, Hud.display_bold()))
	box.add_child(Hud.label(_plate(u.chassis_id), 14, Palette.MUTED, Hud.mono()))
	if not u.passive.is_empty():
		var pl := Hud.label("%s: %s" % [str(u.passive.get("name", "")).to_upper(), str(u.passive.get("description", ""))], 17, Palette.ACCENT)
		pl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(pl)
	box.add_child(_face_list(u.die.faces, _labels(u.die.faces)))
	return panel


## A chassis's maker, size and numbers on one line.
func _plate(chassis_id: String) -> String:
	var c: Dictionary = _db.chassis.get(chassis_id, {})
	return "%s  ·  %s  ·  TIER %d  ·  HULL %d  ·  SHIELD %d" % [str(_db.makers.get(str(c.get("maker", "")), {}).get("name", c.get("maker", ""))).to_upper(),
		str(c.get("size", "")).to_upper(), int(c.get("tier", 0)), int(c.get("hull", 0)), int(c.get("shield", 0))]


func _codex_button(u: Unit) -> HudButton:
	var b := HudButton.new("CODEX", func() -> void: _codex.open(_db.codex_for_unit(u)))
	b.ghost = true
	b.font_size = 17
	b.custom_minimum_size = Vector2(120, 48)
	return b


## A list of die entries; `die` false for pieces that are no machine's die (no places shown).
func _face_list(faces: Array, labels: Array, die: bool = true) -> FaceListView:
	var fl := FaceListView.new()
	fl.labels = labels
	fl.numerals = die
	fl.custom_minimum_size = Vector2(0, ROW * faces.size())
	fl.set_faces(faces, -1)
	return fl


## A component as its entry on a die.
func _face_of(component_id: String) -> Face:
	return _db.build_die([], [component_id], 1).faces[0]


func _labels(faces: Array) -> Array:
	var out: Array = []
	for f in faces:
		out.append("" if f.empty else _db.component_name(f.component).to_upper() + ("  ·  BUILT IN" if f.fixed else ""))
	return out


func _domain_name(fid: String) -> String:
	return str(_db.factions.get(fid, {}).get("name", fid)).to_upper()


func _foe_name(fid: String) -> String:
	return str(_db.foes.get(fid, {}).get("name", fid)).to_upper()


func _section(text: String) -> Label:
	var l := Hud.label(text, 20, Palette.HUD, Hud.display_bold())
	l.custom_minimum_size = Vector2(0, 30)
	l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return l


func _hint(text: String) -> Label:
	var l := Hud.label(text, 17, Palette.MUTED)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _codex.is_open():
			_codex.close()
		elif _chooser != null:
			_close_chooser()
		else:
			return
		get_viewport().set_input_as_handled()

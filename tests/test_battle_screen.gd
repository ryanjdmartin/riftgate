extends TestCase

## Drives the battle screen through its handlers without a window: select, move, set up a
## fight and engage, the skirmish and back, a hunter's forced fight, the enemy's turn, and
## the outcome overlay (bible section 4, the round row).


func _screen(seed_value: int = 3) -> BattleScreen:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		team.append(db.make_mech(id))
	var b := Battle.new(seed_value)
	b.setup(team, "undead")
	var s := BattleScreen.new()
	s.setup(b)
	return s


## Park a pack beside a machine, rooted and pushing.
func _engage(b: Battle, sq: Unit, m: Unit) -> void:
	for n in Hex.neighbors(m.pos):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	sq.movespeed = 0
	if not sq.elite:
		sq.behaviour = "push"


func test_screen_builds_on_the_players_turn() -> void:
	var s := _screen()
	assert_true(s._header.text.begins_with("TURN 01"), "turn one in the header")
	assert_true(s._header.text.contains("NEXT SPAWN IN"), "and how long until the rift spawns")
	assert_true(s._sub_label.text.begins_with("READY // 3 OF 3"), "every machine ready")
	assert_false(s._resolve_btn.disabled, "the turn can end")
	assert_true(s._clear_btn.disabled, "nothing to undo yet")
	assert_true(s._map.field == s.battle.field, "map shows the field")
	assert_eq(s._map.walks.size(), s.battle.field.packs().size(), "every pack's walk on the map")
	assert_true(s._map.scroll_y <= 0.0, "scrolled to the gate end")
	s.free()


func test_a_tap_selects_and_a_lit_hex_moves_the_machine_at_once() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	var start := m.pos
	s._on_hex_tapped(m.pos)
	assert_eq(s._map.selected, m, "mech selected")
	assert_true(s._map.destinations.size() > 0, "destinations lit")
	var dest: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(dest)
	assert_eq(m.pos, dest, "it moved at once")
	assert_eq(s._map.selected, null, "and is let go")
	assert_false(s._clear_btn.disabled, "the move can be undone")
	s._on_undo()
	assert_eq(m.pos, start, "undo puts it back")
	assert_true(s._clear_btn.disabled, "and there is nothing more to undo")
	s.free()


func test_a_second_tap_lets_a_machine_go() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(m.pos)
	assert_eq(s._map.selected, null, "deselected")
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(s.battle.map.rift)
	assert_eq(s._map.selected, null, "a tap out of reach lets it go too")
	s.free()


func test_end_turn_walks_the_packs_and_opens_the_next_turn() -> void:
	var s := _screen()
	var sq: Unit = s.battle.field.packs()[0]
	var shown: Battlefield.Walk = s._map.walks[sq.id]
	s._on_end_turn()
	assert_eq(sq.pos, shown.end, "the pack walked where the map showed")
	assert_true(s._header.text.begins_with("TURN 02"), "next turn")
	assert_eq(s.battle.state, Battle.State.PLAN, "the player's turn again")
	assert_eq(s._skirmish, null, "no fight on its own")
	s.free()


func test_a_tap_on_a_pack_sets_up_the_fight_and_engage_opens_it() -> void:
	var s := _screen()
	var b := s.battle
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	s._refresh()
	s._on_hex_tapped(m.pos)   # the machine in hand is committed first
	s._on_hex_tapped(sq.pos)
	assert_true(s._contacts != null, "the fight's panel is up")
	assert_eq(s._committed, [m], "with the selected machine committed")
	assert_true(s._resolve_btn.disabled, "no ending the turn while a fight is set up")
	s._on_hex_tapped(m.pos)
	assert_true(s._committed.is_empty(), "a tap on it uncommits it")
	s._on_hex_tapped(m.pos)
	assert_eq(s._committed, [m], "and commits it again")
	s._engage()
	assert_eq(s._contacts, null, "the panel goes")
	assert_true(s._skirmish != null, "skirmish screen opened")
	assert_eq(s._sub_label.text, "FIGHT", "the readout says so")
	var sk: Skirmish = s._skirmish.sk
	assert_eq(sk.round, 1, "skirmish started")
	sk.reinforcements.clear()
	for f in sk.field_foes():
		f.hp = 0
	s._skirmish._end_turn_now()
	assert_true(s._skirmish._overlay.visible, "skirmish outcome shown")
	s._on_skirmish_back()
	assert_eq(s._skirmish, null, "skirmish screen gone")
	assert_false(b.field.units.has(sq), "pack wiped")
	assert_eq(b.state, Battle.State.PLAN, "back to the turn")
	assert_eq(b.actions_left(m), 0, "the machine is spent")
	assert_true(s._sub_label.text.contains("2 OF 3"), "the readout counts it out")
	s.free()


func test_a_pack_out_of_reach_shows_its_fight_but_nobody_to_send() -> void:
	var s := _screen()
	var sq: Unit = s.battle.field.packs()[0]
	s._on_hex_tapped(sq.pos)
	assert_true(s._contacts != null, "the panel shows who it is and who would join")
	assert_true(s._committed.is_empty(), "nobody in range")
	s._engage()
	assert_eq(s._skirmish, null, "so ENGAGE does nothing")
	s._on_hex_tapped(s.battle.map.rift)
	assert_eq(s._contacts, null, "a tap elsewhere puts it away")
	s.free()


func test_a_hunters_catch_is_fought_first_and_cannot_be_put_away() -> void:
	var s := _screen()
	var b := s.battle
	var m: Unit = b.mechs()[0]
	var hunter: Unit = b.field.packs()[0]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	hunter.zone = 1
	b._new_turn()
	s._after_step()
	assert_true(s._contacts != null, "the caught fight's panel is up")
	assert_eq(s._committed, [m], "its prey committed")
	assert_true(s._sub_label.text.begins_with("CAUGHT"), "the readout says so")
	s._on_hex_tapped(b.map.rift)
	assert_true(s._contacts != null, "it cannot be put away")
	s._on_end_turn()
	assert_eq(b.field.phase, 0, "nor the turn ended")
	s._engage()
	assert_true(s._skirmish != null, "it opens")
	s._skirmish.sk.reinforcements.clear()
	for f in s._skirmish.sk.field_foes():
		f.hp = 0
	s._skirmish._end_turn_now()
	s._on_skirmish_back()
	assert_true(b.forced.is_empty(), "fought")
	assert_eq(s._contacts, null, "no panel left")
	assert_false(s._resolve_btn.disabled, "the turn may end")
	s.free()


## The contact panel's portraits die with it (Ryan, 26 September: they hung off the screen
## root, and every contact and every tap of the panel's arrows left another pair of
## viewports rendering for the rest of the battle, until the phone's GL driver ran out
## of memory). A view counts as live unless it, or something above it, is on its way out.
func _live_portraits(s: BattleScreen) -> Array:
	var out: Array = []
	for v in s.find_children("*", "MechView3D", true, false):
		if s._skirmish != null and s._skirmish.is_ancestor_of(v):
			continue
		var n: Node = v
		var dying := false
		while n != null and n != s:
			if n.is_queued_for_deletion():
				dying = true
				break
			n = n.get_parent()
		if not dying:
			out.append(v)
	return out


func test_the_panels_portraits_die_with_it() -> void:
	var s := _screen()
	var b := s.battle
	_engage(b, b.field.packs()[0], b.mechs()[0])
	_engage(b, b.field.packs()[1], b.mechs()[1])
	s._refresh()
	s._on_hex_tapped(b.mechs()[0].pos)
	s._on_hex_tapped(b.field.packs()[0].pos)
	assert_true(s._contacts != null, "the panel is up")
	var before := _live_portraits(s)
	assert_true(before.size() > 0, "a portrait per machine committed")
	for v in before:
		assert_true(s._contacts.is_ancestor_of(v), "a portrait belongs to the panel")
	s._fill_attack_panel()
	s._fill_attack_panel()
	assert_eq(_live_portraits(s).size(), before.size(), "refilling replaces the portraits, never adds")
	s._close_attack()
	assert_eq(_live_portraits(s).size(), 0, "the panel gone, no portrait outlives it")
	s.free()


## The boss's fight plays the family's theme when there is one (Ryan, 25 September).
func test_the_boss_fight_plays_its_theme() -> void:
	var s := _screen()
	var b := s.battle
	_engage(b, b.boss, b.mechs()[0])
	s._refresh()
	s._on_hex_tapped(b.mechs()[0].pos)
	s._on_hex_tapped(b.boss.pos)
	s._engage()
	assert_true(b.boss_fight, "the boss's fight")
	assert_true(s._skirmish != null, "it opens")
	assert_eq(s._sub_label.text, "BOSS // FIGHT", "the readout says so")
	var want := Sound.boss_set(b.faction)
	assert_eq(s._skirmish.music_set, want if not want.is_empty() else "skirmish", "the fight plays the family's theme, or the skirmish's pick without one")
	s._on_skirmish_back()
	assert_false(b.boss_fight, "the flag drops on the way back")
	s.free()


func test_offscreen_packs_get_edge_tags() -> void:
	var s := _screen()
	var tags: Array = s._map.offscreen_tags()
	var hidden := 0
	for sq in s.battle.field.packs():
		if s._map.to_screen(s._map.center(sq.pos)).y < -BattleMapView.HEX_SIZE * 0.3:   # center is map space; tags are judged on screen
			hidden += 1
	assert_true(hidden >= 2, "most packs start off-screen at the gate end")
	assert_eq(tags.size(), hidden, "one tag per off-screen pack")
	for t in tags:
		var rect: Rect2 = t[0]
		assert_true(t[2], "tags sit at the top edge")
		assert_true(rect.position.x >= 0.0 and rect.end.x <= s._map.size.x, "tag inside the view")
	for i in range(1, tags.size()):
		assert_true(tags[i][0].position.x >= tags[i - 1][0].end.x, "tags do not overlap")
	var sq: Unit = s.battle.field.packs()[0]
	s._map.scroll_to_unit(sq)
	var still: Array = s._map.offscreen_tags()
	for t in still:
		assert_true(t[1] != sq, "the pack scrolled to has no tag")
	assert_true(BattleMapView.foe_sprite_id(s.battle.boss) == "bone_colossus", "boss uses the faction's boss art")
	s.free()


func test_hold_shows_a_readout() -> void:
	var s := _screen()
	s._on_unit_held(s.battle.mechs()[0])
	assert_true(s._details.visible, "readout shown")
	assert_true(s._details_label.text.contains("hull"), "mech numbers")
	assert_true(s._details_label.text.contains("action"), "and its actions")
	s._on_hold_released()
	assert_false(s._details.visible, "hidden on release")
	s._on_unit_held(s.battle.field.packs()[0])
	assert_true(s._details_label.text.contains("×"), "pack strength")
	assert_true(s._details_label.text.contains("ring"), "and its ring")
	s._on_unit_held(s.battle.boss)
	assert_true(s._details_label.text.contains("massive"), "boss readout")
	s.free()


func test_gate_falling_shows_the_outcome() -> void:
	var s := _screen()
	var b := s.battle
	b.field.gate_hp = 5
	var sq: Unit = b.field.packs()[0]
	load("res://tests/test_battle.gd").threaten_gate(b, sq)
	s._refresh()
	s._on_end_turn()
	assert_true(s._overlay.visible, "overlay shown")
	assert_eq(s._overlay_title.text, "GATE FALLEN", "title")
	assert_true(s._resolve_btn.disabled, "no more turns")
	s.free()


func test_double_tap_opens_the_codex_for_a_machine_and_a_pack() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	s._on_hex_double_tapped(m.pos)
	assert_true(s._codex.visible, "the codex opens for a machine")
	assert_true(s._codex._faces.visible, "with its die listed")
	s._codex.close()
	assert_false(s._codex.visible, "and closes")
	var sq: Unit = s.battle.field.packs()[0]
	s._on_hex_double_tapped(sq.pos)
	assert_true(s._codex.visible, "the codex opens for a pack")
	assert_eq(s._codex._title.text, sq.display_name, "headed by the pack")
	assert_true(s._codex._sub.text.contains("×%d" % sq.strength), "with its strength in the subtitle")
	assert_true(not s._codex._body.text.is_empty(), "and its foe type's codex text")
	s._codex.close()
	s.free()


func test_the_gate_is_selectable_and_has_an_entry() -> void:
	var s := _screen()
	var g: Vector2i = s.battle.field.map.gate
	s._on_hex_tapped(g)
	assert_true(s._map.gate_selected, "the gate is selected")
	assert_true(s._details.visible and s._details_label.text.contains("integrity"), "its integrity in the readout")
	s._on_hex_tapped(s.battle.mechs()[0].pos)
	assert_false(s._map.gate_selected, "another tap lets it go")
	s._on_hex_double_tapped(g)
	assert_true(s._codex.visible, "double-tap opens its entry")
	assert_eq(s._codex._title.text, "“The Gate”", "titled as the gate")
	s._codex.close()
	s.free()


func test_the_menu_opens_and_the_settings_persist() -> void:
	var s := _screen()
	s._open_menu()
	assert_true(s._menu.is_open(), "the menu opens")
	s._menu._show_page("settings")
	Settings.set_display("pace", 1.5)
	s._menu.display_changed.emit("pace", 1.5)
	assert_eq(BattleMapView.pace, 1.5, "the pace setting reaches the map")
	Settings._loaded = false
	Settings.display = Settings.DISPLAY_DEFAULTS.duplicate()
	Settings.apply()
	assert_eq(float(Settings.display["pace"]), 1.5, "and it comes back from the file")
	Settings.reset_display()
	BattleMapView.pace = 1.0
	s._menu.close()
	assert_false(s._menu.is_open(), "resume closes it")
	s.free()


func test_nothing_ends_or_moves_while_a_move_plays() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	s._map._anim_queue = [[]]   # a move in flight, as far as the screen knows
	assert_true(s._map.is_playing(), "the map is playing")
	var phase := s.battle.field.phase
	s._on_end_turn()
	assert_eq(s.battle.field.phase, phase, "End turn does nothing while the move plays")
	s._on_hex_tapped(m.pos)
	assert_eq(s._map.selected, null, "nor does a tap")
	s._refresh()
	assert_true(s._resolve_btn.disabled, "and the button is greyed")
	s._map._anim_queue = []
	s._refresh()
	assert_false(s._resolve_btn.disabled, "until it is done")
	s.free()


func test_the_menu_survives_a_colour_change_and_quits_to_the_harness() -> void:
	var s := _screen()
	s._open_menu()
	var menu: PauseMenu = s._menu
	menu.hud_changed.emit()
	assert_true(is_instance_valid(s._menu) and s._menu == menu and menu.get_parent() == s, "the same menu after the rebuild")
	assert_eq(s.get_child(s.get_child_count() - 1), menu, "on top of the rebuilt screen")
	var quits: Array = []
	s.quit_requested.connect(func() -> void: quits.append(true))
	menu.quit_requested.emit()
	assert_eq(quits.size(), 1, "the battle screen passes QUIT up to the harness")
	s.free()


func test_a_skirmish_quit_leaves_the_battle_too() -> void:
	var s := _screen()
	var b := s.battle
	_engage(b, b.field.packs()[0], b.mechs()[0])
	s._refresh()
	s._on_hex_tapped(b.mechs()[0].pos)
	s._on_hex_tapped(b.field.packs()[0].pos)
	s._engage()
	assert_true(s._skirmish != null, "skirmish screen opened")
	var quits: Array = []
	s.quit_requested.connect(func() -> void: quits.append(true))
	s._skirmish.quit_requested.emit()
	assert_eq(quits.size(), 1, "the skirmish's QUIT goes straight out to the harness")
	s.free()


func test_the_battle_is_saved_as_it_goes_and_resumes() -> void:
	const TMP := "user://test_screen_battle.json"
	SaveGame.clear(TMP)
	var s := _screen(4)
	s.autosave_enabled = true
	s.save_path = TMP
	var b := s.battle
	var m: Unit = b.mechs()[0]
	assert_false(SaveGame.exists(TMP), "nothing written until something changes")
	s._on_hex_tapped(m.pos)
	var dest: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(dest)
	assert_true(SaveGame.exists(TMP), "the move is saved")
	assert_eq(SaveGame.load(TMP).field.unit_by_id(m.id).pos, dest, "where the machine went")
	# A hunter's catch, resumed: the panel comes back.
	var hunter: Unit = b.field.packs()[0]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	hunter.zone = 1
	b._new_turn()
	s._autosave()
	var loaded := SaveGame.load(TMP)
	assert_eq(loaded.forced.size(), 1, "the catch is in the save")
	var r := BattleScreen.new()
	r.setup(loaded)
	r._resume_where_it_was()
	assert_true(r._contacts != null, "the caught fight's panel comes back")
	assert_eq(r._skirmish, null, "no fight opened on its own")
	r.free()
	# Into the fight, and the save follows every change.
	s._open_attack(null)
	s._engage()
	var sk: Skirmish = s._skirmish.sk
	var before := FileAccess.get_file_as_string(TMP)
	sk.reroll([0])
	s._skirmish._refresh()
	assert_true(FileAccess.get_file_as_string(TMP) != before, "a reroll in the fight is saved")
	var mid := SaveGame.load(TMP)
	assert_true(mid.current != null, "the fight is in the save")
	assert_eq(mid.current.round, sk.round, "at its round")
	assert_eq(mid.current.mechs[0].face_index, sk.mechs[0].face_index, "with the die as it shows")
	var r2 := BattleScreen.new()
	r2.setup(mid)
	r2._resume_where_it_was()
	assert_true(r2._skirmish != null, "resumed straight into the skirmish screen")
	assert_eq(r2._skirmish.sk, mid.current, "on the saved fight")
	assert_eq(r2._sub_label.text, "FIGHT", "the field reads as in a fight")
	r2.free()
	# A decided battle clears the save.
	sk.reinforcements.clear()
	for f in sk.field_foes():
		f.hp = 0
	s._skirmish._end_turn_now()
	s._on_skirmish_back()
	b.field.gate_hp = 0
	b._check_outcome()
	s._after_step()
	assert_eq(b.state, Battle.State.DONE, "over")
	assert_false(SaveGame.exists(TMP), "and the save is gone")
	s.free()

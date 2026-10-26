extends TestCase

## Drives the battle screen through its handlers without a window: select, move, order a
## machine onto a pack by a tap or a drag and ENGAGE, the skirmish and back, a hunter's catch,
## the enemy's turn, and the outcome overlay (bible section 4, the round row).


func _screen(seed_value: int = 3) -> BattleScreen:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		team.append(db.make_mech(id))
	var b := Battle.new(seed_value)
	b.setup(team, "marsh")
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
	if not sq.is_boss:
		sq.behaviour = "push"


func test_screen_builds_on_the_players_turn() -> void:
	var s := _screen()
	assert_true(s._header.text.begins_with("TURN 01"), "turn one in the header")
	assert_true(s._header.text.contains("NEXT SPAWN IN"), "and how long until the rift spawns")
	assert_true(s._sub_label.text.begins_with("READY // 3 OF 3"), "every machine ready")
	assert_false(s._resolve_btn.disabled, "the turn can end")
	assert_eq(s._resolve_btn.text, "END TURN", "nothing ordered: the button ends the turn")
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
	assert_eq(s._map.selected, m, "and stays in hand, to pick a target from there")
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


func test_a_tap_on_a_pack_with_a_machine_in_hand_orders_it_and_engage_opens_the_fight() -> void:
	var s := _screen()
	var b := s.battle
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	s._refresh()
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(sq.pos)
	assert_eq(b.order_of(m), sq, "ordered onto the pack")
	assert_eq(b.state, Battle.State.PLAN, "nothing opens on the tap")
	assert_eq(s._resolve_btn.text, "ENGAGE", "the button reads ENGAGE")
	assert_false(s._map.attack.is_empty(), "the map shows the fight")
	assert_true((s._map.attack["committed"] as Array).has(m), "with the machine in it")
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(sq.pos)
	assert_eq(b.order_of(m), null, "a second tap on its pack takes the order back")
	assert_eq(s._resolve_btn.text, "END TURN", "and the button ends the turn again")
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(sq.pos)
	s._on_main_button()
	assert_true(s._skirmish != null, "ENGAGE opens the skirmish screen")
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


func test_a_drag_onto_a_pack_orders_the_machine_into_range() -> void:
	var s := _screen()
	var b := s.battle
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	sq.behaviour = "push"
	var spot := Vector2i(-99, -99)
	for h in b.field.map.all_hexes():
		if Hex.distance(h, m.pos) == 3 and b.field.can_stand(sq, h):
			spot = h
			break
	sq.pos = spot
	sq.movespeed = 0
	s._refresh()
	s._on_route_drag_started(m)
	s._on_route_drag_to(sq.pos)
	assert_eq(s._drag_target, sq, "the finger is on the pack")
	assert_true((s._map.attack.get("committed", []) as Array).has(m), "the map shows the fight it would join")
	s._on_route_drag_ended(true)
	assert_eq(b.order_of(m), sq, "letting go orders it onto the pack")
	assert_true(b.in_range_from(m, m.pos, sq), "having moved into range")
	s.free()


## The carry's block on the map (the Swallowtail's, Ryan, 21 October): a route drawn to a stop
## where a rider cannot land shows the riders' landing hexes and the one that fails, and letting
## go there moves nothing; with room, the block lands where it rode.
func test_a_carriers_route_marks_a_stop_with_no_room_and_lets_go_only_where_the_block_fits() -> void:
	var s := _screen()
	var b := s.battle
	var carrier: Unit = b.mechs()[0]
	var rider: Unit = b.mechs()[1]
	var third: Unit = b.mechs()[2]
	carrier.grant_passive({"id": "deck", "name": "Deck", "description": "", "effects": [{"trigger": "static", "effect": "carry"}]})
	var line := _open_line(b, [carrier, rider, third])
	assert_false(line.is_empty(), "a line of four open hexes")
	carrier.pos = line[0]
	rider.pos = line[1]
	third.pos = line[3]   # where the rider would land if the carrier stopped at the third hex
	s._refresh()
	s._on_route_drag_started(carrier)
	s._on_route_drag_to(line[2])
	assert_eq(s._map.draft, [line[1], line[2]], "the route over the rider")
	assert_eq(s._map.draft_land.get("bad", []), [line[3]] as Array[Vector2i], "the map marks the landing that fails")
	s._on_route_drag_ended(true)
	assert_eq([carrier.pos, rider.pos], [line[0], line[1]], "letting go there moves nothing")
	assert_true(s._map.draft_land.is_empty(), "and the mark goes with the route")
	third.pos = Vector2i(-50, -50)
	s._refresh()
	s._on_route_drag_started(carrier)
	s._on_route_drag_to(line[2])
	assert_true((s._map.draft_land.get("bad", []) as Array).is_empty(), "with room, nothing marked")
	s._on_route_drag_ended(true)
	assert_eq([carrier.pos, rider.pos], [line[2], line[3]], "the block lands where it rode")
	s.free()


## Four hexes in a line, open ground for the machines given (the first stands on the first and
## the third and crosses the second; the second on the second and the fourth), away from every
## other unit; empty when the map has none.
func _open_line(b: Battle, ours: Array) -> Array:
	var carrier: Unit = ours[0]
	var rider: Unit = ours[1]
	for c in b.field.map.all_hexes():
		for d in Hex.DIRECTIONS:
			var line: Array = [c, c + d, c + d * 2, c + d * 3]
			var ok := true
			for k in range(4):
				var h: Vector2i = line[k]
				if not b.field.map.has(h) or b.field.map.is_structure(h):
					ok = false
					break
				var o := b.field.unit_at(h)
				if o != null and not ours.has(o):
					ok = false
					break
				if k <= 2 and (not BattleMap.passable(b.field.map.terrain[h], carrier.traits) or BattleMap.move_cost(b.field.map.terrain[h], carrier.traits) == BattleMap.SLOW):
					ok = false
					break
				if (k == 1 or k == 3) and not BattleMap.passable(b.field.map.terrain[h], rider.traits):
					ok = false
					break
				for n in Hex.neighbors(h):
					var near := b.field.unit_at(n)
					if near != null and not ours.has(near):
						ok = false
			if ok:
				return line
	return []


func test_a_pack_tapped_with_nothing_in_hand_shows_its_fight() -> void:
	var s := _screen()
	var sq: Unit = s.battle.field.packs()[0]
	s._on_hex_tapped(sq.pos)
	assert_true(s.battle.orders.is_empty(), "nothing ordered")
	assert_false(s._map.attack.is_empty(), "its fight shows: who joins, where a machine must stand")
	assert_true(s._details.visible, "and its readout")
	s._on_hex_tapped(s.battle.map.rift)
	assert_true(s._map.attack.is_empty(), "a tap elsewhere puts it away")
	s.free()


func test_a_hunters_catch_is_fought_first() -> void:
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
	assert_eq(s._resolve_btn.text, "ENGAGE", "the button reads ENGAGE with nobody ordered")
	assert_true(s._sub_label.text.begins_with("CAUGHT"), "the readout says so")
	assert_false(s._map.attack.is_empty(), "the catch's fight shows")
	var other: Unit = b.field.packs()[1]
	s._on_hex_tapped(b.mechs()[1].pos)
	s._on_hex_tapped(other.pos)
	assert_eq(b.order_of(b.mechs()[1]), null, "another pack cannot be ordered on first")
	s._on_end_turn()
	assert_eq(b.field.phase, 0, "nor the turn ended")
	s._on_main_button()
	assert_true(s._skirmish != null, "ENGAGE opens the catch")
	s._skirmish.sk.reinforcements.clear()
	for f in s._skirmish.sk.field_foes():
		f.hp = 0
	s._skirmish._end_turn_now()
	s._on_skirmish_back()
	assert_true(b.forced.is_empty(), "fought")
	assert_eq(s._resolve_btn.text, "END TURN", "the turn may end")
	s.free()


## The boss's fight plays the family's theme when there is one (Ryan, 25 September).
func test_the_boss_fight_plays_its_theme() -> void:
	var s := _screen()
	var b := s.battle
	_engage(b, b.boss, b.mechs()[0])
	s._refresh()
	s._on_hex_tapped(b.mechs()[0].pos)
	s._on_hex_tapped(b.boss.pos)
	s._on_main_button()
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
	assert_true(BattleMapView.foe_sprite_id(s.battle.boss) == "bone_dragon", "boss uses the faction's boss art")
	s.free()


func test_hold_shows_a_readout() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	s._on_unit_held(m)
	assert_true(s._details.visible, "readout shown")
	# Readout lines, as the fight's holds read (Ryan, 26 October: the map's looked like blocks
	# of text): the name, the gauges with their numbers, then the stats.
	var lines: Array = s._details_entry.lines
	assert_eq(str(lines[0]["style"]), "title", "the name heads it")
	assert_eq(str(lines[0]["text"]), m.display_name.to_upper(), "the machine's name")
	assert_eq(str(lines[1]["style"]), "bar", "its shield a gauge")
	assert_eq(str(lines[2]["text"]), "Hull %d/%d" % [m.hull, m.hull_max], "its hull a gauge with its numbers")
	assert_true(s._details_entry.text().contains("action"), "and its actions")
	assert_true(s._details_entry.text().contains("Move %d" % int(m.base["move"])), "and its move")
	s._on_hold_released()
	assert_false(s._details.visible, "hidden on release")
	var sq: Unit = s.battle.field.packs()[0]
	s._on_unit_held(sq)
	assert_true(s._details_entry.text().contains("×%d" % sq.strength), "pack strength")
	assert_true(s._details_entry.text().contains("Ring %d" % sq.zone), "and its ring")
	assert_true(s._details_entry.text().contains("Marches") or s._details_entry.text().contains("Hunts"), "and what it is doing")
	s._on_unit_held(s.battle.boss)
	assert_eq(str(s._details_entry.lines[0]["type"]), "Boss", "the boss says so beside its name")
	assert_true(s._details_entry.text().contains("Massive"), "boss readout")
	assert_true(s._details.size.y >= s._details_entry.custom_minimum_size.y, "the panel holds its lines")
	s.free()


func test_the_ground_and_a_refusal_read_as_lines() -> void:
	var s := _screen()
	var water := BattleScreen.ground_lines(BattleMap.Terrain.WATER)
	assert_eq(str(water[0]["text"]), "WATER", "the ground's name heads it")
	var text := ""
	for l in water:
		text += EntryReadout.line_text(l) + "\n"
	assert_true(text.contains("Fast: Hover"), "a line a word, the ways under it: %s" % text)
	assert_true(text.contains("Slow: Walker, Wheeled (the step ends the move)"), "the slow step's price said: %s" % text)
	assert_true(text.contains("Packs never enter it"), "and what the horde does")
	var mountain := BattleScreen.ground_lines(BattleMap.Terrain.MOUNTAIN)
	assert_true(EntryReadout.line_text(mountain[2]).begins_with("Impassable:"), "a wall reads impassable")
	s._show_details(BattleScreen.notice_lines("Out of reach", "It cannot get there"))
	assert_eq(str(s._details_entry.lines[0]["text"]), "OUT OF REACH", "a refusal's title")
	assert_true(s._details.visible, "shown in the readout")
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
	assert_true(s._details.visible and s._details_entry.text().contains("Integrity %d/%d" % [s.battle.field.gate_hp, s.battle.field.gate_hp_max]), "its integrity a gauge in the readout")
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
	s._on_main_button()
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
	# A hunter's catch, resumed: it is still the next fight.
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
	assert_eq(r._resolve_btn.text, "ENGAGE", "the catch is ready to engage")
	assert_eq(r._skirmish, null, "no fight opened on its own")
	r.free()
	# Into the fight, and the save follows every change.
	s._on_main_button()
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

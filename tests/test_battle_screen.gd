extends TestCase

## Drives the battle screen through its handlers without a window: select, route, resolve,
## contact into a skirmish and back, and the outcome overlay.


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


func _engage(b: Battle, sq: Unit, m: Unit) -> void:
	for n in Hex.neighbors(m.pos):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	sq.movespeed = 0
	b.field.compute_intents()


func test_screen_builds_in_the_plan_phase() -> void:
	var s := _screen()
	assert_true(s._header.text.begins_with("PHASE 01"), "phase one in the header")
	assert_true(s._sub_label.text.begins_with("PLAN"), "plan readout")
	assert_false(s._resolve_btn.disabled, "resolve available")
	assert_true(s._clear_btn.disabled, "nothing to clear yet")
	assert_true(s._map.field == s.battle.field, "map shows the field")
	assert_true(s._map.scroll_y <= 0.0, "scrolled to the gate end")
	s.free()


func test_tap_selects_routes_and_clears() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	s._on_hex_tapped(m.pos)
	assert_eq(s._map.selected, m, "mech selected")
	assert_true(s._map.destinations.size() > 0, "destinations lit")
	var dest: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(dest)
	assert_eq(s._map.selected, null, "deselected after plotting")
	assert_eq(s.battle.route_end(m), dest, "route plotted")
	assert_false(s._clear_btn.disabled, "clear available")
	assert_true(s._sub_label.text.contains("1 OF 3"), "readout counts the route")
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(m.pos)
	assert_true(s.battle.routes.is_empty(), "second tap on the mech clears its route")
	assert_eq(s._map.selected, null, "and deselects")
	s.free()


func test_tap_elsewhere_deselects() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(s.battle.map.rift)
	assert_eq(s._map.selected, null, "deselected")
	assert_true(s.battle.routes.is_empty(), "no route to an unreachable hex")
	s.free()


func test_resolve_runs_a_phase() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	s._on_hex_tapped(m.pos)
	var dest: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(dest)
	s._on_resolve()
	assert_eq(m.pos, dest, "mech moved")
	assert_true(s._header.text.begins_with("PHASE 02"), "next phase")
	assert_eq(s.battle.state, Battle.State.PLAN, "planning")
	assert_eq(s._skirmish, null, "no contact, no skirmish")
	s.free()


func test_contact_opens_the_skirmish_screen_and_back_applies_it() -> void:
	var s := _screen()
	var b := s.battle
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.squads()[0]
	_engage(b, sq, m)
	s._on_resolve()
	assert_true(s._contacts != null, "the contacts are offered first, for the player to pick and confirm")
	assert_eq(s._skirmish, null, "nothing opens until they do")
	s._open_skirmish(0)
	assert_true(s._skirmish != null, "skirmish screen opened")
	assert_eq(s._sub_label.text, "CONTACT", "contact readout")
	assert_true(s._resolve_btn.disabled, "no resolving mid-skirmish")
	var sk: Skirmish = s._skirmish.sk
	assert_eq(sk.round, 1, "skirmish started")
	sk.reinforcements.clear()
	for f in sk.field_foes():
		f.hp = 0
	s._skirmish._end_turn_now()
	assert_true(s._skirmish._overlay.visible, "skirmish outcome shown")
	s._on_skirmish_back()
	assert_eq(s._skirmish, null, "skirmish screen gone")
	assert_false(b.field.units.has(sq), "squad wiped")
	assert_eq(b.state, Battle.State.PLAN, "back to the plan")
	assert_false(s._resolve_btn.disabled, "resolve available again")
	s.free()


func test_offscreen_squads_get_edge_tags() -> void:
	var s := _screen()
	var tags: Array = s._map.offscreen_tags()
	var hidden := 0
	for sq in s.battle.field.squads():
		if s._map.to_screen(s._map.center(sq.pos)).y < -BattleMapView.HEX_SIZE * 0.3:   # center is map space; tags are judged on screen
			hidden += 1
	assert_true(hidden >= 2, "most squads start off-screen at the gate end")
	assert_eq(tags.size(), hidden, "one tag per off-screen squad")
	for t in tags:
		var rect: Rect2 = t[0]
		assert_true(t[2], "tags sit at the top edge")
		assert_true(rect.position.x >= 0.0 and rect.end.x <= s._map.size.x, "tag inside the view")
	for i in range(1, tags.size()):
		assert_true(tags[i][0].position.x >= tags[i - 1][0].end.x, "tags do not overlap")
	var sq: Unit = s.battle.field.squads()[0]
	s._map.scroll_to_unit(sq)
	var still: Array = s._map.offscreen_tags()
	for t in still:
		assert_true(t[1] != sq, "the squad scrolled to has no tag")
	assert_true(BattleMapView.foe_sprite_id(s.battle.boss) == "bone_colossus", "boss uses the faction's boss art")
	s.free()


func test_hold_shows_a_readout() -> void:
	var s := _screen()
	s._on_unit_held(s.battle.mechs()[0])
	assert_true(s._details.visible, "readout shown")
	assert_true(s._details_label.text.contains("hull"), "mech numbers")
	s._on_hold_released()
	assert_false(s._details.visible, "hidden on release")
	s._on_unit_held(s.battle.field.squads()[0])
	assert_true(s._details_label.text.contains("×"), "squad strength")
	s._on_unit_held(s.battle.boss)
	assert_true(s._details_label.text.contains("massive"), "boss readout")
	s.free()


func test_gate_falling_shows_the_outcome() -> void:
	var s := _screen()
	var b := s.battle
	b.field.gate_hp = 5
	var sq: Unit = b.field.squads()[0]
	load("res://tests/test_battle.gd").threaten_gate(b, sq)
	s._on_resolve()
	assert_true(s._overlay.visible, "overlay shown")
	assert_eq(s._overlay_title.text, "GATE FALLEN", "title")
	assert_true(s._resolve_btn.disabled, "no more phases")
	s.free()


func test_double_tap_opens_the_codex_for_a_machine_and_a_squad() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	s._on_hex_double_tapped(m.pos)
	assert_true(s._codex.visible, "the codex opens for a machine")
	assert_true(s._codex._faces.visible, "with its die listed")
	s._codex.close()
	assert_false(s._codex.visible, "and closes")
	var sq: Unit = s.battle.field.squads()[0]
	s._on_hex_double_tapped(sq.pos)
	assert_true(s._codex.visible, "the codex opens for a squad")
	assert_eq(s._codex._title.text, sq.display_name, "headed by the squad")
	assert_true(s._codex._sub.text.contains("×%d" % sq.strength), "with its strength in the subtitle")
	assert_true(not s._codex._body.text.is_empty(), "and its foe type's codex text")
	s._codex.close()
	s.free()


func test_a_tap_routes_onto_a_hex_an_earlier_machine_is_leaving() -> void:
	# Ryan, 22 September: plotting in order frees the hex; the tap must route there, not
	# select the machine still drawn on it.
	var s := _screen()
	var a: Unit = s.battle.mechs()[0]
	var b: Unit = s.battle.mechs()[1]
	var a_from := a.pos
	s._on_hex_tapped(a.pos)
	var dests: Array = s._map.destinations.keys()
	s._on_hex_tapped(dests[0])
	assert_true(s.battle.routes.has(a.id), "A plotted away")
	s._on_hex_tapped(b.pos)
	if s._map.destinations.has(a_from):
		s._on_hex_tapped(a_from)
		assert_true(s.battle.routes.has(b.id), "B's route set by the tap on A's old hex")
		var r: Array = s.battle.routes[b.id]
		assert_eq(r[r.size() - 1], a_from, "and it ends there")
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

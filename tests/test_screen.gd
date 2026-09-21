extends TestCase

## Drives the skirmish screen through its gesture and button handlers without a window, so a
## script error in the UI layer fails the suite instead of waiting for someone to tap it.


func _screen(seed_value: int = 3, elite: bool = false) -> SkirmishScreen:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(seed_value)
	for id in ["badger", "sentinel", "raptor"]:
		sk.add_mech(db.make_mech(id))
	var ghouls := Unit.squad(1, "ghouls", Vector2i.ZERO, "undead", 2, 4, "ghoul")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var necros := Unit.squad(2, "necromancers", Vector2i.ZERO, "undead", 2, 2, "necromancer")
	sk.add_foes(db.foes_for(necros), necros)
	if elite:
		var boss := Unit.boss(3, "colossus", Vector2i.ZERO, "undead")
		sk.add_foes(db.foes_for(boss), boss)
	var screen := SkirmishScreen.new()
	screen.setup(sk)
	return screen


func test_screen_builds_and_starts_round_one() -> void:
	var s := _screen()
	assert_eq(s.sk.round, 1, "round one started")
	assert_eq(s.sk.state, Skirmish.State.ASSIGN, "assigning")
	assert_eq(s._dice.size(), 3, "three dice views")
	assert_eq(s._end_btn.text, "END TURN", "one end button")
	assert_eq(s._mech_views.size(), 3, "three mech views")   # mechs are models; headless has no renderer and no sprite
	assert_true(s._dice[0].can_tap and s._dice[0].can_drag, "dice lock and drag in the same phase")
	s.free()


func test_tap_locks_and_unlocks_a_die() -> void:
	var s := _screen()
	s._on_die_tapped(0)
	assert_true(s.locked[0], "locked after one tap")
	assert_true(s._dice[0].locked, "view shows the lock")
	s._on_die_tapped(0)
	assert_false(s.locked[0], "unlocked after a second tap")
	s.free()


func test_reroll_skips_locked_and_spent_dice() -> void:
	var s := _screen(11)
	s._on_die_tapped(0)
	var kept_face := s.sk.mechs[0].face_index
	var before := s.sk.rerolls_left
	s._on_reroll()
	assert_eq(s.sk.rerolls_left, before - 1, "one reroll spent")
	assert_eq(s.sk.mechs[0].face_index, kept_face, "locked die untouched")
	s.free()


func test_attack_then_reroll_flow() -> void:
	var s := _screen(5)
	var attacker := -1
	for i in range(3):
		if s.sk.mechs[i].face().is_attack():
			attacker = i
			break
	assert_true(attacker >= 0, "someone rolled an attack")
	var target: Foe = s.sk.targets_for(attacker)[0]
	assert_true(s._use_die(attacker, target), "attack lands first")
	assert_true(s._roll_label.visible, "the number flashed over the target")
	assert_false(s._reroll_btn.disabled, "reroll still available after attacking")
	s._on_reroll()
	assert_eq(s.sk.rerolls_left, Skirmish.REROLLS_PER_ROUND - 1, "reroll spent after the attack")
	assert_true(s.sk.mechs[attacker].assigned, "spent die stays spent")
	s.free()


func test_drag_onto_a_target_spends_the_face() -> void:
	var s := _screen()
	for i in range(3):
		var ms: Skirmish.MechState = s.sk.mechs[i]
		var f := ms.face()
		if f.is_attack():
			var t := s.sk.targets_for(i)
			assert_true(not t.is_empty(), "attack face has targets")
			assert_true(s._use_die(i, t[0]), "face spent on a foe")
		elif f.kind == Face.Kind.BLANK:
			assert_true(s._use_die(i, null), "blank discarded")
		else:
			assert_true(s._use_die(i, s.sk.mechs[(i + 1) % 3]), "support face spent on an ally")
		assert_true(ms.assigned, "mech %d assigned" % i)
		assert_false(s._dice[i].can_drag, "spent die no longer drags")
		assert_false(s._dice[i].can_tap, "spent die no longer locks")
	s.free()


func test_drop_target_lookup_finds_a_foe_view() -> void:
	var s := _screen()
	var foe: Foe = s.sk.front[0]
	var v := s._foe_view_for(foe)
	assert_true(v != null, "front foe has a view")
	var hit = s._drop_target_at(v.get_global_rect().get_center())
	assert_eq(hit, foe, "the point at the view's centre resolves to the foe")
	var mv := s._mech_views[1]
	var hit2 = s._drop_target_at(mv.get_global_rect().get_center())
	assert_eq(hit2, s.sk.mechs[1], "and a mech view resolves to its mech")
	s.free()


func test_hold_shows_details_and_arrows() -> void:
	var s := _screen()
	var foe: Foe = s.sk.front[0]
	var v := s._foe_view_for(foe)
	s._on_foe_held(v)
	assert_true(s._details.visible, "details shown on hold")
	assert_eq(s._arrows.arrows.size(), 1, "one arrow for the held foe")
	s._on_hold_released()
	assert_false(s._details.visible, "details hidden on release")
	assert_eq(s._arrows.arrows.size(), 0, "arrows cleared")
	s._toggle_all_arrows(true)
	assert_true(s._arrows.arrows.size() >= 3, "eye shows every arrow")
	s.free()


func test_die_hold_shows_every_face_visually_without_the_passive() -> void:
	var s := _screen()
	s._on_die_held(2)
	assert_true(s._details.visible, "details shown")
	var text := s._details_label.text
	var title := str(ContentDB.load_default().chassis.get(s.sk.mechs[2].unit.chassis_id, {}).get("name", "")).to_upper()
	assert_true(text.begins_with(title + " // D4"), "names the die and its size (from content, never a hardcoded name)")
	assert_true(s._details_faces.visible, "face list shown")
	assert_eq(s._details_faces.faces.size(), 4, "four faces in the column")
	assert_eq(s._details_faces.current, s.sk.mechs[2].face_index, "current face highlighted")
	assert_false(text.contains("Hot Hands"), "passive is not on the die readout")
	s._on_hold_released()
	assert_false(s._details.visible, "hidden on release")
	s.free()


func test_face_descriptions_drop_the_line_word() -> void:
	assert_eq(Face.attack(10, Face.Reach.LINE, [], 0, 30).describe(), "10–30", "line of fire goes unsaid")
	assert_true(Face.attack(20, Face.Reach.INDIRECT).describe().begins_with("indirect 20"), "indirect is called out")


func test_double_tap_opens_and_closes_the_codex() -> void:
	var s := _screen()
	var foe: Foe = s.sk.front[0]
	s._on_foe_double_tapped(s._foe_view_for(foe))
	assert_true(s._codex.visible, "codex opens for a foe")
	assert_eq(s._codex_title.text, foe.display_name, "titled with the foe's name")
	assert_eq(s._codex_sub.text, "THE RISEN", "faction name as the subtitle")
	assert_true(not s._codex_body.text.is_empty(), "foe codex text present")
	assert_true(s._codex_actions.visible and s._codex_actions.text.contains("CLAW"), "implemented actions listed")
	assert_false(s._codex_actions.text.contains("GET BACK UP"), "planned actions stay hidden")
	assert_true(s._codex_flavour.text.begins_with("“"), "flavour shown as a quote")
	assert_true(s._codex_flavour.text.contains("tired"), "the foe's own line, not the faction's")
	assert_false(s._codex_faces.visible, "no face list for a foe")
	assert_true(s._codex.custom_minimum_size.x >= 600.0, "codex is wide")
	s._close_codex()
	assert_false(s._codex.visible, "codex closes")
	s._on_mech_double_tapped(2)
	assert_true(s._codex.visible, "codex opens for a mech")
	var title := str(ContentDB.load_default().chassis.get(s.sk.mechs[2].unit.chassis_id, {}).get("name", ""))
	assert_true(s._codex_title.text.contains(title), "titled with the chassis name from content")
	var headless := DisplayServer.get_name() == "headless"   # no renderer: the model view cannot draw
	assert_true(headless or (s._codex_sprite.visible and s._codex_sprite.texture != null), "head-on model shown")
	assert_true(s._codex_passive.visible, "raptor's passive is shown")
	assert_true(s._codex_passive.text.to_lower().contains("hot hands"), "by name")
	assert_true(s._codex_faces.visible and s._codex_faces.faces.size() == 4, "faces listed visually")
	s._close_codex()
	s.free()


func test_die_double_tap_opens_face_codex_and_keeps_lock_state() -> void:
	var s := _screen()
	assert_false(s.locked[0], "unlocked to start")
	s._on_die_tapped(0)
	s._on_die_double_tapped(0)
	assert_false(s.locked[0], "lock state unchanged by a double-tap")
	assert_true(s._codex.visible, "face codex open")
	assert_true(s._codex_title.text.ends_with("die"), "titled as the die")
	assert_true(s._codex_faces.visible, "faces listed visually")
	assert_eq(s._codex_faces.current, s.sk.mechs[0].face_index, "current face highlighted, not repeated")
	assert_false(s._codex_body.visible, "no body text on the die entry")
	s._close_codex()
	s.free()


func test_end_turn_asks_only_when_dice_would_be_wasted() -> void:
	var s := _screen(5)
	s._on_end_turn()
	assert_true(s._confirm.visible, "asks with dice unspent")
	assert_eq(s.sk.round, 1, "nothing happened yet")
	s._hide_confirm()
	assert_false(s._confirm.visible, "no keeps the turn")
	for i in range(3):
		var ms: Skirmish.MechState = s.sk.mechs[i]
		var f := ms.face()
		if f.is_attack():
			s._use_die(i, s.sk.targets_for(i)[0])
		elif f.kind == Face.Kind.BLANK:
			s._use_die(i, null)
		else:
			s._use_die(i, s.sk.mechs[(i + 1) % 3])
	s._on_end_turn()
	assert_false(s._confirm.visible, "no question when every die is spent")
	assert_eq(s.sk.round, 2, "the turn ended at once")
	s.free()


func test_end_turn_runs_the_enemy_and_returns_to_the_player() -> void:
	var s := _screen(5)
	var before := 0
	for m in s.sk.mechs:
		before += m.unit.hull + m.unit.shield
	s._on_end_turn()
	s._confirm_yes()
	assert_eq(s.sk.round, 2, "round two began at once")
	assert_eq(s.sk.state, Skirmish.State.ASSIGN, "back to the player")
	var after := 0
	for m in s.sk.mechs:
		after += m.unit.hull + m.unit.shield
	assert_true(after < before, "the enemy acted in between")
	assert_true(s.sk.can_withdraw(), "withdraw offered at the start of round two")
	assert_false(s._withdraw_btn.disabled, "withdraw button enabled")
	s.free()


func test_withdraw_asks_then_shows_overlay() -> void:
	var s := _screen(5)
	assert_false(s._withdraw_btn.disabled, "withdraw open at the start of round one")
	s._end_turn_now()
	s._on_withdraw()
	assert_true(s._confirm.visible, "withdraw always asks first")
	assert_eq(s.sk.outcome, Skirmish.Outcome.NONE, "not yet withdrawn")
	s._confirm_yes()
	assert_eq(s.sk.outcome, Skirmish.Outcome.WITHDRAWN, "withdrawn")
	assert_true(s._overlay.visible, "overlay shown")
	assert_eq(s._overlay_title.text, "WITHDREW", "title")
	s.free()


func test_exposed_marker_appears_when_front_dies() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(90))
	sk.add_mech(m)
	sk.add_foes([Foe.make("ghoul", 30, 10), Foe.make("archer", 30, 10, true)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	s._use_die(0, sk.front[0])
	s._end_turn_now()
	assert_true(sk.is_exposed(0), "column exposed in the sim")
	s.free()


func test_massive_elite_uses_the_tall_view() -> void:
	var s := _screen(3, true)
	var massive_cols := 0
	for col in range(3):
		if s._massive_views[col].visible:
			massive_cols += 1
			assert_false(s._slot_views[0][col].visible, "slot views hidden under a massive foe")
			assert_false(s._slot_views[1][col].visible, "both of them")
	assert_eq(massive_cols, 1, "one column shows the massive elite")
	s.free()


func test_screen_lays_out_four_columns() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(4, 4)
	for id in ["badger", "sentinel"]:
		sk.add_mech(db.make_mech(id))
	# Ranks hold: four front-rank ghouls fill the front, four back-rank necromancers the back.
	var ghouls := Unit.squad(1, "ghouls", Vector2i.ZERO, "undead", 2, 4, "ghoul")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var necros := Unit.squad(2, "necromancers", Vector2i.ZERO, "undead", 2, 4, "necromancer")
	sk.add_foes(db.foes_for(necros), necros)
	var s := SkirmishScreen.new()
	s.setup(sk)
	assert_eq(s._slot_views[0].size(), 4, "four front views")
	assert_eq(s._massive_views.size(), 4, "four massive views")
	var first: UnitView = s._slot_views[0][0]
	var last: UnitView = s._slot_views[0][3]
	assert_true(first.position.x >= 0.0, "first column inside the screen")
	assert_true(last.position.x + last.size.x <= SkirmishScreen.W, "last column inside the screen")
	assert_true(s._view_foe.size() == 8, "eight foes shown")
	s.free()

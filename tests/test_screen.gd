extends TestCase

## Drives the skirmish screen through its gesture and button handlers without a window, so a
## script error in the UI layer fails the suite instead of waiting for someone to tap it.


func _screen(seed_value: int = 3, elite: bool = false) -> SkirmishScreen:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(seed_value)
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		sk.add_mech(db.make_mech(id))
	var ghouls := Unit.pack(1, "ghouls", Vector2i.ZERO, "marsh", 20, 4, "revenant")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var necros := Unit.pack(2, "necromancers", Vector2i.ZERO, "marsh", 20, 2, "ghost")
	sk.add_foes(db.foes_for(necros), necros)
	if elite:
		var boss := Unit.boss(3, "colossus", Vector2i.ZERO, "marsh")
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


func test_die_hold_shows_every_face_with_what_applies_to_it() -> void:
	var s := _screen()
	s._on_die_held(2)
	assert_true(s._details.visible, "details shown")
	var text := s._details_label.text
	var title := str(ContentDB.load_default().chassis.get(s.sk.mechs[2].unit.chassis_id, {}).get("name", "")).to_upper()
	assert_true(text.begins_with(title + " // D4"), "names the die and its size (from content, never a hardcoded name)")
	assert_true(s._details_faces.visible, "face list shown")
	assert_eq(s._details_faces.faces.size(), 4, "four faces in the column")
	assert_eq(s._details_faces.current, s.sk.mechs[2].face_index, "current face highlighted")
	var passive_name := str(ContentDB.load_default().chassis.get(s.sk.mechs[2].unit.chassis_id, {}).get("passive", {}).get("name", ""))
	assert_false(text.contains(passive_name), "the passive is not in the heading")
	var tagged := false
	for l in s._details_faces.labels:
		if str(l).contains(passive_name):
			tagged = true
	assert_true(tagged, "but each entry it changes says so (the Sparrowhawk's doubled damage and heat)")
	s._on_hold_released()
	assert_false(s._details.visible, "hidden on release")
	s.free()


func test_face_descriptions_drop_the_line_word() -> void:
	assert_eq(Face.attack(10, Face.Reach.DIRECT, [], 0, 30).describe(), "10–30", "line of fire goes unsaid")
	assert_true(Face.attack(20, Face.Reach.INDIRECT).describe().begins_with("indirect 20"), "indirect is called out")


func test_double_tap_opens_and_closes_the_codex() -> void:
	var s := _screen()
	var foe: Foe = s.sk.front[0]
	s._on_foe_double_tapped(s._foe_view_for(foe))
	assert_true(s._codex.visible, "codex opens for a foe")
	assert_eq(s._codex._title.text, foe.display_name, "titled with the foe's name")
	assert_eq(s._codex._sub.text, "THE MARSH", "the domain's name as the subtitle")
	assert_true(not s._codex._body.text.is_empty(), "foe codex text present")
	assert_true(s._codex._actions.visible and s._codex._actions.text.contains("CLAW"), "implemented actions listed")
	assert_true(s._codex._actions.text.contains("A KIN"), "the swarm is said too")
	assert_true(s._codex._flavour.text.begins_with("“"), "flavour shown as a quote")
	assert_true(s._codex._flavour.text.contains("tired"), "the foe's own line, not the faction's")
	assert_false(s._codex._faces.visible, "no face list for a foe")
	assert_true(s._codex._panel.custom_minimum_size.x >= 600.0, "codex is wide")
	s._close_codex()
	assert_false(s._codex.visible, "codex closes")
	s._on_mech_double_tapped(2)
	assert_true(s._codex.visible, "codex opens for a mech")
	var title := str(ContentDB.load_default().chassis.get(s.sk.mechs[2].unit.chassis_id, {}).get("name", ""))
	assert_true(s._codex._title.text.contains(title), "titled with the chassis name from content")
	var headless := DisplayServer.get_name() == "headless"   # no renderer: the model view cannot draw
	assert_true(headless or (s._codex._sprite.visible and s._codex._sprite.texture != null), "head-on model shown")
	assert_true(s._codex._passives.visible, "sparrowhawk's passive is shown")
	var passive_name := str(ContentDB.load_default().chassis.get(s.sk.mechs[2].unit.chassis_id, {}).get("passive", {}).get("name", "")).to_lower()
	var shown := ""
	for l in s._codex._passives.get_children():
		shown += (l as Label).text.to_lower() + "\n"
	assert_true(not passive_name.is_empty() and shown.contains(passive_name), "by its name from content")
	var first: Label = s._codex._passives.get_child(0)
	assert_eq(first.get_theme_color("font_color"), CodexBox.passive_colour("chassis"), "the chassis's own passive in its colour, first")
	assert_true(CodexBox.passive_colour("component") != CodexBox.passive_colour("chassis"), "a component's passive reads in another")
	assert_true(s._codex._faces.visible and s._codex._faces.faces.size() == 4, "faces listed visually")
	s._close_codex()
	s.free()


func test_a_quick_second_tap_on_a_die_is_a_tap() -> void:
	# The die codex is gone (Ryan, 22 September): tap locks, tap again unlocks, hold reads.
	var s := _screen()
	assert_false(s.locked[0], "unlocked to start")
	s._on_die_tapped(0)
	s._on_die_tapped(0)
	assert_false(s.locked[0], "two taps: locked then unlocked")
	assert_false(s._codex.visible, "no codex opened")
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
	sk.add_foes([Foe.make("revenant", 30, 10), Foe.make("archer", 30, 10, true)])
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
	for id in ["badger", "clydesdale"]:
		sk.add_mech(db.make_mech(id))
	# Ranks hold: four front-rank ghouls fill the front, four back-rank necromancers the back.
	var ghouls := Unit.pack(1, "ghouls", Vector2i.ZERO, "marsh", 20, 4, "revenant")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var necros := Unit.pack(2, "necromancers", Vector2i.ZERO, "marsh", 20, 4, "ghost")
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


func test_log_holds_every_line_and_double_tap_opens_it_full() -> void:
	var s := _screen(5)
	assert_true(s._log_scroll != null and s._log_scroll.get_child_count() == 1, "the log strip is a scroller around the text")
	for k in range(12):
		s.sk.log.append("line %d" % k)
	s._refresh()
	for k in range(12):
		assert_true(s._log.text.contains("line %d" % k), "every line is in the strip: %d" % k)
	assert_false(s._log_full.visible, "full log closed to start")
	s._toggle_log_full()
	assert_true(s._log_full.visible, "double-tap opens the full log")
	assert_true(s._log_full_text.text.contains("line 0") and s._log_full_text.text.contains("line 11"), "the full log has the whole fight")
	s._toggle_log_full()
	assert_false(s._log_full.visible, "and closes it again")
	s.free()


func test_a_killed_foe_shows_no_intent_and_no_arrow() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(90))
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 30, 10), Foe.make("revenant", 30, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	s._toggle_all_arrows(true)
	assert_eq(s._arrows.arrows.size(), 2, "both ghouls aim at the only mech")
	var first: Foe = sk.front[0]
	s._use_die(0, first)
	assert_eq(sk.front[0], null, "the kill cleared its slot at once")
	assert_eq(s._foe_view_for(first), null, "no view holds it any more")
	assert_eq(s._arrows.arrows.size(), 1, "its arrow is gone")
	s.free()


func test_the_last_kill_ends_the_fight_without_end_turn() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(90))
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 30, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	s._use_die(0, sk.front[0])
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "decided by the die")
	assert_true(s._overlay.visible, "the outcome shows at once (headless: no delay)")
	assert_eq(s._overlay_title.text, "VICTORY", "title")
	assert_true(s._end_btn.disabled, "nothing left to end")
	s.free()


func test_the_formation_is_four_wide_by_default() -> void:
	assert_eq(Skirmish.new(1).columns, 4, "four columns unless asked otherwise (Ryan, 23 September)")
	var s := _screen()
	assert_eq(s._slot_views[0].size(), 4, "four front views")
	assert_eq(s._massive_views.size(), 4, "four massive views")
	s.free()


func test_withdraw_plays_the_enemy_turn_before_fleeing() -> void:
	var s := _screen(5)
	var before := 0
	for m in s.sk.mechs:
		before += m.unit.hull + m.unit.shield
	s._on_withdraw()
	s._confirm_yes()
	assert_eq(s.sk.outcome, Skirmish.Outcome.WITHDRAWN, "withdrawn")
	assert_true(s.sk.turn_events.size() > 0, "the enemy struck on the way out")
	var ev: Dictionary = s.sk.turn_events[0]
	assert_true(ev.has("shield") and ev.has("hull"), "each blow carries the mech's gauges after it, for the replay")
	var after := 0
	for m in s.sk.mechs:
		after += m.unit.hull + m.unit.shield
	assert_true(after < before, "and it cost the team")
	assert_true(s._overlay.visible, "the outcome shows once the replay is done (headless: at once)")
	assert_eq(s._overlay_title.text, "WITHDREW", "title")
	assert_false(s._replay_shade.visible, "taps are taken again")
	s.free()


func test_the_enemy_beat_follows_the_setting_and_tops_out_at_the_old_instant() -> void:
	var s := _screen()
	Settings.display["enemy_pace"] = 1.0
	assert_eq(s._enemy_beat(), SkirmishScreen.ENEMY_BEAT, "one beat at pace 1")
	Settings.display["enemy_pace"] = Settings.DISPLAY_RANGES["enemy_pace"].y
	assert_true(absf(s._enemy_beat() - 0.12) < 0.01, "the slider's top is the old 0.12 s between blows")
	Settings.display["enemy_pace"] = Settings.DISPLAY_DEFAULTS["enemy_pace"]
	assert_true(Settings.DISPLAY_RANGES.has("enemy_pace"), "and it has a slider range")
	s.free()


func test_the_menu_survives_a_colour_change_and_quits_to_the_host() -> void:
	var s := _screen()
	s._open_menu()
	var menu: PauseMenu = s._menu
	assert_true(menu.is_open(), "the menu opens")
	var was := Settings.hud
	menu.hud_changed.emit()   # what a swatch does after the mask has shown
	assert_true(is_instance_valid(s._menu) and s._menu == menu, "the same menu after the rebuild")
	assert_true(menu.get_parent() == s, "still on the screen")
	assert_eq(s.get_child(s.get_child_count() - 1), menu, "and on top of it")
	assert_true(menu.is_open(), "still open")
	Settings.set_hud(was)
	var quits: Array = []
	s.quit_requested.connect(func() -> void: quits.append(true))
	menu._show_page("quit")
	var pressed := false
	for c in menu._rows.get_children():
		if c is HudButton and c.text == "QUIT":
			c.pressed.emit()
			pressed = true
	assert_true(pressed, "the quit page has a QUIT")
	assert_eq(quits.size(), 1, "the screen asks its host to leave")
	assert_false(menu.is_open(), "and the menu is gone")
	s.free()


func test_the_eye_and_reroll_keep_off_the_grounds() -> void:
	var s := _screen()
	assert_true(s._eye.position.y >= s.LOG_Y - 10.0, "the eye sits in the black under the foes' ground")
	assert_true(s._log_scroll.position.x + s._log_scroll.size.x <= s._eye.position.x, "the log strip stops short of it")
	var seam := s.REROLL_Y + SkirmishScreen.REROLL_SIZE.y + SkirmishScreen.REROLL_GAP
	assert_true(seam <= s.MECH_Y, "the mechs' ground starts before the mechs")
	assert_true(s.DIE_Y >= s.LOG_Y + SkirmishScreen.LOG_H, "the dice sit under the log")
	s.free()


func test_replay_steps_order_specials_among_blows_and_name_only_the_named() -> void:
	# The plaque (decided 9 October): a special always announces, a boss's blow announces
	# once per move, a plain blow never; the steps follow the sim's order, not the lists'.
	var s := _screen(5)
	var before := s._before_enemy_turn()
	var ghoul: Foe = s.sk.field_foes()[0]
	var boss := Foe.make("colossus", 140, 30)
	boss.size = 2
	boss.action = {"id": "storm", "name": "Bone Storm", "kind": "attack", "strikes": 3}
	var blow := {"mech": 0, "absorbed": 0, "through": 10, "blocked": false, "broke_shield": false, "injured": false, "shield": 0, "hull": 50}
	var b1 := blow.duplicate(); b1["foe"] = boss; b1["seq"] = 1; b1["name"] = "Bone Storm"; b1["boss"] = true
	var b2 := blow.duplicate(); b2["foe"] = boss; b2["seq"] = 2; b2["name"] = "Bone Storm"; b2["boss"] = true
	var b3 := blow.duplicate(); b3["foe"] = ghoul; b3["seq"] = 4; b3["name"] = "Claw"; b3["boss"] = false
	s.sk.turn_events = [b1, b2, b3]
	s.sk.turn_specials = [{"foe": ghoul, "name": "Protect", "kind": "defend", "seq": 3}]
	var steps := s._replay_steps(before)
	assert_eq(steps.size(), 4, "three blows and a special")
	var seqs: Array = []
	for st in steps:
		seqs.append(int(st["seq"]))
	assert_eq(seqs, [1, 2, 3, 4], "in the sim's order")
	assert_eq(str(steps[0]["announce"]), "Bone Storm", "the boss's move is announced before its first strike")
	assert_eq(str(steps[1]["announce"]), "", "and not again for its second")
	assert_eq(str(steps[2]["announce"]), "Protect", "the special is announced")
	assert_true((steps[2]["blow"] as Array).is_empty(), "and lands no blow")
	assert_eq(str(steps[3]["announce"]), "", "a plain blow shows no plaque")
	assert_eq((steps[3]["blow"] as Array).size(), 11, "and lands as before, with the striker's family and the struck machine's maker for the sound")
	s.free()


func test_the_plaque_shows_a_name_in_its_pixel_face() -> void:
	var p := Plaque.new()
	p.px = 4.0
	p.announce("1000 Needles", 1.0)
	assert_true(p.is_showing(), "showing")
	assert_eq(p.text, "1000 NEEDLES", "upper case, the face has no lower")
	assert_eq(p.size, p.size_for("1000 NEEDLES"), "sized to its name")
	assert_true(p.size.x > p.size_for("FIRE").x, "a longer name, a wider window")
	assert_eq(Plaque.glyph_rows("A").size(), 7, "seven rows a glyph")
	assert_eq(Plaque.glyph_rows("~"), Plaque.glyph_rows(" "), "a character the face lacks is a space")
	var s := _screen(5)
	assert_true(s._plaque != null, "the screen carries one")
	s._announce("Protect")
	assert_true(s._plaque.is_showing(), "and announces on it")
	assert_true(s._plaque.position.x > 0.0 and s._plaque.position.x + s._plaque.size.x < SkirmishScreen.W, "centred over the foes")
	s.free()
	p.free()

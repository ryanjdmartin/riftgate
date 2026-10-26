extends TestCase

## Drives the skirmish screen through its gesture and button handlers without a window, so a
## script error in the UI layer fails the suite instead of waiting for someone to tap it.


func _screen(seed_value: int = 3, massive: Foe = null) -> SkirmishScreen:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(seed_value)
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		sk.add_mech(db.make_mech(id))
	var ghouls := Unit.pack(1, "ghouls", Vector2i.ZERO, "marsh", 20, 4, "revenant")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var necros := Unit.pack(2, "necromancers", Vector2i.ZERO, "marsh", 20, 2, "ghost")
	sk.add_foes(db.foes_for(necros), necros)
	if massive != null:
		sk.add_foes([massive])
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
		if f.has(Face.Keyword.RAPID) or (f.resets_on_kill and not ms.assigned):
			# A rapid entry gives the turn back (the Laminar Deflector's since 12 October), and so
			# does a reset gun whose shot killed (the Kite's Pinion Driver, 21 October): the die
			# rolls again and the machine acts again.
			assert_false(ms.assigned, "a rapid face or a reset kill gives mech %d its turn back" % i)
			continue
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


## The die's hold (Ryan, 25 October: "only show the visible component"; 26 October: "it just
## turns the iconography into text"): the entry showing, alone, as a list in the order a spend
## runs it: its place and name from content, its number as the die prints it, its target, its
## keywords, its heat, its own rules, then its tags. A number the live sources moved off the
## component's own is highlighted, never its sources listed: the player's gain white, a loss
## the enemy red, an arrow for which way. The whole die is the codex's.
func test_die_hold_shows_the_entry_showing_with_its_effects_listed() -> void:
	var s := _screen()
	var db := ContentDB.load_default()
	var ms: Skirmish.MechState = s.sk.mechs[1]
	var gun := Face.attack(3, Face.Reach.INDIRECT, [Face.Keyword.CLEAVE, Face.Keyword.BURN], 3, 5)
	gun.burn = 2
	gun.strikes = 2
	gun.spray = true
	gun.component = str(db.components.keys()[0])
	gun.tags.append_array(["beam", "flame"])
	ms.die = Die.single(gun)
	ms.face_index = 0
	ms.unit.grant_passive({"id": "t_amp", "name": "Test Amp", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 2}]})
	s._refresh()
	s._on_die_held(1)
	assert_true(s._details.visible and s._details_entry.visible, "the entry's readout shown")
	assert_false(s._details_label.visible, "no heading over it: the entry's name is its first line")
	var lines: Array = s._details_entry.lines
	var texts: Array[String] = []
	for l in lines:
		texts.append(str(l["text"]))
	assert_eq(texts[0], db.component_name(gun.component).to_upper(), "its name, from content")
	assert_eq(str(lines[0]["place"]), "I", "beside its place on the die")
	var sf := s.sk.shown_face(ms, gun)
	var n := s.sk.shown_number(ms, sf)
	assert_eq(texts, [texts[0], "Attack", "Target: Enemy, Indirect", "Spread", "Heat", "Apply Burn 2 on hit", "Sprays the rest in reach", "Tags: Beam, Flame"],
		"a line a mark on the die, in the order a spend runs it, and no source listed: %s" % str(texts))
	assert_eq(str(lines[1]["value"]).replace(EntryReadout.NBSP, " "), "%d–%d ×2" % [n[0], n[1]], "the number as the die prints it")
	assert_eq([int(lines[1]["trend"]), bool(lines[1]["gain"])], [1, true], "moved up by the passive, the player's gain: highlighted, never explained")
	assert_eq(str(lines[4]["value"]), str(sf.heat), "the heat as the spend adds it")
	assert_true(s._details_entry.text().contains("▲"), "its arrow says which way it moved: %s" % s._details_entry.text())
	assert_true(s._details_entry.custom_minimum_size.y > 100.0, "sized to its lines: %s" % str(s._details_entry.custom_minimum_size))
	assert_true(s._details.size.y >= s._details_entry.custom_minimum_size.y, "and the panel to it")
	s._on_hold_released()
	assert_false(s._details.visible, "hidden on release")
	# A heat a passive raised is the player's loss: the red chip, its arrow up.
	ms.unit.grant_passive({"id": "t_hot", "name": "Test Hot", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_heat", "value": 2}]})
	s._on_die_held(1)
	for l in s._details_entry.lines:
		if str(l["text"]) == "Heat":
			assert_eq([int(l["trend"]), bool(l["gain"])], [1, false], "more heat than the component's own: a loss")
	s._on_hold_released()
	s.free()


## Equipment says whom it is spent on, in Ryan's words; a debuff prints no number; a gated rider
## says where it lands; a written-out grant prints its passive's line (the star's text).
func test_the_hold_reads_equipment_debuffs_buffs_and_grants() -> void:
	var db := ContentDB.load_default()
	var shield := Face.shield(6)
	shield.targets = Face.Target.SELF
	shield.add_keyword(Face.Keyword.CLEANSE)
	var texts: Array[String] = []
	for l in EntryReadout.effects_of(shield):
		texts.append(str(l["text"]))
	assert_eq(texts, ["Shield 6", "Target: Self", "Cleanse"], "its number, its target, its keyword: %s" % str(texts))
	shield.targets = Face.Target.ALLY
	assert_eq(EntryReadout.whom(shield), "Target: Any other ally", "an ally's")
	shield.targets = Face.Target.SELF_ALLY
	assert_eq(EntryReadout.whom(shield), "Target: Any ally or self", "either")
	var probe := Face.attack(0, Face.Reach.INDIRECT, [Face.Keyword.SUPPRESS])
	probe.strikes = 2
	probe.gates = {"suppress": {"when": "target_status", "status": "flakked"}}
	var lines := EntryReadout.effects_of(probe)
	assert_eq(str(lines[0]["text"]), "Debuff ×2", "a debuff prints no number")
	assert_eq(str(lines[1]["text"]), "Target: Enemy, Indirect", "a weapon's target and reach")
	assert_eq(str(lines[2]["text"]), "Apply Suppress %s" % Effects.gate_text(probe.gates["suppress"]), "a gated rider says where it lands")
	assert_eq(str(EntryReadout.effects_of(Face.empty_slot())[0]["text"]), "Comes up blank: nothing fills it", "an empty hardpoint says what it does, its name the title")
	var wreck := Face.blank()
	wreck.component = str(db.components.keys()[0])
	assert_eq(str(EntryReadout.effects_of(wreck)[0]["text"]), "Destroyed: comes up blank for the rest of the battle", "and a destroyed one what is left of it")
	assert_eq(str(EntryReadout.lines_for(wreck, 2, [], wreck, [], [], db)[0]["text"]), db.component_name(wreck.component).to_upper(), "its name still the title")
	var coil := Face.buff("overcharged", 2)
	assert_eq(str(EntryReadout.effects_of(coil)[0]["text"]), "Grants %s ×2" % str(Effects.STATUS["overcharged"]["name"]), "a buff grants its status")
	var u := Unit.new()
	u.grant_passive({"id": "t_spill", "name": "Spill", "description": "Damage past a kill spills behind.", "effects": [{"trigger": "static", "effect": "grant_keyword", "value": "spillover", "printed": true}]})
	var gun := Face.attack(4)
	assert_eq(Effects.printed_grants(u, gun), ["Damage past a kill spills behind."], "a written-out grant is its passive's line")
	assert_eq(str(EntryReadout.lines_for(gun, 1, [], gun, [], Effects.printed_grants(u, gun), db).back()["text"]), "Damage past a kill spills behind.", "among the rules, last")


## The keywords list (Ryan, 26 October): the pause menu's page and the button under the eye open
## it, every term the dice and the chips print, by kind, each with its codex line; nothing
## planned shows.
func test_the_keywords_list_holds_every_term_the_dice_print() -> void:
	var db := ContentDB.load_default()
	var names := {}
	var ids := {}
	for kind in PauseMenu.glossary(db):
		for e in kind["entries"]:
			names[str(e[0])] = str(e[1])
			ids[str(e[2])] = true
	for k in Face.KEYWORD_NAMES.keys():
		if k != Face.Keyword.NONE:
			var term := str(db.vocabulary[Face.KEYWORD_NAMES[k]]["name"])
			assert_true(names.has(term) and not str(names[term]).is_empty(), "%s listed with its codex" % term)
	for r in ["direct", "indirect"]:
		assert_true(names.has(str(db.vocabulary[r]["name"])), "%s listed" % r)
	for sid in Face.KEYWORD_STATUS.values():
		var st := str(Effects.STATUS[sid]["name"])
		assert_true(names.has(st), "the status %s listed" % st)
	for id in db.vocabulary.keys():
		if str(db.vocabulary[id].get("status", "")) != "implemented":
			assert_false(ids.has(id), "the planned %s is never shown" % id)
	var s := _screen()
	s._keys.pressed.emit()
	assert_true(s._menu != null and s._menu.visible, "the button under the eye opens it")
	assert_eq(s._menu._page, "keywords", "straight on the keywords")
	s._menu.close()
	assert_false(s._menu.visible, "and it closes back to the fight")
	s._open_menu()
	assert_eq(s._menu._page, "paused", "MENU still opens on PAUSED")
	s._menu._show_page("keywords")
	assert_true(s._menu._list != null and s._menu._list.get_child(0).get_child_count() > 20, "its page from there, the list built")
	s.free()


## The rules the hold lists last are the ones the entry prints, word for word, for every
## component in content and its charged form; equipment reaching every ally never says it
## reaches every foe.
func test_every_rule_the_hold_lists_is_one_the_entry_prints() -> void:
	var db := ContentDB.load_default()
	var checked := 0
	for cid in db.components.keys():
		var f := db.build_face(db.components[cid].get("face", {}))
		for r in f.rule_phrases():
			assert_true(f.describe().contains(r), "%s prints %s: %s" % [cid, r, f.describe()])
			checked += 1
		if not f.is_attack():
			assert_false(f.describe().contains("reaches every foe"), "%s, equipment, reaches no foe: %s" % [cid, f.describe()])
	assert_true(checked > 10, "the rules read: %d" % checked)


func test_every_die_shows_the_place_of_the_entry_it_shows() -> void:
	assert_eq(Hud.roman(1), "I", "one")
	assert_eq(Hud.roman(4), "IV", "four")
	assert_eq(Hud.roman(9), "IX", "nine")
	assert_eq(Hud.roman(14), "XIV", "fourteen")
	assert_eq(Hud.roman(0), "", "no place, no numeral")
	var s := _screen(11)
	for i in range(3):
		assert_eq(s._dice[i].slot, s.sk.mechs[i].face_index + 1, "die %d shows its entry's place, from one" % i)
	s._on_reroll()
	for i in range(3):
		assert_eq(s._dice[i].slot, s.sk.mechs[i].face_index + 1, "die %d's numeral follows the reroll" % i)
	s.free()


func test_a_long_codex_description_takes_two_lines_never_more() -> void:
	var font := Hud.display()
	var text := "20 fires the hopper, +5 a load (3 a shot) (+10 heat)"
	var whole := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
	assert_eq(FaceListView._wrapped(font, text, whole + 1.0, 17, 2).size(), 1, "one line when it fits")
	var two := FaceListView._wrapped(font, text, whole * 0.6, 17, 2)
	assert_eq(two.size(), 2, "two when it does not")
	assert_eq(" ".join(two), text, "every word kept, in order")
	assert_eq(FaceListView._wrapped(font, text, 10.0, 17, 2).size(), 2, "never more than two, the rest on the last")


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
	assert_true(s._codex._faces.visible and s._codex._faces.faces.size() == s.sk.mechs[2].die.faces.size(), "faces listed visually")
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
	# Every die spent where the screen lets it go: a self-only piece on its own machine, and a
	# die that comes back (a reset gun's kill) spent again.
	for sweep in range(12):
		var left := false
		for i in range(3):
			var ms: Skirmish.MechState = s.sk.mechs[i]
			if ms.assigned or not ms.alive() or ms.face() == null:
				continue
			left = true
			var f := ms.face()
			if f.is_attack():
				s._use_die(i, s.sk.targets_for(i)[0])
			elif f.kind == Face.Kind.BLANK:
				s._use_die(i, null)
			else:
				s._use_die(i, s.sk.equipment_targets_for(ms, f)[0])
		if not left:
			break
	assert_eq(s.sk.state, Skirmish.State.ASSIGN, "the fight is still on")
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


func test_a_massive_foe_uses_the_tall_view() -> void:
	# Size, never the role: big is an attribute of any tier (15 October), so a synthetic one.
	var big := Foe.make("colossus", 140, 30)
	big.size = 2
	var s := _screen(3, big)
	var massive_cols := 0
	for col in range(3):
		if s._massive_views[col].visible:
			massive_cols += 1
			assert_false(s._slot_views[0][col].visible, "slot views hidden under a massive foe")
			assert_false(s._slot_views[1][col].visible, "both of them")
	assert_eq(massive_cols, 1, "one column shows the massive foe")
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


func test_a_suppressed_foe_shows_its_chip_in_place_of_its_intent() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(5, Face.Reach.DIRECT, Face.Keyword.SUPPRESS))
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 30, 10), Foe.make("revenant", 30, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	s._toggle_all_arrows(true)
	var first: Foe = sk.front[0]
	var v := s._foe_view_for(first)
	assert_eq(v.intent_kind, "attack", "it shows its blow before the spend")
	s._use_die(0, first)
	assert_true(first.alive() and first.is_suppressed(), "struck and suppressed, still standing")
	assert_eq(v.intent_kind, "", "its intent clears")
	assert_eq(str(v.statuses[0][0]), "suppress", "the Suppressed chip leads the row in its place")
	assert_eq(s._arrows.arrows.size(), 1, "only the other foe's arrow stays")
	s._on_foe_held(v)
	var text := s._details_label.text
	assert_false(text.contains("→"), "the hold names no target")
	assert_false(text.contains("%s %d" % [str(first.action.get("name", "")), first.damage()]), "nor the blow it will not land")
	s._on_hold_released()
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


## The Nemesis's rage (Ryan, 13 October): a die rolled again by a spent stack bursts the
## stack's chip, then flips back with the reroll's sound; headless, the burst is set going and
## the die is the player's to spend again.
func test_a_rage_roll_bursts_the_chip_and_gives_the_die_back() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	var fist := Face.attack(10)
	fist.rolls_again_on = "rage"
	m.die = Die.single(fist)
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(m, Effects.STATUS["rage"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	s._refresh()
	assert_true(s._use_die(0, sk.front[0]), "the fist lands")
	assert_false(sk.mechs[0].assigned, "the rage rolled it again")
	assert_true(s._mech_views[0]._spend >= 0.0, "the rage chip bursts")
	assert_eq(s._mech_views[0]._spend_glyph, SkirmishScreen.status_glyph("rage"), "on the rage chip")
	assert_false(s._dice[0].spent, "the die is the player's again")
	assert_true(s._use_die(0, sk.front[0]), "and it punches again")
	assert_true(sk.mechs[0].assigned, "no rage left: spent")
	s._rage_debug()   # the debug switch's call: a stack kept on the machine, the burst again
	assert_true(Effects.stacks_of(m, "rage") >= 1, "the debug keeps a stack to burst")
	s.free()


## A capped store on the screen (Ryan, 22 October: the rage, individual boxes up to the cap):
## boxes under the heat lit to its count, in its chip's colour, and no chip; a rage spent from
## them bursts there as it did from the chip.
func test_a_capped_store_shows_as_boxes_under_the_heat_in_its_chips_place() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.grant_passive({"id": "rage_core", "name": "Rage Core", "description": "", "effects": [
		{"trigger": "on_hull_damage", "effect": "stack_status", "value": "rage", "cap": 5}]})
	var fist := Face.attack(10)
	fist.rolls_again_on = "rage"
	m.die = Die.single(fist)
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(m, Effects.STATUS["rage"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	s._refresh()
	var v: UnitView = s._mech_views[0]
	assert_eq([int(v.boxes[0]), int(v.boxes[1])], [2, 5], "two of five boxes lit")
	assert_eq(str(v.boxes[3]), SkirmishScreen.status_glyph("rage"), "the store's own mark, for its burst")
	for r in s._mech_rows(0):
		assert_ne(str(r[0]), SkirmishScreen.status_glyph("rage"), "and no rage chip")
	assert_true(s._use_die(0, sk.front[0]), "the fist lands")
	assert_true(v._spend >= 0.0 and v._spend_glyph == SkirmishScreen.status_glyph("rage"), "the spent rage bursts")
	assert_eq(int(v.boxes[0]), 1, "one box left lit")
	s.free()


## A timed buff spent in two rounds is two grants, each going when its own rounds run out
## (16 October), and one status on the machine: one chip, counting every stack.
func test_a_status_granted_in_two_rounds_is_one_chip_with_every_stack() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(10))
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.remove(m, "overcharged")
	Effects.grant_buff(m, "overcharged", 1, "buff", sk.round + 1)
	Effects.grant_buff(m, "overcharged", 1, "buff", sk.round + 2)
	s._refresh()
	var texts: Array[String] = []
	for r in s._mech_rows(0):
		if str(r[0]) == SkirmishScreen.status_glyph("overcharged"):
			texts.append(str(r[1]))
	assert_eq(texts, ["×2"] as Array[String], "one chip for the status, counting both grants")
	s.free()


## The chip texts machine `i` wears for status `id`, one a chip.
func _chips_for(s: SkirmishScreen, i: int, id: String) -> Array[String]:
	var texts: Array[String] = []
	for r in s._mech_rows(i):
		if str(r[0]) == SkirmishScreen.status_glyph(id):
			texts.append(str(r[1]))
	return texts


## Every status is a chip whatever its scope (Ryan, 16 October: the Ammit is Overcharged, "so
## anything that interacts with overcharged needs it displayed"). The talons' kills'
## Overcharged, kept for the battle when its owner keeps the status, is a chip with its count;
## a buff's joins it in the one chip (kept too, since 18 October: the Tap keeps every grant),
## and the hold and the codex each list it once.
func test_a_status_kept_for_the_battle_is_a_chip_with_its_count() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(10))
	m.grant_passive({"id": "keeper", "name": "Keeper", "description": "Keeps what its kills give.",
		"effects": [{"trigger": "static", "effect": "keep_status", "value": "overcharged"}]})
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.remove(m, "overcharged")
	assert_true(Effects.keeps(m, "overcharged"), "the machine keeps Overcharged")
	sk._overcharge_on_kill(sk.mechs[0], sk.front[0], 1)
	sk._overcharge_on_kill(sk.mechs[0], sk.front[0], 1)
	var scopes: Array = []
	for d in Effects.describe(m):
		if str(d[5]) == "overcharged":
			scopes.append(int(d[3]))
	assert_eq(scopes, [Effects.BATTLE], "two kills kept for the battle: one grant, below the skirmish's scope")
	s._refresh()
	assert_eq(_chips_for(s, 0, "overcharged"), ["×2"] as Array[String], "an Overcharged chip with its count")
	Effects.grant_buff(m, "overcharged", 1, "buff", sk.round)
	s._refresh()
	assert_eq(_chips_for(s, 0, "overcharged"), ["×3"] as Array[String], "a buff's for the round joins it in one chip")
	var held := 0
	for r in s._readout_rows(s._mech_rows(0)):
		if str(r[1]).begins_with("Overcharged"):
			held += 1
	assert_eq(held, 1, "the hold lists it once")
	var named := 0
	for note in Effects.explain(m, m.die.faces[0]):
		if note.contains("Overcharged"):
			named += 1
	assert_eq(named, 1, "the die's row names it once")
	var listed := 0
	for r in db.codex_for_unit(m)["passive_rows"]:
		if str(r[0]).begins_with("OVERCHARGED"):
			listed += 1
			assert_true(str(r[0]).begins_with("OVERCHARGED ×3 (KEPT FOR THE BATTLE)"), "a kept status, never a reward, with its count, the buff's stack kept with the kills' (Ryan, 18 October): %s" % str(r[0]))
	assert_eq(listed, 1, "and the codex once: the kept stacks, which the battle carries past this fight")
	# What is no status stays in the codex: the passive that keeps it, and a battle reward.
	Effects.grant(m, Effects.make({"id": "spoils", "name": "Spoils", "description": "Hull +10.",
		"effects": [{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 10}]}, Effects.BATTLE, "reward"))
	s._refresh()
	var rules := 0
	for r in s._mech_rows(0):
		if str(r[2]).begins_with("Keeper") or str(r[2]).begins_with("Spoils"):
			rules += 1
	assert_eq(rules, 0, "a passive and a battle reward that are no status are no chip")
	assert_true(Effects.is_status("corrupted_1") and Effects.is_status("disabled_0"), "a die entry's Corrupted and Disabled are statuses")
	assert_false(Effects.is_status("keeper") or Effects.is_status("disabled_x"), "a passive is none")
	s.free()


## A foe's brace is Braced, the machines' status (16 October): the foe wears Braced's chip with
## the armour it adds, and a Protect on top is the same chip, whatever scope each grant is in.
func test_a_braced_foe_wears_one_braced_chip() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(10))
	sk.add_mech(m)
	var foe := Foe.make("revenant", 300, 10)
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	foe.action = {"id": "dig", "name": "Dig", "kind": "defend", "effect": "brace", "value": 10, "weight": 1, "text": ""}
	sk._foe_acts(foe, sk.mechs[0])
	foe.action = {"id": "ward", "name": "Ward", "kind": "defend", "effect": "brace_all", "value": 5, "weight": 1, "text": ""}
	sk._foe_acts(foe, sk.mechs[0])
	var chips: Array = []
	for r in s._foe_rows(foe):
		if str(r[0]) == SkirmishScreen.status_glyph("braced"):
			chips.append(r)
	assert_eq(chips.size(), 1, "one chip for its brace and the Protect on top")
	if chips.size() == 1:
		assert_eq(str(chips[0][1]), "+15", "the armour both add")
		assert_eq(str(chips[0][2]), "Armoured: armour +15 until its next action", "named Armoured, as a machine's is")
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


## The predator sense (the funnel-web, 18 October): while an ambusher's die is held or dragged
## the foes' ground dims and the foes its entry can reach that show no intent on it are marked;
## and a webbed or acid-eaten foe wears its chip, the web's pointing at the neighbour it catches.
func test_the_predator_sense_marks_the_foes_looking_away_while_the_die_is_held_or_dragged() -> void:
	var ambush := {"id": "ambush_t", "name": "Ambush", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1, "when": "target_no_intent", "damaging": true}]}
	var s := _screen(7)
	var i := 0
	var ms: Skirmish.MechState = s.sk.mechs[i]
	for k in range(ms.die.faces.size()):
		if ms.die.faces[k].is_attack():
			ms.face_index = k
			break
	assert_true(ms.face().is_attack(), "the first machine shows a weapon")
	ms.unit.grant_passive(ambush)
	for foe in s.sk.field_foes():
		foe.target = s.sk.mechs[1]
	s._refresh()
	assert_false(s._prey.on, "off until the die is held or dragged")
	var reach := s.sk.targets_for(i)
	assert_true(reach.size() >= 2, "foes in reach to mark")
	s._on_die_held(i)
	assert_true(s._prey.on, "on while the die is held")
	assert_eq(s._prey.marks.size(), reach.size(), "every foe in reach looks at another machine: every one marked")
	s._on_hold_released()
	assert_false(s._prey.on, "off when the die is let go")
	var t: Foe = reach[0]
	t.target = ms
	s._on_drag_started(i)
	assert_true(s._prey.on, "on while the die is dragged")
	assert_eq(s._prey.marks.size(), reach.size() - 1, "the foe that turned on it loses its eyes")
	assert_false(s.prey_for(i).has(t), "the read is the foe's intent on the machine")
	s._on_drag_ended(Vector2(-100, -100))
	assert_false(s._prey.on, "off when the drag ends")
	assert_true(s.prey_for(1).is_empty(), "a machine without the read marks nothing")
	var foe: Foe = s.sk.front[0]
	Effects.stack(foe, Effects.STATUS["webbed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	Effects.stack(foe, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 2)
	Effects.stack(foe, Effects.STATUS["flakked"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_HALF)
	Effects.stack(foe, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	s._refresh()
	var glyphs: Array = []
	for r in s._foe_rows(foe):
		glyphs.append(r[0])
		if r[0] == "web":
			assert_eq(r[1], ">", "the web's chip points at the neighbour it catches, to its right")
		if r[0] == "flak":
			assert_eq(r[1], "3", "Flak's chip counts its stacks, the extra every blow deals")
		if r[0] == "cryo":
			assert_eq(r[1], "2", "Cryo's chip counts its stacks (21 October: it had none)")
	assert_true(glyphs.has("web") and glyphs.has("vitriol"), "a webbed, acid-eaten foe wears both chips: %s" % str(glyphs))
	assert_true(glyphs.has("flak") and glyphs.has("cryo"), "and Flak and Cryo wear theirs: %s" % str(glyphs))
	s.free()


## The blast's marks (the Whip Scorpion's forecast, 22 October): a vent die on a machine whose
## vents blast prints its blast and, held or dragged, rings every live foe with what it would
## deal there; over an ally the vent blasts nothing, so the print and the rings go.
func test_a_blasting_vent_rings_every_foe_with_its_number_until_it_is_over_an_ally() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var a := db.make_mech("badger")
	a.grant_passive({"id": "blast_t", "name": "Blast", "description": "", "effects": [{"trigger": "static", "effect": "vent_blast", "value": 1}]})
	a.die = Die.single(Face.vent(20))
	sk.add_mech(a)
	sk.add_mech(db.make_mech("clydesdale"))
	var plated := Foe.make("revenant", 300, 10)
	plated.armour = 5
	sk.add_foes([Foe.make("revenant", 300, 10), plated])
	var s := SkirmishScreen.new()
	s.setup(sk)
	sk.mechs[0].heat = 30
	s._refresh()
	assert_eq(s._dice[0].blast, 20, "the die prints the blow its vent would fire")
	assert_false(s._prey.on, "no rings until the die is in hand")
	s._on_die_held(0)
	assert_true(s._prey.on and s._prey.style == "blast", "held: the blast's rings")
	assert_eq(s._prey.marks.size(), 2, "on every live foe")
	assert_true(s._prey.labels.has("20") and s._prey.labels.has("15"), "each with what it would deal there, armour off: %s" % str(s._prey.labels))
	s._on_hold_released()
	assert_false(s._prey.on, "gone when let go")
	s._on_drag_started(0)
	assert_true(s._prey.on, "dragged: the rings")
	assert_eq(s._ghost.blast, 20, "and the die under the finger prints it")
	s._on_drag_moved(s._mech_views[1].get_global_rect().get_center())
	assert_false(s._prey.on, "over an ally the vent blasts nothing: no rings")
	assert_eq(s._ghost.blast, 0, "and no print")
	s._on_drag_moved(s._mech_views[0].get_global_rect().get_center())
	assert_true(s._prey.on, "back over itself, the rings return")
	s._on_drag_ended(Vector2(-100, -100))
	assert_false(s._prey.on, "gone when the drag ends")
	s.free()


## The lure preview (the Siphon's forecast, 22 October): while a die whose entry Lures every foe
## is held or dragged, the foes it would turn draw dashed arrows to its machine, its gauges read
## the lured blows and their heat, and the machine they left reads none; let go, all goes back.
func test_a_lure_in_hand_previews_its_turn_with_dashed_arrows_and_the_gauges() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var a := db.make_mech("badger")
	a.die = Die.single(Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"], "braces": 2, "reaches_all": true, "heat_per_blow": 10}))
	sk.add_mech(a)
	sk.add_mech(db.make_mech("clydesdale"))
	sk.add_foes([Foe.make("revenant", 300, 10), Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	for f in sk.field_foes():
		f.target = sk.mechs[1]
	s._refresh()
	var heat_before := int(s._mech_views[0].bars[2][3])
	assert_eq(heat_before, sk.mechs[0].heat, "the heat as it stands")
	s._on_die_held(0)
	var dashed := s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3]))
	assert_eq(dashed.size(), 2, "both foes' arrows dashed to the lure, unasked")
	assert_eq(int(s._mech_views[0].bars[2][3]), sk.mechs[0].heat + 20, "its heat gauge drinks ten a lured blow")
	assert_eq(int(s._mech_views[1].bars[1][3]), sk.mechs[1].unit.hull, "the machine they left keeps its hull")
	s._on_hold_released()
	assert_eq(int(s._mech_views[0].bars[2][3]), heat_before, "let go, the gauge goes back")
	assert_true(s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3])).is_empty(), "and the dashed arrows with it")
	for f in sk.field_foes():
		assert_eq(f.target, sk.mechs[1], "nothing turned for real")
	s._on_drag_started(0)
	assert_eq(s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3])).size(), 2, "dragged anywhere, the same preview")
	s._on_drag_ended(Vector2(-100, -100))
	sk.front[0].target = sk.mechs[0]
	s._on_die_held(0)
	assert_eq(s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3])).size(), 1, "the one it would turn dashed")
	assert_eq(s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() <= 3 or not bool(x[3])).size(), 1, "and the one on it already solid, every blow it would take shown")
	s._on_hold_released()
	s.free()


## The reinforcements waiting, by rank (Ryan, 15 October; built 22 October): the formation's
## gutter counts the foes waiting for the front, for the back, and the massive ones that take a
## whole column; with the reserve empty it shows nothing.
func test_the_formation_counts_the_reinforcements_waiting_for_each_rank() -> void:
	var s := _screen()
	var sk := s.sk
	sk.reinforcements.clear()
	var archer := Foe.make("skeleton_archer", 30, 10)
	archer.prefers_back = true
	var big := Foe.make("revenant", 300, 10)
	big.size = 2
	sk.reinforcements.append_array([Foe.make("revenant", 30, 10), Foe.make("revenant", 30, 10), archer, big])
	s._refresh()
	assert_true(big.is_massive(), "a foe of size two is massive")
	assert_eq(s._reserve.counts, {"front": 2, "back": 1, "massive": 1}, "two for the front, one for the back, one massive")
	sk.reinforcements.clear()
	s._refresh()
	assert_eq(s._reserve.counts, {"front": 0, "back": 0, "massive": 0}, "the reserve empty: nothing to show")
	s.free()


## The Barrier and the Ward wear chips of their own, one colour parted by what sits inside the
## shield (21 October), and a dark entry shows its rounds left on the die and in the hold.
func test_the_barrier_and_the_ward_wear_chips_and_a_dark_entry_counts_its_rounds() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	Effects.grant_buff(ms.unit, "barrier", 1, "test", s.sk.round)
	Effects.grant_buff(ms.unit, "ward", 1, "test", s.sk.round)
	s._refresh()
	var rows := {}
	for r in s._mech_rows(0):
		rows[r[0]] = r
	assert_true(rows.has("barrier") and rows.has("ward"), "both chips: %s" % str(rows.keys()))
	assert_eq(rows["barrier"][3], Palette.SHIELD, "the Barrier in the shield's colour")
	assert_eq(rows["ward"][3], Palette.SHIELD, "and the Ward, parted from it by its glyph")
	Effects.disable_entry(ms.unit, ms.face_index, "cooldown", s.sk.round + 1)
	s._refresh()
	assert_eq(s._dice[0].dark, 2, "the die shows the entry dark with two rounds left")
	assert_true(s._entry_states(ms, ms.face_index).has("On Cooldown (2 turns left)"), "and so does the hold, in Ryan's words")
	Effects.disable_entry(ms.unit, ms.face_index, "foe:x", s.sk.round)
	s._refresh()
	assert_true(" · ".join(s._entry_states(ms, ms.face_index)).begins_with("Disabled"), "a foe's switch-off says so, cleansable")
	s.free()


## A stepping die (the Cassowary's, 21 October) shows its next chamber on the die and in the
## hold, and a machine that counts its shots shows the count as pips under the heat bar.
func test_a_stepping_die_shows_its_next_chamber_and_its_shot_count() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.grant_passive({"id": "test_step", "name": "Step", "description": "", "effects": [
		{"trigger": "static", "effect": "step_die", "value": 1},
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 2, "when": "nth_shot", "every": 6}]})
	Effects.stack(ms.unit, Effects.STATUS["shots"], Effects.SKIRMISH, "count", 5, Effects.DECAY_NONE)
	s._refresh()
	var n := ms.die.faces.size()
	assert_true(s._dice[0].next_face != null, "the die carries its next chamber")
	assert_eq(s._dice[0].next_face.kind, ms.die.faces[(ms.face_index + 1) % n].kind, "the one it steps to")
	assert_eq(s._mech_views[0].pips, [5, 6], "five shots of six: the sixth is next")
	for r in s._mech_rows(0):
		assert_false(str(r[2]).begins_with("Shots"), "the count is pips, never a chip")
	assert_true(s._dice[1].next_face == null, "a die that rolls shows none")
	assert_true(s._mech_views[1].pips.is_empty(), "nor pips")
	# The hold's cylinder (Ryan's ring, 19 October): every chamber in order, the one showing lit,
	# the arrow to the next; a die that rolls has none.
	s._on_die_held(0)
	assert_true(s._details_ring.visible, "the stepping die's hold shows its cylinder")
	assert_eq(s._details_ring.faces.size(), n, "every chamber on it")
	assert_eq([s._details_ring.current, s._details_ring.next], [ms.face_index, (ms.face_index + 1) % n], "the one showing lit, the arrow to the next")
	s._on_hold_released()
	s._on_die_held(1)
	assert_false(s._details_ring.visible, "a die that rolls shows no cylinder")
	s._on_hold_released()
	# The codex prints the order: its cylinder, no chamber lit and every gap's arrow, between fights.
	var entry := ContentDB.load_default().codex_for_unit(ms.unit)
	assert_true(bool(entry["steps"]), "the codex knows the die steps")
	assert_false(bool(ContentDB.load_default().codex_for_unit(s.sk.mechs[1].unit)["steps"]), "and that a die that rolls does not")
	var box := CodexBox.new()
	box.open(entry)
	assert_true(box._ring.visible and box._ring.faces.size() == n and box._ring.next == -1, "its cylinder, every gap's arrow")
	box.free()
	s.free()


## A Swap's two targets on the screen (Ryan, 21 October): drop the die on the first target and
## it waits there, the second targets lit; a tap on one spends it; dragging the die again picks
## it back up; a reroll or the turn's end sets it back in the tray first.
func test_a_swap_waits_on_its_first_target_for_a_tap_on_the_second() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.die.faces[ms.face_index] = Face.attack(0, Face.Reach.INDIRECT, [Face.Keyword.SWAP])
	var first: Foe = s.sk.targets_for(0)[0]
	s._begin_second(0, first)
	assert_eq(s._pending["primary"], first, "the die waits on its first target")
	assert_true(s._ghost.visible and s._ghost.can_drag, "shown there, and it can be picked back up")
	assert_eq(s._dice[0].modulate.a, 0.0, "its tray slot stands empty")
	var second = null
	for x in s.sk.swap_targets(first):
		if x is Foe:
			second = x
			break
	assert_true(second != null, "a second foe to swap with")
	var lit := false
	for v in s._view_foe.keys():
		if s._view_foe[v] == second:
			lit = v.highlight
	assert_true(lit, "the second targets light")
	var a := Vector2i(first.rank, first.column)
	var b := Vector2i(second.rank, second.column)
	s._on_slot_tapped(b.x, b.y)
	assert_true(s._pending.is_empty(), "a tap on the second spends it")
	assert_eq(Vector2i(first.rank, first.column), b, "and they trade places")
	assert_false(s._ghost.visible, "the die is gone from the field")
	s.free()
	var t := _screen()
	var tm: Skirmish.MechState = t.sk.mechs[0]
	tm.die.faces[tm.face_index] = Face.attack(0, Face.Reach.INDIRECT, [Face.Keyword.SWAP])
	t._begin_second(0, t.sk.targets_for(0)[0])
	t._on_ghost_drag_started()
	assert_true(t._pending.is_empty() and t._drag_from == 0, "dragging it again picks it back up")
	t._on_drag_ended(Vector2(-100, -100))
	assert_false(tm.assigned, "set back in the tray, unspent")
	t._begin_second(0, t.sk.targets_for(0)[0])
	t._on_reroll()
	assert_true(t._pending.is_empty(), "a reroll sets it back first")
	t.free()


## The Lammergeier's mines on the screen (21 October), on a synthetic passive: a weapon of the
## bay dragged lights the empty slots it may be spent on, a drop there lays the shot, and the
## mined slot shows its dashed outline and the mine chip with the total waiting; a hold reads it.
func test_a_weapon_of_the_bay_drops_on_an_empty_slot_and_the_slot_shows_its_mine() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.grant_passive({"id": "bay", "name": "Bay", "description": "", "effects": [{"trigger": "static", "effect": "lay_mines"}]})
	ms.die.faces[ms.face_index] = Face.attack(10, Face.Reach.INDIRECT, [Face.Keyword.BURN])
	ms.die.faces[ms.face_index].burn = 2
	var slots := s.sk.slot_targets(ms, ms.face())
	assert_false(slots.is_empty(), "an empty slot to lay in")
	var slot: Vector2i = slots[0]
	var sv: UnitView = s._slot_views[slot.x][slot.y]
	s._drag_from = 0
	s._refresh()
	assert_true(sv.highlight, "the empty slot lights while the weapon is dragged")
	assert_eq(s._drop_target_at(sv.get_global_rect().get_center()), slot, "and is a drop target")
	s._drag_from = -1
	assert_true(s._use_die(0, slot), "dropped there, the shot is laid")
	s._refresh()
	assert_true(sv.mined, "the slot shows its outline")
	assert_eq(sv.intent, "MINED", "and says so")
	assert_eq(sv.statuses[0][0], "mine", "the mine's chip first")
	assert_eq(sv.statuses[0][1], "10", "with the total waiting")
	assert_eq(sv.statuses[1][0], "burn", "then a chip per keyword riding in it")
	s._on_foe_held(sv)
	s.free()


## The Swallowtail's muster on the screen (21 October; never primed since 22 October), synthetic:
## the gauge under the heat with a notch a charge; with a charge up the die shows the charged
## form under its double frame, unasked, and a drop spends it and the muster; with none, the
## plain form.
func test_a_mustering_machines_die_shows_its_charged_form_when_a_charge_is_up() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.grant_passive({"id": "deck", "name": "Deck", "description": "", "effects": [{"trigger": "static", "effect": "muster", "value": 3, "cap": 2, "kill": 2}]})
	var flare := Face.attack(0, Face.Reach.INDIRECT, [Face.Keyword.EXPOSE])
	flare.charged = {"muster": 1, "keywords": ["suppress"]}
	ms.die.faces[ms.face_index] = flare
	Effects.remove(ms.unit, "muster")
	s._refresh()
	var bars: Array = s._mech_views[0].bars
	assert_eq(bars.size(), 4, "the Muster's gauge under the heat")
	assert_eq(int(bars[3][4]), 3, "a notch a charge")
	assert_false(s._dice[0].charged, "no charge: the plain form")
	assert_false(s._dice[0].face.has(Face.Keyword.SUPPRESS), "without its Suppress")
	Effects.stack(ms.unit, Effects.STATUS["muster"], Effects.SKIRMISH, "test", 3, Effects.DECAY_NONE)
	s._refresh()
	assert_true(s._dice[0].charged, "a charge up: the die says so")
	assert_true(s._dice[0].face.has(Face.Keyword.SUPPRESS), "and shows the charged form")
	var foe: Foe = s.sk.targets_for(0)[0]
	assert_true(s._use_die(0, foe), "dropped on a foe")
	assert_true(Effects.has(foe, "suppressed"), "the charged form lands")
	assert_eq(Effects.muster_charges(ms.unit), 0, "and the muster is spent")
	s.free()


## The Musk Ox's magazine on the screen (21 October), synthetic: a bar under the heat, a notch an
## ammo; the die prints a gun's price in ammo where its heat would be, DRY when it cannot pay.
func test_a_forging_machine_shows_its_magazine_and_each_guns_price() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.grant_passive({"id": "forge", "name": "Forge", "description": "", "effects": [{"trigger": "static", "effect": "forge", "value": 10, "start": 3, "per_round": 1, "per_heat": 10, "vent": 3, "shield": 2}]})
	ms.ammo_max = 10
	ms.ammo = 3
	var ray := Face.attack(30, Face.Reach.INDIRECT)
	ray.heat = 30
	ms.die.faces[ms.face_index] = ray
	s._refresh()
	var bars: Array = s._mech_views[0].bars
	assert_eq([int(bars[bars.size() - 1][0]), int(bars[bars.size() - 1][1])], [3, 10], "the magazine's bar")
	assert_eq(s._dice[0].face.ammo, 3, "the die prints the gun's price")
	assert_false(s._dice[0].face.dry, "which the magazine can pay")
	ms.ammo = 2
	s._refresh()
	assert_true(s._dice[0].face.dry, "and DRY when it cannot")
	s.free()

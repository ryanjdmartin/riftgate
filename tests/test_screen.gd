extends TestCase

## Drives the skirmish screen through its gesture and button handlers without a window, so a
## script error in the UI layer fails the suite instead of waiting for someone to tap it.


func _screen(seed_value: int = 3, massive: Foe = null) -> SkirmishScreen:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(seed_value)
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		sk.add_mech(db.make_mech(id))
	var ghouls := Unit.pack(1, "ghouls", Vector2i.ZERO, "marsh", 2, 4, "revenant")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var necros := Unit.pack(2, "necromancers", Vector2i.ZERO, "marsh", 2, 2, "ghost")
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
	assert_true(s._dice[0].can_tap and s._dice[0].can_drag, "dice read and drag in the same phase")
	s.free()


## A die takes a unit's gestures (Ryan, 30 October: "change lock/unlock to hold and double-tap,
## and tap to inspect for dice ... That way it's standard across the board"): a tap opens its
## readout and a tap again closes it, one readout at a time with the units'; a double-tap or a
## hold locks or unlocks it, the readouts left as they stand (its tap waits out the double-tap
## window, so a double-tap's first tap never lands); no codex.
func test_a_tap_reads_a_die_and_a_double_tap_or_a_hold_locks_it() -> void:
	var s := _screen()
	var d: DieFaceView = s._dice[0]
	assert_true(d.confirm_taps, "the tray's dice wait out the double-tap window")
	d.tapped.emit()
	assert_eq(s._pop, {"die": 0}, "a tap opens the die's readout")
	assert_true(s._details.visible and s._details_entry.visible, "shown, the entry's lines")
	assert_eq(s._details.fill_alpha, 1.0, "opaque over the log's lines")
	assert_false(s.locked[0], "and locks nothing")
	d.tapped.emit()
	assert_true(s._pop.is_empty() and not s._details.visible, "a tap on it again closes it")
	d.double_tapped.emit()
	assert_true(s.locked[0], "a double-tap locks")
	assert_true(d.locked, "the view shows the lock")
	assert_true(s._pop.is_empty() and not s._details.visible, "and opens no readout")
	assert_false(s._codex.visible, "no codex: the whole die is the machine's double-tap")
	d.double_tapped.emit()
	assert_false(s.locked[0], "a double-tap again unlocks")
	s._on_mech_tapped(1)
	d.double_tapped.emit()
	assert_eq(s._pop, {"mech": 1}, "a double-tap leaves the machine's readout open")
	assert_true(s.locked[0], "and locks")
	d.held.emit()
	assert_false(s.locked[0], "a hold unlocks")
	assert_eq(s._pop, {"mech": 1}, "and leaves the readout open")
	d.held.emit()
	assert_true(s.locked[0], "a hold again locks")
	s._close_pop()
	s._replay_shade.visible = true
	d.tapped.emit()
	assert_true(s._pop.is_empty(), "a tap landing late, as the enemy's turn replays, opens nothing")
	s._replay_shade.visible = false
	s._on_mech_double_tapped(0)
	d.tapped.emit()
	assert_true(s._pop.is_empty(), "nor one under a codex opened meanwhile")
	s._close_codex()
	s.free()


## The die's tap waits out the double-tap window (Ryan, 30 October), so a double-tap never shows a
## tap's work, and the face lights from the touch until the tap lands, so the beat never reads as
## lag; a tap and then a hold or a drag is the hold or the drag. Without the wait (the waiting
## Swap's die, whose double-tap does nothing) a tap lands at once.
func test_a_dies_tap_waits_out_the_double_tap_window_lit() -> void:
	var d := DieFaceView.new()
	d.confirm_taps = true
	var count := {"tap": 0, "double": 0, "held": 0, "drag": 0}
	d.tapped.connect(func() -> void: count["tap"] += 1)
	d.double_tapped.connect(func() -> void: count["double"] += 1)
	d.held.connect(func() -> void: count["held"] += 1)
	d.drag_started.connect(func() -> void: count["drag"] += 1)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.global_position = Vector2(50, 50)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.global_position = Vector2(50, 50)
	d._gui_input(press)
	assert_true(d._lit(), "lit the moment it is touched")
	d._gui_input(release)
	assert_eq(count["tap"], 0, "a tap waits out the window")
	assert_true(d._lit(), "the face lit while it waits")
	d._process(0.0)
	assert_eq(count["tap"], 0, "still waiting inside the window")
	d._tap_due = 0.0   # the window run out
	d._process(0.0)
	assert_eq(count["tap"], 1, "then it lands")
	assert_false(d._lit(), "and the light goes")
	d._last_tap_at = -10.0
	d._gui_input(press)
	d._gui_input(release)
	d._gui_input(press)
	d._gui_input(release)
	assert_eq(count["double"], 1, "two quick taps are a double-tap")
	d._tap_due = 0.0 if d._tap_due >= 0.0 else -1.0   # any tap still waiting, its window run out
	d._process(0.0)
	assert_eq(count["tap"], 1, "and its first tap never lands")
	d._last_tap_at = -10.0
	d._gui_input(press)
	d._gui_input(release)
	d._gui_input(press)
	d._press_at -= 1.0   # held past the hold's time
	d._process(0.0)
	d._gui_input(release)
	d._tap_due = 0.0 if d._tap_due >= 0.0 else -1.0   # any tap still waiting, its window run out
	d._process(0.0)
	assert_eq([count["held"], count["tap"]], [1, 1], "a tap and then a hold is the hold")
	d._last_tap_at = -10.0
	d._gui_input(press)
	d._gui_input(release)
	d._gui_input(press)
	var move := InputEventMouseMotion.new()
	move.global_position = Vector2(50, 90)
	d._gui_input(move)
	d._gui_input(release)
	d._tap_due = 0.0 if d._tap_due >= 0.0 else -1.0   # any tap still waiting, its window run out
	d._process(0.0)
	assert_eq([count["drag"], count["tap"]], [1, 1], "a tap and then a drag is the drag")
	d.confirm_taps = false
	d._last_tap_at = -10.0
	d._gui_input(press)
	d._gui_input(release)
	assert_eq(count["tap"], 2, "without the wait a tap lands at once")
	d.free()


func test_reroll_skips_locked_and_spent_dice() -> void:
	var s := _screen(11)
	s._toggle_lock(0)
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
		s._toggle_lock(i)
		assert_false(s.locked[i], "spent die no longer locks")
		assert_true(s._dice[i].can_tap, "but still reads with a tap")
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


## A unit's readout is a tap toggle, one unit's at a time (Ryan, 29 October: "Change the
## hold-press on player units and enemy units into a tap toggle, only one unit popup allowed at a
## time"): a tap opens it with the arrows that concern the unit, a tap on it again closes it, a
## tap on another unit or a die moves it there, a hold opens it and letting go keeps it, a tap on
## nothing closes it, and it is translucent so the arrows under it show.
func test_a_tap_toggles_a_units_readout() -> void:
	var s := _screen()
	var foe: Foe = s.sk.front[0]
	var v := s._foe_view_for(foe)
	s._on_foe_tapped(v, 0, 0)
	assert_true(s._details.visible, "a tap opens the foe's readout")
	assert_true(s._details.fill_alpha < 1.0, "translucent, the arrows under it showing")
	assert_eq(s._arrows.arrows.size(), 1, "with the arrow it brings")
	s._on_foe_tapped(v, 0, 0)
	assert_false(s._details.visible, "a tap on it again closes it")
	assert_eq(s._arrows.arrows.size(), 0, "and its arrow")
	s._on_foe_tapped(v, 0, 0)
	s._on_mech_tapped(1)
	assert_eq(s._pop, {"mech": 1}, "a tap on another unit moves it there, one at a time")
	var name := s.sk.mechs[1].unit.display_name.to_upper()
	assert_true(s._details_entry.text().begins_with(name), "the machine's readout")
	s._on_mech_held(1)
	assert_eq(s._pop, {"mech": 1}, "a hold on the same unit leaves it open")
	s._on_die_tapped(0)
	assert_eq(s._pop, {"die": 0}, "a tap on a die moves it to the die")
	assert_eq(s._details.fill_alpha, 1.0, "its readout opaque over the log")
	s._on_mech_tapped(1)
	assert_true(s._details.visible and s._details_entry.text().begins_with(name), "a tap on the machine moves it back")
	assert_true(s._details.fill_alpha < 1.0, "translucent again")
	s._refresh()
	assert_true(s._details.visible and s._details_entry.text().begins_with(name), "and it stays open as the fight refreshes")
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	s._gui_input(press)
	assert_false(s._details.visible, "a tap on nothing closes it")
	s._on_foe_held(v)
	assert_true(s._details.visible and s._pop == {"foe": foe}, "a hold opens it too")
	s._on_mech_double_tapped(0)
	assert_true(s._pop.is_empty() and not s._details.visible, "the codex takes over from it")
	s._close_codex()
	s._toggle_all_arrows(true)
	assert_true(s._arrows.arrows.size() >= 3, "eye shows every arrow")
	s.free()


## A machine's readout rests on its gauges (Ryan, 29 October: "Tighten the bottom of the player
## unit popups to the top of the unit's bounding box, just a bit").
func test_a_machines_readout_rests_on_its_gauges() -> void:
	var s := _screen()
	s._on_mech_tapped(0)
	var v: UnitView = s._mech_views[0]
	var bottom := s._details.position.y + s._details.size.y
	var top := v.position.y + v.drawn_top()
	assert_true(top - bottom >= 0.0 and top - bottom <= SkirmishScreen.POP_GAP + 0.5, "its foot just over the unit's gauges: %.1f over %.1f" % [bottom, top])
	s.free()


## A unit's hold (Ryan, 26 October: "a similar format as the hold press on the die, showing
## resource bars with numbers and modification up/downs if they exist, a list of all chips on
## the unit, and for enemies their current intent in the same format as the die hold press for
## a component"): its name, its gauges with their numbers, a maximum something moved coloured
## with its arrow, its stats as base (change), every chip with what it does; a foe's intent a
## line a mark, the machine it is aimed at named and its blow read against its own, the colours
## the unit's ("Positive and negative are always relative to the unit, not the player").
func test_a_units_hold_reads_its_gauges_its_chips_and_a_foes_intent() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(5))
	m.grant_passive({"id": "t_plate", "name": "Plate", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 10}]})
	sk.add_mech(m)
	var foe := Foe.make("revenant", 30, 4)
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.grant_buff(m, "overcharged", 2, "buff", sk.round)
	s._refresh()
	s._on_mech_held(0)
	assert_true(s._details_entry.visible and not s._details_label.visible, "the readout's lines, no text block")
	var lines: Array = s._details_entry.lines
	assert_eq(str(lines[0]["text"]), m.display_name.to_upper(), "its name first")
	var gauges := {}
	var chips: Array[String] = []
	for l in lines:
		if str(l["style"]) == "bar":
			gauges[str(l["label"])] = l
		elif str(l["style"]) == "chip":
			chips.append(str(l["text"]))
	assert_eq(gauges.keys(), ["Shield", "Hull", "Heat"], "its three gauges, as on the field")
	assert_eq(str(gauges["Hull"]["text"]), "Hull %d/%d" % [m.hull, m.hull_max], "each with its numbers")
	var top: Dictionary = gauges["Hull"]["parts"][1]
	assert_eq([int(top["trend"]), bool(top["gain"])], [1, true], "a maximum the passive raised: up, the machine's gain")
	assert_eq(int(gauges["Shield"]["parts"][1]["trend"]), 0, "one nothing moved: plain")
	assert_true(s._details_entry.text().contains("Armour %d · Cooling %d" % [m.armour, m.cooling]), "its armour and cooling as stats, nothing moved: %s" % s._details_entry.text())
	assert_false(s._details_entry.text().contains("breaks the shield"), "no shield-break warning: the gauges preview the blows")
	assert_true(chips.any(func(c: String) -> bool: return c.begins_with("Empowered")), "every chip listed with what it does: %s" % str(chips))
	# A foe: its HP, its attack a rally raised (the foe's gain: up and green), its intent.
	Effects.grant_for_rounds(foe, Effects.kindled(2), "test", sk.round + 1)
	s._refresh()
	s._on_foe_held(s._foe_view_for(foe))
	var said := s._details_entry.text()
	assert_true(said.begins_with(foe.display_name.to_upper()), "its name first: %s" % said)
	assert_true(said.contains("HP %d/%d" % [foe.hp, foe.hp_max]), "its HP with its numbers")
	assert_true(said.contains("Attack %d (+2▲)" % foe.attack), "its attack as a stat, the change the rally made beside it: %s" % said)
	var flines: Array = s._details_entry.lines
	var at := -1
	for k in range(flines.size()):
		if str(flines[k]["text"]) == "INTENT":
			at = k
	assert_true(at > 0, "its intent under a caption")
	assert_eq(str(flines[at + 1]["text"]), str(foe.action.get("name", "")).to_upper(), "the move's name heads it")
	assert_eq(str(flines[at + 2]["text"]), "Attack %d" % foe.damage(), "its blow as it will land")
	var blow: Dictionary = flines[at + 2]["parts"][1]
	assert_eq([int(blow["trend"]), bool(blow["gain"])], [1, true], "harder than its own: the foe's gain, relative to the unit")
	assert_eq(str(flines[at + 3]["text"]), "Target: %s" % foe.target.unit.display_name, "the machine it is aimed at, named")
	s.free()


## The die's readout, a tap (Ryan, 25 October: "only show the visible component"; 26 October: "it just
## turns the iconography into text"): the entry showing, alone, as a list in the order a spend
## runs it: its place and name from content, its number as the die prints it, its heat, its
## target, its keywords, its own rules, then its tags. A number the live sources moved off the
## component's own is coloured, never its sources listed: green where it is good for the unit,
## the red-red where it is bad, an arrow on the number for which way. The whole die is the
## codex's.
func test_a_dies_readout_shows_the_entry_showing_with_its_effects_listed() -> void:
	var s := _screen()
	var db := ContentDB.load_default()
	var ms: Skirmish.MechState = s.sk.mechs[1]
	var gun := Face.attack(3, Face.Reach.SWEEP, [Face.Keyword.CLEAVE, Face.Keyword.BURN], 3)
	gun.burn = 2
	gun.cleave = 2
	gun.strikes = 2
	gun.component = str(db.components.keys()[0])
	gun.tags.append_array(["beam", "flame"])
	ms.die = Die.single(gun)
	ms.face_index = 0
	ms.unit.grant_passive({"id": "t_amp", "name": "Test Amp", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 2}]})
	s._refresh()
	s._on_die_tapped(1)
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
	assert_eq(texts, [texts[0], "Attack %d ×2" % n, "Heat %d" % sf.heat, "Target: A rank, Sweep", "Spread 2", "Apply Burn 2 on hit", "Tags: Beam, Flame"],
		"a line a mark on the die, in the order a spend runs it, its numbers as the die prints them, and no source listed: %s" % str(texts))
	var attack: Array = lines[1]["parts"]
	assert_eq([int(attack[1]["trend"]), bool(attack[1]["gain"])], [1, true], "the blow moved up by the passive, the machine's gain: coloured, never explained")
	assert_eq(int(attack[2]["trend"]), 0, "its strikes its own: plain")
	assert_eq(int(lines[2]["parts"][1]["trend"]), 0, "the heat its own: plain")
	assert_eq(EntryReadout.trend_ink(attack[1]), Palette.GAIN, "a gain in the gain's green")
	assert_true(s._details_entry.text().contains("%d▲ ×2" % n), "the arrow on the number that moved and no other: %s" % s._details_entry.text())
	assert_true(s._details_entry.custom_minimum_size.y > 100.0, "sized to its lines: %s" % str(s._details_entry.custom_minimum_size))
	assert_true(s._details.size.y >= s._details_entry.custom_minimum_size.y, "and the panel to it")
	s._on_die_tapped(1)
	assert_false(s._details.visible, "a tap again hides it")
	# A heat a passive raised is bad for the machine: the red-red, its arrow up.
	ms.unit.grant_passive({"id": "t_hot", "name": "Test Hot", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_heat", "value": 2}]})
	s._on_die_tapped(1)
	var heat: Dictionary = {}
	for l in s._details_entry.lines:
		if str(l["text"]).begins_with("Heat"):
			heat = l["parts"][1]
	assert_eq([int(heat.get("trend", 0)), bool(heat.get("gain", true))], [1, false], "more heat than the component's own: a loss")
	assert_eq(EntryReadout.trend_ink(heat), Palette.LOSS, "in the red-red, harm to its unit")
	s._on_die_tapped(1)
	s.free()


## The readout says what kind of piece the entry is on its machine, a passive's hybrid in (Ryan, 26
## October: the Whip Scorpion's vents are "vent, weapon" on that machine, shown on the readout and
## never in the codex, which shows the component as built).
func test_the_readout_names_the_entrys_type_with_a_passives_hybrid() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[1]
	var vent := Face.vent(4)
	vent.component = str(ContentDB.load_default().components.keys()[0])
	ms.die = Die.single(vent)
	ms.face_index = 0
	s._refresh()
	s._on_die_tapped(1)
	assert_eq(str(s._details_entry.lines[0]["type"]), "Vent", "a vent is a vent")
	s._on_die_tapped(1)
	ms.unit.grant_passive({"id": "t_blast", "name": "Test Blast", "description": "", "effects": [{"trigger": "static", "effect": "vent_blast", "value": 1.0}]})
	s._on_die_tapped(1)
	assert_eq(str(s._details_entry.lines[0]["type"]), "Vent, Weapon", "on a machine whose vents blast, a weapon too")
	s._on_die_tapped(1)
	var rows := EntryReadout.codex_lines(vent, ContentDB.load_default())
	assert_eq(str(rows[0]["type"]), "Vent", "the codex keeps the component as built")
	s.free()


## A split weapon (the Skua's breech) prints a smaller blow struck more often: each number its own
## arrow, the blow down and the strikes up (Ryan, 26 October: "Skua should have down on the damage
## and up on the count").
func test_a_split_weapon_reads_its_blow_down_and_its_strikes_up() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[1]
	var breech := Face.attack(4, Face.Reach.DIRECT, [], 1)
	breech.component = str(ContentDB.load_default().components.keys()[0])
	ms.die = Die.single(breech)
	ms.face_index = 0
	ms.unit.grant_passive({"id": "t_split", "name": "Test Split", "description": "", "effects": [{"trigger": "on_attack", "effect": "split_strikes", "value": 2}]})
	s._refresh()
	s._on_die_tapped(1)
	var parts: Array = s._details_entry.lines[1]["parts"]
	assert_eq(str(s._details_entry.lines[1]["text"]), "Attack 2 ×2", "a strike's share of the number, struck twice: %s" % str(s._details_entry.lines[1]["text"]))
	assert_eq([int(parts[1]["trend"]), bool(parts[1]["gain"])], [-1, false], "the blow down, a loss")
	assert_eq([int(parts[2]["trend"]), bool(parts[2]["gain"])], [1, true], "the strikes up, a gain")
	assert_true(s._details_entry.text().contains("2▼ ×2▲"), "each arrow on its own number: %s" % s._details_entry.text())
	s._on_die_tapped(1)
	s.free()


## The codex's row for a component (Ryan, 26 October): its name with its tags beside it, then
## the hold's lines joined into three, its attributes, its keywords and its own rules, at the
## component's own numbers whatever moves them in the fight; a line with nothing to say is left
## out. The plate lays the die out a row a component, one column.
func test_the_codex_row_joins_the_holds_lines_into_three() -> void:
	var db := ContentDB.load_default()
	var gun := Face.attack(3, Face.Reach.SWEEP, [Face.Keyword.CLEAVE, Face.Keyword.BURN, Face.Keyword.RAPID], 3)
	gun.burn = 2
	gun.cleave = 2
	gun.strikes = 2
	gun.component = str(db.components.keys()[0])
	gun.tags.append_array(["beam", "flame"])
	var lines := EntryReadout.codex_lines(gun, db, ["Test: a passive's line."])
	var texts: Array[String] = []
	for l in lines:
		texts.append(str(l["text"]))
	assert_eq(texts, [db.component_name(gun.component).to_upper(), "Attack 3 ×2 · Heat 3 · Target: A rank, Sweep", "Spread 2 · Apply Burn 2 on hit · Rapid", "Test: a passive's line."],
		"its name, its attributes, its keywords, its rules: %s" % str(texts))
	assert_eq([str(lines[0]["type"]), str(lines[0]["tags"])], ["Weapon", "Beam, Flame"], "its type, then its tags, beside its name")
	var types := {}
	var debuff := Face.attack(0, Face.Reach.INDIRECT, [Face.Keyword.SUPPRESS])
	for f in [gun, Face.shield(4), Face.vent(3), Face.buff("overcharged", 1), debuff]:
		types[EntryReadout.face_type(f)] = true
	assert_eq(types.keys(), ["Weapon", "Shield", "Vent", "Equipment"], "a weapon, a shield, a vent; a buff and a debuff are equipment (Ryan, 26 October)")
	var shield := Face.shield(6)
	shield.targets = Face.Target.SELF
	var plain: Array[String] = []
	for l in EntryReadout.codex_lines(shield, db):
		plain.append(str(l["text"]))
	assert_eq(plain.slice(1), ["Shield 6 · Target: Self"] as Array[String], "a line with nothing to say is left out")
	for l in lines:
		for p in l.get("parts", []):
			assert_eq(int(p.get("trend", 0)), 0, "the codex reads the component as built: nothing moved")


## Equipment says whom it is spent on, in Ryan's words; a debuff prints no number; a gated rider
## says where it lands; a written-out grant prints its passive's line (the star's text).
func test_the_hold_reads_shields_debuffs_buffs_and_grants() -> void:
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
	assert_eq(str(EntryReadout.lines_for(wreck, 2, -1, wreck, [], [], db)[0]["text"]), db.component_name(wreck.component).to_upper(), "its name still the title")
	var coil := Face.buff("overcharged", 2)
	assert_eq(str(EntryReadout.effects_of(coil)[0]["text"]), "Grants %s ×2" % str(Effects.STATUS["overcharged"]["name"]), "a buff grants its status")
	var u := Unit.new()
	u.grant_passive({"id": "t_spill", "name": "Spill", "description": "Damage past a kill spills behind.", "effects": [{"trigger": "static", "effect": "grant_keyword", "value": "spillover", "printed": true}]})
	var gun := Face.attack(4)
	assert_eq(Effects.printed_grants(u, gun), ["Damage past a kill spills behind."], "a written-out grant is its passive's line")
	assert_eq(str(EntryReadout.lines_for(gun, 1, -1, gun, [], Effects.printed_grants(u, gun), db).back()["text"]), "Damage past a kill spills behind.", "among the rules, last")


## The keywords list (Ryan, 26 October): the pause menu's page, every term the dice and the chips
## print, by kind, each with its codex line; nothing planned shows.
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
	# A term in shown text takes a tap for its own line, so the list lives in the menu alone (Ryan,
	# 30 October: "And yes remove keywords button").
	for c in s.get_children():
		assert_false(c is HudButton and (c as HudButton).text == "KEYWORDS", "no KEYWORDS button on the field")
	s._open_menu()
	assert_eq(s._menu._page, "paused", "MENU opens on PAUSED")
	s._menu._show_page("keywords")
	assert_true(s._menu._list != null and s._menu._list.get_child(0).get_child_count() > 20, "its KEYWORDS page from there, the list built")
	s._menu.close()
	assert_false(s._menu.visible, "and it closes back to the fight")
	s.free()


## The rules the hold lists last are the ones the entry prints, word for word, for every
## component in content and its charged form; a piece reaching every ally never says it
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
			assert_false(f.describe().contains("reaches every foe"), "%s, spent on machines, reaches no foe: %s" % [cid, f.describe()])
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
	assert_eq(Face.attack(10, Face.Reach.DIRECT).describe(), "10", "line of fire goes unsaid")
	assert_true(Face.attack(20, Face.Reach.INDIRECT).describe().begins_with("indirect 20"), "indirect is called out")


func test_double_tap_opens_and_closes_the_codex() -> void:
	var s := _screen()
	var foe: Foe = s.sk.front[0]
	s._on_foe_double_tapped(s._foe_view_for(foe))
	assert_true(s._codex.visible, "codex opens for a foe")
	assert_eq(s._codex._title.text, foe.display_name, "titled with the foe's name")
	assert_eq(s._codex._sub.text, "THE MARSH", "the domain's name as the subtitle")
	assert_true(not s._codex._body.text().is_empty(), "foe codex text present")
	assert_true(s._codex._moves.visible and s._codex._moves.text().contains("CLAW"), "implemented moves listed")
	assert_true(s._codex._moves.text().contains("a kin standing"), "the swarm is said too")
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
	var shown := s._codex._passives.text().to_lower()
	assert_true(not passive_name.is_empty() and shown.contains(passive_name), "by its name from content")
	var first: Dictionary = s._codex._passives.lines[0]
	assert_eq(first.get("ink", Color.BLACK), Palette.INK, "the chassis's own passive first, in ink (Ryan, 30 October: \"the passive line can go in normal colour\")")
	assert_true(s._codex._faces.visible and s._codex._faces.get_child_count() == s.sk.mechs[2].die.faces.size(), "a row an entry, one column")
	s._close_codex()
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
				s._use_die(i, s.sk.machine_targets_for(ms, f)[0])
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
	var ghouls := Unit.pack(1, "ghouls", Vector2i.ZERO, "marsh", 2, 4, "revenant")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var necros := Unit.pack(2, "necromancers", Vector2i.ZERO, "marsh", 2, 4, "ghost")
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
	var text := s._details_entry.text()
	assert_false(text.contains("INTENT") or text.contains("Target:"), "the hold lists no intent and names no target: %s" % text)
	assert_true(text.contains("Suppressed"), "its Suppressed chip says what it does this round")
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


## Every status is a chip whatever its scope (Ryan, 16 October: the Ammit is Empowered, "so
## anything that interacts with overcharged needs it displayed"). The talons' kills'
## Empowered, kept for the battle when its owner keeps the status, is a chip with its count;
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
	assert_true(Effects.keeps(m, "overcharged"), "the machine keeps Empowered")
	sk._overcharge_on_kill(sk.mechs[0], sk.front[0], 1)
	sk._overcharge_on_kill(sk.mechs[0], sk.front[0], 1)
	var scopes: Array = []
	for d in Effects.describe(m):
		if str(d[5]) == "overcharged":
			scopes.append(int(d[3]))
	assert_eq(scopes, [Effects.BATTLE], "two kills kept for the battle: one grant, below the skirmish's scope")
	s._refresh()
	assert_eq(_chips_for(s, 0, "overcharged"), ["×2"] as Array[String], "an Empowered chip with its count")
	Effects.grant_buff(m, "overcharged", 1, "buff", sk.round)
	s._refresh()
	assert_eq(_chips_for(s, 0, "overcharged"), ["×3"] as Array[String], "a buff's for the round joins it in one chip")
	var held := 0
	for l in s._mech_hold_lines(0):
		if str(l["style"]) == "chip" and str(l["text"]).begins_with("Empowered"):
			held += 1
	assert_eq(held, 1, "the hold lists it once")
	var named := 0
	for note in Effects.explain(m, m.die.faces[0]):
		if note.contains("Empowered"):
			named += 1
	assert_eq(named, 1, "the die's row names it once")
	var listed := 0
	for e in db.codex_for_unit(m)["effects"]:
		if str(e["name"]).begins_with("EMPOWERED"):
			listed += 1
			assert_eq([str(e["name"]), str(e["note"])], ["EMPOWERED ×3", "KEPT FOR THE BATTLE"], "a kept status among the active effects, never a reward, with its count, the buff's stack kept with the kills' (Ryan, 18 October)")
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


## A rally on its way (Ryan, 26 October: "The intents should take into account incoming buffs.
## They should have a pulsing version of the incoming buff as a preview chip"): the foe after the
## rallier shows its lifted blow and wears the preview chip, the rallier none, and both go the
## moment the rallier falls.
func test_an_incoming_rally_lifts_the_intent_and_wears_a_preview_chip_until_the_rallier_falls() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(500, Face.Reach.DIRECT))
	sk.add_mech(m)
	var lord := Foe.make("revenant", 30, 50)
	var howl := {"id": "howl", "name": "Howl", "kind": "buff", "effect": "rally", "value": 5, "weight": 1, "text": ""}
	lord.actions = [Foe.basic_action(), howl]
	var g := Foe.make("revenant", 300, 10)
	sk.add_foes([lord, g])
	var s := SkirmishScreen.new()
	s.setup(sk)
	lord.action = howl
	s._refresh()
	var v := s._foe_view_for(g)
	assert_eq(v.intent_value, 15, "the intent shows the blow lifted by the Howl on its way")
	var previews: Array = []
	for st in v.statuses:
		if st.size() >= 4 and str(st[3]) == "preview":
			previews.append(st)
	assert_eq(previews.size(), 1, "and one preview chip says why")
	if previews.size() == 1:
		assert_eq(str(previews[0][1]), "+5", "at the rally's value")
	for st in s._foe_view_for(lord).statuses:
		assert_false(st.size() >= 4 and str(st[3]) == "preview", "the rallier wears none")
	s._use_die(0, lord)
	assert_false(lord.alive(), "the rallier falls")
	v = s._foe_view_for(g)
	assert_eq(v.intent_value, 10, "the intent drops at once")
	for st in v.statuses:
		assert_false(st.size() >= 4 and str(st[3]) == "preview", "and the chip goes")
	s.free()


## Every status on its way wears a pulsing preview chip (Ryan, 26 October: "All incoming chips
## should appear as pulsing opacity versions"): the Shocked a Retaliate will put on the foe that
## strikes the bare hull, the Burning its rider leaves on the machine; a foe the round kills wears
## its skull and no chips on the way.
func test_every_status_on_its_way_wears_a_preview_chip() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.blank())
	m.shield = 0
	sk.add_mech(m)
	var g := Foe.make("revenant", 300, 4)
	g.actions[0]["keywords"] = ["burn"]
	g.actions[0]["burn"] = 2
	sk.add_foes([g])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.grant_for_rounds(m, Effects.STATUS["retaliate"], "test", sk.round)
	g.target = sk.mechs[0]
	s._refresh()
	var previews: Array = s._foe_view_for(g).statuses.filter(func(st) -> bool: return st.size() >= 4 and str(st[3]) == "preview")
	assert_eq(previews.size(), 1, "the foe wears one chip on its way")
	if previews.size() == 1:
		assert_eq(str(previews[0][0]), "shocked", "the Shocked the Retaliate lands")
		assert_eq(str(previews[0][1]), "", "a status that renews shows no count")
	var mine: Array = s._mech_rows(0).filter(func(r) -> bool: return r.size() >= 5 and str(r[4]) == "preview")
	assert_eq(mine.size(), 1, "the machine wears one")
	if mine.size() == 1:
		assert_eq(str(mine[0][0]), SkirmishScreen.status_glyph("burning_mech"), "the Burning its rider leaves")
		assert_eq(str(mine[0][1]), "+2", "two stacks")
	# A foe the die in hand kills with a Burn weapon wears the skull and the Burn coming, both
	# (Ryan, 26 October: "It should be in addition ... some of those chips might be the cause").
	var torch := Face.attack(1, Face.Reach.DIRECT, Face.Keyword.BURN)
	torch.burn = 3
	m.die = Die.single(torch)
	sk.mechs[0].die = m.die
	sk.mechs[0].face_index = 0
	g.hp = 1
	s._drag_from = 0
	s._drag_over = g
	s._refresh()
	var rows := s._foe_rows(g)
	assert_true(rows.any(func(r) -> bool: return str(r[0]) == "skull" and str(r[1]) == ""), "over it, it wears the skull")
	assert_true(rows.any(func(r) -> bool: return r.size() >= 5 and str(r[4]) == "preview" and str(r[0]) == "burn"), "and the Burn on its way beside it")
	s._drag_from = -1
	s._drag_over = null
	s.free()


## A buff a purge put to sleep (28 October) wears its chip asleep on the machine, its hold line
## saying so, until the player's turn wakes it; the machine's view carries each row's style, so
## a chip on its way pulses there as on a foe.
func test_a_buff_a_purge_put_to_sleep_wears_its_chip_asleep() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.blank())
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 1)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	var seal := Effects.stack(m, Effects.sealed_status(3, 2), Effects.SKIRMISH, "seal", 1, Effects.DECAY_NONE)
	var r := Effects.purge(m)
	assert_eq(r["slept"], ["Sealed"], "the seal sleeps")
	s._refresh()
	var rows: Array = s._mech_rows(0).filter(func(row) -> bool: return row.size() >= 5 and str(row[4]) == "asleep")
	assert_eq(rows.size(), 1, "one chip asleep")
	if rows.size() == 1:
		assert_true(str(rows[0][2]).contains("asleep until your turn"), "its hold line says so")
	var kinds: Array = s._mech_views[0].statuses.map(func(st) -> String: return str(st[3]) if st.size() >= 4 else "")
	assert_true(kinds.has("asleep"), "and the machine's view draws it asleep")
	Effects.wake(m)
	s._refresh()
	assert_true(s._mech_rows(0).all(func(row) -> bool: return row.size() < 5 or str(row[4]) != "asleep"), "awake, it is a plain chip again")
	assert_true(seal != null, "the seal was granted")
	s.free()


## The four buffs a foe's specials grant (the ladder's brief, B; 28 October) wear the machines'
## chips on a foe, each its own mark: Primed's lit flame never the team's Burning's hollow one,
## Regenerating's heart never Getting Back Up's star, the Barrier's wall and the Ward's struck ring.
func test_a_foes_four_buffs_wear_their_own_chips() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(10))
	sk.add_mech(m)
	var foe := Foe.make("revenant", 300, 10)
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(foe, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 2)
	Effects.stack(foe, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:revenant", 1, Effects.DECAY_NONE)
	Effects.grant(foe, Effects.primed_foe(2, "foe:caster"))
	Effects.stack(foe, Effects.foe_barrier(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	Effects.stack(foe, Effects.foe_ward(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	Effects.grant(foe, Effects.regenerating(4))
	var by := {}
	for r in s._foe_rows(foe):
		by[str(r[0])] = r
	for g in ["primed", "barrier", "ward", "regenerating"]:
		assert_true(by.has(g), "a %s chip" % g)
	assert_true(by.has("burn") and by.has("star"), "beside the Burning and the Getting Back Up, each its own")
	if by.has("primed"):
		assert_eq(str(by["primed"][1]), "×2", "Primed counts its stacks")
		assert_true(str(by["primed"][2]).contains("2 Burning"), "and says what its move leaves")
	if by.has("regenerating"):
		assert_eq(str(by["regenerating"][1]), "+4", "Regenerating its regrowth")
		assert_true(str(by["regenerating"][2]).contains("3 actions to go"), "and its clock")
	if by.has("barrier"):
		assert_true(str(by["barrier"][2]).contains("weapon"), "a foe's Barrier says a weapon's blow pops it")
	assert_eq(SkirmishScreen.status_glyph("primed"), "primed", "the same chip on a machine")
	s.free()


## A foe whose machine falls before it acts strikes the pick it will make (26 October: no pick is
## open): its own arrow stays on its pick, the intent whatever reads it still needs, and a second,
## dashed the way a lure's turn is drawn, goes to the machine its blow lands on.
func test_a_foe_whose_machine_falls_first_draws_its_arrow_dashed_to_the_machine_it_will_strike() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var a := db.make_mech("badger")
	a.die = Die.single(Face.blank())
	a.shield = 0
	a.hull = 1
	sk.add_mech(a)
	var b := db.make_mech("clydesdale")
	b.die = Die.single(Face.blank())
	sk.add_mech(b)
	var big := Foe.make("revenant", 300, 20)
	var small := Foe.make("revenant", 300, 7)
	sk.add_foes([big, small])
	var s := SkirmishScreen.new()
	s.setup(sk)
	s.show_all_arrows = true
	big.target = sk.mechs[0]
	small.target = sk.mechs[0]
	s._refresh()
	var dashed := s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3]))
	var solid := s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() <= 3)
	assert_eq(solid.size(), 2, "both intents, solid")
	assert_eq(dashed.size(), 1, "and the second's dashed to the machine it will strike")
	assert_eq(int(s._mech_views[1].bars[1][3]), b.hull - 7 + mini(b.shield, 7) if b.shield < 7 else b.hull, "whose gauge reads the blow")
	s.free()


## A foe's ticks preview on its gauge (Ryan, 26 October: Burning and the other ticks are static
## numbers, "so a hypothetical death at the start of the enemy's turn could be previewed"): the HP
## its Burning will take at its action is the gauge's pending loss, the whole bar when it kills it
## before it acts, which the machines' forecast already reads.
func test_a_foes_gauge_previews_what_its_ticks_will_take() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(1, Face.Reach.DIRECT))
	sk.add_mech(m)
	var a := Foe.make("revenant", 10, 2)
	var b := Foe.make("revenant", 3, 2)
	sk.add_foes([a, b])
	var s := SkirmishScreen.new()
	s.setup(sk)
	assert_eq(int(s._foe_view_for(a).bars[0][3]), 10, "nothing ticking: no change pending")
	var per := Effects.status_value("burning", "tick_hp")
	Effects.stack(a, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 2)
	Effects.stack(b, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 4)
	s._refresh()
	assert_eq(int(s._foe_view_for(a).bars[0][3]), 10 - 2 * per, "its Burning's tick pending on its gauge")
	assert_eq(int(s._foe_view_for(b).bars[0][3]), 0, "Burning that kills it before it acts: the whole bar")
	assert_eq(sk.hp_after_ticks(b), 0, "the same number the forecast reads")
	sk.end_round()
	assert_false(b.alive(), "and it burnt to death at its action")
	assert_eq(a.hp, 10 - 2 * per, "the other took what its gauge showed")
	s.free()


## A foe the round will kill wears the machines' destroyed chip and keeps its intent (Ryan, 26
## October: "Intent of a foe thats dying should absolutely NOT lose its intent ... It should get a
## destroyed chip same as the player"); a Burn hit enough to kill it shows the fall at once, and a
## foe a Cure will heal shows the heal coming on its gauge.
func test_a_foe_the_round_kills_wears_the_destroyed_chip_and_keeps_its_intent() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(1, Face.Reach.DIRECT, [Face.Keyword.BURN]))
	sk.add_mech(m)
	var cleric := Foe.make("revenant", 500, 20)
	var cure := {"id": "cure", "name": "Cure", "kind": "defend", "effect": "regrow_ally", "value": 3, "weight": 1, "text": ""}
	cleric.actions = [Foe.basic_action(), cure]
	var a := Foe.make("revenant", 3, 2)
	sk.add_foes([cleric, a])
	var s := SkirmishScreen.new()
	s.setup(sk)
	cleric.action = Foe.basic_action()
	s._refresh()
	var skulls := func(v: UnitView) -> int:
		return v.statuses.filter(func(st) -> bool: return str(st[0]) == "skull").size()
	assert_eq(skulls.call(s._foe_view_for(a)), 0, "standing through the round: no skull")
	Effects.stack(a, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 5)
	s._refresh()
	var v := s._foe_view_for(a)
	assert_eq(skulls.call(v), 1, "its Burning kills it at its action: the destroyed chip")
	assert_eq(v.intent_kind, "attack", "its intent kept")
	assert_eq(int(v.bars[0][3]), 0, "and the whole bar pulsing")
	Effects.remove(a, "burning")
	a.hp = 1
	cleric.action = cure
	s._refresh()
	v = s._foe_view_for(a)
	assert_eq(int(v.bars[0][3]), 3, "the Cure's heal coming, shown on its gauge before it lands")
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
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	Settings.display["skirmish_controls"] = "middle"   # the controls between the sides: a desk machine may have saved them at the bottom
	var s := _screen()
	assert_true(s._eye.position.y >= s.LOG_Y - 10.0, "the eye sits in the black under the foes' ground")
	assert_true(s._switch.position.x + s._switch.size.x <= s._eye.position.x and s._switch.position.y == s._eye.position.y, "the controls' switch beside it")
	assert_true(s._log_scroll.position.x + s._log_scroll.size.x <= s._switch.position.x, "the log strip stops short of them")
	var glass: Rect2 = s._bg.glass[0]
	assert_true(glass.encloses(s._eye.get_rect()) and glass.encloses(s._switch.get_rect()), "both inside the log's glass (Ryan, 29 October: they did not fit it)")
	var seam := s.REROLL_Y + SkirmishScreen.REROLL_SIZE.y + SkirmishScreen.REROLL_GAP
	assert_true(seam <= s.MECH_Y, "Reroll clear of the machines' row")
	assert_true(s.DIE_Y >= s.LOG_Y + SkirmishScreen.LOG_H, "the dice sit under the log")
	s.free()
	Settings.display["skirmish_controls"] = was


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


## The predator sense (the funnel-web, 18 October): while an ambusher's die is read or dragged
## the foes' ground dims and the foes its entry can reach that show no intent on it are marked;
## and a webbed or acid-eaten foe wears its chip, the web's pointing at the neighbour it catches.
func test_the_predator_sense_marks_the_foes_looking_away_while_the_die_is_read_or_dragged() -> void:
	var ambush := {"id": "ambush_t", "name": "Ambush", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1, "when": "target_no_intent", "damaging": true}]}
	var s := _screen(7)
	var i := 0
	var ms: Skirmish.MechState = s.sk.mechs[i]
	for k in range(ms.die.faces.size()):
		if ms.die.faces[k].is_weapon():
			ms.face_index = k
			break
	assert_true(ms.face().is_weapon(), "the first machine shows a weapon")
	ms.unit.grant_passive(ambush)
	for foe in s.sk.field_foes():
		foe.target = s.sk.mechs[1]
	s._refresh()
	assert_false(s._prey.on, "off until the die is read or dragged")
	var reach := s.sk.targets_for(i)
	assert_true(reach.size() >= 2, "foes in reach to mark")
	s._on_die_tapped(i)
	assert_true(s._prey.on, "on while the die's readout is open")
	assert_eq(s._prey.marks.size(), reach.size(), "every foe in reach looks at another machine: every one marked")
	s._on_die_tapped(i)
	assert_false(s._prey.on, "off when it closes")
	var t: Foe = reach[0]
	t.target = ms
	s._on_drag_started(i)
	assert_true(s._prey.on, "on while the die is dragged")
	assert_eq(s._prey.marks.size(), reach.size() - 1, "the foe that turned on it loses its eyes")
	assert_false(s.prey_for(i).has(t), "the read is the foe's intent on the machine")
	s._on_drag_ended(Vector2(-100, -100))
	assert_false(s._prey.on, "off when the drag ends")
	assert_true(s.prey_for(1).is_empty(), "a machine without the read marks nothing")
	# The read asks for a weapon's hit, so a debuff showing marks nothing (26 October: a debuff
	# is equipment, and "hitting a foe with a weapon" passes it by).
	var kept := ms.die
	ms.die = Die.single(Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"]}))
	ms.face_index = 0
	assert_true(ms.face().is_debuff(), "the machine shows a debuff")
	assert_true(s.prey_for(i).is_empty(), "a debuff marks no prey for a rule that asks for a weapon's hit")
	assert_false(s.prey_for(i, true).is_empty(), "the debug switch marks for anything aimed at a foe")
	ms.die = kept
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
	s._on_die_tapped(0)
	assert_true(s._prey.on and s._prey.style == "blast", "read: the blast's rings")
	assert_eq(s._prey.marks.size(), 2, "on every live foe")
	assert_true(s._prey.labels.has("20") and s._prey.labels.has("15"), "each with what it would deal there, armour off: %s" % str(s._prey.labels))
	s._on_die_tapped(0)
	assert_false(s._prey.on, "gone when its readout closes")
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
## is read or dragged, the foes it would turn draw dashed arrows to its machine, its gauges read
## the lured blows and their heat, and the machine they left reads none; closed, all goes back.
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
	s._on_die_tapped(0)
	var dashed := s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3]))
	assert_eq(dashed.size(), 2, "both foes' arrows dashed to the lure, unasked")
	assert_eq(int(s._mech_views[0].bars[2][3]), sk.mechs[0].heat + 20, "its heat gauge drinks ten a lured blow")
	assert_eq(int(s._mech_views[1].bars[1][3]), sk.mechs[1].unit.hull, "the machine they left keeps its hull")
	s._on_die_tapped(0)
	assert_eq(int(s._mech_views[0].bars[2][3]), heat_before, "its readout closed, the gauge goes back")
	assert_true(s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3])).is_empty(), "and the dashed arrows with it")
	for f in sk.field_foes():
		assert_eq(f.target, sk.mechs[1], "nothing turned for real")
	s._on_drag_started(0)
	assert_eq(s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3])).size(), 2, "dragged anywhere, the same preview")
	s._on_drag_ended(Vector2(-100, -100))
	sk.front[0].target = sk.mechs[0]
	s._on_die_tapped(0)
	assert_eq(s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() > 3 and bool(x[3])).size(), 1, "the one it would turn dashed")
	assert_eq(s._arrows.arrows.filter(func(x: Array) -> bool: return x.size() <= 3 or not bool(x[3])).size(), 1, "and the one on it already solid, every blow it would take shown")
	s._on_die_tapped(0)
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
	# The readout's cylinder (Ryan's ring, 19 October): every chamber in order, the one showing lit,
	# the arrow to the next; a die that rolls has none.
	s._on_die_tapped(0)
	assert_true(s._details_ring.visible, "the stepping die's readout shows its cylinder")
	assert_eq(s._details_ring.faces.size(), n, "every chamber on it")
	assert_eq([s._details_ring.current, s._details_ring.next], [ms.face_index, (ms.face_index + 1) % n], "the one showing lit, the arrow to the next")
	s._on_die_tapped(0)
	s._on_die_tapped(1)
	assert_false(s._details_ring.visible, "a die that rolls shows no cylinder")
	s._on_die_tapped(1)
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
## it waits there, the second targets lit; a tap on one spends it; a tap on the die reads it;
## a tap on nothing sets it back, once no readout is open (30 October); dragging the die again
## picks it back up; a reroll or the turn's end sets it back in the tray first.
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
	t._ghost.tapped.emit()
	assert_eq(t._pop, {"die": 0}, "a tap on the waiting die reads it")
	assert_true(t._details.visible and t._details_entry.visible, "its readout shown")
	assert_false(t._pending.is_empty(), "and the Swap still waits")
	t._ghost.tapped.emit()
	assert_true(t._pop.is_empty(), "a tap again closes it")
	t._ghost.held.emit()
	assert_eq(t._pop, {"die": 0}, "a hold opens it too: a die being spent has nothing to lock")
	assert_false(t.locked[0], "and locks nothing")
	var nothing := InputEventMouseButton.new()
	nothing.button_index = MOUSE_BUTTON_LEFT
	nothing.pressed = true
	t._gui_input(nothing)
	assert_true(t._pop.is_empty() and not t._pending.is_empty(), "a tap on nothing closes the readout first, the Swap still waiting")
	t._gui_input(nothing)
	assert_true(t._pending.is_empty(), "a second sets the Swap back")
	assert_false(t._ghost.visible, "the die gone from its first target")
	assert_false(tm.assigned, "home in the tray, unspent")
	assert_eq(t._dice[0].modulate.a, 1.0, "and shown there")
	t._begin_second(0, t.sk.targets_for(0)[0])
	t._on_ghost_drag_started()
	assert_true(t._pending.is_empty() and t._drag_from == 0, "dragging it again picks it back up")
	assert_true(t._pop.is_empty() and not t._details.visible, "and the die in hand closes its readout")
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


## END TURN pulses once no die can be spent, rerolls left or not (Ryan, 25 October).
func test_end_turn_pulses_once_nothing_is_left_to_spend() -> void:
	var s := _screen(5)
	var any := false
	for i in range(s.sk.mechs.size()):
		any = any or s.sk.can_spend(i)
	assert_eq(s._end_btn.pulse, not any, "it pulses only when nothing can be spent")
	for i in range(s.sk.mechs.size()):
		s.sk.mechs[i].assigned = true
	s._refresh(false)
	assert_true(s.sk.rerolls_left > 0, "rerolls are left")
	assert_true(s._end_btn.pulse, "and it pulses all the same: every die is spent")
	s.free()


## A foe joining the pool is shown going in (Ryan, 25 October): the screen notices who was not
## waiting at its last look; the fight's opening pool is no join.
func test_a_foe_joining_the_pool_is_noticed() -> void:
	var s := _screen(5)
	assert_true(s._pool_primed, "the opening pool remembered")
	var waiting := s.sk.reinforcements.size()
	assert_eq(s._pool_last.size(), waiting, "everyone waiting at the start")
	var joined := Foe.make("revenant", 3, 2)
	s.sk.reinforcements.append(joined)
	s._refresh(false)
	assert_true(s._pool_last.has(joined), "the newcomer seen joining")
	assert_eq(s._reserve.pending.get("front", 0), 0, "headless, nothing flies and the count stands as it is")
	s.free()


## A twin slot (the Gel's pair, 26 October): the left half's view takes the slot's left half and
## the right half's view the other, each its own target; a plain slot is one view again.
func test_a_twin_slot_shows_both_halves() -> void:
	var s := _screen()
	var lead: Foe = s.sk.front[0]
	var half := Foe.make("gel_small", 2, 1)
	s.sk._set_contents(Vector2i(0, 0), [lead, half])
	s._refresh(false)
	var tv: UnitView = s._twin_views[0][0]
	assert_true(tv.visible, "the right half shows")
	assert_eq(s._view_foe.get(tv, null), half, "its own view, its own target")
	assert_eq(s._slot_views[0][0].size.x, SkirmishScreen.SLOT_SIZE.x * 0.5, "the left half takes half the slot")
	s.sk.twins.clear()
	s._refresh(false)
	assert_false(tv.visible, "a plain slot again")
	assert_eq(s._slot_views[0][0].size.x, SkirmishScreen.SLOT_SIZE.x, "one view across it")
	s.free()


## An area weapon in hand brackets a twin slot's pair as one slot (Ryan, 26 October); a
## single-target one brackets each half its own.
func test_an_area_weapon_brackets_a_pair_as_one_slot() -> void:
	var s := _screen()
	var lead: Foe = s.sk.front[0]
	var half := Foe.make("gel_small", 2, 1)
	s.sk._set_contents(Vector2i(0, 0), [lead, half])
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.die = Die.single(Face.attack(3, Face.Reach.DIRECT, Face.Keyword.CLEAVE))
	ms.face_index = 0
	s._drag_from = 0
	s._refresh(false)
	assert_eq(s._pair_marks.rects.size(), 1, "one bracket round the pair")
	assert_false(s._slot_views[0][0].highlight or s._twin_views[0][0].highlight, "and none on either half alone")
	ms.die = Die.single(Face.attack(3, Face.Reach.DIRECT))
	s._refresh(false)
	assert_true(s._pair_marks.rects.is_empty(), "a single-target weapon: no slot bracket")
	assert_true(s._slot_views[0][0].highlight and s._twin_views[0][0].highlight, "each half bracketed on its own")
	s._drag_from = -1
	s.free()


## A foe ready to get back up that burns down in the enemy's turn stands again in its slot, and
## the screen plays its fall and its return after the turn (26 October).
func test_a_foe_getting_back_up_in_the_enemy_turn_is_shown() -> void:
	var s := _screen(5)
	var foe: Foe = s.sk.front[0]
	Effects.stack(foe, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	Effects.stack(foe, Effects.STATUS["burning"], Effects.SKIRMISH, "test", 5, Effects.DECAY_TICK)
	foe.hp = 1
	s._end_turn_now()
	assert_true(s.sk.field_foes().has(foe), "it stood again")
	assert_eq(foe.hp, foe.hp_max, "whole")
	assert_false(Effects.has(foe, "risen"), "its charge spent")
	s.free()


## UNDO (Ryan, 2 November: "undo to your last roll"): a spend taken back on the screen, the
## button's badge saying how far it reaches, the button off once nothing is left, and the
## trail showing the round's bar under its opening lines.
func test_undo_takes_back_the_last_spend_and_its_badge_says_how_far_it_reaches() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.die = Die.single(Face.attack(1, Face.Reach.DIRECT))   # a scratch: the foe stands to be read after
	ms.die = ms.unit.die
	ms.face_index = 0
	s._refresh()
	assert_true(s._undo_btn.disabled, "nothing to take back as the round opens")
	assert_eq(s._undo_btn.badge, "", "and no reach to say")
	var foe: Foe = s.sk.front[0]
	var hp := foe.hp
	var opened := s.sk.log.size()
	assert_true(s._log_text(0).find(SkirmishScreen.ROLL_BAR) >= 0, "the round's bar in the trail")
	assert_true(s._use_die(0, foe), "the die spent")
	assert_eq(s.sk.front[0].hp, hp - 1, "the blow landed")
	assert_false(s._undo_btn.disabled, "the undo opens")
	assert_eq(s._undo_btn.badge, "×1", "one spend back")
	var text := s._log_text(0)
	assert_true(text.find(SkirmishScreen.ROLL_BAR) < text.rfind("> "), "the bar sits under the opening lines, the spend's after it")
	s._on_undo()
	assert_eq([s.sk.front[0].hp, s.sk.mechs[0].assigned, s.sk.log.size()], [hp, false, opened], "the spend taken back")
	assert_true(s._undo_btn.disabled, "and nothing is left")
	s.free()


## A sweep targets a rank (Ryan, 3 November: "fix the UI for sweep so its intuitively targeting a
## rank"): the die dragged over a back foe lights the back rank alone and brackets it whole; over
## nobody, every foe is a legal drop.
func test_a_sweep_die_over_a_foe_lights_and_brackets_its_rank() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.die = Die.single(Face.attack(1, Face.Reach.SWEEP))
	ms.die = ms.unit.die
	ms.face_index = 0
	s._drag_from = 0
	s._drag_over = null
	s._refresh()
	var lit := 0
	for f in s.sk.field_foes():
		if s._foe_view_for(f).highlight:
			lit += 1
	assert_eq(lit, s.sk.field_foes().size(), "over nobody, every foe is a legal drop")
	assert_eq(s._pair_marks.rects.size(), 0, "and no rank is bracketed")
	var back_foe: Foe = s.sk.back[0]
	s._drag_over = back_foe
	s._refresh()
	for f in s.sk.field_foes():
		assert_false(s._foe_view_for(f).highlight, "%s: no foe's own mark; the rank under the finger wears one bracket, the other rank is plain" % f.display_name)
	assert_eq(s._pair_marks.rects.size(), 1, "one bracket round the rank")
	var rank_rect: Rect2 = s._pair_marks.rects[0]
	for f in s.sk.field_foes():
		var v := s._foe_view_for(f)
		var inside := rank_rect.encloses(Rect2(s._home.get(v, v.position) + v.drawing_rect().position, v.drawing_rect().size))
		assert_eq(inside, f.rank == 1, "%s %s the bracket" % [f.display_name, "inside" if f.rank == 1 else "outside"])
	s._drag_over = s.sk.front[0]
	s._refresh()
	assert_eq(s._pair_marks.rects.size(), 1, "the bracket moves with the finger")
	var front_rect: Rect2 = s._pair_marks.rects[0]
	assert_true(front_rect.encloses(Rect2(s._home.get(s._foe_view_for(s.sk.front[0]), Vector2.ZERO) + s._foe_view_for(s.sk.front[0]).drawing_rect().position, s._foe_view_for(s.sk.front[0]).drawing_rect().size)), "round the front rank now")
	s._drag_from = -1
	s._drag_over = null
	s.free()

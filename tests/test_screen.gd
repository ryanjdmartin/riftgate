extends TestCase

## Drives the skirmish screen through its gesture and button handlers without a window, so a
## script error in the UI layer fails the suite instead of waiting for someone to tap it.


func _screen(seed_value: int = 3, massive: Foe = null) -> SkirmishScreen:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(seed_value)
	for id in ["badger", "clydesdale", "kite"]:
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


## Jenny's heat lines (Ryan, 10 November: "The heat warning shouldn't fire every time, not
## anymore ... we only need to warn: -Every time we're overheating -The first time we reach over
## the warning threshold, but not again until we've got back under"): the warning once as a
## machine passes three quarters, silent while it stays there, armed again once it is seen back
## under; the overheat for every spend that heats a machine and leaves it over its cap.
func test_the_heat_warning_once_and_the_overheat_every_time() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	var cap := ms.heat_max
	var line := (cap * 3 + 3) / 4   # the first heat at three quarters or past
	assert_true(cap >= 8 and line < cap, "a cap with room between the warning and the burn")
	var before: Array = s._heats()
	ms.heat = line
	assert_eq(s._heat_hook(before), "heat_high", "past three quarters for the first time: warned")
	before = s._heats()
	ms.heat = line + 1
	assert_eq(s._heat_hook(before), "", "hotter and still past it: not again")
	before = s._heats()
	s.sk.mechs[1].heat += 1
	assert_eq(s._heat_hook(before), "", "another machine's spend, the first still hot: not again")
	# Back under and over again with no look between (an undo and the same spend): not again.
	before = s._heats()
	ms.heat = line
	assert_eq(s._heat_hook(before), "", "never seen back under: not again")
	before = s._heats()
	ms.heat = cap + 1
	assert_eq(s._heat_hook(before), "overheat", "over the cap: the overheat")
	before = s._heats()
	ms.heat = cap + 2
	assert_eq(s._heat_hook(before), "overheat", "heated again while over: the overheat, every time")
	before = s._heats()
	s.sk.mechs[1].heat += 1
	assert_eq(s._heat_hook(before), "", "a spend that heats another machine says nothing of the one already over")
	# The turn's end settles it at the cap, still past three quarters: no second warning.
	ms.heat = cap
	before = s._heats()
	s.sk.mechs[1].heat += 1
	assert_eq(s._heat_hook(before), "", "down from the overheat to its cap: not warned again")
	before = s._heats()
	ms.heat = cap + 1
	assert_eq(s._heat_hook(before), "overheat", "over again the next turn: the overheat again")
	# Cooled back under as a round opens, then past the line again: warned again.
	ms.heat = line - 1
	s._heat_rearm()
	before = s._heats()
	ms.heat = line
	assert_eq(s._heat_hook(before), "heat_high", "back under and over again: warned again")
	# Straight from cool to over the cap: the overheat alone, and no warning once it settles.
	var other: Skirmish.MechState = s.sk.mechs[2]
	other.heat = 0
	s._heat_rearm()
	before = s._heats()
	other.heat = other.heat_max + 1
	assert_eq(s._heat_hook(before), "overheat", "cool to over the cap in one spend: the overheat")
	other.heat = other.heat_max
	before = s._heats()
	assert_eq(s._heat_hook(before), "", "settled at its cap: no warning after the overheat")
	s.free()


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


## Every entry's targeting mark stands under its main mark, never a chip on its rail (Ryan, 2
## November: "Use a straight arrow for direct, and the curved arrow for indirect, and then
## standardize the width of those with the width of the 3 hex symbol"; 3 November: "putting
## targeting underneath"): an arrow under a weapon's sight or equipment's gear aimed at a foe,
## three hexes under a shield, a vent or equipment spent on machines ("center filled for
## self-only, left/right filled for ally only, all filled for self or ally"), the default
## included; a buff and a debuff one equipment mark. A reach over every ally or every foe is a
## keyword's chip.
func test_whom_a_piece_reaches_is_three_hexes_under_its_main_glyph() -> void:
	var shield := Face.shield(4)
	assert_eq(Glyphs.aim_for(shield), "aim_any", "itself or an ally, the default: all three lit")
	shield.targets = Face.Target.SELF
	assert_eq(Glyphs.aim_for(shield), "aim_self", "itself only: the middle")
	shield.targets = Face.Target.ALLY
	assert_eq(Glyphs.aim_for(shield), "aim_ally", "its allies only: the two beside it")
	shield.reaches_all = true
	assert_eq([Glyphs.aim_for(shield), shield.targets], ["aim_every_other_ally", Face.Target.EVERY_OTHER_ALLY], "its allies all at once: its targeting mode, Every Other Ally, its own cell dark under the arch (4 November)")
	assert_true(shield.keywords.is_empty(), "never a keyword")
	var team := Face.shield(4)
	team.reaches_all = true
	assert_eq([Glyphs.aim_for(team), team.targets], ["aim_every_ally", Face.Target.EVERY_ALLY], "itself and its allies all at once: Every Ally, its own cell lit")
	var vent := Face.vent(3)
	vent.targets = Face.Target.SELF
	assert_eq([Glyphs.primary_for(vent), Glyphs.aim_for(vent)], ["vent", "aim_self"], "a vent's steam over the middle hex")
	var buff := Face.buff("overcharged", 1)
	buff.targets = Face.Target.ALLY
	assert_eq([Glyphs.primary_for(buff), Glyphs.aim_for(buff)], ["equipment", "aim_ally"], "a buff: equipment's gear over the hexes")
	var gun := Face.attack(0)
	assert_eq([Glyphs.primary_for(gun), Glyphs.aim_for(gun)], ["equipment", "aim_direct"], "a debuff: the same gear over the straight line")
	assert_eq([Glyphs.primary_for(Face.attack(0, Face.Reach.INDIRECT)), Glyphs.aim_for(Face.attack(0, Face.Reach.INDIRECT))], ["equipment", "aim_indirect"], "or the lobbed one")
	assert_eq([Glyphs.primary_for(Face.attack(4)), Glyphs.aim_for(Face.attack(4))], ["weapon", "aim_direct"], "a weapon: its sight over the line")
	gun.reaches_all = true
	assert_eq([Glyphs.aim_for(gun), gun.reach], ["aim_every_foe", Face.Reach.EVERY_FOE], "over every foe: its targeting mode, Every Foe, and its own mark (4 November)")
	var lure := DieFaceView.new()
	lure.set_face(gun)
	assert_eq(lure.rail_tags(), [] as Array[String], "nothing on the rail: a targeting mode is its mark, never a chip")
	lure.free()
	assert_eq(Glyphs.aim_for(Face.empty_slot()), "", "a blank holds nothing")
	var d := DieFaceView.new()
	var own := Face.shield(4)
	own.targets = Face.Target.SELF
	own.add_keyword(Face.Keyword.CLEANSE)
	d.set_face(own)
	assert_eq(d.rail_tags(), ["cleanse"] as Array[String], "the rail carries its keyword and no self chip")
	own.targets = Face.Target.ALLY
	assert_eq(d.rail_tags(), ["cleanse"] as Array[String], "nor an ally chip")
	d.free()
	var db := ContentDB.load_default()
	var narrowed := 0
	for cid in db.components.keys():
		var comp: Dictionary = db.components[cid]
		if str(comp.get("status", "")) == "planned" or not (comp.get("face", null) is Dictionary):
			continue
		var f := db.build_face(comp["face"])
		var aim := Glyphs.aim_for(f)
		assert_true(aim.begins_with("aim_"), "%s: its main icon holds whom it is aimed at (%s)" % [cid, aim])
		assert_eq(aim in ["aim_self", "aim_ally", "aim_any", "aim_every_ally", "aim_every_other_ally"], f.on_machines(), "%s: the hexes on a piece spent on machines, a line of fire or the formation on one aimed at a foe" % cid)
		if f.on_machines() and f.targets != Face.Target.SELF_ALLY:
			narrowed += 1
	assert_true(narrowed > 0, "content narrows some (%d)" % narrowed)


## The main mark holds what the entry delivers (Ryan, 3 November: "moving the number inside of
## the icon"): equipment, which prints no number, holds what it grants or lays inside its gear (a
## buff's status; a debuff's first keyword that does something to a foe, in content's order; the
## star for a rule of its own), and the rail never shows it twice; a shield and a vent in one entry
## is one mark, the shield and the steam (the Wake Diffuser, the Sutler's Hoist), its cooling a
## number the die prints, never the star; a reload cools nothing, its shells its whole mark.
func test_the_main_mark_holds_what_an_entry_delivers() -> void:
	var buff := Face.buff("overcharged", 2)
	assert_eq(DieFaceView.inside_effect(buff), "overcharged", "a buff: its status inside the gear")
	var d := DieFaceView.new()
	d.set_face(buff)
	assert_false(d.rail_tags().has("overcharged"), "and never on the rail too")
	var lure := Face.attack(0, Face.Reach.EVERY_FOE, [Face.Keyword.LURE, Face.Keyword.CRYO])
	assert_eq(DieFaceView.inside_effect(lure), "lure", "a debuff: its first keyword that does something to a foe")
	d.set_face(lure)
	assert_eq(d.rail_tags(), ["cryo"] as Array[String], "the second effect on the rail, the first inside, Every Foe its targeting mark")
	var mines := Face.attack(0)
	mines.gathers_mines = true
	assert_eq(DieFaceView.inside_effect(mines), "star", "a debuff whose effect is a rule of its own holds the star")
	d.set_face(mines)
	assert_false(d.rail_tags().has("star"), "and the rail does not star it again")
	assert_eq(DieFaceView.inside_effect(Face.attack(4, Face.Reach.DIRECT, [Face.Keyword.ABLATE])), "", "a weapon holds its number, never a keyword")
	d.free()
	var wake := Face.vent(3)
	wake.shields = 3
	var hoist := Face.shield(3)
	hoist.vents = 2
	assert_eq([Glyphs.primary_for(wake), Glyphs.primary_for(hoist)], ["shield_vent", "shield_vent"], "a shield and a vent in one entry: one mark, the shield and the steam, whichever half leads")
	assert_false(hoist.has_unique_rule(), "the Hoist's cooling is a number the die prints, never the star")
	assert_false(hoist.rule_phrases().has("cools 2"), "nor a rule the hold lists")
	var reload := Face.vent(0)
	reload.reloads_ammo = 2
	assert_eq(Glyphs.primary_for(reload), "ammo", "a reload cools nothing: its shells and its number, no steam")


## What a machine's passive adds to an entry stands in its passive box at the rail's foot (Ryan, 4
## November: "Can't we just put the number in the cassowary-type box, call that the 'passive helper
## box' for all these types of effects?"): a blow added after the strikes as "+N", no mark (the
## Storm Petrel's), a stepping die's next entry by its main mark (the Cassowary's); never beside the
## main mark, never joined to its number.
func test_a_passive_adds_its_box_at_the_rails_foot() -> void:
	var picked := func(d: DieFaceView) -> Array:
		return d.passive_marks().map(func(m: Array) -> Array: return [m[0], DieFaceView.passive_plain(m[1])])
	var d := DieFaceView.new()
	d.set_face(Face.attack(4))
	assert_eq(picked.call(d), [], "a plain weapon: no box")
	var hot := Face.attack(4)
	hot.burns = 3
	d.set_face(hot)
	assert_eq(picked.call(d), [["shield", "3"]], "a weapon whose shield pays its heat: what the shield pays, a blow after the strikes, beside the shield's mark")
	var lines := EntryReadout.effects_of(hot)
	var boxed := lines.filter(func(l: Dictionary) -> bool: return (l.get("marks", []) as Array).any(func(m: Dictionary) -> bool: return m.has("passive")))
	assert_eq(boxed.size(), 1, "the readout says it on one line")
	assert_eq(str(boxed[0]["text"]), "Its shield pays 3 of the heat, and the target takes as much after the strikes", "the tap popup clarifies the number, both the spend and the blow")
	assert_false(lines.any(func(l: Dictionary) -> bool: return (l.get("marks", []) as Array).any(func(m: Dictionary) -> bool: return str(m.get("glyph", "")) == "shield")), "and no shield cost line: the passive's payment is no cost")
	assert_eq((boxed[0]["marks"] as Array)[0]["passive"], ["shield", "3"], "headed by the box the die shows")
	d.after_blow = 2
	assert_eq(picked.call(d), [["shield", "2"]], "over a foe, that foe's share")
	d.after_blow = -1
	d.set_face(Face.attack(3))
	d.next_face = Face.shield(5)
	assert_eq(picked.call(d), [["shield", "5"]], "a stepping die's next entry by its mark and its number (Ryan, 4 November: \"Maybe icon+face number?\")")
	d.next_face = Face.attack(6)
	assert_eq(picked.call(d), [["weapon", "6"]], "a weapon's blow")
	d.next_number = "8"
	assert_eq(picked.call(d), [["weapon", "8"]], "as it would deal it now, the screen's live blow")
	d.next_number = ""
	d.next_face = Face.attack(0, Face.Reach.INDIRECT, [Face.Keyword.LURE])
	assert_eq(picked.call(d), [["equipment", ""]], "equipment: its gear, no number (Ryan, 4 November: \"Why drop the equipment gear icon?\")")
	assert_eq((d.passive_marks()[0][1] as Array)[0][2], "lure", "and what it lays where a number would stand")
	var wake := Face.vent(3)
	wake.shields = 2
	d.next_face = wake
	assert_eq(picked.call(d), [["", "2|3"]], "a shield and a vent in one: the two numbers alone, shield | cool (Ryan, 4 November)")
	assert_eq((d.passive_marks()[0][1] as Array).map(func(r: Array) -> Color: return r[1]), [Palette.SHIELD, Palette.MUTED, Palette.HEAT], "each in its colour")
	d.free()
	var db := ContentDB.load_default()
	var next := Face.shield(5)
	next.component = str(db.components.keys()[0])
	var said := EntryReadout.next_chamber_line(next, 2, db)
	assert_eq(str(said["text"]), "A roll or reroll steps it to II, %s" % db.component_name(next.component), "the tap popup names where the die steps (Ryan, 4 November)")
	assert_eq((said["marks"] as Array)[0]["passive"], ["shield", "5"], "headed by the box the die shows")


## Every number a main mark holds is one size, the size the widest of them fits (Ryan, 3 November:
## "you can measure max width just with the multi-strikes text"; 4 November, a weapon's strikes
## beside its sight as equipment's stacks are): a two-digit blow is the widest the sight holds,
## measured at DieFaceView.NUMBER_SIZE; it fits DieFaceView.NUMBER_ROOM, the room sits inside the
## sight's ring, and every weapon's, shield's and vent's number in content fits it.
func test_every_number_a_main_mark_holds_fits_at_one_size() -> void:
	var mono := Hud.mono()
	var px := DieFaceView.NUMBER_SIZE
	var width := func(t: String) -> float: return mono.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	var db := ContentDB.load_default()
	var most := 1
	for cid in db.components.keys():
		var comp: Dictionary = db.components[cid]
		if str(comp.get("status", "")) == "planned" or not (comp.get("face", null) is Dictionary):
			continue
		var f := db.build_face(comp["face"])
		if not (f.is_weapon() or f.kind == Face.Kind.SHIELD or f.kind == Face.Kind.VENT):
			continue
		most = maxi(most, f.strikes)
		var text := str(f.power)
		assert_true(width.call(text) <= DieFaceView.NUMBER_ROOM, "%s: %s fits at the one size (%.0f)" % [cid, text, width.call(text)])
	assert_true(most > 1, "content strikes more than once (%d)" % most)
	assert_true(width.call("12") <= DieFaceView.NUMBER_ROOM, "the widest, a buffed two-digit blow, fits (%.0f)" % width.call("12"))
	var burst := Face.attack(2)
	burst.strikes = most
	var d := DieFaceView.new()
	d.set_face(burst)
	assert_eq(DieFaceView.die_number(burst), "2", "a weapon's number is a strike's blow alone; its strikes stand beside the sight")
	d.free()
	var s := DieFaceView.MAIN_W * 0.5
	var ring := s * Glyphs.SIGHT_RING - 1.2   # the ring's inner edge, half its line in
	var corner := Vector2(DieFaceView.NUMBER_ROOM * 0.5, mono.get_ascent(px) * 0.4).length()
	assert_true(corner + 2.0 <= ring, "the room's corners clear the sight's ring (%.1f inside %.1f)" % [corner, ring])
	# The ticks cross the ring inward (Ryan, 3 November: "have the sight lines extend inwards of
	# the circle"): the side ones stop short of the widest number.
	var side_tick := s * Glyphs.SIGHT_RING - s * 0.12
	assert_true(side_tick >= DieFaceView.NUMBER_ROOM * 0.5 + 1.0, "the side ticks' ends clear the room (%.1f past %.1f)" % [side_tick, DieFaceView.NUMBER_ROOM * 0.5])


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
	# The window runs from the tap's release to the second touch (Ryan, 9 November: "die face single
	# press delay can be a bit faster, even"), so the second press's own length never spends it.
	d.confirm_taps = true
	d._last_tap_at = -10.0
	d._gui_input(press)
	d._gui_input(release)
	d._gui_input(press)   # the second touch inside the window
	d._last_tap_at -= 1.0   # held long, as a slow finger's second press is: its release is late
	d._gui_input(release)
	assert_eq(count["double"], 2, "a second touch inside the window is a double-tap however long it is held")
	assert_true(DieFaceView.DOUBLE_TAP_SECONDS <= 0.15, "the single tap's wait")
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


## REROLL lights only with a die it can roll (the audit's tenth bug, 8 November): every die
## spent or locked, it goes dark.
func test_reroll_goes_dark_with_every_die_spent_or_locked() -> void:
	var s := _screen(5)
	s._refresh()
	assert_false(s._reroll_btn.disabled, "unspent dice: lit")
	for i in range(s.sk.mechs.size()):
		s.locked[i] = true
	s._refresh()
	assert_true(s._reroll_btn.disabled, "every die locked: dark")
	var before := s.sk.rerolls_left
	s._on_reroll()
	assert_eq(s.sk.rerolls_left, before, "and a press spends nothing")
	s.free()


## REROLL lights while the die in hand would bring the team a reroll, and its badge shows the
## count it would leave (Ryan, 15 November: "We can communicate by highlighting the reroll button
## as part of the preview, if one will be granted"): no buff and no chip stand for the grant.
func test_reroll_lights_while_the_die_in_hand_would_grant_one() -> void:
	var s := _screen(5)
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.die = Die.single(Face.from_dict({"kind": "buff", "team_rerolls": 1, "targets": "self"}))
	ms.die = ms.unit.die
	ms.face_index = 0
	s._refresh()
	assert_false(s._reroll_btn.granting, "no die in hand: unlit")
	assert_eq(s._reroll_btn.badge, "×%d" % s.sk.rerolls_left, "the count as it stands")
	s._drag_from = 0
	s._drag_over = ms
	s._refresh()
	assert_true(s._reroll_btn.granting, "the die over its own machine: REROLL lights")
	assert_eq(s._reroll_btn.badge, "×%d+1" % s.sk.rerolls_left, "and the badge shows the one coming")
	s.sk.rerolls_left = 0
	for i in range(s.sk.mechs.size()):
		s.locked[i] = i != 0
	s._refresh()
	assert_true(s._reroll_btn.granting, "with none left it lights all the same: that is when the grant matters most")
	assert_eq(s._reroll_btn.badge, "×0+1", "none in hand, one coming")
	s._drag_from = -1
	s._drag_over = null
	s._refresh()
	assert_false(s._reroll_btn.granting, "the die set down: unlit again")
	assert_eq(s._reroll_btn.badge, "×0", "and the count alone")
	s.free()


## END TURN asks about a die only where it could be spent (the audit's twelfth bug, 8 November): a
## shield whose cost the machine cannot pay has nowhere to go, so it is no waste.
func test_end_turn_counts_only_dice_with_somewhere_to_go() -> void:
	var s := _screen(5)
	for i in range(s.sk.mechs.size()):
		var costly := Face.shield(10)
		costly.shield_cost = 99
		s.sk.mechs[i].unit.die = Die.single(costly)
		s.sk.mechs[i].die = s.sk.mechs[i].unit.die
		s.sk.mechs[i].face_index = 0
	assert_false(s.sk.can_spend(0), "a shield cost it cannot pay: nowhere to spend it")
	assert_eq(s._unspent_count(), 0, "so END TURN has nothing to ask about")
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
	assert_false(s.sk.spend_blows.is_empty(), "its blows recorded, to land a strike at a time")
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
		if f.has(Face.Keyword.RAPID):
			# A rapid entry gives the turn back (the Laminar Deflector's since 12 October): the die
			# rolls again and the machine acts again.
			assert_false(ms.assigned, "a rapid face gives mech %d its turn back" % i)
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
	assert_true(s._details_entry.text().contains("Armour %d" % m.armour), "its armour as a stat, nothing moved: %s" % s._details_entry.text())
	assert_false(s._details_entry.text().contains("Cooling"), "and no cooling, a chassis having none of its own")
	assert_false(s._details_entry.text().contains("breaks the shield"), "no shield-break warning: the gauges preview the blows")
	assert_true(chips.any(func(c: String) -> bool: return c.begins_with("Buff, Empowered")), "every chip listed with what it does, a buff's said so: %s" % str(chips))
	# A foe: its HP, its attack a rally raised (the foe's gain: up and green), its intent.
	Effects.stack(foe, Effects.STATUS["kindled"], Effects.SKIRMISH, "test", 2, Effects.DECAY_HALF)
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
	var gun := Face.attack(3, Face.Reach.INDIRECT, [Face.Keyword.CLEAVE, Face.Keyword.ABLATE], 3)
	gun.ablate = 2
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
	assert_eq(texts, [texts[0], "Attack %d ×2" % n, "Heat %d" % sf.heat, "Target: Enemy, Indirect", "Spread 2", "Apply Ablate 2 on hit", "Tags: Beam, Flame"],
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


## The readout says what kind of piece the entry is on its machine, as the codex says the
## component as built (Ryan, 26 October; the one hybrid, the Whip Scorpion's vents as "vent,
## weapon", left with the vent blast on 12 November).
func test_the_readout_names_the_entrys_type() -> void:
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
	var gun := Face.attack(3, Face.Reach.INDIRECT, [Face.Keyword.CLEAVE, Face.Keyword.ABLATE, Face.Keyword.RAPID], 3)
	gun.ablate = 2
	gun.cleave = 2
	gun.strikes = 2
	gun.component = str(db.components.keys()[0])
	gun.tags.append_array(["beam", "flame"])
	var lines := EntryReadout.codex_lines(gun, db, ["Test: a passive's line."])
	var texts: Array[String] = []
	for l in lines:
		texts.append(str(l["text"]))
	assert_eq(texts, [db.component_name(gun.component).to_upper(), "Attack 3 ×2 · Heat 3 · Target: Enemy, Indirect", "Spread 2 · Apply Ablate 2 on hit · Rapid", "Test: a passive's line."],
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
	probe.gates = {"suppress": {"when": "target_status", "status": "brittled"}}
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
	u.grant_passive({"id": "t_spill", "name": "Spill", "description": "Damage past a kill spills behind.", "effects": [{"trigger": "static", "effect": "spillover", "value": 1}]})
	var gun := Face.attack(4)
	assert_eq(Effects.written_rules(u, gun), ["Damage past a kill spills behind."], "a rule a passive writes on the entry is its passive's line")
	assert_eq(str(EntryReadout.lines_for(gun, 1, -1, gun, [], Effects.written_rules(u, gun), db).back()["text"]), "Damage past a kill spills behind.", "among the rules, last")


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
## component in content and its charged form; a piece reaching every ally never says every foe.
func test_every_rule_the_hold_lists_is_one_the_entry_prints() -> void:
	var db := ContentDB.load_default()
	var checked := 0
	for cid in db.components.keys():
		var f := db.build_face(db.components[cid].get("face", {}))
		for r in f.rule_phrases():
			assert_true(f.describe().contains(r), "%s prints %s: %s" % [cid, r, f.describe()])
			checked += 1
		if not f.is_attack():
			assert_false(f.describe().contains("every foe"), "%s, spent on machines, reaches no foe: %s" % [cid, f.describe()])
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
	assert_true(s._codex._moves.text().contains("Attack %d" % foe.attack), "its blow at its own number")
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
	assert_true(s._codex._passives.visible, "kite's passive is shown")
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
	assert_false(s.sk.can_withdraw(), "no withdrawal at the start of round two either (the long wall brief 3.5)")
	assert_false(has_button(s, "WITHDRAW"), "and no button for one")
	s.free()


## There is no withdrawal (the long wall brief 3.5 and 7.5): the screen has no button for one at
## any point of the fight, and the fight goes on.
func test_there_is_no_withdrawal_on_the_screen() -> void:
	var s := _screen(5)
	assert_false(has_button(s, "WITHDRAW"), "no withdraw button at the start of round one")
	s._end_turn_now()
	assert_false(has_button(s, "WITHDRAW"), "nor at round two's")
	assert_false(s.sk.can_withdraw(), "nor any withdrawal to take")
	assert_eq(s.sk.outcome, Skirmish.Outcome.NONE, "and the fight goes on")
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


## The Nemesis's rage (Ryan, 13 October; the Knuckle of Fury's charged Instant on five rage since
## 12 November): a die rolled again by the store it spent bursts the store's chip, then flips back
## with the reroll's sound; headless, the burst is set going and the die is the player's to spend
## again.
func test_a_rage_roll_bursts_the_chip_and_gives_the_die_back() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	var fist := Face.attack(10)
	fist.charged = {"store": "rage", "price": 5, "keywords": ["instant"]}
	m.die = Die.single(fist)
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(m, Effects.STATUS["rage"], Effects.SKIRMISH, "test", 5, Effects.DECAY_NONE)
	s._refresh()
	assert_true(s._use_die(0, sk.front[0]), "the fist lands")
	assert_false(sk.mechs[0].assigned, "the five rage rolled it again")
	assert_true(s._mech_views[0]._spend >= 0.0, "the rage chip bursts")
	assert_eq(s._mech_views[0]._spend_glyph, SkirmishScreen.status_glyph("rage"), "on the rage chip")
	assert_false(s._dice[0].spent, "the die is the player's again")
	assert_true(s._use_die(0, sk.front[0]), "and it punches again")
	assert_true(sk.mechs[0].assigned, "no rage left: spent")
	s._rage_debug()   # the debug switch's call: a stack kept on the machine, the burst again
	assert_true(Effects.stacks_of(m, "rage") >= 1, "the debug keeps a stack to burst")
	s.free()


## A capped store on the screen (Ryan, 22 October: every store a bar; 10 November: "Resource bars
## like the badgers should be the same shape as the other resource bars, and continuous ...
## nestle under the Heat bar, same shape, divided into four clear segments"): one bar under the
## heat, a gauge's own shape and step, a segment a stack up to its cap, lit to its count, in its
## chip's colour, and no chip; a stack spent from it bursts on the segment that emptied. A store a
## charged piece spends in chunks is the Muster's smooth bar instead (the Nemesis's rage since 11
## November), so the rage here banks for no piece.
func test_a_capped_store_shows_as_a_segmented_bar_under_the_heat_in_its_chips_place() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.grant_passive({"id": "rage_core", "name": "Rage Core", "description": "", "effects": [
		{"trigger": "on_hull_damage", "effect": "stack_status", "value": "rage", "cap": 5}]})
	m.die = Die.single(Face.attack(10))
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(m, Effects.STATUS["rage"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	s._refresh()
	var v: UnitView = s._mech_views[0]
	assert_eq([int(v.store[0]), int(v.store[1])], [2, 5], "two of five segments lit")
	assert_eq(str(v.store[3]), SkirmishScreen.status_glyph("rage"), "the store's own mark, for its burst")
	# The bar is one more gauge in the stack: under the last of them, their width, their height.
	assert_eq(v._store_step(), UnitView.BAR_STEP, "it takes a gauge's step in the stack")
	var first: Rect2 = v._store_cell(0)
	var last: Rect2 = v._store_cell(4)
	assert_true(is_equal_approx(first.position.y, v._bars_top() + v.bars.size() * UnitView.BAR_STEP), "directly under the heat, the last gauge")
	assert_true(is_equal_approx(first.position.x, v.size.x * 0.1) and is_equal_approx(last.end.x, v.size.x * 0.9), "across the gauges' own width")
	assert_eq(first.size.y, UnitView.BAR_H, "a gauge's height")
	# Its units are cells of their own, one width, clear ground between each and the next (Ryan,
	# 10 November: "split them into different bars with borders and whitespace, in the same row").
	for k in range(4):
		var here: Rect2 = v._store_cell(k)
		var next: Rect2 = v._store_cell(k + 1)
		assert_true(next.position.x - here.end.x >= 1.0, "a hairline of ground between cell %d and %d" % [k, k + 1])
		assert_true(is_equal_approx(here.size.x, next.size.x) and is_equal_approx(here.position.y, next.position.y), "one width, one row")
	for r in s._mech_rows(0):
		assert_ne(str(r[0]), SkirmishScreen.status_glyph("rage"), "and no rage chip")
	Effects.spend_stacks(m, "rage", 1)
	s._refresh()
	v.spend_chip(SkirmishScreen.status_glyph("rage"))
	assert_true(v._spend >= 0.0 and v._spend_glyph == SkirmishScreen.status_glyph("rage"), "the spent stack bursts")
	assert_eq(int(v.store[0]), 1, "one segment left lit")
	assert_true(((v._chip_rects[SkirmishScreen.status_glyph("rage")][0]) as Rect2).encloses(v._store_cell(1)), "the burst on the segment that emptied")
	s.free()


## The Honey Badger's hopper is such a bar, four segments, and what its loads are worth is an
## Armoured chip like any buff's, never an ability's (10 November).
func test_the_badgers_hopper_is_a_bar_of_four_and_its_plate_an_armoured_chip() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.add_loads(m, 3)
	s._refresh()
	var v: UnitView = s._mech_views[0]
	assert_eq([int(v.store[0]), int(v.store[1])], [3, 4], "three of four segments lit")
	var armoured := 0
	for r in s._mech_rows(0):
		assert_ne(str(r[0]), SkirmishScreen.status_glyph("hopper"), "no chip for the loads, and none in the hopper's mark")
		if str(r[0]) == SkirmishScreen.status_glyph("braced"):
			armoured += 1
			assert_eq(str(r[5]) if r.size() > 5 else "", "buff", "a buff's chip, one a Purge takes")
	assert_eq(armoured, 1, "one Armoured chip for what the loads are worth")
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
## anything that interacts with overcharged needs it displayed"). Stacks a battle keeps (the
## Ammit's Empowered from 16 October until its rework of 12 November, its Essence since; here a
## battle's own grant) are a chip with their count; a buff's for the round joins them in the one
## chip, and the hold and the codex each list the status once.
func test_a_status_kept_for_the_battle_is_a_chip_with_its_count() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(10))
	m.grant_passive({"id": "keeper", "name": "Keeper", "description": "A rule of its own, and no status.",
		"effects": [{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 5}]})
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 300, 10)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.remove(m, "overcharged")
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.BATTLE, "reward", 2, Effects.DECAY_NONE)   # two stacks the battle keeps
	s._refresh()
	assert_eq(_chips_for(s, 0, "overcharged"), ["×2"] as Array[String], "an Empowered chip with its count")
	Effects.grant_buff(m, "overcharged", 1, "buff", sk.round)
	s._refresh()
	assert_eq(_chips_for(s, 0, "overcharged"), ["×3"] as Array[String], "a buff's for the round joins it in one chip")
	var held := 0
	for l in s._mech_hold_lines(0):
		if str(l["style"]) == "chip" and str(l["text"]).begins_with("Buff, Empowered"):
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
			assert_eq([str(e["name"]), str(e["note"])], ["EMPOWERED ×2", "KEPT FOR THE BATTLE"], "the battle's stacks among the active effects, never a reward, with their count; the round's buff is no part of what the battle keeps")
	assert_eq(listed, 1, "and the codex once: the kept stacks, which the battle carries past this fight")
	# What is no status stays in the codex: a passive of its own, and a battle reward.
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
		assert_eq(str(chips[0][2]), "Buff, Armoured +15", "named Armoured, as a machine's is, with what the chip counts (its meaning a tap on the term), labelled a buff")
		assert_eq(str(chips[0][5]), "buff", "and its chip wears a buff's mark")
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
	# The rallier is Empowered by its own rally too (15 November), so it wears the chip coming.
	var own: Array = s._foe_view_for(lord).statuses.filter(func(st: Array) -> bool: return st.size() >= 4 and str(st[3]) == "preview")
	assert_eq(own.size(), 1, "the rallier wears one too: its own rally reaches it")
	if own.size() == 1:
		assert_eq(str(own[0][1]), "+5", "at the rally's value")
	s._use_die(0, lord)
	assert_false(lord.alive(), "the rallier falls")
	v = s._foe_view_for(g)
	assert_eq(v.intent_value, 10, "the intent drops at once")
	for st in v.statuses:
		assert_false(st.size() >= 4 and str(st[3]) == "preview", "and the chip goes")
	s.free()


## Every status on its way wears a pulsing preview chip (Ryan, 26 October: "All incoming chips
## should appear as pulsing opacity versions"): the Ablating a foe's rider leaves on the machine it
## strikes, and none on a foe nothing is on its way to; a foe the round kills wears
## its skull and no chips on the way.
func test_every_status_on_its_way_wears_a_preview_chip() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.blank())
	m.shield = 0
	sk.add_mech(m)
	var g := Foe.make("revenant", 300, 4)
	g.actions[0]["keywords"] = ["ablate"]
	g.actions[0]["ablate"] = 2
	sk.add_foes([g])
	var s := SkirmishScreen.new()
	s.setup(sk)
	g.target = sk.mechs[0]
	s._refresh()
	var previews: Array = s._foe_view_for(g).statuses.filter(func(st) -> bool: return st.size() >= 4 and str(st[3]) == "preview")
	assert_eq(previews.size(), 0, "nothing is on its way to the foe, so it wears no preview chip")
	var mine: Array = s._mech_rows(0).filter(func(r) -> bool: return r.size() >= 5 and str(r[4]) == "preview")
	assert_eq(mine.size(), 1, "the machine wears one")
	if mine.size() == 1:
		assert_eq(str(mine[0][0]), SkirmishScreen.status_glyph("ablating_mech"), "the Ablating its rider leaves")
		assert_eq(str(mine[0][1]), "+2", "two stacks")
	# A foe the die in hand kills with an Ablate weapon wears the skull and the Ablate coming, both
	# (Ryan, 26 October: "It should be in addition ... some of those chips might be the cause").
	var torch := Face.attack(1, Face.Reach.DIRECT, Face.Keyword.ABLATE)
	torch.ablate = 3
	m.die = Die.single(torch)
	sk.mechs[0].die = m.die
	sk.mechs[0].face_index = 0
	g.hp = 1
	s._drag_from = 0
	s._drag_over = g
	s._refresh()
	var rows := s._foe_rows(g)
	assert_true(rows.any(func(r) -> bool: return str(r[0]) == "skull" and str(r[1]) == ""), "over it, it wears the skull")
	assert_true(rows.any(func(r) -> bool: return r.size() >= 5 and str(r[4]) == "preview" and str(r[0]) == "ablate"), "and the Ablate on its way beside it")
	s._drag_from = -1
	s._drag_over = null
	s.free()


## A kill a foe comes back from takes the skull's place in the preview (Ryan, 7 November: "a revive
## or a split SHOULD be a preview chip that shows up, taking the place of a death chip"): the
## rising arrow on a foe that gets back up, the fork on one that splits, and no skull on either.
## The screen plays a fall and a rise only where the engine says one happened (the audit's
## eleventh bug, 8 November): a Purge that takes a foe's Getting Back Up without felling it plays
## no death; a blow that fells a foe that gets back up plays its fall and its rise.
func test_a_purge_that_takes_undying_from_a_standing_foe_plays_no_death() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	var purge := Face.attack(1, Face.Reach.DIRECT, [Face.Keyword.DISPEL])
	purge.dispel = 1
	m.die = Die.single(purge)
	sk.add_mech(m)
	var riser := Foe.make("revenant", 30, 2)
	sk.add_foes([riser])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(riser, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(s._use_die(0, riser), "the purge, a scratch")
	assert_false(Effects.has(riser, "risen"), "its Getting Back Up taken")
	assert_eq(s.spend_played, {"dead": [], "rose": []}, "and no fall nor rise played")
	s.free()
	var s2_sk := Skirmish.new(1)
	var m2 := db.make_mech("badger")
	m2.die = Die.single(Face.attack(50, Face.Reach.DIRECT))
	s2_sk.add_mech(m2)
	var back := Foe.make("revenant", 10, 2)
	s2_sk.add_foes([back, Foe.make("revenant", 300, 2)])
	var s2 := SkirmishScreen.new()
	s2.setup(s2_sk)
	Effects.stack(back, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(s2._use_die(0, back), "the felling blow")
	assert_eq(s2.spend_played, {"dead": [back], "rose": [back]}, "its fall and its rise played")
	s2.free()


func test_a_foe_that_comes_back_wears_its_return_in_place_of_the_skull() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(50, Face.Reach.DIRECT))
	sk.add_mech(m)
	var riser := Foe.make("revenant", 10, 2)
	var gel := Foe.make("revenant", 10, 2)
	gel.on_death = {"summon": "revenant", "count": 2}
	sk.foe_factory = func(id: String) -> Foe: return Foe.make(id, 5, 1)
	sk.add_foes([riser, gel])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(riser, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	var glyphs := func(f: Foe) -> Array:
		return s._foe_rows(f).filter(func(r) -> bool: return r.size() >= 5 and str(r[4]) == "preview").map(func(r) -> String: return str(r[0]))
	s._drag_from = 0
	s._drag_over = riser
	s._refresh()
	assert_true(glyphs.call(riser).has("rises"), "the die over the riser: it gets back up")
	assert_false(glyphs.call(riser).has("skull"), "and wears no skull")
	s._drag_over = gel
	s._refresh()
	assert_true(glyphs.call(gel).has("splits"), "over the gel: it splits")
	assert_false(glyphs.call(gel).has("skull"), "and wears no skull")
	s._drag_over = riser
	Effects.remove(riser, "risen")
	s._refresh()
	assert_true(glyphs.call(riser).has("skull"), "a foe with nothing to come back with keeps the skull")
	s._drag_from = -1
	s._drag_over = null
	s.free()


## Abilities (Ryan, 8 November: "Nob, and any other enemies with a passive ability, should have an
## unpurgable passive chip that points out what's going on ... It's not a Buff, it's not a Debuff,
## it's labelled as an Ability, so it doesn't get purged"; "Can use this for player units as well,
## like the armadillo's form"): each its glyph on a solid tile, ahead of the statuses, its hold
## line naming it an Ability; a Purge takes the buffs and leaves them.
func test_an_ability_wears_its_own_chip_and_no_purge_takes_it() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1, 4)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.blank())
	sk.add_mech(m)
	var nob := db.make_foe("goblin_nob")
	var gel := Foe.make("gel", 30, 1)
	gel.on_death = {"summon": "gel_half", "count": 2, "pair": true}
	var beast := Foe.make("gargantuan_king", 30, 5)
	beast.on_death = {"blow": Foe.death_blow_from({"name": "Meteor", "factor": 1.0, "keywords": ["all"]})}
	var lord := Foe.make("lord", 30, 5)
	lord.drains = true   # a drain is its foe's own Ability since 16 November, no rider on a blow
	sk.add_foes([nob, gel, beast, lord])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(m, Effects.sealed_status(3, 2), Effects.SKIRMISH, "seal", 1, Effects.DECAY_NONE)
	Effects.grant_buff(m, "overcharged", 2, "buff:overcharge_coil", sk.round)
	Effects.stack(nob, Effects.STATUS["enraged"], Effects.SKIRMISH, "foe:goblin_nob", 2, Effects.DECAY_NONE)
	s._refresh()
	var ability := func(rows: Array) -> Array:
		return rows.filter(func(row) -> bool: return row.size() >= 5 and str(row[4]) == "ability")
	var mine: Array = ability.call(s._mech_rows(0))
	assert_eq(mine.size(), 1, "the seal, the machine's form, is an ability")
	if mine.size() == 1:
		assert_true(str(mine[0][2]).begins_with("Ability, Sealed"), "its hold line names it an Ability")
	assert_true(s._mech_views[0].statuses.any(func(st) -> bool: return st.size() >= 4 and str(st[3]) == "ability"), "and the machine's view draws it on its tile")
	assert_eq(ability.call(s._foe_rows(nob)).size(), 1, "the Nob's rage is its ability")
	assert_true(str(ability.call(s._foe_rows(nob))[0][2]).contains("Enraged +1"), "which says what goes on")
	assert_true(s._foe_rows(nob).any(func(row) -> bool: return str(row[2]) == "Buff, Enraged +2" and (row.size() < 5 or str(row[4]) != "ability")), "and what it has gathered is a buff's chip beside it")
	assert_true(str(ability.call(s._foe_rows(gel))[0][2]).contains("splits"), "a Gel's split is its ability")
	assert_true(str(ability.call(s._foe_rows(beast))[0][2]).contains("Last Act: Meteor"), "a last act is the Gargantuan King's")
	assert_true(str(ability.call(s._foe_rows(lord))[0][2]).begins_with("Ability, Drain"), "a drain is its foe's own, named on its chip")
	Effects.purge(m, 9)
	Effects.purge(nob, 9)
	assert_true(Effects.is_sealed(m), "a Purge leaves the seal")
	assert_false(Effects.has(m, "overcharged"), "and takes the buff")
	assert_eq([nob.rage, Effects.stacks_of(nob, "enraged")], [1, 0], "the rage stays, what it gathered goes")
	s._refresh()
	assert_eq(ability.call(s._foe_rows(nob)).size(), 1, "its chip still there")
	s.free()


## The four buffs a foe's specials grant (the ladder's brief, B; 28 October) wear the machines'
## chips on a foe, each its own mark: Primed's lit flame never the team's Ablating's hollow one,
## Regenerating's heart never Undying's star, the Barrier's wall and the Ward's struck ring.
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
	Effects.stack(foe, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 2)
	Effects.stack(foe, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:revenant", 1, Effects.DECAY_NONE)
	Effects.stack(foe, Effects.primed_foe(), Effects.SKIRMISH, "foe:caster", 2, Effects.DECAY_NONE)
	Effects.stack(foe, Effects.foe_barrier(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	Effects.stack(foe, Effects.foe_ward(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	Effects.stack(foe, Effects.STATUS["regenerating"], Effects.SKIRMISH, "foe:caster", 4, Effects.DECAY_TICK)
	var by := {}
	for r in s._foe_rows(foe):
		by[str(r[0])] = r
	for g in ["primed", "barrier", "ward", "regenerating"]:
		assert_true(by.has(g), "a %s chip" % g)
	assert_true(by.has("ablate") and by.has("star"), "beside the Ablating and the Undying, each its own")
	# The readout names each chip with its count, never what it does (Ryan, 2 November: "unit popups
	# don't need the chips descriptions spelled out now that we can tap keywords").
	if by.has("primed"):
		assert_eq(str(by["primed"][1]), "×2", "Primed counts its stacks")
		assert_eq(str(by["primed"][2]), "Buff, Primed ×2", "and the readout names it with them, a buff")
	if by.has("regenerating"):
		assert_eq(str(by["regenerating"][1]), "×4", "Regenerating counts its stacks, a point each as its turn ends")
		assert_true(str(by["regenerating"][2]).contains("+4 as its turn ends, then a stack fades"), "and the readout says what they do and how they run down")
	if by.has("barrier"):
		assert_eq(str(by["barrier"][2]), "Buff, Barrier", "a foe's Barrier by its name alone, a buff, its meaning the term's")
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


## A foe's ticks preview on its gauge (Ryan, 26 October: Ablating and the other ticks are static
## numbers, "so a hypothetical death at the start of the enemy's turn could be previewed"): the HP
## its Ablating will take at its action is the gauge's pending loss, the whole bar when it kills it
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
	var per := Effects.status_value("ablating", "tick_hp")
	Effects.stack(a, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 2)
	Effects.stack(b, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 4)
	s._refresh()
	assert_eq(int(s._foe_view_for(a).bars[0][3]), 10 - 2 * per, "its Ablating's tick pending on its gauge")
	assert_eq(int(s._foe_view_for(b).bars[0][3]), 0, "Ablating that fells it at its action: the whole bar")
	assert_eq(sk.hp_after_ticks(b), 0, "the same number the forecast reads")
	sk.end_round()
	assert_false(b.alive(), "and it burnt to death at its action")
	assert_eq(a.hp, 10 - 2 * per, "the other took what its gauge showed")
	s.free()


## A foe the round will kill wears the machines' destroyed chip and keeps its intent (Ryan, 26
## October: "Intent of a foe thats dying should absolutely NOT lose its intent ... It should get a
## destroyed chip same as the player"); an Ablate hit enough to kill it shows the fall at once, and a
## foe a Cure will heal shows the heal coming on its gauge.
func test_a_foe_the_round_kills_wears_the_destroyed_chip_and_keeps_its_intent() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(1, Face.Reach.DIRECT, [Face.Keyword.ABLATE]))
	sk.add_mech(m)
	var cleric := Foe.make("revenant", 500, 20)
	var cure := {"id": "cure", "name": "Cure", "kind": "defend", "effect": "heal", "value": 3, "weight": 1, "text": ""}
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
	Effects.stack(a, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 5)
	s._refresh()
	var v := s._foe_view_for(a)
	assert_eq(skulls.call(v), 1, "its Ablating kills it at its action: the destroyed chip")
	assert_eq(v.intent_kind, "attack", "its intent kept")
	assert_eq(int(v.bars[0][3]), 0, "and the whole bar pulsing")
	Effects.remove(a, "ablating")
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


## A fight the enemy's turn decides shows its outcome once that turn has replayed (Ryan, 23
## September): the team on its last hull, END TURN, the blows replayed with the gauges after
## each, then the overlay (there is no withdrawal to end a fight otherwise, the long wall brief).
func test_the_enemy_turn_replays_before_the_outcome() -> void:
	var s := _screen(5)
	for m in s.sk.mechs:
		m.unit.hull = 1
		m.unit.shield = 0
	s._on_end_turn()
	s._confirm_yes()
	assert_true(s.sk.turn_events.size() > 0, "the enemy struck")
	var ev: Dictionary = s.sk.turn_events[0]
	assert_true(ev.has("shield") and ev.has("hull"), "each blow carries the mech's gauges after it, for the replay")
	assert_eq(s.sk.outcome, Skirmish.Outcome.DEFEAT, "and it wrecked the team")
	assert_true(s._overlay.visible, "the outcome shows once the replay is done (headless: at once)")
	assert_eq(s._overlay_title.text, "WRECKED", "title")
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
	Effects.stack(foe, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_HALF)
	Effects.stack(foe, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	s._refresh()
	var glyphs: Array = []
	for r in s._foe_rows(foe):
		glyphs.append(r[0])
		if r[0] == "web":
			assert_eq(r[1], ">", "the web's chip points at the neighbour it catches, to its right")
		if r[0] == "brittle":
			assert_eq(r[1], "3", "Brittle's chip counts its stacks, the extra every blow deals")
		if r[0] == "cryo":
			assert_eq(r[1], "2", "Cryo's chip counts its stacks (21 October: it had none)")
	assert_true(glyphs.has("web") and glyphs.has("vitriol"), "a webbed, acid-eaten foe wears both chips: %s" % str(glyphs))
	assert_true(glyphs.has("brittle") and glyphs.has("cryo"), "and Brittle and Cryo wear theirs: %s" % str(glyphs))
	s.free()


## The lure preview (the lure-all's forecast, 22 October): while a die whose entry Lures every foe
## is read or dragged, the foes it would turn draw dashed arrows to its machine, its gauges read
## the lured blows and the heat its passive banks from them, and the machine they left reads none;
## closed, all goes back.
func test_a_lure_in_hand_previews_its_turn_with_dashed_arrows_and_the_gauges() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var a := db.make_mech("badger")
	a.die = Die.single(Face.from_dict({"kind": "attack", "reach": "every_foe", "power": 0, "keywords": ["lure"], "braces": 2}))
	a.grant_passive({"id": "boiler", "name": "Boiler", "description": "", "effects": [{"trigger": "static", "effect": "heat_per_blow", "value": 10}]})
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
	assert_eq(int(s._mech_views[0].bars[2][3]), sk.mechs[0].heat + 20, "its heat gauge banks its passive's ten a lured blow")
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
	var dark_state: Array = s._entry_states(ms, ms.face_index)[0]
	assert_eq(str(dark_state[0]), "On Cooldown (2 turns left)", "and so does the hold, in Ryan's words")
	assert_eq(str((dark_state[1] as Dictionary).get("glyph", "")), "cooldown", "by the clock the die shows along its foot")
	Effects.disable_entry(ms.unit, ms.face_index, "foe:x", s.sk.round)
	s._refresh()
	assert_true(str(s._entry_states(ms, ms.face_index)[0][0]).begins_with("Jammed"), "a foe's jam says so, cleansable")
	s.free()


## A stepping die (the Cassowary's, 21 October) shows its next chamber on the die and in the
## hold, and a machine that counts its shots shows the count as cells under the heat bar, the last marked.
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
		assert_false(str(r[2]).begins_with("Shots"), "the count is cells under the heat, never a chip")
	assert_true(s._dice[1].next_face == null, "a die that rolls shows none")
	assert_true(s._mech_views[1].pips.is_empty(), "nor a count's cells")
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
	ms.die.faces[ms.face_index] = Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "swaps": true})
	var first: Foe = s.sk.targets_for(0)[0]
	s._begin_second(0, first)
	assert_eq(s._pending["primary"], first, "the die waits on its first target")
	assert_true(s._ghost.visible and s._ghost.can_drag, "shown there, and it can be picked back up")
	assert_true(s._forecast_for(0).has("coming"), "the gauges still read the round preview while it waits, the die uncounted (the audit's Bug 16: the bot's estimate stood in here)")
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
	tm.die.faces[tm.face_index] = Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "swaps": true})
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


## The Lammergeier's Mines on the screen (9 November: "the chip shows the damage instead of the
## stacks, with the tooltip showing the riders"), on a synthetic passive: a spend at a foe leaves its
## Mine, and the foe wears the sea mine's chip with the damage, its readout naming the riders; no
## empty slot lights for a dragged weapon.
func test_a_mined_foe_wears_its_mine_chip_with_the_damage_and_the_riders_in_its_readout() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.grant_passive({"id": "bay", "name": "Bay", "description": "", "effects": [{"trigger": "static", "effect": "mine_on_spend", "value": 2}]})
	ms.die.faces[ms.face_index] = Face.attack(1, Face.Reach.INDIRECT, [Face.Keyword.ABLATE])
	ms.die.faces[ms.face_index].ablate = 2
	s._drag_from = 0
	s._refresh()
	for rank in range(2):
		for col in range(s.sk.columns):
			if s.sk.foe_at(rank, col) == null:
				assert_false(s._slot_views[rank][col].highlight, "no empty slot lights for a weapon")
	s._drag_from = -1
	var foe: Foe = s.sk.targets_for(0)[0]
	assert_true(s._use_die(0, foe), "spent at a foe")
	s._refresh()
	var v: UnitView = s._foe_view_for(foe)
	var chip: Array = []
	for row in v.statuses:
		if str(row[0]) == "mine":
			chip = row
	assert_false(chip.is_empty(), "the foe wears the Mine's chip")
	assert_eq(str(chip[1]), "2", "with its damage")
	var said := ""
	for row in s._foe_rows(foe):
		if str(row[0]) == "mine":
			said = str(row[2])
	assert_true(said.contains("Debuff, Mine 2: Ablate 2"), "its readout names the riders: %s" % said)
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
	# One half falls: the other keeps its half of the slot, never the whole (Ryan, 2 November: "a half
	# unit should not take the full unit slot when it's other half dies, only when both are vacated
	# does it return to a full size slot").
	var home := s._home[s._slot_views[0][0]] as Vector2
	s.sk.twins.clear()
	s._refresh(false)
	assert_false(tv.visible, "the fallen half's view goes")
	assert_eq(s._slot_views[0][0].size.x, SkirmishScreen.SLOT_SIZE.x * 0.5, "the survivor keeps its half")
	assert_eq(s._home[s._slot_views[0][0]], home, "on its own side")
	s.sk.front[0] = null
	s._refresh(false)
	assert_eq(s._slot_views[0][0].size.x, SkirmishScreen.SLOT_SIZE.x, "both gone: one view across the slot again")
	s.free()


## The right half survives its twin: it stays on the right of its slot, drawn by the slot's own view.
## A half shown alone after a resume (no side remembered) is still a half, on the left.
func test_a_right_half_alone_keeps_the_right_of_its_slot() -> void:
	var s := _screen()
	var lead: Foe = s.sk.front[0]
	var half := Foe.make("gel_small", 2, 1)
	s.sk._set_contents(Vector2i(0, 0), [lead, half])
	s._refresh(false)
	var left_x: float = (s._home[s._slot_views[0][0]] as Vector2).x
	s.sk._set_contents(Vector2i(0, 0), [half, null])   # the left half falls; the right keeps the slot alone
	s._refresh(false)
	var v: UnitView = s._slot_views[0][0]
	assert_eq(s._view_foe.get(v, null), half, "the slot's view draws the survivor")
	assert_eq((s._home[v] as Vector2).x, left_x + SkirmishScreen.SLOT_SIZE.x * 0.5, "on the right, where it stood")
	assert_eq(v.size.x, SkirmishScreen.SLOT_SIZE.x * 0.5, "at half a slot")
	var halves := SkirmishScreen.pair_halves()
	assert_false(halves.is_empty(), "content names the pair's halves")
	var resumed := Foe.make(str(halves.keys()[0]), 2, 1)
	resumed.content_id = str(halves.keys()[0])
	assert_true(s.is_half(resumed), "a half no screen has shown is one by its content")
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
	Effects.stack(foe, Effects.STATUS["ablating"], Effects.SKIRMISH, "test", 5, Effects.DECAY_TICK)
	foe.hp = 1
	s._end_turn_now()
	assert_true(s.sk.field_foes().has(foe), "it stood again")
	assert_eq(foe.hp, foe.hp_max, "whole")
	assert_false(Effects.has(foe, "risen"), "its charge spent")
	s.free()


## A gauge wears its scale (Ryan, 2 November: "Tick on the ones, a bigger or more prominent tick
## on the 5s, reduce to ticking on 5s only if the 1s get crowded on a particular bar"): every
## point while the ones stand TICK_PITCH apart, the fives alone where they would crowd, the tens
## past that, none on a one-point bar.
func test_a_bar_ticks_its_ones_and_its_fives_alone_where_the_ones_crowd() -> void:
	assert_eq(Hud.tick_step(136.8, 12), 1, "a machine's heat: every point")
	assert_eq(Hud.tick_step(136.8, 16), 1, "its shield: every point")
	assert_eq(Hud.tick_step(136.8, 34), 1, "a hull of 34 still fits its ones")
	assert_eq(Hud.tick_step(136.8, 36), 5, "a hull of 36 crowds them: the fives alone")
	assert_eq(Hud.tick_step(56.0, 6), 1, "a foe's small gauge: every point")
	assert_eq(Hud.tick_step(56.0, 48), 5, "a boss's: the fives")
	assert_eq(Hud.tick_step(56.0, 72), 10, "a bigger one's: the tens")
	assert_eq(Hud.tick_step(56.0, 1), 0, "a one-point bar has no scale")
	assert_eq(Hud.tick_step(0.0, 10), 0, "nor a bar with no width")


## Every icon on a die face is in its readout (Ryan, 2 November: "any icon on a die face NEEDS to
## be represented in the popup, star icon before the unique effect for instance"): for every
## component in content, the die's big glyph, each keyword chip, the star for a rule of its own,
## equipment's status chip, the marks of its costs and the three hexes of whom it reaches each
## stand at the head of a line of its readout.
func test_every_mark_on_a_die_face_heads_a_line_of_its_readout() -> void:
	var db := ContentDB.load_default()
	for cid in db.components.keys():
		var comp: Dictionary = db.components[cid]
		if str(comp.get("status", "")) == "planned" or not (comp.get("face", null) is Dictionary):
			continue
		var f := db.build_face(comp["face"])
		f.component = str(cid)
		var heads: Array[String] = []
		var texts: Array[String] = []
		for l in EntryReadout.lines_for(f, 1, -1, f, [], [], db):
			texts.append(str(l.get("text", "")))
			for m in l.get("marks", []):
				heads.append(str(m.get("glyph", "")))
		var wanted: Array[String] = [Glyphs.primary_for(f)]
		for k in f.keywords:
			wanted.append(str(Face.KEYWORD_NAMES[k]))
		if f.has_unique_rule():
			wanted.append("star")
		var granted := DieFaceView.status_chip(f)
		if not granted.is_empty():
			wanted.append(Terms.glyph(granted))   # equipment's status, inside its gear
		if f.vents > 0:
			wanted.append("vent")     # a shield's cooling, under the steam off its top (3 November)
		if f.shields > 0:
			wanted.append("shield")   # a vent's shield, in the shield's half of its mark
		# The costs along the foot, each a mark and a number (Ryan, 2 November).
		if f.heat > 0:
			wanted.append("heat")
		if f.volatile > 0:
			wanted.append("hull")
		if f.cooldown_rounds() > 0:
			wanted.append("cooldown")   # the cooldown's clock, a cost (2 November)
		if f.shield_cost > 0:
			wanted.append("shield")
		for g in wanted:
			assert_true(heads.has(g), "%s: the die's %s mark heads a readout line (%s)" % [cid, g, str(heads)])
		var aim := Glyphs.aim_for(f)
		if not aim.is_empty():
			assert_true(heads.has(aim), "%s: the die's hexes head its target line (%s)" % [cid, str(heads)])


## The die's readout lines each with the mark it says: the Puffin's projector, an ally's shield,
## its glyph on its number, the three hexes on its target, and a lock and a corruption on their
## states.
func test_a_dies_readout_heads_each_line_with_its_mark() -> void:
	var db := ContentDB.load_default()
	var f := db.build_face(db.components["backwash_ionizer"]["face"])
	f.component = "backwash_ionizer"
	var lines := EntryReadout.lines_for(f, 1, -1, f, [["Locked: a reroll skips it", EntryReadout.mark("lock", Palette.HUD, false)]], [], db)
	var by := {}
	for l in lines:
		for m in l.get("marks", []):
			by[str(m["glyph"])] = l
	assert_eq(str(by.get("shield", {}).get("text", "")), "Shield 3", "the shield's glyph on its number")
	var target: Dictionary = {}
	for l in lines:
		if str(l.get("text", "")) == "Target: Any other ally":
			target = l
	assert_false(target.is_empty(), "whom it reaches, in words")
	assert_eq((target.get("marks", []) as Array).map(func(m: Dictionary) -> String: return str(m.get("glyph", ""))), ["aim_ally"], "headed by the three hexes the die draws, the two beside lit")
	assert_false(bool((target.get("marks", [{}]) as Array)[0].get("box", true)), "bare, as the die draws them under its glyph")
	assert_eq(str(by.get("lock", {}).get("style", "")), "state", "the lock on its state")
	var readout := EntryReadout.new()
	readout.set_lines(lines)
	var boxed := 0
	var bare := 0
	for c in readout._chips:
		if bool(c["box"]):
			boxed += 1
		else:
			bare += 1
	assert_eq([boxed, bare], [0, 3], "the big glyph, the hexes and the lock bare, and no keyword's chip on a piece that carries none")
	readout.free()


## A foe's intent chip carries its blow's riders (Ryan, 2 November: "Enemy intents with a rider need
## to show that rider as part of the intent chip"): each keyword its move carries by its term's mark,
## a numbered one with its stacks.
func test_a_foes_intent_chip_carries_its_riders() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	sk.add_mech(db.make_mech("badger"))
	var foe := Foe.make("revenant", 30, 4)
	foe.actions = [{"id": "rake", "name": "Rake", "kind": "attack", "weight": 1, "keywords": ["all", "scorch"], "scorch": 2}]
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	var v := s._foe_view_for(foe)
	assert_eq(v.intent_note, "", "no mark after the number for a single blow")
	var riders: Array = v.intent_riders
	assert_eq(riders.size(), 2, "both riders inside the chip")
	if riders.size() == 2:
		assert_eq([str(riders[0][0]), str(riders[0][1])], [Terms.glyph("all"), ""], "the blow at every machine by its mark")
		assert_eq([str(riders[1][0]), str(riders[1][1])], [Terms.glyph("scorch"), "2"], "the scorch with its stacks")
	var plain := UnitView.chip_width(Hud.mono(), ["sword", "4", Palette.ENEMY, "intent", []])
	assert_true(UnitView.chip_width(Hud.mono(), ["sword", "4", Palette.ENEMY, "intent", riders]) > plain + 30.0, "the chip grows to hold them")
	# Its readout heads the move with that chip (Ryan, of the Cinder Tortoise's Withdraw: "a chip I
	# don't recognize ... and more importantly it doesn't show in the popup").
	s._on_foe_tapped(v, 0, 0)
	var head := {}
	for l in s._details_entry.lines:
		if str(l.get("style", "")) == "name":
			head = l
	var marks: Array = head.get("marks", [])
	assert_eq(marks.size(), 1, "the move's name wears its chip")
	if marks.size() == 1:
		assert_eq(marks[0]["chip"], s._intent_chip(foe), "the field's own chip, riders and all")
		assert_eq(str(marks[0]["chip"][0]), "sword", "a blow's sword")
	s.free()


## A special's chip is its kind's (the Cinder Tortoise's Withdraw, a brace: the defend kite with its
## value), and its readout heads the move with it.
func test_a_specials_intent_chip_heads_its_readout() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	sk.add_mech(db.make_mech("badger"))
	var foe := Foe.make("revenant", 30, 4)
	foe.actions = [{"id": "withdraw", "name": "Withdraw", "kind": "defend", "effect": "brace", "value": 3, "weight": 1}]
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	var chip := s._intent_chip(foe)
	assert_eq([str(chip[0]), str(chip[1])], [Glyphs.intent_for("defend"), "3"], "the defend mark and its value, as under the foe")
	s._on_foe_held(s._foe_view_for(foe))
	assert_true(s._details_entry.text().contains("WITHDRAW"), "the move named under it")
	s.free()


## A unit's readout names its chips, never spells them out (Ryan, 2 November: "unit popups don't need
## the chips descriptions spelled out now that we can tap keywords"): each chip line its status's
## name and count, the name a term a tap opens.
func test_a_units_readout_names_its_chips_without_their_descriptions() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	sk.add_mech(m)
	var foe := Foe.make("revenant", 30, 4)
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(foe, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	Effects.grant_buff(m, "overcharged", 2, "buff", sk.round)
	s._refresh()
	var chips: Array[String] = []
	for l in s._foe_hold_lines(foe):
		if str(l["style"]) == "chip":
			chips.append(str(l["text"]))
	assert_true(chips.has("Debuff, Ablating ×3"), "a foe's Ablating by its name and stacks, labelled a debuff (Ryan, 9 November): %s" % str(chips))
	var mine: Array[String] = []
	for l in s._mech_hold_lines(0):
		if str(l["style"]) == "chip":
			mine.append(str(l["text"]))
	assert_true(mine.has("Buff, %s ×2" % str(Effects.STATUS["overcharged"]["name"])), "a machine's Empowered the same, by its shown name, labelled a buff: %s" % str(mine))
	var readout := EntryReadout.new()
	readout.set_lines(s._foe_hold_lines(foe))
	var terms: Array = []
	for h in readout._hits:
		terms.append_array(h["terms"])
	assert_true(terms.has("ablating"), "the name a term, its meaning a tap away")
	readout.free()
	s.free()


## An open readout takes every tap on it (Ryan, 2 November: "i managed to reroll when trying to click
## a keyword on a unit popup since it was underneath. Popups intuitively should prevent triggering
## things behind them, even other popup triggers"): its panel stops the press, and what it holds
## lets one through only to a term.
func test_an_open_readout_takes_every_tap_on_it() -> void:
	var s := _screen()
	s._on_mech_tapped(0)
	assert_true(s._details.visible, "open")
	assert_eq(s._details.mouse_filter, Control.MOUSE_FILTER_STOP, "the panel stops every press on it")
	assert_eq(s._details_entry.mouse_filter, Control.MOUSE_FILTER_PASS, "its lines take one on a term alone")
	assert_false(s._details_entry._has_point(Vector2(-50.0, -50.0)), "nothing off a term")
	s.free()


## The foe acting in the enemy's turn is lit, one at a time (Ryan, 2 November: "enemies need to
## highlight during their attacks, starting right before"); the replay lights the next a part of
## the beat before its move lands, out of the beat after the last blow, so the turn keeps its pace.
func test_the_acting_foe_is_lit_one_at_a_time() -> void:
	var s := _screen()
	var views := s._live_foe_views()
	assert_true(views.size() >= 2, "foes on the field")
	s._spotlight(views[0])
	assert_true(views[0].acting, "the first lit")
	s._spotlight(views[1])
	assert_true(views[1].acting and not views[0].acting, "the next lit puts the last out")
	s._spotlight(null)
	assert_false(views[1].acting, "and none at the turn's end")
	assert_true(SkirmishScreen.ACT_LEAD > 0.0 and SkirmishScreen.ACT_LEAD < 1.0, "the lead a part of the beat")
	s.free()


## A spend's blows land a strike at a time (Ryan, 2 November: "flechette pod and other multistrikes
## need to clearly show the strikes in order, with individual ticks of damage ... damage needs to be
## timed to the animation across the board"): the sim records every blow in the order it landed, its
## strike, what it took and the HP it left; the screen lands each at its strike's beat, and a foe the
## spend killed dies at the spend's death check, after its last blow (Ryan, 7 November).
func test_a_bursts_blows_land_a_strike_at_a_time() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	var gun := Face.attack(2)
	gun.strikes = 3
	m.die = Die.single(gun)
	sk.add_mech(m)
	var foe := Foe.make("revenant", 5, 1)
	var other := Foe.make("revenant", 30, 1)
	sk.add_foes([foe, other])
	var s := SkirmishScreen.new()
	s.setup(sk)
	assert_true(s._use_die(0, foe), "spent")
	var blows: Array = sk.spend_blows
	assert_eq(blows.size(), 3, "three blows for three strikes: %s" % str(blows))
	if blows.size() == 3:
		assert_eq([int(blows[0]["strike"]), int(blows[1]["strike"]), int(blows[2]["strike"])], [0, 1, 2], "in order, a strike each")
		assert_eq([int(blows[0]["hp"]), int(blows[1]["hp"]), int(blows[2]["hp"])], [3, 1, -1], "each with the HP it left")
		assert_eq(int(blows[0]["taken"]), 2, "and what it took")
	assert_eq(SkirmishScreen._strikes_of(blows), 3, "three strikes")
	var deaths := s._land_blows(blows, 0.5, {}, [foe], {foe: 5})
	assert_true(is_equal_approx(float(deaths[foe]), 0.5 + 2.0 * SkirmishScreen.STRIKE_GAP), "it dies after the third, its killing blow and the last: %s" % str(deaths))
	assert_true(s._shown_hp.is_empty() and s._stand_ins.is_empty(), "off the tree nothing is held back: the gauges read the fight")
	s.free()


## Nothing a spend fires is cut short on the screen (Ryan, 7 November: "Animate wasted shots.
## Anything truncated confuses the player"): a multi-hit that kills with its first hit still lands
## its later hits, on the corpse, and the foe dies after the last.
func test_every_hit_lands_on_the_screen_one_on_a_corpse_included() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1, 3)
	var m := db.make_mech("badger")
	var burst := Face.attack(10)
	burst.strikes = 3
	m.die = Die.single(burst)
	sk.add_mech(m)
	var frail := Foe.make("revenant", 4, 1)
	var other := Foe.make("revenant", 30, 1)
	sk.add_foes([frail, other])
	var s := SkirmishScreen.new()
	s.setup(sk)
	assert_true(s._use_die(0, frail), "the burst spent")
	var blows: Array = sk.spend_blows
	assert_eq(blows.size(), 3, "three hits recorded, two on the corpse: %s" % str(blows))
	assert_eq(SkirmishScreen._strikes_of(blows), 3, "three beats")
	var deaths := s._land_blows(blows, 0.5, {}, [frail], {frail: 4})
	assert_true(is_equal_approx(float(deaths[frail]), 0.5 + 2.0 * SkirmishScreen.STRIKE_GAP), "it dies after the third hit, at the death check: %s" % str(deaths))
	s.free()


## Ricochet on the screen (the Skua's, 11 November; a synthetic passive): each of its strikes a
## beat of its own, quick on its shot's heels; the die's passive box says how many a shot gets;
## the status is a chip like any buff, and its once-a-round mark never one.
func test_a_ricochet_lands_on_its_own_quick_beat_and_shows_in_the_passive_box() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1, 2)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(3))
	m.grant_passive({"id": "skip", "name": "Skip", "description": "", "effects": [{"trigger": "on_damage", "effect": "stack_status", "value": "ricochet", "once": "round"}]})
	sk.add_mech(m)
	var foe := Foe.make("revenant", 30, 1)
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	Effects.stack(m, Effects.STATUS["ricochet"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	s._refresh()
	assert_eq(s._dice[0].ricochet, 2, "the die carries the two strikes more")
	assert_true(s._dice[0].passive_marks().any(func(x: Array) -> bool: return str(x[0]) == "ricochet" and str(x[1]) == "+2"), "in its passive box: %s" % str(s._dice[0].passive_marks()))
	assert_true(s._mech_rows(0).any(func(r: Array) -> bool: return str(r[2]).contains("Ricochet")), "the status a chip")
	assert_true(s._use_die(0, foe), "spent")
	var blows: Array = sk.spend_blows
	assert_eq(SkirmishScreen._strikes_of(blows), 3, "three beats, the shot and its two: %s" % str(blows))
	var beats := SkirmishScreen._beats(blows)
	assert_true(is_equal_approx(beats[1], SkirmishScreen.RICOCHET_GAP) and is_equal_approx(beats[2], 2.0 * SkirmishScreen.RICOCHET_GAP), "each quick on the heels of the one before: %s" % str(beats))
	assert_true(SkirmishScreen._is_ricochet(blows, 1) and not SkirmishScreen._is_ricochet(blows, 0), "the shot is a strike, what follows a Ricochet")
	assert_eq(s._view_struck(blows, 2, {}, null), s._foe_view_for(foe), "a Ricochet is aimed at its shot's foe")
	assert_eq(Effects.stacks_of(m, "ricochet"), 3, "the spend earned its stack")
	s._refresh()
	assert_false(s._mech_rows(0).any(func(r: Array) -> bool: return str(r[2]).strip_edges().is_empty() or str(r[2]).contains("once")), "the gate's mark is no chip: %s" % str(s._mech_rows(0)))
	assert_eq(s._dice[0].ricochet, 0, "a spent die prints none")
	s.free()


## A last act lands its damage with the act: the sim records each struck machine's gauges as the
## act met them, for the screen to hold until it is named.
func test_a_last_act_records_the_gauges_it_met() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(10))
	sk.add_mech(m)
	var bomb := Foe.make("revenant", 4, 3)
	bomb.on_death = {"blow": {"name": "Parting Shot", "factor": 1.0, "keywords": ["all"]}}
	sk.add_foes([bomb, Foe.make("revenant", 30, 1)])
	sk.begin()
	sk.start_round()
	var shield := m.shield
	var hull := m.hull
	assert_true(sk.assign(0, bomb), "spent on it")
	assert_eq(sk.last_acts.size(), 1, "its last act landed")
	if sk.last_acts.size() == 1:
		assert_eq(sk.last_acts[0]["gauges"], [[shield, hull]], "the gauges it met")
		assert_true(m.shield < shield or m.hull < hull, "and it struck")


## The Polar Bear's form reads on its die and its view (Ryan, 2 November: "armadillo needs indication
## when a die face will transform it, like a die chip or something. It also needs some highlight or
## something when it is transforming, and a better indication of what form it's in"): open, a buff
## it may spend on itself wears the seal chip and its readout says so (its trigger since 11
## November); sealed, a weapon wears the opening one; sealed, the view wears its shell; the Sealed
## chip the seal's own mark. Its stock die as content deals it.
func test_the_polar_bears_form_reads_on_its_die_and_its_view() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("polar_bear")
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 30, 1)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	var ms: Skirmish.MechState = sk.mechs[0]
	var buff := -1
	var gun := -1
	for k in range(m.die.faces.size()):
		var f: Face = m.die.faces[k]
		if f.kind == Face.Kind.BUFF and f.can_target_self() and buff < 0:
			buff = k
		elif f.is_weapon() and gun < 0:
			gun = k
	assert_true(buff >= 0 and gun >= 0, "its die carries a buff it may spend on itself and a gun")
	ms.face_index = buff
	s._refresh()
	assert_eq(s._dice[0].form_mark, "seal", "open, its buff wears the seal chip")
	s._on_die_tapped(0)
	assert_true(s._details_entry.text().contains("Seals it"), "and its readout says so: %s" % s._details_entry.text())
	s._close_pop()
	assert_false(s._mech_views[0].shell, "open: no shell")
	assert_true(s._use_die(0, ms), "the buff spent on itself")
	assert_true(Effects.is_sealed(m), "sealed")
	assert_true(s._mech_views[0].shell, "the view wears its shell")
	sk.end_round()
	sk.start_round()
	ms.face_index = gun
	s._refresh()
	assert_eq(s._dice[0].form_mark, "unseal", "sealed, a weapon wears the opening chip")
	assert_eq(SkirmishScreen.status_glyph("sealed"), "seal", "the Sealed chip wears the seal's own mark")
	assert_eq(Terms.glyph("sealed"), "seal", "and the term in text")
	var other := db.make_mech("badger")
	var plain := Skirmish.MechState.new()
	plain.unit = other
	assert_eq(SkirmishScreen.form_mark(plain, other.die.faces[0]), "", "a machine with no form has no such chip")
	s.free()


func test_a_shot_crossing_the_field_follows_its_weapon() -> void:
	# The game's own (Ryan, 14 November: "Let's keep it"), no switch over it.
	assert_false(Settings.DISPLAY_DEFAULTS.has("shot_trails"), "no setting turns it off")
	# Synthetic components: the trail reads the tags and the reach, never an id.
	assert_eq(ShotTrail.kind_for({"tags": ["blade", "melee"], "face": {"reach": "direct"}}), -1, "melee lunges, no trail")
	assert_eq(ShotTrail.kind_for({"tags": ["beam"], "face": {"reach": "indirect"}}), ShotTrail.BEAM, "a laser is a beam whatever its reach")
	assert_eq(ShotTrail.kind_for({"tags": ["ballistic"], "face": {"reach": "indirect"}}), ShotTrail.ARC, "an indirect shot lobs")
	assert_eq(ShotTrail.kind_for({"tags": [], "face": {"reach": "direct"}}), ShotTrail.TRACER, "a direct shot is a tracer")
	var t := ShotTrail.make(ShotTrail.ARC, Vector2(300, 900), Vector2(100, 300), Color.ORANGE, 0.0, 0.05)
	assert_eq(t.flight, ShotTrail.MIN_FLIGHT, "a blow whose sound lands at once still flies")
	assert_true(t.arc_at(0.0).is_equal_approx(t.from) and t.arc_at(1.0).is_equal_approx(t.to), "the arc leaves the muzzle and lands on its target")
	var top := INF
	for k in range(21):
		top = minf(top, t.arc_at(float(k) / 20.0).y)
	assert_true(top < t.to.y, "the lob peaks above its target and drops onto it")
	assert_true(t.arc_at(0.5).x > (t.from.x + t.to.x) * 0.5, "and bows out to the side it came from, so it never lies along the shot")
	t._process(ShotTrail.MIN_FLIGHT + ShotTrail.HOLD + ShotTrail.FADE + 0.01)
	assert_true(t.is_queued_for_deletion(), "gone once it has landed and faded")


func test_a_shotgun_tagged_melee_fires_a_tracer() -> void:
	# Ryan, 3 November: "It's a shotgun, thematically". Synthetic components.
	assert_eq(ShotTrail.kind_for({"tags": ["ballistic", "melee"], "shape": "barrel", "face": {"reach": "direct"}}), ShotTrail.TRACER, "a shotgun tagged melee fires a tracer")
	assert_eq(ShotTrail.kind_for({"tags": ["blade", "melee"], "shape": "none", "face": {"reach": "direct"}}), -1, "a claw lunges, no trail")


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
	assert_true(s._log_text().find(SkirmishScreen.ROLL_BAR) >= 0, "the round's bar in the trail")
	assert_true(s._use_die(0, foe), "the die spent")
	assert_eq(s.sk.front[0].hp, hp - 1, "the blow landed")
	assert_false(s._undo_btn.disabled, "the undo opens")
	assert_eq(s._undo_btn.badge, "×1", "one spend back")
	var text := s._log_text()
	assert_true(text.find(SkirmishScreen.ROLL_BAR) < text.rfind("> "), "the bar sits under the opening lines, the spend's after it")
	s._on_undo()
	assert_eq([s.sk.front[0].hp, s.sk.mechs[0].assigned, s.sk.log.size()], [hp, false, opened], "the spend taken back")
	assert_true(s._undo_btn.disabled, "and nothing is left")
	s.free()


## UNDO opens once a spend's blow has played, on the clock that shut it (Ryan, 9 November:
## "skirmish undo, it doesn't work anymore": a tween timed to the same moment ran a frame ahead of
## the clock and left the button shut for good), and it sits bottom-right, END TURN's mirror, where
## the withdrawal was (Ryan: "Undo at least should move there").
func test_undo_opens_once_the_blow_has_played_and_sits_bottom_right() -> void:
	var s := _screen()
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.die = Die.single(Face.attack(1, Face.Reach.DIRECT))
	ms.die = ms.unit.die
	ms.face_index = 0
	s._refresh()
	assert_true(s._use_die(0, s.sk.front[0]), "the die spent")
	s._undo_from = Time.get_ticks_msec() + 100000   # its blow still playing
	s._undo_waiting = true
	s._refresh_undo()
	assert_true(s._undo_btn.disabled, "shut while the blow plays")
	s._process(0.016)
	assert_true(s._undo_btn.disabled, "and still, before the clock passes the mark")
	s._undo_from = Time.get_ticks_msec() - 1   # the clock past it
	s._process(0.016)
	assert_false(s._undo_btn.disabled, "then it opens of its own accord, nothing else asked")
	assert_false(s._undo_waiting, "and stops waiting")
	assert_eq(s._undo_btn.position, Vector2(SkirmishScreen.W - 16.0 - SkirmishScreen.BOTTOM_BTN.x, s.BOTTOM_Y), "bottom-right")
	assert_eq(s._undo_btn.position.y, s._end_btn.position.y, "on END TURN's row")
	assert_true(s._undo_btn.state_marked, "its on and off read by its edge")
	s.free()


## A foe's intent arrow leaves the middle of its intent chip (Ryan, 9 November: "the lines should come
## from the intent chip, and always from the intent chip's middle") and lands on the machine's middle,
## and the ranks stand slightly apart, the front a little left and the back a little right ("A slight
## offset or squeezing would fix the rest"), so one column's two foes at the machine below draw two
## lines; the outer foes' chip rows, held on the glass, keep their gap to their neighbours' (his
## question: "What happens to back rank enemies with a lot of chips if they're that close to the
## right edge?").
func test_an_intent_arrow_leaves_its_chips_middle_and_the_ranks_stand_slightly_apart() -> void:
	var s := _screen()
	for col in range(s.sk.columns):
		var f: UnitView = s._slot_views[0][col]
		var b: UnitView = s._slot_views[1][col]
		assert_eq(b.position.x - f.position.x, 2.0 * SkirmishScreen.RANK_SHIFT, "column %d: the back a little right of the front" % col)
		assert_true(f.position.x >= 0.0 and b.position.x + b.size.x <= SkirmishScreen.W, "column %d on the glass" % col)
	var last := s.sk.columns - 1
	var outer: UnitView = s._slot_views[1][last]
	var inner: UnitView = s._slot_views[1][last - 1]
	var oc := outer.position.x + outer.size.x * 0.5
	var start := minf(oc - outer.chip_wrap * 0.5, SkirmishScreen.W - 2.0 - outer.chip_wrap)   # its widest row, held on the glass
	var inner_end := inner.position.x + inner.size.x * 0.5 + inner.chip_wrap * 0.5
	assert_true(start - inner_end >= 6.0 - 0.01, "the back rank's last foe's widest row keeps its gap to its neighbour's")
	var fv := s._foe_view_for(s.sk.front[0])
	var laid := fv.chip_layout()
	assert_eq(str((laid[0][1] as Array)[3]), "intent", "the first chip is the intent's")
	assert_eq(fv.intent_anchor_global(), fv.get_global_transform() * (laid[0][0] as Rect2).get_center(), "its arrow leaves the chip's middle")
	s._toggle_all_arrows(true)
	var inv := s._arrows.get_global_transform().affine_inverse()
	var from := inv * fv.intent_anchor_global()
	assert_true(s._arrows.arrows.any(func(x: Array) -> bool: return (x[0] as Vector2).is_equal_approx(from)), "and the arrow drawn starts there")
	s.free()


## A status says what it is (Ryan, 9 November: "Buffs and debuffs ... need to be clearly labeled as
## such, so that it's clear what gets purged"): its row's line begins Buff or Debuff and its chip
## carries the word for its mark; an ability keeps its own.
func test_a_status_row_says_buff_or_debuff_and_its_chip_carries_it() -> void:
	var buff := SkirmishScreen.status_row("overcharged", "overcharge", "×2", "Empowered ×2", Palette.HEAT)
	assert_eq(str(buff[2]), "Buff, Empowered ×2", "a buff's line")
	assert_eq(str(buff[5]), "buff", "and its chip's mark")
	var debuff := SkirmishScreen.status_row("ablating", "ablate", "2", "Ablating ×2", Palette.HEAT)
	assert_eq(str(debuff[2]), "Debuff, Ablating ×2", "a debuff's line")
	assert_eq(str(debuff[5]), "debuff", "and its chip's mark")
	var plain := SkirmishScreen.status_row("quick_turned", "rapid", "", "Quick turn spent", Palette.INK)
	assert_eq([str(plain[2]), str(plain[5])], ["Quick turn spent", ""], "one that is neither keeps its words and wears no mark")
	var s := _screen()
	var m: Unit = s.sk.mechs[0].unit
	Effects.grant_buff(m, "overcharged", 2, "buff", s.sk.round)
	s._refresh()
	var v: UnitView = s._mech_views[0]
	assert_true(v.statuses.any(func(st: Array) -> bool: return st.size() >= 5 and str(st[4]) == "buff"), "the machine's view carries the buff's mark")
	s.free()


## A release plays on the screen (the Whip Scorpion's valves, 11 November): a machine that ends
## its turn with an entry it could have spent fires its heat once the enemy's turn has played, and
## the screen takes the fight as it stands after; its model fires it with the act keyed by the
## passive (release_key). Synthetic passive.
func test_a_passed_turns_release_plays_after_the_enemy_turn() -> void:
	var s := _screen(5)
	var ms: Skirmish.MechState = s.sk.mechs[0]
	ms.unit.grant_passive({"id": "boiler", "name": "Boiler", "description": "", "effects": [{"trigger": "static", "effect": "pass_release", "value": 1, "gate": 4}]})
	ms.heat = 6
	assert_eq(SkirmishScreen.release_key(ms), "boiler", "its model's firing for the release is keyed by the passive (the broadside, 12 November)")
	assert_eq(SkirmishScreen.release_key(s.sk.mechs[1]), "", "a machine whose pass releases nothing has none")
	assert_true(s.sk.can_spend(0), "its die has somewhere to go, and is left")
	var hp := 0
	for foe in s.sk.field_foes():
		hp += foe.hp
	var standing := s.sk.field_foes().size()
	s._end_turn_now()
	assert_eq(s.sk.releases.size(), 1, "it released")
	assert_eq((s.sk.releases[0]["blows"] as Array).size(), standing, "a blow on every foe that stood")
	var after := 0
	for foe in s.sk.field_foes():
		after += foe.hp
	assert_true(after < hp, "the pack took it")
	assert_true(s._shown_hp.is_empty(), "no gauge is left held off the tree")
	s.free()


## Sapped wears a chip of its own on the foe (11 November): the blade and the arrow down, its
## stacks as the blow it takes off.
func test_a_sapped_foe_wears_its_chip() -> void:
	var s := _screen(5)
	var foe: Foe = s.sk.front[0]
	var gained := {}
	var turned := {}
	s.sk._land_rider(foe, "sapped", 2, gained, turned)
	var found := false
	for r in s._foe_rows(foe):
		if r is Array and r.size() >= 3 and str(r[0]) == "sap" and str(r[1]) == "-2":
			found = true
	assert_true(found, "the chip: the sap glyph and -2")
	s.free()

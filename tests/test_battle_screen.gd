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
	# The ramp's field, the long wall's (its brief's Phase 2 lays the view for it), and the start
	# quiet: these tests read the screen's rules, not the opening's (TestCase.quiet_start).
	b.setup(team, "marsh")
	quiet_start(b)
	var s := BattleScreen.new()
	s.setup(b)
	return s


## A pack's hold says its threat rating first, after its name (the long wall brief 3.7): "A fight
## for one" to "four", the boss's included, and nothing else is added.
func test_a_packs_hold_names_its_threat_rating_after_its_name() -> void:
	var s := _screen()
	var words := ["one", "two", "three", "four"]
	var seen := 0
	for sq in s.battle.field.packs():
		var lines: Array = s.pack_lines(sq)
		assert_eq(str((lines[1] as Dictionary).get("text", "")), "A fight for %s" % words[sq.squad - 1], "%s's hold" % sq.display_name)
		seen += 1
	assert_true(seen >= 2, "every pack read, the boss among them")
	s.free()


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
	assert_eq(s._top.battle, s.battle, "the top bar reads the battle: the gate, the rift's spawn, the Fractures")
	assert_true(s._board._title().ends_with("TURN 01"), "turn one on the board under the map, the top bar carrying no turn (Ryan, 9 November)")
	for r in s._board._rows():
		assert_eq(r["order"], "READY", "every machine ready, on the board")
	assert_false(s._resolve_btn.disabled, "the turn can end")
	assert_eq(s._resolve_btn.text, "END TURN", "nothing ordered: the button ends the turn")
	assert_true(s._clear_btn.disabled, "nothing to undo yet")
	assert_true(s._map.field == s.battle.field, "map shows the field")
	assert_eq(s._map.walks.size(), s.battle.field.packs().size(), "every pack's walk on the map")
	assert_true(s._map.scroll_y <= 0.0, "scrolled to the gate end")
	s.free()


func test_a_tap_selects_and_a_lit_hex_plans_the_move() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	var start := m.pos
	s._on_hex_tapped(m.pos)
	assert_eq(s._map.selected, m, "mech selected")
	assert_true(s._map.destinations.size() > 0, "destinations lit")
	assert_false(s._map.threat.is_empty(), "and in violet where it could attack from past them")
	var dest: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(dest)
	assert_eq(m.pos, dest, "the battle has it there at once")
	assert_eq(s._map.shown[m.id][0], start, "the map shows it where it stood until the plan plays")
	assert_eq(s._map.plans.size(), 1, "with its route drawn")
	assert_eq(s._map.unit_at_shown(start), m, "a tap where it stands finds it")
	assert_eq(s._map.selected, m, "and it stays in hand, to pick a target from there")
	assert_false(s._clear_btn.disabled, "the move can be undone")
	assert_eq(s._clear_btn.text, "UNDO", "the button undoes whatever came last")
	s._on_undo()
	assert_eq(m.pos, start, "undo puts it back")
	assert_true(s._map.plans.is_empty() and s._map.shown.is_empty(), "and the plan with it")
	assert_true(s._clear_btn.disabled, "and there is nothing more to undo")
	assert_eq(s._map.selected, m, "the machine back in hand")
	s._on_hex_tapped(dest)
	s._on_end_turn()
	assert_true(s._map.plans.is_empty() and s._map.shown.is_empty(), "END TURN plays the plan")
	assert_eq(m.pos, dest, "and it stands where it went")
	s.free()


## A move entered reads EXECUTE, and EXECUTE plays it with the turn going on (Ryan, 2 November:
## "it shouldn't "end turn" when a command is entered. Movement should be able to be executed in
## sequence if the player wants, and undone"): no enemy turn, the next moves planned and played
## after it, and UNDO takes them back in order, each machine where it stood, nothing planned again.
func test_a_planned_move_reads_execute_and_plays_with_the_turn_going_on() -> void:
	var s := _screen()
	var b := s.battle
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var d: Unit = b.mechs()[2]
	var a0 := a.pos
	var c0 := c.pos
	var d0 := d.pos
	var packs := {}
	for sq in b.field.packs():
		packs[sq] = sq.pos
	s._on_hex_tapped(a.pos)
	var ha: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(ha)
	assert_eq(s._resolve_btn.text, "EXECUTE", "a move entered: the button executes it")
	s._on_main_button()
	assert_true(s._map.plans.is_empty() and s._map.shown.is_empty(), "EXECUTE plays the plan")
	assert_eq(a.pos, ha, "the machine stands where it went")
	assert_eq(b.field.phase, 0, "and the turn goes on")
	assert_eq(b.state, Battle.State.PLAN, "the player's still")
	for sq in packs.keys():
		assert_eq(sq.pos, packs[sq], "no pack walked")
	assert_eq(s._resolve_btn.text, "END TURN", "nothing waiting: the button ends the turn")
	assert_false(s._clear_btn.disabled, "and the move can still be undone")
	# Two more planned, then one EXECUTE plays both.
	var dests := {}
	for m in [c, d]:
		s._on_hex_tapped(m.pos)
		for h in s._map.destinations.keys():
			if h != ha and not dests.values().has(h):
				dests[m] = h
				break
		s._on_hex_tapped(dests[m])
	assert_eq(s._map.shown.get(c.id, [Vector2i.ZERO])[0], c0, "the next moves are planned from where their machines stand")
	assert_false(s._map.shown.has(a.id), "and the played one is not planned again")
	assert_eq(s._resolve_btn.text, "EXECUTE", "EXECUTE again")
	s._on_main_button()
	assert_eq([a.pos, c.pos, d.pos], [ha, dests[c], dests[d]], "all three played, in sequence")
	s._on_undo()
	assert_eq([a.pos, c.pos, d.pos], [ha, dests[c], d0], "UNDO takes the last back, the machine where it stood")
	assert_true(s._map.plans.is_empty() and s._map.shown.is_empty(), "with the move played before it not planned again")
	assert_eq(s._map.selected, d, "and back in hand to move again")
	s._on_undo()
	assert_eq(c.pos, c0, "then the one before")
	assert_true(s._map.plans.is_empty() and s._map.shown.is_empty(), "nothing planned")
	s._on_undo()
	assert_eq(a.pos, a0, "then the first")
	assert_true(s._clear_btn.disabled, "back to the turn's start")
	assert_eq(s._resolve_btn.text, "END TURN", "and the button ends the turn")
	s.free()


## ENGAGE still comes first with a fight ready, a move waiting or not; a move entered with nothing
## else left to do pulses EXECUTE, the next press.
func test_engage_comes_before_execute_and_execute_pulses_when_it_is_all_that_is_left() -> void:
	var s := _screen()
	var b := s.battle
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var sq: Unit = b.field.packs()[0]
	var home := sq.pos
	_engage(b, sq, a)
	s._refresh()
	s._on_hex_tapped(c.pos)
	s._on_hex_tapped(s._map.destinations.keys()[0])
	s._on_hex_tapped(a.pos)
	s._on_hex_tapped(sq.pos)
	assert_eq(b.order_of(a), sq, "one ordered")
	assert_false(b.planned.is_empty(), "and another's move waiting")
	assert_eq(s._resolve_btn.text, "ENGAGE", "the fight's button first")
	s._on_undo()
	assert_eq(s._resolve_btn.text, "EXECUTE", "the order taken back: the move's")
	for m in b.mechs():
		if m != c:
			b.spent[m.id] = 1   # nothing else for anyone to do
	sq.pos = home   # and the pack back where it spawned, out of reach of the one that moved
	s._refresh()
	assert_true(b.nothing_left(), "nothing left but the button")
	assert_eq(s._resolve_btn.text, "EXECUTE", "which executes the move")
	assert_true(s._resolve_btn.pulse, "and pulses")
	s.free()


## END TURN with a machine still able to move or fight asks first (Ryan, 2 November: "If end turn
## is hit and there are movements/actions remaining, it should alert the player"); NO keeps the
## turn, YES ends it; with nothing left it ends at once.
func test_end_turn_asks_while_a_machine_can_still_act() -> void:
	var s := _screen()
	var b := s.battle
	assert_eq(s._resolve_btn.text, "END TURN", "nothing entered")
	s._on_main_button()
	assert_true(s._confirm.visible and s._confirm_shade.visible, "END TURN asks first")
	assert_eq(s._confirm_text.text, "%d machines can still move or fight. End the turn anyway?" % b.mechs().size(), "in plain words")
	assert_eq(b.field.phase, 0, "and nothing has ended")
	s._hide_confirm()
	assert_false(s._confirm.visible, "NO puts it away")
	assert_eq(b.field.phase, 0, "with the turn as it was")
	s._on_main_button()
	s._confirm_yes()
	assert_false(s._confirm.visible, "YES puts it away")
	assert_eq(b.field.phase, 1, "and ends the turn")
	assert_true(s._board._title().ends_with("TURN 02"), "the next turn opens")
	assert_true(b.forced.is_empty(), "with no catch to fight first")
	for m in b.mechs():
		b.spent[m.id] = 1
	s._refresh()
	assert_true(s._resolve_btn.pulse, "nothing left: the button pulses")
	s._on_main_button()
	assert_false(s._confirm.visible, "and ends the turn without asking")
	assert_eq(b.field.phase, 2, "at once")
	s.free()


## A move played by EXECUTE is saved played: the save resumes with nothing planned, and its undo
## sets the machine back where it stood.
func test_an_executed_move_is_saved_played() -> void:
	const TMP := "user://test_screen_execute.json"
	SaveGame.clear(TMP)
	var s := _screen(4)
	s.autosave_enabled = true
	s.save_path = TMP
	var m: Unit = s.battle.mechs()[0]
	var start := m.pos
	s._on_hex_tapped(m.pos)
	var dest: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(dest)
	s._on_main_button()
	var loaded := SaveGame.load(TMP)
	assert_true(loaded.planned.is_empty(), "the save holds the move played, nothing planned")
	assert_eq(loaded.field.unit_by_id(m.id).pos, dest, "the machine where it went")
	var r := BattleScreen.new()
	r.setup(loaded)
	r._resume_where_it_was()
	assert_true(r._map.shown.is_empty(), "resumed, the map shows it there")
	assert_eq(r._resolve_btn.text, "END TURN", "with nothing to execute")
	r._on_undo()
	assert_eq(loaded.field.unit_by_id(m.id).pos, start, "and its undo sets it back where it stood")
	assert_true(r._map.plans.is_empty(), "with nothing planned again")
	r.free()
	s.free()
	SaveGame.clear(TMP)


func test_undo_takes_back_an_order_and_the_moves_in_the_order_made() -> void:
	var s := _screen()
	var b := s.battle
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, a)
	s._refresh()
	var c0 := c.pos
	s._on_hex_tapped(c.pos)
	var dest: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(dest)
	s._on_hex_tapped(a.pos)
	s._on_hex_tapped(sq.pos)
	assert_eq(b.order_of(a), sq, "ordered")
	s._on_undo()
	assert_eq(b.order_of(a), null, "the order comes back first")
	assert_eq(c.pos, dest, "the other machine's move still planned")
	s._on_undo()
	assert_eq(c.pos, c0, "then the move")
	assert_true(s._clear_btn.disabled, "and nothing is left")
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
	assert_true(s._board._title().ends_with("TURN 02"), "next turn")
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
	assert_true(s._board._title().begins_with("FIGHT"), "the board says so")
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
	assert_eq(s._board._rows().filter(func(r: Dictionary) -> bool: return r["order"] == "READY").size(), 2, "the board counts it out")
	s.free()


## A Fracture a fight earns is announced as the map comes back (Ryan, 9 November: "Fractures need
## to be announced. The fracture meter needs to be a prominent, always visible UI component"): the
## top bar's gauge flashes, and the bar reads the count the battle holds.
func test_a_fracture_earned_by_a_fight_is_announced_on_the_top_bar() -> void:
	var s := _screen()
	var b := s.battle
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	b.thresholds = [1, 100000, 200000]   # any kill earns the first
	_engage(b, sq, m)
	s._refresh()
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(sq.pos)
	s._on_main_button()
	var sk: Skirmish = s._skirmish.sk
	sk.reinforcements.clear()
	for f in sk.field_foes():
		f.hp = 0
	s._skirmish._end_turn_now()
	assert_false(s._top._flash.has("fractures"), "nothing earned until the fight is back")
	s._on_skirmish_back()
	assert_eq(b.fractures, 1, "the fight earned the first Fracture")
	assert_true(s._top._flash.has("fractures"), "the top bar's gauge flashes it")
	assert_true(b.is_sealed(), "the seal holds until the last")
	s.free()


## A pack's whole way shows while it is tapped, and a hunter's while the machine it comes for is in
## hand (Ryan, 9 November: "I would also show the hunter path when the hunted unit is tapped as
## well"); no other pack's.
func test_a_tapped_pack_and_a_hunted_machine_show_the_whole_way() -> void:
	var s := _screen()
	var b := s.battle
	var packs := b.field.packs().filter(func(p: Unit) -> bool: return not p.is_boss)
	var sq: Unit = packs[0]
	var other: Unit = packs[1] if packs.size() > 1 else null
	var m: Unit = b.mechs()[0]
	s._refresh()
	s._on_hex_tapped(sq.pos)
	var w: Battlefield.Walk = s._map.walks[sq.id]
	assert_true(s._map.shows_whole_way(sq, w), "the tapped pack's way")
	if other != null:
		assert_false(s._map.shows_whole_way(other, s._map.walks[other.id]), "and no other's")
	sq.behaviour = "hunt"
	sq.prey = m.id
	s._refresh()
	s._on_hex_tapped(m.pos)
	assert_eq(s._map.selected, m, "the hunted machine in hand")
	var hw: Battlefield.Walk = s._map.walks[sq.id]
	if hw.prey == m.id:
		assert_true(s._map.shows_whole_way(sq, hw), "its hunter's way shows")
	s.free()


## The boss stands far larger than a pack on the map (Ryan, 9 November: "enemy bosses need bigger
## map sprites ... very big and ominous").
func test_the_boss_draws_far_larger_than_a_pack() -> void:
	var s := _screen()
	var tex := ImageTexture.create_from_image(Image.create(16, 16, false, Image.FORMAT_RGBA8))
	var boss_size := BattleMapView.sprite_size(s.battle.boss, tex)
	var pack_size := BattleMapView.sprite_size(s.battle.field.packs()[0], tex)
	assert_eq(boss_size.y, BattleMapView.BOSS_SPRITE_H, "the boss at its height")
	assert_true(boss_size.y >= pack_size.y * 2.5, "far larger than a pack's")
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
				if k <= 2 and BattleMap.step_cost(b.field.map.terrain[h], carrier.traits) != BattleMap.STEP:
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


## A hunter's ring is drawn (Ryan, 8 November, of a catch from three hexes: "No indication of
## catch range"): round where its walk ends, where the catch is judged, holding every hex inside
## its ring and none past it; lit while it is tapped; none for a pusher; and while its catch waits,
## round where it stands, lit.
func test_a_hunters_ring_is_drawn_round_where_its_walk_ends() -> void:
	var s := _screen()
	var b := s.battle
	var packs: Array = b.field.packs().filter(func(u: Unit) -> bool: return not u.is_boss)
	for p in packs:
		p.behaviour = "push"
	var hunter: Unit = packs[0]
	var m: Unit = b.mechs()[0]
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	s._refresh()
	var rings: Array = s._map.hunter_rings()
	assert_eq(rings.size(), 1, "one hunter, one ring; the pushers draw none")
	var w: Battlefield.Walk = s._map.walks[hunter.id]
	assert_eq(rings[0]["pack"], hunter, "the hunter's")
	assert_eq(rings[0]["at"], w.end, "round where its walk ends")
	var ring: Dictionary = rings[0]["hexes"]
	var wrong: Array = []
	for h in b.field.map.all_hexes():
		var inside := Hex.distance(h, w.end) <= ContentDB.HUNTER_RING and not b.field.map.is_structure(h)
		if ring.has(h) != inside:
			wrong.append(h)
	assert_eq(wrong, [], "every hex its ring holds from the walk's end, and no other")
	assert_false(bool(rings[0]["lit"]), "at rest")
	s._on_hex_tapped(hunter.pos)
	assert_true(bool(s._map.hunter_rings()[0]["lit"]), "lit while the hunter is tapped")
	s._on_hex_tapped(hunter.pos)
	# Its catch waiting: round where it stands, lit, the machine it caught inside.
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	b._new_turn()
	s._after_step()
	rings = s._map.hunter_rings()
	assert_eq(rings.size(), 1, "the catch's hunter")
	assert_eq(rings[0]["at"], hunter.pos, "round where it stands")
	assert_true(bool(rings[0]["lit"]), "lit")
	assert_true((rings[0]["hexes"] as Dictionary).has(m.pos), "the machine it caught inside")
	s.free()


func test_a_hunters_catch_is_fought_first() -> void:
	var s := _screen()
	var b := s.battle
	var m: Unit = b.mechs()[0]
	var hunter: Unit = b.field.packs()[0]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	b._new_turn()
	s._after_step()
	assert_eq(s._resolve_btn.text, "ENGAGE", "the button reads ENGAGE with nobody ordered")
	assert_true(s._board._rows().any(func(r: Dictionary) -> bool: return r["order"] == "CAUGHT"), "the board says so")
	assert_false(s._map.attack.is_empty(), "the catch's fight shows")
	# The catch reads as the caught machine's attack order (Ryan, 2 November: "when caught, the
	# unit should show the attack order on the enemy that caught it for clarity").
	assert_true(s._map.order_pairs().has([m, hunter]), "the map draws its order onto the hunter")
	var row: Dictionary = {}
	for r in s._board._rows():
		if r["unit"] == m:
			row = r
	assert_eq(str(row.get("order", "")), "CAUGHT", "the board says it is caught")
	assert_eq(str(row.get("meets", "")), "> " + s._board._short(hunter.display_name), "and names its fight as an order does, in HUNTED BY's place")
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(hunter.pos)
	assert_eq(b.order_of(m), hunter, "ordered onto its hunter as well")
	assert_eq(s._map.order_pairs().filter(func(p: Array) -> bool: return p[0] == m).size(), 1, "it is still the one line")
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


## A hunter whose prey is sealed off takes the machine nearest it (Ryan, 29 October: "It's just
## punishing hiding"): its tag and the board follow the machine it comes for, and its readout
## says whom it takes and why.
func test_a_hunter_taking_a_machine_in_its_preys_place_says_so() -> void:
	var s := _screen()
	var b := s.battle
	var hunter: Unit = b.field.packs()[0]
	for p in b.field.packs():
		p.behaviour = "push"
	hunter.behaviour = "hunt"
	var sealed: Unit = b.mechs()[0]
	var taken: Unit = b.mechs()[1]
	hunter.prey = sealed.id
	var w := Battlefield.Walk.new()
	w.end = hunter.pos
	w.prey = taken.id
	w.catches = taken.id
	s._map.walks = {hunter.id: w}
	var text := ""
	for line in s.pack_lines(hunter):
		text += str((line as Dictionary).get("text", "")) + " / "
	assert_true(text.contains("Hunts"), "it still names its prey: %s" % text)
	assert_true(text.contains("Takes %s in its place: %s is sealed off" % [taken.display_name, sealed.display_name]), "and whom it takes instead: %s" % text)
	var meets := {}
	for row in s._board._rows():
		meets[(row["unit"] as Unit).id] = str(row["meets"])
	assert_true(str(meets[taken.id]).begins_with("HUNTED BY"), "the board marks the machine it comes for")
	assert_eq(str(meets[sealed.id]), "", "and not the one sealed off")
	s.free()


## The boss's fight plays the family's theme when there is one (Ryan, 25 September).
func test_the_boss_fight_plays_its_theme() -> void:
	var s := _screen()
	var b := s.battle
	b.rupture()   # the seal broken: the boss can be fought
	_engage(b, b.boss, b.mechs()[0])
	s._refresh()
	s._on_hex_tapped(b.mechs()[0].pos)
	s._on_hex_tapped(b.boss.pos)
	s._on_main_button()
	assert_true(b.boss_fight, "the boss's fight")
	assert_true(s._skirmish != null, "it opens")
	assert_true(s._board._title().begins_with("FIGHT"), "the board says so")
	assert_eq(s._skirmish.sk.mechs.size(), b.mechs().size(), "with every machine in it")
	assert_false(has_button(s._skirmish, "WITHDRAW"), "no withdrawing: no button for it (the long wall brief 7.5)")
	var want := Sound.boss_set(b.faction)
	assert_eq(s._skirmish.music_set, want if not want.is_empty() else "skirmish", "the fight plays the family's theme, or the skirmish's pick without one")
	s._on_skirmish_back()
	assert_false(b.boss_fight, "the flag drops on the way back")
	s.free()


## Every pack, machine and tear past the view's edge gets a tag at the edge it lies past, in
## either view (the long wall brief 7.1: a wall longer than a screen), inside the view and never
## overlapping another.
func test_offscreen_packs_get_edge_tags() -> void:
	var s := _screen()
	var tags: Array = s._map.offscreen_tags()
	var hidden := 0
	var m := BattleMapView.HEX_SIZE * 0.3
	var view: Rect2 = Rect2(Vector2.ZERO, s._map.size).grow(m)
	var things: Array = s.battle.field.packs() + s.battle.field.mechs()
	things.append_array(s.battle.field.tears)
	for thing in things:
		var c: Vector2 = s._map.to_screen(s._map.center(thing.pos if thing is Unit else thing["pos"]))   # center is map space; tags are judged on screen
		if not view.has_point(c):
			hidden += 1
	assert_true(hidden >= 1, "a long wall leaves packs off screen at the gate's end")
	assert_eq(tags.size(), hidden, "one tag for each thing off screen")
	for t in tags:
		var rect: Rect2 = t[0]
		assert_true(["top", "bottom", "left", "right"].has(str(t[2])), "a tag names its edge")
		assert_true(Rect2(Vector2.ZERO, s._map.size).encloses(rect), "tag inside the view")
	for i in range(tags.size()):
		for j in range(i + 1, tags.size()):
			assert_false((tags[i][0] as Rect2).intersects(tags[j][0] as Rect2), "tags do not overlap")
	var sq: Unit = s.battle.field.packs()[0]
	s._map.scroll_to_unit(sq)
	var still: Array = s._map.offscreen_tags()
	for t in still:
		assert_true(t[1] != sq, "the pack scrolled to has no tag")
	assert_eq(BattleMapView.foe_sprite_id(s.battle.boss), str(ContentDB.load_default().bosses_of("marsh")[0]), "boss uses its own art, the domain's first boss's")
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
	assert_eq(str(lines[1]["style"]), "bar", "its hull a gauge")
	assert_eq(str(lines[1]["text"]), "Hull %d/%d" % [m.hull, m.hull_max], "with its numbers")
	assert_false(s._details_entry.text().contains("Shield"), "no shield on the map: the shield is the fight's (the long wall brief 7.5)")
	assert_true(s._details_entry.text().contains("action"), "and its actions")
	assert_true(s._details_entry.text().contains("Move %d" % int(m.base["move"])), "and its move")
	s._on_hold_released()
	assert_false(s._details.visible, "hidden on release")
	var sq: Unit = s.battle.field.packs()[0]
	s._on_unit_held(sq)
	assert_true(s._details_entry.text().contains("×%d" % int(sq.member_list()[0][1])), "the pack's members, each at its count")
	assert_eq(s._details_entry.text().contains("Ring %d" % ContentDB.HUNTER_RING), sq.behaviour == "hunt", "its ring, the pounce, only when it hunts (the long wall brief 7.2)")
	assert_true(s._details_entry.text().contains("Marches") or s._details_entry.text().contains("Hunts"), "and what it is doing")
	s._on_unit_held(s.battle.boss)
	assert_eq(str(s._details_entry.lines[0]["type"]), "Boss", "the boss says so beside its name")
	# Its size is its own in content, apart from its being the boss (15 October): a massive boss
	# says so, a human-sized one does not (the slate's Matador leads the Marsh since 30 October).
	var massive := int(ContentDB.load_default().foes[BattleMapView.foe_sprite_id(s.battle.boss)].get("size", 1)) >= 2
	assert_eq(s._details_entry.text().contains("Massive"), massive, "boss readout gives its own size")
	assert_true(s._details.size.y >= s._details_entry.custom_minimum_size.y, "the panel holds its lines")
	s.free()


func test_the_ground_and_a_refusal_read_as_lines() -> void:
	var s := _screen()
	var water := BattleScreen.ground_lines(BattleMap.Terrain.WATER)
	assert_eq(str(water[0]["text"]), "WATER", "the ground's name heads it")
	var text := ""
	for l in water:
		text += EntryReadout.line_text(l) + "\n"
	assert_true(text.contains("Wade: Tracked, Walker, Wheeled (two move a hex)"), "the ground ways wade it, the price said: %s" % text)
	assert_true(text.contains("Cross: Hover, Flyer"), "a line a word, the ways under it: %s" % text)
	assert_true(text.contains("Packs wade it (two move a hex); a winged pack crosses it"), "and what the horde does, as a ground machine does (Ryan, 29 October): %s" % text)
	var mountain := BattleScreen.ground_lines(BattleMap.Terrain.MOUNTAIN, "towers")
	assert_eq(str(mountain[0]["text"]), "TOWERS", "a wall is named by what it is (Ryan, 29 October)")
	assert_eq(str(BattleScreen.ground_lines(BattleMap.Terrain.MOUNTAIN)[0]["text"]), "CRAGS", "rock spikes when the map gives no look")
	assert_eq(EntryReadout.line_text(mountain[1]), "Cross: Flyer", "a wall is the flyer's")
	assert_true(EntryReadout.line_text(mountain[2]).begins_with("Wall: Tracked, Walker, Wheeled, Hover"), "and a wall to the rest")
	assert_eq(EntryReadout.line_text(mountain[3]), "Packs never enter it; a winged pack crosses it", "and the horde's wall")
	var rough := BattleScreen.ground_lines(BattleMap.Terrain.ROUGH)
	assert_eq(EntryReadout.line_text(rough[1]), "Cross: every machine", "rough is ground to every machine")
	assert_eq(EntryReadout.line_text(rough[2]), "Packs cross it", "and to the horde")
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
	assert_true(not s._codex._body.text().is_empty(), "and its foe type's codex text")
	s._codex.close()
	s.free()


## The gate and the rift are no selection on the map (Ryan, 9 November: "The rift and wall no
## longer need to show their bars, nor be selectable"): a tap on either lets go of what was held
## and opens nothing, a double-tap no entry; their numbers are the top bar's.
func test_the_gate_and_the_rift_are_not_selectable() -> void:
	var s := _screen()
	var m: Unit = s.battle.mechs()[0]
	for h in [s.battle.field.map.gate, s.battle.field.map.rift]:
		s._on_hex_tapped(m.pos)
		assert_eq(s._map.selected, m, "a machine in hand")
		s._on_hex_tapped(h)
		assert_eq(s._map.selected, null, "a tap on the structure lets it go")
		assert_false(s._details.visible, "and opens no readout")
		s._on_hex_double_tapped(h)
		assert_false(s._codex.visible, "a double-tap opens no entry")
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
	assert_true(r2._board._title().begins_with("FIGHT"), "the field reads as in a fight")
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


## The long wall's two views (the long wall brief 7.1): with the wall at the left or at the
## bottom, the map opens on the gate's end with the gate in sight, the rift lies across the screen
## from it the way the view says, and a finger on any hex of the field reads that hex.
func test_either_view_opens_on_the_gate_and_reads_a_finger() -> void:
	var s := _screen()
	var map := s.battle.field.map
	for left in [true, false]:
		var view_name := "wall left" if left else "wall bottom"
		MapOrient.wall_left = left
		s._map.set_field(s.battle.field)
		var m: BattleMapView = s._map
		var view := Rect2(Vector2.ZERO, m.size)
		var gate := m.to_screen(m.center(map.gate))
		assert_true(view.has_point(gate), "%s: the gate opens in sight" % view_name)
		var rift := m.to_screen(m.center(map.rift))
		if left:
			assert_true(rift.x > gate.x and absf(rift.y - gate.y) < m.size.y, "%s: the rift lies right of the gate" % view_name)
		else:
			assert_true(rift.y < gate.y, "%s: the rift lies above the gate" % view_name)
		var read := 0
		for h in map.all_hexes():
			var c := m.center(h)
			m.scroll_x = m.size.x * 0.5 - c.x * m.zoom
			m.scroll_y = m.size.y * 0.5 - c.y * m.zoom
			m._clamp_scroll()
			var p := m.to_screen(c)
			if view.has_point(p):
				read += 1
				assert_eq(m.hex_at(p), h, "%s: a finger on %s reads it" % [view_name, str(h)])
		assert_eq(read, map.all_hexes().size(), "%s: every hex of the field can be scrolled to" % view_name)
	MapOrient.apply_setting()
	s.free()


## The fight queue (the long wall brief 7.4): two machines ordered onto two packs are two fights;
## the button reads ENGAGE 1 OF 2 and the map numbers both; once the first is fought the other
## order stands, the button reads ENGAGE and pulses until the player does something else.
func test_engage_counts_the_fights_waiting() -> void:
	var s := _screen()
	var b := s.battle
	var ms := b.mechs()
	var packs: Array = []
	for sq in b.field.packs():
		if not sq.is_boss:
			packs.append(sq)
	_engage(b, packs[0], ms[0])
	_engage(b, packs[1], ms[1])
	assert_true(b.order(ms[0], packs[0]), "the first machine ordered onto the first pack")
	assert_true(b.order(ms[1], packs[1]), "the second onto the second")
	s._refresh()
	assert_eq(b.fights_waiting().size(), 2, "two fights wait")
	assert_eq(b.fights_waiting()[0]["target"], packs[0], "the first order's first")
	assert_eq(s._resolve_btn.text, "ENGAGE 1 OF 2", "the button counts them")
	assert_eq(s._map.queue.size(), 2, "the map numbers both")
	var sk := b.engage()
	assert_true(sk != null and sk.packs.has(packs[0]), "ENGAGE opens the first")
	win_fight(sk)
	s._on_skirmish_back()
	assert_eq(b.fights_waiting().size(), 1, "the other order stands")
	assert_eq(b.order_of(ms[1]), packs[1], "intact")
	assert_eq(s._resolve_btn.text, "ENGAGE", "one left: the button names no count")
	assert_true(s._queue_pulse, "and it pulses: the next fight is waiting")
	s._select(ms[2])
	assert_false(s._queue_pulse, "until the player does something else")
	s.free()

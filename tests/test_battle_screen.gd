extends TestCase

## Drives the battle screen through its handlers without a window: select, move, order a
## machine onto a pack by a tap or a drag and ENGAGE, the skirmish and back, a hunter's catch,
## the enemy's turn, and the outcome overlay (bible section 4, the round row).


func _screen(seed_value: int = 3) -> BattleScreen:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "clydesdale", "kite"]:
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
	assert_eq(s._resolve_btn.text, "EXECUTE", "the button executes the machine in hand")
	assert_false(s._resolve_btn.disabled, "lit: a waypoint is laid")
	assert_false(s._clear_btn.disabled, "the move can be undone")
	assert_eq(s._clear_btn.text, "UNDO", "the button undoes whatever came last")
	s._on_undo()
	assert_eq(m.pos, start, "undo puts it back")
	assert_true(s._map.plans.is_empty() and s._map.shown.is_empty(), "and the plan with it")
	assert_true(s._clear_btn.disabled, "and there is nothing more to undo")
	assert_eq(s._map.selected, null, "nothing left of its plan: let go")
	assert_eq(s._resolve_btn.text, "END TURN", "and the button ends the turn")
	s._on_hex_tapped(m.pos)
	assert_eq(s._resolve_btn.text, "EXECUTE", "in hand with nothing laid ...")
	assert_true(s._resolve_btn.disabled, "... EXECUTE is dim")
	s._on_hex_tapped(dest)
	s._on_hex_tapped(dest)   # its latest waypoint: executed at once
	assert_true(s._map.plans.is_empty() and s._map.shown.is_empty(), "the tap on its waypoint plays the plan")
	assert_eq(m.pos, dest, "and it stands where it went")
	assert_eq(s._map.selected, null, "let go")
	s.free()


## Waypoints (Ryan, 22 November): each tap on a lit hex lays one and draws the reach again from it;
## a tap on an earlier one cuts back to it; a tap on the machine cancels the plan, its steps off
## the undo; a tap on another machine cancels it and takes that one.
func test_waypoints_are_laid_cut_back_and_cancelled_by_taps() -> void:
	var s := _screen()
	var b := s.battle
	var m: Unit = b.mechs()[0]
	var other: Unit = b.mechs()[1]
	var start := m.pos
	s._on_hex_tapped(start)
	var laid: Array = []
	while not s._map.destinations.is_empty() and laid.size() < 3:
		var h: Vector2i = s._map.destinations.keys()[0]
		s._on_hex_tapped(h)
		laid.append(h)
		assert_eq(s._map.selected, m, "still in hand")
	assert_true(laid.size() >= 2, "two waypoints laid")
	assert_eq(b.waypoints(m).size(), laid.size(), "a waypoint a tap")
	assert_eq(s._map.plans.size(), laid.size(), "every leg drawn")
	assert_eq(b.history.size(), laid.size(), "a step a waypoint")
	s._on_hex_tapped(laid[0])
	assert_eq(b.waypoints(m), [laid[0]] as Array[Vector2i], "an earlier waypoint cuts back to it")
	assert_eq(b.history.size(), 1, "its later steps off the undo")
	assert_eq(s._map.selected, m, "still in hand")
	s._on_hex_tapped(start)   # the machine itself, drawn where it started
	assert_eq(m.pos, start, "cancelled: back where it stood")
	assert_eq(s._map.selected, null, "and let go")
	assert_false(b.can_undo(), "nothing queued to undo")
	s._on_hex_tapped(start)
	s._on_hex_tapped(s._map.destinations.keys()[0])
	s._on_hex_tapped(other.pos)
	assert_eq(m.pos, start, "another machine tapped: the plan in hand cancelled")
	assert_eq(s._map.selected, other, "and that one in hand")
	assert_false(b.can_undo(), "its steps gone")
	s._on_hex_tapped(b.map.rift)
	assert_eq(s._map.selected, null, "a tap out of reach lets it go")
	s.free()


## UNDO follows the steps back across machines, taking each in hand while it has a plan left
## (Ryan, 22 November, his own example: a Skua lays a waypoint and an order and executes, a
## Badger lays two waypoints; five UNDOs take them back one at a time).
func test_undo_walks_back_across_machines_selecting_each() -> void:
	var s := _screen()
	var b := s.battle
	var skua: Unit = b.mechs()[0]
	var badger: Unit = b.mechs()[1]
	var sq: Unit = b.field.packs()[0]
	var s0 := skua.pos
	s._on_hex_tapped(s0)
	var wp: Vector2i = s._map.destinations.keys()[0]
	for h in s._map.destinations.keys():
		if int(s._map.destinations[h]) == 1:
			wp = h
			break
	s._on_hex_tapped(wp)
	# A pack beside the waypoint, for the order.
	for n in Hex.neighbors(wp):
		if b.field.can_stand(sq, n) and b.field.unit_at(n) == null:
			sq.pos = n
			break
	sq.behaviour = "push"
	s._select(skua)
	s._on_hex_tapped(sq.pos)
	assert_eq(b.order_of(skua), sq, "ordered from its waypoint, beside the pack")
	assert_eq(b.waypoints(skua), [wp] as Array[Vector2i], "no further move for it")
	s._on_hex_tapped(sq.pos)   # the pack it is ordered onto: executed
	assert_true(b.played.has(skua.id), "the Skua's move played")
	assert_eq(s._map.selected, null, "let go")
	assert_eq(s._resolve_btn.text, "ENGAGE", "with nothing in hand, the fight is ready")
	s._on_hex_tapped(badger.pos)
	var b0 := badger.pos
	for i in range(2):
		var h: Vector2i = Vector2i(-9999, -9999)
		for d in s._map.destinations.keys():
			if not Hex.are_adjacent(d, sq.pos) and d != sq.pos:
				h = d
				break
		s._on_hex_tapped(h)
	assert_eq(b.waypoints(badger).size(), 2, "the Badger's two waypoints")
	s._on_undo()
	assert_eq(b.waypoints(badger).size(), 1, "its last waypoint first")
	assert_eq(s._map.selected, badger, "in hand")
	s._on_undo()
	assert_eq(badger.pos, b0, "then its first")
	assert_eq(s._map.selected, null, "nothing left: let go")
	s._on_undo()
	assert_false(b.played.has(skua.id), "the Skua's execute undone")
	assert_eq(s._map.shown[skua.id][0], s0, "warped back where it stood")
	assert_eq(b.order_of(skua), sq, "its order intact")
	assert_eq(s._map.selected, skua, "and in hand")
	s._on_undo()
	assert_eq(b.order_of(skua), null, "then its order")
	assert_eq(s._map.selected, skua, "still in hand")
	s._on_undo()
	assert_eq(skua.pos, s0, "then its waypoint")
	assert_eq(s._map.selected, null, "and let go")
	assert_false(b.can_undo(), "the turn as it opened")
	s.free()


## EXECUTE plays the machine in hand's move with the turn going on (Ryan, 22 November: "Tapping
## Execute is analogous to the execute above"): no enemy turn, the next machine's moves laid and
## played after it, and UNDO takes them back in order.
func test_execute_plays_the_machine_in_hand_and_the_turn_goes_on() -> void:
	var s := _screen()
	var b := s.battle
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var a0 := a.pos
	var c0 := c.pos
	var packs := {}
	for sq in b.field.packs():
		packs[sq] = sq.pos
	s._on_hex_tapped(a.pos)
	var ha: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(ha)
	assert_eq(s._resolve_btn.text, "EXECUTE", "a waypoint laid: the button executes it")
	s._on_main_button()
	assert_true(s._map.plans.is_empty() and s._map.shown.is_empty(), "EXECUTE plays the plan")
	assert_true(s._map.destinations.is_empty(), "and turns the reach off (Ryan, 16 November: \"When Execute is clicked, the movement range overlay should turn off if visible\")")
	assert_eq(s._map.selected, null, "the machine let go")
	assert_eq(a.pos, ha, "the machine stands where it went")
	assert_eq(b.field.phase, 0, "and the turn goes on")
	for sq in packs.keys():
		assert_eq(sq.pos, packs[sq], "no pack walked")
	assert_eq(s._resolve_btn.text, "END TURN", "nothing in hand: the button ends the turn")
	s._on_hex_tapped(c.pos)
	var hc: Vector2i = s._map.destinations.keys()[0]
	s._on_hex_tapped(hc)
	assert_false(s._map.shown.has(a.id), "the played one is not planned again")
	s._on_main_button()
	assert_eq([a.pos, c.pos], [ha, hc], "both played, in sequence")
	s._on_undo()
	assert_eq(s._map.selected, c, "UNDO takes the last execute back, its machine in hand")
	assert_eq(s._map.shown[c.id][0], c0, "shown where it stood, its waypoint laid")
	s._on_undo()
	assert_eq(c.pos, c0, "then its waypoint")
	s._on_undo()
	s._on_undo()
	assert_eq(a.pos, a0, "then the first's")
	assert_true(s._clear_btn.disabled, "back to the turn's start")
	s.free()


## EXECUTE shows only with a machine in hand; with none, ENGAGE comes first with a fight ready,
## and only the button with nothing in hand pulses.
func test_execute_is_the_machine_in_hands_and_engage_the_rest() -> void:
	var s := _screen()
	var b := s.battle
	var a: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, a)
	s._refresh()
	s._on_hex_tapped(a.pos)
	s._on_hex_tapped(sq.pos)
	assert_eq(b.order_of(a), sq, "ordered")
	assert_eq(s._resolve_btn.text, "EXECUTE", "in hand: the button executes")
	s._on_hex_tapped(sq.pos)
	assert_eq(s._map.selected, null, "the second tap on the pack executes and lets go")
	assert_eq(s._resolve_btn.text, "ENGAGE", "the fight's button")
	for m in b.mechs():
		if m != a:
			b.spent[m.id] = 1   # nothing else for anyone to do
	s._refresh()
	assert_true(b.nothing_left(), "nothing left but the button")
	assert_true(s._resolve_btn.pulse, "which pulses")
	s._select(b.mechs()[1])
	s._refresh()
	assert_false(s._resolve_btn.pulse, "but not while a machine is in hand")
	assert_true(s._resolve_btn.disabled, "whose EXECUTE is dim with nothing laid")
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
	assert_eq(r._map.shown[m.id][0], start, "and its undo sets it back where it stood")
	assert_eq(r._map.selected, loaded.field.unit_by_id(m.id), "its plan in hand again")
	r.free()
	s.free()
	SaveGame.clear(TMP)


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
	assert_eq(s._map.selected, m, "the machine still in hand")
	assert_false(s._map.attack.is_empty(), "the map shows the fight")
	assert_true((s._map.attack["committed"] as Array).has(m), "with the machine in it")
	s._on_hex_tapped(m.pos)
	assert_eq(b.order_of(m), null, "a tap on the machine cancels the order")
	assert_eq(s._map.selected, null, "and lets it go")
	assert_eq(s._resolve_btn.text, "END TURN", "and the button ends the turn again")
	s._on_hex_tapped(m.pos)
	s._on_hex_tapped(sq.pos)
	s._on_hex_tapped(sq.pos)   # executed
	assert_eq(s._resolve_btn.text, "ENGAGE", "the button reads ENGAGE")
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


## A pack's whole way shows while it is tapped, and no other's: not a hunter's while the machine
## it comes for is in hand (Ryan, 10 November: "When a machine is selected, don't need to see the
## whole hunter path to them").
func test_a_tapped_pack_alone_shows_its_whole_way() -> void:
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
	assert_false(s._map.shows_whole_way(sq, s._map.walks[sq.id]), "its hunter's whole way stays put away")
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


## What a pack comes for is the thing it attacks (Ryan, 10 November: "The "target" hexes for
## pushers and hunters should be the thing they're attacking. So an actual wall segment, and the
## actual machine"): a hunter's is the machine it hunts, where the map shows it; a pusher's is a
## hex of the wall or the gate beside where its way ends. And a landing that attacks says so: a
## walk that ends with a strike or a catch (attacks_on_landing), no other.
func test_a_packs_target_is_the_thing_it_attacks() -> void:
	var s := _screen()
	var b := s.battle
	var packs: Array = b.field.packs().filter(func(u: Unit) -> bool: return not u.is_boss)
	for p in packs:
		p.behaviour = "push"
	var hunter: Unit = packs[0]
	var pusher: Unit = packs[1]
	var m: Unit = b.mechs()[0]
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	s._refresh()
	var hw: Battlefield.Walk = s._map.walks[hunter.id]
	assert_eq(s._map.target_hex(hunter, hw), m.pos, "the hunter's target is the machine it comes for")
	var pw: Battlefield.Walk = s._map.walks[pusher.id]
	var wall: Vector2i = s._map.target_hex(pusher, pw)
	assert_true(wall != BattleMapView.NO_TARGET, "the pusher has a target")
	assert_true(b.field.map.is_structure(wall), "a hex of the wall or the gate, the thing it strikes")
	var from: Vector2i = pw.route[pw.route.size() - 1] if not pw.route.is_empty() else pw.end
	assert_eq(Hex.distance(wall, from), 1, "beside where its way ends")
	assert_false(BattleMapView.attacks_on_landing(pw) and not pw.strikes, "a landing warns only when it attacks")
	var struck := Battlefield.Walk.new()
	struck.strikes = true
	var caught := Battlefield.Walk.new()
	caught.catches = m.id
	assert_true(BattleMapView.attacks_on_landing(struck), "a strike from the landing hex is an attack")
	assert_true(BattleMapView.attacks_on_landing(caught), "a catch from it too")
	assert_false(BattleMapView.attacks_on_landing(Battlefield.Walk.new()), "a plain walk is none")
	s.free()


## A machine's order can be given again (Ryan, 10 November: "If I order a unit to move or engage,
## I should be able to re-order them by tapping on them again. Tapping on them when they are
## selected should cancel the order"; "When I tap a unit to cancel its order, it should
## deselect"; "The undo grows infinitely when I take back a move"): in hand it shows its reach
## from where it started; a new move replaces the planned one, one step on the undo where there
## was one; a tap on it takes its order back, lets it go and takes its step off the undo; and
## another machine's step given since keeps its own, forgetting the plan taken back.
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
	s._on_hex_tapped(hunter.pos)   # executed
	var other: Unit = b.field.packs()[1]
	s._on_hex_tapped(b.mechs()[1].pos)
	s._on_hex_tapped(other.pos)
	assert_eq(b.order_of(b.mechs()[1]), null, "another pack cannot be ordered on first")
	s._on_hex_tapped(b.mechs()[1].pos)   # let go
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
	b.rupture()   # the seal broken: the boss can be fought
	_engage(b, b.boss, b.mechs()[0])
	s._refresh()
	s._on_hex_tapped(b.mechs()[0].pos)
	s._on_hex_tapped(b.boss.pos)
	s._on_hex_tapped(b.boss.pos)
	s._on_main_button()
	assert_true(b.boss_fight, "the boss's fight")
	assert_true(s._skirmish != null, "it opens")
	assert_true(s._board._title().begins_with("FIGHT"), "the board says so")
	assert_eq(s._skirmish.sk.mechs.size(), b.mechs().size(), "with every machine in it")
	assert_false(has_button(s._skirmish, "WITHDRAW"), "no withdrawing: no button for it (the long wall brief 7.5)")
	var want := Sound.boss_set(b.faction)
	assert_eq(s._skirmish.music_set, want if not want.is_empty() else "skirmish", "the fight plays the family's theme, or the battle's pair on its battle half without one")
	s._on_skirmish_back()
	assert_false(b.boss_fight, "the flag drops on the way back")
	s.free()


## Every pack and machine past the view's edge gets a tag at the edge it lies past, in either
## view (the long wall brief 7.1: a wall longer than a screen), inside the view and never
## overlapping another.
func test_offscreen_packs_get_edge_tags() -> void:
	var s := _screen()
	var tags: Array = s._map.offscreen_tags()
	var hidden := 0
	var m := BattleMapView.HEX_SIZE * 0.3
	var view: Rect2 = Rect2(Vector2.ZERO, s._map.size).grow(m)
	var things: Array = s.battle.field.packs() + s.battle.field.mechs()
	for thing in things:
		var c: Vector2 = s._map.to_screen(s._map.center(thing.pos))   # center is map space; tags are judged on screen
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


## The board says what the gate takes next (10 November): the strikes the enemy's turn will land
## and what they take off its bar together, each by its pack's threat rating and what a fight has
## left of it (Battlefield.strike_of).
func test_the_board_says_what_the_gate_takes_next() -> void:
	var s := _screen()
	var f: Battlefield = s.battle.field
	var sq := Unit.pack(0, "revenants", Vector2i.ZERO, "marsh", 2, 6, "revenant")
	sq.squad = 3
	var placed := false
	for col in range(f.map.width):   # an apron hex nothing stands on, wherever this seed's map has one
		var h := Hex.offset_to_axial(col, f.apron_row())
		if not placed and f.on_apron(sq, h) and f.can_stand(sq, h) and f.unit_at(h) == null:
			sq.pos = h
			placed = true
	f.add_unit(sq)
	assert_true(placed and f.on_apron(sq, sq.pos), "the pack stands on the apron")
	s._refresh()
	var gate_line := ""
	for l in s._board._field_lines():
		if str(l[0]).begins_with("GATE //"):
			gate_line = str(l[0])
	var want := 0
	var count := 0
	for k in s._map.walks.keys():
		if (s._map.walks[k] as Battlefield.Walk).strikes:
			count += 1
			want += Battlefield.strike_of(f.unit_by_id(int(k)))
	assert_true(count >= 1, "a strike is planned")
	assert_eq(gate_line, "GATE // %d STRIKE%s NEXT // -%d" % [count, "" if count == 1 else "S", want], "the board counts the strikes and what they take")
	sq.strength = 3
	s._refresh()
	var worn := ""
	for l in s._board._field_lines():
		if str(l[0]).begins_with("GATE //"):
			worn = str(l[0])
	assert_true(worn.ends_with("-%d" % (want - 3 * Battlefield.STRIKE_PER_PIP + Battlefield.strike_of(sq))), "worn to half, it takes half as much: %s" % worn)
	s.free()


## A tear has no edge tag, as the rift has none (Ryan, 10 November: "Tear doesn't need an edge
## tag, same way the rift doesn't"): wherever the map looks, every tag is a unit's.
func test_a_tear_has_no_edge_tag() -> void:
	var s := _screen()
	var f: Battlefield = s.battle.field
	f.peak()
	assert_false(f.tears.is_empty(), "a peak opens a tear")
	for end in ["top", "bottom"]:
		if end == "top":
			s._map.scroll_to_top()
		else:
			s._map.scroll_to_bottom()
		for t in s._map.offscreen_tags():
			assert_true(t[1] is Unit, "a tag stands for a unit, never a tear")
	s.free()


## A peak is shown after the packs' walks, never under them (Ryan, 10 November: a tear "needs ...
## an animation/cutscene when one opens. And an animation/cutscene when the seam moves, too"):
## the map holds the seam where it stood and the new tear unseen until the cutscene plays, then
## shows the field as it is and hands on. Headless nothing plays, so it hands on at once.
func test_a_peak_is_held_until_its_cutscene_plays() -> void:
	var s := _screen()
	var f: Battlefield = s.battle.field
	var seam := f.seam_row
	var tears := f.tears.size()
	s._map.hold_peak()
	f.peak()
	assert_eq(s._map.seam_shown, float(seam), "the seam drawn where it stood")
	assert_eq(s._map.tears_shown, tears, "the new tear not drawn yet")
	var grad_held: Vector2 = Bleed.gradient(f, Vector2.ZERO, 48.0, s._map.seam_shown)
	var grad_now: Vector2 = Bleed.gradient(f, Vector2.ZERO, 48.0)
	assert_true(grad_now.x > grad_held.x, "the painting's edge as held stands short of the field's")
	var handed := [false]
	s._map.play_peak(func() -> void: handed[0] = true)
	assert_true(handed[0], "the cutscene hands on")
	assert_false(s._map.cutscene_playing(), "and is over")
	assert_eq(s._map.seam_shown, -1.0, "the seam drawn as the field has it")
	assert_eq(s._map.tears_shown, -1, "and every tear")
	# A turn with no peak hands on the same way.
	s._map.hold_peak()
	handed[0] = false
	s._map.play_peak(func() -> void: handed[0] = true)
	assert_true(handed[0], "nothing to show: at once")
	s.free()


## Every hunter that turns on a machine in a turn is declared, each in its turn (Ryan, 10
## November: "We should pan and zoom to hunters when they acquire as well"; one a turn before,
## the first lock's): the map hands each pair to the screen's declaration and then hands on.
## Headless nothing glides, so all of it happens at once and the view is left as it was.
func test_every_lock_of_a_turn_is_declared() -> void:
	var s := _screen()
	var packs: Array = s.battle.field.packs()
	var m: Unit = s.battle.mechs()[0]
	var locks := [[packs[0], m], [packs[1], m]]
	var told: Array = []
	var handed := [false]
	var view := Vector3(s._map.scroll_x, s._map.scroll_y, s._map.zoom)
	s._map.play_locks(locks, func(h: Unit, p: Unit) -> void: told.append([h, p]), func() -> void: handed[0] = true)
	assert_eq(told.size(), 2, "both locks declared")
	assert_true(told[0][0] == packs[0] and told[1][0] == packs[1] and told[1][1] == m, "each hunter with its prey, in order")
	assert_true(handed[0], "then it hands on")
	assert_false(s._map.cutscene_playing(), "nothing left playing")
	assert_eq(Vector3(s._map.scroll_x, s._map.scroll_y, s._map.zoom), view, "the view where the player had it")
	handed[0] = false
	s._map.play_locks([], func(_h: Unit, _p: Unit) -> void: told.append([]), func() -> void: handed[0] = true)
	assert_true(handed[0] and told.size() == 2, "no lock: it hands on and declares nothing")
	s.free()


## The painting's edge stands on the seam (Ryan, 10 November: "The point of the seam was to
## visually represent where the tears can open"): the seam's own row is the painting's, where a
## tear opens, and the row past it the reconstruction's, at the start and after every creep, in
## either view.
func test_the_paintings_edge_stands_on_the_seam() -> void:
	var s := _screen()
	var f: Battlefield = s.battle.field
	var was := Bleed.everywhere
	Bleed.everywhere = false
	var none := PackedVector3Array()
	for step in range(4):
		var grad := Bleed.gradient(f, Vector2.ZERO, 48.0)
		var col := Hex.axial_to_offset(f.map.gate).x
		var on := MapOrient.to_pixel(Hex.offset_to_axial(col, f.seam_row), 48.0)
		var past := MapOrient.to_pixel(Hex.offset_to_axial(col, f.seam_row + 1), 48.0)
		assert_eq(Bleed.solid(on, grad, none), 0.0, "the seam's row %d is the painting's" % f.seam_row)
		assert_eq(Bleed.solid(past, grad, none), 1.0, "the row past it is solid ground")
		f.peak()
	Bleed.everywhere = was
	s.free()


## The boss's picture on the map is its own, drawn for its size (10 November: its 16-pixel token
## blown up to that size was a blob): every foe that can stand as the boss, a domain's bosses and
## its bench, has one wherever it has a combat sprite to cut it from (tools/foeforge `boss`),
## larger than its token, and every picture in art/foes names such a foe, so a renamed id or a
## new boss's art fails here until the cut is run again.
func test_every_boss_has_its_map_picture() -> void:
	var db := ContentDB.load_default()
	var can_lead := {}
	for fid in db.factions.keys():
		for id in db.bosses_of(str(fid)) + db.bench_of(str(fid)):
			can_lead[str(id)] = true
	assert_false(can_lead.is_empty(), "content names its bosses")
	for id in can_lead.keys():
		if not ResourceLoader.exists("res://art/foes/%s_combat.png" % id):
			continue
		assert_true(ResourceLoader.exists("res://art/foes/%s_boss.png" % id), "%s has its map picture (tools/foeforge/forge.py boss)" % id)
		var pic := Sprites.map_boss(str(id))
		var token := Sprites.map_foe(str(id))
		if pic != null and token != null:
			assert_true(pic.get_height() > token.get_height(), "%s's picture is drawn larger than its token" % id)
	for f in DirAccess.get_files_at("res://art/foes"):
		if f.ends_with("_boss.png"):
			assert_true(can_lead.has(f.trim_suffix("_boss.png")), "%s is a boss or a bench hero content names" % f)
	var s := _screen()
	var boss: Unit = s.battle.boss
	var tex := BattleMapView.foe_picture(boss)
	assert_true(tex != null, "the battle's boss has a picture")
	assert_eq(BattleMapView.sprite_size(boss, tex).y, BattleMapView.BOSS_SPRITE_H, "and stands at the boss's size")
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
	assert_false(s._details_entry.text().contains("Ring"), "no ring line: a hunter catches at the engage range everyone shares (10 November)")
	assert_true(s._details_entry.text().contains("Marches") or s._details_entry.text().contains("Hunts"), "and what it is doing")
	if sq.behaviour != "hunt":
		assert_true(s._details_entry.text().contains("striking it for %d" % Battlefield.strike_of(sq)), "a pusher's panel says what it strikes the gate for (10 November): %s" % s._details_entry.text())
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
	s._select(null)
	s._refresh()
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


func test_the_rift_shell_cracks_a_plate_a_fracture_and_bursts_at_the_rupture() -> void:
	# The rift's shell over the seven hexes beside it (the bible's pacing row; built 16 November): a
	# plate cracked for each Fracture earned, the shell burst at the Rupture. What the map finds
	# already cracked or broken shows as it is; what changes while it watches plays.
	var b := Battle.new(3)
	var db := ContentDB.load_default()
	b.setup([db.make_mech("badger"), db.make_mech("kite")], "meadow")
	var screen: BattleScreen = load("res://game/battle/battle_screen.tscn").instantiate()
	screen.setup(b)
	var map: BattleMapView = screen._map
	assert_true(map._shell_up and map._shell_cracked == 0, "whole and standing as the battle opens")
	assert_true(map._shell_crack_at.is_empty() and map._shell_burst_at < 0.0, "nothing played for what it found")
	b.fractures = 1
	screen._refresh()
	assert_eq(map._shell_cracked, 1, "a Fracture cracks a plate")
	assert_true(map._shell_crack_at.has(0), "and its crack plays")
	b.fractures = b.thresholds.size()
	b.rupture()
	screen._refresh()
	assert_false(map._shell_up, "the Rupture breaks the shell")
	assert_true(map._shell_burst_at >= 0.0, "and its burst plays")
	assert_true(b.field.shell.is_empty(), "and the seven are open to the machines")
	screen.free()


## EXECUTE ends the action of every machine it moves (Ryan, 16 November: "if an attack wasn't
## ordered, it cannot attack ... Once execute is run, the action is forfeit (barring undo, of
## course)"): the machine in hand is let go, a pack beside where it stopped cannot be ordered on,
## and UNDO gives the action back with the move.
func test_execute_lets_the_machine_go_and_its_action_is_over() -> void:
	var s := _screen()
	var b := s.battle
	var a: Unit = b.mechs()[0]
	var a0 := a.pos
	var sq: Unit = b.field.packs()[0]
	# A move that ends beside a pack.
	var stop := Vector2i(-9999, -9999)
	s._on_hex_tapped(a.pos)
	for h in s._map.destinations.keys():
		for n in Hex.neighbors(h):
			if b.field.can_stand(sq, n) and b.field.unit_at(n) == null:
				stop = h
				sq.pos = n
				break
		if stop != Vector2i(-9999, -9999):
			break
	assert_true(stop != Vector2i(-9999, -9999), "a move that ends beside a pack")
	sq.behaviour = "push"
	s._select(a)
	s._on_hex_tapped(stop)
	assert_eq(s._map.selected, a, "laid, the machine stays in hand for an attack from the waypoint")
	assert_false(s._map.threat.is_empty(), "its reach for one drawn")
	s._on_main_button()
	assert_eq(a.pos, stop, "the move played")
	assert_eq(s._map.selected, null, "the machine let go")
	assert_true(s._map.destinations.is_empty() and s._map.threat.is_empty(), "nothing lit")
	assert_eq(b.actions_left(a), 0, "its action over")
	s._on_hex_tapped(a.pos)
	s._on_hex_tapped(sq.pos)
	assert_eq(b.order_of(a), null, "the pack beside it cannot be ordered on")
	assert_true(s._resolve_btn.disabled, "nothing to execute")
	s._select(null)
	s._refresh()
	assert_eq(s._resolve_btn.text, "END TURN", "no fight waiting")
	s._on_undo()
	assert_eq(s._map.shown[a.id][0], a0, "UNDO takes the execute back, the machine where it stood")
	assert_eq(b.actions_left(a), 1, "and gives the action back")
	s.free()

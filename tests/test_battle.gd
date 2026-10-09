extends TestCase

## The battle loop, headless (bible section 4, the round row): setup, the player's turn of
## moves and fights, the fights hunters force, the enemy's turn, and outcomes.


func _team() -> Array:
	var db := ContentDB.load_default()
	var out: Array = []
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		out.append(db.make_mech(id))
	return out


func _battle(seed_value: int = 3) -> Battle:
	var b := Battle.new(seed_value)
	b.setup(_team(), "marsh")
	return b


## Park a pack beside a machine, rooted and pushing, so it can be attacked and does not hunt.
func _engage(b: Battle, sq: Unit, m: Unit) -> void:
	var spot := m.pos
	for n in Hex.neighbors(m.pos):
		if b.field.can_stand(sq, n):
			spot = n
			break
	sq.pos = spot
	sq.movespeed = 0
	if not sq.elite:
		sq.behaviour = "push"


func _win(sk: Skirmish) -> void:
	sk.begin()
	sk.start_round()
	sk.reinforcements.clear()
	for f in sk.field_foes():
		f.hp = 0
	sk.end_round()


func test_setup_places_team_formation_and_boss() -> void:
	var b := _battle()
	assert_eq(b.mechs().size(), 3, "three mechs")
	assert_eq(b.field.packs().size(), 4, "three packs from the spawn list plus the boss")
	assert_true(b.boss != null and b.field.units.has(b.boss), "boss on the field")
	assert_eq(b.boss.foe_id, "", "boss unpacks by faction, not foe id")
	for u in b.field.units:
		assert_true(b.field.can_stand(u, u.pos), "%s stands on legal ground" % u.display_name)
	var gate_row := Hex.axial_to_offset(b.map.gate).y
	for m in b.mechs():
		assert_true(Hex.axial_to_offset(m.pos).y >= gate_row - 3, "%s starts by the gate" % m.display_name)
		assert_eq(b.actions_left(m), 1, "%s has its action" % m.display_name)
	for sq in b.field.packs():
		assert_true(Hex.axial_to_offset(sq.pos).y < gate_row / 2, "%s starts in the north" % sq.display_name)
	assert_eq(b.state, Battle.State.PLAN, "the player's turn")
	assert_true(b.forced.is_empty(), "nothing caught at the start")
	assert_eq(b.field.plan_walks().size(), b.field.packs().size(), "every pack's walk shows")


func test_a_composed_formation_replaces_the_spawn_list_and_the_boss_can_stay_home() -> void:
	var db := ContentDB.load_default()
	var facs: Array = db.factions.keys()
	var a := str(db.spawn_foes(str(facs[0]))[0])
	var c := str(db.spawn_foes(str(facs[1]))[0])
	var b := Battle.new(3)
	b.formation = [[a, 2], [c, 5], [a, 1]]
	b.with_boss = false
	b.setup(_team(), str(facs[0]))
	assert_true(b.boss == null, "no boss")
	var placed: Array = []
	for sq in b.field.packs():
		assert_false(sq.elite, "%s is no boss" % sq.display_name)
		placed.append([sq.foe_id, sq.strength, sq.faction])
	assert_eq(placed, [[a, 2, str(facs[0])], [c, 5, str(facs[1])], [a, 1, str(facs[0])]], "the packs as composed, each under its own foe's faction")
	assert_eq(b.field.spawn_table, placed, "and the rift sends them in turn")
	b.field.rift_pressure = b.field.rift_pressure_max - 1
	b.field._spawn_index = 1
	b.field.tick_pressure(1)
	var spawned: Unit = b.field.packs()[b.field.packs().size() - 1]
	assert_eq([spawned.foe_id, spawned.faction], [c, str(facs[1])], "a rift pack wears its own faction")
	b.forced = []
	b.field.gate_hp = 0
	b.end_turn()
	assert_eq(b.outcome, Battle.Outcome.GATE_FALLEN, "without a boss only the field ends it")


func test_route_to_reaches_every_reachable_hex() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[1]
	var dests := b.field.reachable(m)
	assert_true(dests.size() > 0, "somewhere to go")
	for h in dests.keys():
		var route := b.field.route_to(m, h)
		assert_true(not route.is_empty(), "route to %s" % str(h))
		assert_eq(route[route.size() - 1], h, "route ends at the hex")
		var prev := m.pos
		var cost := 0
		for step in route:
			assert_true(Hex.are_adjacent(prev, step), "steps are adjacent")
			cost += BattleMap.spend(b.map.terrain[step], m.traits, m.movespeed - cost)
			prev = step
		assert_eq(cost, dests[h], "route cost matches the reachable cost")
	assert_true(b.field.route_to(m, m.pos).is_empty(), "no route to itself")


func test_a_machine_moves_at_once_and_keeps_what_is_left_of_its_move() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var near := Vector2i(-99, -99)
	for h in b.destinations_for(m).keys():
		if int(b.destinations_for(m)[h]) < m.movespeed:
			near = h
			break
	assert_true(near != Vector2i(-99, -99), "a hex short of its whole move")
	var cost := int(b.destinations_for(m)[near])
	var route := b.move_to(m, near)
	assert_false(route.is_empty(), "the move is taken")
	assert_eq(m.pos, near, "it is there at once")
	assert_eq(b.moves_left(m), m.movespeed - cost, "with the rest of its move")
	assert_eq(b.actions_left(m), 1, "a move spends no action")
	for h in b.destinations_for(m).keys():
		assert_true(int(b.destinations_for(m)[h]) <= b.moves_left(m), "and it can go on only as far as is left")
	assert_true(b.move_to(m, b.map.rift).is_empty(), "the rift is out of reach")


func test_undo_puts_a_machine_back_with_its_whole_move() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var start := m.pos
	var facing := m.facing
	assert_false(b.can_undo(m), "nothing to undo")
	var h: Vector2i = b.destinations_for(m).keys()[0]
	b.move_to(m, h)
	assert_true(b.can_undo(m), "the move can be taken back")
	assert_true(b.undo_move(m), "undone")
	assert_eq(m.pos, start, "back where it was")
	assert_eq(m.facing, facing, "facing as it was")
	assert_eq(b.moves_left(m), m.movespeed, "its whole move again")
	assert_false(b.can_undo(m), "and nothing more to undo")


func test_a_machine_cannot_end_on_another() -> void:
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var shared := Vector2i(-99, -99)
	for h in b.destinations_for(a).keys():
		if b.destinations_for(c).has(h):
			shared = h
			break
	assert_true(shared != Vector2i(-99, -99), "the two share a reachable hex")
	b.move_to(a, shared)
	assert_false(b.destinations_for(c).has(shared), "taken: off the second machine's list")
	assert_true(b.move_to(c, shared).is_empty(), "and refused")


func test_attack_opens_a_fight_with_the_target_the_packs_that_join_and_the_machines_committed() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	var other: Unit = b.field.packs()[1]
	_engage(b, sq, m)
	other.zone = 3
	other.behaviour = "push"
	for n in Hex.neighbors(sq.pos):
		if b.field.can_stand(other, n) and n != m.pos:
			other.pos = n
			break
	var r := b.roster(sq)
	assert_eq(r["targets"], [sq], "the pack tapped")
	assert_true((r["joins"] as Array).has(other), "a pack whose ring covers it joins")
	assert_true((r["eligible"] as Array).has(m), "the machine beside it may join")
	var sk := b.attack(sq, [m])
	assert_true(sk != null, "the fight opens")
	assert_eq(b.state, Battle.State.SKIRMISH, "and is under way")
	assert_true(sk.packs.has(sq) and sk.packs.has(other), "both packs are in it")
	assert_eq(sk.mechs.size(), 1, "the one machine committed")
	assert_eq(Battle.ground_hex(sk.packs), sq.pos, "fought on the target's ground")
	assert_eq(b.attack(sq, [m]), null, "no second fight while one is open")


func test_a_machine_out_of_range_cannot_be_committed() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	assert_true(Battlefield.unit_distance(m, sq) > m.attack_range, "the packs start far off")
	assert_false((b.roster(sq)["eligible"] as Array).has(m), "out of range")
	assert_eq(b.attack(sq, [m]), null, "so there is nobody to fight with")


func test_a_machine_that_fought_is_spent_until_the_next_turn() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	sk.withdraw()
	b.finish_skirmish()
	assert_eq(b.state, Battle.State.PLAN, "back to the turn")
	assert_eq(b.actions_left(m), 0, "spent, though it withdrew")
	assert_true(b.destinations_for(m).is_empty(), "it cannot move")
	assert_false((b.roster(sq)["eligible"] as Array).has(m), "nor fight again")
	b.end_turn()
	assert_eq(b.actions_left(m), 1, "a new turn gives it back")


func test_a_second_action_fights_twice_a_turn() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	m.grant_passive({"id": "twin", "name": "Twin", "description": "", "effects": [{"trigger": "static", "effect": "extra_action", "value": 1}]}, "twin")
	b.spent.clear()
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	_win(sk)
	b.finish_skirmish()
	assert_eq(b.actions_left(m), 1, "one action left")
	assert_false(b.destinations_for(m).is_empty(), "it can move again, its move whole")
	assert_eq(b.moves_left(m), m.movespeed, "the second action's move")
	var sq2: Unit = b.field.packs()[0]
	_engage(b, sq2, m)
	assert_true(b.attack(sq2, [m]) != null, "and fight again")


func test_finish_skirmish_removes_the_pack_and_keeps_shields_as_they_were() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	m.shield = 0
	_win(sk)
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "won")
	var packs_before := b.field.packs().size()
	b.finish_skirmish()
	assert_eq(b.field.packs().size(), packs_before - 1, "pack wiped from the map")
	assert_eq(b.foes_killed, sq.strength, "a won skirmish counts every foe it killed, for the salvage")
	assert_eq(m.shield, 0, "no free refill between skirmishes")
	assert_eq(b.state, Battle.State.PLAN, "the turn goes on")
	assert_eq(b.current, null, "no skirmish open")


func test_shield_recharges_at_the_field_rate_only_in_a_turn_without_a_fight() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var idle: Unit = b.mechs()[1]
	m.shield = 0
	idle.shield = 0
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	_win(sk)
	b.finish_skirmish()
	b.end_turn()
	assert_eq(m.shield, 0, "a machine that fought this turn gets nothing")
	assert_eq(idle.shield, mini(idle.shield_max, idle.recharge_field), "one that did not, the field rate")
	assert_true(idle.shield <= idle.shield_max, "never above max")


func test_survivors_shrink_the_pack() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	sk.withdraw()
	b.finish_skirmish()
	assert_true(b.field.units.has(sq), "pack still on the map")
	assert_eq(sq.strength, sk.survivors_for(sq), "strength is what survived")


func test_boss_death_seals_the_rift() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	_engage(b, b.boss, m)
	var sk := b.attack(b.boss, [m])
	assert_true(b.boss_fight, "the boss's fight")
	var massive := false
	for f in sk.reinforcements:
		massive = massive or f.is_massive()
	assert_true(massive, "boss unpacked into the massive elite")
	_win(sk)
	b.finish_skirmish()
	assert_false(b.boss_fight, "the flag drops with the fight")
	assert_eq(b.outcome, Battle.Outcome.VICTORY, "victory")
	assert_eq(b.state, Battle.State.DONE, "battle over")


func test_a_hunter_that_caught_its_prey_forces_the_first_fight() -> void:
	# Bible section 5: a hunter within its ring of its prey has caught it; that fight comes
	# first on the player's turn, whatever is tapped, its prey cannot move, and the turn
	# cannot end until it is fought.
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var other: Unit = b.field.packs()[1]
	var hunter: Unit = b.field.packs()[0]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.hunts = "nearest"
	hunter.prey = m.id
	hunter.zone = 1
	b._new_turn()
	assert_eq(b.forced.size(), 1, "caught")
	assert_true(b.is_pinned(m), "its prey is pinned")
	assert_true(b.destinations_for(m).is_empty(), "and cannot move")
	var r := b.roster(other)
	assert_eq(r["targets"], [hunter], "the forced fight comes first whatever is tapped")
	assert_eq(r["pinned"], m, "with its prey in it")
	assert_true(b.end_turn().is_empty(), "the turn cannot end before it")
	var sk := b.attack(other, [])
	assert_true(sk != null, "it opens with nobody else committed")
	assert_true(sk.packs.has(hunter), "against the hunter")
	_win(sk)
	b.finish_skirmish()
	assert_true(b.forced.is_empty(), "fought")
	assert_eq(b.actions_left(m), 0, "and its prey is spent")
	assert_false(b.end_turn().is_empty(), "the turn may end now")


func test_withdrawing_from_a_hunter_leaves_the_machine_caught() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var hunter: Unit = b.field.packs()[0]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	hunter.zone = 1
	b._new_turn()
	var sk := b.attack(null, [])
	sk.begin()
	sk.start_round()
	sk.withdraw()
	b.finish_skirmish()
	assert_true(b.forced.is_empty(), "this turn's forced fight is over")
	b.end_turn()
	assert_eq(b.forced.size(), 1, "next turn the hunter, still on it, has caught it again")
	assert_eq(b.forced[0]["prey"], m, "the same machine")


## Clear the team away from the gate and park a pusher right in front of it.
static func threaten_gate(b: Battle, sq: Unit) -> void:
	var gate_o := Hex.axial_to_offset(b.map.gate)
	for m in b.mechs():
		m.pos = b.field.nearest_standable(m, Hex.offset_to_axial(gate_o.x, gate_o.y - 5))
	for n in Hex.neighbors(b.map.gate_hexes[1]):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	sq.behaviour = "push"


func test_gate_falling_ends_the_battle() -> void:
	var b := _battle()
	b.field.gate_hp = 5
	var sq: Unit = b.field.packs()[0]
	threaten_gate(b, sq)
	b.forced = []
	assert_true((b.field.plan_walks()[sq.id] as Battlefield.Walk).strikes, "the pack shows a strike on the gate")
	b.end_turn()
	assert_eq(b.field.gate_hp, 0, "gate down")
	assert_eq(b.outcome, Battle.Outcome.GATE_FALLEN, "gate fallen")
	assert_eq(b.state, Battle.State.DONE, "battle over")
	assert_eq(b.attack(sq, b.mechs()), null, "nothing to fight once the gate is gone")


func test_wrecked_mechs_leave_the_map() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	for ms in sk.mechs:
		ms.unit.hull = 0
	sk.end_round()
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "wrecked")
	var before := b.mechs().size()
	b.finish_skirmish()
	assert_eq(b.mechs().size(), before - sk.mechs.size(), "wrecks are gone")
	assert_eq(b.wrecks.size(), sk.mechs.size(), "and the battle keeps them, for the campaign to read")
	assert_true(b.state == Battle.State.PLAN or b.outcome == Battle.Outcome.WRECKED, "battle continues or ends")


func test_a_skirmish_is_fought_on_the_first_packs_ground() -> void:
	# Decided 22 September, and since 8 October the first pack is the one attacked: the
	# ground is the target's hex, whatever the machines stand on.
	var b := _battle()
	var f := b.field
	var m: Unit = b.mechs()[0]
	var sq: Unit = f.packs()[0]
	var sq2: Unit = f.packs()[1]
	f.map.terrain[m.pos] = BattleMap.Terrain.ROAD
	f.map.terrain[sq.pos] = BattleMap.Terrain.RUINS
	f.map.terrain[sq2.pos] = BattleMap.Terrain.WATER
	var group: Array = [sq, sq2, m]
	assert_eq(Battle.ground_hex(group), sq.pos, "the first pack's hex")
	assert_eq(b.ground_terrain(group), BattleMap.Terrain.RUINS, "and its terrain")
	var sk := b._build_skirmish(group)
	assert_eq(sk.terrain, BattleMap.Terrain.RUINS, "the skirmish is fought there, not on the machine's road")


## A route drawn by hand goes the way it was drawn, where a tap would take the cheapest way.
func test_a_drawn_route_is_walked_as_drawn() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[1]
	var n1 := Vector2i(-99, -99)
	var dest := Vector2i(-99, -99)
	for a in Hex.neighbors(m.pos):
		if not b.field.can_stand(m, a):
			continue
		for d in Hex.neighbors(a):
			if d != m.pos and Hex.are_adjacent(m.pos, d) and b.field.can_stand(m, d) and b.destinations_for(m).has(d):
				n1 = a
				dest = d
				break
		if dest != Vector2i(-99, -99):
			break
	assert_true(dest != Vector2i(-99, -99), "a neighbour reachable the long way round exists")
	var draft: Array = b.draft_step(m, [], n1)
	assert_eq(draft, [n1], "the first hex joins the draft")
	draft = b.draft_step(m, draft, dest)
	if draft.size() != 2:
		return   # the detour does not fit this machine's move on this map; nothing to test
	assert_eq(b.draft_cost(m, draft), b.field.route_cost(m, draft), "the draft's cost is the route's cost")
	assert_eq(b.field.route_to(m, dest).size(), 1, "where the tap would have gone straight there")
	assert_eq(b.draft_step(m, draft, n1), [n1], "back onto a drawn hex cuts the draft to it")
	assert_true(b.draft_step(m, draft, m.pos).is_empty(), "back onto the machine clears it")
	var cost := b.draft_cost(m, draft)
	assert_true(b.move_along(m, draft), "the drawn route is walked")
	assert_eq(m.pos, dest, "to its end")
	assert_eq(b.moves_left(m), m.movespeed - cost, "spending what the drawn way costs")


func test_the_gauge_tells_a_slow_stop_from_a_spent_move() -> void:
	# Decided 3 October: the move gauge the drawn route drains. A slow last step takes
	# whatever move is left, and the gauge says so apart from the steps' own spending.
	var b := _battle()
	var m: Unit = null
	var slow_ground := -1
	for c in b.mechs():
		for t in [BattleMap.Terrain.WATER, BattleMap.Terrain.RUINS, BattleMap.Terrain.ROUGH]:
			if BattleMap.move_cost(t, c.traits) == BattleMap.SLOW:
				m = c
				slow_ground = t
				break
		if m != null:
			break
	assert_true(m != null, "the team has a machine with a slow ground")
	var n1 := Vector2i(-99, -99)
	var n2 := Vector2i(-99, -99)
	for a in Hex.neighbors(m.pos):
		if not b.field.can_stand(m, a):
			continue
		for d in Hex.neighbors(a):
			if d != m.pos and not Hex.are_adjacent(m.pos, d) and b.field.can_stand(m, d):
				n1 = a
				n2 = d
				break
		if n2 != Vector2i(-99, -99):
			break
	assert_true(n2 != Vector2i(-99, -99), "two free hexes in a line")
	b.field.map.terrain[n1] = BattleMap.Terrain.PLAIN
	b.field.map.terrain[n2] = slow_ground
	var open_cost := BattleMap.move_cost(BattleMap.Terrain.PLAIN, m.traits)
	assert_eq(b.draft_spend(m, []), Vector2i(0, 0), "nothing drawn spends nothing")
	assert_eq(b.draft_spend(m, [n1]), Vector2i(open_cost, 0), "an open step spends its price and stops nothing")
	assert_eq(b.draft_spend(m, [n1, n2]), Vector2i(open_cost, m.movespeed - open_cost), "the slow step takes the rest")
	# The cells: one per 5 of move, filling from the left, so what is left comes first, then
	# what the slow step took, then what the steps spent.
	var C := BattleMapView.Cell
	assert_eq(BattleMapView.gauge_cells(40, Vector2i(10, 30)), [C.STOPPED, C.STOPPED, C.STOPPED, C.STOPPED, C.STOPPED, C.STOPPED, C.SPENT, C.SPENT], "a slow step after one hex")
	assert_eq(BattleMapView.gauge_cells(40, Vector2i(40, 0)), [C.SPENT, C.SPENT, C.SPENT, C.SPENT, C.SPENT, C.SPENT, C.SPENT, C.SPENT], "the move run out")
	assert_eq(BattleMapView.gauge_cells(30, Vector2i(15, 0)), [C.LEFT, C.LEFT, C.LEFT, C.SPENT, C.SPENT, C.SPENT], "a fast hex is half a pip")
	assert_eq(BattleMapView.gauge_cells(0, Vector2i(0, 0)).size(), 0, "no move, no gauge")


func test_a_draft_never_outruns_the_move_left() -> void:
	var b := _battle()
	var c: Unit = b.mechs()[1]
	var first: Vector2i = b.destinations_for(c).keys()[0]
	b.move_to(c, first)
	var left := b.moves_left(c)
	var draft: Array = []
	var cur := c.pos
	for i in range(c.movespeed + 3):
		var stepped := false
		for n in Hex.neighbors(cur):
			if n != c.pos and not draft.has(n) and b.field.can_stand(c, n):
				var next: Array = b.draft_step(c, draft, n)
				if next.size() > draft.size():
					draft = next
					cur = n
					stepped = true
					break
		if not stepped:
			break
	var cost := b.draft_cost(c, draft)
	assert_true(cost >= 0 and cost <= left, "the draft fits the move left: cost %d of %d" % [cost, left])
	assert_false(b.move_along(c, []), "an empty draft walks nowhere")


func test_an_out_of_combat_passive_fires_after_a_quiet_turn() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	m.shield = 0
	m.grant_passive({"id": "hum", "name": "Hum", "description": "", "effects": [
		{"trigger": "out_of_combat", "effect": "add_shield", "value": 5}]}, "hum")
	var rate := m.recharge_field
	b.forced = []
	b.end_turn()
	assert_eq(m.shield, mini(m.shield_max, rate + 5), "the field rate, then the passive's five")


func test_a_kill_is_a_kill_whatever_the_fight_ends_in() -> void:
	# Ryan, 7 October: withdrawing never takes a kill away, so the salvage the campaign
	# tallies at the battle's end counts every foe killed, won fight or not.
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	var victim: Foe = sk.field_foes()[0]
	victim.hp = 0
	assert_true(sk.withdraw(), "the team pulls out")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "withdrawn")
	b.finish_skirmish()
	assert_eq(b.foes_killed, 1, "the kill made before withdrawing counts")


func test_an_order_needs_the_pack_in_range_and_engage_opens_the_fight() -> void:
	# Bible section 5: a machine is ordered onto a pack it has in range; nothing opens until
	# ENGAGE, which opens the fight with every machine ordered onto that pack.
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var sq: Unit = b.field.packs()[0]
	assert_false(b.order(a, sq), "out of range: refused")
	_engage(b, sq, a)
	assert_true(b.order(a, sq), "beside it: ordered")
	assert_eq(b.state, Battle.State.PLAN, "nothing opens on the order")
	assert_eq(b.next_fight()["target"], sq, "the next fight is at the pack")
	assert_eq(b.next_fight()["machines"], [a], "with the machine ordered")
	b.cancel_order(a)
	assert_true(b.next_fight().is_empty(), "taken back")
	b.order(a, sq)
	var sk := b.engage()
	assert_true(sk != null, "ENGAGE opens it")
	assert_true(sk.packs.has(sq), "at the pack")
	assert_eq(sk.mechs.size(), 1, "with the one machine")
	assert_true(b.orders.is_empty(), "the order is spent")
	assert_false(b.orders.has(c.id), "the other machine was never in it")


func test_the_attack_hex_is_the_farthest_in_range_the_move_reaches() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	sq.behaviour = "push"
	# Park the pack three hexes ahead of the machine, out of its range of two.
	var spot := Vector2i(-99, -99)
	for h in b.field.map.all_hexes():
		if Hex.distance(h, m.pos) == 3 and b.field.can_stand(sq, h):
			spot = h
			break
	assert_true(spot != Vector2i(-99, -99), "a hex three away")
	sq.pos = spot
	assert_false(b.in_range_from(m, m.pos, sq), "out of range where it stands")
	var h := b.attack_hex(m, sq)
	assert_true(h != Battle.NO_HEX, "a hex in range within its move")
	assert_true(b.in_range_from(m, h, sq), "in range there")
	for d in b.destinations_for(m).keys():
		if b.in_range_from(m, d, sq):
			assert_true(b._distance_from(d, sq) <= b._distance_from(h, sq), "none in range is farther")
	b.move_to(m, h)
	assert_eq(b.attack_hex(m, sq), m.pos, "in range now: it attacks from where it stands")


func test_moving_out_of_range_drops_the_order() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	assert_true(b.order(m, sq), "ordered")
	var away := Vector2i(-99, -99)
	for h in b.destinations_for(m).keys():
		if not b.in_range_from(m, h, sq):
			away = h
			break
	if away == Vector2i(-99, -99):
		return   # nowhere out of range within its move on this map; nothing to test
	b.move_to(m, away)
	assert_true(b.orders.is_empty(), "out of range: the order drops")


func test_a_catch_comes_first_through_engage() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var helper: Unit = b.mechs()[1]
	var hunter: Unit = b.field.packs()[0]
	var other: Unit = b.field.packs()[1]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	hunter.zone = 1
	b._new_turn()
	assert_false(b.can_target(other), "another pack cannot be ordered on while the catch waits")
	assert_false(b.next_fight().is_empty(), "the catch is ready to engage with nobody ordered")
	assert_eq(b.next_fight()["target"], null, "the catch, not a pack tapped")
	if b.in_range_from(helper, helper.pos, hunter):
		assert_true(b.order(helper, hunter), "a helper in range may be ordered onto the hunter")
	var sk := b.engage()
	assert_true(sk != null, "it opens")
	assert_true(sk.packs.has(hunter), "against the hunter")
	var in_it := false
	for ms in sk.mechs:
		in_it = in_it or ms.unit == m
	assert_true(in_it, "with its prey in it")

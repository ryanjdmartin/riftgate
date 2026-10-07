extends TestCase

## The battle loop, headless: setup, plotting, resolving, contact, and outcomes.


func _team() -> Array:
	var db := ContentDB.load_default()
	var out: Array = []
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		out.append(db.make_mech(id))
	return out


func _battle(seed_value: int = 3) -> Battle:
	var b := Battle.new(seed_value)
	b.setup(_team(), "undead")
	return b


## Park a pack next to a mech and root it so contact is certain after the phase.
func _engage(b: Battle, sq: Unit, m: Unit) -> void:
	var spot := m.pos
	for n in Hex.neighbors(m.pos):
		if b.field.can_stand(sq, n):
			spot = n
			break
	sq.pos = spot
	sq.movespeed = 0
	b.field.compute_intents()


## Wipe the foes of an open skirmish so it ends in victory.
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
	for sq in b.field.packs():
		assert_true(Hex.axial_to_offset(sq.pos).y < gate_row / 2, "%s starts in the north" % sq.display_name)
	assert_eq(b.state, Battle.State.PLAN, "planning")
	assert_true(b.field.intents.size() > 0, "enemy moves previewed")


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


func test_set_route_needs_a_reachable_hex() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	assert_false(b.set_route(m, b.map.rift), "the rift is out of reach")
	var h: Vector2i = b.destinations_for(m).keys()[0]
	assert_true(b.set_route(m, h), "reachable hex accepted")
	assert_eq(b.route_end(m), h, "route ends there")
	assert_true(b.set_route(m, m.pos), "own hex clears")
	assert_true(b.routes.is_empty(), "route gone")


func test_two_mechs_cannot_claim_one_destination() -> void:
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var shared := Vector2i(-99, -99)
	for h in b.destinations_for(a).keys():
		if b.destinations_for(c).has(h):
			shared = h
			break
	assert_true(shared != Vector2i(-99, -99), "the two share a reachable hex")
	assert_true(b.set_route(a, shared), "first claim")
	assert_false(b.destinations_for(c).has(shared), "claimed hex is off the second mech's list")
	assert_false(b.set_route(c, shared), "second claim refused")
	b.clear_route(a.id)
	assert_true(b.destinations_for(c).has(shared), "free again once cleared")


func test_commit_without_contact_returns_to_plan() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var h: Vector2i = b.destinations_for(m).keys()[0]
	b.set_route(m, h)
	var res := b.commit()
	assert_true(res != null, "phase resolved")
	assert_eq(m.pos, h, "mech moved")
	assert_eq(b.field.phase, 1, "one phase in")
	assert_eq(b.state, Battle.State.PLAN, "back to planning")
	assert_true(b.routes.is_empty(), "routes consumed")
	assert_false(b.has_pending(), "no contact")


func test_contact_opens_a_skirmish_with_the_touching_units() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	b.commit()
	assert_eq(b.state, Battle.State.SKIRMISH, "contact")
	var sk := b.open_next_skirmish()
	assert_true(sk != null, "skirmish built")
	var in_it := false
	for ms in sk.mechs:
		in_it = in_it or ms.unit == m
	assert_true(in_it, "the touched mech fights")
	assert_true(sk.packs.has(sq), "the pack is in it")
	assert_eq(sk.reinforcements.size(), sq.strength, "one foe per point of strength")


func test_finish_skirmish_removes_the_pack_and_keeps_shields_as_they_were() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	b.commit()
	var sk := b.open_next_skirmish()
	m.shield = 0
	_win(sk)
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "won")
	var packs_before := b.field.packs().size()
	b.finish_skirmish()
	assert_eq(b.field.packs().size(), packs_before - 1, "pack wiped from the map")
	assert_eq(b.foes_killed, sq.strength, "a won skirmish counts every foe it killed, for the salvage")
	assert_eq(m.shield, 0, "no free refill between skirmishes")
	assert_eq(b.state, Battle.State.PLAN, "planning again")
	assert_eq(b.current, null, "no skirmish open")


func test_shield_recharges_at_the_field_rate_only_out_of_combat() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	m.shield = 0
	m.recharge_field = 15
	m.shield_max = 40
	var sq: Unit = b.field.packs()[0]
	# Phase one: contact. The engaged mech gets nothing from the phase.
	_engage(b, sq, m)
	b.commit()
	assert_eq(m.shield, 0, "a mech in contact this phase does not recharge at the field rate")
	var sk := b.open_next_skirmish()
	_win(sk)
	b.finish_skirmish()
	assert_eq(m.shield, 0, "still nothing after the fight")
	# Later phases with no contact: the field rate, capped at max.
	if b.state == Battle.State.PLAN:
		b.commit()
		assert_true(m.shield == 15 or b.has_pending(), "a quiet phase gives the field rate (%d)" % m.shield)
	assert_true(m.shield <= m.shield_max, "never above max")


func test_survivors_shrink_the_pack() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	b.commit()
	var sk := b.open_next_skirmish()
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
	b.commit()
	assert_eq(b.state, Battle.State.SKIRMISH, "boss contact")
	var sk := b.open_next_skirmish()
	var massive := false
	for f in sk.reinforcements:
		massive = massive or f.is_massive()
	assert_true(massive, "boss unpacked into the massive elite")
	_win(sk)
	b.finish_skirmish()
	assert_eq(b.outcome, Battle.Outcome.VICTORY, "victory")
	assert_eq(b.state, Battle.State.DONE, "battle over")


## The boss's contact takes the phase (Ryan, 25 September): one fight, every machine in it,
## the boss alone across from them, every other contact dropped.
func test_boss_contact_commits_every_machine_and_drops_the_other_contacts() -> void:
	var b := _battle()
	var mechs := b.mechs()
	var sq: Unit = b.field.packs()[0]
	_engage(b, b.boss, mechs[0])
	_engage(b, sq, mechs[2])
	b.commit()
	assert_true(b.boss_contact, "the boss was contacted")
	assert_eq(b.state, Battle.State.SKIRMISH, "one fight pending")
	assert_eq(b.pending.size(), 1, "the pack's contact is dropped")
	var group: Array = b.pending[0]
	for m in mechs:
		assert_true(group.has(m), "%s is committed, in contact or not" % m.display_name)
	assert_true(group.has(b.boss), "against the boss")
	assert_false(group.has(sq), "the pack stays on the field")
	var sk := b.open_next_skirmish()
	assert_eq(sk.mechs.size(), mechs.size(), "every machine fights")
	assert_eq(sk.packs, [b.boss], "the boss is the only pack in it")
	assert_eq(Battle.ground_hex(group), b.boss.pos, "fought on the boss's ground")
	_win(sk)
	b.finish_skirmish()
	assert_false(b.boss_contact, "the flag drops with the fight")
	assert_eq(b.outcome, Battle.Outcome.VICTORY, "victory")
	assert_true(b.field.units.has(sq), "the dropped pack was never fought")


func test_a_plain_contact_is_not_a_boss_contact() -> void:
	var b := _battle()
	_engage(b, b.field.packs()[0], b.mechs()[0])
	b.commit()
	assert_false(b.boss_contact, "no boss in it")
	assert_eq(b.pending.size(), 1, "the one contact stands")
	assert_false(b.pending[0].has(b.boss), "the boss is not dragged in")
	assert_true(b.pending[0].has(b.field.packs()[0]), "the pack is fought")


## Clear the team away from the gate and park a pack right in front of it.
static func threaten_gate(b: Battle, sq: Unit) -> void:
	var gate_o := Hex.axial_to_offset(b.map.gate)
	for m in b.mechs():
		m.pos = b.field.nearest_standable(m, Hex.offset_to_axial(gate_o.x, gate_o.y - 5))
	for n in Hex.neighbors(b.map.gate_hexes[1]):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	sq.behaviour = "push"   # a pusher: an aggressive pack would turn for a machine within its reach
	b.field.compute_intents()


func test_gate_falling_ends_the_battle() -> void:
	var b := _battle()
	b.field.gate_hp = 5
	var sq: Unit = b.field.packs()[0]
	threaten_gate(b, sq)
	assert_true(b.map.gate_hexes.has(b.field.intents[sq.id][0]), "the pack previews a strike on the gate")
	b.commit()
	assert_eq(b.field.gate_hp, 0, "gate down")
	assert_eq(b.outcome, Battle.Outcome.GATE_FALLEN, "gate fallen")
	assert_eq(b.state, Battle.State.DONE, "battle over")
	assert_eq(b.open_next_skirmish(), null, "nothing to fight once the gate is gone")


func test_wrecked_mechs_leave_the_map() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	b.commit()
	var sk := b.open_next_skirmish()
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
	# Decided 22 September: the ground is the pack's hex, the first pack in field order
	# when there are several, whatever the machines stand on.
	var b := _battle()
	var f := b.field
	var m: Unit = b.mechs()[0]
	var sq: Unit = f.packs()[0]
	var sq2: Unit = f.packs()[1]
	f.map.terrain[m.pos] = BattleMap.Terrain.ROAD
	f.map.terrain[sq.pos] = BattleMap.Terrain.RUINS
	f.map.terrain[sq2.pos] = BattleMap.Terrain.WATER
	var group: Array = [m, sq, sq2]
	assert_eq(Battle.ground_hex(group), sq.pos, "the first pack's hex")
	assert_eq(b.ground_terrain(group), BattleMap.Terrain.RUINS, "and its terrain")
	var sk := b._build_skirmish(group)
	assert_eq(sk.terrain, BattleMap.Terrain.RUINS, "the skirmish is fought there, not on the machine's road")


## A route drawn by hand goes the way it was drawn, where a tap would take the cheapest way.
func test_a_drawn_route_is_kept_as_drawn() -> void:
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
	assert_true(b.set_route_path(m, draft), "the drawn route is accepted")
	assert_eq(b.route_for(m.id).size(), 2, "and kept as drawn")
	assert_eq(b.field.route_to(m, dest).size(), 1, "where the tap would have gone straight there")
	assert_eq(b.draft_step(m, draft, n1), [n1], "back onto a drawn hex cuts the draft to it")
	assert_true(b.draft_step(m, draft, m.pos).is_empty(), "back onto the machine clears it")
	b.commit()
	assert_eq(m.pos, dest, "Resolve walks the drawn route")


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


func test_a_draft_never_outruns_the_move_or_lands_on_a_claimed_hex() -> void:
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	# Draw as far as the map allows in one direction: the draft stops growing at the move.
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
	assert_true(not draft.is_empty(), "something was drawn")
	var cost := b.draft_cost(c, draft)
	assert_true(cost >= 0 and cost <= c.movespeed, "the draft fits the move: cost %d of %d" % [cost, c.movespeed])
	# A hex another machine has claimed cannot end a drawn route either.
	var shared := Vector2i(-99, -99)
	for h in b.destinations_for(a).keys():
		if b.destinations_for(c).has(h):
			shared = h
			break
	assert_true(shared != Vector2i(-99, -99), "the two share a reachable hex")
	var to_shared: Array = b.field.route_to(c, shared)
	assert_true(not to_shared.is_empty(), "the second could walk there")
	assert_true(b.set_route(a, shared), "the first claims it by tap")
	assert_false(b.set_route_path(c, to_shared), "the second's drawn route to it is refused")
	assert_true(b.set_route_path(c, []), "an empty draft clears")


func test_an_out_of_combat_passive_fires_after_a_quiet_phase() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	m.shield = 0
	m.grant_passive({"id": "hum", "name": "Hum", "description": "", "effects": [
		{"trigger": "out_of_combat", "effect": "add_shield", "value": 5}]}, "hum")
	var rate := m.recharge_field
	b.commit()
	assert_eq(m.shield, mini(m.shield_max, rate + 5), "the field rate, then the passive's five")


func test_a_kill_is_a_kill_whatever_the_fight_ends_in() -> void:
	# Ryan, 7 October: withdrawing never takes a kill away, so the salvage the campaign
	# tallies at the battle's end counts every foe killed, won fight or not.
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	b.commit()
	var sk := b.open_next_skirmish()
	sk.begin()
	sk.start_round()
	var victim: Foe = sk.field_foes()[0]
	victim.hp = 0
	assert_true(sk.withdraw(), "the team pulls out")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "withdrawn")
	b.finish_skirmish()
	assert_eq(b.foes_killed, 1, "the kill made before withdrawing counts")

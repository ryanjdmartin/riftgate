extends TestCase

## The battle loop, headless: setup, plotting, resolving, contact, and outcomes.


func _team() -> Array:
	var db := ContentDB.load_default()
	var out: Array = []
	for id in ["badger", "sentinel", "raptor"]:
		out.append(db.make_mech(id))
	return out


func _battle(seed_value: int = 3) -> Battle:
	var b := Battle.new(seed_value)
	b.setup(_team(), "undead")
	return b


## Park a squad next to a mech and root it so contact is certain after the phase.
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
	assert_eq(b.field.squads().size(), 4, "three squads from the spawn list plus the boss")
	assert_true(b.boss != null and b.field.units.has(b.boss), "boss on the field")
	assert_eq(b.boss.foe_id, "", "boss unpacks by faction, not foe id")
	for u in b.field.units:
		assert_true(b.field.can_stand(u, u.pos), "%s stands on legal ground" % u.display_name)
	var gate_row := Hex.axial_to_offset(b.map.gate).y
	for m in b.mechs():
		assert_true(Hex.axial_to_offset(m.pos).y >= gate_row - 3, "%s starts by the gate" % m.display_name)
	for sq in b.field.squads():
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
			cost += BattleMap.move_cost(b.map.terrain[step], m.traits)
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
	var sq: Unit = b.field.squads()[0]
	_engage(b, sq, m)
	b.commit()
	assert_eq(b.state, Battle.State.SKIRMISH, "contact")
	var sk := b.open_next_skirmish()
	assert_true(sk != null, "skirmish built")
	var in_it := false
	for ms in sk.mechs:
		in_it = in_it or ms.unit == m
	assert_true(in_it, "the touched mech fights")
	assert_true(sk.squads.has(sq), "the squad is in it")
	assert_eq(sk.reinforcements.size(), sq.strength, "one foe per point of strength")


func test_finish_skirmish_removes_the_squad_and_recharges_shields() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.squads()[0]
	_engage(b, sq, m)
	b.commit()
	var sk := b.open_next_skirmish()
	m.shield = 0
	_win(sk)
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "won")
	var squads_before := b.field.squads().size()
	b.finish_skirmish()
	assert_eq(b.field.squads().size(), squads_before - 1, "squad wiped from the map")
	assert_eq(m.shield, m.shield_max, "shield recharged between skirmishes")
	assert_eq(b.state, Battle.State.PLAN, "planning again")
	assert_eq(b.current, null, "no skirmish open")


func test_survivors_shrink_the_squad() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.squads()[0]
	_engage(b, sq, m)
	b.commit()
	var sk := b.open_next_skirmish()
	sk.begin()
	sk.start_round()
	sk.withdraw()
	b.finish_skirmish()
	assert_true(b.field.units.has(sq), "squad still on the map")
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


## Clear the team away from the gate and park a squad right in front of it.
static func threaten_gate(b: Battle, sq: Unit) -> void:
	var gate_o := Hex.axial_to_offset(b.map.gate)
	for m in b.mechs():
		m.pos = b.field.nearest_standable(m, Hex.offset_to_axial(gate_o.x, gate_o.y - 5))
	for n in Hex.neighbors(b.map.gate_hexes[1]):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	b.field.compute_intents()


func test_gate_falling_ends_the_battle() -> void:
	var b := _battle()
	b.field.gate_hp = 5
	var sq: Unit = b.field.squads()[0]
	threaten_gate(b, sq)
	assert_true(b.map.gate_hexes.has(b.field.intents[sq.id][0]), "the squad previews a strike on the gate")
	b.commit()
	assert_eq(b.field.gate_hp, 0, "gate down")
	assert_eq(b.outcome, Battle.Outcome.GATE_FALLEN, "gate fallen")
	assert_eq(b.state, Battle.State.DONE, "battle over")
	assert_eq(b.open_next_skirmish(), null, "nothing to fight once the gate is gone")


func test_wrecked_mechs_leave_the_map() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.squads()[0]
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
	assert_true(b.state == Battle.State.PLAN or b.outcome == Battle.Outcome.WRECKED, "battle continues or ends")

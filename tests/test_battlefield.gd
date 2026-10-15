extends TestCase

## The battlefield's turn (bible section 4, the round row; section 5, the fights-by-ring row):
## packs walk round machines and never stop at one, a pusher strikes the gate from its apron,
## a hunter catches its prey inside its ring and that fight is forced, and a fight at a pack
## is joined by every pack whose ring covers it and by the machines whose range does.


func _field(w: int = 7, h: int = 13) -> Battlefield:
	return Battlefield.new(BattleMap.flat(w, h))


func _o(col: int, row: int) -> Vector2i:
	return Hex.offset_to_axial(col, row)


func test_reachable_respects_movespeed_and_occupancy() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 6), 20))
	f.add_unit(Unit.mech(2, "B", _o(3, 5), 20))
	var r := f.reachable(m)
	for h in r.keys():
		assert_true(r[h] <= 20, "no hex beyond movespeed")
		assert_true(Hex.distance(m.pos, h) <= 2, "no hex farther than two steps")
	assert_false(r.has(_o(3, 5)), "occupied hex is not reachable")
	assert_false(r.has(m.pos), "own hex is not listed")
	assert_true(r.size() >= 12, "two-step ring on open ground minus the blocker")


func test_a_budget_is_the_move_left() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 8), 30))
	var whole := f.reachable(m)
	var part := f.reachable(m, 10)
	assert_true(part.size() < whole.size(), "less move, fewer hexes")
	for h in part.keys():
		assert_eq(Hex.distance(m.pos, h), 1, "a move of ten is one step on open ground")
	var two: Array = [_o(3, 7), _o(3, 6)]
	assert_eq(f.route_cost(m, two), 20, "two steps on the whole move")
	assert_eq(f.route_cost(m, two, 10), -1, "not on ten left")
	assert_eq(f.route_to(m, _o(3, 6), 10).size(), 0, "no route there on ten left")


func test_a_pusher_walks_toward_the_gate_as_shown() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 20))
	var before := Hex.distance(sq.pos, f.map.gate)
	var walks := f.plan_walks()
	var w: Battlefield.Walk = walks[1]
	assert_eq(w.path.size(), 2, "two steps a turn at move 20")
	f.enemy_turn()
	assert_eq(Hex.distance(sq.pos, f.map.gate), before - 2, "two hexes closer to the gate")
	assert_eq(sq.pos, w.end, "it stopped where the walk said")


func test_packs_walk_round_a_machine_and_never_stop_at_it() -> void:
	# No body stop (bible section 4): a machine in the way is ground the horde goes round.
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 20))
	var first: Vector2i = (f.plan_walks()[1] as Battlefield.Walk).path[0]
	var m := f.add_unit(Unit.mech(2, "A", first, 0))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_false(w.path.has(m.pos), "the walk goes round the machine")
	assert_eq(w.path.size(), 2, "and uses its whole move")
	assert_true(Hex.distance(w.end, f.map.gate) < Hex.distance(sq.pos, f.map.gate), "still closing on the gate")
	assert_false(w.waits, "it is not held")


func test_a_wall_across_the_only_way_makes_a_pusher_wait() -> void:
	# A lane one hex wide with a machine in it: no way round, so the pack waits, and the
	# map says so; the rift clock is the price of a wall.
	var f := _lane()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(1, 2), "marsh", 20))
	f.add_unit(Unit.mech(2, "A", _o(1, 6), 0))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_true(w.waits, "no way to the gate: it waits")
	assert_true(w.path.is_empty(), "and walks nowhere")
	f.enemy_turn()
	assert_eq(sq.pos, _o(1, 2), "it waited")
	assert_true(str(f.log).contains("waits"), "and the log says so")


func test_a_flyer_is_walked_under_but_never_stopped_on() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 20))
	var plain: Battlefield.Walk = f.plan_walks()[1]
	var fly := Unit.mech(2, "Sparrowhawk", plain.path[0], 0)
	fly.traits = ["flyer"]
	f.add_unit(fly)
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.path, plain.path, "the walk passes under the flyer")
	fly.pos = plain.path[1]
	w = f.plan_walks()[1]
	assert_true(w.end != fly.pos, "but never stops on its hex")


func test_a_pack_on_the_apron_strikes_the_gate() -> void:
	var f := _field()
	var gate_o := Hex.axial_to_offset(f.map.gate)
	var front := _o(gate_o.x, gate_o.y - BattleMap.GATE_ROWS)   # the open row above the gate
	var sq := f.add_unit(Unit.pack(1, "ghouls", front, "marsh", 20, 6))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_true(w.strikes, "the walk shows the strike")
	assert_true(w.path.is_empty(), "standing on the apron already, it walks nowhere")
	var hp := f.gate_hp
	f.enemy_turn()
	assert_eq(f.gate_hp, hp - 20, "a third of six, ten at least: twenty")
	assert_eq(sq.pos, front, "it holds at the gate")


func test_gate_is_wider_than_one_hex() -> void:
	var f := _field()
	assert_eq(f.map.gate_hexes.size(), 7, "four gate hexes on the apron row, three below")
	assert_eq(f.map.rift_hexes.size(), 3, "three rift hexes")
	var side: Vector2i = f.map.gate_hexes[0]
	var side_o := Hex.axial_to_offset(side)
	f.add_unit(Unit.pack(1, "ghouls", _o(side_o.x, side_o.y - 1), "marsh", 20))
	assert_true((f.plan_walks()[1] as Battlefield.Walk).strikes, "beside a side gate hex is the apron too")
	var hp := f.gate_hp
	f.enemy_turn()
	assert_true(f.gate_hp < hp, "the gate takes the strike")


func test_a_walk_turns_the_pack_to_its_last_step() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 20))
	var w: Battlefield.Walk = f.plan_walks()[1]
	f.enemy_turn()
	assert_eq(Hex.DIRECTIONS[sq.facing], w.path[1] - w.path[0], "facing matches the final step")


func test_the_walks_shown_are_the_walks_played() -> void:
	# The preview is exact (bible section 4): nothing reacts to the plan, so where the map
	# says a pack ends is where it ends, on real maps with the team and the boss.
	for s in range(1, 12):
		var b := Battle.new(s)
		b.setup([Unit.mech(1, "A", Vector2i.ZERO, 30), Unit.mech(2, "B", Vector2i.ZERO, 30)], "marsh")
		var f := b.field
		var walks := f.plan_walks()
		f.enemy_turn()
		for sq in f.packs():
			assert_eq(sq.pos, (walks[sq.id] as Battlefield.Walk).end, "%s ends where shown (seed %d)" % [sq.display_name, s])


func test_packs_plan_in_order_around_each_others_ends() -> void:
	# Two packs in a column heading for the gate: the rear plans round where the front will
	# end, so it walks its whole move instead of stopping short.
	var f := _field(7, 14)
	var front := f.add_unit(Unit.pack(1, "front", _o(3, 6), "marsh", 20))
	var rear := f.add_unit(Unit.pack(2, "rear", _o(3, 4), "marsh", 20))
	var walks := f.plan_walks()
	var front_end: Vector2i = (walks[front.id] as Battlefield.Walk).end
	var rear_walk: Battlefield.Walk = walks[rear.id]
	assert_false(rear_walk.path.has(front_end), "the rear pack does not plan through the front's end")
	assert_eq(rear_walk.path.size(), 2, "and still uses its whole move")
	f.enemy_turn()
	assert_eq(rear.pos, rear_walk.end, "and lands where shown")


func test_a_boss_patrols_its_zone_outside_the_rift() -> void:
	var f := _field(7, 14)
	var rift_o := Hex.axial_to_offset(f.map.rift)
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(rift_o.x, rift_o.y + 2)))
	for i in range(6):
		var w: Battlefield.Walk = f.plan_walks()[boss.id]
		assert_true(w.path.size() <= 1, "one step at most")
		f.enemy_turn()
		f.phase += 1
		assert_true(Hex.distance(boss.pos, f.map.rift) <= Battlefield.BOSS_ZONE, "stays within its zone (turn %d)" % i)
		assert_false(f.map.rift_hexes.has(boss.pos), "never on the rift itself")


func test_pressure_spawns_pack_at_rift() -> void:
	var f := _field()
	f.rift_pressure_max = 2
	assert_false(f.tick_pressure(1), "one tick, no spawn")
	assert_true(f.tick_pressure(1), "the second spawns")
	assert_eq(f.packs().size(), 1, "one pack now")
	assert_eq(f.packs()[0].foe_id, "revenant", "spawned from the spawn table")
	assert_eq(f.rift_pressure, 0, "clock reset")
	assert_true(Hex.distance(f.packs()[0].pos, f.map.rift) <= 1, "spawned at or beside the rift")


func test_a_hunter_picks_its_prey_by_its_caveat_and_keeps_it() -> void:
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(3, 2), "peak", 30))
	sq.behaviour = "hunt"
	var slow := f.add_unit(Unit.mech(2, "Armadillo", _o(1, 9), 10))
	slow.hull = 90
	slow.shield = 30
	var weak := f.add_unit(Unit.mech(3, "Sparrowhawk", _o(3, 9), 50))
	weak.hull = 20
	weak.shield = 10
	var mid := f.add_unit(Unit.mech(4, "Badger", _o(5, 9), 30))
	mid.hull = 60
	mid.shield = 20
	sq.hunts = "slowest"
	assert_eq(f.pick_prey(sq), slow, "the slowest")
	sq.prey = 0
	sq.hunts = "fastest"
	assert_eq(f.pick_prey(sq), weak, "the fastest")
	sq.prey = 0
	sq.hunts = "weakest"
	assert_eq(f.pick_prey(sq), weak, "the weakest, by hull and shield")
	sq.prey = 0
	sq.hunts = "strongest"
	assert_eq(f.pick_prey(sq), slow, "the strongest")
	sq.prey = 0
	sq.hunts = "nearest"
	weak.pos = _o(3, 7)   # a step nearer than the other two
	assert_eq(f.pick_prey(sq), weak, "the nearest")
	weak.pos = _o(3, 9)
	# Single-minded: the lock holds while the prey lives, however the field changes.
	sq.hunts = "weakest"
	sq.prey = 0
	f.pick_prey(sq)
	weak.hull = 200
	assert_eq(f.pick_prey(sq), weak, "still the Sparrowhawk, now the strongest")
	f.units.erase(weak)
	assert_eq(f.pick_prey(sq), mid, "the prey gone, it picks again: the weakest left")
	# A machine whose passive says never_hunted (the Prairie Dog's) is never picked.
	var f2 := _field(7, 14)
	var sq2 := f2.add_unit(Unit.pack(1, "brutes", _o(3, 2), "peak", 30))
	sq2.behaviour = "hunt"
	var st := f2.add_unit(Unit.mech(2, "Prairie Dog", _o(3, 4), 30))
	st.grant_passive({"id": "scrub", "name": "Scrub", "description": "", "effects": [{"trigger": "static", "effect": "never_hunted", "value": 1}]}, "scrub")
	var open := f2.add_unit(Unit.mech(3, "Badger", _o(3, 10), 30))
	assert_eq(f2.pick_prey(sq2), open, "the nearest machine that can be seen")


func test_a_hunter_walks_until_its_prey_is_in_its_ring_and_catches_it() -> void:
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(3, 3), "peak", 20))
	sq.behaviour = "hunt"
	sq.zone = 1
	var prey := f.add_unit(Unit.mech(2, "A", _o(3, 7), 0))
	f.add_unit(Unit.mech(3, "B", _o(3, 11), 0))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.prey, prey.id, "locked on the nearer machine")
	assert_eq(w.catches, 0, "four away at move two: not this turn")
	assert_true(f.forced_fights().is_empty(), "nothing forced yet")
	f.enemy_turn()
	w = f.plan_walks()[1]
	assert_eq(w.catches, prey.id, "next turn it ends with its prey in its ring")
	f.enemy_turn()
	assert_true(Battlefield.in_ring(sq, prey), "and does")
	var forced := f.forced_fights()
	assert_eq(forced.size(), 1, "the fight is forced")
	assert_eq(forced[0]["prey"], prey, "on its prey")
	assert_eq(forced[0]["hunters"], [sq], "by the hunter")
	var stay: Battlefield.Walk = f.plan_walks()[1]
	assert_true(stay.path.is_empty(), "a hunter with its prey in its ring stays on it")
	assert_eq(stay.catches, prey.id, "and catches it again")


func test_two_hunters_on_one_prey_are_one_forced_fight() -> void:
	var f := _field(7, 14)
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 7), 0))
	var ring := Hex.neighbors(m.pos)
	var a := f.add_unit(Unit.pack(2, "brutes", ring[0], "peak", 20))
	var b := f.add_unit(Unit.pack(3, "ghouls", ring[3], "marsh", 20))
	for sq in [a, b]:
		sq.behaviour = "hunt"
	f.add_unit(Unit.pack(4, "pushers", ring[1], "marsh", 20))   # a pusher beside it forces nothing
	var forced := f.forced_fights()
	assert_eq(forced.size(), 1, "one fight for one prey")
	assert_eq(forced[0]["hunters"].size(), 2, "with both hunters in it")


func test_a_fight_is_joined_by_every_pack_whose_ring_covers_the_target() -> void:
	# A formation in file (bible section 5): the back pack's ring of three covers the front
	# two hexes ahead of it, so attacking the front brings the back in; the front's ring of
	# one does not reach the back, so attacking the back from behind takes it alone.
	var f := _field(7, 14)
	var front := f.add_unit(Unit.pack(1, "ghouls", _o(3, 6), "marsh", 20))
	front.zone = 1
	var back := f.add_unit(Unit.pack(2, "casters", _o(3, 4), "marsh", 20))
	back.zone = 3
	assert_eq(Battlefield.unit_distance(front, back), 2, "two apart")
	assert_eq(f.attack_roster([front])["joins"], [back], "the back joins a fight at the front")
	assert_true((f.attack_roster([back])["joins"] as Array).is_empty(), "the front stays out of a fight at the back")


func test_the_machines_in_range_of_the_target_may_join() -> void:
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 5), "marsh", 20))
	var near := f.add_unit(Unit.mech(2, "A", _o(3, 7), 0))
	var far := f.add_unit(Unit.mech(3, "B", _o(3, 10), 0))
	var r := f.attack_roster([sq])
	assert_true((r["in_range"] as Array).has(near), "two away: in range")
	assert_false((r["in_range"] as Array).has(far), "five away: out of range")
	far.attack_range = 5
	assert_true((f.attack_roster([sq])["in_range"] as Array).has(far), "a longer attack range reaches it")


func test_range_and_rings_count_from_any_footprint_hex() -> void:
	var f := _field()
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(3, 5)))
	boss.footprint = Unit.TRIANGLE.duplicate()
	var far_hex: Vector2i = boss.hexes()[2]
	var spot := Vector2i.ZERO
	for h in f.map.all_hexes():
		if Hex.distance(h, far_hex) == 2 and Battlefield.unit_distance(Unit.mech(9, "probe", h, 0), boss) == 2 and Hex.distance(h, boss.pos) > 2:
			spot = h
			break
	assert_true(spot != Vector2i.ZERO, "a hex two from the far footprint hex and three from the anchor")
	var m := f.add_unit(Unit.mech(2, "A", spot, 0))
	assert_true((f.attack_roster([boss])["in_range"] as Array).has(m), "in range through a secondary footprint hex")


func test_a_passive_can_grant_a_second_action() -> void:
	var m := Unit.mech(1, "Dingo", Vector2i.ZERO, 40)
	assert_eq(Battlefield.actions_for(m), 1, "one action")
	m.grant_passive({"id": "twin", "name": "Twin", "description": "", "effects": [{"trigger": "static", "effect": "extra_action", "value": 1}]}, "twin")
	assert_eq(Battlefield.actions_for(m), 2, "two, by its passive")


func test_boss_covers_three_hexes_and_blocks_them() -> void:
	var f := _field()
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(3, 5)))
	boss.footprint = Unit.TRIANGLE.duplicate()   # the wide footprint, kept in the engine for later
	assert_eq(boss.hexes().size(), 3, "three hexes")
	for h in boss.hexes():
		assert_eq(f.unit_at(h), boss, "boss found at %s" % str(h))
		assert_false(f.is_free(h), "hex %s is not free" % str(h))
	var m := f.add_unit(Unit.mech(2, "A", _o(3, 7), 30))
	var r := f.reachable(m)
	for h in boss.hexes():
		assert_false(r.has(h), "mech cannot end on a boss hex")


func test_nobody_stands_on_structures() -> void:
	var f := _field()
	var gate_o := Hex.axial_to_offset(f.map.gate)
	var m := f.add_unit(Unit.mech(1, "A", _o(gate_o.x, gate_o.y - BattleMap.GATE_ROWS), 30))
	var r := f.reachable(m)
	for g in f.map.gate_hexes:
		assert_false(r.has(g), "gate hex %s not reachable" % str(g))
	assert_false(f.is_free(f.map.rift), "rift is not free ground")


func test_a_pack_is_dressed_from_its_foe_type() -> void:
	# Zone, hunting and move come from the content, never from a hardcoded id.
	var f := _field(7, 14)
	f.foe_profiles = {"caster": {"zone": 3, "behaviour": "hunt", "hunts": "slowest", "movespeed": 40}}
	var sq := f.add_unit(f.dress_pack(Unit.pack(1, "casters", _o(3, 3), "marsh", 20, 4, "caster")))
	assert_eq(sq.zone, 3, "zone from the profile")
	assert_eq(sq.behaviour, "hunt", "behaviour from the profile")
	assert_eq(sq.hunts, "slowest", "and its caveat")
	assert_eq(sq.movespeed, 40, "move from the profile")
	var plain := f.add_unit(f.dress_pack(Unit.pack(2, "ghouls", _o(1, 3), "marsh", 20, 4, "revenant")))
	assert_eq(plain.zone, 1, "no profile: the engine's default zone")
	assert_eq(plain.behaviour, "push", "and it pushes")
	assert_eq(plain.movespeed, 20, "and its own move")


func test_a_slow_hex_is_reached_with_the_last_of_the_move_and_ends_it() -> void:
	# Decided 2 October: a walker can enter water with any move left, and the step ends its
	# move, so nothing is reached through it and no move buys through it.
	var f := _field()
	var water := _o(3, 5)
	f.map.terrain[water] = BattleMap.Terrain.WATER
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 6), 10))
	m.traits.append("walker")
	var r := f.reachable(m)
	assert_true(r.has(water), "the water hex beside it is reachable on a move of one")
	assert_eq(r[water], 10, "and it spends the whole move")
	assert_false(r.has(_o(3, 4)), "nothing is reached through it")
	assert_eq(f.route_cost(m, [water]), 10, "a route ending in water costs the move")
	assert_eq(f.route_cost(m, [water, _o(3, 4)]), -1, "a route through water is not one it can walk")
	m.movespeed = 60
	r = f.reachable(m)
	assert_eq(r[water], 60, "a bigger move still spends it all on the slow step")
	assert_true(r.has(_o(3, 4)), "the hex beyond is reached round the water by land")
	assert_true(f.route_cost(m, [_o(2, 5), _o(3, 4), _o(3, 3)]) == 30, "the land route round it is three normal hexes")
	var tracks := f.add_unit(Unit.mech(2, "T", _o(1, 10), 20))
	tracks.traits.append("tracked")
	f.map.terrain[_o(1, 9)] = BattleMap.Terrain.WATER
	assert_eq(f.route_cost(tracks, [_o(1, 9), _o(1, 8)]), 20, "tracks ford water at normal pace")
	f.map.terrain[_o(1, 8)] = BattleMap.Terrain.RUINS
	assert_eq(f.route_cost(tracks, [_o(1, 9), _o(1, 8)]), 20, "and end their move in rubble with the 10 left")
	assert_eq(f.route_cost(tracks, [_o(1, 8), _o(1, 7)]) if f.map.has(_o(1, 7)) else -1, -1, "a slow first step costs the phase")


func test_any_move_left_enters_a_slow_hex_but_a_normal_one_needs_its_price() -> void:
	var f := _field()
	var car := f.add_unit(Unit.mech(1, "C", _o(3, 10), 15))
	car.traits.append("wheeled")
	f.map.terrain[_o(3, 7)] = BattleMap.Terrain.ROUGH
	var open_then_rough: Array = [_o(3, 9), _o(3, 8), _o(3, 7)]
	assert_eq(f.route_cost(car, open_then_rough), 15, "two fast hexes, then the rough with 5 left")
	var r := f.reachable(car)
	assert_true(r.has(_o(3, 7)), "the rough hex is an end hex")
	assert_eq(r[_o(3, 7)], 15, "at the whole move")
	var walker := f.add_unit(Unit.mech(2, "W", _o(5, 10), 15))
	walker.traits.append("walker")
	assert_eq(f.route_cost(walker, [_o(5, 9), _o(5, 8)]), -1, "5 left does not buy a normal hex")
	assert_eq(f.route_cost(walker, [_o(5, 9)]), 10, "one normal hex, 5 stranded")


func test_packs_never_enter_water_and_route_round_it() -> void:
	var f := _field()
	for col in range(0, 7):
		if col != 0:
			f.map.terrain[_o(col, 6)] = BattleMap.Terrain.WATER   # a river with one ford at the edge
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 20))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.path.size(), 2, "a pack at 20 walks two land hexes a turn")
	for step in w.path:
		assert_true(f.map.terrain[step] != BattleMap.Terrain.WATER, "never into water")
	assert_false(f.can_stand(sq, _o(3, 6)), "a pack cannot stand in water")
	assert_true(f.nearest_free(_o(3, 6), []) != _o(3, 6), "a spawn never lands on water")
	for i in range(6):
		f.enemy_turn()
	assert_true(f.map.terrain[sq.pos] != BattleMap.Terrain.WATER, "it crossed at the ford, or is on its way: never in the river")


func test_a_hunter_whose_prey_stands_in_water_closes_on_the_shore() -> void:
	var f := _field()
	var water := _o(3, 7)
	f.map.terrain[water] = BattleMap.Terrain.WATER
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(3, 3), "peak", 30))
	sq.behaviour = "hunt"
	sq.zone = 1
	var prey := f.add_unit(Unit.mech(2, "A", water, 0))
	prey.traits.append("walker")
	f.enemy_turn()
	f.enemy_turn()
	assert_true(sq.pos != water, "never in the water")
	assert_eq(Hex.distance(sq.pos, water), 1, "on the shore, its prey inside its ring")
	assert_eq(f.forced_fights().size(), 1, "and it has caught it")


func test_the_boss_takes_its_move_from_content() -> void:
	var f := _field()
	f.foe_profiles = {"colossus": {"zone": 2, "behaviour": "push", "hunts": "nearest", "movespeed": 10}}
	var b := f.add_unit(f.dress_pack(Unit.boss(1, "colossus", _o(3, 2), "marsh"), "colossus"))
	assert_eq(b.movespeed, 10, "a boss's move is dressed from its foe type too")
	assert_true(b.is_boss, "and it stays the boss")


func test_a_pack_held_off_its_nearest_gate_hex_by_its_own_side_turns_for_another() -> void:
	# Ryan, 6 October: a stalled horde is never the norm. The row the gate is struck from is
	# held at the three middle columns; the pack behind walks for a free part of the apron.
	var f := _field(7, 13)
	for col in [2, 3, 4]:
		f.add_unit(Unit.pack(10 + col, "wall", _o(col, 10), "marsh", 20))
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 8), "marsh", 20))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_false(w.waits, "it found a way")
	assert_false(w.path.is_empty(), "and walks")
	var before := sq.pos
	f.enemy_turn()
	assert_true(sq.pos != before, "it moved")


func test_a_pack_with_no_way_to_the_gate_waits_and_is_marked() -> void:
	var f := _field(7, 13)
	for col in range(7):
		f.add_unit(Unit.pack(10 + col, "wall", _o(col, 10), "marsh", 20))
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 8), "marsh", 20))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_true(w.waits, "marked: it waits")
	f.enemy_turn()
	assert_eq(sq.pos, _o(3, 8), "it waited")


func _lane() -> Battlefield:
	var f := _field(3, 14)
	for r in range(3, 10):
		f.map.terrain[_o(0, r)] = BattleMap.Terrain.MOUNTAIN
		if r != 5:
			f.map.terrain[_o(2, r)] = BattleMap.Terrain.MOUNTAIN
	return f

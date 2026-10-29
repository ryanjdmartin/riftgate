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
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 6), 2))
	f.add_unit(Unit.mech(2, "B", _o(3, 5), 2))
	var r := f.reachable(m)
	for h in r.keys():
		assert_true(r[h] <= 2, "no hex beyond movespeed")
		assert_true(Hex.distance(m.pos, h) <= 2, "no hex farther than two steps")
	assert_false(r.has(_o(3, 5)), "occupied hex is not reachable")
	assert_false(r.has(m.pos), "own hex is not listed")
	assert_true(r.size() >= 12, "two-step ring on open ground minus the blocker")


func test_a_budget_is_the_move_left() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 8), 3))
	var whole := f.reachable(m)
	var part := f.reachable(m, 1)
	assert_true(part.size() < whole.size(), "less move, fewer hexes")
	for h in part.keys():
		assert_eq(Hex.distance(m.pos, h), 1, "a move of one is one step")
	var two: Array = [_o(3, 7), _o(3, 6)]
	assert_eq(f.route_cost(m, two), 2, "two steps on the whole move")
	assert_eq(f.route_cost(m, two, 1), -1, "not on one")
	assert_eq(f.route_to(m, _o(3, 6), 1).size(), 0, "no route there on one")


func test_a_pusher_walks_toward_the_gate_as_shown() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 2))
	var before := Hex.distance(sq.pos, f.map.gate)
	var walks := f.plan_walks()
	var w: Battlefield.Walk = walks[1]
	assert_eq(w.path.size(), 2, "two steps a turn at move 2")
	f.enemy_turn()
	assert_eq(Hex.distance(sq.pos, f.map.gate), before - 2, "two hexes closer to the gate")
	assert_eq(sq.pos, w.end, "it stopped where the walk said")


func test_packs_walk_round_a_machine_and_never_stop_at_it() -> void:
	# No body stop (bible section 4): a machine in the way is ground the horde goes round.
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 2))
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
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(1, 2), "marsh", 2))
	f.add_unit(Unit.mech(2, "A", _o(1, 6), 0))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_true(w.waits, "no way to the gate: it waits")
	assert_true(w.path.is_empty(), "and walks nowhere")
	f.enemy_turn()
	assert_eq(sq.pos, _o(1, 2), "it waited")
	assert_true(str(f.log).contains("waits"), "and the log says so")


func test_a_flyer_is_walked_under_but_never_stopped_on() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 2))
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
	var sq := f.add_unit(Unit.pack(1, "ghouls", front, "marsh", 2, 6))
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
	f.add_unit(Unit.pack(1, "ghouls", _o(side_o.x, side_o.y - 1), "marsh", 2))
	assert_true((f.plan_walks()[1] as Battlefield.Walk).strikes, "beside a side gate hex is the apron too")
	var hp := f.gate_hp
	f.enemy_turn()
	assert_true(f.gate_hp < hp, "the gate takes the strike")


func test_a_walk_turns_the_pack_to_its_last_step() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 2))
	var w: Battlefield.Walk = f.plan_walks()[1]
	f.enemy_turn()
	assert_eq(Hex.DIRECTIONS[sq.facing], w.path[1] - w.path[0], "facing matches the final step")


func test_the_walks_shown_are_the_walks_played() -> void:
	# The preview is exact (bible section 4): nothing reacts to the plan, so where the map
	# says a pack ends is where it ends, on real maps with the team and the boss.
	for s in range(1, 12):
		var b := Battle.new(s)
		b.setup([Unit.mech(1, "A", Vector2i.ZERO, 3), Unit.mech(2, "B", Vector2i.ZERO, 3)], "marsh")
		var f := b.field
		var walks := f.plan_walks()
		f.enemy_turn()
		for sq in f.packs():
			assert_eq(sq.pos, (walks[sq.id] as Battlefield.Walk).end, "%s ends where shown (seed %d)" % [sq.display_name, s])


func test_packs_plan_in_order_around_each_others_ends() -> void:
	# Two packs in a column heading for the gate: the rear plans round where the front will
	# end, so it walks its whole move instead of stopping short.
	var f := _field(7, 14)
	var front := f.add_unit(Unit.pack(1, "front", _o(3, 6), "marsh", 2))
	var rear := f.add_unit(Unit.pack(2, "rear", _o(3, 4), "marsh", 2))
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
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(rift_o.x, rift_o.y + 2), "marsh"))
	for i in range(6):
		var w: Battlefield.Walk = f.plan_walks()[boss.id]
		assert_true(w.path.size() <= 1, "one step at most")
		f.enemy_turn()
		f.phase += 1
		assert_true(Hex.distance(boss.pos, f.map.rift) <= Battlefield.BOSS_ZONE, "stays within its zone (turn %d)" % i)
		assert_false(f.map.rift_hexes.has(boss.pos), "never on the rift itself")


func test_pressure_spawns_pack_at_rift() -> void:
	var f := _field()
	f.spawn_faction = "marsh"
	f.spawn_table = [["revenant", 6]]
	f.rift_pressure_max = 2
	assert_false(f.tick_pressure(1), "one tick, no spawn")
	assert_true(f.tick_pressure(1), "the second spawns")
	assert_eq(f.packs().size(), 1, "one pack now")
	assert_eq(f.packs()[0].foe_id, "revenant", "spawned from the spawn table")
	assert_eq(f.rift_pressure, 0, "clock reset")
	assert_true(Hex.distance(f.packs()[0].pos, f.map.rift) <= 1, "spawned at or beside the rift")


func test_a_hunter_picks_its_prey_by_its_caveat_and_keeps_it() -> void:
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(3, 2), "peak", 3))
	sq.behaviour = "hunt"
	var slow := f.add_unit(Unit.mech(2, "Armadillo", _o(1, 9), 1))
	slow.hull = 90
	slow.shield = 30
	var weak := f.add_unit(Unit.mech(3, "Sparrowhawk", _o(3, 9), 5))
	weak.hull = 20
	weak.shield = 10
	var mid := f.add_unit(Unit.mech(4, "Badger", _o(5, 9), 3))
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
	var sq2 := f2.add_unit(Unit.pack(1, "brutes", _o(3, 2), "peak", 3))
	sq2.behaviour = "hunt"
	var st := f2.add_unit(Unit.mech(2, "Prairie Dog", _o(3, 4), 3))
	st.grant_passive({"id": "scrub", "name": "Scrub", "description": "", "effects": [{"trigger": "static", "effect": "never_hunted", "value": 1}]}, "scrub")
	var open := f2.add_unit(Unit.mech(3, "Badger", _o(3, 10), 3))
	assert_eq(f2.pick_prey(sq2), open, "the nearest machine that can be seen")


func test_a_hunter_walks_until_its_prey_is_in_its_ring_and_catches_it() -> void:
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(3, 3), "peak", 2))
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
	var a := f.add_unit(Unit.pack(2, "brutes", ring[0], "peak", 2))
	var b := f.add_unit(Unit.pack(3, "ghouls", ring[3], "marsh", 2))
	for sq in [a, b]:
		sq.behaviour = "hunt"
	f.add_unit(Unit.pack(4, "pushers", ring[1], "marsh", 2))   # a pusher beside it forces nothing
	var forced := f.forced_fights()
	assert_eq(forced.size(), 1, "one fight for one prey")
	assert_eq(forced[0]["hunters"].size(), 2, "with both hunters in it")


func test_a_fight_is_joined_by_every_pack_whose_ring_covers_the_target() -> void:
	# A formation in file (bible section 5): the back pack's ring of three covers the front
	# two hexes ahead of it, so attacking the front brings the back in; the front's ring of
	# one does not reach the back, so attacking the back from behind takes it alone.
	var f := _field(7, 14)
	var front := f.add_unit(Unit.pack(1, "ghouls", _o(3, 6), "marsh", 2))
	front.zone = 1
	var back := f.add_unit(Unit.pack(2, "casters", _o(3, 4), "marsh", 2))
	back.zone = 3
	assert_eq(Battlefield.unit_distance(front, back), 2, "two apart")
	assert_eq(f.attack_roster([front])["joins"], [back], "the back joins a fight at the front")
	assert_true((f.attack_roster([back])["joins"] as Array).is_empty(), "the front stays out of a fight at the back")


func test_the_machines_in_range_of_the_target_may_join() -> void:
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 5), "marsh", 2))
	var near := f.add_unit(Unit.mech(2, "A", _o(3, 7), 0))
	var far := f.add_unit(Unit.mech(3, "B", _o(3, 10), 0))
	var r := f.attack_roster([sq])
	assert_true((r["in_range"] as Array).has(near), "two away: in range")
	assert_false((r["in_range"] as Array).has(far), "five away: out of range")
	far.attack_range = 5
	assert_true((f.attack_roster([sq])["in_range"] as Array).has(far), "a longer attack range reaches it")


func test_range_and_rings_count_from_any_footprint_hex() -> void:
	var f := _field()
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(3, 5), "marsh"))
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
	var m := Unit.mech(1, "Dingo", Vector2i.ZERO, 4)
	assert_eq(Battlefield.actions_for(m), 1, "one action")
	m.grant_passive({"id": "twin", "name": "Twin", "description": "", "effects": [{"trigger": "static", "effect": "extra_action", "value": 1}]}, "twin")
	assert_eq(Battlefield.actions_for(m), 2, "two, by its passive")


func test_boss_covers_three_hexes_and_blocks_them() -> void:
	var f := _field()
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(3, 5), "marsh"))
	boss.footprint = Unit.TRIANGLE.duplicate()   # the wide footprint, kept in the engine for later
	assert_eq(boss.hexes().size(), 3, "three hexes")
	for h in boss.hexes():
		assert_eq(f.unit_at(h), boss, "boss found at %s" % str(h))
		assert_false(f.is_free(h), "hex %s is not free" % str(h))
	var m := f.add_unit(Unit.mech(2, "A", _o(3, 7), 3))
	var r := f.reachable(m)
	for h in boss.hexes():
		assert_false(r.has(h), "mech cannot end on a boss hex")


func test_nobody_stands_on_structures() -> void:
	var f := _field()
	var gate_o := Hex.axial_to_offset(f.map.gate)
	var m := f.add_unit(Unit.mech(1, "A", _o(gate_o.x, gate_o.y - BattleMap.GATE_ROWS), 3))
	var r := f.reachable(m)
	for g in f.map.gate_hexes:
		assert_false(r.has(g), "gate hex %s not reachable" % str(g))
	assert_false(f.is_free(f.map.rift), "rift is not free ground")


func test_a_pack_is_dressed_from_its_foe_type() -> void:
	# Zone, hunting and move come from the content, never from a hardcoded id.
	var f := _field(7, 14)
	f.foe_profiles = {"caster": {"zone": 3, "behaviour": "hunt", "hunts": "slowest", "movespeed": 4},
		"wyvern": {"zone": 2, "behaviour": "push", "hunts": "nearest", "movespeed": 1, "winged": true}}
	var sq := f.add_unit(f.dress_pack(Unit.pack(1, "casters", _o(3, 3), "marsh", 2, 4, "caster")))
	assert_eq(sq.zone, 3, "zone from the profile")
	assert_eq(sq.behaviour, "hunt", "behaviour from the profile")
	assert_eq(sq.hunts, "slowest", "and its caveat")
	assert_eq(sq.movespeed, 4, "move from the profile")
	assert_false(sq.traits.has("winged"), "no wings in the profile, none on the pack")
	var plain := f.add_unit(f.dress_pack(Unit.pack(2, "ghouls", _o(1, 3), "marsh", 2, 4, "revenant")))
	assert_eq(plain.zone, 1, "no profile: the engine's default zone")
	assert_eq(plain.behaviour, "push", "and it pushes")
	assert_eq(plain.movespeed, 2, "and its own move")
	var wings := f.add_unit(f.dress_pack(Unit.pack(3, "wyverns", _o(5, 3), "marsh", 2, 1, "wyvern")))
	assert_true(wings.traits.has("winged"), "a winged foe's pack wears the word (the movement proposal's lever 2)")
	assert_eq(BattleMap.way_of(wings.traits), "winged", "and crosses by it")


## A band of water across the field at `rows`, every column.
func _river(f: Battlefield, rows: Array) -> void:
	for r in rows:
		for col in range(f.map.width):
			f.map.terrain[_o(col, int(r))] = BattleMap.Terrain.WATER


func test_a_ground_machine_wades_water_at_two_a_hex() -> void:
	# Ryan, 28 October (the movement proposal's Q1): a water hex costs a ground machine two of
	# its move, and it can always enter one with whatever it has left, so nothing is reached
	# through it with nothing left; a hovercraft crosses it at one.
	var f := _field()
	_river(f, [5])
	var m := f.add_unit(Unit.mech(1, "W", _o(3, 6), 2))
	m.traits.append("walker")
	var r := f.reachable(m)
	assert_true(r.has(_o(3, 5)), "the water ahead is reached on a move of two")
	assert_eq(r[_o(3, 5)], 2, "and wading it spends both")
	for h in r.keys():
		assert_true(Hex.axial_to_offset(h).y >= 5, "nothing is reached through it: %s" % str(Hex.axial_to_offset(h)))
	assert_eq(f.route_cost(m, [_o(3, 5)]), 2, "a route into water costs two")
	assert_eq(f.route_cost(m, [_o(3, 5), _o(3, 4)]), -1, "and nothing follows it on a move of two")
	m.movespeed = 3
	assert_eq(f.route_cost(m, [_o(3, 5), _o(3, 4)]), 3, "on three it wades and steps out")
	var f2 := _field()
	_river(f2, [5, 4])
	var deep := f2.add_unit(Unit.mech(1, "W", _o(3, 6), 3))
	deep.traits.append("tracked")
	var r2 := f2.reachable(deep)
	assert_true(r2.has(_o(3, 5)) and r2.has(_o(3, 4)), "on three it reaches two water hexes deep, the second with the one left")
	assert_eq(r2[_o(3, 4)], 3, "for the whole move")
	assert_false(r2.has(_o(3, 3)), "and not the bank beyond")
	var hover := f2.add_unit(Unit.mech(2, "H", _o(5, 6), 3))
	hover.traits.append("hover")
	var rh := f2.reachable(hover)
	assert_eq(rh[_o(5, 5)], 1, "a hovercraft crosses water at one")
	assert_true(rh.has(_o(5, 3)), "and over the band in three")


func test_a_wade_is_entered_with_whatever_move_is_left() -> void:
	var f := _field()
	f.map.terrain[_o(3, 7)] = BattleMap.Terrain.WATER
	var car := f.add_unit(Unit.mech(1, "C", _o(3, 10), 3))
	car.traits.append("wheeled")
	var land_then_water: Array = [_o(3, 9), _o(3, 8), _o(3, 7)]
	assert_eq(f.route_cost(car, land_then_water), 3, "two steps, then the water with the one left")
	var r := f.reachable(car)
	assert_eq(r[_o(3, 7)], 3, "at the whole move")
	f.map.terrain[_o(3, 8)] = BattleMap.Terrain.ROUGH
	f.map.terrain[_o(3, 9)] = BattleMap.Terrain.RUINS
	assert_eq(f.route_cost(car, land_then_water), 3, "rough and ruins are a step to wheels like any ground")


func test_a_winged_pack_crosses_water_and_crags_and_may_stop_there() -> void:
	# Ryan, 28 October (lever 2): a winged foe's pack crosses water and crags as a flyer does and
	# stands where a flyer stands; a plain pack is walled by both.
	var f := _field()
	_river(f, [4])
	for col in range(f.map.width):
		f.map.terrain[_o(col, 5)] = BattleMap.Terrain.MOUNTAIN
	var sq := f.add_unit(Unit.pack(1, "drakes", _o(3, 3), "peak", 2))
	sq.traits.append("winged")
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.path.size(), 2, "it walks its whole move over the bands")
	assert_eq(f.map.terrain[w.path[0]], BattleMap.Terrain.WATER, "over the water")
	assert_eq(f.map.terrain[w.path[1]], BattleMap.Terrain.MOUNTAIN, "and onto the crags")
	assert_false(w.waits, "it is not held")
	f.enemy_turn()
	assert_eq(f.map.terrain[sq.pos], BattleMap.Terrain.MOUNTAIN, "and it stands on the crag")
	var plain := f.add_unit(Unit.pack(2, "ghouls", _o(1, 2), "marsh", 2))
	var pw: Battlefield.Walk = f.plan_walks()[2]
	assert_true(pw.waits, "a pack without wings has no way through: it waits")
	assert_false(f.can_stand(plain, _o(1, 4)), "and cannot stand in the water")


func test_a_hunter_that_cannot_ring_its_prey_picks_again() -> void:
	# Ryan, 28 October (lever 3; the proposal's Q7, the new lock holds): a hunter whose prey
	# stands where no hex it can reach puts it inside its ring picks again by its caveat among
	# the machines it can ring. The plan shows the new prey; the lock moves when the walk plays.
	var f := _field()
	var lake := _o(3, 6)
	f.map.terrain[lake] = BattleMap.Terrain.WATER
	for n in Hex.neighbors(lake):
		f.map.terrain[n] = BattleMap.Terrain.WATER   # the prey two hexes from the shore
	var sq := f.add_unit(Unit.pack(1, "wolves", _o(3, 2), "meadow", 3))
	sq.behaviour = "hunt"
	sq.hunts = "slowest"
	sq.zone = 1
	var boat := f.add_unit(Unit.mech(2, "H", lake, 2))
	boat.traits.append("hover")
	var slow := f.add_unit(Unit.mech(3, "K", _o(1, 10), 3))
	slow.traits.append("walker")
	var fast := f.add_unit(Unit.mech(4, "G", _o(5, 10), 4))
	fast.traits.append("wheeled")
	assert_eq(f.pick_prey(sq), boat, "the slowest is the hovercraft out in the lake")
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.prey, slow.id, "it cannot ring it, so the walk hunts the slowest it can ring")
	assert_eq(sq.prey, boat.id, "the lock stays until the walk plays")
	f.enemy_turn()
	assert_eq(sq.prey, slow.id, "the walk played: the lock moves")
	assert_true(str(f.log).contains("loses H and hunts K"), "and the log says so: %s" % str(f.log))
	boat.pos = _o(3, 9)   # back on land: the new lock holds all the same
	assert_eq((f.plan_walks()[1] as Battlefield.Walk).prey, slow.id, "the new lock holds")
	var g := _field()
	var pond := _o(3, 6)
	g.map.terrain[pond] = BattleMap.Terrain.WATER
	for n in Hex.neighbors(pond):
		g.map.terrain[n] = BattleMap.Terrain.WATER
	var lone := g.add_unit(Unit.pack(1, "wolves", _o(3, 2), "meadow", 3))
	lone.behaviour = "hunt"
	lone.hunts = "slowest"
	var only := g.add_unit(Unit.mech(2, "H", pond, 2))
	only.traits.append("hover")
	var lw: Battlefield.Walk = g.plan_walks()[1]
	assert_eq(lw.prey, only.id, "with nothing it can ring, it keeps its prey")
	assert_eq(lw.catches, 0, "and catches nothing")
	g.enemy_turn()
	assert_eq(lone.prey, only.id, "the lock is unchanged")


func test_packs_never_enter_water_and_route_round_it() -> void:
	var f := _field()
	for col in range(0, 7):
		if col != 0:
			f.map.terrain[_o(col, 6)] = BattleMap.Terrain.WATER   # a river with one ford at the edge
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "marsh", 2))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.path.size(), 2, "a pack at 2 walks two land hexes a turn")
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
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(3, 3), "peak", 3))
	sq.behaviour = "hunt"
	sq.zone = 1
	var prey := f.add_unit(Unit.mech(2, "A", water, 0))
	prey.traits.append("walker")
	f.enemy_turn()
	f.enemy_turn()
	assert_true(sq.pos != water, "never in the water")
	assert_eq(Hex.distance(sq.pos, water), 1, "on the shore, its prey inside its ring")
	assert_eq(f.forced_fights().size(), 1, "and it has caught it")


func test_a_rift_pressure_spawn_takes_its_foes_shown_name() -> void:
	# The mechanics audit's 30: a spawn was named by its content id ("zombie_knight pack"), where
	# the setup names its packs by the foe's shown name.
	var f := _field()
	f.foe_profiles = {"bone_hound": {"zone": 1, "behaviour": "push", "hunts": "nearest", "movespeed": 2, "name": "Bone Hound"}}
	f.spawn_table = [["bone_hound", 3]]
	f.spawn_faction = "marsh"
	assert_true(f.tick_pressure(f.rift_pressure_max), "the rift spawns")
	var sq: Unit = f.units[f.units.size() - 1]
	assert_eq(sq.display_name, "bone hound pack", "named by its foe's shown name")
	assert_eq(sq.foe_id, "bone_hound", "and still its foe by id")


func test_the_boss_takes_its_move_from_content() -> void:
	var f := _field()
	f.foe_profiles = {"colossus": {"zone": 2, "behaviour": "push", "hunts": "nearest", "movespeed": 1}}
	var b := f.add_unit(f.dress_pack(Unit.boss(1, "colossus", _o(3, 2), "marsh"), "colossus"))
	assert_eq(b.movespeed, 1, "a boss's move is dressed from its foe type too")
	assert_true(b.is_boss, "and it stays the boss")


func test_a_pack_held_off_its_nearest_gate_hex_by_its_own_side_turns_for_another() -> void:
	# Ryan, 6 October: a stalled horde is never the norm. The row the gate is struck from is
	# held at the three middle columns; the pack behind walks for a free part of the apron.
	var f := _field(7, 13)
	for col in [2, 3, 4]:
		f.add_unit(Unit.pack(10 + col, "wall", _o(col, 10), "marsh", 2))
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 8), "marsh", 2))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_false(w.waits, "it found a way")
	assert_false(w.path.is_empty(), "and walks")
	var before := sq.pos
	f.enemy_turn()
	assert_true(sq.pos != before, "it moved")


func test_a_pack_with_no_way_to_the_gate_waits_and_is_marked() -> void:
	var f := _field(7, 13)
	for col in range(7):
		f.add_unit(Unit.pack(10 + col, "wall", _o(col, 10), "marsh", 2))
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 8), "marsh", 2))
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

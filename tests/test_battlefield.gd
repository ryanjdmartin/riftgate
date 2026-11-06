extends TestCase

## The battlefield's turn (bible section 4, the round row; section 5, the fights-by-ring row):
## packs walk round grounded machines, through each other and under flyers, and never stop on
## another unit's hex; a pusher strikes the gate from its apron,
## a hunter catches its prey inside its ring and that fight is forced, and a fight at a pack
## is that pack alone, joined by no other pack, with the machines whose range covers it (the
## long wall brief 3.4).


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


## A pusher's wall segment (the long wall brief 3.3): drawn as the pack is dealt about the rift's
## column, at a spread of nothing the rift's own column, which it walks to from wherever it
## stands; the ramp's spread 2 at the foot and half the wall at the top; a hunter draws none.
func test_a_pushers_segment_is_drawn_about_the_rifts_column_and_walked_to() -> void:
	var f := _field(20, 12)
	var rift_col := Hex.axial_to_offset(f.map.rift).x
	var sq := f.add_unit(Unit.pack(0, "ghouls", _o(3, 3), "marsh", 2))
	f.assign_goal(sq, 0)
	assert_eq(sq.goal_col, rift_col, "at a spread of nothing, the rift's column")
	for i in range(8):
		f.enemy_turn()
	assert_eq(Hex.axial_to_offset(sq.pos), Vector2i(rift_col, f.apron_row()), "walked to the apron hex in that column, across the field")
	assert_eq(Ramp.spread_at(0, 20), 2, "the ramp's spread at the foot")
	assert_eq(Ramp.spread_at(Ramp.TOP, 20), 10, "and half the wall at the top")
	var hunter := f.add_unit(Unit.pack(0, "wolves", _o(15, 3), "marsh", 2))
	hunter.behaviour = "hunt"
	f.assign_goal(hunter, 4)
	assert_eq(hunter.goal_col, -1, "a hunter draws no segment")


## At a spread of four the draw lands eight pushers on eight of the nine columns about the rift's,
## never off the wall.
func test_eight_pushers_at_a_spread_of_four_take_eight_of_the_nine_columns() -> void:
	var f := _field(20, 12)
	var rift_col := Hex.axial_to_offset(f.map.rift).x
	var cols := {}
	for n in range(8):
		var p := f.add_unit(Unit.pack(0, "p%d" % n, _o(n * 2, 1), "marsh", 2))
		f.assign_goal(p, 4)
		assert_true(absi(p.goal_col - rift_col) <= 4, "pusher %d inside the nine columns" % n)
		cols[p.goal_col] = true
	assert_eq(cols.size(), 8, "eight columns of the nine")
	var edge := f.add_unit(Unit.pack(0, "edge", _o(0, 1), "marsh", 2))
	f.assign_goal(edge, 40)
	assert_true(edge.goal_col >= 0 and edge.goal_col < f.map.width, "a spread past the wall is clamped to it")


## A segment whose apron hex is water or a wall resolves to the nearest land apron hex, a tie
## toward the gate's column.
func test_a_segment_on_water_or_a_wall_resolves_to_the_nearest_land_apron_hex() -> void:
	var f := _field(20, 12)
	var row := f.apron_row()
	f.map.terrain[_o(4, row)] = BattleMap.Terrain.WATER
	var wet := f.add_unit(Unit.pack(0, "wet", _o(4, 3), "marsh", 2))
	wet.goal_col = 4
	f.map.terrain[_o(15, row)] = BattleMap.Terrain.MOUNTAIN
	var walled := f.add_unit(Unit.pack(0, "walled", _o(15, 3), "marsh", 2))
	walled.goal_col = 15
	for i in range(8):
		f.enemy_turn()
	assert_eq(Hex.axial_to_offset(wet.pos), Vector2i(5, row), "water at its column: the next land apron hex toward the gate's column")
	assert_eq(Hex.axial_to_offset(walled.pos), Vector2i(14, row), "a wall at its column: likewise")


## The whole wall is a target (Ryan, 30 October): a pack beside any hex of the bottom rows
## strikes the gate's bar, so the apron cannot be plugged, and the strike's floor of ten is
## gone, so a stray pair chips less than a trio.
func test_the_wall_is_struck_anywhere_along_it_and_a_small_pack_chips_less() -> void:
	var f := _field()
	var corner := _o(0, f.map.height - BattleMap.GATE_ROWS - 1)   # the apron row's west end, beside the wall and far from the gate
	assert_true(f.map.wall_hexes.size() > 0, "the wall stands across the rest of the bottom rows")
	var far := true
	for g in f.map.gate_hexes:
		if Hex.distance(corner, g) <= 1:
			far = false
	assert_true(far, "the corner is beside no gate hex")
	var pair := f.add_unit(Unit.pack(1, "a stray pair", corner, "marsh", 2, 2))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_true(w.strikes, "beside the wall it strikes")
	assert_true(w.path.is_empty(), "and walks nowhere")
	var hp := f.gate_hp
	f.enemy_turn()
	assert_eq(f.gate_hp, hp - 6, "a third of two times ten: six, no floor of ten")
	assert_eq(pair.pos, corner, "it holds at the wall")
	assert_eq(f.apron_row(), f.map.height - BattleMap.GATE_ROWS - 1, "the apron is the row before the wall")
	for col in range(f.map.width):
		assert_true(f.apron_hexes().has(_o(col, f.apron_row())), "column %d of the apron row strikes" % col)


## A peak (the pacing session, 30 October): the rift sends the cycle's next composition, a tear
## opens on the seam's row and sends a patrol from the next peak on, the seam creeps, and a
## spawn never lands beside a machine.
func test_a_peak_sends_from_the_rift_and_a_tear_sends_from_the_peak_after_it_opens() -> void:
	var f := _field(9, 20)
	f.spawn_faction = "marsh"
	f.cycle = [Battlefield.composition([["revenant", 4], ["ghost", 2]], "marsh", "formation", "host")]
	f.patrol_cycle = [Battlefield.composition([["revenant", 2]], "marsh", "patrol", "shamblers")]
	f.ramp = 0
	var m := f.add_unit(Unit.mech(9, "A", _o(4, 2), 3))   # a machine right under the rift
	assert_eq(f.seam_row, Battlefield.seam_start(), "the seam starts where the bleed's gradient ended")
	f.peak()
	assert_eq(f.peaks, 1, "one peak")
	assert_eq(f.packs().size(), 1, "the rift sent one composition and the new tear sent nothing yet")
	var sent: Unit = f.packs()[0]
	assert_eq(sent.members, [["revenant", 4], ["ghost", 2]], "the composition's members")
	assert_eq(sent.composition_size, "formation", "and its size")
	assert_false(f.machine_adjacent(sent.pos), "it landed beside no machine")
	assert_true(Hex.distance(sent.pos, f.map.rift) <= 3, "near the rift")
	assert_eq(f.tears.size(), Ramp.tears_at(0), "the ramp's count of tears opened")
	assert_eq(f.seam_row, Battlefield.seam_start() + Ramp.seam_creep_at(0), "the seam crept")
	var first: Vector2i = f.tears[0]["pos"]
	assert_eq(Hex.axial_to_offset(first).y, f.seam_row, "and the tear opened on the seam's new edge")
	f.peak()
	assert_eq(f.packs().size(), 3, "the rift sent again and the tear sent its first patrol")
	assert_eq(f.rift_spawns, 2, "two from the rift")
	assert_eq(f.tear_spawns, 1, "one from the tear")
	var patrol: Unit = f.packs()[2]
	assert_eq(patrol.members, [["revenant", 2]], "the patrol cycle's")
	assert_true(Hex.distance(patrol.pos, first) <= 2, "landed by its tear")
	assert_eq(f.tears.size(), 2 * Ramp.tears_at(0), "another tear opened")
	var second: Vector2i = f.tears[1]["pos"]
	assert_true(Hex.distance(first, second) >= 3, "spread away from the first")
	for i in range(12):
		f.peak()
	assert_eq(f.seam_row, f.apron_row(), "the seam creeps as far as the apron and no further")
	for t in f.tears:
		assert_true(Hex.axial_to_offset(t["pos"]).y <= f.apron_row(), "a tear opens no further south than the apron")
	assert_true(f.units.has(m), "the machine still stands")


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


func test_packs_pass_through_each_other_but_never_stop_on_one() -> void:
	# Ryan, 29 October: "Enemies can pass through other enemies ... enemy units are flat sprites
	# so it's not like they take up space". Packs plan in order, each walking through the others
	# and never stopping where one will end: a pack standing in a lane one hex wide holds it for
	# nobody.
	var f := _lane()
	var still := f.add_unit(Unit.pack(1, "still", _o(1, 6), "marsh", 0))
	var on := f.add_unit(Unit.pack(2, "on", _o(1, 2), "marsh", 5))
	var w: Battlefield.Walk = f.plan_walks()[on.id]
	assert_true(w.path.has(still.pos), "it walks through the pack in the lane")
	assert_eq(w.end, _o(1, 7), "on its whole move, out the other side")
	assert_false(w.waits, "it is not held")
	on.movespeed = 4
	w = f.plan_walks()[on.id]
	assert_eq(w.end, _o(1, 5), "a move that would end on the pack stops short of it")
	f.enemy_turn()
	assert_eq(on.pos, w.end, "and lands where shown")
	assert_eq(still.pos, _o(1, 6), "the pack it passed is where it was")


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
	f.cycle = [Battlefield.composition([["revenant", 6]], "marsh")]
	f.rift_pressure_max = 2
	assert_false(f.tick_pressure(1), "one tick, no spawn")
	assert_true(f.tick_pressure(1), "the second spawns")
	assert_eq(f.packs().size(), 1, "one pack now")
	assert_eq(f.packs()[0].foe_id, "revenant", "spawned from the cycle")
	assert_eq(f.packs()[0].members, [["revenant", 6]], "its members at the ramp's density, one at the start")
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


## One pack is one fight (the long wall brief 3.4; Ryan, 5 November, of the rings: "it just
## adds so much complexity for not a lot of gain"): a pack whose ring covers the target, or that
## stands beside it, stays out of its fight either way round.
func test_no_pack_joins_a_fight_whatever_its_ring() -> void:
	var f := _field(7, 14)
	var front := f.add_unit(Unit.pack(1, "ghouls", _o(3, 6), "marsh", 2))
	front.zone = 1
	var back := f.add_unit(Unit.pack(2, "casters", _o(3, 4), "marsh", 2))
	back.zone = 3
	var beside := f.add_unit(Unit.pack(3, "brutes", _o(4, 6), "marsh", 2))
	beside.zone = 4
	assert_eq(Battlefield.unit_distance(front, back), 2, "two apart, inside the back's ring")
	assert_true((f.attack_roster([front])["joins"] as Array).is_empty(), "nothing joins a fight at the front")
	assert_true((f.attack_roster([back])["joins"] as Array).is_empty(), "nor one at the back")
	assert_eq(f.attack_roster([front])["targets"], [front], "the fight is the one pack")


func test_the_machines_in_range_of_the_target_may_join() -> void:
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 5), "marsh", 2))
	var near := f.add_unit(Unit.mech(2, "A", _o(3, 6), 0))
	var two := f.add_unit(Unit.mech(3, "B", _o(3, 7), 0))
	var far := f.add_unit(Unit.mech(4, "C", _o(3, 10), 0))
	var r := f.attack_roster([sq])
	assert_true((r["in_range"] as Array).has(near), "beside it: in range (adjacency, the long wall brief 3.4)")
	assert_false((r["in_range"] as Array).has(two), "two away: out of range")
	assert_false((r["in_range"] as Array).has(far), "five away: out of range")
	far.attack_range = 5
	assert_true((f.attack_roster([sq])["in_range"] as Array).has(far), "a longer attack range reaches it")


func test_range_counts_from_any_footprint_hex() -> void:
	var f := _field()
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(3, 5), "marsh"))
	boss.footprint = Unit.TRIANGLE.duplicate()
	var far_hex: Vector2i = boss.hexes()[2]
	var spot := Vector2i.ZERO
	for h in f.map.all_hexes():
		if Hex.distance(h, far_hex) == 1 and Battlefield.unit_distance(Unit.mech(9, "probe", h, 0), boss) == 1 and Hex.distance(h, boss.pos) > 1:
			spot = h
			break
	assert_true(spot != Vector2i.ZERO, "a hex beside the far footprint hex and two from the anchor")
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
	assert_true(pw.waits, "a pack without wings wades the water but the crags wall it: it waits")
	assert_true(f.can_stand(plain, _o(1, 4)), "it may stand in the water (Ryan, 29 October)")
	assert_false(f.can_stand(plain, _o(1, 5)), "and never on a crag")


## A hunter at ring two, by its caveat (Ryan, 29 October: "a minimum range of 2 instead of 1
## (wolfs pounce, etc.)").
func _hunter(f: Battlefield, at: Vector2i, move: int, hunts: String) -> Unit:
	var sq := f.add_unit(Unit.pack(1, "wolves", at, "meadow", move))
	sq.behaviour = "hunt"
	sq.hunts = hunts
	sq.zone = 2
	return sq


## Crags across row 7 but for a street at columns 2 to 4, and three machines holding it.
func _held_street(f: Battlefield) -> Array:
	for col in [0, 1, 5, 6]:
		f.map.terrain[_o(col, 7)] = BattleMap.Terrain.MOUNTAIN
	var line: Array = []
	for col in [2, 3, 4]:
		line.append(f.add_unit(Unit.mech(10 + col, "M%d" % col, _o(col, 7), 3)))
	return line


func test_a_hunter_whose_prey_is_sealed_off_takes_the_machine_nearest_it() -> void:
	# Ryan, 29 October: "my target if I can reach him, otherwise the closest machine to my target
	# that I can reach this turn, otherwise chase my target"; reach "at all", "which should be a
	# rare case. It's just punishing hiding". The prey is a flyer over a massif of crags three
	# deep, past any ring of two; the hunter takes the machine standing nearest it, not the one
	# nearest itself, and never one that is never hunted. The lock holds.
	var f := _field()
	var deep := _o(3, 6)
	for col in range(7):
		for row in range(13):
			if Hex.distance(_o(col, row), deep) <= 2:
				f.map.terrain[_o(col, row)] = BattleMap.Terrain.MOUNTAIN
	var sq := _hunter(f, _o(6, 1), 4, "slowest")
	var prey := f.add_unit(Unit.mech(2, "F", deep, 1))
	prey.traits.append("flyer")
	var beside := f.add_unit(Unit.mech(3, "N", _o(5, 1), 3))
	var near := f.add_unit(Unit.mech(4, "P", _o(6, 4), 3))
	var scout := f.add_unit(Unit.mech(5, "D", _o(5, 4), 3))
	scout.grant_passive({"id": "scrub", "name": "Scrub", "description": "", "effects": [{"trigger": "static", "effect": "never_hunted", "value": 1}]}, "scrub")
	assert_eq(f.pick_prey(sq), prey, "the flyer is the slowest")
	assert_false(f.reaches(sq, prey), "no hex the hunter can stand on puts it inside a ring of two")
	assert_true(Hex.distance(scout.pos, deep) < Hex.distance(near.pos, deep), "the scout stands nearest it")
	assert_true(Hex.distance(beside.pos, deep) > Hex.distance(near.pos, deep), "the one beside the hunter farther")
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.prey, near.id, "it comes for the machine nearest its prey, the scout never hunted")
	assert_eq(w.catches, near.id, "and catches it this turn")
	f.enemy_turn()
	assert_eq(sq.prey, prey.id, "the lock holds")
	assert_true(f.log.has("wolves catches P in F's place"), "and the log says so: %s" % str(f.log))
	var forced := f.forced_fights()
	assert_eq(forced.size(), 1, "the fight is forced")
	assert_eq(forced[0]["prey"], near, "on the machine it took")
	prey.pos = _o(3, 10)   # out over open ground: its prey can be reached again
	assert_true(f.reaches(sq, prey), "reached again")
	assert_true(f.forced_fights().is_empty(), "so the machine beside it goes free")
	assert_eq((f.plan_walks()[1] as Battlefield.Walk).prey, prey.id, "and it goes back to its prey")


func test_a_prey_that_keeps_its_distance_is_chased_and_nobody_else_is_caught() -> void:
	# Safety in speed, not hiding (Ryan, 29 October): a prey any route reaches is the only machine
	# the hunter catches, however near the others stand.
	var f := _field(7, 16)
	var sq := _hunter(f, _o(3, 2), 2, "slowest")
	var prey := f.add_unit(Unit.mech(2, "Q", _o(3, 12), 1))
	var other := f.add_unit(Unit.mech(3, "A", _o(3, 4), 3))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.prey, prey.id, "it comes for its prey")
	assert_eq(w.catches, 0, "too far to catch this turn")
	f.enemy_turn()
	assert_true(Battlefield.in_ring(sq, other), "it ends with another machine inside its ring")
	assert_true(f.forced_fights().is_empty(), "and catches nobody: its prey can still be reached")


func test_a_hunter_pounces_over_a_line_but_not_two_back() -> void:
	# A ring of two reaches over one hex of anything: the machine holding a street, so a prey
	# right behind the line is caught; two back it is sealed off, and the hunter takes the
	# machine of the line standing nearest it, its caveat deciding a tie.
	var f := _field()
	var line := _held_street(f)
	var sq := _hunter(f, _o(3, 4), 2, "slowest")
	var prey := f.add_unit(Unit.mech(2, "Q", _o(3, 8), 1))
	assert_true(f.reaches(sq, prey), "a hex in front of the line has it inside a ring of two")
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.catches, prey.id, "so it pounces on the prey over the line")
	prey.pos = _o(1, 9)
	assert_false(f.reaches(sq, prey), "two back, the line seals it off")
	w = f.plan_walks()[1]
	assert_eq(w.catches, (line[0] as Unit).id, "the hunter takes the line's machine nearest it")
	assert_eq(sq.prey, prey.id, "its lock unchanged")
	prey.pos = _o(3, 9)   # as far from every machine of the line
	(line[2] as Unit).movespeed = 2
	w = f.plan_walks()[1]
	assert_eq(w.catches, (line[2] as Unit).id, "a tie goes to its caveat: the slowest of them")


func test_a_hunter_with_its_prey_sealed_and_nobody_in_reach_closes_on_it() -> void:
	var f := _field()
	_held_street(f)
	var sq := _hunter(f, _o(3, 1), 1, "slowest")
	var prey := f.add_unit(Unit.mech(2, "Q", _o(1, 9), 1))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(w.prey, prey.id, "nobody it can reach this turn: it keeps to its prey")
	assert_eq(w.catches, 0, "and catches nothing")
	assert_eq(w.path.size(), 1, "closing on it as far as its move goes")
	f.enemy_turn()
	assert_eq(sq.prey, prey.id, "the lock is unchanged")
	assert_true(f.forced_fights().is_empty(), "nothing forced")


func test_packs_wade_water_as_ground_machines_do() -> void:
	# Ryan, 29 October: "Enemies can cross water just like player units, since that seems fair".
	# A water hex costs a pack two of its move and can be entered with whatever is left, so a
	# pack at 2 wades a hex a turn and may stand in the river; a river is no wall to it.
	var f := _field()
	_river(f, [6])   # every column: no ford
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 4), "marsh", 2))
	var w: Battlefield.Walk = f.plan_walks()[1]
	assert_false(w.waits, "a river is no wall to the horde")
	assert_eq(w.path.size(), 2, "a step, then the water with the one left")
	assert_eq(f.map.terrain[w.end], BattleMap.Terrain.WATER, "it ends the turn in the river")
	f.enemy_turn()
	assert_true(f.can_stand(sq, sq.pos), "standing in it")
	var out: Battlefield.Walk = f.plan_walks()[1]
	assert_eq(out.path.size(), 2, "and walks out the far bank on its next move")
	assert_true(f.map.terrain[out.end] != BattleMap.Terrain.WATER, "onto land")


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


func test_flyers_and_the_ground_pass_each_other_and_never_stop_on_one() -> void:
	# Ryan, 29 October: "Make sure that everything can pass under a player or enemy flyer, but not
	# stop there", and its mirror, "flyers and ground never interact except to fight". In a lane
	# one hex wide: a grounded machine passes under a friendly flyer and a winged pack and stops
	# on neither; a flyer passes over grounded machines and packs.
	var f := _lane()
	var walker := f.add_unit(Unit.mech(1, "W", _o(1, 10), 5))
	walker.traits.append("walker")
	var kite := f.add_unit(Unit.mech(2, "K", _o(1, 8), 0))
	kite.traits.append("flyer")
	var drakes := f.add_unit(Unit.pack(3, "drakes", _o(1, 6), "peak", 0))
	drakes.traits.append("winged")
	var r := f.reachable(walker)
	assert_true(r.has(_o(1, 7)) and r.has(_o(1, 5)), "it passes under both: %s" % str(r.keys()))
	assert_false(r.has(kite.pos), "but never stops under the flyer")
	assert_false(r.has(drakes.pos), "nor under the winged pack")
	assert_eq(f.route_cost(walker, [_o(1, 9), _o(1, 8), _o(1, 7)]), 3, "a route under the flyer costs its steps")
	assert_eq(f.route_cost(walker, [_o(1, 9), _o(1, 8)]), -1, "and one ending under it is no route")
	var g := _lane()
	var fly := g.add_unit(Unit.mech(1, "F", _o(1, 10), 4))
	fly.traits.append("flyer")
	g.add_unit(Unit.mech(2, "A", _o(1, 9), 0)).traits.append("tracked")
	g.add_unit(Unit.pack(3, "ghouls", _o(1, 7), "marsh", 0))
	assert_eq(g.route_cost(fly, [_o(1, 9), _o(1, 8), _o(1, 7), _o(1, 6)]), 4, "a flyer passes over a machine and a pack")
	assert_false(g.reachable(fly).has(_o(1, 9)), "and stops on neither")
	var wings := Unit.pack(4, "wyverns", _o(1, 2), "marsh", 2)
	wings.traits.append("winged")
	assert_true(g._walkable(wings, _o(1, 9), {}), "a winged pack passes over a grounded machine")
	assert_false(g._landable(wings, _o(1, 9), {}), "and never stops on it")


func test_grounded_machines_and_grounded_packs_still_block_each_other() -> void:
	# The player sequences grounded machines (a move lands at once), and a grounded pack and a
	# grounded machine are each other's walls: the bodyblock stays.
	var f := _lane()
	var a := f.add_unit(Unit.mech(1, "A", _o(1, 10), 5))
	a.traits.append("tracked")
	var b := f.add_unit(Unit.mech(2, "B", _o(1, 8), 0))
	b.traits.append("walker")
	var r := f.reachable(a)
	assert_true(r.has(_o(1, 9)), "up to the machine ahead")
	assert_false(r.has(_o(1, 7)), "and no further: a grounded machine is not passed")
	b.pos = _o(0, 11)
	f.add_unit(Unit.pack(3, "ghouls", _o(1, 8), "marsh", 0))
	assert_false(f.reachable(a).has(_o(1, 7)), "nor a grounded pack")


func test_a_rift_pressure_spawn_takes_its_foes_shown_name() -> void:
	# The mechanics audit's 30: a spawn was named by its content id ("zombie_knight pack"), where
	# the setup names its packs by the foe's shown name.
	var f := _field()
	f.foe_profiles = {"bone_hound": {"zone": 1, "behaviour": "push", "hunts": "nearest", "movespeed": 2, "name": "Bone Hound"}}
	f.cycle = [Battlefield.composition([["bone_hound", 3]], "marsh")]
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

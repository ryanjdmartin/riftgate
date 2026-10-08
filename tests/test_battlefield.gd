extends TestCase


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


func test_valid_route_moves_mech() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 10), 30))
	var target := _o(3, 8)
	var route := f.map.find_path(m.pos, target, m.traits)
	var res := f.resolve_phase({1: route})
	assert_eq(m.pos, target, "mech arrived")
	assert_true(res.moved.has(1), "reported as moved")


func test_route_through_occupied_is_rejected() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 10), 30))
	var start := m.pos
	var route := f.map.find_path(m.pos, _o(3, 8), m.traits)
	f.add_unit(Unit.mech(2, "B", route[0], 10))
	var res := f.resolve_phase({1: route})
	assert_eq(m.pos, start, "mech stayed put")
	assert_true(res.rejected.has(1), "route rejected")


func test_route_beyond_movespeed_is_rejected() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 10), 10))
	var route := f.map.find_path(m.pos, _o(3, 8), m.traits)
	var res := f.resolve_phase({1: route})
	assert_true(res.rejected.has(1), "two steps rejected at movespeed 1")


func test_pack_marches_toward_gate() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "undead", 20))
	var before := Hex.distance(sq.pos, f.map.gate)
	f.compute_intents()
	assert_eq(f.intents[1].size(), 2, "preview shows two steps")
	f.resolve_phase({})
	assert_eq(Hex.distance(sq.pos, f.map.gate), before - 2, "two hexes closer to the gate")
	assert_eq(sq.pos, f.intents[1][1], "landed exactly where the preview said")


func test_mech_body_blocks_pack() -> void:
	# A grounded machine standing in the pack's path: the pack stops in front of it, and
	# the machine is inside its zone, so that is the contact (decided 1 October).
	var f := _field(3, 13)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(1, 2), "undead", 30))
	f.compute_intents()
	var m := f.add_unit(Unit.mech(2, "A", f.intents[1][1], 0))   # on its second step
	var res := f.resolve_phase({})
	assert_eq(Hex.distance(sq.pos, m.pos), 1, "pack stopped in front of the machine")
	assert_true(res.blocked.has(1), "pack reported as blocked")
	assert_eq(int(res.blockers.get(1, -1)), m.id, "by the machine")
	assert_eq(res.skirmishes.size(), 1, "contact makes a skirmish")


func test_flyer_does_not_block() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "undead", 20))
	f.compute_intents()
	var first_step: Vector2i = f.intents[1][0]
	var second_step: Vector2i = f.intents[1][1]
	var fly := Unit.mech(2, "Sparrowhawk", first_step, 0)
	fly.traits = ["flyer"]
	f.add_unit(fly)
	var res := f.resolve_phase({})
	assert_eq(sq.pos, second_step, "pack passed through the flyer's hex")
	assert_false(res.blocked.has(1), "not reported as blocked")


func test_pack_stops_short_of_flyer_destination() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "undead", 20))
	f.compute_intents()
	var first_step: Vector2i = f.intents[1][0]
	var second_step: Vector2i = f.intents[1][1]
	var fly := Unit.mech(2, "Sparrowhawk", second_step, 0)
	fly.traits = ["flyer"]
	f.add_unit(fly)
	f.resolve_phase({})
	assert_eq(sq.pos, first_step, "never lands on an occupied hex")


func test_gate_takes_damage_when_pack_arrives() -> void:
	var f := _field()
	var gate_o := Hex.axial_to_offset(f.map.gate)
	var front := _o(gate_o.x, gate_o.y - BattleMap.GATE_ROWS)   # the open row above the apron
	var sq := f.add_unit(Unit.pack(1, "ghouls", front, "undead", 20, 6))
	f.compute_intents()
	assert_eq(f.intents[1].size(), 1, "preview shows the strike")
	assert_true(f.map.gate_hexes.has(f.intents[1][0]), "preview targets the gate (its apron)")
	var hp := f.gate_hp
	var res := f.resolve_phase({})
	assert_true(f.gate_hp < hp, "gate lost hp")
	assert_eq(res.gate_damage, hp - f.gate_hp, "damage reported")
	assert_eq(sq.pos, front, "pack holds position at the gate")


func test_a_hunter_locks_the_nearest_mech_and_closes_on_it() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.pack(1, "hunters", _o(3, 3), "demonic", 20))
	sq.behaviour = "hunt"
	var near := f.add_unit(Unit.mech(2, "A", _o(3, 6), 0))
	f.add_unit(Unit.mech(3, "B", _o(3, 11), 0))
	f.compute_intents()
	assert_eq(sq.prey, near.id, "locked on the nearer machine")
	var path: Array = f.intents[1]
	var last: Vector2i = path[path.size() - 1]
	assert_true(Hex.distance(last, near.pos) < Hex.distance(sq.pos, near.pos), "closes on it")


func test_skirmish_groups_connected_units() -> void:
	var f := _field()
	var sq_pos := _o(3, 6)
	f.add_unit(Unit.pack(1, "ghouls", sq_pos, "undead", 0))
	var ring := Hex.neighbors(sq_pos)
	f.add_unit(Unit.mech(2, "A", ring[0], 0))
	f.add_unit(Unit.mech(3, "B", ring[3], 0))
	f.add_unit(Unit.mech(4, "C", _o(0, 12), 0))
	var groups := f.detect_skirmishes()
	assert_eq(groups.size(), 1, "one skirmish")
	assert_eq(groups[0].size(), 3, "three participants")


func test_two_mechs_alone_are_not_a_skirmish() -> void:
	var f := _field()
	f.add_unit(Unit.mech(1, "A", _o(3, 6), 0))
	f.add_unit(Unit.mech(2, "B", _o(4, 6), 0))
	assert_eq(f.detect_skirmishes().size(), 0, "no enemies, no skirmish")


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


func test_boss_touches_from_any_of_its_hexes() -> void:
	var f := _field()
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(3, 5)))
	boss.footprint = Unit.TRIANGLE.duplicate()
	var far_hex: Vector2i = boss.hexes()[2]
	var spot := Vector2i.ZERO
	for n in Hex.neighbors(far_hex):
		if not boss.occupies(n) and f.map.has(n):
			spot = n
			break
	f.add_unit(Unit.mech(2, "A", spot, 0))
	assert_eq(f.detect_skirmishes().size(), 1, "contact through a secondary footprint hex")


func test_gate_is_wider_than_one_hex() -> void:
	var f := _field()
	assert_eq(f.map.gate_hexes.size(), 7, "four gate hexes on the apron row, three below")
	assert_eq(f.map.rift_hexes.size(), 3, "three rift hexes")
	var side: Vector2i = f.map.gate_hexes[0]   # the apron row comes first: a pack strikes from above it
	var side_o := Hex.axial_to_offset(side)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(side_o.x, side_o.y - 1), "undead", 20))
	f.compute_intents()
	assert_true(f.map.gate_hexes.has(f.intents[1][0]), "preview strikes a gate hex")
	var hp := f.gate_hp
	f.resolve_phase({})
	assert_true(f.gate_hp < hp, "side gate hex takes damage")


func test_nobody_stands_on_structures() -> void:
	var f := _field()
	var gate_o := Hex.axial_to_offset(f.map.gate)
	var m := f.add_unit(Unit.mech(1, "A", _o(gate_o.x, gate_o.y - BattleMap.GATE_ROWS), 30))
	var r := f.reachable(m)
	for g in f.map.gate_hexes:
		assert_false(r.has(g), "gate hex %s not reachable" % str(g))
	assert_false(f.is_free(f.map.rift), "rift is not free ground")


func test_facing_follows_the_last_step() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 10), 30))
	var route := f.map.find_path(m.pos, _o(3, 8), m.traits)
	f.resolve_phase({1: route})
	var expected := route[route.size() - 1] - route[route.size() - 2]
	assert_eq(Hex.DIRECTIONS[m.facing], expected, "facing matches the final step")


func test_pressure_spawns_pack_at_rift() -> void:
	var f := _field()
	f.rift_pressure_max = 2
	assert_eq(f.packs().size(), 0, "starts empty")
	f.resolve_phase({})
	assert_eq(f.packs().size(), 0, "one tick, no spawn")
	var res := f.resolve_phase({})
	assert_true(res.spawned, "second tick spawns")
	assert_eq(f.packs().size(), 1, "one pack now")
	assert_eq(f.packs()[0].foe_id, "ghoul", "spawned from the spawn table")
	assert_eq(f.rift_pressure, 0, "clock reset")
	assert_true(Hex.distance(f.packs()[0].pos, f.map.rift) <= 1, "spawned at or beside the rift")


func test_preview_matches_resolve_and_leaves_nothing_behind() -> void:
	# The plan's preview is the resolver run dry: same ends, same contacts, same blocks,
	# and afterwards every unit is where it was.
	for s in range(1, 12):
		var b := Battle.new(s)
		b.setup([Unit.mech(1, "A", Vector2i.ZERO, 30), Unit.mech(2, "B", Vector2i.ZERO, 30)], "undead")
		var f := b.field
		var routes := {}
		for m in f.mechs():
			var dests: Array = f.reachable(m).keys()
			if not dests.is_empty():
				routes[m.id] = f.map.find_path(m.pos, dests[dests.size() / 2], m.traits)
		var before := {}
		for u in f.units:
			before[u.id] = u.pos
		var pv := f.preview_phase(routes)
		for u in f.units:
			assert_eq(u.pos, before[u.id], "preview moved nobody (seed %d)" % s)
		var hp := f.gate_hp
		var res := f.resolve_phase(routes)
		var ends: Dictionary = pv["ends"]
		for u in f.units:
			if ends.has(u.id):
				assert_eq(u.pos, ends[u.id], "%s ends where the preview said (seed %d)" % [u.display_name, s])
		var pres: Battlefield.PhaseResult = pv["result"]
		assert_eq(pres.blocked, res.blocked, "same blocks (seed %d)" % s)
		assert_eq(pres.rejected, res.rejected, "same rejections (seed %d)" % s)
		assert_eq(pres.skirmishes.size(), res.skirmishes.size(), "same number of contacts (seed %d)" % s)
		assert_eq(hp - f.gate_hp, pres.gate_damage, "the preview's gate damage is the real one (seed %d)" % s)


func test_routes_plan_in_order_so_resolve_never_rejects() -> void:
	# A is plotted first, then B. B may route through the hex A is leaving and may not end
	# on A's destination; both resolve exactly as planned, in that order.
	var b := Battle.new(1)
	b.setup([Unit.mech(1, "A", Vector2i.ZERO, 30), Unit.mech(2, "B", Vector2i.ZERO, 30)], "undead")
	var a_unit: Unit = b.mechs()[0]
	var b_unit: Unit = b.mechs()[1]
	var a_from := a_unit.pos
	var a_dests: Array = b.destinations_for(a_unit).keys()
	assert_true(not a_dests.is_empty(), "A can go somewhere")
	var a_to: Vector2i = a_dests[0]
	assert_true(b.set_route(a_unit, a_to), "A's route set")
	var b_dests := b.destinations_for(b_unit)
	assert_false(b_dests.has(a_to), "B cannot end where A is going")
	assert_true(b_dests.has(a_from) or Hex.distance(b_unit.pos, a_from) > b_unit.movespeed, "B may end where A is leaving, if in reach")
	var b_dests_keys: Array = b_dests.keys()
	assert_true(b.set_route(b_unit, b_dests_keys[b_dests_keys.size() / 2]), "B's route set")
	var pv: Battlefield.PhaseResult = b.field.preview_phase(b.routes)["result"]
	assert_true(pv.rejected.is_empty(), "the plan rejects nobody")
	b.commit()
	assert_true(b.last_result.rejected.is_empty(), "and Resolve rejected nobody")
	assert_eq(a_unit.pos, a_to, "A arrived")


func test_a_replot_drops_a_later_route_it_now_blocks() -> void:
	# A then B, with B's route through A's current hex. A re-plots to stay put (clears its
	# route): B's path now crosses a standing machine, so B's route is dropped and logged.
	var f := _field()
	f.map.terrain[_o(4, 10)] = BattleMap.Terrain.MOUNTAIN   # so A's hex is B's only way north
	var a := f.add_unit(Unit.mech(1, "A", _o(3, 10), 30))
	var b_unit := f.add_unit(Unit.mech(2, "B", _o(3, 11), 30))
	var bt := Battle.new(1)
	bt.field = f
	bt.map = f.map
	bt.state = Battle.State.PLAN
	assert_true(bt.set_route(a, _o(3, 8)), "A goes north")
	assert_true(bt.set_route(b_unit, _o(3, 9)), "B goes north through A's hex, which A is leaving")
	assert_true((bt.routes[b_unit.id] as Array).has(_o(3, 10)), "B's route runs through A's hex")
	bt.clear_route(a.id)
	assert_false(bt.routes.has(b_unit.id), "B's route dropped, since A now stands in it")
	assert_true(str(f.log).contains("route cleared"), "and the log says so")



func test_packs_plan_in_order_around_each_others_destinations() -> void:
	# Two packs in a column heading for the gate. The front one takes the hex the rear
	# one would have reached, so the rear one plans around it rather than stopping short.
	var f := _field(7, 14)
	var front := f.add_unit(Unit.pack(1, "front", _o(3, 6), "undead", 20))
	var rear := f.add_unit(Unit.pack(2, "rear", _o(3, 4), "undead", 20))
	f.compute_intents()
	var front_end: Vector2i = f.intents[front.id][f.intents[front.id].size() - 1]
	var rear_path: Array = f.intents[rear.id]
	assert_false(rear_path.has(front_end), "the rear pack does not plan through the front's destination")
	assert_eq(rear_path.size(), 2, "and still uses its whole move")
	var res := f.resolve_phase({})
	assert_false(res.blocked.has(rear.id), "so it is not blocked at resolve")
	assert_eq(rear.pos, rear_path[rear_path.size() - 1], "and lands where the intent said")


func test_a_replot_moves_the_mech_to_the_end_of_the_order() -> void:
	var b := Battle.new(1)
	b.setup([Unit.mech(1, "A", Vector2i.ZERO, 30), Unit.mech(2, "B", Vector2i.ZERO, 30)], "undead")
	var a_unit: Unit = b.mechs()[0]
	var b_unit: Unit = b.mechs()[1]
	assert_true(b.set_route(a_unit, b.destinations_for(a_unit).keys()[0]), "A plotted")
	assert_true(b.set_route(b_unit, b.destinations_for(b_unit).keys()[0]), "B plotted")
	assert_eq(b.routes.keys(), [a_unit.id, b_unit.id], "A then B")
	var a_dests: Array = b.destinations_for(a_unit).keys()
	assert_true(b.set_route(a_unit, a_dests[a_dests.size() - 1]), "A re-plotted")
	assert_eq(b.routes.keys(), [b_unit.id, a_unit.id], "now B then A: the re-plot goes last")


func test_a_boss_patrols_its_zone_outside_the_rift() -> void:
	var f := _field(7, 14)
	var rift_o := Hex.axial_to_offset(f.map.rift)
	var boss := f.add_unit(Unit.boss(1, "colossus", _o(rift_o.x, rift_o.y + 2)))
	for i in range(6):
		f.compute_intents()
		var path: Array = f.intents[boss.id]
		assert_true(path.size() <= 1, "one step at most")
		f.resolve_phase({})
		assert_true(Hex.distance(boss.pos, f.map.rift) <= Battlefield.BOSS_ZONE, "stays within its zone (phase %d)" % i)
		assert_false(f.map.rift_hexes.has(boss.pos), "never on the rift itself")


func test_a_body_in_the_path_stops_a_pack_and_a_flyer_is_passed_through() -> void:
	# No ground is controlled (decided 1 October): a pack stops only where something stands
	# in its path. In a corridor the machine is in the way, the pack stops in front of it,
	# and the machine is inside its zone.
	var f := _field(3, 14)
	var sq := f.add_unit(Unit.pack(2, "ghouls", _o(1, 2), "undead", 40))
	f.compute_intents()
	var free_path: Array = (f.intents[sq.id] as Array).duplicate()
	var m := f.add_unit(Unit.mech(1, "A", free_path[3], 0))   # on its fourth step
	f.compute_intents()
	var path: Array = f.intents[sq.id]
	assert_eq(path[path.size() - 1], m.pos, "the intent ends on the machine's hex: the block is shown")
	var res := f.resolve_phase({})
	assert_true(res.blocked.has(sq.id), "stopped by the body")
	assert_eq(Hex.distance(sq.pos, m.pos), 1, "in front of the machine")
	assert_eq(res.skirmishes.size(), 1, "and that is a contact")
	# A flyer in the same spot is passed through, and the pack goes on; but where it
	# lands the flyer is inside its zone, so they fight: a flyer engages by the zone like
	# anyone, it only cannot stop a pack.
	var f2 := _field(3, 14)
	var fly := f2.add_unit(Unit.mech(1, "hawk", free_path[2], 0))   # on its third step
	fly.traits = ["flyer"]
	var sq2 := f2.add_unit(Unit.pack(2, "ghouls", _o(1, 2), "undead", 40))
	f2.compute_intents()
	var res2 := f2.resolve_phase({})
	assert_false(res2.blocked.has(sq2.id), "a flyer stops nobody")
	assert_true(Hex.distance(sq2.pos, f2.map.gate) < Hex.distance(_o(1, 2), f2.map.gate) - 2, "the pack kept going")
	assert_eq(res2.skirmishes.size(), 1, "and fights the flyer, which stands in its zone")
	assert_true(res2.skirmishes.size() == 1 and res2.skirmishes[0].has(fly), "the flyer is in it")


func test_a_pack_never_swerves_for_a_machine_only_stops() -> void:
	# Ryan, 22 September: a plot must never make a pack change its path, only cut it.
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(2, "ghouls", _o(3, 2), "undead", 30))
	f.compute_intents()
	var free_path: Array = (f.intents[sq.id] as Array).duplicate()
	var m := f.add_unit(Unit.mech(1, "A", free_path[free_path.size() - 1], 30))   # on its way
	f.compute_intents()
	var cut: Array = f.intents[sq.id]
	assert_true(cut.size() <= free_path.size(), "the path is no longer than it was")
	for i in range(cut.size()):
		assert_eq(cut[i], free_path[i], "the same steps, up to the cut")
	assert_eq(cut[cut.size() - 1], m.pos, "and it ends on the machine's hex, where it will be blocked")
	# A machine well off the path changes nothing at all.
	m.pos = _o(0, 12)
	f.compute_intents()
	assert_eq(f.intents[sq.id], free_path, "a machine off the path leaves it as it was")


func test_the_preview_shows_a_pack_stopped_by_a_route_not_yet_resolved() -> void:
	# A mech's plotted route ends beside the pack's path: the preview's intents already
	# stop there, before Resolve.
	var f := _field(3, 14)
	var m := f.add_unit(Unit.mech(1, "A", _o(1, 9), 30))
	var sq := f.add_unit(Unit.pack(2, "ghouls", _o(1, 3), "undead", 40))
	f.compute_intents()
	var free_path: Array = f.intents[sq.id]
	var block: Vector2i = free_path[3]   # its fourth step, where the machine's route will end
	var routes := {m.id: f.route_to(m, block)}
	assert_false((routes[m.id] as Array).is_empty(), "the machine can get there")
	var pv := f.preview_phase(routes)
	var res: Battlefield.PhaseResult = pv["result"]
	assert_true(res.blocked.has(sq.id), "the preview stops the pack")
	assert_eq(int(res.blockers.get(sq.id, -1)), m.id, "with the machine's planned hex in its way")
	var shown: Array = res.intents[sq.id]
	assert_true(shown.size() <= free_path.size(), "its shown path is cut at the body")
	assert_eq(res.skirmishes.size(), 1, "and the preview sees the contact")
	assert_eq(sq.pos, _o(1, 3), "and nothing moved")


func test_a_pack_walks_past_a_machine_beside_its_path_and_its_zone_decides_the_fight() -> void:
	# Decided 1 October: nothing holds a pack but a body in its way. A machine beside the
	# path is walked past, and whether they fight is whether the machine stands inside the
	# pack's zone where the pack stops. A walled lane down column 1 makes the path certain,
	# with one bay at (2, 5) for the machine to stand in.
	var f := _lane()
	var m := f.add_unit(Unit.mech(1, "A", _o(2, 5), 0))
	var sq := f.add_unit(Unit.pack(2, "ghouls", _o(1, 5), "undead", 30))
	assert_true(sq.touches(m), "beside the machine to start with")
	f.compute_intents()
	assert_eq((f.intents[sq.id] as Array).size(), 3, "it does not hold: it marches")
	var res := f.resolve_phase({})
	assert_false(res.blocked.has(sq.id), "nothing in its way")
	assert_eq(Battlefield.unit_distance(sq, m), 3, "it walked past")
	assert_eq(res.skirmishes.size(), 0, "a zone of one does not reach back to the machine")
	# The same walk with a zone of three: the machine is inside it where the pack stops.
	var f2 := _lane()
	f2.add_unit(Unit.mech(1, "A", _o(2, 5), 0))
	var sq2 := f2.add_unit(Unit.pack(2, "casters", _o(1, 5), "undead", 30))
	sq2.zone = 3
	var res2 := f2.resolve_phase({})
	assert_eq(res2.skirmishes.size(), 1, "so they fight")


## A three-wide field walled down to column 1 from row 3 to row 9, with a bay at (2, 5).
func _lane() -> Battlefield:
	var f := _field(3, 14)
	for r in range(3, 10):
		f.map.terrain[_o(0, r)] = BattleMap.Terrain.MOUNTAIN
		if r != 5:
			f.map.terrain[_o(2, r)] = BattleMap.Terrain.MOUNTAIN
	return f


func test_machines_inside_a_packs_zone_fight_it_and_nothing_chains() -> void:
	# The engagement zone (decided 1 October): every machine within the pack's zone of where
	# it stands fights it. Machines never join through each other: one two hexes behind a
	# machine that is in the fight is out unless the zone itself reaches it.
	var f := _field(9, 13)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(4, 6), "undead", 0, 4))
	sq.zone = 2
	var a := f.add_unit(Unit.mech(2, "A", _o(5, 6), 0))
	var b := f.add_unit(Unit.mech(3, "B", _o(4, 8), 0))
	var c := f.add_unit(Unit.mech(4, "C", _o(4, 10), 0))
	var d := f.add_unit(Unit.mech(5, "D", _o(0, 12), 0))
	assert_true(a.touches(sq), "A touches the pack")
	assert_eq(Battlefield.unit_distance(b, sq), 2, "B stands two from the pack: inside the zone")
	assert_eq(Battlefield.unit_distance(c, b), 2, "C stands two behind B")
	assert_true(Battlefield.unit_distance(c, sq) > sq.zone, "and outside the zone")
	var groups := f.detect_skirmishes()
	assert_eq(groups.size(), 1, "one contact")
	assert_eq(groups[0].size(), 3, "the pack, A and B")
	assert_true(groups[0].has(a) and groups[0].has(b), "both inside the zone")
	assert_false(groups[0].has(c), "C is not pulled in through B")
	assert_false(groups[0].has(d), "D, far away, is not in it")
	assert_eq(groups[0][0], sq, "the pack comes first: the fight's ground is its hex")


func test_a_machine_outside_the_zone_is_no_contact() -> void:
	var f := _field(9, 13)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(4, 6), "undead", 0, 4))
	var b := f.add_unit(Unit.mech(2, "B", _o(4, 8), 0))
	assert_eq(Battlefield.unit_distance(b, sq), 2, "two apart")
	assert_eq(f.detect_skirmishes().size(), 0, "outside a zone of one: no contact")
	sq.zone = 2
	assert_eq(f.detect_skirmishes().size(), 1, "inside a zone of two: a contact")


func test_a_machine_inside_two_zones_joins_the_two_fights_into_one() -> void:
	# The only way fights join (decided 1 October): a machine in both packs' zones.
	var f := _field(9, 13)
	var near := f.add_unit(Unit.pack(1, "ghouls", _o(4, 6), "undead", 0, 4))
	near.zone = 2
	f.add_unit(Unit.mech(2, "A", _o(5, 6), 0))
	var far := f.add_unit(Unit.pack(3, "brutes", _o(4, 10), "demonic", 0, 4))
	far.zone = 2
	f.add_unit(Unit.mech(4, "B", _o(5, 10), 0))
	assert_eq(f.detect_skirmishes().size(), 2, "two fights while nobody stands in both zones")
	var m := f.add_unit(Unit.mech(5, "M", _o(3, 8), 0))
	assert_eq(Battlefield.unit_distance(m, near), 2, "two from one pack")
	assert_eq(Battlefield.unit_distance(m, far), 2, "two from the other")
	var groups := f.detect_skirmishes()
	assert_eq(groups.size(), 1, "one fight")
	assert_eq(groups[0].size(), 5, "both packs and all three machines")


func test_packs_never_join_through_each_other() -> void:
	# Two packs standing together are two fights unless one machine stands in both zones;
	# a formation is unsplittable only by its zones, never by a touch rule.
	var f := _field(9, 13)
	var front := f.add_unit(Unit.pack(1, "ghouls", _o(4, 6), "undead", 0, 4))
	var back := f.add_unit(Unit.pack(2, "necros", _o(4, 5), "undead", 0, 2))
	assert_true(front.touches(back), "the packs touch")
	var m := f.add_unit(Unit.mech(3, "A", _o(4, 7), 0))
	assert_true(m.touches(front), "the machine touches the front pack")
	assert_eq(Battlefield.unit_distance(m, back), 2, "and stands two from the back one")
	var groups := f.detect_skirmishes()
	assert_eq(groups.size(), 1, "one fight")
	assert_eq(groups[0].size(), 2, "the front pack and the machine only")
	assert_false(groups[0].has(back), "the back pack is not pulled in by touching the front")
	back.zone = 3
	groups = f.detect_skirmishes()
	assert_eq(groups.size(), 1, "with a zone that reaches the machine, one fight")
	assert_eq(groups[0].size(), 3, "of both packs and the machine: the formation's own depth")


func test_an_aggressive_pack_commits_to_the_gate_and_turns_for_machines_in_its_reach() -> void:
	# Decided 1 October: an aggressive pack commits to the gate when the round opens; at
	# the move, a machine inside its reach (its move plus its zone) turns it toward the hex
	# within its move whose zone holds the most machines, ties toward the gate.
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 3), "undead", 20))
	sq.behaviour = "aggressive"
	var a := f.add_unit(Unit.mech(2, "A", _o(3, 6), 0))
	var b := f.add_unit(Unit.mech(3, "B", _o(4, 6), 0))
	f.add_unit(Unit.mech(4, "C", _o(1, 4), 0))   # nearer, but alone
	f.compute_intents()
	var committed: Array = f.intents[sq.id]
	assert_true(Hex.distance(committed[committed.size() - 1], f.map.gate) < Hex.distance(sq.pos, f.map.gate), "the committed route heads for the gate")
	var reach := f.reach_hexes(sq)
	assert_true(reach.has(a.pos) and reach.has(b.pos), "the pair stands inside its reach")
	var res := f.resolve_phase({})
	var walked: Array = res.intents[sq.id]
	assert_eq(walked[walked.size() - 1], _o(3, 5), "it turned for the hex beside both A and B")
	assert_eq(res.skirmishes.size(), 1, "one fight")
	assert_true(res.skirmishes[0].has(a) and res.skirmishes[0].has(b), "with the pair, not the loner")
	assert_eq(res.skirmishes[0].size(), 3, "the pack and the two")
	# Nobody in reach: it walks the committed route.
	var f2 := _field(7, 14)
	var sq2 := f2.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "undead", 20))
	sq2.behaviour = "aggressive"
	var far := f2.add_unit(Unit.mech(2, "A", _o(3, 11), 0))
	f2.compute_intents()
	assert_false(f2.reach_hexes(sq2).has(far.pos), "out of reach")
	var committed2: Array = (f2.intents[sq2.id] as Array).duplicate()
	var res2 := f2.resolve_phase({})
	assert_eq(res2.intents[sq2.id], committed2, "the committed route, unchanged")
	assert_eq(sq2.pos, committed2[committed2.size() - 1], "walked to its end")


func test_a_pusher_walks_what_it_committed_to_whatever_the_machines_do() -> void:
	# Decided 1 October: the enemy commits first. A machine that moves beside a pusher's
	# path after the round opened changes nothing: the route the player read is the route.
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "undead", 30))
	var m := f.add_unit(Unit.mech(2, "A", _o(0, 12), 30))
	f.compute_intents()
	var committed: Array = (f.intents[sq.id] as Array).duplicate()
	var beside: Vector2i = Vector2i(-9999, -9999)
	for n in Hex.neighbors(committed[committed.size() - 1]):
		if f.can_stand(m, n) and not committed.has(n):
			beside = n
			break
	m.pos = _o(2, 8)   # within reach of the route's end, so an aggressive pack would turn
	var res := f.resolve_phase({m.id: f.route_to(m, beside)})
	assert_eq(res.intents[sq.id], committed, "the same route")
	assert_eq(sq.pos, committed[committed.size() - 1], "walked to its end")


func test_a_hunter_picks_its_prey_by_its_caveat_and_keeps_it() -> void:
	var f := _field(7, 14)
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(3, 2), "demonic", 30))
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
	# A stealth machine is never picked.
	var f2 := _field(7, 14)
	var sq2 := f2.add_unit(Unit.pack(1, "brutes", _o(3, 2), "demonic", 30))
	sq2.behaviour = "hunt"
	var st := f2.add_unit(Unit.mech(2, "Dingo", _o(3, 4), 30))
	st.traits = ["stealth"]
	var open := f2.add_unit(Unit.mech(3, "Badger", _o(3, 10), 30))
	assert_eq(f2.pick_prey(sq2), open, "the nearest machine that can be seen")


func test_a_hunter_chases_where_its_prey_ends() -> void:
	# The lock is chosen when the round opens; the chase at the move goes to where the
	# prey now stands. Prey within the hunter's move: it stops in front of it, and the
	# zone makes the fight. The preview sees the same.
	var f := _lane()
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(1, 2), "demonic", 30))
	sq.behaviour = "hunt"
	var prey := f.add_unit(Unit.mech(2, "Badger", _o(1, 5), 30))
	f.compute_intents()
	assert_eq(sq.prey, prey.id, "locked")
	var routes := {prey.id: f.route_to(prey, _o(1, 6))}   # a step away down the lane
	var pv: Battlefield.PhaseResult = f.preview_phase(routes)["result"]
	var shown: Array = pv.intents[sq.id]
	assert_eq(shown[shown.size() - 1], _o(1, 6), "the preview's chase ends on the prey's new hex")
	assert_eq(pv.skirmishes.size(), 1, "and sees the fight")
	var res := f.resolve_phase(routes)
	assert_eq(prey.pos, _o(1, 6), "the prey moved")
	assert_eq(sq.pos, _o(1, 5), "the hunter stopped in front of it")
	assert_true(res.blocked.has(sq.id), "blocked by the prey's body")
	assert_eq(res.skirmishes.size(), 1, "the fight")
	assert_eq(sq.prey, prey.id, "the lock holds for next round")


func test_a_pack_is_dressed_from_its_foe_type() -> void:
	# Zone, hunting and move come from the content, never from a hardcoded id.
	var f := _field(7, 14)
	f.foe_profiles = {"caster": {"zone": 3, "behaviour": "hunt", "hunts": "slowest", "movespeed": 40}}
	var sq := f.add_unit(f.dress_pack(Unit.pack(1, "casters", _o(3, 3), "undead", 20, 4, "caster")))
	assert_eq(sq.zone, 3, "zone from the profile")
	assert_eq(sq.behaviour, "hunt", "behaviour from the profile")
	assert_eq(sq.hunts, "slowest", "and its caveat")
	assert_eq(sq.movespeed, 40, "move from the profile")
	var plain := f.add_unit(f.dress_pack(Unit.pack(2, "ghouls", _o(1, 3), "undead", 20, 4, "ghoul")))
	assert_eq(plain.zone, 1, "no profile: the engine's default zone")
	assert_eq(plain.behaviour, "push", "and it pushes")
	assert_eq(plain.movespeed, 20, "and its own move")


func test_stealth_is_never_pulled_in_by_a_zone_alone() -> void:
	# The stealth trait (28 September): a zone never pulls it in. Inside a zone with no ally
	# in the fight there is no fight at all; with an ally in it, the stealth machine is in.
	var f := _field(9, 13)
	var pack := f.add_unit(Unit.pack(1, "casters", _o(4, 6), "undead", 0, 4))
	pack.zone = 3
	var st := f.add_unit(Unit.mech(3, "S", _o(4, 8), 0))
	st.traits = ["stealth"]
	assert_eq(Battlefield.unit_distance(st, pack), 2, "two from the pack: inside its zone")
	assert_eq(f.detect_skirmishes().size(), 0, "no fight: stealth alone is not pulled in")
	var a := f.add_unit(Unit.mech(2, "A", _o(5, 6), 0))
	var groups := f.detect_skirmishes()
	assert_eq(groups.size(), 1, "one contact")
	assert_eq(groups[0].size(), 3, "the pack, A and the stealth machine beside its ally")
	assert_true(groups[0].has(st) and groups[0].has(a), "both machines in")


func test_stealth_joins_a_fight_only_beside_an_ally_or_when_it_stopped_the_pack() -> void:
	# The join rule (28 September; built 30 September). A pack that walks into the stealth
	# machine is stopped by it and that is a contact; one that merely ends its move beside it
	# has walked past. A mountain wall either side of column 1 makes the pack's path certain.
	var f := _field(3, 14)
	for r in range(3, 9):
		f.map.terrain[_o(0, r)] = BattleMap.Terrain.MOUNTAIN
		f.map.terrain[_o(2, r)] = BattleMap.Terrain.MOUNTAIN
	var s := f.add_unit(Unit.mech(1, "dingo", _o(1, 6), 0))
	s.traits = ["stealth"]
	var sq := f.add_unit(Unit.pack(2, "ghouls", _o(1, 2), "undead", 40))
	f.compute_intents()
	var pre: Battlefield.PhaseResult = f.preview_phase({})["result"]
	assert_eq(pre.skirmishes.size(), 1, "the preview sees the pack run into the dingo")
	var res := f.resolve_phase({})
	assert_true(res.blocked.has(sq.id), "the pack was stopped")
	assert_eq(int(res.blockers.get(sq.id, -1)), s.id, "by the dingo")
	assert_eq(res.skirmishes.size(), 1, "so they fight")
	assert_true(res.skirmishes.size() == 1 and res.skirmishes[0].has(s), "the dingo in it")
	# Beside it by chance: a pack that stands touching the dingo without having been stopped
	# by it has walked past, and there is no contact; named as its blocker, there is.
	var f2 := _field(3, 14)
	var s2 := f2.add_unit(Unit.mech(1, "dingo", _o(1, 7), 0))
	s2.traits = ["stealth"]
	var sq2 := f2.add_unit(Unit.pack(2, "ghouls", _o(1, 6), "undead", 0, 4))
	assert_true(sq2.touches(s2), "touching")
	assert_eq(f2.detect_skirmishes({}).size(), 0, "walked past: no contact")
	assert_eq(f2.detect_skirmishes({sq2.id: s2.id}).size(), 1, "stopped by it: a contact")
	assert_eq(f2.detect_skirmishes({sq2.id: 99}).size(), 0, "stopped by someone else: none")
	# With an ally in the touching group, the dingo is in.
	var f3 := _field(5, 14)
	var s3 := f3.add_unit(Unit.mech(1, "dingo", _o(1, 7), 0))
	s3.traits = ["stealth"]
	var a3 := f3.add_unit(Unit.mech(2, "A", _o(3, 7), 0))
	f3.add_unit(Unit.pack(3, "ghouls", _o(2, 7), "undead", 0, 4))
	var groups := f3.detect_skirmishes()
	assert_eq(groups.size(), 1, "one contact")
	assert_true(groups.size() == 1 and groups[0].size() == 3, "the pack, A and the dingo beside its ally")
	assert_true(groups.size() == 1 and groups[0].has(s3) and groups[0].has(a3), "both machines in")


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
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 2), "undead", 20))
	f.compute_intents()
	var path: Array = f.intents[1]
	assert_true(not path.is_empty(), "the pack has a route")
	for step in f.map.find_path(sq.pos, f.map.gate, sq.traits):
		if not f.map.is_structure(step):
			assert_true(f.map.terrain[step] != BattleMap.Terrain.WATER, "the horde's route goes round the river")
	assert_false(f.can_stand(sq, _o(3, 6)), "a pack cannot stand in water")
	assert_true(f.nearest_free(_o(3, 6), []) != _o(3, 6), "a spawn never lands on water")
	assert_eq(path.size(), 2, "a pack at 20 walks two land hexes a phase")


func test_a_hunter_whose_prey_stands_in_water_aims_at_the_shore() -> void:
	var f := _field()
	var water := _o(3, 7)
	f.map.terrain[water] = BattleMap.Terrain.WATER
	var sq := f.add_unit(Unit.pack(1, "brutes", _o(3, 3), "demonic", 30))
	sq.behaviour = "hunt"
	sq.hunts = "nearest"
	sq.zone = 1
	var prey := f.add_unit(Unit.mech(2, "A", water, 0))
	prey.traits.append("walker")
	var target := f.hunt_target(sq, prey)
	assert_true(target != water, "the goal is not the water hex")
	assert_eq(Hex.distance(target, water), 1, "it is a shore hex inside the pack's zone of the prey")
	assert_true(BattleMap.passable(f.map.terrain[target], sq.traits), "and one the pack can stand on")
	f.compute_intents()
	assert_true(not f.intents[1].is_empty(), "the hunter moves instead of freezing")
	var res := f.resolve_phase({})
	assert_true(Hex.distance(sq.pos, water) <= 2, "it closed on the prey: now at %s" % str(sq.pos))
	assert_eq(res.skirmishes.size(), 1 if Hex.distance(sq.pos, water) <= sq.zone else 0, "a fight opens when the shore is inside its zone")


func test_the_boss_takes_its_move_from_content() -> void:
	var f := _field()
	f.foe_profiles = {"colossus": {"zone": 2, "behaviour": "push", "hunts": "nearest", "movespeed": 10}}
	var b := f.add_unit(f.dress_pack(Unit.boss(1, "colossus", _o(3, 2), "undead"), "colossus"))
	assert_eq(b.movespeed, 10, "a boss's move is dressed from its foe type too")
	assert_true(b.elite, "and it stays the boss")


func test_a_pack_held_off_its_gate_hex_by_its_own_side_turns_for_another() -> void:
	# Ryan, 6 October: a stalled horde is never the norm. The row the gate is struck from
	# is held at the three middle columns, so the nearest gate hex cannot be approached;
	# the pack behind turns for a gate hex whose approach is free instead of standing still.
	var f := _field(7, 13)
	for col in [2, 3, 4]:
		f.add_unit(Unit.pack(10 + col, "wall", _o(col, 10), "undead", 20))
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 8), "undead", 20))
	f.compute_intents()
	assert_true(not f.intents[1].is_empty(), "the pack found a way")
	assert_true(not f.stalled.has(1), "and is not stalled")
	var before := sq.pos
	var res := f.resolve_phase({})
	assert_true(sq.pos != before, "it moved")
	assert_true(not res.stalled.has(1), "no stall mark")


func test_a_pack_with_no_way_to_any_goal_waits_and_is_marked() -> void:
	# The whole striking row is held by its own side: nothing is reachable, so the pack
	# waits where it is and the phase says so, in the preview as at the resolve.
	var f := _field(7, 13)
	for col in range(7):
		f.add_unit(Unit.pack(10 + col, "wall", _o(col, 10), "undead", 20))
	var sq := f.add_unit(Unit.pack(1, "ghouls", _o(3, 8), "undead", 20))
	f.compute_intents()
	assert_true(f.intents[1].is_empty(), "no path")
	assert_true(f.stalled.has(1), "marked stalled at the round's open")
	var pv: Dictionary = f.preview_phase({})
	assert_true((pv["result"] as Battlefield.PhaseResult).stalled.has(1), "the preview carries the mark")
	var res := f.resolve_phase({})
	assert_eq(sq.pos, _o(3, 8), "it waited")
	assert_true(res.stalled.has(1), "the resolve carries the mark")

extends TestCase


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


func test_valid_route_moves_mech() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 10), 3))
	var target := _o(3, 8)
	var route := f.map.find_path(m.pos, target, m.traits)
	var res := f.resolve_phase({1: route})
	assert_eq(m.pos, target, "mech arrived")
	assert_true(res.moved.has(1), "reported as moved")


func test_route_through_occupied_is_rejected() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 10), 3))
	var start := m.pos
	var route := f.map.find_path(m.pos, _o(3, 8), m.traits)
	f.add_unit(Unit.mech(2, "B", route[0], 1))
	var res := f.resolve_phase({1: route})
	assert_eq(m.pos, start, "mech stayed put")
	assert_true(res.rejected.has(1), "route rejected")


func test_route_beyond_movespeed_is_rejected() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 10), 1))
	var route := f.map.find_path(m.pos, _o(3, 8), m.traits)
	var res := f.resolve_phase({1: route})
	assert_true(res.rejected.has(1), "two steps rejected at movespeed 1")


func test_squad_marches_toward_gate() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.squad(1, "ghouls", _o(3, 2), "undead", 2))
	var before := Hex.distance(sq.pos, f.map.gate)
	f.compute_intents()
	assert_eq(f.intents[1].size(), 2, "preview shows two steps")
	f.resolve_phase({})
	assert_eq(Hex.distance(sq.pos, f.map.gate), before - 2, "two hexes closer to the gate")
	assert_eq(sq.pos, f.intents[1][1], "landed exactly where the preview said")


func test_mech_body_blocks_squad() -> void:
	# A grounded machine in the middle of a corridor (three columns: every hex of its row
	# is under its guns): the squad stops on the ground beside it, and that is the contact.
	var f := _field(3, 13)
	var m := f.add_unit(Unit.mech(2, "A", _o(1, 4), 0))
	var sq := f.add_unit(Unit.squad(1, "ghouls", _o(1, 2), "undead", 3))
	var res := f.resolve_phase({})
	assert_eq(Hex.distance(sq.pos, m.pos), 1, "squad stopped beside the machine")
	assert_true(res.intercepted.has(1), "squad reported as stopped by control")
	assert_eq(res.skirmishes.size(), 1, "contact makes a skirmish")


func test_flyer_does_not_block() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.squad(1, "ghouls", _o(3, 2), "undead", 2))
	f.compute_intents()
	var first_step: Vector2i = f.intents[1][0]
	var second_step: Vector2i = f.intents[1][1]
	var fly := Unit.mech(2, "Sparrowhawk", first_step, 0)
	fly.traits = ["flyer"]
	f.add_unit(fly)
	var res := f.resolve_phase({})
	assert_eq(sq.pos, second_step, "squad passed through the flyer's hex")
	assert_false(res.blocked.has(1), "not reported as blocked")


func test_squad_stops_short_of_flyer_destination() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.squad(1, "ghouls", _o(3, 2), "undead", 2))
	f.compute_intents()
	var first_step: Vector2i = f.intents[1][0]
	var second_step: Vector2i = f.intents[1][1]
	var fly := Unit.mech(2, "Sparrowhawk", second_step, 0)
	fly.traits = ["flyer"]
	f.add_unit(fly)
	f.resolve_phase({})
	assert_eq(sq.pos, first_step, "never lands on an occupied hex")


func test_gate_takes_damage_when_squad_arrives() -> void:
	var f := _field()
	var gate_o := Hex.axial_to_offset(f.map.gate)
	var front := _o(gate_o.x, gate_o.y - BattleMap.GATE_ROWS)   # the open row above the apron
	var sq := f.add_unit(Unit.squad(1, "ghouls", front, "undead", 2, 6))
	f.compute_intents()
	assert_eq(f.intents[1].size(), 1, "preview shows the strike")
	assert_true(f.map.gate_hexes.has(f.intents[1][0]), "preview targets the gate (its apron)")
	var hp := f.gate_hp
	var res := f.resolve_phase({})
	assert_true(f.gate_hp < hp, "gate lost hp")
	assert_eq(res.gate_damage, hp - f.gate_hp, "damage reported")
	assert_eq(sq.pos, front, "squad holds position at the gate")


func test_aggro_squad_hunts_nearest_mech() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.squad(1, "hunters", _o(3, 3), "demonic", 2))
	sq.aggro = true
	var near := f.add_unit(Unit.mech(2, "A", _o(3, 6), 0))
	f.add_unit(Unit.mech(3, "B", _o(3, 11), 0))
	f.compute_intents()
	var path: Array = f.intents[1]
	var last: Vector2i = path[path.size() - 1]
	assert_true(Hex.distance(last, near.pos) < Hex.distance(sq.pos, near.pos), "closes on the nearer mech")


func test_skirmish_groups_connected_units() -> void:
	var f := _field()
	var sq_pos := _o(3, 6)
	f.add_unit(Unit.squad(1, "ghouls", sq_pos, "undead", 0))
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
	var m := f.add_unit(Unit.mech(2, "A", _o(3, 7), 3))
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
	assert_eq(f.map.gate_hexes.size(), 3 * BattleMap.GATE_ROWS, "three gate hexes per gate row")
	assert_eq(f.map.rift_hexes.size(), 3, "three rift hexes")
	var side: Vector2i = f.map.gate_hexes[0]   # the apron row comes first: a squad strikes from above it
	var side_o := Hex.axial_to_offset(side)
	var sq := f.add_unit(Unit.squad(1, "ghouls", _o(side_o.x, side_o.y - 1), "undead", 2))
	f.compute_intents()
	assert_true(f.map.gate_hexes.has(f.intents[1][0]), "preview strikes a gate hex")
	var hp := f.gate_hp
	f.resolve_phase({})
	assert_true(f.gate_hp < hp, "side gate hex takes damage")


func test_nobody_stands_on_structures() -> void:
	var f := _field()
	var gate_o := Hex.axial_to_offset(f.map.gate)
	var m := f.add_unit(Unit.mech(1, "A", _o(gate_o.x, gate_o.y - BattleMap.GATE_ROWS), 3))
	var r := f.reachable(m)
	for g in f.map.gate_hexes:
		assert_false(r.has(g), "gate hex %s not reachable" % str(g))
	assert_false(f.is_free(f.map.rift), "rift is not free ground")


func test_facing_follows_the_last_step() -> void:
	var f := _field()
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 10), 3))
	var route := f.map.find_path(m.pos, _o(3, 8), m.traits)
	f.resolve_phase({1: route})
	var expected := route[route.size() - 1] - route[route.size() - 2]
	assert_eq(Hex.DIRECTIONS[m.facing], expected, "facing matches the final step")


func test_pressure_spawns_squad_at_rift() -> void:
	var f := _field()
	f.rift_pressure_max = 2
	assert_eq(f.squads().size(), 0, "starts empty")
	f.resolve_phase({})
	assert_eq(f.squads().size(), 0, "one tick, no spawn")
	var res := f.resolve_phase({})
	assert_true(res.spawned, "second tick spawns")
	assert_eq(f.squads().size(), 1, "one squad now")
	assert_eq(f.squads()[0].foe_id, "ghoul", "spawned from the spawn table")
	assert_eq(f.rift_pressure, 0, "clock reset")
	assert_true(Hex.distance(f.squads()[0].pos, f.map.rift) <= 1, "spawned at or beside the rift")


func test_preview_matches_resolve_and_leaves_nothing_behind() -> void:
	# The plan's preview is the resolver run dry: same ends, same contacts, same blocks,
	# and afterwards every unit is where it was.
	for s in range(1, 12):
		var b := Battle.new(s)
		b.setup([Unit.mech(1, "A", Vector2i.ZERO, 3), Unit.mech(2, "B", Vector2i.ZERO, 3)], "undead")
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
	b.setup([Unit.mech(1, "A", Vector2i.ZERO, 3), Unit.mech(2, "B", Vector2i.ZERO, 3)], "undead")
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
	var a := f.add_unit(Unit.mech(1, "A", _o(3, 10), 3))
	var b_unit := f.add_unit(Unit.mech(2, "B", _o(3, 11), 3))
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



func test_squads_plan_in_order_around_each_others_destinations() -> void:
	# Two squads in a column heading for the gate. The front one takes the hex the rear
	# one would have reached, so the rear one plans around it rather than stopping short.
	var f := _field(7, 14)
	var front := f.add_unit(Unit.squad(1, "front", _o(3, 6), "undead", 2))
	var rear := f.add_unit(Unit.squad(2, "rear", _o(3, 4), "undead", 2))
	f.compute_intents()
	var front_end: Vector2i = f.intents[front.id][f.intents[front.id].size() - 1]
	var rear_path: Array = f.intents[rear.id]
	assert_false(rear_path.has(front_end), "the rear squad does not plan through the front's destination")
	assert_eq(rear_path.size(), 2, "and still uses its whole move")
	var res := f.resolve_phase({})
	assert_false(res.blocked.has(rear.id), "so it is not blocked at resolve")
	assert_eq(rear.pos, rear_path[rear_path.size() - 1], "and lands where the intent said")


func test_a_replot_moves_the_mech_to_the_end_of_the_order() -> void:
	var b := Battle.new(1)
	b.setup([Unit.mech(1, "A", Vector2i.ZERO, 3), Unit.mech(2, "B", Vector2i.ZERO, 3)], "undead")
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


func test_a_squad_stepping_beside_a_mech_stops_there_and_a_flyer_stops_nobody() -> void:
	# Control (decided 22 September): the ground beside a grounded machine stops a squad.
	var f := _field(3, 14)   # a corridor: no way round
	var m := f.add_unit(Unit.mech(1, "A", _o(1, 6), 0))
	var sq := f.add_unit(Unit.squad(2, "ghouls", _o(1, 2), "undead", 4))
	f.compute_intents()
	var path: Array = f.intents[sq.id]
	assert_true(f.controlled(path[path.size() - 1]), "the intent ends on controlled ground")
	var res := f.resolve_phase({})
	assert_true(res.intercepted.has(sq.id), "stopped by control")
	assert_eq(Hex.distance(sq.pos, m.pos), 1, "beside the machine")
	assert_eq(res.skirmishes.size(), 1, "and that is a contact")
	# A flyer in the same spot controls nothing: the squad passes.
	var f2 := _field(3, 14)
	var fly := f2.add_unit(Unit.mech(1, "hawk", _o(1, 6), 0))
	fly.traits = ["flyer"]
	var sq2 := f2.add_unit(Unit.squad(2, "ghouls", _o(1, 2), "undead", 4))
	f2.compute_intents()
	var res2 := f2.resolve_phase({})
	assert_false(res2.intercepted.has(sq2.id), "a flyer stops nobody")
	assert_true(Hex.distance(sq2.pos, f2.map.gate) < Hex.distance(_o(1, 2), f2.map.gate) - 2, "the squad kept going")


func test_squads_route_around_control_when_they_can() -> void:
	var f := _field(7, 14)
	f.add_unit(Unit.mech(1, "A", _o(1, 6), 0))   # off to one side: the squad can go round
	var sq := f.add_unit(Unit.squad(2, "ghouls", _o(3, 2), "undead", 3))
	f.compute_intents()
	for h in f.intents[sq.id]:
		assert_false(f.controlled(h), "the path keeps off controlled ground")
	var res := f.resolve_phase({})
	assert_false(res.intercepted.has(sq.id), "and nothing stops it")


func test_the_preview_shows_a_squad_stopped_by_a_route_not_yet_resolved() -> void:
	# A mech's plotted route ends beside the squad's path: the preview's intents already
	# stop there, before Resolve.
	var f := _field(3, 14)
	var m := f.add_unit(Unit.mech(1, "A", _o(1, 8), 3))
	var sq := f.add_unit(Unit.squad(2, "ghouls", _o(1, 3), "undead", 4))   # wants past row 7
	f.compute_intents()
	var free_path: Array = f.intents[sq.id]
	var routes := {m.id: f.map.find_path(m.pos, _o(1, 7), m.traits)}
	var pv := f.preview_phase(routes)
	var res: Battlefield.PhaseResult = pv["result"]
	assert_true(res.intercepted.has(sq.id), "the preview stops the squad")
	var shown: Array = res.intents[sq.id]
	assert_true(shown.size() <= free_path.size(), "its shown path is cut at the control")
	assert_eq(sq.pos, _o(1, 3), "and nothing moved")


func test_a_squad_already_beside_a_machine_holds_its_ground() -> void:
	var f := _field(7, 14)
	var m := f.add_unit(Unit.mech(1, "A", _o(3, 6), 0))
	var sq := f.add_unit(Unit.squad(2, "ghouls", _o(3, 5), "undead", 3))
	f.compute_intents()
	assert_true((f.intents[sq.id] as Array).is_empty(), "no intent: it is engaged where it stands")
	var res := f.resolve_phase({})
	assert_eq(sq.pos, _o(3, 5), "it did not move")
	assert_false(res.blocked.has(sq.id), "and it is not a body block")
	assert_eq(res.skirmishes.size(), 1, "the contact is the fight")
	assert_eq(Hex.distance(sq.pos, m.pos), 1, "still beside the machine")
	# Beside a flyer it moves on as if nothing were there.
	var f2 := _field(7, 14)
	var fly := f2.add_unit(Unit.mech(1, "hawk", _o(3, 6), 0))
	fly.traits = ["flyer"]
	var sq2 := f2.add_unit(Unit.squad(2, "ghouls", _o(3, 5), "undead", 3))
	f2.compute_intents()
	assert_false((f2.intents[sq2.id] as Array).is_empty(), "a flyer holds nobody")

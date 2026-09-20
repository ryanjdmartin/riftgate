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
	var f := _field()
	var sq := f.add_unit(Unit.squad(1, "ghouls", _o(3, 2), "undead", 2))
	f.compute_intents()
	var second_step: Vector2i = f.intents[1][1]
	var first_step: Vector2i = f.intents[1][0]
	f.add_unit(Unit.mech(2, "A", second_step, 0))
	var res := f.resolve_phase({})
	assert_eq(sq.pos, first_step, "squad stopped one short")
	assert_true(res.blocked.has(1), "squad reported as blocked")
	assert_eq(res.skirmishes.size(), 1, "contact makes a skirmish")


func test_flyer_does_not_block() -> void:
	var f := _field()
	var sq := f.add_unit(Unit.squad(1, "ghouls", _o(3, 2), "undead", 2))
	f.compute_intents()
	var first_step: Vector2i = f.intents[1][0]
	var second_step: Vector2i = f.intents[1][1]
	var fly := Unit.mech(2, "Raptor", first_step, 0)
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
	var fly := Unit.mech(2, "Raptor", second_step, 0)
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

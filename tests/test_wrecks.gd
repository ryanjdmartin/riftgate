extends TestCase

## A wreck on the map (Ryan, 4 November: a wreck stays on its hex and blocks it for the battle;
## 16 November: "A wreck should behave like any other unit, meaning nobody can land on it"): a
## machine wrecked in a fight lies where it fell for the rest of the battle, every walk passes it
## as it passes a unit, and nobody, machine or pack, ends a walk on it.


func _battle(seed_value: int = 3) -> Battle:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "clydesdale", "kite"]:
		team.append(db.make_mech(id))
	var b := Battle.new(seed_value)
	b.setup(team, "marsh", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
	quiet_start(b)
	return b


## Lay a wreck on `h` the way a lost fight does (Battlefield.apply_skirmish_result): the machine
## off the units, on the field's wrecks at that hex.
func _wreck_at(b: Battle, u: Unit, h: Vector2i) -> void:
	u.pos = h
	u.hull = 0
	b.field.units.erase(u)
	b.field.wrecks.append(u)


## A hex of open ground nobody stands on, within `within` hexes of `near`.
func _open_hex(b: Battle, near: Vector2i, within: int = 3) -> Vector2i:
	var probe := Unit.new()
	for h in b.field.map.all_hexes():
		if h != near and Hex.distance(h, near) <= within and b.field.can_stand(probe, h) and not b.field.map.is_structure(h):
			return h
	return Battlefield.NO_HEX


func test_a_lost_fight_leaves_its_wreck_where_it_fell() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	for n in Hex.neighbors(m.pos):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	sq.movespeed = 0
	sq.behaviour = "push"
	var where := m.pos
	var sk := b.attack(sq, [m])
	lose_fight(sk)
	b.finish_skirmish()
	assert_false(b.field.units.has(m), "the wreck is off the units")
	assert_false(b.mechs().has(m), "and no machine of the battle's")
	assert_true(b.field.wrecks.has(m), "it lies on the field")
	assert_eq(m.pos, where, "on the hex it fought from")
	assert_eq(b.field.wreck_at(where), m, "which it holds")
	assert_false(b.field.is_free(where), "so the hex is not free")


func test_no_machine_ends_a_move_on_a_wreck() -> void:
	var b := _battle()
	var dead: Unit = b.mechs()[1]
	var m: Unit = b.mechs()[0]
	var dests := b.destinations_for(m)
	assert_false(dests.is_empty(), "the machine can move")
	var h: Vector2i = dests.keys()[0]
	_wreck_at(b, dead, h)
	assert_false(b.field.can_stand(m, h), "nobody stands on a wreck")
	assert_false(b.destinations_for(m).has(h), "so it is no place to move to")
	assert_true(b.move_to(m, h).is_empty(), "and a move onto it is refused")
	assert_true(b.field.can_pass(m, h), "but a walk passes it, as it passes a unit")


func test_a_route_passes_a_wreck_it_cannot_end_on() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var dead: Unit = b.mechs()[1]
	# A wreck in the middle of a straight line of open ground: the move two hexes on is still a
	# move of two, through it.
	var found := false
	for d in range(6):
		var one: Vector2i = m.pos + Hex.DIRECTIONS[d]
		var two: Vector2i = one + Hex.DIRECTIONS[d]
		if b.field.can_stand(m, one) and b.field.can_stand(m, two) and b.field.map.terrain[one] == BattleMap.Terrain.PLAIN and b.field.map.terrain[two] == BattleMap.Terrain.PLAIN:
			_wreck_at(b, dead, one)
			var route := b.field.route_to(m, two)
			assert_eq(route.size(), 2, "the shortest way is still two hexes")
			assert_eq(route[0], one, "through the wreck's hex")
			found = true
			break
	assert_true(found, "an open line beside the machine to test on")


func test_no_pack_ends_its_walk_on_a_wreck() -> void:
	var b := _battle()
	var dead: Unit = b.mechs()[1]
	var walks := b.field.plan_walks()
	var checked := 0
	for sq in b.field.packs():
		var w: Battlefield.Walk = walks[sq.id]
		if w.path.is_empty():
			continue
		# A wreck where the walk would have ended: the walk ends anywhere but there.
		if b.field.wrecks.has(dead):
			b.field.wrecks.erase(dead)
		_wreck_at(b, dead, w.end)
		var again: Battlefield.Walk = b.field.plan_walks()[sq.id]
		assert_ne(again.end, w.end, "%s ends its walk off the wreck" % sq.display_name)
		assert_eq(b.field.wreck_at(again.end), null, "on no wreck")
		checked += 1
		if checked >= 3:
			break
	assert_true(checked > 0, "a pack walked")


func test_a_pack_lands_off_a_wreck_and_no_tear_opens_on_one() -> void:
	var b := _battle()
	var dead: Unit = b.mechs()[1]
	var sq: Unit = b.field.packs()[0]
	var mouth := _open_hex(b, b.field.map.rift + Vector2i(0, 3), 4)
	assert_ne(mouth, Battlefield.NO_HEX, "an open hex to land on")
	_wreck_at(b, dead, mouth)
	assert_ne(b.field.landing(sq, mouth), mouth, "a pack emerging there lands beside the wreck")
	b.field.wrecks.erase(dead)
	var tear := b.field.tear_hex()
	if tear != Battlefield.NO_HEX:
		_wreck_at(b, dead, tear)
		assert_ne(b.field.tear_hex(), tear, "a tear opens off the wreck")


func test_a_saved_battle_keeps_its_wreck_and_its_hold() -> void:
	var b := _battle()
	var dead: Unit = b.mechs()[1]
	var m: Unit = b.mechs()[0]
	var h: Vector2i = b.destinations_for(m).keys()[0]
	_wreck_at(b, dead, h)
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(back.field.wrecks.size(), 1, "the wreck read back")
	var w: Unit = back.field.wrecks[0]
	assert_eq(w.id, dead.id, "the same machine")
	assert_eq(w.pos, h, "where it fell")
	assert_false(back.field.can_stand(back.field.unit_by_id(m.id), h), "holding its hex")


func test_the_bot_plays_round_a_wreck() -> void:
	# A wreck in the middle of the field, and the bot plays the battle's turns: no machine and no
	# pack ever stands on it.
	var b := _battle(11)
	var dead: Unit = b.mechs()[2]
	var mid := Hex.offset_to_axial(b.map.width / 2, b.map.height / 2)
	var h := _open_hex(b, mid, 3)
	assert_ne(h, Battlefield.NO_HEX, "an open hex in the middle")
	_wreck_at(b, dead, h)
	b.field.rift_pressure_max = 6   # the tide runs, so packs come down past the wreck
	var bot := BattleBot.make(Policy.GREEDY, 11)
	for turn in range(8):
		if b.state != Battle.State.PLAN:
			break
		bot.take_turn(b)
		for u in b.field.units:
			for x in u.hexes():
				assert_eq(b.field.wreck_at(x), null, "%s stands off the wreck (turn %d, after the player's)" % [u.display_name, turn])
		if b.state != Battle.State.PLAN:
			break
		b.end_turn()
		for u in b.field.units:
			for x in u.hexes():
				assert_eq(b.field.wreck_at(x), null, "%s stands off the wreck (turn %d, after the enemy's)" % [u.display_name, turn])
	assert_eq(b.field.wreck_at(h), dead, "the wreck still lies there")

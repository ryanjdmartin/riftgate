extends TestCase

## The runner's player that musters (BattleBot.Rule.MUSTER; the anchor's reads of 12 November,
## built 16 November on Ryan's word): each pack, in the order it reaches the wall, takes as many
## machines as it is rated, the nearest that can reach it; a pack that cannot have its rating is
## fought one short when it strikes the wall this coming turn and gathered on otherwise.


## Four tier-one machines on the gate's row and one pack left on the field, the boss aside (it is
## sealed: nobody may be ordered onto it), rated `rating`, parked at `at` and rooted there.
func _battle(rating: int) -> Battle:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "skua", "cassowary", "storm_petrel"]:
		team.append(db.make_mech(id))
	var b := Battle.new(5)
	b.setup(team, "meadow", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
	quiet_start(b)
	b.forced = []
	var kept: Unit = null
	for sq in b.field.packs():
		if sq.is_boss:
			continue
		if kept == null:
			kept = sq
		else:
			b.field.units.erase(sq)
	kept.squad = rating
	kept.movespeed = 0
	kept.behaviour = "push"
	return b


func _pack(b: Battle) -> Unit:
	for sq in b.field.packs():
		if not sq.is_boss:
			return sq
	return null


## The machines ordered onto `sq`.
func _on(b: Battle, sq: Unit) -> Array:
	var out: Array = []
	for m in b.mechs():
		if b.order_of(m) == sq:
			out.append(m)
	return out


## Park the pack on open ground `rows` rows in front of the machines' middle, off the apron.
func _park_ahead(b: Battle, sq: Unit, rows: int) -> void:
	var mid: Unit = b.mechs()[1]
	var at := Hex.axial_to_offset(mid.pos)
	sq.pos = b.field.nearest_standable(sq, Hex.offset_to_axial(at.x, at.y - rows))


## Send a machine to the far side of the field from the pack, out of its move's reach of it.
func _send_away(b: Battle, m: Unit, sq: Unit) -> void:
	var far := Vector2i.ZERO
	var best := -1
	for h in b.field.map.all_hexes():
		if b.field.can_stand(m, h) and Hex.distance(h, sq.pos) > best:
			best = Hex.distance(h, sq.pos)
			far = h
	m.pos = far


func test_a_pack_takes_its_ratings_count_the_nearest() -> void:
	var b := _battle(3)
	var sq := _pack(b)
	_park_ahead(b, sq, 3)
	var bot := BattleBot.make(Policy.GREEDY, 1, BattleBot.Rule.MUSTER)
	bot.muster_orders(b)
	assert_eq(_on(b, sq).size(), 3, "a formation rated for three takes three machines")


func test_an_elite_rated_for_four_takes_all_four() -> void:
	var b := _battle(4)
	var sq := _pack(b)
	_park_ahead(b, sq, 3)
	var bot := BattleBot.make(Policy.GREEDY, 1, BattleBot.Rule.MUSTER)
	bot.muster_orders(b)
	assert_eq(_on(b, sq).size(), 4, "every machine onto the elite")


func test_a_pack_short_of_its_rating_is_gathered_on_not_fought() -> void:
	var b := _battle(4)
	var sq := _pack(b)
	_park_ahead(b, sq, 6)
	# Two machines far off: two can reach it, the elite is rated for four, and it is nowhere near
	# the wall.
	_send_away(b, b.mechs()[0], sq)
	_send_away(b, b.mechs()[3], sq)
	var before := {}
	for m in b.mechs():
		before[m.id] = Battlefield.unit_distance(m, sq)
	var bot := BattleBot.make(Policy.GREEDY, 1, BattleBot.Rule.MUSTER)
	assert_true(BattleBot.turns_to_wall(b, sq, b.field.plan_walks().get(sq.id, null)) > 1, "the pack strikes no wall this coming turn")
	var gathering := {}
	bot.muster_orders(b, gathering)
	assert_eq(_on(b, sq).size(), 0, "nobody fights it short")
	assert_eq(gathering.size(), 4, "its rating's count gather on it")
	var closer := 0
	for m in b.mechs():
		if Battlefield.unit_distance(m, sq) < int(before[m.id]):
			closer += 1
	assert_true(closer >= 2, "and walk toward it")


func test_a_pack_at_the_wall_is_fought_one_short() -> void:
	var b := _battle(4)
	var sq := _pack(b)
	# On the apron, so it strikes the wall this coming turn, beside the machines' row.
	var mid: Unit = b.mechs()[1]
	var spot := Battlefield.NO_HEX
	for h in b.field.apron_hexes().keys():
		if b.field.can_stand(sq, h) and Hex.distance(h, mid.pos) <= 3:
			spot = h
			break
	assert_ne(spot, Battlefield.NO_HEX, "an apron hex near the machines")
	sq.pos = spot
	_send_away(b, b.mechs()[3], sq)
	var bot := BattleBot.make(Policy.GREEDY, 1, BattleBot.Rule.MUSTER)
	assert_eq(BattleBot.turns_to_wall(b, sq, b.field.plan_walks().get(sq.id, null)), 0, "it stands on the apron")
	bot.muster_orders(b)
	assert_eq(_on(b, sq).size(), 3, "three of the four it is rated for fight it rather than let it strike")
	# The what-if of 19 November (the battle runner's --whole): the player that never fights short
	# gathers its rating and lets the strike land.
	var b2 := _battle(4)
	var sq2 := _pack(b2)
	sq2.pos = spot
	_send_away(b2, b2.mechs()[3], sq2)
	var whole := BattleBot.make(Policy.GREEDY, 1, BattleBot.Rule.MUSTER)
	whole.short_at_wall = false
	whole.muster_orders(b2)
	assert_eq(_on(b2, sq2).size(), 0, "with the clause off nobody fights it short")


func test_the_packs_are_taken_in_the_order_they_reach_the_wall() -> void:
	var b := _battle(2)
	var sq := _pack(b)
	_park_ahead(b, sq, 3)
	var near_wall := Battlefield.NO_HEX
	for h in b.field.apron_hexes().keys():
		if b.field.can_stand(sq, h) and Hex.distance(h, sq.pos) >= 2:
			near_wall = h
			break
	var second := Battlefield.pack_of(Battlefield.composition([["goblin", 3]], "meadow"))
	b.field.dress_pack(second, "goblin")
	second.squad = 1
	second.movespeed = 0
	second.behaviour = "push"
	second.pos = near_wall
	b.field.add_unit(second)
	var order := BattleBot.by_wall(b, b.field.plan_walks())
	assert_eq(order[0], second, "the pack on the apron comes first")


func test_the_unsealed_boss_comes_first() -> void:
	var b := _battle(2)
	var sq := _pack(b)
	for h in b.field.apron_hexes().keys():
		if b.field.can_stand(sq, h):
			sq.pos = h
			break
	assert_true(b.boss != null, "a boss holds the rift")
	assert_false(BattleBot.by_wall(b, b.field.plan_walks()).has(b.boss), "sealed, nobody is ordered onto it")
	b.boss.sealed = false
	var order := BattleBot.by_wall(b, b.field.plan_walks())
	assert_eq(order[0], b.boss, "the seal broken, it comes before the pack at the wall: the race for it")


func test_the_mustering_player_plays_a_battle_through() -> void:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "skua", "cassowary", "storm_petrel"]:
		team.append(db.make_mech(id))
	var b := Battle.new(9)
	b.setup(team, "meadow")
	var bot := BattleBot.make(Policy.GREEDY, 9, BattleBot.Rule.MUSTER)
	var outcome := bot.play(b)
	assert_true(b.state == Battle.State.DONE or bot.stalled, "the battle runs to an end")
	if not bot.stalled:
		assert_ne(outcome, Battle.Outcome.NONE, "and has an outcome")
	assert_true(bot.fights > 0, "it fought")
	var largest := 0
	for f in bot.fight_sizes:
		largest = maxi(largest, int(f[0]))
	assert_true(largest >= 3, "and mustered three or more machines into a fight")

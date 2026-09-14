extends TestCase

const L := Face.Reach.LINE
const I := Face.Reach.INDIRECT
const K := Face.Keyword


func _mech(name: String, d: Die, shield: int = 4, hull: int = 10) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _ghoul(hp: int = 3, atk: int = 1) -> Foe:
	return Foe.make("ghoul", hp, atk)


func _archer(hp: int = 3, atk: int = 1) -> Foe:
	return Foe.make("archer", hp, atk, true)


func test_formation_fills_front_then_back() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(1))))
	sk.add_foes([_ghoul(), _ghoul(), _archer(), _ghoul(), _ghoul()])
	sk.begin()
	assert_eq(sk.field_foes().size(), 5, "five on the field")
	assert_eq(sk.front[0].display_name, "ghoul", "front 0 is a ghoul")
	assert_eq(sk.front[2].display_name, "ghoul", "front 2 is a ghoul")
	assert_eq(sk.back[0].display_name, "archer", "archer holds the back")
	assert_eq(sk.back[1].display_name, "ghoul", "spare ghoul waits in the back")
	assert_eq(sk.pool.size(), 0, "pool drained")


func test_line_reach_needs_exposed_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(3, L))))
	sk.add_foes([_ghoul(3), _ghoul(3), _archer()])
	sk.begin()
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.size(), 2, "only the two front ghouls are in line of fire")
	assert_false(t.has(sk.back[0]), "archer behind a ghoul is not exposed")
	# Kill the ghoul in front of the archer.
	assert_true(sk.assign(0, sk.front[0]), "attack front 0")
	sk.end_round()
	assert_true(sk.is_exposed(0), "column 0 is exposed now")
	sk.start_round()
	assert_true(sk.targets_for(0).has(sk.back[0]), "archer is now a line target")


func test_indirect_reaches_back_and_splashes_on_front() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(2, I)), 4)
	sk.add_mech(m)
	sk.add_foes([_ghoul(5), _archer(5)])
	sk.begin()
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.size(), 2, "indirect sees both ranks")
	assert_true(sk.assign(0, sk.front[0]), "mortar the front")
	assert_eq(m.shield, 3, "danger close cost one shield")
	assert_eq(sk.front[0].hp, 3, "ghoul took 2")


func test_pierce_hits_the_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(3, L, K.PIERCE))))
	sk.add_foes([_ghoul(5), _archer(5)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "pierce front 0")
	assert_eq(sk.front[0].hp, 2, "front took 3")
	assert_eq(sk.back[0].hp, 2, "back of the same column took 3")


func test_cleave_hits_neighbours() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(2, L, K.CLEAVE))))
	sk.add_foes([_ghoul(5), _ghoul(5), _ghoul(5)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[1]), "cleave the middle")
	for c in range(3):
		assert_eq(sk.front[c].hp, 3, "front %d took 2" % c)


func test_enemy_targets_lowest_shield() -> void:
	var sk := Skirmish.new(1)
	var tough := _mech("Tough", Die.single(Face.shield(1)), 4, 10)
	var weak := _mech("Weak", Die.single(Face.shield(1)), 1, 10)
	sk.add_mech(tough)
	sk.add_mech(weak)
	sk.add_foes([_ghoul(3, 2)])
	sk.begin()
	sk.start_round()
	# Spend the shield faces on nobody useful so the numbers stay readable: assign to self.
	weak.shield = 1  # shield face capped at shield_max anyway
	sk.end_round()
	assert_eq(tough.shield, 4, "tough untouched")
	assert_eq(weak.shield, 0, "weak lost its shield")
	assert_eq(weak.hull, 9, "and one hull")


func test_heat_overflow_damages_hull() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("Hot", Die.single(Face.attack(1, L, K.NONE, 8)), 4, 10)
	sk.add_mech(m)
	sk.add_foes([_ghoul(9)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "fire the hot gun")
	assert_eq(sk.mechs[0].heat, 6, "heat capped at max")
	assert_eq(m.hull, 8, "two points of overflow hit the hull")


func test_overcharge_doubles_damage_and_heat() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(2, L, K.OVERCHARGE, 1))))
	sk.add_foes([_ghoul(9)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 5, "took 4")
	assert_eq(sk.mechs[0].heat, 2, "heat doubled")


func test_suppress_cancels_intent() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(1, L, K.SUPPRESS)), 0, 10)
	sk.add_mech(m)
	sk.add_foes([_ghoul(9, 3)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.hull, 10, "suppressed ghoul did not strike")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 7, "next round it does")


func test_burn_ticks_down() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(2, L, K.BURN)), 9, 10)
	sk.add_mech(m)
	sk.add_foes([_ghoul(9)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var g: Foe = sk.front[0]
	assert_eq(g.hp, 7, "took 2 on hit")
	assert_eq(g.burn, 1, "one burn stack from power 2")
	sk.end_round()
	assert_eq(g.hp, 6, "burn ticked for 1")
	assert_eq(g.burn, 0, "stack consumed")


func test_victory_when_pool_exhausted() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(3, L))))
	sk.add_foes([_ghoul(2)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var out := sk.end_round()
	assert_eq(out, Skirmish.Outcome.VICTORY, "victory")
	assert_eq(sk.state, Skirmish.State.DONE, "skirmish done")


func test_defeat_when_all_hulls_zero() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.shield(1)), 0, 2))
	sk.add_foes([_ghoul(9, 5)])
	sk.begin()
	sk.start_round()
	var out := sk.end_round()
	assert_eq(out, Skirmish.Outcome.DEFEAT, "defeat")


func test_horde_keeps_coming() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(9, L))))
	var foes: Array = []
	for i in range(8):
		foes.append(_ghoul(3))
	sk.add_foes(foes)
	sk.begin()
	assert_eq(sk.field_foes().size(), 6, "six on the field")
	assert_eq(sk.pool.size(), 2, "two in the pool")
	sk.start_round()
	sk.assign(0, sk.front[1])
	sk.end_round()
	assert_eq(sk.field_foes().size(), 6, "the gap is refilled")
	assert_eq(sk.pool.size(), 1, "one left in the pool")
	assert_true(sk.front[1] != null, "a back-rank ghoul stepped up")


func test_withdraw_only_between_rounds() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(1, L))))
	sk.add_foes([_ghoul(9, 1)])
	sk.begin()
	assert_false(sk.can_withdraw(), "not before the first round")
	sk.start_round()
	assert_false(sk.can_withdraw(), "not while assigning")
	assert_false(sk.withdraw(), "withdraw refused mid-round")
	sk.end_round()
	assert_true(sk.can_withdraw(), "allowed after the enemy acted")
	assert_true(sk.withdraw(), "withdrew")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "outcome withdrawn")


func test_rerolls_are_limited() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Loadouts.gunner_die()))
	sk.add_foes([_ghoul(9)])
	sk.begin()
	sk.start_round()
	assert_true(sk.reroll([0]), "first reroll")
	assert_true(sk.reroll([0]), "second reroll")
	assert_false(sk.reroll([0]), "third refused")


func test_same_seed_same_rolls() -> void:
	var a := Skirmish.new(99)
	var b := Skirmish.new(99)
	for sk in [a, b]:
		sk.add_mech(_mech("A", Loadouts.gunner_die()))
		sk.add_mech(_mech("B", Loadouts.mortar_die()))
		sk.add_foes([_ghoul(9)])
		sk.begin()
		sk.start_round()
	assert_eq(a.mechs[0].face_index, b.mechs[0].face_index, "mech A rolls match")
	assert_eq(a.mechs[1].face_index, b.mechs[1].face_index, "mech B rolls match")


func test_injury_cracks_a_face_and_restores_after() -> void:
	var sk := Skirmish.new(3)
	var d := Die.of([Face.attack(1, L), Face.attack(1, L)])
	var m := _mech("A", d, 0, 10)
	sk.add_mech(m)
	sk.add_foes([Foe.make("necromancer", 9, 2, false, "corrode")])
	sk.begin()
	sk.start_round()
	sk.end_round()
	var blanks := 0
	for f in d.faces:
		if f.kind == Face.Kind.BLANK:
			blanks += 1
	assert_eq(blanks, 1, "one face cracked")
	assert_eq(m.hull, 8, "hull took the hit")
	sk.withdraw()
	blanks = 0
	for f in d.faces:
		if f.kind == Face.Kind.BLANK:
			blanks += 1
	assert_eq(blanks, 0, "faces restored when the skirmish ends")


func _colossus(hp: int = 14) -> Foe:
	var f := Foe.make("colossus", hp, 3, false, "corrode")
	f.size = 2
	return f


func test_massive_foe_fills_a_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(3, L))))
	sk.add_foes([_ghoul(), _ghoul(), _colossus(), _archer()])
	sk.begin()
	var col := -1
	for c in range(3):
		if sk.front[c] != null and sk.front[c].is_massive():
			col = c
	assert_true(col >= 0, "colossus placed in a column")
	assert_eq(sk.back[col], sk.front[col], "same foe in both slots")
	assert_false(sk.is_exposed(col), "its column is never exposed")
	assert_eq(sk.field_foes().size(), 4, "field lists it once")
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.count(sk.front[col]), 1, "line of fire lists it once")


func test_massive_foe_death_clears_both_slots() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(20, L))))
	sk.add_foes([_colossus(5)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "hit the colossus")
	var out := sk.end_round()
	assert_eq(sk.front[0], null, "front slot cleared")
	assert_eq(sk.back[0], null, "back slot cleared")
	assert_eq(out, Skirmish.Outcome.VICTORY, "and that was the whole squad")


func test_pierce_hits_a_massive_foe_once() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(3, L, K.PIERCE))))
	sk.add_foes([_colossus(14)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 11, "took 3, not 6")


func test_shield_face_helps_an_ally() -> void:
	var sk := Skirmish.new(1)
	var giver := _mech("Giver", Die.single(Face.shield(3)), 4, 10)
	var taker := _mech("Taker", Die.single(Face.attack(1, L)), 0, 10)
	sk.add_mech(giver)
	sk.add_mech(taker)
	sk.add_foes([_ghoul(9)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.mechs[1]), "shield the ally")
	assert_eq(taker.shield, 0, "capped at the ally's shield max of 0")
	taker.shield_max = 5
	sk.mechs[0].assigned = false
	assert_true(sk.assign(0, sk.mechs[1]), "shield again with room")
	assert_eq(taker.shield, 3, "ally gained 3")

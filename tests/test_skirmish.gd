extends TestCase

## Numbers are in tens. Static faces are used wherever the exact number matters; ranged
## faces are tested for bounds and for the steady keyword.

const L := Face.Reach.LINE
const I := Face.Reach.INDIRECT
const K := Face.Keyword


func _mech(name: String, d: Die, shield: int = 40, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _ghoul(hp: int = 30, atk: int = 10) -> Foe:
	return Foe.make("ghoul", hp, atk)


func _archer(hp: int = 30, atk: int = 10) -> Foe:
	return Foe.make("archer", hp, atk, true)


func test_formation_fills_front_then_back() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10))))
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
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	sk.add_foes([_ghoul(30), _ghoul(30), _archer()])
	sk.begin()
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.size(), 2, "only the two front ghouls are in line of fire")
	assert_false(t.has(sk.back[0]), "archer behind a ghoul is not exposed")
	assert_true(sk.assign(0, sk.front[0]), "attack front 0")
	sk.end_round()
	assert_true(sk.is_exposed(0), "column 0 is exposed now")
	sk.start_round()
	assert_true(sk.targets_for(0).has(sk.back[0]), "archer is now a line target")


func test_indirect_reaches_back_and_splashes_on_front() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, I)), 40)
	sk.add_mech(m)
	sk.add_foes([_ghoul(50), _archer(50)])
	sk.begin()
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.size(), 2, "indirect sees both ranks")
	assert_true(sk.assign(0, sk.front[0]), "mortar the front")
	assert_eq(m.shield, 30, "danger close cost ten shield")
	assert_eq(sk.front[0].hp, 30, "ghoul took 20")


func test_pierce_hits_the_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.PIERCE))))
	sk.add_foes([_ghoul(50), _archer(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "pierce front 0")
	assert_eq(sk.front[0].hp, 20, "front took 30")
	assert_eq(sk.back[0].hp, 20, "back of the same column took 30")


func test_cleave_hits_neighbours() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(20, L, K.CLEAVE))))
	sk.add_foes([_ghoul(50), _ghoul(50), _ghoul(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[1]), "cleave the middle")
	for c in range(3):
		assert_eq(sk.front[c].hp, 30, "front %d took 20" % c)


func test_enemy_targets_lowest_shield() -> void:
	var sk := Skirmish.new(1)
	var tough := _mech("Tough", Die.single(Face.shield(10)), 40, 100)
	var weak := _mech("Weak", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(tough)
	sk.add_mech(weak)
	sk.add_foes([_ghoul(30, 20)])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(tough.shield, 40, "tough untouched")
	assert_eq(weak.shield, 0, "weak lost its shield")
	assert_eq(weak.hull, 90, "and ten hull")


func test_heat_overflow_damages_hull() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("Hot", Die.single(Face.attack(10, L, K.NONE, 80)), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "fire the hot gun")
	assert_eq(sk.mechs[0].heat, 60, "heat capped at max")
	assert_eq(m.hull, 80, "twenty points of overflow hit the hull")


func test_overcharge_doubles_damage_and_heat() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(20, L, K.OVERCHARGE, 10))))
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 50, "took 40")
	assert_eq(sk.mechs[0].heat, 20, "heat doubled")


func test_suppress_cancels_intent() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 30)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.hull, 100, "suppressed ghoul did not strike")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 70, "next round it does")


func test_burn_ticks_down() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L, K.BURN)), 90, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var g: Foe = sk.front[0]
	assert_eq(g.hp, 60, "took 30 on hit")
	assert_eq(g.burn, 2, "two burn stacks from 30 damage")
	sk.end_round()
	assert_eq(g.hp, 40, "burn ticked for 20")
	assert_eq(g.burn, 1, "one stack consumed")


func test_ranged_face_rolls_within_bounds() -> void:
	var lowest := 999
	var highest := 0
	for seed_value in range(1, 41):
		var sk := Skirmish.new(seed_value)
		sk.add_mech(_mech("A", Die.single(Face.attack(20, L, [], 0, 50))))
		sk.add_foes([_ghoul(200)])
		sk.begin()
		sk.start_round()
		sk.assign(0, sk.front[0])
		var dealt: int = 200 - sk.front[0].hp
		assert_true(dealt >= 20 and dealt <= 50, "roll %d within 20 to 50" % dealt)
		assert_eq(sk.last_roll["rolled"], dealt, "last_roll records the roll")
		assert_true(sk.last_roll["ranged"], "flagged as ranged")
		lowest = mini(lowest, dealt)
		highest = maxi(highest, dealt)
	assert_true(highest - lowest >= 15, "forty seeds spread across the range (%d to %d)" % [lowest, highest])


func test_steady_deals_the_average() -> void:
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("A", Die.single(Face.attack(20, L, K.STEADY, 0, 50))))
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 165, "20 to 50 steady deals 35")


func test_crit_doubles_the_roll() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, [], 0, 0, 100))))
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 140, "30 crit for 60")
	assert_true(sk.last_roll["crit"], "recorded as a crit")
	var never := Skirmish.new(1)
	never.add_mech(_mech("B", Die.single(Face.attack(30, L, [], 0, 0, 0))))
	never.add_foes([_ghoul(200)])
	never.begin()
	never.start_round()
	never.assign(0, never.front[0])
	assert_eq(never.front[0].hp, 170, "zero crit chance never crits")


func test_static_energy_face_never_varies() -> void:
	for seed_value in range(1, 11):
		var sk := Skirmish.new(seed_value)
		sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
		sk.add_foes([_ghoul(200)])
		sk.begin()
		sk.start_round()
		sk.assign(0, sk.front[0])
		assert_eq(sk.front[0].hp, 170, "static face always deals 30")


func test_victory_when_pool_exhausted() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	sk.add_foes([_ghoul(20)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var out := sk.end_round()
	assert_eq(out, Skirmish.Outcome.VICTORY, "victory")
	assert_eq(sk.state, Skirmish.State.DONE, "skirmish done")


func test_defeat_when_all_hulls_zero() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 20))
	sk.add_foes([_ghoul(90, 50)])
	sk.begin()
	sk.start_round()
	var out := sk.end_round()
	assert_eq(out, Skirmish.Outcome.DEFEAT, "defeat")


func test_horde_keeps_coming() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(90, L))))
	var foes: Array = []
	for i in range(8):
		foes.append(_ghoul(30))
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


func test_withdraw_window() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L))))
	sk.add_foes([_ghoul(90, 10)])
	sk.begin()
	assert_false(sk.can_withdraw(), "not before the first round")
	sk.start_round()
	assert_false(sk.can_withdraw(), "not in round one")
	assert_false(sk.withdraw(), "withdraw refused in round one")
	sk.end_round()
	assert_true(sk.can_withdraw(), "between rounds")
	sk.start_round()
	assert_true(sk.can_withdraw(), "at the start of round two")
	sk.assign(0, sk.front[0])
	assert_false(sk.can_withdraw(), "not once a face is spent")
	sk.end_round()
	sk.start_round()
	assert_true(sk.withdraw(), "withdrew at the start of round three")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "outcome withdrawn")


func test_rerolls_are_limited_and_work_after_attacking() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L))))
	sk.add_mech(_mech("B", Loadouts.gunner_die()))
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "A attacks first")
	assert_true(sk.reroll([1]), "then B rerolls: attack-then-reroll is allowed")
	assert_true(sk.reroll([1]), "second reroll")
	assert_false(sk.reroll([1]), "third refused")


func test_same_seed_same_rolls() -> void:
	var a := Skirmish.new(99)
	var b := Skirmish.new(99)
	for sk in [a, b]:
		sk.add_mech(_mech("A", Loadouts.gunner_die()))
		sk.add_mech(_mech("B", Loadouts.mortar_die()))
		sk.add_foes([_ghoul(90)])
		sk.begin()
		sk.start_round()
	assert_eq(a.mechs[0].face_index, b.mechs[0].face_index, "mech A rolls match")
	assert_eq(a.mechs[1].face_index, b.mechs[1].face_index, "mech B rolls match")


func _cracked_count(d: Die) -> int:
	var n := 0
	for f in d.faces:
		if f.cracked or f.kind == Face.Kind.BLANK:
			n += 1
	return n


func test_big_hull_hits_sometimes_crack_a_face() -> void:
	var cracked := 0
	var clean := 0
	for seed_value in range(1, 31):
		var sk := Skirmish.new(seed_value)
		var d := Die.of([Face.attack(10, L, K.CLEAVE), Face.attack(10, L, K.PIERCE)])
		var m := _mech("A", d, 0, 100)
		sk.add_mech(m)
		sk.add_foes([Foe.make("brute", 90, 50)])
		sk.begin()
		sk.start_round()
		sk.end_round()
		assert_eq(m.hull, 50, "the hit reached the hull")
		if _cracked_count(d) > 0:
			cracked += 1
		else:
			clean += 1
	assert_true(cracked > 0 and clean > 0, "a half-hull hit cracks a face about half the time (%d of 30)" % cracked)


func test_small_hits_and_shielded_hits_never_crack() -> void:
	for seed_value in range(1, 11):
		var sk := Skirmish.new(seed_value)
		var d := Die.of([Face.attack(10, L, K.CLEAVE)])
		var m := _mech("A", d, 0, 100)
		sk.add_mech(m)
		sk.add_foes([Foe.make("ghoul", 90, 20)])
		sk.begin()
		sk.start_round()
		sk.end_round()
		assert_eq(_cracked_count(d), 0, "a hit under a quarter of hull never cracks")
	for seed_value in range(1, 11):
		var sk := Skirmish.new(seed_value)
		var d := Die.of([Face.attack(10, L, K.CLEAVE)])
		var m := _mech("A", d, 60, 100)
		sk.add_mech(m)
		sk.add_foes([Foe.make("brute", 90, 50)])
		sk.begin()
		sk.start_round()
		sk.end_round()
		assert_eq(_cracked_count(d), 0, "a hit absorbed by shield never cracks")


func test_injury_cracks_then_destroys_and_persists_until_repaired() -> void:
	var sk := Skirmish.new(3)
	var d := Die.single(Face.attack(30, L, [K.CLEAVE, K.BURN], 10, 50, 15))
	var m := _mech("A", d, 0, 100)
	sk.add_mech(m)
	sk.add_foes([Foe.make("ghoul", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.apply_injury(sk.mechs[0])
	var f := d.faces[0]
	assert_true(f.cracked, "first injury cracks the face")
	assert_eq(f.kind, Face.Kind.ATTACK, "it still attacks")
	assert_eq(f.power, 30, "with its basic damage")
	assert_true(f.keywords.is_empty(), "keywords gone")
	assert_eq(f.crit, 0, "crit gone")
	assert_true(f.describe().ends_with("(cracked)"), "described as cracked")
	assert_eq(m.damaged_face_count(), 1, "one damaged component on the unit")
	sk.apply_injury(sk.mechs[0])
	assert_eq(d.faces[0].kind, Face.Kind.BLANK, "second injury destroys it")
	assert_eq(m.damaged_face_count(), 1, "still one component, now destroyed")
	sk.end_round()
	sk.start_round()
	sk.withdraw()
	assert_eq(d.faces[0].kind, Face.Kind.BLANK, "the skirmish ending does not repair it")
	# A second skirmish with the same unit starts with the damage in place.
	var again := Skirmish.new(4)
	again.add_mech(m)
	again.add_foes([Foe.make("ghoul", 90, 10)])
	again.begin()
	again.start_round()
	assert_eq(again.mechs[0].face().kind, Face.Kind.BLANK, "the destroyed face is still destroyed next fight")
	m.repair_faces()
	assert_eq(d.faces[0].kind, Face.Kind.ATTACK, "hangar repair restores the component")
	assert_true(d.faces[0].has(K.CLEAVE) and d.faces[0].has(K.BURN), "with its keywords")
	assert_eq(d.faces[0].crit, 15, "and its crit")
	assert_false(d.faces[0].cracked, "not cracked any more")
	assert_eq(m.damaged_face_count(), 0, "nothing left to repair")


func _colossus(hp: int = 140) -> Foe:
	var f := Foe.make("colossus", hp, 30)
	f.size = 2
	return f


func test_massive_foe_fills_a_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
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
	sk.add_mech(_mech("A", Die.single(Face.attack(200, L))))
	sk.add_foes([_colossus(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "hit the colossus")
	var out := sk.end_round()
	assert_eq(sk.front[0], null, "front slot cleared")
	assert_eq(sk.back[0], null, "back slot cleared")
	assert_eq(out, Skirmish.Outcome.VICTORY, "and that was the whole squad")


func test_pierce_hits_a_massive_foe_once() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.PIERCE))))
	sk.add_foes([_colossus(140)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 110, "took 30, not 60")


func test_shield_face_helps_an_ally() -> void:
	var sk := Skirmish.new(1)
	var giver := _mech("Giver", Die.single(Face.shield(30)), 40, 100)
	var taker := _mech("Taker", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(giver)
	sk.add_mech(taker)
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.mechs[1]), "shield the ally")
	assert_eq(taker.shield, 0, "capped at the ally's shield max of 0")
	taker.shield_max = 50
	sk.mechs[0].assigned = false
	assert_true(sk.assign(0, sk.mechs[1]), "shield again with room")
	assert_eq(taker.shield, 30, "ally gained 30")

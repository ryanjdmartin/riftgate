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
	assert_true(sk.can_withdraw(), "open at the start of round one, before a face is spent")
	sk.assign(0, sk.front[0])
	assert_false(sk.can_withdraw(), "closed once a face is spent")
	assert_false(sk.withdraw(), "withdraw refused mid-round")
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
	assert_true(sk.reroll([1]), "third reroll")
	assert_false(sk.reroll([1]), "fourth refused")


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


func test_forecast_predicts_shield_break_and_hull_loss() -> void:
	var sk := Skirmish.new(1)
	var m := Unit.mech(1, "A", Vector2i.ZERO)
	m.hull = 100
	m.hull_max = 100
	m.shield = 20
	m.shield_max = 20
	m.die = Die.single(Face.attack(10))
	var ms := sk.add_mech(m)
	sk.add_foes([Foe.make("a", 30, 25), Foe.make("b", 30, 30)])
	sk.begin()
	sk.start_round()
	var fc := sk.forecast(ms)
	assert_eq(fc["incoming"], 55, "both foes aim at the only mech")
	assert_true(fc["breaks_shield"], "55 incoming breaks a 20 shield")
	assert_eq(fc["shield_after"], 0, "shield gone")
	assert_eq(fc["hull_after"], 65, "35 gets through")
	assert_true(fc["component_risk"], "a 30-point hit on 100 hull may injure")
	assert_false(fc["destroyed"], "still standing")
	sk.front[0].suppressed = true
	fc = sk.forecast(ms)
	assert_eq(fc["incoming"], 30, "a suppressed foe does not count")
	sk.front[1].hp = 0
	fc = sk.forecast(ms)
	assert_eq(fc["incoming"], 0, "a dead foe does not count")
	assert_false(fc["breaks_shield"], "nothing incoming")


func test_forecast_predicts_wreck_and_overheat() -> void:
	var sk := Skirmish.new(2)
	var m := Unit.mech(1, "A", Vector2i.ZERO)
	m.hull = 20
	m.hull_max = 100
	m.shield = 0
	m.shield_max = 40
	m.heat_max = 30
	m.die = Die.single(Face.attack(10, Face.Reach.LINE, [], 40))
	var ms := sk.add_mech(m)
	sk.add_foes([Foe.make("a", 30, 25)])
	sk.begin()
	sk.start_round()
	var fc := sk.forecast(ms)
	assert_eq(fc["overheat"], 10, "a 40-heat face on a 30 cap overheats by 10")
	assert_eq(fc["heat_after"], 30, "heat capped")
	assert_true(fc["destroyed"], "25 through plus 10 overheat beats 20 hull")
	sk.assign(0, sk.front[0])
	fc = sk.forecast(ms)
	assert_eq(sk.pending_heat(ms), 0, "a spent face adds no more heat")
	assert_eq(fc["overheat"], 0, "no pending overheat once spent")


func test_forecast_ignores_foes_that_burn_to_death_first() -> void:
	var sk := Skirmish.new(3)
	var m := Unit.mech(1, "A", Vector2i.ZERO)
	m.die = Die.single(Face.attack(10))
	var ms := sk.add_mech(m)
	sk.add_foes([Foe.make("a", 10, 25)])
	sk.begin()
	sk.start_round()
	sk.front[0].burn = 1
	assert_eq(sk.forecast(ms)["incoming"], 0, "burn kills it before it strikes")


func test_reroll_always_lands_on_a_different_face() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var die := Die.of([
		Face.attack(20, Face.Reach.LINE, [], 0, 40, 10),
		Face.attack(20, Face.Reach.LINE, [], 0, 40, 10),
		Face.attack(30),
		Face.shield(20),
	])
	for trial in range(60):
		var cur := die.roll(rng)
		var next := die.reroll(rng, cur)
		assert_ne(next, cur, "index changes")
		assert_true(die.faces[next].to_dict() != die.faces[cur].to_dict(), "and the face is not an equivalent one")
	var same := Die.of([Face.attack(10), Face.attack(10)])
	assert_eq(same.reroll(rng, 0), 0, "a die of identical faces keeps its face")
	var one := Die.single(Face.attack(10))
	assert_eq(one.reroll(rng, 0), 0, "a one-faced die keeps its face")


func test_skirmish_reroll_changes_every_unlocked_face() -> void:
	var db := ContentDB.load_default()
	for seed_value in range(1, 25):
		var sk := Skirmish.new(seed_value)
		for id in ["bulwark", "sentinel", "raptor"]:
			sk.add_mech(db.make_mech(id))
		sk.add_foes([Foe.make("ghoul", 30, 10)])
		sk.begin()
		sk.start_round()
		var before: Array = []
		for ms in sk.mechs:
			before.append(ms.face().to_dict())
		sk.reroll([0, 1, 2])
		for i in range(3):
			assert_true(sk.mechs[i].face().to_dict() != before[i], "seed %d mech %d shows a different face" % [seed_value, i])


func test_four_columns_fill_and_reach() -> void:
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("A", Die.single(Face.attack(20, L, K.CLEAVE))))
	var foes: Array = []
	for i in range(10):
		foes.append(_ghoul(50))
	sk.add_foes(foes)
	sk.begin()
	assert_eq(sk.columns, 4, "four wide")
	assert_eq(sk.front.size(), 4, "four front slots")
	assert_eq(sk.field_foes().size(), 8, "eight on the field")
	assert_eq(sk.pool.size(), 2, "two wait in the pool")
	sk.start_round()
	assert_eq(sk.targets_for(0).size(), 4, "every front foe is a line target")
	assert_true(sk.assign(0, sk.front[3]), "cleave the right edge")
	assert_eq(sk.front[3].hp, 30, "edge took 20")
	assert_eq(sk.front[2].hp, 30, "its one neighbour took 20")
	assert_eq(sk.front[1].hp, 50, "the far column is untouched")
	var three := Skirmish.new(1)
	assert_eq(three.columns, Skirmish.DEFAULT_COLUMNS, "three by default")

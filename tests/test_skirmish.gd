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
	assert_eq(sk.field_foes().size(), 4, "four on the field: ranks hold, so the fourth ghoul waits")
	assert_eq(sk.front[0].display_name, "ghoul", "front 0 is a ghoul")
	assert_eq(sk.front[2].display_name, "ghoul", "front 2 is a ghoul")
	var archer_col := -1
	for col in range(3):
		if sk.back[col] != null and sk.back[col].display_name == "archer":
			archer_col = col
	assert_true(archer_col >= 0, "the archer holds a back slot")
	for col in range(3):
		if col != archer_col:
			assert_eq(sk.back[col], null, "no ghoul in the back row")
	assert_eq(sk.reinforcements.size(), 1, "the spare ghoul waits in reinforcements")


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
	assert_eq(m.shield, 30, "splash cost ten shield")
	assert_eq(sk.front[0].hp, 30, "ghoul took 20")


func test_penetrate_hits_the_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.PENETRATE))))
	sk.add_foes([_ghoul(50), _archer(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "penetrate front 0")
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
	assert_eq(weak.hull, 100, "and no hull: a standing shield blocks the blow whole")


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
	assert_eq(g.burn_stacks(), 2, "two burn stacks from 30 damage")
	sk.end_round()
	assert_eq(g.hp, 50, "burn ticked for 10: two stacks of five")
	assert_eq(g.burn_stacks(), 1, "one stack consumed")


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


func test_victory_when_reinforcements_exhausted() -> void:
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
	# Ranks hold: front foes fill the three front slots and the rest wait as reinforcements.
	assert_eq(sk.field_foes().size(), 3, "three on the field")
	assert_eq(sk.reinforcements.size(), 5, "five in reserve")
	sk.start_round()
	sk.assign(0, sk.front[1])
	sk.end_round()
	assert_eq(sk.field_foes().size(), 3, "the gap is refilled at the reinforcement phase")
	assert_eq(sk.reinforcements.size(), 4, "four left in reserve")
	assert_true(sk.front[1] != null, "a reinforcement stepped into the gap")


func test_withdraw_window() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 10)])
	sk.begin()
	assert_true(sk.can_withdraw(), "open even before the first roll: the price is the same either way")
	sk.start_round()
	assert_true(sk.can_withdraw(), "open at the start of round one")
	sk.assign(0, sk.front[0])
	assert_true(sk.can_withdraw(), "still open after spending: the price is the enemy turn, not the timing")
	sk.end_round()
	assert_true(sk.can_withdraw(), "between rounds")
	sk.start_round()
	assert_true(sk.withdraw(), "withdrew in round two")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "outcome withdrawn")
	assert_eq(m.hull, 80, "and the enemy struck on the way out, both rounds: no leapfrogging out unscathed")

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


func test_big_hull_hits_always_injure_a_face() -> void:
	for seed_value in range(1, 31):
		var sk := Skirmish.new(seed_value)
		var d := Die.of([Face.attack(10, L, K.CLEAVE), Face.attack(10, L, K.PENETRATE)])
		var m := _mech("A", d, 0, 100)
		sk.add_mech(m)
		sk.add_foes([Foe.make("brute", 90, 50)])
		sk.begin()
		sk.start_round()
		sk.end_round()
		assert_eq(m.hull, 50, "the hit reached the hull")
		assert_eq(_cracked_count(d), 1, "a half-hull hit cracks one face, no coin toss (seed %d)" % seed_value)


func test_injury_rolls_the_die_and_a_destroyed_component_takes_the_blow() -> void:
	var sk := Skirmish.new(5)
	var d := Die.of([Face.blank(), Face.blank(), Face.attack(10, L, K.CLEAVE)])
	var m := _mech("A", d, 0, 100)
	sk.add_mech(m)
	sk.add_foes([Foe.make("ghoul", 90, 10)])
	sk.begin()
	sk.start_round()
	var misses := 0
	var hits := 0
	for i in range(60):
		var before := sk.log.size()
		sk.apply_injury(sk.mechs[0])
		if str(sk.log[sk.log.size() - 1]).contains("nothing left to break"):
			misses += 1
		else:
			hits += 1
		assert_eq(sk.log.size(), before + 1, "every injury logs one line")
	assert_true(misses > hits, "two destroyed faces of three absorb most blows (%d misses, %d hits)" % [misses, hits])
	assert_eq(d.faces[2].kind, Face.Kind.BLANK, "the live face was cracked then destroyed by the hits")
	assert_eq(m.damaged_component_count(), 1, "blows on already destroyed faces add no damaged components")


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
	assert_eq(f.crit, 15, "crit kept (18 September: a crack takes only the keywords)")
	assert_true(f.describe().ends_with("(cracked)"), "described as cracked")
	assert_eq(m.damaged_component_count(), 1, "one damaged component on the unit")
	sk.apply_injury(sk.mechs[0])
	assert_eq(d.faces[0].kind, Face.Kind.BLANK, "second injury destroys it")
	assert_eq(m.damaged_component_count(), 1, "still one component, now destroyed")
	sk.apply_injury(sk.mechs[0])
	assert_eq(m.damaged_component_count(), 1, "a third injury finds nothing left to break")
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
	assert_false(d.faces[0].cracked, "not cracked any more")
	assert_eq(m.damaged_component_count(), 0, "nothing left to repair")


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


func test_penetrate_hits_a_massive_foe_once() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.PENETRATE))))
	sk.add_foes([_colossus(140)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 110, "took 30, not 60")


func test_shield_component_helps_an_ally() -> void:
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
	assert_eq(fc["hull_after"], 75, "the thirty stands left, strikes first and is blocked whole; the twenty-five lands on bare hull")
	assert_true(fc["component_risk"], "a 25-point bare-hull hit on 100 hull injures")
	assert_false(fc["destroyed"], "still standing")
	sk._suppress(sk.front[0])
	fc = sk.forecast(ms)
	assert_eq(fc["incoming"], 25, "a suppressed foe does not count")
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
	Effects.stack(sk.front[0], Effects.STATUS["burning"], Effects.SKIRMISH, "test", 2)
	assert_eq(sk.forecast(ms)["incoming"], 0, "two stacks of five kill a ten-hp foe before it strikes")


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
		for id in ["badger", "clydesdale", "sparrowhawk"]:
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
	# Ranks hold: six front ghouls fill four front slots and two wait; four archers take the back.
	var foes: Array = []
	for i in range(6):
		foes.append(_ghoul(50))
	for i in range(4):
		foes.append(_archer(50))
	sk.add_foes(foes)
	sk.begin()
	assert_eq(sk.columns, 4, "four wide")
	assert_eq(sk.front.size(), 4, "four front slots")
	assert_eq(sk.field_foes().size(), 8, "eight on the field")
	assert_eq(sk.reinforcements.size(), 2, "two wait in reserve")
	sk.start_round()
	assert_eq(sk.targets_for(0).size(), 4, "every front foe is a line target")
	assert_true(sk.assign(0, sk.front[3]), "cleave the right edge")
	assert_eq(sk.front[3].hp, 30, "edge took 20")
	assert_eq(sk.front[2].hp, 30, "its one neighbour took 20")
	assert_eq(sk.front[1].hp, 50, "the far column is untouched")
	var three := Skirmish.new(1)
	assert_eq(three.columns, Skirmish.DEFAULT_COLUMNS, "three by default")


func test_no_destroy_passive_holds_a_cracked_component() -> void:
	var sk := Skirmish.new(3)
	var d := Die.single(Face.attack(30, L, [K.CLEAVE], 0, 50, 15))
	var m := _mech("A", d, 0, 100)
	m.grant_passive({"id": "hold", "name": "Hold", "description": "", "effects": [{"trigger": "on_injury", "effect": "no_destroy", "value": 1}]})
	sk.add_mech(m)
	sk.add_foes([Foe.make("ghoul", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.apply_injury(sk.mechs[0])
	assert_true(d.faces[0].cracked, "the first injury still cracks")
	sk.apply_injury(sk.mechs[0])
	assert_eq(d.faces[0].kind, Face.Kind.ATTACK, "the second does not destroy it")
	assert_true(d.faces[0].cracked, "it stays cracked")
	assert_true(str(sk.log[sk.log.size() - 1]).contains("holds"), "and the log says it held")
	assert_eq(m.damaged_component_count(), 1, "one damaged component")


func test_injury_on_an_empty_hardpoint_breaks_nothing() -> void:
	var sk := Skirmish.new(3)
	var d := Die.single(Face.empty_slot())
	var m := _mech("A", d, 0, 100)
	sk.add_mech(m)
	sk.add_foes([Foe.make("ghoul", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.apply_injury(sk.mechs[0])
	assert_true(str(sk.log[sk.log.size() - 1]).contains("empty hardpoint"), "the log names the empty hardpoint")
	assert_eq(m.damaged_component_count(), 0, "nothing was there to damage")
	assert_eq(d.faces[0].describe(), "empty hardpoint", "described as empty, not destroyed")


func test_cracked_condition_narrows_a_passive_to_cracked_components() -> void:
	var bonus := {"id": "scars", "name": "Scars", "description": "", "effects": [{"trigger": "on_attack", "when": "component_cracked", "effect": "add_damage", "value": 10}]}
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive(bonus)
	var f := Face.attack(20, L)
	assert_eq(Effects.attack(u, f, 20, 0, false)["damage"], 20, "an intact component gets nothing")
	f.crack()
	assert_eq(Effects.attack(u, f, 20, 0, false)["damage"], 30, "a cracked one hits harder")
	assert_eq(Effects.attack(u, null, 20, 0, false)["damage"], 20, "no component in hand, no bonus")


func test_shield_never_comes_back_on_its_own_in_a_fight() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 100)
	m.shield_max = 40
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 0)])
	sk.begin()
	sk.start_round()
	sk.end_round()
	sk.start_round()
	assert_eq(m.shield, 0, "no trickle between rounds")
	m.shield = 38
	assert_eq(m.recharge_shield(100), 2, "the field rate is capped at max")
	assert_eq(m.shield, 40, "at max")


func test_a_standing_shield_blocks_the_whole_blow() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 50)])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 0, "ten shield is spent")
	assert_eq(m.hull, 100, "fifty blocked by a ten-point shield: nothing bleeds")
	assert_true(sk.turn_events[0]["blocked"] and sk.turn_events[0]["broke_shield"], "the blow is recorded as blocked and shield-breaking")
	assert_eq(m.damaged_component_count(), 0, "and a shielded blow never injures")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 50, "bare hull takes the next one")
	assert_eq(m.damaged_component_count(), 1, "and it injures")


func test_armour_takes_a_flat_amount_off_bare_hull_blows() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 200)
	m.armour = 10
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 10), _ghoul(90, 10), _ghoul(90, 30)])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 180, "two ghouls bounce off, the thirty does twenty")
	assert_true(str(sk.log).contains("armour holds"), "the log says the armour held")
	m.shield = 10
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 0, "the thirty stands left and strikes first: the ten-point shield takes it whole")
	assert_eq(m.hull, 180, "then both ghouls bounce off the armour")


func test_double_strike_breaks_the_shield_and_reaches_the_hull() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(m)
	var brute := Foe.make("brute", 200, 30)
	brute.actions[0]["strikes"] = 2
	sk.add_foes([brute])
	sk.begin()
	sk.start_round()
	var fc := sk.forecast(sk.mechs[0])
	assert_eq(fc["incoming"], 60, "forecast counts both blows")
	assert_eq(fc["hull_after"], 70, "and knows the second lands on bare hull")
	assert_true(fc["component_risk"], "and that it can injure")
	sk.end_round()
	assert_eq(m.shield, 0, "first blow spends the shield")
	assert_eq(m.hull, 70, "second blow reaches the hull")


func test_breach_overflows_shield_into_hull_and_can_injure() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(m)
	var boss := Foe.make("maw", 200, 50)
	boss.actions[0]["keywords"] = ["breach"]
	sk.add_foes([boss])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 0, "shield gone")
	assert_eq(m.hull, 60, "forty overflowed")
	assert_eq(m.damaged_component_count(), 1, "forty of a hundred hull in one blow injures: a breach gets past the shield rule")
	assert_true(sk.turn_events.size() == 1 and sk.turn_events[0]["broke_shield"] and sk.turn_events[0]["injured"], "the turn event says the shield broke and a component was hit")


func test_heaviest_hitters_deploy_left_and_strike_first() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 10), _ghoul(90, 10), Foe.make("brute", 90, 50)])
	sk.begin()
	assert_eq(sk.front[0].display_name, "brute", "the brute stands left")
	assert_eq(sk.front[1].display_name, "ghoul", "ghouls follow in arrival order")
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 0, "the brute strikes first and the shield takes it")
	assert_eq(m.hull, 80, "the two ghouls then hit bare hull")


func test_strikes_are_separate_blows_with_their_own_rolls_and_procs() -> void:
	var sk := Skirmish.new(2)
	var gun := Face.attack(10, L, K.BURN, 20)
	gun.strikes = 3
	sk.add_mech(_mech("A", Die.single(gun)))
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 170, "three blows of ten")
	assert_eq(sk.front[0].burn_stacks(), 3, "each blow procs burn on its own: three stacks, where one thirty would give two")
	assert_eq(sk.mechs[0].heat, 20, "heat is paid once per use, not per strike")
	assert_eq(sk.last_roll["final"], 30, "the screen sees the total")
	assert_eq(gun.describe(), "10 ×3 burn (+20 heat)", "described as a burst")
	assert_eq(Face.from_dict(gun.to_dict()).strikes, 3, "strikes survive content round-trip")


func test_crit_bonuses_add_to_one_multiplier() -> void:
	var sk := Skirmish.new(1)
	var gun := Face.attack(30, L, [], 0, 0, 100)
	gun.crit_bonus = 0.5
	var m := _mech("A", Die.single(gun))
	m.grant_passive({"id": "eye", "name": "Eye", "description": "", "effects": [{"trigger": "on_crit", "effect": "add_crit_damage", "value": 0.5}]})
	sk.add_mech(m)
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 110, "30 at base 2 plus 0.5 plus 0.5 is 90: additive, not 2 x 1.5 x 1.5")
	assert_eq(gun.describe(), "30 crit 100% (×2.5)", "the readout shows the component's own resulting multiplier")
	assert_eq(Face.from_dict(gun.to_dict()).crit_bonus, 0.5, "crit_bonus survives content round-trip")


func test_melee_reaches_the_back_only_when_the_whole_front_is_empty() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, Face.Reach.MELEE))))
	sk.add_foes([_ghoul(30), _archer(50), _archer(50)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.targets_for(0).size(), 1, "one ghoul in front: melee sees only it, though column 1 is exposed")
	sk.assign(0, sk.front[0])
	sk.end_round()
	sk.start_round()
	assert_eq(sk.targets_for(0).size(), 2, "front rank empty: melee reaches the back rank")


func test_static_set_reach_sends_a_cracked_component_to_melee() -> void:
	var sk := Skirmish.new(3)
	var mortar := Face.attack(30, I, [], 0, 0, 15)
	var m := _mech("A", Die.single(mortar), 0, 100)
	m.grant_passive({"id": "rs", "name": "RS", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.1, "when": "reach_melee"},
		{"trigger": "static", "effect": "set_reach", "value": "melee", "when": "component_cracked"}]})
	sk.add_mech(m)
	sk.add_foes([_ghoul(200), _archer(200)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.targets_for(0).size(), 2, "an intact mortar reaches both ranks")
	sk.apply_injury(sk.mechs[0])
	var f := sk.mechs[0].face()
	assert_true(f.cracked and f.reach == Face.Reach.INDIRECT, "cracked; the component itself is untouched")
	assert_eq(sk.reach_of(sk.mechs[0], f), Face.Reach.MELEE, "but read through the passive it is melee")
	assert_eq(sk.shown_face(sk.mechs[0], f).reach, Face.Reach.MELEE, "and the screen shows it as melee")
	assert_eq(f.crit, 15, "and keeps its crit")
	assert_eq(sk.targets_for(0).size(), 1, "so it reaches only the front")
	sk.assign(0, sk.front[0])
	assert_true(sk.front[0].hp == 167 or sk.front[0].hp == 134, "30 at 1.1 is 33 (or 66 on a crit): the melee bonus follows the effective reach")
	var saved: Array = m.modifiers
	m.modifiers = []
	assert_eq(sk.reach_of(sk.mechs[0], f), Face.Reach.INDIRECT, "take the passive away (suppressed, or an ally reading it) and the reach is its own again")
	m.modifiers = saved
	Effects.grant(m, Effects.make({"id": "jam", "name": "Jam", "description": "", "effects": [{"trigger": "static", "effect": "suppress", "value": "rs"}]}, Effects.SKIRMISH, "foe:whisperer"))
	assert_eq(sk.reach_of(sk.mechs[0], f), Face.Reach.INDIRECT, "a skirmish-long suppression of the passive turns the transformation off too")
	Effects.end_skirmish(m)
	assert_eq(sk.reach_of(sk.mechs[0], f), Face.Reach.MELEE, "and when the skirmish ends the suppression is gone and the passive answers again")
	m.repair_faces()
	assert_eq(m.die.faces[0].reach, Face.Reach.INDIRECT, "repair restores the original mortar")


func test_execute_gives_bosses_half_the_bonus() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(20, L, K.EXECUTE))))
	var boss := Foe.make("maw", 200, 10)
	boss.size = 2
	boss.hp = 90
	sk.add_foes([boss])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(boss.hp, 60, "20 at +50% against a wounded boss, not +100%")


func test_chain_repeats_on_a_kill() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.CHAIN, 10))))
	sk.add_foes([_ghoul(30), _ghoul(30), _ghoul(90)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_false(sk.front[0].alive(), "the first ghoul dies")
	assert_false(sk.front[1].alive(), "the chain kills the second")
	assert_eq(sk.front[2].hp, 60, "and lands once on the third, which survives, so it stops")
	assert_eq(sk.mechs[0].heat, 30, "heat is paid on every link, three here: that is the risk of a chain")


func test_stats_are_base_plus_every_live_source_in_order() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.hull_max = 200
	u.armour = 10
	assert_eq(u.hull_max, 200, "a written maximum is the base")
	u.grant_passive({"id": "plates", "name": "Plates", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 10},
		{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 20}]}, "heavy_plates", "heavy_plates")
	Effects.grant(u, Effects.make({"id": "overdrive", "name": "Overdrive", "description": "", "effects": [
		{"trigger": "static", "effect": "multiply_stat", "stat": "hull", "value": 1.5}]}, Effects.BATTLE, "reward"))
	assert_eq(u.hull_max, 330, "(200 + 20) x 1.5: adds before multiplies, whatever order they were granted")
	assert_eq(u.armour, 20, "armour from the base and the component")
	Effects.end_battle(u)
	assert_eq(u.hull_max, 220, "the reward ends with the battle; the component stays")
	Effects.grant(u, Effects.make({"id": "rust", "name": "Rust", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": -50}]}, Effects.SKIRMISH, "foe:corroder"))
	assert_eq(u.armour, 0, "a stat never goes below zero")
	Effects.end_skirmish(u)
	assert_eq(u.armour, 20, "and comes back when the debuff ends")


func test_a_timed_damage_taken_debuff_runs_out_after_its_round() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 200)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 20)])
	sk.begin()
	sk.start_round()
	Effects.grant_for_rounds(m, {"id": "weakened", "name": "Weakened", "description": "", "effects": [
		{"trigger": "static", "effect": "multiply_damage_taken", "value": 1.5}]}, "foe:hexer", sk.round)
	assert_eq(sk.forecast(sk.mechs[0])["hull_after"], 170, "the forecast reads the debuff: 20 becomes 30")
	sk.end_round()
	assert_eq(m.hull, 170, "and so does the blow")
	assert_true(m.modifiers.is_empty(), "the debuff ran out at the end of its round")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 150, "the next blow is a plain 20")


func test_a_destroyed_component_keeps_its_bonus_and_loses_its_ability() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	var gun := Face.attack(30, L)
	gun.component = "big_gun"
	u.die = Die.single(gun)
	u.armour = 0
	u.grant_passive({"id": "bg", "name": "Big Gun", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 10},
		{"trigger": "on_attack", "effect": "add_damage", "value": 10}]}, "big_gun", "big_gun")
	assert_eq(u.armour, 10, "fitted: the bonus")
	assert_eq(Effects.attack(u, gun, 30, 0, false)["damage"], 40, "fitted: the ability")
	var wreck := Face.blank()
	wreck.component = "big_gun"
	u.die.faces[0] = wreck
	assert_eq(u.armour, 10, "destroyed: the bonus stays")
	assert_eq(Effects.attack(u, gun, 30, 0, false)["damage"], 30, "destroyed: the ability is gone")


func test_shorter_lived_sources_override_longer_ones() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	var f := Face.attack(20, L)
	u.grant_passive({"id": "a", "name": "A", "description": "", "effects": [{"trigger": "static", "effect": "set_reach", "value": "melee"}]})
	assert_eq(Effects.effective_reach(u, f), Face.Reach.MELEE, "the loadout rule holds")
	Effects.grant(u, Effects.make({"id": "b", "name": "B", "description": "", "effects": [{"trigger": "static", "effect": "set_reach", "value": "indirect"}]}, Effects.SKIRMISH, "buff"))
	assert_eq(Effects.effective_reach(u, f), Face.Reach.INDIRECT, "a skirmish-long rule wins over the loadout one")
	Effects.end_skirmish(u)
	assert_eq(Effects.effective_reach(u, f), Face.Reach.MELEE, "and the loadout rule is back when it ends")


func test_statuses_stack_tick_and_decay_on_both_sides() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 200)
	sk.add_mech(m)
	var scorcher := Foe.make("hellhound", 90, 10)
	scorcher.actions[0]["keywords"] = ["scorch"]
	sk.add_foes([scorcher])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overheating"), 1, "a scorching blow leaves one heat stack")
	sk.start_round()
	assert_eq(sk.mechs[0].heat, 5, "it ticks at the mech's turn: five heat")
	assert_eq(Effects.stacks_of(m, "overheating"), 0, "and the stack is spent")
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].heat, 10, "the next scorch ticks again")
	Effects.stack(m, Effects.STATUS["overheating"], Effects.SKIRMISH, "test", 3)
	assert_eq(Effects.stacks_of(m, "overheating"), 3, "stacks add up")
	assert_eq(int(Effects.tick_preview(m)["heat"]), 15, "five per stack")
	sk.withdraw()
	assert_eq(Effects.stacks_of(m, "overheating"), 0, "skirmish-scoped statuses end with the skirmish")


func test_suppress_skips_the_action_and_numbs() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	sk.add_mech(m)
	var boss := Foe.make("maw", 200, 30)
	boss.size = 2
	sk.add_foes([boss])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_true(boss.is_suppressed(), "suppressed this round")
	assert_eq(Effects.stacks_of(boss, "numbed"), 2, "a massive foe gains two Numbed stacks")
	sk.end_round()
	assert_eq(m.hull, 100, "it skipped")
	assert_false(boss.is_suppressed(), "the suppression ran out with the round")
	assert_eq(Effects.stacks_of(boss, "numbed"), 2, "Numbed does not decay")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 70, "next round it strikes")


func test_stacked_adds_scale_with_stacks() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.armour = 0
	var plating := {"id": "energy_armour", "name": "Energy Armour", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 5}]}
	Effects.stack(u, plating, Effects.SKIRMISH, "component", 1, Effects.DECAY_NONE)
	Effects.stack(u, plating, Effects.SKIRMISH, "component", 2, Effects.DECAY_NONE)
	assert_eq(u.modifiers.size(), 1, "the same status stacks instead of doubling")
	assert_eq(u.armour, 15, "five per stack, three stacks")


func test_rapid_rolls_again_for_free_and_switches_itself_off_for_the_round() -> void:
	var sk := Skirmish.new(2)
	var gun := Face.attack(10, L, K.RAPID)
	var d := Die.of([gun, Face.attack(30, L)])
	var m := _mech("A", d)
	sk.add_mech(m)
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "fire the rapid gun")
	assert_eq(sk.front[0].hp, 190, "ten landed")
	assert_false(sk.mechs[0].assigned, "the mech may act again")
	assert_eq(sk.rerolls_left, 3, "the reroll was free")
	assert_eq(sk.mechs[0].face_index, 1, "the die rolled to the other entry, never the same one")
	assert_true(sk.mechs[0].die.faces[0].has(K.RAPID), "the component itself is untouched")
	sk.mechs[0].face_index = 0
	assert_eq(sk.mechs[0].face().describe(), "disabled", "but shown, the rapid entry is switched off for the round")
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, sk.front[0]), "and the second spend goes through")
	assert_eq(sk.front[0].hp, 160, "thirty more")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_false(sk.mechs[0].face().disabled, "back next round")


func test_a_foe_disable_switches_off_the_showing_entry_through_the_next_turn() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L)), 0, 200)
	sk.add_mech(m)
	var jammer := Foe.make("whisperer", 90, 10)
	jammer.actions[0]["keywords"] = ["disable"]
	sk.add_foes([jammer])
	sk.begin()
	sk.start_round()
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].face().describe(), "disabled", "the entry comes up blank on the mech's next turn")
	assert_true(sk.targets_for(0).is_empty(), "no targets from a blank")
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 90, "spending a blank does nothing")
	sk._suppress(sk.front[0])   # or it would disable again
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].face().describe(), "30", "and it is back the turn after")


func test_the_die_screen_explains_what_applies_to_a_component() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	var mortar := Face.attack(30, I)
	u.grant_passive({"id": "rs", "name": "Reinforced Skeleton", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.1, "when": "reach_melee"},
		{"trigger": "static", "effect": "set_reach", "value": "melee", "when": "component_cracked"}]})
	assert_true(Effects.explain(u, mortar).is_empty(), "nothing applies to an intact mortar")
	mortar.crack()
	var notes := Effects.explain(u, mortar)
	assert_eq(notes.size(), 2, "cracked: the reach change and the melee bonus both apply")
	assert_true(notes[0].contains("reach becomes melee (Reinforced Skeleton)") or notes[1].contains("reach becomes melee (Reinforced Skeleton)"), "the reach change names its source")
	assert_eq(Effects.effect_text({"trigger": "on_injury", "effect": "no_destroy", "value": 1}), "on an injury: cracked components are never destroyed", "effects read as sentences")

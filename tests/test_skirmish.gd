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
	var sk := Skirmish.new(1, 3)   # three wide: the rank rules, not the default width
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
	assert_eq(sk.mechs[0].heat, 80, "the gauge runs past its cap during the round")
	assert_eq(m.hull, 100, "nothing burns yet")
	sk.end_round()
	assert_eq(sk.mechs[0].heat, 60, "at the end of the round the gauge settles at its cap")
	assert_eq(m.hull, 80, "and the twenty over it burnt the hull (the ghoul's blow was blocked by the shield)")


func test_equipment_targets_are_the_components_to_set() -> void:
	var sk := Skirmish.new(1)
	var own := Face.shield(10)
	own.targets = Face.Target.SELF
	var give := Face.vent(10)
	give.targets = Face.Target.ALLY
	var a := _mech("A", Die.single(own), 40, 100)
	var b := _mech("B", Die.single(give), 40, 100)
	a.shield = 0
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(own.describe(), "shield 10 (self only)", "the restriction reads on the entry")
	assert_eq(sk.equipment_targets_for(sk.mechs[0], own).size(), 1, "a self-only shield offers one target")
	assert_false(sk.assign(0, sk.mechs[1]), "and refuses an ally")
	assert_true(sk.assign(0, null), "self is fine")
	assert_eq(a.shield, 10, "shielded")
	assert_false(sk.assign(1, null), "an allies-only vent refuses self")
	assert_true(sk.assign(1, sk.mechs[0]), "and takes the ally")
	var default_face := Face.shield(10)
	assert_eq(sk.equipment_targets_for(sk.mechs[0], default_face).size(), 2, "the default reaches everyone alive")
	assert_true(Face.attack(10, L).is_weapon() and not Face.attack(10, L).is_equipment(), "an attack is a weapon")
	var d := Face.from_dict({"kind": "shield", "power": 20, "targets": "ally"})
	assert_eq(d.targets, Face.Target.ALLY, "targets read from content")
	assert_eq(d.to_dict().get("targets", ""), "ally", "and written back")


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
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "victory the moment the last foe falls")
	assert_eq(sk.state, Skirmish.State.DONE, "skirmish done, no End turn needed")


func test_defeat_when_all_hulls_zero() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 20))
	sk.add_foes([_ghoul(90, 50)])
	sk.begin()
	sk.start_round()
	var out := sk.end_round()
	assert_eq(out, Skirmish.Outcome.DEFEAT, "defeat")


func test_horde_keeps_coming() -> void:
	var sk := Skirmish.new(1, 3)   # three wide: the rank rules, not the default width
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
	assert_eq(sk.front[0], null, "front slot cleared at once")
	assert_eq(sk.back[0], null, "back slot cleared at once")
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "and that was the whole pack")


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
	assert_eq(ms.heat, 40, "the heat is on the gauge, past the cap")
	assert_eq(m.hull, 20, "nothing burnt yet")
	assert_eq(fc["overheat"], 10, "the burn is still coming at the end of the round")
	assert_eq(sk.forecast(ms, false)["overheat"], 10, "with or without the die counted: it is spent")


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
	assert_eq(sk.front[0], null, "the first ghoul dies and its slot clears")
	assert_eq(sk.front[1], null, "the chain kills the second")
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
	assert_eq(sk.mechs[0].heat, 5, "a scorching blow leaves one heat stack, and it ticks at the round's end: five heat")
	assert_eq(Effects.stacks_of(m, "overheating"), 0, "and the stack is spent")
	sk.start_round()
	sk.end_round()
	assert_eq(sk.mechs[0].heat, 10, "the next scorch ticks again")
	sk.start_round()
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
	assert_eq(Effects.stacks_of(boss, "numbed"), 3, "a massive foe gains three Numbed stacks")
	assert_eq(boss.resist_total(), 30, "which is 30% to shrug the next one off")
	sk.end_round()
	assert_eq(m.hull, 100, "it skipped")
	assert_false(boss.is_suppressed(), "the suppression ran out with the round")
	assert_eq(Effects.stacks_of(boss, "numbed"), 2, "Numbed lost a stack at the foe's turn, suppressed or not")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 70, "next round it strikes")
	assert_eq(Effects.stacks_of(boss, "numbed"), 1, "and loses another")
	sk.start_round()
	sk.end_round()
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(boss, "numbed"), 0, "gone two turns later")


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


func test_a_kill_clears_the_slot_at_once_and_opens_the_back_rank() -> void:
	# Ryan, 22 September: burning a hole through the front is a legitimate choice, since it
	# opens the back rank to line and melee until reinforcements plug it at the round's end.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.of([Face.attack(90, L), Face.attack(90, L)]), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(30, 25), _archer(30, 10), _ghoul(30, 25)])
	sk.begin()
	sk.start_round()
	var ghoul: Foe = sk.front[0]
	var archer: Foe = sk.back[0]
	assert_true(archer != null, "the archer stands behind the first ghoul")
	assert_false(sk.targets_for(0).has(archer), "covered: the line weapon cannot reach it")
	assert_true(sk.assign(0, ghoul), "the blow kills the ghoul")
	assert_eq(sk.front[0], null, "its slot is empty at once")
	assert_true(sk.log[sk.log.size() - 1].ends_with("destroyed"), "logged as destroyed now, not at the round's end")
	assert_true(sk.is_exposed(0), "the column is exposed")
	assert_eq(sk.forecast(sk.mechs[0])["incoming"], 35, "only the archer and the other ghoul count")
	sk.mechs[0].assigned = false
	assert_true(sk.targets_for(0).has(archer), "the line weapon now reaches the archer")
	assert_true(sk.assign(0, archer), "and the second die takes it")
	sk.end_round()
	assert_eq(m.hull, 75, "only the surviving ghoul struck")
	assert_true(sk.front[0] != null or sk.reinforcements.is_empty(), "the hole is plugged at the round's end when anyone waits")


func test_cooling_at_the_start_of_the_turn_and_overheating_at_the_end_of_the_round() -> void:
	# Ryan, 22 September: cool at the start, heat at the end, so a scorch lands on the
	# round's peak heat before cooling relieves it.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, [], 30)), 40, 100)
	m.heat_max = 60
	m.cooling = 10
	var ms := sk.add_mech(m)
	sk.add_foes([_ghoul(30, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(ms.heat, 0, "nothing to cool at the start")
	assert_eq(sk.forecast(ms)["heat_after"], 30, "the face's heat, nothing cooling it this round")
	sk.assign(0, sk.front[0])
	assert_eq(ms.heat, 30, "the face's heat lands when spent")
	sk.end_round()
	assert_eq(ms.heat, 30, "nothing cools at the end of the round")
	sk.start_round()
	assert_eq(ms.heat, 20, "cooled by 10 as the turn begins")
	assert_true(sk.log[sk.log.size() - 1].begins_with("cooling: A -10"), "one log line: %s" % sk.log[sk.log.size() - 1])
	# Overflow burns at the end of the round, never when the face is spent (Ryan, 22
	# September), so a hot machine can still be vented before it pays.
	ms.heat = 50
	assert_eq(sk.forecast(ms, false)["overheat"], 0, "the die's heat is not counted unless asked")
	assert_eq(sk.forecast(ms, true)["overheat"], 20, "asked (the die is dragged): 50 plus 30 on a 60 cap")
	sk.assign(0, sk.front[0])
	assert_eq(ms.heat, 80, "80 on the gauge, past the cap")
	assert_eq(m.hull, 100, "nothing burnt yet")
	assert_eq(sk.forecast(ms)["overheat"], 20, "the forecast warns of the twenty to come")
	# Overheating ticks at the end of the round, on that peak, before the next cooling.
	Effects.stack(m, Effects.STATUS["overheating"], Effects.SKIRMISH, "test", 2)
	assert_eq(sk.forecast(ms)["heat_after"], 60, "the forecast caps the gauge")
	assert_eq(sk.forecast(ms)["overheat"], 30, "twenty over plus the tick's ten")
	sk.end_round()
	assert_eq(m.hull, 70, "all of it burns at once at the end of the round")
	assert_eq(ms.heat, 60, "and the gauge settles at its cap")
	assert_eq(Effects.stacks_of(m, "overheating"), 1, "one stack ticked away")
	sk.start_round()
	assert_eq(ms.heat, 50, "then cooled by 10")
	# Cooling is a stat like any other: a passive can raise it, and it never goes below zero.
	m.grant_passive({"id": "fins", "name": "Fins", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 15}]}, "fins")
	assert_eq(m.cooling, 25, "base plus the passive")
	ms.heat = 5
	sk.end_round()   # the last stack ticks: five more
	assert_eq(ms.heat, 10, "the remaining stack ticked at the round's end")
	sk.start_round()
	assert_eq(ms.heat, 0, "never below zero")
	assert_true(sk.log[sk.log.size() - 1].begins_with("cooling: A -10"), "logged as what was actually shed: %s" % sk.log[sk.log.size() - 1])


func test_forecast_counts_the_scorch_about_to_land() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 100)
	m.heat_max = 60
	var ms := sk.add_mech(m)
	var demon := _ghoul(30, 10)
	demon.actions[0]["keywords"] = ["scorch"]
	demon.actions[0]["strikes"] = 2
	demon.action = demon.actions[0]
	sk.add_foes([demon])
	sk.begin()
	sk.start_round()
	ms.heat = 55
	var fc := sk.forecast(ms)
	assert_eq(fc["heat_after"], 60, "two scorching blows: two stacks tick ten at the round's end, capped")
	assert_eq(fc["overheat"], 5, "five of it burns hull")
	sk.end_round()
	assert_eq(ms.heat, 60, "as forecast")
	assert_eq(m.hull, 100 - 20 - 5, "two blows of ten on bare hull, then five burnt")


func test_no_cooling_means_no_line_and_no_change() -> void:
	var sk := Skirmish.new(1)
	var ms := sk.add_mech(_mech("A", Die.single(Face.attack(10, L, [], 30)), 40, 100))
	sk.add_foes([_ghoul(30, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var lines := sk.log.size()
	sk.end_round()
	assert_eq(ms.heat, 30, "a chassis with no cooling keeps its heat")
	for j in range(lines, sk.log.size()):
		assert_false(sk.log[j].begins_with("cooling"), "no cooling line")


func test_venting_before_the_end_of_the_round_prevents_the_burn() -> void:
	var sk := Skirmish.new(1)
	var hot := _mech("Hot", Die.single(Face.attack(10, L, [], 50)), 40, 100)
	hot.heat_max = 60
	var ms := sk.add_mech(hot)
	var cool := _mech("Cool", Die.single(Face.vent(30)), 40, 100)
	sk.add_mech(cool)
	sk.add_foes([_ghoul(90, 10)])
	sk.begin()
	sk.start_round()
	ms.heat = 30
	sk.assign(0, sk.front[0])
	assert_eq(ms.heat, 80, "twenty over the cap")
	assert_eq(sk.forecast(ms)["overheat"], 20, "warned")
	assert_true(sk.assign(1, ms), "the ally vents it")
	assert_eq(ms.heat, 50, "back under the cap")
	assert_eq(sk.forecast(ms)["overheat"], 0, "nothing to burn")
	sk.end_round()
	assert_eq(hot.hull, 100, "no burn: the vent came in time")


func test_a_numbed_foe_shrugs_off_a_suppress_at_its_odds() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	sk.add_mech(m)
	var g := _ghoul(500, 30)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.stack(g, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 10, Effects.DECAY_NONE)
	sk.assign(0, sk.front[0])
	assert_false(g.is_suppressed(), "at ten stacks nothing lands")
	assert_eq(Effects.stacks_of(g, "numbed"), 10, "a shrugged-off suppress numbs no further")
	assert_true("\n".join(sk.log).contains("shrugs off"), "the log says so")
	sk.end_round()
	assert_eq(m.hull, 70, "it struck")
	# Three stacks: about seven in ten land, on the skirmish's own die.
	var landed := 0
	for seed_value in range(200):
		var s := Skirmish.new(seed_value)
		s.add_mech(_mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100))
		var f := _ghoul(500, 30)
		s.add_foes([f])
		s.begin()
		s.start_round()
		Effects.stack(f, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_NONE)
		s.assign(0, s.front[0])
		if f.is_suppressed():
			landed += 1
			assert_eq(Effects.stacks_of(f, "numbed"), 5, "a suppress that lands numbs two more")
	assert_true(landed > 110 and landed < 170, "about 140 of 200 land at 30%% resistance, got %d" % landed)
	# A foe's own resistance counts before any Numbed, and a full one never lands.
	var s2 := Skirmish.new(3)
	s2.add_mech(_mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100))
	var stubborn := _ghoul(500, 30)
	stubborn.stun_resist = 100
	s2.add_foes([stubborn])
	s2.begin()
	s2.start_round()
	assert_eq(stubborn.resist_total(), 100, "base resistance reads")
	s2.assign(0, s2.front[0])
	assert_false(stubborn.is_suppressed(), "never suppressed")
	assert_eq(Effects.stacks_of(stubborn, "numbed"), 0, "and never numbed")


func test_a_corrupt_blow_rots_the_showing_entry_and_it_bites_when_spent() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L)), 0, 200)
	sk.add_mech(m)
	var chorister := Foe.make("chorister", 500, 10)
	chorister.actions[0]["keywords"] = ["corrupt"]
	sk.add_foes([chorister])
	sk.begin()
	sk.start_round()
	assert_eq(sk.pending_bite(sk.mechs[0]), 0, "clean to begin with")
	sk.end_round()
	assert_eq(m.hull, 190, "the blow itself")
	assert_eq(Effects.corrupt_stacks(m, 0), 1, "one stack on the entry that was showing")
	assert_true("\n".join(sk.log).contains("corrupts A's 30"), "the log names the entry")
	sk.start_round()
	assert_eq(sk.pending_bite(sk.mechs[0]), 10, "spending it costs 10")
	assert_eq(sk.forecast(sk.mechs[0], true)["hull_after"], 170, "the forecast counts the bite and the blow while the die is in hand")
	assert_eq(sk.forecast(sk.mechs[0], false)["hull_after"], 180, "and only the blow otherwise")
	sk.assign(0, sk.front[0])
	assert_eq(m.hull, 180, "the bite lands as the entry is spent")
	assert_eq(sk.front[0].hp, 470, "and the component still does its work")
	sk.end_round()
	assert_eq(Effects.corrupt_stacks(m, 0), 2, "it stacks")
	sk.start_round()
	assert_eq(sk.pending_bite(sk.mechs[0]), 20, "twenty a spend now")
	sk._finish()
	assert_eq(Effects.corrupt_stacks(m, 0), 0, "gone with the skirmish")


func test_the_bite_takes_shield_first_and_never_armour() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L)), 5, 100)
	m.armour = 50
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.corrupt_entry(m, 0, "foe:x", 2)
	sk.assign(0, sk.front[0])
	assert_eq(m.shield, 0, "the shield goes first")
	assert_eq(m.hull, 85, "the rest reaches the hull, armour or no armour")
	assert_eq(sk.front[0].hp, 470, "the attack still landed")


func test_cleanse_clears_what_foes_did_and_not_the_rapid_switch_off() -> void:
	var sk := Skirmish.new(1)
	var scrubber := Face.shield(10)
	scrubber.add_keyword(K.CLEANSE)
	var a := _mech("A", Die.single(scrubber), 0, 100)
	var b := _mech("B", Die.single(Face.attack(30, L)), 40, 100)
	b.shield = 0
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.corrupt_entry(b, 0, "foe:x", 2)
	Effects.disable_entry(b, 0, "foe:x", sk.round + 1)
	Effects.stack(b, Effects.STATUS["overheating"], Effects.SKIRMISH, "foe:x", 3)
	assert_eq(scrubber.describe(), "shield 10 cleanse", "the keyword reads on the entry")
	assert_true(sk.assign(0, sk.mechs[1]), "the shield is spent on B")
	assert_eq(b.shield, 10, "shielded")
	assert_eq(Effects.corrupt_stacks(b, 0), 0, "corruption gone")
	assert_false(Effects.is_entry_disabled(b, 0), "the foe's disable gone")
	assert_eq(Effects.stacks_of(b, "overheating"), 0, "overheating gone")
	assert_true("\n".join(sk.log).contains("cleanses B: "), "the log says what went")
	Effects.disable_entry(a, 0, "rapid", sk.round)
	var gone := Effects.cleanse(a)
	assert_true(gone.is_empty(), "a rapid switch-off is not the cleanse's to lift")
	assert_true(Effects.is_entry_disabled(a, 0), "and it stays")


func test_the_die_row_names_a_components_own_passive() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive({"id": "fins", "name": "Fins", "description": "Cooling +5.",
		"effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 5}]}, "heat_sink", "heat_sink")
	var sink := Face.vent(20)
	sink.component = "heat_sink"
	var gun := Face.attack(20, L)
	gun.component = "gun"
	assert_eq(Effects.explain(u, sink).size(), 1, "a vent entry names its own passive")
	assert_eq(Effects.explain(u, sink)[0], "passive: Fins", "by name")
	assert_true(Effects.explain(u, gun).is_empty(), "another component's entry does not")
	assert_eq(u.cooling, 5, "and the stat reads it")


func test_a_target_status_condition_reads_the_foe_struck() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L)), 0, 100)
	m.grant_passive({"id": "sol", "name": "Solenoid", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.5, "when": "target_status"}]})
	sk.add_mech(m)
	var clean := _ghoul(200, 10)
	var lit := _ghoul(200, 10)
	sk.add_foes([clean, lit])
	sk.begin()
	sk.start_round()
	sk.assign(0, clean)
	assert_eq(clean.hp, 180, "a clean foe takes the plain 20")
	sk.end_round()
	sk.start_round()
	Effects.stack(lit, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 1)
	sk.assign(0, lit)
	assert_eq(lit.hp, 170, "a burning foe takes 20 times 1.5")
	var notes := Effects.explain(m, m.die.faces[0])
	assert_eq(notes.size(), 1, "the die row shows the rule")
	assert_true(notes[0].begins_with("foes carrying a status: damage ×1.5"), "with its condition as the lead: %s" % notes[0])
	assert_eq(int(Effects.attack(m, m.die.faces[0], 20, 0, false)["damage"]), 20, "asked without a target, the condition does not hold")


func test_stacks_a_hot_machine_applies_run_deeper() -> void:
	# The Stingray's Exothermic Suite (2 October): every stack this machine applies is one
	# deeper per 20 heat it carries, on a foe's burn, an ally's buff or its own devour;
	# Numbed never (exempt from every interaction).
	var hot := {"id": "hot", "name": "Exothermic Suite", "description": "", "effects": [
		{"trigger": "on_stack", "effect": "add_stacks", "value": 1, "per_heat": 20}]}
	var sk := Skirmish.new(1)
	var m := _mech("Ray", Die.single(Face.attack(20, L, K.BURN)), 40, 100)
	m.grant_passive(hot)
	sk.add_mech(m)
	var g := _ghoul(500, 0)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(g, "burning"), 1, "cold, a 20 burn is one stack")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].heat = 45
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(g, "burning"), 1 + 2, "at 45 heat the same burn is two deeper, two whole steps of 20 (the first round's stack burned off at the ghoul's turn)")
	assert_true(sk.log[sk.log.size() - 2].contains("runs hot: +2 Burning"), "and the log says so: %s" % sk.log[sk.log.size() - 2])
	# A buff on an ally is deepened the same way; Numbed from a suppress is not.
	var s2 := Skirmish.new(2)
	var buff := Face.buff("primed", 1, 1)
	var a := _mech("Ray", Die.single(buff), 40, 100)
	a.grant_passive(hot)
	var ally := _mech("Friend", Die.single(Face.attack(10, L, K.SUPPRESS)), 40, 100)
	s2.add_mech(a)
	s2.add_mech(ally)
	var g2 := _ghoul(500, 0)
	s2.add_foes([g2])
	s2.begin()
	s2.start_round()
	s2.mechs[0].heat = 60
	s2.assign(0, s2.mechs[1])
	assert_eq(Effects.stacks_of(ally, "primed"), 1 + 3, "a one-stack buff at 60 heat lands four deep")
	var s3 := Skirmish.new(3)
	var z := _mech("Ray", Die.single(Face.attack(10, L, K.SUPPRESS)), 40, 100)
	z.grant_passive(hot)
	s3.add_mech(z)
	var g3 := _ghoul(500, 0)
	s3.add_foes([g3])
	s3.begin()
	s3.start_round()
	s3.mechs[0].heat = 60
	s3.assign(0, s3.front[0])
	assert_eq(Effects.stacks_of(g3, "numbed"), 2, "Numbed is exempt: the suppress leaves its two, no more")
	assert_eq(Effects.extra_stacks(z, "numbed", 100), 0, "asked directly, Numbed gains nothing")
	assert_eq(Effects.extra_stacks(z, "burning", 19), 0, "under one step, nothing")
	assert_eq(Effects.extra_stacks(z, "burning", 100), 5, "five steps at 100")
	assert_true(Effects.effect_text({"trigger": "on_stack", "effect": "add_stacks", "value": 1, "per_heat": 20}).begins_with("every stack this machine applies is 1 deeper for every 20 heat it carries"), "reads as a sentence")


func test_a_foe_gaining_a_status_may_be_caught_by_the_loop() -> void:
	var loop := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "chance_suppress", "value": 100, "per_missing_shield": 0}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L, K.BURN)), 40, 100)
	m.grant_passive(loop)
	sk.add_mech(m)
	var g := _ghoul(500, 30)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_eq(Effects.foe_status_suppress_chance(m), 100, "a sure thing at 100")
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(g, "burning"), 1, "the burn landed")
	assert_true(g.is_suppressed(), "and the loop caught it")
	assert_eq(Effects.stacks_of(g, "numbed"), 2, "a caught foe is numbed like any suppressed one, once")
	sk.end_round()
	assert_eq(m.hull, 100, "it skipped its blow")
	# Missing shield scales the chance, and a full resistance still shrugs it off.
	var u := Unit.mech(1, "B", Vector2i.ZERO)
	u.shield_max = 60
	u.shield = 20
	u.grant_passive({"id": "loop2", "name": "Loop", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "chance_suppress", "value": 20, "per_missing_shield": 1}]})
	assert_eq(Effects.foe_status_suppress_chance(u), 60, "20 plus 40 missing shield")
	u.shield = 60
	assert_eq(Effects.foe_status_suppress_chance(u), 20, "the base alone when the shield is full")
	assert_true(Effects.effect_text({"trigger": "on_foe_status", "effect": "chance_suppress", "value": 20, "per_missing_shield": 1}).begins_with("20% chance a foe gaining a status is also suppressed, +1% per shield point missing"), "reads as a sentence")
	var s2 := Skirmish.new(2)
	var m2 := _mech("C", Die.single(Face.attack(20, L, K.BURN)), 40, 100)
	m2.grant_passive(loop)
	s2.add_mech(m2)
	var stubborn := _ghoul(500, 30)
	stubborn.stun_resist = 100
	s2.add_foes([stubborn])
	s2.begin()
	s2.start_round()
	s2.assign(0, s2.front[0])
	assert_false(stubborn.is_suppressed(), "a fully resistant foe shrugs the loop off too")
	# A suppress itself never feeds the loop.
	var s3 := Skirmish.new(3)
	var m3 := _mech("D", Die.single(Face.attack(20, L, K.SUPPRESS)), 40, 100)
	m3.grant_passive(loop)
	s3.add_mech(m3)
	var g3 := _ghoul(500, 30)
	s3.add_foes([g3])
	s3.begin()
	s3.start_round()
	s3.assign(0, s3.front[0])
	assert_eq(Effects.stacks_of(g3, "numbed"), 2, "one suppress, one set of stacks: no loop on a suppress")


func test_a_buff_component_grants_its_status_through_the_round() -> void:
	var sk := Skirmish.new(1)
	var coil := Face.buff("overcharged", 2, 1)
	var a := _mech("A", Die.single(coil), 40, 100)
	var b := _mech("B", Die.single(Face.attack(20, L)), 40, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(coil.describe(), "Overcharged ×2", "the entry names the status and its stacks")
	assert_eq(coil.number_text(), "×2", "the die shows the stacks")
	assert_true(coil.is_equipment(), "a buff is equipment")
	assert_true(sk.assign(0, sk.mechs[1]), "spent on B")
	assert_eq(Effects.stacks_of(b, "overcharged"), 2, "two stacks on B")
	sk.assign(1, sk.front[0])
	assert_eq(sk.front[0].hp, 500 - 24, "20 times 1.1 squared, rounded")
	sk.end_round()
	assert_eq(Effects.stacks_of(b, "overcharged"), 0, "gone with the round")
	sk.start_round()
	sk.assign(1, sk.front[0])
	assert_eq(sk.front[0].hp, 500 - 24 - 20, "plain 20 the round after")
	# A two-round buff outlasts the first end of round; targets are the component's to set.
	var s2 := Skirmish.new(2)
	var brace := Face.buff("braced", 1, 2)
	brace.targets = Face.Target.ALLY
	var c := _mech("C", Die.single(brace), 40, 100)
	var d := _mech("D", Die.single(Face.attack(20, L)), 0, 100)
	s2.add_mech(c)
	s2.add_mech(d)
	s2.add_foes([_ghoul(500, 20)])
	s2.begin()
	s2.start_round()
	assert_false(s2.assign(0, null), "allies only: not on itself")
	assert_true(s2.assign(0, s2.mechs[1]), "on the ally")
	s2.end_round()
	assert_eq(Effects.stacks_of(d, "braced"), 1, "still there after one round")
	assert_eq(d.hull, 100 - 17, "20 times 0.85, rounded, on bare hull")
	s2.start_round()
	s2.end_round()
	assert_eq(Effects.stacks_of(d, "braced"), 0, "gone after the second")
	var rt := Face.from_dict({"kind": "buff", "status": "primed", "stacks": 3, "rounds": 2, "targets": "self"})
	assert_eq(rt.to_dict(), {"kind": "buff", "reach": "none", "power": 0, "keywords": [], "heat": 0, "targets": "self", "status": "primed", "stacks": 3, "rounds": 2}, "a buff round-trips through content")


func test_the_bot_values_a_burn_more_when_a_loop_may_catch_the_foe() -> void:
	var loop := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "chance_suppress", "value": 100, "per_missing_shield": 0}]}
	var scores: Array[float] = []
	for with_loop in [false, true]:
		var sk := Skirmish.new(1)
		var m := _mech("A", Die.single(Face.attack(20, L, K.BURN)), 40, 100)
		if with_loop:
			m.grant_passive(loop)
		sk.add_mech(m)
		sk.add_foes([_ghoul(500, 30)])
		sk.begin()
		sk.start_round()
		var pol := Policy.make(Policy.GREEDY)
		scores.append(pol.attack_score(sk, sk.mechs[0], sk.mechs[0].face(), sk.front[0]))
	assert_true(scores[1] > scores[0] + 1.0, "the stopped blow counts: %s without the loop, %s with" % [scores[0], scores[1]])
	# And a buff is an option the bot weighs: a coil on a machine holding an attack scores above zero.
	var s2 := Skirmish.new(3)
	var a := _mech("A", Die.single(Face.buff("overcharged", 2)), 40, 100)
	var b := _mech("B", Die.single(Face.attack(30, L)), 40, 100)
	s2.add_mech(a)
	s2.add_mech(b)
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	var pol2 := Policy.make(Policy.GREEDY)
	var opts: Array = pol2.options_for(s2, 0)
	assert_eq(opts.size(), 2, "self and the ally")
	var on_b := 0.0
	var on_a := 0.0
	for o in opts:
		if o["target"] == s2.mechs[1]:
			on_b = float(o["score"])
		else:
			on_a = float(o["score"])
	assert_true(on_b > on_a, "the coil is worth more on the machine that can shoot this round (%s vs %s)" % [on_b, on_a])


func test_a_volatile_spend_bites_hull_past_shield_and_armour() -> void:
	var sk := Skirmish.new(1)
	var fist := Face.attack(30, L, K.VOLATILE)
	var m := _mech("A", Die.single(fist), 40, 100)
	m.armour = 50
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(fist.describe(), "30 volatile", "the keyword reads on the entry")
	assert_eq(sk.pending_volatile(sk.mechs[0]), 10, "spending it costs 10 hull")
	assert_eq(sk.forecast(sk.mechs[0], true)["volatile"], 10, "the forecast names the cost while the die is in hand")
	assert_eq(sk.forecast(sk.mechs[0], true)["hull_after"], 90, "and takes it off the hull, shield or no shield")
	assert_eq(sk.forecast(sk.mechs[0], false)["hull_after"], 100, "nothing otherwise: the ghoul's blow is blocked")
	assert_true(sk.assign(0, sk.front[0]), "spent")
	assert_eq(m.hull, 90, "the bite lands on the hull as the entry is spent, past shield and armour")
	assert_eq(m.shield, 40, "the shield never saw it")
	assert_eq(sk.front[0].hp, 470, "and the component still does its work")
	assert_true("\n".join(sk.log).contains("A: 30 volatile is volatile, hull -10"), "the log says so")
	assert_eq(sk.pending_volatile(sk.mechs[0]), 0, "a spent die costs nothing more")


func test_a_volatile_shield_costs_hull_to_raise() -> void:
	var sk := Skirmish.new(1)
	var plate := Face.shield(20)
	plate.add_keyword(K.VOLATILE)
	var m := _mech("A", Die.single(plate), 40, 100)
	m.shield = 0
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, null), "raised on itself")
	assert_eq(m.shield, 20, "the shield stands")
	assert_eq(m.hull, 90, "and cost hull to raise")


func test_a_volatile_component_can_wreck_its_owner_before_it_acts() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L, K.VOLATILE)), 40, 10)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.forecast(sk.mechs[0], true)["destroyed"], "the forecast warns")
	assert_true(sk.assign(0, sk.front[0]), "the spend is legal")
	assert_eq(m.hull, 0, "wrecked by its own component")
	assert_eq(sk.front[0].hp, 500, "which never fired")
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "the fight is decided")
	assert_true("\n".join(sk.log).contains("wrecked by its own volatile component"), "the log says why")


func test_a_disabled_volatile_entry_does_not_bite() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L, K.VOLATILE)), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.disable_entry(m, 0, "foe:x", sk.round + 1)
	assert_eq(sk.pending_volatile(sk.mechs[0]), 0, "a blank is never spent")
	assert_true(sk.assign(0, null), "the blank is discarded")
	assert_eq(m.hull, 100, "and costs nothing")


func test_devour_feeds_a_stack_of_overcharged_per_kill_and_it_fades_a_round_at_a_time() -> void:
	var sk := Skirmish.new(3)
	var talon := Face.attack(30, L, [K.CLEAVE, K.DEVOUR])
	var m := _mech("A", Die.single(talon), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(30, 10), _ghoul(30, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(talon.describe(), "30 spread devour", "the keyword reads on the entry")
	# Column 1 (the middle) spreads to both neighbours: two ghouls at 30 die, the big one lives.
	var middle: Foe = sk.front[1]
	assert_true(sk.assign(0, middle), "spent on the middle")
	var kills := 0
	for col in range(3):
		if sk.front[col] == null:
			kills += 1
	assert_eq(kills, 2, "two ghouls fell to the spread")
	assert_eq(Effects.stacks_of(m, "overcharged"), 2, "one stack of Overcharged per kill")
	assert_true("\n".join(sk.log).contains("devours ghoul: Overcharged"), "the log says what was taken")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "a stack fades at the round's end")
	sk.start_round()
	var big: Foe = null
	for col in range(3):
		if sk.front[col] != null and sk.front[col].hp > 100:
			big = sk.front[col]
	var before := big.hp
	sk.assign(0, big)
	assert_eq(before - big.hp, 33, "30 times 1.1 with the stack left, rounded")
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "no kill, no new stack")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 0, "and the last fades")


func test_a_buffs_overcharged_and_devours_add_up() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L, K.DEVOUR)), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.grant_buff(m, "overcharged", 1, "buff", sk.round)
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.SKIRMISH, "devour", 2, Effects.DECAY_TICK)
	assert_eq(Effects.stacks_of(m, "overcharged"), 3, "the round's stack and the skirmish's count together")
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 500 - 27, "20 times 1.1 cubed, rounded")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "the buff went with the round, devour's faded one")


func test_a_live_hull_shocks_the_foe_that_strikes_it_and_the_next_blow_lands_double() -> void:
	var live := {"id": "live_hull", "name": "Faraday Hull", "description": "", "effects": [
		{"trigger": "static", "effect": "shock_on_hull_strike", "value": 1}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L)), 0, 200)
	m.grant_passive(live)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_true(Effects.shocks_striker(m, false), "the hull is live")
	assert_false(Effects.shocks_striker(m, true), "but a blocked blow shocks nothing")
	sk.end_round()
	assert_eq(m.hull, 190, "the blow landed on bare hull")
	assert_true(Effects.has(g, "shocked"), "and the ghoul is Shocked")
	assert_true("\n".join(sk.log).contains("A shocks ghoul"), "the log says so")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 460, "20 lands double")
	assert_false(Effects.has(g, "shocked"), "and the shock is spent")
	assert_eq(sk.last_roll["final"], 40, "the blow's record carries what landed")
	m.shield_max = 50
	m.shield = 50   # the next strike is blocked, so nothing shocks it again
	sk.end_round()
	assert_false(Effects.has(g, "shocked"), "a blocked blow leaves it unshocked")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 440, "plain 20 after")


func test_a_shocked_foe_that_reaches_hull_again_pays_the_discharge() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 40, 200)
	m.shield = 0
	Effects.stack(m, Effects.STATUS["retaliate"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_true(Effects.has(g, "shocked"), "shocked by the first strike")
	assert_eq(g.hp, 500, "no discharge on the strike that shocked it")
	sk.start_round()
	sk.end_round()
	assert_eq(g.hp, 500 - Skirmish.SHOCK_DISCHARGE, "the second strike on bare hull costs it the discharge")
	assert_true(Effects.has(g, "shocked"), "and it stays Shocked, never doubly")
	assert_true("\n".join(sk.log).contains("A discharges into ghoul: 10"), "the log says so")
	# A blocked blow neither shocks nor discharges, unless a passive extends the shock to blocks.
	sk.start_round()
	sk.assign(0, null)
	assert_eq(m.shield, 10, "shield up")
	sk.end_round()
	assert_eq(g.hp, 490, "the blocked blow cost the ghoul nothing")
	var s2 := Skirmish.new(2)
	var shutters := {"id": "live_shell", "name": "Live Shell", "description": "", "effects": [
		{"trigger": "static", "effect": "shock_on_block", "value": 1}]}
	var b := _mech("B", Die.single(Face.shield(10)), 40, 200)
	b.grant_passive(shutters, "shutters", "shutters")
	s2.add_mech(b)
	var g2 := _ghoul(500, 10)
	s2.add_foes([g2])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq(b.hull, 200, "blocked")
	assert_true(Effects.has(g2, "shocked"), "and shocked through the block all the same")


func test_retaliate_is_a_buff_a_component_may_grant() -> void:
	var sk := Skirmish.new(1)
	var klaxon := Face.buff("retaliate", 1, 1)
	var m := _mech("A", Die.single(klaxon), 0, 200)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_eq(klaxon.describe(), "Retaliate ×1", "the entry names the status")
	assert_true(sk.assign(0, null), "spent on itself")
	assert_true(Effects.shocks_striker(m, false), "live for the round")
	sk.end_round()
	assert_true(Effects.has(g, "shocked"), "the striker is shocked")
	assert_false(Effects.shocks_striker(m, false), "and the buff went with the round")
	var f := Face.from_dict({"kind": "buff", "status": "retaliate"})
	assert_eq(f.buff_status, "retaliate", "content may write it")


func test_a_status_gained_after_a_foe_acted_suppresses_its_next_action() -> void:
	var loop := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "chance_suppress", "value": 100, "per_missing_shield": 0}]}
	var live := {"id": "live_hull", "name": "Faraday Hull", "description": "", "effects": [
		{"trigger": "static", "effect": "shock_on_hull_strike", "value": 1}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 200)
	m.grant_passive(loop)
	m.grant_passive(live, "hull")
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 190, "the blow landed")
	assert_true(Effects.has(g, "shocked"), "shocked by it")
	sk.start_round()
	assert_true(g.is_suppressed(), "the loop's suppress holds for the round after, since the ghoul had already struck")
	sk.end_round()
	assert_eq(m.hull, 190, "and it skipped that blow")


func test_a_taunt_turns_the_front_rank_on_the_machine_for_the_round() -> void:
	var sk := Skirmish.new(2, 2)
	var klaxon := Face.shield(10)
	klaxon.add_keyword(K.TAUNT)
	var tank := _mech("Tank", Die.single(klaxon), 40, 200)
	var glass := _mech("Glass", Die.single(Face.attack(10, L)), 0, 50)
	sk.add_mech(tank)
	sk.add_mech(glass)
	sk.add_foes([_ghoul(500, 10), _ghoul(500, 10), _archer(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(klaxon.describe(), "shield 10 taunt", "the keyword reads on the entry")
	for f in sk.field_foes():
		assert_eq(f.target, sk.mechs[1], "every foe aims at the bare machine to begin with")
	assert_true(sk.assign(0, null), "the tank raises its klaxon")
	assert_true(Effects.draws_rank(tank, 0), "and draws the front rank")
	for col in range(2):
		assert_eq(sk.front[col].target, sk.mechs[0], "the front rank turned on the tank")
	var archer: Foe = sk.back[0] if sk.back[0] != null else sk.back[1]
	assert_eq(archer.target, sk.mechs[1], "the back rank kept its aim")
	assert_eq(sk.incoming_for(sk.mechs[0]), 20, "the forecast follows the turn")
	assert_true("\n".join(sk.log).contains("the front rank turns on Tank (2)"), "the log says so")
	sk.end_round()
	assert_eq(tank.shield, 20, "the tank took the front rank's blows on its shield (the klaxon's ten was over its maximum)")
	assert_eq(glass.hull, 40, "the archer's blow reached the glass")
	assert_false(Effects.draws_rank(tank, 0), "the taunt went with the round")
	sk.start_round()
	for f in sk.field_foes():
		assert_eq(f.target, sk.mechs[1], "and the next round aims as it likes")


func test_a_beacon_draws_the_back_rank_and_a_lost_target_picks_the_drawing_machine() -> void:
	var sk := Skirmish.new(2, 2)
	var flare := Face.vent(10)
	flare.add_keyword(K.BEACON)
	var tank := _mech("Tank", Die.single(flare), 40, 200)
	var glass := _mech("Glass", Die.single(Face.attack(10, L)), 0, 50)
	sk.add_mech(tank)
	sk.add_mech(glass)
	sk.add_foes([_ghoul(500, 10), _archer(500, 10), _archer(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, null), "the tank lights its beacon")
	assert_eq(sk.front[0].target, sk.mechs[1], "the ghoul in front keeps its aim")
	for col in range(2):
		assert_eq(sk.back[col].target, sk.mechs[0], "both archers turned")
	# A foe whose target dies picks whoever draws its rank, not the weakest machine.
	var s2 := Skirmish.new(3, 1)
	var t2 := _mech("Tank", Die.single(Face.shield(10)), 40, 200)
	var g2 := _mech("Glass", Die.single(Face.attack(10, L)), 0, 10)
	var g3 := _mech("Glass2", Die.single(Face.attack(10, L)), 0, 100)
	s2.add_mech(t2)
	s2.add_mech(g2)
	s2.add_mech(g3)
	s2.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	Effects.grant_buff(t2, "taunt", 1, "test", s2.round)
	s2.front[0].target = s2.mechs[1]
	s2.front[0].attack = 50
	s2.reinforcements.clear()
	assert_eq(s2._pick_mech_target(s2.front[0]), s2.mechs[0], "a front-rank foe asked again picks the taunting machine")


func test_a_taunt_may_also_come_as_a_buff() -> void:
	var f := Face.from_dict({"kind": "buff", "status": "taunt"})
	assert_eq(f.buff_status, "taunt", "content may write it")
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(f), 40, 100)
	var b := _mech("B", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.front[0].target, sk.mechs[1], "the bare one first")
	assert_true(sk.assign(0, null), "the buff is spent on itself")
	assert_eq(sk.front[0].target, sk.mechs[0], "and the ghoul turns")


func test_overwhelm_carries_the_damage_past_a_kill_into_the_foe_behind() -> void:
	var sk := Skirmish.new(1, 2)
	var ram := Face.attack(50, L, K.OVERWHELM)
	var m := _mech("A", Die.single(ram), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 10), _ghoul(500, 10), _archer(500, 10), _archer(10, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(ram.describe(), "50 overwhelm", "the keyword reads on the entry")
	# Find the column with the weak ghoul in front and see who stands behind it.
	var col := 0 if sk.front[0].hp == 20 else 1
	var behind: Foe = sk.back[col]
	var behind_before := behind.hp
	assert_true(sk.assign(0, sk.front[col]), "hit the weak ghoul")
	assert_eq(sk.front[col], null, "it fell")
	assert_eq(behind_before - behind.hp, 30, "the 30 past its 20 carried into the archer behind")
	assert_true("\n".join(sk.log).contains("A overwhelms: 30 spills into archer"), "the log says so")
	# No spill into an empty slot, and none past a foe that survives.
	sk.end_round()
	sk.start_round()
	var big_col := 1 - col
	var big: Foe = sk.front[big_col]
	var other_back: Foe = sk.back[big_col]
	var other_before := other_back.hp if other_back != null else -1
	sk.assign(0, big)
	assert_eq(big.hp, 450, "the big one stands")
	if other_back != null:
		assert_eq(other_back.hp, other_before, "and nothing spilled")


func test_a_passive_may_grant_a_keyword_and_the_entry_wears_it() -> void:
	var drive := {"id": "drive", "name": "Juggernaut Drive", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "overwhelm"}]}
	var sk := Skirmish.new(1, 1)
	var gun := Face.attack(50, L)
	var m := _mech("A", Die.single(gun), 40, 100)
	m.grant_passive(drive)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 10), _archer(500, 10)])
	sk.begin()
	sk.start_round()
	assert_false(gun.has(K.OVERWHELM), "the die's own entry is untouched")
	assert_true(Effects.effective_face(m, gun).has(K.OVERWHELM), "but the machine spends it with the keyword")
	assert_true(sk.shown_face(sk.mechs[0], gun).has(K.OVERWHELM), "and sees it on the die")
	assert_eq(Effects.explain(m, gun), ["gains overwhelm (Juggernaut Drive)"], "the die row says where it came from")
	sk.assign(0, sk.front[0])
	assert_eq(sk.back[0].hp, 470, "the plain gun spilled past the kill")
	# A support keyword is never granted to an attack, nor an attack keyword to a shield.
	var plate := Face.shield(10)
	var odd := {"id": "odd", "name": "Odd", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "cleanse"}]}
	m.grant_passive(odd, "odd")
	assert_false(Effects.effective_face(m, gun).has(K.CLEANSE), "cleanse stays off the gun")
	assert_true(Effects.effective_face(m, plate).has(K.CLEANSE), "and lands on the shield")
	assert_false(Effects.effective_face(m, plate).has(K.OVERWHELM), "overwhelm stays off the shield")


func test_a_vent_on_fire_attack_fires_the_heat_into_the_blow_and_empties_the_gauge() -> void:
	var sk := Skirmish.new(1)
	var cannon := Face.from_dict({"kind": "attack", "reach": "line", "power": 20, "heat": 0, "vents_all": true, "power_per_heat": 10})
	var m := _mech("A", Die.single(cannon), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].heat = 47
	assert_eq(cannon.describe(), "20 vents all, +10 per 10 heat", "the entry says what it does")
	assert_eq(cannon.to_dict()["power_per_heat"], 10, "and round-trips")
	assert_eq(sk.heat_bonus(sk.mechs[0], cannon), 40, "four tens of heat: +40")
	assert_eq(sk.pending_heat(sk.mechs[0]), -47, "the forecast sees the gauge emptying")
	assert_eq(sk.forecast(sk.mechs[0], true)["heat_after"], 0, "and lands at zero")
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 440, "20 plus the 40 fired")
	assert_eq(sk.mechs[0].heat, 0, "the airframe is cold")
	assert_true("\n".join(sk.log).contains("A fires its heat: -47, +40 to the blow"), "the log says so")
	# Cold, it is a plain 20; its own heat cost still lands.
	var hot := Face.from_dict({"kind": "attack", "reach": "line", "power": 20, "heat": 15, "vents_all": true, "power_per_heat": 10})
	var s2 := Skirmish.new(2)
	s2.add_mech(_mech("B", Die.single(hot), 40, 100))
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	s2.mechs[0].heat = 5
	s2.assign(0, s2.front[0])
	assert_eq(s2.front[0].hp, 480, "under ten heat adds nothing")
	assert_eq(s2.mechs[0].heat, 15, "emptied, then the shot's own heat")


func test_a_round_start_passive_regains_shield_from_heat() -> void:
	var recoupler := {"id": "recoupler", "name": "Thermal Recoupler", "description": "", "effects": [
		{"trigger": "on_round_start", "effect": "shield_per_heat", "value": 5}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L, [], 30)), 60, 100)
	m.shield = 10
	m.grant_passive(recoupler)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(m.shield, 10, "no heat, no shield")
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(sk.mechs[0].heat, 30, "hot now")
	sk.start_round()
	assert_eq(m.shield, 10 - 10 + 15, "the ghoul's blow took ten, then three tens of heat gave fifteen")
	assert_true("\n".join(sk.log).contains("A: round start, +15 shield"), "the log says so")
	assert_eq(Effects.effect_text({"trigger": "on_round_start", "effect": "shield_per_heat", "value": 5}), "at the start of the round: +5 shield for every 10 heat carried", "reads as a sentence")
	# Never over the maximum.
	m.shield = 58
	sk.mechs[0].heat = 40
	sk.end_round()
	sk.start_round()
	assert_true(m.shield <= 60, "capped at the maximum")


func test_a_kinetic_weapon_rolls_its_maximum_with_an_ally_in_the_fight() -> void:
	var databank := {"id": "databank", "name": "Tactical Databank", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "roll_max", "value": 1, "when": "ally_present"}]}
	var sk := Skirmish.new(1)
	var gun := Face.attack(10, L, [], 0, 30)
	var a := _mech("A", Die.single(gun), 40, 100)
	a.grant_passive(databank)
	var b := _mech("B", Die.single(Face.blank()), 40, 10)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 30)])
	sk.begin()
	sk.start_round()
	assert_eq(a.allies, 1, "the skirmish tells the unit who stands with it")
	assert_true(Effects.rolls_max(a, gun), "the solution holds")
	assert_eq(Effects.explain(a, gun), ["with an ally in the fight: kinetic weapons roll their maximum (Tactical Databank)"], "the die row says so")
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 470, "the roll is its ceiling")
	# Alone, it rolls as any gun does.
	b.hull = 0
	sk._refresh_allies()
	assert_eq(a.allies, 0, "alone")
	assert_false(Effects.rolls_max(a, gun), "and the solution is gone")
	var pol := Policy.make(Policy.GREEDY)
	assert_true(pol.expected_damage(sk.mechs[0], gun, sk.front[0]) < 30.0, "the bot reads the plain roll")
	b.hull = 10
	sk._refresh_allies()
	assert_eq(pol.expected_damage(sk.mechs[0], gun, sk.front[0]), 30.0, "and the ceiling with the ally back")


func test_a_free_reroll_of_one_die_spares_the_teams() -> void:
	var director := {"id": "director", "name": "Battery Director", "description": "", "effects": [
		{"trigger": "static", "effect": "free_reroll", "value": 1}]}
	var sk := Skirmish.new(1)
	var a := _mech("A", Die.of([Face.attack(10, L), Face.attack(20, L), Face.attack(30, L)]), 40, 100)
	a.grant_passive(director)
	var b := _mech("B", Die.of([Face.attack(10, L), Face.attack(20, L)]), 40, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.mechs[0].free_rerolls, 1, "one of its own this round")
	assert_eq(sk.mechs[1].free_rerolls, 0, "none for the other")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "the team's are untouched")
	var before := sk.mechs[0].face_index
	assert_true(sk.reroll([0]), "A alone rerolls")
	assert_true(sk.mechs[0].face_index != before, "and the die moved")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "for free")
	assert_eq(sk.mechs[0].free_rerolls, 0, "once a round")
	assert_true(sk.reroll([0]), "again, from the team's")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND - 1, "which paid this time")
	sk.rerolls_left = 0
	assert_false(sk.can_reroll(), "nothing left")
	sk.mechs[0].free_rerolls = 1
	assert_true(sk.can_reroll(), "a free one is a reroll open")
	assert_false(sk.reroll([0, 1]), "but not for two dice at once")
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].free_rerolls, 1, "back each round")


func test_the_crucible_stacks_overheating_on_hull_hits_and_melee_grows_with_it() -> void:
	var crucible := {"id": "crucible", "name": "Crucible Capacitor", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 5, "per_stack": "overheating", "when": "reach_melee"},
		{"trigger": "on_hull_damage", "effect": "stack_status", "value": "overheating"}]}
	var sk := Skirmish.new(1)
	var fist := Face.attack(30, Face.Reach.MELEE)
	var m := _mech("A", Die.single(fist), 0, 200)
	m.grant_passive(crucible)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	g.actions[0]["strikes"] = 2
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 470, "cold: a plain 30")
	sk.end_round()
	assert_eq(m.hull, 180, "two blows reached hull")
	assert_eq(Effects.stacks_of(m, "overheating"), 1, "two stacks from the hits, one ticked away at the round's end")
	assert_true("\n".join(sk.log).contains("A: Overheating from the hit"), "the log says so")
	sk.start_round()
	Effects.stack(m, Effects.STATUS["overheating"], Effects.SKIRMISH, "test", 2)
	assert_eq(Effects.stacks_of(m, "overheating"), 3, "three stacks now")
	assert_eq(Effects.explain(m, fist), ["melee attacks: damage +5 per stack of Overheating (Crucible Capacitor)"], "the die row says so")
	sk.assign(0, g)
	assert_eq(g.hp, 470 - 45, "30 plus 5 a stack for three")
	# A line weapon gains nothing, and the round's overheat burn never feeds it.
	var gun := Face.attack(30, L)
	assert_eq(int(Effects.attack(m, gun, 30, 0, false, g)["damage"]), 30, "not a melee blow")
	var before := Effects.stacks_of(m, "overheating")
	sk.mechs[0].heat = sk.mechs[0].heat_max + 20
	sk._settle_heat()
	assert_eq(Effects.stacks_of(m, "overheating"), before, "the burn is not a hit")
	# A volatile bite is the machine's own weapon reaching hull: it counts.
	var s2 := Skirmish.new(2)
	var n := _mech("N", Die.single(Face.attack(30, Face.Reach.MELEE, K.VOLATILE)), 40, 200)
	n.grant_passive(crucible)
	s2.add_mech(n)
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	s2.assign(0, s2.front[0])
	assert_eq(Effects.stacks_of(n, "overheating"), 1, "the bite fed the core")


func test_glacis_armours_against_the_front_rank_only() -> void:
	var glacis := {"id": "glacis", "name": "Glacis", "description": "", "effects": [
		{"trigger": "static", "effect": "add_armour_vs_rank", "value": 5, "rank": "front"}]}
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.blank()), 0, 200)
	m.armour = 5
	m.grant_passive(glacis, "plow", "plow")
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 20), _archer(500, 20)])
	sk.begin()
	sk.start_round()
	assert_eq(Effects.armour_against(m, 0), 5, "five more against the front")
	assert_eq(Effects.armour_against(m, 1), 0, "none against the back")
	assert_eq(m.armour, 5, "the stat itself is unchanged")
	assert_eq(sk.forecast(sk.mechs[0], false)["hull_after"], 200 - 10 - 15, "the forecast: the ghoul's 20 less ten, the archer's 20 less five")
	sk.end_round()
	assert_eq(m.hull, 175, "and so it lands")
	assert_eq(Effects.effect_text(glacis["effects"][0]), "armour +5 against front-rank blows", "reads as a sentence")


func test_a_kept_status_never_fades_and_lasts_the_battle() -> void:
	var tap := {"id": "tap", "name": "Quintessence Tap", "description": "", "effects": [
		{"trigger": "static", "effect": "keep_status", "value": "overcharged"}]}
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.single(Face.attack(30, L, K.DEVOUR)), 40, 100)
	m.grant_passive(tap)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 10), _ghoul(20, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(Effects.keeps(m, "overcharged"), "the tap holds")
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "one kill, one stack")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "it did not fade")
	sk.start_round()
	sk.assign(0, sk.front[0] if sk.front[0] != null and sk.front[0].hp <= 20 else sk.front[1])
	assert_eq(Effects.stacks_of(m, "overcharged"), 2, "and grows")
	sk._finish()
	assert_eq(Effects.stacks_of(m, "overcharged"), 2, "kept past the skirmish")
	Effects.end_battle(m)
	assert_eq(Effects.stacks_of(m, "overcharged"), 0, "gone with the battle, never the campaign")


func test_the_static_screen_covers_the_withdrawal() -> void:
	var screen := {"id": "screen", "name": "Static-screen Projector", "description": "", "effects": [
		{"trigger": "static", "effect": "screen_withdraw", "value": 50}]}
	# A screener is always out; with the chance at 100 every ally is too, and no blow lands.
	var sure := {"id": "screen", "name": "Static-screen Projector", "description": "", "effects": [
		{"trigger": "static", "effect": "screen_withdraw", "value": 100}]}
	var sk := Skirmish.new(1, 2)
	var car := _mech("Car", Die.single(Face.blank()), 0, 260)   # the tank is the weaker target
	car.grant_passive(sure)
	var tank := _mech("Tank", Die.single(Face.blank()), 0, 200)
	sk.add_mech(car)
	sk.add_mech(tank)
	sk.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
	sk.begin()
	assert_true(sk.withdraw(), "withdrew")
	assert_eq(car.hull, 260, "the car is out before the enemy strikes")
	assert_eq(tank.hull, 200, "and covered the tank")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "withdrawn")
	assert_true("\n".join(sk.log).contains("the static screen covers Car, Tank"), "the log names the covered")
	assert_true("\n".join(sk.log).contains("blow is lost in the static"), "and the lost blows")
	assert_true(sk._screened.is_empty(), "the screen is down afterwards")
	# At 50 the allies roll: over many seeds about half are covered, the screener always.
	var covered := 0
	var car_hit := 0
	for seed in range(40):
		var s2 := Skirmish.new(seed, 2)
		var c2 := _mech("Car", Die.single(Face.blank()), 0, 260)
		c2.grant_passive(screen)
		var t2 := _mech("Tank", Die.single(Face.blank()), 0, 200)
		s2.add_mech(c2)
		s2.add_mech(t2)
		s2.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
		s2.begin()
		s2.withdraw()
		if c2.hull < 260:
			car_hit += 1
		if t2.hull == 200:
			covered += 1
	assert_eq(car_hit, 0, "the screener is never struck")
	assert_true(covered > 8 and covered < 32, "about half the tanks slipped out: %d of 40" % covered)
	# No screener, no screen: the withdrawal costs what it always did.
	var s3 := Skirmish.new(3, 1)
	var plain := _mech("Plain", Die.single(Face.blank()), 0, 100)
	s3.add_mech(plain)
	s3.add_foes([_ghoul(500, 10)])
	s3.begin()
	s3.withdraw()
	assert_eq(plain.hull, 90, "struck as the team pulls out")


func _special(kind: String, effect: String, extra: Dictionary = {}) -> Dictionary:
	var a := {"id": effect, "name": effect.capitalize(), "kind": kind, "effect": effect, "weight": 1, "text": ""}
	for k in extra.keys():
		a[k] = extra[k]
	return a


func test_a_folding_foe_takes_half_until_its_next_action_and_a_knitting_one_regrows() -> void:
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.attack(20, L)), 40, 100)
	sk.add_mech(m)
	var g := _ghoul(100, 10)
	g.actions = [_special("defend", "halve_damage")]
	g.action = g.actions[0]
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_false(g.attacks(), "not a blow")
	assert_eq(g.damage(), 0, "and no damage")
	assert_eq(sk.attackers_of(sk.mechs[0]).size(), 0, "so it is no attacker")
	assert_eq(sk.incoming_for(sk.mechs[0]), 0, "and the forecast is quiet")
	sk.end_round()
	assert_eq(m.shield, 40, "nothing struck")
	assert_true(Effects.has(g, "folded"), "folded")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 90, "the 20 lands as 10")
	g.actions = [Foe.basic_action()]
	g.action = g.actions[0]
	sk.end_round()   # its next action: the fold fades at its tick
	assert_false(Effects.has(g, "folded"), "unfolded at its next action")
	var s2 := Skirmish.new(2, 1)
	s2.add_mech(_mech("B", Die.single(Face.attack(20, L)), 40, 100))
	var k := _ghoul(100, 10)
	k.hp = 50
	k.actions = [_special("defend", "regrow", {"value": 20})]
	k.action = k.actions[0]
	s2.add_foes([k])
	s2.begin()
	s2.start_round()
	assert_eq(k.text_of(k.action), "", "no text set")
	s2.end_round()
	assert_eq(k.hp, 70, "regrew 20")
	k.hp = 95
	s2.start_round()
	s2.end_round()
	assert_eq(k.hp, 100, "never past its maximum")


func test_a_readied_foe_gets_back_up_once_unless_executed() -> void:
	var sk := Skirmish.new(3, 1)
	var m := _mech("A", Die.single(Face.attack(50, L)), 40, 100)
	sk.add_mech(m)
	var g := _ghoul(30, 10)
	g.actions = [_special("buff", "revive_once")]
	g.action = g.actions[0]
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_true(Effects.has(g, "risen"), "readied")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(sk.front[0], null, "it fell")
	assert_eq(sk.reinforcements.size(), 1, "and went back to the pool")
	assert_eq(g.hp, 30, "whole")
	assert_false(Effects.has(g, "risen"), "the charge spent")
	assert_true("\n".join(sk.log).contains("gets back up into the pool"), "the log says so")
	assert_eq(sk.outcome, Skirmish.Outcome.NONE, "the fight goes on")
	sk.end_round()
	assert_eq(sk.front[0], g, "it stepped back in")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(sk.reinforcements.size(), 0, "once only")
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "and the second death holds")
	# An executing blow at any point keeps it down.
	var s2 := Skirmish.new(4, 1)
	s2.add_mech(_mech("B", Die.single(Face.attack(50, L, K.EXECUTE)), 40, 100))
	var e := _ghoul(30, 10)
	e.actions = [_special("buff", "revive_once")]
	e.action = e.actions[0]
	s2.add_foes([e])
	s2.begin()
	s2.start_round()
	s2.end_round()
	s2.start_round()
	s2.assign(0, e)
	assert_true(e.executed, "marked by the execute")
	assert_eq(s2.reinforcements.size(), 0, "it stays down")
	assert_eq(s2.outcome, Skirmish.Outcome.VICTORY, "won")


func test_a_summoning_foe_calls_up_reinforcements_through_the_factory() -> void:
	var sk := Skirmish.new(5, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var n := _archer(30, 10)
	n.pack_id = 7
	n.actions = [_special("buff", "summon", {"foe": "ghoul", "count": 2})]
	n.action = n.actions[0]
	sk.add_foes([n])
	sk.foe_factory = func(id: String) -> Foe: return Foe.make(id, 30, 10)
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(sk.field_foes().size(), 3, "two ghouls stepped in at the round's end")
	for f in sk.field_foes():
		assert_eq(f.pack_id, 7, "in the summoner's pack")
	var s2 := Skirmish.new(6, 1)
	s2.add_mech(_mech("B", Die.single(Face.attack(10, L)), 40, 100))
	var n2 := _archer(30, 10)
	n2.actions = [_special("buff", "summon", {"foe": "ghoul"})]
	n2.action = n2.actions[0]
	s2.add_foes([n2])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq(s2.field_foes().size(), 1, "with no factory, nothing answers")
	assert_true("\n".join(s2.log).contains("nothing answers"), "and the log says so")


func test_a_rally_makes_the_others_hit_harder_next_round_only() -> void:
	var sk := Skirmish.new(7, 2)
	var m := _mech("A", Die.single(Face.blank()), 0, 300)
	sk.add_mech(m)
	var lord := _ghoul(500, 10)
	lord.actions = [_special("buff", "rally", {"value": 10})]
	lord.action = lord.actions[0]
	var g := _ghoul(500, 10)
	sk.add_foes([lord, g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 290, "the ghoul's plain 10 this round; the lord rallied")
	assert_true(Effects.has(g, "kindled"), "the ghoul is kindled")
	assert_false(Effects.has(lord, "kindled"), "not the lord itself")
	sk.start_round()
	assert_eq(g.damage(), 20, "its intent reads 20")
	lord.actions = [Foe.basic_action()]
	lord.action = lord.actions[0]
	sk.end_round()
	assert_eq(m.hull, 290 - 20 - 10, "20 from the kindled ghoul, 10 from the lord's blow")
	assert_false(Effects.has(g, "kindled"), "gone with the round")
	sk.start_round()
	assert_eq(g.damage(), 10, "plain again")


func test_the_debuffs_cost_rerolls_heat_a_reroll_and_a_component() -> void:
	# Roar: the team has one reroll fewer next round.
	var sk := Skirmish.new(8, 1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 40, 100)
	sk.add_mech(m)
	var b := _ghoul(500, 10)
	b.actions = [_special("debuff", "drain_rerolls", {"value": 1})]
	b.action = b.actions[0]
	sk.add_foes([b])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(sk.reroll_debt, 1, "the debt is noted")
	sk.start_round()
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND - 1, "and paid at the next round's start")
	b.actions = [Foe.basic_action()]
	b.action = b.actions[0]
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "then it is over")
	# Stoke: heat on the target, and the forecast counts it.
	var s2 := Skirmish.new(9, 1)
	var m2 := _mech("B", Die.single(Face.attack(10, L)), 40, 100)
	s2.add_mech(m2)
	var h := _archer(500, 10)
	h.actions = [_special("debuff", "add_heat", {"value": 10})]
	h.action = h.actions[0]
	s2.add_foes([h])
	s2.begin()
	s2.start_round()
	assert_eq(s2.scorch_incoming(s2.mechs[0]), 10, "the heat is coming")
	assert_eq(s2.forecast(s2.mechs[0], false)["heat_after"], 10, "and the forecast shows it")
	s2.end_round()
	assert_eq(s2.mechs[0].heat, 10, "landed")
	assert_eq(m2.shield, 40, "no blow with it")
	# Scramble: the next reroll of that die lands anywhere, then the scramble is spent.
	var s3 := Skirmish.new(10, 1)
	var m3 := _mech("C", Die.single(Face.attack(10, L)), 40, 100)
	s3.add_mech(m3)
	var w := _archer(500, 10)
	w.actions = [_special("debuff", "scramble")]
	w.action = w.actions[0]
	s3.add_foes([w])
	s3.begin()
	s3.start_round()
	s3.end_round()
	assert_true(Effects.is_scrambled(m3), "scrambled")
	s3.start_round()
	assert_true(Effects.is_scrambled(m3), "still, until it rerolls")
	assert_true(s3.reroll([0]), "the reroll happens")
	assert_false(Effects.is_scrambled(m3), "and the scramble is spent")
	assert_true("\n".join(s3.log).contains("C's reroll is scrambled"), "the log says so")
	# Unmake: the showing component cracks with no hull lost.
	var s4 := Skirmish.new(11, 1)
	var m4 := _mech("D", Die.single(Face.attack(10, L, K.BURN)), 40, 100)
	s4.add_mech(m4)
	var maw := _ghoul(500, 10)
	maw.actions = [_special("debuff", "crack")]
	maw.action = maw.actions[0]
	s4.add_foes([maw])
	s4.begin()
	s4.start_round()
	s4.end_round()
	assert_true(m4.die.faces[0].cracked, "cracked")
	assert_eq(m4.hull, 100, "with no hull lost")
	assert_eq(m4.shield, 40, "or shield")
	assert_eq(m4.damaged_component_count(), 1, "one to repair")
	s4.start_round()
	s4.end_round()
	assert_eq(m4.die.faces[0].kind, Face.Kind.BLANK, "cracked again: destroyed")


func test_a_foes_special_action_is_picked_by_weight_and_shows_its_kind() -> void:
	var g := _ghoul(30, 10)
	g.actions = [Foe.basic_action(), _special("defend", "halve_damage")]
	g.actions[0]["weight"] = 3
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var specials := 0
	for i in range(400):
		g.choose_action(rng)
		if not g.attacks():
			specials += 1
	assert_true(specials > 60 and specials < 140, "about one pick in four is the special: %d of 400" % specials)
	assert_eq(Foe.kind_of(g.actions[1]), "defend", "its kind reads")
	assert_eq(g.damage_of(g.actions[1]), 0, "and deals nothing")
	assert_eq(g.threat(), 10, "the threat for deployment is the blow's")


func test_the_gauge_triggers_fire_and_never_feed_themselves() -> void:
	var opening := {"id": "opening", "name": "Opening", "description": "", "effects": [
		{"trigger": "on_skirmish_start", "effect": "add_shield", "value": 15}]}
	var breather := {"id": "breather", "name": "Breather", "description": "", "effects": [
		{"trigger": "on_shield_gain", "effect": "vent_heat", "value": 10}]}
	var flywheel := {"id": "flywheel", "name": "Flywheel", "description": "", "effects": [
		{"trigger": "on_heat_gain", "effect": "add_shield", "value": 5}]}
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.of([Face.attack(20, L, [], 30), Face.shield(10)]), 60, 100)
	m.shield = 10
	m.grant_passive(opening)
	m.grant_passive(breather, "b")
	m.grant_passive(flywheel, "c")
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	assert_eq(m.shield, 25, "the opening's shield stood up as the fight began")
	assert_true("\n".join(sk.log).contains("A: as the fight begins, +15 shield"), "the log says so")
	sk.start_round()
	sk.mechs[0].heat = 25
	sk.mechs[0].face_index = 0
	sk.assign(0, sk.front[0])
	# The attack's 30 heat: the flywheel raises 5 shield, which the breather answers by
	# venting 10, and the shield gained grants no more shield.
	assert_eq(m.shield, 30, "5 shield from the heat gained")
	assert_eq(sk.mechs[0].heat, 25 + 30 - 10, "and 10 heat shed for the shield gained")
	assert_eq(Effects.effect_text({"trigger": "on_shield_gain", "effect": "vent_heat", "value": 10}), "on gaining shield: vents 10 heat", "reads as a sentence")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 1
	var heat_before: int = sk.mechs[0].heat
	sk.assign(0, null)
	assert_eq(m.shield, 30 - 10 + 10, "the ghoul's 10 came off, the plate's 10 went on")
	assert_eq(sk.mechs[0].heat, maxi(0, heat_before - 10), "and the breather vented for it")

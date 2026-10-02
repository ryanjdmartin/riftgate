extends TestCase

## The headless player. Synthetic dice throughout: numbers in tens, static faces where the
## exact number matters. Nothing here reads content.

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


func test_greedy_takes_the_kill_over_the_scratch() -> void:
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	sk.add_foes([_ghoul(30, 20), _ghoul(90, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	pol.play_round(sk)
	var dead := 0
	for f in [sk.front[0], sk.front[1]]:
		if f == null:
			dead += 1
	assert_eq(dead, 1, "the die went on the ghoul it could kill")
	assert_eq(sk.reinforcements.size(), 0, "nothing waits: two foes, two slots")
	assert_eq(int(pol.spends.get("", 0)), 1, "one spend tallied under the entry's component")


func test_greedy_shields_the_machine_about_to_die() -> void:
	var sk := Skirmish.new(3)
	var tank := _mech("Tank", Die.single(Face.shield(20)), 40, 100)
	var weak := _mech("Weak", Die.single(Face.attack(10, L)), 40, 20)
	weak.shield = 0   # bare, with room for one
	sk.add_mech(tank)
	sk.add_mech(weak)
	sk.add_foes([_ghoul(300, 30)])
	sk.begin()
	sk.start_round()
	assert_true(sk.forecast(sk.mechs[1], false)["destroyed"], "the ghoul would wreck the weak machine")
	Policy.make(Policy.GREEDY).play_round(sk)
	assert_eq(weak.shield, 20, "the tank's shield went on the weak machine, not itself")
	assert_eq(tank.shield, 40, "and the tank kept its own")
	sk.end_round()
	assert_eq(weak.hull, 20, "so it lived: a standing shield blocks the whole blow")


func test_greedy_vents_before_it_burns() -> void:
	var sk := Skirmish.new(3)
	var hot := _mech("Hot", Die.single(Face.vent(30)), 40, 100)
	sk.add_mech(hot)
	sk.add_foes([_ghoul(300, 1)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].heat = 80   # twenty over a cap of sixty
	assert_eq(int(sk.forecast(sk.mechs[0], false)["overheat"]), 20, "twenty would burn at the round's end")
	Policy.make(Policy.GREEDY).play_round(sk)
	assert_eq(sk.mechs[0].heat, 50, "vented")
	sk.end_round()
	assert_eq(hot.hull, 100, "no burn: the vent was spent on the one who needed it")


func test_greedy_rerolls_a_face_under_the_average() -> void:
	# A die of one blank and one big gun: whichever shows first, the bot ends the round on
	# the gun, having rerolled the blank away (a reroll never lands on the same entry).
	var die := Die.of([Face.blank(), Face.attack(30, L)])
	var wins := 0
	for seed in range(1, 21):
		var sk := Skirmish.new(seed)
		sk.add_mech(_mech("A", die))
		sk.add_foes([_ghoul(30, 1)])
		sk.begin()
		sk.start_round()
		var pol := Policy.make(Policy.GREEDY, seed)
		pol.play_round(sk)
		if sk.outcome == Skirmish.Outcome.VICTORY:
			wins += 1
		assert_true(pol.rerolls <= Skirmish.REROLLS_PER_ROUND, "never more rerolls than the round allows")
	assert_eq(wins, 20, "every seed ends with the ghoul dead: the blank was always rerolled")


func test_random_never_rerolls_and_still_finishes() -> void:
	var die := Die.of([Face.blank(), Face.attack(30, L)])
	var sk := Skirmish.new(5)
	sk.add_mech(_mech("A", die, 40, 100))
	sk.add_foes([_ghoul(30, 1), _ghoul(30, 1)])
	sk.begin()
	var pol := Policy.make(Policy.RANDOM, 5)
	var outcome := pol.play(sk)
	assert_eq(pol.rerolls, 0, "random play never rerolls")
	assert_eq(outcome, Skirmish.Outcome.VICTORY, "and a ghoul that hits for one cannot stop it")
	assert_eq(sk.state, Skirmish.State.DONE, "the fight was played to its end")
	assert_true(pol.rounds >= 2, "two ghouls took at least two rounds")
	assert_eq(int(pol.spends.get("", 0)) + int(pol.spends.get("destroyed", 0)), pol.rounds, "one spend a round, gun or blank")


func test_a_fight_nobody_can_finish_stalls() -> void:
	var u := _mech("A", Die.single(Face.blank()), 0, 100)
	u.armour = 10
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([_ghoul(30, 10)])   # armour eats the whole blow, the die does nothing
	sk.begin()
	var pol := Policy.make(Policy.GREEDY)
	pol.play(sk)
	assert_true(pol.stalled, "stalled, not looping forever")
	assert_eq(pol.rounds, Policy.MAX_ROUNDS, "after the round cap")
	assert_eq(sk.outcome, Skirmish.Outcome.NONE, "the skirmish itself is undecided")


func test_persona_withdraws_under_the_hull_line() -> void:
	var sk := Skirmish.new(2)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 0, 100))
	sk.add_foes([_ghoul(300, 30)])
	sk.begin()
	var pol := Policy.make(Policy.GREEDY)
	pol.withdraw_below = 50
	var outcome := pol.play(sk)
	assert_eq(outcome, Skirmish.Outcome.WITHDRAWN, "pulled out rather than dying")
	assert_true(pol.withdrew, "and says so")
	assert_true(sk.mechs[0].unit.hull > 0, "alive")
	assert_true(sk.mechs[0].unit.hull < 50, "having crossed the line first")


func test_hull_percent_counts_the_dead_at_zero() -> void:
	var sk := Skirmish.new(1)
	var a := _mech("A", Die.single(Face.blank()), 0, 100)
	var b := _mech("B", Die.single(Face.blank()), 0, 100)
	b.hull = -20
	sk.add_mech(a)
	sk.add_mech(b)
	assert_eq(Policy.hull_percent(sk), 50, "a wreck counts as nothing, not as a debt")


func test_greedy_holds_a_die_rather_than_burn_out() -> void:
	var sk := Skirmish.new(1)
	var frail := _mech("Frail", Die.single(Face.attack(10, L, K.NONE, 80)), 40, 15)   # eighty heat on a cap of sixty: twenty over, on fifteen hull
	sk.add_mech(frail)
	sk.add_foes([_ghoul(300, 1)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	pol.play_round(sk)
	assert_false(sk.mechs[0].assigned, "the die was held: the spend would have burnt the machine out")
	assert_eq(pol.spends.size(), 0, "nothing tallied")
	sk.end_round()
	assert_true(frail.hull > 0, "and it lives")
	var bold := _mech("Bold", Die.single(Face.attack(10, L, K.NONE, 80)), 40, 100)
	var sk2 := Skirmish.new(1)
	sk2.add_mech(bold)
	sk2.add_foes([_ghoul(300, 1)])
	sk2.begin()
	sk2.start_round()
	Policy.make(Policy.GREEDY).play_round(sk2)
	assert_false(sk2.mechs[0].assigned, "ten damage for thirty hull of burn is held too")


func test_shield_only_die_is_spent_on_the_one_machine() -> void:
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.single(Face.shield(10)), 40, 100)
	u.shield = 0
	sk.add_mech(u)
	sk.add_foes([_ghoul(30, 1)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	pol.play_round(sk)
	assert_true(sk.mechs[0].assigned, "the shield was spent")
	assert_eq(sk.mechs[0].unit.shield, 10, "on itself, the only machine")


func test_greedy_holds_a_volatile_die_that_would_wreck_the_machine() -> void:
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.VOLATILE)), 40, 10))
	sk.add_foes([_ghoul(30, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(Policy.volatile_cost(sk, ms, ms.face()) > Policy.DEATH_WEIGHT, "the bite would finish the machine, and the bot knows the price")
	pol.play_round(sk)
	assert_true(sk.front[0] != null and sk.front[0].alive(), "the kill is not taken")
	assert_eq(sk.mechs[0].unit.hull, 10, "the machine stands")
	var s2 := Skirmish.new(3)
	s2.add_mech(_mech("B", Die.single(Face.attack(30, L, K.VOLATILE)), 40, 100))
	s2.add_foes([_ghoul(30, 10)])
	s2.begin()
	s2.start_round()
	Policy.make(Policy.GREEDY).play_round(s2)
	assert_eq(s2.front[0], null, "with hull to spare the kill is worth the bite")
	assert_eq(s2.mechs[0].unit.hull, 90, "paid for")


func test_greedy_values_the_kill_that_feeds_it() -> void:
	var sk := Skirmish.new(3)
	var plain := Face.attack(30, L)
	var talon := Face.attack(30, L, K.DEVOUR)
	sk.add_mech(_mech("A", Die.of([plain, talon]), 40, 100))
	sk.add_foes([_ghoul(30, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	var a := pol.attack_score(sk, ms, plain, sk.front[0])
	var b := pol.attack_score(sk, ms, talon, sk.front[0])
	assert_true(b > a, "a devouring kill is worth more than the same kill without it")
	assert_true(b - a < 10.0, "and not by much: a stack is a tenth of the die's damage for about a round")


func test_the_bot_reads_a_shocked_foe_as_taking_double() -> void:
	var sk := Skirmish.new(1)
	var f := Face.attack(20, L)
	sk.add_mech(_mech("A", Die.single(f), 40, 100))
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(pol.expected_damage(ms, f, g), 20.0, "plain")
	Effects.stack(g, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_eq(pol.expected_damage(ms, f, g), 40.0, "doubled while the shock stands")
	var burst := Face.attack(20, L)
	burst.strikes = 3
	assert_eq(pol.expected_damage(ms, burst, g), 80.0, "only the first of three blows is doubled")


func test_greedy_taunts_when_it_saves_the_glass_machine() -> void:
	var sk := Skirmish.new(2, 2)
	sk.targeting_override = "lowest"
	var klaxon := Face.shield(10)
	klaxon.add_keyword(K.TAUNT)
	var plain := Face.shield(10)
	var tank := _mech("Tank", Die.of([klaxon, plain]), 40, 200)
	var glass := _mech("Glass", Die.single(Face.blank()), 0, 15)
	sk.add_mech(tank)
	sk.add_mech(glass)
	sk.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(pol.draw_score(sk, ms, klaxon, 10) > Policy.DEATH_WEIGHT, "the taunt saves a machine, and the bot sees it")
	assert_eq(pol.draw_score(sk, ms, plain, 10), 0.0, "a plain shield draws nothing")
	assert_true(pol.face_value(sk, ms, klaxon) > pol.face_value(sk, ms, plain), "so the klaxon is the better entry")


func test_greedy_values_the_spill_behind_a_dying_foe() -> void:
	var sk := Skirmish.new(1, 1)
	var plain := Face.attack(50, L)
	var ram := Face.attack(50, L, K.OVERWHELM)
	sk.add_mech(_mech("A", Die.of([plain, ram]), 40, 100))
	sk.add_foes([_ghoul(20, 10), _archer(40, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	var a := pol.attack_score(sk, ms, plain, sk.front[0])
	var b := pol.attack_score(sk, ms, ram, sk.front[0])
	assert_true(b > a + 29.0, "the thirty that spills into the archer counts")


func test_greedy_spends_a_free_reroll_before_the_teams() -> void:
	var director := {"id": "director", "name": "Battery Director", "description": "", "effects": [
		{"trigger": "static", "effect": "free_reroll", "value": 1}]}
	var sk := Skirmish.new(5)
	var a := _mech("A", Die.of([Face.blank(), Face.attack(30, L), Face.attack(30, L), Face.attack(30, L)]), 40, 100)
	a.grant_passive(director)
	sk.add_mech(a)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 0   # the blank
	var pol := Policy.make(Policy.GREEDY)
	pol._greedy_rerolls(sk)
	assert_true(sk.mechs[0].face_index != 0, "the blank was rerolled")
	assert_eq(sk.mechs[0].free_rerolls, 0, "with the machine's own reroll")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "the team's untouched")

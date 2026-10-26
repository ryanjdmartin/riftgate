extends TestCase

## The headless player. Synthetic dice throughout: numbers in tens, static faces where the
## exact number matters. Nothing here reads content.

const L := Face.Reach.DIRECT
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
	return Foe.make("revenant", hp, atk)


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
	sk.front[0].target = sk.mechs[1]   # its pick, set: the test is the shield's, not the aim's
	assert_true(sk.forecast(sk.mechs[1], false)["destroyed"], "the ghoul would wreck the weak machine")
	Policy.make(Policy.GREEDY).play_round(sk)
	assert_eq(weak.shield, 20, "the tank's shield went on the weak machine, not itself")
	assert_eq(tank.shield, 40, "and the tank kept its own")
	sk.end_round()
	assert_eq(weak.hull, 10, "so it lived: the shield took twenty of the thirty, and ten reached the hull")


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
	# At the single-digit scale the bot's weights are set to (the stock pass, 22 October): a
	# blow of 3 kills a foe of 3 HP that hits for 1, and the bite is 3.
	var sk := Skirmish.new(3)
	var bomb := Face.attack(3, L, K.VOLATILE)
	bomb.volatile = 3
	sk.add_mech(_mech("A", Die.single(bomb), 8, 3))
	sk.add_foes([_ghoul(3, 1)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(Policy.volatile_cost(sk, ms, ms.face()) > Policy.DEATH_WEIGHT, "the bite would finish the machine, and the bot knows the price")
	pol.play_round(sk)
	assert_true(sk.front[0] != null and sk.front[0].alive(), "the kill is not taken")
	assert_eq(sk.mechs[0].unit.hull, 3, "the machine stands")
	var s2 := Skirmish.new(3)
	var bomb2 := Face.attack(3, L, K.VOLATILE)
	bomb2.volatile = 3
	s2.add_mech(_mech("B", Die.single(bomb2), 8, 30))
	s2.add_foes([_ghoul(3, 1)])
	s2.begin()
	s2.start_round()
	Policy.make(Policy.GREEDY).play_round(s2)
	assert_eq(s2.front[0], null, "with hull to spare the kill is worth the bite")
	assert_eq(s2.mechs[0].unit.hull, 27, "paid for")


## The gated stuns (22 October): the bot values a gated Suppress only where its gate is open,
## reads a consumer's blow with the stacks in, and gives up the ticks it eats.
func test_greedy_values_a_gated_stun_where_it_lands_and_prices_what_a_consumer_eats() -> void:
	var gun := Face.attack(3, I, [K.SUPPRESS])
	gun.gates = {"suppress": {"when": "target_status", "status": "flakked"}}
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("A", Die.single(gun), 40, 100))
	var plain := _ghoul(100, 20)
	var marked := _ghoul(100, 20)
	sk.add_foes([plain, marked])
	sk.begin()
	sk.start_round()
	Effects.stack(marked, Effects.STATUS["flakked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_HALF)
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	var on_marked := pol.attack_score(sk, ms, gun, marked)
	var on_plain := pol.attack_score(sk, ms, gun, plain)
	var open_part := on_marked - pol.expected_damage(ms, gun, marked)
	var shut_part := on_plain - pol.expected_damage(ms, gun, plain)
	assert_true(open_part > shut_part + 1.0, "the stun counts only where the gate is open (%s against %s)" % [open_part, shut_part])
	var charge := Face.attack(2, L)
	charge.consumes = "burning"
	charge.per_consumed = 1
	var plain_charge := Face.attack(2, L)
	Effects.stack(plain, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 3)
	assert_eq(int(pol.damage_outcomes(ms, charge, plain)[0][0]), 5, "the bot reads the blow with the three stacks in")
	var eat := pol.attack_score(sk, ms, charge, plain) - pol.expected_damage(ms, charge, plain)
	var keep := pol.attack_score(sk, ms, plain_charge, plain) - pol.expected_damage(ms, plain_charge, plain)
	assert_true(eat < keep, "and gives up the ticks the stacks would have dealt (%s against %s)" % [eat, keep])


## The Nemesis's rage (12 October): a stack to spend is another roll of the die, worth about
## the die's own average blow, and a bite of its own costs less when the hull it takes banks
## a stack the die can spend.
func test_greedy_values_rage_as_another_roll() -> void:
	var fist := Face.attack(10, L)
	fist.rolls_again_on = "rage"
	var gun := Face.attack(20, L, K.VOLATILE)
	gun.volatile = 10
	var core := {"id": "rage_core", "name": "Rage Core", "description": "", "effects": [
		{"trigger": "on_hull_damage", "effect": "stack_status", "value": "rage"}]}
	var sk := Skirmish.new(3)
	var m := _mech("A", Die.of([fist, gun]), 0, 200)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	var g: Foe = sk.front[0]
	var bare := pol.attack_score(sk, ms, fist, g)
	var plain_bite := Policy.volatile_cost(sk, ms, gun)
	m.grant_passive(core)
	assert_eq(Policy.banked_on_hull(ms), "rage", "its hull banks the rage its fist spends")
	assert_true(Policy.volatile_cost(sk, ms, gun) < plain_bite, "so the bite costs less")
	assert_eq(pol.attack_score(sk, ms, fist, g), bare, "no rage yet: nothing more")
	Effects.stack(m, Effects.STATUS["rage"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_eq(snappedf(pol.attack_score(sk, ms, fist, g) - bare, 0.01), snappedf(Policy.ROLL_AGAIN_WEIGHT * 15.0, 0.01),
		"a rage to spend: another roll, the die's average blow (10 and 20 over two entries)")


func test_greedy_values_the_kill_that_feeds_it() -> void:
	var sk := Skirmish.new(3)
	var plain := Face.attack(30, L)
	var talon := Face.from_dict({"kind": "attack", "reach": "direct", "power": 30, "devours": true})
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


## The spray (the Skua's Flechette Pod): the first strike on the target, each after it on a random
## foe in reach, so the bot reads each foe its share; on a foe one strike kills, a spray among
## others wastes less past the kill than the same strikes all on it.
func test_greedy_reads_a_spray_as_its_share_on_every_foe_in_reach() -> void:
	var sk := Skirmish.new(1, 3)
	var plain := Face.attack(5, L)
	plain.strikes = 3
	var pod := plain.duplicate_face()
	pod.spray = true
	sk.add_mech(_mech("A", Die.of([plain, pod]), 40, 100))
	var weak := _ghoul(3, 10)
	sk.add_foes([_ghoul(50, 10), weak, _ghoul(50, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(pol.attack_score(sk, ms, pod, weak) > pol.attack_score(sk, ms, plain, weak), "the spray's later strikes go on to the others")
	var lone := Skirmish.new(1, 1)
	lone.add_mech(_mech("A", Die.of([plain, pod]), 40, 100))
	var big := _ghoul(100, 10)
	lone.add_foes([big])
	lone.begin()
	lone.start_round()
	assert_true(absf(pol.attack_score(lone, lone.mechs[0], pod, big) - pol.attack_score(lone, lone.mechs[0], plain, big)) < 0.001, "on a lone foe the spray is the plain gun")


func test_greedy_lures_when_it_saves_the_glass_machine() -> void:
	var sk := Skirmish.new(2, 2)
	var klaxon := Face.attack(0, I, K.LURE)
	klaxon.add_keyword(K.CLEAVE)
	var plain := Face.attack(0, I)
	var tank := _mech("Tank", Die.of([klaxon, plain]), 40, 200)
	var glass := _mech("Glass", Die.single(Face.blank()), 0, 15)
	sk.add_mech(tank)
	sk.add_mech(glass)
	sk.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	for f in sk.field_foes():
		f.target = sk.mechs[1]   # both on the glass
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(pol.lure_score(sk, ms, sk.field_foes()) > Policy.DEATH_WEIGHT, "the lure saves a machine, and the bot sees it")
	assert_true(pol.attack_score(sk, ms, klaxon, sk.front[0]) > Policy.DEATH_WEIGHT, "so the klaxon spent on either ghoul is worth a life")
	assert_eq(pol.attack_score(sk, ms, plain, sk.front[0]), 0.0, "a plain entry of no damage is worth nothing")
	assert_true(pol.face_value(sk, ms, klaxon) > pol.face_value(sk, ms, plain), "so the klaxon is the better entry")
	# A disrupt is worth the blow it turns into a quieter move, and nothing when there is none.
	var g: Foe = sk.front[0]
	g.actions = [Foe.basic_action(), {"id": "roar", "name": "Roar", "kind": "debuff", "effect": "drain_rerolls", "value": 1, "weight": 1, "text": ""}]
	g.action = g.actions[0]
	assert_eq(Policy.disrupt_score(sk, g), 10.0 * Policy.HULL_WEIGHT, "the roar is quieter than the blow")
	assert_eq(Policy.disrupt_score(sk, sk.front[1]), 0.0, "a foe with only its blow cannot be moved")


func test_the_bot_weighs_a_blow_at_every_machine_on_each_and_no_lure_turns_it() -> void:
	var sk := Skirmish.new(2, 2)
	var tank := _mech("Tank", Die.single(Face.attack(0, I, K.LURE)), 40, 200)
	var glass := _mech("Glass", Die.single(Face.blank()), 0, 10)
	sk.add_mech(tank)
	sk.add_mech(glass)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	var storm: Foe = sk.front[0]
	storm.actions = [{"id": "storm", "name": "Storm", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": ["all"], "text": ""},
		{"id": "roar", "name": "Roar", "kind": "debuff", "effect": "drain_rerolls", "value": 1, "weight": 1, "text": ""}]
	storm.action = storm.actions[0]
	storm.target = sk.mechs[1]   # named the glass, for a lure to have something to turn
	assert_eq(Policy.disrupt_score(sk, storm), 20.0 * Policy.HULL_WEIGHT, "turning it to its roar saves the blow on both machines")
	var pol := Policy.make(Policy.GREEDY)
	assert_eq(pol.lure_score(sk, sk.mechs[0], [storm]), 0.0, "a lure saves nothing: the blow lands on both whoever it names")
	assert_true(sk.forecast(sk.mechs[1], false)["destroyed"], "the glass is wrecked by it either way, the forecast says")
	assert_eq(sk.incoming_for(sk.mechs[0]), 10, "and the tank takes it too")


func test_greedy_values_the_spill_behind_a_dying_foe() -> void:
	var sk := Skirmish.new(1, 1)
	var plain := Face.attack(50, L)
	var ram := Face.attack(50, L, K.SPILLOVER)
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


func test_greedy_values_a_cleanse_where_there_is_something_to_clear() -> void:
	var sk := Skirmish.new(1)
	var plain := Face.vent(20)
	var scrub := Face.vent(20)
	scrub.add_keyword(K.CLEANSE)
	var m := _mech("A", Die.of([plain, scrub, Face.attack(20, L)]), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(pol.equipment_score(sk, ms, ms, scrub), pol.equipment_score(sk, ms, ms, plain), "nothing to clear: a cleanse vent is a vent")
	Effects.corrupt_entry(m, 2, "foe:x", 2)
	assert_true(pol.equipment_score(sk, ms, ms, scrub) > pol.equipment_score(sk, ms, ms, plain), "a corrupted gun makes the cleanse worth more")
	Effects.disable_entry(m, 2, "cooldown", sk.round)
	var before := pol.cleanse_score(sk, ms)
	Effects.disable_entry(m, 2, "foe:x", sk.round + 1)
	assert_true(pol.cleanse_score(sk, ms) > before, "a foe's disable is worth clearing, a cooldown is not")


func test_greedy_values_a_shock_by_the_doubled_blow_to_come() -> void:
	var sk := Skirmish.new(1, 1)
	var projector := Face.attack(0, L, K.SHOCK)
	var plain := Face.attack(0, L)
	var m := _mech("A", Die.of([projector, plain]), 40, 100)
	sk.add_mech(m)
	sk.add_mech(_mech("B", Die.single(Face.attack(30, L)), 40, 100))
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(pol.attack_score(sk, ms, plain, g), 0.0, "an entry of no damage is worth nothing")
	assert_true(pol.attack_score(sk, ms, projector, g) > 0.0, "a shock is worth the team's next blow again")
	Effects.stack(g, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_eq(pol.attack_score(sk, ms, projector, g), 0.0, "and nothing on a foe already carrying one")


## 23 October: a Shock is worth the blow it will double, the biggest an ally still to act shows
## on that foe, so a projector of no damage beside a big gun survives the rerolls every rung
## shares; with no hitter in hand it falls back to the team's average blow and reads as the
## bad roll it then is.
func test_a_shock_is_worth_the_hitter_in_hand_and_survives_the_rerolls() -> void:
	var sk := Skirmish.new(1, 1)
	var projector := Face.attack(0, L, K.SHOCK)
	sk.add_mech(_mech("A", Die.of([projector, Face.attack(10, L)]), 40, 100))
	sk.add_mech(_mech("B", Die.single(Face.attack(30, L)), 40, 100))
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 0   # the projector
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(pol.shock_cash(sk, ms, g), 30.0, "the hitter in hand is the blow a shock doubles")
	assert_true(pol.face_value(sk, ms, projector) > pol.reroll_worth(sk, ms), "so the projector beats its die's average")
	pol._greedy_rerolls(sk)
	assert_eq(sk.mechs[0].face_index, 0, "and is kept through the rerolls")

	var lone := Skirmish.new(1, 1)
	lone.add_mech(_mech("A", Die.of([projector, Face.attack(10, L)]), 40, 100))
	lone.add_mech(_mech("B", Die.single(Face.shield(20)), 40, 100))
	var h := _ghoul(500, 10)
	lone.add_foes([h])
	lone.begin()
	lone.start_round()
	lone.mechs[0].face_index = 0
	var pol2 := Policy.make(Policy.GREEDY)
	var ms2: Skirmish.MechState = lone.mechs[0]
	assert_eq(pol2.shock_cash(lone, ms2, h), Policy._team_raw_attack_mean(lone), "no hitter in hand: the team's average blow")
	pol2._greedy_rerolls(lone)
	assert_true(lone.mechs[0].face_index != 0, "and the projector is rerolled for the gun")


func test_greedy_rolls_before_it_spends_a_sure_number() -> void:
	# Ryan, 9 October: a sure number is worth most after the rolls have landed, when it can
	# finish what they left; the bot spends rolled damage first and the flat finisher after.
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("Sure", Die.single(Face.attack(15, L))))
	sk.add_mech(_mech("Rolls", Die.single(Face.attack(10, L, [], 0, 20))))
	var small := _ghoul(15, 10)
	sk.add_foes([small, _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Policy.make(Policy.GREEDY).play_round(sk)
	var first := ""
	for line in sk.log:
		if str(line).contains(" hits "):
			first = str(line)
			break
	assert_true(first.begins_with("Rolls hits"), "the rolled die goes first: %s" % first)
	assert_false(small.alive(), "and the sure one finishes whatever the roll left")


## The funnel-web's valuations (18 October): an ambush bite on a foe looking away is worth
## Vitriol's ticks on what the blow leaves, as the engine ticks it; a web the blows its burst
## will stop.
func test_greedy_bites_the_foe_looking_away() -> void:
	var ambush := {"id": "ambush_t", "name": "Ambush", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1, "when": "target_no_intent"}]}
	var sk := Skirmish.new(3, 2)
	var a := _mech("A", Die.single(Face.attack(10, L)), 0, 500)
	a.grant_passive(ambush)
	var b := _mech("B", Die.single(Face.shield(10)), 40, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var looking := _ghoul(200, 10)
	var away := _ghoul(200, 10)
	sk.add_foes([looking, away])
	sk.begin()
	sk.start_round()
	looking.target = sk.mechs[0]
	away.target = sk.mechs[1]
	var pol := Policy.make(Policy.GREEDY)
	var f := a.die.faces[0]
	assert_true(pol.attack_score(sk, sk.mechs[0], f, away) > pol.attack_score(sk, sk.mechs[0], f, looking), "the foe looking away is worth the bite")
	var share := Effects.status_value("vitriol", "tick_hp_share")   # the status's number, a field the loops move
	var hp := 138
	var due := 0
	for stacks in [3, 2, 1]:
		var tick: int = hp * share * int(stacks) / 100
		due += tick
		hp -= tick
	assert_eq(int(Policy.dot_payout("vitriol", 3, 138)), due, "a bite's three stacks on 138 HP: the share a stack, three ticks, each on what the last left")
	assert_eq(int(Policy.dot_payout("burning", 3, 500)), 6, "Burning's flat ticks: three, two, one stacks of a point (18 October)")
	pol.play_round(sk)
	assert_eq(Effects.stacks_of(away, "vitriol"), 1, "and the die went there")
	assert_eq(Effects.stacks_of(looking, "vitriol"), 0, "not on the one looking")


func test_greedy_values_a_web_by_the_blows_its_burst_stops() -> void:
	var sk := Skirmish.new(3, 3)
	var a := _mech("A", Die.single(Face.attack(0, L, K.WEB)), 0, 500)
	sk.add_mech(a)
	var small := _ghoul(500, 10)
	var mid := _ghoul(500, 20)
	var big := _ghoul(500, 40)
	sk.add_foes([small, mid, big])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	assert_eq(pol.web_score(sk, big), 60.0 * Policy.HULL_WEIGHT, "a web on the big one: its own next blow and the middle one's, caught beside it")
	assert_eq(pol.web_score(sk, small), 30.0 * Policy.HULL_WEIGHT, "on the small one: its own and the middle one's to its left, which has acted")
	Effects.grant_for_rounds(big, Effects.STATUS["suppressed"], "mech", sk.round)
	assert_eq(pol.web_score(sk, big), 20.0 * Policy.HULL_WEIGHT, "a stunned foe gains nothing from the burst on itself: the catch alone")
	Effects.remove(big, "suppressed")
	pol.play_round(sk)
	assert_true(Effects.has(big, "webbed"), "greedy webs the big one")
	assert_eq(pol.web_score(sk, big), 0.0, "and a web on a webbed foe is worth nothing more")


## Flak (21 October): the bot values it as damage in hand for the team's blows still to come,
## so a Flak spray beats the same spray without it while the team has blows to land, and is
## worth less once the team has spent.
func test_greedy_values_flak_by_the_team_blows_still_to_come() -> void:
	var sk := Skirmish.new(3)
	var flak := Face.attack(5, L, K.FLAK)
	flak.flak = 3
	var plain := Face.attack(5, L)
	sk.add_mech(_mech("A", Die.single(flak), 0, 200))
	sk.add_mech(_mech("B", Die.single(Face.attack(10, L)), 0, 200))
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var with := pol.attack_score(sk, sk.mechs[0], flak, sk.front[0])
	var without := pol.attack_score(sk, sk.mechs[0], plain, sk.front[0])
	assert_true(with > without, "Flak is worth the team's blows still to come")
	sk.mechs[1].assigned = true
	var spent := pol.attack_score(sk, sk.mechs[0], flak, sk.front[0])
	assert_true(spent < with and spent > without, "less once the team has spent, and the halved stacks still count for next round")


## A Barrier and a Ward (21 October) are worth what the forecast keeps with them up: the
## Barrier the one big blow, the Ward a breach's needles and their riders; nothing a second time.
func test_greedy_values_a_barrier_by_the_blow_it_takes_and_a_ward_by_what_it_turns_away() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var wall := Face.buff("barrier")
	var ward := Face.buff("ward")
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.of([wall, ward, Face.attack(10, L)]), 20, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 60)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(pol.equipment_score(sk, ms, ms, wall) > 0.0, "a Barrier against a blow of sixty is worth the forty it keeps off the hull")
	assert_eq(pol.equipment_score(sk, ms, ms, ward), 0.0, "and a Ward against a plain blow nothing")
	Effects.grant_buff(m, "barrier", 1, "test", sk.round)
	assert_eq(pol.barrier_score(sk, ms), 0.0, "a second Barrier adds nothing")
	var s2 := Skirmish.new(1)
	var n := _mech("B", Die.of([wall, ward, Face.attack(10, L)]), 40, 100)
	s2.add_mech(n)
	var needler := _ghoul(500, 10)
	needler.actions[0]["strikes"] = 4
	needler.actions[0]["keywords"] = ["breach", "scorch"]
	s2.add_foes([needler])
	s2.begin()
	s2.start_round()
	var ns: Skirmish.MechState = s2.mechs[0]
	assert_true(pol.equipment_score(s2, ns, ns, ward) > pol.equipment_score(s2, ns, ns, wall), "four breaching needles: the Ward, which lets the shield take them all and turns their scorch away")
	assert_true(pol.equipment_score(s2, ns, ns, wall) > 0.0, "though the Barrier still takes one")


## A printed cooldown costs its entry the rounds it stays dark after this one (21 October),
## the share of the die's rolls it would have shown; Rapid's switch-off costs nothing.
func test_greedy_prices_a_printed_cooldown_by_the_rounds_it_stays_dark() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1)
	var plain := Face.attack(30, L)
	var slow := Face.attack(30, L)
	slow.cooldown = 3
	var zap := Face.attack(30, L, [K.RAPID])
	sk.add_mech(_mech("A", Die.of([plain, slow, Face.attack(10, L), Face.attack(10, L)]), 40, 100))
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var base := pol.attack_score(sk, ms, plain, sk.front[0])
	assert_true(absf(pol.attack_score(sk, ms, slow, sk.front[0]) - base * 0.5) < 0.01, "two rounds dark after this one on a four-entry die: half its worth")
	assert_eq(Policy.cooldown_cost(ms, zap, base), 0.0, "Rapid's switch-off ends with the round")


## A stepping die's reroll is worth the entry it steps to, known in advance (the Cassowary's
## dial, 21 October), so the greedy bot turns it only toward a better chamber.
func test_greedy_turns_a_stepping_die_toward_a_better_chamber() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.of([Face.attack(10, L), Face.attack(40, L), Face.attack(5, L), Face.attack(5, L)]), 40, 100)
	u.grant_passive({"id": "test_step", "name": "Step", "description": "", "effects": [{"trigger": "static", "effect": "step_die", "value": 1}]})
	sk.add_mech(u)
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_eq(pol.reroll_worth(sk, ms), pol.face_value(sk, ms, ms.die.faces[1]), "the next chamber's worth, not the die's mean")
	pol._greedy_rerolls(sk)
	assert_eq(ms.face_index, 1, "the ten turns to the forty, and the forty holds against a five")
	assert_eq(sk.rerolls_left, 2, "one reroll spent")


## The seal (the Armadillo's Lockdown, valued 21 October): a shield a machine with a seal
## spends on itself is worth the armour it stands behind this round's blows, less its heat.
func test_greedy_values_the_seal_by_the_blows_its_armour_turns() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.of([Face.shield(10), Face.attack(10, L)]), 0, 200)
	u.grant_passive({"id": "test_seal", "name": "Seal", "description": "", "effects": [{"trigger": "static", "effect": "seal_form", "value": 20, "heat": 5}]})
	sk.add_mech(u)
	sk.add_foes([_ghoul(500, 30), _ghoul(500, 30)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(pol.seal_score(sk, ms) > 0.0, "twenty armour against two blows of thirty is worth the forty it keeps off")
	Effects.stack(u, Effects.sealed_status(20, 5), Effects.SKIRMISH, "seal", 1, Effects.DECAY_NONE)
	assert_eq(pol.seal_score(sk, ms), 0.0, "and nothing once sealed")


## A Swap's second target (the Dingo's Combat Translocator, a first reading of 21 October): the
## bot brings a back-rank foe forward, where Direct fire reaches it, rather than sending one back.
func test_greedy_swaps_a_back_foe_forward() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(0, Face.Reach.INDIRECT, [K.SWAP])), 40, 100))
	var front := _ghoul(100, 10)
	var caster := _archer(100, 30)
	sk.add_foes([front, caster])
	sk.begin()
	sk.start_round()
	var opts := pol.options_for(sk, 0)
	assert_true(opts.all(func(o: Dictionary) -> bool: return o.has("second")), "every option carries its second target")
	assert_true(Policy.swap_score(sk, caster, Vector2i(0, caster.column)) > 0.0, "the caster pulled forward is worth something")
	assert_true(Policy.swap_score(sk, front, Vector2i(1, front.column + 1)) < 0.0, "a front foe sent back is a loss")
	pol.play_round(sk)
	assert_eq(caster.rank, 0, "the bot pulls the caster into the front")


## A Swap that bunches (the Dingo's Translocator, 22 October): a foe moved beside another in the
## row an ally's Spread will hit is worth what that Spread then deals past its target; read in a
## what-if, the foes put back; nothing sent off alone, and nothing once the ally has acted.
func test_greedy_swaps_to_bunch_foes_under_an_allys_spread() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("Dingo", Die.single(Face.attack(0, I, [K.SWAP])), 40, 100))
	sk.add_mech(_mech("Sprayer", Die.single(Face.attack(10, L, [K.CLEAVE])), 40, 100))
	var a := _ghoul(100, 10)
	var b := _ghoul(100, 10)
	sk.add_foes([a, b])
	sk.begin()
	sk.start_round()
	sk.front[b.column] = null
	sk._place(b, 0, 3)
	sk._place(a, 0, 0)
	var dingo: Skirmish.MechState = sk.mechs[0]
	assert_true(Policy.bunching_score(sk, dingo, b, Vector2i(0, 1)) > 0.0, "b moved beside a: the Spread reaches both")
	assert_eq([b.rank, b.column, sk.front[3] == b, sk.front[1] == null], [0, 3, true, true], "read in a what-if, the foes put back")
	assert_eq(Policy.bunching_score(sk, dingo, b, Vector2i(1, 3)), 0.0, "sent back alone it bunches nothing")
	var best: Dictionary = {}
	for o in pol.options_for(sk, 0):
		if best.is_empty() or float(o["score"]) > float(best["score"]):
			best = o
	assert_true(sk.assign(0, best["target"], best["second"]), "the bot's best swap is spent")
	assert_true(a.rank == 0 and b.rank == 0 and absi(a.column - b.column) == 1, "and leaves the two side by side under the Spread")
	sk.end_round()
	sk.start_round()
	sk.front[b.column] = null
	sk._place(b, 0, 3)
	assert_true(sk.assign(1, a), "the Sprayer spends first")
	assert_eq(Policy.bunching_score(sk, sk.mechs[0], b, Vector2i(0, 1)), 0.0, "and a swap after it bunches for nobody")


## The boss mechanics for the bot (15 October; valued 22 October): a gathering countdown's blow
## is worth breaking off with a Disrupt, holding a round with a Suppress and ending with a kill,
## at its discount a round still to gather; a part whose fall opens its core is worth a share of
## the core, and nothing once the core is open or while another part keeps it guarded; a last
## act costs its blow on the machines it lands on, so the kill that sets it off is worth less.
func test_greedy_reads_a_countdown_a_core_and_a_last_act() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, I)), 40, 100))
	var lancer := Foe.make("lancer_t", 100, 40)
	var jump := {"id": "jump", "name": "Jump", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "countdown": 2, "text": ""}
	lancer.actions = [jump, {"id": "brace", "name": "Brace", "kind": "defend", "effect": "brace", "value": 1, "weight": 1, "text": ""}]
	var plain := _ghoul(100, 10)
	sk.add_foes([lancer, plain])
	sk.begin()
	sk.start_round()
	lancer.action = jump
	lancer.pending = jump
	lancer.charge = 2
	lancer.target = sk.mechs[0]
	lancer.last_special = ""   # whatever the round drew, the brace is open to a disrupt
	assert_true(lancer.gathering() and not lancer.attacks(), "gathering two rounds, no blow this one")
	var gathered := Policy.countdown_threat(lancer, sk)
	assert_true(is_equal_approx(gathered, 40.0 * 0.75 * 0.75), "its blow at the discount of two rounds: %s" % gathered)
	assert_true(is_equal_approx(Policy.disrupt_score(sk, lancer), gathered * Policy.HULL_WEIGHT), "a Disrupt breaks it off, into a brace")
	assert_true(Policy.suppress_worth(sk, lancer) > 0.0 and Policy.suppress_worth(sk, lancer) < gathered, "a Suppress holds it a round, worth the delay")
	assert_eq(Policy.countdown_threat(plain, sk), 0.0, "a foe gathering nothing")
	var kill := Face.attack(200, I)
	var gun := Face.attack(200, I)
	var with_count := pol.attack_score(sk, sk.mechs[0], kill, lancer)
	lancer.pending = {}
	lancer.charge = 0
	lancer.action = lancer.actions[1]
	assert_true(with_count > pol.attack_score(sk, sk.mechs[0], gun, lancer), "and a kill ends it, worth more than the same kill on a foe gathering nothing")
	# The core: guarded while all its parts stand, any one's fall opens it.
	var s2 := Skirmish.new(1, 3)
	s2.add_mech(_mech("A", Die.single(Face.attack(10, I)), 40, 100))
	var core := Foe.make("hilt", 200, 10)
	core.content_id = "hilt"
	core.part_ids = ["eye", "eye"]
	core.guard = "all"
	var e1 := Foe.make("eye", 20, 5)
	e1.content_id = "eye"
	var e2 := Foe.make("eye", 20, 5)
	e2.content_id = "eye"
	s2.add_foes([core, e1, e2])
	s2.begin()
	s2.start_round()
	assert_true(Effects.has(core, "guarded"), "the core guarded while both stand")
	assert_true(Policy.core_opening(s2, e1) > 0.0, "either part's fall opens it")
	assert_eq(Policy.core_opening(s2, core), 0.0, "the core opens nothing")
	core.guard = "any"
	assert_eq(Policy.core_opening(s2, e1), 0.0, "under any, the other part keeps it guarded")
	e2.hp = 0
	assert_true(Policy.core_opening(s2, e1) > 0.0, "and the last part standing opens it")
	# The last act.
	var s3 := Skirmish.new(1, 3)
	s3.add_mech(_mech("A", Die.single(Face.attack(40, I)), 0, 100))
	var beast := Foe.make("behemoth", 30, 20)
	beast.on_death = {"blow": Foe.death_blow_from({"name": "Meteor", "factor": 1.0, "keywords": ["all"]})}
	var calm := Foe.make("behemoth", 30, 20)
	s3.add_foes([beast, calm])
	s3.begin()
	s3.start_round()
	assert_true(is_equal_approx(Policy.last_act_cost(s3, beast), 20.0 * Policy.HULL_WEIGHT), "its Meteor's twenty on the bare machine")
	assert_eq(Policy.last_act_cost(s3, calm), 0.0, "a foe without one costs nothing")
	beast.target = s3.mechs[0]
	calm.target = s3.mechs[0]
	var f40 := Face.attack(40, I)
	assert_true(pol.attack_score(s3, s3.mechs[0], f40, beast) < pol.attack_score(s3, s3.mechs[0], f40, calm), "the kill that sets off a Meteor is worth less")


## The Lammergeier's mines for the bot (21 October), on a synthetic passive: a mine laid on a
## slot a waiting foe will take is worth its blow there, and nothing with none waiting and no
## pull on the team; the pull on a foe is worth the pile landing in laid order, a Shock shot
## doubling the next; the drone is worth more on a foe already Exposed, its Rapid.
func test_greedy_lays_a_mine_where_a_foe_will_step_in_and_weighs_the_pull_and_the_drone() -> void:
	var bay := {"id": "bay", "name": "Bay", "description": "", "effects": [{"trigger": "static", "effect": "lay_mines"}]}
	var sk := Skirmish.new(3, 2)
	var m := _mech("Bomber", Die.single(Face.attack(20, I)), 40, 100)
	m.grant_passive(bay)
	sk.add_mech(m)
	var wall := _ghoul(500, 0)
	sk.add_foes([wall])
	sk.begin()
	var arrival := _ghoul(100, 10)
	sk.reinforcements.append(arrival)
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	var empty := Vector2i(0, 1) if sk.front[1] == null else Vector2i(0, 0)
	assert_eq(Policy.arrival_odds(sk, empty), 1.0, "the waiting foe takes the empty front slot")
	assert_eq(Policy.arrival_odds(sk, Vector2i(1, empty.y)), 0.0, "no back foe waits")
	assert_true(pol.mine_score(sk, ms, ms.face(), empty) > 0.0, "a mine there is worth its blow")
	var opts := pol.options_for(sk, 0)
	var slots := opts.filter(func(o) -> bool: return o["target"] is Vector2i)
	assert_true(not slots.is_empty(), "the slots are options")
	sk.reinforcements.clear()
	assert_true(pol.mine_score(sk, ms, ms.face(), empty) <= 0.0, "with none waiting and no pull, a mine is worth nothing")
	# The pull on a foe: the pile, read as it will land.
	var pull := Face.attack(0, I)
	pull.pulls_mines = true
	sk.reinforcements.append(arrival)
	assert_true(sk.assign(0, empty), "a mine laid")
	assert_eq(pol.pull_score(sk, wall), 20.0, "the pull on the wall cashes its 20")
	var drone := Face.attack(0, I)
	drone.drones = true
	var s2 := Skirmish.new(3, 2)
	s2.add_mech(_mech("Droner", Die.of([drone, Face.attack(30, L)]), 40, 100))
	var foe := _ghoul(100, 10)
	s2.add_foes([foe])
	s2.begin()
	s2.reinforcements.append(_ghoul(100, 10))
	s2.start_round()
	var d := s2.mechs[0]
	var plain := pol.attack_score(s2, d, drone, foe)
	assert_true(plain > 0.0, "the drone is worth its mine and its Exposed")
	Effects.grant_for_rounds(foe, Effects.STATUS["exposure"], "test", s2.round + 1)
	assert_true(pol.attack_score(s2, d, drone, foe) > 0.0, "and on a foe already Exposed, its Rapid")


## The Swallowtail for the bot (21 October; the charge never primed since 22 October), synthetic:
## the bot weighs the die as it will go out, so with a charge up and an ally yet to act the
## Screens' options are Phased's, and it Phases the ally its blows would kill.
func test_greedy_weighs_the_charged_form_the_die_will_spend() -> void:
	var deck := {"id": "deck", "name": "Deck", "description": "", "effects": [{"trigger": "static", "effect": "muster", "value": 3, "cap": 2, "kill": 2}]}
	var screens := Face.shield(10)
	screens.targets = Face.Target.ALLY
	screens.reaches_all = true
	screens.charged = {"muster": 1, "status": "phased", "reaches_all": true, "not_acted": true}
	var sk := Skirmish.new(3, 2)
	var c := _mech("Carrier", Die.single(screens), 40, 100)
	c.grant_passive(deck)
	sk.add_mech(c)
	var a := _mech("A", Die.single(Face.attack(10, L)), 0, 10)
	sk.add_mech(a)
	sk.add_foes([_ghoul(300, 40), _ghoul(300, 40)])
	sk.begin()
	sk.start_round()
	Effects.stack(c, Effects.STATUS["muster"], Effects.SKIRMISH, "test", 3, Effects.DECAY_NONE)
	for f in sk.field_foes():
		f.target = sk.mechs[1]
	var pol := Policy.make(Policy.GREEDY)
	var opts := pol.options_for(sk, 0)
	assert_false(opts.is_empty(), "the Screens have options")
	assert_eq(sk.spend_face(sk.mechs[0]).buff_status, "phased", "and they are the charged form's")
	pol.play_round(sk)
	assert_true(Effects.has(a, "phased"), "the bot Phases the ally its blows would kill")
	assert_eq(Effects.muster_charges(c), 0, "the charge went with it")


## The Musk Ox for the bot (21 October), synthetic: a forging machine's gun costs its price at
## what an ammo buys; a dry gun is no option; the salvo is worth its strikes on the field.
func test_greedy_prices_a_forged_gun_in_ammo_and_weighs_the_salvo() -> void:
	var forge := {"id": "forge", "name": "Forge", "description": "", "effects": [{"trigger": "static", "effect": "forge", "value": 10, "start": 3, "per_round": 1, "per_heat": 10, "vent": 3, "shield": 2}]}
	var ray := Face.attack(30, L)
	ray.heat = 30
	var salvo := Face.attack(5, I, [K.CLEAVE, K.PENETRATE])
	salvo.spends_magazine = true
	salvo.random_targets = true
	var sk := Skirmish.new(3, 2)
	var m := _mech("Ox", Die.of([ray, salvo]), 40, 200)
	m.grant_passive(forge)
	sk.add_mech(m)
	sk.add_foes([_ghoul(300, 0), _ghoul(300, 0)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(pol.ammo_worth(sk, ms) > 0.0, "an ammo is worth something to a forging machine")
	var free := Policy.make(Policy.GREEDY)
	var plain := _mech("Plain", Die.single(ray.duplicate_face()), 40, 200)
	var s2 := Skirmish.new(3, 2)
	s2.add_mech(plain)
	s2.add_foes([_ghoul(300, 0), _ghoul(300, 0)])
	s2.begin()
	s2.start_round()
	assert_true(pol.attack_score(sk, ms, ray, sk.front[0]) < free.attack_score(s2, s2.mechs[0], ray, s2.front[0]), "the forged gun is worth its blow less its three ammo")
	assert_true(pol.salvo_score(sk, ms, salvo) > 0.0, "three strikes on a full field are worth firing")
	ms.ammo = 0
	ms.face_index = 0
	assert_true(pol.options_for(sk, 0).is_empty(), "a dry gun is no option")
	assert_eq(pol.salvo_score(sk, ms, salvo), -INF, "nor an empty salvo")


## The planner (the stock pass's second chunk, 22 October) rolls a decision out over two rounds
## on copies of the fight. A Shock on either of two foes nobody can hurt again this round is a
## tie on the greedy's one-round read, and the greedy takes the first; the planner places it on
## the foe the next round's blow of thirty kills, doubled, and its rollouts leave the real fight
## as it stood.
func test_the_planner_places_a_setup_where_the_next_round_cashes_it() -> void:
	var shocked := {}
	var lines := {}
	for kind in [Policy.GREEDY, Policy.PLANNER]:
		var sk := Skirmish.new(4, 2)
		sk.add_mech(_mech("A", Die.single(Face.attack(0, L, K.SHOCK)), 40, 300))
		sk.add_mech(_mech("B", Die.single(Face.attack(30, L)), 40, 300))
		sk.add_foes([_ghoul(60, 1), _ghoul(500, 10)])
		sk.begin()
		sk.start_round()
		sk.mechs[1].assigned = true   # B has spent: A's Shock is the round's last die
		var big: Foe = sk.front[0]
		var small: Foe = sk.front[1]
		assert_eq(big.hp, 500, "the heavier hitter stands left, first on the greedy's list")
		var pol := Policy.make(kind, 4)
		var ms: Skirmish.MechState = sk.mechs[0]
		assert_eq(pol.attack_score(sk, ms, ms.face(), big), pol.attack_score(sk, ms, ms.face(), small), "the one-round read ties the two")
		var mark := sk.log.size()
		pol.play_round(sk)
		shocked[kind] = "small" if Effects.has(small, "shocked") else ("big" if Effects.has(big, "shocked") else "none")
		lines[kind] = sk.log.size() - mark
		assert_eq(big.hp + small.hp, 560, "%s: no foe's hit points moved" % Policy.kind_name(kind))
		if kind == Policy.PLANNER:
			assert_eq(pol.plans, 1, "the planner weighed the one decision")
			assert_eq(pol.plan_changes, 1, "and spent otherwise than the greedy")
	assert_eq(shocked[Policy.GREEDY], "big", "the greedy takes the first of the tie")
	assert_eq(shocked[Policy.PLANNER], "small", "the planner shocks the foe the next round kills")
	assert_eq(lines[Policy.PLANNER], lines[Policy.GREEDY], "and the real fight's log holds its one spend, nothing of the rollouts'")


## Blind play (the bible's section 2: "a team that spends each die on the nearest foe"; the rung
## since 22 October): every weapon on the nearest foe, the front rank before the back and left
## before right, whatever a kill elsewhere would give; every piece of equipment on its own
## machine; a die held only where its heat would burn the machine.
func test_blind_play_spends_on_the_nearest_foe_and_its_own_machine() -> void:
	var sk := Skirmish.new(2, 2)
	var gun := _mech("Gun", Die.single(Face.attack(10, L)), 40, 100)
	var wall := _mech("Wall", Die.single(Face.shield(20)), 40, 100)
	var hot := _mech("Hot", Die.single(Face.attack(10, L, K.NONE, 80)), 40, 100)   # eighty heat on a cap of sixty
	gun.shield = 0
	wall.shield = 0
	for u in [gun, wall, hot]:
		sk.add_mech(u)
	sk.add_foes([_ghoul(300, 1), _ghoul(10, 1)])
	sk.begin()
	sk.start_round()
	var near: Foe = sk.front[0]
	var weak: Foe = sk.front[1]
	var pol := Policy.make(Policy.BLIND, 2)
	pol.play_round(sk)
	assert_eq(near.hp, 290, "the gun hit the nearest foe")
	assert_eq(weak.hp, 10, "not the one it could kill")
	assert_eq(wall.shield, 20, "the shield went on its own machine")
	assert_eq(gun.shield, 0, "not on the bare gun beside it")
	assert_false(sk.mechs[2].assigned, "the hot gun was held")
	assert_eq(Policy.kind_name(Policy.BLIND), "blind", "the rung's name, as the runner reads it")
	assert_eq(Policy.kind_name(Policy.PLANNER), "planner", "and the planner's")


## The bot reads a Gel's pair as the resolver does (26 October): a Spread filling the hopper
## beside a twin slot loads for both halves.
func test_the_bot_counts_both_halves_of_a_pair() -> void:
	var sk := Skirmish.new(3, 3)
	var fill := Face.attack(3, L, K.CLEAVE)
	fill.fills_hopper = 1
	var fire := Face.attack(3, L)
	fire.fires_hopper = 6
	fire.power_per_load = 1
	sk.add_mech(_mech("A", Die.of([fill, fire])))
	var target := _ghoul(500, 10)
	sk.add_foes([target, _ghoul(400, 10)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var pol := Policy.make(Policy.GREEDY)
	var plain := pol.hopper_fill_score(sk, ms, fill, target)
	var lead: Foe = sk.front[1]
	sk._set_contents(Vector2i(0, 1), [lead, _ghoul(5, 2)])
	assert_true(pol.hopper_fill_score(sk, ms, fill, target) > plain, "the pair beside it loads twice")

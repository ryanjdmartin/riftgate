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


## The Nemesis's rage (12 October): a stack to spend is another roll of the die, worth about
## the die's own average blow, and a bite of its own costs less when the hull it takes banks
## a stack the die can spend.
func test_greedy_values_rage_as_another_roll() -> void:
	var fist := Face.attack(10, L)
	fist.rolls_again_on = "rage"
	var gun := Face.attack(20, L, K.VOLATILE)
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
	Effects.disable_entry(m, 2, "rapid", sk.round)
	var before := pol.cleanse_score(sk, ms)
	Effects.disable_entry(m, 2, "foe:x", sk.round + 1)
	assert_true(pol.cleanse_score(sk, ms) > before, "a foe's disable is worth clearing, a rapid switch-off is not")


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
	assert_eq(int(Policy.dot_payout("vitriol", 3, 138)), 36, "a Maxigun bite's three stacks on a 160-hull boss that took 22: about 36 over its next three actions")
	assert_eq(int(Policy.dot_payout("burning", 3, 500)), 30, "Burning's flat ticks: three, two, one stacks of five")
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

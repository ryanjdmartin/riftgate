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
	assert_true(sk.forecast(sk.mechs[1])["destroyed"], "the ghoul would wreck the weak machine")
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
	assert_eq(int(sk.forecast(sk.mechs[0])["overheat"]), 20, "twenty would burn at the round's end")
	Policy.make(Policy.GREEDY).play_round(sk)
	assert_eq(sk.mechs[0].heat, 50, "vented")
	sk.end_round()
	assert_eq(hot.hull, 100, "no burn: the vent was spent on the one who needed it")


## The cautious persona (30 October, the heat report's): heat above its line is priced as an
## overheat's hull, so a vent is worth taking where no overheat looms, and a hot spend above
## the line costs what an overheat would; the rungs as they are pay nothing under the cap.
func test_the_cautious_persona_prices_heat_above_its_line() -> void:
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("Hot", Die.single(Face.vent(30)), 40, 100))
	sk.add_foes([_ghoul(300, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 45   # under the cap of sixty: no overheat looms
	assert_eq(int(sk.forecast(ms)["overheat"]), 0, "nothing would burn")
	var plain := Policy.make(Policy.GREEDY)
	var careful := Policy.make(Policy.GREEDY)
	careful.cool_above = 50
	assert_eq(plain.caution_line(ms), -1, "the persona off")
	assert_eq(careful.caution_line(ms), 30, "half of sixty")
	assert_true(absf(careful.vent_score(sk, ms, 30) - plain.vent_score(sk, ms, 30) - 15.0 * Policy.HULL_WEIGHT) < 0.001, "the vent's worth gains the fifteen over the line, as hull")
	assert_true(absf(careful.vent_score(sk, ms, 10) - plain.vent_score(sk, ms, 10) - 10.0 * Policy.HULL_WEIGHT) < 0.001, "a smaller vent, what it takes off")
	var gun := Face.attack(10, L, [], 8)
	assert_eq(plain.heat_cost(sk, ms, gun), 0.0, "the greedy pays nothing under the cap")
	assert_eq(careful.heat_cost(sk, ms, gun), 8.0 * Policy.HULL_WEIGHT, "the persona pays for every point above its line")
	ms.heat = 26
	assert_eq(careful.heat_cost(sk, ms, gun), 4.0 * Policy.HULL_WEIGHT, "from under the line, only the part past it")


## The overheat's what-if switch (30 October): the bot prices an overheat at the hull it burns, on
## the spend that causes it and on the vent that saves it.
func test_the_bot_prices_an_overheat_at_its_burn() -> void:
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("Hot", Die.single(Face.vent(30)), 40, 100))
	sk.add_foes([_ghoul(300, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var pol := Policy.make(Policy.GREEDY)
	var gun := Face.attack(10, L, [], 10)
	ms.heat = 55   # the gun would end the turn five past the cap of sixty
	var cost_plain := pol.heat_cost(sk, ms, gun)
	ms.heat = 70   # ten past it: the vent of ten saves the whole burn
	var vent_plain := pol.vent_score(sk, ms, 10)
	Skirmish.overheat_scale = 2
	var vent_doubled := pol.vent_score(sk, ms, 10)
	ms.heat = 55
	var cost_doubled := pol.heat_cost(sk, ms, gun)
	Skirmish.overheat_scale = 1
	assert_true(absf(cost_plain - 5.0 * Policy.HULL_WEIGHT) < 0.001, "five past the cap, one for one: %f" % cost_plain)
	assert_true(absf(cost_doubled - 10.0 * Policy.HULL_WEIGHT) < 0.001, "doubled, the hull it burns: %f" % cost_doubled)
	assert_true(absf(vent_doubled - vent_plain - 10.0 * Policy.HULL_WEIGHT) < 0.001, "the vent saves twice the hull")


## The overheat's other what-ifs priced (30 October): the spend that takes the burn to the injury
## threshold pays for the component it burns out, and the one that starts an overheat for the
## corruption it lays; nothing while both are off.
func test_the_bot_prices_a_burnout_and_an_overheats_corruption() -> void:
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("Hot", Die.of([Face.vent(30), Face.attack(10, L, [], 10)]), 40, 100))
	sk.add_foes([_ghoul(300, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var pol := Policy.make(Policy.GREEDY)
	assert_eq(pol.overheat_marks_cost(ms, 0, 30), 0.0, "both off: nothing")
	Skirmish.overheat_burnout = true
	var burnt := pol.overheat_marks_cost(ms, 0, 30)
	var short := pol.overheat_marks_cost(ms, 0, 20)
	var already := pol.overheat_marks_cost(ms, 25, 30)
	Skirmish.overheat_burnout = false
	Skirmish.overheat_corrupt = 1
	var corrupt := pol.overheat_marks_cost(ms, 0, 5)
	var again := pol.overheat_marks_cost(ms, 5, 10)
	Skirmish.overheat_corrupt = 0
	assert_true(absf(burnt - Policy.DEATH_WEIGHT / 2.0) < 0.001, "thirty past the cap on a 100-hull machine reaches the quarter: half the machine's worth on a die of two: %f" % burnt)
	assert_eq(short, 0.0, "twenty burns short of the quarter")
	assert_eq(already, 0.0, "a burnout the turn was making anyway costs this spend nothing")
	assert_true(corrupt > 0.0, "the spend that starts the overheat pays for its corruption")
	assert_eq(again, 0.0, "one overheat a turn: a spend that only deepens it lays no more")


## The shield persona (30 October, the support ladders' bot): a shield left standing past this
## round's blows is worth the hull it turns next round, the foes' blows on an average machine at
## a share for the round away, where the rungs bank it at a fifth of a point.
func test_the_shield_persona_values_a_standing_shield_by_next_rounds_blows() -> void:
	var sk := Skirmish.new(3)
	var a := _mech("A", Die.single(Face.shield(8)), 40, 100)
	a.shield = 0
	sk.add_mech(a)
	sk.add_mech(_mech("B", Die.single(Face.attack(5, L)), 40, 100))
	var g := _ghoul(300, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	g.target = sk.mechs[1]   # the blow this round falls on the other machine: the shield on A saves nothing now
	var ms: Skirmish.MechState = sk.mechs[0]
	var plain := Policy.make(Policy.GREEDY)
	var ahead := Policy.make(Policy.GREEDY)
	ahead.shield_ahead = true
	assert_true(absf(ahead.next_round_hull(sk, ms) - 5.0) < 0.001, "a blow of ten over two machines")
	var p := plain.shield_score(sk, ms, 8)
	var q := ahead.shield_score(sk, ms, 8)
	assert_true(absf(p - 8.0 * Policy.BANK_WEIGHT) < 0.001, "the rungs bank the eight: %f" % p)
	assert_true(absf(q - (5.0 * Policy.HULL_WEIGHT * Policy.AHEAD_SHARE + 3.0 * Policy.BANK_WEIGHT)) < 0.001, "the persona: five of it turns next round's blow, the rest banks: %f" % q)
	# Next round's blow is the roll's mean, not this round's pick (2 November): a brace at the
	# same weight halves it, and a blow on every machine lands whole at its weight.
	g.actions.append({"id": "cower", "kind": "defend", "effect": "brace", "value": 2, "weight": 1})
	assert_true(absf(ahead.next_round_hull(sk, ms) - 2.5) < 0.001, "ten over two machines at one weight, nothing at the other: %f" % ahead.next_round_hull(sk, ms))
	g.actions.append({"id": "sweep", "factor": 1.0, "strikes": 1, "weight": 2, "keywords": ["all"]})
	assert_true(absf(ahead.next_round_hull(sk, ms) - 6.25) < 0.001, "the sweep's ten whole at two weights of four: %f" % ahead.next_round_hull(sk, ms))
	g.actions.append({"id": "wind_up", "factor": 3.0, "strikes": 1, "weight": 1, "keywords": [], "then": "sweep"})
	assert_true(absf(ahead.next_round_hull(sk, ms) - 20.0 / 3.0) < 0.001, "the wind-up's thirty over two beside the ten over two and the brace, three weights, its follow-up (the sweep) never rolled: %f" % ahead.next_round_hull(sk, ms))


## The aggressor's habit (the refit pass, 9 November): a block is worth a share of what the rung
## reads, so the bot rerolls it away for a gun and spends one only when its die is stuck showing
## it; a buff that is no block keeps its worth. The hull the blocks keep is read as the gap
## between the two.
func test_the_aggressor_values_a_block_at_a_share_and_never_rerolls_for_one() -> void:
	var wall := Face.buff("barrier")
	var coil := Face.buff("overcharged", 2)
	assert_true(Policy.is_block(wall) and Policy.is_block(Face.buff("braced", 2)) and Policy.is_block(Face.buff("ward")) and Policy.is_block(Face.buff("phased")), "a Barrier, Armoured, a Ward and Phased are blocks")
	assert_false(Policy.is_block(coil) or Policy.is_block(Face.attack(10, L)) or Policy.is_block(Face.shield(8)) or Policy.is_block(null), "a damage buff, a gun and a shield are none")
	var gun := Face.attack(10, L)
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.of([wall, coil, gun]), 20, 100))
	sk.add_foes([_ghoul(500, 60)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var plain := Policy.make(Policy.GREEDY)
	var bold := Policy.make(Policy.GREEDY)
	bold.guard_weight = 0.05
	var p := plain.machine_spend_score(sk, ms, ms, wall)
	assert_true(p > plain.attack_score(sk, ms, gun, sk.front[0]), "the rung takes the Barrier over its gun against a blow of sixty: %f" % p)
	assert_true(absf(bold.machine_spend_score(sk, ms, ms, wall) - p * 0.05) < 0.001, "the aggressor reads it at its share")
	assert_eq(bold.machine_spend_score(sk, ms, ms, coil), plain.machine_spend_score(sk, ms, ms, coil), "a buff that is no block at its whole worth")
	# A die of the Barrier and a gun (a reroll never lands on the same entry): the rung ends every
	# round behind the Barrier, the aggressor on the gun, and it pays the blow for it.
	for seed in range(1, 9):
		for habit in [1.0, 0.05]:
			var s2 := Skirmish.new(seed)
			var m := _mech("B", Die.of([wall, gun]), 20, 100)
			s2.add_mech(m)
			var g := _ghoul(500, 60)
			s2.add_foes([g])
			s2.begin()
			s2.start_round()
			var pol := Policy.make(Policy.GREEDY, seed)
			pol.guard_weight = habit
			pol.play_round(s2)
			s2.end_round()
			if habit == 1.0:
				assert_eq([m.hull, g.hp], [100, 500], "seed %d: the rung's Barrier takes the blow whole, and nothing is fired" % seed)
			else:
				assert_eq([m.hull, g.hp], [60, 490], "seed %d: the aggressor fires, and the sixty lands on its twenty of shield" % seed)
	# Stuck with it, the aggressor spends it all the same: a die of the Barrier alone.
	var s3 := Skirmish.new(2)
	var lone := _mech("C", Die.single(wall), 20, 100)
	s3.add_mech(lone)
	s3.add_foes([_ghoul(500, 60)])
	s3.begin()
	s3.start_round()
	var stuck := Policy.make(Policy.GREEDY, 2)
	stuck.guard_weight = 0.05
	stuck.play_round(s3)
	s3.end_round()
	assert_eq(lone.hull, 100, "the block it could not reroll away is still spent")


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
	assert_true(pol.stalemate, "and a stalemate: nothing changed for ten rounds running (the long wall brief, section 5)")


## A fight that moves every round is no stalemate, however long (the long wall brief, section 5:
## ten rounds running with no foe's HP, no machine's hull or shield changed).
func test_a_fight_that_moves_is_no_stalemate() -> void:
	var u := _mech("A", Die.single(Face.attack(1, L)), 0, 900)
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([_ghoul(40, 1)])
	sk.begin()
	var pol := Policy.make(Policy.GREEDY)
	pol.play(sk)
	assert_true(pol.rounds > Policy.STALEMATE_ROUNDS, "a long fight")
	assert_false(pol.stalemate, "that moved every round")


## The fight bot plays a losing fight to its end (the long wall brief 3.5: there is no
## withdrawal, and the withdrawing persona went with it).
func test_the_fight_bot_plays_a_losing_fight_to_its_end() -> void:
	var sk := Skirmish.new(2)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 0, 100))
	sk.add_foes([_ghoul(300, 30)])
	sk.begin()
	var pol := Policy.make(Policy.GREEDY)
	var outcome := pol.play(sk)
	assert_eq(outcome, Skirmish.Outcome.DEFEAT, "fought to the wreck")
	assert_true(sk.mechs[0].unit.hull <= 0, "nothing left of it")


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
	var bomb := Face.attack(3, L)
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
	var bomb2 := Face.attack(3, L)
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
	var gun := Face.attack(20, L)
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


## A flat buff lands on every strike, so the bot counts Empowered once a strike of the ally's
## gun showing: twice on a split gun (the Skua's), once on a plain one.
func test_greedy_counts_a_flat_buff_once_a_strike_of_the_allys_gun() -> void:
	var split := {"id": "split", "name": "Split", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "split_strikes", "value": 2}]}
	var sk := Skirmish.new(1, 2)
	var coil := Face.buff("overcharged", 2)
	var plain := _mech("P", Die.single(Face.attack(4, L)), 40, 100)
	var skua := _mech("S", Die.single(Face.attack(4, L)), 40, 100)
	skua.grant_passive(split)
	sk.add_mech(_mech("B", Die.single(coil), 40, 100))
	sk.add_mech(plain)
	sk.add_mech(skua)
	sk.add_foes([_ghoul(100, 10), _ghoul(100, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var on_plain := pol.buff_score(sk, sk.mechs[1], coil)
	var on_skua := pol.buff_score(sk, sk.mechs[2], coil)
	assert_true(on_plain > 0.0, "worth something on a gun showing")
	assert_true(absf(on_skua - 2.0 * on_plain) < 0.001, "twice as much on a gun that strikes twice")


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


## A rallier's threat is what its rally adds to the blows after it this round (26 October), so
## killing, Suppressing or Disrupting it weighs the fodder it lifts, and the forecast reads the
## lifted blows.
func test_the_bot_reads_a_rallier_by_the_blows_its_rally_lifts() -> void:
	var sk := Skirmish.new(3, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 0, 300))
	var lord := _ghoul(500, 50)
	var howl := {"id": "howl", "name": "Howl", "kind": "buff", "effect": "rally", "value": 5, "weight": 1, "text": ""}
	lord.actions = [Foe.basic_action(), howl]
	sk.add_foes([lord, _ghoul(500, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.front[0] == lord, "the rallier acts first")
	lord.action = howl
	assert_eq(sk.incoming_for(sk.mechs[0]), 30, "the forecast reads both lifted blows")
	assert_eq(Policy._threat_now(lord, sk), 10.0, "the rallier threatens what its rally adds: 5 on each of two blows")
	assert_eq(Policy.suppress_worth(sk, lord), 10.0, "and a Suppress on it is worth that")
	assert_eq(Policy.disrupt_score(sk, lord), 0.0, "a Disrupt turning it to its 50 is worth nothing")
	lord.action = lord.actions[0]
	assert_eq(Policy._threat_now(lord, sk), 50.0, "on its blow it threatens its blow")


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
	assert_true(sk.forecast(sk.mechs[1])["destroyed"], "the glass is wrecked by it either way, the forecast says")
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
	assert_eq(pol.machine_spend_score(sk, ms, ms, scrub), pol.machine_spend_score(sk, ms, ms, plain), "nothing to clear: a cleanse vent is a vent")
	Effects.corrupt_entry(m, 2, "foe:x", 2)
	assert_true(pol.machine_spend_score(sk, ms, ms, scrub) > pol.machine_spend_score(sk, ms, ms, plain), "a corrupted gun makes the cleanse worth more")
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


## The funnel-web's valuations (18 October): an ambush bite on a foe looking away is worth
## Vitriol's ticks on what the blow leaves, as the engine ticks it; a web the blows its burst
## will stop.
func test_greedy_bites_the_foe_looking_away() -> void:
	var ambush := {"id": "ambush_t", "name": "Ambush", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1, "when": "target_no_intent", "damaging": true}]}
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
	assert_true(pol.machine_spend_score(sk, ms, ms, wall) > 0.0, "a Barrier against a blow of sixty is worth the forty it keeps off the hull")
	assert_eq(pol.machine_spend_score(sk, ms, ms, ward), 0.0, "and a Ward against a plain blow nothing")
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
	assert_true(pol.machine_spend_score(s2, ns, ns, ward) > pol.machine_spend_score(s2, ns, ns, wall), "four breaching needles: the Ward, which lets the shield take them all and turns their scorch away")
	assert_true(pol.machine_spend_score(s2, ns, ns, wall) > 0.0, "though the Barrier still takes one")


## The bot's read of a foe's four buffs (the ladder's brief, B; 28 October; placeholders): a
## sheltering foe threatens the biggest weapon blow a machine still to act shows on it, a warding
## one nothing, a stoker 2 a stack on every other foe it primes, a knitter its value for each of
## three actions, a primed foe its blow and 2 a stack; a Barrier eats a weapon's first blow in the
## damage read, and a Ward leaves the marks a blow would lay worth nothing.
func test_the_bot_reads_a_foes_barrier_ward_priming_and_regrowth() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1, 3)
	var gun := Face.attack(10, L)
	var torch := Face.attack(10, L, [K.BURN])
	torch.burn = 3
	sk.add_mech(_mech("A", Die.single(gun), 40, 200))
	sk.add_mech(_mech("B", Die.single(torch), 40, 200))
	var caster := Foe.make("caster", 500, 1)
	var g1 := _ghoul(500, 10)
	var g2 := _ghoul(500, 10)
	sk.add_foes([caster, g1, g2])
	sk.begin()
	sk.start_round()
	var moves := {"barrier": ["defend", 0], "ward_all": ["buff", 0], "prime": ["buff", 2], "regenerate": ["defend", 4]}
	var worth := {}
	for effect in moves:
		caster.action = {"id": effect, "name": effect, "kind": moves[effect][0], "effect": effect, "weight": 1, "text": ""}
		if int(moves[effect][1]) > 0:
			caster.action["value"] = int(moves[effect][1])
		worth[effect] = Policy._threat_now(caster, sk)
	assert_eq(worth["barrier"], 10.0, "a Barrier: the biggest weapon blow a machine still to act shows on it")
	assert_eq(worth["ward_all"], 0.0, "a Ward: nothing")
	assert_eq(worth["prime"], 8.0, "a priming: 2 a stack, two stacks on each of two others")
	assert_eq(worth["regenerate"], 12.0, "a regrowth: its value for each of three actions")
	var plain := Policy._threat_now(g1, sk)
	Effects.grant(g1, Effects.primed_foe(3, "foe:caster"))
	assert_eq(Policy._threat_now(g1, sk), plain + 6.0, "a primed foe threatens its blow and 2 a stack")
	var a: Skirmish.MechState = sk.mechs[0]
	var b: Skirmish.MechState = sk.mechs[1]
	Effects.stack(g1, Effects.foe_barrier(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	assert_eq(pol.expected_damage(a, gun, g1), 0.0, "a Barrier eats a weapon's first blow")
	var twice := Face.attack(10, L)
	twice.strikes = 2
	assert_eq(pol.expected_damage(a, twice, g1), 10.0, "and the second lands")
	var bare := pol.attack_score(sk, b, torch, g2)
	var bare_gun := pol.attack_score(sk, a, gun, g2)
	Effects.stack(g2, Effects.foe_ward(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	assert_true(pol.attack_score(sk, b, torch, g2) < bare, "a Ward leaves the Burn worth nothing")
	assert_eq(pol.attack_score(sk, a, gun, g2), bare_gun, "and a plain gun as it was")


## The bot's worth of the player's Purge (the ladder's brief, C; 28 October; placeholders), by
## what the foe carries: Undying its maximum HP whatever the blow does, a Barrier the
## biggest weapon blow an ally still to act shows on it (nothing when its own weapon pops it),
## Armoured its stacks for each allied blow to come, Empowered its value, Primed 2 a stack,
## Regenerating its value for each action left, a Ward nothing, a bare foe nothing; the attack
## score carries it.
func test_the_bot_prices_a_purge_by_what_the_foe_carries() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1, 3)
	var null_field := Face.attack(0, I, [K.DISPEL])
	null_field.dispel = 9
	var gun := Face.attack(10, L, [K.DISPEL])
	gun.dispel = 9
	var null1 := Face.attack(0, I, [K.DISPEL])   # Purge 1
	sk.add_mech(_mech("A", Die.single(null_field), 40, 200))
	sk.add_mech(_mech("B", Die.single(Face.attack(12, L)), 40, 200))
	var g := _ghoul(100, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	var a: Skirmish.MechState = sk.mechs[0]
	assert_eq(pol.purge_worth(sk, a, null_field, g, 1.0), 0.0, "a bare foe: nothing")
	Effects.stack(g, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:revenant", 1, Effects.DECAY_NONE)
	assert_eq(pol.purge_worth(sk, a, null_field, g, 0.0), 100.0, "Undying: its maximum HP, whatever the blow")
	Effects.remove(g, "risen")
	Effects.stack(g, Effects.foe_barrier(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	assert_eq(pol.purge_worth(sk, a, null_field, g, 1.0), 12.0, "a Barrier: the biggest weapon blow an ally still to act shows on it")
	assert_eq(pol.purge_worth(sk, a, gun, g, 1.0), 0.0, "nothing when its own weapon's blow pops it")
	Effects.remove(g, "barrier")
	Effects.stack(g, Effects.STATUS["braced"], Effects.SKIRMISH, "foe:revenant", 2, Effects.DECAY_ROUND)
	assert_eq(pol.purge_worth(sk, a, null_field, g, 1.0), 2.0, "Armoured: its stacks for the one allied blow to come")
	assert_eq(pol.purge_worth(sk, a, null1, g, 1.0), 1.0, "a Purge 1 takes one of the two (2 November)")
	Effects.remove(g, "braced")
	Effects.stack(g, Effects.STATUS["kindled"], Effects.SKIRMISH, "foe:caster", 3, Effects.DECAY_HALF)
	assert_eq(pol.purge_worth(sk, a, null_field, g, 1.0), 3.0, "Empowered: its value")
	Effects.remove(g, "kindled")
	Effects.grant(g, Effects.primed_foe(2, "foe:caster"))
	assert_eq(pol.purge_worth(sk, a, null_field, g, 1.0), 4.0, "Primed: 2 a stack")
	assert_eq(pol.purge_worth(sk, a, null_field, g, 0.5), 2.0, "at the odds the foe outlives the blow")
	Effects.remove(g, "primed")
	Effects.grant(g, Effects.regenerating(4))
	assert_eq(pol.purge_worth(sk, a, null_field, g, 1.0), 12.0, "Regenerating: its value for each of three actions left")
	Effects.remove(g, "regenerating")
	Effects.stack(g, Effects.foe_ward(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	assert_eq(pol.purge_worth(sk, a, null_field, g, 1.0), 0.0, "a Ward: nothing, since it turns the Purge away")
	Effects.remove(g, "ward")
	Effects.stack(g, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	assert_true(pol.purge_worth(sk, a, null1, g, 1.0) > 0.0, "Numbed: a stack stripped is a step toward a stun")
	var bare := pol.attack_score(sk, a, null_field, g)
	Effects.grant(g, Effects.primed_foe(5, "foe:caster"))
	assert_eq(pol.attack_score(sk, a, null_field, g), bare + 10.0, "the attack score carries it")


## A printed cooldown costs its entry the rounds it stays dark after this one (21 October),
## the share of the die's rolls it would have shown; a cooldown of one, ending with the round,
## costs nothing.
func test_greedy_prices_a_printed_cooldown_by_the_rounds_it_stays_dark() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1)
	var plain := Face.attack(30, L)
	var slow := Face.attack(30, L)
	slow.cooldown = 3
	var zap := Face.attack(30, L, [K.RAPID])
	zap.cooldown = 1
	sk.add_mech(_mech("A", Die.of([plain, slow, Face.attack(10, L), Face.attack(10, L)]), 40, 100))
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var base := pol.attack_score(sk, ms, plain, sk.front[0])
	assert_true(absf(pol.attack_score(sk, ms, slow, sk.front[0]) - base * 0.5) < 0.01, "two rounds dark after this one on a four-entry die: half its worth")
	assert_eq(Policy.cooldown_cost(ms, zap, base), 0.0, "a cooldown of one ends with the round")


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
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND - 1, "one reroll spent")


## A plain Rapid entry (4 November): spent, its machine acts again, so the bot values it at its
## blow plus the die's own average blow, where it had valued the blow alone.
func test_greedy_values_a_rapid_entry_by_its_action_again() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var quick := Face.attack(5, L, [K.RAPID])
	var plain := Face.attack(5, L)
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.of([quick, plain, Face.attack(5, L)]), 40, 100))
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var foe: Foe = sk.front[0]
	var extra := pol.attack_score(sk, ms, quick, foe) - pol.attack_score(sk, ms, plain, foe)
	assert_true(absf(extra - Policy.ROLL_AGAIN_WEIGHT * 5.0) < 0.001, "the action again: the die's average blow, 5")


## The same for a Rapid shield (the Laminar Deflector's kind), spent on its own machine.
func test_greedy_values_a_rapid_shield_by_its_action_again() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var quick := Face.shield(6)
	quick.keywords = [K.RAPID]
	var plain := Face.shield(6)
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.of([quick, Face.attack(4, L), Face.attack(4, L)]), 0, 100))
	sk.add_foes([_ghoul(500, 6)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var extra := pol.machine_spend_score(sk, ms, ms, quick) - pol.machine_spend_score(sk, ms, ms, plain)
	assert_true(absf(extra - Policy.ROLL_AGAIN_WEIGHT * 8.0 / 3.0) < 0.001, "the action again: two fours over three entries")


## A stepping die's Rapid is the cycle plan's (cycle_chain reads the chamber it steps to), so a
## spend's own score adds nothing for it.
func test_a_stepping_die_rapid_entry_adds_no_action_again_to_its_spend() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var quick := Face.attack(5, L, [K.RAPID])
	var plain := Face.attack(5, L)
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.of([quick, plain, Face.attack(5, L)]), 40, 100)
	u.grant_passive({"id": "test_step", "name": "Step", "description": "", "effects": [{"trigger": "static", "effect": "step_die", "value": 1}]})
	sk.add_mech(u)
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var foe: Foe = sk.front[0]
	assert_true(absf(pol.attack_score(sk, ms, quick, foe) - pol.attack_score(sk, ms, plain, foe)) < 0.001, "the cycle plan reads it, not the spend")


## A stepping die's cycle (3 November): the greedy bot weighs where the dial rests for the next
## round, so it holds a chamber when the one after it opens the next round better than now.
func test_greedy_holds_a_stepping_die_to_open_the_next_round_on_its_better_chamber() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := _stepper([20, 21, 2, 2])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	pol._greedy_rerolls(sk)
	assert_eq(ms.face_index, 0, "the twenty holds: a step would spend the twenty-one now and open on a two")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "no reroll spent")


## The cycle reaches past the next chamber: two steps through a weak one to the big gun.
func test_greedy_steps_a_stepping_die_through_a_weak_chamber_to_a_big_one() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := _stepper([10, 5, 40, 5])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_eq(int(pol.cycle_plan(sk, ms, 3)["steps"]), 2, "two steps to the forty")
	pol._greedy_rerolls(sk)
	assert_eq(ms.face_index, 2, "the ten steps past the five to the forty")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND - 2, "two rerolls spent")


## A spinning chamber (the Spin-Up's) is worth its own spend and the spin after it, so the bot
## does not step away from it toward a chamber worth only a little more than its stack.
func test_greedy_keeps_a_spinning_chamber_for_the_spin_after_it() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var spin := Face.buff("spun_up", 1, 1)
	spin.keywords = [Face.Keyword.RAPID]
	spin.spins = true
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.of([spin, Face.attack(6, L), Face.attack(6, L), Face.attack(6, L)]), 40, 100)
	u.grant_passive({"id": "test_step", "name": "Step", "description": "", "effects": [{"trigger": "static", "effect": "step_die", "value": 1}]})
	sk.add_mech(u)
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	var own := pol.face_value(sk, ms, ms.die.faces[0])
	var chain := float(pol.cycle_chain(sk, ms, 0)["value"])
	assert_true(chain > own + 5.9, "the spin's chamber carries the spin: at least a six after its own spend")
	assert_eq(int(pol.cycle_chain(sk, ms, 0)["rest"]), -1, "and leaves the dial anywhere")
	pol._greedy_rerolls(sk)
	assert_eq(ms.face_index, 0, "the spin holds against a six")


func _stepper(powers: Array) -> Skirmish:
	var sk := Skirmish.new(1)
	var faces: Array = []
	for p in powers:
		faces.append(Face.attack(int(p), L))
	var u := _mech("A", Die.of(faces), 40, 100)
	u.grant_passive({"id": "test_step", "name": "Step", "description": "", "effects": [{"trigger": "static", "effect": "step_die", "value": 1}]})
	sk.add_mech(u)
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	return sk


## The seal (the Polar Bear's Lockdown, valued 21 October): a buff a machine with a seal spends
## on itself (its trigger since 11 November) is worth the armour it stands behind this round's
## blows, less its heat, on top of what the buff grants.
func test_greedy_values_the_seal_by_the_blows_its_armour_turns() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk := Skirmish.new(1)
	var buff := Face.buff("overcharged", 1)
	var u := _mech("A", Die.of([buff, Face.attack(10, L)]), 0, 200)
	u.grant_passive({"id": "test_seal", "name": "Seal", "description": "", "effects": [{"trigger": "static", "effect": "seal_form", "value": 20, "heat": 5}]})
	sk.add_mech(u)
	sk.add_foes([_ghoul(500, 30), _ghoul(500, 30)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(pol.seal_score(sk, ms) > 0.0, "twenty armour against two blows of thirty is worth the forty it keeps off")
	var on_self := pol.machine_spend_score(sk, ms, ms, buff)
	assert_true(absf(on_self - (pol.buff_score(sk, ms, buff) + pol.seal_score(sk, ms))) < 0.001, "spent on itself, the buff is worth what it grants and the seal besides")
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
	var beast := Foe.make("gargantuan_king", 30, 20)
	beast.on_death = {"blow": Foe.death_blow_from({"name": "Meteor", "factor": 1.0, "keywords": ["all"]})}
	var calm := Foe.make("gargantuan_king", 30, 20)
	s3.add_foes([beast, calm])
	s3.begin()
	s3.start_round()
	assert_true(is_equal_approx(Policy.last_act_cost(s3, beast), 20.0 * Policy.HULL_WEIGHT), "its Meteor's twenty on the bare machine")
	assert_eq(Policy.last_act_cost(s3, calm), 0.0, "a foe without one costs nothing")
	beast.target = s3.mechs[0]
	calm.target = s3.mechs[0]
	var f40 := Face.attack(40, I)
	assert_true(pol.attack_score(s3, s3.mechs[0], f40, beast) < pol.attack_score(s3, s3.mechs[0], f40, calm), "the kill that sets off a Meteor is worth less")


## The Lammergeier's Mines for the bot (9 November), on a synthetic passive: a spend that leaves a
## Mine is worth more where neighbours stand to take its blast, a kill of a mined foe is worth its
## blast at once, the drone is worth the Mine it sets off now, and the gather the bigger blast round
## its target.
func test_greedy_weighs_a_mine_its_blast_on_a_kill_the_detonation_and_the_gather() -> void:
	var bay := {"id": "bay", "name": "Bay", "description": "", "effects": [{"trigger": "static", "effect": "mine_on_spend", "value": 2}]}
	var sk := Skirmish.new(3, 3)
	var gun := Face.attack(1, Face.Reach.INDIRECT)
	var m := _mech("Bomber", Die.single(gun), 40, 100)
	m.grant_passive(bay)
	sk.add_mech(m)
	var plain := _mech("Plain", Die.single(gun), 40, 100)
	sk.add_mech(plain)
	var a := _ghoul(100, 0)
	var b := _ghoul(100, 0)
	var c := _ghoul(100, 0)
	sk.add_foes([a, b, c])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	var bomber: Skirmish.MechState = sk.mechs[0]
	var other: Skirmish.MechState = sk.mechs[1]
	assert_true(pol.mine_worth(sk, bomber, gun, b, 0.0) > pol.mine_worth(sk, bomber, gun, a, 0.0), "the middle foe has two neighbours to its blast, the end one one")
	assert_eq(pol.mine_worth(sk, other, gun, b, 0.0), 0.0, "a machine that leaves none: nothing")
	sk._add_mine(b, 10, {})
	assert_true(pol.mine_worth(sk, other, gun, b, 1.0) > 15.0, "a sure kill of a mined foe blows its 10 on both neighbours")
	var drone := Face.attack(1, Face.Reach.INDIRECT)
	drone.detonates = true
	assert_true(pol.mine_worth(sk, bomber, drone, b, 0.0) > pol.mine_worth(sk, bomber, gun, b, 0.0), "the drone sets the Mine off now")
	var gather := Face.attack(0, Face.Reach.INDIRECT, [Face.Keyword.EXPOSE])
	gather.gathers_mines = true
	sk._add_mine(a, 6, {})
	assert_true(pol.mine_worth(sk, bomber, gather, b, 0.0) > 0.0, "gathering the end foe's Mine onto the middle foe adds a neighbour to its blast")
	assert_true(pol.mine_worth(sk, bomber, gather, c, 0.0) < pol.mine_worth(sk, bomber, gather, b, 0.0), "onto the other end, less")


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
## what an ammo buys; a dry gun is no option; the salvo is worth its number on every foe, less its reserve.
func test_greedy_prices_a_forged_gun_in_ammo_and_weighs_the_salvo() -> void:
	var forge := {"id": "forge", "name": "Forge", "description": "", "effects": [{"trigger": "static", "effect": "forge", "value": 10, "start": 3, "per_round": 1, "per_heat": 10, "vent": 3, "shield": 2}]}
	var ray := Face.attack(30, L)
	ray.heat = 30
	var salvo := Face.attack(20, Face.Reach.EVERY_FOE)
	salvo.spends_magazine = true
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
	assert_true(pol.attack_score(sk, ms, salvo, sk.front[0]) > 0.0, "its number on a full field is worth firing")
	# The reserve (3 November): only the ammo the ray's next spend needs counts against the salvo,
	# so a fuller magazine costs it nothing more.
	var at_three := pol.attack_score(sk, ms, salvo, sk.front[0])
	ms.ammo = 10
	assert_eq(pol.magazine_reserve(ms), 3, "the ray's next spend")
	assert_true(absf(pol.attack_score(sk, ms, salvo, sk.front[0]) - at_three) < 0.001, "past the reserve the magazine it empties is free")
	ms.ammo = 0
	ms.face_index = 0
	assert_true(pol.options_for(sk, 0).is_empty(), "a dry gun is no option")
	ms.face_index = 1
	assert_true(pol.options_for(sk, 0).is_empty(), "nor an empty salvo")


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
## before right, whatever a kill elsewhere would give; every shield, vent and buff on its own
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


## The bot reads Chain as the resolver deals it (the conductor, 28 October; its charge, and a Shock
## read by an aimed strike alone, 29 October): each Shocked foe on the field past the target takes
## Chain's number plain, the conductors' charges standing; with no conductor the Chain gun is a
## plain gun (the charge retired 3 November: Chain is the arcs alone).
func test_the_bot_reads_a_chains_arcs() -> void:
	var sk := Skirmish.new(1, 3)
	var gun := Face.attack(4, L, [K.CHAIN], 3)
	gun.chain = 2
	var plain := Face.attack(4, L, [], 3)
	var m := _mech("A", Die.of([gun, plain]), 40, 100)
	sk.add_mech(m)
	var aim := _ghoul(100)
	var a := _ghoul(100)
	var b := _ghoul(100)
	sk.add_foes([aim, a, b])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var pol := Policy.new()
	var lead := pol.attack_score(sk, ms, gun, aim) - pol.attack_score(sk, ms, plain, aim)
	assert_true(absf(lead) < 0.001, "with no conductor the Chain gun is a plain gun: %f" % lead)
	for foe in [a, b]:
		Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_eq(pol.damage_outcomes(ms, gun, a, Skirmish.AREA_CHAIN), [[2.0, 1.0]], "a conductor: Chain 2 plain, no strike aimed at it")
	assert_eq(pol.damage_outcomes(ms, gun, a), [[8.0, 1.0]], "the same foe aimed at: the blow doubled")
	lead = pol.attack_score(sk, ms, gun, aim) - pol.attack_score(sk, ms, plain, aim)
	assert_true(absf(lead - 4.0) < 0.001, "two conductors, Chain 2 each: %f" % lead)


## The bot reads a foe past the target as the resolver deals it (area by shape, numbered: Ryan,
## 28 October): its shape's number through the firer's modifiers, judged on that foe, then its
## own statuses and armour; and a consumer gives up every foe's stacks it eats, each its own.
func test_the_bot_reads_each_foe_past_the_target_at_its_shapes_number() -> void:
	var sk := Skirmish.new(1, 3)
	var sweep := Face.attack(6, L, K.CLEAVE)
	sweep.cleave = 2
	var m := _mech("A", Die.single(sweep), 40, 100)
	m.grant_passive({"id": "test_edge", "name": "Edge", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_status"}]})
	sk.add_mech(m)
	var marked := _ghoul(100)
	var aim := _ghoul(100)
	var plain := _ghoul(100)
	sk.add_foes([marked, aim, plain])
	sk.begin()
	sk.start_round()
	Effects.stack(marked, Effects.STATUS["flakked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_HALF)
	var ms: Skirmish.MechState = sk.mechs[0]
	var pol := Policy.new()
	assert_eq(pol.damage_outcomes(ms, sweep, aim), [[6.0, 1.0]], "the clean target: the roll alone")
	assert_eq(pol.damage_outcomes(ms, sweep, marked, Skirmish.AREA_ROW), [[4.0, 1.0]], "the marked neighbour: Spread 2, the point its status earns, its Flak")
	assert_eq(pol.damage_outcomes(ms, sweep, plain, Skirmish.AREA_ROW), [[2.0, 1.0]], "the plain one: Spread 2")
	var before := pol.attack_score(sk, ms, sweep, aim)
	sweep.cleave = 4
	assert_true(pol.attack_score(sk, ms, sweep, aim) > before, "a bigger Spread is worth more")
	# A consumer through a Spread: every foe it strikes eats its own, so the ticks each gives up count.
	var charge := Face.attack(2, L, K.CLEAVE)
	charge.cleave = 1
	charge.consumes = "burning"
	var dry := charge.duplicate_face()
	dry.consumes = ""
	Effects.stack(plain, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 3)
	var lost: float = pol.attack_score(sk, ms, dry, aim) + float(pol.damage_outcomes(ms, charge, plain, Skirmish.AREA_ROW)[0][0]) - float(pol.damage_outcomes(ms, dry, plain, Skirmish.AREA_ROW)[0][0]) - pol.attack_score(sk, ms, charge, aim)
	assert_true(lost > 0.0, "the neighbour's Burning eaten costs the ticks it would have dealt: %f" % lost)

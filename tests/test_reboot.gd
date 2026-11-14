extends TestCase

## The reboot, a what-if behind one switch (Skirmish.reboot; Ryan, 13 November;
## docs/briefs/refit_pass.md, section 22, has his words and the spec these tests follow line by
## line). Off, the game as built runs, and tests/test_skirmish.gd holds that. The runner turns
## the switch off before each test. Numbers are in tens; every piece here is synthetic.

const L := Face.Reach.DIRECT
const K := Face.Keyword
const SKIRMISH_SCENE := preload("res://game/skirmish/skirmish_screen.tscn")

## A point of cooling and of regen granted over the chassis's own, as a module or a passive would.
const RADIATOR := {"id": "radiator", "name": "Radiator", "description": "", "effects": [
	{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 15}]}
const MENDER := {"id": "mender", "name": "Mender", "description": "", "effects": [
	{"trigger": "static", "effect": "add_stat", "stat": "shield_regen", "value": 5}]}
## A hull hit that stands a shield up, a gain by another road than the regen.
const LINER := {"id": "liner", "name": "Liner", "description": "", "effects": [
	{"trigger": "on_hull_damage", "effect": "add_shield", "value": 10}]}
## A pass at 8 heat or more releases it on every foe.
const BOILER := {"id": "boiler", "name": "Boiler", "description": "", "effects": [
	{"trigger": "static", "effect": "pass_release", "value": 1, "gate": 8}]}


func _mech(id: int, name: String, d: Die, shield: int = 40, hull: int = 100, heat_max: int = 30) -> Unit:
	var u := Unit.mech(id, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.heat_max = heat_max
	u.die = d
	return u


func _gun(heat: int, power: int = 1) -> Die:
	return Die.single(Face.attack(power, L, [], heat))


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1)
	sk.keeps_undo = true
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	return sk


func test_off_the_game_as_built_runs_and_no_machine_reboots() -> void:
	var m := _mech(1, "A", _gun(10))
	m.cooling = 2
	m.shield_regen = 2
	m.shield = 30
	var sk := _fight([m], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	assert_false(sk.can_reboot(0), "off, there is no reboot")
	assert_false(sk.reboot_mech(0), "and asking for one does nothing")
	assert_eq(m.shield, 32, "its regen ran as the round opened")
	sk.assign(0, sk.front[0])
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].heat, 8, "and its cooling runs")
	assert_eq(m.shield, 34, "with its regen")


func test_on_a_chassis_s_own_regen_and_cooling_are_nothing() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(10))
	m.cooling = 2
	m.shield_regen = 2
	m.shield = 30
	var sk := _fight([m], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	assert_eq(m.shield, 30, "no regen of its own")
	sk.assign(0, sk.front[0])
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].heat, 10, "and no cooling of its own")
	assert_eq(m.cooling, 2, "the stat stands on the chassis; the rule reads past it")


func test_what_is_granted_still_cools_and_mends() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(20))
	m.cooling = 2
	m.shield_regen = 2
	m.shield = 30
	m.grant_passive(RADIATOR)
	m.grant_passive(MENDER)
	var sk := _fight([m], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	assert_eq(m.shield, 35, "a granted regen lands, the chassis's own two left out")
	sk.assign(0, sk.front[0])
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].heat, 5, "and a granted cooling, fifteen off the twenty")
	assert_eq(m.shield, 40, "the regen again, up to the maximum")


func test_a_reboot_drops_the_shield_at_once_and_both_gauges_are_back_next_round() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(10))
	var sk := _fight([m], [Foe.make("brute", 900, 25)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.shield, 15, "round one: the blow takes its number off the shield")
	sk.start_round()
	assert_eq([ms.heat, m.shield], [10, 15], "round two opens as round one left it: nothing came back")
	assert_true(sk.can_reboot(0), "it has spent nothing, so it may reboot")
	assert_true(sk.reboot_mech(0), "and does")
	assert_eq(m.shield, 0, "its shield is down at once")
	assert_true(ms.rebooting and ms.assigned, "it is rebooting, and its turn is given")
	assert_false(sk.can_spend(0), "so its die is not to be spent")
	assert_eq(ms.heat, 10, "its heat is still on the gauge this turn")
	assert_true("\n".join(sk.log).contains("A reboots: shield -15, heat 10 to vent, back next round"), "the log says what it gave up")
	sk.end_round()
	assert_eq(m.hull, 75, "the enemy's turn finds it bare: the whole blow on the hull")
	sk.start_round()
	assert_eq([ms.heat, m.shield], [0, 40], "round three opens cold and whole")
	assert_false(ms.rebooting or ms.shield_broken or ms.overheated, "and clear of all three states")
	assert_true(sk.can_reboot(0), "free to reboot again")


func test_only_a_machine_that_has_spent_nothing_may_reboot() -> void:
	Skirmish.reboot = true
	var quick := Face.attack(1, L, [K.RAPID])
	var m := _mech(1, "A", Die.of([quick, Face.attack(1, L), Face.attack(2, L)]))
	var plain := _mech(2, "B", _gun(0))
	var dud := _mech(3, "C", Die.single(Face.blank()))
	var sk := _fight([m, plain, dud], [Foe.make("dummy", 900, 0)])
	assert_false(sk.can_reboot(0), "not before the round is rolled")
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "a Rapid piece spent")
	assert_false(sk.mechs[0].assigned, "it may act again")
	assert_false(sk.can_reboot(0), "and may not reboot: it has spent something")
	assert_false(sk.reboot_mech(0), "asking changes nothing")
	assert_eq(m.shield, 40, "its shield stands")
	assert_true(sk.assign(1, sk.front[0]), "an ordinary spend")
	assert_false(sk.can_reboot(1), "nor a machine whose die is spent")
	assert_true(sk.can_reboot(2), "a machine with nothing to spend may: a dud is the cheap moment for one")
	assert_false(sk.can_reboot(7), "no such machine, no reboot")
	sk.end_round()
	sk.start_round()
	assert_true(sk.can_reboot(0) and sk.can_reboot(1), "the next round they have spent nothing again")


func test_the_undo_takes_a_reboot_back() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(10), 40, 100)
	var sk := _fight([m], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	m.shield = 25
	assert_true(sk.reboot_mech(0), "rebooted")
	assert_eq(sk.undo_depth(), 1, "the undo reaches it")
	assert_true(sk.undo(), "and takes it back")
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(ms.unit.shield, 25, "its shield as it stood")
	assert_false(ms.rebooting or ms.assigned or ms.shield_broken, "and it has given nothing")
	assert_true(sk.can_reboot(0), "so it may choose again")


func test_heat_past_the_maximum_stays_and_every_stack_burns_every_turn() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m], [Foe.make("dummy", 9000, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "a spend is never refused for its heat")
	assert_eq(ms.overheat_stacks(), 10, "ten past its maximum")
	sk.end_round()
	assert_eq(m.hull, 190, "each stack burns a point of hull")
	assert_eq(ms.heat, 40, "and the heat stays where it is: nothing settles")
	sk.start_round()
	assert_eq(ms.heat, 40, "nor cools")
	sk.end_round()
	assert_eq(m.hull, 180, "a turn it only stands there, the ten burn again")
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(ms.overheat_stacks(), 50, "another shot piles on")
	sk.end_round()
	assert_eq(m.hull, 130, "and the whole fifty burn: it builds until a reboot or a wreck")
	assert_true("\n".join(sk.log).contains("A is overheated ×50: hull -50"), "the log counts the stacks")


func test_the_overheat_s_dial_prices_a_stack() -> void:
	Skirmish.reboot = true
	Skirmish.overheat_scale = 2
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m], [Foe.make("dummy", 9000, 0)])
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.hull, 180, "two hull a stack")


func test_the_first_overheat_breaks_the_shield_once_between_reboots() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(40), 40, 900, 30)
	m.grant_passive(RADIATOR)
	var sk := _fight([m], [Foe.make("dummy", 9000, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_true(ms.overheated, "it has overheated")
	assert_eq(m.shield, 0, "and the overheat broke its shield")
	assert_true(ms.shield_broken, "which is broken")
	assert_true(bool(sk.overheats[0]["first"]), "the first since its last reboot")
	sk.start_round()
	assert_eq(ms.heat, 25, "a granted cooling brings it back under its maximum")
	assert_eq(ms.overheat_stacks(), 0, "the stacks gone first")
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(ms.overheat_stacks(), 35, "past it again")
	assert_false(bool(sk.overheats[0]["first"]), "it burns, and overheats no second time")
	assert_eq("\n".join(sk.log).count("its shield breaks"), 1, "one break between reboots")
	sk.start_round()
	assert_true(sk.reboot_mech(0), "it reboots")
	sk.end_round()
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_true(bool(sk.overheats[0]["first"]), "and after the reboot an overheat is a first again")
	assert_eq("\n".join(sk.log).count("its shield breaks"), 2, "breaking the shield it got back")


func test_a_rebooting_machine_neither_burns_nor_overheats() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m], [Foe.make("dummy", 9000, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.hull, 190, "round one burns its ten")
	sk.start_round()
	assert_eq(int(sk.forecast(ms)["overheat"]), 10, "the forecast has it burning again")
	sk.reboot_mech(0)
	assert_eq(int(sk.forecast(ms)["overheat"]), 0, "and not once it reboots")
	sk.end_round()
	assert_eq(m.hull, 190, "the turn of its reboot burns nothing")
	assert_true(sk.overheats.is_empty(), "and is no overheat")
	sk.start_round()
	assert_eq([ms.heat, ms.overheat_stacks(), m.shield], [0, 0, 40], "back cold and whole")


func test_a_machine_out_of_the_fight_does_not_burn() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m, _mech(2, "B", _gun(0))], [Foe.make("dummy", 9000, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.hull, 190, "it burns the turn it passes its maximum")
	sk.start_round()
	Effects.grant_buff(m, "phased", 1, "test", sk.round)
	assert_true(Skirmish.is_out(ms), "Phased, it is out of the fight this round")
	assert_false(sk.can_reboot(0), "and cannot reboot")
	sk.end_round()
	assert_eq(m.hull, 190, "so the burn does not ask it to: nothing burns while it is out")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 180, "back in the fight, the stacks it still carries burn again")


func test_a_blow_that_takes_a_shield_to_nothing_breaks_it_and_a_breach_does_not() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(0), 40, 200)
	var sk := _fight([m], [Foe.make("brute", 900, 40)])
	sk.start_round()
	sk.end_round()
	assert_eq([m.shield, m.hull], [0, 200], "spent exactly, nothing on the hull")
	assert_true(sk.mechs[0].shield_broken, "and broken all the same")
	assert_true("\n".join(sk.log).contains("A's shield is broken: no shield until it reboots"), "the log says so")
	var m2 := _mech(2, "B", _gun(0), 40, 200)
	var maw := Foe.make("maw", 900, 50)
	maw.actions[0]["keywords"] = ["breach"]
	var s2 := _fight([m2], [maw])
	s2.start_round()
	s2.end_round()
	assert_eq([m2.shield, m2.hull], [40, 150], "a breach passes a shield that stands")
	assert_false(s2.mechs[0].shield_broken, "which is not broken")


func test_a_broken_shield_gains_none_by_any_method_until_it_reboots() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(0), 10, 900)
	m.grant_passive(MENDER)
	m.grant_passive(LINER)
	var brute := Foe.make("brute", 900, 30)
	var sk := _fight([m], [brute])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	sk.end_round()
	assert_eq([m.shield, m.hull], [0, 880], "the blow breaks it and the rest reaches the hull")
	assert_eq(m.shield, 0, "the hull hit stands no shield up on a broken one")
	sk.start_round()
	assert_eq(m.shield, 0, "nor does a granted regen")
	assert_eq(sk._gain_shield(ms, 5), 0, "nor any gain at all")
	assert_eq(sk._gain_shield(ms, 5, true), 0, "an overshield included")
	sk.reboot_mech(0)
	sk.end_round()
	assert_eq(m.shield, 0, "it reboots bare, and the hit stands nothing up")
	sk.start_round()
	assert_eq(m.shield, 10, "the reboot's recovery is the one way back")
	assert_false(ms.shield_broken, "and the shield is live again")
	brute.attack = 4
	sk.end_round()
	assert_eq(m.shield, 6, "a blow it outlasts leaves it live")
	sk.start_round()
	assert_eq(m.shield, 10, "so the granted regen lands on it")


func test_a_machine_can_break_its_own_shield() -> void:
	Skirmish.reboot = true
	var costly := Face.attack(10, L)
	costly.shield_cost = 10
	var m := _mech(1, "A", Die.single(costly), 10, 200)
	var sk := _fight([m], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "a piece that costs its last point of shield")
	assert_eq(m.shield, 0, "paid")
	assert_true(sk.mechs[0].shield_broken, "and its own spend broke it")
	assert_eq(sk._gain_shield(sk.mechs[0], 5), 0, "so it gains none until it reboots")


func test_a_barrier_lands_on_a_broken_shield_and_covers_a_reboot() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(0), 40, 200)
	var sk := _fight([m], [Foe.make("brute", 900, 50)])
	sk.start_round()
	sk.reboot_mech(0)
	assert_true(sk.mechs[0].shield_broken, "rebooting, its shield at nothing")
	Effects.grant_buff(m, "barrier", 1, "test", sk.round)
	assert_true(Effects.has(m, "barrier"), "a Barrier is a buff in front of the gauges: it lands all the same")
	sk.end_round()
	assert_eq(m.hull, 200, "and takes the blow the bare machine would have")
	assert_true("\n".join(sk.log).contains("the Barrier takes the blow"), "the log says so")


func test_a_reboot_is_no_pass() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(10), 40, 200)
	m.grant_passive(BOILER)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([m], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	var hp := foe.hp
	sk.start_round()
	assert_eq(ms.heat, 10, "ten held, past its valve's gate")
	sk.reboot_mech(0)
	sk.end_round()
	assert_false(ms.passed, "a reboot is no pass")
	assert_eq(foe.hp, hp, "so the valve does not open")
	assert_true(sk.releases.is_empty(), "nothing released")
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	hp = foe.hp
	sk.start_round()
	sk.end_round()
	assert_true(ms.passed, "a turn it ends with its die unspent is one")
	assert_true(foe.hp < hp, "and the valve opens")


func test_the_round_preview_plays_a_reboot_bare_and_a_burn_that_stands() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m], [Foe.make("brute", 9000, 25)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	var held: Dictionary = sk.preview_round(0, sk.front[0])["mechs"][0]   # the die in hand, over its foe
	assert_eq(int(held["overheat"]), 10, "the shot would leave it ten past its maximum")
	assert_eq(int(held["heat_end"]), 40, "the gauge as the turn ends")
	assert_eq(int(held["heat_after"]), 40, "and after the round: nothing settles")
	assert_eq(int(held["shield_after"]), 0, "the overheat breaks the shield before the blow lands")
	assert_eq(int(held["hull_after"]), 165, "ten burnt, and the whole twenty-five on a bare hull")
	sk.assign(0, sk.front[0])
	var fc := sk.forecast(ms)
	assert_eq([int(fc["overheat"]), int(fc["heat_after"])], [10, 40], "the bot's forecast reads the same burn and no settle")
	sk.end_round()
	sk.start_round()
	sk.reboot_mech(0)
	var shown: Dictionary = sk.preview_round()["mechs"][0]
	assert_eq(int(shown["overheat"]), 0, "rebooting, it burns nothing")
	assert_eq(int(shown["hull_after"]), m.hull - 25, "and the blow lands whole on it")
	assert_eq(m.shield, 0, "the fight itself as the reboot left it")


func test_a_copy_of_the_fight_carries_the_reboot() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m], [Foe.make("dummy", 9000, 0)])
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	sk.start_round()
	sk.reboot_mech(0)
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	var cm: Skirmish.MechState = copy.mechs[0]
	assert_true(cm.rebooting and cm.shield_broken and cm.overheated, "the copy's machine is rebooting, broken and overheated as the fight's is")
	copy.end_round()
	copy.start_round()
	assert_eq([cm.heat, cm.unit.shield], [0, 40], "and the copy's next round opens cold and whole")
	assert_true(sk.mechs[0].rebooting, "the fight itself untouched")


## The fight bot's first play of it (Policy._reboot_first and _reboot_idle), so the runners still
## finish a fight under the rule: a machine past its maximum gives its turn, one whose entry
## would pass it reboots where little shield is at stake, and a die left idle is a reboot too.
func test_the_bot_reboots_and_plays_the_fight_out() -> void:
	Skirmish.reboot = true
	for kind in [Policy.GREEDY, Policy.BLIND, Policy.PLANNER, Policy.RANDOM]:
		var m := _mech(1, "A", _gun(20, 10), 40, 300, 30)   # twenty heat a shot against thirty: its second shot would pass the maximum
		var sk := _fight([m], [Foe.make("dummy", 60, 0)])
		var p := Policy.make(kind, 1)
		assert_eq(p.play(sk), Skirmish.Outcome.VICTORY, "%s wins the fight" % Policy.kind_name(kind))
		assert_false(p.stalled, "and does not stall")
		assert_true(p.reboots >= 2, "%s gives turns to reboots along the way (%d)" % [Policy.kind_name(kind), p.reboots])
		if kind != Policy.RANDOM:
			assert_eq(m.hull, 300, "%s never burns for it" % Policy.kind_name(kind))


func test_the_bot_reboots_out_of_a_burn_it_did_not_choose() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(0, 10), 40, 300, 30)
	var sk := _fight([m], [Foe.make("dummy", 900, 0)])
	var p := Policy.make(Policy.GREEDY, 1)
	sk.start_round()
	sk.mechs[0].heat = 45   # a foe's heat, say, has carried it past its maximum
	p.play_round(sk)
	assert_true(sk.mechs[0].rebooting, "past its maximum it burns every turn, so the bot reboots before it spends")
	sk.end_round()
	assert_eq(m.hull, 300, "and the reboot's turn burns nothing")


func test_the_bot_keeps_a_shield_a_blow_is_coming_for() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(40, 10), 40, 300, 30)   # its one entry would pass the maximum
	var sk := _fight([m], [Foe.make("brute", 900, 30)])
	var p := Policy.make(Policy.GREEDY, 1)
	sk.start_round()
	p.play_round(sk)
	assert_false(sk.mechs[0].rebooting, "a blow is coming that its shield would take: it rides, and keeps the shield up")
	assert_eq(sk.mechs[0].heat, 0, "and does not fire past its maximum to do it")
	var blind := Policy.make(Policy.BLIND, 1)
	var m2 := _mech(2, "B", _gun(40, 10), 40, 300, 30)
	var s2 := _fight([m2], [Foe.make("brute", 900, 30)])
	s2.start_round()
	blind.play_round(s2)
	assert_true(s2.mechs[0].rebooting, "the blind bot reads no picks: it reboots where its entry would pass the maximum")


## A fight saved under the trial and carried on without it plays as built from there: no
## recovery owed, and the shield its regen may raise again.
func test_a_fight_carried_on_without_the_trial_is_the_game_as_built() -> void:
	Skirmish.reboot = true
	var m := _mech(1, "A", _gun(10), 40, 200)
	m.shield_regen = 5
	var sk := _fight([m], [Foe.make("brute", 900, 50)])
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_true(sk.mechs[0].shield_broken, "its shield broken under the trial")
	sk.start_round()
	sk.reboot_mech(0)
	Skirmish.reboot = false
	sk.end_round()
	sk.start_round()
	assert_false(sk.mechs[0].rebooting, "the trial off, no reboot is under way")
	assert_eq(sk.mechs[0].heat, 10, "and no recovery lands: its heat is where it was")
	assert_eq(m.shield, 5, "its regen raises its shield, as built")


func test_off_the_bot_never_reboots() -> void:
	var m := _mech(1, "A", _gun(20, 10), 40, 300, 30)
	m.cooling = 10
	var sk := _fight([m], [Foe.make("dummy", 60, 0)])
	var p := Policy.make(Policy.GREEDY, 1)
	assert_eq(p.play(sk), Skirmish.Outcome.VICTORY, "the fight as built")
	assert_eq(p.reboots, 0, "with no reboot in it")


## A chassis the game can run, whichever content lists first: the screen wants a real machine's
## model, and no test names one.
func _a_chassis(db: ContentDB) -> String:
	for id in db.chassis.keys():
		if db.chassis_runnable(str(id)):
			return str(id)
	return ""


## The screen under the trial (a debug build's): a REBOOT control beside REROLL, lit while any
## machine may reboot, a press giving the turn of the machine whose die is read; the three states
## as chips, the two debuffs said so; the hold's cooling reading what the rule leaves of it; UNDO
## taking it back.
func test_the_screen_s_reboot_control_gives_the_read_die_s_turn() -> void:
	Skirmish.reboot = true
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	sk.keeps_undo = true
	var m := db.make_mech(_a_chassis(db))
	m.die = Die.single(Face.attack(1, L, [], 0))
	sk.add_mech(m)
	sk.add_foes([Foe.make("dummy", 900, 0)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(s._reboot_btn != null, "under its trial the screen has the control")
	assert_false(s._reboot_btn.disabled, "lit while a machine has spent nothing, with nothing read")
	s._on_die_tapped(0)
	assert_false(s._reboot_btn.disabled, "and with its die read")
	ms.heat = ms.heat_max + 3
	s._refresh()
	var chips: Array[String] = []
	for r in s._mech_rows(0):
		chips.append(str(r[2]))
	assert_true(chips.has("Debuff, Overheated ×3: hull -3 every turn until it reboots"), "heat past the maximum is a debuff, a stack a point: %s" % str(chips))
	s._on_reboot()
	assert_true(ms.rebooting, "REBOOT gives the read die's machine its reboot")
	assert_eq(m.shield, 0, "its shield down at once")
	assert_true(s._reboot_btn.disabled, "and the control goes dark")
	chips.clear()
	for r in s._mech_rows(0):
		chips.append(str(r[2]))
	assert_true(chips.has("Rebooting: bare this turn, cold and whole the next"), "the machine says it is rebooting: %s" % str(chips))
	s._undo_from = 0
	s._on_undo()
	assert_false(sk.mechs[0].rebooting, "UNDO takes the reboot back")
	sk.mechs[0].unit.shield = 0
	sk._note_break(sk.mechs[0])
	chips.clear()
	for r in s._mech_rows(0):
		chips.append(str(r[2]))
	assert_true(chips.has("Debuff, Shield broken: no shield until it reboots"), "a broken shield is a debuff of its own: %s" % str(chips))
	s._on_mech_held(0)
	assert_true(s._details_entry.text().contains("Cooling %d" % int(sk.mechs[0].unit.base["cooling"])), "the hold reads its cooling from the chassis's own")
	s.free()


## The control under a finger, as the phone delivers one (Ryan, 14 November: "So I can't actually
## trigger a reboot"; it had lit for a die's open readout alone, and nothing on the screen said
## so). Every way in: a press that asks which and the tap on a die or a machine that answers, a
## press with a machine's readout open or its die's, and a die dropped on the control. Live: the
## fight's screen in a viewport, every touch pushed through it.
func live_test_reboot_takes_a_press_and_a_pick_a_read_machine_and_a_dropped_die() -> void:
	Skirmish.reboot = true
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	sk.keeps_undo = true
	for k in range(3):
		var m := db.make_mech(_a_chassis(db))
		m.die = Die.single(Face.attack(1, L, [], 0))
		sk.add_mech(m)
	sk.add_foes([Foe.make("dummy", 900, 0)])
	var vp := SubViewport.new()
	vp.size = Vector2i(720, 1280)
	vp.gui_embed_subwindows = true
	(Engine.get_main_loop() as SceneTree).root.add_child(vp)
	var s: SkirmishScreen = SKIRMISH_SCENE.instantiate()
	s.sk = sk
	s.setup(sk)
	vp.add_child(s)
	var rb: Vector2 = s._reboot_btn.get_global_rect().get_center()
	assert_false(s._reboot_btn.disabled, "lit with nothing read: a press is never dead while a machine may reboot")
	# A press with nothing read asks which, and a tap on a die answers.
	_tap(vp, rb)
	assert_true(s._reboot_armed and s._reboot_btn.filled, "a press with no machine read asks which, the control filled")
	assert_false(_rebooting(sk).has(true), "and reboots nothing yet")
	_tap_die(vp, s, 1)
	assert_eq(_rebooting(sk), [false, true, false], "a tap on a die answers: its machine reboots")
	assert_false(s._reboot_armed or s._reboot_btn.filled, "the question answered")
	_undo(s)
	assert_false(_rebooting(sk).has(true), "UNDO takes it back")
	# The same press, answered by a tap on the machine itself.
	_tap(vp, rb)
	_tap(vp, s._mech_views[2].get_global_rect().get_center())
	assert_eq(_rebooting(sk), [false, false, true], "a tap on a machine answers as its die does")
	_undo(s)
	# A machine's own readout open: the press reboots it at once.
	_tap(vp, s._mech_views[0].get_global_rect().get_center())
	assert_eq(s._pop, {"mech": 0}, "a tap on a machine reads it")
	_tap(vp, rb)
	assert_eq(_rebooting(sk), [true, false, false], "REBOOT with a machine's readout open reboots that machine")
	assert_true(s._pop.is_empty(), "its readout shut")
	_undo(s)
	# Its die's readout open: the same.
	_tap_die(vp, s, 1)
	assert_eq(s._pop, {"die": 1}, "a tap on a die reads it")
	_tap(vp, rb)
	assert_eq(_rebooting(sk), [false, true, false], "and REBOOT with a die's readout open reboots its machine")
	_undo(s)
	# A die dropped on the control.
	var from: Vector2 = s._dice[2].get_global_rect().get_center()
	_drag(vp, from, rb - from)
	assert_eq(_rebooting(sk), [false, false, true], "a die dropped on REBOOT gives its machine's turn")
	assert_false(s._ghost.visible, "the die in hand set down")
	_undo(s)
	# The question taken back: a second press, a tap on nothing.
	_tap(vp, rb)
	_tap(vp, rb)
	assert_false(s._reboot_armed, "a second press takes the question back")
	_tap(vp, rb)
	_tap(vp, Vector2(60.0, rb.y))
	assert_false(s._reboot_armed, "and so does a tap on nothing")
	assert_false(_rebooting(sk).has(true), "nothing rebooted by either")
	# A machine that has spent may not: its die's tap is no answer, and reads it as ever.
	assert_true(sk.assign(0, sk.field_foes()[0]), "the first machine spends its die")
	s._refresh()
	_tap(vp, rb)
	assert_true(s._reboot_armed, "the others may still, so the control asks")
	_tap_die(vp, s, 0)
	assert_false(_rebooting(sk).has(true), "a machine that has spent is no answer")
	assert_false(s._reboot_armed, "the question is let go")
	assert_eq(s._pop, {"die": 0}, "and the tap reads its die as ever")
	vp.free()


func _rebooting(sk: Skirmish) -> Array:
	var out: Array = []
	for ms in sk.mechs:
		out.append(ms.rebooting)
	return out


func _tap(vp: Viewport, at: Vector2) -> void:
	_finger(vp, at, true)
	_finger(vp, at, false)


## A tap on a die lands once its double-tap window has passed: the wait, then the frame that
## would land it.
func _tap_die(vp: Viewport, s: SkirmishScreen, i: int) -> void:
	_tap(vp, s._dice[i].get_global_rect().get_center())
	OS.delay_msec(int(DieFaceView.DOUBLE_TAP_SECONDS * 1000.0) + 40)
	s._dice[i]._process(0.016)


func _undo(s: SkirmishScreen) -> void:
	s._undo_from = 0
	s._on_undo()


func test_off_the_screen_has_no_reboot_control() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	sk.add_mech(db.make_mech(_a_chassis(db)))
	sk.add_foes([Foe.make("dummy", 900, 0)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	assert_true(s._reboot_btn == null, "the game as built shows none")
	var chips: Array[String] = []
	for r in s._mech_rows(0):
		chips.append(str(r[2]))
	assert_false(chips.any(func(c: String) -> bool: return c.contains("eboot")), "nor any of its chips")
	s.free()

extends TestCase

## The reboot, the shield's and the heat's rule (Ryan, 13 November; folded in 15 November;
## docs/briefs/refit_pass.md, section 22, has his words and the spec these tests follow line by
## line). Numbers are in tens; every piece here is synthetic.

const L := Face.Reach.DIRECT
const K := Face.Keyword
const SKIRMISH_SCENE := preload("res://game/skirmish/skirmish_screen.tscn")

## Cooling and regen granted, as a module or a passive would: a chassis has none of its own.
const RADIATOR := {"id": "radiator", "name": "Radiator", "description": "", "effects": [
	{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 15}]}
const MENDER := {"id": "mender", "name": "Mender", "description": "", "effects": [
	{"trigger": "static", "effect": "add_stat", "stat": "shield_regen", "value": 5}]}
## A hull hit that stands a shield up, a gain by another road than the regen.
const LINER := {"id": "liner", "name": "Liner", "description": "", "effects": [
	{"trigger": "on_hull_damage", "effect": "add_shield", "value": 10}]}
## A reboot blasts what it vents on every foe, 1 for every 2 heat.
const BOILER := {"id": "boiler", "name": "Boiler", "description": "", "effects": [
	{"trigger": "static", "effect": "reboot_release", "value": 1, "per": 2}]}


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


## Nothing cools or mends by itself, and what a module or a passive grants does.
func test_a_machine_cools_and_mends_only_by_what_it_is_granted() -> void:
	var bare := _mech(1, "A", _gun(10))
	bare.shield = 30
	var plain := _fight([bare], [Foe.make("dummy", 900, 0)])
	plain.start_round()
	assert_eq(bare.shield, 30, "no regen of its own")
	plain.assign(0, plain.front[0])
	plain.end_round()
	plain.start_round()
	assert_eq(plain.mechs[0].heat, 10, "and no cooling of its own")
	assert_eq([bare.cooling, bare.shield_regen], [0, 0], "the two stats read nothing on a bare machine")
	var m := _mech(1, "A", _gun(20))
	m.shield = 30
	m.grant_passive(RADIATOR)
	m.grant_passive(MENDER)
	assert_eq([m.cooling, m.shield_regen], [15, 5], "and what is granted, on one that carries it")
	var sk := _fight([m], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	assert_eq(m.shield, 35, "a granted regen lands")
	sk.assign(0, sk.front[0])
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].heat, 5, "and a granted cooling, fifteen off the twenty")
	assert_eq(m.shield, 40, "the regen again, up to the maximum")


func test_a_reboot_drops_the_shield_and_vents_the_heat_at_once_and_the_shield_is_back_next_round() -> void:
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
	assert_eq(ms.heat, 0, "and its heat with it: shunted as the shield drops (Ryan, 17 November)")
	assert_true("\n".join(sk.log).contains("A reboots: shield -15, heat -10, back next round"), "the log says what it gave up")
	sk.end_round()
	assert_eq(m.hull, 75, "the enemy's turn finds it bare: the whole blow on the hull")
	sk.start_round()
	assert_eq([ms.heat, m.shield], [0, 40], "round three opens cold still, and whole")
	assert_false(ms.rebooting or ms.shield_broken or ms.overheated, "and clear of all three states")
	assert_true(sk.can_reboot(0), "free to reboot again")


func test_only_a_machine_that_has_spent_nothing_may_reboot() -> void:
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
	Skirmish.overheat_scale = 2
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m], [Foe.make("dummy", 9000, 0)])
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.hull, 180, "two hull a stack")


func test_the_first_overheat_breaks_the_shield_once_between_reboots() -> void:
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


## A reboot vents what stands past the maximum as its shield drops (Ryan, 17 November, of the
## heat that stayed on the gauge until the recovery: "it didn't make sense to have that overheat
## hanging around and not hurting the mech"; "Maybe the heat gets shunted when the shield gets
## taken down?"), so its turn has nothing to burn, and no rule spares it.
func test_a_reboot_vents_what_stood_past_the_maximum_so_its_turn_burns_nothing() -> void:
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
	assert_eq([ms.heat, ms.overheat_stacks()], [0, 0], "the reboot vents it all at once, the stacks past its maximum too")
	assert_false(ms.overheated, "and it is free to overheat again")
	assert_eq(int(sk.forecast(ms)["overheat"]), 0, "so the forecast shows no burn")
	sk.end_round()
	assert_eq(m.hull, 190, "the turn of its reboot burns nothing: an overshoot pays once")
	assert_true(sk.overheats.is_empty(), "and is no overheat")
	sk.start_round()
	assert_eq([ms.heat, ms.overheat_stacks(), m.shield], [0, 0, 40], "back cold and whole")


## A reboot opens a sealed machine (Ryan, 17 November: "Polar bear unseals when rebooting. It's
## a good change because you're never accidentally stuck sealed, and a weaponless build is
## possible if you wanted it for some reason"): the seal and its armour go as the die drops, so
## the seal's clock adds nothing that turn, and it comes back open. Synthetic passive.
func test_a_reboot_opens_a_sealed_machine() -> void:
	var m := _mech(1, "A", Die.single(Face.buff("overcharged", 1)), 40, 200, 30)
	m.grant_passive({"id": "lockdown", "name": "Lockdown", "description": "", "effects": [
		{"trigger": "static", "effect": "seal_form"}]})
	var sk := _fight([m], [Foe.make("brute", 900, 25)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	assert_true(sk.assign(0, null), "a buff on itself")
	assert_true(Effects.is_sealed(m), "seals it")
	sk.end_round()
	assert_eq(ms.heat, int(Effects.STATUS["sealed"]["seal_heat"]), "sealed, it ran hotter as its turn ended")
	var hull := m.hull
	sk.start_round()
	assert_true(sk.can_reboot(0), "sealed, it may reboot: it is never stuck in its shell")
	assert_true(sk.reboot_mech(0), "and does")
	assert_false(Effects.is_sealed(m), "the reboot opens it")
	assert_eq(m.armour, 0, "the seal's armour gone with it")
	assert_true("\n".join(sk.log).contains("A opens as it reboots"), "the log says so")
	sk.end_round()
	assert_eq(ms.heat, 0, "open, the seal's clock adds nothing to the gauge it vented")
	assert_eq(m.hull, hull - 25, "and the blow lands whole: bare, and behind no shell")
	sk.start_round()
	assert_false(Effects.is_sealed(m), "it comes back open")
	assert_eq(m.shield, 40, "and whole")


## One vent, at the drop: heat that lands on a machine while it reboots is its own, there as the
## next round opens, and what it carries past its maximum as the turn ends burns like any
## machine's. A session's read where his words give none (17 November), his to overrule.
func test_heat_laid_on_a_rebooting_machine_stays_and_burns_like_any() -> void:
	var m := _mech(1, "A", _gun(10), 40, 200, 30)
	var sk := _fight([m], [Foe.make("dummy", 9000, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	sk.start_round()
	sk.reboot_mech(0)
	sk._add_heat(ms, 6)
	sk.end_round()
	assert_eq(m.hull, 200, "six laid on it after the vent, under its maximum: nothing burns")
	sk.start_round()
	assert_eq([ms.heat, m.shield], [6, 40], "its shield is back, and the six are still on its gauge")
	sk.reboot_mech(0)
	sk._add_heat(ms, 35)
	sk.end_round()
	assert_eq(m.hull, 195, "thirty-five laid on it while it reboots, five past its maximum, burn like any machine's")


## A machine out of reach does not burn: a Swallowed one has no turn to give, so it cannot
## reboot either; a Phased one is damaged by nothing (Ryan, 16 November: "it shouldn't take
## damage from overheating since we don't need the exception. It does accumulate the stacks,
## though, which it will feel the round after") and acts, so it may reboot, bare where nothing
## reaches it (15 November: "it's a safe reboot if you can pull it off").
func test_a_machine_out_of_reach_does_not_burn_and_a_phased_one_may_reboot() -> void:
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m, _mech(2, "B", _gun(0))], [Foe.make("dummy", 9000, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.hull, 190, "it burns the turn it passes its maximum")
	sk.start_round()
	Effects.lay_timer(m, Effects.STATUS["swallowed"], "test", 1)
	assert_true(Skirmish.is_out(ms), "Swallowed, it is out of the fight this round")
	assert_false(sk.can_reboot(0), "and cannot reboot")
	sk.end_round()
	assert_eq(m.hull, 190, "so the burn does not ask it to: nothing burns while it is out")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 180, "back in the fight, the stacks it still carries burn again")
	sk.start_round()
	Effects.grant_for_rounds(m, Effects.STATUS["phased"], "test", sk.round)
	assert_true(Skirmish.is_out(ms), "Phased, it is out of reach this round")
	assert_true(sk.can_reboot(0), "and free to reboot: the safe one")
	assert_eq(int(sk.forecast(ms)["overheat"]), 0, "the forecast shows no burn on it this turn")
	sk.assign(0, sk.front[0])
	assert_eq(ms.overheat_stacks(), 50, "it fires again, and its heat past the maximum grows: the stacks accumulate")
	sk.end_round()
	assert_eq(m.hull, 180, "Phased, it takes nothing from its own heat")
	assert_true(sk.overheats.is_empty(), "and the turn is no overheat")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 130, "back in reach, it feels every stack the round after")
	sk.start_round()
	Effects.grant_for_rounds(m, Effects.STATUS["phased"], "test", sk.round)
	assert_true(sk.reboot_mech(0), "it gives a Phased turn to the reboot")
	sk.end_round()
	assert_eq(m.hull, 130, "and burns nothing that turn")
	sk.start_round()
	assert_eq([ms.heat, m.shield], [0, 40], "cold and whole the round after")


func test_a_blow_that_takes_a_shield_to_nothing_breaks_it_and_a_lesser_one_does_not() -> void:
	var m := _mech(1, "A", _gun(0), 40, 200)
	var sk := _fight([m], [Foe.make("brute", 900, 40)])
	sk.start_round()
	sk.end_round()
	assert_eq([m.shield, m.hull], [0, 200], "spent exactly, nothing on the hull")
	assert_true(sk.mechs[0].shield_broken, "and broken all the same")
	assert_true("\n".join(sk.log).contains("A's shield is broken: no shield until it reboots"), "the log says so")
	var m2 := _mech(2, "B", _gun(0), 40, 200)
	var s2 := _fight([m2], [Foe.make("maw", 900, 30)])
	s2.start_round()
	s2.end_round()
	assert_eq([m2.shield, m2.hull], [10, 200], "a blow under its number leaves the shield standing")
	assert_false(s2.mechs[0].shield_broken, "which is not broken")


func test_a_broken_shield_gains_none_by_any_method_until_it_reboots() -> void:
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


## The vent that explodes (Ryan, 17 November: "the reboot vent is the one that explodes"): a
## machine whose reboot blasts what it vents lands it on every foe as its shield drops; a turn it
## ends with its die unspent releases nothing, the release a passed turn's until then.
func test_a_reboots_vent_explodes_and_an_unspent_die_releases_nothing() -> void:
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
	assert_eq(ms.heat, 10, "ten held")
	sk.end_round()
	assert_eq(foe.hp, hp, "a turn it ends with its die unspent opens no valve")
	assert_true(sk.releases.is_empty(), "nothing released")
	sk.start_round()
	assert_true(sk.reboot_mech(0), "it reboots")
	assert_eq(foe.hp, hp - 5, "and its vent lands on the foe at once: 1 for every 2 heat it sheds")
	assert_eq(ms.heat, 0, "left cold")
	assert_eq(sk.releases.size(), 1, "the screen is told")


func test_the_round_preview_plays_a_reboot_bare_and_a_burn_that_stands() -> void:
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
	var m := _mech(1, "A", _gun(40), 40, 200, 30)
	var sk := _fight([m], [Foe.make("dummy", 9000, 0)])
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	sk.start_round()
	var hot: Skirmish.MechState = (SaveGame.clone_skirmish(sk) as Skirmish).mechs[0]
	assert_true(hot.shield_broken and hot.overheated and hot.overheat_stacks() == 10, "a copy before the reboot is broken and overheated as the fight's machine is")
	sk.reboot_mech(0)
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	var cm: Skirmish.MechState = copy.mechs[0]
	assert_true(cm.rebooting and cm.shield_broken and not cm.overheated and cm.heat == 0, "the copy's machine is rebooting, broken and vented as the fight's is")
	copy.end_round()
	copy.start_round()
	assert_eq([cm.heat, cm.unit.shield], [0, 40], "and the copy's next round opens cold and whole")
	assert_true(sk.mechs[0].rebooting, "the fight itself untouched")


## The fight bot's first play of it (Policy._reboot_first and _reboot_idle), so the runners still
## finish a fight under the rule: a machine past its maximum gives its turn, one whose entry
## would pass it reboots where little shield is at stake, and a die left idle is a reboot too.
func test_the_bot_reboots_and_plays_the_fight_out() -> void:
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
	assert_false(s2.mechs[0].rebooting, "cold and whole, a reboot buys its entry no room: even the blind bot holds")
	var m3 := _mech(3, "C", _gun(40, 10), 40, 300, 30)
	var s3 := _fight([m3], [Foe.make("brute", 900, 30)])
	s3.start_round()
	s3.mechs[0].heat = 10
	Policy.make(Policy.BLIND, 1).play_round(s3)
	assert_true(s3.mechs[0].rebooting, "with heat to shed the blind bot reads no picks: it reboots where its entry would pass the maximum")


## A chassis the game can run, whichever content lists first: the screen wants a real machine's
## model, and no test names one.
func _a_chassis(db: ContentDB) -> String:
	for id in db.chassis.keys():
		if db.chassis_runnable(str(id)):
			return str(id)
	return ""


## The screen under the trial (a debug build's): a REBOOT control on the dice's row, a drop's
## target and no button, live while any machine may reboot; a die dropped there gives its
## machine's turn (the gesture is the live test's, below); the three states as chips, the two
## debuffs said so; the hold's cooling reading what the rule leaves of it; UNDO taking it back.
func test_the_screen_s_reboot_control_is_a_drop_s_target_and_shows_the_three_states() -> void:
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
	assert_false(s._reboot_btn.disabled, "live while a machine has spent nothing")
	assert_eq(s._reboot_btn.mouse_filter, Control.MOUSE_FILTER_IGNORE, "and no button: a touch passes through it")
	assert_true(s._reboot_btn.socket and not s._reboot_btn.pressed.has_connections(), "a drop's target, nothing wired to a press")
	assert_eq(s._reroll_btn.position.x + s._reroll_btn.size.x * 0.5, s.W * 0.5, "REROLL centred under the dice")
	assert_true(s._end_btn.position.x + s._end_btn.size.x < s._reboot_btn.position.x and s._reboot_btn.position.x + s._reboot_btn.size.x < s._undo_btn.position.x, "the control between END TURN and UNDO")
	assert_eq(s._reboot_btn.position.y, s._end_btn.position.y, "on the bottom row")
	ms.heat = ms.heat_max + 3
	s._refresh()
	var chips: Array[String] = []
	for r in s._mech_rows(0):
		chips.append(str(r[2]))
	assert_true(chips.has("Debuff, Overheated ×3: hull -3 every turn until it reboots"), "heat past the maximum is a debuff, a stack a point: %s" % str(chips))
	assert_true(s._do_reboot(0), "its die dropped on REBOOT, the machine reboots")
	assert_true(ms.rebooting, "its turn given")
	assert_eq(m.shield, 0, "its shield down at once")
	assert_true(s._reboot_btn.disabled, "and the control goes dark, no machine left that may")
	assert_false(s._do_reboot(0), "a machine rebooting may not again")
	chips.clear()
	for r in s._mech_rows(0):
		chips.append(str(r[2]))
	assert_true(chips.has("Rebooting: vented and bare this turn, its shield whole the next"), "the machine says it is rebooting: %s" % str(chips))
	assert_eq(ms.heat, 0, "and its heat went with its shield")
	s._undo_from = 0
	s._on_undo()
	assert_false(sk.mechs[0].rebooting, "UNDO takes the reboot back")
	sk.mechs[0].unit.shield = 0
	sk._note_break(sk.mechs[0])
	chips.clear()
	for r in s._mech_rows(0):
		chips.append(str(r[2]))
	assert_true(chips.has("Debuff, Broken: no shield until it reboots"), "a broken shield is a debuff of its own: %s" % str(chips))
	s._on_mech_held(0)
	assert_false(s._details_entry.text().contains("Cooling"), "the hold names no cooling on a machine that is granted none: %s" % s._details_entry.text())
	sk.mechs[0].unit.grant_passive(RADIATOR)
	var granted: Array = []
	for l in s._mech_hold_lines(0):
		granted.append(str(l["text"]))
	assert_true(granted.any(func(t: String) -> bool: return t.contains("Cooling 0 (+15")), "and what a loadout grants, as a gain over nothing: %s" % str(granted))
	s.free()


## The control under a finger, as the phone delivers one. A die dragged onto it is the one way
## in (Ryan, 14 November: "dragging is the gesture we already have, we should stick with that"):
## in hand it lights its target, the drop lands a thumb's width past the drawing, and a machine
## that may not reboot darkens it. It is no button: a touch on it passes through and reboots
## nothing (the press that asked which machine was cut on his word the day it was built; the
## first cut had lit for a die's open readout alone, his "So I can't actually trigger a
## reboot"). Live: the fight's screen in a viewport, every touch pushed through it.
func live_test_a_die_dragged_onto_reboot_is_the_one_way_in() -> void:
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
	assert_false(s._reboot_btn.disabled, "live at rest: a machine may reboot")
	assert_false(s._reboot_btn.pulse and not HudButton.PULSE_DEBUG, "and still, no die in hand")
	# A die in hand lights its target; the drop lands a thumb's width past the drawing too.
	var from: Vector2 = s._dice[2].get_global_rect().get_center()
	var out := from + Vector2(0.0, -60.0)
	_finger(vp, from, true)
	_slide(vp, from, out)
	assert_eq(s._drag_from, 2, "the die in hand")
	assert_true(s._reboot_btn.pulse and not s._reboot_btn.disabled, "a die in hand lights REBOOT as its target, pulsing")
	assert_false(s._reboot_btn.filled, "not filled until the die is over it")
	var drop: Vector2 = s.reboot_drop_rect().position + Vector2(4.0, 4.0)
	assert_false(s._reboot_btn.get_global_rect().has_point(drop), "a point past the drawing, inside the drop's room")
	_slide(vp, out, drop)
	assert_true(s._reboot_btn.filled, "filled with the die over it")
	_finger(vp, drop, false)
	assert_eq(_rebooting(sk), [false, false, true], "a die dropped on REBOOT gives its machine's turn")
	assert_false(s._ghost.visible, "the die in hand set down")
	assert_false(s._reboot_btn.filled or (s._reboot_btn.pulse and not HudButton.PULSE_DEBUG), "and the control at rest")
	_undo(s)
	assert_false(_rebooting(sk).has(true), "UNDO takes it back")
	# The drop's room stops short of the dice above: a die set back on its own slot reboots nothing.
	for d in s._dice:
		assert_false(s.reboot_drop_rect().intersects(d.get_global_rect()), "REBOOT's drop clear of a die's slot")
	for v in s._mech_views:
		assert_false(s.reboot_drop_rect().intersects(v.get_global_rect()), "and of a machine, a die's other target")
	assert_false(s.reboot_drop_rect().intersects(s._reroll_btn.get_global_rect()), "and of REROLL, in the row above")
	assert_false(s.reboot_drop_rect().intersects(s._end_btn.get_global_rect()) or s.reboot_drop_rect().intersects(s._undo_btn.get_global_rect()), "and of END TURN and UNDO beside it")
	# A die dropped anywhere else is no reboot: on a foe it is spent, on nothing it is set back.
	_finger(vp, from, true)
	_slide(vp, from, out)
	_finger(vp, out, false)
	assert_false(_rebooting(sk).has(true), "a die set back reboots nothing")
	# A machine that has spent and still holds a die (two things a round) is no target: its
	# die in hand darkens the control, and a drop there sets the die back.
	sk.mechs[1].spends = 1
	var held: Vector2 = s._dice[1].get_global_rect().get_center()
	_finger(vp, held, true)
	_slide(vp, held, rb)
	assert_eq(s._drag_from, 1, "its die in hand")
	assert_true(s._reboot_btn.disabled and not s._reboot_btn.filled, "a die whose machine has spent darkens REBOOT")
	_finger(vp, rb, false)
	assert_false(_rebooting(sk).has(true), "and a drop there reboots nothing")
	assert_false(s._reboot_btn.disabled, "the die set back, the control live again for the others")
	sk.mechs[1].spends = 0
	s._refresh()
	# No button: a touch on it reboots nothing, with a machine's readout open or its die's, and
	# passes through to the ground, which shuts the readout as a tap on nothing does.
	_tap(vp, rb)
	assert_false(_rebooting(sk).has(true), "a touch on REBOOT reboots nothing")
	_tap(vp, s._mech_views[0].get_global_rect().get_center())
	assert_eq(s._pop, {"mech": 0}, "a tap on a machine reads it")
	_tap(vp, rb)
	assert_false(_rebooting(sk).has(true), "nor with a machine's readout open")
	assert_true(s._pop.is_empty(), "the touch falls through: the readout shuts, as on a tap on nothing")
	_tap_die(vp, s, 1)
	assert_eq(s._pop, {"die": 1}, "a tap on a die reads it")
	_tap(vp, rb)
	assert_false(_rebooting(sk).has(true), "nor with a die's")
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


## A finger already down slid from `a` to `b`, not lifted: its motion as Android delivers it.
func _slide(vp: Viewport, a: Vector2, b: Vector2, steps: int = 8) -> void:
	for k in range(1, steps + 1):
		var at := a.lerp(b, float(k) / steps)
		var mm := InputEventMouseMotion.new()
		mm.device = InputEvent.DEVICE_ID_EMULATION
		mm.position = at
		mm.global_position = at
		mm.relative = (b - a) / steps
		mm.button_mask = MOUSE_BUTTON_MASK_LEFT
		vp.push_input(mm)
		var sd := InputEventScreenDrag.new()
		sd.index = 0
		sd.position = at
		sd.relative = (b - a) / steps
		vp.push_input(sd)




## The quick turn's reboot (the Needletail's Quick-turn Avionics Relay; Ryan, 18 November: "So it
## may act, and then the second spend needs to be on the reboot. Doesn't matter what the action
## is. It's pure tempo and flexibility"), on a synthetic one-of-each passive: one spend of either
## kind, then the reboot as its second, the vent taking that spend's heat with the rest; none after
## two spends; and the reboot standing whatever the first spend left its die.
const RELAY := {"id": "relay", "name": "Relay", "description": "", "effects": [{"trigger": "static", "effect": "one_of_each"}]}


func test_a_one_of_each_machine_acts_and_then_reboots_as_its_second_spend() -> void:
	var gun := Face.attack(5, L, [], 20)
	var mark := Face.attack(0, Face.Reach.INDIRECT, [K.EXPOSE], 0)
	var m := _mech(1, "Spotter", Die.of([gun, mark]))
	m.grant_passive(RELAY)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([m], [foe])
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.can_reboot(0), "nothing spent: it may reboot as any machine may")
	assert_true(sk.assign(0, foe), "the gun first")
	assert_eq(ms.heat, 20, "its heat on the gauge")
	assert_true(sk.can_reboot(0), "one spend made: its second may be the reboot")
	assert_true(sk.reboot_mech(0), "rebooted as its second spend")
	assert_eq([ms.heat, m.shield, foe.hp], [0, 0, 895], "the gun landed, and the vent took its heat with the rest as the shield dropped")
	assert_true(ms.assigned and ms.rebooting, "its turn is done")
	assert_true("\n".join(sk.log).contains("reboots after its action"), "the log says so")
	assert_true(sk.undo(), "the undo takes the reboot back")
	ms = sk.mechs[0]
	assert_true(not ms.rebooting and ms.heat == 20 and not ms.assigned, "back at its second action: %s" % str([ms.rebooting, ms.heat, ms.assigned]))
	assert_true(sk.assign(0, sk.front[0]), "the mark as its second action instead")
	assert_false(sk.can_reboot(0), "two spends made: no reboot this turn")
	sk.end_round()
	sk.start_round()
	ms = sk.mechs[0]
	ms.face_index = 1
	assert_true(sk.assign(0, sk.front[0]), "equipment first this round")
	assert_true(sk.can_reboot(0), "and the reboot as its second all the same: whatever the action")
	var plain := _mech(2, "Plain", _gun(10))
	var other := _fight([plain], [Foe.make("dummy", 900, 0)])
	other.start_round()
	assert_true(other.assign(0, other.front[0]), "a machine without the rule spends")
	assert_false(other.can_reboot(0), "and has given up its reboot")


## A die left with nothing lit to flip to keeps the reboot (Ryan, 18 November: "The dark-die no
## reboot is unintuitive. That would be the exact time a player would want to reboot. And it
## limits a build that only has weapons, just to leverage the reboot turn"): a weapons-only die,
## its one action then the reboot, on the engine and on the screen.
func test_a_die_with_nothing_to_flip_to_after_its_action_still_reboots() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	sk.keeps_undo = true
	var m := db.make_mech(_a_chassis(db))
	m.die = Die.of([Face.attack(5, L, [], 10), Face.attack(5, L, [], 10)])
	m.grant_passive(RELAY)
	sk.add_mech(m)
	sk.add_foes([Foe.make("dummy", 900, 0)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(sk.assign(0, sk.front[0]), "a gun, and no equipment to flip to")
	assert_true(ms.assigned, "its die done: no second action")
	assert_true(sk.can_reboot(0), "and still it may reboot: one action made")
	s._refresh()
	assert_true(s._dice[0].can_drag, "its done die lifts for REBOOT")
	assert_true(s._do_reboot(0), "its die dropped on REBOOT, it reboots")
	assert_eq(ms.heat, 0, "the vent took the gun's heat")
	s.free()


func test_no_machine_but_the_needletail_reboots_after_a_rapid_spend() -> void:
	var m := _mech(1, "Plain", Die.of([Face.attack(3, L, [K.RAPID], 2), Face.attack(3, L, [], 2)]))
	var sk := _fight([m], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "a Rapid gun")
	assert_false(ms.assigned, "it acts again")
	assert_false(sk.can_reboot(0), "but a Rapid spend is a spend: no reboot after it (Ryan, 18 November: \"Normal units cannot even rapid before rebooting\")")


func test_the_bot_spends_before_a_reboot_it_owes_and_reboots_as_its_second() -> void:
	var gun := Face.attack(5, L, [], 4)
	var mark := Face.attack(0, Face.Reach.INDIRECT, [K.EXPOSE], 0)
	var m := _mech(1, "Spotter", Die.of([gun, mark]), 40, 100, 30)
	m.grant_passive(RELAY)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([m], [foe])
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 34   # past its maximum: it owes a reboot
	ms.face_index = 0
	var bot := Policy.make(Policy.GREEDY, 1)
	bot.play_round(sk, false)
	assert_true(ms.rebooting, "it rebooted")
	assert_eq(ms.spends, 1, "after one spend: the gun it showed, its heat free before the vent")
	assert_eq([foe.hp, ms.heat], [895, 0], "the gun landed, and the vent took the heat")
	var plain := _mech(2, "Plain", _gun(4, 5), 40, 100, 30)
	var other := _fight([plain], [Foe.make("dummy", 900, 0)])
	other.start_round()
	other.mechs[0].heat = 34
	Policy.make(Policy.GREEDY, 1).play_round(other, false)
	assert_eq(other.mechs[0].spends, 0, "a machine without the rule reboots first and spends nothing")
	assert_true(other.mechs[0].rebooting, "rebooted")


## A die with nothing lit is the very moment to reboot (Ryan, 18 November: "If somehow all the
## machine's faces were jammed or on cooldown - which is a legitimate situation ... that's the
## exact time to want to reboot"): a dark entry is no spend, so the machine has spent nothing,
## its die is in play, and it may reboot, on the engine and on the screen.
func test_a_machine_whose_whole_die_is_dark_may_reboot() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	sk.keeps_undo = true
	var m := db.make_mech(_a_chassis(db))
	m.die = Die.of([Face.attack(3, L, [], 4), Face.attack(0, Face.Reach.INDIRECT, [K.EXPOSE], 0)])
	sk.add_mech(m)
	sk.add_foes([Foe.make("dummy", 900, 0)])
	var s := SkirmishScreen.new()
	s.setup(sk)
	var ms: Skirmish.MechState = sk.mechs[0]
	Effects.disable_entry(m, 0, "cooldown", sk.round + 1)   # one on a cooldown
	Effects.disable_entry(m, 1, "foe:x", sk.round)          # the other jammed by a foe
	ms.heat = 9
	s._refresh()
	assert_false(sk.can_spend(0), "nothing on its die to spend")
	assert_true(sk.can_reboot(0), "and still it may reboot: a dark entry is no spend")
	assert_true(s._dice[0].can_drag, "its die lifts")
	assert_false(s._reboot_btn.disabled, "and REBOOT takes it")
	assert_true(s._do_reboot(0), "its die dropped on REBOOT, it reboots")
	assert_eq([ms.heat, m.shield], [0, 0], "vented, the shield down")
	s.free()

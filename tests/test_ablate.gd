extends TestCase

## Ablate on a machine (Ryan, 15 November: one rule on both sides, in the place of Burning as
## heat; "hits shield first, I think. Pretty deadly otherwise. Bypasses armour when damaging
## hull"; "Tick of ablate ignores barrier yes"). A point a stack as the player's turn ends, the
## shield first and then the hull past armour, then a stack fades. The foe's half is Burning's
## rule under its new word, and tests/test_skirmish.gd keeps its tests. Every piece is synthetic.

const L := Face.Reach.DIRECT
const K := Face.Keyword

## A hull hit that heats its machine a point, as a passive that reads hull damage would.
const TALLY := {"id": "tally", "name": "Tally", "description": "", "effects": [
	{"trigger": "on_hull_damage", "effect": "gain_heat", "value": 1}]}
## A hit on the shield that heats it a point: a foe's blow its shield took, never a tick.
const FLINCH := {"id": "flinch", "name": "Flinch", "description": "", "effects": [
	{"trigger": "on_shield_hit", "effect": "gain_heat", "value": 1}]}
## Regen granted, as a module would.
const MENDER := {"id": "mender", "name": "Mender", "description": "", "effects": [
	{"trigger": "static", "effect": "add_stat", "stat": "shield_regen", "value": 5}]}


func _mech(id: int, name: String, shield: int = 10, hull: int = 100, d: Die = null) -> Unit:
	var u := Unit.mech(id, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.heat_max = 30
	u.die = d if d != null else Die.single(Face.attack(1, L, [], 0))
	return u


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1)
	sk.keeps_undo = true
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	return sk


func _ablating(u: Unit, n: int) -> void:
	Effects.stack(u, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "test", n, Effects.status_decay(Effects.STATUS["ablating_mech"]))


func _per() -> int:
	return Effects.status_value("ablating_mech", "tick_hp")


## The shield first, then the hull past armour, a point a stack, and a stack fades each turn.
func test_ablating_takes_the_shield_first_then_the_hull_past_armour() -> void:
	assert_eq(_per(), 1, "a point a stack")
	var u := _mech(1, "A", 2, 100)
	u.armour = 5
	var sk := _fight([u], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	_ablating(u, 3)
	var heat := sk.mechs[0].heat
	sk.end_round()
	assert_eq([u.shield, u.hull], [0, 99], "three points: the shield's two, then one off the hull, the armour taking nothing off it")
	assert_eq(sk.mechs[0].heat, heat, "and no heat: Ablating is damage")
	assert_eq(Effects.stacks_of(u, "ablating_mech"), 2, "a stack fades")
	assert_eq(sk.ablations.size(), 1, "on record for the replay")
	var rec: Dictionary = sk.ablations[0]
	assert_eq([int(rec["mech"]), int(rec["points"]), int(rec["shield_lost"]), int(rec["hull_lost"]), int(rec["shield"]), int(rec["hull"])], [0, 3, 2, 1, 0, 99], "the record keeps what it took and what it left")
	assert_true("\n".join(sk.log).contains("A is ablating: shield -2, hull -1"), "the log says what each gauge lost")
	sk.start_round()
	sk.end_round()
	assert_eq([u.hull, Effects.stacks_of(u, "ablating_mech")], [97, 1], "two the turn after")
	sk.start_round()
	sk.end_round()
	assert_eq([u.hull, Effects.has(u, "ablating_mech")], [96, false], "one, and it is gone")
	sk.start_round()
	sk.end_round()
	assert_eq(u.hull, 96, "nothing more")
	assert_true(sk.ablations.is_empty(), "and no record on a turn it took nothing")


## A tick is no blow: a Barrier neither stops it nor is spent on it.
func test_a_tick_ignores_a_barrier_and_spends_none() -> void:
	var u := _mech(1, "A", 10, 100)
	var sk := _fight([u], [Foe.make("revenant", 900, 4)])
	sk.start_round()
	_ablating(u, 2)
	Effects.grant_buff(u, "barrier", 1, "test", sk.round)
	sk.end_round()
	assert_eq(u.shield, 8, "the tick took its two through the Barrier, and the Barrier took the foe's blow after it")
	assert_eq(u.hull, 100, "nothing reached the hull")


## A shield its Ablating takes to nothing is broken like any other, and gains none until the
## reboot.
func test_a_shield_ablated_to_nothing_is_broken() -> void:
	var u := _mech(1, "A", 2, 100)
	u.grant_passive(MENDER)
	var sk := _fight([u], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	_ablating(u, 2)
	sk.end_round()
	assert_eq(u.shield, 0, "the two it had")
	assert_true(sk.mechs[0].shield_broken, "broken, whatever took it there")
	sk.start_round()
	assert_eq(u.shield, 0, "and its granted regen raises nothing until it reboots")


## What reaches the hull is hull damage for whatever reads it; what the shield takes is no hit
## on the shield.
func test_what_reaches_the_hull_is_hull_damage_and_the_shields_share_is_no_hit() -> void:
	var bare := _mech(1, "A", 0, 100)
	bare.grant_passive(TALLY)
	var sk := _fight([bare], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	_ablating(bare, 1)
	sk.end_round()
	assert_eq(bare.hull, 99, "a point off the bare hull")
	assert_eq(sk.mechs[0].heat, 1, "and it is hull damage: the passive that reads it fires")
	var shielded := _mech(2, "B", 10, 100)
	shielded.grant_passive(TALLY)
	shielded.grant_passive(FLINCH)
	var s2 := _fight([shielded], [Foe.make("dummy", 900, 0)])
	s2.start_round()
	_ablating(shielded, 1)
	s2.end_round()
	assert_eq([shielded.shield, shielded.hull], [9, 100], "the shield took it whole")
	assert_eq(s2.mechs[0].heat, 0, "no hull damage, and no blow on its shield either")


## A rebooting machine stands bare, so its tick lands on the hull; the reboot does not lift it.
func test_a_rebooting_machine_takes_its_tick_on_the_hull() -> void:
	var u := _mech(1, "A", 10, 100)
	var sk := _fight([u], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	_ablating(u, 2)
	assert_true(sk.reboot_mech(0), "nothing spent: it may reboot")
	sk.end_round()
	assert_eq(u.hull, 98, "bare through the turn: both points off the hull")
	sk.start_round()
	assert_eq(u.shield, 10, "whole as the next round opens")
	assert_eq(Effects.stacks_of(u, "ablating_mech"), 1, "and still Ablating: a reboot is no cleanse")


## Out of reach, two ways (Ryan, 16 November). A Phased machine takes no point and its stacks
## fade all the same ("Everything ticks during phased. It doesn't take damage but it's a way of
## waiting out a debuff"); a Swallowed one's wait ("Swallowed it's out of play so everything
## should pause"), and tick the turn it is back.
func test_a_phased_machines_stacks_fade_and_take_nothing_and_a_swallowed_ones_wait() -> void:
	var u := _mech(1, "A", 10, 100)
	var other := _mech(2, "B", 10, 100)
	var sk := _fight([u, other], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	_ablating(u, 2)
	Effects.grant_buff(u, "phased", 1, "test", sk.round)
	assert_eq(int(sk.forecast(sk.mechs[0])["ablated"]), 0, "the forecast counts none while it is Phased")
	sk.end_round()
	assert_eq([u.shield, u.hull], [10, 100], "nothing damages a Phased machine, its own tick included")
	assert_eq(Effects.stacks_of(u, "ablating_mech"), 1, "and a stack fades all the same")
	sk.start_round()
	assert_false(Skirmish.is_out(sk.mechs[0]), "back in reach")
	sk.end_round()
	assert_eq([u.shield, Effects.stacks_of(u, "ablating_mech")], [9, 0], "the turn it is back, the stack left takes its point and goes")
	var v := _mech(1, "A", 10, 100)
	var sk2 := _fight([v, _mech(2, "B", 10, 100)], [Foe.make("dummy", 900, 0)])
	sk2.start_round()
	_ablating(v, 2)
	Effects.lay_timer(v, Effects.STATUS["swallowed"], "test", 2)
	assert_eq(int(sk2.forecast(sk2.mechs[0])["ablated"]), 0, "the forecast counts none while it is Swallowed")
	sk2.end_round()
	sk2.start_round()
	sk2.end_round()
	assert_eq([v.shield, v.hull, Effects.stacks_of(v, "ablating_mech")], [10, 100, 2], "two turns out: no point taken and no stack faded")
	sk2.start_round()
	assert_false(Skirmish.is_out(sk2.mechs[0]), "back in the fight")
	sk2.end_round()
	assert_eq([v.shield, Effects.stacks_of(v, "ablating_mech")], [8, 1], "the turn it is back, it ticks as it would have")


## The bot's forecast and the screen's preview both count the tick, before the foes' blows.
func test_the_forecast_and_the_preview_count_the_tick_before_the_blows() -> void:
	var u := _mech(1, "A", 3, 100)
	var sk := _fight([u], [Foe.make("revenant", 900, 4)])
	sk.start_round()
	_ablating(u, 2)
	var fc := sk.forecast(sk.mechs[0])
	assert_eq(int(fc["ablated"]), 2, "two points as the turn ends")
	assert_eq([int(fc["shield_after"]), int(fc["hull_after"])], [0, 97], "the tick leaves one of shield, and the blow of four takes it and three of hull")
	var pv: Dictionary = sk.preview_round()["mechs"][0]
	assert_eq(int(pv["ablated"]), 2, "the preview says the same")
	assert_eq([int(pv["shield_after"]), int(pv["hull_after"])], [0, 97], "and lands on the same gauges")
	sk.end_round()
	assert_eq([u.shield, u.hull], [0, 97], "as the round then plays")


## Its Ablating can wreck a machine on its own turn, before the enemy acts.
func test_a_tick_can_wreck_a_machine_before_the_enemy_acts() -> void:
	var u := _mech(1, "A", 0, 2)
	var foe := Foe.make("revenant", 900, 4)
	var sk := _fight([u], [foe])
	sk.start_round()
	_ablating(u, 2)
	assert_true(bool(sk.forecast(sk.mechs[0])["destroyed"]), "the forecast warns of it")
	sk.end_round()
	assert_false(u.alive(), "the tick took its last two")
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "and the fight is lost on its own turn")
	assert_true(sk.turn_events.is_empty(), "before any foe struck")


## A weapon that ablates its firer (a synthetic one): its machine gains the stacks after the
## blow, the die in hand's preview counts the first tick, and the tick comes off its own shield.
func test_a_weapon_that_ablates_its_firer_pays_in_its_own_shield() -> void:
	var stoker := Face.attack(3, L, K.ABLATE)
	stoker.ablate = 2
	stoker.heat = 1
	stoker.self_ablate = 1
	assert_true(stoker.describe().contains("Ablate 1 on itself"), "the hold says it: %s" % stoker.describe())
	assert_true(stoker.has_unique_rule(), "a printed rule: the star")
	var u := _mech(1, "A", 10, 100, Die.single(stoker))
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	sk.start_round()
	assert_eq(int(sk.preview_round(0, foe)["mechs"][0]["ablated"]), _per(), "the round preview with the die in hand counts its own first tick")
	assert_eq(int(sk.forecast(sk.mechs[0])["ablated"]), 0, "and nothing without the die in hand")
	assert_true(sk.assign(0, foe), "fired")
	assert_eq(Effects.stacks_of(foe, "ablating"), 2, "the foe is Ablating, Ablate 2")
	assert_eq(Effects.stacks_of(u, "ablating_mech"), 1, "and so is its own machine, a stack")
	assert_eq(sk.mechs[0].heat, 1, "its heat is the gun's alone")
	sk.end_round()
	assert_eq(u.shield, 10 - _per(), "its own tick comes off its shield at the turn's end")
	assert_eq(sk.mechs[0].heat, 1, "and adds no heat")
	assert_false(Effects.has(u, "ablating_mech"), "then the stack fades")


## The bot prices a self-ablating piece by the shield it costs, and a cleanse by what the
## stacks would take.
func test_the_bot_prices_its_own_tick_and_a_cleanse_of_it() -> void:
	var stoker := Face.attack(3, L, K.ABLATE)
	stoker.ablate = 1
	stoker.self_ablate = 2
	var u := _mech(1, "A", 10, 100, Die.single(stoker))
	var sk := _fight([u], [Foe.make("dummy", 900, 0)])
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY, 1)
	assert_true(pol.self_ablate_cost(sk, sk.mechs[0], stoker) > 0.0, "two stacks on itself cost it")
	assert_eq(pol.self_ablate_cost(sk, sk.mechs[0], Face.attack(3, L)), 0.0, "a plain gun costs nothing of the kind")
	var clean := pol.cleanse_score(sk, sk.mechs[0])
	_ablating(u, 3)
	assert_true(pol.cleanse_score(sk, sk.mechs[0]) > clean, "and a cleanse is worth more on a machine that is Ablating")

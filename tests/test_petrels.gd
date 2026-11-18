extends TestCase

## The Storm Petrel's and the Giant Petrel's engines (Ryan's go, 21 October; built 30 October; the
## Storm Petrel's reworked 17 November), on synthetic passives and entries: the plate while the
## shield stands and the shield every point of heat gained stands up, what a spend at a foe lays on
## its own machine by its branches (Hardened for each foe reached, Charged), a debuff's Chain; the
## bank of unspent rerolls, the action bought with them, the kill that brings them and the roll on an
## ally. The branches' picks themselves are tests/test_branches.gd's.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT
const K := Face.Keyword

## The Storm Petrel's shape since 17 November: a point off every blow while the shield stands, and
## a point of shield for every point of heat it gains.
const RIOT := {"id": "riot", "name": "Riot", "description": "", "effects": [
	{"trigger": "static", "effect": "add_damage_taken", "value": -1, "when": "shield_up"},
	{"trigger": "on_heat_gain", "effect": "shield_per_heat", "value": 1}]}
## The Storm Petrel's branches' shapes (17 November): its lure's spend at a foe lays Hardened on
## itself, a stack for each foe reached, or Charged 2, scoped to that piece (`entry`).
const HARDEN := {"id": "harden", "name": "Harden", "description": "", "effects": [
	{"trigger": "static", "effect": "self_status", "status": "hardened", "value": 1, "per_foe": true, "entry": "test_lure"}]}
const CHARGE := {"id": "charge", "name": "Charge", "description": "", "effects": [
	{"trigger": "static", "effect": "self_status", "status": "charged", "value": 2, "entry": "test_lure"}]}


## A lure as the tests' locked piece, its component the one the grants are scoped to.
func _lure() -> Face:
	var f := Face.attack(0, I, [K.LURE])
	f.component = "test_lure"
	return f
## The Giant Petrel's shape: the team's unspent rerolls banked, up to three.
const BANK := {"id": "bank", "name": "Bank", "description": "", "effects": [
	{"trigger": "static", "effect": "bank_rerolls", "value": 3}]}


func _mech(name: String, d: Die, shield: int = 10, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = maxi(shield, 16)
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _foe(hp: int = 30, atk: int = 0, armour: int = 0) -> Foe:
	var f := Foe.make("revenant", hp, atk)
	f.armour = armour
	return f


func _hot(power: int, heat: int) -> Face:
	var f := Face.attack(power, L)
	f.heat = heat
	return f


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1, 4)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


# ---------------------------------------------------------------- the Storm Petrel

func test_the_heat_a_spend_adds_stands_up_as_much_shield() -> void:
	var u := _mech("Petrel", Die.single(_hot(4, 3)), 5)
	u.grant_passive(RIOT)
	var plain := _mech("Plain", Die.single(_hot(4, 3)), 5)
	var sk := _fight([u, plain], [_foe(30), _foe(30)])
	assert_true(sk.assign(0, sk.front[0]), "the gun spent")
	assert_eq([sk.mechs[0].heat, u.shield], [3, 8], "its heat on the gauge, and as much shield stood up")
	assert_eq(sk.front[0].hp, 26, "the strike alone: the zap left with the shield burn")
	assert_true(sk.assign(1, sk.front[1]), "a machine without the passive")
	assert_eq([sk.mechs[1].heat, plain.shield], [3, 5], "heat and nothing more")


func test_any_heat_stands_up_shield_to_its_maximum_and_never_on_a_broken_one() -> void:
	# Any source (Ryan, 11 November: "I did mean any source"): equipment's heat, Scorched's extra.
	var probe := Face.attack(0, I, [K.SHOCK])
	probe.heat = 2
	var u := _mech("Petrel", Die.of([probe, _hot(4, 3)]), 4)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30), _foe(30)])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "the debuff")
	assert_eq([ms.heat, u.shield], [2, 6], "equipment's heat stands up shield as a gun's does")
	var hot := _mech("Scorched", Die.single(_hot(4, 3)), 4)
	hot.grant_passive(RIOT)
	var s2 := _fight([hot], [_foe(30)])
	Effects.stack(hot, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe", 2, Effects.DECAY_NONE)
	assert_true(s2.assign(0, s2.front[0]), "a gun under a foe's Scorched")
	assert_true(s2.mechs[0].heat > 3, "Scorched's extra on the gauge")
	assert_eq(hot.shield, 4 + s2.mechs[0].heat, "and every point of it stood up as shield")
	var full := _mech("Full", Die.single(_hot(4, 6)), 14)
	full.shield_max = 16
	full.grant_passive(RIOT)
	var s3 := _fight([full], [_foe(30)])
	assert_true(s3.assign(0, s3.front[0]), "spent near the top")
	assert_eq(full.shield, 16, "up to its maximum and no further")
	var broken := _mech("Broken", Die.single(_hot(4, 3)), 0)
	broken.grant_passive(RIOT)
	var s4 := _fight([broken], [_foe(30)])
	s4.mechs[0].shield_broken = true
	assert_true(s4.assign(0, s4.front[0]), "spent on a broken shield")
	assert_eq([s4.mechs[0].heat, broken.shield], [3, 0], "the heat lands, and a broken shield takes none of it")


func test_a_shield_cost_is_paid_first_and_the_heat_stands_some_back() -> void:
	var gun := _hot(4, 4)
	gun.shield_cost = 2
	var u := _mech("Petrel", Die.single(gun), 5)
	u.shield_max = 6
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30)])
	assert_true(sk.assign(0, sk.front[0]), "spent")
	assert_eq([u.shield, sk.mechs[0].heat], [6, 4], "the cost first, 5 to 3, then its heat's 4 back up to its maximum of 6")
	var spent := gun.duplicate_face()
	var v := _mech("Petrel", Die.single(spent), 2)
	v.grant_passive(RIOT)
	var s2 := _fight([v], [_foe(30)])
	assert_true(s2.assign(0, s2.front[0]), "a cost that takes the last point")
	assert_eq([v.shield, s2.mechs[0].shield_broken], [0, true], "it breaks itself, and its heat stands up nothing after")


func test_the_plate_takes_a_point_off_every_blow_while_the_shield_stands() -> void:
	var u := _mech("Petrel", Die.single(Face.blank()), 3)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(300, 5), _foe(300, 5)])
	var fc := sk.forecast(sk.mechs[0])
	assert_eq(int(fc["hull_after"]), 100 - 1 - 5, "the forecast walks the plate: 4 on a shield of 3, then 5 on bare hull")
	sk.end_round()
	assert_eq([u.shield, u.hull], [0, 94], "the first blow lost a point to the plate while the shield stood; the second met none")


## What a spend at a foe lays on its own machine (self_status, a passive's: the Storm Petrel's
## branches, 17 November): Hardened Light a stack for each foe reached, a Spread's neighbours among
## them, a stack going as each of its turns starts (Ryan, 17 November: "decay by a stack at start of
## Petrel's turn, not all at once"); Charged on its next fires; the entry as spent says them, the
## die's own never, and a copy of the fight keeps them.
func test_a_lure_lays_hardened_light_for_each_foe_it_reaches_a_stack_going_each_turn_start() -> void:
	var lure := _lure()
	lure.heat = 3
	var u := _mech("Petrel", Die.single(lure), 10)
	u.grant_passive(HARDEN)
	assert_true(lure.self_statuses.is_empty(), "the die keeps the piece as printed")
	var spent := Effects.effective_face(u, lure)
	assert_eq(spent.self_statuses, [{"status": "hardened", "stacks": 1, "per_foe": true}], "the entry as spent carries the grant")
	assert_true(spent.describe().contains("Hardened Light 1 on itself for each foe reached"), "and says it: %s" % spent.describe())
	assert_true(Effects.effective_face(u, Face.attack(0, I, [K.LURE])).self_statuses.is_empty(), "another piece carries none: the grant is its piece's")
	var sk := _fight([u], [_foe(300, 5), _foe(300, 5), _foe(300, 5)])
	assert_eq(Effects.self_grants(SaveGame.clone_skirmish(sk).mechs[0].unit, lure), Effects.self_grants(u, lure), "a copy of the fight keeps the grant")
	var mid: Foe = sk.foe_at(0, 1)
	assert_true(sk.assign(0, mid), "the lure at one foe")
	assert_eq(Effects.stacks_of(u, "hardened"), 1, "a stack for the one foe it reached")
	assert_eq(mid.target, sk.mechs[0], "and the foe turns on it")
	var wide := lure.duplicate_face()
	wide.keywords.append(K.CLEAVE)
	var w := _mech("Wide", Die.single(wide), 10)
	w.grant_passive(HARDEN)
	var s2 := _fight([w], [_foe(300, 5), _foe(300, 5), _foe(300, 5)])
	assert_true(s2.assign(0, s2.foe_at(0, 1)), "the lure with Spread at the middle foe")
	assert_eq(Effects.stacks_of(w, "hardened"), 3, "a stack for each foe lured, the two beside it too")
	s2.end_round()
	assert_eq([w.shield, w.hull], [10 - 3 * (5 - 3), 100], "three lured blows of 5, each 3 lighter while its shield stood")
	s2.start_round()
	assert_eq(Effects.stacks_of(w, "hardened"), 2, "a stack goes as its next turn starts, the rest standing")
	assert_eq(Effects.stacks_next_round(Effects.STATUS["hardened"], 2), 1, "and the bot's look a round on reads the same clock")
	s2.end_round()
	s2.start_round()
	assert_eq(Effects.stacks_of(w, "hardened"), 1, "another at the next")
	assert_true(s2.assign(0, s2.foe_at(0, 1)), "a second lure at the middle foe")
	assert_eq(Effects.stacks_of(w, "hardened"), 4, "piles its three on the one left")
	s2.end_round()
	s2.start_round()
	s2.end_round()
	s2.start_round()
	s2.end_round()
	s2.start_round()
	assert_eq(Effects.stacks_of(w, "hardened"), 1, "a stack a turn start, whatever laid them")
	s2.end_round()
	s2.start_round()
	assert_false(Effects.has(w, "hardened"), "and gone at zero")


func test_a_lure_that_charges_its_machine_shocks_its_next_fires() -> void:
	var lure := _lure()
	var u := _mech("Petrel", Die.of([lure, _hot(1, 1)]), 10)
	u.grant_passive(CHARGE)
	var sk := _fight([u], [_foe(300), _foe(300)])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "the lure")
	assert_eq(Effects.stacks_of(u, "charged"), 2, "Charged 2 on its own machine, the lure, equipment, spending none")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, sk.front[1]), "a gun")
	assert_true(Effects.has(sk.front[1], "shocked"), "the fire carried the Shock")
	assert_eq(Effects.stacks_of(u, "charged"), 1, "and spent a stack")


## A debuff's Chain (the Storm Petrel's lure, its Striker branch, 17 November: "adds Chain 3 to the
## lure"): its arcs land the number it prints, plain, through each conductor's armour, and carry its
## riders, so every Shocked foe it arcs to is lured; its target takes nothing, and no Shock is spent.
func test_a_debuffs_chain_lands_its_number_plain_on_every_other_shocked_foe_and_lures_them() -> void:
	var lure := Face.attack(0, I, [K.LURE, K.CHAIN])
	lure.chain = 3
	var u := _mech("Petrel", Die.single(lure), 10)
	var sk := _fight([u], [_foe(30, 2), _foe(30, 2, 1), _foe(30, 2)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var a: Foe = sk.foe_at(0, 0)
	var b: Foe = sk.foe_at(0, 1)
	var c: Foe = sk.foe_at(0, 2)
	for foe in [b, c]:
		Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	Effects.stack(u, Effects.STATUS["overcharged"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	assert_true(sk.assign(0, a), "the lure at a foe that carries no Shock")
	assert_eq([a.hp, b.hp, c.hp], [30, 28, 27], "nothing on its target; 3 on each conductor, b's point of armour off, Empowered adding nothing to a debuff")
	assert_true(Effects.has(b, "shocked") and Effects.has(c, "shocked"), "no strike was aimed at them: their Shock stands")
	assert_eq([a.target, b.target, c.target], [ms, ms, ms], "the lure rides its arcs: every conductor turns on it")


# ---------------------------------------------------------------- the Giant Petrel

func test_the_bank_carries_unspent_rerolls_up_to_its_cap_while_it_fights() -> void:
	var p := _mech("Petrel", Die.single(Face.blank()))
	p.grant_passive(BANK)
	var a := _mech("A", Die.of([Face.attack(1, L), Face.attack(2, L)]))
	var sk := _fight([p, a], [_foe(300), _foe(300)])
	var r := Skirmish.REROLLS_PER_ROUND
	assert_eq(sk.rerolls_left, r, "the round's")
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, r * 2, "the round's fresh, and the last round's banked")
	for n in range(r):
		assert_true(sk.reroll([1]), "a reroll spent")
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, r * 2, "what was left was banked")
	sk.rerolls_left = 9
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, r + 3, "the bank holds three at most")
	sk.reroll_debt = 2
	sk.end_round()
	sk.reroll_debt = 2
	sk.start_round()
	assert_eq(sk.rerolls_left, r + 3 - 2, "a roar's cost comes off the whole")
	p.hull = 0
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, r, "the banker wrecked, nothing banks")


func test_a_team_without_a_banker_keeps_nothing() -> void:
	var a := _mech("A", Die.of([Face.attack(1, L), Face.attack(2, L)]))
	var sk := _fight([a], [_foe(300)])
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "never banked")


func _booster() -> Face:
	var f := Face.from_dict({"kind": "buff", "team_rerolls": 1, "keywords": ["rapid"], "ally_action": {"rerolls": 3}})
	return f


func test_the_booster_rallies_itself_or_buys_a_spent_allys_action() -> void:
	var p := _mech("Petrel", Die.of([_booster(), Face.attack(2, L)]))
	var a := _mech("A", Die.of([Face.attack(10, L), Face.attack(20, L)]))
	var sk := _fight([p, a], [_foe(300), _foe(300)])
	var pm: Skirmish.MechState = sk.mechs[0]
	var am: Skirmish.MechState = sk.mechs[1]
	pm.face_index = 0
	assert_eq(sk.machine_targets_for(pm, pm.face()), [pm], "the ally has not spent: itself alone")
	assert_true(sk.assign(0, pm), "on itself")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND + 1, "the team gains a reroll")
	assert_false(pm.assigned, "Rapid: it acts again")
	sk.end_round()
	sk.start_round()
	am.face_index = 0
	assert_true(sk.assign(1, sk.front[0]), "the ally acts")
	pm.face_index = 0
	sk.rerolls_left = 3   # the price in hand (at two a round, a bank's worth: the engine reads banked or fresh alike)
	assert_true(sk.machine_targets_for(pm, pm.face()).has(am), "a spent ally, three rerolls in hand: a target")
	assert_true(sk.assign(0, am), "the Booster on the spent ally")
	assert_eq(sk.rerolls_left, 0, "three rerolls paid")
	assert_false(am.assigned, "the ally acts again")
	assert_eq(am.face_index, 1, "its die rolled onto another entry, never the one it showed")
	assert_false(pm.assigned, "and the Petrel too: no turn traded")
	assert_true(sk.assign(1, sk.front[0]), "the bought action")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(1, sk.front[0]), "the ally acts")
	sk.rerolls_left = 2
	pm.face_index = 0
	assert_false(sk.machine_targets_for(pm, pm.face()).has(am), "two rerolls cannot pay three")


func test_the_salvo_brings_rerolls_on_a_kill_and_the_bank_keeps_them() -> void:
	var salvo := Face.attack(5, I)
	salvo.kill_rerolls = 2
	var p := _mech("Petrel", Die.single(salvo))
	p.grant_passive(BANK)
	var sk := _fight([p], [_foe(50), _foe(5)])
	assert_true(sk.assign(0, sk.front[0]), "a shot that kills nothing")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "no kill, no rerolls")
	sk.end_round()
	sk.start_round()
	var before := sk.rerolls_left
	var frail: Foe = sk.front[1] if sk.front[1] != null and sk.front[1].hp == 5 else sk.front[0]
	assert_true(sk.assign(0, frail), "a shot that kills")
	assert_eq(sk.rerolls_left, before + 2, "the kill brings two")
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND + 3, "banked as the turn ended, up to the cap")


func test_the_uplink_overcharges_an_ally_and_rolls_its_die() -> void:
	var uplink := Face.buff("overcharged", 2)
	uplink.targets = Face.Target.ALLY
	uplink.rolls_target = true
	var p := _mech("Petrel", Die.single(uplink))
	var a := _mech("A", Die.of([Face.attack(10, L), Face.attack(20, L)]))
	var sk := _fight([p, a], [_foe(300)])
	var pm: Skirmish.MechState = sk.mechs[0]
	var am: Skirmish.MechState = sk.mechs[1]
	assert_eq(sk.machine_targets_for(pm, uplink), [am], "allies only")
	am.face_index = 0
	assert_true(sk.assign(0, am), "on the unspent ally")
	assert_eq(Effects.stacks_of(a, "overcharged"), 2, "Empowered 2")
	assert_eq(am.face_index, 1, "its die rolled again, never onto the entry showing")
	sk.end_round()
	sk.start_round()
	am.face_index = 0
	assert_true(sk.assign(1, sk.front[0]), "the ally spends first")
	var stacks := Effects.stacks_of(a, "overcharged")
	assert_true(sk.assign(0, am), "then the Uplink on it")
	assert_eq(Effects.stacks_of(a, "overcharged"), stacks + 2, "the Empowered lands")
	assert_true(am.assigned and am.face_index == 0, "a spent die rolls nothing")


func test_the_bank_rides_in_a_copy_and_a_save() -> void:
	var p := _mech("Petrel", Die.single(Face.blank()))
	p.grant_passive(BANK)
	var sk := _fight([p], [_foe(300)])
	sk.end_round()
	assert_eq(sk.banked, Skirmish.REROLLS_PER_ROUND, "the round's rerolls banked as the turn ended")
	var copy := SaveGame.clone_skirmish(sk)
	assert_eq(copy.banked, Skirmish.REROLLS_PER_ROUND, "the planner's copy carries the bank")
	copy.start_round()
	assert_eq(copy.rerolls_left, Skirmish.REROLLS_PER_ROUND * 2, "and spends it")


# ---------------------------------------------------------------- the bot

func test_the_bot_prices_the_shield_its_heat_stands_up_and_what_its_lure_lays_on_itself() -> void:
	var gun := _hot(4, 3)
	var u := _mech("Petrel", Die.single(gun), 4)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30, 6), _foe(30, 6)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_eq(Policy.heat_of(ms, gun), 3, "its heat on the gauge, whole")
	assert_eq(Policy.heat_shield_gain(ms, gun), 3, "a point of shield a point of heat, on a shield that stands")
	assert_true(bot.shield_gain_worth(sk, ms, 3) > 0.0, "worth what it keeps of the blows coming")
	ms.shield_broken = true
	assert_eq(Policy.heat_shield_gain(ms, gun), 0, "a broken shield takes none")
	ms.shield_broken = false
	u.shield = u.shield_max
	assert_eq(Policy.heat_shield_gain(ms, gun), 0, "a full one has no room")
	u.shield = 6
	var lure := Face.attack(0, I, [K.LURE])
	lure.self_statuses = [{"status": "hardened", "stacks": 1, "per_foe": true}]   # the entry as its branches make it
	assert_true(bot.self_grant_worth(sk, ms, lure, sk.front[0]) > 0.0, "Hardened against the blows its lure draws")
	var charge := Face.attack(0, I, [K.LURE])
	charge.self_statuses = [{"status": "charged", "stacks": 2}]
	assert_true(bot.self_grant_worth(sk, ms, charge, sk.front[0]) > 0.0, "Charged on its next fires")
	assert_eq(bot.self_grant_worth(sk, ms, Face.attack(0, I, [K.LURE]), sk.front[0]), 0.0, "a lure with no grant is worth none of it")


func test_the_bot_holds_rerolls_for_an_action_worth_its_price_and_buys_it() -> void:
	var p := _mech("Petrel", Die.of([_booster(), Face.attack(1, L)]))
	var a := _mech("A", Die.of([Face.attack(30, L), Face.attack(29, L)]))
	var sk := _fight([p, a], [_foe(900), _foe(900)])
	sk.mechs[0].face_index = 0
	sk.mechs[1].face_index = 1
	sk.rerolls_left = 3   # the price in hand, as a bank would leave it
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_eq(bot._action_reserve(sk), 3, "the Booster showing, an ally's action worth its price: three kept from the looks")
	bot.play_round(sk)
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("pays 3 rerolls")), "the ally spent, the Booster bought its action: %s" % str(sk.log))


func test_the_bot_prices_rerolls_paid_mid_round_by_what_the_bank_carries() -> void:
	var p := _mech("Petrel", Die.of([_booster(), Face.attack(4, L)]))
	p.grant_passive(BANK)
	var a := _mech("A", Die.of([Face.attack(4, L), Face.attack(4, L)]))
	var sk := _fight([p, a], [_foe(900)])
	var rv := Policy.reroll_value(sk)
	assert_true(rv > 0.0, "a reroll is worth a share of the team's blow")
	sk.rerolls_left = 3
	assert_eq(Policy.bank_delta(sk, -3), 3.0 * rv, "three left and a bank of three: paying three gives up three banked")
	sk.rerolls_left = 6
	assert_eq(Policy.bank_delta(sk, -3), 0.0, "six left: the bank keeps three whatever is paid")
	assert_eq(Policy.bank_delta(sk, 2), 0.0, "and two more bring nothing past its cap")
	sk.rerolls_left = 1
	assert_eq(Policy.bank_delta(sk, 2), 2.0 * rv, "one left: a kill's two fill the bank")
	p.hull = 0
	assert_eq(Policy.bank_delta(sk, 2), 0.0, "no banker standing: a reroll mid-round is lost at the turn's end")


func test_the_bot_buys_no_action_worth_less_than_its_price() -> void:
	var p := _mech("Petrel", Die.of([_booster(), Face.attack(9, L)]))
	var a := _mech("A", Die.of([Face.attack(1, L), Face.attack(2, L)]))
	var sk := _fight([p, a], [_foe(900), _foe(900)])
	sk.mechs[0].face_index = 0
	sk.rerolls_left = 3   # the price in hand, so what is read is the worth and not the purse
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_eq(bot._action_reserve(sk), 0, "a small die's action is worth less than three looks: nothing kept")
	bot.play_round(sk)
	assert_false(sk.log.any(func(l: String) -> bool: return l.contains("pays 3 rerolls")), "and none bought")


# ---------------------------------------------------------------- the validator

func test_the_validator_holds_the_petrels_fields_to_their_kinds() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var base: Dictionary = db.components["twin_autoguns"].duplicate(true)
	var cases := {
		"bad_regen": [{"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"], "regenerates": {"status": "regenerating", "stacks": 3}}, "printed on no entry"],
		"bad_self_printed": [{"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"], "self_statuses": [{"status": "hardened"}]}, "printed on no entry"],
		"bad_debuff_chain": [{"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "chain"]}, "chain"],
		"bad_price": [{"kind": "attack", "reach": "direct", "power": 2, "ally_action": {"rerolls": 3}}, "ally_action"],
		"bad_price_self": [{"kind": "buff", "team_rerolls": 1, "targets": "self", "ally_action": {"rerolls": 3}}, "ally_action"],
		"bad_roll": [{"kind": "attack", "reach": "direct", "power": 2, "rolls_target": true}, "rolls_target"],
		"bad_kill": [{"kind": "attack", "reach": "direct", "power": 2, "kill_rerolls": 0}, "kill_rerolls"],
	}
	for cid in cases.keys():
		var comp := base.duplicate(true)
		comp["face"] = cases[cid][0]
		comp["tier"] = 2
		db.components[cid] = comp
	var errs := db.validate()
	for cid in cases.keys():
		assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component %s" % cid) and e.contains(str(cases[cid][1]))), "%s is refused" % cid)
	var good := base.duplicate(true)
	good["face"] = {"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "chain"], "chain": 3, "heat": 3}
	good["tier"] = 2
	db.components["good_lure"] = good
	for e in db.validate():
		assert_false(e.begins_with("component good_lure"), "a hot lure with Chain 3 passes: %s" % e)
	var grants := {"id": "g", "name": "G", "description": "", "effects": [
		{"trigger": "static", "effect": "self_status", "status": "barrier", "value": 1},
		{"trigger": "static", "effect": "self_status", "status": "hardened", "value": 0},
		{"trigger": "static", "effect": "self_status", "status": "charged", "value": 2, "per_foe": "yes"}]}
	var gerrs: Array[String] = []
	db._validate_passive("passive g", grants, gerrs)
	assert_true(gerrs.any(func(e: String) -> bool: return e.contains("self_status lays one of")), "a Barrier keeps its pieces: %s" % str(gerrs))
	assert_true(gerrs.any(func(e: String) -> bool: return e.contains("the stacks it lays")), "a grant of nothing is refused")
	assert_true(gerrs.any(func(e: String) -> bool: return e.contains("per_foe is true or false")), "per_foe is a switch")
	var fine: Array[String] = []
	db.components["test_lure"] = good.duplicate(true)   # the piece the grants are scoped to
	db._validate_passive("passive h", HARDEN, fine)
	db._validate_passive("passive c", CHARGE, fine)
	assert_eq(fine, [] as Array[String], "Hardened for each foe and Charged 2 pass")
	var p := {"id": "p", "name": "P", "description": "", "effects": [{"trigger": "static", "effect": "shield_per_heat", "value": 1}, {"trigger": "on_heat_gain", "effect": "shield_per_heat", "value": 0}, {"trigger": "static", "effect": "bank_rerolls", "value": 0}]}
	var perrs: Array[String] = []
	db._validate_passive("passive p", p, perrs)
	assert_eq(perrs.filter(func(e: String) -> bool: return e.contains("shield_per_heat")).size() >= 2, true, "the hook off its trigger, and a hook of nothing, are refused: %s" % str(perrs))
	assert_true(perrs.any(func(e: String) -> bool: return e.contains("bank_rerolls")), "a bank of nothing is refused")

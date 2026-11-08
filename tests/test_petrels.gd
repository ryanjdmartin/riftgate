extends TestCase

## The Storm Petrel's and the Giant Petrel's engines (Ryan's go, 21 October; built 30 October), on
## synthetic passives and entries: the shield paying a weapon's heat and the zap it pays back, the
## plate while the shield stands, Regenerating's machine half on its own spender; the bank of
## unspent rerolls, the action bought with them, the kill that brings them and the roll on an ally.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT
const K := Face.Keyword

## The Storm Petrel's shape: a point off every blow while the shield stands, and the shield paying
## its weapons' heat.
const RIOT := {"id": "riot", "name": "Riot", "description": "", "effects": [
	{"trigger": "static", "effect": "add_damage_taken", "value": -1, "when": "shield_up"},
	{"trigger": "static", "effect": "burn_shield", "value": 1}]}
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

func test_the_shield_pays_a_weapons_heat_and_the_target_takes_it_back() -> void:
	var u := _mech("Petrel", Die.single(_hot(4, 3)), 10)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30)])
	var foe: Foe = sk.front[0]
	assert_true(sk.assign(0, foe), "the hot gun spent")
	assert_eq(u.shield, 7, "its 3 heat came off the shield")
	assert_eq(sk.mechs[0].heat, 0, "and none reached the gauge")
	assert_eq(foe.hp, 30 - 4 - 3, "the strike's 4, then the zap of what the shield paid")


func test_a_weapon_hotter_than_the_shield_burns_what_it_holds_and_heats_the_rest() -> void:
	var u := _mech("Petrel", Die.single(_hot(4, 5)), 2)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30)])
	var foe: Foe = sk.front[0]
	assert_true(sk.assign(0, foe), "the hot gun spent")
	assert_eq([u.shield, sk.mechs[0].heat], [0, 3], "the shield's 2 burnt, the other 3 on the gauge")
	assert_eq(foe.hp, 30 - 4 - 2, "the zap is what the shield paid")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 0
	var heat := sk.mechs[0].heat
	assert_true(sk.assign(0, foe), "again, with the shield at nothing")
	assert_eq(sk.mechs[0].heat, heat + 5, "nothing to burn: every point heats the gauge")
	assert_eq(foe.hp, 30 - 4 - 2 - 4, "and no zap")


## Scorched heats the gauge, never the shield (Ryan, 8 November: "scorch affects the actual heat
## bar, not the ammo cost. It still can generate heat through other sources, just not weapons
## fire. Same as the storm petrel when its shield is up"): the shield pays the gun's own heat, and
## a Scorched machine's extra lands on the gauge; the die says so.
func test_the_shield_pays_the_guns_own_heat_and_scorched_heats_the_gauge() -> void:
	var u := _mech("Petrel", Die.single(_hot(4, 3)), 10)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30)])
	Effects.stack(u, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe", 2, Effects.DECAY_NONE)
	var ms: Skirmish.MechState = sk.mechs[0]
	var extra := 0
	for eff in Effects.STATUS["scorched"]["effects"]:
		if str(eff.get("effect", "")) == "add_heat":
			extra = 2 * int(eff["value"])   # the status's own number, read rather than copied
	assert_eq(sk.pending_burn(ms), 3, "the die: the shield pays the gun's own 3")
	var foe: Foe = sk.front[0]
	assert_true(sk.assign(0, foe), "the hot gun, scorched")
	assert_eq(u.shield, 7, "the shield paid the gun's own 3")
	assert_eq(ms.heat, extra, "and Scorched's extra reached the gauge")
	assert_eq(foe.hp, 30 - 4 - 3, "the zap is what the shield paid")


## The zap is a blow of the spend's, so it lands before the death check (Ryan, 7 November: the
## hit's every effect, then the death): on a target the strikes felled too, its corpse taking it.
func test_the_zap_meets_armour_and_lands_on_a_target_the_strikes_felled() -> void:
	var u := _mech("Petrel", Die.single(_hot(4, 3)), 16)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30, 0, 1), _foe(4)])
	var plated: Foe = sk.front[0]
	var frail: Foe = sk.front[1]
	assert_true(sk.assign(0, plated), "on the armoured foe")
	assert_eq(plated.hp, 30 - 3 - 2, "its armour off the strike and off the zap")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 0
	var shield := u.shield
	assert_true(sk.assign(0, frail), "on a foe the strike kills")
	assert_eq(u.shield, shield - 3, "the heat is paid all the same")
	assert_false(frail.alive(), "the strike killed")
	assert_true(sk.log.filter(func(l: String) -> bool: return l.contains("zaps")).size() == 2, "and the zap landed all the same, on the felled foe")
	assert_eq(frail.hp, 4 - 4 - 3, "its corpse took the zap of what the shield paid")


func test_the_zap_is_plain_and_a_guarded_foe_takes_none_of_it() -> void:
	var u := _mech("Petrel", Die.single(_hot(4, 3)), 16)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30)])
	var foe: Foe = sk.front[0]
	Effects.stack(foe, Effects.STATUS["guarded"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(0, foe), "on a guarded foe")
	assert_eq(foe.hp, 30, "neither the strike nor the zap lands on it")
	assert_eq(u.shield, 13, "the heat is the shield's whatever the blows did")


func test_equipment_and_a_machine_without_the_passive_heat_as_ever() -> void:
	var probe := Face.attack(0, I, [K.SHOCK])
	probe.heat = 2
	var u := _mech("Petrel", Die.of([probe, _hot(4, 3)]), 10)
	u.grant_passive(RIOT)
	var plain := _mech("Plain", Die.single(_hot(4, 3)), 10)
	var sk := _fight([u, plain], [_foe(30), _foe(30)])
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "the debuff")
	assert_eq([u.shield, sk.mechs[0].heat], [10, 2], "equipment heats the gauge: only a weapon's heat burns shield")
	assert_true(sk.assign(1, sk.front[1]), "a machine without the passive")
	assert_eq([plain.shield, sk.mechs[1].heat, sk.front[1].hp], [10, 3, 26], "heat on its gauge and no zap")


func test_the_plate_takes_a_point_off_every_blow_while_the_shield_stands() -> void:
	var u := _mech("Petrel", Die.single(Face.blank()), 3)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(300, 5), _foe(300, 5)])
	var fc := sk.forecast(sk.mechs[0], false)
	assert_eq(int(fc["hull_after"]), 100 - 1 - 5, "the forecast walks the plate: 4 on a shield of 3, then 5 on bare hull")
	sk.end_round()
	assert_eq([u.shield, u.hull], [0, 94], "the first blow lost a point to the plate while the shield stood; the second met none")


func test_the_die_shows_the_burn_and_the_zap() -> void:
	var u := _mech("Petrel", Die.single(_hot(4, 3)), 10)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30, 0, 1)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var foe: Foe = sk.front[0]
	var sf := sk.shown_face(ms, ms.face(), foe)
	assert_eq([sf.burns, sf.heat], [3, 0], "the burn in the heat slot's place, no heat past it")
	assert_eq(sk.shown_number_text(ms, sf, foe), "3", "over the foe: the blow alone, its armour off")
	assert_eq(Skirmish.after_blow(ms, sf, foe), 2, "and the zap its own number, the die's passive box (Ryan, 4 November), its armour off too")
	assert_eq(sk.shown_number_text(ms, sf), "4", "without a foe, the blow alone")
	assert_eq(Skirmish.after_blow(ms, sf), 3, "and the zap what the shield pays")
	assert_eq([sk.pending_heat(ms), sk.pending_burn(ms)], [0, 3], "the gauge waits for nothing; the shield for 3")
	assert_eq(int(sk.forecast(ms)["shield_after"]), 7, "the round's forecast spends the burn")
	u.shield = 2
	sf = sk.shown_face(ms, ms.face(), foe)
	assert_eq([sf.burns, sf.heat], [2, 1], "a shield short of the heat: what it holds, and the rest as heat")


## A shield cost on the Storm Petrel's weapon (Ryan, 4 November: "Does it actually convert ALL
## shield costs to damage?"): it does not. The strict cost is paid first as the entry is spent and
## never lands as a blow; the shield pays the heat from what the cost leaves, the rest reaching the
## gauge, and only what it paid for the heat lands after the strikes. The preview and the forecast
## read the same order; the die prints the cost along its foot and the burn in its passive box,
## never the burn as a cost ("the passive shield cost can't go there").
func test_a_shield_cost_is_paid_first_and_never_burnt_into_a_blow() -> void:
	var gun := _hot(4, 4)
	gun.shield_cost = 2
	var u := _mech("Petrel", Die.single(gun), 5)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var foe: Foe = sk.front[0]
	var sf := sk.shown_face(ms, ms.face())
	assert_eq([sf.shield_cost, sf.burns, sf.heat], [2, 3, 1], "the cost first, the heat from the 3 it leaves, the 1 past it as heat")
	assert_eq([sk.pending_heat(ms), sk.pending_burn(ms)], [1, 3], "the gauge takes what the shield cannot")
	assert_eq(int(sk.forecast(ms)["shield_after"]), 0, "the forecast spends the cost, then the burn")
	var d := DieFaceView.new()
	d.set_face(sf)
	assert_eq(d.cost_marks().map(func(c: Array) -> String: return "%s %d" % [c[0], c[1]]), ["heat 1", "shield 2"], "along the foot what must be paid: the heat past the shield and the shield cost, never the burn")
	assert_eq(d.passive_marks().map(func(m: Array) -> String: return str(m[1])), ["3"], "the burn the passive box's number")
	d.free()
	assert_true(sk.assign(0, foe), "spent")
	assert_eq([u.shield, ms.heat], [0, 1], "the cost, then the burn, then the gauge")
	assert_eq(foe.hp, 30 - 4 - 3, "the strike's 4 and the 3 the shield paid for the heat; the cost lands nowhere")


func test_the_regenerator_lures_and_regains_shield_three_rounds_each_grant_its_own() -> void:
	var regen := Face.attack(0, I, [K.LURE])
	regen.regen_shield = 2
	regen.regen_rounds = 3
	var u := _mech("Petrel", Die.of([regen, Face.blank()]), 2)
	u.shield_max = 20
	var ally := _mech("Ally", Die.single(Face.blank()), 0)
	var sk := _fight([u, ally], [_foe(300), _foe(300)])
	var foe: Foe = sk.front[0]
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, foe), "the lure spent")
	assert_eq(foe.target, sk.mechs[0], "the foe turns on the spender")
	assert_true(Effects.has(u, "regenerating"), "Regenerating on its own machine")
	assert_eq(u.shield, 2, "nothing this round")
	var seen: Array = []
	for r in range(4):
		sk.end_round()
		sk.start_round()
		seen.append(u.shield)
		if r == 0:
			sk.mechs[0].face_index = 0
			assert_true(sk.assign(0, sk.front[0]), "a second grant in the second round")
	assert_eq(seen, [4, 8, 12, 14], "2 a round for three rounds from each grant: the second's rounds overlap the first's, then run on alone")
	sk.end_round()
	sk.start_round()
	assert_false(Effects.has(u, "regenerating"), "both clocks have run out")
	assert_eq(u.shield, 14, "and nothing more comes")


func test_a_regeneration_is_bought_so_a_purge_takes_it_and_the_shield_caps_it() -> void:
	var regen := Face.attack(0, I, [K.LURE])
	regen.regen_shield = 5
	regen.regen_rounds = 3
	var u := _mech("Petrel", Die.single(regen), 10)
	u.shield_max = 12
	var sk := _fight([u], [_foe(300)])
	assert_true(sk.assign(0, sk.front[0]), "spent")
	sk.end_round()
	sk.start_round()
	assert_eq(u.shield, 12, "capped at the maximum")
	var gone := Effects.purge(u, 9)
	assert_true(gone.has("Regenerating gone"), "a buff, so a purge takes it")


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
	var f := Face.buff("rallied", 1)
	f.add_keyword(K.RAPID)
	f.action_price = 3
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

func test_the_bot_reads_the_burn_off_the_gauge_and_prices_the_zap_and_the_shield() -> void:
	var gun := _hot(4, 3)
	var u := _mech("Petrel", Die.single(gun), 10)
	u.grant_passive(RIOT)
	var sk := _fight([u], [_foe(30, 6), _foe(4)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_eq(Policy.heat_of(ms, gun), 0, "the shield pays it all: no heat on the gauge")
	var tough: Foe = sk.front[0] if sk.front[0].hp == 30 else sk.front[1]
	var frail: Foe = sk.front[1] if tough == sk.front[0] else sk.front[0]
	var sure := bot.damage_outcomes(ms, gun, frail)
	assert_eq(bot.zap_worth(sk, ms, frail, 3, sure), 0.0, "a strike that surely kills loses the zap")
	assert_true(bot.zap_worth(sk, ms, tough, 3, bot.damage_outcomes(ms, gun, tough)) >= 3.0, "a foe the strike leaves standing takes it")
	assert_true(bot.burn_cost(sk, ms, 3) > 0.0, "shield burnt under a foe's blow costs hull and the plate")
	u.shield = 1
	assert_eq(Policy.heat_of(ms, gun), 2, "what the shield cannot pay is heat")


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
		"bad_regen": [{"kind": "buff", "status": "overcharged", "regenerates": {"status": "regenerating", "shield": 2, "rounds": 3}}, "regenerates"],
		"bad_regen_status": [{"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"], "regenerates": {"status": "overcharged", "shield": 2, "rounds": 3}}, "regenerates"],
		"bad_price": [{"kind": "attack", "reach": "direct", "power": 2, "ally_action": {"rerolls": 3}}, "ally_action"],
		"bad_price_self": [{"kind": "buff", "status": "rallied", "targets": "self", "ally_action": {"rerolls": 3}}, "ally_action"],
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
	good["face"] = {"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"], "regenerates": {"status": "regenerating", "shield": 2, "rounds": 3}}
	good["tier"] = 2
	db.components["good_regen"] = good
	for e in db.validate():
		assert_false(e.begins_with("component good_regen"), "a lure that regenerates its machine passes: %s" % e)
	var p := {"id": "p", "name": "P", "description": "", "effects": [{"trigger": "static", "effect": "burn_shield", "value": 2}, {"trigger": "static", "effect": "bank_rerolls", "value": 0}]}
	var perrs: Array[String] = []
	db._validate_passive("passive p", p, perrs)
	assert_true(perrs.any(func(e: String) -> bool: return e.contains("burn_shield")), "a burn of 2 a heat point is refused")
	assert_true(perrs.any(func(e: String) -> bool: return e.contains("bank_rerolls")), "a bank of nothing is refused")

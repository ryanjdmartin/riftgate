extends TestCase

## The Macaque's engines (Ryan, 19 November), on synthetic passives and entries: an offhand whose
## forms cycle, a rider on every weapon and equipment its machine aims at a foe ("It cycles after a
## spend"), each form's rider (a blow on the foe to the right with every strike, beside an area's; a
## hit again on the target after every strike for its share of the strike's blow, rounded down; a
## status laid on its own machine, flat or a set a foe reached), a later form in a slot taking its
## place in the cycle, a grant adding to a keyword's own number, a buff waiting on the next weapon
## fired (Indirect reach for its whole spend, armour ignored), a branch's status in a buff piece's
## own's place, and the Parry: what a Barrier and armour keep off this round, half of it on every
## strike of the first weapon fired next turn.

const L := Face.Reach.DIRECT
const K := Face.Keyword

## A rifle, a sword and a shield, in that order: the content's shape, its numbers the test's own.
const RIFLE := {"trigger": "static", "effect": "offhand", "id": "rifle", "slot": "rifle", "name": "Rifle", "description": "To the right for 2.",
	"riders": [{"trigger": "static", "effect": "side_strike", "value": 2}]}
const SWORD := {"trigger": "static", "effect": "offhand", "id": "sword", "slot": "sword", "name": "Sword", "description": "Again for half.",
	"riders": [{"trigger": "static", "effect": "strike_again", "value": 50}]}
const SHIELD := {"trigger": "static", "effect": "offhand", "id": "shield", "slot": "shield", "name": "Shield", "description": "Armoured 2.",
	"riders": [{"trigger": "static", "effect": "self_status", "status": "braced", "value": 2}]}


func _passive(forms: Array) -> Dictionary:
	return {"id": "test_offhand", "name": "Test Offhand", "description": "", "effects": forms}


func _mech(name: String, d: Die, forms: Array = [RIFLE, SWORD, SHIELD], shield: int = 0, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	if not forms.is_empty():
		u.grant_passive(_passive(forms))
	return u


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1, 4)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


## A foe of `hp` with no blow of its own, so a round passes untouched.
func _dummy(hp: int = 100, armour: int = 0) -> Foe:
	var f := Foe.make("revenant", hp, 0)
	f.armour = armour
	return f


func _gun(power: int, strikes: int = 1, kws = []) -> Face:
	var g := Face.attack(power, L, kws)
	g.strikes = strikes
	return g


## The next round, its die showing entry `at`.
func _next_round(sk: Skirmish, at: int = 0) -> void:
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = at


func test_the_fight_opens_on_the_first_form_and_each_spend_at_a_foe_turns_it() -> void:
	var gun := _gun(1)
	var boost := Face.buff("overcharged")
	boost.targets = Face.Target.SELF
	var u := _mech("Line", Die.of([gun, boost]))
	var foe := _dummy(300)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(Effects.held_form(u), "Rifle", "the fight opens on its first form")
	assert_eq(Effects.status_kind("offhand"), "ability", "its chip is an Ability, no buff a Purge takes")
	ms.face_index = 0
	assert_true(sk.assign(0, foe), "a gun at a foe")
	assert_eq(Effects.held_form(u), "Sword", "turns it to the next")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("offhand turns: Sword")), "the log says so")
	_next_round(sk, 1)
	assert_true(sk.assign(0, ms), "a buff on itself")
	assert_eq(Effects.held_form(u), "Sword", "carries no rider, so it turns nothing")
	_next_round(sk)
	assert_true(sk.reboot_mech(0), "a reboot spends nothing")
	assert_eq(Effects.held_form(u), "Sword", "and turns nothing")
	_next_round(sk)
	assert_true(sk.assign(0, foe), "a gun")
	assert_eq(Effects.held_form(u), "Shield", "the third")
	_next_round(sk)
	assert_true(sk.assign(0, foe), "a gun")
	assert_eq(Effects.held_form(u), "Rifle", "and round to the first")
	var plain := Unit.mech(1, "Plain", Vector2i.ZERO)
	plain.die = Die.single(_gun(1))
	var s2 := _fight([plain], [_dummy()])
	assert_eq(Effects.held_form(plain), "", "a machine with no offhand holds none")
	assert_eq(s2.mechs[0].offhand, -1, "and has no place in a cycle")


func test_a_rapid_spends_second_shot_rides_the_next_form() -> void:
	var rapid := _gun(4, 1, [K.RAPID])
	var gun := _gun(4)
	var u := _mech("Line", Die.of([rapid, gun]))
	var a := _dummy(100)
	var b := _dummy(100)
	var sk := _fight([u], [a, b])
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, a), "the Rapid gun, on the rifle")
	assert_eq(b.hp, 98, "the foe to the right took the rifle's 2")
	assert_eq(sk.mechs[0].face_index, 1, "the die rolls again, onto the other gun")
	assert_true(sk.assign(0, a), "its second spend")
	assert_eq(a.hp, 100 - 4 - 4 - 2, "rides the sword: 4, then 2 again")
	assert_eq(b.hp, 98, "and no rifle")


func test_the_rifle_strikes_the_foe_to_the_right_with_every_strike_its_own_blow_beside_a_spread() -> void:
	var u := _mech("Line", Die.single(_gun(3, 2)))
	var left := _dummy(50)
	var mid := _dummy(50)
	var far := _dummy(50)
	var sk := _fight([u], [left, mid, far])
	assert_eq(sk.right_of(left), mid, "the foe to the right is the next slot's")
	assert_true(sk.assign(0, left), "two strikes at the left")
	assert_eq(left.hp, 44, "the target takes its two strikes")
	assert_eq(mid.hp, 46, "the foe to the right takes 2 a strike")
	assert_eq(far.hp, 50, "and no further")
	assert_true(sk.spend_blows.any(func(b: Dictionary) -> bool: return b["foe"] == mid and str(b["kind"]) == "area"), "a blow that reaches it, never aimed at it")
	# On a Spread gun, the foe to the right takes the Spread's blow and the rifle's, each meeting its armour.
	var spray := _gun(3, 1, [K.CLEAVE])
	spray.cleave = 1
	var v := _mech("Line", Die.single(spray))
	var x := _dummy(50)
	var y := _dummy(50)
	var z := _dummy(50, 1)
	var s2 := _fight([v], [x, y, z])
	assert_true(s2.assign(0, y), "spread at the middle")
	assert_eq(x.hp, 49, "the left takes its Spread 1")
	assert_eq(z.hp, 49, "the right, armour 1, takes the Spread's 1 to nothing and the rifle's 2 to 1: two blows")
	# At the rank's end, or before an empty slot, nothing to the right.
	var w := _mech("Line", Die.single(_gun(3)))
	var p := _dummy(50)
	var q := _dummy(50)
	var s3 := _fight([w], [p, q])
	assert_eq(s3.right_of(q), null, "an empty slot to its right")
	assert_true(s3.assign(0, q), "at the last foe")
	assert_eq([p.hp, q.hp], [50, 47], "the rifle finds nobody")


func test_a_strikes_blows_land_in_the_strike_order() -> void:
	# Ryan, 19 November: "Center -> Left -> Right for Spread, and Center -> Front/Rear for penetrate.
	# Spread always computes before Penetrate, and Penetrate computes before Rifle"; Chain's arcs
	# after them, following the impact.
	var gun := _gun(3, 1, [K.CLEAVE, K.PENETRATE, K.CHAIN])
	gun.cleave = 1
	gun.penetrate = 1
	gun.chain = 1
	var u := _mech("Line", Die.single(gun))
	var a := _dummy(50)
	var b := _dummy(50)
	var c := _dummy(50)
	var d := _dummy(50)
	var e := Foe.make("archer", 50, 0, true)
	var g := Foe.make("archer", 50, 0, true)
	var sk := _fight([u], [a, b, c, d, e, g])
	assert_eq(sk.foe_at(1, 1), g, "a foe behind the target")
	Effects.stack(d, Effects.STATUS["shocked"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(0, b), "at the second front foe")
	var order: Array = sk.spend_blows.map(func(bl: Dictionary) -> Foe: return bl["foe"])
	assert_eq(order, [b, a, c, g, c, d], "the target, Spread's left and right, Penetrate's behind, the rifle's to the right, then the arc")


func test_the_rifles_blow_carries_the_entrys_riders_and_a_debuff_rides_it_too() -> void:
	var gun := _gun(3, 1, [K.BRITTLE])
	gun.brittle = 1
	var u := _mech("Line", Die.single(gun))
	var a := _dummy(50)
	var b := _dummy(50)
	var sk := _fight([u], [a, b])
	assert_true(sk.assign(0, a), "a Brittle gun")
	assert_eq(Effects.stacks_of(b, "brittled"), 1, "the foe to the right takes the rider with the rifle's blow")
	var probe := Face.attack(0, L, [K.BRITTLE])
	probe.brittle = 1
	var v := _mech("Line", Die.single(probe))
	var c := _dummy(50)
	var d := _dummy(50)
	var s2 := _fight([v], [c, d])
	assert_true(s2.assign(0, c), "a debuff")
	assert_eq(d.hp, 50, "equipment's blow is nothing")
	assert_eq(Effects.stacks_of(d, "brittled"), 1, "its rider lands all the same")


func test_the_sword_hits_the_target_again_after_each_strike_as_a_strike_of_half_its_number() -> void:
	# Ryan, 19 November: "Base 4 -> treat like a 4,2 weapon (two strikes) ... Base 2x2 -> treat like a
	# 2,1,2,1 (four strikes)".
	var u := _mech("Line", Die.single(_gun(4)), [SWORD])
	var foe := _dummy(100)
	var sk := _fight([u], [foe])
	assert_true(sk.assign(0, foe), "a strike of 4")
	assert_eq(foe.hp, 100 - 4 - 2, "4, then 2: a 4,2 weapon")
	var w := _mech("Line", Die.single(_gun(2, 2)), [SWORD])
	var f1 := _dummy(100)
	var s1 := _fight([w], [f1])
	assert_true(s1.assign(0, f1), "two strikes of 2")
	assert_eq(f1.hp, 100 - (2 + 1) * 2, "2, 1, 2, 1")
	var kinds: Array = s1.spend_blows.map(func(b: Dictionary) -> String: return str(b["kind"]))
	assert_eq(kinds, ["strike", "again", "strike", "again"], "each hit its own place, in order")
	# Each its own strike through the pipeline: Empowered on both, a next strike's buff on the first alone.
	var v := _mech("Line", Die.single(_gun(4)), [SWORD])
	var f2 := _dummy(100)
	var s2 := _fight([v], [f2])
	Effects.stack(v, Effects.STATUS["overcharged"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(s2.assign(0, f2), "an Empowered strike")
	assert_eq(f2.hp, 100 - 5 - 3, "4 and 1, then 2 and 1")
	var x := _mech("Line", Die.single(_gun(4)), [SWORD])
	x.grant_passive({"id": "doubler", "name": "Doubler", "description": "", "effects": [{"trigger": "on_attack", "effect": "multiply_damage", "value": 2, "when": "first_blow"}]})
	var f3 := _dummy(100)
	var s3 := _fight([x], [f3])
	assert_true(s3.assign(0, f3), "a strike its next-strike buff doubles")
	assert_eq(f3.hp, 100 - 8 - 2, "8, then the hit again's own 2: the buff never reaches it")
	# The foe's armour meets each hit as its own blow.
	var y := _mech("Line", Die.single(_gun(5)), [SWORD])
	var f4 := _dummy(100, 1)
	var s4 := _fight([y], [f4])
	assert_true(s4.assign(0, f4), "at armour 1")
	assert_eq(f4.hp, 100 - 4 - 1, "5 less 1, then 2 less 1")


func test_a_saber_hits_again_whole_and_a_ricochet_sets_off_no_hit_again() -> void:
	var saber := {"trigger": "static", "effect": "offhand", "id": "saber", "slot": "sword", "name": "Saber", "description": "Again, whole.",
		"riders": [{"trigger": "static", "effect": "strike_again", "value": 100}]}
	var u := _mech("Line", Die.single(_gun(5, 2)), [saber])
	var foe := _dummy(100)
	var sk := _fight([u], [foe])
	assert_true(sk.assign(0, foe), "two strikes")
	assert_eq(foe.hp, 80, "5, 5, 5, 5")
	var v := _mech("Line", Die.single(_gun(5)), [SWORD])
	var f2 := _dummy(100)
	var s2 := _fight([v], [f2])
	Effects.stack(v, Effects.STATUS["ricochet"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	assert_true(s2.assign(0, f2), "a strike, then two Ricochets")
	assert_eq(f2.hp, 100 - 5 - 2 - 1 - 1, "5, its hit again of 2, then the Ricochet's 1 and 1, which set off nothing")


func test_the_shield_lays_armoured_on_its_machine_once_the_spend_is_done() -> void:
	var u := _mech("Line", Die.single(_gun(3, 3)), [SHIELD])
	var foe := _dummy(100)
	var sk := _fight([u], [foe])
	assert_true(sk.assign(0, foe), "three strikes")
	assert_eq(Effects.stacks_of(u, "braced"), 2, "Armoured 2, once a spend, never a strike")
	var pavise := {"trigger": "static", "effect": "offhand", "id": "pavise", "slot": "shield", "name": "Pavise", "description": "1, and 1 a foe.",
		"riders": [{"trigger": "static", "effect": "self_status", "status": "braced", "value": 1, "per_foe": true, "plus": 1}]}
	var spray := _gun(3, 1, [K.CLEAVE])
	spray.cleave = 1
	var v := _mech("Line", Die.single(spray), [pavise])
	var a := _dummy(50)
	var b := _dummy(50)
	var c := _dummy(50)
	var s2 := _fight([v], [a, b, c])
	assert_true(s2.assign(0, b), "a Spread across three")
	assert_eq(Effects.stacks_of(v, "braced"), 4, "1, plus 1 for each of the three foes it struck")


func test_a_later_form_in_a_slot_takes_its_place_in_the_cycle() -> void:
	var u := _mech("Line", Die.single(_gun(1)))
	var saber := {"trigger": "static", "effect": "offhand", "id": "saber", "slot": "sword", "name": "Saber", "description": "",
		"riders": [{"trigger": "static", "effect": "strike_again", "value": 100}]}
	u.grant_passive({"id": "step", "name": "Step", "description": "", "effects": [saber]}, "branch")
	var names: Array = Effects.offhand_forms(u).map(func(f: Dictionary) -> String: return str(f["name"]))
	assert_eq(names, ["Rifle", "Saber", "Shield"], "the step's form in the sword's place, the order kept")


func test_a_grant_that_adds_combines_with_a_guns_own_number() -> void:
	var bazooka := {"trigger": "static", "effect": "offhand", "id": "bazooka", "slot": "rifle", "name": "Bazooka", "description": "",
		"riders": [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "number": 2, "adds": true},
			{"trigger": "static", "effect": "grant_keyword", "value": "penetrate", "number": 2, "adds": true}]}
	var spray := _gun(3, 1, [K.CLEAVE])
	spray.cleave = 1
	var plain := _gun(3)
	var u := _mech("Line", Die.of([spray, plain]), [bazooka])
	var sk := _fight([u], [_dummy()])
	var ms: Skirmish.MechState = sk.mechs[0]
	var s := sk.shown_face(ms, spray)
	assert_eq([s.row_number(), s.column_number()], [3, 2], "a Spread 1 gun under it is a Spread 3, and gains Penetrate 2")
	var p := sk.shown_face(ms, plain)
	assert_eq([p.row_number(), p.column_number()], [2, 2], "a plain gun gains both at 2")
	assert_eq(spray.cleave, 1, "the die keeps the gun as printed")


func test_the_aile_boost_gives_the_next_weapon_indirect_reach_and_equipment_leaves_it() -> void:
	var boost := Face.buff("aile_boost")
	boost.targets = Face.Target.SELF
	boost.add_keyword(K.RAPID)
	var gun := _gun(3)
	var probe := Face.attack(0, L, [K.BRITTLE])
	probe.brittle = 1
	var u := _mech("Line", Die.of([boost, gun, probe]), [])
	var front := Foe.make("revenant", 50, 0)
	var back := Foe.make("archer", 50, 0, true)
	var sk := _fight([u], [front, back])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_false(sk.targets_for_face(ms, gun).has(back), "a Direct gun cannot reach past the front")
	ms.face_index = 0
	assert_true(sk.assign(0, ms), "the boost, on itself")
	assert_true(Effects.has(u, "aile_boost"), "Aile Boost stands")
	assert_true(sk.targets_for_face(ms, gun).has(back), "the gun reaches as Indirect")
	assert_false(sk.targets_for_face(ms, probe).has(back), "equipment does not")
	ms.face_index = 2
	assert_true(sk.assign(0, front), "the debuff first")
	assert_true(Effects.has(u, "aile_boost"), "leaves it standing")
	_next_round(sk, 1)
	assert_true(Effects.has(u, "aile_boost"), "carried between turns until a weapon fires")
	assert_true(sk.assign(0, back), "the gun at the back rank")
	assert_eq(back.hp, 47, "struck")
	assert_false(Effects.has(u, "aile_boost"), "and the weapon lifts it")


func test_the_aile_blitz_also_ignores_armour_for_the_whole_spend() -> void:
	var u := _mech("Line", Die.single(_gun(3, 2)), [])
	var foe := _dummy(50, 2)
	var sk := _fight([u], [foe])
	Effects.grant_buff(u, "aile_blitz", 1, "test", 1)
	assert_true(sk.assign(0, foe), "two strikes at armour 2")
	assert_eq(foe.hp, 44, "neither meets the armour")
	assert_false(Effects.has(u, "aile_blitz"), "spent by the weapon")


func test_a_branch_rewrites_a_buffs_status_and_a_buff_lays_its_own_grant() -> void:
	var booster := Face.buff("aile_boost")
	booster.targets = Face.Target.SELF
	booster.component = "test_booster"
	var u := _mech("Line", Die.single(booster), [])
	u.grant_passive({"id": "step", "name": "Step", "description": "", "effects": [
		{"trigger": "static", "effect": "buff_status", "value": "aile_assault", "entry": "test_booster"},
		{"trigger": "static", "effect": "self_status", "status": "overcharged", "value": 1, "entry": "test_booster"}]}, "branch")
	var sk := _fight([u], [_dummy()])
	assert_true(sk.assign(0, sk.mechs[0]), "the booster on itself")
	assert_true(Effects.has(u, "aile_assault") and not Effects.has(u, "aile_boost"), "the branch's status in the piece's own's place")
	assert_eq(Effects.stacks_of(u, "overcharged"), 1, "and its own Empowered beside it")
	var plain := Face.buff("overcharged")
	plain.targets = Face.Target.SELF
	var v := _mech("Line", Die.single(plain), [SHIELD])
	var s2 := _fight([v], [_dummy()])
	assert_true(s2.assign(0, s2.mechs[0]), "a buff under the shield form")
	assert_eq(Effects.stacks_of(v, "braced"), 0, "a rider on what it aims at foes rides no buff")


func test_the_parry_counts_what_a_barrier_and_armour_keep_off_and_pays_half_next_turn() -> void:
	var buckler := {"trigger": "static", "effect": "offhand", "id": "buckler", "slot": "shield", "name": "Buckler", "description": "",
		"riders": [{"trigger": "static", "effect": "self_status", "status": "barrier", "value": 1},
			{"trigger": "static", "effect": "self_status", "status": "ward", "value": 1},
			{"trigger": "static", "effect": "self_status", "status": "parry", "value": 1}]}
	var u := _mech("Line", Die.of([_gun(3, 2), _gun(3)]), [buckler], 0)
	u.armour = 2
	var a := Foe.make("revenant", 300, 6)
	var b := Foe.make("revenant", 300, 6)
	var sk := _fight([u], [a, b])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 1
	assert_true(sk.assign(0, a), "a gun on the buckler")
	for id in ["barrier", "ward", "parry"]:
		assert_true(Effects.has(u, id), "it gains %s" % id)
	assert_eq(Effects.stacks_of(u, "parry_strike"), 0, "nothing to fire on yet: the Parry pays next turn")
	var hull := u.hull
	sk.end_round()
	assert_eq(u.hull, hull - 4, "the Barrier took the first blow whole, its armour 2 off the second")
	assert_eq(ms.parried, 6 + 2, "the count: 6 the Barrier kept off, 2 the armour")
	sk.start_round()
	assert_false(Effects.has(u, "parry"), "the Parry goes as its turn opens")
	assert_eq(Effects.stacks_of(u, "parry_strike"), 4, "half of 8 stands for the first weapon")
	assert_eq(Effects.status_kind("parry_strike"), "buff", "a buff")
	ms.face_index = 0
	var before := a.hp
	assert_true(sk.assign(0, a), "two strikes")
	assert_eq(before - a.hp, (3 + 4) + 3, "4 more on its next strike alone (19 November: \"Can we change it to 'next strike' instead?\")")
	assert_eq(Effects.stacks_of(u, "parry_strike"), 0, "lifted by that weapon")


func test_an_unspent_parry_goes_with_its_turn_and_a_shield_soaks_nothing_into_it() -> void:
	var u := _mech("Line", Die.single(_gun(3)), [], 20)
	u.armour = 2
	var a := Foe.make("revenant", 300, 6)
	var sk := _fight([u], [a])
	var ms: Skirmish.MechState = sk.mechs[0]
	Effects.stack(u, Effects.STATUS["parry"], Effects.SKIRMISH, "test", 1, Effects.DECAY_ROUND)
	sk.end_round()
	assert_eq(ms.parried, 0, "a blow its shield took whole: nothing blocked by Barrier or armour")
	u.shield = 0
	sk.start_round()
	assert_eq(Effects.stacks_of(u, "parry_strike"), 0, "nothing counted, nothing returned")
	Effects.stack(u, Effects.STATUS["parry"], Effects.SKIRMISH, "test", 1, Effects.DECAY_ROUND)
	sk.end_round()
	assert_eq(ms.parried, 2, "its armour's 2")
	sk.start_round()
	assert_eq(Effects.stacks_of(u, "parry_strike"), 1, "half of 2")
	sk.end_round()
	assert_eq(Effects.stacks_of(u, "parry_strike"), 0, "no weapon fired: gone with the turn")


func test_a_save_keeps_the_offhands_form_and_the_parrys_count() -> void:
	var u := _mech("Line", Die.single(_gun(1)))
	var foe := _dummy()
	var sk := _fight([u], [foe])
	assert_true(sk.assign(0, foe), "a spend")
	sk.mechs[0].parried = 5
	var back := SaveGame.clone_skirmish(sk)
	assert_eq(back.mechs[0].offhand, 1, "the place in the cycle")
	assert_eq(Effects.held_form(back.mechs[0].unit), "Sword", "and the form's chip")
	assert_eq(back.mechs[0].parried, 5, "and the Parry's count")


func test_the_validator_holds_a_form_to_its_shape() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var ok: Array[String] = []
	db._validate_passive("test", _passive([RIFLE, SWORD, SHIELD]), ok)
	assert_eq(ok, [] as Array[String], "three forms validate clean")
	var cases := {
		"no riders": func(f: Dictionary) -> void: f.erase("riders"),
		"no name": func(f: Dictionary) -> void: f["name"] = "",
		"no line": func(f: Dictionary) -> void: f["description"] = "",
		"no id": func(f: Dictionary) -> void: f.erase("id"),
		"a form in a form": func(f: Dictionary) -> void: f["riders"] = [RIFLE.duplicate(true)],
		"a rider the engine lacks": func(f: Dictionary) -> void: f["riders"] = [{"trigger": "static", "effect": "warp"}],
		"a strike of nothing to the right": func(f: Dictionary) -> void: f["riders"] = [{"trigger": "static", "effect": "side_strike", "value": 0}],
		"plus without per_foe": func(f: Dictionary) -> void: f["riders"] = [{"trigger": "static", "effect": "self_status", "status": "braced", "value": 1, "plus": 1}],
		"adds without a number": func(f: Dictionary) -> void: f["riders"] = [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "adds": true}],
	}
	for name in cases.keys():
		var f: Dictionary = RIFLE.duplicate(true)
		(cases[name] as Callable).call(f)
		var e: Array[String] = []
		db._validate_passive("test", _passive([f]), e)
		assert_false(e.is_empty(), "%s is refused" % name)
	var e2: Array[String] = []
	db._validate_passive("test", {"id": "x", "name": "X", "description": "x", "effects": [{"trigger": "static", "effect": "buff_status", "value": "aile_blitz"}]}, e2)
	assert_false(e2.is_empty(), "a buff rewrite names its buff piece")

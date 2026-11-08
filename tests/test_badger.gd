extends TestCase

## The Honey Badger's rework (Ryan's go, 31 October: "agreed on all proposed. Build it"), on
## synthetic passives and entries: a load for each foe a weapon's spend damages, never past the
## hopper's cap; a weapon's own number in place of the passive's; the Ore Plate standing at what
## the loads are worth, asleep under a purge while the loads stay; a shot firing loads takes their
## plate with it; never destroyed as a module's rule; the bot pricing the plate a shot spends.

const L := Face.Reach.DIRECT
const K := Face.Keyword

## The Ore Hopper's shape: a load a foe damaged, four at most, a point of armour a load held.
const HOPPER := {"id": "hop", "name": "Hop", "description": "", "effects": [
	{"trigger": "static", "effect": "fill_hopper", "value": 1, "cap": 4},
	{"trigger": "static", "effect": "hopper_plate", "value": 1, "per": 1}]}
## Ryan's fallback: a point of armour for every two loads.
const HALF := {"id": "half", "name": "Half", "description": "", "effects": [
	{"trigger": "static", "effect": "fill_hopper", "value": 1, "cap": 4},
	{"trigger": "static", "effect": "hopper_plate", "value": 1, "per": 2}]}


func _mech(name: String, d: Die, shield: int = 10, hull: int = 100, armour: int = 1) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = maxi(shield, 16)
	u.hull = hull
	u.hull_max = hull
	u.armour = armour
	u.die = d
	return u


func _foe(hp: int = 30, atk: int = 0, armour: int = 0) -> Foe:
	var f := Foe.make("revenant", hp, atk)
	f.armour = armour
	return f


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1, 4)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


func _spread(power: int, n: int) -> Face:
	return Face.from_dict({"kind": "attack", "reach": "direct", "power": power, "keywords": ["cleave"], "cleave": n})


func _firing(power: int, per_shot: int, per_load: int) -> Face:
	return Face.from_dict({"kind": "attack", "reach": "direct", "power": power, "fires_hopper": per_shot, "power_per_load": per_load})


func test_every_foe_a_weapon_damages_puts_a_load_in_and_the_plate_follows() -> void:
	var u := _mech("Badger", Die.single(Face.attack(3, L)))
	u.grant_passive(HOPPER)
	var sk := _fight([u], [_foe(30)])
	assert_eq([Effects.store_cap(u, "hopper"), u.armour], [4, 1], "a cap of four, and the base armour before any load")
	assert_true(sk.assign(0, sk.front[0]), "a plain gun spent")
	assert_eq(Effects.stacks_of(u, "hopper"), 1, "one foe damaged: a load")
	assert_eq([Effects.stacks_of(u, "ore_plate"), u.armour], [1, 2], "its plate stands as a buff, a point of armour")
	assert_true("\n".join(sk.log).contains("fills the hopper: +1 (1)"), "the log says so")


func test_an_area_weapon_loads_for_each_foe_and_the_cap_holds() -> void:
	var u := _mech("Badger", Die.single(_spread(3, 2)))
	u.grant_passive(HOPPER)
	var sk := _fight([u], [_foe(30), _foe(30), _foe(30)])
	assert_true(sk.assign(0, sk.front[1]), "the spread on the middle foe")
	assert_eq(Effects.stacks_of(u, "hopper"), 3, "three foes damaged, three loads")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.front[1]), "again")
	assert_eq(Effects.stacks_of(u, "hopper"), 4, "never past the cap")
	assert_eq(u.armour, 5, "four loads, four points over the base one")


func test_a_weapons_own_number_reads_in_place_of_the_passives() -> void:
	var claw := Face.from_dict({"kind": "attack", "reach": "direct", "power": 3, "strikes": 2, "fills_hopper": 2})
	var u := _mech("Badger", Die.single(claw))
	u.grant_passive(HOPPER)
	var sk := _fight([u], [_foe(30)])
	assert_true(sk.assign(0, sk.front[0]), "the claw, twice on one foe")
	assert_eq(Effects.stacks_of(u, "hopper"), 2, "its two a foe, once a spend, never the passive's one beside them or a load a strike")
	assert_eq(sk.front[0].hp, 30 - 6, "both strikes landed")


func test_a_blow_that_deals_nothing_loads_nothing() -> void:
	var u := _mech("Badger", Die.of([Face.attack(2, L), Face.attack(0, L, [K.SHOCK])]))
	u.grant_passive(HOPPER)
	var sk := _fight([u], [_foe(30, 0, 3)])
	assert_true(sk.assign(0, sk.front[0]), "a 2 into armour 3")
	assert_eq(Effects.stacks_of(u, "hopper"), 0, "a blow its armour took whole damaged nothing")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, sk.front[0]), "equipment aimed at it")
	assert_eq(Effects.stacks_of(u, "hopper"), 0, "equipment deals no damage and loads nothing")


func test_a_shot_fires_its_loads_and_their_plate_goes_with_them() -> void:
	var u := _mech("Badger", Die.single(_firing(4, 2, 2)))
	u.grant_passive(HOPPER)
	var sk := _fight([u], [_foe(60)])
	Effects.add_loads(u, 4)
	assert_eq(u.armour, 5, "four loads held")
	assert_eq(sk.shown_number(sk.mechs[0], u.die.faces[0]), 8, "the shot fires two of the four at +2 (one number since rolled damage went, 2 November)")
	assert_true(sk.assign(0, sk.front[0]), "the shot")
	assert_eq(sk.front[0].hp, 60 - 8, "four and two loads")
	assert_eq(Effects.stacks_of(u, "hopper"), 3, "two fired, then its own blow loads one back")
	assert_eq(u.armour, 4, "the plate follows: three loads, three points")


## A purge leaves the plate and the loads (Ryan's row on stores, 21 October): the Ore Plate is
## the hopper's own, an ability since 8 November ("It's not a Buff, it's not a Debuff, it's
## labelled as an Ability, so it doesn't get purged"), as the loads are a store's.
func test_a_purge_leaves_the_plate_and_the_loads() -> void:
	var u := _mech("Badger", Die.single(Face.attack(3, L)))
	u.grant_passive(HOPPER)
	Effects.add_loads(u, 3)
	assert_eq(u.armour, 4, "three loads held")
	assert_true(Effects.is_ability("ore_plate"), "the plate is an ability")
	assert_true(Effects.purge(u, 3).is_empty(), "so a Purge finds nothing to take")
	assert_eq([Effects.stacks_of(u, "hopper"), u.armour], [3, 4], "the loads and their armour stay")


func test_the_fallback_plates_a_point_for_every_two_loads() -> void:
	var u := _mech("Badger", Die.single(Face.attack(3, L)), 10, 100, 2)
	u.grant_passive(HALF)
	Effects.add_loads(u, 3)
	assert_eq(u.armour, 3, "three loads, one point over the base two")
	Effects.add_loads(u, 1)
	assert_eq(u.armour, 4, "four loads, two points: the total of four")
	Effects.spend_loads(u, 3)
	assert_eq([Effects.stacks_of(u, "ore_plate"), u.armour], [0, 2], "one load is worth nothing")


func test_a_hopper_with_no_passive_fills_as_its_weapon_says_with_no_cap_or_plate() -> void:
	var fill := Face.from_dict({"kind": "attack", "reach": "direct", "power": 3, "keywords": ["cleave"], "cleave": 2, "fills_hopper": 2})
	var u := _mech("Gel", Die.single(fill))
	var sk := _fight([u], [_foe(30), _foe(30), _foe(30)])
	assert_true(sk.assign(0, sk.front[1]), "a filling spread")
	assert_eq(Effects.stacks_of(u, "hopper"), 6, "two a foe, three foes, no cap")
	assert_eq([Effects.stacks_of(u, "ore_plate"), u.armour], [0, 1], "and no plate without a passive that plates it")


func test_the_rules_read_as_sentences() -> void:
	assert_eq(Effects.effect_text(HOPPER["effects"][0]), "every foe its weapons damage puts a load in its hopper, up to 4", "the fill")
	assert_eq(Effects.effect_text(HOPPER["effects"][1]), "each load held is a point of armour", "the plate")
	assert_eq(Effects.effect_text(HALF["effects"][1]), "every 2 loads held are a point of armour", "the fallback's plate")


func test_never_destroyed_is_a_modules_rule() -> void:
	var u := _mech("Badger", Die.of([Face.attack(3, L), Face.attack(4, L)]))
	u.grant_passive({"id": "module:skeleton", "name": "Skeleton", "description": "", "effects": [{"trigger": "on_injury", "effect": "no_destroy", "value": 1}]}, "module")
	var sk := _fight([u], [_foe(30)])
	assert_eq(sk._injure_entry(sk.mechs[0], 0), "", "the injury lands and nothing breaks")
	assert_eq(u.die.faces[0].kind, Face.Kind.ATTACK, "the component holds")
	assert_true("\n".join(sk.log).contains("holds, never destroyed"), "the log says why")


func test_the_bot_weighs_the_plate_a_shot_spends_and_the_plate_a_spend_digs() -> void:
	var gun := _firing(4, 2, 2)
	var plain := Face.attack(3, L)
	var u := _mech("Badger", Die.of([gun, plain]), 0, 100)
	u.grant_passive(HOPPER)
	var sk := _fight([u], [_foe(60, 6), _foe(60, 6)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var pol := Policy.make(Policy.GREEDY, 1)
	var fill := pol.hopper_fill_score(sk, ms, plain, sk.front[0])
	assert_true(fill > 1.0 * 2.0 * Policy.HOPPER_WEIGHT, "a plain gun's load is worth what a shot would add and the plate it stands, while foes aim at its bare hull")
	Effects.add_loads(u, 4)
	assert_true(pol.hopper_score(sk, ms, gun, sk.front[0]) < pol.hopper_fill_score(sk, ms, gun, sk.front[0], 2), "the plate its fired loads stood for is a price on the shot")
	assert_eq(pol.hopper_fill_score(sk, ms, plain, sk.front[0]), 0.0, "a full hopper takes no more")


func test_the_validator_holds_the_hoppers_rules_to_their_numbers() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var errs: Array[String] = []
	db._validate_passive("passive p", {"id": "p", "name": "P", "description": "", "effects": [
		{"trigger": "static", "effect": "fill_hopper", "value": 1},
		{"trigger": "static", "effect": "hopper_plate", "value": 1, "per": 0}]}, errs)
	assert_true(errs.any(func(e: String) -> bool: return e.contains("fill_hopper")), "a fill with no cap is refused")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("hopper_plate")), "a plate for every nothing is refused")
	var ok: Array[String] = []
	db._validate_passive("passive q", HOPPER, ok)
	assert_eq(ok, [] as Array[String], "the Ore Hopper's shape passes")

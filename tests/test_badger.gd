extends TestCase

## The Honey Badger's Ore (Ryan, 20 November), on synthetic passives and entries: a stack of Ore for
## each foe a weapon's spend damages, never past the hopper's most, which a step raises and every
## raise adds to; at its threshold the Ore is armour, the Ore chip, an Ability no Purge touches, set
## the moment the Ore moves; a weapon that empties the hopper strikes once for every Ore, puts none
## back and is a dead entry with none; a step's plate for each Ore past the threshold; a grant held
## once a round (the Claw's Instant); never destroyed as a module's rule; the bot pricing the plate
## a spend digs and the plate an emptying spend gives up.

const L := Face.Reach.DIRECT
const K := Face.Keyword

## The Ore Hopper's shape: one Ore a foe damaged, three at most, a point of armour at three.
const ORE := {"id": "ore", "name": "Ore", "description": "", "effects": [
	{"trigger": "static", "effect": "fill_hopper", "value": 1, "cap": 3},
	{"trigger": "static", "effect": "hopper_plate", "value": 1, "at": 3, "slot": "plate"}]}
## The Miner step's shape: one more Ore, and a point for each Ore past three, in the plate's slot.
const MINER := {"id": "miner", "name": "Miner", "description": "", "effects": [
	{"trigger": "static", "effect": "hopper_max", "value": 1},
	{"trigger": "static", "effect": "hopper_plate", "value": 1, "at": 3, "past": 1, "slot": "plate"}]}
## Two raises of the most, read together.
const MORE := {"id": "more", "name": "More", "description": "", "effects": [
	{"trigger": "static", "effect": "hopper_max", "value": 3}]}


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


func _emptying(power: int) -> Face:
	return Face.from_dict({"kind": "attack", "reach": "direct", "power": power, "empties_hopper": true})


func test_every_foe_a_weapon_damages_puts_an_ore_in_and_three_is_armour() -> void:
	var u := _mech("Badger", Die.single(Face.attack(3, L)))
	u.grant_passive(ORE)
	var sk := _fight([u], [_foe(60)])
	assert_eq([Effects.store_cap(u, "hopper"), u.armour], [3, 1], "a most of three, and the base armour before any Ore")
	assert_true(sk.assign(0, sk.front[0]), "a plain gun spent")
	assert_eq([Effects.stacks_of(u, "hopper"), u.armour], [1, 1], "one foe damaged: an Ore, and no armour short of three")
	assert_true("\n".join(sk.log).contains("fills the hopper: +1 (1)"), "the log says so")
	Effects.add_loads(u, 2)
	assert_eq([Effects.stacks_of(u, "ore_plate"), u.armour], [1, 2], "at three, the Ore chip: a point of armour, at once")
	assert_true(Effects.is_ability("ore_plate"), "an Ability")
	Effects.purge(u, 9)
	assert_eq(u.armour, 2, "no Purge touches it")


func test_an_area_weapon_fills_for_each_foe_and_every_raise_of_the_most_adds() -> void:
	var u := _mech("Badger", Die.single(_spread(3, 2)))
	u.grant_passive(ORE)
	var sk := _fight([u], [_foe(30), _foe(30), _foe(30), _foe(30)])
	assert_true(sk.assign(0, sk.front[1]), "the spread on a middle foe")
	assert_eq(Effects.stacks_of(u, "hopper"), 3, "three foes damaged, three Ore")
	assert_eq(Effects.add_loads(u, 2), 0, "never past the most")
	u.grant_passive(MINER, "branch")
	u.grant_passive(MORE, "branch")
	assert_eq(Effects.store_cap(u, "hopper"), 7, "three, a step's one and another's three: cumulative")


func test_a_blow_that_deals_nothing_fills_nothing() -> void:
	var u := _mech("Badger", Die.of([Face.attack(2, L), Face.attack(0, L, [K.SHOCK])]))
	u.grant_passive(ORE)
	var sk := _fight([u], [_foe(30, 0, 3)])
	assert_true(sk.assign(0, sk.front[0]), "a 2 into armour 3")
	assert_eq(Effects.stacks_of(u, "hopper"), 0, "a blow its armour took whole damaged nothing")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, sk.front[0]), "equipment aimed at it")
	assert_eq(Effects.stacks_of(u, "hopper"), 0, "equipment deals no damage and fills nothing")


func test_an_emptying_weapon_strikes_once_an_ore_puts_none_back_and_is_dead_with_none() -> void:
	var u := _mech("Badger", Die.single(_emptying(2)))
	u.grant_passive(ORE)
	var sk := _fight([u], [_foe(60)])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(sk.cannot_pay(ms, u.die.faces[0]), "no Ore: a dead entry")
	assert_true(sk.targets_for_face(ms, u.die.faces[0]).is_empty(), "with nowhere to land")
	Effects.add_loads(u, 3)
	assert_eq(u.armour, 2, "three Ore held, a point of armour")
	assert_eq(Effects.effective_face(u, u.die.faces[0]).strikes, 3, "a strike for every Ore")
	assert_true(sk.assign(0, sk.front[0]), "it empties the hopper")
	assert_eq(sk.front[0].hp, 60 - 6, "three strikes of 2")
	assert_eq([Effects.stacks_of(u, "hopper"), u.armour], [0, 1], "every Ore spent and none put back, the armour gone with it")
	assert_true("\n".join(sk.log).contains("empties the hopper: 3 Ore, 3 strikes"), "the log says so")


func test_a_step_plates_each_ore_past_three_in_the_passives_place() -> void:
	var u := _mech("Badger", Die.single(Face.attack(3, L)))
	u.grant_passive(ORE)
	u.grant_passive(MINER, "branch")
	u.grant_passive(MORE, "branch")
	Effects.add_loads(u, 2)
	assert_eq(u.armour, 1, "two Ore: nothing")
	Effects.add_loads(u, 1)
	assert_eq(u.armour, 2, "three: the point")
	Effects.add_loads(u, 3)
	assert_eq([Effects.stacks_of(u, "hopper"), u.armour], [6, 5], "three past it, a point each: four in all and the base one")
	Effects.spend_loads(u, 6)
	assert_eq(u.armour, 1, "emptied, gone")


func test_a_grant_held_once_a_round_is_taken_by_the_first_spend_alone() -> void:
	var claw := Face.attack(2, L)
	claw.component = "test_claw"
	var u := _mech("Badger", Die.of([claw, Face.attack(1, L)]))
	u.grant_passive({"id": "twice", "name": "Twice", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "instant", "entry": "test_claw", "once": "round"}]}, "branch")
	var sk := _fight([u], [_foe(60)])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(Effects.effective_face(u, claw).has(K.INSTANT), "Instant before its first spend")
	assert_true(sk.assign(0, sk.front[0]), "the claw")
	assert_false(ms.assigned, "Instant: it acts again")
	assert_false(Effects.effective_face(u, claw).has(K.INSTANT), "and the grant is taken for the round")
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "found again: its second use")
	assert_true(ms.assigned, "which ends its action")
	sk.end_round()
	sk.start_round()
	assert_true(Effects.effective_face(u, claw).has(K.INSTANT), "a new round, the grant back")


func test_the_rules_read_as_sentences() -> void:
	assert_eq(Effects.effect_text(ORE["effects"][0]), "damaging a foe grants one Ore, up to 3", "the fill")
	assert_eq(Effects.effect_text(ORE["effects"][1]), "at 3 Ore, armour +1", "the plate")
	assert_eq(Effects.effect_text(MINER["effects"][0]), "Ore max +1", "the raise")
	assert_eq(Effects.effect_text(MINER["effects"][1]), "at 3 Ore, armour +1, and +1 for each Ore past 3", "the step's plate")


func test_never_destroyed_is_a_modules_rule() -> void:
	var u := _mech("Badger", Die.of([Face.attack(3, L), Face.attack(4, L)]))
	u.grant_passive({"id": "module:skeleton", "name": "Skeleton", "description": "", "effects": [{"trigger": "on_injury", "effect": "no_destroy", "value": 1}]}, "module")
	var sk := _fight([u], [_foe(30)])
	assert_eq(sk._injure_entry(sk.mechs[0], 0), "", "the injury lands and nothing breaks")
	assert_eq(u.die.faces[0].kind, Face.Kind.ATTACK, "the component holds")
	assert_true("\n".join(sk.log).contains("holds, never destroyed"), "the log says why")


func test_the_bot_weighs_the_plate_a_spend_digs_and_the_plate_an_emptying_spend_gives_up() -> void:
	var gun := _emptying(2)
	var plain := Face.attack(3, L)
	var u := _mech("Badger", Die.of([gun, plain]), 0, 100)
	u.grant_passive(ORE)
	var sk := _fight([u], [_foe(60, 6), _foe(60, 6)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var pol := Policy.make(Policy.GREEDY, 1)
	assert_true(pol.hopper_fill_score(sk, ms, plain, sk.front[0]) > 0.0, "a plain gun's Ore is worth a strike more of the emptying entry")
	assert_eq(pol.hopper_fill_score(sk, ms, gun, sk.front[0]), 0.0, "the emptying entry puts none in")
	Effects.add_loads(u, 3)
	assert_true(pol.hopper_score(sk, ms, gun, sk.front[0]) < 0.0, "the plate the Ore stood for is a price on emptying it")
	assert_eq(pol.hopper_fill_score(sk, ms, plain, sk.front[0]), 0.0, "a full hopper takes no more")


func test_the_validator_holds_the_hoppers_rules_to_their_numbers() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var errs: Array[String] = []
	db._validate_passive("passive p", {"id": "p", "name": "P", "description": "", "effects": [
		{"trigger": "static", "effect": "fill_hopper", "value": 1},
		{"trigger": "static", "effect": "hopper_plate", "value": 1, "at": 0},
		{"trigger": "static", "effect": "hopper_max", "value": 0}]}, errs)
	assert_true(errs.any(func(e: String) -> bool: return e.contains("fill_hopper")), "a fill with no most is refused")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("hopper_plate")), "a plate at nothing is refused")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("hopper_max")), "a raise of nothing is refused")
	for shape in [ORE, MINER, MORE]:
		var ok: Array[String] = []
		db._validate_passive("passive q", shape, ok)
		assert_eq(ok, [] as Array[String], "%s's shape passes" % shape["id"])

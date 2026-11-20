extends TestCase

## Three engines the Prairie Dog's branches stand on (Ryan, 20 November), on synthetic passives and
## entries: a grant held once a round and on a weapon alone (the first strike on a Brittle foe each
## turn Rapid), a machine's weapon strikes counting a status twice (Brittle), and a piece a step
## remakes whole, its new entry spent, read and shown while the die keeps the piece as printed.

const L := Face.Reach.DIRECT
const K := Face.Keyword


func _mech(d: Die) -> Unit:
	var u := Unit.mech(0, "Dog", Vector2i.ZERO)
	u.shield = 10
	u.shield_max = 10
	u.hull = 100
	u.hull_max = 100
	u.die = d
	return u


func _foe(hp: int = 60) -> Foe:
	return Foe.make("revenant", hp, 0)


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1, 4)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


func _brittle(f: Foe, n: int) -> void:
	Effects.stack(f, Effects.STATUS["brittled"], Effects.SKIRMISH, "test", n, Effects.status_decay(Effects.STATUS["brittled"]))


func test_the_first_weapon_strike_on_a_brittle_foe_each_round_is_rapid() -> void:
	var gun := Face.attack(3, L)
	var spray := Face.attack(0, L, [K.SHOCK])
	var u := _mech(Die.of([gun, Face.attack(3, L), spray]))
	u.grant_passive({"id": "flak", "name": "Flak", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "rapid", "when": "target_status", "status": "brittled", "weapon_only": true, "once": "round"}]}, "branch")
	var plain := _foe()
	var cracked := _foe()
	var sk := _fight([u], [plain, cracked])
	_brittle(cracked, 2)
	assert_false(Effects.effective_face(u, gun, plain).has(K.RAPID), "a foe with no Brittle: no Rapid")
	assert_false(Effects.effective_face(u, spray, cracked).has(K.RAPID), "equipment on a Brittle foe: none, a weapon's strike alone")
	assert_true(Effects.effective_face(u, gun, cracked).has(K.RAPID), "a weapon on a Brittle foe: Rapid")
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, cracked), "the first strike")
	assert_false(ms.assigned, "Rapid: it acts again")
	assert_false(Effects.effective_face(u, gun, cracked).has(K.RAPID), "the grant taken for the round")
	sk.end_round()
	sk.start_round()
	_brittle(cracked, 2)
	assert_true(Effects.effective_face(u, gun, cracked).has(K.RAPID), "back as the next round opens")


func test_a_machines_weapon_strikes_count_brittle_twice() -> void:
	var gun := Face.attack(3, L)
	var u := _mech(Die.single(gun))
	var foe := _foe()
	var sk := _fight([u], [foe])
	_brittle(foe, 2)
	assert_eq(Effects.damage_taken(foe, 3, u, true), 5, "a blow of 3 on Brittle 2: 5")
	u.grant_passive({"id": "harrier", "name": "Harrier", "description": "", "effects": [
		{"trigger": "static", "effect": "count_status", "value": "brittled", "times": 2}]}, "branch")
	assert_eq(Effects.damage_taken(foe, 3, u, true), 7, "counted twice: 7")
	assert_eq(Effects.damage_taken(foe, 3, null, true), 5, "another's blow reads it once")
	assert_true(sk.assign(0, foe), "the gun")
	assert_eq(foe.hp, 60 - 7, "and the strike lands so")


func test_a_step_remakes_a_piece_whole_and_the_die_keeps_it_printed() -> void:
	var spreader := Face.from_dict({"kind": "attack", "reach": "direct", "power": 0, "keywords": ["brittle", "cleave"], "brittle": 2, "cooldown": 1})
	spreader.component = "test_spreader"
	var u := _mech(Die.single(spreader))
	u.grant_passive({"id": "form", "name": "Form", "description": "", "effects": [
		{"trigger": "static", "effect": "piece_form", "entry": "test_spreader", "name": "Test Repeater",
			"face": {"kind": "attack", "reach": "direct", "power": 1, "strikes": 3, "keywords": ["brittle", "cleave"], "brittle": 1, "cleave": 1}}]}, "branch")
	var foe := _foe()
	var sk := _fight([u], [_foe(), foe, _foe()])
	assert_true(u.die.faces[0].is_debuff() and u.die.faces[0].cooldown_rounds() == 1, "the die keeps the piece as printed")
	var spent := Effects.effective_face(u, u.die.faces[0])
	assert_eq([spent.power, spent.strikes, spent.brittle, spent.cooldown_rounds(), spent.renamed], [1, 3, 1, 0, "Test Repeater"], "the entry as spent is the form, under its name")
	assert_eq(Effects.upgraded_face(u, u.die.faces[0]).strikes, 3, "and the codex shows it")
	assert_true(sk.assign(0, foe), "spent")
	assert_eq(foe.hp, 60 - 3, "three strikes of 1, the Brittle each lays landing once they are done")
	assert_eq(Effects.stacks_of(foe, "brittled"), 3, "a stack a strike")
	assert_false(Effects.is_entry_disabled(u, 0), "no cooldown: the form prints none")


func test_the_validator_holds_the_three() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var errs: Array[String] = []
	db._validate_passive("passive p", {"id": "p", "name": "P", "description": "", "effects": [
		{"trigger": "static", "effect": "count_status", "value": "brittled", "times": 1},
		{"trigger": "static", "effect": "piece_form", "entry": "x"},
		{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 1, "once": "round"}]}, errs)
	assert_true(errs.any(func(e: String) -> bool: return e.contains("count_status")), "a count of once is refused")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("piece_form")), "a form with no face is refused")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("once is")), "once a round on a static effect but a grant is refused")

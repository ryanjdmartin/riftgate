extends TestCase

## The Puffin's engines (Ryan, 11 November: "it MOVES heat around. Using an equipment on an ally
## moves some of its heat to the Puffin. A locked piece can transfer the Puffins heat to another
## unit along with a buff based on heat moved"; "just allies"; 19 November: "I think 4 for the
## Puffin. We can try empowered for 2"), on synthetic passives and entries: the pull equipment
## spent on an ally fires, taking up to its number of the ally's heat onto the spender; the dump
## that passes the spender's whole heat to an ally for a stack of its status for every step passed,
## past the ally's maximum too; the bot's reads of both.

const L := Face.Reach.DIRECT

## The pull's shape: equipment spent on an ally takes up to 4 of its heat.
const PULL := {"id": "pull", "name": "Pull", "description": "", "effects": [
	{"trigger": "on_buff_granted", "effect": "pull_heat", "value": 4}]}


func _mech(name: String, d: Die, heat_max: int = 12, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = 6
	u.shield_max = 6
	u.hull = hull
	u.hull_max = hull
	u.heat_max = heat_max
	u.die = d
	return u


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1, 4)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


## A buff for itself or an ally: Empowered 1.
func _coil() -> Face:
	return Face.from_dict({"kind": "buff", "status": "overcharged", "stacks": 1})


## The dump's shape: the spender's whole heat to one ally, Empowered 1 for every 2 passed.
func _dump() -> Face:
	return Face.from_dict({"kind": "buff", "status": "overcharged", "targets": "ally", "passes_heat": true, "heat_per_stack": 2})


func test_equipment_on_an_ally_takes_up_to_the_pulls_number_of_its_heat() -> void:
	var u := _mech("Puffin", Die.single(_coil()))
	u.grant_passive(PULL)
	var ally := _mech("Ally", Die.single(Face.attack(3, L)))
	var sk := _fight([u, ally], [Foe.make("revenant", 50, 0)])
	sk.mechs[1].heat = 7
	sk.mechs[0].heat = 2
	assert_true(sk.assign(0, sk.mechs[1]), "the buff on the ally")
	assert_eq([sk.mechs[1].heat, sk.mechs[0].heat], [3, 6], "4 of the ally's 7 onto the spender's 2")
	assert_eq(Effects.stacks_of(ally, "overcharged"), 1, "and the buff landed as ever")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("Puffin takes 4 heat off Ally")), "the log says so")
	assert_eq(Effects.granted_pull(u), 4, "the bot and the readout read its number")
	assert_eq(Effects.effect_text(PULL["effects"][0]), "an ally this machine spends equipment on: takes up to 4 of its heat onto this machine", "reads as a sentence")


func test_the_pull_takes_what_the_ally_has_and_never_fires_on_itself_or_a_weapon() -> void:
	var u := _mech("Puffin", Die.of([_coil(), Face.attack(3, L, [], 3)]))
	u.grant_passive(PULL)
	var ally := _mech("Ally", Die.single(Face.attack(3, L)))
	var sk := _fight([u, ally], [Foe.make("revenant", 50, 0)])
	sk.mechs[1].heat = 2
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.mechs[1]), "the buff on a cool ally")
	assert_eq([sk.mechs[1].heat, sk.mechs[0].heat], [0, 2], "the 2 it carries, no more")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].heat = 5
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.mechs[0]), "the buff on itself")
	assert_eq(sk.mechs[0].heat, 5, "no ally, no pull")
	sk.end_round()
	sk.start_round()
	sk.mechs[1].heat = 9
	sk.mechs[0].heat = 0
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, sk.front[0]), "a weapon at a foe")
	assert_eq([sk.mechs[1].heat, sk.mechs[0].heat], [9, 3], "a weapon pulls nothing: only its own heat")


func test_a_pull_may_take_the_spender_past_its_maximum_and_it_burns() -> void:
	var u := _mech("Puffin", Die.single(_coil()), 12)
	u.grant_passive(PULL)
	var ally := _mech("Ally", Die.single(Face.attack(3, L)), 12)
	var sk := _fight([u, ally], [Foe.make("revenant", 50, 0)])
	sk.mechs[0].heat = 10
	sk.mechs[1].heat = 15
	assert_true(sk.assign(0, sk.mechs[1]), "the buff on an overheating ally")
	assert_eq([sk.mechs[1].heat, sk.mechs[0].heat], [11, 14], "its overheat taken first, the spender past its own maximum")
	var hull := u.hull
	sk.end_round()
	assert_eq(hull - u.hull, 2, "the spender burns its 2 past the maximum as the turn ends")


func test_the_dump_passes_its_whole_heat_for_a_stack_every_two() -> void:
	var u := _mech("Puffin", Die.single(_dump()))
	var ally := _mech("Ally", Die.single(Face.attack(3, L)))
	var sk := _fight([u, ally], [Foe.make("revenant", 50, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 9
	sk.mechs[1].heat = 1
	assert_eq(sk.shown_face(ms, ms.face()).buff_stacks, 4, "the die shows what its heat would grant now: 4 for 9")
	assert_eq(sk.machine_targets_for(ms, ms.face()).has(ms), false, "an ally only, never itself")
	assert_true(sk.assign(0, sk.mechs[1]), "the dump on the ally")
	assert_eq([ms.heat, sk.mechs[1].heat], [0, 10], "the whole 9 passed")
	assert_eq(Effects.stacks_of(ally, "overcharged"), 4, "Empowered 1 for every 2 passed, rounded down")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("Puffin passes 9 heat to Ally")), "the log says so")
	assert_eq(_dump().describe(), "passes heat, Empowered 1 per 2 heat (allies only)", "its text says its rule")
	var back := Face.from_dict(_dump().to_dict())
	assert_eq([back.passes_heat, back.heat_per_stack], [true, 2], "the rule survives the save")


func test_the_dump_may_take_an_ally_past_its_maximum_and_it_burns() -> void:
	var u := _mech("Puffin", Die.single(_dump()))
	var ally := _mech("Ally", Die.single(Face.attack(3, L)), 12)
	var sk := _fight([u, ally], [Foe.make("revenant", 50, 0)])
	sk.mechs[0].heat = 14
	sk.mechs[1].heat = 4
	assert_true(sk.assign(0, sk.mechs[1]), "the dump on the ally")
	assert_eq([sk.mechs[0].heat, sk.mechs[1].heat], [0, 18], "its overheat passed with the rest, the ally past its maximum")
	var hull := ally.hull
	sk.end_round()
	assert_true(hull - ally.hull >= 6, "the ally burns its 6 past the maximum as the turn ends (%d)" % (hull - ally.hull))


func test_the_dump_pulls_nothing_and_too_little_heat_grants_nothing() -> void:
	var u := _mech("Puffin", Die.single(_dump()))
	u.grant_passive(PULL)
	var ally := _mech("Ally", Die.single(Face.attack(3, L)))
	var sk := _fight([u, ally], [Foe.make("revenant", 50, 0)])
	sk.mechs[0].heat = 1
	sk.mechs[1].heat = 6
	assert_true(sk.assign(0, sk.mechs[1]), "the dump of 1")
	assert_eq([sk.mechs[0].heat, sk.mechs[1].heat], [0, 7], "its heat goes the other way: no pull rides it")
	assert_eq(Effects.stacks_of(ally, "overcharged"), 0, "1 heat makes no stack")


func test_the_heat_passed_answers_the_allys_heat_gain() -> void:
	var u := _mech("Puffin", Die.single(_dump()))
	var petrel := _mech("Petrel", Die.single(Face.attack(3, L)))
	petrel.grant_passive({"id": "gen", "name": "Gen", "description": "", "effects": [
		{"trigger": "on_heat_gain", "effect": "shield_per_heat", "value": 1}]})
	petrel.shield_max = 20
	var sk := _fight([u, petrel], [Foe.make("revenant", 50, 0)])
	petrel.shield = 4
	sk.mechs[0].heat = 6
	assert_true(sk.assign(0, sk.mechs[1]), "the dump on a machine that turns heat to shield")
	assert_eq(petrel.shield, 10, "a point of shield for each of the 6 it gained")


func test_the_bot_reads_the_pull_and_the_dump() -> void:
	var u := _mech("Puffin", Die.of([_coil(), _dump()]))
	u.grant_passive(PULL)
	var ally := _mech("Ally", Die.single(Face.attack(3, L)))
	var sk := _fight([u, ally], [Foe.make("revenant", 50, 3)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var bot := Policy.make(Policy.GREEDY, 1)
	sk.mechs[1].heat = 8
	assert_true(bot.pull_score(sk, ms, sk.mechs[1]) > 0.0, "cooling a hot ally under its own maximum is worth something")
	assert_eq(bot.pull_score(sk, ms, ms), 0.0, "on itself, nothing")
	ms.heat = 10
	assert_true(bot.pull_score(sk, ms, sk.mechs[1]) < bot.vent_score(sk, sk.mechs[1], 4), "a pull that takes the spender past its maximum costs its burn")
	ms.heat = 8
	sk.mechs[1].heat = 0
	assert_true(bot.dump_score(sk, ms, sk.mechs[1], _dump()) > 0.0, "its heat as Empowered on an ally about to fire")
	ms.heat = 0
	assert_eq(bot.dump_score(sk, ms, sk.mechs[1], _dump()), 0.0, "an empty gauge passes nothing")


func test_the_validator_holds_the_dump_and_the_pull_to_their_shapes() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var face := {"kind": "buff", "status": "overcharged", "targets": "ally", "passes_heat": true, "heat_per_stack": 2}
	db.components["test_dump"] = {"id": "test_dump", "name": "Test Dump", "maker": str(db.components.values()[0].get("maker", "")), "tier": 2, "shape": "dish", "codex": "", "flavour": "", "design": {"stage": "draft", "fantasy": "A test."}, "face": face.duplicate(), "passive": null, "tags": []}
	var said := func() -> Array:
		return db.validate().filter(func(e: String) -> bool: return e.contains("test_dump"))
	assert_eq(said.call(), [], "the dump's shape is sound")
	db.components["test_dump"]["face"]["targets"] = "self_ally"
	assert_true((said.call() as Array).any(func(e: String) -> bool: return e.contains("lands on one ally")), "on one ally only")
	db.components["test_dump"]["face"] = face.duplicate()
	db.components["test_dump"]["face"]["stacks"] = 3
	assert_true((said.call() as Array).any(func(e: String) -> bool: return e.contains("no stacks")), "its stacks are the heat's, never printed")
	db.components["test_dump"]["face"] = face.duplicate()
	db.components["test_dump"]["face"].erase("heat_per_stack")
	assert_true((said.call() as Array).any(func(e: String) -> bool: return e.contains("heat_per_stack")), "it says the heat a stack stands for")
	db.components.erase("test_dump")
	var errs: Array[String] = []
	db._validate_passive("test pull", {"id": "pull", "name": "Pull", "description": "A pull.", "effects": [{"trigger": "static", "effect": "pull_heat", "value": 4}]}, errs)
	assert_true(errs.any(func(e: String) -> bool: return e.contains("pull_heat is on_buff_granted's")), "the pull fires on equipment spent on an ally")

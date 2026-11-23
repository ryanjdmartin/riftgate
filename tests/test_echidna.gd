extends TestCase

## The Echidna's engines (Ryan's kit of 20 November), on a synthetic passive and pieces: a needle
## on every foe a strike of its weapons or equipment reaches, a stack a strike, and on every foe
## whose blow lands on it, a stack a blow whatever the blow dealt ("Striking a foe, or getting
## struck by one, grants that foe a stack"); a needled foe conducting Chain as a Shocked one does;
## the stack that brings a foe to the rule's count firing the bolt, the Chain's number on every
## conductor, that foe included ("targeted at nothing. So the foe that hit 3 stacks and procced it
## would take 2 by definition"), each an arc that lays nothing and spends no Shock, through each
## foe's Brittle, Barrier and armour, then the foe's stacks spent; a bolt from a foe the strike
## felled; a striker its own blow's bolt fells striking no more; a Ward turning the needles away;
## and the branches' tweaks (a bolt that leaves its foe a stack, a sap a stack, a weapon's add a
## stack on its target). The status is the engine's; the passive and its numbers are the test's.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT
const K := Face.Keyword
const NEEDLE := "sonic_needle"
const NEEDLES := {"id": "test_needles", "name": "Test Needles", "description": "", "effects": [
	{"trigger": "on_attack", "effect": "lay_status", "value": NEEDLE, "stacks": 1},
	{"trigger": "on_struck", "effect": "lay_status", "value": NEEDLE, "stacks": 1},
	{"trigger": "static", "effect": "needles", "status": NEEDLE, "at": 3, "chain": 2}]}


func _mech(d: Die, steps: Array = [], shield: int = 10, hull: int = 100) -> Unit:
	var u := Unit.mech(0, "Echidna", Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	u.grant_passive(NEEDLES)
	if not steps.is_empty():
		u.grant_passive({"id": "test_step", "name": "Test Step", "description": "", "effects": steps})
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


func _needle(foe: Foe, n: int) -> void:
	Effects.stack(foe, Effects.STATUS[NEEDLE], Effects.SKIRMISH, "mech", n, Effects.DECAY_NONE)


func _status(foe: Foe, id: String) -> void:
	Effects.stack(foe, Effects.STATUS[id], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)


func test_a_strike_lays_a_needle_on_every_foe_it_reaches_a_stack_a_strike() -> void:
	var twin := Face.attack(1, L)
	twin.strikes = 2
	var spread := Face.attack(1, L, [K.CLEAVE])
	spread.cleave = 1
	var probe := Face.attack(0, I, [K.LURE])
	var u := _mech(Die.of([twin, spread, probe]))
	var a := _foe()
	var b := _foe()
	var c := _foe()
	var sk := _fight([u], [a, b, c])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, a), "two strikes at the first foe")
	assert_eq(Effects.stacks_of(a, NEEDLE), 2, "a needle a strike")
	ms.assigned = false
	ms.face_index = 1
	assert_true(sk.assign(0, b), "a spread at the middle foe")
	assert_eq([Effects.stacks_of(a, NEEDLE), Effects.stacks_of(b, NEEDLE), Effects.stacks_of(c, NEEDLE)], [0, 1, 1], "a needle on every foe the strike reaches, the third on the first firing its bolt")
	ms.assigned = false
	ms.face_index = 2
	assert_true(sk.assign(0, c), "equipment at the last")
	assert_eq(Effects.stacks_of(c, NEEDLE), 2, "equipment's strike lays one too")


func test_a_blow_on_it_lays_a_needle_on_its_striker_whatever_it_dealt() -> void:
	var u := _mech(Die.single(Face.blank()))
	var foe := _foe(30, 2)
	foe.action["strikes"] = 2
	var sk := _fight([u], [foe])
	_status_mech(u, "barrier")
	sk.end_round()
	assert_eq(Effects.stacks_of(foe, NEEDLE), 2, "a needle a blow, the one its Barrier took whole among them")
	assert_eq(u.shield, 8, "the second blow on the shield")


func _status_mech(u: Unit, id: String) -> void:
	Effects.stack(u, Effects.STATUS[id], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)


func test_a_needled_foe_conducts_chain() -> void:
	var arc := Face.attack(3, L, [K.CHAIN])
	arc.chain = 2
	var u := _mech(Die.single(arc))
	var a := _foe()
	var b := _foe()
	var c := _foe()
	var sk := _fight([u], [a, b, c])
	_needle(b, 1)
	assert_eq(Array(sk.conducting_foes(null)), [b], "a needle conducts")
	assert_eq(Array(sk.conductors(arc, a)), [b], "so Chain arcs to it")
	assert_true(sk.assign(0, a), "the Chain gun at the first foe")
	assert_eq([a.hp, b.hp, c.hp], [27, 28, 30], "the arc on the needled foe, nothing on the plain one")
	assert_eq(Effects.stacks_of(b, NEEDLE), 1, "an arc lays no needle")


func test_the_third_needle_fires_chain_2_on_every_conductor_its_own_foe_included() -> void:
	var u := _mech(Die.single(Face.attack(1, L)))
	var a := _foe()
	var b := _foe()
	var c := _foe()
	var d := _foe()
	var sk := _fight([u], [a, b, c, d])
	_needle(a, 2)
	_needle(b, 1)
	_status(c, "shocked")
	assert_true(sk.assign(0, a), "a strike lays the third needle")
	assert_eq([a.hp, b.hp, c.hp, d.hp], [27, 28, 28, 30], "the bolt's 2 on every conductor, the foe it fired from among them")
	assert_eq(Effects.stacks_of(a, NEEDLE), 0, "every stack on that foe consumed")
	assert_eq(Effects.stacks_of(b, NEEDLE), 1, "the others' stand, and an arc lays none")
	assert_true(Effects.has(c, "shocked"), "no strike aimed at a conductor: its Shock stands")


func test_the_bolt_meets_brittle_a_barrier_and_armour() -> void:
	var u := _mech(Die.single(Face.attack(0, I, [K.LURE])))
	var a := _foe()
	var brittle := _foe()
	var barred := _foe()
	var plated := _foe(30, 0, 1)
	var sk := _fight([u], [a, brittle, barred, plated])
	_needle(a, 2)
	for f in [brittle, barred, plated]:
		_needle(f, 1)
	_status(brittle, "brittled")
	_status(barred, "barrier")
	assert_true(sk.assign(0, a), "equipment lays the third needle")
	assert_eq([a.hp, brittle.hp, barred.hp, plated.hp], [28, 27, 30, 29], "2 on its foe, Brittle adding, a Barrier taking it whole, armour taking 1")
	assert_false(Effects.has(barred, "barrier"), "the Barrier is spent")


func test_two_needles_on_a_foe_at_two_fire_once_and_leave_one() -> void:
	var twin := Face.attack(1, L)
	twin.strikes = 2
	var u := _mech(Die.single(twin))
	var a := _foe()
	var sk := _fight([u], [a])
	_needle(a, 2)
	assert_true(sk.assign(0, a), "two strikes on a foe at two")
	assert_eq(a.hp, 30 - 2 - 2, "the two strikes and one bolt")
	assert_eq(Effects.stacks_of(a, NEEDLE), 1, "a stack at a time: the bolt at the third, the fourth left")


func test_a_foe_the_strike_fells_fires_its_bolt_all_the_same() -> void:
	var u := _mech(Die.single(Face.attack(3, L)))
	var a := _foe(2)
	var b := _foe()
	var sk := _fight([u], [a, b])
	_needle(a, 2)
	_needle(b, 1)
	assert_true(sk.assign(0, a), "the strike fells the foe at two")
	assert_false(a.alive(), "it falls")
	assert_eq(b.hp, 28, "and its third needle's bolt still arcs to the other conductor")


func test_a_striker_its_own_blows_bolt_fells_strikes_no_more() -> void:
	var u := _mech(Die.single(Face.blank()))
	var foe := _foe(2, 3)
	foe.action["strikes"] = 2
	var sk := _fight([u], [foe])
	_needle(foe, 2)
	sk.end_round()
	assert_false(foe.alive(), "its first blow's needle fired the bolt on it, and it fell")
	assert_eq(u.shield, 7, "its second blow never landed")


func test_a_wreck_lays_no_needle() -> void:
	var u := _mech(Die.single(Face.blank()), [], 0, 2)
	var foe := _foe(30, 5)
	var sk := _fight([u], [foe])
	sk.end_round()
	assert_false(sk.mechs[0].alive(), "the blow wrecks it")
	assert_eq(Effects.stacks_of(foe, NEEDLE), 0, "and a wreck lays nothing")


func test_a_ward_turns_the_needles_away_and_a_cleanse_counts_them() -> void:
	var u := _mech(Die.single(Face.attack(1, L)))
	var a := _foe()
	var b := _foe()
	var sk := _fight([u], [a, b])
	_status(a, "ward")
	assert_true(sk.assign(0, a), "a strike on a Warded foe")
	assert_eq(Effects.stacks_of(a, NEEDLE), 0, "its Ward turns the needle away")
	_needle(b, 1)
	assert_eq(Effects.team_marks(b), 1, "a team's mark, which a foe's cleanse takes")


func test_a_bolt_that_leaves_a_stack_fires_again_two_needles_on() -> void:
	var u := _mech(Die.single(Face.attack(0, I, [K.LURE])), [{"trigger": "static", "effect": "needles", "keeps": 1}])
	var a := _foe()
	var sk := _fight([u], [a])
	_needle(a, 2)
	assert_true(sk.assign(0, a), "the third needle")
	assert_eq([a.hp, Effects.stacks_of(a, NEEDLE)], [28, 1], "the bolt, and its stacks down to one")
	sk._land_rider(a, NEEDLE, 1, {}, {})
	assert_eq([a.hp, Effects.stacks_of(a, NEEDLE)], [28, 2], "the next needle short of the count")
	sk._land_rider(a, NEEDLE, 1, {}, {})
	assert_eq([a.hp, Effects.stacks_of(a, NEEDLE)], [26, 1], "and the one after fires it again")


func test_a_sapping_needle_takes_its_number_off_the_foes_blow_a_stack() -> void:
	var u := _mech(Die.single(Face.blank()), [{"trigger": "static", "effect": "needles", "sap": 1}])
	var foe := _foe(30, 5)
	var sk := _fight([u], [foe])
	var whole := sk.foe_blow(foe)
	sk._land_rider(foe, NEEDLE, 2, {}, {})
	assert_eq(sk.foe_blow(foe), whole - 2, "a point off its blow for each needle")
	sk._land_rider(foe, NEEDLE, 1, {}, {})
	assert_eq(sk.foe_blow(foe), whole, "and the bolt's spent needles take their sap with them")


func test_a_weapons_add_a_stack_on_its_target_reads_the_needles() -> void:
	var gun := Face.attack(3, L)
	var u := _mech(Die.single(gun), [{"trigger": "on_attack", "effect": "add_damage", "value": 1, "per_target": NEEDLE, "when": "weapon"}])
	var foe := _foe()
	var plain := _foe()
	_fight([u], [foe, plain])
	_needle(foe, 2)
	assert_eq(int(Effects.attack(u, gun, 3, 0, foe)["damage"]), 5, "+1 for each needle in the foe it is aimed at")
	assert_eq(int(Effects.attack(u, gun, 3, 0, plain)["damage"]), 3, "nothing on a foe without one")


func test_a_needle_with_no_machine_to_fire_it_lands_as_any_status() -> void:
	var gun := Face.attack(1, L)
	var plain := Unit.mech(0, "Plain", Vector2i.ZERO)
	plain.shield = 10
	plain.shield_max = 10
	plain.hull = 100
	plain.hull_max = 100
	plain.die = Die.single(gun)
	var a := _foe()
	var sk := _fight([plain], [a])
	_needle(a, 2)
	sk._land_rider(a, NEEDLE, 1, {}, {})
	assert_eq([a.hp, Effects.stacks_of(a, NEEDLE)], [30, 3], "no rule in the fight, no bolt")


func test_the_bot_prices_the_bolt_a_needle_brings() -> void:
	var u := _mech(Die.single(Face.attack(0, I, [K.LURE])))
	var a := _foe()
	var b := _foe()
	var sk := _fight([u], [a, b])
	var ms: Skirmish.MechState = sk.mechs[0]
	var bot := Policy.new()
	_needle(b, 1)
	var short := bot.needle_worth(sk, ms, a, 1, a.hp)
	_needle(a, 2)
	var brings := bot.needle_worth(sk, ms, a, 1, a.hp)
	assert_true(brings > short, "the needle that fires the bolt is worth more than one short of it")
	assert_eq(Policy.needle_bolts(2, 2, 3, 0), [1, 1], "two on a foe at two: one bolt, one left")
	assert_eq(Policy.needle_bolts(2, 2, 3, 1), [1, 2], "a bolt that leaves one: the first fires it, the second stands")
	assert_eq(Policy.needle_bolts(2, 3, 3, 1), [2, 1], "and every second needle after fires it again")


func test_chain_strikes_a_needled_target_too() -> void:
	# Chain strikes every conductor (Ryan, 21 November: "Any conductor"): a needle in its own target
	# stays through the strike, so the arc strikes it as well.
	var arc := Face.attack(3, L, [K.CHAIN])
	arc.chain = 2
	var u := _mech(Die.single(arc))
	var a := _foe()
	var b := _foe()
	var sk := _fight([u], [a, b])
	_needle(a, 1)
	assert_eq(Array(sk.conductors(arc, a)), [a], "its needled target conducts its own arc")
	assert_true(sk.assign(0, a), "the Chain gun at the needled foe")
	assert_eq(a.hp, 30 - 3 - 2, "the strike, then the arc")
	assert_eq(b.hp, 30, "and nothing on a foe that conducts nothing")

extends TestCase

## When what a unit carries ends (Ryan's rulings of 16 November), on synthetic pieces.
## Empowered halves as its side's turn ends ("Empowered should decay at the end of turn, clearly,
## not end of round"): a machine's at END TURN, a foe's as the foes' turn ends, the round's end.
## A Phased machine is damaged by nothing and everything it carries ticks ("Everything ticks
## during phased. It doesn't take damage but it's a way of waiting out a debuff"), a bite of its
## own entry blocked with the rest ("I think we block the damage as a feature"). A Swallowed
## machine is out of play and everything it carries waits ("Swallowed it's out of play so
## everything should pause"): the rounds it sat out never came for it.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT

## Regen and cooling granted, as a module or a passive would: a chassis has none of its own.
const MENDER := {"id": "mender", "name": "Mender", "description": "", "effects": [
	{"trigger": "static", "effect": "add_stat", "stat": "shield_regen", "value": 3},
	{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 2}]}
## A hull hit that grants Empowered: a stack gained in the enemy's turn.
const SPITE := {"id": "spite", "name": "Spite", "description": "", "effects": [
	{"trigger": "on_hull_damage", "effect": "stack_status", "value": "overcharged", "stacks": 3}]}


func _mech(name: String, d: Die, shield: int = 0, hull: int = 500) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.heat_max = 30
	u.die = d
	return u


func _lay(u, id: String, n: int) -> void:
	Effects.stack(u, Effects.STATUS[id], Effects.SKIRMISH, "test", n, Effects.status_decay(Effects.STATUS[id]))


## What a machine carries, as numbers: every clock's count, a timed buff, the rounds its dark
## entry has left, and its gauges.
func _carried(sk: Skirmish, at: int, entry: int) -> Array:
	var ms: Skirmish.MechState = sk.mechs[at]
	var u: Unit = ms.unit
	return [Effects.stacks_of(u, "ablating_mech"), Effects.stacks_of(u, "scorched"), Effects.stacks_of(u, "sapped"),
		Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech"), Effects.stacks_of(u, "regenerating"),
		Effects.stacks_of(u, "braced"), Effects.has(u, "barrier"), Effects.dark_rounds(u, entry, sk.round),
		u.shield, u.hull, ms.heat]


# ---------------------------------------------------------------- Empowered's clock

func test_a_machines_empowered_halves_as_its_turn_ends_and_a_foes_as_the_round_does() -> void:
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.single(Face.attack(1, L)))
	u.grant_passive(SPITE)
	sk.add_mech(u)
	var g := Foe.make("revenant", 500, 5)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	_lay(u, "overcharged", 4)
	_lay(g, "kindled", 4)
	sk.end_round()
	assert_eq(u.hull, 500 - 9, "the foe's is whole through its own turn: a blow of 5 and 4")
	assert_eq(Effects.stacks_of(g, "kindled"), 2, "and halves as that turn ends, the round's end")
	assert_eq(Effects.stacks_of(u, "overcharged"), 2 + 3, "the machine's halved as its own turn ended, four to two, and the three it gained in the enemy's turn stand whole: the round's end halves none of a machine's")
	sk.start_round()
	assert_eq(Effects.stacks_of(u, "overcharged"), 5, "carried whole into its next turn")
	sk.end_round()
	assert_eq(u.hull, 500 - 9 - 7, "the foe's blow at 5 and 2")
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(g, "kindled")], [2 + 3, 1], "five to two as its turn ended, and three more gained; the foe's two to one")


func test_a_buff_that_halves_and_a_debuff_that_halves_keep_their_own_ends() -> void:
	var u := _mech("A", Die.single(Face.blank()))
	_lay(u, "overcharged", 5)
	_lay(u, "brittled_mech", 5)
	Effects.halve_buffs(u)
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [2, 5], "its side's turn ends: the buff halves, rounded down, the debuff left alone")
	Effects.tick(u)
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [2, 2], "the round's end: the debuff halves, the buff left alone")
	Effects.halve_buffs(u, ["overcharged"])
	assert_eq(Effects.stacks_of(u, "overcharged"), 2, "what the field holds this round does not halve")
	Effects.halve_buffs(u)
	Effects.halve_buffs(u)
	assert_false(Effects.has(u, "overcharged"), "two to one to none")


# ---------------------------------------------------------------- Phased: everything ticks

func test_everything_a_phased_machine_carries_ticks_and_nothing_damages_it() -> void:
	var sk := Skirmish.new(1)
	var fist := Face.attack(30, L)
	fist.volatile = 10
	var u := _mech("A", Die.single(fist), 10, 100)
	u.shield_max = 20
	sk.add_mech(u)
	sk.add_mech(_mech("B", Die.single(Face.blank())))
	var g := Foe.make("revenant", 900, 5)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	Effects.grant_for_rounds(u, Effects.STATUS["phased"], "test", sk.round + 1)   # Phased this round and the next
	_lay(u, "ablating_mech", 3)
	_lay(u, "scorched", 2)
	_lay(u, "overcharged", 4)
	_lay(u, "brittled_mech", 4)
	Effects.stack(u, Effects.regenerating_shield(), Effects.SKIRMISH, "buff:test", 2, Effects.DECAY_NONE)
	Effects.corrupt_entry(u, 0, "foe:x", 2)
	ms.heat = ms.heat_max + 5
	# A bite of its own entry is damage, and nothing damages it.
	assert_eq([sk.pending_volatile(ms), sk.pending_bite(ms)], [0, 0], "no Volatile bite and no corrupted entry's while it is Phased")
	assert_eq(Policy.volatile_cost(sk, ms, fist), 0.0, "and the bot counts none")
	assert_true(sk.assign(0, g), "it acts")
	assert_eq([u.shield, u.hull], [10, 100], "and the spend cost it nothing")
	assert_true(g.hp < 900, "the weapon did its work")
	var hot := ms.heat
	sk.end_round()
	assert_eq([u.shield, u.hull], [10, 100], "END TURN: its Ablating takes no point and its heat burns nothing")
	assert_eq(Effects.stacks_of(u, "ablating_mech"), 2, "and a stack fades all the same: Phased waits a debuff out")
	assert_false(Effects.has(u, "scorched"), "its Scorched goes with the turn")
	assert_eq(Effects.stacks_of(u, "overcharged"), 2, "its Empowered halves as its turn ends")
	assert_eq(Effects.stacks_of(u, "brittled_mech"), 2, "its Brittle halves as the round does")
	assert_eq(ms.heat, hot, "the heat stays where it stood")
	sk.start_round()
	assert_true(Skirmish.is_phased(ms), "Phased still as the next round opens")
	assert_eq([u.shield, Effects.stacks_of(u, "regenerating")], [12, 1], "its Regenerating pays a point a stack and a stack fades")
	sk.end_round()
	assert_eq([Effects.stacks_of(u, "ablating_mech"), Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [1, 1, 1], "a second round of the same: each a step down")
	assert_eq([u.shield, u.hull], [12, 100], "and no damage taken")
	# Back in reach: the stack left takes its point, and the heat it carried burns.
	sk.start_round()
	assert_false(Skirmish.is_out(ms), "back in reach")
	g.target = sk.mechs[1]
	assert_eq(sk.pending_volatile(ms), 10, "and its spend costs what it says again")
	var over := ms.heat - ms.heat_max
	assert_true(over > 0, "it carried its heat past the maximum through both rounds")
	sk.end_round()
	assert_false(Effects.has(u, "ablating_mech"), "the last stack ticked and went")
	assert_eq(u.hull, 100 - over * Skirmish.overheat_scale, "the turn it is back, the heat past its maximum burns")


# ---------------------------------------------------------------- Swallowed: everything waits

func test_everything_a_swallowed_machine_carries_waits_and_it_comes_back_as_it_left() -> void:
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.of([Face.attack(1, L), Face.attack(1, L)]), 10, 100)
	u.shield_max = 20
	u.grant_passive(MENDER)
	sk.add_mech(u)
	sk.add_mech(_mech("B", Die.single(Face.blank())))
	var g := Foe.make("revenant", 900, 5)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	Effects.grant_for_rounds(u, Effects.STATUS["swallowed"], "test", sk.round + 1)   # out this round and the next
	_lay(u, "ablating_mech", 3)
	_lay(u, "scorched", 2)
	_lay(u, "sapped", 2)
	_lay(u, "overcharged", 4)
	_lay(u, "brittled_mech", 4)
	Effects.stack(u, Effects.regenerating_shield(), Effects.SKIRMISH, "buff:test", 2, Effects.DECAY_NONE)
	Effects.grant_buff(u, "braced", 2, "test", sk.round)
	Effects.grant_buff(u, "barrier", 1, "test", sk.round)
	Effects.disable_entry(u, 1, "cooldown", sk.round + 2)
	ms.heat = ms.heat_max + 5
	ms.killed_round = true   # a kill of its own before it was taken: what a passive reads as a round ends
	var left := _carried(sk, 0, 1)
	assert_eq(left, [3, 2, 2, 4, 4, 2, 2, true, 3, 13, 100, 35], "what it carries as it is taken (its shield with the regen the round's opening paid)")
	assert_true(Skirmish.paused(ms), "everything on it is paused")
	sk.end_round()
	sk.start_round()
	assert_true(Skirmish.is_swallowed(ms), "out for its second round")
	assert_eq(_carried(sk, 0, 1), left, "a round out: no stack faded, halved or paid, nothing timed ran out, nothing cooled, regenerated or burned, and the dark entry has the rounds it had")
	assert_true(ms.killed_round, "and what waits on the round's end waits with it")
	sk.end_round()
	# Its swallow's rounds have run: it is let go as the round ends, before that round's end is
	# read, so the round's end it was owed reads it like any machine: its Brittle halves, the
	# Barrier that was a round's ends, its kill is read.
	assert_false(Skirmish.is_swallowed(ms), "let go as its second round out ends")
	assert_eq(Effects.stacks_of(u, "brittled_mech"), 2, "its Brittle halves with the round it is back for")
	assert_false(Effects.has(u, "barrier"), "the Barrier that was a round's ends with it")
	assert_false(ms.killed_round, "and the round's end reads its kill")
	assert_eq([Effects.stacks_of(u, "ablating_mech"), Effects.stacks_of(u, "scorched"), Effects.stacks_of(u, "sapped"), Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "regenerating"), Effects.stacks_of(u, "braced")], [3, 2, 2, 4, 2, 2], "what its own turn runs down still stands")
	sk.start_round()
	assert_false(ms.assigned, "back and acting")
	g.target = sk.mechs[1]
	# The turn opens for it again: its Armoured goes, it cools and regenerates, its Regenerating
	# pays, and the dark entry has the two rounds more it had when it was taken.
	assert_eq(_carried(sk, 0, 1), [3, 2, 2, 4, 2, 1, 0, false, 2, 13 + 3 + 2, 100, 35 - 2], "as its turn opens")
	sk.end_round()
	assert_eq([Effects.stacks_of(u, "ablating_mech"), Effects.stacks_of(u, "scorched"), Effects.stacks_of(u, "sapped")], [2, 0, 0], "its turn's end, as it would have been: Ablating ticks, Scorched and Sapped go")
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [2, 1], "Empowered halves with its turn and Brittle with the round")
	assert_eq(u.hull, 100 - 3 * Skirmish.overheat_scale, "the heat it carried burns the turn it is back")
	sk.start_round()
	assert_eq(Effects.dark_rounds(u, 1, sk.round), 1, "the dark entry counts down again")


## Only the swallow's own rounds run: every other timed thing moves a round later for each
## round's end it sits out, and none for the round's end it is let go at.
func test_the_swallows_own_rounds_run_while_every_other_clock_stands() -> void:
	var u := _mech("A", Die.single(Face.attack(1, L)))
	Effects.grant_for_rounds(u, Effects.STATUS["swallowed"], "test", 2)
	Effects.grant_buff(u, "barrier", 1, "test", 1)
	Effects.disable_entry(u, 0, "cooldown", 4)
	assert_eq(Effects.dark_rounds(u, 0, 1), 4, "taken in the first round with its entry dark for the rest of it and three more")
	assert_true(Effects.pause_round(u, 1, "swallowed"), "the first round's end: still held")
	assert_true(Effects.has(u, "swallowed") and Effects.has(u, "barrier"), "the swallow holds, and the Barrier that was that round's stands")
	assert_eq(Effects.dark_rounds(u, 0, 2), 4, "the dark entry a round later: the round it sat out is not counted")
	assert_false(Effects.pause_round(u, 2, "swallowed"), "the second round's end: its rounds have run")
	assert_false(Effects.has(u, "swallowed"), "the swallow gone on its own clock")
	assert_eq(Effects.dark_rounds(u, 0, 2), 4, "and nothing moved this time: it is back before the round's end is read")
	Effects.end_round(u, 2)
	assert_false(Effects.has(u, "barrier"), "so that round's end takes the Barrier, the end it was owed")
	assert_eq(Effects.dark_rounds(u, 0, 3), 3, "and its entry has the three rounds it had left when it was taken")


## Let go in the player's turn (its swallower felled), it acts that round and its clocks run
## from there: the turn's end ticks it like any machine.
func test_a_machine_let_go_in_the_players_turn_ticks_that_turn() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(10, I)), 10, 100)
	var b := _mech("B", Die.single(Face.attack(50, I)))
	sk.add_mech(a)
	sk.add_mech(b)
	var flo := Foe.make("floraison", 40, 10)
	flo.actions = [{"id": "swallow", "name": "Swallow", "kind": "debuff", "effect": "swallow", "value": 3, "weight": 1, "text": ""},
		{"id": "lash", "name": "Lash", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": ""}]
	var rev := Foe.make("revenant", 900, 1)
	sk.add_foes([flo, rev])
	sk.begin()
	sk.start_round()
	flo.action = flo.actions[0]
	flo.target = sk.mechs[0]
	sk.end_round()
	assert_true(Skirmish.is_swallowed(sk.mechs[0]), "A is swallowed in the enemy's turn")
	_lay(a, "ablating_mech", 2)
	_lay(a, "overcharged", 4)
	sk.start_round()
	assert_true(sk.assign(1, flo), "B fells the swallower")
	assert_false(Skirmish.is_swallowed(sk.mechs[0]), "and A is let go at once")
	rev.target = sk.mechs[1]
	sk.end_round()
	assert_eq(Effects.stacks_of(a, "ablating_mech"), 1, "back in play, its Ablating ticks as the turn ends")
	assert_eq(a.shield, 10 - 2, "a point a stack")
	assert_eq(Effects.stacks_of(a, "overcharged"), 2, "and its Empowered halves")


## A buff that holds the field's statuses from halving (the engine's Essence Flare) waits with
## a Swallowed carrier: out of play it holds nothing, and it holds the round its machine is
## back for.
func test_a_swallowed_machines_hold_on_the_field_waits_with_it() -> void:
	var sk := Skirmish.new(1)
	var holder := _mech("A", Die.single(Face.blank()))
	var ally := _mech("B", Die.single(Face.blank()))
	sk.add_mech(holder)
	sk.add_mech(ally)
	var g := Foe.make("revenant", 900, 1)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.grant_for_rounds(holder, Effects.STATUS["essence_flare"], "test", sk.round)
	assert_true(sk.field_holds().has("overcharged"), "the buff holds every Empowered on the field")
	Effects.grant_for_rounds(holder, Effects.STATUS["swallowed"], "test", sk.round + 1)
	assert_true(sk.field_holds().is_empty(), "and nothing once its machine is out of play")
	_lay(ally, "overcharged", 8)
	_lay(g, "kindled", 8)
	sk.end_round()
	assert_eq([Effects.stacks_of(ally, "overcharged"), Effects.stacks_of(g, "kindled")], [4, 4], "so both sides' Empowered halves as ever")
	assert_true(Effects.has(holder, "essence_flare"), "the buff itself waits on its machine")
	sk.start_round()
	sk.end_round()
	assert_false(Skirmish.is_swallowed(sk.mechs[0]), "let go as its second round out ends")
	assert_eq(Effects.stacks_of(ally, "overcharged"), 2, "the ally's halved at END TURN, its holder still out")
	assert_eq(Effects.stacks_of(g, "kindled"), 4, "and the foe's is held as the round ends: the holder is back for that end, the buff's own")
	assert_false(Effects.has(holder, "essence_flare"), "and the buff ends with it")

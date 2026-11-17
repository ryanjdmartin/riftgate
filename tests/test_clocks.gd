extends TestCase

## When what a unit carries ends (Ryan's rulings of 16 November), on synthetic pieces.
## His four places ("I see four places things should decay, tick, or fall off"): its turn's
## start, its turn's end, the round's end, and when it is spent. A machine's turn starts as the
## round opens and ends at END TURN; a foe's starts as the foes' turn opens and ends as its own
## action does. Empowered halves as its turn ends ("Empowered should decay at the end of turn,
## clearly, not end of round"). A Phased machine is damaged by nothing and everything it carries
## ticks ("Everything ticks during phased. It doesn't take damage but it's a way of waiting out a
## debuff"), a bite of its own entry blocked with the rest ("I think we block the damage as a
## feature"). A Swallowed machine is out of play and everything it carries waits ("Swallowed
## it's out of play so everything should pause"): the rounds it sat out never came for it.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT

## Regen and cooling granted, as a module or a passive would: a chassis has none of its own.
const MENDER := {"id": "mender", "name": "Mender", "description": "", "effects": [
	{"trigger": "static", "effect": "add_stat", "stat": "shield_regen", "value": 3},
	{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 2}]}
## A buff on a machine's turn clock, a stack fading as each of its turns ends (a machine's
## Regenerating was one until 17 November, when it left with its last carrier).
const TICKER := {"id": "ticker", "name": "Ticker", "description": "", "decay": "turn", "tags": ["buff"], "effects": []}
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
		Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech"), Effects.stacks_of(u, "ticker"),
		Effects.stacks_of(u, "braced"), Effects.has(u, "barrier"), Effects.dark_rounds(u, entry, sk.round),
		u.shield, u.hull, ms.heat]


# ---------------------------------------------------------------- Empowered's clock

func test_empowered_halves_as_its_carriers_own_turn_ends_on_either_side() -> void:
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
	assert_eq(Effects.stacks_of(g, "kindled"), 2, "and halves as that turn ends, its action done")
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
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [2, 5], "its turn ends: the buff halves, rounded down, the debuff left alone")
	Effects.tick(u, true)
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [2, 5], "the round's end halves nothing")
	Effects.turn_opens(u)
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [2, 2], "its turn starts: the debuff halves, the other side's blows having used it, the buff left alone")
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
	Effects.stack(u, TICKER, Effects.SKIRMISH, "buff:test", 2, Effects.DECAY_TURN)
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
	assert_eq(Effects.stacks_of(u, "ablating_mech"), 2, "a stack fades all the same: Phased waits a debuff out")
	assert_eq(Effects.stacks_of(u, "ticker"), 1, "and a stack of a buff on its turn's clock")
	assert_false(Effects.has(u, "scorched"), "its Scorched goes with the turn")
	assert_eq(Effects.stacks_of(u, "overcharged"), 2, "its Empowered halves as its turn ends")
	assert_eq(Effects.stacks_of(u, "brittled_mech"), 4, "its Brittle waits for its turn's start")
	assert_eq(ms.heat, hot, "the heat stays where it stood")
	sk.start_round()
	assert_true(Skirmish.is_phased(ms), "Phased still as the next round opens")
	assert_eq(Effects.stacks_of(u, "brittled_mech"), 2, "and its Brittle halves there, Phased or not")
	sk.end_round()
	assert_eq([Effects.stacks_of(u, "ablating_mech"), Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "ticker")], [1, 1, 0], "a second round of the same: each a step down")
	assert_eq([u.shield, u.hull], [10, 100], "and no damage taken")
	# Back in reach: the stack left takes its point, and the heat it carried burns.
	sk.start_round()
	assert_eq(Effects.stacks_of(u, "brittled_mech"), 1, "its Brittle a step down again as its turn starts")
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
	Effects.stack(u, TICKER, Effects.SKIRMISH, "buff:test", 2, Effects.DECAY_TURN)
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
	# read, so the round's end reads it like any machine: its kill is read. Nothing else of its
	# is the round's: what a turn's start or end runs down waits for its own next turn.
	assert_false(Skirmish.is_swallowed(ms), "let go as its second round out ends")
	assert_false(ms.killed_round, "and the round's end reads its kill")
	assert_eq(_carried(sk, 0, 1).slice(0, 8), left.slice(0, 8), "every stack and its Barrier as it left: none is the round's to end")
	sk.start_round()
	assert_false(ms.assigned, "back and acting")
	g.target = sk.mechs[1]
	# Its turn starts again: its Armoured and its Barrier go, its Brittle halves, it cools and
	# regenerates, and the dark entry has the two rounds more it had when it was taken.
	assert_eq(_carried(sk, 0, 1), [3, 2, 2, 4, 2, 2, 0, false, 2, 13 + 3, 100, 35 - 2], "as its turn starts")
	sk.end_round()
	assert_eq([Effects.stacks_of(u, "ablating_mech"), Effects.stacks_of(u, "scorched"), Effects.stacks_of(u, "sapped")], [2, 0, 0], "its turn's end, as it would have been: Ablating ticks, Scorched and Sapped go")
	assert_eq([Effects.stacks_of(u, "ticker"), u.shield], [1, 0], "its turn's buff fades one with the turn; the overheat it carried broke its shield")
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [2, 2], "Empowered halves with its turn; its Brittle halved as that turn started")
	assert_eq(u.hull, 100 - 3 * Skirmish.overheat_scale, "the heat it carried burns the turn it is back")
	sk.start_round()
	assert_eq(Effects.dark_rounds(u, 1, sk.round), 1, "the dark entry counts down again")


## Only the swallow's own rounds run: every other timed thing moves a round later for each
## round's end it sits out, and none for the round's end it is let go at.
func test_the_swallows_own_rounds_run_while_every_other_clock_stands() -> void:
	var u := _mech("A", Die.single(Face.attack(1, L)))
	var timed := {"id": "test_timed", "name": "Timed", "description": "", "effects": []}   # a buff for the round, as Essence Flare is
	Effects.grant_for_rounds(u, Effects.STATUS["swallowed"], "test", 2)
	Effects.grant_for_rounds(u, timed, "test", 1)
	Effects.disable_entry(u, 0, "cooldown", 4)
	assert_eq(Effects.dark_rounds(u, 0, 1), 4, "taken in the first round with its entry dark for the rest of it and three more")
	assert_true(Effects.pause_round(u, 1, "swallowed"), "the first round's end: still held")
	assert_true(Effects.has(u, "swallowed") and Effects.has(u, "test_timed"), "the swallow holds, and the buff that was that round's stands")
	assert_eq(Effects.dark_rounds(u, 0, 2), 4, "the dark entry a round later: the round it sat out is not counted")
	assert_false(Effects.pause_round(u, 2, "swallowed"), "the second round's end: its rounds have run")
	assert_false(Effects.has(u, "swallowed"), "the swallow gone on its own clock")
	assert_eq(Effects.dark_rounds(u, 0, 2), 4, "and nothing moved this time: it is back before the round's end is read")
	Effects.end_round(u, 2)
	assert_false(Effects.has(u, "test_timed"), "so that round's end takes the buff, the end it was owed")
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
## a Swallowed carrier: out of play it holds nothing, and it ends with the round its machine is
## back for, every turn's end of that round behind it by then.
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
	assert_eq(Effects.stacks_of(g, "kindled"), 2, "and the foe's as its own turn ended, the holder still out: it is let go as the round ends, after both")
	assert_false(Effects.has(holder, "essence_flare"), "and the buff ends with the round its machine is back for")


# ---------------------------------------------------------------- the four places

## A foe's turn ends as its own action does, landed, lost or skipped, and everything of its that
## ends with its turn runs there, in one order: its Ablating and its Vitriol take their points
## and lose a stack, its Regenerating pays after them and loses one, its Empowered halves, its
## Sapped goes and its Numbed loses a stack. The foe after it has had none of it yet when it acts.
func test_a_foes_turn_ends_as_its_own_action_does_and_its_statuses_run_there() -> void:
	var sk := Skirmish.new(1, 2)
	var u := _mech("A", Die.single(Face.blank()), 0, 500)
	sk.add_mech(u)
	var first := Foe.make("revenant", 400, 9)
	var second := Foe.make("revenant", 400, 5)
	sk.add_foes([first, second])
	sk.begin()
	sk.start_round()
	assert_eq(sk.front, [first, second], "the heavier hitter acts first")
	first.hp = 300
	second.hp = 300
	for f in [first, second]:
		Effects.stack(f, Effects.STATUS["ablating"], Effects.SKIRMISH, "test", 3, Effects.DECAY_TICK)
		Effects.stack(f, Effects.STATUS["regenerating"], Effects.SKIRMISH, "test", 2, Effects.DECAY_TICK)
		_lay(f, "kindled", 4)
		_lay(f, "sapped", 1)
		Effects.stack(f, Effects.STATUS["numbed"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	sk.end_round()
	var burn := 3 * int(Effects.status_value("ablating", "tick_hp"))
	assert_eq(u.hull, 500 - (9 + 4 - 1) - (5 + 4 - 1), "each struck whole: its blow, its four of Empowered, less the Sapped it wore")
	for f in [first, second]:
		assert_eq(f.hp, 300 - burn + 2, "its Ablating took its points once it had struck, then its Regenerating paid")
		assert_eq([Effects.stacks_of(f, "ablating"), Effects.stacks_of(f, "regenerating")], [2, 1], "each a stack down")
		assert_eq(Effects.stacks_of(f, "kindled"), 2, "its Empowered halved")
		assert_false(Effects.has(f, "sapped"), "its Sapped gone with the turn it weakened")
		assert_eq(Effects.stacks_of(f, "numbed"), 1, "and a stack of Numbed with it")


## A foe's own turn's end is its own: when the first foe's turn ends, the second's statuses
## have not moved, so what the first does to the field meets them whole.
func test_a_later_foes_statuses_wait_for_its_own_turns_end() -> void:
	var sk := Skirmish.new(1, 2)
	var u := _mech("A", Die.single(Face.blank()), 0, 20)
	sk.add_mech(u)
	var killer := Foe.make("revenant", 400, 50)
	var after := Foe.make("revenant", 400, 5)
	sk.add_foes([killer, after])
	sk.begin()
	sk.start_round()
	assert_eq(sk.front, [killer, after], "the killer acts first")
	_lay(killer, "kindled", 4)
	_lay(after, "kindled", 4)
	Effects.stack(after, Effects.STATUS["ablating"], Effects.SKIRMISH, "test", 3, Effects.DECAY_TICK)
	assert_eq(sk.end_round(), Skirmish.Outcome.DEFEAT, "the first blow wrecks the last machine")
	assert_eq(Effects.stacks_of(killer, "kindled"), 4, "the fight ended on its blow: nothing ticks after that, its own turn's end included")
	assert_eq([Effects.stacks_of(after, "kindled"), Effects.stacks_of(after, "ablating"), after.hp], [4, 3, 400], "and the foe after it never had its turn")


## A dark entry lights again as its machine's turn ends, a cooldown's and a jam's alike (16
## November: with Jammed, at its turn's end; at the round's end until then, the die unread
## between the two).
func test_a_dark_entry_lights_again_as_its_machines_turn_ends() -> void:
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.of([Face.attack(1, L), Face.attack(1, L), Face.attack(1, L)]))
	sk.add_mech(u)
	sk.add_foes([Foe.make("revenant", 900, 1)])
	sk.begin()
	sk.start_round()
	Effects.disable_entry(u, 0, "cooldown", sk.round)        # dark this turn
	Effects.disable_entry(u, 1, "foe:jam", sk.round + 1)     # a jam a foe laid: through its next turn
	assert_true(Effects.is_entry_disabled(u, 0) and Effects.is_entry_disabled(u, 1), "both dark")
	sk._end_player_turn()
	assert_false(Effects.is_entry_disabled(u, 0), "the first lights as its turn ends")
	assert_true(Effects.is_entry_disabled(u, 1), "the jam has a turn to run")
	sk._enemy_turn()
	sk._finish_round()
	sk.state = Skirmish.State.ROUND_START
	sk.start_round()
	assert_true(Effects.is_entry_disabled(u, 1), "dark through its next turn")
	sk._end_player_turn()
	assert_false(Effects.is_entry_disabled(u, 1), "and lit again as that turn ends")


## A foe's Exposed falls as its turn starts in the round after it landed ("Exposed on next turn
## start"): through the player's turn it was laid in and the next, and gone before the foes act.
func test_a_foes_exposed_falls_as_its_turn_starts_the_round_after() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var g := Foe.make("revenant", 900, 1)
	g.armour = 3
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.grant_for_rounds(g, Effects.STATUS["exposure"], "mech", sk.round)
	assert_eq(g.armour_total(), 0, "Exposed: its armour counts for nothing")
	sk.end_round()
	assert_true(Effects.has(g, "exposure"), "it stands through the foes' turn of the round it landed, and the round's end")
	sk.start_round()
	assert_eq(g.armour_total(), 0, "and through the player's next turn")
	sk._end_player_turn()
	assert_true(Effects.has(g, "exposure"), "END TURN included")
	sk._enemy_turn()
	assert_false(Effects.has(g, "exposure"), "gone as its turn starts")
	assert_eq(g.armour_total(), 3, "its armour back")


## A Suppress is spent with the turn it cost, and Numbed lands as that turn ends (his four
## places: "Its turn End: ... Suppressed, Numbed (applied or reduced)"): the foe has had its
## turn, so the count on its chip is the turns until one stun lands, a stack going as each ends.
func test_a_suppress_is_spent_with_the_turn_it_cost_and_numbed_lands_there() -> void:
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.single(Face.blank()), 0, 500)
	sk.add_mech(u)
	var g := Foe.make("revenant", 900, 7)
	g.resist = 2
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_true(sk._suppress(g), "the stun lands")
	sk.end_round()
	assert_eq(u.hull, 500, "it lost its turn")
	assert_false(g.is_suppressed(), "the Suppress spent with it")
	assert_eq(Effects.stacks_of(g, "numbed"), 2, "and its stun resist landed as Numbed as that turn ended")
	sk.start_round()
	assert_false(sk._suppress(g), "a stun strips a stack and lands nothing")
	assert_eq(Effects.stacks_of(g, "numbed"), 1, "one left")
	sk.end_round()
	assert_eq(u.hull, 493, "it strikes")
	assert_false(Effects.has(g, "numbed"), "and the last stack goes as that turn ends")


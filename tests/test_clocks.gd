extends TestCase

## When what a unit carries ends (Ryan's rulings of 16 November), on synthetic pieces.
## His four places ("I see four places things should decay, tick, or fall off"): its turn's
## start, its turn's end, the round's end, and when it is spent. A machine's turn starts as the
## round opens and ends at END TURN; a foe's starts as the foes' turn opens and ends as its own
## action does. Empowered halves as its turn ends ("Empowered should decay at the end of turn,
## clearly, not end of round"). What a Phased machine carries is its own and acts on it in full,
## as on any machine (19 November: "Phased: Cannot be targeted, damaged, or affected in any way
## by non-phased units"): its ticks, its heat and what its own entry costs it. A Swallowed
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


# ---------------------------------------------------------------- Phased: what it carries is its own

## A machine that pays hull for every component it spends, as a passive's price would be.
const TITHE := {"id": "tithe", "name": "Tithe", "description": "", "effects": [
	{"trigger": "static", "effect": "hull_per_spend", "value": 2}]}


## Everything a Phased machine carries acts on it exactly as on a machine that is not Phased,
## beside it in the same fight with the same statuses, the same heat and the same entry: its
## Ablating takes its points and fades, its Scorched heats its weapon and goes, its Empowered and
## its Brittle halve, its Regenerating pays, its heat burns and overheats it, and its own entry's
## costs land, a Volatile's hull, a passive's hull price and a corrupted entry's bite.
func test_what_a_phased_machine_carries_acts_on_it_as_on_any_machine() -> void:
	var sk := Skirmish.new(1)
	var units: Array[Unit] = []
	for name in ["P", "Q"]:
		var fist := Face.attack(30, L)
		fist.volatile = 10
		var u := _mech(name, Die.single(fist), 10, 100)
		u.shield_max = 20
		u.grant_passive(TITHE)
		sk.add_mech(u)
		units.append(u)
	var g := Foe.make("post", 900, 5)
	g.actions = [{"id": "brace", "name": "Brace", "kind": "defend", "effect": "brace", "value": 1, "weight": 1, "text": ""}]
	g.action = g.actions[0]   # it strikes nobody: what the two machines lose is their own doing
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	var p: Skirmish.MechState = sk.mechs[0]
	var q: Skirmish.MechState = sk.mechs[1]
	Effects.grant_for_rounds(units[0], Effects.STATUS["phased"], "test", sk.round + 1)   # Phased this round and the next
	for u in units:
		_lay(u, "ablating_mech", 3)
		_lay(u, "scorched", 2)
		_lay(u, "sapped", 1)
		_lay(u, "overcharged", 4)
		_lay(u, "brittled_mech", 4)
		Effects.stack(u, Effects.regenerating_mech(), Effects.SKIRMISH, "buff:test", 2, Effects.DECAY_TURN)
		Effects.corrupt_entry(u, 0, "foe:x", 2)
	p.heat = p.heat_max + 5
	q.heat = q.heat_max + 5
	assert_true(Skirmish.is_phased(p) and not Skirmish.is_phased(q), "P is Phased and Q is not")
	# Its own entry's costs: the Volatile's hull and the passive's price, and the corrupted entry's bite.
	var bite := 2 * Skirmish.corrupt_bite()
	assert_eq([sk.pending_volatile(p), sk.pending_bite(p)], [10 + 2, bite], "a Phased machine's spend costs what it says: its Volatile's hull, its passive's price and its corrupted entry's bite")
	assert_eq([sk.pending_volatile(p), sk.pending_bite(p)], [sk.pending_volatile(q), sk.pending_bite(q)], "as the machine beside it pays")
	assert_true(is_equal_approx(Policy.volatile_cost(sk, p, p.face()), Policy.volatile_cost(sk, q, q.face())) and Policy.volatile_cost(sk, p, p.face()) > 0.0, "and the bot counts it on both alike")
	assert_true(sk.assign(0, g) and sk.assign(1, g), "both fire")
	assert_eq([units[0].shield, units[0].hull], [maxi(0, 10 - bite), 100 - 12 - maxi(0, bite - 10)], "the bite off the shield and the hull cost off the hull, Phased or not")
	assert_eq(_carried(sk, 0, 0), _carried(sk, 1, 0), "spent alike, they stand alike")
	assert_true(p.heat > p.heat_max + 5, "its Scorched heated its weapon")
	var before := _carried(sk, 0, 0)
	sk.end_round()
	assert_eq(_carried(sk, 0, 0), _carried(sk, 1, 0), "END TURN reads the two alike")
	assert_eq(Effects.stacks_of(units[0], "ablating_mech"), 2, "its Ablating took its points and a stack faded")
	assert_true(sk.ablations.any(func(a) -> bool: return int(a["mech"]) == 0 and int(a["points"]) == 3), "three points, on record for the replay")
	assert_false(Effects.has(units[0], "scorched") or Effects.has(units[0], "sapped"), "its Scorched and its Sapped go with the turn")
	assert_eq(Effects.stacks_of(units[0], "overcharged"), 2, "its Empowered halves as its turn ends")
	assert_eq(Effects.stacks_of(units[0], "regenerating"), 1, "its Regenerating paid, and a stack faded")
	assert_true(sk.overheats.any(func(o) -> bool: return int(o["mech"]) == 0 and bool(o["first"])), "and its heat burnt it: its overheat, Phased or not")
	assert_true(p.shield_broken and units[0].hull < int(before[10]), "the overheat broke its shield and took hull")
	sk.start_round()
	assert_true(Skirmish.is_phased(p), "Phased still as the next round opens")
	assert_eq(Effects.stacks_of(units[0], "brittled_mech"), 2, "its Brittle halves as its turn starts")
	assert_eq(_carried(sk, 0, 0), _carried(sk, 1, 0), "the round opens on the two alike")
	var hull := units[0].hull
	sk.end_round()
	assert_eq(_carried(sk, 0, 0), _carried(sk, 1, 0), "a second turn of the same")
	assert_eq(hull - units[0].hull, 2 + (p.heat - p.heat_max) * Skirmish.overheat_scale, "its Ablating's two on the bare hull, and every point past its maximum burning again")
	sk.start_round()
	assert_false(Skirmish.is_phased(p), "Phased no longer")
	assert_eq(_carried(sk, 0, 0), _carried(sk, 1, 0), "and nothing was waited out: it stands where the machine beside it stands")


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
	Effects.lay_timer(u, Effects.STATUS["swallowed"], "test", 2)   # out this round and the next
	_lay(u, "ablating_mech", 3)
	_lay(u, "scorched", 2)
	_lay(u, "sapped", 2)
	_lay(u, "overcharged", 4)
	_lay(u, "brittled_mech", 4)
	Effects.stack(u, Effects.regenerating_mech(), Effects.SKIRMISH, "buff:test", 2, Effects.DECAY_TURN)
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
	assert_eq([Effects.stacks_of(u, "regenerating"), u.shield], [1, 0], "its Regenerating fades one with the turn; the overheat it carried broke its shield after")
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "brittled_mech")], [2, 2], "Empowered halves with its turn; its Brittle halved as that turn started")
	assert_eq(u.hull, 100 - 3 * Skirmish.overheat_scale, "the heat it carried burns the turn it is back")
	sk.start_round()
	assert_eq(Effects.dark_rounds(u, 1, sk.round), 1, "the dark entry counts down again")


## A timer renews to the larger count and works at any count (Ryan, 22 November: "make sure it's
## built so that a theoretical exposed 1 or 3 will work as well"); its stacks never scale what it
## does.
func test_a_timer_renews_to_the_larger_count_at_any_count() -> void:
	var g := Foe.make("revenant", 900, 1)
	g.armour = 3
	Effects.lay_timer(g, Effects.STATUS["exposure"], "mech")
	Effects.turn_opens(g, 1)
	assert_eq(Effects.stacks_of(g, "exposure"), 1, "a stack gone as its turn started")
	Effects.lay_timer(g, Effects.STATUS["exposure"], "mech")
	assert_eq(Effects.stacks_of(g, "exposure"), 2, "laid again, it renews to 2, never adds")
	Effects.lay_timer(g, Effects.STATUS["exposure"], "mech", 3)
	assert_eq(Effects.stacks_of(g, "exposure"), 3, "an Exposed 3 renews to the larger count")
	Effects.lay_timer(g, Effects.STATUS["exposure"], "mech", 1)
	assert_eq(Effects.stacks_of(g, "exposure"), 3, "and an Exposed 1 leaves it at 3")
	for i in range(3):
		assert_eq(g.armour_total(), 0, "its armour counts for nothing at %d" % Effects.stacks_of(g, "exposure"))
		Effects.turn_opens(g, 2 + i)
	assert_false(Effects.has(g, "exposure"), "three turn starts on, gone")
	assert_eq(g.armour_total(), 3, "its armour back")
	var u := _mech("A", Die.single(Face.blank()))
	u.base["armour"] = 4
	Effects.lay_timer(u, Effects.STATUS["exposure_mech"], "foe:test", 3)
	assert_eq(Effects.stat(u, "armour"), 0, "a machine's Exposed 3: its armour nothing, the multiply counted once")


## A swallow lands as the round ends (Ryan, 22 November: "Round end, swallow it?"): until then
## the machine is in the fight, hittable by the foes after its swallower, and its wait is its own
## status; the round's end lays Swallowed at the swallow's count, after that round's own count.
func test_a_swallowed_machine_stays_hittable_until_the_round_ends() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.blank()))
	var b := _mech("B", Die.single(Face.blank()))
	sk.add_mech(a)
	sk.add_mech(b)
	var flo := Foe.make("floraison", 900, 20)
	flo.actions = [{"id": "swallow", "name": "Swallow", "kind": "debuff", "effect": "swallow", "value": 2, "weight": 1, "text": ""},
		{"id": "lash", "name": "Lash", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": ""}]
	var rev := Foe.make("revenant", 900, 7)
	sk.add_foes([flo, rev])
	sk.begin()
	sk.start_round()
	assert_eq(sk.front[0], flo, "the swallower acts first")
	flo.action = flo.actions[0]
	flo.target = sk.mechs[0]
	rev.target = sk.mechs[0]
	sk.end_round()
	assert_eq(a.hull, 493, "the foe after the swallower still hits it")
	assert_eq(Effects.stacks_of(a, "swallowing"), 0, "and the wait has landed as the round ended")
	assert_eq(Effects.stacks_of(a, "swallowed"), 2, "Swallowed 2: its count whole, the round it was taken in uncounted")
	assert_eq(sk.swallowed_by(flo), sk.mechs[0], "held by its swallower")
	sk.start_round()
	assert_true(sk.mechs[0].assigned, "out the next round")


## Only the swallow's own rounds run: every other timed thing moves a round later for each
## round's end it sits out, and none for the round's end it is let go at.
func test_the_swallows_own_rounds_run_while_every_other_clock_stands() -> void:
	var u := _mech("A", Die.single(Face.attack(1, L)))
	var timed := {"id": "test_timed", "name": "Timed", "description": "", "effects": []}   # a buff for the round, as Essence Flare is
	Effects.lay_timer(u, Effects.STATUS["swallowed"], "test", 2)
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
	Effects.lay_timer(holder, Effects.STATUS["swallowed"], "test", 2)
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


## The hold is its holder's to land on each unit it holds for, so it holds nothing on a Phased
## unit its holder cannot reach (Ryan, 19 November: "Phased: Cannot be targeted, damaged, or
## affected in any way by non-phased units"): a Phased machine's and a Phased foe's Empowered
## halve as ever under a holder that is not Phased, and are held by a Phased holder as any.
func test_a_hold_on_the_field_passes_a_phased_unit_by_unless_its_holder_is_phased() -> void:
	for faded in [false, true]:
		var sk := Skirmish.new(1)
		var holder := _mech("A", Die.single(Face.blank()))
		var ally := _mech("B", Die.single(Face.blank()))
		var ghost_ally := _mech("C", Die.single(Face.blank()))
		sk.add_mech(holder)
		sk.add_mech(ally)
		sk.add_mech(ghost_ally)
		var g := Foe.make("revenant", 900, 0)
		var ghost := Foe.make("revenant", 900, 0)
		sk.add_foes([g, ghost])
		sk.begin()
		sk.start_round()
		Effects.grant_for_rounds(holder, Effects.STATUS["essence_flare"], "test", sk.round)
		Effects.grant_for_rounds(ghost_ally, Effects.STATUS["phased"], "test", sk.round)
		Effects.grant_for_rounds(ghost, Effects.STATUS["phased"], "test", sk.round)
		if faded:
			Effects.grant_for_rounds(holder, Effects.STATUS["phased"], "test", sk.round)
		assert_eq([sk.field_holds(sk.mechs[1]).has("overcharged"), sk.field_holds(g).has("kindled")], [true, true], "the hold stands for the units its holder reaches")
		assert_eq([sk.field_holds(sk.mechs[2]).has("overcharged"), sk.field_holds(ghost).has("kindled")], [faded, faded], "and for a Phased unit only where its holder is Phased too")
		for u in [ally, ghost_ally]:
			_lay(u, "overcharged", 8)
		for f in [g, ghost]:
			_lay(f, "kindled", 8)
		sk.end_round()
		assert_eq([Effects.stacks_of(ally, "overcharged"), Effects.stacks_of(g, "kindled")], [8, 8], "held whole on both sides, as ever")
		var kept := 8 if faded else 4
		assert_eq([Effects.stacks_of(ghost_ally, "overcharged"), Effects.stacks_of(ghost, "kindled")], [kept, kept], "the Phased machine's and the Phased foe's are held by a Phased holder alone")


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


## A machine's Regenerating pays at END TURN, after its Ablating (Ryan, 16 November, his four
## places: "Its turn End: ... Regeneration"; at the round's opening until then): shield before
## the foes strike, a point a stack, the first as the turn it was gained in ends. A shield the
## Ablating just broke takes none, and the stack fades all the same.
func test_a_machines_regenerating_pays_at_end_turn_after_its_ablating() -> void:
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.single(Face.blank()), 5, 100)
	u.shield_max = 20
	sk.add_mech(u)
	var g := Foe.make("revenant", 900, 4)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	_lay(u, "ablating_mech", 2)
	Effects.stack(u, Effects.regenerating_mech(), Effects.SKIRMISH, "buff:test", 3, Effects.DECAY_TURN)
	var fc := sk.forecast(sk.mechs[0])
	assert_eq([int(fc["shield_after"]), int(fc["hull_after"])], [5 - 2 + 3 - 4, 100], "the forecast reads it: two ablated, three regrown, then the foe's four on the shield")
	sk.end_round()
	assert_eq([u.shield, u.hull], [2, 100], "as it landed")
	assert_eq([Effects.stacks_of(u, "ablating_mech"), Effects.stacks_of(u, "regenerating")], [1, 2], "each a stack down as its turn ended")
	sk.start_round()
	assert_eq(u.shield, 2, "the round's opening pays nothing")
	# A shield the tick breaks takes none.
	var s2 := Skirmish.new(1)
	var b := _mech("B", Die.single(Face.blank()), 2, 100)
	b.shield_max = 20
	s2.add_mech(b)
	s2.add_foes([Foe.make("revenant", 900, 0)])
	s2.begin()
	s2.start_round()
	_lay(b, "ablating_mech", 3)
	Effects.stack(b, Effects.regenerating_mech(), Effects.SKIRMISH, "buff:test", 3, Effects.DECAY_TURN)
	var f2 := s2.forecast(s2.mechs[0])
	s2.end_round()
	assert_eq([b.shield, b.hull], [0, 99], "the Ablating broke the shield and took a point of hull; a broken shield gains none")
	assert_eq([int(f2["shield_after"]), int(f2["hull_after"])], [0, 99], "and the forecast said so")
	assert_eq(Effects.stacks_of(b, "regenerating"), 2, "the stack faded all the same")


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


## A foe's Exposed is a timer (Ryan, 22 November): Exposed 2, a stack going as each of its turns
## starts, so it stands through the player's turn it was laid in and the next, and is gone before
## the foes act that round.
func test_a_foes_exposed_2_loses_a_stack_as_each_of_its_turns_starts() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var g := Foe.make("revenant", 900, 1)
	g.armour = 3
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.lay_timer(g, Effects.STATUS["exposure"], "mech")
	assert_eq(Effects.stacks_of(g, "exposure"), 2, "Exposed 2, its own count")
	assert_eq(g.armour_total(), 0, "Exposed: its armour counts for nothing")
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "exposure"), 1, "a stack gone as its turn started: it stands through the foes' turn of the round it landed, and the round's end")
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


extends TestCase

## The Mole's engines (Ryan's kit of 16 November), on a synthetic passive and pieces: the burrow
## in a reboot's place, on a turn it has spent nothing ("only on a nothing spend"), its shield never
## emptied and its overheat vented; Burrowed, an ability no Purge touches, its armour, its die
## rolling the drill alone, and each turn under clearing Broken and Overheated and making good half
## of what its shield and heat were missing as it burrowed; Conserved Momentum, a stack as it burrows
## and one a turn under, up to its cap; the drill, which spends it whole for as many stacks of
## Applied Momentum on its foe and brings the machine up, its drill out; the drill's blow as the
## foes' turn starts, a plain blow its foe's Brittle adds to and its armour and Barrier take, a stack
## going each; a burrow taking the drill back with what is left; a Ward turning the drill away and a
## cleanse taking it; and the branches' tweaks of the drill's turn (Ablating in the blow's place, a
## Brittle and a pin that holds it).

const DRILL := "drill_test"
const BURROW := {"trigger": "static", "effect": "burrow", "piece": DRILL, "cap": 3, "armour": 1, "recover": 50, "blow": 2}


func _drill() -> Face:
	var d := Face.attack(0, Face.Reach.INDIRECT)
	d.component = DRILL
	d.fixed = true
	return d


func _gun() -> Face:
	var g := Face.attack(1, Face.Reach.DIRECT)
	g.component = "gun_test"
	return g


## A burrower: the drill fixed first, three guns after it, and any branch steps on the drill.
func _mole(shield: int = 8, steps: Array = []) -> Unit:
	var u := Unit.mech(0, "Mole", Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = 100
	u.hull_max = 100
	u.die = Die.of([_drill(), _gun(), _gun(), _gun()])
	u.grant_passive({"id": "test_burrow", "name": "Test Burrow", "description": "", "effects": [BURROW]})
	if not steps.is_empty():
		u.grant_passive({"id": "test_branch", "name": "Test Branch", "description": "", "effects": steps})
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


## Burrow now, then `turns` rounds under: its die shows the drill each time.
func _dig(sk: Skirmish, turns: int) -> void:
	sk.reboot_mech(0)
	for i in range(turns):
		sk.end_round()
		sk.start_round()


func test_a_burrower_burrows_in_its_reboots_place_and_its_die_rolls_the_drill_alone() -> void:
	var u := _mole()
	var sk := _fight([u], [_dummy()])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(Effects.live_entries(u, ms.die), [1, 2, 3], "above ground its die rolls everything but the drill")
	assert_true(ms.die.faces[ms.face_index].component != DRILL, "so the drill never shows above ground")
	u.shield = 3
	assert_true(sk.can_reboot(0), "a machine that has spent nothing may burrow")
	assert_true(sk.reboot_mech(0), "it burrows where another machine reboots")
	assert_true(Effects.has(u, "burrowed"), "burrowed")
	assert_eq(Effects.status_kind("burrowed"), "ability", "an ability, the unpurgeable buff his rule of 8 November labels so")
	assert_eq(u.shield, 3, "its shield is never emptied")
	assert_false(ms.rebooting, "a burrow is no reboot: nothing comes back whole as the next round opens")
	assert_eq(Effects.stacks_of(u, "conserved_momentum"), 1, "a stack of Conserved Momentum as it burrows")
	assert_eq(Effects.stat(u, "armour"), 1, "Burrowed's armour")
	assert_false(sk.can_reboot(0), "under, it has nothing to burrow into")
	assert_eq(Effects.live_entries(u, ms.die), [0], "under, its die rolls the drill alone")
	sk.end_round()
	sk.start_round()
	assert_eq(ms.die.faces[ms.face_index].component, DRILL, "the next round its die shows the drill")
	assert_false(sk.can_reboot(0), "and it still cannot burrow again")


func test_a_burrow_waits_for_a_turn_with_nothing_spent() -> void:
	var u := _mole()
	var foe := _dummy()
	var sk := _fight([u], [foe])
	assert_true(sk.assign(0, foe), "a gun spent")
	assert_false(sk.can_reboot(0), "only on a nothing spend")
	assert_false(sk.reboot_mech(0), "so no burrow")
	assert_false(Effects.has(u, "burrowed"), "and it stays up")


func test_a_turn_under_makes_good_half_of_what_was_missing_as_it_burrowed() -> void:
	var u := _mole(10)
	var sk := _fight([u], [_dummy()])
	var ms: Skirmish.MechState = sk.mechs[0]
	u.shield = 4
	ms.heat = 8
	_dig(sk, 1)
	assert_eq(u.shield, 7, "half of the 6 missing back on the first turn under")
	assert_eq(ms.heat, 4, "half of the 8 it carried off")
	assert_eq(Effects.stacks_of(u, "conserved_momentum"), 2, "and a stack more")
	sk.end_round()
	sk.start_round()
	assert_eq(u.shield, 10, "two turns under is whole")
	assert_eq(ms.heat, 0, "and cold")
	assert_eq(Effects.stacks_of(u, "conserved_momentum"), 3, "three stacks, the cap")
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(u, "conserved_momentum"), 3, "the cap holds")
	assert_eq(u.shield, 10, "nothing past whole")


func test_a_blow_taken_under_is_not_mended_and_a_broken_shield_comes_back() -> void:
	var u := _mole(10)
	var sk := _fight([u], [_dummy()])
	var ms: Skirmish.MechState = sk.mechs[0]
	u.shield = 6
	sk.reboot_mech(0)
	u.shield = 0   # a blow under takes the shield to nothing: broken
	ms.shield_broken = true
	sk.end_round()
	sk.start_round()
	assert_false(ms.shield_broken, "a turn under clears Broken, as a reboot's recovery does")
	assert_eq(u.shield, 2, "and makes good half of the 4 missing as it burrowed, the blow under not mended")


func test_the_burrow_vents_what_stands_past_the_maximum_so_nothing_burns() -> void:
	var u := _mole()
	var sk := _fight([u], [_dummy()])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = ms.heat_max + 5
	ms.overheated = true
	sk.reboot_mech(0)
	assert_eq(ms.heat, ms.heat_max, "the overheat vents at once, as a reboot's does")
	assert_false(ms.overheated, "and it is free to overheat again")
	var hull := u.hull
	sk.end_round()
	assert_eq(u.hull, hull, "nothing burns at its END TURN")


func test_the_drill_spends_every_stack_for_applied_momentum_and_brings_it_up() -> void:
	var u := _mole()
	var foe := _dummy()
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	_dig(sk, 2)
	assert_eq(Effects.stacks_of(u, "conserved_momentum"), 3, "three stacks under")
	assert_true(sk.assign(0, foe), "the drill spent at the foe")
	assert_eq(Effects.stacks_of(foe, "applied_momentum"), 3, "as many stacks of Applied Momentum on it")
	assert_false(Effects.has(u, "conserved_momentum"), "every Conserved stack spent")
	assert_false(Effects.has(u, "burrowed"), "the machine comes up")
	assert_true(Effects.has(u, "drill_out"), "its drill out")
	assert_eq(Effects.live_entries(u, ms.die), [1, 2, 3], "its die rolls its guns again")


func test_the_drill_strikes_its_foe_as_the_foes_turn_starts_a_stack_going_each() -> void:
	var u := _mole()
	var foe := _dummy(100, 1)
	var sk := _fight([u], [foe])
	_dig(sk, 1)
	sk.assign(0, foe)
	assert_eq(Effects.stacks_of(foe, "applied_momentum"), 2, "two stacks")
	sk.end_round()
	assert_eq(foe.hp, 99, "a plain blow of 2, its armour taking 1")
	assert_eq(Effects.stacks_of(foe, "applied_momentum"), 1, "a stack gone")
	sk.start_round()
	sk.end_round()
	assert_eq(foe.hp, 98, "the second turn's blow")
	assert_false(Effects.has(foe, "applied_momentum"), "and the drill's work done")


func test_the_drills_blow_reads_brittle_and_a_barrier_takes_it() -> void:
	var u := _mole()
	var foe := _dummy()
	var sk := _fight([u], [foe])
	_dig(sk, 1)
	sk.assign(0, foe)
	Effects.stack(foe, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_HALF)
	sk.end_round()
	assert_eq(foe.hp, 95, "its Brittle adds to the blow: 2 and 3")
	sk.start_round()
	Effects.stack(foe, Effects.STATUS["barrier"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_ROUND)
	var hp := foe.hp
	sk.end_round()
	assert_eq(foe.hp, hp, "a Barrier takes the blow whole")


func test_a_burrow_takes_the_drill_back_with_what_is_left() -> void:
	var u := _mole()
	var foe := _dummy()
	var sk := _fight([u], [foe])
	_dig(sk, 2)
	sk.assign(0, foe)
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(foe, "applied_momentum"), 2, "two stacks left in the foe")
	sk.reboot_mech(0)
	assert_false(Effects.has(foe, "applied_momentum"), "the drill comes home, taking the debuff with it")
	assert_false(Effects.has(u, "drill_out"), "its bore full again")
	assert_eq(Effects.stacks_of(u, "conserved_momentum"), 3, "what was left back as Conserved, with the burrow's own stack, up to the cap")


func test_a_ward_turns_the_drill_away_and_a_cleanse_takes_it() -> void:
	var u := _mole()
	var warded := _dummy()
	var sk := _fight([u], [warded])
	_dig(sk, 1)
	Effects.stack(warded, Effects.STATUS["ward"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_ROUND)
	sk.assign(0, warded)
	assert_false(Effects.has(warded, "applied_momentum"), "a Ward turns the drill's mark away")
	assert_false(Effects.has(u, "conserved_momentum"), "the stacks spent all the same")
	var foe := _dummy()
	Effects.stack(foe, Effects.STATUS["applied_momentum"], Effects.SKIRMISH, "drill:0", 2, Effects.DECAY_NONE)
	assert_true(Effects.clear_marks(foe).has("Applied Momentum"), "a foe's cleanse takes it, a mark the team laid")


func test_no_purge_takes_burrowed_or_conserved_momentum() -> void:
	var u := _mole()
	var sk := _fight([u], [_dummy()])
	_dig(sk, 1)
	Effects.purge(u, 5)
	assert_true(Effects.has(u, "burrowed"), "Burrowed stands: an ability")
	assert_eq(Effects.stacks_of(u, "conserved_momentum"), 2, "Conserved Momentum stands: a store")


func test_the_ablate_step_lays_ablating_in_the_blows_place_and_seared_holds_it() -> void:
	var step := {"trigger": "static", "effect": "momentum", "entry": DRILL, "blow": 0, "lays": {"ablating": 2, "seared": 1}}
	var u := _mole(8, [step])
	var foe := _dummy()
	var sk := _fight([u], [foe])
	_dig(sk, 1)
	sk.assign(0, foe)
	sk.end_round()
	assert_eq(foe.hp, 98, "no blow, and the Ablating 2 it laid burns 2 as the foe's turn ends")
	assert_eq(Effects.stacks_of(foe, "ablating"), 2, "Seared held the stack the turn's end would take")


func test_the_squad_step_lays_brittle_and_a_pin_that_holds_it_while_the_drill_is_in() -> void:
	var step := {"trigger": "static", "effect": "momentum", "entry": DRILL, "lays": {"brittled": 1, "pinned": 1}}
	var u := _mole(8, [step])
	var foe := _dummy(200)
	var sk := _fight([u], [foe])
	_dig(sk, 2)
	sk.assign(0, foe)
	for i in range(3):
		sk.end_round()
		sk.start_round()
	assert_eq(foe.hp, 191, "2, then 3 and 4 as the Brittle each turn laid stands pinned: 9")
	assert_false(Effects.has(foe, "applied_momentum"), "three turns for three stacks")


func test_a_burrow_undoes_like_a_spend() -> void:
	var u := _mole()
	var sk := _fight([u], [_dummy()])
	sk.keeps_undo = true
	sk.reboot_mech(0)
	assert_true(sk.can_undo(), "the burrow can be taken back")
	sk.undo()
	assert_false(Effects.has(sk.mechs[0].unit, "burrowed"), "and is: up again")

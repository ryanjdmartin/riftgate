extends TestCase

## The Mole's engines (Ryan's kit of 24 November), on a synthetic passive and pieces:
## - the burrow in a reboot's place, on a turn it has spent nothing, banking nothing but armoured
##   from that turn ("Burrow does not bank. But it does gain the 1 Armour");
## - each turn under clearing Broken and Overheated and opening with a flat shield, cooling and
##   Momentum ("50% of the final numbers, but represented as flat numbers"), Momentum a resource up
##   to its cap;
## - the drill a weapon, ignoring armour, Ward and Barrier, Rapid, its Resolve laying the drill's
##   mark and bringing the machine up, no Momentum spent;
## - the mark's turn: Brittle and the Pinned that holds it, then a plain blow, then a drain of its
##   machine's Momentum, gone at none and the drill home;
## - every use that hits a drilled foe giving its machine a Momentum, area hits included and the
##   drill's own use none;
## - a burrow taking the drill home, its Momentum where it ended up;
## - the branches: Frozen Momentum with Frozen, which keeps a Cryo through its cash, and Heated
##   Momentum; and immunity to a named status.
## The statuses are the engine's; the passive and its numbers are the test's.

const DRILL := "drill_test"
const BURROW := {"trigger": "static", "effect": "burrow", "piece": DRILL}
const K := Face.Keyword


func _drill() -> Face:
	var d := Face.attack(2, Face.Reach.INDIRECT, [K.RAPID])
	d.component = DRILL
	d.fixed = true
	d.ignores_armour = true
	d.ignores_ward = true
	d.ignores_barrier = true
	return d


func _gun(power: int = 1, keys: Array = []) -> Face:
	var g := Face.attack(power, Face.Reach.DIRECT, keys)
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


## A machine of guns alone: a plain gun first, then a Spread gun.
func _gunner() -> Unit:
	var u := Unit.mech(1, "Gunner", Vector2i.ZERO)
	u.shield = 10
	u.shield_max = 10
	u.hull = 100
	u.hull_max = 100
	var spread := _gun(1, [K.CLEAVE])
	spread.cleave = 1
	u.die = Die.of([_gun(), spread])
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


func test_a_burrow_banks_nothing_but_armours_it_at_once_and_its_die_rolls_the_drill_alone() -> void:
	var u := _mole()
	var sk := _fight([u], [_dummy()])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(Effects.live_entries(u, ms.die), [1, 2, 3], "above ground its die rolls everything but the drill")
	u.shield = 3
	assert_true(sk.can_reboot(0), "a machine that has spent nothing may burrow")
	assert_true(sk.reboot_mech(0), "it burrows where another machine reboots")
	assert_true(Effects.has(u, "burrowed"), "burrowed")
	assert_eq(Effects.status_kind("burrowed"), "ability", "an ability, the unpurgeable buff his rule of 8 November labels so")
	assert_eq(u.shield, 3, "its shield is never emptied")
	assert_false(ms.rebooting, "a burrow is no reboot: nothing comes back whole as the next round opens")
	assert_eq(Effects.stacks_of(u, "momentum"), 0, "the burrow banks no Momentum")
	assert_eq(Effects.stat(u, "armour"), 1, "but Burrowed's armour holds from the burrow's own turn")
	assert_eq(Effects.live_entries(u, ms.die), [0], "under, its die rolls the drill alone")
	assert_false(sk.can_reboot(0), "under, it has nothing to burrow into")
	sk.end_round()
	sk.start_round()
	assert_eq(ms.die.faces[ms.face_index].component, DRILL, "the next round its die shows the drill")
	assert_eq(Effects.stacks_of(u, "momentum"), 5, "and the turn under brought its Momentum")


func test_a_burrow_waits_for_a_turn_with_nothing_spent() -> void:
	var u := _mole()
	var foe := _dummy()
	var sk := _fight([u], [foe])
	assert_true(sk.assign(0, foe), "a gun spent")
	assert_false(sk.can_reboot(0), "only on a nothing spend")
	assert_false(sk.reboot_mech(0), "so no burrow")
	assert_false(Effects.has(u, "burrowed"), "and it stays up")


func test_a_turn_under_opens_with_flat_shield_cooling_and_momentum_to_the_cap() -> void:
	var u := _mole(10)
	var sk := _fight([u], [_dummy()])
	var ms: Skirmish.MechState = sk.mechs[0]
	u.shield = 4
	ms.heat = 8
	_dig(sk, 1)
	assert_eq(u.shield, 7, "the rule's 3 shield back on the first turn under")
	assert_eq(ms.heat, 2, "its 6 cooling off the 8")
	assert_eq(Effects.stacks_of(u, "momentum"), 5, "its 5 Momentum")
	sk.end_round()
	sk.start_round()
	assert_eq(u.shield, 10, "3 more, whole")
	assert_eq(ms.heat, 0, "and cold, never below nothing")
	assert_eq(Effects.stacks_of(u, "momentum"), 10, "Momentum at its cap")
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(u, "momentum"), 10, "the cap holds")
	assert_eq(u.shield, 10, "nothing past whole")


func test_a_blow_taken_under_is_mended_by_the_turns_shield_and_a_broken_shield_comes_back() -> void:
	var u := _mole(10)
	var sk := _fight([u], [_dummy()])
	var ms: Skirmish.MechState = sk.mechs[0]
	sk.reboot_mech(0)
	u.shield = 0   # a blow under takes the shield to nothing: broken
	ms.shield_broken = true
	sk.end_round()
	sk.start_round()
	assert_false(ms.shield_broken, "a turn under clears Broken, as a reboot's recovery does")
	assert_eq(u.shield, 3, "and its 3 shield comes back whatever took it")


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


func test_the_drill_hits_through_armour_lays_its_mark_and_brings_it_up_rapid_and_spends_nothing() -> void:
	var u := _mole()
	var foe := _dummy(100, 2)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	_dig(sk, 2)
	assert_eq(Effects.stacks_of(u, "momentum"), 10, "ten Momentum under")
	assert_true(sk.assign(0, foe), "the drill fired at the foe")
	assert_eq(foe.hp, 98, "its 2, the foe's armour taking nothing")
	assert_true(Effects.has(foe, "applied_momentum"), "its Resolve lays Applied Momentum")
	assert_eq(Effects.stacks_of(foe, "applied_momentum"), 1, "a mark that never stacks")
	assert_eq(Effects.stacks_of(u, "momentum"), 10, "no Momentum spent by the firing, nor any gained by its own use")
	assert_false(Effects.has(u, "burrowed"), "the machine comes up")
	assert_true(Effects.has(u, "drill_out"), "its drill out")
	assert_false(ms.assigned, "Rapid: it acts again")
	assert_true(ms.die.faces[ms.face_index].component != DRILL, "its die rolled among its guns")
	assert_eq(Effects.live_entries(u, ms.die), [1, 2, 3], "which are all it rolls above ground")


func test_the_mark_lays_brittle_and_a_pin_then_a_blow_then_drains_and_goes_home_at_none() -> void:
	var u := _mole()
	var foe := _dummy(100)
	var sk := _fight([u], [foe])
	_dig(sk, 2)
	sk.assign(0, foe)
	var hp := foe.hp
	sk.end_round()
	assert_eq(foe.hp, hp - 2, "Brittle 1 first, then the blow of 1 it adds to")
	assert_eq(Effects.stacks_of(foe, "brittled"), 1, "the Pinned it laid held the Brittle through the turn's halving")
	assert_eq(Effects.stacks_of(u, "momentum"), 5, "5 drained")
	assert_true(Effects.has(foe, "applied_momentum"), "the drill still in")
	sk.start_round()
	sk.end_round()
	assert_eq(foe.hp, hp - 5, "the second turn: Brittle 2, a blow of 3")
	assert_eq(Effects.stacks_of(u, "momentum"), 0, "drained to none")
	assert_false(Effects.has(foe, "applied_momentum"), "so the mark goes")
	assert_false(Effects.has(u, "drill_out"), "and the drill comes home")


func test_a_use_that_hits_the_drilled_foe_gives_the_mole_a_momentum_area_hits_included() -> void:
	var u := _mole()
	var g := _gunner()
	var a := _dummy(200)
	var b := _dummy(200)
	var sk := _fight([u, g], [a, b])
	var gun: Skirmish.MechState = sk.mechs[1]
	_dig(sk, 1)
	assert_eq(Effects.stacks_of(u, "momentum"), 5, "five under")
	sk.assign(0, a)
	assert_eq(Effects.stacks_of(u, "momentum"), 5, "the drill's own use gives nothing")
	gun.face_index = 0
	assert_true(sk.assign(1, a), "a gun at the drilled foe")
	assert_eq(Effects.stacks_of(u, "momentum"), 6, "a Momentum for the use")
	sk.end_round()
	assert_eq(Effects.stacks_of(u, "momentum"), 1, "the drill drained 5 as its foe's turn started")
	sk.start_round()
	gun.face_index = 1
	assert_true(sk.assign(1, b), "a Spread gun at the foe beside it")
	assert_eq(Effects.stacks_of(u, "momentum"), 2, "its Spread's hit on the drilled foe gives one too")


func test_the_momentum_a_hit_gives_stops_at_the_cap() -> void:
	var u := _mole()
	var g := _gunner()
	var a := _dummy(200)
	var sk := _fight([u, g], [a])
	var gun: Skirmish.MechState = sk.mechs[1]
	_dig(sk, 2)
	sk.assign(0, a)
	gun.face_index = 0
	sk.assign(1, a)
	assert_eq(Effects.stacks_of(u, "momentum"), 10, "at its cap a hit gives none")


func test_a_burrow_takes_the_drill_home_and_leaves_its_momentum_where_it_ended() -> void:
	var u := _mole()
	var foe := _dummy()
	var sk := _fight([u], [foe])
	_dig(sk, 2)
	sk.assign(0, foe)
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(u, "momentum"), 5, "one turn drained")
	sk.reboot_mech(0)
	assert_false(Effects.has(foe, "applied_momentum"), "the drill comes home, taking the mark with it")
	assert_false(Effects.has(u, "drill_out"), "its bore full again")
	assert_eq(Effects.stacks_of(u, "momentum"), 5, "its Momentum where it ended up, the burrow banking none")


func test_the_drill_passes_a_ward_and_a_barrier_and_a_cleanse_takes_its_mark() -> void:
	var u := _mole()
	var foe := _dummy()
	var sk := _fight([u], [foe])
	_dig(sk, 1)
	Effects.stack(foe, Effects.STATUS["ward"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_ROUND)
	Effects.stack(foe, Effects.STATUS["barrier"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_ROUND)
	sk.assign(0, foe)
	assert_eq(foe.hp, 98, "its 2 land through the Barrier")
	assert_true(Effects.has(foe, "barrier"), "which takes nothing and stands")
	assert_true(Effects.has(foe, "applied_momentum"), "its mark lands through the Ward")
	assert_true(Effects.clear_marks(foe).has("Applied Momentum"), "a foe's cleanse takes it, a mark the team laid")


func test_no_purge_takes_burrowed_or_momentum() -> void:
	var u := _mole()
	var sk := _fight([u], [_dummy()])
	_dig(sk, 1)
	Effects.purge(u, 5)
	assert_true(Effects.has(u, "burrowed"), "Burrowed stands: an ability")
	assert_eq(Effects.stacks_of(u, "momentum"), 5, "Momentum stands: a store")


func test_a_named_immunity_keeps_that_status_off_its_machine() -> void:
	var u := _mole(8, [{"trigger": "static", "effect": "immune", "value": "brittled"}])
	_fight([u], [_dummy()])
	assert_true(Effects.stack(u, Effects.STATUS["brittled_mech"], Effects.SKIRMISH, "foe", 2, Effects.DECAY_HALF) == null, "a foe's Brittle lands on nothing")
	assert_false(Effects.has(u, "brittled_mech"), "so it carries none")
	assert_true(Effects.stack(u, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_TURN) != null, "a status it is not immune to lands")


func test_frozen_momentum_lays_brittle_cryo_a_pin_and_frozen_which_keeps_the_cryo_through_its_cash() -> void:
	var steps := [{"trigger": "static", "effect": "momentum", "entry": DRILL, "status": "frozen_momentum"}]
	var u := _mole(8, steps)
	var g := _gunner()
	var foe := _dummy(200)
	var sk := _fight([u, g], [foe])
	var gun: Skirmish.MechState = sk.mechs[1]
	_dig(sk, 2)
	sk.assign(0, foe)
	assert_true(Effects.has(foe, "frozen_momentum"), "the branch's form in Applied Momentum's place")
	assert_false(Effects.has(foe, "applied_momentum"), "and not Applied Momentum")
	var hp := foe.hp
	sk.end_round()
	assert_eq(foe.hp, hp - 3, "Brittle 2 first, then the blow of 1 it adds to")
	assert_eq(Effects.stacks_of(foe, "cryoed"), 1, "Cryo 1")
	assert_true(Effects.has(foe, "frozen"), "and Frozen")
	sk.start_round()
	Effects.stack(foe, Effects.STATUS["numbed"], Effects.SKIRMISH, "foe", 2, Effects.DECAY_TURN)
	gun.heat = 6
	gun.face_index = 0
	assert_true(sk.assign(1, foe), "a weapon's hit would cash the Cryo")
	assert_eq(gun.heat, 6 - Skirmish.cryo_cool(), "the hitter cooled as ever")
	assert_eq(Effects.stacks_of(foe, "cryoed"), 1, "the Cryo kept")
	assert_eq(Effects.stacks_of(foe, "numbed"), 1, "a Numbed spent in its place")
	assert_false(Effects.has(foe, "frozen"), "and Frozen gone")


func test_frozen_keeps_the_cryo_with_no_numbed_to_spend() -> void:
	var u := _mole()
	var g := _gunner()
	var foe := _dummy(200)
	var sk := _fight([u, g], [foe])
	var gun: Skirmish.MechState = sk.mechs[1]
	Effects.stack(foe, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	Effects.stack(foe, Effects.STATUS["frozen"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	gun.face_index = 0
	sk.assign(1, foe)
	assert_eq(Effects.stacks_of(foe, "cryoed"), 2, "preserved, Numbed or none")
	assert_false(Effects.has(foe, "frozen"), "Frozen spent")


func test_heated_momentum_lays_ablate_and_seared_in_the_blows_place() -> void:
	var steps := [{"trigger": "static", "effect": "momentum", "entry": DRILL, "status": "heated_momentum"}]
	var u := _mole(8, steps)
	var foe := _dummy(200)
	var sk := _fight([u], [foe])
	_dig(sk, 2)
	sk.assign(0, foe)
	assert_true(Effects.has(foe, "heated_momentum"), "the branch's form")
	var hp := foe.hp
	sk.end_round()
	assert_eq(foe.hp, hp - 2, "no blow; the Ablate 2 it laid burns 2 as the foe's turn ends")
	assert_eq(Effects.stacks_of(foe, "ablating"), 2, "Seared held the stack the turn's end would take")
	assert_eq(Effects.stacks_of(foe, "brittled"), 1, "Brittle 1, pinned")
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(foe, "ablating"), 4, "a second turn's Ablate 2 on the held 2")


func test_a_burrow_undoes_like_a_spend() -> void:
	var u := _mole()
	var sk := _fight([u], [_dummy()])
	sk.keeps_undo = true
	sk.reboot_mech(0)
	assert_true(sk.can_undo(), "the burrow can be taken back")
	sk.undo()
	assert_false(Effects.has(sk.mechs[0].unit, "burrowed"), "and is: up again")


## Burrowed's numbers are its own and Momentum's cap is Momentum's (Ryan, 24 November: "Move the
## effects on the mole's passive to the status chip"): a burrow passive carries its piece alone (the
## burrower above has nothing else, and its turns under are the tests above), and each tip says the
## number its status holds.
func test_the_burrows_numbers_are_the_statuses_own() -> void:
	var u := _mole(20)
	assert_eq(Effects.store_cap(u, "momentum"), int(Effects.STATUS["momentum"]["cap"]), "Momentum's cap is its own")
	assert_eq(Effects.store_cap(_gunner(), "momentum"), 0, "and a machine that reboots banks none")
	var db := ContentDB.load_default()
	var tip := str(db.vocabulary["burrowed"]["codex"])
	for said in ["+%d Armour" % Effects.status_value_static("burrowed", "add_stat"), "%d Shield" % Effects.burrowed_number("shield"), "%d Momentum" % Effects.burrowed_number("momentum"), "%d Heat" % Effects.burrowed_number("cool")]:
		assert_true(tip.contains(said), "Burrowed's tip says %s: %s" % [said, tip])
	assert_true(str(db.vocabulary["momentum"]["codex"]).contains("Maximum %d" % int(Effects.STATUS["momentum"]["cap"])), "and Momentum's says its cap")

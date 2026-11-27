extends TestCase

## Volatile Gas (the Cottonmouth's Volatile Gas Canister; Ryan, 27 November: "Round End: Transform
## into another random debuff"), on synthetic pieces: a hit laying it, a stack a hit; as the round
## ends, after its other effects, each stack turning into one stack of a debuff the team lays, drawn
## from those the Sprite may become now, each as likely, and the gas gone; never a debuff it carries
## that does not stack, nor one it is immune to (his: "if a non stacked debuff exists on a unit
## already (like shock), don't choose that one. Otherwise, everything is fair game and stacks"); a
## conditional one only while its condition holds (his: "pinned if the sprite hit has Brittle, sonic
## needle if the echidna is in the fight and functional, etc. Paradox if the baboon is present and
## functional"); a Ward turning away what it becomes; a Suppress its next turn lost; a needle its
## machine's, the bolt at its count; a Paradox its meter's; and the round's preview drawing nothing.
## The status is the engine's; the pieces, the passives and their numbers are the test's.

const I := Face.Reach.INDIRECT
const K := Face.Keyword
const GAS := "gassed"
## What a stack may become on a plain Sprite with no Echidna and no Baboon in the fight: every
## debuff the gas names but the pins (nothing to hold), the needle and the Paradox (no machine).
const PLAIN := ["ablating", "brittled", "cryoed", "exposure", "sapped", "shocked", "suppressed", "vitriol"]
const NEEDLES := {"id": "test_needles", "name": "Test Needles", "description": "", "effects": [
	{"trigger": "static", "effect": "needles", "status": "sonic_needle", "at": 3, "chain": 2}]}
const METER := {"id": "test_meter", "name": "Test Meter", "description": "", "effects": [
	{"trigger": "on_foe_status", "effect": "paradox", "value": 3}]}
## A drum's rewrite (the shape a passive may force on every weapon and equipment aimed at a foe),
## its spray at the front rank.
const DRUM := {"id": "test_drum", "name": "Test Drum", "description": "", "effects": [
	{"trigger": "static", "effect": "rewrite_weapon", "value": 4, "reach": "indirect", "heat": 6, "tag": "ballistic"},
	{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "target_rank", "rank": "front", "number": 2}]}


func _canister(n: int = 1) -> Face:
	var f := Face.attack(0, I, [K.VOLATILE_GAS])
	f.volatile_gas = n
	return f


func _mech(d: Die, passive: Dictionary = {}) -> Unit:
	var u := Unit.mech(0, "Cottonmouth", Vector2i.ZERO)
	u.shield = 10
	u.shield_max = 10
	u.hull = 100
	u.hull_max = 100
	u.die = d
	if not passive.is_empty():
		u.grant_passive(passive)
	return u


func _foe(hp: int = 30) -> Foe:
	return Foe.make("revenant", hp, 0)


func _fight(units: Array, foes: Array, seed_value: int = 1) -> Skirmish:
	var sk := Skirmish.new(seed_value, 4)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


## A status laid as the engine lays it: the Paradox and the gas on no clock (_foe_gained_status, a
## rider), the rest on their own.
func _lay(foe: Foe, id: String, n: int = 1) -> void:
	var decay := Effects.DECAY_NONE if id == "paradox" else Effects.status_decay(Effects.STATUS[id])
	Effects.stack(foe, Effects.STATUS[id], Effects.SKIRMISH, "mech", n, decay)


## Every status a unit carries, by id, with its stacks.
func _carried(u) -> Dictionary:
	var out := {}
	for m in Effects.live(u):
		out[m.id] = int(out.get(m.id, 0)) + int(m.stacks)
	return out


## How many draws a Sprite's statuses come to: a stack of a stacking debuff each, and a debuff that
## does not stack, a timer or the stun once.
func _draws(foe: Foe) -> int:
	var n := 0
	var have := _carried(foe)
	for sid in have.keys():
		var def: Dictionary = Effects.STATUS.get(sid, {})
		var once: bool = sid == "suppressed" or Effects.is_timer(sid) or str(def.get("stacking", "")) == "renew"
		n += 1 if once else int(have[sid])
	return n


func test_a_hit_lays_volatile_gas_a_stack_a_hit() -> void:
	var twin := _canister(1)
	twin.strikes = 2
	var u := _mech(Die.of([_canister(1), twin, _canister(2)]))
	var a := _foe()
	var b := _foe()
	var c := _foe()
	var sk := _fight([u], [a, b, c])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, a), "the canister at the first Sprite")
	assert_eq(Effects.stacks_of(a, GAS), 1, "a stack of gas on the Sprite hit")
	ms.assigned = false
	ms.face_index = 1
	assert_true(sk.assign(0, b), "two strikes at the second")
	assert_eq(Effects.stacks_of(b, GAS), 2, "a stack a strike")
	ms.assigned = false
	ms.face_index = 2
	assert_true(sk.assign(0, c), "Volatile Gas 2 at the third")
	assert_eq(Effects.stacks_of(c, GAS), 2, "the keyword's number a hit")
	assert_eq([a.hp, b.hp, c.hp], [30, 30, 30], "the gas deals nothing")
	assert_true(Face.KEYWORD_STATUS[K.VOLATILE_GAS] == GAS and Effects.FOE_STATUSES.has(GAS) and Effects.TEAM_MARKS.has(GAS), "a team mark on a Sprite: a Ward turns it away, a cleanse lifts it")
	assert_eq(Effects.status_kind(GAS), "debuff", "a debuff")


func test_through_a_drum_the_canister_is_its_shot_and_the_gas_rides_every_sprite_hit() -> void:
	var u := _mech(Die.single(_canister(1)), DRUM)
	var a := _foe()
	var b := _foe()
	var c := _foe()
	var sk := _fight([u], [a, b, c])
	assert_true(sk.assign(0, b), "the canister through the drum at the middle of the front rank")
	assert_eq([a.hp, b.hp, c.hp], [28, 26, 28], "the drum's shot: 4 on the target, Spread 2 beside it")
	assert_eq([Effects.stacks_of(a, GAS), Effects.stacks_of(b, GAS), Effects.stacks_of(c, GAS)], [1, 1, 1], "the gas on each Sprite hit")
	assert_eq(sk.mechs[0].heat, 6, "at the drum's heat")


func test_a_warded_sprite_takes_no_gas() -> void:
	var u := _mech(Die.single(_canister(1)))
	var foe := _foe()
	var sk := _fight([u], [foe])
	Effects.grant_buff(foe, "ward", 1, "test", sk.round)
	assert_true(sk.assign(0, foe), "the canister at a warded Sprite")
	assert_eq(Effects.stacks_of(foe, GAS), 0, "the Ward turns it away")


func test_as_the_round_ends_a_stack_becomes_one_debuff_each_as_likely_and_the_gas_goes() -> void:
	var seen := {}
	var wrong: Array[String] = []
	for s in range(1, 161):
		var foe := _foe()
		var sk := _fight([_mech(Die.single(Face.blank()))], [foe], s)
		var pool := Array(sk.gas_pool(foe))
		pool.sort()
		if pool != PLAIN:
			wrong.append("seed %d: the pool %s" % [s, str(pool)])
			continue
		_lay(foe, GAS, 1)
		sk.end_round()
		var now := _carried(foe)
		if now.has(GAS) or now.size() != 1 or not pool.has(now.keys()[0]):
			wrong.append("seed %d: it became %s" % [s, str(now)])
			continue
		seen[now.keys()[0]] = true
	assert_eq(wrong, [] as Array[String], "one stack, one debuff of the pool, the gas gone")
	var drawn := seen.keys()
	drawn.sort()
	assert_eq(drawn, PLAIN, "each of the pool drawn in 160 rounds, each as likely")


func test_each_stack_draws_its_own_the_next_once_the_last_has_landed() -> void:
	var wrong: Array[String] = []
	for s in range(1, 81):
		var foe := _foe()
		var sk := _fight([_mech(Die.single(Face.blank()))], [foe], s)
		_lay(foe, GAS, 4)
		sk.end_round()
		var now := _carried(foe)
		if now.has(GAS) or _draws(foe) != 4:
			wrong.append("seed %d: four stacks became %s" % [s, str(now)])
	assert_eq(wrong, [] as Array[String], "four stacks, four debuffs, none that does not stack twice")


func test_never_a_debuff_it_carries_that_does_not_stack_nor_one_it_is_immune_to() -> void:
	var foe := _foe()
	var sk := _fight([_mech(Die.single(Face.blank()))], [foe])
	_lay(foe, "shocked")
	Effects.lay_timer(foe, Effects.STATUS["exposure"], "mech")
	_lay(foe, "brittled", 2)
	_lay(foe, "ablating", 1)
	var pool := Array(sk.gas_pool(foe))
	assert_false(pool.has("shocked"), "Shocked carried, which does not stack: never drawn")
	assert_false(pool.has("exposure"), "nor Exposed, a timer that renews")
	assert_true(pool.has("brittled") and pool.has("ablating"), "a debuff that stacks is drawn on one carrying it")
	Effects.grant_for_rounds(foe, Effects.STATUS["suppressed"], "mech", sk.round + 1)
	assert_false(Array(sk.gas_pool(foe)).has("suppressed"), "a Sprite that will lose its next turn already: no stun drawn")
	var stout := _foe()
	stout.immune["suppress"] = true
	var sk2 := _fight([_mech(Die.single(Face.blank()))], [stout])
	assert_false(Array(sk2.gas_pool(stout)).has("suppressed"), "immune to the stun: never drawn")
	assert_eq(Array(sk2.gas_pool(stout)).size(), PLAIN.size() - 1, "the rest stand")


func test_a_pin_only_on_a_sprite_carrying_what_it_holds() -> void:
	var foe := _foe()
	var sk := _fight([_mech(Die.single(Face.blank()))], [foe])
	var pool := Array(sk.gas_pool(foe))
	assert_false(pool.has("pinned") or pool.has("seared"), "no pin on a Sprite with nothing to hold")
	_lay(foe, "brittled", 2)
	pool = Array(sk.gas_pool(foe))
	assert_true(pool.has("pinned") and not pool.has("seared"), "Pinned on Brittle (his: \"pinned if the sprite hit has Brittle\")")
	_lay(foe, "ablating", 1)
	assert_true(Array(sk.gas_pool(foe)).has("seared"), "Seared on Ablate")
	_lay(foe, "pinned")
	assert_false(Array(sk.gas_pool(foe)).has("pinned"), "a pin does not stack: never drawn on one it pins")


func test_a_needle_only_while_its_machine_is_in_the_fight_and_reaches_the_sprite() -> void:
	var foe := _foe()
	var echidna := _mech(Die.single(Face.blank()), NEEDLES)
	var sk := _fight([_mech(Die.single(Face.blank())), echidna], [foe])
	assert_true(Array(sk.gas_pool(foe)).has("sonic_needle"), "a machine that lays them in the fight: the needle drawn")
	Effects.grant_for_rounds(foe, Effects.STATUS["phased"], "test", sk.round)
	assert_false(Array(sk.gas_pool(foe)).has("sonic_needle"), "a Phased Sprite it cannot reach: no needle")
	Effects.remove(foe, "phased")
	echidna.hull = 0
	assert_false(Array(sk.gas_pool(foe)).has("sonic_needle"), "its machine wrecked: no needle")
	var alone := _foe()
	var sk2 := _fight([_mech(Die.single(Face.blank()))], [alone])
	assert_false(Array(sk2.gas_pool(alone)).has("sonic_needle"), "no machine laying them: no needle")


func test_a_paradox_only_while_a_machine_with_the_meter_is_in_the_fight() -> void:
	var foe := _foe()
	var baboon := _mech(Die.single(Face.blank()), METER)
	var sk := _fight([_mech(Die.single(Face.blank())), baboon], [foe])
	assert_true(Array(sk.gas_pool(foe)).has("paradox"), "a machine with the meter in the fight: the Paradox drawn")
	baboon.hull = 0
	assert_false(Array(sk.gas_pool(foe)).has("paradox"), "its machine wrecked: no Paradox")
	var alone := _foe()
	var sk2 := _fight([_mech(Die.single(Face.blank()))], [alone])
	assert_false(Array(sk2.gas_pool(alone)).has("paradox"), "no meter: no Paradox")


func test_what_it_becomes_lands_as_the_teams_mark_does() -> void:
	var foe := _foe()
	var sk := _fight([_mech(Die.single(Face.blank()))], [foe])
	sk._gas_becomes(foe, "brittled")
	assert_eq(Effects.stacks_of(foe, "brittled"), 1, "a stack of what it drew")
	sk._gas_becomes(foe, "exposure")
	assert_eq(Effects.stacks_of(foe, "exposure"), int(Effects.STATUS["exposure"].get("stacks", 1)), "a timer on its own clock")
	sk._gas_becomes(foe, "shocked")
	var shock = Effects.live(foe).filter(func(m) -> bool: return m.id == "shocked")
	assert_true(shock.size() == 1 and shock[0].decay == Effects.DECAY_NONE, "a Shock until a strike spends it, as the Shock keyword lays it")
	sk._gas_becomes(foe, "suppressed")
	assert_true(sk._suppressed_through(foe, sk.round + 1), "a stun: its next turn lost")
	var numb := _foe()
	var sk2 := _fight([_mech(Die.single(Face.blank()))], [numb])
	Effects.stack(numb, Effects.STATUS["numbed"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	sk2._gas_becomes(numb, "suppressed")
	assert_false(sk2._suppressed_through(numb, sk2.round + 1), "Numbed's brake as ever: the stun strips a stack")
	assert_eq(Effects.stacks_of(numb, "numbed"), 0, "the stack it strips")


func test_a_ward_turns_away_what_it_becomes() -> void:
	var foe := _foe()
	var sk := _fight([_mech(Die.single(Face.blank()))], [foe])
	_lay(foe, GAS, 3)
	Effects.grant_buff(foe, "ward", 1, "test", sk.round)
	sk._transform_gas()
	var now := _carried(foe)
	now.erase("ward")
	assert_eq(now, {}, "the gas gone and nothing it became landing")


func test_a_needle_it_becomes_is_its_machines_the_bolt_at_its_count() -> void:
	var a := _foe()
	var b := _foe()
	var echidna := _mech(Die.single(Face.blank()), NEEDLES)
	var sk := _fight([echidna], [a, b])
	_lay(a, "sonic_needle", 2)
	_lay(b, "sonic_needle", 1)
	sk._gas_becomes(a, "sonic_needle")
	assert_eq(Effects.stacks_of(a, "sonic_needle"), 0, "the third needle fires the bolt and the stacks go")
	assert_eq([a.hp, b.hp], [28, 28], "Chain 2 on every conductor, its own Sprite included")


func test_a_paradox_it_becomes_is_its_meters_the_stun_at_its_count() -> void:
	var foe := _foe()
	var sk := _fight([_mech(Die.single(Face.blank()), METER)], [foe])
	_lay(foe, "paradox", 1)
	sk._gas_becomes(foe, "paradox")
	assert_eq(Effects.stacks_of(foe, "paradox"), 2, "a stack of the meter")
	sk._gas_becomes(foe, "brittled")
	assert_eq(Effects.stacks_of(foe, "paradox"), 0, "a debuff it became is a debuff gained: the meter counts it, and at its count the stacks go")
	# As the round ends whatever a stack becomes brings a foe at the meter's count less one to it,
	# and the stun costs its next turn, the round's turn being had (_round_over).
	var missed: Array[String] = []
	for s in range(1, 41):
		var f := _foe()
		var fight := _fight([_mech(Die.single(Face.blank()), METER)], [f], s)
		_lay(f, "paradox", 2)
		_lay(f, GAS, 1)
		fight.end_round()
		if not fight._suppressed_through(f, fight.round + 1):
			missed.append("seed %d: %s" % [s, str(_carried(f))])
	assert_eq(missed, [] as Array[String], "the stun a round's end trips costs the Sprite its next turn")


func test_the_round_preview_draws_nothing() -> void:
	var foe := _foe()
	var sk := _fight([_mech(Die.single(Face.blank()))], [foe])
	_lay(foe, GAS, 2)
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	copy.previewing = true
	copy._transform_gas()
	assert_eq(_carried(copy.field_foes()[0]), {GAS: 2}, "the preview's round ends with the gas standing as it is")
	sk.preview_round()
	assert_eq(_carried(foe), {GAS: 2}, "and the fight's own untouched")


func test_the_validator_holds_the_number_to_the_keyword() -> void:
	var db := ContentDB.load_default()
	var bare: Array[String] = []
	db._validate_face("test", {"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["volatile_gas"]}, bare)
	assert_true(bare.any(func(e) -> bool: return e.contains("Volatile Gas needs its number")), "the keyword without its number is refused: %s" % str(bare))
	var stray: Array[String] = []
	db._validate_face("test", {"kind": "attack", "reach": "indirect", "power": 0, "keywords": [], "volatile_gas": 1}, stray)
	assert_true(stray.any(func(e) -> bool: return e.contains("the entry needs the keyword")), "the number without the keyword is refused: %s" % str(stray))
	var good: Array[String] = []
	db._validate_face("test", {"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["volatile_gas"], "volatile_gas": 1}, good)
	assert_eq(good, [] as Array[String], "the two together validate")
	var said := _canister(1).describe()
	assert_true(said.contains("volatile gas 1"), "the entry says its gas: %s" % said)


func test_the_bot_counts_the_gas_a_debuff_to_come_and_nothing_on_a_ward() -> void:
	var can := _canister(1)
	var bare := Face.attack(0, I)
	var u := _mech(Die.of([can, bare]))
	var foe := _foe()
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	var bot := Policy.new()
	var gas := bot.attack_score(sk, ms, can, foe)
	var nothing := bot.attack_score(sk, ms, bare, foe)
	assert_true(gas > nothing, "the gas is worth a debuff to come (%.2f over %.2f)" % [gas, nothing])
	Effects.grant_buff(foe, "ward", 1, "test", sk.round)
	assert_eq(snappedf(bot.attack_score(sk, ms, can, foe), 0.001), snappedf(bot.attack_score(sk, ms, bare, foe), 0.001), "a Ward turns it away: worth nothing")

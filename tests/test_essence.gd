extends TestCase

## The Ammit's rework (Ryan, 12 November), held on synthetic passives and entries, never on the
## chassis's own: Essence, a count kept for the battle that every kill in its fight banks ("Souls
## granted by any kill"; "The souls last the battle"; no cap, "as part of the fantasy"); the
## flare, a stack of Empowered for every five Essence as a fight opens and as a round ends in
## which an attack of its own killed, once however many fell and however many attacks felled
## them ("the flare should be the Ammit kill only"; 16 November: "At the start of the skirmish,
## or at the end of a round where the Ammit killed at least one enemy, the Essences Flare,
## granting 1 Empowered per 5 Essences it holds"; once after each attack that killed from 12
## November until then); the Quintessence Tap, which consumes up to five Essence
## for a stack each ("Consume up to 5 souls, granting 1 Empowered per soul. Cooldown 3") and holds
## every Empowered on the field through the round's end ("No Empowered decays this round. And I
## mean none, not ally or enemy").

const L := Face.Reach.DIRECT

const EATER := {"id": "eater", "name": "Eater", "description": "", "effects": [
	{"trigger": "on_foe_killed", "effect": "stack_status", "value": "essence"},
	{"trigger": "on_skirmish_start", "effect": "stack_status", "value": "overcharged", "per_stack": "essence", "stack_step": 5},
	{"trigger": "on_round_kill", "effect": "stack_status", "value": "overcharged", "per_stack": "essence", "stack_step": 5}]}
const TAP := {"kind": "buff", "status": "overcharged", "targets": "self", "spends": "essence", "spends_up_to": 5, "holds_all": "overcharged", "cooldown": 3}


func _mech(name: String, d: Die, shield: int = 40, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _foe(id: String, hp: int, atk: int = 0) -> Foe:
	var f := Foe.make(id, hp, atk)
	f.content_id = id
	return f


func _essence(u: Unit, n: int) -> void:
	Effects.stack(u, Effects.STATUS["essence"], Effects.status_scope(Effects.STATUS["essence"]), "test", n, Effects.DECAY_NONE)


func _empower(u, n: int, id: String = "overcharged") -> void:
	Effects.stack(u, Effects.STATUS[id], Effects.SKIRMISH, "test", n, Effects.status_decay(Effects.STATUS[id]))


func test_every_kill_in_its_fight_banks_a_essence_whoever_made_it() -> void:
	var sk := Skirmish.new(1, 4)
	var eater := _mech("Eater", Die.single(Face.attack(1, L)))
	eater.grant_passive(EATER)
	var ally := _mech("Ally", Die.single(Face.attack(30, L)))
	sk.add_mech(eater)
	sk.add_mech(ally)
	var a := _foe("revenant", 20)
	var b := _foe("revenant", 20)
	var riser := _foe("revenant", 20)
	sk.add_foes([a, b, riser, _foe("revenant", 500)])
	sk.begin()
	sk.start_round()
	assert_eq(Effects.stacks_of(eater, "essence"), 0, "it opens a battle with none")
	assert_true(sk.assign(1, a), "an ally's kill")
	assert_eq(Effects.stacks_of(eater, "essence"), 1, "banks 1 Essence")
	assert_eq(Effects.stacks_of(ally, "essence"), 0, "on the machine whose passive banks them, and no other")
	assert_eq(Effects.stacks_of(eater, "overcharged"), 0, "and flares nothing: the flare is its own kill's")
	assert_false(sk.mechs[0].killed_round, "nor marks the round as one it killed in")
	# A burn's tick is nobody's blow, and a kill all the same.
	Effects.stack(b, Effects.STATUS["ablating"], Effects.SKIRMISH, "test", 30, Effects.status_decay(Effects.STATUS["ablating"]))
	# A foe getting back up is no kill, so it banks nothing.
	Effects.stack(riser, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	sk.end_round()
	assert_false(b.alive(), "the burn felled it at its action")
	assert_eq(Effects.stacks_of(eater, "essence"), 2, "a burn's tick banks one")
	sk.start_round()
	assert_true(sk.assign(1, riser), "a foe felled that gets back up")
	assert_true(riser.alive(), "and it did")
	assert_eq(Effects.stacks_of(eater, "essence"), 2, "no kill, no Essence")


func test_the_essence_flare_as_a_fight_opens_and_as_a_round_ends_that_it_killed_in() -> void:
	var sk := Skirmish.new(1, 4)
	var wide := Face.from_dict({"kind": "attack", "reach": "direct", "power": 30, "keywords": ["cleave"], "cleave": 30})
	var eater := _mech("Eater", Die.single(wide))
	eater.grant_passive(EATER)
	_essence(eater, 12)
	sk.add_mech(eater)
	var a := _foe("revenant", 20)
	var b := _foe("revenant", 20)
	sk.add_foes([a, b, _foe("revenant", 500)])
	assert_eq(Effects.would_stack(eater, "on_skirmish_start", "overcharged"), 2, "the flare read ahead: a stack for every five of twelve")
	sk.begin()
	assert_eq(Effects.stacks_of(eater, "overcharged"), 2, "as the fight opens the Essence flare, a stack for every five")
	assert_eq(Effects.stacks_of(eater, "essence"), 12, "and none is spent by it")
	sk.start_round()
	var target: Foe = sk.front[0] if sk.front[0] == a or sk.front[0] == b else sk.front[1]
	assert_true(sk.assign(0, target), "its spread fells two")
	assert_false(a.alive() or b.alive(), "both down")
	assert_eq(Effects.stacks_of(eater, "essence"), 14, "the death check banks both first, one for each foe that fell: the trigger's own count, which no effect opts into")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("Eater: 2 foes fall, Essence ×14")), "said once in the log, at the count with both in")
	assert_eq(Effects.stacks_of(eater, "overcharged"), 2, "and nothing flares yet: the kill's flare is the round's end's")
	assert_true(sk.mechs[0].killed_round, "the round is marked as one it killed in")
	assert_true(SaveGame.clone_skirmish(sk).mechs[0].killed_round, "and a copy of the fight keeps the mark")
	sk.end_round()
	assert_eq(Effects.stacks_of(eater, "overcharged"), 1 + 2, "the opening flare halves as its turn ends (two to one); then as the round ends the Essence flare once, two foes killed or one, at the count as it stands (fourteen: two stacks)")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("Eater: as the round ends, after its kill")), "said in the log")
	assert_false(sk.mechs[0].killed_round, "and the mark is spent")
	sk.start_round()
	assert_eq(Effects.stacks_of(eater, "overcharged"), 3, "whole through its next turn: the round's end halves no machine's Empowered")
	sk.end_round()
	assert_eq(Effects.stacks_of(eater, "overcharged"), 1, "a round with no kill of its own: what it holds halves as its turn ends, and nothing flares")


## Once a round, however many of its attacks kill (a Rapid entry and the one after it), and
## nothing for a machine wrecked before the round ends.
func test_the_kills_flare_is_once_a_round_and_a_wreck_flares_nothing() -> void:
	var sk := Skirmish.new(1, 4)
	var eater := _mech("Eater", Die.of([Face.attack(30, L, [Face.Keyword.RAPID]), Face.attack(30, L)]))
	eater.grant_passive(EATER)
	_essence(eater, 10)
	sk.add_mech(eater)
	var a := _foe("revenant", 20)
	var b := _foe("revenant", 20)
	sk.add_foes([a, b, _foe("revenant", 500)])
	sk.begin()
	Effects.remove(eater, "overcharged")   # the opening flare aside
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, a), "its first attack kills")
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, b), "and its second")
	assert_false(a.alive() or b.alive(), "both down, an attack each")
	sk.end_round()
	assert_eq(Effects.stacks_of(eater, "essence"), 12, "two Essence banked")
	assert_eq(Effects.stacks_of(eater, "overcharged"), 2, "and one flare for the round, at twelve: two stacks, never four")
	# A machine wrecked in the enemy's turn flares nothing.
	var sk2 := Skirmish.new(2, 4)
	var doomed := _mech("Eater", Die.single(Face.attack(30, L)))
	doomed.grant_passive(EATER)
	_essence(doomed, 10)
	sk2.add_mech(doomed)
	sk2.add_mech(_mech("Ally", Die.single(Face.attack(1, L))))
	var c := _foe("revenant", 20)
	sk2.add_foes([c, _foe("revenant", 500)])
	sk2.begin()
	Effects.remove(doomed, "overcharged")
	sk2.start_round()
	assert_true(sk2.assign(0, c), "its kill")
	doomed.hull = 0   # as a foe's blow would leave it
	sk2.end_round()
	assert_eq(Effects.stacks_of(doomed, "overcharged"), 0, "wrecked before the round ended: no flare")


func test_a_flare_under_five_essence_grants_nothing() -> void:
	var sk := Skirmish.new(1, 2)
	var eater := _mech("Eater", Die.single(Face.attack(30, L)))
	eater.grant_passive(EATER)
	_essence(eater, 3)
	sk.add_mech(eater)
	var a := _foe("revenant", 20)
	sk.add_foes([a, _foe("revenant", 500)])
	sk.begin()
	assert_eq(Effects.stacks_of(eater, "overcharged"), 0, "three Essence: no flare as the fight opens")
	sk.start_round()
	assert_true(sk.assign(0, a), "its kill")
	sk.end_round()
	assert_eq([Effects.stacks_of(eater, "essence"), Effects.stacks_of(eater, "overcharged")], [4, 0], "four now, and still under five as the round ends")
	var b := _foe("revenant", 20)
	var sk2 := Skirmish.new(2, 2)
	sk2.add_mech(eater)
	sk2.add_foes([b, _foe("revenant", 500)])
	sk2.begin()
	sk2.start_round()
	assert_true(sk2.assign(0, b), "the fifth Essence's own kill")
	assert_eq([Effects.stacks_of(eater, "essence"), Effects.stacks_of(eater, "overcharged")], [5, 0], "the Essence at once, the flare not yet")
	sk2.end_round()
	assert_eq([Effects.stacks_of(eater, "essence"), Effects.stacks_of(eater, "overcharged")], [5, 1], "as the round ends, the flare: five is a stack")


func test_essence_last_the_battle_carry_no_cap_and_nothing_strips_them() -> void:
	var sk := Skirmish.new(1, 2)
	var eater := _mech("Eater", Die.single(Face.attack(30, L)))
	eater.grant_passive(EATER)
	_essence(eater, 40)
	sk.add_mech(eater)
	var a := _foe("revenant", 20)
	sk.add_foes([a, _foe("revenant", 500)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, a), "a kill past forty")
	assert_eq(Effects.stacks_of(eater, "essence"), 41, "no cap: the count goes on")
	assert_eq(Effects.status_kind("essence"), "ability", "an Ability, no buff and no store")
	assert_true(Effects.is_counted("essence"), "whose chip says its count at one too")
	_empower(eater, 4)
	Effects.purge(eater, 99)
	assert_eq(Effects.stacks_of(eater, "essence"), 41, "a Purge takes none of them")
	assert_eq(Effects.stacks_of(eater, "overcharged"), 0, "and takes the Empowered they granted: a stack is a stack")
	sk._finish()
	assert_eq(Effects.stacks_of(eater, "essence"), 41, "kept past the fight")
	var scopes: Array = []
	for d in Effects.describe(eater):
		if str(d[5]) == "essence":
			scopes.append(int(d[3]))
	assert_eq(scopes, [Effects.BATTLE], "one count, the battle's")
	Effects.end_battle(eater)
	assert_eq(Effects.stacks_of(eater, "essence"), 0, "and gone with the battle")


func test_the_tap_consumes_up_to_five_essence_for_a_stack_each() -> void:
	var tap := Face.from_dict(TAP)
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.of([tap, Face.attack(10, L)]))
	sk.add_mech(m)
	sk.add_foes([_foe("revenant", 500)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	# With no Essence it cannot be played, as an entry whose shield cost the shield cannot pay.
	assert_true(sk.spend_short(ms, tap) and sk.cannot_pay(ms, tap), "no Essence to consume")
	assert_false(sk.can_spend(0), "so the die has nowhere to land")
	assert_false(sk.assign(0, null), "and the spend is refused")
	var shown := sk.shown_face(ms, tap)
	assert_true(shown.short, "the die shows its price struck")
	assert_eq(shown.buff_stacks, 5, "at its most")
	# Three Essence: it takes the three.
	_essence(m, 3)
	assert_false(sk.cannot_pay(ms, tap), "1 Essence pays")
	assert_eq(sk.shown_face(ms, tap).buff_stacks, 3, "the die shows what it would take now, and so what it would grant")
	assert_true(sk.assign(0, null), "spent on itself")
	assert_eq([Effects.stacks_of(m, "essence"), Effects.stacks_of(m, "overcharged")], [0, 3], "three consumed, three stacks of Empowered")
	assert_eq(Effects.dark_rounds(m, 0, sk.round), 4, "and its entry is dark for the rest of this round and the three after it (a cooldown counts the rounds after its spend)")
	# Seven: it takes five and leaves two.
	var sk2 := Skirmish.new(2, 2)
	var m2 := _mech("B", Die.of([Face.from_dict(TAP), Face.attack(10, L)]))
	_essence(m2, 7)
	sk2.add_mech(m2)
	sk2.add_foes([_foe("revenant", 500)])
	sk2.begin()
	sk2.start_round()
	sk2.mechs[0].face_index = 0
	assert_true(sk2.assign(0, null), "spent with seven")
	assert_eq([Effects.stacks_of(m2, "essence"), Effects.stacks_of(m2, "overcharged")], [2, 5], "five consumed at most, five stacks")


func test_no_empowered_decays_in_the_taps_round_on_either_side() -> void:
	var sk := Skirmish.new(1, 4)
	var m := _mech("A", Die.of([Face.from_dict(TAP), Face.attack(1, L)]), 40, 400)
	_essence(m, 5)
	_empower(m, 2)
	var ally := _mech("B", Die.single(Face.attack(1, L)), 40, 400)
	_empower(ally, 4)
	sk.add_mech(m)
	sk.add_mech(ally)
	var rallied := _foe("revenant", 500)
	var late := _foe("revenant", 500)
	sk.add_foes([rallied, late])
	sk.begin()
	sk.start_round()
	_empower(rallied, 4, "kindled")
	Effects.stack(rallied, Effects.STATUS["brittled"], Effects.SKIRMISH, "test", 4, Effects.status_decay(Effects.STATUS["brittled"]))
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, null), "the Tap spent")
	assert_eq(Effects.stacks_of(m, "essence_flare"), 1, "its machine gains Essence Flare, a buff of its own")
	assert_eq(Effects.status_kind("essence_flare"), "buff", "a buff, so a Purge takes it")
	assert_false(Effects.has(ally, "essence_flare") or Effects.has(rallied, "essence_flare"), "and no other unit wears anything for it")
	assert_true(sk.field_holds().has("overcharged") and sk.field_holds().has("kindled"), "while it stands the field holds Empowered, a machine's and a foe's: one word on both sides")
	assert_true("\n".join(sk.log).contains("gains Essence Flare: no Empowered decays this round"), "the log says so")
	_empower(late, 2, "kindled")   # what a unit gains later in the round is held too
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 7, "its own, what it held and what it consumed, whole")
	assert_eq(Effects.stacks_of(ally, "overcharged"), 4, "an ally's")
	assert_eq(Effects.stacks_of(rallied, "kindled"), 4, "a foe's: none, not ally or enemy")
	assert_eq(Effects.stacks_of(late, "kindled"), 2, "and what came after the spend")
	assert_eq(Effects.stacks_of(rallied, "brittled"), 2, "nothing else is held: Brittle halves as ever")
	assert_false(Effects.has(m, "essence_flare"), "the buff is the round's, and over with it")
	assert_true(sk.field_holds().is_empty(), "and the hold with it")
	sk.start_round()
	sk.end_round()
	assert_eq([Effects.stacks_of(m, "overcharged"), Effects.stacks_of(ally, "overcharged"), Effects.stacks_of(rallied, "kindled")], [3, 2, 2], "the round after, everything halves again")


## Essence Flare is a buff on the machine that spent the Tap (Ryan, 15 November: "an Ammit specific
## buff ... the no-decay state which is represented as a buff on the Ammit called Essence Flare"),
## so the hold stands while its carrier and its buff do: a Purge that takes it, or a carrier
## wrecked in the enemy's turn, and every Empowered halves as ever.
func test_the_hold_stands_while_its_buff_and_its_carrier_do() -> void:
	for how in ["kept", "purged", "wrecked"]:
		var sk := Skirmish.new(1, 4)
		var m := _mech("A", Die.of([Face.from_dict(TAP), Face.attack(1, L)]), 40, 400)
		_essence(m, 5)
		var ally := _mech("B", Die.single(Face.attack(1, L)), 40, 400)
		_empower(ally, 4)
		sk.add_mech(m)
		sk.add_mech(ally)
		var foe := _foe("revenant", 500)
		sk.add_foes([foe])
		sk.begin()
		sk.start_round()
		_empower(foe, 4, "kindled")
		sk.mechs[0].face_index = 0
		assert_true(sk.assign(0, null), "%s: the Tap spent" % how)
		if how == "purged":
			Effects.remove(m, "essence_flare")   # as a foe's Purge of one takes a buff of one stack
		elif how == "wrecked":
			m.hull = 0
		sk.end_round()
		var held: bool = how == "kept"
		assert_eq(Effects.stacks_of(ally, "overcharged"), 4 if held else 2, "%s: an ally's Empowered" % how)
		assert_eq(Effects.stacks_of(foe, "kindled"), 4 if held else 2, "%s: a foe's" % how)


func test_the_hold_rides_a_clone_and_an_undo_takes_the_spend_back_whole() -> void:
	var sk := Skirmish.new(1, 2)
	sk.keeps_undo = true
	var m := _mech("A", Die.of([Face.from_dict(TAP), Face.attack(1, L)]))
	_essence(m, 6)
	sk.add_mech(m)
	sk.add_foes([_foe("revenant", 500)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, null), "spent")
	var copy := SaveGame.clone_skirmish(sk)
	assert_eq(copy.field_holds(), sk.field_holds(), "a copy of the fight (the round preview's, the planner's, a save's) carries the hold, its machine's buff")
	assert_true(Effects.has(copy.mechs[0].unit, "essence_flare"), "the buff itself")
	copy.end_round()
	assert_eq(Effects.stacks_of(copy.mechs[0].unit, "overcharged"), 5, "so its round ends as the fight's will")
	assert_true(sk.undo(), "the spend taken back")
	assert_true(sk.field_holds().is_empty() and not Effects.has(m, "essence_flare"), "the buff and its hold with it")
	assert_eq([Effects.stacks_of(m, "essence"), Effects.stacks_of(m, "overcharged")], [6, 0], "the Essence back and the Empowered gone")
	assert_eq(Effects.dark_rounds(m, 0, sk.round), 0, "and the entry lit")


func test_the_entry_says_its_two_rules_and_round_trips() -> void:
	var tap := Face.from_dict(TAP)
	assert_eq(tap.describe(), "consumes up to 5 Essence, 1 Empowered each grants Essence Flare: no Empowered decays this round cooldown 3 (self only)", "the entry in plain words")
	for phrase in tap.rule_phrases():
		assert_true(tap.describe().contains(phrase), "its rule '%s' is in its line" % phrase)
	assert_eq(tap.rule_phrases().size(), 2, "two rules of its own, each the star's")
	assert_true(tap.has_unique_rule(), "so the die stars it")
	assert_eq(tap.buff_stacks, 5, "as built it grants its most")
	var back := Face.from_dict(tap.to_dict())
	assert_eq([back.spends, back.spends_up_to, back.holds_all, back.cooldown, back.buff_stacks], ["essence", 5, "overcharged", 3, 5], "it round-trips through a save")
	var copy := tap.duplicate_face()
	assert_eq([copy.spends, copy.spends_up_to, copy.holds_all], ["essence", 5, "overcharged"], "and through a copy")
	assert_eq(Effects.named_like("overcharged"), ["overcharged", "kindled"], "Empowered is one word on both sides")
	assert_eq(Effects.effect_text(EATER["effects"][1]), "as the fight begins: gains a stack of Empowered for every 5 Essence it holds", "the flare reads as a sentence")
	assert_eq(Effects.effect_text(EATER["effects"][0]), "for each foe that falls in its fight: gains a stack of Essence", "and the banking")
	assert_eq(Effects.effect_text(EATER["effects"][2]), "at the end of a round in which it killed: gains a stack of Empowered for every 5 Essence it holds", "and the kill's flare, once a round")


func test_the_validator_holds_the_new_keys() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var base: Dictionary = db.components["overcharge_coil"].duplicate(true)
	var odd := {
		"odd_spends": {"kind": "buff", "status": "overcharged", "targets": "self", "spends": "nonsense", "spends_up_to": 5},
		"odd_most": {"kind": "buff", "status": "overcharged", "targets": "self", "spends": "essence"},
		"odd_stacks": {"kind": "buff", "status": "overcharged", "targets": "self", "spends": "essence", "spends_up_to": 5, "stacks": 2},
		"odd_ally": {"kind": "buff", "status": "overcharged", "spends": "essence", "spends_up_to": 5},
		"odd_hold": {"kind": "buff", "status": "overcharged", "holds_all": "barrier"},
	}
	for id in odd.keys():
		var c: Dictionary = base.duplicate(true)
		c["id"] = id
		c["face"] = odd[id]
		db.components[id] = c
	var good: Dictionary = base.duplicate(true)
	good["id"] = "fine_tap"
	good["face"] = TAP.duplicate(true)
	db.components["fine_tap"] = good
	var c2: Dictionary = db.chassis["badger"].duplicate(true)
	c2["id"] = "odd"
	c2["name"] = "Odd Test"
	c2["passive"] = {"id": "odd", "name": "Odd", "description": "", "effects": [
		{"trigger": "on_kill", "effect": "stack_status", "value": "overcharged", "stack_step": 5},
		{"trigger": "on_foe_killed", "effect": "vent_heat", "value": 2}]}
	db.chassis["odd"] = c2
	var errs := db.validate()
	var said := func(where: String, what: String) -> bool:
		return errs.any(func(e: String) -> bool: return e.begins_with(where) and e.contains(what))
	assert_true(said.call("component odd_spends", "spends is a buff's"), "a count the engine lacks is refused")
	assert_true(said.call("component odd_most", "spends_up_to is the most"), "and one with no most")
	assert_true(said.call("component odd_stacks", "no stacks"), "it says no stacks of its own")
	assert_true(said.call("component odd_ally", "lands on itself"), "and lands on its own machine")
	assert_true(said.call("component odd_hold", "holds_all names a status that halves"), "a hold on a status that does not halve is refused")
	assert_false(errs.any(func(e: String) -> bool: return e.begins_with("component fine_tap")), "and the entry as built is clean")
	assert_true(said.call("chassis odd", "stack_step"), "a step with no status to count is refused")
	assert_true(said.call("chassis odd", "'vent_heat' on 'on_foe_killed'"), "and the trigger banks a status or gives shield (the Buzzard's carrion), nothing else")


func test_the_content_as_shipped_runs_the_new_rules() -> void:
	# Whatever chassis carries them today: a count banked on on_foe_killed is one the engine
	# keeps for the battle, and an entry that spends one names a count some passive banks.
	var db := ContentDB.load_default()
	var banked := {}
	for id in db.chassis.keys():
		var p = db.chassis[id].get("passive", null)
		if not (p is Dictionary) or str(p.get("status", "implemented")) == "planned":
			continue
		for eff in p.get("effects", []):
			if str(eff.get("trigger", "")) == "on_foe_killed" and str(eff.get("effect", "")) == "stack_status":
				banked[str(eff.get("value", ""))] = id
				assert_eq(Effects.status_scope(Effects.STATUS[str(eff["value"])]), Effects.BATTLE, "%s banks a count the battle keeps" % id)
	for cid in db.components.keys():
		var fd = db.components[cid].get("face", {})
		if fd is Dictionary and fd.has("spends"):
			assert_true(banked.has(str(fd["spends"])), "%s spends a count a chassis banks" % cid)
			var owner := str(banked.get(str(fd["spends"]), ""))
			assert_true((db.chassis.get(owner, {}).get("fixed", []) as Array).has(cid), "%s is locked on the machine that banks it" % cid)


# ---------------------------------------------------------------- the screen and the bot

func test_the_die_prints_the_essence_it_would_take_as_a_cost_and_strikes_it_with_none() -> void:
	var tap := Face.from_dict(TAP)
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.of([tap, Face.attack(10, L)]))
	_essence(m, 3)
	sk.add_mech(m)
	sk.add_foes([_foe("revenant", 500)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var d := DieFaceView.new()
	d.set_face(sk.shown_face(ms, tap))
	assert_eq(d.cost_marks().map(func(c: Array) -> String: return "%s %d %s" % [c[0], c[1], c[3]]), ["essence 3 false", "cooldown 3 false"], "along the foot: the Essence it would take by their mark, and its clock")
	assert_eq(DieFaceView.inside_effect(tap), "overcharged", "its gear holds what it grants")
	assert_true(d.rail_tags().has("star"), "and its rules wear the star")
	Effects.remove(m, "essence")
	d.set_face(sk.shown_face(ms, tap))
	assert_eq(d.cost_marks().map(func(c: Array) -> String: return "%s %d %s" % [c[0], c[1], c[3]]), ["essence 5 true", "cooldown 3 false"], "with none, its most, struck")
	d.free()
	# The readout says the same, a line a mark.
	_essence(m, 3)
	var db := ContentDB.load_default()
	var said: Array[String] = []
	for l in EntryReadout.lines_for(sk.shown_face(ms, tap), 1, -1, tap, [], [], db):
		said.append(EntryReadout.line_text(l))
	assert_true(said.has("Grants Empowered ×3"), "what it grants now: %s" % str(said))
	assert_true(said.has("Consumes 3 Essence"), "what it consumes now")
	assert_true(said.has("Consumes up to 5 Essence, 1 Empowered each") and said.has("Grants Essence Flare: no Empowered decays this round"), "and its two rules, as written")


func test_the_essence_chip_says_its_count_and_the_flare_is_its_machines_chip_alone() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1)
	var m := db.make_mech("badger")
	m.die = Die.of([Face.from_dict(TAP), Face.attack(10)])
	sk.add_mech(m)
	var foe := Foe.make("revenant", 300, 0)
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	_essence(m, 1)
	s._refresh()
	var counts: Array = s._mech_rows(0).filter(func(r: Array) -> bool: return str(r[0]) == "essence")
	assert_eq(counts.size(), 1, "one chip for the Essence")
	assert_eq([str(counts[0][1]), str(counts[0][2]), str(counts[0][4])], ["1", "Ability, Essence 1", "ability"], "an Ability's, saying its count at one")
	assert_true(s._mech_rows(0).filter(func(r: Array) -> bool: return str(r[0]) == "essence_flare").is_empty(), "no flare while nothing holds the round")
	var kept: Array = db.codex_for_unit(m)["effects"].filter(func(e: Dictionary) -> bool: return str(e["name"]).begins_with("ESSENCE"))
	assert_eq(kept.size(), 1, "the codex lists the count")
	if not kept.is_empty():
		assert_eq([str(kept[0]["name"]), str(kept[0]["note"])], ["ESSENCE 1", "KEPT FOR THE BATTLE"], "among what the battle keeps")
	# The Tap spent: its machine wears Essence Flare, a buff's chip, and no other unit wears
	# anything for the hold (Ryan, 15 November: "I would give it to the Ammit only, even though
	# it affects the whole battlefield").
	_empower(foe, 2, "kindled")
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, null), "the Tap spent")
	s._refresh()
	var flares: Array = s._mech_rows(0).filter(func(r: Array) -> bool: return str(r[0]) == "essence_flare")
	assert_eq(flares.size(), 1, "one chip on its machine")
	if not flares.is_empty():
		assert_eq(str(flares[0][2]), "Buff, Essence Flare", "a buff's, by its name")
	assert_true(s._foe_rows(foe).filter(func(r: Array) -> bool: return str(r[0]) == "essence_flare" or str(r[2]).contains("Pinned")).is_empty(), "and a foe's Empowered wears nothing for it")
	assert_true(Terms.has("essence_flare") and not Terms.has("pinned_empowered"), "the list holds the buff, and Pinned Empowered is gone from it")
	s.free()


func test_the_bot_reads_the_flare_and_the_hold() -> void:
	var gun := Face.attack(30, L)
	var sk := Skirmish.new(3, 2)
	var plain := _mech("Plain", Die.of([gun, Face.attack(30, L)]))
	var eater := _mech("Eater", Die.of([Face.attack(30, L), Face.from_dict(TAP)]))
	eater.grant_passive(EATER)
	_essence(eater, 10)
	sk.add_mech(plain)
	sk.add_mech(eater)
	var g := _foe("revenant", 30, 1)
	sk.add_foes([g, _foe("revenant", 500, 1)])
	sk.begin()
	sk.start_round()
	Effects.remove(eater, "overcharged")   # the opening flare aside: the kill's own worth is what is read
	var pol := Policy.make(Policy.GREEDY)
	var a := pol.attack_score(sk, sk.mechs[0], gun, g)
	var b := pol.attack_score(sk, sk.mechs[1], eater.die.faces[0], g)
	assert_true(b > a, "a kill that sets off a flare is worth more than the same kill without one")
	assert_eq(snappedf(b - a, 0.01), snappedf(Policy.flare_gain(sk.mechs[1], "overcharged", 2) * Policy.FLARE_ROUNDS, 0.01), "by the flare's stacks on its die's strikes, about a round of them")
	sk.mechs[1].killed_round = true
	assert_eq(snappedf(pol.attack_score(sk, sk.mechs[1], eater.die.faces[0], g), 0.01), snappedf(a, 0.01), "and nothing more once it has killed this round: the flare is coming already, once a round")
	sk.mechs[1].killed_round = false
	# The Tap: nothing with no Essence to consume; with some, what it carries whole into the next
	# round, less the Essence it spends; and a foe's Empowered held with it is its price.
	var tap: Face = eater.die.faces[1]
	var with_ten := pol.hold_score(sk, sk.mechs[1], tap)
	assert_true(with_ten > 0.0, "five Essence for five stacks carried whole is worth pressing")
	_empower(g, 6, "kindled")
	assert_true(pol.hold_score(sk, sk.mechs[1], tap) < with_ten, "less while a foe's rally would be held with it")
	Effects.remove(eater, "essence")
	assert_eq(pol.hold_score(sk, sk.mechs[1], tap), 0.0, "and nothing with no Essence")

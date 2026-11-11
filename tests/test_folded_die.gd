extends TestCase

## A folded die (the Clydesdale's batteries; Ryan, 11 November: "One half at a time, yes, not two
## dice spinning. The active half should persist between skirmishes, too"; "My intent was for the
## flipper to be shared between the two, so it's the same piece with one cooldown"). Synthetic, as
## every test of a passive: a turner fixed first, then two batteries of four, the first's blows 1
## to 4 and the second's 11 to 14, so an entry's place says which battery it is.

const L := Face.Reach.DIRECT
const FOLD_PASSIVE := {"id": "test_fold", "name": "Fold", "description": "", "effects": [{"trigger": "static", "effect": "fold_die", "value": 4}]}


func _turner() -> Face:
	var f := Face.from_dict({"kind": "buff", "targets": "self", "keywords": ["rapid"], "cooldown": 1, "turns_die": true})
	f.fixed = true
	f.component = "test_turner"
	return f


func _folded_unit(fold: bool = true) -> Unit:
	var faces: Array = [_turner()]
	for p in [1, 2, 3, 4, 11, 12, 13, 14]:
		faces.append(Face.attack(p, L))
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.shield = 40
	u.shield_max = 40
	u.hull = 100
	u.hull_max = 100
	u.die = Die.of(faces)
	if fold:
		u.grant_passive(FOLD_PASSIVE)
	return u


func _fight(u: Unit, seed_value: int) -> Skirmish:
	var sk := Skirmish.new(seed_value)
	sk.add_mech(u)
	sk.add_foes([Foe.make("revenant", 500, 1)])
	sk.begin()
	sk.start_round()
	return sk


## Spend the turner, on itself, from the entry showing.
func _turn(sk: Skirmish) -> bool:
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	return sk.assign(0, ms)


func test_the_batteries_and_the_turner_by_their_places() -> void:
	var u := _folded_unit()
	assert_eq(Effects.folds_die(u), 4, "batteries of four")
	assert_eq(Effects.live_entries(u, u.die), [0, 1, 2, 3, 4], "the turner and the first battery up")
	assert_eq(Effects.stowed_entries(u, u.die), [5, 6, 7, 8], "the second stowed")
	assert_true(Effects.turn_die(u), "turned: the second up")
	assert_true(Effects.has(u, "changed_over"), "which carries Changed Over")
	assert_eq(Effects.live_entries(u, u.die), [0, 5, 6, 7, 8], "the turner live on both batteries")
	assert_eq(Effects.stowed_entries(u, u.die), [1, 2, 3, 4], "the first stowed")
	assert_false(Effects.turn_die(u), "turned back: the first up")
	assert_false(Effects.has(u, "changed_over"), "with no chip")
	var plain := _folded_unit(false)
	assert_eq(Effects.folds_die(plain), 0, "a die with no fold")
	assert_eq(Effects.live_entries(plain, plain.die), [], "rolls among every entry")
	assert_eq(Effects.stowed_entries(plain, plain.die), [], "and stows none")


func test_a_folded_die_rolls_its_battery_up_and_its_turner_alone() -> void:
	var seen := {}
	for seed_value in range(60):
		var sk := _fight(_folded_unit(), seed_value)
		var ms: Skirmish.MechState = sk.mechs[0]
		seen[ms.face_index] = true
		sk.rerolls_left = 3
		for k in range(3):
			sk.reroll([0])
			seen[ms.face_index] = true
	assert_eq(seen.size(), 5, "the opening roll and the rerolls land on five entries over sixty fights")
	for i in seen.keys():
		assert_true(int(i) <= 4, "the turner or the first battery, never the battery stowed (%d)" % int(i))


func test_the_turner_raises_the_other_battery_and_its_free_roll_lands_there() -> void:
	for seed_value in range(20):
		var u := _folded_unit()
		var sk := _fight(u, seed_value)
		var ms: Skirmish.MechState = sk.mechs[0]
		assert_true(_turn(sk), "the turner spent on itself")
		assert_true(Effects.has(u, "changed_over"), "the second battery up")
		assert_true(ms.face_index >= 5, "Rapid's free roll on the battery it raised, never the turner (%d)" % ms.face_index)
		assert_false(ms.assigned, "and the machine acts again")
		assert_true(Effects.is_entry_disabled(u, 0), "the turner dark for the round: one entry, one cooldown")
	var u2 := _folded_unit()
	var s2 := _fight(u2, 7)
	_turn(s2)
	s2.rerolls_left = 8
	for k in range(8):
		s2.reroll([0])
		var at: int = s2.mechs[0].face_index
		assert_true(at == 0 or at >= 5, "a reroll after the turn stays on the raised battery and its turner (%d)" % at)


func test_the_battery_up_stays_from_fight_to_fight_and_a_battle_opens_on_the_first() -> void:
	var u := _folded_unit()
	var sk := _fight(u, 4)
	assert_true(_turn(sk), "turned in the first fight")
	Effects.end_skirmish(u)
	assert_true(Effects.has(u, "changed_over"), "the fight's end keeps the battery up")
	for seed_value in range(30):
		var next := _fight(u, seed_value)
		var at: int = next.mechs[0].face_index
		assert_true(at == 0 or at >= 5, "the next fight opens on the second battery (%d)" % at)
		Effects.end_skirmish(u)
	Effects.end_battle(u)
	assert_false(Effects.has(u, "changed_over"), "the battle's end lets it go, so the next battle opens on the first")
	assert_eq(Effects.live_entries(u, u.die), [0, 1, 2, 3, 4], "the first battery up again")


func test_a_turner_on_a_die_that_does_not_fold_turns_nothing() -> void:
	var u := _folded_unit(false)
	var sk := _fight(u, 2)
	assert_true(_turn(sk), "spent")
	assert_false(Effects.has(u, "changed_over"), "no battery to turn to")


func test_every_folded_chassis_has_its_turner_and_a_model_holding_the_raised_battery() -> void:
	# Content and models alike: a chassis whose passive folds its die fills two batteries with its
	# hardpoints, fixes a piece that turns it, and its model holds the second battery up as the
	# form of Changed Over's name (the model's half of the turn).
	var db := ContentDB.load_default()
	var folded := 0
	for id in db.chassis.keys():
		var c: Dictionary = db.chassis[id]
		var u := db.make_mech(str(id))
		var h := Effects.folds_die(u)
		if h <= 0:
			continue
		folded += 1
		assert_eq(int(c.get("hardpoints", 0)), 2 * h, "%s: two batteries of %d" % [id, h])
		var turns := false
		for f in u.die.faces:
			if f.fixed and f.turns_die:
				turns = true
		assert_true(turns, "%s: a fixed piece turns it" % id)
		var forms = MechRig.load_sidecar(str(id)).get("forms", {})
		assert_true(forms is Dictionary and (forms as Dictionary).has("changed_over"), "%s: its model raises its second battery" % id)
	assert_true(folded > 0, "a folded die in content")

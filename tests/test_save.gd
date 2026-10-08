extends TestCase

## Save and resume, headless: a battle written as data and read back plays on exactly as
## the original would have. Content builds the team (the real dice and passives are the
## point); the assertions never name a specific entry's passive.

const TMP := "user://test_battle.json"


func _team() -> Array:
	var db := ContentDB.load_default()
	var out: Array = []
	var uid := 1
	for id in db.default_team():
		out.append(db.make_mech(id, uid))
		uid += 1
	return out


func _battle(seed_value: int = 5) -> Battle:
	var b := Battle.new(seed_value)
	b.setup(_team(), "")
	return b


## Park a pack beside a machine, rooted and pushing, so it can be attacked.
func _engage(b: Battle, sq: Unit, m: Unit) -> void:
	var spot := m.pos
	for n in Hex.neighbors(m.pos):
		if b.field.can_stand(sq, n):
			spot = n
			break
	sq.pos = spot
	sq.movespeed = 0
	sq.behaviour = "push"


## The same skirmish played from two copies of one state by the same bot with the same
## seed: the fights must match blow for blow.
func _play_alike(a: Skirmish, b: Skirmish) -> void:
	var pa := Policy.make(Policy.GREEDY, 11)
	var pb := Policy.make(Policy.GREEDY, 11)
	for pair in [[pa, a], [pb, b]]:
		var pol: Policy = pair[0]
		var sk: Skirmish = pair[1]
		# Finish the round under way first: the bot's play begins at a round's start.
		if sk.state == Skirmish.State.ASSIGN:
			pol.play_round(sk)
			if sk.outcome == Skirmish.Outcome.NONE:
				sk.end_round()
		if sk.outcome == Skirmish.Outcome.NONE:
			pol.play(sk)
	assert_eq(a.outcome, b.outcome, "the same outcome")
	assert_eq(a.round, b.round, "in the same round")
	assert_eq(a.log.size(), b.log.size(), "the same log length")
	for i in range(mini(a.log.size(), b.log.size())):
		if a.log[i] != b.log[i]:
			assert_eq(a.log[i], b.log[i], "the logs agree at line %d" % i)
			break
	for i in range(a.mechs.size()):
		assert_eq(a.mechs[i].unit.hull, b.mechs[i].unit.hull, "%s's hull" % a.mechs[i].unit.display_name)
		assert_eq(a.mechs[i].heat, b.mechs[i].heat, "%s's heat" % a.mechs[i].unit.display_name)


func test_a_battle_in_plan_round_trips() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var dest: Vector2i = b.destinations_for(m).keys()[0]
	b.move_to(m, dest)
	var hunted: Unit = b.mechs()[1]
	var hunter: Unit = b.field.packs()[0]
	_engage(b, hunter, hunted)
	hunter.behaviour = "hunt"
	hunter.prey = hunted.id
	b.forced = b.field.forced_fights()
	b.spent[b.mechs()[2].id] = 1
	b.fought[b.mechs()[2].id] = true
	b.orders[hunted.id] = hunter
	var d := SaveGame.to_dict(b)
	var text := JSON.stringify(d)
	var back := SaveGame.from_dict(JSON.parse_string(text))
	assert_eq(back.seed_value, b.seed_value, "the seed")
	assert_eq(back.faction, b.faction, "the faction")
	assert_eq(back.state, Battle.State.PLAN, "still planning")
	assert_eq(back.field.units.size(), b.field.units.size(), "every unit")
	assert_eq(back.map.terrain, b.map.terrain, "the same map from the same seed")
	assert_eq(back.field.gate_hp, b.field.gate_hp, "the gate")
	assert_eq(back.field.unit_by_id(m.id).pos, dest, "the machine where it moved")
	assert_eq(back.moves_left(back.field.unit_by_id(m.id)), b.moves_left(m), "with the move it has left")
	assert_true(back.can_undo(back.field.unit_by_id(m.id)), "and its move can still be taken back")
	assert_eq(back.spent, b.spent, "who has fought")
	assert_eq(back.fought, b.fought, "and who recharges")
	assert_eq(back.forced.size(), 1, "the fight a hunter forced")
	assert_eq((back.forced[0]["prey"] as Unit).id, hunted.id, "on its prey")
	assert_eq((back.forced[0]["hunters"][0] as Unit).id, hunter.id, "by its hunter")
	assert_eq(back.orders.size(), 1, "the order given")
	assert_eq((back.orders[hunted.id] as Unit).id, hunter.id, "onto its pack")
	var bm: Unit = back.field.unit_by_id(m.id)
	assert_eq(bm.display_name, m.display_name, "the machine by id")
	assert_eq(bm.die.size(), m.die.size(), "its die")
	for i in range(m.die.size()):
		assert_eq(bm.die.faces[i].to_dict(), m.die.faces[i].to_dict(), "entry %d" % i)
		assert_eq(bm.die.faces[i].component, m.die.faces[i].component, "entry %d's component" % i)
		assert_eq(bm.die.faces[i].fixed, m.die.faces[i].fixed, "entry %d fixed" % i)
	assert_eq(bm.modifiers.size(), m.modifiers.size(), "its passives")
	assert_eq(Effects.describe(bm), Effects.describe(m), "read the same")
	assert_eq(bm.hull_max, m.hull_max, "the same hull through the pipeline")
	assert_eq(back.boss != null, b.boss != null, "the boss")
	if back.boss != null:
		assert_eq(back.boss.id, b.boss.id, "by id")
	assert_eq(back.rng.state, b.rng.state, "the battle's random stream")
	# Written twice, the data is the same: nothing drifts through a round trip.
	assert_eq(JSON.stringify(SaveGame.to_dict(back)), JSON.stringify(SaveGame.to_dict(SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(back)))))), "stable")


func test_a_skirmish_under_way_resumes_and_plays_on_alike() -> void:
	var b := _battle(9)
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	assert_eq(b.state, Battle.State.SKIRMISH, "a fight")
	assert_true(sk != null, "a fight")
	sk.begin()
	sk.start_round()
	# A round in: dice spent, a reroll, statuses about, the enemy's blows landed.
	var pol := Policy.make(Policy.GREEDY, 3)
	pol.play_round(sk)
	if sk.outcome == Skirmish.Outcome.NONE:
		sk.end_round()
	if sk.outcome == Skirmish.Outcome.NONE:
		sk.start_round()
		if sk.rerolls_left > 0:
			sk.reroll([0])
	var d: Dictionary = JSON.parse_string(JSON.stringify(SaveGame.to_dict(b)))
	var back := SaveGame.from_dict(d)
	assert_eq(back.state, Battle.State.SKIRMISH, "still in the fight")
	assert_true(back.current != null, "the skirmish came back")
	var sk2: Skirmish = back.current
	assert_eq(sk2.round, sk.round, "the round")
	assert_eq(sk2.rerolls_left, sk.rerolls_left, "the rerolls")
	assert_eq(sk2.state, sk.state, "the state")
	assert_eq(sk2.mechs.size(), sk.mechs.size(), "the machines")
	for i in range(sk.mechs.size()):
		assert_eq(sk2.mechs[i].face_index, sk.mechs[i].face_index, "the die showing")
		assert_eq(sk2.mechs[i].heat, sk.mechs[i].heat, "the heat")
		assert_eq(sk2.mechs[i].unit.id, sk.mechs[i].unit.id, "the same unit of the field")
		assert_true(back.field.units.has(sk2.mechs[i].unit), "and it is the field's unit, not a copy")
	assert_eq(sk2.field_foes().size(), sk.field_foes().size(), "the foes on the field")
	assert_eq(sk2.reinforcements.size(), sk.reinforcements.size(), "and waiting")
	for col in range(sk.columns):
		var a_front: Foe = sk.front[col]
		var b_front: Foe = sk2.front[col]
		assert_eq(a_front == null, b_front == null, "column %d front" % col)
		if a_front != null and b_front != null:
			assert_eq(b_front.hp, a_front.hp, "its hit points")
			assert_eq(b_front.display_name, a_front.display_name, "its name")
			assert_eq(sk.mechs.find(a_front.target), sk2.mechs.find(b_front.target), "its target")
			assert_eq(Effects.describe(b_front), Effects.describe(a_front), "its statuses")
	assert_eq(sk2.rng.state, sk.rng.state, "the fight's random stream")
	assert_eq(sk2.packs.size(), sk.packs.size(), "the packs it will shrink")
	_play_alike(sk, sk2)
	# And the battle takes the resumed fight back the same way.
	b.finish_skirmish()
	back.finish_skirmish()
	assert_eq(back.state, b.state, "the battle's state after")
	assert_eq(back.field.units.size(), b.field.units.size(), "the same units left")
	assert_eq(back.field.rift_pressure, b.field.rift_pressure, "the same pressure")
	assert_eq(back.actions_left(back.field.unit_by_id(m.id)), b.actions_left(m), "and the machine spent alike")


func test_damage_and_statuses_survive_the_trip() -> void:
	var b := _battle(4)
	var m: Unit = b.mechs()[0]
	# A cracked entry, a destroyed one, a battle reward and a skirmish status, by hand.
	var original: Face = m.die.faces[0].duplicate_face()
	m.damaged_faces[0] = original
	var cracked: Face = m.die.faces[0].duplicate_face()
	cracked.crack()
	m.die.faces[0] = cracked
	var gone := Face.blank()
	gone.component = m.die.faces[1].component
	m.damaged_faces[1] = m.die.faces[1].duplicate_face()
	m.die.faces[1] = gone
	Effects.grant(m, Effects.make({"id": "reward", "name": "Reward", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 20}]}, Effects.BATTLE, "reward"))
	Effects.stack(m, Effects.STATUS["overheating"], Effects.SKIRMISH, "foe:x", 2)
	m.hull = 33
	m.shield = 7
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	var bm: Unit = back.field.unit_by_id(m.id)
	assert_true(bm.die.faces[0].cracked, "the crack")
	assert_eq(bm.die.faces[0].keywords.size(), 0, "with its keywords gone")
	assert_eq(bm.die.faces[1].kind, Face.Kind.BLANK, "the destroyed entry is blank")
	assert_eq(bm.die.faces[1].component, gone.component, "and remembers what it was")
	assert_eq(bm.damaged_component_count(), 2, "two to repair")
	assert_eq(bm.damaged_faces[0].to_dict(), original.to_dict(), "the original kept for the hangar")
	assert_eq(bm.hull, 33, "hull as it was")
	assert_eq(bm.shield, 7, "shield as it was")
	assert_eq(bm.hull_max, m.hull_max, "the reward still counts")
	assert_eq(Effects.stacks_of(bm, "overheating"), 2, "the status and its stacks")
	bm.repair_faces()
	assert_eq(bm.die.faces[0].to_dict(), original.to_dict(), "and the hangar can repair it")


func test_the_file_is_written_read_and_cleared() -> void:
	SaveGame.clear(TMP)
	assert_false(SaveGame.exists(TMP), "nothing to begin with")
	assert_true(SaveGame.load(TMP) == null, "and nothing loads")
	var b := _battle(2)
	assert_true(SaveGame.save(b, TMP), "written")
	assert_true(SaveGame.exists(TMP), "there")
	var back := SaveGame.load(TMP)
	assert_true(back != null, "read")
	assert_eq(back.seed_value, 2, "the same battle")
	SaveGame.clear(TMP)
	assert_false(SaveGame.exists(TMP), "cleared")
	# A file from another version is refused rather than misread.
	var f := FileAccess.open(TMP, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 999}))
	f.close()
	assert_true(SaveGame.load(TMP) == null, "an unknown version loads nothing")
	SaveGame.clear(TMP)

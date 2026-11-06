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
	quiet_start(b)   # a save's rules, not the opening's (TestCase.quiet_start)
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


## A pusher's wall segment rides in the save (the long wall brief 3.3).
func test_a_pushers_wall_segment_rides_in_the_save() -> void:
	var b := _battle()
	var sq: Unit = b.field.packs()[0]
	sq.goal_col = 3
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(back.field.unit_by_id(sq.id).goal_col, 3, "the segment comes back")
	for p in b.field.packs():
		assert_eq(back.field.unit_by_id(p.id).goal_col, p.goal_col, "%s keeps its segment" % p.display_name)


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
	assert_eq(back.moved, b.moved, "who has moved this action")
	assert_true(back.moved.has(m.id), "the machine among them, in one go")
	assert_true(back.can_undo(), "and its move can still be taken back")
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


## The mechanics audit (25 October): a battle read back from its save dresses every pack Rift
## Pressure spawns from the content (its ring, move and hunt), a resumed fight calls content up
## as a fresh one does (a fallen Gel splits), and a final's commanders come back with it.
func test_a_resumed_battle_dresses_its_spawns_and_its_fight_calls_content_up() -> void:
	var b := Battle.new(4)
	b.lineup = ["warrior"]
	b.escort = ["goblin", 3]
	b.setup(_team(), "meadow")
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(back.lineup, b.lineup, "the rift's commanders")
	assert_eq(back.escort, b.escort, "and its escort")
	var profiles: Dictionary = b.db.pack_profiles()
	assert_eq(back.field.cycle.size(), b.field.cycle.size(), "the cycle rides in the save")
	assert_eq(back.field.patrol_cycle.size(), b.field.patrol_cycle.size(), "and the tears' cycle")
	for i in range(back.field.cycle.size()):
		var before := back.field.packs().size()
		assert_true(back.field.tick_pressure(back.field.rift_pressure_max), "the rift spawns")
		var spawned: Unit = back.field.packs()[before]
		var p: Dictionary = profiles.get(spawned.foe_id, {})
		assert_false(p.is_empty(), "a content foe: %s" % spawned.foe_id)
		var ring := 1
		var pace := 99
		for m in spawned.member_list():
			ring = maxi(ring, int(profiles.get(str(m[0]), {}).get("zone", 1)))
			pace = mini(pace, int(profiles.get(str(m[0]), {}).get("movespeed", Unit.PACK_MOVE)))
		assert_eq(spawned.zone, ring, "%s: its ring, the largest of its members'" % spawned.foe_id)
		assert_eq(spawned.movespeed, pace, "%s: its move, the slowest" % spawned.foe_id)
		assert_eq(spawned.behaviour, str(p.get("behaviour", "push")), "%s: its walk, its lead's" % spawned.foe_id)
	var m: Unit = b.mechs()[0]
	var sq: Unit = null
	for p in b.field.packs():
		if p.foe_id == "gel":
			sq = p
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	var resumed := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	var sk2: Skirmish = resumed.current
	assert_true(sk2.foe_factory.is_valid(), "the resumed fight can call content up")
	for f in sk2.field_foes():
		if f.content_id == "gel":
			f.hp = 0
			break
	sk2.end_round()
	var halves := 0
	for f in sk2.field_foes() + sk2.reinforcements:
		if f.content_id == "gel_half":
			halves += 1
	assert_eq(halves, 2, "and a Gel it fells splits in two")


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


func test_a_foe_keeps_its_role_and_its_death_through_the_trip() -> void:
	# A fight resumed mid-way plays on alike: the plaque's boss (the content's word since 15
	# October), a splitter's summon and a foe gone whole all ride in the save.
	var sk := Skirmish.new(1)
	var boss := Foe.make("warden", 100, 20)
	boss.boss = true
	var splitter := Foe.make("blob", 40, 10)
	splitter.on_death = {"summon": "blob_half", "count": 2}
	var gone := Foe.make("cinder", 30, 10)
	gone.stays_down = true
	var trip := func(f: Foe) -> Foe: return SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(f, sk))), sk)
	assert_true((trip.call(boss) as Foe).boss, "the boss stays the boss, human-sized")
	var split: Foe = trip.call(splitter)
	assert_eq(str(split.on_death.get("summon", "")), "blob_half", "the splitter still splits")
	assert_eq(split.on_death.get("count", 0), 2, "into as many, a whole number")
	assert_true((trip.call(gone) as Foe).stays_down, "a foe gone whole stays down")
	var old := SaveGame._foe_dict(Foe.make("old", 100, 20), sk)
	old.erase("boss")
	old["size"] = 2
	assert_true(SaveGame._foe_from(old, sk).boss, "a save from before 15 October marks its massive foe the boss, as it played")


## A composition's members ride in the save (30 October), and a fight's tallies by type with
## them, so a resumed battle keeps its packs by member and its kills at their menace.
func test_a_compositions_members_survive_the_trip() -> void:
	var b := _battle()
	var host: Unit = b.field.packs()[0]
	host.set_members([["revenant", 2], ["ghost", 1]])
	var d: Dictionary = JSON.parse_string(JSON.stringify(SaveGame.to_dict(b)))
	var back := SaveGame.from_dict(d)
	var again := back.field.unit_by_id(host.id)
	assert_eq(again.members, [["revenant", 2], ["ghost", 1]], "the members as they were")
	assert_eq(again.foe_id, "revenant", "the lead's type")
	assert_eq(again.strength, 3, "and the count")
	var sk := Skirmish.new(3)
	sk.add_mech(b.mechs()[0])
	sk.add_foes(b.db.foes_for(host), host)
	sk.joined_fallen_types[host.id] = {"gel_half": 2}
	var sd: Dictionary = JSON.parse_string(JSON.stringify(SaveGame._skirmish_dict(sk, b.field)))
	var sk2 := SaveGame._skirmish_from(sd, b.field)
	assert_eq(sk2.came_with.get(host.id, {}), {"revenant": 2, "ghost": 1}, "what the pack came with")
	assert_eq(sk2.joined_fallen_types.get(host.id, {}), {"gel_half": 2}, "and the joined fallen by type")
	assert_eq(sk2.kills_by_type(host), sk.kills_by_type(host), "the kills by type read alike")


func test_damage_and_statuses_survive_the_trip() -> void:
	var b := _battle(4)
	var m: Unit = b.mechs()[0]
	# Two destroyed entries, a battle reward and a skirmish status, by hand.
	var original: Face = m.die.faces[0].duplicate_face()
	m.damaged_faces[0] = original
	var first := Face.blank()
	first.component = original.component
	m.die.faces[0] = first
	var gone := Face.blank()
	gone.component = m.die.faces[1].component
	m.damaged_faces[1] = m.die.faces[1].duplicate_face()
	m.die.faces[1] = gone
	Effects.grant(m, Effects.make({"id": "reward", "name": "Reward", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 20}]}, Effects.BATTLE, "reward"))
	Effects.stack(m, Effects.STATUS["burning_mech"], Effects.SKIRMISH, "foe:x", 2, Effects.DECAY_TURN)
	Effects.stack(m, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe:x", 2, Effects.DECAY_TURN_ALL)
	m.hull = 33
	m.shield = 7
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	var bm: Unit = back.field.unit_by_id(m.id)
	assert_eq(bm.die.faces[0].kind, Face.Kind.BLANK, "the first destroyed entry is blank")
	assert_eq(bm.die.faces[0].component, original.component, "and remembers what it was")
	assert_eq(bm.die.faces[1].kind, Face.Kind.BLANK, "the second too")
	assert_eq(bm.die.faces[1].component, gone.component, "and remembers what it was")
	assert_eq(bm.damaged_component_count(), 2, "two to repair")
	assert_eq(bm.damaged_faces[0].to_dict(), original.to_dict(), "the original kept for the hangar")
	assert_eq(bm.hull, 33, "hull as it was")
	assert_eq(bm.shield, 7, "shield as it was")
	assert_eq(bm.hull_max, m.hull_max, "the reward still counts")
	assert_eq(Effects.stacks_of(bm, "burning_mech"), 2, "the status and its stacks")
	Effects.turn_tick(bm)
	assert_eq(Effects.stacks_of(bm, "burning_mech"), 1, "Burning still loses a stack at the turn's end")
	assert_eq(Effects.stacks_of(bm, "scorched"), 0, "and Scorched every stack: each keeps its decay")
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


## The mines (the Lammergeier's) ride the save: each slot's shots in laid order, their
## keywords and spender, and the order count, so a resumed fight lands them alike.
func test_the_mines_survive_the_trip() -> void:
	var b := _battle(9)
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	m.grant_passive({"id": "bay", "name": "Bay", "description": "", "effects": [{"trigger": "static", "effect": "lay_mines"}]})
	var ms: Skirmish.MechState = sk.mechs[0]
	var gun := -1
	for i in range(ms.die.faces.size()):
		if ms.die.faces[i].is_attack() and ms.die.faces[i].power > 0:
			gun = i
	assert_true(gun >= 0, "the machine carries a gun")
	ms.face_index = gun
	var slot := Vector2i(-1, -1)
	for col in range(sk.columns):
		if sk.front[col] == null:
			slot = Vector2i(0, col)
	if slot.x < 0:
		sk.front[0].hp = 0
		sk._clear_dead()
		slot = Vector2i(0, 0)
	assert_true(sk.assign(0, slot), "a mine laid")
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	var sk2: Skirmish = back.current
	assert_eq(sk2.mines.keys(), sk.mines.keys(), "the mined slots")
	assert_eq(JSON.stringify(sk2.mines_at(slot)), JSON.stringify(sk.mines_at(slot)), "their shots")
	assert_eq(typeof(sk2.mines_at(slot)[0]["keywords"]), TYPE_ARRAY, "keywords as a list")
	assert_eq(sk2.mine_seq, sk.mine_seq, "the order count")


## The planner's copy (SaveGame.clone_skirmish, 22 October): every unit its own, the fight under
## way carried whole, so the copy plays on blow for blow as the original would, and playing it
## to its end touches nothing of the original's.
func test_a_clone_plays_on_alike_and_leaves_the_original_alone() -> void:
	var b := _battle(9)
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	var first := Policy.make(Policy.GREEDY, 3)
	first.play_round(sk)
	if sk.outcome == Skirmish.Outcome.NONE:
		sk.end_round()
	if sk.outcome == Skirmish.Outcome.NONE:
		sk.start_round()
	var c := SaveGame.clone_skirmish(sk)
	assert_eq(c.mechs.size(), sk.mechs.size(), "the machines")
	for i in range(sk.mechs.size()):
		assert_true(c.mechs[i].unit != sk.mechs[i].unit, "each machine the copy's own")
		assert_eq(c.mechs[i].unit.id, sk.mechs[i].unit.id, "of the same unit")
		assert_eq(c.mechs[i].face_index, sk.mechs[i].face_index, "the die showing")
	assert_eq(c.rng.state, sk.rng.state, "the random stream where it stood")
	assert_eq(c.field_foes().size(), sk.field_foes().size(), "the foes on the field")
	assert_eq(c.log.size(), 0, "and no log")
	var mark := sk.log.size()
	var stream := sk.rng.state
	var hull: Array = []
	for ms in sk.mechs:
		hull.append(ms.unit.hull)
	var hp: Array = []
	for f in sk.field_foes():
		hp.append(f.hp)
	var copy_pol := Policy.make(Policy.GREEDY, 11)
	if c.state == Skirmish.State.ASSIGN:
		copy_pol.play_round(c)
		if c.outcome == Skirmish.Outcome.NONE:
			c.end_round()
	if c.outcome == Skirmish.Outcome.NONE:
		copy_pol.play(c)
	assert_true(c.outcome != Skirmish.Outcome.NONE, "the copy was played to its end")
	assert_eq(sk.log.size(), mark, "the original's log untouched")
	assert_eq(sk.rng.state, stream, "its random stream")
	for i in range(sk.mechs.size()):
		assert_eq(sk.mechs[i].unit.hull, hull[i], "its machines' hull")
	var now: Array = []
	for f in sk.field_foes():
		now.append(f.hp)
	assert_eq(now, hp, "its foes' hit points")
	var pol := Policy.make(Policy.GREEDY, 11)
	if sk.state == Skirmish.State.ASSIGN:
		pol.play_round(sk)
		if sk.outcome == Skirmish.Outcome.NONE:
			sk.end_round()
	if sk.outcome == Skirmish.Outcome.NONE:
		pol.play(sk)
	assert_eq(sk.outcome, c.outcome, "the same outcome")
	assert_eq(sk.round, c.round, "in the same round")
	var tail := sk.log.slice(mark)
	assert_eq(tail.size(), c.log.size(), "the same log from the copy's start")
	for i in range(mini(tail.size(), c.log.size())):
		if tail[i] != c.log[i]:
			assert_eq(tail[i], c.log[i], "the logs agree at line %d" % i)
			break
	for i in range(sk.mechs.size()):
		assert_eq(c.mechs[i].unit.hull, sk.mechs[i].unit.hull, "%s's hull" % sk.mechs[i].unit.display_name)
		assert_eq(c.mechs[i].heat, sk.mechs[i].heat, "%s's heat" % sk.mechs[i].unit.display_name)


## A fight saved mid-turn keeps its undo (the snapshots ride in the save, JSON's way) and the
## trail's bars, and a foe's stun resist and a machine's overheat culprit come back with it.
func test_a_saved_fight_keeps_its_undo_its_bars_and_the_numbers_of_2_november() -> void:
	var b := _battle(9)
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.keeps_undo = true
	sk.begin()
	sk.start_round()
	var foe: Foe = sk.field_foes()[0]
	var slot := Vector2i(foe.rank, foe.column)
	for f in sk.field_foes():
		f.resist = 2   # every foe, since the spend below may fell the first
		f.elite = true
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = ms.heat_max + 5
	ms.hot_entry = 1
	var opened := sk.log.size()
	var spent := false
	for i in range(ms.die.faces.size()):
		ms.face_index = i
		var f := ms.face()
		if f == null or f.kind == Face.Kind.BLANK or f.disabled:
			continue
		if f.is_attack():
			var reached: Array[Foe] = sk.targets_for(0)
			spent = not reached.is_empty() and sk.assign(0, reached[0])
		else:
			spent = sk.assign(0, null)
		if spent:
			break
	assert_true(spent, "a die spent")
	assert_true(sk.can_undo(), "and can be taken back")
	var d: Dictionary = JSON.parse_string(JSON.stringify(SaveGame.to_dict(b)))
	var back := SaveGame.from_dict(d)
	var sk2: Skirmish = back.current
	assert_eq(sk2.roll_marks, sk.roll_marks, "the bars came back")
	assert_eq(sk2.mechs[0].hot_entry, 1, "the overheat's culprit came back")
	assert_eq([sk2.field_foes()[0].resist, sk2.field_foes()[0].elite], [2, true], "a foe's stun resist and its elite flag came back")
	assert_true(sk2.can_undo(), "the undo came back")
	assert_true(sk2.undo(), "and takes the spend back")
	assert_eq([sk2.mechs[0].assigned, sk2.log.size()], [false, opened], "the die unspent, the trail as the round opened")
	assert_eq(sk2.foe_at(slot.x, slot.y).resist, 2, "the snapshot carries the stun resist too")
	assert_eq(sk2.mechs[0].hot_entry, 1, "and the culprit")
	assert_false(sk2.can_undo(), "nothing more")

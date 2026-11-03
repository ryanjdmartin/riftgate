extends TestCase

## The slate's first bosses (30 October, on Ryan's word: "build what can be built"): the engine
## pieces they need (a follow-up move, a steal with its borrowed swing, a swallow) and the
## content's shape. Synthetic foes for the rules; the content read by its structure, never by id.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT


func _mech(name: String, d: Die, shield: int = 0, hull: int = 500) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _move(id: String, extra: Dictionary = {}) -> Dictionary:
	var a := {"id": id, "name": id.capitalize(), "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": ""}
	a.merge(extra, true)
	return a


## A matador's pair: a brace that names its flurry, the flurry never rolled on its own.
func _matador() -> Foe:
	var f := Foe.make("matador", 900, 10)
	f.actions = [_move("thrust"),
		{"id": "capote", "name": "Capote", "kind": "defend", "effect": "brace", "value": 3, "weight": 1, "then": "flurry", "text": ""},
		_move("flurry", {"strikes": 4, "factor": 0.5})]
	return f


func test_a_follow_up_comes_the_round_after_its_move_lands() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var m := _matador()
	sk.add_foes([m])
	sk.begin()
	sk.start_round()
	m.action = m.actions[1]   # the capote, announced
	m.last_special = "capote"
	sk.end_round()
	assert_eq(m.next_move, "flurry", "the capote landed and names its flurry")
	sk.start_round()
	assert_eq(str(m.action.get("id", "")), "flurry", "the flurry is the next round's intent")
	assert_eq(m.next_move, "", "and the pair is spent")
	sk.end_round()
	assert_eq(sk.mechs[0].unit.hull, 500 - 4 * 5, "four strikes of five")


func test_a_follow_up_never_comes_by_the_roll() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var m := _matador()
	sk.add_foes([m])
	sk.begin()
	sk.start_round()
	m.last_special = ""   # whatever it drew this round, a special may come again
	var ids: Array = sk.legal_actions(m).map(func(a): return str(a.get("id", "")))
	assert_false(ids.has("flurry"), "the flurry is not in the roll")
	assert_true(ids.has("thrust") and ids.has("capote"), "the rest are")
	for i in range(40):
		m.choose_from(sk.legal_actions(m), sk.rng)
		assert_ne(str(m.action.get("id", "")), "flurry", "never drawn alone")


func test_a_suppress_or_a_disrupt_on_the_first_move_breaks_the_pair() -> void:
	# Suppressed, the capote never lands, so the flurry never comes.
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var m := _matador()
	sk.add_foes([m])
	sk.begin()
	sk.start_round()
	m.action = m.actions[1]
	sk._suppress(m)
	sk.end_round()
	assert_eq(m.next_move, "", "a suppressed capote names nothing")
	# Disrupted, it turns to another move, which names nothing.
	var sk2 := Skirmish.new(2, 3)
	sk2.add_mech(_mech("A", Die.single(Face.blank())))
	var m2 := _matador()
	sk2.add_foes([m2])
	sk2.begin()
	sk2.start_round()
	m2.action = m2.actions[1]
	sk2._disrupt([m2])
	assert_ne(str(m2.action.get("id", "")), "capote", "the disrupt turns it")
	assert_ne(str(m2.action.get("id", "")), "flurry", "and never to its follow-up")
	sk2.end_round()
	assert_eq(m2.next_move, "", "so nothing follows")


## A collector's pair: a blow that steals, then the borrowed swing.
func _collector() -> Foe:
	var f := Foe.make("gilgamesh", 900, 10)
	f.actions = [_move("disarm", {"keywords": ["steal"], "then": "borrowed"}),
		_move("borrowed", {"power": "held"})]
	return f


func test_a_steal_takes_the_showing_entry_and_the_borrowed_swing_lands_its_number() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	var g := _collector()
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_eq(str(g.action.get("id", "")), "disarm", "the swing is never rolled: the steal comes first")
	sk.end_round()
	assert_eq(sk.mechs[0].unit.hull, 490, "the disarm lands its own blow")
	assert_eq(int(g.held.get("power", 0)), 30, "and takes the weapon's number")
	assert_false(bool(g.held.get("fake", true)), "a weapon is no fake")
	sk.start_round()
	assert_eq(str(g.action.get("id", "")), "borrowed", "the borrowed swing is next round's intent")
	assert_eq(g.damage(), 30, "at the stolen weapon's number")
	assert_eq(sk.mechs[0].face().describe(), "disabled", "the entry it took is switched off through the next turn")
	sk.end_round()
	assert_eq(sk.mechs[0].unit.hull, 460, "the swing lands thirty")
	assert_true(g.held.is_empty(), "and spends what it took")
	sk.start_round()
	assert_eq(sk.mechs[0].face().describe(), "30", "the entry is back the turn after")


func test_a_stolen_weapon_swings_at_its_number_and_anything_else_is_a_fake() -> void:
	assert_eq(Skirmish.stolen_number(Face.attack(5, L)), 5, "a flat five for five")
	assert_eq(Skirmish.stolen_number(Face.shield(8)), 1, "a shield is a fake, for one")
	assert_eq(Skirmish.stolen_number(Face.vent(6)), 1, "a vent too")
	assert_eq(Skirmish.stolen_number(Face.blank()), 1, "and a blank")
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.shield(8))))
	var g := _collector()
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_true(bool(g.held.get("fake", false)), "it took a shield: a fake")
	sk.start_round()
	assert_eq(g.damage(), 1, "swung for one")


func test_a_ward_turns_a_steal_away_and_with_nothing_taken_the_roll_decides() -> void:
	var sk := Skirmish.new(1, 3)
	var u := _mech("A", Die.single(Face.attack(30, L)))
	sk.add_mech(u)
	var g := _collector()
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.grant_buff(u, "ward", 1, "test", sk.round)
	sk.end_round()
	assert_eq(u.hull, 490, "the blow's damage lands through a Ward")
	assert_true(g.held.is_empty(), "but the Ward turns the steal away")
	sk.start_round()
	assert_eq(str(g.action.get("id", "")), "disarm", "nothing taken, no swing: the roll decides")


func test_a_swallow_takes_a_machine_out_of_the_fight_for_its_rounds() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(10, I)))
	var b := _mech("B", Die.single(Face.attack(10, I)))
	sk.add_mech(a)
	sk.add_mech(b)
	var flo := Foe.make("floraison", 900, 10)
	flo.actions = [{"id": "swallow", "name": "Swallow", "kind": "debuff", "effect": "swallow", "value": 2, "weight": 1, "text": ""}, _move("lash")]
	sk.add_foes([flo])
	sk.begin()
	sk.start_round()
	flo.action = flo.actions[0]
	flo.target = sk.mechs[0]
	sk.end_round()
	assert_true(Skirmish.is_swallowed(sk.mechs[0]), "A is swallowed")
	assert_true("\n".join(sk.log).contains("swallowed: out of the fight for 2 rounds"), "the log says for how long")
	sk.start_round()
	assert_true(sk.mechs[0].assigned, "it cannot act")
	assert_false(sk.can_spend(0), "its die is no spend")
	assert_eq(sk.targetable_mechs().size(), 1, "nobody may target it")
	assert_false(sk.machine_targets_for(sk.mechs[1], Face.shield(5)).has(sk.mechs[0]), "an ally cannot shield it")
	flo.action = flo.actions[1]
	flo.target = sk.mechs[0]
	sk.end_round()
	assert_eq(a.hull, 500, "a blow picked at it lands elsewhere")
	assert_eq(b.hull, 490, "on the next in line")
	sk.start_round()
	assert_true(Skirmish.is_swallowed(sk.mechs[0]), "still held in its second round")
	sk.end_round()
	sk.start_round()
	assert_false(Skirmish.is_swallowed(sk.mechs[0]), "back after two rounds")
	assert_true(sk.can_spend(0), "and acting")


func test_a_swallow_lets_go_when_its_swallower_falls_and_never_takes_the_last_machine() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(10, I)))
	var b := _mech("B", Die.single(Face.attack(50, I)))
	sk.add_mech(a)
	sk.add_mech(b)
	var flo := Foe.make("floraison", 40, 10)
	flo.actions = [{"id": "swallow", "name": "Swallow", "kind": "debuff", "effect": "swallow", "value": 3, "weight": 1, "text": ""}, _move("lash")]
	sk.add_foes([flo, Foe.make("revenant", 900, 1)])
	sk.begin()
	sk.start_round()
	flo.action = flo.actions[0]
	flo.target = sk.mechs[0]
	sk.end_round()
	assert_true(Skirmish.is_swallowed(sk.mechs[0]), "A is swallowed")
	var ids: Array = sk.legal_actions(flo).map(func(x): return str(x.get("id", "")))
	assert_false(ids.has("swallow"), "with one machine left able to act, no second swallow is drawn")
	sk.start_round()
	assert_true(sk.assign(1, flo), "B kills the swallower")
	assert_false(Skirmish.is_swallowed(sk.mechs[0]), "and A is let go at once")
	assert_true(sk.can_spend(0), "and acts this round")
	assert_true("\n".join(sk.log).contains("lets A go"), "the log says so")


func test_a_ward_turns_a_swallow_away() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.blank()))
	sk.add_mech(a)
	sk.add_mech(_mech("B", Die.single(Face.blank())))
	var flo := Foe.make("floraison", 900, 10)
	flo.actions = [{"id": "swallow", "name": "Swallow", "kind": "debuff", "effect": "swallow", "value": 2, "weight": 1, "text": ""}, _move("lash")]
	sk.add_foes([flo])
	sk.begin()
	sk.start_round()
	Effects.grant_buff(a, "ward", 1, "test", sk.round)
	flo.action = flo.actions[0]
	flo.target = sk.mechs[0]
	sk.end_round()
	assert_false(Skirmish.is_swallowed(sk.mechs[0]), "the Ward turns it away")


func test_a_save_keeps_a_follow_up_a_held_piece_and_a_swallow() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	sk.add_mech(_mech("B", Die.single(Face.blank())))
	var g := _collector()
	var flo := Foe.make("floraison", 900, 10)
	flo.actions = [{"id": "swallow", "name": "Swallow", "kind": "debuff", "effect": "swallow", "value": 2, "weight": 1, "text": ""}, _move("lash")]
	sk.add_foes([g, flo])
	sk.begin()
	sk.start_round()
	g.action = g.actions[0]
	g.target = sk.mechs[0]
	flo.action = flo.actions[0]
	flo.target = sk.mechs[1]
	sk.end_round()
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	var cg: Foe = null
	for f in copy.field_foes():
		if f.display_name == "gilgamesh":
			cg = f
	assert_eq(cg.next_move, "borrowed", "the follow-up survives a save")
	assert_eq(int(cg.held.get("power", 0)), 30, "and what it took")
	assert_true(Skirmish.is_swallowed(copy.mechs[1]), "and a swallowed machine")


## The content: the slate's bosses are whole, by their structure (30 October).
func test_the_slates_bosses_are_whole_in_content() -> void:
	var db := ContentDB.load_default()
	assert_true(db.validate().is_empty(), "the content validates")
	var bosses := 0
	for fid in db.factions.keys():
		var list := db.bosses_of(str(fid))
		assert_true(list.size() >= 2, "%s fields two bosses at least while the slate fills" % fid)
		for b in list:
			bosses += 1
			var acts: Array = db.foes[b].get("actions", []).filter(func(a): return str(a.get("status", "")) == "implemented")
			assert_eq(acts.size(), 3, "%s carries three moves" % b)
			var opens := acts.any(func(a): return a.has("when")) or not Foe.follow_ups(acts).is_empty()
			assert_true(opens, "%s's third opens on a condition or follows another" % b)
	assert_true(bosses >= 11, "the slate's seven beside the four stand-ins")
	for id in db.foes.keys():
		for a in db.foes[id].get("actions", []):
			if a.has("then"):
				var ids: Array = db.foes[id]["actions"].map(func(x): return str(x.get("id", "")))
				assert_true(ids.has(str(a["then"])), "%s's follow-up is its own move" % id)


func test_a_core_in_parts_from_content_stands_guarded_until_an_eye_falls() -> void:
	var db := ContentDB.load_default()
	var core_id := ""
	for id in db.foes.keys():
		if db.foes[id].has("parts") and db.is_boss(str(id)):
			core_id = str(id)
	assert_ne(core_id, "", "a boss in parts is in content")
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(60, I))))
	var core := db.make_foe(core_id)
	var parts := db.parts_for(core)
	assert_eq(parts.size(), Array(db.foes[core_id]["parts"]).size(), "every part stands with it")
	var all: Array = [core]
	all.append_array(parts)
	sk.add_foes(all)
	sk.begin()
	assert_true(Effects.has(core, "guarded"), "the core is Guarded while its parts stand")
	sk.start_round()
	assert_true(sk.assign(0, parts[0]), "a part falls")
	assert_false(Effects.has(core, "guarded"), "and the core is open")


func test_a_last_act_at_every_machine_in_content_lands_on_each() -> void:
	var db := ContentDB.load_default()
	var beast_id := ""
	for id in db.foes.keys():
		var od = db.foes[id].get("on_death", {})
		if od is Dictionary and od.get("blow", null) is Dictionary and Array(od["blow"].get("keywords", [])).has("all"):
			beast_id = str(id)
	assert_ne(beast_id, "", "a last act at every machine is in content")
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(900, I)))
	var b := _mech("B", Die.single(Face.blank()))
	sk.add_mech(a)
	sk.add_mech(b)
	var beast := db.make_foe(beast_id)
	sk.add_foes([beast])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, beast), "it falls")
	assert_true(a.hull < 500 and b.hull < 500, "its last act lands on every machine")
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "as the fight is won")


func test_the_validator_refuses_a_broken_follow_up_a_loose_swing_and_a_long_swallow() -> void:
	var db := ContentDB.new()   # a copy of its own: the shared content is never written to
	db.load_dir(ContentDB.DIR)
	db.foes["x_test"] = {"id": "x_test", "name": "X", "faction": "meadow", "hp": 9, "attack": 3, "codex": "", "flavour": "", "design": {},
		"actions": [{"id": "a", "name": "A", "kind": "attack", "then": "nowhere", "text": "", "status": "implemented"},
			{"id": "b", "name": "B", "kind": "attack", "power": "held", "text": "", "status": "implemented"},
			{"id": "c", "name": "C", "kind": "debuff", "effect": "swallow", "value": 4, "text": "", "status": "implemented"},
			{"id": "d", "name": "D", "kind": "attack", "power": "borrowed", "text": "", "status": "implemented"}]}
	var errs: Array = db.validate().filter(func(e) -> bool: return e.contains("x_test"))
	assert_true(errs.any(func(e) -> bool: return e.contains("then names 'nowhere'")), "a follow-up must be a move of its own")
	assert_true(errs.any(func(e) -> bool: return e.contains("a borrowed swing (power held) is the follow-up of a blow that steals")), "a borrowed swing must follow a steal")
	assert_true(errs.any(func(e) -> bool: return e.contains("a swallow's value is the rounds its machine is out, 1 to 3")), "a swallow is held short")
	assert_true(errs.any(func(e) -> bool: return e.contains("the one word it knows is held")), "power knows one word")


func test_the_harness_fields_the_boss_it_picks_whichever_of_its_domains() -> void:
	var db := ContentDB.load_default()
	var fid := ""
	for f in db.factions.keys():
		if db.bosses_of(str(f)).size() >= 2:
			fid = str(f)
	assert_ne(fid, "", "a domain lists two bosses or more")
	var second := str(db.bosses_of(fid)[1])
	var s := HarnessSetup.defaults(db)
	s.use_faction(fid)
	s.boss = second
	var b := s.make_battle()
	assert_eq(str(b.boss.lineup[0]), second, "the battle's boss unit is the one picked")
	var sk := s.make_skirmish()
	var named := false
	for f in sk.reinforcements:
		if f.commands and f.content_id == second:
			named = true
	assert_true(named, "and so is the skirmish's")


func test_the_codex_says_a_follow_up_pair_and_a_borrowed_swing() -> void:
	var db := ContentDB.load_default()
	var m := _matador()
	var lines: Array = EntryReadout.move_lines(m, m.actions[1], db)
	assert_true(lines.any(func(l) -> bool: return str(l.get("text", "")) == "Then Flurry, next round"), "the first says what follows")
	lines = EntryReadout.move_lines(m, m.actions[2], db)
	assert_true(lines.any(func(l) -> bool: return str(l.get("text", "")) == "Only after Capote"), "the second says it comes only after")
	var g := _collector()
	lines = EntryReadout.move_lines(g, g.actions[1], db)
	assert_true(str(lines[1].get("parts", [{}])[0].get("text", "")) == "Attack: what it took", "a borrowed swing says its number is what it took")
	g.held = {"name": "gun", "power": 6, "fake": false}
	lines = EntryReadout.move_lines(g, g.actions[1], db, true)
	assert_false(str(lines[1].get("parts", [{}])[0].get("text", "")) == "Attack: what it took", "held, the intent shows the number")

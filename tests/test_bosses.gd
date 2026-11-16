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


## An announced follow-up is committed (Ryan, 2 November: "cannot be Disrupted"): a Disrupt on
## the flurry's round turns nothing, the die's gate shuts the keyword over it, the bot values it
## at nothing and a save keeps it, while a Suppress still takes the move; the first move stays
## the window, a Disrupt on the capote's round turning it as before, so no flurry comes.
func test_an_announced_follow_up_cannot_be_disrupted_and_a_suppress_still_takes_it() -> void:
	var probe := Face.attack(0, I, [Face.Keyword.DISRUPT])
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(probe)))
	var m := _matador()
	sk.add_foes([m])
	sk.begin()
	sk.start_round()
	m.action = m.actions[1]   # the capote, announced
	m.last_special = "capote"
	sk.end_round()
	sk.start_round()
	assert_eq(str(m.action.get("id", "")), "flurry", "the flurry is announced")
	assert_true(m.committed, "and committed")
	assert_true(sk.shut_gates(sk.mechs[0], probe, m).has(Face.Keyword.DISRUPT), "the Disrupt's chip is struck over it")
	assert_eq(Policy.disrupt_score(sk, m), 0.0, "the bot values the disrupt at nothing")
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	assert_true(copy.field_foes()[0].committed, "a save keeps it")
	assert_true(sk.assign(0, m), "the Disrupt is spent on it")
	assert_eq(str(m.action.get("id", "")), "flurry", "and the flurry holds")
	assert_true("\n".join(sk.log).contains("committed to"), "the log says so")
	sk.end_round()
	assert_eq(sk.mechs[0].unit.hull, 500 - 4 * 5, "four strikes of five land")
	sk.start_round()
	assert_false(m.committed, "the next round's pick is its own again")
	# A Suppress still takes the announced flurry.
	var sk2 := Skirmish.new(1, 3)
	sk2.add_mech(_mech("A", Die.single(Face.attack(0, I, [Face.Keyword.SUPPRESS]))))
	var m2 := _matador()
	sk2.add_foes([m2])
	sk2.begin()
	sk2.start_round()
	m2.action = m2.actions[1]
	m2.last_special = "capote"
	sk2.end_round()
	sk2.start_round()
	assert_true(m2.committed, "the flurry is committed")
	assert_true(sk2.assign(0, m2), "the Suppress is spent on it")
	assert_true(m2.is_suppressed(), "and takes it")
	sk2.end_round()
	assert_eq(sk2.mechs[0].unit.hull, 500, "no strike lands")
	# The first move stays the window: a Disrupt on the capote's round turns it.
	var sk3 := Skirmish.new(1, 3)
	sk3.add_mech(_mech("A", Die.single(Face.attack(0, I, [Face.Keyword.DISRUPT]))))
	var m3 := _matador()
	sk3.add_foes([m3])
	sk3.begin()
	sk3.start_round()
	m3.action = m3.actions[1]
	m3.last_special = "capote"
	assert_false(m3.committed, "the capote is the roll's, not committed")
	assert_true(sk3.assign(0, m3), "the Disrupt is spent on the capote's round")
	assert_true(str(m3.action.get("id", "")) != "capote", "and turns it")
	sk3.end_round()
	assert_eq(m3.next_move, "", "so no flurry is named")


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


## The content: the slate's bosses are whole, by their structure (30 October): three a domain,
## each with three moves, and the massive foes that stood in for them in the rank and file.
func test_the_slates_bosses_are_whole_in_content() -> void:
	var db := ContentDB.load_default()
	assert_true(db.validate().is_empty(), "the content validates")
	var bosses := 0
	for fid in db.factions.keys():
		var list := db.bosses_of(str(fid))
		# Three a domain is the bible's floor and more are welcome (Ryan, 3 November); the Meadow's
		# and the Waste's third wait on his pick since the Malboro and the Tonberry left the lists.
		assert_true(list.size() >= 2, "%s fields two bosses of its own at least" % fid)
		for b in list:
			bosses += 1
			assert_false(bool(db.foes[b].get("elite", false)), "%s is no elite" % b)
			var acts: Array = db.foes[b].get("actions", []).filter(func(a): return str(a.get("status", "")) == "implemented")
			assert_eq(acts.size(), 3, "%s carries three moves" % b)
			var opens := acts.any(func(a): return a.has("when")) or not Foe.follow_ups(acts).is_empty()
			assert_true(opens, "%s's third opens on a condition or follows another" % b)
	assert_true(bosses >= 10, "the slate's ten at least")
	# A massive foe that is no boss, no elite, no hero and no part stands in a domain's ranks.
	var parts: Array = []
	for id in db.foes.keys():
		parts.append_array(Array(db.foes[id].get("parts", [])))
	for id in db.foes.keys():
		var f: Dictionary = db.foes[id]
		if int(f.get("size", 1)) < 2 or db.is_boss(str(id)) or db.is_elite(str(id)) or bool(f.get("hero", false)) or f.has("promotes") or parts.has(id):
			continue
		var ranked := false
		for c in db.factions.get(str(f.get("faction", "")), {}).get("compositions", []):
			if ["formation", "patrol"].has(str(c.get("size", ""))) and (Array(c.get("front", [])) + Array(c.get("back", []))).has(str(id)):
				ranked = true
		assert_true(ranked, "%s, massive rank and file, stands in its domain's ranks" % id)
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
	s.battle_faction = fid
	s.battle_boss = second
	var b := s.make_battle()
	assert_eq(str(b.boss.lineup[0]), second, "the battle's boss unit is the one picked")
	s.use_faction(fid)
	s.boss = second
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



# ---------------------------------------------------------------- the slate's last five (30 October)

## Gels for a merge, their kind named as content names a foe.
func _gels(n: int, hp: int = 5) -> Array:
	var out: Array = []
	for i in range(n):
		var g := Foe.make("gel", hp, 2)
		g.content_id = "gel"
		out.append(g)
	return out


## A king that takes its Gels in.
func _king() -> Foe:
	var k := Foe.make("king", 90, 6)
	k.content_id = "king"
	k.actions = [_move("slam"), {"id": "merge", "name": "Merge", "kind": "buff", "effect": "merge", "foe": ["gel"], "value": 1, "weight": 1, "text": ""}]
	return k


func test_a_merge_takes_its_kinds_in_and_regrows_what_they_had() -> void:
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var k := _king()
	k.hp = 40
	var gels := _gels(3)
	gels[0].hp = 3
	sk.add_foes([k] + gels)
	sk.begin()
	sk.start_round()
	k.action = k.actions[1]
	k.last_special = "merge"
	sk.end_round()
	assert_eq(k.hp, 40 + 3 + 5 + 5, "it regrows the HP they had left")
	for g in gels:
		assert_false(sk.field_foes().has(g), "each Gel is gone from the field")
	assert_eq(sk.team_kills, 0, "and none is a kill of the team's")
	assert_eq(k.damage_of(k.actions[0]), 6 + 1, "a point of Empowered for each, three, halved to one as its own turn ends (16 November: gained in its turn, like a rallier's share)")
	assert_true("\n".join(sk.log).contains("3 taken in"), "the log says how many")


func test_a_merge_with_nothing_to_take_in_is_never_drawn() -> void:
	var lone := Skirmish.new(1, 4)
	lone.add_mech(_mech("A", Die.single(Face.blank())))
	var k := _king()
	lone.add_foes([k])
	lone.begin()
	var ids: Array = lone.legal_actions(k).map(func(x): return str(x.get("id", "")))
	assert_false(ids.has("merge"), "no Gel stands: no merge")
	var court := Skirmish.new(1, 4)
	court.add_mech(_mech("A", Die.single(Face.blank())))
	var k2 := _king()
	court.add_foes([k2] + _gels(1))
	court.begin()
	ids = court.legal_actions(k2).map(func(x): return str(x.get("id", "")))
	assert_true(ids.has("merge"), "a Gel stands: the merge may come")


## A drain regrows what the blow took from the hull, so the shield starves it.
func test_a_drain_regrows_what_the_blow_took_from_the_hull_and_no_more() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.blank()), 4, 500)
	var b := _mech("B", Die.single(Face.blank()), 0, 3)
	sk.add_mech(a)
	sk.add_mech(b)
	var v := Foe.make("lord", 40, 10)
	v.hp = 10
	v.drains = true   # its own Ability, every blow's (16 November); a rider on the blow until then
	v.actions = [_move("drain")]
	v.action = v.actions[0]
	sk.add_foes([v])
	sk.begin()
	sk.start_round()
	v.action = v.actions[0]
	v.target = sk.mechs[0]
	sk.end_round()
	assert_eq(a.shield, 0, "the shield takes four")
	assert_eq(a.hull, 494, "the hull six")
	assert_eq(v.hp, 16, "it regrows the six it took from the hull, the shield's four none")
	sk.start_round()
	v.action = v.actions[0]
	v.target = sk.mechs[1]
	sk.end_round()
	assert_eq(v.hp, 19, "a machine with three hull left gives three")


## A Barrier's blow deals nothing, so it drains nothing; a Ward turns no drain away, since it lays
## nothing on the machine.
func test_a_barrier_drains_nothing_and_a_ward_turns_no_drain_away() -> void:
	var sk := Skirmish.new(1, 3)
	var u := _mech("A", Die.single(Face.blank()))
	sk.add_mech(u)
	var v := Foe.make("lord", 40, 10)
	v.hp = 10
	v.drains = true
	v.actions = [{"id": "drain", "name": "Drain", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": ""}]
	v.action = v.actions[0]
	sk.add_foes([v])
	sk.begin()
	sk.start_round()
	Effects.grant_buff(u, "barrier", 1, "test", sk.round)
	Effects.grant_buff(u, "ward", 1, "test", sk.round)
	v.action = v.actions[0]
	v.target = sk.mechs[0]
	sk.end_round()
	assert_eq(v.hp, 10, "a blow the Barrier takes drains nothing")
	sk.start_round()
	Effects.grant_buff(u, "ward", 1, "test", sk.round)
	v.action = v.actions[0]
	v.target = sk.mechs[0]
	sk.end_round()
	assert_eq(v.hp, 20, "and a Ward turns no drain away")


## The drain is its foe's own Ability since 16 November (Ryan, 15 November: "This should be moved
## to an ability on the unit since it's on every attack. Like the Nob"): every blow of its own,
## whatever the move, and no rider on any; a save keeps it, and a blow no longer knows the word.
func test_the_drain_is_its_foes_own_ability_on_every_blow() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	sk.add_mech(_mech("B", Die.single(Face.blank())))
	var v := Foe.make("lord", 40, 10)
	v.hp = 10
	v.drains = true
	v.actions = [_move("bite"), _move("feast", {"keywords": ["all"], "factor": 0.5})]
	v.action = v.actions[0]
	sk.add_foes([v])
	sk.begin()
	sk.start_round()
	v.action = v.actions[1]
	v.target = sk.mechs[0]
	sk.end_round()
	assert_eq(v.hp, 20, "a blow at every machine drains each: five and five")
	assert_true(SaveGame.clone_skirmish(sk).field_foes()[0].drains, "a copy of the fight keeps the Ability")
	assert_false(Foe.ATTACK_KEYWORDS.has("drain"), "and no blow carries the word: the rider left with its last carrier")
	# The validator: the old rider is unknown, and the key is true or left out.
	var db := ContentDB.new()   # a copy of its own: the shared content is never written to
	db.load_dir(ContentDB.DIR)
	db.foes["x_test"] = {"id": "x_test", "name": "X", "faction": "meadow", "hp": 9, "attack": 3, "codex": "", "flavour": "", "design": {}, "drains": 2,
		"actions": [{"id": "a", "name": "A", "kind": "attack", "keywords": ["drain"], "text": "", "status": "implemented"}]}
	var errs: Array = db.validate().filter(func(e) -> bool: return e.contains("x_test"))
	assert_true(errs.any(func(e) -> bool: return e.contains("unknown attack keyword 'drain'")), "a drain on a blow is refused")
	assert_true(errs.any(func(e) -> bool: return e.contains("drains is true or left out")), "and the key is a yes or nothing")
	# Content as shipped, read by its structure: whoever drains does so by the key.
	var shipped := ContentDB.load_default()
	var drainers := 0
	for fid in shipped.foes.keys():
		if bool(shipped.foes[fid].get("drains", false)):
			drainers += 1
			assert_true(shipped.make_foe(str(fid)).drains, "%s: the Ability reaches the foe as it is made" % fid)
	assert_true(drainers >= 1, "a foe in content carries it, or the Ability leaves the engine with its last carrier")


func test_a_grudge_grows_with_the_teams_kills_and_a_burst_is_none() -> void:
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("A", Die.single(Face.attack(50, I))))
	var p := Foe.make("pilgrim", 900, 6)
	p.actions = [_move("karma", {"per_kill": 1})]
	p.action = p.actions[0]
	var fodder := Foe.make("revenant", 3, 1)
	var bomb := Foe.make("bomb", 900, 1)
	bomb.actions = [_move("burst", {"keywords": ["self_destruct"]})]
	bomb.action = bomb.actions[0]
	sk.add_foes([p, fodder, bomb])
	sk.begin()
	sk.start_round()
	assert_eq(sk.foe_blow(p), 6, "no kills: its own number")
	assert_true(sk.assign(0, fodder), "the team kills one")
	assert_eq(sk.team_kills, 1, "the fight counts it")
	assert_eq(sk.foe_blow(p), 7, "a point heavier, shown at once")
	bomb.action = bomb.actions[0]
	bomb.target = sk.mechs[0]
	sk.end_round()
	assert_false(bomb.alive(), "the bomb bursts")
	assert_eq(sk.team_kills, 1, "and a burst is no kill of the team's")


func test_a_move_may_open_once_a_part_has_fallen() -> void:
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("A", Die.single(Face.attack(50, I))))
	var core := Foe.make("tyrant", 900, 8)
	core.content_id = "tyrant"
	core.part_ids = ["rider"]
	core.guard = "all"
	core.actions = [_move("crunch"), _move("firestorm", {"countdown": 5, "keywords": ["all"], "when": ["part_fallen"]})]
	var rider := Foe.make("rider", 10, 3, true)
	rider.content_id = "rider"
	sk.add_foes([core, rider])
	sk.begin()
	assert_eq(sk.parts_down(core), 0, "its rider stands")
	var ids: Array = sk.legal_actions(core).map(func(x): return str(x.get("id", "")))
	assert_false(ids.has("firestorm"), "and the firestorm waits")
	sk.start_round()
	assert_true(sk.assign(0, rider), "the rider falls")
	assert_eq(sk.parts_down(core), 1, "a part is down")
	ids = sk.legal_actions(core).map(func(x): return str(x.get("id", "")))
	assert_true(ids.has("firestorm"), "the firestorm opens")


func test_a_move_marked_once_is_used_once_a_fight() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var v := Foe.make("lord", 40, 6)
	v.actions = [_move("bite"), {"id": "undying", "name": "Undying", "kind": "buff", "effect": "revive_once", "once": true, "weight": 1, "text": ""}]
	sk.add_foes([v])
	sk.begin()
	var ids: Array = sk.legal_actions(v).map(func(x): return str(x.get("id", "")))
	assert_true(ids.has("undying"), "it may ready itself")
	sk.start_round()
	v.action = v.actions[1]
	v.last_special = "undying"
	sk.end_round()
	assert_true(Effects.has(v, "risen"), "it is readied")
	v.last_special = ""
	ids = sk.legal_actions(v).map(func(x): return str(x.get("id", "")))
	assert_false(ids.has("undying"), "and never again this fight")


## The stun resist by kind (Ryan, 3 November: "1 small, 2 massive, 3 for elites and bosses"): a
## boss of any size and whoever commands a boss unit (a final's hero, the finale's line) recover
## with three, a massive foe with two, the rest with one; content's `resist` overrides.
func test_a_boss_recovers_with_three_numbed_whatever_its_size() -> void:
	var boss := Foe.make("boss", 50, 5)
	boss.boss = true
	var hero := Foe.make("hero", 20, 8)
	hero.commands = true
	var big := Foe.make("big", 30, 7)
	big.size = 2
	var grunt := Foe.make("grunt", 5, 2)
	assert_eq(boss.stun_resist(), 3, "a human-sized boss recovers with three")
	assert_eq(hero.stun_resist(), 3, "so does a final's hero, the boss of its battle")
	assert_eq(big.stun_resist(), 2, "a massive foe with two")
	assert_eq(grunt.stun_resist(), 1, "the rest with one")


func test_a_save_keeps_a_grudge_a_move_used_once_and_the_teams_kills() -> void:
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("A", Die.single(Face.attack(50, I))))
	var p := Foe.make("pilgrim", 900, 6)
	p.actions = [_move("karma", {"per_kill": 1}), {"id": "undying", "name": "Undying", "kind": "buff", "effect": "revive_once", "once": true, "weight": 1, "text": ""}]
	var fodder := Foe.make("revenant", 3, 1)
	sk.add_foes([p, fodder])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, fodder), "a kill")
	p.action = p.actions[1]
	p.last_special = "undying"
	sk.end_round()
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	assert_eq(copy.team_kills, 1, "the team's kills survive a save")
	var cp: Foe = copy.field_foes()[0]
	assert_eq(cp.grudge, 1, "and the grudge")
	assert_true(cp.spent_once.has("undying"), "and a move used once")


## The content's side (30 October): an escort that names its boss is that boss's alone, and a
## boss that merges finds its kinds in its own escort.
func test_an_escort_that_names_its_boss_is_that_bosss_alone() -> void:
	var db := ContentDB.load_default()
	var found := false
	for fid in db.factions.keys():
		for c in db.factions[fid].get("compositions", []):
			if str(c.get("size", "")) != "escort" or not c.has("boss"):
				continue
			found = true
			var b := str(c["boss"])
			var t := int(ContentDB.composition_tiers(c)[0])
			var own := db.escort_composition(str(fid), t, b)
			assert_eq(str(own.get("boss", "")), b, "%s's own escort at tier %d" % [b, t])
			for other in db.bosses_of(str(fid)):
				if other != b:
					assert_ne(str(db.escort_composition(str(fid), t, other).get("boss", "")), b, "never %s's" % other)
	assert_true(found, "an escort that names its boss is in content")
	for id in db.foes.keys():
		if not db.is_boss(str(id)):
			continue
		for a in db.foes[id].get("actions", []):
			if str(a.get("effect", "")) != "merge":
				continue
			var esc := db.escort_composition(db.faction_of_foe(str(id)), 1, str(id))
			var kinds := Foe.kinds_named(a)
			assert_true(Array(esc.get("members", [])).any(func(m): return kinds.has(str(m[0]))), "%s's own escort brings what it merges" % id)


func test_the_harness_fields_a_bosss_own_escort() -> void:
	var db := ContentDB.load_default()
	var boss_id := ""
	for fid in db.factions.keys():
		for c in db.factions[fid].get("compositions", []):
			if str(c.get("size", "")) == "escort" and c.has("boss") and ContentDB.composition_tiers(c).has(1):
				boss_id = str(c["boss"])
	assert_ne(boss_id, "", "a boss with its own tier-one escort is in content")
	var s := HarnessSetup.defaults(db)
	s.packs = []
	s.boss = boss_id
	var sk := s.make_skirmish()
	var esc := db.escort_composition(db.faction_of_foe(boss_id), 1, boss_id)
	var want := 1 + Array(db.foes[boss_id].get("parts", [])).size()   # the boss and its parts
	for m in esc["members"]:
		want += int(m[1])
	assert_eq(sk.field_foes().size() + sk.reinforcements.size(), want, "the boss, its parts and its own escort")


## A boss whose kit is armour grows it by its step a tier above one, from a lighter start (Ryan,
## 31 October: "just the ones that have it"); a boss with no step keeps its armour at every tier.
func test_a_boss_grows_its_armour_by_its_step_a_tier() -> void:
	var db := ContentDB.load_default()
	for t in range(ContentDB.BOSS_TIERS.size()):
		var plated := Foe.make("shell", 48, 7)
		plated.armour = 1
		plated.armour_step = 1
		db.scale_boss(plated, t)
		assert_eq(plated.armour, 1 + t, "tier %d: a point a tier above one" % (t + 1))
		var plain := Foe.make("plain", 48, 7)
		plain.armour = 1
		db.scale_boss(plain, t)
		assert_eq(plain.armour, 1, "tier %d: no step, the same armour" % (t + 1))
	for id in db.foes.keys():
		if int(db.foes[id].get("armour_step", 0)) > 0:
			var f := db.make_foe(str(id))
			assert_eq(f.armour_step, int(db.foes[id]["armour_step"]), "%s carries its step from content" % id)


func test_the_validator_holds_an_armour_step_to_the_foes_that_scale() -> void:
	var db := ContentDB.new()   # a copy of its own: the shared content is never written to
	db.load_dir(ContentDB.DIR)
	db.foes["x_step"] = {"id": "x_step", "name": "X", "faction": "meadow", "hp": 9, "attack": 3, "armour_step": 1, "codex": "", "flavour": "", "design": {},
		"actions": [{"id": "a", "name": "A", "kind": "attack", "text": "", "status": "implemented"}]}
	db.foes["x_zero"] = {"id": "x_zero", "name": "Z", "faction": "meadow", "hp": 9, "attack": 3, "hero": true, "armour_step": 0, "codex": "", "flavour": "", "design": {},
		"actions": [{"id": "a", "name": "A", "kind": "attack", "text": "", "status": "implemented"}]}
	var errs: Array = db.validate()
	assert_true(errs.any(func(e) -> bool: return e.contains("x_step") and e.contains("only on a foe that scales with the tier")), "the rank and file never step")
	assert_true(errs.any(func(e) -> bool: return e.contains("x_zero") and e.contains("at least 1")), "a step is at least a point")


## A swallower that has lost a quarter of its HP since the swallow lets its machine go at once,
## and the machine acts that round (Ryan, 31 October); less than a quarter, it holds on, its chip
## counting the damage still to deal; a save keeps the count.
func test_a_swallow_lets_go_once_its_swallower_loses_a_quarter_of_its_hp() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(6, I)))
	var b := _mech("B", Die.single(Face.attack(6, I)))
	sk.add_mech(a)
	sk.add_mech(b)
	var flo := Foe.make("floraison", 40, 10)
	flo.actions = [{"id": "swallow", "name": "Swallow", "kind": "debuff", "effect": "swallow", "value": 3, "weight": 1, "text": ""}, _move("lash")]
	sk.add_foes([flo])
	sk.begin()
	sk.start_round()
	flo.action = flo.actions[0]
	flo.target = sk.mechs[0]
	sk.end_round()
	assert_true(Skirmish.is_swallowed(sk.mechs[0]), "A is swallowed")
	assert_eq(flo.swallow_mark, 40, "the swallower marks its HP as it swallows")
	assert_eq(Skirmish.swallow_left(flo), 10, "a quarter of its 40 to deal")
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	assert_eq(copy.field_foes()[0].swallow_mark, 40, "a save keeps the mark")
	sk.start_round()
	assert_true(sk.assign(1, flo), "B strikes for 6")
	assert_true(Skirmish.is_swallowed(sk.mechs[0]), "short of a quarter, it holds on")
	assert_eq(Skirmish.swallow_left(flo), 4, "four still to deal")
	assert_eq(sk.swallowed_by(flo), sk.mechs[0], "and it holds A")
	flo.action = flo.actions[1]
	flo.target = sk.mechs[1]
	sk.end_round()
	sk.start_round()
	assert_true(Skirmish.is_swallowed(sk.mechs[0]), "still held in its swallow's next round")
	assert_true(sk.assign(1, flo), "B strikes again")
	assert_false(Skirmish.is_swallowed(sk.mechs[0]), "a quarter lost: A is let go at once")
	assert_true(sk.can_spend(0), "and acts this round")
	assert_eq(flo.swallow_mark, -1, "the swallower holds nothing")
	assert_true("\n".join(sk.log).contains("reels, and lets A go"), "the log says so")


## A second machine swallowed while the first is held joins the first's count (the review of
## 2 November): the mark stays the first swallow's, so the release the chip promised never moves
## back, and a quarter lost since lets every machine it holds go. The chip never asks for more
## damage than the swallower has left.
func test_a_second_swallow_keeps_the_first_release() -> void:
	var sk := Skirmish.new(1, 3)
	for n in ["A", "B", "C"]:
		sk.add_mech(_mech(n, Die.single(Face.attack(6, I))))
	var flo := Foe.make("floraison", 40, 10)
	flo.actions = [{"id": "swallow", "name": "Swallow", "kind": "debuff", "effect": "swallow", "value": 3, "weight": 1, "text": ""}, _move("lash")]
	sk.add_foes([flo])
	sk.begin()
	sk.start_round()
	flo.action = flo.actions[0]
	flo.target = sk.mechs[0]
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(2, flo), "C strikes for 6")
	assert_eq(Skirmish.swallow_left(flo), 4, "four still to deal")
	flo.action = flo.actions[0]
	flo.target = sk.mechs[1]
	sk.end_round()
	assert_true(Skirmish.is_swallowed(sk.mechs[1]), "B is swallowed too")
	assert_eq(flo.swallow_mark, 40, "the first swallow's mark stands")
	assert_eq(Skirmish.swallow_left(flo), 4, "and the chip still says four")
	sk.start_round()
	assert_true(sk.assign(2, flo), "C strikes again")
	assert_false(Skirmish.is_swallowed(sk.mechs[0]), "a quarter lost: A is let go")
	assert_false(Skirmish.is_swallowed(sk.mechs[1]), "and B with it")
	assert_eq(flo.swallow_mark, -1, "the swallower holds nothing")
	flo.hp = 8
	flo.swallow_mark = 8
	assert_eq(Skirmish.swallow_left(flo), 8, "under a quarter already, the chip asks for what it has, no more")


## The wandering elite (31 October: Gilgamesh; 2 November, Ryan: a wanderer never waits for a
## domain's own to run out, and an elite may come again in a later battle): one composition in
## one domain's list is every domain's by ContentDB.next_elite, the domain's next own on a high
## roll, a wanderer on a roll under WANDER_CHANCE, always once the own are spent, nothing twice
## in a battle; it stands at the battle's tier as a boss does, as every elite does since
## 2 November.
func test_a_wandering_elite_walks_out_of_every_domain_at_the_tier() -> void:
	var db := ContentDB.load_default()
	var wanderers: Array = []
	for id in db.foes.keys():
		if bool(db.foes[id].get("wanders", false)):
			wanderers.append(str(id))
	assert_false(wanderers.is_empty(), "a wanderer is in content")
	for w in wanderers:
		assert_true(db.is_elite(str(w)), "%s is an elite" % w)
		assert_false(db.is_boss(str(w)), "and no domain's boss")
	for t in [1, 2, 3]:
		var pool := db.wandering_compositions(t)
		assert_false(pool.is_empty(), "a wanderer walks at tier %d" % t)
		var ids: Array = pool.map(func(c) -> String: return str(c["id"]))
		for fid in db.factions.keys():
			var own := db.elite_compositions(str(fid), t)
			for c in own:
				assert_false(ids.has(str(c["id"])), "%s's own elites hold no wanderer" % fid)
			var sent: Array = []
			var first := db.next_elite(str(fid), t, sent, 0.99)
			assert_false(first.is_empty(), "%s sends an elite at tier %d" % [fid, t])
			if own.is_empty():
				assert_true(ids.has(str(first["id"])), "%s, with none of its own, sends a wanderer" % fid)
			else:
				assert_eq(str(first["id"]), str(own[0]["id"]), "%s's first own on a high roll" % fid)
				assert_true(ids.has(str(db.next_elite(str(fid), t, sent, 0.0)["id"])), "a wanderer on a low roll")
				for c in own:
					sent.append(str(c["id"]))
				assert_true(ids.has(str(db.next_elite(str(fid), t, sent, 0.99)["id"])), "and once its own are spent, whatever the roll")
			for c in pool:
				sent.append(str(c["id"]))
			for c in own:
				if not sent.has(str(c["id"])):
					sent.append(str(c["id"]))
			assert_true(db.next_elite(str(fid), t, sent, 0.0).is_empty(), "nothing twice in one battle")
			assert_eq(str(db.elite_composition(str(fid), t, str(pool[0]["id"]))["id"]), str(pool[0]["id"]), "a wanderer found by id from any domain")
	var w := str(wanderers[0])
	var base := db.make_foe(w)
	for t in range(ContentDB.BOSS_TIERS.size()):
		var sq := Unit.pack(0, "", Vector2i.ZERO, str(db.factions.keys()[0]), Unit.PACK_MOVE, 0, w)
		sq.set_members([[w, 1]])
		sq.boss_tier = t
		var made := db.foes_for(sq)
		var s := ContentDB.boss_tier(t)
		assert_eq(made[0].hp_max, roundi(base.hp_max * float(s["hp"])), "tier %d: its HP the tier's" % (t + 1))
		assert_eq(made[0].attack, base.attack + int(s["attack"]), "tier %d: its attack the tier's" % (t + 1))
	var other := ""
	for id in db.foes.keys():
		if db.is_elite(str(id)) and not bool(db.foes[id].get("wanders", false)):
			other = str(id)
	var still := Unit.pack(0, "", Vector2i.ZERO, str(db.factions.keys()[0]), Unit.PACK_MOVE, 0, other)
	still.set_members([[other, 1]])
	still.boss_tier = 2
	assert_eq(db.foes_for(still)[0].hp_max, roundi(int(db.foes[other]["hp"]) * float(ContentDB.boss_tier(2)["hp"])), "every elite stands at the tier as a boss does (2 November)")
	# A battle's elite stands at the battle's tier.
	var b := Battle.new(3)
	b.tier = 2
	b.setup([], "peak")
	b._spawn_elite()
	var emerged: Array = b.field.units.filter(func(u) -> bool: return u.composition_size == "elite")
	assert_false(emerged.is_empty(), "an elite emerges")
	if not emerged.is_empty():
		assert_eq(emerged[0].boss_tier, 2, "at the battle's tier")


func test_the_validator_holds_wanders_to_the_elites() -> void:
	var db := ContentDB.new()   # a copy of its own: the shared content is never written to
	db.load_dir(ContentDB.DIR)
	db.foes["x_wander"] = {"id": "x_wander", "name": "X", "faction": "meadow", "hp": 9, "attack": 3, "wanders": true, "codex": "", "flavour": "", "design": {},
		"actions": [{"id": "a", "name": "A", "kind": "attack", "text": "", "status": "implemented"}]}
	var errs: Array = db.validate()
	assert_true(errs.any(func(e) -> bool: return e.contains("x_wander") and e.contains("only an elite wanders")), "the rank and file never wander")


## The Nob's rage is its own from the fight's start (Ryan, 8 November, on the Bellow it had to cast
## first: "It's not innate? ... That is so unbelievably incorrect"): the content's Nob rages before
## it has acted, the team's first shield feeds it, and it has no move to bellow with; a fight
## saved with a Bellow still on its list loads with the rage and the move gone.
func test_the_nobs_rage_is_its_own_from_the_fights_start() -> void:
	var db := ContentDB.load_default()
	var nob := db.make_foe("goblin_nob")
	assert_true(nob.rage >= 1, "it rages as it is made")
	assert_false(nob.actions.any(func(a: Dictionary) -> bool: return str(a.get("effect", "")) == "enrage"), "and no move of its casts it")
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 500))
	sk.add_foes([nob])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0), "the team's first shield, before the Nob has acted")
	assert_eq(Effects.stacks_of(nob, "enraged"), nob.rage, "feeds its rage at once")
	var fd := SaveGame._foe_dict(nob, sk)
	var bellow := {"id": "bellow", "name": "Bellow", "kind": "buff", "effect": "enrage", "value": 2, "once": true, "opens": true, "weight": 1, "text": ""}
	fd["actions"] = [bellow] + fd["actions"]
	fd["action"] = 2   # the third saved move, the second once the Bellow goes
	fd["rage"] = 0
	var old := SaveGame._foe_from(JSON.parse_string(JSON.stringify(fd)), sk)
	assert_eq(old.rage, 2, "an old save's Bellow becomes its rage")
	assert_false(old.actions.any(func(a: Dictionary) -> bool: return str(a.get("effect", "")) == "enrage"), "and the move goes")
	assert_eq(str(old.action.get("id", "")), str(nob.actions[1].get("id", "")), "its announced move still the one it was")


## The rage (3 November): every shield, vent or equipment entry the team spends stacks Enraged
## on a foe that rages, a point of attack a stack for the rest of the fight; a weapon feeds
## nothing; the player's Purge clears the stacks and the rage goes on.
func test_a_rage_grows_with_the_teams_safe_spends_and_a_purge_lowers_it() -> void:
	var sk := Skirmish.new(1, 3)
	var d := Die.of([Face.shield(10), Face.attack(5, I), Face.vent(4)])
	sk.add_mech(_mech("A", d, 0, 500))
	var nob := Foe.make("nob", 900, 6)
	nob.actions = [_move("rush")]
	nob.action = nob.actions[0]
	nob.rage = 1   # its own from the start (8 November)
	sk.add_foes([nob])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0), "a shield spent")
	assert_eq(Effects.stacks_of(nob, "enraged"), 1, "feeds the rage a stack")
	assert_eq(nob.damage_of(nob.actions[0]), 7, "and its blow is a point harder")
	sk.end_round()
	assert_eq(Effects.stacks_of(nob, "enraged"), 1, "the stack outlives its move")
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, nob), "a weapon spent")
	assert_eq(Effects.stacks_of(nob, "enraged"), 1, "feeds nothing")
	sk.end_round()
	sk.start_round()
	ms.face_index = 2
	assert_true(sk.assign(0), "a vent spent")
	assert_eq(Effects.stacks_of(nob, "enraged"), 2, "feeds it again")
	assert_eq(nob.damage_of(nob.actions[0]), 8, "two points now")
	var lowered := Effects.purge(nob)
	assert_true(lowered.has(Effects.STATUS["enraged"]["name"] + " 1"), "a Purge 1 lowers the stacks by one (Purge N, 2 November)")
	assert_eq(nob.damage_of(nob.actions[0]), 7, "a point harder still")
	var gone := Effects.purge(nob, 2)
	assert_true(gone.has(Effects.STATUS["enraged"]["name"] + " gone"), "a Purge 2 takes what is left")
	assert_eq(nob.damage_of(nob.actions[0]), 6, "back to its own number")
	assert_eq(nob.rage, 1, "and the rage goes on")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	assert_true(sk.assign(0), "another shield")
	assert_eq(Effects.stacks_of(nob, "enraged"), 1, "gathers again")
	# A save keeps the rage and what it has gathered.
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	var cp: Foe = copy.field_foes()[0]
	assert_eq(cp.rage, 1, "a save keeps the rage")
	assert_eq(Effects.stacks_of(cp, "enraged"), 1, "and its stacks")
	# The bot values a safe spend less while a foe rages.
	assert_eq(sk.rage_on_field(), 1, "the field's rage, for the bot")
	assert_true(Policy.make(Policy.GREEDY).rage_cost(sk) > 0.0, "which costs a non-weapon spend")


## The wanderers' draw (3 November, the pool past one): the roll under WANDER_CHANCE picks
## which wanderer by its place in the band, and with the domain's own spent the whole roll
## does, each among those not yet sent, so a resumed battle draws the same wanderer.
func test_the_wanderers_are_drawn_by_the_roll_among_those_not_yet_sent() -> void:
	var db := ContentDB.load_default()
	for t in [1, 2, 3]:
		var pool: Array = db.wandering_compositions(t).map(func(c) -> String: return str(c["id"]))
		assert_true(pool.size() >= 2, "more than one wanderer walks at tier %d" % t)
		var fid := str(db.factions.keys()[0])
		var low := str(db.next_elite(fid, t, [], 0.0)["id"])
		var high := str(db.next_elite(fid, t, [], ContentDB.WANDER_CHANCE * 0.999)["id"])
		assert_eq(low, pool[0], "the band's floor draws the first")
		assert_eq(high, pool[pool.size() - 1], "its ceiling the last")
		assert_eq(str(db.next_elite(fid, t, [], 0.0)["id"]), low, "the same roll draws the same")
		var own: Array = db.elite_compositions(fid, t).map(func(c) -> String: return str(c["id"]))
		var sent: Array = own.duplicate()
		assert_eq(str(db.next_elite(fid, t, sent, 0.0)["id"]), pool[0], "own spent: the roll's floor the first")
		assert_eq(str(db.next_elite(fid, t, sent, 0.99)["id"]), pool[pool.size() - 1], "its ceiling the last")
		sent.append(pool[0])
		assert_ne(str(db.next_elite(fid, t, sent, 0.0)["id"]), pool[0], "never one already sent")
		assert_true(pool.has(str(db.next_elite(fid, t, sent, 0.0)["id"])), "another wanderer instead")


## The elites' shapes in content (3 November): hunters among them (the composition says so since
## 8 November, every hunter pouncing at two), a pack of clones led by its elite at a strength above
## one, and every elite composition's members exist. Read by structure, never by id.
func test_the_elites_compositions_hold_their_shapes() -> void:
	var db := ContentDB.load_default()
	var clones := 0
	var hunters := 0
	for fid in db.factions.keys():
		for c in db.elite_compositions(str(fid), 1) + db.elite_compositions(str(fid), 2) + db.elite_compositions(str(fid), 3) + db.wandering_compositions(1) + db.wandering_compositions(3):
			var lead := str(c["members"][0][0])
			assert_true(db.is_elite(lead), "%s is led by its elite" % str(c["id"]))
			if int(c["members"][0][1]) > 1:
				clones += 1
			if c.has("hunts"):
				hunters += 1
				assert_true(ContentDB.HUNT_CAVEATS.has(str(c["hunts"])), "%s hunts by a caveat the engine has" % str(c["id"]))
	assert_true(clones >= 1, "an elite pack of clones is in content (the Wild Hunt's shape)")
	assert_true(hunters >= 3, "hunters among the elites")
	for fid in db.factions.keys():
		for t in [1, 2, 3]:
			assert_true(db.elite_compositions(str(fid), t).size() >= 1, "%s has an elite of its own at tier %d" % [fid, t])


## The Thunder Ape's Golden Rage (4 November, Ryan's read of Rajang: "a mode, not an attack ...
## a cycle that forces the player into a cycle of attack and defense, broken by a bold player
## with great timing"): gold, its blows hit the move's value harder under a point of plate for
## the move's rounds; a quarter of its HP lost since it went gold breaks it and it staggers out
## of its next action; a stun breaks it too; a Purge strips it; it roars again only once calm.
func test_a_golden_rage_is_a_mode_that_a_quarter_of_its_hp_or_a_stun_breaks() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(6, I))))
	sk.add_mech(_mech("B", Die.single(Face.attack(6, I))))
	var ape := Foe.make("ape", 24, 7)
	var rage := {"id": "golden_rage", "name": "Golden Rage", "kind": "buff", "effect": "golden", "value": 2, "rounds": 3, "weight": 1, "when": "calm", "text": ""}
	ape.actions = [_move("fist"), rage]
	sk.add_foes([ape])
	sk.begin()
	sk.start_round()
	assert_true(sk._when_holds(ape, rage), "calm, it may go gold")
	ape.action = rage
	sk.end_round()
	assert_true(Effects.has(ape, "golden"), "it is gold")
	assert_eq(ape.damage_of(ape.actions[0]), 9, "its blows two harder")
	assert_eq(ape.armour_total(), 1, "and a point of plate")
	assert_eq(ape.golden_mark, 24, "it marks its HP as it goes gold")
	assert_eq(Skirmish.golden_left(ape), 6, "a quarter of its 24 breaks it")
	assert_false(sk._when_holds(ape, rage), "gold, it may not roar again")
	sk.start_round()
	assert_eq(sk.golden_rounds_left(ape), 3, "three rounds of gold")
	var copy: Skirmish = SaveGame.clone_skirmish(sk)
	var cp: Foe = copy.field_foes()[0]
	assert_eq(cp.golden_mark, 24, "a save keeps the mark")
	assert_true(Effects.has(cp, "golden"), "and the gold")
	assert_true(Effects.purge(cp, 9).is_empty() and Effects.has(cp, "golden"), "no Purge strips the gold: an ability (8 November)")
	assert_true(sk.assign(0, ape), "A strikes for 6, 5 through the plate")
	assert_eq(ape.hp, 19, "a point of plate off the six")
	assert_true(Effects.has(ape, "golden"), "short of a quarter, it holds")
	assert_eq(Skirmish.golden_left(ape), 1, "one more breaks it")
	assert_true(sk.assign(1, ape), "B strikes")
	assert_false(Effects.has(ape, "golden"), "a quarter lost: the gold goes")
	assert_eq(ape.golden_mark, -1, "and it is calm")
	assert_true(ape.is_suppressed(), "staggered out of its next action")
	assert_eq(ape.damage_of(ape.actions[0]), 7, "its blows its own again")
	assert_eq(ape.armour_total(), 0, "the plate gone with the gold")
	assert_true("\n".join(sk.log).contains("staggers"), "the log says so")
	# Gold again, and a stun breaks it.
	sk.end_round()
	sk.start_round()
	assert_true(sk._when_holds(ape, rage), "calm again, it may roar")
	ape.action = rage
	sk.end_round()
	assert_true(Effects.has(ape, "golden"), "gold again")
	sk.start_round()
	assert_true(sk._suppress(ape), "a stun lands")
	assert_false(Effects.has(ape, "golden"), "and breaks the gold")
	assert_eq(ape.golden_mark, -1, "calm")
	# Gold runs out on its own clock.
	sk.end_round()
	sk.start_round()
	ape.action = rage
	sk.end_round()
	for i in range(3):
		sk.start_round()
		assert_true(Effects.has(ape, "golden"), "gold through round %d of three" % (i + 1))
		assert_eq(sk.golden_rounds_left(ape), 3 - i, "counting down")
		ape.action = ape.actions[0]
		sk.end_round()
	sk.start_round()
	assert_false(Effects.has(ape, "golden"), "three rounds on, the gold is gone")
	assert_true(sk._when_holds(ape, rage), "and it may roar again")
	# The validator holds the rounds to 1 to 5.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	db.foes["x_gold"] = {"id": "x_gold", "name": "X", "faction": "peak", "hp": 9, "attack": 3, "codex": "", "flavour": "", "design": {},
		"actions": [{"id": "a", "name": "A", "kind": "attack", "text": "", "status": "implemented"},
			{"id": "g", "name": "G", "kind": "buff", "effect": "golden", "value": 2, "rounds": 9, "weight": 1, "text": "", "status": "implemented"}]}
	var errs: Array = db.validate()
	assert_true(errs.any(func(e) -> bool: return e.contains("x_gold") and e.contains("golden's rounds")), "nine rounds of gold is refused")


## A stagger is the mode's own, no stun piece's (4 November): it numbs the foe nothing, so the
## next stun lands and breaks the gold again; and a rage the foe's own tick breaks in the enemy's
## turn staggers it out of its next action, never the one it has had.
func test_a_stagger_numbs_nothing_and_a_tick_broken_rage_costs_the_next_action() -> void:
	var rage := {"id": "golden_rage", "name": "Golden Rage", "kind": "buff", "effect": "golden", "value": 2, "rounds": 3, "weight": 1, "when": "calm", "text": ""}
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(6, I))))
	sk.add_mech(_mech("B", Die.single(Face.attack(6, I))))
	var ape := Foe.make("ape", 24, 7)
	ape.elite = true   # an elite recovers from a stun with Numbed 3, so a stagger that numbed would show
	ape.actions = [_move("fist"), rage]
	sk.add_foes([ape])
	sk.begin()
	sk.start_round()
	ape.action = rage
	sk.end_round()
	sk.start_round()
	assert_true(Effects.has(ape, "golden"), "gold")
	assert_true(sk.assign(0, ape), "A strikes")
	assert_true(sk.assign(1, ape), "B strikes: a quarter lost")
	assert_true(ape.is_suppressed(), "staggered")
	sk.end_round()
	assert_eq(Effects.stacks_of(ape, "numbed"), 0, "a stagger numbs nothing")
	sk.start_round()
	ape.action = rage
	sk.end_round()
	sk.start_round()
	assert_true(Effects.has(ape, "golden"), "gold again")
	assert_true(sk._suppress(ape), "a stun lands, no Numbed in its way")
	assert_false(Effects.has(ape, "golden"), "and breaks the gold")
	# Broken by its own tick in the enemy's turn: it acted gold, and loses the next action.
	var sk2 := Skirmish.new(1, 3)
	sk2.add_mech(_mech("A", Die.single(Face.attack(1, I))))
	var ape2 := Foe.make("ape", 24, 7)
	ape2.actions = [_move("fist"), rage]
	sk2.add_foes([ape2])
	sk2.begin()
	sk2.start_round()
	ape2.action = rage
	sk2.end_round()
	sk2.start_round()
	assert_true(Effects.has(ape2, "golden"), "gold at 24, a quarter breaks it at 18")
	Effects.stack(ape2, Effects.STATUS["ablating"], Effects.SKIRMISH, "test", 6)
	ape2.action = ape2.actions[0]
	sk2.end_round()
	assert_eq(ape2.hp, 18, "its burn took it to the break")
	assert_false(Effects.has(ape2, "golden"), "the gold goes")
	sk2.start_round()
	assert_true(ape2.is_suppressed(), "and it staggers out of the next round's action, not the one it had")


## The World Eater's pin (4 November, Ryan: "rework the below half attack into a form of its pin,
## since that inflicts Defense Down in game, something we don't have"; Brittle on both sides
## since 15 November, "Crushed and flak - agreed, brittle"): a foe's Brittle rider lays Brittle on
## the machine, a point more on every blow it takes a stack, whole for the blows after it that
## turn and halving as each of the machine's turns starts (16 November; at the round's end until
## then, no blow apart); a Ward turns it away and a Cleanse lifts it.
func test_a_foes_brittle_makes_every_blow_the_machine_takes_land_harder_and_halves_each_turn() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var jho := Foe.make("jho", 40, 8)
	jho.actions = [_move("chomp"), _move("pin", {"factor": 1.25, "keywords": ["brittle"], "brittle": 2})]
	var gob := Foe.make("gob", 9, 3)
	gob.actions = [_move("stab")]
	sk.add_foes([jho, gob])
	sk.begin()
	var a: Skirmish.MechState = sk.mechs[0]
	var turn := func(jho_move: int) -> void:
		jho.action = jho.actions[jho_move]
		jho.target = a
		gob.action = gob.actions[0]
		gob.target = a
		sk.end_round()
	sk.start_round()
	turn.call(1)
	assert_eq(a.unit.hull, 485, "the pin's 10 and Brittle 2, then the stab's 3 and 2 more")
	assert_true("\n".join(sk.log).contains("lays Brittle ×2 on A"), "the log says so")
	assert_eq(Effects.stacks_of(a.unit, "brittled_mech"), 2, "the round's end leaves it")
	assert_eq(Effects.STATUS["brittled_mech"]["name"], Effects.STATUS["brittled"]["name"], "one word on either body")
	sk.start_round()
	assert_eq(Effects.stacks_of(a.unit, "brittled_mech"), 1, "its turn's start halves it")
	turn.call(0)
	assert_eq(a.unit.hull, 472, "the chomp's 8 and the stab's 3, each 1 harder")
	sk.start_round()
	assert_eq(Effects.stacks_of(a.unit, "brittled_mech"), 0, "one halves to none")
	turn.call(0)
	assert_eq(a.unit.hull, 461, "their own numbers again")
	# A Ward turns the rider away; a Cleanse lifts the mark.
	sk.start_round()
	Effects.grant_buff(a.unit, "ward", 1, "test", sk.round)
	turn.call(1)
	assert_eq(a.unit.hull, 448, "warded: the pin's 10 and the stab's plain 3")
	assert_eq(Effects.stacks_of(a.unit, "brittled_mech"), 0, "the Ward turns the Brittle away")
	sk.start_round()
	turn.call(1)
	assert_eq(Effects.stacks_of(a.unit, "brittled_mech"), 2, "Brittle again, whole until its next turn starts")
	assert_true(Effects.cleanse(a.unit).has(Effects.STATUS["brittled_mech"]["name"]), "a Cleanse lifts it")
	assert_eq(Effects.stacks_of(a.unit, "brittled_mech"), 0, "and it is gone")


## Every domain holds three bosses at least (Ryan, 3 November: more is fine): the slate's twelve
## and the Emperor Scorpion since 4 November.
func test_every_domain_holds_three_bosses_at_least() -> void:
	var db := ContentDB.load_default()
	for fid in db.factions:
		assert_true(Array(db.factions[fid].get("boss", [])).size() >= 3, "%s holds three bosses at least" % str(fid))

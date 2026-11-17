extends TestCase

## Exposed on a machine, from a foe's Expose (Ryan, 15 November, the vocabulary pass's fourth and
## fifth rounds: docs/vocabulary_pass_proposal.md, section 17), on synthetic foes. The armour
## half is the foe's rule whole ("all armour of all kinds"); the second half is the field's fire:
## as the round after opens every targeted intent turns on the machine until the blows already
## drawn would wreck it ("keep the logic where enemies don't try and overkill ... So the whole
## field targets up until predicted death, then the rest pick intent targets as normal"). A Lure
## turns the move and a Ward turns it away; a Cleanse gives the armour back and leaves the
## intents; and no foe announces one while another's is out or a machine stands Exposed.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT
const K := Face.Keyword

## A kit's armour, and a reduction that is no armour.
const SHELL := {"id": "shell", "name": "Shell", "description": "", "effects": [
	{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 2},
	{"trigger": "static", "effect": "add_damage_taken", "value": -1}]}


func _mech(name: String, d: Die, shield: int = 0, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _blow(extra: Dictionary = {}) -> Dictionary:
	var a := {"id": "claw", "name": "Claw", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": ""}
	a.merge(extra, true)
	return a


## A foe with an Expose of its own and a plain blow.
func _marker(hp: int = 500, atk: int = 10) -> Foe:
	var f := Foe.make("marker", hp, atk)
	f.actions = [{"id": "mark", "name": "Mark", "kind": "debuff", "effect": "expose", "weight": 1, "text": ""}, _blow()]
	return f


func _ids(list: Array) -> Array:
	return list.map(func(x): return str(x.get("id", "")))


func _expose(u: Unit, until: int) -> void:
	Effects.grant_for_rounds(u, Effects.STATUS["exposure_mech"], "test", until)


# ---------------------------------------------------------------- the armour half

func test_a_foes_expose_takes_armour_of_every_kind_through_the_round_after() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.blank()))
	a.armour = 3
	a.grant_passive(SHELL)
	sk.add_mech(a)
	var m := _marker()
	sk.add_foes([m])
	sk.begin()
	sk.start_round()
	m.action = m.actions[0]
	m.target = sk.mechs[0]
	assert_eq(a.armour, 5, "its own and its kit's")
	sk.end_round()
	assert_true(Effects.has(a, "exposure_mech"), "the move lands: Exposed")
	assert_eq(a.armour, 0, "all armour of all kinds counts for nothing, at once")
	assert_eq(a.hull, 100, "and the move itself deals nothing")
	assert_true("\n".join(sk.log).contains("Mark, A is Exposed"), "the log says so")
	assert_eq(Effects.status_kind("exposure_mech"), "debuff", "a debuff on its chip")
	sk.start_round()
	Effects.grant_buff(a, "braced", 4, "test", sk.round)
	assert_eq(Effects.stacks_of(a, "braced"), 4, "armour gained while Exposed is gained")
	assert_eq(a.armour, 0, "and does nothing until the mark ends")
	m.action = m.actions[1]
	m.target = sk.mechs[0]
	assert_eq(int(sk.forecast(sk.mechs[0])["hull_after"]), 91, "the forecast reads the bare hull")
	sk.end_round()
	assert_eq(a.hull, 100 - 9, "the blow of 10 loses the 1 that is no armour, and no armour comes off it")
	assert_true(Effects.has(a, "exposure_mech"), "the mark stands through the foes' next turn, the round's end included")
	sk.start_round()
	assert_false(Effects.has(a, "exposure_mech"), "and falls as its machine's turn starts, the round after that")
	assert_eq(a.armour, 5, "the armour counts again")


func test_a_cleanse_gives_the_armour_back_and_leaves_the_intents() -> void:
	var sk := Skirmish.new(3, 3)
	var a := _mech("A", Die.single(Face.blank()), 0, 500)
	a.armour = 4
	var b := _mech("B", Die.single(Face.blank()), 0, 500)
	sk.add_mech(b)
	sk.add_mech(a)
	var f1 := Foe.make("revenant", 500, 10)
	var f2 := Foe.make("revenant", 500, 10)
	sk.add_foes([f1, f2])
	sk.begin()
	_expose(a, 1)
	sk.start_round()
	assert_eq([f1.target, f2.target], [sk.mechs[1], sk.mechs[1]], "the intents turned on it as the round opened")
	assert_eq(a.armour, 0, "bare")
	assert_eq(Effects.cleanse(a), ["Exposed"] as Array[String], "a Cleanse lifts the mark")
	assert_eq(a.armour, 4, "and the armour is back")
	assert_eq([f1.target, f2.target], [sk.mechs[1], sk.mechs[1]], "the intents stay where they turned: chosen already")
	sk.end_round()
	assert_eq(a.hull, 500 - 2 * 6, "so the blows land on its plate")


# ---------------------------------------------------------------- the field's fire

func test_every_targeted_intent_turns_on_it_until_the_blows_drawn_would_wreck_it() -> void:
	for seed in [1, 2, 3, 4, 5]:
		var sk := Skirmish.new(seed, 4)
		var a := _mech("A", Die.single(Face.blank()), 0, 25)
		var b := _mech("B", Die.single(Face.blank()), 0, 500)
		var c := _mech("C", Die.single(Face.blank()), 0, 500)
		sk.add_mech(b)
		sk.add_mech(a)   # in the middle: no place in the line picks it
		sk.add_mech(c)
		var strikers: Array = []
		for i in range(4):
			strikers.append(Foe.make("revenant", 500, 10))
		# One that braces every round: its blow is shut by a condition, so its move aims at no machine.
		var warden := Foe.make("archer", 500, 10, true)
		warden.actions = [{"id": "brace", "name": "Brace", "kind": "defend", "effect": "brace", "value": 2, "weight": 1, "text": ""}, _blow({"when": "below_half"})]
		sk.add_foes(strikers + [warden])
		sk.begin()
		_expose(a, 1)
		sk.start_round()
		var marked: Skirmish.MechState = sk.mechs[1]
		assert_eq(sk.exposed_mech(), marked, "seed %d: the machine that stands Exposed" % seed)
		var on_it := 0
		for f in sk.field_foes():
			if f != warden and f.target == marked:
				on_it += 1
		# Three blows of 10 wreck a hull of 25; the fourth foe picks as it would, among the rest.
		assert_eq(on_it, 3, "seed %d: the field turns on it, whatever each move's word, up to the blows that would wreck it" % seed)
		var order: Array = sk.field_foes().filter(func(f) -> bool: return f != warden)
		assert_eq([order[0].target, order[1].target, order[2].target], [marked, marked, marked], "seed %d: in the order they strike" % seed)
		assert_true(order[3].target != marked and order[3].target != null, "seed %d: and never an overkill: the rest pick intent targets as normal" % seed)
		assert_eq(str(warden.action.get("id", "")), "brace", "seed %d: a foe whose move aims at no machine is not made to strike" % seed)


func test_a_lure_wins_and_a_machine_out_of_reach_is_passed_by() -> void:
	# A Lure laid in the player's turn pulls a blow off it as off any machine.
	var sk := Skirmish.new(2, 3)
	var a := _mech("A", Die.single(Face.blank()), 0, 500)
	var b := _mech("B", Die.single(Face.attack(0, I, [K.LURE])), 0, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var f1 := Foe.make("revenant", 500, 10)
	var f2 := Foe.make("revenant", 500, 10)
	sk.add_foes([f1, f2])
	sk.begin()
	_expose(a, 1)
	sk.start_round()
	assert_eq([f1.target, f2.target], [sk.mechs[0], sk.mechs[0]], "both on the Exposed machine")
	assert_true(sk.assign(1, f1), "B lures one")
	assert_eq([f1.target, f2.target], [sk.mechs[1], sk.mechs[0]], "Lure wins: the blow comes off it")
	# Phased as the round ended, it is out of the picks: the round bought a round ahead answers it.
	var sk2 := Skirmish.new(2, 3)
	var p := _mech("A", Die.single(Face.blank()), 0, 500)
	var q := _mech("B", Die.single(Face.blank()), 0, 500)
	sk2.add_mech(p)
	sk2.add_mech(q)
	var g := Foe.make("revenant", 500, 10)
	sk2.add_foes([g])
	sk2.begin()
	_expose(p, 1)
	Effects.grant_for_rounds(p, Effects.STATUS["phased"], "test", 1)
	sk2.start_round()
	assert_eq(sk2.exposed_mech(), null, "an Exposed machine out of reach draws nothing")
	assert_eq(g.target, sk2.mechs[1], "and the foe picks another")


# ---------------------------------------------------------------- how it lands

func test_a_lure_turns_the_expose_itself_and_a_ward_turns_it_away() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.blank()), 0, 500)
	var b := _mech("B", Die.single(Face.attack(0, I, [K.LURE])), 0, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var m := _marker()
	sk.add_foes([m])
	sk.begin()
	sk.start_round()
	m.action = m.actions[0]
	m.target = sk.mechs[0]
	assert_true(sk.assign(1, m), "B lures the foe that is about to mark A")
	sk.end_round()
	assert_true(Effects.has(b, "exposure_mech") and not Effects.has(a, "exposure_mech"), "the Expose lands on the machine that lured it, like any targeted move")
	# A Ward turns it away as it turns every rider.
	var sk2 := Skirmish.new(1, 2)
	var w := _mech("W", Die.single(Face.blank()), 0, 500)
	sk2.add_mech(w)
	var m2 := _marker()
	sk2.add_foes([m2])
	sk2.begin()
	sk2.start_round()
	m2.action = m2.actions[0]
	m2.target = sk2.mechs[0]
	Effects.grant_buff(w, "ward", 1, "test", sk2.round)
	sk2.end_round()
	assert_false(Effects.has(w, "exposure_mech"), "the Ward turns the move away")
	assert_true("\n".join(sk2.log).contains("W's Ward turns it away"), "and the log says so")


func test_the_rider_lands_with_its_blow_through_a_barrier_and_not_through_a_ward() -> void:
	for how in ["bare", "barrier", "ward"]:
		var sk := Skirmish.new(1, 2)
		var a := _mech("A", Die.single(Face.blank()), 0, 500)
		sk.add_mech(a)
		var f := Foe.make("lancer", 500, 10)
		f.actions = [_blow({"id": "lance", "name": "Lance", "keywords": ["expose"]})]
		sk.add_foes([f])
		sk.begin()
		sk.start_round()
		f.action = f.actions[0]
		f.target = sk.mechs[0]
		assert_true(Foe.exposes(f.action), "%s: a blow that carries the rider lays Exposed" % how)
		if how == "barrier":
			Effects.grant_buff(a, "barrier", 1, "test", sk.round)
		elif how == "ward":
			Effects.grant_buff(a, "ward", 1, "test", sk.round)
		sk.end_round()
		assert_eq(a.hull, 500 if how == "barrier" else 490, "%s: the blow's own damage" % how)
		assert_eq(Effects.has(a, "exposure_mech"), how != "ward", "%s: a Barrier's blow deals nothing and its riders land; a Ward turns the rider away" % how)


# ---------------------------------------------------------------- one at a time

func test_no_foe_announces_an_expose_while_one_is_out_or_a_machine_stands_exposed() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.blank()), 0, 5000)
	var b := _mech("B", Die.single(Face.blank()), 0, 5000)
	sk.add_mech(a)
	sk.add_mech(b)
	var m1 := _marker()
	var m2 := _marker()
	sk.add_foes([m1, m2])
	sk.begin()
	sk.start_round()
	m2.last_special = ""
	m1.action = m1.actions[1]
	assert_true(_ids(sk.legal_actions(m2, [m1])).has("mark"), "open while none is out")
	m1.action = m1.actions[0]
	assert_true(sk.expose_announced(m2, [m1]), "the first foe's Expose is out")
	assert_false(_ids(sk.legal_actions(m2, [m1])).has("mark"), "so the second announces none: one machine at a time")
	assert_false(_ids(sk.legal_actions(m2)).has("mark"), "nor turns to one mid-round")
	m1.action = m1.actions[1]
	_expose(a, sk.round + 1)
	assert_false(_ids(sk.legal_actions(m2, [m1])).has("mark"), "and none while a machine stands Exposed")
	# Over whole fights: never two out in a round, and never one in the round a machine stands Exposed.
	for seed in range(1, 9):
		var s2 := Skirmish.new(seed, 3)
		s2.add_mech(_mech("A", Die.single(Face.blank()), 0, 5000))
		s2.add_mech(_mech("B", Die.single(Face.blank()), 0, 5000))
		s2.add_foes([_marker(), _marker(), _marker()])
		s2.begin()
		var landed := 0
		for r in range(8):
			s2.start_round()
			var out := 0
			for f in s2.field_foes():
				if Foe.exposes(f.action):
					out += 1
			var stands := false
			for ms in s2.mechs:
				if Effects.has(ms.unit, "exposure_mech"):
					stands = true
			assert_true(out <= 1, "seed %d round %d: one Expose out at the most (%d)" % [seed, r + 1, out])
			assert_true(out == 0 or not stands, "seed %d round %d: none announced while a machine stands Exposed" % [seed, r + 1])
			landed += out
			s2.end_round()
		assert_true(landed >= 1, "seed %d: and the move is still announced (%d times in eight rounds)" % [seed, landed])


# ---------------------------------------------------------------- content, the bot and the screen

func test_the_validator_refuses_an_expose_on_anything_dealt_at_tier_one() -> void:
	var db := ContentDB.new()   # a copy of its own: the shared content is never written to
	db.load_dir(ContentDB.DIR)
	assert_true(db.validate().filter(func(e) -> bool: return e.contains("lays Exposed")).is_empty(), "content as shipped lays none at tier one")
	# The first formation dealt at tier one, whichever it is: one of its foes learns the move.
	var who := ""
	var comp := ""
	for fid in db.factions.keys():
		for c in db.factions[fid].get("compositions", []):
			if who.is_empty() and ContentDB.composition_tiers(c).has(1):
				for cell in ContentDB.layout_cells(c):
					if who.is_empty() and db.foes.has(cell):
						who = str(cell)
						comp = str(c.get("id", ""))
	assert_false(who.is_empty(), "a tier-one formation is read")
	(db.foes[who]["actions"] as Array).append({"id": "x_mark", "name": "Mark", "kind": "debuff", "effect": "expose", "text": "", "status": "implemented"})
	var errs: Array = db.validate().filter(func(e) -> bool: return e.contains("lays Exposed"))
	assert_true(errs.any(func(e) -> bool: return e.contains(comp) and e.contains(who)), "a foe that lays Exposed is refused in a tier-one formation")
	# A planned draft is kept and not held to it.
	(db.foes[who]["actions"] as Array)[-1]["status"] = "planned"
	assert_true(db.validate().filter(func(e) -> bool: return e.contains("lays Exposed")).is_empty(), "a planned draft is no carrier")
	# An elite is held to no tier, as a boss is not (Ryan, 16 November: "I think elites can hold
	# any mechanic at any tier, as a boss can"): the first elite dealt at tier one learns the move.
	var elite := ""
	for fid in db.factions.keys():
		for c in db.factions[fid].get("compositions", []):
			if elite.is_empty() and ContentDB.composition_tiers(c).has(1):
				for cell in ContentDB.layout_cells(c):
					if elite.is_empty() and db.is_elite(str(cell)):
						elite = str(cell)
	assert_false(elite.is_empty(), "an elite dealt at tier one is read")
	(db.foes[elite]["actions"] as Array).append({"id": "x_mark", "name": "Mark", "kind": "debuff", "effect": "expose", "text": "", "status": "implemented"})
	assert_true(db.validate().filter(func(e) -> bool: return e.contains("lays Exposed")).is_empty(), "an elite may lay Exposed at tier one")


func test_the_bot_reads_an_expose_aimed_at_it_and_a_cleanse_of_one() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.blank()), 0, 100)
	a.armour = 3
	var b := _mech("B", Die.single(Face.blank()), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var m := _marker()
	var s := Foe.make("revenant", 500, 10)
	sk.add_foes([m, s])
	sk.begin()
	sk.start_round()
	m.action = m.actions[0]
	m.target = sk.mechs[0]
	s.target = sk.mechs[1]
	var pol := Policy.make(Policy.GREEDY)
	var stakes := Policy.exposed_stakes(sk, sk.mechs[0])
	assert_true(stakes > 0.0, "standing Exposed next round has a cost: its armour off every blow and the fire that would have gone elsewhere")
	assert_eq(snappedf(pol.ward_score(sk, sk.mechs[0]), 0.01), snappedf(stakes, 0.01), "a Ward on the machine it is aimed at is worth turning it away")
	assert_eq(pol.ward_score(sk, sk.mechs[1]), 0.0, "and nothing on the machine it is not aimed at")
	# The rider on a blow reads the same.
	m.actions.append(_blow({"id": "lance", "name": "Lance", "keywords": ["expose"]}))
	m.action = m.actions[2]
	assert_true(pol.ward_score(sk, sk.mechs[0]) >= stakes, "a blow that carries it counts the same")
	# A Cleanse of an Exposed machine gives its armour back for the blows drawn on it.
	m.action = m.actions[1]
	_expose(a, sk.round)
	s.target = sk.mechs[0]
	assert_true(pol.cleanse_score(sk, sk.mechs[0]) > 0.0, "the armour back against the blows on it")
	a.armour = 0
	assert_eq(pol.cleanse_score(sk, sk.mechs[0]), 0.0, "and nothing for a machine with none to give back")


func test_the_chip_and_the_intent_wear_exposeds_mark() -> void:
	assert_eq(SkirmishScreen.status_glyph("exposure_mech"), "exposed", "the machine's chip wears the mark an Exposed foe wears")
	assert_eq(Terms.of_status("exposure_mech"), Terms.of_status("exposure"), "one word on either body")
	var m := _marker()
	m.action = m.actions[0]
	var riders := SkirmishScreen.intent_riders(m)
	assert_eq(riders.size(), 1, "a move of its own that lays Exposed wears the mark on its intent")
	assert_eq(str(riders[0][0]), Terms.glyph("expose"), "Expose's")
	m.action = m.actions[1]
	assert_true(SkirmishScreen.intent_riders(m).is_empty(), "a plain blow wears none")
	m.actions.append(_blow({"id": "lance", "name": "Lance", "keywords": ["expose"]}))
	m.action = m.actions[2]
	assert_eq(SkirmishScreen.intent_riders(m).size(), 1, "a blow that carries the rider wears it as any rider")
	# A copy of the fight (the round preview's, a save's) keeps the mark.
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.blank()), 0, 100)
	sk.add_mech(a)
	sk.add_foes([Foe.make("revenant", 500, 10)])
	sk.begin()
	sk.start_round()
	_expose(a, sk.round + 1)
	assert_true(SaveGame.clone_skirmish(sk).exposed_mech() != null, "and a copy of the fight keeps it")

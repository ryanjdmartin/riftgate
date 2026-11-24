extends TestCase

## Numbers are in tens; a face is one number (rolled ranges went on 2 November).

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT
const E := Face.Reach.EVERY_FOE   # a reach over every foe
const K := Face.Keyword

## A kill trigger to read: a stack of Empowered after each attack of the machine's own that
## kills. No die entry prints a kill rule of its own since Empowered a kill left (12 November).
const KILLER := {"id": "killer", "name": "Killer", "description": "", "effects": [
	{"trigger": "on_kill", "effect": "stack_status", "value": "overcharged"}]}


func _mech(name: String, d: Die, shield: int = 40, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _ghoul(hp: int = 30, atk: int = 10) -> Foe:
	return Foe.make("revenant", hp, atk)


func _archer(hp: int = 30, atk: int = 10) -> Foe:
	return Foe.make("archer", hp, atk, true)

## The three rules written on their one piece since 15 November (keywords before), set on a test's
## own entry: damage past a kill spilling behind (the Overrun Gearing's), the Web Bomb's web and
## the Combat Translocator's swap.
func _spiller(f: Face) -> Face:
	f.spills = true
	return f


func _webber(f: Face) -> Face:
	f.webs = true
	return f


func _swapper(f: Face) -> Face:
	f.swaps = true
	return f



## A status's number in the engine's table, whatever its trigger: a field the stock pass's loops
## move (22 October), so a test reads it rather than copying it.
func _rule(status_id: String, effect: String) -> int:
	for eff in Effects.STATUS[status_id]["effects"]:
		if str(eff.get("effect", "")) == effect:
			return int(eff["value"])
	return 0


func test_formation_fills_front_then_back() -> void:
	var sk := Skirmish.new(1, 3)   # three wide: the rank rules, not the default width
	sk.add_mech(_mech("A", Die.single(Face.attack(10))))
	sk.add_foes([_ghoul(), _ghoul(), _archer(), _ghoul(), _ghoul()])
	sk.begin()
	assert_eq(sk.field_foes().size(), 4, "four on the field: ranks hold, so the fourth ghoul has no slot")
	assert_eq(sk.front[0].display_name, "revenant", "front 0 is a ghoul")
	assert_eq(sk.front[2].display_name, "revenant", "front 2 is a ghoul")
	var archer_col := -1
	for col in range(3):
		if sk.back[col] != null and sk.back[col].display_name == "archer":
			archer_col = col
	assert_true(archer_col >= 0, "the archer holds a back slot")
	for col in range(3):
		if col != archer_col:
			assert_eq(sk.back[col], null, "no ghoul in the back row")
	assert_true(sk.reinforcements.is_empty(), "and the spare ghoul is never dealt: nothing waits (no reinforcement inside a fight, 6 November)")


## What a full formation cannot stand was never in the fight (no reinforcement inside a fight, 6
## November): every fight the game deals is one pack that fits, so only a fight built by hand
## reaches this; the foe left out came with nothing, so it is no kill.
func test_a_foe_the_slots_cannot_hold_is_never_in_the_fight() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10))))
	var sq := Unit.pack(1, "horde", Vector2i.ZERO, "marsh", 2, 6, "revenant")
	var list: Array = []
	for i in range(6):
		var f := _ghoul()
		f.content_id = "revenant"
		list.append(f)
	sk.add_foes(list, sq)
	sk.begin()
	assert_eq(sk.field_foes().size(), 4, "the front rank holds four")
	assert_true(sk.reinforcements.is_empty(), "the other two never stand, and nothing waits")
	assert_true(sk.log.any(func(l) -> bool: return str(l).contains("2 more could not stand")), "the log says so")
	for f in sk.field_foes():
		f.hp = 0
	sk._clear_dead()   # the death check: a kill is what it clears (Skirmish.is_kill, 8 November)
	assert_eq(sk.kills_by_type(sq), {"revenant": 4}, "four stood and fell: the two left out are no kills")

func test_line_reach_needs_exposed_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	sk.add_foes([_ghoul(30), _ghoul(30), _archer()])
	sk.begin()
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.size(), 2, "only the two front ghouls are in line of fire")
	assert_false(t.has(sk.back[0]), "archer behind a ghoul is not exposed")
	assert_true(sk.assign(0, sk.front[0]), "attack front 0")
	sk.end_round()
	assert_true(sk.is_exposed(0), "column 0 is exposed now")
	sk.start_round()
	assert_true(sk.targets_for(0).has(sk.back[0]), "archer is now a line target")


func test_indirect_reaches_both_ranks_and_costs_its_firer_nothing() -> void:
	# Danger close retired with the stock pass (22 October): fired at the front rank, Indirect
	# costs its firer nothing; area belongs to the keywords.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, I)), 40)
	sk.add_mech(m)
	sk.add_foes([_ghoul(50), _archer(50)])
	sk.begin()
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.size(), 2, "indirect sees both ranks")
	assert_true(sk.assign(0, sk.front[0]), "mortar the front")
	assert_eq(m.shield, 40, "no splash: the shield stands")
	assert_eq(sk.front[0].hp, 30, "ghoul took 20")


func test_penetrate_hits_the_column() -> void:
	var sk := Skirmish.new(1)
	var lance := Face.attack(30, L, K.PENETRATE)
	lance.penetrate = 15
	sk.add_mech(_mech("A", Die.single(lance)))
	sk.add_foes([_ghoul(50), _archer(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "penetrate front 0")
	assert_eq(sk.front[0].hp, 20, "front took 30")
	assert_eq(sk.back[0].hp, 35, "back of the same column took its Penetrate 15 (area by shape, numbered: 28 October)")


func test_cleave_hits_neighbours() -> void:
	var sk := Skirmish.new(1)
	var sweep := Face.attack(20, L, K.CLEAVE)
	sweep.cleave = 10
	sk.add_mech(_mech("A", Die.single(sweep)))
	sk.add_foes([_ghoul(50), _ghoul(50), _ghoul(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[1]), "cleave the middle")
	assert_eq(sk.front[1].hp, 30, "the target took the blow, 20")
	for c in [0, 2]:
		assert_eq(sk.front[c].hp, 40, "front %d took its Spread 10 (area by shape, numbered: 28 October)" % c)


## A foe whose one blow carries a word for whom it goes for (Foe.AIMS), a synthetic piece.
func _seeker(word: String, hp: int = 30, atk: int = 20) -> Foe:
	var f := _ghoul(hp, atk)
	f.actions[0]["aim"] = word
	return f


func test_an_attack_picks_any_machine_and_the_pick_is_a_commitment() -> void:
	# Ryan, 17 November, after Slice and Dice: "random, don't overkill, and a spattering of
	# 'target highest HP' and 'target lowest HP'". An attack that carries no word picks any
	# machine, drawn level: over many seeds the shielded machine and the bare one are both
	# picked, and neither nearly always.
	assert_eq(_ghoul().aim_of(), "", "no word: any machine")
	var first := 0
	for seed_value in range(100):
		var sk := Skirmish.new(seed_value)
		sk.add_mech(_mech("A", Die.single(Face.shield(10)), 40, 100))
		sk.add_mech(_mech("B", Die.single(Face.shield(10)), 0, 30))
		sk.add_foes([_ghoul(30, 20)])
		sk.begin()
		sk.start_round()
		if sk.front[0].target == sk.mechs[0]:
			first += 1
	assert_true(first > 30 and first < 70, "the picks spread level, whatever a machine has left: %d of 100 on the shielded one" % first)
	# The pick is a commitment: a shield raised on the target does not move the blow.
	var s2 := Skirmish.new(3)
	s2.add_mech(_mech("A", Die.single(Face.shield(30)), 0, 100))
	s2.add_mech(_mech("B", Die.single(Face.shield(30)), 0, 100))
	s2.add_foes([_ghoul(30, 20)])
	s2.begin()
	s2.start_round()
	var picked: Skirmish.MechState = s2.front[0].target
	var at := s2.mechs.find(picked)
	assert_true(at >= 0, "it picked a machine")
	assert_true(s2.assign(at, null), "the machine it picked shields up")
	assert_eq(s2.front[0].target, picked, "and the foe still swings at it")


func test_the_foes_never_over_commit_to_a_machine_already_doomed() -> void:
	# Ryan, 24 October, after Slice and Dice: the foes pick in the order they strike, and a
	# machine the blows already picked would wreck is passed over while another stands.
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("Frail", Die.single(Face.shield(10)), 0, 10))
	sk.add_mech(_mech("Stout", Die.single(Face.shield(10)), 0, 100))
	sk.add_foes([_seeker("hottest"), _seeker("hottest")])
	sk.begin()
	sk.mechs[0].heat = 30
	sk.start_round()
	var order := sk.field_foes()
	assert_eq(order[0].target, sk.mechs[0], "the first to strike takes the hottest machine")
	assert_eq(order[1].target, sk.mechs[1], "its blow of 20 wrecks the frail machine's 10, so the second passes it over")
	# Every machine doomed: the pick is among them all.
	var s2 := Skirmish.new(1)
	s2.add_mech(_mech("Frail", Die.single(Face.shield(10)), 0, 10))
	s2.add_foes([_ghoul(30, 20), _ghoul(30, 20)])
	s2.begin()
	s2.start_round()
	for f in s2.field_foes():
		assert_eq(f.target, s2.mechs[0], "one machine standing: both strike it")
	# A blow at every machine counts on each.
	var s3 := Skirmish.new(1)
	s3.add_mech(_mech("Frail", Die.single(Face.shield(10)), 0, 10))
	s3.add_mech(_mech("Stout", Die.single(Face.shield(10)), 0, 100))
	var storm := _storm(25, 1, ["all"])
	var after := _seeker("hottest")
	s3.add_foes([storm, after])
	s3.begin()
	s3.mechs[0].heat = 30
	s3.start_round()
	assert_eq(s3.field_foes()[0], storm, "the storm stands first")
	assert_eq(after.target, s3.mechs[1], "its blow on every machine wrecks the frail one, so the heat seeker takes the other")
	# A suppressed foe lands nothing, so its pick dooms nobody.
	var s4 := Skirmish.new(1)
	s4.add_mech(_mech("Frail", Die.single(Face.shield(10)), 0, 10))
	s4.add_mech(_mech("Stout", Die.single(Face.shield(10)), 0, 100))
	var stunned := _seeker("hottest", 30, 25)
	var next := _seeker("hottest")
	s4.add_foes([stunned, next])
	s4.begin()
	s4.mechs[0].heat = 30
	Effects.grant_for_rounds(stunned, Effects.STATUS["suppressed"], "mech", 1)
	s4.start_round()
	assert_eq(s4.field_foes()[0], stunned, "the heavier hitter stands first")
	assert_eq(stunned.target, s4.mechs[0], "it still picks")
	assert_eq(next.target, s4.mechs[0], "but lands nothing, so the frail machine stays open")


func test_an_attacks_word_goes_for_the_most_or_the_least_of_one_thing_a_tie_drawn_level() -> void:
	# The strongest and the weakest read hull and shield together, as the map's hunts do.
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("Shelled", Die.single(Face.shield(10)), 40, 30))   # 70 in all
	sk.add_mech(_mech("Stout", Die.single(Face.shield(10)), 0, 100))    # 100
	sk.add_mech(_mech("Frail", Die.single(Face.shield(10)), 10, 20))    # 30
	var strong := _seeker("strongest", 30, 5)
	var weak := _seeker("weakest", 30, 5)
	sk.add_foes([strong, weak])
	sk.begin()
	sk.start_round()
	assert_eq(strong.aim_of(), "strongest", "the word is its move's")
	assert_eq(strong.target, sk.mechs[1], "the strongest: the most hull and shield together, the bare hull of 100 over the shell of 70")
	assert_eq(weak.target, sk.mechs[2], "the weakest: the least of them")
	# The hottest: the most heat, however bare the other.
	var s2 := Skirmish.new(1)
	s2.add_mech(_mech("Cold", Die.single(Face.shield(10)), 0, 100))
	s2.add_mech(_mech("Hot", Die.single(Face.shield(10)), 40, 100))
	s2.add_foes([_seeker("hottest")])
	s2.begin()
	s2.mechs[1].heat = 30
	s2.start_round()
	assert_eq(s2.front[0].target, s2.mechs[1], "the hot machine draws the heat seeker")
	# The most buffed: the most stacks of buffs.
	var s3 := Skirmish.new(1)
	s3.add_mech(_mech("Plain", Die.single(Face.shield(10)), 0, 100))
	s3.add_mech(_mech("Buffed", Die.single(Face.shield(10)), 0, 100))
	s3.add_foes([_seeker("buffed")])
	s3.begin()
	Effects.stack(s3.mechs[1].unit, Effects.STATUS["kindled"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	s3.start_round()
	assert_eq(s3.front[0].target, s3.mechs[1], "the machine carrying the buff draws it")
	# A tie is drawn level among the tied, and no other machine is picked.
	var tied := [0, 0, 0]
	for seed_value in range(100):
		var s4 := Skirmish.new(seed_value)
		for n in ["A", "B", "C"]:
			s4.add_mech(_mech(n, Die.single(Face.shield(10)), 0, 100))
		s4.add_foes([_seeker("hottest", 30, 5)])
		s4.begin()
		s4.mechs[0].heat = 8
		s4.mechs[2].heat = 8
		s4.start_round()
		tied[s4.mechs.find(s4.front[0].target)] += 1
	assert_eq(tied[1], 0, "the cold machine is never picked while two are hotter")
	assert_true(tied[0] > 30 and tied[2] > 30, "the two that tie share the picks: %s" % str(tied))
	# So a field that is level is any machine: the word needs no fallback.
	var level := [0, 0, 0]
	for seed_value in range(150):
		var s5 := Skirmish.new(seed_value)
		for n in ["A", "B", "C"]:
			s5.add_mech(_mech(n, Die.single(Face.shield(10)), 0, 100))
		s5.add_foes([_seeker("hottest", 30, 5)])
		s5.begin()
		s5.start_round()
		level[s5.mechs.find(s5.front[0].target)] += 1
	assert_true(level[0] > 25 and level[1] > 25 and level[2] > 25, "every machine cold: any of them, level (%s)" % str(level))
	# The word is the attack's, never the foe's (Ryan, 17 November: "the heat target is a
	# property of the attack, not the dragon itself"): a foe with a seeking breath and a plain
	# claw goes for the hottest with the one and for anyone with the other.
	var breath_off := 0
	var claw_cold := 0
	var claws := 0
	for seed_value in range(120):
		var s6 := Skirmish.new(seed_value)
		s6.add_mech(_mech("Cold", Die.single(Face.shield(10)), 0, 100))
		s6.add_mech(_mech("Hot", Die.single(Face.shield(10)), 0, 100))
		var drake := _ghoul(30, 5)
		drake.actions = [Foe.basic_action(), Foe.basic_action()]
		drake.actions[0]["id"] = "breath"
		drake.actions[0]["aim"] = "hottest"
		drake.actions[1]["id"] = "claw"
		drake.action = drake.actions[0]
		s6.add_foes([drake])
		s6.begin()
		s6.mechs[1].heat = 9
		s6.start_round()
		if str(drake.action["id"]) == "breath":
			if drake.target != s6.mechs[1]:
				breath_off += 1
		else:
			claws += 1
			if drake.target == s6.mechs[0]:
				claw_cold += 1
	assert_eq(breath_off, 0, "its breath lands on the hot machine every time")
	assert_true(claws > 20 and claw_cold > 5 and claw_cold < claws, "its claw picks either: %d of %d on the cold one" % [claw_cold, claws])


func test_a_move_at_every_machine_or_at_nobody_draws_no_pick() -> void:
	# Ryan, 17 November: a pick nobody sees is no pick. A blow at every machine and a move on a
	# foe's own side hold none, and each is an intent all the same.
	var sk := Skirmish.new(4)
	sk.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 100))
	sk.add_mech(_mech("B", Die.single(Face.shield(10)), 0, 100))
	var storm := _storm(5, 1, ["all"])
	var bracer := _ghoul(30, 5)
	bracer.actions = [_special("defend", "brace", {"value": 2})]
	bracer.action = bracer.actions[0]
	var plain := _ghoul(30, 5)
	sk.add_foes([storm, bracer, plain])
	sk.begin()
	sk.start_round()
	assert_true(storm.target == null, "a blow at every machine holds no pick")
	assert_true(bracer.target == null, "nor does a move on its own side")
	assert_true(plain.target != null, "a blow at one machine does")
	assert_true(storm.intends() and bracer.intends() and plain.intends(), "each shows its move all the same")
	assert_true(storm.intent_on(sk.mechs[0].unit) and storm.intent_on(sk.mechs[1].unit), "the storm's intent is on every machine")
	assert_false(bracer.intent_on(sk.mechs[0].unit) or bracer.intent_on(sk.mechs[1].unit), "and the bracer's on none")
	assert_eq(sk.forecast(sk.mechs[0])["incoming"] + sk.forecast(sk.mechs[1])["incoming"], 5 + 5 + 5, "the forecast counts the storm on each machine and the plain blow on its pick")
	# A lure has nothing of theirs to turn.
	sk._lure(sk.mechs[0], [storm, bracer, plain])
	assert_true(storm.target == null, "a lure turns no blow at every machine")
	assert_true(bracer.target == null, "and no move at nobody")
	assert_eq(plain.target, sk.mechs[0], "the aimed blow turns on the lurer")
	assert_true("\n".join(sk.log).contains("have nothing to turn"), "and the log says who had nothing to turn: %s" % sk.log[sk.log.size() - 1])
	# Neither draws from the fight's stream: the plain foe's pick is what it would be alone.
	for seed_value in range(40):
		var picks: Array[int] = []
		for crowded in [false, true]:
			var s2 := Skirmish.new(seed_value)
			s2.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 100))
			s2.add_mech(_mech("B", Die.single(Face.shield(10)), 0, 100))
			s2.add_mech(_mech("C", Die.single(Face.shield(10)), 0, 100))
			var lone := _ghoul(30, 5)
			var others: Array = []
			if crowded:
				var b2 := _ghoul(30, 6)
				b2.actions = [_special("defend", "brace", {"value": 2})]
				b2.action = b2.actions[0]
				others = [_storm(6, 1, ["all"]), b2]
			s2.add_foes(others + [lone])
			s2.begin()
			s2.start_round()
			picks.append(s2.mechs.find(lone.target))
		assert_eq(picks[0], picks[1], "seed %d: the same pick with a storm and a bracer drawn before it" % seed_value)
	# A Disrupt that turns a foe to a move at nobody drops its pick, and one that turns it to a
	# blow from a move at nobody takes the next machine in line.
	var s3 := Skirmish.new(2)
	s3.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 100))
	s3.add_mech(_mech("B", Die.single(Face.shield(10)), 0, 100))
	var turner := _ghoul(30, 5)
	turner.actions = [Foe.basic_action(), _special("defend", "brace", {"value": 2})]
	turner.actions[0]["weight"] = 1000
	turner.action = turner.actions[0]
	s3.add_foes([turner])
	s3.begin()
	s3.start_round()
	assert_true(turner.attacks(), "the blow, at that weight")
	turner.target = s3.mechs[1]
	s3._disrupt([turner])
	assert_eq(str(turner.action.get("effect", "")), "brace", "disrupted to its brace")
	assert_true(turner.target == null, "which holds no pick")
	s3._disrupt([turner])
	assert_true(turner.attacks(), "and disrupted back to its blow")
	assert_eq(turner.target, s3.mechs[0], "it takes the next machine in line, never the pick it dropped")


func test_a_moves_condition_gates_it_and_a_special_never_fires_twice_running() -> void:
	var sk := Skirmish.new(1, 1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var g := _ghoul(100, 10)
	g.actions = [Foe.basic_action(), _special("defend", "recover", {"value": 20, "when": "below_half"})]
	g.actions[1]["weight"] = 1000
	g.action = g.actions[0]
	sk.add_foes([g])
	sk.begin()
	for i in range(5):
		sk.start_round()
		assert_true(g.attacks(), "at full health the regrow is not open, whatever its weight")
		sk.end_round()
	g.hp = 40
	sk.start_round()
	assert_false(g.attacks(), "below half it opens, and the weight carries it")
	assert_eq(g.last_special, "recover", "and it is on record")
	sk.end_round()
	assert_eq(g.hp, 60, "it regrew")
	sk.start_round()
	assert_true(g.attacks(), "never twice running: the swing after the roar")
	sk.end_round()
	g.hp = 40
	sk.start_round()
	assert_false(g.attacks(), "then the special is open again")
	# A list of conditions means any; a foe whose only move is a special keeps it.
	var s2 := Skirmish.new(2, 2)
	s2.add_mech(_mech("B", Die.single(Face.attack(10, L)), 40, 100))
	var sp := _ghoul(100, 10)
	sp.actions = [_special("defend", "brace", {"value": 10, "when": ["below_half", "back_behind"]})]
	sp.action = sp.actions[0]
	s2.add_foes([sp, _archer(30, 10)])
	s2.begin()
	s2.start_round()
	assert_false(sp.attacks(), "something stands behind it, so the brace is open")
	s2.end_round()
	s2.start_round()
	assert_false(sp.attacks(), "its only move repeats: the rule needs something else to pick")
	assert_eq(Foe.whens_of(sp.actions[0]), ["below_half", "back_behind"], "the list reads back")
	assert_eq(Foe.whens_of({"when": "below_half"}), ["below_half"], "a word reads as a list of one")
	# The other words, each on its own skirmish state.
	var s3 := Skirmish.new(3, 2)
	s3.add_mech(_mech("C", Die.single(Face.attack(10, L)), 40, 100))
	var hc := _ghoul(100, 10)
	s3.add_foes([hc, _ghoul(30, 10), _ghoul(30, 10)])
	s3.begin()
	s3.start_round()
	assert_true(s3._when_holds(hc, {"when": "others_on_field"}), "another stands with it")
	assert_false(Foe.WHENS.has("few_waiting"), "no condition counts the pool (Ryan, 26 October: a summoner needs none)")
	assert_false(s3._when_holds(hc, {"when": "missing_hull", "value": 20}), "whole")
	hc.hp = 80
	assert_true(s3._when_holds(hc, {"when": "missing_hull", "value": 20}), "missing the value")


func test_a_swarm_blow_grows_with_its_kin_on_the_field_and_falls_as_they_die() -> void:
	var sk := Skirmish.new(1, 4)
	var m := _mech("A", Die.single(Face.attack(40, L)), 40, 100)
	sk.add_mech(m)
	var pack: Array = []
	for i in range(6):
		var g := _ghoul(30, 5)
		g.actions = [{"id": "claw", "name": "Claw", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": "", "swarm": 5}]
		g.action = g.actions[0]
		pack.append(g)
	sk.add_foes(pack)
	sk.begin()
	sk.start_round()
	assert_eq(sk.front[0].kin, 3, "four on the field: three kin each")
	assert_eq(sk.front[0].damage(), 20, "5 plus 5 a kin")
	assert_eq(sk.front[0].text_of(sk.front[0].action), "", "no text set")
	assert_true(sk.assign(0, sk.front[1]), "one dies")
	assert_eq(sk.front[0].kin, 2, "the kin count drops at once")
	assert_eq(sk.front[0].damage(), 15, "and so does every claw, before the blows land")
	sk.end_round()
	assert_eq(sk.front[1], null, "nothing steps into its slot (no reinforcement inside a fight)")
	assert_eq(sk.front[0].kin, 2, "so the swarm stays three")
	assert_eq(sk.front[0].damage(), 15, "and its claw 15")


func test_heat_overflow_damages_hull() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("Hot", Die.single(Face.attack(10, L, K.NONE, 80)), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "fire the hot gun")
	assert_eq(sk.mechs[0].heat, 80, "the gauge runs past its cap during the round")
	assert_eq(m.hull, 100, "nothing burns yet")
	sk.end_round()
	assert_eq(sk.mechs[0].heat, 80, "the gauge does not settle: what stands past its cap stays until the machine reboots")
	assert_eq([m.shield, sk.mechs[0].shield_broken], [0, true], "its first overheat breaks its shield")
	assert_eq(m.hull, 70, "the twenty over the cap burnt the hull, and the ghoul's ten landed on it bare")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 40, "and it burns again the next turn, twenty more beside the ghoul's ten")


func test_machine_targets_are_the_components_to_set() -> void:
	var sk := Skirmish.new(1)
	var own := Face.shield(10)
	own.targets = Face.Target.SELF
	var give := Face.vent(10)
	give.targets = Face.Target.ALLY
	var a := _mech("A", Die.single(own), 40, 100)
	var b := _mech("B", Die.single(give), 40, 100)
	a.shield = 5   # a sliver standing: a shield at nothing is broken and takes none
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(own.describe(), "shield 10 (self only)", "the restriction reads on the entry")
	assert_eq(sk.machine_targets_for(sk.mechs[0], own).size(), 1, "a self-only shield offers one target")
	assert_false(sk.assign(0, sk.mechs[1]), "and refuses an ally")
	assert_true(sk.assign(0, null), "self is fine")
	assert_eq(a.shield, 15, "shielded")
	assert_false(sk.assign(1, null), "an allies-only vent refuses self")
	assert_true(sk.assign(1, sk.mechs[0]), "and takes the ally")
	var default_face := Face.shield(10)
	assert_eq(sk.machine_targets_for(sk.mechs[0], default_face).size(), 2, "the default reaches everyone alive")
	assert_true(Face.attack(10, L).is_weapon() and not Face.attack(10, L).on_machines(), "an attack is a weapon")
	# The types in Ryan's words of 26 October: a weapon deals damage; a buff or a debuff is
	# equipment; a shield, a vent and a buff are spent on machines.
	var probe := Face.attack(0, L, [Face.Keyword.SUPPRESS])
	assert_true(probe.is_equipment() and not probe.is_weapon() and probe.is_attack(), "a debuff is equipment aimed at a foe, never a weapon")
	assert_true(Face.buff("overcharged", 1).is_equipment() and not Face.shield(4).is_equipment() and not Face.vent(3).is_equipment(), "a buff is equipment; a shield and a vent are their own kinds")
	var d := Face.from_dict({"kind": "shield", "power": 20, "targets": "ally"})
	assert_eq(d.targets, Face.Target.ALLY, "targets read from content")
	assert_eq(d.to_dict().get("targets", ""), "ally", "and written back")


func test_suppress_cancels_intent() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 30)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(m.hull, 100, "suppressed ghoul did not strike")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 70, "next round it does")


func test_ablating_ticks_down_on_a_foe() -> void:
	var sk := Skirmish.new(1)
	var torch := Face.attack(30, L, K.ABLATE)
	torch.ablate = 3   # Ablate 3 (Ryan, 18 October): the keyword's number, whatever the blow deals
	var m := _mech("A", Die.single(torch), 90, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var g: Foe = sk.front[0]
	assert_eq(g.hp, 60, "took 30 on hit")
	assert_eq(g.ablate_stacks(), 3, "three stacks of Ablating: the Ablate's number, not the blow's")
	assert_eq(torch.describe(), "30 ablate 3", "the entry shows the number")
	sk.end_round()
	assert_eq(g.hp, 57, "burn ticked for 3: three stacks of one")
	assert_eq(g.ablate_stacks(), 2, "one stack consumed")


## A blow that grows with its target's missing hull (10 October, the Kite's rifle): flat,
## +5 for every 20 the target has lost, read as the die is spent, and the bot reads the same.
func test_a_blow_grows_with_its_targets_missing_hull() -> void:
	var gun := Face.attack(10, L)
	gun.power_per_missing = 5
	var whole := _ghoul(200)
	var hurt := _ghoul(200)
	hurt.hp = 130   # 70 missing: three steps of 20
	assert_eq(gun.missing_bonus(whole), 0, "a whole foe adds nothing")
	assert_eq(gun.missing_bonus(hurt), 15, "70 missing is three steps")
	assert_eq(gun.missing_bonus(null), 0, "no target, no bonus")
	assert_eq(Face.from_dict(gun.to_dict()).power_per_missing, 5, "it survives the content round-trip")
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("A", Die.single(gun)))
	sk.add_foes([hurt])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY)
	assert_eq(pol.expected_damage(sk.mechs[0], gun, hurt), 25.0, "the bot reads 25")
	sk.assign(0, sk.front[0])
	assert_eq(hurt.hp, 105, "and 25 lands")


## The face shows the number (10 October, bible section 5): what the blow will deal now, and
## held over a foe, what it deals to that foe. Flat means no roll, however much feeds it.
func test_an_emptying_entry_says_what_it_does_and_round_trips() -> void:
	# Ryan, 20 November: the Bullion Fragmenter empties the hopper, a strike an Ore (its engine in
	# tests/test_badger.gd).
	var gun := Face.from_dict({"kind": "attack", "reach": "direct", "power": 2, "empties_hopper": true})
	assert_eq(gun.describe(), "2 a strike for every Ore it empties", "the entry says what it does")
	assert_true(gun.has_unique_rule(), "a rule printed on the entry: the star chip")
	assert_false(gun.is_debuff(), "a weapon")
	assert_true(Face.from_dict(gun.to_dict()).empties_hopper, "it round-trips")


func test_a_bracing_entry_armours_its_owner_until_its_sides_next_turn_begins() -> void:
	# Ryan, 12 October: the Breaching Plow braces the Boar behind its blade, in place of the
	# Glacis. Spending a bracing entry Armours its owner, the stacks it says, until its side's
	# next turn begins (16 November: "Armoured we should change so its end is symmetrical on both
	# sides"): the armour stands through the enemy's turn and goes as the next round opens.
	var sk := Skirmish.new(1)
	var plow := Face.from_dict({"kind": "attack", "reach": "direct", "power": 10, "braces": 10})
	assert_eq(plow.describe(), "10 braces ×10", "the entry says what it does")
	assert_true(plow.has_unique_rule(), "a rule printed on the entry: the star chip")
	assert_eq(Face.from_dict(plow.to_dict()).braces, 10, "it round-trips")
	var m := _mech("A", Die.single(plow), 0, 200)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 20)])
	sk.begin()
	sk.start_round()
	var armour: int = m.armour
	assert_true(sk.assign(0, sk.front[0]), "the plow")
	assert_eq(Effects.stacks_of(m, "braced"), 10, "ten stacks of Armoured, an armour point each")
	assert_eq(m.armour, armour + 10, "armour +10 through the enemy's turn")
	assert_true("\n".join(sk.log).contains("braces: Armoured ×10"), "the log says so")
	var hull: int = m.hull
	sk.end_round()
	assert_eq(hull - m.hull, maxi(0, 20 - (armour + 10)), "the ghoul's 20 lands less the brace")
	assert_eq(Effects.stacks_of(m, "braced"), 10, "it stands at the round's end")
	sk.start_round()
	assert_eq([Effects.stacks_of(m, "braced"), m.armour], [0, armour], "and goes as its side's next turn begins, before the foes announce")
	# A foe's goes the same way on its own side: as the enemy's turn opens.
	var g: Foe = sk.front[0]
	Effects.stack(g, Effects.STATUS["braced"], Effects.SKIRMISH, "foe", 2, Effects.status_decay(Effects.STATUS["braced"]))
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "braced"), 0, "a foe's Armoured from before its turn is gone as that turn opens")


func test_braced_lasts_one_turn_from_every_source() -> void:
	# Ryan, 12 October: a defensive buff that lingered, a stack fading a round, would stack
	# into a wall. A passive's Armoured (the Phase Conjugator's) goes whole as its side's next
	# turn begins, like a buff's; the round's own tick leaves it.
	var m := _mech("A", Die.single(Face.attack(10)))
	m.grant_passive({"id": "brace_on_hit", "name": "Brace", "description": "",
		"effects": [{"trigger": "on_hull_damage", "effect": "stack_status", "value": "braced"}]})
	Effects.fire(m, "on_hull_damage")
	Effects.fire(m, "on_hull_damage")
	assert_eq(Effects.stacks_of(m, "braced"), 2, "two stacks from the passive")
	Effects.tick(m, true)
	assert_eq(Effects.stacks_of(m, "braced"), 2, "the round's tick leaves them")
	Effects.turn_opens(m)
	assert_eq(Effects.stacks_of(m, "braced"), 0, "every stack goes as the turn opens, none lingers")
	# A buff of Armoured for two rounds, which the validator refuses in content, is held no longer.
	Effects.grant_buff(m, "braced", 3, "buff:test", 9)
	Effects.end_round(m, 1)
	assert_eq(Effects.stacks_of(m, "braced"), 3, "no round's end takes it")
	Effects.turn_opens(m)
	assert_eq(Effects.stacks_of(m, "braced"), 0, "its end is its side's next turn, whatever round the grant named")


func test_the_bot_values_a_brace_by_the_blows_coming() -> void:
	var sk := Skirmish.new(1)
	var plow := Face.from_dict({"kind": "attack", "reach": "direct", "power": 10, "braces": 10})
	var bare := _mech("A", Die.single(plow), 0, 200)
	var ms := sk.add_mech(bare)
	sk.add_foes([_ghoul(500, 20), _ghoul(500, 3)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY, 1)
	var arm: int = bare.armour
	var saved := mini(10, maxi(0, 20 - arm)) + mini(10, maxi(0, 3 - arm))
	assert_eq(pol.brace_score(sk, ms, 10), float(saved) * Policy.HULL_WEIGHT, "the armour each coming blow loses, in hull")
	bare.shield = 30
	assert_eq(pol.brace_score(sk, ms, 10), 0.0, "a standing shield takes every blow whole: nothing to brace against")


func test_the_shown_number_is_what_the_blow_will_deal() -> void:
	var sk := Skirmish.new(1)
	var gun := Face.attack(10, L)
	var rifle := Face.attack(10)
	rifle.power_per_missing = 5
	var cannon := Face.from_dict({"kind": "attack", "reach": "direct", "power": 20, "vents_all": true, "power_per_heat": 10})
	var m := _mech("A", Die.of([gun, rifle, cannon]), 40, 100)
	sk.add_mech(m)
	var hard := _ghoul(200)
	hard.armour = 5
	hard.hp = 120   # 80 missing: four steps of 20
	sk.add_foes([hard])
	sk.begin()
	sk.start_round()
	var ms := sk.mechs[0]
	assert_eq(sk.shown_number(ms, gun), 10, "the gun's own number")
	assert_eq(sk.shown_number_text(ms, gun), "10", "printed plain")
	assert_eq(sk.shown_number_text(ms, rifle), "10", "the rifle with nobody under it")
	assert_eq(sk.shown_number_text(ms, rifle, hard), "25", "over the wounded foe: 10, +20 for its missing hull, -5 armour")
	assert_eq(sk.shown_number_text(ms, gun, hard), "5", "armour comes off it too")
	ms.heat = 30
	assert_eq(sk.shown_number_text(ms, cannon), "50", "a gun that vents all shows what its heat will add: 20, +10 a 10 heat")
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.SKIRMISH, "test", 5)   # five stacks, a point each (18 October)
	assert_eq(sk.shown_number_text(ms, rifle), "15", "a buff on the machine shows on the face")
	assert_eq(sk.shown_number_text(ms, rifle, hard), "30", "and over the foe")
	ms.face_index = 1
	sk.assign(0, hard)
	assert_eq(hard.hp, 90, "and the spend deals exactly the 30 it showed")


func test_static_energy_face_never_varies() -> void:
	for seed_value in range(1, 11):
		var sk := Skirmish.new(seed_value)
		sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
		sk.add_foes([_ghoul(200)])
		sk.begin()
		sk.start_round()
		sk.assign(0, sk.front[0])
		assert_eq(sk.front[0].hp, 170, "static face always deals 30")


func test_victory_when_reinforcements_exhausted() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	sk.add_foes([_ghoul(20)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "victory the moment the last foe falls")
	assert_eq(sk.state, Skirmish.State.DONE, "skirmish done, no End turn needed")


func test_defeat_when_all_hulls_zero() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 20))
	sk.add_foes([_ghoul(90, 50)])
	sk.begin()
	sk.start_round()
	var out := sk.end_round()
	assert_eq(out, Skirmish.Outcome.DEFEAT, "defeat")


## No reinforcement inside a fight (Ryan, 6 November: "Cut"): a pack is what its slots hold, so
## the foes past them are never dealt (the log says so), and a kill's slot stays empty at the
## round's end: nothing steps into it.
func test_nothing_steps_into_a_kills_slot() -> void:
	var sk := Skirmish.new(1, 3)   # three wide: the rank rules, not the default width
	sk.add_mech(_mech("A", Die.single(Face.attack(90, L))))
	var foes: Array = []
	for i in range(8):
		foes.append(_ghoul(30))
	sk.add_foes(foes)
	sk.begin()
	assert_eq(sk.field_foes().size(), 3, "three on the field")
	assert_true(sk.reinforcements.is_empty(), "the five past the slots never dealt")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("could not stand")), "the log says so")
	sk.start_round()
	sk.assign(0, sk.front[1])
	sk.end_round()
	assert_eq(sk.field_foes().size(), 2, "the gap stays a gap")
	assert_eq(sk.front[1], null, "nothing stepped into it")


## There is no withdrawal (the long wall brief 3.5; Ryan, 6 November: "what if there's just NO
## withdrawal?"): refused at every state of a fight, and a refusal changes nothing.
func test_no_fight_has_a_withdrawal() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 10)])
	assert_false(sk.can_withdraw(), "none before the fight begins")
	sk.begin()
	assert_false(sk.can_withdraw(), "none before the first roll")
	sk.start_round()
	assert_false(sk.can_withdraw(), "none at the start of round one")
	sk.assign(0, sk.front[0])
	assert_false(sk.can_withdraw(), "none after spending")
	sk.end_round()
	assert_false(sk.can_withdraw(), "none between rounds")
	sk.start_round()
	var hull := m.hull
	assert_false(sk.withdraw(), "refused in round two")
	assert_eq(sk.outcome, Skirmish.Outcome.NONE, "the fight goes on")
	assert_eq(sk.state, Skirmish.State.ASSIGN, "still the player's turn")
	assert_eq(m.hull, hull, "and nothing struck")
	win_fight(sk)
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "it ends by the foes' fall")
	assert_false(sk.can_withdraw(), "and none once it is over")

func test_rerolls_are_limited_and_work_after_attacking() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L))))
	sk.add_mech(_mech("B", Loadouts.gunner_die()))
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "A attacks first")
	assert_true(sk.reroll([1]), "then B rerolls: attack-then-reroll is allowed")
	for n in range(Skirmish.REROLLS_PER_ROUND - 1):
		assert_true(sk.reroll([1]), "reroll %d of the round's" % (n + 2))
	assert_false(sk.reroll([1]), "one past the round's refused")


## A reroll of nothing spends nothing (the audit's tenth bug, 8 November): with no unspent die
## named it is refused and the team keeps its reroll, and with every die spent none is open.
func test_a_reroll_of_nothing_spends_nothing() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L))))
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	var before := sk.rerolls_left
	assert_false(sk.reroll([]), "nothing named: refused")
	assert_true(sk.assign(0, sk.front[0]), "the one die spent")
	assert_false(sk.reroll([0]), "a spent die named: refused")
	assert_eq(sk.rerolls_left, before, "and no reroll spent either way")
	assert_false(sk.can_reroll(), "with every die spent no reroll is open")


func test_same_seed_same_rolls() -> void:
	var a := Skirmish.new(99)
	var b := Skirmish.new(99)
	for sk in [a, b]:
		sk.add_mech(_mech("A", Loadouts.gunner_die()))
		sk.add_mech(_mech("B", Loadouts.mortar_die()))
		sk.add_foes([_ghoul(90)])
		sk.begin()
		sk.start_round()
	assert_eq(a.mechs[0].face_index, b.mechs[0].face_index, "mech A rolls match")
	assert_eq(a.mechs[1].face_index, b.mechs[1].face_index, "mech B rolls match")


func _destroyed_count(d: Die) -> int:
	var n := 0
	for f in d.faces:
		if f.kind == Face.Kind.BLANK:
			n += 1
	return n


## No blow destroys a component by its size (the injury rule's quarter of the hull, 17 September
## to 15 November; Ryan: "No longer a general rule"). Destroy is a rider on a foe's blow ("a
## boss-level rider, that destroys the visible face if it damages hull at all"): any of it on the
## hull and the entry the die shows is destroyed, the forecast and the round's preview naming the
## risk and the blow's event what it did.
func test_only_a_blow_that_carries_destroy_destroys_the_entry_showing() -> void:
	for rider in [false, true]:
		var sk := Skirmish.new(3)
		var d := Die.of([Face.attack(10, L, K.CLEAVE), Face.attack(10, L, K.PENETRATE)])
		var m := _mech("A", d, 0, 100)
		sk.add_mech(m)
		sk.add_foes([_storm(50, 1, ["destroy"] if rider else [])])
		sk.begin()
		sk.start_round()
		var showing := sk.mechs[0].face_index
		var fc: Dictionary = sk.forecast(sk.mechs[0])
		assert_eq(bool(fc.get("component_risk", false)), rider, "the forecast names a component at risk only under the rider (%s)" % str(rider))
		assert_eq(bool(sk.preview_round()["mechs"][0]["component_risk"]), rider, "and so does the round's preview (%s)" % str(rider))
		sk.end_round()
		assert_eq(m.hull, 50, "the blow lands whole either way (%s)" % str(rider))
		assert_eq(sk.destroyed, 1 if rider else 0, "half the hull in one blow destroys an entry only under the rider (%s)" % str(rider))
		assert_eq(_destroyed_count(d), 1 if rider else 0, "and blanks it only then (%s)" % str(rider))
		assert_eq(str(sk.turn_events[0].get("component", "")), "destroyed" if rider else "", "the blow's event says what it did, for the console (%s)" % str(rider))
		if rider:
			assert_eq(d.faces[showing].kind, Face.Kind.BLANK, "the entry the die showed is the one that breaks")


## Destroy reads the hull and nothing else: a point on it is enough, and a blow the shield takes
## whole, the armour turns or a Barrier takes destroys nothing. It is a rider, so a Ward turns it
## away with the rest though the blow lands; and a passive that holds its components holds them.
func test_destroy_needs_the_hull_however_small_the_blow() -> void:
	# [the blow, shield, armour, a Barrier, a Ward, a passive that holds, entries destroyed]
	var cases := [
		[1, 0, 0, false, false, false, 1, "a point on bare hull"],
		[50, 60, 0, false, false, false, 0, "a blow the shield takes whole"],
		[50, 49, 0, false, false, false, 1, "a point past the shield"],
		[5, 0, 5, false, false, false, 0, "a blow the armour turns"],
		[50, 0, 0, true, false, false, 0, "a blow a Barrier takes"],
		[50, 0, 0, false, true, false, 0, "a rider a Ward turns away"],
		[50, 0, 0, false, false, true, 0, "a component its passive holds"],
	]
	for c in cases:
		var sk := Skirmish.new(2)
		var d := Die.of([Face.attack(10, L, K.CLEAVE), Face.attack(10, L, K.PENETRATE)])
		var m := _mech("A", d, int(c[1]), 100)
		m.armour = int(c[2])
		if bool(c[5]):
			m.grant_passive({"id": "hold", "name": "Hold", "description": "", "effects": [{"trigger": "on_injury", "effect": "no_destroy", "value": 1}]})
		sk.add_mech(m)
		sk.add_foes([_storm(int(c[0]), 1, ["destroy"])])
		sk.begin()
		sk.start_round()
		if bool(c[3]):
			Effects.stack(m, Effects.STATUS["barrier"], Effects.ROUNDS, "test", 1, Effects.DECAY_NONE, sk.round)
		if bool(c[4]):
			Effects.stack(m, Effects.STATUS["ward"], Effects.ROUNDS, "test", 1, Effects.DECAY_NONE, sk.round)
		var said := str(c[7])
		assert_eq(bool(sk.forecast(sk.mechs[0])["component_risk"]), int(c[6]) > 0, "%s: the forecast" % said)
		assert_eq(bool(sk.preview_round()["mechs"][0]["component_risk"]), int(c[6]) > 0, "%s: the round's preview" % said)
		sk.end_round()
		assert_eq(_destroyed_count(d), int(c[6]), "%s: the entries destroyed" % said)
	# Two strikes: the first destroys the entry showing and the second finds nothing left.
	var sk2 := Skirmish.new(2)
	var d2 := Die.of([Face.attack(10, L, K.CLEAVE), Face.attack(10, L, K.PENETRATE)])
	sk2.add_mech(_mech("A", d2, 0, 100))
	sk2.add_foes([_storm(10, 2, ["destroy"])])
	sk2.begin()
	sk2.start_round()
	sk2.end_round()
	assert_eq(_destroyed_count(d2), 1, "two strikes break the one entry showing, never a second")
	assert_true("\n".join(sk2.log).contains("nothing left to break"), "and the log says the second found it broken")


## An injury breaks the entry the die shows (2 November, in place of the die's roll): what faces
## the enemy is the player's choice, a blank showing shrugs it off, and a second blow on the
## same showing entry finds it broken already.
func test_an_injury_breaks_the_entry_showing_and_a_broken_one_shrugs_it_off() -> void:
	var sk := Skirmish.new(5)
	var d := Die.of([Face.blank(), Face.attack(10, L, K.CLEAVE), Face.attack(10, L, K.PENETRATE)])
	var m := _mech("A", d, 0, 100)
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 2
	assert_eq(sk.apply_injury(sk.mechs[0]), "destroyed", "the entry showing breaks")
	assert_eq([d.faces[1].kind, d.faces[2].kind], [Face.Kind.ATTACK, Face.Kind.BLANK], "the other gun stands")
	assert_eq(sk.apply_injury(sk.mechs[0]), "", "a second blow finds it broken already")
	assert_true(str(sk.log[sk.log.size() - 1]).contains("nothing left to break"), "and says so")
	sk.mechs[0].face_index = 0
	assert_eq(sk.apply_injury(sk.mechs[0]), "", "a blank showing shrugs it off")
	assert_eq(m.damaged_component_count(), 1, "one damaged component in all")


func test_injury_destroys_and_persists_until_repaired() -> void:
	# One state (Ryan, 25 October: "Cracked is gone"): an injury destroys what it lands on.
	var sk := Skirmish.new(3)
	var d := Die.single(Face.attack(30, L, [K.CLEAVE, K.ABLATE], 10))
	var m := _mech("A", d, 0, 100)
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.apply_injury(sk.mechs[0]), "destroyed", "the first injury destroys it")
	assert_eq(d.faces[0].kind, Face.Kind.BLANK, "blank")
	assert_true(str(sk.log[sk.log.size() - 1]).contains("a component is destroyed"), "and the log says so")
	assert_eq(m.damaged_component_count(), 1, "one damaged component on the unit")
	assert_eq(sk.apply_injury(sk.mechs[0]), "", "a second finds nothing left to break")
	assert_eq(m.damaged_component_count(), 1, "still one component")
	sk.end_round()
	win_fight(sk)
	assert_eq(d.faces[0].kind, Face.Kind.BLANK, "the skirmish ending does not repair it")
	# A second skirmish with the same unit starts with the damage in place.
	var again := Skirmish.new(4)
	again.add_mech(m)
	again.add_foes([Foe.make("revenant", 90, 10)])
	again.begin()
	again.start_round()
	assert_eq(again.mechs[0].face().kind, Face.Kind.BLANK, "the destroyed face is still destroyed next fight")
	m.repair_faces()
	assert_eq(d.faces[0].kind, Face.Kind.ATTACK, "hangar repair restores the component")
	assert_true(d.faces[0].has(K.CLEAVE) and d.faces[0].has(K.ABLATE), "with its keywords")
	assert_eq(m.damaged_component_count(), 0, "nothing left to repair")


func _colossus(hp: int = 140) -> Foe:
	var f := Foe.make("colossus", hp, 30)
	f.size = 2
	return f


func test_massive_foe_fills_a_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	sk.add_foes([_ghoul(), _ghoul(), _colossus(), _archer()])
	sk.begin()
	var col := -1
	for c in range(3):
		if sk.front[c] != null and sk.front[c].is_massive():
			col = c
	assert_true(col >= 0, "colossus placed in a column")
	assert_eq(sk.back[col], sk.front[col], "same foe in both slots")
	assert_false(sk.is_exposed(col), "its column is never exposed")
	assert_eq(sk.field_foes().size(), 4, "field lists it once")
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.count(sk.front[col]), 1, "line of fire lists it once")


func test_massive_foe_death_clears_both_slots() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(200, L))))
	sk.add_foes([_colossus(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "hit the colossus")
	assert_eq(sk.front[0], null, "front slot cleared at once")
	assert_eq(sk.back[0], null, "back slot cleared at once")
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "and that was the whole pack")


func test_penetrate_hits_a_massive_foe_once() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.PENETRATE))))
	sk.add_foes([_colossus(140)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 110, "took 30, not 60")


func test_shield_component_helps_an_ally() -> void:
	var sk := Skirmish.new(1)
	var giver := _mech("Giver", Die.single(Face.shield(30)), 40, 100)
	var taker := _mech("Taker", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(giver)
	sk.add_mech(taker)
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.mechs[1]), "shield the ally")
	assert_eq(taker.shield, 0, "capped at the ally's shield max of 0")
	taker.shield_max = 50
	taker.shield = 10   # standing: a shield at nothing is broken and takes none
	sk.mechs[0].assigned = false
	assert_true(sk.assign(0, sk.mechs[1]), "shield again with room")
	assert_eq(taker.shield, 40, "ally gained 30")


func test_forecast_predicts_shield_break_and_hull_loss() -> void:
	var sk := Skirmish.new(1)
	var m := Unit.mech(1, "A", Vector2i.ZERO)
	m.hull = 100
	m.hull_max = 100
	m.shield = 20
	m.shield_max = 20
	m.die = Die.single(Face.attack(10))
	var ms := sk.add_mech(m)
	sk.add_foes([Foe.make("a", 30, 25), Foe.make("b", 30, 30)])
	sk.begin()
	sk.start_round()
	var fc := sk.forecast(ms)
	assert_eq(fc["incoming"], 55, "both foes aim at the only mech")
	assert_eq(fc["shield_after"], 0, "55 incoming takes the 20 shield")
	assert_eq(fc["hull_after"], 65, "the thirty stands left and strikes first: the shield takes twenty and ten pass; the twenty-five lands on bare hull")
	assert_false(fc["component_risk"], "and no component is at risk: no blow destroys one by its size")
	assert_false(fc["destroyed"], "still standing")
	sk._suppress(sk.front[0])
	fc = sk.forecast(ms)
	assert_eq(fc["incoming"], 25, "a suppressed foe does not count")
	sk.front[1].hp = 0
	fc = sk.forecast(ms)
	assert_eq(fc["incoming"], 0, "a dead foe does not count")
	assert_eq(fc["shield_after"], 20, "nothing incoming, the shield stands")


func test_forecast_predicts_wreck_and_overheat() -> void:
	var sk := Skirmish.new(2)
	var m := Unit.mech(1, "A", Vector2i.ZERO)
	m.hull = 20
	m.hull_max = 100
	m.shield = 0
	m.shield_max = 40
	m.heat_max = 30
	m.die = Die.single(Face.attack(10, Face.Reach.DIRECT, [], 40))
	var ms := sk.add_mech(m)
	sk.add_foes([Foe.make("a", 30, 25)])
	sk.begin()
	sk.start_round()
	var fc: Dictionary = sk.preview_round(0, sk.front[0])["mechs"][0]   # the die in hand, over its foe
	assert_eq(fc["overheat"], 10, "a 40-heat face on a 30 cap overheats by 10")
	assert_eq(fc["heat_after"], 40, "and the heat stays on the gauge, past its cap")
	assert_true(fc["destroyed"], "25 through plus 10 overheat beats 20 hull")
	assert_eq(sk.forecast(ms)["overheat"], 0, "the round as it stands counts no die")
	sk.assign(0, sk.front[0])
	fc = sk.forecast(ms)
	assert_eq(ms.heat, 40, "the heat is on the gauge, past the cap")
	assert_eq(m.hull, 20, "nothing burnt yet")
	assert_eq(fc["overheat"], 10, "the burn is still coming at the end of the turn")
	assert_eq(int(sk.preview_round()["mechs"][0]["overheat"]), 10, "the round preview says the same: it is spent")


## A foe's Ablating takes its points as its turn ends, its action done (Ryan, 16 November: "Its
## turn End: ... Ablate, Vitriol"), so a foe its burn will fell still strikes first, whole (4
## November: never "a zero-hp enemy attacking and then dying after"): the forecast counts its blow.
func test_forecast_counts_a_foe_its_burn_will_fell_since_it_strikes_first() -> void:
	var sk := Skirmish.new(3)
	var m := Unit.mech(1, "A", Vector2i.ZERO)
	m.die = Die.single(Face.attack(10))
	var ms := sk.add_mech(m)
	sk.add_foes([Foe.make("a", 10, 25)])
	sk.begin()
	sk.start_round()
	Effects.stack(sk.front[0], Effects.STATUS["ablating"], Effects.SKIRMISH, "test", 10)   # ten stacks, a point each (18 October)
	assert_eq(sk.forecast(ms)["incoming"], 25, "ten stacks of one fell a ten-hp foe as its turn ends: its blow lands first")
	assert_true(sk.front[0].intent_on(m), "its intent on the machine stands")
	assert_true(sk.acting_on(ms).has(sk.front[0]), "and the forecast counts its blow")
	var burner: Foe = sk.front[0]
	sk.end_round()
	assert_eq(sk.turn_events.map(func(ev) -> int: return int(ev["amount"]) if ev.get("foe") == burner else 0), [25], "it struck whole")
	assert_false(burner.alive(), "and burned down after, its turn over")


## A reroll skips only the entry showing; a copy of it may come up, at the odds its copies
## give it (Ryan, 15 October). Skipping copies too was abusable: a die of one key entry and
## copies of one filler sent every reroll from a filler onto the key.
func test_reroll_lands_on_any_other_face_a_copy_included() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var die := Die.of([
		Face.attack(20, Face.Reach.DIRECT),
		Face.attack(20, Face.Reach.DIRECT),
		Face.attack(30),
		Face.shield(20),
	])
	var landed := {}
	for trial in range(200):
		var next := die.reroll(rng, 0)
		assert_ne(next, 0, "never the entry showing")
		landed[next] = true
	assert_true(landed.has(1), "its copy comes up")
	assert_true(landed.has(2) and landed.has(3), "and so does every other entry")
	var rigged := Die.of([Face.attack(50), Face.attack(5), Face.attack(5), Face.attack(5)])
	var keys := 0
	for trial in range(300):
		if rigged.reroll(rng, 1) == 0:
			keys += 1
	assert_true(keys > 60 and keys < 140, "from a filler the key comes up a third of the time, never every time (%d of 300)" % keys)
	var same := Die.of([Face.attack(10), Face.attack(10)])
	assert_eq(same.reroll(rng, 0), 1, "a die of copies moves to the other copy")
	var one := Die.single(Face.attack(10))
	assert_eq(one.reroll(rng, 0), 0, "a one-faced die keeps its face")


func test_skirmish_reroll_moves_every_unlocked_die() -> void:
	var db := ContentDB.load_default()
	for seed_value in range(1, 25):
		var sk := Skirmish.new(seed_value)
		for id in ["badger", "clydesdale", "kite"]:
			sk.add_mech(db.make_mech(id))
		sk.add_foes([Foe.make("revenant", 30, 10)])
		sk.begin()
		sk.start_round()
		var before: Array = []
		for ms in sk.mechs:
			before.append(ms.face_index)
		sk.reroll([0, 1, 2])
		for i in range(3):
			assert_ne(sk.mechs[i].face_index, before[i], "seed %d mech %d lands on another entry" % [seed_value, i])


func test_four_columns_fill_and_reach() -> void:
	var sk := Skirmish.new(1, 4)
	var sweep := Face.attack(20, L, K.CLEAVE)
	sweep.cleave = 10
	sk.add_mech(_mech("A", Die.single(sweep)))
	# Ranks hold: six front ghouls fill four front slots and two are never dealt; four archers take the back.
	var foes: Array = []
	for i in range(6):
		foes.append(_ghoul(50))
	for i in range(4):
		foes.append(_archer(50))
	sk.add_foes(foes)
	sk.begin()
	assert_eq(sk.columns, 4, "four wide")
	assert_eq(sk.front.size(), 4, "four front slots")
	assert_eq(sk.field_foes().size(), 8, "eight on the field")
	assert_true(sk.reinforcements.is_empty(), "the two past the slots never dealt")
	sk.start_round()
	assert_eq(sk.targets_for(0).size(), 4, "every front foe is a line target")
	assert_true(sk.assign(0, sk.front[3]), "cleave the right edge")
	assert_eq(sk.front[3].hp, 30, "edge took 20")
	assert_eq(sk.front[2].hp, 40, "its one neighbour took its Spread 10")
	assert_eq(sk.front[1].hp, 50, "the far column is untouched")
	var three := Skirmish.new(1)
	assert_eq(three.columns, Skirmish.DEFAULT_COLUMNS, "three by default")


func test_no_destroy_passive_holds_an_injured_component() -> void:
	var sk := Skirmish.new(3)
	var d := Die.single(Face.attack(30, L, [K.CLEAVE]))
	var m := _mech("A", d, 0, 100)
	m.grant_passive({"id": "hold", "name": "Hold", "description": "", "effects": [{"trigger": "on_injury", "effect": "no_destroy", "value": 1}]})
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	for i in range(3):
		assert_eq(sk.apply_injury(sk.mechs[0]), "", "the injury lands and holds (%d)" % i)
	assert_eq(d.faces[0].kind, Face.Kind.ATTACK, "never destroyed")
	assert_true(d.faces[0].has(K.CLEAVE), "and untouched, its keywords kept")
	assert_true(str(sk.log[sk.log.size() - 1]).contains("holds"), "and the log says it held")
	assert_eq(m.damaged_component_count(), 0, "nothing damaged")


func test_injury_on_an_empty_hardpoint_breaks_nothing() -> void:
	var sk := Skirmish.new(3)
	var d := Die.single(Face.empty_slot())
	var m := _mech("A", d, 0, 100)
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.apply_injury(sk.mechs[0])
	assert_true(str(sk.log[sk.log.size() - 1]).contains("empty hardpoint"), "the log names the empty hardpoint")
	assert_eq(m.damaged_component_count(), 0, "nothing was there to damage")
	assert_eq(d.faces[0].describe(), "empty hardpoint", "described as empty, not destroyed")


func test_shield_never_comes_back_on_its_own_in_a_fight() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 100)
	m.shield_max = 40
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 0)])
	sk.begin()
	sk.start_round()
	sk.end_round()
	sk.start_round()
	assert_eq(m.shield, 0, "no trickle between rounds")
	m.shield = 38
	assert_eq(m.recharge_shield(100), 2, "a shield gain is capped at max")
	assert_eq(m.shield, 40, "at max")


## A granted shield regen (a module's or a passive's: a chassis has none of its own since the
## reboot): a machine regains it at each round's start after the cooling, up to its maximum, one
## log line for all. A sealed machine's regen runs: the Polar Bear's seal stops its cooling, and
## nothing says it stops the regen.
func test_a_granted_shield_regen_comes_back_each_round_to_the_maximum_sealed_or_not() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(1, L)), 10, 100)
	m.grant_passive({"id": "mender", "name": "Mender", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "shield_regen", "value": 2}]})
	m.shield = 5
	m.grant_passive({"id": "lockdown", "name": "Lockdown", "description": "", "effects": [
		{"trigger": "static", "effect": "seal_form"}]})
	var plain := _mech("B", Die.single(Face.attack(1, L)), 10, 100)
	plain.shield = 5
	sk.add_mech(m)
	sk.add_mech(plain)
	sk.add_foes([_ghoul(500, 0)])
	sk.begin()
	sk.start_round()
	assert_eq(m.shield, 7, "two back at the round's start")
	assert_eq(plain.shield, 5, "none where nothing grants it")
	assert_true("\n".join(sk.log).contains("shield regen: A +2"), "one log line says so")
	sk.end_round()
	sk.start_round()
	assert_eq(m.shield, 9, "two more")
	sk.end_round()
	sk.start_round()
	assert_eq(m.shield, 10, "capped at the maximum")
	Effects.stack(m, Effects.STATUS["sealed"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(Effects.is_sealed(m), "sealed")
	m.shield = 4
	sk.end_round()
	sk.start_round()
	assert_true(Effects.is_sealed(m), "still sealed as the round opens")
	assert_eq(m.shield, 6, "the regen runs while sealed")


## Shield regen granted (a module's, a passive's, a status's; a chassis has none of its own): paid as
## the round opens, after the cooling, in the regen's one log line, up to the maximum. The heat that
## raised the Buzzard's left with its last carrier on 18 November. Synthetic passive.
func test_a_granted_shield_regen_pays_as_the_round_opens_up_to_the_maximum() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(1, L)), 20, 100)
	m.grant_passive({"id": "fitted", "name": "Fitted", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "shield_regen", "value": 3},
		{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 1}]})
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 0)])
	sk.begin()
	var ms := sk.mechs[0]
	m.shield = 5
	ms.heat = 10
	sk.start_round()
	assert_eq(ms.heat, 9, "the cooling first")
	assert_eq(Skirmish.shield_regen_of(ms), 3, "the regen it is granted, whatever its heat")
	assert_eq(m.shield, 8, "three back as the round opens")
	assert_true("\n".join(sk.log).contains("shield regen: A +3"), "in the regen's one line")
	m.shield = 19
	sk.end_round()
	sk.start_round()
	assert_eq(m.shield, 20, "never past the maximum")


func test_a_shield_absorbs_its_number_and_the_excess_passes_to_the_hull() -> void:
	# The honest shield (Ryan, 14 October): a shield is its number, never a whole block.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(900, 50)])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 0, "ten shield is spent")
	assert_eq(m.hull, 60, "fifty on a ten-point shield: forty pass to the hull")
	assert_true(not sk.turn_events[0]["blocked"] and sk.turn_events[0]["broke_shield"], "the blow broke the shield and was not blocked")
	assert_eq(m.damaged_component_count(), 0, "and the forty that reached the hull destroy nothing: no blow does by its size")
	assert_true(str(sk.log).contains("shield -10, hull -40"), "the log says what each took")
	m.shield = 50
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 0, "a shield the blow's size takes it all")
	assert_eq(m.hull, 60, "and nothing passes")
	assert_true(sk.turn_events[0]["blocked"], "the blow is recorded as blocked")


func test_armour_takes_a_flat_amount_off_bare_hull_blows() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 200)
	m.armour = 10
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 10), _ghoul(90, 10), _ghoul(90, 30)])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 180, "two ghouls bounce off, the thirty does twenty")
	assert_true(str(sk.log).contains("armour holds"), "the log says the armour held")
	m.shield = 10
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 0, "the thirty stands left and strikes first: the ten-point shield takes ten")
	assert_eq(m.hull, 170, "the armour ten of the twenty past it, and both ghouls bounce off the armour")


func test_double_strike_breaks_the_shield_and_reaches_the_hull() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(m)
	var brute := Foe.make("brute", 200, 30)
	brute.actions[0]["strikes"] = 2
	sk.add_foes([brute])
	sk.begin()
	sk.start_round()
	var fc := sk.forecast(sk.mechs[0])
	assert_eq(fc["incoming"], 60, "forecast counts both blows")
	assert_eq(fc["hull_after"], 50, "and knows the first passes twenty and the second lands on bare hull")
	sk.end_round()
	assert_eq(m.shield, 0, "first blow spends the shield")
	assert_eq(m.hull, 50, "twenty past it, and the second blow's thirty")


## No blow of a foe's passes a shield or armour (Ryan, 15 November: "Sure, let's cut breach"):
## the shield takes its number, the armour comes off what is left, and a move that still names
## the old rider is a plain blow.
func test_every_blow_meets_the_shield_and_then_the_armour() -> void:
	var sk := Skirmish.new(1)
	var plated := _mech("B", Die.single(Face.shield(10)), 10, 100)
	plated.armour = 15
	sk.add_mech(plated)
	var maw := Foe.make("maw", 200, 50)
	maw.actions[0]["keywords"] = ["breach"]   # a rider the engine no longer knows: nothing reads it
	sk.add_foes([maw])
	sk.begin()
	sk.start_round()
	assert_eq(sk.forecast(sk.mechs[0])["hull_after"], 75, "the forecast: ten on the shield and fifteen off the armour")
	sk.end_round()
	assert_eq(plated.shield, 0, "the shield took its ten")
	assert_eq(plated.hull, 75, "and the armour fifteen of the rest")
	assert_true(str(sk.log).contains("maw hits B"), "the log calls it a hit like any other")


## A piece that ignores armour (Ryan, 15 November: "Ignores armour can be an explicitly written
## out property", where the Breach keyword stood on our side): in the blow, the forecast and the
## bot's read; the same gun without it loses the armour. It is a rule written on the entry, kept
## through a save, and no keyword.
func test_a_weapon_that_ignores_armour_takes_nothing_off_for_it() -> void:
	var gun := Face.attack(20, L)
	gun.ignores_armour = true
	assert_true(gun.describe().contains("ignores armour"), "the entry says it: %s" % gun.describe())
	assert_true(gun.rule_phrases().has("ignores armour") and gun.has_unique_rule(), "a printed rule: the star, and its line on the hold")
	assert_true(Face.from_dict(gun.to_dict()).ignores_armour and gun.duplicate_face().ignores_armour, "and it survives a save and a copy")
	assert_true(Face.keyword_from_name("breach") <= 0, "Breach is no keyword")
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(gun), 40, 100))
	var plate := _ghoul(100, 1)
	plate.armour = 10
	sk.add_foes([plate])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(sk.shown_number(ms, gun, plate), 20, "the forecast shows the whole blow")
	var outcomes := Policy.make(Policy.GREEDY).damage_outcomes(ms, gun, plate)
	assert_eq(int(outcomes[0][0]), 20, "and the bot reads it whole")
	assert_true(sk.assign(0, plate), "fired")
	assert_eq(plate.hp, 80, "the armour took none of it")
	var sk2 := Skirmish.new(1)
	var plain := Face.attack(20, L)
	sk2.add_mech(_mech("A", Die.single(plain), 40, 100))
	var plate2 := _ghoul(100, 1)
	plate2.armour = 10
	sk2.add_foes([plate2])
	sk2.begin()
	sk2.start_round()
	assert_eq(sk2.shown_number(sk2.mechs[0], plain, plate2), 10, "without it the forecast takes the armour off")
	assert_true(sk2.assign(0, plate2), "fired")
	assert_eq(plate2.hp, 90, "and so does the blow")


## A gated keyword (the stun row's gated stuns, Ryan, 22 October): the Suppression Battery's
## Suppress lands only on a foe carrying Brittle, read at the spend before its own riders, so a
## spend that lays Brittle never opens its own gate; the die over a foe strikes the chip where it
## will not land, and the hold's line says where it does.
func test_a_gated_suppress_lands_only_where_its_gate_holds() -> void:
	var gun := Face.attack(3, I, [K.SUPPRESS])
	gun.gates = {"suppress": {"when": "target_status", "status": "brittled"}}
	var spray := Face.attack(3, I, [K.SUPPRESS, K.BRITTLE])
	spray.gates = {"suppress": {"when": "target_status", "status": "brittled"}}
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(gun), 40, 100))
	sk.add_mech(_mech("B", Die.single(gun.duplicate_face()), 40, 100))
	sk.add_mech(_mech("C", Die.single(spray), 40, 100))
	var plain := _ghoul(100, 1)
	var marked := _ghoul(100, 1)
	var fresh := _ghoul(100, 1)
	sk.add_foes([plain, marked, fresh])
	sk.begin()
	sk.start_round()
	Effects.stack(marked, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_HALF)
	assert_true(gun.describe().contains("(on a foe carrying Brittle)"), "the hold's line says where it lands: %s" % gun.describe())
	assert_true(gun.has_unique_rule(), "a gate is a printed rule, the star")
	assert_eq(sk.shut_gates(sk.mechs[0], gun, plain), [K.SUPPRESS] as Array[int], "over a foe with no Brittle the chip is struck")
	assert_true(sk.shut_gates(sk.mechs[0], gun, marked).is_empty(), "over a foe carrying Brittle it is lit")
	assert_true(sk.shut_gates(sk.mechs[0], gun, null).is_empty(), "with no foe in hand, as printed")
	assert_true(sk.assign(0, plain), "spent on the plain foe")
	assert_false(Effects.has(plain, "suppressed"), "the gate is shut: no stun")
	assert_eq(plain.hp, 97, "the blow lands all the same")
	assert_true("\n".join(sk.log).contains("suppress does not land"), "the log says so")
	assert_true(sk.assign(1, marked), "spent on the foe carrying Brittle")
	assert_true(Effects.has(marked, "suppressed"), "the gate is open: stunned")
	assert_true(sk.assign(2, fresh), "a spend that lays Brittle itself")
	assert_true(Effects.has(fresh, "brittled"), "lays its Brittle")
	assert_false(Effects.has(fresh, "suppressed"), "and never opens its own gate")


## A consumer (the Backdraft Charge's, Ryan, 22 October): its blow eats every stack of Ablating on
## its target for a point each, the die over the foe showing the number with the stacks in, and
## its Suppress, gated at two stacks, lands only where it ate two or more.
func test_a_consumer_eats_its_targets_stacks_and_stuns_at_its_threshold() -> void:
	var charge := Face.attack(2, L, [K.SUPPRESS])
	charge.gates = {"suppress": {"when": "target_status", "status": "ablating", "stacks": 2}}
	charge.consumes = "ablating"
	charge.per_consumed = 1
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(charge), 40, 100))
	sk.add_mech(_mech("B", Die.single(charge.duplicate_face()), 40, 100))
	var hot := _ghoul(100, 1)
	var warm := _ghoul(100, 1)
	sk.add_foes([hot, warm])
	sk.begin()
	sk.start_round()
	Effects.stack(hot, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	Effects.stack(warm, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 1)
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(charge.describe().contains("consumes Ablate, +1 a stack"), "the hold says what it eats: %s" % charge.describe())
	assert_eq(sk.shown_number(ms, charge, hot), 5, "over three stacks the die shows 2 and 3")
	assert_eq(sk.shown_number(ms, charge, warm), 3, "over one, 2 and 1")
	assert_eq(sk.shut_gates(ms, charge, warm), [K.SUPPRESS] as Array[int], "one stack is under the threshold: the chip struck")
	assert_true(sk.shut_gates(ms, charge, hot).is_empty(), "three is over it: lit")
	assert_true(sk.assign(0, hot), "spent on the burning foe")
	assert_eq(hot.hp, 95, "the blow carries its stacks")
	assert_false(Effects.has(hot, "ablating"), "and the fire is out")
	assert_true(Effects.has(hot, "suppressed"), "two or more eaten: stunned")
	assert_true(sk.assign(1, warm), "spent on the foe with one stack")
	assert_eq(warm.hp, 97, "its one stack on the blow")
	assert_false(Effects.has(warm, "ablating"), "eaten all the same")
	assert_false(Effects.has(warm, "suppressed"), "under the threshold: no stun")


## A reach read on the rank (the Ram Frame and the Artillery Rangefinder, mirrors: Ryan, 22
## October): the point lands only on blows of its reach aimed at its rank, the die shows it
## over the foe, and the hold lists each rule on the entries of its reach alone.
func test_a_reach_read_on_the_rank_adds_only_on_its_reach_and_its_rank() -> void:
	var direct := Face.attack(10, L)
	var lob := Face.attack(10, I)
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.of([direct, lob]), 40, 100)
	m.grant_passive({"id": "mirrors", "name": "Mirrors", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_rank", "rank": "front", "reach": "direct"},
		{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_rank", "rank": "back", "reach": "indirect"}]})
	sk.add_mech(m)
	var front := _ghoul(100, 1)
	var back := _archer(100, 1)
	sk.add_foes([front, back])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(front.rank == 0 and back.rank == 1, "one column: a front and a back")
	assert_eq(sk.shown_number(ms, direct, front), 11, "a Direct blow at the front rank takes the front's point")
	assert_eq(sk.shown_number(ms, lob, front), 10, "an Indirect blow at the front takes neither")
	assert_eq(sk.shown_number(ms, lob, back), 11, "an Indirect blow at the back takes the back's point")
	var on_direct := Effects.explain(m, direct)
	var on_lob := Effects.explain(m, lob)
	assert_true(on_direct.any(func(t: String) -> bool: return t.contains("direct blows aimed at the front rank")), "the Direct entry lists the front's rule: %s" % str(on_direct))
	assert_false(on_direct.any(func(t: String) -> bool: return t.contains("indirect blows")), "and not the back's")
	assert_true(on_lob.any(func(t: String) -> bool: return t.contains("indirect blows aimed at the back rank")), "the Indirect entry lists the back's: %s" % str(on_lob))
	assert_false(on_lob.any(func(t: String) -> bool: return t.contains("direct blows aimed at the front")), "and not the front's")


## The bot's value of extra armour: what it keeps of every blow that reaches the hull.
func test_extra_armour_keeps_its_number_of_a_blow_on_the_hull() -> void:
	var pol := Policy.make(Policy.GREEDY)
	var sk2 := Skirmish.new(1)
	sk2.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 100))
	sk2.add_foes([Foe.make("maw", 200, 30)])
	sk2.begin()
	sk2.start_round()
	assert_eq(pol._armour_saved(sk2, sk2.mechs[0], 10), 10.0, "against a blow on bare hull it keeps its ten")


func test_heaviest_hitters_deploy_left_and_strike_first() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 10), _ghoul(90, 10), Foe.make("brute", 90, 50)])
	sk.begin()
	assert_eq(sk.front[0].display_name, "brute", "the brute stands left")
	assert_eq(sk.front[1].display_name, "revenant", "ghouls follow in arrival order")
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 0, "the brute strikes first and the shield takes ten of it")
	assert_eq(m.hull, 40, "forty past the shield, then the two ghouls on bare hull")


func test_strikes_are_separate_blows_with_their_own_rolls_and_procs() -> void:
	var sk := Skirmish.new(2)
	var gun := Face.attack(10, L, K.ABLATE, 20)
	gun.strikes = 3
	sk.add_mech(_mech("A", Die.single(gun)))
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 170, "three blows of ten")
	assert_eq(sk.front[0].ablate_stacks(), 3, "each blow procs burn on its own: three stacks, where one thirty would give two")
	assert_eq(sk.mechs[0].heat, 20, "heat is paid once per use, not per strike")
	assert_eq(sk.last_roll["final"], 30, "the screen sees the total")
	assert_eq(gun.describe(), "10 ×3 ablate 1 (+20 heat)", "described as a burst")
	assert_eq(Face.from_dict(gun.to_dict()).strikes, 3, "strikes survive content round-trip")


## Two reaches since 10 October: a melee weapon is a direct one with a tag, and the tag
## changes nothing about whom it reaches.
func test_a_melee_tag_reaches_as_direct_does() -> void:
	var sk := Skirmish.new(1)
	var claw := Face.attack(30)
	claw.tags.append("melee")
	sk.add_mech(_mech("A", Die.of([claw, Face.attack(30)])))
	sk.add_foes([_ghoul(30), _archer(50), _archer(50)])
	sk.begin()
	sk.start_round()
	var plain := sk.targets_for_face(sk.mechs[0], sk.mechs[0].die.faces[1])
	assert_eq(sk.targets_for_face(sk.mechs[0], claw), plain, "the claw sees what the gun sees")
	assert_true(plain.size() > 1, "the front and an exposed back")


func test_static_set_reach_sends_a_tagged_component_to_direct() -> void:
	var sk := Skirmish.new(3)
	var mortar := Face.attack(30, I)
	var m := _mech("A", Die.of([mortar, Face.attack(30, I)]), 0, 100)
	m.grant_passive({"id": "rs", "name": "RS", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.1, "when": "reach_direct"},
		{"trigger": "static", "effect": "set_reach", "value": "direct", "when": "tag_siege"}]})
	sk.add_mech(m)
	sk.add_foes([_ghoul(200), _archer(200)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 1
	assert_eq(sk.targets_for(0).size(), 2, "an untagged mortar reaches both ranks")
	sk.mechs[0].die.faces[0].tags = ["siege"] as Array[String]
	sk.mechs[0].face_index = 0
	var f := sk.mechs[0].face()
	assert_true(f.tags.has("siege") and f.reach == Face.Reach.INDIRECT, "tagged; the component itself is untouched")
	assert_eq(sk.reach_of(sk.mechs[0], f), Face.Reach.DIRECT, "but read through the passive it is direct")
	assert_eq(sk.shown_face(sk.mechs[0], f).reach, Face.Reach.DIRECT, "and the screen shows it as direct")
	assert_eq(sk.targets_for(0).size(), 1, "so it reaches only the front")
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 167, "30 at 1.1 is 33: the direct bonus follows the effective reach")
	var saved: Array = m.modifiers
	m.modifiers = []
	assert_eq(sk.reach_of(sk.mechs[0], f), Face.Reach.INDIRECT, "take the passive away (suppressed, or an ally reading it) and the reach is its own again")
	m.modifiers = saved
	Effects.grant(m, Effects.make({"id": "jam", "name": "Jam", "description": "", "effects": [{"trigger": "static", "effect": "suppress", "value": "rs"}]}, Effects.SKIRMISH, "foe:whisperer"))
	assert_eq(sk.reach_of(sk.mechs[0], f), Face.Reach.INDIRECT, "a skirmish-long suppression of the passive turns the transformation off too")
	Effects.end_skirmish(m)
	assert_eq(sk.reach_of(sk.mechs[0], f), Face.Reach.DIRECT, "and when the skirmish ends the suppression is gone and the passive answers again")
	assert_eq(m.die.faces[0].reach, Face.Reach.INDIRECT, "the mortar itself never changed")


## Chain, the conductor (Ryan, 28 and 29 October): the blow lands on its target as ever, and
## Chain's number on every other Shocked foe on the field, wherever it stands and whatever the
## gun's reach; no strike is aimed at a conductor, so its Shock neither doubles the arc nor is
## spent. Then one other foe at random, neither the target nor already Shocked, is Shocked. Heat
## once a spend.
func _chain_gun(power: int = 4, chain: int = 2, heat: int = 3, more: Array = []) -> Face:
	var kws: Array = [K.CHAIN]
	kws.append_array(more)
	var f := Face.attack(power, L, kws, heat)
	f.chain = chain
	return f


func _shock_on(foe: Foe) -> void:
	Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)


func test_chain_pings_every_shocked_foe_on_the_field_whatever_its_reach() -> void:
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(_chain_gun())))
	var target := _ghoul(30, 5)
	var beside := _ghoul(30, 5)
	var behind := _archer(30, 5)
	var idle := _archer(30, 5)
	sk.add_foes([target, beside, behind, idle])
	sk.begin()
	sk.start_round()
	assert_true(sk.front[0] == target and sk.front[1] == beside and sk.back[0] == behind and sk.back[1] == idle, "the ranks as they arrived")
	_shock_on(beside)
	_shock_on(behind)
	assert_false(sk.targets_for_face(sk.mechs[0], sk.mechs[0].face()).has(behind), "the foe behind the target is out of Direct reach")
	assert_true(sk.assign(0, target), "the Chain gun spent")
	assert_eq(target.hp, 26, "the target takes the roll")
	assert_eq(beside.hp, 28, "the Shocked foe beside it loses Chain's 2 HP at Resolve: no strike is aimed at it")
	assert_eq(behind.hp, 28, "and so does the one behind the target, out of the gun's reach")
	assert_true(Effects.has(beside, "shocked") and Effects.has(behind, "shocked"), "each conductor keeps its charge")
	assert_eq(idle.hp, 30, "a foe with no charge takes nothing")
	assert_false(Effects.has(idle, "shocked"), "and gains no charge: Chain is the arcs alone (3 November)")
	assert_eq(sk.mechs[0].heat, 3, "heat once a spend; the ping adds none")
	assert_eq("\n".join(sk.log).count("'s Chain: "), 2, "the log tells each foe the ping reaches")


## An arc is its blow alone (Ryan, 18 November: "take riders off chain. Thematically it's a lightning
## arc, not part of the impact"): what the gun lays lands on the foes its strike and its area reach,
## never on a conductor, which takes the arc's number through its armour and nothing else.
func test_an_arc_carries_no_rider() -> void:
	var sk := Skirmish.new(1, 2)
	var gun := _chain_gun(4, 2, 3, [K.ABLATE, K.BRITTLE, K.LURE])
	gun.ablate = 2
	gun.brittle = 1
	sk.add_mech(_mech("A", Die.single(gun)))
	sk.add_mech(_mech("B", Die.single(Face.blank())))
	var target := _ghoul(30, 5)
	var other := _ghoul(30, 5)
	sk.add_foes([target, other])
	sk.begin()
	sk.start_round()
	_shock_on(other)
	var ms: Skirmish.MechState = sk.mechs[0]
	for foe in [target, other]:
		foe.target = sk.mechs[1]   # both aim at the other machine, so a lure shows as a turn
	assert_true(sk.ridden_by(gun, target).has(target) and not sk.ridden_by(gun, target).has(other), "the riders reach the target, never the conductor")
	assert_true(sk.reached_by(gun, target).has(other), "though the blow reaches it")
	assert_true(sk.assign(0, target), "the Chain gun spent")
	assert_eq(other.hp, 28, "the conductor takes Chain 2")
	assert_eq([Effects.stacks_of(other, "ablating"), Effects.stacks_of(other, "brittled")], [0, 0], "and none of the gun's marks")
	assert_eq(other.target, sk.mechs[1], "nor its lure")
	assert_eq([Effects.stacks_of(target, "ablating"), Effects.stacks_of(target, "brittled")], [2, 1], "the target takes them all")
	assert_eq(target.target, ms, "and turns on it")


func test_chain_never_pings_the_foe_whose_shock_its_strike_spent() -> void:
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(_chain_gun())))
	var target := _ghoul(30, 5)
	var other := _ghoul(30, 5)
	sk.add_foes([target, other])
	sk.begin()
	sk.start_round()
	_shock_on(target)
	_shock_on(other)
	assert_true(sk.assign(0, target), "the Chain gun spent")
	assert_eq(target.hp, 22, "the aimed foe takes the roll, doubled by its own charge, once")
	assert_false(Effects.has(target, "shocked"), "the strike aimed at it spends the charge")
	assert_eq(other.hp, 28, "the other conductor loses Chain's 2 HP")
	assert_true(Effects.has(other, "shocked"), "and keeps its charge")
	assert_eq("\n".join(sk.log).count("'s Chain: "), 1, "one foe pinged")


## An arc is the Chain's number flat (Ryan, 21 November: "If Chain doesn't carry the riders, it
## shouldn't carry the unit's or weapon's buffs either. It's flat damage that strikes"): no add or
## multiply of the machine's lands on it, where the strike itself takes them.
func test_no_buff_of_the_machines_rides_an_arc() -> void:
	for amp in [["add_damage", 1, 2, "2, flat"], ["multiply_damage", 2, 2, "2, flat"]]:
		var sk := Skirmish.new(1, 2)
		var m := _mech("A", Die.single(_chain_gun()))
		m.grant_passive({"id": "test_amp", "name": "Amp", "description": "", "effects": [{"trigger": "on_attack", "effect": str(amp[0]), "value": amp[1]}]})
		sk.add_mech(m)
		var target := _ghoul(30, 5)
		var other := _ghoul(30, 5)
		sk.add_foes([target, other])
		sk.begin()
		sk.start_round()
		_shock_on(other)
		assert_true(sk.assign(0, target), "the Chain gun spent")
		assert_eq(30 - other.hp, int(amp[2]), "%s: the conductor takes %s" % [str(amp[0]), str(amp[3])])
		assert_true(30 - target.hp > 4, "%s: the strike itself takes the buff" % str(amp[0]))


func test_a_kill_by_an_arc_fires_the_kill_rules() -> void:
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.single(_chain_gun()))
	m.grant_passive(KILLER)
	sk.add_mech(m)
	var target := _ghoul(30, 5)
	var weak := _ghoul(2, 5)
	sk.add_foes([target, weak])
	sk.begin()
	sk.start_round()
	_shock_on(weak)
	assert_true(sk.assign(0, target), "the Chain gun spent")
	assert_false(weak.alive(), "the arc kills the conductor")
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "and the kill is its attack's: its kill trigger fires")


## Chain's ping is HP lost (Ryan, 24 November: "The under-armour ping is simpler"): no armour takes
## any of it, whatever its gun's rules.
func test_chains_ping_passes_armour_whatever_its_gun() -> void:
	for ignores in [false, true]:
		var sk := Skirmish.new(1, 2)
		var gun := _chain_gun(4, 2, 3)
		gun.ignores_armour = ignores
		sk.add_mech(_mech("A", Die.single(gun)))
		var target := _ghoul(30, 5)
		var plated := _ghoul(30, 5)
		plated.armour = 1
		sk.add_foes([target, plated])
		sk.begin()
		sk.start_round()
		_shock_on(plated)
		assert_true(sk.assign(0, target), "the Chain gun spent")
		assert_eq(30 - plated.hp, 2, "Chain's 2 HP, its armour taking none, %s" % ("its gun ignoring armour" if ignores else "a plain gun's"))


## The primers (Ryan, 2 November; as keywords since 3 November: "a multi-hit weapon with Shock
## would apply it after both hits ... Cryo should work the same way, resulting in 2 applications";
## Primed the third since 15 November, "give it the same format as cryo ... use a stack on
## firing", an Ablate a stack, "Just one, like supercooled"): while a machine carries Charged its
## weapons fire with Shock, while it carries Supercooled with Cryo, while it carries Primed with
## Ablate, one more a strike, all shown on the die and landing after the strikes; a weapon fired
## spends a stack of each; equipment carries none and spends none; a laid shot carries them.
func test_charged_supercooled_and_primed_ride_the_weapon_fired_as_its_keywords() -> void:
	var sk := Skirmish.new(1, 2)
	var gun := Face.attack(4, L)
	gun.strikes = 2
	var m := _mech("A", Die.of([gun, Face.buff("ward")]), 40, 100)
	sk.add_mech(m)
	var g := _ghoul(100, 0)
	var h := _ghoul(100, 0)
	sk.add_foes([g, h])
	sk.begin()
	sk.start_round()
	Effects.stack(m, Effects.STATUS["charged"], Effects.SKIRMISH, "buff", 1, Effects.DECAY_NONE)
	Effects.stack(m, Effects.STATUS["supercooled"], Effects.SKIRMISH, "buff", 2, Effects.DECAY_NONE)
	Effects.grant_buff(m, "primed", 2, "buff", sk.round)   # as a buff grants it: stacks, and no rounds to run out
	var ms: Skirmish.MechState = sk.mechs[0]
	var shown := sk.shown_face(ms, gun)
	assert_true(shown.has(K.SHOCK) and shown.has(K.CRYO) and shown.cryo == 1, "the die shows the gun firing with Shock and Cryo 1: %s" % shown.describe())
	assert_true(shown.has(K.ABLATE) and shown.ablate == 1, "and with Ablate 1, Primed's: %s" % shown.describe())
	assert_false(sk.shown_face(ms, ms.die.faces[1]).has(K.SHOCK) or sk.shown_face(ms, ms.die.faces[1]).has(K.ABLATE), "equipment carries none of them")
	ms.face_index = 1
	assert_true(sk.assign(0, null), "equipment spent on itself")
	assert_eq([Effects.stacks_of(m, "charged"), Effects.stacks_of(m, "supercooled"), Effects.stacks_of(m, "primed")], [1, 2, 2], "equipment spends nothing")
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(m, "primed"), 2, "a primer outlasts the round it was granted in: it waits for a weapon")
	ms.face_index = 0
	assert_true(sk.assign(0, g), "the gun fired at g")
	assert_eq(g.hp, 92, "two strikes of 4, neither doubled: the Shock lands after the blows")
	assert_true(Effects.has(g, "shocked"), "Charged: the foe is Shocked after the fire")
	assert_eq(Effects.stacks_of(g, "cryoed"), 2, "Supercooled: Cryo 1 a strike, laid after the hits, so the second strike cashes nothing")
	assert_eq(Effects.stacks_of(g, "ablating"), 2, "Primed: Ablate 1 a strike, a stack of Ablating each")
	assert_false("\n".join(sk.log).contains("cashes Cryo"), "no cash on the fire's own frost")
	assert_eq([Effects.stacks_of(m, "charged"), Effects.stacks_of(m, "supercooled"), Effects.stacks_of(m, "primed")], [0, 1, 1], "a stack of each spent, one fire")
	var hit_line := sk.log.filter(func(l: String) -> bool: return l.begins_with("A hits revenant"))
	assert_true(not hit_line.is_empty() and hit_line[0].contains("shock") and hit_line[0].contains("cryo 1"), "the hit's line names the keywords the fire carried: %s" % str(hit_line))
	assert_false(sk.shown_face(ms, gun).has(K.SHOCK), "the Charged spent, the die shows the gun plain of it")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	assert_true(sk.assign(0, h), "fired again, at h")
	assert_false(Effects.has(h, "shocked"), "no Charged left")
	assert_eq([Effects.stacks_of(h, "cryoed"), Effects.stacks_of(m, "supercooled")], [2, 0], "the last Supercooled spent on h, a stack a strike")
	assert_eq([Effects.stacks_of(h, "ablating"), Effects.stacks_of(m, "primed")], [2, 0], "and the last Primed, an Ablating a strike")
	assert_false(sk.shown_face(ms, gun).has(K.ABLATE), "the primers spent, the die shows the gun plain")
	# On a gun that carries Ablate, Primed is one more a strike, as Supercooled is on a Cryo gun.
	var torch := Face.attack(4, L, [K.ABLATE])
	torch.ablate = 2
	var s3 := Skirmish.new(1, 2)
	var burner := _mech("Burner", Die.single(torch), 40, 100)
	s3.add_mech(burner)
	var lit := _ghoul(100, 0)
	s3.add_foes([lit])
	s3.begin()
	s3.start_round()
	Effects.grant_buff(burner, "primed", 3, "buff", s3.round)
	assert_eq(s3.shown_face(s3.mechs[0], torch).ablate, 3, "Ablate 2 fires as Ablate 3 while Primed, however many stacks it carries")
	assert_true(s3.assign(0, lit), "fired")
	assert_eq([Effects.stacks_of(lit, "ablating"), Effects.stacks_of(burner, "primed")], [3, 2], "three Ablating laid, one stack spent")
	# A Mine carries the keywords the primers gave the fire, the stacks spent as it fires.
	var s2 := Skirmish.new(1, 2)
	var bomber := _mech("Bomber", Die.single(Face.attack(4, I)), 40, 100)
	bomber.grant_passive(MINER)
	s2.add_mech(bomber)
	var prey := _ghoul(100, 0)
	s2.add_foes([prey])
	s2.begin()
	s2.start_round()
	Effects.stack(bomber, Effects.STATUS["charged"], Effects.SKIRMISH, "buff", 1, Effects.DECAY_NONE)
	Effects.stack(bomber, Effects.STATUS["supercooled"], Effects.SKIRMISH, "buff", 1, Effects.DECAY_NONE)
	Effects.stack(bomber, Effects.STATUS["primed"], Effects.SKIRMISH, "buff", 1, Effects.DECAY_NONE)
	assert_true(s2.assign(0, prey), "fired, a Mine left")
	assert_eq([Effects.stacks_of(bomber, "charged"), Effects.stacks_of(bomber, "supercooled"), Effects.stacks_of(bomber, "primed")], [0, 0, 0], "all three spent at the fire")
	var mine := Skirmish.mine_of(prey)
	assert_true(mine["riders"]["keywords"].has("shock") and int(mine["riders"]["stacks"].get("cryoed", 0)) == 1, "the Mine carries the Shock and the Cryo 1: %s" % str(mine))
	assert_eq(int(mine["riders"]["stacks"].get("ablating", 0)), 1, "and the Ablate 1")


## Riders land after the hits (Ryan, 3 November: "resulting in 2 applications, not
## apply-cash-apply-cash, and not hit-hit-apply once, since that just removes the purpose of
## multi-hit strikes"): a strikes gun's Cryo lands a stack a strike once its strikes are done, so
## it never cashes its own frost; a foe already frosted is cashed on the first strike alone.
func test_a_strikes_guns_cryo_lands_a_stack_a_strike_after_its_hits_and_never_cashes_its_own() -> void:
	var sk := Skirmish.new(1, 2)
	var gun := Face.attack(5, L, K.CRYO, 4)
	gun.cryo = 1
	gun.strikes = 2
	sk.add_mech(_mech("A", Die.single(gun), 40, 100))
	var g := _ghoul(100, 0)
	var h := _ghoul(100, 0)
	sk.add_foes([g, h])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 20
	assert_true(sk.assign(0, g), "fired at a plain foe")
	assert_eq([g.hp, Effects.stacks_of(g, "cryoed")], [90, 2], "two strikes, Cryo 2: a stack a strike, laid after the hits")
	assert_eq(ms.heat, 24, "its own heat and no cash: the second strike found nothing of the first's")
	sk.end_round()
	sk.start_round()
	Effects.stack(h, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_NONE)
	ms.heat = 20
	assert_true(sk.assign(0, h), "fired at a frosted foe")
	assert_eq(Effects.stacks_of(h, "cryoed"), 2, "its three cashed by the first strike, then the fire's two laid")
	assert_eq(ms.heat, 24 - 3 * Skirmish.cryo_cool(), "cooled for the three alone")


## The stun resist by kind (Ryan, 3 November: "1 small, 2 massive, 3 for elites and bosses, by
## default"), content's own number over it, and the elite flag from content.
func test_a_foes_stun_resist_is_by_its_kind_unless_content_says() -> void:
	var small := _ghoul(100)
	assert_eq(small.stun_resist(), 1, "a small foe")
	var big := _ghoul(100)
	big.size = 2
	assert_eq(big.stun_resist(), 2, "a massive foe")
	var elite := _ghoul(100)
	elite.elite = true
	assert_eq(elite.stun_resist(), 3, "an elite")
	var boss := _ghoul(100)
	boss.boss = true
	assert_eq(boss.stun_resist(), 3, "a boss")
	var hero := _ghoul(100)
	hero.hero = true
	assert_eq(hero.stun_resist(), 3, "a hero")
	big.resist = 5
	assert_eq(big.stun_resist(), 5, "content's own number over the kind's")
	var db := ContentDB.load_default()
	var elites := 0
	for id in db.foes.keys():
		if db.is_elite(id):
			var f := db.make_foe(id)
			assert_true(f.elite, "%s is made an elite" % id)
			assert_true(f.resist >= 0 or f.stun_resist() == 3, "%s resists as a boss unless content says" % id)
			elites += 1
	assert_true(elites > 0, "content has elites to check")


func test_chains_ping_passes_a_barrier_and_the_charge_stands() -> void:
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(_chain_gun())))
	var target := _ghoul(30, 5)
	var sheltered := _ghoul(30, 5)
	sk.add_foes([target, sheltered])
	sk.begin()
	sk.start_round()
	_shock_on(sheltered)
	Effects.grant_buff(sheltered, "barrier", 1, "test", sk.round)
	assert_true(sk.assign(0, target), "the Chain gun spent")
	assert_eq(sheltered.hp, 28, "the ping is no blow: it loses its 2 HP past the Barrier")
	assert_true(Effects.has(sheltered, "barrier"), "which stands")
	assert_true(Effects.has(sheltered, "shocked"), "the charge stands: no strike was aimed at it")


func test_the_maps_list_the_conductors() -> void:
	var sk := Skirmish.new(1, 2)
	var gun := _chain_gun()
	sk.add_mech(_mech("A", Die.single(gun)))
	var target := _ghoul(30, 5)
	var beside := _ghoul(30, 5)
	var behind := _archer(30, 5)
	var other_back := _archer(30, 5)
	sk.add_foes([target, beside, behind, other_back])
	sk.begin()
	sk.start_round()
	_shock_on(behind)
	assert_true(sk.area_shapes(gun, target).is_empty(), "Chain is no shape of the strike: its conductors are struck apart")
	assert_eq(Array(sk.ridden_by(gun, target)), [target], "the strike's own footprint, its riders' foes: the target alone")
	var hit := sk.reached_by(gun, target)
	assert_eq(hit.size(), 2, "every foe the spend reaches: the target and its conductor")
	assert_true(hit.has(target) and hit.has(behind), "both")
	assert_false(hit.has(beside) or hit.has(other_back), "no foe without a charge")
	assert_eq(Array(sk.conductors(gun, target)), [behind], "the arcs' foes: the conductor")
	_shock_on(target)
	assert_eq(Array(sk.conductors(gun, target)), [behind], "a Shocked target is out: the gun's strike spends its Shock first")
	var probe := Face.attack(0, L, [K.CHAIN])
	probe.chain = 2
	assert_eq(Array(sk.conductors(probe, target)), [target, behind], "equipment spends no Shock, so its Shocked target is struck too (Ryan, 21 November: \"Any conductor\")")
	assert_true(sk.conductors(Face.attack(0, L, [K.LURE]), target).is_empty(), "an entry without Chain conducts nothing")


## Chain beside an area (Ryan, 21 November: "It should stack with spread and penetrate"): a Shocked
## foe beside the target takes Spread's blow and the arc, the area's blow spending no Shock, and an
## arc spreads nowhere.
func test_chain_stacks_with_spread_and_spreads_nowhere() -> void:
	var sk := Skirmish.new(1, 3)
	var gun := _chain_gun(4, 2, 3, [K.CLEAVE])
	gun.cleave = 1
	sk.add_mech(_mech("A", Die.single(gun)))
	var left := _ghoul(30, 5)
	var target := _ghoul(30, 5)
	var right := _ghoul(30, 5)
	var far := _archer(30, 5)
	var mid_back := _archer(30, 5)
	var right_back := _archer(30, 5)
	sk.add_foes([left, target, right, far, mid_back, right_back])
	sk.begin()
	sk.start_round()
	assert_true(sk.front[1] == target and sk.back[0] == far and sk.back[1] == mid_back, "the ranks as they arrived")
	_shock_on(right)
	_shock_on(far)
	assert_true(sk.assign(0, target), "the Chain and Spread gun spent")
	assert_eq(target.hp, 26, "the target takes the roll")
	assert_eq(left.hp, 29, "the foe beside it takes Spread 1")
	assert_eq(right.hp, 27, "the Shocked foe beside it takes Spread 1 and Chain's 2")
	assert_true(Effects.has(right, "shocked"), "an area's blow spends no Shock, nor the ping")
	assert_eq(far.hp, 28, "the Shocked foe out of the row takes Chain 2")
	assert_eq(mid_back.hp, 30, "the ping spreads nowhere: the conductor's neighbour loses nothing")
	assert_eq(right_back.hp, 30, "and nothing goes on from the area's foe")
	assert_eq("\n".join(sk.log).count("'s Chain: "), 2, "two foes pinged, each conductor once")


## Shocked (Ryan, 29 October: "when targeted and struck by a weapon, double the damage received
## and remove Shock"): a weapon's strike aimed at the foe doubles and spends it; a blow that only
## reaches it, an area's or a spill's, neither doubles nor spends it.
func test_a_shock_is_read_only_by_a_weapon_strike_aimed_at_its_foe() -> void:
	var sk := Skirmish.new(1, 2)
	var sweep := Face.attack(6, L, [K.CLEAVE])
	sweep.cleave = 2
	sk.add_mech(_mech("A", Die.single(sweep)))
	sk.add_mech(_mech("B", Die.single(Face.attack(5, L))))
	var target := _ghoul(30, 5)
	var neighbour := _ghoul(30, 5)
	sk.add_foes([target, neighbour])
	sk.begin()
	sk.start_round()
	_shock_on(neighbour)
	assert_true(sk.assign(0, target), "a Spread spent beside the Shocked foe")
	assert_eq(neighbour.hp, 28, "Spread 2 lands plain on it")
	assert_true(Effects.has(neighbour, "shocked"), "and its charge stands")
	assert_true(sk.assign(1, neighbour), "a gun aimed at it")
	assert_eq(neighbour.hp, 18, "the strike aimed at it lands double")
	assert_false(Effects.has(neighbour, "shocked"), "and spends the charge")


func test_a_spill_neither_doubles_nor_spends_a_shock() -> void:
	var sk := Skirmish.new(1, 1)
	sk.add_mech(_mech("A", Die.single(_spiller(Face.attack(10, L)))))
	var front := _ghoul(4, 5)
	var behind := _archer(30, 5)
	sk.add_foes([front, behind])
	sk.begin()
	sk.start_round()
	_shock_on(behind)
	assert_true(sk.assign(0, front), "the strike kills the front foe")
	assert_eq(behind.hp, 24, "its excess, 6, spills plain into the foe behind")
	assert_true(Effects.has(behind, "shocked"), "whose charge stands")


func test_stats_are_base_plus_every_live_source_in_order() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.hull_max = 200
	u.armour = 10
	assert_eq(u.hull_max, 200, "a written maximum is the base")
	u.grant_passive({"id": "plates", "name": "Plates", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 10},
		{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 20}]}, "heavy_plates", "heavy_plates")
	Effects.grant(u, Effects.make({"id": "overdrive", "name": "Overdrive", "description": "", "effects": [
		{"trigger": "static", "effect": "multiply_stat", "stat": "hull", "value": 1.5}]}, Effects.BATTLE, "reward"))
	assert_eq(u.hull_max, 330, "(200 + 20) x 1.5: adds before multiplies, whatever order they were granted")
	assert_eq(u.armour, 20, "armour from the base and the component")
	Effects.end_battle(u)
	assert_eq(u.hull_max, 220, "the reward ends with the battle; the component stays")
	Effects.grant(u, Effects.make({"id": "rust", "name": "Rust", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": -50}]}, Effects.SKIRMISH, "foe:corroder"))
	assert_eq(u.armour, 0, "a stat never goes below zero")
	Effects.end_skirmish(u)
	assert_eq(u.armour, 20, "and comes back when the debuff ends")


func test_a_timed_damage_taken_debuff_runs_out_after_its_round() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 200)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 20)])
	sk.begin()
	sk.start_round()
	Effects.grant_for_rounds(m, {"id": "weakened", "name": "Weakened", "description": "", "effects": [
		{"trigger": "static", "effect": "multiply_damage_taken", "value": 1.5}]}, "foe:hexer", sk.round)
	assert_eq(sk.forecast(sk.mechs[0])["hull_after"], 170, "the forecast reads the debuff: 20 becomes 30")
	sk.end_round()
	assert_eq(m.hull, 170, "and so does the blow")
	assert_true(m.modifiers.is_empty(), "the debuff ran out at the end of its round")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 150, "the next blow is a plain 20")


func test_a_destroyed_component_keeps_its_bonus_and_loses_its_ability() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	var gun := Face.attack(30, L)
	gun.component = "big_gun"
	u.die = Die.single(gun)
	u.armour = 0
	u.grant_passive({"id": "bg", "name": "Big Gun", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 10},
		{"trigger": "on_attack", "effect": "add_damage", "value": 10}]}, "big_gun", "big_gun")
	assert_eq(u.armour, 10, "fitted: the bonus")
	assert_eq(Effects.attack(u, gun, 30, 0)["damage"], 40, "fitted: the ability")
	var wreck := Face.blank()
	wreck.component = "big_gun"
	u.die.faces[0] = wreck
	assert_eq(u.armour, 10, "destroyed: the bonus stays")
	assert_eq(Effects.attack(u, gun, 30, 0)["damage"], 30, "destroyed: the ability is gone")


func test_shorter_lived_sources_override_longer_ones() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	var f := Face.attack(20, I)
	u.grant_passive({"id": "a", "name": "A", "description": "", "effects": [{"trigger": "static", "effect": "set_reach", "value": "direct"}]})
	assert_eq(Effects.effective_reach(u, f), Face.Reach.DIRECT, "the loadout rule holds")
	Effects.grant(u, Effects.make({"id": "b", "name": "B", "description": "", "effects": [{"trigger": "static", "effect": "set_reach", "value": "indirect"}]}, Effects.SKIRMISH, "buff"))
	assert_eq(Effects.effective_reach(u, f), Face.Reach.INDIRECT, "a skirmish-long rule wins over the loadout one")
	Effects.end_skirmish(u)
	assert_eq(Effects.effective_reach(u, f), Face.Reach.DIRECT, "and the loadout rule is back when it ends")


func test_a_doubled_heat_doubles_scorched_too() -> void:
	# Heat reads adds before multiplies, the one order damage reads too, so a machine whose
	# weapons run twice as hot (the Thrust Overboost module's double; a synthetic passive here)
	# doubles Scorched's extra as well, and its die says so (Ryan asked, 13 October).
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, [], 10)), 0, 200)
	m.heat_max = 100
	Effects.grant(m, Effects.make({"id": "hot", "name": "Hot", "description": "", "effects": [{"trigger": "on_attack", "effect": "multiply_heat", "value": 2}]}, Effects.BATTLE, "test"))
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.shown_face(sk.mechs[0], sk.mechs[0].face()).heat, 20, "the double alone")
	Effects.stack(m, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe:x", 1, Effects.DECAY_TURN_ALL)
	var sc := _rule("scorched", "add_heat")
	assert_eq(sk.shown_face(sk.mechs[0], sk.mechs[0].face()).heat, (10 + sc) * 2, "a stack of Scorched is doubled with the rest, and the die shows it: (10 + its extra) × 2")
	assert_eq(int(sk.preview_round(0, sk.front[0])["mechs"][0]["heat_end"]), (10 + sc) * 2, "and the round preview with the die in hand lands it")


func test_statuses_stack_tick_and_decay_on_both_sides() -> void:
	# What a foe lays on a machine that ticks at the end of the player's turn (Ryan, 13 October,
	# Scorch; 15 November, Ablate). A scorching blow leaves a stack of Scorched: no heat now, the
	# next weapon fired runs hotter by its number, and every stack goes at the end of the player's
	# turn. An ablating blow leaves a stack of Ablating: a point off the shield, then the hull, at
	# the end of the next player's turn, then the stack goes (tests/test_ablate.gd has the rule).
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, [], 10)), 0, 200)
	m.heat_max = 100
	sk.add_mech(m)
	var scorcher := Foe.make("hellhound", 900, 10)
	scorcher.actions[0]["keywords"] = ["scorch"]
	sk.add_foes([scorcher])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(sk.mechs[0].heat, 0, "a scorch adds no heat by itself")
	assert_eq(Effects.stacks_of(m, "scorched"), 1, "it leaves a stack of Scorched")
	sk.start_round()
	var sc := _rule("scorched", "add_heat")
	var per := _rule("ablating_mech", "tick_hp")
	assert_eq(sk.shown_face(sk.mechs[0], sk.mechs[0].face()).heat, 10 + sc, "the weapon runs hotter by Scorched's number, and the die says so")
	assert_eq(int(sk.preview_round(0, sk.front[0])["mechs"][0]["heat_end"]), 10 + sc, "and the round preview with the die in hand lands it")
	assert_eq(sk.mechs[0].face().heat, 10, "while the component keeps its own")
	sk.assign(0, sk.front[0])
	assert_eq(sk.mechs[0].heat, 10 + sc, "and lands that hot")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "scorched"), 1, "the turn's end took the stack; the next blow left another")
	Effects.stack(m, Effects.STATUS["scorched"], Effects.SKIRMISH, "test", 2, Effects.DECAY_TURN_ALL)
	assert_eq(Effects.stacks_of(m, "scorched"), 3, "three blows' worth")
	Effects.turn_tick(m)
	assert_eq(Effects.stacks_of(m, "scorched"), 0, "every stack goes at the turn's end, so Scorched never piles up")
	var s2 := Skirmish.new(2)
	var n := _mech("B", Die.single(Face.shield(10)), 0, 200)
	n.heat_max = 100
	s2.add_mech(n)
	var burner := Foe.make("hellhound", 900, 10)
	burner.actions[0]["keywords"] = ["ablate"]
	s2.add_foes([burner])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq([s2.mechs[0].heat, n.hull], [0, 190], "an ablate adds no heat, and takes nothing at once past its blow")
	assert_eq(Effects.stacks_of(n, "ablating_mech"), 1, "a stack of Ablating")
	s2.start_round()
	assert_eq(int(s2.forecast(s2.mechs[0])["ablated"]), per, "the forecast counts the tick at the turn's end")
	s2.end_round()
	assert_eq(n.hull, 190 - per - 10, "Ablating's point a stack off the bare hull at the end of the turn, then the next blow")
	assert_eq(s2.mechs[0].heat, 0, "and never any heat")
	assert_eq(Effects.stacks_of(n, "ablating_mech"), 1, "that stack went; the next blow left another")
	Effects.stack(n, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "test", 2, Effects.DECAY_TURN)
	assert_eq(Effects.stacks_of(n, "ablating_mech"), 3, "stacks add up")
	assert_eq(int(Effects.tick_preview(n, true)["hp"]), 3 * per, "its point a stack, at the turn's end")
	assert_eq(int(Effects.tick_preview(n)["hp"]), 0, "and never at the round's")
	win_fight(s2)
	assert_eq(Effects.stacks_of(n, "ablating_mech"), 0, "skirmish-scoped statuses end with the skirmish")


## Numbed on Ryan's clock (2 November): a stunned foe recovers with its stun resist in stacks,
## after the round's decay, a stack goes at each round's end, and a stun on a Numbed foe strips a
## stack and lands nothing, so the count is the rounds until one stun lands.
func test_suppress_skips_the_action_and_numbs() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 60, 100)   # a shield, so the blow it takes reaches no hull
	sk.add_mech(m)
	var boss := Foe.make("maw", 200, 30)
	boss.size = 2
	sk.add_foes([boss])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_true(boss.is_suppressed(), "suppressed this round")
	assert_eq(Effects.stacks_of(boss, "numbed"), 0, "Numbed lands as it recovers, not as the stun does")
	sk.end_round()
	assert_eq([m.hull, m.shield], [100, 60], "it skipped")
	assert_false(boss.is_suppressed(), "the suppression ran out with the round")
	assert_eq(Effects.stacks_of(boss, "numbed"), 2, "a massive foe recovers with its stun resist in stacks (2, Ryan's default of 3 November): two rounds until one stun lands")
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_false(boss.is_suppressed(), "a stun on a Numbed foe lands nothing")
	assert_eq(Effects.stacks_of(boss, "numbed"), 1, "and strips a stack")
	assert_true("\n".join(sk.log).contains("strips a stack of Numbed"), "the log says so")
	sk.end_round()
	assert_eq([m.hull, m.shield], [100, 30], "it struck")
	assert_eq(Effects.stacks_of(boss, "numbed"), 0, "the last stack goes at the round's end: one stun lands again")
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_true(boss.is_suppressed(), "and the next stun lands")


func test_a_second_suppress_on_a_suppressed_foe_adds_nothing() -> void:
	# Ryan, 17 October: "A suppressed foe should not gain numbed from being re-supressed, since
	# suppressed doesn't stack." The second spend is wasted and numbs it no further, and nothing
	# carries: "Suppressed is suppressed - they lose their next action. It does not stack, it
	# does not carry." A Paradox tripping on a suppressed foe is wasted the same way.
	var sk := Skirmish.new(1)
	var a := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.assign(0, g)
	assert_true(g.is_suppressed(), "suppressed by the first")
	sk.assign(1, g)
	assert_eq(Effects.stacks_of(g, "numbed"), 0, "the second suppress lands nothing and numbs it no further")
	var grants := 0
	for m in g.modifiers:
		if m.id == "suppressed":
			grants += 1
	assert_eq(grants, 1, "and leaves one Suppressed, never two")
	assert_true("\n".join(sk.log).contains("already suppressed"), "the log says the spend was wasted")
	assert_false(sk._suppress(g), "a Paradox's trip on it is a suppress like any other: wasted")
	assert_eq(Effects.stacks_of(g, "numbed"), 0, "and numbs it no further")
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "numbed"), g.stun_resist(), "it recovers with its stun resist")
	sk.start_round()
	assert_false(g.is_suppressed(), "it lost the one action and nothing carried into the next round")


func test_a_status_stacks_renews_or_never_stacks_as_its_definition_says() -> void:
	# Ryan, 17 October: renewal without stacking "should be supported, since that's a pretty
	# common thing for a powerful or non-number-related buff to do". A status's definition
	# names it: add (the default: a stack a grant, a timed grant keeping its own end) or renew
	# (one grant, its end the later and its count the larger; on an untimed one-stack status a
	# second grant then changes nothing, which is all "never stacks" ever meant).
	var m := _mech("A", Die.single(Face.attack(20, L)))
	var steady := {"id": "steady", "name": "Steady", "description": "", "stacking": "renew", "tags": ["buff"],
		"effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 5}]}
	Effects.stack(m, steady, Effects.ROUNDS, "buff:a", 1, Effects.DECAY_NONE, 2)
	Effects.stack(m, steady, Effects.ROUNDS, "buff:b", 1, Effects.DECAY_NONE, 3)
	assert_eq(m.modifiers.size(), 1, "a renewing status is one grant however often it is granted")
	assert_eq(Effects.stacks_of(m, "steady"), 1, "never a second stack")
	Effects.end_round(m, 2)
	assert_eq(Effects.stacks_of(m, "steady"), 1, "the later end holds")
	Effects.end_round(m, 3)
	assert_eq(Effects.stacks_of(m, "steady"), 0, "and it goes after that")
	Effects.stack(m, steady, Effects.ROUNDS, "buff:a", 2, Effects.DECAY_NONE, 6)
	Effects.stack(m, steady, Effects.ROUNDS, "buff:b", 1, Effects.DECAY_NONE, 5)
	assert_eq(Effects.stacks_of(m, "steady"), 2, "a renewal with a smaller count keeps the larger")
	Effects.end_round(m, 5)
	assert_eq(Effects.stacks_of(m, "steady"), 2, "and a shorter renewal never shortens")
	Effects.end_round(m, 6)
	assert_eq(Effects.stacks_of(m, "steady"), 0, "gone at the longer end")
	Effects.grant_for_rounds(m, steady, "a", 7)
	Effects.grant_for_rounds(m, steady, "b", 8)
	assert_eq(m.modifiers.size(), 1, "a timed grant takes the policy too: one grant")
	Effects.end_round(m, 7)
	assert_eq(Effects.stacks_of(m, "steady"), 1, "to the later end")
	Effects.end_round(m, 8)
	var once := {"id": "once", "name": "Once", "description": "", "stacking": "renew", "tags": ["buff"], "effects": []}
	Effects.stack(m, once, Effects.SKIRMISH, "x", 1, Effects.DECAY_NONE)
	Effects.stack(m, once, Effects.SKIRMISH, "y", 1, Effects.DECAY_NONE)
	assert_eq(Effects.stacks_of(m, "once"), 1, "an untimed one-stack status renewed is one stack")
	var again := 0
	for mod in m.modifiers:
		if mod.id == "once":
			again += 1
	assert_eq(again, 1, "and one grant of it: never stacking is renewing with nothing to renew")
	# The engine's own: Shocked and Suppressed renew, Empowered adds.
	assert_eq(Effects.status_stacking(Effects.STATUS["shocked"]), "renew", "Shocked renews, one stack")
	assert_eq(Effects.status_stacking(Effects.STATUS["suppressed"]), "renew", "Suppressed renews")
	assert_eq(Effects.status_stacking(Effects.STATUS["overcharged"]), "add", "Empowered adds")


func test_stacked_adds_scale_with_stacks() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.armour = 0
	var plating := {"id": "energy_armour", "name": "Energy Armour", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 5}]}
	Effects.stack(u, plating, Effects.SKIRMISH, "component", 1, Effects.DECAY_NONE)
	Effects.stack(u, plating, Effects.SKIRMISH, "component", 2, Effects.DECAY_NONE)
	assert_eq(u.modifiers.size(), 1, "the same status stacks instead of doubling")
	assert_eq(u.armour, 15, "five per stack, three stacks")


## Rapid's free reroll lands on any other entry, a copy included (Ryan, 15 October), so the
## same Rapid component stacked is a build: each copy fires and switches itself off.
func test_rapid_may_roll_onto_a_copy_of_itself() -> void:
	var chained := 0
	for seed_value in range(1, 40):
		var sk := Skirmish.new(seed_value)
		var d := Die.of([Face.attack(10, L, K.RAPID), Face.attack(10, L, K.RAPID), Face.attack(30, L)])
		sk.add_mech(_mech("A", d))
		sk.add_foes([_ghoul(500)])
		sk.begin()
		sk.start_round()
		sk.mechs[0].face_index = 0
		assert_true(sk.assign(0, sk.front[0]), "seed %d: fire the first copy" % seed_value)
		assert_ne(sk.mechs[0].face_index, 0, "seed %d: never the entry just spent" % seed_value)
		if sk.mechs[0].face_index == 1:
			chained += 1
			assert_true(sk.assign(0, sk.front[0]), "seed %d: the copy fires too" % seed_value)
			assert_eq(sk.front[0].hp, 480, "seed %d: ten and ten" % seed_value)
	assert_true(chained > 0, "over the seeds the free reroll lands on the copy (%d of 39)" % chained)


func test_rapid_rolls_again_for_free_and_switches_itself_off_for_the_round() -> void:
	var sk := Skirmish.new(2)
	var gun := Face.attack(10, L, K.RAPID)   # its switch-off its own, never printed (12 November)
	var d := Die.of([gun, Face.attack(30, L)])
	var m := _mech("A", d)
	sk.add_mech(m)
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "fire the rapid gun")
	assert_eq(sk.front[0].hp, 190, "ten landed")
	assert_false(sk.mechs[0].assigned, "the mech may act again")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "the reroll was free")
	assert_eq(sk.mechs[0].face_index, 1, "the die rolled to the other entry, never the same one")
	assert_true(sk.mechs[0].die.faces[0].has(K.RAPID), "the component itself is untouched")
	sk.mechs[0].face_index = 0
	assert_eq(sk.mechs[0].face().describe(), "disabled", "but shown, the rapid entry is switched off for the round")
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, sk.front[0]), "and the second spend goes through")
	assert_eq(sk.front[0].hp, 160, "thirty more")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_false(sk.mechs[0].face().disabled, "back next round")


## A foe's jam waits for its machine's reboot (Ryan, 19 November: "Lets change Jammed to lasting
## until Reboot, that closes the cockatrice hole"): the entry it shows is dark on every turn after,
## the die's foot showing the reboot's mark and no count, until the machine reboots, whose drop
## lights it; the bot weighs a jam in its reboot.
func test_a_foes_jam_switches_off_the_showing_entry_until_the_reboot() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.of([Face.attack(30, L), Face.attack(30, L), Face.attack(30, L)]), 0, 200)
	sk.add_mech(m)
	var jammer := Foe.make("cockatrice", 900, 0)
	jammer.actions[0]["keywords"] = ["jam"]
	sk.add_foes([jammer])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 0
	sk.end_round()
	assert_eq(Effects.jams_waiting(m), 1, "the jam waits for the reboot")
	sk._suppress(sk.front[0])   # no second jam
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_eq(sk.mechs[0].face().describe(), "disabled", "dark on its next turn")
	assert_true(sk.targets_for(0).is_empty(), "no targets from a blank")
	assert_eq(Effects.dark_rounds(m, 0, sk.round), Effects.DARK_REBOOT, "no count: it waits for the reboot")
	sk.end_round()
	sk._suppress(sk.front[0])
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_eq(sk.mechs[0].face().describe(), "disabled", "and the turn after: no clock lights it")
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_true(bot._wants_reboot(sk, sk.mechs[0]), "the bot wants a reboot for a jam, unpressed")
	assert_true(sk.reboot_mech(0), "the machine reboots")
	assert_eq(Effects.jams_waiting(m), 0, "the reboot lights the entry")
	assert_true("\n".join(sk.log).contains("reboot clears 1 jammed entry"), "the log says so")
	sk._suppress(sk.front[0])   # no jam on the rebooting machine's turn
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_eq(sk.mechs[0].face().describe(), "30", "back, whole, as the round after the reboot opens")


func test_the_die_screen_explains_what_applies_to_a_component() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	var mortar := Face.attack(30, I)
	u.grant_passive({"id": "rs", "name": "Reinforced Skeleton", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.1, "when": "reach_direct"},
		{"trigger": "static", "effect": "set_reach", "value": "direct", "when": "tag_siege"}]})
	assert_true(Effects.explain(u, mortar).is_empty(), "nothing applies to an untagged mortar")
	mortar.tags = ["siege"] as Array[String]
	var notes := Effects.explain(u, mortar)
	assert_eq(notes.size(), 2, "tagged: the reach change and the direct bonus both apply")
	assert_true(notes[0].contains("reach becomes direct (Reinforced Skeleton)") or notes[1].contains("reach becomes direct (Reinforced Skeleton)"), "the reach change names its source")
	assert_eq(Effects.effect_text({"trigger": "on_injury", "effect": "no_destroy", "value": 1}), "on an injury: components are never destroyed", "effects read as sentences")


func test_a_kill_clears_the_slot_at_once_and_opens_the_back_rank() -> void:
	# Ryan, 22 September: burning a hole through the front is a legitimate choice, since it
	# opens the back rank to direct fire until reinforcements plug it at the round's end.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.of([Face.attack(90, L), Face.attack(90, L)]), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(30, 25), _archer(30, 10), _ghoul(30, 25)])
	sk.begin()
	sk.start_round()
	var ghoul: Foe = sk.front[0]
	var archer: Foe = sk.back[0]
	assert_true(archer != null, "the archer stands behind the first ghoul")
	assert_false(sk.targets_for(0).has(archer), "covered: the direct weapon cannot reach it")
	assert_true(sk.assign(0, ghoul), "the blow kills the ghoul")
	assert_eq(sk.front[0], null, "its slot is empty at once")
	assert_true(sk.log[sk.log.size() - 1].ends_with("destroyed"), "logged as destroyed now, not at the round's end")
	assert_true(sk.is_exposed(0), "the column is exposed")
	assert_eq(sk.forecast(sk.mechs[0])["incoming"], 35, "only the archer and the other ghoul count")
	sk.mechs[0].assigned = false
	assert_true(sk.targets_for(0).has(archer), "the line weapon now reaches the archer")
	assert_true(sk.assign(0, archer), "and the second die takes it")
	sk.end_round()
	assert_eq(m.hull, 75, "only the surviving ghoul struck")
	assert_true(sk.front[0] != null or sk.reinforcements.is_empty(), "the hole is plugged at the round's end when anyone waits")


func test_cooling_at_the_start_of_the_round_and_overheating_at_the_end_of_the_turn() -> void:
	# Ryan, 22 September: cool at the start of the round. Ryan, 11 October: the overheat burns
	# at the end of the player's turn, before the enemy acts. The cooling here is granted, a
	# chassis having none of its own, and the gauge never settles (the reboot, 13 November).
	# Nothing a foe lays adds heat (Ablate, 15 November: a machine's Ablating is damage).
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, [], 30)), 40, 100)
	m.heat_max = 60
	m.grant_passive({"id": "radiator", "name": "Radiator", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 10}]}, "radiator")
	var ms := sk.add_mech(m)
	sk.add_foes([_ghoul(30, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(ms.heat, 0, "nothing to cool at the start")
	assert_eq(int(sk.preview_round(0, sk.front[0])["mechs"][0]["heat_after"]), 30, "the die in hand: the face's heat, nothing cooling it this round")
	sk.assign(0, sk.front[0])
	assert_eq(ms.heat, 30, "the face's heat lands when spent")
	sk.end_round()
	assert_eq(ms.heat, 30, "nothing cools at the end of the round")
	sk.start_round()
	assert_eq(ms.heat, 20, "cooled by 10 as the turn begins")
	assert_true(sk.log[sk.log.size() - 1].begins_with("cooling: A -10"), "one log line: %s" % sk.log[sk.log.size() - 1])
	# Overflow burns as the turn ends, never when the face is spent (Ryan, 22 September), so
	# a hot machine can still be vented before it pays.
	ms.heat = 50
	assert_eq(sk.forecast(ms)["overheat"], 0, "the die's heat is not counted in the round as it stands")
	assert_eq(int(sk.preview_round(0, sk.front[0])["mechs"][0]["overheat"]), 20, "the die dragged over its foe: 50 plus 30 on a 60 cap")
	sk.assign(0, sk.front[0])
	assert_eq(ms.heat, 80, "80 on the gauge, past the cap")
	assert_eq(m.hull, 100, "nothing burnt yet")
	assert_eq(sk.forecast(ms)["overheat"], 20, "the forecast warns of the twenty to come")
	assert_eq(sk.forecast(ms)["heat_after"], 80, "and the gauge keeps what it carries: nothing settles")
	sk.end_round()
	assert_eq(m.hull, 100 - 20 - 10, "the twenty burn as the turn ends, and the overheat bares the hull to the ghoul's ten")
	assert_eq(ms.heat, 80, "the heat stands past the cap")
	sk.start_round()
	assert_eq(ms.heat, 70, "then cooled by the ten it is granted")
	assert_eq(m.hull, 100 - 20 - 10, "nothing burns at the round's start")
	# Cooling is a stat like any other: a second grant adds to it, and it never goes below zero.
	m.grant_passive({"id": "fins", "name": "Fins", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 15}]}, "fins")
	assert_eq(m.cooling, 25, "the two grants together")
	ms.heat = 5
	sk.end_round()
	assert_eq(ms.heat, 5, "nothing adds to it at the end of the turn")
	sk.start_round()
	assert_eq(ms.heat, 0, "never below zero")
	assert_true(sk.log[sk.log.size() - 1].begins_with("cooling: A -5"), "logged as what was actually shed: %s" % sk.log[sk.log.size() - 1])


func test_the_forecast_counts_ablating_the_turn_after_it_is_laid() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 100)
	var ms := sk.add_mech(m)
	var demon := _ghoul(30, 10)
	demon.actions[0]["keywords"] = ["ablate"]
	demon.actions[0]["strikes"] = 2
	demon.action = demon.actions[0]
	sk.add_foes([demon])
	sk.begin()
	sk.start_round()
	var per := _rule("ablating_mech", "tick_hp")
	var fc := sk.forecast(ms)
	assert_eq([int(fc["ablated"]), int(fc["heat_after"])], [0, 0], "what the blows will lay takes nothing this turn, and no heat ever")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "ablating_mech"), 2, "two ablating blows, two stacks")
	assert_eq(m.hull, 100 - 20, "two blows of ten on bare hull")
	sk.start_round()
	assert_eq(int(sk.forecast(ms)["ablated"]), 2 * per, "the turn's end: two stacks' points, unless cleansed")
	assert_eq(int(sk.forecast(ms)["hull_after"]), 80 - 2 * per - 20, "off the bare hull, before the two blows to come")


func test_no_cooling_means_no_line_and_no_change() -> void:
	var sk := Skirmish.new(1)
	var ms := sk.add_mech(_mech("A", Die.single(Face.attack(10, L, [], 30)), 40, 100))
	sk.add_foes([_ghoul(30, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var lines := sk.log.size()
	sk.end_round()
	assert_eq(ms.heat, 30, "a chassis with no cooling keeps its heat")
	for j in range(lines, sk.log.size()):
		assert_false(sk.log[j].begins_with("cooling"), "no cooling line")


func test_venting_before_the_end_of_the_turn_prevents_the_burn() -> void:
	var sk := Skirmish.new(1)
	var hot := _mech("Hot", Die.single(Face.attack(10, L, [], 50)), 40, 100)
	hot.heat_max = 60
	var ms := sk.add_mech(hot)
	var cool := _mech("Cool", Die.single(Face.vent(30)), 40, 100)
	sk.add_mech(cool)
	sk.add_foes([_ghoul(90, 10)])
	sk.begin()
	sk.start_round()
	ms.heat = 30
	sk.assign(0, sk.front[0])
	assert_eq(ms.heat, 80, "twenty over the cap")
	assert_eq(sk.forecast(ms)["overheat"], 20, "warned")
	assert_true(sk.assign(1, ms), "the ally vents it")
	assert_eq(ms.heat, 50, "back under the cap")
	assert_eq(sk.forecast(ms)["overheat"], 0, "nothing to burn")
	sk.end_round()
	assert_eq(hot.hull, 100, "no burn: the vent came in time")


func test_the_overheat_burns_before_the_enemy_acts() -> void:
	# Ryan, 11 October: the burn is the end of the player's turn. A machine it wrecks is gone
	# before the enemy strikes, so the foe aimed at it turns on the one still standing.
	var sk := Skirmish.new(1)
	var hot := _mech("Hot", Die.single(Face.attack(10, L, [], 50)), 0, 10)
	hot.heat_max = 30
	sk.add_mech(hot)
	var other := _mech("Other", Die.single(Face.shield(10)), 0, 100)
	sk.add_mech(other)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	g.target = sk.mechs[0]
	sk.assign(0, sk.front[0])
	assert_eq(sk.forecast(sk.mechs[0])["overheat"], 20, "twenty over a 30 cap")
	assert_eq(sk.end_round(), Skirmish.Outcome.NONE, "one machine still stands")
	assert_false(sk.mechs[0].alive(), "the burn wrecked it as the turn ended")
	assert_eq(other.hull, 90, "so the blow aimed at it landed on the other")
	assert_eq(sk.overheats.size(), 1, "the burn is on record for the replay")
	assert_eq(int(sk.turn_events[0]["mech"]), 1, "and the enemy's only blow fell on the survivor")


## The overheat's what-if switch (30 October; the runner's --overheat N): an overheat burns N hull
## a point past the maximum, and the forecast reads the same; the engine's own is one for one.
func test_the_overheat_scale_burns_its_multiple_and_the_forecast_reads_it() -> void:
	assert_eq(Skirmish.overheat_scale, 1, "the engine burns one for one")
	Skirmish.overheat_scale = 2
	var sk := Skirmish.new(1)
	var hot := _mech("Hot", Die.single(Face.attack(10, L, [], 40)), 0, 100)
	hot.heat_max = 30
	sk.add_mech(hot)
	sk.add_foes([_ghoul(500, 0)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var fc := sk.forecast(sk.mechs[0])
	sk.end_round()
	Skirmish.overheat_scale = 1
	assert_eq(int(fc["overheat"]), 10, "ten past a cap of thirty")
	assert_eq(int(fc["hull_after"]), 80, "the forecast burns twenty")
	assert_eq(hot.hull, 80, "and so does the turn's end")
	assert_eq([int(sk.overheats[0]["over"]), int(sk.overheats[0]["burn"])], [10, 20], "the record keeps the excess and the burn")


## The overheat's other what-if (Ryan, 30 October; the runner's --overheat-corrupt N), on the
## component whose spend took the gauge past its maximum: Corrupted by the overheat; off as the
## engine runs. No overheat burns a component out (the injury threshold it read went on 15
## November).
func test_an_overheat_corrupts_the_component_that_took_it_over() -> void:
	var cases := [[40, 1, 30, 1], [35, 2, 35, 2], [35, 0, 35, 0]]
	for c in cases:
		Skirmish.overheat_corrupt = int(c[1])
		var sk := Skirmish.new(1)
		var hot := _mech("Hot", Die.single(Face.attack(10, L, [], int(c[0]))), 0, 40)
		hot.heat_max = 30
		sk.add_mech(hot)
		sk.add_foes([_ghoul(500, 0)])
		sk.begin()
		sk.start_round()
		sk.assign(0, sk.front[0])
		sk.end_round()
		Skirmish.overheat_corrupt = 0
		var said := "heat %d, corrupt %d" % [int(c[0]), int(c[1])]
		assert_eq(hot.hull, int(c[2]), "%s: the burn" % said)
		assert_eq(sk.mechs[0].die.faces[0].kind, Face.Kind.ATTACK, "%s: no overheat burns a component out" % said)
		assert_eq(Effects.corrupt_stacks(hot, 0), int(c[3]), "%s: the corruption" % said)


## A vent that brings the gauge back under the maximum clears the what-ifs' culprit (2 November):
## a status's heat taking it over again afterwards marks nothing, where the spend's own excess
## left standing marks its entry.
func test_a_vent_under_the_maximum_clears_the_overheats_culprit() -> void:
	for vented in [true, false]:
		Skirmish.overheat_corrupt = 1
		var sk := Skirmish.new(1)
		var hot := _mech("Hot", Die.single(Face.attack(10, L, [], 50)), 40, 100)
		hot.heat_max = 60
		var ms := sk.add_mech(hot)
		sk.add_mech(_mech("Cool", Die.single(Face.vent(30)), 40, 100))
		sk.add_foes([_ghoul(500, 0)])
		sk.begin()
		sk.start_round()
		ms.heat = 30
		sk.assign(0, sk.front[0])
		assert_eq([ms.heat, ms.hot_entry], [80, 0], "the spend took the gauge to eighty: its entry stands accused")
		if vented:
			assert_true(sk.assign(1, ms), "the ally vents it")
			assert_eq([ms.heat, ms.hot_entry], [50, -1], "back under the maximum, nothing stands accused")
		ms.heat += 20   # a status's heat (a seal's) through the gauge: 70, or 100 unvented
		sk.end_round()
		Skirmish.overheat_corrupt = 0
		assert_eq(Effects.corrupt_stacks(hot, 0), 0 if vented else 1, "vented %s: the overheat corrupts the entry only while its own excess stands" % str(vented))


func test_an_overheat_that_wrecks_the_last_machine_ends_the_fight_before_the_enemy_acts() -> void:
	var sk := Skirmish.new(1)
	var hot := _mech("Hot", Die.single(Face.attack(10, L, [], 50)), 40, 10)
	hot.heat_max = 30
	sk.add_mech(hot)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.end_round(), Skirmish.Outcome.DEFEAT, "burnt out on its own turn")
	assert_true(sk.turn_events.is_empty(), "the enemy never struck")
	assert_eq(sk.state, Skirmish.State.DONE, "the fight is over")


## The overheat burns as the player's turn ends, before the enemy strikes (Ryan, 11 October;
## a withdrawal shared the turn's end until the long wall brief took it away): running hot is
## paid in hull on the machine's own turn, and the enemy's blow lands after on what the overheat
## left, the first one between reboots breaking the shield (13 November).
func test_the_overheat_burns_before_the_enemy_strikes() -> void:
	var sk := Skirmish.new(1)
	var hot := _mech("Hot", Die.single(Face.attack(10, L, [], 50)), 40, 100)
	hot.heat_max = 30
	sk.add_mech(hot)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(sk.outcome, Skirmish.Outcome.NONE, "the fight goes on")
	assert_eq(hot.shield, 0, "its first overheat broke its shield as the turn ended")
	assert_eq(hot.hull, 70, "the twenty over the cap burnt then, and the enemy's ten landed after on the hull it bared")


## A stun lock costs its stuns (Ryan, 2 November): a foe with Numbed N takes N stuns to strip and
## one more to stun, every round it is held, since it recovers with its resist again; a fresh
## foe is stunned by one, boss or not; a Warded foe turns the stun away.
func test_a_numbed_foe_is_stunned_by_one_stun_more_than_its_stacks() -> void:
	var sk := Skirmish.new(1, 3)
	for name in ["A", "B", "C"]:
		sk.add_mech(_mech(name, Die.single(Face.attack(0, L, K.SUPPRESS)), 0, 100))
	var g := _ghoul(500, 30)
	g.resist = 2
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, g) and g.is_suppressed(), "a fresh foe is stunned by one, whatever its resist")
	sk.end_round()
	assert_eq([Effects.stacks_of(g, "numbed"), g.stun_resist()], [2, 2], "it recovers with its resist in stacks")
	sk.start_round()
	sk.assign(0, g)
	sk.assign(1, g)
	assert_false(g.is_suppressed(), "two stuns strip two stacks and land nothing")
	assert_eq(Effects.stacks_of(g, "numbed"), 0, "stripped bare")
	sk.assign(2, g)
	assert_true(g.is_suppressed(), "the third lands: the lock costs its resist and one")
	sk.end_round()
	assert_eq(sk.mechs[0].unit.hull + sk.mechs[1].unit.hull + sk.mechs[2].unit.hull, 300, "it skipped again")
	assert_eq(Effects.stacks_of(g, "numbed"), 2, "and recovers with its resist again")
	var warded := _ghoul(500, 30)
	var s2 := Skirmish.new(2)
	s2.add_mech(_mech("A", Die.single(Face.attack(0, L, K.SUPPRESS)), 0, 100))
	s2.add_foes([warded])
	s2.begin()
	s2.start_round()
	Effects.stack(warded, Effects.foe_ward(), Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_TURN_ALL)
	assert_true(s2.assign(0, warded), "a stun at a Warded foe")
	assert_false(warded.is_suppressed(), "the Ward turns the stun away (2 November)")
	assert_true("\n".join(s2.log).contains("Ward turns away Suppressed"), "and the spend says so: %s" % s2.log.back())
	assert_true(Effects.has(warded, "ward"), "the Ward stands")


func test_a_corrupt_blow_rots_the_showing_entry_and_it_bites_when_spent() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L)), 0, 200)
	sk.add_mech(m)
	var chorister := Foe.make("chorister", 500, 10)
	chorister.actions[0]["keywords"] = ["corrupt"]
	sk.add_foes([chorister])
	sk.begin()
	sk.start_round()
	assert_eq(sk.pending_bite(sk.mechs[0]), 0, "clean to begin with")
	sk.end_round()
	assert_eq(m.hull, 190, "the blow itself")
	assert_eq(Effects.corrupt_stacks(m, 0), 1, "one stack on the entry that was showing")
	assert_true("\n".join(sk.log).contains("corrupts A's 30"), "the log names the entry")
	sk.start_round()
	var cb := Effects.status_value("corrupted", "corrupt_bite")
	assert_eq(sk.pending_bite(sk.mechs[0]), cb, "spending it costs its bite")
	var pv: Dictionary = sk.preview_round(0, sk.front[0])["mechs"][0]
	assert_eq([int(pv["bite"]), int(pv["hull_after"])], [cb, 180 - cb], "the round preview names the bite and counts it with the blow while the die is in hand")
	assert_eq(sk.forecast(sk.mechs[0])["hull_after"], 180, "and only the blow otherwise")
	sk.assign(0, sk.front[0])
	assert_eq(m.hull, 190 - cb, "the bite lands as the entry is spent")
	assert_eq(sk.front[0].hp, 470, "and the component still does its work")
	sk.end_round()
	assert_eq(Effects.corrupt_stacks(m, 0), 2, "it stacks")
	sk.start_round()
	assert_eq(sk.pending_bite(sk.mechs[0]), 2 * cb, "two bites a spend now")
	sk._finish()
	assert_eq(Effects.corrupt_stacks(m, 0), 0, "gone with the skirmish")


func test_the_bite_takes_shield_first_and_never_armour() -> void:
	var sk := Skirmish.new(1)
	var cb := Effects.status_value("corrupted", "corrupt_bite")
	var m := _mech("A", Die.single(Face.attack(30, L)), cb, 100)   # a shield of one stack's bite
	m.armour = 50
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.corrupt_entry(m, 0, "foe:x", 2)
	sk.assign(0, sk.front[0])
	assert_eq(m.shield, 0, "the shield goes first")
	assert_eq(m.hull, 100 - cb, "the rest reaches the hull, armour or no armour")
	assert_eq(sk.front[0].hp, 470, "the attack still landed")


func test_cleanse_clears_what_foes_did_and_not_a_cooldown() -> void:
	var sk := Skirmish.new(1)
	var scrubber := Face.shield(10)
	scrubber.add_keyword(K.CLEANSE)
	var a := _mech("A", Die.single(scrubber), 0, 100)
	var b := _mech("B", Die.single(Face.attack(30, L)), 40, 100)
	b.shield = 5
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.corrupt_entry(b, 0, "foe:x", 2)
	Effects.disable_entry(b, 0, "foe:x", sk.round + 1)
	Effects.stack(b, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "foe:x", 3, Effects.DECAY_TURN)
	Effects.stack(b, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe:x", 2, Effects.DECAY_TURN_ALL)
	assert_eq(scrubber.describe(), "shield 10 cleanse", "the keyword reads on the entry")
	assert_true(sk.assign(0, sk.mechs[1]), "the shield is spent on B")
	assert_eq(b.shield, 15, "shielded")
	assert_eq(Effects.corrupt_stacks(b, 0), 0, "corruption gone")
	assert_false(Effects.is_entry_disabled(b, 0), "the foe's disable gone")
	assert_eq(Effects.stacks_of(b, "ablating_mech"), 0, "Ablating gone")
	assert_eq(Effects.stacks_of(b, "scorched"), 0, "scorched gone")
	assert_true("\n".join(sk.log).contains("cleanses B: "), "the log says what went")
	Effects.disable_entry(a, 0, "cooldown", sk.round)
	var gone := Effects.cleanse(a)
	assert_true(gone.is_empty(), "a cooldown is not the cleanse's to lift")
	assert_true(Effects.is_entry_disabled(a, 0), "and it stays")


func test_the_die_row_names_a_components_own_passive() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive({"id": "fins", "name": "Fins", "description": "Cooling +5.",
		"effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 5}]}, "heat_sink", "heat_sink")
	var sink := Face.vent(20)
	sink.component = "heat_sink"
	var gun := Face.attack(20, L)
	gun.component = "gun"
	assert_eq(Effects.explain(u, sink).size(), 1, "a vent entry names its own passive")
	assert_eq(Effects.explain(u, sink)[0], "passive: Fins", "by name")
	assert_true(Effects.explain(u, gun).is_empty(), "another component's entry does not")
	assert_eq(u.cooling, 5, "and the stat reads it")


func test_a_target_status_condition_reads_the_foe_struck() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L)), 0, 100)
	m.grant_passive({"id": "sol", "name": "Solenoid", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.5, "when": "target_status"}]})
	sk.add_mech(m)
	var clean := _ghoul(200, 10)
	var lit := _ghoul(200, 10)
	sk.add_foes([clean, lit])
	sk.begin()
	sk.start_round()
	sk.assign(0, clean)
	assert_eq(clean.hp, 180, "a clean foe takes the plain 20")
	sk.end_round()
	sk.start_round()
	Effects.stack(lit, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 1)
	sk.assign(0, lit)
	assert_eq(lit.hp, 170, "a burning foe takes 20 times 1.5")
	var notes := Effects.explain(m, m.die.faces[0])
	assert_eq(notes.size(), 1, "the die row shows the rule")
	assert_true(notes[0].begins_with("foes carrying a status: damage ×1.5"), "with its condition as the lead: %s" % notes[0])
	assert_eq(int(Effects.attack(m, m.die.faces[0], 20, 0)["damage"]), 20, "asked without a target, the condition does not hold")


func test_stacks_a_hot_machine_applies_run_deeper() -> void:
	# The Stingray's Exothermic Suite (2 October): every stack this machine applies is one
	# deeper per 20 heat it carries, on a foe's burn, an ally's buff or its own devour;
	# Numbed never (exempt from every interaction).
	var hot := {"id": "hot", "name": "Exothermic Suite", "description": "", "effects": [
		{"trigger": "on_stack", "effect": "add_stacks", "value": 1, "per_heat": 20}]}
	var sk := Skirmish.new(1)
	var m := _mech("Ray", Die.single(Face.attack(10, L, K.ABLATE)), 40, 100)   # Ablate 1: one stack (the number, since 18 October)
	m.grant_passive(hot)
	sk.add_mech(m)
	var g := _ghoul(500, 0)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(g, "ablating"), 1, "cold, a 10 burn is one stack")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].heat = 45
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(g, "ablating"), 1 + 2, "at 45 heat the same burn is two deeper, two whole steps of 20 (the first round's stack burned off at the ghoul's turn)")
	assert_true(sk.log[sk.log.size() - 2].contains("runs hot: +2 Ablate"), "and the log says so: %s" % sk.log[sk.log.size() - 2])
	# A buff on an ally is deepened the same way; Numbed from a suppress is not.
	var s2 := Skirmish.new(2)
	var buff := Face.buff("primed", 1, 1)
	var a := _mech("Ray", Die.single(buff), 40, 100)
	a.grant_passive(hot)
	var ally := _mech("Friend", Die.single(Face.attack(10, L, K.SUPPRESS)), 40, 100)
	s2.add_mech(a)
	s2.add_mech(ally)
	var g2 := _ghoul(500, 0)
	s2.add_foes([g2])
	s2.begin()
	s2.start_round()
	s2.mechs[0].heat = 60
	s2.assign(0, s2.mechs[1])
	assert_eq(Effects.stacks_of(ally, "primed"), 1 + 3, "a one-stack buff at 60 heat lands four deep")
	var s3 := Skirmish.new(3)
	var z := _mech("Ray", Die.single(Face.attack(10, L, K.SUPPRESS)), 40, 100)
	z.grant_passive(hot)
	s3.add_mech(z)
	var g3 := _ghoul(500, 0)
	s3.add_foes([g3])
	s3.begin()
	s3.start_round()
	s3.mechs[0].heat = 60
	s3.assign(0, s3.front[0])
	assert_eq(Effects.stacks_of(g3, "numbed"), 0, "Numbed is exempt: the stun lays none, the recovery counts its resist and nothing deepens it")
	assert_eq(Effects.extra_stacks(z, "numbed", 100), 0, "asked directly, Numbed gains nothing")
	# A Barrier is one stack whoever grants it (Ryan, 10 November: "Barrier probably shouldn't be
	# stackable. The stingray stacks it due to its passive"): the hot machine's reads x1, takes
	# one blow, and a Purge of one takes it whole; a foe's own Barrier the same.
	assert_true(Effects.is_single("barrier") and not Effects.is_single("primed"), "the Barrier is single, a buff that stacks is not")
	assert_eq(Effects.extra_stacks(z, "barrier", 100), 0, "asked directly, a Barrier gains nothing")
	var s4 := Skirmish.new(4)
	var door := _mech("Ray", Die.single(Face.buff("barrier", 1, 1)), 12, 100)
	door.grant_passive(hot)
	s4.add_mech(door)
	var h1 := _ghoul(500, 6)
	var h2 := _ghoul(500, 6)
	s4.add_foes([h1, h2])
	s4.begin()
	s4.start_round()
	s4.mechs[0].heat = 60
	h1.target = s4.mechs[0]
	h2.target = s4.mechs[0]
	s4.assign(0, s4.mechs[0])
	assert_eq(Effects.stacks_of(door, "barrier"), 1, "at 60 heat its Barrier is still one")
	assert_false(s4.log[s4.log.size() - 1].contains("runs hot") or s4.log[s4.log.size() - 2].contains("runs hot"), "and the log claims no deeper one")
	s4.end_round()
	assert_eq([door.shield, door.hull], [6, 100], "it took one blow of the two: the other landed on the shield")
	var twice := _mech("Twice", Die.single(Face.buff("barrier", 3, 1)), 12, 100)
	Effects.grant_buff(twice, "barrier", 3, "test", 1)
	Effects.grant_buff(twice, "barrier", 2, "test", 1)
	assert_eq(Effects.stacks_of(twice, "barrier"), 1, "a grant of three, then of two: one")
	Effects.purge(twice, 1)
	assert_false(Effects.has(twice, "barrier"), "a Purge of one takes it whole")
	var sheltered := _ghoul(50, 1)
	Effects.stack(sheltered, Effects.foe_barrier(), Effects.SKIRMISH, "test", 2, Effects.DECAY_TURN_ALL)
	assert_eq(Effects.stacks_of(sheltered, "barrier"), 1, "a foe's Barrier is one too")
	assert_eq(Effects.extra_stacks(z, "ablating", 19), 0, "under one step, nothing")
	assert_eq(Effects.extra_stacks(z, "ablating", 100), 5, "five steps at 100")
	assert_true(Effects.effect_text({"trigger": "on_stack", "effect": "add_stacks", "value": 1, "per_heat": 20}).begins_with("every stack this machine applies is 1 deeper for every 20 heat it carries"), "reads as a sentence")


## The Pocket Paradox as a meter (Ryan, 10 October): a foe gains Paradox for each other status
## it gains, once a spend however many strikes or stacks; at the count it is Suppressed and
## the Paradox clears. Paradox is a status, never decays, and never feeds itself.
func test_the_paradox_meter_knocks_a_foe_out_at_its_count() -> void:
	var meter := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "paradox", "value": 6}]}
	var sk := Skirmish.new(1)
	var gun := Face.attack(5, L, [K.ABLATE, K.SHOCK])
	gun.strikes = 3
	var m := _mech("A", Die.single(gun), 0, 100)
	m.grant_passive(meter)
	sk.add_mech(m)
	var g := _ghoul(500, 30)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_eq(Effects.paradox(m), [1, 6] as Array[int], "a stack a debuff stack, six to trip")
	assert_eq(sk.paradox_count(), 6, "the team's count")
	sk.assign(0, g)
	assert_eq(Effects.stacks_of(g, "paradox"), 4, "three strikes of Ablate 1 are three stacks and the Shock a fourth (11 November: a stack a stack)")
	assert_false(g.is_suppressed(), "not yet")
	sk._foe_gained_status(g, "paradox")
	assert_eq(Effects.stacks_of(g, "paradox"), 4, "Paradox never feeds itself")
	sk._foe_gained_status(g, "numbed")
	assert_eq(Effects.stacks_of(g, "paradox"), 4, "nor Numbed, the foe's own buff")
	sk._foe_gained_status(g, "ablating", 2)
	assert_true(g.is_suppressed(), "six trips it: its past self knocks it out")
	assert_eq(Effects.stacks_of(g, "paradox"), 0, "the Paradox clears, and the Suppressed it caused added none")
	assert_eq(Effects.stacks_of(g, "numbed"), 0, "Numbed lands as it recovers, not as the stun does")
	assert_true("\n".join(sk.log).contains("trapped in a paradox"), "the log says so")
	sk.end_round()
	assert_eq(m.hull, 100, "it skipped its blow")
	# Paradox never decays.
	sk.start_round()
	sk._foe_gained_status(g, "ablating")
	sk.end_round()
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "paradox"), 1, "two rounds on, the stack still stands")
	# A Suppress keyword's suppress is a status gained; a trip on a foe already suppressed is wasted, the
	# meter spent (Ryan, 17 October: Suppressed never stacks and never carries).
	var s2 := Skirmish.new(2)
	var m2 := _mech("B", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	m2.grant_passive(meter)
	s2.add_mech(m2)
	var g2 := _ghoul(500, 30)
	s2.add_foes([g2])
	s2.begin()
	s2.start_round()
	s2.assign(0, g2)
	assert_true(g2.is_suppressed(), "the weapon's suppress landed")
	assert_eq(Effects.stacks_of(g2, "paradox"), 1, "and it counts as a status gained")
	Effects.remove(g2, "numbed")   # no resistance, so the trip is certain
	s2._foe_gained_status(g2, "ablating", 4)
	s2._foe_gained_status(g2, "shocked")
	assert_eq(Effects.stacks_of(g2, "paradox"), 0, "tripped, and the meter is spent on a foe already suppressed")
	assert_true("\n".join(s2.log).contains("already suppressed"), "the trip was wasted on it")
	assert_eq(Effects.stacks_of(g2, "numbed"), 0, "and numbed it no further")
	s2.end_round()
	assert_eq(m2.hull, 100, "suppressed this round")
	s2.start_round()
	assert_false(g2.is_suppressed(), "and nothing carried: it lost the one action")
	# A machine that deepens what it applies deepens Paradox, so it trips sooner.
	var s3 := Skirmish.new(3)
	var m3 := _mech("C", Die.single(Face.attack(20, L, K.ABLATE)), 40, 100)
	m3.grant_passive(meter)
	m3.grant_passive({"id": "deep", "name": "Deep", "description": "", "effects": [{"trigger": "on_stack", "effect": "add_stacks", "value": 1}]})
	s3.add_mech(m3)
	var g3 := _ghoul(500, 30)
	s3.add_foes([g3])
	s3.begin()
	s3.start_round()
	s3.assign(0, g3)
	assert_eq(Effects.stacks_of(g3, "paradox"), 3, "Ablate 1 deepened to two stacks, two Paradox, deepened to three")
	assert_true(Effects.effect_text({"trigger": "on_foe_status", "effect": "paradox", "value": 3}).begins_with("a foe gains a Paradox stack for every stack of another debuff it gains; at 3 or more every stack is consumed and it is Suppressed"), "reads as a sentence")


## A foe carrying a status (the Susceptibility Tensor's condition, 10 October) means what the
## team put on it: never Numbed, a resistance, and never the foe's own buffs.
func test_a_status_on_a_foe_is_what_the_team_put_there() -> void:
	var g := _ghoul(100)
	assert_false(Effects.carries_status(g), "bare")
	Effects.stack(g, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 2)
	assert_false(Effects.carries_status(g), "Numbed is no status")
	Effects.stack(g, Effects.STATUS["braced"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_ROUND)
	assert_false(Effects.carries_status(g), "nor is its own buff")
	Effects.stack(g, Effects.STATUS["paradox"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_true(Effects.carries_status(g), "Paradox is")
	var u := _mech("A", Die.single(Face.attack(20, L)))
	u.grant_passive({"id": "tensor", "name": "Tensor", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 5, "when": "target_status"}]})
	assert_eq(int(Effects.attack(u, u.die.faces[0], 20, 0, g)["damage"]), 25, "so the Tensor reads it")
	Effects.remove(g, "paradox")
	assert_eq(int(Effects.attack(u, u.die.faces[0], 20, 0, g)["damage"]), 20, "and not Numbed or a Braced foe")


func test_a_buff_component_grants_its_status_through_the_round() -> void:
	var sk := Skirmish.new(1)
	var coil := Face.buff("overcharged", 10, 1)   # ten stacks, a point each; a halving status takes no rounds (18 October)
	var a := _mech("A", Die.single(coil), 40, 100)
	var b := _mech("B", Die.single(Face.attack(20, L)), 40, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(coil.describe(), "Empowered ×10", "the entry names the status and its stacks")
	assert_eq(coil.number_text(), "×10", "the die shows the stacks")
	assert_true(coil.on_machines() and coil.is_equipment(), "a buff is equipment, spent on a machine")
	assert_true(sk.assign(0, sk.mechs[1]), "spent on B")
	assert_eq(Effects.stacks_of(b, "overcharged"), 10, "ten stacks on B")
	sk.assign(1, sk.front[0])
	assert_eq(sk.front[0].hp, 500 - 30, "20 plus 1 a stack, ten stacks")
	sk.end_round()
	assert_eq(Effects.stacks_of(b, "overcharged"), 5, "halved at the round's end, rounded down (Ryan, 18 October: a halving rule has no duration)")
	sk.start_round()
	sk.assign(1, sk.front[0])
	assert_eq(sk.front[0].hp, 500 - 30 - 25, "20 plus the five left the round after")
	# A two-round buff outlasts the first end of round; targets are the component's to set. A
	# Ward here: Armoured ends as its side's next turn begins and takes no rounds (16 November).
	var s2 := Skirmish.new(2)
	var brace := Face.buff("ward", 1, 2)
	brace.targets = Face.Target.ALLY
	var c := _mech("C", Die.single(brace), 40, 100)
	var d := _mech("D", Die.single(Face.attack(20, L)), 0, 100)
	s2.add_mech(c)
	s2.add_mech(d)
	s2.add_foes([_ghoul(500, 20)])
	s2.begin()
	s2.start_round()
	s2.front[0].target = s2.mechs[1]   # its pick, set: the test is the brace's, not the aim's
	assert_false(s2.assign(0, null), "allies only: not on itself")
	assert_true(s2.assign(0, s2.mechs[1]), "on the ally")
	s2.end_round()
	assert_true(Effects.has(d, "ward"), "still there after one round")
	assert_eq(d.hull, 100 - 20, "a Ward turns riders, never the blow: 20 on bare hull")
	s2.start_round()
	s2.end_round()
	assert_false(Effects.has(d, "ward"), "gone after the second")
	var rt := Face.from_dict({"kind": "buff", "status": "ward", "stacks": 3, "rounds": 2, "targets": "self"})
	assert_eq(rt.to_dict(), {"kind": "buff", "reach": "none", "power": 0, "keywords": [], "heat": 0, "targets": "self", "status": "ward", "stacks": 3, "rounds": 2}, "a buff round-trips through content")


func test_the_bot_values_a_burn_more_when_a_paradox_may_trip_on_the_foe() -> void:
	var loop := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "paradox", "value": 1}]}
	var scores: Array[float] = []
	for with_loop in [false, true]:
		var sk := Skirmish.new(1)
		var m := _mech("A", Die.single(Face.attack(20, L, K.ABLATE)), 40, 100)
		if with_loop:
			m.grant_passive(loop)
		sk.add_mech(m)
		sk.add_foes([_ghoul(500, 30)])
		sk.begin()
		sk.start_round()
		var pol := Policy.make(Policy.GREEDY)
		scores.append(pol.attack_score(sk, sk.mechs[0], sk.mechs[0].face(), sk.front[0]))
	assert_true(scores[1] > scores[0] + 1.0, "the stopped blow counts: %s without the loop, %s with" % [scores[0], scores[1]])
	# And a buff is an option the bot weighs: a coil on a machine holding an attack scores above zero.
	var s2 := Skirmish.new(3)
	var a := _mech("A", Die.single(Face.buff("overcharged", 2)), 40, 100)
	var b := _mech("B", Die.single(Face.attack(30, L)), 40, 100)
	s2.add_mech(a)
	s2.add_mech(b)
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	var pol2 := Policy.make(Policy.GREEDY)
	var opts: Array = pol2.options_for(s2, 0)
	assert_eq(opts.size(), 2, "self and the ally")
	var on_b := 0.0
	var on_a := 0.0
	for o in opts:
		if o["target"] == s2.mechs[1]:
			on_b = float(o["score"])
		else:
			on_a = float(o["score"])
	assert_true(on_b > on_a, "the coil is worth more on the machine that can shoot this round (%s vs %s)" % [on_b, on_a])


func test_a_volatile_spend_bites_hull_past_shield_and_armour() -> void:
	var sk := Skirmish.new(1)
	var fist := Face.attack(30, L)
	fist.volatile = 10   # Volatile 10: a cost printed on the entry (Ryan, 26 October: a cost beside the heat, a keyword with a chip until then)
	var m := _mech("A", Die.single(fist), 40, 100)
	m.armour = 50
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(fist.describe(), "30 (-10 hull)", "the cost reads on the entry as the heat does")
	assert_false(fist.to_dict().has("keywords") and Array(fist.to_dict()["keywords"]).has("volatile"), "and is no keyword")
	assert_eq(sk.pending_volatile(sk.mechs[0]), 10, "spending it costs the 10 hull it says")
	var pv: Dictionary = sk.preview_round(0, sk.front[0])["mechs"][0]
	assert_eq(int(pv["volatile"]), 10, "the round preview names the cost while the die is in hand")
	assert_eq(int(pv["hull_after"]), 90, "and takes it off the hull, shield or no shield")
	assert_eq(sk.forecast(sk.mechs[0])["hull_after"], 100, "nothing otherwise: the ghoul's blow is blocked")
	assert_true(sk.assign(0, sk.front[0]), "spent")
	assert_eq(m.hull, 90, "the bite lands on the hull as the entry is spent, past shield and armour")
	assert_eq(m.shield, 40, "the shield never saw it")
	assert_eq(sk.front[0].hp, 470, "and the component still does its work")
	assert_true("\n".join(sk.log).contains("A: 30 (-10 hull) costs hull 10"), "the log says so")
	assert_eq(sk.pending_volatile(sk.mechs[0]), 0, "a spent die costs nothing more")


func test_a_volatile_shield_costs_hull_to_raise() -> void:
	var sk := Skirmish.new(1)
	var plate := Face.shield(20)
	plate.volatile = 10
	var m := _mech("A", Die.single(plate), 40, 100)
	m.shield = 5
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, null), "raised on itself")
	assert_eq(m.shield, 25, "the shield stands")
	assert_eq(m.hull, 90, "and cost hull to raise")


func test_a_volatile_component_can_wreck_its_owner_before_it_acts() -> void:
	var sk := Skirmish.new(1)
	var bomb := Face.attack(30, L)
	bomb.volatile = 10
	var m := _mech("A", Die.single(bomb), 40, 10)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.preview_round(0, sk.front[0])["mechs"][0]["destroyed"], "the round preview warns with the die in hand")
	assert_true(sk.assign(0, sk.front[0]), "the spend is legal")
	assert_eq(m.hull, 0, "wrecked by its own component")
	assert_eq(sk.front[0].hp, 500, "which never fired")
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "the fight is decided")
	assert_true("\n".join(sk.log).contains("wrecked by its own volatile component"), "the log says why")


func test_a_disabled_volatile_entry_does_not_bite() -> void:
	var sk := Skirmish.new(1)
	var fist := Face.attack(30, L)
	fist.volatile = 1
	var m := _mech("A", Die.single(fist), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.disable_entry(m, 0, "foe:x", sk.round + 1)
	assert_eq(sk.pending_volatile(sk.mechs[0]), 0, "a blank is never spent")
	assert_true(sk.assign(0, null), "the blank is discarded")


## A shield cost (Ryan, 26 October: "if you don't have the shield, the face cannot be played, and
## overshield does cheat it out at the cost of using two actions for one effect"): taken first
## from the shield as it stands, overshield included; short of it, the entry is locked: nowhere to
## land, the drag finds no target, END TURN pulses, the die shows the cost struck through.
func test_a_shield_cost_is_paid_first_and_locks_the_entry_while_the_shield_is_short() -> void:
	var sk := Skirmish.new(1)
	var lance := Face.attack(30, L)
	lance.shield_cost = 15
	var m := _mech("A", Die.single(lance), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(lance.describe(), "30 (-15 shield)", "the cost reads on the entry")
	assert_false(sk.shield_short(sk.mechs[0], lance), "40 shield pays 15")
	assert_false(sk.shown_face(sk.mechs[0], lance).short, "and the die shows it payable")
	assert_true(sk.can_assign(0, sk.front[0]), "playable")
	assert_true(sk.assign(0, sk.front[0]), "spent")
	assert_eq(m.shield, 25, "the shield paid it first")
	assert_eq(sk.front[0].hp, 470, "and the component did its work")
	assert_true("\n".join(sk.log).contains("A: 30 (-15 shield) costs shield 15"), "the log says so")
	# Short of it, the entry cannot be played.
	var s2 := Skirmish.new(1)
	var m2 := _mech("B", Die.single(lance), 40, 100)
	m2.shield = 10
	s2.add_mech(m2)
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	assert_true(s2.shield_short(s2.mechs[0], lance), "10 shield cannot pay 15")
	assert_true(s2.shown_face(s2.mechs[0], lance).short, "the die shows it short")
	assert_true(s2.targets_for_face(s2.mechs[0], lance).is_empty(), "nowhere to land")
	assert_false(s2.can_assign(0, s2.front[0]), "not playable")
	assert_false(s2.can_spend(0), "END TURN may pulse")
	assert_false(s2.assign(0, s2.front[0]), "and a spend is refused")
	assert_eq([m2.shield, s2.front[0].hp], [10, 500], "nothing paid, nothing fired")
	var pv := s2.preview_round(0, s2.front[0])
	assert_eq(int(pv["foes"][s2.front[0]]["hp"]), 500, "the preview counts no spend over it")
	# With the shield to pay it, the same entry is spent.
	m2.shield = 40
	assert_false(s2.shield_short(s2.mechs[0], lance), "a full shield pays")
	assert_true(s2.assign(0, s2.front[0]), "spent")
	assert_eq(m2.shield, 25, "the cost off the shield")
	# Equipment pays it too, and locks the same way.
	var s3 := Skirmish.new(1)
	var vent := Face.vent(20)
	vent.shield_cost = 5
	var m3 := _mech("C", Die.single(vent), 40, 100)
	m3.shield = 4
	s3.add_mech(m3)
	s3.add_foes([_ghoul(500, 10)])
	s3.begin()
	s3.start_round()
	assert_true(s3.machine_targets_for(s3.mechs[0], vent).is_empty(), "a vent short of its shield cost lands nowhere")
	assert_false(s3.can_spend(0), "and cannot be spent")
	m3.shield = 5
	assert_true(s3.assign(0, null), "with the shield to pay, it is spent")
	assert_eq(m3.shield, 0, "to nothing")
	assert_eq(m.hull, 100, "and costs nothing")


func test_empowered_is_a_point_a_stack_and_halves_each_turn() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L)), 40, 100)
	sk.add_mech(m)
	var big := _ghoul(500, 10)
	sk.add_foes([big])
	sk.begin()
	sk.start_round()
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.SKIRMISH, "test", 2, Effects.DECAY_HALF)
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "it halves as its turn ends")
	sk.start_round()
	var before := big.hp
	sk.assign(0, big)
	assert_eq(before - big.hp, 31, "30 plus 1 with the stack left: a damage point a stack")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 0, "and one stack halves to none, rounded down (Ryan: a status decays to zero or is timed)")


func test_a_buffs_empowered_and_a_passives_add_up_and_halve_as_one() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.from_dict({"kind": "attack", "reach": "direct", "power": 20})), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.grant_buff(m, "overcharged", 2, "buff", sk.round)
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.SKIRMISH, "passive:flare", 3, Effects.DECAY_HALF)
	assert_eq(Effects.stacks_of(m, "overcharged"), 5, "the buff's two and a passive's three together")
	assert_eq(m.modifiers.size(), 1, "one grant: a halving status has no rounds to part them, and a stack is a stack whatever granted it (Ryan, 18 October and 8 November)")
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 500 - 25, "20 plus 1 a stack, five stacks")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 2, "five halve to two at the round's end")
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "two to one")
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 0, "one to none: 10, 5, 2, 1, gone")


## A status timed in rounds, synthetic (TIMED): Empowered halves on its own clock and takes no
## rounds since 18 October (Ryan: a status decays to zero or is timed, never both), and the
## primers wait for a weapon since 15 November, so no status of the game's own stacks by rounds
## for more than one; the rounds scope's rule is the general path, and these hold it.
const TIMED := {"id": "test_timed", "name": "Timed", "description": "", "tags": ["buff"],
	"effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 1}]}


func test_a_timed_buff_granted_again_later_keeps_each_grants_own_rounds() -> void:
	# Ryan, 16 October: "Timed stacks should decay based on when they started. Not stack and
	# refresh." A buff for two rounds granted in round 1 runs through round 2; granted again in
	# round 2 it runs through round 3, and never lengthens the first grant's stack.
	var gun := Face.attack(20, L)
	var m := _mech("A", Die.single(gun))
	Effects.grant_def(m, TIMED, 1, "buff", 2)   # round 1, for two rounds
	Effects.end_round(m, 1)
	assert_eq(Effects.stacks_of(m, "test_timed"), 1, "the first grant outlasts round 1")
	Effects.grant_def(m, TIMED, 1, "buff", 3)   # round 2, for two rounds
	assert_eq(Effects.stacks_of(m, "test_timed"), 2, "two stacks during round 2")
	assert_eq(m.modifiers.size(), 2, "each grant a modifier of its own")
	# Two modifiers of one of the game's statuses are one status on the die's row: Empowered
	# held for the skirmish and for the battle is named once.
	var twice := _mech("C", Die.single(gun))
	Effects.stack(twice, Effects.STATUS["overcharged"], Effects.SKIRMISH, "buff", 1, Effects.DECAY_HALF)
	Effects.stack(twice, Effects.STATUS["overcharged"], Effects.BATTLE, "test", 1, Effects.DECAY_NONE)
	assert_eq(twice.modifiers.size(), 2, "a modifier a scope")
	var named := 0
	for t in Effects.explain(twice, gun):
		if str(t).contains("Empowered"):
			named += 1
	assert_eq(named, 1, "the die's row names the status once")
	# A save writes each grant, and a load keeps them apart, each with its own end.
	var back := _mech("B", Die.single(Face.attack(20, L)))
	for mod in m.modifiers:
		back.modifiers.append(SaveGame._modifier_from(JSON.parse_string(JSON.stringify(SaveGame._modifier_dict(mod)))))
	assert_eq(back.modifiers.size(), 2, "still two grants after a save and a load")
	for u in [m, back]:
		Effects.end_round(u, 2)
		assert_eq(Effects.stacks_of(u, "test_timed"), 1, "the first grant's stack goes at the end of round 2")
		Effects.end_round(u, 3)
		assert_eq(Effects.stacks_of(u, "test_timed"), 0, "the second's at the end of round 3")


func test_grants_of_a_timed_buff_ending_the_same_round_stack_as_one() -> void:
	# Two of one buff spent in one round, or a brace beside a buff of Armoured for the round: the
	# same timed status ending the same round stacks onto one modifier and goes as one.
	var m := _mech("A", Die.single(Face.attack(20, L)))
	Effects.grant_def(m, TIMED, 1, "buff:one", 2)
	Effects.grant_def(m, TIMED, 2, "buff:other", 2)
	assert_eq(m.modifiers.size(), 1, "one modifier")
	assert_eq(Effects.stacks_of(m, "test_timed"), 3, "with the stacks summed")
	Effects.end_round(m, 1)
	assert_eq(Effects.stacks_of(m, "test_timed"), 3, "both outlast round 1")
	Effects.end_round(m, 2)
	assert_eq(Effects.stacks_of(m, "test_timed"), 0, "and go together at the end of round 2")
	assert_true(m.modifiers.is_empty(), "nothing left behind")
	Effects.grant_buff(m, "braced", 2, "brace:plow", 3)
	Effects.grant_buff(m, "braced", 1, "buff:jack", 3)
	assert_eq(m.modifiers.size(), 1, "a brace and a buff of Armoured for the same round: one modifier too")
	assert_eq(Effects.stacks_of(m, "braced"), 3, "three stacks")


func test_a_status_for_the_skirmish_still_stacks_onto_one_modifier() -> void:
	# The timed rule is the rounds scope's alone: a status for the skirmish (or the battle)
	# stacks onto the one there whenever it is granted, and decays as one.
	var m := _mech("A", Die.single(Face.attack(20, L)))
	var mark := {"id": "test_mark", "name": "Mark", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 5}]}
	Effects.stack(m, mark, Effects.SKIRMISH, "test", 1, Effects.DECAY_TICK)
	Effects.end_round(m, 1)
	Effects.stack(m, mark, Effects.SKIRMISH, "test", 2, Effects.DECAY_TICK)
	assert_eq(m.modifiers.size(), 1, "one modifier for the skirmish")
	assert_eq(Effects.stacks_of(m, "test_mark"), 3, "three stacks")
	Effects.end_round(m, 2)
	assert_eq(Effects.stacks_of(m, "test_mark"), 3, "a round's end leaves it be")
	Effects.tick(m)
	assert_eq(Effects.stacks_of(m, "test_mark"), 2, "a tick takes one stack off the one modifier")
	Effects.stack(m, mark, Effects.BATTLE, "test", 1, Effects.DECAY_NONE)
	Effects.stack(m, mark, Effects.BATTLE, "test", 1, Effects.DECAY_NONE)
	assert_eq(m.modifiers.size(), 2, "the battle's stack onto one of their own")
	assert_eq(Effects.stacks_of(m, "test_mark"), 4, "and every scope counts together")


func test_a_two_round_buff_spent_again_runs_to_its_later_end() -> void:
	# The rounds a buff entry says, through the skirmish: a Ward for two rounds spent in round 1
	# stands through round 2; spent again in round 2 it stands through round 3, one Ward and
	# never two (it renews). No status of the game's own stacks by rounds for more than one, so
	# each grant keeping its own end is held on the synthetic one, above.
	var sk := Skirmish.new(1)
	var veil := Face.buff("ward", 1, 2)
	var m := _mech("A", Die.single(veil), 40, 300)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, null), "spent on itself in round 1")
	sk.end_round()
	assert_true(Effects.has(m, "ward"), "it outlasts round 1")
	sk.start_round()
	assert_true(sk.assign(0, null), "and again in round 2")
	assert_eq(Effects.stacks_of(m, "ward"), 1, "one Ward, renewed")
	sk.end_round()
	assert_true(Effects.has(m, "ward"), "the second spend carries it past round 2's end")
	sk.start_round()
	sk.end_round()
	assert_false(Effects.has(m, "ward"), "and it goes at the end of round 3")


func test_removing_a_status_clears_every_grant_of_it() -> void:
	var m := _mech("A", Die.single(Face.attack(20, L)))
	Effects.grant_def(m, TIMED, 1, "buff", 2)
	Effects.grant_def(m, TIMED, 2, "buff", 3)
	assert_eq(m.modifiers.size(), 2, "two grants")
	assert_true(Effects.remove(m, "test_timed"), "the status went")
	assert_false(Effects.has(m, "test_timed"), "both grants with it")
	assert_true(m.modifiers.is_empty(), "nothing left behind")
	assert_false(Effects.remove(m, "test_timed"), "and nothing more to remove")
	# A spend takes from the grant ending soonest, whichever came first, so the later one
	# keeps its stacks.
	Effects.grant_def(m, TIMED, 2, "buff", 3)
	Effects.grant_def(m, TIMED, 1, "buff", 2)
	assert_eq(Effects.spend_stacks(m, "test_timed", 1), 1, "one stack spent")
	Effects.end_round(m, 2)
	assert_eq(Effects.stacks_of(m, "test_timed"), 2, "from the grant ending soonest: the later one keeps both its stacks")
	# A status a use spends is held for the fight, whatever round its grant names (a primer, Spun Up).
	var spent := {"id": "test_spent", "name": "Spent", "description": "", "spent_by": "weapon", "tags": ["buff"], "effects": []}
	Effects.grant_def(m, spent, 2, "buff", 1)
	Effects.grant_def(m, spent, 1, "buff", 2)
	Effects.end_round(m, 3)
	assert_eq(Effects.stacks_of(m, "test_spent"), 3, "it waits on its use, the grants one count")


## A stun that lands on a foe after it has acted this turn holds for its next action (a Mine's
## blast in the enemy's turn is the way one lands there: a foe its tick fells blows its Mine on
## the foe beside it, which has already struck).
func test_a_status_gained_after_a_foe_acted_suppresses_its_next_action() -> void:
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 200)
	sk.add_mech(m)
	var g := _ghoul(500, 10)     # the heavier blow stands left and strikes first
	var fuse := _ghoul(2, 1)
	sk.add_foes([g, fuse])
	sk.begin()
	sk.start_round()
	g.target = sk.mechs[0]
	fuse.target = sk.mechs[0]
	Effects.stack(fuse, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	sk._add_mine(fuse, 1, {"stacks": {}, "keywords": ["suppress"]})
	sk.end_round()
	assert_eq(m.hull, 189, "the ghoul's blow landed and the fuse's own, its tick felling it as its turn ended")
	assert_false(fuse.alive(), "its Ablating felled it, its action done")
	assert_eq(g.hp, 499, "its Mine blew on the foe beside it")
	sk.start_round()
	assert_true(g.is_suppressed(), "the blast's suppress holds for the round after, since the ghoul had already struck")
	sk.end_round()
	assert_eq(m.hull, 189, "and it skipped that blow")
	assert_false(g.is_suppressed(), "the Suppress spent with the turn it cost")


func test_a_lure_turns_every_foe_the_entry_reaches_on_the_spender_for_the_round() -> void:
	var sk := Skirmish.new(2, 3)
	var klaxon := Face.attack(0, I, K.LURE)
	klaxon.add_keyword(K.CLEAVE)
	var tank := _mech("Tank", Die.single(klaxon), 40, 200)
	var glass := _mech("Glass", Die.single(Face.attack(10, L)), 0, 50)
	sk.add_mech(tank)
	sk.add_mech(glass)
	sk.add_foes([_ghoul(500, 10), _ghoul(500, 10), _ghoul(500, 10), _archer(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(klaxon.describe(), "indirect lure spread", "the keyword reads on the entry")
	for f in sk.field_foes():
		f.target = sk.mechs[1]   # every foe on the glass, whatever the dice said
	# Spent on the middle ghoul: the spread reaches its neighbours, so the whole front turns;
	# the archer behind is out of the spread and keeps its aim.
	assert_true(sk.assign(0, sk.front[1]), "the tank sounds its klaxon at the middle ghoul")
	for col in range(3):
		assert_eq(sk.front[col].target, sk.mechs[0], "the front rank turned on the tank")
	var archer: Foe = sk.back[0] if sk.back[0] != null else (sk.back[1] if sk.back[1] != null else sk.back[2])
	assert_eq(archer.target, sk.mechs[1], "the archer kept its aim")
	assert_eq(sk.incoming_for(sk.mechs[0]), 30, "the forecast follows the turn")
	assert_true("\n".join(sk.log).contains("Tank lures revenant, revenant, revenant"), "the log says so: %s" % sk.log[sk.log.size() - 1])
	assert_false(Effects.describe(tank).any(func(d): return str(d[5]) == "lure"), "no status on the machine: the arrows are the record")
	sk.end_round()
	assert_eq(tank.shield, 10, "the tank took the front rank's three blows on its shield")
	assert_eq(glass.hull, 40, "the archer's blow reached the glass")
	# A lure on a weapon: the foe it hits turns, if it lives.
	var s2 := Skirmish.new(1, 2)
	var hook := Face.attack(10, L, K.LURE)
	var t2 := _mech("Tank", Die.single(hook), 40, 200)
	var g2 := _mech("Glass", Die.single(Face.attack(10, L)), 0, 50)
	s2.add_mech(t2)
	s2.add_mech(g2)
	s2.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	for f in s2.field_foes():
		f.target = s2.mechs[1]
	assert_true(s2.assign(0, s2.front[0]), "hooks the first ghoul")
	assert_eq(s2.front[0].hp, 490, "the blow lands")
	assert_eq(s2.front[0].target, s2.mechs[0], "and the ghoul turns")
	assert_eq(s2.front[1].target, s2.mechs[1], "the other does not")
	s2.end_round()
	s2.start_round()
	assert_true(s2.front[0].target != null, "the next round it aims as it likes")
	# A lure lands on a foe whose move has no target: the blow still lands, the log says so.
	var s3 := Skirmish.new(1, 1)
	s3.add_mech(_mech("Tank", Die.single(Face.attack(10, L, K.LURE)), 40, 200))
	s3.add_mech(_mech("Glass", Die.single(Face.attack(10, L)), 0, 50))
	var r := _ghoul(500, 10)
	r.actions = [_special("buff", "rally", {"value": 10})]
	r.action = r.actions[0]
	s3.add_foes([r])
	s3.begin()
	s3.start_round()
	assert_true(s3.assign(0, r), "lures the rallying foe")
	assert_eq(r.hp, 490, "the damage lands anyway")
	assert_true("\n".join(s3.log).contains("has nothing to turn"), "and the log says the lure moved nothing")


func test_a_disrupt_makes_the_foe_do_its_other_move_and_the_new_move_aims_for_itself() -> void:
	var sk := Skirmish.new(1, 1)
	var jam := Face.attack(10, L, K.DISRUPT)
	var cold := _mech("Cold", Die.single(jam), 40, 200)
	var hot := _mech("Hot", Die.single(Face.attack(10, L)), 0, 50)
	sk.add_mech(cold)
	sk.add_mech(hot)
	var h := _ghoul(500, 20)
	h.actions = [Foe.basic_action(), _special("debuff", "ablate", {"value": 2, "aim": "hottest"})]
	h.actions[0]["weight"] = 1000
	h.action = h.actions[0]
	sk.add_foes([h])
	sk.begin()
	sk.mechs[1].heat = 30
	sk.start_round()
	assert_true(h.attacks(), "the blow, at that weight")
	h.target = sk.mechs[0]
	assert_true(sk.assign(0, h), "disrupted")
	assert_false(h.attacks(), "it does its other move instead")
	assert_eq(str(h.action.get("effect", "")), "ablate", "the stoke")
	assert_eq(h.target, sk.mechs[0], "and keeps its pick, whatever the new move's word (Ryan, 26 October: a new one only for an invalid target)")
	assert_eq(h.last_special, "ablate", "and counts as the special announced")
	assert_true("\n".join(sk.log).contains("is disrupted: Ablate instead of Attack"), "the log names both: %s" % sk.log[sk.log.size() - 1])
	sk.end_round()
	assert_eq(Effects.stacks_of(sk.mechs[0].unit, "ablating_mech"), 2, "the stoke landed on its pick: two stacks of Ablating")
	assert_eq(cold.shield, 40, "and no blow did")
	# A pick the new move cannot keep (its machine Phased) is drawn again.
	var sp := Skirmish.new(1, 1)
	sp.add_mech(_mech("A", Die.single(Face.attack(10, L, K.DISRUPT)), 40, 200))
	var phm := _mech("B", Die.single(Face.blank()), 0, 50)
	sp.add_mech(phm)
	var hp3 := _ghoul(500, 20)
	hp3.actions = [Foe.basic_action(), _special("debuff", "ablate", {"value": 2})]
	hp3.actions[0]["weight"] = 1000
	hp3.action = hp3.actions[0]
	sp.add_foes([hp3])
	sp.begin()
	sp.start_round()
	hp3.target = sp.mechs[1]
	Effects.grant_for_rounds(phm, Effects.STATUS["phased"], "test", sp.round)
	assert_true(sp.assign(0, hp3), "disrupted")
	assert_eq(hp3.target, sp.mechs[0], "its machine Phased, it picks the one it may")
	# A move aimed at no one machine (a brace) holds no pick, so turned into a blow it takes the
	# next machine in line (Ryan, 26 October: a buff to an attack "should still retarget").
	var sb := Skirmish.new(1, 1)
	sb.add_mech(_mech("A", Die.single(Face.attack(10, L, K.DISRUPT)), 40, 200))
	sb.add_mech(_mech("B", Die.single(Face.blank()), 0, 50))
	var hb := _ghoul(500, 20)
	hb.actions = [Foe.basic_action(), _special("defend", "brace", {"value": 2})]
	hb.actions[1]["weight"] = 1000
	hb.action = hb.actions[1]
	sb.add_foes([hb])
	sb.begin()
	sb.start_round()
	assert_true(hb.acts_on_nobody(), "the brace, at that weight")
	assert_true(hb.target == null, "which holds no pick")
	assert_true(sb.assign(0, hb), "disrupted")
	assert_true(hb.attacks(), "into its blow")
	assert_eq(hb.target, sb.mechs[0], "which takes the next machine in line")
	# Nothing else open: a foe with one move, or whose other move's condition fails, is not moved.
	var s2 := Skirmish.new(1, 1)
	s2.add_mech(_mech("A", Die.single(Face.attack(10, L, K.DISRUPT)), 40, 200))
	var lone := _ghoul(500, 20)
	lone.actions = [Foe.basic_action(), _special("defend", "recover", {"value": 20, "when": "below_half"})]
	lone.action = lone.actions[0]
	s2.add_foes([lone])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, lone), "disrupted at full health")
	assert_true(lone.attacks(), "the regrow is not open, so the blow stands")
	assert_true("\n".join(s2.log).contains("has nothing else to do"), "the log says so")
	# Three moves: the next in the pattern, wrapping.
	var s3 := Skirmish.new(1, 1)
	s3.add_mech(_mech("A", Die.single(Face.attack(10, L, K.DISRUPT)), 40, 200))
	var boss := _ghoul(500, 20)
	boss.actions = [Foe.basic_action(), _special("defend", "recover", {"value": 20}), _special("buff", "rally", {"value": 10})]
	boss.action = boss.actions[2]
	boss.last_special = "rally"
	s3.add_foes([boss])
	s3.begin()
	s3.start_round()
	boss.action = boss.actions[2]
	assert_true(s3.assign(0, boss), "disrupted on its rally")
	assert_true(boss.attacks(), "the next in its list after the rally is the blow, wrapping")


func test_spillover_carries_the_damage_past_a_kill_into_the_foe_behind() -> void:
	var sk := Skirmish.new(1, 2)
	var ram := _spiller(Face.attack(50, L))
	var m := _mech("A", Die.single(ram), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 10), _ghoul(500, 10), _archer(500, 10), _archer(10, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(ram.describe(), "50 " + Templates.say("rule.spills"), "the rule reads on the entry, in words: no keyword names it")
	# Find the column with the weak ghoul in front and see who stands behind it.
	var col := 0 if sk.front[0].hp == 20 else 1
	var behind: Foe = sk.back[col]
	var behind_before := behind.hp
	assert_true(sk.assign(0, sk.front[col]), "hit the weak ghoul")
	assert_eq(sk.front[col], null, "it fell")
	assert_eq(behind_before - behind.hp, 30, "the 30 past its 20 carried into the archer behind")
	assert_true("\n".join(sk.log).contains("A spills over: 30 into archer"), "the log says so")
	# No spill into an empty slot, and none past a foe that survives.
	sk.end_round()
	sk.start_round()
	var big_col := 1 - col
	var big: Foe = sk.front[big_col]
	var other_back: Foe = sk.back[big_col]
	var other_before := other_back.hp if other_back != null else -1
	sk.assign(0, big)
	assert_eq(big.hp, 450, "the big one stands")
	if other_back != null:
		assert_eq(other_back.hp, other_before, "and nothing spilled")


## Ryan, 15 October: "All its damage or subsequent strikes spill over." A strike that falls on
## a front-rank foe an earlier strike of the spend killed goes on whole into the foe behind it,
## through everything the killing strike's excess goes through.
func test_spillover_carries_every_later_strike_into_the_foe_behind() -> void:
	# Three strikes of 10, 15 each with the machine's own +5, on a 9-hp ghoul in armour 3 with
	# an archer in armour 2 behind it.
	var sk := Skirmish.new(1, 1)
	var burst := _spiller(Face.attack(10, L))
	burst.strikes = 3
	var m := _mech("A", Die.single(burst), 40, 100)
	m.grant_passive({"id": "edge", "name": "Edge", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 5}]})
	sk.add_mech(m)
	var weak := _ghoul(9, 10)
	weak.armour = 3
	var archer := _archer(100, 10)
	archer.armour = 2
	sk.add_foes([weak, archer])
	sk.begin()
	sk.start_round()
	assert_eq(sk.back[0], archer, "the archer stands behind the ghoul")
	assert_true(sk.assign(0, weak), "the burst at the ghoul")
	# The first strike lands 12 past the ghoul's armour, 3 past its kill: 1 past the archer's
	# armour. The next two go on whole, 15 each, the fallen ghoul's armour never seeing them.
	assert_eq(archer.hp, 100 - (15 - 3 - 9 - 2) - 2 * (15 - 2), "the excess past the kill and both later strikes, each less the archer's armour")
	assert_eq(weak.hp, 9 - (15 - 3), "the fallen ghoul takes nothing past its kill")
	var text := "\n".join(sk.log)
	assert_eq(text.count("A spills over: "), 3, "a spill for every strike past the kill")
	assert_true(text.contains("A spills over: 1 into archer"), "the killing strike's excess")
	assert_eq(text.count("A spills over: 13 into archer"), 2, "and each later strike, less the archer's armour")
	assert_eq(sk.last_roll["final"], (15 - 3) + 2 * 15, "the blow's record counts the later strikes whole, as it counts the excess")
	# The foe behind reads its own statuses but a Shock: a spill is aimed at nobody, so its charge
	# neither doubles a strike nor is spent (29 October). An exact kill has nothing past it.
	var s2 := Skirmish.new(1, 1)
	var b2 := _spiller(Face.attack(10, L))
	b2.strikes = 3
	s2.add_mech(_mech("A", Die.single(b2), 40, 100))
	var exact := _ghoul(10, 10)
	var wired := _archer(100, 10)
	s2.add_foes([exact, wired])
	s2.begin()
	s2.start_round()
	Effects.stack(wired, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_true(s2.assign(0, exact), "the burst at a ghoul its first strike kills exactly")
	assert_eq(wired.hp, 100 - 2 * 10, "nothing past the exact kill; the later strikes land plain")
	assert_true(Effects.has(wired, "shocked"), "and the shock stands")
	# Per foe: a spread neighbour an earlier strike killed spills its later strikes behind it,
	# while the target that stands spills nothing.
	var s3 := Skirmish.new(1, 2)
	var sweep := _spiller(Face.attack(10, L, [K.CLEAVE]))
	sweep.strikes = 3
	sweep.cleave = 5
	s3.add_mech(_mech("A", Die.single(sweep), 40, 100))
	s3.add_foes([_ghoul(500, 30), _ghoul(5, 10), _archer(100, 20), _archer(100, 10)])
	s3.begin()
	s3.start_round()
	var n_col := 0 if s3.front[0].hp == 5 else 1
	var big: Foe = s3.front[1 - n_col]
	var past: Foe = s3.back[n_col]
	var safe: Foe = s3.back[1 - n_col]
	assert_true(s3.assign(0, big), "the sweep at the big ghoul, its weak neighbour in reach")
	assert_eq(big.hp, 500 - 3 * 10, "the big one takes all three")
	assert_eq(past.hp, 100 - 2 * 5, "behind the neighbour, which the Spread 5 kills exactly: nothing past the kill, then the two later strikes' Spread 5 each (area by shape, numbered)")
	assert_eq(safe.hp, 100, "behind the big one, which stands: nothing")


## The foe behind falls partway through the spend: the strikes left are lost, since nothing
## stands behind the back rank, and nothing else is hit.
## A later strike that spills past a corpse still lands its riders on it, as every hit's do (the
## audit's eighth bug, 8 November): a Wild Boar's ×2 Brittle 1 that kills with its first strike
## leaves Brittle 2 on the fallen foe, its second strike's number gone on behind it.
func test_a_spilling_strikes_riders_land_on_the_corpse() -> void:
	var plow := _spiller(Face.attack(10, L, [K.BRITTLE]))
	plow.brittle = 1
	plow.strikes = 2
	var sk := Skirmish.new(2, 1)
	sk.add_mech(_mech("Boar", Die.single(plow), 40, 100))
	var front := _ghoul(5, 10)
	var behind := _archer(100, 10)
	sk.add_foes([front, behind])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, front), "the plow")
	assert_eq(Effects.stacks_of(front, "brittled"), 2, "a stack a strike on the corpse, the spilling one's included")
	assert_eq(behind.hp, 100 - 5 - 10, "the first strike's excess and the second's whole number went on behind")


func test_spillover_strikes_are_lost_once_the_foe_behind_falls() -> void:
	var sk := Skirmish.new(1, 2)
	var burst := _spiller(Face.attack(10, L))
	burst.strikes = 4
	sk.add_mech(_mech("A", Die.single(burst), 40, 100))
	sk.add_foes([_ghoul(5, 20), _ghoul(100, 10), _archer(12, 20), _archer(100, 10)])
	sk.begin()
	sk.start_round()
	var col := 0 if sk.front[0].hp == 5 else 1
	var weak: Foe = sk.front[col]
	var behind: Foe = sk.back[col]
	assert_eq(behind.hp, 12, "the 12-hp archer stands behind the 5-hp ghoul")
	assert_true(sk.assign(0, weak), "four strikes of 10 at the ghoul")
	# The first kills the ghoul and spills 5; the second spills 10 and kills the archer.
	assert_eq(behind.hp, 12 - 5 - 10, "the third and fourth strikes are lost, not landed on the fallen archer")
	assert_eq(weak.hp, 5 - 10, "nor on the fallen ghoul")
	assert_eq("\n".join(sk.log).count("A spills over: "), 2, "two spills, then nothing")
	assert_eq(sk.field_foes().size(), 2, "the other column stands")
	for f in sk.field_foes():
		assert_eq(f.hp, 100, "untouched: %s" % f.display_name)
	# The foe a spill kills is the spend's kill, as the foe its blow kills is.
	var s2 := Skirmish.new(1, 2)
	var talons := _spiller(Face.attack(10, L))
	talons.strikes = 4
	var m := _mech("A", Die.single(talons), 40, 100)
	m.grant_passive(KILLER)
	s2.add_mech(m)
	s2.add_foes([_ghoul(5, 20), _ghoul(100, 10), _archer(12, 20), _archer(100, 10)])
	s2.begin()
	s2.start_round()
	var c2 := 0 if s2.front[0].hp == 5 else 1
	var fed: Foe = s2.back[c2]
	assert_true(s2.assign(0, s2.front[c2]), "the talons at the ghoul")
	assert_false(fed.alive(), "the archer falls to the spill")
	assert_eq(s2.team_kills, 2, "the ghoul and the archer both count as kills")
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "and its kill trigger fires once for the attack, however many fell")
	assert_eq("\n".join(s2.log).count("A spills over: "), 2, "and nothing spills past the fallen archer")


## What the later strikes' spill leaves as it was: one strike spills only its excess, a burst
## that already reaches the foe behind (Penetrate) lands there once a strike with no spill on
## top, and a burst without Spillover loses its later strikes on the fallen foe.
func test_spillover_holds_for_one_strike_and_never_doubles_a_penetrating_blow() -> void:
	var sk := Skirmish.new(1, 1)
	sk.add_mech(_mech("A", Die.single(_spiller(Face.attack(30, L))), 40, 100))
	var g := _ghoul(10, 10)
	g.armour = 2
	var a := _archer(100, 10)
	a.armour = 5
	sk.add_foes([g, a])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, g), "one strike of 30")
	assert_eq(a.hp, 100 - (30 - 2 - 10 - 5), "the 18 past the ghoul's armour and kill, less the archer's 5")
	assert_eq("\n".join(sk.log).count("A spills over: "), 1, "one spill")
	# A penetrating burst already reaches the archer: it takes each strike there, once.
	var s2 := Skirmish.new(1, 1)
	var lance := _spiller(Face.attack(10, L, [K.PENETRATE]))
	lance.strikes = 3
	lance.penetrate = 5
	s2.add_mech(_mech("A", Die.single(lance), 40, 100))
	var g2 := _ghoul(5, 10)
	var a2 := _archer(100, 10)
	a2.armour = 2
	s2.add_foes([g2, a2])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, g2), "three penetrating strikes of 10")
	assert_false(g2.alive(), "the ghoul falls to the first")
	assert_eq(a2.hp, 100 - 3 * (5 - 2), "the archer, reached past the target, takes the Penetrate 5 of every strike, less its armour, and no spill on top")
	assert_false("\n".join(s2.log).contains("spills over"), "nothing spills into a foe the blow already reaches")
	# A burst without Spillover: the strikes after the kill land on the fallen ghoul and are lost.
	var s3 := Skirmish.new(1, 1)
	var plain := Face.attack(10, L)
	plain.strikes = 3
	s3.add_mech(_mech("A", Die.single(plain), 40, 100))
	var g3 := _ghoul(5, 10)
	var a3 := _archer(100, 10)
	s3.add_foes([g3, a3])
	s3.begin()
	s3.start_round()
	assert_true(s3.assign(0, g3), "three plain strikes of 10")
	assert_eq(a3.hp, 100, "nothing reaches the archer")
	assert_eq(g3.hp, 5 - 3 * 10, "every strike lands on the ghoul, the two after its kill too")
	assert_eq(s3.last_roll["final"], 3 * 10, "and the blow's record counts them")


func test_a_passive_may_grant_a_keyword_and_the_entry_wears_it() -> void:
	var drive := {"id": "drive", "name": "Juggernaut Drive", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "shock"}]}
	var sk := Skirmish.new(1, 1)
	var gun := Face.attack(50, L)
	var m := _mech("A", Die.single(gun), 40, 100)
	m.grant_passive(drive)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10), _archer(500, 10)])
	sk.begin()
	sk.start_round()
	assert_false(gun.has(K.SHOCK), "the die's own entry is untouched")
	assert_true(Effects.effective_face(m, gun).has(K.SHOCK), "but the machine spends it with the keyword")
	assert_true(sk.shown_face(sk.mechs[0], gun).has(K.SHOCK), "and sees it on the die")
	assert_eq(Effects.explain(m, gun), ["gains shock (Juggernaut Drive)"], "the die row says where it came from")
	sk.assign(0, sk.front[0])
	assert_true(Effects.has(sk.front[0], "shocked"), "the plain gun left its foe Shocked")
	# A support keyword is never granted to an attack, nor an attack keyword to a shield.
	var plate := Face.shield(10)
	var odd := {"id": "odd", "name": "Odd", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "cleanse"}]}
	m.grant_passive(odd, "odd")
	assert_false(Effects.effective_face(m, gun).has(K.CLEANSE), "cleanse stays off the gun")
	assert_true(Effects.effective_face(m, plate).has(K.CLEANSE), "and lands on the shield")
	assert_false(Effects.effective_face(m, plate).has(K.SHOCK), "shock stays off the shield")


## A rule a passive writes on its machine's weapons (the Overrun Gearing's spill, the Boar's first;
## a keyword granted written out from 22 October, its own effect since 15 November, on Ryan's
## mark: "As a module only effect, this does not need to be a keyword. It can be unique text"):
## the effective entry spills and carries no keyword for it, the die draws the star, and the hold
## reads the passive's own line; a keyword a passive grants keeps its chip and its effect text.
func test_a_rule_a_passive_writes_is_the_star_and_the_hold_reads_the_passive() -> void:
	var drive := {"id": "drive", "name": "Juggernaut Drive", "description": "Damage past a kill spills into the rank behind, from any weapon.", "effects": [
		{"trigger": "static", "effect": "spillover", "value": 1}]}
	var sk := Skirmish.new(1, 1)
	var gun := Face.attack(50, L)
	var m := _mech("A", Die.single(gun), 40, 100)
	m.grant_passive(drive)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 10), _archer(500, 10)])
	sk.begin()
	sk.start_round()
	var shown := sk.shown_face(sk.mechs[0], gun)
	assert_true(shown.spills, "the engine spends it as an entry that spills")
	assert_true(shown.keywords.is_empty(), "with no keyword for it: the die draws no chip")
	assert_true(shown.has_unique_rule(), "but the star")
	assert_false(shown.describe().contains("spillover"), "and its line names no keyword: %s" % shown.describe())
	assert_false(gun.spills or gun.has_unique_rule(), "which the bare entry does not wear")
	assert_eq(Effects.explain(m, gun), ["Damage past a kill spills into the rank behind, from any weapon. (Juggernaut Drive)"], "the hold reads the passive's line")
	assert_eq(Effects.written_rules(m, gun), ["Damage past a kill spills into the rank behind, from any weapon."] as Array[String], "which is the star's text")
	assert_false(Effects.effective_face(m, Face.shield(10)).spills, "and a shield is no entry it is written on")
	assert_true(Effects.written_rules(m, Face.shield(10)).is_empty(), "nor does the hold read it there")
	sk.assign(0, sk.front[0])
	assert_eq(sk.back[0].hp, 470, "and the spill lands as before")
	var plain := {"id": "plain", "name": "Plain", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "penetrate"}]}
	var u := _mech("B", Die.single(Face.attack(10, L)), 40, 100)
	u.grant_passive(plain)
	var f := Effects.effective_face(u, u.die.faces[0])
	assert_true(f.has(K.PENETRATE) and not f.spills, "a keyword a passive grants is a keyword chip")


func test_a_vent_on_fire_attack_fires_the_heat_into_the_blow_and_empties_the_gauge() -> void:
	var sk := Skirmish.new(1)
	var cannon := Face.from_dict({"kind": "attack", "reach": "direct", "power": 20, "heat": 0, "vents_all": true, "power_per_heat": 10})
	var m := _mech("A", Die.single(cannon), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].heat = 47
	assert_eq(cannon.describe(), "20 vents all, +10 per 10 heat", "the entry says what it does")
	assert_eq(cannon.to_dict()["power_per_heat"], 10, "and round-trips")
	assert_eq(sk.heat_bonus(sk.mechs[0], cannon), 40, "four tens of heat: +40")
	assert_eq(int(sk.preview_round(0, sk.front[0])["mechs"][0]["heat_after"]), 0, "the round preview with the die in hand sees the gauge emptied")
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 440, "20 plus the 40 fired")
	assert_eq(sk.mechs[0].heat, 0, "the airframe is cold")
	assert_true("\n".join(sk.log).contains("A fires its heat: -47, +40 to the blow"), "the log says so")
	# Cold, it is a plain 20; its own heat cost still lands.
	var hot := Face.from_dict({"kind": "attack", "reach": "direct", "power": 20, "heat": 15, "vents_all": true, "power_per_heat": 10})
	var s2 := Skirmish.new(2)
	s2.add_mech(_mech("B", Die.single(hot), 40, 100))
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	s2.mechs[0].heat = 5
	s2.assign(0, s2.front[0])
	assert_eq(s2.front[0].hp, 480, "under ten heat adds nothing")
	assert_eq(s2.mechs[0].heat, 15, "emptied, then the shot's own heat")


## The converter's step is a field (the stock pass, 22 October), at today's ten until the content
## landing: the vent-on-fire face's per_heat (the ally-heat shield's went with the Slipstream
## Projector, 19 November).
func test_a_heat_converter_reads_its_step_from_its_field() -> void:
	var cannon := Face.attack(10, L)
	cannon.vents_all = true
	cannon.power_per_heat = 1
	cannon.per_heat = 2
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(cannon), 40, 100))
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].heat = 9
	assert_eq(Skirmish.heat_bonus(sk.mechs[0], cannon), 4, "+1 for every 2 heat: four steps in nine")
	assert_eq(Face.from_dict(cannon.to_dict()).per_heat, 2, "the step survives the save")


## The ally condition reads allies.
func test_the_ally_condition_reads_allies() -> void:
	var a := _mech("A", Die.of([Face.attack(10, L), Face.attack(15, L)]), 40, 100)
	var sk := Skirmish.new(1)
	var b := _mech("B", Die.single(Face.blank()), 40, 10)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 30)])
	sk.begin()
	sk.start_round()
	assert_eq(a.allies, 1, "the skirmish tells the unit who stands with it")
	b.hull = 0
	sk._refresh_allies()
	assert_eq(a.allies, 0, "alone")


func test_a_free_reroll_of_one_die_spares_the_teams() -> void:
	var director := {"id": "director", "name": "Battery Director", "description": "", "effects": [
		{"trigger": "static", "effect": "free_reroll", "value": 1}]}
	var sk := Skirmish.new(1)
	var a := _mech("A", Die.of([Face.attack(10, L), Face.attack(20, L), Face.attack(30, L)]), 40, 100)
	a.grant_passive(director)
	var b := _mech("B", Die.of([Face.attack(10, L), Face.attack(20, L)]), 40, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.mechs[0].free_rerolls, 1, "one of its own this round")
	assert_eq(sk.mechs[1].free_rerolls, 0, "none for the other")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "the team's are untouched")
	var before := sk.mechs[0].face_index
	assert_true(sk.reroll([0]), "A alone rerolls")
	assert_true(sk.mechs[0].face_index != before, "and the die moved")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "for free")
	assert_eq(sk.mechs[0].free_rerolls, 0, "once a round")
	assert_true(sk.reroll([0]), "again, from the team's")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND - 1, "which paid this time")
	sk.rerolls_left = 0
	assert_false(sk.can_reroll(), "nothing left")
	sk.mechs[0].free_rerolls = 1
	assert_true(sk.can_reroll(), "a free one is a reroll open")
	assert_false(sk.reroll([0, 1]), "but not for two dice at once")
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].free_rerolls, 1, "back each round")


## Hull damage is every hull hit (Ryan, 12 October, of the Nemesis's rage, which fed on it until
## 23 November): a blow, a bite of its own, an overheat each fire what reads it. A synthetic
## counter banks a stack a hit: the hopper's loads, inert with no plate to read them, kept for the
## skirmish, and nothing in a blow.
func test_hull_damage_fires_on_every_hull_hit_for_the_skirmish() -> void:
	var core := {"id": "count_core", "name": "Count Core", "description": "", "effects": [
		{"trigger": "on_hull_damage", "effect": "stack_status", "value": "hopper"}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30)), 0, 200)
	m.grant_passive(core)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	g.actions[0]["strikes"] = 2
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 470, "a plain 30")
	sk.end_round()
	assert_eq(m.hull, 180, "two blows reached hull")
	assert_eq(Effects.stacks_of(m, "hopper"), 2, "a stack each")
	sk.start_round()
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(m, "hopper"), 4, "never fading: two more blows, four")
	assert_eq(int(Effects.attack(m, Face.attack(30), 30, 0, g)["damage"]), 30, "the count alone adds nothing to a blow")
	# An overheat is hull damage too.
	var before := Effects.stacks_of(m, "hopper")
	sk.mechs[0].heat = sk.mechs[0].heat_max + 20
	sk._burn_overheated()
	assert_eq(Effects.stacks_of(m, "hopper"), before + 1, "the overheat fed it")
	# A volatile bite is the machine's own weapon reaching hull: it counts.
	var s2 := Skirmish.new(2)
	var biter := Face.attack(30, L)
	biter.volatile = 1
	var n := _mech("N", Die.single(biter), 40, 200)
	n.grant_passive(core)
	s2.add_mech(n)
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	s2.assign(0, s2.front[0])
	assert_eq(Effects.stacks_of(n, "hopper"), 1, "the bite fed it")


## A cap on a banked stack (Ryan, 22 October, of the Nemesis's rage, a store until 23 November; the
## Wild Boar's Juggernaut at one today): a passive's stack_status that names a cap banks no stack
## past it, the rule text says so, and the cap reads back; a cap below one is refused by the
## validator. On a synthetic stack of Empowered.
func test_a_capped_store_banks_no_more_than_its_cap() -> void:
	var core := {"id": "rage_core", "name": "Rage Core", "description": "", "effects": [
		{"trigger": "on_hull_damage", "effect": "stack_status", "value": "overcharged", "cap": 3}]}
	var m := _mech("A", Die.single(Face.attack(30)), 0, 200)
	m.grant_passive(core)
	for k in range(5):
		Effects.fire(m, "on_hull_damage", 10)
	assert_eq(Effects.stacks_of(m, "overcharged"), 3, "five hull hits, three stacks: the cap")
	assert_eq(Effects.store_cap(m, "overcharged"), 3, "the cap reads back")
	assert_eq(Effects.store_cap(m, "muster"), 0, "an uncapped store has none")
	assert_true(Effects.effect_text(core["effects"][0]).contains("up to 3"), "the rule text names the cap")
	Effects.spend_stacks(m, "overcharged", 1)
	Effects.fire(m, "on_hull_damage", 10)
	assert_eq(Effects.stacks_of(m, "overcharged"), 3, "a spent one banks again, up to the cap")
	var db := ContentDB.load_default()
	var errs: Array[String] = []
	db._validate_passive("probe", {"id": "p", "name": "P", "description": "", "effects": [{"trigger": "on_hull_damage", "effect": "stack_status", "value": "overcharged", "cap": 0}]}, errs)
	assert_true(errs.any(func(e) -> bool: return e.contains("cap")), "a cap below one is refused")


## Instant (Ryan, 12 November: "reroll after use, can land on itself"): spent, the die rolls again
## as the round opens, itself included, and the machine acts again; nothing switches off, so the
## same entry may show again and be spent again. The fight's last blow rolls nothing.
func test_an_instant_entry_rolls_again_itself_included_and_nothing_switches_off() -> void:
	var jab := Face.attack(10, L, [K.INSTANT])
	jab.heat = 1
	assert_false(jab.has_unique_rule(), "a keyword, never the star")
	assert_eq(jab.describe(), "10 instant (+1 heat)", "and it says so")
	var sk := Skirmish.new(3)
	var m := _mech("A", Die.single(jab), 0, 200)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	var g: Foe = sk.front[0]
	assert_true(sk.assign(0, g), "spent")
	assert_false(sk.mechs[0].assigned, "the die rolls again, and the machine acts again")
	assert_false(Effects.is_entry_disabled(m, 0), "nothing switches off")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "the roll was free")
	assert_true(sk.assign(0, g), "the same entry showed again, and it is spent again")
	assert_eq(g.hp, 480, "two blows of 10")
	assert_true("\n".join(sk.log).contains("instant, rolls again"), "the log says so")
	# The fight's last blow rolls nothing: the fight is over.
	var s3 := Skirmish.new(4)
	var q := _mech("Q", Die.single(jab), 0, 200)
	s3.add_mech(q)
	s3.add_foes([_ghoul(10, 10)])
	s3.begin()
	s3.start_round()
	s3.assign(0, s3.front[0])
	assert_eq(s3.outcome, Skirmish.Outcome.VICTORY, "the last foe down")
	for line in s3.log:
		assert_false(line.contains("rolls again"), "no roll after the last kill: %s" % line)


func _special(kind: String, effect: String, extra: Dictionary = {}) -> Dictionary:
	var a := {"id": effect, "name": effect.capitalize(), "kind": kind, "effect": effect, "weight": 1, "text": ""}
	for k in extra.keys():
		a[k] = extra[k]
	return a


## A foe's brace is Braced, the machines' status (Ryan, 16 October: an effect and the buff it
## creates share a name): its value in stacks of armour +1, standing through the player's turn
## and going as the foes' next turn opens, every stack at once (15 November; at the foe's own
## next action until then).
func test_a_bracing_foe_is_braced_until_the_foes_next_turn_and_a_knitting_one_regrows() -> void:
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.attack(20, L)), 40, 100)
	sk.add_mech(m)
	var g := _ghoul(100, 10)
	g.actions = [_special("defend", "brace", {"value": 10})]
	g.action = g.actions[0]
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_false(g.attacks(), "not a blow")
	assert_eq(g.damage(), 0, "and no damage")
	assert_eq(sk.attackers_of(sk.mechs[0]).size(), 0, "so it is no attacker")
	assert_eq(sk.incoming_for(sk.mechs[0]), 0, "and the forecast is quiet")
	sk.end_round()
	assert_eq(m.shield, 40, "nothing struck")
	assert_eq(Effects.stacks_of(g, "braced"), 10, "Armoured past the round's end, a stack an armour point of the brace's 10")
	assert_eq(g.armour_total(), 10, "armour +10, read through the pipeline")
	assert_true("\n".join(sk.log).contains("Brace, Armoured ×10 (armour +10 until its next turn)"), "the log names the status")
	var desc := ""
	for d in Effects.describe(g):
		if str(d[5]) == "braced":
			desc = str(d[1])
	assert_eq(desc, "Armour +1 a stack, every stack at once, until its next turn starts.", "one description and one clock, for both sides")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 90, "the next round's 20 lands as 10: the brace's armour comes off, flat")
	sk.end_round()   # the foes' next turn: the stacks go as it opens, and its only move braces again
	assert_eq(Effects.stacks_of(g, "braced"), 10, "ten fresh stacks: the old ones went whole as the turn opened, a stack a turn would have left more")
	g.actions = [Foe.basic_action()]
	g.action = g.actions[0]
	sk.start_round()
	sk.end_round()   # its next action is a blow
	assert_false(Effects.has(g, "braced"), "gone as the foes' next turn opened, every stack at once")
	assert_eq(g.armour_total(), 0, "and its armour with them")
	var s2 := Skirmish.new(2, 1)
	s2.add_mech(_mech("B", Die.single(Face.attack(20, L)), 40, 100))
	var k := _ghoul(100, 10)
	k.hp = 50
	k.actions = [_special("defend", "recover", {"value": 20})]
	k.action = k.actions[0]
	s2.add_foes([k])
	s2.begin()
	s2.start_round()
	assert_eq(k.text_of(k.action), "", "no text set")
	s2.end_round()
	assert_eq(k.hp, 70, "regrew 20")
	k.hp = 95
	s2.start_round()
	s2.end_round()
	assert_eq(k.hp, 100, "never past its maximum")


## One status for one effect on both sides (Ryan, 16 October): a foe's armour from a defend is
## the machines' Braced, and no status of its own.
func test_a_foes_brace_is_the_machines_braced_and_no_status_of_its_own() -> void:
	assert_false(Effects.STATUS.has("folded"), "no status \"folded\" exists")
	assert_true(Foe.ACTION_EFFECTS["defend"].has("brace") and Foe.ACTION_EFFECTS["defend"].has("brace_all"), "the defends brace and brace_all")
	assert_eq(Effects.braced_armour(), 1, "Armoured is an armour point a stack (Ryan, 18 October; 5 before)")
	assert_eq(Effects.brace_stacks(10), 10, "so a brace of 10 is ten stacks")
	assert_eq(Effects.brace_stacks(5), 5, "and a brace of 5 five")
	assert_eq(Effects.STATUS["braced"]["name"], "Armoured", "both sides say Armoured (Ryan, 17 and 18 October); the engine id stays")


## A brace is armour in stacks of Braced (16 October), so the validator holds its value to a
## positive multiple of a stack's armour, on one foe or on every foe.
func test_the_validator_asks_a_brace_for_a_positive_armour() -> void:
	# A brace's value is its stacks of Armoured, an armour point each (18 October), so any
	# positive number stands (a multiple of 5 was asked for while a stack was 5) and nothing
	# braces for nothing.
	var db := ContentDB.new()   # its own copy: the foes below are added to it
	db.load_dir(ContentDB.DIR)
	var base: Dictionary = db.foes[db.foes.keys()[0]].duplicate(true)
	var cases := {"brace_whole": ["brace", 10], "brace_odd": ["brace", 7], "brace_none": ["brace", 0], "brace_all_none": ["brace_all", 0]}
	for id in cases.keys():
		var f: Dictionary = base.duplicate(true)
		f["name"] = str(id).capitalize()
		f["actions"] = [{"id": "claw", "name": "Claw", "kind": "attack", "text": "", "status": "implemented"},
			{"id": "dig", "name": "Dig", "kind": "defend", "effect": cases[id][0], "value": cases[id][1], "weight": 1, "text": "", "status": "implemented"}]
		db.foes[id] = f
	var refused := {}
	for e in db.validate():
		for id in cases.keys():
			if e.begins_with("foe %s action dig" % id) and e.contains("stacks of Armoured"):
				refused[id] = true
	assert_false(refused.has("brace_whole"), "a brace of 10 is ten stacks")
	assert_false(refused.has("brace_odd"), "a brace of 7 is seven, and stands")
	assert_true(refused.has("brace_none"), "a brace of nothing is refused")
	assert_true(refused.has("brace_all_none"), "a brace on every foe is held to it too")
	assert_eq(Effects.brace_stacks(7), 7, "the value is the stacks")


func test_a_readied_foe_gets_back_up_once() -> void:
	var sk := Skirmish.new(3, 1)
	var m := _mech("A", Die.single(Face.attack(50, L)), 40, 100)
	sk.add_mech(m)
	var g := _ghoul(30, 10)
	g.actions = [_special("buff", "revive_once")]
	g.action = g.actions[0]
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_true(Effects.has(g, "risen"), "readied")
	sk.start_round()
	var hp_before := m.hull + m.shield
	sk.assign(0, g)
	assert_eq(sk.front[0], g, "it fell and got back up in its own slot at once (Ryan, 26 October)")
	assert_eq(sk.reinforcements.size(), 0, "never into the pool")
	assert_eq(g.hp, 30, "whole")
	assert_false(Effects.has(g, "risen"), "the charge spent")
	assert_true(g.fresh and g.target == null, "its round over: no intent")
	assert_true("\n".join(sk.log).contains("gets back up"), "the log says so")
	assert_eq(sk.outcome, Skirmish.Outcome.NONE, "the fight goes on")
	sk.end_round()
	assert_eq(m.hull + m.shield, hp_before, "it struck nobody the round it got back up")
	sk.start_round()
	assert_false(g.fresh, "it acts from the next round")
	sk.assign(0, g)
	assert_eq(sk.reinforcements.size(), 0, "once only")
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "and the second death holds")


## Shown text (the audit's thirteenth bug, 8 November): Purge says its number, as every numbered
## keyword does, and the readout names whom each foe move that is no blow acts on.
func test_purge_says_its_number_and_every_foe_move_says_whom_it_acts_on() -> void:
	var purge := Face.attack(0, I, [K.DISPEL])
	purge.dispel = 2
	assert_true(purge.describe().contains("2"), "Purge 2 says its 2: %s" % purge.describe())
	var bare := Face.attack(0, I)
	bare.add_keyword(K.DISPEL)
	assert_eq(bare.dispel, 1, "a Purge with no number is Purge 1")
	for kind in ["defend", "buff"]:
		for effect in Foe.ACTION_EFFECTS[kind]:
			assert_true(EntryReadout.MOVE_TARGETS.has(effect), "the readout names whom %s acts on" % effect)
			var key := str(EntryReadout.MOVE_TARGETS.get(effect, ""))
			assert_true(key == "every_machine" or Templates.has("foe_target." + key), "and content says it (foe_target.%s), or the term does (every machine)" % key)


func test_a_summoning_foe_calls_up_reinforcements_through_the_factory() -> void:
	var sk := Skirmish.new(5, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var n := _archer(30, 10)
	n.pack_id = 7
	n.actions = [_special("buff", "summon", {"foe": "revenant", "count": 2})]
	n.action = n.actions[0]
	sk.add_foes([n])
	sk.foe_factory = func(id: String) -> Foe:
		var g := Foe.make("The Revenant", 30, 10)
		g.content_id = id
		return g
	sk.begin()
	sk.start_round()
	var a: Skirmish.MechState = sk.mechs[0]
	var hull := a.unit.hull + a.unit.shield
	sk.end_round()
	assert_eq(sk.field_foes().size(), 3, "two ghouls took the empty slots at once (Ryan, 26 October)")
	assert_true("\n".join(sk.log).contains("2 The Revenant answer the call, stepping up"), "the log says so, by the foe's name, never its id (the audit's thirteenth bug)")
	assert_eq(a.unit.hull + a.unit.shield, hull, "and struck nobody the round they came")
	for f in sk.field_foes():
		assert_eq(f.pack_id, 7, "in the summoner's pack")
	# No empty slot of its rank: it never summons (Ryan, 7 November: "a summoner should not summon
	# if there's no space"), and made to anyway, nothing comes: there is no pool.
	var s3 := Skirmish.new(5, 1)
	s3.add_mech(_mech("C", Die.single(Face.attack(10, L)), 40, 100))
	var n3 := _archer(30, 10)
	n3.actions = [_special("buff", "summon", {"foe": "revenant"})]
	n3.action = n3.actions[0]
	s3.add_foes([_ghoul(300, 1), n3])
	s3.foe_factory = func(id: String) -> Foe: return Foe.make(id, 30, 10)
	s3.begin()
	s3.start_round()
	assert_false(s3.legal_actions(n3).has(n3.actions[0]), "the front full: the summon is no move it may announce")
	n3.action = n3.actions[0]
	s3._foe_acts(n3, s3.mechs[0])
	assert_true(s3.reinforcements.is_empty(), "made to anyway, nothing waits")
	assert_eq(s3.field_foes().size(), 2, "and nothing came")
	# Room for one, a call for two: it summons what fits (Ryan, 8 November: "Summoner should be
	# able to summon whatever they're able to"), never shut by a slot left just short.
	var s4 := Skirmish.new(7, 2)
	s4.add_mech(_mech("D", Die.single(Face.attack(10, L)), 40, 100))
	var n4 := _archer(30, 10)
	n4.actions = [_special("buff", "summon", {"foe": "revenant", "count": 2})]
	n4.action = n4.actions[0]
	s4.add_foes([_ghoul(300, 1), n4])
	s4.foe_factory = func(id: String) -> Foe: return Foe.make(id, 30, 10)
	s4.begin()
	s4.start_round()
	assert_eq(s4._free_slots_for(Foe.make("revenant", 30, 10)), 1, "one front slot open")
	assert_true(s4.legal_actions(n4).has(n4.actions[0]), "room for one of two: the call may be announced")
	s4.assign(0, s4.front[0]) if false else null
	s4._foe_acts(n4, s4.mechs[0])
	assert_eq(s4.field_foes().size(), 3, "and one stands, as many as fit")
	assert_true("\n".join(s4.log).contains("1 stepping up"), "the log says how many")
	var s2 := Skirmish.new(6, 1)
	s2.add_mech(_mech("B", Die.single(Face.attack(10, L)), 40, 100))
	var n2 := _archer(30, 10)
	n2.actions = [_special("buff", "summon", {"foe": "revenant"})]
	n2.action = n2.actions[0]
	s2.add_foes([n2])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq(s2.field_foes().size(), 1, "with no factory, nothing answers")
	assert_true("\n".join(s2.log).contains("nothing answers"), "and the log says so")


## A summon that calls back only what its pack has lost (`refill`, the Wild Huntsman's Horn, Ryan's
## go of 20 November on "a fallen rider rides back"): no call while every rider stands, room or
## none; one back once one has fallen; never more of the kind than rode out.
func test_the_huntsmans_horn_calls_back_only_the_riders_its_pack_has_lost() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var horn: Dictionary = {}
	for a in db.make_foe("wild_huntsman").actions:
		if bool(a.get("refill", false)):
			horn = a
	assert_false(horn.is_empty(), "the Huntsman carries a summon that refills")
	var who := str(horn.get("foe", ""))
	var pack := Unit.pack(9, "The Hunt", Vector2i.ZERO)
	pack.members = [["wild_huntsman", 1], [who, 2]]
	var sk := Skirmish.new(11, 4)
	sk.add_mech(_mech("A", Die.single(Face.blank()), 0, 300))
	var lineup := db.foes_for(pack)
	sk.add_foes(lineup, pack)
	sk.foe_factory = func(id: String) -> Foe: return db.make_foe(id)
	sk.begin()
	sk.start_round()
	var huntsman: Foe = null
	var riders: Array = []
	for f in sk.field_foes():
		if f.content_id == "wild_huntsman":
			huntsman = f
		elif f.content_id == who:
			riders.append(f)
	assert_eq(riders.size(), 2, "two riders rode out")
	assert_eq(sk._free_slots_for(db.make_foe(who)), 1, "a front slot stands open")
	assert_eq(sk.refill_short(huntsman, horn), 0, "nothing lost")
	assert_false(sk.legal_actions(huntsman).has(horn), "so the horn is no move it may announce, room or none")
	(riders[0] as Foe).hp = 0
	sk._clear_dead()
	assert_eq(sk.refill_short(huntsman, horn), 1, "one rider fallen, one short")
	assert_true(sk.legal_actions(huntsman).has(horn), "and the horn may sound")
	huntsman.action = horn
	sk._foe_acts(huntsman, sk.mechs[0])
	var standing := 0
	for f in sk.field_foes():
		if f.alive() and f.content_id == who:
			standing += 1
	assert_eq(standing, 2, "one rides back, two again")
	assert_eq(sk._free_slots_for(db.make_foe(who)), 1, "and the open slot stays open: never more than rode out")
	assert_eq(sk.refill_short(huntsman, horn), 0, "nothing short again")
	assert_false(sk.legal_actions(huntsman).has(horn), "so no second call")
	# A call for several calls back no more than is short.
	var two := horn.duplicate(true)
	two["count"] = 3
	for f in sk.field_foes():
		if f.alive() and f.content_id == who:
			f.hp = 0
			break
	sk._clear_dead()
	huntsman.action = two
	sk._foe_acts(huntsman, sk.mechs[0])
	standing = 0
	for f in sk.field_foes():
		if f.alive() and f.content_id == who:
			standing += 1
	assert_eq(standing, 2, "a call for three brings back the one short")


func test_a_rally_lands_at_once_and_a_foe_that_has_acted_carries_it_whole_to_its_next_blow() -> void:
	# The rallier strikes nothing, so it stands right of the ghoul and acts after it (Ryan, 26
	# October: "howl is more clear if it gives kindled for the next action, which could be the
	# turn its granted"): the ghoul has struck by the time the rally lands, and its turn's end,
	# where its Empowered halves, is behind it (16 November: a foe's turn ends as its own action
	# does), so its next blow has the whole rally. The rallier's own share halves at once, its
	# turn ending on the rally.
	var sk := Skirmish.new(7, 2)
	var m := _mech("A", Die.single(Face.blank()), 0, 300)
	sk.add_mech(m)
	var lord := _ghoul(500, 10)
	lord.actions = [_special("buff", "rally", {"value": 10})]
	lord.action = lord.actions[0]
	var g := _ghoul(500, 10)
	sk.add_foes([lord, g])
	sk.begin()
	assert_true(sk.front[0] == g, "the ghoul stands left and acts first")
	sk.start_round()
	assert_eq(sk.foe_blow(g), 10, "no rally reaches it before its blow: its intent is its plain 10")
	assert_true(sk.rallies_on(g).is_empty(), "and none is on its way")
	sk.end_round()
	assert_eq(m.hull, 290, "the ghoul's plain 10 this round; the lord rallied after it")
	assert_eq(Effects.stacks_of(g, "kindled"), 10, "the ghoul is Empowered, all ten: its turn had ended before the rally landed")
	assert_eq(Effects.stacks_of(lord, "kindled"), 5, "the lord itself carries half, its own turn ending on its rally (Ryan, 15 November: \"Buff itself too. Helps with low foe counts\")")
	assert_true("\n".join(sk.log).contains("2 hit 10 harder"), "and the log counts both")
	sk.start_round()
	assert_eq(g.damage(), 20, "its intent reads 20, the whole rally")
	lord.actions = [Foe.basic_action()]
	lord.action = lord.actions[0]
	assert_eq(sk.foe_blow(lord), 15, "and the lord's own blow the half it kept")
	sk.end_round()
	assert_eq(m.hull, 290 - 20 - 15, "20 from the Empowered ghoul, 15 from the lord's own blow")
	assert_eq(Effects.stacks_of(g, "kindled"), 5, "the blow spends nothing; the stacks halve as its turn ends")
	assert_eq(Effects.stacks_of(lord, "kindled"), 2, "and the lord's again")
	sk.start_round()
	assert_eq(g.damage(), 15, "five left, then two, then one, then plain")


func test_a_rally_lifts_the_foes_acting_after_it_this_turn_and_their_intents_show_it() -> void:
	# The rallier is the heaviest hitter, so it stands left and acts first: the foe after it is
	# Empowered before its blow, at the move's own value, and its intent shows the lifted number
	# from the round's start (Ryan, 26 October: "The intents should take into account incoming
	# buffs").
	var sk := Skirmish.new(11, 2)
	var m := _mech("A", Die.single(Face.blank()), 0, 300)
	sk.add_mech(m)
	var lord := _ghoul(500, 50)
	var howl := _special("buff", "rally", {"value": 5})
	lord.actions = [Foe.basic_action(), howl]
	var g := _ghoul(500, 10)
	sk.add_foes([lord, g])
	sk.begin()
	assert_true(sk.front[0] == lord, "the heavier hitter stands left and acts first")
	sk.start_round()
	lord.action = howl
	assert_eq(g.damage(), 10, "its own statuses lift nothing yet")
	assert_eq(sk.incoming_rally(g), 5, "the Howl's own 5 is on its way")
	assert_true(sk.rallies_on(g).size() == 1 and sk.rallies_on(g).has(lord), "from the lord")
	assert_eq(sk.foe_blow(g), 15, "so the intent shows 15")
	assert_eq(sk.incoming_for(sk.mechs[0]), 15, "and the forecast counts it")
	assert_eq(sk.foe_blow(lord), 0, "the rallier strikes nothing")
	sk.end_round()
	assert_eq(m.hull, 285, "the blow landed is the intent shown: 10 and the Howl's 5")
	assert_eq(Effects.stacks_of(g, "kindled"), 2, "the blow spends nothing: the five halve as its turn ends")
	assert_eq(Effects.stacks_of(lord, "kindled"), 2, "and the rallier itself the same: its own five, halved as its turn ended")
	sk.start_round()
	lord.action = lord.actions[0]
	assert_eq(sk.foe_blow(g), 12, "the two it carried, with no rally on its way")
	assert_eq(sk.foe_blow(lord), 52, "and the lord's blow the two it kept of its own rally")
	sk.end_round()
	assert_eq(m.hull, 285 - 52 - 12, "the lord's 52 and the ghoul's 12")


func test_an_incoming_rally_drops_when_its_rallier_is_suppressed_disrupted_or_killed() -> void:
	var sk := Skirmish.new(11, 2)
	var m := _mech("A", Die.single(Face.blank()), 0, 300)
	sk.add_mech(m)
	var lord := _ghoul(500, 50)
	var howl := _special("buff", "rally", {"value": 5})
	lord.actions = [Foe.basic_action(), howl]
	var g := _ghoul(500, 10)
	sk.add_foes([lord, g])
	sk.begin()
	sk.start_round()
	lord.action = howl
	assert_eq(sk.foe_blow(g), 15, "the rally is on its way")
	Effects.grant_for_rounds(lord, Effects.STATUS["suppressed"], "mech", sk.round)
	assert_eq(sk.foe_blow(g), 10, "Suppressed, the rallier lands nothing, and the intent drops at once")
	assert_eq(sk.rally_worth(lord), 0, "nor is its rally worth anything to stop")
	Effects.remove(lord, "suppressed")
	assert_eq(sk.foe_blow(g), 15, "lifted again")
	sk._disrupt([lord])
	assert_true(lord.attacks(), "Disrupted, it swings instead")
	assert_eq(sk.foe_blow(g), 10, "and the rally is gone from the intent")
	lord.action = howl
	assert_eq(sk.foe_blow(g), 15, "back on its rally")
	lord.hp = 0
	assert_eq(sk.foe_blow(g), 10, "killed, it rallies nobody")
	sk.end_round()
	assert_eq(m.hull, 290, "the ghoul's plain 10 landed")
	assert_false(Effects.has(g, "kindled"), "and nothing was kindled")


func test_a_rally_reaches_every_foe_after_it_at_its_value_and_two_rallies_add() -> void:
	# Two ralliers: each lands its own grant, so the foes after both carry both, and a rallier
	# after the other is lifted by the first though its own move, a special, gains nothing.
	var sk := Skirmish.new(3, 4)
	var m := _mech("A", Die.single(Face.blank()), 0, 500)
	sk.add_mech(m)
	var a := _ghoul(500, 40)
	var b := _ghoul(500, 30)
	var c := _ghoul(500, 10)
	var d := _ghoul(500, 10)
	a.actions = [Foe.basic_action(), _special("buff", "rally", {"value": 2})]
	b.actions = [Foe.basic_action(), _special("buff", "rally", {"value": 3})]
	sk.add_foes([a, b, c, d])
	sk.begin()
	assert_eq(sk.front, [a, b, c, d], "the heavier hitters stand left")
	sk.start_round()
	a.action = a.actions[1]
	b.action = b.actions[1]
	assert_eq(sk.foe_blow(c), 15, "10 and both rallies on their way")
	assert_eq(sk.foe_blow(d), 15, "the last as well")
	assert_eq(sk.incoming_rally(b), 2, "the second rallier is reached by the first")
	assert_eq(sk.rally_worth(a), 4, "the first's rally lifts the two blows after it by 2 each")
	assert_eq(sk.rally_worth(b), 6, "the second's by 3 each")
	sk.end_round()
	assert_eq(m.hull, 500 - 15 - 15, "both lifted blows landed")
	assert_eq(Effects.stacks_of(b, "kindled"), 2, "its own rally spends nothing of the first's 2 and adds its own 3: five halve to two as its turn ends")
	assert_eq(Effects.foe_attack_bonus(a), 4, "the first's own 2 halved to 1 as its turn ended, then the second's 3 landed whole on it, its turn over")
	assert_eq(Effects.stacks_of(c, "kindled") + Effects.stacks_of(d, "kindled"), 4, "the blows spend nothing: five halve to two each")


func test_a_foes_adds_land_on_every_strike_of_a_move_whatever_its_factor() -> void:
	# The machines' formula on the foes' side (Ryan, 18 November, of an Empowered the move's
	# factor scaled: "Should work the same as the machines do"): a move's number is its own, the
	# foe's attack at the move's factor, and every add is a point on each strike. A flurry of
	# half-strength strikes takes a rally whole on every strike, a great blow takes it once, and
	# a swarm, a grudge and a Sapped's less land the same way.
	var sk := Skirmish.new(3, 4)
	var m := _mech("A", Die.single(Face.blank()), 0, 500)
	sk.add_mech(m)
	var r := _ghoul(500, 40)
	var f := _ghoul(500, 10)
	r.actions = [Foe.basic_action(), _special("buff", "rally", {"value": 2})]
	var flurry := {"id": "flurry", "name": "Flurry", "kind": "attack", "factor": 0.5, "strikes": 3, "weight": 1, "keywords": [], "text": ""}
	var great := {"id": "great", "name": "Great Blow", "kind": "attack", "factor": 1.5, "strikes": 1, "weight": 1, "keywords": [], "text": ""}
	var pack := {"id": "pack", "name": "Pack Bite", "kind": "attack", "factor": 0.5, "strikes": 2, "weight": 1, "keywords": [], "text": "", "swarm": 3, "per_kill": 1}
	f.actions = [flurry, great, pack]
	sk.add_foes([r, f])
	sk.begin()
	assert_eq(sk.front[0], r, "the rallier stands left and acts first")
	sk.start_round()
	assert_eq(f.base_damage_of(flurry), 5, "the move's number: 10 at half")
	assert_eq(f.base_damage_of(great), 15, "and 10 at half again as much")
	r.action = r.actions[1]
	f.action = great
	assert_eq(sk.foe_blow(f), 17, "a rally of 2 on its way is 2 on the great blow, never 3 for its factor")
	f.action = flurry
	assert_eq(sk.foe_blow(f), 7, "and 2 on each strike of 5, never 1 for the half")
	sk.end_round()
	assert_eq(m.hull, 500 - 7 * 3, "three strikes of 7 landed")
	assert_eq(Effects.stacks_of(f, "kindled"), 1, "the rally halved as its turn ended")
	assert_eq(f.damage_of(flurry), 6, "what is left is a point a strike")
	f.kin = 2
	f.grudge = 1
	assert_eq(f.damage_of(pack), 5 + 1 + 3 * 2 + 1, "a swarm and a grudge are adds on the move's number as the rally is")
	Effects.grant_buff(f, "sapped", 2, "test", 99)
	assert_eq(f.damage_of(flurry), 5 + 1 - 2, "a Sapped's less comes off each strike whole")
	assert_eq(f.damage_of({"id": "tap", "name": "Tap", "kind": "attack", "factor": 0.1, "strikes": 1, "weight": 1, "keywords": [], "text": ""}), 0, "and never below nothing")


func test_a_suppress_takes_a_kindled_move_and_a_countdown_carries_its_rally_to_the_blow() -> void:
	# A Suppress spends none of a foe's Empowered, which halves on its own clock (4 November); a
	# countdown gathering carries what stands to the blow it lands, and its intent shows what it
	# would deal now, never a rally of a round before it lands (Ryan, 8 November: "It shouldn't
	# forecast rounds in the future. Show what it would deal at the current game state").
	var sk := Skirmish.new(5, 3)
	var m := _mech("A", Die.single(Face.blank()), 0, 500)
	sk.add_mech(m)
	var lancer := _gatherer(30, 1)
	var g := _ghoul(500, 10)
	var lord := _ghoul(500, 1)
	lord.actions = [_special("buff", "rally", {"value": 4})]
	lord.action = lord.actions[0]
	sk.add_foes([lancer, g, lord])
	sk.begin()
	assert_eq(sk.front, [lancer, g, lord], "the rallier acts last")
	sk.start_round()
	assert_true(lancer.gathering(), "the lancer gathers")
	assert_eq(sk.foe_blow(lancer), 30, "its Jump shows what it would deal now: no rally of this round")
	assert_eq(sk.foe_blow(g), 10, "the ghoul acts before the rally: its blow this round is plain")
	sk.end_round()
	assert_eq(m.hull, 490, "the ghoul's plain 10")
	assert_eq(Effects.foe_attack_bonus(lancer), 4, "the lancer's turn had ended, gathering, before the rally landed: it carries all four")
	assert_eq(Effects.foe_attack_bonus(g), 4, "and so does the ghoul")
	assert_eq(Effects.foe_attack_bonus(lord), 2, "the rallier's own share halved as its turn ended")
	sk.start_round()
	lord.action = Foe.basic_action()
	Effects.grant_for_rounds(g, Effects.STATUS["suppressed"], "mech", sk.round)
	assert_eq(sk.foe_blow(lancer), 34, "the Jump lands lifted by the four it carried")
	sk.end_round()
	assert_eq(m.hull, 490 - 34 - 3, "the lifted Jump and the lord's 1 with the two it kept of its own rally; the ghoul lost its move")
	assert_eq(Effects.stacks_of(g, "kindled"), 2, "a Suppress spends none of its Empowered, which halves as the turn it lost ends")
	assert_eq(Effects.stacks_of(lancer, "kindled"), 2, "nor does the Jump spend the lancer's")


func test_a_special_spends_no_empowered_and_it_halves_as_its_turn_ends() -> void:
	var sk := Skirmish.new(5, 1)
	var m := _mech("A", Die.single(Face.blank()), 0, 300)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	g.actions = [_special("defend", "recover", {"value": 5})]
	g.action = g.actions[0]
	sk.add_foes([g])
	sk.begin()
	Effects.stack(g, Effects.STATUS["kindled"], Effects.SKIRMISH, "foe:test", 6, Effects.DECAY_HALF)
	assert_false(Effects.STATUS["kindled"].has("spent_by"), "Empowered is spent by no move (4 November: it halves on both sides)")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 300, "a regrow lands no blow")
	assert_eq(Effects.stacks_of(g, "kindled"), 3, "and spends none of the Empowered, which halves as its turn ends")


## The round preview (Ryan, 26 October: it "should account for every single thing that will
## happen other than 1) random active effects ... and 2) player decisions"): a copy plays the rest
## of the round, so the fight is untouched and the round then lands as shown.
func test_the_round_preview_plays_a_copy_and_the_round_then_lands_as_shown() -> void:
	var sk := Skirmish.new(4, 2)
	var m := _mech("A", Die.single(Face.blank()), 10, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 12), _ghoul(500, 8)])
	sk.begin()
	sk.start_round()
	var state := sk.rng.state
	var logged := sk.log.size()
	var pv := sk.preview_round()
	assert_eq(sk.rng.state, state, "no draw from the fight's stream")
	assert_eq(sk.log.size(), logged, "nothing logged in the fight")
	assert_eq(m.hull, 100, "and nothing struck")
	var mp: Dictionary = pv["mechs"][0]
	assert_eq(int(mp["incoming"]), 20, "both blows come in")
	assert_true(bool(mp["breaks_shield"]), "and break its shield")
	sk.end_round()
	assert_eq(int(mp["hull_after"]), m.hull, "the hull the round left is the hull previewed")
	assert_eq(int(mp["shield_after"]), m.shield, "and the shield")


## A heal is set before the player acts, so the preview reads it (Ryan, 26 October: "showing
## healing on the enemy side as part of the preview is incredibly important for decision
## making"): a Cure before a burning foe's tick keeps it standing, and its blow lands.
func test_the_round_preview_reads_a_cure_that_saves_a_burning_foe() -> void:
	var sk := Skirmish.new(4, 2)
	var m := _mech("A", Die.single(Face.blank()), 0, 100)
	sk.add_mech(m)
	var cleric := _ghoul(500, 20)
	var cure := _special("defend", "heal", {"value": 5})
	cleric.actions = [Foe.basic_action(), cure]
	var x := _ghoul(10, 7)
	sk.add_foes([cleric, x])
	sk.begin()
	assert_true(sk.front[0] == cleric, "the curer stands left and acts first")
	sk.start_round()
	cleric.action = cure
	x.hp = 2
	Effects.stack(x, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	var per := _rule("ablating", "tick_hp")
	assert_eq(sk.hp_after_ticks(x), 0, "alone, its Ablating fells it as its turn ends")
	var pv := sk.preview_round()
	assert_true(bool(pv["foes"][x]["alive"]), "cured first, it stands")
	assert_eq(int(pv["foes"][x]["hp"]), 2 + 5 - 3 * per, "2, cured 5, burnt 3")
	assert_eq(int(pv["mechs"][0]["hull_after"]), 100 - 7, "and its blow lands")
	sk.end_round()
	assert_true(x.alive(), "as it did")
	assert_eq(m.hull, 93, "and so did its blow")


## A foe's fall in the round reads in the preview, with what it sets off: a last act (fired as the
## dead are cleared) and a self-destruct.
func test_the_round_preview_lands_a_last_act_and_reads_a_self_destruct() -> void:
	var sk := Skirmish.new(4, 3)
	var m := _mech("A", Die.single(Face.blank()), 0, 100)
	sk.add_mech(m)
	var beast := _meteor_beast(2)
	Effects.stack(beast, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 5)
	var bomb := Foe.make("bomb", 50, 6)
	bomb.actions = [{"id": "burst", "name": "Self-Destruct", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": ["self_destruct"], "text": ""}]
	bomb.action = bomb.actions[0]
	sk.add_foes([beast, bomb])
	sk.begin()
	sk.start_round()
	var pv := sk.preview_round()
	assert_false(bool(pv["foes"][beast]["alive"]), "it burns to death as its turn ends")
	assert_false(bool(pv["foes"][bomb]["alive"]), "the bomb spends itself")
	assert_eq(int(pv["mechs"][0]["hull_after"]), 100 - 20 - 20 - 6, "its own blow first, then the Meteor its fall sets off, and the bomb's blow")
	sk.end_round()
	assert_eq(m.hull, 100 - 20 - 20 - 6, "as they landed")


## The preview reads a web exactly (2 November; the burst at the round's end since 16 November):
## every blow lands this round, and the Suppressed on its way shows on each foe the burst will
## stun; a foe whose Numbed the burst only strips shows none, and nothing is held back.
func test_the_round_preview_reads_a_web_exactly() -> void:
	var sk := Skirmish.new(4, 2)
	var m := _mech("A", Die.single(Face.blank()), 0, 100)
	sk.add_mech(m)
	var a := _ghoul(500, 9)
	var b := _ghoul(500, 6)
	sk.add_foes([a, b])
	sk.begin()
	sk.start_round()
	Effects.stack(a, Effects.STATUS["webbed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	var pv := sk.preview_round()
	assert_eq(int(pv["mechs"][0]["hull_after"]), 100 - 9 - 6, "the burst comes as the round ends: both blows land this round")
	assert_true((pv["foes"][a]["coming"] as Dictionary).has("suppressed") and (pv["foes"][b]["coming"] as Dictionary).has("suppressed"), "and both wear the Suppressed on its way")
	Effects.stack(b, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	pv = sk.preview_round()
	assert_true((pv["foes"][a]["coming"] as Dictionary).has("suppressed"), "the webbed foe is stunned still")
	assert_false((pv["foes"].get(b, {}).get("coming", {}) as Dictionary).has("suppressed"), "on a Numbed foe the burst strips a stack and stuns nothing, for sure")
	assert_eq(Effects.stacks_of(b, "numbed"), 2, "and the fight itself is untouched")


## The die in hand counts only over a valid target (Ryan, 26 October: "Die faces only apply to
## the preview when hovered over a valid target"): over the foe it kills, the foe falls and its
## blow comes off.
func test_the_round_preview_spends_the_die_in_hand_only_over_its_target() -> void:
	var sk := Skirmish.new(4, 2)
	var m := _mech("A", Die.single(Face.attack(5, L)), 0, 100)
	sk.add_mech(m)
	var a := _ghoul(5, 9)
	var b := _ghoul(500, 6)
	sk.add_foes([a, b])
	sk.begin()
	sk.start_round()
	var pv := sk.preview_round()
	assert_eq(int(pv["mechs"][0]["hull_after"]), 100 - 15, "nothing in hand: both blows")
	pv = sk.preview_round(0, a)
	assert_false(bool(pv["foes"][a]["alive"]), "over the foe it kills, it falls")
	assert_eq(int(pv["mechs"][0]["hull_after"]), 100 - 6, "and its blow comes off")
	assert_true(a.alive() and not sk.mechs[0].assigned, "the fight untouched")


## Ryan's own case (26 October): "if a player hits with a weapon that grants burn, it should then
## show impending death if the burn is sufficient". Over the foe, the Ablate the hit lays ticks as
## its turn ends and kills it, its blow landed first (16 November: a foe's ticks at its turn's
## end); spent, the same reads with nothing in hand.
func test_the_round_preview_reads_a_burn_that_kills_as_the_foes_turn_ends() -> void:
	var sk := Skirmish.new(4, 2)
	var torch := Face.attack(1, L, K.ABLATE)
	torch.ablate = 3
	var m := _mech("A", Die.single(torch), 0, 100)
	sk.add_mech(m)
	var x := _ghoul(1 + 3 * _rule("ablating", "tick_hp"), 9)
	var b := _ghoul(500, 6)
	sk.add_foes([x, b])
	sk.begin()
	sk.start_round()
	var pv := sk.preview_round()
	assert_true(bool(pv["foes"][x]["alive"]), "nothing in hand: it stands")
	assert_eq(int(pv["mechs"][0]["hull_after"]), 100 - 9 - 6, "and strikes")
	pv = sk.preview_round(0, x)
	assert_false(bool(pv["foes"][x]["alive"]), "over it, the Ablate the hit lays kills it as its turn ends")
	assert_eq(int(pv["mechs"][0]["hull_after"]), 100 - 9 - 6, "its blow landed first")
	sk.assign(0, x)
	pv = sk.preview_round()
	assert_false(bool(pv["foes"][x]["alive"]), "spent, the same with nothing in hand")
	sk.end_round()
	assert_false(x.alive(), "as it fell")
	assert_eq(m.hull, 100 - 9 - 6, "after its blow")


## No pick is ever open (Ryan, 26 October: "the targeting recalculates immediately, showing the
## new game state"): a foe whose machine falls before it acts strikes the next machine in line,
## left to right (Slice and Dice's rule, Ryan's call of the same day), so the preview shows the
## machine it will strike; a strike at random with one foe standing strikes it.
func test_the_round_preview_shows_the_pick_a_foe_whose_machine_falls_will_make() -> void:
	var sk := Skirmish.new(4, 2)
	sk.add_mech(_mech("A", Die.single(Face.blank()), 0, 10))
	var b := _mech("B", Die.single(Face.blank()), 0, 100)
	sk.add_mech(b)
	var big := _ghoul(500, 20)
	var small := _ghoul(500, 7)
	sk.add_foes([big, small])
	sk.begin()
	sk.start_round()
	big.target = sk.mechs[0]
	small.target = sk.mechs[0]
	var pv := sk.preview_round()
	assert_true(bool(pv["mechs"][0]["destroyed"]), "the first blow wrecks A")
	assert_eq(int(pv["mechs"][1]["hull_after"]), 100 - 7, "and the second, its machine gone, can only pick B")
	sk.end_round()
	assert_eq(b.hull, 100 - 7, "as it did")
	var s3 := Skirmish.new(4, 2)
	s3.add_mech(_mech("A", Die.single(Face.blank()), 0, 10))
	s3.add_mech(_mech("B", Die.single(Face.blank()), 0, 100))
	s3.add_mech(_mech("C", Die.single(Face.blank()), 0, 100))
	var big3 := _ghoul(500, 20)
	var small3 := _ghoul(500, 7)
	s3.add_foes([big3, small3])
	s3.begin()
	s3.start_round()
	big3.target = s3.mechs[0]
	small3.target = s3.mechs[0]
	pv = s3.preview_round()
	assert_eq(int(pv["mechs"][1]["hull_after"]), 100 - 7, "B, the next in line, takes the blow")
	var struck: Array = pv["foes"][small3]["struck"]
	assert_eq(struck, [1], "and the preview says so")
	var state3 := s3.rng.state
	pv = s3.preview_round()
	assert_true(s3.rng.state == state3, "nothing drawn")
	s3.end_round()
	assert_eq(s3.mechs[1].unit.hull, 100 - 7, "and the round strikes it")
	# A word never breaks the line (Ryan: "More unpredictable info"): a fire that goes for the
	# hottest picks it as the round opens, and the next in line when its machine falls.
	var sh := Skirmish.new(4, 2)
	sh.add_mech(_mech("A", Die.single(Face.blank()), 0, 10))
	sh.add_mech(_mech("B", Die.single(Face.blank()), 0, 100))
	sh.add_mech(_mech("C", Die.single(Face.blank()), 0, 100))
	var bigh := _ghoul(500, 20)
	var mage := _seeker("hottest", 500, 7)
	sh.add_foes([bigh, mage])
	sh.begin()
	sh.start_round()
	sh.mechs[2].heat = 30
	bigh.target = sh.mechs[0]
	mage.target = sh.mechs[0]
	pv = sh.preview_round()
	assert_eq(pv["foes"][mage]["struck"], [1], "B, the next in line, not the hottest")
	# A shot that fells a lone foe, and the preview says so.
	var s1 := Skirmish.new(4, 2)
	var gun := Face.attack(5, L)
	s1.add_mech(_mech("A", Die.single(gun), 0, 100))
	var lone := _ghoul(5, 9)
	s1.add_foes([lone])
	s1.begin()
	s1.start_round()
	pv = s1.preview_round(0, lone)
	assert_false(bool(pv["foes"][lone]["alive"]), "the lone foe falls to it")


## Every status the round lands is in the preview (Ryan, 26 October: "All incoming chips should
## appear as pulsing opacity versions"): the Ablate the die in hand lays and the Ablating a foe's
## rider leaves on the machine it strikes.
func test_the_round_preview_lists_every_status_the_round_lands() -> void:
	var sk := Skirmish.new(4, 2)
	var torch := Face.attack(1, L, K.ABLATE)
	torch.ablate = 3
	var m := _mech("A", Die.single(torch), 0, 100)
	sk.add_mech(m)
	var x := _ghoul(500, 9)
	x.actions[0]["keywords"] = ["ablate"]
	x.actions[0]["ablate"] = 2
	sk.add_foes([x])
	sk.begin()
	sk.start_round()
	var pv := sk.preview_round()
	assert_false(pv["foes"][x]["coming"].has("ablating"), "nothing in hand: no Ablate on it")
	assert_eq(int(pv["mechs"][0]["coming"]["ablating_mech"]["stacks"]), 2, "its rider's Ablating on the machine")
	assert_eq(str(pv["mechs"][0]["coming"]["ablating_mech"]["name"]), "Ablate", "named")
	pv = sk.preview_round(0, x)
	assert_eq(int(pv["foes"][x]["coming"]["ablating"]["stacks"]), 3, "over it, the Ablate the die lays")
	assert_true(m.recorder == null and x.recorder == null, "the fight's own carry no recorder: only the copy's play is noted")
	assert_false(Effects.has(x, "ablating") or Effects.has(x, "shocked") or Effects.has(m, "ablating_mech"), "the fight untouched")


func test_the_debuffs_cost_rerolls_and_heat() -> void:
	# Roar: the team has one reroll fewer next round.
	var sk := Skirmish.new(8, 1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 40, 100)
	sk.add_mech(m)
	var b := _ghoul(500, 10)
	b.actions = [_special("debuff", "drain_rerolls", {"value": 1})]
	b.action = b.actions[0]
	sk.add_foes([b])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(sk.reroll_debt, 1, "the debt is noted")
	sk.start_round()
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND - 1, "and paid at the next round's start")
	b.actions = [Foe.basic_action()]
	b.action = b.actions[0]
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "then it is over")
	# Stoke: Ablating on the target, its points at the end of the next player's turn.
	var s2 := Skirmish.new(9, 1)
	var m2 := _mech("B", Die.single(Face.attack(10, L)), 40, 100)
	s2.add_mech(m2)
	var h := _archer(500, 10)
	h.actions = [_special("debuff", "ablate", {"value": 2})]
	h.action = h.actions[0]
	s2.add_foes([h])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq(Effects.stacks_of(m2, "ablating_mech"), 2, "two stacks of Ablating")
	assert_eq(s2.mechs[0].heat, 0, "no heat yet")
	assert_eq(m2.shield, 40, "no blow with it")
	s2.start_round()
	assert_eq(int(s2.forecast(s2.mechs[0])["ablated"]), 2 * _rule("ablating_mech", "tick_hp"), "the forecast counts the tick to come")


## The foes never announce more drain than a round's rerolls (Ryan, 15 November: "mandragoras
## shouldn't try to scream away 3 rerolls, they should be smarter than that when declaring
## intents"): each reads the drains already out as it announces, down the strike order, and once
## they take every reroll a round gives its own drain is no move it may pick.
func test_the_foes_never_announce_more_drain_than_a_rounds_rerolls() -> void:
	var sk := Skirmish.new(11, 4)
	sk.add_mech(_mech("A", Die.single(Face.attack(1, L)), 40, 100000))
	var pack: Array[Foe] = []
	for i in range(4):
		var s := _archer(500, 1)
		s.actions = [Foe.basic_action(), _special("debuff", "drain_rerolls", {"value": 1, "weight": 1000})]
		s.action = s.actions[0]
		pack.append(s)
	sk.add_foes(pack)
	sk.begin()
	var most := 0
	for r in range(8):
		sk.start_round()
		var out := 0
		for f in sk.field_foes():
			if str(f.action.get("effect", "")) == "drain_rerolls":
				out += 1
		most = maxi(most, out)
		assert_true(out <= Skirmish.REROLLS_PER_ROUND, "round %d: %d drains announced, never more than a round's rerolls" % [sk.round, out])
		sk.end_round()
		assert_true(sk.reroll_debt <= Skirmish.REROLLS_PER_ROUND, "and never more owed than a round gives")
	assert_eq(most, Skirmish.REROLLS_PER_ROUND, "at that weight they do take every one, and stop there")


func test_a_drain_reads_only_the_moves_already_out_and_what_would_land() -> void:
	var sk := Skirmish.new(12, 4)
	sk.add_mech(_mech("A", Die.single(Face.attack(1, L)), 40, 100000))
	var pack: Array[Foe] = []
	for i in range(3):
		var s := _archer(500, 1)
		s.actions = [Foe.basic_action(), _special("debuff", "drain_rerolls", {"value": 1})]
		s.action = s.actions[0]
		pack.append(s)
	sk.add_foes(pack)
	sk.begin()
	sk.start_round()
	var foes := sk.field_foes()
	var a: Foe = foes[0]
	var b: Foe = foes[1]
	var c: Foe = foes[2]
	for f in foes:
		f.last_special = ""
	a.action = a.actions[1]
	b.action = b.actions[1]
	c.action = c.actions[0]
	assert_eq(sk.drain_announced(c), 2, "two drains out besides its own move")
	assert_false(sk.legal_actions(c).has(c.actions[1]), "so a third is no move it may announce")
	assert_true(sk.disrupt_next(c).is_empty(), "and a Disrupt finds it nothing else to do")
	assert_eq(sk.drain_announced(a), 1, "a drainer counts the others', never its own")
	assert_true(sk.legal_actions(a).has(a.actions[1]), "so its own stays open")
	# As the round opens a foe reads only the moves already out: what the foes after it in the
	# strike order still hold is last round's.
	assert_true(sk.legal_actions(c, []).has(c.actions[1]), "none out yet: the drain is open")
	assert_true(sk.legal_actions(c, [a]).has(c.actions[1]), "one out: still open")
	assert_false(sk.legal_actions(c, [a, b]).has(c.actions[1]), "two out: shut")
	# A drain that will not land counts for nothing.
	b.hp = 0
	assert_eq(sk.drain_announced(c), 1, "a destroyed foe's drain is out of the count")
	assert_true(sk.legal_actions(c).has(c.actions[1]), "so a drain is open again")
	assert_eq(sk.disrupt_next(c), c.actions[1], "and a Disrupt turns it there")
	# The count is in rerolls, not in foes.
	a.actions[1] = _special("debuff", "drain_rerolls", {"value": Skirmish.REROLLS_PER_ROUND})
	a.action = a.actions[1]
	assert_false(sk.legal_actions(c).has(c.actions[1]), "one drain of a whole round's rerolls shuts the next")
	# A foe that stepped up this round has announced nothing, whatever move it holds.
	a.fresh = true
	assert_eq(sk.drain_announced(c), 0, "a foe that stepped up this round is out of the count")
	assert_true(sk.legal_actions(c).has(c.actions[1]), "so the drain is open")


func test_a_foes_special_action_is_picked_by_weight_and_shows_its_kind() -> void:
	var g := _ghoul(30, 10)
	g.actions = [Foe.basic_action(), _special("defend", "brace", {"value": 10})]
	g.actions[0]["weight"] = 3
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var specials := 0
	for i in range(400):
		g.choose_action(rng)
		if not g.attacks():
			specials += 1
	assert_true(specials > 60 and specials < 140, "about one pick in four is the special: %d of 400" % specials)
	assert_eq(Foe.kind_of(g.actions[1]), "defend", "its kind reads")
	assert_eq(g.damage_of(g.actions[1]), 0, "and deals nothing")
	assert_eq(g.threat(), 10, "the threat for deployment is the blow's")


## A shield stops at its maximum, whatever grants it (Overshield, the one keyword that passed it,
## was cut on 15 November).
func test_a_shield_on_a_full_ally_stays_at_the_maximum() -> void:
	var plain := _mech("Plain", Die.single(Face.shield(30)), 40, 100)
	var sk2 := Skirmish.new(1)
	var t2 := _mech("T", Die.single(Face.attack(10, L)), 20, 100)
	t2.shield = 20
	sk2.add_mech(plain)
	sk2.add_mech(t2)
	sk2.add_foes([_ghoul(90)])
	sk2.begin()
	sk2.start_round()
	assert_true(sk2.assign(0, sk2.mechs[1]), "a shield on a full ally")
	assert_eq(t2.shield, 20, "stays at the maximum")
	assert_true(Face.keyword_from_name("overshield") <= 0, "and no keyword passes it")


func test_shielding_an_ally_fires_the_escorts_passive_on_the_ally() -> void:
	var escort := {"id": "escort", "name": "Escort", "description": "", "effects": [
		{"trigger": "on_shield_granted", "effect": "vent_heat", "value": 10}]}
	var sk := Skirmish.new(1)
	var giver := _mech("Giver", Die.of([Face.shield(30), Face.shield(10)]), 40, 100)
	var taker := _mech("Taker", Die.single(Face.attack(10, L)), 50, 100)
	giver.grant_passive(escort)
	sk.add_mech(giver)
	sk.add_mech(taker)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	sk.mechs[1].heat = 25
	sk.mechs[0].heat = 25
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.mechs[1]), "shield the ally")
	assert_eq(sk.mechs[1].heat, 15, "the ally shed 10 heat")
	assert_eq(sk.mechs[0].heat, 25, "the escort itself shed nothing")
	assert_true("\n".join(sk.log).contains("Taker: Giver's escort, -10 heat"), "the log names the escort")
	assert_eq(Effects.granted_vent(giver), 10, "the bot can read what the escort sheds")
	assert_eq(Effects.effect_text(escort["effects"][0]), "an ally this machine shields: sheds 10 heat", "reads as a sentence")
	# On itself the trigger never fires, and a shield on a full ally still vents.
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 1
	sk.mechs[0].heat = 25
	assert_true(sk.assign(0, null), "shield itself")
	assert_eq(sk.mechs[0].heat, 25, "no vent for a shield on itself")
	sk.end_round()
	sk.start_round()
	taker.shield = taker.shield_max
	sk.mechs[1].heat = 30
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, sk.mechs[1]), "shield a full ally")
	assert_eq(taker.shield, taker.shield_max, "the plain shield is capped")
	assert_eq(sk.mechs[1].heat, 20, "but the escort's vent still fires on the spend")


func test_the_gauge_triggers_fire_and_never_feed_themselves() -> void:
	var opening := {"id": "opening", "name": "Opening", "description": "", "effects": [
		{"trigger": "on_skirmish_start", "effect": "add_shield", "value": 15}]}
	var breather := {"id": "breather", "name": "Breather", "description": "", "effects": [
		{"trigger": "on_shield_gain", "effect": "vent_heat", "value": 10}]}
	var flywheel := {"id": "flywheel", "name": "Flywheel", "description": "", "effects": [
		{"trigger": "on_heat_gain", "effect": "add_shield", "value": 5}]}
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.of([Face.attack(20, L, [], 30), Face.shield(10)]), 60, 100)
	m.shield = 10
	m.grant_passive(opening)
	m.grant_passive(breather, "b")
	m.grant_passive(flywheel, "c")
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	assert_eq(m.shield, 25, "the opening's shield stood up as the fight began")
	assert_true("\n".join(sk.log).contains("A: as the fight begins, +15 shield"), "the log says so")
	sk.start_round()
	sk.mechs[0].heat = 25
	sk.mechs[0].face_index = 0
	sk.assign(0, sk.front[0])
	# The attack's 30 heat: the flywheel raises 5 shield, which the breather answers by
	# venting 10, and the shield gained grants no more shield.
	assert_eq(m.shield, 30, "5 shield from the heat gained")
	assert_eq(sk.mechs[0].heat, 25 + 30 - 10, "and 10 heat shed for the shield gained")
	assert_eq(Effects.effect_text({"trigger": "on_shield_gain", "effect": "vent_heat", "value": 10}), "on gaining shield: sheds 10 heat", "reads as a sentence")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 1
	var heat_before: int = sk.mechs[0].heat
	sk.assign(0, null)
	assert_eq(m.shield, 30 - 10 + 10, "the ghoul's 10 came off, the plate's 10 went on")
	assert_eq(sk.mechs[0].heat, maxi(0, heat_before - 10), "and the breather vented for it")


func test_a_foes_armour_comes_off_every_blow_but_never_a_burn() -> void:
	var sk := Skirmish.new(1, 2)
	var burst := Face.attack(15, L)
	burst.strikes = 2
	var m := _mech("A", Die.single(burst), 40, 100)
	sk.add_mech(m)
	var g := _ghoul(100, 10)
	g.armour = 10
	var n := _ghoul(100, 10)
	n.armour = 5
	sk.add_foes([g, n])
	sk.begin()
	sk.start_round()
	var first: Foe = sk.front[0]
	var second: Foe = sk.front[1]
	assert_true(sk.assign(0, first), "two blows of 15")
	assert_eq(first.hp, 100 - 2 * (15 - first.armour), "each blow loses the armour, flat")
	assert_true("\n".join(sk.log).contains("(armour -%d)" % (2 * first.armour)), "the log says what the armour took: %s" % sk.log[sk.log.size() - 1])
	# Armour read by the bot too: the expected damage is what gets past it.
	var pol := Policy.make(Policy.GREEDY)
	assert_eq(pol.expected_damage(sk.mechs[0], burst, second), float(2 * (15 - second.armour)), "the bot reads the armour")
	# A blow smaller than the armour does nothing; a burn ignores it.
	var tap := Face.attack(5, L, K.ABLATE)
	var s2 := Skirmish.new(1, 1)
	s2.add_mech(_mech("B", Die.single(tap), 40, 100))
	var h := _ghoul(100, 10)
	h.armour = 10
	s2.add_foes([h])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, h), "a tap with a burn")
	assert_eq(h.hp, 100, "the armour holds the tap whole")
	assert_true(h.ablate_stacks() > 0, "but the burn is on")
	s2.end_round()
	assert_true(h.hp < 100, "and the burn ticks past the armour")


func test_brace_is_flat_armour_for_the_rounds_it_says() -> void:
	var sk := Skirmish.new(1, 1)
	var brace := Face.buff("braced", 5, 1)
	var m := _mech("A", Die.single(brace), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 30)])
	sk.begin()
	sk.start_round()
	assert_eq(m.armour, 0, "bare")
	assert_true(sk.assign(0, null), "armours itself")
	assert_eq(m.armour, 5, "Armoured 5 is armour +5, read through the stat")
	assert_eq(int(sk.forecast(sk.mechs[0])["hull_after"]), 75, "the forecast takes the armour off the 30")
	sk.end_round()
	assert_eq(m.hull, 75, "and so does the blow")
	sk.start_round()
	assert_eq(m.armour, 0, "gone with the round")


func test_a_foes_rider_lays_its_number_of_stacks() -> void:
	# The numbered riders (24 October, as the player's Ablate N does): Scorch 2 lays two stacks a
	# blow, Ablate 3 three, Corrupt 2 two on the entry the die shows; a rider naming no number, as
	# a move built here may, lays one.
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(m)
	var f := _ghoul(500, 5)
	f.actions = [{"id": "lick", "name": "Lick", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1,
		"keywords": ["scorch", "ablate", "corrupt"], "scorch": 2, "ablate": 3, "corrupt": 2, "text": ""}]
	f.action = f.actions[0]
	sk.add_foes([f])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "scorched"), 2, "Scorch 2: two stacks of Scorched")
	assert_eq(Effects.stacks_of(m, "ablating_mech"), 3, "Ablate 3: three of Ablating")
	assert_eq(Effects.corrupt_stacks(m, 0), 2, "Corrupt 2: two on the entry the die shows")
	assert_eq(f.rider({"keywords": ["scorch"]}, "scorch"), 1, "no number: one")


func test_the_hush_the_eruption_and_the_unravel_run() -> void:
	# Hush: the showing weapon is Jammed through the machine's next turn, no blow.
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 40, 100)
	sk.add_mech(m)
	var w := _ghoul(500, 10)
	w.actions = [_special("debuff", "jam")]
	w.action = w.actions[0]
	sk.add_foes([w])
	sk.begin()
	sk.start_round()
	assert_false(w.attacks(), "the hush is its one move")
	sk.end_round()
	assert_eq(m.shield, 40, "no blow")
	sk.start_round()
	assert_eq(sk.mechs[0].face().kind, Face.Kind.BLANK, "the entry shows blank the next turn")
	assert_true("\n".join(sk.log).contains("is jammed"), "the log says so")
	# Eruption: every machine Scorched, whoever it was aimed at.
	var s2 := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.shield(10)), 40, 100)
	var b := _mech("B", Die.single(Face.shield(10)), 40, 100)
	s2.add_mech(a)
	s2.add_mech(b)
	var lord := _ghoul(500, 10)
	lord.actions = [_special("debuff", "scorch_all", {"value": 2})]
	lord.action = lord.actions[0]
	s2.add_foes([lord])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq(Effects.stacks_of(a, "scorched"), 2, "both machines")
	assert_eq(Effects.stacks_of(b, "scorched"), 2, "are scorched")
	assert_eq(s2.mechs[0].heat, 0, "and no heat lands by itself")
	# Unravel: every machine's showing component is corrupted.
	var s3 := Skirmish.new(1, 1)
	var c := _mech("C", Die.single(Face.attack(10, L)), 40, 100)
	var d := _mech("D", Die.single(Face.attack(10, L)), 40, 100)
	s3.add_mech(c)
	s3.add_mech(d)
	var maw := _ghoul(500, 10)
	maw.actions = [_special("debuff", "corrupt_all")]
	maw.action = maw.actions[0]
	s3.add_foes([maw])
	s3.begin()
	s3.start_round()
	s3.end_round()
	assert_eq(Effects.corrupt_stacks(c, s3.mechs[0].face_index), 1, "the first machine's showing entry is corrupted")
	assert_eq(Effects.corrupt_stacks(d, s3.mechs[1].face_index), 1, "and the second's")


func test_a_shocking_weapon_leaves_a_charge_its_own_blow_never_spends() -> void:
	var sk := Skirmish.new(1, 2)
	var tesla := Face.attack(20, L, K.SHOCK)
	tesla.add_keyword(K.CLEAVE)
	tesla.cleave = 10
	var a := _mech("A", Die.single(tesla), 40, 100)
	var b := _mech("B", Die.single(Face.attack(20, L)), 40, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var g1 := _ghoul(500, 10)
	var g2 := _ghoul(500, 10)
	sk.add_foes([g1, g2])
	sk.begin()
	sk.start_round()
	assert_eq(tesla.describe(), "20 shock spread 10", "the keywords read on the entry, Spread's number with it")
	assert_true(sk.assign(0, sk.front[0]), "A punches the first ghoul")
	assert_eq(sk.front[0].hp, 480, "the blow itself lands plain")
	assert_true(Effects.has(sk.front[0], "shocked") and Effects.has(sk.front[1], "shocked"), "and every foe it reached is Shocked, the spread's neighbour too")
	assert_true(sk.assign(1, sk.front[0]), "B follows up")
	assert_eq(sk.front[0].hp, 440, "20 lands double")
	assert_false(Effects.has(sk.front[0], "shocked"), "and the charge is spent")


func test_a_blow_of_nothing_leaves_a_standing_shock_alone() -> void:
	var sk := Skirmish.new(1, 1)
	var probe := Face.attack(0, L, K.SHOCK)
	var m := _mech("A", Die.single(probe), 40, 100)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.stack(g, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(0, g), "the projector is spent on a foe already Shocked")
	assert_true(Effects.has(g, "shocked"), "a blow of nothing never spends the charge")
	assert_eq(Effects.stacks_of(g, "shocked"), 1, "and a shock never stacks")
	assert_false("\n".join(sk.log).contains("the shock lands"), "the log claims no doubled blow")


func test_a_rapid_vent_cools_and_the_machine_acts_again() -> void:
	var sk := Skirmish.new(2)
	var diffuser := Face.vent(10)
	diffuser.add_keyword(K.RAPID)
	var m := _mech("A", Die.of([diffuser, Face.attack(30, L)]), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.mechs[0].heat = 30
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.mechs[0]), "vent itself")
	assert_eq(sk.mechs[0].heat, 20, "ten heat gone")
	assert_false(sk.mechs[0].assigned, "and the machine may act again")
	assert_eq(sk.mechs[0].face_index, 1, "on the other entry, rolled free")
	assert_true(sk.assign(0, sk.front[0]), "so the gun fires the same round")
	assert_eq(sk.front[0].hp, 170, "thirty landed")


func test_a_hull_hit_can_raise_shield_and_shed_heat() -> void:
	# on_hull_damage's add_shield and vent_heat were accepted by the validator and dropped by
	# the skirmish until 9 October (the Spall Liner needs the shield).
	var liner := {"id": "liner", "name": "Liner", "description": "", "effects": [
		{"trigger": "on_hull_damage", "effect": "add_shield", "value": 10},
		{"trigger": "on_hull_damage", "effect": "vent_heat", "value": 5}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 20, 200)
	m.shield = 0
	m.grant_passive(liner)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.mechs[0].heat = 20
	sk.assign(0, g)
	sk.end_round()
	assert_eq(m.hull, 190, "the blow reached bare hull")
	assert_eq(m.shield, 0, "and stood no shield up: one at nothing is broken until its machine reboots, whatever would raise it")
	assert_eq(sk.mechs[0].heat, 15, "and shed heat")
	assert_true("\n".join(sk.log).contains("A: -5 heat from the hit"), "the log says so")
	# Hull damage behind a shield that stands (a cost of the machine's own): the shield half lands.
	var s2 := Skirmish.new(1)
	var cost := Face.shield(5)
	cost.volatile = 10
	var m2 := _mech("B", Die.single(cost), 40, 200)
	m2.shield = 10
	m2.grant_passive(liner)
	s2.add_mech(m2)
	s2.add_foes([_ghoul(500, 1)])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, null), "a volatile shield raised: hull damage with the shield standing")
	assert_eq(m2.shield, 25, "the entry's five and the liner's ten on a shield that stands")


func test_a_status_granted_on_shielding_lands_on_the_ally() -> void:
	# on_shield_granted's stack_status landed on the shielder until 9 October (the Phase
	# Conjugator's Braced is for the ally).
	var conj := {"id": "conj", "name": "Conjugator", "description": "", "effects": [
		{"trigger": "on_shield_granted", "effect": "stack_status", "value": "braced"}]}
	var sk := Skirmish.new(1)
	var giver := _mech("Giver", Die.single(Face.shield(20)), 40, 100)
	var taker := _mech("Taker", Die.single(Face.attack(10, L)), 50, 100)
	giver.grant_passive(conj)
	sk.add_mech(giver)
	sk.add_mech(taker)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.mechs[1]), "shield the ally")
	assert_eq(Effects.stacks_of(taker, "braced"), 1, "the ally is Braced")
	assert_eq(Effects.stacks_of(giver, "braced"), 0, "the shielder is not")
	assert_eq(taker.armour, int(Effects.STATUS["braced"]["effects"][0]["value"]), "and the ally's armour reads it")
	assert_true("\n".join(sk.log).contains("Taker: Giver's escort, Armoured"), "the log names it")


func test_a_massive_foe_that_is_no_boss_lands_a_plain_blow() -> void:
	# Big is an attribute of any tier (the bible's tiers row, 15 October): the plaque's mark
	# follows the content's boss, so a big elite's plain blow announces nothing.
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var big := _ghoul(100, 10)
	big.size = 2
	sk.add_foes([big])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(sk.turn_events.size(), 1, "one blow this turn")
	assert_false(bool(sk.turn_events[0]["boss"]), "a massive foe is no boss by its size")


func test_the_replay_hears_specials_and_the_names_of_blows_in_order() -> void:
	# The plaque (decided 9 October): a special is recorded beside the blows with a shared
	# order, and every blow carries its move's name and whether a boss struck.
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var bracer := _ghoul(100, 10)
	bracer.actions = [_special("defend", "brace", {"value": 10})]
	bracer.action = bracer.actions[0]
	var striker := _ghoul(100, 10)
	striker.boss = true   # human-sized: a boss is the content's word, never its size (15 October)
	sk.add_foes([bracer, striker])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(sk.turn_specials.size(), 1, "one special this turn")
	assert_eq(str(sk.turn_specials[0]["name"]), "Brace", "it carries the move's name")
	assert_eq(str(sk.turn_specials[0]["kind"]), "defend", "and its kind")
	assert_eq(sk.turn_events.size(), 1, "one blow this turn")
	assert_eq(str(sk.turn_events[0]["name"]), "Attack", "the blow carries its move's name")
	assert_true(bool(sk.turn_events[0]["boss"]), "and that a boss struck, human-sized")
	var spec_seq := int(sk.turn_specials[0]["seq"])
	var blow_seq := int(sk.turn_events[0]["seq"])
	assert_true(spec_seq != blow_seq, "one order for both lists")
	assert_eq(spec_seq < blow_seq, sk.front[0] == bracer, "whoever stands left acts first, and the order says so")
	sk.start_round()
	sk.end_round()
	assert_eq(sk.turn_specials.size(), 1, "the lists start over each turn")


func test_a_self_destructing_blow_lands_and_spends_the_striker() -> void:
	# The Bomb (decided 9 October): its blow is its whole life, and nothing brings it back.
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(m)
	var bomb := _ghoul(30, 20)
	bomb.actions = [{"id": "burst", "name": "Self-Destruct", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": ["self_destruct"], "text": ""}]
	bomb.action = bomb.actions[0]
	Effects.stack(bomb, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)   # readied to get back up: the burst still keeps it down
	sk.add_foes([bomb])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 80, "the blow landed")
	assert_false(bomb.alive(), "and the striker is spent")
	assert_true(bomb.stays_down, "never to get back up")
	assert_eq(sk.front[0], null, "its slot is clear")
	assert_eq(sk.reinforcements.size(), 0, "and it did not return to the pool")
	assert_true("\n".join(sk.log).contains("bursts, and is gone"), "the log says so")
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "the fight is won by its own blow")


func _storm(atk: int, strikes: int, keywords: Array) -> Foe:
	var f := Foe.make("storm", 500, atk)
	f.actions = [{"id": "storm", "name": "Needle Storm", "kind": "attack", "factor": 1.0, "strikes": strikes, "weight": 1, "keywords": keywords, "text": ""}]
	f.action = f.actions[0]
	return f


func test_a_blow_at_every_machine_lands_on_each_with_its_riders() -> void:
	# Ryan, 15 October: no foe struck more than one machine; `all` lands the blow on every one.
	var sk := Skirmish.new(1, 1)
	var bare := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	var shielded := _mech("B", Die.single(Face.attack(10, L)), 10, 100)
	var third := _mech("C", Die.single(Face.attack(10, L)), 0, 100)
	for m in [bare, shielded, third]:
		sk.add_mech(m)
	var storm := _storm(20, 2, ["all", "scorch"])
	sk.add_foes([storm])
	sk.begin()
	sk.start_round()
	for i in range(3):
		assert_true(sk.attackers_of(sk.mechs[i]).has(storm), "machine %d is struck, whichever the pick named" % i)
		assert_eq(sk.incoming_for(sk.mechs[i]), 40, "and each takes both blows")
	assert_eq(sk.forecast(sk.mechs[1])["hull_after"], 70, "a shield takes ten of the first blow on its own machine and no other")
	sk.end_round()
	assert_eq(bare.hull, 60, "both blows on the bare machine")
	assert_eq(shielded.shield, 0, "the shield took ten of the first")
	assert_eq(shielded.hull, 70, "ten of it passed, and the second reached the hull whole")
	assert_eq(third.hull, 60, "both on the third")
	for m in [bare, shielded, third]:
		assert_eq(Effects.stacks_of(m, "scorched"), 2, "each strike's rider lands on each machine")
	var order: Array = sk.turn_events.map(func(ev): return int(ev["mech"]))
	assert_eq(order, [0, 0, 1, 1, 2, 2], "machine by machine, left to right")
	assert_true(sk.turn_events.all(func(ev): return bool(ev["all"])), "each blow says it struck every machine, for the plaque")
	# A wreck is out of it: the blow lands on the live machines only.
	third.hull = 0
	sk.start_round()
	sk.end_round()
	assert_eq(sk.turn_events.size(), 4, "two blows on each of the two left")


func test_no_lure_turns_a_blow_at_every_machine_and_a_suppress_stops_it_whole() -> void:
	var sk := Skirmish.new(1, 1)
	var tank := _mech("Tank", Die.single(Face.attack(0, L, K.LURE)), 0, 100)
	var glass := _mech("Glass", Die.single(Face.attack(0, L)), 0, 100)
	sk.add_mech(tank)
	sk.add_mech(glass)
	var storm := _storm(20, 1, ["all"])
	sk.add_foes([storm])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, storm), "the tank sounds its klaxon at it")
	assert_true("\n".join(sk.log).contains("lured, but storm has nothing to turn"), "the log says the lure moved nothing")
	assert_eq(sk.incoming_for(sk.mechs[1]), 20, "the glass still takes the blow")
	sk.end_round()
	assert_eq(tank.hull, 80, "the tank took it")
	assert_eq(glass.hull, 80, "and so did the glass")
	var s2 := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(10, L)), 0, 100)
	s2.add_mech(a)
	s2.add_mech(b)
	var numbed := _storm(20, 1, ["all"])
	s2.add_foes([numbed])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, numbed), "suppressed")
	assert_true(s2.acting_on(s2.mechs[1]).is_empty(), "a suppressed storm acts on nobody")
	s2.end_round()
	assert_eq(a.hull, 100, "the suppressing machine is untouched")
	assert_eq(b.hull, 100, "and so is the other")


func test_a_bursting_blow_at_every_machine_lands_on_each_and_spends_the_striker_once() -> void:
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var bomb := _storm(20, 1, ["all", "self_destruct"])
	sk.add_foes([bomb])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(a.hull, 80, "the burst reached the first")
	assert_eq(b.hull, 80, "and the second")
	assert_false(bomb.alive(), "the striker is spent")
	assert_eq("\n".join(sk.log).count("bursts, and is gone"), 1, "once, after every machine took it")


func test_a_countdown_blow_at_every_machine_gathers_then_lands_on_each() -> void:
	# The Augur's Harvest (16 October): a countdown and `all` on one move, announced one round and
	# landing on every machine the next.
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(10, L)), 10, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var augur := Foe.make("augur", 500, 20)
	augur.actions = [{"id": "harvest", "name": "Harvest", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": ["all"], "countdown": 1, "text": ""}]
	augur.action = augur.actions[0]
	sk.add_foes([augur])
	sk.begin()
	sk.start_round()
	assert_true(augur.gathering(), "announced, it gathers")
	assert_false(augur.hits_all(), "and strikes nobody yet")
	assert_true(augur.reaches_every_machine(), "though its arrows already reach every machine")
	assert_eq(sk.incoming_for(sk.mechs[0]) + sk.incoming_for(sk.mechs[1]), 0, "nothing lands this round")
	sk.end_round()
	assert_eq(a.hull + b.hull, 200, "and nothing did")
	sk.start_round()
	assert_true(augur.hits_all(), "the next round it lands on every machine")
	assert_eq(sk.incoming_for(sk.mechs[0]), 20, "the forecast counts it on the first")
	assert_eq(sk.incoming_for(sk.mechs[1]), 20, "and on the second")
	sk.end_round()
	assert_eq(a.hull, 80, "the bare machine took it")
	assert_eq(b.shield, 0, "the shield took ten of the other's")
	assert_eq(b.hull, 90, "and ten passed")
	assert_true(augur.pending.is_empty(), "spent")


func _gatherer(atk: int, countdown: int) -> Foe:
	var f := Foe.make("lancer", 500, atk)
	f.actions = [{"id": "jump", "name": "Jump", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "countdown": countdown, "text": ""}]
	f.action = f.actions[0]
	return f


func test_a_countdown_move_gathers_a_round_then_lands() -> void:
	# The Lancer's Jump (15 October): announced as the round opens, it lands the next.
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(a)
	var lancer := _gatherer(30, 1)
	sk.add_foes([lancer])
	sk.begin()
	sk.start_round()
	assert_true(lancer.gathering(), "announced, it gathers")
	assert_eq(sk.incoming_for(sk.mechs[0]), 0, "nothing lands this round")
	sk.end_round()
	assert_eq(a.hull, 100, "and nothing did")
	assert_true(sk.turn_specials.any(func(s): return str(s["kind"]) == "charge" and str(s["name"]) == "Jump"), "the plaque names it as it begins")
	sk.start_round()
	assert_false(lancer.gathering(), "the next round it lands")
	assert_eq(sk.incoming_for(sk.mechs[0]), 30, "and the forecast says so")
	sk.end_round()
	assert_eq(a.hull, 70, "it landed")
	assert_true(lancer.pending.is_empty(), "spent")


## A foe whose blow climbs for a round and then stoops (the Roc's Stoop, built as a test's own),
## alone on its list or beside a plain blow.
func _climber(hp: int = 60, atk: int = 10, plain: bool = false) -> Foe:
	var f := Foe.make("revenant", hp, atk)
	f.actions = [{"id": "stoop", "name": "Stoop", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "countdown": 1, "aloft": true, "text": ""}]
	if plain:
		f.actions.append({"id": "talons", "name": "Talons", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": ""})
	f.action = f.actions[0]
	return f


## The Roc's climb (Ryan, 16 November: "I think the stoop can make it untargetable, yes"): the
## round its stoop is announced it is a target like any, which is the window. As it begins to
## gather it is Aloft, and through the player's next turn no die may be dropped on it. It comes
## down as the stoop lands.
func test_a_foe_that_climbs_is_no_target_while_its_blow_gathers() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(5, I)), 0, 100)
	sk.add_mech(a)
	var roc := _climber()
	var other := _ghoul(500, 0)
	sk.add_foes([roc, other])
	sk.begin()
	sk.start_round()
	assert_true(roc.gathering(), "announced, it gathers")
	assert_false(Skirmish.out_of_reach(roc), "the round the climb is announced it is still on the ground")
	assert_true(sk.targets_for(0).has(roc), "and a target like any: the window")
	sk.end_round()
	assert_true(Effects.has(roc, "aloft"), "as it begins to gather it climbs")
	assert_true("\n".join(sk.log).contains("climbs out of reach"), "the log says so")
	sk.start_round()
	assert_true(Skirmish.out_of_reach(roc), "through the player's next turn it is out of the dice's reach")
	assert_false(sk.targets_for(0).has(roc), "no die may be dropped on it")
	assert_true(sk.targets_for(0).has(other), "the foe beside it is a target as ever")
	assert_false(sk.assign(0, roc), "and a spend at it is refused")
	assert_eq(roc.hp, 60, "so nothing aimed touched it")
	var hull := a.hull
	sk.end_round()
	assert_eq(hull - a.hull, 10, "its stoop lands")
	assert_false(Effects.has(roc, "aloft"), "and it is back in reach")
	sk.start_round()
	assert_true(sk.targets_for(0).has(roc), "the round after, announcing again, it is a target once more")
	var trip := SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(_climber(), sk))), sk)
	assert_true(Foe.climbs(trip.actions[0]), "a save keeps the move that climbs")


## Aloft is not Phased (Ryan, 16 November: "it should still take damage from its riders, unlike
## phased. So it's different, should be a different buff"): what the foe carries still wears at
## it. And nothing new reaches it, with an aim or without (17 November: "the roc doesn't get
## splashed while aloft"): a neighbour's Spread, a blow at every foe, a Chain's arc, a Mine's
## blast beside it, a spill and a shove from the foe in front all pass it by.
func test_a_foe_aloft_takes_what_it_carries_and_nothing_that_lands_elsewhere() -> void:
	var sk := Skirmish.new(1, 2)
	var sweep := Face.attack(20, I, K.CLEAVE)
	sweep.cleave = 10
	sk.add_mech(_mech("A", Die.single(sweep), 0, 100))
	sk.add_mech(_mech("B", Die.single(Face.attack(6, E)), 0, 100))
	var roc := _climber()
	var other := _ghoul(500, 0)
	sk.add_foes([roc, other])
	sk.begin()
	sk.start_round()
	Effects.stack(roc, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	sk.end_round()
	assert_true(Skirmish.out_of_reach(roc), "it has climbed")
	var after_first := roc.hp
	assert_true(after_first < 60, "its Ablating took its points as its turn ended, climb or no (%d)" % after_first)
	sk.start_round()
	assert_false(sk.reached_by(sweep, other).has(roc), "a Spread on the foe beside it does not reach it")
	assert_false(sk.area_shapes(sweep, other).has(roc), "and no shape of the spend holds it")
	assert_true(sk.assign(0, other), "the Spread, dropped beside it")
	assert_eq(roc.hp, after_first, "passes it by")
	assert_true(sk.targets_for(1).has(other) and not sk.targets_for(1).has(roc), "a blow at every foe is dropped on a foe in reach")
	assert_true(sk.assign(1, other), "and dropped there")
	assert_eq(roc.hp, after_first, "it lands on every foe but the climber")
	assert_true(sk.web_catch(other) == null, "a web on the foe beside it catches nobody, the climber its one neighbour")
	var before_tick := roc.hp
	sk.end_round()
	assert_true(roc.hp < before_tick, "and what it carries wears at it again as its turn ends")
	# A Chain's arc, a Mine's blast beside it and a web's catch pass it by; a Mine it carries
	# itself is its own.
	var s2 := Skirmish.new(1, 3)
	s2.add_mech(_mech("A", Die.single(Face.attack(5, I)), 0, 100))
	var r2 := _climber()
	s2.add_foes([r2, _ghoul(500, 0), _ghoul(500, 0)])
	s2.begin()
	s2.start_round()
	s2.end_round()
	s2.start_round()
	assert_true(Skirmish.out_of_reach(r2), "aloft")
	assert_eq(r2.column, 0, "the heaviest hitter stands left")
	var next_to: Foe = s2.front[1]
	var far: Foe = s2.front[2]
	Effects.stack(r2, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1)
	assert_false(s2.conducting_foes(null).has(r2), "Shocked, it conducts no arc")
	var blast := s2.mine_reach(next_to.rank, next_to.column, false)
	assert_true(blast.has(next_to) and blast.has(far) and not blast.has(r2), "a Mine blowing beside it reaches the foes in reach and passes it by")
	assert_true(s2.mine_reach(r2.rank, r2.column, false).has(r2), "a Mine it carries blows on it: what it carries is its own")
	assert_eq(s2.web_catch(next_to), far, "a web on the foe beside it catches the foe on the other side")


## Nothing breaks off a climb once it is up: a Disrupt over every foe passes the climber by, as
## every spend with no aim does, so the round the climb is announced is the window.
func test_a_disrupt_over_every_foe_passes_a_climber_by() -> void:
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(1, E, K.DISRUPT)), 0, 100))
	sk.add_mech(_mech("B", Die.single(Face.attack(5, I)), 0, 100))
	var roc := _climber(60, 10, true)
	var other := _ghoul(500, 0)
	sk.add_foes([roc, other])
	sk.begin()
	sk.start_round()
	roc.action = roc.actions[0]
	roc.pending = roc.action
	roc.charge = 1
	sk.end_round()
	sk.start_round()
	assert_true(Skirmish.out_of_reach(roc), "it has climbed, its stoop coming")
	assert_true(sk.assign(0, other), "a Disrupt over every foe, dropped on the foe beside it")
	assert_true(Effects.has(roc, "aloft"), "does not reach it: it is still up")
	assert_eq(str(roc.action.get("id", "")), "stoop", "and its stoop still comes")
	assert_false(sk.targets_for(1).has(roc), "no die may be dropped on it this turn")


## An immunity (Ryan, 15 November: "not as a blanket for all bosses, but for ones who need it for
## their fight to actually do something"), a foe's own Ability. A Suppress never lands on a foe
## immune to it, from a die, a web or a Paradox, and it gains no Numbed for it. A Disrupt never
## turns a foe from the move its immunity names while that move gathers, from the round it is
## announced to the round it lands; a Suppress still holds it a round. The die's own mark is
## struck over a foe it will do nothing to, and the bot prices neither.
func test_an_immune_foe_takes_no_stun_and_a_gather_it_is_immune_through_is_not_turned() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(1, L, K.SUPPRESS)), 0, 500)
	var b := _mech("B", Die.single(Face.blank()), 0, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var walker := _ghoul(500, 5)
	walker.immune = {"suppress": true}
	var plain := _ghoul(500, 5)
	sk.add_foes([walker, plain])
	sk.begin()
	sk.start_round()
	assert_true(walker.immune_to("suppress") and not walker.immune_to("disrupt"), "immune to the stun, and to nothing else")
	assert_true(sk.shut_gates(sk.mechs[0], sk.mechs[0].face(), walker).has(K.SUPPRESS), "the die's Suppress is struck over it")
	assert_false(sk.shut_gates(sk.mechs[0], sk.mechs[0].face(), plain).has(K.SUPPRESS), "and open over any other foe")
	assert_false(Policy.web_stuns(walker), "the bot reads no stun on it")
	assert_true(Policy.web_stuns(plain), "and one on a foe that takes it")
	assert_true(sk.assign(0, walker), "the stun, dropped on it all the same")
	assert_eq(walker.hp, 499, "its blow lands")
	assert_false(walker.is_suppressed(), "and its stun lands nothing")
	assert_eq(Effects.stacks_of(walker, "numbed"), 0, "with no Numbed for it: nothing was resisted")
	assert_true("\n".join(sk.log).contains("is immune"), "the log says why: %s" % sk.log[sk.log.size() - 1])
	assert_false(sk._suppress(walker, null, true), "a web's burst stuns it no more than a die does")
	var hull := a.hull + b.hull
	sk.end_round()
	assert_eq(hull - (a.hull + b.hull), 10, "it strikes, as the foe beside it does")
	var trip := SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(walker, sk))), sk)
	assert_true(trip.immune_to("suppress"), "a save keeps the immunity")
	# A gather its foe is immune through.
	var s2 := Skirmish.new(1, 2)
	s2.add_mech(_mech("A", Die.single(Face.attack(1, L, K.DISRUPT)), 0, 500))
	s2.add_mech(_mech("B", Die.single(Face.attack(1, L, K.SUPPRESS)), 0, 500))
	var tyrant := _ghoul(500, 5)
	tyrant.actions = [{"id": "storm", "name": "Storm", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1000, "keywords": [], "countdown": 2, "text": ""}, Foe.basic_action()]
	tyrant.action = tyrant.actions[1]
	tyrant.immune = {"disrupt": "storm"}
	assert_false(tyrant.immune_to("disrupt"), "gathering nothing, it is immune to nothing")
	s2.add_foes([tyrant])
	s2.begin()
	s2.start_round()
	assert_eq(str(tyrant.action.get("id", "")), "storm", "it announces its storm, at that weight")
	assert_true(tyrant.immune_to("disrupt"), "and is immune from the round the storm is announced")
	assert_true(s2.shut_gates(s2.mechs[0], s2.mechs[0].face(), tyrant).has(K.DISRUPT), "the die's Disrupt is struck over it")
	assert_eq(Policy.disrupt_score(s2, tyrant), 0.0, "and the bot prices none")
	assert_true(s2.assign(0, tyrant), "a Disrupt dropped on it")
	assert_eq(str(tyrant.action.get("id", "")), "storm", "turns nothing")
	assert_eq(tyrant.charge, 2, "and breaks nothing off")
	assert_true("\n".join(s2.log).contains("no Disrupt turns it"), "the log says why: %s" % s2.log[s2.log.size() - 1])
	assert_true(s2.assign(1, tyrant), "a Suppress still lands")
	assert_true(tyrant.is_suppressed(), "and holds the storm a round")
	s2.end_round()
	assert_eq(tyrant.charge, 2, "held: the count has not moved")
	s2.start_round()
	s2.end_round()
	s2.start_round()
	assert_eq(tyrant.charge, 1, "then it gathers on")
	assert_true(tyrant.immune_to("disrupt"), "immune still, the round before it lands")
	s2.end_round()
	s2.start_round()
	s2.end_round()
	tyrant.pending = {}
	tyrant.action = tyrant.actions[1]
	assert_false(tyrant.immune_to("disrupt"), "and once the storm has landed, no longer")


## A foe whose blow fades it (the Spectre's Hex Bolt, a blow and then a step, `phase`), built
## as a test's own.
func _fader(hp: int = 60, atk: int = 5) -> Foe:
	var f := Foe.make("fader", hp, atk)
	f.content_id = "fader"
	f.actions = [{"id": "bolt", "name": "Bolt", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": "",
		"also": Foe.also_from([{"effect": "phase"}], "Bolt")}]
	f.action = f.actions[0]
	return f


## A foe's Phased (Ryan, 15 November: "I think we give this to the foes too"; 16 November:
## "Phased foes act"; his yes of 17 November to the ghosts' row: "After Hex Bolt it fades:
## Phased through the next round, and it still acts"). The round its bolt lands it stands
## solid, the window. As that round ends it fades. Through the next nothing of the team's
## reaches it, with an aim or without, and nothing it carries damages it while its clocks run;
## it acts all the same. It is back as that round ends, and never out two rounds running.
func test_a_foe_that_fades_is_out_of_reach_for_a_round_and_acts_all_the_same() -> void:
	var sk := Skirmish.new(1, 2)
	var sweep := Face.attack(20, I, K.CLEAVE)
	sweep.cleave = 10
	var a := _mech("A", Die.single(sweep), 0, 500)
	var b := _mech("B", Die.single(Face.attack(6, E)), 0, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var ghost := _fader()
	var other := _ghoul(500, 0)
	sk.add_foes([ghost, other])
	sk.begin()
	sk.start_round()
	assert_false(Skirmish.out_of_reach(ghost), "the round it throws its bolt it stands solid: the window")
	assert_true(sk.targets_for(0).has(ghost), "and is a target like any")
	Effects.stack(ghost, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	var hull := a.hull + b.hull
	sk.end_round()
	assert_true(Skirmish.foe_phased(ghost), "as the round its bolt landed in ends, it fades")
	assert_eq(hull - (a.hull + b.hull), 5, "its bolt landed first")
	var solid_hp := ghost.hp
	assert_true(solid_hp < 60, "and its Ablating took its points that turn: it stands through the round first (%d)" % solid_hp)
	sk.start_round()
	assert_true(ghost.intends(), "Phased, it announces a move like any")
	assert_false(sk.targets_for(0).has(ghost) or sk.targets_for(1).has(ghost), "no die may be dropped on it")
	assert_false(sk.assign(0, ghost), "and a spend at it is refused")
	assert_true(sk.assign(0, other), "a Spread on the foe beside it")
	assert_true(sk.assign(1, other), "and a blow at every foe")
	assert_eq(ghost.hp, solid_hp, "both pass it by")
	assert_eq(sk.hp_after_ticks(ghost), solid_hp, "and its gauge forecasts no loss to what it carries")
	var stacks := Effects.stacks_of(ghost, "ablating")
	hull = a.hull + b.hull
	sk.end_round()
	assert_eq(hull - (a.hull + b.hull), 5, "it acts all the same: its bolt lands")
	assert_eq(ghost.hp, solid_hp, "what it carries takes nothing while it is Phased")
	assert_true(Effects.stacks_of(ghost, "ablating") < stacks, "and its clock runs all the same (%d to %d)" % [stacks, Effects.stacks_of(ghost, "ablating")])
	assert_false(Skirmish.foe_phased(ghost), "as that round ends it is back, and the bolt it threw while Phased faded nothing: never two rounds running")
	sk.start_round()
	assert_true(sk.targets_for(0).has(ghost), "solid again, a target once more")
	sk.end_round()
	assert_true(Skirmish.foe_phased(ghost), "and its next bolt fades it again: every other round")


## The last foe standing does not fade, so a fight has a foe to end on; and a foe's Phased is
## less strict than a machine's (Ryan, 15 November: "Phased on foes can be less strict since it's
## balanced around their kit and theme"): its own side still reaches it, a rally's Empowered
## among it.
func test_the_last_foe_standing_does_not_fade_and_its_own_side_still_reaches_one_that_has() -> void:
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(Face.blank()), 0, 500))
	var lone := _fader()
	sk.add_foes([lone])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_false(Skirmish.foe_phased(lone), "alone, it throws its bolt and stays")
	assert_false(Effects.has(lone, "phasing"), "and the wait is gone with the round")
	assert_true("\n".join(sk.log).contains("the last one standing"), "the log says why: %s" % sk.log[sk.log.size() - 1])
	var s2 := Skirmish.new(1, 2)
	s2.add_mech(_mech("A", Die.single(Face.blank()), 0, 500))
	var ghost := _fader()
	var caller := _ghoul(500, 0)
	caller.actions = [_special("buff", "rally", {"value": 2})]
	caller.action = caller.actions[0]
	s2.add_foes([ghost, caller])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_true(Skirmish.foe_phased(ghost), "with another foe standing it fades")
	Effects.remove(ghost, "kindled")
	s2.start_round()
	s2.end_round()
	assert_true(s2.log.any(func(line) -> bool: return str(line).contains("hit 2 harder")), "the rally is called while it is Phased")
	assert_true(Effects.has(ghost, "kindled"), "and reaches it with the rest of its side")
	# The wait is a foe's own move too, and a Phased foe gains no second.
	var s3 := Skirmish.new(1, 2)
	s3.add_mech(_mech("A", Die.single(Face.blank()), 0, 500))
	var veil := _ghoul(500, 0)
	veil.actions = [_special("defend", "phase")]
	veil.action = veil.actions[0]
	s3.add_foes([veil, _ghoul(500, 0)])
	s3.begin()
	s3.start_round()
	assert_true(veil.acts_on_nobody() and veil.target == null, "a move on itself: no pick")
	s3.end_round()
	assert_true(Skirmish.foe_phased(veil), "a move of its own fades it as a step does")
	s3.start_round()
	s3.end_round()
	assert_false(Skirmish.foe_phased(veil), "and cast again while Phased it adds nothing: back the round after")
	assert_true("\n".join(s3.log).contains("cannot fade again so soon"), "the log says so")


func test_a_longer_countdown_holds_its_pick_and_a_suppress_holds_its_blow() -> void:
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var walker := _gatherer(20, 2)
	sk.add_foes([walker])
	sk.begin()
	sk.start_round()
	var picked = walker.target
	assert_eq(walker.charge, 2, "two rounds to go")
	sk.end_round()
	sk.start_round()
	assert_eq(walker.target, picked, "the pick holds while it gathers")
	assert_eq(walker.charge, 1, "one to go")
	sk.end_round()
	sk.start_round()
	assert_false(walker.gathering(), "it lands this round")
	assert_true(sk.assign(0, walker), "unless a suppress lands first")
	sk.end_round()
	assert_eq(a.hull + b.hull, 200, "suppressed, it held its blow")
	assert_false(walker.pending.is_empty(), "and holds it still")
	sk.start_round()
	assert_eq(walker.action.get("id", ""), "jump", "the held move, not a new pick")
	sk.end_round()
	assert_eq(a.hull + b.hull, 180, "the next round it lands")


func test_a_disrupt_breaks_off_a_gathering_move() -> void:
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.attack(0, L, K.DISRUPT)), 0, 100)
	sk.add_mech(a)
	var lancer := _gatherer(30, 1)
	lancer.actions.append({"id": "thrust", "name": "Thrust", "kind": "attack", "factor": 0.5, "strikes": 1, "weight": 1, "keywords": [], "text": ""})
	sk.add_foes([lancer])
	sk.begin()
	sk.start_round()
	lancer.action = lancer.actions[0]
	lancer.pending = lancer.action
	lancer.charge = 1
	assert_true(sk.assign(0, lancer), "disrupted while it gathers")
	assert_true(lancer.pending.is_empty(), "the jump is broken off")
	assert_eq(lancer.action.get("id", ""), "thrust", "its other move instead")
	sk.end_round()
	assert_eq(a.hull, 85, "the thrust lands this round")
	# A fight saved mid-gather resumes with the count.
	var held := _gatherer(30, 2)
	held.pending = held.actions[0]
	held.charge = 2
	var back := SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(held, sk))), sk)
	assert_true(back.gathering(), "the save keeps the move gathering")
	assert_eq(back.charge, 2, "and its count")
	assert_eq(Foe.countdown_of(back.pending), 2, "a whole number")


## A cleanse that follows a heal in one move has the heal's patient (the Cleric's Cure, Ryan's
## yes of 17 November: "Cure heals 4, then cleanses the same foe"), whoever else carries more
## marks; a cleanse of its own still finds the most marked.
func test_a_cleanse_after_a_heal_lands_on_the_foe_it_mended() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var healer := Foe.make("mage", 60, 10, true)
	healer.actions = [{"id": "cure", "name": "Cure", "kind": "defend", "effect": "heal", "value": 20, "weight": 1, "text": "",
		"also": Foe.also_from([{"effect": "cleanse"}], "Cure")}]
	healer.action = healer.actions[0]
	var hurt := _ghoul(100, 10)
	var marked := _ghoul(100, 10)
	sk.add_foes([hurt, marked, healer])
	sk.begin()
	hurt.hp = 50
	Effects.stack(hurt, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 1)
	Effects.stack(marked, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 4)
	Effects.stack(marked, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 2)
	sk.start_round()
	assert_eq(sk.cleanse_target(healer), marked, "a cleanse of its own would find the most marked")
	sk.end_round()
	assert_eq(hurt.hp, 70, "the most hurt is mended")
	assert_false(Effects.has(hurt, "brittled"), "and the same foe is cleansed")
	assert_true(Effects.has(marked, "brittled") and Effects.has(marked, "cryoed"), "the more marked foe keeps its marks: one patient a Cure")
	# With nobody hurt the heal mends nobody, and the cleanse goes by its own rule.
	hurt.hp = hurt.hp_max
	sk.start_round()
	sk.end_round()
	assert_false(Effects.has(marked, "cryoed"), "no patient, so the step is a cleanse like any: the most marked")


## The one fall that pays the team (the Lich's, Ryan's yes of 17 November: "Killed, every foe it
## readied loses its readiness to rise"): every foe still standing loses the Undying the fallen
## foe's kind gave it. What a foe readied for itself stays, and one felled by the same blow
## had its readiness as it fell, so it gets up.
func test_a_fall_takes_back_the_readiness_its_foe_gave() -> void:
	var sk := Skirmish.new(1, 4)
	var sweep := Face.attack(200, I, K.CLEAVE)
	sweep.cleave = 200
	sk.add_mech(_mech("A", Die.single(sweep), 0, 500))
	var binder := Foe.make("binder", 10, 0)
	binder.content_id = "binder"
	binder.on_death = {"act": Foe.fall_act_from({"name": "Unbound", "effect": "unready_all"})}
	var readied := _ghoul(500, 0)
	var own := _ghoul(500, 0)
	own.content_id = "knight"
	var beside := _ghoul(10, 0)
	sk.add_foes([beside, binder, readied, own])
	sk.begin()
	Effects.stack(readied, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:binder", 1, Effects.DECAY_NONE)
	Effects.stack(beside, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:binder", 1, Effects.DECAY_NONE)
	Effects.stack(own, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:knight", 1, Effects.DECAY_NONE)
	sk.start_round()
	assert_true(absi(binder.column - beside.column) == 1 and binder.rank == beside.rank, "the binder stands beside a foe it readied")
	assert_true(sk.assign(0, binder), "a blow that fells the binder and the foe beside it")
	assert_false(binder.alive(), "the binder falls")
	assert_false(Effects.has(readied, "risen"), "what it readied will not get back up")
	assert_true(Effects.has(own, "risen"), "a foe that readied itself keeps its own")
	assert_true(beside.alive() and beside.hp == beside.hp_max, "and the foe felled with it fell readied: it gets up")
	assert_true("\n".join(sk.log).contains("will not get back up"), "the log says who lost it: %s" % sk.log[sk.log.size() - 1])
	assert_true(Foe.FALL_EFFECTS.has("unready_all") and Foe.UNTARGETED_EFFECTS.has("unready_all"), "a fall's effect, aimed at no machine")


func test_a_healer_cures_the_most_hurt_of_its_own() -> void:
	# The Cleric's Cure (15 October): foes helping foes.
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var healer := Foe.make("mage", 60, 10, true)
	healer.actions = [{"id": "cure", "name": "Cure", "kind": "defend", "effect": "heal", "value": 20, "weight": 1, "when": ["ally_hurt"], "text": ""}]
	healer.action = healer.actions[0]
	var hurt := _ghoul(100, 10)
	var scratched := _ghoul(100, 10)
	sk.add_foes([hurt, scratched, healer])
	sk.begin()
	hurt.hp = 50
	scratched.hp = 90
	sk.start_round()
	assert_eq(str(healer.action.get("id", "")), "cure", "one of its own is hurt, so it may cure")
	sk.end_round()
	assert_eq(hurt.hp, 70, "the most hurt regrew twenty")
	assert_eq(scratched.hp, 90, "and nobody else")
	var whole := Skirmish.new(1, 3)
	whole.add_mech(_mech("B", Die.single(Face.attack(10, L)), 40, 100))
	var idle := Foe.make("mage", 60, 10, true)
	idle.actions = [{"id": "cure", "name": "Cure", "kind": "defend", "effect": "heal", "value": 20, "weight": 1, "when": ["ally_hurt"], "text": ""}, Foe.basic_action()]
	whole.add_foes([_ghoul(100, 10), idle])
	whole.begin()
	assert_false(whole.legal_actions(idle).has(idle.actions[0]), "with none of its own hurt it has no cure to cast")


## Armoured runs one clock on both sides (Ryan, 15 November: "The common "end" state between both
## sides is "start of their next turn""): a foe's plate goes as the foes' next turn opens, before
## the first of them acts, where it went at its own action and a late foe wore it through the
## blasts of the foes before it; and a Protect cast in a turn stands on the foes acting after its
## caster, to go with the rest as the next turn opens.
func test_a_foes_armour_ends_as_the_foes_next_turn_opens() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.shield(10)), 400, 400))
	var fuse := _ghoul(50, 0)
	var late := _ghoul(100, 0)
	late.actions = [_special("defend", "brace", {"value": 3})]
	late.action = late.actions[0]
	sk.add_foes([fuse, late])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(late.armour_total(), 3, "braced, through the player's turn")
	sk.start_round()
	late.actions = [Foe.basic_action()]
	late.action = late.actions[0]
	fuse.hp = 2
	Effects.stack(fuse, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	sk._add_mine(fuse, 5, {"stacks": {}, "keywords": []})
	sk.end_round()
	assert_false(fuse.alive(), "the foe before it fell to its tick, and its Mine blew")
	assert_eq(late.hp, 95, "on a foe whose plate had gone as the turn opened: the blast lands whole, where its own action had not yet come")
	assert_false(Effects.has(late, "braced"), "and it wears none after")
	# A Protect: the foes acting after the caster keep it through the turn it is cast in.
	var s2 := Skirmish.new(1, 3)
	s2.add_mech(_mech("A", Die.single(Face.shield(10)), 400, 400))
	var caster := _ghoul(100, 0)
	caster.actions = [_special("defend", "brace_all", {"value": 2})]
	caster.action = caster.actions[0]
	var after := _ghoul(100, 0)
	s2.add_foes([caster, after])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq([caster.armour_total(), after.armour_total()], [2, 2], "the caster and the foe that acted after it, both plated past the turn")
	assert_true("\n".join(s2.log).contains("until their next turn"), "the log says the clock")
	caster.actions = [Foe.basic_action()]
	caster.action = caster.actions[0]
	s2.start_round()
	caster.action = caster.actions[0]
	s2.end_round()
	assert_eq([caster.armour_total(), after.armour_total()], [0, 0], "and gone from both as the next turn opened")


func test_protect_braces_every_foe_through_the_next_round() -> void:
	# The Cleric's Protect (15 October): a brace on every foe, gone as the foes' next turn
	# opens; Braced since 16 October, the move's value in stacks of armour +1.
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L)), 400, 400))
	var priest := Foe.make("priest", 60, 10, true)
	priest.actions = [{"id": "protect", "name": "Protect", "kind": "defend", "effect": "brace_all", "value": 10, "weight": 1, "when": ["others_on_field"], "text": ""}, Foe.basic_action()]
	priest.action = priest.actions[0]
	var g := _ghoul(100, 10)
	var h := _ghoul(100, 10)
	sk.add_foes([g, h, priest])
	sk.begin()
	sk.start_round()
	priest.action = priest.actions[0]
	priest.last_special = "protect"   # as announcing it would have, so it does not cast it twice running
	sk.end_round()
	assert_eq([Effects.stacks_of(g, "braced"), Effects.stacks_of(h, "braced"), Effects.stacks_of(priest, "braced")], [10, 10, 10], "every foe in the fight is Armoured, a stack an armour point of the 10")
	assert_eq(g.armour_total(), 10, "every foe in the fight is armoured")
	assert_eq(priest.armour_total(), 10, "the caster too")
	sk.start_round()
	assert_true(sk.assign(0, g), "through the player's turn")
	assert_eq(g.hp, 80, "a blow of thirty takes twenty")
	sk.end_round()
	assert_eq(g.armour_total(), 0, "and gone when the enemy has acted again")
	assert_false(Effects.has(h, "braced") or Effects.has(priest, "braced"), "from every foe")


func _core(guard: String, regrow: int = 0) -> Foe:
	var core := Foe.make("hilt", 200, 10)
	core.content_id = "hilt"
	core.part_ids = ["eye", "eye"]
	core.guard = guard
	core.regrow_parts = regrow
	return core


func _eye(id: String = "eye") -> Foe:
	var p := Foe.make(id, 20, 5)
	p.content_id = id
	return p


func _two_guns(sk: Skirmish) -> void:
	sk.add_mech(_mech("A", Die.single(Face.attack(30, I)), 40, 400))
	sk.add_mech(_mech("B", Die.single(Face.attack(30, I)), 40, 400))


func test_a_core_takes_nothing_while_all_its_parts_stand_and_opens_as_one_falls() -> void:
	# The boss in parts (Ryan, 15 October): Exor's hilt, untouchable until a part falls.
	var sk := Skirmish.new(1, 3)
	_two_guns(sk)
	var core := _core("all")
	var left := _eye()
	var right := _eye()
	sk.add_foes([core, left, right])
	sk.begin()
	sk.start_round()
	assert_true(Effects.has(core, "guarded"), "its parts stand, so it is guarded")
	assert_true(sk.assign(0, core), "a blow on it")
	assert_eq(core.hp, 200, "does nothing")
	assert_true(sk.assign(1, left), "a part falls")
	assert_false(Effects.has(core, "guarded"), "and the core is open at once: the guard needed every part")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(0, core), "so the next blow")
	assert_eq(core.hp, 170, "lands")


## Guarded takes no damage, its ticks included (Ryan, 8 November: "I wouldn't think so by
## definition"): a guarded core's Ablating and Vitriol take nothing off it and still fade a stack,
## and its gauge shows no loss to come.
func test_a_guarded_core_takes_nothing_from_its_ticks() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank()), 40, 400))
	var core := _core("all")
	sk.add_foes([core, _eye(), _eye()])
	sk.begin()
	sk.start_round()
	assert_true(Effects.has(core, "guarded"), "guarded while its parts stand")
	Effects.stack(core, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3, Effects.status_decay(Effects.STATUS["ablating"]))
	Effects.stack(core, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 2, Effects.status_decay(Effects.STATUS["vitriol"]))
	assert_eq(sk.hp_after_ticks(core), core.hp, "its gauge shows nothing coming off")
	sk.end_round()
	assert_eq(core.hp, 200, "its ticks took nothing")
	assert_eq([Effects.stacks_of(core, "ablating"), Effects.stacks_of(core, "vitriol")], [2, 1], "and each still faded a stack")
	assert_false("\n".join(sk.log).contains("hilt burns"), "nothing burns in the log")


## The die over a guarded core shows what lands, nothing (the audit's third bug, 8 November): it
## reads every add and multiply the foe takes but a Shocked doubling, its own chip; so does the
## bot.
func test_the_die_over_a_guarded_core_shows_nothing_and_the_bot_values_nothing() -> void:
	var sk := Skirmish.new(1, 3)
	_two_guns(sk)
	var core := _core("all")
	sk.add_foes([core, _eye(), _eye()])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_true(Effects.has(core, "guarded"), "guarded")
	assert_eq(sk.shown_number(ms, ms.face(), core), 0, "the die shows nothing over it")
	var best := 0.0
	for o in Policy.make(Policy.GREEDY).damage_outcomes(ms, ms.face(), core):
		best = maxf(best, float(o[0]))
	assert_eq(best, 0.0, "and the bot values hitting it at nothing")
	Effects.remove(core, "guarded")
	Effects.stack(core, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_eq(sk.shown_number(ms, ms.face(), core), 30, "open, the whole blow, its Shock left to its chip")


func test_an_any_guard_holds_until_the_last_part_falls() -> void:
	var sk := Skirmish.new(1, 3)
	_two_guns(sk)
	var core := _core("any")
	var left := _eye()
	var right := _eye()
	sk.add_foes([core, left, right])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, left), "one part falls")
	assert_true(Effects.has(core, "guarded"), "one still stands, so the guard holds")
	assert_true(sk.assign(1, right), "the other falls")
	assert_false(Effects.has(core, "guarded"), "and the core is open")


func _eye_factory(id: String) -> Foe:
	return _eye(id)


func test_a_fallen_part_grows_back_while_the_core_stands() -> void:
	var sk := Skirmish.new(1, 3)
	_two_guns(sk)
	sk.foe_factory = Callable(self, "_eye_factory")
	var core := _core("all", 1)
	var left := _eye()
	var right := _eye()
	sk.add_foes([core, left, right])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, left), "a part falls")
	sk.end_round()
	assert_eq(sk.parts_of(core).size(), 1, "still down at the round's end")
	sk.start_round()
	sk.end_round()
	assert_eq(sk.parts_of(core).size(), 2, "a round later it has grown back into its slot")
	assert_true(Effects.has(core, "guarded"), "and the guard is up again")


func test_a_core_that_falls_takes_its_parts_with_it() -> void:
	var sk := Skirmish.new(1, 3)
	_two_guns(sk)
	var core := _core("")
	core.hp = 20
	var left := _eye()
	var right := _eye()
	sk.add_foes([core, left, right])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, core), "the core falls")
	assert_false(left.alive() or right.alive(), "and its parts with it")
	assert_true(sk.field_foes().is_empty(), "the field is clear")
	assert_true("\n".join(sk.log).contains("its parts with it"), "the log says so")
	var trip := SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(_core("any", 2), sk))), sk)
	assert_eq(trip.part_ids, ["eye", "eye"], "a save keeps its parts")
	assert_eq(trip.guard, "any", "its guard")
	assert_eq(trip.regrow_parts, 2, "and its regrowth, a whole number")


func _meteor_beast(hp: int = 30) -> Foe:
	var f := Foe.make("gargantuan_king", hp, 20)
	f.on_death = {"blow": Foe.death_blow_from({"name": "Meteor", "factor": 1.0, "keywords": ["all"]})}
	return f


## A blow at every machine reaches the machines in the fight (the audit's ninth bug, 8
## November): a last act on every machine passes a Phased one by, its blow and its riders alike,
## as a foe's turn always has.
func test_a_last_act_at_every_machine_passes_a_machine_out_of_the_fight_by() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(40, I)), 0, 100)
	var b := _mech("B", Die.single(Face.blank()), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var beast := Foe.make("gargantuan_king", 30, 20)
	beast.on_death = {"blow": Foe.death_blow_from({"name": "Meteor", "factor": 1.0, "keywords": ["all", "scorch"], "scorch": 1})}
	sk.add_foes([beast, _ghoul(500, 0)])
	sk.begin()
	sk.start_round()
	Effects.grant_for_rounds(b, Effects.STATUS["phased"], "test", sk.round)
	assert_true(Skirmish.is_phased(sk.mechs[1]), "B is out of the fight")
	assert_true(sk.assign(0, beast), "the beast falls")
	assert_true(a.hull < 100 and Effects.has(a, "scorched"), "its Meteor lands on A, scorching it")
	assert_eq(b.hull, 100, "and passes the Phased machine by")
	assert_false(Effects.has(b, "scorched"), "its riders too")


func test_a_last_act_lands_the_moment_its_foe_falls() -> void:
	# The Gargantuan King's Meteor (15 October): shield up, then kill it.
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(40, I)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(10, I)), 10, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var beast := _meteor_beast()
	sk.add_foes([beast, _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, beast), "the beast falls")
	assert_eq(a.hull, 80, "its Meteor lands on the machine that killed it at once")
	assert_eq(b.shield, 0, "a shield takes ten of it on the other")
	assert_eq(b.hull, 90, "and ten pass to the hull")
	assert_eq(sk.last_acts.size(), 1, "the screen is told")
	assert_eq(sk.last_acts[0]["mechs"], [0, 1], "which machines it struck")
	assert_true("\n".join(sk.log).contains("its last act lands: Meteor"), "the log says so")


func test_the_last_foes_last_act_lands_even_as_the_fight_is_won() -> void:
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.attack(40, L)), 0, 100)
	sk.add_mech(a)
	sk.add_foes([_meteor_beast()])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "the last foe falls")
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "the fight is won")
	assert_eq(a.hull, 80, "and the Meteor still landed: damage sticks for the battle")
	var trip := SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(_meteor_beast(), sk))), sk)
	assert_eq(str(trip.last_act().get("name", "")), "Meteor", "a save keeps its last act")
	assert_eq(int(trip.last_act().get("strikes", 0)), 1, "a whole number of strikes")


## A foe whose fall is one special in a blow's place (16 November), built as content would.
func _falls_with(effect: String, value: int = 0, also: Array = []) -> Foe:
	var f := Foe.make("revenant", 10, 5)
	var act := {"name": "Last Word", "effect": effect}
	if value > 0:
		act["value"] = value
	if not also.is_empty():
		act["also"] = also
	f.on_death = {"act": Foe.fall_act_from(act)}
	return f


## A fall is a short list of steps, as a move is (16 November, on Ryan's mark of 15 November:
## "foes who, say buff others on death, or debuff on death, which makes kill sequencing more
## interesting in normal formations"). One that blesses lifts every foe still standing, never
## the one that fell, and their blows this very turn show it.
func test_a_fall_that_blesses_lifts_the_foes_still_standing() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(40, I)), 0, 100)
	sk.add_mech(a)
	var howler := _falls_with("rally", 2)
	var left := _ghoul(500, 10)
	var right := _ghoul(500, 10)
	sk.add_foes([left, howler, right])
	sk.begin()
	sk.start_round()
	assert_eq(sk.foe_blow(left), 10, "before the fall, its plain blow")
	assert_true(sk.assign(0, howler), "the howler falls")
	assert_eq([Effects.stacks_of(left, "kindled"), Effects.stacks_of(right, "kindled")], [2, 2], "every foe still standing is Empowered by the fall's number")
	assert_eq(Effects.stacks_of(howler, "kindled"), 0, "never the one that fell")
	assert_eq(sk.foe_blow(left), 12, "and the blow it shows is that much harder at once")
	assert_eq(sk.last_acts.size(), 1, "the screen is told")
	assert_eq(sk.last_acts[0]["effects"], ["rally"], "what the fall did")
	assert_eq(sk.last_acts[0]["mechs"], [], "it struck nobody")
	assert_true("\n".join(sk.log).contains("its last act lands: Last Word"), "the log names the fall")
	var hull := a.hull
	sk.end_round()
	assert_eq(hull - a.hull, 24, "both land their blow, two harder each")


## A fall's curse, an effect aimed at one machine, lands on the machine that made the kill (Ryan,
## 16 November: "if the effect is a curse, then it should apply to the killer, and the dodge is
## ablating it"), whatever the foe's own pick was; a Ward on the killer turns it away; a kill no
## machine made, a tick's, lands it on nobody; and a killer out of the fight is out of its reach.
func test_a_falls_curse_lands_on_the_killer_and_a_tick_dodges_it() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(40, I)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(3, I)), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var gazer := _falls_with("jam")
	sk.add_foes([gazer, _ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	gazer.target = sk.mechs[1]
	assert_true(sk.assign(0, gazer), "A makes the kill")
	assert_true(Effects.is_entry_disabled(a, sk.mechs[0].face_index), "the entry the killer shows is Jammed")
	assert_false(Effects.is_entry_disabled(b, sk.mechs[1].face_index), "and its own pick's is not: the curse follows the kill")
	assert_eq(int(sk.last_acts[0]["cursed"]), 0, "the screen is told whom it cursed")
	# A Ward on the killer turns the curse away.
	var s2 := Skirmish.new(1, 2)
	var c := _mech("C", Die.single(Face.attack(40, I)), 0, 100)
	s2.add_mech(c)
	var g2 := _falls_with("jam")
	s2.add_foes([g2, _ghoul(500, 1)])
	s2.begin()
	s2.start_round()
	Effects.stack(c, Effects.STATUS["ward"], Effects.SKIRMISH, "test", 1)
	assert_true(s2.assign(0, g2), "the gazer falls to a warded machine")
	assert_false(Effects.is_entry_disabled(c, s2.mechs[0].face_index), "the Ward turns it away")
	assert_true("\n".join(s2.log).contains("Ward turns it away"), "and the log says so")
	# The dodge: Ablating fells it as its turn ends, and no machine made the kill.
	var s3 := Skirmish.new(1, 2)
	var e := _mech("E", Die.single(Face.blank()), 0, 100)
	s3.add_mech(e)
	var g3 := _falls_with("jam")
	g3.hp = 2
	Effects.stack(g3, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 5)
	s3.add_foes([g3, _ghoul(500, 1)])
	s3.begin()
	s3.start_round()
	g3.target = s3.mechs[0]
	s3.end_round()
	assert_false(g3.alive(), "it burns down as its turn ends")
	assert_false(Effects.is_entry_disabled(e, s3.mechs[0].face_index), "and its curse lands on nobody, its pick included")
	assert_true("\n".join(s3.log).contains("no machine stands to take it"), "the log says so")
	# A killer out of the fight is out of the curse's reach too.
	var s4 := Skirmish.new(1, 2)
	var h := _mech("H", Die.single(Face.attack(40, I)), 0, 100)
	s4.add_mech(h)
	var g4 := _falls_with("jam")
	s4.add_foes([g4, _ghoul(500, 1)])
	s4.begin()
	s4.start_round()
	Effects.grant_for_rounds(h, Effects.STATUS["phased"], "test", s4.round)
	assert_true(s4.assign(0, g4), "a Phased machine makes the kill")
	assert_false(Effects.is_entry_disabled(h, s4.mechs[0].face_index), "nothing reaches it")
	assert_eq(int(s4.last_acts[0]["cursed"]), -1, "so the curse lands on nobody")


## One fall, two machines: its blow lands where a move's does, on the foe's own pick, and its
## curse on the machine that made the kill.
## A fall's single blow follows the kill as its curse does (Ryan, 17 November, of the Dread
## Knight's Death Throes: "yes, hit its killer, if it has one"): the machine whose spend felled
## it takes the blow, whatever the foe had picked, and a kill no machine made lands it on nobody.
func test_a_falls_blow_lands_on_its_killer_and_on_nobody_when_it_has_none() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(40, I)), 0, 100)
	var b := _mech("B", Die.single(Face.blank()), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var knight := Foe.make("revenant", 10, 6)
	knight.on_death = {"blow": Foe.death_blow_from({"name": "Throes", "factor": 1.0, "also": [{"effect": "ablate", "value": 2}]})}
	sk.add_foes([knight, _ghoul(500, 0)])
	sk.begin()
	sk.start_round()
	knight.target = sk.mechs[1]
	assert_true(sk.assign(0, knight), "A makes the kill")
	assert_eq([a.hull, b.hull], [94, 100], "its blow lands on the machine that killed it, not on its pick")
	assert_eq([Effects.stacks_of(a, "ablating_mech"), Effects.stacks_of(b, "ablating_mech")], [2, 0], "and its curse with it")
	assert_eq(sk.last_acts[0]["mechs"], [0], "the blow's machine")
	assert_eq(int(sk.last_acts[0]["cursed"]), 0, "and the curse's, the same")
	# A kill no machine made: its tick fells it in the enemy's turn, and the blow lands on nobody.
	var s2 := Skirmish.new(1, 2)
	var c := _mech("C", Die.single(Face.blank()), 0, 100)
	var d := _mech("D", Die.single(Face.blank()), 0, 100)
	s2.add_mech(c)
	s2.add_mech(d)
	var k2 := Foe.make("revenant", 2, 6)
	k2.on_death = {"blow": Foe.death_blow_from({"name": "Throes", "factor": 1.0})}
	s2.add_foes([k2, _ghoul(500, 0)])
	s2.begin()
	s2.start_round()
	k2.target = s2.mechs[0]
	Effects.stack(k2, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 5, Effects.status_decay(Effects.STATUS["ablating"]))
	s2.end_round()
	assert_false(k2.alive(), "its tick fells it")
	assert_true("\n".join(s2.log).contains("Throes lands on nobody"), "and its blow lands on nobody: no machine made the kill")
	assert_eq(s2.last_acts.filter(func(x): return x["foe"] == k2)[0]["mechs"], [], "no machine struck by it")


## A fall strikes first and then does the rest, in the order written: its blow, then each
## effect by that effect's own rules, a machine out of the fight passed by.
func test_a_fall_strikes_and_then_does_the_rest() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(40, I)), 0, 100)
	var b := _mech("B", Die.single(Face.blank()), 0, 100)
	var c := _mech("C", Die.single(Face.blank()), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_mech(c)
	var beast := Foe.make("gargantuan_king", 30, 20)
	beast.on_death = {"blow": Foe.death_blow_from({"name": "Meteor", "factor": 0.5, "keywords": ["all"],
		"also": [{"effect": "scorch_all", "value": 2}, {"effect": "brittle_all", "value": 2}]})}
	assert_eq(Foe.steps_of(beast.fall()).size(), 3, "its blow and two steps after")
	sk.add_foes([beast, _ghoul(500, 0)])
	sk.begin()
	sk.start_round()
	Effects.grant_for_rounds(c, Effects.STATUS["phased"], "test", sk.round)
	assert_true(sk.assign(0, beast), "the beast falls")
	assert_eq([a.hull, b.hull, c.hull], [90, 90, 100], "its blow lands on every machine in the fight")
	assert_eq([Effects.stacks_of(a, "scorched"), Effects.stacks_of(b, "scorched"), Effects.stacks_of(c, "scorched")], [2, 2, 0], "then its scorch, the Phased machine passed by")
	assert_eq([Effects.stacks_of(a, "brittled_mech"), Effects.stacks_of(b, "brittled_mech"), Effects.stacks_of(c, "brittled_mech")], [2, 2, 0], "then its Brittle, the Phased machine passed by again")
	assert_eq(sk.last_acts[0]["effects"], ["scorch_all", "brittle_all"], "in the order written")
	assert_eq(sk.last_acts[0]["mechs"], [0, 1], "the machines its blow struck")
	var trip := SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(beast, sk))), sk)
	assert_eq(Foe.effects_of(trip.fall()).map(func(st) -> String: return str(st["effect"])), ["scorch_all", "brittle_all"], "a save keeps a fall's steps")
	assert_eq(int(Foe.effects_of(trip.fall())[0]["value"]), 2, "their numbers whole")


## The round preview plays a fall with everything it sets off, the same engine on a copy: a
## foe its tick will fell blesses the rest and scorches the team in the preview as in the turn.
func test_the_round_preview_plays_a_falls_steps() -> void:
	var sk := Skirmish.new(4, 3)
	var m := _mech("A", Die.single(Face.blank()), 0, 100)
	sk.add_mech(m)
	var howler := _falls_with("rally", 2, [{"effect": "scorch_all", "value": 1}])
	howler.hp = 2
	Effects.stack(howler, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 5)
	var other := _ghoul(500, 10)
	sk.add_foes([howler, other])
	sk.begin()
	sk.start_round()
	var pv := sk.preview_round()
	assert_false(bool(pv["foes"][howler]["alive"]), "it burns down as its turn ends")
	assert_true((pv["foes"][other]["coming"] as Dictionary).has("kindled"), "the foe still standing wears the Empowered its fall brings")
	assert_true((pv["mechs"][0]["coming"] as Dictionary).has("scorched"), "and the machine the Scorched")
	assert_eq(Effects.stacks_of(other, "kindled"), 0, "the fight itself untouched")
	var said := int(pv["mechs"][0]["hull_after"])
	sk.end_round()
	assert_eq(m.hull, said, "and the turn lands as the preview said")


## A root's scream (Ryan, 19 November: "Mandragora can be brittle on killer for t1, and it's
## higher variations can brittle the whole team"): a curse lands on the machine that made the
## kill, a Ward turning it away and a tick's kill landing it on nobody; the scream at every
## machine lands on each in the fight. Either is Brittle through the enemy's turn after it, halved
## as the next round opens. No fall takes a reroll: the drain is a move's alone.
func test_a_roots_scream_leaves_its_killer_brittle_and_a_higher_roots_every_machine() -> void:
	var sk := Skirmish.new(1, 4)
	var a := _mech("A", Die.single(Face.attack(40, I)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(40, I)), 0, 100)
	var c := _mech("C", Die.single(Face.blank()), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_mech(c)
	var root := _falls_with("brittle", 2)
	var warded := _falls_with("brittle", 2)
	var loud := _falls_with("brittle_all", 2)
	sk.add_foes([root, warded, loud, _ghoul(500, 0)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, root), "A pulls the root")
	assert_eq([Effects.stacks_of(a, "brittled_mech"), Effects.stacks_of(b, "brittled_mech"), Effects.stacks_of(c, "brittled_mech")], [2, 0, 0], "its killer alone is Brittle")
	assert_eq(sk.reroll_debt, 0, "and no reroll is owed")
	Effects.grant_for_rounds(b, Effects.STATUS["ward"], "test", sk.round)
	assert_true(sk.assign(1, warded), "B pulls the second under a Ward")
	assert_eq(Effects.stacks_of(b, "brittled_mech"), 0, "the Ward turns the curse away")
	loud.hp = 2
	Effects.stack(loud, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 5)
	sk.end_round()
	assert_false(loud.alive(), "the loud one burns down as its turn ends")
	assert_eq(Effects.stacks_of(c, "brittled_mech"), 2, "its scream reaches every machine, whoever made the kill")
	sk.start_round()
	assert_eq([Effects.stacks_of(a, "brittled_mech"), Effects.stacks_of(c, "brittled_mech")], [2, 1], "A's halves as the round opens, 2 with the loud one's to 4 and then 2; C's 2 to 1")


## Sap on every machine, a step of a foe's move (the Fell Rider's Shriek, Ryan, 20 November: "Fell
## rider shriek probably wants Sap on there, thematically"): every machine in the fight is Sapped
## as the move lands in the enemy's turn, a Ward turning it away, so each hit it lands through its
## next turn is a point lower, and the stacks go as that turn ends. Synthetic move.
func test_a_shriek_that_saps_every_machine_lowers_its_next_turns_hits() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(5, I)), 0, 100)
	var b := _mech("B", Die.single(Face.attack(5, I)), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var rider := _ghoul(500, 0)
	rider.actions = [_special("debuff", "drain_rerolls", {"value": 1, "also": [{"effect": "sap_all", "value": 1}]})]
	var target := _ghoul(500, 0)
	sk.add_foes([rider, target])
	sk.begin()
	sk.start_round()
	rider.action = rider.actions[0]
	Effects.grant_for_rounds(b, Effects.STATUS["ward"], "test", sk.round)
	sk.end_round()
	assert_eq([Effects.stacks_of(a, "sapped"), Effects.stacks_of(b, "sapped")], [1, 0], "every machine Sapped, the Warded one passed by")
	sk.start_round()
	rider.actions = [Foe.basic_action()]
	rider.action = rider.actions[0]
	var before := target.hp
	assert_true(sk.assign(0, target), "A fires at the second foe")
	assert_eq(before - target.hp, 4, "its blow a point lower")
	sk.end_round()
	assert_eq(Effects.stacks_of(a, "sapped"), 0, "and the stack goes as its turn ends")


func test_a_splitting_foe_steps_its_halves_up_in_its_place_at_once() -> void:
	# The Gel (Ryan, 25 October: "spawn the half-gel immediately in place, not wait for the
	# reinforcement phase"): destroyed, its halves step up at once, the first into its slot and
	# the next into the nearest empty slot of its rank; their round is over, so they show no
	# intent and strike from the next round. The halves never split again, and without the
	# battle's factory nothing steps in.
	var sk := Skirmish.new(2, 3)
	var m := _mech("A", Die.single(Face.attack(200, L)), 40, 100)
	sk.add_mech(m)
	var heavy := _ghoul(500, 20)
	var gel := _ghoul(30, 10)
	gel.display_name = "gel"
	gel.on_death = {"summon": "gel_small", "count": 2}
	sk.foe_factory = func(id: String) -> Foe: return Foe.make(id, 10, 5)
	sk.add_foes([heavy, gel])
	sk.begin()
	sk.start_round()
	assert_eq(sk.front[1], gel, "the gel stands beside the heavier hitter")
	sk.assign(0, gel)
	assert_false(gel.alive(), "it fell")
	assert_eq(sk.front[1].display_name, "gel_small", "a half stepped up in its slot at once")
	assert_eq(sk.front[2].display_name, "gel_small", "and the other into the nearest empty slot")
	assert_eq(sk.front[1].pack_id, gel.pack_id, "under the same pack")
	assert_eq(sk.reinforcements.size(), 0, "nothing waits")
	assert_true("\n".join(sk.log).contains("splits: 2 gel_small step up in its place"), "the log says so")
	assert_eq(sk.outcome, Skirmish.Outcome.NONE, "the fight goes on")
	assert_true(sk.front[1].fresh and sk.front[1].target == null, "its round is over: no intent")
	assert_false(sk.front[1].intent_on(m), "so it shows none on the machine")
	assert_eq(sk.incoming_for(sk.mechs[0]), 20, "the forecast counts the heavy hitter alone")
	sk.end_round()
	assert_eq(m.shield, 20, "only the heavy hitter struck")
	sk.start_round()
	assert_false(sk.front[1].fresh, "the next round it acts")
	assert_true(sk.front[1].intent_on(m), "and shows its intent")
	var trip := SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(sk.front[2], sk))), sk)
	assert_false(trip.fresh, "a save keeps whether it has had its round")
	# A one-column fight: the second half has no room and never forms (no reinforcement inside a
	# fight, 6 November).
	var sk1 := Skirmish.new(2, 1)
	sk1.add_mech(_mech("C", Die.single(Face.attack(200, L)), 40, 100))
	var one := _ghoul(30, 10)
	one.on_death = {"summon": "gel_small", "count": 2}
	sk1.foe_factory = func(id: String) -> Foe: return Foe.make(id, 10, 5)
	sk1.add_foes([one])
	sk1.begin()
	sk1.start_round()
	sk1.assign(0, one)
	assert_eq(sk1.front[0].display_name, "gel_small", "one half in its place")
	assert_true(sk1.reinforcements.is_empty(), "the other never forms: nothing waits")
	assert_true("\n".join(sk1.log).contains("1 gel_small step up in its place, 1 with no room"), "the log says so")
	var fresh_save := SaveGame._foe_from(JSON.parse_string(JSON.stringify(SaveGame._foe_dict(sk1.front[0], sk1))), sk1)
	assert_true(fresh_save.fresh, "a save keeps a half that has had its round")
	var sk2 := Skirmish.new(2, 1)
	sk2.add_mech(_mech("B", Die.single(Face.attack(200, L)), 40, 100))
	var lone := _ghoul(30, 10)
	lone.on_death = {"summon": "gel_small", "count": 2}
	sk2.add_foes([lone])
	sk2.begin()
	sk2.start_round()
	sk2.assign(0, lone)
	assert_eq(sk2.reinforcements.size(), 0, "no factory, no halves")
	assert_eq(sk2.outcome, Skirmish.Outcome.VICTORY, "and the fight ends")


## A pack's survivors are its own foe type (the mechanics audit, 25 October): a Gel's halves join
## the fight under its pack, a pair in its slot, but never come back on the map as Gels, so the
## pack never grows, and every one of them that falls is a kill all the same ("a kill is a kill").
func test_a_packs_survivors_are_its_own_and_a_split_is_no_kill_but_a_half_is() -> void:
	var sk := Skirmish.new(2, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(200, L)), 40, 100))
	var sq := Unit.pack(7, "gel pack", Vector2i.ZERO, "", Unit.PACK_MOVE, 2, "gel")
	var gels: Array = []
	for i in range(2):
		var g := _ghoul(30, 1)
		g.content_id = "gel"
		g.on_death = {"summon": "gel_half", "count": 2, "pair": true}
		gels.append(g)
	sk.foe_factory = func(id: String) -> Foe:
		var h := Foe.make(id, 10, 1)
		h.content_id = id
		return h
	sk.add_foes(gels, sq)
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, gels[0]), "a Gel falls")
	var half: Foe = sk.front[0]
	assert_true(half != null and half.content_id == "gel_half" and sk.twin_of(half) != null, "its two halves stand in its slot")
	assert_eq(half.pack_id, sq.id, "under its pack")
	assert_eq(sk.survivors_for(sq), 1, "but the pack's own left is the one Gel: halves never come back as Gels")
	assert_eq(sk.kills_for(sq), 0, "the Gel's split is no kill: it goes on as its halves (Ryan, 8 November)")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(0, half), "a half falls")
	assert_eq(sk.survivors_for(sq), 1, "the pack's own unchanged")
	assert_eq(sk.kills_for(sq), 1, "the half is a kill")
	var copy := SaveGame.clone_skirmish(sk)
	assert_eq(copy.kills_for(copy.packs[0]), 1, "and the tally survives the save's round trip")


## The Gel's pair (Ryan, 26 October: the halves "should exist as a pair taking the place of one
## unit"): both stand in its slot at once, one slot to the formation; an area blow reaches both,
## a single-target blow one; a half's Mine blows on its twin beside it; when one falls the other
## keeps the slot alone, and with both gone it is a plain slot.
func test_a_pair_of_halves_stands_in_one_slot() -> void:
	var sk := Skirmish.new(2, 3)
	var spread := Face.attack(3, L, K.CLEAVE)
	var single := Face.attack(3, L)
	sk.add_mech(_mech("A", Die.of([Face.attack(200, L), spread, single]), 40, 100))
	var heavy := _ghoul(500, 20)
	var gel := _ghoul(30, 10)
	gel.display_name = "gel"
	gel.on_death = {"summon": "gel_small", "count": 2, "pair": true}
	sk.foe_factory = func(id: String) -> Foe: return Foe.make(id, 5, 2)
	sk.add_foes([heavy, gel])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	sk.assign(0, gel)
	var left: Foe = sk.front[1]
	var right: Foe = sk.twins.get(Vector2i(0, 1), null)
	assert_true(left != null and right != null, "both halves stand in its slot")
	assert_eq(sk.front[2], null, "the next slot stays empty")
	assert_eq(sk.reinforcements.size(), 0, "and nothing goes to the pool")
	assert_eq(sk.twin_of(left), right, "a pair")
	assert_eq(sk.field_foes(), [heavy, left, right] as Array[Foe], "the right half acts after the left")
	assert_true(left.fresh and right.fresh, "their round over")
	assert_true("\n".join(sk.log).contains("a pair in one slot"), "the log says so")
	assert_true(sk.targets_for_face(ms, single).has(right), "each half its own target")
	assert_eq(sk.web_catch(left), right, "a web on the left half catches the right")
	# An area blow reaches the slot whole; a single-target blow one half.
	assert_true(sk.reached_by(spread, heavy).has(left) and sk.reached_by(spread, heavy).has(right), "a Spread beside it reaches both")
	assert_true(sk.reached_by(spread, right).has(left), "and aimed at one, its twin too")
	assert_eq(sk.reached_by(single, right), [right] as Array[Foe], "a single-target blow the one")
	# A half's Mine: it falls, and the blast meets its twin in the slot and the foe beside it.
	sk._add_mine(left, 3, {})
	var heavy_hp := heavy.hp
	left.hp = 0
	sk._clear_dead()
	assert_eq(right.hp, 5 - 3, "its twin took the 3")
	assert_eq(heavy.hp, heavy_hp - 3, "and the foe beside the slot")
	assert_eq(sk.front[1], right, "the survivor keeps the slot alone")
	assert_true(sk.twins.is_empty(), "the pair gone")
	right.hp = 0
	sk._clear_dead()
	assert_eq(sk.front[1], null, "both gone: a plain empty slot")


## A Swap moves a pair together, and a save keeps it.
func test_a_pair_moves_and_saves_together() -> void:
	var sk := Skirmish.new(2, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(200, L)), 40, 100))
	var gel := _ghoul(30, 10)
	gel.on_death = {"summon": "gel_small", "count": 2, "pair": true}
	sk.foe_factory = func(id: String) -> Foe: return Foe.make(id, 5, 2)
	sk.add_foes([gel])
	sk.begin()
	sk.start_round()
	sk.assign(0, gel)
	var left: Foe = sk.front[0]
	var right: Foe = sk.twins[Vector2i(0, 0)]
	assert_false(sk.swap_targets(left).has(right), "a half never swaps with its own twin")
	sk._swap(left, Vector2i(0, 2))
	assert_eq([sk.front[0], sk.front[2], sk.twins.get(Vector2i(0, 2), null)], [null, left, right], "the pair moved as one")
	assert_eq([right.rank, right.column], [0, 2], "the right half with it")
	var c := SaveGame.clone_skirmish(sk)
	var cl: Foe = c.front[2]
	assert_true(cl != null and c.twin_of(cl) != null, "a copy through the save keeps the pair")
	assert_eq(c.twin_of(cl).hp, right.hp, "its right half as it was")


func test_the_reach_tally_counts_a_spend_and_its_hull() -> void:
	# For the balance runner's reach table (9 October): what a spend of each reach did.
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(20, I)), 40, 100))
	var front := _ghoul(15, 10)
	var behind := _archer(500, 10)
	sk.add_foes([front, behind])
	sk.begin()
	sk.start_round()
	sk.assign(0, front)
	var t: Dictionary = sk.reach_tally["indirect"]
	assert_eq(int(t["spends"]), 1, "one spend")
	assert_eq(int(t["damage"]), 15, "the hull it took, overkill not counted")
	assert_eq(int(t["back"]), 0, "aimed at the front")
	assert_false(t.has("splash"), "and no splash is counted, danger close being gone")
	assert_eq(sk.mechs[0].unit.shield, 40, "nor paid")
	assert_false(sk.reach_tally.has("direct"), "no direct spend happened")


# ---------------------------------------------------------------- the funnel-web (18 October)

## A synthetic ambush: the engine's lay_status on its target_no_intent condition, never the
## content's passive.
const AMBUSH := {"id": "ambush_t", "name": "Ambush", "description": "", "effects": [
	{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1, "when": "target_no_intent", "damaging": true}]}


func _strikes(f: Face, n: int) -> Face:
	f.strikes = n
	return f


## Vitriol (Ryan's go, 18 October): a share of the foe's current hull a stack at its action,
## read after Ablating on what it leaves, past armour, rounded down, then a stack fades; and it
## never finishes a foe, so it sets off no last act.
func test_vitriol_eats_a_share_of_the_hull_burning_leaves_and_never_finishes_a_foe() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 500)
	sk.add_mech(m)
	var g := _ghoul(100, 10)
	g.armour = 5   # armour never sees a tick, as with Ablating
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.stack(g, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 2)
	Effects.stack(g, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 3)
	var bt := Effects.status_value("ablating", "tick_hp")
	var vs := Effects.status_value("vitriol", "tick_hp_share")   # its share a stack, in percent
	var left := 100 - 2 * bt
	var eaten := left * vs * 3 / 100
	var tp := Effects.tick_preview(g)
	assert_eq(int(tp["share"]), eaten, "three stacks eat their share of what Ablating's two stacks leave, rounded down")
	assert_eq(int(tp["hp"]), 2 * bt + eaten, "the whole tick is Ablating's and the share")
	sk.end_round()
	assert_eq(g.hp, left - eaten, "100, less Ablating's, less Vitriol's, past armour")
	assert_eq(Effects.stacks_of(g, "vitriol"), 2, "a stack faded at its action")
	assert_true("\n".join(sk.log).contains("vitriol eats revenant for %d" % eaten), "the log says what it ate")
	sk.start_round()
	sk.end_round()
	var then := left - eaten - bt
	assert_eq(g.hp, then - then * vs * 2 / 100, "after Ablating's last stack, two stacks eat their share of what it leaves")
	assert_eq(Effects.stacks_of(g, "vitriol"), 1, "another faded")
	var low := _ghoul(1, 10)
	Effects.stack(low, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 5)
	assert_eq(int(Effects.tick_preview(low)["hp"]), 0, "nothing to eat on a foe at one hull")
	var mid := _ghoul(3, 10)
	Effects.stack(mid, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 20)
	assert_eq(int(Effects.tick_preview(mid)["hp"]), 2, "stacks enough to eat all three leave the last point: it never finishes a foe")
	assert_true(Effects.carries_status(mid), "a foe carrying Vitriol carries a status the team put on it")
	assert_eq(Effects.status_stacking(Effects.STATUS["vitriol"]), "add", "Vitriol adds, Ablating's shape")


## The ambush read (18 October): a foe shows intent on the machine when its arrow is on it, a
## gathering countdown and a blow at every machine included; none when aimed at another
## machine, Suppressed, or on a special that acts on nobody in particular. A stack per hit.
func test_an_ambush_lays_its_status_on_a_foe_showing_no_intent_on_it_a_stack_per_hit() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(_strikes(Face.attack(10, L), 3)), 0, 500)
	a.grant_passive(AMBUSH)
	var b := _mech("B", Die.single(Face.shield(10)), 40, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var at_a := _ghoul(500, 10)
	var at_b := _ghoul(500, 10)
	var stunned := _ghoul(500, 10)
	sk.add_foes([at_a, at_b, stunned])
	sk.begin()
	sk.start_round()
	var me: Skirmish.MechState = sk.mechs[0]
	var other: Skirmish.MechState = sk.mechs[1]
	at_a.target = me
	at_b.target = other
	stunned.target = me
	Effects.grant_for_rounds(stunned, Effects.STATUS["suppressed"], "mech", sk.round)
	assert_true(at_a.intent_on(a), "aimed at the ambusher: intent on it")
	assert_false(at_b.intent_on(a), "aimed at an ally: none on it")
	assert_false(stunned.intent_on(a), "a suppressed foe shows intent on nobody")
	assert_true(sk.acting_on(me).has(at_a) and not sk.acting_on(me).has(at_b), "acting_on reads the same")
	assert_true(sk.assign(0, at_b), "the bite")
	assert_eq(Effects.stacks_of(at_b, "vitriol"), 3, "three strikes on a foe looking away: three stacks")
	assert_true("\n".join(sk.log).contains("A lays Vitriol ×3 on revenant"), "the log says so")
	sk.end_round()
	sk.start_round()
	at_a.target = me
	assert_true(sk.assign(0, at_a), "the blow on the one looking")
	assert_eq(Effects.stacks_of(at_a, "vitriol"), 0, "a foe aimed at the ambusher takes the blow and no acid")
	sk.end_round()
	sk.start_round()
	stunned.target = me
	Effects.grant_for_rounds(stunned, Effects.STATUS["suppressed"], "mech", sk.round)
	assert_true(sk.assign(0, stunned), "the blow on the stunned one")
	assert_eq(Effects.stacks_of(stunned, "vitriol"), 3, "a suppressed foe looks away: three stacks")
	# The read's edges, on the foe itself.
	at_a.target = me
	at_a.action = {"id": "knit", "name": "Knit", "kind": "defend", "effect": "recover", "value": 10, "weight": 1, "text": ""}
	assert_true(at_a.acts_on_nobody(), "a regrow acts on nobody in particular")
	assert_false(at_a.intent_on(a), "so it shows intent on no machine, whatever its pick")
	at_a.action = {"id": "storm", "name": "Storm", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": ["all"], "text": ""}
	at_a.target = other
	assert_true(at_a.intent_on(a), "a blow at every machine is aimed at the ambusher too")
	at_a.pending = at_a.action
	at_a.charge = 1
	assert_true(at_a.intent_on(a), "gathering as much as landing")
	at_a.action = at_a.actions[0]
	at_a.pending = at_a.action
	at_a.charge = 2
	at_a.target = me
	assert_true(at_a.intent_on(a), "a countdown aimed at it shows intent")
	at_a.target = other
	assert_false(at_a.intent_on(a), "and one aimed elsewhere shows none")


## A passive's lay lands on every hit, a debuff's included, unless it asks for a weapon's
## weapon's hit (Ryan, 25 October: "that should be a vitriol specific rule, and documented in the
## passive text"): a debuff spent on the foe lays the plain lay and not the weapon's one.
func test_a_passives_lay_lands_on_any_hit_unless_it_asks_for_a_weapons() -> void:
	var lays := {"id": "lays_t", "name": "Lays", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "lay_status", "value": "brittled", "stacks": 1},
		{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1, "damaging": true}]}
	var probe := Face.attack(0, L, [K.SUPPRESS])
	var gun := Face.attack(5, L)
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.of([probe, gun]), 0, 500)
	a.grant_passive(lays)
	sk.add_mech(a)
	var g := _ghoul(100, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, g), "a debuff on the foe")
	assert_eq(Effects.stacks_of(g, "brittled"), 1, "the plain lay lands on a blow of nothing")
	assert_eq(Effects.stacks_of(g, "vitriol"), 0, "the weapon's one waits for a weapon's hit")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, g), "a gun on the foe")
	assert_eq(Effects.stacks_of(g, "vitriol"), 1, "and lands with it")
	assert_true(Effects.effect_text(lays["effects"][1]).contains("a weapon hits"), "its line says so")


## A weapon's hit spends a Shock, cashes Cryo and lays a weapon's lay whatever it dealt (Ryan,
## 25 October: "The important part is that it was a damaging weapon"); a debuff does none
## of it. Under a split a printed 1 strikes 1, twice (never below one, 27 October), and the
## foe's armour takes each to nothing.
func test_a_weapons_hit_of_nothing_still_spends_a_shock_cashes_cryo_and_lays() -> void:
	var passive := {"id": "split_lays", "name": "Split", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "split_strikes", "value": 2},
		{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1, "damaging": true}]}
	for weapon in ["debuff", "gun"]:
		var f := Face.attack(0, L, [K.SUPPRESS]) if weapon == "debuff" else Face.attack(1, L)
		var sk := Skirmish.new(1, 1)
		var m := _mech("S", Die.single(f), 40, 100)
		m.grant_passive(passive)
		sk.add_mech(m)
		var g := _ghoul(100, 10)
		g.armour = 2   # a strike of 1, doubled by the shock or not, comes to nothing on it
		sk.add_foes([g])
		sk.begin()
		sk.start_round()
		var ms: Skirmish.MechState = sk.mechs[0]
		Effects.stack(g, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
		Effects.stack(g, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
		ms.heat = 8
		assert_true(sk.assign(0, g), "the %s spent" % weapon)
		assert_eq(g.hp, 100, "the %s deals nothing" % weapon)
		if weapon == "debuff":
			assert_true(Effects.has(g, "shocked"), "a debuff leaves the shock standing")
			assert_eq(Effects.stacks_of(g, "cryoed"), 2, "and the Cryo")
			assert_eq(Effects.stacks_of(g, "vitriol"), 0, "and lays no weapon's lay")
		else:
			assert_false(Effects.has(g, "shocked"), "a weapon's blow the armour takes to nothing spends the shock")
			assert_eq(Effects.stacks_of(g, "cryoed"), 0, "and cashes the Cryo")
			assert_eq(ms.heat, 8 - 2 * sk.cryo_cool(), "cooling its hitter")
			assert_eq(Effects.stacks_of(g, "vitriol"), 2, "and lays the weapon's lay on each strike")


## Brittle on a weapon's blow of 0 (Ryan, 25 October: "Flak and overcharge exist in part
## to get past armour"): a split 1 strikes twice at 1 (never below one, 27 October), and each strike takes the foe's Brittle
## before its armour comes off, on the die over the foe, in the bot's read and in the blow; a
## debuff's blow stays nothing.
func test_a_weapons_blow_of_0_takes_the_foes_brittle_before_its_armour() -> void:
	var split := {"id": "split", "name": "Split", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "split_strikes", "value": 2}]}
	for weapon in ["debuff", "gun"]:
		var f := Face.attack(0, L, [K.SUPPRESS]) if weapon == "debuff" else Face.attack(1, L)
		var sk := Skirmish.new(1, 1)
		var m := _mech("S", Die.single(f), 40, 100)
		m.grant_passive(split)
		sk.add_mech(m)
		var g := _ghoul(100, 10)
		g.armour = 1
		sk.add_foes([g])
		sk.begin()
		sk.start_round()
		var ms: Skirmish.MechState = sk.mechs[0]
		Effects.stack(g, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_HALF)
		var shown := sk.shown_face(ms, f)
		var pol := Policy.make(Policy.GREEDY)
		if weapon == "debuff":
			assert_eq(sk.shown_number(ms, shown, g), 0, "a debuff shows none, Brittle or not")
			assert_eq(pol.expected_damage(ms, shown, g), 0.0, "and the bot reads none")
			assert_true(sk.assign(0, g), "the debuff spent")
			assert_eq(g.hp, 100, "and it deals nothing")
		else:
			assert_eq(shown.number_text(), "1", "a 1 halved is 1, never below one")
			assert_eq(sk.shown_number(ms, shown, g), 3, "over the foe a strike shows its 1 and the 3 Brittle, the armour off")
			assert_eq(pol.expected_damage(ms, shown, g), 6.0, "and the bot reads both strikes")
			assert_true(sk.assign(0, g), "the gun spent")
			assert_eq(g.hp, 94, "each strike of 1 takes the Brittle, then loses the armour: 3 twice")


func test_the_ambush_reads_the_intent_before_the_spends_own_riders() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(_strikes(Face.attack(10, L, K.SUPPRESS), 2)), 0, 500)
	a.grant_passive(AMBUSH)
	sk.add_mech(a)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	g.target = sk.mechs[0]
	assert_true(sk.assign(0, g), "two suppressing strikes")
	assert_true(g.is_suppressed(), "the first strike suppressed it")
	assert_eq(Effects.stacks_of(g, "vitriol"), 0, "and the second lays nothing: the read came before the spend's own riders, so a Suppress gun never feeds itself")
	var notes := Effects.explain(a, a.die.faces[0])
	assert_true(notes.size() == 1 and notes[0].begins_with("foes showing no intent on this machine: lays Vitriol"), "the die row shows the rule with its condition: %s" % str(notes))


func test_a_spread_judges_each_foe_reached_alone() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(10, L, K.CLEAVE)), 0, 500)
	a.grant_passive(AMBUSH)
	var b := _mech("B", Die.single(Face.shield(10)), 40, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var left := _ghoul(500, 10)
	var mid := _ghoul(500, 10)
	var right := _ghoul(500, 10)
	sk.add_foes([left, mid, right])
	sk.begin()
	sk.start_round()
	assert_eq(sk.front[1], mid, "ties keep arrival order: the middle foe holds the middle column")
	left.target = sk.mechs[1]
	mid.target = sk.mechs[0]
	right.target = sk.mechs[0]
	Effects.grant_for_rounds(right, Effects.STATUS["suppressed"], "mech", sk.round)
	assert_true(sk.assign(0, mid), "the spread on the middle")
	assert_eq(Effects.stacks_of(mid, "vitriol"), 0, "the target looks at the ambusher: no acid")
	assert_eq(Effects.stacks_of(left, "vitriol"), 1, "its neighbour looks at an ally: a stack")
	assert_eq(Effects.stacks_of(right, "vitriol"), 1, "its other neighbour is suppressed: a stack")


func test_a_blow_of_nothing_lays_no_vitriol_and_the_web_lands() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(_webber(Face.attack(0, L))), 0, 500)
	a.grant_passive(AMBUSH)
	var b := _mech("B", Die.single(Face.shield(10)), 40, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	g.target = sk.mechs[1]
	assert_true(sk.assign(0, g), "the web")
	assert_eq(g.hp, 500, "a web deals nothing")
	assert_eq(Effects.stacks_of(g, "vitriol"), 0, "and a blow of nothing is no hit: the web never feeds the ambush directly")
	assert_true(Effects.has(g, "webbed"), "the foe is webbed")
	assert_true(Effects.carries_status(g), "Webbed is a status the team put on it")
	assert_true("\n".join(sk.log).contains("A webs revenant"), "the log says so")


## The web (Ryan's go, 18 October; at the round's end since 16 November, his "double suppress
## on a delay, not suppress one this turn and one the next"): every foe acts this round, and as
## the round ends the web bursts, Suppressing the webbed foe and the foe beside it, each for
## its next turn.
func test_a_web_bursts_as_the_round_ends_and_both_foes_lose_their_next_turn() -> void:
	var sk := Skirmish.new(1, 3)
	var m := _mech("A", Die.single(_webber(Face.attack(0, L))), 0, 500)
	sk.add_mech(m)
	var small := _ghoul(500, 10)
	var mid := _ghoul(500, 20)
	var big := _ghoul(500, 40)
	sk.add_foes([small, mid, big])
	sk.begin()
	assert_eq(sk.front[0], big, "the heaviest hitter stands left")
	sk.start_round()
	assert_eq(sk.web_catch(big), mid, "a web on it would catch the one to its right")
	assert_true(sk.assign(0, big), "web the big one")
	assert_true("\n".join(sk.log).contains("it bursts as the round ends, on it and revenant"), "the log says when and on whom")
	sk.end_round()
	assert_eq(m.hull, 430, "every foe acts this round, the webbed one and the one beside it too")
	assert_true("\n".join(sk.log).contains("revenant's web bursts, catching revenant"), "the log tells the burst")
	assert_false(Effects.has(big, "webbed"), "the web is spent")
	assert_true(big.is_suppressed() and mid.is_suppressed(), "both are held for their next turn")
	assert_false(small.is_suppressed(), "and the third is not")
	assert_eq([Effects.stacks_of(big, "numbed"), Effects.stacks_of(mid, "numbed")], [0, 0], "neither has lost a turn yet: its stun resist lands as the turn it loses ends")
	sk.start_round()
	assert_true(big.intent_on(m) == false and mid.intent_on(m) == false, "held, they show no intent: two foes the round is planned round")
	sk.end_round()
	assert_eq(m.hull, 420, "the round after, the two skip and the small one strikes")
	assert_eq([Effects.stacks_of(big, "numbed"), Effects.stacks_of(mid, "numbed")], [big.stun_resist(), mid.stun_resist()], "each recovers with its stun resist")
	assert_false(big.is_suppressed() or mid.is_suppressed(), "and the Suppress is spent with the turn it cost")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 350, "then every blow lands again")


func test_a_web_on_the_rightmost_foe_catches_the_one_to_its_left() -> void:
	var sk := Skirmish.new(1, 3)
	var m := _mech("A", Die.single(_webber(Face.attack(0, L))), 0, 500)
	sk.add_mech(m)
	var small := _ghoul(500, 10)
	var mid := _ghoul(500, 20)
	var big := _ghoul(500, 40)
	sk.add_foes([small, mid, big])
	sk.begin()
	sk.start_round()
	assert_eq(sk.front[2], small, "the small one stands at the right")
	assert_eq(sk.web_catch(small), mid, "with nobody to its right, the web catches the one to its left")
	assert_true(sk.assign(0, small), "web the small one")
	sk.end_round()
	assert_eq(m.hull, 430, "every blow lands this round")
	assert_true(small.is_suppressed() and mid.is_suppressed(), "both lose their next turn")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 390, "the big one alone strikes the round after")


## The web sits through the whole enemy turn, so the foes have their answers: one felled before
## the round ends takes its web with it, and a foe's cleanse lifts it first.
func test_a_webbed_foe_felled_in_the_enemys_turn_takes_its_web_and_a_cleanse_lifts_one() -> void:
	var sk := Skirmish.new(1, 3)
	var m := _mech("A", Die.single(_webber(Face.attack(0, L))), 0, 500)
	sk.add_mech(m)
	var mid := _ghoul(500, 20)
	var burning := _ghoul(3, 40)
	sk.add_foes([mid, burning])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, burning), "web the one about to burn down")
	Effects.stack(burning, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	sk.end_round()
	assert_false(burning.alive(), "it struck, then its Ablating felled it as its turn ended")
	assert_false("\n".join(sk.log).contains("'s web bursts"), "no burst: the web went with it")
	assert_false(mid.is_suppressed(), "and the one beside it is free")
	var s2 := Skirmish.new(1, 3)
	var m2 := _mech("B", Die.single(_webber(Face.attack(0, L))), 0, 500)
	s2.add_mech(m2)
	var cleric := _ghoul(500, 40)
	cleric.actions = [Foe.basic_action(), _special("defend", "cleanse")]
	var other := _ghoul(500, 20)
	s2.add_foes([cleric, other])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, other), "web the other one")
	cleric.action = cleric.actions[1]
	s2.end_round()
	assert_false(Effects.has(other, "webbed"), "the cleanse lifted the web in the enemy's turn")
	assert_false(other.is_suppressed() or cleric.is_suppressed(), "so nothing bursts as the round ends")


func test_a_webbed_foe_killed_first_takes_its_web_with_it() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(_webber(Face.attack(0, L))), 0, 500)
	var b := _mech("B", Die.single(Face.attack(500, L)), 0, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var mid := _ghoul(100, 20)
	var big := _ghoul(100, 40)
	sk.add_foes([mid, big])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, big), "web the big one")
	assert_true(sk.assign(1, big), "then kill it")
	assert_false(big.alive(), "killed before it acted")
	sk.end_round()
	assert_false("\n".join(sk.log).contains("'s web bursts"), "no burst: the web went with it")
	assert_false(mid.is_suppressed(), "and the one beside it acted")
	assert_eq(a.hull + b.hull, 980, "its blow landed")


## A web on a foe the team has stunned this round (16 November: the burst comes after every
## foe's turn has ended): the foe has just gained its Numbed, so the burst strips a stack of it
## and stuns nothing, where it did nothing at all while it burst in the foe's own turn; the foe
## beside it is caught as ever.
func test_a_web_on_a_foe_the_team_suppressed_strips_its_numbed_and_still_catches_the_neighbour() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 500)
	var b := _mech("B", Die.single(_webber(Face.attack(0, L))), 0, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var small := _ghoul(500, 10)
	var mid := _ghoul(500, 20)
	var big := _ghoul(500, 40)
	sk.add_foes([small, mid, big])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, big), "stun the big one")
	assert_true(big.is_suppressed(), "stunned")
	assert_true(sk.assign(1, big), "and web it")
	assert_true(Effects.has(big, "webbed"), "webbed on top of the stun")
	sk.end_round()
	assert_eq(a.hull + b.hull, 970, "the stunned foe skipped, and the other two struck: the burst stops nothing this round")
	assert_eq(Effects.stacks_of(big, "numbed"), big.stun_resist() - 1, "its stun resist landed as its lost turn ended, and the burst stripped a stack of it")
	assert_true("\n".join(sk.log).contains("the stun strips a stack of Numbed"), "the log says so")
	sk.start_round()
	assert_false(big.is_suppressed(), "it lost the one turn and the web stunned nothing more")
	assert_true(mid.is_suppressed(), "the one beside it is held for this turn")


func test_a_second_web_changes_nothing_and_a_web_feeds_the_paradox_at_the_spend_and_at_the_burst() -> void:
	var meter := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "paradox", "value": 5}]}
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(_webber(Face.attack(0, L))), 0, 500)
	a.grant_passive(meter)
	var b := _mech("B", Die.single(_webber(Face.attack(0, L))), 0, 500)
	sk.add_mech(a)
	sk.add_mech(b)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, g), "the first web")
	assert_eq(Effects.stacks_of(g, "paradox"), 1, "Webbed is a status gained: the meter counts it")
	assert_true(sk.assign(1, g), "a second web")
	var grants := 0
	for m in g.modifiers:
		if m.id == "webbed":
			grants += 1
	assert_eq(grants, 1, "one web still, however often it is webbed")
	assert_eq(Effects.stacks_of(g, "paradox"), 1, "and nothing gained from the second")
	sk.end_round()
	assert_true(g.is_suppressed(), "the burst held it")
	assert_eq(Effects.stacks_of(g, "paradox"), 2, "the burst's Suppressed counts as the Suppress keyword's: the meter counts it too")


func test_a_web_holds_a_gathering_countdown_a_round() -> void:
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(_webber(Face.attack(0, L))), 0, 100)
	sk.add_mech(a)
	var walker := _gatherer(20, 2)
	sk.add_foes([walker])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, walker), "web the gatherer")
	sk.end_round()
	assert_eq(walker.charge, 1, "it gathered a round")
	assert_true(walker.is_suppressed(), "and the burst holds it")
	sk.start_round()
	sk.end_round()
	assert_eq(walker.charge, 1, "held: the countdown did not move")
	sk.start_round()
	sk.end_round()
	assert_eq(walker.charge, 0, "then it gathers on")
	assert_eq(a.hull, 100, "nothing has landed")
	sk.start_round()
	sk.end_round()
	assert_eq(a.hull, 80, "it lands a round later than it would have")


func test_an_attacker_status_condition_reads_the_foe_striking() -> void:
	# The Prairie Dog's fight half (21 October): a damage-taken effect that reads the striker's
	# status. Handed the striker, damage_taken honours it; asked without one, it never holds.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L)), 0, 100)
	m.grant_passive({"id": "tyres", "name": "Tyres", "description": "", "effects": [
		{"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status", "status": "ablating"}]})
	sk.add_mech(m)
	var clean := _ghoul(200, 20)
	var lit := _ghoul(200, 20)
	sk.add_foes([clean, lit])
	sk.begin()
	sk.start_round()
	Effects.stack(lit, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 1)
	assert_eq(Effects.damage_taken(m, 20, clean), 20, "a clean striker's blow is the plain 20")
	assert_eq(Effects.damage_taken(m, 20, lit), 15, "a burning striker's blow lands 5 lighter")
	assert_eq(Effects.damage_taken(m, 20), 20, "asked without a striker, the condition does not hold")
	assert_eq(Effects.damage_taken(m, 3, lit), 0, "and never below nothing")
	sk._damage_mech(sk.mechs[0], 20, lit)
	assert_eq(m.hull, 85, "the blow in the fight reads the striker")
	sk._damage_mech(sk.mechs[0], 20, clean)
	assert_eq(m.hull, 65, "a clean foe's blow lands whole")
	var notes := Effects.explain(m, m.die.faces[0])
	assert_true(notes.is_empty(), "a passive with no component names no die row")
	var lead := Effects.effect_text(m.modifiers[0].effects[0])
	assert_eq(lead, "blows from foes carrying Ablate: damage taken -5", "the rule reads with its condition as the lead")
	assert_eq(Effects.effect_text({"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status", "status": "brittled"}),
		"blows from foes carrying Brittle: damage taken -5", "Brittle reads by its name since it was built (21 October)")
	assert_eq(Effects.effect_text({"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status", "status": "unbuilt"}),
		"blows from foes carrying Unbuilt: damage taken -5", "a status the engine lacks reads by its id")
	var other := _mech("B", Die.single(Face.attack(20, L)), 0, 100)
	other.grant_passive({"id": "tyres2", "name": "Tyres", "description": "", "effects": [
		{"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status"}]})
	assert_eq(Effects.damage_taken(other, 20, lit), 15, "named no status, the condition reads any foe status")
	assert_eq(Effects.damage_taken(other, 20, clean), 20, "and a clean striker is nothing")
	other.modifiers[0].effects[0]["status"] = "unbuilt"
	assert_eq(Effects.damage_taken(other, 20, lit), 20, "a status the engine lacks never holds")


## The form-changing tank (the Polar Bear's Lockdown; Ryan's framework of 15 October, his go 20
## October; its trigger since the refit pass, Ryan, 11 November: "target equipment at itself to
## seal. And then the only way to open is with a weapon. Offensive equipment like it's lure remain
## neutral"): a buff spent on itself seals the machine, one chip carrying the passive's armour;
## sealed, its own cooling stops and it runs hotter at the end of each turn, before the overheat; a
## weapon opens it; a buff on an ally, a debuff (its lure) and a shield or a vent, kinds no die is
## dealt, leave the form alone. Synthetic pieces and passive, so content may move.
func test_a_buff_on_itself_seals_the_machine_and_a_weapon_opens_it() -> void:
	var sk := Skirmish.new(1)
	var buff := Face.buff("overcharged", 1)
	var vent := Face.from_dict({"kind": "vent", "power": 5})
	var gun := Face.attack(10, L)
	var lure := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "cryo"], "heat": 5, "cryo": 1})
	var shield := Face.shield(20)
	var m := _mech("A", Die.of([buff, vent, gun, lure, shield]), 0, 200)
	m.grant_passive({"id": "radiator", "name": "Radiator", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 5}]}, "radiator")   # cooling is granted: a chassis has none of its own
	m.grant_passive({"id": "lockdown", "name": "Lockdown", "description": "", "effects": [
		{"trigger": "static", "effect": "seal_form"}]})
	var b := _mech("B", Die.single(Face.attack(10, L)), 40, 100)
	sk.add_mech(m)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 20)])
	sk.begin()
	sk.start_round()
	var ms := sk.mechs[0]
	var A := Effects.status_value_static("sealed", "add_stat")
	var H := int(Effects.STATUS["sealed"]["seal_heat"])
	assert_eq(Effects.seal_form(m), {"armour": A, "heat": H}, "Sealed's own numbers, whatever passive lets it seal")
	assert_false(Effects.is_sealed(m), "open to begin with")
	assert_eq(Skirmish.form_change(ms, buff), "seal", "a buff of its own on itself would seal it")
	assert_eq(Skirmish.form_change(ms, buff, false), "", "the same buff on an ally would not")
	assert_eq(Skirmish.form_change(ms, shield), "", "nor a shield on itself")
	ms.face_index = 0
	assert_true(sk.assign(0, sk.mechs[1]), "a buff on the ally")
	assert_false(Effects.is_sealed(m), "does not seal it")
	sk.end_round()
	sk.start_round()
	ms.face_index = 4
	assert_true(sk.assign(0, null), "a shield on itself")
	assert_false(Effects.is_sealed(m), "seals nothing: no die is dealt one since the refit pass")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	assert_true(sk.assign(0, null), "a buff on itself")
	assert_true(Effects.is_sealed(m), "seals it")
	assert_eq(m.armour, A, "the seal's armour, read through the stat")
	assert_true("\n".join(sk.log).contains("A seals: armour +%d" % A), "the log says so")
	assert_eq(sk.forecast(ms)["heat_end"], H, "the forecast reads the seal's heat at the turn's end")
	sk.end_round()
	assert_eq(ms.heat, H, "sealed, it ran hotter at the end of its turn")
	assert_true(Effects.is_sealed(m), "and stays sealed through the enemy's turn")
	sk.start_round()
	assert_eq(ms.heat, H, "its cooling stopped: nothing shed at the round's start")
	ms.face_index = 3
	assert_true(sk.assign(0, sk.front[0]), "a lure, a debuff")
	assert_true(Effects.is_sealed(m), "keeps the seal")
	assert_eq(Effects.stacks_of(sk.front[0], "cryoed"), 1, "and leaves Cryo on the foe")
	sk.end_round()
	assert_eq(ms.heat, 2 * H + 5, "the lure's 5 and the seal's again")
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, null), "a vent on itself")
	assert_true(Effects.is_sealed(m), "opens nothing")
	assert_eq(ms.heat, 2 * H, "though its 5 come off")
	sk.end_round()
	assert_eq(ms.heat, 3 * H, "and the seal's go back on")
	sk.start_round()
	ms.face_index = 2
	assert_eq(Skirmish.form_change(ms, gun), "open", "sealed, a weapon would open it")
	assert_true(sk.assign(0, sk.front[0]), "a weapon")
	assert_false(Effects.is_sealed(m), "opens it")
	assert_eq(m.armour, 0, "the seal's armour goes with it")
	assert_true("\n".join(sk.log).contains("A opens"), "the log says so")
	sk.end_round()
	assert_eq(ms.heat, 3 * H - Skirmish.cryo_cool(), "open, nothing more at the turn's end, and the Cryo its gun met cooled it")
	sk.start_round()
	assert_eq(ms.heat, maxi(0, 3 * H - Skirmish.cryo_cool() - 5), "and its cooling runs again")
	ms.face_index = 0
	assert_true(sk.assign(0, null), "sealed again")
	assert_true(Effects.is_sealed(m), "one seal, renewed")
	assert_eq(m.modifiers.filter(func(x): return x.id == "sealed").size(), 1, "one modifier however often it seals")


## A passive's grant scoped to one of its machine's pieces and held while it is sealed (the
## Polar Bear's Lockdown, Ryan, 9 November: "Cryo flinger: No rapid. While sealed, gains Spread"):
## open, its lure turns the one foe it is aimed at; sealed, the foes beside it in its rank too, each
## taking the entry's Cryo; the grant reaches that piece alone, never the machine's gun, and goes as
## the seal opens. Synthetic pieces and passive, so content may move.
func test_a_grant_scoped_to_one_piece_holds_on_it_alone_while_sealed() -> void:
	var sk := Skirmish.new(1)
	var lure := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "cryo"], "heat": 1, "cryo": 1})
	lure.component = "test_flinger"
	var buff := Face.buff("overcharged", 1)
	var gun := Face.attack(10, I)
	gun.component = "test_gun"
	var m := _mech("A", Die.of([lure, buff, gun]), 0, 200)
	m.grant_passive({"id": "lockdown", "name": "Lockdown", "description": "", "effects": [
		{"trigger": "static", "effect": "seal_form"},
		{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "sealed", "entry": "test_flinger"}]})
	sk.add_mech(m)
	sk.add_mech(_mech("B", Die.single(Face.attack(10, L)), 40, 100))
	sk.add_foes([_ghoul(500, 5), _ghoul(500, 5), _ghoul(500, 5), _ghoul(500, 5)])
	sk.begin()
	sk.start_round()
	var ms := sk.mechs[0]
	var aim: Foe = sk.front[1]
	assert_false(Effects.effective_face(m, lure, aim).has(K.CLEAVE), "open, the lure carries no Spread")
	assert_eq(sk.reached_by(Effects.effective_face(m, lure, aim), aim).size(), 1, "and reaches its one foe")
	ms.face_index = 0
	assert_true(sk.assign(0, aim), "the lure, open")
	assert_eq(aim.target, ms, "its foe turns on it")
	for k in [0, 2, 3]:
		assert_eq(Effects.stacks_of(sk.front[k], "cryoed"), 0, "a foe beside it takes nothing (column %d)" % k)
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, null), "a buff on itself")
	assert_true(Effects.is_sealed(m), "seals it")
	assert_true(Effects.effective_face(m, lure, aim).has(K.CLEAVE), "sealed, the lure gains Spread")
	assert_false(Effects.effective_face(m, gun, aim).has(K.CLEAVE), "and the gun does not: the grant names its piece")
	assert_eq(Effects.effective_face(m, lure, aim).power, 0, "the lure still deals nothing")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	assert_true(sk.assign(0, aim), "the lure, sealed")
	for k in [0, 1, 2]:
		assert_eq(sk.front[k].target, ms, "the foe in column %d turns on it" % k)
	assert_eq(Effects.stacks_of(sk.front[0], "cryoed"), 1, "the neighbours take its Cryo")
	assert_eq(Effects.stacks_of(sk.front[2], "cryoed"), 1, "on both sides")
	assert_eq(Effects.stacks_of(aim, "cryoed"), 2, "the foe it was aimed at gains a second stack")
	assert_eq(Effects.stacks_of(sk.front[3], "cryoed"), 0, "the foe past the neighbours, nothing")
	assert_true(Effects.is_sealed(m), "a lure leaves the seal as it is")
	var notes := Effects.explain(m, lure)
	assert_true(notes.has("while sealed: gains spread (Lockdown)"), "the entry's row says the grant with its condition: %s" % str(notes))
	sk.end_round()
	sk.start_round()
	ms.face_index = 2
	assert_true(sk.assign(0, sk.front[3]), "the gun")
	assert_false(Effects.is_sealed(m), "opens it")
	assert_false(Effects.effective_face(m, lure, aim).has(K.CLEAVE), "and the Spread goes with the seal")


## Its weapons deal 1 more to a foe carrying Cryo (the Polar Bear's Lockdown, Ryan, 9 November): an
## add on the blow, the attacker's condition read on the foe as each strike lands, so the strike
## that meets the Cryo takes it and its hit spends the stacks; a later strike of the same spend
## meets none and lands plain; a foe with none takes the plain blow, and a debuff deals nothing still.
func test_its_weapons_hit_a_foe_carrying_cryo_one_harder_on_the_strike_that_cashes_it() -> void:
	var sk := Skirmish.new(1)
	var gun := Face.attack(2, L)
	var twin := Face.from_dict({"kind": "attack", "reach": "direct", "power": 2, "strikes": 2, "keywords": [], "heat": 0})
	var lure := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "cryo"], "heat": 1, "cryo": 1})
	var m := _mech("A", Die.of([gun, twin, lure]), 0, 200)
	m.grant_passive({"id": "lockdown", "name": "Lockdown", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_status", "status": "cryoed"}]})
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 0), _ghoul(20, 0)])
	sk.begin()
	sk.start_round()
	var ms := sk.mechs[0]
	var cold: Foe = sk.front[0]
	var clean: Foe = sk.front[1]
	Effects.stack(cold, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	ms.heat = 8
	assert_eq(sk.shown_number(ms, gun, cold), 3, "over a foe carrying Cryo the die shows the blow 1 harder")
	assert_eq(sk.shown_number(ms, gun, clean), 2, "and over a clean foe the plain blow")
	ms.face_index = 0
	assert_true(sk.assign(0, cold), "the gun on the cold foe")
	assert_eq(cold.hp, 17, "it lands 3")
	assert_eq(Effects.stacks_of(cold, "cryoed"), 0, "and its hit spent the Cryo")
	assert_eq(ms.heat, 8 - Effects.status_value("cryoed", "cool_hitter"), "cooling the hitter as ever")
	sk.end_round()
	sk.start_round()
	Effects.stack(cold, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	ms.face_index = 1
	assert_true(sk.assign(0, cold), "two strikes on a foe carrying Cryo")
	assert_eq(cold.hp, 12, "the first strike 1 harder, its hit spending the Cryo, the second plain")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	assert_true(sk.assign(0, cold), "again, the Cryo spent")
	assert_eq(cold.hp, 10, "the plain 2")
	sk.end_round()
	sk.start_round()
	Effects.stack(clean, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	ms.face_index = 2
	assert_true(sk.assign(0, clean), "the lure on a foe carrying Cryo")
	assert_eq(clean.hp, 20, "a debuff deals nothing, Cryo or none")
	assert_eq(Effects.effect_text(m.modifiers[0].effects[0]), "foes carrying Cryo: damage +1", "the rule reads with the status it names")


## Cryo (Ryan, 18 and 20 October): the Cryo Flinger's mark pays in cooling. Any machine's
## weapon's hit on a foe carrying Cryo spends every stack and cools the hitter its number a stack, after
## the spend's own heat lands; a blow of nothing spends none, and the keyword's number is the
## stacks each foe reached gains.
func test_a_weapons_hit_cashes_a_foes_cryo_for_the_hitters_cooling() -> void:
	var sk := Skirmish.new(1)
	var flinger := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "rapid", "cryo"], "heat": 5, "cryo": 1})
	assert_eq(flinger.describe(), "indirect lure rapid cryo 1 (+5 heat)", "the entry says its stacks")
	assert_eq(Face.from_dict(flinger.to_dict()).cryo, 1, "the number round-trips")
	var a := _mech("A", Die.of([flinger, Face.shield(20)]), 0, 200)
	var b := _mech("B", Die.single(Face.attack(10, L, [], 5)), 40, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	sk.mechs[1].heat = 30
	var g: Foe = sk.front[0]
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, g), "the flinger")
	assert_eq(Effects.stacks_of(g, "cryoed"), 1, "the foe carries Cryo")
	assert_true(Effects.carries_status(g), "a status the team put on it")
	assert_eq(sk.mechs[0].heat, 5, "the flinger's heat landed, no cash on a blow of nothing")
	# Rapid gave the turn back: a second fling lays a second stack and cashes nothing.
	sk.mechs[0].face_index = 0
	Effects.remove(a, "disabled_0")
	sk.mechs[0].assigned = false
	assert_true(sk.assign(0, g), "flung again")
	assert_eq(Effects.stacks_of(g, "cryoed"), 2, "two stacks, nothing spent by a debuff")
	assert_true(sk.assign(1, g), "B's gun, 10 damage for 5 heat")
	assert_eq(Effects.stacks_of(g, "cryoed"), 0, "the hit spent every stack")
	var cool := Effects.status_value("cryoed", "cool_hitter")
	assert_eq(sk.mechs[1].heat, 30 + 5 - 2 * cool, "B cooled Cryo's number a stack after its own heat landed")
	assert_true("\n".join(sk.log).contains("B cashes Cryo ×2: -%d heat" % (2 * cool)), "the log says so")
	sk.end_round()
	sk.start_round()
	sk.mechs[1].heat = 3
	Effects.stack(g, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 8 / cool + 1, Effects.DECAY_NONE)   # more than the 8 the shot leaves
	assert_true(sk.assign(1, g), "a cash worth more than the heat held")
	assert_eq(sk.mechs[1].heat, 0, "cools to zero, the rest wasted")
	# The bot values the cash as a vent of that much on the hitter.
	var s2 := Skirmish.new(2)
	var c := _mech("C", Die.single(Face.attack(10, L)), 40, 100)
	s2.add_mech(c)
	s2.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	s2.mechs[0].heat = 50
	var pol := Policy.make(Policy.GREEDY)
	var cold := pol.attack_score(s2, s2.mechs[0], c.die.faces[0], s2.front[0])
	Effects.stack(s2.front[1], Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	assert_true(pol.attack_score(s2, s2.mechs[0], c.die.faces[0], s2.front[1]) > cold, "the hot machine prefers the foe carrying Cryo")


## Brittle (Ryan's go, 19 October; built 21 October): Brittle N lays N stacks on each foe hit, whatever
## the blow dealt, after the blow, and every blow the foe takes deals a point more a stack: an
## add before the multiplies (a Shocked foe takes a weapon's strike aimed at it plus Brittle,
## doubled) and before its armour, folded into the die's number over it; a blow of nothing stays
## nothing.
func test_brittle_lays_its_number_on_each_foe_hit_and_every_blow_it_takes_lands_harder() -> void:
	var sk := Skirmish.new(1)
	var spray := Face.attack(5, L, [K.CLEAVE, K.BRITTLE])
	spray.brittle = 2
	spray.cleave = 2
	var gun := Face.attack(10, L)
	var lure := Face.attack(0, I, K.LURE)
	sk.add_mech(_mech("A", Die.single(spray), 0, 200))
	sk.add_mech(_mech("B", Die.single(gun), 0, 200))
	sk.add_mech(_mech("C", Die.single(lure), 0, 200))
	sk.add_foes([_ghoul(100), _ghoul(100), _ghoul(100)])
	sk.begin()
	sk.start_round()
	var mid: Foe = sk.front[1]
	assert_true(sk.assign(0, mid), "spray the middle")
	assert_eq(mid.hp, 95, "the blow that lays the Brittle never feeds on it: a plain 5")
	assert_eq(sk.front[0].hp, 98, "the spray's neighbour takes its Spread 2 (area by shape, numbered)")
	for foe in [sk.front[0], mid, sk.front[2]]:
		assert_eq(Effects.stacks_of(foe, "brittled"), 2, "each foe hit carries Brittle 2")
	assert_true(Effects.carries_status(mid), "a status the team put on it, for the Tensor")
	assert_eq(sk.shown_number(sk.mechs[1], gun, mid), 12, "the die over a Brittle foe folds in its 2")
	assert_true(sk.assign(1, mid), "the gun on it")
	assert_eq(mid.hp, 83, "every blow it takes deals a point more a stack: 10 and 2")
	assert_true(sk.assign(2, sk.front[2]), "a lure on another")
	assert_eq(sk.front[2].hp, 98, "a blow of nothing stays nothing, Brittle or not")
	assert_eq(Effects.damage_taken(mid, 0), 0, "nothing in, nothing out")
	Effects.stack(mid, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_eq(Effects.damage_taken(mid, 10, null, true), 24, "adds before multiplies: a Shocked foe takes a weapon's strike aimed at it plus Brittle, doubled")
	assert_eq(Effects.damage_taken(mid, 10, null, true, false), 12, "a blow that only reaches it: the Brittle, never the Shock")
	mid.armour = 5
	assert_eq(sk.shown_number(sk.mechs[1], gun, mid), 7, "its armour comes off after the Brittle, and the shock stays on its chip")


## A spend of several strikes lays its Brittle a stack a strike once the strikes are done (Ryan, 3
## November: riders land after the hits), so no strike of the spend feeds on what it lays.
func test_a_later_strike_of_a_brittle_spend_lands_plain_and_the_brittle_lands_after() -> void:
	var sk := Skirmish.new(1)
	var burst := _strikes(Face.attack(5, L, K.BRITTLE), 3)
	burst.brittle = 1
	sk.add_mech(_mech("A", Die.single(burst), 0, 200))
	var g := _ghoul(100)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, g), "three strikes")
	assert_eq(g.hp, 100 - 5 - 5 - 5, "5, 5 and 5: the Brittle lands after the hits")
	assert_eq(Effects.stacks_of(g, "brittled"), 3, "a stack a strike")


## Brittle halves as its carrier's turn starts, rounded down, until gone (Ryan, 16 November, his
## four places, Brittle with what ends at a turn's start): the other side's blows have used it by
## then. A foe's halves as the foes' turn opens and its own turn's end leaves it alone; a
## machine's halves as the round opens.
func test_brittle_halves_as_its_turn_starts_rounded_down_until_gone() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 500))
	var g := _ghoul(500, 1)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.stack(g, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 5, Effects.DECAY_HALF)
	Effects.tick(g, false)
	Effects.halve_buffs(g)
	assert_eq(Effects.stacks_of(g, "brittled"), 5, "a foe's own turn's end leaves its Brittle alone")
	sk._end_player_turn()
	assert_eq(Effects.stacks_of(g, "brittled"), 5, "it stands whole through the player's turn, END TURN included")
	sk._enemy_turn()
	assert_eq(Effects.stacks_of(g, "brittled"), 2, "the foes' turn opening halves it, rounded down")
	sk._finish_round()
	assert_eq(Effects.stacks_of(g, "brittled"), 2, "and the round's end halves nothing")
	sk.state = Skirmish.State.ROUND_START   # the round stepped by hand: end_round's own last line
	sk.start_round()
	assert_eq(Effects.stacks_of(g, "brittled"), 2, "nor a round's opening, the machines' turn start, a foe's")
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "brittled"), 1, "two to one")
	sk.start_round()
	sk.end_round()
	assert_false(Effects.has(g, "brittled"), "and one halves to none")
	# A machine's turn starts as the round opens: its Brittle halves there, the foes' blows having
	# used it. Its Empowered is a buff, and halves as its own turn ends (tests/test_clocks.gd).
	var ov := _mech("B", Die.single(Face.shield(10)), 0, 100)
	Effects.stack(ov, Effects.STATUS["brittled_mech"], Effects.SKIRMISH, "foe", 4, Effects.DECAY_HALF)
	Effects.stack(ov, Effects.STATUS["overcharged"], Effects.SKIRMISH, "buff", 4, Effects.DECAY_HALF)
	Effects.tick(ov, true)
	assert_eq([Effects.stacks_of(ov, "brittled_mech"), Effects.stacks_of(ov, "overcharged")], [4, 4], "the round's end halves neither")
	Effects.turn_opens(ov)
	assert_eq([Effects.stacks_of(ov, "brittled_mech"), Effects.stacks_of(ov, "overcharged")], [2, 4], "a machine's Brittle halves as its turn starts, its Empowered not there")
	Effects.halve_buffs(ov)
	assert_eq([Effects.stacks_of(ov, "brittled_mech"), Effects.stacks_of(ov, "overcharged")], [2, 2], "its Empowered halves as its turn ends, its Brittle left alone")


## Brittle runs on the clock its status names (the stock pass's loop reads a stack a round against
## the halving, 22 October): a spend lays stacks carrying the definition's decay, and what a
## clock keeps into the next round reads from a definition alone.
func test_brittle_laid_carries_the_clock_its_status_names() -> void:
	var sk := Skirmish.new(1)
	var spray := Face.attack(1, L, K.BRITTLE)
	spray.brittle = 3
	sk.add_mech(_mech("A", Die.single(spray), 0, 200))
	var g := _ghoul(100)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, g), "Brittle laid")
	var clocks: Array = []
	for m in g.modifiers:
		if m.id == "brittled":
			clocks.append(m.decay)
	assert_eq(clocks, [Effects.status_decay(Effects.STATUS["brittled"])], "one stack of Brittle on the status's own clock")
	assert_eq(Effects.stacks_next_round({"decay": "half"}, 5), 2, "a halving clock keeps half, rounded down")
	assert_eq(Effects.stacks_next_round({}, 5), 4, "a clock that names none loses a stack")
	assert_eq(Effects.stacks_next_round({"decay": "round"}, 5), 0, "a round's clock keeps nothing")
	assert_eq(Effects.stacks_next_round({"decay": "none"}, 5), 5, "and none keeps it all")
	assert_eq(Effects.stacks_next_round({}, 0), 0, "never below none")


## The Barrier (Ryan, 14 October; built 21 October): the next blow a foe lands deals nothing,
## so a rider that reads the hull (Destroy) finds none, its other riders land, and it is spent; a
## blow of nothing leaves it standing, a second grant renews it, and its machine's next turn
## start takes it (16 November; the round's end until then, which no blow parted from it).
func test_a_barrier_takes_the_next_blow_whole_and_its_riders_land() -> void:
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.buff("barrier")), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_storm(50, 2, ["scorch", "destroy"])])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.mechs[0]), "the Barrier goes up")
	assert_true(Effects.has(m, "barrier"), "a buff grants it")
	var fc := sk.forecast(sk.mechs[0])
	assert_eq(int(fc["hull_after"]), 50, "the forecast reads it: the first fifty taken whole, the second on bare hull")
	sk.end_round()
	assert_eq(m.hull, 50, "the first blow dealt nothing; the second landed")
	assert_eq(m.damaged_component_count(), 1, "the second destroyed the entry showing; the first, on no hull, never could")
	assert_eq(Effects.stacks_of(m, "scorched"), 2, "both blows' riders landed")
	assert_false(Effects.has(m, "barrier"), "spent by the blow it took")
	assert_true(sk.turn_events[0]["barred"] and not sk.turn_events[1]["barred"], "the events say which blow it took")
	assert_true(str(sk.log).contains("the Barrier takes the blow"), "and so does the log")
	var s2 := Skirmish.new(1)
	var b := _mech("B", Die.single(Face.attack(10, L)), 0, 100)
	s2.add_mech(b)
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	Effects.grant_buff(b, "barrier", 1, "test", s2.round)
	s2._damage_mech(s2.mechs[0], 0, s2.front[0])
	assert_true(Effects.has(b, "barrier"), "a blow of nothing leaves it standing")
	Effects.grant_buff(b, "barrier", 1, "test", s2.round)
	assert_eq(Effects.stacks_of(b, "barrier"), 1, "a second grant renews it: one Barrier, never two")
	s2._suppress(s2.front[0])
	s2.end_round()
	assert_true(Effects.has(b, "barrier"), "unspent, it stands past the round's end")
	assert_eq(b.hull, 100, "nothing struck")
	s2.start_round()
	assert_false(Effects.has(b, "barrier"), "and its next turn's start takes it")


## The Ward (Ryan, 14 October; built 21 October): every blow a foe lands on the machine that
## round leaves no rider; the damage lands, on the shield and then the hull like any blow.
func test_a_ward_turns_away_every_rider_for_the_round() -> void:
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.buff("ward")), 30, 100)
	sk.add_mech(m)
	sk.add_foes([_storm(20, 2, ["scorch", "corrupt"])])
	sk.begin()
	sk.start_round()
	var bare := sk.forecast(sk.mechs[0])
	assert_true(sk.assign(0, sk.mechs[0]), "the Ward goes up")
	var fc := sk.forecast(sk.mechs[0])
	assert_eq([int(fc["shield_after"]), int(fc["hull_after"])], [int(bare["shield_after"]), int(bare["hull_after"])], "a Ward moves no blow's arithmetic")
	assert_eq([int(fc["shield_after"]), int(fc["hull_after"])], [0, 90], "the shield takes thirty of the forty and ten pass")
	sk.end_round()
	assert_eq(m.shield, 0, "the shield absorbed its thirty")
	assert_eq(m.hull, 90, "the damage landed")
	assert_eq(Effects.stacks_of(m, "scorched"), 0, "no scorch")
	assert_eq(Effects.corrupt_stacks(m, 0), 0, "no corruption")
	assert_true("\n".join(sk.log).contains("the Ward turns storm's riders away"), "the log says so")
	assert_true(Effects.has(m, "ward"), "it stands past the round's end")
	sk.start_round()
	assert_false(Effects.has(m, "ward"), "and its next turn's start takes it")
	sk.end_round()
	assert_eq(m.hull, 50, "unwarded the next round, both blows land on bare hull")
	assert_eq(Effects.stacks_of(m, "scorched"), 2, "and both riders land")


## The Ward turns away every rider, a special's too (Ryan, 25 October: "Should stop all riders,
## even from non-damaging attacks"): a Stoke's Ablating, a Stone's switch-off, an Eruption's
## Scorched and a Diamond Dust's Corrupted, on the warded machine while the bare one beside it
## takes the all-machine ones; and a Phased machine is out of a special on every machine as it
## is out of a blow at every machine (the mechanics audit, 25 October).
func test_a_ward_turns_away_a_specials_riders_and_phased_is_out_of_them() -> void:
	for effect in ["ablate", "jam", "scorch_all", "corrupt_all"]:
		var sk := Skirmish.new(1, 1)
		var warded := _mech("W", Die.single(Face.buff("ward")), 30, 100)
		var bare := _mech("B", Die.single(Face.attack(1, L)), 30, 100)
		sk.add_mech(warded)
		sk.add_mech(bare)
		var caster := _ghoul(500, 10)
		caster.actions = [_special("debuff", effect, {"value": 2})]
		caster.action = caster.actions[0]
		sk.add_foes([caster])
		sk.begin()
		sk.start_round()
		caster.target = sk.mechs[0]
		assert_true(sk.assign(0, sk.mechs[0]), "the Ward goes up")
		sk.end_round()
		assert_eq(Effects.stacks_of(warded, "ablating_mech"), 0, "%s: no Ablating on the warded" % effect)
		assert_false(Effects.is_entry_disabled(warded, 0), "%s: nothing switched off" % effect)
		assert_eq(Effects.stacks_of(warded, "scorched"), 0, "%s: no Scorched" % effect)
		assert_eq(Effects.corrupt_stacks(warded, 0), 0, "%s: no Corrupted" % effect)
		assert_true("\n".join(sk.log).contains("W's Ward turns it away"), "%s: the log says so" % effect)
		if effect == "scorch_all":
			assert_eq(Effects.stacks_of(bare, "scorched"), 2, "the bare machine is scorched")
		if effect == "corrupt_all":
			assert_eq(Effects.corrupt_stacks(bare, 0), 2, "the bare machine's entry is corrupted")
	var sk3 := Skirmish.new(1, 1)
	var out := _mech("P", Die.single(Face.attack(1, L)), 30, 100)
	var left := _mech("Q", Die.single(Face.attack(1, L)), 30, 100)
	sk3.add_mech(out)
	sk3.add_mech(left)
	var erupter := _ghoul(500, 10)
	erupter.actions = [_special("debuff", "scorch_all", {"value": 2})]
	erupter.action = erupter.actions[0]
	sk3.add_foes([erupter])
	sk3.begin()
	sk3.start_round()
	Effects.grant_buff(out, "phased", 1, "test", sk3.round)
	sk3.end_round()
	assert_eq(Effects.stacks_of(out, "scorched"), 0, "the Phased machine is out of the eruption")
	assert_eq(Effects.stacks_of(left, "scorched"), 2, "the other takes it")


## The cooldown (Ryan, 14 October; built 21 October; counted after the round of the spend since 12
## November: "change the count so 1 is how I intended"): a printed property, the entry dark for the
## rest of the round and the rounds it says after it, shown with the rounds left, this one
## included; no cleanse lifts it, a price as heat is.
func test_a_printed_cooldown_darkens_its_entry_for_the_rounds_it_says() -> void:
	var gun := Face.attack(10, L)
	gun.cooldown = 1
	assert_eq(gun.describe(), "10 cooldown 1", "the entry says its cooldown")
	assert_false(gun.has_unique_rule(), "a cost, its clock along the die's foot, never the star (2 November)")
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.of([gun, Face.attack(10, L)]), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "spent")
	assert_true(Effects.is_entry_disabled(m, 0), "dark at once")
	assert_eq(Effects.dark_rounds(m, 0, sk.round), 2, "two rounds left, this one included: the rest of this one and the one it sits out")
	assert_false(Effects.cleansable_disable(m, 0), "and no cleanse lifts it")
	assert_eq(Effects.dark_rounds(m, 1, sk.round), 0, "the other entry is lit")
	sk.end_round()
	sk.start_round()
	assert_true(Effects.is_entry_disabled(m, 0), "it sits out the next round")
	assert_eq(Effects.dark_rounds(m, 0, sk.round), 1, "its last")
	ms.face_index = 0
	assert_true(ms.face().disabled, "the die landing on it shows it dark")
	sk.end_round()
	sk.start_round()
	assert_false(Effects.is_entry_disabled(m, 0), "lit again the round after")
	var round_trip := Face.from_dict(gun.to_dict())
	assert_eq(round_trip.cooldown_rounds(), 1, "and a save keeps it")


## Rapid's own switch-off (Ryan, 12 November: "rapid gets its innate cooldown zero back without the
## explicit display"): a Rapid entry spent is dark for the rest of the round, never printed (no
## clock along its foot, no word in its text), lit the next; a cooldown it prints sits out that
## many rounds after; copies chain, each dark once spent, its heat paid every spend.
func test_rapid_switches_its_entry_off_for_the_round_and_prints_nothing() -> void:
	var zap := Face.attack(10, L, [K.RAPID])
	assert_eq(zap.cooldown_rounds(), 0, "Rapid prints no cooldown: its switch-off is the keyword's")
	assert_eq(zap.describe(), "10 rapid", "and says none")
	assert_false(zap.has_unique_rule(), "a keyword, never the star")
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.of([zap, Face.attack(10, L)]), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "spent")
	assert_eq(Effects.dark_rounds(m, 0, sk.round), 1, "dark for the rest of this round")
	assert_false(Effects.cleansable_disable(m, 0), "and no cleanse lifts it")
	assert_false(ms.assigned, "and the machine acts again")
	sk.end_round()
	sk.start_round()
	assert_false(Effects.is_entry_disabled(m, 0), "lit the next round")
	# A Rapid piece may print a cooldown on top: the rounds it sits out after.
	var slow := Face.attack(10, L, [K.RAPID])
	slow.cooldown = 1
	assert_eq(slow.describe(), "10 rapid cooldown 1", "said as the piece's")
	var s1 := Skirmish.new(1)
	var p := _mech("C", Die.of([slow, Face.attack(10, L)]), 40, 100)
	s1.add_mech(p)
	s1.add_foes([_ghoul(500, 1)])
	s1.begin()
	s1.start_round()
	s1.mechs[0].face_index = 0
	assert_true(s1.assign(0, s1.front[0]), "spent")
	assert_eq(Effects.dark_rounds(p, 0, s1.round), 2, "dark this round and the next")
	s1.end_round()
	s1.start_round()
	assert_true(Effects.is_entry_disabled(p, 0), "sitting out the next round")
	s1.end_round()
	s1.start_round()
	assert_false(Effects.is_entry_disabled(p, 0), "lit the round after")
	# Two copies chain, each dark once spent, its heat paid every spend.
	var hot := Face.from_dict({"kind": "attack", "reach": "direct", "power": 10, "keywords": ["rapid"], "heat": 5})
	assert_eq(hot.describe(), "10 rapid (+5 heat)", "a hot Rapid piece says its heat and no cooldown")
	var s2 := Skirmish.new(1)
	var n := _mech("B", Die.of([hot, hot.duplicate_face()]), 40, 100)
	s2.add_mech(n)
	s2.add_foes([_ghoul(500, 1)])
	s2.begin()
	s2.start_round()
	var ns: Skirmish.MechState = s2.mechs[0]
	ns.face_index = 0
	var heat_before := ns.heat
	assert_true(s2.assign(0, s2.front[0]), "the first copy")
	assert_eq(ns.face_index, 1, "the free reroll onto the other copy")
	assert_true(s2.assign(0, s2.front[0]), "the second copy chains")
	assert_eq(ns.heat - heat_before, 10, "two spends at five heat each")
	assert_true(Effects.is_entry_disabled(n, 0) and Effects.is_entry_disabled(n, 1), "each copy dark once spent")
	assert_true(s2.targets_for(0).is_empty(), "the chain ends on a dark copy")


const STEP_PASSIVE := {"id": "test_step", "name": "Step", "description": "", "effects": [{"trigger": "static", "effect": "step_die", "value": 1}]}


## A stepping die (the Cassowary's Indexed Cylinder, Ryan's wording of 12 October; built 21
## October): the fight's first roll spins it to a random entry, then every roll steps it to the
## next in order: the round's roll, a reroll, Rapid's free reroll; a lock holds it.
func test_a_stepping_die_spins_once_then_steps_on_every_roll() -> void:
	var opened := {}
	for seed_value in range(40):
		var s0 := Skirmish.new(seed_value)
		var u0 := _mech("A", Die.of([Face.attack(10, L), Face.attack(20, L), Face.attack(30, L), Face.attack(40, L)]), 40, 100)
		u0.grant_passive(STEP_PASSIVE)
		s0.add_mech(u0)
		s0.add_foes([_ghoul(500, 1)])
		s0.begin()
		s0.start_round()
		opened[s0.mechs[0].face_index] = true
	assert_eq(opened.size(), 4, "the fight opens on a random chamber: every one, over forty fights")
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.of([Face.attack(10, L), Face.attack(20, L), Face.attack(30, L), Face.attack(40, L)]), 40, 100)
	u.grant_passive(STEP_PASSIVE)
	var other := _mech("B", Die.of([Face.attack(10, L), Face.attack(20, L)]), 40, 100)
	sk.add_mech(u)
	sk.add_mech(other)
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var at := ms.face_index
	assert_eq(sk.next_face(ms).power, ms.die.faces[(at + 1) % 4].power, "the screen reads the next chamber before it turns")
	assert_true(sk.reroll([0]), "a reroll")
	assert_eq(ms.face_index, (at + 1) % 4, "steps it one")
	var held := ms.face_index
	assert_true(sk.reroll([1]), "the other die rerolled, this one locked")
	assert_eq(ms.face_index, held, "a lock holds it")
	sk.end_round()
	sk.start_round()
	assert_eq(ms.face_index, (held + 1) % 4, "the round's roll steps it too")
	sk.rerolls_left = 3
	var from := ms.face_index
	sk.reroll([0])
	assert_eq(ms.face_index, (from + 1) % 4, "and every reroll after it steps one more")
	var fast := Face.attack(10, L, [K.RAPID])
	var s2 := Skirmish.new(2)
	var r := _mech("R", Die.of([fast, Face.attack(20, L), Face.attack(30, L)]), 40, 100)
	r.grant_passive(STEP_PASSIVE)
	s2.add_mech(r)
	s2.add_foes([_ghoul(500, 1)])
	s2.begin()
	s2.start_round()
	s2.mechs[0].face_index = 0
	assert_true(s2.assign(0, s2.front[0]), "a Rapid chamber fires")
	assert_eq(s2.mechs[0].face_index, 1, "and its free reroll steps the die to the next")


## Instant (Ryan, 12 November: "reroll after use, can land on itself"; the Spin-Up's spin of 19
## October its first form): spent, the die rolls true over every entry, itself included, a spin on
## a stepping die, and the machine acts again.
func test_an_instant_entry_rolls_true_and_may_land_on_itself() -> void:
	var spin := Face.from_dict({"kind": "buff", "status": "spun_up", "stacks": 1, "targets": "self", "keywords": ["instant"]})
	assert_true(spin.has(K.INSTANT) and not spin.has_unique_rule(), "a keyword, never the star")
	assert_eq(spin.describe(), "Spun Up ×1 instant (self only)", "the entry says it (Ryan, 8 November: \"we just need to make it clear\")")
	for stepping in [true, false]:
		var landed := {}
		var said := ""
		for seed_value in range(60):
			var sk := Skirmish.new(seed_value)
			var u := _mech("A", Die.of([spin, Face.attack(10, L), Face.attack(20, L)]), 40, 100)
			if stepping:
				u.grant_passive(STEP_PASSIVE)
			sk.add_mech(u)
			sk.add_foes([_ghoul(500, 1)])
			sk.begin()
			sk.start_round()
			sk.mechs[0].face_index = 0
			assert_true(sk.assign(0, sk.mechs[0]), "the spin is spent")
			assert_false(sk.mechs[0].assigned, "and the machine acts again")
			landed[sk.mechs[0].face_index] = true
			said = "\n".join(sk.log)
		assert_eq(landed.size(), 3, "it lands anywhere, itself included%s: %s" % [" (a stepping die)" if stepping else "", str(landed.keys())])
		assert_true(said.contains("the cylinder spins" if stepping else "instant, rolls again"), "the log says how it rolled")


## Spun Up (the Cassowary's, Ryan's go of 19 October; built 21 October): its number a stack on
## the next weapon the machine spends, stacking, carried between turns until one takes it;
## equipment leaves it standing (Ryan, 26 October: "Spun up only interacts with damage").
func test_spun_up_lasts_until_a_weapon_takes_it_and_adds_its_number_a_stack() -> void:
	var sk := Skirmish.new(1)
	var u := _mech("A", Die.of([Face.attack(10, L), Face.attack(0, I, [K.LURE])]), 40, 100)
	sk.add_mech(u)
	var g := _ghoul(500, 1)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.grant_buff(u, "spun_up", 1, "buff", sk.round)
	Effects.grant_buff(u, "spun_up", 1, "buff", sk.round)
	assert_eq(Effects.stacks_of(u, "spun_up"), 2, "it stacks")
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(u, "spun_up"), 2, "and carries between turns")
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	var su := _rule("spun_up", "add_damage")
	assert_eq(sk.shown_number_text(ms, ms.face(), g), str(10 + 2 * su), "the die shows what its two stacks add")
	assert_true(sk.assign(0, g), "a shot")
	assert_eq(g.hp, 500 - (10 + 2 * su), "ten and its two stacks'")
	assert_false(Effects.has(u, "spun_up"), "spent whole")
	sk.end_round()
	sk.start_round()
	Effects.grant_buff(u, "spun_up", 1, "buff", sk.round)
	ms.face_index = 1
	assert_true(sk.assign(0, g), "a debuff")
	assert_eq(Effects.stacks_of(u, "spun_up"), 1, "leaves it standing")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	var hp_before := g.hp
	assert_true(sk.assign(0, g), "then a weapon")
	assert_eq(g.hp, hp_before - (10 + su), "takes its stack")
	assert_false(Effects.has(u, "spun_up"), "and spends it")


## Every n-th shot (the Cassowary's sixth, Ryan's kit of 18 October; built 21 October): the
## weapon or equipment aimed at a foe the count lands on doubles its damage and the
## stacks it lays; a shield, a vent, a buff and a spin are no shots, and the count resets each
## fight.
func test_every_nth_shot_doubles_its_damage_and_the_stacks_it_lays() -> void:
	var sk := Skirmish.new(1)
	var torch := Face.attack(10, L, [K.ABLATE])
	var u := _mech("A", Die.of([torch, Face.vent(10)]), 40, 100)
	u.grant_passive({"id": "test_third", "name": "Third", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 2, "when": "nth_shot", "every": 3},
		{"trigger": "on_attack", "effect": "multiply_stacks", "value": 2, "when": "nth_shot", "every": 3}]})
	sk.add_mech(u)
	var g := _ghoul(500, 1)
	sk.add_foes([g])
	sk.begin()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(Effects.counts_shots(u), 3, "the machine counts every third")
	for k in range(2):
		sk.start_round()
		ms.face_index = 0
		sk.assign(0, g)
		sk.end_round()
	assert_eq(Effects.stacks_of(u, "shots"), 2, "two shots counted")
	sk.start_round()
	ms.face_index = 1
	sk.assign(0, ms)
	assert_eq(Effects.stacks_of(u, "shots"), 2, "a vent is no shot")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	assert_true(Effects.nth_shot_due(u), "the third is next")
	assert_eq(sk.shown_number_text(ms, ms.face(), g), "20", "and the die shows it doubled")
	var hp := g.hp
	var burning := Effects.stacks_of(g, "ablating")
	sk.assign(0, g)
	assert_eq(hp - g.hp, 20, "its damage doubled")
	assert_eq(Effects.stacks_of(g, "ablating") - burning, 2, "and its Ablate's stack laid twice")
	assert_true("\n".join(sk.log).contains("the third shot counts double"), "the log says so")
	assert_false(Effects.nth_shot_due(u), "the count runs on")
	Effects.end_skirmish(u)
	assert_eq(Effects.stacks_of(u, "shots"), 0, "and resets with the fight")


const DRUM_PASSIVE := {"id": "test_drum", "name": "Drum", "description": "", "effects": [
	{"trigger": "static", "effect": "rewrite_weapon", "value": 15, "reach": "indirect", "heat": 10, "tag": "ballistic"},
	{"trigger": "static", "effect": "grant_keyword", "value": "penetrate", "when": "target_rank", "rank": "back", "number": 7},
	{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "target_rank", "rank": "front", "number": 7}]}


## The drum (the Cottonmouth's Adaptive Munitions Drum, Ryan's go of 19 October; built 21
## October): every weapon and debuff leaves as the drum's shot, Indirect, a flat 15, heat 10, one blow,
## Ballistic, its own keywords kept; aimed at the front rank it sprays (Spread 7), at the back
## it punches through (Penetrate 7); a shield fires as itself, and the die keeps the real entry.
func test_a_drum_fires_every_weapon_as_its_shot_by_the_rank_it_is_aimed_at() -> void:
	var sk := Skirmish.new(1, 3)
	var gun := Face.attack(40, L, [K.ABLATE])
	gun.heat = 5
	gun.strikes = 2
	var u := _mech("A", Die.of([gun, Face.shield(20)]), 40, 100)
	u.grant_passive(DRUM_PASSIVE)
	sk.add_mech(u)
	sk.add_foes([_ghoul(100, 1), _ghoul(100, 1), _ghoul(100, 1), _archer(100, 1), _archer(100, 1), _archer(100, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	var shot := sk.shown_face(ms, ms.face())
	assert_eq([shot.power, shot.reach, shot.heat, shot.strikes], [15, I, 10, 1], "the drum's shot: 15, Indirect, heat 10, one blow")
	assert_true(shot.has(K.ABLATE) and shot.tags.has("ballistic"), "its own keyword kept, Ballistic added")
	assert_eq(gun.power, 40, "the die keeps the real entry")
	assert_false(shot.has(K.CLEAVE) or shot.has(K.PENETRATE), "no rank keyword without a target")
	var mid: Foe = sk.front[1]
	assert_true(sk.shown_face(ms, ms.face(), mid).has(K.CLEAVE), "over the front rank it shows Spread")
	assert_eq(sk.shown_face(ms, ms.face(), mid).cleave, 7, "at the grant's number")
	assert_true(sk.shown_face(ms, ms.face(), sk.back[2]).has(K.PENETRATE), "over the back rank, Penetrate")
	assert_true(sk.assign(0, mid), "fired at the front")
	assert_true((sk.last_roll["tags"] as Array).has("ballistic"), "the blow's record carries the tags it was fired with, the drum's Ballistic among them, so the screen fires it as a gun")
	for f in sk.front:
		assert_eq(f.hp, 85 if f == mid else 93, "the spray lands 15 on the target and its Spread 7 on each neighbour")
		assert_true(Effects.has(f, "ablating"), "with the Ablate it kept")
	assert_eq(ms.heat, 10, "at the drum's heat")
	assert_eq(u.shield, 40, "the front-rank spray costs its firer nothing (danger close retired)")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	var back: Foe = sk.back[2]
	var front_hp: int = sk.front[2].hp
	var other_hp: int = sk.front[0].hp
	assert_true(sk.assign(0, back), "fired at the back")
	assert_eq(back.hp, 85, "the shot lands on the back foe")
	assert_eq(sk.front[2].hp, front_hp - 7, "and punches through the front foe of its column for its Penetrate 7")
	assert_eq(sk.front[0].hp, other_hp, "and no other")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_eq(sk.shown_face(ms, ms.face()).power, 20, "a shield fires as itself")




## A lure over every foe that braces (the Whip Scorpion's Heliographic Siphon of 20 October,
## the piece gone since its rework; a heat a blow is a machine's passive, never an entry's): no
## damage, every foe in the fight turns on it for the round, and it braces. With a passive's heat a
## blow (the Nemesis's shape), every blow a foe lands on it adds heat, after the overheat.
func test_a_lure_over_every_foe_turns_them_all_and_braces() -> void:
	var siphon := Face.from_dict({"kind": "attack", "reach": "every_foe", "power": 0, "keywords": ["lure"], "braces": 2})
	assert_eq(siphon.describe(), "every foe lure braces ×2", "the entry says its rules, Every Foe its targeting mode (4 November)")
	var back := Face.from_dict(siphon.to_dict()).to_dict()
	assert_true(back["reach"] == "every_foe" and not back.has("reaches_all") and not (back["keywords"] as Array).has("every_foe"), "saved as its reach, never a keyword or a flag")
	var sk := Skirmish.new(1, 2)
	var u := _mech("A", Die.single(siphon), 40, 200)
	u.grant_passive(_heat_a_blow(10))   # ten heat a blow it takes
	var other := _mech("B", Die.single(Face.attack(10, L)), 40, 200)
	sk.add_mech(u)
	sk.add_mech(other)
	var foes := [_ghoul(100, 10), _ghoul(100, 10), _archer(100, 10)]
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	for f in sk.field_foes():
		f.target = sk.mechs[1]
	assert_true(sk.assign(0, sk.front[0]), "the lure is spent")
	for f in sk.field_foes():
		assert_eq(f.target, sk.mechs[0], "every foe in the fight turns on it, the back rank too")
	assert_eq(Effects.stacks_of(u, "braced"), 2, "it braces")
	var fc := sk.forecast(sk.mechs[0])
	assert_eq(int(fc["heat_after"]), 30, "the forecast counts the passive's ten a blow, three blows")
	sk.end_round()
	assert_eq(sk.mechs[0].heat, 30, "three blows, ten heat each, after the overheat")


## A heat a blow it takes, on its shield or its hull (the Nemesis's Crucible's shape since 23
## November): `n` heat for each foe's blow that lands anything on it. Synthetic.
func _heat_a_blow(n: int) -> Dictionary:
	return {"id": "heat_a_blow", "name": "Heat a Blow", "description": "", "effects": [
		{"trigger": "on_shield_hit", "effect": "gain_heat", "value": n},
		{"trigger": "on_hull_damage", "effect": "gain_heat", "value": n}]}


## The kinds a piece is (Ryan, 26 October: "Face type is either Weapon, Shield, Vent, or
## Equipment"), the engine's one reading (Effects.kinds_of): its own, on a machine or as built.
func test_a_piece_is_its_own_kind_on_a_machine_and_as_built() -> void:
	var vent := Face.vent(30)
	var plain := _mech("P", Die.single(vent), 40, 100)
	assert_eq(Effects.kinds_of(plain, vent), ["vent"] as Array[String], "a vent is a vent")
	assert_eq(Effects.kinds_of(null, vent), ["vent"] as Array[String], "as built, a vent")
	assert_eq(Effects.kinds_of(plain, Face.attack(10, L)), ["weapon"] as Array[String], "a gun is a weapon")
	assert_eq(Effects.kinds_of(plain, Face.shield(5)), ["shield"] as Array[String], "a shield is a shield")
	assert_eq(Effects.kinds_of(plain, Face.attack(0, L, [K.LURE])), ["equipment"] as Array[String], "a debuff is equipment")
	assert_eq(Effects.kinds_of(plain, Face.blank()), [] as Array[String], "a blank is none")


## The round preview over a Lure (the lure-all's, 22 October; on the one round model since 9
## November): a Lure entry's turn read before it is spent, every foe it reaches turned on its
## machine in the copy and the fight untouched; the spender takes the lured blows behind its
## brace and banks their heat (its passive's), the machine they left takes nothing; a targeted lure needs its
## aim, and an entry without Lure turns nobody (lure_turns, the arrows').
func test_the_round_preview_over_a_lure_reads_the_turned_round_and_leaves_the_fight_untouched() -> void:
	var siphon := Face.from_dict({"kind": "attack", "reach": "every_foe", "power": 0, "keywords": ["lure"], "braces": 2})
	var sk := Skirmish.new(1, 2)
	var lurer := _mech("A", Die.single(siphon), 0, 200)
	lurer.grant_passive(_heat_a_blow(10))   # ten heat a blow it takes
	sk.add_mech(lurer)
	sk.add_mech(_mech("B", Die.single(Face.attack(10, L)), 0, 200))
	sk.add_foes([_ghoul(100, 10), _ghoul(100, 10), _archer(100, 10)])
	sk.begin()
	sk.start_round()
	for f in sk.field_foes():
		f.target = sk.mechs[1]
	assert_eq(sk.lure_turns(sk.mechs[0]).size(), 3, "a reach over every foe needs no aim: all three would turn")
	var pv: Array = sk.preview_round(0, sk.front[0])["mechs"]   # the lure spent on the copy, aimed at any foe it reaches
	assert_eq(int(pv[0]["incoming"]), 30, "the three blows come at it")
	assert_eq(int(pv[0]["hull_after"]), 200 - 3 * (10 - 2), "behind the brace's two a blow")
	assert_eq(int(pv[0]["heat_after"]), 30, "and its passive banks ten heat from each")
	assert_eq(int(pv[1]["incoming"]), 0, "the machine they left takes nothing")
	for f in sk.field_foes():
		assert_eq(f.target, sk.mechs[1], "every foe still on the machine it picked: the fight is untouched")
	assert_eq(int(sk.forecast(sk.mechs[1])["incoming"]), 30, "so the round as it stands is untouched")
	assert_true(sk.lure_turns(sk.mechs[1], sk.front[0]).is_empty(), "a gun without Lure turns nobody")
	var s2 := Skirmish.new(1, 2)
	s2.add_mech(_mech("A", Die.single(Face.attack(0, I, [K.LURE])), 0, 200))
	s2.add_mech(_mech("B", Die.single(Face.attack(10, L)), 0, 200))
	s2.add_foes([_ghoul(100, 10), _ghoul(100, 10)])
	s2.begin()
	s2.start_round()
	for f in s2.field_foes():
		f.target = s2.mechs[1]
	assert_true(s2.lure_turns(s2.mechs[0]).is_empty(), "a targeted lure needs its aim")
	var aimed := s2.lure_turns(s2.mechs[0], s2.front[0])
	assert_true(aimed.size() == 1 and aimed[0] == s2.front[0], "aimed, it turns the foe it reaches and no other")


## The round preview counts the die in hand's brace (22 October): its armour stands behind this
## round's blows while the die is dragged over its foe, and not otherwise.
func test_the_round_preview_counts_the_brace_in_hand() -> void:
	var plow := Face.attack(10, L)
	plow.braces = 2
	var sk := Skirmish.new(1, 1)
	sk.add_mech(_mech("A", Die.single(plow), 0, 100))
	var g := _ghoul(100, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	g.target = sk.mechs[0]
	assert_eq(int(sk.forecast(sk.mechs[0])["hull_after"]), 90, "the blow as it stands")
	assert_eq(int(sk.preview_round()["mechs"][0]["hull_after"]), 90, "and the round preview with no die in hand")
	assert_eq(int(sk.preview_round(0, g)["mechs"][0]["hull_after"]), 92, "the brace's two off it while the die is in hand")


## The round preview over a Cryo foe (Ryan, 16 October: the net on the heat bar, never the die):
## a weapon held over a foe carrying Cryo reads its own heat less what the hit cashes, every
## stack on every foe it reaches; held over nothing it counts no die (Ryan, 26 October: "Die faces
## only apply to the preview when hovered over a valid target"); a debuff cashes nothing.
func test_the_round_preview_over_a_cryo_foe_reads_the_net_heat() -> void:
	var sk := Skirmish.new(1, 3)
	var gun := Face.attack(10, L, [K.CLEAVE])
	gun.heat = 20
	var u := _mech("A", Die.of([gun, Face.attack(0, I, [K.LURE])]), 40, 100)
	sk.add_mech(u)
	sk.add_foes([_ghoul(500, 1), _ghoul(500, 1), _ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 30
	ms.face_index = 0
	Effects.stack(sk.front[0], Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	Effects.stack(sk.front[1], Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	var cool := Effects.status_value("cryoed", "cool_hitter")
	assert_eq(int(sk.preview_round()["mechs"][0]["heat_after"]), 30, "held over nothing: the die uncounted, the gauge as it stands")
	assert_eq(int(sk.preview_round(0, sk.front[2])["mechs"][0]["heat_after"]), 50 - 2 * cool, "over the right one, Spread reaches the two-stack neighbour: its twenty, two stacks cashed")
	assert_eq(int(sk.preview_round(0, sk.front[1])["mechs"][0]["heat_after"]), 50 - 3 * cool, "over the middle, three stacks cashed")
	ms.face_index = 1
	assert_eq(int(sk.preview_round(0, sk.front[1])["mechs"][0]["heat_after"]), 30, "a lure cashes nothing")


## A fight's share of the Sponsorship measures (the bible's row): damage taken on shield and
## armour, dice spent on entries that deal damage and on entries that deal none; a blank is no
## spend.
func test_a_fight_tallies_its_sponsorship_measures() -> void:
	var sk := Skirmish.new(1, 1)
	var u := _mech("A", Die.of([Face.attack(10, L), Face.vent(10), Face.attack(0, I, [K.LURE]), Face.blank()]), 10, 1000)   # a hull no blow here can wreck
	u.armour = 5
	sk.add_mech(u)
	sk.add_foes([_ghoul(500, 30)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(int(sk.sponsorship["guarded"]), 15, "a blow of thirty: ten on the shield, five off the armour")
	assert_eq(int(sk.sponsorship["damaging_spends"]), 1, "a gun that deals damage")
	for k in [1, 2, 3]:
		sk.start_round()
		ms.face_index = k
		sk.assign(0, ms if k == 1 else (sk.front[0] if k == 2 else null))
		sk.end_round()
	assert_eq(int(sk.sponsorship["quiet_spends"]), 2, "a vent and a lure deal none; a blank is no spend")


## A foe whose one move is a special of no blow: a purge or a cleanse (28 October: a purge is a
## special, never a rider).
func _caster(effect: String, kind: String = "debuff", when: String = "") -> Foe:
	var f := Foe.make("caster", 500, 1)
	var a := {"id": effect, "name": effect.capitalize(), "kind": kind, "effect": effect, "weight": 1, "text": ""}
	if not when.is_empty():
		a["when"] = when
	f.actions = [a]
	f.action = f.actions[0]
	return f


## A purger: its one move a purge, at the most buffed machine and cast where one carries a buff.
func _purger() -> Foe:
	var f := Foe.make("priest", 500, 1)
	f.actions = [{"id": "purge", "name": "Purge", "kind": "debuff", "effect": "dispel", "value": 9, "weight": 1, "aim": "buffed", "when": "machine_buffed", "text": ""}]
	f.action = f.actions[0]
	return f


## The three feeds of the Nemesis's heat (the Crucible Capacitor, its rage's from 11 November, Ryan:
## "Taking a hit on shield gives 1 rage, hull damage gives 2 rage", "hull damage takes priority, so
## it would be 2 if the shield is broken and hull damaged", and "getting its attacks completely
## blocked gives 2 rage", per blow; heat since 23 November: "change rage into simply generating heat,
## using the same rules as rage generation"): a foe's blow its shield takes whole heats it one; one
## that breaks the shield and wounds two, never three; one its armour or its own Barrier takes whole
## nothing. Synthetic passive, on a gauge too deep to overheat.
func _crucible() -> Dictionary:
	return {"id": "crucible", "name": "Crucible", "description": "", "effects": [
		{"trigger": "on_shield_hit", "effect": "gain_heat", "value": 1},
		{"trigger": "on_hull_damage", "effect": "gain_heat", "value": 2},
		{"trigger": "on_blocked", "effect": "gain_heat", "value": 2}]}


func test_a_hit_on_the_shield_banks_one_and_hull_damage_two_never_both() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(1, L)), 5, 1000)
	m.grant_passive(_crucible())
	m.heat_max = 100
	sk.add_mech(m)
	var foe := _ghoul(500, 3)
	sk.add_foes([foe])
	sk.begin()
	var ms := sk.mechs[0]
	sk._damage_mech(ms, 3, foe)
	assert_eq([m.shield, m.hull], [2, 1000], "the shield takes it whole")
	assert_eq(sk.mechs[0].heat, 1, "a hit on its shield: one heat")
	assert_true("\n".join(sk.log).contains("from the hit on its shield"), "the log says why")
	sk._damage_mech(ms, 3, foe)
	assert_eq([m.shield, m.hull], [0, 999], "it breaks the shield and wounds")
	assert_eq(sk.mechs[0].heat, 3, "two for the hull, never three: hull first")
	m.armour = 10
	sk._damage_mech(ms, 3, foe)
	assert_eq(sk.mechs[0].heat, 3, "its armour takes the blow whole: nothing")
	m.armour = 0
	m.shield = 5
	Effects.grant_buff(m, "barrier", 1, "test", sk.round)
	sk._damage_mech(ms, 3, foe)
	assert_eq(sk.mechs[0].heat, 3, "its own Barrier takes it: nothing")
	for k in range(6):
		sk._damage_mech(ms, 50, foe)
	assert_eq(sk.mechs[0].heat, 15, "two a hull hit, with no cap: the gauge holds what it gains")


## A blow blocked whole, counted a blow (Ryan, 11 November: "I'd do per blow because that lets it
## scrap against the comp its supposed to"): every blow of its weapon on a living foe that the
## foe's armour or Barrier takes whole heats it two, each foe's of an area and each strike's; a blow
## that deals anything, a debuff's and one on a felled foe bank nothing. Synthetic passive and pieces.
func test_every_blow_a_foes_armour_or_barrier_takes_whole_banks_two() -> void:
	var sk := Skirmish.new(1, 3)
	var spread := Face.from_dict({"kind": "attack", "reach": "direct", "power": 3, "keywords": ["cleave"], "cleave": 2})
	var twice := Face.from_dict({"kind": "attack", "reach": "direct", "power": 3, "strikes": 2})
	var probe := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["shock"]})
	var m := _mech("A", Die.of([spread, twice, probe]), 40, 200)
	m.grant_passive(_crucible())
	m.heat_max = 100
	sk.add_mech(m)
	var left := _ghoul(500, 0)
	var mid := _ghoul(500, 0)
	var right := _ghoul(500, 0)
	left.armour = 5
	mid.armour = 5
	sk.add_foes([left, mid, right])
	sk.begin()
	sk.start_round()
	var ms := sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, mid), "a spread on the armoured middle")
	assert_eq(sk.mechs[0].heat, 4, "its blow and the armoured one beside it, two each; the bare one took damage")
	assert_true("\n".join(sk.log).contains("2 blows blocked whole"), "one line for the spend")
	sk.end_round()
	sk.start_round()
	Effects.stack(right, Effects.STATUS["barrier"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	ms.face_index = 1
	assert_true(sk.assign(0, right), "two strikes on the Barrier")
	assert_eq(sk.mechs[0].heat, 6, "the Barrier takes the first whole, two; the second lands")
	sk.end_round()
	sk.start_round()
	ms.face_index = 2
	assert_true(sk.assign(0, left), "a debuff on the armoured foe")
	assert_eq(sk.mechs[0].heat, 6, "equipment blocks nothing")


## Purge (Ryan, 17 and 21 October; by its number since 2 November; 8 November: "A stack is a
## stack, doesn't matter where it came from"): a foe's Purge N takes N stacks of every buff the
## machine carries, for good, whatever granted it, a die entry or a passive; an ability is no
## buff (the Polar Bear's seal, its form, stays and so does its armour); the stores and the
## passives stay; a Ward turns it away.
func test_a_purge_takes_every_buffs_stacks_and_leaves_the_abilities() -> void:
	var sk := Skirmish.new(1, 1)
	var u := _mech("A", Die.single(Face.attack(10, L)), 40, 200)
	u.grant_passive({"id": "test_pass", "name": "Pass", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 5}]})
	sk.add_mech(u)
	sk.add_foes([_purger()])
	sk.begin()
	Effects.stack(u, Effects.STATUS["overcharged"], Effects.SKIRMISH, "buff:overcharge_coil", 4, Effects.DECAY_HALF)
	Effects.stack(u, Effects.STATUS["braced"], Effects.SKIRMISH, "passive:phase_conjugator", 2, Effects.DECAY_NONE)
	Effects.stack(u, Effects.STATUS["hopper"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_NONE)
	Effects.stack(u, Effects.STATUS["muster"], Effects.BATTLE, "mech", 2, Effects.DECAY_NONE)
	sk.start_round()
	sk.end_round()
	assert_false(Effects.has(u, "overcharged"), "the Coil's Empowered is gone")
	assert_false(Effects.has(u, "braced"), "and so is a passive's Armoured: a stack is a stack")
	assert_eq([Effects.stacks_of(u, "hopper"), Effects.stacks_of(u, "muster")], [3, 2], "the stores stay, the battle's muster too")
	assert_eq(u.armour, 5, "the passive stays")
	assert_eq(u.hull, 200, "no blow")
	assert_true("\n".join(sk.log).contains("purges A ×9: Empowered gone, Armoured gone"), "the log says what went")
	sk.start_round()
	assert_false(Effects.has(u, "overcharged") or Effects.has(u, "braced"), "and nothing comes back")
	# The seal is the Polar Bear's form, an ability: the purge leaves it, its armour standing.
	var s2 := Skirmish.new(1, 2)
	var buff := Face.buff("overcharged", 2)   # two, so one is left past END TURN's halving for the purge to take
	var m := _mech("D", Die.of([buff, Face.attack(10, L)]), 40, 200)
	m.grant_passive({"id": "radiator", "name": "Radiator", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 5}]}, "radiator")   # cooling is granted: a chassis has none of its own
	m.grant_passive({"id": "lockdown", "name": "Lockdown", "description": "", "effects": [
		{"trigger": "static", "effect": "seal_form"}]})
	s2.add_mech(m)
	var hitter := _archer(500, 12)   # the back rank strikes after the front, so after the purge
	s2.add_foes([_purger(), hitter])
	s2.begin()
	s2.start_round()
	var ms: Skirmish.MechState = s2.mechs[0]
	ms.face_index = 0
	assert_true(s2.assign(0, null), "a buff on itself")
	assert_true(Effects.is_sealed(m) and m.armour == Effects.status_value_static("sealed", "add_stat"), "seals it, Sealed's armour")
	m.shield = 0
	s2.end_round()
	assert_true(Effects.is_sealed(m) and m.armour == Effects.status_value_static("sealed", "add_stat"), "the purge left the seal and its armour")
	assert_eq(m.hull, 200 - (12 - Effects.status_value_static("sealed", "add_stat")), "so the blow after it met the plate")
	assert_true("\n".join(s2.log).contains("purges D ×9: Empowered gone"), "the log says the purge took the buff that sealed it, and nothing of the seal")
	# A Ward turns it away.
	var s4 := Skirmish.new(1, 1)
	var w := _mech("W", Die.single(Face.attack(10, L)), 40, 200)
	s4.add_mech(w)
	s4.add_foes([_purger()])
	s4.begin()
	Effects.stack(w, Effects.STATUS["overcharged"], Effects.SKIRMISH, "buff:overcharge_coil", 2, Effects.DECAY_HALF)
	s4.start_round()
	Effects.grant_buff(w, "ward", 1, "test", s4.round)
	s4.end_round()
	assert_true(Effects.has(w, "overcharged"), "the Ward turned the purge away")


## A foe's cleanse (28 October, the Marsh's lever): every mark the team laid comes off the
## most-marked of its own, itself included; Numbed and Suppressed stay; a foe carrying only
## Numbed is no target; and a special never fires twice running while another move is open.
func test_a_foes_cleanse_takes_the_teams_marks_off_the_most_marked_of_its_own() -> void:
	var sk := Skirmish.new(1, 3)
	var u := _mech("A", Die.single(Face.attack(1, L)), 40, 200)
	sk.add_mech(u)
	var healer := _caster("cleanse", "defend", "ally_marked")
	var a := _ghoul(500, 1)
	var b := _ghoul(500, 1)
	sk.add_foes([healer, a, b])
	sk.begin()
	assert_eq(sk.cleanse_target(healer), null, "nothing marked: no target")
	assert_false(sk.legal_actions(healer).any(func(x) -> bool: return str(x.get("effect", "")) == "cleanse"), "and its condition fails")
	Effects.stack(b, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_TICK)
	assert_eq(sk.cleanse_target(healer), null, "Numbed alone is no mark")
	Effects.stack(b, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	Effects.stack(b, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 2, Effects.status_decay(Effects.STATUS["brittled"]))
	Effects.stack(b, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	Effects.stack(a, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_eq(sk.cleanse_target(healer), b, "the most marked of its own")
	sk.start_round()
	Effects.grant_for_rounds(b, Effects.STATUS["suppressed"], "mech", sk.round + 1)
	assert_eq(str(healer.action.get("effect", "")), "cleanse", "it announces the cleanse")
	assert_true(healer.acts_on_nobody(), "aimed at no machine")
	sk.end_round()
	for id in ["ablating", "brittled", "shocked"]:
		assert_false(Effects.has(b, id), "%s gone" % id)
	assert_true(Effects.has(b, "numbed"), "Numbed stays: nothing removes it")
	assert_true(Effects.has(b, "suppressed"), "and Suppressed stays: the stun is sure")
	assert_true(Effects.has(a, "cryoed"), "the other's mark stays: one foe a cleanse")
	assert_true("\n".join(sk.log).contains("loses ablate"), "the log says what went")
	# Never twice running while another move is open.
	healer.actions = [{"id": "touch", "name": "Touch", "kind": "attack", "weight": 1, "text": ""}, healer.actions[0]]
	assert_false(sk.legal_actions(healer).any(func(x) -> bool: return str(x.get("effect", "")) == "cleanse"), "the round after, the cleanse is not open")


## A foe's Barrier (the ladder's brief, B; 28 October): its special shelters itself, aimed at
## no machine; the next blow of a weapon it takes deals nothing and pops it, the blow's riders
## landing and its Shock spent; equipment pops nothing; unpopped, it goes at the end of the
## player's next turn.
func test_a_foes_barrier_takes_the_next_weapon_blow_and_lasts_to_the_players_turn_end() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(0, L, [K.SHOCK])), 40, 200)
	var b := _mech("B", Die.single(Face.attack(10, L, [K.ABLATE])), 40, 200)
	var c := _mech("C", Die.single(Face.attack(10, L)), 40, 200)
	for m in [a, b, c]:
		sk.add_mech(m)
	var shelter := _caster("barrier", "defend")
	sk.add_foes([shelter])
	sk.begin()
	sk.start_round()
	assert_true(shelter.acts_on_nobody(), "a Barrier is aimed at no machine")
	sk.end_round()
	assert_true(Effects.has(shelter, "barrier"), "it shelters itself")
	assert_true("\n".join(sk.log).contains("the next weapon blow on it deals nothing"), "the log says what it does")
	sk.start_round()
	assert_true(Effects.has(shelter, "barrier"), "it stands through the player's turn")
	assert_true(sk.assign(0, shelter), "a probe")
	assert_true(Effects.has(shelter, "barrier"), "equipment pops nothing")
	assert_true(Effects.has(shelter, "shocked"), "and its mark lands")
	var before := shelter.hp
	assert_true(sk.assign(1, shelter), "a torch")
	assert_eq(shelter.hp, before, "the weapon's blow deals nothing")
	assert_false(Effects.has(shelter, "barrier"), "and pops it")
	assert_true(Effects.has(shelter, "ablating"), "the blow's rider lands")
	assert_false(Effects.has(shelter, "shocked"), "and the blow spends the Shock")
	assert_true("\n".join(sk.log).contains("Barrier takes the blow"), "the log says so")
	assert_true(sk.assign(2, shelter), "the next gun")
	assert_eq(shelter.hp, before - 10, "lands whole")
	sk.end_round()
	assert_true(Effects.has(shelter, "barrier"), "it shelters again")
	shelter.actions = [{"id": "touch", "name": "Touch", "kind": "attack", "weight": 1, "text": ""}]
	sk.start_round()
	assert_true(Effects.has(shelter, "barrier"), "unpopped through the player's turn")
	sk.end_round()
	assert_false(Effects.has(shelter, "barrier"), "and gone when the player's turn ends")


## A foe's Ward (the ladder's brief, B; 28 October): its special wards every foe on the field,
## itself included; no mark the team lays lands (Ablating, Brittle, Shock, the Paradox), Suppressed
## excepted, since Numbed stays the one stun resistance; the damage lands; the spend tells it
## once; a passive's lay is turned too; it goes at the end of the player's next turn.
## A foe's Purge N on a machine (2 November; 8 November: "A stack is a stack, doesn't matter where
## it came from"): every buff loses N stacks for good, whatever granted it.
func test_a_foes_purge_n_lowers_every_buff_by_n_whatever_granted_it() -> void:
	var sk := Skirmish.new(1, 1)
	var u := _mech("A", Die.single(Face.attack(10, L)), 40, 200)
	sk.add_mech(u)
	var p := _purger()
	p.actions[0]["value"] = 2
	p.action = p.actions[0]
	sk.add_foes([p])
	sk.begin()
	Effects.stack(u, Effects.STATUS["overcharged"], Effects.SKIRMISH, "buff:overcharge_coil", 4, Effects.DECAY_NONE)
	Effects.stack(u, Effects.STATUS["primed"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_NONE)
	sk.start_round()
	sk.end_round()
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "primed")], [2, 1], "each loses two")
	assert_true("\n".join(sk.log).contains("purges A ×2: Empowered 2, Primed 1"), "the log says what it left: %s" % sk.log.back())
	sk.start_round()
	assert_eq([Effects.stacks_of(u, "overcharged"), Effects.stacks_of(u, "primed")], [2, 1], "and nothing comes back at the player's turn")


func test_a_foes_ward_turns_the_teams_marks_away_and_the_stun_with_them() -> void:
	var meter := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "paradox", "value": 3}]}
	var sk := Skirmish.new(1, 2)
	var gun := Face.attack(5, L, [K.ABLATE, K.SHOCK, K.BRITTLE])
	gun.strikes = 2
	var a := _mech("A", Die.single(gun), 40, 200)
	a.grant_passive(meter)
	var b := _mech("B", Die.single(Face.attack(0, L, [K.SUPPRESS])), 40, 200)
	sk.add_mech(a)
	sk.add_mech(b)
	var hallow := _caster("ward_all", "buff")
	var g := _ghoul(500, 1)
	sk.add_foes([hallow, g])
	sk.begin()
	sk.start_round()
	assert_true(hallow.acts_on_nobody(), "a Ward is aimed at no machine")
	sk.end_round()
	assert_true(Effects.has(hallow, "ward") and Effects.has(g, "ward"), "every foe on the field, itself included")
	sk.start_round()
	var before := g.hp
	assert_true(sk.assign(0, g), "a gun of three marks, twice")
	assert_eq(g.hp, before - 10, "the damage lands, and no Brittle feeds the second blow")
	for id in ["ablating", "shocked", "brittled", "paradox"]:
		assert_false(Effects.has(g, id), "no %s" % id)
	assert_eq("\n".join(sk.log).count("Ward turns away"), 1, "the spend tells it once")
	assert_true(sk.assign(1, g), "a Suppress")
	assert_false(g.is_suppressed(), "the Ward turns the stun away too (2 November)")
	assert_false(Effects.has(g, "paradox"), "and the Paradox it would feed is turned away")
	Effects.stack(g, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 2)
	assert_false(Effects.has(g, "vitriol"), "a lay from anywhere is turned")
	sk.end_round()
	hallow.actions = [{"id": "touch", "name": "Touch", "kind": "attack", "weight": 1, "text": ""}]
	sk.start_round()
	assert_true(Effects.has(hallow, "ward"), "granted again, it stands through the player's turn")
	sk.end_round()
	assert_false(Effects.has(hallow, "ward") or Effects.has(g, "ward"), "and goes when the player's turn ends")
	sk.start_round()
	assert_true(sk.assign(0, g), "the gun again")
	assert_true(Effects.has(g, "ablating") and Effects.has(g, "brittled"), "its marks land once the Ward is gone")


## Primed on a foe (the ladder's brief, B; 28 October; the primers' format since 15 November):
## a stoker primes every other foe on the field, its value in stacks; each blow of a primed foe's
## move that strikes leaves Ablating 1 on the machine it hits, and the move spends a stack, so
## Primed 2 rides two moves; one that acted carries its stacks on, a special spends none, and a
## machine's Ward turns the Ablating away as a rider.
func test_a_stoker_primes_the_others_and_each_move_that_strikes_spends_a_stack() -> void:
	var sk := Skirmish.new(1, 2)
	var u := _mech("A", Die.single(Face.attack(1, L)), 40, 400)
	sk.add_mech(u)
	var stoker := _caster("prime", "buff")
	stoker.actions[0]["value"] = 2
	var early := _ghoul(500, 12)   # the heaviest blow stands left and strikes first
	var late := _archer(500, 3)    # the back rank strikes after the front
	sk.add_foes([stoker, early, late])
	sk.begin()
	sk.start_round()
	assert_true(stoker.acts_on_nobody(), "a priming is aimed at no machine")
	sk.end_round()
	assert_false(Effects.has(stoker, "primed"), "every other foe, never itself")
	assert_eq(Effects.stacks_of(early, "primed"), 2, "one that acted carries both stacks to its next moves")
	assert_eq(Effects.stacks_of(late, "primed"), 1, "one acting after it spends a stack this turn")
	assert_eq(Effects.stacks_of(u, "ablating_mech"), 1, "its blow leaving Ablating 1, whatever it carries")
	assert_true("\n".join(sk.log).contains("primed, lays Ablating ×1 on A"), "the log says so")
	stoker.actions = [{"id": "touch", "name": "Touch", "kind": "attack", "weight": 1, "text": ""}]
	sk.start_round()
	Effects.remove(u, "ablating_mech")
	sk.end_round()
	assert_eq([Effects.stacks_of(early, "primed"), Effects.stacks_of(late, "primed")], [1, 0], "each move that strikes spends a stack more")
	assert_eq(Effects.stacks_of(u, "ablating_mech"), 2, "and leaves its Ablating 1, a blow each")
	Effects.stack(early, Effects.primed_foe(), Effects.SKIRMISH, "foe:caster", 3, Effects.DECAY_NONE)
	assert_eq(Effects.stacks_of(early, "primed"), 4, "a second stoking adds its stacks")
	assert_true(Skirmish._rides(early), "a primed blow carries a rider a Ward turns")
	sk.start_round()
	Effects.remove(u, "ablating_mech")
	Effects.stack(u, Effects.STATUS["ward"], Effects.ROUNDS, "buff", 1, Effects.DECAY_NONE, sk.round)
	sk.end_round()
	assert_false(Effects.has(u, "ablating_mech"), "a warded machine takes no priming's Ablating")
	assert_eq(Effects.stacks_of(early, "primed"), 3, "and the move still spends its stack")
	# A special spends none: a stoker primed by another keeps its stacks through its own stoking.
	var s2 := Skirmish.new(1, 2)
	s2.add_mech(_mech("A", Die.single(Face.attack(1, L)), 40, 400))
	var other := _caster("prime", "buff")
	s2.add_foes([other, _ghoul(500, 12)])
	s2.begin()
	Effects.stack(other, Effects.primed_foe(), Effects.SKIRMISH, "foe:caster", 2, Effects.DECAY_NONE)
	s2.start_round()
	s2.end_round()
	assert_eq(Effects.stacks_of(other, "primed"), 2, "a move that strikes nobody spends no Primed")


## Regenerating on a foe (the ladder's brief, B; 28 October; its clock Ryan's of 15 November,
## "Regen 1 per stack ... decay one stack at a time"): its special knits itself, its value in
## stacks, a point a stack as each of its turns ends and a stack fading each (16 November, his
## four places: "Its turn End: ... Regeneration"), the first as the turn it knit in ends, so
## Regenerating 4 gives 4, 3, 2 and 1, after its Ablating and Vitriol have ticked, so a burn is a
## race and never a wall: a foe the tick kills regrows nothing. A suppressed foe regrows too,
## its turn being its own, and a second grant adds its stacks.
func test_a_foes_regeneration_regrows_a_point_a_stack_and_fades_a_stack_a_turn() -> void:
	var sk := Skirmish.new(1, 2)
	var u := _mech("A", Die.single(Face.attack(1, L)), 40, 400)
	sk.add_mech(u)
	var knit := _caster("regenerate", "defend")
	knit.actions[0]["value"] = 4
	var dying := _ghoul(500, 1)
	sk.add_foes([knit, dying])
	sk.begin()
	sk.start_round()
	assert_true(knit.acts_on_nobody(), "a regrowth is aimed at no machine")
	knit.hp = 490
	sk.end_round()
	assert_eq(knit.hp, 494, "it regrows as the turn it knit in ends, a point a stack")
	assert_eq([Effects.stacks_of(knit, "regenerating"), Effects.regrowth(knit)], [3, 3], "its value in stacks, one faded with that turn")
	assert_eq(Effects.regen_total(4), 10, "ten in all before it runs out: 4, 3, 2 and 1")
	knit.actions = [{"id": "touch", "name": "Touch", "kind": "attack", "weight": 1, "text": ""}]
	knit.hp = 498
	Effects.stack(knit, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	var burn := 3 * _rule("ablating", "tick_hp")
	sk.start_round()
	sk.end_round()
	assert_eq(knit.hp, mini(500, 498 - burn + 3), "the regrowth comes after the tick, a point a stack")
	assert_eq(Effects.stacks_of(knit, "regenerating"), 2, "and a stack fades")
	assert_true("\n".join(sk.log).contains("regenerates"), "the log says so")
	knit.hp = 400
	sk.start_round()
	Effects.grant_for_rounds(knit, Effects.STATUS["suppressed"], "mech", sk.round)
	var ticks := int(Effects.tick_preview(knit)["hp"])
	sk.end_round()
	assert_eq(knit.hp, 400 - ticks + 2, "a suppressed foe regrows too, the two it has left")
	sk.start_round()
	ticks = int(Effects.tick_preview(knit)["hp"])
	var at := knit.hp
	sk.end_round()
	assert_eq(knit.hp, at - ticks + 1, "its fourth turn: the last point")
	assert_false(Effects.has(knit, "regenerating"), "and then it is gone")
	sk.start_round()
	at = knit.hp
	ticks = int(Effects.tick_preview(knit)["hp"])
	sk.end_round()
	assert_eq(knit.hp, at - ticks, "nothing regrown at the fifth")
	# A second grant adds its stacks to what stands.
	Effects.stack(knit, Effects.STATUS["regenerating"], Effects.SKIRMISH, "foe:test", 2, Effects.DECAY_TICK)
	Effects.stack(knit, Effects.STATUS["regenerating"], Effects.SKIRMISH, "foe:test", 3, Effects.DECAY_TICK)
	assert_eq([Effects.stacks_of(knit, "regenerating"), Effects.regrowth(knit)], [5, 5], "two grants are one count")
	# A race, never a wall: the tick that kills comes first.
	Effects.stack(dying, Effects.STATUS["regenerating"], Effects.SKIRMISH, "foe:test", 10, Effects.DECAY_TICK)
	dying.hp = 2
	Effects.stack(dying, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 5)
	sk.start_round()
	sk.end_round()
	assert_false(dying.alive(), "a foe its Ablating kills regrows nothing")


## The player's Purge (the ladder's brief, C; 28 October): every foe the entry reaches loses every
## buff it carries but Numbed and Guarded, the four a foe's specials grant among them, after the
## blow and with the riders, equipment's included; a Barrier the weapon's blow pops is gone first,
## and a foe the blow kills stays down.
## A player's Purge N (28 October; Ryan, 2 November: "lower everything by N"): every buff a foe
## carries loses N stacks, Numbed among them since it is a buff, Guarded never; a Ward turns the
## Purge away and stands; a weapon's blow lands first, so a Barrier it pops is gone already.
func test_a_players_purge_lowers_every_buff_a_foe_carries_by_its_number_but_guarded() -> void:
	var sk := Skirmish.new(1, 3)
	var null9 := Face.attack(0, I, [K.DISPEL])
	null9.dispel = 9
	var gun9 := Face.attack(10, L, [K.DISPEL])
	gun9.dispel = 9
	var gun1 := Face.attack(10, L, [K.DISPEL])
	gun1.dispel = 1
	var a := _mech("A", Die.single(null9), 40, 200)
	var b := _mech("B", Die.single(gun9), 40, 200)
	var c := _mech("C", Die.single(gun1), 40, 200)
	for m in [a, b, c]:
		sk.add_mech(m)
	var caster := Foe.make("caster", 500, 1)
	var g := _ghoul(500, 3)
	var h := _ghoul(5, 2)
	sk.add_foes([caster, g, h])
	sk.begin()
	sk.start_round()
	var act := func(who: Foe, effect: String, kind: String, value: int) -> void:
		who.action = {"id": effect, "name": effect.capitalize(), "kind": kind, "effect": effect, "weight": 1, "text": ""}
		if value > 0:
			who.action["value"] = value
		sk._foe_acts(who, sk.mechs[0])
	# Every buff a foe can carry on the caster: its own specials', and a stoker's and a rallier's.
	act.call(caster, "barrier", "defend", 0)
	act.call(caster, "regenerate", "defend", 3)
	act.call(caster, "brace", "defend", 2)
	act.call(caster, "revive_once", "buff", 0)
	act.call(g, "ward_all", "buff", 0)
	act.call(g, "prime", "buff", 2)
	act.call(g, "rally", "buff", 3)
	caster.rage = 1   # the Nob's rage (3 November; its own since 8 November): the stacks the team's safe spends feed, laid here by hand
	act.call(caster, "golden", "buff", 2)   # a golden rage (4 November): an ability since 8 November, no Purge's
	sk._gold_lands(caster)   # Golden lands as its turn ends (a timer, 22 November)
	Effects.stack(caster, Effects.STATUS["enraged"], Effects.SKIRMISH, "foe:caster", 2, Effects.DECAY_NONE)
	Effects.stack(caster, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
	Effects.stack(caster, Effects.STATUS["guarded"], Effects.SKIRMISH, "foe:caster", 1, Effects.DECAY_NONE)
	var buffs := ["braced", "kindled", "enraged", "risen", "primed", "barrier", "regenerating", "numbed"]
	for id in buffs:
		assert_true(Effects.has(caster, id), "the caster carries %s" % id)
	assert_true(Effects.has(caster, "ward"), "and the Ward the hallow laid on every foe")
	assert_true(sk.assign(0, caster), "a Purge of equipment at a Warded foe")
	for id in buffs:
		assert_true(Effects.has(caster, id), "%s stands: the Ward turns the Purge away" % id)
	assert_true(Effects.has(caster, "ward"), "and the Ward stands")
	assert_true("\n".join(sk.log).contains("Ward turns away Purge"), "the spend says so: %s" % sk.log.back())
	Effects.remove(caster, "ward")
	sk.mechs[0].assigned = false
	assert_true(sk.assign(0, caster), "a Purge 9 of equipment, the Ward gone")
	for id in buffs:
		assert_false(Effects.has(caster, id), "%s gone" % id)
	assert_eq(caster.rage, 1, "the rage itself goes on, the Nob's ability; only what it gathered is purged")
	assert_false(Effects.has(caster, "numbed"), "Numbed goes with them: a buff since 2 November")
	assert_true(Effects.has(caster, "guarded") and Effects.has(caster, "golden"), "and the abilities stay, Guarded and the golden rage (8 November)")
	assert_true("\n".join(sk.log).contains("A purges"), "the log says what went")
	# A weapon's Purge: the blow first, so the Barrier takes it, then the rest goes.
	Effects.remove(g, "ward")
	act.call(g, "barrier", "defend", 0)
	act.call(g, "brace", "defend", 2)
	var before := g.hp
	assert_true(sk.assign(1, g), "a Purge 9 on a gun")
	assert_eq(g.hp, before, "the Barrier takes the blow")
	assert_false(Effects.has(g, "barrier") or Effects.has(g, "braced"), "and the Purge takes the rest")
	# A Purge 1 lowers by one: Armoured 2 to 1.
	act.call(g, "brace", "defend", 2)
	assert_true(sk.assign(2, g), "a Purge 1 on a gun")
	assert_eq(Effects.stacks_of(g, "braced"), 1, "Armoured 2 to 1")
	assert_true("\n".join(sk.log).contains("×1: Armoured 1"), "the log says what it left: %s" % sk.log.back())
	sk.mechs[2].assigned = false
	# A foe the blow kills stays down.
	act.call(h, "revive_once", "buff", 0)
	Effects.remove(h, "ward")
	assert_true(sk.assign(2, h), "a killing Purge")
	sk._clear_dead()
	assert_false(h.alive(), "it stays down")
	assert_false("\n".join(sk.log).contains("gets back up"), "no return")


## A Purge in a Mine (28 October; the Mines on foes, 9 November): the Mine carries the keyword, and
## every foe its blast meets loses its buffs.
func test_a_purge_in_a_mine_purges_every_foe_its_blast_meets() -> void:
	var sk := Skirmish.new(1, 2)
	var purge9 := Face.attack(0, I, [K.DISPEL])
	purge9.dispel = 9
	var a := _mech("Bomber", Die.single(purge9), 40, 100)
	a.grant_passive(MINER)
	sk.add_mech(a)
	sk.add_mech(_mech("Killer", Die.single(Face.attack(10, L)), 40, 100))
	var weak := _ghoul(10, 0)
	var boss := _ghoul(300, 0)
	sk.add_foes([weak, boss])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, weak), "the Purge spent on the weak foe, its Mine left")
	Effects.stack(boss, Effects.STATUS["braced"], Effects.SKIRMISH, "foe:revenant", 2, Effects.DECAY_ROUND)
	Effects.stack(boss, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:revenant", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(1, weak), "the weak foe felled")
	assert_false(Effects.has(boss, "braced") or Effects.has(boss, "risen"), "the blast purges the foe beside it")
	assert_true("\n".join(sk.log).contains("the Mine purges"), "the log says so")


## Swap (the Dingo's Combat Translocator, Ryan's go of 19 October; built 21 October): the spend
## takes a second target, another foe or an empty slot, and the two trade places, no damage; a
## foe pulled into the front stands exposed to Direct fire; a massive foe never moves.
func test_a_swap_trades_two_foes_or_pulls_one_into_an_empty_slot() -> void:
	var sk := Skirmish.new(1, 3)
	var swap := _swapper(Face.attack(0, I))
	var u := _mech("A", Die.of([swap, Face.attack(10, L)]), 40, 100)
	sk.add_mech(u)
	var front := _ghoul(100, 1)
	var caster := _archer(100, 1)
	sk.add_foes([front, caster])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.needs_second(ms), "a Swap takes a second target")
	assert_false(sk.assign(0, caster), "and is not spent without one")
	var seconds := sk.swap_targets(caster)
	assert_true(seconds.has(front) and seconds.has(Vector2i(0, 1)), "another foe, or an empty slot")
	assert_false(seconds.has(caster), "never itself")
	var from := Vector2i(caster.rank, caster.column)
	var empty_front := -1
	for col in range(3):
		if sk.foe_at(0, col) == null:
			empty_front = col
			break
	assert_true(sk.assign(0, caster, Vector2i(0, empty_front)), "the caster pulled into an empty front slot")
	assert_eq(Vector2i(caster.rank, caster.column), Vector2i(0, empty_front), "it stands in the front now")
	assert_eq(sk.foe_at(1, from.y), null, "its old slot is empty")
	assert_eq(caster.hp, 100, "no damage")
	assert_true(sk.targets_for_face(ms, Face.attack(10, L)).has(caster), "a Direct gun reaches it")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	var a := Vector2i(front.rank, front.column)
	var b := Vector2i(caster.rank, caster.column)
	assert_true(sk.assign(0, front, caster), "two foes")
	assert_eq(Vector2i(front.rank, front.column), b, "trade places")
	assert_eq(Vector2i(caster.rank, caster.column), a, "both ways")
	assert_true("\n".join(sk.log).contains("trade places"), "the log says so")
	# A massive foe stays.
	var s2 := Skirmish.new(1, 3)
	var v := _mech("B", Die.single(swap), 40, 100)
	s2.add_mech(v)
	var big := Foe.make("titan", 500, 1)
	big.size = 2   # massive: it fills its column
	var small := _ghoul(100, 1)
	s2.add_foes([big, small])
	s2.begin()
	s2.start_round()
	assert_false(s2.targets_for(0).has(big), "a massive foe is no first target")
	assert_false(s2.swap_targets(small).has(big), "nor a second")


## Reraise on an ally (Ryan, 16 October: the promoted Cleric's, cast on the other party
## members, never itself): Undying on one of its own not yet readied, a party member
## before the rest, the heaviest hitter among them first; with every one readied the move
## has no case to cast, and a readied ally gets back up once, whole.
func test_a_reraise_readies_one_of_its_own_a_party_member_first_and_never_itself() -> void:
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 400, 400))
	var cleric := Foe.make("cleric", 90, 10, true)
	cleric.hero = true
	cleric.actions = [_special("buff", "revive_once_ally", {"when": ["ally_unready"]}), Foe.basic_action()]
	var brute := _ghoul(100, 40)   # the heaviest hitter, and no party member
	var squire := _ghoul(100, 10)
	squire.hero = true
	var knight := _ghoul(100, 20)
	knight.hero = true
	sk.add_foes([brute, squire, knight, cleric])
	sk.begin()
	var reraise: Dictionary = cleric.actions[0]
	assert_true(sk.legal_actions(cleric).has(reraise), "one of its own is not readied, so it may cast")
	var readied: Array = []
	for i in range(3):
		sk.start_round()
		cleric.action = reraise
		sk.end_round()
		for f in [brute, squire, knight]:
			if Effects.has(f, "risen") and not readied.has(f):
				readied.append(f)
	assert_eq(readied, [knight, squire, brute], "the party first, the heavier hitter of it first, then the rest")
	assert_false(Effects.has(cleric, "risen"), "never itself")
	assert_false(sk.legal_actions(cleric).has(reraise), "with every one readied it has nothing to cast")
	assert_true("\n".join(sk.log).contains("revenant will return once"), "the log names the one readied")
	knight.hp = 0
	sk._clear_dead_slots()
	assert_true(sk.field_foes().has(knight) and knight.hp == knight.hp_max, "the readied ally falls and gets back up in its slot, whole")


## The die's kinds (Ryan, 20 and 21 October): a debuff is equipment aimed at a foe, and it deals
## none under any effect (a flat add, a multiply, a floor) and carries no primer, its heat
## running as a weapon's; it prints no number and wears its reach frame with the status mark; a gun
## whose blow is nothing here prints "0".
func test_a_debuff_deals_nothing_under_any_effect_and_prints_no_number() -> void:
	var lure := Face.attack(0, I, [K.LURE])
	lure.heat = 5
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.single(lure), 40, 100)
	m.grant_passive({"id": "test_hot_hands", "name": "Hot hands", "description": "",
		"effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 10},
			{"trigger": "on_attack", "effect": "multiply_damage", "value": 2.0},
			{"trigger": "on_attack", "effect": "min_damage", "value": 5},
			{"trigger": "on_attack", "effect": "add_heat", "value": 5}]}, "test")
	Effects.stack(m, Effects.STATUS["primed"], Effects.SKIRMISH, "buff", 2, Effects.DECAY_NONE)
	sk.add_mech(m)
	var g := _ghoul(100, 10)
	sk.add_foes([g, _ghoul(100, 10)])
	sk.begin()
	sk.start_round()
	assert_true(lure.is_debuff() and lure.is_equipment(), "an attack of no damage is a debuff, equipment")
	var modded := Effects.attack(m, lure, 0, lure.heat, g)
	assert_eq(int(modded["damage"]), 0, "no add, no multiply, no floor")
	assert_false(sk.shown_face(sk.mechs[0], lure).has(K.ABLATE), "and no primer's keyword: equipment carries none")
	assert_eq(int(modded["heat"]), 10, "its heat is a weapon's, the passive's heat in")
	assert_eq(sk.shown_number_text(sk.mechs[0], lure, g), "", "it prints no number, over a foe or not")
	assert_eq(lure.number_text(), "", "nor on the die's own entry")
	assert_eq(lure.describe(), "indirect lure (+5 heat)", "its line is its reach and keywords")
	assert_eq([Glyphs.primary_for(lure), Glyphs.aim_for(lure)], ["equipment", "aim_indirect"], "an Indirect debuff is equipment's gear over the curved arrow")
	assert_eq([Glyphs.primary_for(Face.attack(0, L, [K.SHOCK])), Glyphs.aim_for(Face.attack(0, L, [K.SHOCK]))], ["equipment", "aim_direct"], "a Direct one the straight arrow")
	assert_true(sk.assign(0, g), "spent on a foe in reach")
	assert_eq(g.hp, 100, "it dealt nothing")
	assert_eq([Effects.stacks_of(g, "ablating"), Effects.stacks_of(m, "primed")], [0, 2], "it laid no Ablating and spent no Primed")
	assert_eq(sk.mechs[0].heat, 10, "its heat landed")
	var gun := Face.attack(5, L)
	assert_false(gun.is_debuff(), "a gun of 5 is a gun")
	var plated := _ghoul(100, 10)
	plated.armour = 5
	var sk2 := Skirmish.new(1, 1)
	sk2.add_mech(_mech("B", Die.single(gun), 40, 100))
	sk2.add_foes([plated])
	sk2.begin()
	assert_eq(sk2.shown_number_text(sk2.mechs[0], gun, plated), "0", "whose blow is nothing here prints 0")


## A vent's shield half left with the Wake Diffuser, its last piece (19 November): the validator
## refuses the key wherever it stands, and a vent vents alone.
func test_a_vents_shield_half_is_refused() -> void:
	var f := Face.from_dict({"kind": "vent", "power": 10, "shields": 10})
	assert_eq(f.describe(), "vent 10", "a vent says its vent alone")
	assert_false(f.shields_machine(), "and shields nothing")
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var cid := str(db.components.keys()[0])
	db.components[cid]["face"] = {"kind": "vent", "power": 10, "shields": 5}
	var refused := false
	for e in db.validate():
		if e.contains("shields left the entry"):
			refused = true
	assert_true(refused, "the key is refused")


## Two pieces the Kite's first rework built (Ryan's go, 21 October) that its second kit and the
## Ammit's still print, on a synthetic passive: a multiply on the printed number alone, the buffs
## added once after it, and a kill trigger laying a status. Its third, a cooldown a passive
## granted every weapon, left the engine with its last piece (12 November).
func test_a_printed_double_and_a_kill_trigger() -> void:
	var regs := {"id": "regs", "name": "Regs", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_printed", "value": 2},
		{"trigger": "on_kill", "effect": "stack_status", "value": "hopper"}]}
	var gun := Face.attack(10, L)
	gun.heat = 5
	var sk := Skirmish.new(1, 2)
	var m := _mech("Kite", Die.of([gun, gun.duplicate_face(), Face.shield(10)]), 40, 100)
	m.grant_passive(regs)
	sk.add_mech(m)
	var weak := _ghoul(15, 10)
	sk.add_foes([weak, _ghoul(200, 10)])
	sk.begin()
	sk.start_round()
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.SKIRMISH, "test", 5, Effects.DECAY_NONE)
	assert_eq(int(Effects.attack(m, gun, 10, 5, weak)["damage"]), 25, "the printed 10 doubled, then the buff's 5 once")
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, weak), "the doubled gun kills the weak foe")
	assert_eq(Effects.dark_rounds(m, 0, sk.round), 0, "a gun with no cooldown of its own stays lit: no passive darkens it")
	assert_eq(Effects.stacks_of(m, "hopper"), 1, "the kill lays the status its trigger names")
	assert_true("\n".join(sk.log).contains("after the kill"), "the log says why")


## The Kite's kit since 11 November (Ryan: "Burst glass cannon"), on a synthetic passive. The
## opener: a double on the printed number against an unhurt foe alone, read as the hit judges
## the foe, so both strikes of a two-strike gun take it and the next spend on that foe takes
## none; the die shows each foe its own number; an area reads each foe for itself.
const OPENER := {"id": "opener", "name": "Opener", "description": "", "effects": [
	{"trigger": "on_attack", "effect": "multiply_printed", "value": 2, "when": "target_unhurt"},
	{"trigger": "on_kill", "effect": "refill_shield"}]}


func test_an_opener_doubles_on_the_unhurt_judged_once_a_hit() -> void:
	var twin := Face.attack(3, L)
	twin.strikes = 2
	var spread := Face.attack(4, L, [K.CLEAVE])
	spread.cleave = 2
	var sk := Skirmish.new(1, 3)
	var m := _mech("Kite", Die.of([twin, Face.attack(5, L), spread]), 40, 100)
	m.grant_passive(OPENER)
	sk.add_mech(m)
	sk.add_foes([_ghoul(100, 0), _ghoul(100, 0), _ghoul(100, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var a: Foe = sk.front[0]
	var b: Foe = sk.front[1]
	var c: Foe = sk.front[2]
	assert_eq(sk.shown_number(ms, twin, a), 6, "the die over an unhurt foe shows its 3 doubled")
	ms.face_index = 0
	assert_true(sk.assign(0, a), "the two-strike gun on the unhurt foe")
	assert_eq(a.hp, 88, "both strikes at 6: the foe was judged as the die was spent, not between them")
	assert_eq(sk.shown_number(ms, twin, a), 3, "hurt now: the die shows the plain number over it")
	assert_eq(sk.shown_number(ms, twin, b), 6, "and the doubled one over a foe nothing has touched")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, a), "a later spend on the hurt foe")
	assert_eq(a.hp, 83, "is plain")
	sk.end_round()
	sk.start_round()
	# An area: the aimed foe hurt, its neighbour unhurt, each read for itself.
	ms.face_index = 2
	assert_true(sk.assign(0, a), "the Spread gun on the hurt foe")
	assert_eq([a.hp, b.hp, c.hp], [79, 96, 100], "the hurt target its plain 4, the unhurt neighbour its Spread 2 doubled, the far one out of the shape")


## Its lock's finish (the Pinion Driver since 11 November; the Coriolis Accelerator's slope as one
## step): the entry's number times its finisher against a foe at half its HP or less, read as
## the hit judges the foe, so a first strike that takes a foe to half does not double the
## second; with the opener beside it the two never meet on one blow.
func test_a_finisher_doubles_at_half_or_less_judged_once_a_hit() -> void:
	var driver := Face.attack(2, L)
	driver.strikes = 2
	driver.finisher = 2
	assert_true(driver.has_unique_rule() and driver.describe().contains("×2 on a foe at half its HP or less"), "the entry prints its rule")
	assert_true(driver.rule_phrases().has("×2 on a foe at half its HP or less"), "and its hold lists it")
	assert_eq(Face.from_dict(driver.to_dict()).finisher, 2, "it survives the content round-trip")
	assert_eq(driver.duplicate_face().finisher, 2, "and a copy")
	var sk := Skirmish.new(1, 3)
	var m := _mech("Kite", Die.single(driver), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 0), _ghoul(20, 0), _ghoul(20, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var whole: Foe = sk.front[0]
	var half: Foe = sk.front[1]
	var near: Foe = sk.front[2]
	half.hp = 10
	near.hp = 11
	assert_eq([sk.shown_number(ms, driver, whole), sk.shown_number(ms, driver, half), sk.shown_number(ms, driver, near)], [2, 4, 2], "the die shows the double over the foe at half alone")
	assert_true(sk.assign(0, half), "on the foe at half")
	assert_eq(half.hp, 2, "both strikes doubled")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(0, near), "on the foe a point above half")
	assert_eq(near.hp, 7, "both plain: the first strike took it to half, and the hit had judged it already")
	# With the opener: doubled on the unhurt by the passive, on the half-dead by its own rule.
	m.grant_passive(OPENER)
	near.hp = 15   # hurt, and above half
	assert_eq([sk.shown_number(ms, driver, whole), sk.shown_number(ms, driver, half), sk.shown_number(ms, driver, near)], [4, 4, 2], "double at both ends and plain between, never both at once")
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var cid := ""
	for id in db.components.keys():
		if str(db.components[id].get("face", {}).get("kind", "")) == "shield":
			cid = str(id)
			break
	if not cid.is_empty():
		db.components[cid]["face"]["finisher"] = 2
		var refused := false
		for e in db.validate():
			if e.contains("finisher is a weapon's"):
				refused = true
		assert_true(refused, "a finisher on anything but a weapon is refused")


## A kill of its own recharges its shield whole (Ryan, 11 November: "kills recharge it's shield
## completely"): what it is short of its maximum and no more, once a spend that killed; nothing
## for a spend that kills nothing; and the bot weighs the shield a kill would give back.
func test_a_kill_recharges_the_shield_whole() -> void:
	var gun := Face.attack(10, L)
	var sk := Skirmish.new(1, 3)
	var m := _mech("Kite", Die.single(gun), 40, 100)
	m.grant_passive(OPENER)
	sk.add_mech(m)
	sk.add_foes([_ghoul(5, 10), _ghoul(300, 10), _ghoul(300, 10)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var weak: Foe = null
	var big: Foe = null
	for f in sk.field_foes():
		if f.hp_max == 5:
			weak = f
		elif big == null:
			big = f
	m.shield = 12
	var bot := Policy.make(Policy.GREEDY, 1)
	var short := bot.attack_score(sk, ms, gun, weak)
	m.shield = m.shield_max
	assert_true(short > bot.attack_score(sk, ms, gun, weak), "the bot weighs the shield a kill gives back")
	m.shield = 12
	assert_true(sk.assign(0, big), "a spend that kills nothing")
	assert_eq(m.shield, 12, "recharges nothing")
	m.shield = m.shield_max   # whole for the foes' turn: a shield they take to nothing is broken, and a kill gives a broken one nothing
	sk.end_round()
	sk.start_round()
	m.shield = 3
	assert_true(sk.assign(0, weak), "a spend that kills")
	assert_eq(m.shield, m.shield_max, "the shield back whole")
	assert_true("\n".join(sk.log).contains("after the kill"), "the log says why")


## The split (the Skua's Split-cycle Breech, built 25 October; Ryan, 7 November: "Doubles the
## number of hits ... for Weapons and Equipment. Base weapon damage is
## halved (rounded down, minimum 1)"; "the spirit of buffs and riders is they happen after"): a
## weapon hits twice as often, each hit's base halved, rounded down and never below one, then every
## buff counting on each hit whole, then the foe's own reads (its Brittle) and its armour; the die
## shows a hit's blow beside the hits. A debuff deals nothing to halve and hits twice all the same,
## its riders on each hit (Ryan, 25 October: "That's kind of the whole point"). No passive splits today.
func test_a_split_passive_hits_twice_its_base_halved_rounded_down() -> void:
	var split := {"id": "split", "name": "Split", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "split_strikes", "value": 2}]}
	var gun := Face.attack(3, L)
	var sk := Skirmish.new(1, 2)
	var m := _mech("S", Die.single(gun), 40, 100)
	m.grant_passive(split)
	sk.add_mech(m)
	var bare := _ghoul(100, 10)
	var plate := _ghoul(100, 10)
	plate.armour = 1
	sk.add_foes([bare, plate])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var shown := sk.shown_face(ms, gun)
	assert_eq(shown.strikes, 2, "two hits")
	assert_eq(shown.number_text(), "1", "each a 3 halved, rounded down")
	assert_true(shown.describe().contains("×2"), "the hits beside it")
	assert_eq(sk.shown_number(ms, shown, bare), 1, "the die over a bare foe")
	assert_eq(sk.shown_number(ms, shown, plate), 0, "over armour 1 each hit bounces")
	assert_eq(Effects.effective_face(m, shown).strikes, 2, "never split twice")
	assert_true(sk.assign(0, bare), "fired")
	assert_eq(bare.hp, 98, "1 twice")
	sk.end_round()
	sk.start_round()
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.SKIRMISH, "test", 2)
	shown = sk.shown_face(ms, gun)
	assert_eq(sk.shown_number(ms, shown, plate), 2, "Empowered on each hit, after the halving: 1 + 2, the armour off each")
	ms.face_index = 0
	assert_true(sk.assign(0, plate), "fired on plate")
	assert_eq(plate.hp, 96, "(1 + 2 - 1) twice")
	var probe := Face.attack(0, L, [K.BRITTLE])
	probe.brittle = 1
	assert_eq(Effects.effective_face(m, probe).strikes, 2, "a debuff hits twice")
	sk.end_round()
	sk.start_round()
	ms.die = Die.single(probe)
	ms.face_index = 0
	var before := Effects.stacks_of(bare, "brittled")
	assert_true(sk.assign(0, bare), "the debuff spent")
	assert_eq(Effects.stacks_of(bare, "brittled") - before, 2, "its Brittle on each hit")
	assert_eq(bare.hp, 98, "and no damage")
	# The foe's own reads come after the halving, whole (the blow's order): the Brittle the debuff
	# laid adds its points to each halved hit.
	sk.end_round()
	sk.start_round()
	ms.die = Die.single(gun)
	ms.face_index = 0
	var brittle := Effects.stacks_of(bare, "brittled")
	assert_true(brittle > 0, "the Brittle still stands")
	assert_eq(sk.shown_number(ms, sk.shown_face(ms, gun), bare), 1 + brittle, "a halved 1, then the foe's Brittle whole")


## The spend's order (Ryan, 7 November: "Spend-hit(s)-riders per hit-check death-end
## spend-revive/split"; "nothing normal should hit a unit and it's revive/split/spawn in the same
## spend"): a foe getting back up and a split's arrivals stand only once the spend is done, so a
## multi-hit's later hits land on the corpse, and a Purge on the
## killing hit strips its Getting Back Up before the death check, so it stays down.
func test_what_a_kill_brings_back_waits_for_the_spend_to_end() -> void:
	# A multi-hit's second hit lands on the corpse; it gets back up whole once the spend is done.
	var twice := Face.attack(10, L)
	twice.strikes = 2
	var sk := Skirmish.new(3, 1)
	sk.add_mech(_mech("A", Die.single(twice), 40, 100))
	var g := _ghoul(8, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.stack(g, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(0, g), "the multi-hit")
	assert_eq(sk.front[0], g, "it got back up in its own slot once the spend was done")
	assert_eq(g.hp, 8, "whole: the second hit had landed on its corpse, before it rose")
	assert_true(sk.returned.any(func(r: Dictionary) -> bool: return r["foe"] == g and r["how"] == "rises"), "the spend's returns name it")
	# A Purge on the killing hit lands before the death check: it stays down.
	var purge := Face.attack(5, L, [K.DISPEL])
	purge.dispel = 1
	purge.strikes = 2
	var s3 := Skirmish.new(3, 2)
	s3.add_mech(_mech("C", Die.single(purge), 40, 100))
	var gone := _ghoul(4, 10)
	var stays := _ghoul(100, 10)
	s3.add_foes([gone, stays])
	s3.begin()
	s3.start_round()
	Effects.stack(gone, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(s3.assign(0, gone), "the purging gun")
	assert_false(gone.alive(), "felled")
	assert_true(s3.front[0] == null, "and the Purge took its Getting Back Up before the death check: it stays down")
	# A split's halves step up once the spend is done: a multi-hit's later hit lands on the Gel's
	# corpse, the halves untouched.
	var pair := Face.attack(5, L)
	pair.strikes = 2
	var s4 := Skirmish.new(2, 2)
	s4.add_mech(_mech("D", Die.single(pair), 40, 100))
	var heavy := _ghoul(500, 20)
	var gel := _ghoul(4, 10)
	gel.display_name = "gel"
	gel.on_death = {"summon": "gel_small", "count": 2}
	s4.foe_factory = func(id: String) -> Foe: return Foe.make(id, 10, 5)
	s4.add_foes([heavy, gel])
	s4.begin()
	s4.start_round()
	assert_eq(s4.front[1], gel, "the gel stands second")
	assert_true(s4.assign(0, gel), "two hits at the gel")
	assert_eq(heavy.hp, 500, "the heavy untouched")
	assert_eq(s4.front[1].display_name, "gel_small", "the gel split once the hits were done")
	assert_eq(s4.front[1].hp, 10, "its half whole: the second hit landed on the corpse")
	assert_true(s4.returned.any(func(r: Dictionary) -> bool: return r["foe"] == gel and r["how"] == "splits"), "the spend's returns name the split")


## An entry's own effects past its blow land in the rider phase, before the death check, on a
## target the hit felled too (Ryan, 7 November: "if a swap did damage, it should play out the
## same: deal damage, then swap (in the rider phase), check death, end spend, and revive in the
## NEW spot, since the split/revive is attached to the unit, not the spot"): a damaging Swap
## moves the foe it kills, which gets back up where it was moved to; a detonation lands on a
## target its own chip felled, before the death check, and its fall blows nothing more.
func test_a_swap_lands_in_the_rider_phase_and_a_revive_stands_in_the_new_spot() -> void:
	var swapper := _swapper(Face.attack(10, L))
	var sk := Skirmish.new(3, 3)
	sk.add_mech(_mech("A", Die.single(swapper), 40, 100))
	var up := _ghoul(4, 10)
	var other := _ghoul(100, 10)
	sk.add_foes([up, other])
	sk.begin()
	sk.start_round()
	Effects.stack(up, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(sk.front[0] == up and sk.front[1] == other and sk.front[2] == null, "two in front, the third column empty")
	assert_true(sk.assign(0, up, Vector2i(0, 2)), "the damaging swap: its blow kills, then it moves the foe")
	assert_eq(sk.front[2], up, "it got back up in the slot it was moved to, not the one it was struck in")
	assert_true(sk.front[0] == null, "the slot it was struck in stands empty")
	assert_eq(up.hp, 4, "whole")
	# A damaging detonation lands on the target its blow felled, before the death check.
	var drone := Face.attack(10, L)
	drone.detonates = true
	var s2 := Skirmish.new(3, 2)
	s2.add_mech(_mech("B", Die.single(drone), 40, 100))
	var prey := _ghoul(4, 10)
	var beside := _ghoul(100, 10)
	s2.add_foes([prey, beside])
	s2.begin()
	s2.start_round()
	s2._add_mine(prey, 3, {})
	assert_true(s2.assign(0, prey), "the damaging drone")
	assert_false(prey.alive(), "its blow kills")
	assert_eq(beside.hp, 97, "the Mine blew once, on the foe beside it")


## A massive foe fills both slots of its column. Area aimed at it reaches the foes beside it, and
## its own column adds nothing, so it never takes its own Penetrate twice (Ryan, 7
## November: "Whatever it does now is fine, it will just be something to test"); a back-rank
## Spread's row meets it like any foe in that rank.
func test_area_meets_a_massive_foe_once_from_either_rank() -> void:
	var plus := Face.attack(10, I, [K.CLEAVE, K.PENETRATE])
	plus.cleave = 3
	plus.penetrate = 3
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(plus), 40, 100))
	var left := _ghoul(100, 10)
	var giant := _colossus(100)
	var right := _ghoul(100, 10)
	sk.add_foes([giant, left, right])
	sk.begin()
	sk.start_round()
	var gc := giant.column
	assert_true(sk.front[gc] == giant and sk.back[gc] == giant, "the giant fills its column")
	assert_true(sk.assign(0, giant), "the plus at the giant")
	assert_eq(giant.hp, 90, "it takes the blow once: its column holds only itself")
	var beside := 0
	for f in [left, right]:
		if absi(f.column - gc) == 1:
			beside += 1
			assert_eq(f.hp, 97, "a foe beside it takes the Spread")
	assert_true(beside >= 1, "something stood beside it")
	var lance := Face.attack(10, L, [K.PENETRATE])
	lance.penetrate = 4
	var s2 := Skirmish.new(1, 2)
	s2.add_mech(_mech("B", Die.single(lance), 40, 100))
	var g2 := _colossus(100)
	s2.add_foes([g2, _ghoul(100, 10)])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, g2), "Penetrate at the giant")
	assert_eq(g2.hp, 90, "once: nothing else in its column")
	# A back-rank Spread beside a massive foe's column meets it.
	var spread := Face.attack(10, I, [K.CLEAVE])
	spread.cleave = 4
	var s3 := Skirmish.new(1, 2)
	s3.add_mech(_mech("C", Die.single(spread), 40, 100))
	var g3 := _colossus(100)
	var rear := _archer(100, 10)
	s3.add_foes([g3, rear])
	s3.begin()
	s3.start_round()
	assert_true(s3.back[g3.column] == g3 and s3.back[1 - g3.column] == rear, "the giant's column and an archer behind the other")
	assert_true(s3.assign(0, rear), "Spread at the back-rank archer")
	assert_eq([rear.hp, g3.hp], [90, 96], "the archer takes the blow, the giant beside it in the back rank the Spread")


## Expose and Exposed (the Kestrel session, 20 and 21 October): every foe the entry reaches and
## leaves standing is Exposed through the next round, in Direct reach of every machine as if
## its column's front were empty and its armour counting for nothing, its own and any Armoured;
## a second Expose refreshes it, never adds; it feeds the Paradox and the bot weighs it.
func test_an_expose_puts_a_back_foe_in_direct_reach_and_zeroes_its_armour() -> void:
	var designator := Face.attack(0, I, [K.EXPOSE])
	var gun := Face.attack(20, L)
	var sk := Skirmish.new(1, 1)
	sk.add_mech(_mech("Spotter", Die.single(designator), 40, 100))
	sk.add_mech(_mech("Gunner", Die.single(gun), 40, 100))
	var wall := _ghoul(200, 10)
	var caster := _archer(100, 10)
	caster.armour = 5
	sk.add_foes([wall, caster])
	sk.begin()
	sk.start_round()
	Effects.stack(caster, Effects.STATUS["braced"], Effects.SKIRMISH, "test", 3, Effects.DECAY_NONE)
	assert_false(sk.targets_for(1).has(caster), "behind its wall the back rank is out of Direct reach")
	assert_eq(caster.armour_total(), 8, "its armour and its brace")
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_true(bot.expose_score(sk, caster) > 0.0, "the bot weighs exposing it")
	assert_true(sk.assign(0, caster), "the designator, Indirect, reaches it")
	assert_true(Effects.has(caster, "exposure"), "it is Exposed")
	assert_eq(caster.armour_total(), 0, "its armour counts for nothing, its own and the brace")
	assert_true(sk.targets_for(1).has(caster), "and every machine's Direct gun reaches it")
	assert_true(sk.assign(1, caster), "the gunner's line gun")
	assert_eq(caster.hp, 80, "the whole 20 lands")
	assert_eq(bot.expose_score(sk, caster), 0.0, "exposing it again adds nothing to weigh")
	sk.end_round()
	sk.start_round()
	assert_true(Effects.has(caster, "exposure"), "through the next round")
	sk.end_round()
	sk.start_round()
	assert_false(Effects.has(caster, "exposure"), "then gone")
	assert_false(sk.targets_for(1).has(caster), "behind its wall again")


## The Lammergeier's Mines (the Reverberant Payload, Ryan, 9 November: "the lammergeier basically
## converts all hits to AoE hits, at the cost of a delay until Death"), on a synthetic passive: a
## machine that leaves Mines leaves one on every foe it aims a weapon or equipment at, its flat damage
## and the spend's keywords, one Mine a foe however many spends feed it; when the foe falls, getting
## back up or splitting included, the Mine blows on every foe round its slot (Splash's shape).
const MINER := {"id": "bay", "name": "Bay", "description": "", "effects": [{"trigger": "static", "effect": "mine_on_spend", "value": 2}]}


## One Mine a spend (Ryan, 9 November: "One mine per spend ... we're only adding N flat damage
## (plain, not modified by lammergeier modifiers), and the keywords attached to it. Area modifiers,
## targeting rules (sweep), and hit counts are ignored. Anything that ties it back to the firer is
## ignored, like lure"; "the mine should take the entire result of the spend"): the target alone,
## its damage flat whatever the strikes, its stacks every hit's; a second spend adds to the Mine.
func test_every_spend_at_a_foe_leaves_one_mine_of_its_flat_damage_and_keywords() -> void:
	var sk := Skirmish.new(1, 3)
	var gun := Face.attack(2, I, [K.ABLATE, K.SHOCK, K.CLEAVE, K.LURE])
	gun.ablate = 1
	gun.cleave = 1
	gun.strikes = 3
	var bomber := _mech("Bomber", Die.single(gun), 40, 100)
	bomber.grant_passive(MINER)
	bomber.grant_passive({"id": "test_edge", "name": "Edge", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 5}]})
	sk.add_mech(bomber)
	sk.add_mech(_mech("Plain", Die.single(Face.attack(1, I)), 40, 100))
	var a := _ghoul(200, 0)
	var b := _ghoul(200, 0)
	var c := _ghoul(200, 0)
	sk.add_foes([a, b, c])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, b), "the bomber's spend at the middle foe")
	var mine := Skirmish.mine_of(b)
	assert_eq(int(mine["damage"]), 2, "one Mine of the flat 2, whatever the gun's strikes or its firer's +5")
	assert_eq(int(mine["riders"]["stacks"]["ablating"]), 3, "the Ablating its three hits fired")
	assert_eq(mine["riders"]["keywords"], ["shock"], "its Shock rides; Spread and Lure stay with the spend")
	assert_true(Skirmish.mine_of(a).is_empty() and Skirmish.mine_of(c).is_empty(), "the target alone: the Spread's neighbours carry none")
	assert_true("\n".join(sk.log).contains("leaves a Mine on revenant: Mine 2: Ablate 3, Shock"), "the log says so")
	sk.mechs[0].assigned = false
	assert_true(sk.assign(0, b), "a second spend at it")
	mine = Skirmish.mine_of(b)
	assert_eq([int(mine["damage"]), int(mine["riders"]["stacks"]["ablating"])], [4, 6], "one Mine, the second spend's 2 and its three Ablating added")
	assert_eq(mine["riders"]["keywords"], ["shock"], "a flag rides once")
	assert_true(sk.assign(1, a), "a machine without the passive")
	assert_true(Skirmish.mine_of(a).is_empty(), "leaves none")


## The Mine blows when its foe falls (Ryan, 9 November: "On death, the mine explodes, dealing its
## damage and keywords in an area, I would probably go for Splash as the shape to start"): every foe
## beside it in its rank and the other rank of its column takes its damage, plain, through its own
## Brittle and armour, aimed at nobody (a Shock neither doubles nor is spent), then its keywords; the
## blast lands as a blow the screen plays, after the spend's own.
func test_a_mine_blows_on_every_foe_round_its_slot_when_its_foe_falls() -> void:
	var sk := Skirmish.new(1, 3)
	var gun := Face.attack(1, I, [K.ABLATE])
	gun.ablate = 1
	var bomber := _mech("Bomber", Die.single(gun), 40, 100)
	bomber.grant_passive(MINER)
	sk.add_mech(bomber)
	sk.add_mech(_mech("Killer", Die.single(Face.attack(200, L)), 40, 100))
	var a := _ghoul(100, 0)
	var b := _ghoul(100, 0)
	var c := _ghoul(100, 0)
	var behind := _archer(100, 0)
	var far := _archer(100, 0)
	sk.add_foes([a, b, c, far, behind])
	sk.begin()
	sk.start_round()
	assert_true(sk.front[1] == b and sk.back[1] == behind, "b mid-front, the archer behind it")
	a.armour = 1
	Effects.stack(c, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 1, Effects.status_decay(Effects.STATUS["brittled"]))
	_shock_on(behind)
	assert_true(sk.assign(0, b), "the Mine laid on b")
	var b_hp := b.hp
	assert_true(sk.assign(1, b), "the killer fells it")
	assert_false(b.alive(), "b is down")
	assert_eq(a.hp, 100 - 1, "beside it, its armour off the 2")
	assert_eq(c.hp, 100 - 3, "beside it, its Brittle on the 2")
	assert_eq(behind.hp, 100 - 2, "behind it, the 2 plain: no Shock doubles a blast")
	assert_true(Effects.has(behind, "shocked"), "and its Shock stands")
	assert_eq(far.hp, 100, "the far back slot is no neighbour")
	for f in [a, c, behind]:
		assert_eq(Effects.stacks_of(f, "ablating"), 1, "its Ablate 1 on each foe it met")
	assert_true(sk.spend_blows.any(func(x: Dictionary) -> bool: return str(x["kind"]) == "mine" and x["foe"] == behind), "the screen lands the blast as its own blows")
	assert_true("\n".join(sk.log).contains("the Mine on revenant blows: Mine 2: Ablate 1"), "the log says so")
	assert_eq(b_hp, 100 - 1, "the bomber's own hit landed whole first")


## The Mine takes the spend's whole result on its target (Ryan, 9 November: "the mine should take
## the entire result of the spend, then apply it. So a 3-hit flak that burns 1 per hit if the target
## is under 50% HP, would result in adding a 2 damage mine with 3 flak, and 0-3 burn depending on
## when the target reached under 50% HP during the spend"): every hit's stacks, as its machine
## deepened and doubled them, a passive's lays and a burn whose condition held as the die was spent
## (a single-target weapon's conditions are read then, the rules' blow order); the damage stays flat.
func test_a_mine_takes_the_whole_result_of_the_spend_every_hits_stacks_as_fired() -> void:
	var sk := Skirmish.new(1, 3)
	var brittle := Face.attack(1, I, [K.BRITTLE])
	brittle.brittle = 1
	brittle.strikes = 3
	var bomber := _mech("Bomber", Die.single(brittle), 40, 100)
	bomber.grant_passive(MINER)
	bomber.grant_passive({"id": "test_scorch_brittle", "name": "Scorch", "description": "", "effects": [{"trigger": "on_attack", "effect": "lay_status", "value": "ablating", "when": "target_status", "status": "brittled"}]})
	sk.add_mech(bomber)
	var b := _ghoul(100, 0)
	sk.add_foes([_ghoul(100, 0), b])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, b), "three hits of Brittle 1 on a foe with no Brittle")
	var mine := Skirmish.mine_of(b)
	assert_eq(int(mine["damage"]), 2, "a 2 damage Mine")
	assert_eq(int(mine["riders"]["stacks"].get("brittled", 0)), 3, "with 3 Brittle")
	assert_eq(int(mine["riders"]["stacks"].get("ablating", 0)), 0, "and no Ablating: the condition did not hold as the die was spent")
	sk.mechs[0].assigned = false
	assert_true(sk.assign(0, b), "again, the foe now Brittle")
	mine = Skirmish.mine_of(b)
	assert_eq([int(mine["riders"]["stacks"]["brittled"]), int(mine["riders"]["stacks"].get("ablating", 0))], [6, 3], "its 3 Brittle more and 3 Ablating, a hit each")
	# Deepened and doubled as its machine lays them, and a passive's lays among them.
	var s2 := Skirmish.new(1, 3)
	var burner := Face.attack(1, I, [K.ABLATE])
	burner.ablate = 1
	burner.strikes = 2
	var deep := _mech("Deep", Die.single(burner), 40, 100)
	deep.grant_passive(MINER)
	deep.grant_passive({"id": "test_deepen", "name": "Deepen", "description": "", "effects": [{"trigger": "on_stack", "effect": "add_stacks", "value": 1}]})
	deep.grant_passive({"id": "test_double", "name": "Double", "description": "", "effects": [{"trigger": "on_attack", "effect": "multiply_stacks", "value": 2}]})
	deep.grant_passive({"id": "test_vitriol", "name": "Ambush", "description": "", "effects": [{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1}]})
	s2.add_mech(deep)
	var t := _ghoul(100, 0)
	s2.add_foes([t])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, t), "two hits of Ablate 1, deepened a stack and doubled")
	var landed_burn := Effects.stacks_of(t, "ablating")
	var m2 := Skirmish.mine_of(t)
	assert_eq(int(m2["riders"]["stacks"]["ablating"]), landed_burn, "the Mine's Ablating is what the spend landed: %d" % landed_burn)
	assert_eq(landed_burn, 2 * (1 + 1) * 2, "each hit's 1 deepened to 2 and doubled to 4")
	assert_eq(int(m2["riders"]["stacks"]["vitriol"]), Effects.stacks_of(t, "vitriol"), "and the Vitriol its passive laid")
	assert_true(Skirmish.mine_text(m2).contains("Ablate 8") and Skirmish.mine_text(m2).contains("Vitriol"), "the readout names them: %s" % Skirmish.mine_text(m2))


## The Mine is laid as a rider, before the death check (Ryan, 9 November: "applied before the death
## check, correct"), so a spend that fells its target blows the Mine it just left, with whatever the
## target carried.
func test_a_kill_by_the_bombers_own_spend_blows_its_mine_at_once() -> void:
	var sk := Skirmish.new(1, 3)
	var bomber := _mech("Bomber", Die.single(Face.attack(50, I)), 40, 100)
	bomber.grant_passive(MINER)
	sk.add_mech(bomber)
	var a := _ghoul(100, 0)
	var b := _ghoul(40, 0)
	var c := _ghoul(100, 0)
	sk.add_foes([a, b, c])
	sk.begin()
	sk.start_round()
	sk._add_mine(b, 3, {})
	assert_true(sk.assign(0, b), "the bomber's killing spend")
	assert_eq([a.hp, c.hp], [95, 95], "its own 2 and the 3 it carried blow on both neighbours at once")
	assert_true(Skirmish.mine_of(b).is_empty(), "the Mine spent")


## It blows on any fall the death check clears (Ryan, 9 November: "the explosion should occur after
## the death check regardless of revive or split ... I'd go with 'a killing blow' instead of 'on
## death'"; Claude's lean, his: a fall, so a tick's counts too): a foe that gets back up rises
## clean, a Gel's halves stand after the blast and take none of it, and a foe its Ablating fells in
## the enemy's turn blows there.
func test_a_mine_blows_when_its_foe_falls_to_get_back_up_or_to_split_or_to_a_tick() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("Killer", Die.single(Face.attack(200, L)), 40, 100))
	var a := _ghoul(100, 0)
	var riser := _ghoul(30, 0)
	var c := _ghoul(100, 0)
	sk.add_foes([a, riser, c])
	sk.begin()
	sk.start_round()
	Effects.stack(riser, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	sk._add_mine(riser, 4, {})
	assert_true(sk.assign(0, riser), "the riser felled")
	assert_eq([a.hp, c.hp], [96, 96], "its Mine blew on its neighbours")
	assert_eq(sk.front[1], riser, "and it got back up in its slot")
	assert_true(Skirmish.mine_of(riser).is_empty(), "clean")
	# A Gel splits after the blast: the halves stand where it fell and take none of it.
	var s2 := Skirmish.new(1, 3)
	s2.add_mech(_mech("Killer", Die.single(Face.attack(200, L)), 40, 100))
	var left := _ghoul(100, 0)
	var gel := _ghoul(30, 0)
	gel.on_death = {"summon": "gel_small", "count": 2, "pair": true}
	s2.foe_factory = func(id: String) -> Foe: return Foe.make(id, 5, 0)
	s2.add_foes([left, gel])
	s2.begin()
	s2.start_round()
	s2._add_mine(gel, 4, {"keywords": ["suppress"]})
	assert_true(s2.assign(0, gel), "the gel felled")
	var half: Foe = s2.front[1]
	assert_eq(half.display_name, "gel_small", "its halves stood")
	assert_eq([half.hp, s2.twin_of(half).hp], [5, 5], "whole: the blast came first")
	assert_eq(left.hp, 96, "its neighbour took the 4")
	assert_true(s2._suppressed_through(left, s2.round), "and its stun")
	assert_false(s2._suppressed_through(half, s2.round + 1), "the halves none of it")
	# A tick's fall in the enemy's turn blows there.
	var s3 := Skirmish.new(1, 3)
	s3.add_mech(_mech("A", Die.single(Face.attack(1, L)), 40, 100))
	var p := _ghoul(100, 0)
	var burnt := _ghoul(1, 0)
	var q := _ghoul(100, 0)
	s3.add_foes([p, burnt, q])
	s3.begin()
	s3.start_round()
	Effects.stack(burnt, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	s3._add_mine(burnt, 5, {})
	s3.end_round()
	assert_false(burnt.alive(), "its Ablating felled it")
	assert_eq([p.hp, q.hp], [95, 95], "and its Mine blew on both sides")


## Several Mines due at one death check blow in strike order, front left to right, then the back,
## each once its slot is clear; a blast that fells a mined foe blows its Mine in turn.
func test_mines_blow_in_strike_order_and_a_blast_that_fells_a_mined_foe_blows_its_own() -> void:
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("Killer", Die.single(Face.attack(200, L)), 40, 100))
	var a := _ghoul(30, 0)
	var b := _ghoul(3, 0)
	var c := _ghoul(100, 0)
	var d := _ghoul(100, 0)
	sk.add_foes([a, b, c, d])
	sk.begin()
	sk.start_round()
	sk._add_mine(a, 5, {})
	sk._add_mine(b, 7, {})
	assert_true(sk.assign(0, a), "a felled")
	assert_false(b.alive(), "a's 5 fells b beside it")
	assert_eq(c.hp, 93, "and b's own 7 blows on c, the blast's chain")
	assert_eq(d.hp, 100, "d stands past the chain's reach")
	var said := sk.log.filter(func(l: String) -> bool: return l.begins_with("the Mine on"))
	assert_eq(said.size(), 2, "two blasts")
	assert_true(said[0].contains("Mine 5") and said[1].contains("Mine 7"), "a's first, then b's: %s" % str(said))


## The single big hit (Ryan, 9 November: "mines combine into one large hit with all keywords
## combined ... a way to group small weapons into armour-overcoming hits"): the numbered keywords
## add up, the rest ride once; a gated keyword rides only where its gate held on the hit; nothing
## a hit reads off its foe rides, and a rule written on a piece's own blows (ignores armour, where
## Breach rode until 15 November) stays with the piece: the blast always meets armour.
## A Mine's Chain stacks with its blast (Ryan, 21 November: Chain "should stack with spread and
## penetrate"): a conductor the blast meets takes the blast and the arc, one out of its reach the arc
## alone, and no rider of the Mine rides an arc (18 November: "take riders off chain").
func test_a_mines_chain_stacks_with_its_blast_and_carries_no_rider() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank()), 40, 100))
	var a := _ghoul(100, 0)
	var b := _ghoul(100, 0)
	var c := _ghoul(100, 0)
	var far := _archer(100, 0)
	sk.add_foes([a, b, c, far])
	sk.begin()
	sk.start_round()
	assert_true(sk.front[1] == b and sk.back[0] == far, "b mid-front, the archer behind a")
	_shock_on(a)
	_shock_on(far)
	sk._blow_mine({"damage": 3, "riders": {"chain": 2, "stacks": {"brittled": 1}, "keywords": []}}, 0, 1, false, "b")
	assert_eq(a.hp, 100 - 3 - 2, "a Shocked foe beside it takes the blast and the arc")
	assert_eq(c.hp, 100 - 3, "a plain one beside it, the blast alone")
	assert_eq(far.hp, 100 - 2, "a conductor out of its reach, the arc alone")
	assert_eq(Effects.stacks_of(far, "brittled"), 0, "and no rider rides the arc")
	assert_eq([Effects.stacks_of(a, "brittled"), Effects.stacks_of(c, "brittled")], [1, 1], "the riders on each foe the blast met")


func test_a_mines_keywords_add_up_and_its_blast_meets_armour() -> void:
	var merged := Skirmish.mine_riders_merged({"stacks": {"ablating": 2}, "keywords": ["shock"]}, {"stacks": {"ablating": 3}, "chain": 1, "keywords": ["shock", "expose"]})
	assert_eq([int(merged["stacks"]["ablating"]), int(merged["chain"])], [5, 1], "Ablating 2 and Ablating 3 are Ablating 5")
	assert_eq(merged["keywords"], ["shock", "expose"], "the flags once each, in a fixed order")
	var sk := Skirmish.new(1, 3)
	var gated := Face.attack(1, I, [K.SUPPRESS])
	gated.gates = {"suppress": {"when": "target_status", "status": "brittled"}}
	gated.consumes = "ablating"
	gated.per_consumed = 1
	var piercer := Face.attack(1, I)
	piercer.ignores_armour = true
	var bomber := _mech("Bomber", Die.of([gated, piercer]), 40, 100)
	bomber.grant_passive(MINER)
	sk.add_mech(bomber)
	sk.add_mech(_mech("Killer", Die.single(Face.attack(200, L)), 40, 100))
	var a := _ghoul(100, 0)
	var b := _ghoul(100, 0)
	var c := _ghoul(100, 0)
	sk.add_foes([a, b, c])
	sk.begin()
	sk.start_round()
	Effects.stack(b, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 4)
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, b), "the gated stun on a foe without Brittle")
	assert_eq(Skirmish.mine_of(b)["riders"]["keywords"], [], "the gate shut: no Suppress in the Mine")
	assert_eq(int(Skirmish.mine_of(b)["damage"]), 2, "and the eaten stacks stay with the hit")
	Effects.stack(b, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 1, Effects.status_decay(Effects.STATUS["brittled"]))
	sk.mechs[0].assigned = false
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, b), "again, on the Brittle")
	assert_true(Skirmish.mine_of(b)["riders"]["keywords"].has("suppress"), "the gate held: the Suppress rides")
	sk.mechs[0].assigned = false
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, b), "a gun that ignores armour")
	assert_false(Skirmish.mine_of(b)["riders"]["keywords"].has("ignores_armour"), "its rule is its own blows': no flag of it in the Mine")
	a.armour = 4
	c.armour = 50
	assert_true(sk.assign(1, b), "b felled")
	assert_eq([a.hp, c.hp], [98, 100], "the Mine of 6 meets their armour: two past four of plate, none past fifty")


## The Syrinx Drone (Ryan, 9 November: "Deals a small amount of damage and detonates a foe's
## combined mine immediately ... The small chip damage makes it add a stack first. Try without a
## cooldown first"): its chip lands, its own Mine joins the target's, then the Mine blows on the
## target and every foe round it, spent, so the target's fall blows nothing more; a Shock doubles
## the chip, never the Mine.
func test_the_drone_adds_its_mine_then_detonates_it_on_the_target_and_round_it() -> void:
	var drone := Face.attack(1, I)
	drone.detonates = true
	assert_true(drone.has_unique_rule() and drone.describe().contains("detonates its Mine"), "the entry prints its rule")
	var sk := Skirmish.new(1, 3)
	var bomber := _mech("Bomber", Die.single(drone), 40, 100)
	bomber.grant_passive(MINER)
	sk.add_mech(bomber)
	var a := _ghoul(100, 0)
	var b := _ghoul(100, 0)
	var c := _ghoul(100, 0)
	sk.add_foes([a, b, c])
	sk.begin()
	sk.start_round()
	sk._add_mine(b, 4, {"stacks": {"ablating": 1}})
	_shock_on(b)
	assert_true(sk.assign(0, b), "the drone at b")
	assert_eq(b.hp, 100 - 2 - 6, "the chip doubled on the Shock, then the Mine of 4 and its own 2")
	assert_eq([a.hp, c.hp], [94, 94], "the Mine on both neighbours")
	assert_eq(Effects.stacks_of(a, "ablating"), 1, "its Ablate rides the blast")
	assert_true(Skirmish.mine_of(b).is_empty(), "spent")
	assert_eq(cooldown_rounds_of(sk, 0), 0, "no cooldown: it may go again whenever it shows")
	# A drone that fells its target blows the Mine once, before the death check.
	var s2 := Skirmish.new(1, 3)
	var b2 := _mech("Bomber", Die.single(drone), 40, 100)
	b2.grant_passive(MINER)
	s2.add_mech(b2)
	var p := _ghoul(100, 0)
	var frail := _ghoul(1, 0)
	var q := _ghoul(100, 0)
	s2.add_foes([p, frail, q])
	s2.begin()
	s2.start_round()
	s2._add_mine(frail, 3, {})
	assert_true(s2.assign(0, frail), "the drone at a foe its chip fells")
	assert_eq([p.hp, q.hp], [95, 95], "the 5 blew once on each neighbour, never again at its fall")


func cooldown_rounds_of(sk: Skirmish, i: int) -> int:
	return sk.mechs[i].face().cooldown_rounds()


## The Lorentz Contractor (Ryan, 9 November: "moves all mines to a single target, and Exposes that
## target. The Expose rider will effectively create an AoE expose mine"): every other foe's Mine
## joins the target's, which carries the Contractor's own Mine and Expose too; a Ward on the target
## turns the gather away.
func test_the_contractor_gathers_every_mine_onto_its_target_and_exposes_it() -> void:
	var gather := Face.attack(0, I, [K.EXPOSE])
	gather.gathers_mines = true
	assert_true(gather.has_unique_rule() and gather.describe().contains("gathers every Mine onto it"), "the entry prints its rule")
	var sk := Skirmish.new(1, 3)
	var bomber := _mech("Bomber", Die.single(gather), 40, 100)
	bomber.grant_passive(MINER)
	sk.add_mech(bomber)
	sk.add_mech(_mech("Killer", Die.single(Face.attack(200, L)), 40, 100))
	var a := _ghoul(100, 0)
	var b := _ghoul(100, 0)
	var c := _ghoul(100, 0)
	var behind := _archer(100, 0)
	sk.add_foes([a, b, c, behind])
	sk.begin()
	sk.start_round()
	sk._add_mine(a, 3, {"stacks": {"ablating": 1}})
	sk._add_mine(c, 4, {"keywords": ["shock"]})
	assert_true(sk.back[0] == behind, "the archer behind a")
	assert_true(sk.assign(0, behind), "the gather at the back foe")
	var mine := Skirmish.mine_of(behind)
	assert_eq(int(mine["damage"]), 3 + 4 + 2, "both Mines and its own 2 on it")
	assert_eq(int(mine["riders"]["stacks"]["ablating"]), 1, "their Ablating")
	assert_true(mine["riders"]["keywords"].has("shock") and mine["riders"]["keywords"].has("expose"), "the Shock, and its own Expose")
	assert_true(Skirmish.mine_of(a).is_empty() and Skirmish.mine_of(c).is_empty(), "none left where they lay")
	assert_true(Effects.has(behind, "exposure"), "the target Exposed")
	assert_true(sk.targets_for(1).has(behind), "in the killer's Direct reach")
	assert_true(sk.assign(1, behind), "the killer fells it")
	assert_eq(a.hp, 91, "the 9 blows on the foe in front of it")
	assert_true(Effects.has(a, "exposure"), "an AoE Expose")
	assert_eq(b.hp, 100, "the foe beside its column untouched")
	# A Ward on the target turns the gather away: the Mines stay where they lay.
	var s2 := Skirmish.new(1, 3)
	var b2 := _mech("Bomber", Die.single(gather), 40, 100)
	s2.add_mech(b2)
	var x := _ghoul(100, 0)
	var y := _ghoul(100, 0)
	s2.add_foes([x, y])
	s2.begin()
	s2.start_round()
	s2._add_mine(x, 3, {})
	Effects.stack(y, Effects.STATUS["ward"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_NONE)
	assert_true(s2.assign(0, y), "the gather at a Warded foe")
	assert_eq(int(Skirmish.mine_of(x).get("damage", 0)), 3, "the Mine stays on x")
	assert_true(Skirmish.mine_of(y).is_empty(), "none on y")


## A Mine is a mark the team laid: a Ward turns it away, and a foe's cleanse takes it off.
func test_a_ward_turns_a_mine_away_and_a_foes_cleanse_takes_it() -> void:
	var sk := Skirmish.new(1, 3)
	var bomber := _mech("Bomber", Die.single(Face.attack(1, I)), 40, 100)
	bomber.grant_passive(MINER)
	sk.add_mech(bomber)
	var healer := _caster("cleanse", "defend", "ally_marked")
	var warded := _ghoul(100, 0)
	var marked := _ghoul(100, 0)
	sk.add_foes([healer, warded, marked])
	sk.begin()
	sk.start_round()
	Effects.stack(warded, Effects.STATUS["ward"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(0, warded), "a spend at the Warded foe")
	assert_true(Skirmish.mine_of(warded).is_empty(), "its Ward turned the Mine away")
	sk._add_mine(marked, 5, {})
	assert_eq(sk.cleanse_target(healer), marked, "the Mine is a mark: the cleanse picks it")
	assert_eq(Effects.team_marks(marked), 1, "one mark")


## A foe taken into a merge never falls (Ryan's lean of 9 November): its Mine goes in with it,
## joining the merger's, so the merger's fall blows them all.
func test_a_merge_takes_in_the_mines_of_the_foes_it_takes_in() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(1, L)), 40, 100))
	var king := Foe.make("king", 500, 0)
	var small := Foe.make("slime", 10, 0)
	small.content_id = "slime"
	sk.add_foes([king, small])
	sk.begin()
	sk.start_round()
	sk._add_mine(small, 3, {"stacks": {"ablating": 2}})
	sk._add_mine(king, 1, {})
	sk._merge(king, {"effect": "merge", "foe": ["slime"], "value": 1, "name": "Merge"})
	assert_false(small.on_field(), "the slime taken in")
	var mine := Skirmish.mine_of(king)
	assert_eq([int(mine["damage"]), int(mine["riders"]["stacks"]["ablating"])], [4, 2], "its Mine joined the king's")


## Massive foes carry Mines like any foe: a massive foe's blast meets the front-rank foes in the
## columns either side, its column being its own; a blast beside a massive foe meets it once.
func test_a_massive_foes_mine_blows_on_its_rank_neighbours_and_a_blast_meets_one_once() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("Killer", Die.single(Face.attack(900, L)), 40, 100))
	var big := Foe.make("titan", 300, 5)
	big.size = 2
	var a := _ghoul(100, 0)
	var behind := _archer(100, 0)
	sk.add_foes([big, a, behind])
	sk.begin()
	sk.start_round()
	assert_true(sk.front[0] == big and sk.back[0] == big and sk.front[1] == a and sk.back[1] == behind, "the titan fills column 0; a and its archer column 1")
	sk._add_mine(a, 3, {})
	assert_eq(sk.mine_reach(0, 1, false).filter(func(f: Foe) -> bool: return f == big).size(), 1, "the blast at a's slot meets the titan once")
	sk._add_mine(big, 7, {})
	var met := sk.mine_reach(0, 0, true)
	assert_true(met.has(a) and not met.has(behind), "the titan's blast its rank's neighbour alone")
	assert_true(sk.assign(0, big), "the titan felled")
	assert_eq(a.hp, 93, "its 7 on the foe beside it")
	assert_eq(behind.hp, 100, "never the back rank beside it")


## A Mine's Disrupt does nothing in the enemy's turn (Ryan's lean of 9 November), the foes' moves
## being under way; in the player's turn it turns the foes its blast meets.
func test_a_mines_disrupt_turns_its_foes_in_the_players_turn_and_never_in_the_enemys() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("Killer", Die.single(Face.attack(200, L)), 40, 500))
	var a := _ghoul(100, 1)
	a.actions = [{"id": "jab", "name": "Jab", "kind": "attack", "weight": 1, "text": ""}, {"id": "swing", "name": "Swing", "kind": "attack", "factor": 2, "weight": 1, "text": ""}]
	var b := _ghoul(10, 0)
	sk.add_foes([a, b])
	sk.begin()
	sk.start_round()
	var before := str(a.action.get("id", ""))
	sk._add_mine(b, 1, {"keywords": ["disrupt"]})
	assert_true(sk.assign(0, b), "b felled in the player's turn")
	assert_true(str(a.action.get("id", "")) != before, "its Disrupt turned a's move")
	var s2 := Skirmish.new(1, 3)
	s2.add_mech(_mech("A", Die.single(Face.attack(1, L)), 40, 500))
	var x := _ghoul(100, 1)
	x.actions = a.actions.duplicate(true)
	var burnt := _ghoul(1, 0)
	s2.add_foes([burnt, x])
	s2.begin()
	s2.start_round()
	Effects.stack(burnt, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	s2._add_mine(burnt, 1, {"keywords": ["disrupt"]})
	var picked := str(x.action.get("id", ""))
	s2.end_round()
	assert_false(burnt.alive(), "felled by its tick in the enemy's turn")
	assert_false("\n".join(s2.log).contains("is disrupted"), "and its Disrupt did nothing")


## A Mine survives a save's round trip with its riders, and the round preview's copy shares
## nothing with the fight: a merge on the copy leaves the fight's Mine as it was.
func test_a_mine_survives_the_save_and_the_preview_leaves_it_alone() -> void:
	var sk := Skirmish.new(1, 3)
	var bomber := _mech("Bomber", Die.single(Face.attack(1, I, [K.SHOCK])), 40, 100)
	bomber.grant_passive(MINER)
	sk.add_mech(bomber)
	var a := _ghoul(100, 0)
	var b := _ghoul(100, 0)
	sk.add_foes([a, b])
	sk.begin()
	sk.start_round()
	sk._add_mine(a, 3, {"stacks": {"ablating": 2}})
	var c := SaveGame.clone_skirmish(sk)
	var ca: Foe = c.front[0]
	assert_eq(JSON.stringify(Skirmish.mine_of(ca)), JSON.stringify(Skirmish.mine_of(a)), "the copy's Mine as the fight's")
	c._add_mine(ca, 5, {"keywords": ["shock"]})
	var mine := Skirmish.mine_of(a)
	assert_eq([int(mine["damage"]), mine["riders"]["keywords"]], [3, []], "the fight's Mine untouched by the copy's")
	var preview := sk.preview_round(0, a)
	assert_eq(int(Skirmish.mine_of(a)["damage"]), 3, "the preview leaves it as it was")
	assert_true(preview is Dictionary, "and reads the round")


## The Needletail's two things a round (the Quick-turn Avionics Relay as Ryan settled it on 11
## November; built that day), on a synthetic passive: after its first spend of a weapon or of
## equipment its die turns to a lit entry of the other kind and the machine acts again, once a
## round. One entry to turn to is no draw, so the die shows it and the undo reaches past it;
## several are a draw among them; a dark entry is none; a spend Rapid of its own keeps the turn
## for the next; with nothing of the other kind there is no second action; the next round opens
## it again, and the bot weighs the action the turn gives.
## Ricochet (the Skua's rewrite), on synthetic passives. Ryan, 12 November: "After firing a weapon,
## it hits the primary target 1 more time per stack, dealing 1 damage each time and applying all
## effects other than area keywords"; 11 November: "Lose half stacks of Ricochet on any hull
## damage".
const SKIP_FIRE := {"id": "skip_fire", "name": "Skip fire", "description": "", "effects": [
	{"trigger": "on_damage", "effect": "stack_status", "value": "ricochet", "once": "round"}]}


func _ricochet(u: Unit, n: int) -> void:
	Effects.stack(u, Effects.STATUS["ricochet"], Effects.SKIRMISH, "test", n, Effects.DECAY_NONE)


func test_ricochet_strikes_again_for_one_a_stack_after_each_shot() -> void:
	var gun := Face.attack(5, L)
	var twin := Face.attack(3, L)
	twin.strikes = 2
	var probe := Face.attack(0, I, [K.EXPOSE])
	var sk := Skirmish.new(1, 3)
	var m := _mech("Skua", Die.of([gun, twin, probe]), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(100, 0), _ghoul(100, 0), _ghoul(100, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var a: Foe = sk.front[0]
	_ricochet(m, 3)
	ms.face_index = 0
	assert_true(sk.assign(0, a), "a gun of 5 on three stacks")
	assert_eq(a.hp, 92, "its 5, then three strikes of 1")
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_eq(bot.damage_outcomes(ms, gun, sk.front[1]), [[8.0, 1.0]], "the bot counts them")
	var kinds: Array = []
	for b in sk.spend_blows:
		kinds.append(str(b["kind"]))
	assert_eq(kinds, ["strike", "ricochet", "ricochet", "ricochet"], "each a blow of its own for the screen, in order")
	var places: Array = []
	for b in sk.spend_blows:
		places.append(int(b["strike"]))
	assert_eq(places, [0, 1, 2, 3], "each on its own place in the spend")
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(m, "ricochet"), 3, "the stacks last the fight: no round takes one")
	ms.face_index = 1
	assert_true(sk.assign(0, a), "a gun of two strikes")
	assert_eq(a.hp, 83, "its two strikes of 3, then the three once: a multi-hit's come after it, never a strike")
	sk.end_round()
	sk.start_round()
	ms.face_index = 2
	assert_true(sk.assign(0, a), "equipment aimed at a foe")
	assert_eq(a.hp, 83, "is no weapon: nothing strikes again")
	assert_eq(sk.spend_blows.filter(func(b): return str(b["kind"]) == "ricochet").size(), 0, "and no blow of one is told")


func test_a_ricochet_is_a_strike_through_the_whole_blow() -> void:
	var gun := Face.attack(5, L)
	var burner := Face.attack(3, L, [K.ABLATE])
	burner.ablate = 1
	var spread := Face.attack(4, L, [K.CLEAVE])
	spread.cleave = 2
	var sk := Skirmish.new(1, 3)
	var m := _mech("Skua", Die.of([gun, burner, spread]), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(100, 0), _ghoul(100, 0), _ghoul(100, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var a: Foe = sk.front[0]
	var b: Foe = sk.front[1]
	var c: Foe = sk.front[2]
	_ricochet(m, 3)
	# Armour comes off each: a point of plate stops every one of them.
	a.armour = 1
	ms.face_index = 0
	assert_true(sk.assign(0, a), "the gun on a plated foe")
	assert_eq(a.hp, 96, "its 5 less the plate, and three strikes of 1 the plate takes whole")
	sk.end_round()
	sk.start_round()
	# A flat buff adds to each, as to any strike.
	Effects.grant_buff(m, "overcharged", 1, "test", sk.round)
	ms.face_index = 0
	assert_true(sk.assign(0, a), "Empowered by one")
	assert_eq(a.hp, 88, "its 6 less the plate, and three strikes of 2 less the plate")
	sk.end_round()
	sk.start_round()
	# The weapon's riders ride each strike.
	a.armour = 0
	ms.face_index = 1
	assert_true(sk.assign(0, b), "an Ablate 1 gun")
	assert_eq(Effects.stacks_of(b, "ablating"), 4, "a stack for its strike and one for each Ricochet")
	sk.end_round()
	sk.start_round()
	# An area is the shot's, never the Ricochet's.
	var c_before := c.hp
	var a_before := a.hp
	ms.face_index = 2
	assert_true(sk.assign(0, b), "a Spread gun between two foes")
	assert_eq([a_before - a.hp, c_before - c.hp], [2, 2], "each neighbour its Spread 2 once: the Ricochets strike the aimed foe alone")


func test_hull_damage_halves_ricochet_and_a_shield_keeps_it() -> void:
	var gun := Face.attack(5, L)
	var sk := Skirmish.new(1, 1)
	var m := _mech("Skua", Die.single(gun), 4, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(300, 4)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	_ricochet(m, 5)
	sk.end_round()
	assert_eq(m.shield, 0, "the blow of 4 lands on its shield of 4")
	assert_eq(Effects.stacks_of(m, "ricochet"), 5, "nothing on the hull: the stacks stand")
	sk.start_round()
	m.shield = 0
	sk.end_round()
	assert_true(m.hull < 100, "the next reaches the hull")
	assert_eq(Effects.stacks_of(m, "ricochet"), 2, "and half the stacks go, rounded down")
	sk.start_round()
	m.shield = 0
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "ricochet"), 1, "half again at the next")
	sk.start_round()
	m.shield = 0
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "ricochet"), 0, "and a lone stack is lost")
	# An overheat is hull damage like any other.
	sk.start_round()
	m.shield = 40
	_ricochet(m, 4)
	ms.heat = ms.heat_max + 3
	sk._burn_overheated()   # the burn alone: the overheat also breaks the shield, and the blow after it would halve them again
	assert_eq(Effects.stacks_of(m, "ricochet"), 2, "its own heat burning hull halves them too")
	# A stack is a stack: a Purge takes one.
	Effects.purge(m, 1)
	assert_eq(Effects.stacks_of(m, "ricochet"), 1, "a buff a Purge lowers")


func test_damaging_a_foe_earns_a_stack_once_a_round_after_the_spend() -> void:
	var quick := Face.attack(5, L, [K.RAPID])
	var gun := Face.attack(5, L)
	var probe := Face.attack(0, I, [K.EXPOSE])
	var sk := Skirmish.new(1, 2)
	var m := _mech("Skua", Die.of([quick, gun]), 40, 100)
	m.grant_passive(SKIP_FIRE)
	sk.add_mech(m)
	var other := _mech("Wing", Die.single(probe), 40, 100)
	other.id = 1
	other.grant_passive(SKIP_FIRE)
	sk.add_mech(other)
	sk.add_foes([_ghoul(100, 0), _ghoul(100, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var a: Foe = sk.front[0]
	var plated: Foe = sk.front[1]
	plated.armour = 9
	ms.face_index = 0
	assert_true(sk.assign(0, a), "its first weapon to damage a foe this round")
	assert_eq(a.hp, 95, "strikes for its 5 alone: the stack lands after the spend that earned it")
	assert_eq(Effects.stacks_of(m, "ricochet"), 1, "and earns a stack")
	assert_false(ms.assigned, "Rapid: it acts again")
	assert_true(sk.assign(0, a), "its second spend of the round")
	assert_eq(a.hp, 89, "ricochets off the stack: 5 and 1")
	assert_eq(Effects.stacks_of(m, "ricochet"), 1, "and earns no second: once a round")
	assert_false(Effects.describe(m).any(func(d): return str(d[5]).begins_with("once:")), "the gate's mark is the engine's own, never described")
	assert_true(sk.assign(1, a), "equipment aimed at a foe")
	assert_eq(Effects.stacks_of(other, "ricochet"), 0, "damages nothing and earns nothing")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, plated), "a blow its armour takes whole")
	assert_eq(plated.hp, 100, "damaged nothing")
	assert_eq(Effects.stacks_of(m, "ricochet"), 1, "so it earns nothing")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, a), "the next round's first")
	assert_eq(Effects.stacks_of(m, "ricochet"), 2, "earns the next stack")


func test_a_buff_grants_ricochet_for_the_fight() -> void:
	var swoop := Face.buff("ricochet", 1)
	swoop.add_keyword(K.RAPID)
	swoop.cooldown = 1
	var gun := Face.attack(5, L)
	var sk := Skirmish.new(1, 1)
	var m := _mech("Skua", Die.of([swoop, gun]), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(100, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var a: Foe = sk.front[0]
	ms.face_index = 0
	assert_true(sk.assign(0, ms), "the swoop, spent on itself")
	assert_eq(Effects.stacks_of(m, "ricochet"), 1, "a stack")
	assert_false(ms.assigned, "Rapid: its die rolls again")
	assert_eq(ms.face_index, 1, "onto its gun, the swoop dark for the round")
	assert_true(sk.assign(0, a), "the gun, the same round")
	assert_eq(a.hp, 94, "ricochets off it: 5 and 1")
	sk.end_round()
	sk.start_round()
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(m, "ricochet"), 1, "no rounds run out on it: it lasts the fight")


const RELAY := {"id": "relay", "name": "Relay", "description": "", "effects": [{"trigger": "static", "effect": "one_of_each"}]}


func test_a_one_of_each_die_turns_to_the_other_kind_once_a_round() -> void:
	var probe := Face.attack(0, I, [K.EXPOSE])
	var gun := Face.attack(10, L)
	var sk := Skirmish.new(1, 2)
	sk.keeps_undo = true
	var m := _mech("Spotter", Die.of([probe, gun, Face.attack(5, L)]), 40, 100)
	m.grant_passive(RELAY)
	sk.add_mech(m)
	sk.add_foes([_ghoul(300, 0), _ghoul(300, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	# A weapon first: one equipment to turn to, so no draw.
	ms.face_index = 1
	assert_eq(sk.turn_index(ms), 0, "the die knows where it turns: its one equipment")
	assert_true(sk.turn_face(ms).has(K.EXPOSE), "and shows that entry")
	var before := sk.rng.state
	assert_true(sk.assign(0, sk.front[0]), "the gun spent")
	assert_false(ms.assigned, "the machine acts again")
	assert_eq(ms.face_index, 0, "its die turned to the equipment")
	assert_eq(sk.rng.state, before, "one entry to turn to is no draw")
	assert_true("\n".join(sk.log).contains("a quick turn"), "the log says so")
	assert_eq(sk.turn_index(ms), -1, "its second action is the one it holds: nothing more to turn to")
	assert_true(sk.undo(), "with no draw the undo reaches past the turn")
	ms = sk.mechs[0]   # the undo writes the fight back: its units are read again
	m = ms.unit
	assert_true(ms.face_index == 1 and not ms.assigned and not Effects.is_entry_disabled(m, 1), "the gun showing again, lit: nothing sent onto cooldown")
	assert_true(sk.assign(0, sk.front[0]), "spent again")
	assert_true(sk.assign(0, sk.front[0]), "then the equipment")
	assert_true(ms.assigned, "a full action: once a round")
	sk.end_round()
	sk.start_round()
	# Equipment first: two guns to turn to, a draw among them.
	ms.face_index = 0
	assert_eq(sk.turn_entries(ms, ms.face()), [1, 2] as Array[int], "its two guns")
	assert_eq(sk.turn_index(ms), -1, "a draw among several is never promised")
	before = sk.rng.state
	assert_true(sk.assign(0, sk.front[0]), "the equipment first this round")
	assert_false(ms.assigned, "it acts again")
	assert_true(ms.face_index == 1 or ms.face_index == 2, "on one of its guns")
	assert_true(sk.rng.state != before, "a draw among several")
	assert_false(sk.can_undo(), "and a draw is the undo's floor")
	sk.end_round()
	sk.start_round()
	# A dark entry is none to turn to; with nothing of the other kind there is no second action.
	Effects.disable_entry(m, 0, "foe:x", sk.round)
	ms.face_index = 1
	assert_true(sk.turn_entries(ms, ms.face()).is_empty(), "its one equipment dark: nothing to turn to")
	assert_true(sk.assign(0, sk.front[0]), "the gun")
	assert_true(ms.assigned, "a full action")
	# A piece Rapid of its own keeps the turn for the next spend.
	var s2 := Skirmish.new(1, 2)
	var own := Face.attack(0, I, [K.RAPID, K.SHOCK])
	own.heat = 5
	var n := _mech("Spotter", Die.of([own, gun.duplicate_face()]), 40, 100)
	n.grant_passive(RELAY)
	s2.add_mech(n)
	s2.add_foes([_ghoul(300, 0)])
	s2.begin()
	s2.start_round()
	var ns: Skirmish.MechState = s2.mechs[0]
	ns.face_index = 0
	assert_true(s2.assign(0, s2.front[0]), "its own Rapid")
	assert_true(not ns.assigned and not Effects.is_entry_disabled(n, 1), "acts again by Rapid, nothing but itself onto cooldown (Ryan, 18 November: \"rapid does not consume any of the spends\")")
	var bot := Policy.make(Policy.GREEDY, 1)
	ns.face_index = 1
	for held in n.modifiers.duplicate():
		if held.source == "cooldown":
			n.modifiers.erase(held)   # its entries lit again, for the read
	var open := bot.attack_score(s2, ns, ns.face(), s2.front[0])
	Effects.disable_entry(n, 0, "cooldown", s2.round)   # its equipment spent and on cooldown: the gun's spend has no flip to give
	assert_true(open > bot.attack_score(s2, ns, ns.face(), s2.front[0]), "the bot weighs the action the turn gives")
	# A machine without the rule turns nothing.
	var plain := _mech("Plain", Die.of([probe.duplicate_face(), gun.duplicate_face()]), 40, 100)
	var s3 := Skirmish.new(1, 2)
	s3.add_mech(plain)
	s3.add_foes([_ghoul(300, 0)])
	s3.begin()
	s3.start_round()
	s3.mechs[0].face_index = 1
	assert_true(s3.turn_entries(s3.mechs[0], s3.mechs[0].face()).is_empty(), "no rule, no turn")


## The Swallowtail's Muster (Ryan's go, 21 October; built that day), on a synthetic passive at
## small numbers: every die's roll, any machine's, fills it a point, a kill by its own guns more,
## a charge every so many, up to its cap; with a charge up the entry goes out in its charged
## form unasked (Ryan, 22 October: never primed), the Flare's Suppress on top of its Expose, and
## the charge goes with it; without one, the plain form.
const MUSTER := {"id": "deck", "name": "Deck", "description": "", "effects": [{"trigger": "static", "effect": "muster", "value": 3, "cap": 2, "kill": 2}]}


func test_the_muster_fills_on_every_roll_and_a_kill_and_buys_a_charged_form() -> void:
	var flare := Face.attack(0, I, [K.EXPOSE])
	flare.charged = {"muster": 1, "keywords": ["suppress"]}
	assert_true(flare.has_unique_rule() and flare.describe().contains("a muster: indirect expose suppress"), "the entry prints both forms")
	var sk := Skirmish.new(1, 2)
	var m := _mech("Carrier", Die.of([flare, Face.attack(10, L)]), 40, 100)
	m.grant_passive(MUSTER)
	sk.add_mech(m)
	sk.add_mech(_mech("Ally", Die.single(Face.attack(10, L)), 40, 100))
	var foe := _ghoul(300, 10)
	sk.add_foes([foe, _ghoul(10, 0)])
	sk.begin()
	var late := _ghoul(10, 0)
	sk.reinforcements.append(late)
	sk.start_round()
	assert_eq(Effects.stacks_of(m, "muster"), 2, "both dice rolled: a point each")
	assert_eq(Effects.muster_charges(m), 0, "no charge yet")
	sk.mechs[0].face_index = 0
	assert_eq(sk.spend_face(sk.mechs[0]), flare, "no charge: the plain Flare")
	assert_true(sk.reroll([1]), "a reroll of the ally's die")
	assert_eq(Effects.muster_charges(m), 1, "a third point: a charge")
	assert_true(sk.charge_lands(sk.mechs[0]), "the Flare goes out charged, unasked")
	assert_true(sk.spend_face(sk.mechs[0]).has(K.SUPPRESS), "and the die shows the charged form")
	assert_true(sk.assign(0, foe), "spent")
	assert_true(Effects.has(foe, "exposure") and Effects.has(foe, "suppressed"), "the charged form: Exposed and Suppressed")
	assert_eq(Effects.stacks_of(m, "muster"), 0, "the charge spent")
	assert_true("\n".join(sk.log).contains("spends a muster"), "the log says so")
	var weak: Foe = null
	for f in sk.field_foes():
		if f.hp == 10:
			weak = f
	sk.mechs[1].face_index = 0
	assert_true(sk.assign(1, weak), "the ally's kill")
	assert_eq(Effects.stacks_of(m, "muster"), 0, "another machine's kill fills nothing")
	sk.end_round()
	sk._first_deployment(true)   # the late foe stepped in by hand: nothing steps in on its own since the cut (6 November)
	sk.start_round()
	assert_eq(Effects.stacks_of(m, "muster"), 2, "the next round's two rolls")
	sk.mechs[0].face_index = 1
	assert_true(sk.assign(0, late), "its own gun's kill")
	assert_eq(Effects.stacks_of(m, "muster"), 4, "a kill by its own guns: two points more")
	for i in range(6):
		sk._rolled()
	assert_eq(Effects.stacks_of(m, "muster"), 6, "capped at two charges")


## The Swallowtail's locked pieces (21 October), synthetic: the team shield reaches every ally,
## never its spender; charged, the wait for Phased lands on every ally, only while none has acted
## this round (the piece's own filter; Ryan, 22 October: never a selective protection). Phased is
## granted as the round ends (15 November): they keep their dice and stand through the enemy's
## turn as any machine, and as it ends they are Phased through the next round, where no foe
## picks them, no blow reaches them, no ally may spend on them, and they act. Once any ally has
## acted the charged form has nowhere to land: the plain shield goes out and the charge waits.
func test_the_team_shield_reaches_every_ally_and_its_charge_phases_them_as_the_round_ends() -> void:
	var screens := Face.shield(10)
	screens.targets = Face.Target.ALLY
	screens.reaches_all = true
	screens.charged = {"muster": 1, "status": "phased", "reaches_all": true, "not_acted": true}
	var sk := Skirmish.new(1, 2)
	var c := _mech("Carrier", Die.single(screens), 40, 100)
	c.grant_passive(MUSTER)
	sk.add_mech(c)
	var a := _mech("A", Die.single(Face.attack(10, L)), 10, 100)
	a.shield_max = 40
	var b := _mech("B", Die.single(Face.attack(10, L)), 10, 100)
	b.shield_max = 40
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(300, 20), _ghoul(300, 20)])
	sk.begin()
	sk.start_round()
	Effects.remove(c, "muster")   # the three dice's rolls made a charge; this round's shield is plain
	assert_true(sk.assign(0, sk.mechs[1]), "the team shield, dropped on one ally")
	assert_eq([a.shield, b.shield, c.shield], [20, 20, 40], "every ally shielded, never its spender")
	sk.end_round()
	sk.start_round()
	Effects.remove(c, "muster")
	Effects.stack(c, Effects.STATUS["muster"], Effects.SKIRMISH, "test", 3, Effects.DECAY_NONE)
	for f in sk.field_foes():
		f.target = sk.mechs[1]   # every foe's pick on A
	assert_true(sk.charge_lands(sk.mechs[0]), "a charge up and no ally has acted: it goes out charged")
	assert_true(sk.assign(0, sk.mechs[1]), "charged: Phased queued on every ally")
	assert_true(Effects.has(a, "phasing") and Effects.has(b, "phasing"), "A and B both wait for it")
	assert_false(Effects.has(a, "phased") or Skirmish.is_out(sk.mechs[1]), "neither is Phased yet")
	assert_false(sk.mechs[1].assigned or sk.mechs[2].assigned, "they keep their dice: no action is its price")
	for f in sk.field_foes():
		assert_eq(f.target, sk.mechs[1], "the foes' picks stand: it is in the fight this round")
	var hull := a.hull + a.shield
	sk.end_round()
	assert_eq(a.hull + a.shield, hull - 40, "the round it is queued in, the blows land")
	assert_true(Effects.has(a, "phased") and Effects.has(b, "phased") and not Effects.has(a, "phasing"), "as the round ends, both are Phased")
	assert_true("\n".join(sk.log).contains("A is Phased: out of reach until the next round's end"), "the log says so")
	sk.start_round()
	assert_true(Skirmish.is_out(sk.mechs[1]) and Skirmish.is_out(sk.mechs[2]), "through the next round")
	for f in sk.field_foes():
		assert_eq(f.target, sk.mechs[0], "no foe picks a Phased machine: the Carrier alone may be picked")
	assert_false(sk.machine_targets_for(sk.mechs[0], screens).has(sk.mechs[1]), "no ally may spend on it")
	assert_true(sk.can_spend(1), "and it acts")
	var foe_hp: int = sk.front[0].hp
	assert_true(sk.assign(1, sk.front[0]), "its gun fires")
	assert_eq(sk.front[0].hp, foe_hp - 10, "and lands")
	var held := a.hull + a.shield
	sk.end_round()
	assert_eq(a.hull + a.shield, held, "nothing reaches it in the enemy's turn")
	sk.start_round()
	assert_false(Effects.has(a, "phased") or Effects.has(b, "phased"), "gone at that round's end")
	# One ally acted first: never a selective protection, so the plain shield, the charge kept.
	Effects.remove(c, "muster")
	Effects.stack(c, Effects.STATUS["muster"], Effects.SKIRMISH, "test", 3, Effects.DECAY_NONE)
	assert_true(sk.assign(2, sk.front[0]), "B acts first")
	assert_false(sk.charge_lands(sk.mechs[0]), "an ally has acted: no charged form")
	var shields := [a.shield, b.shield]
	assert_true(sk.assign(0, sk.mechs[1]), "the Screens")
	assert_true(sk.mechs[1].shield_broken, "A's shield broke under the blows it stood through while it waited")
	assert_eq([a.shield, b.shield], [0, mini(40, int(shields[1]) + 10)], "the plain team shield on B, and none on a broken one")
	assert_false(Effects.has(a, "phasing"), "and A, yet to act, waits for no Phased")
	assert_eq(Effects.muster_charges(c), 1, "the charge waits")


## Phased (Ryan's mark and answer, 15 November: "Cannot be damaged or targeted by anything until
## the end of this round"; "all sources of Phased should say "at the end of this round, grant
## Phased""; "you have to survive the current round"): a source lays the wait for it, on a
## machine that has acted or not; a machine wrecked before the round ends never phases, and a
## foe's Purge takes the wait as it takes any buff. A Phased machine may spend on itself, a
## second grant carrying it through the round after, and its Lure turns no pick, since nothing
## may target it.
func test_phased_waits_for_the_rounds_end_and_a_wrecked_or_purged_machine_never_phases() -> void:
	var veil := Face.buff("phased")
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(veil), 0, 100)
	var doomed := _mech("D", Die.single(veil.duplicate_face()), 0, 5)
	sk.add_mech(a)
	sk.add_mech(doomed)
	var g := _ghoul(300, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	g.target = sk.mechs[1]
	assert_true(sk.assign(0, null) and sk.assign(1, null), "each queues Phased on itself")
	assert_true(Effects.has(a, "phasing") and Effects.has(doomed, "phasing"), "both wait for it")
	assert_false(Skirmish.is_out(sk.mechs[0]), "and neither is out of reach yet")
	sk.end_round()
	assert_false(sk.mechs[1].alive(), "the blow wrecks D first")
	assert_false(Effects.has(doomed, "phased"), "a machine wrecked before the round ends never phases")
	assert_true(Effects.has(a, "phased") and not Effects.has(a, "phasing"), "A, standing, does")
	sk.start_round()
	assert_true(sk.targetable_mechs().is_empty() and g.target == null, "nothing may target it, and no foe picks it")
	assert_true(sk.machine_targets_for(sk.mechs[0], sk.mechs[0].face()).has(sk.mechs[0]), "it may spend on itself")
	assert_true(sk.assign(0, null), "and does: Phased queued again")
	sk.end_round()
	assert_eq(a.hull, 100, "the blow of a foe with nothing to strike is lost")
	sk.start_round()
	assert_true(Skirmish.is_phased(sk.mechs[0]), "the second grant carries it through the round after")
	sk.end_round()
	sk.start_round()
	assert_false(Skirmish.is_phased(sk.mechs[0]), "and without a third it is back in reach")
	# A foe's Purge takes the wait: it is a buff a die entry bought.
	var s2 := Skirmish.new(2, 2)
	var u := _mech("U", Die.single(Face.attack(1, L)), 0, 100)
	s2.add_mech(u)
	s2.add_foes([_purger()])
	s2.begin()
	Effects.stack(u, Effects.STATUS["phasing"], Effects.SKIRMISH, "buff", 1, Effects.DECAY_NONE)
	s2.start_round()
	s2.end_round()
	assert_false(Effects.has(u, "phasing") or Effects.has(u, "phased"), "purged before the round ends, it never phases")
	# A Phased machine's Lure turns no pick.
	var s3 := Skirmish.new(3, 2)
	var lurer := _mech("L", Die.single(Face.attack(0, I, [K.LURE])), 0, 100)
	var bait := _mech("B", Die.single(Face.blank()), 0, 100)
	s3.add_mech(lurer)
	s3.add_mech(bait)
	var hunter := _ghoul(300, 10)
	s3.add_foes([hunter])
	s3.begin()
	s3.start_round()
	Effects.grant_for_rounds(lurer, Effects.STATUS["phased"], "test", s3.round)
	hunter.target = s3.mechs[1]
	assert_true(s3.assign(0, hunter), "the lure spent")
	assert_eq(hunter.target, s3.mechs[1], "the foe keeps its pick: nothing may target a Phased machine")
	assert_true("\n".join(s3.log).contains("L lures nothing"), "and the log says so")


## The Phased trial at once (Ryan, 20 November: "Set the debug toggle for phased"; the TRIALS
## page's PHASED, Skirmish.phase_at_once): a machine's Phased lands as its entry is spent, out of
## reach until the round ends, and the foe whose pick it was draws again; off, it waits for the
## round's end as built.
func test_phased_at_once_lands_as_it_is_spent_and_the_foes_pick_again() -> void:
	var veil := Face.buff("phased")
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(veil), 0, 100)
	var b := _mech("B", Die.single(Face.blank()), 0, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var g := _ghoul(300, 10)
	sk.add_foes([g])
	sk.begin()
	Skirmish.phase_at_once = true
	sk.start_round()
	g.target = sk.mechs[0]
	assert_true(sk.assign(0, null), "A spends its Phase on itself")
	Skirmish.phase_at_once = false   # the switch is read as the entry is spent; the rest of the test runs the game's own
	assert_true(Skirmish.is_phased(sk.mechs[0]) and not Effects.has(a, "phasing"), "Phased at once, with no wait")
	assert_eq(g.target, sk.mechs[1], "the foe that picked it picks again, the next machine in line")
	sk.end_round()
	assert_eq(a.hull, 100, "nothing reaches A in the foes' turn")
	assert_true(b.hull < 100, "the blow lands on B")
	sk.start_round()
	assert_false(Skirmish.is_phased(sk.mechs[0]), "and it is back in reach as the next round opens")
	# Off, the game's own: the wait, then Phased as the round ends.
	var s2 := Skirmish.new(2, 2)
	var c := _mech("C", Die.single(veil.duplicate_face()), 0, 100)
	s2.add_mech(c)
	s2.add_foes([_ghoul(300, 10)])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, null), "C spends its Phase")
	assert_true(Effects.has(c, "phasing") and not Skirmish.is_phased(s2.mechs[0]), "the wait, and no Phased yet")


## The Sutler's Hoist and the Reveille Horn (21 October), synthetic: the Hoist cools an ally and
## shields it, the shield sized on the heat its cooling leaves; charged, the full reset (the
## shield to its maximum, the heat to nothing, a cleanse). The Horn gives the team a reroll more
## this round; charged, an ally whose die is spent rolls again and acts again.
func test_the_hoist_resets_an_ally_and_the_horn_rallies_or_gives_an_ally_its_turn_again() -> void:
	var hoist := Face.shield(15)
	hoist.targets = Face.Target.ALLY
	hoist.vents = 10
	hoist.charged = {"muster": 1, "shield": "full", "vents": "all", "cleanse": true}
	var horn := Face.from_dict({"kind": "buff", "team_rerolls": 1, "targets": "self", "charged": {"muster": 1, "act_again": "ally"}})
	assert_true(horn.describe().contains("the team gains a reroll") and horn.has_unique_rule(), "the Horn's rule is its own text: %s" % horn.describe())
	assert_false(horn.charged_form().rule_phrases().has("the team gains a reroll"), "and its charged form is the act-again alone")
	var sk := Skirmish.new(1, 2)
	var c := _mech("Carrier", Die.of([hoist, horn]), 40, 100)
	c.grant_passive(MUSTER)
	sk.add_mech(c)
	var a := _mech("A", Die.single(Face.attack(10, L)), 10, 100)
	a.shield_max = 60
	sk.add_mech(a)
	sk.add_foes([_ghoul(300, 0), _ghoul(300, 0)])
	sk.begin()
	sk.start_round()
	sk.mechs[1].heat = 30
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.mechs[1]), "the plain Hoist on the ally")
	assert_eq([sk.mechs[1].heat, a.shield], [20, 25], "cooled 10, then shielded 15")
	sk.end_round()
	sk.start_round()
	Effects.stack(c, Effects.STATUS["muster"], Effects.SKIRMISH, "test", 6, Effects.DECAY_NONE)
	sk.mechs[1].heat = 30
	Effects.stack(a, Effects.STATUS["scorched"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.mechs[1]), "the Hoist, a charge up: charged")
	assert_eq([sk.mechs[1].heat, a.shield], [0, 60], "the full reset: no heat, the shield full")
	assert_false(Effects.has(a, "scorched"), "and cleansed")
	sk.end_round()
	sk.start_round()
	var before := sk.rerolls_left
	sk.mechs[0].face_index = 1
	var charges := Effects.muster_charges(c)
	assert_false(sk.charge_lands(sk.mechs[0]), "a charge up, but no ally has spent its die")
	assert_true(sk.assign(0, null), "the plain Horn")
	assert_eq(Effects.muster_charges(c), charges, "the charge waits")
	assert_eq(sk.rerolls_left, before + 1, "the team has a reroll more, past the round's two")
	assert_true(c.modifiers.filter(func(mod) -> bool: return mod.scope == Effects.ROUNDS).is_empty(), "and no buff stands for it: the reroll is the whole effect")
	assert_true("\n".join(sk.log).contains("the team gains a reroll"), "the log says so")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(1, sk.front[0]), "the ally acts")
	sk.mechs[0].face_index = 1
	assert_false(sk.machine_targets_for(sk.mechs[0], horn.charged_form()).has(sk.mechs[0]), "never itself")
	assert_true(sk.charge_lands(sk.mechs[0]), "an ally spent: the Horn goes out charged")
	assert_true(sk.assign(0, sk.mechs[1]), "the Horn charged, on the spent ally")
	assert_false(sk.mechs[1].assigned, "its die rolls again and it acts again")
	assert_true(sk.assign(1, sk.front[0]), "the second action")


## The Horn's charged form rolls by the reroll rule (Ryan, 8 November: "It's a roll, it should
## follow roll rules, like everything that rolls"): the ally's die lands on any other entry, never
## the one it spent, as Rapid's, the Booster's and the Uplink's do.
## A reroll a piece grants is the whole of its effect (Ryan, 15 November: "This doesn't need to
## be a temporary buff or a keyword"; and of the round's two, "allow it"): the team has it at
## once, past the round's count and with none left alike, no status stands for it, and the round's
## preview says how many the die in hand would bring so the REROLL button can light.
func test_a_granted_reroll_lands_at_once_and_the_preview_counts_it() -> void:
	var horn := Face.from_dict({"kind": "buff", "team_rerolls": 1, "targets": "self"})
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("Carrier", Die.of([horn, Face.attack(10, L)]), 40, 100))
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 10, 100))
	sk.add_foes([_ghoul(300, 0), _ghoul(300, 0)])
	sk.begin()
	sk.start_round()
	var c: Skirmish.MechState = sk.mechs[0]
	c.face_index = 0
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "the round's count to start")
	assert_eq(int(sk.preview_round(0, c)["rerolls"]), 1, "the die in hand would bring one")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "and the preview spends and grants nothing")
	assert_eq(int(sk.preview_round()["rerolls"]), 0, "no die in hand: none coming")
	assert_eq(int(sk.preview_round(1, sk.front[0])["rerolls"]), 0, "a plain gun in hand: none")
	assert_true(sk.assign(0, c), "the Horn sounds")
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND + 1, "past the round's count")
	assert_false(Effects.has(c.unit, "rallied"), "no status stands for it")
	sk.end_round()
	sk.start_round()
	assert_eq(sk.rerolls_left, Skirmish.REROLLS_PER_ROUND, "and it never banks: the next round has its own")
	sk.rerolls_left = 0
	c.face_index = 0
	assert_eq(int(sk.preview_round(0, c)["rerolls"]), 1, "with none left it would bring one all the same")
	assert_true(sk.assign(0, c), "the Horn again")
	assert_eq(sk.rerolls_left, 1, "none left: one in hand")
	var two := Face.from_dict({"kind": "buff", "team_rerolls": 2, "targets": "self"})
	assert_true(two.describe().contains("the team gains 2 rerolls"), "a piece that grants two says so: %s" % two.describe())
	assert_eq(Face.from_dict({"kind": "attack", "power": 3, "team_rerolls": 1}).team_rerolls, 0, "the rule is a buff's: a weapon carries none")


func test_the_horns_charged_roll_never_lands_on_the_entry_the_ally_spent() -> void:
	var horn := Face.from_dict({"kind": "buff", "team_rerolls": 1, "targets": "self", "charged": {"muster": 1, "act_again": "ally"}})
	for seed in range(12):
		var sk := Skirmish.new(1, 2)
		var c := _mech("Carrier", Die.of([horn]), 40, 100)
		c.grant_passive(MUSTER)
		sk.add_mech(c)
		sk.add_mech(_mech("A", Die.of([Face.attack(10, L), Face.attack(20, L)]), 0, 100))
		sk.add_foes([_ghoul(300, 0), _ghoul(300, 0)])
		sk.begin()
		sk.rng.seed = seed
		sk.start_round()
		Effects.stack(c, Effects.STATUS["muster"], Effects.SKIRMISH, "test", 6, Effects.DECAY_NONE)
		var spent := sk.mechs[1].face_index
		assert_true(sk.assign(1, sk.front[0]), "the ally acts")
		assert_true(sk.assign(0, sk.mechs[1]), "the Horn charged, on the spent ally")
		assert_ne(sk.mechs[1].face_index, spent, "seed %d: its die rolled onto the other entry, never the one it spent" % seed)


## The Musk Ox's Forge (Ryan's go, 21 October; built that day), on a synthetic passive: the
## magazine opens at its start and gains a round's trickle from the second round; a weapon
## pays 1 ammo for every 10 heat its own spend would make, rounded up, at least 1, and heats the
## machine only by what a foe's Scorched adds; a debuff heats it as any machine; a dry gun has no
## target; a vent it spends on itself reloads 3, a shield 2, and a reload entry its own.
const FORGE := {"id": "forge", "name": "Forge", "description": "", "effects": [{"trigger": "static", "effect": "forge", "value": 10, "start": 3, "per_round": 1, "per_heat": 10, "vent": 3, "shield": 2}]}


func test_the_forge_fires_its_guns_from_ammo_and_a_foes_scorch_still_heats_them() -> void:
	var ray := Face.attack(30, L)
	ray.heat = 30
	var cold := Face.attack(10, L)
	var probe := Face.attack(0, I, [K.SHOCK])
	probe.heat = 5
	var sk := Skirmish.new(1, 2)
	var m := _mech("Ox", Die.of([ray, cold, probe, Face.vent(10), Face.shield(10)]), 40, 200)
	m.grant_passive(FORGE)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 0), _ghoul(500, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq([ms.ammo, ms.ammo_max], [3, 10], "the magazine opens at three of ten, the first round adding nothing")
	assert_eq([sk.ammo_price_of(ms, ray), sk.ammo_price_of(ms, cold), sk.ammo_price_of(ms, probe)], [3, 1, 0], "30 heat is 3 ammo, a cold gun 1, a debuff none")
	var shown := sk.shown_face(ms, ray)
	assert_eq([shown.ammo, shown.heat], [3, 0], "the die shows the price in the heat's place")
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "the ray fired")
	assert_eq([ms.ammo, ms.heat], [0, 0], "three ammo spent, no heat")
	sk.end_round()
	sk.start_round()
	assert_eq(ms.ammo, 1, "the round's trickle")
	Effects.stack(m, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_NONE)
	assert_false(sk.targets_for_face(ms, ray).size() > 0, "a dry gun has no target")
	assert_true(sk.shown_face(ms, ray).dry, "and shows so")
	ms.face_index = 1
	assert_true(sk.assign(0, sk.front[0]), "the cold gun, scorched")
	assert_eq([ms.ammo, ms.heat], [0, _rule("scorched", "add_heat")], "its ammo spent, and Scorched's extra on the heat bar")
	sk.end_round()
	sk.start_round()
	Effects.remove(m, "scorched")   # the test's scorch never decays; a foe's goes at the turn's end
	ms.heat = 0
	ms.face_index = 2
	assert_true(sk.assign(0, sk.front[0]), "the debuff")
	assert_eq(ms.heat, 5, "a debuff heats it as any machine")
	sk.end_round()
	sk.start_round()
	ms.face_index = 3
	var before := ms.ammo
	assert_true(sk.assign(0, ms), "a vent on itself")
	assert_eq(ms.ammo, before + 3, "reloads three")
	sk.end_round()
	sk.start_round()
	before = ms.ammo
	ms.face_index = 4
	assert_true(sk.assign(0, ms), "a shield on itself")
	assert_eq(ms.ammo, before + 2, "reloads two")
	# A shield that cools is a vent and a shield at once and reloads once, the greater (Ryan, 8
	# November: "Once, take the greater number").
	for both in [Face.from_dict({"kind": "shield", "power": 3, "vents": 2})]:
		var s2 := Skirmish.new(1, 2)
		var ox := _mech("Ox", Die.single(both), 40, 200)
		ox.grant_passive(FORGE)
		s2.add_mech(ox)
		s2.add_foes([_ghoul(500, 0), _ghoul(500, 0)])
		s2.begin()
		s2.start_round()
		var oms: Skirmish.MechState = s2.mechs[0]
		var had := oms.ammo
		assert_true(s2.assign(0, oms), "a cool-and-shield entry on itself")
		assert_eq(oms.ammo, had + 3, "reloads three, once: the shield's number, the greater")


## The Musk Ox's pieces (21 October), synthetic: the cluster cannon gives an ammo back for every
## foe its blows reach; the salvo needs its gate's ammo, empties the magazine and lands its number
## on every foe (a stand-in since Sweep went, 12 November; its session's), the magazine its price
## and no heat; the quick reload, Rapid, adds its 2 for its heat, and the Forge counts it as no vent.
func test_the_cluster_cannon_refunds_the_salvo_empties_and_the_quick_reload_heats() -> void:
	var cannon := Face.attack(5, I, [K.CLEAVE, K.PENETRATE])
	cannon.cleave = 3
	cannon.penetrate = 3
	cannon.heat = 10
	cannon.ammo_per_foe_hit = 1
	var salvo := Face.attack(5, E)
	salvo.spends_magazine = true
	salvo.magazine_min = 4
	var reload := Face.vent(0)
	reload.targets = Face.Target.SELF
	reload.add_keyword(K.RAPID)
	reload.heat = 15
	reload.reloads_ammo = 2
	assert_eq(reload.number_text(), "+2", "a reload prints the ammo it adds")
	assert_eq([Glyphs.primary_for(reload), DieFaceView.number_mark(reload), DieFaceView.die_number(reload)], ["ammo", "ammo", "2"], "and is drawn as its shells and the ammo it loads: it cools nothing, so no steam, and no mark of its own (2 and 3 November)")
	var sk := Skirmish.new(2, 3)
	var m := _mech("Ox", Die.of([cannon, salvo, reload]), 40, 200)
	m.grant_passive(FORGE)
	sk.add_mech(m)
	sk.add_foes([_ghoul(200, 0), _ghoul(200, 0), _ghoul(200, 0), _archer(200, 0), _archer(200, 0), _archer(200, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[1]), "the cannon on the middle front")
	assert_eq(ms.ammo, 3 - 1 + 4, "one ammo paid, four back: the target, its two neighbours and the foe behind it")
	sk.end_round()
	sk.start_round()
	var hp_before := 0
	for f in sk.field_foes():
		hp_before += f.hp
	var n := ms.ammo
	ms.face_index = 1
	ms.ammo = 3
	assert_true(sk.targets_for_face(ms, salvo).is_empty(), "under its gate of four the salvo has nowhere to land")
	assert_true(sk.shown_face(ms, salvo).dry, "and the die shows it dry")
	ms.ammo = n
	assert_true(n >= 4, "the magazine holds its gate")
	assert_true(sk.assign(0, sk.front[0]), "the salvo")
	assert_eq([ms.ammo, ms.heat], [0, 0], "the whole magazine spent, and no heat of its own")
	var hp_after := 0
	for f in sk.field_foes():
		hp_after += f.hp
	assert_eq(hp_before - hp_after, 6 * 5, "its 5 on every foe, both ranks")
	assert_true("\n".join(sk.log).contains("empties the magazine: %d ammo" % n), "the log says what it spent")
	sk.end_round()
	sk.start_round()
	before_heat_check(sk, ms)


## The salvo under Scorched (Ryan, 8 November: "scorch affects the actual heat bar, not the ammo
## cost"): the magazine pays the shots and the gun makes no heat of its own, and a Scorched
## machine's extra lands on its heat bar, as on every forged gun.
func test_a_scorched_salvo_heats_its_machine_by_scorcheds_extra() -> void:
	var salvo := Face.attack(5, E)
	salvo.spends_magazine = true
	var sk := Skirmish.new(1, 2)
	var m := _mech("Ox", Die.single(salvo), 40, 200)
	m.grant_passive(FORGE)
	sk.add_mech(m)
	sk.add_foes([_ghoul(200, 0), _ghoul(200, 0)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	Effects.stack(m, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe", 2, Effects.DECAY_NONE)
	assert_true(sk.assign(0, sk.front[0]), "the salvo, scorched")
	assert_eq([ms.ammo, ms.heat], [0, 2 * _rule("scorched", "add_heat")], "the magazine spent, and Scorched's extra on the heat bar")


func before_heat_check(sk: Skirmish, ms: Skirmish.MechState) -> void:
	var ammo := ms.ammo
	var heat := ms.heat
	ms.face_index = 2
	assert_true(sk.assign(0, ms), "the quick reload")
	assert_eq(ms.ammo, ammo + 2, "adds its 2, and no vent's 3")
	assert_eq(ms.heat, heat + 15, "for its heat")
	assert_false(ms.assigned, "Rapid: the machine acts again")


## Heat is paid once a spend (the rules: a blow), every modifier's with it: a three-strike gun
## under Scorched heats by its own heat and the scorch's once, as the die shows (fixed 21 October:
## the modifiers' heat had landed on every strike).
func test_a_multi_strike_gun_pays_its_heat_once_a_spend() -> void:
	var maxi_gun := Face.attack(5, L, [], 5)
	maxi_gun.strikes = 3
	var sk := Skirmish.new(1, 1)
	var m := _mech("Gunner", Die.single(maxi_gun), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 0)])
	sk.begin()
	sk.start_round()
	Effects.stack(m, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe", 1, Effects.DECAY_NONE)
	var ms: Skirmish.MechState = sk.mechs[0]
	var sc := _rule("scorched", "add_heat")
	assert_eq(sk.shown_face(ms, maxi_gun).heat, 5 + sc, "the die shows its 5 and the scorch's extra")
	assert_true(sk.assign(0, sk.front[0]), "spent")
	assert_eq(ms.heat, 5 + sc, "and the spend adds them, once")


## The enemy's turn goes on past a foe with no machine to strike (the audit's 13, 27 October):
## every machine Phased, the first foe's blow is lost and the second still ticks its Ablating.
func test_the_enemy_turn_goes_on_when_no_machine_can_be_struck() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(10, L)), 40, 100)
	sk.add_mech(a)
	var first := _ghoul(100, 10)
	var second := _ghoul(100, 10)
	sk.add_foes([first, second])
	sk.begin()
	sk.start_round()
	Effects.grant_buff(a, "phased", 1, "test", sk.round)
	Effects.stack(second, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	sk.end_round()
	assert_eq(a.hull + a.shield, 140, "nothing reaches the Phased machine")
	assert_eq(second.hp, 97, "the second foe's Ablating ticked: the turn went on past the first")
	assert_eq(Effects.stacks_of(second, "ablating"), 2, "and a stack faded")
	assert_true("\n".join(sk.log).contains("no machine to strike"), "the log says the first had nobody to strike")


## Heat a blow goes through the heat path every other heat takes (the audit's 17, 27 October),
## so a passive that answers heat gained answers it: each blow's point off the shield, then its
## heat standing up the flywheel's 5.
func test_heat_a_blow_fires_the_on_heat_gain_passives() -> void:
	var siphon := Face.from_dict({"kind": "attack", "reach": "every_foe", "power": 0, "keywords": ["lure"]})
	var flywheel := {"id": "flywheel", "name": "Flywheel", "description": "", "effects": [
		{"trigger": "on_heat_gain", "effect": "add_shield", "value": 5}]}
	var sk := Skirmish.new(1, 2)
	var u := _mech("A", Die.single(siphon), 40, 200)
	u.shield = 10
	u.grant_passive(flywheel)
	u.grant_passive(_heat_a_blow(10), "heat_a_blow")   # ten heat a blow it takes
	sk.add_mech(u)
	sk.add_foes([_ghoul(100, 1), _ghoul(100, 1), _archer(100, 1)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "the lure is spent")
	sk.end_round()
	assert_eq(sk.mechs[0].heat, 30, "three blows, ten heat each")
	assert_eq(u.shield, 22, "and each blow's heat stood up the flywheel's 5 shield, its point off first")


## Area by shape, numbered, and the blow's order (Ryan, 28 October): every foe past the target
## takes its shape's number in place of the roll; the firer's modifiers land on every blow, its
## adds then its multiplies (the Kite's double on the printed number before them), then each
## foe its own statuses, its adds then its multiplies (a Shock's never, no strike being aimed at
## it: 29 October), then its armour.
func test_area_takes_its_number_through_the_firers_modifiers_then_each_foes_own() -> void:
	var sk := Skirmish.new(1, 3)
	var sweep := Face.attack(6, L, K.CLEAVE)
	sweep.cleave = 2
	var m := _mech("A", Die.single(sweep), 40, 100)
	m.grant_passive({"id": "test_edge", "name": "Edge", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 1},
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 2}]})
	sk.add_mech(m)
	var left := _ghoul(100)
	var mid := _ghoul(100)
	var right := _ghoul(100)
	left.armour = 1
	sk.add_foes([left, mid, right])
	sk.begin()
	sk.start_round()
	Effects.stack(left, Effects.STATUS["brittled"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_HALF)
	Effects.stack(right, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(0, mid), "the sweep at the middle")
	assert_eq(mid.hp, 100 - (6 + 1) * 2, "the target: the roll, the firer's add, then its multiply")
	assert_eq(left.hp, 100 - ((2 + 1) * 2 + 1 - 1), "a neighbour: Spread 2, the firer's add and multiply, then its own Brittle, then its armour")
	assert_eq(right.hp, 100 - (2 + 1) * 2, "the other: the same blow, its Shock never read, no strike being aimed at it (29 October)")
	assert_true(Effects.has(right, "shocked"), "and the shock stands")
	# The Kite's double stays on the printed number (Ryan, 28 October: his reading, doubling after
	# the firer's flat adds, is its buff if it ever needs one): what the entry prints from its
	# firer is doubled, the buffs land once after, and each foe's own read (the hull it is
	# missing) after those, undoubled (Ryan's chain: the struck unit's reads after the firer's multiplies).
	var s2 := Skirmish.new(1, 3)
	var gun := Face.attack(6, L, K.CLEAVE)
	gun.cleave = 2
	gun.power_per_missing = 1
	gun.per_missing = 5
	var kite := _mech("K", Die.single(gun), 40, 100)
	kite.grant_passive({"id": "test_double", "name": "Double", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_printed", "value": 2},
		{"trigger": "on_attack", "effect": "add_damage", "value": 1}]})
	s2.add_mech(kite)
	var hurt := _ghoul(100)
	var aim := _ghoul(100)
	var whole := _ghoul(100)
	s2.add_foes([hurt, aim, whole])
	s2.begin()
	s2.start_round()
	hurt.hp = 90
	assert_true(s2.assign(0, aim), "at the unhurt middle")
	assert_eq(aim.hp, 100 - (6 * 2 + 1), "the printed 6 doubled, the buff once after: missing nothing, it adds nothing")
	assert_eq(hurt.hp, 90 - (2 * 2 + 1 + 10 / 5), "the hurt neighbour: its Spread 2 doubled, the buff once, then its own missing hull, undoubled")
	assert_eq(whole.hp, 100 - (2 * 2 + 1), "the whole one: its Spread 2 doubled, the buff once")


## A condition on the foe is read on each foe struck (the mechanics audit's 9): the Tensor's
## point lands on a marked neighbour and not on a clean target; a rank read (the Ram Frame's)
## on each foe's own rank.
func test_a_condition_on_the_foe_is_read_on_each_foe_struck() -> void:
	var sk := Skirmish.new(1, 3)
	var sweep := Face.attack(5, L, K.CLEAVE)
	sweep.cleave = 2
	var m := _mech("A", Die.single(sweep), 40, 100)
	m.grant_passive({"id": "test_tensor", "name": "Tensor", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_status"}]})
	sk.add_mech(m)
	var marked := _ghoul(100)
	var clean := _ghoul(100)
	var plain := _ghoul(100)
	sk.add_foes([marked, clean, plain])
	sk.begin()
	sk.start_round()
	Effects.stack(marked, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 1)
	assert_true(sk.assign(0, clean), "at the clean middle")
	assert_eq(clean.hp, 95, "the clean target: no point")
	assert_eq(marked.hp, 97, "the marked neighbour: its Spread 2 and the point")
	assert_eq(plain.hp, 98, "the clean neighbour: its Spread 2 alone")
	var s2 := Skirmish.new(1, 1)
	var lance := Face.attack(5, L, K.PENETRATE)
	lance.penetrate = 3
	var r := _mech("R", Die.single(lance), 40, 100)
	r.grant_passive({"id": "test_ram", "name": "Ram", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_rank", "rank": "front", "reach": "direct"}]})
	s2.add_mech(r)
	var front := _ghoul(100)
	var back := _archer(100)
	s2.add_foes([front, back])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, front), "a Direct lance at the front")
	assert_eq(front.hp, 94, "the front foe: the blow and the front rank's point")
	assert_eq(back.hp, 97, "the back foe it punches through: its Penetrate 3, no point, its rank the back")


## A consumer eats each foe struck its own stacks (the mechanics audit's 19; Ryan, 28 October:
## "If only one unit is on fire, that's the only one that gets spiked"), on its first blow.
func test_a_consumer_eats_each_foe_struck_its_own() -> void:
	var sk := Skirmish.new(1, 3)
	var charge := Face.attack(2, L, K.CLEAVE)
	charge.cleave = 1
	charge.consumes = "ablating"
	charge.per_consumed = 1
	var m := _mech("A", Die.single(charge), 40, 100)
	m.grant_passive({"id": "test_double", "name": "Double", "description": "", "effects": [{"trigger": "on_attack", "effect": "multiply_damage", "value": 2}]})
	sk.add_mech(m)
	var burning := _ghoul(100)
	var aim := _ghoul(100)
	var cold := _ghoul(100)
	sk.add_foes([burning, aim, cold])
	sk.begin()
	sk.start_round()
	Effects.stack(burning, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	assert_true(sk.assign(0, aim), "the charge at the cold middle")
	assert_eq(aim.hp, 96, "the target eats nothing: its blow alone, doubled by the firer")
	assert_eq(burning.hp, 100 - (1 * 2 + 3), "the burning neighbour: its Spread 1 doubled, then a point a stack it carried, undoubled (the struck unit's reads after the firer's multiplies)")
	assert_eq(cold.hp, 98, "the cold one: its Spread 1, doubled")
	assert_false(Effects.has(burning, "ablating"), "its stacks eaten")
	assert_true("\n".join(sk.log).contains("consumes Ablate ×3 on"), "the log says whose")


## The plus round the target, a piece carrying Spread and Penetrate together (Ryan, 15 November:
## "a few select pieces carrying both spread and penetrate together", with Splash cut as a word);
## a twin slot reached whole, each half as the one it pairs with (the target's own beside it in
## the row, or the column's when the entry reaches no row).
func test_spread_and_penetrate_together_reach_the_plus_and_a_twin_takes_its_shape() -> void:
	var sk := Skirmish.new(1, 3)
	var burst := Face.attack(6, I, [K.CLEAVE, K.PENETRATE])
	burst.cleave = 2
	burst.penetrate = 2
	assert_eq(burst.describe(), "indirect 6 spread 2 penetrate 2", "each keyword reads with its number")
	assert_true(Face.keyword_from_name("splash") <= 0, "and Splash is no keyword")
	assert_true(burst.reaches_row() and burst.reaches_column(), "the row and the column")
	sk.add_mech(_mech("A", Die.single(burst), 40, 100))
	sk.add_foes([_ghoul(100), _ghoul(100), _ghoul(100), _archer(100), _archer(100), _archer(100)])
	sk.begin()
	sk.start_round()
	var aim: Foe = sk.front[1]
	assert_true(sk.assign(0, aim), "at the front middle")
	assert_eq(aim.hp, 94, "the target takes the blow")
	assert_eq([sk.front[0].hp, sk.front[2].hp, sk.back[1].hp], [98, 98, 98], "the plus round it, two each")
	assert_eq([sk.back[0].hp, sk.back[2].hp], [100, 100], "and nothing past the plus")
	# The Gel's pair: aimed at a half, its twin takes the row's number, or the column's.
	var s2 := Skirmish.new(2, 3)
	var sweep := Face.attack(3, L, K.CLEAVE)
	sweep.cleave = 2
	var lance := Face.attack(3, L, K.PENETRATE)
	lance.penetrate = 1
	s2.add_mech(_mech("A", Die.of([Face.attack(200, L), sweep, lance]), 40, 100))
	var heavy := _ghoul(500, 20)
	var gel := _ghoul(30, 10)
	gel.on_death = {"summon": "gel_small", "count": 2, "pair": true}
	s2.foe_factory = func(id: String) -> Foe: return Foe.make(id, 5, 2)
	s2.add_foes([heavy, gel])
	s2.begin()
	s2.start_round()
	var ms: Skirmish.MechState = s2.mechs[0]
	ms.face_index = 0
	s2.assign(0, gel)
	var left: Foe = s2.front[1]
	var right: Foe = s2.twin_of(left)
	assert_true(right != null, "the pair stands")
	var shapes := s2.area_shapes(sweep, left)
	assert_eq([int(shapes.get(right, 0)), int(shapes.get(heavy, 0))], [Skirmish.AREA_ROW, Skirmish.AREA_ROW], "Spread at a half: its twin and the foe beside both in the row")
	assert_eq(int(s2.area_shapes(lance, left).get(right, 0)), Skirmish.AREA_COLUMN, "Penetrate alone at a half: its twin takes the column's number")
	assert_eq(Skirmish.area_number(lance, Skirmish.AREA_COLUMN), 1, "Penetrate's 1")


## A numbered grant (the drum's, Ryan, 28 October) gives the keyword its number; on an entry
## already carrying it, the grant's number replaces the entry's own (Ryan: the drum "forces the
## weapon into its own shape"; the higher of the two would be "gaming the build").
func test_a_numbered_grant_sets_the_keywords_number() -> void:
	var sk := Skirmish.new(1, 3)
	var light := Face.attack(4, L, K.CLEAVE)
	light.cleave = 1
	var heavy := Face.attack(4, L, K.CLEAVE)
	heavy.cleave = 9
	var u := _mech("A", Die.of([light, heavy, Face.attack(4, L)]), 40, 100)
	u.grant_passive(DRUM_PASSIVE)
	sk.add_mech(u)
	sk.add_foes([_ghoul(100), _ghoul(100), _ghoul(100), _archer(100), _archer(100), _archer(100)])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	var mid: Foe = sk.front[1]
	assert_eq(sk.shown_face(ms, light, mid).cleave, 7, "a Spread 1 fired through the drum at the front sprays at the drum's 7")
	assert_eq(sk.shown_face(ms, heavy, mid).cleave, 7, "a Spread 9 leaves the drum at the drum's 7 too: the drum's shape, never the higher")
	var plain := sk.shown_face(ms, ms.die.faces[2], sk.back[1])
	assert_true(plain.has(K.PENETRATE) and plain.penetrate == 7 and not plain.has(K.CLEAVE), "a plain gun at the back punches through at the drum's 7")
	assert_eq(Effects.effect_text(DRUM_PASSIVE["effects"][2]), "aimed at the front rank: gains spread 7", "the grant's text carries its number")


# ---------------------------------------------------------------- the undo

## The undo (Ryan, 2 November: "undo to your last roll"): every spend since the last roll can
## be taken back, in the order made, the fight put back as it was before each: the foe's hull,
## the machine's heat and its die, the log and the stream. The machines' units are the field's
## own objects, their numbers written back; the round's roll leaves its bar at the trail's end,
## and the next round's start is a floor. A runner's fight keeps no snapshots and still marks.
func test_undo_takes_back_the_spends_since_the_last_roll_in_order() -> void:
	var sk := Skirmish.new(3)
	sk.keeps_undo = true
	var a := _mech("A", Die.single(Face.attack(10, L, [], 4)))
	var b := _mech("B", Die.single(Face.attack(20, L, [], 6)))
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(100, 5), _ghoul(100, 5)])
	sk.begin()
	sk.start_round()
	assert_false(sk.can_undo(), "nothing spent: nothing to take back")
	assert_eq(sk.roll_marks, [sk.log.size()], "the round's roll leaves its bar at the trail's end")
	var opened := sk.log.size()
	var stream := sk.rng.state
	assert_true(sk.assign(0, sk.front[0]), "A fires")
	var after_a := sk.log.size()
	assert_true(sk.assign(1, sk.front[1]), "B fires")
	assert_eq([sk.front[0].hp, sk.front[1].hp], [90, 80], "both struck")
	assert_eq([sk.mechs[0].heat, sk.mechs[1].heat], [4, 6], "both heated")
	assert_eq(sk.undo_depth(), 2, "two spends to take back")
	assert_true(sk.undo(), "B's spend taken back")
	assert_eq([sk.front[0].hp, sk.front[1].hp], [90, 100], "the second foe whole again, the first still struck")
	assert_eq([sk.mechs[1].heat, sk.mechs[1].assigned], [0, false], "B cool and unspent")
	assert_true(sk.mechs[1].unit == b and sk.mechs[0].unit == a, "the machines' units are the same objects")
	assert_eq(sk.log.size(), after_a, "the trail back to A's spend")
	assert_eq(sk.undo_depth(), 1, "one left")
	assert_true(sk.undo(), "A's spend taken back")
	assert_eq([sk.front[0].hp, sk.mechs[0].heat, sk.mechs[0].assigned], [100, 0, false], "the fight as the round opened")
	assert_eq(sk.log.size(), opened, "the trail as the round opened")
	assert_true(sk.rng.state == stream, "the stream as it was")
	assert_false(sk.can_undo(), "and nothing more to take back")
	assert_false(sk.undo(), "an undo with nothing to take back does nothing")
	assert_true(sk.assign(0, sk.front[0]), "A fires again, the same blow")
	assert_eq(sk.front[0].hp, 90, "the same blow")
	sk.end_round()
	sk.start_round()
	assert_false(sk.can_undo(), "the next round's roll is a floor")
	assert_eq(sk.roll_marks.size(), 2, "and leaves its bar")
	assert_eq(sk.roll_marks[1], sk.log.size(), "at the trail's end")
	var runner := Skirmish.new(3)
	runner.add_mech(_mech("A", Die.single(Face.attack(10, L))))
	runner.add_foes([_ghoul(100, 5)])
	runner.begin()
	runner.start_round()
	assert_true(runner.assign(0, runner.front[0]), "a runner's fight spends")
	assert_eq([runner.undo_depth(), runner.roll_marks.size()], [0, 1], "keeps no snapshot, and marks its rolls all the same")


## A draw is the undo's floor (Ryan, 2 November: "Obviously we can't undo past a reroll ... Rapid
## also does"): a reroll that draws, and a spend that rolls the die again, leave a bar at the
## trail's end and clear the stack, so the spends before them stand; a stepping die's reroll
## draws nothing, so it is taken back like a spend.
func test_a_reroll_or_a_rapid_spend_is_the_undos_floor_and_a_step_is_not() -> void:
	var sk := Skirmish.new(2)
	sk.keeps_undo = true
	sk.add_mech(_mech("A", Die.of([Face.attack(10, L, K.RAPID), Face.attack(30, L), Face.attack(30, L)])))   # three entries: a reroll of two others draws
	sk.add_mech(_mech("B", Die.single(Face.attack(5, L))))
	sk.add_mech(_mech("C", Die.of([Face.attack(1, L), Face.attack(1, L), Face.attack(1, L)])))
	var stepper := _mech("D", Die.of([Face.attack(1, L), Face.attack(2, L), Face.attack(3, L)]))
	stepper.grant_passive(STEP_PASSIVE)
	sk.add_mech(stepper)
	sk.add_foes([_ghoul(500, 1)])
	sk.begin()
	sk.start_round()
	var foe: Foe = sk.front[0]
	assert_true(sk.assign(1, foe), "B fires")
	assert_eq(sk.undo_depth(), 1, "one spend back")
	sk.mechs[0].face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "A fires its Rapid gun, which rolls the die again")
	assert_eq(sk.front[0].hp, 485, "both blows landed")
	assert_eq(sk.undo_depth(), 0, "the roll inside the spend is the floor: B's spend stands too")
	assert_eq(sk.roll_marks.back(), sk.log.size(), "and leaves its bar at the trail's end")
	var rolled := sk.mechs[0].face_index
	assert_true(rolled >= 1, "the die rolled to another entry")
	assert_true(sk.assign(0, sk.front[0]), "A fires its plain gun")
	assert_eq(sk.undo_depth(), 1, "that spend can go back")
	assert_true(sk.undo(), "taken back")
	assert_eq([sk.front[0].hp, sk.mechs[0].face_index, sk.mechs[0].assigned], [485, rolled, false], "the Rapid's blow stands, the die as the roll left it")
	assert_false(sk.can_undo(), "no further")
	assert_true(sk.assign(0, sk.front[0]), "A fires its plain gun again")
	var before_reroll := sk.rerolls_left
	assert_true(sk.reroll([2]), "C rerolls")
	assert_eq(sk.undo_depth(), 0, "a reroll draws: the floor")
	assert_eq(sk.roll_marks.back(), sk.log.size(), "and leaves its bar")
	var marks := sk.roll_marks.size()
	assert_true(sk.assign(2, sk.front[0]), "C fires")
	assert_eq(sk.undo_depth(), 1, "C's spend can go back, nothing before it")
	assert_true(sk.undo(), "taken back")
	assert_eq(sk.rerolls_left, before_reroll - 1, "the reroll stays spent")
	# The stepping die: its reroll steps, no draw, so the reroll itself is taken back.
	var showing := sk.mechs[3].face_index
	assert_true(sk.reroll([3]), "D rerolls: a step")
	assert_eq(sk.mechs[3].face_index, (showing + 1) % 3, "to the next chamber")
	assert_eq([sk.undo_depth(), sk.roll_marks.size()], [1, marks], "no draw: the step is an undo step and no bar")
	assert_true(sk.undo(), "the step taken back")
	assert_eq([sk.mechs[3].face_index, sk.rerolls_left], [showing, before_reroll - 1], "the die back where it stood, the reroll back")


## A rider lands on the foe its strike killed, every one (Ryan, 3 November: "the point is to show
## that the riders hit, AND it dies"), so the round preview shows them beside the skull; the
## whole attack plays out on it, death the last check.
func test_every_rider_lands_on_the_foe_its_strike_killed_and_the_preview_shows_them() -> void:
	var sk := Skirmish.new(1, 2)
	var gun := _webber(Face.attack(5, L, [K.ABLATE, K.CRYO, K.BRITTLE, K.SUPPRESS]))
	gun.ablate = 1
	gun.cryo = 1
	gun.brittle = 1
	gun.strikes = 2
	sk.add_mech(_mech("A", Die.single(gun), 40, 100))
	var weak := _ghoul(3, 10)
	sk.add_foes([weak, _ghoul(100, 10)])
	sk.begin()
	sk.start_round()
	var pv := sk.preview_round(0, weak)
	assert_false(bool(pv["foes"][weak]["alive"]), "the first strike kills it")
	var coming: Dictionary = pv["foes"][weak]["coming"]
	for sid in ["ablating", "cryoed", "brittled", "suppressed", "webbed"]:
		assert_true(coming.has(sid), "the %s on its way beside the skull: %s" % [sid, str(coming.keys())])
	if coming.has("ablating"):
		assert_eq(int(coming["ablating"]["stacks"]), 2, "both strikes' Ablate: the whole attack plays out on it (death the last check)")
	assert_true(sk.assign(0, weak), "fired")
	assert_eq([Effects.stacks_of(weak, "ablating"), Effects.stacks_of(weak, "cryoed"), Effects.stacks_of(weak, "brittled")], [2, 2, 2], "each rider a strike, the felling strike's and the one after")


## Death is the last thing checked (Ryan, 3 November: "'death' is just another chip, and is the
## last thing ever to be checked - the whole attack, or whole turn if it's a predicted death from
## burn or the like, should be played out"): a felled foe takes everything the spend does to it,
## both strikes' riders, its Shock, its Expose and the Lure's turn, so the preview shows them
## beside the skull and no trigger goes unfired; the dead are cleared once the spend is done.
func test_death_is_the_last_check_a_felled_foe_takes_everything_the_spend_does() -> void:
	var sk := Skirmish.new(1, 2)
	var gun := Face.attack(5, L, [K.ABLATE, K.SHOCK, K.EXPOSE, K.LURE])
	gun.ablate = 1
	gun.strikes = 2
	var m := _mech("A", Die.single(gun), 40, 100)
	sk.add_mech(m)
	sk.add_mech(_mech("B", Die.single(Face.attack(1, L)), 40, 100))
	var weak := _ghoul(3, 10)
	var other := _ghoul(100, 10)
	sk.add_foes([weak, other])
	sk.begin()
	sk.start_round()
	weak.target = sk.mechs[1]
	other.target = sk.mechs[1]
	var pv := sk.preview_round(0, weak)
	assert_false(bool(pv["foes"][weak]["alive"]), "the first strike kills it")
	var coming: Dictionary = pv["foes"][weak]["coming"]
	for sid in ["ablating", "shocked", "exposure"]:
		assert_true(coming.has(sid), "the %s on its way beside the skull: %s" % [sid, str(coming.keys())])
	assert_eq(int(coming.get("ablating", {}).get("stacks", 0)), 2, "both strikes' Ablate: the whole attack plays out on it")
	assert_true(sk.assign(0, weak), "fired")
	assert_true(not weak.alive() and not sk.field_foes().has(weak), "felled and cleared once the spend is done")
	assert_eq([Effects.stacks_of(weak, "ablating"), Effects.has(weak, "shocked"), Effects.has(weak, "exposure")], [2, true, true], "and it took every effect first")
	assert_true(weak.target == sk.mechs[0], "the Lure turned it on the spender, felled or not: the altered target shows")
	assert_eq([other.hp, other.target == sk.mechs[0]], [100, false], "the other foe untouched")


## A foe strikes whole and burns as its turn ends (16 November, his four places; never "a
## zero-hp enemy attacking and then dying after", Ryan, 4 November).
## The enemy's turn checks death as each foe's action is done, and at once when its tick kills it
## (the audit's first bug, 8 November): a core its Ablating kills, its own blow landed, takes its
## parts with it before they act, a last act lands before the next foe moves, and one getting
## back up does so at once, its round over.
func test_a_foe_its_tick_kills_falls_at_once_in_the_enemys_turn() -> void:
	var sk := Skirmish.new(1, 3)
	var m := _mech("A", Die.single(Face.blank()), 0, 100)
	sk.add_mech(m)
	var core := _core("")
	core.hp = 2
	var eye := _eye()
	sk.add_foes([core, eye, _eye()])
	sk.begin()
	sk.start_round()
	for f in sk.field_foes():
		f.target = sk.mechs[0]
	Effects.stack(core, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	assert_eq(sk.front[0], core, "the core acts first")
	sk.end_round()
	assert_eq(m.hull, 90, "the core struck, its Ablating killed it as its turn ended, and its parts fell with it before they struck")
	var s2 := Skirmish.new(1, 2)
	var b := _mech("B", Die.single(Face.blank()), 0, 100)
	s2.add_mech(b)
	var beast := _meteor_beast(2)
	var after := _ghoul(100, 10)
	s2.add_foes([beast, after])
	s2.begin()
	s2.start_round()
	beast.target = s2.mechs[0]
	after.target = s2.mechs[0]
	Effects.stack(beast, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	s2.end_round()
	var its: Array = []
	var blow := -1
	for ev in s2.turn_events:
		if ev.get("foe") == beast:
			its.append(int(ev.get("seq", -1)))
		elif ev.get("foe") == after and blow < 0:
			blow = int(ev.get("seq", -1))
	assert_eq(its.size(), 2, "its own blow, then the Meteor its fall set off")
	assert_true(blow >= 0 and its.size() == 2 and its[1] < blow, "its Meteor landed the moment it fell, its turn ending, before the next foe's blow")


## A fight lost in the enemy's turn ends there (the audit's second bug): the foes after the blow
## that wrecks the last machine neither tick nor act, and no kill is counted.
func test_a_fight_lost_in_the_enemys_turn_ends_there() -> void:
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(Face.blank()), 0, 10))
	var killer := _ghoul(100, 50)
	var burner := _ghoul(2, 1)
	var behind := _archer(100, 1)
	sk.add_foes([killer, burner, behind])
	sk.begin()
	sk.start_round()
	assert_eq([sk.front[0], sk.front[1]], [killer, burner], "the killer acts first")
	assert_true(sk.back.has(behind), "the third stands behind them")
	killer.target = sk.mechs[0]
	burner.target = sk.mechs[0]
	behind.target = sk.mechs[0]
	Effects.stack(burner, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	Effects.stack(behind, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	assert_eq(sk.end_round(), Skirmish.Outcome.DEFEAT, "the team falls")
	assert_true(burner.alive(), "the foe after it never ticked")
	assert_eq(behind.hp, 100, "nor the one behind")
	assert_eq(sk.team_kills, 0, "so no burn death counts as a kill")


func test_a_foe_its_burn_kills_strikes_first_and_falls_as_its_turn_ends() -> void:
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.blank()), 0, 100)
	sk.add_mech(m)
	var g := _ghoul(2, 7)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	g.target = sk.mechs[0]
	Effects.stack(g, Effects.STATUS["ablating"], Effects.SKIRMISH, "mech", 3)
	assert_eq(sk.hp_after_ticks(g), 0, "its Ablating kills it as its turn ends")
	assert_true(g.intent_on(m), "its intent on the machine shows")
	assert_true(sk.acting_on(sk.mechs[0]).has(g), "and the forecast counts its blow: it strikes before it burns")
	assert_eq(sk.incoming_for(sk.mechs[0]), 7, "its seven are incoming")
	var pv := sk.preview_round()
	assert_eq([int(pv["mechs"][0]["hull_after"]), bool(pv["foes"][g]["alive"])], [93, false], "the preview: its blow lands and it dies")
	sk.end_round()
	assert_eq(m.hull, 93, "it struck whole, never at nothing")
	assert_true(not g.alive() and not sk.field_foes().has(g), "and it is gone once the turn is done")


## Every Foe on a weapon (12 November, Sweep's place for the two gated specials): dropped on any
## foe, it strikes every foe in the fight for its number, each through its own Brittle and armour,
## and it targets the field (Ryan, 24 November: "should probably be coded as none are targeted,
## since its targeting the field. Important semantics"): no hit is aimed, the one it was dropped on
## included, so no Shock is doubled or spent and no Ricochet follows it; Chain's ping at its Resolve
## reaches every conductor (Ryan, 24 November: no target in the line).
func test_a_weapon_over_every_foe_lands_its_number_on_each() -> void:
	var blast := Face.attack(3, E)
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.single(blast), 40, 100)
	sk.add_mech(m)
	var a := _ghoul(100, 0)
	var b := _ghoul(100, 0)
	var c := _archer(100, 0)
	sk.add_foes([a, b, c])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	b.armour = 1
	assert_true(sk.targets_for_face(ms, blast).has(c), "it may be dropped on any foe, the back rank's too")
	Effects.stack(a, Effects.STATUS["shocked"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	Effects.stack(c, Effects.STATUS["shocked"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	var bot := Policy.make(Policy.GREEDY, 1)
	var worth := bot.attack_score(sk, ms, blast, a)
	assert_true(worth >= 3.0 + 2.0 + 3.0 and worth < 6.0 + 2.0 + 3.0, "the bot counts every foe it strikes, no Shock doubled, the one it is dropped on included: %f" % worth)
	Effects.stack(m, Effects.STATUS["ricochet"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	assert_true(sk.assign(0, a), "dropped on a Shocked one")
	assert_eq([a.hp, b.hp, c.hp], [97, 98, 97], "its number on each, the plated one its 3 less the plate, and no Shock doubled, the one it was dropped on included")
	assert_true(Effects.has(a, "shocked") and Effects.has(c, "shocked"), "and every Shock stands")
	assert_eq(sk.spend_blows.filter(func(x): return str(x["kind"]) == "ricochet").size(), 0, "with no target, no Ricochet follows")
	# Chain on it pings every conductor: no hit of it is aimed, so none spent a Shock.
	var arcing := Face.attack(3, E, [K.CHAIN])
	arcing.chain = 2
	assert_eq(sk.conductors(arcing, a), [a, c], "every Shocked foe, the one it is dropped on among them")
	var sk2 := Skirmish.new(1, 2)
	var m2 := _mech("A", Die.single(arcing), 40, 100)
	sk2.add_mech(m2)
	var d := _ghoul(100, 0)
	var e := _ghoul(100, 0)
	sk2.add_foes([d, e])
	sk2.begin()
	sk2.start_round()
	Effects.stack(e, Effects.STATUS["shocked"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(sk2.assign(0, d), "a Chain over every foe")
	assert_eq([d.hp, e.hp], [97, 95], "its number on each, and Chain's 2 HP off the Shocked one")


## The Hollow-point Harpoon's pin (Ryan, 11 November: "Applies 1 flak and the target's flak does
## not decay this round"; 16 November: "the next time it would decay, it doesn't"): the Brittle on
## its target, its own and what stood there, skips its next halving, as the foes' turn opens, and
## the pin is spent by it; it halves again the time after. A pin with nothing to hold goes as its
## foe's turn ends (19 November: "It should get spent when the next decay happens, or the end of
## the target's turn where it has none"). Synthetic piece.
func test_a_pin_holds_its_targets_brittle_through_its_next_halving() -> void:
	var sk := Skirmish.new(1)
	var pin := Face.from_dict({"kind": "attack", "reach": "direct", "power": 1, "keywords": ["brittle"], "brittle": 1, "holds": "brittled"})
	sk.add_mech(_mech("A", Die.single(pin), 40, 1000))
	var a := _ghoul(500, 0)
	var b := _ghoul(500, 0)
	sk.add_foes([a, b])
	sk.begin()
	sk.start_round()
	Effects.stack(a, Effects.STATUS["brittled"], Effects.SKIRMISH, "test", 4, Effects.DECAY_HALF)
	Effects.stack(b, Effects.STATUS["brittled"], Effects.SKIRMISH, "test", 4, Effects.DECAY_HALF)
	assert_true(sk.assign(0, a), "the harpoon on the first")
	assert_eq(Effects.stacks_of(a, "brittled"), 5, "it lays its own")
	assert_true(Effects.has(a, "pinned"), "and leaves it Pinned, a status of its own")
	assert_true(Effects.holds(a, "brittled"), "which holds its Brittle")
	sk.end_round()
	assert_eq(Effects.stacks_of(a, "brittled"), 5, "pinned: no halving as its turn started")
	assert_false(Effects.has(a, "pinned"), "the pin is spent by the halving it stopped")
	assert_eq(Effects.stacks_of(b, "brittled"), 2, "the other's halves as ever")
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(a, "brittled"), 2, "and it halves the time after")
	# A pin with nothing to hold stands through its foe's turn and goes as that turn ends.
	var c := _ghoul(500, 0)
	Effects.stack(c, Effects.STATUS["pinned"], Effects.SKIRMISH, "mech", 1, Effects.status_decay(Effects.STATUS["pinned"]))
	Effects.turn_opens(c, 3)
	assert_true(Effects.has(c, "pinned"), "no Brittle to halve as its turn opens: the pin stands")
	Effects.foe_turn_end(c)
	assert_false(Effects.has(c, "pinned"), "and goes as the turn ends, having held nothing")
	Effects.stack(c, Effects.STATUS["brittled"], Effects.SKIRMISH, "test", 4, Effects.DECAY_HALF)
	Effects.turn_opens(c, 4)
	assert_eq(Effects.stacks_of(c, "brittled"), 2, "so a Brittle laid after it halves as ever")


## The Combat Translocator's Shock (Ryan, 11 November: "not dead versus only frontliners and
## versus massives and bosses that can't be swapped"): both foes a Swap trades come out Shocked;
## it takes two targets always ("Translocator should still target two, always"), a massive foe
## among them staying where it stands while both are Shocked; a Swap carrying nothing else still
## has no use for a foe it cannot move. Synthetic pieces.
func test_a_swap_that_shocks_marks_both_and_a_massive_foe_named_stays_put() -> void:
	var shocker := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "swaps": true, "keywords": ["shock"]})
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(shocker), 40, 1000))
	var a := _ghoul(500, 0)
	var b := _ghoul(500, 0)
	sk.add_foes([a, b])
	sk.begin()
	sk.start_round()
	var at := [a.column, b.column]
	assert_true(sk.needs_second(sk.mechs[0]), "a second target, always")
	assert_true(sk.assign(0, a, b), "the two trade")
	assert_eq([a.column, b.column], [at[1], at[0]], "places traded")
	assert_true(Effects.has(a, "shocked") and Effects.has(b, "shocked"), "both come out Shocked")
	var boss := Skirmish.new(1)
	boss.add_mech(_mech("A", Die.single(shocker), 40, 1000))
	var big := _ghoul(500, 0)
	big.size = 2
	var small := _ghoul(500, 0)
	boss.add_foes([big, small])
	boss.begin()
	boss.start_round()
	assert_true(boss.needs_second(boss.mechs[0]), "a massive foe named: a second target still")
	assert_false(boss.assign(0, big), "never alone")
	var seconds := boss.swap_targets(big, true)
	assert_true(seconds.has(small) and seconds.any(func(x) -> bool: return x is Vector2i), "its second: another foe or an empty slot")
	var where := [big.column, small.column]
	assert_true(boss.assign(0, big, small), "the two are named")
	assert_eq([big.column, small.column], where, "nothing moves: a massive foe stays")
	assert_true(Effects.has(big, "shocked") and Effects.has(small, "shocked"), "and both are Shocked")
	assert_true("\n".join(boss.log).contains("holds its ground"), "the log says why")
	var plain := Skirmish.new(1)
	plain.add_mech(_mech("A", Die.single(Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "swaps": true})), 40, 1000))
	var huge := _ghoul(500, 0)
	huge.size = 2
	plain.add_foes([huge])
	plain.begin()
	plain.start_round()
	assert_false(plain.can_spend(0), "a Swap that carries nothing else has no use for a foe it cannot move")


## Ablating's pin (Ryan, 11 November: "a similar one for burning as well ... Might as well code it
## in"; 16 November: "the next time it would decay, it doesn't"): a foe under it burns for every
## stack as its turn ends and loses none, the pin spent by the fade it stopped, and its Ablating
## fades again the turn after; on a foe with no Ablating it goes as that turn ends all the same.
## No piece lays it yet: granted here.
func test_pinned_burning_burns_and_loses_no_stack_the_next_time() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.blank()), 40, 1000))
	var a := _ghoul(500, 0)
	var b := _ghoul(500, 0)
	var c := _ghoul(500, 0)
	sk.add_foes([a, b, c])
	sk.begin()
	sk.start_round()
	for foe in [a, b]:
		Effects.stack(foe, Effects.STATUS["ablating"], Effects.SKIRMISH, "test", 3, Effects.DECAY_TICK)
	assert_eq(str(Effects.HOLDERS["ablating"]), "seared", "Ablating has a holder of its own")
	for foe in [a, c]:
		Effects.stack(foe, Effects.STATUS["seared"], Effects.SKIRMISH, "test", 1, Effects.status_decay(Effects.STATUS["seared"]))
	assert_true(Effects.holds(a, "ablating"), "the pin holds its Ablating")
	sk.end_round()
	assert_false(Effects.has(c, "seared"), "a pin with no Ablating to hold goes as its foe's turn ends")
	assert_eq(Effects.stacks_of(a, "ablating"), 3, "pinned: it burned and lost no stack")
	assert_eq(Effects.stacks_of(b, "ablating"), 2, "the other's fades a stack as ever")
	assert_eq(a.hp, b.hp, "both burned alike this turn")
	assert_false(Effects.has(a, "seared"), "the pin is spent by the fade it stopped")
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(a, "ablating"), 2, "and it fades the turn after")


## Sapped (Ryan, 11 November: "Deals 1 less damage per stack with attacks"; "Weaken can apply to
## both sides"; "till after it's next turn then, instead of round end. Let's use Sapped"): a foe's
## blow a point lower a stack, never below nothing, gone at the end of its next action; a machine's
## attacks the same, gone at the end of the player's turn; a Cleanse clears it from a machine.
func test_sapped_lowers_blows_on_either_side_and_goes_after_its_next_turn() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.blank()), 0, 1000)
	sk.add_mech(m)
	var foe := _ghoul(500, 4)
	sk.add_foes([foe])
	sk.begin()
	sk.start_round()
	var before := sk.foe_blow(foe)
	var gained := {}
	var turned := {}
	sk._land_rider(foe, "sapped", 2, gained, turned)
	assert_eq(sk.foe_blow(foe), before - 2, "its blow two lower")
	sk._land_rider(foe, "sapped", 9, gained, turned)
	assert_eq(sk.foe_blow(foe), 0, "never below nothing")
	var hull := m.hull
	sk.end_round()
	assert_eq(m.hull, hull, "its blow landed as nothing")
	assert_false(Effects.has(foe, "sapped"), "every stack gone after its action")
	sk.start_round()
	assert_eq(sk.foe_blow(foe), before, "and its blow whole again")
	var whole := Effects.attack(m, Face.attack(5, L), 5, 0, foe)
	Effects.stack(m, Effects.STATUS["sapped"], Effects.SKIRMISH, "test", 2, Effects.DECAY_AFTER_TURN)
	var weak := Effects.attack(m, Face.attack(5, L), 5, 0, foe)
	assert_eq(int(weak["damage"]), int(whole["damage"]) - 2, "a machine's attack two lower")
	sk._end_player_turn()
	assert_false(Effects.has(m, "sapped"), "gone at the end of the player's turn")
	Effects.stack(m, Effects.STATUS["sapped"], Effects.SKIRMISH, "test", 1, Effects.DECAY_AFTER_TURN)
	assert_eq(Effects.cleanse(m), ["Sapped"], "and a Cleanse clears it")


## The foe in front (the Photosphere Lance's; Ryan, 11 November: "You target ally or self. The
## enemy directly in front of them gets the debuff, or if none in either rank in front, the closest
## column that does, searching left-right-left-right"): a machine faces its spot's column, the
## squad of three from the left; its front rank, then its back, then left, right. Synthetic piece.
func test_a_buff_lays_its_rider_on_the_foe_in_front_of_the_machine_it_lands_on() -> void:
	var lance := Face.from_dict({"kind": "buff", "status": "overcharged", "stacks": 2, "in_front": {"status": "sapped", "stacks": 2}})
	var sk := Skirmish.new(1)
	for k in range(3):
		sk.add_mech(_mech("M%d" % k, Die.single(lance), 40, 1000))
	var a := _ghoul(500, 3)
	var b := _archer(500, 3)
	var c := _ghoul(500, 3)
	sk.add_foes([a, b, c])
	sk.begin()
	_regrid(sk, [[a, 0, 0], [b, 1, 1], [c, 0, 3]])
	sk.start_round()
	assert_eq([sk.mech_spot(0), sk.mech_spot(1), sk.mech_spot(2)], [0, 1, 2], "a squad of three from the left")
	assert_eq(sk.foe_in_front(sk.mechs[0]), a, "column 0's front")
	assert_eq(sk.foe_in_front(sk.mechs[1]), b, "column 1: no front, its back")
	assert_eq(sk.foe_in_front(sk.mechs[2]), b, "column 2 empty: left first")
	assert_true(sk.assign(2, sk.mechs[0]), "spent on the first machine")
	assert_eq(Effects.stacks_of(sk.mechs[0].unit, "overcharged"), 2, "Empowered there")
	assert_eq(Effects.stacks_of(a, "sapped"), 2, "Sapped on the foe in front of it")
	assert_eq(Effects.stacks_of(b, "sapped") + Effects.stacks_of(c, "sapped"), 0, "and no other")
	var two := Skirmish.new(1)
	for k in range(2):
		two.add_mech(_mech("M%d" % k, Die.single(lance), 40, 1000))
	var w := _ghoul(500, 3)
	two.add_foes([w])
	two.begin()
	assert_eq([two.mech_spot(0), two.mech_spot(1)], [1, 2], "a squad of two in the middle spots")
	_regrid(two, [[w, 0, 1]])
	two.start_round()
	Effects.grant_buff(w, "ward", 1, "test", two.round)
	assert_true(two.assign(0, two.mechs[0]), "on itself")
	assert_false(Effects.has(w, "sapped"), "a Ward turns it away")


## The grid cleared and the foes stood where a test says: [foe, rank, column] each.
func _regrid(sk: Skirmish, cells: Array) -> void:
	for col in range(sk.columns):
		sk.front[col] = null
		sk.back[col] = null
	for cell in cells:
		sk._place(cell[0], cell[1], cell[2])


## The round's forecast shows the Lance's rider coming (11 November): dragged over a machine, the
## foe in front of it shows Sapped among what the round lands on it.
func test_the_forecast_shows_the_rider_coming_on_the_foe_in_front() -> void:
	var lance := Face.from_dict({"kind": "buff", "status": "overcharged", "stacks": 2, "in_front": {"status": "sapped", "stacks": 2}})
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(lance), 40, 1000))
	sk.add_mech(_mech("B", Die.single(Face.attack(3, L)), 40, 1000))
	var a := _ghoul(500, 3)
	var b := _ghoul(500, 3)
	sk.add_foes([a, b])
	sk.begin()
	_regrid(sk, [[a, 0, 1], [b, 0, 2]])
	sk.start_round()
	var front := sk.foe_in_front(sk.mechs[1])
	var pv := sk.preview_round(0, sk.mechs[1])
	assert_true((pv["foes"][front]["coming"] as Dictionary).has("sapped"), "Sapped coming on the foe in front")
	assert_false(Effects.has(front, "sapped"), "and nothing landed yet")


## The Juggernaut Drive's shove (the Wild Boar's; Ryan, 11 November: "Damaging an enemy in the
## front rank deals 25% of its maximum HP, rounded up, to the enemy immediately behind"): once the
## hits land, every front foe a blow damaged drives that share into the foe behind it, through its
## armour, once a spend; a front foe the blow did not damage, or a massive one, drives nothing.
## Synthetic passive and pieces.
func _juggernaut() -> Dictionary:
	return {"id": "juggernaut_test", "name": "Juggernaut", "description": "", "effects": [
		{"trigger": "static", "effect": "shove_behind", "value": 25},
		{"trigger": "on_barrier", "effect": "stack_status", "value": "juggernaut", "stacks": 1, "cap": 1}]}


func test_a_damaging_blow_on_the_front_drives_a_quarter_of_its_maximum_hp_behind() -> void:
	var twice := Face.from_dict({"kind": "attack", "reach": "direct", "power": 3, "strikes": 2})
	var sk := Skirmish.new(1)
	var m := _mech("Boar", Die.of([twice, Face.attack(3, L)]), 40, 1000)
	m.grant_passive(_juggernaut())
	sk.add_mech(m)
	var a := _ghoul(12, 0)
	var b := _archer(500, 0)
	var c := _ghoul(12, 0)
	var d := _archer(500, 0)
	c.armour = 10
	sk.add_foes([a, b, c, d])
	sk.begin()
	_regrid(sk, [[a, 0, 0], [b, 1, 0], [c, 0, 1], [d, 1, 1]])
	sk.start_round()
	var ms := sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, a), "two strikes on the front foe")
	assert_eq(b.hp, 500 - 3, "a quarter of its 12, once for the spend, not a strike")
	assert_true("\n".join(sk.log).contains("drives revenant into"), "the log says so")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, c), "a blow its armour takes whole")
	assert_eq(d.hp, 500, "no damage on the front: nothing driven")
	var boss := Skirmish.new(1)
	var bm := _mech("Boar", Die.single(Face.attack(3, L)), 40, 1000)
	bm.grant_passive(_juggernaut())
	boss.add_mech(bm)
	var big := _ghoul(40, 0)
	big.size = 2
	boss.add_foes([big])
	boss.begin()
	boss.start_round()
	assert_true(boss.assign(0, big), "a massive foe")
	assert_false("\n".join(boss.log).contains("drives"), "nothing stands behind it")


## The Juggernaut Drive's waiting state (Ryan, 11 November: "After gaining Barrier, its next
## weapon attack gains Breach"; "a purgeable buff"; 15 November: 'Change to explicit "ignores
## armour."'): gained with a Barrier, one whatever grants it, the next weapon spend ignoring armour
## and lifting it, equipment leaving it, a purge taking it. Synthetic passive and pieces.
func test_a_barrier_makes_the_next_weapon_attack_ignore_armour() -> void:
	var wall := Face.from_dict({"kind": "buff", "status": "barrier", "stacks": 1, "rounds": 1, "targets": "self"})
	var lure := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure"]})
	var sk := Skirmish.new(1)
	var m := _mech("Boar", Die.of([wall, lure, Face.attack(4, L)]), 40, 1000)
	m.grant_passive(_juggernaut())
	sk.add_mech(m)
	var foe := _ghoul(500, 0)
	foe.armour = 3
	sk.add_foes([foe])
	sk.begin()
	sk.start_round()
	var ms := sk.mechs[0]
	ms.face_index = 0
	assert_true(sk.assign(0, ms), "a Barrier on itself")
	assert_eq(Effects.stacks_of(m, "juggernaut"), 1, "the Drive's state with it")
	assert_eq(str(Effects.STATUS["juggernaut"]["name"]), "Juggernaut Drive", "shown under the passive's own name")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	assert_true(sk.assign(0, ms), "another Barrier")
	assert_eq(Effects.stacks_of(m, "juggernaut"), 1, "still one")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, foe), "equipment at a foe")
	assert_eq(Effects.stacks_of(m, "juggernaut"), 1, "equipment leaves it standing")
	sk.end_round()
	sk.start_round()
	ms.face_index = 2
	var hp := foe.hp
	assert_true(Effects.effective_face(ms.unit, ms.face(), foe).ignores_armour and not ms.die.faces[2].ignores_armour, "the gun fires ignoring armour, the piece itself unchanged")
	var shown := sk.shown_face(ms, ms.face(), foe)
	assert_true(shown.rule_phrases().has("ignores armour"), "the die shows the rule on the gun while the state stands")
	assert_eq(sk.shown_number(ms, shown, foe), 4, "and its number whole")
	assert_true(sk.assign(0, foe), "the next weapon")
	assert_eq(hp - foe.hp, 4, "it ignores armour: the foe's 3 takes nothing")
	assert_false(Effects.has(m, "juggernaut"), "and lifts it")
	Effects.stack(m, Effects.STATUS["juggernaut"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	Effects.purge(m, 1)
	assert_false(Effects.has(m, "juggernaut"), "a purge takes it")


## The Wild Boar as content (11 November): its Plow a self-defence, Cleanse and a Barrier on itself
## on a cooldown of 1, and its Juggernaut Drive the shove and the gun that ignores armour after a Barrier.
func test_the_wild_boar_plows_and_drives() -> void:
	var db := ContentDB.load_default()
	var plow := Face.from_dict(db.components["breaching_plow"]["face"])
	assert_eq(plow.kind, Face.Kind.BUFF, "the Plow is equipment")
	assert_eq([plow.buff_status, plow.targets, plow.cooldown], ["barrier", Face.Target.SELF, 1], "a Barrier on itself, cooldown 1")
	assert_true(plow.has(Face.Keyword.CLEANSE), "with a Cleanse")
	var u := db.make_mech("wild_boar", 1)
	assert_eq(Effects.shove_share(u), 25, "the drive's quarter")


## The Pocket Paradox since 11 November (Ryan: "When an enemy gains one or more debuff stacks other
## than Paradox, it also gains that many Paradox stacks"; "At five or more, consume all stacks to
## grant Suppressed"; "Shocked and such are a stack, it just caps at 1, so yes they grant 1
## paradox"): a stack of Paradox for every debuff stack, a stackless one one, a buff none; at five or
## more every stack goes and the foe is Suppressed. Synthetic passive.
func test_the_paradox_counts_debuff_stacks_and_suppresses_at_its_count() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("Baboon", Die.single(Face.blank()), 40, 1000)
	m.grant_passive({"id": "paradox_test", "name": "", "description": "", "effects": [{"trigger": "on_foe_status", "effect": "paradox", "value": 5}]})
	sk.add_mech(m)
	var foe := _ghoul(500, 3)
	sk.add_foes([foe])
	sk.begin()
	sk.start_round()
	var gained := {}
	var turned := {}
	sk._land_rider(foe, "brittled", 3, gained, turned)
	for f in gained.keys():
		for sid in gained[f]:
			sk._foe_gained_status(f, sid, int(gained[f][sid]))
	assert_eq(Effects.stacks_of(foe, "paradox"), 3, "Brittle 3: three Paradox")
	sk._foe_gained_status(foe, "kindled", 2)
	assert_eq(Effects.stacks_of(foe, "paradox"), 3, "a buff it gains feeds nothing")
	sk._shock(foe, sk.mechs[0])
	assert_eq(Effects.stacks_of(foe, "paradox"), 4, "Shocked, a stack that caps at one: one")
	gained.clear()
	sk._land_rider(foe, "ablating", 2, gained, turned)
	for f in gained.keys():
		for sid in gained[f]:
			sk._foe_gained_status(f, sid, int(gained[f][sid]))
	assert_eq(Effects.stacks_of(foe, "paradox"), 0, "six of five: every stack consumed")
	assert_true(foe.is_suppressed(), "and it is Suppressed")


## The Retrocausal Shroud (the Baboon's; Ryan, 11 November: "Cleanse an ally. Disrupt all enemies
## targeting it"; "Targeting all means targeting the ally"; "Cleanse can be self"): spent on a
## machine, its marks cleared and every foe showing intent on it Disrupted, a blow at every machine
## included; a foe aiming elsewhere keeps its move. Synthetic piece.
func test_the_shroud_cleanses_a_machine_and_disrupts_every_foe_aiming_at_it() -> void:
	var shroud := Face.from_dict({"kind": "buff", "keywords": ["cleanse"], "disrupts_attackers": true})
	var sk := Skirmish.new(3)
	sk.add_mech(_mech("Baboon", Die.single(shroud), 40, 1000))
	sk.add_mech(_mech("Ally", Die.single(Face.attack(1, L)), 40, 1000))
	var foes: Array = []
	for k in range(3):
		var g := _ghoul(500, 3)
		g.actions = [Foe.basic_action(), {"id": "bite", "name": "Bite", "factor": 1.0, "strikes": 2, "weight": 1, "keywords": [], "text": ""}]
		foes.append(g)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	var ally := sk.mechs[1]
	for k in range(3):
		var g: Foe = foes[k]
		g.action = g.actions[0]
		g.target = ally if k < 2 else sk.mechs[0]
	Effects.stack(ally.unit, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "test", 2, Effects.DECAY_TURN)
	assert_true(sk.assign(0, ally), "the Shroud on the ally")
	assert_false(Effects.has(ally.unit, "ablating_mech"), "its Ablating cleared")
	assert_eq(foes[0].action, foes[0].actions[1], "a foe aiming at it takes its next move")
	assert_eq(foes[1].action, foes[1].actions[1], "every one of them")
	assert_eq(foes[2].action, foes[2].actions[0], "the one aiming elsewhere keeps its move")
	assert_true("\n".join(sk.log).contains("disrupts the foes aiming at Ally"), "the log says so")
	assert_eq(foes[0].target, ally, "still aimed at it: Disrupt changes the move, not the pick")


## Sap (the Baboon's Redshift Emitter, 11 November): a hit lays its number of Sapped on each foe it
## reaches, a strike's worth, and a Purge beside it strips a buff. Synthetic piece.
func test_sap_lays_sapped_and_rides_beside_a_purge() -> void:
	var emitter := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["dispel", "sap"], "dispel": 1, "sap": 1})
	assert_eq([emitter.sap, emitter.has(Face.Keyword.SAP)], [1, true], "Sap 1 parsed")
	assert_true(emitter.describe().contains("sap 1"), "and said")
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("Baboon", Die.single(emitter), 40, 1000))
	var foe := _archer(500, 3)
	sk.add_foes([foe])
	sk.begin()
	sk.start_round()
	Effects.stack(foe, Effects.STATUS["kindled"], Effects.SKIRMISH, "test", 2, Effects.DECAY_HALF)
	var blow := sk.foe_blow(foe)
	assert_true(sk.assign(0, foe), "the Emitter on a back-rank foe")
	assert_eq(Effects.stacks_of(foe, "sapped"), 1, "Sapped 1")
	assert_eq(Effects.stacks_of(foe, "kindled"), 1, "a stack of its buff purged")
	assert_eq(sk.foe_blow(foe), blow - 2, "its blow a point lower for each")


## The Relay rewritten (Ryan, 18 November: "it was always completely broken ... I spend anything,
## reroll, and spend whatever I want after"; then "just to send the 'unlit' kinds onto cooldown.
## There's no special cases or states then"): a weapon spent sends every weapon on its die onto
## cooldown for the round and its equipment the same, its die flipping to a lit entry of the other
## kind; a roll or a reroll lands anywhere, a dark entry doing nothing ("don't restrict the die to
## only lit faces"); a Rapid or Instant spend sends nothing but itself ("rapid does not consume any
## of the spends"); and the machine may reboot while its die is in play.
func _relay_fight(faces: Array) -> Skirmish:
	var sk := Skirmish.new(7, 2)
	sk.keeps_undo = true
	var m := _mech("Spotter", Die.of(faces), 40, 100)
	m.heat_max = 99
	m.grant_passive(RELAY)
	sk.add_mech(m)
	sk.add_foes([_ghoul(900, 0), _ghoul(900, 0)])
	sk.begin()
	sk.start_round()
	return sk


func test_a_spent_kind_goes_on_cooldown_and_a_reroll_onto_it_does_nothing() -> void:
	var sk := _relay_fight([Face.attack(5, L, [], 1), Face.attack(5, L, [], 1), Face.attack(5, L, [], 1), Face.attack(0, I, [K.EXPOSE]), Face.attack(0, I, [K.SHOCK])])
	var ms: Skirmish.MechState = sk.mechs[0]
	var u := ms.unit
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "a gun")
	assert_true(Effects.is_entry_disabled(u, 0) and Effects.is_entry_disabled(u, 1) and Effects.is_entry_disabled(u, 2), "every weapon on its die on cooldown for the round")
	assert_eq(Effects.dark_rounds(u, 1, sk.round), 1, "this round alone")
	assert_false(Effects.is_entry_disabled(u, 3) or Effects.is_entry_disabled(u, 4), "its equipment lit")
	assert_true([3, 4].has(ms.face_index) and not ms.assigned, "its die flipped to equipment")
	sk.rerolls_left = 60
	var dud := false
	for k in range(60):
		assert_true(sk.reroll([0]), "a team reroll, onto any other entry")
		if [0, 1, 2].has(ms.face_index):
			dud = true
			assert_false(sk.can_spend(0), "a gun it lands on is dark: nothing to spend")
			break
	assert_true(dud, "a reroll may land on a spent kind: the die is not narrowed to its lit entries")
	ms.face_index = 3
	assert_true(sk.assign(0, sk.front[0]), "its equipment")
	assert_true(ms.assigned, "both kinds on cooldown: nothing to flip to, its die is done")
	sk.end_round()
	sk.start_round()
	assert_false(Effects.is_entry_disabled(u, 0) or Effects.is_entry_disabled(u, 3), "the next round nothing is dark")


func test_a_rapid_spend_sends_only_itself_onto_cooldown_on_the_relay() -> void:
	var gun := Face.attack(5, L, [], 1)
	var rapid := Face.attack(0, I, [K.EXPOSE, K.RAPID])
	var tool := Face.attack(0, I, [K.SHOCK])
	# The gun first, then the Rapid mark: its kind stays lit, so its equipment is still to spend.
	var sk := _relay_fight([gun, rapid, tool])
	var ms: Skirmish.MechState = sk.mechs[0]
	var u := ms.unit
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "the gun")
	ms.face_index = 1   # the flip drew among its two equipment: the Rapid one, for the read
	assert_true(sk.assign(0, sk.front[0]), "the Rapid mark")
	assert_true(Effects.is_entry_disabled(u, 1) and not Effects.is_entry_disabled(u, 2), "only itself dark: its kind not sent onto cooldown")
	assert_true(not ms.assigned and sk.can_reboot(0), "its die in play: it may still reboot")
	ms.face_index = 2
	assert_true(sk.assign(0, sk.front[0]), "the equipment, after the Rapid mark")
	assert_true(ms.assigned and not sk.can_reboot(0), "both kinds spent: its die is done, and so is the reboot")
	# The mark first: nothing on cooldown but itself, and both kinds still to spend.
	var s2 := _relay_fight([gun.duplicate_face(), rapid.duplicate_face(), tool.duplicate_face()])
	var m2: Skirmish.MechState = s2.mechs[0]
	m2.face_index = 1
	assert_true(s2.assign(0, s2.front[0]), "the Rapid mark first")
	assert_true(not m2.assigned and [0, 2].has(m2.face_index), "its die rolled onto another entry")
	m2.face_index = 0
	assert_true(s2.assign(0, s2.front[0]), "the gun")
	assert_eq(m2.face_index, 2, "the flip to the equipment still lit")
	assert_true(s2.can_reboot(0), "its die in play: its second may be the reboot")


func test_an_instant_spend_on_the_relay_leaves_its_kind_lit_and_pays_its_limit() -> void:
	var instant := Face.attack(0, I, [K.EXPOSE, K.INSTANT])
	instant.heat = 2   # its limiter (the rules: no chain is free)
	var sk := _relay_fight([Face.attack(5, L, [], 3), instant])
	var ms: Skirmish.MechState = sk.mechs[0]
	var u := ms.unit
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[0]), "the gun")
	assert_eq(ms.face_index, 1, "the flip to its one equipment")
	var spent := 0
	while ms.face_index == 1 and not ms.assigned and spent < 20:
		assert_true(sk.assign(0, sk.front[spent % 2]), "the Instant spend")
		spent += 1
		assert_false(Effects.is_entry_disabled(u, 1), "its kind never sent onto cooldown")
	assert_true(spent >= 1 and ms.face_index == 0 and not ms.assigned, "until its roll landed on the dark gun: %d spends" % spent)
	assert_eq(ms.heat, 3 + 2 * spent, "each paid its heat: the limit of a chain")

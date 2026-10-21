extends TestCase

## Numbers are in tens. Flat faces are used wherever the exact number matters; rolled faces
## are tested for bounds.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT
const K := Face.Keyword


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


func test_formation_fills_front_then_back() -> void:
	var sk := Skirmish.new(1, 3)   # three wide: the rank rules, not the default width
	sk.add_mech(_mech("A", Die.single(Face.attack(10))))
	sk.add_foes([_ghoul(), _ghoul(), _archer(), _ghoul(), _ghoul()])
	sk.begin()
	assert_eq(sk.field_foes().size(), 4, "four on the field: ranks hold, so the fourth ghoul waits")
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
	assert_eq(sk.reinforcements.size(), 1, "the spare ghoul waits in reinforcements")


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


func test_indirect_reaches_back_and_splashes_on_front() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, I)), 40)
	sk.add_mech(m)
	sk.add_foes([_ghoul(50), _archer(50)])
	sk.begin()
	sk.start_round()
	var t := sk.targets_for(0)
	assert_eq(t.size(), 2, "indirect sees both ranks")
	assert_true(sk.assign(0, sk.front[0]), "mortar the front")
	assert_eq(m.shield, 30, "splash cost ten shield")
	assert_eq(sk.front[0].hp, 30, "ghoul took 20")


func test_penetrate_hits_the_column() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.PENETRATE))))
	sk.add_foes([_ghoul(50), _archer(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "penetrate front 0")
	assert_eq(sk.front[0].hp, 20, "front took 30")
	assert_eq(sk.back[0].hp, 20, "back of the same column took 30")


func test_cleave_hits_neighbours() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(20, L, K.CLEAVE))))
	sk.add_foes([_ghoul(50), _ghoul(50), _ghoul(50)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[1]), "cleave the middle")
	for c in range(3):
		assert_eq(sk.front[c].hp, 30, "front %d took 20" % c)


func test_a_foe_aims_at_the_exposed_by_weight_and_the_old_rule_is_an_override() -> void:
	# A blow of 20: the tough machine's shield of 40 holds (weight 1); the weak one's shield of
	# 10 takes ten and lets ten through (the honest shield), and a shield about to fail is
	# exposure too (half of it), so the weak one weighs 16 and is picked sixteen times in
	# seventeen.
	var weak_picks := 0
	for seed_value in range(120):
		var sk := Skirmish.new(seed_value)
		var tough := _mech("Tough", Die.single(Face.shield(10)), 40, 100)
		var weak := _mech("Weak", Die.single(Face.shield(10)), 10, 100)
		sk.add_mech(tough)
		sk.add_mech(weak)
		sk.add_foes([_ghoul(30, 20)])
		sk.begin()
		sk.start_round()
		assert_eq(sk.front[0].aim_of(), "exposed", "the default sense")
		if sk.front[0].target == sk.mechs[1]:
			weak_picks += 1
	assert_true(weak_picks > 88 and weak_picks < 120, "the exposed machine draws most of the picks, never all: %d of 120" % weak_picks)
	var s0 := Skirmish.new(1)
	s0.add_mech(_mech("Bare", Die.single(Face.shield(10)), 0, 100))
	s0.add_mech(_mech("Thin", Die.single(Face.shield(10)), 10, 100))
	s0.add_mech(_mech("Thick", Die.single(Face.shield(10)), 40, 100))
	s0.add_foes([_ghoul(30, 20)])
	s0.begin()
	var g0: Foe = s0.front[0]
	assert_eq(s0.hull_reached(g0, s0.mechs[0]), 20, "bare: the whole blow reaches hull")
	assert_eq(s0.hull_reached(g0, s0.mechs[1]), 10, "a thin shield takes its ten, and the other ten pass")
	assert_eq(s0.shield_broken(g0, s0.mechs[1]), 10, "but the thin shield breaks")
	assert_eq(s0.shield_broken(g0, s0.mechs[2]), 0, "and the thick one holds")
	# The rule before 2 October, kept for the runner's comparison: every blow on the lowest shield.
	var sk := Skirmish.new(1)
	sk.targeting_override = "lowest"
	var tough := _mech("Tough", Die.single(Face.shield(10)), 40, 100)
	var weak := _mech("Weak", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(tough)
	sk.add_mech(weak)
	sk.add_foes([_ghoul(30, 20)])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(tough.shield, 40, "tough untouched")
	assert_eq(weak.shield, 0, "weak lost its shield")
	assert_eq(weak.hull, 90, "and the ten its shield could not take")
	# The pick is a commitment: a shield raised on the target does not move the blow.
	var s2 := Skirmish.new(3)
	s2.targeting_override = "lowest"
	var a := _mech("A", Die.single(Face.shield(30)), 0, 100)
	var b := _mech("B", Die.single(Face.shield(10)), 40, 100)
	s2.add_mech(a)
	s2.add_mech(b)
	s2.add_foes([_ghoul(30, 20)])
	s2.begin()
	s2.start_round()
	assert_eq(s2.front[0].target, s2.mechs[0], "the bare machine")
	assert_true(s2.assign(0, null), "it shields up")
	assert_eq(s2.front[0].target, s2.mechs[0], "and the foe still swings at it")


func test_the_other_aims_anything_heat_armed_and_fires_as_one() -> void:
	# Anything: uniform, so over many seeds both machines are picked and neither nearly always.
	var first := 0
	for seed_value in range(100):
		var sk := Skirmish.new(seed_value)
		sk.add_mech(_mech("A", Die.single(Face.shield(10)), 40, 100))
		sk.add_mech(_mech("B", Die.single(Face.shield(10)), 0, 100))
		var g := _ghoul(30, 20)
		g.aim = "anything"
		sk.add_foes([g])
		sk.begin()
		sk.start_round()
		if sk.front[0].target == sk.mechs[0]:
			first += 1
	assert_true(first > 30 and first < 70, "anything spreads the picks: %d of 100 on the shielded machine" % first)
	# Heat: the hottest machine, however bare the other.
	var s2 := Skirmish.new(1)
	var cold := _mech("Cold", Die.single(Face.shield(10)), 0, 100)
	var hot := _mech("Hot", Die.single(Face.shield(10)), 40, 100)
	s2.add_mech(cold)
	s2.add_mech(hot)
	var h := _ghoul(30, 20)
	h.aim = "heat"
	s2.add_foes([h])
	s2.begin()
	s2.mechs[1].heat = 30
	s2.start_round()
	assert_eq(s2.front[0].target, s2.mechs[1], "the hot machine draws the heat seeker")
	# Armed: a machine showing an intact weapon; a move may carry the aim on its own.
	var s3 := Skirmish.new(1)
	var gunner := _mech("Gunner", Die.single(Face.attack(10, L)), 40, 100)
	var medic := _mech("Medic", Die.single(Face.shield(10)), 0, 100)
	s3.add_mech(gunner)
	s3.add_mech(medic)
	var w := _ghoul(30, 20)
	w.actions = [Foe.basic_action()]
	w.actions[0]["aim"] = "armed"
	w.action = w.actions[0]
	s3.add_foes([w])
	s3.begin()
	s3.start_round()
	assert_eq(s3.front[0].aim_of(), "armed", "the move's own sense")
	assert_eq(s3.front[0].target, s3.mechs[0], "the machine showing a gun")
	var cracked := Face.attack(10, L)
	cracked.crack()
	var s4 := Skirmish.new(1)
	s4.add_mech(_mech("Broken", Die.single(cracked), 40, 100))
	s4.add_mech(_mech("Bare", Die.single(Face.shield(10)), 0, 100))
	var w2 := _ghoul(30, 20)
	w2.aim = "armed"
	s4.add_foes([w2])
	s4.begin()
	s4.start_round()
	assert_eq(s4.front[0].target, s4.mechs[1], "nobody armed: the exposed, and the bare machine is all of it")
	# Fires as one: every foe of the rank with the aim shares one pick; the front picks alone.
	var shared := 0
	var same_as_front := 0
	for seed_value in range(60):
		var s5 := Skirmish.new(seed_value, 3)
		s5.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 100))
		s5.add_mech(_mech("B", Die.single(Face.shield(10)), 0, 100))
		s5.add_mech(_mech("C", Die.single(Face.shield(10)), 0, 100))
		var casters: Array = [_archer(30, 10), _archer(30, 10), _archer(30, 10)]
		for c in casters:
			c.aim = "focus"
		s5.add_foes([_ghoul(30, 10), _ghoul(30, 10), _ghoul(30, 10)] + casters)
		s5.begin()
		s5.start_round()
		if s5.back[0].target == s5.back[1].target and s5.back[1].target == s5.back[2].target:
			shared += 1
		if s5.front[0].target == s5.front[1].target and s5.front[1].target == s5.front[2].target:
			same_as_front += 1
	assert_eq(shared, 60, "the back rank fires as one every time")
	assert_true(same_as_front < 30, "the front rank picks on its own: all three agree in %d of 60" % same_as_front)


func test_a_moves_condition_gates_it_and_a_special_never_fires_twice_running() -> void:
	var sk := Skirmish.new(1, 1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var g := _ghoul(100, 10)
	g.actions = [Foe.basic_action(), _special("defend", "regrow", {"value": 20, "when": "below_half"})]
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
	assert_eq(g.last_special, "regrow", "and it is on record")
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
	assert_eq(Foe.whens_of({"when": "machine_hot"}), ["machine_hot"], "a word reads as a list of one")
	# The other words, each on its own skirmish state.
	var s3 := Skirmish.new(3, 2)
	var hot := _mech("C", Die.single(Face.attack(10, L)), 40, 100)
	s3.add_mech(hot)
	var hc := _ghoul(100, 10)
	s3.add_foes([hc, _ghoul(30, 10), _ghoul(30, 10)])
	s3.begin()
	s3.start_round()
	assert_false(s3._when_holds(hc, {"when": "machine_hot"}), "nobody runs hot")
	s3.mechs[0].heat = Skirmish.HOT_HEAT
	assert_true(s3._when_holds(hc, {"when": "machine_hot"}), "now one does")
	assert_true(s3._when_holds(hc, {"when": "machine_armed"}), "a gun is showing")
	assert_true(s3._when_holds(hc, {"when": "rerolls_left"}), "the team has rerolls to lose")
	s3.reroll_debt = Skirmish.REROLLS_PER_ROUND
	assert_false(s3._when_holds(hc, {"when": "rerolls_left"}), "not when a roar has taken them all")
	assert_true(s3._when_holds(hc, {"when": "others_on_field"}), "another stands with it")
	assert_true(s3._when_holds(hc, {"when": "few_waiting"}), "one waits, which is few")
	s3.reinforcements.append(_ghoul(30, 10))
	s3.reinforcements.append(_ghoul(30, 10))
	assert_false(s3._when_holds(hc, {"when": "few_waiting"}), "three wait: not few")
	assert_true(s3._when_holds(hc, {"when": "few_waiting", "foe": "nobody"}), "none of a named foe waits")
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
	assert_eq(sk.front[1].kin, 3, "a reinforcement stepped in: four again")
	assert_eq(sk.front[1].damage(), 20, "and the swarm is back to 20")


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
	assert_eq(sk.mechs[0].heat, 60, "at the end of the round the gauge settles at its cap")
	assert_eq(m.hull, 80, "and the twenty over it burnt the hull (the ghoul's blow was blocked by the shield)")


func test_equipment_targets_are_the_components_to_set() -> void:
	var sk := Skirmish.new(1)
	var own := Face.shield(10)
	own.targets = Face.Target.SELF
	var give := Face.vent(10)
	give.targets = Face.Target.ALLY
	var a := _mech("A", Die.single(own), 40, 100)
	var b := _mech("B", Die.single(give), 40, 100)
	a.shield = 0
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(own.describe(), "shield 10 (self only)", "the restriction reads on the entry")
	assert_eq(sk.equipment_targets_for(sk.mechs[0], own).size(), 1, "a self-only shield offers one target")
	assert_false(sk.assign(0, sk.mechs[1]), "and refuses an ally")
	assert_true(sk.assign(0, null), "self is fine")
	assert_eq(a.shield, 10, "shielded")
	assert_false(sk.assign(1, null), "an allies-only vent refuses self")
	assert_true(sk.assign(1, sk.mechs[0]), "and takes the ally")
	var default_face := Face.shield(10)
	assert_eq(sk.equipment_targets_for(sk.mechs[0], default_face).size(), 2, "the default reaches everyone alive")
	assert_true(Face.attack(10, L).is_weapon() and not Face.attack(10, L).is_equipment(), "an attack is a weapon")
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


func test_burn_ticks_down() -> void:
	var sk := Skirmish.new(1)
	var torch := Face.attack(30, L, K.BURN)
	torch.burn = 3   # Burn 3 (Ryan, 18 October): the keyword's number, whatever the blow deals
	var m := _mech("A", Die.single(torch), 90, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	var g: Foe = sk.front[0]
	assert_eq(g.hp, 60, "took 30 on hit")
	assert_eq(g.burn_stacks(), 3, "three stacks of Burning: the Burn's number, not the blow's")
	assert_eq(torch.describe(), "30 burn 3", "the entry shows the number")
	sk.end_round()
	assert_eq(g.hp, 57, "burn ticked for 3: three stacks of one")
	assert_eq(g.burn_stacks(), 2, "one stack consumed")


func test_rolled_face_rolls_within_bounds() -> void:
	var lowest := 999
	var highest := 0
	for seed_value in range(1, 41):
		var sk := Skirmish.new(seed_value)
		sk.add_mech(_mech("A", Die.single(Face.attack(20, L, [], 0, 50))))
		sk.add_foes([_ghoul(200)])
		sk.begin()
		sk.start_round()
		sk.assign(0, sk.front[0])
		var dealt: int = 200 - sk.front[0].hp
		assert_true(dealt >= 20 and dealt <= 50, "roll %d within 20 to 50" % dealt)
		assert_eq(sk.last_roll["rolled"], dealt, "last_roll records the roll")
		assert_false(sk.last_roll["melee"], "no melee tag, so the screen kicks it back")
		lowest = mini(lowest, dealt)
		highest = maxi(highest, dealt)
	assert_true(highest - lowest >= 15, "forty seeds spread across the range (%d to %d)" % [lowest, highest])


## A blow that grows with its target's missing hull (10 October, the Sparrowhawk's rifle): flat,
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
	assert_false(gun.is_ranged(), "still flat")
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
func test_the_hopper_fills_from_a_claw_and_a_shot_fires_a_few_loads() -> void:
	# Ryan, 11 October: the Honey Badger's locked pair. A weapon that fills the hopper puts a
	# load in for each foe its blows reach; one that fires it takes up to its most a shot,
	# +5 a load, and spends them, so a full hopper feeds several shots rather than one.
	var sk := Skirmish.new(1)
	var claw := Face.from_dict({"kind": "attack", "reach": "direct", "power": 10, "keywords": ["cleave"], "fills_hopper": 1})
	var gun := Face.from_dict({"kind": "attack", "reach": "direct", "power": 20, "fires_hopper": 3, "power_per_load": 5})
	assert_eq(claw.describe(), "10 spread fills the hopper", "the claw says what it does")
	assert_eq(gun.describe(), "20 fires the hopper, +5 a load (3 a shot)", "and so does the gun")
	assert_eq(Face.from_dict(gun.to_dict()).describe(), gun.describe(), "both round-trip")
	var m := _mech("A", Die.of([claw, gun]), 500, 500)
	var ms := sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10), _ghoul(500, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	ms.face_index = 1
	assert_eq(sk.shown_number(ms, gun), [20, 20] as Array[int], "an empty hopper adds nothing")
	ms.face_index = 0
	assert_true(sk.assign(0, sk.front[1]), "the claw on the middle foe")
	assert_eq(Effects.stacks_of(m, "hopper"), 3, "three foes reached: three loads")
	assert_true("\n".join(sk.log).contains("fills the hopper: +3 (3)"), "the log says so")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "hopper"), 3, "the loads keep through the round")
	sk.start_round()
	Effects.stack(m, Effects.STATUS["hopper"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	ms.face_index = 1
	assert_eq(sk.shown_number(ms, gun), [35, 35] as Array[int], "five loads, but three a shot: 20 and 15")
	var hp: int = sk.front[0].hp
	assert_true(sk.assign(0, sk.front[0]), "the shot")
	assert_eq(sk.front[0].hp, hp - 35, "twenty and three loads")
	assert_eq(Effects.stacks_of(m, "hopper"), 2, "three spent, two left for the next shot")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_eq(sk.shown_number(ms, gun), [30, 30] as Array[int], "the next shot fires the two left")
	# A cracked component keeps its unique rule for now (Ryan, 11 October: hold until the
	# impact is measured); only its keywords go.
	var cracked := claw.duplicate_face()
	cracked.crack()
	assert_eq(cracked.fills_hopper, 1, "a cracked claw still fills the hopper")
	assert_false(cracked.has(Face.Keyword.CLEAVE), "but loses its spread")


func test_the_bot_fills_the_hopper_before_it_fires_it() -> void:
	# A claw that reaches three foes is worth its loads to a machine that can fire them.
	var sk := Skirmish.new(1)
	var claw := Face.from_dict({"kind": "attack", "reach": "direct", "power": 10, "keywords": ["cleave"], "fills_hopper": 1})
	var gun := Face.from_dict({"kind": "attack", "reach": "direct", "power": 20, "fires_hopper": 3, "power_per_load": 5})
	var m := _mech("A", Die.of([claw, gun]), 500, 500)
	var ms := sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10), _ghoul(500, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY, 1)
	var plain := Face.from_dict({"kind": "attack", "reach": "direct", "power": 10, "keywords": ["cleave"]})
	assert_true(pol.attack_score(sk, ms, claw, sk.front[1]) > pol.attack_score(sk, ms, plain, sk.front[1]), "the loads are worth something")
	assert_eq(pol.hopper_fill_score(sk, ms, claw, sk.front[1]), 3.0 * 5.0 * Policy.HOPPER_WEIGHT, "three loads at five, discounted")
	Effects.stack(m, Effects.STATUS["hopper"], Effects.SKIRMISH, "test", 6, Effects.DECAY_NONE)
	assert_eq(pol.hopper_fill_score(sk, ms, claw, sk.front[1]), 0.0, "two shots' worth waiting already: no more value")


func test_a_bracing_entry_braces_its_owner_until_the_rounds_end() -> void:
	# Ryan, 12 October: the Breaching Plow braces the Boar behind its blade, in place of the
	# Glacis. Spending a bracing entry Braces its owner, the stacks it says, until the round's
	# end: the armour stands through the enemy's turn and is gone when the next round opens.
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
	assert_eq(Effects.stacks_of(m, "braced"), 0, "and it is gone at the round's end")
	var cracked := plow.duplicate_face()
	cracked.crack()
	assert_eq(cracked.braces, 10, "a crack takes keywords only, so a cracked plow still braces")


func test_braced_lasts_one_turn_from_every_source() -> void:
	# Ryan, 12 October: a defensive buff that lingered, a stack fading a round, would stack
	# into a wall. A passive's Braced (the Phase Conjugator's) goes at the round's end whole,
	# like a buff's.
	var m := _mech("A", Die.single(Face.attack(10)))
	m.grant_passive({"id": "brace_on_round", "name": "Brace", "description": "",
		"effects": [{"trigger": "on_round_start", "effect": "stack_status", "value": "braced"}]})
	Effects.fire(m, "on_round_start")
	Effects.fire(m, "on_round_start")
	assert_eq(Effects.stacks_of(m, "braced"), 2, "two stacks from the passive")
	Effects.tick(m)
	assert_eq(Effects.stacks_of(m, "braced"), 0, "every stack goes at the tick, none lingers")


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
	var gun := Face.attack(10, L, [], 0, 20)
	var rifle := Face.attack(10)
	rifle.power_per_missing = 5
	var cannon := Face.from_dict({"kind": "attack", "reach": "direct", "power": 20, "vents_all": true, "power_per_heat": 10})
	var m := _mech("A", Die.of([gun, rifle, cannon]), 40, 100)
	m.grant_passive({"id": "db", "name": "Databank", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 5, "when": "rolled"}]})
	sk.add_mech(m)
	var hard := _ghoul(200)
	hard.armour = 5
	hard.hp = 120   # 80 missing: four steps of 20
	sk.add_foes([hard])
	sk.begin()
	sk.start_round()
	var ms := sk.mechs[0]
	assert_eq(sk.shown_number(ms, gun), [15, 25] as Array[int], "a rolled range with the Databank's 5 on both ends")
	assert_eq(sk.shown_number_text(ms, gun), "15–25", "printed as the range")
	assert_eq(sk.shown_number_text(ms, rifle), "10", "the rifle with nobody under it")
	assert_eq(sk.shown_number_text(ms, rifle, hard), "25", "over the wounded foe: 10, +20 for its missing hull, -5 armour")
	assert_eq(sk.shown_number_text(ms, gun, hard), "10–20", "armour comes off the range too")
	ms.heat = 30
	assert_eq(sk.shown_number_text(ms, cannon), "50", "the Afterburner shows what its heat will add: 20, +10 a 10 heat")
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.SKIRMISH, "test", 5)   # five stacks, a point each (18 October)
	assert_eq(sk.shown_number_text(ms, rifle), "15", "a buff on the machine shows on the face")
	assert_eq(sk.shown_number_text(ms, rifle, hard), "30", "and over the foe")
	ms.face_index = 1
	sk.assign(0, hard)
	assert_eq(hard.hp, 90, "and the spend deals exactly the 30 it showed")


## No crits (10 October): a raised ceiling (add_ceiling, the Muzzle Velocity Booster) widens a
## rolled range before the roll, the face shows it, and a flat face gets nothing.
func test_a_raised_ceiling_widens_a_rolled_range_and_leaves_a_flat_one() -> void:
	var gun := Face.attack(10, L, [], 0, 20)
	var beam := Face.attack(15, L)
	var m := _mech("A", Die.of([gun, beam]))
	m.grant_passive({"id": "mv", "name": "MV", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_ceiling", "value": 10}]})
	var shown := Effects.effective_face(m, gun)
	assert_eq([shown.power, shown.power_max], [10, 30], "the rolled face shows 10 to 30")
	assert_eq(gun.power_max, 20, "the die keeps the real one")
	assert_eq(Effects.effective_face(m, beam).power_max, 15, "a flat face has no range to widen")
	# The floor (add_floor, the Tactical Databank, 10 October) is the other way to push it.
	m.grant_passive({"id": "db", "name": "DB", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_floor", "value": 5}]})
	shown = Effects.effective_face(m, gun)
	assert_eq([shown.power, shown.power_max], [15, 30], "floor and ceiling together: 15 to 30")
	var narrow := Face.attack(5, L, [], 0, 10)
	var n := _mech("N", Die.single(narrow))
	n.grant_passive({"id": "db", "name": "DB", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_floor", "value": 10}]})
	assert_eq([Effects.effective_face(n, narrow).power, Effects.effective_face(n, narrow).power_max], [10, 10], "never past the top: a narrow range ends flat")
	assert_eq(Effects.effective_face(n, beam), beam, "a flat face is untouched")
	assert_eq(Effects.explain(n, beam), [], "and its row says nothing")
	var high := 0
	for seed in range(40):
		var sk := Skirmish.new(seed)
		var u := _mech("A", Die.single(Face.attack(10, L, [], 0, 20)))
		u.grant_passive({"id": "mv", "name": "MV", "description": "", "effects": [{"trigger": "on_attack", "effect": "add_ceiling", "value": 10}]})
		sk.add_mech(u)
		sk.add_foes([_ghoul(200)])
		sk.begin()
		sk.start_round()
		sk.assign(0, sk.front[0])
		var dealt: int = 200 - sk.front[0].hp
		assert_true(dealt >= 10 and dealt <= 30, "every roll between 10 and 30: %d" % dealt)
		if dealt > 20:
			high += 1
	assert_true(high > 0, "and some land above the old ceiling")


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


func test_horde_keeps_coming() -> void:
	var sk := Skirmish.new(1, 3)   # three wide: the rank rules, not the default width
	sk.add_mech(_mech("A", Die.single(Face.attack(90, L))))
	var foes: Array = []
	for i in range(8):
		foes.append(_ghoul(30))
	sk.add_foes(foes)
	sk.begin()
	# Ranks hold: front foes fill the three front slots and the rest wait as reinforcements.
	assert_eq(sk.field_foes().size(), 3, "three on the field")
	assert_eq(sk.reinforcements.size(), 5, "five in reserve")
	sk.start_round()
	sk.assign(0, sk.front[1])
	sk.end_round()
	assert_eq(sk.field_foes().size(), 3, "the gap is refilled at the reinforcement phase")
	assert_eq(sk.reinforcements.size(), 4, "four left in reserve")
	assert_true(sk.front[1] != null, "a reinforcement stepped into the gap")


func test_withdraw_window() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(90, 10)])
	sk.begin()
	assert_true(sk.can_withdraw(), "open even before the first roll: the price is the same either way")
	sk.start_round()
	assert_true(sk.can_withdraw(), "open at the start of round one")
	sk.assign(0, sk.front[0])
	assert_true(sk.can_withdraw(), "still open after spending: the price is the enemy turn, not the timing")
	sk.end_round()
	assert_true(sk.can_withdraw(), "between rounds")
	sk.start_round()
	assert_true(sk.withdraw(), "withdrew in round two")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "outcome withdrawn")
	assert_eq(m.hull, 80, "and the enemy struck on the way out, both rounds: no leapfrogging out unscathed")

func test_rerolls_are_limited_and_work_after_attacking() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L))))
	sk.add_mech(_mech("B", Loadouts.gunner_die()))
	sk.add_foes([_ghoul(90)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "A attacks first")
	assert_true(sk.reroll([1]), "then B rerolls: attack-then-reroll is allowed")
	assert_true(sk.reroll([1]), "second reroll")
	assert_true(sk.reroll([1]), "third reroll")
	assert_false(sk.reroll([1]), "fourth refused")


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


func _cracked_count(d: Die) -> int:
	var n := 0
	for f in d.faces:
		if f.cracked or f.kind == Face.Kind.BLANK:
			n += 1
	return n


func test_big_hull_hits_always_injure_a_face() -> void:
	for seed_value in range(1, 31):
		var sk := Skirmish.new(seed_value)
		var d := Die.of([Face.attack(10, L, K.CLEAVE), Face.attack(10, L, K.PENETRATE)])
		var m := _mech("A", d, 0, 100)
		sk.add_mech(m)
		sk.add_foes([Foe.make("brute", 90, 50)])
		sk.begin()
		sk.start_round()
		sk.end_round()
		assert_eq(m.hull, 50, "the hit reached the hull")
		assert_eq(_cracked_count(d), 1, "a half-hull hit cracks one face, no coin toss (seed %d)" % seed_value)


func test_injury_rolls_the_die_and_a_destroyed_component_takes_the_blow() -> void:
	var sk := Skirmish.new(5)
	var d := Die.of([Face.blank(), Face.blank(), Face.attack(10, L, K.CLEAVE)])
	var m := _mech("A", d, 0, 100)
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	var misses := 0
	var hits := 0
	for i in range(60):
		var before := sk.log.size()
		sk.apply_injury(sk.mechs[0])
		if str(sk.log[sk.log.size() - 1]).contains("nothing left to break"):
			misses += 1
		else:
			hits += 1
		assert_eq(sk.log.size(), before + 1, "every injury logs one line")
	assert_true(misses > hits, "two destroyed faces of three absorb most blows (%d misses, %d hits)" % [misses, hits])
	assert_eq(d.faces[2].kind, Face.Kind.BLANK, "the live face was cracked then destroyed by the hits")
	assert_eq(m.damaged_component_count(), 1, "blows on already destroyed faces add no damaged components")


func test_small_hits_and_shielded_hits_never_crack() -> void:
	for seed_value in range(1, 11):
		var sk := Skirmish.new(seed_value)
		var d := Die.of([Face.attack(10, L, K.CLEAVE)])
		var m := _mech("A", d, 0, 100)
		sk.add_mech(m)
		sk.add_foes([Foe.make("revenant", 90, 20)])
		sk.begin()
		sk.start_round()
		sk.end_round()
		assert_eq(_cracked_count(d), 0, "a hit under a quarter of hull never cracks")
	for seed_value in range(1, 11):
		var sk := Skirmish.new(seed_value)
		var d := Die.of([Face.attack(10, L, K.CLEAVE)])
		var m := _mech("A", d, 60, 100)
		sk.add_mech(m)
		sk.add_foes([Foe.make("brute", 90, 50)])
		sk.begin()
		sk.start_round()
		sk.end_round()
		assert_eq(_cracked_count(d), 0, "a hit absorbed by shield never cracks")


func test_injury_cracks_then_destroys_and_persists_until_repaired() -> void:
	var sk := Skirmish.new(3)
	var d := Die.single(Face.attack(30, L, [K.CLEAVE, K.BURN], 10, 50))
	var m := _mech("A", d, 0, 100)
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.apply_injury(sk.mechs[0])
	var f := d.faces[0]
	assert_true(f.cracked, "first injury cracks the face")
	assert_eq(f.kind, Face.Kind.ATTACK, "it still attacks")
	assert_eq(f.power, 30, "with its basic damage")
	assert_true(f.keywords.is_empty(), "keywords gone")
	assert_eq(f.power_max, 50, "its range kept (18 September: a crack takes only the keywords)")
	assert_true(f.describe().ends_with("(cracked)"), "described as cracked")
	assert_eq(m.damaged_component_count(), 1, "one damaged component on the unit")
	sk.apply_injury(sk.mechs[0])
	assert_eq(d.faces[0].kind, Face.Kind.BLANK, "second injury destroys it")
	assert_eq(m.damaged_component_count(), 1, "still one component, now destroyed")
	sk.apply_injury(sk.mechs[0])
	assert_eq(m.damaged_component_count(), 1, "a third injury finds nothing left to break")
	sk.end_round()
	sk.start_round()
	sk.withdraw()
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
	assert_true(d.faces[0].has(K.CLEAVE) and d.faces[0].has(K.BURN), "with its keywords")
	assert_false(d.faces[0].cracked, "not cracked any more")
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
	sk.mechs[0].assigned = false
	assert_true(sk.assign(0, sk.mechs[1]), "shield again with room")
	assert_eq(taker.shield, 30, "ally gained 30")


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
	assert_true(fc["breaks_shield"], "55 incoming breaks a 20 shield")
	assert_eq(fc["shield_after"], 0, "shield gone")
	assert_eq(fc["hull_after"], 65, "the thirty stands left and strikes first: the shield takes twenty and ten pass; the twenty-five lands on bare hull")
	assert_true(fc["component_risk"], "a 25-point bare-hull hit on 100 hull injures")
	assert_false(fc["destroyed"], "still standing")
	sk._suppress(sk.front[0])
	fc = sk.forecast(ms)
	assert_eq(fc["incoming"], 25, "a suppressed foe does not count")
	sk.front[1].hp = 0
	fc = sk.forecast(ms)
	assert_eq(fc["incoming"], 0, "a dead foe does not count")
	assert_false(fc["breaks_shield"], "nothing incoming")


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
	var fc := sk.forecast(ms)
	assert_eq(fc["overheat"], 10, "a 40-heat face on a 30 cap overheats by 10")
	assert_eq(fc["heat_after"], 30, "heat capped")
	assert_true(fc["destroyed"], "25 through plus 10 overheat beats 20 hull")
	sk.assign(0, sk.front[0])
	fc = sk.forecast(ms)
	assert_eq(sk.pending_heat(ms), 0, "a spent face adds no more heat")
	assert_eq(ms.heat, 40, "the heat is on the gauge, past the cap")
	assert_eq(m.hull, 20, "nothing burnt yet")
	assert_eq(fc["overheat"], 10, "the burn is still coming at the end of the turn")
	assert_eq(sk.forecast(ms, false)["overheat"], 10, "with or without the die counted: it is spent")


func test_forecast_ignores_foes_that_burn_to_death_first() -> void:
	var sk := Skirmish.new(3)
	var m := Unit.mech(1, "A", Vector2i.ZERO)
	m.die = Die.single(Face.attack(10))
	var ms := sk.add_mech(m)
	sk.add_foes([Foe.make("a", 10, 25)])
	sk.begin()
	sk.start_round()
	Effects.stack(sk.front[0], Effects.STATUS["burning"], Effects.SKIRMISH, "test", 10)   # ten stacks, a point each (18 October)
	assert_eq(sk.forecast(ms)["incoming"], 0, "ten stacks of one kill a ten-hp foe before it strikes")


## A reroll skips only the entry showing; a copy of it may come up, at the odds its copies
## give it (Ryan, 15 October). Skipping copies too was abusable: a die of one key entry and
## copies of one filler sent every reroll from a filler onto the key.
func test_reroll_lands_on_any_other_face_a_copy_included() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var die := Die.of([
		Face.attack(20, Face.Reach.DIRECT, [], 0, 40),
		Face.attack(20, Face.Reach.DIRECT, [], 0, 40),
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
		for id in ["badger", "clydesdale", "sparrowhawk"]:
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
	sk.add_mech(_mech("A", Die.single(Face.attack(20, L, K.CLEAVE))))
	# Ranks hold: six front ghouls fill four front slots and two wait; four archers take the back.
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
	assert_eq(sk.reinforcements.size(), 2, "two wait in reserve")
	sk.start_round()
	assert_eq(sk.targets_for(0).size(), 4, "every front foe is a line target")
	assert_true(sk.assign(0, sk.front[3]), "cleave the right edge")
	assert_eq(sk.front[3].hp, 30, "edge took 20")
	assert_eq(sk.front[2].hp, 30, "its one neighbour took 20")
	assert_eq(sk.front[1].hp, 50, "the far column is untouched")
	var three := Skirmish.new(1)
	assert_eq(three.columns, Skirmish.DEFAULT_COLUMNS, "three by default")


func test_no_destroy_passive_holds_a_cracked_component() -> void:
	var sk := Skirmish.new(3)
	var d := Die.single(Face.attack(30, L, [K.CLEAVE], 0, 50))
	var m := _mech("A", d, 0, 100)
	m.grant_passive({"id": "hold", "name": "Hold", "description": "", "effects": [{"trigger": "on_injury", "effect": "no_destroy", "value": 1}]})
	sk.add_mech(m)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.apply_injury(sk.mechs[0])
	assert_true(d.faces[0].cracked, "the first injury still cracks")
	sk.apply_injury(sk.mechs[0])
	assert_eq(d.faces[0].kind, Face.Kind.ATTACK, "the second does not destroy it")
	assert_true(d.faces[0].cracked, "it stays cracked")
	assert_true(str(sk.log[sk.log.size() - 1]).contains("holds"), "and the log says it held")
	assert_eq(m.damaged_component_count(), 1, "one damaged component")


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


func test_cracked_condition_narrows_a_passive_to_cracked_components() -> void:
	var bonus := {"id": "scars", "name": "Scars", "description": "", "effects": [{"trigger": "on_attack", "when": "component_cracked", "effect": "add_damage", "value": 10}]}
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive(bonus)
	var f := Face.attack(20, L)
	assert_eq(Effects.attack(u, f, 20, 0)["damage"], 20, "an intact component gets nothing")
	f.crack()
	assert_eq(Effects.attack(u, f, 20, 0)["damage"], 30, "a cracked one hits harder")
	assert_eq(Effects.attack(u, null, 20, 0)["damage"], 20, "no component in hand, no bonus")


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
	assert_eq(m.recharge_shield(100), 2, "the field rate is capped at max")
	assert_eq(m.shield, 40, "at max")


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
	assert_eq(m.damaged_component_count(), 1, "and the forty that reached the hull injure: an injury counts what reaches it")
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
	assert_true(fc["component_risk"], "and that it can injure")
	sk.end_round()
	assert_eq(m.shield, 0, "first blow spends the shield")
	assert_eq(m.hull, 50, "twenty past it, and the second blow's thirty")


func test_breach_ignores_the_shield_and_can_injure() -> void:
	# A breach ignores the shield outright, and the shield stands (Ryan, 14 October).
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 10, 100)
	sk.add_mech(m)
	var boss := Foe.make("maw", 200, 50)
	boss.actions[0]["keywords"] = ["breach"]
	sk.add_foes([boss])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.shield, 10, "the shield stands")
	assert_eq(m.hull, 50, "the whole fifty reached the hull")
	assert_eq(m.damaged_component_count(), 1, "fifty of a hundred hull in one blow injures")
	assert_true(sk.turn_events.size() == 1 and not sk.turn_events[0]["broke_shield"] and sk.turn_events[0]["injured"], "the turn event says the shield held and a component was hit")
	assert_true(str(sk.log).contains("maw breaches A: hull -50"), "the log says it breached")
	# Armour comes off a breach like any blow that reaches the hull (Ryan, 11 October).
	var s2 := Skirmish.new(1)
	var plated := _mech("B", Die.single(Face.shield(10)), 10, 100)
	plated.armour = 15
	s2.add_mech(plated)
	var maw := Foe.make("maw", 200, 50)
	maw.actions[0]["keywords"] = ["breach"]
	s2.add_foes([maw])
	s2.begin()
	s2.start_round()
	assert_eq(s2.forecast(s2.mechs[0], false)["hull_after"], 65, "the forecast takes the armour off the breach")
	s2.end_round()
	assert_eq(plated.shield, 10, "the shield took nothing")
	assert_eq(plated.hull, 65, "fifty breached, fifteen of it stopped by the armour")


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
	var gun := Face.attack(10, L, K.BURN, 20)
	gun.strikes = 3
	sk.add_mech(_mech("A", Die.single(gun)))
	sk.add_foes([_ghoul(200)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 170, "three blows of ten")
	assert_eq(sk.front[0].burn_stacks(), 3, "each blow procs burn on its own: three stacks, where one thirty would give two")
	assert_eq(sk.mechs[0].heat, 20, "heat is paid once per use, not per strike")
	assert_eq(sk.last_roll["final"], 30, "the screen sees the total")
	assert_eq(gun.describe(), "10 ×3 burn 1 (+20 heat)", "described as a burst")
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


func test_static_set_reach_sends_a_cracked_component_to_direct() -> void:
	var sk := Skirmish.new(3)
	var mortar := Face.attack(30, I)
	var m := _mech("A", Die.single(mortar), 0, 100)
	m.grant_passive({"id": "rs", "name": "RS", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.1, "when": "reach_direct"},
		{"trigger": "static", "effect": "set_reach", "value": "direct", "when": "component_cracked"}]})
	sk.add_mech(m)
	sk.add_foes([_ghoul(200), _archer(200)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.targets_for(0).size(), 2, "an intact mortar reaches both ranks")
	sk.apply_injury(sk.mechs[0])
	var f := sk.mechs[0].face()
	assert_true(f.cracked and f.reach == Face.Reach.INDIRECT, "cracked; the component itself is untouched")
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
	m.repair_faces()
	assert_eq(m.die.faces[0].reach, Face.Reach.INDIRECT, "repair restores the original mortar")


func test_chain_repeats_on_a_kill() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.CHAIN, 10))))
	sk.add_foes([_ghoul(30), _ghoul(30), _ghoul(90)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0], null, "the first ghoul dies and its slot clears")
	assert_eq(sk.front[1], null, "the chain kills the second")
	assert_eq(sk.front[2].hp, 60, "and lands once on the third, which survives, so it stops")
	assert_eq(sk.mechs[0].heat, 30, "heat is paid on every link, three here: that is the risk of a chain")


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
	# weapons run twice as hot (the Sparrowhawk's double; a synthetic passive here) doubles
	# Scorched's extra as well, and its die says so (Ryan asked, 13 October).
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, [], 10)), 0, 200)
	m.heat_max = 100
	m.cooling = 0
	Effects.grant(m, Effects.make({"id": "hot", "name": "Hot", "description": "", "effects": [{"trigger": "on_attack", "effect": "multiply_heat", "value": 2}]}, Effects.BATTLE, "test"))
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(sk.pending_heat(sk.mechs[0]), 20, "the double alone")
	Effects.stack(m, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe:x", 1, Effects.DECAY_TURN_ALL)
	assert_eq(sk.pending_heat(sk.mechs[0]), 30, "a stack of Scorched is doubled with the rest: (10 + 5) × 2")
	assert_eq(sk.shown_face(sk.mechs[0], sk.mechs[0].face()).heat, 30, "and the die shows it")


func test_statuses_stack_tick_and_decay_on_both_sides() -> void:
	# A foe's fire on a machine (Ryan, 13 October: Burn and Scorch). A scorching blow leaves a
	# stack of Scorched: no heat now, the next weapon fired runs five hotter, and every stack
	# goes at the end of the player's turn. A burning blow leaves a stack of Burning: five heat
	# at the end of the next player's turn, before the overheat, then the stack goes.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, [], 10)), 0, 200)
	m.heat_max = 100
	m.cooling = 0
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
	assert_eq(sk.pending_heat(sk.mechs[0]), 15, "the weapon runs five hotter")
	assert_eq(sk.shown_face(sk.mechs[0], sk.mechs[0].face()).heat, 15, "and the die says so")
	assert_eq(sk.mechs[0].face().heat, 10, "while the component keeps its own")
	sk.assign(0, sk.front[0])
	assert_eq(sk.mechs[0].heat, 15, "and lands that hot")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "scorched"), 1, "the turn's end took the stack; the next blow left another")
	Effects.stack(m, Effects.STATUS["scorched"], Effects.SKIRMISH, "test", 2, Effects.DECAY_TURN_ALL)
	assert_eq(Effects.stacks_of(m, "scorched"), 3, "three blows' worth")
	Effects.turn_tick(m)
	assert_eq(Effects.stacks_of(m, "scorched"), 0, "every stack goes at the turn's end, so Scorched never piles up")
	var s2 := Skirmish.new(2)
	var n := _mech("B", Die.single(Face.shield(10)), 0, 200)
	n.heat_max = 100
	n.cooling = 0
	s2.add_mech(n)
	var burner := Foe.make("hellhound", 900, 10)
	burner.actions[0]["keywords"] = ["burn"]
	s2.add_foes([burner])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq(s2.mechs[0].heat, 0, "a burn adds no heat at once")
	assert_eq(Effects.stacks_of(n, "burning_mech"), 1, "a stack of Burning")
	s2.start_round()
	assert_eq(s2.forecast(s2.mechs[0], false)["heat_end"], 5, "the forecast counts the tick at the turn's end")
	s2.end_round()
	assert_eq(s2.mechs[0].heat, 5, "five heat at the end of the turn")
	assert_eq(Effects.stacks_of(n, "burning_mech"), 1, "that stack went; the next blow left another")
	Effects.stack(n, Effects.STATUS["burning_mech"], Effects.SKIRMISH, "test", 2, Effects.DECAY_TURN)
	assert_eq(Effects.stacks_of(n, "burning_mech"), 3, "stacks add up")
	assert_eq(int(Effects.tick_preview(n, true)["heat"]), 15, "five per stack, at the turn's end")
	assert_eq(int(Effects.tick_preview(n)["heat"]), 0, "and never at the round's")
	s2.withdraw()
	assert_eq(Effects.stacks_of(n, "burning_mech"), 0, "skirmish-scoped statuses end with the skirmish")


func test_suppress_skips_the_action_and_numbs() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	sk.add_mech(m)
	var boss := Foe.make("maw", 200, 30)
	boss.size = 2
	sk.add_foes([boss])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_true(boss.is_suppressed(), "suppressed this round")
	assert_eq(Effects.stacks_of(boss, "numbed"), 3, "a massive foe gains three Numbed stacks")
	assert_eq(boss.resist_total(), 30, "which is 30% to shrug the next one off")
	sk.end_round()
	assert_eq(m.hull, 100, "it skipped")
	assert_false(boss.is_suppressed(), "the suppression ran out with the round")
	assert_eq(Effects.stacks_of(boss, "numbed"), 2, "Numbed lost a stack at the foe's turn, suppressed or not")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 70, "next round it strikes")
	assert_eq(Effects.stacks_of(boss, "numbed"), 1, "and loses another")
	sk.start_round()
	sk.end_round()
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(boss, "numbed"), 0, "gone two turns later")


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
	assert_eq(Effects.stacks_of(g, "numbed"), 2, "and numbed for it")
	sk.assign(1, g)
	assert_eq(Effects.stacks_of(g, "numbed"), 2, "the second suppress numbs it no further")
	var grants := 0
	for m in g.modifiers:
		if m.id == "suppressed":
			grants += 1
	assert_eq(grants, 1, "and leaves one Suppressed, never two")
	assert_true("\n".join(sk.log).contains("already suppressed"), "the log says the spend was wasted")
	assert_false(sk._suppress(g), "a Paradox's trip on it is a suppress like any other: wasted")
	assert_eq(Effects.stacks_of(g, "numbed"), 2, "and numbs it no further")
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "numbed"), 1, "a stack faded at its turn")
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
	# The engine's own: Shocked, Suppressed and Retaliate renew, Overcharged adds.
	assert_eq(Effects.status_stacking(Effects.STATUS["shocked"]), "renew", "Shocked renews, one stack")
	assert_eq(Effects.status_stacking(Effects.STATUS["suppressed"]), "renew", "Suppressed renews")
	assert_eq(Effects.status_stacking(Effects.STATUS["retaliate"]), "renew", "Retaliate renews")
	assert_eq(Effects.status_stacking(Effects.STATUS["overcharged"]), "add", "Overcharged adds")


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
	var gun := Face.attack(10, L, K.RAPID)
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
	assert_eq(sk.rerolls_left, 3, "the reroll was free")
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


func test_a_foe_disable_switches_off_the_showing_entry_through_the_next_turn() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L)), 0, 200)
	sk.add_mech(m)
	var jammer := Foe.make("cockatrice", 90, 10)
	jammer.actions[0]["keywords"] = ["disable"]
	sk.add_foes([jammer])
	sk.begin()
	sk.start_round()
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].face().describe(), "disabled", "the entry comes up blank on the mech's next turn")
	assert_true(sk.targets_for(0).is_empty(), "no targets from a blank")
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 90, "spending a blank does nothing")
	sk._suppress(sk.front[0])   # or it would disable again
	sk.end_round()
	sk.start_round()
	assert_eq(sk.mechs[0].face().describe(), "30", "and it is back the turn after")


func test_the_die_screen_explains_what_applies_to_a_component() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	var mortar := Face.attack(30, I)
	u.grant_passive({"id": "rs", "name": "Reinforced Skeleton", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.1, "when": "reach_direct"},
		{"trigger": "static", "effect": "set_reach", "value": "direct", "when": "component_cracked"}]})
	assert_true(Effects.explain(u, mortar).is_empty(), "nothing applies to an intact mortar")
	mortar.crack()
	var notes := Effects.explain(u, mortar)
	assert_eq(notes.size(), 2, "cracked: the reach change and the direct bonus both apply")
	assert_true(notes[0].contains("reach becomes direct (Reinforced Skeleton)") or notes[1].contains("reach becomes direct (Reinforced Skeleton)"), "the reach change names its source")
	assert_eq(Effects.effect_text({"trigger": "on_injury", "effect": "no_destroy", "value": 1}), "on an injury: cracked components are never destroyed", "effects read as sentences")


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
	# at the end of the player's turn, before the enemy acts. Ryan, 13 October: a machine's
	# Burning adds its heat there too, before the overheat, so it burns in the same turn.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, [], 30)), 40, 100)
	m.heat_max = 60
	m.cooling = 10
	var ms := sk.add_mech(m)
	sk.add_foes([_ghoul(30, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(ms.heat, 0, "nothing to cool at the start")
	assert_eq(sk.forecast(ms)["heat_after"], 30, "the face's heat, nothing cooling it this round")
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
	assert_eq(sk.forecast(ms, false)["overheat"], 0, "the die's heat is not counted unless asked")
	assert_eq(sk.forecast(ms, true)["overheat"], 20, "asked (the die is dragged): 50 plus 30 on a 60 cap")
	sk.assign(0, sk.front[0])
	assert_eq(ms.heat, 80, "80 on the gauge, past the cap")
	assert_eq(m.hull, 100, "nothing burnt yet")
	assert_eq(sk.forecast(ms)["overheat"], 20, "the forecast warns of the twenty to come")
	# Burning ticks at the end of the player's turn, before the overheat: its heat burns with it.
	Effects.stack(m, Effects.STATUS["burning_mech"], Effects.SKIRMISH, "test", 2, Effects.DECAY_TURN)
	assert_eq(sk.forecast(ms)["overheat"], 30, "the tick's ten burns with the twenty already over")
	assert_eq(sk.forecast(ms)["heat_after"], 60, "and the gauge settles at its cap")
	sk.end_round()
	assert_eq(m.hull, 70, "thirty burns as the turn ends")
	assert_eq(ms.heat, 60, "settled at the cap")
	assert_eq(Effects.stacks_of(m, "burning_mech"), 1, "one stack ticked away")
	sk.start_round()
	assert_eq(ms.heat, 50, "then cooled by 10")
	assert_eq(m.hull, 70, "nothing burns at the round's start")
	# Cooling is a stat like any other: a passive can raise it, and it never goes below zero.
	m.grant_passive({"id": "fins", "name": "Fins", "description": "", "effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 15}]}, "fins")
	assert_eq(m.cooling, 25, "base plus the passive")
	ms.heat = 5
	sk.end_round()   # the last stack ticks: five more
	assert_eq(ms.heat, 10, "the remaining stack ticked at the end of the turn")
	sk.start_round()
	assert_eq(ms.heat, 0, "never below zero")
	assert_true(sk.log[sk.log.size() - 1].begins_with("cooling: A -10"), "logged as what was actually shed: %s" % sk.log[sk.log.size() - 1])


func test_forecast_counts_burning_in_the_turn_it_lands() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 100)
	m.heat_max = 60
	m.cooling = 0
	var ms := sk.add_mech(m)
	var demon := _ghoul(30, 10)
	demon.actions[0]["keywords"] = ["burn"]
	demon.actions[0]["strikes"] = 2
	demon.action = demon.actions[0]
	sk.add_foes([demon])
	sk.begin()
	sk.start_round()
	ms.heat = 55
	var fc := sk.forecast(ms)
	assert_eq(fc["heat_after"], 55, "the foes' fire adds no heat this round")
	assert_eq(fc["overheat"], 0, "and nothing burns this turn")
	sk.end_round()
	assert_eq(ms.heat, 55, "as forecast")
	assert_eq(Effects.stacks_of(m, "burning_mech"), 2, "two burning blows, two stacks")
	assert_eq(m.hull, 100 - 20, "two blows of ten on bare hull")
	sk.start_round()
	assert_eq(sk.forecast(ms, false)["overheat"], 5, "the turn's end: ten from the tick, five over the cap, unless vented or cleansed")


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


func test_withdrawing_burns_the_overheat_first() -> void:
	# Ryan, 11 October: leaving ends the turn, so running hot and then withdrawing is no way
	# round an overheat.
	var sk := Skirmish.new(1)
	var hot := _mech("Hot", Die.single(Face.attack(10, L, [], 50)), 40, 100)
	hot.heat_max = 30
	sk.add_mech(hot)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_true(sk.withdraw(), "withdrawn")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "the team got out")
	assert_eq(hot.hull, 80, "but the twenty over the cap burnt on the way")
	assert_eq(hot.shield, 30, "and the parting blow still landed on the shield")


func test_a_numbed_foe_shrugs_off_a_suppress_at_its_odds() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100)
	sk.add_mech(m)
	var g := _ghoul(500, 30)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.stack(g, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 10, Effects.DECAY_NONE)
	sk.assign(0, sk.front[0])
	assert_false(g.is_suppressed(), "at ten stacks nothing lands")
	assert_eq(Effects.stacks_of(g, "numbed"), 10, "a shrugged-off suppress numbs no further")
	assert_true("\n".join(sk.log).contains("shrugs off"), "the log says so")
	sk.end_round()
	assert_eq(m.hull, 70, "it struck")
	# Three stacks: about seven in ten land, on the skirmish's own die.
	var landed := 0
	for seed_value in range(200):
		var s := Skirmish.new(seed_value)
		s.add_mech(_mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 100))
		var f := _ghoul(500, 30)
		s.add_foes([f])
		s.begin()
		s.start_round()
		Effects.stack(f, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_NONE)
		s.assign(0, s.front[0])
		if f.is_suppressed():
			landed += 1
			assert_eq(Effects.stacks_of(f, "numbed"), 5, "a suppress that lands numbs two more")
	assert_true(landed > 110 and landed < 170, "about 140 of 200 land at 30%% resistance, got %d" % landed)
	# No foe resists by nature (Ryan, 10 October): a first suppress always lands, boss or not.
	var boss := _ghoul(500, 30)
	boss.size = 2
	assert_eq(boss.resist_total(), 0, "a fresh boss resists nothing")


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
	assert_eq(sk.pending_bite(sk.mechs[0]), 10, "spending it costs 10")
	assert_eq(sk.forecast(sk.mechs[0], true)["hull_after"], 170, "the forecast counts the bite and the blow while the die is in hand")
	assert_eq(sk.forecast(sk.mechs[0], false)["hull_after"], 180, "and only the blow otherwise")
	sk.assign(0, sk.front[0])
	assert_eq(m.hull, 180, "the bite lands as the entry is spent")
	assert_eq(sk.front[0].hp, 470, "and the component still does its work")
	sk.end_round()
	assert_eq(Effects.corrupt_stacks(m, 0), 2, "it stacks")
	sk.start_round()
	assert_eq(sk.pending_bite(sk.mechs[0]), 20, "twenty a spend now")
	sk._finish()
	assert_eq(Effects.corrupt_stacks(m, 0), 0, "gone with the skirmish")


func test_the_bite_takes_shield_first_and_never_armour() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L)), 5, 100)
	m.armour = 50
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.corrupt_entry(m, 0, "foe:x", 2)
	sk.assign(0, sk.front[0])
	assert_eq(m.shield, 0, "the shield goes first")
	assert_eq(m.hull, 85, "the rest reaches the hull, armour or no armour")
	assert_eq(sk.front[0].hp, 470, "the attack still landed")


func test_cleanse_clears_what_foes_did_and_not_a_cooldown() -> void:
	var sk := Skirmish.new(1)
	var scrubber := Face.shield(10)
	scrubber.add_keyword(K.CLEANSE)
	var a := _mech("A", Die.single(scrubber), 0, 100)
	var b := _mech("B", Die.single(Face.attack(30, L)), 40, 100)
	b.shield = 0
	sk.add_mech(a)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.corrupt_entry(b, 0, "foe:x", 2)
	Effects.disable_entry(b, 0, "foe:x", sk.round + 1)
	Effects.stack(b, Effects.STATUS["burning_mech"], Effects.SKIRMISH, "foe:x", 3, Effects.DECAY_TURN)
	Effects.stack(b, Effects.STATUS["scorched"], Effects.SKIRMISH, "foe:x", 2, Effects.DECAY_TURN_ALL)
	assert_eq(scrubber.describe(), "shield 10 cleanse", "the keyword reads on the entry")
	assert_true(sk.assign(0, sk.mechs[1]), "the shield is spent on B")
	assert_eq(b.shield, 10, "shielded")
	assert_eq(Effects.corrupt_stacks(b, 0), 0, "corruption gone")
	assert_false(Effects.is_entry_disabled(b, 0), "the foe's disable gone")
	assert_eq(Effects.stacks_of(b, "burning_mech"), 0, "burning gone")
	assert_eq(Effects.stacks_of(b, "scorched"), 0, "scorched gone")
	assert_true("\n".join(sk.log).contains("cleanses B: "), "the log says what went")
	Effects.disable_entry(a, 0, "cooldown", sk.round)
	var gone := Effects.cleanse(a)
	assert_true(gone.is_empty(), "a cooldown (Rapid's switch-off among them) is not the cleanse's to lift")
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
	Effects.stack(lit, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 1)
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
	var m := _mech("Ray", Die.single(Face.attack(10, L, K.BURN)), 40, 100)   # Burn 1: one stack (the number, since 18 October)
	m.grant_passive(hot)
	sk.add_mech(m)
	var g := _ghoul(500, 0)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(g, "burning"), 1, "cold, a 10 burn is one stack")
	sk.end_round()
	sk.start_round()
	sk.mechs[0].heat = 45
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(g, "burning"), 1 + 2, "at 45 heat the same burn is two deeper, two whole steps of 20 (the first round's stack burned off at the ghoul's turn)")
	assert_true(sk.log[sk.log.size() - 2].contains("runs hot: +2 Burning"), "and the log says so: %s" % sk.log[sk.log.size() - 2])
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
	assert_eq(Effects.stacks_of(g3, "numbed"), 2, "Numbed is exempt: the suppress leaves its two, no more")
	assert_eq(Effects.extra_stacks(z, "numbed", 100), 0, "asked directly, Numbed gains nothing")
	assert_eq(Effects.extra_stacks(z, "burning", 19), 0, "under one step, nothing")
	assert_eq(Effects.extra_stacks(z, "burning", 100), 5, "five steps at 100")
	assert_true(Effects.effect_text({"trigger": "on_stack", "effect": "add_stacks", "value": 1, "per_heat": 20}).begins_with("every stack this machine applies is 1 deeper for every 20 heat it carries"), "reads as a sentence")


## The Pocket Paradox as a meter (Ryan, 10 October): a foe gains Paradox for each other status
## it gains, once a spend however many strikes or stacks; at the count it is Suppressed and
## the Paradox clears. Paradox is a status, never decays, and never feeds itself.
func test_the_paradox_meter_knocks_a_foe_out_at_its_count() -> void:
	var meter := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "paradox", "value": 3}]}
	var sk := Skirmish.new(1)
	var gun := Face.attack(5, L, [K.BURN, K.SHOCK])
	gun.strikes = 3
	var m := _mech("A", Die.single(gun), 0, 100)
	m.grant_passive(meter)
	sk.add_mech(m)
	var g := _ghoul(500, 30)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_eq(Effects.paradox(m), [1, 3] as Array[int], "a stack an application, three to trip")
	assert_eq(sk.paradox_count(), 3, "the team's count")
	sk.assign(0, g)
	assert_eq(Effects.stacks_of(g, "paradox"), 2, "three strikes of burn are one application and the shock a second: two, not four")
	assert_false(g.is_suppressed(), "not yet")
	sk._foe_gained_status(g, "paradox")
	assert_eq(Effects.stacks_of(g, "paradox"), 2, "Paradox never feeds itself")
	sk._foe_gained_status(g, "numbed")
	assert_eq(Effects.stacks_of(g, "paradox"), 2, "nor Numbed, which is no status")
	sk._foe_gained_status(g, "burning")
	assert_true(g.is_suppressed(), "the third trips it: its past self knocks it out")
	assert_eq(Effects.stacks_of(g, "paradox"), 0, "the Paradox clears, and the Suppressed it caused added none")
	assert_eq(Effects.stacks_of(g, "numbed"), 2, "numbed like any suppressed foe")
	assert_true("\n".join(sk.log).contains("trapped in a paradox"), "the log says so")
	sk.end_round()
	assert_eq(m.hull, 100, "it skipped its blow")
	# Paradox never decays.
	sk.start_round()
	sk._foe_gained_status(g, "burning")
	sk.end_round()
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "paradox"), 1, "two rounds on, the stack still stands")
	# A weapon's suppress is a status gained; a trip on a foe already suppressed is wasted, the
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
	s2._foe_gained_status(g2, "burning")
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
	var m3 := _mech("C", Die.single(Face.attack(20, L, K.BURN)), 40, 100)
	m3.grant_passive(meter)
	m3.grant_passive({"id": "deep", "name": "Deep", "description": "", "effects": [{"trigger": "on_stack", "effect": "add_stacks", "value": 1}]})
	s3.add_mech(m3)
	var g3 := _ghoul(500, 30)
	s3.add_foes([g3])
	s3.begin()
	s3.start_round()
	s3.assign(0, g3)
	assert_eq(Effects.stacks_of(g3, "paradox"), 2, "one application, two stacks")
	assert_true(Effects.effect_text({"trigger": "on_foe_status", "effect": "paradox", "value": 3}).begins_with("a foe gaining any other status gains Paradox; at 3 it is suppressed"), "reads as a sentence")


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
	assert_eq(coil.describe(), "Overcharged ×10", "the entry names the status and its stacks")
	assert_eq(coil.number_text(), "×10", "the die shows the stacks")
	assert_true(coil.is_equipment(), "a buff is equipment")
	assert_true(sk.assign(0, sk.mechs[1]), "spent on B")
	assert_eq(Effects.stacks_of(b, "overcharged"), 10, "ten stacks on B")
	sk.assign(1, sk.front[0])
	assert_eq(sk.front[0].hp, 500 - 30, "20 plus 1 a stack, ten stacks")
	sk.end_round()
	assert_eq(Effects.stacks_of(b, "overcharged"), 5, "halved at the round's end, rounded down (Ryan, 18 October: a halving rule has no duration)")
	sk.start_round()
	sk.assign(1, sk.front[0])
	assert_eq(sk.front[0].hp, 500 - 30 - 25, "20 plus the five left the round after")
	# A two-round buff outlasts the first end of round; targets are the component's to set.
	var s2 := Skirmish.new(2)
	var brace := Face.buff("braced", 5, 2)
	brace.targets = Face.Target.ALLY
	var c := _mech("C", Die.single(brace), 40, 100)
	var d := _mech("D", Die.single(Face.attack(20, L)), 0, 100)
	s2.add_mech(c)
	s2.add_mech(d)
	s2.add_foes([_ghoul(500, 20)])
	s2.begin()
	s2.start_round()
	assert_false(s2.assign(0, null), "allies only: not on itself")
	assert_true(s2.assign(0, s2.mechs[1]), "on the ally")
	s2.end_round()
	assert_eq(Effects.stacks_of(d, "braced"), 5, "still there after one round")
	assert_eq(d.hull, 100 - 15, "20 less the brace's armour 5, on bare hull")
	s2.start_round()
	s2.end_round()
	assert_eq(Effects.stacks_of(d, "braced"), 0, "gone after the second")
	var rt := Face.from_dict({"kind": "buff", "status": "primed", "stacks": 3, "rounds": 2, "targets": "self"})
	assert_eq(rt.to_dict(), {"kind": "buff", "reach": "none", "power": 0, "keywords": [], "heat": 0, "targets": "self", "status": "primed", "stacks": 3, "rounds": 2}, "a buff round-trips through content")


func test_the_bot_values_a_burn_more_when_a_paradox_may_trip_on_the_foe() -> void:
	var loop := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "paradox", "value": 1}]}
	var scores: Array[float] = []
	for with_loop in [false, true]:
		var sk := Skirmish.new(1)
		var m := _mech("A", Die.single(Face.attack(20, L, K.BURN)), 40, 100)
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
	var fist := Face.attack(30, L, K.VOLATILE)
	var m := _mech("A", Die.single(fist), 40, 100)
	m.armour = 50
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(fist.describe(), "30 volatile", "the keyword reads on the entry")
	assert_eq(sk.pending_volatile(sk.mechs[0]), 10, "spending it costs 10 hull")
	assert_eq(sk.forecast(sk.mechs[0], true)["volatile"], 10, "the forecast names the cost while the die is in hand")
	assert_eq(sk.forecast(sk.mechs[0], true)["hull_after"], 90, "and takes it off the hull, shield or no shield")
	assert_eq(sk.forecast(sk.mechs[0], false)["hull_after"], 100, "nothing otherwise: the ghoul's blow is blocked")
	assert_true(sk.assign(0, sk.front[0]), "spent")
	assert_eq(m.hull, 90, "the bite lands on the hull as the entry is spent, past shield and armour")
	assert_eq(m.shield, 40, "the shield never saw it")
	assert_eq(sk.front[0].hp, 470, "and the component still does its work")
	assert_true("\n".join(sk.log).contains("A: 30 volatile is volatile, hull -10"), "the log says so")
	assert_eq(sk.pending_volatile(sk.mechs[0]), 0, "a spent die costs nothing more")


func test_a_volatile_shield_costs_hull_to_raise() -> void:
	var sk := Skirmish.new(1)
	var plate := Face.shield(20)
	plate.add_keyword(K.VOLATILE)
	var m := _mech("A", Die.single(plate), 40, 100)
	m.shield = 0
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, null), "raised on itself")
	assert_eq(m.shield, 20, "the shield stands")
	assert_eq(m.hull, 90, "and cost hull to raise")


func test_a_volatile_component_can_wreck_its_owner_before_it_acts() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L, K.VOLATILE)), 40, 10)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.forecast(sk.mechs[0], true)["destroyed"], "the forecast warns")
	assert_true(sk.assign(0, sk.front[0]), "the spend is legal")
	assert_eq(m.hull, 0, "wrecked by its own component")
	assert_eq(sk.front[0].hp, 500, "which never fired")
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "the fight is decided")
	assert_true("\n".join(sk.log).contains("wrecked by its own volatile component"), "the log says why")


func test_a_disabled_volatile_entry_does_not_bite() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(30, L, K.VOLATILE)), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.disable_entry(m, 0, "foe:x", sk.round + 1)
	assert_eq(sk.pending_volatile(sk.mechs[0]), 0, "a blank is never spent")
	assert_true(sk.assign(0, null), "the blank is discarded")
	assert_eq(m.hull, 100, "and costs nothing")


func test_the_talons_kill_rule_feeds_overcharged_per_kill_and_it_halves_each_round() -> void:
	var sk := Skirmish.new(3)
	var talon := Face.from_dict({"kind": "attack", "reach": "direct", "power": 30, "keywords": ["cleave"], "devours": 1})
	var m := _mech("A", Die.single(talon), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(30, 10), _ghoul(30, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(talon.describe(), "30 spread Overcharged ×1 a kill", "the rule reads on the entry, in plain words (Ryan, 18 October: devour is not a thing)")
	assert_true(talon.has_unique_rule(), "a rule printed on the entry: the die's star chip")
	assert_eq(Face.from_dict({"kind": "attack", "reach": "direct", "power": 30, "keywords": ["devour"]}).devours, 1, "an old save's devour keyword reads as the rule, a stack a kill")
	assert_eq(Face.from_dict({"kind": "attack", "reach": "direct", "power": 30, "devours": true}).devours, 1, "and an old save's true as one")
	assert_eq(Face.from_dict({"kind": "attack", "reach": "direct", "power": 30, "devours": 2}).to_dict()["devours"], 2, "the count round-trips")
	# Column 1 (the middle) spreads to both neighbours: two ghouls at 30 die, the big one lives.
	var middle: Foe = sk.front[1]
	assert_true(sk.assign(0, middle), "spent on the middle")
	var kills := 0
	for col in range(3):
		if sk.front[col] == null:
			kills += 1
	assert_eq(kills, 2, "two ghouls fell to the spread")
	assert_eq(Effects.stacks_of(m, "overcharged"), 2, "one stack of Overcharged per kill")
	assert_true("\n".join(sk.log).contains("kills revenant: Overcharged"), "the log says what the kill gave")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "it halves at the round's end")
	sk.start_round()
	var big: Foe = null
	for col in range(3):
		if sk.front[col] != null and sk.front[col].hp > 100:
			big = sk.front[col]
	var before := big.hp
	sk.assign(0, big)
	assert_eq(before - big.hp, 31, "30 plus 1 with the stack left: a damage point a stack")
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "no kill, no new stack")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 0, "and one stack halves to none, rounded down (Ryan: a status decays to zero or is timed)")


func test_a_buffs_overcharged_and_a_kills_add_up_and_halve_as_one() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.from_dict({"kind": "attack", "reach": "direct", "power": 20, "devours": 1})), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.grant_buff(m, "overcharged", 2, "buff", sk.round)
	Effects.stack(m, Effects.STATUS["overcharged"], Effects.SKIRMISH, "kill", 3, Effects.DECAY_HALF)
	assert_eq(Effects.stacks_of(m, "overcharged"), 5, "the buff's two and the kill's three together")
	assert_eq(m.modifiers.size(), 1, "one grant: a halving status has no rounds to part them (Ryan, 18 October)")
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


func test_a_timed_buff_granted_again_later_keeps_each_grants_own_rounds() -> void:
	# Ryan, 16 October: "Timed stacks should decay based on when they started. Not stack and
	# refresh." A buff for two rounds granted in round 1 runs through round 2; granted again in
	# round 2 it runs through round 3, and never lengthens the first grant's stack.
	# Primed is the timed buff here: Overcharged halves on its own clock and takes no rounds
	# since 18 October (Ryan: a status decays to zero or is timed, never both).
	var gun := Face.attack(20, L)
	var m := _mech("A", Die.single(gun))
	Effects.grant_buff(m, "primed", 1, "buff", 2)   # round 1, for two rounds
	Effects.end_round(m, 1)
	assert_eq(Effects.stacks_of(m, "primed"), 1, "the first grant outlasts round 1")
	Effects.grant_buff(m, "primed", 1, "buff", 3)   # round 2, for two rounds
	assert_eq(Effects.stacks_of(m, "primed"), 2, "two stacks during round 2")
	assert_eq(m.modifiers.size(), 2, "each grant a modifier of its own")
	var named := 0
	for t in Effects.explain(m, gun):
		if str(t).contains("Primed"):
			named += 1
	assert_eq(named, 1, "the die's row names the status once")
	# A save writes each grant, and a load keeps them apart, each with its own end.
	var back := _mech("B", Die.single(Face.attack(20, L)))
	for mod in m.modifiers:
		back.modifiers.append(SaveGame._modifier_from(JSON.parse_string(JSON.stringify(SaveGame._modifier_dict(mod)))))
	assert_eq(back.modifiers.size(), 2, "still two grants after a save and a load")
	for u in [m, back]:
		Effects.end_round(u, 2)
		assert_eq(Effects.stacks_of(u, "primed"), 1, "the first grant's stack goes at the end of round 2")
		Effects.end_round(u, 3)
		assert_eq(Effects.stacks_of(u, "primed"), 0, "the second's at the end of round 3")


func test_grants_of_a_timed_buff_ending_the_same_round_stack_as_one() -> void:
	# Two lattices spent in one round, or a brace beside a buff of Armoured for the round: the
	# same timed status ending the same round stacks onto one modifier and goes as one.
	var m := _mech("A", Die.single(Face.attack(20, L)))
	Effects.grant_buff(m, "primed", 1, "buff:lattice", 2)
	Effects.grant_buff(m, "primed", 2, "buff:other_lattice", 2)
	assert_eq(m.modifiers.size(), 1, "one modifier")
	assert_eq(Effects.stacks_of(m, "primed"), 3, "with the stacks summed")
	Effects.end_round(m, 1)
	assert_eq(Effects.stacks_of(m, "primed"), 3, "both outlast round 1")
	Effects.end_round(m, 2)
	assert_eq(Effects.stacks_of(m, "primed"), 0, "and go together at the end of round 2")
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


func test_a_two_round_buff_spent_in_two_rounds_goes_a_grant_at_a_time() -> void:
	# The same through the skirmish: a buff entry for two rounds, spent in round 1 and again in
	# round 2, leaves two stacks in round 2, and round 1's goes at the end of round 2.
	var sk := Skirmish.new(1)
	var lattice := Face.buff("primed", 1, 2)   # a timed buff: Overcharged halves on its own clock since 18 October
	var m := _mech("A", Die.single(lattice), 40, 300)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, null), "spent on itself in round 1")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "primed"), 1, "it outlasts round 1")
	sk.start_round()
	assert_true(sk.assign(0, null), "and again in round 2")
	assert_eq(Effects.stacks_of(m, "primed"), 2, "two stacks during round 2")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "primed"), 1, "round 1's goes at the end of round 2")
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "primed"), 0, "round 2's at the end of round 3")


func test_removing_a_status_clears_every_grant_of_it() -> void:
	var m := _mech("A", Die.single(Face.attack(20, L)))
	Effects.grant_buff(m, "primed", 1, "buff", 2)   # a timed buff (Overcharged halves on its own since 18 October)
	Effects.grant_buff(m, "primed", 2, "buff", 3)
	assert_eq(m.modifiers.size(), 2, "two grants")
	assert_true(Effects.remove(m, "primed"), "the status went")
	assert_false(Effects.has(m, "primed"), "both grants with it")
	assert_true(m.modifiers.is_empty(), "nothing left behind")
	assert_false(Effects.remove(m, "primed"), "and nothing more to remove")
	# A spend takes from the grant ending soonest, whichever came first, so the later one
	# keeps its stacks.
	Effects.grant_buff(m, "primed", 2, "buff", 3)
	Effects.grant_buff(m, "primed", 1, "buff", 2)
	assert_eq(Effects.spend_stacks(m, "primed", 1), 1, "one stack spent")
	Effects.end_round(m, 2)
	assert_eq(Effects.stacks_of(m, "primed"), 2, "from the grant ending soonest: the later one keeps both its stacks")


func test_a_live_hull_shocks_the_foe_that_strikes_it_and_the_next_blow_lands_double() -> void:
	var live := {"id": "live_hull", "name": "Faraday Hull", "description": "", "effects": [
		{"trigger": "static", "effect": "shock_on_hull_strike", "value": 1}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L)), 0, 200)
	m.grant_passive(live)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_true(Effects.shocks_striker(m, false), "the hull is live")
	assert_false(Effects.shocks_striker(m, true), "but a blocked blow shocks nothing")
	sk.end_round()
	assert_eq(m.hull, 190, "the blow landed on bare hull")
	assert_true(Effects.has(g, "shocked"), "and the ghoul is Shocked")
	assert_true("\n".join(sk.log).contains("A shocks revenant"), "the log says so")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 460, "20 lands double")
	assert_false(Effects.has(g, "shocked"), "and the shock is spent")
	assert_eq(sk.last_roll["final"], 40, "the blow's record carries what landed")
	m.shield_max = 50
	m.shield = 50   # the next strike is blocked, so nothing shocks it again
	sk.end_round()
	assert_false(Effects.has(g, "shocked"), "a blocked blow leaves it unshocked")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 440, "plain 20 after")


func test_a_shocked_foe_that_reaches_hull_again_pays_nothing() -> void:
	# Ryan, 11 October: the discharge went. Shocked sets up the team's next blow and does
	# nothing to the foe on its own, however often it strikes.
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 40, 200)
	m.shield = 0
	Effects.stack(m, Effects.STATUS["retaliate"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_true(Effects.has(g, "shocked"), "shocked by the first strike")
	assert_eq(g.hp, 500, "no discharge on the strike that shocked it")
	sk.start_round()
	sk.end_round()
	assert_eq(g.hp, 500, "the second strike on bare hull costs it nothing")
	assert_true(Effects.has(g, "shocked"), "and it stays Shocked, never doubly")
	assert_false("\n".join(sk.log).contains("discharges"), "no discharge in the log")
	# A blocked blow does not shock, unless a passive extends the shock to blocks.
	sk.start_round()
	sk.assign(0, null)
	assert_eq(m.shield, 10, "shield up")
	sk.end_round()
	assert_eq(g.hp, 500, "the blocked blow cost the ghoul nothing")
	var s2 := Skirmish.new(2)
	var shutters := {"id": "live_shell", "name": "Live Shell", "description": "", "effects": [
		{"trigger": "static", "effect": "shock_on_block", "value": 1}]}
	var b := _mech("B", Die.single(Face.shield(10)), 40, 200)
	b.grant_passive(shutters, "shutters", "shutters")
	s2.add_mech(b)
	var g2 := _ghoul(500, 10)
	s2.add_foes([g2])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq(b.hull, 200, "blocked")
	assert_true(Effects.has(g2, "shocked"), "and shocked through the block all the same")


func test_retaliate_is_a_buff_a_component_may_grant() -> void:
	var sk := Skirmish.new(1)
	var klaxon := Face.buff("retaliate", 1, 1)
	var m := _mech("A", Die.single(klaxon), 0, 200)
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_eq(klaxon.describe(), "Retaliate ×1", "the entry names the status")
	assert_true(sk.assign(0, null), "spent on itself")
	assert_true(Effects.shocks_striker(m, false), "live for the round")
	sk.end_round()
	assert_true(Effects.has(g, "shocked"), "the striker is shocked")
	assert_false(Effects.shocks_striker(m, false), "and the buff went with the round")
	var f := Face.from_dict({"kind": "buff", "status": "retaliate"})
	assert_eq(f.buff_status, "retaliate", "content may write it")


func test_a_status_gained_after_a_foe_acted_suppresses_its_next_action() -> void:
	var loop := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "paradox", "value": 1}]}
	var live := {"id": "live_hull", "name": "Faraday Hull", "description": "", "effects": [
		{"trigger": "static", "effect": "shock_on_hull_strike", "value": 1}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 200)
	m.grant_passive(loop)
	m.grant_passive(live, "hull")
	sk.add_mech(m)
	var g := _ghoul(500, 10)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 190, "the blow landed")
	assert_true(Effects.has(g, "shocked"), "shocked by it")
	sk.start_round()
	assert_true(g.is_suppressed(), "the Paradox's suppress holds for the round after, since the ghoul had already struck")
	sk.end_round()
	assert_eq(m.hull, 190, "and it skipped that blow")


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
	assert_eq(klaxon.describe(), "indirect 0 lure spread", "the keyword reads on the entry")
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
	# A lure on a damage weapon: the foe it hits turns, if it lives.
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
	h.actions = [Foe.basic_action(), _special("debuff", "burn", {"value": 2, "aim": "heat"})]
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
	assert_eq(str(h.action.get("effect", "")), "burn", "the stoke")
	assert_eq(h.target, sk.mechs[1], "which aims for itself: at heat")
	assert_eq(h.last_special, "burn", "and counts as the special announced")
	assert_true("\n".join(sk.log).contains("is disrupted: Burn instead of Attack"), "the log names both: %s" % sk.log[sk.log.size() - 1])
	sk.end_round()
	assert_eq(Effects.stacks_of(sk.mechs[1].unit, "burning_mech"), 2, "the stoke landed: two stacks of Burning")
	assert_eq(cold.shield, 40, "and no blow did")
	# Nothing else open: a foe with one move, or whose other move's condition fails, is not moved.
	var s2 := Skirmish.new(1, 1)
	s2.add_mech(_mech("A", Die.single(Face.attack(10, L, K.DISRUPT)), 40, 200))
	var lone := _ghoul(500, 20)
	lone.actions = [Foe.basic_action(), _special("defend", "regrow", {"value": 20, "when": "below_half"})]
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
	boss.actions = [Foe.basic_action(), _special("defend", "regrow", {"value": 20}), _special("buff", "rally", {"value": 10})]
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
	var ram := Face.attack(50, L, K.SPILLOVER)
	var m := _mech("A", Die.single(ram), 40, 100)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 10), _ghoul(500, 10), _archer(500, 10), _archer(10, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(ram.describe(), "50 spillover", "the keyword reads on the entry")
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
	var burst := Face.attack(10, L, K.SPILLOVER)
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
	# The foe behind reads its own statuses: a shock doubles the first strike that reaches it
	# and is spent. An exact kill has nothing past it, so the shock waits for the next strike.
	var s2 := Skirmish.new(1, 1)
	var b2 := Face.attack(10, L, K.SPILLOVER)
	b2.strikes = 3
	s2.add_mech(_mech("A", Die.single(b2), 40, 100))
	var exact := _ghoul(10, 10)
	var wired := _archer(100, 10)
	s2.add_foes([exact, wired])
	s2.begin()
	s2.start_round()
	Effects.stack(wired, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_true(s2.assign(0, exact), "the burst at a ghoul its first strike kills exactly")
	assert_eq(wired.hp, 100 - 2 * 10 - 10, "nothing past the exact kill; the second strike lands double, the third plain")
	assert_false(Effects.has(wired, "shocked"), "the shock is spent")
	# Per foe: a spread neighbour an earlier strike killed spills its later strikes behind it,
	# while the target that stands spills nothing.
	var s3 := Skirmish.new(1, 2)
	var sweep := Face.attack(10, L, [K.CLEAVE, K.SPILLOVER])
	sweep.strikes = 3
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
	assert_eq(past.hp, 100 - 5 - 2 * 10, "behind the neighbour: the 5 past its kill and the two strikes after")
	assert_eq(safe.hp, 100, "behind the big one, which stands: nothing")


## The foe behind falls partway through the spend: the strikes left are lost, since nothing
## stands behind the back rank, and nothing else is hit.
func test_spillover_strikes_are_lost_once_the_foe_behind_falls() -> void:
	var sk := Skirmish.new(1, 2)
	var burst := Face.attack(10, L, K.SPILLOVER)
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
	# A devour feeds on the foe the spill kills, as it does on the foe the blow kills.
	var s2 := Skirmish.new(1, 2)
	var talons := Face.attack(10, L, K.SPILLOVER)
	talons.strikes = 4
	talons.devours = true
	var m := _mech("A", Die.single(talons), 40, 100)
	s2.add_mech(m)
	s2.add_foes([_ghoul(5, 20), _ghoul(100, 10), _archer(12, 20), _archer(100, 10)])
	s2.begin()
	s2.start_round()
	var c2 := 0 if s2.front[0].hp == 5 else 1
	var fed: Foe = s2.back[c2]
	assert_true(s2.assign(0, s2.front[c2]), "the talons at the ghoul")
	assert_false(fed.alive(), "the archer falls to the spill")
	assert_true("\n".join(s2.log).contains("A kills archer: Overcharged"), "and feeds the talons' rule")
	assert_eq(Effects.stacks_of(m, "overcharged"), 2, "one stack for each foe killed, the ghoul and the archer")
	assert_eq("\n".join(s2.log).count("A spills over: "), 2, "and nothing spills past the fallen archer")


## What the later strikes' spill leaves as it was: one strike spills only its excess, a burst
## that already reaches the foe behind (Penetrate) lands there once a strike with no spill on
## top, and a burst without Spillover loses its later strikes on the fallen foe.
func test_spillover_holds_for_one_strike_and_never_doubles_a_penetrating_blow() -> void:
	var sk := Skirmish.new(1, 1)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L, K.SPILLOVER)), 40, 100))
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
	var lance := Face.attack(10, L, [K.PENETRATE, K.SPILLOVER])
	lance.strikes = 3
	s2.add_mech(_mech("A", Die.single(lance), 40, 100))
	var g2 := _ghoul(5, 10)
	var a2 := _archer(100, 10)
	a2.armour = 2
	s2.add_foes([g2, a2])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, g2), "three penetrating strikes of 10")
	assert_false(g2.alive(), "the ghoul falls to the first")
	assert_eq(a2.hp, 100 - 3 * (10 - 2), "the archer takes every strike directly, less its armour, and no spill on top")
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
		{"trigger": "static", "effect": "grant_keyword", "value": "spillover"}]}
	var sk := Skirmish.new(1, 1)
	var gun := Face.attack(50, L)
	var m := _mech("A", Die.single(gun), 40, 100)
	m.grant_passive(drive)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 10), _archer(500, 10)])
	sk.begin()
	sk.start_round()
	assert_false(gun.has(K.SPILLOVER), "the die's own entry is untouched")
	assert_true(Effects.effective_face(m, gun).has(K.SPILLOVER), "but the machine spends it with the keyword")
	assert_true(sk.shown_face(sk.mechs[0], gun).has(K.SPILLOVER), "and sees it on the die")
	assert_eq(Effects.explain(m, gun), ["gains spillover (Juggernaut Drive)"], "the die row says where it came from")
	sk.assign(0, sk.front[0])
	assert_eq(sk.back[0].hp, 470, "the plain gun spilled past the kill")
	# A support keyword is never granted to an attack, nor an attack keyword to a shield.
	var plate := Face.shield(10)
	var odd := {"id": "odd", "name": "Odd", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "cleanse"}]}
	m.grant_passive(odd, "odd")
	assert_false(Effects.effective_face(m, gun).has(K.CLEANSE), "cleanse stays off the gun")
	assert_true(Effects.effective_face(m, plate).has(K.CLEANSE), "and lands on the shield")
	assert_false(Effects.effective_face(m, plate).has(K.SPILLOVER), "spillover stays off the shield")


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
	assert_eq(sk.pending_heat(sk.mechs[0]), -47, "the forecast sees the gauge emptying")
	assert_eq(sk.forecast(sk.mechs[0], true)["heat_after"], 0, "and lands at zero")
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


func test_a_round_start_passive_regains_shield_from_heat() -> void:
	var recoupler := {"id": "recoupler", "name": "Thermal Recoupler", "description": "", "effects": [
		{"trigger": "on_round_start", "effect": "shield_per_heat", "value": 5}]}
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.attack(20, L, [], 30)), 60, 100)
	m.shield = 10
	m.grant_passive(recoupler)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_eq(m.shield, 10, "no heat, no shield")
	sk.assign(0, sk.front[0])
	sk.end_round()
	assert_eq(sk.mechs[0].heat, 30, "hot now")
	sk.start_round()
	assert_eq(m.shield, 10 - 10 + 15, "the ghoul's blow took ten, then three tens of heat gave fifteen")
	assert_true("\n".join(sk.log).contains("A: round start, +15 shield"), "the log says so")
	assert_eq(Effects.effect_text({"trigger": "on_round_start", "effect": "shield_per_heat", "value": 5}), "at the start of the round: +5 shield for every 10 heat carried", "reads as a sentence")
	# Never over the maximum.
	m.shield = 58
	sk.mechs[0].heat = 40
	sk.end_round()
	sk.start_round()
	assert_true(m.shield <= 60, "capped at the maximum")


## The rolled condition: an effect that holds for a rolled weapon and never for a flat one.
## The ally condition still reads allies.
func test_a_rolled_condition_holds_for_rolled_weapons_only() -> void:
	var databank := {"id": "databank", "name": "Tactical Databank", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 5, "when": "rolled"}]}
	var gun := Face.attack(10, L, [], 0, 30)
	var beam := Face.attack(15, L)
	var a := _mech("A", Die.of([gun, beam]), 40, 100)
	a.grant_passive(databank)
	assert_eq(int(Effects.attack(a, gun, 20, 0)["damage"]), 25, "a rolled blow lands 5 harder")
	assert_eq(int(Effects.attack(a, beam, 15, 0)["damage"]), 15, "a flat one does not")
	assert_eq(Effects.explain(a, gun), ["rolled weapons: damage +5 (Tactical Databank)"], "the die row says so")
	assert_eq(Effects.explain(a, beam), [], "and says nothing on the flat one")
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


## The Nemesis's rage in Ryan's words (12 October): taking hull damage banks a rage for the
## skirmish, all of it: a blow, a bite of its own, an overheat. Rage alone changes no blow.
func test_rage_banks_on_every_hull_hit_for_the_skirmish() -> void:
	var core := {"id": "rage_core", "name": "Rage Core", "description": "", "effects": [
		{"trigger": "on_hull_damage", "effect": "stack_status", "value": "rage"}]}
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
	assert_eq(Effects.stacks_of(m, "rage"), 2, "a rage each")
	sk.start_round()
	sk.end_round()
	sk.start_round()
	assert_eq(Effects.stacks_of(m, "rage"), 4, "never fading: two more blows, four")
	assert_eq(int(Effects.attack(m, Face.attack(30), 30, 0, g)["damage"]), 30, "rage alone adds nothing to a blow")
	# An overheat is hull damage too.
	var before := Effects.stacks_of(m, "rage")
	sk.mechs[0].heat = sk.mechs[0].heat_max + 20
	sk._settle_heat()
	assert_eq(Effects.stacks_of(m, "rage"), before + 1, "the overheat fed it")
	# A volatile bite is the machine's own weapon reaching hull: it counts.
	var s2 := Skirmish.new(2)
	var n := _mech("N", Die.single(Face.attack(30, L, K.VOLATILE)), 40, 200)
	n.grant_passive(core)
	s2.add_mech(n)
	s2.add_foes([_ghoul(500, 10)])
	s2.begin()
	s2.start_round()
	s2.assign(0, s2.front[0])
	assert_eq(Effects.stacks_of(n, "rage"), 1, "the bite fed it")


## The Nemesis's fists (Ryan, 12 October: "you just get rapid", without the switch-off): an
## entry that rolls again on a status spends a stack as it is spent, and the die rolls again,
## a plain roll that may show the same entry; with no stack left it is spent like any other.
func test_an_entry_rolls_again_on_a_stack_and_nothing_switches_off() -> void:
	var fist := Face.attack(10)
	fist.rolls_again_on = "rage"
	assert_true(fist.has_unique_rule(), "a rule printed on the entry: the star chip")
	assert_true(fist.describe().contains("spends a Rage to roll again"), "and it says so: %s" % fist.describe())
	var sk := Skirmish.new(3)
	var m := _mech("A", Die.single(fist), 0, 200)
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	Effects.stack(m, Effects.STATUS["rage"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	var g: Foe = sk.front[0]
	assert_true(sk.assign(0, g), "spent")
	assert_false(sk.mechs[0].assigned, "a rage spent: the die rolls again, and the machine acts again")
	assert_eq(Effects.stacks_of(m, "rage"), 1, "one rage spent")
	assert_false(Effects.is_entry_disabled(m, 0), "nothing switches off")
	assert_true(sk.assign(0, g), "the fist showed again, and it punches again")
	assert_false(sk.mechs[0].assigned, "the last rage rolls it again")
	assert_eq(Effects.stacks_of(m, "rage"), 0, "no rage left")
	assert_true(sk.assign(0, g), "and once more")
	assert_true(sk.mechs[0].assigned, "no rage: spent like any entry")
	assert_eq(g.hp, 470, "three blows of 10")
	# The fight's last blow rolls nothing: the fight is over.
	var s2 := Skirmish.new(4)
	var n := _mech("N", Die.single(fist), 0, 200)
	s2.add_mech(n)
	s2.add_foes([_ghoul(10, 10)])
	s2.begin()
	s2.start_round()
	Effects.stack(n, Effects.STATUS["rage"], Effects.SKIRMISH, "test", 2, Effects.DECAY_NONE)
	s2.assign(0, s2.front[0])
	assert_eq(s2.outcome, Skirmish.Outcome.VICTORY, "the last foe down")
	for line in s2.log:
		assert_false(line.contains("rolls again"), "no roll after the last kill: %s" % line)


func test_glacis_armours_against_the_front_rank_only() -> void:
	var glacis := {"id": "glacis", "name": "Glacis", "description": "", "effects": [
		{"trigger": "static", "effect": "add_armour_vs_rank", "value": 5, "rank": "front"}]}
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.blank()), 0, 200)
	m.armour = 5
	m.grant_passive(glacis, "plow", "plow")
	sk.add_mech(m)
	sk.add_foes([_ghoul(500, 20), _archer(500, 20)])
	sk.begin()
	sk.start_round()
	assert_eq(Effects.armour_against(m, 0), 5, "five more against the front")
	assert_eq(Effects.armour_against(m, 1), 0, "none against the back")
	assert_eq(m.armour, 5, "the stat itself is unchanged")
	assert_eq(sk.forecast(sk.mechs[0], false)["hull_after"], 200 - 10 - 15, "the forecast: the ghoul's 20 less ten, the archer's 20 less five")
	sk.end_round()
	assert_eq(m.hull, 175, "and so it lands")
	assert_eq(Effects.effect_text(glacis["effects"][0]), "armour +5 against front-rank blows", "reads as a sentence")


func test_a_kept_status_never_fades_and_lasts_the_battle() -> void:
	var tap := {"id": "tap", "name": "Quintessence Tap", "description": "", "effects": [
		{"trigger": "static", "effect": "keep_status", "value": "overcharged"}]}
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.single(Face.from_dict({"kind": "attack", "reach": "direct", "power": 30, "devours": true})), 40, 100)
	m.grant_passive(tap)
	sk.add_mech(m)
	sk.add_foes([_ghoul(20, 10), _ghoul(20, 10), _ghoul(500, 10)])
	sk.begin()
	sk.start_round()
	assert_true(Effects.keeps(m, "overcharged"), "the tap holds")
	sk.assign(0, sk.front[0])
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "one kill, one stack")
	sk.end_round()
	assert_eq(Effects.stacks_of(m, "overcharged"), 1, "it did not fade")
	sk.start_round()
	sk.assign(0, sk.front[0] if sk.front[0] != null and sk.front[0].hp <= 20 else sk.front[1])
	assert_eq(Effects.stacks_of(m, "overcharged"), 2, "and grows")
	sk._finish()
	assert_eq(Effects.stacks_of(m, "overcharged"), 2, "kept past the skirmish")
	Effects.end_battle(m)
	assert_eq(Effects.stacks_of(m, "overcharged"), 0, "gone with the battle, never the campaign")


func test_the_static_screen_covers_the_withdrawal() -> void:
	var screen := {"id": "screen", "name": "Static-screen Projector", "description": "", "effects": [
		{"trigger": "static", "effect": "screen_withdraw", "value": 50}]}
	# A screener is always out; with the chance at 100 every ally is too, and no blow lands.
	var sure := {"id": "screen", "name": "Static-screen Projector", "description": "", "effects": [
		{"trigger": "static", "effect": "screen_withdraw", "value": 100}]}
	var sk := Skirmish.new(1, 2)
	var car := _mech("Car", Die.single(Face.blank()), 0, 260)   # the tank is the weaker target
	car.grant_passive(sure)
	var tank := _mech("Tank", Die.single(Face.blank()), 0, 200)
	sk.add_mech(car)
	sk.add_mech(tank)
	sk.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
	sk.begin()
	assert_true(sk.withdraw(), "withdrew")
	assert_eq(car.hull, 260, "the car is out before the enemy strikes")
	assert_eq(tank.hull, 200, "and covered the tank")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "withdrawn")
	assert_true("\n".join(sk.log).contains("the static screen covers Car, Tank"), "the log names the covered")
	assert_true("\n".join(sk.log).contains("blow is lost in the static"), "and the lost blows")
	assert_true(sk._screened.is_empty(), "the screen is down afterwards")
	# At 50 the allies roll: over many seeds about half are covered, the screener always.
	var covered := 0
	var car_hit := 0
	for seed in range(40):
		var s2 := Skirmish.new(seed, 2)
		var c2 := _mech("Car", Die.single(Face.blank()), 0, 260)
		c2.grant_passive(screen)
		var t2 := _mech("Tank", Die.single(Face.blank()), 0, 200)
		s2.add_mech(c2)
		s2.add_mech(t2)
		s2.add_foes([_ghoul(500, 10), _ghoul(500, 10)])
		s2.begin()
		s2.withdraw()
		if c2.hull < 260:
			car_hit += 1
		if t2.hull == 200:
			covered += 1
	assert_eq(car_hit, 0, "the screener is never struck")
	assert_true(covered > 8 and covered < 32, "about half the tanks slipped out: %d of 40" % covered)
	# No screener, no screen: the withdrawal costs what it always did.
	var s3 := Skirmish.new(3, 1)
	var plain := _mech("Plain", Die.single(Face.blank()), 0, 100)
	s3.add_mech(plain)
	s3.add_foes([_ghoul(500, 10)])
	s3.begin()
	s3.withdraw()
	assert_eq(plain.hull, 90, "struck as the team pulls out")


func _special(kind: String, effect: String, extra: Dictionary = {}) -> Dictionary:
	var a := {"id": effect, "name": effect.capitalize(), "kind": kind, "effect": effect, "weight": 1, "text": ""}
	for k in extra.keys():
		a[k] = extra[k]
	return a


## A foe's brace is Braced, the machines' status (Ryan, 16 October: an effect and the buff it
## creates share a name): its value in stacks of armour +5, standing through the player's turn
## and going at the foe's next action, every stack at once.
func test_a_bracing_foe_is_braced_until_its_next_action_and_a_knitting_one_regrows() -> void:
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
	assert_true("\n".join(sk.log).contains("Brace, Armoured ×10 (armour +10 until its next action)"), "the log names the status")
	var desc := ""
	for d in Effects.describe(g):
		if str(d[5]) == "braced":
			desc = str(d[1])
	assert_eq(desc, "Armour +1 a stack, every stack at once: on a machine until the round's end, on a foe until its next action.", "the machines' description, for both sides")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(g.hp, 90, "the next round's 20 lands as 10: the brace's armour comes off, flat")
	sk.end_round()   # its next action: both stacks go at its tick, and its only move braces again
	assert_eq(Effects.stacks_of(g, "braced"), 10, "ten fresh stacks: the old ones went whole at its tick, a stack a turn would have left more")
	g.actions = [Foe.basic_action()]
	g.action = g.actions[0]
	sk.start_round()
	sk.end_round()   # its next action is a blow
	assert_false(Effects.has(g, "braced"), "gone at its next action, every stack at once")
	assert_eq(g.armour_total(), 0, "and its armour with them")
	var s2 := Skirmish.new(2, 1)
	s2.add_mech(_mech("B", Die.single(Face.attack(20, L)), 40, 100))
	var k := _ghoul(100, 10)
	k.hp = 50
	k.actions = [_special("defend", "regrow", {"value": 20})]
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
	sk.assign(0, g)
	assert_eq(sk.front[0], null, "it fell")
	assert_eq(sk.reinforcements.size(), 1, "and went back to the pool")
	assert_eq(g.hp, 30, "whole")
	assert_false(Effects.has(g, "risen"), "the charge spent")
	assert_true("\n".join(sk.log).contains("gets back up into the pool"), "the log says so")
	assert_eq(sk.outcome, Skirmish.Outcome.NONE, "the fight goes on")
	sk.end_round()
	assert_eq(sk.front[0], g, "it stepped back in")
	sk.start_round()
	sk.assign(0, g)
	assert_eq(sk.reinforcements.size(), 0, "once only")
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "and the second death holds")


func test_a_summoning_foe_calls_up_reinforcements_through_the_factory() -> void:
	var sk := Skirmish.new(5, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var n := _archer(30, 10)
	n.pack_id = 7
	n.actions = [_special("buff", "summon", {"foe": "revenant", "count": 2})]
	n.action = n.actions[0]
	sk.add_foes([n])
	sk.foe_factory = func(id: String) -> Foe: return Foe.make(id, 30, 10)
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(sk.field_foes().size(), 3, "two ghouls stepped in at the round's end")
	for f in sk.field_foes():
		assert_eq(f.pack_id, 7, "in the summoner's pack")
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


func test_a_rally_makes_the_others_hit_harder_next_round_only() -> void:
	var sk := Skirmish.new(7, 2)
	var m := _mech("A", Die.single(Face.blank()), 0, 300)
	sk.add_mech(m)
	var lord := _ghoul(500, 10)
	lord.actions = [_special("buff", "rally", {"value": 10})]
	lord.action = lord.actions[0]
	var g := _ghoul(500, 10)
	sk.add_foes([lord, g])
	sk.begin()
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 290, "the ghoul's plain 10 this round; the lord rallied")
	assert_true(Effects.has(g, "kindled"), "the ghoul is kindled")
	assert_false(Effects.has(lord, "kindled"), "not the lord itself")
	sk.start_round()
	assert_eq(g.damage(), 20, "its intent reads 20")
	lord.actions = [Foe.basic_action()]
	lord.action = lord.actions[0]
	sk.end_round()
	assert_eq(m.hull, 290 - 20 - 10, "20 from the kindled ghoul, 10 from the lord's blow")
	assert_false(Effects.has(g, "kindled"), "gone with the round")
	sk.start_round()
	assert_eq(g.damage(), 10, "plain again")


func test_a_rally_lands_next_round_at_its_own_value_whoever_acts_after_it() -> void:
	# The rallier is the heaviest hitter, so it stands left and acts first (13 October): the
	# foe striking after it this turn hits the number it showed, and next round every intent
	# is drawn with Kindled at the move's own value (the Howl's 5), never a fixed 10.
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
	assert_eq(g.damage(), 10, "the intent shown")
	sk.end_round()
	assert_eq(m.hull, 290, "the blow landed is the intent shown, rallied or not")
	assert_true(Effects.has(g, "kindled"), "kindled for next round")
	assert_false(Effects.has(lord, "kindled"), "not the rallier itself")
	assert_eq(Effects.foe_attack_bonus(g), 5, "by the Howl's own 5")
	sk.start_round()
	lord.action = lord.actions[0]
	assert_eq(g.damage(), 15, "its intent reads 15")
	sk.end_round()
	assert_eq(m.hull, 290 - 50 - 15, "the lord's 50 and the kindled 15")
	assert_false(Effects.has(g, "kindled"), "gone with the round")


func test_the_debuffs_cost_rerolls_heat_a_reroll_and_a_component() -> void:
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
	# Stoke: Burning on the target, its heat at the end of the next player's turn.
	var s2 := Skirmish.new(9, 1)
	var m2 := _mech("B", Die.single(Face.attack(10, L)), 40, 100)
	m2.cooling = 0
	s2.add_mech(m2)
	var h := _archer(500, 10)
	h.actions = [_special("debuff", "burn", {"value": 2})]
	h.action = h.actions[0]
	s2.add_foes([h])
	s2.begin()
	s2.start_round()
	s2.end_round()
	assert_eq(Effects.stacks_of(m2, "burning_mech"), 2, "two stacks of Burning")
	assert_eq(s2.mechs[0].heat, 0, "no heat yet")
	assert_eq(m2.shield, 40, "no blow with it")
	s2.start_round()
	assert_eq(s2.forecast(s2.mechs[0], false)["heat_end"], 10, "the forecast counts the tick to come")
	# Scramble: the next reroll of that die lands anywhere, then the scramble is spent.
	var s3 := Skirmish.new(10, 1)
	var m3 := _mech("C", Die.single(Face.attack(10, L)), 40, 100)
	s3.add_mech(m3)
	var w := _archer(500, 10)
	w.actions = [_special("debuff", "scramble")]
	w.action = w.actions[0]
	s3.add_foes([w])
	s3.begin()
	s3.start_round()
	s3.end_round()
	assert_true(Effects.is_scrambled(m3), "scrambled")
	s3.start_round()
	assert_true(Effects.is_scrambled(m3), "still, until it rerolls")
	assert_true(s3.reroll([0]), "the reroll happens")
	assert_false(Effects.is_scrambled(m3), "and the scramble is spent")
	assert_true("\n".join(s3.log).contains("C's reroll is scrambled"), "the log says so")
	# Unmake: the showing component cracks with no hull lost.
	var s4 := Skirmish.new(11, 1)
	var m4 := _mech("D", Die.single(Face.attack(10, L, K.BURN)), 40, 100)
	s4.add_mech(m4)
	var maw := _ghoul(500, 10)
	maw.actions = [_special("debuff", "crack")]
	maw.action = maw.actions[0]
	s4.add_foes([maw])
	s4.begin()
	s4.start_round()
	s4.end_round()
	assert_true(m4.die.faces[0].cracked, "cracked")
	assert_eq(m4.hull, 100, "with no hull lost")
	assert_eq(m4.shield, 40, "or shield")
	assert_eq(m4.damaged_component_count(), 1, "one to repair")
	s4.start_round()
	s4.end_round()
	assert_eq(m4.die.faces[0].kind, Face.Kind.BLANK, "cracked again: destroyed")


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


func test_an_overshield_passes_the_maximum_and_fades_at_the_rounds_end() -> void:
	var sk := Skirmish.new(1)
	var ov := Face.shield(40)
	ov.keywords.append(Face.Keyword.OVERSHIELD)
	var giver := _mech("Giver", Die.single(ov), 40, 100)
	var taker := _mech("Taker", Die.single(Face.attack(10, L)), 20, 100)
	sk.add_mech(giver)
	sk.add_mech(taker)
	sk.add_foes([_ghoul(500, 20), _ghoul(500, 20), _ghoul(500, 20)])
	sk.begin()
	sk.start_round()
	for f in sk.field_foes():
		f.target = sk.mechs[1]
	var fc := sk.forecast(sk.mechs[1], false, 40, true)
	assert_eq(int(fc["shield_after"]), 0, "the forecast reads the overshield: 60 against three blows of 20 leaves no shield standing")
	assert_eq(int(fc["hull_after"]), 100, "and no hull lost, where 20 shield alone would have let forty through")
	assert_true(sk.assign(0, sk.mechs[1]), "shield the ally past its maximum")
	assert_eq(taker.shield, 60, "20 plus 40, past a maximum of 20")
	assert_true("\n".join(sk.log).contains("past its maximum"), "the log says so")
	sk.mechs[1].face_index = 0
	sk.assign(1, sk.front[0])
	sk.end_round()
	assert_eq(taker.hull, 100, "three blows of 20 all taken by the overshield")
	assert_eq(taker.shield, 0, "the shield spent on them")
	# The excess fades at the round's end when nothing spends it.
	taker.shield = 20
	sk.start_round()
	sk.mechs[0].face_index = 0
	for f in sk.field_foes():
		f.target = sk.mechs[0]
	assert_true(sk.assign(0, sk.mechs[1]), "shield the ally again")
	assert_eq(taker.shield, 60, "past the maximum again")
	sk.mechs[1].face_index = 0
	sk.assign(1, sk.front[0])
	sk.end_round()
	assert_eq(taker.shield, 20, "untouched by the blows this round, the 40 past the maximum faded at the round's end")
	assert_true("\n".join(sk.log).contains("40 shield past its maximum fades"), "and the log says so")
	# Without the keyword the same shield is capped, as it always was.
	var plain := _mech("Plain", Die.single(Face.shield(30)), 40, 100)
	var sk2 := Skirmish.new(1)
	var t2 := _mech("T", Die.single(Face.attack(10, L)), 20, 100)
	t2.shield = 20
	sk2.add_mech(plain)
	sk2.add_mech(t2)
	sk2.add_foes([_ghoul(90)])
	sk2.begin()
	sk2.start_round()
	assert_true(sk2.assign(0, sk2.mechs[1]), "a plain shield on a full ally")
	assert_eq(t2.shield, 20, "stays at the maximum")


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
	var tap := Face.attack(5, L, K.BURN)
	var s2 := Skirmish.new(1, 1)
	s2.add_mech(_mech("B", Die.single(tap), 40, 100))
	var h := _ghoul(100, 10)
	h.armour = 10
	s2.add_foes([h])
	s2.begin()
	s2.start_round()
	assert_true(s2.assign(0, h), "a tap with a burn")
	assert_eq(h.hp, 100, "the armour holds the tap whole")
	assert_true(h.burn_stacks() > 0, "but the burn is on")
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
	assert_eq(int(sk.forecast(sk.mechs[0], false)["hull_after"]), 75, "the forecast takes the armour off the 30")
	sk.end_round()
	assert_eq(m.hull, 75, "and so does the blow")
	sk.start_round()
	assert_eq(m.armour, 0, "gone with the round")


func test_the_hush_the_eruption_and_the_unravel_run() -> void:
	# Hush: the showing weapon is switched off through the machine's next turn, no blow.
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.attack(10, L)), 40, 100)
	sk.add_mech(m)
	var w := _ghoul(500, 10)
	w.actions = [_special("debuff", "disable", {"aim": "armed", "when": "machine_armed"})]
	w.action = w.actions[0]
	sk.add_foes([w])
	sk.begin()
	sk.start_round()
	assert_false(w.attacks(), "a gun is showing, so the hush is open")
	sk.end_round()
	assert_eq(m.shield, 40, "no blow")
	sk.start_round()
	assert_eq(sk.mechs[0].face().kind, Face.Kind.BLANK, "the entry shows blank the next turn")
	assert_true("\n".join(sk.log).contains("is switched off"), "the log says so")
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
	var a := _mech("A", Die.single(tesla), 40, 100)
	var b := _mech("B", Die.single(Face.attack(20, L)), 40, 100)
	sk.add_mech(a)
	sk.add_mech(b)
	var g1 := _ghoul(500, 10)
	var g2 := _ghoul(500, 10)
	sk.add_foes([g1, g2])
	sk.begin()
	sk.start_round()
	assert_eq(tesla.describe(), "20 shock spread", "the keyword reads on the entry")
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
	assert_eq(m.shield, 10, "and the hit stood a shield up")
	assert_eq(sk.mechs[0].heat, 15, "and shed heat")
	assert_true("\n".join(sk.log).contains("A: +10 shield, -5 heat from the hit"), "the log says so")


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
	assert_eq(sk.forecast(sk.mechs[1], false)["hull_after"], 70, "a shield takes ten of the first blow on its own machine and no other")
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


func test_a_healer_cures_the_most_hurt_of_its_own() -> void:
	# The White Mage's Cure (15 October): foes helping foes.
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(10, L)), 40, 100))
	var healer := Foe.make("mage", 60, 10, true)
	healer.actions = [{"id": "cure", "name": "Cure", "kind": "defend", "effect": "regrow_ally", "value": 20, "weight": 1, "when": ["ally_hurt"], "text": ""}]
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
	idle.actions = [{"id": "cure", "name": "Cure", "kind": "defend", "effect": "regrow_ally", "value": 20, "weight": 1, "when": ["ally_hurt"], "text": ""}, Foe.basic_action()]
	whole.add_foes([_ghoul(100, 10), idle])
	whole.begin()
	assert_false(whole.legal_actions(idle).has(idle.actions[0]), "with none of its own hurt it has no cure to cast")


func test_protect_braces_every_foe_through_the_next_round() -> void:
	# The White Mage's Protect (15 October): a brace on every foe, gone when the enemy acts
	# again; Braced since 16 October, the move's value in stacks of armour +5.
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
	var f := Foe.make("behemoth", hp, 20)
	f.on_death = {"blow": Foe.death_blow_from({"name": "Meteor", "factor": 1.0, "keywords": ["all"]})}
	return f


func test_a_last_act_lands_the_moment_its_foe_falls() -> void:
	# The Behemoth's Meteor (15 October): shield up, then kill it.
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


func test_a_splitting_foe_puts_its_halves_into_the_pool_once() -> void:
	# The Gel (decided 9 October): destroyed, so many smaller step into the pool; the
	# halves never split again, and without the battle's factory nothing steps in.
	var sk := Skirmish.new(2, 1)
	var m := _mech("A", Die.single(Face.attack(200, L)), 40, 100)
	sk.add_mech(m)
	var gel := _ghoul(30, 10)
	gel.on_death = {"summon": "gel_small", "count": 2}
	sk.foe_factory = func(id: String) -> Foe: return Foe.make(id, 10, 5)
	sk.add_foes([gel])
	sk.begin()
	sk.start_round()
	sk.assign(0, gel)
	assert_eq(sk.front[0], null, "it fell")
	assert_eq(sk.reinforcements.size(), 2, "two halves wait in the pool")
	assert_eq(sk.reinforcements[0].display_name, "gel_small", "the named foe")
	assert_eq(sk.reinforcements[0].pack_id, gel.pack_id, "under the same pack")
	assert_true("\n".join(sk.log).contains("splits: 2 gel_small"), "the log says so")
	assert_eq(sk.outcome, Skirmish.Outcome.NONE, "the fight goes on")
	sk.end_round()
	assert_eq(sk.front[0].display_name, "gel_small", "a half stepped in")
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


func test_the_reach_tally_counts_a_spend_its_hull_and_its_splash() -> void:
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
	assert_eq(int(t["front_spends"]), 1, "so it is a front spend")
	assert_eq(int(t["splash"]), 10, "and danger close cost half the blow in shield")
	assert_false(sk.reach_tally.has("direct"), "no direct spend happened")


# ---------------------------------------------------------------- the funnel-web (18 October)

## A synthetic ambush: the engine's lay_status on its target_no_intent condition, never the
## content's passive.
const AMBUSH := {"id": "ambush_t", "name": "Ambush", "description": "", "effects": [
	{"trigger": "on_attack", "effect": "lay_status", "value": "vitriol", "stacks": 1, "when": "target_no_intent"}]}


func _strikes(f: Face, n: int) -> Face:
	f.strikes = n
	return f


## Vitriol (Ryan's go, 18 October): a share of the foe's current hull a stack at its action,
## read after Burning on what it leaves, past armour, rounded down, then a stack fades; and it
## never finishes a foe, so it sets off no last act.
func test_vitriol_eats_a_share_of_the_hull_burning_leaves_and_never_finishes_a_foe() -> void:
	var sk := Skirmish.new(1)
	var m := _mech("A", Die.single(Face.shield(10)), 0, 500)
	sk.add_mech(m)
	var g := _ghoul(100, 10)
	g.armour = 5   # armour never sees a tick, as with Burning
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.stack(g, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 2)
	Effects.stack(g, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 3)
	var tp := Effects.tick_preview(g)
	assert_eq(int(tp["share"]), 14, "three stacks eat 15% of the 98 Burning's 2 leaves (a point a stack since 18 October), rounded down")
	assert_eq(int(tp["hp"]), 16, "the whole tick is Burning's and the share")
	sk.end_round()
	assert_eq(g.hp, 84, "100, less Burning's 2, less Vitriol's 14, past armour")
	assert_eq(Effects.stacks_of(g, "vitriol"), 2, "a stack faded at its action")
	assert_true("\n".join(sk.log).contains("vitriol eats revenant for 14"), "the log says what it ate")
	sk.start_round()
	sk.end_round()
	assert_eq(g.hp, 75, "after Burning's last point, two stacks eat 10% of 83: 8")
	assert_eq(Effects.stacks_of(g, "vitriol"), 1, "another faded")
	var low := _ghoul(1, 10)
	Effects.stack(low, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 5)
	assert_eq(int(Effects.tick_preview(low)["hp"]), 0, "nothing to eat on a foe at one hull")
	var mid := _ghoul(3, 10)
	Effects.stack(mid, Effects.STATUS["vitriol"], Effects.SKIRMISH, "mech", 20)
	assert_eq(int(Effects.tick_preview(mid)["hp"]), 2, "stacks enough to eat all three leave the last point: it never finishes a foe")
	assert_true(Effects.carries_status(mid), "a foe carrying Vitriol carries a status the team put on it")
	assert_eq(Effects.status_stacking(Effects.STATUS["vitriol"]), "add", "Vitriol adds, Burning's shape")


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
	at_a.action = {"id": "knit", "name": "Knit", "kind": "defend", "effect": "regrow", "value": 10, "weight": 1, "text": ""}
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
	var a := _mech("A", Die.single(Face.attack(0, L, K.WEB)), 0, 500)
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


## The web (Ryan's go, 18 October): the webbed foe acts once; at the end of its action the web
## bursts, Suppressing it (its next action, since it has acted) and the next foe to act beside
## it (its right-hand neighbour, which loses this round's action).
func test_a_web_bursts_after_the_foes_action_and_catches_the_next_to_act_beside_it() -> void:
	var sk := Skirmish.new(1, 3)
	var m := _mech("A", Die.single(Face.attack(0, L, K.WEB)), 0, 500)
	sk.add_mech(m)
	var small := _ghoul(500, 10)
	var mid := _ghoul(500, 20)
	var big := _ghoul(500, 40)
	sk.add_foes([small, mid, big])
	sk.begin()
	assert_eq(sk.front[0], big, "the heaviest hitter stands left and acts first")
	sk.start_round()
	assert_eq(sk.web_catch(big), mid, "a web on it would catch the one to its right, which acts after it")
	assert_true(sk.assign(0, big), "web the big one")
	sk.end_round()
	assert_eq(m.hull, 450, "the webbed foe's blow lands now and the small one's too; the burst catches the middle one's")
	assert_true("\n".join(sk.log).contains("revenant's web bursts, catching revenant"), "the log tells the burst")
	assert_false(Effects.has(big, "webbed"), "the web is spent")
	assert_true(big.is_suppressed(), "the webbed foe is held: it has acted, so it loses its next action")
	assert_false(mid.is_suppressed(), "the caught one lost this round's action, and nothing carries")
	assert_eq(Effects.stacks_of(big, "numbed"), 2, "a landed suppress numbs the webbed foe")
	assert_eq(Effects.stacks_of(mid, "numbed"), 1, "and the caught one, a stack already faded at the turn it skipped")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 420, "the round after, the big one skips and the other two strike")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 350, "then every blow lands again")


func test_a_web_on_the_rightmost_foe_catches_the_one_to_its_left_which_has_acted() -> void:
	var sk := Skirmish.new(1, 3)
	var m := _mech("A", Die.single(Face.attack(0, L, K.WEB)), 0, 500)
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
	assert_eq(m.hull, 430, "every blow lands this round: the caught neighbour had already acted")
	assert_true(small.is_suppressed() and mid.is_suppressed(), "both lose their next action")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 390, "the big one alone strikes the round after")


func test_a_webbed_foe_killed_first_takes_its_web_with_it() -> void:
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(0, L, K.WEB)), 0, 500)
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
	assert_false("\n".join(sk.log).contains("web bursts"), "no burst: the web went with it")
	assert_false(mid.is_suppressed(), "and the one beside it acted")
	assert_eq(a.hull + b.hull, 980, "its blow landed")


func test_a_web_on_a_foe_the_team_suppressed_wastes_its_half_and_still_catches_the_neighbour() -> void:
	var sk := Skirmish.new(1, 3)
	var a := _mech("A", Die.single(Face.attack(10, L, K.SUPPRESS)), 0, 500)
	var b := _mech("B", Die.single(Face.attack(0, L, K.WEB)), 0, 500)
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
	assert_eq(a.hull + b.hull, 990, "the stunned foe skipped, the burst caught the middle one, the small one struck")
	assert_eq(Effects.stacks_of(big, "numbed"), 1, "the burst's half on itself was wasted: two from the stun, one faded, none from the web")
	assert_true("\n".join(sk.log).contains("already suppressed"), "the log says the half was wasted")
	sk.start_round()
	assert_false(big.is_suppressed(), "it lost the one action and nothing carried")


func test_a_second_web_changes_nothing_and_a_web_feeds_the_paradox_at_the_spend_and_at_the_burst() -> void:
	var meter := {"id": "loop", "name": "Pocket Paradox", "description": "", "effects": [
		{"trigger": "on_foe_status", "effect": "paradox", "value": 5}]}
	var sk := Skirmish.new(1, 2)
	var a := _mech("A", Die.single(Face.attack(0, L, K.WEB)), 0, 500)
	a.grant_passive(meter)
	var b := _mech("B", Die.single(Face.attack(0, L, K.WEB)), 0, 500)
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
	assert_eq(Effects.stacks_of(g, "paradox"), 2, "the burst's Suppressed is a weapon's: the meter counts it too")


func test_a_web_holds_a_gathering_countdown_a_round() -> void:
	var sk := Skirmish.new(1, 1)
	var a := _mech("A", Die.single(Face.attack(0, L, K.WEB)), 0, 100)
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
		{"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status", "status": "burning"}]})
	sk.add_mech(m)
	var clean := _ghoul(200, 20)
	var lit := _ghoul(200, 20)
	sk.add_foes([clean, lit])
	sk.begin()
	sk.start_round()
	Effects.stack(lit, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", 1)
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
	assert_eq(lead, "blows from foes carrying Burning: damage taken -5", "the rule reads with its condition as the lead")
	assert_eq(Effects.effect_text({"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status", "status": "flakked"}),
		"blows from foes carrying Flak: damage taken -5", "Flak reads by its name since it was built (21 October)")
	assert_eq(Effects.effect_text({"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status", "status": "unbuilt"}),
		"blows from foes carrying Unbuilt: damage taken -5", "a status the engine lacks reads by its id")
	var other := _mech("B", Die.single(Face.attack(20, L)), 0, 100)
	other.grant_passive({"id": "tyres2", "name": "Tyres", "description": "", "effects": [
		{"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status"}]})
	assert_eq(Effects.damage_taken(other, 20, lit), 15, "named no status, the condition reads any foe status")
	assert_eq(Effects.damage_taken(other, 20, clean), 20, "and a clean striker is nothing")
	other.modifiers[0].effects[0]["status"] = "unbuilt"
	assert_eq(Effects.damage_taken(other, 20, lit), 20, "a status the engine lacks never holds")


## The form-changing tank (the Armadillo's Lockdown; Ryan's framework of 15 October, his go 20
## October): a shield spent on itself seals the machine, one chip carrying the passive's armour;
## sealed, its own cooling stops and it runs hotter at the end of each turn, before the overheat;
## a vent or a damaging weapon opens it; a shield on an ally and a weapon of no damage (its
## lures) leave the form alone.
func test_a_shield_on_itself_seals_the_machine_and_a_vent_or_a_damaging_weapon_opens_it() -> void:
	var sk := Skirmish.new(1)
	var shield := Face.shield(20)
	var vent := Face.from_dict({"kind": "vent", "power": 20})
	var gun := Face.attack(10, L)
	var lure := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "cryo"], "heat": 5, "cryo": 1})
	var m := _mech("A", Die.of([shield, vent, gun, lure]), 0, 200)
	m.cooling = 5
	m.grant_passive({"id": "lockdown", "name": "Lockdown", "description": "", "effects": [
		{"trigger": "static", "effect": "seal_form", "value": 10, "heat": 15}]})
	var b := _mech("B", Die.single(Face.attack(10, L)), 40, 100)
	sk.add_mech(m)
	sk.add_mech(b)
	sk.add_foes([_ghoul(500, 20)])
	sk.begin()
	sk.start_round()
	var ms := sk.mechs[0]
	assert_eq(Effects.seal_form(m), {"armour": 10, "heat": 15}, "the passive says what the seal grants")
	assert_false(Effects.is_sealed(m), "open to begin with")
	ms.face_index = 0
	assert_true(sk.assign(0, sk.mechs[1]), "a shield on the ally")
	assert_false(Effects.is_sealed(m), "does not seal it")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	assert_true(sk.assign(0, null), "a shield on itself")
	assert_true(Effects.is_sealed(m), "seals it")
	assert_eq(m.armour, 10, "the seal's armour, read through the stat")
	assert_true("\n".join(sk.log).contains("A seals: armour +10"), "the log says so")
	assert_eq(sk.forecast(ms, false)["heat_end"], 15, "the forecast reads the seal's heat at the turn's end")
	sk.end_round()
	assert_eq(ms.heat, 15, "sealed, it ran 15 hotter at the end of its turn")
	assert_true(Effects.is_sealed(m), "and stays sealed through the enemy's turn")
	sk.start_round()
	assert_eq(ms.heat, 15, "its own cooling stopped: nothing shed at the round's start")
	ms.face_index = 3
	assert_true(sk.assign(0, sk.front[0]), "a lure, a weapon of no damage")
	assert_true(Effects.is_sealed(m), "keeps the seal")
	assert_eq(Effects.stacks_of(sk.front[0], "cryoed"), 1, "and leaves Cryo on the foe")
	sk.end_round()
	assert_eq(ms.heat, 35, "the lure's 5 and another 15 sealed")
	sk.start_round()
	ms.face_index = 1
	assert_true(sk.assign(0, null), "a vent on itself")
	assert_false(Effects.is_sealed(m), "opens it")
	assert_eq(m.armour, 0, "the seal's armour goes with it")
	assert_eq(ms.heat, 15, "the vent's 20 off")
	assert_true("\n".join(sk.log).contains("A opens"), "the log says so")
	sk.end_round()
	assert_eq(ms.heat, 15, "open, nothing more at the turn's end")
	sk.start_round()
	assert_eq(ms.heat, 10, "and its cooling runs again")
	ms.face_index = 0
	assert_true(sk.assign(0, null), "sealed again")
	assert_true(Effects.is_sealed(m), "one seal, renewed")
	assert_eq(m.modifiers.filter(func(x): return x.id == "sealed").size(), 1, "one modifier however often it seals")
	sk.end_round()
	sk.start_round()
	ms.face_index = 2
	assert_true(sk.assign(0, sk.front[0]), "a damaging weapon")
	assert_false(Effects.is_sealed(m), "opens it too")


## Cryo (Ryan, 18 and 20 October): the Cryo Flinger's mark pays in cooling. Any machine's
## damaging hit on a foe carrying Cryo spends every stack and cools the hitter 10 a stack, after
## the spend's own heat lands; a blow of nothing spends none, and the keyword's number is the
## stacks each foe reached gains.
func test_a_damaging_hit_cashes_a_foes_cryo_for_the_hitters_cooling() -> void:
	var sk := Skirmish.new(1)
	var flinger := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "rapid", "cryo"], "heat": 5, "cryo": 1})
	assert_eq(flinger.describe(), "indirect 0 lure rapid cryo 1 (+5 heat)", "the entry says its stacks")
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
	assert_eq(Effects.stacks_of(g, "cryoed"), 2, "two stacks, nothing spent by a weapon of no damage")
	assert_true(sk.assign(1, g), "B's gun, 10 damage for 5 heat")
	assert_eq(Effects.stacks_of(g, "cryoed"), 0, "the hit spent every stack")
	assert_eq(sk.mechs[1].heat, 30 + 5 - 20, "B cooled 10 a stack after its own heat landed")
	assert_true("\n".join(sk.log).contains("B cashes Cryo ×2: -20 heat"), "the log says so")
	sk.end_round()
	sk.start_round()
	sk.mechs[1].heat = 3
	Effects.stack(g, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_NONE)
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


## Flak (Ryan's go, 19 October; built 21 October): Flak N lays N stacks on each foe hit, whatever
## the blow dealt, after the blow, and every blow the foe takes deals a point more a stack: an
## add before the multiplies (a Shocked foe takes blow plus Flak, doubled) and before its
## armour, folded into the die's number over it; a blow of nothing stays nothing.
func test_flak_lays_its_number_on_each_foe_hit_and_every_blow_it_takes_lands_harder() -> void:
	var sk := Skirmish.new(1)
	var spray := Face.attack(5, L, [K.CLEAVE, K.FLAK])
	spray.flak = 2
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
	assert_eq(mid.hp, 95, "the blow that lays the Flak never feeds on it: a plain 5")
	assert_eq(sk.front[0].hp, 95, "the spray's neighbour takes its 5")
	for foe in [sk.front[0], mid, sk.front[2]]:
		assert_eq(Effects.stacks_of(foe, "flakked"), 2, "each foe hit carries Flak 2")
	assert_true(Effects.carries_status(mid), "a status the team put on it, for the Tensor")
	assert_eq(sk.shown_number(sk.mechs[1], gun, mid), [12, 12] as Array[int], "the die over a Flak foe folds in its 2")
	assert_true(sk.assign(1, mid), "the gun on it")
	assert_eq(mid.hp, 83, "every blow it takes deals a point more a stack: 10 and 2")
	assert_true(sk.assign(2, sk.front[2]), "a lure on another")
	assert_eq(sk.front[2].hp, 95, "a blow of nothing stays nothing, Flak or not")
	assert_eq(Effects.damage_taken(mid, 0), 0, "nothing in, nothing out")
	Effects.stack(mid, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	assert_eq(Effects.damage_taken(mid, 10), 24, "adds before multiplies: a Shocked foe takes blow plus Flak, doubled")
	mid.armour = 5
	assert_eq(sk.shown_number(sk.mechs[1], gun, mid), [7, 7] as Array[int], "its armour comes off after the Flak, and the shock stays on its chip")


## A spend of several strikes lays its Flak a strike at a time, so the later strikes land on
## what the earlier ones laid.
func test_a_later_strike_of_a_flak_spend_lands_on_the_flak_the_first_laid() -> void:
	var sk := Skirmish.new(1)
	var burst := _strikes(Face.attack(5, L, K.FLAK), 3)
	burst.flak = 1
	sk.add_mech(_mech("A", Die.single(burst), 0, 200))
	var g := _ghoul(100)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, g), "three strikes")
	assert_eq(g.hp, 100 - 5 - 6 - 7, "5, then 5 and a stack, then 5 and two")
	assert_eq(Effects.stacks_of(g, "flakked"), 3, "a stack a strike")


## Flak halves at the end of each round, rounded down, until gone (Overcharged's clock): a
## foe's statuses tick at its action, and its Flak waits for the round's end.
func test_flak_halves_at_the_rounds_end_rounded_down_until_gone() -> void:
	var sk := Skirmish.new(1)
	sk.add_mech(_mech("A", Die.single(Face.shield(10)), 0, 500))
	var g := _ghoul(500, 1)
	sk.add_foes([g])
	sk.begin()
	sk.start_round()
	Effects.stack(g, Effects.STATUS["flakked"], Effects.SKIRMISH, "mech", 5, Effects.DECAY_HALF)
	Effects.tick(g, false)
	assert_eq(Effects.stacks_of(g, "flakked"), 5, "a foe's action leaves its Flak alone")
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "flakked"), 2, "the round's end halves it, rounded down")
	sk.start_round()
	sk.end_round()
	assert_eq(Effects.stacks_of(g, "flakked"), 1, "two to one")
	sk.start_round()
	sk.end_round()
	assert_false(Effects.has(g, "flakked"), "and one halves to none")
	var ov := _mech("B", Die.single(Face.shield(10)), 0, 100)
	Effects.stack(ov, Effects.STATUS["overcharged"], Effects.SKIRMISH, "buff", 4, Effects.DECAY_HALF)
	Effects.tick(ov)
	assert_eq(Effects.stacks_of(ov, "overcharged"), 2, "a machine's tick is the round's end, and halves as before")


## The Barrier (Ryan, 14 October; built 21 October): the next blow a foe lands deals nothing,
## so it never injures, its riders land, and it is spent; a blow of nothing leaves it
## standing, a second grant renews it, and the round's end takes it.
func test_a_barrier_takes_the_next_blow_whole_and_its_riders_land() -> void:
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.buff("barrier")), 0, 100)
	sk.add_mech(m)
	sk.add_foes([_storm(50, 2, ["scorch"])])
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.mechs[0]), "the Barrier goes up")
	assert_true(Effects.has(m, "barrier"), "a buff grants it")
	var fc := sk.forecast(sk.mechs[0], false)
	assert_eq(int(fc["hull_after"]), 50, "the forecast reads it: the first fifty taken whole, the second on bare hull")
	sk.end_round()
	assert_eq(m.hull, 50, "the first blow dealt nothing; the second landed")
	assert_eq(m.damaged_component_count(), 1, "the second injured; the first never could")
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
	assert_false(Effects.has(b, "barrier"), "the round's end takes it unspent")
	assert_eq(b.hull, 100, "and nothing struck")


## The Ward (Ryan, 14 October; built 21 October): every blow a foe lands on the machine that
## round leaves no rider, a breach included, so the shield absorbs it; the damage lands.
func test_a_ward_turns_away_every_rider_and_the_breach_for_the_round() -> void:
	var sk := Skirmish.new(1, 1)
	var m := _mech("A", Die.single(Face.buff("ward")), 30, 100)
	sk.add_mech(m)
	sk.add_foes([_storm(20, 2, ["breach", "scorch", "corrupt"])])
	sk.begin()
	sk.start_round()
	assert_eq(int(sk.forecast(sk.mechs[0], false)["hull_after"]), 60, "unwarded, both blows breach past the shield")
	assert_true(sk.assign(0, sk.mechs[0]), "the Ward goes up")
	var fc := sk.forecast(sk.mechs[0], false)
	assert_eq(int(fc["shield_after"]), 0, "warded, the shield takes thirty of the forty")
	assert_eq(int(fc["hull_after"]), 90, "and ten pass")
	sk.end_round()
	assert_eq(m.shield, 0, "the shield absorbed the needle")
	assert_eq(m.hull, 90, "the damage landed")
	assert_eq(Effects.stacks_of(m, "scorched"), 0, "no scorch")
	assert_eq(Effects.corrupt_stacks(m, 0), 0, "no corruption")
	var said := "\n".join(sk.log)
	assert_true(said.contains("the Ward turns storm's breach away") and said.contains("the Ward turns storm's riders away"), "the log says so")
	assert_false(Effects.has(m, "ward"), "the round's end takes it")
	sk.start_round()
	sk.end_round()
	assert_eq(m.hull, 50, "unwarded the next round, both blows breach")
	assert_eq(Effects.stacks_of(m, "scorched"), 2, "and both riders land")


## The cooldown (Ryan, 14 October; built 21 October): a printed property, the entry dark for
## the rounds it says, this one included, shown with the rounds left; no cleanse lifts it,
## and a crack keeps it, a price as heat is.
func test_a_printed_cooldown_darkens_its_entry_for_the_rounds_it_says() -> void:
	var gun := Face.attack(10, L)
	gun.cooldown = 2
	assert_eq(gun.describe(), "10 cooldown 2", "the entry says its cooldown")
	assert_true(gun.has_unique_rule(), "a printed rule: the star chip")
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
	assert_eq(Effects.dark_rounds(m, 0, sk.round), 2, "two rounds left, this one included")
	assert_false(Effects.cleansable_disable(m, 0), "and no cleanse lifts it")
	assert_eq(Effects.dark_rounds(m, 1, sk.round), 0, "the other entry is lit")
	sk.end_round()
	sk.start_round()
	assert_true(Effects.is_entry_disabled(m, 0), "still dark the next round")
	assert_eq(Effects.dark_rounds(m, 0, sk.round), 1, "its last")
	ms.face_index = 0
	assert_true(ms.face().disabled, "the die landing on it shows it dark")
	sk.end_round()
	sk.start_round()
	assert_false(Effects.is_entry_disabled(m, 0), "lit again the round after")
	var cracked := gun.duplicate_face()
	cracked.crack()
	assert_eq(cracked.cooldown_rounds(), 2, "a crack keeps a printed cooldown")
	var round_trip := Face.from_dict(gun.to_dict())
	assert_eq(round_trip.cooldown_rounds(), 2, "and a save keeps it")


## Rapid's switch-off is a cooldown of one, the rest of this round (the cooldown row); a Rapid
## entry that prints no cooldown chains onto a copy of itself and back, its heat the limiter.
func test_rapid_is_a_cooldown_of_one_unless_it_prints_none() -> void:
	var zap := Face.attack(10, L, [K.RAPID])
	assert_eq(zap.cooldown_rounds(), 1, "Rapid's own cooldown")
	assert_eq(zap.describe(), "10 rapid", "unsaid: the keyword says it")
	assert_false(zap.has_unique_rule(), "and no star for it")
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
	assert_false(ms.assigned, "and the machine acts again")
	sk.end_round()
	sk.start_round()
	assert_false(Effects.is_entry_disabled(m, 0), "lit the next round")
	var z := zap.duplicate_face()
	z.crack()
	assert_eq(z.cooldown_rounds(), 0, "a cracked Rapid entry lost its switch-off with the keyword")
	var hot := Face.from_dict({"kind": "attack", "reach": "direct", "power": 10, "keywords": ["rapid"], "heat": 5, "cooldown": 0})
	assert_eq(hot.cooldown_rounds(), 0, "it prints none")
	assert_eq(hot.describe(), "10 rapid no cooldown (+5 heat)", "and says so")
	assert_true(hot.has_unique_rule(), "a printed rule")
	assert_eq(int(hot.to_dict()["cooldown"]), 0, "kept through a save")
	var s2 := Skirmish.new(1)
	var n := _mech("B", Die.of([hot, hot.duplicate_face()]), 40, 100)
	s2.add_mech(n)
	s2.add_foes([_ghoul(500, 1)])
	s2.begin()
	s2.start_round()
	var ns: Skirmish.MechState = s2.mechs[0]
	ns.face_index = 0
	var heat_before := ns.heat
	for i in range(3):
		assert_true(s2.assign(0, s2.front[0]), "spend %d" % i)
		assert_false(Effects.is_entry_disabled(n, 0) or Effects.is_entry_disabled(n, 1), "nothing dark")
	assert_eq(ns.heat - heat_before, 15, "three spends at five heat each")
	assert_eq(ns.face_index, 1, "off the first copy onto the second, back, and onto the second again")


const STEP_PASSIVE := {"id": "test_step", "name": "Step", "description": "", "effects": [{"trigger": "static", "effect": "step_die", "value": 1}]}


## A stepping die (the Cassowary's Indexed Cylinder, Ryan's wording of 12 October; built 21
## October): the fight's first roll spins it to a random entry, then every roll steps it to the
## next in order: the round's roll, a reroll, Rapid's free reroll; a lock holds it, and a foe's
## Scramble is a true roll, the sequence running on from where it lands.
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
	Effects.grant_for_rounds(u, Effects.STATUS["scrambled"], "foe:x", sk.round + 1)
	var landed := {}
	for k in range(30):
		Effects.grant_for_rounds(u, Effects.STATUS["scrambled"], "foe:x", sk.round + 1)
		sk.rerolls_left = 3
		var before := ms.face_index
		sk.reroll([0])
		landed[ms.face_index == before] = true
	assert_true(landed.has(true) and landed.has(false), "a scrambled reroll is a true roll: it may land where it stood")
	sk.rerolls_left = 3
	var from := ms.face_index
	sk.reroll([0])
	assert_eq(ms.face_index, (from + 1) % 4, "and the sequence runs on from where it lands")
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


## A spin (the Spin-Up's, Ryan's exception to the reroll rule, 19 October): a Rapid entry whose
## free reroll is a true roll over every entry, itself included, on a stepping die or any.
func test_a_spinning_rapid_entry_rolls_true_and_may_land_on_itself() -> void:
	var spin := Face.from_dict({"kind": "buff", "status": "spun_up", "stacks": 1, "targets": "self", "keywords": ["rapid"], "cooldown": 0, "spins": true})
	assert_true(spin.spins and spin.has_unique_rule(), "a printed rule: the star")
	assert_eq(spin.describe(), "Spun Up ×1 rapid no cooldown spins the die (self only)", "the entry says what it does")
	var crack := spin.duplicate_face()
	crack.crack()
	assert_false(crack.spins, "a crack takes the spin with Rapid")
	var landed := {}
	for seed_value in range(60):
		var sk := Skirmish.new(seed_value)
		var u := _mech("A", Die.of([spin, Face.attack(10, L), Face.attack(20, L)]), 40, 100)
		u.grant_passive(STEP_PASSIVE)
		sk.add_mech(u)
		sk.add_foes([_ghoul(500, 1)])
		sk.begin()
		sk.start_round()
		sk.mechs[0].face_index = 0
		assert_true(sk.assign(0, sk.mechs[0]), "the spin is spent")
		landed[sk.mechs[0].face_index] = true
	assert_eq(landed.size(), 3, "it lands anywhere, itself included: %s" % str(landed.keys()))


## Spun Up (the Cassowary's, Ryan's go of 19 October; built 21 October): +5 a stack on the next
## weapon spend, stacking, carried between turns until a weapon spends it, damage or none.
func test_spun_up_lasts_until_a_weapon_spends_it_and_adds_five_a_stack() -> void:
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
	assert_eq(sk.shown_number_text(ms, ms.face(), g), "20", "the die shows the ten it adds")
	assert_true(sk.assign(0, g), "a shot")
	assert_eq(g.hp, 480, "ten and its two stacks' ten")
	assert_false(Effects.has(u, "spun_up"), "spent whole")
	sk.end_round()
	sk.start_round()
	Effects.grant_buff(u, "spun_up", 1, "buff", sk.round)
	ms.face_index = 1
	assert_true(sk.assign(0, g), "a weapon of no damage")
	assert_false(Effects.has(u, "spun_up"), "spends it too")


## Every n-th shot (the Cassowary's sixth, Ryan's kit of 18 October; built 21 October): the
## weapon spend the count lands on doubles its damage and the stacks it lays; equipment and
## spins are no shots, and the count resets each fight.
func test_every_nth_shot_doubles_its_damage_and_the_stacks_it_lays() -> void:
	var sk := Skirmish.new(1)
	var torch := Face.attack(10, L, [K.BURN])
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
	var burning := Effects.stacks_of(g, "burning")
	sk.assign(0, g)
	assert_eq(hp - g.hp, 20, "its damage doubled")
	assert_eq(Effects.stacks_of(g, "burning") - burning, 2, "and its Burn's stack laid twice")
	assert_true("\n".join(sk.log).contains("the third shot counts double"), "the log says so")
	assert_false(Effects.nth_shot_due(u), "the count runs on")
	Effects.end_skirmish(u)
	assert_eq(Effects.stacks_of(u, "shots"), 0, "and resets with the fight")


const DRUM_PASSIVE := {"id": "test_drum", "name": "Drum", "description": "", "effects": [
	{"trigger": "static", "effect": "rewrite_weapon", "value": 15, "reach": "indirect", "heat": 10, "tag": "ballistic"},
	{"trigger": "static", "effect": "grant_keyword", "value": "penetrate", "when": "target_rank", "rank": "back"},
	{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "target_rank", "rank": "front"}]}


## The drum (the Cottonmouth's Adaptive Munitions Drum, Ryan's go of 19 October; built 21
## October): every weapon leaves as the drum's shot, Indirect, a flat 15, heat 10, one blow,
## Ballistic, its own keywords kept; aimed at the front rank it sprays (Spread), at the back
## it punches through (Penetrate); equipment fires as itself, and the die keeps the real entry.
func test_a_drum_fires_every_weapon_as_its_shot_by_the_rank_it_is_aimed_at() -> void:
	var sk := Skirmish.new(1, 3)
	var gun := Face.attack(40, L, [K.BURN])
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
	assert_eq([shot.power, shot.power_max, shot.reach, shot.heat, shot.strikes], [15, 15, I, 10, 1], "the drum's shot: a flat 15, Indirect, heat 10, one blow")
	assert_true(shot.has(K.BURN) and shot.tags.has("ballistic"), "its own keyword kept, Ballistic added")
	assert_eq(gun.power, 40, "the die keeps the real entry")
	assert_false(shot.has(K.CLEAVE) or shot.has(K.PENETRATE), "no rank keyword without a target")
	var mid: Foe = sk.front[1]
	assert_true(sk.shown_face(ms, ms.face(), mid).has(K.CLEAVE), "over the front rank it shows Spread")
	assert_true(sk.shown_face(ms, ms.face(), sk.back[2]).has(K.PENETRATE), "over the back rank, Penetrate")
	assert_true(sk.assign(0, mid), "fired at the front")
	for f in sk.front:
		assert_eq(f.hp, 85, "the spray lands 15 on the target and each neighbour")
		assert_true(Effects.has(f, "burning"), "with the Burn it kept")
	assert_eq(ms.heat, 10, "at the drum's heat")
	assert_true(u.shield < 40, "danger close: the front-rank spray costs shield")
	sk.end_round()
	sk.start_round()
	ms.face_index = 0
	var back: Foe = sk.back[2]
	var front_hp: int = sk.front[2].hp
	var other_hp: int = sk.front[0].hp
	assert_true(sk.assign(0, back), "fired at the back")
	assert_eq(back.hp, 85, "the shot lands on the back foe")
	assert_eq(sk.front[2].hp, front_hp - 15, "and punches through the front foe of its column")
	assert_eq(sk.front[0].hp, other_hp, "and no other")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	assert_eq(sk.shown_face(ms, ms.face()).power, 20, "equipment fires as itself")

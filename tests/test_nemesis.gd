extends TestCase

## The Nemesis's Rage (Ryan, 23 November: "change rage into simply generating heat, using the same
## rules as rage generation"; "Knuckles of Fury generates no heat and is no longer instant. It deals
## damage and cools the Nemesis by 3. When in Rage, it has Instant"; "When the Nemesis starts its turn
## with heat at or over max, it gains the unpurgable status Rage: Remove all debuffs on self. Immune to
## all debuffs. The only component available is Knuckles of Fury"; "Rage ends when the Nemesis' heat
## reaches zero, at which point it immediately reboots, regardless of how it got there"; "Nemesis
## never reboots voluntarily at max heat, yes"; "I'm leaving the option open for the player to end
## turn at any time, the nemesis is just still stuck in rage"), on synthetic passives and pieces: a
## turn opened at the maximum rages, its debuffs lifted and none landing, its die its rage piece
## alone and Instant; it swings until its heat runs out and reboots at once, however the heat went;
## an ended turn leaves it raging and burning; it never reboots by choice at its maximum; out of the
## Rage the piece is a plain swing that cools its machine; the validator holds the new keys; the bot
## swings a Rage down.

const L := Face.Reach.DIRECT

## The rage form: its piece the synthetic fist.
const FURY := {"id": "fury", "name": "Fury", "description": "", "effects": [
	{"trigger": "static", "effect": "rage_form", "piece": "test_fist"}]}


## A fist: a swing of `power` that cools its machine `cools`.
func _fist(power: int = 5, cools: int = 3) -> Face:
	var f := Face.from_dict({"kind": "attack", "reach": "direct", "power": power, "heat": 0, "self_vent": cools})
	f.component = "test_fist"
	return f


func _mech(name: String, d: Die, heat_max: int = 9, shield: int = 10, hull: int = 200) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.heat_max = heat_max
	u.die = d
	return u


func _nemesis() -> Unit:
	var u := _mech("N", Die.of([Face.attack(2, L, [], 4), Face.attack(2, L, [], 4), _fist()]))
	u.grant_passive(FURY)
	return u


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


## Its next turn opened at `heat`.
func _rage_at(sk: Skirmish, heat: int) -> void:
	sk.mechs[0].heat = heat
	sk.end_round()
	sk.start_round()


func test_a_turn_opened_at_its_maximum_rages_its_debuffs_lifted_and_its_die_all_fists() -> void:
	var u := _nemesis()
	var sk := _fight([u], [Foe.make("dummy", 900, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_false(Effects.raging(u), "cold, no Rage")
	Effects.stack(u, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "foe:test", 3, Effects.DECAY_NONE)
	_rage_at(sk, 9)
	assert_true(Effects.raging(u), "it opens its turn at its maximum: it rages")
	assert_false(Effects.has(u, "ablating_mech"), "its debuffs lifted")
	assert_eq(Effects.live_entries(u, u.die), [2], "its die rolls among the fist alone")
	assert_eq(ms.face().component, "test_fist", "and shows it")
	assert_true(Effects.effective_face(u, ms.face()).has(Face.Keyword.INSTANT), "Instant while it rages")
	assert_true(sk.log.any(func(l: String) -> bool: return l.begins_with("N rages")), "the log says so")
	assert_true(Effects.stack(u, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "foe:test", 2, Effects.DECAY_NONE) == null, "no debuff lands on it")
	assert_false(Effects.has(u, "ablating_mech"), "none")
	assert_true(Effects.grant_buff(u, "overcharged", 1, "test", sk.round) != null, "a buff lands as ever")
	assert_false(sk.reroll([0]), "its die rerolls nothing: the fist is all it shows")
	var ag := Effects.STATUS["rage"]
	assert_true((ag.get("tags", []) as Array).has("ability"), "an ability: no Purge touches it")


func test_a_raging_machine_swings_until_its_heat_runs_out_then_reboots_at_once() -> void:
	var u := _nemesis()
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	_rage_at(sk, 9)
	for k in range(2):
		assert_true(sk.assign(0, sk.front[0]), "a swing")
		assert_false(ms.assigned, "Instant: it swings again")
	assert_eq(ms.heat, 3, "three off its nine a swing")
	assert_true(sk.assign(0, sk.front[0]), "the third")
	assert_eq(foe.hp, 900 - 15, "three swings of five")
	assert_false(Effects.raging(u), "at no heat its Rage ends")
	assert_true(ms.rebooting, "and it reboots at once")
	assert_true(ms.assigned, "its turn over: nothing acts again")
	assert_eq(u.shield, 0, "bare through the enemy's turn")
	assert_true(sk.log.any(func(l: String) -> bool: return l.begins_with("N reboots as its rage is spent")), "the log says why")
	sk.end_round()
	sk.start_round()
	assert_eq([u.shield, ms.heat], [10, 0], "whole and cold as the next round opens")
	assert_false(Effects.raging(u), "and calm")


func test_an_ended_turn_leaves_it_raging_and_what_stands_past_its_maximum_burns() -> void:
	var u := _nemesis()
	var sk := _fight([u], [Foe.make("dummy", 900, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	_rage_at(sk, 12)
	assert_true(Effects.raging(u), "past its maximum, it rages")
	var hull := u.hull
	sk.end_round()
	assert_eq(hull - u.hull, 3, "its three past the maximum burn as the turn it ended unspent ends")
	sk.start_round()
	assert_true(Effects.raging(u), "it rages on")
	assert_eq(ms.face().component, "test_fist", "its die still all fists")
	assert_false(sk.can_reboot(0), "and no reboot by choice")


func test_the_rage_ends_at_no_heat_however_it_got_there() -> void:
	var u := _nemesis()
	var puffin := _mech("P", Die.single(Face.from_dict({"kind": "buff", "status": "overcharged", "stacks": 1})), 30)
	puffin.grant_passive({"id": "pull", "name": "Pull", "description": "", "effects": [{"trigger": "on_buff_granted", "effect": "pull_heat", "value": 9}]})
	var sk := _fight([u, puffin], [Foe.make("dummy", 900, 0)])
	var ms: Skirmish.MechState = sk.mechs[0]
	_rage_at(sk, 9)
	assert_true(Effects.raging(u), "raging")
	assert_true(sk.assign(1, ms), "an ally's equipment on it takes its nine")
	assert_eq(ms.heat, 0, "cold")
	assert_false(Effects.raging(u), "its Rage ends")
	assert_true(ms.rebooting, "and it reboots at once, its own die unspent")


func test_a_machine_that_would_rage_never_reboots_by_choice_at_its_maximum() -> void:
	var u := _nemesis()
	var plain := _mech("Q", Die.single(Face.attack(2, L)))
	var sk := _fight([u, plain], [Foe.make("dummy", 900, 0)])
	sk.mechs[0].heat = 8
	assert_true(sk.can_reboot(0), "under its maximum it may")
	sk.mechs[0].heat = 9
	assert_false(sk.can_reboot(0), "at it, not yet raging, never by choice")
	sk.mechs[1].heat = 9
	assert_true(sk.can_reboot(1), "a machine with no rage form at its maximum may")


func test_out_of_its_rage_a_fist_is_a_plain_swing_that_cools_its_machine() -> void:
	var u := _nemesis()
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 5
	ms.face_index = 2
	assert_false(Effects.effective_face(u, ms.face()).has(Face.Keyword.INSTANT), "calm: no Instant")
	assert_eq(Policy.heat_of(ms, ms.face()), -3, "the bot reads its cooling as heat off")
	assert_true(sk.assign(0, foe), "a swing")
	assert_eq([ms.heat, foe.hp], [2, 895], "five, and three off its five")
	assert_true(ms.assigned, "its turn spent")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("N cools 3 as it strikes")), "the log says so")
	sk.end_round()
	sk.start_round()
	ms.heat = 1
	ms.face_index = 2
	assert_true(sk.assign(0, foe), "a swing on one heat")
	assert_eq(ms.heat, 0, "it cools what it has")
	assert_false(ms.rebooting, "calm at no heat: no reboot")
	assert_true(_fist().describe().contains("cools itself 3"), "its text says its rule: %s" % _fist().describe())
	var back := Face.from_dict(_fist().to_dict())
	assert_eq(back.self_vent, 3, "the rule survives the save")
	assert_true(Effects.effect_text(FURY["effects"][0]).contains("it rages"), "the rage form reads as a sentence")


func test_a_raging_machine_turns_a_foes_debuff_riders_away() -> void:
	var u := _nemesis()
	var jammer := Foe.make("dummy", 900, 2)
	jammer.actions[0]["keywords"] = ["jam"]
	var sk := _fight([u], [jammer])
	_rage_at(sk, 12)
	assert_true(Effects.raging(u), "raging")
	sk.end_round()
	assert_eq(Effects.jams_waiting(u), 0, "no jam lands")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("N's Rage turns dummy's debuffs away") or l.contains("Rage turns")), "the log says the Rage turned it away")


func test_the_bot_swings_a_rage_down_and_the_reboot_follows() -> void:
	var u := _nemesis()
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	_rage_at(sk, 9)
	Policy.make(Policy.GREEDY, 1).play_round(sk)
	assert_true(ms.rebooting, "it swung its nine away and rebooted")
	assert_eq(foe.hp, 900 - 15, "three swings")


func test_the_validator_holds_the_rage_and_the_cooling_to_their_shapes() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var errs: Array[String] = []
	db._validate_passive("probe", {"id": "p", "name": "P", "description": "P.", "effects": [{"trigger": "on_hull_damage", "effect": "gain_heat", "value": 0}]}, errs)
	assert_true(errs.any(func(e: String) -> bool: return e.contains("gain_heat is the heat")), "a heat of nothing is refused")
	errs.clear()
	db._validate_passive("probe", {"id": "p", "name": "P", "description": "P.", "effects": [{"trigger": "static", "effect": "gain_heat", "value": 1}]}, errs)
	assert_true(errs.any(func(e: String) -> bool: return e.contains("not implemented")), "gain_heat fires on a blow, never static")
	errs.clear()
	db._validate_passive("probe", {"id": "p", "name": "P", "description": "P.", "effects": [{"trigger": "static", "effect": "rage_form", "piece": "no_such_piece"}]}, errs)
	assert_true(errs.any(func(e: String) -> bool: return e.contains("names its piece")), "a rage form names a component")
	var cid := ""
	for id in db.chassis.keys():
		if str(db.chassis[id].get("status", "")) != "planned" and db.chassis[id].get("passive", null) is Dictionary:
			cid = str(id)
			break
	var c: Dictionary = db.chassis[cid].duplicate(true)
	var piece := str(db.components.keys()[0])
	c["passive"] = {"id": "probe_fury", "name": "Fury", "description": "Fury.", "effects": [{"trigger": "static", "effect": "rage_form", "piece": piece}]}
	c["fixed"] = []
	db.chassis["probe_rager"] = c
	assert_true(db.validate().any(func(e: String) -> bool: return e.begins_with("chassis probe_rager") and e.contains("one of its fixed components")), "its piece is one of its fixed components")
	db.chassis.erase("probe_rager")
	var gun: Dictionary = db.components[piece].duplicate(true)
	gun["face"] = {"kind": "buff", "status": "overcharged", "stacks": 1, "self_vent": 3}
	gun["tier"] = 1
	db.components["probe_cooler"] = gun
	assert_true(db.validate().any(func(e: String) -> bool: return e.begins_with("component probe_cooler") and e.contains("self_vent")), "a cooling of its own is an attack's")

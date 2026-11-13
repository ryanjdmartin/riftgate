extends TestCase

## What a kill is (Ryan, 8 November, the audit's fourth question): a foe the death check clears
## that stays down. A merge is none, nor a foe queued to get back up or to split ("If a foe is
## killed during the death check and revives, that shouldn't count for kill triggers. Same with
## gel splits"), nor a part, whatever fells it, only its core ("technically one giant unit,
## thematically, the parts are extensions"; "I thought I said only the core counts"), nor a foe
## gone whole by its own burst. One count, read by the kill triggers, the grudge, salvage and
## menace.

const L := Face.Reach.DIRECT
const I := Face.Reach.INDIRECT

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


func _foe(id: String, hp: int, atk: int = 1) -> Foe:
	var f := Foe.make(id, hp, atk)
	f.content_id = id
	return f


func _pack(id: int) -> Unit:
	return Unit.pack(id, "pack", Vector2i.ZERO)


func _rise(f: Foe) -> void:
	Effects.stack(f, Effects.STATUS["risen"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)


func test_a_foe_that_gets_back_up_is_no_kill_until_it_stays_down() -> void:
	var gun := Face.attack(30, L)
	gun.kill_rerolls = 2   # the Spindrift Salvo's rider: a kill trigger
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(gun)))
	var sq := _pack(7)
	var g := _foe("revenant", 20)
	sk.add_foes([g, _foe("revenant", 500)], sq)
	sk.begin()
	sk.start_round()
	_rise(g)
	var rerolls := sk.rerolls_left
	assert_true(sk.assign(0, g), "felled")
	assert_true(g.alive(), "it got back up once the spend was done")
	assert_eq(sk.team_kills, 0, "no kill: it got back up")
	assert_eq(sk.rerolls_left, rerolls, "so the kill trigger fired nothing")
	assert_eq(sk.kills_by_type(sq), {}, "and salvage and menace count nothing")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(0, g), "felled again, and it stays down")
	assert_eq(sk.team_kills, 1, "a kill now")
	assert_eq(sk.rerolls_left, rerolls + 2, "the trigger fires")
	assert_eq(sk.kills_by_type(sq), {"revenant": 1}, "and it counts by its type")


func test_a_kill_trigger_fires_at_the_death_check_never_on_a_foe_that_gets_back_up() -> void:
	var sk := Skirmish.new(1, 2)
	var m := _mech("A", Die.single(Face.attack(30, L)))
	m.grant_passive(KILLER)
	sk.add_mech(m)
	var g := _foe("revenant", 20)
	sk.add_foes([g, _foe("revenant", 500)])
	sk.begin()
	sk.start_round()
	_rise(g)
	assert_true(sk.assign(0, g), "it fells a foe that gets back up")
	assert_eq(Effects.stacks_of(m, "overcharged"), 0, "no kill, so its kill trigger stays quiet")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(0, g), "and fell it for good")
	assert_true(Effects.stacks_of(m, "overcharged") > 0, "a kill fires it")


func test_a_split_is_no_kill_and_each_half_is() -> void:
	var sk := Skirmish.new(2, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(200, L))))
	var sq := _pack(3)
	var g := _foe("gel", 30)
	g.on_death = {"summon": "gel_half", "count": 2, "pair": true}
	sk.foe_factory = func(id: String) -> Foe: return _foe(id, 10)
	sk.add_foes([g], sq)
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, g), "the Gel falls and splits")
	assert_eq(sk.team_kills, 0, "no kill: it goes on as its halves")
	assert_eq(sk.kills_by_type(sq), {}, "nothing counted")
	var half: Foe = sk.front[0]
	assert_true(half != null and half.content_id == "gel_half", "a half stands in its slot")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(0, half), "a half falls")
	assert_eq(sk.team_kills, 1, "a kill")
	assert_eq(sk.kills_by_type(sq), {"gel_half": 1}, "by its type")


func test_a_part_its_core_takes_is_no_kill() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, I)), 40, 400))
	var sq := _pack(5)
	var core := _foe("hilt", 20, 10)
	core.part_ids = ["eye", "eye"]
	sk.add_foes([core, _foe("eye", 20), _foe("eye", 20)], sq)
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, core), "the core falls, and its parts with it")
	assert_true(sk.field_foes().is_empty(), "the field is clear")
	assert_eq(sk.team_kills, 1, "one kill: the parts were the core's own")
	assert_eq(sk.kills_by_type(sq), {"hilt": 1}, "the core alone counts")


func test_a_part_is_never_a_kill_only_its_core() -> void:
	var sk := Skirmish.new(1, 3)
	var m := _mech("A", Die.single(Face.attack(60, L)), 40, 400)
	m.grant_passive(KILLER)
	sk.add_mech(m)
	var sq := _pack(6)
	var core := _foe("hilt", 50, 1)
	core.part_ids = ["eye"]
	var eye := _foe("eye", 20)
	sk.add_foes([core, eye, _foe("revenant", 500)], sq)
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, eye), "a part felled while its core stands")
	assert_eq(sk.team_kills, 0, "no kill: a core and its parts are one unit")
	assert_eq(Effects.stacks_of(m, "overcharged"), 0, "so its kill trigger stays quiet")
	assert_eq(sk.kills_by_type(sq), {}, "and salvage and menace count nothing")
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(0, core), "the core falls")
	assert_eq(sk.team_kills, 1, "its fall the one kill")
	assert_true(Effects.stacks_of(m, "overcharged") > 0, "and its kill trigger fires")
	assert_eq(sk.kills_by_type(sq), {"hilt": 1}, "counted by the core's type")


func test_a_part_felled_beside_its_core_getting_back_up_is_no_kill() -> void:
	var sk := Skirmish.new(1, 3)
	sk.add_mech(_mech("A", Die.single(Face.blank()), 40, 400))
	var core := _foe("hilt", 50, 1)
	core.part_ids = ["eye"]
	var eye := _foe("eye", 20)
	sk.add_foes([_foe("revenant", 500), core, eye], _pack(8))
	sk.begin()
	sk.start_round()
	assert_true(core.column < eye.column, "the core's slot clears before its part's")
	_rise(core)
	core.hp = 0
	eye.hp = 0
	sk._clear_dead()   # one death check: the core gets back up, its part stays down
	assert_eq(sk.team_kills, 0, "neither is a kill: the core rises, and a part is never one")
	assert_true(core.alive(), "the core is back up")


func test_a_merge_and_a_burst_are_no_kills() -> void:
	var sk := Skirmish.new(1, 4)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	var sq := _pack(9)
	var king := _foe("king", 90, 6)
	king.actions = [Foe.basic_action(), {"id": "merge", "name": "Merge", "kind": "buff", "effect": "merge", "foe": ["gel"], "value": 1, "weight": 1, "text": ""}]
	var bomb := _foe("bomb", 900)
	bomb.actions = [{"id": "burst", "name": "Burst", "kind": "attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": ["self_destruct"], "text": ""}]
	bomb.action = bomb.actions[0]
	sk.add_foes([king, _foe("gel", 5), _foe("gel", 5), bomb], sq)
	sk.begin()
	sk.start_round()
	king.action = king.actions[1]
	king.last_special = "merge"
	bomb.action = bomb.actions[0]
	bomb.target = sk.mechs[0]
	sk.end_round()
	assert_false(bomb.alive(), "the bomb burst")
	assert_true(sk.field_foes().all(func(f: Foe) -> bool: return f.content_id != "gel"), "the Gels were taken in")
	assert_eq(sk.team_kills, 0, "no kill of the team's")
	assert_eq(sk.kills_by_type(sq), {}, "so salvage and menace count none (the audit's fourth bug)")


func test_the_tally_survives_a_save_and_an_undo() -> void:
	var sk := Skirmish.new(1, 3)
	sk.keeps_undo = true
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	sk.add_mech(_mech("B", Die.single(Face.attack(30, L))))
	var sq := _pack(4)
	var a := _foe("revenant", 20)
	var b := _foe("revenant", 20)
	sk.add_foes([a, b, _foe("revenant", 500)], sq)
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, a), "one falls")
	assert_eq(sk.kills_by_type(sq), {"revenant": 1}, "counted")
	var copy := SaveGame.clone_skirmish(sk)
	assert_eq(copy.kills_by_type(copy.packs[0]), {"revenant": 1}, "the save keeps the tally")
	assert_true(sk.assign(1, b), "the other falls")
	assert_eq(sk.kills_by_type(sq), {"revenant": 2}, "two")
	assert_true(sk.undo(), "taken back")
	assert_eq([sk.kills_by_type(sq), sk.team_kills], [{"revenant": 1}, 1], "an undone kill counts for nothing")


func test_a_save_from_before_the_tally_counts_its_kills_the_old_way() -> void:
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(Face.attack(30, L))))
	var sq := _pack(4)
	sk.add_foes([_foe("revenant", 20), _foe("revenant", 500)], sq)
	sk.begin()
	sk.start_round()
	assert_true(sk.assign(0, sk.front[0]), "one falls")
	var d := SaveGame._fight_dict(sk)
	d.erase("kills")
	d["came_with"] = {"4": {"revenant": 2}}
	d["joined_fallen_types"] = {"4": {"gel_half": 1}}
	var units: Array[Unit] = []
	for ud in d["units"]:
		units.append(SaveGame._unit_from(ud))
	var old := SaveGame._skirmish_build(d, func(at: int) -> Unit: return units[at] if at >= 0 and at < units.size() else null)
	assert_eq(old.kills_by_type(old.packs[0]), {"revenant": 1, "gel_half": 1}, "what it came with less what is left, and every joined foe that fell")

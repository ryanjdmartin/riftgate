extends TestCase

## Ryan's kits of 20 November, on the content's own entries: the gel line that Ablates and
## Brittles where it used to hit ("Honestly I think all gels should Ablate instead of attacking as
## their default"), the King Gel's Dissolve in Body Slam's place, the goblins' Shield Wall over
## their neighbours with a knife only when buffed ("goblins only attack when they have any buff,
## or are predicted to get one"), and the Obsidian Tyrant's Roar that leaves every machine Brittle.
## Numbers are read off content, so a sizing pass that moves one leaves these standing.

const L := Face.Reach.DIRECT


func _mech(name: String, d: Die, shield: int = 0, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _db() -> ContentDB:
	return ContentDB.load_default()


## The rider a content move lays, by its keyword: its own number, a blow's rider or a rider-only
## hit's (a debuff of that effect, its value).
func _rider(db: ContentDB, foe_id: String, move_id: String, kw: String) -> int:
	for a in db.foes[foe_id]["actions"]:
		if str(a.get("id", "")) == move_id:
			if str(a.get("kind", "")) == "debuff":
				return int(a.get("value", 0)) if str(a.get("effect", "")) == kw else 0
			return int(a.get(kw, 0)) if Array(a.get("keywords", [])).has(kw) else 0
	return 0


## One machine against the foes given, each foe set to its first move, every round's announce
## left to the test: the skirmish begun and its first round opened.
func _fight(foes: Array, db: ContentDB, columns: int = 4, hull: int = 100) -> Skirmish:
	var sk := Skirmish.new(1, columns)
	sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
	sk.add_mech(_mech("A", Die.single(Face.blank()), 0, hull))
	sk.add_foes(foes)
	sk.begin()
	return sk


func test_every_gel_lays_its_kits_rider_and_the_half_gels_engulf_is_a_rider_only_hit() -> void:
	var db := _db()
	# Each of the line's Engulfs, on a bare machine: the stacks content names, Ablating on the
	# machine and Brittle, and the blow its attack says.
	var cases := {
		"gel": {"ablating_mech": _rider(db, "gel", "engulf", "ablate"), "brittled_mech": 0},
		"gel_half": {"ablating_mech": _rider(db, "gel_half", "engulf", "ablate"), "brittled_mech": 0},
		"bubble_gel": {"ablating_mech": 0, "brittled_mech": _rider(db, "bubble_gel", "engulf", "brittle")},
		"bubble_gel_half": {"ablating_mech": 0, "brittled_mech": _rider(db, "bubble_gel_half", "engulf", "brittle")},
		"molten_gel": {"ablating_mech": _rider(db, "molten_gel", "engulf", "ablate"), "brittled_mech": _rider(db, "molten_gel", "engulf", "brittle")},
		"molten_gel_half": {"ablating_mech": _rider(db, "molten_gel_half", "engulf", "ablate"), "brittled_mech": _rider(db, "molten_gel_half", "engulf", "brittle")},
	}
	for id in cases.keys():
		var g := db.make_foe(id)
		var sk := _fight([g], db)
		sk.start_round()
		g.target = sk.mechs[0]
		var m: Unit = sk.mechs[0].unit
		sk.end_round()
		for st in cases[id].keys():
			var want := int(cases[id][st])
			# Ablating takes its first point at the end of the player's turn, after the foes'; read
			# the stacks before that tick: laid this turn, the stacks stand whole.
			assert_eq(Effects.stacks_of(m, st), want, "%s lays %s ×%d" % [id, st, want])
		assert_eq(100 - m.hull, int(db.foes[id]["attack"]), "%s's Engulf is its attack on a bare hull" % id)
	# The Half-Gel's Engulf is no blow (Ryan, 20 November: "I didn't mean 'attack of zero' I meant
	# just an ablate"): a rider-only hit, a debuff with its Ablating.
	var half_engulf: Dictionary = db.foes["gel_half"]["actions"][0]
	assert_false(Foe.is_attack_action(half_engulf), "the Half-Gel's Engulf is no blow")
	assert_true(_rider(db, "gel_half", "engulf", "ablate") > 0, "and lays its Ablate")


func test_each_gel_splits_into_its_own_halves_and_the_merge_takes_the_whole_line() -> void:
	var db := _db()
	for pair in [["gel", "gel_half"], ["bubble_gel", "bubble_gel_half"], ["molten_gel", "molten_gel_half"]]:
		var od: Dictionary = db.foes[pair[0]].get("on_death", {})
		assert_eq(str(od.get("summon", "")), pair[1], "%s splits into %s" % pair)
		assert_eq(int(od.get("count", 0)), 2, "two of them")
		assert_false(db.foes[pair[1]].has("on_death"), "and a half splits no further")
	assert_false(db.foes.has("metal_gel"), "the Metal Gel is the Molten Gel (Ryan, 20 November)")
	var merge: Array = []
	for a in db.foes["king_gel"]["actions"]:
		if str(a.get("effect", "")) == "merge":
			merge = Array(a["foe"])
	for id in ["gel", "gel_half", "bubble_gel", "bubble_gel_half", "molten_gel", "molten_gel_half"]:
		assert_true(merge.has(id), "the King's Merge takes %s in" % id)


func test_the_king_gel_dissolves_where_it_slammed() -> void:
	var db := _db()
	var ids: Array = []
	for a in db.foes["king_gel"]["actions"]:
		ids.append(str(a.get("id", "")))
	assert_false(ids.has("body_slam"), "Body Slam is gone (Ryan: \"King gel then loses body slam\")")
	assert_true(ids.has("dissolve"), "Dissolve stands in its place")
	assert_eq(ids.size(), 3, "three moves, a boss's")
	# Dissolve on a machine carrying a Barrier: the Purge takes the Barrier first, the blow lands,
	# and the machine is Brittle and Ablating as content says.
	var king := db.make_foe("king_gel")
	for a in king.actions:
		if str(a.get("id", "")) == "dissolve":
			king.action = a
	var sk := _fight([king], db, 4, 200)
	sk.start_round()
	var m: Unit = sk.mechs[0].unit
	Effects.grant_buff(m, "barrier", 1, "test", sk.round + 1)
	for a in king.actions:
		if str(a.get("id", "")) == "dissolve":
			king.action = a
	king.target = sk.mechs[0]
	sk.end_round()
	assert_false(Effects.has(m, "barrier"), "the Purge took the Barrier before the blow")
	assert_true(m.hull < 200, "so the blow landed")
	assert_eq(Effects.stacks_of(m, "brittled_mech"), _rider(db, "king_gel", "dissolve", "brittle"), "Brittle as Dissolve says")
	assert_eq(Effects.stacks_of(m, "ablating_mech"), _rider(db, "king_gel", "dissolve", "ablate"), "Ablating as Dissolve says")


func test_the_shield_wall_covers_itself_and_its_neighbours_and_walls_add() -> void:
	var db := _db()
	var goblins: Array = []
	for i in range(4):
		goblins.append(db.make_foe("goblin"))
	var sk := _fight(goblins, db)
	sk.start_round()
	# The first and the third raise the wall; the second stands between two.
	var wall: Dictionary = {}
	for a in goblins[0].actions:
		if str(a.get("effect", "")) == "brace_beside":
			wall = a
	assert_false(wall.is_empty(), "the goblin's Shield Wall is the wall over its neighbours")
	for g in goblins:
		g.action = Foe.basic_action()
		g.target = sk.mechs[0]
	goblins[0].action = wall
	goblins[2].action = wall
	sk.end_round()
	var armour: Array = []
	for g in goblins:
		armour.append(Effects.stacks_of(g, "braced"))
	assert_eq(armour, [1, 2, 1, 1], "a wall covers itself and the one beside it on each side; two walls add on the goblin between them")
	assert_eq(sk.foes_beside(goblins[0]), [goblins[1]] as Array[Foe], "the first in the rank has one neighbour")
	assert_eq(sk.foes_beside(goblins[1]).size(), 2, "the second has two")
	# All four walling: three at the most, on the two in the middle (Ryan: "it would be 3 max").
	var s2 := _fight([db.make_foe("goblin"), db.make_foe("goblin"), db.make_foe("goblin"), db.make_foe("goblin")], db)
	s2.start_round()
	var row: Array = []
	for f in s2.field_foes():
		f.action = wall
		row.append(f)
	s2.end_round()
	var most := 0
	for f in row:
		most = maxi(most, Effects.stacks_of(f, "braced"))
	assert_eq(most, 3, "four walls at once: three on a goblin between two")


func test_a_goblin_strikes_only_with_a_buff_on_it_or_one_coming() -> void:
	var db := _db()
	var g := db.make_foe("goblin")
	assert_true(g.strikes_when_buffed, "the goblin carries the rule (content's strikes_when_buffed)")
	var sk := _fight([g], db)
	# Bare and alone: it walls, never stabs.
	for i in range(8):
		var legal := sk.legal_actions(g, [])
		for a in legal:
			assert_false(Foe.is_attack_action(a), "a bare goblin announces no blow")
	# With armour on it: its knife alone.
	Effects.stack(g, Effects.STATUS["braced"], Effects.SKIRMISH, "test", 1, Effects.status_decay(Effects.STATUS["braced"]))
	for a in sk.legal_actions(g, []):
		assert_true(Foe.is_attack_action(a), "a shielded goblin announces its knife")
	# A peer's wall announced ahead of it, covering it: the knife.
	var h := db.make_foe("goblin")
	var p := db.make_foe("goblin")
	var s2 := _fight([p, h], db)
	for a in p.actions:
		if str(a.get("effect", "")) == "brace_beside":
			p.action = a
	assert_true(s2.buffed_or_coming(h, [p]), "the wall beside it, announced ahead of it, is a buff coming")
	for a in s2.legal_actions(h, [p]):
		assert_true(Foe.is_attack_action(a), "so it queues the knife")
	# A rally announced ahead of it is a buff coming too.
	var shaman := Foe.make("shaman", 20, 5, true)
	shaman.action = {"id": "bloodlust", "name": "Bloodlust", "kind": "buff", "effect": "rally", "value": 2, "weight": 1, "text": ""}
	var k := db.make_foe("goblin")
	var s3 := _fight([k, shaman], db)
	assert_true(s3.buffed_or_coming(k, [shaman]), "a rally announced ahead of it is a buff coming")
	assert_false(s3.buffed_or_coming(k, []), "with nothing announced and nothing on it, none")


func test_the_round_opens_with_bare_goblins_walling_and_their_neighbours_stabbing() -> void:
	# Four goblins, all bare as the fight opens: in the order they strike, the first walls (nothing
	# on it, nothing coming), the second stabs (the first's wall covers it), the third walls (no
	# wall covers it yet), the fourth stabs. The next round every one of them is shielded and stabs.
	var db := _db()
	var row: Array = []
	for i in range(4):
		row.append(db.make_foe("goblin"))
	var sk := _fight(row, db)
	sk.start_round()
	var first: Array = []
	for f in row:
		first.append(Foe.is_attack_action(f.action))
	assert_eq(first, [false, true, false, true], "wall, stab, wall, stab")
	sk.end_round()
	sk.start_round()
	var second: Array = []
	for f in row:
		second.append(Foe.is_attack_action(f.action))
	assert_eq(second, [true, true, true, true], "every one shielded as the next round opens, so every one stabs")


func test_the_tyrants_roar_drains_and_leaves_every_machine_brittle() -> void:
	var db := _db()
	var roar: Dictionary = {}
	for a in db.foes["obsidian_tyrant"]["actions"]:
		if str(a.get("id", "")) == "roar":
			roar = a
	assert_eq(str(roar.get("effect", "")), "drain_rerolls", "the Roar still drains")
	var steps: Array = roar.get("also", [])
	assert_eq(str(steps[0].get("effect", "")), "brittle_all", "and leaves every machine Brittle (Ryan: \"Tyrant is good\")")
	var t := Foe.make("tyrant", 200, 5)
	t.actions = [roar]
	t.action = roar
	var sk := Skirmish.new(1, 2)
	sk.add_mech(_mech("A", Die.single(Face.blank())))
	sk.add_mech(_mech("B", Die.single(Face.blank())))
	sk.add_foes([t])
	sk.begin()
	sk.start_round()
	t.action = roar
	sk.end_round()
	var want := int(steps[0].get("value", 0))
	for ms in sk.mechs:
		assert_eq(Effects.stacks_of(ms.unit, "brittled_mech"), want, "%s Brittle ×%d" % [ms.unit.display_name, want])

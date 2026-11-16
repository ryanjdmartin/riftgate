extends TestCase



## A component of content as a template for a test's own piece, read by the validator like any
## built piece: the shields and vents are planned drafts since the refit pass landed (10
## November), and a draft's face is not held to the engine, which these tests need it to be.
func _piece(db: ContentDB, id: String) -> Dictionary:
	var c: Dictionary = db.components[id].duplicate(true)
	c.erase("status")
	return c

func _db() -> ContentDB:
	return ContentDB.load_default()


func test_content_loads() -> void:
	var db := _db()
	assert_true(db.load_errors.is_empty(), "no load errors: %s" % str(db.load_errors))
	assert_true(db.vocabulary.size() > 30, "vocabulary has entries")
	assert_true(db.chassis.size() >= 3, "chassis present")
	assert_true(db.components.size() >= 10, "components present")
	assert_true(db.foes.size() >= 6, "foes present")
	assert_eq(db.factions.size(), 4, "four domains")


func test_content_validates_clean() -> void:
	var errs := _db().validate()
	for e in errs:
		failures.append("content: " + e)
	checks += 1


func test_every_chassis_builds_a_full_die() -> void:
	var db := _db()
	for id in db.chassis.keys():
		var u := db.make_mech(id)
		var c: Dictionary = db.chassis[id]
		assert_eq(u.die.size(), c.get("fixed", []).size() + int(c["hardpoints"]), "%s die size is fixed plus hardpoints" % id)
		assert_eq(u.hardpoints, int(c["hardpoints"]), "%s knows its free slots" % id)
		for f in u.die.faces:
			assert_true(f.kind != Face.Kind.BLANK, "%s ships with every hardpoint filled and nothing broken" % id)
			assert_false(f.component.is_empty(), "%s: every entry names its component" % id)
		for i in range(c.get("fixed", []).size()):
			assert_eq(u.die.faces[i].component, str(c["fixed"][i]), "%s: fixed components come first" % id)


func test_build_die_leaves_empty_hardpoints_empty() -> void:
	var db := _db()
	var d := db.build_die(["chainsaw_claw"], ["shotfire_rack"], 3)
	assert_eq(d.size(), 4, "one fixed plus three hardpoints")
	assert_eq(d.faces[0].component, "chainsaw_claw", "the fixed claw first")
	assert_eq(d.faces[1].component, "shotfire_rack", "then the loadout")
	assert_true(d.faces[2].empty and d.faces[3].empty, "two hardpoints left empty stay empty")
	assert_true(d.faces[0].fixed and not d.faces[1].fixed and not d.faces[2].fixed, "only the claw is fixed; the rest are hardpoints")
	assert_eq(d.faces[2].describe(), "empty hardpoint", "and say so")


func test_chassis_validator_guards_hardpoints() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["kite"].duplicate(true)
	c["loadout"] = ["laminar_deflector", "laminar_deflector", "laminar_deflector", "laminar_deflector", "laminar_deflector"]
	db.chassis["over"] = c
	var f: Dictionary = db.chassis["badger"].duplicate(true)
	f["loadout"] = ["chainsaw_claw"]
	db.chassis["twice"] = f
	var g: Dictionary = db.chassis["kite"].duplicate(true)
	g["filler"] = {"kind": "shield", "power": 10}
	db.chassis["stuffed"] = g
	var over := false
	var twice := false
	var stuffed := false
	for e in db.validate():
		if e.begins_with("chassis over") and e.contains("into %d hardpoints" % int(c["hardpoints"])):
			over = true
		if e.begins_with("chassis twice") and e.contains("is fixed"):
			twice = true
		if e.begins_with("chassis stuffed") and e.contains("filler is gone"):
			stuffed = true
	assert_true(over, "more components than hardpoints is refused")
	assert_true(twice, "a fixed component in the loadout is refused")
	assert_true(stuffed, "filler is refused")


func test_chassis_validator_wants_one_way_of_moving_and_moves_in_hexes() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var two: Dictionary = db.chassis["badger"].duplicate(true)
	two["traits"] = ["tracked", "walker"]
	db.chassis["twoways"] = two
	var none: Dictionary = db.chassis["badger"].duplicate(true)
	none["traits"] = ["defense"]
	db.chassis["noway"] = none
	var odd: Dictionary = db.chassis["badger"].duplicate(true)
	odd["movespeed"] = 7
	db.chassis["odd"] = odd
	var still: Dictionary = db.chassis["badger"].duplicate(true)
	still["movespeed"] = 0
	db.chassis["still"] = still
	var twoways := false
	var noway := false
	var odd_move := false
	var still_move := false
	for e in db.validate():
		if e.begins_with("chassis twoways") and e.contains("exactly one way of moving"):
			twoways = true
		if e.begins_with("chassis noway") and e.contains("exactly one way of moving"):
			noway = true
		if e.begins_with("chassis odd") and e.contains("in hexes"):
			odd_move = true
		if e.begins_with("chassis still") and e.contains("in hexes"):
			still_move = true
	assert_true(twoways, "two ways of moving are refused")
	assert_true(noway, "no way of moving is refused")
	assert_true(still_move, "a move of 0 is refused")
	assert_true(odd_move, "a move past six hexes is refused")


func test_kite_loadout_matches_design() -> void:
	var db := _db()
	var u := db.make_mech("kite")
	assert_eq(u.movespeed, int(db.chassis["kite"]["movespeed"]), "the move is the content's, in hexes")
	assert_true(u.movespeed >= 1 and u.movespeed <= ContentDB.MAX_MOVE, "moves are hexes, 1 to 6")
	assert_true(u.traits.has("flyer"), "kite flies")
	assert_false(u.can_block(), "and therefore does not block")


func test_packs_unpack_by_foe_type() -> void:
	var db := _db()
	var ghouls := Unit.pack(7, "ghouls", Vector2i.ZERO, "marsh", 2, 3, "revenant")
	var foes := db.foes_for(ghouls)
	assert_eq(foes.size(), 3, "three ghouls from strength three")
	for f in foes:
		assert_eq(f.display_name, "Revenant", "all the same type")
		assert_eq(f.pack_id, 7, "foe remembers its pack")
	# A pack unpacks whole: content is validated to fit its fight's slots (no reinforcement inside a
	# fight, 6 November), so the engine never trims one.
	assert_eq(db.foes_for(Unit.pack(10, "horde", Vector2i.ZERO, "marsh", 2, 6, "revenant")).size(), 6, "six from strength six")
	var necros := Unit.pack(8, "necromancers", Vector2i.ZERO, "marsh", 2, 2, "ghost")
	var backs := db.foes_for(necros)
	assert_eq(backs.size(), 2, "two necromancers")
	assert_true(backs[0].prefers_back, "necromancer holds the back")
	var untyped := Unit.pack(9, "whatever", Vector2i.ZERO, "peak", 2, 3)
	var fallback := db.foes_for(untyped)
	assert_eq(fallback.size(), 3, "a pack with no type falls back to the faction's first spawn entry")
	assert_eq(fallback[0].content_id, str(db.spawn_table("peak", 1)[0][0]), "which is the Peak's first unit, its tier-one formation's lead")


func test_boss_unpacks_to_the_faction_boss() -> void:
	var db := _db()
	var boss := Unit.boss(8, "colossus", Vector2i.ZERO, "marsh")
	var only := db.foes_for(boss)
	assert_eq(only.size(), 1, "a boss unpacks to just its boss")
	assert_eq(only[0].display_name, str(db.foes[db.bosses_of("marsh")[0]]["name"]), "the Marsh's first boss, whatever the content names it (a domain's bosses are a list since the slate)")
	assert_true(only[0].boss, "and the content marks it the boss")
	var pit := db.foes_for(Unit.boss(9, "lord", Vector2i.ZERO, "peak"))
	assert_eq(pit[0].display_name, str(db.foes[db.bosses_of("peak")[0]]["name"]), "the Peak's first boss")


func test_spawn_table_lists_the_factions_units() -> void:
	# Derived from the compositions since 30 October: the tier's formations' then patrols'
	# members, each foe once, first seen first, for the harness, the runners and the escorts.
	var db := _db()
	for fac in db.factions.keys():
		var table := db.spawn_table(str(fac), 1)
		var ids: Array = table.map(func(e) -> String: return str(e[0]))
		var want: Array = []
		for size in ["formation", "patrol"]:
			for c in db.compositions(str(fac), 1, size):
				for m in c["members"]:
					if not want.has(str(m[0])):
						want.append(str(m[0]))
		assert_eq(ids, want, "%s at tier one: the formations' then the patrols' members, each once, first seen first" % fac)
		for e in table:
			assert_true(int(e[1]) >= 1, "%s at a strength" % str(e[0]))
	assert_eq(db.faction_of_foe("drake"), "peak", "foe to faction lookup")
	for fid in db.factions.keys():
		for t in [1, 2, 3]:
			var seen := {}
			for e in db.spawn_table(str(fid), t):
				assert_false(seen.has(e[0]), "%s tier %d lists %s once" % [fid, t, e[0]])
				seen[e[0]] = true
				assert_false(db.is_elite(str(e[0])), "%s: an elite is never in the spawn list" % str(e[0]))


## The compositions by tier (the foes' fresh start, 30 October): every domain a formation and a
## patrol at each tier, a tier past the content taking the highest under it and one below them the
## first; the validator asks for a tier-one formation and patrol, a known size, members of known
## foes, no hero, an elite leading its own composition and nowhere else, and refuses the old spawn
## lists.
func test_the_compositions_go_by_tier() -> void:
	var db := ContentDB.new()   # its own copy: compositions are dropped below
	db.load_dir(ContentDB.DIR)
	for fid in db.factions.keys():
		for t in [1, 2, 3]:
			assert_false(db.compositions(str(fid), t, "formation").is_empty(), "%s has a tier-%d formation" % [fid, t])
			assert_false(db.compositions(str(fid), t, "patrol").is_empty(), "%s has a tier-%d patrol" % [fid, t])
			for c in db.compositions(str(fid), t):
				assert_true(ContentDB.COMPOSITION_SIZES.has(str(c["size"])), "%s is a size" % str(c["id"]))
				assert_false((c["members"] as Array).is_empty(), "%s has members" % str(c["id"]))
		assert_eq(db.spawn_table(str(fid), 0), db.spawn_table(str(fid), 1), "below the tiers, the first")
		assert_eq(db.spawn_table(str(fid), 5), db.spawn_table(str(fid), 3), "past them, the highest")
	var fid := "meadow"
	assert_ne(db.spawn_table(fid, 2), db.spawn_table(fid, 1), "a tier's compositions are its own")
	var comps: Array = db.factions[fid]["compositions"]
	for c in comps:
		var tiers: Array = c.get("tiers", [1])
		c["tiers"] = tiers.filter(func(t) -> bool: return int(t) != 2)
	db.factions[fid]["compositions"] = comps.filter(func(c) -> bool: return not (c["tiers"] as Array).is_empty())
	assert_true(db.spawn_table(fid, 2).is_empty(), "a tier with none has none: nothing stands in from the tier below (8 November), which is why every domain writes every size at every tier")
	# The validator.
	var hero := ""
	for id in db.foes.keys():
		if bool(db.foes[id].get("hero", false)):
			hero = str(id)
			break
	var elite := ""
	for id in db.foes.keys():
		if db.is_elite(str(id)):
			elite = str(id)
			break
	var bad: Array = db.factions[fid]["compositions"]
	var empty := [null, null, null, null]
	bad.append({"id": "twice", "size": "patrol", "tiers": [1], "front": ["goblin", "goblin", null, null], "back": empty})
	bad.append({"id": "twice", "size": "horde", "tiers": [9], "front": ["nobody", null, null, null], "back": empty})
	bad.append({"id": "with_a_hero", "size": "formation", "tiers": [1], "front": [hero, null, null, null], "back": empty})
	bad.append({"id": "an_elite_astray", "size": "formation", "tiers": [1], "front": [elite, null, null, null], "back": empty})
	bad.append({"id": "no_elite", "size": "elite", "tiers": [1], "front": ["goblin", "goblin", "goblin", null], "back": empty})
	bad.append({"id": "nobody", "size": "patrol", "tiers": [1], "front": empty, "back": empty})
	bad.append({"id": "old_shape", "size": "patrol", "tiers": [1], "front": ["goblin", null, null, null], "back": empty, "members": [{"foe": "goblin", "strength": 1}]})
	var errs := db.validate()
	var mine: Array = errs.filter(func(e) -> bool: return e.begins_with("faction %s" % fid))
	assert_true(mine.any(func(e) -> bool: return e.contains("id comes twice")), "a repeated id is reported")
	assert_true(mine.any(func(e) -> bool: return e.contains("size is one of")), "an unknown size")
	assert_true(mine.any(func(e) -> bool: return e.contains("tiers are 1 to 3")), "a tier past three")
	assert_true(mine.any(func(e) -> bool: return e.contains("unknown foe")), "an unknown foe")
	assert_true(mine.any(func(e) -> bool: return e.contains("hero %s is never in a composition" % hero)), "a hero")
	assert_true(mine.any(func(e) -> bool: return e.contains("%s is an elite and stands only in an elite composition" % elite)), "an elite astray")
	assert_true(mine.any(func(e) -> bool: return e.contains("led by its elite")), "an elite composition with no elite")
	assert_true(mine.any(func(e) -> bool: return e.contains("name nobody")), "an empty grid")
	assert_true(mine.any(func(e) -> bool: return e.contains("members and layout are gone")), "the old shape refused")
	db.factions[fid]["spawn"] = {"1": [{"foe": "goblin", "strength": 1}]}
	assert_true(db.validate().any(func(e) -> bool: return e.begins_with("faction %s" % fid) and e.contains("spawn is gone")), "the old spawn lists are refused")
	db.factions[fid].erase("spawn")
	db.factions[fid]["compositions"] = [{"id": "only_patrols", "size": "patrol", "tiers": [2], "front": ["goblin", "goblin", null, null], "back": [null, null, null, null]}]
	errs = db.validate()
	assert_true(errs.any(func(e) -> bool: return e.begins_with("faction %s" % fid) and e.contains("needs a tier-one formation")), "a domain without a tier-one formation is reported")
	assert_true(errs.any(func(e) -> bool: return e.begins_with("faction %s" % fid) and e.contains("needs a tier-one patrol")), "and without a tier-one patrol")


## Menace is a pack's threat rating (Ryan, 11 November: "Maybe just 1-2-3-4 for now to keep math
## simple ... It gives us an absolute unbiased benchmark"): the one weight the Rupture meter,
## Anathema and salvage count kills by is a composition's rating, a pip a hundred, a lone patrol
## one, a formation three, an elite four, the same in every domain and at every tier. A foe's
## own numbers add up to its weight (the heaviest implemented blow, damage times strikes, a
## breach one more, plus a quarter of the HP rounded up: what menace was from 30 October), the
## other side of the benchmark and nothing a kill pays.
func test_menace_is_a_compositions_threat_rating_and_weight_its_foes_own_numbers() -> void:
	var db := _db()
	var pip := ContentDB.MENACE_PER_PIP
	for id in db.foes.keys():
		if db.foes[id].has("promotes"):
			continue
		var f := db.make_foe(str(id))
		var want := f.threat() + int(ceil(float(f.hp_max) / 4.0))
		assert_eq(db.weight(str(id)), want, "%s's weight" % id)
		assert_true(db.weight(str(id)) >= 1, "%s weighs something" % id)
	var goblin := db.make_foe("goblin")
	assert_eq(db.weight("goblin"), goblin.threat() + 1, "a goblin: its stab and a quarter of three HP, rounded up")
	assert_eq(db.weight("nobody"), 0, "an unknown foe weighs nothing")
	var elites := 0
	var by_size := {}
	for fid in db.factions.keys():
		for t in [1, 2, 3]:
			for size in ["patrol", "formation", "elite"]:
				for c in db.compositions(str(fid), t, size):
					assert_eq(db.composition_menace(c), ContentDB.squad_of(c) * pip, "%s's menace is its threat rating, a pip a hundred" % str(c["id"]))
					assert_eq(db.composition_weight(c), (c["members"] as Array).reduce(func(acc, m): return acc + db.weight(str(m[0])) * int(m[1]), 0), "%s's weight is its members'" % str(c["id"]))
					if not c.has("squad"):
						by_size[size] = db.composition_menace(c)
		for c in db.elite_compositions(str(fid), 1):
			elites += 1
			assert_true(db.is_elite(str(c["members"][0][0])), "%s is led by its elite" % str(c["id"]))
			assert_eq(db.composition_menace(c), 4 * pip, "%s: an elite is four pips, whichever" % str(c["id"]))
	assert_eq(by_size, {"patrol": pip, "formation": 3 * pip, "elite": 4 * pip}, "a lone patrol one, a formation three, an elite four, in every domain and at every tier")
	assert_eq([ContentDB.worth_of(0), ContentDB.worth_of(9)], [pip, 4 * pip], "a rating outside one to four is held to it")
	assert_true(elites >= 1, "some domain has an elite at tier one")
	assert_true(db.escort_composition("meadow", 1).is_empty(), "no hand-tailored escort is written yet")


## Every move of every foe a domain sends, at every tier, runs in a fight (the ladder's brief, D;
## 28 October): its condition set aside, each implemented move is its only one for two rounds, a
## countdown's included, on a machine that outlasts it.
func test_every_move_of_every_spawned_foe_runs_in_a_fight() -> void:
	var db := ContentDB.load_default()
	var seen := {}
	for fid in db.factions.keys():
		for t in [1, 2, 3]:
			for c in db.compositions(str(fid), t):   # every size: the elites' kits run too
				for e in c["members"]:
					seen[str(e[0])] = true
	for id in seen.keys():
		for a in db.foes[id].get("actions", []):
			if str(a.get("status", "")) != "implemented":
				continue
			var sk := Skirmish.new(1, 3)
			var m := db.make_mech(str(db.chassis.keys()[0]), 1, Vector2i.ZERO)
			m.hull = 999
			m.hull_max = 999
			sk.add_mech(m)
			var f := db.make_foe(id)
			f.hp = maxi(1, f.hp_max / 2)   # below half and hurt, for the moves that wait on it
			var move: Dictionary = a.duplicate(true)
			move.erase("when")
			f.actions = [move]
			sk.add_foes([f, db.make_foe(id)])
			sk.begin()
			for r in range(3):
				if sk.outcome != Skirmish.Outcome.NONE:
					break
				sk.start_round()
				sk.end_round()
			assert_true(sk.log.size() > 0, "%s's %s runs" % [id, str(a.get("id", ""))])


func test_a_massive_foe_may_stand_in_a_composition() -> void:
	# The bible's tiers row (15 October, Ryan again 24 October): size is apart from the tier, so
	# massive rank and file validate, unpack from their pack as no boss, and take a column each.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var fid := str(db.factions.keys()[0])
	var big: Dictionary = db.foes[str(db.bosses_of(fid)[0])].duplicate(true)
	big["id"] = "massive_rank_and_file"
	big["name"] = "Massive Rank and File"
	db.foes["massive_rank_and_file"] = big
	db.factions[fid]["compositions"].append({"id": "giants", "size": "patrol", "tiers": [1], "front": ["massive_rank_and_file", "massive_rank_and_file", null, null], "back": [null, null, null, null],
		"design": {"question": "Two giants on a flank.", "crossing": "A test's pushers in a patrol."}})
	assert_true(db.validate().is_empty(), "a massive foe in a composition validates: %s" % str(db.validate()))
	assert_true(db.spawn_table(fid, 1).any(func(e) -> bool: return str(e[0]) == "massive_rank_and_file"), "and the derived list carries it")
	var foes := db.foes_for(Unit.pack(5, "giants", Vector2i.ZERO, fid, 1, 2, "massive_rank_and_file"))
	assert_eq(foes.size(), 2, "two from strength two")
	assert_true(foes[0].is_massive() and not foes[0].boss, "massive, and no boss for it")
	var sk := Skirmish.new(1)
	sk.add_mech(db.make_mech(str(db.chassis.keys()[0]), 1, Vector2i.ZERO))
	sk.add_foes(foes)
	sk.begin()
	var columns := 0
	for c in range(sk.front.size()):
		if sk.front[c] != null and sk.front[c].is_massive():
			assert_eq(sk.back[c], sk.front[c], "each fills both ranks of its column")
			columns += 1
	assert_eq(columns, 2, "and each takes a column of its own")


func test_content_mech_survives_a_skirmish_round() -> void:
	var db := _db()
	var sk := Skirmish.new(5)
	sk.add_mech(db.make_mech("badger"))
	sk.add_mech(db.make_mech("clydesdale"))
	var sq := Unit.pack(1, "risen", Vector2i.ZERO, "marsh", 2, 6)
	sk.add_foes(db.foes_for(sq), sq)
	sk.begin()
	sk.start_round()
	for i in range(sk.mechs.size()):
		var t := sk.targets_for(i)
		if not t.is_empty():
			sk.assign(i, t[0])
		else:
			sk.assign(i, null)
	var out := sk.end_round()
	assert_eq(out, Skirmish.Outcome.NONE, "fight continues after one round")
	assert_true(sk.survivors_for(sq) <= 6, "survivor count sane")


func test_keyword_cap_is_enforced() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var comp: Dictionary = db.components["enfilade_beam"].duplicate(true)
	comp["face"]["keywords"] = ["penetrate", "ablate", "chain", "shock"]
	comp["face"]["chain"] = 1   # Chain says its number (the conductor, 28 October)
	comp["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["too_many"] = comp
	var errs := db.validate()
	var hit := false
	for e in errs:
		if e.begins_with("component too_many") and e.contains("authored cap"):
			hit = true
	assert_true(hit, "four keywords on an authored face is reported")


## A purge is a special, never a rider (28 October): the validator refuses it on a blow and in
## a last act.
func test_a_purge_rides_no_blow() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var f: Dictionary = db.foes["revenant"].duplicate(true)
	f["actions"][0]["keywords"] = ["dispel"]
	db.foes["hushed"] = f
	var g: Dictionary = db.foes["revenant"].duplicate(true)
	g["on_death"] = {"blow": {"name": "Last Rites", "factor": 1, "strikes": 1, "keywords": ["dispel"]}}
	db.foes["rites"] = g
	var errs := db.validate()
	assert_true(errs.any(func(e) -> bool: return e.begins_with("foe hushed") and e.contains("a special, never a rider")), "a purge on a blow is reported")
	assert_true(errs.any(func(e) -> bool: return e.begins_with("foe rites") and e.contains("on_death blow") and e.contains("never a rider")), "a purge in a last act is reported")


## A hero only commands the boss unit, which holds its hex and never hunts (Ryan, 28
## October, of the Thief's move: "it's a boss so it doesn't need it"): the validator refuses a map
## move on a hero, and the rank and file keep theirs. A hunt it refuses on every foe (the next test).
func test_a_hero_carries_no_map_move_or_hunt() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var hero_id := ""
	var walker_id := ""
	for id in db.foes.keys():
		var e: Dictionary = db.foes[id]
		if hero_id.is_empty() and bool(e.get("hero", false)):
			hero_id = str(id)
		if walker_id.is_empty() and not bool(e.get("hero", false)) and e.has("movespeed"):
			walker_id = str(id)
	assert_false(hero_id.is_empty(), "the content has a hero")
	assert_false(walker_id.is_empty(), "and a foe with a move of its own")
	assert_false(db.foes[hero_id].has("movespeed"), "no hero carries a move")
	var f: Dictionary = db.foes[hero_id].duplicate(true)
	f["movespeed"] = 3
	db.foes["roamer"] = f
	var errs := db.validate()
	assert_true(errs.any(func(e) -> bool: return e.begins_with("foe roamer") and e.contains("drop movespeed")), "a hero's move is reported")
	assert_false(errs.any(func(e) -> bool: return e.begins_with("foe %s" % walker_id) and e.contains("a hero only")), "the rank and file's moves are their own")


## The hunt is a composition's and no foe carries a ring (Ryan, 8 November: "The composition should
## say if it hunts, not the units"; the rings purged, a hunter catching at the pounce alone): no
## foe in content says either, the validator refuses a ring, a behaviour or a caveat on a foe, a
## composition hunts by a caveat the engine has, an escort never hunts, and content has hunters.
func test_the_hunt_is_a_compositions_and_no_foe_carries_a_ring() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var carried: Array = []
	for id in db.foes.keys():
		for key in ["zone", "behaviour", "hunts"]:
			if db.foes[id].has(key):
				carried.append("%s.%s" % [id, key])
	assert_eq(carried, [], "no foe carries a ring or a hunt")
	var hunting := 0
	for fid in db.factions.keys():
		for c in db.factions[fid].get("compositions", []):
			if (c as Dictionary).has("hunts"):
				hunting += 1
	assert_true(hunting > 0, "content has hunting compositions")
	var f: Dictionary = db.foes[str(db.foes.keys()[0])].duplicate(true)
	f["zone"] = 2
	f["behaviour"] = "hunt"
	f["hunts"] = "nearest"
	db.foes["creeper"] = f
	var comps: Array = []
	var patrol: Dictionary = {}
	var escort: Dictionary = {}
	for fid in db.factions.keys():
		for c in db.factions[fid].get("compositions", []):
			if patrol.is_empty() and str(c["size"]) == "patrol":
				patrol = c
				comps = db.factions[fid]["compositions"]
			if escort.is_empty() and str(c["size"]) == "escort" and db.factions[fid]["compositions"] == comps:
				escort = c
	assert_false(patrol.is_empty() or escort.is_empty(), "a domain with a patrol and an escort to probe")
	var loud := patrol.duplicate(true)
	loud["id"] = "probe_loud"
	loud["hunts"] = "loudest"
	comps.append(loud)
	var hunting_escort := escort.duplicate(true)
	hunting_escort["id"] = "probe_hunting_escort"
	hunting_escort["hunts"] = "nearest"
	comps.append(hunting_escort)
	var errs := db.validate()
	for key in ["zone", "behaviour", "hunts"]:
		assert_true(errs.any(func(e) -> bool: return e.begins_with("foe creeper") and e.contains(key + " is gone")), "a foe's %s is refused" % key)
	assert_true(errs.any(func(e) -> bool: return e.contains("probe_loud") and e.contains("hunts is the caveat")), "a caveat the engine has not is refused")
	assert_true(errs.any(func(e) -> bool: return e.contains("probe_hunting_escort") and e.contains("never hunts")), "an escort that hunts is refused")
	assert_false(errs.any(func(e) -> bool: return e.contains("hunts is the caveat") and not e.contains("probe_loud")), "the content's own hunts pass")


## A foe's four buff specials (the ladder's brief, B; 28 October): a priming and a regrowth say
## their number, 1 or more; a Barrier and a Ward say none.
func test_a_foes_buff_specials_say_their_number_or_none() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var cases := {
		"stoker": {"kind": "buff", "effect": "prime"},
		"knitter": {"kind": "defend", "effect": "regenerate", "value": 0},
		"shelter": {"kind": "defend", "effect": "barrier", "value": 2},
		"hallow": {"kind": "buff", "effect": "ward_all", "value": 1},
		"fine": {"kind": "buff", "effect": "prime", "value": 2},
	}
	for id in cases:
		var f: Dictionary = db.foes["revenant"].duplicate(true)
		var a := {"id": "move", "name": "Move", "text": "", "status": "implemented", "weight": 1}
		a.merge(cases[id])
		f["actions"].append(a)
		db.foes[id] = f
	var errs := db.validate()
	assert_true(errs.any(func(e) -> bool: return e.begins_with("foe stoker") and e.contains("prime says its number")), "a priming with no number is reported")
	assert_true(errs.any(func(e) -> bool: return e.begins_with("foe knitter") and e.contains("regenerate says its number")), "a regrowth of nothing is reported")
	assert_true(errs.any(func(e) -> bool: return e.begins_with("foe shelter") and e.contains("barrier takes no value")), "a Barrier with a number is reported")
	assert_true(errs.any(func(e) -> bool: return e.begins_with("foe hallow") and e.contains("ward_all takes no value")), "a Ward with a number is reported")
	var fine: Array = errs.filter(func(e) -> bool: return e.begins_with("foe fine"))
	assert_eq(fine, [], "a priming that says its number passes")


func test_passive_effect_cap_is_enforced() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["kite"].duplicate(true)
	c["design"].erase("one_off")   # the cap as it stands for every passive without one
	var eff := {"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 1}   # synthetic: content's passives change
	c["passive"] = {"id": "bloated", "name": "Bloated", "description": "Four effects.", "effects": [eff, eff, eff, eff]}
	db.chassis["bloated"] = c
	var errs := db.validate()
	var hit := false
	for e in errs:
		if e.begins_with("chassis bloated") and e.contains("effects, cap"):
			hit = true
	assert_true(hit, "four effects in one passive is reported")


## An effect an event fires may fire once a round (Ryan, 11 November, of the Skua's stack of
## Ricochet: "once per turn"): `once` is "round", never on an effect the pipeline reads; and a
## status that lasts the fight takes stacks and no rounds from a buff. Synthetic, as every
## passive a test asserts on.
func test_a_once_gate_and_a_fight_long_buff_are_validated() -> void:
	var db := _fresh()
	var cid := ""
	for id in db.chassis.keys():
		if db.chassis[id].get("passive", null) is Dictionary and str(db.chassis[id].get("status", "")) != "planned":
			cid = str(id)
			break
	var gated := func(eff: Dictionary) -> bool:
		db.chassis[cid]["passive"] = {"id": "test_once", "name": "Once", "description": "Once.", "effects": [eff]}
		for e in db.validate():
			if e.begins_with("chassis %s" % cid) and e.contains("once is"):
				return true
		return false
	assert_false(gated.call({"trigger": "on_damage", "effect": "stack_status", "value": "ricochet", "once": "round"}), "once a round on an event's effect: allowed")
	assert_true(gated.call({"trigger": "on_damage", "effect": "stack_status", "value": "ricochet", "once": "turn"}), "any other span: refused")
	assert_true(gated.call({"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 1, "once": "round"}), "on a static effect, which no event fires: refused")
	assert_true(gated.call({"trigger": "on_attack", "effect": "add_damage", "value": 1, "once": "round"}), "on the blow's pipeline: refused")
	db = _fresh()
	var buff := ""
	for id in db.components.keys():
		if str(db.components[id].get("face", {}).get("kind", "")) == "buff" and str(db.components[id].get("status", "")) != "planned" and not db.components[id]["face"].has("ally_action"):
			buff = str(id)
			break
	assert_false(buff.is_empty(), "the content has a buff")
	db.components[buff]["face"]["status"] = "ricochet"
	db.components[buff]["face"]["rounds"] = 2
	assert_true(_has_error(db, "ricochet lasts the fight"), "rounds on a status that lasts the fight: refused")
	db.components[buff]["face"].erase("rounds")
	assert_false(_has_error(db, "component %s" % buff), "stacks alone: allowed")


func test_a_boss_is_marked_by_content_and_may_be_any_size() -> void:
	# The bible's tiers row (15 October): big is an attribute apart from boss and elite, so a
	# human-sized boss validates and is the boss; a hero is a final, dealt from the bench.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	# An escort written for one boss names it (30 October); this test rewrites the boss lists, so
	# its copy's escorts name none.
	for fac in db.factions.values():
		for c in fac.get("compositions", []):
			c.erase("boss")
	var fid := str(db.factions.keys()[0])
	var small: Dictionary = db.foes[str(db.bosses_of(fid)[0])].duplicate(true)
	small["size"] = 1
	db.foes["small_boss"] = small
	db.factions[fid]["boss"] = "small_boss"
	assert_true(db.validate().is_empty(), "a human-sized boss validates: %s" % str(db.validate()))
	var b := db.make_foe("small_boss")
	assert_true(b.boss and not b.is_massive(), "the content makes it the boss, and it stands one slot high")
	assert_false(db.make_foe(str(db.spawn_table(fid, 1)[0][0])).boss, "its rank and file are no boss")
	var hero_id := ""
	for id in db.foes.keys():
		if bool(db.foes[id].get("hero", false)):
			hero_id = str(id)
			break
	db.factions[fid]["boss"] = hero_id
	var refused := false
	for e in db.validate():
		if e.begins_with("faction %s" % fid) and e.contains("is a hero"):
			refused = true
	assert_true(refused, "a hero named the boss is refused")
	# A list of bosses (three a domain once the slate lands, 22 October): each once, none a hero.
	var boss_id := str(db.spawn_table(fid, 1)[0][0])
	db.factions[fid]["boss"] = ["small_boss", boss_id]
	assert_true(db.validate().is_empty(), "a list of bosses validates: %s" % str(db.validate()))
	assert_eq(Array(db.bosses_of(fid)), ["small_boss", boss_id], "read in content order")
	db.factions[fid]["boss"] = ["small_boss", "small_boss"]
	assert_true(db.validate().any(func(e: String) -> bool: return e.contains("comes twice")), "a boss listed twice is refused")
	db.factions[fid]["boss"] = []
	assert_true(db.validate().any(func(e: String) -> bool: return e.contains("names no foe")), "and an empty list")
	db.factions[fid]["boss"] = ["small_boss", hero_id]
	assert_true(db.validate().any(func(e: String) -> bool: return e.contains("is a hero")), "and a hero among them")


func test_internal_text_cannot_sit_at_the_top_level() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["kite"].duplicate(true)
	c["fantasy"] = "would be shown"
	db.chassis["leaky"] = c
	var f: Dictionary = db.foes["revenant"].duplicate(true)
	f.erase("design")
	db.foes["bare"] = f
	var errs := db.validate()
	var leak := false
	var bare := false
	for e in errs:
		if e.begins_with("chassis leaky") and e.contains("belongs under design"):
			leak = true
		if e.begins_with("foe bare") and e.contains("missing design"):
			bare = true
	assert_true(leak, "fantasy at the top level is refused")
	assert_true(bare, "an entry without design is refused")


func test_a_reserved_machine_name_is_refused_unless_the_clash_is_recorded() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.reserved_names.size() > 1000, "the reserved names loaded (%d)" % db.reserved_names.size())
	assert_eq(ContentDB.normalise_name("Black Hawk-KU"), "blackhawkku", "spaces, hyphens and case fall away")
	var wolf: Dictionary = db.chassis["clydesdale"].duplicate(true)
	wolf["name"] = "timber wolf"      # case and spacing do not hide a clash
	db.chassis["wolf"] = wolf
	var by_id: Dictionary = db.chassis["clydesdale"].duplicate(true)
	by_id["name"] = "Pale Rider"
	db.chassis["king_crab"] = by_id    # the id clashes even when the nickname does not
	var gear: Dictionary = db.chassis["clydesdale"].duplicate(true)
	gear["name"] = "Black Mamba"      # Heavy Gear, and the message says so
	db.chassis["gear"] = gear
	var tank: Dictionary = db.chassis["clydesdale"].duplicate(true)
	tank["name"] = "Warthog"          # Halo
	db.chassis["tank"] = tank
	var grey: Dictionary = db.chassis["clydesdale"].duplicate(true)
	grey["name"] = "Grey Wolf"        # nobody's machine: the match is exact, not by word
	db.chassis["grey"] = grey
	var kept: Dictionary = db.chassis["clydesdale"].duplicate(true)
	kept["name"] = "Timber Wolf"
	kept["design"] = kept["design"].duplicate(true)
	kept["design"]["name_clash"] = "kept knowingly for the test"
	db.chassis["kept"] = kept
	var wolf_hit := false
	var id_hit := false
	var gear_hit := false
	var tank_hit := false
	for e in db.validate():
		if e.begins_with("chassis wolf") and e.contains("Timber Wolf (a BattleTech 'Mech)"):
			wolf_hit = true
		if e.begins_with("chassis king_crab") and e.contains("King Crab"):
			id_hit = true
		if e.begins_with("chassis gear") and e.contains("Black Mamba (a Heavy Gear machine)"):
			gear_hit = true
		if e.begins_with("chassis tank") and e.contains("Warthog (a Halo vehicle)"):
			tank_hit = true
		assert_false(e.begins_with("chassis grey") and e.contains("clashes"), "a name that merely shares a word passes: %s" % e)
		assert_false(e.begins_with("chassis kept") and e.contains("clashes"), "a recorded clash passes: %s" % e)
	assert_true(wolf_hit, "a BattleTech 'Mech nickname is refused and named")
	assert_true(id_hit, "a reserved id is refused")
	assert_true(gear_hit, "a Heavy Gear name is refused and its source named")
	assert_true(tank_hit, "a Halo name is refused and its source named")


## The Kite's shape on a synthetic passive (content's own passive is Ryan's to change): the
## printed number doubled, and a flat heat tax a shot that the double leaves alone.
func test_a_printed_double_and_a_heat_tax_on_one_shot() -> void:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive({"id": "test_double", "name": "Double", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "multiply_printed", "value": 2},
		{"trigger": "on_attack", "effect": "add_heat", "value": 3}]})
	u.die = Die.single(Face.attack(30, Face.Reach.DIRECT, [], 10))
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([Foe.make("revenant", 90, 10)])
	sk.begin()
	sk.start_round()
	sk.assign(0, sk.front[0])
	assert_eq(sk.front[0].hp, 30, "power 30 became 60")
	assert_eq(sk.mechs[0].heat, 13, "heat 10 plus the tax of 3, the double printed-only")


func test_min_damage_passive_raises_the_floor() -> void:
	# The engine's damage floor, on a synthetic passive: content is Ryan's and changes.
	var floor_passive := {"id": "floor", "name": "Floor", "description": "", "effects": [{"trigger": "on_attack", "effect": "min_damage", "value": 30}]}
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.grant_passive(floor_passive)
	assert_eq(Effects.attack(u, null, 12, 0)["damage"], 30, "a 12 is lifted to 30")
	assert_eq(Effects.attack(u, null, 45, 5)["damage"], 45, "a 45 stays")


func test_planned_passive_is_kept_but_not_run() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["kite"].duplicate(true)
	c["passive"] = {"id": "draft", "name": "Draft", "description": "Not built yet.", "status": "planned",
		"effects": [{"trigger": "on_sunrise", "effect": "immune_destroy", "value": 1}]}
	db.chassis["drafted"] = c
	var errs := db.validate()
	for e in errs:
		assert_false(e.begins_with("chassis drafted"), "a planned passive with an unbuilt effect validates clean: %s" % e)
	assert_true(Effects.make(c["passive"], Effects.LOADOUT, "chassis") == null, "a planned passive grants nothing")
	c["passive"]["status"] = "implemented"
	db.chassis["drafted"] = c
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis drafted") and e.contains("unknown trigger"):
			hit = true
	assert_true(hit, "the same passive marked implemented is refused until the engine has the trigger")


func test_a_built_component_may_carry_a_planned_keyword() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	# A synthetic planned keyword (21 October: Swap, the last one the vocabulary held, was built).
	var planned_kw := "test_planned_kw"
	db.vocabulary[planned_kw] = {"id": planned_kw, "category": "keyword", "name": "Planned", "codex": "A keyword the engine lacks.", "status": "planned"}
	var gun: Dictionary = db.components["twin_autoguns"].duplicate(true)
	gun["face"] = Dictionary(gun["face"]).duplicate(true)
	gun["face"]["keywords"] = [planned_kw]
	gun["tier"] = 2   # no chassis stocks it, so it carries its own tier
	db.components["ahead_gun"] = gun
	for e in db.validate():
		assert_false(e.begins_with("component ahead_gun"), "a built component may carry a planned keyword: %s" % e)
	var f := db.build_face(gun["face"])
	assert_true(f.keywords.is_empty(), "the die builds the entry without the keyword the engine lacks")
	db.vocabulary["someday"] = {"id": "someday", "category": "keyword", "name": "Someday", "codex": "An idea.", "status": "idea"}
	gun["face"]["keywords"] = ["someday"]
	db.components["ahead_gun"] = gun
	var hit := false
	for e in db.validate():
		if e.begins_with("component ahead_gun"):
			hit = true
	assert_true(hit, "an idea-stage keyword rides only on a planned component")


func test_a_planned_buff_may_grant_a_planned_machine_status() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var coil := ""
	for cid in db.components.keys():
		if str(db.components[cid].get("face", {}).get("kind", "")) == "buff" and db.components[cid].get("status", "implemented") == "implemented":
			coil = str(cid)
			break
	assert_true(not coil.is_empty(), "the content has a built buff component to copy")
	# A synthetic planned machine status (the content may have none left to borrow: the
	# Swallowtail's were the last, built 21 October).
	var drafted_status := "probe_status"
	db.vocabulary[drafted_status] = {"id": drafted_status, "category": "status", "name": "Probe", "codex": "A probe.", "status": "planned",
		"design": {"holes": "", "table": {"kind": "buff", "on": "machine", "stacks": "No", "lasts": "The round"}}}
	var piece: Dictionary = db.components[coil].duplicate(true)
	piece["face"] = Dictionary(piece["face"]).duplicate(true)
	piece["face"]["status"] = drafted_status
	piece["status"] = "planned"
	piece["tier"] = 2   # no chassis stocks it, so it carries its own tier
	db.components["draft_coil"] = piece
	for e in db.validate():
		assert_false(e.begins_with("component draft_coil"), "a planned buff granting a planned machine status validates clean: %s" % e)
	piece["status"] = "implemented"
	db.components["draft_coil"] = piece
	var hit := false
	for e in db.validate():
		if e.begins_with("component draft_coil") and e.contains("a buff needs 'status'"):
			hit = true
	assert_true(hit, "the same buff marked implemented is refused until the engine has the status")
	var foe_status := ""
	for k in db.vocabulary.keys():
		var e: Dictionary = db.vocabulary[k]
		if e.get("category") == "status" and e.get("status") != "implemented" and str(e.get("design", {}).get("table", {}).get("on", "")) == "foe":
			foe_status = str(k)
			break
	if not foe_status.is_empty():
		piece["face"]["status"] = foe_status
		piece["status"] = "planned"
		db.components["draft_coil"] = piece
		hit = false
		for e in db.validate():
			if e.begins_with("component draft_coil"):
				hit = true
		assert_true(hit, "a planned buff cannot grant a foe's planned status")


func test_a_planned_chassis_is_kept_but_never_fielded() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var built: Dictionary = db.chassis["badger"].duplicate(true)
	built["passive"] = {"id": "built", "name": "Built", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 1}]}
	db.chassis["built"] = built
	assert_true(db.chassis_runnable("built"), "a chassis whose passive is built can be fielded")
	var drafted: Dictionary = built.duplicate(true)
	drafted["passive"] = {"id": "draft", "name": "Draft", "description": "Not built yet.", "status": "planned", "effects": []}
	db.chassis["drafted"] = drafted
	assert_false(db.chassis_runnable("drafted"), "a planned passive keeps the chassis off the table")
	var locked: Dictionary = built.duplicate(true)
	locked["passive"] = null
	locked["fixed"] = ["draft_piece"]
	var piece: Dictionary = db.components["twin_autoguns"].duplicate(true)
	piece["status"] = "planned"
	db.components["draft_piece"] = piece
	db.chassis["locked"] = locked
	assert_false(db.chassis_runnable("locked"), "a planned locked piece keeps the chassis off the table")
	for id in ["built", "drafted", "locked"]:
		for e in db.validate():
			assert_false(e.begins_with("chassis %s" % id), "the draft validates clean: %s" % e)


func test_planned_component_may_carry_a_planned_keyword() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = _piece(db, "laminar_deflector")
	# The vocabulary's planned keyword of the day (Corrode until 18 October, Web until it was
	# built that day), found rather than named, so the test outlives the content; with none
	# planned, a synthetic one stands in.
	var planned_kw := ""
	for k in db.vocabulary.keys():
		if db.vocabulary[k].get("category") == "keyword" and db.vocabulary[k].get("status") != "implemented":
			planned_kw = str(k)
			break
	if planned_kw.is_empty():
		planned_kw = "taunt_test"
		db.vocabulary[planned_kw] = {"id": planned_kw, "category": "keyword", "name": "Taunt", "codex": "A keyword the engine lacks.", "status": "planned", "design": {"holes": ""}}
	assert_true(not planned_kw.is_empty(), "a planned keyword to test with")
	plate["face"]["keywords"] = [planned_kw]
	plate["status"] = "planned"
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["loud_plate"] = plate
	for e in db.validate():
		assert_false(e.begins_with("component loud_plate"), "a planned component with a planned keyword validates clean: %s" % e)
	var f := Face.from_dict(plate["face"])
	assert_true(f.keywords.is_empty(), "and builds without the keyword the engine lacks")
	plate.erase("status")
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["loud_plate"] = plate
	for e in db.validate():
		assert_false(e.begins_with("component loud_plate"), "a built component may carry a planned keyword too (19 October, the Flakshot's Flak): %s" % e)
	plate["face"]["keywords"] = ["no_such_keyword"]
	db.components["loud_plate"] = plate
	var hit := false
	for e in db.validate():
		if e.begins_with("component loud_plate") and e.contains("unknown keyword"):
			hit = true
	assert_true(hit, "a keyword the vocabulary does not name is refused")


## No crits (10 October): a face carrying a crit chance and a passive on the old on_crit trigger
## are both stale content, and the validator says so.
func test_crits_are_refused_in_content() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["crit"] = 10
	gun["tier"] = 1
	db.components["old_gun"] = gun
	var c: Dictionary = db.chassis[db.chassis.keys()[0]].duplicate(true)
	c["passive"] = {"id": "hot", "name": "Hot", "description": "Crits burn.", "effects": [{"trigger": "on_crit", "effect": "add_ablate", "value": 1}]}
	db.chassis["hot_one"] = c
	var gun_refused := false
	var passive_refused := false
	for e in db.validate():
		if e.begins_with("component old_gun") and e.contains("no crits"):
			gun_refused = true
		if e.begins_with("chassis hot_one") and e.contains("on_crit"):
			passive_refused = true
	assert_true(gun_refused, "a crit chance on a face is refused")
	assert_true(passive_refused, "and so is a passive on the on_crit trigger")


## Two reaches since 10 October: melee is refused as a reach in content, a melee weapon is a
## direct one with the tag, and its built entry carries the tag for a passive to read.
func test_melee_is_a_tag_and_never_a_reach() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var claw: Dictionary = db.components["enfilade_beam"].duplicate(true)
	claw["face"]["reach"] = "melee"
	claw["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["fist"] = claw
	var refused := false
	for e in db.validate():
		if e.begins_with("component fist") and e.contains("reach direct, indirect or every_foe"):
			refused = true
	assert_true(refused, "melee is no reach")
	claw["face"]["reach"] = "direct"
	claw["tags"] = ["melee"]
	for e in db.validate():
		assert_false(e.begins_with("component fist"), "a direct weapon tagged melee validates clean: %s" % e)
	var f: Face = db.build_die(["fist"], [], 0).faces[0]
	assert_eq(f.reach, Face.Reach.DIRECT, "it builds direct")
	assert_eq(f.tags, ["melee"] as Array[String], "carrying its tag")
	assert_eq(Face.reach_from_name("melee"), -1, "and melee names no reach")


## The working set is the validator's list (the stock pass, 22 October): a component wears only
## its tags, each once; a tag condition and the drum's added tag read only the set; the filing
## tags are gone from content, melee kept where the content had it.
func test_a_component_wears_only_the_working_set_of_tags() -> void:
	var db := _fresh()
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["tagged"] = gun
	gun["tags"] = ["kinetic"]
	assert_true(_refused(db, "component tagged", "not in the working set"), "a filing tag is refused")
	gun["tags"] = ["beam", "beam"]
	assert_true(_refused(db, "component tagged", "twice"), "a tag listed twice is refused")
	gun["tags"] = ["beam", "melee"]
	for e in db.validate():
		assert_false(e.begins_with("component tagged"), "tags of the working set validate clean: %s" % e)
	var side: Dictionary = db.chassis["badger"].duplicate(true)
	side["id"] = "tag_reader"
	side["name"] = "Tag Reader"
	side["passive"] = {"id": "p_tag_reader", "name": "P", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 5, "when": "tag_kinetic"}]}
	db.chassis["tag_reader"] = side
	assert_true(_refused(db, "chassis tag_reader", "outside the working set"), "a condition on a retired tag is refused")
	side["passive"]["effects"][0]["when"] = "tag_melee"
	assert_false(_refused(db, "chassis tag_reader", "working set"), "a condition on a tag of the set is clean")
	var drum: Dictionary = db.chassis["badger"].duplicate(true)
	drum["id"] = "drum_reader"
	drum["name"] = "Drum Reader"
	drum["passive"] = {"id": "p_drum_reader", "name": "P", "description": "", "effects": [
		{"trigger": "static", "effect": "rewrite_weapon", "value": 4, "reach": "indirect", "heat": 3, "tag": "kinetic"}]}
	db.chassis["drum_reader"] = drum
	assert_true(_refused(db, "chassis drum_reader", "rewrite_weapon's tag"), "the drum adds only a tag of the set")
	for id in db.components.keys():
		if id == "tagged":
			continue
		for t in db.components[id].get("tags", []):
			assert_true(ContentDB.TAGS.has(str(t)), "%s wears only the working set (%s)" % [id, t])
	assert_true(Array(db.components["chainsaw_claw"]["tags"]).has("melee"), "the claw keeps its melee")


## Breach is no word of the game's (Ryan, 15 November: "Sure, let's cut breach"): no vocabulary
## entry, no keyword and no foe's rider, so a piece that names it is refused. A piece that ignores
## armour says so as a rule written on it, a weapon's alone.
func test_breach_is_gone_and_ignoring_armour_is_a_rule_written_on_a_weapon() -> void:
	var db := _fresh()
	assert_false(db.vocabulary.has("breach"), "no vocabulary word")
	assert_eq(str(db.vocabulary["ignores_armour"]["category"]), "component_property", "the rule that took its place on our side, printed on the piece")
	assert_false(Foe.ATTACK_KEYWORDS.has("breach"), "and no foe's rider")
	var old: Dictionary = db.components["enfilade_beam"].duplicate(true)
	old["tier"] = 1
	old["face"]["keywords"] = ["breach"]
	old["face"].erase("penetrate")   # the beam's Penetrate number goes with its keyword
	db.components["breacher"] = old
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["tier"] = 1
	gun["face"]["ignores_armour"] = true
	db.components["piercer"] = gun
	var plate: Dictionary = _piece(db, "canopy")
	plate["tier"] = 1
	plate["face"]["ignores_armour"] = true
	db.components["piercing_plate"] = plate
	var wordy: Dictionary = db.components["enfilade_beam"].duplicate(true)
	wordy["tier"] = 1
	wordy["face"]["ignores_armour"] = "yes"
	db.components["wordy"] = wordy
	var refused := {"breacher": false, "piercing_plate": false, "wordy": false}
	for e in db.validate():
		assert_false(e.begins_with("component piercer"), "a weapon that ignores armour validates clean: %s" % e)
		for id in refused.keys():
			if e.begins_with("component %s" % id):
				refused[id] = true
	assert_true(refused["breacher"], "a piece that names breach is refused: the engine knows no such keyword")
	assert_true(refused["piercing_plate"], "the rule on a shield is refused: an attack's alone")
	assert_true(refused["wordy"], "and it is true or false")
	assert_true(db.build_face(gun["face"]).ignores_armour, "and the weapon builds with it")


## Swap, Web and Spillover are no keywords of the game's (Ryan's marks of 15 November: "Can be
## unique text, not a keyworded rider"; "It's a unique effect, and the debuff can be renamed
## \"web bomb.\""; "As a module only effect, this does not need to be a keyword"). Each is a rule
## written on its one piece: an attack's own field, the die's star, its text on the entry, and
## the mark the web leaves is named for the piece.
func test_swap_web_and_spillover_are_rules_written_on_their_pieces() -> void:
	var db := _fresh()
	for gone in ["spillover", "web"]:
		assert_false(db.vocabulary.has(gone), "%s is no vocabulary word" % gone)
	assert_eq(str(db.vocabulary["swap"]["category"]), "component_property", "the swap is a rule printed on its piece")
	assert_eq(str(Effects.STATUS["webbed"]["name"]), "Web Bomb", "the web's mark is named for its piece")
	assert_eq(str(db.vocabulary["webbed"]["name"]), "Web Bomb", "in the list too")
	var base: Dictionary = db.components["enfilade_beam"].duplicate(true)
	base["tier"] = 1
	base["face"].erase("penetrate")
	base["face"]["keywords"] = []
	var cases := {
		"swapper": [{"swaps": true}, ""], "webber": [{"webs": true}, ""],
		"old_swap": [{"keywords": ["swap"]}, "swap"], "old_web": [{"keywords": ["web"]}, "web"],
		"old_spill": [{"keywords": ["spillover"]}, "spillover"],
		"wordy_swap": [{"swaps": "yes"}, "swaps is true or false"], "wordy_web": [{"webs": 1}, "webs is true or false"],
	}
	for id in cases.keys():
		var c: Dictionary = base.duplicate(true)
		for k in (cases[id][0] as Dictionary).keys():
			c["face"][k] = cases[id][0][k]
		db.components[id] = c
	var plate: Dictionary = _piece(db, "canopy")
	plate["tier"] = 1
	plate["face"]["swaps"] = true
	db.components["swap_plate"] = plate
	var errs := db.validate()
	for id in cases.keys():
		var want := str(cases[id][1])
		var mine := errs.filter(func(e: String) -> bool: return e.begins_with("component %s:" % id) or e.begins_with("component %s " % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates clean: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused for %s: %s" % [id, want, str(mine)])
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component swap_plate") and e.contains("on an attack")), "the rule on a shield is refused: an attack's alone")
	var swapper := db.build_face(db.components["swapper"]["face"])
	var webber := db.build_face(db.components["webber"]["face"])
	assert_true(swapper.swaps and swapper.keywords.is_empty() and swapper.has_unique_rule(), "the swap builds as a rule, no keyword, the die's star")
	assert_true(webber.webs and webber.keywords.is_empty() and webber.has_unique_rule(), "and the web")
	assert_true(swapper.rule_phrases().has(Face.SWAPS_TEXT) and swapper.describe().contains(Face.SWAPS_TEXT), "the swap says itself in words: %s" % swapper.describe())
	assert_true(webber.rule_phrases().has(Face.WEBS_TEXT) and webber.describe().contains(Face.WEBS_TEXT), "and the web: %s" % webber.describe())
	assert_true(bool(swapper.to_dict().get("swaps", false)) and Face.from_dict(swapper.to_dict()).swaps, "a save keeps the swap")
	assert_true(bool(webber.to_dict().get("webs", false)) and Face.from_dict(webber.to_dict()).webs, "and the web")
	assert_true(swapper.duplicate_face().swaps and webber.duplicate_face().webs, "and a copy both")
	assert_false(Face.from_dict({"kind": "attack", "power": 3, "spills": true}).spills, "a spill is never printed on a piece: a passive writes it on the entry as it is spent")
	# Their marks stay on the die, on the equipment they are: the swap's own inside its gear, the
	# web's as the mark it leaves.
	var gear_swap := Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "swaps": true, "keywords": ["shock"]})
	var gear_web := Face.from_dict({"kind": "attack", "power": 0, "webs": true})
	assert_eq(DieFaceView.inside_effect(gear_swap), "swap", "the swap's mark inside the gear, ahead of a keyword it carries")
	assert_eq(DieFaceView.inside_effect(gear_web), "webbed", "the web's, the mark it leaves on a foe")
	assert_true(Terms.has("swap") and not Terms.has("web") and not Terms.has("spillover"), "the list holds the swap as a rule, the web as its mark alone")


func _refused(db: ContentDB, prefix: String, word: String) -> bool:
	for e in db.validate():
		if e.begins_with(prefix) and e.contains(word):
			return true
	return false


## No weapon classes since 10 October (bible section 5) and one number a weapon since
## 2 November (rolled damage gone, Ryan: decided in play testing), whatever a piece's filing
## tags say, so the content holds sane numbers and no range.
func test_content_dice_are_sane_and_one_number_each() -> void:
	var db := _db()
	var guns := 0
	for id in db.components.keys():
		var c: Dictionary = db.components[id]
		for fd in [c.get("face", {})]:
			assert_true(int(fd.get("power", 0)) >= 0, "%s power is not negative" % id)
			if str(fd.get("kind", "")) != "attack":
				continue
			assert_false(fd.has("power_max"), "%s: rolled damage is gone, a weapon is one number" % id)
			guns += 1
	assert_true(guns >= 8, "the weapons are there (%d)" % guns)


func test_unsupported_passive_effect_is_rejected() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["kite"].duplicate(true)
	c["passive"]["effects"] = [{"trigger": "on_attack", "effect": "summon_dragon", "value": 1}]
	db.chassis["dreamer"] = c
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis dreamer") and e.contains("not implemented"):
			hit = true
	assert_true(hit, "an effect the engine cannot run is reported")


func test_every_foe_has_an_action_roster_and_player_text() -> void:
	var db := ContentDB.load_default()
	for id in db.foes.keys():
		var f: Dictionary = db.foes[id]
		assert_true(not str(f.get("codex", "")).is_empty(), "%s has codex text" % id)
		assert_true(not str(f.get("flavour", "")).is_empty(), "%s has its own flavour line" % id)
		var implemented := 0
		for a in f.get("actions", []):
			if a.get("status") == "implemented":
				implemented += 1
				if Foe.is_attack_action(a):
					assert_false(a.has("value"), "%s: an attack scales the base attack, it has no value of its own" % id)
		assert_true(implemented >= 1, "%s has at least one implemented action" % id)
	var foe := db.make_foe("revenant")
	var entry := db.codex_for_foe(foe)
	var atk := int(db.foes["revenant"]["attack"])
	var said := _moves_text(db, entry)
	assert_true(said.contains("CLAW\nAttack %d" % atk), "codex lists the implemented move, its name then its blow at its own number: %s" % said)
	assert_true(said.contains("for %d." % atk), "and fills {damage} into the text")
	var caster := db.codex_for_foe(db.make_foe("ghost"))
	assert_true(_moves_text(db, caster).contains("RAISE\nBuff"), "and lists a buff, live since 30 September: %s" % _moves_text(db, caster))
	var planned: Dictionary = db.foes["revenant"].duplicate(true)
	planned["actions"] = Array(planned["actions"]).duplicate(true)
	planned["actions"].append({"id": "someday", "name": "Someday", "kind": "buff", "text": "", "status": "planned"})
	db.foes["revenant"] = planned
	assert_false(_moves_text(db, db.codex_for_foe(db.make_foe("revenant"))).contains("SOMEDAY"), "a planned action stays hidden")
	ContentDB.reset_cache()
	assert_eq(entry["flavour"], db.foes["revenant"]["flavour"], "codex quotes the foe, not the faction")


func test_foe_actions_scale_the_base_attack_and_are_picked_by_weight() -> void:
	var f := Foe.make("revenant", 30, 10)
	f.actions = [
		{"id": "claw", "name": "Claw", "factor": 1.0, "strikes": 1, "weight": 3, "text": "Claws for {damage}."},
		{"id": "rend", "name": "Jaw Rend", "factor": 1.5, "strikes": 1, "weight": 1, "text": "Bites for {damage}."},
	]
	assert_eq(f.damage_of(f.actions[1]), 15, "1.5 times 10 is 15, in the magnitude of tens")
	assert_eq(f.text_of(f.actions[1]), "Bites for 15.", "the text shows the number, never the factor")
	assert_eq(f.threat(), 15, "threat is its worst action")
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var rends := 0
	for i in range(400):
		f.choose_action(rng)
		if f.action["id"] == "rend":
			rends += 1
	assert_true(rends > 60 and rends < 140, "a weight of 1 in 4 picks the rend about a quarter of the time (%d of 400)" % rends)
	var sk := Skirmish.new(3)
	var m := Unit.mech(0, "A", Vector2i.ZERO)
	m.shield = 0
	m.hull = 100
	m.hull_max = 100
	m.die = Die.single(Face.shield(10))
	sk.add_mech(m)
	sk.add_foes([f])
	sk.begin()
	sk.start_round()
	assert_true(not f.action.is_empty(), "the round's action is chosen at round start")
	assert_eq(sk.forecast(sk.mechs[0])["incoming"], f.damage(), "and the forecast uses it")
	sk.end_round()
	assert_eq(m.hull, 100 - f.damage(), "and so does the blow")


func test_planned_actions_cannot_claim_to_be_implemented() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var f: Dictionary = db.foes["revenant"].duplicate(true)
	f["actions"].append({"id": "someday", "name": "Someday", "kind": "buff", "text": "", "status": "implemented"})
	db.foes["revenant"] = f
	var hit := false
	for e in db.validate():
		if e.begins_with("foe revenant action someday") and e.contains("effect must be"):
			hit = true
	assert_true(hit, "a non-attack action marked implemented without an effect the engine runs is reported")


func test_face_round_trips_through_json() -> void:
	var f := Face.attack(3, Face.Reach.INDIRECT, [Face.Keyword.ABLATE, Face.Keyword.SUPPRESS], 2)
	var back := Face.from_dict(f.to_dict())
	assert_eq(back.describe(), f.describe(), "describe matches after round trip")
	assert_true(back.has(Face.Keyword.ABLATE) and back.has(Face.Keyword.SUPPRESS), "both keywords kept")


func test_chassis_cooling_is_read_and_never_negative() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.validate().is_empty(), "content validates")
	for id in db.chassis.keys():
		var u := db.make_mech(id)
		assert_eq(u.cooling, int(db.chassis[id].get("cooling", 0)), "%s cooling read from content (0 when absent)" % id)
	var c: Dictionary = db.chassis["kite"].duplicate(true)
	c["cooling"] = -5
	db.chassis["frozen"] = c
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis frozen") and e.contains("cooling"):
			hit = true
	assert_true(hit, "negative cooling is refused")


## A chassis carries no field recharge, no shield regen and no cooling of its own: the reboot is
## how both gauges come back (folded in 15 November), so the validator refuses the three keys.
## What a loadout grants of either shows in the codex, and nothing shows where nothing is granted.
func test_a_chassis_has_no_recharge_regen_or_cooling_of_its_own() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.validate().is_empty(), "content validates")
	for id in db.chassis.keys():
		for gone in ["recharge_field", "shield_regen", "cooling"]:
			assert_false(db.chassis[id].has(gone), "%s names no %s" % [id, gone])
		var built := db.make_mech(id)
		assert_eq([built.shield_regen, built.cooling], [0, 0], "%s regains and cools nothing as stocked" % id)
	var first := str(db.chassis.keys()[0])
	var base: Dictionary = db.chassis[first].duplicate(true)
	var cases := {"old": ["recharge_field", 4], "regen": ["shield_regen", 2], "cooling": ["cooling", 1], "nought": ["cooling", 0]}
	for tag in cases.keys():
		var c := base.duplicate(true)
		c[cases[tag][0]] = cases[tag][1]
		db.chassis["probe_" + tag] = c
	var refused := {}
	for e in db.validate():
		for tag in cases.keys():
			if e.begins_with("chassis probe_%s:" % tag):
				refused[tag] = true
	for tag in cases.keys():
		assert_true(refused.has(tag), "%s %s on a chassis is refused" % [cases[tag][0], str(cases[tag][1])])
	db.chassis["probe_plain"] = base.duplicate(true)
	var plain := db.make_mech("probe_plain")
	var bare: Dictionary = db.codex_for_unit(plain)
	assert_false((bare["stat_items"] as Array).any(func(item) -> bool: return str(item[0]) == "shield regen" or str(item[0]) == "cooling"), "a bare machine's codex lists neither")
	assert_false(str(bare["stats"]).contains("A ROUND") or str(bare["stats"]).contains("A TURN"), "nor does its stats line")
	assert_false(str(bare["stats"]).contains("PHASE"), "and it names no field recharge")
	plain.grant_passive({"id": "probe_mender", "name": "Mender", "description": "", "effects": [
		{"trigger": "static", "effect": "add_stat", "stat": "shield_regen", "value": 2},
		{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 1}]})
	var fitted: Dictionary = db.codex_for_unit(plain)
	assert_eq([plain.shield_regen, plain.cooling], [2, 1], "what a loadout grants is the machine's")
	for want in ["shield regen", "cooling"]:
		assert_true((fitted["stat_items"] as Array).any(func(item) -> bool: return str(item[0]) == want), "and the codex shows its %s" % want)
	assert_true(str(fitted["stats"]).contains("(+2 A ROUND)") and str(fitted["stats"]).contains("(-1 A TURN)"), "with both on the stats line: %s" % str(fitted["stats"]))


## A composition's fields of the long wall brief (section 6), on synthetic compositions: squad 1
## to 4; lead a member, an elite composition's its elite; layout four cells a rank, each null, a
## member's id or a list of them, a massive member in a front cell with the cell behind it null,
## and no member named in more cells than its strength.
## A composition's ramp gate (Ryan, 7 November: variants placed "in the tier-ramp curve"): [lo, hi],
## the Convergences it is dealt at, both held; the lookups deal only those whose gate holds the ramp
## asked (none asked, all); where a domain's compositions of a size at a tier carry gates, together
## they hold every Convergence the tier is fought at, its first to the top; a battle deals by its own.
func test_a_compositions_ramp_gate_deals_it_and_its_tier_is_covered() -> void:
	assert_eq([ContentDB.first_ramp_of(1), ContentDB.first_ramp_of(2), ContentDB.first_ramp_of(3)], [0, Campaign.TIER_EVERY, 2 * Campaign.TIER_EVERY], "a tier is first fought at its Convergence")
	var db := _fresh()
	var formations: Array = db.factions["meadow"]["compositions"]
	# Meadow's tier-one formations made two variants: the low one to C5, the high one from C6.
	var kept: Array = formations.filter(func(c) -> bool: return not (str(c.get("size", "")) == "formation" and ContentDB.composition_tiers(c).has(1)))
	var low := {"id": "gate_low", "size": "formation", "tiers": [1], "ramp": [0, 5], "front": ["goblin", "goblin", null, null], "back": [null, null, null, null]}
	var high := {"id": "gate_high", "size": "formation", "tiers": [1], "ramp": [6, Ramp.TOP], "front": ["goblin", "goblin", "goblin", null], "back": [null, null, null, null]}
	kept.append(low)
	kept.append(high)
	db.factions["meadow"]["compositions"] = kept
	assert_true(db.validate().filter(func(e) -> bool: return str(e).contains("ramp")).is_empty(), "two gates holding 0 to %d between them: sound" % Ramp.TOP)
	assert_eq(db.compositions("meadow", 1, "formation", 3).map(func(c) -> String: return str(c["id"])), ["gate_low"], "at C3, the low variant alone")
	assert_eq(db.compositions("meadow", 1, "formation", 9).map(func(c) -> String: return str(c["id"])), ["gate_high"], "at C9, the high one alone")
	assert_eq(db.compositions("meadow", 1, "formation").size(), 2, "no ramp asked: both")
	assert_eq(db.compositions("meadow", 1, "formation", 9)[0]["ramp"], [6, Ramp.TOP], "the dealt entry carries its gate")
	var b := Battle.new(3)
	b.db = db
	b.ramp = 9
	b.setup([], "meadow")
	for sq in b.field.packs():
		if sq.composition_size == "formation":
			assert_eq(sq.composition, "gate_high", "a battle at C9 deals the variant its gate holds")
	for w in b.field.cycle:
		if str(w["size"]) == "formation":
			assert_eq(str(w["id"]), "gate_high", "and the rift sends no other")
	# A gap in the tier's Convergences is refused, and so is a gate of the wrong shape.
	high["ramp"] = [7, Ramp.TOP]
	assert_true(db.validate().any(func(e) -> bool: return str(e).contains("no formation at tier 1 is dealt at Convergence 6")), "C6 held by none: refused")
	high["ramp"] = [9, 6]
	assert_true(db.validate().any(func(e) -> bool: return str(e).contains("gate_high: ramp is [lo, hi]")), "a gate the wrong way round")
	high["ramp"] = [6, Ramp.TOP + 1]
	assert_true(db.validate().any(func(e) -> bool: return str(e).contains("gate_high: ramp is [lo, hi]")), "a gate past the top")
	high["ramp"] = [6, Ramp.TOP]
	# A tier fought from C4 needs its gates from C4 only; an escort's group is its boss's.
	var court := {"id": "gate_court", "size": "escort", "boss": "floraison", "tiers": [2], "ramp": [Campaign.TIER_EVERY, Ramp.TOP], "front": ["warg", null, null, null], "back": [null, null, null, null]}
	kept = (db.factions["meadow"]["compositions"] as Array).filter(func(c) -> bool: return not (str(c.get("boss", "")) == "floraison" and ContentDB.composition_tiers(c).has(2)))
	kept.append(court)
	db.factions["meadow"]["compositions"] = kept
	assert_true(db.validate().filter(func(e) -> bool: return str(e).contains("ramp")).is_empty(), "tier two's escort gated from its first Convergence: sound")
	assert_eq(str(db.escort_composition("meadow", 2, "floraison", Campaign.TIER_EVERY).get("id", "")), "gate_court", "dealt at it")
	assert_true(db.escort_composition("meadow", 2, "floraison", Campaign.TIER_EVERY - 1).get("boss", "") != "floraison", "and never under it")
	var s := HarnessSetup.defaults(_fresh())
	s.battle_tier = 3
	s.ramp = 0
	assert_eq(s.battle_ramp(), ContentDB.first_ramp_of(3), "the harness raises a battle's Convergence to its tier's first")
	# A tier with none of a size has none: nothing stands in from the tier below (8 November).
	var bare := _fresh()
	bare.factions["meadow"]["compositions"] = (bare.factions["meadow"]["compositions"] as Array).filter(func(c) -> bool: return not (str(c.get("size", "")) == "formation" and ContentDB.composition_tiers(c).has(3)))
	assert_true(bare.compositions("meadow", 3, "formation").is_empty(), "no tier-three formation: none dealt, not tier two's")
	assert_false(bare.compositions("meadow", 2, "formation").is_empty(), "tier two's stay its own")


## The battlefield roles (Ryan, 9 November: a unit is made for a pusher's, a flanker's or a
## hunter's fight and tuned for it, a crossing deliberate; the formation pass, 10 November): a
## foe's role is a pusher's unless it says a hunter's or a flanker's; a formation that pushes
## fields pushers and a patrol that pushes fields flankers, or says why under design.crossing; a
## pack that hunts is led by a hunter and holds only what keeps up with it; every patrol and
## formation writes its question down; elites and escorts are written by other rules.
func test_a_patrol_or_a_formation_is_held_to_its_members_roles_and_poses_a_question() -> void:
	var db := _fresh()
	assert_true(db.validate().is_empty(), "content validates: %s" % str(db.validate().slice(0, 3)))
	var fid := str(db.factions.keys()[0])
	var q := {"question": "What the player must answer."}
	# Units of the test's own, by role and by pace.
	var base: Dictionary = {}
	for id in db.foes.keys():
		var f: Dictionary = db.foes[id]
		if str(f.get("rank", "front")) != "back" and int(f.get("size", 1)) == 1 and not bool(f.get("elite", false)) and not db.is_boss(str(id)) and not f.has("parts") and not bool(f.get("hero", false)) and not f.has("role"):
			base = f.duplicate(true)
			break
	assert_false(base.is_empty(), "content has a plain front-rank pusher to copy")
	for spec in [["probe_pusher", "", 2, false], ["probe_flanker", "flanker", 3, false], ["probe_hunter", "hunter", 4, false], ["probe_slow", "pusher", 2, false], ["probe_keeper", "pusher", 4, false], ["probe_flyer", "hunter", 4, true]]:
		var f := base.duplicate(true)
		f["id"] = spec[0]
		f["name"] = str(spec[0]).capitalize()
		if not str(spec[1]).is_empty():
			f["role"] = spec[1]
		else:
			f.erase("role")
		f["movespeed"] = spec[2]
		if bool(spec[3]):
			f["winged"] = true
		db.foes[spec[0]] = f
	assert_eq(db.role_of("probe_pusher"), "pusher", "a foe that names no role is a pusher")
	assert_eq(db.role_of("probe_hunter"), "hunter", "one that names it is what it says")
	var none := [null, null, null, null]
	var elite_id := ""
	for id in db.foes.keys():
		var e: Dictionary = db.foes[id]
		if elite_id.is_empty() and bool(e.get("elite", false)) and str(e.get("rank", "front")) != "back" and int(e.get("size", 1)) == 1 and not e.has("parts"):
			elite_id = str(id)
	assert_false(elite_id.is_empty(), "content has a front-rank elite to lead the test's elite")
	var cases := {
		"formation of pushers": [{"size": "formation", "front": ["probe_pusher", "probe_pusher", null, null], "design": q}, ""],
		"patrol of flankers": [{"size": "patrol", "front": ["probe_flanker", null, null, null], "design": q}, ""],
		"hunters hunting": [{"size": "patrol", "hunts": "slowest", "front": ["probe_hunter", "probe_hunter", null, null], "design": q}, ""],
		"a pusher that keeps up with the hunt": [{"size": "patrol", "hunts": "slowest", "front": ["probe_hunter", "probe_keeper", null, null], "design": q}, ""],
		"a pusher that lags the hunt": [{"size": "patrol", "hunts": "slowest", "front": ["probe_hunter", "probe_slow", null, null], "design": q}, "does not keep up with its lead"],
		"a walker behind a flying lead": [{"size": "patrol", "hunts": "slowest", "front": ["probe_flyer", "probe_hunter", null, null], "design": q}, "cannot follow its lead"],
		"a hunt led by a pusher": [{"size": "patrol", "hunts": "slowest", "front": ["probe_keeper", "probe_hunter", null, null], "design": q}, "a pack that hunts is led by a hunter"],
		"pushers in a patrol": [{"size": "patrol", "front": ["probe_pusher", "probe_pusher", null, null], "design": q}, "is a pusher in a flanker's patrol"],
		"a flanker in a formation": [{"size": "formation", "front": ["probe_pusher", "probe_flanker", null, null], "design": q}, "is a flanker in a pusher's formation"],
		"a hunter in a formation": [{"size": "formation", "front": ["probe_pusher", "probe_hunter", null, null], "design": q}, "is a hunter in a pusher's formation"],
		"a crossing that says why": [{"size": "formation", "front": ["probe_pusher", "probe_hunter", null, null], "design": {"question": "Q.", "crossing": "The hunter is ridden."}}, ""],
		"no question": [{"size": "formation", "front": ["probe_pusher", null, null, null]}, "design.question says what the player must answer"],
		"an empty question": [{"size": "patrol", "front": ["probe_flanker", null, null, null], "design": {"question": "  "}}, "design.question says what the player must answer"],
		"an elite of anyone": [{"size": "elite", "front": [elite_id, "probe_pusher", "probe_hunter", "probe_flanker"]}, ""],
	}
	for tag in cases.keys():
		var c: Dictionary = (cases[tag][0] as Dictionary).duplicate(true)
		c["id"] = "probe_" + str(tag).replace(" ", "_")
		c["tiers"] = [1]
		if not c.has("back"):
			c["back"] = none.duplicate()
		var own := _fresh()
		for id in db.foes.keys():
			if str(id).begins_with("probe_"):
				own.foes[id] = db.foes[id]
		own.factions[fid]["compositions"].append(c)
		var errs := own.validate().filter(func(e: String) -> bool: return e.contains("composition %s:" % c["id"]))
		var want := str(cases[tag][1])
		if want.is_empty():
			assert_true(errs.is_empty(), "%s validates clean: %s" % [tag, str(errs)])
		else:
			assert_true(errs.any(func(e: String) -> bool: return e.contains(want)), "%s is refused for '%s': %s" % [tag, want, str(errs)])
	var odd := _fresh()
	odd.foes[str(odd.foes.keys()[0])]["role"] = "wanderer"
	assert_true(odd.validate().any(func(e: String) -> bool: return e.contains("role is one of")), "a role content does not know is refused")
	# Content as it stands: every patrol that pushes is a duel, and no formation hunts.
	var real := ContentDB.load_default()
	for f2 in real.factions.keys():
		for t in [1, 2, 3]:
			var lone := 0
			for c in real.compositions(str(f2), t, "patrol"):
				if not c.has("hunts"):
					for m in c["members"]:
						assert_eq(real.role_of(str(m[0])), "flanker", "%s tier %d: %s's %s is a flanker" % [f2, t, c["id"], m[0]])
					if (c["members"] as Array).size() == 1 and int(c["members"][0][1]) == 1:
						lone += 1
			assert_true(lone >= 1, "%s tier %d fields a duel for one machine on its flanks" % [f2, t])
			for c in real.compositions(str(f2), t, "formation"):
				assert_false(c.has("hunts"), "%s tier %d: %s is a formation and pushes" % [f2, t, c["id"]])


func test_the_validator_holds_a_compositions_grid_squad_and_lead() -> void:
	var db := _fresh()
	var none := [null, null, null, null]
	var base := {"id": "probe", "size": "formation", "tiers": [1], "front": ["treant", "goblin", "goblin", "goblin"], "back": [null, "mandragora", null, null],
		"design": {"question": "A tree and three knives before a screamer."}}
	var good := base.duplicate(true)
	good["squad"] = 2
	good["lead"] = "mandragora"
	var cases := {
		"good": [good, ""],
		"squad5": [_with(base, "squad", 5), "squad is 1, 2, 3 or 4"],
		"squad0": [_with(base, "squad", 0), "squad is 1, 2, 3 or 4"],
		"leadwolf": [_with(base, "lead", "wolf"), "lead 'wolf' stands nowhere in its grid"],
		"short": [_with(base, "front", ["goblin", null, null]), "front is four cells"],
		"odd": [_with(base, "front", [42, null, null, null]), "front cell 0 is null or a foe id"],
		"stranger": [_with(base, "front", ["nobody", null, null, null]), "names unknown foe nobody"],
		"deep": [_with(_with(base, "front", none), "back", ["treant", null, null, null]), "names the massive treant"],
		"crowded": [_with(_with(base, "front", ["treant", null, null, null]), "back", ["mandragora", null, null, null]), "the back cell behind it is null"],
		"backfront": [_with(base, "front", ["mandragora", null, null, null]), "stands in the back rank"],
		"frontback": [_with(base, "back", ["goblin", null, null, null]), "stands in the front rank"],
		"orphan": [_with(base, "front", ["warding_orb", "goblin", "goblin", "goblin"]), "is a part and stands only beside its core"],
	}
	for tag in cases.keys():
		var c: Dictionary = (cases[tag][0] as Dictionary).duplicate(true)
		c["id"] = "probe_" + tag
		db.factions["meadow"]["compositions"].append(c)
	var errors := db.validate()
	for tag in cases.keys():
		var mine: Array = errors.filter(func(e: String) -> bool: return e.contains("composition probe_%s:" % tag))
		if str(cases[tag][1]).is_empty():
			assert_true(mine.is_empty(), "%s validates clean: %s" % [tag, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(str(cases[tag][1]))), "%s refused: %s" % [tag, str(mine)])
	var elite := {"id": "probe_elite", "size": "elite", "tiers": [1], "front": ["goblin_nob", "goblin", "goblin", null], "back": none, "lead": "goblin"}
	db.factions["meadow"]["compositions"].append(elite)
	assert_true(db.validate().any(func(e: String) -> bool: return e.contains("composition probe_elite:") and e.contains("led by its elite")), "an elite composition is led by its elite")
	# A core's parts take their cells: the Astromancer as content writes it, and short of an orb.
	var fid_of := db.faction_of_foe("astromancer")
	var astro: Dictionary = {}
	for c in db.factions[fid_of]["compositions"]:
		if str(c.get("id", "")) == "the_astromancer":
			astro = c
	assert_false(astro.is_empty(), "the Astromancer is in content")
	var members := db.grid_members(astro)
	assert_eq(str(members[0][0]), "astromancer", "its members read off the grid lead with the core, the orbs left to parts_for")
	assert_true(members.all(func(m) -> bool: return not db.is_part(str(m[0]))), "no orb among them")
	var short := astro.duplicate(true)
	short["id"] = "probe_short_astro"
	short["front"] = [null, null, null, null]   # its Warding Orb, the core's one part, gone
	db.factions[fid_of]["compositions"].append(short)
	assert_true(db.validate().any(func(e: String) -> bool: return e.contains("probe_short_astro:") and e.contains("a core's parts each take a cell")), "an orb missing is refused")


static func _with(c: Dictionary, key: String, value) -> Dictionary:
	var out := c.duplicate(true)
	out[key] = value
	return out


func test_support_keywords_ride_on_shields_and_vents_only() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var scrubber: Dictionary = _piece(db, "laminar_deflector")
	scrubber["face"]["keywords"] = ["cleanse"]
	scrubber["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["scrubber"] = scrubber
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["keywords"] = ["cleanse"]
	gun["face"].erase("penetrate")   # the beam's Penetrate number goes with its keyword
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["cleansing_gun"] = gun
	var plate: Dictionary = _piece(db, "laminar_deflector")
	plate["face"]["keywords"] = ["ablate"]
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["burning_plate"] = plate
	var bad_gun := false
	var bad_plate := false
	for e in db.validate():
		assert_false(e.begins_with("component scrubber"), "cleanse on a shield validates clean: %s" % e)
		if e.begins_with("component cleansing_gun") and e.contains("rides on a shield or vent"):
			bad_gun = true
		if e.begins_with("component burning_plate") and e.contains("attack keyword"):
			bad_plate = true
	assert_true(bad_gun, "cleanse on an attack is refused")
	assert_true(bad_plate, "burn on a shield is refused")


func test_a_component_passive_from_content_lands_on_the_mech() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var fins: Dictionary = _piece(db, "coolant_jacket")
	fins["name"] = "Finned Sink"
	fins["passive"] = {"id": "fins", "name": "Fins", "description": "Cooling +5.",
		"effects": [{"trigger": "static", "effect": "add_stat", "stat": "cooling", "value": 5}]}
	db.components["fins_pack"] = fins   # the jacket's own tier, a basic, below the chassis that stocks it
	var c: Dictionary = db.chassis["clydesdale"].duplicate(true)
	c["fixed"] = []   # nothing built in, so the component is the die's first entry
	c["loadout"] = ["fins_pack"]
	c["passive"] = null
	db.chassis["finned"] = c
	for e in db.validate():
		assert_false(e.begins_with("chassis finned") or e.begins_with("component fins_pack"), "a stat passive on a component validates clean: %s" % e)
	var u := db.make_mech("finned")
	assert_eq(u.cooling, 5, "the component's cooling, the chassis having none of its own")
	var codex := db.codex_for_unit(u)
	assert_eq(codex["face_rules"][0], ["Fins: Cooling +5."], "the codex prints a component's passive on its row")
	assert_false(str(codex["passive"]).contains("Fins"), "never as the machine's own")
	var cooling_shown := false
	for item in codex["stat_items"]:
		if str(item[0]) == "cooling":
			cooling_shown = true
			assert_eq(StatBlock.value_text(item), "0 (+5▲)", "its cooling nothing of the chassis's, the change the component makes beside it")
	assert_true(cooling_shown, "and the codex lists the cooling it is granted")
	var sink: Face = u.die.faces[0]
	assert_eq(sink.component, "fins_pack", "the first entry is the component")
	assert_eq(Effects.explain(u, sink).size(), 1, "the die row names it")
	# Destroyed, the component keeps its stat bonus (18 September).
	u.die.faces[0] = Face.blank()
	u.die.faces[0].component = "fins_pack"
	assert_eq(u.cooling, 5, "a destroyed component keeps its stat bonus")


func test_a_buff_face_names_a_machine_status() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var good: Dictionary = _piece(db, "laminar_deflector")
	good["face"] = {"kind": "buff", "status": "overcharged", "stacks": 2}
	good["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["coil_ok"] = good
	var foe_status: Dictionary = good.duplicate(true)
	foe_status["face"] = {"kind": "buff", "status": "ablating"}
	foe_status["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["coil_foe"] = foe_status
	var unknown: Dictionary = good.duplicate(true)
	unknown["face"] = {"kind": "buff", "status": "haste", "rounds": 0}
	unknown["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["coil_bad"] = unknown
	var stray: Dictionary = good.duplicate(true)
	stray["face"] = {"kind": "shield", "power": 10, "stacks": 2}
	stray["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["stray"] = stray
	var hit := {"coil_foe": false, "coil_bad": false, "stray": false}
	for e in db.validate():
		assert_false(e.begins_with("component coil_ok"), "a buff granting a machine status validates clean: %s" % e)
		for k in hit.keys():
			if e.begins_with("component " + k):
				hit[k] = true
	assert_true(hit["coil_foe"], "a foe's status is refused on a buff")
	assert_true(hit["coil_bad"], "an unknown status, or zero rounds, is refused")
	assert_true(hit["stray"], "stacks on a shield is refused")


func test_a_spend_keyword_rides_on_any_kind_of_component() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = _piece(db, "laminar_deflector")
	plate["face"]["volatile"] = 3
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_plate"] = plate
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["volatile"] = 3
	gun["face"]["shield_cost"] = 2
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_gun"] = gun
	var fins: Dictionary = _piece(db, "coolant_jacket")
	fins["face"]["volatile"] = 3
	fins["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_fins"] = fins
	for e in db.validate():
		assert_false(e.begins_with("component hot_"), "volatile validates on a shield, an attack and a vent alike, a shield cost too: %s" % e)
	var f := db.build_face(plate["face"])
	assert_eq(f.volatile, 3, "and builds onto the entry as a cost (26 October), with the bite it says")
	assert_eq(db.build_face(gun["face"]).shield_cost, 2, "the shield cost too")


## The gated stuns' fields (22 October): a gate maps a keyword the entry carries (Suppress
## today) to a condition on the foe in hand; a consumer eats a foe status on one blow on each
## foe it strikes, an area one each foe's own (the blow's order, 28 October).
func test_gates_and_consumers_validate() -> void:
	var db := _fresh()
	var base: Dictionary = db.components["enfilade_beam"].duplicate(true)
	base["tier"] = 1
	base["face"].erase("keywords")
	base["face"].erase("penetrate")   # the beam's Penetrate number goes with its keyword
	var flak_gate := {"suppress": {"when": "target_status", "status": "flakked"}}
	var cases := {
		"test_battery": [{"keywords": ["suppress"], "gates": flak_gate}, ""],
		"test_backdraft": [{"keywords": ["suppress"], "gates": {"suppress": {"when": "target_status", "status": "ablating", "stacks": 2}}, "consumes": "ablating", "per_consumed": 1}, ""],
		"test_gate_absent": [{"keywords": [], "gates": flak_gate}, "does not carry"],
		"test_gate_burn": [{"keywords": ["ablate"], "ablate": 2, "gates": {"ablate": {"when": "target_status"}}}, "rides on Suppress today"],
		"test_gate_when": [{"keywords": ["suppress"], "gates": {"suppress": {"when": "ally_present"}}}, "a condition on the foe in hand"],
		"test_gate_status": [{"keywords": ["suppress"], "gates": {"suppress": {"when": "target_status", "status": "numbed"}}}, "a status the team puts on a foe"],
		"test_gate_count": [{"keywords": ["suppress"], "gates": {"suppress": {"when": "target_status", "stacks": 2}}}, "a positive count of the status it names"],
		"test_eat_odd": [{"consumes": "numbed"}, "names a status the team puts on a foe"],
		"test_eat_wide": [{"keywords": ["cleave"], "cleave": 1, "consumes": "ablating"}, ""],   # each foe it strikes eats its own (the blow's order, 28 October)
		"test_eat_twice": [{"strikes": 2, "consumes": "ablating"}, "one blow on each foe"],
		"test_eat_stray": [{"per_consumed": 2}, "only beside consumes"],
	}
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		for k in cases[id][0]:
			c["face"][k] = cases[id][0][k]
		if not c["face"].has("keywords"):
			c["face"]["keywords"] = []
		db.components[id] = c
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])
	var f := db.build_face(db.components["test_backdraft"]["face"])
	assert_eq(f.consumes, "ablating", "the consumer builds onto the entry")
	assert_eq(int(f.gates["suppress"]["stacks"]), 2, "and its gate")
	var back := Face.from_dict(f.to_dict())
	assert_true(back.consumes == "ablating" and back.gates.has("suppress"), "and survives the round trip a save makes")


## Its own fire (the Stoker's, the stock pass's landing, 22 October): self_ablate is a positive
## number of stacks of Ablating on an attack's own machine, kept through a save.
func test_a_weapon_that_burns_its_firer_validates() -> void:
	var db := _fresh()
	var base: Dictionary = db.components["enfilade_beam"].duplicate(true)
	base["tier"] = 1
	base["face"]["keywords"] = []
	base["face"].erase("penetrate")   # the beam's Penetrate number goes with its keyword
	var cases := {
		"test_stoker": [{"keywords": ["ablate"], "ablate": 2, "self_ablate": 1}, ""],
		"test_fire_none": [{"self_ablate": 0}, "a positive number of stacks"],
		"test_fire_vent": [{"kind": "vent", "self_ablate": 1}, "on an attack"],
	}
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		for k in cases[id][0]:
			c["face"][k] = cases[id][0][k]
		db.components[id] = c
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])
	var f := db.build_face(db.components["test_stoker"]["face"])
	assert_eq(f.self_ablate, 1, "its own fire builds onto the entry")
	assert_eq(Face.from_dict(f.to_dict()).self_ablate, 1, "and survives the round trip a save makes")


## The rank condition's reach (the Ram Frame's and the Rangefinder's reads, 22 October) reads an
## attack's own spend: direct or indirect, on an on_attack effect only.
func test_a_reach_beside_the_rank_is_an_attacks_and_a_real_reach() -> void:
	var db := _fresh()
	var base: Dictionary = db.modules["ram_frame"].duplicate(true)
	var cases := {
		"test_rank_reach": [{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_rank", "rank": "back", "reach": "indirect"}, ""],
		"test_rank_odd": [{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "target_rank", "rank": "front", "reach": "close"}, "direct or indirect"],
		"test_rank_static": [{"trigger": "static", "effect": "grant_keyword", "value": "penetrate", "when": "target_rank", "rank": "back", "reach": "indirect"}, "on an attack's own effects only"],
	}
	for id in cases:
		var m: Dictionary = base.duplicate(true)
		m["text"] = {"description": "A test.", "effects": [cases[id][0]]}
		db.modules[id] = m
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.contains(id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])


## The stock pass's engine (22 October): the rule numbers that were constants in code ride as
## fields on their keyword, their face or their status, so the content and the landing set them.
func test_the_rule_numbers_are_fields_on_their_keyword_their_face_or_their_status() -> void:
	var db := _fresh()
	var base: Dictionary = _piece(db, "coolant_jacket")
	base["tier"] = 1
	var cases := {
		"test_keyword": [{"keywords": ["volatile"]}, "Volatile is a cost, not a keyword"],
		"test_nobite": [{"volatile": 0}, "a positive number"],
		"test_bite_ok": [{"volatile": 3}, ""],
		"test_notoll": [{"shield_cost": 0}, "a positive number"],
		"test_toll_ok": [{"shield_cost": 2}, ""],
	}
	var gun: Dictionary = db.components["coriolis_accelerator"].duplicate(true)
	gun["tier"] = 1
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		for k in cases[id][0]:
			c["face"][k] = cases[id][0][k]
		db.components[id] = c
	var stray: Dictionary = base.duplicate(true)
	stray["face"]["per_missing"] = 5
	db.components["test_stray_step"] = stray
	cases["test_stray_step"] = [{}, "only beside power_per_missing"]
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])
	# The missing-HP step reads from the entry, and so does its line.
	var f := db.build_face(gun["face"])
	f.per_missing = 5
	var foe := Foe.new()
	foe.hp_max = 30
	foe.hp = 19
	assert_eq(f.missing_bonus(foe), f.power_per_missing * 2, "two steps of 5 missing")
	assert_true(f.describe().contains("per 5 HP missing"), "the entry prints its step: %s" % f.describe())
	# Cryo's cooling and Corrupted's bite are their statuses' own numbers.
	assert_eq(Skirmish.cryo_cool(), Effects.status_value("cryoed", "cool_hitter"), "Cryo's cooling is the status's")
	assert_eq(Skirmish.corrupt_bite(), Effects.status_value("corrupted", "corrupt_bite"), "Corrupted's bite is the status's")
	assert_true(Skirmish.cryo_cool() > 0 and Skirmish.corrupt_bite() > 0, "both carry a number")


func test_lure_and_disrupt_ride_on_attacks_and_never_on_a_shield() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["keywords"] = ["lure", "disrupt"]
	gun["face"].erase("penetrate")   # the beam's Penetrate number goes with its keyword
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["loud_gun"] = gun
	var plate: Dictionary = _piece(db, "laminar_deflector")
	plate["face"]["keywords"] = ["lure"]
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["loud_plate"] = plate
	var bad_plate := false
	for e in db.validate():
		assert_false(e.begins_with("component loud_gun"), "a lure and a disrupt on a weapon validate: %s" % e)
		if e.begins_with("component loud_plate") and e.contains("is an attack keyword"):
			bad_plate = true
	assert_true(bad_plate, "a lure on a shield is refused")
	var built := db.build_face(gun["face"])
	assert_true(built.has(Face.Keyword.LURE) and built.has(Face.Keyword.DISRUPT), "and the weapon builds with both")
	# The shipped lure: a debuff that lures with a spread, in the Badger's stock.
	var klaxon := db.build_face(db.components["proximity_klaxon"]["face"])
	assert_true(klaxon.is_attack() and klaxon.power == 0 and klaxon.has(Face.Keyword.LURE) and klaxon.has(Face.Keyword.CLEAVE), "the klaxon lures and does nothing else")


func test_grant_keyword_names_a_keyword_the_engine_runs() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["badger"].duplicate(true)
	c["id"] = "ram"
	c["name"] = "Ram Test"
	c["passive"] = {"id": "drive", "name": "Drive", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "shock"}]}
	db.chassis["ram"] = c
	var bad: Dictionary = c.duplicate(true)
	bad["id"] = "ram_bad"
	bad["name"] = "Ram Bad"
	bad["passive"] = {"id": "drive2", "name": "Drive", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "corrode"}]}
	db.chassis["ram_bad"] = bad
	var hit := false
	for e in db.validate():
		assert_false(e.begins_with("chassis ram:"), "a real keyword validates: %s" % e)
		if e.begins_with("chassis ram_bad") and e.contains("grant_keyword"):
			hit = true
	assert_true(hit, "a keyword the engine lacks is refused")
	# A rule one piece carries is no keyword to grant (15 November): the three that were are
	# refused as any unknown word, and the old way of writing a grant out says where it went.
	for gone in ["spillover", "swap", "web"]:
		assert_true(Face.keyword_from_name(gone) <= 0, "%s is no keyword of the engine's" % gone)
	var old: Dictionary = c.duplicate(true)
	old["id"] = "ram_old"
	old["name"] = "Ram Old"
	old["passive"] = {"id": "drive3", "name": "Drive", "description": "", "effects": [
		{"trigger": "static", "effect": "grant_keyword", "value": "shock", "printed": true}]}
	db.chassis["ram_old"] = old
	assert_true(db.validate().any(func(e: String) -> bool: return e.begins_with("chassis ram_old") and e.contains("'printed' is gone")), "a grant written out the old way is refused")


func test_the_vent_on_fire_fields_belong_to_an_attack() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = _piece(db, "laminar_deflector")
	plate["face"]["vents_all"] = true
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["hot_plate"] = plate
	var gun: Dictionary = db.components["enfilade_beam"].duplicate(true)
	gun["face"]["power_per_heat"] = 10
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["half_gun"] = gun
	var bad_plate := false
	var bad_gun := false
	for e in db.validate():
		if e.begins_with("component hot_plate") and e.contains("belong to an attack"):
			bad_plate = true
		if e.begins_with("component half_gun") and e.contains("needs vents_all"):
			bad_gun = true
	assert_true(bad_plate, "vents_all on a shield is refused")
	assert_true(bad_gun, "power_per_heat without vents_all is refused")


func test_a_brace_is_a_positive_number_of_stacks() -> void:
	# The brace (12 October): the stacks of Braced a spend gives its owner. Any kind of entry
	# may brace; nothing braces for zero.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var plate: Dictionary = _piece(db, "laminar_deflector")
	plate["face"]["braces"] = 0
	plate["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["limp_plate"] = plate
	var refused := false
	for e in db.validate():
		if e.begins_with("component limp_plate") and e.contains("braces is a positive number"):
			refused = true
	assert_true(refused, "a brace of nothing is refused")
	# Braced lasts one turn from every source, so no buff grants it for longer.
	var jack: Dictionary = db.components["shoring_jack"].duplicate(true)
	jack["face"]["rounds"] = 2
	jack["tier"] = 1
	db.components["long_jack"] = jack
	var long_refused := false
	for e in db.validate():
		if e.begins_with("component long_jack") and e.contains("lasts until the round's end"):
			long_refused = true
	assert_true(long_refused, "a buff granting Braced for two rounds is refused")


## Rolling again on a status (the Nemesis's fists on rage, 12 October to 11 November) and the
## Spin-Up's spin retired on 12 November: Instant is the roll that may land on itself, a spin on a
## stepping die, and a charged form on a store prices it, so either key is refused.
func test_rolling_again_and_the_spin_are_retired_for_instant() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var gun: Dictionary = db.components["incendiary_shells"].duplicate(true)
	gun["face"] = {"kind": "attack", "reach": "direct", "power": 10, "heat": 2, "rolls_again_on": "rage"}
	gun["tier"] = 1   # a synthetic component no chassis stocks carries its own tier (7 October)
	db.components["odd_gun"] = gun
	var plate: Dictionary = db.components["incendiary_shells"].duplicate(true)
	plate["face"] = {"kind": "shield", "power": 10, "keywords": ["instant"], "heat": 2, "spins": true}
	plate["tier"] = 1
	db.components["odd_plate"] = plate
	var errs := db.validate()
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component odd_gun") and e.contains("rolls_again_on is retired")), "a roll again on a status is refused, Instant in its place")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component odd_plate") and e.contains("spins is retired")), "a spin is refused, Instant's roll a spin on a stepping die")


func test_the_new_passive_fields_are_checked() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var c: Dictionary = db.chassis["badger"].duplicate(true)
	c["id"] = "odd"
	c["name"] = "Odd Test"
	c["passive"] = {"id": "odd", "name": "Odd", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "add_damage", "value": 5, "per_stack": "nonsense"}]}
	db.chassis["odd"] = c
	var hits := 0
	for e in db.validate():
		if e.begins_with("chassis odd") and e.contains("per_stack"):
			hits += 1
	assert_eq(hits, 1, "the bad field is named")


func test_the_foe_actions_run_and_the_validator_knows_their_shape() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var errs := db.validate()
	assert_true(errs.is_empty(), "the shipped foes validate: %s" % str(errs))
	var kinds := {}
	for id in db.foes.keys():
		var f := db.make_foe(id)
		assert_true(Foe.is_attack_action(f.action), "%s opens with its blow" % id)
		for a in f.actions:
			kinds[Foe.kind_of(a)] = true
			if not Foe.is_attack_action(a):
				assert_true(Foe.ACTION_EFFECTS[Foe.kind_of(a)].has(str(a.get("effect", ""))), "%s's %s runs" % [id, a["id"]])
	assert_true(kinds.has("defend") and kinds.has("buff") and kinds.has("debuff"), "every kind is in the content")
	var g: Dictionary = db.foes["revenant"].duplicate(true)
	g["id"] = "odd_ghoul"
	g["name"] = "Odd Ghoul"
	g["actions"] = [{"id": "claw", "name": "Claw", "kind": "attack", "text": "", "status": "implemented"},
		{"id": "odd", "name": "Odd", "kind": "buff", "effect": "nonsense", "text": "", "status": "implemented"},
		{"id": "call", "name": "Call", "kind": "buff", "effect": "summon", "foe": "nobody", "text": "", "status": "implemented"},
		{"id": "hit", "name": "Hit", "kind": "debuff", "effect": "ablate", "factor": 2.0, "text": "", "status": "implemented"}]
	db.foes["odd_ghoul"] = g
	var hits := 0
	for e in db.validate():
		if e.begins_with("foe odd_ghoul") and (e.contains("effect must be") or e.contains("unknown foe") or e.contains("belongs to an attack")):
			hits += 1
	assert_eq(hits, 3, "a bad effect, an unknown summon and an attack field on a debuff are each named")
	var entry := db.codex_for_foe(db.make_foe("bone_wyvern"))
	var said := _moves_text(db, entry)
	# Its defend that recovers, whatever content names it: listed by its name, aimed at itself,
	# its text with its number filled in.
	var mend: Dictionary = {}
	for a in db.foes["bone_wyvern"]["actions"]:
		if str(a.get("effect", "")) == "recover":
			mend = a
	assert_false(mend.is_empty(), "the foe read here carries a defend that recovers")
	assert_true(said.contains("%s\nDefend · Target: Self" % str(mend.get("name", "")).to_upper()), "the codex lists the defend, aimed at itself: %s" % said)
	assert_true(said.contains(str(mend.get("text", "")).replace("{value}", str(int(mend.get("value", 0))))), "with its number filled in")


## A synthetic foe move, so no test leans on a real entry's kit: an attack, or a special of the
## kind given running the engine's first effect of that kind; `when` its condition, if any.
func _foe_move(id: String, kind: String = "attack", when: String = "") -> Dictionary:
	var m := {"id": id, "name": id.capitalize(), "kind": kind, "weight": 1, "text": "", "status": "implemented"}
	if kind != "attack":
		m["effect"] = str(Foe.ACTION_EFFECTS[kind][0])
		m["value"] = 1
	if not when.is_empty():
		m["when"] = when
	return m


## A foe's moves keep content's order (ContentDB.make_foe), the pattern a Disrupt steps through
## and the order a weighted draw walks: an attack that already leads moves nothing, so two
## attacks listed first stay as written, and a later attack (a below-half special, the Black
## Mage's shape) stays where content put it.
func test_a_foe_that_leads_with_an_attack_keeps_its_content_order() -> void:
	var db := ContentDB.new()
	db.foes = {
		"test_twin": {"name": "Twin", "hp": 5, "attack": 2, "actions": [_foe_move("jab"), _foe_move("hook"), _foe_move("guard", "defend")]},
		"test_caster": {"name": "Caster", "hp": 5, "attack": 2, "actions": [_foe_move("fire"), _foe_move("ward", "debuff"), _foe_move("flare", "attack", "below_half")]},
	}
	var twin := db.make_foe("test_twin")
	assert_eq(twin.actions.map(func(a): return str(a["id"])), ["jab", "hook", "guard"], "two attacks listed first keep content's order")
	assert_eq(str(twin.action["id"]), "jab", "and it opens with the first")
	var caster := db.make_foe("test_caster")
	assert_eq(caster.actions.map(func(a): return str(a["id"])), ["fire", "ward", "flare"], "a later attack, a below-half special, is not moved to the front")
	assert_eq(str(caster.action["id"]), "fire", "and it opens with its first attack")


## A foe whose content leads with a special still opens with its blow: its first attack moves
## to the front and nothing else moves, a later attack included.
func test_a_foe_that_leads_with_a_special_opens_with_its_first_attack() -> void:
	var db := ContentDB.new()
	db.foes = {"test_mystic": {"name": "Mystic", "hp": 5, "attack": 2, "actions": [_foe_move("rouse", "buff"), _foe_move("guard", "defend"),
		_foe_move("jab"), _foe_move("hook"), _foe_move("flare", "attack", "below_half")]}}
	var f := db.make_foe("test_mystic")
	assert_eq(f.actions.map(func(a): return str(a["id"])), ["jab", "rouse", "guard", "hook", "flare"], "the first attack leads, the rest in content's order")
	assert_eq(str(f.action["id"]), "jab", "its opening intent is its blow")


func test_every_component_names_a_silhouette_class() -> void:
	var db := ContentDB.new()   # its own copy: the checks below break an entry
	db.load_dir(ContentDB.DIR)
	for id in db.components.keys():
		var c0: Dictionary = db.components[id]
		var shape := str(c0.get("shape", ""))
		assert_true(ContentDB.SHAPES.has(shape), "%s wears a class the model can build" % id)
		# The rule (30 September): a weapon has a shape; armour and vents never do. Narrowed with
		# the blade's retirement (15 November): a locked weapon is built into its machine and never
		# takes a mount, so it may wear none (Ryan: "The four you listed are locked pieces").
		if c0["face"].get("kind") == "attack" and not db.is_fixed(str(id)):
			assert_true(shape != ContentDB.SHAPE_NONE, "%s is a weapon and takes a mount" % id)
		if c0["face"].get("kind") == "vent":
			assert_eq(shape, ContentDB.SHAPE_NONE, "%s is a vent and shows nowhere" % id)
	var c: Dictionary = db.components["enfilade_beam"]
	c["shape"] = "teapot"
	var hit := false
	for e in db.validate():
		if e.begins_with("component enfilade_beam") and e.contains("silhouette class"):
			hit = true
	assert_true(hit, "an unknown class is refused")
	c.erase("shape")
	hit = false
	for e in db.validate():
		if e.begins_with("component enfilade_beam") and e.contains("missing shape"):
			hit = true
	assert_true(hit, "and a component without one")


func test_the_playtest_set_obeys_the_targeting_rules() -> void:
	# The set of 2 October (the bible, section 9): rank and file carry one or two moves and a
	# boss three; every foe reads an aim the engine knows; the ghoul's claw is a swarm blow; a
	# boss wears armour only where its kit is armour (Ryan, 2 November), a point or two, and one
	# whose armour steps by the tier starts from at least a point.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(db.validate().is_empty(), "the set validates: %s" % str(db.validate()))
	for id in db.foes.keys():
		var f := db.make_foe(id)
		assert_true(Foe.AIMS.has(f.aim), "%s aims by a word the engine knows" % id)
		if f.boss:
			assert_eq(f.actions.size(), 3, "%s, a boss, has three moves" % id)
			assert_true(f.armour >= 0 and f.armour <= 2, "%s, a boss, wears no armour or a point or two" % id)
			if f.armour_step > 0:
				assert_true(f.armour > 0, "%s, a boss whose armour steps, starts from a point" % id)
		elif f.hero and db.foes[id].has("promotes"):
			# A promoted form (the bible's section 9): its hero's moves and one more, massive and
			# armoured.
			var base := db.make_foe(str(db.foes[id]["promotes"]))
			assert_true(f.actions.size() >= base.actions.size() and f.actions.size() <= base.actions.size() + 1, "%s, a promoted form, runs its hero's moves and at most one more" % id)
			assert_true(f.is_massive() and f.armour > 0, "%s, a promoted form, is massive and armoured" % id)
		elif f.hero:
			# A hero has three moves (decided 9 October); one may still be planned, so two run.
			assert_true(f.actions.size() >= 2 and f.actions.size() <= 3, "%s, a hero, has two or three moves running" % id)
			assert_eq(f.size, 1, "%s, a hero, is human-sized" % id)
		elif db.is_elite(id):
			# An elite is a mini-boss tier (the bible's tiers row): up to a boss's three moves, its
			# numbers scaled by the tier as a boss's are (2 November).
			assert_true(f.actions.size() >= 1 and f.actions.size() <= 3, "%s, an elite, has one to three moves" % id)
			assert_false(f.boss, "%s, an elite, is no boss" % id)
		elif int(db.foes[id].get("tier", 1)) <= 1:
			assert_true(f.actions.size() >= 1 and f.actions.size() <= 2, "%s has one or two moves" % id)
		else:
			# A tier-two or tier-three recolour carries up to three, the twist the third (Ryan,
			# 28 October: the ladder's move counts, section 5's one rule set row).
			assert_true(f.actions.size() >= 1 and f.actions.size() <= 3, "%s, of tier two or three, has one to three moves" % id)
	# A blow that counts its kin (the engine's swarm) is no content's since the formation pass
	# (10 November: the goblin's and the revenant's lines hit flat, "Kill one goblin, suddenly the
	# whole formation falls apart"), so the rule is read on a foe of the test's own.
	var own := ContentDB.new()
	own.load_dir(ContentDB.DIR)
	var swarmer: Dictionary = own.foes["revenant"].duplicate(true)
	swarmer["id"] = "probe_swarmer"
	swarmer["actions"][0]["swarm"] = 1
	own.foes["probe_swarmer"] = swarmer
	var g := own.make_foe("probe_swarmer")
	assert_eq(g.actions.size(), 1, "the swarmer has one move")
	var swarm := int(g.actions[0].get("swarm", 0))
	assert_true(swarm > 0, "and it swarms")
	g.kin = 3
	assert_eq(g.damage(), int(swarmer["attack"]) + 3 * swarm, "four on the field hit for the blow and three kin's swarm each")
	var entry := own.codex_for_foe(g)
	assert_true(_moves_text(own, entry).contains("Attack %d (+%d a kin standing)" % [int(swarmer["attack"]), swarm]), "the codex says the swarm, at its own number with no kin: %s" % _moves_text(own, entry))
	for fid in db.factions.keys():
		for t in [1, 2, 3]:
			for c in db.compositions(str(fid), t, "formation"):
				for m in c["members"]:
					for a in db.foes[str(m[0])].get("actions", []):
						assert_false(a.has("swarm"), "%s in %s: a formation's unit hits flat; a threat that is its pack's head count is no identity for a pusher" % [m[0], c["id"]])
	# A move's condition and a foe's armour show in its codex, read off whichever armoured foe
	# carries a condition (by structure, never an entry by id: the stand-ins moved to the ranks, 30 October).
	var held_id := ""
	var held_when := ""
	for id in db.foes.keys():
		if not held_id.is_empty() or int(db.foes[id].get("armour", 0)) <= 0:
			continue
		for a in db.foes[id].get("actions", []):
			if held_id.is_empty() and a.has("when") and str(a.get("status", "")) == "implemented":
				held_id = str(id)
				held_when = str(Foe.whens_of(a)[0])
	assert_ne(held_id, "", "an armoured foe with a condition is in content")
	var maw := db.codex_for_foe(db.make_foe(held_id))
	var said := str(Foe.WHEN_TEXT[held_when])
	assert_true(_moves_text(db, maw).contains(said.substr(0, 1).to_upper() + said.substr(1)), "the codex says a move's condition: %s" % _moves_text(db, maw))
	assert_true(str(maw["stats"]).contains("ARM %d" % int(db.foes[held_id]["armour"])), "and its armour")


# The name plate shows the traits, not a silhouette word (Ryan, 2 October): maker, then
# every trait by its shown name, then the die. Synthetic traits and a synthetic chassis, so
# no entry's content is asserted on.
func test_the_codex_plate_lists_the_traits() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	db.vocabulary["test_skids"] = {"id": "test_skids", "category": "trait", "name": "Skids"}
	db.vocabulary["test_quiet"] = {"id": "test_quiet", "category": "trait", "name": "Quiet"}
	var c: Dictionary = db.chassis["clydesdale"].duplicate(true)
	c["traits"] = ["test_skids", "test_quiet"]
	db.chassis["plated"] = c
	var u := db.make_mech("plated")
	var maker := str(db.makers[c["maker"]]["name"]).to_upper()
	assert_eq(str(db.codex_for_unit(u)["subtitle"]), "%s // SKIDS, QUIET // D%d" % [maker, u.die.size()], "maker, the traits by name, the die")
	c["traits"] = []
	db.chassis["bare"] = c
	assert_eq(str(db.codex_for_unit(db.make_mech("bare"))["subtitle"]), "%s // D%d" % [maker, u.die.size()], "no traits, no traits part")
	for e in db.validate():
		assert_false(e.contains("silhouette"), "no chassis needs a silhouette: %s" % e)


## A foe's codex moves as the plate prints them, a line each (EntryReadout.codex_move_lines).
func _moves_text(db: ContentDB, entry: Dictionary) -> String:
	var out: Array[String] = []
	for a in entry["moves"]:
		for l in EntryReadout.codex_move_lines(entry["foe"], a, db):
			out.append(str(l["text"]))
	return "\n".join(out)


## A fresh database the test may edit (the default one is shared and cached).
func test_a_foes_stacking_rider_says_its_number() -> void:
	# 24 October: a foe's Scorch, Ablate and Corrupt say their stacks, as the player's Ablate does,
	# and so does an effect that lays them.
	var db := _fresh()
	var f: Dictionary = db.foes["revenant"].duplicate(true)
	f["actions"] = [{"id": "lick", "name": "Lick", "kind": "attack", "weight": 1, "keywords": ["scorch"], "text": "", "status": "implemented"}]
	db.foes["test_licker"] = f
	assert_true(_refused(db, "foe test_licker", "says its stacks"), "a Scorch without its number is refused")
	f["actions"][0]["scorch"] = 2
	for e in db.validate():
		assert_false(e.begins_with("foe test_licker"), "Scorch 2 validates clean: %s" % e)
	f["actions"][0]["corrupt"] = 1
	assert_true(_refused(db, "foe test_licker", "rides with the corrupt keyword"), "a number without its rider is refused")
	f["actions"][0].erase("corrupt")
	f["actions"].append({"id": "frost", "name": "Frost", "kind": "debuff", "effect": "corrupt_all", "weight": 1, "text": "", "status": "implemented"})
	assert_true(_refused(db, "foe test_licker", "says what it lays"), "an effect that lays stacks says how many")


func _fresh() -> ContentDB:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	return db


func _has_error(db: ContentDB, word: String) -> bool:
	for e in db.validate():
		if e.contains(word):
			return true
	return false


func test_a_component_stores_its_tier_and_the_basics_are_the_starting_blueprints() -> void:
	# 7 October: tier is power and complexity, never the maker. Stored since the stock pass (22
	# October): a component carries its tier whatever stocks it, and moving a chassis moves
	# nothing; the basics, tier zero, are the blueprints a run starts with.
	var db := _fresh()
	var stocked := ""
	var host := ""
	for id in db.chassis.keys():
		for cid in db.chassis[id].get("loadout", []):
			if stocked.is_empty() and db.component_tier(str(cid)) == 0:
				stocked = str(cid)
				host = str(id)
	assert_true(not stocked.is_empty(), "the content stocks a basic")
	assert_true(db.starting_blueprints().has(stocked), "a basic is a starting blueprint")
	db.chassis[host]["tier"] = 3
	assert_eq(db.component_tier(stocked), 0, "a chassis moving tier moves none of its stock")
	db.components[stocked]["tier"] = 1
	assert_eq(db.component_tier(stocked), 1, "the tier is the component's own")
	assert_false(db.starting_blueprints().has(stocked), "and above zero it is found, never started with")
	for cid in db.starting_blueprints():
		assert_eq(db.component_tier(str(cid)), 0, "%s starts the run as a basic" % cid)


func test_the_tier_rules_are_validated() -> void:
	var db := _fresh()
	var capital := db.capital_maker()
	var cap_chassis := ""
	var plain := ""
	for id in db.chassis.keys():
		if str(db.chassis[id].get("maker", "")) == capital and cap_chassis.is_empty():
			cap_chassis = str(id)
		elif plain.is_empty() and not db.chassis[id].get("loadout", []).is_empty():
			plain = str(id)
	assert_true(not cap_chassis.is_empty(), "the content has a chassis of the capital's maker")
	db.chassis[cap_chassis]["tier"] = 1
	assert_true(_has_error(db, "fields no tier one"), "the capital's maker fields no tier one")
	db = _fresh()
	db.chassis[plain].erase("tier")
	assert_true(_has_error(db, "tier must be 1, 2 or 3"), "a chassis needs a tier")
	db = _fresh()
	var stocked := str(db.chassis[plain]["loadout"][0])
	db.components[stocked].erase("tier")
	assert_true(_has_error(db, "component %s: tier must be 0, 1, 2 or 3" % stocked), "a component that is not locked stores its tier")
	db = _fresh()
	db.components[stocked]["tier"] = 4
	assert_true(_has_error(db, "component %s: tier must be 0, 1, 2 or 3" % stocked), "and only 0 to 3")
	# A chassis stocks up to its own tier at tiers one and two, and a tier three to tier two (the
	# bible's tiers row; the validator's half since 11 November), so a tier-three piece is found.
	for own in [1, 2, 3]:
		db = _fresh()
		db.chassis[plain]["tier"] = own
		for cid in db.chassis[plain]["loadout"]:
			db.components[cid]["tier"] = 0
		assert_false(_has_error(db, "chassis %s: stocks %s at tier" % [plain, stocked]), "a tier-%d chassis stocks basics" % own)
		db.components[stocked]["tier"] = mini(own, 2)
		assert_false(_has_error(db, "chassis %s: stocks %s at tier" % [plain, stocked]), "a tier-%d chassis stocks a tier-%d piece" % [own, mini(own, 2)])
		db.components[stocked]["tier"] = mini(own, 2) + 1
		assert_true(_has_error(db, "chassis %s: stocks %s at tier" % [plain, stocked]), "a tier-%d chassis stocks nothing of tier %d" % [own, mini(own, 2) + 1])
	db = _fresh()
	var cap_piece := ""
	for cid in db.components.keys():
		if cap_piece.is_empty() and str(db.components[cid].get("maker", "")) == capital and not db.is_fixed(str(cid)):
			cap_piece = str(cid)
	assert_true(not cap_piece.is_empty(), "the capital's maker makes a component")
	db.components[cap_piece]["tier"] = 0
	assert_true(_has_error(db, "the capital's maker makes no basics"), "the capital's maker has no tier zero")
	for e in _fresh().validate():
		assert_false(e.contains("tier"), "today's content keeps every tier rule: %s" % e)


func test_rapid_rides_on_anything_and_shock_on_weapons_only() -> void:
	# 9 October: rapid joined volatile as a keyword about the spend, so a vent may carry it;
	# shock is a weapon's.
	var db := _fresh()
	var vent: Dictionary = _piece(db, "coolant_jacket")
	vent["face"]["keywords"] = ["rapid"]
	vent["face"]["cooldown"] = 1   # its limiter, printed (Rapid carries none of its own, 2 November)
	vent["tier"] = 1
	db.components["test_vent"] = vent
	var plate: Dictionary = _piece(db, "laminar_deflector")
	plate["face"]["keywords"] = ["shock"]
	plate["tier"] = 1
	db.components["test_plate"] = plate
	var refused_shock := false
	for e in db.validate():
		assert_false(e.begins_with("component test_vent"), "a rapid vent validates: %s" % e)
		if e.begins_with("component test_plate") and e.contains("is an attack keyword"):
			refused_shock = true
	assert_true(refused_shock, "a shock on a shield is refused")
	var built := db.build_face(vent["face"])
	assert_true(built.kind == Face.Kind.VENT and built.has(Face.Keyword.RAPID), "and the vent builds rapid")


func test_every_chassis_states_its_module_slots() -> void:
	# A number of the chassis, never bought (Ryan; bible section 10): the validator wants it
	# on every chassis and holds it to a small range.
	var db := _fresh()
	for id in db.chassis.keys():
		assert_true(db.chassis[id].has("module_slots"), "%s states its module slots" % id)
	var bare: Dictionary = db.chassis.values()[0].duplicate(true)
	bare.erase("module_slots")
	bare["id"] = "test_bare"
	db.chassis["test_bare"] = bare
	assert_true(_has_error(db, "missing module_slots"), "a chassis without its slots is refused")
	db = _fresh()
	var wide: Dictionary = db.chassis.values()[0].duplicate(true)
	wide["module_slots"] = ContentDB.MAX_MODULE_SLOTS + 1
	wide["id"] = "test_wide"
	db.chassis["test_wide"] = wide
	assert_true(_has_error(db, "module_slots must be"), "and so is one past the range")


## A synthetic module, so no test leans on a real entry's numbers or text.
func _module(maker: String, tier: int, stats: Dictionary, text) -> Dictionary:
	return {"id": "test_module", "name": "Test Module", "maker": maker, "tier": tier, "codex": "", "flavour": "",
		"stats": stats, "text": text, "design": {"fantasy": "A test."}}


func test_a_module_is_its_stat_lines_and_its_text_on_the_machine() -> void:
	# Built 9 October: a module is read like a passive, sourced "module", and the machine
	# starts whole on the numbers it made.
	var db := _fresh()
	var maker := str(db.chassis["badger"]["maker"])
	db.modules["test_module"] = _module(maker, 1, {"hull": 30, "armour": 5, "move": -1},
		{"description": "Its weapons run twice as hot.", "effects": [{"trigger": "on_attack", "effect": "multiply_heat", "value": 2}]})
	var plain := db.make_mech("badger")
	var u := db.make_mech("badger", 0, Vector2i.ZERO, null, ["test_module"])
	assert_eq(Array(u.modules), ["test_module"], "the machine knows its module")
	assert_eq(u.hull_max, plain.hull_max + 30, "hull line")
	assert_eq(u.hull, u.hull_max, "and it starts whole on it")
	assert_eq(u.armour, plain.armour + 5, "armour line")
	assert_eq(u.movespeed, plain.movespeed - 1, "a drawback line")
	var gun: Face = null
	for f in u.die.faces:
		if f.kind == Face.Kind.ATTACK:
			gun = f
			break
	assert_eq(int(Effects.attack(u, gun, 10, 10)["heat"]), 2 * int(Effects.attack(plain, gun, 10, 10)["heat"]), "and the text runs")
	var codex := db.codex_for_unit(u)
	var found := false
	for e in codex["effects"]:
		if str(e["name"]) == "TEST MODULE" and str(e["note"]) == "MODULE":
			found = str(e["kind"]) == "module" and str(e["text"]) == "Hull +30, armour +5, move -1. Its weapons run twice as hot."
	assert_true(found, "the codex lists it among the active effects as a module, with its lines and its text: %s" % str(codex["effects"]))
	var read := {}
	for item in codex["stat_items"]:
		read[str(item[0]).get_slice(" ", 0)] = StatBlock.value_text(item)
	assert_eq(read["hull"], "%d (+30▲)" % int(plain.base["hull"]), "its hull the chassis's, the module's change in a bracket, up")
	assert_eq(read["move"], "%d (-1▼)" % int(plain.base["move"]), "and a drawback down")


## A rule a module's text writes on its machine's weapons (the Overrun Gearing's spill, 12
## November; its own effect and no keyword since 15 November): its weapons spill, and the star
## and the hold read the module's rule, never the stat lines its own description leads with.
func test_a_modules_written_rule_reads_its_rule_and_never_its_stat_lines() -> void:
	var db := _fresh()
	var maker := str(db.chassis["badger"]["maker"])
	db.modules["test_module"] = _module(maker, 1, {"hull": 8},
		{"description": "Damage past a kill spills behind.", "effects": [{"trigger": "static", "effect": "spillover", "value": 1}]})
	var u := db.make_mech("badger", 0, Vector2i.ZERO, null, ["test_module"])
	var gun: Face = null
	for f in u.die.faces:
		if f.is_weapon():
			gun = f
			break
	assert_true(gun != null, "the machine has a weapon to wear it")
	assert_true(Effects.effective_face(u, gun).spills and not gun.spills, "its weapons spill as the machine fires them, the piece itself unchanged")
	assert_eq(Effects.written_rules(u, gun), ["Damage past a kill spills behind."] as Array[String], "the star reads the rule alone")
	assert_true(Effects.explain(u, gun).has("Damage past a kill spills behind. (Test Module)"), "and so does the hold: %s" % str(Effects.explain(u, gun)))
	assert_eq(db.module_description("test_module"), "Hull +8. Damage past a kill spills behind.", "where the module reads its stat line first")


func test_a_machine_wears_no_more_modules_than_its_slots() -> void:
	var db := _fresh()
	var maker := str(db.chassis["badger"]["maker"])
	db.modules["test_module"] = _module(maker, 1, {"hull": 10}, null)
	var slots := int(db.chassis["badger"]["module_slots"])
	var asked: Array = []
	for i in range(slots + 1):
		asked.append("test_module")
	var u := db.make_mech("badger", 0, Vector2i.ZERO, null, asked)
	assert_eq(u.modules.size(), slots, "one past the slots is left off")
	assert_eq(u.hull_max, db.make_mech("badger").hull_max + 10 * slots, "the same module twice stacks")


func test_the_module_rules_are_validated() -> void:
	var db := _fresh()
	var plain_maker := ""
	for id in db.makers.keys():
		if str(id) != db.capital_maker():
			plain_maker = str(id)
			break
	db.modules["test_module"] = _module(plain_maker, 1, {"hull": 10, "armour": 5, "shield": 5, "cooling": 5}, null)
	for e in db.validate():
		assert_false(e.begins_with("module test_module"), "four stat lines and no text validate: %s" % e)
	db.modules["test_module"] = _module(db.capital_maker(), 1, {"hull": 10}, null)
	assert_true(_has_error(db, "no tier-one module"), "the capital's maker has no tier-one module")
	db.modules["test_module"] = _module(plain_maker, 4, {"hull": 10}, null)
	assert_true(_has_error(db, "module test_module: tier must be"), "a tier is 1 to 3")
	db.modules["test_module"] = _module(plain_maker, 1, {"luck": 10}, null)
	assert_true(_has_error(db, "stat 'luck' is not one of"), "a stat line names an engine stat")
	db.modules["test_module"] = _module(plain_maker, 1, {"hull": 0}, null)
	assert_true(_has_error(db, "must be a whole number other than zero"), "and is not zero")
	db.modules["test_module"] = _module(plain_maker, 1, {}, null)
	assert_true(_has_error(db, "needs stats, a text or both"), "an empty module is refused")
	db.modules["test_module"] = _module(plain_maker, 1, {}, {"description": "x", "effects": [{"trigger": "static", "effect": "no_such_thing", "value": 1}]})
	assert_true(_has_error(db, "is not implemented by the engine"), "a text is checked like a passive")
	db.modules["test_module"] = _module(plain_maker, 1, {}, {"description": "x", "status": "planned", "effects": [{"trigger": "static", "effect": "no_such_thing", "value": 1}]})
	for e in db.validate():
		assert_false(e.begins_with("module test_module"), "a planned text waits: %s" % e)


func test_a_split_is_validated_one_deep_and_read_into_the_foe() -> void:
	var db := _db()
	var any_id: String = db.foes.keys()[0]
	var a: Dictionary = db.foes[any_id].duplicate(true)
	a["on_death"] = {"summon": "nobody", "count": 2}
	db.foes["split_test"] = a
	var errs := db.validate()
	assert_true("\n".join(errs).contains("on_death must name a known foe"), "an unknown foe is refused")
	a["on_death"] = {"summon": any_id, "count": 2}
	var b: Dictionary = db.foes[any_id].duplicate(true)
	b["on_death"] = {"summon": "split_test", "count": 1}
	db.foes["chain_test"] = b
	errs = db.validate()
	assert_true("\n".join(errs).contains("a split goes one deep"), "a chain of splits is refused")
	db.foes.erase("chain_test")
	errs = db.validate()
	assert_false("\n".join(errs).contains("split"), "one level validates: %s" % str(errs))
	var f := db.make_foe("split_test")
	assert_eq(f.on_death, {"summon": any_id, "count": 2}, "read into the foe")
	db.foes.erase("split_test")


## A component's sound (decided 2 October): its label where content names one, else derived
## from shape and face. Synthetic components, so no entry's sound is pinned here.
func test_a_component_sound_is_its_label_or_derived() -> void:
	var db := ContentDB.new()
	var kinetic := {"kind": "attack", "reach": "direct", "power": 10}
	var energy := {"kind": "attack", "reach": "direct", "power": 15}
	db.components = {
		"slug": {"shape": "barrel", "maker": "minerva", "tags": ["ballistic"], "face": kinetic},
		"twin": {"shape": "twin_barrel", "maker": "kestrel", "face": kinetic},
		"beam": {"shape": "barrel", "maker": "kestrel", "tags": ["beam"], "face": energy},
		"hot": {"shape": "barrel", "maker": "arsenal", "tags": ["plasma"], "face": energy},
		"hot_rack": {"shape": "rack", "maker": "arsenal", "tags": ["plasma"], "face": energy},
		"plow": {"shape": "none", "maker": "minerva", "face": {"kind": "attack", "reach": "direct", "power": 5}, "sound": "blunt"},
		"fist": {"shape": "none", "maker": "arsenal", "face": energy, "sound": ["blunt", "plasma"]},
		"field": {"shape": "none", "maker": "minerva", "face": {"kind": "shield", "power": 20}},
		"coil": {"shape": "dish", "maker": "kestrel", "face": {"kind": "buff"}},
		"lure": {"shape": "dish", "maker": "minerva", "face": {"kind": "attack", "reach": "indirect", "power": 0}},
		"bare": {"shape": "none", "maker": "minerva", "face": {"kind": "attack", "reach": "indirect", "power": 5}},
		"vent": {"shape": "none", "maker": "minerva", "face": {"kind": "vent", "power": 10}},
	}
	assert_eq(db.sound_of("slug"), ["barrel"], "a kinetic barrel is a barrel")
	assert_eq(db.sound_of("twin"), ["twin_barrel"], "a twin a twin")
	assert_eq(db.sound_of("beam"), ["laser"], "a Beam barrel a laser")
	assert_eq(db.sound_of("hot"), ["plasma"], "a Plasma barrel a plasma")
	assert_eq(db.sound_of("hot_rack"), ["rack"], "the Arsenal's rack still a rack")
	assert_eq(db.sound_of("plow"), ["blunt"], "a label wins")
	assert_eq(db.sound_of("fist"), ["blunt", "plasma"], "a list is layers")
	assert_eq(db.sound_of("field"), ["deflector"], "a shield a deflector, whatever its mount")
	assert_eq(db.sound_of("coil"), ["coil"], "a buff a coil")
	assert_eq(db.sound_of("lure"), ["coil"], "a dish that attacks a coil")
	assert_eq(db.sound_of("bare"), ["rack"], "an attack with no mount by its reach")
	assert_eq(db.sound_of("vent"), [], "a vent has none of these")
	assert_eq(db.sound_of("nothing"), [], "an unknown id has none")


func test_every_component_derives_a_sound_the_game_plays() -> void:
	var db := ContentDB.load_default()
	for id in db.components:
		var kind := str(db.components[id].get("face", {}).get("kind", ""))
		var layers := db.sound_of(id)
		if kind == "vent":
			assert_eq(layers, [], "%s is a vent" % id)
			continue
		assert_true(not layers.is_empty(), "%s has a sound" % id)
		assert_true(not Sound.blow(layers).is_empty(), "%s's sound %s has a blow" % [id, layers])


func test_a_locked_component_is_never_a_blueprint() -> void:
	# Ryan, 9 October: locked components are powerful and unique, which is why they are locked.
	var db := _fresh()
	var locked := ""
	var plain := ""
	for id in db.chassis.keys():
		if locked.is_empty() and not db.chassis[id].get("fixed", []).is_empty():
			locked = str(db.chassis[id]["fixed"][0])
		if plain.is_empty() and int(db.chassis[id].get("tier", 0)) == 1 and not db.chassis[id].get("loadout", []).is_empty():
			plain = str(id)
	assert_true(not locked.is_empty() and not plain.is_empty(), "the content has a locked component and a tier-one stock")
	assert_eq(db.component_tier(locked), ContentDB.NO_TIER, "a locked component has no tier")
	for bp in db.starting_blueprints():
		assert_false(db.is_fixed(str(bp)), "no starting blueprint is locked anywhere: %s" % bp)
	db.chassis[plain]["loadout"][0] = locked
	assert_true(_has_error(db, "locked on a chassis, so no hardpoint stocks it"), "a hardpoint stocking a locked component is refused")
	assert_eq(db.component_tier(locked), ContentDB.NO_TIER, "and even then it is never a blueprint")
	assert_false(db.starting_blueprints().has(locked), "nor started with")
	db = _fresh()
	db.components[locked]["tier"] = 2
	assert_true(_has_error(db, "locked on a chassis, so it carries no tier"), "a locked component storing a tier is refused")


## Ablate is a numbered keyword (Ryan, 18 October): a weapon says the stacks each blow leaves,
## and the number rides with the keyword.
func test_a_burn_weapon_says_its_stacks() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var mute: Dictionary = db.components["blazethrower"].duplicate(true)
	mute["face"].erase("ablate")
	mute["tier"] = 1
	db.components["mute_torch"] = mute
	var stray: Dictionary = db.components["slugthrower"].duplicate(true)
	stray["face"]["ablate"] = 2
	stray["tier"] = 1
	db.components["stray_number"] = stray
	var errs := db.validate()
	var mute_refused := false
	var stray_refused := false
	for e in errs:
		if e.begins_with("component mute_torch") and e.contains("says its stacks"):
			mute_refused = true
		if e.begins_with("component stray_number") and e.contains("rides with the Ablate keyword"):
			stray_refused = true
	assert_true(mute_refused, "an Ablate weapon with no number is refused")
	assert_true(stray_refused, "a number with no Ablate keyword is refused")
	var shipped := ContentDB.new()
	shipped.load_dir(ContentDB.DIR)
	for c in shipped.components.values():
		var fd: Dictionary = c.get("face", {})
		if Array(fd.get("keywords", [])).has("ablate"):
			assert_true(int(fd.get("ablate", 0)) >= 1, "%s carries its Ablate number" % c["id"])
	assert_eq(db.build_face(db.components["blazethrower"]["face"]).ablate, int(db.components["blazethrower"]["face"]["ablate"]), "the number reaches the entry")


## A halving status has no duration (Ryan, 18 October: "Things either decrease to zero, or are
## timed, not both"): a buff of Empowered grants stacks and no rounds.
func test_a_buff_of_a_halving_status_takes_no_rounds() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_false(db.components["overcharge_coil"]["face"].has("rounds"), "the Overcharge Coil says its stacks and no rounds")
	var timed: Dictionary = db.components["overcharge_coil"].duplicate(true)
	timed["face"]["rounds"] = 2
	timed["tier"] = 1
	db.components["timed_coil"] = timed
	var refused := false
	for e in db.validate():
		if e.begins_with("component timed_coil") and e.contains("stacks and no rounds"):
			refused = true
	assert_true(refused, "a buff granting Empowered for rounds is refused")
	assert_true(Effects.decays_to_zero(Effects.STATUS["overcharged"]), "Empowered runs down on its own")
	assert_false(Effects.decays_to_zero(Effects.STATUS["primed"]), "Primed is timed by the component")
	assert_false(Effects.decays_to_zero(Effects.STATUS["braced"]), "Armoured ends with the round")


## lay_status (the funnel-web's Ambush, 18 October) names a status the engine has and lays at
## least a stack a hit.
func test_lay_status_names_an_engine_status_and_lays_at_least_a_stack() -> void:
	var db := _fresh()
	var base: Dictionary = db.chassis["badger"].duplicate(true)
	var cases := {"lay_ok": ["vitriol", 1], "lay_none": ["nothing", 1], "lay_zero": ["vitriol", 0]}
	for id in cases.keys():
		var c: Dictionary = base.duplicate(true)
		c["id"] = id
		c["name"] = str(id).capitalize()
		c["passive"] = {"id": "p_" + str(id), "name": "P", "description": "", "effects": [
			{"trigger": "on_attack", "effect": "lay_status", "value": cases[id][0], "stacks": cases[id][1], "when": "target_no_intent"}]}
		db.chassis[id] = c
	var refused := {}
	for e in db.validate():
		for id in cases.keys():
			if e.begins_with("chassis %s" % id) and e.contains("lay_status"):
				refused[id] = true
	assert_false(refused.has("lay_ok"), "a status the engine has, a stack a hit: clean")
	assert_true(refused.has("lay_none"), "a status the engine lacks is refused")
	assert_true(refused.has("lay_zero"), "and so is a lay of no stacks")
	assert_true(Effects.supports_when("target_no_intent"), "the ambush condition is one the engine runs")


## A passive effect may hold on one of its machine's pieces (`entry`) and while it is sealed (the
## Polar Bear's Lockdown, Ryan, 9 November: its Cryo Flinger gains Spread while sealed): the entry
## names a component the content holds; an area granted to a debuff carries no number, as a
## debuff's printed one does, and one granted anywhere else says its number. Synthetic passives.
func test_a_passive_may_hold_on_one_piece_and_on_the_sealed_form() -> void:
	assert_true(Effects.supports_when("sealed"), "the sealed form is a condition the engine runs")
	var db := _fresh()
	var debuff := "proximity_klaxon"   # any shipped debuff; the test reads its kind, never its rules
	assert_true(db.build_face(db.components[debuff]["face"]).is_debuff(), "the piece named is a debuff")
	var gun := "rivet_gun"
	var cases := {
		"probe_ok": [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "sealed", "entry": debuff}, ""],
		"probe_numbered": [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "number": 1, "when": "sealed", "entry": debuff}, "carries no number"],
		"probe_gun": [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "sealed", "entry": gun}, "says what each foe past the target takes"],
		"probe_gun_numbered": [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "number": 1, "when": "sealed", "entry": gun}, ""],
		"probe_nothing": [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "sealed", "entry": "no_such_piece"}, "entry names no component"],
	}
	for id in cases:
		var ch: Dictionary = db.chassis["prairie_dog"].duplicate(true)   # the striker-status test's clean probe
		ch["passive"] = {"id": "p", "name": "P", "description": "A rule.", "effects": [cases[id][0]]}
		db.chassis[id] = ch
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("chassis %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused for '%s': %s" % [id, want, str(mine)])
	assert_eq(Effects.effect_text(cases["probe_ok"][0]), "while sealed: gains spread", "the grant reads with its condition as the lead")


func test_a_passive_may_read_the_striker_for_a_status_the_vocabulary_drafts() -> void:
	# The Prairie Dog's fight half (21 October): its clause named Flak before Flak was built (the
	# same day), so the passive stayed built and the chassis dealable; a status nobody knows is refused.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var drafted := "probe_status"   # a synthetic drafted status, none the engine knows
	db.vocabulary[drafted] = {"id": drafted, "category": "status", "name": "Probe", "codex": "A probe.", "status": "planned",
		"design": {"holes": "", "table": {"kind": "debuff", "on": "foe", "stacks": "No", "lasts": "The round"}}}
	assert_false(Effects.STATUS.has(drafted), "the vocabulary drafts a status to test with")
	var ch: Dictionary = db.chassis["prairie_dog"].duplicate(true)
	ch["passive"] = {"id": "p", "name": "P", "description": "A rule.", "effects": [
		{"trigger": "static", "effect": "add_damage_taken", "value": -5, "when": "attacker_status", "status": drafted}]}
	db.chassis["probe_car"] = ch
	for e in db.validate():
		assert_false(e.begins_with("chassis probe_car"), "a drafted status on the striker's condition passes: %s" % e)
	assert_true(db.chassis_runnable("probe_car"), "and the chassis stays dealable")
	ch["passive"]["effects"][0]["status"] = "nonsense"
	db.chassis["probe_car"] = ch
	var hit := false
	for e in db.validate():
		if e.begins_with("chassis probe_car") and e.contains("attacker_status"):
			hit = true
	assert_true(hit, "a status nobody knows is refused")


## A charged form may draw on another store than the Muster (the Nemesis's rage, 11 November):
## a status tagged a store, priced in its stacks, never beside a muster price; a price needs its
## store.
func test_a_charged_form_on_a_store_names_a_store_and_its_price() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var base: Dictionary = db.components["slugthrower"].duplicate(true)
	var cases := {
		"store_ok": [{"store": "rage", "price": 5, "keywords": ["shock"]}, ""],
		"store_not_one": [{"store": "overcharged", "price": 5}, "tagged a store"],
		"store_and_muster": [{"store": "rage", "muster": 1}, "never in musters"],
		"price_alone": [{"price": 3, "keywords": ["shock"]}, "needs the store"],
		"price_nothing": [{"store": "rage", "price": 0}, "at least one stack"],
	}
	for id in cases.keys():
		var c: Dictionary = base.duplicate(true)
		c["face"]["charged"] = cases[id][0]
		db.components["probe_" + id] = c
	var errs := db.validate()
	for id in cases.keys():
		var want := str(cases[id][1])
		var hit := errs.filter(func(e: String) -> bool: return e.begins_with("component probe_" + id + " ") and e.contains("charged"))
		if want.is_empty():
			assert_true(hit.is_empty(), "%s passes: %s" % [id, hit])
		else:
			assert_true(hit.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, hit])


## Cryo is a numbered keyword like Ablate (20 October), and the Polar Bear's content runs: its
## Lockdown passive carries the seal, its die its fixed Cryo Flinger before its hardpoints (one
## since 9 November, Ryan: a five-entry die).
func test_a_cryo_weapon_says_its_stacks_and_the_polar_bear_leads_with_its_flinger() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var mute: Dictionary = db.components["cryo_flinger"].duplicate(true)
	mute["face"].erase("cryo")
	db.components["mute_flinger"] = mute
	var stray: Dictionary = db.components["slugthrower"].duplicate(true)
	stray["face"]["cryo"] = 1
	stray["tier"] = 1
	db.components["stray_cryo"] = stray
	var refused := {}
	for e in db.validate():
		if e.begins_with("component mute_flinger") and e.contains("says its stacks"):
			refused["mute"] = true
		if e.begins_with("component stray_cryo") and e.contains("rides with the Cryo keyword"):
			refused["stray"] = true
	assert_true(refused.has("mute"), "a Cryo weapon with no number is refused")
	assert_true(refused.has("stray"), "a number with no Cryo keyword is refused")
	var fresh := ContentDB.load_default()
	var m := fresh.make_mech("polar_bear")
	var fixed: Array = fresh.chassis["polar_bear"]["fixed"]
	assert_eq(m.die.faces.size(), fixed.size() + int(fresh.chassis["polar_bear"]["hardpoints"]), "its fixed pieces and its hardpoints")
	for k in range(fixed.size()):
		assert_eq(m.die.faces[k].component, str(fixed[k]), "its fixed pieces lead the die")
	assert_true(m.die.faces[0].has(Face.Keyword.CRYO) and m.die.faces[0].has(Face.Keyword.LURE), "the Flinger lures and lays Cryo")
	assert_eq(m.armour, int(fresh.chassis["polar_bear"]["armour"]), "its base armour, as the content says")


## Flak lands (21 October): the Flakshot Repeater builds with its Flak and sprays, and the
## validator asks a Flak weapon for its stacks and the stacks for the keyword, as it does Ablate's
## and Cryo's (a foe carrying Flak hitting lighter is the synthetic attacker_status test's).
func test_the_flakshot_lays_flak_and_the_validator_asks_for_its_stacks() -> void:
	var fresh := ContentDB.load_default()
	var m := fresh.make_mech("prairie_dog")
	var gun: Face = null
	for f in m.die.faces:
		if f.component == "flakshot_repeater":
			gun = f
	var stacks := int(fresh.components["flakshot_repeater"]["face"]["flak"])
	assert_true(gun != null and gun.has(Face.Keyword.FLAK) and gun.flak == stacks and stacks > 0, "the Repeater carries its Flak")
	assert_true(gun.has(Face.Keyword.CLEAVE), "and sprays")
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var mute: Dictionary = db.components["flakshot_repeater"].duplicate(true)
	mute["face"].erase("flak")
	db.components["mute_flak"] = mute
	var stray: Dictionary = db.components["slugthrower"].duplicate(true)
	stray["face"]["flak"] = 1
	stray["tier"] = 1
	db.components["stray_flak"] = stray
	var refused := {}
	for e in db.validate():
		if e.begins_with("component mute_flak") and e.contains("says its stacks"):
			refused["mute"] = true
		if e.begins_with("component stray_flak") and e.contains("rides with the Flak keyword"):
			refused["stray"] = true
	assert_true(refused.has("mute"), "a Flak weapon with no number is refused")
	assert_true(refused.has("stray"), "a number with no Flak keyword is refused")


## The cooldown (Ryan, 14 October; counted after the round of the spend since 12 November) and
## the limiter (15 October: no chain is free): a cooldown is a whole number of rounds, one or more,
## printed on the piece; Rapid's own switch-off is the keyword's, never printed (Ryan, 12 November:
## "rapid gets its innate cooldown zero back without the explicit display"), so a cold Rapid piece
## validates; an Instant entry that prints no cooldown pays heat, Volatile or a shield cost every
## spend; and an entry is Rapid or Instant, never both, its charged form included.
func test_a_cooldown_is_whole_rounds_and_every_instant_entry_carries_a_limiter() -> void:
	var db := _fresh()
	var base: Dictionary = _piece(db, "coolant_jacket")
	base["tier"] = 1
	var cases := {
		"test_rapid_cold": [{"keywords": ["rapid"]}, ""],
		"test_free": [{"keywords": ["instant"]}, "carries another limiter"],
		"test_hot": [{"keywords": ["instant"], "heat": 5}, ""],
		"test_bite": [{"keywords": ["instant"], "volatile": 3}, ""],
		"test_toll": [{"keywords": ["instant"], "shield_cost": 2}, ""],
		"test_switch": [{"keywords": ["instant"], "cooldown": 1}, ""],
		"test_both": [{"keywords": ["rapid", "instant"], "heat": 2}, "never both"],
		"test_both_charged": [{"keywords": ["rapid"], "charged": {"store": "rage", "price": 5, "keywords": ["instant"]}}, "never both"],
		"test_zero": [{"cooldown": 0}, "leaves it out"],
		"test_negative": [{"cooldown": -1}, "whole number of rounds"],
		"test_two": [{"cooldown": 2}, ""],
	}
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		var fields: Dictionary = cases[id][0]
		for k in fields:
			c["face"][k] = fields[k]
		db.components[id] = c
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused for '%s': %s" % [id, want, str(mine)])
	# Rapid's own switch-off is no printed cooldown: a Rapid entry counts none, whatever it pays.
	var hot: Dictionary = {"kind": "attack", "reach": "indirect", "power": 0, "keywords": ["lure", "rapid"], "heat": 1}
	assert_eq(db.build_face(hot).cooldown_rounds(), 0, "a Rapid entry prints no cooldown: its switch-off is the keyword's")
	# No shipped piece prints a cooldown of 1 to stand in for Rapid's own switch-off any more: a
	# Rapid piece that prints one sits out the next round too.
	var shipped := ContentDB.load_default()
	for cid in shipped.components.keys():
		var fd: Dictionary = shipped.components[cid].get("face", {})
		if Array(fd.get("keywords", [])).has("rapid"):
			assert_false(fd.has("cooldown"), "%s: Rapid's switch-off is its own, so a Rapid piece prints no cooldown today" % cid)


## A piece locked on a stepping die has the cylinder for its Instant's limiter (the Cassowary's
## Spin-Up, Ryan, 19 October; Instant since 12 November); anywhere else the same entry is refused,
## and a status a weapon spends (Spun Up) is granted with no rounds.
func test_a_stepping_die_is_its_locked_instant_pieces_limiter() -> void:
	var db := _fresh()
	assert_false(db.validate().any(func(e: String) -> bool: return e.begins_with("component spin_up")), "the Spin-Up validates where it is locked")
	assert_true(db.build_face(db.components["spin_up"]["face"]).has(Face.Keyword.INSTANT), "the Spin-Up is Instant")
	var loose: Dictionary = db.components["spin_up"].duplicate(true)
	loose["tier"] = 1
	db.components["test_loose_spin"] = loose
	var timed: Dictionary = db.components["spin_up"].duplicate(true)
	timed["tier"] = 1
	timed["face"]["rounds"] = 1
	timed["face"]["cooldown"] = 1
	db.components["test_timed_spin"] = timed
	var errs := db.validate()
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_loose_spin") and e.contains("carries another limiter")), "off the cylinder it needs a limiter of its own")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_timed_spin") and e.contains("no rounds")), "Spun Up takes no rounds")


## The drum's rewrite and the rank condition (the Cottonmouth's, 19 October): a rewrite says its
## number, reach and heat and never keys on reach; a rank condition says front or back.
func test_a_rewrite_says_its_shot_and_a_rank_condition_its_rank() -> void:
	var db := _fresh()
	var base: Dictionary = db.chassis["cottonmouth"].duplicate(true)
	base["passive"]["effects"] = [{"trigger": "static", "effect": "rewrite_weapon", "value": 15, "reach": "sideways", "heat": 10}]
	db.chassis["test_drum_bad"] = base
	var side: Dictionary = db.chassis["cottonmouth"].duplicate(true)
	side["passive"]["effects"] = [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "when": "target_rank", "rank": "middle"}]
	db.chassis["test_rank_bad"] = side
	var errs := db.validate()
	assert_true(errs.any(func(e: String) -> bool: return e.contains("test_drum_bad") and e.contains("rewrite_weapon fires every weapon and debuff as one shot")), "a rewrite with no reach is refused")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("test_rank_bad") and e.contains("target_rank needs rank")), "a rank that is neither is refused")


## A reach over every machine is never a vent's, the old reach key is a targeting mode's now (4
## November), and the Siphon's leavings are refused (12 November): a heat a blow on an entry (a
## passive's now) and the vent blast, an effect the engine no longer runs.
func test_a_vent_never_reaches_every_ally_and_the_siphons_leavings_are_refused() -> void:
	var db := _fresh()
	var plate: Dictionary = _piece(db, "coolant_jacket")
	plate["tier"] = 1
	plate["face"]["targets"] = "every_ally"
	plate["face"]["heat_per_blow"] = 2
	db.components["test_vent_all"] = plate
	var old: Dictionary = db.components["heliographic_death_ray"].duplicate(true)
	old["face"]["keywords"] = ["lure"]
	old["face"]["reaches_all"] = true
	db.components["test_old_reach"] = old
	var boiler: Dictionary = db.chassis["whip_scorpion"].duplicate(true)
	boiler["passive"]["effects"] = [{"trigger": "static", "effect": "vent_blast", "value": 1}]
	db.chassis["test_boiler"] = boiler
	var errs := db.validate()
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_vent_all") and e.contains("Every Ally and Every Other Ally are a shield's or a buff's")), "a vent never reaches every ally")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_old_reach") and e.contains("reaches_all is a targeting mode now")), "the old reach key is refused for the targeting mode")
	assert_true(errs.any(func(e: String) -> bool: return e.begins_with("component test_vent_all") and e.contains("heat_per_blow left the entry")), "a heat a blow on an entry is refused: a passive's now")
	assert_true(errs.any(func(e: String) -> bool: return e.contains("test_boiler") and e.contains("'vent_blast'") and e.contains("not implemented")), "and the vent blast, which the engine no longer runs")


## A promoted form (the bible's section 9): its entry holds what the class change adds and
## takes the rest from its hero as the content loads, a move of its own with one of its hero's
## ids taking that move's place; the validator holds it massive, a hero's, one to a hero, and
## a hero the run may deal needs one.
func test_a_promoted_form_takes_its_heros_kit_and_adds_its_own() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var fid := str(db.factions.keys()[0])
	db.foes["test_hero"] = {"id": "test_hero", "name": "The Tester", "faction": fid, "hero": true,
		"design": {"fantasy": "a test"}, "codex": "c", "flavour": "f", "hp": 70, "attack": 15, "rank": "back", "aim": "focus",
		"actions": [{"id": "jab", "name": "Jab", "kind": "attack", "weight": 2, "text": "", "status": "implemented"},
			{"id": "guard", "name": "Guard", "kind": "defend", "effect": "brace", "value": 5, "weight": 1, "text": "", "status": "implemented"}]}
	db.foes["test_hero_up"] = {"id": "test_hero_up", "promotes": "test_hero", "size": 2, "rank": "front", "armour": 5,
		"design": {"fantasy": "its class change"},
		"actions": [{"id": "guard", "name": "Guard", "kind": "defend", "effect": "brace", "value": 10, "weight": 1, "text": "", "status": "implemented"},
			{"id": "ready", "name": "Ready", "kind": "buff", "effect": "revive_once_ally", "weight": 1, "when": "ally_unready", "text": "", "status": "implemented"}]}
	db._resolve_promotions()
	var whole: Dictionary = db.foes["test_hero_up"]
	assert_eq(str(whole["name"]), "The Tester", "the same name, its hero's")
	assert_eq([int(whole["hp"]), int(whole["attack"]), str(whole["aim"]), str(whole["faction"])], [70, 15, "focus", fid], "its hero's numbers, sense and domain")
	assert_eq([int(whole["size"]), str(whole["rank"]), int(whole["armour"])], [2, "front", 5], "massive, front, armour 5: its own")
	assert_eq(whole["actions"].map(func(a): return str(a["id"])), ["jab", "guard", "ready"], "its hero's moves, then its own")
	assert_eq(int(whole["actions"][1]["value"]), 10, "a move of its own with a hero's id takes that move's place")
	assert_false(whole.has("hero"), "it is no hero itself")
	assert_eq(str(whole["design"]["fantasy"]), "its class change", "its design is its own")
	assert_eq(db.foes["test_hero"]["actions"].size(), 2, "the hero's own kit is untouched")
	assert_eq(db.promoted_form("test_hero"), "test_hero_up", "the hero finds its promoted form")
	var f := db.make_foe("test_hero_up")
	assert_true(f.hero and f.is_massive() and f.armour == 5, "made, it is one of the party, massive and armoured")
	assert_true(db.validate().is_empty(), "it validates: %s" % str(db.validate()))
	var refusals := func(word: String) -> bool:
		for e in db.validate():
			if e.contains(word):
				return true
		return false
	whole["size"] = 1
	assert_true(refusals.call("a promoted form is massive"), "a promoted form stands one slot high: refused")
	whole["size"] = 2
	db.foes["test_hero_up2"] = whole.duplicate(true)
	db.foes["test_hero_up2"]["id"] = "test_hero_up2"
	assert_true(refusals.call("a hero has one promoted form"), "a second class change for one hero: refused")
	db.foes.erase("test_hero_up2")
	whole["promotes"] = str(db.spawn_table(fid, 1)[0][0])
	assert_true(refusals.call("which is no hero"), "a class change of the rank and file: refused")
	whole["promotes"] = "test_hero"
	db.foes.erase("test_hero_up")
	db.factions[fid]["bench"] = Array(db.factions[fid].get("bench", [])) + ["test_hero"]
	assert_true(refusals.call("bench hero test_hero has no promoted form"), "a hero the run may deal without its class change: refused")


## A passive may break a rule as a one-off (the bible's section 7): the chassis's design names
## it, and the effect cap lifts by one for that passive alone (the first Kite's four effects).
func test_a_passive_one_off_lifts_the_effect_cap_by_one() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var cid := ""
	for id in db.chassis.keys():
		if db.chassis[id].get("passive", null) is Dictionary and not str(db.chassis[id].get("design", {}).get("one_off", "")).is_empty():
			continue
		cid = str(id)
		break
	var four := {"id": "test_four", "name": "Four", "description": "Four effects.", "effects": [
		{"trigger": "on_attack", "effect": "multiply_printed", "value": 2},
		{"trigger": "on_attack", "effect": "add_heat", "value": 10},
		{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 2},
		{"trigger": "on_kill", "effect": "stack_status", "value": "rage"}]}
	db.chassis[cid]["passive"] = four
	db.chassis[cid]["design"].erase("one_off")
	var capped := func() -> bool:
		for e in db.validate():
			if e.begins_with("chassis %s" % cid) and e.contains("passive has 4 effects"):
				return true
		return false
	assert_true(capped.call(), "four effects without a one-off: refused")
	db.chassis[cid]["design"]["one_off"] = "a test's reason"
	assert_false(capped.call(), "with the one-off named in its design, allowed")
	four["effects"].append({"trigger": "on_attack", "effect": "add_damage", "value": 1})
	assert_true(db.validate().any(func(e): return e.begins_with("chassis %s" % cid) and e.contains("passive has 5 effects")), "the lift is one, never more")


## Area by shape, numbered (Ryan, 28 October): a weapon's Spread or Penetrate says what each foe
## past its target takes; a debuff's says none; a piece may carry both, at one number or two
## (Splash, the two under one word, was cut on 15 November and is refused); Every Foe is a
## debuff's (2 November: a targeting mode given a keyword).
func test_the_area_keywords_say_their_number() -> void:
	var db := _fresh()
	var base: Dictionary = db.components["enfilade_beam"].duplicate(true)
	base["tier"] = 1
	base["face"]["keywords"] = []
	base["face"].erase("penetrate")
	var cases := {
		"test_spread_bare": [{"keywords": ["cleave"]}, "a weapon with Spread says what each foe past its target takes"],
		"test_spread_n": [{"keywords": ["cleave"], "cleave": 2}, ""],
		"test_stray_n": [{"penetrate": 2}, "rides with the Penetrate keyword"],
		"test_splash_n": [{"keywords": ["splash"]}, "splash"],
		"test_plus_one_number": [{"keywords": ["cleave", "penetrate"], "cleave": 2, "penetrate": 2}, ""],
		"test_plus_two_numbers": [{"keywords": ["cleave", "penetrate"], "cleave": 2, "penetrate": 1}, ""],
		"test_debuff_n": [{"power": 0, "keywords": ["lure", "cleave"], "cleave": 1}, "carries no number"],
		"test_debuff_area": [{"power": 0, "keywords": ["lure", "cleave"]}, ""],
		"test_wide_weapon": [{"reach": "every_foe"}, ""],
		"test_wide_area": [{"reach": "every_foe", "keywords": ["cleave"], "cleave": 2}, "lands on every foe already"],
		"test_wide_debuff": [{"power": 0, "reach": "every_foe", "keywords": ["lure"]}, ""],
		"test_wide_keyword": [{"power": 0, "keywords": ["lure", "every_foe"]}, "a targeting mode since 4 November"],
	}
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		for k in cases[id][0]:
			c["face"][k] = cases[id][0][k]
		db.components[id] = c
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])
	var f := db.build_face(db.components["test_plus_one_number"]["face"])
	assert_true(f.reaches_row() and f.reaches_column() and [f.cleave, f.penetrate] == [2, 2], "the plus builds as Spread and Penetrate, each with its number")
	var back := Face.from_dict(f.to_dict())
	assert_eq([back.cleave, back.penetrate], [2, 2], "and survives the round trip a save makes")
	assert_eq(Face.from_dict(db.build_face(db.components["test_debuff_area"]["face"]).to_dict()).to_dict().has("cleave"), false, "a debuff's area writes no number")
	for id in db.components.keys():
		var face: Dictionary = db.components[id].get("face", {})
		if id.begins_with("test_") or str(face.get("status", "")) == "planned":
			continue
		for name in ["cleave", "penetrate", "chain"]:
			if Array(face.get("keywords", [])).has(name) and not db.build_face(face).is_debuff():
				assert_true(int(face.get(name, 0)) > 0, "%s's %s carries its number" % [id, name])


## Chain is a weapon's keyword with a number (the conductor, Ryan, 28 October): the validator
## refuses it bare, its number without it, and on a debuff, whose arc would carry its riders to
## every conductor for no blow; the Arc Fault Cannon's Chain 2 validates and builds.
func test_chain_says_its_number_and_rides_a_weapon() -> void:
	var db := _fresh()
	var base: Dictionary = db.components["arc_fault_cannon"].duplicate(true)
	base["face"]["keywords"] = []
	base["face"].erase("chain")
	var cases := {
		"test_chain_bare": [{"keywords": ["chain"]}, "Chain says the number every other Shocked foe takes"],
		"test_chain_n": [{"keywords": ["chain"], "chain": 2}, ""],
		"test_chain_stray": [{"chain": 2}, "chain (the number) rides with the Chain keyword"],
		"test_chain_debuff": [{"power": 0, "keywords": ["chain"], "chain": 2}, "Chain is a weapon's keyword"],
	}
	for id in cases:
		var c: Dictionary = base.duplicate(true)
		for k in cases[id][0]:
			c["face"][k] = cases[id][0][k]
		db.components[id] = c
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component %s " % id) or e.begins_with("component %s:" % id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])
	var arc: Array = errs.filter(func(e: String) -> bool: return e.begins_with("component arc_fault_cannon"))
	assert_true(arc.is_empty(), "the Arc Fault Cannon validates: %s" % str(arc))
	var f := db.build_face(db.components["arc_fault_cannon"]["face"])
	assert_true(f.has(Face.Keyword.CHAIN) and f.chain == 2, "it builds with Chain 2")
	assert_eq(Face.from_dict(f.to_dict()).chain, 2, "and its number survives the round trip a save makes")
	assert_true(f.describe().contains("chain 2"), "the die's text says its number: %s" % f.describe())


## A grant of a numbered keyword may say its number, an area keyword's must (the drum's Spread 2
## and Penetrate 2, Ryan, 28 October); a keyword with no number takes none.
func test_a_numbered_keywords_grant_says_its_number() -> void:
	var db := _fresh()
	var base: Dictionary = db.modules["ram_frame"].duplicate(true)
	var cases := {
		"test_grant_spread": [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "number": 2}, ""],
		"test_grant_bare": [{"trigger": "static", "effect": "grant_keyword", "value": "penetrate"}, "says what each foe past the target takes"],
		"test_grant_odd": [{"trigger": "static", "effect": "grant_keyword", "value": "shock", "number": 2}, "a positive number for a numbered keyword"],
		"test_grant_conductor": [{"trigger": "static", "effect": "grant_keyword", "value": "chain", "number": 2}, ""],
		"test_grant_arc": [{"trigger": "static", "effect": "grant_keyword", "value": "chain"}, "says what every other Shocked foe takes"],
		"test_grant_none": [{"trigger": "static", "effect": "grant_keyword", "value": "cleave", "number": 0}, "a positive number for a numbered keyword"],
	}
	for id in cases:
		var m: Dictionary = base.duplicate(true)
		m["text"] = {"description": "A test.", "effects": [cases[id][0]]}
		db.modules[id] = m
	var errs := db.validate()
	for id in cases:
		var want: String = cases[id][1]
		var mine: Array = errs.filter(func(e: String) -> bool: return e.contains(id))
		if want.is_empty():
			assert_true(mine.is_empty(), "%s validates: %s" % [id, str(mine)])
		else:
			assert_true(mine.any(func(e: String) -> bool: return e.contains(want)), "%s is refused (%s): %s" % [id, want, str(mine)])


func test_the_map_and_the_vocabulary_agree_on_the_ground() -> void:
	# The walls named by what they are (Ryan, 29 October): every ground word the map shows has a
	# terrain entry in the vocabulary and every implemented terrain entry is one the map shows,
	# so a rename on either side fails the build; a domain's map lean names a shape.
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_eq(db.validate(), [], "the content as it stands agrees")
	for g in BattleMap.ground_ids():
		assert_eq(str(db.vocabulary.get(g, {}).get("category", "")), "terrain", "%s is a terrain term" % g)
	var towers: Dictionary = db.vocabulary["towers"]
	db.vocabulary.erase("towers")
	assert_true(db.validate().any(func(e) -> bool: return e.contains("ground 'towers'")), "a look with no term is reported")
	db.vocabulary["towers"] = towers
	db.vocabulary["mountain"] = {"category": "terrain", "name": "Mountain", "codex": "A wall.", "status": "implemented", "design": {"holes": ""}}
	assert_true(db.validate().any(func(e) -> bool: return e.contains("terrain 'mountain'")), "a terrain term the map never shows is reported")
	db.vocabulary.erase("mountain")
	var fid := str(db.factions.keys()[0])
	db.factions[fid]["map_kind"] = str(BattleMap.KINDS.keys()[0])
	assert_true(db.validate().any(func(e) -> bool: return e.begins_with("faction %s" % fid) and e.contains("names no map shape")), "a domain naming a map shape, even a real one, is reported (Ryan, 30 October)")


## Sweep is gone (Ryan, 12 November: "let's remove it"): the reach and the keyword are refused,
## a weapon may reach every foe, and no area keyword rides one that does. The slot mines' fields
## are gone (9 November) and refused.
func test_sweep_is_refused_and_a_weapon_may_reach_every_foe() -> void:
	var db := ContentDB.load_default()
	var swept: Array[String] = []
	db._validate_face("test", {"kind": "attack", "reach": "sweep", "power": 2, "strikes": 4, "keywords": []}, swept)
	assert_true(swept.any(func(e) -> bool: return e.contains("Sweep is gone")), "the reach is refused: %s" % str(swept))
	var every: Array[String] = []
	db._validate_face("test", {"kind": "attack", "reach": "every_foe", "power": 2, "keywords": []}, every)
	assert_eq(every, [], "a weapon over every foe validates")
	var wide: Array[String] = []
	db._validate_face("test", {"kind": "attack", "reach": "every_foe", "power": 2, "keywords": ["cleave"], "cleave": 1}, wide)
	assert_true(wide.any(func(e) -> bool: return e.contains("lands on every foe already")), "an area on it is refused")
	var gate: Array[String] = []
	db._validate_face("test", {"kind": "attack", "reach": "direct", "power": 2, "keywords": [], "magazine_min": 8}, gate)
	assert_true(gate.any(func(e) -> bool: return e.contains("magazine_min")), "a magazine's gate rides a piece that spends it")
	for gone in [{"pulls_mines": true}, {"drones": true}]:
		var errs: Array[String] = []
		var fd := {"kind": "attack", "reach": "indirect", "power": 0, "keywords": []}
		fd.merge(gone, true)
		db._validate_face("test", fd, errs)
		assert_true(errs.any(func(e) -> bool: return e.contains("are gone (9 November)")), "refused: %s" % str(gone))

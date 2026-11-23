extends TestCase

## The fodder's trial's stand-in packs (ContentDB.fodder_of; Ryan, 23 November: "All fodder safer
## to fight ... More fodder overall, with choices of pack sizes and pack types - bring back threat 2
## packs as fodder and not just hunters"): a formation come apart into packs for one machine and
## for two, drawn from its own foes by a budget of hit points. On synthetic foes, then swept over
## content so a new formation cannot deal a pack the rule would refuse.


## A line foe of 4, a back-rank foe of 3, a massive, a foe that leaves two halves as it falls and
## one a move of its raises once.
func _db() -> ContentDB:
	var db := ContentDB.new()
	db.foes = {
		"liner": {"name": "Liner", "faction": "f", "hp": 4, "attack": 4, "rank": "front", "actions": []},
		"caster": {"name": "Caster", "faction": "f", "hp": 3, "attack": 2, "rank": "back", "actions": []},
		"hulk": {"name": "Hulk", "faction": "f", "hp": 14, "attack": 6, "rank": "front", "size": 2, "actions": []},
		"splitter": {"name": "Splitter", "faction": "f", "hp": 4, "attack": 1, "rank": "front", "on_death": {"summon": "half", "count": 2}, "actions": []},
		"half": {"name": "Half", "faction": "f", "hp": 2, "attack": 1, "rank": "front", "actions": []},
		"riser": {"name": "Riser", "faction": "f", "hp": 5, "attack": 4, "rank": "front", "actions": [{"id": "rise", "kind": "buff", "effect": "revive_once", "status": "implemented"}]},
		"dreamer": {"name": "Dreamer", "faction": "f", "hp": 5, "attack": 4, "rank": "front", "actions": [{"id": "rise", "kind": "buff", "effect": "revive_once", "status": "planned"}]},
	}
	return db


func _formation(id: String, front: Array, back: Array) -> Dictionary:
	var cells: Array = []
	for row in [front, back]:
		for col in range(4):
			cells.append(str(row[col]) if col < row.size() else "")
	return {"id": id, "size": "formation", "faction": "f", "layout": cells, "members": []}


func _hp(db: ContentDB, members: Array) -> int:
	var hp := 0
	for m in members:
		hp += db.standing_hp(str(m[0])) * int(m[1])
	return hp


func _says(members: Array) -> String:
	var out: Array = []
	for m in members:
		out.append("%s*%d" % [str(m[0]), int(m[1])])
	return "+".join(out)


func test_a_foes_standing_hit_points_count_what_it_leaves_and_a_rise() -> void:
	var db := _db()
	assert_eq(db.standing_hp("liner"), 4, "a plain foe: its own")
	assert_eq(db.standing_hp("splitter"), 4 + 2 * 2, "one that leaves two halves as it falls: theirs with it")
	assert_eq(db.standing_hp("riser"), 8, "one a move of its raises once: half again, rounded up")
	assert_eq(db.standing_hp("dreamer"), 5, "a planned move raises nobody")
	assert_eq(db.standing_hp("nobody"), 0, "no such foe: nothing")


func test_a_grid_is_laid_from_a_packs_members_rank_by_rank() -> void:
	var db := _db()
	assert_eq(db.grid_of([["liner", 2], ["caster", 1]]), ["liner", "liner", "", "", "caster", "", "", ""], "the front rank from the left, the back rank behind it")
	assert_eq(db.grid_of([["caster", 2]]), ["", "", "", "", "caster", "caster", "", ""], "a pack of the back rank alone stands in the back cells")
	assert_eq(db.grid_of([["hulk", 1], ["liner", 1], ["caster", 2]]), ["hulk", "liner", "", "", "", "caster", "caster", ""], "nothing stands behind a massive foe")
	assert_eq(db.grid_of([["liner", 6]]), ["liner", "liner", "liner", "liner", "", "", "", ""], "and what four columns cannot hold is left out")


func test_a_formations_packs_are_drawn_from_its_own_foes_within_the_budget() -> void:
	var db := _db()
	var line := _formation("line", ["liner", "liner", "liner", "liner"], ["caster", "caster", "caster", "caster"])
	var ones: Array = db.fodder_candidates(line, 1).map(_says)
	ones.sort()
	assert_eq(ones, ["caster*2", "liner*1+caster*1", "liner*2"], "for one machine: two of the line, one with a caster behind it, or two casters")
	for pips in [1, 2]:
		var hi := int(ContentDB.FODDER_HP[pips - 1])
		var found := db.fodder_candidates(line, pips)
		assert_false(found.is_empty(), "the formation has packs for %d" % pips)
		for members in found:
			var hp := _hp(db, members)
			assert_true(hp <= hi and hp >= hi - ContentDB.FODDER_HP_SLACK, "%s is within the slack of the budget for %d (%d)" % [_says(members), pips, hp])
			var back := 0
			for m in members:
				back += int(m[1]) if str(m[0]) == "caster" else 0
			assert_true(back <= ContentDB.FODDER_BACK_RANK, "%s holds a back rank of two at most" % _says(members))
			assert_eq(str(members[0][0]) == "liner", members.any(func(m: Array) -> bool: return str(m[0]) == "liner"), "%s names its front rank first" % _says(members))
	var twos: Array = db.fodder_candidates(line, 2).map(_says)
	assert_true(twos.has("liner*3") and twos.has("liner*2+caster*1") and twos.has("liner*1+caster*2"), "for two: three heads of it, plain or mixed (%s)" % str(twos))
	# A massive foe sits the stand-in out, a splitter counts what it leaves, and a formation of
	# nothing the budget holds deals its heaviest draw under it.
	var grove := _formation("grove", ["hulk", "liner", "liner", "liner"], ["", "caster", "caster", ""])
	for pips in [1, 2]:
		for members in db.fodder_candidates(grove, pips):
			assert_false(members.any(func(m: Array) -> bool: return str(m[0]) == "hulk"), "no pack for %d holds the massive foe (%s)" % [pips, _says(members)])
	var wall := _formation("wall", ["splitter", "splitter", "splitter", ""], ["", "caster", "caster", ""])
	var wall_ones: Array = db.fodder_candidates(wall, 1).map(_says)
	assert_true(wall_ones.has("splitter*1") and not wall_ones.has("splitter*2"), "a splitter alone is a pack for one, two of it never (%s)" % str(wall_ones))
	var odd := _formation("odd", ["dreamer", "dreamer", "", ""], ["", "", "", ""])
	assert_eq(db.fodder_candidates(odd, 1).map(_says), ["dreamer*1"], "none in the band: the heaviest draw under the budget")
	var giants := _formation("giants", ["hulk", "hulk", "", ""], ["", "", "", ""])
	assert_true(db.fodder_candidates(giants, 1).is_empty() and db.fodder_of(giants, 0, 1, 0).is_empty(), "a formation of massives alone has no fodder: it comes as built")


func test_a_rating_comes_apart_into_ones_and_twos() -> void:
	assert_eq(ContentDB.fodder_splits(1), [[1]], "one pip: a pack for one")
	assert_eq(ContentDB.fodder_splits(2), [[1, 1], [2]], "two: two ones, or a two")
	assert_eq(ContentDB.fodder_splits(3), [[1, 1, 1], [1, 2], [2, 1]], "a formation's three: three ones, or a one and a two either way round")
	for split in ContentDB.fodder_splits(4):
		var sum := 0
		for part in split:
			sum += int(part)
		assert_eq(sum, 4, "every way adds up (%s)" % str(split))


func test_a_formation_as_fodder_keeps_its_pips_and_deals_by_the_seed() -> void:
	var db := _db()
	var line := _formation("line", ["liner", "liner", "liner", "liner"], ["caster", "caster", "caster", "caster"])
	var ways := {}
	for n in range(12):
		var packs := db.fodder_of(line, n, 7, 0)
		var pips := 0
		for p in packs:
			pips += ContentDB.squad_of(p)
			assert_true([1, 2].has(ContentDB.squad_of(p)), "a pack for one or for two")
			assert_eq([str(p["size"]), str(p["faction"]), str(p["id"])], ["patrol", "f", "line_fodder"], "a patrol of its formation's domain, named for it")
			assert_eq(str(p["lead"]), str(p["members"][0][0]), "led by its first member")
			var heads := 0
			for m in p["members"]:
				heads += int(m[1])
			assert_eq((p["layout"] as Array).filter(func(cell) -> bool: return not str(cell).is_empty()).size(), heads, "its grid stands every head")
			assert_eq((p["members"] as Array).size(), 1, "the tier's first battle: every pack one kind of foe")
			var sq := Battlefield.pack_of(p, "f")
			assert_eq([sq.squad, Battlefield.heads(sq)], [ContentDB.squad_of(p), heads], "and the field deals it at its rating, every head counted")
		assert_eq(pips, 3, "the formation's three pips, however it comes apart (deal %d)" % n)
		ways[packs.size()] = true
		assert_eq(db.fodder_of(line, n, 7, 0), packs, "the same deal of the same battle comes the same")
	assert_true(ways.has(2) and ways.has(3), "some deals three packs for one, some a one and a two")
	var other := false
	for n in range(12):
		other = other or db.fodder_of(line, n, 8, 0) != db.fodder_of(line, n, 7, 0)
	assert_true(other, "and another battle's seed deals another way")
	# The battle's place in its tier: no pack mixed at its first, every pack at its last.
	for n in range(6):
		for p in db.fodder_of(line, n, 7, 3):
			assert_true((p["members"] as Array).size() >= 2, "the tier's last battle: every pack brings a second kind (%s)" % _says(p["members"]))
	var mixed := [0, 0, 0, 0]
	for step in range(4):
		for n in range(6):
			for p in db.fodder_of(line, n, 7, step):
				mixed[step] += 1 if (p["members"] as Array).size() >= 2 else 0
	assert_true(mixed[0] == 0 and mixed[0] < mixed[1] and mixed[1] < mixed[2] and mixed[2] < mixed[3], "more of a formation's packs are mixed each battle into its tier (%s)" % str(mixed))


## Content's own formations, every tier: each comes apart into its pips or not at all, every pack
## within its budget, on a grid that stands every head, with no massive foe in it.
func test_every_formation_in_content_comes_apart_within_the_budget() -> void:
	var db := ContentDB.load_default()
	var dealt := 0
	for fid in db.factions.keys():
		for tier in [1, 2, 3]:
			for c in db.compositions(str(fid), tier, "formation"):
				for step in [0, 3]:
					for n in range(ContentDB.fodder_splits(ContentDB.squad_of(c)).size() * 2):
						var packs := db.fodder_of(c, n, 11, step)
						if packs.is_empty():
							continue
						dealt += 1
						var pips := 0
						for p in packs:
							pips += ContentDB.squad_of(p)
							var hp := 0
							var heads := 0
							for m in p["members"]:
								hp += db.standing_hp(str(m[0])) * int(m[1])
								heads += int(m[1])
								assert_true(int(db.foes[str(m[0])].get("size", 1)) < 2, "%s: no massive foe in a fodder pack (%s)" % [str(c["id"]), str(m[0])])
							assert_true(hp <= int(ContentDB.FODDER_HP[ContentDB.squad_of(p) - 1]), "%s: %s is within its budget (%d)" % [str(c["id"]), _says(p["members"]), hp])
							assert_eq((p["layout"] as Array).filter(func(cell) -> bool: return not str(cell).is_empty()).size(), heads, "%s: its grid stands every head (%s)" % [str(c["id"]), _says(p["members"])])
						assert_eq(pips, ContentDB.squad_of(c), "%s comes apart into its own rating" % str(c["id"]))
	assert_true(dealt > 0, "content's formations deal fodder")

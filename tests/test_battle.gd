extends TestCase

## The battle loop, headless (bible section 4, the round row): setup, the player's turn of
## moves and fights, the fights hunters force, the enemy's turn, and outcomes.


func _team() -> Array:
	var db := ContentDB.load_default()
	var out: Array = []
	for id in ["badger", "clydesdale", "kite"]:
		out.append(db.make_mech(id))
	return out


func _battle(seed_value: int = 3) -> Battle:
	var b := Battle.new(seed_value)
	b.setup(_team(), "marsh", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
	quiet_start(b)   # these tests read their own rules, not the opening's (TestCase.quiet_start)
	return b


## The Rupture's size as the rule has it (sized in beats, 11 November; on the tide's lists since
## the graded tide became the game's), worked out here apart from the battle's own sum: [the
## field's part before the pack left, the size, the packs the field's part counts]. Every pack
## counts at its threat rating, a pip a hundred. The field's part is what stands at the start and
## what the tide sends through the ramp's beats: at a peak every mouth's packs, the rift's and
## those of each tear open before it, the ramp's tears opening after; a send is worth the mean of
## the bands its mouth draws from, each band at the mean of the list its pack is taken from (its
## rating's, else the nearest that has any, a lighter before a heavier), an end's with its one in
## so many for two; and the hunting pack the rift sends every other peak from the second. The
## size leaves a pack for one machine and adds an elite's four pips for each the tier's Fractures
## call, and the pack bonus for every pack it counts, the one left aside and the elites with them.
func _rupture_size(b: Battle) -> Array:
	var pip := ContentDB.MENACE_PER_PIP
	var field_part := 0
	var packs := 0
	for sq in b.field.packs():
		if not sq.is_boss:
			field_part += sq.squad * pip
			packs += 1
	var worth := func(rating: int) -> int:
		for r in [rating, rating - 1, rating + 1, rating - 2, rating + 2]:
			var list: Array = b.field.graded.get(r, [])
			if list.is_empty():
				continue
			var sum := 0
			for c in list:
				sum += ContentDB.squad_of(c) * pip
			return sum / list.size()
		return 0
	var one: int = worth.call(1)
	var two: int = worth.call(2)
	var end := one + (two - one) / Battlefield.END_TWO_IN
	var rift_send := 0   # the mean of the wall's bands, the rift's to draw from
	for rating in Battlefield.BAND_RATING:
		rift_send += end if int(rating) == 1 else int(worth.call(int(rating)))
	rift_send /= Battlefield.BAND_RATING.size()
	var tear_send := (end + two) / 2   # a tear's: an end's band and the one beside it
	var sends := Battlefield.sends_a_peak()
	var tears := 0
	for j in range(Ramp.beats_at(b.tier)):
		field_part += sends * rift_send + tears * sends * tear_send
		packs += sends * (1 + tears)
		if j % 2 == 1 and not b.field.hunters.is_empty():
			field_part += ContentDB.squad_of(b.field.hunters[(j / 2) % b.field.hunters.size()]) * pip
			packs += 1
		tears += Ramp.tears_at(b.ramp)
	var elites: int = Ramp.elite_fractures_at(b.tier).size()
	var size := maxi(1, field_part - Battle.RUPTURE_LEAVE * one) + elites * 4 * pip
	size += Battle.pack_bonus() * (packs - Battle.RUPTURE_LEAVE + elites)
	return [field_part, size, packs]


## Park a pack beside a machine, rooted and pushing, so it can be attacked and does not hunt.
func _engage(b: Battle, sq: Unit, m: Unit) -> void:
	var spot := m.pos
	for n in Hex.neighbors(m.pos):
		if b.field.can_stand(sq, n):
			spot = n
			break
	sq.pos = spot
	sq.movespeed = 0
	if not sq.is_boss:
		sq.behaviour = "push"


## A pack parked three hexes from a machine, out of its range of two and inside its move's reach:
## an order onto it moves the machine first.
func _a_pack_in_reach(b: Battle, m: Unit) -> Unit:
	var sq: Unit = b.field.packs()[0]
	sq.behaviour = "push"
	for h in b.field.map.all_hexes():
		if Hex.distance(h, m.pos) == 3 and b.field.can_stand(sq, h):
			sq.pos = h
			if b.attack_hex(m, sq) != Battle.NO_HEX:
				return sq
	return null


## Every foe felled, round on round, until none stands or waits: each through the death check,
## so each is a kill (Skirmish.is_kill) or comes back to be felled again.
func _win(sk: Skirmish) -> void:
	sk.begin()
	sk.start_round()
	for i in range(20):
		for f in sk.field_foes():
			f.hp = 0
		sk.end_round()
		if sk.outcome != Skirmish.Outcome.NONE:
			return
		sk.start_round()


## The opening's form as the rules have it (Setup), worked out here apart from
## Battle.graded_opening: how many packs a battle stands before its wall at a Convergence. Two for
## one machine at each end, one for two before each band between, and before the middle the
## ramp's count for three.
func _opening_count(ramp: int) -> int:
	return 2 * 2 + 2 + Ramp.formations_at(ramp)


## The rating a band's pack is dealt at, as the lists stand: its own where the domain has a pack
## of it, else the nearest that has any, one lighter before one heavier.
func _dealt_rating(f: Battlefield, rating: int) -> int:
	for r in [rating, rating - 1, rating + 1, rating - 2, rating + 2]:
		if not (f.graded.get(r, []) as Array).is_empty():
			return r
	return -1


## The turns a pack takes to stand at the wall from where it is, as its walk shows it: this
## turn's walk and the stops after it; none for a pack already there or with no way.
func _turns_to_wall(f: Battlefield, sq: Unit) -> int:
	var w: Battlefield.Walk = f.plan_walks()[sq.id]
	return 0 if w.route.is_empty() else 1 + f.turn_ends(sq, w).size()


func test_setup_places_team_formation_and_boss() -> void:
	var b := Battle.new(3)
	b.setup(_team(), "marsh")
	assert_eq(b.mechs().size(), 3, "three mechs")
	var opening := Battle.graded_opening(0, b.map.width)
	assert_eq(opening.size(), _opening_count(0), "the opening's form: two packs at each end, one before each band between, the ramp's count before the middle")
	assert_eq(b.field.packs().size(), 1 + _opening_count(0), "the opening's packs at the start, plus the boss")
	assert_true(b.boss != null and b.field.units.has(b.boss), "boss on the field")
	# Its hex (Ryan, 10 November: "Put him on the single hex in front of the two new out of play
	# ones"): touching both of the rift's front hexes, on the rift's middle line.
	assert_eq(b.boss.pos, Battle.boss_home(b.map), "the boss on its hex")
	var fronts := 0
	for r in b.map.rift_hexes:
		if Hex.axial_to_offset(r).y == 1:
			fronts += 1
			assert_eq(Hex.distance(b.boss.pos, r), 1, "beside each of the rift's front hexes")
	assert_eq(fronts, 2, "the two of them")
	assert_true(is_equal_approx(Hex.to_pixel(b.boss.pos, 1.0).x, Hex.to_pixel(b.map.rift, 1.0).x), "on the rift's middle line")
	assert_eq(b.boss.foe_id, "", "boss unpacks by faction, not foe id")
	for u in b.field.units:
		assert_true(b.field.can_stand(u, u.pos), "%s stands on legal ground" % u.display_name)
	var gate_row := Hex.axial_to_offset(b.map.gate).y
	for m in b.mechs():
		assert_true(Hex.axial_to_offset(m.pos).y >= gate_row - 3, "%s starts by the gate" % m.display_name)
		assert_eq(b.actions_left(m), 1, "%s has its action" % m.display_name)
	# The opening (the rules' Setup): packs before every band of the wall, each of its band's
	# rating (the nearest the domain has where it has none of it), each its own moves from the
	# row before the wall and two or more, at its column, never in the rift's mouth, all pushing;
	# the boss by the rift; the rift a turn short.
	var walks := b.field.plan_walks()
	var stood := {}
	var k := 0
	for sq in b.field.packs():
		var o := Hex.axial_to_offset(sq.pos)
		if sq.is_boss:
			assert_true(o.y <= 2, "the boss starts by the rift")
			continue
		var e: Array = opening[k]
		k += 1
		var band := int(e[0])
		var moves := int(e[3])
		stood[band] = true
		assert_eq(int(e[1]), int(Battlefield.BAND_RATING[band]), "the form stands band %d its own rating" % band)
		assert_eq(sq.squad, _dealt_rating(b.field, int(e[1])), "%s before band %d is the pack dealt for its rating, %d" % [sq.display_name, band, int(e[1])])
		assert_eq(sq.behaviour, "push", "%s pushes: no hunter stands on the field at turn one" % sq.display_name)
		assert_true(moves >= 2, "two moves or more from the wall")
		assert_eq(o, Vector2i(int(e[2]), maxi(Battle.OPENING_FLOOR_ROW, b.field.apron_row() - moves * sq.movespeed)), "%s stands %d of its own moves from the wall, at its column" % [sq.display_name, moves])
		assert_eq(b.field.band_of(o.x), band, "before its own band")
		assert_eq(b.field.band_of(sq.goal_col), band, "and makes for it (column %d)" % sq.goal_col)
		assert_false(b.field.soonest_columns(sq).is_empty(), "on ground with a way to the wall")
		assert_false((walks[sq.id] as Battlefield.Walk).strikes, "%s strikes nothing on the first turn" % sq.display_name)
	assert_eq(stood.size(), Battlefield.BAND_RATING.size(), "a pack before every band of the wall")
	assert_eq(b.field.rift_pressure, b.field.rift_pressure_max - 1, "the rift a turn short of its peak")
	assert_eq(b.state, Battle.State.PLAN, "the player's turn")
	assert_true(b.forced.is_empty(), "the first turn opens on no forced fight")
	assert_eq(walks.size(), b.field.packs().size(), "every pack's walk shows")


## The field's trial (Ryan, 10 November: "I think the map is a bit too shallow ... If the map is a
## little deeper, and the seam starts a little farther out, it will feel more like I can actually
## plan a little bit ahead instead of panicking from the very start"): a trial depth is the
## field's depth, and the tears' row starts that much farther from the wall while its share's
## ceiling holds. The opening is measured from the wall, so depth alone leaves every pack its own
## moves from it and the first of them at the wall as soon; a trial of the opening stands every
## opening pack that many moves farther out, and the first is at the wall later. Nothing strikes
## on the first turn either way: the opening stands no pack that near.
func test_the_fields_trial_deepens_the_field_and_stands_the_opening_farther_out() -> void:
	var plain := Battle.new(3)
	plain.setup(_team(), "meadow")
	var depth := plain.map.height
	assert_eq(depth, Ramp.depth_at(0), "no trial: the ramp's own depth")
	Ramp.depth_trial = depth + 2
	var deep := Battle.new(3)
	deep.setup(_team(), "meadow")
	assert_eq(deep.map.height, depth + 2, "a trial depth is the field's")
	assert_eq(deep.map.width, plain.map.width, "the wall as long as it was")
	assert_eq(deep.field.apron_row() - deep.field.tear_row, plain.field.apron_row() - plain.field.tear_row + 2, "the tears' row starts two rows farther from the wall")
	# Over a few seeds (a shape may put a wall in a pack's way on one): on the deeper field every
	# pack still opens its own count of moves from the wall, so the first of them is at the wall
	# as soon as on the game's own depth; with the opening a move farther out each stands a move
	# farther (or on the floor row, where the field has no more room) and the first is at the
	# wall later.
	var seeds := [1, 2, 3, 4, 5, 6]
	var soonest := {}   # seed -> the turns the first pack takes to stand at the wall
	var soonest_shallow := {}   # the same on the game's own depth
	var rows := {}      # seed -> every opening pack's row
	for s in seeds:
		var shallow := Battle.new(s)   # the game's own depth, for the count of turns
		Ramp.depth_trial = 0
		shallow.setup(_team(), "meadow")
		Ramp.depth_trial = depth + 2
		var b := Battle.new(s)
		b.setup(_team(), "meadow")
		var opening := Battle.graded_opening(0, b.map.width)
		var pushers: Array = b.field.packs().filter(func(sq: Unit) -> bool: return not sq.is_boss)
		assert_eq(pushers.size(), opening.size(), "seed %d: the opening's packs" % s)
		var first := 1 << 20
		var first_shallow := 1 << 20
		rows[s] = []
		for i in range(pushers.size()):
			var sq: Unit = pushers[i]
			var moves := int(opening[i][3])
			var want := maxi(Battle.OPENING_FLOOR_ROW, b.field.apron_row() - moves * sq.movespeed)
			assert_true(absi(Hex.axial_to_offset(sq.pos).y - want) <= 1, "seed %d: %s still opens %d of its moves from the wall, however deep the field (within the row its landing found): row %d, wanted %d" % [s, sq.display_name, moves, Hex.axial_to_offset(sq.pos).y, want])
			(rows[s] as Array).append(Hex.axial_to_offset(sq.pos).y)
			first = mini(first, _turns_to_wall(b.field, sq))
		for sq in shallow.field.packs():
			if not sq.is_boss:
				first_shallow = mini(first_shallow, _turns_to_wall(shallow.field, sq))
		assert_true(first >= 2 and first_shallow >= 2, "seed %d: nothing strikes the wall in the enemy's first turn at either depth (the first pack is there in %d, and in %d on the game's own)" % [s, first, first_shallow])
		soonest[s] = first
		soonest_shallow[s] = first_shallow
	assert_eq(soonest.values().min(), soonest_shallow.values().min(), "the deeper field alone leaves the first pack at the wall as soon: the opening is measured from the wall (%s against %s)" % [str(soonest.values()), str(soonest_shallow.values())])
	Battle.opening_trial = 1
	var farther := 0
	for s in seeds:
		var far := Battle.new(s)
		far.setup(_team(), "meadow")
		var opening := Battle.graded_opening(0, far.map.width)
		var pushers: Array = far.field.packs().filter(func(sq: Unit) -> bool: return not sq.is_boss)
		assert_eq(pushers.size(), opening.size(), "seed %d: the opening's packs" % s)
		var first := 1 << 20
		for i in range(pushers.size()):
			var sq: Unit = pushers[i]
			var moves := int(opening[i][3]) + 1
			var want := maxi(Battle.OPENING_FLOOR_ROW, far.field.apron_row() - moves * sq.movespeed)
			var row := Hex.axial_to_offset(sq.pos).y
			assert_true(absi(row - want) <= 1, "seed %d: %s opens a move farther out (within the row its landing found): row %d, wanted %d" % [s, sq.display_name, row, want])
			assert_true(row <= int(rows[s][i]), "seed %d: %s never nearer the wall than the game stands it (row %d against %d)" % [s, sq.display_name, row, int(rows[s][i])])
			farther += int(rows[s][i]) - row
			first = mini(first, _turns_to_wall(far.field, sq))
		assert_true(first > int(soonest[s]), "seed %d: the opening a move farther out, the first pack is at the wall later (%d turns against %d)" % [s, first, int(soonest[s])])
		assert_true(far.forced.is_empty(), "seed %d: nor does the battle open on a forced fight" % s)
	assert_true(farther > 0, "and the packs stand farther from the wall in all (%d rows)" % farther)
	Ramp.depth_trial = 0
	Battle.opening_trial = 0
	var again := Battle.new(3)
	again.setup(_team(), "meadow")
	assert_eq(again.map.height, depth, "the trial off, the field is the game's again")


## No battle opens on a forced fight (Ryan, 6 November: "I probably would shy away from hitting
## the first battle with a fight in the first turn ... That's just mean"), and no hunter stands
## on the field at turn one (8 November: "no hunters should be on the field turn one, but that
## was a formation pass issue, I think"; built with the pass, 10 November): in every domain, at
## the foot of the ramp and at its top, at every tier, with a guest and without, the opening's
## packs all push, while the tier's hunting packs wait apart from the tide's lists, for the rift
## to send.
func test_no_battle_opens_on_a_forced_fight_and_no_hunter_stands_at_turn_one() -> void:
	var db := ContentDB.load_default()
	var hunting := 0
	var fids: Array = db.factions.keys()
	for fid in fids:
		for guest in ["", str(fids[(fids.find(fid) + 1) % fids.size()])]:
			for ramp in [0, 12]:
				for tier in [0, 1, 2]:
					for s in range(1, 5):
						var b := Battle.new(s)
						b.ramp = ramp
						b.tier = tier
						b.guest = guest
						b.setup(_team(), str(fid))
						var at := "%s, guest '%s', ramp %d, tier %d, seed %d" % [fid, guest, ramp, tier, s]
						assert_true(b.forced.is_empty(), "%s: no fight forced as the battle opens" % at)
						var opened := 0
						for sq in b.field.packs():
							if sq.is_boss:
								continue
							opened += 1
							assert_true(Hex.axial_to_offset(sq.pos).y >= Battle.OPENING_FLOOR_ROW, "%s opens off the rift's row" % sq.display_name)
							assert_true(sq.behaviour != "hunt", "%s: %s hunts and stands on the field at turn one" % [at, sq.display_name])
						assert_eq(opened, _opening_count(ramp), "%s: the opening stands every pack of its form" % at)
						for r in b.field.graded.keys():
							for c in b.field.graded[r]:
								assert_true(str(c.get("hunts", "")).is_empty(), "%s: %s hunts and stands in the tide's list for %d" % [at, str(c["id"]), int(r)])
						for c in b.field.hunters:
							assert_false(str(c.get("hunts", "")).is_empty(), "%s: %s waits among the hunting packs and pushes" % [at, str(c["id"])])
							hunting += 1
	assert_true(hunting > 0, "the content's hunters still come with the tide, so the rule is read")
	# A tier with no patrol that pushes opens whole all the same, and with no hunter: a band with
	# no pack of its rating is dealt the nearest rating that has any, so its formations stand
	# before the wall's ends too, and its hunting patrols wait for the rift like any other's.
	var own := ContentDB.new()
	own.load_dir(ContentDB.DIR)
	var fid0 := str(own.factions.keys()[0])
	var kept: Array = []
	for c in own.factions[fid0]["compositions"]:
		if (str(c.get("size", "")) != "patrol" or c.has("hunts")) and not c.has("tide"):
			kept.append(c)
	own.factions[fid0]["compositions"] = kept
	var hb := Battle.new(1)
	hb.db = own
	hb.setup(_team(), fid0)
	var listed: Array = tide_lists(hb.field).filter(func(c) -> bool: return str(c.get("hunts", "")).is_empty())
	assert_true(not listed.is_empty() and listed.all(func(c) -> bool: return str(c["size"]) == "formation"), "with no patrol that pushes, the tide's lists hold the formations alone")
	assert_false(hb.field.hunters.is_empty(), "and its hunting patrols wait apart")
	var stood := 0
	for sq in hb.field.packs():
		if sq.is_boss:
			continue
		stood += 1
		assert_eq([sq.composition_size, sq.behaviour], ["formation", "push"], "%s, a formation, stands where a lighter pack would: no hunter opens" % sq.display_name)
	assert_eq(stood, _opening_count(0), "the opening drops no pack for want of its rating")
	assert_true(hb.forced.is_empty(), "nor opens on a forced fight")


## The field's size is the ramp's (the long wall brief 3.1): a battle that names none takes
## Ramp.wall_length_at and Ramp.depth_at; at any size the gate stands centred on the wall, the
## wall spans the width, the rift is three hexes at the top centre, and four machines stand on
## the row before the gate's apron.
func test_the_field_takes_the_ramps_size_and_keeps_its_shape_at_any_size() -> void:
	var b := Battle.new(3)
	b.with_boss = false
	b.map_kind = "steppe"
	b.setup(_four_synthetic(), "marsh")
	assert_eq([b.map.width, b.map.height], [Ramp.wall_length_at(0), Ramp.depth_at(0)], "a battle that names no size takes the ramp's")
	for size in [[20, 12], [30, 10]]:
		var w: int = size[0]
		var h: int = size[1]
		var c := Battle.new(5)
		c.with_boss = false
		c.map_kind = "steppe"
		c.setup(_four_synthetic(), "marsh", w, h)
		var at := "at %dx%d" % [w, h]
		assert_eq([c.map.width, c.map.height], [w, h], "the size passed " + at)
		assert_eq(Hex.axial_to_offset(c.map.gate), Vector2i(w / 2, h - 1), "the gate centred on the wall " + at)
		var walled := true
		for row in range(h - BattleMap.GATE_ROWS, h):
			for col in range(w):
				walled = walled and c.map.is_structure(Hex.offset_to_axial(col, row))
		assert_true(walled, "the gate and the wall span the width in the bottom two rows " + at)
		# The rift's five hexes (10 November): three at the top centre, and the two of the next
		# row that touch its middle.
		var rift_cols: Array = []
		var front := 0
		for rh in c.map.rift_hexes:
			var o := Hex.axial_to_offset(rh)
			if o.y == 0:
				rift_cols.append(o.x)
			else:
				front += 1
				assert_eq(o.y, 1, "the rift's front hexes on the next row " + at)
				assert_eq(Hex.distance(rh, c.map.rift), 1, "each beside its middle " + at)
		rift_cols.sort()
		assert_eq(rift_cols, [w / 2 - 1, w / 2, w / 2 + 1], "the rift three hexes at the top centre " + at)
		assert_eq(front, 2, "and two in front of them " + at)
		assert_eq(c.mechs().size(), 4, "four machines " + at)
		for m in c.mechs():
			assert_eq(Hex.axial_to_offset(m.pos).y, c.field.apron_row(), "%s on the row before the gate's apron %s" % [m.display_name, at])


func _four_synthetic() -> Array:
	var out: Array = []
	for n in range(4):
		out.append(Unit.mech(n + 1, "M%d" % (n + 1), Vector2i.ZERO, 3))
	return out


## Every pack carries its threat rating, the machines it is intended for (the long wall brief
## 3.7; Ryan, 6 November: a formation a three, a patrol a one, an elite and a boss a true four):
## by its composition's size, or its own where the composition writes one; a pack of no
## composition three; the boss's unit four; the fight's roster carries it and a save keeps it.
func test_every_pack_carries_its_threat_rating() -> void:
	var b := _battle()
	var cases := [["patrol", 0, 1], ["formation", 0, 3], ["elite", 0, 4], ["escort", 0, 4], ["patrol", 2, 2], ["formation", 4, 4]]
	var dealt: Array = []
	for cs in cases:
		var c := Battlefield.composition([["revenant", 2]], "marsh", str(cs[0]), "probe")
		if int(cs[1]) > 0:
			c["squad"] = int(cs[1])
		var sq := b.field.emerge(c, Hex.offset_to_axial(2, 3))
		assert_eq(sq.squad, int(cs[2]), "a %s%s is a fight for %d" % [str(cs[0]), (" that writes %d" % int(cs[1])) if int(cs[1]) > 0 else "", int(cs[2])])
		dealt.append(sq)
	assert_eq(b.boss.squad, 4, "the boss's unit is a true four")
	assert_eq(int(b.roster(dealt[1])["squad"]), 3, "the fight's roster carries its pack's")
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	for sq in dealt:
		assert_eq(back.field.unit_by_id(sq.id).squad, sq.squad, "a save keeps it")
	var h := Battle.new(3)
	h.formation = [["revenant", 3], ["ghost", 2]]
	h.with_boss = false
	h.setup(_team(), "marsh")
	for p in h.field.packs():
		assert_eq(p.squad, ContentDB.SQUAD_DEFAULT, "a pack of no composition is a fight for three")
	assert_eq(h.field.graded.keys(), [ContentDB.SQUAD_DEFAULT], "and the tide's one list is theirs, for three")
	var composed := h.field.packs().size()
	h.field.peak()
	var after: Array = h.field.packs().slice(composed)
	assert_eq(after.size(), Battlefield.sends_a_peak(), "the rift sends from it")
	for p: Unit in after:
		assert_eq(p.squad, ContentDB.SQUAD_DEFAULT, "and so are the ones the rift sends after, whichever band each makes for (band %d)" % h.field.band_of(p.goal_col))


## A composition is its grid (8 November): the pack on the map is what the grid holds, the lead
## first among its members; its fight, holding it alone, stands the foes as the grid has them, an
## empty cell empty and nothing waiting; a grid that names nothing is dropped and the members
## stand heaviest first (the harness's hand-made packs).
func test_a_grid_is_dealt_as_the_pack_and_places_its_fight() -> void:
	var b := _battle()
	var c := Battlefield.composition([["revenant", 2], ["ghost", 2]], "marsh", "formation", "probe")
	c["lead"] = "ghost"
	c["layout"] = ["", "revenant", "revenant", "", "ghost", "", "", "ghost"]
	var sq := b.field.emerge(c, Hex.offset_to_axial(2, 3))
	assert_eq(sq.foe_id, "ghost", "the pack wears its lead")
	assert_eq(sq.member_list(), [["ghost", 2], ["revenant", 2]], "first among its members, the counts the grid's")
	assert_eq(sq.layout, c["layout"], "the grid dealt as it emerged")
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(back.field.unit_by_id(sq.id).layout, c["layout"], "a save keeps it")
	var m: Unit = b.mechs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	assert_eq(sk.layout, c["layout"], "the fight on the one pack takes its grid")
	sk.begin()
	for cell in range(8):
		var f := sk.foe_at(0 if cell < 4 else 1, cell % 4)
		if str(c["layout"][cell]).is_empty():
			assert_true(f == null, "cell %d stands empty" % cell)
		else:
			assert_true(f != null and f.content_id == str(c["layout"][cell]), "cell %d holds its %s" % [cell, c["layout"][cell]])
	assert_true(sk.reinforcements.is_empty(), "nothing waits: no reinforcement inside a fight")
	# Content's compositions come dealt with their grid: a formation of the content stands as written.
	var db := ContentDB.load_default()
	var form: Dictionary = db.compositions("meadow", 1, "formation")[0]
	assert_eq(form["layout"].size(), 8, "eight cells")
	var counted := {}
	for cell in form["layout"]:
		if not str(cell).is_empty() and not db.is_part(str(cell)):
			counted[str(cell)] = int(counted.get(str(cell), 0)) + 1
	for mm in form["members"]:
		assert_eq(int(mm[1]), int(counted[str(mm[0])]), "%s: the members read off the grid" % mm[0])
	var dealt := b.field.emerge(form, Hex.offset_to_axial(5, 3))
	assert_eq(dealt.member_list(), form["members"], "and the pack is the grid")
	# A grid that names nothing is dropped: the members stand as given, heaviest first.
	var blank := Battlefield.composition([["revenant", 2], ["ghost", 1]], "marsh", "formation", "blank")
	blank["layout"] = ["", "", "", "", "", "", "", ""]
	var sq2 := b.field.emerge(blank, Hex.offset_to_axial(4, 3))
	assert_eq(sq2.strength, 3, "every member kept")
	assert_true(sq2.layout.is_empty(), "and the fight deploys them heaviest first")


func test_a_composed_formation_replaces_the_spawn_list_and_the_boss_can_stay_home() -> void:
	var db := ContentDB.load_default()
	var facs: Array = db.factions.keys()
	var a := str(db.spawn_foes(str(facs[0]), 1)[0])
	var c := str(db.spawn_foes(str(facs[1]), 1)[0])
	var b := Battle.new(3)
	b.formation = [[a, 2], [c, 5], [a, 1]]
	b.with_boss = false
	b.setup(_team(), str(facs[0]))
	assert_true(b.boss == null, "no boss")
	var placed: Array = []
	for sq in b.field.packs():
		assert_false(sq.is_boss, "%s is no boss" % sq.display_name)
		placed.append([sq.foe_id, sq.strength, sq.faction])
	assert_eq(placed, [[a, 2, str(facs[0])], [c, 5, str(facs[1])], [a, 1, str(facs[0])]], "the packs as composed, each under its own foe's faction")
	# The tide's one list is the composed side, which every band draws from: the mouths send its
	# packs in turn from the first, the rift's and then a tear's, each under its own faction.
	assert_eq(b.field.graded.keys(), [ContentDB.SQUAD_DEFAULT], "one list, of packs of no composition")
	var listed: Array = (b.field.graded[ContentDB.SQUAD_DEFAULT] as Array).map(func(comp) -> Array: return [str(comp["members"][0][0]), int(comp["members"][0][1]), str(comp["faction"])])
	assert_eq(listed, placed, "the packs as composed, in their order")
	assert_true(b.field.hunters.is_empty(), "and no hunting pack beside them")
	for peak in range(2):
		b.field.rift_pressure = b.field.rift_pressure_max - 1
		assert_true(b.field.tick_pressure(1), "a peak")
	var sent: Array = b.field.packs().slice(placed.size())
	assert_eq(sent.size(), Battlefield.sends_a_peak() * (2 + Ramp.tears_at(0)), "two peaks: the rift's packs twice and the first tear's once")
	for k in range(sent.size()):
		var spawned: Unit = sent[k]
		assert_eq([spawned.foe_id, spawned.strength, spawned.faction], placed[k % placed.size()], "pack %d the mouths send is the list's next in turn, under its own faction" % k)
	b.forced = []
	b.field.gate_hp = 0
	b.end_turn()
	assert_eq(b.outcome, Battle.Outcome.GATE_FALLEN, "without a boss only the field ends it")


## A pack as a composition (the foes' fresh start, 30 October): one hex, one sprite (its lead's),
## every member unpacked into the fight, the survivors kept by member, pushing unless a composition
## says it hunts (8 November), its pace the slowest, winged only when every member is, and a pack
## a fight has worn paying the share of its rating its strike has lost (11 November).
func test_a_composition_unpacks_its_members_and_keeps_its_survivors_by_member() -> void:
	var b := _battle()
	var db := b.db
	var host := Unit.pack(0, "the host", Vector2i.ZERO, "marsh", Unit.PACK_MOVE, 0, "")
	host.set_members([["revenant", 3], ["ghost", 2]])
	assert_eq(host.foe_id, "revenant", "its foe type is the lead's")
	assert_eq(host.strength, 5, "its strength is the count of every member")
	b.field.add_unit(b.field.dress_pack(host))
	assert_eq(host.movespeed, mini(int(db.foes["revenant"].get("movespeed", 2)), int(db.foes["ghost"].get("movespeed", 2))), "its pace the slowest")
	assert_eq(host.behaviour, "push", "a pack of no composition pushes: only a composition says it hunts")
	assert_false(host.traits.has("winged"), "winged only when every member is: the revenants walk")
	var wisps := Unit.pack(0, "wisps", Vector2i.ZERO, "marsh", Unit.PACK_MOVE, 0, "")
	wisps.set_members([["ghost", 2]])
	b.field.dress_pack(wisps)
	assert_eq(wisps.traits.has("winged"), bool(db.foes["ghost"].get("winged", false)), "a composition of winged members is winged")
	var types := {}
	for f in db.foes_for(host):
		types[f.content_id] = int(types.get(f.content_id, 0)) + 1
	assert_eq(types, {"revenant": 3, "ghost": 2}, "every member unpacks, by type")
	# A fight that kills two revenants and a ghost: the pack keeps the rest by member.
	var m: Unit = b.mechs()[0]
	_engage(b, host, m)
	var sk := b.attack(host, [m])
	assert_true(sk != null, "the fight opens")
	sk.begin()
	sk.start_round()
	var fell := {"revenant": 0, "ghost": 0}
	for f in sk.field_foes():
		if f.pack_id == host.id and fell.has(f.content_id) and int(fell[f.content_id]) < (2 if f.content_id == "revenant" else 1):
			f.hp = 0
			fell[f.content_id] = int(fell[f.content_id]) + 1
	for f in sk.reinforcements:
		if f.pack_id == host.id and fell.has(f.content_id) and int(fell[f.content_id]) < (2 if f.content_id == "revenant" else 1):
			f.hp = 0
			fell[f.content_id] = int(fell[f.content_id]) + 1
	assert_eq(fell, {"revenant": 2, "ghost": 1}, "three of its own fall")
	sk.reinforcements = sk.reinforcements.filter(func(f) -> bool: return f.alive())
	sk.end_round()
	assert_eq(sk.kills_by_type(host), {"revenant": 2, "ghost": 1}, "the kills by type")
	assert_eq(sk.kills_for(host), 3, "and in all")
	assert_eq(sk.members_left(host), [["revenant", 1], ["ghost", 1]], "the members left, in the pack's order")
	var before := b.menace_killed
	b.finish_skirmish()
	assert_eq(host.members, [["revenant", 1], ["ghost", 1]], "the map keeps the survivors by member")
	assert_eq(host.strength, 2, "and the badge their count")
	assert_eq(b.foes_killed, 3, "the battle counts the kills")
	var paid := b.menace_killed - before
	assert_eq(paid, (ContentDB.worth_of(host.squad) * 3) / 5, "three of its five heads gone: three fifths of its rating's worth")
	assert_eq(ContentDB.worth_of(host.squad) - paid, Battlefield.strike_of(host) * ContentDB.MENACE_PER_PIP / Battlefield.STRIKE_PER_PIP, "what it has yet to pay is what it still strikes the wall for")


## The field at the start follows the tier and the ramp (the pacing session, 30 October): the
## timer the ramp's; the tide's lists the tier's pushing packs of the lead and the guest that the
## ramp's gate holds, each by its rating and the two domains in turn, the lead's first, their
## hunting patrols apart; and before the wall the opening's form at the ramp, the ramp's count of
## packs before the middle, each pack its list's next as content writes it.
func test_the_field_at_the_start_follows_the_tier_and_the_ramp() -> void:
	var db := ContentDB.load_default()
	var mid := Battlefield.BAND_RATING.size() / 2
	for r in [0, 6, 12]:
		var b := Battle.new(5)
		b.tier = 1
		b.ramp = r
		b.guest = "waste"
		b.setup(_team(), "meadow")
		var f := b.field
		assert_eq(f.rift_pressure_max, Ramp.timer_at(r), "ramp %d: the timer" % r)
		# The lists: both domains' tier-two packs the gate holds, by rating, in turn.
		var mine := tide_packs(db, "meadow", 2, r)
		var theirs := tide_packs(db, "waste", 2, r)
		var ratings: Array = f.graded.keys()
		ratings.sort()
		assert_true(ratings.has(1) and ratings.has(3), "ramp %d: packs for one and for three at the least (%s)" % [r, str(ratings)])
		for rating in ratings:
			var ids: Array = (f.graded[rating] as Array).map(func(c) -> String: return str(c["id"]))
			assert_eq(ids, in_turn(mine.get(rating, []), theirs.get(rating, [])), "ramp %d: the packs for %d, the lead's and the guest's in turn, the lead's first" % [r, int(rating)])
			for c in f.graded[rating]:
				assert_eq([ContentDB.squad_of(c), str(c.get("hunts", ""))], [int(rating), ""], "ramp %d: %s is a pack for %d that pushes" % [r, str(c["id"]), int(rating)])
		for rating in mine.keys() + theirs.keys():
			assert_true(ratings.has(rating), "ramp %d: a list for every rating either domain has a pack for (%d)" % [r, int(rating)])
		assert_false(f.hunters.is_empty(), "ramp %d: the hunting packs stand apart" % r)
		for c in f.hunters:
			assert_true(str(c["size"]) == "patrol" and not str(c.get("hunts", "")).is_empty(), "ramp %d: %s is a patrol that hunts" % [r, str(c["id"])])
		# The opening: its form at the ramp, each pack a tier-two composition as content writes it.
		var opened: Array = f.packs().filter(func(sq: Unit) -> bool: return not sq.is_boss)
		assert_eq(opened.size(), _opening_count(r), "ramp %d: the opening's count of packs" % r)
		var by_band := {}
		for sq: Unit in opened:
			var band := f.band_of(sq.goal_col)
			by_band[band] = int(by_band.get(band, 0)) + 1
			assert_eq(sq.squad, _dealt_rating(f, int(Battlefield.BAND_RATING[band])), "ramp %d: %s before band %d is the pack dealt for its rating" % [r, sq.composition, band])
			var comp: Dictionary = {}
			for c in db.compositions(sq.faction, 2, sq.composition_size) + db.compositions(sq.faction, 2, sq.composition_size, -1, ContentDB.GRADED):
				if str(c["id"]) == sq.composition:
					comp = c
			assert_false(comp.is_empty(), "ramp %d: %s is a tier-two composition of its domain" % [r, sq.composition])
			assert_true(ContentDB.ramp_holds(comp, r), "ramp %d: one its gate deals at this Convergence (%s)" % [r, sq.composition])
			for k in range(comp["members"].size()):
				assert_eq(sq.members[k], [str(comp["members"][k][0]), int(comp["members"][k][1])], "ramp %d: %s's member %d as content writes it, at any ramp (7 November)" % [r, sq.composition, k])
		for band in range(Battlefield.BAND_RATING.size()):
			var want := Ramp.formations_at(r) if band == mid else (1 if int(Battlefield.BAND_RATING[band]) == 2 else 2)
			assert_eq(int(by_band.get(band, 0)), want, "ramp %d: the packs making for band %d" % [r, band])
		assert_eq(opening_off_lists(b), "", "ramp %d: each pack the opening stands is its list's next, the lead's or the guest's as it comes" % r)
		assert_true(opened.any(func(sq: Unit) -> bool: return sq.faction == "waste") and opened.any(func(sq: Unit) -> bool: return sq.faction == "meadow"), "ramp %d: so both domains stand before the wall" % r)


## The Rupture meter (the pacing session, 30 October; sized in beats, 11 November): the last
## threshold the opening and the tide through the ramp's beats, a pack for one machine left, an
## elite's rating for the tier's elite, and the pack bonus of every pack it counts; a Fracture
## pays out as a fight ends, the elite the tier names spawning at the rift; the last breaks the
## seal; a sealed boss cannot be ordered onto and joins no fight.
func test_the_meter_fills_by_menace_and_the_fractures_pay_out_as_fights_end() -> void:
	var b := _battle()   # the Marsh at tier 0: three Fractures, the Reaper at the first
	var db := b.db
	assert_eq(b.thresholds.size(), Ramp.fractures_at(0), "the tier's count of Fractures")
	var size := _rupture_size(b)
	assert_true(b.field_menace > 0, "the field's part weighs something")
	assert_eq(b.field_menace, int(size[0]), "the field's part: the opening and the tide through the ramp's beats")
	assert_eq(int(b.thresholds[b.thresholds.size() - 1]), int(size[1]), "the Rupture: that, a pack for one machine left, four pips for the tier's elite, and the pack bonus of every pack counted")
	assert_eq(Ramp.beats_at(0), Ramp.BEATS, "on the game's own beats")
	assert_true(int(size[2]) > _opening_count(0), "the tide's packs counted with the opening's (%d)" % int(size[2]))
	for k in range(1, b.thresholds.size()):
		assert_true(int(b.thresholds[k]) - int(b.thresholds[k - 1]) >= int(b.thresholds[k - 1]) - (int(b.thresholds[k - 2]) if k >= 2 else 0), "later Fractures cost more (%s)" % str(b.thresholds))
	assert_true(b.is_sealed() and b.boss.sealed, "the boss is sealed while there is a field to earn the Rupture against")
	assert_false(b.can_target(b.boss), "a sealed boss cannot be ordered onto")
	assert_true(b.roster(b.boss).is_empty(), "nor fought")
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	for n in Hex.neighbors(b.boss.pos):   # a pack beside the boss, inside its ring
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	_engage(b, sq, m)
	var r := b.roster(sq)
	assert_false((r["joins"] as Array).has(b.boss), "a sealed boss's ring is inert: it joins no fight")
	assert_false(bool(r["all_in"]), "so the fight is an ordinary one")
	# The tally stood a pack's worth short of the first Fracture by hand, then that pack killed
	# outright: its fall carries the meter over the threshold as the fight ends.
	var worth := ContentDB.worth_of(sq.squad)
	var short := int(b.thresholds[0]) - worth
	assert_true(short > 0, "the first Fracture costs more than one pack (%d against %d)" % [int(b.thresholds[0]), worth])
	b.menace_killed = short
	b._fractures()
	assert_eq(b.fractures, 0, "no Fracture under the first threshold")
	var sk := b.attack(sq, [m])
	_win(sk)
	b.finish_skirmish()
	assert_eq(b.menace_killed, short + worth, "the tally counts the pack's fall at its threat rating's worth")
	assert_eq(b.meter(), short + worth + Battle.pack_bonus(), "and the meter the pack bonus over it")
	assert_eq(b.fractures, 1, "a Fracture is earned as the fight ends, once the meter crosses its threshold")
	assert_eq(b.elites_spawned, [str(db.elite_compositions("marsh", 1)[0]["id"])], "and the Marsh's first own elite emerges at it (the roll at this seed is above the wanderers' chance)")
	var elite: Unit = b.field.packs()[b.field.packs().size() - 1]
	assert_eq(elite.composition_size, "elite", "an elite composition")
	assert_true(db.is_elite(elite.foe_id), "led by its elite")
	assert_true(Hex.distance(elite.pos, b.map.rift) <= 3, "at the rift")
	assert_true(b.is_sealed(), "the seal holds short of the Rupture")
	# The tally carried over the last threshold by hand: the Rupture.
	b.menace_killed = int(b.thresholds[b.thresholds.size() - 1])
	b._fractures()
	assert_eq(b.fractures, b.thresholds.size(), "every Fracture earned")
	assert_false(b.is_sealed(), "the Rupture: the seal breaks")
	assert_eq(b.rupture_turn, b.field.phase, "the turn it broke")
	assert_true(b.can_target(b.boss), "the boss can be fought now")
	assert_true(bool(b.roster(b.boss).get("all_in", false)), "and its fight takes every machine")


## The Rupture's beats on trial (Ryan, 11 November: "Try your lean first", two beats): the dial
## moves how many peaks of the tide the field's part runs through, one or three beside the
## game's two, and nothing else, the Fractures' count, their growing steps and the elite's part
## as they were; and a battle under way keeps the thresholds it opened on.
func test_the_beats_trial_moves_the_fields_part_and_nothing_else() -> void:
	var two := _battle()
	var own := _rupture_size(two)
	assert_eq(int(two.thresholds[-1]), int(own[1]), "the game's own: two beats")
	# What the size holds past the field's part and the bonus of the packs that part counts: the
	# elite's part, with its bonus, less the pack left with its own. Read before the dial moves.
	var over := int(two.thresholds[-1]) - int(own[0]) - Battle.pack_bonus() * int(own[2])
	var sizes := {}
	for beats in [1, 3]:
		Ramp.beats_trial = beats
		var b := _battle()   # the same seed, so the same field
		var size := _rupture_size(b)
		assert_eq(b.field_menace, int(size[0]), "%d beats: the opening and the tide through that many peaks" % beats)
		assert_eq(int(b.thresholds[-1]), int(size[1]), "and the Rupture with it")
		assert_eq(b.thresholds.size(), two.thresholds.size(), "the tier's count of Fractures stands")
		assert_true((int(size[2]) - int(own[2])) * (beats - Ramp.BEATS) > 0, "the packs counted follow the beats (%d against %d)" % [int(size[2]), int(own[2])])
		assert_eq(int(b.thresholds[-1]) - int(size[0]) - Battle.pack_bonus() * int(size[2]), over, "the elite's part and the pack left are the tier's, whatever the beats")
		for k in range(1, b.thresholds.size()):
			assert_true(int(b.thresholds[k]) - int(b.thresholds[k - 1]) >= int(b.thresholds[k - 1]) - (int(b.thresholds[k - 2]) if k >= 2 else 0), "later Fractures still cost more (%s)" % str(b.thresholds))
		sizes[beats] = int(b.thresholds[-1])
		if beats == 3:
			# A battle under way keeps what it opened on: the save carries the thresholds.
			Ramp.beats_trial = 0
			var back := SaveGame.from_dict(SaveGame.to_dict(b))
			assert_eq(back.thresholds, b.thresholds, "a saved battle keeps the thresholds it opened on, whatever the dial says since")
	assert_true(int(sizes[1]) < int(two.thresholds[-1]) and int(two.thresholds[-1]) < int(sizes[3]), "a beat more is a bigger Rupture (%s, %d)" % [str(sizes), int(two.thresholds[-1])])
	Ramp.beats_trial = 0


## The strike's dial (Ryan, 11 November, of more packs: "even if it means that each needs to do
## less to the wall"; 23 November: "Reduce foe damage to the wall so that quantity matters"): what
## a pip of threat rating strikes the wall for.
func test_the_strikes_trial_sets_what_a_pip_strikes_the_wall_for() -> void:
	var own := _battle()
	var sq0: Unit = own.field.packs()[0]
	var rating := clampi(sq0.squad, 1, 4)
	assert_eq(Battlefield.strike_per_pip(), Battlefield.STRIKE_PER_PIP, "no trial: the game's own strike a pip")
	assert_eq(Battlefield.strike_of(sq0), rating * Battlefield.STRIKE_PER_PIP, "and a pack strikes by it")
	var tried := 2 * Battlefield.STRIKE_PER_PIP
	Battlefield.strike_trial = tried
	assert_eq(Battlefield.strike_of(sq0), rating * tried, "the strike's trial: twice the game's a pip")
	Battlefield.strike_trial = 0
	assert_eq(Battlefield.strike_of(sq0), rating * Battlefield.STRIKE_PER_PIP, "and the game's own again")


## Menace is a pack's threat rating (Ryan, 11 November: "Maybe just 1-2-3-4 for now to keep math
## simple ... It gives us an absolute unbiased benchmark"): a pack's fall pays its rating's
## worth, a pip a hundred, whoever is in it, so every elite pays four and the meter is the
## tally; a pack a fight has worn has paid the share its strike has lost, the fall makes it
## whole, once; and a save carries the books.
func test_menace_is_a_packs_threat_rating_whoever_is_in_it() -> void:
	Battle.pack_bonus_trial = 0   # the pack bonus set aside: the meter here is the tally alone (its own test reads the bonus)
	var db := ContentDB.load_default()
	var pip := ContentDB.MENACE_PER_PIP
	assert_eq([ContentDB.worth_of(1), ContentDB.worth_of(2), ContentDB.worth_of(3), ContentDB.worth_of(4)], [pip, 2 * pip, 3 * pip, 4 * pip], "one, two, three, four")
	var falls: Array = []
	var weights: Array = []
	for c in db.compositions("marsh", 1, "elite"):   # its own and the wanderers its list holds
		var b := _battle()
		var m: Unit = b.mechs()[0]
		var sq := b.field.emerge(c, b.map.rift)
		assert_true(sq != null and sq.composition_size == "elite", "the elite's pack on the field (%s)" % str(c["id"]))
		_engage(b, sq, m)
		_win(b.attack(sq, [m]))
		b.finish_skirmish()
		assert_false(b.field.units.has(sq), "the pack is gone")
		assert_eq(b.menace_killed, 4 * pip, "an elite's fall is four pips (%s)" % str(c["id"]))
		assert_eq(b.meter(), b.menace_killed, "and with no pack bonus the meter is the tally")
		assert_true(b.pack_paid.is_empty(), "nothing of the pack is left on the books")
		falls.append(b.menace_killed)
		weights.append(db.composition_weight(c))
	assert_true(falls.size() >= 2 and falls.min() == falls.max(), "every elite paid the same (%s)" % str(falls))
	assert_true(weights.min() != weights.max(), "whatever their own numbers add up to (%s)" % str(weights))
	# A pack worn over two fights: the share its strike has lost, then the rest at its fall.
	var w := _battle()
	var m1: Unit = w.mechs()[0]
	var m2: Unit = w.mechs()[1]
	var m3: Unit = w.mechs()[2]
	var sqw: Unit = w.field.packs()[0]
	var worth := ContentDB.worth_of(sqw.squad)
	var full := sqw.full_strength
	assert_true(full >= 2 and full == Battlefield.heads(sqw), "it took the field with its heads (%d)" % full)
	_engage(w, sqw, m1)
	var sk := w.attack(sqw, [m1])
	sk.begin()
	sk.start_round()
	for f in sk.field_foes():
		if f.pack_id == sqw.id:
			f.hp = 0
			break
	sk.end_round()
	w.finish_skirmish()
	var gone := full - Battlefield.heads(sqw)
	assert_true(gone >= 1 and w.field.units.has(sqw), "a head of it gone, the pack standing")
	assert_eq(w.menace_killed, (worth * gone) / full, "it has paid the share of its rating its heads gone are")
	assert_eq(int(w.pack_paid.get(sqw.id, 0)), w.menace_killed, "and the books say so")
	var back := SaveGame.from_dict(SaveGame.to_dict(w))
	assert_eq([back.menace_killed, int(back.pack_paid.get(sqw.id, 0)), back.meter()], [w.menace_killed, w.menace_killed, w.meter()], "a save keeps the tally, the books and the meter")
	# A fight that fells none of it pays nothing.
	var paid := w.menace_killed
	_engage(w, sqw, m2)
	var idle := w.attack(sqw, [m2])
	idle.begin()
	idle.start_round()
	idle.end_round()
	w.finish_skirmish()
	assert_eq(w.menace_killed, paid, "a fight that fells none of it pays nothing")
	_engage(w, sqw, m3)
	_win(w.attack(sqw, [m3]))
	w.finish_skirmish()
	assert_false(w.field.units.has(sqw), "the pack falls")
	assert_eq(w.menace_killed, worth, "and its fall makes its rating whole, once")
	assert_true(w.pack_paid.is_empty(), "the books clear")
	Battle.pack_bonus_trial = -1


## The thresholds read the tide (the long wall brief 3.8; in beats since 11 November): the menace
## placed at the start and what the rift and the tears send through the ramp's beats, pack for
## pack, each send at the mean of the bands its mouth draws from, so no draw moves a threshold;
## and the Rupture quickens the tide, the beat halving once, never sealing again.
func test_the_thresholds_read_the_first_waves_and_the_rupture_halves_the_beat() -> void:
	var b := Battle.new(3)
	b.ramp = 5
	b.setup(_team(), "marsh")
	var placed := 0
	var opened := 0
	for sq in b.field.packs():
		if not sq.is_boss:
			placed += ContentDB.worth_of(sq.squad)
			opened += 1
	var size := _rupture_size(b)
	assert_true(int(size[0]) > placed, "the tide's beats weigh something past the opening")
	assert_eq(b.field_menace, int(size[0]), "the field's part: the opening and the tide through the beats")
	# No draw moves a threshold: another seed's battle stands other packs of its lists before
	# the wall and draws other bands at its peaks, and opens on the same thresholds.
	var stood := func(battle: Battle) -> Array: return battle.field.packs().filter(func(sq: Unit) -> bool: return not sq.is_boss).map(func(sq: Unit) -> String: return sq.composition)
	var other_openings := 0
	for s in [1, 2, 4, 5, 6, 7]:
		var other := Battle.new(s)
		other.ramp = 5
		other.setup(_team(), "marsh")
		assert_eq([other.field_menace, other.thresholds], [b.field_menace, b.thresholds], "seed %d: the same field's part and the same thresholds" % s)
		if stood.call(other) != stood.call(b):
			other_openings += 1
	assert_true(other_openings > 0, "though the seeds stood different packs (%d of six)" % other_openings)
	# The tide as the field then sends it: pack for pack what the size counted, peak by peak,
	# each worth what its band's rating made it, where the size read the mean.
	var sent := 0
	var seen: Array = b.field.packs().duplicate()
	for j in range(Ramp.beats_at(b.tier)):
		b.field.peak()
		for sq in b.field.packs():
			if not seen.has(sq):
				seen.append(sq)
				sent += 1
	assert_eq(sent, int(size[2]) - opened, "and the mouths send through those peaks the packs it counted")
	assert_eq([b.field.rift_spawns, b.field.tear_spawns], [Battlefield.sends_a_peak() * Ramp.beats_at(b.tier) + (Ramp.beats_at(b.tier) / 2 if not b.field.hunters.is_empty() else 0), sent - b.field.rift_spawns], "the rift's at every peak, a tear's from the peak after it opens")
	b.field.rift_pressure_max = 3
	b.rupture()
	assert_false(b.is_sealed(), "the Rupture")
	assert_eq(b.field.rift_pressure_max, 1, "the beat halves, three to one")
	assert_true("\n".join(b.field.log).contains("the rift convulses: the beat is now 1"), "the log says so")
	b.rupture()
	assert_eq(b.field.rift_pressure_max, 1, "once: nothing re-seals and nothing halves it again")
	var c := Battle.new(3)
	c.setup(_team(), "marsh")
	c.field.rift_pressure_max = 1
	c.rupture()
	assert_eq(c.field.rift_pressure_max, 1, "never below one")


## A field cleared is its own reward (Ryan, 11 November: "a clear field is its own reward, it's
## breathing room to reposition or get loot"): with the seal standing and no pack but the boss's
## on the field, nothing breaks the seal and nothing is hurried; the tide comes on its beat.
## The stall guard of 30 October broke the seal there.
func test_a_field_cleared_leaves_the_seal_standing_until_the_tide_returns() -> void:
	var b := _battle()
	b.thresholds = [100000, 200000, 300000]   # out of reach by the meter
	assert_true(b.is_sealed(), "sealed")
	for sq in b.field.packs().duplicate():
		if not sq.is_boss:
			b.field.units.erase(sq)   # the field cleared by hand
	var m: Unit = b.mechs()[0]
	var sq := b.field.add_unit(b.field.dress_pack(Unit.pack(0, "the last pack", Vector2i.ZERO, "marsh", Unit.PACK_MOVE, 2, "revenant")))
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	_win(sk)
	b.finish_skirmish()
	assert_true(b.field.packs().filter(func(p: Unit) -> bool: return not p.is_boss).is_empty(), "the field is clear")
	assert_true(b.is_sealed(), "and the seal stands")
	assert_eq([b.fractures, b.rupture_turn], [0, -1], "no Fracture, no Rupture")
	assert_false(b.can_target(b.boss), "the boss still cannot be ordered onto")
	assert_eq(b.state, Battle.State.PLAN, "the battle goes on")
	# The tide returns on its beat: the pressure fills as before and the peak sends the next wave.
	var pressure_before := b.field.rift_pressure
	b.field.rift_pressure_max = 2
	b.end_turn()
	assert_true(b.field.rift_pressure == pressure_before + 1 or b.field.peaks > 0, "a clear turn is a turn of the clock, no more")
	for i in range(3):
		if b.state == Battle.State.PLAN:
			b.end_turn()
	assert_true(b.field.peaks >= 1, "the peak comes on its beat")
	assert_false(b.field.packs().filter(func(p: Unit) -> bool: return not p.is_boss).is_empty(), "and the field has packs again")
	assert_true(b.is_sealed(), "the seal still the meter's to break")


func test_route_to_reaches_every_reachable_hex() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[1]
	var dests := b.field.reachable(m)
	assert_true(dests.size() > 0, "somewhere to go")
	for h in dests.keys():
		var route := b.field.route_to(m, h)
		assert_true(not route.is_empty(), "route to %s" % str(h))
		assert_eq(route[route.size() - 1], h, "route ends at the hex")
		var prev := m.pos
		var cost := 0
		for step in route:
			assert_true(Hex.are_adjacent(prev, step), "steps are adjacent")
			cost += BattleMap.spend(b.map.terrain[step], m.traits, m.movespeed - cost)
			prev = step
		assert_eq(cost, dests[h], "route cost matches the reachable cost")
	assert_true(b.field.route_to(m, m.pos).is_empty(), "no route to itself")


## A move is given in one go (Ryan, 28 October): one move an action, the whole of it, so a
## machine that moved short of its move cannot move again until a fight spends the action.
## A move is laid a waypoint at a time (Ryan, 22 November: "If points remain, re-draw reachable
## hexes from the waypoint ... until movement points are emptied"): each leg spends its cost, the
## reach is read from the leg's end with what is left, and once the move is spent nothing is lit.
func test_a_move_is_laid_in_waypoints_until_it_is_spent() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	assert_true(b.move_to(m, b.map.rift).is_empty(), "the rift is out of reach")
	var near := Vector2i(-99, -99)
	for h in b.destinations_for(m).keys():
		if int(b.destinations_for(m)[h]) == 1:
			near = h
			break
	assert_true(near != Vector2i(-99, -99), "a hex a step away")
	var route := b.move_to(m, near)
	assert_false(route.is_empty(), "the first waypoint is laid")
	assert_eq(m.pos, near, "it is there at once")
	assert_eq(b.move_left(m), m.movespeed - 1, "its step off the move")
	assert_true(b.can_move(m), "so it may lay another")
	assert_eq(b.waypoints(m), [near] as Array[Vector2i], "one waypoint")
	for h in b.destinations_for(m).keys():
		assert_true(Hex.distance(h, near) <= b.move_left(m), "the reach is read from the waypoint with what is left")
	while b.can_move(m):
		var next: Vector2i = b.destinations_for(m).keys()[0]
		assert_false(b.move_to(m, next).is_empty(), "another waypoint")
	assert_eq(b.move_left(m), 0, "until the move is spent")
	assert_true(b.destinations_for(m).is_empty(), "nothing is lit")
	assert_eq(b.plan_pieces().size(), b.waypoints(m).size(), "a leg a waypoint")
	assert_eq(b.actions_left(m), 1, "a move spends no action: it may still fight")
	assert_true(b.pending(m), "the plan in hand")


## A previous waypoint takes back every step after it; a cancel takes the whole plan and its
## steps off the undo; an execute plays it as one step, and its undo puts the plan back as it was
## (Ryan, 22 November).
func test_waypoints_are_cut_back_cancelled_and_executed() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var start := m.pos
	var steps := 0
	while b.can_move(m) and b.waypoints(m).size() < 3:
		b.move_to(m, b.destinations_for(m).keys()[0])
		steps += 1
	assert_true(steps >= 2, "two waypoints at least")
	var wps := b.waypoints(m)
	assert_eq(b.history.size(), wps.size(), "a step a waypoint")
	assert_true(b.back_to_waypoint(m, 1), "cut back to the first")
	assert_eq(b.waypoints(m), [wps[0]] as Array[Vector2i], "only it left")
	assert_eq(m.pos, wps[0], "the machine there")
	assert_eq(b.history.size(), 1, "the later steps off the undo")
	assert_true(b.cancel(m), "cancelled")
	assert_eq(m.pos, start, "back where it stood")
	assert_false(b.pending(m), "nothing in hand")
	assert_false(b.can_undo(), "and nothing on the undo")
	b.move_to(m, b.destinations_for(m).keys()[0])
	var at := m.pos
	var played := b.execute(m)
	assert_eq(played.size(), 1, "the execute hands over its leg")
	assert_false(b.pending(m), "nothing left to play")
	assert_eq(b.actions_left(m), 0, "no order stood: its action is over")
	assert_eq(b.history.size(), 2, "the execute a step of its own")
	assert_eq(b.undo(), m, "its undo is about the machine")
	assert_true(b.pending(m), "the plan back in hand, to play again")
	assert_eq(b.waypoints(m), [at] as Array[Vector2i], "its waypoint as it was")
	assert_eq(b.shown_positions()[m.id][0], start, "shown where it stood")
	assert_eq(b.actions_left(m), 1, "its action whole")


## An order onto a pack, then its execute: the order stands as given, the machine played.
func test_an_executed_order_stands() -> void:
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var pack := _a_pack_in_reach(b, a)
	assert_true(pack != null, "a pack the machine can reach this turn")
	assert_eq(b.order_onto(a, pack), "ordered", "ordered, moving into range")
	assert_eq(b.order_onto(a, pack), "ordered", "a second order onto it changes nothing")
	assert_eq(b.history.size(), 1, "one step")
	assert_true(b.pending(a), "in hand")
	b.execute(a)
	assert_true(b.played.has(a.id), "played")
	assert_eq(b.order_of(a), pack, "its order kept")
	assert_false(b.can_move(a), "it moves no more")
	assert_false(b.cancel(a), "and no cancel takes a played move back")


func test_undo_puts_a_machine_back_with_its_whole_move() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var start := m.pos
	var facing := m.facing
	assert_false(b.can_undo(), "nothing to undo")
	var h: Vector2i = b.destinations_for(m).keys()[0]
	b.move_to(m, h)
	assert_true(b.can_undo(), "the move can be taken back")
	assert_eq(b.undo(), m, "undone, and the machine it was about handed back")
	assert_eq(m.pos, start, "back where it was")
	assert_eq(m.facing, facing, "facing as it was")
	assert_true(b.can_move(m), "its whole move again")
	assert_false(b.moved.has(m.id), "unmoved")
	assert_false(b.can_undo(), "and nothing more to undo")
	assert_true(b.planned.is_empty(), "nor any plan")


## The undo runs in the order things were done, whoever did them (Ryan, 25 October: "the undo
## stack is stored in order, and undos in order, always"), orders included, and an order with
## its move into range is one step.
func test_undo_takes_back_moves_and_orders_in_the_order_they_were_made() -> void:
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var a0 := a.pos
	var c0 := c.pos
	var ha: Vector2i = b.destinations_for(a).keys()[0]
	b.move_to(a, ha)
	var hc: Vector2i = Vector2i(-99, -99)
	for h in b.destinations_for(c).keys():
		if h != ha:
			hc = h
			break
	b.move_to(c, hc)
	assert_eq(b.undo(), c, "the last move first, the second machine's")
	assert_eq([a.pos, c.pos], [ha, c0], "the first still where it went")
	assert_eq(b.undo(), a, "then the first")
	assert_eq(a.pos, a0, "back")
	# An order and its move into range: one step.
	var pack := _a_pack_in_reach(b, a)
	assert_true(pack != null, "a pack the machine can reach this turn")
	assert_eq(b.order_onto(a, pack), "ordered", "ordered, moving into range")
	assert_eq(b.order_of(a), pack, "on that pack")
	assert_eq(b.history.size(), 1, "one step on the undo")
	b.undo()
	assert_eq(b.order_of(a), null, "the order taken back")
	assert_eq(a.pos, a0, "and the move with it")
	assert_true(b.can_undo() == false, "nothing more")


## A move is planned on the map (Ryan, 25 October: shown, then played on ENGAGE or END TURN):
## the battle has the machine at its route's end, and the plan says where it stands until then.
func test_a_move_is_planned_and_handed_over_once() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var start := m.pos
	var facing := m.facing
	var h: Vector2i = b.destinations_for(m).keys()[0]
	var route := b.move_to(m, h)
	assert_eq(m.pos, h, "the battle has it at the route's end")
	assert_eq(b.shown_positions(), {m.id: [start, facing]}, "the map shows it where it stood")
	var pieces := b.plan_pieces()
	assert_eq(pieces.size(), 1, "one piece")
	assert_eq(pieces[0]["path"], route, "along its route")
	var phases := BattleMapView.plan_phases(pieces)
	assert_eq(phases.size(), 1, "played in one phase")
	assert_eq((phases[0][0][1] as Array).size(), route.size() + 1, "from where it stood")
	var saved := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(saved.shown_positions(), {m.id: [start, facing]}, "a save keeps the plan")
	assert_true(saved.can_undo(), "and the undo")
	saved.undo()
	assert_eq(saved.field.unit_by_id(m.id).pos, start, "which still takes the move back")
	assert_eq(b.take_plan().size(), 1, "the plan handed to the screen")
	assert_true(b.shown_positions().is_empty(), "and gone from the battle")
	assert_true(b.can_undo(), "the move can still be taken back until a fight or the turn's end")


## A plan played mid turn stays played (Ryan, 2 November: "Movement should be able to be executed
## in sequence if the player wants, and undone"): an undo after EXECUTE puts each machine back
## where it stood, in the order made, and plans nothing to play a second time, a save between too.
func test_a_plan_played_mid_turn_undoes_to_where_each_machine_stood() -> void:
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var a0 := a.pos
	var c0 := c.pos
	var ha: Vector2i = b.destinations_for(a).keys()[0]
	b.move_to(a, ha)
	var hc := Vector2i(-99, -99)
	for h in b.destinations_for(c).keys():
		if h != ha:
			hc = h
			break
	b.move_to(c, hc)
	assert_eq(b.take_plan().size(), 2, "both moves handed to the screen to play")
	for snap in b.history:
		assert_true((snap["planned"] as Array).is_empty(), "and no step on the undo plans either again")
	var saved := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(b.undo(), c, "the last move first")
	assert_eq([a.pos, c.pos], [ha, c0], "the second machine back where it stood, the first where it went")
	assert_true(b.planned.is_empty() and b.shown_positions().is_empty(), "with nothing planned to play again")
	assert_true(b.can_move(c), "and its move whole")
	assert_eq(b.undo(), a, "then the first")
	assert_eq(a.pos, a0, "back where it stood")
	assert_true(b.planned.is_empty(), "nothing planned")
	assert_false(b.can_undo(), "back to the turn's start")
	b.move_to(a, ha)
	assert_eq(b.plan_pieces().size(), 1, "a move after it is planned as any is")
	assert_eq(b.plan_pieces()[0]["from"], a0, "from where the machine stands")
	saved.undo()
	assert_eq(saved.field.unit_by_id(c.id).pos, c0, "the save's undo sets the machine back the same")
	assert_true(saved.planned.is_empty(), "and plans nothing")


## A move that plays ends its machine's action unless an order stands (Ryan, 16 November: "if an
## attack wasn't ordered, it cannot attack. What is allowed, is plotting a path, THEN selecting an
## attack in range. Once execute is run, the action is forfeit (barring undo, of course)"): no
## reach, no order, nothing left to do, until an UNDO takes the move back.
func test_a_move_played_with_no_order_ends_the_action() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var start := m.pos
	var sq := _a_pack_in_reach(b, m)
	assert_true(sq != null, "a pack the machine can move into range of")
	var h := b.attack_hex(m, sq)
	b.move_to(m, h)
	assert_false(b.threat_for(m).is_empty(), "a planned move: its attack can still be ordered from the route's end")
	assert_true(b.still_to_act().has(m), "so it still has something to do")
	assert_eq(b.take_plan().size(), 1, "the move plays (EXECUTE)")
	assert_eq(b.actions_left(m), 0, "and its action is over")
	assert_true(b.threat_for(m).is_empty(), "no reach for a fight")
	assert_false(b.order(m, sq), "no order, the pack beside it or not")
	assert_eq(b.order_onto(m, sq), "refused", "nor a tap onto it")
	assert_false(b.still_to_act().has(m), "nothing left for it to do")
	var saved := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(saved.actions_left(saved.field.unit_by_id(m.id)), 0, "a save keeps it spent")
	assert_eq(b.undo(), m, "UNDO takes the move back")
	assert_eq(m.pos, start, "back where it stood")
	assert_eq(b.actions_left(m), 1, "its action whole again")
	assert_true(b.can_move(m), "its move to give")
	saved.undo()
	assert_eq(saved.actions_left(saved.field.unit_by_id(m.id)), 1, "the save's undo gives it back the same")


## Plotting a path and then ordering an attack in range is the action (Ryan, 16 November): the
## order stands once the move has played, as given, the machine fighting it at ENGAGE; it takes no
## other order, and taking it back then ends the action.
func test_a_path_then_an_order_stands_once_the_move_plays() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq := _a_pack_in_reach(b, m)
	assert_true(sq != null, "a pack the machine can move into range of")
	b.move_to(m, b.attack_hex(m, sq))
	assert_true(b.order(m, sq), "the attack ordered from the route's end")
	b.take_plan()
	assert_true(b.played.has(m.id), "the move played")
	assert_eq(b.order_of(m), sq, "the order standing")
	assert_eq(b.actions_left(m), 1, "its action still to spend")
	assert_true(b.threat_for(m).is_empty(), "no reach for another order")
	var other: Unit = null
	for p in b.field.packs():
		if p != sq and not p.is_boss:
			other = p
			break
	_engage(b, other, m)
	assert_false(b.order(m, other), "no other order, a pack beside it or not")
	assert_eq(b.order_of(m), sq, "the first stands")
	assert_false(b.still_to_act().has(m), "nothing more to give it")
	var saved := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_true(saved.played.has(m.id), "a save keeps it played")
	assert_true((b.next_fight()["machines"] as Array).has(m), "it fights at ENGAGE")
	b.cancel_order(m)
	assert_eq(b.actions_left(m), 0, "taken back once its move has played, its action is over")
	assert_false(b.played.has(m.id), "nothing standing")


## EXECUTE plays every planned move at once: an UNDO of the last takes back that machine's move and
## gives its action back, and leaves the others played and spent; an UNDO past each gives each back.
func test_an_undo_after_execute_gives_back_only_the_moves_it_takes_back() -> void:
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var a0 := a.pos
	var ha: Vector2i = b.destinations_for(a).keys()[0]
	b.move_to(a, ha)
	var hc := Vector2i(-99, -99)
	for h in b.destinations_for(c).keys():
		if h != ha:
			hc = h
			break
	b.move_to(c, hc)
	b.take_plan()
	assert_eq([b.actions_left(a), b.actions_left(c)], [0, 0], "both actions over")
	assert_eq(b.undo(), c, "the last move taken back")
	assert_eq(b.actions_left(c), 1, "its action back")
	assert_eq(a.pos, ha, "the first still where it went")
	assert_eq(b.actions_left(a), 0, "and still spent: its move played")
	assert_true(b.threat_for(a).is_empty(), "no fight for it")
	assert_eq(b.undo(), a, "then the first")
	assert_eq([a.pos, b.actions_left(a)], [a0, 1], "back where it stood, its action whole")


## A second action (a synthetic passive's, as the Dingo's Retrograde Flywheel grants one): a move
## played with no order spends the first, and the second moves again.
func test_a_move_played_spends_one_action_of_two() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	m.grant_passive({"id": "twin", "name": "Twin", "description": "", "effects": [{"trigger": "static", "effect": "extra_action", "value": 1}]}, "twin")
	b.spent.clear()
	var h: Vector2i = b.destinations_for(m).keys()[0]
	b.move_to(m, h)
	b.take_plan()
	assert_eq(b.actions_left(m), 1, "one action left")
	assert_false(b.moved.has(m.id), "its second action's move unspent")
	assert_false(b.destinations_for(m).is_empty(), "it moves again")


## A piece planned into the room another piece made waits for it to play.
func test_a_move_into_a_hex_another_left_plays_after_it() -> void:
	var a := {"unit": 1, "from": Vector2i(2, 2), "facing": 0, "path": [Vector2i(3, 2)] as Array[Vector2i], "to_facing": 0, "riders": []}
	var c := {"unit": 2, "from": Vector2i(1, 2), "facing": 0, "path": [Vector2i(2, 2)] as Array[Vector2i], "to_facing": 0, "riders": []}
	var d := {"unit": 3, "from": Vector2i(5, 5), "facing": 0, "path": [Vector2i(5, 6)] as Array[Vector2i], "to_facing": 0, "riders": []}
	var again := {"unit": 1, "from": Vector2i(3, 2), "facing": 0, "path": [Vector2i(4, 2)] as Array[Vector2i], "to_facing": 0, "riders": []}
	var phases := BattleMapView.plan_phases([a, c, d, again])
	assert_eq(phases.size(), 2, "two phases")
	assert_eq(phases[0].map(func(mv): return mv[0]), [1, 3], "the first move and the one beside nobody together")
	assert_eq(phases[1].map(func(mv): return mv[0]), [2, 1], "the move into the hex it left after it, and its own second piece")


## Nothing left on the map but the button (Ryan, 25 October: END TURN pulses "when all units are
## out of actions"): every machine fought out, ordered, or with no move and nothing in reach.
func test_nothing_is_left_once_every_machine_has_done_what_it_can() -> void:
	var b := _battle()
	assert_false(b.nothing_left(), "a fresh turn: everyone can move")
	assert_eq(b.still_to_act().size(), b.mechs().size(), "every machine still to act, for END TURN's question")
	for m in b.mechs():
		b.spent[m.id] = 1
	assert_true(b.nothing_left(), "every action spent")
	assert_true(b.still_to_act().is_empty(), "and nobody left to ask about")
	b.spent.clear()
	for m in b.mechs():
		b.moved[m.id] = true
		b.move_used[m.id] = m.movespeed   # every move spent
	var a: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, a)
	assert_false(b.nothing_left(), "every machine moved, but a pack in reach of the first")
	assert_true(b.still_to_act().has(a), "the first can still fight")
	assert_true(b.order(a, sq), "ordered onto it")
	assert_false(b.still_to_act().has(a), "and is done once ordered")
	for m in b.mechs():
		if m != a and b.in_range_from(m, m.pos, sq):
			assert_false(b.nothing_left(), "another still has it in reach")
			b.order(m, sq)
	assert_true(b.nothing_left(), "and now the button is all that is left")
	assert_true(b.still_to_act().is_empty(), "with nobody to ask about")


## Where a selected machine could attack from, past its move, in the enemy's violet on the map (Ryan, 25 October; violet since 30 October).
func test_the_attack_hexes_ring_the_move() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	assert_eq(m.attack_range, 1, "a machine fights a pack it stands beside (the long wall brief 3.4)")
	var dests := b.destinations_for(m)
	var threat := b.threat_for(m)
	assert_false(threat.is_empty(), "there are some")
	for h in threat.keys():
		assert_false(dests.has(h) or h == m.pos, "past the move")
		var near := Hex.distance(h, m.pos) <= m.attack_range
		for d in dests.keys():
			near = near or Hex.distance(h, d) <= m.attack_range
		assert_true(near, "within its attack range of where it can stand")
	b.spent[m.id] = 1
	assert_true(b.threat_for(m).is_empty(), "none with no action left")


func test_a_machine_cannot_end_on_another() -> void:
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var shared := Vector2i(-99, -99)
	for h in b.destinations_for(a).keys():
		if b.destinations_for(c).has(h):
			shared = h
			break
	assert_true(shared != Vector2i(-99, -99), "the two share a reachable hex")
	b.move_to(a, shared)
	assert_false(b.destinations_for(c).has(shared), "taken: off the second machine's list")
	assert_true(b.move_to(c, shared).is_empty(), "and refused")


## One pack is one fight (the long wall brief 3.4): a pack beside the target stays out, and the
## machine beside the target is committed.
func test_attack_opens_a_fight_on_the_one_pack_with_the_machines_committed() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	var other: Unit = b.field.packs()[1]
	_engage(b, sq, m)
	other.behaviour = "push"
	for n in Hex.neighbors(sq.pos):
		if b.field.can_stand(other, n) and n != m.pos:
			other.pos = n
			break
	var r := b.roster(sq)
	assert_eq(r["targets"], [sq], "the pack tapped")
	assert_true((r["joins"] as Array).is_empty(), "nothing joins, a pack beside it included")
	assert_true((r["eligible"] as Array).has(m), "the machine beside it may be committed")
	var sk := b.attack(sq, [m])
	assert_true(sk != null, "the fight opens")
	assert_eq(b.state, Battle.State.SKIRMISH, "and is under way")
	assert_eq(sk.packs, [sq], "the one pack is in it")
	assert_eq(sk.mechs.size(), 1, "the one machine committed")
	assert_eq(Battle.ground_hex(sk.packs), sq.pos, "fought on the target's ground")
	assert_eq(b.attack(sq, [m]), null, "no second fight while one is open")


func test_a_machine_out_of_range_cannot_be_committed() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = null
	for p in b.field.packs():
		if not p.is_boss and not bool(b.roster(p)["all_in"]):
			sq = p   # a pack whose fight the boss stays out of
			break
	assert_true(Battlefield.unit_distance(m, sq) > m.attack_range, "the packs start far off")
	assert_false((b.roster(sq)["eligible"] as Array).has(m), "out of range")
	assert_eq(b.attack(sq, [m]), null, "so there is nobody to fight with")


func test_a_machine_that_fought_is_spent_until_the_next_turn() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	win_fight(sk)
	b.finish_skirmish()
	assert_eq(b.state, Battle.State.PLAN, "back to the turn")
	assert_eq(b.actions_left(m), 0, "spent, the fight over")
	assert_true(b.destinations_for(m).is_empty(), "it cannot move")
	var other: Unit = null
	for p in b.field.packs():
		if not p.is_boss:
			other = p
			break
	_engage(b, other, m)
	assert_false((b.roster(other)["eligible"] as Array).has(m), "nor fight again, a pack beside it or not")
	b.end_turn()
	assert_eq(b.actions_left(m), 1, "a new turn gives it back")


func test_a_second_action_fights_twice_a_turn() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	m.grant_passive({"id": "twin", "name": "Twin", "description": "", "effects": [{"trigger": "static", "effect": "extra_action", "value": 1}]}, "twin")
	b.spent.clear()
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	_win(sk)
	b.finish_skirmish()
	assert_eq(b.actions_left(m), 1, "one action left")
	assert_false(b.destinations_for(m).is_empty(), "it can move again, its move whole")
	assert_false(b.moved.has(m.id), "the second action's move, unspent")
	var sq2: Unit = b.field.packs()[0]
	_engage(b, sq2, m)
	assert_true(b.attack(sq2, [m]) != null, "and fight again")


func test_finish_skirmish_removes_the_pack_and_keeps_shields_as_they_were() -> void:
	var b := _battle()
	b.thresholds = []   # no meter here, so no Fracture's elite joins the count
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	m.base["shield_regen"] = 0   # the regen is the fight's own way back; this reads what the map gives, which is nothing
	m.shield = 0
	_win(sk)
	assert_eq(sk.outcome, Skirmish.Outcome.VICTORY, "won")
	var packs_before := b.field.packs().size()
	b.finish_skirmish()
	assert_eq(b.field.packs().size(), packs_before - 1, "pack wiped from the map")
	assert_eq(b.foes_killed, sq.strength, "a won skirmish counts every foe it killed, for the salvage")
	assert_eq(m.shield, 0, "no free refill between skirmishes")
	assert_eq(b.state, Battle.State.PLAN, "the turn goes on")
	assert_eq(b.current, null, "no skirmish open")


## The shield and the heat are the fight's (the long wall brief 3.6; Claude's answer to Ryan's
## "if there is in-battle recharge it's going to feel very disconnected"): a machine that left a
## fight hot and half shielded opens the next at zero heat and full shield, and a turn without a
## fight changes no shield; hull is the battle's.
func test_a_fight_opens_with_the_shield_full_and_the_heat_at_zero() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var idle: Unit = b.mechs()[1]
	idle.shield = 0
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	assert_eq(m.shield, m.shield_max, "the fight opens on a full shield")
	sk.begin()
	sk.start_round()
	sk.mechs[0].heat = sk.mechs[0].heat_max
	m.shield = m.shield_max / 2
	m.hull -= 3
	var hull := m.hull
	win_fight(sk)
	b.finish_skirmish()
	b.end_turn()
	assert_eq(idle.shield, 0, "a turn without a fight changes no shield")
	assert_eq(m.shield, m.shield_max / 2, "nor one after a fight: it waits for the next")
	var other: Unit = null
	for p in b.field.packs():
		if not p.is_boss:
			other = p
			break
	_engage(b, other, m)
	var sk2 := b.attack(other, [m])
	assert_eq(m.shield, m.shield_max, "the next fight opens on a full shield")
	sk2.begin()
	assert_eq(sk2.mechs[0].heat, 0, "and at zero heat")
	assert_eq(m.hull, hull, "the hull carried, as the battle's")


## A fight the team loses leaves the pack its survivors (there is no withdrawal, the long wall
## brief 3.5: a pack survives a fight only by wrecking the machines in it).
func test_survivors_shrink_the_pack() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	var before := sq.strength
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	sk.field_foes()[0].hp = 0
	lose_fight(sk)
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "the machine wrecked")
	b.finish_skirmish()
	assert_true(b.field.units.has(sq), "pack still on the map")
	assert_eq(sq.strength, sk.survivors_for(sq), "strength is what survived")
	assert_eq(sq.strength, before - 1, "a foe short")


## The mechanics audit (25 October): a Gel killed leaves two halves under its pack, and a fight
## left with the pack standing (a withdrawal then, the team's wreck since the long wall brief)
## walked the pack on as every foe of it standing, halves made whole Gels; the pack keeps its own
## Gels alone, and the split is no kill (Ryan, 8 November).
func test_a_wipe_never_grows_a_pack_by_its_halves() -> void:
	var b := Battle.new(3)
	b.formation = [["gel", 4]]   # a Gel pack of its own: the Meadow's stand in its formations since the pass (10 November)
	b.setup(_team(), "meadow")
	quiet_start(b)   # no catch from the opening comes first
	var m: Unit = b.mechs()[0]
	var sq: Unit = null
	for p in b.field.packs():
		if p.foe_id == "gel":
			sq = p
	assert_true(sq != null, "the Meadow fields a Gel pack")
	var before := sq.strength
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	for f in sk.field_foes():
		if f.content_id == "gel":
			f.hp = 0
			break
	sk.end_round()   # the dead cleared: the Gel splits
	var halves := 0
	for f in sk.field_foes() + sk.reinforcements:
		if f.content_id == "gel_half":
			halves += 1
	assert_eq(halves, 2, "the fallen Gel split into two halves")
	lose_fight(sk)
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "the team wrecked, the pack standing")
	b.finish_skirmish()
	assert_eq(sq.strength, before - 1, "the pack walks on one Gel short, never grown by its halves")
	assert_eq(b.foes_killed, 0, "and the split is no kill: the Gel went on as its halves")


func test_boss_death_seals_the_rift() -> void:
	var b := _battle()
	b.rupture()   # the seal broken: the boss can be fought
	var m: Unit = b.mechs()[0]
	_engage(b, b.boss, m)
	var sk := b.attack(b.boss, [m])
	assert_true(b.boss_fight, "the boss's fight")
	var boss := false
	for f in sk.reinforcements:
		boss = boss or f.boss
	assert_true(boss, "the boss pack unpacked into the faction's boss")
	_win(sk)
	b.finish_skirmish()
	assert_false(b.boss_fight, "the flag drops with the fight")
	assert_eq(b.outcome, Battle.Outcome.VICTORY, "victory")
	assert_eq(b.state, Battle.State.DONE, "battle over")


func test_a_hunter_that_caught_its_prey_forces_the_first_fight() -> void:
	# Bible section 5: a hunter within its ring of its prey has caught it; that fight comes
	# first on the player's turn, whatever is tapped, its prey cannot move, and the turn
	# cannot end until it is fought.
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var other: Unit = b.field.packs()[1]
	var hunter: Unit = b.field.packs()[0]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.hunts = "nearest"
	hunter.prey = m.id
	b._new_turn()
	assert_eq(b.forced.size(), 1, "caught")
	assert_true(b.is_pinned(m), "its prey is pinned")
	assert_eq(b.catchers_of(m), [hunter], "by the hunter: its fight, the map's order and the board's")
	assert_true(b.catchers_of(b.mechs()[1]).is_empty(), "and nobody else is caught")
	assert_true(b.destinations_for(m).is_empty(), "and cannot move")
	var r := b.roster(other)
	assert_eq(r["targets"], [hunter], "the forced fight comes first whatever is tapped")
	assert_eq(r["pinned"], m, "with its prey in it")
	assert_true(b.end_turn().is_empty(), "the turn cannot end before it")
	var sk := b.attack(other, [])
	assert_true(sk != null, "it opens with nobody else committed")
	assert_true(sk.packs.has(hunter), "against the hunter")
	_win(sk)
	b.finish_skirmish()
	assert_true(b.forced.is_empty(), "fought")
	assert_eq(b.actions_left(m), 0, "and its prey is spent")
	assert_false(b.end_turn().is_empty(), "the turn may end now")


## One hunter a machine (Ryan, 8 November): two hunters set on one machine never both catch it;
## the second takes the next machine, its own catch a fight of its own.
func test_two_hunters_take_two_machines_and_each_catch_is_its_own_fight() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var m2: Unit = b.mechs()[1]
	var first: Unit = b.field.packs()[0]
	var second: Unit = b.field.packs()[1]
	_engage(b, first, m)
	_engage(b, second, m2)
	for h in [first, second]:
		h.behaviour = "hunt"
		h.hunts = "nearest"
		h.prey = 0
	second.pos = b.field.landing(second, m.pos)   # beside the first's machine too, so "nearest" would pick it
	b._new_turn()
	assert_eq(b.catchers_of(m), [first], "the first, picking first, takes the machine")
	assert_eq(second.prey, m2.id, "the second turns on the other, however near the first's stands")
	_engage(b, second, m2)
	second.behaviour = "hunt"   # _engage parks a pack as a pusher
	b._new_turn()
	assert_eq(b.forced.size(), 2, "two catches, two fights, a machine each")
	var sk := b.attack(null, [])
	assert_eq(sk.packs, [first], "the first fight the first hunter's")
	_win(sk)
	b.finish_skirmish()
	assert_eq(b.forced.size(), 1, "the second catch waits")
	assert_true(b.end_turn().is_empty(), "the turn cannot end before it")
	var sk2 := b.attack(null, [])
	assert_eq(sk2.packs, [second], "against the second hunter")
	assert_true(sk2.mechs.any(func(ms) -> bool: return ms.unit == m2), "with its own prey in it")
	_win(sk2)
	b.finish_skirmish()
	assert_false(b.end_turn().is_empty(), "both fought, the turn may end")


## A hunter's catch is a fight to its end (the long wall brief 3.5: there is no withdrawal): it
## ends in the hunter's fall, the prey free and the turn going on, or in the prey's wreck, the
## hunter walking on.
func test_a_hunters_catch_ends_in_the_packs_fall_or_the_machines_wreck() -> void:
	for won in [true, false]:
		var b := _battle()
		var m: Unit = b.mechs()[0]
		var hunter: Unit = b.field.packs()[0]
		_engage(b, hunter, m)
		hunter.behaviour = "hunt"
		hunter.prey = m.id
		b._new_turn()
		var sk := b.attack(null, [])
		assert_false(sk.can_withdraw(), "no withdrawing from a catch")
		if won:
			win_fight(sk)
		else:
			lose_fight(sk)
		assert_eq(sk.outcome, Skirmish.Outcome.VICTORY if won else Skirmish.Outcome.DEFEAT, "the catch fought to its end")
		b.finish_skirmish()
		assert_true(b.forced.is_empty(), "this turn's forced fight is over")
		if won:
			assert_false(b.field.units.has(hunter), "the hunter fell")
			assert_true(b.field.units.has(m), "its prey stands")
		else:
			assert_true(b.field.units.has(hunter), "the hunter stands")
			assert_false(b.field.units.has(m), "its prey is wrecked")


## Clear the team away from the gate and park a pusher right in front of it.
static func threaten_gate(b: Battle, sq: Unit) -> void:
	var gate_o := Hex.axial_to_offset(b.map.gate)
	for m in b.mechs():
		m.pos = b.field.nearest_standable(m, Hex.offset_to_axial(gate_o.x, gate_o.y - 5))
	for n in Hex.neighbors(b.map.gate_hexes[1]):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	sq.behaviour = "push"


func test_gate_falling_ends_the_battle() -> void:
	var b := _battle()
	b.field.gate_hp = 5
	var sq: Unit = b.field.packs()[0]
	threaten_gate(b, sq)
	b.forced = []
	assert_true((b.field.plan_walks()[sq.id] as Battlefield.Walk).strikes, "the pack shows a strike on the gate")
	b.end_turn()
	assert_eq(b.field.gate_hp, 0, "gate down")
	assert_eq(b.outcome, Battle.Outcome.GATE_FALLEN, "gate fallen")
	assert_eq(b.state, Battle.State.DONE, "battle over")
	assert_eq(b.attack(sq, b.mechs()), null, "nothing to fight once the gate is gone")


func test_wrecked_mechs_leave_the_map() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	for ms in sk.mechs:
		ms.unit.hull = 0
	sk.end_round()
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "wrecked")
	var before := b.mechs().size()
	b.finish_skirmish()
	assert_eq(b.mechs().size(), before - sk.mechs.size(), "wrecks are gone")
	assert_eq(b.field.wrecks.size(), sk.mechs.size(), "and the field keeps them where they fell, for the campaign to read")
	assert_true(b.state == Battle.State.PLAN or b.outcome == Battle.Outcome.WRECKED, "battle continues or ends")


func test_a_skirmish_is_fought_on_the_first_packs_ground() -> void:
	# Decided 22 September, and since 8 October the first pack is the one attacked: the
	# ground is the target's hex, whatever the machines stand on.
	var b := _battle()
	var f := b.field
	var m: Unit = b.mechs()[0]
	var sq: Unit = f.packs()[0]
	var sq2: Unit = f.packs()[1]
	f.map.terrain[m.pos] = BattleMap.Terrain.ROAD
	f.map.terrain[sq.pos] = BattleMap.Terrain.RUINS
	f.map.terrain[sq2.pos] = BattleMap.Terrain.WATER
	var group: Array = [sq, sq2, m]
	assert_eq(Battle.ground_hex(group), sq.pos, "the first pack's hex")
	assert_eq(b.ground_terrain(group), BattleMap.Terrain.RUINS, "and its terrain")
	var sk := b._build_skirmish(group)
	assert_eq(sk.terrain, BattleMap.Terrain.RUINS, "the skirmish is fought there, not on the machine's road")
	assert_eq(sk.ground, "ruins", "and its header names that ground")
	# A winged pack over a wall: the fight's word is the wall's look (Ryan, 29 October: walls are
	# named by what they are), kept through a save.
	f.map.terrain[sq.pos] = BattleMap.Terrain.MOUNTAIN
	f.map.wall_look[sq.pos] = "towers"
	var on_wall := b._build_skirmish(group)
	assert_eq(on_wall.ground, "towers", "a fight over a tower says towers")
	assert_eq(SaveGame._skirmish_from(SaveGame._skirmish_dict(on_wall, f), f).ground, "towers", "and a resumed one too")


## A route drawn by hand goes the way it was drawn, where a tap would take the cheapest way.
func test_a_drawn_route_is_walked_as_drawn() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[1]
	var n1 := Vector2i(-99, -99)
	var dest := Vector2i(-99, -99)
	for a in Hex.neighbors(m.pos):
		if not b.field.can_stand(m, a):
			continue
		for d in Hex.neighbors(a):
			if d != m.pos and Hex.are_adjacent(m.pos, d) and b.field.can_stand(m, d) and b.destinations_for(m).has(d):
				n1 = a
				dest = d
				break
		if dest != Vector2i(-99, -99):
			break
	assert_true(dest != Vector2i(-99, -99), "a neighbour reachable the long way round exists")
	var draft: Array = b.draft_step(m, [], n1)
	assert_eq(draft, [n1], "the first hex joins the draft")
	draft = b.draft_step(m, draft, dest)
	if draft.size() != 2:
		return   # the detour does not fit this machine's move on this map; nothing to test
	assert_true(b.field.route_cost(m, draft, m.movespeed) >= 0, "the draft is a route it can walk")
	assert_eq(b.field.route_to(m, dest).size(), 1, "where the tap would have gone straight there")
	assert_eq(b.draft_step(m, draft, n1), [n1], "back onto a drawn hex cuts the draft to it")
	assert_true(b.draft_step(m, draft, m.pos).is_empty(), "back onto the machine clears it")
	assert_true(b.move_along(m, draft), "the drawn route is walked")
	assert_eq(m.pos, dest, "to its end")
	assert_true(b.moved.has(m.id), "and that is a waypoint laid this action")
	assert_eq(b.move_left(m), m.movespeed - b.field.route_cost(m, draft, m.movespeed), "its cost off the move")


func test_a_draft_never_outruns_the_move() -> void:
	var b := _battle()
	var c: Unit = b.mechs()[1]
	var draft: Array = []
	var cur := c.pos
	for i in range(c.movespeed + 3):
		var stepped := false
		for n in Hex.neighbors(cur):
			if n != c.pos and not draft.has(n) and b.field.can_stand(c, n):
				var next: Array = b.draft_step(c, draft, n)
				if next.size() > draft.size():
					draft = next
					cur = n
					stepped = true
					break
		if not stepped:
			break
	assert_false(draft.is_empty(), "a route was drawn")
	var cost := b.field.route_cost(c, draft, c.movespeed)
	assert_true(cost >= 0 and cost <= c.movespeed, "the draft fits the move: cost %d of %d" % [cost, c.movespeed])
	assert_false(b.move_along(c, []), "an empty draft walks nowhere")


## Nothing returns on the map (the long wall brief 3.6): a quiet turn gives back no shield, and
## no trigger fires for a turn out of a fight (the out-of-combat event left the engine on 12
## November, an event no effect could ride).
func test_a_quiet_turn_returns_no_shield() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	m.shield = 0
	b.forced = []
	b.end_turn()
	assert_eq(m.shield, 0, "no shield back after a turn out of a fight")


func test_a_kill_is_a_kill_whatever_the_fight_ends_in() -> void:
	# Ryan, 7 October: a kill is never taken away (a withdrawal then, a lost fight since the long
	# wall brief), so the salvage the campaign tallies at the battle's end counts every foe
	# killed, won fight or not.
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	var victim: Foe = sk.field_foes()[0]
	victim.hp = 0
	sk._clear_dead()   # the spend's death check: a kill is what it clears (Skirmish.is_kill, 8 November)
	lose_fight(sk)
	assert_eq(sk.outcome, Skirmish.Outcome.DEFEAT, "the fight lost")
	b.finish_skirmish()
	assert_eq(b.foes_killed, 1, "the kill made before the wreck counts")


func test_an_order_needs_the_pack_in_range_and_engage_opens_the_fight() -> void:
	# Bible section 5: a machine is ordered onto a pack it has in range; nothing opens until
	# ENGAGE, which opens the fight with every machine ordered onto that pack.
	var b := _battle()
	var a: Unit = b.mechs()[0]
	var c: Unit = b.mechs()[1]
	var sq: Unit = b.field.packs()[0]
	assert_false(b.order(a, sq), "out of range: refused")
	_engage(b, sq, a)
	assert_true(b.order(a, sq), "beside it: ordered")
	assert_eq(b.state, Battle.State.PLAN, "nothing opens on the order")
	assert_eq(b.next_fight()["target"], sq, "the next fight is at the pack")
	assert_eq(b.next_fight()["machines"], [a], "with the machine ordered")
	b.cancel_order(a)
	assert_true(b.next_fight().is_empty(), "taken back")
	b.order(a, sq)
	var sk := b.engage()
	assert_true(sk != null, "ENGAGE opens it")
	assert_true(sk.packs.has(sq), "at the pack")
	assert_eq(sk.mechs.size(), 1, "with the one machine")
	assert_true(b.orders.is_empty(), "the order is spent")
	assert_false(b.orders.has(c.id), "the other machine was never in it")


func test_the_attack_hex_is_the_farthest_in_range_the_move_reaches() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	sq.behaviour = "push"
	# Park the pack three hexes ahead of the machine, out of its range (adjacency, 3.4).
	var spot := Vector2i(-99, -99)
	for h in b.field.map.all_hexes():
		if Hex.distance(h, m.pos) == 3 and b.field.can_stand(sq, h):
			spot = h
			break
	assert_true(spot != Vector2i(-99, -99), "a hex three away")
	sq.pos = spot
	assert_false(b.in_range_from(m, m.pos, sq), "out of range where it stands")
	var h := b.attack_hex(m, sq)
	assert_true(h != Battle.NO_HEX, "a hex in range within its move")
	assert_true(b.in_range_from(m, h, sq), "in range there")
	for d in b.destinations_for(m).keys():
		if b.in_range_from(m, d, sq):
			assert_true(b._distance_from(d, sq) <= b._distance_from(h, sq), "none in range is farther")
	b.move_to(m, h)
	assert_eq(b.attack_hex(m, sq), m.pos, "in range now: it attacks from where it stands")


func test_moving_out_of_range_drops_the_order() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	assert_true(b.order(m, sq), "ordered")
	var away := Vector2i(-99, -99)
	for h in b.destinations_for(m).keys():
		if not b.in_range_from(m, h, sq):
			away = h
			break
	if away == Vector2i(-99, -99):
		return   # nowhere out of range within its move on this map; nothing to test
	b.move_to(m, away)
	assert_true(b.orders.is_empty(), "out of range: the order drops")


func test_a_catch_comes_first_through_engage() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var helper: Unit = b.mechs()[1]
	var hunter: Unit = b.field.packs()[0]
	var other: Unit = b.field.packs()[1]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	b._new_turn()
	assert_false(b.can_target(other), "another pack cannot be ordered on while the catch waits")
	assert_false(b.next_fight().is_empty(), "the catch is ready to engage with nobody ordered")
	assert_eq(b.next_fight()["target"], null, "the catch, not a pack tapped")
	if b.in_range_from(helper, helper.pos, hunter):
		assert_true(b.order(helper, hunter), "a helper in range may be ordered onto the hunter")
	var sk := b.engage()
	assert_true(sk != null, "it opens")
	assert_true(sk.packs.has(hunter), "against the hunter")
	var in_it := false
	for ms in sk.mechs:
		in_it = in_it or ms.unit == m
	assert_true(in_it, "with its prey in it")


## The hexes a battle's machines move feed the run's Sponsorship (Kestrel's measure, the
## bible's row); a move taken back is taken off.
func test_the_hexes_moved_are_tallied_and_an_undo_takes_them_back() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	assert_eq(int(b.sponsorship["hexes_moved"]), 0, "nothing moved yet")
	var h: Vector2i = b.destinations_for(m).keys()[0]
	var route := b.move_to(m, h)
	assert_eq(int(b.sponsorship["hexes_moved"]), route.size(), "the route's hexes")
	b.undo()
	assert_eq(int(b.sponsorship["hexes_moved"]), 0, "taken back with the move")
	route = b.move_to(m, h)
	assert_eq(int(b.sponsorship["hexes_moved"]), route.size(), "and counted again when it goes")


## The boss's fight (Ryan, 25 October): one order onto it brings every machine, wherever it
## stands and whether or not it has fought this turn; nobody withdraws from it; and its death
## counts among the battle's kills.
func test_the_boss_fight_takes_every_machine_and_cannot_be_left() -> void:
	var b := _battle()
	b.rupture()
	var m: Unit = b.mechs()[0]
	var far: Unit = b.mechs()[2]
	_engage(b, b.boss, m)
	far.pos = b.field.nearest_standable(far, Hex.offset_to_axial(0, b.map.height - 3))
	assert_false(b.in_range_from(far, far.pos, b.boss), "one machine far out of range")
	b.spent[b.mechs()[1].id] = 1   # and one that has fought this turn
	assert_true(b.order(m, b.boss), "one order onto the boss")
	assert_true(b.next_fight_is_boss(), "the next fight is the boss's")
	assert_eq((b.next_fight()["machines"] as Array).size(), b.mechs().size(), "and it takes every machine")
	var before := b.foes_killed
	var sk := b.engage()
	assert_eq(sk.mechs.size(), b.mechs().size(), "every machine is in the fight")
	sk.begin()
	sk.start_round()
	assert_true(sk.committed, "the fight is committed")
	assert_false(sk.can_withdraw(), "no withdrawing from it")
	assert_false(sk.withdraw(), "refused, as every fight's is")
	var trip := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_true(trip.current.committed, "a save keeps it committed")
	_win(sk)
	b.finish_skirmish()
	assert_eq(b.foes_killed, before + 1, "the boss's death is a kill")
	assert_eq(b.outcome, Battle.Outcome.VICTORY, "and the rift is sealed")


## A fight on the boss takes every machine, and nothing joins it or is joined by it (the long
## wall brief 3.4): a pack beside the boss is a fight of its own, the boss staying out of it.
func test_a_fight_on_the_boss_takes_every_machine_and_no_pack_joins_it() -> void:
	var b := _battle()
	b.rupture()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	sq.behaviour = "push"
	# The pack beside the boss, inside its ring, and the machine beside the pack.
	for n in Hex.neighbors(b.boss.pos):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	for n in Hex.neighbors(sq.pos):
		if b.field.can_stand(m, n):
			m.pos = n
			break
	var r := b.roster(sq)
	assert_true((r["joins"] as Array).is_empty(), "the boss beside it does not join")
	assert_false(bool(r["all_in"]), "so it is the pack's own fight")
	var on_boss := b.roster(b.boss)
	assert_true(bool(on_boss["all_in"]), "the boss's own fight takes everyone")
	assert_true((on_boss["joins"] as Array).is_empty(), "and the pack beside it stays out")
	var sk := b.attack(b.boss, [m])
	assert_eq(sk.mechs.size(), b.mechs().size(), "every machine goes in")
	assert_eq(sk.packs, [b.boss], "against the boss's unit alone")
	assert_true(sk.committed, "and none withdraws")


## Orders onto two packs queue and play one at a time, and the order they open in changes
## nothing a fight opens on (the long wall brief 3.4): each fight holds its own pack and the
## machine ordered onto it, in the state it stood in at the turn's start. Each fight's dice are
## drawn from the battle's stream as it opens, as before, so the same fight rolls differently
## in the other order; nothing else does.
func test_two_fights_open_alike_whichever_engages_first() -> void:
	var seen: Array = []
	for first_q in [false, true]:
		var b := _battle(7)
		var a: Unit = b.mechs()[0]
		var c: Unit = b.mechs()[2]
		var p: Unit = null
		var q: Unit = null
		for sq in b.field.packs():
			if sq.is_boss:
				continue
			if p == null:
				p = sq
			elif q == null:
				q = sq
		_engage(b, p, a)
		_engage(b, q, c)
		assert_false(Hex.are_adjacent(p.pos, c.pos) or Hex.are_adjacent(q.pos, a.pos), "each pack beside its own machine alone")
		var order := [[c, q], [a, p]] if first_q else [[a, p], [c, q]]
		for o in order:
			assert_true(b.order(o[0], o[1]), "%s ordered onto %s" % [o[0].display_name, o[1].display_name])
		var fights := {}
		for k in range(2):
			var sk := b.engage()
			assert_true(sk != null, "fight %d opens" % (k + 1))
			var packs: Array = sk.packs.map(func(u: Unit) -> int: return u.id)
			var ms: Array = sk.mechs.map(func(ms: Skirmish.MechState) -> Array: return [ms.unit.id, ms.unit.hull, ms.unit.shield])
			var dice: Array = sk.mechs.map(func(ms: Skirmish.MechState) -> int: return ms.face_index)
			fights[packs[0]] = [packs, ms, sk.rng.seed, dice]
			_win(sk)
			b.finish_skirmish()
		seen.append(fights)
	assert_eq(seen[0], seen[1], "each fight opened on the same pack, machine, state and dice whichever came first (Ryan, 7 November: the order must not change a fight's dice)")


## A final (the bible's section 9): the dealt hero commands the rift, in its rank, with its
## domain's wildlife beside it; the unit stands while its hero does, its escort counted as
## its strength, and the battle is won when the hero falls, whatever is left of the escort.
func test_a_heros_unit_stands_while_its_hero_does_with_its_escort() -> void:
	var db := ContentDB.load_default()
	var fid := ""
	for f in db.factions.keys():
		if not db.bench_of(str(f)).is_empty():
			fid = str(f)
			break
	var hero := str(db.bench_of(fid)[0])
	var escort := str(db.spawn_table(fid, 1)[0][0])
	var b := Battle.new(3)
	b.lineup = [hero]
	b.escort = [escort, 3]
	b.setup(_team(), fid)
	quiet_start(b)   # no catch from the opening comes first
	assert_eq(b.boss.lineup, [hero], "the hero commands the rift")
	assert_eq([b.boss.foe_id, b.boss.strength], [escort, 3], "its wildlife with it")
	b.rupture()
	var m: Unit = b.mechs()[0]
	_engage(b, b.boss, m)
	var sk := b.attack(b.boss, [m])
	assert_true(b.boss_fight, "the commander's fight")
	var commanders := 0
	var escorts := 0
	for f in sk.reinforcements:
		commanders += 1 if f.commands else 0
		escorts += 1 if f.escorts else 0
	assert_eq([commanders, escorts], [1, 3], "it unpacks into its hero and its escort")
	sk.begin()
	sk.start_round()
	_fell(sk, func(f: Foe) -> bool: return f.escorts, 1)
	b.finish_skirmish()   # the fight carried back to the map as it stands: the unit's bookkeeping
	assert_true(b.field.units.has(b.boss), "the hero stands, so its unit does")
	assert_eq([b.boss.lineup, b.boss.strength], [[hero], 2], "its escort a foe short")
	b.spent.clear()   # a fresh turn's actions, without the enemy's turn between
	var sk2 := b.attack(b.boss, [m])
	sk2.begin()
	sk2.start_round()
	_fell(sk2, func(f: Foe) -> bool: return f.commands, 1)
	b.finish_skirmish()
	assert_false(b.field.units.has(b.boss), "the hero fell, and its unit with it")
	assert_eq(b.outcome, Battle.Outcome.VICTORY, "the final is won with the escort still standing")


## Fell `n` of a fight's foes that `which` picks, on the field or still waiting.
func _fell(sk: Skirmish, which: Callable, n: int) -> void:
	for f in sk.field_foes():
		if n > 0 and which.call(f):
			f.hp = 0
			n -= 1
	sk._clear_dead_slots()
	for f in sk.reinforcements.duplicate():
		if n > 0 and which.call(f):
			sk.reinforcements.erase(f)
			n -= 1


## The carry (the Swallowtail's Muster Deck, Ryan's go of 21 October; the block on his word of
## that evening), on a synthetic passive: the machines beside the carrier are lifted in place and
## land as a block round its stop, each where it rode from it, their action as it was and their
## move unspent; their hexes never block its way; a stop the block does not fit is no destination and no
## move, and the map is told which hex fails; an undo puts them back, and is refused once a
## rider has moved on its own.
func test_a_carrier_lifts_the_machines_beside_it_and_lands_them_as_a_block() -> void:
	var b := _battle()
	var carrier: Unit = b.mechs()[0]
	var rider: Unit = b.mechs()[1]
	var third: Unit = b.mechs()[2]
	carrier.grant_passive({"id": "deck", "name": "Deck", "description": "", "effects": [{"trigger": "static", "effect": "carry"}]})
	# A line of four open hexes: the carrier, the rider beside it, the carrier's stop two on (its
	# shortest way over the rider) and the rider's landing beyond.
	var line := _carry_line(b, carrier, rider, third)
	assert_false(line.is_empty(), "a line of four open hexes")
	third.pos = Vector2i(-50, -50)   # off the map, so nobody else rides or blocks
	carrier.pos = line[0]
	rider.pos = line[1]
	var d: Vector2i = line[1] - line[0]
	assert_eq(b.riders_of(carrier), [rider] as Array[Unit], "the machine beside it rides")
	var rider_moved := b.moved.has(rider.id)
	var dests := b.destinations_for(carrier)
	assert_true(dests.has(line[2]), "its riders' hexes never block its way")
	for h in dests.keys():
		assert_true(b.block_fits(carrier, b.riders_of(carrier), h), "every destination takes the block")
	var route := b.move_to(carrier, line[2])
	assert_eq(route, [line[1], line[2]] as Array[Vector2i], "the shortest way, over the rider")
	assert_eq(rider.pos, line[2] + d, "the rider lands where it rode from the carrier")
	assert_eq(b.last_carry, [[rider.id, line[1], line[3]]], "the map is told the ring's move")
	assert_eq(b.moved.has(rider.id), rider_moved, "its move as it was: riding is not moving")
	assert_eq(b.actions_left(rider), 1, "and its action")
	assert_eq(b.shown_positions()[rider.id][0], line[1], "the rider shown where it rode from until the plan plays")
	assert_eq(b.undo(), carrier, "the carrier's move undone")
	assert_eq([carrier.pos, rider.pos], [line[0], line[1]], "the block back where it stood")
	# A stop the block does not fit: the rider's landing held by another machine.
	third.pos = line[3]
	assert_false(b.destinations_for(carrier).has(line[2]), "no destination where the block does not fit")
	assert_eq(b.draft_landing(carrier, [line[1], line[2]])["bad"], [line[3]] as Array[Vector2i], "the map is told which hex fails")
	assert_false(b.move_along(carrier, [line[1], line[2]]), "and the move is refused")
	assert_eq(carrier.pos, line[0], "nothing moved")
	third.pos = Vector2i(-50, -50)
	b.move_to(carrier, line[2])
	var hop := Vector2i(-99, -99)
	for h in b.destinations_for(rider).keys():
		hop = h
		break
	b.move_to(rider, hop)
	assert_eq(b.undo(), rider, "the rider's own move comes back first")
	assert_eq(rider.pos, line[2] + d, "to where it was set down")
	assert_eq(b.undo(), carrier, "then the carry")
	assert_eq([carrier.pos, rider.pos], [line[0], line[1]], "the block back where it stood")
	# The carry played (Ryan, 16 November: "let the swallow carry, then it can drive and fight"):
	# the carrier's action is over, the rider's whole, its move its own.
	b.move_to(carrier, line[2])
	b.take_plan()
	assert_eq(b.actions_left(carrier), 0, "the carrier's move played: its action over")
	assert_eq(b.actions_left(rider), 1, "the rider's action whole")
	assert_true(b.can_move(rider), "and its move its own to give")


## The mechanics audit (25 October): an undo never stacks two machines on a hex. A machine that
## walks onto the hex a carried rider left is taken back first (UNDO takes back the last step
## first), so the block goes back to hexes that are free.
func test_a_carry_is_never_undone_onto_a_machine_that_moved_in() -> void:
	var b := _battle()
	var carrier: Unit = b.mechs()[0]
	var rider: Unit = b.mechs()[1]
	var third: Unit = b.mechs()[2]
	carrier.grant_passive({"id": "deck", "name": "Deck", "description": "", "effects": [{"trigger": "static", "effect": "carry"}]})
	var line := _carry_line(b, carrier, rider, third)
	assert_false(line.is_empty(), "a line of four open hexes")
	third.pos = Vector2i(-50, -50)
	carrier.pos = line[0]
	rider.pos = line[1]
	b.move_to(carrier, line[2])
	assert_eq(rider.pos, line[3], "the rider landed beyond the carrier")
	# Another machine, beside the hex the rider rode from, walks onto it.
	var start := Vector2i(-99, -99)
	for n in Hex.neighbors(line[1]):
		if line.has(n) or not b.field.map.has(n) or b.field.map.is_structure(n) or b.field.unit_at(n) != null:
			continue
		if not BattleMap.passable(b.field.map.terrain[n], third.traits):
			continue
		third.pos = n
		if b.destinations_for(third).has(line[1]):
			start = n
			break
	third.pos = start
	assert_true(b.field.map.has(start), "a machine beside the hex the rider left")
	assert_false(b.move_to(third, line[1]).is_empty(), "walks onto it")
	assert_eq(b.undo(), third, "the undo takes that move back first")
	assert_eq(third.pos, start, "the machine back where it stood")
	assert_eq(b.undo(), carrier, "then the carry")
	assert_eq([carrier.pos, rider.pos], [line[0], line[1]], "the block back where it stood")
	assert_false([line[0], line[1]].has(third.pos), "and no two machines on one hex")


## Four hexes in a line from a machine's own side of the map, every one open ground for the
## carrier's way and for the rider, none beside another unit; empty when the map has none.
func _carry_line(b: Battle, carrier: Unit, rider: Unit, third: Unit) -> Array:
	for c in b.field.map.all_hexes():
		for d in Hex.DIRECTIONS:
			var line: Array = [c, c + d, c + d * 2, c + d * 3]
			var ok := true
			for k in range(4):
				var h: Vector2i = line[k]
				var o := b.field.unit_at(h) if b.field.map.has(h) else null
				if not b.field.map.has(h) or b.field.map.is_structure(h) or (o != null and o != carrier and o != rider and o != third):
					ok = false
					break
				# The carrier stands on the first and the third and passes over the second, on
				# open ground; the rider stands on the second and the fourth.
				if k <= 2 and BattleMap.step_cost(b.field.map.terrain[h], carrier.traits) != BattleMap.STEP:
					ok = false
					break
				if (k == 1 or k == 3) and not BattleMap.passable(b.field.map.terrain[h], rider.traits):
					ok = false
					break
			if not ok:
				continue
			var crowded := false
			for k in range(4):
				for n in Hex.neighbors(line[k]):
					var o := b.field.unit_at(n)
					if o != null and o != carrier and o != rider and o != third:
						crowded = true
			if not crowded:
				return line
	return []


## The packs a mouth sends at a peak (Ryan, 24 November: "I think enabling multiple spawns at the
## rift and at tears is plenty ... If we enable multiple simultaneous spawns from all spawn points,
## it gives us a very useful tuning dial for convergences"): every mouth sends so many, the rift
## and each open tear alike, two the game's own and the dial another count, and the Rupture's
## size counts them.
func test_every_mouth_sends_as_many_packs_as_the_sends_trial_says() -> void:
	var own := Battlefield.SENDS_A_PEAK
	assert_eq(Battlefield.sends_a_peak(), own, "no trial: the game's own count")
	var plain := Battle.new(6)
	plain.setup(_team(), "meadow")
	assert_true(plain.field.tears.is_empty(), "no tear stands before the first peak")
	plain.end_turn()
	assert_eq([plain.field.rift_spawns, plain.field.tear_spawns], [own, 0], "the game's own: the rift sends its two at a peak")
	var open := plain.field.tears.size()
	assert_true(open > 0, "a tear opened at the first peak")
	var hunting := 1 if not plain.field.hunters.is_empty() else 0   # the rift's hunting pack at the second peak
	plain.field.peak()
	assert_eq([plain.field.rift_spawns, plain.field.tear_spawns], [2 * own + hunting, own * open], "at the next, each open tear sends as many as the rift")
	for tried in [own + 1, own - 1]:
		if tried < 1:
			continue   # no dial below one pack a mouth
		Battlefield.sends_trial = tried
		assert_eq(Battlefield.sends_a_peak(), tried, "the dial at %d" % tried)
		var b := Battle.new(6)
		b.setup(_team(), "meadow")
		assert_true((int(b.thresholds[-1]) - int(plain.thresholds[-1])) * (tried - own) > 0, "the Rupture's size counts what the mouths send (%d at %d a mouth against %d at %d)" % [int(b.thresholds[-1]), tried, int(plain.thresholds[-1]), own])
		b.end_turn()
		assert_eq([b.field.rift_spawns, b.field.tear_spawns], [tried, 0], "the rift sends %d at a peak" % tried)
		assert_eq(b.field.tears.size(), open, "and no more tears open for it")
		b.field.peak()
		assert_eq([b.field.rift_spawns, b.field.tear_spawns], [2 * tried + hunting, tried * open], "at the next, each open tear sends %d" % tried)
	Battlefield.sends_trial = 0
	var again := Battle.new(6)
	again.setup(_team(), "meadow")
	assert_eq(again.thresholds, plain.thresholds, "no trial: the game's own size")


## The tide is graded (Ryan, 23 November: "the far edges are 1s with a sprinkling of 2s, then 2s
## in between, and 3s coming right down the center. Move speed for pushers probably should reflect
## that, with 1s fastest and 3s slowest"; the game's own tide since 25 November, on his "Go ahead
## with the switch-over"): a battle opens on packs before every band of the wall, each of its
## band's rating; a mouth's packs are drawn by the band of the wall each makes for; a pack walks at
## its composition's pace; the hunting packs come apart from them; and a save keeps the lists.
func test_the_tide_deals_packs_by_the_band_of_the_wall_they_make_for() -> void:
	var db := ContentDB.load_default()
	Battlefield.sends_trial = 3
	var b := Battle.new(8)
	b.setup(_team(), "meadow")
	var f := b.field
	assert_true(f.graded.has(1) and f.graded.has(2) and f.graded.has(3), "the Meadow has packs for one, two and three")
	for r in f.graded.keys():
		for c in f.graded[r]:
			assert_eq([ContentDB.squad_of(c), str(c.get("hunts", ""))], [int(r), ""], "%s is a pack for %d that pushes" % [str(c["id"]), int(r)])
	assert_false(f.hunters.is_empty(), "its hunting packs stand apart")
	for c in f.hunters:
		assert_false(str(c.get("hunts", "")).is_empty(), "%s hunts" % str(c["id"]))
	# The opening: packs before every band of the wall (Ryan, 24 November: "There needs to be more
	# packs on the field at the start, for sure"), seven of them, eight from the third Convergence
	# and nine from the eighth, each of its band's rating, none to strike on the first turn.
	var opened: Array = f.packs().filter(func(sq: Unit) -> bool: return not sq.is_boss)
	var form := Battle.graded_opening(0, f.map.width)
	assert_eq(opened.size(), form.size(), "the opening stands its form")
	for ramp in range(Ramp.TOP + 1):
		assert_eq(Battle.graded_opening(ramp, f.map.width).size(), _opening_count(ramp), "Convergence %d: two at each end, one before each band between, the ramp's count before the middle" % ramp)
	assert_eq([0, 2, 3, 7, 8, Ramp.TOP].map(func(ramp: int) -> int: return Battle.graded_opening(ramp, f.map.width).size()), [7, 7, 8, 8, 9, 9], "seven packs, eight from the third Convergence and nine from the eighth")
	assert_true(Battle.graded_opening(0, Battlefield.BAND_RATING.size() - 1).is_empty(), "a field too narrow to have the five bands opens with nothing of the form")
	var stood := {}
	for e in form:
		assert_eq(int(e[1]), int(Battlefield.BAND_RATING[int(e[0])]), "the form stands a band its own rating")
		assert_eq(f.band_of(int(e[2])), int(e[0]), "before its own band (column %d)" % int(e[2]))
		assert_true(int(e[3]) >= 2, "two moves or more from the wall")
	for sq in opened:
		var band := f.band_of((sq as Unit).goal_col)
		stood[band] = true
		assert_eq(int(Battlefield.BAND_RATING[band]), (sq as Unit).squad, "%s, a pack for %d, makes for a band of its rating (column %d)" % [(sq as Unit).display_name, (sq as Unit).squad, (sq as Unit).goal_col])
		assert_eq((sq as Unit).behaviour, "push", "and pushes")
		assert_false(f.soonest_columns(sq).is_empty(), "%s opens with a way to the wall" % (sq as Unit).display_name)
		assert_false((f.plan_walks()[(sq as Unit).id] as Battlefield.Walk).strikes, "and strikes nothing on the first turn")
	assert_eq(stood.size(), Battlefield.BAND_RATING.size(), "a pack makes for every band of the wall")
	assert_eq(opening_off_lists(b), "", "each the next of its rating's list, from where the seed started it")
	# A peak: the rift sends three, each to a band of its own, at its band's rating but for an
	# end's odd pack for two.
	b.end_turn()
	var sent: Array = f.packs().filter(func(sq: Unit) -> bool: return not sq.is_boss and not opened.has(sq))
	assert_eq(sent.size(), 3, "the rift sends three at a peak under the sends' trial")
	var bands := {}
	for sq in sent:
		var band := f.band_of((sq as Unit).goal_col)
		bands[band] = true
		var want := int(Battlefield.BAND_RATING[band])
		assert_true((sq as Unit).squad == want or (want == 1 and (sq as Unit).squad == 2), "%s, a pack for %d, makes for a band of its rating (column %d)" % [(sq as Unit).display_name, (sq as Unit).squad, (sq as Unit).goal_col])
	assert_eq(bands.size(), 3, "each to a band of its own")
	# A pack's pace is its composition's where it names one.
	var paced: Dictionary = {}
	for c in f.graded[1]:
		if c.has("pace"):
			paced = c
	assert_false(paced.is_empty(), "a pack for one in content names its pace")
	var runner := f.emerge(paced, f.map.rift, 0)
	assert_eq(runner.movespeed, int(paced["pace"]), "and walks at it")
	assert_ne(int(db.foes[runner.foe_id].get("movespeed", 0)), int(paced["pace"]), "where its own foes walk another (%s)" % runner.foe_id)
	# The hunting packs come out of the rift every other peak from the second.
	var hunting := func() -> int: return f.packs().filter(func(sq: Unit) -> bool: return sq.behaviour == "hunt").size()
	assert_eq(hunting.call(), 0, "none at the first peak")
	f.peak()
	assert_eq(hunting.call(), 1, "one at the second")
	# A save keeps the tide's lists and where each stands, so the resumed rift sends on from them.
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(back.field.graded.keys().size(), f.graded.keys().size(), "a save keeps the packs by rating")
	for r in f.graded.keys():
		assert_eq((back.field.graded[r] as Array).map(func(c: Dictionary) -> String: return str(c["id"])), (f.graded[r] as Array).map(func(c: Dictionary) -> String: return str(c["id"])), "each list as it was (%d)" % int(r))
		assert_eq(int(back.field._graded_at[r]), int(f._graded_at[r]), "and where it stands")
	assert_eq([back.field.hunters.size(), back.field._hunter_index], [f.hunters.size(), f._hunter_index], "and the hunting packs")
	var twin := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	var before := back.field.packs().size()
	back.field.peak()
	twin.field.peak()
	assert_true(back.field.packs().size() > before, "and the resumed battle's rift sends by the bands still")
	var drawn := func(field: Battlefield) -> Array: return field.packs().slice(before).map(func(sq: Unit) -> Array: return [sq.composition, sq.goal_col, sq.pos])
	assert_eq(drawn.call(back.field), drawn.call(twin.field), "the same packs to the same stretches however often it is resumed: the draw is the seed's, the peak's and the mouth's")
	f.peak()
	assert_eq(drawn.call(f), drawn.call(back.field), "as the unbroken battle sends them")
	Battlefield.sends_trial = 0


## The tide's pushers come down onto their own stretch (Battlefield._higher): a pack the
## rift sends to an end of the wall crosses the field high and never stands on the apron short of
## its stretch, where it would stop and strike (Ryan, 23 November, of the walk it would otherwise
## be: "they're skipping sections they could hit this turn to go hit something two turns away").
func test_a_pack_bound_for_an_end_never_stops_short_along_the_wall() -> void:
	var b := Battle.new(8)
	b.setup([], "meadow")   # nobody to catch or block it
	var f := b.field
	var one := f.emerge(f.next_graded(1), f.map.rift, 0)
	assert_eq(f.band_of(one.goal_col), 0, "a pack for one bound for the wall's first band (column %d)" % one.goal_col)
	var turns := 0
	while not f.on_apron(one, one.pos) and turns < 20:
		var w: Battlefield.Walk = f.plan_walks()[one.id]
		assert_false(w.path.is_empty(), "it walks every turn until it stands at the wall")
		for h in w.path:
			if f.on_apron(one, h):
				assert_eq(f.band_of(Hex.axial_to_offset(h).x), 0, "the first apron hex it touches is in its own band (column %d)" % Hex.axial_to_offset(h).x)
		one.pos = w.end
		turns += 1
	assert_true(f.on_apron(one, one.pos), "it reaches the wall (%d turns)" % turns)
	assert_eq(f.band_of(Hex.axial_to_offset(one.pos).x), 0, "in its own band")


## A pack the rift sends lands outside the shell, on the side it is headed (Ryan, 24 November:
## "spawns from the rift should probably spawn outside of the shell, and on a hex that is on the
## side of where they're headed. Right now they spawn from the back and have to skirt around the
## whole rift to head out"): on the ring round the shell's seven, the hex its walk is shortest
## from; its first walk never crosses the rift's column; a hunting pack lands on its prey's side
## and locks nothing by it; nothing lands beside a machine; with the ring held it still stands
## off the shell; and a pack dealt for no band lands there too, on the segment it drew first.
func test_a_pack_the_rift_sends_lands_outside_the_shell_on_the_side_it_is_headed() -> void:
	var b := Battle.new(8)
	b.setup(_team(), "meadow")
	var f := b.field
	# A bare field, so the read is the landing's and no shape's: the opening's packs off it.
	for sq in f.packs():
		if not sq.is_boss:
			f.units.erase(sq)
	for h in f.map.terrain.keys():
		if not f.map.is_structure(h):
			f.map.terrain[h] = BattleMap.Terrain.PLAIN
	var shell := f.map.shell_hexes()
	var ring := f.rift_ring()
	assert_eq(shell.size(), 7, "the shell's seven")
	assert_true(ring.size() >= 8, "a ring of hexes round them (%d)" % ring.size())
	for h in ring:
		assert_false(shell.has(h) or f.map.rift_hexes.has(h), "no ring hex is the shell's or the rift's")
		assert_true(Hex.neighbors(h).any(func(n: Vector2i) -> bool: return shell.has(n)), "each beside one of the seven")
	var rift_col := Hex.axial_to_offset(f.map.rift).x
	var last := Battlefield.BAND_RATING.size() - 1
	var sides := {0: -1, last: 1}
	for band in [0, last]:
		var sq := f.emerge(f.next_graded(1), f.map.rift, band)
		assert_eq(f.band_of(sq.goal_col), band, "a pack bound for an end of the wall (column %d)" % sq.goal_col)
		assert_true(ring.has(sq.pos), "lands on the ring outside the shell (%s)" % str(Hex.axial_to_offset(sq.pos)))
		assert_true((Hex.axial_to_offset(sq.pos).x - rift_col) * int(sides[band]) > 0, "on its own side of the rift (column %d)" % Hex.axial_to_offset(sq.pos).x)
		var w: Battlefield.Walk = f.plan_walks()[sq.id]
		assert_false(w.route.is_empty(), "and walks")
		for h in w.route:
			assert_true((Hex.axial_to_offset(h).x - rift_col) * int(sides[band]) >= 0, "never round the rift to the other side (column %d)" % Hex.axial_to_offset(h).x)
		assert_eq(w.route.size(), Hex.distance(sq.pos, w.route[w.route.size() - 1]), "straight to its stretch, no hex wasted")
	var centre := f.emerge(f.next_graded(3), f.map.rift, last / 2)
	assert_true(ring.has(centre.pos), "a pack bound for the middle lands on the ring")
	assert_eq(Hex.axial_to_offset(centre.pos).y, BattleMap.RIFT_ROWS + 1, "before the rift, the row past the shell's")
	# A hunting pack: on its prey's side, and its prey is locked when it first walks, as before.
	assert_false(f.hunters.is_empty(), "the Meadow's hunting packs")
	for side in [-1, 1]:
		var k := 0
		for m in f.mechs():
			m.pos = Hex.offset_to_axial(rift_col + side * (6 + k), f.apron_row() - 2)
			k += 1
		var locked := f.locks.size()
		var hunt := f.emerge(f.hunters[0], f.map.rift)
		assert_eq(hunt.behaviour, "hunt", "a hunting pack")
		assert_true(ring.has(hunt.pos), "lands on the ring")
		assert_true((Hex.axial_to_offset(hunt.pos).x - rift_col) * side > 0, "on the side its prey stands (column %d)" % Hex.axial_to_offset(hunt.pos).x)
		assert_eq([hunt.prey, f.locks.size()], [0, locked], "and the landing locks nothing")
		f.units.erase(hunt)
	# Nothing lands beside a machine: one stood by the ring's hex turns the pack to the next.
	var probe := f.emerge(f.next_graded(1), f.map.rift, 0)
	var first := probe.pos
	f.units.erase(probe)
	var guard: Unit = f.mechs()[0]
	for n in Hex.neighbors(first):
		if f.can_stand(guard, n):
			guard.pos = n
			break
	assert_true(f.machine_adjacent(first), "a machine beside the hex a pack took")
	var turned := f.emerge(f.next_graded(1), f.map.rift, 0)
	assert_true(turned.pos != first and not f.machine_adjacent(turned.pos), "the next lands clear of it")
	assert_false(shell.has(turned.pos), "and off the shell still")
	# The ring held: the pack lands beyond it, never on the shell.
	for h in ring:
		if f.unit_at(h) == null:
			var block := f.emerge(f.next_graded(1), Hex.offset_to_axial(0, f.apron_row() - 1))
			block.pos = h
	var late := f.emerge(f.next_graded(1), f.map.rift, 0)
	assert_false(shell.has(late.pos) or ring.has(late.pos) or f.map.rift_hexes.has(late.pos), "with the ring held it lands past it (%s)" % str(Hex.axial_to_offset(late.pos)))
	# A pack dealt for no band (an elite that pushes, a pack made by hand): the same landing, and
	# the segment it draws is the wall it reaches soonest from the hex nearest the rift's middle,
	# read before the pack takes its place on the ring. The twin battle deals the same pack by
	# hand as far as the draw, and stops there.
	var free := Battle.new(8)
	free.setup(_team(), "meadow")
	var twin := Battle.new(8)
	twin.setup(_team(), "meadow")
	var c: Dictionary = (free.field.graded[3] as Array)[0]
	var sent := free.field.emerge(c, free.map.rift)
	var drawn := Battlefield.pack_of(c, twin.field.spawn_faction)
	twin.field.dress_pack(drawn)
	if int(c.get("pace", 0)) > 0:
		drawn.movespeed = int(c["pace"])
	drawn.pos = twin.field.landing(drawn, twin.map.rift)
	twin.field.add_unit(drawn)
	var reached := twin.field.soonest_columns(drawn)
	twin.field.assign_goal(drawn)
	assert_eq([sent.id, sent.movespeed], [drawn.id, drawn.movespeed], "the twin's pack is the same pack")
	assert_true(reached.has(drawn.goal_col), "dealt for no band, a pack draws among the wall it reaches soonest (column %d of %s)" % [drawn.goal_col, str(reached)])
	assert_eq(sent.goal_col, drawn.goal_col, "and the rift's pack keeps the segment it drew before it took its place")
	assert_ne(sent.pos, drawn.pos, "which is not where the draw was read from")
	assert_true(free.field.rift_ring().has(sent.pos), "its pack lands on the ring too")
	assert_false(free.map.shell_hexes().has(sent.pos), "off the shell")


## Nothing is stood where it could only wait: the opening's pushers and the tears take ground
## with a way to the wall (Battlefield.wall_ground), so a corner the map's shape closed off holds
## neither (a pack stood in one held its hex for the battle and the Rupture's size counted it).
func test_the_opening_and_the_tears_take_ground_with_a_way_to_the_wall() -> void:
	var b := Battle.new(8)
	b.map_kind = "steppe"
	b.setup(_team(), "meadow")
	var f := b.field
	for h in f.map.terrain.keys():
		if not f.map.is_structure(h):
			f.map.terrain[h] = BattleMap.Terrain.PLAIN
	# A pocket in the field's corner: the hex itself open, every hex beside it a crag.
	var pocket := Hex.offset_to_axial(0, Battle.OPENING_FLOOR_ROW)
	for n in Hex.neighbors(pocket):
		if f.map.has(n):
			f.map.terrain[n] = BattleMap.Terrain.MOUNTAIN
	var sq: Unit = f.packs().filter(func(u: Unit) -> bool: return not u.is_boss and u.behaviour == "push")[0]
	var ground := f.wall_ground(sq)
	assert_false(ground.has(pocket), "the pocket has no way to the wall")
	assert_true(ground.has(Hex.offset_to_axial(3, Battle.OPENING_FLOOR_ROW)), "the open field beside it has")
	sq.pos = pocket
	assert_true(f.soonest_columns(sq).is_empty(), "a pack stood there could only wait")
	b._open_row(sq, 0, 20)   # as far back as the field goes, at the corner's column
	assert_ne(sq.pos, pocket, "the opening stands it elsewhere")
	assert_false(f.soonest_columns(sq).is_empty(), "on ground with a way to the wall")
	# A tear: the pocket is the farthest hex from the rift on its row, and no tear opens there.
	f.tear_row = Battle.OPENING_FLOOR_ROW
	var at := f.tear_hex()
	assert_ne(at, Battlefield.NO_HEX, "a tear finds a hex")
	assert_ne(at, pocket, "never the pocket")
	assert_true(ground.has(at), "one with a way to the wall")


## The pack bonus (Ryan, 23 November: "Maybe add a flat fracture bonus to a pack on top of the
## per-foe weight, so that splitting into 4 fights across the map and grouping for bigger packs are
## both viable ways of farming fracture"): a pack pays the meter its bonus as it falls, once, on
## top of its rating, half a pip the game's own and the dial another; the Rupture's size counts
## the bonus for every pack it counts, so the battle's length holds; the tally is never touched;
## a save keeps what was paid.
func test_the_pack_bonus_pays_a_pack_as_it_falls_and_sizes_the_rupture_to_match() -> void:
	var bonus := Battle.PACK_BONUS
	assert_eq(Battle.pack_bonus(), bonus, "no trial: the game's own bonus")
	assert_true(bonus > 0, "which pays something, so the rule is read (%d)" % bonus)
	Battle.pack_bonus_trial = 0
	assert_eq(Battle.pack_bonus(), 0, "the dial at none: no bonus, where the game's own is one")
	var none := Battle.new(8)
	none.setup(_team(), "meadow")
	Battle.pack_bonus_trial = -1
	var b := Battle.new(8)
	b.setup(_team(), "meadow")
	# The packs the size counts at the first Convergence: what opens, every mouth's sends a beat
	# (the rift's, and those of each tear open before the beat), the hunting pack of every other
	# beat from the second; less the one the squad may leave, and each elite.
	var counted := _opening_count(0)
	var open := 0
	for beat in range(Ramp.beats_at(0)):
		counted += Battlefield.sends_a_peak() * (1 + open)
		if beat % 2 == 1 and not b.field.hunters.is_empty():
			counted += 1
		open += Ramp.tears_at(0)
	assert_eq(counted, int(_rupture_size(b)[2]), "the packs the field's part counts")
	counted += Ramp.elite_fractures_at(0).size() - Battle.RUPTURE_LEAVE
	assert_eq(int(b.thresholds[-1]), int(none.thresholds[-1]) + bonus * counted, "the Rupture grows by the bonus of every pack it counts (%d)" % counted)
	assert_eq(b.thresholds.size(), none.thresholds.size(), "the same Fractures")
	Battle.pack_bonus_trial = 2 * bonus
	var twice := Battle.new(8)
	twice.setup(_team(), "meadow")
	assert_eq(int(twice.thresholds[-1]), int(none.thresholds[-1]) + 2 * bonus * counted, "and by a trial's as much")
	Battle.pack_bonus_trial = -1
	quiet_start(b)
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	var worth := ContentDB.worth_of(sq.squad)
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	var felled := false
	for f in sk.field_foes():
		if f.pack_id == sq.id and not felled and Battlefield.heads(sq) >= 2:
			f.hp = 0
			felled = true
	sk.end_round()
	b.finish_skirmish()
	if felled:
		assert_true(b.field.units.has(sq), "a head of it gone, the pack standing")
		assert_eq(b.meter_bonus, 0, "a pack that stands has paid no bonus")
		assert_eq(b.meter(), b.menace_killed, "its heads' share alone on the meter")
		b.spent.clear()
		_engage(b, sq, m)
		_win(b.attack(sq, [m]))
		b.finish_skirmish()
	else:
		_win(sk)
		b.finish_skirmish()
	assert_false(b.field.units.has(sq), "the pack has fallen")
	assert_eq(b.menace_killed, worth, "the tally is its rating: salvage and Anathema read no bonus")
	assert_eq([b.meter_bonus, b.meter()], [bonus, worth + bonus], "and the meter its rating and the bonus, once")
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq([back.meter_bonus, back.meter()], [b.meter_bonus, b.meter()], "a save keeps what the bonus has paid")
	# The dial at none: a pack's fall pays its rating and nothing over it.
	Battle.pack_bonus_trial = 0
	quiet_start(none)
	var m0: Unit = none.mechs()[0]
	var sq0: Unit = none.field.packs()[0]
	_engage(none, sq0, m0)
	_win(none.attack(sq0, [m0]))
	none.finish_skirmish()
	assert_false(none.field.units.has(sq0), "with no bonus, a pack fallen")
	assert_eq([none.meter_bonus, none.meter()], [0, none.menace_killed], "pays the meter its rating alone")
	Battle.pack_bonus_trial = -1
	var again := Battle.new(8)
	again.setup(_team(), "meadow")
	assert_eq(again.thresholds, b.thresholds, "no trial: the game's own size")


## The leaders' step on trial (Ryan, 23 November: "A set form of each formation, for each C. Bosses
## too ... if they don't scale with me they'll become a joke at C4"): an elite's and a boss's hit
## points so many hundredths more for each Convergence its battle stands past its tier's first,
## three steps at most, the rank and file beside them as content has them; nothing with no trial.
func test_the_leaders_trial_steps_a_bosss_and_an_elites_hit_points_by_the_convergence() -> void:
	var db := ContentDB.load_default()
	assert_eq(ContentDB.step_in_tier(0, 0), 0, "a tier's first Convergence is no step")
	assert_eq(ContentDB.step_in_tier(0, 2), 2, "two battles in, two")
	assert_eq(ContentDB.step_in_tier(0, 9), Campaign.TIER_EVERY - 1, "a rift fought late holds its tier's last step")
	assert_eq(ContentDB.step_in_tier(1, 5), 1, "tier two's count from its own first")
	var hp := {}
	for trial in [0, 20]:
		ContentDB.leader_step_trial = trial
		for ramp in [0, 2]:
			var b := Battle.new(9)
			b.ramp = ramp
			b.setup(_team(), "meadow")
			assert_eq(b.boss.boss_step, ramp, "the boss's unit knows its battle's place in the tier")
			var foes: Array = b.db.foes_for(b.boss)
			hp[[trial, ramp, "boss"]] = (foes[0] as Foe).hp_max
			b._spawn_elite()
			var elite: Unit = b.field.packs()[b.field.packs().size() - 1]
			assert_eq(elite.composition_size, "elite", "an elite sent")
			assert_eq(elite.boss_step, ramp, "and it knows the same")
			var led := 0
			var file := 0
			for f in b.db.foes_for(elite):
				if b.db.is_elite((f as Foe).content_id):
					led += (f as Foe).hp_max
				else:
					file += (f as Foe).hp_max
			hp[[trial, ramp, "elite"]] = led
			hp[[trial, ramp, "file"]] = file
	ContentDB.leader_step_trial = 0
	for who in ["boss", "elite"]:
		assert_eq(hp[[0, 2, who]], hp[[0, 0, who]], "no trial: a %s's hit points the same at every Convergence of its tier" % who)
		assert_eq(hp[[20, 0, who]], hp[[0, 0, who]], "the trial at the tier's first Convergence: as content has it")
		assert_eq(hp[[20, 2, who]], roundi(float(hp[[0, 0, who]]) * 1.4), "two Convergences in at a fifth a step: two fifths more")
	assert_eq(hp[[20, 2, "file"]], hp[[0, 2, "file"]], "the rank and file beside an elite as content has them")

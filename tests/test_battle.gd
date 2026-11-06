extends TestCase

## The battle loop, headless (bible section 4, the round row): setup, the player's turn of
## moves and fights, the fights hunters force, the enemy's turn, and outcomes.


func _team() -> Array:
	var db := ContentDB.load_default()
	var out: Array = []
	for id in ["badger", "clydesdale", "sparrowhawk"]:
		out.append(db.make_mech(id))
	return out


func _battle(seed_value: int = 3) -> Battle:
	var b := Battle.new(seed_value)
	b.setup(_team(), "marsh", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
	quiet_start(b)   # these tests read their own rules, not the opening's (TestCase.quiet_start)
	return b


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


func _win(sk: Skirmish) -> void:
	sk.begin()
	sk.start_round()
	sk.reinforcements.clear()
	for f in sk.field_foes():
		f.hp = 0
	sk.end_round()


func test_setup_places_team_formation_and_boss() -> void:
	var b := Battle.new(3)
	b.setup(_team(), "marsh")
	assert_eq(b.mechs().size(), 3, "three mechs")
	assert_eq(b.field.packs().size(), 1 + Ramp.formations_at(0) + Ramp.patrols_at(0), "the ramp's formations and patrols at the start, plus the boss")
	assert_true(b.boss != null and b.field.units.has(b.boss), "boss on the field")
	assert_eq(b.boss.foe_id, "", "boss unpacks by faction, not foe id")
	for u in b.field.units:
		assert_true(b.field.can_stand(u, u.pos), "%s stands on legal ground" % u.display_name)
	var gate_row := Hex.axial_to_offset(b.map.gate).y
	for m in b.mechs():
		assert_true(Hex.axial_to_offset(m.pos).y >= gate_row - 3, "%s starts by the gate" % m.display_name)
		assert_eq(b.actions_left(m), 1, "%s has its action" % m.display_name)
	# The opening (the long wall brief 3.2): a formation a move of its own from the apron, a
	# patrol two moves, never in the rift's mouth; the boss by the rift; the rift a turn short.
	for sq in b.field.packs():
		var row := Hex.axial_to_offset(sq.pos).y
		if sq.is_boss:
			assert_true(row <= 2, "the boss starts by the rift")
		elif sq.composition_size == "formation":
			assert_eq(row, maxi(BattleMap.MOUTH_ROWS, b.field.apron_row() - sq.movespeed), "%s stands a move from the wall" % sq.display_name)
		else:
			assert_eq(row, maxi(BattleMap.MOUTH_ROWS, b.field.apron_row() - 2 * sq.movespeed), "%s stands two moves from the wall" % sq.display_name)
	assert_eq(b.field.rift_pressure, b.field.rift_pressure_max - 1, "the rift a turn short of its peak")
	assert_eq(b.state, Battle.State.PLAN, "the player's turn")
	assert_eq(b.forced.size(), b.field.forced_fights().size(), "the first turn opens on what the opening's hunters caught, as every turn does")
	assert_eq(b.field.plan_walks().size(), b.field.packs().size(), "every pack's walk shows")


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
		var rift_cols: Array = []
		for rh in c.map.rift_hexes:
			var o := Hex.axial_to_offset(rh)
			assert_eq(o.y, 0, "the rift on the top row " + at)
			rift_cols.append(o.x)
		rift_cols.sort()
		assert_eq(rift_cols, [w / 2 - 1, w / 2, w / 2 + 1], "the rift three hexes at the top centre " + at)
		assert_eq(c.mechs().size(), 4, "four machines " + at)
		for m in c.mechs():
			assert_eq(Hex.axial_to_offset(m.pos).y, c.field.apron_row(), "%s on the row before the gate's apron %s" % [m.display_name, at])


func _four_synthetic() -> Array:
	var out: Array = []
	for n in range(4):
		out.append(Unit.mech(n + 1, "M%d" % (n + 1), Vector2i.ZERO, 3))
	return out


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
	var cycled: Array = b.field.cycle.map(func(comp) -> Array: return [str(comp["members"][0][0]), int(comp["members"][0][1]), str(comp["faction"])])
	assert_eq(cycled, placed, "and the rift sends them in turn")
	b.field.rift_pressure = b.field.rift_pressure_max - 1
	b.field._cycle_index = 1
	b.field.tick_pressure(1)
	var spawned: Unit = b.field.packs()[b.field.packs().size() - 1]
	assert_eq([spawned.foe_id, spawned.faction], [c, str(facs[1])], "a rift pack wears its own faction")
	b.forced = []
	b.field.gate_hp = 0
	b.end_turn()
	assert_eq(b.outcome, Battle.Outcome.GATE_FALLEN, "without a boss only the field ends it")


## A pack as a composition (the foes' fresh start, 30 October): one hex, one sprite (its lead's),
## every member unpacked into the fight, the survivors kept by member, its ring the largest of
## its members', its pace the slowest, winged only when every member is, and each kill worth its
## type's menace.
func test_a_composition_unpacks_its_members_and_keeps_its_survivors_by_member() -> void:
	var b := _battle()
	var db := b.db
	var host := Unit.pack(0, "the host", Vector2i.ZERO, "marsh", Unit.PACK_MOVE, 0, "")
	host.set_members([["revenant", 3], ["ghost", 2]])
	assert_eq(host.foe_id, "revenant", "its foe type is the lead's")
	assert_eq(host.strength, 5, "its strength is the count of every member")
	b.field.add_unit(b.field.dress_pack(host))
	var ring := maxi(int(db.foes["revenant"].get("zone", 1)), int(db.foes["ghost"].get("zone", 1)))
	assert_eq(host.zone, ring, "its ring is the largest of its members'")
	assert_eq(host.movespeed, mini(int(db.foes["revenant"].get("movespeed", 2)), int(db.foes["ghost"].get("movespeed", 2))), "its pace the slowest")
	assert_eq(host.behaviour, str(db.foes["revenant"].get("behaviour", "push")), "it walks by its lead")
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
	assert_eq(b.menace_killed - before, 2 * db.menace("revenant") + db.menace("ghost"), "each at its type's menace")


## The field at the start follows the tier and the ramp (the pacing session, 30 October): the
## tier's compositions, the ramp's count of formations (the second the guest's where there is
## one) and patrols at the ramp's density, the timer the ramp's, and the cycle the lead's and the
## guest's formations and patrols in turn, a formation first.
func test_the_field_at_the_start_follows_the_tier_and_the_ramp() -> void:
	var db := ContentDB.load_default()
	for r in [0, 6, 12]:
		var b := Battle.new(5)
		b.tier = 1
		b.ramp = r
		b.guest = "waste"
		b.setup(_team(), "meadow")
		assert_eq(b.field.rift_pressure_max, Ramp.timer_at(r), "ramp %d: the timer" % r)
		var forms := 0
		var patrols := 0
		var guests := 0
		for sq in b.field.packs():
			if sq.is_boss:
				continue
			if sq.composition_size == "formation":
				forms += 1
			elif sq.composition_size == "patrol":
				patrols += 1
			if sq.faction == "waste":
				guests += 1
			var comp: Dictionary = {}
			for c in db.compositions(sq.faction, 2, sq.composition_size):
				if str(c["id"]) == sq.composition:
					comp = c
			assert_false(comp.is_empty(), "ramp %d: %s is a tier-two composition of its domain" % [r, sq.composition])
			for k in range(comp["members"].size()):
				assert_eq(sq.members[k], [str(comp["members"][k][0]), Ramp.scaled(int(comp["members"][k][1]), r)], "ramp %d: %s's member %d at the ramp's density" % [r, sq.composition, k])
		assert_eq(forms, Ramp.formations_at(r), "ramp %d: the formations at the start" % r)
		assert_eq(patrols, Ramp.patrols_at(r), "ramp %d: the patrols at the start" % r)
		# The lead's and the guest's in turn, the lead's first: the second formation and the
		# second patrol are the guest's.
		assert_eq(guests, Ramp.formations_at(r) / 2 + Ramp.patrols_at(r) / 2, "ramp %d: every second composition on the field is the guest's" % r)
		var first_pack: Unit = b.field.packs()[0]
		assert_eq(first_pack.faction, "meadow", "ramp %d: the first on the field is the lead's" % r)
		assert_eq(str(b.field.cycle[0]["size"]), "formation", "ramp %d: the cycle starts with a formation" % r)
		assert_eq(str(b.field.cycle[0]["faction"]), "meadow", "the lead's")
		assert_eq(str(b.field.cycle[2]["faction"]), "waste", "then the guest's formation, after the lead's patrol")
		for c in b.field.patrol_cycle:
			assert_eq(str(c["size"]), "patrol", "the tears send patrols alone")
		assert_true(b.field.cycle.size() >= db.compositions("meadow", 2, "formation").size() + db.compositions("waste", 2, "formation").size(), "every formation of both is in the cycle")


## The Rupture meter (the pacing session, 30 October): the thresholds from the field's menace at
## the start, the last at two thirds of it; a Fracture pays out as a fight ends, the elite the
## tier names spawning at the rift; the last breaks the seal; a sealed boss cannot be ordered
## onto and joins no fight; and the stall guard breaks the seal once the field is clear.
func test_the_meter_fills_by_menace_and_the_fractures_pay_out_as_fights_end() -> void:
	var b := _battle()   # the Marsh at tier 0: three Fractures, the Reaper at the first
	var db := b.db
	assert_eq(b.thresholds.size(), Ramp.fractures_at(0), "the tier's count of Fractures")
	assert_true(b.field_menace > 0, "the field's menace at the start")
	assert_eq(int(b.thresholds[b.thresholds.size() - 1]), maxi(1, roundi(Battle.RUPTURE_SHARE * float(b.field_menace))), "the last at the Rupture's share of it")
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
	# Kill the first pack outright: its menace is the first Fracture's worth or more.
	var sk := b.attack(sq, [m])
	_win(sk)
	b.finish_skirmish()
	var packs_before := b.field.packs().size()
	assert_true(b.menace_killed > 0, "the tally counts the kills' menace")
	if b.menace_killed >= int(b.thresholds[0]):
		assert_true(b.fractures >= 1, "a Fracture is earned once the tally crosses its threshold")
		assert_eq(b.elites_spawned, [str(db.elite_compositions("marsh", 1)[0]["id"])], "and the Marsh's first own elite emerges at it (the roll at this seed is above the wanderers' chance)")
		var elite: Unit = b.field.packs()[b.field.packs().size() - 1]
		assert_eq(elite.composition_size, "elite", "an elite composition")
		assert_true(db.is_elite(elite.foe_id), "led by its elite")
		assert_true(Hex.distance(elite.pos, b.map.rift) <= 3, "at the rift")
	else:
		assert_eq(b.fractures, 0, "no Fracture under the first threshold")
	assert_true(b.is_sealed(), "the seal holds short of the Rupture")
	# The tally carried over the last threshold by hand: the Rupture.
	b.menace_killed = int(b.thresholds[b.thresholds.size() - 1])
	b._fractures()
	assert_eq(b.fractures, b.thresholds.size(), "every Fracture earned")
	assert_false(b.is_sealed(), "the Rupture: the seal breaks")
	assert_eq(b.rupture_turn, b.field.phase, "the turn it broke")
	assert_false(b.stall_guard, "by the tally, not the guard")
	assert_true(b.can_target(b.boss), "the boss can be fought now")
	assert_true(bool(b.roster(b.boss).get("all_in", false)), "and its fight takes every machine")


func test_the_stall_guard_breaks_the_seal_once_the_field_is_clear() -> void:
	var b := _battle()
	b.thresholds = [100000, 200000, 300000]   # out of reach by the tally
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
	assert_false(b.is_sealed(), "the field clear, the seal breaks by the guard")
	assert_true(b.stall_guard, "marked as the guard's")
	assert_eq(b.fractures, 0, "with no Fracture earned")


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
func test_a_machine_moves_once_an_action() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	assert_true(b.move_to(m, b.map.rift).is_empty(), "the rift is out of reach")
	var near := Vector2i(-99, -99)
	for h in b.destinations_for(m).keys():
		if int(b.destinations_for(m)[h]) < m.movespeed:
			near = h
			break
	assert_true(near != Vector2i(-99, -99), "a hex short of its whole move")
	var route := b.move_to(m, near)
	assert_false(route.is_empty(), "the move is taken")
	assert_eq(m.pos, near, "it is there at once")
	assert_true(b.moved.has(m.id), "and it has moved this action")
	assert_false(b.can_move(m), "so it cannot move again")
	assert_true(b.destinations_for(m).is_empty(), "nothing is lit")
	assert_eq(b.actions_left(m), 1, "a move spends no action: it may still fight")


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
	# A second tap takes the order back, and an undo puts it back.
	b.order_onto(a, pack)
	assert_eq(b.order_onto(a, pack), "cancelled", "the second tap cancels it")
	assert_eq(b.order_of(a), null, "no order")
	b.undo()
	assert_eq(b.order_of(a), pack, "the undo puts the order back")
	b.undo()
	assert_eq([b.order_of(a), a.pos], [null, a0], "and the next takes the first order back")


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


## One pack is one fight (the long wall brief 3.4): a pack beside the target whose ring covers
## it stays out, and the machine beside the target is committed.
func test_attack_opens_a_fight_on_the_one_pack_with_the_machines_committed() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	var other: Unit = b.field.packs()[1]
	_engage(b, sq, m)
	other.zone = 3
	other.behaviour = "push"
	for n in Hex.neighbors(sq.pos):
		if b.field.can_stand(other, n) and n != m.pos:
			other.pos = n
			break
	var r := b.roster(sq)
	assert_eq(r["targets"], [sq], "the pack tapped")
	assert_true((r["joins"] as Array).is_empty(), "nothing joins, a ring of three beside it included")
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
	sk.begin()
	sk.start_round()
	sk.withdraw()
	b.finish_skirmish()
	assert_eq(b.state, Battle.State.PLAN, "back to the turn")
	assert_eq(b.actions_left(m), 0, "spent, though it withdrew")
	assert_true(b.destinations_for(m).is_empty(), "it cannot move")
	assert_false((b.roster(sq)["eligible"] as Array).has(m), "nor fight again")
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


func test_shield_recharges_at_the_field_rate_only_in_a_turn_without_a_fight() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var idle: Unit = b.mechs()[1]
	m.shield = 0
	idle.shield = 0
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	_win(sk)
	b.finish_skirmish()
	b.end_turn()
	assert_eq(m.shield, 0, "a machine that fought this turn gets nothing")
	assert_eq(idle.shield, mini(idle.shield_max, idle.recharge_field), "one that did not, the field rate")
	assert_true(idle.shield <= idle.shield_max, "never above max")


func test_survivors_shrink_the_pack() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	sk.withdraw()
	b.finish_skirmish()
	assert_true(b.field.units.has(sq), "pack still on the map")
	assert_eq(sq.strength, sk.survivors_for(sq), "strength is what survived")


## The mechanics audit (25 October): a Gel killed leaves two halves under its pack, and a
## withdrawal used to walk the pack on as every foe of it standing, halves made whole Gels; the
## pack keeps its own Gels alone, and the kill counts.
func test_a_withdrawal_never_grows_a_pack_by_its_halves() -> void:
	var b := Battle.new(3)
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
	assert_true(sk.withdraw(), "the team pulls out")
	var halves := 0
	for f in sk.field_foes() + sk.reinforcements:
		if f.content_id == "gel_half":
			halves += 1
	assert_eq(halves, 2, "the fallen Gel split into two halves")
	b.finish_skirmish()
	assert_eq(sq.strength, before - 1, "the pack walks on one Gel short, never grown by its halves")
	assert_eq(b.foes_killed, 1, "and the Gel is a kill")


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
	hunter.zone = 1
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


func test_withdrawing_from_a_hunter_leaves_the_machine_caught() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var hunter: Unit = b.field.packs()[0]
	_engage(b, hunter, m)
	hunter.behaviour = "hunt"
	hunter.prey = m.id
	hunter.zone = 1
	b._new_turn()
	var sk := b.attack(null, [])
	sk.begin()
	sk.start_round()
	sk.withdraw()
	b.finish_skirmish()
	assert_true(b.forced.is_empty(), "this turn's forced fight is over")
	b.end_turn()
	assert_eq(b.forced.size(), 1, "next turn the hunter, still on it, has caught it again")
	assert_eq(b.forced[0]["prey"], m, "the same machine")


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
	assert_eq(b.wrecks.size(), sk.mechs.size(), "and the battle keeps them, for the campaign to read")
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
	assert_true(b.moved.has(m.id), "and that is its move this action")
	assert_false(b.can_move(m), "in one go")


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


func test_an_out_of_combat_passive_fires_after_a_quiet_turn() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	m.shield = 0
	m.grant_passive({"id": "hum", "name": "Hum", "description": "", "effects": [
		{"trigger": "out_of_combat", "effect": "add_shield", "value": 5}]}, "hum")
	var rate := m.recharge_field
	b.forced = []
	b.end_turn()
	assert_eq(m.shield, mini(m.shield_max, rate + 5), "the field rate, then the passive's five")


func test_a_kill_is_a_kill_whatever_the_fight_ends_in() -> void:
	# Ryan, 7 October: withdrawing never takes a kill away, so the salvage the campaign
	# tallies at the battle's end counts every foe killed, won fight or not.
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var sq: Unit = b.field.packs()[0]
	_engage(b, sq, m)
	var sk := b.attack(sq, [m])
	sk.begin()
	sk.start_round()
	var victim: Foe = sk.field_foes()[0]
	victim.hp = 0
	assert_true(sk.withdraw(), "the team pulls out")
	assert_eq(sk.outcome, Skirmish.Outcome.WITHDRAWN, "withdrawn")
	b.finish_skirmish()
	assert_eq(b.foes_killed, 1, "the kill made before withdrawing counts")


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
	hunter.zone = 1
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
	assert_false(sk.withdraw(), "refused")
	var trip := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_true(trip.current.committed, "a save keeps it committed")
	_win(sk)
	b.finish_skirmish()
	assert_eq(b.foes_killed, before + 1, "the boss's death is a kill")
	assert_eq(b.outcome, Battle.Outcome.VICTORY, "and the rift is sealed")


## A fight the boss joins by its ring is the boss's fight too: every machine, no withdrawal.
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
			fights[packs[0]] = [packs, ms]
			_win(sk)
			b.finish_skirmish()
		seen.append(fights)
	assert_eq(seen[0], seen[1], "each fight opened on the same pack, machine and state whichever came first")


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
	sk.withdraw()
	b.finish_skirmish()
	assert_true(b.field.units.has(b.boss), "the hero stands, so its unit does")
	assert_eq([b.boss.lineup, b.boss.strength], [[hero], 2], "its escort a foe short")
	b.spent.clear()   # a fresh turn's actions, without the enemy's turn between
	var sk2 := b.attack(b.boss, [m])
	sk2.begin()
	sk2.start_round()
	_fell(sk2, func(f: Foe) -> bool: return f.commands, 1)
	sk2.withdraw()
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

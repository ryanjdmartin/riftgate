extends TestCase

## The run between battles (bible sections 3 and 10; the rules of 6 October): cities and
## their gates, rifts as fronts, what a battle's end does to the city, the roster and the
## salvage, the turn's bleed and drain, the finale, the hangar's few verbs, and the run and
## profile saves. Battles are forced to their ends here; the bot plays one for real once.

const TMP := "user://test_campaign.json"
const TMP_PROFILE := "user://test_profile.json"


func _run(seed_value: int = 5) -> Campaign:
	return Campaign.new(seed_value)


## A chassis with built-in and hardpoint components both, from the content (ids are Ryan's).
func _mixed_chassis(db: ContentDB) -> String:
	for id in db.chassis.keys():
		var c: Dictionary = db.chassis[id]
		if not c.get("fixed", []).is_empty() and c.get("loadout", []).size() >= 2:
			return str(id)
	return ""


## Start a battle at a front (the first, unless named) with every ready machine.
func _battle(c: Campaign, city: String = "") -> Battle:
	var uids: Array = []
	for m in c.ready_machines().slice(0, Campaign.SQUAD):
		uids.append(m.uid)
	return c.start_battle(city if not city.is_empty() else str(c.fronts()[0]), uids)


func _end(b: Battle, outcome: int) -> void:
	b.outcome = outcome
	b.state = Battle.State.DONE


## Wreck a machine the way a skirmish does: hull to zero, off the map, kept by the battle.
func _wreck(b: Battle, u: Unit) -> void:
	u.hull = 0
	b.field.units.erase(u)
	b.wrecks.append(u)


func _destroy(u: Unit, idx: int) -> void:
	var d := Face.blank()
	d.component = u.die.faces[idx].component
	u.die.faces[idx] = d


func test_a_new_run_has_a_city_per_maker_around_the_capital() -> void:
	var c := _run()
	var db := ContentDB.load_default()
	assert_eq(c.cities.size(), db.makers.size(), "a city per maker")
	assert_eq(c.capital().id, db.capital_maker(), "the capital is the capital maker's")
	for city in c.cities.values():
		assert_eq(city.gate, city.gate_max, "%s starts full" % city.id)
	assert_eq(c.capital().gate_max, Campaign.CAPITAL_GATE, "the capital's gate is the life bar")
	assert_eq(c.fronts().size(), Campaign.RIFTS_BASE, "rifts open at tier 0")
	assert_true(c.capital().rift.is_empty(), "the capital is not attacked before the finale")
	assert_eq(c.roster.size(), Campaign.START_MACHINES, "three machines to start, all four squad slots open")
	var offered := Campaign.tender(db, 5)
	for m in c.roster:
		assert_eq(db.chassis_tier(m.chassis), 1, "%s is a tier-one chassis" % m.chassis)
		assert_true(offered.has(m.chassis), "%s was in the tender" % m.chassis)
	assert_eq(c.salvage, Campaign.START_SALVAGE, "starting salvage")
	assert_eq(c.favour, Campaign.START_FAVOUR, "starting Favour")
	assert_eq(c.blueprints, db.starting_blueprints(), "the basics' blueprints")
	assert_true(not c.blueprints.is_empty(), "there are some")
	for cid in c.blueprints:
		assert_eq(db.component_tier(cid), 0, "%s is a basic, tier zero" % cid)


func test_the_tender_offers_one_tier_one_machine_from_each_city_maker() -> void:
	var db := ContentDB.load_default()
	var seen := {}
	for seed_value in range(1, 41):
		var offered := Campaign.tender(db, seed_value)
		var makers := {}
		for id in offered:
			var mk := str(db.chassis[id].get("maker", ""))
			assert_eq(db.chassis_tier(id), 1, "%s is tier one" % id)
			assert_true(mk != db.capital_maker(), "the capital's maker never offers")
			assert_true(not makers.has(mk), "one machine a maker")
			makers[mk] = true
			seen[id] = true
		assert_true(offered.size() >= Campaign.START_MACHINES, "enough to take a full start")
		assert_eq(Campaign.tender(db, seed_value), offered, "a seed always offers the same")
	var city_tier_one := 0
	for id in db.chassis_of_tier(1):
		if str(db.chassis[id].get("maker", "")) != db.capital_maker() and db.chassis_runnable(id):
			city_tier_one += 1
	assert_eq(seen.size(), city_tier_one, "across seeds every city maker's tier-one machine the engine can field is offered")


## The mechanics audit (25 October): the tender drew on the run's own stream, so the runner's
## random pick of three reread Minerva's offer and the Armadillo started every run it was
## offered. On a stream of its own, an offered machine sits a run out as often as any other.
func test_the_runners_pick_never_rereads_the_offer() -> void:
	var db := ContentDB.load_default()
	var sat_out := {}
	for seed_value in range(1, 61):
		var offered := Campaign.tender(db, seed_value)
		var c := Campaign.new(seed_value)
		var started := {}
		for m in c.roster:
			started[m.chassis] = true
		for id in offered:
			if not started.has(id):
				sat_out[id] = true
	for id in db.chassis_of_tier(1):
		if str(db.chassis[id].get("maker", "")) != db.capital_maker() and db.chassis_runnable(id):
			assert_true(sat_out.has(id), "%s, offered, sits a run out now and then" % id)


func test_the_tender_never_deals_a_planned_chassis() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var mk := str(db.city_makers()[0])
	var base := ""
	for id in db.chassis_of_tier(1):
		if str(db.chassis[id].get("maker", "")) == mk:
			base = str(id)
			break
	assert_true(not base.is_empty(), "the maker has a tier one to copy")
	var draft: Dictionary = db.chassis[base].duplicate(true)
	draft["name"] = "Draft"
	draft["passive"] = {"id": "draft", "name": "Draft", "description": "Not built yet.", "status": "planned", "effects": []}
	db.chassis["draft"] = draft
	for seed_value in range(1, 41):
		var offered := Campaign.tender(db, seed_value)
		assert_false(offered.has("draft"), "a chassis whose passive is planned is never dealt")
		var from_maker := 0
		for id in offered:
			if str(db.chassis[id].get("maker", "")) == mk:
				from_maker += 1
		assert_eq(from_maker, 1, "the maker still offers one of its built tier ones")
	# The maker's only tier one planned: it offers nothing until the draft lands.
	for id in db.chassis_of_tier(1):
		if id != "draft" and str(db.chassis[id].get("maker", "")) == mk:
			db.chassis[id]["tier"] = 2
	var offered := Campaign.tender(db, 5)
	for id in offered:
		assert_true(str(db.chassis[id].get("maker", "")) != mk, "a maker whose only tier one is a draft offers nothing")


func test_the_content_names_exactly_one_capital() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	assert_true(not db.capital_maker().is_empty(), "a maker sits at the capital")
	var other := str(db.city_makers()[0])
	db.makers[other]["capital"] = true
	var found := false
	for e in db.validate():
		if e.contains("capital"):
			found = true
	assert_true(found, "two capitals fail validation")


func test_a_front_warns_how_long_its_gate_holds() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	assert_eq(c.turns_to_fall(front), int(ceil(float(Campaign.CITY_GATE) / Campaign.BLEED)), "turns until it bleeds out")
	c.cities[front].gate = Campaign.BLEED + 1
	assert_eq(c.turns_to_fall(front), 2, "a part turn counts")
	assert_eq(c.turns_to_fall(c.capital().id), -1, "the capital never bleeds on its own")


func test_a_battle_is_fought_on_the_citys_gate_with_the_rosters_loadouts() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	c.cities[front].gate = 120
	var m: Campaign.Machine = c.roster[0]
	var before := m.loadout.size()
	assert_true(c.strip(m.uid, 0), "a component comes off")
	var b := _battle(c)
	assert_true(b != null, "the battle opens")
	assert_eq(b.field.gate_hp, 120, "the city's gate is the battle's")
	assert_eq(b.faction, str(c.cities[front].rift["faction"]), "the rift's faction leads")
	var u := b.field.unit_by_id(m.uid)
	assert_true(u != null and u.is_player(), "the machine fights under its roster uid")
	var fitted := 0
	for f in u.die.faces:
		if not f.fixed and not f.component.is_empty():
			fitted += 1
	assert_eq(fitted, before - 1, "it carries the roster's loadout, not the stock one")
	assert_eq(c.start_battle(front, [m.uid]), null, "one battle at a time")


func test_a_won_battle_lifts_the_siege_and_banks_its_salvage() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	c.cities[front].gate = 60
	var b := _battle(c)
	var faction := b.faction
	b.foes_killed = 10
	b.menace_killed = 30
	_end(b, Battle.Outcome.VICTORY)
	var r := c.finish_battle()
	assert_eq(r["result"], "won", "won")
	assert_eq(c.cities[front].gate, Campaign.CITY_GATE, "the gate is restored to full")
	assert_true(c.cities[front].rift.is_empty(), "its rift is closed")
	assert_eq(c.salvage, Campaign.START_SALVAGE + 30 * Campaign.SALVAGE_PER_MENACE, "the salvage banks, by the menace killed")
	assert_eq(int(c.anathema.get(faction, 0)), 30, "and Anathema takes the menace")
	assert_true(c.tokens.has(faction), "the boss drops a research token of its faction")
	assert_true(c.offers.has(front), "the host maker owes an offer")
	assert_eq(c.turn, 1, "the turn ends")
	assert_eq(c.state, Campaign.PICK, "back between battles")


func test_a_closed_rift_leaves_its_city_quiet_for_a_turn() -> void:
	var c := _run()
	# Every other city is taken, so the only free one is the city just won.
	var front := str(c.fronts()[0])
	for city in c.cities.values():
		if not city.capital and city.id != front:
			city.rift = {"faction": "x", "guest": "", "final": false}
	var b := _battle(c, front)
	_end(b, Battle.Outcome.VICTORY)
	c.finish_battle()
	assert_true(c.cities[front].rift.is_empty(), "no rift reopens on the turn it was closed")


func test_a_fallen_gate_loses_the_city_and_the_battles_salvage() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	var b := _battle(c)
	b.foes_killed = 10
	b.field.gate_hp = 0
	_end(b, Battle.Outcome.GATE_FALLEN)
	var r := c.finish_battle()
	assert_eq(r["result"], "fell", "fell")
	assert_true(c.cities[front].fallen, "the city falls")
	assert_eq(c.salvage, Campaign.START_SALVAGE, "the battle's salvage is lost")
	assert_true(not c.fronts().has(front), "a fallen city is no front")
	assert_eq(c.capital().gate, Campaign.CAPITAL_GATE - Campaign.DRAIN * c.fallen_count(), "its horde drains the capital")


func test_a_wipe_lets_the_horde_strike_and_the_city_holds_wounded() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	var b := _battle(c)
	for u in b.mechs():
		_wreck(b, u)
	b.foes_killed = 4
	b.menace_killed = 12
	_end(b, Battle.Outcome.WRECKED)
	var r := c.finish_battle()
	assert_true(r["wiped"], "a wipe")
	assert_eq(r["result"], "held", "the gate held the strikes")
	assert_true(not c.cities[front].fallen, "the city stands")
	assert_true(not c.cities[front].rift.is_empty(), "its rift stays open")
	assert_eq(c.salvage, Campaign.START_SALVAGE + 12 * Campaign.SALVAGE_PER_MENACE, "the salvage was in the city and is kept")
	assert_eq(c.tokens.size(), 0, "no token")
	assert_eq(c.ready_machines().size(), 0, "every machine is in the shop")


func test_a_wipe_on_a_weak_gate_loses_the_city() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	c.cities[front].gate = 10
	var b := _battle(c)
	# A pack standing in front of the gate strikes it in the first phase.
	var gate_o := Hex.axial_to_offset(b.map.gate)
	var at := Hex.offset_to_axial(gate_o.x, gate_o.y - BattleMap.GATE_ROWS)
	for u in b.mechs():
		_wreck(b, u)
	var sq := Unit.pack(0, "strikers", at, b.faction, Unit.PACK_MOVE, 6, "")
	b.field.add_unit(sq)
	_end(b, Battle.Outcome.WRECKED)
	var r := c.finish_battle()
	assert_eq(r["result"], "fell", "the strikes took the gate")
	assert_true(c.cities[front].fallen, "the city falls")


func test_destroyed_components_go_and_fixed_ones_are_rebuilt() -> void:
	var db := ContentDB.load_default()
	var cid := _mixed_chassis(db)
	assert_true(not cid.is_empty(), "the content has a chassis with both kinds")
	var c := Campaign.new(5, [cid])
	var m: Campaign.Machine = c.roster[0]
	var stock: Array = m.loadout.duplicate()
	var fixed_n: int = db.chassis[cid]["fixed"].size()
	var b := _battle(c)
	var u := b.field.unit_by_id(m.uid)
	_destroy(u, 0)                # a fixed component
	_destroy(u, fixed_n)          # the first hardpoint
	_end(b, Battle.Outcome.VICTORY)
	var r := c.finish_battle()
	assert_eq(r["lost"], [stock[0]], "only the destroyed hardpoint component is gone")
	assert_eq(m.loadout, stock.slice(1), "the intact ones are kept")
	var b2 := _battle(c)
	var u2 := b2.field.unit_by_id(m.uid)
	assert_true(u2.die.faces[0].component == str(db.chassis[cid]["fixed"][0]) and u2.die.faces[0].kind != Face.Kind.BLANK, "the fixed component is rebuilt")
	assert_true(u2.die.faces[fixed_n].kind != Face.Kind.BLANK, "the kept hardpoint is whole next battle")


func test_a_wreck_loses_what_was_destroyed_and_sits_out_a_battle() -> void:
	var db := ContentDB.load_default()
	var cid := _mixed_chassis(db)
	var c := Campaign.new(5, [cid, cid])
	var m: Campaign.Machine = c.roster[0]
	var stock: Array = m.loadout.duplicate()
	var fixed_n: int = db.chassis[cid]["fixed"].size()
	var b := _battle(c)
	var u := b.field.unit_by_id(m.uid)
	_destroy(u, fixed_n)
	_wreck(b, u)
	_end(b, Battle.Outcome.VICTORY)
	var r := c.finish_battle()
	assert_eq(r["wrecked"], [m.uid], "reported wrecked")
	assert_eq(m.loadout, stock.slice(1), "its destroyed component is lost as any machine's, the intact ones kept")
	assert_eq(m.shop, Campaign.SHOP_BATTLES, "in the shop")
	assert_true(not c.ready_machines().has(m), "not ready")
	c.pass_turn()
	assert_eq(m.shop, 0, "back after a battle's time")


func test_a_wreck_can_be_rushed_for_salvage() -> void:
	var c := _run()
	var m: Campaign.Machine = c.roster[0]
	m.shop = 1
	c.favour = Campaign.RUSH_PRICE - 1
	assert_false(c.rush(m.uid), "not without the Favour")
	c.favour = Campaign.RUSH_PRICE
	assert_true(c.rush(m.uid), "rushed")
	assert_eq(m.shop, 0, "ready now")
	assert_eq(c.favour, 0, "paid in Favour")
	assert_false(c.rush(m.uid), "a ready machine needs no rush")


func test_the_capitals_gate_is_the_one_priced_repair() -> void:
	var c := _run()
	c.capital().gate = 100
	c.salvage = 30 * Campaign.REPAIR_COST
	assert_eq(c.repair_capital(10 * Campaign.REPAIR_COST), 10 * Campaign.REPAIR_COST, "spends what it is given")
	assert_eq(c.capital().gate, 110, "a point for every REPAIR_COST")
	c.salvage = 1000
	c.repair_capital(1000)
	assert_eq(c.capital().gate, Campaign.CAPITAL_GATE, "never past full")
	assert_true(c.salvage > 0, "and spends no more than full needs")


func test_an_undefended_gate_bleeds_and_falls_unfought() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	var turns := c.turns_to_fall(front)
	for i in range(turns - 1):
		c.pass_turn()
	assert_true(not c.cities[front].fallen, "standing on its last turn")
	assert_eq(c.turns_to_fall(front), 1, "the warning says so")
	c.pass_turn()
	assert_true(c.cities[front].fallen, "fallen, with no battle")


func test_rifts_open_with_the_tier_and_a_guest_joins_from_its_tier() -> void:
	var c := _run()
	c.convergence = Campaign.TIER_EVERY * Campaign.GUEST_TIER - 1
	for city in c.cities.values():
		city.rift = {}
		city.quiet = 0
	c.pass_turn()
	assert_eq(c.tier(), Campaign.GUEST_TIER, "a tier up")
	assert_eq(c.fronts().size(), Campaign.RIFTS_BASE + c.tier(), "one more rift")
	for f in c.fronts():
		var rift: Dictionary = c.cities[f].rift
		assert_true(c.db.factions.has(rift["faction"]), "a lead faction")
		assert_true(c.db.factions.has(rift["guest"]) and rift["guest"] != rift["faction"], "a guest, another faction")


## A rift keeps the tier it opened at (Ryan's form, the curve proposal; 30 October): the card's
## jump never moves under the player, and the battle reads the live Convergence as its ramp,
## the same for every open front.
func test_a_rift_keeps_the_tier_it_opened_at_and_the_battle_reads_the_ramp() -> void:
	var c := _run(7)
	for f in c.fronts():
		assert_eq(int(c.cities[f].rift.get("tier", -1)), 0, "a rift opened at the start carries tier one")
	var front := str(c.fronts()[0])
	c.convergence = 5   # the clock moved on: tier two now
	assert_eq(c.tier(), 1, "the Convergence's tier is two")
	var b := _battle(c, front)
	assert_eq(b.tier, 0, "the battle is fought at the rift's own tier")
	assert_eq(b.ramp, 5, "and at the live Convergence as its ramp")
	assert_eq(b.field.rift_pressure_max, Ramp.timer_at(5), "the timer is the ramp's")
	_end(b, Battle.Outcome.VICTORY)
	c.finish_battle()
	var late := ""
	for f in c.fronts():
		if int(c.cities[f].rift.get("tier", -1)) == 1:
			late = f
	assert_ne(late, "", "a rift opened now carries tier two")
	var d: Dictionary = JSON.parse_string(JSON.stringify(SaveGame.campaign_to_dict(c)))
	var back := SaveGame.campaign_from_dict(d)
	assert_eq(int(back.cities[late].rift.get("tier", -1)), 1, "the rift's tier rides in the save")


func test_a_guests_spawns_join_the_rifts_cycle() -> void:
	var db := ContentDB.load_default()
	var facs: Array = db.factions.keys()
	var b := Battle.new(3)
	b.guest = str(facs[1])
	b.setup([db.make_mech(str(db.default_team()[0]))], str(facs[0]))
	var guest_comps := 0
	for c in b.field.cycle:
		if str(c["faction"]) == str(facs[1]):
			guest_comps += 1
	assert_eq(guest_comps, db.compositions(str(facs[1]), 1, "formation").size() + db.compositions(str(facs[1]), 1, "patrol").size(), "every guest formation and patrol is in the cycle")
	var on_field := 0
	var guests_on_field := 0
	for u in b.field.packs():
		if not u.is_boss:
			on_field += 1
			if u.faction == str(facs[1]):
				guests_on_field += 1
	assert_eq(on_field, Ramp.formations_at(0) + Ramp.patrols_at(0), "the ramp's count: a guest never doubles the field")
	assert_eq(guests_on_field, Ramp.formations_at(0) / 2 + Ramp.patrols_at(0) / 2, "the lead's and the guest's in turn on the field, the lead's first")
	# A guest composition the rift sends wears its own faction.
	b.field.rift_pressure = b.field.rift_pressure_max - 1
	b.field._cycle_index = 2   # the lead's formation, its patrol, then the guest's formation
	b.field.tick_pressure(1)
	var spawned: Unit = b.field.packs()[b.field.packs().size() - 1]
	assert_eq(spawned.faction, str(facs[1]), "the guest's pack is the guest's")
	assert_eq(spawned.composition_size, "formation", "its formation")


func test_the_finale_is_due_at_the_threshold_and_fought_at_the_capital() -> void:
	var c := _run()
	c.convergence = Campaign.FINALE_AT - 1
	c.pass_turn()
	assert_true(c.finale_due(), "due")
	assert_eq(c.fronts(), [c.capital().id], "the capital is the only front")
	var b := _battle(c)
	assert_eq(b.field.gate_hp, c.capital().gate, "fought on what the capital has left")
	_end(b, Battle.Outcome.VICTORY)
	c.finish_battle()
	assert_eq(c.state, Campaign.OVER, "the run is over")
	assert_true(c.won, "won")


func test_a_fallen_city_brings_the_finale_sooner() -> void:
	var c := _run()
	c.convergence = Campaign.FINALE_AT - 1
	assert_false(c.finale_due(), "not yet")
	c.cities[str(c.fronts()[0])].fallen = true
	assert_true(c.finale_due(), "one sooner")


func test_the_capital_at_zero_loses_the_run() -> void:
	var c := _run()
	c.cities[str(c.fronts()[0])].fallen = true
	c.capital().gate = Campaign.DRAIN
	c.pass_turn()
	assert_eq(c.state, Campaign.OVER, "over")
	assert_false(c.won, "lost")


func test_fit_and_strip_move_components_through_the_stock() -> void:
	var c := _run()
	var m: Campaign.Machine = c.roster[0]
	var first := str(m.loadout[0])
	assert_true(c.strip(m.uid, 0), "stripped")
	assert_eq(int(c.components.get(first, 0)), 1, "into the stock")
	assert_true(c.fit(m.uid, first), "fitted back")
	assert_eq(int(c.components.get(first, 0)), 0, "out of the stock")
	assert_false(c.fit(m.uid, first), "nothing left to fit")


## Three bosses a domain before its hero (the bible's section 9, decided 15 October; built 22
## October): a faction's `boss` may be a list, each battle drawing one its domain has not ended on
## this run, any of them once every one has been; a domain with one boss draws nothing from the
## seed; a won battle records its boss, and the save keeps what each domain has ended.
func test_each_battle_draws_a_boss_its_domain_has_not_ended_on_this_run() -> void:
	var c := _run(9)
	var front := str(c.fronts()[0])
	var fid := str(c.cities[front].rift["faction"])
	# A domain with one boss (a copy of the content naming one): drawn as itself, the seed untouched.
	var single := ContentDB.new()
	single.load_dir(ContentDB.DIR)
	single.factions[fid]["boss"] = [str(single.bosses_of(fid)[0])]
	var own := c.db
	c.db = single
	var state := c.rng.state
	assert_eq(c.draw_boss(fid), single.bosses_of(fid)[0], "one boss: drawn as itself")
	assert_eq(c.rng.state, state, "and the seed untouched, so a run plays as it did")
	c.db = own
	# The slate (30 October): the domain's bosses as content lists them, a stand-in last while
	# the domain has fewer than three of its own.
	var db := c.db
	var three: Array = Array(db.bosses_of(fid))
	assert_true(three.size() >= 2, "each domain fields two bosses or more since the slate landed")
	var drawn: Array = []
	for k in range(three.size()):
		var id := c.draw_boss(fid)
		assert_false(drawn.has(id), "never one the domain has ended: %s" % id)
		drawn.append(id)
		c.bosses_ended[fid] = drawn.duplicate()
	assert_true(three.has(c.draw_boss(fid)), "every one ended: any of them")
	c.bosses_ended.clear()
	var b := _battle(c, front)
	assert_eq(b.lineup.size(), 1, "the battle brings one boss")
	assert_true(three.has(str(b.lineup[0])), "one of the domain's")
	var boss := str(b.lineup[0])
	assert_eq(b.boss.display_name, str(db.foes[boss]["name"]).to_lower(), "named after it")
	_end(b, Battle.Outcome.VICTORY)
	c.finish_battle()
	assert_eq(c.bosses_ended.get(fid, []), [boss], "its domain has ended it")
	assert_true(SaveGame.save_campaign(c, TMP), "saved")
	var c2 := SaveGame.load_campaign(TMP)
	assert_eq(c2.bosses_ended.get(fid, []), [boss], "and the save keeps it")
	SaveGame.clear(TMP)


func test_the_run_saves_and_resumes_between_battles_and_mid_battle() -> void:
	var c := _run(9)
	var b := _battle(c)
	b.foes_killed = 3
	_end(b, Battle.Outcome.VICTORY)
	c.finish_battle()
	c.roster[0].shop = 1
	assert_true(SaveGame.save_campaign(c, TMP), "saved between battles")
	var c2 := SaveGame.load_campaign(TMP)
	assert_true(c2 != null, "loaded")
	assert_eq(JSON.stringify(SaveGame.campaign_to_dict(c2)), JSON.stringify(SaveGame.campaign_to_dict(c)), "the same run")
	# Both go on alike: the random stream came back too.
	c.pass_turn()
	c2.pass_turn()
	assert_eq(JSON.stringify(SaveGame.campaign_to_dict(c2)), JSON.stringify(SaveGame.campaign_to_dict(c)), "and plays on the same")
	# Mid-battle, with a wreck on the battle's books.
	var b3 := _battle(c)
	b3.forced = []
	b3.end_turn()
	var wreck: Unit = b3.mechs()[0]
	_wreck(b3, wreck)
	assert_true(SaveGame.save_campaign(c, TMP), "saved mid-battle")
	var c3 := SaveGame.load_campaign(TMP)
	assert_eq(c3.state, Campaign.BATTLE, "still in battle")
	assert_eq(c3.battle.field.phase, b3.field.phase, "at the same phase")
	assert_eq(c3.battle.wrecks.size(), 1, "the wreck kept")
	assert_eq(c3.squad, c.squad, "the same squad")
	_end(c3.battle, Battle.Outcome.VICTORY)
	var r := c3.finish_battle()
	assert_eq(r["wrecked"], [wreck.id], "the resumed battle still knows its wreck")
	SaveGame.clear(TMP)


func test_the_profile_keeps_what_outlives_a_run() -> void:
	var c := _run()
	c.blueprints = ["bp_a"]
	c.won = true
	var p := Profile.new()
	p.absorb(c)
	p.absorb(c)
	assert_eq(p.pool, ["bp_a"], "a find joins the pool once")
	assert_eq(p.tier, 2, "a won run clears a tier")
	assert_eq(p.runs, 2, "runs counted")
	assert_true(p.codex.has(c.roster[0].chassis), "the roster is in the codex")
	assert_true(SaveGame.save_profile(p, TMP_PROFILE), "saved")
	var p2 := SaveGame.load_profile(TMP_PROFILE)
	assert_eq(JSON.stringify(p2.to_dict()), JSON.stringify(p.to_dict()), "loaded alike")
	SaveGame.clear(TMP_PROFILE)


func test_the_bot_plays_a_battle_of_the_run_to_its_end() -> void:
	var c := _run(2)
	var b := _battle(c)
	var bot := BattleBot.make(Policy.GREEDY, 2)
	bot.play(b)
	assert_false(bot.stalled, "the battle ends")
	assert_eq(b.state, Battle.State.DONE, "done")
	assert_true(bot.fights > 0, "it fought")
	var r := c.finish_battle()
	assert_true(["won", "held", "fell"].has(r["result"]), "and the run reads it")


## A machine the bot fields that no volley wrecks (a hull bump the way the runner grants one),
## standing hurt, so a persona's line is already crossed.
func _hurt_tank(db: ContentDB) -> Unit:
	var u := db.make_mech(str(db.default_team(1)[0]))
	u.grant_passive({"id": "test_hull", "name": "Hull", "description": "The test's hull.",
		"effects": [{"trigger": "static", "effect": "add_stat", "stat": "hull", "value": 500}]}, "test")
	u.hull = u.hull_max / 4
	return u


## Park a pack beside a machine so the next fight is at hand: rooted, and pushing unless the
## test wants a hunter.
func _park(b: Battle, sq: Unit, m: Unit, hunting: bool) -> void:
	for n in Hex.neighbors(m.pos):
		if b.field.can_stand(sq, n):
			sq.pos = n
			break
	sq.movespeed = 0
	sq.behaviour = "hunt" if hunting else "push"


## The withdrawing persona on the campaign bot (26 October, the foes' fresh start): a fight the
## player picked is left once the fighters' hull is under the line, the pack keeping its
## survivors, and the bot says so.
func test_the_bots_persona_withdraws_from_a_fight_it_is_losing() -> void:
	var db := ContentDB.load_default()
	var fac := db.default_faction()
	var foe := str(db.spawn_foes(fac, 1)[0])
	var b := Battle.new(4)
	b.with_boss = false
	b.formation = [[foe, 8]]
	var u := _hurt_tank(db)
	b.setup([u], fac)
	var sq: Unit = b.field.packs()[0]
	_park(b, sq, u, false)
	var bot := BattleBot.make(Policy.GREEDY, 4)
	bot.withdraw_below = 50
	bot.take_turn(b)
	assert_eq(bot.fights, 1, "one fight")
	assert_eq(bot.withdrawals, 1, "withdrawn from, under the line")
	assert_eq(bot.fights_won, 0, "so not won")
	assert_true(u.hull > 0 and b.field.units.has(u), "the machine took the volley and stands")
	assert_true(b.field.units.has(sq), "the pack keeps its survivors")
	assert_eq(bot.fight_sizes[0][4], true, "and the fight is marked withdrawn")


## A fight a hunter forced is never withdrawn from: the prey would stay caught and take the
## volley for nothing, so the persona fights it out.
func test_the_bots_persona_fights_out_a_hunters_catch() -> void:
	var db := ContentDB.load_default()
	var fac := db.default_faction()
	var hunter := ""
	for id in db.foes.keys():
		var f: Dictionary = db.foes[id]
		if str(f.get("behaviour", "push")) == "hunt" and not bool(f.get("hero", false)) and not f.has("promotes"):
			hunter = str(id)
			break
	if hunter.is_empty():
		return   # no hunter in content: nothing to force
	var b := Battle.new(4)
	b.with_boss = false
	b.formation = [[hunter, 3]]
	var u := _hurt_tank(db)
	b.setup([u], fac)
	var sq: Unit = b.field.packs()[0]
	_park(b, sq, u, true)
	b.forced = b.field.forced_fights()
	assert_eq(b.forced.size(), 1, "the hunter has caught the machine")
	var bot := BattleBot.make(Policy.GREEDY, 4)
	bot.withdraw_below = 50
	bot.take_turn(b)
	assert_eq(bot.fights, 1, "the catch was fought")
	assert_eq(bot.withdrawals, 0, "and never withdrawn from")
	assert_true(b.forced.is_empty(), "the catch is answered")


func test_the_council_pays_favour_for_a_win_docked_for_gate_damage() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	var b := _battle(c)
	b.field.gate_hp = c.cities[front].gate - 30   # the gate took 30 in the battle
	_end(b, Battle.Outcome.VICTORY)
	var r := c.finish_battle()
	var fee := maxi(0, Campaign.FAVOUR_PER_WIN - 30 * Campaign.FAVOUR_DOCK)
	assert_eq(r["favour"], fee, "the fee, docked for the damage")
	assert_eq(c.favour, Campaign.START_FAVOUR + fee, "paid")
	assert_eq(c.cities[front].gate, Campaign.CITY_GATE, "and the siege is lifted all the same")


func test_a_battle_not_won_pays_no_favour() -> void:
	var c := _run()
	var b := _battle(c)
	for u in b.mechs():
		_wreck(b, u)
	b.foes_killed = 3
	b.menace_killed = 9
	_end(b, Battle.Outcome.WRECKED)
	var r := c.finish_battle()
	assert_eq(r["result"], "held", "the city held")
	assert_eq(r["favour"], 0, "no Favour for a battle not won")
	assert_eq(c.favour, Campaign.START_FAVOUR, "nothing paid")
	assert_true(c.salvage > Campaign.START_SALVAGE, "though its kills keep their salvage")


## The run's Sponsorship tallies (the bible's row): each battle's measures added at its end,
## kept through a save, and read for each maker through the measure its content names.
func test_the_run_tallies_each_makers_sponsorship_measure() -> void:
	var c := _run(9)
	var b := _battle(c)
	b.sponsorship = {"hexes_moved": 12, "guarded": 40, "damaging_spends": 5, "quiet_spends": 2}
	_end(b, Battle.Outcome.VICTORY)
	c.finish_battle()
	assert_eq(int(c.sponsorship["hexes_moved"]), 12, "a battle's hexes")
	var by_maker := c.sponsorship_by_maker()
	for id in c.db.makers.keys():
		var measure := str(c.db.makers[id].get("sponsorship", ""))
		if measure.is_empty():
			assert_false(by_maker.has(id), "a maker that names no measure has none")
		else:
			assert_eq(int(by_maker[id]), int(b.sponsorship[measure]), "%s reads its own measure, %s" % [id, measure])
	assert_true(SaveGame.save_campaign(c, TMP), "saved")
	var c2 := SaveGame.load_campaign(TMP)
	assert_eq(c2.sponsorship, c.sponsorship, "kept through a save")
	SaveGame.clear(TMP)


## The party (the bible's section 9): dealt as the run starts, one hero to each domain from its
## bench, the front jobs and the back as even as the benches allow, the same for the same
## seed, and kept through a save.
func test_the_party_is_dealt_from_the_benches_front_and_back_evenly() -> void:
	var db := ContentDB.load_default()
	var domains: Array = []
	for fid in db.factions.keys():
		if not db.bench_of(str(fid)).is_empty():
			domains.append(str(fid))
	var seen := {}
	for s in range(1, 13):
		var c := _run(s)
		assert_eq(c.party.keys().size(), domains.size(), "a hero for every domain with a bench")
		var back := 0
		for fid in c.party.keys():
			var h := str(c.party[fid])
			assert_true(db.bench_of(str(fid)).has(h), "%s is from its domain's bench" % h)
			back += 1 if str(db.foes[h].get("rank", "front")) == "back" else 0
			seen[h] = true
		assert_true(absi(c.party.size() - 2 * back) <= _evenest_gap(db, domains), "front and back as even as the benches allow")
		assert_eq(c.party, _run(s).party, "the same seed deals the same party")
	assert_true(seen.size() > domains.size(), "the deal varies with the seed")
	var c := _run(9)
	assert_true(SaveGame.save_campaign(c, TMP), "saved")
	assert_eq(SaveGame.load_campaign(TMP).party, c.party, "the deal kept through a save")
	SaveGame.clear(TMP)


## The least front-back gap any deal of one hero a domain allows.
func _evenest_gap(db: ContentDB, domains: Array) -> int:
	var gaps := [0]
	for fid in domains:
		var grown := []
		for g in gaps:
			for h in db.bench_of(fid):
				grown.append(int(g) + (-1 if str(db.foes[h].get("rank", "front")) == "back" else 1))
		gaps = grown
	var best := 1 << 30
	for g in gaps:
		best = mini(best, absi(int(g)))
	return best


## A domain's final (the bible's section 9): fought against its dealt hero with its wildlife in
## the other columns, won when the hero falls, and then the domain is thinned.
func test_a_final_is_fought_against_the_dealt_hero_with_its_wildlife() -> void:
	var c := _run()
	var front := str(c.fronts()[0])
	var fid := str(c.party.keys()[0])
	c.cities[front].rift = {"faction": fid, "guest": "", "final": true}
	var b := _battle(c, front)
	assert_eq(b.boss.lineup, [str(c.party[fid])], "the dealt hero commands the rift")
	assert_eq(b.boss.foe_id, "", "its wildlife unnamed: the tier's own units (26 October)")
	assert_eq(b.boss.strength, b.columns - 1 + ContentDB.escort_at(b.tier), "in the other columns, and the tier's escort")
	var wild := c.db.foes_for(b.boss).filter(func(f) -> bool: return f.escorts)
	assert_eq(wild.size(), b.boss.strength, "unpacked beside the hero")
	for f in wild:
		assert_eq(c.db.faction_of_foe(f.content_id), fid, "its domain's units")
	_end(b, Battle.Outcome.VICTORY)
	var r := c.finish_battle()
	assert_true(r["final"], "the report says it was the final")
	assert_true(c.finals_won.has(fid), "won: the domain is thinned")


## A domain's final is set by its third boss beaten (Ryan, 26 October: "If the final is set,
## then all open rifts should change to show the final as the boss in the mission select"):
## every standing city's rift it leads turns final at once, its dealt hero the boss; a rift it
## guests and a fallen city's stay as they are, and a rift it leads after is dealt final.
func test_a_third_boss_beaten_turns_every_open_rift_its_domain_leads_final() -> void:
	var c := _run()
	var fid := str(c.party.keys()[0])
	var other := ""
	for f in c.db.factions.keys():
		if str(f) != fid:
			other = str(f)
			break
	var ids: Array = []
	for city in c.cities.values():
		if not city.capital:
			ids.append(city.id)
	assert_true(ids.size() >= 4, "four cities around the capital")
	var won_at: String = ids[0]
	var led: String = ids[1]
	var guested: String = ids[2]
	var fallen: String = ids[3]
	c.bosses_beaten[fid] = Campaign.FINAL_AFTER - 1
	c.cities[won_at].rift = {"faction": fid, "guest": "", "final": false}
	c.cities[led].rift = {"faction": fid, "guest": other, "final": false}   # opened before the third boss fell
	c.cities[guested].rift = {"faction": other, "guest": fid, "final": false}
	c.cities[fallen].rift = {"faction": fid, "guest": "", "final": false}
	c.cities[fallen].fallen = true
	c.cities[fallen].gate = 0
	var b := _battle(c, won_at)
	assert_ne(b.boss.lineup, [str(c.party[fid])], "the third is a boss, not the final")
	_end(b, Battle.Outcome.VICTORY)
	var r := c.finish_battle()
	assert_false(r["final"], "the report says it was no final")
	assert_eq(int(c.bosses_beaten[fid]), Campaign.FINAL_AFTER, "the third boss beaten")
	assert_eq(r["finals"], [led], "the report names the rift turned final")
	assert_true(bool(c.cities[led].rift.get("final", false)), "the rift it leads turns final at once")
	assert_eq(str(c.cities[led].rift.get("guest", "")), other, "its guest kept")
	assert_false(bool(c.cities[guested].rift.get("final", false)), "a rift it only guests keeps its own lead's boss")
	assert_false(bool(c.cities[fallen].rift.get("final", false)), "a fallen city's rift stays as it was")
	assert_false(c.finals_won.has(fid), "the domain stands until its final is won")
	var b2 := _battle(c, led)
	assert_eq(b2.boss.lineup, [str(c.party[fid])], "the battle there is its final: the dealt hero commands it")
	var turned := false
	for i in range(80):
		var rift := c._roll_rift()
		if str(rift["faction"]) == fid:
			turned = true
			assert_true(bool(rift["final"]), "a rift it leads after is dealt final")
	assert_true(turned, "and some rift it leads was rolled")


## A beaten domain's other rifts close (Ryan, 26 October: "if a domain gets beat, other rifts
## for that domain should close"): its final won, every standing city whose rift it leads is
## free of it at once, quiet for a turn as a won city is, its gate as it stood (only a win
## restores one) and nothing paid; a rift it only guests keeps it, a fallen city's rift stays as
## it is, and the domain guests no new rift.
func test_a_won_final_closes_its_domains_other_rifts() -> void:
	var c := _run()
	var fid := str(c.party.keys()[0])
	var other := ""
	for f in c.db.factions.keys():
		if str(f) != fid:
			other = str(f)
			break
	var ids: Array = []
	for city in c.cities.values():
		if not city.capital:
			ids.append(city.id)
	assert_true(ids.size() >= 4, "four cities around the capital")
	var won_at: String = ids[0]
	var led: String = ids[1]
	var guested: String = ids[2]
	var fallen: String = ids[3]
	c.cities[won_at].rift = {"faction": fid, "guest": "", "final": true}
	c.cities[led].rift = {"faction": fid, "guest": other, "final": true}   # a second final, opened before the first was won
	c.cities[led].gate = 100
	c.cities[guested].rift = {"faction": other, "guest": fid, "final": false}
	c.cities[fallen].rift = {"faction": fid, "guest": "", "final": false}
	c.cities[fallen].fallen = true
	c.cities[fallen].gate = 0
	var salvage := c.salvage
	var favour := c.favour
	var b := _battle(c, won_at)
	_end(b, Battle.Outcome.VICTORY)
	var r := c.finish_battle()
	assert_true(c.finals_won.has(fid), "the domain is beaten")
	assert_eq(r["closed"], [led], "its other rift closes with its final")
	assert_true(c.cities[led].rift.is_empty(), "no rift reopens there on the turn it closed")
	assert_eq(c.cities[led].gate, 100, "its gate as it stood: neither restored nor bled")
	assert_eq(c.salvage - salvage, int(r["salvage"]), "nothing paid for the closure but the battle's own salvage")
	assert_eq(c.favour - favour, int(r["favour"]), "and its Favour")
	assert_eq(str(c.cities[guested].rift.get("guest", "")), fid, "a rift it only guests keeps it")
	assert_eq(str(c.cities[fallen].rift.get("faction", "")), fid, "a fallen city's rift stays as it was")
	assert_false(c.fronts().has(fallen), "and is no front")
	c.convergence = Campaign.TIER_EVERY * Campaign.GUEST_TIER
	for i in range(60):
		var rift := c._roll_rift()
		assert_true(str(rift["faction"]) != fid and str(rift["guest"]) != fid, "a beaten domain leads and guests no new rift")


## The finale (the bible's section 9): the dealt party promoted, a column a domain, and a domain
## whose final was won leaves its column to a standing domain's boss.
func test_the_finale_is_the_party_promoted_a_beaten_heros_column_to_a_standing_boss() -> void:
	var c := _run()
	var line := c.finale_line()
	var want: Array = []
	for fid in c.db.factions.keys():
		want.append(c.db.promoted_form(str(c.party.get(fid, ""))))
	assert_eq(line, want, "every domain standing: the party, promoted")
	var beaten := str(c.db.factions.keys()[0])
	c.finals_won = [beaten]
	line = c.finale_line()
	var bosses: Array = []
	for fid in c.db.factions.keys():
		if str(fid) != beaten:
			bosses.append_array(c.db.bosses_of(str(fid)))
	assert_true(bosses.has(str(line[0])), "the beaten hero's column goes to a standing domain's boss")
	assert_eq(line.slice(1), want.slice(1), "the rest of the party stands in line")
	c.convergence = Campaign.FINALE_AT - 1
	c.pass_turn()
	var b := _battle(c)
	assert_eq(b.boss.lineup.size(), c.db.factions.size(), "the line at the capital: a column a domain")
	assert_eq(b.boss.display_name, "the party", "and it goes by the party")
	assert_false(bool(c.capital().rift.get("final", true)), "the capital's is the finale, never a final")


## Bosses scale to the battle's tier (Ryan, 25 and 26 October: "scaling stats and upgrading the
## escort", "composed of units from the tier"; ContentDB.BOSS_TIERS): a boss unit's commanders
## take the tier's HP and attack, and it brings more escort, its domain's units of the tier
## round robin, unless the escort is named (a hand-tailored one).
func test_a_boss_unit_stands_at_its_battles_tier() -> void:
	var db := ContentDB.load_default()
	var faction := str(db.factions.keys()[0])
	var boss_id := str(db.bosses_of(faction)[0])
	var units_at := func(t: int) -> Array:
		var out: Array = []
		for e in db.spawn_table(faction, t + 1):
			if not out.has(str(e[0])) and int(db.foes[str(e[0])].get("size", 1)) == 1:
				out.append(str(e[0]))
		return out
	var spawn_foes: Array = units_at.call(2)
	var hp: Array = []
	for t in range(ContentDB.BOSS_TIERS.size()):
		var units: Array = units_at.call(t)
		var b := Battle.new(3)
		b.tier = t
		b.setup([], faction)
		assert_true(b.boss != null, "the boss takes the field")
		assert_eq(b.boss.boss_tier, t, "the unit stands at the battle's tier")
		assert_eq(b.boss.strength, ContentDB.escort_at(t), "tier %d's escort" % (t + 1))
		var foes := db.foes_for(b.boss)
		var cmd: Foe = foes.filter(func(f) -> bool: return f.commands)[0]
		var s := ContentDB.boss_tier(t)
		assert_eq(cmd.hp_max, roundi(int(db.foes[boss_id]["hp"]) * float(s["hp"])), "its HP at the tier")
		assert_eq(cmd.hp, cmd.hp_max, "whole")
		assert_eq(cmd.attack, int(db.foes[boss_id]["attack"]) + int(s["attack"]), "its attack at the tier")
		hp.append(cmd.hp_max)
		var escorts := foes.filter(func(f) -> bool: return f.escorts)
		assert_eq(escorts.size(), ContentDB.escort_at(t), "unpacked beside the boss")
		for i in range(escorts.size()):
			assert_eq(escorts[i].content_id, units[i % units.size()], "its domain's units of the tier, round robin")
			assert_eq(escorts[i].hp_max, int(db.foes[units[i % units.size()]]["hp"]), "the rank and file never inflated")
	assert_true(hp[0] < hp[1] and hp[1] < hp[2], "a harder boss each tier")
	# A named escort is a hand-tailored one, kept whole.
	var named := Battle.new(3)
	named.tier = 2
	named.escort = [spawn_foes[0], 1]
	named.setup([], faction)
	var kept := db.foes_for(named.boss).filter(func(f) -> bool: return f.escorts)
	assert_eq(kept.size(), 1 + ContentDB.escort_at(2), "its own count and the tier's")
	for f in kept:
		assert_eq(f.content_id, spawn_foes[0], "all of the foe it names")
	var c := Campaign.new(5)
	c.convergence = Campaign.TIER_EVERY * 2
	assert_eq(c.tier(), 2, "the Convergence at tier three")
	var front := str(c.fronts()[0])
	c.cities[front].rift["tier"] = c.tier()   # a rift opened now: it carries the tier (locked, 30 October)
	var uids: Array = c.ready_machines().slice(0, 1).map(func(m) -> int: return m.uid)
	var b2 := c.start_battle(front, uids)
	assert_eq(b2.tier, 2, "the campaign hands its tier to the battle")
	assert_eq(b2.boss.boss_tier, 2, "and its boss stands at it")


## A battle fields its domain's spawn list at its tier (the ladder's brief, D3; 28 October): the
## formation on the map is the lead's list at the tier, and the rift's cycle carries it and the
## guest's at the same tier.
func test_a_battle_fields_the_compositions_of_its_tier() -> void:
	var db := ContentDB.load_default()
	var facs: Array = db.factions.keys()
	for t in range(3):
		var b := Battle.new(3)
		b.tier = t
		b.guest = str(facs[1])
		b.setup([db.make_mech(str(db.default_team()[0]))], str(facs[0]))
		var cycle: Array = b.field.cycle.map(func(c) -> String: return str(c["id"]))
		for fid in [facs[0], facs[1]]:
			for c in db.compositions(str(fid), t + 1, "formation") + db.compositions(str(fid), t + 1, "patrol"):
				assert_true(cycle.has(str(c["id"])), "tier %d's %s in the rift's cycle" % [t + 1, str(c["id"])])
		var ids: Array = []
		for fid in [facs[0], facs[1]]:
			ids.append_array((db.compositions(str(fid), t + 1, "formation") + db.compositions(str(fid), t + 1, "patrol")).map(func(c) -> String: return str(c["id"])))
		for u in b.field.packs():
			if not u.is_boss:
				assert_true(ids.has(u.composition), "%s on the field is one of tier %d's compositions, the lead's or the guest's" % [u.composition, t + 1])


## An escort's units are the foes of its domain's spawn list at the battle's tier (the ladder's
## brief, D3, 28 October), else of the highest tier's list under it; a unit's own `tier` decides
## nothing.
func test_an_escort_is_drawn_from_its_tiers_list() -> void:
	var db := ContentDB.new()   # its own copy: a tier's list is dropped below
	db.load_dir(ContentDB.DIR)
	var faction := str(db.factions.keys()[0])
	for t in range(3):
		var units: Array = []
		for e in db.spawn_table(faction, t + 1):
			if not units.has(str(e[0])) and int(db.foes[str(e[0])].get("size", 1)) == 1:
				units.append(str(e[0]))
		var drawn: Array = db.escort_units(faction, t, units.size()).map(func(f) -> String: return f.content_id)
		assert_eq(drawn, units, "tier %d draws its own list, in spawn order" % (t + 1))
	var tier_two: Array = db.spawn_table(faction, 2)
	var comps: Array = db.factions[faction]["compositions"]
	for c in comps:   # tier three's compositions dropped: the tier takes tier two's
		c["tiers"] = (c.get("tiers", [1]) as Array).filter(func(t) -> bool: return int(t) != 3)
	db.factions[faction]["compositions"] = comps.filter(func(c) -> bool: return not (c["tiers"] as Array).is_empty())
	assert_eq(db.spawn_table(faction, 3), tier_two, "a tier with no list takes the highest under it")
	assert_eq(db.escort_units(faction, 2, 1)[0].content_id, str(tier_two[0][0]), "and its escort with it")
	var first: Dictionary = db.foes[str(tier_two[0][0])]
	first["tier"] = 3
	assert_eq(db.escort_units(faction, 1, 1)[0].content_id, str(tier_two[0][0]), "a unit's own tier decides nothing")

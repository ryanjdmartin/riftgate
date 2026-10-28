extends TestCase

## The quick campaign (Ryan, 25 October; the bible's quick campaign row): the draft, a battle's
## fights by tier with the elites folded into the Fractures and the guest from tier two, a fight's
## damage carried with a field recharge and no withdrawal, the boss's fall (the after-battle rule,
## the loot, the token, the offer), the hangar's verbs and the save. Fights are forced to their
## ends here; the bot plays a battle for real once. Content ids come from the content.

const TMP := "user://test_quick_run.json"


## A run past its draft: the first three chassis the draft offers.
func _run(seed_value: int = 5) -> QuickRun:
	var r := QuickRun.new(seed_value)
	r.choose(QuickRun.draft_choices(r.db).slice(0, QuickRun.START_MACHINES))
	return r


## End the open fight the way a skirmish does.
func _end(r: QuickRun, outcome: int) -> Dictionary:
	var sk := r.open_fight()
	sk.outcome = outcome
	sk.state = Skirmish.State.DONE
	return r.finish_fight()


## Move a run to a battle of the given number (1 is the first) at the hangar.
func _at_battle(r: QuickRun, n: int) -> void:
	r.battle = n - 1
	r._roll_battle()
	r.state = QuickRun.HANGAR


func _destroy(u: Unit, idx: int) -> void:
	var d := Face.blank()
	d.component = u.die.faces[idx].component
	u.die.faces[idx] = d


func test_the_draft_is_every_runnable_tier_one_and_takes_three_different() -> void:
	var db := ContentDB.load_default()
	var offered := QuickRun.draft_choices(db)
	assert_true(offered.size() >= QuickRun.START_MACHINES, "enough to pick from")
	for id in offered:
		assert_eq(db.chassis_tier(str(id)), 1, "%s is a tier one" % id)
		assert_true(db.chassis_runnable(str(id)), "%s can be fielded" % id)
	for id in db.chassis_of_tier(1):
		if db.chassis_runnable(str(id)):
			assert_true(offered.has(str(id)), "every runnable tier one is offered: %s" % id)
	var r := QuickRun.new(3)
	assert_eq(r.state, QuickRun.DRAFT, "a run opens on the draft")
	assert_false(r.choose(offered.slice(0, 2)), "two are not enough")
	assert_false(r.choose([offered[0], offered[0], offered[1]]), "three different ones")
	var upper := ""
	for id in db.chassis.keys():
		if db.chassis_tier(str(id)) > 1:
			upper = str(id)
	if not upper.is_empty():
		assert_false(r.choose([offered[0], offered[1], upper]), "a tier two is not in the draft")
	assert_eq(r.state, QuickRun.DRAFT, "a refused pick starts nothing")
	assert_true(r.choose(offered.slice(0, 3)), "three different tier ones start it")
	assert_eq(r.state, QuickRun.HANGAR, "into the hangar, the first battle shown")
	assert_eq(r.roster.size(), 3, "three machines")
	assert_eq(r.squad.size(), 3, "all three in the squad")
	for m in r.roster:
		assert_eq(m.loadout, db.chassis[m.chassis].get("loadout", []), "%s in its stock" % m.chassis)
		assert_true(m.modules.is_empty(), "and no module")
	assert_eq(r.battle, 1, "the first battle")
	assert_eq(r.party, Campaign.deal_party(db, 3), "the party dealt as the campaign deals it")


func test_a_battle_holds_its_fractures_with_the_elites_folded_in() -> void:
	var r := _run()
	for t in range(QuickRun.TOP_TIER + 1):
		_at_battle(r, 1 + t * QuickRun.TIER_EVERY)
		assert_eq(r.tier(), t, "battle %d is tier %d" % [r.battle, t])
		var enc: Array = r.encounters
		assert_eq(enc.size(), QuickRun.FRACTURES[t] + 1, "the Fractures' fights, then the boss")
		var elites := enc.filter(func(e) -> bool: return e["kind"] == "elite").size()
		assert_eq(elites, QuickRun.ELITES[t], "elites folded into the count")
		assert_eq(enc[0]["kind"], "formation", "a formation opens the battle")
		var last: Dictionary = enc[enc.size() - 1]
		if str(last["kind"]) == "final":
			assert_true(t >= QuickRun.FINAL_TIER, "a final closes a battle from tier two")
			assert_eq(str(last["foe"]), str(r.party.get(r.lead, "")), "the lead's dealt hero")
		else:
			assert_eq(last["kind"], "boss", "the boss closes it")
			assert_true(r.db.bosses_of(r.lead).has(str(last["foe"])), "the lead's boss")
		for e in enc:
			if e["kind"] == "elite":
				assert_eq(e["domain"], r.lead, "an elite is the lead's")
				assert_eq(str(e.get("foe", "")), "", "nothing stands in for it until the elites land (Ryan, 27 October)")
				assert_eq(r.encounter_foes(e).size(), r.formation_foes(r.lead).size(), "the lead's formation holds the slot")


func test_the_guest_joins_from_tier_two_and_takes_every_other_formation() -> void:
	for seed_value in range(1, 9):
		var r := _run(seed_value)
		_at_battle(r, 1)
		assert_eq(r.guest, "", "no guest at tier one")
		_at_battle(r, 1 + QuickRun.GUEST_TIER * QuickRun.TIER_EVERY)
		assert_ne(r.guest, "", "a guest from tier two")
		assert_ne(r.guest, r.lead, "another domain")
		var formations: Array = r.encounters.filter(func(e) -> bool: return e["kind"] == "formation")
		for i in range(formations.size()):
			assert_eq(formations[i]["domain"], r.lead if i % 2 == 0 else r.guest, "the lead's and the guest's in turn")
		for e in r.encounters:
			if e["kind"] != "formation":
				assert_eq(e["domain"], r.lead, "the elites and the boss are the lead's")


func test_twelve_battles_then_the_finale_on_the_partys_line() -> void:
	var r := _run()
	for n in range(1, QuickRun.BATTLES + 2):
		_at_battle(r, n)
		assert_eq(r.tier(), mini(QuickRun.TOP_TIER, (n - 1) / QuickRun.TIER_EVERY), "battle %d's tier" % n)
		assert_eq(r.is_finale(), n > QuickRun.BATTLES, "battle %d is the finale or not" % n)
	var last: Dictionary = r.encounters[r.encounters.size() - 1]
	assert_eq(last["kind"], "finale", "the finale's last fight")
	var line: Array = last["line"]
	assert_eq(line.size(), r.party.size(), "a column a domain, drawn as the finale is rolled")
	var foes: Array = r.encounter_foes(last)
	assert_eq(foes.size(), line.size() + ContentDB.escort_at(r.tier()), "the line, then the tier's escort")
	for i in range(line.size()):
		assert_eq(foes[i].size, 2, "every one promoted, massive")


func test_a_final_may_close_a_battle_from_tier_two_and_leaves_the_finales_line() -> void:
	# Ryan, 25 October: "finale bosses can just appear as a random boss in tier 2 or 3".
	var finals := 0
	for seed_value in range(1, 13):
		var r := _run(seed_value)
		_at_battle(r, 1)
		assert_ne(r.encounters[r.encounters.size() - 1]["kind"], "final", "never at tier one")
		_at_battle(r, 1 + QuickRun.FINAL_TIER * QuickRun.TIER_EVERY)
		if r.encounters[r.encounters.size() - 1]["kind"] == "final":
			finals += 1
	assert_true(finals > 0, "a final turns up as a boss from tier two (%d of 12)" % finals)
	# Its bosses beaten, a domain's next boss fight is its final while its hero stands.
	var r := _run(4)
	_at_battle(r, 1 + QuickRun.FINAL_TIER * QuickRun.TIER_EVERY)
	r.bosses_ended[r.lead] = Array(r.db.bosses_of(r.lead))
	var enc := r._boss_encounter(r.tier())
	assert_eq(enc["kind"], "final", "the final, the bosses all beaten")
	assert_eq(str(enc["foe"]), str(r.party[r.lead]), "the lead's dealt hero")
	var foes: Array = r.encounter_foes(enc)
	assert_true(foes[0].hero and foes[0].size == 1, "the hero leads, human-sized")
	assert_eq(foes.size(), 1 + r.formation_foes(r.lead).size() + ContentDB.escort_at(r.tier()), "its formation and the tier's escort beside it")
	# Won, the hero leaves the finale's line for boss-tier wildlife of a standing domain.
	r.encounters[r.encounters.size() - 1] = enc
	r.start_battle()
	for i in range(r.encounters.size()):
		_end(r, Skirmish.Outcome.VICTORY)
	assert_true(r.finals_won.has(r.history[0]["lead"]), "the final counts as won")
	var won_domain := str(r.history[0]["lead"])
	var line := r.finale_line()
	assert_eq(line.size(), r.party.size(), "still a column a domain")
	assert_false(line.has(r.db.promoted_form(str(r.party[won_domain]))), "the beaten hero is gone from the line")
	var promoted := 0
	for fid in line:
		if r.db.foes[str(fid)].has("promotes"):
			promoted += 1
	assert_eq(promoted, r.party.size() - 1, "the others still promoted")
	var r2 := _run(4)
	_at_battle(r2, 1 + QuickRun.FINAL_TIER * QuickRun.TIER_EVERY)
	r2.bosses_ended[r2.lead] = Array(r2.db.bosses_of(r2.lead))
	r2.finals_won.append(r2.lead)
	assert_eq(r2._boss_encounter(r2.tier())["kind"], "boss", "a won final never comes back: a boss again")


func test_a_boss_brings_the_tiers_escort() -> void:
	var r := _run(6)
	var counts: Array = []
	for t in range(QuickRun.TOP_TIER + 1):
		_at_battle(r, 1 + t * QuickRun.TIER_EVERY)
		var boss := {"kind": "boss", "domain": r.lead, "foe": r.draw_boss(r.lead)}
		var foes: Array = r.encounter_foes(boss)
		var n: int = foes.size() - 1 - r.formation_foes(r.lead).size()
		assert_eq(n, ContentDB.escort_at(t), "tier %d's escort beside the formation" % (t + 1))
		counts.append(n)
		var content: Dictionary = r.db.foes[str(boss["foe"])]
		assert_eq(foes[0].hp_max, roundi(int(content["hp"]) * float(ContentDB.boss_tier(t)["hp"])), "the boss's HP at the tier")
		assert_eq(foes[0].attack, int(content["attack"]) + int(ContentDB.boss_tier(t)["attack"]), "its attack at the tier")
	assert_true(counts[0] < counts[2], "more at tier three than at tier one")
	for e in r.encounters:
		if e["kind"] == "formation" or e["kind"] == "elite":
			var plain: int = r.encounter_foes(e).size()
			assert_eq(plain, r.formation_foes(str(e["domain"])).size(), "no escort outside a boss fight, and no stand-in in an elite's slot")


func test_a_fight_carries_its_damage_recharges_a_field_turn_and_never_withdraws() -> void:
	var r := _run()
	assert_true(r.start_battle(), "into the battle")
	assert_eq(r.state, QuickRun.BATTLE, "a battle under way")
	var sk := r.open_fight()
	assert_true(sk.committed, "no withdrawal in the quick campaign")
	sk.begin()
	assert_false(sk.can_withdraw(), "so none is open")
	assert_eq(sk.mechs.size(), r.squad.size(), "the whole squad fights")
	var u: Unit = r.units[0]
	u.hull = u.hull_max - 5
	u.shield = 0
	sk.outcome = Skirmish.Outcome.VICTORY
	sk.state = Skirmish.State.DONE
	var rep := r.finish_fight()
	assert_true(rep["won"], "won")
	assert_eq(r.fight, 1, "on to the next encounter")
	assert_eq(r.units[0], u, "the same machine fights on")
	assert_eq(u.hull, u.hull_max - 5, "its hull not mended")
	assert_eq(u.shield, mini(u.shield_max, u.recharge_field), "one field recharge since")
	# A wreck sits the rest of the battle out.
	u.hull = 0
	var next := r.open_fight()
	assert_eq(next.mechs.size(), r.squad.size() - 1, "the wreck stays out of the next fight")


func test_a_wipe_ends_the_run_where_it_fell() -> void:
	var r := _run()
	r.start_battle()
	_end(r, Skirmish.Outcome.VICTORY)
	var rep := _end(r, Skirmish.Outcome.DEFEAT)
	assert_false(rep["won"], "lost")
	assert_eq(r.state, QuickRun.OVER, "the run is over")
	assert_false(r.won, "lost")
	assert_eq(r.lost_at["battle"], 1, "in the first battle")
	assert_eq(r.lost_at["fight"], 1, "at its second fight")
	assert_eq(r.history.size(), 1, "the battle reported")


func test_the_boss_falling_mends_the_squad_and_owes_the_rewards() -> void:
	var r := _run()
	r.start_battle()
	var a: Unit = r.units[0]
	var b: Unit = r.units[1]
	var ma: QuickRun.Machine = r.machine(a.id)
	var mb: QuickRun.Machine = r.machine(b.id)
	var fixed_a: int = r.db.chassis[ma.chassis].get("fixed", []).size()
	assert_true(ma.loadout.size() >= 1 and mb.loadout.size() >= 1, "both carry a hardpoint piece")
	var gone := str(ma.loadout[0])
	_destroy(a, fixed_a)
	b.hull = 0
	var fights := r.encounters.size()
	for i in range(fights):
		_end(r, Skirmish.Outcome.VICTORY)
	assert_eq(r.state, QuickRun.REWARDS, "the boss is down: the rewards")
	assert_true(r.units.is_empty(), "the battle's machines are let go: the next is made whole")
	var stock_a: Array = r.db.chassis[ma.chassis].get("loadout", [])
	var stock_b: Array = r.db.chassis[mb.chassis].get("loadout", [])
	assert_eq(ma.loadout.size(), stock_a.size() - 1, "a destroyed piece is gone")
	assert_eq(ma.loadout.count(gone), stock_a.count(gone) - 1, "the destroyed one")
	assert_eq(mb.loadout, stock_b, "a wreck loses only what was destroyed, here nothing")
	assert_eq(r.squad.size(), 3, "the wreck stays in the squad, mended (no shop)")
	var kinds: Array = r.rewards.map(func(x) -> String: return x["kind"])
	assert_eq(kinds.count("loot"), fights - 1, "a loot pick for every fight before the boss")
	assert_eq(kinds[kinds.size() - 2], "token", "then the token")
	assert_eq(kinds[kinds.size() - 1], "offer", "then the offer")
	for reward in r.rewards:
		assert_true(reward["choices"].size() >= 1 and reward["choices"].size() <= QuickRun.CHOICES, "one of up to three")
	assert_eq(r.history[0]["won"], true, "the battle won")
	assert_true(r.bosses_ended.has(str(r.history[0]["lead"])), "its boss marked beaten")


func test_the_loot_and_the_token_follow_the_tier() -> void:
	var r := _run(7)
	_at_battle(r, 1)
	for i in range(20):
		for it in r._loot_choices():
			var t: int = r.db.component_tier(it["id"]) if it["kind"] == "component" else int(r.db.modules[it["id"]]["tier"])
			assert_eq(t, 1, "tier one's loot is tier one")
	for battle_tier in range(QuickRun.TOP_TIER + 1):
		_at_battle(r, 1 + battle_tier * QuickRun.TIER_EVERY)
		var token: Array = r._token_choices()
		assert_eq(token.size(), QuickRun.CHOICES, "a choice of three at tier %d" % (battle_tier + 1))
		var comps: Array = r.pool(battle_tier + 1).filter(func(it) -> bool: return it["kind"] == "component")
		var shown := 0
		for it in token:
			if it["kind"] == "component":
				shown += 1
				assert_eq(r.db.component_tier(it["id"]), battle_tier + 1, "the token's components at the battle's tier")
			else:
				assert_eq(int(r.db.modules[it["id"]]["tier"]), battle_tier + 1, "a module fills a thin tier")
		assert_eq(shown, mini(QuickRun.CHOICES, comps.size()), "components first, all the tier holds")
	for i in range(30):
		for it in r._loot_choices():
			var t: int = r.db.component_tier(it["id"]) if it["kind"] == "component" else int(r.db.modules[it["id"]]["tier"])
			assert_true(t >= 1 and t <= 3, "loot of tiers one to three")
			if it["kind"] == "component":
				assert_false(r.db.is_fixed(it["id"]), "never a locked piece")
				assert_ne(t, 0, "never a basic")


func test_the_offer_is_one_makers_its_chassis_at_or_under_the_tier() -> void:
	var r := _run(11)
	for n in [1, 1 + QuickRun.TIER_EVERY, 1 + 2 * QuickRun.TIER_EVERY]:
		_at_battle(r, n)
		var shown := r.tier() + 1
		for mk in r.db.makers.keys():
			for it in r._offer_choices(str(mk)):
				match str(it["kind"]):
					"chassis":
						var c: Dictionary = r.db.chassis[it["id"]]
						assert_eq(str(c["maker"]), str(mk), "the maker's own chassis")
						assert_true(int(c["tier"]) <= shown, "at or under the battle's tier")
						assert_true(r.db.chassis_runnable(it["id"]), "one the engine fields")
						assert_false(r.roster.any(func(m) -> bool: return m.chassis == it["id"]), "one the roster does not hold")
					"component":
						assert_eq(str(r.db.components[it["id"]]["maker"]), str(mk), "the maker's own piece")
						assert_true(r.db.component_tier(it["id"]) <= shown and r.db.component_tier(it["id"]) >= 1, "at or under the tier, never a basic")
					"module":
						assert_eq(str(r.db.modules[it["id"]]["maker"]), str(mk), "the maker's own module")
						assert_true(int(r.db.modules[it["id"]]["tier"]) <= shown, "at or under the tier")
	_at_battle(r, 1 + 2 * QuickRun.TIER_EVERY)
	var any_upper := false
	for mk in r.db.makers.keys():
		for it in r._offer_choices(str(mk)):
			if it["kind"] == "chassis" and r.db.chassis_tier(it["id"]) > 1:
				any_upper = true
	assert_true(any_upper, "a late offer can bring an upper-tier chassis (every maker, the capital's too)")


func test_taking_the_rewards_stocks_them_and_opens_the_hangar_on_the_next_battle() -> void:
	var r := _run()
	r.start_battle()
	for i in range(r.encounters.size()):
		_end(r, Skirmish.Outcome.VICTORY)
	var owed := r.rewards.size()
	var stocked := 0
	while r.state == QuickRun.REWARDS:
		var reward: Dictionary = r.rewards[0]
		var pick := 0
		for i in range(reward["choices"].size()):
			if reward["choices"][i]["kind"] == "chassis":
				pick = i
		var item: Dictionary = reward["choices"][pick]
		var before_roster := r.roster.size()
		assert_true(r.take(pick), "taken")
		if item["kind"] == "chassis":
			assert_eq(r.roster.size(), before_roster + 1, "a chassis joins the roster")
			assert_eq(r.roster[r.roster.size() - 1].loadout, r.db.chassis[item["id"]].get("loadout", []), "in its stock")
			assert_true(r.squad.has(r.roster[r.roster.size() - 1].uid), "and the squad, which had room")
		elif item["kind"] == "component":
			assert_true(int(r.components.get(item["id"], 0)) >= 1, "a piece goes to the stores")
		else:
			assert_true(int(r.modules.get(item["id"], 0)) >= 1, "a module goes to the stores")
		stocked += 1
	assert_eq(stocked, owed, "every reward taken once")
	assert_eq(r.state, QuickRun.HANGAR, "the hangar")
	assert_eq(r.battle, 2, "the next battle shown")
	assert_false(r.take(0), "nothing more owed")


func test_the_hangar_fits_from_the_stores_and_the_basics_are_free() -> void:
	var r := _run()
	var m: QuickRun.Machine = r.roster[0]
	var piece := ""
	for it in r.pool(1):
		if it["kind"] == "component":
			piece = it["id"]
			break
	var basic := str(r.db.starting_blueprints()[0])
	var old := str(m.loadout[0])
	assert_false(r.fit(m.uid, 0, piece), "nothing in the stores to fit")
	r.components[piece] = 1
	assert_true(r.fit(m.uid, 0, piece), "a stored piece fits")
	assert_eq(m.loadout[0], piece, "on that hardpoint")
	assert_false(r.components.has(piece), "out of the stores")
	assert_eq(int(r.components.get(old, 0)), 0 if r.is_basic(old) else 1, "the piece it replaced back in the stores, unless a basic")
	assert_true(r.fit(m.uid, 0, basic), "a basic fits without stores")
	assert_eq(int(r.components.get(piece, 0)), 1, "the stored piece back again")
	var size_before := m.loadout.size()
	assert_true(r.fit(m.uid, 0, ""), "a hardpoint stripped")
	assert_eq(m.loadout.size(), size_before - 1, "one fewer fitted")
	assert_false(r.fit(m.uid, r.hardpoints(m), basic), "no hardpoint past the chassis's")
	var mid := str(r.db.modules.keys()[0])
	assert_false(r.fit_module(m.uid, 0, mid), "no module in the stores")
	r.modules[mid] = 2
	assert_true(r.fit_module(m.uid, 0, mid), "a module in a slot")
	assert_true(r.fit_module(m.uid, 1, mid), "the same module twice")
	assert_false(r.fit_module(m.uid, r.module_slots(m), mid), "no slot past the chassis's")
	assert_true(r.fit_module(m.uid, 0, ""), "a slot emptied")
	assert_eq(int(r.modules.get(mid, 0)), 1, "back in the stores")
	assert_false(r.set_squad([]), "a squad has someone in it")
	assert_false(r.set_squad([m.uid, m.uid]), "each machine once")
	assert_true(r.set_squad([m.uid]), "one machine may go alone")
	r.start_battle()
	assert_false(r.fit(m.uid, 0, basic), "no refit while a battle is on")
	assert_eq(r.units[0].modules.size(), 1, "the battle's machine wears its module")


func test_a_run_saves_and_resumes_mid_fight_alike() -> void:
	var r := _run(9)
	r.components[str(r.pool(2)[0]["id"])] = 1
	r.finals_won.append(str(r.db.factions.keys()[0]))
	r.start_battle()
	_end(r, Skirmish.Outcome.VICTORY)
	var sk := r.open_fight()
	sk.begin()
	sk.start_round()
	var pol := Policy.make(Policy.GREEDY, 3)
	pol.play_round(sk)
	if sk.outcome == Skirmish.Outcome.NONE:
		sk.end_round()
	assert_true(SaveGame.save_quick(r, TMP), "written")
	var back := SaveGame.load_quick(TMP)
	assert_true(back != null, "read back")
	assert_eq(back.state, r.state, "the state")
	assert_eq(back.battle, r.battle, "the battle")
	assert_eq(back.fight, r.fight, "the fight")
	assert_eq(back.encounters, r.encounters, "its encounters")
	assert_eq(back.squad, r.squad, "the squad")
	assert_eq(back.components, r.components, "the stores")
	assert_eq(back.party, r.party, "the party")
	assert_eq(back.finals_won, r.finals_won, "the finals won")
	assert_eq(back.rng.state, r.rng.state, "the run's random stream")
	assert_true(back.current != null, "the fight came back")
	assert_true(back.current.committed, "still without withdrawal")
	for i in range(r.units.size()):
		assert_eq(back.units[i].hull, r.units[i].hull, "a machine's hull")
		assert_eq(back.units[i].shield, r.units[i].shield, "its shield")
	for ms in back.current.mechs:
		assert_true(back.units.has(ms.unit), "the fight's machines are the run's")
	# Both play on the same: the fight, then the run.
	var pa := Policy.make(Policy.GREEDY, 21)
	var pb := Policy.make(Policy.GREEDY, 21)
	for pair in [[pa, r.current], [pb, back.current]]:
		var p: Policy = pair[0]
		var s: Skirmish = pair[1]
		if s.outcome == Skirmish.Outcome.NONE:
			p.play(s)
	assert_eq(back.current.outcome, r.current.outcome, "the same outcome")
	assert_eq(back.current.round, r.current.round, "in the same round")
	var ra := r.finish_fight()
	var rb := back.finish_fight()
	assert_eq(rb["won"], ra["won"], "the run takes it alike")
	assert_eq(back.state, r.state, "and stands alike")
	SaveGame.clear(TMP)
	assert_true(SaveGame.load_quick(TMP) == null, "cleared")


func test_the_bot_plays_a_battle_to_its_end() -> void:
	var r := _run(4)
	r.start_battle()
	var guard := 0
	while r.state == QuickRun.BATTLE and guard < 16:
		guard += 1
		var sk := r.open_fight()
		sk.begin()
		var pol := Policy.make(Policy.GREEDY, guard)
		pol.play(sk)
		assert_false(pol.stalled, "the fight ends")
		r.finish_fight()
	assert_true(r.state == QuickRun.REWARDS or r.state == QuickRun.OVER, "won with rewards owed, or lost")
	assert_eq(r.history.size(), 1, "the battle reported")

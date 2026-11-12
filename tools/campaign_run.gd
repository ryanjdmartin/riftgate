extends SceneTree

## The campaign runner: plays whole runs headless (`Campaign`, `BattleBot`, `Policy`) and
## measures the campaign's placeholders against play. Writes docs/campaign_run.md and
## prints it.
##   perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/campaign_run.gd -- --runs 40
## Options: --runs N (40), --seed S (1, the first run's seed), --policy greedy|random,
## --shape KIND (every battle on that map shape, a key of BattleMap.KINDS; by default each
## battle's seed draws one), --out path (docs/campaign_run.md), --trace SEED (print one run
## battle by battle), --refit SPEC (the refit pass's what-ifs laid over the content, sim/refit.gd,
## as tools/balance.gd takes it: "regen=half|N", "cooling=N", "hotter=N", "barrier=cooldownN|heatN"), --injury
## on|N (the injury rule on for the runs, off in the game since 9 November). The squad-as-one rule
## (--solo before it) and the turtle and detaching
## personas went with the long wall brief: the map is the defence rule (BattleBot).
##
## The player it stands in for is plain: it defends the front nearest to falling (the
## finale's capital once due) with every ready machine, rushes a wreck out of the shop with
## Favour only when nobody is ready, passes the turn when it cannot rush, and puts all its
## salvage into the capital's gate. On the map it plays the defence rule (BattleBot): every
## machine onto the pack it can reach that reaches the wall soonest.
## Its starting team is three of the run's tender at random (the draft, 7 October). Nothing
## yet brings anything in (offers, research, building are not built), so a run is the
## starting team and what it loses: the loss rate with no inflow, which is the number
## destroyed-is-gone waits on (bible section 10, the numbers row).

const OUT := "res://docs/campaign_run.md"

var runs := 40
var first_seed := 1
var policy := Policy.GREEDY
var shape := ""
var out_path := OUT
var trace := 0
var refit_spec := ""                  # --refit: the refit pass's what-if (sim/refit.gd), as tools/balance.gd takes it
var refit_notes: Array[String] = []
var guard_weight := 1.0               # --guard: a block's worth to the fight bot, as a share (Policy.guard_weight)


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var a: String = args[i]
		var v: String = args[i + 1] if i + 1 < args.size() else ""
		match a:
			"--runs":
				runs = int(v)
			"--seed":
				first_seed = int(v)
			"--policy":
				policy = Policy.RANDOM if v == "random" else Policy.GREEDY
			"--shape":
				shape = v
			"--out":
				out_path = v
			"--trace":
				trace = int(v)
			"--refit":
				refit_spec = v
			"--guard":
				guard_weight = clampf(float(v), 0.0, 1.0)
			"--injury":
				Skirmish.injuries = v != "off"
				if v.is_valid_int():
					Skirmish.injury_pct = clampi(int(v), 1, 100)
		i += 2
	if not refit_spec.is_empty():
		# The refit pass's what-if (sim/refit.gd) over the content every run of this process deals
		# from: the campaign reads the one loaded copy (ContentDB.load_default).
		refit_notes = Refit.apply(ContentDB.load_default(), Refit.parse(refit_spec))
	if not shape.is_empty() and not BattleMap.KINDS.has(shape):
		push_error("no such map shape: %s (%s)" % [shape, ", ".join(BattleMap.KINDS.keys())])
		quit(1)
		return
	if trace != 0:
		var r := play_run(trace, true)
		print("run %d: %s after %d turns, %d battles" % [trace, "won" if r["won"] else "lost", r["turns"], r["reports"].size()])
	else:
		var text := report()
		print(text)
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		f.store_string(text)
		f.close()
	quit()


## One run, played to its end. Returns {"won", "turns", "reports", "passes", "rushes",
## "stalled", "capital", "salvage", "fallen", "first_fall", "finale", "ms", "fights"}.
func play_run(seed_value: int, verbose: bool = false) -> Dictionary:
	var t0 := Time.get_ticks_msec()
	var c := Campaign.new(seed_value)
	c.map_kind = shape
	var team: Array = []
	for m in c.roster:
		team.append(m.chassis)
	var out := {"team": team, "won": false, "turns": 0, "reports": [], "passes": 0, "rushes": 0, "stalled": 0,
		"first_fall": -1, "finale": false, "fights": 0, "spends": {}, "fight_sizes": [], "party": c.party.duplicate()}
	var guard := 0
	while c.state != Campaign.OVER and guard < 200:
		guard += 1
		var ready := c.ready_machines()
		if ready.is_empty():
			var rushed := false
			for m in c.roster:
				if m.shop > 0 and c.rush(m.uid):
					rushed = true
					out["rushes"] += 1
					break
			if not rushed:
				if c.pass_turn():
					out["passes"] += 1
					if verbose:
						print("turn %d: nobody ready, passed" % c.turn)
				else:
					c.forfeit_finale()   # the finale cannot be passed (8 November): nobody to field it, the capital falls
					out["forfeits"] = int(out.get("forfeits", 0)) + 1
					if verbose:
						print("turn %d: nobody ready at the finale, the capital falls" % c.turn)
				continue
			ready = c.ready_machines()
		var fronts := c.fronts()
		if fronts.is_empty():
			c.pass_turn()
			out["passes"] += 1
			continue
		var city := _most_urgent(c, fronts)
		var uids: Array = []
		for m in ready.slice(0, Campaign.SQUAD):
			uids.append(m.uid)
		var b := c.start_battle(city, uids)
		if b == null:
			c.pass_turn()
			out["passes"] += 1
			continue
		var gate_before: int = c.cities[city].gate
		var bot := BattleBot.make(policy, seed_value * 1000 + c.turn)
		bot.guard_weight = guard_weight
		bot.play(b)
		out["fights"] += bot.fights
		out["fight_sizes"].append_array(bot.fight_sizes)
		for cid in bot.spends.keys():
			out["spends"][cid] = int(out["spends"].get(cid, 0)) + int(bot.spends[cid])
		if bot.stalled:
			out["stalled"] += 1
			if verbose:
				print("turn %d: the battle at %s stalled after %d phases; the run is abandoned" % [c.turn, city, bot.phases])
			break
		var tier := c.tier()
		var hero := str(c.party.get(b.faction, "")) if bool(c.cities[city].rift.get("final", false)) else ""
		var r := c.finish_battle()
		r["tier"] = tier
		r["hero"] = hero
		r["squad"] = uids.size()
		r["gate_damage"] = maxi(0, gate_before - int(r["gate_left"]))
		r["ratios"] = bot.ratios.duplicate()   # the pressure ratio as each turn opened (the long wall brief, section 5)
		r["stalemates"] = bot.stalemates
		r["stalled_fights"] = bot.stalled_fights
		r["field"] = "%d by %d" % [b.map.width, b.map.height]
		out["reports"].append(r)
		if r["result"] == "fell" and int(out["first_fall"]) < 0:
			out["first_fall"] = int(r["turn"])
		if r["city"] == c.db.capital_maker():
			out["finale"] = true
		if verbose:
			print("turn %d, Convergence %d: %s at %s (%s%s), %s, gate %d left, %d machines, lost %s, wrecked %s, salvage +%d; capital %d" % [
				int(r["turn"]), c.convergence, "won" if r["result"] == "won" else r["result"], r["city"], r["faction"],
				(" + " + str(r["guest"])) if str(r["guest"]) != "" else "", "wiped" if r["wiped"] else "standing",
				int(r["gate_left"]), uids.size(), str(r["lost"]), str(r["wrecked"]), int(r["salvage"]), c.capital().gate])
		# Everything above one rush goes on the capital's gate.
		# Salvage goes into the capital's gate (nothing else can be built yet); Favour waits for
		# rushes.
		if c.state == Campaign.PICK and c.salvage > 0:
			c.repair_capital(c.salvage)
	out["won"] = c.won
	out["turns"] = c.turn
	out["capital"] = c.capital().gate
	out["salvage"] = c.salvage
	out["favour"] = c.favour
	out["fallen"] = c.fallen_count()
	out["kit"] = _kit(c)
	out["ms"] = Time.get_ticks_msec() - t0
	return out


func _most_urgent(c: Campaign, fronts: Array) -> String:
	var best := str(fronts[0])
	var best_t := 1 << 30
	for f in fronts:
		var t := c.turns_to_fall(str(f))
		if t < 0:
			return str(f)   # the capital: nothing else is a front then
		if t < best_t:
			best = str(f)
			best_t = t
	return best


## Hardpoint components still fitted across the roster, and hardpoints in all.
func _kit(c: Campaign) -> Array:
	var fitted := 0
	var slots := 0
	for m in c.roster:
		fitted += m.loadout.size()
		slots += int(c.db.chassis[m.chassis].get("hardpoints", 0))
	return [fitted, slots]


func report() -> String:
	var t0 := Time.get_ticks_msec()
	var results: Array = []
	for s in range(first_seed, first_seed + runs):
		results.append(play_run(s))
	var secs := (Time.get_ticks_msec() - t0) / 1000.0
	var db := ContentDB.load_default()
	var L: Array[String] = []
	L.append("# Campaign run")
	L.append("")
	var fields := {}
	for r in results:
		for rep in r["reports"]:
			fields[str(rep.get("field", "?"))] = true
	L.append("Generated by `tools/campaign_run.gd` on %s: %d runs from seed %d in %.0f s, the %s rung, %s, each run starting with %d machines of its tender at random (the draft), on a field of %s hexes (the wall's length by the depth: Ramp.wall_length_at, Ramp.depth_at). Do not edit by hand." % [
		Time.get_date_string_from_system(), runs, first_seed, secs, Policy.kind_name(policy),
		("every battle on the %s map" % shape) if not shape.is_empty() else "each battle's map shape drawn by its seed",
		Campaign.START_MACHINES, ", ".join(fields.keys())])
	L.append("")
	L.append("The injury rule: %s.%s" % ["on, at %d%% of maximum hull" % Skirmish.injury_pct if Skirmish.injuries else "off, as the game plays it",
		"" if refit_notes.is_empty() else " The refit what-if (`--refit %s`): %s." % [refit_spec, "; ".join(refit_notes)]]
		+ ("" if guard_weight == 1.0 else " The fight bot's habit (`--guard`): a block at %d%% of its worth, the aggressor, which never rerolls for one." % int(round(guard_weight * 100.0))))
	L.append("")
	L.append("Every number the campaign uses is a placeholder (`sim/campaign.gd`); this measures them against a plain player, it does not tune them. Nothing brings anything in yet (offers, research and building are not built), so every run is its starting team (three of its tender at random) and what it loses. The player defends the front nearest to falling with every ready machine, rushes a wreck with Favour only when nobody is ready, and puts all its salvage into the capital's gate; on the map it plays the defence rule (the long wall brief, section 5): a hunter's catch first, then every machine onto the pack it can stand beside that reaches the wall soonest, ties by the larger threat rating and then the nearer, a machine with no pack in reach taking a cache its move reaches (the nearest, the higher kind on a tie) and the rest walking toward the pack that reaches the wall soonest, never the sealed boss, every fight fought out. Read the bands.")
	L.append("")
	# The runs.
	var won := 0
	var lengths: Array[float] = []
	var fallen: Array[float] = []
	var first_falls: Array[float] = []
	var capitals: Array[float] = []
	var finales := 0
	var stalled := 0
	var passes := 0
	var rushes := 0
	var fights_all := 0
	var kit_left: Array[float] = []
	for r in results:
		if r["won"]:
			won += 1
		fights_all += int(r["fights"])
		lengths.append(float(r["turns"]))
		fallen.append(float(r["fallen"]))
		if int(r["first_fall"]) >= 0:
			first_falls.append(float(r["first_fall"]))
		capitals.append(float(r["capital"]))
		if r["finale"]:
			finales += 1
		stalled += int(r["stalled"])
		passes += int(r["passes"])
		rushes += int(r["rushes"])
		var kit: Array = r["kit"]
		kit_left.append(100.0 * float(kit[0]) / maxf(1.0, float(kit[1])))
	L.append("## The runs")
	L.append("")
	L.append("| Measure | Mean | Range |")
	L.append("|---|---|---|")
	L.append("| Runs won | %d of %d | |" % [won, runs])
	L.append("| Runs that reached the finale | %d of %d | |" % [finales, runs])
	L.append("| Turns a run | %s |" % _band(lengths))
	L.append("| Cities fallen a run | %s |" % _band(fallen))
	L.append("| The turn the first city fell | %s |" % _band(first_falls))
	L.append("| The capital's gate at the end, of %d | %s |" % [Campaign.CAPITAL_GATE, _band(capitals)])
	L.append("| Hardpoints still filled at the end, percent | %s |" % _band(kit_left))
	L.append("| Turns passed with nobody ready | %d in all | |" % passes)
	L.append("| Wrecks rushed | %d in all | |" % rushes)
	L.append("| Battles the bot could not finish (run abandoned) | %d | |" % stalled)
	L.append("")
	# Who started: each tier-one machine, the runs it started and how many of those were won.
	L.append("Who started the runs (the draft's pick here is random, so this is coverage, not a preference):")
	L.append("")
	L.append("| Machine | Runs started | Won |")
	L.append("|---|---|---|")
	for id in db.chassis_of_tier(1):
		if not db.chassis_runnable(str(id)):
			continue   # a planned draft is never dealt
		var started := 0
		var won_with := 0
		for r in results:
			if r["team"].has(id):
				started += 1
				if r["won"]:
					won_with += 1
		if started > 0:
			L.append("| %s | %d | %d%% |" % [str(db.chassis[id].get("name", id)), started, roundi(100.0 * won_with / started)])
	L.append("")
	# The party (the bible's section 9): who was dealt, and how its final and the finale went.
	var dealt := {}
	for r in results:
		for fid in r["party"].keys():
			var h := str(r["party"][fid])
			if not dealt.has(h):
				dealt[h] = {"runs": 0, "finals": 0, "won": 0}
			dealt[h]["runs"] += 1
		for b in r["reports"]:
			var h := str(b.get("hero", ""))
			if not h.is_empty() and dealt.has(h):
				dealt[h]["finals"] += 1
				dealt[h]["won"] += 1 if b["result"] == "won" else 0
	L.append("The party: each hero, the runs it was dealt in, the finals fought against it and how many were won (a final counts when its hero falls):")
	L.append("")
	L.append("| Hero | Dealt | Finals | Won |")
	L.append("|---|---|---|---|")
	for fid in db.factions.keys():
		for h in db.bench_of(str(fid)):
			var e: Dictionary = dealt.get(h, {"runs": 0, "finals": 0, "won": 0})
			L.append("| %s (%s) | %d | %d | %s |" % [str(db.foes[h].get("name", h)), str(db.factions[fid].get("name", fid)), int(e["runs"]), int(e["finals"]),
				("%d%%" % roundi(100.0 * int(e["won"]) / int(e["finals"]))) if int(e["finals"]) > 0 else "none"])
	L.append("")
	# The battles.
	var battles: Array = []
	for r in results:
		battles.append_array(r["reports"])
	var by := {"won": 0, "held": 0, "fell": 0}
	var wiped := 0
	var lost_won: Array[float] = []
	var lost_all: Array[float] = []
	var wrecked_all: Array[float] = []
	var salvage_won: Array[float] = []
	var loot_salvage: Array[float] = []
	var caches_all: Array[float] = []
	var favour_won: Array[float] = []
	var phases_all: Array[float] = []
	for b in battles:
		by[b["result"]] = int(by[b["result"]]) + 1
		if b["wiped"]:
			wiped += 1
		lost_all.append(float(b["lost"].size()))
		wrecked_all.append(float(b["wrecked"].size()))
		phases_all.append(float(b["phases"]))
		caches_all.append(float((b.get("loot", []) as Array).size()))   # claimed; banked on a won or held battle
		loot_salvage.append(float(b.get("loot_salvage", 0)))
		if b["result"] == "won":
			lost_won.append(float(b["lost"].size()))
			salvage_won.append(float(b["salvage"]))
			favour_won.append(float(b.get("favour", 0)))
	var n := maxi(1, battles.size())
	L.append("## The battles")
	L.append("")
	L.append("%d battles. Won %d%%, held after a wipe %d%%, fell %d%%; %d%% of battles ended in a team wipe." % [
		battles.size(), 100 * int(by["won"]) / n, 100 * int(by["held"]) / n, 100 * int(by["fell"]) / n, 100 * wiped / n])
	L.append("")
	L.append("| Measure | Mean | Range |")
	L.append("|---|---|---|")
	L.append("| Components destroyed per won battle (gone for good; the inflow has to beat this) | %s |" % _band(lost_won))
	L.append("| Components destroyed per battle, any outcome | %s |" % _band(lost_all))
	L.append("| Machines wrecked per battle | %s |" % _band(wrecked_all))
	L.append("| Salvage banked per won battle (the kills' and the loot's) | %s |" % _band(salvage_won))
	L.append("| Caches banked per battle (a fall loses what was claimed) | %s |" % _band(caches_all))
	L.append("| Salvage the loot banked per battle | %s |" % _band(loot_salvage))
	L.append("| Favour paid per won battle, after the gate's docking, of %d | %s |" % [Campaign.FAVOUR_PER_WIN, _band(favour_won)])
	L.append("| Phases a battle | %s |" % _band(phases_all))
	L.append("")
	# The Rupture meter and the mouths (the pacing session, 30 October): what the clocks did.
	var fr: Array[float] = []
	var fr_of: Array[float] = []
	var ruptured := 0
	var rupture_turns: Array[float] = []
	var peaks: Array[float] = []
	var rift_sent: Array[float] = []
	var tear_sent: Array[float] = []
	var tears_open: Array[float] = []
	var elites: Array[float] = []
	var menace: Array[float] = []
	var gate_dmg: Array[float] = []
	for b in battles:
		fr.append(float(b.get("fractures", 0)))
		fr_of.append(float(b.get("fractures_of", 0)))
		if int(b.get("rupture_turn", -1)) >= 0:
			ruptured += 1
			rupture_turns.append(float(b["rupture_turn"]))
		peaks.append(float(b.get("peaks", 0)))
		rift_sent.append(float(b.get("rift_spawns", 0)))
		tear_sent.append(float(b.get("tear_spawns", 0)))
		tears_open.append(float(b.get("tears", 0)))
		elites.append(float(b.get("elites", 0)))
		menace.append(float(b.get("menace", 0)) / float(ContentDB.MENACE_PER_PIP))
		gate_dmg.append(float(b.get("gate_damage", 0)))
	L.append("## The Rupture meter and the mouths")
	L.append("")
	L.append("The meter fills by the menace of the kills against the tier's Fractures (three, four, five), the last the Rupture, which breaks the boss's seal; it is sized in beats, what the opening places and the tide sends through its second peak, with four pips for each elite; menace is a pack's threat rating, a lone patrol one and a formation three. A peak of Rift Pressure sends a composition from the rift and a patrol from every tear open before it, and opens the ramp's count of tears on the seam. Every number a placeholder (`sim/ramp.gd`, `sim/battle.gd`).")
	L.append("")
	L.append("| Measure | Mean | Range |")
	L.append("|---|---|---|")
	L.append("| Fractures reached a battle | %s |" % _band(fr))
	L.append("| Fractures a battle holds | %s |" % _band(fr_of))
	L.append("| Battles reaching the Rupture | %d%% of %d | |" % [100 * ruptured / n, battles.size()])
	L.append("| The turn the seal broke, where it did | %s |" % _band(rupture_turns))
	L.append("| Peaks of Rift Pressure a battle | %s |" % _band(peaks))
	L.append("| Compositions the rift sent a battle | %s |" % _band(rift_sent))
	L.append("| Patrols the tears sent a battle | %s |" % _band(tear_sent))
	L.append("| Tears open at the battle's end | %s |" % _band(tears_open))
	L.append("| Elites spawned a battle | %s |" % _band(elites))
	L.append("| Menace killed a battle, in pips of threat rating | %s |" % _band(menace, true))
	L.append("| Gate damage a battle | %s |" % _band(gate_dmg))
	L.append("")
	# The pressure ratio (the long wall brief, section 5): as each player's turn opens, the threat
	# ratings of the packs at the wall or reaching it this coming enemy turn, over the machines
	# standing; per run, the mean over its turns, the share of its turns above one and the mean
	# of its battles' maxima, banded over the runs.
	var run_mean: Array[float] = []
	var run_over: Array[float] = []
	var run_max: Array[float] = []
	for r in results:
		var all: Array[float] = []
		var maxima: Array[float] = []
		for rep in r["reports"]:
			var rs: Array = rep.get("ratios", [])
			if rs.is_empty():
				continue
			var top := 0.0
			for x in rs:
				all.append(float(x))
				top = maxf(top, float(x))
			maxima.append(top)
		if all.is_empty():
			continue
		var sum := 0.0
		var over := 0
		for x in all:
			sum += x
			over += 1 if x > 1.0 else 0
		run_mean.append(sum / all.size())
		run_over.append(100.0 * over / all.size())
		var msum := 0.0
		for x in maxima:
			msum += x
		run_max.append(msum / maxima.size())
	L.append("## The pressure ratio")
	L.append("")
	L.append("As each player's turn opens: the threat ratings of the packs on the apron and of those whose planned walk ends there this coming enemy turn (a patrol 1, a formation 3, an elite and a boss 4), over the machines standing; a formation and a patrol arriving against four machines read 1.0, two formations 1.5. Per run, banded over the runs.")
	L.append("")
	L.append("| Measure | Mean | Range |")
	L.append("|---|---|---|")
	L.append("| The ratio, a run's mean over its turns | %s |" % _band(run_mean, true))
	L.append("| Turns above 1.0, percent of a run's | %s |" % _band(run_over))
	L.append("| A battle's highest, a run's mean | %s |" % _band(run_max, true))
	L.append("")
	# By tier and by faction.
	L.append("## By kind, tier of the Convergence, lead faction, squad size and guest")
	L.append("")
	L.append("| | Battles | Won | Fell | Wiped | Destroyed per battle |")
	L.append("|---|---|---|---|---|---|")
	var tiers := {}
	var facs := {}
	for b in battles:
		var tk := "tier %d" % int(b["tier"])
		var fk := str(db.factions.get(b["faction"], {}).get("name", b["faction"]))
		for key in [tk, fk]:
			var bucket: Dictionary = tiers if key == tk else facs
			if not bucket.has(key):
				bucket[key] = {"n": 0, "won": 0, "fell": 0, "wiped": 0, "lost": 0}
			var e: Dictionary = bucket[key]
			e["n"] += 1
			e["won"] += 1 if b["result"] == "won" else 0
			e["fell"] += 1 if b["result"] == "fell" else 0
			e["wiped"] += 1 if b["wiped"] else 0
			e["lost"] += b["lost"].size()
	var squads := {}
	var guests := {}
	var kinds := {}
	for b in battles:
		var kk := "the finale" if bool(b.get("finale", false)) else ("a final" if bool(b.get("final", false)) else "a battle")
		if not kinds.has(kk):
			kinds[kk] = {"n": 0, "won": 0, "fell": 0, "wiped": 0, "lost": 0}
		var ke: Dictionary = kinds[kk]
		ke["n"] += 1
		ke["won"] += 1 if b["result"] == "won" else 0
		ke["fell"] += 1 if b["result"] == "fell" else 0
		ke["wiped"] += 1 if b["wiped"] else 0
		ke["lost"] += b["lost"].size()
	for b in battles:
		var sk := "%d machines" % int(b["squad"])
		var gk := "with a guest" if str(b["guest"]) != "" else "lead alone"
		for pair in [[squads, sk], [guests, "%s, %s" % [sk, gk]]]:
			var bucket: Dictionary = pair[0]
			if not bucket.has(pair[1]):
				bucket[pair[1]] = {"n": 0, "won": 0, "fell": 0, "wiped": 0, "lost": 0}
			var e: Dictionary = bucket[pair[1]]
			e["n"] += 1
			e["won"] += 1 if b["result"] == "won" else 0
			e["fell"] += 1 if b["result"] == "fell" else 0
			e["wiped"] += 1 if b["wiped"] else 0
			e["lost"] += b["lost"].size()
	for bucket in [kinds, tiers, facs, squads, guests]:
		var ks: Array = bucket.keys()
		ks.sort()
		for k in ks:
			var e: Dictionary = bucket[k]
			var m := maxi(1, int(e["n"]))
			L.append("| %s | %d | %d%% | %d%% | %d%% | %.2f |" % [k, int(e["n"]), 100 * int(e["won"]) / m, 100 * int(e["fell"]) / m, 100 * int(e["wiped"]) / m, float(e["lost"]) / m])
	L.append("")
	# The fights by the pack's threat rating and the machines in them (the long wall brief,
	# section 5): one pack a fight, so a fight holds the machines the defence rule sent at it.
	var sizes: Array = []
	var stalemates := 0
	var stalled_fights := 0
	for r in results:
		sizes.append_array(r["fight_sizes"])
		for rep in r["reports"]:
			stalemates += int(rep.get("stalemates", 0))
			stalled_fights += int(rep.get("stalled_fights", 0))
	var cells := {}
	for f in sizes:
		var squad := int(f[5]) if f.size() > 5 else 0
		var k := Vector2i(squad, int(f[0]))
		if not cells.has(k):
			cells[k] = [0, 0]
		cells[k][0] += 1
		cells[k][1] += 1 if f[3] else 0
	L.append("## The fights")
	L.append("")
	L.append("%d fights. One pack is one fight, with the machines the defence rule sent at it; each row a pack's threat rating (the machines it is intended for, the largest of a catch's hunters') and the machines in the fight, with the fight's win rate. Stalemates, ten rounds running with no foe's HP, no machine's hull or shield changed, %d; fights stalled past the fight bot's cap of %d rounds, %d." % [
		sizes.size(), stalemates, Policy.MAX_ROUNDS, stalled_fights])
	L.append("")
	L.append("| A fight for | Machines in it | Fights | Won |")
	L.append("|---|---|---|---|")
	var ks: Array = cells.keys()
	ks.sort()
	for k in ks:
		var e: Array = cells[k]
		var fn := maxi(1, int(e[0]))
		L.append("| %d | %d | %d | %d%% |" % [(k as Vector2i).x, (k as Vector2i).y, int(e[0]), 100 * int(e[1]) / fn])
	L.append("")
	L.append("## The placeholders measured")
	L.append("")
	L.append("City gate %d, capital %d, bleed %d a turn, drain %d a fallen city a turn, %d phases of unopposed strikes after a wipe, %d salvage a pip of menace killed in any fight (a pack's threat rating), %d to start, %d Favour a won battle less %d a point of gate damage, %d Favour to start, a rush %d Favour, %d salvage a point of the capital's gate, the finale at Convergence %d (one sooner a fallen city), %d rifts open at tier 0 and one more every %d of the Convergence, a guest from tier %d, a squad of %d." % [
		Campaign.CITY_GATE, Campaign.CAPITAL_GATE, Campaign.BLEED, Campaign.DRAIN, Campaign.WIPE_PHASES,
		Campaign.SALVAGE_PER_PIP, Campaign.START_SALVAGE, Campaign.FAVOUR_PER_WIN, Campaign.FAVOUR_DOCK, Campaign.START_FAVOUR, Campaign.RUSH_PRICE, Campaign.REPAIR_COST,
		Campaign.FINALE_AT, Campaign.RIFTS_BASE, Campaign.TIER_EVERY, Campaign.GUEST_TIER, Campaign.SQUAD])
	L.append("")
	return "\n".join(L)


## A measure's mean and range; `fine` gives the range two decimals (a ratio's).
func _band(xs: Array[float], fine: bool = false) -> String:
	if xs.is_empty():
		return "none | "
	var lo := xs[0]
	var hi := xs[0]
	var sum := 0.0
	for x in xs:
		lo = minf(lo, x)
		hi = maxf(hi, x)
		sum += x
	var mean := sum / xs.size()
	var fmt := "%.0f" if absf(mean) >= 10.0 else "%.2f"
	var rfmt := "%.2f" if fine else "%.0f"
	return (fmt % mean) + " | " + ((rfmt % lo) + " to " + (rfmt % hi))

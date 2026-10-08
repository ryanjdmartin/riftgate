extends SceneTree

## The campaign runner: plays whole runs headless (`Campaign`, `BattleBot`, `Policy`) and
## measures the campaign's placeholders against play. Writes docs/campaign_run.md and
## prints it.
##   perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/campaign_run.gd -- --runs 40
## Options: --runs N (40), --seed S (1, the first run's seed), --policy greedy|random,
## --out path (docs/campaign_run.md), --trace SEED (print one run battle by battle).
##
## The player it stands in for is plain: it defends the front nearest to falling (the
## finale's capital once due) with every ready machine, rushes a wreck out of the shop with
## Favour only when nobody is ready, passes the turn when it cannot rush, and puts all its
## salvage into the capital's gate. On the map it hunts the nearest enemy (BattleBot).
## Its starting team is three of the run's tender at random (the draft, 7 October). Nothing
## yet brings anything in (offers, research, building are not built), so a run is the
## starting team and what it loses: the loss rate with no inflow, which is the number
## destroyed-is-gone waits on (bible section 10, the numbers row).

const OUT := "res://docs/campaign_run.md"

var runs := 40
var first_seed := 1
var policy := Policy.GREEDY
var out_path := OUT
var trace := 0


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
			"--out":
				out_path = v
			"--trace":
				trace = int(v)
		i += 2
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
	var team: Array = []
	for m in c.roster:
		team.append(m.chassis)
	var out := {"team": team, "won": false, "turns": 0, "reports": [], "passes": 0, "rushes": 0, "stalled": 0,
		"first_fall": -1, "finale": false, "fights": 0, "spends": {}, "fight_sizes": []}
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
				c.pass_turn()
				out["passes"] += 1
				if verbose:
					print("turn %d: nobody ready, passed" % c.turn)
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
		var bot := BattleBot.make(policy, seed_value * 1000 + c.turn)
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
		var r := c.finish_battle()
		r["tier"] = tier
		r["squad"] = uids.size()
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
	L.append("Generated by `tools/campaign_run.gd` on %s: %d runs from seed %d in %.0f s, the %s rung, each run starting with %d machines of its tender at random (the draft). Do not edit by hand." % [
		Time.get_date_string_from_system(), runs, first_seed, secs, Policy.kind_name(policy), Campaign.START_MACHINES])
	L.append("")
	L.append("Every number the campaign uses is a placeholder (`sim/campaign.gd`); this measures them against a plain player, it does not tune them. Nothing brings anything in yet (offers, research and building are not built), so every run is its starting team (three of its tender at random) and what it loses. The player defends the front nearest to falling with every ready machine, rushes a wreck with Favour only when nobody is ready, and puts all its salvage into the capital's gate; on the map it hunts the nearest enemy. Read the bands.")
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
	var kit_left: Array[float] = []
	for r in results:
		if r["won"]:
			won += 1
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
	var favour_won: Array[float] = []
	var phases_all: Array[float] = []
	for b in battles:
		by[b["result"]] = int(by[b["result"]]) + 1
		if b["wiped"]:
			wiped += 1
		lost_all.append(float(b["lost"].size()))
		wrecked_all.append(float(b["wrecked"].size()))
		phases_all.append(float(b["phases"]))
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
	L.append("| Salvage banked per won battle | %s |" % _band(salvage_won))
	L.append("| Favour paid per won battle, after the gate's docking, of %d | %s |" % [Campaign.FAVOUR_PER_WIN, _band(favour_won)])
	L.append("| Phases a battle | %s |" % _band(phases_all))
	L.append("")
	# By tier and by faction.
	L.append("## By tier of the Convergence, lead faction, squad size and guest")
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
	for bucket in [tiers, facs, squads, guests]:
		var ks: Array = bucket.keys()
		ks.sort()
		for k in ks:
			var e: Dictionary = bucket[k]
			var m := maxi(1, int(e["n"]))
			L.append("| %s | %d | %d%% | %d%% | %d%% | %.2f |" % [k, int(e["n"]), 100 * int(e["won"]) / m, 100 * int(e["fell"]) / m, 100 * int(e["wiped"]) / m, float(e["lost"]) / m])
	L.append("")
	# The fights: who the rings and the attack range actually put in them.
	var sizes: Array = []
	for r in results:
		sizes.append_array(r["fight_sizes"])
	var cells := {}
	var packs_in := {}
	for f in sizes:
		var k := "%d of %d" % [int(f[0]), int(f[1])]
		if not cells.has(k):
			cells[k] = [0, 0]
		cells[k][0] += 1
		cells[k][1] += 1 if f[3] else 0
		var pk := "%d machines against %d packs" % [int(f[0]), int(f[2])]
		if not packs_in.has(pk):
			packs_in[pk] = [0, 0]
		packs_in[pk][0] += 1
		packs_in[pk][1] += 1 if f[3] else 0
	L.append("## The fights")
	L.append("")
	L.append("%d fights. A fight holds the machines committed (those whose attack range covers the pack attacked) and every pack whose ring covers it, so a fight need not hold the whole squad; this bot walks every machine toward its nearest enemy and attacks the pack the most of them can reach, so it bunches, and a player who splits the team fights more fights with fewer machines in each. Machines in the fight of machines on the field, then machines against packs, each with the fight's win rate." % sizes.size())
	L.append("")
	L.append("| In the fight | Fights | Won |")
	L.append("|---|---|---|")
	for bucket in [cells, packs_in]:
		var ks: Array = bucket.keys()
		ks.sort()
		for k in ks:
			var e: Array = bucket[k]
			L.append("| %s | %d | %d%% |" % [k, int(e[0]), 100 * int(e[1]) / maxi(1, int(e[0]))])
	L.append("")
	L.append("## The placeholders measured")
	L.append("")
	L.append("City gate %d, capital %d, bleed %d a turn, drain %d a fallen city a turn, %d phases of unopposed strikes after a wipe, %d salvage a foe killed in any fight, %d to start, %d Favour a won battle less %d a point of gate damage, %d Favour to start, a rush %d Favour, %d salvage a point of the capital's gate, the finale at Convergence %d (one sooner a fallen city), %d rifts open at tier 0 and one more every %d of the Convergence, a guest from tier %d, a squad of %d." % [
		Campaign.CITY_GATE, Campaign.CAPITAL_GATE, Campaign.BLEED, Campaign.DRAIN, Campaign.WIPE_PHASES,
		Campaign.SALVAGE_PER_FOE, Campaign.START_SALVAGE, Campaign.FAVOUR_PER_WIN, Campaign.FAVOUR_DOCK, Campaign.START_FAVOUR, Campaign.RUSH_PRICE, Campaign.REPAIR_COST,
		Campaign.FINALE_AT, Campaign.RIFTS_BASE, Campaign.TIER_EVERY, Campaign.GUEST_TIER, Campaign.SQUAD])
	L.append("")
	return "\n".join(L)


func _band(xs: Array[float]) -> String:
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
	return (fmt % mean) + " | " + (("%.0f" % lo) + " to " + ("%.0f" % hi))

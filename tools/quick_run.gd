extends SceneTree

## The quick campaign's runner (25 October; sim/quick_run.gd, the bible's quick campaign row):
## whole quick runs played headless by `Policy`, with a plain player picking and fitting what
## the runs deal, into docs/quick_run.md. It reads what the campaign runner cannot: a squad
## fighting every fight together, the wear a battle costs, the kit a run gathers by tier, the
## bosses and the finale against a squad built from what it found.
##   perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/quick_run.gd -- --runs 40
## Options: --runs N (40), --seed S (1, the first run's seed), --policy greedy|random|planner,
## --out path (docs/quick_run.md), --team id,id,id (every run starts with these three; by
## default three different draft chassis at random by the run's seed), --density a,b,c (the
## formations' density at tiers one to three, 1 by default: the probe of 25 October's lever),
## --trace SEED (one run fight by fight), --part i/n with --json path (this process plays runs
## i, i+n, ... into the JSON and writes no report) and --merge a.json,b.json (the report from the
## parts, with the options they ran under):
##   for i in 0 1 2 3; do godot ... -s tools/quick_run.gd -- --part $i/4 --json build/quick_$i.json & done; wait
##   godot ... -s tools/quick_run.gd -- --merge build/quick_0.json,build/quick_1.json,build/quick_2.json,build/quick_3.json
##
## The player is plain, so a verdict on its picks and fits is a verdict on the bot: it starts
## with three draft chassis at random; takes a chassis from an offer while the roster is short
## of a squad, else the offer's piece of the highest tier; takes the loot pick's piece of the
## highest tier, a component before a module; fields the roster's first four; fills an empty
## hardpoint with the stores' best piece, and swaps a fitted piece for a stored one of a higher
## tier and the same side (a weapon for a weapon, equipment for equipment); fills and upgrades
## its module slots the same way.

const OUT := "res://docs/quick_run.md"

var runs := 40
var first_seed := 1
var policy := Policy.GREEDY
var out_path := OUT
var team: Array = []
var density: Array = [1.0, 1.0, 1.0]
var trace := 0
var part := -1
var parts := 1
var json_path := ""
var merge: Array = []
var db: ContentDB


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
				policy = Policy.RANDOM if v == "random" else (Policy.PLANNER if v == "planner" else Policy.GREEDY)
			"--out":
				out_path = v
			"--team":
				team = Array(v.split(",", false))
			"--density":
				density = Array(v.split(",", false)).map(func(x) -> float: return float(x))
			"--trace":
				trace = int(v)
			"--part":
				var p := v.split("/")
				part = int(p[0])
				parts = maxi(1, int(p[1]))
			"--json":
				json_path = v
			"--merge":
				merge = Array(v.split(",", false))
		i += 2
	db = ContentDB.load_default()
	if trace != 0:
		var r := play_run(trace, true)
		print("run %d: %s, %d battles won%s" % [trace, "won" if r["won"] else "lost", int(r["battles_won"]),
			(", lost at battle %d's %s" % [int(r["lost_at"].get("battle", 0)), str(r["lost_at"].get("kind", ""))]) if not r["won"] else ""])
		quit()
		return
	var results: Array = []
	var secs := 0.0
	if not merge.is_empty():
		for path in merge:
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(str(path)))
			if parsed is Dictionary:
				results.append_array(parsed.get("runs", []))
				secs = maxf(secs, float(parsed.get("secs", 0.0)))
		results.sort_custom(func(a, b) -> bool: return int(a["seed"]) < int(b["seed"]))
	else:
		var t0 := Time.get_ticks_msec()
		for s in range(first_seed, first_seed + runs):
			if part >= 0 and (s - first_seed) % parts != part:
				continue
			results.append(play_run(s))
		secs = (Time.get_ticks_msec() - t0) / 1000.0
		if part >= 0:
			var f := FileAccess.open(json_path, FileAccess.WRITE)
			f.store_string(JSON.stringify({"runs": results, "secs": secs}))
			f.close()
			quit()
			return
	var text := report(results, secs)
	print(text)
	var out := FileAccess.open(out_path, FileAccess.WRITE)
	out.store_string(text)
	out.close()
	quit()


# ---------------------------------------------------------------- one run

## One run, played to its end: {"seed", "team", "won", "battles_won", "lost_at", "stalled",
## "battles": [{battle, tier, lead, guest, won, fights: [...], kit, wrecked, lost}], "roster", "ms"}.
func play_run(seed_value: int, verbose: bool = false) -> Dictionary:
	var t0 := Time.get_ticks_msec()
	var r := QuickRun.new(seed_value)
	r.density = density.duplicate()
	var start: Array = team.duplicate()
	if start.is_empty():
		var offered := QuickRun.draft_choices(db)
		var pick := RandomNumberGenerator.new()
		pick.seed = seed_value * 7907 + 3
		while start.size() < QuickRun.START_MACHINES:
			var id := str(offered[pick.randi_range(0, offered.size() - 1)])
			if not start.has(id):
				start.append(id)
	r.choose(start)
	var out := {"seed": seed_value, "team": start, "won": false, "battles_won": 0, "lost_at": {}, "stalled": false, "battles": []}
	var battle_rec := {}
	var guard := 0
	while r.state != QuickRun.OVER and guard < 4000:
		guard += 1
		match r.state:
			QuickRun.HANGAR:
				_refit(r)
				battle_rec = {"battle": r.battle, "tier": r.tier(), "lead": r.lead, "guest": r.guest, "won": false,
					"fights": [], "kit": _kit(r), "finale": r.is_finale()}
				if verbose:
					print("battle %d, tier %d: %s%s; squad %s; kit %s" % [r.battle, r.tier() + 1, r.lead, (" + " + r.guest) if not r.guest.is_empty() else "",
						str(r.squad.map(func(uid) -> String: return r.machine(int(uid)).chassis)), str(battle_rec["kit"])])
				r.start_battle()
			QuickRun.BATTLE:
				var sk := r.open_fight()
				sk.begin()
				var pol := Policy.make(policy, seed_value * 1000 + guard)
				pol.play(sk)
				if pol.stalled:
					out["stalled"] = true
					if verbose:
						print("  the fight stalled after %d rounds; the run is abandoned" % pol.rounds)
					break
				var rep := r.finish_fight()
				battle_rec["fights"].append(rep)
				if verbose:
					print("  %s (%s): %s in %d rounds, %d standing, %.0f%% hull left" % [rep["kind"], rep["domain"], "won" if rep["won"] else "lost",
						int(rep["rounds"]), int(rep["standing"]), float(rep["hull_left"])])
				if r.state != QuickRun.BATTLE:
					var h: Dictionary = r.history[r.history.size() - 1]
					battle_rec["won"] = bool(h["won"])
					battle_rec["wrecked"] = h.get("wrecked", [])
					battle_rec["lost"] = h.get("lost", [])
					out["battles"].append(battle_rec)
					if bool(h["won"]):
						out["battles_won"] = int(out["battles_won"]) + 1
			QuickRun.REWARDS:
				var reward: Dictionary = r.rewards[0]
				var pick := _choose(r, reward)
				if verbose:
					print("  %s%s: %s" % [reward["kind"], (" (" + str(reward["maker"]) + ")") if reward.has("maker") else "", str(reward["choices"][pick]["id"])])
				r.take(pick)
	out["won"] = r.won
	out["lost_at"] = r.lost_at.duplicate()
	out["roster"] = r.roster.map(func(m) -> String: return m.chassis)
	out["ms"] = Time.get_ticks_msec() - t0
	return out


## The plain player's pick: a chassis while the roster is short of a squad, else the piece of
## the highest tier, a component before a module.
func _choose(r: QuickRun, reward: Dictionary) -> int:
	var choices: Array = reward["choices"]
	if r.roster.size() < QuickRun.SQUAD:
		for i in range(choices.size()):
			if choices[i]["kind"] == "chassis":
				return i
	var best := -1
	var best_score := -1
	for i in range(choices.size()):
		var it: Dictionary = choices[i]
		if it["kind"] == "chassis":
			continue
		var score := _tier_of(r, it) * 2 + (1 if it["kind"] == "component" else 0)
		if score > best_score:
			best = i
			best_score = score
	return best if best >= 0 else 0


func _tier_of(r: QuickRun, it: Dictionary) -> int:
	if it["kind"] == "component":
		return r.db.component_tier(str(it["id"]))
	if it["kind"] == "module":
		return int(r.db.modules[str(it["id"])].get("tier", 0))
	return r.db.chassis_tier(str(it["id"]))


func _is_weapon(r: QuickRun, cid: String) -> bool:
	return str(r.db.components.get(cid, {}).get("face", {}).get("kind", "attack")) == "attack"


## The plain player's hangar: the roster's first four; empty hardpoints filled with the stores'
## best piece; a fitted piece swapped for a stored one of a higher tier on the same side; the
## module slots filled and upgraded the same way.
func _refit(r: QuickRun) -> void:
	var uids: Array = []
	for m in r.roster:
		if uids.size() < QuickRun.SQUAD:
			uids.append(m.uid)
	r.set_squad(uids)
	for uid in uids:
		var m: QuickRun.Machine = r.machine(int(uid))
		# Empty hardpoints first, with the best stored piece of any side.
		while m.loadout.size() < r.hardpoints(m):
			var best := _best_stored(r, func(_cid: String) -> bool: return true)
			if best.is_empty():
				break
			r.fit(m.uid, m.loadout.size(), best)
		# Then upgrades, side for side.
		for slot in range(m.loadout.size()):
			var have := str(m.loadout[slot])
			var weapon := _is_weapon(r, have)
			var best := _best_stored(r, func(cid: String) -> bool: return _is_weapon(r, cid) == weapon)
			if not best.is_empty() and r.db.component_tier(best) > r.db.component_tier(have):
				r.fit(m.uid, slot, best)
		while m.modules.size() < r.module_slots(m):
			var best_mod := _best_module(r)
			if best_mod.is_empty():
				break
			r.fit_module(m.uid, m.modules.size(), best_mod)
		for slot in range(m.modules.size()):
			var best_mod := _best_module(r)
			if not best_mod.is_empty() and int(r.db.modules[best_mod]["tier"]) > int(r.db.modules[str(m.modules[slot])]["tier"]):
				r.fit_module(m.uid, slot, best_mod)


func _best_stored(r: QuickRun, ok: Callable) -> String:
	var best := ""
	for cid in r.components.keys():
		if int(r.components[cid]) > 0 and ok.call(str(cid)) and (best.is_empty() or r.db.component_tier(str(cid)) > r.db.component_tier(best)):
			best = str(cid)
	return best


func _best_module(r: QuickRun) -> String:
	var best := ""
	for mid in r.modules.keys():
		if int(r.modules[mid]) > 0 and (best.is_empty() or int(r.db.modules[mid]["tier"]) > int(r.db.modules[best]["tier"])):
			best = str(mid)
	return best


## The squad's kit as a battle opens: its hardpoint pieces by tier ("t0" the basics to "t3"),
## its empty hardpoints and its modules.
func _kit(r: QuickRun) -> Dictionary:
	var k := {"t0": 0, "t1": 0, "t2": 0, "t3": 0, "empty": 0, "modules": 0, "machines": r.squad.size()}
	for uid in r.squad:
		var m: QuickRun.Machine = r.machine(int(uid))
		for cid in m.loadout:
			var t := r.db.component_tier(str(cid))
			k["t%d" % clampi(t, 0, 3)] = int(k["t%d" % clampi(t, 0, 3)]) + 1
		k["empty"] = int(k["empty"]) + r.hardpoints(m) - m.loadout.size()
		k["modules"] = int(k["modules"]) + m.modules.size()
	return k


# ---------------------------------------------------------------- the report

func report(results: Array, secs: float) -> String:
	var L: Array[String] = []
	L.append("# Quick run")
	L.append("")
	L.append("Generated by `tools/quick_run.gd` on %s: %d runs from seed %d in %.0f s, the %s rung, %s, the formations' density %s by tier. Do not edit by hand." % [
		Time.get_date_string_from_system(), results.size(), int(results[0]["seed"]) if not results.is_empty() else first_seed, secs, Policy.kind_name(policy),
		("every run starting with " + ", ".join(team)) if not team.is_empty() else "each run starting with three different draft chassis at random",
		", ".join(density.map(func(x) -> String: return "%.2f" % float(x)))])
	L.append("")
	L.append("The quick campaign (`sim/quick_run.gd`; the bible's quick campaign row): twelve battles at a tier every four, then the finale; a battle's fights before its boss are the Rupture's Fractures (three, four, five), one, two and three of them elites, the boss standing with its formation, a field recharge between fights, nothing mended until the boss falls, a wipe ending the run. Every number is a placeholder, and the enemy does not change with the tier yet (the same spawn lists every tier; the elites stood in by each domain's other bench hero; the bosses the four massive stand-ins), so the later battles read the squad's kit against the first battles' foes. The player is plain (the runner's header): a verdict on its picks and fits is a verdict on the bot. Read the bands.")
	L.append("")
	var won := 0
	var stalled := 0
	var reached: Array[float] = []
	var finales := 0
	var ends := {}
	for r in results:
		if bool(r["won"]):
			won += 1
		if bool(r["stalled"]):
			stalled += 1
		reached.append(float(r["battles"].size()))
		for b in r["battles"]:
			if bool(b.get("finale", false)):
				finales += 1
		var at: Dictionary = r["lost_at"]
		if not at.is_empty():
			var key := "battle %d, %s" % [int(at["battle"]), str(at["kind"])]
			ends[key] = int(ends.get(key, 0)) + 1
	L.append("## The runs")
	L.append("")
	L.append("| Measure | Value |")
	L.append("|---|---|")
	L.append("| Runs won | %d of %d |" % [won, results.size()])
	L.append("| Runs that reached the finale | %d |" % finales)
	L.append("| Battles fought a run | %s |" % _mean_range(reached))
	L.append("| Runs abandoned on a stalled fight | %d |" % stalled)
	L.append("")
	L.append("Where the lost runs ended, by battle and fight:")
	L.append("")
	L.append("| Ended at | Runs |")
	L.append("|---|---|")
	var keys := ends.keys()
	keys.sort_custom(func(a, b) -> bool: return int(str(a).split(",")[0].split(" ")[1]) < int(str(b).split(",")[0].split(" ")[1]) or (int(str(a).split(",")[0].split(" ")[1]) == int(str(b).split(",")[0].split(" ")[1]) and str(a) < str(b)))
	for k in keys:
		L.append("| %s | %d |" % [k, int(ends[k])])
	L.append("")
	# By battle.
	L.append("## By battle")
	L.append("")
	L.append("Each battle the runs reached: how many won it, the squad's hull standing as its boss fight opened (a wreck counts nothing), machines wrecked, components destroyed for good, and the squad's kit as it opened (hardpoint pieces by tier, then empty hardpoints and modules, a squad's mean).")
	L.append("")
	L.append("| Battle | Tier | Reached | Won | Hull before the boss | Wrecked | Destroyed | Kit: t0 / t1 / t2 / t3 · empty · modules | Machines |")
	L.append("|---|---|---|---|---|---|---|---|---|")
	for n in range(1, QuickRun.BATTLES + 2):
		var at_n: Array = []
		for r in results:
			for b in r["battles"]:
				if int(b["battle"]) == n:
					at_n.append(b)
		if at_n.is_empty():
			continue
		var won_n := 0
		var hull_boss: Array[float] = []
		var wrecked := 0.0
		var lost := 0.0
		var kit := {"t0": 0.0, "t1": 0.0, "t2": 0.0, "t3": 0.0, "empty": 0.0, "modules": 0.0, "machines": 0.0}
		for b in at_n:
			if bool(b["won"]):
				won_n += 1
			var fights: Array = b["fights"]
			if fights.size() >= 2 and str(fights[fights.size() - 1]["kind"]) != "formation" and str(fights[fights.size() - 1]["kind"]) != "elite":
				hull_boss.append(float(fights[fights.size() - 2]["hull_left"]))
			wrecked += float(b.get("wrecked", []).size())
			lost += float(b.get("lost", []).size())
			for k in kit.keys():
				kit[k] = float(kit[k]) + float(b["kit"].get(k, 0))
		var nb := float(at_n.size())
		L.append("| %s | %d | %d | %d%% | %s | %.2f | %.2f | %.1f / %.1f / %.1f / %.1f · %.1f · %.1f | %.1f |" % [
			"finale" if n > QuickRun.BATTLES else str(n), mini(QuickRun.TOP_TIER, (n - 1) / QuickRun.TIER_EVERY) + 1, at_n.size(), roundi(100.0 * won_n / nb),
			("%.0f%%" % _mean(hull_boss)) if not hull_boss.is_empty() else "",
			wrecked / nb, lost / nb, kit["t0"] / nb, kit["t1"] / nb, kit["t2"] / nb, kit["t3"] / nb, kit["empty"] / nb, kit["modules"] / nb, kit["machines"] / nb])
	L.append("")
	# By fight kind and tier.
	L.append("## By fight")
	L.append("")
	L.append("Every fight by its kind and tier: how many were won, the rounds a won one took, and the squad's hull standing after it.")
	L.append("")
	L.append("| Fight | Tier | Fights | Won | Rounds | Hull left after |")
	L.append("|---|---|---|---|---|---|")
	for kind in ["formation", "elite", "boss", "final", "finale"]:
		for t in range(QuickRun.TOP_TIER + 1):
			var n_f := 0
			var n_won := 0
			var rounds: Array[float] = []
			var hull: Array[float] = []
			for r in results:
				for b in r["battles"]:
					for f in b["fights"]:
						if str(f["kind"]) == kind and int(f["tier"]) == t:
							n_f += 1
							hull.append(float(f["hull_left"]))
							if bool(f["won"]):
								n_won += 1
								rounds.append(float(f["rounds"]))
			if n_f > 0:
				L.append("| %s | %d | %d | %d%% | %s | %.0f%% |" % [kind, t + 1, n_f, roundi(100.0 * n_won / n_f), ("%.1f" % _mean(rounds)) if not rounds.is_empty() else "", _mean(hull)])
	L.append("")
	# By lead domain.
	L.append("## By domain")
	L.append("")
	L.append("| Lead domain | Battles | Won |")
	L.append("|---|---|---|")
	var by_lead := {}
	for r in results:
		for b in r["battles"]:
			var k := str(b["lead"])
			if not by_lead.has(k):
				by_lead[k] = [0, 0]
			by_lead[k][0] += 1
			if bool(b["won"]):
				by_lead[k][1] += 1
	for fid in db.factions.keys():
		if by_lead.has(fid):
			L.append("| %s | %d | %d%% |" % [str(db.factions[fid].get("name", fid)), int(by_lead[fid][0]), roundi(100.0 * by_lead[fid][1] / maxi(1, by_lead[fid][0]))])
	L.append("")
	# Who started.
	L.append("## Who started")
	L.append("")
	L.append("Each draft chassis, the runs it started and the battles those runs won (coverage, not a preference: the pick is random).")
	L.append("")
	L.append("| Machine | Runs started | Battles won, mean | Runs won |")
	L.append("|---|---|---|---|")
	for id in QuickRun.draft_choices(db):
		var started := 0
		var bw := 0.0
		var rw := 0
		for r in results:
			if Array(r["team"]).has(id):
				started += 1
				bw += float(r["battles_won"])
				if bool(r["won"]):
					rw += 1
		if started > 0:
			L.append("| %s | %d | %.2f | %d |" % [str(db.chassis[id].get("name", id)), started, bw / started, rw])
	L.append("")
	return "\n".join(L)


func _mean(list: Array) -> float:
	var s := 0.0
	for x in list:
		s += float(x)
	return s / maxf(1.0, float(list.size()))


func _mean_range(list: Array[float]) -> String:
	if list.is_empty():
		return "none"
	var lo := list[0]
	var hi := list[0]
	for x in list:
		lo = minf(lo, x)
		hi = maxf(hi, x)
	return "%.2f (%.0f to %.0f)" % [_mean(list), lo, hi]

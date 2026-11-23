extends SceneTree

## The battle runner (16 November; the anchor's reads of 12 November, "the second battle whole"
## and its ledger, as a tool beside the balance report): one battle of a run played whole,
## headless, by squads of machines over many seeds a domain, and every fight in it written down
## by what it held. Writes docs/battle_run.md and prints it.
##   perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/battle_run.gd -- --seeds 20
## Options: --seeds N (20 a domain and squad), --seed S (1, the first), --convergence N (1: a run's
## second battle; 0 its first), --tier N (1, the shown tier), --domains meadow,waste (every domain),
## --squad a,b,c,d (repeatable: a squad of those chassis; by default the anchor's three of four
## tier ones), --rule muster|defence (the map's player, BattleBot.Rule: muster by default, the
## player that gathers; defence the floor), --policy greedy|random (the fight bot, greedy), --out
## path (docs/battle_run.md). The field's trial dials are read from the environment as the game
## reads them (Settings.field_trial: RIFTGATE_STRIKE, RIFTGATE_TIDE, RIFTGATE_BEATS,
## RIFTGATE_OPENING, RIFTGATE_FODDER, RIFTGATE_FIELD_DEPTH, RIFTGATE_OVERHEAT, RIFTGATE_PACE,
## RIFTGATE_SPAWN_FIRST, RIFTGATE_RIFT_SENDS, RIFTGATE_FLANK_TEARS), a what-if the
## report names under its first line; with none set it is the game's own field.
##
## A battle is set up as a run sets one up (Battle.setup at the tier and the Convergence, the boss
## one of its domain's drawn by the seed), the squad stock and whole, and played by BattleBot to
## its end. Each cell is a domain and a squad: won, the gate fallen, wiped, the Rupture reached and
## its turn, the squad's hull when the seal broke and at the end (a share of its full hull), and
## the wrecks. The ledger beside it, every fight by its kind (BattleBot.fight_kind) over the
## domain's squads: how many a battle, the machines in it, its rounds, the hull a fight cost (a
## share of the squad's full hull), the fights lost and the wrecks a fight. Read the bands; a
## cell at twenty seeds is a direction.

const OUT := "res://docs/battle_run.md"
const SQUADS := [["badger", "skua", "cassowary", "storm_petrel"], ["badger", "storm_petrel", "prairie_dog", "cottonmouth"], ["badger", "skua", "cottonmouth", "cassowary"]]

var seeds := 20
var first_seed := 1
var convergence := 1
var tier := 1
var domains: Array = []
var squads: Array = []
var rule: int = BattleBot.Rule.MUSTER
var policy := Policy.GREEDY
var out_path := OUT
var whole := false   # --whole: the mustering player never fights a pack one short at the wall (BattleBot.short_at_wall off)
var db: ContentDB


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var a: String = args[i]
		var v: String = args[i + 1] if i + 1 < args.size() else ""
		match a:
			"--seeds":
				seeds = int(v)
			"--seed":
				first_seed = int(v)
			"--convergence":
				convergence = int(v)
			"--tier":
				tier = clampi(int(v), 1, 3)
			"--domains":
				domains = Array(v.split(","))
			"--squad":
				squads.append(Array(v.split(",")))
			"--rule":
				rule = BattleBot.Rule.DEFENCE if v == "defence" else BattleBot.Rule.MUSTER
			"--policy":
				policy = Policy.RANDOM if v == "random" else Policy.GREEDY
			"--out":
				out_path = v
			"--whole":
				whole = true
				i -= 1   # a switch: it takes no value
		i += 2
	db = ContentDB.load_default()
	Settings.field_trial()   # the field's trial dials from the environment, as the game reads them
	if squads.is_empty():
		squads = SQUADS.duplicate(true)
	for sq in squads:
		for cid in sq:
			if not db.chassis.has(str(cid)):
				push_error("--squad: no chassis '%s'" % str(cid))
				quit(1)
				return
	if domains.is_empty():
		domains = db.factions.keys()
	var text := report()
	print(text)
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(text)
	f.close()
	quit()


## One battle played whole: {"outcome", "turns", "rupture" (the turn the seal broke, -1),
## "hull_rupture" and "hull_end" (shares of the squad's full hull; -1 for no Rupture), "wrecks",
## "fights" (BattleBot.fight_sizes), "stalled"}.
func play(fac: String, squad: Array, seed_value: int) -> Dictionary:
	var team: Array = []
	for cid in squad:
		team.append(db.make_mech(str(cid)))
	var full := 0
	for u in team:
		full += u.hull_max
	var b := Battle.new(seed_value)
	b.tier = tier - 1
	b.ramp = convergence
	var bosses := db.bosses_of(fac)
	if not bosses.is_empty():
		b.lineup = [bosses[seed_value % bosses.size()]]
	b.setup(team, fac)
	var bot := BattleBot.make(policy, seed_value, rule)
	bot.short_at_wall = not whole
	var out := {"outcome": Battle.Outcome.NONE, "turns": 0, "rupture": -1, "hull_rupture": -1.0, "hull_end": 0.0, "wrecks": 0, "fights": [], "stalled": false}
	while b.state == Battle.State.PLAN:
		if bot.phases >= BattleBot.MAX_PHASES:
			out["stalled"] = true
			break
		bot.take_turn(b)
		_read_rupture(b, out, full)
		if b.state != Battle.State.PLAN:
			break
		b.end_turn()
		bot.phases += 1
		_read_rupture(b, out, full)
	out["outcome"] = b.outcome
	out["turns"] = bot.phases
	out["hull_end"] = _hull(b) / float(maxi(1, full))
	out["wrecks"] = b.field.wrecks.size()
	out["fights"] = bot.fight_sizes
	return out


func _read_rupture(b: Battle, out: Dictionary, full: int) -> void:
	if int(out["rupture"]) < 0 and b.rupture_turn >= 0:
		out["rupture"] = b.rupture_turn
		out["hull_rupture"] = _hull(b) / float(maxi(1, full))


func _hull(b: Battle) -> float:
	var h := 0
	for m in b.mechs():
		h += maxi(0, m.hull)
	return float(h)


func report() -> String:
	var t0 := Time.get_ticks_msec()
	var L: Array[String] = []
	var cells: Array[String] = []
	var ledger: Array[String] = []
	var battles := 0
	for fac in domains:
		var fname := str(db.factions.get(fac, {}).get("name", fac))
		var kinds := {}   # kind -> {"n", "machines", "rounds", "hull", "lost", "wrecks"}
		var played := 0
		for sq in squads:
			var e := {"won": 0, "fell": 0, "wiped": 0, "rupture": 0, "rupture_turn": 0.0, "hull_rupture": 0.0, "hull_end": 0.0, "wrecks": 0.0, "stalled": 0}
			var full := 0
			for cid in sq:
				full += db.make_mech(str(cid)).hull_max
			for s in range(first_seed, first_seed + seeds):
				var r := play(str(fac), sq, s)
				battles += 1
				played += 1
				match int(r["outcome"]):
					Battle.Outcome.VICTORY:
						e["won"] += 1
					Battle.Outcome.GATE_FALLEN:
						e["fell"] += 1
					Battle.Outcome.WRECKED:
						e["wiped"] += 1
				if bool(r["stalled"]):
					e["stalled"] += 1
				if int(r["rupture"]) >= 0:
					e["rupture"] += 1
					e["rupture_turn"] += float(r["rupture"])
					e["hull_rupture"] += float(r["hull_rupture"])
				e["hull_end"] += float(r["hull_end"])
				e["wrecks"] += float(r["wrecks"])
				for f in r["fights"]:
					var k := str(f[10]) if (f as Array).size() > 10 else "?"
					if not kinds.has(k):
						kinds[k] = {"n": 0, "machines": 0, "rounds": 0, "hull": 0.0, "lost": 0, "wrecks": 0}
					var d: Dictionary = kinds[k]
					d["n"] += 1
					d["machines"] += int(f[0])
					d["rounds"] += int(f[6])
					d["hull"] += 100.0 * float(f[7]) / float(maxi(1, full))
					d["lost"] += 0 if bool(f[3]) else 1
					d["wrecks"] += int(f[9])
			var n := float(maxi(1, seeds))
			var ru := maxi(1, int(e["rupture"]))
			cells.append("| %s | %s | %d%% | %d%% | %d%% | %d%% | %s | %s | %d%% | %.1f |" % [
				fname, ", ".join(_names(sq)), roundi(100.0 * e["won"] / n), roundi(100.0 * e["fell"] / n), roundi(100.0 * e["wiped"] / n),
				roundi(100.0 * e["rupture"] / n), ("%.1f" % (e["rupture_turn"] / ru)) if int(e["rupture"]) > 0 else "—",
				("%d%%" % roundi(100.0 * e["hull_rupture"] / ru)) if int(e["rupture"]) > 0 else "—", roundi(100.0 * e["hull_end"] / n), e["wrecks"] / n])
		var order := ["patrol for 1", "patrol for 2", "patrol for 3", "patrol for 4", "formation", "elite", "boss"]
		for k in kinds.keys():
			if not order.has(k):
				order.append(k)
		for k in order:
			if not kinds.has(k):
				continue
			var d: Dictionary = kinds[k]
			var m := float(maxi(1, int(d["n"])))
			ledger.append("| %s | %s | %.1f | %.1f | %.1f | %.1f%% | %d%% | %.2f |" % [fname, k, float(d["n"]) / float(maxi(1, played)), d["machines"] / m, d["rounds"] / m, d["hull"] / m, roundi(100.0 * d["lost"] / m), d["wrecks"] / m])
	var secs := (Time.get_ticks_msec() - t0) / 1000.0
	L.append("# Battle run")
	L.append("")
	L.append("Generated by `tools/battle_run.gd` on %s: %d battles in %.0f s, %d seeds a domain and squad from seed %d, tier %d at Convergence %d (%s), the map played by %s and every fight by the %s rung. Do not edit by hand." % [
		Time.get_date_string_from_system(), battles, secs, seeds, first_seed, tier, convergence,
		"a run's second battle" if convergence == 1 else ("a run's first battle" if convergence == 0 else "a run's battle at that Convergence"),
		"the player that gathers (BattleBot.Rule.MUSTER: each pack its threat rating's count of machines, the packs in the order they reach the wall, one short at the wall, gathered on otherwise, the unsealed boss first)" if rule == BattleBot.Rule.MUSTER else "the defence rule (BattleBot.Rule.DEFENCE: every machine onto the pack it can reach that reaches the wall soonest)",
		Policy.kind_name(policy)])
	L.append("")
	var trials: Array[String] = []
	for key in ["RIFTGATE_STRIKE", "RIFTGATE_TIDE", "RIFTGATE_BEATS", "RIFTGATE_OPENING", "RIFTGATE_FODDER", "RIFTGATE_FIELD_DEPTH", "RIFTGATE_OVERHEAT", "RIFTGATE_PACE", "RIFTGATE_SPAWN_FIRST", "RIFTGATE_RIFT_SENDS", "RIFTGATE_FLANK_TEARS"]:
		if not OS.get_environment(key).is_empty():
			trials.append("%s=%s" % [key, OS.get_environment(key)])
	if not trials.is_empty():
		L.append("A what-if on the field, never the game's own numbers: %s." % ", ".join(trials))
		L.append("")
	if whole:
		L.append("A what-if on the map's player (`--whole`): it never fights a pack one short at the wall; it gathers its rating and lets the strike land.")
		L.append("")
	L.append("Each battle as a run sets one up: the tier's compositions, the boss one of its domain's drawn by the seed, the squad stock and whole. A cell is a domain and a squad. Hull is a share of the squad's full hull, at the Rupture (the battles that reached it) and at the end (every battle). Read the bands; twenty seeds is a direction.")
	L.append("")
	L.append("| Domain | Squad | Won | The gate fell | Wiped | Rupture reached | Its turn | Hull then | Hull at the end | Wrecks |")
	L.append("|---|---|---|---|---|---|---|---|---|---|")
	L.append_array(cells)
	L.append("")
	L.append("## The ledger")
	L.append("")
	L.append("Every fight over the domain's squads by what it held (BattleBot.fight_kind: a patrol by the machines it is rated for, a formation, an elite, the boss): how many a battle, the machines the map's player sent into it, its rounds, the hull it cost (a share of the squad's full hull), the share of those fights lost, and the machines it wrecked.")
	L.append("")
	L.append("| Domain | The fight | A battle | Machines in it | Rounds | Hull a fight | Lost | Wrecks a fight |")
	L.append("|---|---|---|---|---|---|---|---|")
	L.append_array(ledger)
	L.append("")
	return "\n".join(L)


func _names(ids: Array) -> Array[String]:
	var out: Array[String] = []
	for cid in ids:
		out.append(str(db.chassis.get(str(cid), {}).get("name", cid)))
	return out

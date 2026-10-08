extends SceneTree

## The balance runner: every chassis alone, the default team, and each maker's team of three
## (5 October: an escort such as the Puffin reads only on a team that carries it), against
## every pack a faction sends through the rift, played by each rung of the policy ladder
## over many seeds. Writes docs/balance.md (and a JSON of every cell with --json) and prints it.
##   perl -e 'alarm 900; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200
## Options: --seeds N (200), --policies random,greedy (both), --out path (docs/balance.md),
## --json path (none), --withdraw N (a persona that withdraws under N percent hull; 0 never),
## --targeting aim|lowest (the foes' targeting rule for the matrix: the aims as shipped, or
## the lowest-shield rule from before 2 October; the team cells are always run under both
## and compared in their own section, since a single machine cannot see targeting),
## --damage F (every machine's blows scaled by F through a loadout modifier, to read a
## damage scale before the content is rewritten to it; 1.0 is the content as it stands),
## --trace "<row id>|<pack id>|<policy>|<seed>" (play that one fight and print its log
## instead of the matrix; ids as the JSON names them, e.g. "sparrowhawk|brute x4|greedy|3").
##
## Read the bands, not the numbers: a pack random play beats is too easy; a pack greedy
## play cannot beat is a wall; a cell where the two rungs land together holds no decision.
## Pick share is the balance signal for components: one nobody spends is dead, one spent
## every time is the whole die.

const OUT := "res://docs/balance.md"

var seeds := 200
var policies: Array[int] = [Policy.RANDOM, Policy.GREEDY]
var out_path := OUT
var json_path := ""
var withdraw_below := 0
var trace := ""
var targeting := ""   # "" is the aims; "lowest" the rule before 2 October
var damage_scale := 1.0   # the player's blows, scaled; a question asked of the matrix, never written to content here

var db: ContentDB
var rows: Array = []      # {id, name, chassis: [ids]}
var packs: Array = []     # {id, name, foe, strength}
var cells: Dictionary = {}   # "row|pack|policy" -> aggregate
var compare: Dictionary = {}   # the team row under the other targeting rule, same keys


func _init() -> void:
	_parse_args()
	db = ContentDB.load_default()
	if not db.load_errors.is_empty():
		push_error("content did not load: " + "\n".join(db.load_errors))
		quit(1)
		return
	_build_matrix()
	if not trace.is_empty():
		quit(_trace_one())
		return
	var t0 := Time.get_ticks_msec()
	var fights := 0
	for r in rows:
		for p in packs:
			for k in policies:
				cells[_key(r, p, k)] = _run_cell(r, p, k)
				fights += seeds
	# The team row again under the other targeting rule, for the comparison section.
	var other := "lowest" if targeting.is_empty() else ""
	for r in rows:
		if r["id"] != "team":
			continue
		for p in packs:
			for k in policies:
				compare[_key(r, p, k)] = _run_cell(r, p, k, other)
				fights += seeds
	var secs := (Time.get_ticks_msec() - t0) / 1000.0
	var report := _report(fights, secs)
	print(report)
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write %s" % out_path)
		quit(1)
		return
	f.store_string(report)
	f.close()
	if not json_path.is_empty():
		var j := FileAccess.open(json_path, FileAccess.WRITE)
		if j != null:
			j.store_string(JSON.stringify({"seeds": seeds, "rows": rows, "packs": packs, "cells": cells}, "  "))
			j.close()
	print("wrote %s: %d fights in %.1f s (%.0f a second)" % [out_path, fights, secs, fights / maxf(0.001, secs)])
	quit(0)


func _parse_args() -> void:
	var args := OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var a: String = args[i]
		var v: String = args[i + 1] if i + 1 < args.size() else ""
		match a:
			"--seeds":
				seeds = maxi(1, int(v))
				i += 1
			"--policies":
				policies.clear()
				for name in v.split(","):
					for k in Policy.KIND_NAMES.keys():
						if Policy.KIND_NAMES[k] == name.strip_edges():
							policies.append(k)
				i += 1
			"--out":
				out_path = v
				i += 1
			"--json":
				json_path = v
				i += 1
			"--targeting":
				targeting = "" if v == "aim" else v
				i += 1
			"--damage":
				damage_scale = maxf(0.05, float(v))
				i += 1
			"--withdraw":
				withdraw_below = int(v)
				i += 1
			"--trace":
				trace = v
				i += 1
		i += 1


## Rows: each chassis alone, then the starting team, then each maker's team (its first three
## machines in content order, for every maker with three; decided 5 October, so that a machine
## whose kit is for its allies, the Puffin's allies-only Prow Projector, is read at all: alone
## it can never spend it). Packs: every distinct foe and strength a faction's spawn list
## names, then each faction's boss alone.
func _build_matrix() -> void:
	for id in db.chassis.keys():
		rows.append({"id": str(id), "name": str(db.chassis[id].get("name", id)), "chassis": [str(id)]})
	var team: Array = db.default_team()
	rows.append({"id": "team", "name": "Team (%s)" % ", ".join(_names(team)), "chassis": team})
	for mk in db.makers.keys():
		var own: Array = []
		for id in db.chassis.keys():
			if str(db.chassis[id].get("maker", "")) == str(mk):
				own.append(str(id))
		if own.size() < 3:
			continue
		var trio: Array = own.slice(0, 3)
		rows.append({"id": "%s team" % mk, "name": "%s team (%s)" % [str(db.makers[mk].get("name", mk)), ", ".join(_names(trio))], "chassis": trio})
	for fac in db.factions.keys():
		for entry in db.spawn_table(fac):
			var pid := "%s x%d" % [entry[0], entry[1]]
			if _has_pack(pid) or not db.foes.has(entry[0]):
				continue
			packs.append({"id": pid, "name": "%s x%d" % [str(db.foes[entry[0]].get("name", entry[0])), entry[1]], "foe": str(entry[0]), "strength": int(entry[1])})
	for fac in db.factions.keys():
		var boss := str(db.factions[fac].get("boss", ""))
		if boss.is_empty() or not db.foes.has(boss) or _has_pack(boss + " x1"):
			continue
		packs.append({"id": boss + " x1", "name": str(db.foes[boss].get("name", boss)), "foe": boss, "strength": 1})
	# The mixed cells (the to-do, 2 October): every pack a faction sends through the rift in
	# one fight, a front and a back together, which is where targeting, spillover and the
	# Databank can be read at all.
	for fac in db.factions.keys():
		var mix: Array = []
		var names: Array[String] = []
		for entry in db.spawn_table(fac):
			if db.foes.has(entry[0]):
				mix.append([str(entry[0]), int(entry[1])])
				names.append("%s x%d" % [str(db.foes[entry[0]].get("name", entry[0])), int(entry[1])])
		if mix.size() < 2:
			continue
		packs.append({"id": fac + " formation", "name": "%s formation (%s)" % [str(db.factions[fac].get("name", fac)), ", ".join(names)], "foe": "", "strength": 0, "mix": mix})


func _names(ids: Array) -> Array[String]:
	var out: Array[String] = []
	for id in ids:
		out.append(str(db.chassis[id].get("name", id)))
	return out


func _has_pack(pid: String) -> bool:
	for p in packs:
		if p["id"] == pid:
			return true
	return false


static func _key(r: Dictionary, p: Dictionary, k: int) -> String:
	return "%s|%s|%s" % [r["id"], p["id"], Policy.kind_name(k)]


## One fight, played to its end: {sk, pol, hull_max, foes, outcome}. `rule` is the targeting
## rule, the runner's unless the comparison asks for the other.
func _fight(r: Dictionary, p: Dictionary, k: int, seed_value: int, rule: String = "\u0001") -> Dictionary:
	var sk := Skirmish.new(seed_value)
	sk.targeting_override = targeting if rule == "\u0001" else rule
	var hull_max := 0
	var uid := 0
	for cid in r["chassis"]:
		uid += 1
		var u := db.make_mech(cid, uid)
		if not is_equal_approx(damage_scale, 1.0):
			# The scale rides on every blow as a loadout modifier, the way a number is asked
			# here, so the bot's outcomes and the resolver read the same thing.
			u.grant_passive({"id": "runner_damage_scale", "name": "Damage scale", "description": "The runner's damage scale.",
				"effects": [{"trigger": "on_attack", "effect": "multiply_damage", "value": damage_scale}]}, "runner")
		hull_max += u.hull_max
		sk.add_mech(u)
	var foes: Array = []
	if p.has("mix"):
		for entry in p["mix"]:
			for n in range(int(entry[1])):
				foes.append(db.make_foe(str(entry[0])))
	else:
		for n in range(int(p["strength"])):
			foes.append(db.make_foe(p["foe"]))
	sk.add_foes(foes)
	sk.begin()
	var pol := Policy.make(k, seed_value)
	pol.withdraw_below = withdraw_below
	var outcome := pol.play(sk)
	return {"sk": sk, "pol": pol, "hull_max": hull_max, "foes": foes, "outcome": outcome}


## --trace: one fight's log, with the dice as they were spent.
func _trace_one() -> int:
	var parts := trace.split("|")
	if parts.size() != 4:
		push_error("--trace wants \"<row id>|<pack id>|<policy>|<seed>\"")
		return 1
	var r: Dictionary = {}
	for row in rows:
		if row["id"] == parts[0]:
			r = row
	var p: Dictionary = {}
	for pack in packs:
		if pack["id"] == parts[1]:
			p = pack
	var k := -1
	for kind in Policy.KIND_NAMES.keys():
		if Policy.KIND_NAMES[kind] == parts[2]:
			k = kind
	if r.is_empty() or p.is_empty() or k < 0:
		push_error("unknown row, pack or policy in --trace (rows: %s; packs: %s)" % [_ids(rows), _ids(packs)])
		return 1
	var f := _fight(r, p, k, int(parts[3]))
	var sk: Skirmish = f["sk"]
	print("%s vs %s, %s play, seed %s" % [r["name"], p["name"], parts[2], parts[3]])
	for line in sk.log:
		print("  " + line)
	var pol: Policy = f["pol"]
	print("outcome %s after %d rounds%s; rerolls %d; overheat hull %d; spends %s" % [
		Skirmish.Outcome.keys()[f["outcome"]], pol.rounds, " (stalled)" if pol.stalled else "", pol.rerolls, pol.overheat_hull, str(pol.spends)])
	for ms in sk.mechs:
		print("  %s: hull %d/%d, shield %d, heat %d" % [ms.unit.display_name, ms.unit.hull, ms.unit.hull_max, ms.unit.shield, ms.heat])
	return 0


static func _ids(list: Array) -> String:
	var out: Array[String] = []
	for e in list:
		out.append(str(e["id"]))
	return ", ".join(out)


## One cell: `seeds` fights of a row against a pack under one policy, summed.
func _run_cell(r: Dictionary, p: Dictionary, k: int, rule: String = "\u0001") -> Dictionary:
	var agg := {"fights": 0, "victory": 0, "defeat": 0, "withdrawn": 0, "stalled": 0,
		"rounds": 0, "hull_lost_pct": 0.0, "mechs_lost": 0, "foes_killed_pct": 0.0,
		"overheat_hull": 0, "rerolls": 0, "spends": {}, "destroyed": 0, "destroyed_won": 0}
	for s in range(seeds):
		var fight := _fight(r, p, k, s + 1, rule)
		var sk: Skirmish = fight["sk"]
		var pol: Policy = fight["pol"]
		var hull_max: int = fight["hull_max"]
		var foes: Array = fight["foes"]
		var outcome: int = fight["outcome"]
		agg["fights"] += 1
		if pol.stalled:
			agg["stalled"] += 1
		elif outcome == Skirmish.Outcome.VICTORY:
			agg["victory"] += 1
		elif outcome == Skirmish.Outcome.WITHDRAWN:
			agg["withdrawn"] += 1
		else:
			agg["defeat"] += 1
		agg["rounds"] += pol.rounds
		agg["destroyed"] += sk.destroyed
		if outcome == Skirmish.Outcome.VICTORY and not pol.stalled:
			agg["destroyed_won"] += sk.destroyed
		var hull := 0
		var lost := 0
		for ms in sk.mechs:
			hull += maxi(0, ms.unit.hull)
			if not ms.alive():
				lost += 1
		agg["hull_lost_pct"] += 100.0 * (hull_max - hull) / maxi(1, hull_max)
		agg["mechs_lost"] += lost
		var dead := 0
		for f in foes:
			if not f.alive():
				dead += 1
		agg["foes_killed_pct"] += 100.0 * dead / maxi(1, foes.size())
		agg["overheat_hull"] += pol.overheat_hull
		agg["rerolls"] += pol.rerolls
		for c in pol.spends.keys():
			agg["spends"][c] = int(agg["spends"].get(c, 0)) + int(pol.spends[c])
	return agg


# ---------------------------------------------------------------- the report

func _report(fights: int, secs: float) -> String:
	var L: Array[String] = []
	L.append("# Balance")
	L.append("")
	L.append("Generated by `tools/balance.gd` on %s: %d fights in %.0f s, %d seeds a cell, policies %s%s%s. Do not edit by hand." % [
		Time.get_date_string_from_system(), fights, secs, seeds, ", ".join(_policy_names()),
		"" if withdraw_below <= 0 else ", withdrawing under %d%% hull" % withdraw_below,
		"" if is_equal_approx(damage_scale, 1.0) else ", the player's damage scaled by %.2f" % damage_scale])
	L.append("")
	L.append("Read the bands, not the numbers. A pack random play beats is too easy; a pack greedy play cannot beat is a wall; a cell where both rungs land together holds no decision. Numbers in content are placeholders, so this is the shape of the game, not its balance.")
	L.append("")
	L.append("## Win rate, %s" % " / ".join(_policy_names()))
	L.append("")
	L.append("Percent of fights won, one figure per policy. Each row fights each pack from full hull, with its default loadout.")
	L.append("")
	L.append(_header())
	for r in rows:
		var cell: Array[String] = ["**%s**" % r["name"]]
		for p in packs:
			var parts: Array[String] = []
			for k in policies:
				var a: Dictionary = cells[_key(r, p, k)]
				parts.append("%d" % _pct(a["victory"], a["fights"]))
			cell.append(" / ".join(parts))
		L.append("| " + " | ".join(cell) + " |")
	L.append("")
	var top := policies[policies.size() - 1]
	L.append("## Cost of a win, %s" % Policy.kind_name(top))
	L.append("")
	L.append("Mean rounds and mean hull lost (percent of the row's total hull), over every fight in the cell, won or not, then the components destroyed per won fight (gone for good in the hangar, bible section 10; the inflow has to beat this). A w marks a cell with withdrawals, an s a cell with a stalled fight (past %d rounds)." % Policy.MAX_ROUNDS)
	L.append("")
	L.append(_header())
	for r in rows:
		var cell: Array[String] = ["**%s**" % r["name"]]
		for p in packs:
			var a: Dictionary = cells[_key(r, p, top)]
			var n: int = maxi(1, a["fights"])
			var flags := ""
			if a["withdrawn"] > 0:
				flags += " w"
			if a["stalled"] > 0:
				flags += " s"
			cell.append("%.1f r, %d%% hull, %.2f lost%s" % [float(a["rounds"]) / n, int(roundf(a["hull_lost_pct"] / n)), float(a["destroyed_won"]) / maxi(1, int(a["victory"])), flags])
		L.append("| " + " | ".join(cell) + " |")
	L.append("")
	L.append("## Targeting rules on the team cells, %s" % " / ".join(_policy_names()))
	L.append("")
	L.append("The team against every pack under the shipped rule (every foe picks its own target by its aim, 2 October) and under the rule before it (every foe on the machine with the lowest shield): win rate per policy, then mean rounds and mean hull lost under %s. A single machine cannot see targeting, so this is the only place the rule reads. The matrix above ran under %s." % [Policy.kind_name(top), "the aims" if targeting.is_empty() else "the lowest-shield rule"])
	L.append("")
	L.append(_header())
	for r in rows:
		if r["id"] != "team":
			continue
		for pair in [["aims", cells if targeting.is_empty() else compare], ["lowest shield", compare if targeting.is_empty() else cells]]:
			var cell: Array[String] = ["**%s**" % pair[0]]
			for p in packs:
				var parts: Array[String] = []
				for k in policies:
					var a: Dictionary = pair[1][_key(r, p, k)]
					parts.append("%d" % _pct(a["victory"], a["fights"]))
				var t: Dictionary = pair[1][_key(r, p, top)]
				var n: int = maxi(1, t["fights"])
				cell.append("%s; %.1f r, %d%% hull" % [" / ".join(parts), float(t["rounds"]) / n, int(roundf(t["hull_lost_pct"] / n))])
			L.append("| " + " | ".join(cell) + " |")
	L.append("")
	L.append("## Pick share, %s" % Policy.kind_name(top))
	L.append("")
	L.append("How each row's spends divide between its components over every pack: the die's entries as the bot actually uses them. Blank spends (an empty hardpoint, a destroyed or disabled component) are listed last. Rerolls are per round.")
	L.append("")
	for r in rows:
		var spends := {}
		var total := 0
		var rounds := 0
		var rerolls := 0
		for p in packs:
			var a: Dictionary = cells[_key(r, p, top)]
			rounds += int(a["rounds"])
			rerolls += int(a["rerolls"])
			for c in a["spends"].keys():
				spends[c] = int(spends.get(c, 0)) + int(a["spends"][c])
				total += int(a["spends"][c])
		var named: Array = []
		var blanks: Array = []
		for c in spends.keys():
			if c in ["empty", "destroyed", "disabled"]:
				blanks.append([c, spends[c]])
			else:
				named.append([db.component_name(c), spends[c], c])
		named.sort_custom(func(a, b) -> bool: return a[1] > b[1])
		var parts: Array[String] = []
		for e in named:
			parts.append("%s %d%%" % [e[0], _pct(e[1], total)])
		for e in blanks:
			parts.append("%s %d%%" % [e[0], _pct(e[1], total)])
		L.append("- **%s**: %s. Rerolls %.2f a round." % [r["name"], ", ".join(parts), float(rerolls) / maxi(1, rounds)])
	L.append("")
	return "\n".join(L)


func _header() -> String:
	var names: Array[String] = [""]
	for p in packs:
		names.append(str(p["name"]))
	var sep: Array[String] = []
	for i in range(names.size()):
		sep.append("---")
	return "| " + " | ".join(names) + " |\n| " + " | ".join(sep) + " |"


func _policy_names() -> Array[String]:
	var out: Array[String] = []
	for k in policies:
		out.append(Policy.kind_name(k))
	return out


static func _pct(n: int, of: int) -> int:
	return int(roundf(100.0 * n / maxi(1, of)))

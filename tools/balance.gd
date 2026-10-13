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
## --rows id,id (only these rows, by the ids the JSON names: a chassis id, "team", "minerva
## team", "team:badger+sparrowhawk"), --team id,id (repeatable: a row of exactly those machines,
## any number of them, so pairs and fours can be read beside the trios), --module id (that module fitted to every machine in every row, to read what it is
## worth beside a run without it; 11 October, the Booster against the Databank),
## --bump stat:N, repeatable (N more of a stat on every machine: hull, shield, armour, heat
## for the maximum, cooling, or damage for N more on every blow; the price of a stat, read
## against a run without it), --nopassive (every chassis without its passive, for what the
## passives are worth), --set path=json, repeatable (one content value replaced for this
## run only, e.g. components/enfilade_beam/face/keywords=[]; never validated, for a knock-out
## or a what-if, never a way to change content),
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
var only_rows: Array = []   # --rows: the row ids to run, all when empty
var custom_teams: Array = []  # --team: extra rows, each a list of chassis ids
var fit_module := ""        # --module: a module fitted to every machine of every row
var bumps: Array = []       # --bump: [stat, amount] pairs given to every machine
var no_passive := false     # --nopassive: every chassis stripped of its passive
var edits: Array = []       # --set: "path=json" content replacements for this run only

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
	for e in edits:
		var err := _apply_edit(str(e))
		if not err.is_empty():
			push_error("--set %s: %s" % [e, err])
			quit(1)
			return
	if no_passive:
		for id in db.chassis.keys():
			db.chassis[id]["passive"] = null
	_build_matrix()
	if not fit_module.is_empty() and not db.modules.has(fit_module):
		push_error("no module '%s' (modules: %s)" % [fit_module, ", ".join(db.modules.keys())])
		quit(1)
		return
	if not only_rows.is_empty():
		rows = rows.filter(func(r) -> bool: return only_rows.has(r["id"]))
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
			"--rows":
				only_rows = Array(v.split(","))
				i += 1
			"--team":
				custom_teams.append(Array(v.split(",")))
				i += 1
			"--module":
				fit_module = v
				i += 1
			"--bump":
				var bp := v.split(":")
				if bp.size() == 2:
					bumps.append([bp[0], int(bp[1])])
				i += 1
			"--nopassive":
				no_passive = true
			"--set":
				edits.append(v)
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
	# --team rows (13 October): any machines together, to read pairs and fours beside the trios.
	for ids in custom_teams:
		var team_ids: Array = []
		for id in ids:
			var cid := str(id).strip_edges()
			if not db.chassis.has(cid):
				push_error("--team: no chassis '%s' (chassis: %s)" % [cid, ", ".join(db.chassis.keys())])
				quit(1)
				return
			team_ids.append(cid)
		if team_ids.is_empty():
			continue
		rows.append({"id": "team:" + "+".join(team_ids), "name": "Team (%s)" % ", ".join(_names(team_ids)), "chassis": team_ids})
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
		var u := db.make_mech(cid, uid, Vector2i.ZERO, null, [] if fit_module.is_empty() else [fit_module])
		if not is_equal_approx(damage_scale, 1.0):
			# The scale rides on every blow as a loadout modifier, the way a number is asked
			# here, so the bot's outcomes and the resolver read the same thing.
			u.grant_passive({"id": "runner_damage_scale", "name": "Damage scale", "description": "The runner's damage scale.",
				"effects": [{"trigger": "on_attack", "effect": "multiply_damage", "value": damage_scale}]}, "runner")
		for b in bumps:
			# A bump is a question asked of the matrix, like the damage scale: a static stat
			# line, or damage on every blow, granted by the runner and never written to content.
			var eff := {"trigger": "on_attack", "effect": "add_damage", "value": b[1]} if b[0] == "damage" \
				else {"trigger": "static", "effect": "add_stat", "stat": b[0], "value": b[1]}
			u.grant_passive({"id": "runner_bump_" + str(b[0]), "name": "Bump", "description": "The runner's bump.", "effects": [eff]}, "runner")
			u.hull = u.hull_max
			u.shield = u.shield_max
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
		"overheat_hull": 0, "rerolls": 0, "spends": {}, "destroyed": 0, "destroyed_won": 0, "reach": {}, "class": {}, "taken": {}}
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
		for pair in [["reach", sk.reach_tally], ["class", sk.class_tally]]:
			var src: Dictionary = pair[1]
			for rk in src.keys():
				var into: Dictionary = agg[pair[0]].get(rk, {})
				for f in src[rk].keys():
					into[f] = int(into.get(f, 0)) + int(src[rk][f])
				agg[pair[0]][rk] = into
		for rk in sk.taken_by_rank.keys():
			agg["taken"][rk] = int(agg["taken"].get(rk, 0)) + int(sk.taken_by_rank[rk])
	return agg


## One --set: a content value replaced in memory for this run, by a path through the
## loaded content ("components/<id>/face/keywords", "chassis/<id>/loadout/0") and a JSON value.
## An empty string is success; anything else says what was wrong.
func _apply_edit(e: String) -> String:
	var eq := e.find("=")
	if eq < 0:
		return "no '='"
	var path := e.substr(0, eq).split("/")
	var parsed := JSON.new()
	if parsed.parse(e.substr(eq + 1)) != OK:
		return "the value is not JSON"
	var roots := {"components": db.components, "chassis": db.chassis, "modules": db.modules}
	if path.size() < 3 or not roots.has(path[0]):
		return "a path starts components/, chassis/ or modules/ and names a field"
	var node = roots[path[0]]
	for k in range(1, path.size() - 1):
		if node is Array and path[k].is_valid_int() and int(path[k]) < node.size():
			node = node[int(path[k])]
		elif node is Dictionary and node.has(path[k]):
			node = node[path[k]]
		else:
			return "no '%s'" % path[k]
	var last := path[path.size() - 1]
	if node is Array:
		if not last.is_valid_int() or int(last) >= node.size():
			return "no index %s" % last
		node[int(last)] = parsed.data
	elif node is Dictionary:
		node[last] = parsed.data
	else:
		return "'%s' is not a list or a record" % path[path.size() - 2]
	return ""


# ---------------------------------------------------------------- the report

func _report(fights: int, secs: float) -> String:
	var L: Array[String] = []
	L.append("# Balance")
	L.append("")
	L.append("Generated by `tools/balance.gd` on %s: %d fights in %.0f s, %d seeds a cell, policies %s%s%s. Do not edit by hand." % [
		Time.get_date_string_from_system(), fights, secs, seeds, ", ".join(_policy_names()),
		"" if withdraw_below <= 0 else ", withdrawing under %d%% hull" % withdraw_below,
		"" if is_equal_approx(damage_scale, 1.0) else ", the player's damage scaled by %.2f" % damage_scale]
		+ ("" if fit_module.is_empty() else " Every machine wears the %s." % str(db.modules[fit_module].get("name", fit_module)))
		+ ("" if bumps.is_empty() else " Every machine bumped: %s." % ", ".join(bumps.map(func(b) -> String: return "%s %+d" % [b[0], b[1]])))
		+ ("" if not no_passive else " No chassis has its passive.")
		+ ("" if edits.is_empty() else " Content changed for this run: %s." % ", ".join(edits)))
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
	L.append_array(_reach_report(top))
	return "\n".join(L)


## Does a pack field a back rank? Indirect's premium is reaching it (Ryan, 9 October: the
## splash is a build issue, not a price, if the back rank holds the threats).
func _has_back_rank(p: Dictionary) -> bool:
	var ids: Array = []
	if p.has("mix"):
		for entry in p["mix"]:
			ids.append(str(entry[0]))
	else:
		ids.append(str(p["foe"]))
	for fid in ids:
		if str(db.foes.get(fid, {}).get("rank", "front")) == "back":
			return true
	return false


## The reach table: what a spend of each reach did, over every row and pack under the top
## policy, then over the packs with a back rank alone (Ryan, 9 October: does each attack
## type carry a premium, and is indirect's priced at all?).
func _reach_report(top: int) -> Array[String]:
	var L: Array[String] = []
	L.append("## Reach, %s" % Policy.kind_name(top))
	L.append("")
	L.append("What a spend of each reach did (lures and probes, which deal nothing, left out): its share of attack spends, the hull it took off foes a spend (every foe the blows reached, overkill not counted), the heat it paid a spend, the spends aimed at the back rank, and for indirect the shield its danger close cost per spend aimed at the front. Over every row and pack, then over the packs that field a back rank.")
	L.append("")
	for only_back in [false, true]:
		var tot := {}
		for r in rows:
			for p in packs:
				if only_back and not _has_back_rank(p):
					continue
				var a: Dictionary = cells[_key(r, p, top)]
				for rk in a.get("reach", {}).keys():
					var into: Dictionary = tot.get(rk, {})
					for f in a["reach"][rk].keys():
						into[f] = int(into.get(f, 0)) + int(a["reach"][rk][f])
					tot[rk] = into
		var all_spends := 0
		for rk in tot.keys():
			all_spends += int(tot[rk].get("spends", 0))
		L.append("**%s**" % ("Packs with a back rank" if only_back else "Every pack"))
		L.append("")
		L.append("| Reach | Share of attack spends | Hull a spend | Heat a spend | Aimed at the back | Splash a front spend |")
		L.append("|---|---|---|---|---|---|")
		for rk in ["direct", "indirect"]:
			if not tot.has(rk):
				continue
			var t: Dictionary = tot[rk]
			var n := maxi(1, int(t.get("spends", 0)))
			var splash := "%.1f" % (float(t.get("splash", 0)) / maxi(1, int(t.get("front_spends", 0)))) if rk == "indirect" else "-"
			L.append("| %s | %d%% | %.1f | %.1f | %d%% | %s |" % [rk, _pct(int(t.get("spends", 0)), all_spends), float(t.get("damage", 0)) / n, float(t.get("heat", 0)) / n, _pct(int(t.get("back", 0)), n), splash])
		L.append("")
	# Who the hits came from: the share of the damage the machines took (shield and hull)
	# that came from the back rank, in the packs that field one.
	var taken := {}
	for r in rows:
		for p in packs:
			if not _has_back_rank(p):
				continue
			var a: Dictionary = cells[_key(r, p, top)]
			for rk in a.get("taken", {}).keys():
				taken[rk] = int(taken.get(rk, 0)) + int(a["taken"][rk])
	var all_taken := int(taken.get("front", 0)) + int(taken.get("back", 0))
	L.append("In the packs with a back rank, %d%% of the damage the machines took (shield and hull) came from the back rank." % _pct(int(taken.get("back", 0)), all_taken))
	L.append("")
	L.append("## Rolled and flat, %s" % Policy.kind_name(top))
	L.append("")
	L.append("The same by the shape of the number: a weapon that rolls a range against one that is a single number, over every row and pack.")
	L.append("")
	var tot := {}
	for r in rows:
		for p in packs:
			var a: Dictionary = cells[_key(r, p, top)]
			for ck in a.get("class", {}).keys():
				var into: Dictionary = tot.get(ck, {})
				for f in a["class"][ck].keys():
					into[f] = int(into.get(f, 0)) + int(a["class"][ck][f])
				tot[ck] = into
	var all_spends := 0
	for ck in tot.keys():
		all_spends += int(tot[ck].get("spends", 0))
	L.append("| Shape | Share of damaging spends | Hull a spend | Heat a spend |")
	L.append("|---|---|---|---|")
	for ck in ["rolled", "flat"]:
		if not tot.has(ck):
			continue
		var t: Dictionary = tot[ck]
		var n := maxi(1, int(t.get("spends", 0)))
		L.append("| %s | %d%% | %.1f | %.1f |" % [ck, _pct(int(t.get("spends", 0)), all_spends), float(t.get("damage", 0)) / n, float(t.get("heat", 0)) / n])
	L.append("")
	return L


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

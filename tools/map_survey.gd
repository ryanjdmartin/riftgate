extends SceneTree

## The map survey: generates many seeded battlefields at the game's size and measures what
## the generator guarantees and what the ground does to each way of moving. Writes
## docs/map_survey.md and prints it.
##   perl -e 'alarm 900; exec @ARGV' godot --headless --path . -s tools/map_survey.gd -- --seeds 200
## Options: --seeds N (200), --type KIND (mixed; a key of BattleMap.KINDS for the detailed
## report; the comparison at the end always runs every kind), --w W --h H (Battle's default,
## 9 by 20, the game's field), --move M (3, the reference move in hexes every way of moving is
## measured at; the packs at their own 2), --out path (docs/map_survey.md), --show SEED (print that seed's
## map as text instead, of --type's kind).
##
## What it reads: each ground's share of the field, how much is water and in how many
## bodies, the horde's narrowest crossing (the fewest hexes that cut every foe route; the
## generator guarantees BattleMap.CROSSING_WIDTH), how many hexes the guarantee had to
## open, the phases each way of moving takes from its best lane on the team's ground to the
## rift's mouth with nobody in the way, and its reach: the share of the field it can stand
## on after two phases, and whether it makes the horde's crossing by then. Bands, not
## decimals: the ground is right when the ground machines read alike and the crossers above
## them (hover over water, the flyer over water and crags), the kinds tell apart, and the
## horde's crossings stay wide.

const OUT := "res://docs/map_survey.md"
const WAYS := ["tracked", "walker", "wheeled", "hover", "flyer"]

var seeds := 200
var w := Battle.DEFAULT_WIDTH   # the game's field: nine wide since 8 October
var h := 20
var move := 3
var out_path := OUT
var show := 0
var kind := "mixed"
## Each way of moving's move in content today, for the reach table (the survey reads the
## chassis files for them; these are the fallbacks).
var moves := {"tracked": 3, "walker": 3, "wheeled": 5, "hover": 4, "flyer": 5}


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var a: String = args[i]
		var v: String = args[i + 1] if i + 1 < args.size() else ""
		match a:
			"--seeds":
				seeds = int(v)
			"--w":
				w = int(v)
			"--h":
				h = int(v)
			"--move":
				move = int(v)
			"--out":
				out_path = v
			"--show":
				show = int(v)
			"--type":
				kind = v
		i += 2
	if not BattleMap.KINDS.has(kind):
		push_error("no such map kind: " + kind + " (" + ", ".join(BattleMap.KINDS.keys()) + ")")
		quit(1)
		return
	_read_moves()
	if show != 0:
		print(_picture(BattleMap.generate(w, h, show, kind)))
	else:
		var text := _survey()
		print(text)
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		f.store_string(text)
		f.close()
	quit()


## The biggest move each way of moving has in content, so the reach table reads the game
## as it stands.
func _read_moves() -> void:
	var f := FileAccess.open("res://content/chassis.json", FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary) or not parsed.has("chassis"):
		return
	var best := {}
	for c in parsed["chassis"]:
		var way := BattleMap.way_of(c.get("traits", []))
		if way.is_empty():
			continue
		best[way] = maxi(int(best.get(way, 0)), int(c.get("movespeed", 0)))
	for way in best.keys():
		moves[way] = best[way]


func _survey() -> String:
	var shares := {}
	for t in BattleMap.TERRAIN_NAMES.keys():
		shares[t] = []
	var water_share: Array[float] = []
	var bodies: Array[int] = []
	var biggest: Array[int] = []
	var spans := 0
	var kinds := {}
	var widths := {}
	var opened: Array[int] = []
	var opened_water: Array[int] = []
	var ms: Array[float] = []
	var horde_len: Array[int] = []
	var phases := {}   # way -> [phases per seed]
	for way in WAYS + ["packs"]:
		phases[way] = []
	var reach := {}   # way -> [share after two phases per seed]
	var at_cut := {}  # way -> maps where the crossing is reached by phase two
	for way in WAYS:
		reach[way] = []
		at_cut[way] = 0
	for s in range(1, seeds + 1):
		var t := Time.get_ticks_usec()
		var m := BattleMap.generate(w, h, s, kind)
		ms.append(float(Time.get_ticks_usec() - t) / 1000.0)
		var field := 0
		var water: Array[Vector2i] = []
		var count := {}
		for hx in m.all_hexes():
			if m.is_structure(hx):
				continue
			field += 1
			count[m.terrain[hx]] = int(count.get(m.terrain[hx], 0)) + 1
			if m.terrain[hx] == BattleMap.Terrain.WATER:
				water.append(hx)
		for tt in shares.keys():
			shares[tt].append(float(count.get(tt, 0)) / float(field))
		water_share.append(float(water.size()) / float(field))
		var comps := _bodies(m, water)
		bodies.append(comps.size())
		var big := 0
		for c in comps:
			big = maxi(big, c.size())
		var edges := {}
		for hx in water:
			edges[Hex.axial_to_offset(hx).x] = true
		biggest.append(big)
		if edges.has(0) and edges.has(w - 1):
			spans += 1
		kinds[m.water_feature] = int(kinds.get(m.water_feature, 0)) + 1
		var cw := m.narrowest_crossing()
		widths[cw] = int(widths.get(cw, 0)) + 1
		opened.append(m.opened.size())
		var ow := 0
		for hx in m.opened.keys():
			if int(m.opened[hx]) == BattleMap.Terrain.WATER:
				ow += 1
		opened_water.append(ow)
		horde_len.append(m.find_path(m.gate, m.rift, []).size())
		for way in WAYS:
			phases[way].append(_best_phases(m, [way], move))
		phases["packs"].append(_best_phases(m, [], Unit.PACK_MOVE))
		var cut := m.horde_cut(cw + 1)
		for way in WAYS:
			var best := 0.0
			var hit := false
			for col in range(w):
				var start := Hex.offset_to_axial(col, h - BattleMap.GATE_ROWS - 1)
				var got := _reach(m, start, [way], int(moves[way]), 2)
				best = maxf(best, float(got.size()) / float(field))
				for c in cut:
					if got.has(c):
						hit = true
			reach[way].append(best)
			if hit:
				at_cut[way] += 1
	var lines: Array[String] = []
	lines.append("# Map survey")
	lines.append("")
	lines.append("Generated by `tools/map_survey.gd` on %s: %d seeds at %dx%d, map type **%s** (`%s`). Phases to the rift are measured with every way of moving at move %d and the packs at their own %d, from its best lane on the team's ground (the row above the gate's apron) to the rift's mouth with nobody in the way; reach uses each way's biggest move in content. Read the bands, not the decimals. The comparison of every map type is at the end." % [Time.get_date_string_from_system(), seeds, w, h, BattleMap.KINDS[kind]["name"], kind, move, Unit.PACK_MOVE])
	lines.append("")
	lines.append("## The ground")
	lines.append("")
	lines.append("| Ground | Share, mean | Range |")
	lines.append("|---|---|---|")
	for tt in [BattleMap.Terrain.PLAIN, BattleMap.Terrain.ROAD, BattleMap.Terrain.ROUGH, BattleMap.Terrain.RUINS, BattleMap.Terrain.WATER, BattleMap.Terrain.MOUNTAIN]:
		var v: Array = shares[tt]
		lines.append("| %s | %d%% | %d%% to %d%% |" % [BattleMap.TERRAIN_NAMES[tt].capitalize() if tt != BattleMap.Terrain.MOUNTAIN else "Crags", roundi(_mean_f(v) * 100.0), roundi(v.min() * 100.0), roundi(v.max() * 100.0)])
	lines.append("")
	lines.append("| Measure | Mean | Range |")
	lines.append("|---|---|---|")
	lines.append("| Water, share of the field | %d%% | %d%% to %d%% |" % [roundi(_mean_f(water_share) * 100.0), roundi(water_share.min() * 100.0), roundi(water_share.max() * 100.0)])
	lines.append("| Water bodies | %.1f | %d to %d |" % [_mean_i(bodies), bodies.min(), bodies.max()])
	lines.append("| The biggest body, hexes | %.1f | %d to %d |" % [_mean_i(biggest), biggest.min(), biggest.max()])
	lines.append("| Hexes the crossing guarantee opened | %.1f | %d to %d |" % [_mean_i(opened), opened.min(), opened.max()])
	lines.append("| of them water | %.1f | %d to %d |" % [_mean_i(opened_water), opened_water.min(), opened_water.max()])
	lines.append("| The horde's route, hexes | %.1f | %d to %d |" % [_mean_i(horde_len), horde_len.min(), horde_len.max()])
	lines.append("| Generation, ms a map | %.0f | %.0f to %.0f |" % [_mean_f(ms), ms.min(), ms.max()])
	lines.append("")
	var kind_names: Array[String] = []
	var ks := kinds.keys()
	ks.sort()
	for k in ks:
		kind_names.append("%s %d" % [k if k != "" else "none", kinds[k]])
	lines.append("The water feature: %s. Water reaches both edges of the field on %d of %d maps (a river's fords split it into bodies)." % [", ".join(kind_names), spans, seeds])
	lines.append("")
	lines.append("## The horde's narrowest crossing")
	lines.append("")
	lines.append("The fewest hexes that together cut every foe route from the rift to the gate (the generator guarantees %d)." % BattleMap.CROSSING_WIDTH)
	lines.append("")
	lines.append("| Hexes | Maps |")
	lines.append("|---|---|")
	var keys := widths.keys()
	keys.sort()
	for k in keys:
		lines.append("| %d | %d |" % [k, widths[k]])
	lines.append("")
	lines.append("## Phases to the rift, at move %d" % move)
	lines.append("")
	lines.append("| Way of moving | Mean | Fewest | Most | Slower than the flyer on |")
	lines.append("|---|---|---|---|---|")
	for way in WAYS + ["packs"]:
		var p: Array = phases[way]
		var slower := 0
		for i in range(p.size()):
			if int(p[i]) > int(phases["flyer"][i]):
				slower += 1
		var name: String = way if way != "packs" else "packs (the horde's rule, %d)" % Unit.PACK_MOVE
		lines.append("| %s | %.1f | %d | %d | %d maps |" % [name, _mean_i(p), p.min(), p.max(), slower])
	lines.append("")
	lines.append("## Reach after two phases, at the content's moves")
	lines.append("")
	lines.append("The share of the field's hexes a way of moving can stand on two phases from its best start, and on how many maps it reaches the horde's narrowest crossing by then. This is where the ground bites: the trip north barely moves, the lanes do.")
	lines.append("")
	lines.append("| Way of moving | Move | Reach, mean | Range | Makes the crossing by phase 2 |")
	lines.append("|---|---|---|---|---|")
	for way in WAYS:
		var r: Array = reach[way]
		lines.append("| %s | %d | %d%% | %d%% to %d%% | %d of %d maps |" % [way, moves[way], roundi(_mean_f(r) * 100.0), roundi(r.min() * 100.0), roundi(r.max() * 100.0), at_cut[way], seeds])
	lines.append("")
	lines.append_array(_compare())
	return "\n".join(lines)


## Every map type side by side, on fewer seeds: shares, the crossing, what the guarantee
## opened, the phases to the rift and the two-phase reach by way of moving.
func _compare() -> Array[String]:
	var n := mini(seeds, 100)
	var lines: Array[String] = ["## The map types compared", "", "Each type on seeds 1 to %d. Shares of the field; the horde's narrowest crossing and the hexes the guarantee opened; the phases to the rift at move %d and the reach after two phases at the content's moves, by way of moving (T tracked, W walker, Wh wheeled, H hover, F flyer)." % [n, move], ""]
	lines.append("| Type | Open | Rough | Ruins | Water | Crags | Crossing | Opened | Phases T/W/Wh/H/F | Reach T/W/Wh/H/F |")
	lines.append("|---|---|---|---|---|---|---|---|---|---|")
	for k in BattleMap.KINDS.keys():
		var sh := {}
		var field := 0
		var opened := 0
		var cw3 := 0
		var ph := {}
		var rc := {}
		for way in WAYS:
			ph[way] = 0.0
			rc[way] = 0.0
		for s in range(1, n + 1):
			var m := BattleMap.generate(w, h, s, k)
			for hx in m.all_hexes():
				if m.is_structure(hx):
					continue
				field += 1
				sh[m.terrain[hx]] = int(sh.get(m.terrain[hx], 0)) + 1
			opened += m.opened.size()
			if m.narrowest_crossing() >= BattleMap.CROSSING_WIDTH:
				cw3 += 1
			var mf := 0
			for hx in m.all_hexes():
				if not m.is_structure(hx):
					mf += 1
			for way in WAYS:
				ph[way] += _best_phases(m, [way], move)
				var best := 0.0
				for col in range(w):
					best = maxf(best, float(_reach(m, Hex.offset_to_axial(col, h - BattleMap.GATE_ROWS - 1), [way], int(moves[way]), 2).size()) / float(mf))
				rc[way] += best
		var pct := func(t: int) -> String: return "%d%%" % roundi(100.0 * int(sh.get(t, 0)) / float(field))
		var open_share := roundi(100.0 * (int(sh.get(BattleMap.Terrain.PLAIN, 0)) + int(sh.get(BattleMap.Terrain.ROAD, 0))) / float(field))
		var phs: Array[String] = []
		var rcs: Array[String] = []
		for way in WAYS:
			phs.append("%.1f" % (ph[way] / n))
			rcs.append("%d" % roundi(100.0 * rc[way] / n))
		lines.append("| %s | %d%% | %s | %s | %s | %s | %d of %d at %d+ | %.1f | %s | %s%% |" % [BattleMap.KINDS[k]["name"], open_share, pct.call(BattleMap.Terrain.ROUGH), pct.call(BattleMap.Terrain.RUINS), pct.call(BattleMap.Terrain.WATER), pct.call(BattleMap.Terrain.MOUNTAIN), cw3, n, BattleMap.CROSSING_WIDTH, float(opened) / n, "/".join(phs), "/".join(rcs)])
	lines.append("")
	return lines


## The fewest phases from any start on the team's ground.
func _best_phases(m: BattleMap, traits: Array, budget: int) -> int:
	var best := 99
	for col in range(w):
		best = mini(best, _phases(m, Hex.offset_to_axial(col, h - BattleMap.GATE_ROWS - 1), traits, budget))
	return best


## The hexes a unit with `traits` can stand on after `k` full phases from `start`.
func _reach(m: BattleMap, start: Vector2i, traits: Array, budget: int, k: int) -> Dictionary:
	if not m.has(start) or not BattleMap.passable(m.terrain[start], traits):
		return {}
	var reached := {start: true}
	for i in range(k):
		reached = _one_phase(m, reached, traits, budget)
	return reached


## One phase's bounded search from every hex in `from`: the hexes reached, each with its
## cost (BattleMap.spend: a wade entered with less than its price left takes the rest).
func _one_phase(m: BattleMap, from: Dictionary, traits: Array, budget: int) -> Dictionary:
	var dist := {}
	var frontier: Array = []
	for s in from.keys():
		dist[s] = 0
		frontier.append([0, s])
	while not frontier.is_empty():
		var best := 0
		for i in range(1, frontier.size()):
			if frontier[i][0] < frontier[best][0]:
				best = i
		var cur: Array = frontier.pop_at(best)
		var d: int = cur[0]
		var hx: Vector2i = cur[1]
		if d > int(dist[hx]):
			continue
		for n in Hex.neighbors(hx):
			if not m.has(n) or m.is_structure(n):
				continue
			var c := BattleMap.spend(m.terrain[n], traits, budget - d)
			if c < 0:
				continue
			if not dist.has(n) or d + c < int(dist[n]):
				dist[n] = d + c
				frontier.append([d + c, n])
	return dist


## Connected bodies of water.
func _bodies(m: BattleMap, water: Array[Vector2i]) -> Array:
	var seen := {}
	var out: Array = []
	for start in water:
		if seen.has(start):
			continue
		var body: Array[Vector2i] = []
		var queue: Array[Vector2i] = [start]
		seen[start] = true
		while not queue.is_empty():
			var cur: Vector2i = queue.pop_front()
			body.append(cur)
			for n in Hex.neighbors(cur):
				if not seen.has(n) and m.has(n) and m.terrain[n] == BattleMap.Terrain.WATER:
					seen[n] = true
					queue.append(n)
		out.append(body)
	return out


## Phases from `start` until a hex beside the rift is reached, every phase a full move by
## the crossing table (BattleMap.spend: a wade entered with less than its price left takes
## the rest). 99 when it never arrives.
func _phases(m: BattleMap, start: Vector2i, traits: Array, budget: int) -> int:
	var goal := {}
	for r in m.rift_hexes:
		for n in Hex.neighbors(r):
			if m.has(n) and not m.is_structure(n):
				goal[n] = true
	if not m.has(start) or not BattleMap.passable(m.terrain[start], traits):
		return 99
	var reached := {start: true}
	for k in range(1, 60):
		var dist := _one_phase(m, reached, traits, budget)
		for hx in dist.keys():
			if goal.has(hx):
				return k
		if dist.size() == reached.size():
			return 99
		reached = dist
	return 99


## The map as text, the odd rows indented a half step: . plain, = road, " rough, # ruins,
## ~ water, ^ crag, G gate, R rift, | wall.
func _picture(m: BattleMap) -> String:
	var glyph := {
		BattleMap.Terrain.PLAIN: ".", BattleMap.Terrain.ROAD: "=", BattleMap.Terrain.ROUGH: "\"",
		BattleMap.Terrain.RUINS: "#", BattleMap.Terrain.WATER: "~", BattleMap.Terrain.MOUNTAIN: "^",
	}
	var rows: Array[String] = ["seed %d, %s, %s, narrowest crossing %d, the guarantee opened %d" % [m.map_seed, BattleMap.KINDS[m.kind]["name"], m.water_feature, m.narrowest_crossing(), m.opened.size()]]
	for row in range(-BattleMap.MARGIN_ROWS, m.height):
		var line := " " if row & 1 else ""
		for col in range(-BattleMap.MARGIN_COLS, m.width + BattleMap.MARGIN_COLS):
			var hx := Hex.offset_to_axial(col, row)
			var g := " "
			if m.gate_hexes.has(hx):
				g = "G"
			elif m.rift_hexes.has(hx):
				g = "R"
			elif m.wall_hexes.has(hx):
				g = "|"
			elif m.has(hx):
				g = glyph[m.terrain[hx]]
			elif m.margin.has(hx):
				g = glyph[m.margin[hx]].to_lower() if m.margin[hx] != BattleMap.Terrain.PLAIN else ","
			if col == 0:
				line += "["
			line += g + (" " if col != -1 and col != m.width - 1 else "")
			if col == m.width - 1:
				line += "]"
		rows.append(line)
	return "\n".join(rows)


func _mean_f(a: Array) -> float:
	var t := 0.0
	for x in a:
		t += x
	return t / maxf(1.0, float(a.size()))


func _mean_i(a: Array) -> float:
	var t := 0.0
	for x in a:
		t += float(x)
	return t / maxf(1.0, float(a.size()))

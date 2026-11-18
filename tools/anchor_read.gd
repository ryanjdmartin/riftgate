extends SceneTree
## The anchor read: every fight of a tier at its rating, by the bot. The measure the numbers
## pass sizes against (docs/briefs/numbers_pass.md; Ryan's hull budget of 9 November: a
## formation's fight a twentieth of the squad's hull at its rating, a flanker's a thirtieth or
## less, a hunter's a tenth, an elite's a quarter, the boss what is left).
##
## Every composition of the kinds asked and every boss, built by the battle's own builders
## and fought by squads drawn from a pool of chassis, each as large as the fight is rated (a
## patrol one machine, a hunter's pack two, a formation three, an elite and a boss four), by
## the greedy bot. Hull lost is a share of a squad of four's: the pool's mean machine, four
## times. A cell is a direction; a kind's mean is a band. It prints markdown and writes no
## file: a read a decision cites is copied into docs/measurements.md.
##
## usage: godot --headless --path . -s tools/anchor_read.gd -- pool=a,b,c,d,e,f [seeds=5]
##        [squads=6] [tier=1] [ramp=1] [kinds=patrol,formation,elite,boss] [only=id,id]
##        [refit=spec] [blows=percent] [split=strikes] [label=text]
##   pool    the chassis ids the squads are drawn from
##   seeds   fights a squad; squads: how many of the pool's squads of that size (0, all)
##   only    the composition or boss ids to read, the rest skipped
##   refit   a what-if laid over content for the run (sim/refit.gd's spec, as --refit takes)
##   blows   a what-if on the leaders alone: every elite's, boss's, hero's and commander's
##           attack at that share of content's, in hundredths (blows=80), a foe a fight
##           fields or a foe it makes later; the rank and file beside them as content has it
##   split   a what-if on the leaders alone: each of their plain blows, one strike at one
##           machine that lands the round it shows and carries no keyword, becomes that many
##           strikes of the same total, a point either way for the rounding (split=2). A blow
##           that gathers, a blow at every machine, a blow with a rider (it would land once a
##           strike) and a move of many strikes stay as content has them; the moves it split
##           are listed under the table


func combos(pool: Array, n: int) -> Array:
	var out: Array = []
	if n <= 0 or n > pool.size():
		return out
	var idx: Array = []
	for i in n:
		idx.append(i)
	while true:
		var pick: Array = []
		for i in idx:
			pick.append(pool[i])
		out.append(pick)
		var k := n - 1
		while k >= 0 and int(idx[k]) == pool.size() - n + k:
			k -= 1
		if k < 0:
			break
		idx[k] = int(idx[k]) + 1
		for j in range(k + 1, n):
			idx[j] = int(idx[j - 1]) + 1
	return out


func _init() -> void:
	var o := {"seeds": "5", "tier": "1", "pool": "", "kinds": "patrol,formation,elite,boss", "ramp": "1", "squads": "0", "label": "", "only": "", "refit": "", "blows": "100", "split": "1"}
	for arg in OS.get_cmdline_user_args():
		var kv := str(arg).split("=", true, 1)
		if kv.size() == 2:
			o[kv[0]] = kv[1]
	var seeds := int(o["seeds"])
	var tier := int(o["tier"])
	var ramp := int(o["ramp"])
	var pool: Array = Array(str(o["pool"]).split(",", false))
	var kinds: Array = Array(str(o["kinds"]).split(",", false))
	var only: Array = Array(str(o["only"]).split(",", false))
	if pool.is_empty():
		push_error("anchor_read: name a pool of chassis, pool=a,b,c")
		quit(1)
		return
	ContentDB.reset_cache()
	var db := ContentDB.load_default()
	for cid in pool:
		if not db.chassis.has(cid):
			push_error("anchor_read: no chassis %s" % cid)
			quit(1)
			return
	if not str(o["refit"]).is_empty():
		for line in Refit.apply(db, Refit.parse(str(o["refit"]))):
			print("what-if: " + str(line))
	var four := 0.0
	var names: Array = []
	for cid in pool:
		names.append(str(db.chassis[cid]["name"]))
		four += float(int(db.chassis[cid]["hull"]))
	four = 4.0 * four / float(maxi(1, pool.size()))
	print("the anchor: tier %d, Convergence %d, greedy, %d seeds a squad, squads of the pool %s; a squad of four's hull %.0f%s" % [tier, ramp, seeds, ", ".join(names), four, (" [" + str(o["label"]) + "]") if not str(o["label"]).is_empty() else ""])
	print("| Domain | Kind | Fight | Machines | Won | Rounds | Of a four's hull | Wrecks a fight | Reboots a machine | Burn, hull a fight | Stalled |")
	print("|---|---|---|---|---|---|---|---|---|---|---|")
	var rows: Array = []
	var seen: Array = []
	for fid in db.factions.keys():
		for kind in ["patrol", "formation", "elite"]:
			if not kinds.has(kind):
				continue
			for c in db.compositions(str(fid), tier, kind, ramp):
				if not seen.has(str(c["id"])):
					seen.append(str(c["id"]))
					rows.append([kind, str(fid), str(c["id"]), c])
		if kinds.has("boss"):
			for bid in db.bosses_of(str(fid)):
				rows.append(["boss", str(fid), str(bid), {}])
	var blows := clampi(int(o["blows"]), 10, 300)
	if blows != 100:
		print("what-if: every leader's attack at %d%% of content's" % blows)
	var split := clampi(int(o["split"]), 1, 6)
	if split != 1:
		print("what-if: every leader's plain blow (one strike at one machine, no countdown, no keyword) lands as %d strikes of the same total" % split)
	var cut := {}   # the moves the split changed, by foe and move: the strikes it lands now
	# A foe as content makes it, a leader's attack at the what-if's share (never under one)
	# and its plain blows split into strikes.
	var lead := func(f: Foe) -> Foe:
		if f == null or not (f.boss or f.elite or f.hero or f.commands):
			return f
		if blows != 100:
			f.attack = maxi(1, roundi(float(f.attack) * float(blows) / 100.0))
		if split != 1:
			var moves: Array = f.actions.duplicate(true)
			for a in moves:
				if Foe.is_attack_action(a) and int(a.get("strikes", 1)) == 1 and Foe.countdown_of(a) == 0 and Array(a.get("keywords", [])).is_empty():
					var whole := f.base_damage_of(a)
					a["strikes"] = split
					a["factor"] = float(a.get("factor", 1.0)) / float(split)
					cut["%s's %s" % [f.display_name, str(a.get("name", a.get("id", "")))]] = "%d as %d×%d" % [whole, split, f.base_damage_of(a)]
			f.actions.assign(moves)
			if not f.actions.is_empty():
				f.action = f.actions[0]
		return f
	var sums := {}
	for row in rows:
		if not only.is_empty() and not only.has(str(row[2])):
			continue
		var rated := 4
		if str(row[0]) != "boss":
			var probe_pack: Unit = Battlefield.pack_of(row[3], str(row[1]))
			rated = probe_pack.squad
		var n := clampi(rated, 1, mini(4, pool.size()))
		var wins := 0; var fights := 0; var rounds := 0; var stalls := 0; var wrecks := 0
		var lost := 0.0; var reboots := 0; var burn := 0
		var all_squads: Array = combos(pool, n)
		var take := int(o["squads"])
		if take > 0 and take < all_squads.size():
			var kept: Array = []
			for i in take:
				kept.append(all_squads[(i * all_squads.size()) / take])
			all_squads = kept
		for squad in all_squads:
			for s in range(1, seeds + 1):
				var sk := Skirmish.new(s)
				var uid := 0
				var units: Array = []
				for cid in squad:
					uid += 1
					var u := db.make_mech(str(cid), uid)
					units.append(u)
					sk.add_mech(u)
				var pack: Unit
				if str(row[0]) == "boss":
					pack = Battle.make_boss_unit(db, str(row[1]), tier - 1, str(row[2]), [str(row[2])], [], ramp)
				else:
					pack = Battlefield.pack_of(row[3], str(row[1]))
					pack.boss_tier = tier - 1
				pack.id = 100
				if not pack.layout.is_empty():
					sk.layout = pack.layout.duplicate()
				sk.foe_factory = func(foe_id: String) -> Foe: return lead.call(db.make_foe(foe_id)) if db.foes.has(foe_id) else null
				var fielded: Array[Foe] = db.foes_for(pack)
				for f in fielded:
					lead.call(f)
				sk.add_foes(fielded, pack)
				sk.begin()
				var pol: Policy = Policy.make(Policy.GREEDY, s)
				if pol.play(sk) == Skirmish.Outcome.VICTORY:
					wins += 1
				if pol.stalled:
					stalls += 1
				fights += 1
				rounds += pol.rounds
				reboots += pol.reboots
				burn += pol.overheat_hull
				for u2 in units:
					lost += float((u2 as Unit).hull_max - maxi(0, (u2 as Unit).hull))
					if (u2 as Unit).hull <= 0:
						wrecks += 1
		var fn := float(maxi(1, fights))
		var kind_label := str(row[0])
		if kind_label == "patrol" and rated >= 2:
			kind_label = "hunter"
		print("| %s | %s | %s | %d | %d%% | %.1f | %.1f%% | %.2f | %.2f | %.1f | %d |" % [str(db.factions[row[1]].get("name", row[1])), kind_label, row[2], n,
			roundi(100.0 * wins / fn), float(rounds) / fn, 100.0 * lost / fn / four, float(wrecks) / fn, float(reboots) / fn / float(n), float(burn) / fn, stalls])
		if not sums.has(kind_label):
			sums[kind_label] = [0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0]
		var v: Array = sums[kind_label]
		v[0] += 1
		v[1] += 100.0 * wins / fn
		v[2] += float(rounds) / fn
		v[3] += 100.0 * lost / fn / four
		v[4] += float(wrecks) / fn
		v[5] += float(reboots) / fn / float(n)
		v[6] += float(burn) / fn
		v[7] += fights
		v[8] += stalls
	for key in sums.keys():
		var v: Array = sums[key]
		print("mean, %s (%d rows, %d fights): won %d%%, %.1f rounds, %.1f%% of a four's hull, %.2f wrecks a fight, %.2f reboots a machine a fight, the burn %.1f hull a fight, %d stalled" % [key, v[0], v[7], roundi(v[1] / v[0]), v[2] / v[0], v[3] / v[0], v[4] / v[0], v[5] / v[0], v[6] / v[0], v[8]])
	if not cut.is_empty():
		var said: Array = []
		for key in cut.keys():
			said.append("%s %s" % [key, cut[key]])
		said.sort()
		print("split: " + ", ".join(said))
	quit(0)

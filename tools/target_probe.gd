extends SceneTree

## Whom the foes strike (23 October, Ryan's question: does the exposed aim pile the blows onto
## the thick machines and take the decisions with it?). Every starter trio a tender can deal
## (three tier-one machines from three city makers, stock), greedy play, against each faction's
## formation, its bosses and its first pack. Per cell it tallies whom each foe picks as the
## round's intents are drawn (the aim's own choice), the same restricted to rounds with every
## machine standing (so a wreck never forces the pick), whom each swings at as the enemy's turn
## opens (after any Lure), the weight the exposed aim gave each machine and whether its shield
## would hold the blow, and the hull each machine lost. The report is read by hand
## (docs/measurements.md, 23 October).
##   perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/target_probe.gd -- --out probe.json [--part 0/4] [--seeds 20]

var db: ContentDB
var out_path := ""
var part := 0
var parts := 1
var seeds := 20


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	for i in range(args.size() - 1):
		match args[i]:
			"--out":
				out_path = args[i + 1]
			"--part":
				var p := args[i + 1].split("/")
				part = int(p[0])
				parts = maxi(1, int(p[1]))
			"--seeds":
				seeds = maxi(1, int(args[i + 1]))
	db = ContentDB.load_default()
	if out_path.is_empty() or not db.load_errors.is_empty():
		push_error("target_probe: --out <file> is needed and the content must load")
		quit(1)
		return
	var trios := _starters()
	var packs := _packs()
	var res := {}
	for i in range(trios.size()):
		if i % parts != part:
			continue
		for p in packs:
			res["+".join(trios[i]) + "|" + str(p["id"])] = _cell(trios[i], p)
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(res))
	f.close()
	quit(0)


## The trios a tender can deal: three of the city makers in file order, a runnable tier-one
## machine of each.
func _starters() -> Array:
	var makers: Array = db.city_makers()
	var ones := {}
	for mk in makers:
		ones[mk] = []
		for id in db.chassis.keys():
			var c: Dictionary = db.chassis[id]
			if str(c.get("maker", "")) == str(mk) and int(c.get("tier", 0)) == 1 and db.chassis_runnable(str(id)):
				ones[mk].append(str(id))
	var out: Array = []
	for a in range(makers.size()):
		for b in range(a + 1, makers.size()):
			for c in range(b + 1, makers.size()):
				for x in ones[makers[a]]:
					for y in ones[makers[b]]:
						for z in ones[makers[c]]:
							out.append([x, y, z])
	return out


## Each faction's formation (its whole spawn list at once), its bosses alone, its first pack.
func _packs() -> Array:
	var out: Array = []
	for fac in db.factions.keys():
		var spawn := db.spawn_table(str(fac), 1)
		if spawn.size() >= 2:
			var mix: Array = []
			for e in spawn:
				mix.append([str(e[0]), int(e[1])])
			out.append({"id": str(fac) + " formation", "mix": mix})
		for boss in db.bosses_of(str(fac)):
			out.append({"id": boss + " x1", "mix": [[boss, 1]]})
		if not spawn.is_empty():
			out.append({"id": "%s x%d" % [spawn[0][0], spawn[0][1]], "mix": [[str(spawn[0][0]), int(spawn[0][1])]]})
	return out


func _cell(trio: Array, p: Dictionary) -> Dictionary:
	var agg := {"fights": 0, "won": 0, "picks": {}, "picks_full": {}, "swings": {}, "exposed_picks": 0,
		"level": 0, "aims": {}, "w_sum": {}, "w_n": {}, "shield_holds": {}, "hull_lost": {}, "hull_max": {}, "stats": {}}
	for s in range(seeds):
		var sk := Skirmish.new(s + 1)
		var uid := 0
		for cid in trio:
			uid += 1
			var u := db.make_mech(str(cid), uid, Vector2i.ZERO)
			sk.add_mech(u)
			agg["stats"][str(cid)] = [u.hull_max, u.shield_max, u.armour]
		var foes: Array = []
		for entry in p["mix"]:
			for n in range(int(entry[1])):
				foes.append(db.make_foe(str(entry[0])))
		sk.add_foes(foes)
		sk.begin()
		var pol := Policy.make(Policy.GREEDY, s + 1)
		var rounds := 0
		while sk.outcome == Skirmish.Outcome.NONE and rounds < Policy.MAX_ROUNDS:
			sk.start_round()
			rounds += 1
			_tally_picks(sk, agg, sk.live_mechs().size() == trio.size())
			pol.play_round(sk)
			if sk.outcome != Skirmish.Outcome.NONE:
				break
			_tally_swings(sk, agg)
			sk.end_round()
		agg["fights"] += 1
		if sk.outcome == Skirmish.Outcome.VICTORY:
			agg["won"] += 1
		for ms in sk.mechs:
			var c: String = ms.unit.chassis_id
			agg["hull_lost"][c] = int(agg["hull_lost"].get(c, 0)) + clampi(ms.unit.hull_max - ms.unit.hull, 0, ms.unit.hull_max)
			agg["hull_max"][c] = int(agg["hull_max"].get(c, 0)) + ms.unit.hull_max
	return agg


## A foe about to strike one machine with an attack (not a blow at every machine).
static func _single_strike(f: Foe) -> bool:
	return f.alive() and f.target != null and not f.is_suppressed() and f.attacks() and not f.hits_all()


func _tally_picks(sk: Skirmish, agg: Dictionary, full: bool) -> void:
	for f in sk.field_foes():
		if not _single_strike(f):
			continue
		var c: String = f.target.unit.chassis_id
		agg["picks"][c] = int(agg["picks"].get(c, 0)) + 1
		if full:
			agg["picks_full"][c] = int(agg["picks_full"].get(c, 0)) + 1
		var aim := f.aim_of()
		agg["aims"][aim] = int(agg["aims"].get(aim, 0)) + 1
		if aim != Foe.AIM_EXPOSED:
			continue
		agg["exposed_picks"] += 1
		var first := -1.0
		var level := true
		for m in sk.targetable_mechs():
			var reach := sk.hull_reached(f, m)
			var broke := sk.shield_broken(f, m)
			var w := 1.0 + float(reach) + float(broke) * 0.5
			if first < 0.0:
				first = w
			elif not is_equal_approx(w, first):
				level = false
			if full:
				var mc: String = m.unit.chassis_id
				agg["w_sum"][mc] = float(agg["w_sum"].get(mc, 0.0)) + w
				agg["w_n"][mc] = int(agg["w_n"].get(mc, 0)) + 1
				if reach == 0 and broke == 0:
					agg["shield_holds"][mc] = int(agg["shield_holds"].get(mc, 0)) + 1
		if level:
			agg["level"] += 1


func _tally_swings(sk: Skirmish, agg: Dictionary) -> void:
	for f in sk.field_foes():
		if _single_strike(f):
			var c: String = f.target.unit.chassis_id
			agg["swings"][c] = int(agg["swings"].get(c, 0)) + 1

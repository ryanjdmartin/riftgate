extends SceneTree

## Formations back to back (25 October, for the quick campaign's proposal: how many complete
## formations a squad gets through in a row, docs/quick_campaign_proposal.md). A squad fights
## one domain's formation (its whole spawn list in one fight, as tools/balance.gd builds it) up
## to CHAIN times, carrying hull, shield, cracks and wrecks from fight to fight, heat starting
## each fight at zero, as a battle's fights do; greedy play, never withdrawing. Each chain is
## run twice: with no shield back between fights (every machine fought, so no field
## recharge), and with one field recharge between them (a map turn's walk to the next pack).
## Squads: every trio the tender can deal or every four (one tier-one machine from each city
## maker, stock), or a JSON file of squads, each a list of [chassis, loadout, modules] (null
## loadout for the stock; `python3 tools/endgame_fours.py --json` prints the endgame fours so).
## The report is read by `tools/chain_probe_read.py`.
##   perl -e 'alarm 5400; exec @ARGV' godot --headless --path . -s tools/chain_probe.gd -- --squads trios --seeds 2 --out build/chain_0.json --part 0/4
## Options: --squads trios|fours|<path>, --seeds N (2), --part i/n, --out path, --density F
## (each spawn entry's strength scaled and rounded, at least 1: a formation's density, read
## before any content moves), --recharge 0|1 (one of the two variants only).

const CHAIN := 9

var db: ContentDB
var squads_arg := "trios"
var seeds := 2
var part := 0
var parts := 1
var out_path := ""
var density := 1.0
var only_recharge := -1


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	for i in range(args.size() - 1):
		var v: String = args[i + 1]
		match args[i]:
			"--squads":
				squads_arg = v
			"--seeds":
				seeds = int(v)
			"--part":
				var p := v.split("/")
				part = int(p[0])
				parts = maxi(1, int(p[1]))
			"--out":
				out_path = v
			"--density":
				density = float(v)
			"--recharge":
				only_recharge = int(v)
	if out_path.is_empty():
		push_error("--out is required")
		quit(1)
		return
	db = ContentDB.load_default()
	var rows: Array = []
	var cell := 0
	for sq in _squads():
		for fac in db.factions.keys():
			for recharge in [false, true]:
				if only_recharge >= 0 and int(recharge) != only_recharge:
					continue
				for s in range(seeds):
					cell += 1
					if (cell - 1) % parts != part:
						continue
					rows.append(_chain(sq, str(fac), recharge, s + 1))
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(rows))
	f.close()
	quit()


## The squads, each a list of [chassis id, loadout or null for the stock, module ids].
func _squads() -> Array:
	if squads_arg != "trios" and squads_arg != "fours":
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(squads_arg))
		return parsed if parsed is Array else []
	# The tender's pools: each city maker's runnable tier ones (Campaign.tender's).
	var pools: Array = []
	for mk in db.city_makers():
		var pool: Array = []
		for id in db.chassis_of_tier(1):
			if str(db.chassis[id].get("maker", "")) == str(mk) and db.chassis_runnable(str(id)):
				pool.append(str(id))
		if not pool.is_empty():
			pools.append(pool)
	var picks: Array = []
	for skip in range(-1, pools.size()):
		# A four takes every pool; a trio leaves one out.
		if (squads_arg == "fours") != (skip == -1):
			continue
		var grown_picks: Array = [[]]
		for k in range(pools.size()):
			if k == skip:
				continue
			var grown: Array = []
			for p in grown_picks:
				for id in pools[k]:
					grown.append(p + [id])
			grown_picks = grown
		picks.append_array(grown_picks)
	var out: Array = []
	for p in picks:
		var sq: Array = []
		for id in p:
			sq.append([id, null, []])
		out.append(sq)
	return out


func _chain(sq: Array, fac: String, recharge: bool, seed_value: int) -> Dictionary:
	var units: Array = []
	var hull_max := 0
	var names: Array = []
	for m in sq:
		var u := db.make_mech(str(m[0]), units.size() + 1, Vector2i.ZERO, m[1], m[2] if m[2] is Array else [])
		units.append(u)
		hull_max += u.hull_max
		names.append(str(m[0]))
	var won := 0
	var hull_after: Array = []
	var alive_after: Array = []
	var rounds: Array = []
	for k in range(CHAIN):
		var live := units.filter(func(u) -> bool: return u.hull > 0)
		if live.is_empty():
			break
		var sk := Skirmish.new(seed_value * 1009 + k * 7 + (1 if recharge else 0))
		sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
		for u in live:
			sk.add_mech(u)
		var foes: Array = []
		for e in db.spawn_table(fac):
			for n in range(maxi(1, roundi(int(e[1]) * density))):
				foes.append(db.make_foe(str(e[0])))
		sk.add_foes(foes)
		sk.begin()
		var pol := Policy.make(Policy.GREEDY, seed_value * 31 + k)
		var outcome := pol.play(sk)
		rounds.append(pol.rounds)
		var h := 0
		var alive := 0
		for u in units:
			if u.hull > 0:
				h += u.hull
				alive += 1
		hull_after.append(100.0 * h / hull_max)
		alive_after.append(alive)
		if outcome != Skirmish.Outcome.VICTORY or pol.stalled:
			break
		won += 1
		if recharge:
			# The walk to the next pack: a map turn out of a fight (Battle.end_turn's recharge).
			for u in units:
				if u.hull > 0:
					u.recharge_shield(u.recharge_field)
					var fired := Effects.fire(u, "out_of_combat")
					if int(fired["shield"]) > 0:
						u.recharge_shield(int(fired["shield"]))
	return {"squad": "+".join(names), "size": sq.size(), "fac": fac, "recharge": recharge, "seed": seed_value,
		"density": density, "won": won, "hull": hull_after, "alive": alive_after, "rounds": rounds}

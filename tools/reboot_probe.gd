extends SceneTree

## The machines the reboot reaches, one at a time (17 November, for docs/reboot_machines_proposal.md):
## each chassis fielded first in a squad of four beside the Honey Badger, the Prairie Dog and the
## Cassowary, which the rule does not reach, against tier one's formations and elites (each
## composition at its own grid) or, with --bosses, tier one's bosses alone; the greedy bot playing.
## Per machine, of its turns: the share it spent, gave to a reboot or held, the share it stood bare
## of shield as the enemy struck, and sealed (the Polar Bear's Lockdown); a fight's overheats, burn
## and vents that blast (the Whip Scorpion's); its own hull lost (percent of its own), its fights wrecked,
## and the squad's hull lost. A direction, never a gate: the bot's play of the reboot is a first
## heuristic, so its losses are a floor of skill. A fight still standing at forty rounds (CAP)
## ends there as it stands.
##   perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/reboot_probe.gd -- --seeds 8
##   perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/reboot_probe.gd -- --bosses --seeds 6 --only kite,badger
## Options: --seeds N (6), --only <chassis ids>, --bosses, --whatif <lean>, --branches <picks> (the
## machine read's upgrades, its directions in the order taken: --branches defence,defence; each
## machine read takes those its chassis allows). Four in parallel, a part of the roster each, read
## the whole roster in about seven minutes.
##
## --whatif lays one of the proposal's leans over the fight loop, where the engine has no switch
## for it, the machine first in the squad the one it reads:
## `kite_bot`, a
## bot that fights a broken Kite on when the die it shows would fell a foe, and `kite_mends`, that
## bot and a kill of its own mending a broken shield. Each is cut here once its lean is built or
## refused: the Polar Bear's, a reboot opening its seal, and the Storm Petrel's, its heat standing
## up its shield, were built on his word the same day.

var db: ContentDB
var seeds := 6
var only: Array = []
var bosses := false
var whatif := ""
var picks: Array = []   # the machine read's branch picks (--branches)

const CAP := 40   # a fight still standing at forty rounds ends there as it stands, the bot stalled


## The bot of the Kite's lean (kite_bot, kite_mends): a broken Kite whose die shows a weapon that
## would fell a foe standing fights for the kill instead of rebooting.
class KiteBot extends Policy:
	func _wants_reboot(sk: Skirmish, ms: Skirmish.MechState) -> bool:
		if ms.shield_broken and ms.overheat_stacks() <= 0 and Effects.refills_on_kill(ms.unit):
			var f := ms.face()
			if f != null and f.is_weapon():
				for foe in sk.field_foes():
					if foe.alive() and sk.shown_number(ms, f, foe) >= foe.hp:
						return false
		return super._wants_reboot(sk, ms)


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	for i in range(args.size()):
		var v: String = args[i + 1] if i + 1 < args.size() else ""
		match args[i]:
			"--seeds":
				seeds = maxi(1, int(v))
			"--only":
				only = Array(v.split(","))
			"--bosses":
				bosses = true
			"--whatif":
				whatif = v
			"--branches":
				picks = Array(v.split(","))
	db = ContentDB.load_default()
	if not db.load_errors.is_empty():
		push_error("content did not load: " + "\n".join(db.load_errors))
		quit(1)
		return
	var mates := ["badger", "prairie_dog", "cassowary"]
	var comps: Array = []
	for fac in db.factions.keys():
		if bosses:
			for b in db.bosses_of(str(fac)):
				comps.append({"members": [[b, 1]], "layout": []})
			continue
		for size in ["formation", "elite"]:
			for c in db.compositions(str(fac), 1, size):
				comps.append(c)
	print("%d %s, %d seeds, the squad's three: %s%s%s" % [comps.size(), "bosses" if bosses else "compositions", seeds, ", ".join(mates),
		"" if whatif.is_empty() else ", what-if " + whatif, "" if picks.is_empty() else ", upgrades " + ",".join(picks)])
	var t0 := Time.get_ticks_msec()
	print("| Machine | Fights | Won | Rounds | Spent | Rebooted | Held | Rounds a reboot | Overheats a fight | Burn a fight | Bare turns | Sealed | Blasts a fight | Own hull lost | Wrecked | Squad hull lost |")
	print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
	for cid in db.chassis.keys():
		if not only.is_empty() and not only.has(str(cid)):
			continue
		if str(db.chassis[cid].get("status", "")) == "planned":
			continue
		var agg := {"fights": 0, "won": 0, "rounds": 0, "turns": 0, "spent": 0, "reboot": 0, "held": 0, "overheats": 0, "burn": 0,
			"bare": 0, "sealed": 0, "blasts": 0, "hull_lost": 0.0, "wrecked": 0, "squad_lost": 0.0}
		for ci in range(comps.size()):
			for s in range(seeds):
				_fight(str(cid), mates, comps[ci], 1000 + s * 7919 + ci * 104729, agg)
		var n := maxf(1.0, float(agg["fights"]))
		var t := maxf(1.0, float(agg["turns"]))
		print("| %s | %d | %d%% | %.1f | %d%% | %d%% | %d%% | %s | %.2f | %.2f | %d%% | %d%% | %.2f | %d%% | %d%% | %d%% |" % [
			str(db.chassis[cid].get("name", cid)), int(agg["fights"]), int(round(100.0 * agg["won"] / n)), agg["rounds"] / n,
			int(round(100.0 * agg["spent"] / t)), int(round(100.0 * agg["reboot"] / t)), int(round(100.0 * agg["held"] / t)),
			("%.1f" % (t / float(agg["reboot"]))) if int(agg["reboot"]) > 0 else "never",
			agg["overheats"] / n, agg["burn"] / n, int(round(100.0 * agg["bare"] / t)), int(round(100.0 * agg["sealed"] / t)),
			agg["blasts"] / n, int(round(agg["hull_lost"] / n)), int(round(100.0 * agg["wrecked"] / n)), int(round(agg["squad_lost"] / n))])
	print("in %.0f s" % ((Time.get_ticks_msec() - t0) / 1000.0))
	quit(0)


## One fight, the machine first in the squad, played round by round so its turns and its blasts are
## read as the player's turn ends (before the burn and the enemy) and its burns as the round does.
func _fight(cid: String, mates: Array, c: Dictionary, seed_value: int, agg: Dictionary) -> void:
	var sk := Skirmish.new(seed_value)
	var uid := 0
	var hull_max := 0
	for id in [cid] + mates:
		uid += 1
		var u := db.make_mech(str(id), uid, Vector2i.ZERO, null, [], picks if id == cid and db.branch_error(cid, picks).is_empty() else [])
		hull_max += u.hull_max
		sk.add_mech(u)
	var fielded: Array = []
	for entry in c["members"]:
		for k in range(int(entry[1])):
			var f := db.make_foe(str(entry[0]))
			var scaled := db.is_boss(str(entry[0])) or db.is_elite(str(entry[0]))
			if scaled:
				db.scale_boss(f, 0)   # tier one's numbers, as the runner fields them
			fielded.append(f)
			for part in db.parts_for(f):
				if scaled:
					db.scale_boss(part, 0)
				fielded.append(part)
	sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
	sk.add_foes(fielded)
	if not Array(c["layout"]).is_empty():
		sk.layout = Array(c["layout"]).duplicate()
	sk.begin()
	var pol: Policy = Policy.make(Policy.GREEDY, seed_value)
	if whatif == "kite_bot" or whatif == "kite_mends":
		pol = KiteBot.new()
		pol.kind = Policy.GREEDY
		pol.rng.seed = seed_value
	var me: Skirmish.MechState = sk.mechs[0]
	var rounds := 0
	while sk.outcome == Skirmish.Outcome.NONE and rounds < CAP:
		sk.start_round()
		rounds += 1
		var alive := me.alive()
		var log_from := sk.log.size()
		pol.play_round(sk)
		var valves := "%s opens its valves" % me.unit.display_name   # a reboot's vent that blasts, in the player's turn
		for line in sk.log.slice(log_from):
			if str(line).begins_with(valves):
				agg["blasts"] += 1
		if whatif == "kite_mends" and me.alive() and me.killed_round and me.shield_broken:
			me.shield_broken = false
			me.unit.shield = me.unit.shield_max
		if alive:
			agg["turns"] += 1
			if me.rebooting:
				agg["reboot"] += 1
			elif me.spends > 0:
				agg["spent"] += 1
			else:
				agg["held"] += 1
			if me.unit.shield <= 0:
				agg["bare"] += 1
			if Effects.is_sealed(me.unit):
				agg["sealed"] += 1
		if sk.outcome != Skirmish.Outcome.NONE:
			break
		sk.end_round()
		for o in sk.overheats:
			if int(o["mech"]) == 0:
				agg["burn"] += int(o.get("burn", o["over"]))
				if bool(o.get("first", false)):
					agg["overheats"] += 1
	agg["fights"] += 1
	agg["rounds"] += rounds
	if sk.outcome == Skirmish.Outcome.VICTORY:
		agg["won"] += 1
	agg["hull_lost"] += 100.0 * float(me.unit.hull_max - maxi(0, me.unit.hull)) / float(me.unit.hull_max)
	if not me.alive():
		agg["wrecked"] += 1
	var left := 0
	for ms in sk.mechs:
		left += maxi(0, ms.unit.hull)
	agg["squad_lost"] += 100.0 * float(hull_max - left) / float(hull_max)

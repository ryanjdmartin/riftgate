extends SceneTree

## The machines the reboot reaches, one at a time (17 November, for docs/reboot_machines_proposal.md):
## each chassis fielded first in a squad of four beside the Honey Badger, the Prairie Dog and the
## Cassowary, which the rule does not reach, against tier one's formations and elites (each
## composition at its own grid) or, with --bosses, tier one's bosses alone; the greedy bot playing.
## Per machine, of its turns: the share it spent, gave to a reboot or held, the share it stood bare
## of shield as the enemy struck, and sealed (the Polar Bear's Lockdown); a fight's overheats, burn
## and vents that blast (the Whip Scorpion's); its own hull lost (percent of its own), its fights wrecked,
## and the squad's hull lost; under the table, a machine that spends its shield into its blows (the
## Buzzard's zap and its cannon, 18 November): its zaps a fight, its shots of the whole shield and
## the shield each fired; one whose reboot may be its second spend (the Needletail's, the same
## day): how many of its reboots came after a spend of its own; and one that ramps Ricochet (the
## Skua's, 19 November): its peak stacks a fight and its halvings; one that moves heat (the Puffin's,
## 19 November): its pulls a fight and the heat each took, its dumps and the heat each passed. For
## every machine, the share of their turns the squad's other three gave to a reboot, since a machine
## that takes its allies' heat is read by theirs. A direction, never a gate: the bot's play of the reboot is a first
## heuristic, so its losses are a floor of skill. A fight still standing at forty rounds (CAP)
## ends there as it stands.
##   perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/reboot_probe.gd -- --seeds 8
##   perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/reboot_probe.gd -- --bosses --seeds 6 --only kite,badger
## Options: --seeds N (6), --only <chassis ids>, --bosses, --branches <picks> (the
## machine read's upgrades, its directions in the order taken: --branches defence,defence; each
## machine read takes those its chassis allows), --dump-per N (a what-if: the heat a stack of a
## dump's buff stands for, on every piece that passes heat; 0 grants none: the Puffin's Empowered for
## every 2, Ryan, 19 November: "We can try empowered for 2 but that needs data"). Four in parallel, a part of the roster each, read
## the whole roster in about seven minutes.
##
## The proposal's leans it laid over its fight loop went with their calls: the Polar Bear's and
## the Storm Petrel's built (17 November), the Kite's kill that mends and the Skua's spared stacks
## refused (19 November: "Leave it"); a lean to come gets its what-if again (git keeps the form).

var db: ContentDB
var seeds := 6
var only: Array = []
var bosses := false
var picks: Array = []   # the machine read's branch picks (--branches)
var dump_per := -1      # --dump-per: the dump's step as a what-if; -1 leaves content's

const CAP := 40   # a fight still standing at forty rounds ends there as it stands, the bot stalled


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
			"--branches":
				picks = Array(v.split(","))
			"--dump-per":
				dump_per = maxi(0, int(v))
	db = ContentDB.load_default()
	if not db.load_errors.is_empty():
		push_error("content did not load: " + "\n".join(db.load_errors))
		quit(1)
		return
	if dump_per >= 0:
		for cid in db.components.keys():
			var face: Dictionary = db.components[cid].get("face", {})
			if bool(face.get("passes_heat", false)):
				face["heat_per_stack"] = dump_per if dump_per > 0 else 1000   # a step no gauge reaches: no stack
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
		"" if picks.is_empty() else ", upgrades " + ",".join(picks), "" if dump_per < 0 else ", a dump's stack every %s" % (str(dump_per) if dump_per > 0 else "never")])
	var t0 := Time.get_ticks_msec()
	print("| Machine | Fights | Won | Rounds | Spent | Rebooted | Held | Rounds a reboot | Overheats a fight | Burn a fight | Bare turns | Sealed | Blasts a fight | Own hull lost | Wrecked | Squad hull lost | Mates rebooted |")
	print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
	var spent_shield: Array[String] = []   # the lines under the table
	for cid in db.chassis.keys():
		if not only.is_empty() and not only.has(str(cid)):
			continue
		if str(db.chassis[cid].get("status", "")) == "planned":
			continue
		var agg := {"fights": 0, "won": 0, "rounds": 0, "turns": 0, "spent": 0, "reboot": 0, "held": 0, "overheats": 0, "burn": 0,
			"bare": 0, "sealed": 0, "blasts": 0, "hull_lost": 0.0, "wrecked": 0, "squad_lost": 0.0,
			"zaps": 0, "whole": 0, "whole_shield": 0, "spend_reboot": 0,
			"peak": 0, "halvings": 0, "halved_rebooting": 0, "stacks_lost": 0,
			"pulls": 0, "pulled": 0, "dumps": 0, "dumped": 0, "mate_turns": 0, "mate_reboots": 0}
		for ci in range(comps.size()):
			for s in range(seeds):
				_fight(str(cid), mates, comps[ci], 1000 + s * 7919 + ci * 104729, agg)
		var n := maxf(1.0, float(agg["fights"]))
		var t := maxf(1.0, float(agg["turns"]))
		print("| %s | %d | %d%% | %.1f | %d%% | %d%% | %d%% | %s | %.2f | %.2f | %d%% | %d%% | %.2f | %d%% | %d%% | %d%% | %d%% |" % [
			str(db.chassis[cid].get("name", cid)), int(agg["fights"]), int(round(100.0 * agg["won"] / n)), agg["rounds"] / n,
			int(round(100.0 * agg["spent"] / t)), int(round(100.0 * agg["reboot"] / t)), int(round(100.0 * agg["held"] / t)),
			("%.1f" % (t / float(agg["reboot"]))) if int(agg["reboot"]) > 0 else "never",
			agg["overheats"] / n, agg["burn"] / n, int(round(100.0 * agg["bare"] / t)), int(round(100.0 * agg["sealed"] / t)),
			agg["blasts"] / n, int(round(agg["hull_lost"] / n)), int(round(100.0 * agg["wrecked"] / n)), int(round(agg["squad_lost"] / n)),
			int(round(100.0 * agg["mate_reboots"] / maxf(1.0, float(agg["mate_turns"]))))])
		if int(agg["pulls"]) + int(agg["dumps"]) > 0:
			spent_shield.append("%s: %.2f pulls a fight, %s heat each; %.2f dumps a fight, %s heat each" % [
				str(db.chassis[cid].get("name", cid)), agg["pulls"] / n, ("%.1f" % (float(agg["pulled"]) / float(agg["pulls"]))) if int(agg["pulls"]) > 0 else "no",
				agg["dumps"] / n, ("%.1f" % (float(agg["dumped"]) / float(agg["dumps"]))) if int(agg["dumps"]) > 0 else "no"])
		if int(agg["peak"]) > 0:
			spent_shield.append("%s: Ricochet at its peak %.1f stacks a fight; %.2f halvings a fight, %.2f of them while it rebooted, %.1f stacks lost" % [
				str(db.chassis[cid].get("name", cid)), agg["peak"] / n, agg["halvings"] / n, agg["halved_rebooting"] / n, agg["stacks_lost"] / n])
		if int(agg["spend_reboot"]) > 0:
			spent_shield.append("%s: %d of its %d reboots after a spend of its own (its second spend the reboot)" % [
				str(db.chassis[cid].get("name", cid)), int(agg["spend_reboot"]), int(agg["reboot"])])
		if int(agg["zaps"]) + int(agg["whole"]) > 0:
			spent_shield.append("%s: %.2f zaps a fight; %.2f shots of the whole shield a fight, %s shield each" % [
				str(db.chassis[cid].get("name", cid)), agg["zaps"] / n, agg["whole"] / n,
				("%.1f" % (float(agg["whole_shield"]) / float(agg["whole"]))) if int(agg["whole"]) > 0 else "no"])
	for line in spent_shield:
		print(line)
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
	var me: Skirmish.MechState = sk.mechs[0]
	var rounds := 0
	var peak := 0   # the most Ricochet it held this fight (the Skua's)
	while sk.outcome == Skirmish.Outcome.NONE and rounds < CAP:
		sk.start_round()
		rounds += 1
		var alive := me.alive()
		var alive_mates: Array[bool] = []
		for m in sk.mechs:
			alive_mates.append(m.alive())
		var log_from := sk.log.size()
		pol.play_round(sk)
		var valves := "%s opens its valves" % me.unit.display_name   # a reboot's vent that blasts, in the player's turn
		var zapped := "%s pays " % me.unit.display_name   # a zap paid (Skirmish._pay_zap's line)
		var whole := "%s fires its whole shield: -" % me.unit.display_name   # the shield fired whole (Skirmish._hit's line)
		var takes := "%s takes " % me.unit.display_name   # a pull (Skirmish._pull_heat's line)
		var passes := "%s passes " % me.unit.display_name   # a dump (Skirmish._pass_heat's line)
		for line in sk.log.slice(log_from):
			var said := str(line)
			if said.begins_with(valves):
				agg["blasts"] += 1
			elif said.begins_with(zapped) and said.contains("shield into the blow"):
				agg["zaps"] += 1
			elif said.begins_with(whole):
				agg["whole"] += 1
				agg["whole_shield"] += int(said.substr(whole.length()).get_slice(",", 0))
			elif said.begins_with(takes) and said.contains(" heat off "):
				agg["pulls"] += 1
				agg["pulled"] += int(said.substr(takes.length()).get_slice(" ", 0))
			elif said.begins_with(passes) and said.contains(" heat to "):
				agg["dumps"] += 1
				agg["dumped"] += int(said.substr(passes.length()).get_slice(" ", 0))
		if alive:
			agg["turns"] += 1
			if me.rebooting:
				agg["reboot"] += 1
				if me.spends > 0:
					agg["spend_reboot"] += 1   # the Needletail's: a spend, then the reboot as its second
			elif me.spends > 0:
				agg["spent"] += 1
			else:
				agg["held"] += 1
			if me.unit.shield <= 0:
				agg["bare"] += 1
			if Effects.is_sealed(me.unit):
				agg["sealed"] += 1
		for k in range(1, sk.mechs.size()):
			if alive_mates[k]:
				agg["mate_turns"] += 1
				if sk.mechs[k].rebooting:
					agg["mate_reboots"] += 1
		peak = maxi(peak, Effects.stacks_of(me.unit, "ricochet"))
		if sk.outcome != Skirmish.Outcome.NONE:
			break
		var held_stacks := Effects.stacks_of(me.unit, "ricochet")
		var was_rebooting := me.rebooting
		sk.end_round()
		var left_stacks := Effects.stacks_of(me.unit, "ricochet")
		if left_stacks < held_stacks and me.alive():
			agg["halvings"] += 1
			agg["stacks_lost"] += held_stacks - left_stacks
			if was_rebooting:
				agg["halved_rebooting"] += 1
		for o in sk.overheats:
			if int(o["mech"]) == 0:
				agg["burn"] += int(o.get("burn", o["over"]))
				if bool(o.get("first", false)):
					agg["overheats"] += 1
	agg["peak"] += maxi(peak, Effects.stacks_of(me.unit, "ricochet"))
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

extends SceneTree

## The behaviour trace (the skirmish code audit's structural steps, 8 November): for a change that
## must change nothing, a byte-for-byte record of the skirmish engine over many seeded fights, run
## on main and on the change and compared. Every runnable chassis fights in a stock team (the
## default four, then each chassis with the next two) and in kit teams whose loadouts cycle through
## every component content has, so each component is fitted and spent; every composition at every
## tier it names (its grid as a battle deals it), every boss alone at each tier and every spawn
## list's foe at its strength meets a stock team and two kit teams, random and greedy, at each seed.
## Around every spend, reroll and round's end it records what the game and the bot can observe: the
## round preview with and without the die in hand, every machine's forecast, the die's numbers and
## reads, the spend's blows, rolls, last acts and returns, the enemy turn's events, and the save's
## whole fight dictionary. Writes one line an event, its label and an md5, to <out>.hash, and every
## fight's log to <out>.log; `--fight "<id>"` writes one fight's events whole instead, to read the
## first line two trees part on. About four minutes on four cores at two seeds.
##   for i in 0 1 2 3; do godot --headless --path . -s tools/behaviour_trace.gd -- --out build/trace_$i --part $i/4 & done; wait
## Options: --out base (required), --seeds N (2), --part i/n (every n-th fight from the i-th),
## --fight id (one fight, its id as a .log's "###" line names it, written whole).

var out_base := ""
var seeds := 2
var part := -1
var parts := 1
var only_fight := ""
var full := false
var hash_lines: Array[String] = []
var log_lines: Array[String] = []


## The fight, recording what can be observed around every call the bot makes into it.
class TraceSkirmish extends Skirmish:
	var tr = null      # the tool
	var tag := ""
	var events := 0
	var seen_log := 0

	func _emit(label: String, blob: String) -> void:
		events += 1
		tr.emit("%s #%d %s" % [tag, events, label], blob)

	func _new_log() -> String:
		var lines: Array[String] = []
		for i in range(seen_log, log.size()):
			lines.append(log[i])
		seen_log = log.size()
		return "\n".join(lines)

	func _state() -> String:
		var d := SaveGame._fight_dict(self)
		d.erase("log")
		return JSON.stringify(d, "", true, true)

	## What the screen and the bot read with a die in hand, before its spend.
	func _reads(mech_index: int, target) -> String:
		var bits: Array = []
		bits.append(tr.ser(preview_round()))
		if target != null:
			bits.append(tr.ser(preview_round(mech_index, target)))
		for i in range(mechs.size()):
			var m: Skirmish.MechState = mechs[i]
			if not m.alive():
				continue
			bits.append(tr.ser(forecast(m)))
		var ms: Skirmish.MechState = mechs[mech_index]
		if ms.alive() and ms.face() != null and not ms.assigned:
			var raw := spend_face(ms)
			var foe: Foe = target if target is Foe else null
			var sf := shown_face(ms, raw, foe)
			bits.append(tr.ser(sf.to_dict() if sf != null else {}))
			bits.append(str(shown_number(ms, sf, foe)))
			bits.append(shown_number_text(ms, sf, foe))
			bits.append(tr.ser(lure_turns(ms, foe)))
			bits.append(tr.ser(shut_gates(ms, sf, foe)))
			bits.append(str(after_blow(ms, sf, foe)))
			bits.append(tr.ser(targets_for_face(ms, raw)))
			bits.append(str(can_spend(mech_index)))
			bits.append(str(can_assign(mech_index, target)))
		return "\n".join(bits)

	func assign(mech_index: int, target = null, second = null) -> bool:
		_emit("reads", _reads(mech_index, target))
		var ok := super.assign(mech_index, target, second)
		var after := [str(ok), tr.ser(spend_blows), tr.ser(last_roll), tr.ser(last_acts), tr.ser(returned), tr.ser(reach_tally), tr.ser(mine_tally), tr.ser(sponsorship), str(team_kills)]
		_emit("assign %d %s %s" % [mech_index, tr.ser(target), tr.ser(second)], _new_log() + "\n" + "\n".join(after) + "\n" + _state())
		return ok

	func reroll(indices: Array) -> bool:
		var ok := super.reroll(indices)
		_emit("reroll %s" % str(indices), str(ok) + "\n" + _new_log() + "\n" + _state())
		return ok

	func start_round() -> void:
		super.start_round()
		_emit("start_round", _new_log() + "\n" + _state())

	func end_round() -> int:
		var bits: Array = [tr.ser(preview_round())]
		for m in live_mechs():
			bits.append(tr.ser(forecast(m)))
			bits.append(tr.ser(incoming_for(m)))
		for f in field_foes():
			bits.append(str(rally_worth(f)))
			bits.append(str(hp_after_ticks(f)))
		_emit("before end", "\n".join(bits))
		var r := super.end_round()
		_emit("end_round", str(r) + "\n" + _new_log() + "\n" + tr.ser(turn_events) + "\n" + tr.ser(turn_specials) + "\n" + tr.ser(overheats) + "\n" + _state())
		return r


func emit(label: String, blob: String) -> void:
	if full:
		hash_lines.append("== " + label + "\n" + blob)
	else:
		hash_lines.append("%s %s" % [label, blob.md5_text()])


## A value as text, the same in every run: a dictionary by its sorted keys, an object by what it is.
func ser(v) -> String:
	if v == null:
		return "null"
	if v is Dictionary:
		var keys: Array = []
		var by := {}
		for k in v.keys():
			var ks := ser(k)
			keys.append(ks)
			by[ks] = v[k]
		keys.sort()
		var out: Array[String] = []
		for ks in keys:
			out.append("%s:%s" % [ks, ser(by[ks])])
		return "{" + ",".join(out) + "}"
	if v is Array:
		var out: Array[String] = []
		for x in v:
			out.append(ser(x))
		return "[" + ",".join(out) + "]"
	if v is Foe:
		var f: Foe = v
		return "Foe(%s/%s r%d c%d hp%d)" % [f.content_id, f.display_name, f.rank, f.column, f.hp]
	if v is Skirmish.MechState:
		return "Mech(%s)" % (v as Skirmish.MechState).unit.display_name
	if v is Unit:
		return "Unit(%s)" % (v as Unit).display_name
	if v is Face:
		return "Face" + ser((v as Face).to_dict())
	if v is Effects.Modifier:
		var m: Effects.Modifier = v
		return "Mod(%s %d %s %d)" % [m.id, m.stacks, m.source, m.expires_round]
	if v is Callable:
		return "callable"
	if v is Object:
		return "Object(%s)" % v.get_class()
	return var_to_str(v)


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var a := args[i]
		var val := args[i + 1] if i + 1 < args.size() else ""
		match a:
			"--out":
				out_base = val
				i += 1
			"--seeds":
				seeds = int(val)
				i += 1
			"--part":
				var bits := val.split("/")
				part = int(bits[0])
				parts = maxi(1, int(bits[1]) if bits.size() > 1 else 1)
				i += 1
			"--fight":
				only_fight = val
				full = true
				i += 1
		i += 1
	if out_base.is_empty():
		push_error("--out wanted: the base path of the .hash and .log it writes")
		quit(1)
		return
	var db := ContentDB.load_default()
	if not db.load_errors.is_empty():
		push_error("content did not load: " + "\n".join(db.load_errors))
		quit(1)
		return
	var chassis: Array = []
	for id in db.chassis.keys():
		if db.chassis_runnable(str(id)):
			chassis.append(str(id))
	chassis.sort()
	# A machine is [chassis id, loadout or null for its stock].
	var comps: Array = []
	for cid in db.components.keys():
		comps.append(str(cid))
	comps.sort()
	var stock_teams: Array = []
	var dt: Array = []
	for cid in db.default_team(4):
		dt.append([str(cid), null])
	stock_teams.append(dt)
	for k in range(chassis.size()):
		stock_teams.append([[chassis[k], null], [chassis[(k + 1) % chassis.size()], null], [chassis[(k + 2) % chassis.size()], null]])
	var kit: Array = [[], []]
	var at := [0, 37]
	for v in range(2):
		for cid in chassis:
			var hp := int(db.chassis[cid].get("hardpoints", 4))
			var lo: Array = []
			for j in range(hp):
				lo.append(comps[(at[v] + j) % comps.size()])
			at[v] += hp
			kit[v].append([cid, lo])
	var kit_teams: Array = []
	for v in range(2):
		for k in range(chassis.size()):
			kit_teams.append([kit[v][k], kit[v][(k + 5) % chassis.size()], kit[v][(k + 11) % chassis.size()]])
	# The packs: {id, mix: [[foe, n]], tier (scale_boss's, from 0), layout}.
	var packs: Array = []
	for fac in db.factions.keys():
		for t in [1, 2, 3]:
			for c in db.compositions(str(fac), t):
				packs.append({"id": "%s %s t%d" % [fac, str(c["id"]), t], "mix": c["members"].duplicate(true), "tier": t - 1, "layout": c["layout"]})
		for boss in db.bosses_of(str(fac)):
			for t in [1, 2, 3]:
				packs.append({"id": "%s boss %s t%d" % [fac, boss, t], "mix": [[boss, 1]], "tier": t - 1})
		for t in [1, 2, 3]:
			for entry in db.spawn_table(fac, t):
				if db.foes.has(entry[0]):
					packs.append({"id": "%s spawn %s x%d t%d" % [fac, entry[0], entry[1], t], "mix": [[str(entry[0]), int(entry[1])]], "tier": t - 1})
	var fights := 0
	var cell := 0
	var t0 := Time.get_ticks_msec()
	for pi in range(packs.size()):
		var p: Dictionary = packs[pi]
		var teams: Array = [stock_teams[pi % stock_teams.size()], kit_teams[pi % kit_teams.size()], kit_teams[(pi * 7 + 3) % kit_teams.size()]]
		for team in teams:
			var names: Array[String] = []
			for m in team:
				names.append(str(m[0]) if m[1] == null else "%s[%s]" % [m[0], ",".join(m[1])])
			for k in [Policy.RANDOM, Policy.GREEDY]:
				for s in range(seeds):
					var fid := "%s|%s|%s|%d" % ["+".join(names), p["id"], Policy.kind_name(k), s + 1]
					cell += 1
					if part >= 0 and (cell % parts) != part:
						continue
					if not only_fight.is_empty() and fid != only_fight:
						continue
					_fight(db, team, p, k, s + 1, fid)
					fights += 1
	var secs := (Time.get_ticks_msec() - t0) / 1000.0
	var f := FileAccess.open(out_base + ".hash", FileAccess.WRITE)
	if f == null:
		push_error("cannot write %s.hash" % out_base)
		quit(1)
		return
	f.store_string("\n".join(hash_lines) + "\n")
	f.close()
	var g := FileAccess.open(out_base + ".log", FileAccess.WRITE)
	g.store_string("\n".join(log_lines) + "\n")
	g.close()
	print("behaviour trace: %d fights, %d events in %.0f s" % [fights, hash_lines.size(), secs])
	quit(0)


func _fight(db: ContentDB, team: Array, p: Dictionary, k: int, seed_value: int, fid: String) -> void:
	var sk := TraceSkirmish.new(seed_value)
	sk.tr = self
	sk.tag = fid
	var uid := 0
	for m in team:
		uid += 1
		sk.add_mech(db.make_mech(str(m[0]), uid, Vector2i.ZERO, m[1], []))
	var foes: Array = []
	for entry in p["mix"]:
		for n in range(int(entry[1])):
			var fo := db.make_foe(str(entry[0]))
			if int(p.get("tier", 0)) > 0 and (db.is_boss(str(entry[0])) or db.is_elite(str(entry[0]))):
				db.scale_boss(fo, int(p["tier"]))
			foes.append(fo)
	var fielded: Array = []
	for fo in foes:
		fielded.append(fo)
		for pt in db.parts_for(fo):
			if int(p.get("tier", 0)) > 0 and (db.is_boss(fo.content_id) or db.is_elite(fo.content_id)):
				db.scale_boss(pt, int(p["tier"]))
			fielded.append(pt)
	sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
	sk.add_foes(fielded)
	if p.has("layout"):
		sk.layout = Array(p["layout"]).duplicate()
	sk.begin()
	sk._emit("begin", sk._new_log() + "\n" + sk._state())
	var pol := Policy.make(k, seed_value)
	var outcome := pol.play(sk)
	sk._emit("done", "%d %d %d %s" % [outcome, pol.rounds, int(pol.stalled), ser(pol.spends)])
	log_lines.append("### " + fid)
	for line in sk.log:
		log_lines.append(line)

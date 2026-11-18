extends SceneTree

## How often each foe special can fire, and what its gate is worth (24 October, Ryan's question:
## do the Cockatrice's Stone and the Drake's Stoke ever fire?). Starter trios, stock, greedy
## play, against each domain's formation, each boss alone and each hero alone; every cell
## played as built and, when OPENED names conditions, again on the same seeds with those read
## as always true (its run of 24 October opened the three that read the player's state, a
## machine at a heat, a machine showing a weapon and a reroll left, which went after it). Per
## special it tallies the rounds its foe drew a move, the draws its condition held, and the
## draws that picked it, and each fight's overheats and the hull they cost. --heat N scales every
## foe's heat stacks (its Scorch riders and its scorch_all moves) by N before the
## fights, to size a buff; --only a,b keeps the cells whose names hold one of the words.
##   perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/special_probe.gd -- --out build/special_0.json --part 0/4 --seeds 10 --step 3

const OPENED := []

class ProbeSkirmish extends Skirmish:
	var opened: Array = []

	func _when_word_holds(f: Foe, a: Dictionary, w: String) -> bool:
		if opened.has(w):
			return true
		return super(f, a, w)


var db: ContentDB
var out_path := ""
var seeds := 10
var step := 1
var part := 0
var parts := 1
var heat := 1.0
var only: Array = []


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	for i in range(args.size() - 1):
		match args[i]:
			"--out":
				out_path = args[i + 1]
			"--seeds":
				seeds = maxi(1, int(args[i + 1]))
			"--step":
				step = maxi(1, int(args[i + 1]))
			"--part":
				var p := args[i + 1].split("/")
				part = int(p[0])
				parts = maxi(1, int(p[1]))
			"--heat":
				heat = float(args[i + 1])
			"--only":
				only = Array(args[i + 1].split(","))
	db = ContentDB.load_default()
	if out_path.is_empty() or not db.load_errors.is_empty():
		push_error("special_probe: --out <file> is needed and the content must load")
		quit(1)
		return
	if not is_equal_approx(heat, 1.0):
		_scale_heat(heat)
	var trios := _starters()
	var picked: Array = []
	for i in range(0, trios.size(), step):
		picked.append(trios[i])
	var cells: Array = []
	for c in _cells():
		if only.is_empty() or only.any(func(w) -> bool: return str(c["id"]).contains(str(w))):
			cells.append(c)
	var res := {"trios": picked.size(), "cells": cells.size(), "seeds": seeds, "heat": heat, "rows": {}}
	var n := 0
	for t in picked:
		for c in cells:
			n += 1
			if n % parts != part:
				continue
			for variant in (["built", "open"] if not OPENED.is_empty() else ["built"]):
				res["rows"]["%s|%s|%s" % ["+".join(t), str(c["id"]), variant]] = _run(t, c, variant == "open")
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


## Each domain's formation (its whole spawn list at once), each boss alone, each hero alone.
func _cells() -> Array:
	var out: Array = []
	for fac in db.factions.keys():
		var spawn := db.spawn_table(str(fac), 1)
		if not spawn.is_empty():
			var mix: Array = []
			for e in spawn:
				mix.append([str(e[0]), int(e[1])])
			out.append({"id": str(fac) + " formation", "mix": mix})
		for boss in db.bosses_of(str(fac)):
			out.append({"id": boss + " x1", "mix": [[boss, 1]]})
	for id in db.foes.keys():
		var e: Dictionary = db.foes[id]
		if bool(e.get("hero", false)) and not e.has("promotes"):
			out.append({"id": str(id) + " x1", "mix": [[str(id), 1]]})
	return out


func _run(trio: Array, cell: Dictionary, opened: bool) -> Dictionary:
	var agg := {"fights": 0, "won": 0, "rounds": 0, "hull_lost": 0, "hull_max": 0, "overheats": 0, "over_hull": 0, "fights_overheated": 0, "specials": {}}
	for s in range(seeds):
		var sk := ProbeSkirmish.new(s + 1)
		if opened:
			sk.opened = OPENED
		var uid := 0
		for cid in trio:
			uid += 1
			sk.add_mech(db.make_mech(str(cid), uid, Vector2i.ZERO))
		var foes: Array = []
		for entry in cell["mix"]:
			for k in range(int(entry[1])):
				foes.append(db.make_foe(str(entry[0])))
		sk.add_foes(foes)
		sk.begin()
		var pol := Policy.make(Policy.GREEDY, s + 1)
		var rounds := 0
		var burnt := false
		while sk.outcome == Skirmish.Outcome.NONE and rounds < Policy.MAX_ROUNDS:
			var carried := {}
			for f in sk.field_foes():
				carried[f] = not f.pending.is_empty()
			sk.start_round()
			rounds += 1
			_tally(sk, agg, carried)
			pol.play_round(sk)
			if sk.outcome != Skirmish.Outcome.NONE:
				break
			sk.end_round()
			for o in sk.overheats:
				agg["overheats"] += 1
				agg["over_hull"] += int(o.get("burn", o["over"]))
				burnt = true
		if burnt:
			agg["fights_overheated"] += 1
		agg["fights"] += 1
		agg["rounds"] += rounds
		if sk.outcome == Skirmish.Outcome.VICTORY:
			agg["won"] += 1
		for ms in sk.mechs:
			agg["hull_lost"] += clampi(ms.unit.hull_max - ms.unit.hull, 0, ms.unit.hull_max)
			agg["hull_max"] += ms.unit.hull_max
	return agg


## Each foe that drew a move this round (not one holding a gathered countdown): for every special
## in its kit, whether the condition held as it drew and whether it was the pick.
func _tally(sk: ProbeSkirmish, agg: Dictionary, carried: Dictionary) -> void:
	for f in sk.field_foes():
		if carried.get(f, false):
			continue
		for a in f.actions:
			if Foe.is_attack_action(a) and Foe.whens_of(a).is_empty():
				continue
			if str(a.get("status", "implemented")) == "planned":
				continue
			var key := "%s:%s" % [f.content_id, str(a.get("id", ""))]
			var row: Dictionary = agg["specials"].get(key, {"draws": 0, "held": 0, "picked": 0, "when": ",".join(PackedStringArray(Foe.whens_of(a)))})
			row["draws"] += 1
			if sk._when_holds(f, a):
				row["held"] += 1
			if str(f.action.get("id", "")) == str(a.get("id", "")):
				row["picked"] += 1
			agg["specials"][key] = row


## Every foe's heat stacks scaled by `k` (rounded, one at least): its Scorch riders and the
## stacks its scorch_all moves lay. Ablate is damage since 15 November, and no heat of a foe's.
func _scale_heat(k: float) -> void:
	for id in db.foes.keys():
		for a in db.foes[id].get("actions", []):
			if a.has("scorch"):
				a["scorch"] = maxi(1, roundi(float(a["scorch"]) * k))
			if str(a.get("effect", "")) == "scorch_all":
				a["value"] = maxi(1, roundi(float(a.get("value", 0)) * k))

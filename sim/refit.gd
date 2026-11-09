class_name Refit
extends RefCounted

## The refit pass's what-if (docs/briefs/refit_pass.md; Ryan's direction of 9 November: shields and
## vents leave the die, a component a weapon or equipment, the shield innate and regenerating,
## cooling passive, the hold the heat decision). It lays that model over a loaded ContentDB, the
## copy in memory and never the files, so the runners and the harness read the game as the pass
## would make it before any content moves. Every number it sets is a placeholder a read is asked
## about; nothing here is a decision, and it goes when the pass's content lands.
##
## It names no content id (CLAUDE.md: ids are Ryan's to rename): the pieces are found by what
## their entries do.
##
## A spec is a comma-separated list, the runners' --refit:
##   die        the model's die: every stock shield and vent swapped for a defensive basic (below),
##              the machines the model cannot field left undealt, a chassis whose one way down was
##              a vent cooling 1
##   regen=half every chassis regains half its shield a round, rounded up (the first numbers' lean);
##   regen=N    or a flat N on every chassis, 0 to 9
##   cooling=N  every chassis cools N more a round (a read of the offset; may be negative)
##   heat1      every tier-zero weapon makes 1 heat at least (the basics at heat one)
##   barrier=off        with die: no Barrier basic, the Armoured one alone and guns in the other slots
##   barrier=cooldown   with die: the Barrier basic goes dark for the next round once spent
##   barrier=heatN      with die: the Barrier basic makes N heat
##   barrier=ward       with die: a Ward in the Barrier basic's place (a breach lands on the shield)
##   vents=guns         with die: a vent's slot takes a tier-zero gun, so a die holds a defensive
##                      basic only where a shield stood (the audit's own deal, the stock re-deal's
##                      placeholder); without it a vent's slot takes the defensive basic the die lacks
##   all        die, regen=half and heat1 together: the model as leaned

const BARRIER := "barrier"   # the statuses a defensive basic grants (the engine's words)
const ARMOURED := "braced"
const WARD := "ward"

## What a chassis's passive may do that the model has no entry left to feed: sealing on a shield
## it spends, blasting with its vents, growing a shield it grants. A chassis carrying one is back
## in design (the brief's section 6) and is not fielded under the model's die.
const DEAD_EFFECTS := ["seal_form", "vent_blast"]
const DEAD_TRIGGERS := ["on_shield_granted"]


static func parse(text: String) -> Dictionary:
	var spec := {"die": false, "regen": "", "cooling": 0, "heat1": false, "barrier": "", "vents": ""}
	for part in text.split(",", false):
		var p := part.strip_edges()
		if p == "all":
			spec["die"] = true
			spec["regen"] = "half"
			spec["heat1"] = true
		elif p == "die":
			spec["die"] = true
		elif p == "heat1":
			spec["heat1"] = true
		elif p.begins_with("regen="):
			spec["regen"] = p.trim_prefix("regen=")
		elif p.begins_with("cooling="):
			spec["cooling"] = int(p.trim_prefix("cooling="))
		elif p.begins_with("barrier="):
			spec["barrier"] = p.trim_prefix("barrier=")
		elif p.begins_with("vents="):
			spec["vents"] = p.trim_prefix("vents=")
		elif not p.is_empty():
			push_error("--refit: no part '%s' (die, regen=half|N, cooling=N, heat1, barrier=off|cooldown|heatN|ward, vents=guns, all)" % p)
	return spec


## Lay the model over `db` as the spec says. Returns what it did, a line a change, for a report's
## head.
static func apply(db: ContentDB, spec: Dictionary) -> Array[String]:
	var notes: Array[String] = []
	if bool(spec.get("die", false)):
		notes.append_array(_die(db, str(spec.get("barrier", "")), str(spec.get("vents", ""))))
	var regen := str(spec.get("regen", ""))
	if not regen.is_empty():
		var said: Array[String] = []
		for id in db.chassis.keys():
			var c: Dictionary = db.chassis[id]
			var n := int(ceil(float(int(c.get("shield", 0))) / 2.0)) if regen == "half" else int(regen)
			c["shield_regen"] = clampi(n, 0, 9)
			said.append("%s %d" % [str(c.get("name", id)), int(c["shield_regen"])])
		notes.append("shield regen a round (%s): %s" % ["half the gauge, rounded up" if regen == "half" else "flat", ", ".join(said)])
	var cooling := int(spec.get("cooling", 0))
	if cooling != 0:
		for id in db.chassis.keys():
			db.chassis[id]["cooling"] = maxi(0, int(db.chassis[id].get("cooling", 0)) + cooling)
		notes.append("cooling: every chassis %+d a round" % cooling)
	if bool(spec.get("heat1", false)):
		var warmed: Array[String] = []
		for cid in db.components.keys():
			var face = db.components[cid].get("face", null)
			if db.component_tier(str(cid)) == 0 and face is Dictionary and str(face.get("kind", "")) == "attack" \
					and int(face.get("power", 0)) > 0 and int(face.get("heat", 0)) < 1:
				face["heat"] = 1
				warmed.append(str(db.components[cid].get("name", cid)))
		if not warmed.is_empty():
			notes.append("the basics at heat one: %s" % ", ".join(warmed))
	return notes


## The chassis the model's die cannot field, by id: a passive that reads a shield or a vent spent,
## or a locked piece that is a shield, or a vent that reloads nothing (a vent that reloads is the
## Musk Ox's reload, equipment under the model, and plays as it does).
static func sent_back(db: ContentDB) -> Array:
	var out: Array = []
	for id in db.chassis.keys():
		var c: Dictionary = db.chassis[id]
		var dead := false
		var p = c.get("passive", null)
		if p is Dictionary:
			for e in p.get("effects", []):
				if DEAD_EFFECTS.has(str(e.get("effect", ""))) or DEAD_TRIGGERS.has(str(e.get("trigger", ""))):
					dead = true
		for cid in c.get("fixed", []):
			var face: Dictionary = db.components.get(cid, {}).get("face", {})
			var kind := str(face.get("kind", ""))
			if kind == "shield" or (kind == "vent" and int(face.get("reloads_ammo", 0)) <= 0):
				dead = true
		if dead:
			out.append(str(id))
	return out


## The lowest-tier slottable buff that grants `status`, in content order: the defensive basic
## the model's die carries. "" when content has none.
static func basic_granting(db: ContentDB, status: String) -> String:
	var best := ""
	var best_tier := 99
	for cid in db.components.keys():
		var c: Dictionary = db.components[cid]
		var face = c.get("face", null)
		var tier := db.component_tier(str(cid))
		if tier == ContentDB.NO_TIER or not (face is Dictionary) or str(c.get("status", "implemented")) == "planned":
			continue
		if str(face.get("kind", "")) == "buff" and str(face.get("status", "")) == status and tier < best_tier:
			best = str(cid)
			best_tier = tier
	return best


## The first tier-zero gun, in content order: what a slot takes once the die holds both basics.
static func basic_gun(db: ContentDB) -> String:
	for cid in db.components.keys():
		var face = db.components[cid].get("face", null)
		if db.component_tier(str(cid)) == 0 and face is Dictionary and str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
			return str(cid)
	return ""


## The model's die: a shield a chassis stocks for itself alone becomes the Armoured basic, any
## other shield the Barrier basic, each the other where the die holds the first already; a vent
## becomes the Barrier basic where the die holds none, else the Armoured one, else a basic gun.
## Entries keep their places (a stepping die's order is its plan). The chassis the model cannot
## field are marked planned, so the tender and the runners leave them out; one whose one way down
## was a vent (cooling 0) cools 1.
static func _die(db: ContentDB, barrier_rule: String = "", vents_rule: String = "") -> Array[String]:
	var notes: Array[String] = []
	var barrier := basic_granting(db, BARRIER)
	var armoured := basic_granting(db, ARMOURED)
	var gun := basic_gun(db)
	if barrier.is_empty() or armoured.is_empty() or gun.is_empty():
		push_error("the refit what-if: content has no slottable Barrier, Armoured piece or basic gun")
		return notes
	# The Barrier basic's price, a question the first reads raised (a free Barrier on every stock
	# die is spent every round it is rolled): none, a round dark once spent, so much heat, or no
	# Barrier among the basics at all.
	if barrier_rule == "off":
		barrier = gun
		notes.append("no Barrier among the basics: the Armoured piece alone, guns in the other slots")
	elif barrier_rule == "cooldown":
		db.components[barrier]["face"]["cooldown"] = 2   # a cooldown counts the round of the spend (Face.cooldown), so two is the next round dark
		notes.append("the Barrier basic goes dark for the next round once spent")
	elif barrier_rule.begins_with("heat"):
		db.components[barrier]["face"]["heat"] = int(barrier_rule.trim_prefix("heat"))
		notes.append("the Barrier basic makes %d heat" % int(barrier_rule.trim_prefix("heat")))
	elif barrier_rule == "ward":
		# The first reads' other question: every hull-costing cell is a breach, which the regen
		# cannot touch; a Ward turns the round's breaches onto the shield the regen refills.
		var ward := basic_granting(db, WARD)
		if ward.is_empty():
			push_error("the refit what-if: content has no slottable Ward piece")
		else:
			barrier = ward
			notes.append("a Ward in the Barrier basic's place: %s" % str(db.components[ward].get("name", ward)))
	var back := sent_back(db)
	var names: Array[String] = []
	for id in back:
		var p = db.chassis[id].get("passive", null)
		if p is Dictionary:
			p["status"] = "planned"   # undealt and unmeasured (ContentDB.chassis_runnable)
		names.append(str(db.chassis[id].get("name", id)))
	if not names.is_empty():
		notes.append("back in design, not fielded: %s" % ", ".join(names))
	var swapped: Array[String] = []
	for id in db.chassis.keys():
		if back.has(str(id)):
			continue
		var c: Dictionary = db.chassis[id]
		var loadout: Array = (c.get("loadout", []) as Array).duplicate()
		var kinds: Array = []
		var had_vent := false
		for cid in loadout:
			var face: Dictionary = db.components.get(cid, {}).get("face", {})
			kinds.append([str(face.get("kind", "")), str(face.get("targets", ""))])
			had_vent = had_vent or str(face.get("kind", "")) == "vent"
		var holds := {barrier: barrier != gun and loadout.has(barrier), armoured: loadout.has(armoured)}
		var said: Array[String] = []
		# The shields first, then the vents, each in its own slot.
		for pass_kind in ["shield", "vent"]:
			for i in range(loadout.size()):
				if str(kinds[i][0]) != pass_kind:
					continue
				var want := armoured if (pass_kind == "shield" and str(kinds[i][1]) == "self") else barrier
				var other := barrier if want == armoured else armoured
				var pick := want if not bool(holds[want]) else (other if not bool(holds[other]) else gun)
				if pass_kind == "vent" and vents_rule == "guns":
					pick = gun   # the audit's own deal: a vent retires, and its slot is the re-deal's
				if holds.has(pick) and pick != gun:
					holds[pick] = true
				said.append("%s for %s" % [str(db.components[pick].get("name", pick)), str(db.components[loadout[i]].get("name", loadout[i]))])
				loadout[i] = pick
		if not said.is_empty():
			c["loadout"] = loadout
			swapped.append("%s (%s)" % [str(c.get("name", id)), "; ".join(said)])
		if had_vent and int(c.get("cooling", 0)) <= 0:
			c["cooling"] = 1
			notes.append("%s cools 1 a round: its vent was its one way down" % str(c.get("name", id)))
	if vents_rule == "guns":
		notes.append("a vent's slot takes a gun: a defensive basic only where a shield stood")
	if not swapped.is_empty():
		notes.append("the model's die, %d chassis: %s" % [swapped.size(), ", ".join(swapped)])
	return notes

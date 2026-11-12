class_name Refit
extends RefCounted

## The refit pass's what-ifs (docs/briefs/refit_pass.md). The model itself is content since 10
## November (Ryan: "The re-deal with regen and heat ... seems like the correct way to go ... start
## with the minimal swaps"): no stock die holds a shield or a vent, every chassis regains its own
## `shield_regen` a round, the basics make heat, and the machines back in design are undealt. What
## is left here are the numbers a read may still be asked about, laid over a loaded ContentDB, the
## copy in memory and never the files. Nothing here is a decision.
##
## It names no content id (CLAUDE.md: ids are Ryan's to rename): the pieces are found by what
## their entries do.
##
## A spec is a comma-separated list, the runners' --refit and the game's RIFTGATE_REFIT:
##   regen=N    every chassis regains a flat N a round, 0 to 9, in place of its own number
##   regen=half every chassis regains half its shield a round, rounded up (the pass's first lean,
##              far too much by Ryan's first read of 10 November)
##   cooling=N  every chassis that cools at all cools N more a round (a read of the offset; may
##              be negative); one that cools nothing keeps its rule
##   hotter=N   every weapon makes N more heat, fixed pieces too, and a passive that rewrites
##              its machine's weapons its shot's (a read of how much hotter the guns must run
##              before heat is a pace; Ryan, 10 November: "Heat generation is too low")
##   barrier=cooldown   the Barrier basic goes dark for the next round once spent
##   barrier=heatN      the Barrier basic makes N heat

const BARRIER := "barrier"   # the status the Barrier basic grants (the engine's word)


static func parse(text: String) -> Dictionary:
	var spec := {"regen": "", "cooling": 0, "hotter": 0, "barrier": ""}
	for part in text.split(",", false):
		var p := part.strip_edges()
		if p.begins_with("regen="):
			spec["regen"] = p.trim_prefix("regen=")
		elif p.begins_with("cooling="):
			spec["cooling"] = int(p.trim_prefix("cooling="))
		elif p.begins_with("hotter="):
			spec["hotter"] = int(p.trim_prefix("hotter="))
		elif p.begins_with("barrier="):
			spec["barrier"] = p.trim_prefix("barrier=")
		elif not p.is_empty():
			push_error("--refit: no part '%s' (regen=half|N, cooling=N, hotter=N, barrier=cooldown|heatN; the model's die, its regen by chassis and the basics' heat are content since 10 November)" % p)
	return spec


## Lay the what-if over `db` as the spec says. Returns what it did, a line a change, for a report's
## head.
static func apply(db: ContentDB, spec: Dictionary) -> Array[String]:
	var notes: Array[String] = []
	var regen := str(spec.get("regen", ""))
	if not regen.is_empty():
		var said: Array[String] = []
		for id in db.chassis.keys():
			var c: Dictionary = db.chassis[id]
			var n := int(ceil(float(int(c.get("shield", 0))) / 2.0)) if regen == "half" else int(regen)
			c["shield_regen"] = clampi(n, 0, 9)
			said.append("%s %d" % [str(c.get("name", id)), int(c["shield_regen"])])
		notes.append("shield regen a round (%s, in place of each chassis's own): %s" % ["half the gauge, rounded up" if regen == "half" else "flat", ", ".join(said)])
	var cooling := int(spec.get("cooling", 0))
	if cooling != 0:
		for id in db.chassis.keys():
			var cools := int(db.chassis[id].get("cooling", 0))
			if cools > 0:   # a chassis that cools nothing is so by its rule, and no offset moves it
				db.chassis[id]["cooling"] = maxi(0, cools + cooling)
		notes.append("cooling: every chassis that cools %+d a round" % cooling)
	var hotter := int(spec.get("hotter", 0))
	if hotter != 0:
		var n := 0
		for cid in db.components.keys():
			var face = db.components[cid].get("face", null)
			if face is Dictionary and str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
				face["heat"] = maxi(0, int(face.get("heat", 0)) + hotter)
				n += 1
		# A machine whose passive rewrites every weapon it fires into one shot: that shot is its
		# weapons' heat, so it moves with them.
		for id in db.chassis.keys():
			for e in (db.chassis[id].get("passive", {}) as Dictionary).get("effects", []):
				if e is Dictionary and str(e.get("effect", "")) == "rewrite_weapon" and e.has("heat"):
					e["heat"] = maxi(0, int(e["heat"]) + hotter)
		notes.append("every weapon makes %+d heat (%d weapons)" % [hotter, n])
	# The Barrier basic's price, a question the first reads raised (a free Barrier is spent every
	# round it is rolled): a round dark once spent, or so much heat.
	var barrier_rule := str(spec.get("barrier", ""))
	if not barrier_rule.is_empty():
		var barrier := basic_granting(db, BARRIER)
		if barrier.is_empty():
			push_error("the refit what-if: content has no slottable Barrier piece")
		elif barrier_rule == "cooldown":
			db.components[barrier]["face"]["cooldown"] = 2   # a cooldown counts the round of the spend (Face.cooldown), so two is the next round dark
			notes.append("the Barrier basic goes dark for the next round once spent")
		elif barrier_rule.begins_with("heat"):
			db.components[barrier]["face"]["heat"] = int(barrier_rule.trim_prefix("heat"))
			notes.append("the Barrier basic makes %d heat" % int(barrier_rule.trim_prefix("heat")))
		else:
			push_error("--refit: barrier=%s is no rule (cooldown, heatN)" % barrier_rule)
	return notes


## The lowest-tier slottable buff that grants `status`, in content order: the basic of its kind.
## "" when content has none.
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

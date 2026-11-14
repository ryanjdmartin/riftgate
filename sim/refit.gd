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
##   basics=N   every basic gun deals N more, a rolled one at both ends (Ryan, 14 November: "A
##              'standard' vanilla shot should be 1 less than our 'standard' fodder health": a
##              read of the vanilla a point up; section 23 of the brief); may be negative
##   top=N      the basic guns that deal more than the plainest basic gun make N more heat (the
##              same day: the gun that deals one more "needs to bite appropriately", and "for
##              basics, the only cost we should have is Heat")
##   barrier=cooldownN  the Barrier basic sits out N rounds once spent, after the round of the
##                      spend (a cooldown's own count); 0 for none, and the bare word is 1
##   barrier=heatN      the Barrier basic makes N heat
##   barrier=none       the Barrier basic leaves the stock dice, the Armoured basic in its slot
##                      (the Barrier's place, open since 12 November: a basic, or rare or locked)

const BARRIER := "barrier"   # the status the Barrier basic grants (the engine's word)
const ARMOURED := "braced"   # the status the Armoured basic grants


static func parse(text: String) -> Dictionary:
	var spec := {"regen": "", "cooling": 0, "hotter": 0, "basics": 0, "top": 0, "barrier": ""}
	for part in text.split(",", false):
		var p := part.strip_edges()
		if p.begins_with("regen="):
			spec["regen"] = p.trim_prefix("regen=")
		elif p.begins_with("cooling="):
			spec["cooling"] = int(p.trim_prefix("cooling="))
		elif p.begins_with("hotter="):
			spec["hotter"] = int(p.trim_prefix("hotter="))
		elif p.begins_with("basics="):
			spec["basics"] = int(p.trim_prefix("basics="))
		elif p.begins_with("top="):
			spec["top"] = int(p.trim_prefix("top="))
		elif p.begins_with("barrier="):
			spec["barrier"] = p.trim_prefix("barrier=")
		elif not p.is_empty():
			push_error("--refit: no part '%s' (regen=half|N, cooling=N, hotter=N, basics=N, top=N, barrier=cooldownN|heatN|none; the model's die, its regen by chassis and the basics' heat are content since 10 November)" % p)
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
	# The basic guns' own numbers (the brief's section 23): the damage of every one, and the heat
	# of those that deal more than the plainest, which is the price his logic gives the point.
	var basics := int(spec.get("basics", 0))
	var top := int(spec.get("top", 0))
	if basics != 0 or top != 0:
		var guns := basic_guns(db)
		var plain := 0
		for cid in guns:
			var power := int(db.components[cid]["face"].get("power", 0))
			plain = power if plain == 0 else mini(plain, power)
		var said: Array[String] = []
		for cid in guns:
			var face: Dictionary = db.components[cid]["face"]
			var over := int(face.get("power", 0)) > plain
			if basics != 0:
				if face.has("power_max"):
					face["power_max"] = maxi(1, int(face["power_max"]) + basics)
				face["power"] = maxi(1, int(face.get("power", 0)) + basics)
			if top != 0 and over:
				face["heat"] = maxi(0, int(face.get("heat", 0)) + top)
			said.append("%s %d for %d heat" % [str(db.components[cid].get("name", cid)), int(face["power"]), int(face.get("heat", 0))])
		notes.append("the basic guns (%+d damage, %+d heat on those over the plainest): %s" % [basics, top, ", ".join(said)])
	# The Barrier basic's price, a question the first reads raised (a free Barrier is spent every
	# round it is rolled): so many rounds dark once spent, or so much heat. The number is a
	# cooldown's own, the rounds sat out after the round of the spend; until 12 November this
	# wrote 2 for "the next round dark", the count of the day before, and so read two rounds.
	var barrier_rule := str(spec.get("barrier", ""))
	if not barrier_rule.is_empty():
		var barrier := basic_granting(db, BARRIER)
		if barrier.is_empty():
			push_error("the refit what-if: content has no slottable Barrier piece")
		elif barrier_rule.begins_with("cooldown"):
			var dark := 1 if barrier_rule == "cooldown" else maxi(0, int(barrier_rule.trim_prefix("cooldown")))
			if dark > 0:
				db.components[barrier]["face"]["cooldown"] = dark
			else:
				(db.components[barrier]["face"] as Dictionary).erase("cooldown")
			notes.append("the Barrier basic sits out %d round%s once spent" % [dark, "" if dark == 1 else "s"])
		elif barrier_rule.begins_with("heat"):
			db.components[barrier]["face"]["heat"] = int(barrier_rule.trim_prefix("heat"))
			notes.append("the Barrier basic makes %d heat" % int(barrier_rule.trim_prefix("heat")))
		elif barrier_rule == "none":
			# The Barrier off the starting dice (its place is open since 12 November: Ryan, "Should
			# it be rare or locked?"): every stock slot that holds the Barrier basic holds the
			# Armoured basic, the piece itself untouched for whoever finds one.
			var jack := basic_granting(db, ARMOURED)
			if jack.is_empty():
				push_error("the refit what-if: content has no slottable Armoured piece to stand in the Barrier basic's slot")
			else:
				var dice := 0
				for id in db.chassis.keys():
					var loadout = db.chassis[id].get("loadout", [])
					if not (loadout is Array):
						continue
					for i in range((loadout as Array).size()):
						if str(loadout[i]) == barrier:
							loadout[i] = jack
							dice += 1
				notes.append("the Barrier basic leaves the stock dice: the Armoured basic in its slot on %d" % dice)
		else:
			push_error("--refit: barrier=%s is no rule (cooldownN, heatN, none)" % barrier_rule)
	return notes


## The basic guns, in content order: every tier-zero piece the engine runs whose entry is a
## weapon that deals damage.
static func basic_guns(db: ContentDB) -> Array[String]:
	var out: Array[String] = []
	for cid in db.components.keys():
		var c: Dictionary = db.components[cid]
		var face = c.get("face", null)
		if str(c.get("status", "")) == "planned" or not (face is Dictionary) or db.component_tier(str(cid)) != 0:
			continue
		if str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
			out.append(str(cid))
	return out


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

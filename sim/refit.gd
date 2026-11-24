class_name Refit
extends RefCounted

## The refit pass's what-ifs (docs/briefs/refit_pass.md). The model itself is content since 10
## November (Ryan: "The re-deal with regen and heat ... seems like the correct way to go ... start
## with the minimal swaps"): no stock die holds a shield or a vent, the basics make heat, and the
## machines back in design are undealt; and since the reboot's fold-in of 15 November no chassis
## regains shield or cools by itself, so the parts that moved either are gone. What is left here
## are the numbers a read may still be asked about, laid over a loaded ContentDB, the copy in
## memory and never the files. Nothing here is a decision.
##
## It names no content id (CLAUDE.md: ids are Ryan's to rename): the pieces are found by what
## their entries do.
##
## A spec is a comma-separated list, the runners' --refit and the game's RIFTGATE_REFIT:
##   hotter=N   every weapon makes N more heat, fixed pieces too, and a passive that rewrites
##              its machine's weapons its shot's (a read of how much hotter the guns must run
##              before heat is a pace; Ryan, 10 November: "Heat generation is too low")
##   top=N      the basic guns that deal more than the plainest basic gun make N more heat (Ryan,
##              14 November: the gun that deals one more "needs to bite appropriately", and "for
##              basics, the only cost we should have is Heat"). The vanilla's own point, the
##              `basics` part until 15 November, is content: the basic guns deal 3
##   foehp=N    every foe a tier-one formation fields that is no massive, and what such a foe
##              leaves as it falls, has N more hit points (Ryan, 15 November: "Ok let's go 3
##              against 5 or 3 against 4 as the options": the standard foe a point up, so
##              both can be played); may be negative, never under one
##   barrier=cooldownN  the Barrier basic sits out N rounds once spent, after the round of the
##                      spend (a cooldown's own count); 0 for none, and the bare word is 1
##   barrier=heatN      the Barrier basic makes N heat
##   barrier=none       the Barrier basic leaves the stock dice, the Armoured basic in its slot
##                      (the Barrier's place, open since 12 November: a basic, or rare or locked)
##   finds=N    the squad a few battles into its tier: on every tier-one stock die up to N basic
##              guns give their slots to found guns of that tier and their reach, dealt round the
##              tier's finds in content order, so a squad carries a spread of them and never the
##              best alone (Ryan, 23 November: "the player is going to go through power spikes as
##              they outfit their units ... if they don't scale with me they'll become a joke at
##              C4"). A read of what a kit's growth inside a tier is worth against foes that hold
##              still, so the forms a Convergence apart can be sized to it
##   face=ID:KEY=N:KEY=N   one piece's entry rewritten for the run, as many parts as pieces: its
##              power, strikes, heat or reach, a keyword with its number (penetrate=2; =0 takes
##              the keyword off), or its tier (tier=2, out of tier one's finds). The id is the
##              spec's, so the tier-one bench can be read at the anchor before a piece of it is
##              content (docs/briefs/numbers_pass.md, section 6, has the spec)

const BARRIER := "barrier"   # the status the Barrier basic grants (the engine's word)
const ARMOURED := "braced"   # the status the Armoured basic grants


static func parse(text: String) -> Dictionary:
	var spec := {"hotter": 0, "top": 0, "foehp": 0, "barrier": "", "finds": 0, "faces": []}
	for part in text.split(",", false):
		var p := part.strip_edges()
		if p.begins_with("hotter="):
			spec["hotter"] = int(p.trim_prefix("hotter="))
		elif p.begins_with("top="):
			spec["top"] = int(p.trim_prefix("top="))
		elif p.begins_with("foehp="):
			spec["foehp"] = int(p.trim_prefix("foehp="))
		elif p.begins_with("barrier="):
			spec["barrier"] = p.trim_prefix("barrier=")
		elif p.begins_with("finds="):
			spec["finds"] = int(p.trim_prefix("finds="))
		elif p.begins_with("face="):
			(spec["faces"] as Array).append(p.trim_prefix("face="))
		elif not p.is_empty():
			push_error("--refit: no part '%s' (hotter=N, top=N, foehp=N, finds=N, face=ID:KEY=N, barrier=cooldownN|heatN|none; the model's die and the basics' heat are content since 10 November, regen= and cooling= left with the chassis's own on 15 November, and basics= and breach= with the vanilla's 3 and breach's cut the same day)" % p)
	return spec


## Lay the what-if over `db` as the spec says. Returns what it did, a line a change, for a report's
## head.
static func apply(db: ContentDB, spec: Dictionary) -> Array[String]:
	var notes: Array[String] = []
	# face=: a piece's entry rewritten, before anything reads the pieces (the finds' pool is by
	# tier and reach).
	for text in spec.get("faces", []):
		var bits := str(text).split(":", false)
		var cid := str(bits[0]) if bits.size() > 0 else ""
		if not db.components.has(cid) or not (db.components[cid].get("face", null) is Dictionary):
			push_error("--refit: face= names no component '%s'" % cid)
			continue
		var piece: Dictionary = db.components[cid]
		var entry: Dictionary = piece["face"]
		var said: Array[String] = []
		for i in range(1, bits.size()):
			var kv := str(bits[i]).split("=", true, 1)
			if kv.size() != 2:
				continue
			var key := str(kv[0])
			if key == "tier":
				piece["tier"] = int(kv[1])
			elif key == "reach":
				entry["reach"] = str(kv[1])
			elif ["power", "strikes", "heat"].has(key):
				entry[key] = int(kv[1])
			else:   # a keyword with its number; none takes the keyword off
				var words: Array = Array(entry.get("keywords", [])).duplicate()
				if int(kv[1]) > 0:
					entry[key] = int(kv[1])
					if not words.has(key):
						words.append(key)
				else:
					entry.erase(key)
					words.erase(key)
				entry["keywords"] = words
			said.append("%s %s" % [key, str(kv[1])])
		notes.append("%s: %s" % [str(piece.get("name", cid)), ", ".join(said)])
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
	# The basic guns' heat (the brief's section 23): that of those that deal more than the
	# plainest, which is the price his logic gives the point.
	var top := int(spec.get("top", 0))
	if top != 0:
		var guns := basic_guns(db)
		var plain := 0
		for cid in guns:
			var power := int(db.components[cid]["face"].get("power", 0))
			plain = power if plain == 0 else mini(plain, power)
		var said: Array[String] = []
		for cid in guns:
			var face: Dictionary = db.components[cid]["face"]
			var over := int(face.get("power", 0)) > plain
			if over:
				face["heat"] = maxi(0, int(face.get("heat", 0)) + top)
			said.append("%s %d for %d heat" % [str(db.components[cid].get("name", cid)), int(face["power"]), int(face.get("heat", 0))])
		notes.append("the basic guns (%+d heat on those over the plainest): %s" % [top, ", ".join(said)])
	# The standard foe's hit points (the vocabulary pass, 15 November): tier one's rank and file
	# a point up or down, the massive foes, the elites and the bosses as content has them.
	var foehp := int(spec.get("foehp", 0))
	if foehp != 0:
		var raised: Array[String] = []
		for fid in rank_and_file(db):
			db.foes[fid]["hp"] = maxi(1, int(db.foes[fid].get("hp", 1)) + foehp)
			raised.append("%s %d" % [str(db.foes[fid].get("name", fid)), int(db.foes[fid]["hp"])])
		notes.append("tier one's rank and file (%+d hit points): %s" % [foehp, ", ".join(raised)])
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
	# The squad a few battles in: found guns of tier one in the basic guns' slots.
	var finds := int(spec.get("finds", 0))
	if finds > 0:
		var by_reach := {}   # reach -> the tier's found guns of it, in content order
		for cid in db.components.keys():
			var c: Dictionary = db.components[cid]
			var face = c.get("face", null)
			if str(c.get("status", "")) == "planned" or not (face is Dictionary) or db.is_basic(str(cid)) or db.component_tier(str(cid)) != 1:
				continue
			if str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
				var reach := str(face.get("reach", ""))
				if not by_reach.has(reach):
					by_reach[reach] = []
				(by_reach[reach] as Array).append(str(cid))
		var basics := basic_guns(db)
		var dealt := {}   # reach -> how many dealt so far, so the finds go round
		var dice := 0
		var slots := 0
		for id in db.chassis.keys():
			if int(db.chassis[id].get("tier", 0)) != 1:
				continue
			var loadout = db.chassis[id].get("loadout", [])
			if not (loadout is Array):
				continue
			var swapped := 0
			for i in range((loadout as Array).size()):
				if swapped >= finds or not basics.has(str(loadout[i])):
					continue
				var reach := str(db.components[str(loadout[i])]["face"].get("reach", ""))
				var pool: Array = by_reach.get(reach, [])
				if pool.is_empty():
					continue
				loadout[i] = pool[int(dealt.get(reach, 0)) % pool.size()]
				dealt[reach] = int(dealt.get(reach, 0)) + 1
				swapped += 1
			if swapped > 0:
				dice += 1
				slots += swapped
		var said: Array[String] = []
		for reach in by_reach.keys():
			said.append("%s: %s" % [reach, ", ".join((by_reach[reach] as Array).map(func(c): return str(db.components[c].get("name", c))))])
		notes.append("up to %d basic guns a tier-one die swapped for the tier's finds (%d slots on %d dice; %s)" % [finds, slots, dice, "; ".join(said)])
	return notes


## The basic guns, in content order: every basic the engine runs whose entry is a
## weapon that deals damage.
static func basic_guns(db: ContentDB) -> Array[String]:
	var out: Array[String] = []
	for cid in db.components.keys():
		var c: Dictionary = db.components[cid]
		var face = c.get("face", null)
		if str(c.get("status", "")) == "planned" or not (face is Dictionary) or not db.is_basic(str(cid)):
			continue
		if str(face.get("kind", "")) == "attack" and int(face.get("power", 0)) > 0:
			out.append(str(cid))
	return out


## Tier one's rank and file, in content order: every foe a tier-one formation fields that is
## no massive, no elite and no boss, and whatever such a foe leaves as it falls (a Gel's halves).
static func rank_and_file(db: ContentDB) -> Array[String]:
	var out: Array[String] = []
	for faction in db.factions.keys():
		for c in db.compositions(str(faction), 1, "formation"):
			for member in c.get("members", []):
				var fid := str(member[0])
				if not _is_rank_and_file(db, fid) or out.has(fid):
					continue
				out.append(fid)
				var fallen = db.foes[fid].get("on_death", null)
				var left := str(fallen.get("summon", "")) if fallen is Dictionary else ""
				if _is_rank_and_file(db, left) and not out.has(left):
					out.append(left)
	return out


static func _is_rank_and_file(db: ContentDB, fid: String) -> bool:
	return db.foes.has(fid) and int(db.foes[fid].get("size", 1)) < 2 and not db.is_elite(fid) and not db.is_boss(fid)


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
		if db.is_basic(str(cid)):
			tier = 0   # a basic ahead of the other tier-one pieces
		if str(face.get("kind", "")) == "buff" and str(face.get("status", "")) == status and tier < best_tier:
			best = str(cid)
			best_tier = tier
	return best

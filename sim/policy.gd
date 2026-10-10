class_name Policy
extends RefCounted

## A player for the headless skirmish, so balance can be measured at a scale nobody can play
## by hand (Ryan, 25 September). A ladder of skill rather than one bot, because a win rate
## means nothing on its own and a band means something:
##   RANDOM  never rerolls, spends every die on any legal target, shields and vents itself.
##           The floor: a fight random play wins is too easy, no argument.
##   GREEDY  reads the same forecast the screen shows and takes the best one-round trade,
##           rerolling dice that came up under their die's average. A competent new player.
##           It cannot see anything the player cannot.
## A persona is a habit on top: `withdraw_below` pulls out when the team's hull is under a
## percentage. The weights here trade mech hull against foe hit points and are knobs for
## the tool, not the game. Nothing here is shown to the player.

const RANDOM := 0
const GREEDY := 1
const KIND_NAMES := {RANDOM: "random", GREEDY: "greedy"}

const MAX_ROUNDS := 60           # a fight nobody can finish (armour holds, dice all blank) is stalled
const HULL_WEIGHT := 1.5         # a point of mech hull, in foe hit points: hull is the resource that persists
const SHIELD_WEIGHT := 0.3       # a point of shield lost to splash
const KILL_BONUS := 10.0         # a slot cleared: the back rank opens, the horde shrinks
const DEATH_WEIGHT := 60.0       # a machine kept alive through the round
const BANK_WEIGHT := 0.2         # shield stood up or heat room made for a later round
const BURN_WEIGHT := 0.5         # burn stacks pay out over the rounds to come
const OPTION_GUARD := 64         # spends in one round, at most: rapid rerolls the die and acts again
const DEVOUR_ROUNDS := 1.0       # rounds of the die's own damage a devoured stack is worth (it fades a stack a round)
const SHOCK_WEIGHT := 0.6        # the doubled blow a Shocked foe will take, as a share of the die's own damage
const CLEANSE_ROUNDS := 2.0      # rounds a cleansed status would otherwise have cost (Corrupted lasts the fight, Overheating fades)

var kind: int = GREEDY
var withdraw_below: int = 0      # persona: withdraw when the team's hull is under this percent (0: never)
var rng := RandomNumberGenerator.new()

## What the fight cost and how it was played, for the runner to tally.
var rounds: int = 0
var rerolls: int = 0
var overheat_hull: int = 0
var spends: Dictionary = {}      # component id, or "empty", "destroyed", "disabled" -> times spent
var stalled: bool = false
var withdrew: bool = false


static func make(kind_arg: int, seed_value: int = 0) -> Policy:
	var p := Policy.new()
	p.kind = kind_arg
	p.rng.seed = seed_value
	return p


static func kind_name(k: int) -> String:
	return str(KIND_NAMES.get(k, "?"))


# ---------------------------------------------------------------- driving a fight

## Plays a begun skirmish to its end and returns the outcome.
func play(sk: Skirmish) -> int:
	while sk.outcome == Skirmish.Outcome.NONE:
		if rounds >= MAX_ROUNDS:
			stalled = true
			break
		if withdraw_below > 0 and hull_percent(sk) < withdraw_below and sk.can_withdraw():
			sk.withdraw()
			withdrew = sk.outcome == Skirmish.Outcome.WITHDRAWN
			rounds += 1
			break
		sk.start_round()
		rounds += 1
		play_round(sk)
		if sk.outcome != Skirmish.Outcome.NONE:
			break
		sk.end_round()
		for o in sk.overheats:
			overheat_hull += int(o["over"])
	return sk.outcome


## One player turn, from the dice showing to every die spent or skipped.
func play_round(sk: Skirmish) -> void:
	if kind == GREEDY:
		_greedy_rerolls(sk)
	var held: Array[int] = []   # dice left unspent this round: nothing in reach, or every spend a loss
	var guard := 0
	while sk.state == Skirmish.State.ASSIGN and guard < OPTION_GUARD:
		guard += 1
		var best: Dictionary = {}
		var best_rolled: Dictionary = {}   # the best damaging spend that rolls, to go before a sure one
		for i in range(sk.mechs.size()):
			var ms: Skirmish.MechState = sk.mechs[i]
			if not ms.alive() or ms.assigned or held.has(i):
				continue
			var opts := options_for(sk, i)
			if opts.is_empty():
				held.append(i)
				continue
			var pick: Dictionary
			if kind == RANDOM:
				pick = opts[rng.randi_range(0, opts.size() - 1)]
			else:
				pick = opts[0]
				for o in opts:
					if o["score"] > pick["score"]:
						pick = o
				# A spend that costs more than it gains is not made: the screen lets a die go
				# unspent at End turn, and so does the bot. A blank costs nothing to discard.
				if pick["score"] < 0.0:
					held.append(i)
					continue
			if best.is_empty() or pick["score"] > best["score"]:
				best = pick
			if _rolls_damage(ms.face()) and pick["score"] > 0.0 and (best_rolled.is_empty() or pick["score"] > best_rolled["score"]):
				best_rolled = pick
			if kind == RANDOM:
				break   # the first unspent die, any option: no weighing across the team
		if best.is_empty():
			break
		# Rolled before sure (Ryan, 9 October): a sure number is worth most after the rolls
		# have landed, when it can finish what they left, so a damaging flat spend waits while
		# a damaging rolled one is there to make. Setup (buffs, shock, lure) keeps its order.
		if kind == GREEDY and not best_rolled.is_empty() and _sure_damage(sk.mechs[best["mech"]].face()):
			best = best_rolled
		var ms: Skirmish.MechState = sk.mechs[best["mech"]]
		var spent := ms.face()
		if sk.assign(best["mech"], best["target"]):
			_tally(spent)
		else:
			held.append(best["mech"])


## A damaging attack that rolls a range (the gamble), and one that is a single number.
static func _rolls_damage(f: Face) -> bool:
	return f != null and f.kind == Face.Kind.ATTACK and f.is_ranged()


static func _sure_damage(f: Face) -> bool:
	return f != null and f.kind == Face.Kind.ATTACK and not f.is_ranged() and f.power > 0


## Every legal spend of one mech's showing entry, scored: {mech, target, score}. A blank is
## one option worth nothing; an attack has one per foe in reach; a shield or a vent has one
## per live machine.
func options_for(sk: Skirmish, i: int) -> Array:
	var out: Array = []
	var ms: Skirmish.MechState = sk.mechs[i]
	var f := ms.face()
	if f == null:
		return out
	match f.kind:
		Face.Kind.BLANK:
			out.append({"mech": i, "target": null, "score": 0.0})
		Face.Kind.ATTACK:
			for t in sk.targets_for(i):
				out.append({"mech": i, "target": t, "score": attack_score(sk, ms, f, t)})
		Face.Kind.SHIELD, Face.Kind.VENT, Face.Kind.BUFF:
			for who in sk.equipment_targets_for(ms, f):
				out.append({"mech": i, "target": who, "score": equipment_score(sk, ms, who, f)})
	return out


# ---------------------------------------------------------------- scoring

## An attack on a foe, in foe hit points: what lands (capped at what the target and any
## neighbours have left), the kill it makes as often as the roll makes it, the links a
## chain adds, the burn it leaves, less the hull the heat will burn and the shield the
## splash will cost. Suppress counts the blow it stops.
func attack_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe) -> float:
	f = Effects.effective_face(ms.unit, f)
	var outcomes := damage_outcomes(ms, f, target)
	var mean := _mean(outcomes)
	var p_kill := _kill_odds(outcomes, target.hp)
	var score := _capped(outcomes, target.hp)
	if f.has(Face.Keyword.CLEAVE):
		for c in [target.column - 1, target.column + 1]:
			if c >= 0 and c < sk.columns:
				var n := sk.foe_at(target.rank, c)
				if n != null and n != target and n.alive():
					score += minf(mean, float(n.hp))
	if f.has(Face.Keyword.PENETRATE):
		var other := sk.foe_at(1 - target.rank, target.column)
		if other != null and other != target and other.alive():
			score += minf(mean, float(other.hp))
	score += p_kill * (KILL_BONUS + _threat_now(target) * HULL_WEIGHT)
	if f.has(Face.Keyword.LURE) or f.has(Face.Keyword.DISRUPT) or f.has(Face.Keyword.SHOCK):
		# Every foe the blows reach: the target, the neighbours of a spread, the column of a
		# penetrate; the ones that survive the blow are the ones a lure or a disrupt moves
		# and a shock charges.
		var hit: Array = [target]
		if f.has(Face.Keyword.CLEAVE):
			for c in [target.column - 1, target.column + 1]:
				if c >= 0 and c < sk.columns:
					var n := sk.foe_at(target.rank, c)
					if n != null and n.alive() and not hit.has(n):
						hit.append(n)
		if f.has(Face.Keyword.PENETRATE):
			var other := sk.foe_at(1 - target.rank, target.column)
			if other != null and other.alive() and not hit.has(other):
				hit.append(other)
		if f.has(Face.Keyword.DISRUPT):
			for foe in hit:
				score += ((1.0 - p_kill) if foe == target else 1.0) * disrupt_score(sk, foe)
		if f.has(Face.Keyword.LURE):
			score += (1.0 - p_kill) * lure_score(sk, ms, hit)
		if f.has(Face.Keyword.SHOCK):
			# Each foe left standing takes the team's next blow double: about the team's own
			# average blow again, capped at what the foe will have left. A charge already on a
			# foe this blow does not spend is worth nothing more.
			for foe in hit:
				if Effects.has(foe, "shocked") and mean <= 0.0:
					continue
				var left := maxf(0.0, float(foe.hp) - mean)
				score += ((1.0 - p_kill) if foe == target else 1.0) * minf(left, _team_raw_attack_mean(sk)) * SHOCK_WEIGHT
	if f.has(Face.Keyword.SPILLOVER) and target.rank == 0 and not target.is_massive():
		# What the roll has past the kill lands on the foe behind, and may kill it too.
		var behind := sk.foe_at(1, target.column)
		if behind != null and behind.alive() and behind != target:
			for o in outcomes:
				var spill := maxi(0, int(o[0]) - target.hp)
				if spill <= 0:
					continue
				score += float(o[1]) * minf(float(spill), float(behind.hp))
				if spill >= behind.hp:
					score += float(o[1]) * (KILL_BONUS + _threat_now(behind) * HULL_WEIGHT)
	if f.has(Face.Keyword.SUPPRESS):
		# A Numbed foe shrugs it off at its resistance, so the stopped blow is worth its odds.
		var lands := 1.0 - float(target.resist_total()) / 100.0
		score += (1.0 - p_kill) * _threat_now(target) * HULL_WEIGHT * maxf(0.0, lands)
	# The statuses this blow applies feed any machine's Paradox meter (the Baboon's Pocket
	# Paradox, a meter since 10 October): the share of a knock-out they move on this foe.
	var apps := int(f.has(Face.Keyword.BURN)) + int(f.has(Face.Keyword.SHOCK)) + int(f.has(Face.Keyword.SUPPRESS))
	if apps > 0:
		score += _paradox_share(sk, target, apps) * (1.0 - p_kill) * _threat_now(target) * HULL_WEIGHT
	if f.has(Face.Keyword.BURN):
		score += (1.0 - p_kill) * mean * BURN_WEIGHT
	if f.has(Face.Keyword.DEVOUR):
		# A kill feeds a stack of Overcharged: what the status adds to the die's own damage,
		# for about the rounds the stack lasts. Read from the status, never hardcoded.
		score += p_kill * _stack_damage_gain("overcharged", _raw_attack_mean(ms)) * DEVOUR_ROUNDS
	# A chain repeats on the next foe in reach while it keeps killing, heat and all: every
	# link is worth its kill at the odds of reaching it.
	var uses := 1.0
	if f.has(Face.Keyword.CHAIN):
		var p := p_kill
		for n in sk.targets_for_face(ms, f):
			if n == target or not n.alive() or p <= 0.001:
				continue
			uses += p
			var link := damage_outcomes(ms, f, n)
			score += p * (_capped(link, n.hp) + _kill_odds(link, n.hp) * (KILL_BONUS + _threat_now(n) * HULL_WEIGHT))
			p *= _kill_odds(link, n.hp)
	# The heat this entry adds, on top of what the round's end already brings: whatever ends
	# over the cap burns hull, and a machine burnt out is the worst trade there is. Asked of
	# the entry itself, not the one showing, so a reroll can weigh every entry the same way.
	var fc := sk.forecast(ms, false)
	var over := maxi(0, int(fc["heat_after"]) + int(fc["overheat"]) + int(roundf(heat_of(ms, f) * uses)) - ms.heat_max)
	score -= float(over - int(fc["overheat"])) * HULL_WEIGHT
	if not fc["destroyed"] and int(fc["hull_after"]) - (over - int(fc["overheat"])) <= 0:
		score -= DEATH_WEIGHT
	if sk.reach_of(ms, f) == Face.Reach.INDIRECT and target.rank == 0 and not Effects.spares_splash(ms.unit):
		score -= ceilf(mean / Skirmish.DANGER_CLOSE_DIVISOR) * SHIELD_WEIGHT
	return score - volatile_cost(sk, ms, f, uses)


## What a volatile entry costs its owner in the score: the hull it bites per use, and the
## death it brings when the round's end would already leave nothing to bite.
static func volatile_cost(sk: Skirmish, ms: Skirmish.MechState, f: Face, uses: float = 1.0) -> float:
	var bite := Skirmish.spend_bite(ms.unit, f)
	if bite <= 0:
		return 0.0
	var cost := float(bite) * uses * HULL_WEIGHT
	var fc := sk.forecast(ms, false)
	if not fc["destroyed"] and int(fc["hull_after"]) - int(roundf(bite * uses)) <= 0:
		cost += DEATH_WEIGHT
	return cost


## What one stack of a status adds to a blow of `mean` damage: a flat add as itself, a
## multiplier as its share of the blow. Read from the status, never hardcoded.
static func _stack_damage_gain(status_id: String, mean: float) -> float:
	var gain := 0.0
	for eff in Effects.STATUS.get(status_id, {}).get("effects", []):
		if str(eff.get("trigger", "")) != "on_attack":
			continue
		match str(eff.get("effect", "")):
			"multiply_damage":
				gain += (float(eff.get("value", 1)) - 1.0) * mean
			"add_damage":
				gain += float(eff.get("value", 0))
	return gain


## The die's own average damage per entry, attack entries at their average times their
## strikes, blanks and equipment at zero: a plain read with no scoring under it, so a
## keyword that pays out on later attacks can be valued without asking the scorer again.
static func _raw_attack_mean(ms: Skirmish.MechState) -> float:
	if ms.die.faces.is_empty():
		return 0.0
	var total := 0.0
	for f in ms.die.faces:
		if f.is_attack():
			total += float(f.average() * maxi(1, f.strikes))
	return total / float(ms.die.faces.size())


## The heat one use of an attack entry adds, through the pipeline; negative for one that
## fires the gauge empty first.
static func heat_of(ms: Skirmish.MechState, f: Face) -> int:
	var added := int(Effects.attack(ms.unit, f, 0, f.heat)["heat"])
	return added - ms.heat if f.vents_all else added


## What one use of an attack entry can land, with the odds of each: [[damage, weight], ...].
## A rolled entry is read at five points (its ends, its quarters, its middle); a flat entry is
## one point. Overcharge, a target's missing hull and the pipeline's modifiers apply as the
## resolver applies them; the strikes multiply the blow.
func damage_outcomes(ms: Skirmish.MechState, f: Face, target: Foe = null) -> Array:
	f = Effects.effective_face(ms.unit, f)
	var rolls: Array[int] = []
	if not f.is_ranged():
		rolls.append(f.power)
	else:
		var span := f.power_max - f.power
		for q in [0.0, 0.25, 0.5, 0.75, 1.0]:
			rolls.append(f.power + int(roundf(span * q)))
	var fired := f.power_per_heat * int(ms.heat / 10) if f.vents_all else 0   # what the heat it fires adds
	fired += f.missing_bonus(target)   # and what the target's lost hull adds
	var out: Array = []
	var w := 1.0 / rolls.size()
	for v in rolls:
		var dmg: int = v + fired
		dmg = int(Effects.attack(ms.unit, f, dmg, 0, target)["damage"])
		# The foe's own statuses read last: a Shocked foe takes the first blow double. Then its
		# armour comes off every blow, so a hardened foe is worth less to a volume weapon.
		var arm := target.armour_total() if target != null else 0
		var first := maxi(0, (Effects.damage_taken(target, dmg) if target != null else dmg) - arm)
		out.append([first + maxi(0, dmg - arm) * (maxi(1, f.strikes) - 1), w])
	return out


## What one use of an attack entry lands on average.
func expected_damage(ms: Skirmish.MechState, f: Face, target: Foe = null) -> float:
	return _mean(damage_outcomes(ms, f, target))


static func _mean(outcomes: Array) -> float:
	var total := 0.0
	for o in outcomes:
		total += float(o[0]) * float(o[1])
	return total


## The damage that lands on a foe with this much left, on average: nothing past the kill.
static func _capped(outcomes: Array, hp: int) -> float:
	var total := 0.0
	for o in outcomes:
		total += minf(float(o[0]), float(hp)) * float(o[1])
	return total


static func _kill_odds(outcomes: Array, hp: int) -> float:
	var p := 0.0
	for o in outcomes:
		if int(o[0]) >= hp:
			p += float(o[1])
	return p


## A piece of equipment spent by `ms` on `who`: its shield, vent or buff where it lands, what
## a cleanse clears there, and what a volatile bite costs.
func equipment_score(sk: Skirmish, ms: Skirmish.MechState, who: Skirmish.MechState, f: Face) -> float:
	var score := 0.0
	match f.kind:
		Face.Kind.SHIELD:
			score = shield_score(sk, who, f.power, f.has(Face.Keyword.OVERSHIELD), ms)
		Face.Kind.VENT:
			score = vent_score(sk, who, f.power)
		Face.Kind.BUFF:
			score = buff_score(sk, who, f)
	if f.has(Face.Keyword.CLEANSE):
		score += cleanse_score(sk, who)
	return score - volatile_cost(sk, ms, f)


## What a cleanse clears from a machine, in hull: the Overheating it would gain (the heat this
## round's tick adds past the cap as hull, the rest as room), the bites its Corrupted entries
## would take over the rounds to come, and the entries a foe switched off, at the die's own
## mean for each. A Scrambled reroll is small change.
func cleanse_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	var score := 0.0
	var tick := int(Effects.tick_preview(who.unit)["heat"])
	if tick > 0:
		var fc := sk.forecast(who, false)
		var over := mini(tick, int(fc["overheat"]))
		score += float(over) * HULL_WEIGHT + float(tick - over) * BANK_WEIGHT * CLEANSE_ROUNDS
	var n := who.die.faces.size()
	if n > 0:
		for i in range(n):
			var bite := Effects.corrupt_stacks(who.unit, i) * Skirmish.CORRUPT_BITE_PER_STACK
			score += float(bite) * HULL_WEIGHT * CLEANSE_ROUNDS / float(n)
			if Effects.is_entry_disabled(who.unit, i) and Effects.cleansable_disable(who.unit, i):
				score += _raw_attack_mean(who) * CLEANSE_ROUNDS / float(n)
	if Effects.has(who.unit, "scrambled"):
		score += KILL_BONUS * BANK_WEIGHT
	return score


## A shield on a machine: the hull it keeps this round (a standing shield blocks a whole
## blow), the death it prevents, and a little for what stands afterwards.
func shield_score(sk: Skirmish, who: Skirmish.MechState, power: int, overshield: bool = false, by: Skirmish.MechState = null) -> float:
	var before := sk.forecast(who, false)
	var after := sk.forecast(who, false, power, overshield)
	var saved := maxf(0.0, float(after["hull_after"])) - maxf(0.0, float(before["hull_after"]))
	var score := saved * HULL_WEIGHT
	if before["destroyed"] and not after["destroyed"]:
		score += DEATH_WEIGHT
	# What stands afterwards: an overshield's excess fades at the round's end, so only the
	# shield up to the maximum banks.
	score += float(maxi(0, mini(power, who.unit.shield_max - who.unit.shield))) * BANK_WEIGHT
	# An escort's passive sheds the ally's heat as it shields (on_shield_granted): worth what
	# a vent of that much would be, on an ally only.
	if by != null and by != who:
		var vent := Effects.granted_vent(by.unit)
		if vent > 0:
			score += vent_score(sk, who, vent)
	return score


## A lure on the foes an entry reaches: the team's hull the redirect saves this round, and
## the deaths it prevents or causes, read by turning those foes on `who` in a what-if and
## reading every machine's forecast, then putting the targets back.
func lure_score(sk: Skirmish, who: Skirmish.MechState, foes: Array) -> float:
	var before := _team_outlook(sk, who, 0)
	var saved := {}
	for foe in foes:
		if foe.alive() and foe.target != who:
			saved[foe] = foe.target
			foe.target = who
	if saved.is_empty():
		return 0.0
	var after := _team_outlook(sk, who, 0)
	for foe in saved.keys():
		foe.target = saved[foe]
	return (float(after["hull"]) - float(before["hull"])) * HULL_WEIGHT + float(int(before["deaths"]) - int(after["deaths"])) * DEATH_WEIGHT


## A disrupt on a foe about to strike: the blow it will not land, when it has a quieter move
## open to switch to (a disrupt into another blow is worth nothing here).
static func disrupt_score(sk: Skirmish, foe: Foe) -> float:
	if not foe.attacks() or foe.is_suppressed() or foe.target == null:
		return 0.0
	for a in sk.legal_actions(foe):
		if a != foe.action and not Foe.is_attack_action(a):
			return _threat_now(foe) * HULL_WEIGHT
	return 0.0


## The team's hull at the round's end as the forecast sees it, and how many machines it
## loses, with `extra_shield` standing on `who`.
static func _team_outlook(sk: Skirmish, who: Skirmish.MechState, extra_shield: int) -> Dictionary:
	var hull := 0
	var deaths := 0
	for ms in sk.live_mechs():
		var fc := sk.forecast(ms, false, extra_shield if ms == who else 0)
		hull += maxi(0, int(fc["hull_after"]))
		if fc["destroyed"]:
			deaths += 1
	return {"hull": hull, "deaths": deaths}


## A buff on a machine, from what its status does: more damage on the attack it has in hand
## this round (and its die's mean for any further round), less of the incoming it faces, or
## the burn its blows will leave. Nothing for a machine that has already spent its die.
func buff_score(sk: Skirmish, who: Skirmish.MechState, f: Face) -> float:
	var status: Dictionary = Effects.STATUS.get(f.buff_status, {})
	var n := f.buff_stacks
	var attack_now := 0.0
	var shown := who.face()
	if not who.assigned and shown != null and shown.is_attack():
		for t in sk.targets_for_face(who, shown):
			attack_now = maxf(attack_now, attack_score(sk, who, shown, t))
	# Rounds beyond this one: the die's attack entries alone, on average, never its buffs
	# (a buff that can land on its own machine would otherwise ask itself its worth forever).
	var attack_later := 0.0
	if f.buff_rounds > 1:
		attack_later = _attack_mean(sk, who) * float(f.buff_rounds - 1)
	var score := 0.0
	for eff in status.get("effects", []):
		var v := float(eff.get("value", 0))
		match str(eff.get("effect", "")):
			"multiply_damage":
				score += (pow(v, n) - 1.0) * (attack_now + attack_later)
			"add_damage":
				score += v * n * (1.0 if attack_now > 0.0 else 0.0) + v * n * float(f.buff_rounds - 1)
			"multiply_damage_taken":
				score += (1.0 - pow(v, n)) * float(sk.incoming_for(who)) * HULL_WEIGHT * float(f.buff_rounds)
			"add_burn":
				var per := float(Effects.STATUS["burning"]["effects"][0]["value"])
				score += per * v * n * BURN_WEIGHT * (1.0 if attack_now > 0.0 else 0.0) * float(f.buff_rounds)
			"shock_on_hull_strike":
				# Every foe about to reach this machine's hull comes out Shocked: the team's
				# next blow on it lands double, worth about the die's own damage again, capped
				# at what the foe has left.
				for a in sk.attackers_of(who):
					if who.unit.shield <= 0 or a.breaches():
						score += minf(float(a.hp), _team_raw_attack_mean(sk)) * SHOCK_WEIGHT
	return score


## The team's average attack entry, for what a doubled blow is worth.
static func _team_raw_attack_mean(sk: Skirmish) -> float:
	var total := 0.0
	var n := 0
	for ms in sk.live_mechs():
		total += _raw_attack_mean(ms)
		n += 1
	return total / float(maxi(1, n))


## The mean of a machine's attack entries, each spent as well as it can be, over its die.
func _attack_mean(sk: Skirmish, who: Skirmish.MechState) -> float:
	if who.die.faces.is_empty():
		return 0.0
	var total := 0.0
	for f in who.die.faces:
		if not f.is_attack():
			continue
		var best := 0.0
		for t in sk.targets_for_face(who, f):
			best = maxf(best, attack_score(sk, who, f, t))
		total += best
	return total / float(who.die.faces.size())


## What `apps` statuses landing on a foe move toward a Paradox knock-out: the share of the
## stacks it still needs, whole when they trip it, at its odds of not shrugging it off.
## Nothing without a machine running the meter.
static func _paradox_share(sk: Skirmish, target: Foe, apps: int) -> float:
	var adds := 0
	var at := 0
	for ms in sk.live_mechs():
		var meter := Effects.paradox(ms.unit)
		if meter[1] <= 0:
			continue
		adds += meter[0]
		at = meter[1] if at == 0 else mini(at, meter[1])
	if at <= 0 or apps <= 0 or not target.alive():
		return 0.0
	var need := maxi(1, at - Effects.stacks_of(target, "paradox"))
	return minf(1.0, float(apps * adds) / float(need)) * maxf(0.0, 1.0 - float(target.resist_total()) / 100.0)


## A vent on a machine: the hull its overheat would burn this round, and a little for the
## room it makes.
func vent_score(sk: Skirmish, who: Skirmish.MechState, power: int) -> float:
	var fc := sk.forecast(who, false)
	var score := float(mini(power, int(fc["overheat"]))) * HULL_WEIGHT
	if fc["destroyed"] and int(fc["overheat"]) > 0 and int(fc["hull_after"]) + mini(power, int(fc["overheat"])) > 0:
		score += DEATH_WEIGHT
	score += float(mini(power, who.heat)) * BANK_WEIGHT
	return score


## What an entry is worth to this machine right now, spent as well as it can be: for the
## reroll decision, where the question is "is this face below what my die usually gives".
## Never under zero, since a losing spend is held instead.
func face_value(sk: Skirmish, ms: Skirmish.MechState, f: Face) -> float:
	if f == null:
		return 0.0
	match f.kind:
		Face.Kind.ATTACK:
			var best := 0.0
			for t in sk.targets_for_face(ms, f):
				best = maxf(best, attack_score(sk, ms, f, t))
			return best
		Face.Kind.SHIELD, Face.Kind.VENT, Face.Kind.BUFF:
			var best := 0.0
			for who in sk.equipment_targets_for(ms, f):
				best = maxf(best, equipment_score(sk, ms, who, f))
			return best
	return 0.0


## The die's average entry value right now, a disabled entry counting as blank.
func die_mean(sk: Skirmish, ms: Skirmish.MechState) -> float:
	if ms.die.faces.is_empty():
		return 0.0
	var total := 0.0
	for i in range(ms.die.faces.size()):
		if Effects.is_entry_disabled(ms.unit, i):
			continue
		total += face_value(sk, ms, ms.die.faces[i])
	return total / float(ms.die.faces.size())


## The team's hull as a percentage of its maximum, dead machines included.
static func hull_percent(sk: Skirmish) -> int:
	var hull := 0
	var hull_max := 0
	for ms in sk.mechs:
		hull += maxi(0, ms.unit.hull)
		hull_max += ms.unit.hull_max
	return 100 if hull_max <= 0 else int(100 * hull / hull_max)


# ---------------------------------------------------------------- private

## Reroll every unspent die showing less than its average, while rerolls last. A reroll
## never lands on the same entry, so this is a real second chance, not a coin flip.
func _greedy_rerolls(sk: Skirmish) -> void:
	# A machine's own free rerolls first, one die at a time, while it shows less than its mean.
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		while ms.alive() and not ms.assigned and ms.free_rerolls > 0 and face_value(sk, ms, ms.face()) + 0.001 < die_mean(sk, ms):
			if not sk.reroll([i]):
				break
			rerolls += 1
	while sk.rerolls_left > 0:
		var idx: Array = []
		for i in range(sk.mechs.size()):
			var ms: Skirmish.MechState = sk.mechs[i]
			if not ms.alive() or ms.assigned:
				continue
			if face_value(sk, ms, ms.face()) + 0.001 < die_mean(sk, ms):
				idx.append(i)
		if idx.is_empty():
			return
		if not sk.reroll(idx):
			return
		rerolls += 1


## The blow this foe is about to land, if it is aimed at anyone.
static func _threat_now(f: Foe) -> float:
	if f.target == null or f.is_suppressed() or not f.attacks():
		return 0.0
	return float(f.damage() * f.strikes())


func _tally(f: Face) -> void:
	if f == null:
		return
	var key := f.component
	if f.kind == Face.Kind.BLANK:
		key = "disabled" if f.disabled else ("empty" if f.empty else "destroyed")
	spends[key] = int(spends.get(key, 0)) + 1

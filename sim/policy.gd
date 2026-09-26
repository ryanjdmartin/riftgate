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
			if kind == RANDOM:
				break   # the first unspent die, any option: no weighing across the team
		if best.is_empty():
			break
		var ms: Skirmish.MechState = sk.mechs[best["mech"]]
		var spent := ms.face()
		if sk.assign(best["mech"], best["target"]):
			_tally(spent)
		else:
			held.append(best["mech"])


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
		Face.Kind.SHIELD:
			for who in sk.live_mechs():
				out.append({"mech": i, "target": who, "score": shield_score(sk, who, f.power)})
		Face.Kind.VENT:
			for who in sk.live_mechs():
				out.append({"mech": i, "target": who, "score": vent_score(sk, who, f.power)})
	return out


# ---------------------------------------------------------------- scoring

## An attack on a foe, in foe hit points: what lands (capped at what the target and any
## neighbours have left), the kill it makes as often as the roll makes it, the links a
## chain adds, the burn it leaves, less the hull the heat will burn and the shield the
## splash will cost. Suppress counts the blow it stops.
func attack_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe) -> float:
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
	if f.has(Face.Keyword.SUPPRESS):
		# A Numbed foe shrugs it off at its resistance, so the stopped blow is worth its odds.
		var lands := 1.0 - float(Effects.tick_preview(target)["resist"]) / 100.0
		score += (1.0 - p_kill) * _threat_now(target) * HULL_WEIGHT * maxf(0.0, lands)
	if f.has(Face.Keyword.BURN):
		score += (1.0 - p_kill) * mean * BURN_WEIGHT
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
	if sk.reach_of(ms, f) == Face.Reach.INDIRECT and target.rank == 0:
		score -= ceilf(mean / Skirmish.DANGER_CLOSE_DIVISOR) * SHIELD_WEIGHT
	return score


## The heat one use of an attack entry adds, through the pipeline.
static func heat_of(ms: Skirmish.MechState, f: Face) -> int:
	var heat := f.heat
	if f.has(Face.Keyword.OVERCHARGE):
		heat *= 2
	return int(Effects.attack(ms.unit, f, 0, heat, false)["heat"])


## What one use of an attack entry can land, with the odds of each: [[damage, weight], ...].
## A kinetic roll is read at five points (its ends, its quarters, its middle), each with and
## without a crit; a static entry is one point. Overcharge, execute and the pipeline's
## modifiers apply as the resolver applies them; the strikes multiply the blow.
func damage_outcomes(ms: Skirmish.MechState, f: Face, target: Foe = null) -> Array:
	var rolls: Array[int] = []
	if not f.is_ranged():
		rolls.append(f.power)
	elif f.has(Face.Keyword.STEADY):
		rolls.append(f.average())
	else:
		var span := f.power_max - f.power
		for q in [0.0, 0.25, 0.5, 0.75, 1.0]:
			rolls.append(f.power + int(roundf(span * q)))
	var crit_p := clampf(float(f.crit) / 100.0, 0.0, 1.0)
	var crit_mult := Face.CRIT_MULT + f.crit_bonus + Effects.crit_bonus(ms.unit, f)
	var out: Array = []
	for v in rolls:
		for crit in [false, true]:
			var w := (crit_p if crit else 1.0 - crit_p) / rolls.size()
			if w <= 0.0:
				continue
			var dmg: int = v
			if crit:
				dmg = int(roundf(dmg * crit_mult))
			if f.has(Face.Keyword.OVERCHARGE):
				dmg *= 2
			if target != null and f.has(Face.Keyword.EXECUTE) and target.hp * 2 <= target.hp_max:
				dmg = int(roundf(dmg * (1.5 if target.is_massive() else 2.0)))
			dmg = int(Effects.attack(ms.unit, f, dmg, 0, crit, target)["damage"]) * maxi(1, f.strikes)
			out.append([dmg, w])
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


## A shield on a machine: the hull it keeps this round (a standing shield blocks a whole
## blow), the death it prevents, and a little for what stands afterwards.
func shield_score(sk: Skirmish, who: Skirmish.MechState, power: int) -> float:
	var before := sk.forecast(who, false)
	var after := sk.forecast(who, false, power)
	var saved := maxf(0.0, float(after["hull_after"])) - maxf(0.0, float(before["hull_after"]))
	var score := saved * HULL_WEIGHT
	if before["destroyed"] and not after["destroyed"]:
		score += DEATH_WEIGHT
	score += float(mini(power, who.unit.shield_max - who.unit.shield)) * BANK_WEIGHT
	return score


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
		Face.Kind.SHIELD:
			var best := 0.0
			for who in sk.live_mechs():
				best = maxf(best, shield_score(sk, who, f.power))
			return best
		Face.Kind.VENT:
			var best := 0.0
			for who in sk.live_mechs():
				best = maxf(best, vent_score(sk, who, f.power))
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
	if f.target == null or f.is_suppressed():
		return 0.0
	return float(f.damage() * f.strikes())


func _tally(f: Face) -> void:
	if f == null:
		return
	var key := f.component
	if f.kind == Face.Kind.BLANK:
		key = "disabled" if f.disabled else ("empty" if f.empty else "destroyed")
	spends[key] = int(spends.get(key, 0)) + 1

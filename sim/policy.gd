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
const KILL_BONUS := 10.0         # a slot cleared: the back rank opens, the horde shrinks
const DEATH_WEIGHT := 60.0       # a machine kept alive through the round
const BANK_WEIGHT := 0.2         # shield stood up or heat room made for a later round
const BURN_WEIGHT := 0.5         # burn stacks pay out over the rounds to come
const OPTION_GUARD := 64         # spends in one round, at most: rapid rerolls the die and acts again
const DEVOUR_ROUNDS := 2.0       # rounds of damage a kill's Overcharged stacks are worth: a halving stack pays about twice itself over the rounds to come; kept for the battle (the Ammit), more
const SHOCK_WEIGHT := 0.6        # the doubled blow a Shocked foe will take, as a share of the die's own damage
const CLEANSE_ROUNDS := 2.0      # rounds a cleansed status would otherwise have cost (Corrupted lasts the fight, Burning fades)
const HOPPER_WEIGHT := 0.6       # a load in the hopper, as a share of what it adds when a later shot fires it
const ROLL_AGAIN_WEIGHT := 1.0   # another roll of the die bought with a stack (the Nemesis's rage), as the die's own average blow
const RAGE_BANK_WEIGHT := 0.5    # a stack banked by a bite of its own, as a share of the roll it buys: it waits for a fist to show
const VITRIOL_WEIGHT := 0.5      # a status a passive lays (the funnel-web's acid) pays out over the actions to come, as Burn's does
const FLAK_WEIGHT := 0.5         # a stack of Flak, as the point it adds to each team blow the foe is likely to take before it halves
const FUEL_WEIGHT := 0.5         # a point of heat banked by a machine whose vents blast, as a share of next round's blast it fuels
const SWAP_WEIGHT := 0.25        # a foe brought into the front rank by a swap, as a share of its kill and its threat: it stands exposed to Direct fire
const BUNCH_WEIGHT := 0.75       # what a swap adds to an ally's area entry this round, as a share: the ally may still spend elsewhere
const COUNTDOWN_DISCOUNT := 0.75 # a gathering blow's worth now, for each round it still gathers: it lands later, and the fight may end first
const OPEN_CORE_WEIGHT := 0.5    # a part's kill that opens its core, as a share of the core's kill and threat: the core still has to be hit
const SHIELD_LOSS_WEIGHT := 0.5  # a point of shield a last act takes, in foe hit points: it recharges out of fights, where hull does not
const EXPOSE_WEIGHT := 0.5       # Exposed on a foe: its armour off each team blow likely before it fades, and a back-rank foe in Direct reach, as a share
const MINE_WEIGHT := 0.8         # a laid shot, as a share of its blow on the arrival: delayed, and laid against a count of those waiting, never a foe seen
const MINE_PULL_SHARE := 0.5     # the odds a shot no arrival will take is cashed later by a pull on the team's dice
const DRONE_WEIGHT := 0.5        # the Syrinx Drone's mine: the team's average blow, at the odds an arrival takes the slot its kill empties, as a share
const REROLL_SHARE := 0.4        # a team reroll more (Rallied), as a share of the team's average blow
const AMMO_SHARE := 0.5          # an ammo (the Musk Ox's magazine), as a share of the best damage a gun on its die buys with one

var kind: int = GREEDY
var withdraw_below: int = 0      # persona: withdraw when the team's hull is under this percent (0: never)
var rng := RandomNumberGenerator.new()

## What the fight cost and how it was played, for the runner to tally.
var rounds: int = 0
var rerolls: int = 0
var overheat_hull: int = 0
var overheats: int = 0           # overheat events (a machine over its maximum as a turn ends)
var heat_peak_pct: float = 0.0   # the hottest any machine stood as a turn ended, percent of its maximum
var hot_rounds: int = 0          # rounds a machine ended its turn at four fifths of its maximum or more
var forced_holds: int = 0        # damaging dice held because spending them would cross the maximum (the heat report, 13 October: spikes, not actions)
var forgone: float = 0.0         # the damage those dice would have dealt, at their mean
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
		_read_heat(sk)
		if sk.outcome != Skirmish.Outcome.NONE:
			break
		sk.end_round()
		for o in sk.overheats:
			overheat_hull += int(o["over"])
			overheats += 1
	return sk.outcome


## The heat as the player's turn ends, for the runner's heat report: the hottest machine as a
## share of its maximum, and whether any stood at four fifths of it or more.
func _read_heat(sk: Skirmish) -> void:
	var hot := false
	for ms in sk.live_mechs():
		var pct := 100.0 * float(ms.heat) / float(maxi(1, ms.heat_max))
		heat_peak_pct = maxf(heat_peak_pct, pct)
		hot = hot or pct >= 80.0
	if hot:
		hot_rounds += 1


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
					_note_forced(sk, ms)
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
		if sk.assign(best["mech"], best["target"], best.get("second", null)):
			_tally(spent)
		else:
			held.append(best["mech"])


## A damaging die held because its heat would cross the maximum: a forced choice, and the
## damage it would have dealt at its mean (the heat report's, 13 October).
func _note_forced(sk: Skirmish, ms: Skirmish.MechState) -> void:
	var f := ms.face()
	if f == null or not f.is_attack() or (f.power <= 0 and f.power_max <= 0):
		return
	var fc := sk.forecast(ms, false)
	if int(fc["heat_end"]) + heat_of(ms, f) <= ms.heat_max:
		return
	forced_holds += 1
	forgone += float(Effects.effective_face(ms.unit, f).average() * maxi(1, f.strikes))


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
	if ms.face() == null:
		return out
	var f := sk.spend_face(ms)   # the charged form when it goes out charged (the Swallowtail's muster)
	match f.kind:
		Face.Kind.BLANK:
			out.append({"mech": i, "target": null, "score": 0.0})
		Face.Kind.ATTACK:
			var swaps := sk.needs_second(ms)
			for t in sk.targets_for_face(ms, f):
				var score := attack_score(sk, ms, f, t)
				if not swaps:
					out.append({"mech": i, "target": t, "score": score})
					continue
				# A Swap takes the second target worth the most beside this first.
				var best_second = null
				var best := -INF
				for second in sk.swap_targets(t):
					var v := swap_score(sk, t, second) + bunching_score(sk, ms, t, second)
					if v > best:
						best = v
						best_second = second
				if best_second != null:
					out.append({"mech": i, "target": t, "second": best_second, "score": score + best})
			# An empty slot (the Lammergeier's): a mine laid there, or the pull's gather.
			for slot in sk.slot_targets(ms, f):
				out.append({"mech": i, "target": slot, "score": slot_score(sk, ms, f, slot)})
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
	var quick := Effects.quick_turn_live(ms.unit, f)
	f = Effects.effective_face(ms.unit, f, target)
	if f.spends_magazine:
		return salvo_score(sk, ms, f)   # the Musk Ox's salvo: random targets, the magazine its price
	var outcomes := damage_outcomes(ms, f, target)
	var mean := _mean(outcomes)
	var p_kill := _kill_odds(outcomes, target.hp)
	var score := _capped(outcomes, target.hp)
	# Every other foe the blow reaches (a Spread's neighbours, a Penetrate's column, a reach over
	# every foe), the blow on each capped at what it has left.
	for n in sk.reached_by(f, target):
		if n != target and n.alive():
			score += minf(mean, float(n.hp))
	# A kill ends the countdown it gathers, opens the core its fall unguards, and sets off its
	# last act (the boss mechanics of 15 October; valued 22 October).
	score += p_kill * (KILL_BONUS + (_threat_now(target, sk) + countdown_threat(target, sk)) * HULL_WEIGHT + core_opening(sk, target) - last_act_cost(sk, target))
	if f.has(Face.Keyword.LURE) or f.has(Face.Keyword.DISRUPT) or f.has(Face.Keyword.SHOCK):
		# Every foe the blows reach: the target, the neighbours of a spread, the column of a
		# penetrate; the ones that survive the blow are the ones a lure or a disrupt moves
		# and a shock charges.
		var hit: Array = sk.reached_by(f, target).filter(func(n: Foe) -> bool: return n == target or n.alive())
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
					score += float(o[1]) * (KILL_BONUS + _threat_now(behind, sk) * HULL_WEIGHT)
	if f.has(Face.Keyword.SUPPRESS):
		# A Numbed foe shrugs it off at its resistance, so the stopped blow is worth its odds.
		var lands := 1.0 - float(target.resist_total()) / 100.0
		score += (1.0 - p_kill) * suppress_worth(sk, target) * HULL_WEIGHT * maxf(0.0, lands)
	if f.has(Face.Keyword.WEB):
		# A delayed stun (the funnel-web's web, 18 October): the blows its burst will stop.
		score += (1.0 - p_kill) * web_score(sk, target)
	# Flak (21 October): a point a stack on every team blow each foe reached takes before the
	# stacks halve, damage in hand for the team's blows (flak_score).
	if f.has(Face.Keyword.FLAK):
		for foe in sk.reached_by(f, target):
			if not foe.alive():
				continue
			var survives_flak := (1.0 - p_kill) if foe == target else 1.0
			score += survives_flak * flak_score(sk, ms, f, foe, maxf(0.0, float(foe.hp) - mean), foe == target)
	# What this machine's passives lay on each foe the blow reaches, judged alone (the
	# funnel-web's Ambush, 18 October): a stack per strike that lands with a number, worth its
	# ticks over the actions to come on the hull the blow leaves, at the odds the foe outlives
	# the blow. A blow of nothing lays nothing.
	var laid_apps := 0
	if f.power > 0 or f.power_max > 0:
		for foe in sk.reached_by(f, target):
			if not foe.alive():
				continue
			var lays := Effects.laid_statuses(ms.unit, f, foe)
			if lays.is_empty():
				continue
			var left := int(maxf(0.0, float(foe.hp) - mean))
			var survives := (1.0 - p_kill) if foe == target else 1.0
			for pair in lays:
				score += survives * dot_payout(str(pair[0]), int(pair[1]) * maxi(1, f.strikes), left) * VITRIOL_WEIGHT
				if foe == target:
					laid_apps += 1
	# The statuses this blow applies feed any machine's Paradox meter (the Baboon's Pocket
	# Paradox, a meter since 10 October): the share of a knock-out they move on this foe.
	var apps := int(f.has(Face.Keyword.BURN)) + int(f.has(Face.Keyword.SHOCK)) + int(f.has(Face.Keyword.SUPPRESS)) + int(f.has(Face.Keyword.WEB)) + int(f.has(Face.Keyword.FLAK)) + laid_apps
	if apps > 0:
		score += _paradox_share(sk, target, apps) * (1.0 - p_kill) * _threat_now(target, sk) * HULL_WEIGHT
	if f.has(Face.Keyword.BURN):
		# Burn N leaves N stacks that tick N, N-1, ... 1 over the actions to come (Ryan, 18
		# October: a numbered keyword, a damage point a stack); the tick is read from the status.
		var per := float(Effects.STATUS["burning"]["effects"][0]["value"])
		score += (1.0 - p_kill) * per * float(f.burn * (f.burn + 1)) / 2.0 * BURN_WEIGHT
	# Cryo (20 October): a damaging hit cashes the foe's stacks for cooling, worth what a vent
	# of that much would be on the hitter.
	if (f.power > 0 or f.power_max > 0) and Effects.has(target, "cryoed"):
		score += vent_score(sk, ms, Effects.stacks_of(target, "cryoed") * Skirmish.cryo_cool())
	if f.fills_hopper > 0:
		score += hopper_fill_score(sk, ms, f, target)
	if f.braces > 0:
		score += brace_score(sk, ms, f.braces)
	if f.heat_per_blow > 0:
		score += siphon_score(sk, ms, f.heat_per_blow)
	if f.has(Face.Keyword.EXPOSE):
		score += (1.0 - p_kill) * expose_score(sk, target)
	if not f.rolls_again_on.is_empty() and Effects.stacks_of(ms.unit, f.rolls_again_on) > 0:
		# A stack to spend buys another roll of the die, so the machine acts again: about the
		# die's own average blow, read plainly so the scorer never asks itself.
		score += ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms)
	if f.resets_on_kill:
		# The reset gun (the Kite's Pinion Driver): a kill lights every dark entry and the machine
		# acts again, about the die's own average blow, at the odds of the kill.
		score += p_kill * ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms)
	if quick:
		# The Needletail's gate: a setup it spends is Rapid once a round, so the machine acts
		# again, about the die's own average blow.
		score += ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms)
	# The Forge (the Musk Ox's): the gun's price in ammo, at what an ammo buys; the cluster
	# cannon's refund, an ammo for every foe its blows reach, as far as the magazine has room.
	var price := sk.ammo_price_of(ms, f)
	if price > 0:
		var worth := ammo_worth(sk, ms)
		score -= float(price) * worth
		if f.ammo_per_foe_hit > 0:
			var back := f.ammo_per_foe_hit * sk.reached_by(f, target).filter(func(n: Foe) -> bool: return n.alive()).size()
			score += float(mini(back, ms.ammo_max - ms.ammo + price)) * worth
	if f.pulls_mines:
		score += pull_score(sk, target)
	if f.drones:
		# The Syrinx Drone (the Lammergeier's): Rapid on a foe already Exposed, the machine acting
		# again, or else its Exposed; and the mine its killing shot leaves, at the odds a foe
		# steps into the slot it empties or a pull on the team's dice cashes it.
		if Effects.has(target, "exposure"):
			score += ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms)
		else:
			score += expose_score(sk, target)
		if not Effects.has(target, "syrinx_drone"):
			var waits := 1.0 if waiting_for(sk, 0 if target.is_massive() else target.rank) > 0 else 0.0
			score += DRONE_WEIGHT * _team_raw_attack_mean(sk) * maxf(waits, pull_on_team(sk) * MINE_PULL_SHARE)
	if f.devours > 0:
		# A kill feeds stacks of Overcharged: what the status adds to the die's own damage, a
		# stack, for about the rounds the stacks last. Read from the status, never hardcoded.
		score += p_kill * _stack_damage_gain("overcharged", _raw_attack_mean(ms)) * float(f.devours) * DEVOUR_ROUNDS
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
			score += p * (_capped(link, n.hp) + _kill_odds(link, n.hp) * (KILL_BONUS + _threat_now(n, sk) * HULL_WEIGHT))
			p *= _kill_odds(link, n.hp)
	score -= heat_cost(sk, ms, f, uses)
	return score - volatile_cost(sk, ms, f, uses) - cooldown_cost(ms, f, score)


## The heat this entry adds, on top of what the gauge already holds: whatever ends the turn
## over the cap burns hull, and a machine burnt out is the worst trade there is. Asked of the
## entry itself, not the one showing, so a reroll can weigh every entry the same way.
func heat_cost(sk: Skirmish, ms: Skirmish.MechState, f: Face, uses: float = 1.0) -> float:
	var fc := sk.forecast(ms, false)
	var over := maxi(0, int(fc["heat_end"]) + int(roundf(heat_of(ms, f) * uses)) - ms.heat_max)
	var cost := float(over - int(fc["overheat"])) * HULL_WEIGHT
	if not fc["destroyed"] and int(fc["hull_after"]) - (over - int(fc["overheat"])) <= 0:
		cost += DEATH_WEIGHT
	return cost


# ---------------------------------------------------------------- mines

## An empty slot as a target (the Lammergeier's): the pull's gather there, or a mine laid.
func slot_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, slot: Vector2i) -> float:
	if f.pulls_mines:
		return gather_score(sk, slot) - heat_cost(sk, ms, f)
	return mine_score(sk, ms, f, slot)


## A weapon laid as a mine: a shot delayed, worth its blow on the arrival at the odds one steps
## in (the arrival pays before it acts, so a stun, a burn, a shock and a Spread's neighbours
## count as on a blow), or a share of it when only a pull on the team's dice will cash it, on a
## foe of the field; less the heat, a volatile bite and a cooldown, as a blow's.
func mine_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, slot: Vector2i) -> float:
	f = Effects.effective_face(ms.unit, f)
	var p := arrival_odds(sk, slot)
	var hp := _waiting_hp(sk, slot.x)
	var threat := _waiting_threat(sk, slot.x)
	if p <= 0.0:
		p = pull_on_team(sk) * MINE_PULL_SHARE
		hp = _field_hp(sk)
		threat = 0.0   # a pull cashes it on a foe that may well have acted already
	var mean := expected_damage(ms, f, null)
	var score := minf(mean, hp) * p
	if f.has(Face.Keyword.SUPPRESS):
		score += p * threat * HULL_WEIGHT
	if f.has(Face.Keyword.BURN):
		var per := float(Effects.STATUS["burning"]["effects"][0]["value"])
		score += p * per * float(f.burn * (f.burn + 1)) / 2.0 * BURN_WEIGHT
	if f.has(Face.Keyword.SHOCK):
		score += p * minf(maxf(0.0, hp - mean), _team_raw_attack_mean(sk)) * SHOCK_WEIGHT
	if f.has(Face.Keyword.CLEAVE):
		for dc in [-1, 1]:
			var c: int = slot.y + dc
			if c >= 0 and c < sk.columns:
				var n := sk.foe_at(slot.x, c)
				if n != null and n.alive():
					score += p * minf(mean, float(n.hp))
	score *= MINE_WEIGHT
	return score - heat_cost(sk, ms, f) - volatile_cost(sk, ms, f) - cooldown_cost(ms, f, score)


## The pull on a foe: every mine on the field lands on it now, shot by shot in laid order, read
## as they will land (its flat damage-taken adds, a Shocked doubling once and a Shock shot
## charging the next, its armour off each), capped at what it has left, with the kill.
func pull_score(sk: Skirmish, target: Foe) -> float:
	var shots := _all_mines(sk)
	if shots.is_empty() or target == null or not target.alive():
		return 0.0
	var hp := float(target.hp)
	var shocked := Effects.has(target, "shocked")
	var add := float(Effects.damage_taken_add(target))
	var arm := float(target.armour_total())
	var dealt := 0.0
	for shot in shots:
		if hp <= 0.0:
			break
		var d := float(int(shot["damage"]))
		if d > 0.0:
			d += add
			if shocked:
				d *= 2.0
				shocked = false
		d = maxf(0.0, d - (0.0 if Array(shot["keywords"]).has(Face.Keyword.BREACH) else arm))
		dealt += minf(d, hp)
		hp -= d
		if Array(shot["keywords"]).has(Face.Keyword.SHOCK) and hp > 0.0:
			shocked = true
	var score := dealt
	if hp <= 0.0:
		score += KILL_BONUS + _threat_now(target, sk) * HULL_WEIGHT
	return score


## The pull on an empty slot: every mine gathers there, worth the pile at the odds a foe steps
## in, less what the mines were worth where they lay.
func gather_score(sk: Skirmish, slot: Vector2i) -> float:
	var total := 0.0
	var where := 0.0
	for s in sk.mines.keys():
		var v := 0.0
		for shot in sk.mines[s]:
			v += float(int(shot["damage"]))
		total += v
		where += arrival_odds(sk, s) * v
	return (arrival_odds(sk, slot) * minf(total, _waiting_hp(sk, slot.x)) - where) * MINE_WEIGHT


static func _all_mines(sk: Skirmish) -> Array:
	var shots: Array = []
	for slot in sk.mines.keys():
		shots.append_array(sk.mines[slot])
	shots.sort_custom(func(a, b) -> bool: return int(a["seq"]) < int(b["seq"]))
	return shots


## The odds a waiting foe steps into this empty slot at the round's end, in the reinforcement
## step's order (a massive foe takes a whole empty column first, then the slots fill left to
## right, each from those waiting of its rank): one when enough wait for it, else none.
static func arrival_odds(sk: Skirmish, slot: Vector2i) -> float:
	var massive := 0
	for f in sk.reinforcements:
		if f.is_massive():
			massive += 1
	var filled := {}
	for col in range(sk.columns):
		if massive > 0 and sk.front[col] == null and sk.back[col] == null:
			filled[col] = true
			massive -= 1
	if filled.has(slot.y):
		return 1.0
	var ahead := 0
	for col in range(sk.columns):
		if filled.has(col) or sk.foe_at(slot.x, col) != null:
			continue
		if col == slot.y:
			return 1.0 if waiting_for(sk, slot.x) > ahead else 0.0
		ahead += 1
	return 0.0


## The foes waiting for a rank (massive ones fill either).
static func waiting_for(sk: Skirmish, rank: int) -> int:
	var n := 0
	for f in sk.reinforcements:
		if f.is_massive() or f.prefers_back == (rank == 1):
			n += 1
	return n


## Does a live machine of the team carry the pull?
static func pull_on_team(sk: Skirmish) -> float:
	for ms in sk.live_mechs():
		for f in ms.die.faces:
			if f.pulls_mines:
				return 1.0
	return 0.0


static func _waiting_hp(sk: Skirmish, rank: int) -> float:
	var total := 0.0
	var n := 0
	for f in sk.reinforcements:
		if f.is_massive() or f.prefers_back == (rank == 1):
			total += float(f.hp)
			n += 1
	return total / float(n) if n > 0 else 0.0


static func _waiting_threat(sk: Skirmish, rank: int) -> float:
	var total := 0.0
	var n := 0
	for f in sk.reinforcements:
		if f.is_massive() or f.prefers_back == (rank == 1):
			total += float(f.attack)   # its move is not chosen until it stands: its base blow
			n += 1
	return total / float(n) if n > 0 else 0.0


static func _field_hp(sk: Skirmish) -> float:
	var total := 0.0
	var n := 0
	for f in sk.field_foes():
		if f.alive():
			total += float(f.hp)
			n += 1
	return total / float(n) if n > 0 else 0.0


## What Exposed on a foe is worth (21 October): its armour off each team blow likely before it
## fades (one a live machine, this round's rest and the next), and for a back-rank foe its
## formation hides, its kill and threat brought into Direct reach, as a share.
func expose_score(sk: Skirmish, foe: Foe) -> float:
	if foe == null or not foe.alive() or Effects.has(foe, "exposure"):
		return 0.0
	var blows := float(sk.live_mechs().size())
	var score := float(foe.armour_total()) * blows * HULL_WEIGHT * EXPOSE_WEIGHT
	if foe.rank == 1 and not sk.is_exposed(foe.column):
		score += (KILL_BONUS + _threat_now(foe, sk) * HULL_WEIGHT) * EXPOSE_WEIGHT * 0.5
	return score


## What Flak laid on one foe is worth (21 October): a point a stack on every team blow it takes
## before the stacks halve at the round's end, capped by what the foe will have left. The blows
## still to come this round are this spend's later strikes and the damaging entries the other
## machines show unspent, all of them on the spend's target and half on a neighbour it sprays
## (the team may well pick another); then a round of the team's blows at half the stacks, the
## halving, a blow a machine on the target and half that elsewhere. Damage in hand, at FLAK_WEIGHT.
func flak_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, foe: Foe, left: float, is_target: bool) -> float:
	if f == null or not f.has(Face.Keyword.FLAK) or left <= 0.0:
		return 0.0
	var stacks := f.flak + Effects.extra_stacks(ms.unit, "flakked", ms.heat)
	var now := float(maxi(0, f.strikes - 1))
	var next := 0.0
	for other in sk.live_mechs():
		next += 1.0
		if other == ms or other.assigned:
			continue
		var of := other.face()
		if of != null and of.is_attack() and (of.power > 0 or of.power_max > 0):
			now += float(maxi(1, of.strikes))
	var share := 1.0 if is_target else 0.5
	var gain := float(stacks) * now * share + float(int(stacks / 2)) * next * share
	return minf(left, gain) * FLAK_WEIGHT


## What a volatile entry costs its owner in the score: the hull it bites per use, and the
## death it brings when the round's end would already leave nothing to bite.
static func volatile_cost(sk: Skirmish, ms: Skirmish.MechState, f: Face, uses: float = 1.0) -> float:
	var bite := Skirmish.spend_bite(ms.unit, f)
	if bite <= 0:
		return 0.0
	var cost := float(bite) * uses * HULL_WEIGHT
	if not banked_on_hull(ms).is_empty():
		# The bite is hull damage, so it banks a stack the machine's own entries spend to roll
		# again (the Nemesis's rage): a share of the roll it will buy.
		cost -= RAGE_BANK_WEIGHT * ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms) * uses
	var fc := sk.forecast(ms, false)
	if not fc["destroyed"] and int(fc["hull_after"]) - int(roundf(bite * uses)) <= 0:
		cost += DEATH_WEIGHT
	return cost


## What a cooldown costs an entry (21 October): every round it stays dark after this one, the
## share of the die's rolls it would have shown, at what it is worth now; its own or the one
## its machine's passives grant (the Kite's), the longer. Rapid's switch-off ends with this
## round and costs nothing here.
static func cooldown_cost(ms: Skirmish.MechState, f: Face, worth: float) -> float:
	var later := maxi(f.cooldown_rounds(), Effects.granted_cooldown(ms.unit, f)) - 1
	if later <= 0 or worth <= 0.0 or ms.die.faces.is_empty():
		return 0.0
	return worth * float(later) / float(ms.die.faces.size())


## The status this machine banks on every hull hit that one of its own entries spends to
## roll again (the Nemesis's rage, 12 October), or "" when it has no such pair.
static func banked_on_hull(ms: Skirmish.MechState) -> String:
	for m in Effects.live(ms.unit):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != "on_hull_damage" or str(eff.get("effect", "")) != "stack_status":
				continue
			var st := str(eff.get("value", ""))
			for f in ms.die.faces:
				if f.rolls_again_on == st:
					return st
	return ""


## What one stack of a status adds to a blow of `mean` damage: a flat add as itself, a
## multiplier as its share of the blow. Read from the status, never hardcoded.
## What bracing its owner is worth (the Breaching Plow, 12 October): the hull the Braced
## stacks keep from the blows coming at its bare hull this round. The armour a stack gives is
## read from the status, never hardcoded.
func brace_score(sk: Skirmish, ms: Skirmish.MechState, stacks: int) -> float:
	var per := 0
	for eff in Effects.STATUS.get("braced", {}).get("effects", []):
		if str(eff.get("effect", "")) == "add_stat" and str(eff.get("stat", "")) == "armour":
			per += int(eff.get("value", 0))
	return _armour_saved(sk, ms, per * stacks) * HULL_WEIGHT


## Hull that `extra` armour keeps this round: every blow aimed at this machine that reaches
## its hull (past the shield's number or on bare hull) loses that much more, down to nothing,
## walked blow by blow as the forecast walks them; a breach meets no armour, so extra keeps
## none of it (one breach, 22 October).
func _armour_saved(sk: Skirmish, who: Skirmish.MechState, extra: int) -> float:
	if extra <= 0:
		return 0.0
	var saved := 0
	var walk := {"shield": who.unit.shield, "barrier": Effects.has(who.unit, "barrier")}
	for a in sk.attackers_of(who):
		for r in sk.blows_on(who, a, walk):
			if not bool(r.get("breach", false)):
				saved += mini(extra, int(r["through"]))
	return float(saved)


## What filling the hopper is worth (the Chainsaw Claw, 11 October): each load what this
## machine's best hopper-firing entry adds a load, at the odds a later shot fires it, while
## the hopper holds less than two of that entry's shots (more would sit unfired).
func hopper_fill_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe) -> float:
	var per_load := 0
	var per_shot := 0
	for e in ms.die.faces:
		var ef := Effects.effective_face(ms.unit, e)
		if ef.fires_hopper > 0 and ef.power_per_load > per_load:
			per_load = ef.power_per_load
			per_shot = ef.fires_hopper
	if per_load <= 0:
		return 0.0
	var reached := 1
	if f.has(Face.Keyword.CLEAVE):
		for c in [target.column - 1, target.column + 1]:
			if c >= 0 and c < sk.columns:
				var n := sk.foe_at(target.rank, c)
				if n != null and n != target and n.alive():
					reached += 1
	if f.has(Face.Keyword.PENETRATE):
		var other := sk.foe_at(1 - target.rank, target.column)
		if other != null and other != target and other.alive():
			reached += 1
	var room := maxi(0, per_shot * 2 - Effects.stacks_of(ms.unit, "hopper"))
	return float(mini(f.fills_hopper * reached, room) * per_load) * HOPPER_WEIGHT


## What `stacks` of a ticking status are worth on a foe with `hp` left, over the actions to
## come as a stack fades each: a flat tick (Burning) its value a stack a tick, a share
## (Vitriol) its share of what is left each tick, rounded down and never the last point, as
## the engine ticks it (Effects.tick_preview). Read from the status, never hardcoded.
static func dot_payout(status_id: String, stacks: int, hp: int) -> float:
	var flat := Effects.status_value(status_id, "tick_hp")
	var pct := Effects.status_value(status_id, "tick_hp_share")
	var total := 0.0
	var h := hp
	for k in range(stacks, 0, -1):
		if h <= 0:
			break
		var t := mini(h, flat * k)
		h -= t
		total += t
		if pct > 0 and h > 1:
			var s := mini(h - 1, int(floorf(float(h) * float(pct * k) / 100.0)))
			h -= s
			total += s
	return total


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
	if f != null and not f.is_attack():
		return f.heat   # equipment's printed heat, landing as it is (the Musk Ox's quick reload)
	if ms.ammo_max > 0 and f != null and not f.is_debuff():
		return Effects.debuff_heat(ms.unit, f)   # a forging machine's gun: only a foe's debuff heats it
	var added := int(Effects.attack(ms.unit, f, 0, f.heat)["heat"])
	return added - ms.heat if f.vents_all else added


## What one use of an attack entry can land, with the odds of each: [[damage, weight], ...].
## A rolled entry is read at five points (its ends, its quarters, its middle); a flat entry is
## one point. Overcharge, a target's missing hull and the pipeline's modifiers apply as the
## resolver applies them; the strikes multiply the blow.
func damage_outcomes(ms: Skirmish.MechState, f: Face, target: Foe = null) -> Array:
	f = Effects.effective_face(ms.unit, f, target)
	var rolls: Array[int] = []
	if not f.is_ranged():
		rolls.append(f.power)
	else:
		var span := f.power_max - f.power
		for q in [0.0, 0.25, 0.5, 0.75, 1.0]:
			rolls.append(f.power + int(roundf(span * q)))
	var fired := Skirmish.heat_bonus(ms, f)   # what the heat it fires adds
	fired += f.missing_bonus(target)   # and what the target's lost hull adds
	fired += Skirmish.hopper_bonus(ms.unit, f)   # and what the loads it fires add
	var out: Array = []
	var w := 1.0 / rolls.size()
	for v in rolls:
		var dmg: int = v + fired
		dmg = int(Effects.attack(ms.unit, f, dmg, 0, target)["damage"])
		# The foe's own statuses read last: a Shocked foe takes the first blow double. Then its
		# armour comes off every blow, so a braced foe is worth less to a volume weapon.
		var arm := target.armour_for(f) if target != null else 0
		var first := maxi(0, (Effects.damage_taken(target, dmg, ms.unit) if target != null else dmg) - arm)
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
	if f.reaches_all and f.is_equipment():
		# A spend reaching every ally (the Swallowtail's team shield, its Phased): each one's
		# worth, wherever the die was dropped.
		var plain := f.duplicate_face()
		plain.reaches_all = false
		for w in sk.reached_machines(ms, f):
			score += equipment_score(sk, ms, w, plain)
		return score
	match f.kind:
		Face.Kind.SHIELD:
			score = shield_score(sk, who, sk.shield_amount(ms, f, who), f.has(Face.Keyword.OVERSHIELD), ms)
			if f.vents > 0 or f.cools_all:
				score += vent_score(sk, who, who.heat if f.cools_all else f.vents)   # the Hoist's cooling half
			if who == ms:
				score += seal_score(sk, ms)
		Face.Kind.VENT:
			score = vent_score(sk, who, f.power)
			if who == ms:
				score += blast_score(sk, ms, mini(f.power, ms.heat))
			if f.shields > 0:
				score += shield_score(sk, who, sk.shield_amount(ms, f, who), false, ms)   # the combined entry's shield half
		Face.Kind.BUFF:
			if f.act_again:
				score = ROLL_AGAIN_WEIGHT * _raw_attack_mean(who)   # the Horn's charged form: the ally acts again
			else:
				score = buff_score(sk, who, f)
			if Effects.quick_turn_live(ms.unit, f):
				score += ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms)   # the Needletail's gate: Rapid once a round
	if f.has(Face.Keyword.CLEANSE):
		score += cleanse_score(sk, who)
	# The Forge's reloads (the Musk Ox's): the entry's own, else a vent's or a shield's on itself,
	# as far as the magazine has room; and a printed heat's price on the low heat bar.
	if ms.ammo_max > 0:
		var rule := Effects.forge_rule(ms.unit)
		var n := f.reloads_ammo
		if n <= 0 and who == ms and not f.reaches_all:
			n = int(rule.get("vent", 0)) if f.kind == Face.Kind.VENT else (int(rule.get("shield", 0)) if f.kind == Face.Kind.SHIELD else 0)
		score += float(mini(n, ms.ammo_max - ms.ammo)) * ammo_worth(sk, ms)
	if f.heat > 0:
		score -= heat_cost(sk, ms, f)
	return score - volatile_cost(sk, ms, f) - cooldown_cost(ms, f, score)


## What an ammo is worth to a forging machine (the Musk Ox's): a share of the best damage a gun
## on its die buys with one, read now (the salvo a strike); nothing for a machine that forges.
func ammo_worth(sk: Skirmish, ms: Skirmish.MechState) -> float:
	if ms.ammo_max <= 0:
		return 0.0
	var best := 0.0
	for face in ms.die.faces:
		if not face.is_attack() or face.is_debuff():
			continue
		if face.spends_magazine:
			best = maxf(best, salvo_per_strike(sk, ms, face))
			continue
		var price := Effects.ammo_price(ms.unit, face)
		if price > 0:
			best = maxf(best, expected_damage(ms, face, null) / float(price))
	return best * AMMO_SHARE


## One salvo strike's worth (the Unrestricted Expenditure): its blow on a random live foe and on
## every foe its Spread and Penetrate reach there, each capped at what it has left, averaged
## over the foes it may fall on.
func salvo_per_strike(sk: Skirmish, ms: Skirmish.MechState, f: Face) -> float:
	var live: Array[Foe] = []
	for foe in sk.field_foes():
		if foe.alive():
			live.append(foe)
	if live.is_empty():
		return 0.0
	var total := 0.0
	for t in live:
		var mean := expected_damage(ms, f, t)
		for n in sk.reached_by(f, t):
			if n.alive():
				total += minf(mean, float(n.hp))
	return total / float(live.size())


## The salvo spent now: every ammo a strike, capped at what the field has left, less what those
## ammo would buy on the die's other guns.
func salvo_score(sk: Skirmish, ms: Skirmish.MechState, f: Face) -> float:
	var n := ms.ammo
	if n <= 0:
		return -INF
	var field_hp := 0.0
	for foe in sk.field_foes():
		if foe.alive():
			field_hp += float(foe.hp)
	var other := 0.0
	for face in ms.die.faces:
		if face.is_attack() and not face.is_debuff() and not face.spends_magazine:
			var price := Effects.ammo_price(ms.unit, face)
			if price > 0:
				other = maxf(other, expected_damage(ms, face, null) / float(price))
	return minf(float(n) * salvo_per_strike(sk, ms, f), field_hp) - float(n) * other * AMMO_SHARE


## What a cleanse clears from a machine, in hull: the heat its Burning would add at the end of
## the turn (what it would put over the cap as hull, the rest as room), the heat Scorched would
## add to its weapons this turn (about one; it goes at the turn's end), the bites its
## Corrupted entries would take over the rounds to come, and the entries a foe switched off,
## at the die's own mean for each. A Scrambled reroll is small change.
func cleanse_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	var score := 0.0
	var tick := int(Effects.tick_preview(who.unit, true)["heat"])
	if tick > 0:
		var fc := sk.forecast(who, false)
		var over := mini(int(fc["overheat"]), tick)
		score += float(over) * HULL_WEIGHT + float(tick - over) * BANK_WEIGHT * CLEANSE_ROUNDS
	var scorch := Effects.stacks_of(who.unit, "scorched")
	if scorch > 0:
		for eff in Effects.STATUS["scorched"]["effects"]:
			if str(eff.get("effect", "")) == "add_heat":
				score += float(int(eff.get("value", 0)) * scorch) * BANK_WEIGHT
	var n := who.die.faces.size()
	if n > 0:
		for i in range(n):
			var bite := Effects.corrupt_stacks(who.unit, i) * Skirmish.corrupt_bite()
			score += float(bite) * HULL_WEIGHT * CLEANSE_ROUNDS / float(n)
			if Effects.is_entry_disabled(who.unit, i) and Effects.cleansable_disable(who.unit, i):
				score += _raw_attack_mean(who) * CLEANSE_ROUNDS / float(n)
	if Effects.has(who.unit, "scrambled"):
		score += KILL_BONUS * BANK_WEIGHT
	# Silenced: the buffs it sleeps wake now, and the keywords it muted come back.
	if Effects.has(who.unit, "silenced"):
		score += float(Effects.buff_stacks(who.unit)) * BANK_WEIGHT + (_raw_attack_mean(who) * 0.5 if not who.assigned else 0.0)
	return score


## A shield on a machine: the hull it keeps this round (each blow costs the shield its number
## and the excess passes), the death it prevents, and a little for what stands afterwards.
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


## A disrupt on a foe about to strike, or gathering a countdown it breaks off (15 October;
## valued 22 October): the blow it will not land, this round's or the countdown's at its
## discount, less the blow of the move the disrupt turns it to (Skirmish.disrupt_next), when that
## lands this round.
static func disrupt_score(sk: Skirmish, foe: Foe) -> float:
	if foe.is_suppressed() or not foe.alive():
		return 0.0
	var now := countdown_threat(foe, sk) if foe.gathering() else _threat_now(foe, sk)
	if now <= 0.0:
		return 0.0
	var next := sk.disrupt_next(foe)
	if next.is_empty():
		return 0.0
	var instead := 0.0
	if Foe.is_attack_action(next) and Foe.countdown_of(next) == 0:
		var machines: int = sk.live_mechs().size() if foe.has_keyword(next, "all") else 1
		instead = float(foe.damage_of(next) * maxi(1, int(next.get("strikes", 1))) * machines)
	return maxf(0.0, now - instead) * HULL_WEIGHT


## A gathering countdown's blow as a threat now (the boss mechanics of 15 October): the blow it
## will land when its count runs out, on every machine for a blow at every machine, at
## COUNTDOWN_DISCOUNT for each round it still gathers, one more while it is held this round.
## Nothing for a foe gathering nothing.
static func countdown_threat(f: Foe, sk: Skirmish = null) -> float:
	if not f.gathering() or not f.alive():
		return 0.0
	var machines: int = sk.live_mechs().size() if sk != null and f.reaches_every_machine() else 1
	var rounds := f.charge + (1 if f.is_suppressed() else 0)
	return float(f.damage() * f.strikes() * machines) * pow(COUNTDOWN_DISCOUNT, float(rounds))


## What stopping a foe's next action is worth (a Suppress): this round's blow, and on a gathering
## countdown the round it is held, its blow landing a round later. Nothing on a foe already held.
static func suppress_worth(sk: Skirmish, f: Foe) -> float:
	if f.is_suppressed():
		return 0.0
	return _threat_now(f, sk) + countdown_threat(f, sk) * (1.0 - COUNTDOWN_DISCOUNT)


## What a foe's fall opens (a boss in parts, 15 October; valued 22 October): the core it leaves
## unguarded, a share of the core's kill and threat; nothing for a foe that guards no core, one
## whose fall leaves its core guarded (another part standing under "any"), or a core open already.
static func core_opening(sk: Skirmish, part: Foe) -> float:
	for core in sk.field_foes():
		if core == part or not core.alive() or not core.has_parts() or core.guard.is_empty():
			continue
		if core.pack_id != part.pack_id or not core.part_ids.has(part.content_id) or not Effects.has(core, "guarded"):
			continue
		var standing := sk.parts_of(core)
		if not standing.has(part):
			continue
		if core.guard != "any" or standing.size() == 1:
			return (KILL_BONUS + _threat_now(core, sk) * HULL_WEIGHT) * OPEN_CORE_WEIGHT
	return 0.0


## What a foe's last act costs the team when it falls (15 October, the Behemoth's Meteor; valued
## 22 October): its blow the moment it falls, on the machine it aims at or every machine for a
## blow at every machine, through each one's shield and armour as they stand: hull at
## HULL_WEIGHT, shield at SHIELD_LOSS_WEIGHT, a wreck at DEATH_WEIGHT.
static func last_act_cost(sk: Skirmish, f: Foe) -> float:
	var blow := f.last_act()
	if blow.is_empty():
		return 0.0
	var amount := f.damage_of(blow)
	var whom: Array = []
	if f.has_keyword(blow, "all"):
		whom = sk.live_mechs()
	elif f.target != null and (f.target as Skirmish.MechState).alive():
		whom = [f.target]
	elif not sk.live_mechs().is_empty():
		whom = [sk.live_mechs()[0]]
	var cost := 0.0
	for m in whom:
		var shield: int = m.unit.shield
		var hull: int = m.unit.hull
		for s in range(maxi(1, int(blow.get("strikes", 1)))):
			var r := Skirmish._blow(shield, m.unit.hull_max, m.unit.armour, Effects.damage_taken(m.unit, amount, f), false)
			cost += float(int(r["absorbed"])) * SHIELD_LOSS_WEIGHT + float(int(r["through"])) * HULL_WEIGHT
			shield = int(r["shield"])
			hull -= int(r["through"])
		if hull <= 0:
			cost += DEATH_WEIGHT
	return cost


## A web on a foe (the funnel-web's Web Bomb, 18 October): the blow the foe it catches beside
## it will not land (this round's when the catch acts after it; its next, read as this round's,
## when it has acted), and the webbed foe's own next action, read as the blow it shows now,
## each at the odds Numbed lets the burst land; nothing on a foe already suppressed, which
## gains nothing from a second, and nothing on a foe already webbed.
func web_score(sk: Skirmish, target: Foe) -> float:
	if Effects.has(target, "webbed"):
		return 0.0
	var score := 0.0
	if not target.is_suppressed():
		score += _threat_next(target, sk) * HULL_WEIGHT * maxf(0.0, 1.0 - float(target.resist_total()) / 100.0)
	var beside := sk.web_catch(target)
	if beside != null and not beside.is_suppressed():
		score += _threat_next(beside, sk) * HULL_WEIGHT * maxf(0.0, 1.0 - float(beside.resist_total()) / 100.0)
	return score


## The blow a foe lands at its next action, read as the one it shows: its blow now, a
## gathering one included, on every machine for a blow at every machine, or its base attack
## when it shows a special.
static func _threat_next(f: Foe, sk: Skirmish) -> float:
	if f.target == null or not f.alive():
		return 0.0
	if f.attacks() or f.gathering():
		var machines: int = sk.live_mechs().size() if f.reaches_every_machine() else 1
		return float(f.damage() * f.strikes() * machines)
	return float(f.attack)


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
				if status.has("spent_by"):
					score += v * n   # Spun Up: damage on the next weapon spend, whenever it comes
				else:
					score += v * n * (1.0 if attack_now > 0.0 else 0.0) + v * n * float(f.buff_rounds - 1)
			"multiply_damage_taken":
				score += (1.0 - pow(v, n)) * float(sk.incoming_for(who)) * HULL_WEIGHT * float(f.buff_rounds)
			"add_stat":
				# Braced and its like: the armour stands behind this round's incoming blows.
				if str(eff.get("stat", "")) == "armour":
					score += _armour_saved(sk, who, int(v) * n) * HULL_WEIGHT * float(f.buff_rounds)
			"add_burn":
				var per := float(Effects.STATUS["burning"]["effects"][0]["value"])
				score += per * v * n * BURN_WEIGHT * (1.0 if attack_now > 0.0 else 0.0) * float(f.buff_rounds)
			"shock_on_hull_strike":
				# Every foe about to reach this machine's hull comes out Shocked: the team's
				# next blow on it lands double, worth about the die's own damage again, capped
				# at what the foe has left.
				var walk := {"shield": who.unit.shield, "barrier": Effects.has(who.unit, "barrier")}
				for a in sk.attackers_of(who):
					var reaches := false
					for r in sk.blows_on(who, a, walk):
						reaches = reaches or int(r["through"]) + int(r["armoured"]) > 0
					if reaches:
						score += minf(float(a.hp), _team_raw_attack_mean(sk)) * SHOCK_WEIGHT
	match f.buff_status:
		"barrier":
			score += barrier_score(sk, who)
		"ward":
			score += ward_score(sk, who)
		"phased":
			score += phased_score(sk, who)
		"rallied":
			score += REROLL_SHARE * _team_raw_attack_mean(sk) * float(n)   # a team reroll more this round
	return score


## What Phased is worth on a machine yet to act (the Swallowtail's charged Screens): the round's
## end without a blow reaching it, the hull kept and the death prevented, less the action it
## stands down, its die's entry at its worth now.
func phased_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	if who.assigned:
		return 0.0
	var after := _forecast_with(sk, who, "phased")
	if after.is_empty():
		return 0.0
	return _outlook_gain(sk.forecast(who, false), after) - face_value(sk, who, who.face())


## The round's end with and without a status on `who`, read in a what-if: the forecast with
## it granted for the round, then the grant taken back. Empty when the machine has it already
## (a second one renews, and changes nothing this round).
static func _forecast_with(sk: Skirmish, who: Skirmish.MechState, status_id: String) -> Dictionary:
	if Effects.has(who.unit, status_id):
		return {}
	var m := Effects.grant_buff(who.unit, status_id, 1, "what-if", sk.round)
	var fc := sk.forecast(who, false)
	who.unit.modifiers.erase(m)
	return fc


## What a Barrier is worth (21 October): the round's end as the forecast reads it with the
## first blow that deals anything taken whole: the hull kept and the death prevented, and a
## little for the shield it keeps standing, as a shield's own score reads them.
func barrier_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	var after := _forecast_with(sk, who, "barrier")
	if after.is_empty():
		return 0.0
	return _outlook_gain(sk.forecast(who, false), after)


## What a Ward is worth (21 October): the breach it turns away, read as the Barrier's is (the
## blow lands on the shield instead, so the hull kept less the shield it costs), and every
## rider the blows aimed at it would lay this round, each at what a cleanse would clear of it:
## a Scorch's and a Burn's heat, a disabled entry's share of the die, a corruption's bites.
func ward_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	var after := _forecast_with(sk, who, "ward")
	if after.is_empty():
		return 0.0
	var score := _outlook_gain(sk.forecast(who, false), after)
	var n := maxi(1, who.die.faces.size())
	var scorch := 0
	for eff in Effects.STATUS["scorched"]["effects"]:
		if str(eff.get("effect", "")) == "add_heat":
			scorch += int(eff.get("value", 0))
	var burn := Effects.status_value("burning_mech", "tick_heat")
	for a in sk.attackers_of(who):
		var blows := float(a.strikes())
		if a.has_keyword(a.action, "scorch"):
			score += float(scorch) * blows * BANK_WEIGHT
		if a.has_keyword(a.action, "burn"):
			score += float(burn) * blows * BANK_WEIGHT
		if a.has_keyword(a.action, "disable"):
			score += _raw_attack_mean(who) / float(n)
		if a.has_keyword(a.action, "corrupt"):
			score += float(Skirmish.corrupt_bite()) * blows * HULL_WEIGHT * CLEANSE_ROUNDS / float(n)
		# A silence sleeps the machine's buffs for the round, a purge takes them: the stacks at
		# stake, a purge's for the rounds they would have run.
		if a.has_keyword(a.action, "silence"):
			score += float(Effects.buff_stacks(who.unit)) * BANK_WEIGHT
		if a.has_keyword(a.action, "dispel"):
			score += float(Effects.buff_stacks(who.unit)) * BANK_WEIGHT * CLEANSE_ROUNDS
	return score


## Two forecasts of one machine's round, read as a shield's score reads them: the hull kept,
## the death prevented, and the shield left standing at the bank's weight.
static func _outlook_gain(before: Dictionary, after: Dictionary) -> float:
	var score := (maxf(0.0, float(after["hull_after"])) - maxf(0.0, float(before["hull_after"]))) * HULL_WEIGHT
	if before["destroyed"] and not after["destroyed"]:
		score += DEATH_WEIGHT
	score += float(int(after["shield_after"]) - int(before["shield_after"])) * BANK_WEIGHT
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


## What a vent's blast is worth (the Whip Scorpion's, 21 October): the heat it takes off, as
## one blow on a random live foe, each foe's share of it: what it deals past the foe's own
## modifiers and armour, capped at what the foe has left, and the kill when it finishes one.
func blast_score(sk: Skirmish, ms: Skirmish.MechState, vented: int) -> float:
	var share := Effects.vent_blast(ms.unit)
	if share <= 0.0 or vented <= 0:
		return 0.0
	var amount := int(roundf(float(vented) * share))
	var live: Array = sk.field_foes().filter(func(foe: Foe) -> bool: return foe.alive())
	if live.is_empty():
		return 0.0
	var total := 0.0
	for foe in live:
		var taken := maxi(0, Effects.damage_taken(foe, amount, ms.unit) - foe.armour_total())
		total += minf(float(taken), float(foe.hp))
		if taken >= foe.hp:
			total += KILL_BONUS + _threat_now(foe, sk) * HULL_WEIGHT
	return total / float(live.size())


## What a swap is worth (the Dingo's Combat Translocator, a first reading of 21 October): a foe
## the swap brings into the front rank stands exposed to the team's Direct fire, worth a share
## of its kill and its threat; one it sends to the back hides by the same. Bunching foes for an
## area piece is bunching_score's; the acting order is not read yet.
static func swap_score(sk: Skirmish, first: Foe, second) -> float:
	var to := Vector2i(second.rank, second.column) if second is Foe else (second as Vector2i)
	var score := _front_worth(sk, first) * float(first.rank - to.x)
	if second is Foe:
		score += _front_worth(sk, second) * float((second as Foe).rank - first.rank)
	return score


## What a swap is worth to the team's area pieces this round (the Dingo's Combat Translocator;
## bunching, 22 October): for every other machine yet to act whose entry showing reaches more
## than its target (a Spread's row, a Penetrate's column, the drum's shape by the aim), the most
## its widest spend would deal past its target after the swap against before it, read by trading
## the two places in a what-if. The greedy still spends one die at a time, so the swap goes first
## only when its whole worth tops the ally's own spend.
static func bunching_score(sk: Skirmish, ms: Skirmish.MechState, first: Foe, second) -> float:
	var areas: Array = []
	for m in sk.live_mechs():
		if m == ms or m.assigned or m.face() == null:
			continue
		var f := sk.spend_face(m)
		if f == null or not f.is_attack() or f.reaches_all or f.spends_magazine or (f.power <= 0 and f.power_max <= 0):
			continue
		areas.append([m, f, _mean_blow(m, f)])
	if areas.is_empty():
		return 0.0
	var before := _widest(sk, areas)
	var after := [0.0]
	sk.swap_what_if(first, second, func() -> void: after[0] = _widest(sk, areas))
	return maxf(0.0, float(after[0]) - before) * BUNCH_WEIGHT


## The team's area entries at their widest: for each, over its targets, the most its spend would
## deal to the live foes it reaches past its target (its mean blow less each foe's armour, capped
## at what the foe has left); an entry that reaches only its target adds nothing.
static func _widest(sk: Skirmish, areas: Array) -> float:
	var total := 0.0
	for a in areas:
		var m: Skirmish.MechState = a[0]
		var f: Face = a[1]
		var blow: float = a[2]
		var most := 0.0
		for t in sk.targets_for_face(m, f):
			var ef := Effects.effective_face(m.unit, f, t)
			if not ef.has(Face.Keyword.CLEAVE) and not ef.has(Face.Keyword.PENETRATE):
				continue
			var past := 0.0
			for foe in sk.reached_by(ef, t):
				if foe != t and foe.alive():
					past += minf(maxf(0.0, blow - float(foe.armour_total())), float(foe.hp))
			most = maxf(most, past)
		total += most
	return total


## An attack entry's mean blow from its machine, every strike, before any foe.
static func _mean_blow(m: Skirmish.MechState, f: Face) -> float:
	var mean := int(roundf(float(f.power + f.power_max) * 0.5))
	return float(Effects.attack(m.unit, f, mean, 0)["damage"]) * float(maxi(1, f.strikes))


## A foe's worth standing in the front rank, where Direct fire reaches it.
static func _front_worth(sk: Skirmish, foe: Foe) -> float:
	return (KILL_BONUS + _threat_now(foe, sk) * HULL_WEIGHT) * SWAP_WEIGHT


## What sealing is worth (the Armadillo's Lockdown, 20 October; valued 21 October): a shield
## it spends on itself seals it, and the armour stands behind this round's blows, less the heat
## the seal adds as the turn ends and the cooling it stops, as room lost. Nothing when it is
## sealed already or has no seal.
func seal_score(sk: Skirmish, ms: Skirmish.MechState) -> float:
	var seal := Effects.seal_form(ms.unit)
	if seal.is_empty() or Effects.is_sealed(ms.unit):
		return 0.0
	var kept := _armour_saved(sk, ms, int(seal["armour"])) * HULL_WEIGHT
	var cost := float(int(seal["heat"]) + ms.unit.cooling) * BANK_WEIGHT
	return kept - cost


## What a Siphon is worth to a machine whose vents blast (the Whip Scorpion's, 21 October): the
## heat every blow this round adds, the formation's blows once the lure has turned it, up to the
## room left under the maximum, as next round's blast at FUEL_WEIGHT. To a machine whose vents
## blast nothing the heat is no fuel, and the brace and the lure carry the spend.
func siphon_score(sk: Skirmish, ms: Skirmish.MechState, per_blow: int) -> float:
	var share := Effects.vent_blast(ms.unit)
	if share <= 0.0:
		return 0.0
	var blows := 0
	for foe in sk.field_foes():
		if foe.alive() and foe.attacks() and not foe.is_suppressed():
			blows += foe.strikes()
	var room := maxi(0, ms.heat_max - ms.heat)
	return float(mini(blows * per_blow, room)) * share * FUEL_WEIGHT


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
			for slot in sk.slot_targets(ms, f):
				best = maxf(best, slot_score(sk, ms, f, slot))
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


## What a reroll of this die is worth, the bar a greedy reroll clears: the die's mean, or for
## a stepping die the entry it steps to, known in advance (the Cassowary's dial, 21 October);
## a Scrambled reroll is a true roll either way.
func reroll_worth(sk: Skirmish, ms: Skirmish.MechState) -> float:
	if Effects.steps_die(ms.unit) and not Effects.is_scrambled(ms.unit):
		var nf := sk.next_face(ms)
		if nf != null:
			return face_value(sk, ms, nf)
	return die_mean(sk, ms)


## The team's hull as a percentage of its maximum, dead machines included.
static func hull_percent(sk: Skirmish) -> int:
	var hull := 0
	var hull_max := 0
	for ms in sk.mechs:
		hull += maxi(0, ms.unit.hull)
		hull_max += ms.unit.hull_max
	return 100 if hull_max <= 0 else int(100 * hull / hull_max)


# ---------------------------------------------------------------- private

## Reroll every unspent die showing less than its average (a stepping die, less than the entry
## it steps to), while rerolls last. A reroll never lands on the same entry, so this is a real
## second chance, not a coin flip.
func _greedy_rerolls(sk: Skirmish) -> void:
	# A machine's own free rerolls first, one die at a time, while it shows less than its mean.
	for i in range(sk.mechs.size()):
		var ms: Skirmish.MechState = sk.mechs[i]
		while ms.alive() and not ms.assigned and ms.free_rerolls > 0 and face_value(sk, ms, sk.spend_face(ms)) + 0.001 < reroll_worth(sk, ms):
			if not sk.reroll([i]):
				break
			rerolls += 1
	while sk.rerolls_left > 0:
		var idx: Array = []
		for i in range(sk.mechs.size()):
			var ms: Skirmish.MechState = sk.mechs[i]
			if not ms.alive() or ms.assigned:
				continue
			if face_value(sk, ms, sk.spend_face(ms)) + 0.001 < reroll_worth(sk, ms):   # a charged form as it will go out
				idx.append(i)
		if idx.is_empty():
			return
		if not sk.reroll(idx):
			return
		rerolls += 1


## The blow this foe is about to land, if it is aimed at anyone: on every live machine for a
## blow at every machine (`all`).
static func _threat_now(f: Foe, sk: Skirmish = null) -> float:
	if f.target == null or f.is_suppressed() or not f.attacks():
		return 0.0
	var machines: int = sk.live_mechs().size() if sk != null and f.hits_all() else 1
	return float(f.damage() * f.strikes() * machines)


func _tally(f: Face) -> void:
	if f == null:
		return
	var key := f.component
	if f.kind == Face.Kind.BLANK:
		key = "disabled" if f.disabled else ("empty" if f.empty else "destroyed")
	spends[key] = int(spends.get(key, 0)) + 1

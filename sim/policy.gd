class_name Policy
extends RefCounted

## A player for the headless skirmish, so balance can be measured at a scale nobody can play
## by hand (Ryan, 25 September). A ladder of skill rather than one bot, because a win rate
## means nothing on its own and a band means something:
##   RANDOM  never rerolls, spends every die on any legal target, shields and vents itself.
##           The floor: a fight random play wins is too easy, no argument.
##   GREEDY  reads the forecast (Skirmish.forecast: the blows the screen's round preview shows,
##           summed by hand, without what only playing the round finds, a heal or a last act)
##           and takes the best one-round trade, rerolling dice that came up under their
##           die's average. A competent new player. It cannot see anything the player cannot.
##   BLIND   the tests' blind play (the bible's section 2: "a team that spends each die on the
##           nearest foe"): the greedy's rerolls, then every weapon and debuff on the nearest foe in
##           reach and every shield, vent and buff on its own machine, holding only what would overheat
##           or wreck it. The floor the coordination gap is read from (22 October).
##   PLANNER plans two rounds (the stock pass's second chunk, 22 October): at every spend it
##           rolls out the greedy's best few candidates (a copy of the fight, the spend made,
##           the rest of the turn, the enemy's turn and the next round played by the greedy
##           rung, the future dice and picks drawn from a seed of its own, never the real
##           fight's) and keeps the one whose fight is worth most. A team that sets up and
##           cashes across rounds: the top the gap is read against.
## A persona is a habit on top (the withdrawing one went with the withdrawal, the long wall brief
## 3.5): `cool_above` keeps each machine's gauge under a share of its maximum, pricing the
## heat a spend leaves above that line as an overheat's hull, so it vents early and holds a hot
## gun there (the heat report's cautious persona, 30 October; the rungs as they are play the
## reckless one, cooling only against an overheat); `shield_ahead` values a shield left standing
## by the blows it turns next round, where the rungs bank it at a fifth of a point (the support
## ladders' bot, 30 October); `guard_weight` is a block's worth as a share (a Barrier, Armoured, a
## Ward, Phased: is_block), and near nothing it is the aggressor, which never rerolls for a block
## and spends one only when its die is stuck showing it (the refit pass, 9 November: the hull the
## blocks keep and the rounds they cost are read as the gap between it and the rung that takes
## every block worth making). The weights here trade mech hull against
## foe hit points and are knobs for the tool, not the game. Nothing here is shown to the player.

const RANDOM := 0
const GREEDY := 1
const BLIND := 2
const PLANNER := 3
const KIND_NAMES := {RANDOM: "random", GREEDY: "greedy", BLIND: "blind", PLANNER: "planner"}
const PLAN_CANDIDATES := 4   # the spends the planner rolls out at a decision: the greedy's pick and the next best, each machine's best among them
const PLAN_SAMPLES := 2      # futures each candidate is rolled out over, the same seeds for every candidate (common random numbers)

const MAX_ROUNDS := 60           # a fight nobody can finish (armour holds, dice all blank) is stalled
const STALEMATE_ROUNDS := 10     # rounds running with nothing changed that mark a stalemate (the long wall brief, section 5)
const HULL_WEIGHT := 1.5         # a point of mech hull, in foe hit points: hull is the resource that persists
const KILL_BONUS := 3.0         # a slot cleared: the back rank opens, the horde shrinks
const DEATH_WEIGHT := 20.0       # a machine kept alive through the round
const BANK_WEIGHT := 0.2         # shield stood up or heat room made for a later round
const ABLATE_WEIGHT := 0.5       # Ablating's stacks on a foe pay out over the rounds to come
const ABLATED_WEIGHT := 0.5      # a point Ablating will take off a machine on a later turn, the shield first: between a banked point of shield and a point of hull
const OPTION_GUARD := 64         # spends in one round, at most: rapid rerolls the die and acts again
const FLARE_ROUNDS := 1.0        # rounds of damage a stack its own kill grants is worth (the Ammit's flare): it lands as the round ends, whole through its next turn and halving after; a placeholder
const HOLD_ROUNDS := 1.0         # rounds of damage a stack held whole into the next round is worth (the Quintessence Tap's hold): whole next round and halving after, less the round's wait
const ESSENCE_WEIGHT := 0.3         # a count spent for a buff (1 Essence the Tap consumes), in foe hit points: a fifth of a flare for the rest of the battle, which the bot's one fight cannot see; a placeholder
const SHOCK_WEIGHT := 0.6        # a Shock cashed later (a mine's, a hull's): the doubled blow, as a share of the team's average; a blow's own reads the hitter in hand (shock_cash)
const CLEANSE_ROUNDS := 2.0      # rounds a cleansed status would otherwise have cost (Corrupted lasts the fight, Ablating fades)
const EXPOSED_SHARE := 0.5       # what standing Exposed next round would cost, at a share: it is a round away and answered there too (a Lure, a Cleanse, a kill, a reboot the turn before); a placeholder
const HOPPER_WEIGHT := 0.6       # a load in the hopper, as a share of what it adds when a later shot fires it
const PLATE_ROUNDS := 2.0        # rounds a held load's Armoured is likely to stand (this round's blows and the next's), for the hull its armour keeps
const HARDENED_ROUNDS := 2.0     # rounds a stack of Hardened Light is read to stand (the Storm Petrel's, 18 November): it lasts until its shield breaks, a reboot's drop among the breaks, so about half a reboot's cycle; a placeholder
const RICOCHET_WORTH := 2.0      # a stack of Ricochet (the Skua's, 11 November), in foe hit points: about two shots' worth before the fight ends or a blow halves it; a placeholder, as every weight
const AILE_REACH_WORTH := 0.3    # an Aile buff's Indirect reach on the next weapon (the Macaque's booster, 19 November), as a share of the machine's own average blow: the back rank it opens; a placeholder
const AILE_ARMOUR_WORTH := 0.5   # and the Blitz's armour ignored, a point of armour off each foe it may strike, a share of it a strike; a placeholder
const ROLL_AGAIN_WEIGHT := 1.0   # another action of the die (Rapid, Instant, the reset gun, the Horn's), as the die's own average blow
const VITRIOL_WEIGHT := 0.5      # a status a passive lays (the funnel-web's acid) pays out over the actions to come, as Ablate's does
const DRILL_BRITTLE := 1.0       # a Brittle the drill holds on its foe: about one more blow of the squad's lands on it a turn (a first cut, 24 November)
const DRILL_FOCUS := 0.5         # a use on a foe a drill is in: the Momentum it gives the drill's machine, a fifth of a turn more in the foe
const NEEDLE_PROGRESS := 0.5     # a Sonic Needle short of its bolt: its share of the bolt, at the odds the bolt still comes (a first cut, 20 November)
const BRITTLE_WEIGHT := 0.5         # a stack of Brittle, as the point it adds to each team blow the foe is likely to take while it lasts
const SWAP_WEIGHT := 0.25        # a foe brought into the front rank by a swap, as a share of its kill and its threat: it stands exposed to Direct fire
const BUNCH_WEIGHT := 0.75       # what a swap adds to an ally's area entry this round, as a share: the ally may still spend elsewhere
const COUNTDOWN_DISCOUNT := 0.75 # a gathering blow's worth now, for each round it still gathers: it lands later, and the fight may end first
const OPEN_CORE_WEIGHT := 0.5    # a part's kill that opens its core, as a share of the core's kill and threat: the core still has to be hit
const SHIELD_LOSS_WEIGHT := 0.5  # a point of shield a last act takes, in foe hit points: it recharges out of fights, where hull does not
const EXPOSE_WEIGHT := 0.5       # Exposed on a foe: its armour off each team blow likely before it fades, and a back-rank foe in Direct reach, as a share
const MINE_WEIGHT := 0.8         # a Mine left on a foe, as a share of its blast: delayed until its foe falls, the neighbours it meets then as they stand now
const REROLL_SHARE := 0.4        # a team reroll more (equipment's own rule), as a share of the team's average blow
const AMMO_SHARE := 0.5          # an ammo (the Musk Ox's magazine), as a share of the best damage a gun on its die buys with one
const PRIMED_WORTH := 2.0        # a stack of Primed on a foe (28 October): the Ablating the move that spends it leaves, a placeholder
const REGEN_WEIGHT := 0.5        # a point of shield a regeneration brings in a round to come, as a share of the hull it keeps: those blows are guessed from this round's (the Storm Petrel's, 30 October)
const AHEAD_SHARE := 0.6         # the shield persona: a blow next round, as a share of one this round (the fight may end, the foes pick afresh)
const CYCLE_AHEAD := 0.6         # a stepping die's next round, as a share of this one: where the dial rests now is the chamber it opens on (the Cassowary's cycle, 3 November)
const RAGE_SHARE := 0.5          # a Rage's flurry next turn (the Nemesis's), as a share of its swings' plain damage: a round away, the fight may end first, and it ends in a bare round; a placeholder
const RAGE_SWINGS := 8           # the most swings a Rage is read for: past it the heat is a burn, never more fists
const SHOT_SHARE := 0.5          # the shot a machine's held heat banks for its reboot piece (the Whip Scorpion's Death Ray), as a share of it: a round or more away, the fight may end first; a placeholder
const REBOOT_KEEP := 1           # the reboot's first play (a what-if): the shield this round's blows would take off a machine that it gives up without a thought when it reboots

var kind: int = GREEDY
var cool_above: int = 0          # persona: keep the gauge under this percent of the maximum (0: cool only against an overheat)
var shield_ahead: bool = false   # persona: a standing shield valued by the blows it turns next round (the support ladders' bot, 30 October)
var guard_weight: float = 1.0    # persona: a block's worth, as a share of what the rung reads (is_block); near nothing, the aggressor (the refit pass, 9 November)
var rng := RandomNumberGenerator.new()

## What the fight cost and how it was played, for the runner to tally.
var rounds: int = 0
var rerolls: int = 0
var overheat_hull: int = 0
var overheats: int = 0           # overheat events (a machine over its maximum as a turn ends)
var heat_peak_pct: float = 0.0   # the hottest any machine stood as a turn ended, percent of its maximum
var hot_rounds: int = 0          # rounds a machine ended its turn at four fifths of its maximum or more
var forced_holds: int = 0        # damaging dice held because spending them would cross the maximum (the heat report, 13 October: spikes, not actions)
var reboots: int = 0             # turns given to a reboot
var _owed: Array[int] = []        # machines that owe a reboot as their second spend this turn (_reboot_first)
var forgone: float = 0.0         # the damage those dice would have dealt, at their mean
var spends: Dictionary = {}      # component id, or "empty", "destroyed", "disabled" -> times spent
var stalled: bool = false
var stalemate: bool = false      # ten rounds running with no foe's HP, no machine's hull or shield changed (the long wall brief, section 5); counted apart from a stall, the cap staying MAX_ROUNDS
var _still := 0
var _last_sig := Vector3i(-1, -1, -1)
var plans: int = 0               # the planner's decisions that weighed more than one candidate
var plan_changes: int = 0        # of those, the ones where it spent otherwise than the greedy would
var actions_bought: int = 0      # an ally's action bought with the team's rerolls (the Immelmann Booster, 30 October)
var banked: int = 0              # rerolls the bank carried as each turn ended, summed (Maverick's Playbook, 30 October)
var gate_free: int = 0           # spends a once-a-round gate made Rapid (the Needletail's, 3 November)
var paints: int = 0              # Expose spends on a foe (the Needletail's Fovea Designator)
var paints_cashed: int = 0       # of those, the ones an ally's Direct weapon spend cashed while the foe stood Exposed
var _painted: Dictionary = {}    # foe -> the machine whose Expose stands on it, uncashed


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
		sk.start_round()
		rounds += 1
		play_round(sk)
		_read_heat(sk)
		if sk.outcome != Skirmish.Outcome.NONE:
			break
		sk.end_round()
		banked += sk.banked
		for o in sk.overheats:
			overheat_hull += int(o.get("burn", o["over"]))
			overheats += 1
		_read_stalemate(sk)
	return sk.outcome


## A stalemate (the long wall brief, section 5): no foe's HP, no machine's hull or shield moved
## for STALEMATE_ROUNDS rounds running, read as each round ends; the fight plays on to its end
## or the cap.
func _read_stalemate(sk: Skirmish) -> void:
	var hp := 0
	for f in sk.field_foes() + sk.reinforcements:
		hp += maxi(0, f.hp)
	var hull := 0
	var shield := 0
	for ms in sk.mechs:
		hull += maxi(0, ms.unit.hull)
		shield += ms.unit.shield
	var sig := Vector3i(hp, hull, shield)
	_still = _still + 1 if sig == _last_sig else 0
	_last_sig = sig
	if _still >= STALEMATE_ROUNDS:
		stalemate = true


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


## One player turn, from the dice showing to every die spent or skipped. `rerolls` false skips
## the turn's opening rerolls (a rollout picking up a turn already under way).
func play_round(sk: Skirmish, rerolls: bool = true) -> void:
	if rerolls and kind != RANDOM:
		_greedy_rerolls(sk)
	_reboot_first(sk)
	if kind == BLIND:
		_blind_round(sk)
		_reboot_idle(sk)
		return
	var held: Array[int] = []   # dice left unspent this round: nothing in reach, or every spend a loss
	var guard := 0
	while sk.state == Skirmish.State.ASSIGN and guard < OPTION_GUARD:
		guard += 1
		var best: Dictionary = {}
		var alternatives: Array = []       # the planner's: each machine's best two spends worth making
		for i in range(sk.mechs.size()):
			var ms: Skirmish.MechState = sk.mechs[i]
			if not ms.alive() or ms.assigned or held.has(i):
				continue
			# Its second spend the reboot (the Needletail's): one it owed, or one its spend made it want.
			if _reboots_second(sk, i):
				_reboot(sk, i)
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
				# A machine whose reboot fires a piece first (the Whip Scorpion's Death Ray) fires it, and
				# reboots, when the piece's best spend, less the round it then stands bare, is worth more
				# than its die's best. One that may not reboot (it has spent this turn) spends.
				if sk.can_reboot(i) and piece_worth(sk, i) > float(pick["score"]) and _reboot(sk, i):
					continue
				if kind == PLANNER:
					alternatives.append_array(_top_two(opts))
			if best.is_empty() or pick["score"] > best["score"]:
				best = pick
			if kind == RANDOM:
				break   # the first unspent die, any option: no weighing across the team
		if best.is_empty():
			break
		if kind == PLANNER:
			best = _plan(sk, best, alternatives)
		var ms: Skirmish.MechState = sk.mechs[best["mech"]]
		var spent := ms.face()
		var charged := sk.charge_lands(ms)
		var marks := _paint_marks(sk, ms, spent, best["target"])
		if sk.assign(best["mech"], best["target"], best.get("second", null)):
			_tally(spent, charged)
			_note_paints(ms, best["target"], marks)
			if spent != null and spent.action_price > 0 and best["target"] is Skirmish.MechState and best["target"] != ms:
				actions_bought += 1
			# An entry that buys an ally's action (the Immelmann Booster) waits for an ally to spend:
			# a die held for it is weighed again once one has.
			var still: Array[int] = []
			for h in held:
				if not _buys_action(sk, sk.mechs[h]):
					still.append(h)
			held = still
		else:
			held.append(best["mech"])
	_reboot_idle(sk)


## The reboot's first play (Ryan, 13 November; docs/briefs/refit_pass.md, section 22): the
## machines that owe one give their turn before any die is spent.
## A first cut, no weighing against the spend it gives up, so the runners still play a fight under
## the rule and its reads are a floor: a bot that reads the foes' picks reboots where no blow would
## cost it a shield worth keeping. A machine that may reboot after an action (the Needletail's,
## Skirmish.can_reboot) spends first where it has a spend worth making, and owes the reboot after
## it (_owed): the vent takes that spend's heat with the rest.
func _reboot_first(sk: Skirmish) -> void:
	_owed.clear()
	for i in range(sk.mechs.size()):
		if sk.can_reboot(i) and _wants_reboot(sk, sk.mechs[i]):
			if Effects.one_of_each(sk.mechs[i].unit):
				_owed.append(i)   # its spend's heat is free before the reboot (heat_cost), so it is weighed so
				if _best_score(sk, i) > 0.0:
					continue
				_owed.erase(i)
			_reboot(sk, i)


## The best a machine's die offers now, or -1 with nothing to spend on.
func _best_score(sk: Skirmish, i: int) -> float:
	var best := -1.0
	for o in options_for(sk, i):
		best = maxf(best, float(o["score"]))
	return best


## Whether this machine's next spend comes before a reboot it owes (_owed), or is its reboot
## piece's (the Whip Scorpion's Death Ray, up): its heat is vented with the rest, so it costs nothing.
func _vents_after(sk: Skirmish, ms: Skirmish.MechState) -> bool:
	if ms.rebooting:
		return false
	if ms.ray_from >= 0:
		return true   # its reboot piece up (the Whip Scorpion's Death Ray): the reboot after the spend vents its heat
	if _owed.is_empty():
		return false
	var i := sk.mechs.find(ms)
	return i >= 0 and _owed.has(i)


## Whether a machine that has spent once may reboot as its second spend and should: it owed the
## reboot as the turn began (_reboot_first), or wants one now, the spend's heat on it.
func _reboots_second(sk: Skirmish, i: int) -> bool:
	var ms: Skirmish.MechState = sk.mechs[i]
	if ms.spends == 0 or not sk.can_reboot(i):
		return false   # a reboot after its action (the Needletail's), its die done or not
	return _owed.has(i) or _wants_reboot(sk, ms)


## Whether a machine that may reboot should, before it spends (_reboot_first): past its maximum
## it burns every turn, so always, unless a vent it shows takes it back under; with its shield broken, when a blow is coming or its heat is
## half spent; with the entry it shows too hot to fire without passing its maximum, when this
## round's blows would take little of its shield; and to top up a shield at a quarter or less
## with its heat half spent, when none are coming. The blind and the random bot read no picks:
## they reboot at the maximum or on a break, whatever is coming. One that would rage (the
## Nemesis's) never reboots to make room for its entry or for a shield short of broken: its
## maximum is the Rage it climbs toward (rage_worth).
func _wants_reboot(sk: Skirmish, ms: Skirmish.MechState) -> bool:
	var blind := kind == BLIND or kind == RANDOM
	var rager := not Effects.rage_piece(ms.unit).is_empty()   # one that would rage (the Nemesis's) reads its maximum as the Rage it opens, never a wall
	var banker := shot_worth(ms, ms.heat) > 0.0   # one whose heat is its shot (the Whip Scorpion's): its reboot fires it, weighed against its die (piece_worth), never a reboot for room
	# A burrower whose drill still works in a foe (the Mole's) gives it up as it burrows, the burrow
	# taking it home with what is left: only an overheat takes it under then, and its guns fight on.
	if drill_working(sk, ms):
		return ms.overheat_stacks() > 0
	if ms.overheat_stacks() > 0:
		# A vent showing that takes it back under its maximum is the cheaper way down: it keeps
		# the shield a reboot would drop (the kits that still roll a vent).
		var shown := ms.face()
		var vents := shown.power if shown != null and shown.kind == Face.Kind.VENT else 0
		return blind or vents < ms.overheat_stacks()
	var fc := sk.forecast(ms)
	var pressed := int(fc["incoming"]) > 0
	var kept := maxi(0, ms.unit.shield - int(fc["shield_after"]))   # what its shield would take of this round's blows
	# A foe's jam waits for the reboot (19 November): its entry is dark until the machine
	# reboots, so a quiet round, or a die a third dark, is the moment.
	var waiting := Effects.jams_waiting(ms.unit)
	if waiting > 0 and (blind or not pressed or waiting * 3 >= maxi(1, ms.unit.die.faces.size())):
		return true
	if ms.shield_broken:
		return blind or pressed or (ms.heat * 2 >= ms.heat_max and not rager)
	var f := ms.face()
	var entry_heat := heat_of(ms, f) if f != null and f.kind != Face.Kind.BLANK else 0
	if entry_heat > 0 and ms.heat + entry_heat > ms.heat_max and not rager and not banker:
		return ms.heat > 0 and (blind or kept <= REBOOT_KEEP)   # cold already, a reboot buys the entry no room: it only drops the shield
	return not blind and not pressed and not rager and not banker and ms.unit.shield * 4 <= ms.unit.shield_max and ms.heat * 2 >= ms.heat_max


## A die left unspent as the turn's spending ends is the cheap moment for a reboot:
## a machine that may, has something to get back, and would lose little shield to this round's
## blows, gives the turn it was not using.
func _reboot_idle(sk: Skirmish) -> void:
	if sk.state != Skirmish.State.ASSIGN:
		return
	for i in range(sk.mechs.size()):
		if not sk.can_reboot(i):
			continue
		if _owed.has(i) or _reboots_second(sk, i):   # a reboot it owed and put after a spend it then held, or its second-spend reboot with its die spent and nothing to turn to
			_reboot(sk, i)
			continue
		var ms: Skirmish.MechState = sk.mechs[i]
		if ms.heat <= 0 and ms.unit.shield >= ms.unit.shield_max:
			continue
		if drill_working(sk, ms):
			continue   # a burrow would take its drill home before it has done its work (the Mole's)
		if not Effects.rage_piece(ms.unit).is_empty() and not ms.shield_broken:
			continue   # one that would rage (the Nemesis's) keeps the heat it is climbing toward its Rage
		if kind != BLIND and kind != RANDOM and shot_worth(ms, ms.heat) > 0.0 and piece_worth(sk, i) <= 0.0:
			continue   # one whose heat is its shot (the Whip Scorpion's) fires it only where it is worth more than the heat it banks
		var fc := sk.forecast(ms)
		var kept := maxi(0, ms.unit.shield - int(fc["shield_after"]))
		if kind == BLIND or kind == RANDOM or kept <= REBOOT_KEEP:
			_reboot(sk, i)


## A reboot, the bot's: a plain one, or, on a machine whose reboot fires a piece first (the Whip
## Scorpion's Heliographic Death Ray, Skirmish.reboot_mech), the piece brought up and spent where it
## is worth the most (the blind rung's nearest foe, the random rung's any), the reboot after it. False
## when it could not: a reboot it may not make, or a piece with nothing to fire at (a field of Phased
## foes), stood down again so the die shows what it did.
func _reboot(sk: Skirmish, i: int) -> bool:
	var ms: Skirmish.MechState = sk.mechs[i]
	if Effects.reboot_piece(ms.unit).is_empty():
		if not sk.reboot_mech(i):
			return false
		reboots += 1
		return true
	if not sk.reboot_mech(i):
		return false
	var pick: Dictionary = {}
	if kind == BLIND:
		pick = _blind_pick(sk, i)
	else:
		var opts := options_for(sk, i)
		if not opts.is_empty():
			pick = opts[rng.randi_range(0, opts.size() - 1)] if kind == RANDOM else opts[0]
			if kind != RANDOM:
				for o in opts:
					if o["score"] > pick["score"]:
						pick = o
	var spent := ms.face()
	var charged := sk.charge_lands(ms)
	var marks := {} if pick.is_empty() else _paint_marks(sk, ms, spent, pick.get("target"))
	if pick.is_empty() or not sk.assign(i, pick.get("target"), pick.get("second", null)):
		if ms.ray_from >= 0:
			sk.reboot_mech(i)   # stood down: nothing it may fire at
		return false
	_tally(spent, charged)
	_note_paints(ms, pick.get("target"), marks)
	reboots += 1
	return true


## Where a machine's reboot piece sits on its die (the Whip Scorpion's Death Ray), lit; -1 for none.
static func piece_entry(ms: Skirmish.MechState) -> int:
	return Skirmish.reboot_piece_at(ms)


## What firing a machine's reboot piece is worth now (the Whip Scorpion's Death Ray), in foe hit
## points: the piece's best spend as it would go out, its heat free (the reboot after it vents it),
## less what standing bare through this round costs over standing as it is (bare_cost). -INF for a
## machine with no piece to bring up, or one that may not reboot.
func piece_worth(sk: Skirmish, i: int) -> float:
	var ms: Skirmish.MechState = sk.mechs[i]
	var at := piece_entry(ms)
	if at < 0 or ms.ray_from >= 0 or not sk.can_reboot(i):
		return -INF
	var was := ms.face_index
	ms.face_index = at
	ms.ray_from = was   # read as up: its heat goes with the reboot after it (_vents_after)
	var best := -INF
	for o in options_for(sk, i):
		best = maxf(best, float(o["score"]))
	ms.face_index = was
	ms.ray_from = -1
	if best == -INF:
		return best
	# The shot it fires now is the heat it would otherwise bank for a bigger one (shot_worth): what it
	# held, over the cold start the reboot leaves.
	return best - bare_cost(sk, ms) - (shot_worth(ms, ms.heat) - shot_worth(ms, 0))


## The shot the heat a machine holds banks for its reboot piece (the Whip Scorpion's Death Ray, or the
## form a branch remakes it as: a low base and a point for every `per_heat` of the heat it fires, at
## its heat scale), at SHOT_SHARE, on its target alone; nothing for a machine whose reboot fires no
## heat. The bot's lean, so its heat is fuel it climbs with and holds, never only a gauge to empty.
static func shot_worth(ms: Skirmish.MechState, heat: int) -> float:
	var at := Skirmish.reboot_piece_at(ms)
	if at < 0:
		return 0.0
	var f := Effects.effective_face(ms.unit, ms.die.faces[at])
	if f == null or not f.vents_all or f.power_per_heat <= 0:
		return 0.0
	var h := maxi(0, heat)
	var number := float(f.power + (h / maxi(1, f.per_heat)) * f.power_per_heat)
	return SHOT_SHARE * number * Effects.heat_damage_multiple(ms.unit, h, ms.heat_max) * float(maxi(1, f.strikes))


## What a reboot now costs a machine through this round's blows, in foe hit points: the hull it
## would lose bare and cold (its shield and its heat gone at the drop) over what it loses as it
## stands, the burn of an overheat it would shed and a doubling of hits on a hot gauge (the Whip
## Scorpion's) taken off; a wreck it would make, or save, at DEATH_WEIGHT. Negative where the
## reboot saves hull.
func bare_cost(sk: Skirmish, ms: Skirmish.MechState) -> float:
	var now := sk.forecast(ms)
	var shield := ms.unit.shield
	var heat := ms.heat
	ms.unit.shield = 0
	ms.heat = 0
	var bare := sk.forecast(ms)
	ms.unit.shield = shield
	ms.heat = heat
	var cost := float(int(now["hull_after"]) - int(bare["hull_after"])) * HULL_WEIGHT
	if bare["destroyed"] and not now["destroyed"]:
		cost += DEATH_WEIGHT
	elif now["destroyed"] and not bare["destroyed"]:
		cost -= DEATH_WEIGHT
	return cost


## A damaging die held because its heat would cross the maximum: a forced choice, and the
## damage it would have dealt at its mean (the heat report's, 13 October).
func _note_forced(sk: Skirmish, ms: Skirmish.MechState) -> void:
	var f := ms.face()
	if f == null or not f.is_attack() or f.power <= 0:
		return
	var fc := sk.forecast(ms)
	if int(fc["heat_end"]) + heat_of(ms, f) <= ms.heat_max:
		return
	forced_holds += 1
	forgone += float(Effects.effective_face(ms.unit, f).power * maxi(1, f.strikes))


## A machine's two best spends worth making (a score of nought or more), for the planner's list.
static func _top_two(opts: Array) -> Array:
	var sorted := opts.filter(func(o: Dictionary) -> bool: return float(o["score"]) >= 0.0)
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["score"]) > float(b["score"]))
	return sorted.slice(0, 2)


static func _same_option(a: Dictionary, b: Dictionary) -> bool:
	return int(a["mech"]) == int(b["mech"]) and a.get("target") == b.get("target") and a.get("second") == b.get("second")


## The planner's choice at one decision: the greedy's pick and the best few alternatives, each
## rolled out over PLAN_SAMPLES futures with the same seeds for every candidate, the best worth
## kept, the greedy's pick on a tie.
func _plan(sk: Skirmish, default: Dictionary, alternatives: Array) -> Dictionary:
	var list: Array = [default]
	alternatives.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["score"]) > float(b["score"]))
	for c in alternatives:
		if list.size() >= PLAN_CANDIDATES:
			break
		if not list.any(func(x: Dictionary) -> bool: return _same_option(x, c)):
			list.append(c)
	if list.size() <= 1:
		return default
	plans += 1
	var seeds: Array[int] = []
	for s in range(PLAN_SAMPLES):
		seeds.append(absi(hash([rng.seed, plans, s])) % 2147483647)
	var best := default
	var best_v := -INF
	for c in list:
		var v := 0.0
		for sd in seeds:
			v += rollout(sk, c, sd)
		v /= float(seeds.size())
		if v > best_v + 0.001:
			best_v = v
			best = c
	if not _same_option(best, default):
		plan_changes += 1
	return best


## One candidate spend rolled out over two rounds: a copy of the fight, the spend made, the rest
## of this turn played by the greedy rung, the enemy's turn, the next round (its dice and the
## foes' picks drawn from the copy's own seed, the dice spent as they fall: the greedy's rerolls
## are most of a round's cost, and a future without them is the same for every candidate) and
## its enemy turn, then the fight's worth (state_value). The real fight is never touched.
func rollout(sk: Skirmish, c: Dictionary, seed_value: int) -> float:
	var copy := SaveGame.clone_skirmish(sk)
	copy.rng.seed = seed_value
	var g := Policy.make(GREEDY, seed_value)
	g.cool_above = cool_above   # the persona's habit plays the future out too
	g.shield_ahead = shield_ahead
	g.guard_weight = guard_weight
	if not copy.assign(int(c["mech"]), _mirror(copy, sk, c.get("target")), _mirror(copy, sk, c.get("second"))):
		return -INF
	g.play_round(copy, false)
	if copy.outcome == Skirmish.Outcome.NONE:
		copy.end_round()
	if copy.outcome == Skirmish.Outcome.NONE:
		copy.start_round()
		g.play_round(copy, false)
		if copy.outcome == Skirmish.Outcome.NONE:
			copy.end_round()
	return state_value(copy)


## A target in the real fight, as the copy has it: the foe in the same slot, the machine in the
## same place, a slot as it is.
static func _mirror(copy: Skirmish, sk: Skirmish, t):
	if t == null or t is Vector2i:
		return t
	if t is Foe:
		var key := Vector2i(t.rank, t.column)
		if sk.twins.get(key, null) == t:
			return copy.twins.get(key, null)   # a twin slot's right-hand half (the Gel's pair)
		return copy.foe_at(t.rank, t.column)
	if t is Skirmish.MechState:
		var i := sk.mechs.find(t)
		return copy.mechs[i] if i >= 0 and i < copy.mechs.size() else null
	return t


## A fight's worth to the team at the planner's horizon, in foe hit points as the greedy rung
## weighs them: every machine standing (DEATH_WEIGHT) with its hull at HULL_WEIGHT and its
## shield at SHIELD_LOSS_WEIGHT, less every foe left on the field or waiting (its hit points
## less what its Ablating and Vitriol will still tick, a slot's worth, and its next blow at the
## hull's weight).
static func state_value(sk: Skirmish) -> float:
	var v := 0.0
	for ms in sk.mechs:
		if ms.alive():
			v += DEATH_WEIGHT + HULL_WEIGHT * float(maxi(0, ms.unit.hull)) + SHIELD_LOSS_WEIGHT * float(maxi(0, ms.unit.shield))
	var foes: Array = sk.field_foes()
	for f in sk.reinforcements:
		if not foes.has(f):
			foes.append(f)
	for f in foes:
		if not f.alive():
			continue
		var ticks := dot_payout("ablating", Effects.stacks_of(f, "ablating"), f.hp) * ABLATE_WEIGHT \
			+ dot_payout("vitriol", Effects.stacks_of(f, "vitriol"), f.hp) * VITRIOL_WEIGHT
		v -= float(f.hp) - ticks + KILL_BONUS + _threat_next(f, sk) * HULL_WEIGHT
	return v


## The blind rung's turn: left to right, each die spent as _blind_pick says, a Rapid entry's
## fresh roll read from the left again, a die held only where _blind_pick finds nothing.
func _blind_round(sk: Skirmish) -> void:
	var held: Array[int] = []
	var guard := 0
	while sk.state == Skirmish.State.ASSIGN and guard < OPTION_GUARD:
		guard += 1
		var spent_one := false
		for i in range(sk.mechs.size()):
			var ms: Skirmish.MechState = sk.mechs[i]
			if not ms.alive() or ms.assigned or held.has(i):
				continue
			if _reboots_second(sk, i):   # its second spend the reboot (the Needletail's), as the greedy's loop
				_reboot(sk, i)
				spent_one = true
				break
			var pick := _blind_pick(sk, i)
			var face := ms.face()
			var charged := sk.charge_lands(ms)
			var marks := {} if pick.is_empty() else _paint_marks(sk, ms, face, pick.get("target"))
			if pick.is_empty() or not sk.assign(i, pick.get("target"), pick.get("second")):
				held.append(i)
				continue
			_tally(face, charged)
			_note_paints(ms, pick.get("target"), marks)
			spent_one = true
			break
		if not spent_one:
			break


## Where blind play spends a die: a weapon or a debuff on the nearest foe in reach (the front rank before the
## back, left before right), a swap's second on the first it may take; a shield, a vent or a buff
## on its own machine where it may land there, else the first ally; a blank discarded. Nothing
## where its heat would cross the maximum or its bite wreck the machine, the gauge being
## in view.
func _blind_pick(sk: Skirmish, i: int) -> Dictionary:
	var ms: Skirmish.MechState = sk.mechs[i]
	if ms.face() == null:
		return {}
	var f := sk.spend_face(ms)
	match f.kind:
		Face.Kind.BLANK:
			return {"target": null}
		Face.Kind.ATTACK:
			if heat_cost(sk, ms, f) > 0.0 or volatile_cost(sk, ms, f) >= DEATH_WEIGHT:
				return {}
			var foes: Array = sk.targets_for_face(ms, f)
			if foes.is_empty():
				return {}
			var t: Foe = foes[0]
			for n in foes:
				if n.rank < t.rank or (n.rank == t.rank and n.column < t.column):
					t = n
			if sk.needs_second(ms):
				var seconds: Array = sk.swap_targets(t, sk.swap_carries(ms))
				return {} if seconds.is_empty() else {"target": t, "second": seconds[0]}
			return {"target": t}
		_:
			var who: Array = sk.machine_targets_for(ms, f)
			if who.is_empty():
				return {}
			return {"target": ms if who.has(ms) else who[0]}
	return {}


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
				for second in sk.swap_targets(t, sk.swap_carries(ms)):
					var stays: bool = t.is_massive() or (second is Foe and (second as Foe).is_massive())   # nothing moves: the rider alone
					var v := 0.0 if stays else swap_score(sk, t, second) + bunching_score(sk, ms, t, second)
					if v > best:
						best = v
						best_second = second
				if best_second != null:
					out.append({"mech": i, "target": t, "second": best_second, "score": score + best})
		Face.Kind.SHIELD, Face.Kind.VENT, Face.Kind.BUFF:
			for who in sk.machine_targets_for(ms, f):
				out.append({"mech": i, "target": who, "score": machine_spend_score(sk, ms, who, f)})
	return out


# ---------------------------------------------------------------- scoring

## An attack on a foe, in foe hit points: what lands (capped at what the target, any
## neighbours and a Chain's Shocked conductors have left), the kill it makes as often as the
## roll makes it, the Ablating it leaves and a Chain's charge, less the hull the heat will burn and
## the shield the splash will cost. Suppress counts the blow it stops.
func attack_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe) -> float:
	var quick := second_action(sk, ms, f)   # its machine's second action this round (the Needletail's)
	var real := f
	f = Effects.effective_face(ms.unit, f, target)
	var field := f.reach == Face.Reach.EVERY_FOE   # it targets the field: no foe takes an aimed strike (24 November)
	var outcomes := damage_outcomes(ms, f, target, Skirmish.AREA_ALL if field else -1)
	var mean := _mean(outcomes)
	var p_kill := _kill_odds(outcomes, target.hp)
	var score := _capped(outcomes, target.hp)
	# Every other foe the strike's own footprint reaches (a Spread's neighbours, a Penetrate's
	# column, a reach over every foe): its shape's number through the firer's modifiers and its own
	# reads, statuses (a Shock never, no strike being aimed at it: 29 October) and armour, capped at
	# what it has left (area by shape, numbered).
	var shapes := sk.area_shapes(f, target)
	for n in sk.ridden_by(f, target):
		if n != target and n.alive():
			score += _capped(damage_outcomes(ms, f, n, int(shapes.get(n, Skirmish.AREA_ALL))), n.hp)
	score += arcs_worth(sk, ms, f, target, mean)
	# The rifle's blow on the foe to the right with every strike (the Macaque's offhand, 19
	# November), a blow of its own beside an area's, through the same order.
	if f.reach != Face.Reach.EVERY_FOE and Effects.side_strike(ms.unit, f, target) > 0:
		var right := sk.right_of(target)
		if right != null and right.alive():
			score += _capped(damage_outcomes(ms, f, right, Skirmish.AREA_SIDE), right.hp)
	# A kill ends the countdown it gathers, opens the core its fall unguards, and sets off its
	# last act (the boss mechanics of 15 October; valued 22 October), of which only what a
	# round's wait could save argues against the kill (last_act_deterrent, 18 November).
	score += p_kill * (KILL_BONUS + (_threat_now(target, sk) + countdown_threat(target, sk)) * HULL_WEIGHT + core_opening(sk, target) - last_act_deterrent(sk, target, ms))
	if f.has(Face.Keyword.LURE) or f.has(Face.Keyword.DISRUPT) or f.has(Face.Keyword.SHOCK):
		# Every foe the riders reach: the target, the neighbours of a spread, the column of a
		# penetrate, never a Chain's conductor (an arc is its blow alone, 18 November); a lure, a
		# disrupt or a shock lands on a felled foe too (death is the last check, 3 November) but is
		# worth something only on the ones that survive the blow.
		var hit: Array = sk.ridden_by(f, target).filter(func(n: Foe) -> bool: return n == target or n.alive())
		if f.has(Face.Keyword.DISRUPT):
			for foe in hit:
				score += ((1.0 - p_kill) if foe == target else 1.0) * disrupt_score(sk, foe)
		if f.has(Face.Keyword.LURE):
			score += (1.0 - p_kill) * lure_score(sk, ms, hit)
			score += (1.0 - p_kill) * lured_needles(sk, ms, f, hit)   # the blows it turns onto a machine that needles its strikers
		if f.has(Face.Keyword.SHOCK):
			# Each foe left standing takes the team's next strike aimed at it double: the blow
			# shock_cash reads, capped at what the foe will have left. A charge already on a foe
			# this blow does not spend is worth nothing more.
			for foe in hit:
				if Effects.has(foe, "shocked") and f.is_debuff():
					continue
				if Effects.turns_mark(foe, "shocked"):
					continue   # its Ward turns the Shock away (28 October)
				var left := maxf(0.0, float(foe.hp) - mean)
				score += ((1.0 - p_kill) if foe == target else 1.0) * minf(left, shock_cash(sk, ms, foe))
	if f.spills and target.rank == 0 and not target.is_massive():
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
	var suppress_open := f.has(Face.Keyword.SUPPRESS) and Effects.gate_holds(ms.unit, f, Face.Keyword.SUPPRESS, target) and not target.immune_to("suppress")
	if suppress_open:
		# A stun on a Numbed foe strips a stack and lands nothing (2 November), so each is a step
		# toward the one that lands: worth the stopped blow over the stuns still needed. A gated
		# Suppress (the Battery's on Brittle) is worth nothing where its gate is shut.
		var lands := 1.0 / float(Effects.stacks_of(target, "numbed") + 1)
		score += (1.0 - p_kill) * suppress_worth(sk, target) * HULL_WEIGHT * maxf(0.0, lands)
	if not f.consumes.is_empty():
		# A consumer gives up the ticks the stacks it eats would have dealt (the Backdraft
		# Charge's Ablating), at the odds the foe would have lived to take them: every foe it
		# strikes eats its own (the blow's order, 28 October).
		for foe in sk.reached_by(f, target):
			var eaten := Effects.stacks_of(foe, f.consumes)
			if eaten > 0 and foe.alive():
				var lives := (1.0 - p_kill) if foe == target else 1.0
				score -= lives * dot_payout(f.consumes, eaten, int(maxf(0.0, float(foe.hp) - (mean if foe == target else 0.0)))) * ABLATE_WEIGHT
	if f.webs:
		# A delayed stun (the funnel-web's web, 18 October): the blows its burst will stop.
		score += (1.0 - p_kill) * web_score(sk, target)
	# A burrower's drill (the Mole's Inertia Drill): its turns in the foe (drill_worth). A use on a
	# foe a drill is in gives that drill's machine a Momentum, a share of a turn more in it.
	if real.component != "" and real.component == str(Effects.burrow_rule(ms.unit).get("piece", "")):
		score += drill_worth(sk, ms, real, target)
	elif sk.driller_of(target) != null:
		score += DRILL_FOCUS
	if f.has(Face.Keyword.DISPEL):
		# Purge (28 October): what every foe the entry reaches carries but Numbed and Guarded,
		# the target's at the odds it outlives the blow, its Undying whatever.
		for foe in sk.ridden_by(f, target):
			if foe == target or foe.alive():
				score += purge_worth(sk, ms, f, foe, (1.0 - p_kill) if foe == target else 1.0)
	# Sap (the Baboon's Redshift Emitter, 11 November): each foe reached that is to strike this round
	# strikes a point lower a stack, never below nothing.
	if f.has(Face.Keyword.SAP):
		for foe in sk.ridden_by(f, target):
			if foe.alive() and foe.attacks() and not foe.is_suppressed():
				score += float(mini(sk.foe_blow(foe), f.sap) * foe.strikes()) * HULL_WEIGHT
	# Brittle (21 October): a point a stack on every team blow each foe reached takes while the
	# stacks last on their clock, damage in hand for the team's blows (brittle_score).
	if f.has(Face.Keyword.BRITTLE):
		for foe in sk.ridden_by(f, target):
			if not foe.alive():
				continue
			var survives_brittle := (1.0 - p_kill) if foe == target else 1.0
			score += survives_brittle * brittle_score(sk, ms, f, foe, maxf(0.0, float(foe.hp) - mean), foe == target)
	# What this machine's passives lay on each foe the blow reaches, judged alone (the
	# funnel-web's Ambush, 18 October): a stack per strike, worth its ticks over the actions to
	# come on the hull the blow leaves, at the odds the foe outlives the blow. A lay that asks for
	# a weapon's hit (the Ambush's) gets nothing from equipment.
	var laid_apps := 0
	var needled := str(Effects.needle_rule(ms.unit).get("status", ""))
	var hot_after := ms.heat + heat_of(ms, f) > ms.heat_max   # the spend takes it past its maximum (a lay that reads Overheated)
	for foe in sk.ridden_by(f, target):
		if not foe.alive():
			continue
		var lays := Effects.laid_statuses(ms.unit, f, foe)
		if lays.is_empty():
			continue
		var left := int(maxf(0.0, float(foe.hp) - mean))
		var survives := (1.0 - p_kill) if foe == target else 1.0
		for pair in lays:
			if bool(pair[2]) and f.is_debuff():
				continue
			if Effects.turns_mark(foe, str(pair[0])):
				continue   # its Ward turns the lay away (28 October)
			# A lay past the maximum lays its own stacks where the spend takes it there (the
			# Incinerator's 3 Ablate), and a lay once a spend lays once on each foe, whatever the strikes.
			var n := int(pair[1])
			if (pair as Array).size() > 3 and int(pair[3]) > 0 and hot_after:
				n = int(pair[3])
			var times := 1 if (pair as Array).size() > 4 and bool(pair[4]) else maxi(1, f.strikes)
			if str(pair[0]) == needled:
				score += survives * needle_worth(sk, ms, foe, n * times, left)   # the Echidna's needles: the bolt they bring
			else:
				score += survives * dot_payout(str(pair[0]), n * times, left) * VITRIOL_WEIGHT
			if foe == target:
				laid_apps += 1
	# The statuses this blow applies feed any machine's Paradox meter (the Baboon's Pocket
	# Paradox, a meter since 10 October): the share of a knock-out they move on this foe.
	var apps := int(f.has(Face.Keyword.ABLATE)) + int(f.has(Face.Keyword.SHOCK)) + int(suppress_open) + int(f.webs) + int(f.has(Face.Keyword.BRITTLE)) + laid_apps
	if apps > 0:
		score += _paradox_share(sk, target, apps) * (1.0 - p_kill) * _threat_now(target, sk) * HULL_WEIGHT
	if f.has(Face.Keyword.ABLATE) and not Effects.turns_mark(target, "ablating"):
		# Ablate N leaves N stacks that tick N, N-1, ... 1 over the actions to come (Ryan, 18
		# October: a numbered keyword, a damage point a stack); the tick is read from the status.
		# Every strike lays its stacks, so a split or multi-strike gun's add up first.
		var per := float(Effects.STATUS["ablating"]["effects"][0]["value"])
		var laid_ablate := f.ablate * maxi(1, f.strikes)
		score += (1.0 - p_kill) * per * float(laid_ablate * (laid_ablate + 1)) / 2.0 * ABLATE_WEIGHT
	# Cryo (20 October): a weapon's hit cashes the foe's stacks for cooling, worth what a vent
	# of that much would be on the hitter.
	if not f.is_debuff() and Effects.has(target, "cryoed"):
		score += vent_score(sk, ms, Effects.stacks_of(target, "cryoed") * Skirmish.cryo_cool())
	score += hopper_score(sk, ms, f, target)
	if f.braces > 0:
		score += brace_score(sk, ms, f.braces)
	if f.has(Face.Keyword.EXPOSE):
		score += (1.0 - p_kill) * expose_score(sk, target)
	if f.is_weapon() and p_kill > 0.0 and Effects.refills_on_kill(ms.unit) and ms.unit.shield < ms.unit.shield_max:
		# A kill that recharges its shield whole (the Kite's, 11 November): what the shield it
		# would regain turns of the blows coming, at the odds of the kill.
		score += p_kill * shield_score(sk, ms, ms.unit.shield_max - ms.unit.shield, ms)
	if quick:
		# The Needletail's two things a round: its first spend turns the die to the other kind
		# and the machine acts again, about the die's own average blow.
		score += ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms)
	score += rapid_worth(ms, f, quick)   # a plain Rapid entry's action again (4 November)
	# The Forge (the Musk Ox's): the gun's price in ammo, at what an ammo buys; the cluster
	# cannon's refund, an ammo for every foe its blows reach, as far as the magazine has room.
	var price := sk.ammo_price_of(ms, f)
	if price > 0:
		var worth := ammo_worth(sk, ms)
		# A piece that empties the magazine (the Musk Ox's salvo) is charged its reserve alone (3
		# November): the ammo the dearest other gun needs for its next spend, since the forge's
		# trickle refills the rest before the die comes back to them; priced whole the bot
		# rerolled a full magazine away.
		score -= float(mini(price, magazine_reserve(ms)) if f.spends_magazine else price) * worth
		if f.ammo_per_foe_hit > 0:
			var back := f.ammo_per_foe_hit * sk.reached_by(f, target).filter(func(n: Foe) -> bool: return n.alive()).size()
			score += float(mini(back, ms.ammo_max - ms.ammo + price)) * worth
	# The Mines (the Lammergeier's Reverberant Payload, 9 November): the spend's own, a mined foe's
	# blast on its kill, the gather and the detonation (mine_worth).
	score += mine_worth(sk, ms, f, target, p_kill)
	# What the machine's passives grant it for a kill of its own (the Ammit's flare, a stack of
	# Empowered for every five Essence it holds; as the round ends since 16 November, once a round
	# however many attacks kill, so a machine that has killed this round has its flare coming
	# already): each stack on the blows its die deals in its next turn, a strike a point
	# (flare_gain), at the odds of the kill.
	var flare := Effects.would_stack(ms.unit, "on_round_kill", "overcharged") if f.is_weapon() and not ms.killed_round else 0
	if flare > 0:
		score += p_kill * flare_gain(ms, "overcharged", flare) * FLARE_ROUNDS
	if f.kill_rerolls > 0:
		# The Spindrift Salvo's kill rider (30 October): the team's rerolls it brings mid-round, at
		# the odds of the kill, worth what the bank carries of them (bank_delta).
		score += p_kill * bank_delta(sk, f.kill_rerolls)
	# What the spend lays on its own machine (the Storm Petrel's lure and its branches, 17
	# November), and the shield its heat stands up (the Hardlight Generator's hook): each worth
	# what it keeps of this round's blows (self_grant_worth, heat_shield_gain), the grant read on the
	# entry as its machine's branches make it.
	score += self_grant_worth(sk, ms, f, target)
	score += shield_gain_worth(sk, ms, heat_shield_gain(ms, real))
	score -= heat_cost(sk, ms, f) + self_ablate_cost(sk, ms, f) + shield_spend_cost(sk, ms, f)
	if not f.is_weapon():
		score -= rage_cost(sk)   # a debuff is equipment, and feeds a raging foe (3 November)
	# The Juggernaut Drive (the Wild Boar's, 11 November): a damaging blow on a front-rank foe drives
	# a share of its maximum HP into the foe behind it, capped at what that foe has left; the
	# target's alone, a placeholder read as every weight is.
	var pct := Effects.shove_share(ms.unit)
	if pct > 0 and f.is_weapon() and target.rank == 0 and not target.is_massive():
		var back := sk.foe_at(1, target.column)
		if back != null and back.alive() and expected_damage(ms, f, target) > 0.0:
			score += minf(float(back.hp), float(ceili(float(target.hp_max) * float(pct) / 100.0)))
	return score - volatile_cost(sk, ms, f) - cooldown_cost(ms, f, score)



## What a spend's own shield costs its machine (the Buzzard's, 18 November): a zap's cost where its
## shield pays one, the whole shield for a gun that fires it (the Shield-burner Cannon), read as
## burn_cost reads shield gone this turn. A placeholder, as every weight: the regrowth a break shuts
## off until the reboot (its carrion) is not counted.
## Whether a burrower's drill is still at work in a foe standing (the Mole's): its drill's form of
## its own on a live foe, which its next burrow would take home.
static func drill_working(sk: Skirmish, ms: Skirmish.MechState) -> bool:
	if not Effects.burrows(ms.unit) or not Effects.has(ms.unit, "drill_out"):
		return false
	var source := Skirmish.drill_source(ms)
	for f in sk.field_foes():
		if not f.alive():
			continue
		for m in f.modifiers:
			if Effects.DRILL_STATUSES.has(m.id) and m.source == source:
				return true
	return false


## The Inertia Drill's mark at a foe (the Mole's; a first cut, 24 November), over its hit, which the
## pipeline scores: the turns its machine's Momentum keeps it in (its drain a turn, a turn at least),
## each a blow through the foe's armour that the Brittle held so far adds to, capped at what the foe
## has left, the Brittle it holds read as a blow more of the squad's a turn, and the Ablate its form
## lays at the payout the bot reads any Ablate at. Under, short of its cap with its shield or heat
## not yet made good, it is worth waiting a turn: the drill is held (a score below nothing). A Ward
## turns it away unless the piece ignores Ward.
func drill_worth(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe) -> float:
	var have := Effects.stacks_of(ms.unit, "momentum")
	var tick := Effects.momentum_of(ms.unit, f)
	if Effects.turns_mark(target, str(tick["status"])) and not f.ignores_ward:
		return 0.0
	if have < Effects.store_cap(ms.unit, "momentum") and (ms.unit.shield < ms.unit.shield_max or ms.heat > 0):
		return -1.0
	var ticks := maxi(1, ceili(float(have) / float(maxi(1, int(tick["drain"])))))
	var lays: Dictionary = tick["lays"]
	var brittle_per := int(lays.get("brittled", 0))
	var blow := int(tick["blow"])
	var left := float(target.hp)
	var worth := 0.0
	for k in range(ticks):
		var brittle := brittle_per * (k + 1)   # the Pinned it lays holds what each turn lays
		if blow > 0:
			var d := minf(left, float(maxi(0, blow + brittle - target.armour_total())))
			worth += d
			left -= d
		worth += float(brittle) * DRILL_BRITTLE
	if int(lays.get("ablating", 0)) > 0 and left > 0.0:
		worth += float(ticks) * dot_payout("ablating", int(lays["ablating"]), int(left)) * ABLATE_WEIGHT
	return worth


## A Chain spend's ping (Ryan, 24 November: "Resolve: All Sprites with Shock, Static, or Sonic
## Needle lose {N} HP"): the number flat, once a use, on every conductor the ping will reach
## (Skirmish.conductors: its own target among them while it still conducts after the strike), no
## armour, Brittle or Barrier read; a Phased foe loses none; capped at what each foe keeps (the
## target's after the strike's mean).
func arcs_worth(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe, mean: float) -> float:
	var n := f.number_of(Face.Keyword.CHAIN)
	var worth := 0.0
	for c in sk.conductors(f, target):
		if not c.alive() or Skirmish.foe_phased(c):
			continue
		var left := maxf(0.0, float(c.hp) - (mean if c == target else 0.0))
		worth += minf(left, float(n))
	return worth


## How many bolts `n` more needles fire on a foe holding `have` (Skirmish._lay_needles: a stack at a
## time, the bolt at the rule's `at`, then the stacks down to the rule's `keeps`, none by default),
## and the stacks it holds after: [bolts, stacks].
static func needle_bolts(have: int, n: int, at: int, keeps: int) -> Array:
	var bolts := 0
	var held := have
	for i in range(maxi(0, n)):
		held += 1
		if held >= at:
			bolts += 1
			held = clampi(keeps, 0, held)
	return [bolts, held]


## What laying `n` of this machine's needles on a foe is worth (the Echidna's Sonic Needles; a first
## cut, 20 November): every bolt they fire (bolt_worth), and what they leave short of the next, its
## share of a bolt at NEEDLE_PROGRESS; with the Spiker's sap, the points the foe's attacks lose this
## round. `left` is the HP the foe keeps after the blow that lays them, `already` the needles the
## same spend lays on it first (a lured foe's own spend). A Ward turns them away.
func needle_worth(sk: Skirmish, ms: Skirmish.MechState, foe: Foe, n: int, left: int, already: int = 0) -> float:
	var rule := Effects.needle_rule(ms.unit)
	if rule.is_empty() or n <= 0:
		return 0.0
	var sid := str(rule["status"])
	if Effects.turns_mark(foe, sid):
		return 0.0
	var at := int(rule["at"])
	var keeps := int(rule.get("keeps", 0))
	var start: int = needle_bolts(Effects.stacks_of(foe, sid), already, at, keeps)[1]
	var after := needle_bolts(start, n, at, keeps)
	var bolt := bolt_worth(sk, ms, rule, foe, left)
	var worth := float(int(after[0])) * bolt
	var short := int(after[1]) - (start if int(after[0]) == 0 else 0)
	worth += maxf(0.0, float(short)) / float(at) * bolt * NEEDLE_PROGRESS
	var sap := int(rule.get("sap", 0))
	if sap > 0 and left > 0 and foe.attacks() and not foe.is_suppressed():
		worth += float(mini(sk.foe_blow(foe), sap * n) * foe.strikes()) * HULL_WEIGHT
	return worth


## A needle bolt's worth now (Skirmish._needle_bolt): Chain's ping of its number on every conductor,
## the foe it fires from among them with the HP it keeps (`left`), flat and capped at what it has, a
## kill at its bonus; a Phased foe loses none.
func bolt_worth(sk: Skirmish, ms: Skirmish.MechState, rule: Dictionary, from: Foe, left: int) -> float:
	var chain := int(rule.get("chain", 0))
	var foes := sk.conducting_foes(from)
	if left > 0 and not Skirmish.out_of_reach(from):
		foes.append(from)
	var worth := 0.0
	for c in foes:
		if Skirmish.foe_phased(c):
			continue
		var hp := left if c == from else c.hp
		var blow := chain
		worth += float(mini(blow, hp))
		if blow >= hp:
			worth += KILL_BONUS + _threat_now(c, sk) * HULL_WEIGHT
	return worth


## What a lure's turned blows lay on their strikers (on_struck: the Echidna's needles, Ryan, 20
## November: the Tether "theoretically ... should result in 2 stacks on that foe"): every foe it
## turns onto this machine strikes it this round, a needle a blow, after the needles the spend lays
## on it.
func lured_needles(sk: Skirmish, ms: Skirmish.MechState, f: Face, foes: Array) -> float:
	var rule := Effects.needle_rule(ms.unit)
	if rule.is_empty():
		return 0.0
	var sid := str(rule["status"])
	var per := 0
	for pair in Effects.struck_lays(ms.unit):
		if str(pair[0]) == sid:
			per += int(pair[1])
	if per <= 0:
		return 0.0
	var worth := 0.0
	for foe in foes:
		if not foe.alive() or not foe.aims_at_one() or foe.target == ms or not foe.attacks() or foe.is_suppressed():
			continue
		var own := 0
		for pair in Effects.laid_statuses(ms.unit, f, foe):
			if str(pair[0]) == sid:
				own += int(pair[1]) * maxi(1, f.strikes)
		worth += needle_worth(sk, ms, foe, per * foe.strikes(), foe.hp, own)
	return worth


func shield_spend_cost(sk: Skirmish, ms: Skirmish.MechState, f: Face) -> float:
	if f == null or ms.shield_broken:
		return 0.0
	if f.spends_shield:
		return burn_cost(sk, ms, maxi(0, ms.unit.shield))
	if Skirmish.zap_ready(ms, f) > 0:
		return burn_cost(sk, ms, int(Effects.zap_of(ms.unit, f)["cost"]))
	return 0.0


## What a piece that ablates its own firer costs it (the Stoker's, Ablate since 15 November): its
## first tick lands as this turn ends, before the foes strike, so it is shield gone this round
## (burn_cost's read), and the ticks after it a point each at what a later point is worth.
func self_ablate_cost(sk: Skirmish, ms: Skirmish.MechState, f: Face) -> float:
	if f == null or f.self_ablate <= 0:
		return 0.0
	var per := Effects.status_value("ablating_mech", "tick_hp")
	var k := f.self_ablate
	return burn_cost(sk, ms, per * k) + float(per * k * (k - 1)) / 2.0 * ABLATED_WEIGHT


## What losing shield this turn costs a machine (a self-Ablate's first tick; the Storm Petrel's burn
## until 17 November): the hull the enemy's blows would take through the gap this round, a death it
## opens, and the shield that would have stood afterwards, at shield_score's weights.
func burn_cost(sk: Skirmish, ms: Skirmish.MechState, burnt: int) -> float:
	var before := sk.forecast(ms)
	var after := sk.forecast(ms, -burnt)
	var lost := maxf(0.0, float(before["hull_after"])) - maxf(0.0, float(after["hull_after"]))
	var cost := lost * HULL_WEIGHT + float(mini(burnt, int(before["shield_after"]))) * BANK_WEIGHT
	if after["destroyed"] and not before["destroyed"]:
		cost += DEATH_WEIGHT
	return cost


## What shield stood up this turn is worth (the Storm Petrel's hook and its Hardened Light, 17 November):
## the hull it keeps from this round's blows, a death it averts, and what stands past them banked,
## burn_cost read the other way.
func shield_gain_worth(sk: Skirmish, ms: Skirmish.MechState, gain: int) -> float:
	if gain <= 0:
		return 0.0
	var before := sk.forecast(ms)
	var after := sk.forecast(ms, gain)
	var kept := maxf(0.0, float(after["hull_after"])) - maxf(0.0, float(before["hull_after"]))
	var worth := kept * HULL_WEIGHT + float(maxi(0, int(after["shield_after"]) - int(before["shield_after"]))) * BANK_WEIGHT
	if before["destroyed"] and not after["destroyed"]:
		worth += DEATH_WEIGHT
	return worth


## The shield a spend's heat stands up (the Storm Petrel's Hardlight Generator, 17 November: a point
## of shield for every point of heat it gains): on a shield that stands, up to its maximum.
static func heat_shield_gain(ms: Skirmish.MechState, f: Face) -> int:
	var per := Effects.shield_per_heat(ms.unit)
	if per <= 0 or f == null or ms.shield_broken or ms.unit.shield <= 0:
		return 0
	return mini(per * maxi(0, heat_of(ms, f)), maxi(0, ms.unit.shield_max - ms.unit.shield))


## What a spend lays on its own machine is worth (the entry's self_statuses as its machine's
## branches make it: the Hardlight Pulse's Hardened Light, a Ward, Charged; Ryan, 18 November):
## Hardened Light a point off every blow it meets while its shield stands, read as that much
## shield stood up against the foes aiming at it once the spend has turned the ones it reaches,
## over the rounds a stack is read to stand until the shield breaks (HARDENED_ROUNDS), nothing past
## its cap; a Ward as a Ward piece is (ward_score); Charged a Shock on each of its next fires, its
## own blow again as a Charged buff is worth. Placeholders, as every weight.
func self_grant_worth(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe) -> float:
	if f == null or f.self_statuses.is_empty() or target == null:
		return 0.0
	var reached := sk.reached_by(f, target)
	var lured := sk.ridden_by(f, target) if f.has(Face.Keyword.LURE) else []   # a Chain's arc lures nothing (18 November)
	var worth := 0.0
	for g in f.self_statuses:
		var id := str(g.get("status", ""))
		var n := maxi(1, int(g.get("stacks", 1))) * (reached.size() if bool(g.get("per_foe", false)) else 1)
		if int(g.get("cap", 0)) > 0:
			n = mini(n, maxi(0, int(g["cap"]) - Effects.stacks_of(ms.unit, id)))
		if n <= 0:
			continue
		match id:
			"hardened":
				var blows := 0
				for foe in sk.field_foes():
					if foe.alive() and foe.attacks() and not foe.is_suppressed() and (foe.target == ms or lured.has(foe)):
						blows += maxi(1, foe.strikes())
				if ms.unit.shield > 0 and not ms.shield_broken:
					worth += shield_gain_worth(sk, ms, mini(blows * n, ms.unit.shield_max)) * HARDENED_ROUNDS
			"ward":
				if not Effects.has(ms.unit, "ward"):
					worth += ward_score(sk, ms)
			"charged":
				worth += float(n) * _raw_attack_mean(ms)
			"parry":
				if not Effects.has(ms.unit, "parry"):
					worth += parry_worth(sk, ms)
			_:
				# Any other machine status (the Macaque's offhand: Armoured, a Barrier, Empowered), at
				# the price a buff granting it on this machine carries.
				worth += buff_score(sk, ms, Face.buff(id, n))
	return worth


## What a Parry is worth (the Beam Buckler's, Ryan, 19 November): half, rounded down, of what its
## Barrier and its armour would keep off this round's blows aimed at it, the Barrier taking the
## first whole, on its next strike alone. Placeholders, as every weight.
func parry_worth(sk: Skirmish, ms: Skirmish.MechState) -> float:
	var kept := 0
	var barred := false
	for foe in sk.field_foes():
		if not foe.alive() or not foe.attacks() or foe.is_suppressed() or foe.target != ms:
			continue
		for s in range(maxi(1, foe.strikes())):
			var blow := sk.foe_blow(foe)
			if not barred:
				barred = true
				kept += blow
			elif ms.unit.shield <= 0:
				kept += mini(blow, ms.unit.armour)
	return float(int(kept / 2.0))


## A team reroll's worth, the one yardstick for a reroll gained (equipment's, a kill's), paid (an
## ally's action bought) or banked: a share of the team's average blow.
static func reroll_value(sk: Skirmish) -> float:
	return REROLL_SHARE * _team_raw_attack_mean(sk)


## What `n` rerolls more (or fewer) mid-round are worth: the bot rerolls only as the round opens,
## so a reroll a spend brings or pays after that is worth only what the bank carries into the
## next round (Maverick's Playbook), each at a reroll's worth; nothing past the bank's cap, and
## nothing on a team that banks none.
static func bank_delta(sk: Skirmish, n: int) -> float:
	var cap := sk.bank_cap()
	var left := sk.rerolls_left
	return float(absi(mini(cap, maxi(0, left + n)) - mini(cap, left))) * reroll_value(sk)


## What an action bought for a machine is worth (the Immelmann Booster's, 30 October): its die
## rolled again and spent again, about its own average blow, as the Horn's charged form is read.
static func action_value(who: Skirmish.MechState) -> float:
	return ROLL_AGAIN_WEIGHT * _raw_attack_mean(who)


## The best action an entry that buys one (the Booster's ally use) may still buy this round for an
## ally yet to spend, less its price as the bank reads it (bank_delta): what spending it now on
## anything else gives up, and what it holds out for. Nothing while the team cannot pay.
func action_ahead(sk: Skirmish, ms: Skirmish.MechState, f: Face) -> float:
	if f == null or f.action_price <= 0 or sk.rerolls_left < f.action_price:
		return 0.0
	var best := 0.0
	var price := bank_delta(sk, -f.action_price)
	for who in sk.live_mechs():
		if who != ms and not who.assigned and not Skirmish.is_phased(who):
			best = maxf(best, action_value(who) - price)
	return best


## What rolling an unspent machine's die again in place is worth (the Reheat Uplink's roll): its
## die's average blow, read plainly, less the blow the entry showing would land; the roll never
## lands on the entry showing. Nothing on a spent die, which rolls nothing.
static func roll_gain(who: Skirmish.MechState) -> float:
	if who.assigned or who.face() == null:
		return 0.0
	var shown := who.face()
	var now := float(shown.power * maxi(1, shown.strikes)) if shown.is_weapon() else 0.0
	return _raw_attack_mean(who) - now


## What the player's Purge takes off one foe (28 October; placeholders), by what it carries:
## Undying the foe's maximum HP, whatever the blow does, since a foe it kills stays down;
## the rest at the odds the foe outlives the blow (`lives`): a Barrier the biggest weapon blow an
## ally still to act shows on it (nothing when the spend's own weapon pops it first), Armoured
## its stacks for each allied blow still to land on it this round, Empowered its value, Primed 2 a
## stack, Regenerating what the stacks it takes would have regrown, a Ward nothing.
func purge_worth(sk: Skirmish, ms: Skirmish.MechState, f: Face, foe: Foe, lives: float) -> float:
	if foe == null or Effects.has(foe, "ward"):
		return 0.0   # a Ward turns a Purge away and stands (2 November)
	var n := maxi(1, f.dispel)   # Purge N (2 November): each buff loses N stacks, so its worth is capped there
	var allied_blows := 0
	for other in sk.live_mechs():
		if other == ms or other.assigned:
			continue
		var of := sk.spend_face(other)
		if of != null and of.is_weapon() and sk.targets_for_face(other, of).has(foe):
			allied_blows += maxi(1, of.strikes)
	var back := 0.0
	var rest := 0.0
	var seen := {}
	for m in Effects.live(foe):
		var stacks: int = mini(n, Effects.stacks_of(foe, m.id))
		if seen.has(m.id):
			continue   # a status's grants priced once, at the stacks the Purge reaches
		seen[m.id] = true
		match m.id:
			"risen":
				back = float(foe.hp_max)
			"barrier":
				if not f.is_weapon():
					rest += barrier_stakes(sk, foe, ms)
			"braced":
				rest += float(stacks * Effects.braced_armour() * allied_blows)
			"kindled":
				for eff in m.effects:
					if str(eff.get("effect", "")) == "add_attack":
						rest += float(int(eff.get("value", 0)) * stacks)
			"regenerating":
				# What the stacks the Purge reaches would have regrown before they ran out: the
				# top of the count, the dearest part of it.
				var held := Effects.stacks_of(foe, m.id)
				rest += float(Effects.regen_total(held) - Effects.regen_total(held - stacks))
			"enraged":
				# The Nob's gathered rage (3 November): a point of attack a stack on every blow to
				# come, so worth the stacks the Purge reaches over the blows the fight has left (RAGE_BLOWS).
				rest += float(stacks) * RAGE_BLOWS
			"golden":
				# A golden rage (4 November): its add on every blow of the rounds it has left, read
				# over RAGE_BLOWS, and the point of plate it wears; one stack, so any Purge takes it.
				rest += float(Effects.golden_value(foe)) * RAGE_BLOWS + 1.0
			"primed":
				rest += PRIMED_WORTH * float(stacks)
			"numbed":
				# Each stack stripped is a step toward a stun that lands (the stun's own price).
				rest += _threat_next(foe, sk) * HULL_WEIGHT * float(stacks) / float(Effects.stacks_of(foe, "numbed") + 1)
	return back + lives * rest


## The heat this entry adds, on top of what the gauge already holds: whatever ends the turn
## over the cap burns hull, and a machine burnt out is the worst trade there is. Asked of the
## entry itself, not the one showing, so a reroll can weigh every entry the same way.
func heat_cost(sk: Skirmish, ms: Skirmish.MechState, f: Face, uses: float = 1.0) -> float:
	return heat_cost_of(sk, ms, int(roundf(heat_of(ms, f) * uses)))


## What `added` heat on a machine's gauge costs it, from any source: a spend's own (heat_cost), the
## heat the Puffin's pull takes onto it or its dump passes onto an ally (19 November).
func heat_cost_of(sk: Skirmish, ms: Skirmish.MechState, added: int) -> float:
	if _vents_after(sk, ms):
		return 0.0   # a spend before the reboot it owes as its second (the Needletail's): the vent takes its heat
	var fc := sk.forecast(ms)
	var over := maxi(0, int(fc["heat_end"]) + added - ms.heat_max)
	var burn := (over - int(fc["overheat"])) * Skirmish.overheat_scale   # the hull the added excess burns
	var cost := float(burn) * HULL_WEIGHT
	if not fc["destroyed"] and int(fc["hull_after"]) - burn <= 0:
		cost += DEATH_WEIGHT
	cost += overheat_marks_cost(ms, int(fc["overheat"]), over)
	cost += hot_cost(sk, ms, added, fc)
	# A machine that would rage (the Nemesis's): heat that opens its next turn at its maximum buys
	# the Rage's flurry, read at a share (rage_worth), and heat it sheds below it gives that up.
	cost -= rage_worth(ms, int(fc["heat_after"]) + added) - rage_worth(ms, int(fc["heat_after"]))
	# A machine whose heat is its shot (the Whip Scorpion's Death Ray, fired with its heat at its heat
	# scale): heat that stays banks its next shot, read at a share (shot_worth); past the maximum the
	# burn above prices it.
	cost -= shot_worth(ms, int(fc["heat_after"]) + added) - shot_worth(ms, int(fc["heat_after"]))
	# The first turn past the maximum breaks the shield, and what stands there burns again
	# every turn: the shield it would lose, and the burn once more.
	if over > 0:
		cost += float(burn) * HULL_WEIGHT
		if int(fc["overheat"]) <= 0 and not ms.overheated:
			cost += float(ms.unit.shield) * HULL_WEIGHT
	# The cautious persona: the heat this spend leaves above its line (under the maximum, past
	# which the overheat above prices it), as an overheat's hull.
	var line := caution_line(ms)
	if line >= 0:
		var top := mini(int(fc["heat_end"]) + added, ms.heat_max)
		cost += float(maxi(0, top - maxi(line, int(fc["heat_end"])))) * HULL_WEIGHT * Skirmish.overheat_scale
	return cost


## What a Rage opening on `heat` is worth to a machine that would rage (the Nemesis's Crucible
## Capacitor), in foe hit points: a swing of its rage piece for every point the piece cools it,
## up to RAGE_SWINGS, each at the piece's plain number, at RAGE_SHARE; nothing under its maximum,
## for a machine already raging, or for one with no rage form.
static func rage_worth(ms: Skirmish.MechState, heat: int) -> float:
	var piece := Effects.rage_piece(ms.unit)
	if piece.is_empty() or Effects.raging(ms.unit) or heat < ms.heat_max:
		return 0.0
	for f in ms.die.faces:
		if f != null and f.component == piece:
			var swings := ceili(float(heat) / float(f.self_vent)) if f.self_vent > 0 else 1
			return RAGE_SHARE * float(mini(swings, RAGE_SWINGS) * f.power * maxi(1, f.strikes))
	return 0.0


## What `added` heat costs a machine whose hits on it double on a hot gauge (the Whip Scorpion's
## Thermal Ejection Manifold, past half its heat): the hull this round's blows would take more with
## the heat on it, a wreck it would make at DEATH_WEIGHT; nothing where the gauge stays on its side.
func hot_cost(sk: Skirmish, ms: Skirmish.MechState, added: int, fc: Dictionary) -> float:
	if added <= 0 or Effects.hot_hits(ms.unit, ms.heat + added, ms.heat_max) <= Effects.hot_hits(ms.unit, ms.heat, ms.heat_max):
		return 0.0
	var heat := ms.heat
	ms.heat = heat + added
	var hot := sk.forecast(ms)
	ms.heat = heat
	var more := maxi(0, int(hot["struck"]) - int(fc["struck"]))
	var cost := float(more) * HULL_WEIGHT
	if not fc["destroyed"] and int(fc["hull_after"]) - more <= 0:
		cost += DEATH_WEIGHT
	return cost


## What the overheat's what-if (Ryan, 30 October; Skirmish.overheat_corrupt) adds when the turn's
## excess goes from `before` to `after`: the corruption an overheat lays, the bites its stacks
## take over the rounds to come, as a foe's corrupt rider is priced. A placeholder, as every weight.
func overheat_marks_cost(ms: Skirmish.MechState, before: int, after: int) -> float:
	var cost := 0.0
	var faces := maxi(1, ms.die.faces.size())
	if Skirmish.overheat_corrupt > 0 and before <= 0 and after > 0:
		cost += float(Skirmish.corrupt_bite() * Skirmish.overheat_corrupt) * HULL_WEIGHT * CLEANSE_ROUNDS / float(faces)
	return cost


## The cautious persona's line on this machine's gauge (cool_above percent of its maximum), or
## -1 when the persona is off.
func caution_line(ms: Skirmish.MechState) -> int:
	if cool_above <= 0:
		return -1
	return int(floorf(float(ms.heat_max) * float(cool_above) / 100.0))


# ---------------------------------------------------------------- mines

## A spend's worth in Mines (the Lammergeier's Reverberant Payload, Ryan, 9 November), in foe hit
## points: the Mine its machine leaves on the target, blown at once with what the target already
## carries where the spend kills it (p_kill), else a blast to come at MINE_WEIGHT; a kill of a mined
## foe by any machine blowing its Mine now; the Lorentz Contractor's gather, the bigger blast round
## its target less the blasts the Mines had where they lay, still to come; and the Syrinx Drone's
## detonation, the target's Mine with its own added blown now on it and round it, less what it was
## worth waiting.
func mine_worth(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe, p_kill: float) -> float:
	if target == null or not target.alive():
		return 0.0
	var n := Effects.mine_damage(ms.unit)
	var mine := Skirmish.mine_of(target)
	var laid := {}
	if n > 0 and not Effects.turns_mark(target, "mine"):
		laid = {"damage": n, "riders": Skirmish.mine_riders(f)}
	var worth := 0.0
	if f.gathers_mines and not Effects.turns_mark(target, "mine"):
		var moved := {}
		var where := 0.0
		for foe in sk.field_foes():
			if foe == target or not foe.alive():
				continue
			var m := Skirmish.mine_of(foe)
			if not m.is_empty():
				moved = _mine_sum(moved, m)
				where += blast_worth(sk, m, foe, false)
		if not moved.is_empty():
			var before := _mine_sum(mine, laid)
			worth += (blast_worth(sk, _mine_sum(before, moved), target, false) - blast_worth(sk, before, target, false) - where) * MINE_WEIGHT
	var whole := _mine_sum(mine, laid)
	if f.detonates and not whole.is_empty():
		return worth + blast_worth(sk, whole, target, true) - blast_worth(sk, mine, target, false) * MINE_WEIGHT
	if not whole.is_empty():
		worth += p_kill * blast_worth(sk, whole, target, false)
	if not laid.is_empty():
		worth += (1.0 - p_kill) * blast_worth(sk, laid, target, false) * MINE_WEIGHT
	return worth


## A Mine's blast at a foe's slot, in foe hit points, as the field stands: its damage through each
## foe's own reads and armour, capped at what it has left, a kill's bonus where
## it fells, and its riders on a foe it leaves standing (Ablate's ticks, a stun's blow stopped, a
## Shock's doubled team blow, Exposed's worth); the foe itself among those it meets for a
## detonation (`centre`), never for its fall.
func blast_worth(sk: Skirmish, mine: Dictionary, at: Foe, centre: bool) -> float:
	if mine.is_empty() or at == null or at.rank < 0:
		return 0.0
	var dmg := int(mine.get("damage", 0))
	var r: Dictionary = mine.get("riders", {})
	var kws: Array = r.get("keywords", [])
	var met := sk.mine_reach(0 if at.is_massive() else at.rank, at.column, at.is_massive())
	if not centre:
		met.erase(at)
	var per := float(Effects.STATUS["ablating"]["effects"][0]["value"])
	var ablate := int((r.get("stacks", {}) as Dictionary).get("ablating", 0))
	var worth := 0.0
	for foe in met:
		var taken := maxi(0, Effects.damage_taken(foe, dmg, null, true, false) - foe.armour_total())
		worth += minf(float(taken), float(foe.hp))
		if taken >= foe.hp:
			worth += KILL_BONUS + _threat_now(foe, sk) * HULL_WEIGHT
			continue
		if ablate > 0:
			worth += per * float(ablate * (ablate + 1)) / 2.0 * ABLATE_WEIGHT
		if kws.has("suppress"):
			worth += _threat_now(foe, sk) * HULL_WEIGHT
		if kws.has("shock"):
			worth += minf(float(foe.hp - taken), _team_raw_attack_mean(sk)) * SHOCK_WEIGHT
		if kws.has("expose"):
			worth += expose_score(sk, foe)
	return worth


## Two Mines as one, either empty: their damage added and their riders as one (Skirmish's merge).
static func _mine_sum(a: Dictionary, b: Dictionary) -> Dictionary:
	if a.is_empty():
		return b
	if b.is_empty():
		return a
	return {"damage": int(a["damage"]) + int(b["damage"]), "riders": Skirmish.mine_riders_merged(a.get("riders", {}), b.get("riders", {}))}


## What Exposed on a foe is worth (21 October): its armour off each team blow likely before it
## fades (one a live machine, this round's rest and the next), and for a back-rank foe its
## formation hides, its kill and threat brought into Direct reach, as a share.
func expose_score(sk: Skirmish, foe: Foe) -> float:
	if foe == null or not foe.alive() or Effects.has(foe, "exposure") or Effects.turns_mark(foe, "exposure"):
		return 0.0
	var blows := float(sk.live_mechs().size())
	var score := float(foe.armour_total()) * blows * HULL_WEIGHT * EXPOSE_WEIGHT
	if foe.rank == 1 and not sk.is_exposed(foe.column):
		score += (KILL_BONUS + _threat_now(foe, sk) * HULL_WEIGHT) * EXPOSE_WEIGHT * 0.5
	return score


## What Brittle laid on one foe is worth (21 October): a point a stack on every team blow it takes
## this round, capped by what the foe will have left. The blows still to come this round are
## this spend's later strikes and the damaging entries the other machines show unspent, all of
## them on the spend's target and half on a neighbour it sweeps (the team may well pick
## another); then a round of the team's blows at the stacks its clock keeps (the status names
## it: half, or a stack less), a blow a machine on the target and half that elsewhere. Damage
## in hand, at BRITTLE_WEIGHT.
func brittle_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, foe: Foe, left: float, is_target: bool) -> float:
	if f == null or not f.has(Face.Keyword.BRITTLE) or left <= 0.0 or Effects.turns_mark(foe, "brittled"):
		return 0.0
	var stacks := f.brittle + Effects.extra_stacks(ms.unit, "brittled", ms.heat)
	var now := float(maxi(0, f.strikes - 1))
	var next := 0.0
	for other in sk.live_mechs():
		next += 1.0
		if other == ms or other.assigned:
			continue
		var of := other.face()
		if of != null and of.is_attack() and of.power > 0:
			now += float(maxi(1, of.strikes))
	var share := 1.0 if is_target else 0.5
	var gain := float(stacks) * now * share + float(Effects.stacks_next_round(Effects.STATUS["brittled"], stacks)) * next * share
	return minf(left, gain) * BRITTLE_WEIGHT


## What a volatile entry costs its owner in the score: the hull it bites per use, and the
## death it brings when the round's end would already leave nothing to bite.
static func volatile_cost(sk: Skirmish, ms: Skirmish.MechState, f: Face, uses: float = 1.0) -> float:
	if Skirmish.is_phased(ms):
		return 0.0   # nothing damages a Phased machine, the hull its own spend costs included (Skirmish.pending_volatile)
	var bite := Skirmish.spend_bite(ms.unit, f)
	if bite <= 0:
		return 0.0
	var cost := float(bite) * uses * HULL_WEIGHT
	var fc := sk.forecast(ms)
	if not fc["destroyed"] and int(fc["hull_after"]) - int(roundf(bite * uses)) <= 0:
		cost += DEATH_WEIGHT
	return cost


## What a cooldown costs an entry (21 October): every round it sits out after this one (the
## count since 12 November), the share of the die's rolls it would have shown, at what it is
## worth now. Rapid's own switch-off ends with this round and costs nothing here.
static func cooldown_cost(ms: Skirmish.MechState, f: Face, worth: float) -> float:
	var later := f.cooldown_rounds()
	if later <= 0 or worth <= 0.0 or ms.die.faces.is_empty():
		return 0.0
	return worth * float(later) / float(ms.die.faces.size())


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
	return _armour_saved(sk, ms, per * stacks, per) * HULL_WEIGHT


## Hull that `extra` armour keeps this round: every blow aimed at this machine that reaches
## its hull (past the shield's number or on bare hull) loses that much more, down to nothing,
## walked blow by blow as the forecast walks them. `per` is the armour a stack of it gives,
## where the armour is a buff: a blow that purges before it lands (19 November: the Waste's
## needles) takes a stack of it first, so each point purged by then thins it by that much.
func _armour_saved(sk: Skirmish, who: Skirmish.MechState, extra: int, per: int = 0) -> float:
	if extra <= 0:
		return 0.0
	var saved := 0
	var walk := {"shield": who.unit.shield, "barrier": Effects.has(who.unit, "barrier")}
	for a in sk.attackers_of(who):
		for r in sk.blows_on(who, a, walk):
			var left := extra if per <= 0 else maxi(0, extra - per * int(walk.get("purged", 0)))
			saved += mini(left, int(r["through"]))
	return float(saved)


## What a spend does to the hopper (the Ore Hopper, 31 October): the plate its fired loads stood
## for, lost, then the loads its blows dig back (hopper_fill_score, from the hopper as the shot
## leaves it).
func hopper_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe) -> float:
	var fired := Skirmish.hopper_loads(ms.unit, f)
	var have := Effects.stacks_of(ms.unit, "hopper")
	var score := 0.0
	if fired > 0:
		var lost := Effects.hopper_plate(ms.unit, have) - Effects.hopper_plate(ms.unit, have - fired)
		if lost > 0:
			score -= _armour_saved(sk, ms, lost) * HULL_WEIGHT * PLATE_ROUNDS
	return score + hopper_fill_score(sk, ms, f, target, have - fired)


## What filling the hopper is worth (the Chainsaw Claw, 11 October; any weapon on the Ore
## Hopper, 31 October): each load gained, up to the cap's room, the Armoured it stands (the
## hull its armour keeps over the rounds it is likely held) and what this machine's best
## hopper-firing entry adds a load, at the odds a later shot fires it. With no cap, the hopper
## is worth filling while it holds less than two of that entry's shots (more would sit unfired).
func hopper_fill_score(sk: Skirmish, ms: Skirmish.MechState, f: Face, target: Foe, held: int = -1) -> float:
	var per_foe := Skirmish.hopper_fill_of(ms.unit, f)
	if per_foe <= 0:
		return 0.0
	var per_load := 0
	var per_shot := 0
	for e in ms.die.faces:
		var ef := Effects.effective_face(ms.unit, e)
		if ef.empties_hopper and ef.power > per_load:
			per_load = ef.power   # a strike more of the entry that empties it (the Bullion Fragmenter)
			per_shot = maxi(1, Effects.store_cap(ms.unit, "hopper"))
	var have := Effects.stacks_of(ms.unit, "hopper") if held < 0 else held
	var cap := Effects.store_cap(ms.unit, "hopper")
	var room := cap - have if cap > 0 else per_shot * 2 - have
	# A load set for each foe the blow reaches, as the resolver reaches them (a twin slot's pair both).
	var reached := maxi(1, sk.reached_by(f, target).filter(func(n: Foe) -> bool: return n == target or n.alive()).size())
	var gained := mini(per_foe * reached, maxi(0, room))
	if gained <= 0:
		return 0.0
	var score := float(gained * per_load) * HOPPER_WEIGHT
	var plate := Effects.hopper_plate(ms.unit, have + gained) - Effects.hopper_plate(ms.unit, have)
	if plate > 0:
		score += _armour_saved(sk, ms, plate) * HULL_WEIGHT * PLATE_ROUNDS
	return score


## What `stacks` of a ticking status are worth on a foe with `hp` left, over the actions to
## come as a stack fades each: a flat tick (Ablating) its value a stack a tick, a share
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


## What `stacks` of a status that adds to every blow are worth on this machine's die for a round:
## its add a stack, on the strikes its entries land on average (a weapon of four strikes counts a
## stack four times, a blank and equipment none). A plain read off the die, so the scorer never
## asks itself; the rounds it lasts are the caller's.
static func flare_gain(ms: Skirmish.MechState, status_id: String, stacks: int) -> float:
	var faces := _rolled_faces(ms)
	if faces.is_empty() or stacks <= 0:
		return 0.0
	var strikes := 0.0
	for f in faces:
		if f.is_weapon():
			strikes += float(maxi(1, f.strikes))
	return _stack_damage_gain(status_id, _raw_attack_mean(ms)) * float(stacks) * strikes / float(faces.size())


## A buff on itself that spends a count for its stacks and holds the round's run-down on every
## unit (the Ammit's Quintessence Tap, 12 November): the machine gives this round's action for it, so
## nothing lands now. Next round it swings at what it consumed and at what it held, whole, where
## what it held would have halved; an ally's stacks are held the same way, and so is every foe's
## (a rally carries whole into its next blows), which is its price beside the count it spends.
## A plain rule for the rungs that read one round: the planner's rollouts play the real thing.
func hold_score(sk: Skirmish, ms: Skirmish.MechState, f: Face) -> float:
	var grants := sk.spend_take(ms, f) if not f.spends.is_empty() else f.buff_stacks
	if not f.spends.is_empty() and sk.spend_short(ms, f):
		return 0.0
	var held_ids: Array = Effects.named_like(f.holds_all) if not f.holds_all.is_empty() else []
	# What the machine carries whole into the next round: its grant when the hold covers it (else
	# half of it, the round's halving), and the half of what it held that the hold keeps.
	var own := float(grants) if held_ids.has(f.buff_status) else float(grants) * 0.5
	var score := 0.0
	for who in sk.live_mechs():
		var kept := 0.0
		for id in held_ids:
			var n := Effects.stacks_of(who.unit, str(id))
			kept += float(n - int(n / 2.0))
		if who == ms:
			kept += own
		score += flare_gain(who, f.buff_status, 1) * kept * HOLD_ROUNDS
	# The foes' half of the hold: each stack a rally leaves standing is a point on its next blow.
	for foe in sk.field_foes():
		if not foe.alive():
			continue
		for id in held_ids:
			var n := Effects.stacks_of(foe, str(id))
			score -= float(n - int(n / 2.0)) * HULL_WEIGHT
	if not f.spends.is_empty():
		score -= float(grants) * ESSENCE_WEIGHT
	return score


## The die's own average damage per entry, attack entries at their average times their
## strikes, blanks and everything else at zero: a plain read with no scoring under it, so a
## keyword that pays out on later attacks can be valued without asking the scorer again.
static func _raw_attack_mean(ms: Skirmish.MechState) -> float:
	return _raw_mean_of(_rolled_faces(ms))


## The plain mean blow of some entries (an attack's power times its strikes, the rest nothing).
static func _raw_mean_of(faces: Array) -> float:
	if faces.is_empty():
		return 0.0
	var total := 0.0
	for f in faces:
		if f.is_attack():
			total += float(f.power * maxi(1, f.strikes))
	return total / float(faces.size())


## The entries a die rolls among now: a folded die's live ones (the Clydesdale's battery up and
## its fixed pieces, Effects.live_entries), else every entry.
static func _rolled_faces(ms: Skirmish.MechState) -> Array:
	var live := Effects.live_entries(ms.unit, ms.die)
	if live.is_empty():
		return ms.die.faces
	var out: Array = []
	for i in live:
		out.append(ms.die.faces[int(i)])
	return out


## The entries a folded die's Changeover raises: the battery down, its roll's landing.
static func _stowed_faces(ms: Skirmish.MechState) -> Array:
	var out: Array = []
	for i in Effects.stowed_entries(ms.unit, ms.die):
		out.append(ms.die.faces[int(i)])
	return out


## The heat one use of an attack entry adds, through the pipeline; negative for one that
## fires the gauge empty first, or cools its own machine (self_vent).
static func heat_of(ms: Skirmish.MechState, f: Face) -> int:
	if f != null and not f.is_attack():
		return f.heat   # a printed heat on a piece spent on machines, landing as it is (the Musk Ox's quick reload)
	if ms.ammo_max > 0 and f != null and not f.is_debuff():
		return Effects.debuff_heat(ms.unit, f)   # a forging machine's gun: only a foe's debuff heats it
	var added := int(Effects.attack(ms.unit, f, 0, f.heat)["heat"])
	if f.vents_all:
		added -= ms.heat
	added += Effects.hit_heat(ms.unit, f) * maxi(1, f.strikes) + Effects.hit_heat(ms.unit, f, null, true)   # the heat its hits give it, the target's alone, and once a spend (the Incinerator's)
	if f.self_vent > 0:
		added -= mini(f.self_vent, maxi(0, ms.heat + added))   # it cools itself once its heat has landed (the Nemesis's Knuckles of Fury)
	return added


## What one use of an attack entry can land, with the odds of each: [[damage, weight], ...].
## One point, the entry's number. Overcharge, a target's missing hull and the pipeline's modifiers apply as the
## resolver applies them; the strikes multiply the blow, a split entry's (the Skua's) each
## taking its base halved before the pipeline, rounded down, never below one.
## `area` is the shape (Skirmish.AREA_ROW, AREA_COLUMN, AREA_ALL) of a foe past the strike's
## target, which takes that shape's number in place of the roll, through the same order (Ryan,
## 28 October): `f` is then the entry as aimed at the target, its grants already judged there.
func damage_outcomes(ms: Skirmish.MechState, f: Face, target: Foe = null, area: int = -1) -> Array:
	if area < 0:
		f = Effects.effective_face(ms.unit, f, target)
	var rolls: Array[int] = []
	if area == Skirmish.AREA_SIDE:
		rolls.append(Effects.side_strike(ms.unit, f, target))   # the foe to the right: the rifle's number (the Macaque's)
	elif area >= 0:
		rolls.append(Skirmish.area_number(f, area))   # a foe past the target: its shape's number
	else:
		rolls.append(f.power)
	var fired := Skirmish.heat_bonus(ms, f)   # what the heat it fires adds
	fired += Skirmish.shield_bonus(ms, f)   # what the shield it fires adds (the Shield-burner Cannon's)
	var zap := Skirmish.zap_ready(ms, f)   # the Buzzard's zap, where Empowered's add goes, when its shield pays
	var zctx := {"zap": zap} if zap > 0 else {}
	var scale := Effects.heat_damage_multiple(ms.unit, ms.heat, ms.heat_max)   # the Whip Scorpion's heat scale, at the heat it holds
	if scale != 1.0:
		zctx["heat_scale"] = scale
	# The foe's own reads (the blow's order, 28 October): its missing hull on every blow, and the
	# stacks a consumer eats on it on the first, flat after the firer's pipeline, as the resolver lands them.
	var own := f.missing_bonus(target) if not f.is_debuff() else 0   # every blow's
	var eats := f.consume_bonus(target) if not f.is_debuff() else 0   # the first blow's alone
	var out: Array = []
	var w := 1.0 / rolls.size()
	var n := float(maxi(1, f.strikes))
	var damaging := not f.is_debuff()
	# A foe's Barrier (28 October) takes the first blow of a weapon whole, an area's included.
	var barred := damaging and target != null and Effects.has(target, "barrier")
	for v in rolls:
		# A split's halving of the base (rounded down, never below one), then the firer's modifiers
		# judged on this foe, then its own reads.
		var dmg: int = int(Effects.attack(ms.unit, f, Skirmish.split_share(v + fired, f.split), 0, target, zctx.duplicate())["damage"]) + own
		# The foe's own statuses read last: a Shocked foe takes the first blow aimed at it double
		# (a foe past the target, an area's or an arc's, never: 29 October), and its Brittle adds to
		# every blow of a weapon, a strike of 0 included. Then its armour comes off every blow, so
		# a braced foe is worth less to a volume weapon.
		var arm := target.armour_for(f) if target != null else 0
		var later := maxi(0, (Effects.damage_taken(target, dmg, ms.unit, true, false) if target != null and damaging else dmg) - arm)   # every add and multiply but a Shocked doubling: its Brittle, a Guarded core's nothing
		if area >= 0:
			out.append([float(later) * (maxf(0.0, n - 1.0) if barred else n), w])   # no strike aimed at it: no Shock read
			continue
		# The spend's first blow, its first strike's on its target, reads what waits on the next strike
		# (the Parry's return, 19 November), as the resolver hands it.
		var fctx := zctx.duplicate()
		fctx["first_blow"] = true
		var opening: int = int(Effects.attack(ms.unit, f, Skirmish.split_share(v + fired, f.split), 0, target, fctx)["damage"]) + own
		var first := maxi(0, (Effects.damage_taken(target, opening + eats, ms.unit, damaging) if target != null else opening + eats) - arm)
		if barred:
			first = 0
		# The sword's hit again after every strike (the Macaque's offhand, 19 November): a strike of
		# its own, its share of the strike's number rounded down, through the firer's pipeline and the
		# foe's reads, then the foe's Brittle and armour.
		var again := Effects.strike_again(ms.unit, f, target) if target != null and f.reach != Face.Reach.EVERY_FOE else 0
		var echoed := 0.0
		if again > 0:
			var echo_base := floori(Skirmish.split_share(v + fired, f.split) * again / 100.0)
			var echo := int(Effects.attack(ms.unit, f, echo_base, 0, target, zctx.duplicate())["damage"]) + own
			echoed = float(maxi(0, (Effects.damage_taken(target, echo, ms.unit, damaging, false) if damaging else 0) - arm)) * n
		# Ricochet (the Skua's, 12 November; 25 November, the machine's alone): once the weapon's
		# strikes are done, a hit of 1 more a stack at its target, through the firer's pipeline, none
		# of the entry's own rules, then the foe's Brittle and its own armour.
		var bounced := 0.0
		var stacks := Effects.stacks_of(ms.unit, "ricochet") if f.is_weapon() and target != null and f.reach != Face.Reach.EVERY_FOE else 0
		if stacks > 0:
			var bctx := zctx.duplicate()
			bctx["plain"] = true
			var one := int(Effects.attack(ms.unit, f, 1, 0, target, bctx)["damage"])
			bounced = float(maxi(0, Effects.damage_taken(target, one, ms.unit, true, false) - target.armour_total())) * stacks
		out.append([float(first) + float(later) * maxf(0.0, n - 1.0) + bounced + echoed, w])
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


## A shield, a vent or a buff spent by `ms` on `who`: what it does where it lands, what a
## cleanse clears there, and what a volatile bite costs.
func machine_spend_score(sk: Skirmish, ms: Skirmish.MechState, who: Skirmish.MechState, f: Face) -> float:
	var score := 0.0
	if f.reaches_all and f.on_machines():
		# A spend reaching every ally (the Swallowtail's team shield, its Phased): each one's
		# worth, wherever the die was dropped.
		var plain := f.duplicate_face()
		plain.reaches_all = false
		plain.keywords.erase(Face.Keyword.RAPID)   # its action again counted once, below, not once a machine
		plain.keywords.erase(Face.Keyword.INSTANT)
		for w in sk.reached_machines(ms, f):
			score += machine_spend_score(sk, ms, w, plain)
		return score + rapid_worth(ms, f, second_action(sk, ms, f))
	match f.kind:
		Face.Kind.SHIELD:
			score = shield_score(sk, who, sk.shield_amount(ms, f, who), ms)
			if f.vents > 0 or f.cools_all:
				score += vent_score(sk, who, who.heat if f.cools_all else f.vents)   # the Hoist's cooling half
		Face.Kind.VENT:
			score = vent_score(sk, who, f.power)
		Face.Kind.BUFF:
			if f.act_again:
				score = ROLL_AGAIN_WEIGHT * _raw_attack_mean(who)   # the Horn's charged form: the ally acts again
			elif f.action_price > 0 and who != ms:
				# The Immelmann Booster's ally use (30 October), the look-or-action valuation: the
				# action bought, less its price, the rerolls it pays worth what the bank would have
				# carried of them (bank_delta), since the looks were taken as the round opened.
				score = action_value(who) - bank_delta(sk, -f.action_price)
			elif not f.spends.is_empty() or not f.holds_all.is_empty():
				score = hold_score(sk, ms, f)   # a buff that spends a count and holds the round (the Quintessence Tap)
			elif f.passes_heat:
				score = dump_score(sk, ms, who, f)   # the Puffin's dump: its heat onto the ally, a buff for it
			else:
				score = buff_score(sk, who, f)
				if guard_weight != 1.0 and is_block(f):
					score *= guard_weight   # the aggressor's habit: a block at a share of its worth
				if f.action_price > 0 and f.team_rerolls > 0:
					# The Booster's reroll on itself: the bot rerolls only as the round opens, so a
					# reroll gained mid-round is worth what the bank carries of it, as its price is.
					score = bank_delta(sk, f.team_rerolls)
				if f.rolls_target:
					score += roll_gain(who)   # the Reheat Uplink's roll on the machine it lands on
				if f.action_price > 0:
					# Spent on itself, the Booster goes dark for the round (Rapid's own switch-off):
					# the ally's action it could still buy once an ally has spent is given up.
					score -= action_ahead(sk, ms, f)
			if second_action(sk, ms, f):
				score += ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms)   # the Needletail's two things a round: the die turns and it acts again
			if who == ms:
				score += seal_score(sk, ms)   # a buff on itself seals a machine with a seal (the Polar Bear's Lockdown)
			elif not f.passes_heat:
				score += pull_score(sk, ms, who)   # the Puffin's pull: the ally's heat it takes onto itself
	if f.has(Face.Keyword.CLEANSE):
		score += cleanse_score(sk, who)
	# The Retrocausal Shroud (the Baboon's, 11 November): every foe aiming at the machine Disrupted.
	if f.disrupts_attackers:
		for foe in sk.acting_on(who):
			score += disrupt_score(sk, foe)
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
	score -= rage_cost(sk)   # a shield, a vent or a buff feeds a raging foe (3 November)
	score += rapid_worth(ms, f, second_action(sk, ms, f))   # a plain Rapid entry's action again (4 November)
	return score - volatile_cost(sk, ms, f) - cooldown_cost(ms, f, score)


## The Puffin's pull (on_buff_granted's pull_heat, 19 November): equipment it spends on an ally takes
## up to its number of that ally's heat onto itself. Worth a vent of what it takes on the ally, less
## what that heat costs on its own gauge; nothing for a machine that pulls none.
func pull_score(sk: Skirmish, ms: Skirmish.MechState, who: Skirmish.MechState) -> float:
	var most := Effects.granted_pull(ms.unit)
	if most <= 0 or who == ms:
		return 0.0
	var taken := mini(who.heat, most)
	if taken <= 0:
		return 0.0
	return vent_score(sk, who, taken) - heat_cost_of(sk, ms, taken)


## The Puffin's dump (Face.passes_heat, 19 November): its whole heat onto the ally, and a stack of its
## status for every heat_per_stack passed. Worth the buff at the stacks the heat makes, a vent of
## its own gauge, and the shield the ally's passive stands up for heat gained (the Storm Petrel's
## Hardlight Generator), less what the heat costs on the ally's gauge, its overheat included.
func dump_score(sk: Skirmish, ms: Skirmish.MechState, who: Skirmish.MechState, f: Face) -> float:
	var passed := ms.heat
	if passed <= 0 or who == ms:
		return 0.0
	var made := f.duplicate_face()
	made.passes_heat = false
	made.buff_stacks = passed / maxi(1, f.heat_per_stack)
	var score := buff_score(sk, who, made) if made.buff_stacks > 0 else 0.0
	score += vent_score(sk, ms, passed)
	var shield := 0 if who.shield_broken else mini(Effects.shield_per_heat(who.unit) * passed, maxi(0, who.unit.shield_max - who.unit.shield))
	if shield > 0:
		score += shield_score(sk, who, shield)
	return score - heat_cost_of(sk, who, passed)


## Does this spend leave its machine a second action by its own rule (Effects.one_of_each, the
## Needletail's Quick-turn Avionics Relay): its die turning to the other kind once it is out? A
## spend that acts again of its own (Rapid or Instant) keeps the turn for the next, so it reads as none here.
func second_action(sk: Skirmish, ms: Skirmish.MechState, f: Face) -> bool:
	return f != null and not f.acts_again() and not sk.turn_entries(ms, f).is_empty()


## What a plain Rapid or Instant entry's action again is worth (4 November; Ryan: "If the bot
## doesn't value rapid property, it probably should be fixed"; Instant, 12 November): spent, the
## die rolls again, never onto the entry just spent for Rapid and itself included for Instant, and
## its machine acts again, about the die's own average blow, read plainly so the scorer never asks
## itself (as the reset gun's and the Horn's are). Nothing for a spend the Needletail's turn
## follows (`quick`, valued as its own), nor on a stepping die, whose cycle plan reads the chamber its
## Rapid steps to and the chambers a spin may stop on (cycle_chain). The bot had valued none, so the
## Laminar Deflector, the Pulse Vacillator, the Cryo Flinger, the Musk Ox's Quick Reload and the
## Immelmann Booster's own action again were each worth only what they did once.
static func rapid_worth(ms: Skirmish.MechState, f: Face, quick: bool) -> float:
	if f == null or quick or not f.acts_again() or Effects.steps_die(ms.unit):
		return 0.0
	if f.turns_die and Effects.folds_die(ms.unit) > 0:
		return ROLL_AGAIN_WEIGHT * _raw_mean_of(_stowed_faces(ms))   # the Changeover's roll lands on the battery it raises
	return ROLL_AGAIN_WEIGHT * _raw_attack_mean(ms)



## The feed a non-weapon spend gives every raging foe on the field (the Nob's Bellow, 3
## November): each point of rage is a point on every blow it has left, read over RAGE_BLOWS
## blows, so the bot leans on its weapons against a Nob as the player should.
const RAGE_BLOWS := 2.0


func rage_cost(sk: Skirmish) -> float:
	var rage := sk.rage_on_field()
	return float(rage) * RAGE_BLOWS if rage > 0 else 0.0


## What an ammo is worth to a forging machine (the Musk Ox's): a share of the best damage a gun
## on its die buys with one, read now (the salvo aside: it takes whatever is left); nothing for a
## machine that forges nothing.
func ammo_worth(sk: Skirmish, ms: Skirmish.MechState) -> float:
	if ms.ammo_max <= 0:
		return 0.0
	var best := 0.0
	for face in ms.die.faces:
		if not face.is_attack() or face.is_debuff():
			continue
		if face.spends_magazine:
			continue
		var price := Effects.ammo_price(ms.unit, face)
		if price > 0:
			best = maxf(best, expected_damage(ms, face, null) / float(price))
	return best * AMMO_SHARE


## The ammo a forging machine keeps back from a piece that empties its magazine: what the dearest
## of its other guns needs for its next spend.
func magazine_reserve(ms: Skirmish.MechState) -> int:
	var reserve := 0
	for face in ms.die.faces:
		if face.is_attack() and not face.is_debuff() and not face.spends_magazine:
			reserve = maxi(reserve, Effects.ammo_price(ms.unit, face))
	return reserve


## What a cleanse clears from a machine, in hull: what its Ablating would take as the turn
## ends, the shield first, and on the turns after; the heat Scorched would
## add to its weapons this turn (about one; it goes at the turn's end), the bites its
## Corrupted entries would take over the rounds to come, and the entries a foe switched off,
## at the die's own mean for each.
## What a purge on this machine would cost it (28 October): every stack of its buffs, for the
## rounds they would have run (a stack is a stack, 8 November); a kept stack, an ability or a
## store, nothing.
func _purge_stakes(who: Skirmish.MechState) -> float:
	return float(Effects.buff_stacks(who.unit)) * BANK_WEIGHT * CLEANSE_ROUNDS


func cleanse_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	var score := 0.0
	# Its Ablating (15 November): the round's end with the stacks gone against the round's end
	# as it stands, this turn's tick and the blows through the gap it opens, then the ticks after
	# this turn's, a point each.
	var ablating := Effects.stacks_of(who.unit, "ablating_mech")
	if ablating > 0 and not Skirmish.is_out(who):
		var carried: Array = who.unit.modifiers
		who.unit.modifiers = carried.filter(func(m) -> bool: return m.id != "ablating_mech")
		var cleared := sk.forecast(who)
		who.unit.modifiers = carried
		var per := Effects.status_value("ablating_mech", "tick_hp")
		score += _outlook_gain(sk.forecast(who), cleared) + float(per * ablating * (ablating - 1)) / 2.0 * ABLATED_WEIGHT
	# Its Exposed (16 November): the armour back against the blows drawn on it this round, the
	# intents staying where they turned.
	if Effects.has(who.unit, "exposure_mech") and not Skirmish.is_out(who):
		var marked: Array = who.unit.modifiers
		who.unit.modifiers = marked.filter(func(m) -> bool: return m.id != "exposure_mech")
		var plated := sk.forecast(who)
		who.unit.modifiers = marked
		score += _outlook_gain(sk.forecast(who), plated)
	var scorch := Effects.stacks_of(who.unit, "scorched")
	if scorch > 0:
		for eff in Effects.STATUS["scorched"]["effects"]:
			if str(eff.get("effect", "")) == "add_heat":
				score += float(int(eff.get("value", 0)) * scorch) * BANK_WEIGHT
	var brittle := Effects.stacks_of(who.unit, "brittled_mech")
	if brittle > 0:
		# A point more a stack on every blow it takes this round, and the half that would stand the next.
		score += _brittle_cost(brittle)
	var n := who.die.faces.size()
	if n > 0:
		for i in range(n):
			var bite := Effects.corrupt_stacks(who.unit, i) * Skirmish.corrupt_bite()
			score += float(bite) * HULL_WEIGHT * CLEANSE_ROUNDS / float(n)
			if Effects.is_entry_disabled(who.unit, i) and Effects.cleansable_disable(who.unit, i):
				score += _raw_attack_mean(who) * CLEANSE_ROUNDS / float(n)
	return score


## A shield on a machine: the hull it keeps this round (each blow costs the shield its number
## and the excess passes), the death it prevents, and a little for what stands afterwards.
func shield_score(sk: Skirmish, who: Skirmish.MechState, power: int, by: Skirmish.MechState = null) -> float:
	var before := sk.forecast(who)
	var after := sk.forecast(who, power)
	var saved := maxf(0.0, float(after["hull_after"])) - maxf(0.0, float(before["hull_after"]))
	var score := saved * HULL_WEIGHT
	if before["destroyed"] and not after["destroyed"]:
		score += DEATH_WEIGHT
	# What stands afterwards banks, the shield up to its maximum.
	if shield_ahead:
		# The persona (30 October): what this shield leaves standing past the round's blows turns
		# next round's, the hull the foes' blows would take off an average machine, at a share for
		# the round away; the rest banks as ever.
		var stand := maxi(0, mini(int(after["shield_after"]), who.unit.shield_max) - mini(int(before["shield_after"]), who.unit.shield_max))
		var ahead := minf(float(stand), next_round_hull(sk, who))
		score += ahead * HULL_WEIGHT * AHEAD_SHARE + (float(stand) - ahead) * BANK_WEIGHT
	else:
		score += float(maxi(0, mini(power, who.unit.shield_max - who.unit.shield))) * BANK_WEIGHT
	# An escort's passive sheds the ally's heat as it shields (on_shield_granted): worth what
	# a vent of that much would be, on an ally only.
	if by != null and by != who:
		var vent := Effects.granted_vent(by.unit)
		if vent > 0:
			score += vent_score(sk, who, vent)
	return score


## The hull the foes' blows would take off an average machine next round (the shield persona's read
## of a standing shield): each live foe's moves by their weight, since a foe rolls its move as a
## round opens (a defend, a buff or a debuff deals nothing at its weight; a follow-up never
## rolls), a blow less this machine's armour and its armour against the foe's rank, times the
## move's strikes, whole for a blow on every machine and a share of one otherwise, since an
## attack with no word of its own picks any machine (this round's pick was the read until 2
## November; an attack's word is not read here).
func next_round_hull(sk: Skirmish, who: Skirmish.MechState) -> float:
	var total := 0.0
	var live := float(maxi(1, sk.live_mechs().size()))
	for foe in sk.field_foes():
		if not foe.alive():
			continue
		var armour := who.unit.armour
		var follow := Foe.follow_ups(foe.actions)
		var weights := 0.0
		var sum := 0.0
		for a in foe.actions:
			if follow.has(str(a.get("id", ""))):
				continue
			var w := float(maxi(1, int(a.get("weight", 1))))
			weights += w
			if not Foe.is_attack_action(a):
				continue
			var blow := float(maxi(0, foe.damage_of(a) - armour) * maxi(1, int(a.get("strikes", 1))))
			sum += w * blow * (1.0 if foe.has_keyword(a, "all") else 1.0 / live)
		total += sum / maxf(1.0, weights)
	return total


## A lure on the foes an entry reaches: the team's hull the redirect saves this round, and
## the deaths it prevents or causes, read by turning those foes on `who` in a what-if and
## reading every machine's forecast, then putting the targets back.
func lure_score(sk: Skirmish, who: Skirmish.MechState, foes: Array) -> float:
	var before := _team_outlook(sk, who, 0)
	var saved := {}
	for foe in foes:
		if foe.alive() and foe.aims_at_one() and foe.target != who:   # a move at every machine or at nobody holds no pick to turn
			saved[foe] = foe.target
			foe.target = who
	if saved.is_empty():
		return 0.0
	var after := _team_outlook(sk, who, 0)
	# What the turned moves lay with their blows moves with them (19 November): a purge, a jam,
	# an ablate, at its price on the lurer against its price on the machine it was aimed at.
	var steps := 0.0
	for foe in saved.keys():
		steps -= steps_threat(foe, sk)
	for foe in saved.keys():
		foe.target = saved[foe]
		steps += steps_threat(foe, sk)
	return (float(after["hull"]) - float(before["hull"])) * HULL_WEIGHT + float(int(before["deaths"]) - int(after["deaths"])) * DEATH_WEIGHT + steps * HULL_WEIGHT


## A disrupt on a foe about to strike, or gathering a countdown it breaks off (15 October;
## valued 22 October): the blow it will not land, this round's or the countdown's at its
## discount, less the blow of the move the disrupt turns it to (Skirmish.disrupt_next), when that
## lands this round.
static func disrupt_score(sk: Skirmish, foe: Foe) -> float:
	if foe.is_suppressed() or not foe.alive() or foe.committed or foe.immune_to("disrupt"):
		return 0.0   # an announced follow-up holds (2 November), and so does a gather its foe is immune through: a disrupt turns nothing
	var now := countdown_threat(foe, sk) if foe.gathering() else _threat_now(foe, sk)
	if now <= 0.0:
		return 0.0
	var next := sk.disrupt_next(foe)
	if next.is_empty():
		return 0.0
	var instead := 0.0
	if Foe.is_attack_action(next) and Foe.countdown_of(next) == 0:
		var machines: int = sk.live_mechs().size() if foe.has_keyword(next, "all") else 1
		instead = float(foe.damage_of(next, sk.incoming_rally(foe)) * maxi(1, int(next.get("strikes", 1))) * machines)
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
	var blow := sk.foe_blow(f) if sk != null else f.damage()
	return float(blow * f.strikes() * machines) * pow(COUNTDOWN_DISCOUNT, float(rounds))


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


## What a foe's last act costs the team when it falls (15 October, the Gargantuan King's Meteor; valued
## 22 October): its blow the moment it falls, on the machine that makes the kill (`killer`: the
## one weighing the spend; nobody when none does, Ryan, 17 November) or every machine for a
## blow at every machine, through each one's shield and armour as they stand: hull at
## HULL_WEIGHT, shield at SHIELD_LOSS_WEIGHT, a wreck at DEATH_WEIGHT.
static func last_act_cost(sk: Skirmish, f: Foe, killer: Skirmish.MechState = null) -> float:
	var blow := f.last_act()
	if blow.is_empty():
		return fall_steps_cost(sk, f, killer)
	return _last_blow_cost(sk, f, blow, killer, false) + fall_steps_cost(sk, f, killer)


## What a foe's last act argues against killing it this round: the part of its blow that waiting
## could save, its cost on the team as it stands less its cost on the same machines with their
## shields whole (a reboot's worth), and its fall's steps. The rest is paid whenever it falls,
## and a foe has to fall for the fight to be won: the whole blow weighed against one round's
## worth of the kill had the bot nursing a boss it could finish (18 November, the Gargantuan
## King at 33 rounds with a Meteor of 12, its squad rebooting five times a machine).
static func last_act_deterrent(sk: Skirmish, f: Foe, killer: Skirmish.MechState = null) -> float:
	var blow := f.last_act()
	if blow.is_empty():
		return fall_steps_cost(sk, f, killer)
	return maxf(0.0, _last_blow_cost(sk, f, blow, killer, false) - _last_blow_cost(sk, f, blow, killer, true)) + fall_steps_cost(sk, f, killer)


## A last act's blow on the machines it reaches, each through its shield and armour: as they
## stand, or `whole`, every shield at its maximum.
static func _last_blow_cost(sk: Skirmish, f: Foe, blow: Dictionary, killer: Skirmish.MechState, whole: bool) -> float:
	var amount := f.damage_of(blow)
	var whom: Array = []
	if f.has_keyword(blow, "all"):
		whom = sk.live_mechs()
	elif killer != null and killer.alive() and not Skirmish.is_out(killer):
		whom = [killer]   # a single death blow lands on the machine that made the kill, and on nobody when none did
	var cost := 0.0
	for m in whom:
		var shield: int = maxi(m.unit.shield, m.unit.shield_max) if whole else m.unit.shield
		var hull: int = m.unit.hull
		for s in range(maxi(1, int(blow.get("strikes", 1)))):
			var r := Skirmish._blow(shield, m.unit.armour, Effects.damage_taken(m.unit, amount, f))
			cost += float(int(r["absorbed"])) * SHIELD_LOSS_WEIGHT + float(int(r["through"])) * HULL_WEIGHT
			shield = int(r["shield"])
			hull -= int(r["through"])
		if hull <= 0:
			cost += DEATH_WEIGHT
	return cost


## What the steps of a foe's fall cost the team beside its blow (16 November: a fall is a short
## list of steps): each by the one table (effect_cost). A curse lands on the machine that
## makes the kill (`killer`: the one weighing the spend), and on nobody when none does.
static func fall_steps_cost(sk: Skirmish, f: Foe, killer: Skirmish.MechState = null) -> float:
	var fall := f.fall()
	if fall.is_empty():
		return 0.0
	var pick: Skirmish.MechState = killer
	if pick != null and (not pick.alive() or Skirmish.is_out(pick)):
		pick = null
	var cost := 0.0
	for st in Foe.effects_of(fall):
		cost += effect_cost(sk, f, st, pick, true)
	return cost


## What a Brittle laid on a machine costs it: a point more a stack on every blow it takes this
## round, and the half that stands the next.
static func _brittle_cost(stacks: int) -> float:
	return float(stacks + Effects.stacks_next_round(Effects.STATUS["brittled_mech"], stacks)) * HULL_WEIGHT


## What one effect of a foe's costs the team, in the score's points: the one table for a
## fall's steps, a move's own special and the steps a move does also (a move and a fall are
## short lists of steps since 16 November; a move's priced 17 November, as the bench's rows
## came to use them). Each is priced as the bot prices the same thing elsewhere: a Ward turns
## what lands on a machine, a rally is a point on every blow, a reroll is its share of the
## team's blow, a point regrown is a point of ours undone. `by` is the foe. `pick` is the
## machine an aimed effect lands on, the killer for a fall and the foe's own pick for a move,
## nobody when there is none. `falling` says the foe is gone as it lands: what it would do
## for itself counts nothing, and its rally and its unreadying are a fall's alone (a move's
## rally is Skirmish.rally_worth's). An effect with no line here counts nothing until a
## piece carries it and a read asks its price: a brace, a summon, a revival, a swallow, a
## merge.
static func effect_cost(sk: Skirmish, by: Foe, st: Dictionary, pick: Skirmish.MechState, falling: bool = false) -> float:
	var value := maxi(1, int(st.get("value", 0)))
	var lands: bool = pick != null and not Effects.has(pick.unit, "ward")
	var cost := 0.0
	match str(st.get("effect", "")):
		"ablate":
			if lands:
				cost += float(Effects.status_value("ablating_mech", "tick_hp") * value * (value + 1)) / 2.0 * ABLATED_WEIGHT
		"jam":
			if lands:
				cost += _raw_attack_mean(pick) / float(maxi(1, pick.die.faces.size()))
		"brittle":
			# A point more a stack on every blow it takes, this round and the half that stands
			# the next, as the bot prices a Brittle a Cleanse would lift.
			if lands:
				cost += _brittle_cost(value)
		"brittle_all":
			for m in sk.live_mechs():
				if not Effects.has(m.unit, "ward") and not Skirmish.is_out(m):
					cost += _brittle_cost(value)
		"sap_all":
			# A point off each hit a machine lands through its next turn, never more than its blow.
			for m in sk.live_mechs():
				if not Effects.has(m.unit, "ward") and not Skirmish.is_out(m):
					cost += minf(float(value), _raw_attack_mean(m))
		"dispel":
			# A purge, a move of its own or a step of one (19 November, as the Waste's needles
			# came to carry it): what it takes off its machine.
			if lands:
				cost += purge_cost(pick, value)
		"scorch_all":
			var scorch := 0
			for eff in Effects.STATUS["scorched"]["effects"]:
				if str(eff.get("effect", "")) == "add_heat":
					scorch += int(eff.get("value", 0))
			for m in sk.live_mechs():
				if not Effects.has(m.unit, "ward"):
					cost += float(scorch * value) * BANK_WEIGHT
		"corrupt_all":
			for m in sk.live_mechs():
				if not Effects.has(m.unit, "ward"):
					cost += float(Skirmish.corrupt_bite() * value) * HULL_WEIGHT * CLEANSE_ROUNDS / float(maxi(1, m.die.faces.size()))
		"drain_rerolls":
			cost += REROLL_SHARE * _team_raw_attack_mean(sk) * float(value)
		"rally":
			# A fall's: every foe still standing hits that much harder at its next blow, before it halves.
			if falling:
				for o in sk.field_foes():
					if o != by and o.alive():
						cost += float(value * o.strikes()) * HULL_WEIGHT
		"heal":
			# The points the heal gives back to the most hurt of its side, the healer too
			# while it stands.
			var most := 0
			for o in sk.field_foes():
				if o.alive() and (o != by or not falling):
					most = maxi(most, o.hp_max - o.hp)
			cost += float(mini(value, most))
		"recover":
			if not falling:
				cost += float(mini(value, by.hp_max - by.hp))
		"cleanse":
			# After a heal in the same move it lands on the heal's patient (the Cleric's
			# Cure); a cleanse of its own is priced where the move is (_cleanse_worth).
			if not falling:
				cost += _marks_worth(sk.heal_target(by), sk)
		"prime":
			for o in sk.field_foes():
				if o != by and o.alive():
					cost += PRIMED_WORTH * float(value)
		"expose":
			# The plate the mark takes off its machine, on every blow the foes' next round
			# turns on it. What the gathered fire is worth past that is no number here.
			if lands and not falling:
				var others := 0
				for o in sk.field_foes():
					if o != by and o.alive():
						others += 1
				cost += float(pick.unit.armour * others) * HULL_WEIGHT * AHEAD_SHARE
		"phase":
			# A foe that fades acts next round where no die reaches it: its next blow at a
			# round ahead's share, the one no kill and no stun can answer. Nothing where the
			# fade lays nothing: a foe out already, or the last one standing.
			if not falling and Skirmish.fade_lands(by):
				var stands := false
				for o in sk.field_foes():
					if o != by and o.alive():
						stands = true
				if stands:
					cost += float((sk.foe_blow(by) if by.attacks() else by.damage()) * by.strikes()) * HULL_WEIGHT * AHEAD_SHARE
		"appropriate":
			# The number the foe takes is on its every blow while it holds the piece.
			if lands and not falling and pick.face_index >= 0:
				cost += float(Skirmish.stolen_number(pick.die.faces[pick.face_index]) * by.strikes()) * HULL_WEIGHT
		"unready_all":
			# The one fall that pays: every foe its kind readied stays down when it next
			# falls, a second kill the team is spared, at that foe's whole HP.
			if falling:
				for o in sk.field_foes():
					if o == by or not o.alive():
						continue
					for m in o.modifiers:
						if m.id == "risen" and m.source == "foe:" + by.content_id:
							cost -= float(o.hp_max)
							break
	return cost


## What a foe's Purge of `n` takes off a machine, in the score's points: a stack of every
## buff it carries a point of the purge. A stack that stands for the fight is priced as the
## bot prices gaining one (Ricochet); one that turns a point off every blow on a standing
## shield, at a blow's point (Hardened Light); one that adds to its blows, at what it adds to
## one. Armour, a Barrier and a Ward count nothing here: they are the round's, and the round's
## forecast reads the blow as it lands with them gone. Any other buff is a banked stack.
static func purge_cost(who: Skirmish.MechState, n: int) -> float:
	var cost := 0.0
	for m in who.unit.modifiers:
		if not Effects.purgeable(m):
			continue
		var taken := float(mini(maxi(1, n), maxi(1, m.stacks)))
		match str(m.id):
			"ricochet":
				cost += RICOCHET_WORTH * taken
			"hardened":
				cost += HULL_WEIGHT * taken
			"barrier", "ward", "braced":
				pass
			_:
				var add := _stack_damage_gain(str(m.id), _raw_attack_mean(who))
				cost += (add if add > 0.0 else BANK_WEIGHT * CLEANSE_ROUNDS) * taken
	return cost


## The points of Purge aimed at a machine this round: a foe's move of its own, or a step of
## its move, before its blow or after. Nothing behind a Ward, which turns them away.
static func purges_coming(sk: Skirmish, who: Skirmish.MechState) -> int:
	if Effects.has(who.unit, "ward"):
		return 0
	var n := 0
	for f in sk.field_foes():
		if not f.alive() or f.is_suppressed() or not f.intends() or f.gathering() or f.target != who:
			continue
		if str(f.action.get("effect", "")) == "dispel":
			n += maxi(1, int(f.action.get("value", 1)))
		for st in Foe.extra_steps(f.action):
			if str(st.get("effect", "")) == "dispel":
				n += maxi(1, int(st.get("value", 1)))
	return n


## The specials _threat_now prices by reads of their own, so steps_threat leaves them be.
const PRICED_MOVES := ["rally", "cleanse", "barrier", "ward_all", "prime", "regenerate"]


## What the move a foe shows does beside its blow, in the points _threat_now counts (the
## score's over HULL_WEIGHT, since every reader weighs a threat as hull): its own special
## where the move is one the reads below do not already price, and every step it does also.
## Nothing while it gathers: a countdown's steps land with its blow.
static func steps_threat(f: Foe, sk: Skirmish) -> float:
	if sk == null or not f.intends() or f.is_suppressed() or f.gathering():
		return 0.0
	var pick: Skirmish.MechState = f.target as Skirmish.MechState
	if pick != null and (not pick.alive() or Skirmish.is_out(pick)):
		pick = null
	var cost := 0.0
	if not Foe.is_attack_action(f.action) and not PRICED_MOVES.has(str(f.action.get("effect", ""))):
		cost += effect_cost(sk, f, f.action, pick)
	for st in Foe.extra_steps(f.action):
		cost += effect_cost(sk, f, st, pick)
	return cost / HULL_WEIGHT


## A web on a foe (the funnel-web's Web Bomb, 18 October; bursting as the round ends since 16
## November): the next turn of the webbed foe and of the foe beside it, each read as the blow
## it shows now and at a round ahead's share, since the fight may end and the foes pick
## afresh; nothing for a foe the burst will not stun (web_stuns), and nothing on a foe already
## webbed.
func web_score(sk: Skirmish, target: Foe) -> float:
	if Effects.has(target, "webbed") or Effects.turns_mark(target, "webbed"):
		return 0.0
	var score := 0.0
	for foe in [target, sk.web_catch(target)]:
		if foe != null and web_stuns(foe):
			score += _threat_next(foe, sk) * HULL_WEIGHT * AHEAD_SHARE
	return score


## Will a web's burst stun this foe as the round ends? It meets the Numbed the foe ends the
## round with, which is exact: a stack goes as its turn ends, and a foe that loses this turn
## to a stun gains its stun resist there, so the web strips a stack of that and stuns nothing.
## A Ward up now is gone by then on a machine's side only: a foe's stands until its next turn
## starts, and turns the web itself away as it lands (web_score).
static func web_stuns(f: Foe) -> bool:
	if f == null or not f.alive() or f.immune_to("suppress"):
		return false
	var left := maxi(0, Effects.stacks_of(f, "numbed") - 1)
	if f.is_suppressed():
		left += f.stun_resist()
	return left <= 0


## The blow a foe lands at its next action, read as the one it shows: its blow now, a
## gathering one included, on every machine for a blow at every machine, or its base attack
## when it shows a special.
static func _threat_next(f: Foe, sk: Skirmish) -> float:
	if not f.intends():
		return 0.0
	if f.attacks() or f.gathering():
		var machines: int = sk.live_mechs().size() if f.reaches_every_machine() else 1
		return float(sk.foe_blow(f) * f.strikes() * machines)
	return float(f.attack)


## The team's hull at the round's end as the forecast sees it, and how many machines it
## loses, with `extra_shield` standing on `who`.
static func _team_outlook(sk: Skirmish, who: Skirmish.MechState, extra_shield: int) -> Dictionary:
	var hull := 0
	var deaths := 0
	for ms in sk.live_mechs():
		var fc := sk.forecast(ms, extra_shield if ms == who else 0)
		hull += maxi(0, int(fc["hull_after"]))
		if fc["destroyed"]:
			deaths += 1
	return {"hull": hull, "deaths": deaths}


## Whether a buff entry is a block (the aggressor's habit, guard_weight): its status takes a blow
## or a rider whole (a Barrier, a Ward, Phased) or thins what lands (armour for the round, damage
## taken at a share). Read from the status table, so a new block is one without a line here.
const BLOCK_STATUSES := ["barrier", "ward", "phased"]
static func is_block(f: Face) -> bool:
	if f == null or f.kind != Face.Kind.BUFF:
		return false
	if BLOCK_STATUSES.has(f.buff_status):
		return true
	for eff in Effects.STATUS.get(f.buff_status, {}).get("effects", []):
		match str(eff.get("effect", "")):
			"multiply_damage_taken":
				if float(eff.get("value", 1.0)) < 1.0:
					return true
			"add_stat":
				if str(eff.get("stat", "")) == "armour" and float(eff.get("value", 0)) > 0.0:
					return true
	return false


## A buff on a machine, from what its status does: more damage on the attack it has in hand
## this round (and its die's mean for any further round), less of the incoming it faces, or
## the Ablating its blows will leave. Nothing for a machine that has already spent its die.
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
	# The primers (2 November; Primed the third, 15 November): a stack a weapon fired. Charged is
	# a Shock on the next fire's foe, about this machine's own blow again; Supercooled a Cryo 1 the
	# next hit cashes, a vent of its cooling; Primed an Ablate 1 on the next fire's foe, its tick
	# at the bot's weight for a point of Ablating. Placeholders, as every weight.
	if f.buff_status == "charged":
		score += float(n) * _raw_attack_mean(who)
	elif f.buff_status == "supercooled":
		score += float(n) * vent_score(sk, who, Effects.status_value("cryoed", "cool_hitter"))
	elif f.buff_status == "primed":
		score += float(n) * float(Effects.STATUS["ablating"]["effects"][0]["value"]) * ABLATE_WEIGHT
	for eff in status.get("effects", []):
		var v := float(eff.get("value", 0))
		match str(eff.get("effect", "")):
			"multiply_damage":
				score += (pow(v, n) - 1.0) * (attack_now + attack_later)
			"add_damage":
				if status.has("spent_by"):
					score += v * n   # Spun Up: damage on the next weapon spend, whenever it comes
				else:
					# A flat add lands on every strike, so the gun showing counts it once a strike (the
					# Skua's split guns twice, its Pod four times).
					var blows := float(maxi(1, Effects.effective_face(who.unit, shown).strikes)) if attack_now > 0.0 else 0.0
					score += v * n * blows + v * n * float(f.buff_rounds - 1)
			"multiply_damage_taken":
				score += (1.0 - pow(v, n)) * float(sk.incoming_for(who)) * HULL_WEIGHT * float(f.buff_rounds)
			"add_stat":
				# Braced and its like: the armour stands behind this round's incoming blows.
				if str(eff.get("stat", "")) == "armour":
					score += _armour_saved(sk, who, int(v) * n, int(v)) * HULL_WEIGHT * float(f.buff_rounds)
	if f.team_rerolls > 0:
		score += REROLL_SHARE * _team_raw_attack_mean(sk) * float(f.team_rerolls)   # a team reroll more this round, no status
	match f.buff_status:
		"barrier":
			score += barrier_score(sk, who)
		"ward":
			score += ward_score(sk, who)
		"phased":
			score += phased_score(sk, who)
		"ricochet":
			# A strike of 1 more after each shot, for the fight: the stacks it will still hold
			# once the purges aimed at it this round have taken theirs.
			var have := Effects.stacks_of(who.unit, "ricochet")
			var taken := purges_coming(sk, who)
			score += RICOCHET_WORTH * float(maxi(0, have + n - taken) - maxi(0, have - taken))
		"aile_boost", "aile_assault", "aile_blitz":
			# The Aile Booster's (the Macaque's, 19 November): its next weapon reaches as Indirect, the
			# back rank opened; the Blitz's ignores armour too, a point off each strike it would meet.
			if not Effects.has(who.unit, f.buff_status):
				score += AILE_REACH_WORTH * _raw_attack_mean(who)
				if f.buff_status == "aile_blitz":
					var armour := 0
					for foe in sk.field_foes():
						if foe.alive():
							armour = maxi(armour, foe.armour_for(Face.attack(1)))
					score += AILE_ARMOUR_WORTH * float(armour)
	# The foe in front (the Photosphere Lance's Sapped, 11 November): its blows this round a
	# point lower a stack on each strike, never more than the blow, if it is to strike at all.
	if f.front_status == "sapped":
		var foe := sk.foe_in_front(who)
		if foe != null and foe.attacks() and not foe.is_suppressed():
			score += float(mini(sk.foe_blow(foe), f.front_stacks) * foe.strikes()) * HULL_WEIGHT
	return score


## What Phased is worth on a machine (the Swallowtail's charged Screens), granted as the round
## ends since 15 November and standing through the next: the next round's end with no blow
## reaching it, read as this round's would be (the foes' picks for the next are not out yet,
## so this round's are the bot's guess at them), the hull kept and the death prevented. It
## keeps its action. Nothing on a machine this round's end would wreck, which never phases,
## nor on one that waits for it already.
func phased_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	if Effects.has(who.unit, "phasing"):
		return 0.0
	var now := sk.forecast(who)
	if bool(now["destroyed"]):
		return 0.0
	var after := _forecast_with(sk, who, "phased")
	if after.is_empty():
		return 0.0
	return _outlook_gain(now, after)


## The round's end with and without a status on `who`, read in a what-if: the forecast with
## it granted for the round, then the grant taken back. Empty when the machine has it already
## (a second one renews, and changes nothing this round).
static func _forecast_with(sk: Skirmish, who: Skirmish.MechState, status_id: String) -> Dictionary:
	if Effects.has(who.unit, status_id):
		return {}
	var m := Effects.grant_buff(who.unit, status_id, 1, "what-if", sk.round)
	var fc := sk.forecast(who)
	who.unit.modifiers.erase(m)
	return fc


## What a Barrier is worth (21 October): the round's end as the forecast reads it with the
## first blow that deals anything taken whole: the hull kept and the death prevented, and a
## little for the shield it keeps standing, as a shield's own score reads them.
func barrier_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	var after := _forecast_with(sk, who, "barrier")
	if after.is_empty():
		return 0.0
	return _outlook_gain(sk.forecast(who), after)


## What a Ward is worth (21 October): every
## rider the blows aimed at it would lay this round, each at what a cleanse would clear of it:
## a Scorch's heat, an Ablate's points and a corruption's bites, each by the stacks its rider lays, and
## a disabled entry's share of the die.
func ward_score(sk: Skirmish, who: Skirmish.MechState) -> float:
	if Effects.has(who.unit, "ward"):
		return 0.0   # a second one renews, and changes nothing this round
	var score := 0.0
	var n := maxi(1, who.die.faces.size())
	var scorch := 0
	for eff in Effects.STATUS["scorched"]["effects"]:
		if str(eff.get("effect", "")) == "add_heat":
			scorch += int(eff.get("value", 0))
	var ablate := Effects.status_value("ablating_mech", "tick_hp")
	for a in sk.attackers_of(who):
		var blows := float(a.strikes())
		if a.has_keyword(a.action, "scorch"):
			score += float(scorch * a.rider(a.action, "scorch")) * blows * BANK_WEIGHT
		if a.has_keyword(a.action, "ablate"):
			var laid := a.rider(a.action, "ablate") * a.strikes()
			score += float(ablate * laid * (laid + 1)) / 2.0 * ABLATED_WEIGHT   # N stacks take N, N-1 ... 1 over the turns to come
		if a.has_keyword(a.action, "jam"):
			score += _raw_attack_mean(who) / float(n)
		if a.has_keyword(a.action, "corrupt"):
			score += float(Skirmish.corrupt_bite() * a.rider(a.action, "corrupt")) * blows * HULL_WEIGHT * CLEANSE_ROUNDS / float(n)
		if a.has_keyword(a.action, "expose"):
			score += exposed_stakes(sk, who)
	# A special's rider lands on it too, and the Ward turns that away as well (Ryan, 25 October:
	# "Should stop all riders, even from non-damaging attacks"): a Stoke's Ablating, a Stone's
	# switch-off or a purge on its pick; an Eruption's Scorched and a Diamond Dust's
	# Corrupted on every machine.
	# Every step of a move that is an effect, its own special or what it does also (16
	# November: a move is a short list of steps).
	for a in sk.field_foes():
		if not a.alive() or a.is_suppressed() or a.gathering():
			continue
		var on_it: bool = a.target == who
		for st in Foe.effects_of(a.action):
			var value := maxi(1, int(st.get("value", 0)))
			match str(st.get("effect", "")):
				"ablate":
					if on_it:
						score += float(ablate * value * (value + 1)) / 2.0 * ABLATED_WEIGHT
				"jam":
					if on_it:
						score += _raw_attack_mean(who) / float(n)
				"dispel":
					if on_it:
						score += _purge_stakes(who)
				"expose":
					if on_it:
						score += exposed_stakes(sk, who)
				"scorch_all":
					score += float(scorch * value) * BANK_WEIGHT
				"corrupt_all":
					score += float(Skirmish.corrupt_bite() * value) * HULL_WEIGHT * CLEANSE_ROUNDS / float(n)
				"sap_all":
					score += minf(float(value), _raw_attack_mean(who))
	return score


## What standing Exposed through the next round would cost a machine a foe's Expose is aimed
## at (16 November): its armour off every blow, and the fire of the whole field that would
## have gone elsewhere, as far as it has shield and hull to lose, at a share since the round
## is one away. The foes' moves a round on are unknown, so each counts at its blow.
static func exposed_stakes(sk: Skirmish, who: Skirmish.MechState) -> float:
	var fire := 0.0
	var blows := 0.0
	for a in sk.field_foes():
		if not a.alive():
			continue
		if a.attacks():
			fire += float(sk.foe_blow(a) * a.strikes())
			blows += float(a.strikes())
		else:
			fire += float(a.attack)   # a special this round: its plain blow the next
			blows += 1.0
	var stand := maxi(1, sk.targetable_mechs().size())
	var drawn := fire * (1.0 - 1.0 / float(stand))   # what it would not have taken as one pick among the machines
	var bare := float(who.unit.armour) * blows   # and its armour off every blow
	return minf(float(who.unit.shield + who.unit.hull), drawn + bare) * HULL_WEIGHT * EXPOSED_SHARE


## Two forecasts of one machine's round, read as a shield's score reads them: the hull kept,
## the death prevented, and the shield left standing at the bank's weight.
static func _outlook_gain(before: Dictionary, after: Dictionary) -> float:
	var score := (maxf(0.0, float(after["hull_after"])) - maxf(0.0, float(before["hull_after"]))) * HULL_WEIGHT
	if before["destroyed"] and not after["destroyed"]:
		score += DEATH_WEIGHT
	score += float(int(after["shield_after"]) - int(before["shield_after"])) * BANK_WEIGHT
	return score


## The blow a Shock laid on this foe now will double (23 October): the biggest an ally still to
## act this turn shows that reaches it, the hitter in hand, else the team's average blow. Priced
## at a share of the team's average alone, a Shock of no damage read as a bad roll beside any
## hitter, so the rerolls every rung shares threw a Polarity Projector away nine times in ten
## (`docs/measurements.md`, 23 October). A mine's Shock and a hull's land later and keep the
## average at SHOCK_WEIGHT.
func shock_cash(sk: Skirmish, ms: Skirmish.MechState, foe: Foe) -> float:
	var best := 0.0
	for other in sk.live_mechs():
		if other == ms or other.assigned:
			continue
		var of := sk.spend_face(other)
		if of == null or not of.is_attack() or not sk.targets_for_face(other, of).has(foe):
			continue
		best = maxf(best, float(of.power))
	return best if best > 0.0 else _team_raw_attack_mean(sk)


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
	var faces := _rolled_faces(who)
	if faces.is_empty():
		return 0.0
	var total := 0.0
	for f in faces:
		if not f.is_attack():
			continue
		var best := 0.0
		for t in sk.targets_for_face(who, f):
			best = maxf(best, attack_score(sk, who, f, t))
		total += best
	return total / float(faces.size())


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
	if at <= 0 or apps <= 0 or not target.alive() or Effects.turns_mark(target, "paradox") or target.immune_to("suppress"):
		return 0.0   # a Ward turns the Paradox itself away (28 October), and the stun it ends in lands on no foe immune to it
	var need := maxi(1, at - Effects.stacks_of(target, "paradox"))
	return minf(1.0, float(apps * adds) / float(need)) / float(Effects.stacks_of(target, "numbed") + 1)


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
		if f == null or not f.is_attack() or f.reaches_all or f.spends_magazine or f.is_debuff():
			continue
		areas.append([m, f])
	if areas.is_empty():
		return 0.0
	var before := _widest(sk, areas)
	var after := [0.0]
	sk.swap_what_if(first, second, func() -> void: after[0] = _widest(sk, areas))
	return maxf(0.0, float(after[0]) - before) * BUNCH_WEIGHT


## The team's area entries at their widest: for each, over its targets, the most its spend would
## deal to the live foes it reaches past its target (its shape's number through its machine's
## modifiers, every strike, less each foe's armour, capped at what the foe has left); an entry
## that reaches only its target adds nothing.
static func _widest(sk: Skirmish, areas: Array) -> float:
	var total := 0.0
	for a in areas:
		var m: Skirmish.MechState = a[0]
		var f: Face = a[1]
		var most := 0.0
		for t in sk.targets_for_face(m, f):
			var ef := Effects.effective_face(m.unit, f, t)
			if not ef.has_area():
				continue
			var shapes := sk.area_shapes(ef, t)
			var past := 0.0
			for foe in sk.ridden_by(ef, t):
				if foe != t and foe.alive():
					past += minf(maxf(0.0, _area_mean(m, ef, int(shapes.get(foe, Skirmish.AREA_ALL))) - float(foe.armour_total())), float(foe.hp))
			most = maxf(most, past)
		total += most
	return total


## What an area entry's spend deals a foe of one shape past its target, every strike, before
## that foe: the shape's number with what the entry prints from its firer (heat fired, the
## hopper), a split's halving of that base, through its machine's modifiers with no foe in hand.
static func _area_mean(m: Skirmish.MechState, f: Face, shape: int) -> float:
	var n := Skirmish.split_share(Skirmish.area_number(f, shape) + Skirmish.heat_bonus(m, f) + Skirmish.shield_bonus(m, f), f.split)
	var zap := Skirmish.zap_ready(m, f)
	var ctx := {"zap": zap} if zap > 0 else {}
	var scale := Effects.heat_damage_multiple(m.unit, m.heat, m.heat_max)   # the Whip Scorpion's heat scale
	if scale != 1.0:
		ctx["heat_scale"] = scale
	return float(Effects.attack(m.unit, f, n, 0, null, ctx)["damage"]) * float(maxi(1, f.strikes))


## A foe's worth standing in the front rank, where Direct fire reaches it.
static func _front_worth(sk: Skirmish, foe: Foe) -> float:
	return (KILL_BONUS + _threat_now(foe, sk) * HULL_WEIGHT) * SWAP_WEIGHT


## What sealing is worth (the Polar Bear's Lockdown, 20 October; valued 21 October; its trigger
## a buff spent on itself since 11 November): the armour stands behind this round's blows, less
## the heat the seal adds as the turn ends and the cooling it stops, as room lost. Nothing when
## it is sealed already or has no seal.
func seal_score(sk: Skirmish, ms: Skirmish.MechState) -> float:
	var seal := Effects.seal_form(ms.unit)
	if seal.is_empty() or Effects.is_sealed(ms.unit):
		return 0.0
	var kept := _armour_saved(sk, ms, int(seal["armour"])) * HULL_WEIGHT
	var cost := float(int(seal["heat"]) + Skirmish.cooling_of(ms)) * BANK_WEIGHT
	return kept - cost


## A vent on a machine: the hull its overheat would burn this round, and a little for the
## room it makes.
func vent_score(sk: Skirmish, who: Skirmish.MechState, power: int) -> float:
	var fc := sk.forecast(who)
	var saved := mini(power, int(fc["overheat"])) * Skirmish.overheat_scale   # the hull the vent keeps from the burn
	var score := float(saved) * HULL_WEIGHT
	if fc["destroyed"] and int(fc["overheat"]) > 0 and int(fc["hull_after"]) + saved > 0:
		score += DEATH_WEIGHT
	score += overheat_marks_cost(who, maxi(0, int(fc["overheat"]) - power), int(fc["overheat"]))
	score += float(mini(power, who.heat)) * BANK_WEIGHT
	# The cautious persona: what the vent takes off above its line and under the maximum (the
	# overheat above counts the rest), as an overheat's hull.
	var line := caution_line(who)
	if line >= 0:
		var held := mini(int(fc["heat_end"]), who.heat_max) - line
		score += float(clampi(power - int(fc["overheat"]), 0, maxi(0, held))) * HULL_WEIGHT * Skirmish.overheat_scale
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
			for who in sk.machine_targets_for(ms, f):
				best = maxf(best, machine_spend_score(sk, ms, who, f))
			# An entry that buys an ally's action (the Immelmann Booster) is worth the best one it may
			# still buy this round, so the bot neither rerolls it away nor spends it early.
			return maxf(best, action_ahead(sk, ms, f))
	return 0.0


## The die's average entry value right now, a disabled entry counting as blank.
func die_mean(sk: Skirmish, ms: Skirmish.MechState) -> float:
	if ms.die.faces.is_empty():
		return 0.0
	var live := Effects.live_entries(ms.unit, ms.die)   # a folded die's battery up and its fixed pieces
	var rolled: Array = live if not live.is_empty() else range(ms.die.faces.size())
	var total := 0.0
	for i in rolled:
		if Effects.is_entry_disabled(ms.unit, int(i)):
			continue
		total += face_value(sk, ms, ms.die.faces[int(i)])
	return total / float(rolled.size())


## What a reroll of this die is worth, the bar a greedy reroll clears: the die's mean, or for
## a stepping die the entry it steps to, known in advance (the Cassowary's dial, 21 October).
func reroll_worth(sk: Skirmish, ms: Skirmish.MechState) -> float:
	if Effects.steps_die(ms.unit):
		var nf := sk.next_face(ms)
		if nf != null:
			return face_value(sk, ms, nf)
	return die_mean(sk, ms)


## A stepping die's cycle (the Cassowary's, 3 November): what spending from chamber `at` this
## round is worth, and where the dial rests after, as {value, rest}. A Rapid chamber acts again
## on the chamber after it, known in advance, and a spin (the Spin-Up's) on a chamber drawn
## from all of them, itself included, so its value carries the die's spun mean and the dial
## rests anywhere (rest -1). Chambers read at their worth now, a dark one as blank. `read` is
## cycle_read's, so a plan scores each chamber once.
func cycle_chain(sk: Skirmish, ms: Skirmish.MechState, at: int, read: Dictionary = {}) -> Dictionary:
	if read.is_empty():
		read = cycle_read(sk, ms)
	var n := ms.die.faces.size()
	var kinds: Array = read["kinds"]
	var vals: Array = read["values"]
	var value := 0.0
	for seen in range(n):
		value += float(vals[at])
		match int(kinds[at]):
			1:
				return {"value": value + float(read["tail"]), "rest": -1}
			2:
				at = (at + 1) % n
			_:
				return {"value": value, "rest": at}
	return {"value": value, "rest": at}


## Every chamber of a stepping die read once: its worth now, its kind (0 plain or dark, 1 a spin,
## Instant's roll on a stepping die, 2 Rapid), what a spin brings after its own spend (a chamber drawn from all of them, each
## played out one step deep, the spinning one landing on itself spinning again: E = (S + E) / n
## + M / n over the S of the spinning chambers and the M of the rest, solved), and the die's
## mean over its chambers played out, for a next round whose chamber a spin left to chance.
func cycle_read(sk: Skirmish, ms: Skirmish.MechState) -> Dictionary:
	var n := ms.die.faces.size()
	var vals: Array = []
	var kinds: Array = []
	for i in range(n):
		var f := _chamber_face(sk, ms, i)
		vals.append(face_value(sk, ms, f))
		kinds.append(0 if f == null else (1 if f.has(Face.Keyword.INSTANT) else (2 if f.has(Face.Keyword.RAPID) else 0)))
	var spinning := 0
	var total := 0.0
	for i in range(n):
		if int(kinds[i]) == 1:
			spinning += 1
			total += float(vals[i])
		else:
			total += float(vals[i]) + (float(vals[(i + 1) % n]) if int(kinds[i]) == 2 else 0.0)
	var tail := 0.0 if spinning >= n or n == 0 else total / float(n - spinning)
	var mean := 0.0
	for i in range(n):
		mean += float(vals[i]) + (tail if int(kinds[i]) == 1 else 0.0)
	return {"values": vals, "kinds": kinds, "tail": tail, "mean": mean / float(maxi(1, n))}


## A chamber as it would be spent: the one showing as the spend goes out (a charged form), any
## other as the die would show it; null for a dark one.
func _chamber_face(sk: Skirmish, ms: Skirmish.MechState, i: int) -> Face:
	if Effects.is_entry_disabled(ms.unit, i):
		return null
	if i == ms.face_index:
		return sk.spend_face(ms)
	return sk.shown_face(ms, ms.die.faces[i])


## A stepping die's plan for the round's opening rerolls (the Cassowary's cycle, 3 November):
## for every count of steps the rerolls in hand allow, this round's chain from the chamber it
## brings, plus the next round's from the chamber after where the dial rests, at CYCLE_AHEAD
## (a spin's rest at the die's played-out mean). Returns {steps, gain}: the steps worth taking
## (the fewest on a tie) and what they add over standing.
func cycle_plan(sk: Skirmish, ms: Skirmish.MechState, budget: int) -> Dictionary:
	var n := ms.die.faces.size()
	if n == 0 or ms.face_index < 0 or not Effects.steps_die(ms.unit):
		return {"steps": 0, "gain": 0.0}
	var read := cycle_read(sk, ms)
	var worth: Array[float] = []
	for k in range(mini(budget, n - 1) + 1):
		var c := cycle_chain(sk, ms, (ms.face_index + k) % n, read)
		var ahead := float(read["mean"])
		if int(c["rest"]) >= 0:
			ahead = float(cycle_chain(sk, ms, (int(c["rest"]) + 1) % n, read)["value"])
		worth.append(float(c["value"]) + CYCLE_AHEAD * ahead)
	var best := 0
	for k in range(worth.size()):
		if worth[k] > worth[best] + 0.001:
			best = k
	return {"steps": best, "gain": worth[best] - worth[0]}


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
		while ms.alive() and not ms.assigned and ms.free_rerolls > 0 and _wants_reroll(sk, ms, ms.free_rerolls + sk.rerolls_left):
			if not sk.reroll([i]):
				break
			rerolls += 1
	# The look-or-action valuation (the Giant Petrel's, 30 October): with an ally's action to buy this
	# round (the Immelmann Booster showing, worth its price), its price in rerolls is kept from the
	# looks; and with a bank (Maverick's Playbook), a reroll it would carry to the next round goes on
	# looks only when they are worth more than a reroll kept.
	var kept := sk.bank_cap()
	while sk.rerolls_left > 0:
		var reserve := _action_reserve(sk)   # read again after every reroll: one may bring the Booster up
		if sk.rerolls_left <= reserve:
			return
		var idx: Array = []
		var gain := 0.0
		for i in range(sk.mechs.size()):
			var ms: Skirmish.MechState = sk.mechs[i]
			if not ms.alive() or ms.assigned:
				continue
			if Effects.steps_die(ms.unit):
				# A stepping die plans its cycle: the steps the rerolls left can take (3 November).
				var plan := cycle_plan(sk, ms, sk.rerolls_left - reserve)
				if int(plan["steps"]) > 0:
					idx.append(i)
					gain += float(plan["gain"]) / float(plan["steps"])
				continue
			var now := face_value(sk, ms, sk.spend_face(ms))   # a charged form as it will go out
			var worth := reroll_worth(sk, ms)
			if now + 0.001 < worth:
				idx.append(i)
				gain += worth - now
		if idx.is_empty():
			return
		if kept > 0 and sk.rerolls_left <= reserve + kept and gain < reroll_value(sk):
			return
		if not sk.reroll(idx):
			return
		rerolls += 1


## Whether a machine's own free reroll is worth taking: a stepping die by its cycle plan over
## `budget` steps, any other die while it shows less than its mean.
func _wants_reroll(sk: Skirmish, ms: Skirmish.MechState, budget: int) -> bool:
	if Effects.steps_die(ms.unit):
		return int(cycle_plan(sk, ms, budget)["steps"]) > 0
	return face_value(sk, ms, sk.spend_face(ms)) + 0.001 < reroll_worth(sk, ms)


## Rerolls to keep from the looks this round (the look-or-action valuation): the price of an ally's
## action an entry showing on an unspent die can buy (the Immelmann Booster), while one is worth
## more than the looks the price would take, at a reroll's worth each; 0 otherwise.
func _action_reserve(sk: Skirmish) -> int:
	for ms in sk.live_mechs():
		if ms.assigned or ms.face() == null:
			continue
		var f := sk.spend_face(ms)
		if f == null or f.action_price <= 0 or Effects.is_entry_disabled(ms.unit, ms.face_index) or sk.rerolls_left < f.action_price:
			continue
		for who in sk.live_mechs():
			if who != ms and not Skirmish.is_phased(who) and action_value(who) > float(f.action_price) * reroll_value(sk):
				return f.action_price
	return 0


## Whether a machine's die shows an entry that buys an ally's action (the Immelmann Booster), unspent.
static func _buys_action(sk: Skirmish, ms: Skirmish.MechState) -> bool:
	if not ms.alive() or ms.assigned or ms.face() == null:
		return false
	var f := sk.spend_face(ms)
	return f != null and f.action_price > 0


## The blow this foe is about to land, if it is aimed at anyone: on every live machine for a
## blow at every machine (`all`), the rallies on their way to it included. A rallier's is what
## its rally adds to the blows after it this round (Skirmish.rally_worth, 26 October), so the
## wolf is worth killing, Suppressing or Disrupting for the fodder it lifts.
static func _threat_now(f: Foe, sk: Skirmish = null) -> float:
	if sk != null and sk.rallies_now(f):
		return float(sk.rally_worth(f))
	var steps := steps_threat(f, sk) if sk != null else 0.0
	if sk != null and not f.is_suppressed():
		match str(f.action.get("effect", "")):
			"cleanse":
				return _cleanse_worth(f, sk) + steps
			"barrier", "ward_all", "prime", "regenerate":
				return _foe_buff_worth(f, sk) + steps
	if not f.intends() or f.is_suppressed() or not f.attacks():
		return steps
	var machines: int = sk.targetable_mechs().size() if sk != null and f.hits_all() else 1
	var blow := sk.foe_blow(f) if sk != null else f.damage()
	# A primed foe's move leaves Ablating on what it hits (28 October), 2 a stack (a placeholder).
	return float(blow * f.strikes() * machines) + PRIMED_WORTH * float(Effects.stacks_of(f, "primed")) + steps


## What a foe's buff special grants, as the bot reads it (28 October; placeholders): a Barrier
## the biggest weapon blow a machine still to act shows on the foe it shelters, a Ward nothing,
## Primed 2 a stack on every other foe it primes, Regenerating what its stacks regrow before they run out.
static func _foe_buff_worth(f: Foe, sk: Skirmish) -> float:
	var value := maxi(1, int(f.action.get("value", 0)))
	match str(f.action.get("effect", "")):
		"barrier":
			return barrier_stakes(sk, f)
		"prime":
			var primed := 0
			for other in sk.field_foes():
				if other != f and other.alive():
					primed += 1
			return PRIMED_WORTH * float(value * primed)
		"regenerate":
			return float(Effects.regen_total(value))
	return 0.0   # a Ward: nothing (the brief's placeholder)


## What a Barrier on a foe stands to take (28 October): the biggest blow of a weapon a machine
## still to act shows on it, the blow it would eat; `except` the machine asking, when an ally's
## blow is the question (a Purge's worth).
static func barrier_stakes(sk: Skirmish, foe: Foe, except: Skirmish.MechState = null) -> float:
	var best := 0.0
	for ms in sk.live_mechs():
		if ms.assigned or ms == except:
			continue
		var of := sk.spend_face(ms)
		if of != null and of.is_weapon() and sk.targets_for_face(ms, of).has(foe):
			best = maxf(best, float(of.power))
	return best


## What a cleanser's move would take off its side this round (28 October), each mark at what
## laying it is worth (placeholders): a Shock the biggest blow a machine still to act shows on
## that foe, Brittle its stacks for every machine still to act, Ablating its stacks, every other mark
## a point.
static func _cleanse_worth(f: Foe, sk: Skirmish) -> float:
	return _marks_worth(sk.cleanse_target(f), sk)


## What a stunned foe's move would threaten with its stun lifted, the stun a foe's cleanse takes
## (26 November): its blow as _threat_now reads one, which reads nothing on a stunned foe; a
## freed special counts nothing (a placeholder), so a freed cleanser is never read again.
static func _freed_threat(f: Foe, sk: Skirmish) -> float:
	if not f.intends() or not f.attacks():
		return 0.0
	var machines: int = sk.targetable_mechs().size() if f.hits_all() else 1
	return float(sk.foe_blow(f) * f.strikes() * machines) + PRIMED_WORTH * float(Effects.stacks_of(f, "primed"))


## The team's marks on one foe, each at what laying it is worth: what a cleanse of it takes.
static func _marks_worth(marked: Foe, sk: Skirmish) -> float:
	if marked == null:
		return 0.0
	var to_act: Array = []
	for ms in sk.live_mechs():
		if not ms.assigned:
			to_act.append(ms)
	var worth := 0.0
	for id in Effects.cleansed_marks():
		if not Effects.has(marked, id):
			continue
		match id:
			"suppressed":
				worth += _freed_threat(marked, sk)   # the stun a cleanse would lift: the move it frees (26 November)
			"shocked":
				var best := 0.0
				for ms in to_act:
					var of := sk.spend_face(ms)
					if of != null and of.is_attack() and sk.targets_for_face(ms, of).has(marked):
						best = maxf(best, float(of.power))
				worth += best
			"brittled":
				worth += float(Effects.stacks_of(marked, id) * to_act.size())
			"ablating":
				worth += float(Effects.stacks_of(marked, id))
			_:
				worth += 1.0
	return worth


## What a spend about to go out means for the Needletail's tallies (3 November): whether its
## die turns after it for a second action, whether it paints (an Expose on a foe), and whether it cashes a paint
## (a Direct weapon spend by another machine on a foe standing Exposed by one).
func _paint_marks(sk: Skirmish, ms: Skirmish.MechState, f: Face, target) -> Dictionary:
	if f == null:
		return {}
	var marks := {}
	if second_action(sk, ms, f):
		marks["quick"] = true   # read before the spend: the die will turn and its machine act again
	if not (target is Foe):
		return marks
	var foe := target as Foe
	if f.has(Face.Keyword.EXPOSE):
		marks["paint"] = true
	elif f.is_weapon() and f.reach == Face.Reach.DIRECT and _painted.has(foe) and _painted[foe] != ms and Effects.has(foe, "exposure"):
		marks["cash"] = true
	return marks


func _note_paints(ms: Skirmish.MechState, target, marks: Dictionary) -> void:
	if marks.is_empty():
		return
	if marks.has("quick"):
		gate_free += 1
	if marks.has("paint"):
		paints += 1
		_painted[target] = ms
	if marks.has("cash"):
		paints_cashed += 1
		_painted.erase(target)


func _tally(f: Face, charged: bool = false) -> void:
	if f == null:
		return
	var key := f.component + (" (charged)" if charged else "")   # a muster's spend apart (the Swallowtail's rows, 3 November)
	if f.kind == Face.Kind.BLANK:
		key = "disabled" if f.disabled else ("empty" if f.empty else "destroyed")
	spends[key] = int(spends.get(key, 0)) + 1

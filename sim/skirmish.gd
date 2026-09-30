class_name Skirmish
extends RefCounted

## The dice skirmish. Mechs have no positions. Enemies stand in a two-rank, three-column
## formation fed from a reinforcements, so a horde keeps coming.
##
## Round loop:
##   start_round()       passive cooling, roll every live mech's die, telegraph foe intents
##   reroll([...])       up to REROLLS_PER_ROUND times, any subset of unspent mech dice,
##                       before or after spending others: a low damage roll is information;
##                       a reroll always lands on a different face (see Die.reroll)
##   assign(i, target)   spend a mech's face on a foe (attacks) or a mech (shield, vent);
##                       kinetic faces roll their damage here, immediately and visibly
##                       a kill clears its slot at once; a decided fight ends at once
##   end_round()         burn ticks, foes act, the dead are cleared, mech statuses tick
##                       (overheating), heat over the cap burns hull, the reinforcements
##                       refill, outcome is checked
##   can_withdraw()      at the start of any round, before any face is spent
##
## Numbers are in tens. Enemy damage is static; only the player's kinetic faces roll.

enum State { SETUP, ROUND_START, ASSIGN, DONE }
enum Outcome { NONE, VICTORY, DEFEAT, WITHDRAWN }

const DEFAULT_COLUMNS := 4   # the formation's width (Ryan, 23 September: four plays better than three)
const REROLLS_PER_ROUND := 3
const DANGER_CLOSE_DIVISOR := 2
const BURN_DAMAGE_PER_STACK := 20   # damage dealt per stack applied
const CRACK_MIN_HULL_PCT := 25      # a single hull hit this big (percent of max) injures a face
const CORRUPT_BITE_PER_STACK := 10  # what a corrupted entry costs its owner each time it is spent, per stack (placeholder)
const VOLATILE_BITE := 10           # what a volatile component costs its owner each time it is spent: hull, past shield and armour (placeholder)
const SHOCK_DISCHARGE := 10         # what a Shocked foe pays for striking bare hull again (placeholder; the small thorns left in, Ryan, 28 September)
const NUMBED_PER_SUPPRESS := 2       # Numbed stacks a landed suppress adds; one is lost at each of the foe's turns
const NUMBED_PER_SUPPRESS_MASSIVE := 3


class MechState:
	var unit: Unit
	var die: Die
	var heat: int = 0
	var heat_max: int = 60
	var face_index: int = -1
	var locked: bool = false
	var assigned: bool = false
	var free_rerolls: int = 0   # rerolls of this die alone left this round, from a passive, on top of the team's

	## The entry showing, as it is right now: a disabled one shows as blank (the component
	## itself is untouched; the status is what says so).
	func face() -> Face:
		if face_index < 0 or face_index >= die.faces.size():
			return null
		if Effects.is_entry_disabled(unit, face_index):
			return Face.disabled_stand_in(die.faces[face_index])
		return die.faces[face_index]

	func alive() -> bool:
		return unit.hull > 0


var rng := RandomNumberGenerator.new()
var mechs: Array[MechState] = []
var packs: Array[Unit] = []
var columns: int = DEFAULT_COLUMNS
var terrain: int = BattleMap.Terrain.PLAIN   # the ground the fight is on (the contact hex), for the screen
var front: Array = []
var back: Array = []
var reinforcements: Array[Foe] = []   # foes waiting behind the formation; they step in at the reinforcement phase
var round: int = 0
var rerolls_left: int = 0
var state: int = State.SETUP
var outcome: int = Outcome.NONE
var log: Array[String] = []

## The most recent attack, for the screen to show: {mech, target, rolled, final, crit, ranged}.
var last_roll: Dictionary = {}
## Every blow of the last enemy turn, in order, for the screen to replay:
## {foe, mech (index), absorbed, through, blocked, broke_shield, injured, shield, hull}.
var turn_events: Array = []
## Every mech that burnt at the end of the last enemy turn, for the screen to land after
## the blows: {mech (index), over, hull}.
var overheats: Array = []
## The foes that have finished their action in the enemy turn under way, so a suppress that
## lands on one of them afterwards (a machine's loop catching a status it just gained) skips
## its next action rather than an action already taken.
var _acted: Array = []
## The machines a static screen covers during a withdrawal (the Prairie Dog): a blow aimed at
## one is lost. Empty outside a withdrawal.
var _screened: Array = []


func _init(seed_value: int = 0, columns_arg: int = DEFAULT_COLUMNS) -> void:
	rng.seed = seed_value
	columns = maxi(1, columns_arg)
	front.resize(columns)
	front.fill(null)
	back.resize(columns)
	back.fill(null)


# ---------------------------------------------------------------- setup

func add_mech(u: Unit, d: Die = null) -> MechState:
	var ms := MechState.new()
	ms.unit = u
	ms.die = d if d != null else u.die
	ms.heat_max = u.heat_max
	mechs.append(ms)
	return ms


func add_foes(list: Array, from_pack: Unit = null) -> void:
	for f in list:
		if from_pack != null:
			f.pack_id = from_pack.id
		reinforcements.append(f)
	if from_pack != null and not packs.has(from_pack):
		packs.append(from_pack)


func begin() -> void:
	# First deployment: heaviest hitters first, so they stand left and strike first, and the
	# player sees the big blow coming from the jump. Ties keep arrival order, so a formation
	# is predictable.
	var ordered: Array = reinforcements.duplicate()
	var ranked: Array = []
	for i in range(ordered.size()):
		ranked.append([ordered[i].threat(), -i, ordered[i]])
	ranked.sort_custom(func(a, b) -> bool: return a[0] > b[0] or (a[0] == b[0] and a[1] > b[1]))
	reinforcements.clear()
	for r in ranked:
		reinforcements.append(r[2])
	_reinforce(false)
	_refresh_allies()
	state = State.ROUND_START


# ---------------------------------------------------------------- queries

## Every foe on the field once. A massive foe sits in both slots of its column.
func field_foes() -> Array[Foe]:
	var out: Array[Foe] = []
	for f in front:
		if f != null and not out.has(f):
			out.append(f)
	for f in back:
		if f != null and not out.has(f):
			out.append(f)
	return out


func foe_at(rank: int, col: int) -> Foe:
	return front[col] if rank == 0 else back[col]


func is_exposed(col: int) -> bool:
	return front[col] == null


func live_mechs() -> Array[MechState]:
	var out: Array[MechState] = []
	for m in mechs:
		if m.alive():
			out.append(m)
	return out


func survivors_for(sq: Unit) -> int:
	var n := 0
	for f in field_foes():
		if f.pack_id == sq.id and f.alive():
			n += 1
	for f in reinforcements:
		if f.pack_id == sq.id:
			n += 1
	return n


func any_assigned() -> bool:
	for m in mechs:
		if m.assigned:
			return true
	return false


## Withdraw is open at any point of the player's turn, the first round included. Its price is
## always the same: the enemy takes its turn, then the team flees at the end of the round, so
## there is no leapfrogging out of contact unscathed (Ryan, 19 September).
func can_withdraw() -> bool:
	return state == State.ROUND_START or state == State.ASSIGN


## Heat the mech's current face will add if it is spent as an attack: negative for one that
## fires the gauge empty first.
func pending_heat(ms: MechState) -> int:
	var f := ms.face()
	if f == null or ms.assigned or not f.is_attack():
		return 0
	var added: int = Effects.attack(ms.unit, f, 0, f.heat, false)["heat"]
	return added - ms.heat if f.vents_all else added


## What a vent-on-fire attack adds to every blow from the heat it fires: its power_per_heat
## for each 10 heat the machine carries right now (the Afterburner Cannon, 28 September).
func heat_bonus(ms: MechState, f: Face) -> int:
	if f == null or not f.vents_all:
		return 0
	return f.power_per_heat * int(ms.heat / 10)


## Every live machine learns how many allies stand with it, for passives that read it.
func _refresh_allies() -> void:
	var n := live_mechs().size()
	for ms in mechs:
		ms.unit.allies = maxi(0, n - 1) if ms.alive() else 0


## The foes that will strike this mech when the round ends, in the order they act: alive,
## not suppressed, aimed at it, and not about to die to burn first.
func attackers_of(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	for f in field_foes():
		if not f.alive() or f.is_suppressed() or f.target != ms:
			continue
		if f.hp - int(Effects.tick_preview(f)["hp"]) <= 0:   # burns to death before it strikes
			continue
		out.append(f)
	return out


## Heat the round's end will add from the scorching blows about to land: one stack each,
## ticking at once.
func scorch_incoming(ms: MechState) -> int:
	var per_stack := int(Effects.STATUS["overheating"]["effects"][0]["value"])
	var stacks := 0
	for f in attackers_of(ms):
		if f.has_keyword(f.action, "scorch"):
			stacks += f.strikes()
	return stacks * per_stack


func incoming_for(ms: MechState) -> int:
	var total := 0
	for f in attackers_of(ms):
		total += f.damage() * f.strikes()
	return total


## What spending the entry showing would cost its owner through Corrupted stacks: nothing
## for a blank (a blank is not spent) or a die already spent.
func pending_bite(ms: MechState) -> int:
	var f := ms.face()
	if f == null or ms.assigned or f.kind == Face.Kind.BLANK:
		return 0
	return Effects.corrupt_stacks(ms.unit, ms.face_index) * CORRUPT_BITE_PER_STACK


## What spending the entry showing costs its owner as a volatile component (the Arsenal's
## keyword, 28 September): hull straight away, past shield and armour, whatever the
## component does. Nothing for a die already spent or an entry that is not volatile.
func pending_volatile(ms: MechState) -> int:
	var f := ms.face()
	if f == null or ms.assigned:
		return 0
	return volatile_cost(f)


## The hull a volatile entry costs its owner per spend; zero for any other entry.
static func volatile_cost(f: Face) -> int:
	return VOLATILE_BITE if f != null and f.has(Face.Keyword.VOLATILE) else 0


## What the end of the round does to this mech if nothing else changes: the screen's warning
## signs and bar overlays. Recomputed after every action, so shielding or killing an attacker
## moves the numbers at once. `with_face` counts the heat of the die's showing component as
## if spent; the screen asks for that only while the die is being dragged. `extra_shield`
## asks the same question with that much more shield standing (a shield component about
## to be spent here), for whoever weighs one.
func forecast(ms: MechState, with_face: bool = true, extra_shield: int = 0) -> Dictionary:
	var shield := mini(ms.unit.shield_max, ms.unit.shield + extra_shield)
	var hull := ms.unit.hull
	var bite := pending_bite(ms) if with_face else 0
	if bite > 0:
		# A corrupted entry bites the moment it is spent, shield first, before the enemy's blows.
		var b := _bite(shield, hull, bite)
		shield = b["shield"]
		hull = b["hull"]
	# A volatile entry costs hull outright as it is spent, shield or no shield.
	var volatile := pending_volatile(ms) if with_face else 0
	hull -= volatile
	var incoming := 0
	var component_risk := false
	for f in attackers_of(ms):
		for s in range(f.strikes()):
			incoming += f.damage()
			var r := _blow(shield, ms.unit.hull_max, ms.unit.armour + Effects.armour_against(ms.unit, f.rank), Effects.damage_taken(ms.unit, f.damage()), f.breaches())
			shield = r["shield"]
			hull -= r["through"]
			if r["injures"]:
				component_risk = true
	# Heat: what the gauge holds (past the cap, if the round ran hot), the face's own if
	# asked, then the end of the round's Overheating tick: the stacks it carries plus one
	# per scorching blow coming. Whatever ends over the cap burns hull at the round's end.
	var heat_after := ms.heat + (pending_heat(ms) if with_face else 0) + int(Effects.tick_preview(ms.unit)["heat"]) + scorch_incoming(ms)
	var over := maxi(0, heat_after - ms.heat_max)
	hull -= over
	return {
		"incoming": incoming,
		"bite": bite,
		"volatile": volatile,
		"shield_after": shield,
		"hull_after": hull,
		"heat_after": mini(heat_after, ms.heat_max),
		"overheat": over,
		"breaks_shield": ms.unit.shield > 0 and incoming >= ms.unit.shield,
		"component_risk": component_risk,
		"destroyed": hull <= 0 and ms.alive(),
	}


## Machines a piece of equipment may be spent on: itself, its allies, or both, as the
## component says (Ryan, 26 September: not every shield reaches an ally). Live machines only.
func equipment_targets_for(ms: MechState, f: Face) -> Array[MechState]:
	var out: Array[MechState] = []
	if f == null or not f.is_equipment():
		return out
	for who in live_mechs():
		if (who == ms and f.can_target_self()) or (who != ms and f.can_target_ally()):
			out.append(who)
	return out


## Foes this mech's current face may be spent on.
func targets_for(mech_index: int) -> Array[Foe]:
	var ms := mechs[mech_index]
	return targets_for_face(ms, ms.face())


## Foes this mech could spend `f` on, whether or not the die shows it: the same reach rules,
## asked about any entry (a player weighing a reroll, or a bot weighing a die).
func targets_for_face(ms: MechState, f: Face) -> Array[Foe]:
	var out: Array[Foe] = []
	if f == null or not f.is_attack():
		return out
	# Reach: melee hits the front rank, and the back only when the whole front is empty;
	# line hits the front and any exposed column's back; indirect hits everyone.
	var front_empty := true
	for col in range(columns):
		if front[col] != null:
			front_empty = false
	# A foe already killed this round still stands until the dead are cleared, but it is
	# no target: a die spent on it would be wasted.
	for col in range(columns):
		if front[col] != null and front[col].alive() and not out.has(front[col]):
			out.append(front[col])
		if back[col] == null or not back[col].alive() or out.has(back[col]):
			continue
		var reaches_back := false
		var reach := reach_of(ms, f)
		if reach == Face.Reach.INDIRECT:
			reaches_back = true
		elif reach == Face.Reach.MELEE:
			reaches_back = front_empty
		else:
			reaches_back = is_exposed(col)
		if reaches_back:
			out.append(back[col])
	return out


## A component's reach as it is right now: its own, unless the mech's passive says
## otherwise while a condition holds (the Badger's cracked weapons are melee). Computed on
## every read and never written to the component, so the answer always has a source: an
## ally reading the same component gets its own answer, and a suppressed passive stops
## answering.
func reach_of(ms: MechState, f: Face) -> int:
	return Effects.effective_reach(ms.unit, f)


## The component as the player should see it and as the resolver spends it: a copy carrying
## the effective reach and any keyword a passive grants. The die keeps the real one.
func shown_face(ms: MechState, f: Face) -> Face:
	return Effects.effective_face(ms.unit, f)


# ---------------------------------------------------------------- round flow

func start_round() -> void:
	assert(state == State.ROUND_START, "start_round called out of order")
	round += 1
	rerolls_left = REROLLS_PER_ROUND
	last_roll.clear()
	# The turn begins with passive cooling (Ryan, 22 September: cool at the start, heat at
	# the end): every machine sheds its chassis's cooling rating, one log line for all.
	var cooled: Array[String] = []
	for ms in mechs:
		ms.assigned = false
		if not ms.alive():
			continue
		var drop := mini(ms.heat, ms.unit.cooling)
		if drop > 0:
			ms.heat -= drop
			cooled.append("%s -%d" % [ms.unit.display_name, drop])
		ms.face_index = ms.die.roll(rng)
		ms.free_rerolls = Effects.free_rerolls(ms.unit)
	if not cooled.is_empty():
		log.append("cooling: " + ", ".join(cooled))
	_refresh_allies()
	# Passives that fire at the round's start, after the roll: shield from heat, a flat
	# shield, a vent (the Goshawk's Thermal Recoupler reads the heat as it stands now).
	for ms in live_mechs():
		var rs := Effects.round_start(ms.unit, ms.heat)
		var gained := ms.unit.recharge_shield(int(rs["shield"])) if int(rs["shield"]) > 0 else 0
		var vented := mini(ms.heat, int(rs["vent"]))
		ms.heat -= vented
		if gained > 0 or vented > 0:
			log.append("%s: round start, %s" % [ms.unit.display_name, ", ".join(([("+%d shield" % gained)] if gained > 0 else []) + ([("-%d heat" % vented)] if vented > 0 else []))])
	# Every foe announces its move for the round: which action, at whom. Chosen now, before
	# the player acts, so the intent chips and the forecast are exact.
	for f in field_foes():
		f.choose_action(rng)
		f.target = _pick_mech_target()
	state = State.ASSIGN


## Reroll the dice named. One die alone, on a machine with a free reroll of its own left
## (the Clydesdale's Battery Director), spends that instead of the team's; anything else
## spends one of the team's.
func reroll(mech_indices: Array) -> bool:
	if state != State.ASSIGN:
		return false
	var live: Array[MechState] = []
	for i in mech_indices:
		var ms := mechs[i]
		if ms.alive() and not ms.assigned:
			live.append(ms)
	if live.size() == 1 and live[0].free_rerolls > 0:
		live[0].free_rerolls -= 1
		live[0].face_index = live[0].die.reroll(rng, live[0].face_index)
		log.append("%s rerolls its own die for free" % live[0].unit.display_name)
		return true
	if rerolls_left <= 0:
		return false
	for ms in live:
		ms.face_index = ms.die.reroll(rng, ms.face_index)
	rerolls_left -= 1
	return true


## Is any reroll open: the team's, or a machine's own?
func can_reroll() -> bool:
	if state != State.ASSIGN:
		return false
	if rerolls_left > 0:
		return true
	for ms in live_mechs():
		if not ms.assigned and ms.free_rerolls > 0:
			return true
	return false


## Spend a mech's face. `target` is a Foe for attacks, a MechState (or null for self) for
## shield and vent. Returns false if the assignment is not legal.
func assign(mech_index: int, target = null) -> bool:
	if state != State.ASSIGN:
		return false
	var ms := mechs[mech_index]
	if not ms.alive() or ms.assigned:
		return false
	var f := ms.face()
	if f == null:
		return false
	f = Effects.effective_face(ms.unit, f)   # the entry as this machine's passives make it
	if f.is_attack() and (not (target is Foe) or not targets_for(mech_index).has(target)):
		return false
	if f.is_equipment() and not equipment_targets_for(ms, f).has(target if target is MechState else ms):
		return false
	# A corrupted entry bites its owner as it is spent (shield first, no armour: the rot is
	# inside the machine), before the component does its work. A machine it finishes acts
	# no further.
	var bite := pending_bite(ms)
	if bite > 0:
		var b := _bite(ms.unit.shield, ms.unit.hull, bite)
		log.append("%s: %s bites back, shield -%d, hull -%d" % [ms.unit.display_name, f.describe(), ms.unit.shield - int(b["shield"]), ms.unit.hull - int(b["hull"])])
		var hull_lost: bool = int(b["hull"]) < ms.unit.hull
		ms.unit.shield = b["shield"]
		ms.unit.hull = b["hull"]
		if hull_lost:
			_hull_damaged(ms)
		if not ms.alive():
			log.append("%s is wrecked by its own corrupted component" % ms.unit.display_name)
			ms.assigned = true
			_check_outcome()
			return true
	# A volatile component bites too, hull outright: shield and armour never see it (the
	# Arsenal's keyword, 28 September). It fires whatever the component is, so a volatile
	# shield costs hull to raise. A machine it finishes acts no further.
	var volatile := pending_volatile(ms)
	if volatile > 0:
		ms.unit.hull -= volatile
		log.append("%s: %s is volatile, hull -%d" % [ms.unit.display_name, f.describe(), volatile])
		_hull_damaged(ms)
		if not ms.alive():
			log.append("%s is wrecked by its own volatile component" % ms.unit.display_name)
			ms.assigned = true
			_check_outcome()
			return true
	match f.kind:
		Face.Kind.BLANK:
			pass
		Face.Kind.SHIELD:
			var who: MechState = target if target is MechState else ms
			who.unit.shield = mini(who.unit.shield_max, who.unit.shield + f.power)
			log.append("%s shields %s for %d" % [ms.unit.display_name, who.unit.display_name, f.power])
			_cleanse_with(ms, who, f)
			_draw_with(who, f)
		Face.Kind.VENT:
			var who: MechState = target if target is MechState else ms
			who.heat = maxi(0, who.heat - f.power)
			log.append("%s vents %s by %d" % [ms.unit.display_name, who.unit.display_name, f.power])
			_cleanse_with(ms, who, f)
			_draw_with(who, f)
		Face.Kind.BUFF:
			# Equipment that grants a status for the round (or more): the pipeline reads it
			# like any modifier, and end_round lets it go.
			var who: MechState = target if target is MechState else ms
			var until := round + f.buff_rounds - 1
			var src := "buff:" + f.component if not f.component.is_empty() else "buff"
			var m := Effects.grant_buff(who.unit, f.buff_status, f.buff_stacks, src, until)
			if m != null:
				log.append("%s buffs %s: %s ×%d%s" % [ms.unit.display_name, who.unit.display_name, m.name, f.buff_stacks, "" if f.buff_rounds == 1 else " for %d rounds" % f.buff_rounds])
				for rank in [0, 1]:
					if Effects.draws_rank(who.unit, rank):
						_retarget_rank(rank, who)
			_cleanse_with(ms, who, f)
		Face.Kind.ATTACK:
			_resolve_attack(mech_index, ms, f, target)
	ms.assigned = true
	# Rapid: the component is switched off for the rest of this round, the die rerolls for
	# free (never the same entry), and the mech may act again. The disable is only there to
	# stop an infinite turn.
	if f.has(Face.Keyword.RAPID):
		Effects.disable_entry(ms.unit, ms.face_index, "rapid", round)
		ms.face_index = ms.die.reroll(rng, ms.face_index)
		ms.assigned = false
		log.append("%s: rapid, rolls again" % ms.unit.display_name)
	# The fight ends the moment it is decided (Ryan, 22 September): the last foe down, or
	# the last machine burnt out by its own heat, and nobody waits for End turn.
	_refresh_allies()
	_check_outcome()
	return true


func end_round() -> int:
	assert(state == State.ASSIGN, "end_round called out of order")
	_enemy_turn()
	_tick_mechs()
	_settle_heat()
	_reinforce(true)    # the reinforcement phase: a random waiting foe of the right rank per empty slot
	_refresh_allies()
	_check_outcome()
	if outcome == Outcome.NONE:
		state = State.ROUND_START
	return outcome


## The enemy's turn: every foe on the field acts in order, statuses tick, timed effects run
## out. Shared by the end of a round and by a withdrawal.
func _enemy_turn() -> void:
	turn_events.clear()
	overheats.clear()
	# Foes act in the order they stand: front rank left to right, then the back rank. Each
	# foe's statuses tick at the start of its action (burning may kill it first), a
	# suppressed foe skips, and a foe with two strikes lands two separate blows, so a shield
	# stops the first and the second reaches the hull.
	_acted.clear()
	for f in field_foes():
		if not f.alive():
			continue   # killed by a die this round; it stands until the dead are cleared, and does nothing
		var tick := Effects.tick(f)
		if int(tick["hp"]) > 0:
			f.hp -= int(tick["hp"])
			log.append("%s burns for %d" % [f.display_name, int(tick["hp"])])
			if not f.alive():
				continue
		if tick["skip"]:
			continue
		var t := f.target as MechState
		if t == null or not t.alive():
			t = _pick_mech_target(f)
		if t == null:
			break
		_acted.append(f)   # from its first blow, a suppress landing on it costs its next action
		if _screened.has(t):
			log.append("%s's blow is lost in the static" % f.display_name)
			continue
		for s in range(f.strikes()):
			if not t.alive():
				break
			var was_shocked := Effects.has(f, "shocked")
			_damage_mech(t, f.damage(), f)
			var blocked: bool = turn_events[turn_events.size() - 1]["blocked"]
			# The live hull (the Armadillo's, a machine under Retaliate): a blow that reaches
			# hull shocks the foe that struck; a shutters' blocked blow shocks too. A foe already
			# Shocked that reaches hull again pays the discharge, and may die of it.
			if was_shocked and not blocked:
				f.hp -= SHOCK_DISCHARGE
				log.append("%s discharges into %s: %d" % [t.unit.display_name, f.display_name, SHOCK_DISCHARGE])
				if not f.alive():
					break
			if Effects.shocks_striker(t.unit, blocked):
				_shock(f, t)
			if f.has_keyword(f.action, "scorch") and t.alive():
				Effects.stack(t.unit, Effects.STATUS["overheating"], Effects.SKIRMISH, "foe:" + f.content_id)
			if f.has_keyword(f.action, "disable") and t.alive() and t.face_index >= 0:
				# The entry the die shows is switched off through the mech's next turn.
				Effects.disable_entry(t.unit, t.face_index, "foe:" + f.content_id, round + 1)
				log.append("%s disables %s's %s" % [f.display_name, t.unit.display_name, t.die.faces[t.face_index].describe()])
			if f.has_keyword(f.action, "corrupt") and t.alive() and t.face_index >= 0:
				# The entry the die shows is corrupted for the fight: it bites when spent.
				Effects.corrupt_entry(t.unit, t.face_index, "foe:" + f.content_id)
				log.append("%s corrupts %s's %s (×%d)" % [f.display_name, t.unit.display_name, t.die.faces[t.face_index].describe(), Effects.corrupt_stacks(t.unit, t.face_index)])
	_acted.clear()
	_clear_dead()
	for ms in mechs:
		Effects.end_round(ms.unit, round)   # timed effects run out
	for f in field_foes():
		Effects.end_round(f, round)


## The round ends with the machines' statuses ticking, after the enemy has struck: an
## Overheating stack lands on the round's peak heat, before the next turn's cooling can
## relieve it (Ryan, 22 September), so a scorch bites the round it was dealt.
func _tick_mechs() -> void:
	for ms in live_mechs():
		var t := Effects.tick(ms.unit)
		if int(t["heat"]) > 0:
			log.append("%s: %d heat from overheating" % [ms.unit.display_name, int(t["heat"])])
			_add_heat(ms, int(t["heat"]))


func withdraw() -> bool:
	if not can_withdraw():
		return false
	if state == State.ROUND_START:
		start_round()
	log.append("Withdrawing: the enemy strikes as the team pulls out")
	_screen_cover()
	_enemy_turn()
	_screened.clear()
	outcome = Outcome.DEFEAT if live_mechs().is_empty() else Outcome.WITHDRAWN
	_finish()
	if outcome == Outcome.WITHDRAWN:
		log.append("Withdrew at the end of round %d" % round)
	return true


# ---------------------------------------------------------------- resolution

## Spend an attack: every strike is its own blow (its own roll, its own crit, its own
## keywords and passives), landing on every foe the component reaches. Heat is paid once per
## use; danger close is charged on the total.
func _resolve_attack(mech_index: int, ms: MechState, f: Face, target: Foe) -> void:
	var total := 0
	var rolled_total := 0
	var any_crit := false
	var heat_total := 0
	var vent := 0
	var extra_burn := 0
	# A vent-on-fire attack fires the machine's whole heat into the blow: its bonus is read
	# now and the gauge is emptied once the strikes have landed.
	var fired := heat_bonus(ms, f)
	var vented_all := ms.heat if f.vents_all else 0
	if f.vents_all:
		ms.heat = 0
	for s in range(maxi(1, f.strikes)):
		var rolled := f.power
		if f.is_ranged():
			if Effects.rolls_max(ms.unit, f, target):
				rolled = f.power_max   # every ally's firing solution: the roll is its ceiling
			else:
				rolled = f.average() if f.has(Face.Keyword.STEADY) else rng.randi_range(f.power, f.power_max)
		rolled += fired
		var dmg := rolled
		var heat := f.heat if s == 0 else 0
		var crit := f.crit > 0 and rng.randi_range(1, 100) <= f.crit
		if crit:
			dmg = int(roundf(dmg * (Face.CRIT_MULT + f.crit_bonus + Effects.crit_bonus(ms.unit, f, target))))
		if f.has(Face.Keyword.EXECUTE) and target.hp * 2 <= target.hp_max:
			dmg = int(roundf(dmg * (1.5 if target.is_massive() else 2.0)))   # bosses and elites: half the bonus
		# Then the pipeline: every live modifier's adds, multiplies and floors, in that order.
		# Conditions on the foe read the primary target; a spread or a penetrate carries
		# the same blow to the others.
		var modded := Effects.attack(ms.unit, f, dmg, heat, crit, target)
		dmg = modded["damage"]
		heat_total += modded["heat"]
		extra_burn += modded["burn"]
		vent += modded["vent"]
		# Keywords stack: a cleaving, piercing blow hits the neighbours and the column.
		var hit: Array[Foe] = [target]
		if f.has(Face.Keyword.CLEAVE):
			for c in [target.column - 1, target.column + 1]:
				if c >= 0 and c < columns:
					var n := foe_at(target.rank, c)
					if n != null and not hit.has(n):
						hit.append(n)
		if f.has(Face.Keyword.PENETRATE):
			var other := foe_at(1 - target.rank, target.column)
			if other != null and not hit.has(other):
				hit.append(other)
		var landed := dmg
		for foe in hit:
			var was_alive := foe.alive()
			var hp_before := foe.hp
			# What the foe takes of the blow: its own statuses read last (a Shocked foe takes
			# double, and the shock is spent by the blow).
			var taken := Effects.damage_taken(foe, dmg)
			foe.hp -= taken
			if foe == target:
				landed = taken
			if Effects.remove(foe, "shocked"):
				log.append("%s: the shock lands, %d doubled" % [foe.display_name, dmg])
			if was_alive and not foe.alive() and f.has(Face.Keyword.DEVOUR):
				_devour(ms, foe)
			# Overwhelm: what the blow had past the kill of a front-rank foe carries into the
			# foe behind it in the column, as plain damage that still spends a shock and
			# feeds a devour. A massive foe fills its column, so nothing stands behind it.
			if was_alive and not foe.alive() and f.has(Face.Keyword.OVERWHELM) and foe.rank == 0 and not foe.is_massive():
				var spill := taken - hp_before
				var behind: Foe = back[foe.column] if foe.column >= 0 and foe.column < columns else null
				if spill > 0 and behind != null and behind.alive() and not hit.has(behind):
					var behind_taken := Effects.damage_taken(behind, spill)
					behind.hp -= behind_taken
					Effects.remove(behind, "shocked")
					log.append("%s overwhelms: %d spills into %s" % [ms.unit.display_name, behind_taken, behind.display_name])
					if not behind.alive() and f.has(Face.Keyword.DEVOUR):
						_devour(ms, behind)
			if f.has(Face.Keyword.BURN):
				Effects.stack(foe, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", ceili(float(dmg) / BURN_DAMAGE_PER_STACK))
				_foe_gained_status(foe, "burning")
			if f.has(Face.Keyword.SUPPRESS):
				_suppress(foe)
		total += landed
		rolled_total += rolled
		any_crit = any_crit or crit
	if extra_burn > 0:
		Effects.stack(target, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", extra_burn)
		_foe_gained_status(target, "burning")
	last_roll = {"mech": mech_index, "target": target, "rolled": rolled_total, "final": total, "crit": any_crit, "ranged": f.is_ranged()}
	var how := f.describe()
	if any_crit:
		how = "CRIT " + how
	elif f.is_ranged():
		how = "rolled %d, " % rolled_total + how
	log.append("%s hits %s for %d (%s)" % [ms.unit.display_name, target.display_name, total, how])
	if vented_all > 0:
		log.append("%s fires its heat: -%d, +%d to the blow" % [ms.unit.display_name, vented_all, fired])
	var was_front := target.rank == 0
	# A kill clears the slot at once (Ryan, 22 September): burning a hole through the front
	# opens the back rank to line and melee until reinforcements plug it.
	_clear_dead()
	if reach_of(ms, f) == Face.Reach.INDIRECT and was_front:
		var splash := ceili(float(total) / DANGER_CLOSE_DIVISOR)
		ms.unit.shield = maxi(0, ms.unit.shield - splash)
		log.append("%s: splash, shield -%d" % [ms.unit.display_name, splash])
	if vent > 0:
		ms.heat = maxi(0, ms.heat - vent)
	_add_heat(ms, heat_total)
	# Chain: a kill repeats the attack on a new valid target, heat and all (the heat is the
	# risk, and a laser is telegraphed), until it misses a kill.
	if f.has(Face.Keyword.CHAIN) and not target.alive():
		for cand in targets_for(mech_index):
			if cand.alive() and cand != target:
				log.append("%s chains to %s" % [ms.unit.display_name, cand.display_name])
				_resolve_attack(mech_index, ms, f, cand)
				break


## The Prairie Dog's screen on a withdrawal (28 September; built 30 September): a machine with
## the passive is out before the enemy strikes, every other live machine rolls the screen's
## chance on the skirmish's die to slip out with it, and a blow aimed at a covered machine
## is lost rather than retargeted. Nothing happens without a screener.
func _screen_cover() -> void:
	_screened.clear()
	var chance := 0
	for ms in live_mechs():
		chance = maxi(chance, Effects.screen_chance(ms.unit))
	if chance <= 0:
		return
	var names: Array[String] = []
	for ms in live_mechs():
		if Effects.screen_chance(ms.unit) > 0 or rng.randi_range(1, 100) <= chance:
			_screened.append(ms)
			names.append(ms.unit.display_name)
	log.append("the static screen covers %s" % ", ".join(names))


## Hull lost to a blow or a bite: the on_hull_damage passives fire (the Nemesis's Crucible
## stacks Overheating). Never for the round's overheat burn, which would feed itself.
func _hull_damaged(ms: MechState) -> void:
	var gained := Effects.hull_damaged(ms.unit)
	if not gained.is_empty():
		log.append("%s: %s from the hit" % [ms.unit.display_name, ", ".join(gained)])


## Shocked (the Armadillo's retaliation, 28 September; built 29 September): the foe that struck
## carries one shock, never more, until a blow spends it double. A machine's loop passive
## may catch the status like any other.
func _shock(foe: Foe, by: MechState) -> void:
	if not foe.alive() or Effects.has(foe, "shocked"):
		return
	Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	log.append("%s shocks %s" % [by.unit.display_name, foe.display_name])
	_foe_gained_status(foe, "shocked")


## Devour (the Ammit's talons, 28 September; built 29 September): a kill with the component
## feeds its owner a stack of Overcharged for the skirmish, one per foe killed (a spread that
## kills two feeds two, a chain feeds on every link). The stacks tick down one a round at the
## round's end, the way Overheating does, so the ramp fades unless a passive keeps it.
func _devour(ms: MechState, foe: Foe) -> void:
	var m: Effects.Modifier
	if Effects.keeps(ms.unit, "overcharged"):
		# The Ammit's Quintessence Tap: what the talons take is kept, for the battle, never fading.
		m = Effects.stack(ms.unit, Effects.STATUS["overcharged"], Effects.BATTLE, "devour", 1, Effects.DECAY_NONE)
	else:
		m = Effects.stack(ms.unit, Effects.STATUS["overcharged"], Effects.SKIRMISH, "devour", 1, Effects.DECAY_TICK)
	log.append("%s devours %s: %s ×%d" % [ms.unit.display_name, foe.display_name, m.name, Effects.stacks_of(ms.unit, "overcharged")])


## Suppress: the foe skips its action this round, then grows Numbed (two stacks, three for
## a massive foe). It resists at its own base resistance plus 10% a stack, on the
## skirmish's own die (Ryan, 26 September): a suppress it shrugs off does nothing at all
## and numbs it no further, and Numbed loses a stack at each of the foe's turns, so a stun
## repeated on one foe stops landing while stuns spread across the formation keep working.
func _suppress(foe: Foe) -> bool:
	var resist := foe.resist_total()
	if resist > 0 and rng.randi_range(1, 100) <= resist:
		log.append("%s shrugs off the suppression (%d%% resistant)" % [foe.display_name, resist])
		return false
	# A foe that has already acted this turn loses its next action instead of one it has taken.
	Effects.grant_for_rounds(foe, Effects.STATUS["suppressed"], "mech", round + 1 if _acted.has(foe) else round)
	Effects.stack(foe, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", NUMBED_PER_SUPPRESS_MASSIVE if foe.is_massive() else NUMBED_PER_SUPPRESS, Effects.DECAY_TICK)
	return true


## A foe has just gained a status (whoever applied it): every live machine's on_foe_status
## passives get their roll, the first that lands suppressing the foe (the Baboon's Pocket
## Paradox, 28 September). Never for Suppressed or Numbed themselves, or the loop would feed
## itself; a foe already suppressed or dead has nothing to lose.
func _foe_gained_status(foe: Foe, status_id: String) -> void:
	if status_id == "suppressed" or status_id == "numbed" or not foe.alive() or foe.is_suppressed():
		return
	for ms in live_mechs():
		var chance := Effects.foe_status_suppress_chance(ms.unit)
		if chance <= 0 or rng.randi_range(1, 100) > chance:
			continue
		log.append("%s got trapped in a paradox! (%s, %d%%)" % [foe.display_name, ms.unit.display_name, chance])
		_suppress(foe)
		return


## The taunt and beacon keywords on a shield or vent component (decided 28 September: damage
## redirection is common, not locked): whoever it was spent on draws a rank of foes for the
## round, taunt the front and beacon the back, and every foe of that rank on the field turns
## on it now, intents and all. The status is the record; the retarget is the act.
func _draw_with(who: MechState, f: Face) -> void:
	for pair in [[Face.Keyword.TAUNT, "taunt", 0], [Face.Keyword.BEACON, "beacon", 1]]:
		if not f.has(pair[0]):
			continue
		var src := "draw:" + f.component if not f.component.is_empty() else "draw"
		Effects.grant_buff(who.unit, pair[1], 1, src, round)
		_retarget_rank(pair[2], who)


## Every live foe of a rank on the field turns on one machine, now. Massive foes stand in
## both ranks and follow either draw.
func _retarget_rank(rank: int, who: MechState) -> void:
	var turned := 0
	for f in field_foes():
		if not f.alive() or (f.rank != rank and not f.is_massive()) or f.target == who:
			continue
		f.target = who
		turned += 1
	if turned > 0:
		log.append("the %s rank turns on %s (%d)" % ["front" if rank == 0 else "back", who.unit.display_name, turned])


## The cleanse keyword on a shield or vent component: whoever it was spent on loses every
## cleansable status (a foe's disable, Corrupted, Overheating), and the log says which.
func _cleanse_with(ms: MechState, who: MechState, f: Face) -> void:
	if not f.has(Face.Keyword.CLEANSE):
		return
	var gone := Effects.cleanse(who.unit)
	if gone.is_empty():
		log.append("%s cleanses %s: nothing to clear" % [ms.unit.display_name, who.unit.display_name])
	else:
		log.append("%s cleanses %s: %s cleared" % [ms.unit.display_name, who.unit.display_name, ", ".join(gone).to_lower()])


## A corrupted entry's bite against a shield and a hull: shield first, whole, then hull,
## never armoured and never an injury. Shared by the real bite and the forecast.
static func _bite(shield: int, hull: int, amount: int) -> Dictionary:
	var absorbed := mini(shield, amount)
	return {"shield": shield - absorbed, "hull": hull - (amount - absorbed)}


## Heat only climbs here, past the maximum too. It burns at the end of the round (Ryan,
## 22 September: every overheat lands at once, never as a spike when a component is spent),
## so a machine run hot can still be vented before it pays.
func _add_heat(ms: MechState, amount: int) -> void:
	if amount > 0:
		ms.heat += amount


## The end of the round: heat above the maximum burns hull one for one and the gauge
## settles at its cap.
func _settle_heat() -> void:
	for ms in live_mechs():
		var over := ms.heat - ms.heat_max
		if over <= 0:
			continue
		ms.unit.hull -= over
		ms.heat = ms.heat_max
		overheats.append({"mech": mechs.find(ms), "over": over, "hull": ms.unit.hull})
		log.append("%s overheats: hull -%d" % [ms.unit.display_name, over])


## One blow. Decided 18 September: a standing shield blocks the whole blow, however small the
## shield and however big the blow; nothing bleeds through (unless the foe breaches, then the
## excess reaches the hull). A blow on bare hull loses the chassis's armour first, so small
## hits bounce off a heavy machine. Only a bare-hull blow can injure a component, and only
## when what gets through is at least a quarter of max hull. Shield before a telegraphed
## blow is the counterplay; a double strike is how a foe gets past it.
func _damage_mech(ms: MechState, amount: int, source: Foe) -> void:
	amount = Effects.damage_taken(ms.unit, amount)   # buffs and debuffs on damage taken, before shield and armour
	var r := _blow(ms.unit.shield, ms.unit.hull_max, ms.unit.armour + Effects.armour_against(ms.unit, source.rank), amount, source.breaches())
	var had_shield := ms.unit.shield > 0
	ms.unit.shield = r["shield"]
	ms.unit.hull -= r["through"]
	# The mech's gauges after the blow ride along, so a replay can step them down blow by blow.
	turn_events.append({"foe": source, "mech": mechs.find(ms), "absorbed": r["absorbed"], "through": r["through"],
		"blocked": r["blocked"], "broke_shield": had_shield and ms.unit.shield == 0, "injured": r["injures"],
		"shield": ms.unit.shield, "hull": ms.unit.hull})
	if r["blocked"]:
		log.append("%s hits %s: shield -%d, blocked" % [source.display_name, ms.unit.display_name, r["absorbed"]])
	elif r["absorbed"] > 0:
		log.append("%s breaches %s: shield -%d, hull -%d" % [source.display_name, ms.unit.display_name, r["absorbed"], r["through"]])
	elif r["through"] == 0:
		log.append("%s hits %s: armour holds" % [source.display_name, ms.unit.display_name])
	else:
		log.append("%s hits %s: hull -%d%s" % [source.display_name, ms.unit.display_name, r["through"], " (armour -%d)" % r["armoured"] if r["armoured"] > 0 else ""])
	if int(r["through"]) > 0:
		_hull_damaged(ms)
	if r["injures"]:
		apply_injury(ms)


## The arithmetic of one blow against a shield, hull max and armour, shared by the real hit
## and the forecast. Returns shield after, absorbed, through (to hull), armoured (taken off
## by armour), blocked (a standing shield took it all), injures (bare hull, over threshold).
static func _blow(shield: int, hull_max: int, armour: int, amount: int, breach: bool) -> Dictionary:
	var absorbed := 0
	var through := 0
	var blocked := false
	var bare := shield <= 0
	if bare:
		through = amount
	elif breach:
		absorbed = mini(shield, amount)
		through = amount - absorbed
	else:
		absorbed = mini(shield, amount)
		blocked = true
	var armoured := 0
	if through > 0 and bare:
		armoured = mini(armour, through)
		through -= armoured
	# Injury is about hull lost in one blow, wherever it came from: a breach that overflows a
	# quarter of the hull injures too (Ryan, 18 September: breach is the release valve, and its
	# counterplay is not the shield).
	var injures := through > 0 and through * 100 >= hull_max * CRACK_MIN_HULL_PCT
	return {"shield": shield - absorbed, "absorbed": absorbed, "through": through, "armoured": armoured, "blocked": blocked, "injures": injures}


## The injury rolls the die and hits the component it lands on. An intact component cracks:
## keywords, crit and unique effect are gone, the basic action stays. A cracked component is
## destroyed: blank. A destroyed component or an empty hardpoint takes the blow and nothing
## happens, so a mech with little left to break shrugs off more of them. The damage lives on
## the unit and persists until repaired in the hangar. (Decided 17 September: one threshold,
## one roll.) A passive may say no_destroy on_injury: then a cracked component holds.
func apply_injury(ms: MechState) -> void:
	if ms.die.faces.is_empty():
		return
	var idx := ms.die.roll(rng)
	var f := ms.die.faces[idx]
	if f.kind == Face.Kind.BLANK:
		log.append("%s: the blow lands on %s; nothing left to break" % [ms.unit.display_name, "an empty hardpoint" if f.empty else "a destroyed component"])
		return
	var originals: Dictionary = ms.unit.damaged_faces
	var what := f.describe()
	if f.cracked:
		if Effects.no_destroy(ms.unit, f):
			log.append("%s: %s holds, cracked but not destroyed" % [ms.unit.display_name, what])
			return
		var d := Face.blank()
		d.component = f.component
		ms.die.faces[idx] = d
		log.append("%s: a cracked component is destroyed (%s)" % [ms.unit.display_name, what])
	else:
		originals[idx] = f.duplicate_face()
		var c := f.duplicate_face()
		c.crack()
		ms.die.faces[idx] = c
		log.append("%s: a component cracks (%s)" % [ms.unit.display_name, what])


## Whom a foe strikes: the machine drawing its rank if one is (a taunt or beacon standing),
## else the weakest shield, then the weakest hull. Asked with no foe, the plain pick.
func _pick_mech_target(f: Foe = null) -> MechState:
	if f != null:
		for ms in live_mechs():
			if Effects.draws_rank(ms.unit, f.rank) or (f.is_massive() and Effects.draws_rank(ms.unit, 1)):
				return ms
	var best: MechState = null
	for ms in live_mechs():
		if best == null \
				or ms.unit.shield < best.unit.shield \
				or (ms.unit.shield == best.unit.shield and ms.unit.hull < best.unit.hull):
			best = ms
	return best


# ---------------------------------------------------------------- formation

func _clear_dead() -> void:
	for col in range(columns):
		for rank in [front, back]:
			var f: Foe = rank[col]
			if f != null and not f.alive():
				if f.rank >= 0:
					log.append("%s destroyed" % f.display_name)
				f.rank = -1
				rank[col] = null


## The reinforcement phase. Ranks hold: a front foe only ever stands in the front, a back
## foe only in the back, so the question "how is that ghoul hitting me from the back row"
## never comes up. Massive foes need a whole empty column and take both slots. Empty slots
## fill left to right, front rank first, each taking a random foe of the right rank from
## those waiting; the rest keep waiting.
func _reinforce(random: bool = true) -> void:
	var placed := 0
	for col in range(columns):
		if front[col] == null and back[col] == null:
			var i := _reinforcement_index_massive()
			if i >= 0:
				var f: Foe = reinforcements.pop_at(i)
				_place(f, 0, col)
				back[col] = f
				placed += 1
	var slots: Array = []
	for col in range(columns):
		if front[col] == null:
			slots.append([0, col])
		if back[col] == null:
			slots.append([1, col])
	for slot in slots:
		var want_back: bool = slot[0] == 1
		var choices: Array = []
		for i in range(reinforcements.size()):
			if not reinforcements[i].is_massive() and reinforcements[i].prefers_back == want_back:
				choices.append(i)
		if choices.is_empty():
			continue
		var f: Foe = reinforcements.pop_at(choices[rng.randi_range(0, choices.size() - 1)] if random else choices[0])
		_place(f, slot[0], slot[1])
		placed += 1
	if placed > 0 and round > 0:
		log.append("%d reinforcement%s step%s in" % [placed, "s" if placed != 1 else "", "" if placed != 1 else "s"])


func _reinforcement_index_massive() -> int:
	for i in range(reinforcements.size()):
		if reinforcements[i].is_massive():
			return i
	return -1


func _place(f: Foe, rank: int, col: int) -> void:
	f.rank = rank
	f.column = col
	if rank == 0:
		front[col] = f
	else:
		back[col] = f


func _check_outcome() -> void:
	if live_mechs().is_empty():
		outcome = Outcome.DEFEAT
		_finish()
	elif field_foes().is_empty() and reinforcements.is_empty():
		outcome = Outcome.VICTORY
		_finish()


## Damaged components are NOT restored here: they are repaired in the hangar. Skirmish-long
## and timed effects end.
func _finish() -> void:
	state = State.DONE
	for ms in mechs:
		Effects.end_skirmish(ms.unit)

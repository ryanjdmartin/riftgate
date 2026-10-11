class_name Skirmish
extends RefCounted

## The dice skirmish. Mechs have no positions. Enemies stand in a two-rank, four-column
## formation fed from the reinforcements, so a horde keeps coming. The rules are docs/rules.md's.
##
## Round loop:
##   start_round()       passive cooling, roll every live mech's die, telegraph foe intents
##   reroll([...])       up to REROLLS_PER_ROUND times, any subset of unspent mech dice,
##                       before or after spending others: a low damage roll is information;
##                       a reroll always lands on a different face (see Die.reroll)
##   assign(i, target)   spend a mech's face on a foe (attacks) or a mech (shield, vent);
##                       a rolled face rolls its damage here, immediately and visibly
##                       a kill clears its slot at once; a decided fight ends at once
##   end_round()         the player's turn ends: heat over the cap burns hull; then burn
##                       ticks, foes act, the dead are cleared, mech statuses tick
##                       (overheating), the reinforcements refill, outcome is checked
##   can_withdraw()      at any point of the player's turn
##
## The player's damage is in fives, everything else in tens. Enemy damage is static; only
## the player's rolled faces roll.

enum State { SETUP, ROUND_START, ASSIGN, DONE }
enum Outcome { NONE, VICTORY, DEFEAT, WITHDRAWN }

const DEFAULT_COLUMNS := 4   # the formation's width (Ryan, 23 September: four plays better than three)
const REROLLS_PER_ROUND := 3
const DANGER_CLOSE_DIVISOR := 2
const BURN_DAMAGE_PER_STACK := 10   # damage dealt per stack applied (halved 2 October with the player's damage)
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
var destroyed: int = 0   # components destroyed this fight, for the balance runner (the hangar's destroyed-is-gone rule, bible section 10, depends on the rate)
var log: Array[String] = []

## The most recent attack, for the screen to show: {mech, target, rolled, final, melee}; melee
## (the tag) is how the screen animates it, a lunge in place of a kick back.
var last_roll: Dictionary = {}
## What each reach did this fight, for the balance runner's reach table (tools/balance.gd):
## by reach name, the spends, the hull its blows took off foes, the spends aimed at the back
## rank, the heat paid and the shield lost to danger close. Never read by the game.
var reach_tally: Dictionary = {}
## The same by the shape of the number (rolled or flat), and the damage the foes dealt by
## the rank they struck from. The runner's alone.
var class_tally: Dictionary = {}
var taken_by_rank: Dictionary = {}
var _chaining := false
## Every blow of the last enemy turn, in order, for the screen to replay:
## {foe, mech (index), absorbed, through, blocked, broke_shield, injured, shield, hull,
## seq, name, boss}. `seq` orders it among the turn's specials; `name` is the move's shown
## name and `boss` whether a massive foe struck, for the plaque (decided 9 October).
var turn_events: Array = []
## Every special of the last enemy turn (a defend, buff or debuff in place of a blow), for
## the screen to announce on its plaque in order: {foe, name, kind, seq}.
var turn_specials: Array = []
var _seq: int = 0   # the order of the turn's blows and specials, shared by both lists
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
## Rerolls a foe's roar has cost the team for the coming round.
var reroll_debt: int = 0
## Makes a foe from a content id, for a summoning action; set by the battle (the content
## database), left empty by tests, in which case a summon calls nothing up.
var foe_factory: Callable = Callable()
## The targeting rule: empty for the aims (decided 2 October), "lowest" for the rule before
## it (every foe on the machine with the lowest shield, then the lowest hull), kept for the
## balance runner's comparison and nothing else.
var targeting_override: String = ""
## The shared pick of a rank that fires as one this round, by rank; cleared as the round opens.
var _focus: Dictionary = {}
## A machine runs hot, for a foe's condition, from this much heat on.
const HOT_HEAT := 20
## Foe effects that act on nobody in particular, so a lure has nothing to turn.
const UNTARGETED_EFFECTS := ["harden", "regrow", "revive_once", "summon", "rally", "drain_rerolls", "heat_all", "corrupt_all"]


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
	# Passives that fire once as the fight begins.
	for ms in live_mechs():
		_fired(ms, Effects.fire(ms.unit, "on_skirmish_start"), "as the fight begins")


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
	var added: int = Effects.attack(ms.unit, f, 0, f.heat)["heat"]
	return added - ms.heat if f.vents_all else added


## What a vent-on-fire attack adds to every blow from the heat it fires: its power_per_heat
## for each 10 heat the machine carries right now (the Afterburner Cannon, 28 September).
func heat_bonus(ms: MechState, f: Face) -> int:
	if f == null or not f.vents_all:
		return 0
	return f.power_per_heat * int(ms.heat / 10)


## The loads one shot of a hopper-firing attack takes (fires_hopper, the Bullion Fragmenter,
## 11 October): as many as the machine's hopper holds, up to the shot's most, so a full
## hopper feeds several shots rather than one. Read as the die is spent.
static func hopper_loads(u, f: Face) -> int:
	if f == null or f.fires_hopper <= 0:
		return 0
	return mini(Effects.stacks_of(u, "hopper"), f.fires_hopper)


## What the hopper adds to every blow of that shot.
static func hopper_bonus(u, f: Face) -> int:
	return hopper_loads(u, f) * f.power_per_load if f != null else 0


## What one blow of an attack entry will deal, as the die shows it (decided 10 October, bible
## section 5: the game does the arithmetic and the player reads it): [low, high], equal for a
## flat entry. Without a target, every source that needs none: the pipeline's adds and
## multiplies, the heat a vent-on-fire shot fires, a raised ceiling. Over a foe, what it deals
## to that foe: its missing hull, conditions on it (a status it carries), and its armour off
## the blow. A shock is left out, the foe's own chip, and spent by the first blow of many.
## `f` is the entry as this machine's passives make it (shown_face); [0, 0] for no attack.
func shown_number(ms: MechState, f: Face, target: Foe = null) -> Array[int]:
	if f == null or not f.is_attack():
		return [0, 0]
	var add := heat_bonus(ms, f) + f.missing_bonus(target) + hopper_bonus(ms.unit, f)
	var out: Array[int] = []
	for v in [f.power, f.power_max]:
		var d := int(Effects.attack(ms.unit, f, v + add, 0, target)["damage"])
		if target != null:
			d = maxi(0, d - target.armour_total())
		out.append(d)
	return out


## The shown number as the die prints it: one number, or the range.
func shown_number_text(ms: MechState, f: Face, target: Foe = null) -> String:
	if f == null or not f.is_attack():
		return f.number_text() if f != null else ""
	var n := shown_number(ms, f, target)
	return str(n[0]) if n[0] == n[1] else "%d–%d" % [n[0], n[1]]


## Every live machine learns how many allies stand with it, for passives that read it.
func _refresh_allies() -> void:
	var n := live_mechs().size()
	for ms in mechs:
		ms.unit.allies = maxi(0, n - 1) if ms.alive() else 0


## The foes that will strike this mech when the round ends, in the order they act: alive,
## not suppressed, aimed at it with an attack (a foe folding, rallying or roaring lands no
## blow), and not about to die to burn first.
func attackers_of(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	for f in acting_on(ms):
		if f.attacks():
			out.append(f)
	return out


## Every foe that will act on this mech when the round ends, whatever its action: alive, not
## suppressed, aimed at it, not about to die to burn first.
func acting_on(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	for f in field_foes():
		if not f.alive() or f.is_suppressed() or f.target != ms:
			continue
		if f.hp - int(Effects.tick_preview(f)["hp"]) <= 0:   # burns to death before it strikes
			continue
		out.append(f)
	return out


## Heat the foes will add to this mech after the player's turn has burnt its own: a stack
## of Overheating per scorching blow, ticking at the round's end, and a stoking debuff's heat
## outright. It waits on the gauge for the next turn.
func scorch_incoming(ms: MechState) -> int:
	var per_stack := int(Effects.STATUS["overheating"]["effects"][0]["value"])
	var stacks := 0
	var heat := 0
	for f in acting_on(ms):
		if f.attacks() and f.has_keyword(f.action, "scorch"):
			stacks += f.strikes()
		elif str(f.action.get("effect", "")) == "add_heat":
			heat += int(f.action.get("value", 0))
	# A move that heats every machine counts whoever it is aimed at.
	for f in field_foes():
		if f.alive() and not f.is_suppressed() and str(f.action.get("effect", "")) == "heat_all" and f.hp - int(Effects.tick_preview(f)["hp"]) > 0:
			heat += int(f.action.get("value", 0))
	return stacks * per_stack + heat


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
	return spend_bite(ms.unit, f)


## The hull a volatile entry costs its owner per spend; zero for any other entry.
static func volatile_cost(f: Face) -> int:
	return VOLATILE_BITE if f != null and f.has(Face.Keyword.VOLATILE) else 0


## The hull spending this entry costs its owner: a volatile bite, and a passive's price on
## every component spent (hull_per_spend; never on a blank, which is no component).
static func spend_bite(u, f: Face) -> int:
	if f == null:
		return 0
	var tithe := 0 if f.kind == Face.Kind.BLANK else Effects.hull_per_spend(u)
	return volatile_cost(f) + tithe


## What the end of the round does to this mech if nothing else changes: the screen's warning
## signs and bar overlays. Recomputed after every action, so shielding or killing an attacker
## moves the numbers at once. `with_face` counts the heat of the die's showing component as
## if spent; the screen asks for that only while the die is being dragged. `extra_shield`
## asks the same question with that much more shield standing (a shield component about
## to be spent here), for whoever weighs one; `overshield` lets it pass the maximum, as a
## component with that keyword would.
func forecast(ms: MechState, with_face: bool = true, extra_shield: int = 0, overshield: bool = false) -> Dictionary:
	var shield := ms.unit.shield + extra_shield if overshield else mini(maxi(ms.unit.shield_max, ms.unit.shield), ms.unit.shield + extra_shield)
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
	# Heat: what the gauge holds (past the cap, if the turn ran hot) and the face's own if
	# asked burns at the end of the player's turn, before the enemy acts (11 October). The
	# heat the foes and the Overheating tick add comes after the burn, onto the gauge for the
	# next turn, where a vent can still take it off.
	var heat_end := ms.heat + (pending_heat(ms) if with_face else 0)
	var over := maxi(0, heat_end - ms.heat_max)
	hull -= over
	var heat_after := mini(heat_end, ms.heat_max) + int(Effects.tick_preview(ms.unit)["heat"]) + scorch_incoming(ms)
	return {
		"incoming": incoming,
		"bite": bite,
		"volatile": volatile,
		"shield_after": shield,
		"hull_after": hull,
		"heat_end": heat_end,       # the gauge as the turn ends, uncapped: what the burn reads
		"heat_after": heat_after,   # the gauge after the round: settled at the cap, then the foes' heat
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
	# Reach: direct hits the front and any exposed column's back; indirect hits everyone.
	# A foe already killed this round still stands until the dead are cleared, but it is
	# no target: a die spent on it would be wasted.
	for col in range(columns):
		if front[col] != null and front[col].alive() and not out.has(front[col]):
			out.append(front[col])
		if back[col] == null or not back[col].alive() or out.has(back[col]):
			continue
		if reach_of(ms, f) == Face.Reach.INDIRECT or is_exposed(col):
			out.append(back[col])
	return out


## A component's reach as it is right now: its own, unless the mech's passive says
## otherwise while a condition holds (a passive's set_reach). Computed on
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
	rerolls_left = maxi(0, REROLLS_PER_ROUND - reroll_debt)   # a roar last round costs rerolls now
	if reroll_debt > 0:
		log.append("the roar costs the team %d reroll%s" % [reroll_debt, "" if reroll_debt == 1 else "s"])
	reroll_debt = 0
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
		_fired(ms, Effects.round_start(ms.unit, ms.heat), "round start")
	# Every foe announces its move for the round: which action, at whom. Chosen now, before
	# the player acts, so the intent chips and the forecast are exact. The move first, from
	# the ones its conditions allow (never the same special twice running), then the pick by
	# the move's aim, each foe on its own; a rank that fires as one shares its pick.
	_focus.clear()
	_refresh_kin()
	for f in field_foes():
		_choose_foe_action(f)
		f.target = _pick_mech_target(f)
	state = State.ASSIGN


## The moves a foe may announce this round: those whose conditions hold, less the special
## it announced last round when anything else is open (a special never fires twice running,
## so the swing after the roar can be counted on). Nothing legal falls back to its blow.
func legal_actions(f: Foe) -> Array:
	var legal: Array = []
	for a in f.actions:
		if _when_holds(f, a):
			legal.append(a)
	if legal.size() > 1 and not f.last_special.is_empty():
		var kept: Array = []
		for a in legal:
			if Foe.is_attack_action(a) or str(a.get("id", "")) != f.last_special:
				kept.append(a)
		if not kept.is_empty():
			legal = kept
	if legal.is_empty():
		for a in f.actions:
			if Foe.is_attack_action(a):
				legal.append(a)
	return legal


func _choose_foe_action(f: Foe) -> void:
	f.choose_from(legal_actions(f), rng)
	f.last_special = "" if f.attacks() else str(f.action.get("id", ""))


## Does a move's condition hold right now? One word or a list meaning any (Foe.WHENS).
func _when_holds(f: Foe, a: Dictionary) -> bool:
	var whens := Foe.whens_of(a)
	if whens.is_empty():
		return true
	for w in whens:
		if _when_word_holds(f, a, str(w)):
			return true
	return false


func _when_word_holds(f: Foe, a: Dictionary, w: String) -> bool:
	match w:
		"below_half":
			return f.hp * 2 <= f.hp_max
		"missing_hull":
			return f.hp <= f.hp_max - maxi(1, int(a.get("value", 0)))
		"few_waiting":
			# Fewer than two of the foe a summon calls (or of anyone, when it names none) wait.
			var who := str(a.get("foe", ""))
			var n := 0
			for r in reinforcements:
				if who.is_empty() or r.content_id == who:
					n += 1
			return n < 2
		"rerolls_left":
			return reroll_debt < REROLLS_PER_ROUND
		"machine_hot":
			for ms in live_mechs():
				if ms.heat >= HOT_HEAT:
					return true
			return false
		"machine_armed":
			return not _armed_mechs().is_empty()
		"back_behind":
			if f.rank != 0 or f.column < 0 or f.column >= columns:
				return false
			var behind: Foe = back[f.column]
			return behind != null and behind != f and behind.alive()
		"others_on_field":
			for o in field_foes():
				if o != f and o.alive():
					return true
			return false
	return true


## The live machines showing an intact weapon: what a foe that aims at the armed looks for.
func _armed_mechs() -> Array[MechState]:
	var out: Array[MechState] = []
	for ms in live_mechs():
		var face := ms.face()
		if face != null and face.is_attack() and not face.cracked:
			out.append(ms)
	return out


## Every foe on the field learns how many of its kind stand with it, for a swarm blow. Kept
## current as foes fall and step in, so the intent chips drop as the pack thins.
## A foe that splits (the Gel): destroyed, so many of the named foe step into the pool
## under its pack, made by the battle's content; without a factory nothing steps in.
func _split(f: Foe) -> void:
	if f.on_death.is_empty() or not foe_factory.is_valid():
		return
	var who := str(f.on_death.get("summon", ""))
	var count := maxi(1, int(f.on_death.get("count", 1)))
	var made := 0
	for i in range(count):
		var n = foe_factory.call(who)
		if n is Foe:
			n.pack_id = f.pack_id
			reinforcements.append(n)
			made += 1
	if made > 0:
		log.append("%s splits: %d %s step into the pool" % [f.display_name, made, who])


func _refresh_kin() -> void:
	var live := field_foes()
	for f in live:
		var n := 0
		for o in live:
			if o != f and o.alive() and _same_kind(o, f):
				n += 1
		f.kin = n


static func _same_kind(a: Foe, b: Foe) -> bool:
	if not a.content_id.is_empty() or not b.content_id.is_empty():
		return a.content_id == b.content_id
	return a.display_name == b.display_name


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
		_reroll_die(live[0])
		log.append("%s rerolls its own die for free" % live[0].unit.display_name)
		return true
	if rerolls_left <= 0:
		return false
	for ms in live:
		_reroll_die(ms)
	rerolls_left -= 1
	return true


## One die rerolled: never the same entry, unless a foe scrambled it, in which case it lands
## anywhere and the scramble is spent.
func _reroll_die(ms: MechState) -> void:
	if Effects.is_scrambled(ms.unit):
		ms.face_index = ms.die.roll(rng)
		Effects.remove(ms.unit, "scrambled")
		log.append("%s's reroll is scrambled" % ms.unit.display_name)
		return
	ms.face_index = ms.die.reroll(rng, ms.face_index)


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
## Whether die `mech_index` may be spent on `target` now (a Foe for an attack, a MechState or
## null for equipment): the checks `assign` makes before it acts, changing nothing. The
## screen asks it while a die is dragged, for the hover over a valid target.
func can_assign(mech_index: int, target) -> bool:
	if state != State.ASSIGN or mech_index < 0 or mech_index >= mechs.size():
		return false
	var ms := mechs[mech_index]
	if not ms.alive() or ms.assigned or ms.face() == null:
		return false
	var f := Effects.effective_face(ms.unit, ms.face())
	if f.is_attack():
		return target is Foe and targets_for(mech_index).has(target)
	if f.is_equipment():
		return equipment_targets_for(ms, f).has(target if target is MechState else ms)
	return false


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
		log.append("%s: %s %s, hull -%d" % [ms.unit.display_name, f.describe(), "is volatile" if f.has(Face.Keyword.VOLATILE) else "pays its tithe", volatile])
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
			_gain_shield(who, f.power, f.has(Face.Keyword.OVERSHIELD))
			log.append("%s shields %s for %d%s" % [ms.unit.display_name, who.unit.display_name, f.power, " (past its maximum)" if who.unit.shield > who.unit.shield_max else ""])
			if who != ms:
				_shield_granted(ms, who, f.power)
			_cleanse_with(ms, who, f)
		Face.Kind.VENT:
			var who: MechState = target if target is MechState else ms
			who.heat = maxi(0, who.heat - f.power)
			log.append("%s vents %s by %d" % [ms.unit.display_name, who.unit.display_name, f.power])
			_cleanse_with(ms, who, f)
		Face.Kind.BUFF:
			# Equipment that grants a status for the round (or more): the pipeline reads it
			# like any modifier, and end_round lets it go.
			var who: MechState = target if target is MechState else ms
			var until := round + f.buff_rounds - 1
			var src := "buff:" + f.component if not f.component.is_empty() else "buff"
			var stacks := _stacks_from(ms, f.buff_status, f.buff_stacks)
			var m := Effects.grant_buff(who.unit, f.buff_status, stacks, src, until)
			if m != null:
				log.append("%s buffs %s: %s ×%d%s" % [ms.unit.display_name, who.unit.display_name, m.name, stacks, "" if f.buff_rounds == 1 else " for %d rounds" % f.buff_rounds])
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
	_end_player_turn()
	if outcome != Outcome.NONE:
		return outcome   # the burn wrecked the last machine: the enemy never acts
	_enemy_turn()
	_tick_mechs()
	_trim_overshield()
	_reinforce(true)    # the reinforcement phase: a random waiting foe of the right rank per empty slot
	_refresh_allies()
	_check_outcome()
	if outcome == Outcome.NONE:
		state = State.ROUND_START
	return outcome


## The end of the player's turn (Ryan, 11 October): heat over the maximum burns hull now,
## before the enemy acts, so an overheat is the machine's own doing on its own turn, like a
## volatile bite. A machine it wrecks is gone before the enemy strikes, and a fight it
## decides ends here. Heat a foe adds lands after it, so it waits on the gauge for the
## next turn, where a vent or a cleanse can answer it. Shared by END TURN and a withdrawal.
func _end_player_turn() -> void:
	overheats.clear()
	_settle_heat()
	_refresh_allies()
	_check_outcome()


## The enemy's turn: every foe on the field acts in order, statuses tick, timed effects run
## out. Shared by the end of a round and by a withdrawal.
func _enemy_turn() -> void:
	turn_events.clear()
	turn_specials.clear()
	_seq = 0
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
		if not f.attacks():
			_foe_acts(f, t)   # a defend, buff or debuff instead of a blow
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
		if f.has_keyword(f.action, "self_destruct") and f.alive():
			# The blow spends the striker (the Bomb): it dies whole and never gets back up.
			f.hp = 0
			f.stays_down = true
			log.append("%s bursts, and is gone" % f.display_name)
	_acted.clear()
	_clear_dead()
	for ms in mechs:
		Effects.end_round(ms.unit, round)   # timed effects run out
	for f in field_foes():
		Effects.end_round(f, round)


## The round ends with the machines' statuses ticking, after the enemy has struck: an
## Overheating stack adds its heat to the gauge now, and that heat burns only at the end of
## the next player's turn (11 October), after the cooling, so a vent or a cleanse answers it.
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
	# Leaving ends the player's turn, so the heat burns first (Ryan, 11 October): running hot
	# and then withdrawing is no way round an overheat.
	_end_player_turn()
	if outcome != Outcome.NONE:
		return true   # burnt out on the way: the fight is lost, and the enemy never strikes
	_screen_cover()
	_enemy_turn()
	_screened.clear()
	outcome = Outcome.DEFEAT if live_mechs().is_empty() else Outcome.WITHDRAWN
	_finish()
	if outcome == Outcome.WITHDRAWN:
		log.append("Withdrew at the end of round %d" % round)
	return true


# ---------------------------------------------------------------- resolution

## Spend an attack: every strike is its own blow (its own roll, its own keywords and
## passives), landing on every foe the component reaches. Heat is paid once per
## use; danger close is charged on the total.
func _resolve_attack(mech_index: int, ms: MechState, f: Face, target: Foe) -> void:
	var reach := reach_of(ms, f)
	var aimed_back := target.rank == 1
	var dealt := 0             # hull the blows took off every foe they reached, for the reach tally
	var total := 0
	var rolled_total := 0
	var heat_total := 0
	var vent := 0
	var extra_burn := 0
	var armoured_total := 0   # what the primary target's armour took off, for the log
	var touched: Array = []    # every foe the blows reached and left alive, for a lure or a disrupt
	var gained := {}           # foe -> the statuses this spend put on it, told once each at the end (an application, never a stack or a strike)
	# A vent-on-fire attack fires the machine's whole heat into the blow: its bonus is read
	# now and the gauge is emptied once the strikes have landed.
	var fired := heat_bonus(ms, f)
	var missing := f.missing_bonus(target)   # what the target's lost hull adds, read once as the die is spent
	var loads := hopper_loads(ms.unit, f)   # the loads this shot fires from the hopper, read once too
	var from_hopper := loads * f.power_per_load
	var reached: Array = []    # every foe the blows reached, killed or not, for a weapon that fills the hopper
	var vented_all := ms.heat if f.vents_all else 0
	if f.vents_all:
		ms.heat = 0
	for s in range(maxi(1, f.strikes)):
		var rolled := f.power
		if f.is_ranged():
			rolled = rng.randi_range(f.power, f.power_max)
		rolled += fired + missing + from_hopper
		var dmg := rolled
		var heat := f.heat if s == 0 else 0
		# Then the pipeline: every live modifier's adds, multiplies and floors, in that order.
		# Conditions on the foe read the primary target; a spread or a penetrate carries
		# the same blow to the others.
		var modded := Effects.attack(ms.unit, f, dmg, heat, target)
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
			if not reached.has(foe):
				reached.append(foe)
			# What the foe takes of the blow: its own statuses read last (a Shocked foe takes
			# double, and the shock is spent by the blow), then its armour comes off, flat, so
			# small blows bounce off a hardened foe the way they do off a heavy machine.
			var taken := Effects.damage_taken(foe, dmg)
			var foe_armoured := mini(taken, foe.armour_total())
			taken -= foe_armoured
			foe.hp -= taken
			if was_alive:
				dealt += clampi(taken, 0, maxi(0, hp_before))
			if foe == target:
				landed = taken
				armoured_total += foe_armoured
			# A blow of nothing (a lure, a probe) leaves a shock standing for a blow that counts.
			if dmg > 0 and Effects.remove(foe, "shocked"):
				log.append("%s: the shock lands, %d doubled" % [foe.display_name, dmg])
			if was_alive and not foe.alive() and f.has(Face.Keyword.DEVOUR):
				_devour(ms, foe)
			# Spillover (Overwhelm until 6 October): what the blow had past the kill of a front-rank foe carries into the
			# foe behind it in the column, as plain damage that still spends a shock and
			# feeds a devour. A massive foe fills its column, so nothing stands behind it.
			if was_alive and not foe.alive() and f.has(Face.Keyword.SPILLOVER) and foe.rank == 0 and not foe.is_massive():
				var spill := taken - hp_before
				var behind: Foe = back[foe.column] if foe.column >= 0 and foe.column < columns else null
				if spill > 0 and behind != null and behind.alive() and not hit.has(behind):
					var behind_taken := maxi(0, Effects.damage_taken(behind, spill) - behind.armour_total())
					behind.hp -= behind_taken
					Effects.remove(behind, "shocked")
					log.append("%s spills over: %d into %s" % [ms.unit.display_name, behind_taken, behind.display_name])
					if not behind.alive() and f.has(Face.Keyword.DEVOUR):
						_devour(ms, behind)
			if f.has(Face.Keyword.BURN):
				Effects.stack(foe, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", _stacks_from(ms, "burning", ceili(float(dmg) / BURN_DAMAGE_PER_STACK)))
				_note_status(gained, foe, "burning")
			if f.has(Face.Keyword.SUPPRESS) and _suppress(foe):
				_note_status(gained, foe, "suppressed")
			if foe.alive() and not touched.has(foe):
				touched.append(foe)
		total += landed
		rolled_total += rolled
	if extra_burn > 0:
		Effects.stack(target, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", _stacks_from(ms, "burning", extra_burn))
		_note_status(gained, target, "burning")
	# The hopper (11 October): a shot that fires it spends the loads it took; a weapon that
	# fills it puts its loads in for every foe its blows reached, after the blow, so a claw
	# never feeds the shot it is part of.
	if loads > 0:
		Effects.spend_stacks(ms.unit, "hopper", loads)
		log.append("%s fires the hopper: %d load%s, +%d" % [ms.unit.display_name, loads, "" if loads == 1 else "s", from_hopper])
	if f.fills_hopper > 0 and not reached.is_empty():
		var n := f.fills_hopper * reached.size()
		Effects.stack(ms.unit, Effects.STATUS["hopper"], Effects.SKIRMISH, "mech", n, Effects.DECAY_NONE)
		log.append("%s fills the hopper: +%d (%d)" % [ms.unit.display_name, n, Effects.stacks_of(ms.unit, "hopper")])
	# Shock (9 October): every foe the blows reached and left alive carries a charge for the
	# team's next blow, after this one landed, so a shocking weapon never spends its own.
	if f.has(Face.Keyword.SHOCK):
		for foe in touched:
			_shock(foe, ms)
	# Disrupt first, then lure, so an entry carrying both ends with the foe's new move aimed at
	# the spender.
	if f.has(Face.Keyword.DISRUPT):
		_disrupt(touched)
	if f.has(Face.Keyword.LURE):
		_lure(ms, touched)
	for foe in gained.keys():
		for status_id in gained[foe]:
			_foe_gained_status(foe, status_id)
	last_roll = {"mech": mech_index, "target": target, "rolled": rolled_total, "final": total, "melee": f.tags.has("melee")}
	var how := f.describe()
	if f.is_ranged():
		how = "rolled %d, " % rolled_total + how
	log.append("%s hits %s for %d (%s)%s" % [ms.unit.display_name, target.display_name, total, how, " (armour -%d)" % armoured_total if armoured_total > 0 else ""])
	if vented_all > 0:
		log.append("%s fires its heat: -%d, +%d to the blow" % [ms.unit.display_name, vented_all, fired])
	var was_front := target.rank == 0
	# A kill clears the slot at once (Ryan, 22 September): burning a hole through the front
	# opens the back rank to direct fire until reinforcements plug it.
	_clear_dead()
	var splashed := 0
	if reach == Face.Reach.INDIRECT and was_front:
		var splash := ceili(float(total) / DANGER_CLOSE_DIVISOR)
		if splash > 0 and not Effects.spares_splash(ms.unit):
			splashed = mini(splash, ms.unit.shield)
			ms.unit.shield = maxi(0, ms.unit.shield - splash)
			log.append("%s: splash, shield -%d" % [ms.unit.display_name, splash])
	if f.power > 0 or f.power_max > 0:   # a lure or a probe deals nothing: it is no spend of damage
		_tally_reach(reach, dealt, aimed_back, heat_total, splashed)
		_tally_class(f.is_ranged(), dealt, heat_total, maxi(1, f.strikes))
	if vent > 0:
		ms.heat = maxi(0, ms.heat - vent)
	_add_heat(ms, heat_total)
	# Chain: a kill repeats the attack on a new valid target, heat and all (the heat is the
	# risk, and a laser is telegraphed), until it misses a kill.
	if f.has(Face.Keyword.CHAIN) and not target.alive():
		for cand in targets_for(mech_index):
			if cand.alive() and cand != target:
				log.append("%s chains to %s" % [ms.unit.display_name, cand.display_name])
				var was_chaining := _chaining
				_chaining = true   # a chain is the same spend: its blows count, not a second spend
				_resolve_attack(mech_index, ms, f, cand)
				_chaining = was_chaining
				break


## A foe's defend, buff or debuff action, resolved in its turn in place of a blow (the ten
## planned actions of 14 September, built 30 September). Every field is the action's;
## nothing here keys on a foe's id. `Foe.ACTION_EFFECTS` says what each kind may do.
func _foe_acts(f: Foe, t: MechState) -> void:
	var a := f.action
	var effect := str(a.get("effect", ""))
	var value := int(a.get("value", 0))
	turn_specials.append({"foe": f, "name": str(a.get("name", "")), "kind": Foe.kind_of(a), "seq": _seq})
	_seq += 1
	match effect:
		"harden":
			# Armour for a turn: the status carries the action's own number, flat off every blow,
			# and fades at the foe's next action like the half it replaced.
			var guard: Dictionary = Effects.STATUS["folded"].duplicate(true)
			guard["effects"][0]["value"] = maxi(0, value)
			guard["description"] = "Armour +%d until its next action." % maxi(0, value)
			Effects.stack(f, guard, Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_TICK)
			log.append("%s: %s (armour +%d until its next action)" % [f.display_name, str(a.get("name", "hardens")), maxi(0, value)])
		"regrow":
			var before := f.hp
			f.hp = mini(f.hp_max, f.hp + value)
			log.append("%s: %s, regrows %d" % [f.display_name, str(a.get("name", "regrows")), f.hp - before])
		"revive_once":
			Effects.stack(f, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_NONE)
			log.append("%s: %s (it will return once)" % [f.display_name, str(a.get("name", "readies"))])
		"summon":
			var count := maxi(1, int(a.get("count", 1)))
			var who := str(a.get("foe", ""))
			if foe_factory.is_valid() and not who.is_empty():
				for i in range(count):
					var n = foe_factory.call(who)
					if n is Foe:
						n.pack_id = f.pack_id
						reinforcements.append(n)
				log.append("%s: %s, %d %s answer%s the call" % [f.display_name, str(a.get("name", "calls")), count, who, "s" if count == 1 else ""])
			else:
				log.append("%s: %s, and nothing answers" % [f.display_name, str(a.get("name", "calls"))])
		"rally":
			var rallied := 0
			for other in field_foes():
				if other != f and other.alive():
					Effects.grant_for_rounds(other, Effects.STATUS["kindled"], "foe:" + f.content_id, round + 1)
					rallied += 1
			log.append("%s: %s, %d hit %d harder next round" % [f.display_name, str(a.get("name", "rallies")), rallied, value])
		"drain_rerolls":
			reroll_debt += maxi(0, value)
			log.append("%s: %s, the team loses %d reroll%s next round" % [f.display_name, str(a.get("name", "roars")), value, "" if value == 1 else "s"])
		"add_heat":
			_add_heat(t, value)
			log.append("%s: %s, %s +%d heat" % [f.display_name, str(a.get("name", "stokes")), t.unit.display_name, value])
		"scramble":
			Effects.grant_for_rounds(t.unit, Effects.STATUS["scrambled"], "foe:" + f.content_id, round + 1)
			log.append("%s: %s, %s's next reroll is scrambled" % [f.display_name, str(a.get("name", "scrambles")), t.unit.display_name])
		"crack":
			if t.face_index >= 0:
				log.append("%s: %s, %s's showing component takes the blow" % [f.display_name, str(a.get("name", "unmakes")), t.unit.display_name])
				_injure_entry(t, t.face_index)
		"disable":
			# The entry the die shows is switched off through the machine's next turn, no blow.
			if t.face_index >= 0:
				Effects.disable_entry(t.unit, t.face_index, "foe:" + f.content_id, round + 1)
				log.append("%s: %s, %s's %s is switched off" % [f.display_name, str(a.get("name", "hushes")), t.unit.display_name, t.die.faces[t.face_index].describe()])
		"heat_all":
			var names: Array[String] = []
			for ms in live_mechs():
				_add_heat(ms, value)
				names.append(ms.unit.display_name)
			log.append("%s: %s, +%d heat to %s" % [f.display_name, str(a.get("name", "erupts")), value, ", ".join(names)])
		"corrupt_all":
			var hit_names: Array[String] = []
			for ms in live_mechs():
				if ms.face_index >= 0:
					Effects.corrupt_entry(ms.unit, ms.face_index, "foe:" + f.content_id)
					hit_names.append(ms.unit.display_name)
			log.append("%s: %s, the showing component of %s is corrupted" % [f.display_name, str(a.get("name", "unravels")), ", ".join(hit_names) if not hit_names.is_empty() else "nobody"])
		_:
			log.append("%s: %s" % [f.display_name, str(a.get("name", "acts"))])


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


## One attack's share of the reach tally (the runner's; the game never reads it).
func _tally_reach(reach: int, dealt: int, aimed_back: bool, heat: int, splashed: int) -> void:
	var k := str(Face.REACH_NAMES.get(reach, reach))
	var t: Dictionary = reach_tally.get(k, {"spends": 0, "damage": 0, "back": 0, "heat": 0, "splash": 0, "front_spends": 0})
	if not _chaining:
		t["spends"] += 1
		if aimed_back:
			t["back"] += 1
		else:
			t["front_spends"] += 1
	t["damage"] += dealt
	t["heat"] += heat
	t["splash"] += splashed
	reach_tally[k] = t


## One attack's share of the class tally (the runner's; the game never reads it).
func _tally_class(rolled: bool, dealt: int, heat: int, strikes: int) -> void:
	var k := "rolled" if rolled else "flat"
	var t: Dictionary = class_tally.get(k, {"spends": 0, "damage": 0, "heat": 0, "strikes": 0})
	if not _chaining:
		t["spends"] += 1
	t["damage"] += dealt
	t["heat"] += heat
	t["strikes"] += strikes
	class_tally[k] = t


## Hull lost, to a blow, a bite or an overheat (Ryan, 10 October: taking hull damage is any of
## them): the on_hull_damage passives fire (the Nemesis's Crucible, a shield raised, heat
## shed, a buff stacked).
func _hull_damaged(ms: MechState) -> void:
	var parts := _apply(ms, Effects.hull_damaged(ms.unit))
	if not parts.is_empty():
		log.append("%s: %s from the hit" % [ms.unit.display_name, ", ".join(parts)])


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
	var stacks := _stacks_from(ms, "overcharged", 1)
	if Effects.keeps(ms.unit, "overcharged"):
		# The Ammit's Quintessence Tap: what the talons take is kept, for the battle, never fading.
		m = Effects.stack(ms.unit, Effects.STATUS["overcharged"], Effects.BATTLE, "devour", stacks, Effects.DECAY_NONE)
	else:
		m = Effects.stack(ms.unit, Effects.STATUS["overcharged"], Effects.SKIRMISH, "devour", stacks, Effects.DECAY_TICK)
	log.append("%s devours %s: %s ×%d" % [ms.unit.display_name, foe.display_name, m.name, Effects.stacks_of(ms.unit, "overcharged")])


## Stacks this machine is applying, deepened by its on_stack passives (the Stingray's
## Exothermic Suite: a stack per 20 heat carried, on every stack it applies, to a foe, an
## ally or itself). Numbed is never deepened: it is exempt from every interaction (Ryan,
## 2 October), and Effects.extra_stacks says so.
func _stacks_from(ms: MechState, status_id: String, n: int) -> int:
	if n <= 0:
		return n
	var extra := Effects.extra_stacks(ms.unit, status_id, ms.heat)
	if extra > 0:
		log.append("%s runs hot: +%d %s" % [ms.unit.display_name, extra, str(Effects.STATUS.get(status_id, {}).get("name", status_id))])
	return n + extra


## Suppress: the foe skips its action this round, then grows Numbed (two stacks, three for
## a massive foe). It resists at its own base resistance plus 10% a stack, on the
## skirmish's own die (Ryan, 26 September): a suppress it shrugs off does nothing at all
## and numbs it no further, and Numbed loses a stack at each of the foe's turns, so a stun
## repeated on one foe stops landing while stuns spread across the formation keep working.
## `carry`: a foe already suppressed loses its next action instead (a Paradox tripping on
## it, 10 October), so the knock-out is never spent on an action already lost.
func _suppress(foe: Foe, carry: bool = false) -> bool:
	var resist := foe.resist_total()
	if resist > 0 and rng.randi_range(1, 100) <= resist:
		log.append("%s shrugs off the suppression (%d%% resistant)" % [foe.display_name, resist])
		return false
	# A foe that has already acted this turn loses its next action instead of one it has taken.
	var next := _acted.has(foe) or (carry and foe.is_suppressed())
	Effects.grant_for_rounds(foe, Effects.STATUS["suppressed"], "mech", round + 1 if next else round)
	Effects.stack(foe, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", NUMBED_PER_SUPPRESS_MASSIVE if foe.is_massive() else NUMBED_PER_SUPPRESS, Effects.DECAY_TICK)
	return true


## The count that knocks a foe out through Paradox: the lowest any live machine runs, or 0 when
## no machine runs the meter (the screen's chips read it).
func paradox_count() -> int:
	var at := 0
	for ms in live_mechs():
		var t: int = Effects.paradox(ms.unit)[1]
		if t > 0 and (at == 0 or t < at):
			at = t
	return at


## One spend's status on one foe, told once at the end of the spend however many strikes or
## stacks put it there (Ryan, 10 October: an application, not a stack).
static func _note_status(gained: Dictionary, foe: Foe, status_id: String) -> void:
	var ids: Array = gained.get(foe, [])
	if not ids.has(status_id):
		ids.append(status_id)
	gained[foe] = ids


## A foe has just gained a status (whoever applied it, once a spend): every live machine's
## on_foe_status passive answers. The Baboon's Pocket Paradox, a meter since 10 October
## (Ryan): the foe gains Paradox, deepened like any status its machine applies, and at the
## machine's count it is Suppressed and the Paradox clears. Paradox never counts, and the
## Suppressed it causes is never told, so it never feeds itself; a weapon's Suppressed does
## count. Numbed is a resistance, not a status.
func _foe_gained_status(foe: Foe, status_id: String) -> void:
	if status_id == "paradox" or status_id == "numbed" or not foe.alive():
		return
	for ms in live_mechs():
		var meter := Effects.paradox(ms.unit)
		if meter[1] <= 0:
			continue
		Effects.stack(foe, Effects.STATUS["paradox"], Effects.SKIRMISH, "mech", _stacks_from(ms, "paradox", meter[0]), Effects.DECAY_NONE)
		if Effects.stacks_of(foe, "paradox") >= meter[1]:
			Effects.remove(foe, "paradox")
			log.append("%s got trapped in a paradox! (%s)" % [foe.display_name, ms.unit.display_name])
			_suppress(foe, true)
			return


## Lure (decided 2 October, in place of taunt and beacon): every foe this entry reached turns
## on the spender for the round, intents and all. No status and no chip: the arrow changing
## is the record. A lured foe whose move has no target keeps doing it, and the log says so.
func _lure(ms: MechState, foes: Array) -> void:
	var turned: Array[String] = []
	var idle: Array[String] = []
	for foe in foes:
		if not foe.alive():
			continue
		if not foe.attacks() and str(foe.action.get("effect", "")) in UNTARGETED_EFFECTS:
			idle.append(foe.display_name)
		if foe.target != ms:
			foe.target = ms
			turned.append(foe.display_name)
	if not turned.is_empty():
		log.append("%s lures %s" % [ms.unit.display_name, ", ".join(turned)])
	if not idle.is_empty():
		log.append("lured, but %s %s nothing to turn" % [", ".join(idle), "has" if idle.size() == 1 else "have"])


## Disrupt (decided 2 October, in place of the planned scramble and confuse): the foe does its
## other move instead, this round, the new intent shown at once. Deterministic: the next move
## in its list that its conditions allow, so a boss with three moves steps through its
## pattern; a foe with nothing else open is not moved. The new move picks its own target.
func _disrupt(foes: Array) -> void:
	for foe in foes:
		if not foe.alive():
			continue
		var legal := legal_actions(foe)
		var others: Array = []
		for a in legal:
			if a != foe.action:
				others.append(a)
		if others.is_empty():
			log.append("%s is disrupted, and has nothing else to do" % foe.display_name)
			continue
		# The next in its pattern: the first legal move after the current one, wrapping.
		var start: int = foe.actions.find(foe.action)
		var next: Dictionary = others[0]
		for k in range(1, foe.actions.size() + 1):
			var cand: Dictionary = foe.actions[(start + k) % foe.actions.size()]
			if others.has(cand):
				next = cand
				break
		var was := str(foe.action.get("name", ""))
		foe.action = next
		foe.last_special = "" if foe.attacks() else str(foe.action.get("id", ""))
		foe.target = _pick_mech_target(foe)
		log.append("%s is disrupted: %s instead of %s" % [foe.display_name, str(next.get("name", "")), was])


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
## so a machine run hot can still be vented before it pays. Gaining heat fires the
## on_heat_gain passives (which may raise shield, never heat).
func _add_heat(ms: MechState, amount: int) -> void:
	if amount > 0:
		ms.heat += amount
		_fired(ms, Effects.fire(ms.unit, "on_heat_gain", amount), "on the heat")


## Shield gained from any source, capped at the maximum unless the component carries
## Overshield; gaining any fires the on_shield_gain passives (which may shed heat, never
## raise shield). Returns what stood up.
func _gain_shield(ms: MechState, amount: int, overshield: bool = false) -> int:
	if amount <= 0:
		return 0
	var gained := ms.unit.recharge_shield(amount, overshield)
	if gained > 0:
		_fired(ms, Effects.fire(ms.unit, "on_shield_gain", gained), "on the shield")
	return gained


## A shield component spent on an ally fires the spender's on_shield_granted passives on
## that ally (the Puffin's escort passive, 5 October): heat the ally sheds, statuses it
## gains. Fires on the spend, whatever the shield gained.
func _shield_granted(ms: MechState, who: MechState, amount: int) -> void:
	var r := Effects.shield_granted(ms.unit, who.unit, amount)
	var parts: Array[String] = []
	var vented := mini(who.heat, int(r["vent"]))
	if vented > 0:
		who.heat -= vented
		parts.append("-%d heat" % vented)
	for name in r["statuses"]:
		parts.append(str(name))
	if not parts.is_empty():
		log.append("%s: %s's escort, %s" % [who.unit.display_name, ms.unit.display_name, ", ".join(parts)])


## The round's end lets shield past the maximum go (Overshield, 5 October): the excess was a
## one-round buffer, and a buffer that stayed would stack a team past every blow.
func _trim_overshield() -> void:
	for ms in live_mechs():
		if ms.unit.shield > ms.unit.shield_max:
			log.append("%s: %d shield past its maximum fades" % [ms.unit.display_name, ms.unit.shield - ms.unit.shield_max])
			ms.unit.shield = ms.unit.shield_max


## Apply what a trigger's passives gave a machine: shield up (which is a shield gain of its
## own), heat off, and a log line naming it when anything happened.
func _fired(ms: MechState, result: Dictionary, when: String) -> void:
	var parts := _apply(ms, result)
	if not parts.is_empty():
		log.append("%s: %s, %s" % [ms.unit.display_name, when, ", ".join(parts)])


## What a trigger's passives gave a machine, applied where the gauges live; returns the
## pieces for the log line.
func _apply(ms: MechState, result: Dictionary) -> Array[String]:
	var parts: Array[String] = []
	var gained := _gain_shield(ms, int(result["shield"]))
	if gained > 0:
		parts.append("+%d shield" % gained)
	var vented := mini(ms.heat, int(result["vent"]))
	if vented > 0:
		ms.heat -= vented
		parts.append("-%d heat" % vented)
	for name in result["statuses"]:
		parts.append(str(name))
	return parts


## The end of the player's turn: heat above the maximum burns hull one for one and the gauge
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
		if ms.alive():
			_hull_damaged(ms)   # an overheat is hull damage like any other (10 October)


## One blow. Decided 18 September: a standing shield blocks the whole blow, however small the
## shield and however big the blow; nothing bleeds through (unless the foe breaches, then the
## excess reaches the hull). A blow that reaches the hull loses the chassis's armour first, a
## breach's overflow included, so small hits bounce off a heavy machine. Only a bare-hull blow can injure a component, and only
## when what gets through is at least a quarter of max hull. Shield before a telegraphed
## blow is the counterplay; a double strike is how a foe gets past it.
func _damage_mech(ms: MechState, amount: int, source: Foe) -> void:
	amount = Effects.damage_taken(ms.unit, amount)   # buffs and debuffs on damage taken, before shield and armour
	var r := _blow(ms.unit.shield, ms.unit.hull_max, ms.unit.armour + Effects.armour_against(ms.unit, source.rank), amount, source.breaches())
	var had_shield := ms.unit.shield > 0
	ms.unit.shield = r["shield"]
	ms.unit.hull -= r["through"]
	var rk := "back" if source != null and source.rank == 1 else "front"
	taken_by_rank[rk] = int(taken_by_rank.get(rk, 0)) + int(r["absorbed"]) + int(r["through"])
	# The mech's gauges after the blow ride along, so a replay can step them down blow by blow.
	turn_events.append({"foe": source, "mech": mechs.find(ms), "absorbed": r["absorbed"], "through": r["through"],
		"blocked": r["blocked"], "broke_shield": had_shield and ms.unit.shield == 0, "injured": r["injures"],
		"shield": ms.unit.shield, "hull": ms.unit.hull, "seq": _seq,
		"name": str(source.action.get("name", "")) if source != null else "", "boss": source != null and source.is_massive()})
	_seq += 1
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
		# What the injury did rides on the event too: the console says a component was
		# damaged or destroyed (Jenny's information lines, 8 October).
		turn_events[turn_events.size() - 1]["component"] = apply_injury(ms)


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
	# Armour comes off every blow that reaches the hull, a breach's overflow too (Ryan, 11
	# October): a breach beats the shield, never the plate under it.
	var armoured := 0
	if through > 0:
		armoured = mini(armour, through)
		through -= armoured
	# Injury is about hull lost in one blow, wherever it came from: a breach that overflows a
	# quarter of the hull injures too (Ryan, 18 September: breach is the release valve, and its
	# counterplay is not the shield).
	var injures := through > 0 and through * 100 >= hull_max * CRACK_MIN_HULL_PCT
	return {"shield": shield - absorbed, "absorbed": absorbed, "through": through, "armoured": armoured, "blocked": blocked, "injures": injures}


## The injury rolls the die and hits the component it lands on. An intact component cracks:
## keywords and unique effect are gone, the basic action stays. A cracked component is
## destroyed: blank. A destroyed component or an empty hardpoint takes the blow and nothing
## happens, so a mech with little left to break shrugs off more of them. The damage lives on
## the unit and persists until repaired in the hangar. (Decided 17 September: one threshold,
## one roll.) A passive may say no_destroy on_injury: then a cracked component holds.
func apply_injury(ms: MechState) -> String:
	if ms.die.faces.is_empty():
		return ""
	return _injure_entry(ms, ms.die.roll(rng))


## The injury on one entry: intact cracks, cracked is destroyed (unless a passive holds it),
## blank shrugs it off. The die's roll picks the entry for a hull hit; a foe's unmake picks
## the one showing. Returns what happened: "cracked", "destroyed", or "" for nothing.
func _injure_entry(ms: MechState, idx: int) -> String:
	if idx < 0 or idx >= ms.die.faces.size():
		return ""
	var f := ms.die.faces[idx]
	if f.kind == Face.Kind.BLANK:
		log.append("%s: the blow lands on %s; nothing left to break" % [ms.unit.display_name, "an empty hardpoint" if f.empty else "a destroyed component"])
		return ""
	var originals: Dictionary = ms.unit.damaged_faces
	var what := f.describe()
	if f.cracked:
		if Effects.no_destroy(ms.unit, f):
			log.append("%s: %s holds, cracked but not destroyed" % [ms.unit.display_name, what])
			return ""
		var d := Face.blank()
		d.component = f.component
		ms.die.faces[idx] = d
		destroyed += 1
		log.append("%s: a cracked component is destroyed (%s)" % [ms.unit.display_name, what])
		return "destroyed"
	originals[idx] = f.duplicate_face()
	var c := f.duplicate_face()
	c.crack()
	ms.die.faces[idx] = c
	log.append("%s: a component cracks (%s)" % [ms.unit.display_name, what])
	return "cracked"


## Whom a foe strikes (decided 2 October): its own pick, by the sense its move follows. The aim: the exposed, weighted by the hull its blow would reach, so a
## shield standing lowers the draw and a shield down raises it; anything, uniform; heat, the
## hottest machine; the armed, a machine showing an intact weapon (the exposed when none
## does); fires as one, the rank's shared pick. The pick is a commitment: a foe whose target
## shields up still swings at it. With the override set, or asked with no foe, the rule
## before: the lowest shield, then the lowest hull.
func _pick_mech_target(f: Foe = null) -> MechState:
	var live := live_mechs()
	if live.is_empty():
		return null
	if f == null or targeting_override == "lowest":
		return _lowest_shield(live)
	match f.aim_of():
		"anything":
			return live[rng.randi_range(0, live.size() - 1)]
		"heat":
			var hottest: Array[MechState] = []
			for ms in live:
				if hottest.is_empty() or ms.heat > hottest[0].heat:
					hottest = [ms]
				elif ms.heat == hottest[0].heat:
					hottest.append(ms)
			return hottest[rng.randi_range(0, hottest.size() - 1)]
		"armed":
			var armed := _armed_mechs()
			if armed.is_empty():
				return _pick_exposed(f, live)
			return armed[rng.randi_range(0, armed.size() - 1)]
		"focus":
			var shared = _focus.get(f.rank, null)
			if shared != null and shared.alive():
				return shared
			var pick := _pick_exposed(f, live)
			_focus[f.rank] = pick
			return pick
	return _pick_exposed(f, live)


static func _lowest_shield(live: Array[MechState]) -> MechState:
	var best: MechState = null
	for ms in live:
		if best == null \
				or ms.unit.shield < best.unit.shield \
				or (ms.unit.shield == best.unit.shield and ms.unit.hull < best.unit.hull):
			best = ms
	return best


## The exposed: each machine weighs one, plus the hull this foe's blows would reach through
## its shield and armour as they stand, plus half of any shield they would break (a standing
## shield blocks a blow whole here, so without that a shield of 10 would read as safe as one
## of 40; a shield about to fail is exposure too), and the pick is drawn by weight.
func _pick_exposed(f: Foe, live: Array[MechState]) -> MechState:
	var weights: Array[float] = []
	var total := 0.0
	for ms in live:
		var w := 1.0 + float(hull_reached(f, ms)) + float(shield_broken(f, ms)) * 0.5
		weights.append(w)
		total += w
	var roll := rng.randf() * total
	for i in range(live.size()):
		roll -= weights[i]
		if roll <= 0.0:
			return live[i]
	return live[live.size() - 1]


## The shield this foe's blows would take off a machine, when they would take all of it;
## zero when the shield holds.
func shield_broken(f: Foe, ms: MechState) -> int:
	var dmg := f.damage()
	if dmg <= 0 or ms.unit.shield <= 0:
		return 0
	var shield := ms.unit.shield
	for s in range(f.strikes()):
		shield = int(_blow(shield, ms.unit.hull_max, 0, Effects.damage_taken(ms.unit, dmg), f.breaches())["shield"])
	return ms.unit.shield if shield <= 0 else 0


## The hull this foe's blows would reach on a machine as it stands: its damage, its strikes,
## its breach, against the shield, armour and damage taken the forecast reads.
func hull_reached(f: Foe, ms: MechState) -> int:
	var dmg := f.damage()
	if dmg <= 0:
		return 0
	var shield := ms.unit.shield
	var through := 0
	for s in range(f.strikes()):
		var r := _blow(shield, ms.unit.hull_max, ms.unit.armour + Effects.armour_against(ms.unit, f.rank), Effects.damage_taken(ms.unit, dmg), f.breaches())
		shield = r["shield"]
		through += int(r["through"])
	return mini(through, maxi(0, ms.unit.hull))


# ---------------------------------------------------------------- formation

func _clear_dead() -> void:
	_clear_dead_slots()
	_refresh_kin()


func _clear_dead_slots() -> void:
	for col in range(columns):
		for rank in [front, back]:
			var f: Foe = rank[col]
			if f != null and not f.alive():
				if f.rank >= 0:
					# A foe that readied itself to get back up returns to the pool once, whole,
					# unless it went whole (a Bomb's burst).
					if Effects.has(f, "risen") and not f.stays_down:
						Effects.remove(f, "risen")
						f.hp = f.hp_max
						f.rank = -1
						f.column = -1
						f.target = null
						f.modifiers.clear()
						reinforcements.append(f)
						log.append("%s falls, and gets back up into the pool" % f.display_name)
					else:
						log.append("%s destroyed" % f.display_name)
						_split(f)
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
	_refresh_kin()


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

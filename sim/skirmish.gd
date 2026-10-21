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
##   end_round()         the player's turn ends: a machine's Burning adds its heat and loses a
##                       stack, Scorched goes, then heat over the cap burns hull; then
##                       burn ticks, foes act, the dead are cleared, mech statuses tick, the
##                       reinforcements refill, outcome is checked
##   can_withdraw()      at any point of the player's turn
##
## The player's damage is in fives, everything else in tens. Enemy damage is static; only
## the player's rolled faces roll.

enum State { SETUP, ROUND_START, ASSIGN, DONE }
enum Outcome { NONE, VICTORY, DEFEAT, WITHDRAWN }

const DEFAULT_COLUMNS := 4   # the formation's width (Ryan, 23 September: four plays better than three)
const REROLLS_PER_ROUND := 3
const DANGER_CLOSE_DIVISOR := 2
const CRACK_MIN_HULL_PCT := 25      # a single hull hit this big (percent of max) injures a face
const CRYO_COOL_PER_STACK := 10    # heat a damaging hit on a Cryo foe sheds for its hitter, a stack (20 October; a placeholder ahead of the heat rework)
const CORRUPT_BITE_PER_STACK := 10  # what a corrupted entry costs its owner each time it is spent, per stack (placeholder)
const VOLATILE_BITE := 10           # what a volatile component costs its owner each time it is spent: hull, past shield and armour (placeholder)
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
var last_blast: Dictionary = {}   # the last vent blast, {mech, foe, dealt}, for the screen; cleared each round
## The fight's share of the run's Sponsorship measures (the bible's Sponsorship row; tallied 21
## October, never shown live): damage the team took on shield and armour, dice spent on
## entries that deal damage (a vent that blasts among them) and on entries that deal none.
## The battle adds them up with the hexes its machines move; each maker's content names its own.
var sponsorship := {"guarded": 0, "damaging_spends": 0, "quiet_spends": 0}
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
## seq, name, boss, all}. `seq` orders it among the turn's specials; `name` is the move's shown
## name, `boss` whether a massive foe struck and `all` whether the blow struck every machine,
## for the plaque (decided 9 October; `all` 15 October).
var turn_events: Array = []
## The last acts of foes that fell during the latest spend (15 October), for the screen to name
## and land: {foe, name, mechs (indices struck)}.
var last_acts: Array = []
## Every special of the last enemy turn (a defend, buff or debuff in place of a blow), for
## the screen to announce on its plaque in order: {foe, name, kind, seq}.
var turn_specials: Array = []
## This turn's rallies, [foe, value, source], granted as Kindled once the turn is over (13
## October): live from the next round, so a foe striking after the rallier hits what it showed.
var _rallies: Array = []
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
	_refresh_guards()
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


## A boss unit's commanders still standing in this fight (Foe.commands: its boss, a final's
## hero, the finale's line), alive on the field or waiting in the pool, a readied one that got
## back up among them: their content ids, field first. The unit stands while one does.
func commanders_left(sq: Unit) -> Array:
	var out: Array = []
	for f in field_foes():
		if f.pack_id == sq.id and f.commands and f.alive():
			out.append(f.content_id)
	for f in reinforcements:
		if f.pack_id == sq.id and f.commands:
			out.append(f.content_id)
	return out


## A boss unit's escort left after this fight (Foe.escorts): its strength on the map.
func escort_left(sq: Unit) -> int:
	var n := 0
	for f in field_foes():
		if f.pack_id == sq.id and f.escorts and f.alive():
			n += 1
	for f in reinforcements:
		if f.pack_id == sq.id and f.escorts:
			n += 1
	return n


## The foes of a pack this fight killed, for the salvage the battle tallies: a pack's strength
## less its survivors; a boss unit's fallen commanders and escort (read before the map takes
## the result, while its lineup and strength are still the ones it came with).
func kills_for(sq: Unit) -> int:
	if sq.is_boss:
		return maxi(0, maxi(1, sq.lineup.size()) - commanders_left(sq).size()) + maxi(0, sq.strength - escort_left(sq))
	return maxi(0, sq.strength - survivors_for(sq))


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
## to that foe: its missing hull, conditions on it (a status it carries), its Flak (a point a
## stack on a blow that deals something) and its armour off the blow. A shock is left out, the
## foe's own chip, and spent by the first blow of many.
## `f` is the entry as this machine's passives make it (shown_face); [0, 0] for no attack.
func shown_number(ms: MechState, f: Face, target: Foe = null) -> Array[int]:
	if f == null or not f.is_attack():
		return [0, 0]
	var add := heat_bonus(ms, f) + f.missing_bonus(target) + hopper_bonus(ms.unit, f)
	var out: Array[int] = []
	for v in [f.power, f.power_max]:
		var d := int(Effects.attack(ms.unit, f, v + add, 0, target)["damage"])
		if target != null:
			if d > 0:
				d += Effects.damage_taken_add(target, ms.unit)
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
## not suppressed, aimed at it with an attack (a foe bracing, rallying or roaring lands no
## blow), and not about to die to burn first.
func attackers_of(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	for f in acting_on(ms):
		if f.attacks():
			out.append(f)
	return out


## Every foe that will act on this mech when the round ends, whatever its action: alive, not
## suppressed, showing intent on it (its pick, or a blow at every machine; a special that acts
## on nobody in particular shows none: Foe.intent_on), and not about to die to burn first.
func acting_on(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	for f in field_foes():
		if not f.intent_on(ms.unit):
			continue
		if f.hp - int(Effects.tick_preview(f)["hp"]) <= 0:   # burns to death before it strikes
			continue
		out.append(f)
	return out


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
	return spend_bite(ms.unit, Effects.effective_face(ms.unit, f))   # a Silenced entry's Volatile is muted


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
## component with that keyword would. `aimed`, the foe a dragged die is held over, folds in
## what that spend cashes there: a damaging hit on a Cryo foe cools the hitter after its own
## heat lands (Ryan, 16 October: the net on the heat bar, never the die).
func forecast(ms: MechState, with_face: bool = true, extra_shield: int = 0, overshield: bool = false, aimed: Foe = null) -> Dictionary:
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
	var standing := shield
	var walk := {"shield": shield, "barrier": Effects.has(ms.unit, "barrier")}
	for f in attackers_of(ms):
		incoming += f.damage() * f.strikes()
		for r in blows_on(ms, f, walk):
			hull -= int(r["through"])
			if r["injures"]:
				component_risk = true
	shield = int(walk["shield"])
	# Heat: what the gauge holds (past the cap, if the turn ran hot), the face's own if asked
	# and Burning's tick burn at the end of the player's turn, before the enemy acts (11 and
	# 13 October). Foes add no heat outright: their fire leaves Burning and Scorched, which
	# land on later turns.
	var heat_mid := ms.heat + (pending_heat(ms) if with_face else 0)
	heat_mid -= mini(heat_mid, cryo_cash(ms, aimed) if with_face else 0)
	var heat_end := heat_mid + int(Effects.tick_preview(ms.unit, true)["heat"]) + seal_heat(ms)
	var over := maxi(0, heat_end - ms.heat_max)
	hull -= over
	var blows := 0
	for f in attackers_of(ms):
		blows += f.strikes()
	var heat_after := mini(heat_end, ms.heat_max) + int(Effects.tick_preview(ms.unit)["heat"]) + Effects.heat_per_blow(ms.unit) * blows   # a Siphon's heat lands with the blows
	return {
		"incoming": incoming,
		"bite": bite,
		"volatile": volatile,
		"shield_after": shield,
		"hull_after": hull,
		"heat_end": heat_end,       # the gauge as the turn ends, uncapped: what the burn reads
		"heat_after": heat_after,   # the gauge after the round: settled at the cap, then the foes' heat
		"overheat": over,
		"breaks_shield": standing > 0 and shield <= 0,
		"component_risk": component_risk,
		"destroyed": hull <= 0 and ms.alive(),
	}


## The heat a damaging spend of the entry showing would cash off Cryo foes, aimed at `over`:
## every stack on every foe it reaches, at the Cryo rate. Nothing for an entry of no damage or
## without a foe in hand.
func cryo_cash(ms: MechState, over: Foe) -> int:
	var f := ms.face()
	if over == null or f == null or ms.assigned or not f.is_attack():
		return 0
	var ef := Effects.effective_face(ms.unit, f, over)
	if ef.power <= 0 and ef.power_max <= 0:
		return 0
	var stacks := 0
	for foe in reached_by(ef, over):
		if foe.alive():
			stacks += Effects.stacks_of(foe, "cryoed")
	return stacks * CRYO_COOL_PER_STACK


## One foe's blows on a machine as they would land now, in order: each through what the
## machine takes (damage_taken), a Barrier that stands taking the first that deals anything,
## a breach unless a Ward turns it away, each against the shield the one before left. `walk`
## carries the shield and the Barrier from blow to blow, and from foe to foe for a caller
## walking every attacker: {"shield": int, "barrier": bool}, updated. Returns each blow's
## arithmetic (_blow's).
func blows_on(ms: MechState, f: Foe, walk: Dictionary) -> Array:
	var out: Array = []
	var breach := f.breaches() and not Effects.has(ms.unit, "ward")
	var armour := ms.unit.armour + Effects.armour_against(ms.unit, f.rank)
	for s in range(f.strikes()):
		var amount := Effects.damage_taken(ms.unit, f.damage(), f)
		if amount > 0 and bool(walk.get("barrier", false)):
			walk["barrier"] = false
			amount = 0
		var r := _blow(int(walk["shield"]), ms.unit.hull_max, armour, amount, breach)
		walk["shield"] = r["shield"]
		out.append(r)
	return out


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
## The second targets a Swap entry takes beside its first (the Dingo's Combat Translocator, Ryan's
## go of 19 October): every other foe on the field and every empty slot, the slot as
## Vector2i(rank, column); never a massive foe, which fills its column and stays, and nothing
## for a massive first.
func swap_targets(first: Foe) -> Array:
	var out: Array = []
	if first == null or not first.alive() or first.is_massive():
		return out
	for foe in field_foes():
		if foe != first and foe.alive() and not foe.is_massive():
			out.append(foe)
	for col in range(columns):
		if front[col] == null:
			out.append(Vector2i(0, col))
		if back[col] == null:
			out.append(Vector2i(1, col))
	return out


## Does this entry, spent now, take a second target (a Swap)?
func needs_second(ms: MechState) -> bool:
	var f := ms.face()
	return f != null and Effects.effective_face(ms.unit, f).has(Face.Keyword.SWAP)


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
	# A Swap moves its target, and a massive foe fills its column and stays (the Dingo's row).
	if Effects.effective_face(ms.unit, f).has(Face.Keyword.SWAP):
		out = out.filter(func(foe: Foe) -> bool: return not foe.is_massive())
	return out


## A component's reach as it is right now: its own, unless the mech's passive says
## otherwise while a condition holds (a passive's set_reach). Computed on
## every read and never written to the component, so the answer always has a source: an
## ally reading the same component gets its own answer, and a suppressed passive stops
## answering.
func reach_of(ms: MechState, f: Face) -> int:
	return Effects.effective_reach(ms.unit, f)


## The component as the player should see it and as the resolver spends it: a copy carrying
## the effective reach and any keyword a passive grants. The die keeps the real one. An
## attack also shows the heat a spend adds through every live source (a Scorched machine's
## weapons run hotter, 13 October; the Sparrowhawk's double): the game does the arithmetic.
## Over a target, the keywords its rank grants too (the Cottonmouth's drum: Spread at the
## front, Penetrate at the back), as the spend will carry them.
func shown_face(ms: MechState, f: Face, target: Foe = null) -> Face:
	var sf := Effects.effective_face(ms.unit, f, target)
	if sf == null or not sf.is_attack():
		return sf
	var heat := int(Effects.attack(ms.unit, sf, 0, sf.heat)["heat"])
	if heat == sf.heat:
		return sf
	if sf == f:
		sf = f.duplicate_face()
	sf.heat = heat
	return sf


# ---------------------------------------------------------------- round flow

func start_round() -> void:
	assert(state == State.ROUND_START, "start_round called out of order")
	round += 1
	rerolls_left = maxi(0, REROLLS_PER_ROUND - reroll_debt)   # a roar last round costs rerolls now
	if reroll_debt > 0:
		log.append("the roar costs the team %d reroll%s" % [reroll_debt, "" if reroll_debt == 1 else "s"])
	reroll_debt = 0
	last_roll.clear()
	last_blast.clear()
	# The turn begins with passive cooling (Ryan, 22 September: cool at the start, heat at
	# the end): every machine sheds its chassis's cooling rating, one log line for all.
	var cooled: Array[String] = []
	for ms in mechs:
		ms.assigned = false
		if not ms.alive():
			continue
		# A sealed machine's own cooling stops (the Armadillo's Lockdown, 20 October); an ally's
		# vent still cools it.
		var drop := 0 if Effects.is_sealed(ms.unit) else mini(ms.heat, ms.unit.cooling)
		if drop > 0:
			ms.heat -= drop
			cooled.append("%s -%d" % [ms.unit.display_name, drop])
		ms.face_index = _roll(ms)
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
		# A move gathered last round holds, and so does its pick while the machine stands.
		var carried := not f.pending.is_empty()
		_choose_foe_action(f)
		if carried and f.target != null and (f.target as MechState).alive():
			continue
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
	if not f.pending.is_empty():
		f.action = f.pending   # a countdown move holds until it lands
		return
	f.choose_from(legal_actions(f), rng)
	f.last_special = "" if f.attacks() else str(f.action.get("id", ""))
	_begin_countdown(f)


## A move with a countdown starts gathering as it is announced (15 October).
func _begin_countdown(f: Foe) -> void:
	var n := Foe.countdown_of(f.action)
	if n > 0:
		f.pending = f.action
		f.charge = n


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
		"ally_hurt":
			for o in field_foes():
				if o.alive() and o.hp < o.hp_max:
					return true
			return false
		"others_on_field":
			for o in field_foes():
				if o != f and o.alive():
					return true
			return false
		"ally_unready":
			return _unready_ally(f) != null
		"machine_buffed":
			for ms in live_mechs():
				if Effects.buff_stacks(ms.unit) > 0:
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
## anywhere and the scramble is spent. A stepping die steps (a reroll is a roll), and a
## Scramble is a true roll for it too, the sequence running on from where it lands.
func _reroll_die(ms: MechState) -> void:
	if Effects.is_scrambled(ms.unit):
		ms.face_index = ms.die.roll(rng)
		Effects.remove(ms.unit, "scrambled")
		log.append("%s's reroll is scrambled" % ms.unit.display_name)
		return
	ms.face_index = _step(ms) if Effects.steps_die(ms.unit) else ms.die.reroll(rng, ms.face_index)


## A die rolling (Ryan's wording for the Cassowary, 12 October: "Whenever its die rolls, it
## moves to the next entry instead, in sequence"): a stepping die steps, once the fight's
## first roll has spun it to a random chamber (Ryan, 18 October: "like a revolver spinning");
## any other die rolls.
func _roll(ms: MechState) -> int:
	if ms.face_index >= 0 and Effects.steps_die(ms.unit):
		return _step(ms)
	return ms.die.roll(rng)


## The entry after the one showing, past the last back to the first.
func _step(ms: MechState) -> int:
	var n := ms.die.faces.size()
	return 0 if n == 0 or ms.face_index < 0 else (ms.face_index + 1) % n


## What a stepping die shows after its next step, as the die would show it (a dark entry's
## stand-in, the passives' reach and heat): the screen's next-chamber chip. Null for a die
## that rolls.
func next_face(ms: MechState) -> Face:
	if ms.face_index < 0 or not Effects.steps_die(ms.unit) or ms.die.faces.is_empty():
		return null
	var at := _step(ms)
	if Effects.is_entry_disabled(ms.unit, at):
		return Face.disabled_stand_in(ms.die.faces[at])
	return shown_face(ms, ms.die.faces[at])


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


func assign(mech_index: int, target = null, second = null) -> bool:
	if state != State.ASSIGN:
		return false
	last_acts.clear()
	var ms := mechs[mech_index]
	if not ms.alive() or ms.assigned:
		return false
	var f := ms.face()
	if f == null:
		return false
	f = Effects.effective_face(ms.unit, f, target if target is Foe else null)   # the entry as this machine's passives make it, over the foe it is aimed at
	if f.is_attack() and (not (target is Foe) or not targets_for(mech_index).has(target)):
		return false
	# A Swap takes its second target with it (Ryan, 21 October: drag to the first, drop, then
	# tap the second): another foe or an empty slot, never a massive foe.
	if f.has(Face.Keyword.SWAP) and not swap_targets(target).has(second):
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
	var blasted := false   # a vent that blasted deals damage, for the Sponsorship tally
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
			var before := who.heat
			who.heat = maxi(0, who.heat - f.power)
			log.append("%s vents %s by %d" % [ms.unit.display_name, who.unit.display_name, f.power])
			# The Thermal Ejection Manifold (the Whip Scorpion's, 12 and 13 October): a vent it
			# spends on itself blasts a random foe for the heat it took off; a vent on an ally
			# blasts nothing, and so does an ally's vent on it.
			if who == ms and Effects.vent_blast(ms.unit) > 0.0 and before > who.heat:
				_blast(ms, int(roundf(float(before - who.heat) * Effects.vent_blast(ms.unit))))
				blasted = true
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
			# The sixth shot (the Cassowary's, Ryan's kit of 18 October): the spend the count
			# lands on doubles its damage and the stacks it lays (an nth_shot rule read through
			# the pipeline); every weapon spend counts, and spends the machine's Spun Up whole.
			if Effects.nth_shot_due(ms.unit):
				log.append("%s: the %s shot counts double" % [ms.unit.display_name, Effects.ordinal(Effects.counts_shots(ms.unit))])
			_resolve_attack(mech_index, ms, f, target)
			if f.has(Face.Keyword.SWAP) and target.alive():
				_swap(target, second)
			if Effects.counts_shots(ms.unit) > 0:
				Effects.stack(ms.unit, Effects.STATUS["shots"], Effects.SKIRMISH, "count", 1, Effects.DECAY_NONE)
			if Effects.remove(ms.unit, "spun_up"):
				log.append("%s: the spin is spent" % ms.unit.display_name)
	# The brace (Ryan, 12 October; the Breaching Plow's in place of the Glacis): spending the
	# entry Braces its owner until the round's end, so the plate stands behind the charge
	# through the enemy's turn and is gone when the next round opens.
	if f.braces > 0 and ms.alive():
		var bm := Effects.grant_buff(ms.unit, "braced", f.braces, "brace:" + f.component, round)
		if bm != null:
			log.append("%s braces: %s ×%d" % [ms.unit.display_name, bm.name, f.braces])
	_shift_form(ms, f, target)
	if f.kind != Face.Kind.BLANK:
		var deals := blasted or (f.is_attack() and (f.power > 0 or f.power_max > 0))
		var measure := "damaging_spends" if deals else "quiet_spends"
		sponsorship[measure] = int(sponsorship[measure]) + 1
	# The Siphon (the Whip Scorpion's, 20 October): every blow a foe lands on its owner this
	# round adds the entry's heat, next round's fuel (Siphoning, until the round's end).
	if f.heat_per_blow > 0 and ms.alive():
		Effects.grant_for_rounds(ms.unit, Effects.siphon_status(f.heat_per_blow), "siphon:" + f.component, round)
		log.append("%s siphons: +%d heat for every blow it takes this round" % [ms.unit.display_name, f.heat_per_blow])
	ms.assigned = true
	# A cooldown (Ryan, 14 October): the entry goes dark for the rounds it prints, this one
	# included, shown on the die with the rounds left; Rapid's switch-off is a cooldown of one,
	# the rest of this round, there to stop an infinite turn (Face.cooldown_rounds).
	var cd := f.cooldown_rounds()
	if cd > 0:
		Effects.disable_entry(ms.unit, ms.face_index, "cooldown", round + cd - 1)
	# Rapid: the die rerolls for free (never the same entry; a copy of it may come up, so
	# stacked copies chain, the cooldown of each copy its own), and the mech may act again.
	# A spin (the Spin-Up's, Ryan's exception to the reroll rule, 19 October) is a true roll
	# over every entry, itself included; a stepping die's free reroll steps it.
	if f.has(Face.Keyword.RAPID):
		if f.spins:
			ms.face_index = ms.die.roll(rng)
		elif Effects.steps_die(ms.unit):
			ms.face_index = _step(ms)
		else:
			ms.face_index = ms.die.reroll(rng, ms.face_index)
		ms.assigned = false
		log.append("%s: %s" % [ms.unit.display_name, "the cylinder spins" if f.spins else "rapid, rolls again"])
	# Rolling again on a status (the Nemesis's fists on rage, Ryan, 12 October): spending the
	# entry spends a stack, if its owner has one, and the die rolls again, a plain roll as the
	# round opens. Not Rapid's reroll, which never lands on the entry just spent: a plain roll
	# may show the same fist again. Nothing switches off: the stacks are the limit, and a fist
	# that shows again punches again. A fight already won rolls nothing.
	elif not f.rolls_again_on.is_empty() and ms.alive() and not (field_foes().is_empty() and reinforcements.is_empty()) \
			and Effects.spend_stacks(ms.unit, f.rolls_again_on, 1) > 0:
		ms.face_index = _roll(ms)
		ms.assigned = false
		log.append("%s: %s, rolls again (%d left)" % [ms.unit.display_name, str(Effects.STATUS.get(f.rolls_again_on, {}).get("name", f.rolls_again_on)).to_lower(), Effects.stacks_of(ms.unit, f.rolls_again_on)])
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
	for f in field_foes():
		Effects.halve(f)   # a foe's halving statuses (Flak) halve at the round's end, Overcharged's clock
	_trim_overshield()
	_regrow_parts()
	_reinforce(true)    # the reinforcement phase: a random waiting foe of the right rank per empty slot
	_refresh_guards()
	_refresh_allies()
	_check_outcome()
	if outcome == Outcome.NONE:
		state = State.ROUND_START
	return outcome


## The end of the player's turn (Ryan, 11 October): heat over the maximum burns hull now,
## before the enemy acts, so an overheat is the machine's own doing on its own turn, like a
## volatile bite. A machine it wrecks is gone before the enemy strikes, and a fight it
## decides ends here. A foe's Burning adds its heat just before it (13 October), so a vent
## made room for it or a cleanse took it off. Shared by END TURN and a withdrawal.
func _end_player_turn() -> void:
	overheats.clear()
	_burn_mechs()
	_seal_heat()
	_settle_heat()
	_refresh_allies()
	_check_outcome()


## The enemy's turn: every foe on the field acts in order, statuses tick, timed effects run
## out. Shared by the end of a round and by a withdrawal.
func _enemy_turn() -> void:
	turn_events.clear()
	turn_specials.clear()
	_rallies.clear()
	_seq = 0
	# Foes act in the order they stand: front rank left to right, then the back rank. Each
	# foe's statuses tick at the start of its action (burning may kill it first; vitriol eats
	# its share of what is left and finishes nobody), a suppressed foe skips, and a foe with
	# two strikes lands two separate blows, so a shield stops the first and the second reaches
	# the hull. A web on the foe bursts at the end of its action, skipped or not (18 October).
	_acted.clear()
	for f in field_foes():
		if not f.alive():
			continue   # killed by a die this round; it stands until the dead are cleared, and does nothing
		var tick := Effects.tick(f, false)   # a halving status (Flak) waits for the round's end
		var share := int(tick.get("share", 0))
		if int(tick["hp"]) - share > 0:
			log.append("%s burns for %d" % [f.display_name, int(tick["hp"]) - share])
		if share > 0:
			log.append("vitriol eats %s for %d" % [f.display_name, share])
		if int(tick["hp"]) > 0:
			f.hp -= int(tick["hp"])
			if not f.alive():
				continue   # burnt to death before it acts: a web it carried goes with it
		var more := true
		if not tick["skip"]:   # a suppressed foe does nothing, and a web on it still bursts
			more = _foe_turn(f)
		_web_burst(f)
		if not more:
			break
	_acted.clear()
	_clear_dead()
	# The rallies land now, on the foes still standing: Kindled at each rally's own value,
	# live from the next round (its intents drawn with it) and gone after it.
	for r in _rallies:
		var other: Foe = r[0]
		if other.alive() and field_foes().has(other):
			Effects.grant_for_rounds(other, Effects.kindled(int(r[1])), str(r[2]), round + 1)
	_rallies.clear()
	for ms in mechs:
		Effects.end_round(ms.unit, round)   # timed effects run out
	for f in field_foes():
		Effects.end_round(f, round)


## One foe's action in the enemy's turn: its pick (or a new one, its machine gone), its
## countdown gathering, its blow at one machine or at every machine, or its special in place of
## a blow; then a self-destruct spends it. False when no machine stands to act on, which ends
## the turn.
func _foe_turn(f: Foe) -> bool:
	var t := f.target as MechState
	if t == null or not t.alive():
		t = _pick_mech_target(f)
	if t == null:
		return false
	_acted.append(f)   # from its first blow, a suppress landing on it costs its next action
	if not f.pending.is_empty():
		if f.charge > 0:
			# A countdown move gathers this turn and lands when its count runs out; the
			# plaque names it as it begins, so the warning has a voice (15 October).
			if f.charge == Foe.countdown_of(f.pending):
				turn_specials.append({"foe": f, "name": str(f.pending.get("name", "")), "kind": "charge", "seq": _seq})
				_seq += 1
			f.charge -= 1
			var when := "next round" if f.charge == 0 else "in %d rounds" % (f.charge + 1)
			log.append("%s gathers: %s lands %s" % [f.display_name, str(f.pending.get("name", "")), when])
			return true
		f.pending = {}   # it lands now
	if f.hits_all():
		# A blow at every machine (`all`, Ryan, 15 October): its strikes land on each live
		# machine in turn, left to right, so no aim or lure moves it; a screened machine is
		# out of it.
		for m in live_mechs():
			if _screened.has(m):
				log.append("%s's blow on %s is lost in the static" % [f.display_name, m.unit.display_name])
				continue
			_strike(f, m)
	else:
		if _screened.has(t):
			log.append("%s's blow is lost in the static" % f.display_name)
			return true
		if not f.attacks():
			_foe_acts(f, t)   # a defend, buff or debuff instead of a blow
			return true
		_strike(f, t)
	if f.has_keyword(f.action, "self_destruct") and f.alive():
		# The blow spends the striker (the Bomb): it dies whole and never gets back up.
		f.hp = 0
		f.stays_down = true
		log.append("%s bursts, and is gone" % f.display_name)
	return true


## The web bursts at the end of the webbed foe's action (the funnel-web's Web Bomb, Ryan's go,
## 18 October): a Suppress on it, costing its next action since it has acted (its countdown
## held a round, if it gathers one), and one on the next foe to act beside it (web_catch), each
## resisted by its own Numbed; a foe already suppressed for that action gains nothing, as from
## any second suppress, so a web on a foe the team has stunned is spent on the neighbour alone.
## The web is spent either way. A foe gone by the end of its action (a Bomb's burst) takes its
## web with it, as one killed before it does.
func _web_burst(f: Foe) -> void:
	if not f.alive() or not Effects.has(f, "webbed"):
		return
	Effects.remove(f, "webbed")
	var beside := web_catch(f)
	log.append("%s's web bursts%s" % [f.display_name, "" if beside == null else ", catching %s" % beside.display_name])
	if _suppress(f):
		_foe_gained_status(f, "suppressed")
	if beside != null and _suppress(beside):
		_foe_gained_status(beside, "suppressed")


## The foe a web on `f` catches: the next to act beside it, its right-hand neighbour in its
## rank (which acts after it, so the burst costs this round's action), or with none standing
## there the one to its left (which has acted, and loses its next); a massive foe stands in
## both ranks, so it is beside either. Null with nobody standing beside it.
func web_catch(f: Foe) -> Foe:
	if f.column < 0 or f.rank < 0:
		return null
	var row: Array = front if f.rank == 0 else back
	for c in [f.column + 1, f.column - 1]:
		if c < 0 or c >= columns:
			continue
		var n: Foe = row[c]
		if n != null and n != f and n.alive():
			return n
	return null


## A foe's blows on one machine: each strike lands on its own, against the shield the one
## before left, and each carries the move's riders unless a Ward turns them away.
func _strike(f: Foe, t: MechState) -> void:
	var turned := false
	for s in range(f.strikes()):
		if not t.alive():
			break
		_damage_mech(t, f.damage(), f)
		var ev: Dictionary = turn_events[turn_events.size() - 1]
		# The live hull (the Armadillo's, a machine under Retaliate): a blow that reaches
		# hull shocks the foe that struck; a shutters' blocked blow (the shield took it whole)
		# shocks too, and a blow a Barrier took never touched either. Shocked is a setup and
		# nothing else (Ryan, 11 October): the discharge a Shocked striker paid was thorns,
		# scaling with the blows a horde lands, and it went.
		if not bool(ev["barred"]) and Effects.shocks_striker(t.unit, bool(ev["blocked"])):
			_shock(f, t)
		# A Ward turns away every rider a foe's blows lay this round; the damage has landed.
		if Effects.has(t.unit, "ward"):
			if t.alive() and _rides(f) and not turned:
				log.append("%s: the Ward turns %s's riders away" % [t.unit.display_name, f.display_name])
				turned = true
			continue
		if f.has_keyword(f.action, "scorch") and t.alive():
			_fire_on(t, "scorched", 1, f)
			log.append("%s scorches %s" % [f.display_name, t.unit.display_name])
		if f.has_keyword(f.action, "burn") and t.alive():
			_fire_on(t, "burning_mech", 1, f)
			log.append("%s sets %s burning" % [f.display_name, t.unit.display_name])
		if f.has_keyword(f.action, "disable") and t.alive() and t.face_index >= 0:
			# The entry the die shows is switched off through the mech's next turn.
			Effects.disable_entry(t.unit, t.face_index, "foe:" + f.content_id, round + 1)
			log.append("%s disables %s's %s" % [f.display_name, t.unit.display_name, t.die.faces[t.face_index].describe()])
		if f.has_keyword(f.action, "corrupt") and t.alive() and t.face_index >= 0:
			# The entry the die shows is corrupted for the fight: it bites when spent.
			Effects.corrupt_entry(t.unit, t.face_index, "foe:" + f.content_id)
			log.append("%s corrupts %s's %s (×%d)" % [f.display_name, t.unit.display_name, t.die.faces[t.face_index].describe(), Effects.corrupt_stacks(t.unit, t.face_index)])
		if f.has_keyword(f.action, "silence") and t.alive():
			_silence(t, f)
		if f.has_keyword(f.action, "dispel") and t.alive():
			_purge(t, f)


## Whether this foe's blows carry a rider a Ward turns away: a scorch, a burn, a disable, a
## corrupt, a silence or a purge (the breach is the Ward's too, in _damage_mech).
static func _rides(f: Foe) -> bool:
	for kw in ["scorch", "burn", "disable", "corrupt", "silence", "dispel"]:
		if f.has_keyword(f.action, kw):
			return true
	return false


## A Swap (the Dingo's Combat Translocator, Ryan's go of 19 October; built 21 October): the
## first target and the second trade places, a foe for a foe, or the foe into an empty slot (a
## back foe into an empty front slot is a pull). A foe keeps its pick and its move; the rank it
## stands in is the swap's, so a caster pulled forward stands exposed to Direct fire.
func _swap(first: Foe, second) -> void:
	var from := Vector2i(first.rank, first.column)
	if second is Foe:
		var other: Foe = second
		var to := Vector2i(other.rank, other.column)
		_place(other, from.x, from.y)
		_place(first, to.x, to.y)
		log.append("%s and %s trade places" % [first.display_name, other.display_name])
	elif second is Vector2i:
		var slot: Vector2i = second
		if from.x == 0:
			front[from.y] = null
		else:
			back[from.y] = null
		_place(first, slot.x, slot.y)
		log.append("%s is moved to the %s rank" % [first.display_name, "front" if slot.x == 0 else "back"])
	_refresh_kin()
	_refresh_guards()


## Silenced (Ryan, 17 and 18 October; built 21 October): its buffs and stores count for nothing
## and its keywords are muted through its next round, as a foe's Disabled lasts: the foe acts
## as the round ends, so "the round" a silence costs is the machine's next.
func _silence(t: MechState, f: Foe) -> void:
	Effects.grant_for_rounds(t.unit, Effects.STATUS["silenced"], "foe:" + f.content_id, round + 1)
	log.append("%s silences %s: its buffs sleep and its keywords are muted through its next round" % [f.display_name, t.unit.display_name])


## A purge: every buff and store the machine carries goes, every stack.
func _purge(t: MechState, f: Foe) -> void:
	var gone := Effects.purge(t.unit)
	log.append("%s purges %s%s" % [f.display_name, t.unit.display_name, ": " + ", ".join(gone) + " gone" if not gone.is_empty() else ", and finds nothing to take"])


## The round ends with the machines' statuses ticking, after the enemy has struck. Burning and
## Scorched are not among them: they tick at the end of the player's turn (_burn_mechs).
func _tick_mechs() -> void:
	for ms in live_mechs():
		var t := Effects.tick(ms.unit)
		if int(t["heat"]) > 0:
			log.append("%s: %d heat from its statuses" % [ms.unit.display_name, int(t["heat"])])
			_add_heat(ms, int(t["heat"]))


## The end of the player's turn, before the overheat (Ryan, 13 October): each machine's
## Burning adds its heat, so a vent made room for it or a cleanse took it off; Burning loses a
## stack and Scorched goes.
## The heat a sealed machine runs at the end of its turn (the Armadillo's Lockdown): the
## seal's own number, or nothing.
func seal_heat(ms: MechState) -> int:
	if not Effects.is_sealed(ms.unit):
		return 0
	return int(Effects.seal_form(ms.unit).get("heat", 0))


## Sealed machines run hotter at the end of the player's turn, after Burning and before the
## overheat (Burning's timing), so the clock bites where a vent can answer it.
func _seal_heat() -> void:
	for ms in live_mechs():
		var h := seal_heat(ms)
		if h > 0:
			log.append("%s runs sealed: +%d heat" % [ms.unit.display_name, h])
			_add_heat(ms, h)


## The form change (the Armadillo's Lockdown, Ryan's framework of 15 October, his go 20
## October): a shield spent on itself seals the machine, a vent or a weapon that deals damage
## opens it; a shield on an ally, a buff, and a weapon of no damage (its lures) leave the form
## as it is. The seal is one chip carrying the passive's armour; the heat clock and the
## stopped cooling read it.
func _shift_form(ms: MechState, f: Face, target) -> void:
	var seal := Effects.seal_form(ms.unit)
	if seal.is_empty() or not ms.alive():
		return
	if f.kind == Face.Kind.SHIELD and (not (target is MechState) or target == ms):
		if not Effects.is_sealed(ms.unit):
			Effects.stack(ms.unit, Effects.sealed_status(int(seal["armour"]), int(seal["heat"])), Effects.SKIRMISH, "seal", 1, Effects.DECAY_NONE)
			log.append("%s seals: armour +%d, its own cooling stopped, +%d heat a turn" % [ms.unit.display_name, int(seal["armour"]), int(seal["heat"])])
	elif f.kind == Face.Kind.VENT or (f.is_attack() and (f.power > 0 or f.power_max > 0)):
		if Effects.remove(ms.unit, "sealed"):
			log.append("%s opens" % ms.unit.display_name)


func _burn_mechs() -> void:
	for ms in live_mechs():
		var t := Effects.turn_tick(ms.unit)
		if int(t["heat"]) > 0:
			log.append("%s burns: +%d heat" % [ms.unit.display_name, int(t["heat"])])
			_add_heat(ms, int(t["heat"]))


## A foe's fire on a machine (Ryan, 13 October: Burn and Scorch; foes heat machines only
## through them): stacks of Burning or Scorched for the skirmish, decaying as each says at the
## end of the player's turn (Burning a stack, Scorched every stack).
func _fire_on(t: MechState, id: String, n: int, f: Foe) -> void:
	Effects.stack(t.unit, Effects.STATUS[id], Effects.SKIRMISH, "foe:" + f.content_id, n, Effects.status_decay(Effects.STATUS[id]))


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
	# Every foe one strike reaches (a Spread's neighbours, a Penetrate's column), the same for
	# each strike, since a kill clears its slot only after the spend.
	var hit := reached_by(f, target)
	# What this machine's passives lay on each foe reached, judged alone and read now, before
	# any strike's riders land (the funnel-web's Ambush, 18 October: a Suppress gun never feeds
	# its own read): foe -> [[status id, stacks a hit], ...]; and what was laid, for the log.
	var lays := {}
	for foe in hit:
		var l := Effects.laid_statuses(ms.unit, f, foe)
		if not l.is_empty():
			lays[foe] = l
	var laid := {}
	var webbed: Array[Foe] = []
	var doubled := Effects.stack_multiplier(ms.unit, f, target)   # the stacks this spend lays, multiplied (the sixth shot)
	var thawed := 0   # Cryo stacks this spend's damaging hits spent, cooling the hitter after its heat lands
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
		var landed := dmg
		for foe in hit:
			var was_alive := foe.alive()
			var hp_before := foe.hp
			if not reached.has(foe):
				reached.append(foe)
			# Spillover (Overwhelm until 6 October): damage past the kill of a front-rank foe carries
			# into the foe behind it (_spill). A massive foe fills its column: nothing is behind it.
			var spills := f.has(Face.Keyword.SPILLOVER) and foe.rank == 0 and not foe.is_massive()
			if spills and not was_alive:
				# A later strike on a foe an earlier strike of this spend killed (Ryan, 15 October:
				# "All its damage or subsequent strikes spill over"): the fallen foe takes nothing
				# more, its armour included, and the strike's whole number goes on behind it; with
				# nothing standing there, it is lost. The blow's record counts it whole, as it
				# counts the killing strike's excess.
				_spill(ms, f, foe, dmg, hit)
				if foe == target:
					landed = dmg
				continue
			# What the foe takes of the blow: its own statuses read last (a Shocked foe takes
			# double, and the shock is spent by the blow), then its armour comes off, flat, so
			# small blows bounce off a braced foe the way they do off a heavy machine.
			var taken := Effects.damage_taken(foe, dmg, ms.unit)
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
			# A hit lays what the passives lay on this foe, a stack per strike that lands with a
			# number: a blow of nothing (the web, a lure) is no hit, and a strike on a foe an
			# earlier one killed lays nothing on it.
			if was_alive and dmg > 0 and lays.has(foe):
				for pair in lays[foe]:
					var sid := str(pair[0])
					var n_laid := _stacks_from(ms, sid, int(pair[1])) * doubled
					Effects.stack(foe, Effects.STATUS[sid], Effects.SKIRMISH, "mech", n_laid, Effects.status_decay(Effects.STATUS[sid]))
					_note_status(gained, foe, sid)
					var per: Dictionary = laid.get(foe, {})
					per[sid] = int(per.get(sid, 0)) + n_laid
					laid[foe] = per
			if was_alive and not foe.alive() and f.devours > 0:
				_overcharge_on_kill(ms, foe, f.devours)
			# The killing strike: what it had past the kill carries on.
			if spills and was_alive and not foe.alive():
				_spill(ms, f, foe, taken - hp_before, hit)
			if f.has(Face.Keyword.BURN):
				# Burn is a numbered keyword (Ryan, 18 October): the stacks it says, whatever the
				# blow dealt (it was a stack per 10 of the damage, rounded up, until then).
				Effects.stack(foe, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", _stacks_from(ms, "burning", f.burn) * doubled)
				_note_status(gained, foe, "burning")
			if f.has(Face.Keyword.SUPPRESS) and _suppress(foe):
				_note_status(gained, foe, "suppressed")
			# Web (18 October): the foe is Webbed, one web however often it is webbed, and the
			# skirmish bursts it at the end of the foe's action (_web_burst).
			if f.has(Face.Keyword.WEB) and foe.alive() and not Effects.has(foe, "webbed"):
				Effects.stack(foe, Effects.STATUS["webbed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
				_note_status(gained, foe, "webbed")
				webbed.append(foe)
			# Cryo (20 October): a damaging hit spends every stack the foe carries, and the hitter
			# cools for them once the spend's own heat has landed (below); a blow of nothing
			# spends none. Then the blow's own Cryo lands, after the cash, so a damaging Cryo
			# weapon never eats what it lays.
			if was_alive and dmg > 0 and Effects.has(foe, "cryoed"):
				thawed += Effects.stacks_of(foe, "cryoed")
				Effects.remove(foe, "cryoed")
			if f.has(Face.Keyword.CRYO) and foe.alive():
				Effects.stack(foe, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", _stacks_from(ms, "cryoed", f.cryo) * doubled, Effects.DECAY_NONE)
				_note_status(gained, foe, "cryoed")
			# Flak (Ryan's go, 19 October; built 21 October): each foe hit gains the keyword's
			# number in stacks, whatever the blow dealt, after the blow, so the blow that lays it
			# never feeds on it; a later strike of the same spend does.
			if f.has(Face.Keyword.FLAK) and foe.alive():
				Effects.stack(foe, Effects.STATUS["flakked"], Effects.SKIRMISH, "mech", _stacks_from(ms, "flakked", f.flak) * doubled, Effects.DECAY_HALF)
				_note_status(gained, foe, "flakked")
			if foe.alive() and not touched.has(foe):
				touched.append(foe)
		total += landed
		rolled_total += rolled
	for foe in laid.keys():
		var bits: Array[String] = []
		for sid in laid[foe].keys():
			bits.append("%s ×%d" % [str(Effects.STATUS[sid]["name"]), int(laid[foe][sid])])
		log.append("%s lays %s on %s" % [ms.unit.display_name, ", ".join(bits), foe.display_name])
	for foe in webbed:
		var caught := web_catch(foe)
		log.append("%s webs %s: it bursts after its action%s" % [ms.unit.display_name, foe.display_name, "" if caught == null else ", on it and %s" % caught.display_name])
	if extra_burn > 0:
		Effects.stack(target, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", _stacks_from(ms, "burning", extra_burn) * doubled)
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
	if thawed > 0:
		var cooled := mini(ms.heat, thawed * CRYO_COOL_PER_STACK)
		ms.heat -= cooled
		log.append("%s cashes Cryo ×%d: -%d heat" % [ms.unit.display_name, thawed, cooled])
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


## A vent's blast (the Whip Scorpion's Thermal Ejection Manifold): the heat it took off, as
## one blow of the machine's on a live foe drawn from the seeded stream, back rank included,
## through the damage pipeline (the machine's adds and multiplies, then the foe's own: its
## Flak, a Shocked doubling spent, its armour). A kill clears its slot as any blow's does.
func _blast(ms: MechState, amount: int) -> void:
	var live: Array[Foe] = []
	for foe in field_foes():
		if foe.alive():
			live.append(foe)
	if live.is_empty() or amount <= 0:
		return
	var foe: Foe = live[rng.randi_range(0, live.size() - 1)]
	var shot := Face.attack(amount, Face.Reach.INDIRECT)   # the blast as a blow, for the pipeline
	var dmg := int(Effects.attack(ms.unit, shot, amount, 0, foe)["damage"])
	var taken := Effects.damage_taken(foe, dmg, ms.unit)
	var armoured := mini(taken, foe.armour_total())
	taken -= armoured
	foe.hp -= taken
	if dmg > 0 and Effects.remove(foe, "shocked"):
		log.append("%s: the shock lands, %d doubled" % [foe.display_name, dmg])
	log.append("%s's vent blasts %s for %d%s" % [ms.unit.display_name, foe.display_name, taken, " (armour -%d)" % armoured if armoured > 0 else ""])
	last_blast = {"mech": mechs.find(ms), "foe": foe, "dealt": taken}
	_clear_dead()


## Every foe one strike of an entry reaches from its target, each once: the target, a Spread's
## neighbours in its rank, a Penetrate's other rank of its column; a foe killed this round
## still standing in its slot included, as the strikes find it. The resolver and the bot read
## the same list.
func reached_by(f: Face, target: Foe) -> Array[Foe]:
	var hit: Array[Foe] = [target]
	# A reach over every foe in the fight (the Whip Scorpion's Siphon, a lure-all), front and back.
	if f.reaches_all:
		for foe in field_foes():
			if not hit.has(foe):
				hit.append(foe)
		return hit
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
	return hit


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
		"brace":
			# Armoured, the machines' status (Ryan, 16 October: an effect and the buff it creates
			# share a name; Braced until 18 October): the move's value in stacks of armour, a
			# point each, flat off every blow, every stack going at once at the foe's next action
			# (its tick), as a foe's armour from a defend always lasted.
			var n := Effects.brace_stacks(value)
			if n > 0:
				Effects.stack(f, Effects.STATUS["braced"], Effects.SKIRMISH, "foe:" + f.content_id, n, Effects.status_decay(Effects.STATUS["braced"]))
			log.append("%s: %s, %s ×%d (armour +%d until its next action)" % [f.display_name, str(a.get("name", "braces")), Effects.STATUS["braced"]["name"], n, n * Effects.braced_armour()])
		"regrow":
			var before := f.hp
			f.hp = mini(f.hp_max, f.hp + value)
			log.append("%s: %s, regrows %d" % [f.display_name, str(a.get("name", "regrows")), f.hp - before])
		"regrow_ally":
			# Foes helping foes (15 October): the most hurt of its own by hull missing, itself
			# included, the first in the order they stand on a tie.
			var hurt: Foe = null
			for other in field_foes():
				if other.alive() and other.hp < other.hp_max and (hurt == null or other.hp_max - other.hp > hurt.hp_max - hurt.hp):
					hurt = other
			if hurt == null:
				log.append("%s: %s, and none of its own is hurt" % [f.display_name, str(a.get("name", "cures"))])
			else:
				var before := hurt.hp
				hurt.hp = mini(hurt.hp_max, hurt.hp + value)
				log.append("%s: %s, %s regrows %d" % [f.display_name, str(a.get("name", "cures")), hurt.display_name, hurt.hp - before])
		"brace_all":
			# Armoured on every foe in the fight through the next round, so it stands through the
			# player's turn and is gone when the enemy acts again: its next action, as the
			# player sees it, which going at each foe's own tick would cut short for the foes
			# acting after it.
			var n := Effects.brace_stacks(value)
			var braced := 0
			for other in field_foes():
				if other.alive() and n > 0:
					Effects.stack(other, Effects.STATUS["braced"], Effects.ROUNDS, "foe:" + f.content_id, n, Effects.DECAY_NONE, round + 1)
					braced += 1
			log.append("%s: %s, %d of its own %s ×%d (armour +%d through the next round)" % [f.display_name, str(a.get("name", "protects")), braced, Effects.STATUS["braced"]["name"], n, n * Effects.braced_armour()])
		"revive_once":
			Effects.stack(f, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_NONE)
			log.append("%s: %s (it will return once)" % [f.display_name, str(a.get("name", "readies"))])
		"revive_once_ally":
			# Reraise on an ally (Ryan, 16 October: the promoted Cleric's, cast on the other
			# party members, never itself): Getting Back Up on one of its own.
			var ally := _unready_ally(f)
			if ally == null:
				log.append("%s: %s, and none of its own needs readying" % [f.display_name, str(a.get("name", "readies"))])
			else:
				Effects.stack(ally, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_NONE)
				log.append("%s: %s, %s will return once" % [f.display_name, str(a.get("name", "readies")), ally.display_name])
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
			# Kindled goes live from the next round, when intents are drawn with it (13
			# October): the grant waits until the enemy's turn is over (_enemy_turn), so a foe
			# striking after the rallier this turn hits the number it showed, and it carries
			# the move's own value (the Howl's 5, Stoke the Forge's 10), never a fixed 10.
			var rallied := 0
			for other in field_foes():
				if other != f and other.alive():
					_rallies.append([other, maxi(0, value), "foe:" + f.content_id])
					rallied += 1
			log.append("%s: %s, %d hit %d harder next round" % [f.display_name, str(a.get("name", "rallies")), rallied, value])
		"drain_rerolls":
			reroll_debt += maxi(0, value)
			log.append("%s: %s, the team loses %d reroll%s next round" % [f.display_name, str(a.get("name", "roars")), value, "" if value == 1 else "s"])
		"burn":
			_fire_on(t, "burning_mech", maxi(1, value), f)
			log.append("%s: %s, %s burning ×%d" % [f.display_name, str(a.get("name", "stokes")), t.unit.display_name, maxi(1, value)])
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
		"silence":
			# A caster's silence (17 October): no blow, the machine Silenced for the round.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "silences")), t.unit.display_name])
			else:
				_silence(t, f)
		"dispel":
			# A hero's or a boss's purge (17 October): no blow, every buff and store gone.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "purges")), t.unit.display_name])
			else:
				_purge(t, f)
		"scorch_all":
			var names: Array[String] = []
			for ms in live_mechs():
				_fire_on(ms, "scorched", maxi(1, value), f)
				names.append(ms.unit.display_name)
			log.append("%s: %s, %s scorched ×%d" % [f.display_name, str(a.get("name", "erupts")), ", ".join(names), maxi(1, value)])
		"corrupt_all":
			var hit_names: Array[String] = []
			for ms in live_mechs():
				if ms.face_index >= 0:
					Effects.corrupt_entry(ms.unit, ms.face_index, "foe:" + f.content_id)
					hit_names.append(ms.unit.display_name)
			log.append("%s: %s, the showing component of %s is corrupted" % [f.display_name, str(a.get("name", "unravels")), ", ".join(hit_names) if not hit_names.is_empty() else "nobody"])
		_:
			log.append("%s: %s" % [f.display_name, str(a.get("name", "acts"))])


## The one a Reraise on an ally readies: a live foe on the field other than the caster, not
## readied already and able to get back up (one gone whole cannot); a party member before the
## rest of its own, the heaviest hitter first (Foe.threat), then the order they stand. Null
## when there is none.
func _unready_ally(caster: Foe) -> Foe:
	var best: Foe = null
	for o in field_foes():
		if o == caster or not o.alive() or o.stays_down or Effects.has(o, "risen"):
			continue
		if best == null or (o.hero and not best.hero) or (o.hero == best.hero and o.threat() > best.threat()):
			best = o
	return best


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


## Spillover: `amount` of a blow, past the kill of the front-rank `foe`, carries into the foe
## behind it in the column as plain damage, through that foe's own damage taken and its armour;
## it spends a shock and feeds the talons' kill rule, and carries no other keyword of the blow. A foe behind
## that the blow already reaches (a penetrate) takes the strike itself, never a spill too, and
## one already fallen takes nothing: nothing stands behind the back rank, so the damage is lost.
func _spill(ms: MechState, f: Face, foe: Foe, amount: int, hit: Array[Foe]) -> void:
	var behind: Foe = back[foe.column] if foe.column >= 0 and foe.column < columns else null
	if amount <= 0 or behind == null or not behind.alive() or hit.has(behind):
		return
	var behind_taken := maxi(0, Effects.damage_taken(behind, amount, ms.unit) - behind.armour_total())
	behind.hp -= behind_taken
	Effects.remove(behind, "shocked")
	log.append("%s spills over: %d into %s" % [ms.unit.display_name, behind_taken, behind.display_name])
	if not behind.alive() and f.devours > 0:
		_overcharge_on_kill(ms, behind, f.devours)


## The Soulcutter Talons' rule (28 September; built 29 September; a rule printed on its one
## carrier and no keyword to learn since 11 October, Ryan: "devour is not a thing"): every foe
## the entry kills gives its owner `per_kill` stacks of Overcharged (a spread that kills two
## feeds twice, a chain feeds on every link). The stacks halve each round like any Overcharged;
## on the Ammit its Quintessence Tap keeps them for the battle (Effects.stack applies the keep).
func _overcharge_on_kill(ms: MechState, foe: Foe, per_kill: int) -> void:
	var stacks := _stacks_from(ms, "overcharged", per_kill)
	var m := Effects.stack(ms.unit, Effects.STATUS["overcharged"], Effects.SKIRMISH, "kill", stacks, Effects.status_decay(Effects.STATUS["overcharged"]))
	log.append("%s kills %s: %s ×%d" % [ms.unit.display_name, foe.display_name, m.name, Effects.stacks_of(ms.unit, "overcharged")])


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


## Suppress: the foe loses its next action (this round's, or the next round's when it has
## already acted this turn), then grows Numbed (two stacks, three for a massive foe). It
## resists at its own base resistance plus 10% a stack, on the skirmish's own die (Ryan, 26
## September): a suppress it shrugs off does nothing at all and numbs it no further, and
## Numbed loses a stack at each of the foe's turns, so a stun repeated on one foe stops
## landing while stuns spread across the formation keep working. A foe already suppressed
## gains nothing more, Numbed included: Suppressed never stacks and never carries (Ryan, 17
## October: "Suppressed is suppressed - they lose their next action. It does not stack, it
## does not carry"), so a Paradox tripping on a suppressed foe is wasted, its meter spent.
func _suppress(foe: Foe) -> bool:
	# A foe that has already acted this turn loses its next action instead of one it has taken.
	var next := _acted.has(foe)
	if _suppressed_through(foe, round + 1 if next else round):
		log.append("%s is already suppressed" % foe.display_name)
		return false
	var resist := foe.resist_total()
	if resist > 0 and rng.randi_range(1, 100) <= resist:
		log.append("%s shrugs off the suppression (%d%% resistant)" % [foe.display_name, resist])
		return false
	Effects.grant_for_rounds(foe, Effects.STATUS["suppressed"], "mech", round + 1 if next else round)
	Effects.stack(foe, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", NUMBED_PER_SUPPRESS_MASSIVE if foe.is_massive() else NUMBED_PER_SUPPRESS, Effects.DECAY_TICK)
	return true


## Is the foe's action of round `r` already lost to a Suppressed it carries?
func _suppressed_through(foe: Foe, r: int) -> bool:
	for m in Effects.live(foe):
		if m.id == "suppressed" and (m.expires_round < 0 or m.expires_round >= r):
			return true
	return false


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
			_suppress(foe)
			return


## Lure (decided 2 October, in place of taunt and beacon): every foe this entry reached turns
## on the spender for the round, intents and all. No status and no chip: the arrow changing
## is the record. A lured foe whose move has no target (a blow at every machine included)
## keeps doing it, and the log says so.
func _lure(ms: MechState, foes: Array) -> void:
	var turned: Array[String] = []
	var idle: Array[String] = []
	for foe in foes:
		if not foe.alive():
			continue
		if foe.hits_all() or foe.acts_on_nobody():
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
		foe.pending = {}   # a gathered move is broken off
		foe.charge = 0
		foe.action = next
		foe.last_special = "" if foe.attacks() else str(foe.action.get("id", ""))
		_begin_countdown(foe)
		foe.target = _pick_mech_target(foe)
		log.append("%s is disrupted: %s instead of %s" % [foe.display_name, str(next.get("name", "")), was])


## The cleanse keyword on a shield or vent component: whoever it was spent on loses every
## cleansable status (a foe's disable, Corrupted, Scrambled, Burning, Scorched), and the log says which.
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


## One blow. The honest shield (Ryan, 14 October; built 21 October): the shield absorbs its
## number and the excess reaches the hull; a breach ignores the shield, which stands. A blow
## that reaches the hull loses the chassis's armour first, so small hits bounce off a heavy
## machine, and it injures a component when what gets through is at least a quarter of max
## hull. A Barrier takes the next blow whole; a Ward turns a breach away. A shield sized to a
## telegraphed blow, or a Barrier, is the counterplay.
func _damage_mech(ms: MechState, amount: int, source: Foe) -> void:
	amount = Effects.damage_taken(ms.unit, amount, source)   # buffs and debuffs on damage taken, before shield and armour; the striker read for its statuses
	# A Barrier takes the next blow that deals anything, whole, and is spent; a blow of nothing
	# leaves it standing (Shocked's mirror). A Ward turns a breach away, so the shield absorbs
	# it like any blow (Ryan, 14 October).
	var barred := amount > 0 and Effects.has(ms.unit, "barrier")
	if barred:
		Effects.remove(ms.unit, "barrier")
		amount = 0
	var warded := source.breaches() and Effects.has(ms.unit, "ward")
	var breach := source.breaches() and not warded
	var r := _blow(ms.unit.shield, ms.unit.hull_max, ms.unit.armour + Effects.armour_against(ms.unit, source.rank), amount, breach)
	var had_shield := ms.unit.shield > 0
	ms.unit.shield = r["shield"]
	ms.unit.hull -= r["through"]
	var rk := "back" if source != null and source.rank == 1 else "front"
	taken_by_rank[rk] = int(taken_by_rank.get(rk, 0)) + int(r["absorbed"]) + int(r["through"])
	sponsorship["guarded"] = int(sponsorship["guarded"]) + int(r["absorbed"]) + int(r["armoured"])
	# The mech's gauges after the blow ride along, so a replay can step them down blow by blow.
	turn_events.append({"foe": source, "mech": mechs.find(ms), "absorbed": r["absorbed"], "through": r["through"],
		"blocked": r["blocked"], "barred": barred, "broke_shield": had_shield and ms.unit.shield == 0, "injured": r["injures"],
		"shield": ms.unit.shield, "hull": ms.unit.hull, "seq": _seq,
		"name": str(source.action.get("name", "")) if source != null else "", "boss": source != null and source.boss,
		"all": source != null and source.hits_all()})
	_seq += 1
	var verb := "breaches" if breach and had_shield else "hits"
	var armoured: String = " (armour -%d)" % r["armoured"] if r["armoured"] > 0 else ""
	if warded and had_shield and not barred:
		log.append("%s: the Ward turns %s's breach away" % [ms.unit.display_name, source.display_name])
	if barred:
		log.append("%s hits %s: the Barrier takes the blow" % [source.display_name, ms.unit.display_name])
	elif r["blocked"]:
		log.append("%s hits %s: shield -%d, blocked" % [source.display_name, ms.unit.display_name, r["absorbed"]])
	elif r["through"] == 0:
		log.append("%s %s %s: %sarmour holds" % [source.display_name, verb, ms.unit.display_name, "shield -%d, " % r["absorbed"] if r["absorbed"] > 0 else ""])
	elif r["absorbed"] > 0:
		log.append("%s hits %s: shield -%d, hull -%d%s" % [source.display_name, ms.unit.display_name, r["absorbed"], r["through"], armoured])
	else:
		log.append("%s %s %s: hull -%d%s" % [source.display_name, verb, ms.unit.display_name, r["through"], armoured])
	# Siphoning: every blow a foe lands adds heat, whatever it dealt, in the enemy's turn, after
	# the overheat has settled, so it is next round's fuel or next turn's burn.
	var siphoned := Effects.heat_per_blow(ms.unit)
	if siphoned > 0 and ms.alive():
		ms.heat += siphoned
		log.append("%s siphons the blow: +%d heat" % [ms.unit.display_name, siphoned])
	if int(r["through"]) > 0:
		_hull_damaged(ms)
	if r["injures"]:
		# What the injury did rides on the event too: the console says a component was
		# damaged or destroyed (Jenny's information lines, 8 October).
		turn_events[turn_events.size() - 1]["component"] = apply_injury(ms)


## The arithmetic of one blow against a shield, hull max and armour, shared by the real hit
## and the forecast. The honest shield (Ryan, 14 October): a shield absorbs its number and the
## excess passes to the hull; a breach ignores the shield outright and the shield stands.
## Returns shield after, absorbed, through (to hull), armoured (taken off by armour), blocked
## (the shield took the whole blow), injures (what reached the hull, over the threshold).
static func _blow(shield: int, hull_max: int, armour: int, amount: int, breach: bool) -> Dictionary:
	var absorbed := 0 if breach else mini(maxi(0, shield), maxi(0, amount))
	var through := maxi(0, amount) - absorbed
	# Armour comes off every blow that reaches the hull, a shield's overflow and a breach too
	# (Ryan, 11 October): a breach beats the shield, never the plate under it. A blow on the
	# shield costs it its full damage: shield is not armoured.
	var armoured := mini(armour, through) if through > 0 else 0
	through -= armoured
	# Injury counts what reaches the hull in one blow, wherever it came from: past the shield,
	# past a breach, on bare hull (the shield row: a quarter of the hull in one blow injures).
	var injures := through > 0 and through * 100 >= hull_max * CRACK_MIN_HULL_PCT
	return {"shield": shield - absorbed, "absorbed": absorbed, "through": through, "armoured": armoured, "blocked": absorbed > 0 and through + armoured == 0, "injures": injures}


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
		"buffed":
			# The buffed (21 October): the machine carrying the most stacks of buffs and stores,
			# drawn among the tied; the exposed when none carries any.
			var most: Array[MechState] = []
			var top := 0
			for ms in live:
				var n := Effects.buff_stacks(ms.unit)
				if n > top:
					top = n
					most = [ms]
				elif n == top and n > 0:
					most.append(ms)
			if most.is_empty():
				return _pick_exposed(f, live)
			return most[rng.randi_range(0, most.size() - 1)]
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
## its shield, armour, Barrier and Ward as they stand, plus half of any shield they would
## break (a shield about to fail is exposure too), and the pick is drawn by weight.
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
	if f.damage() <= 0 or ms.unit.shield <= 0:
		return 0
	var walk := {"shield": ms.unit.shield, "barrier": Effects.has(ms.unit, "barrier")}
	blows_on(ms, f, walk)
	return ms.unit.shield if int(walk["shield"]) <= 0 else 0


## The hull this foe's blows would reach on a machine as it stands: its damage, its strikes,
## its breach, against the shield, armour, Barrier, Ward and damage taken the forecast reads.
func hull_reached(f: Foe, ms: MechState) -> int:
	if f.damage() <= 0:
		return 0
	var walk := {"shield": ms.unit.shield, "barrier": Effects.has(ms.unit, "barrier")}
	var through := 0
	for r in blows_on(ms, f, walk):
		through += int(r["through"])
	return mini(through, maxi(0, ms.unit.hull))


# ---------------------------------------------------------------- formation

func _clear_dead() -> void:
	_fall_with_cores()
	_clear_dead_slots()
	_refresh_kin()
	_refresh_guards()


# ---------------------------------------------------------------- a boss in parts

## The boss in parts (Ryan, 15 October: parts that regrow, or stand for a while, until the core
## is killed, so the player chooses what to focus): a core's parts are the foes of its pack
## whose type it names, on the field. Found by pack and type, so a save needs no references.
func parts_of(core: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	if not core.has_parts():
		return out
	for f in field_foes():
		if f != core and f.alive() and f.pack_id == core.pack_id and core.part_ids.has(f.content_id):
			out.append(f)
	return out


## Every core's guard as its parts stand now: Guarded while all its parts stand ("all"), or
## while any does ("any"), lifted the moment that stops being true, so a part killed by one
## die opens the core to the next.
func _refresh_guards() -> void:
	for core in field_foes():
		if not core.alive() or not core.has_parts():
			continue
		_schedule_regrowth(core)
		if core.guard.is_empty():
			continue
		var standing := parts_of(core).size()
		var guarded := standing > 0 and (core.guard == "any" or standing >= core.part_ids.size())
		if guarded and not Effects.has(core, "guarded"):
			Effects.stack(core, Effects.STATUS["guarded"], Effects.SKIRMISH, "parts", 1, Effects.DECAY_NONE)
		elif not guarded and Effects.has(core, "guarded"):
			Effects.remove(core, "guarded")
			log.append("%s is open: its guard has fallen" % core.display_name)


## A part down, while the core stands, is on its way back when the core regrows its parts.
func _schedule_regrowth(core: Foe) -> void:
	if core.regrow_parts <= 0:
		return
	var present: Dictionary = {}
	for f in parts_of(core):
		present[f.content_id] = int(present.get(f.content_id, 0)) + 1
	for f in reinforcements:
		if f.pack_id == core.pack_id and core.part_ids.has(f.content_id):
			present[f.content_id] = int(present.get(f.content_id, 0)) + 1
	for d in core.regrow_due:
		present[str(d[0])] = int(present.get(str(d[0]), 0)) + 1
	for pid in core.part_ids:
		if int(present.get(pid, 0)) > 0:
			present[pid] = int(present[pid]) - 1
		else:
			core.regrow_due.append([pid, round + core.regrow_parts])


## At the round's end, the parts due back step into the pool, to fill a slot as any waiting
## foe does.
func _regrow_parts() -> void:
	if not foe_factory.is_valid():
		return
	for core in field_foes():
		if not core.alive() or core.regrow_due.is_empty():
			continue
		var keep: Array = []
		for d in core.regrow_due:
			if int(d[1]) > round:
				keep.append(d)
				continue
			var n = foe_factory.call(str(d[0]))
			if n is Foe:
				n.pack_id = core.pack_id
				reinforcements.append(n)
				log.append("%s grows back its %s" % [core.display_name, n.display_name])
		core.regrow_due = keep


## A foe's last act (15 October, the Behemoth's Meteor): its death blow lands the moment it
## falls, before anything else, so the player shields first and kills after, and even the last
## foe's lands, since damage sticks for the battle.
func _last_act(f: Foe) -> void:
	var blow := f.last_act()
	if blow.is_empty():
		return
	f.action = blow
	f.pending = {}
	f.charge = 0
	log.append("%s falls, and its last act lands: %s" % [f.display_name, str(blow.get("name", ""))])
	var struck: Array[int] = []
	if f.hits_all():
		for m in live_mechs():
			struck.append(mechs.find(m))
			_strike(f, m)
	else:
		var t := f.target as MechState
		if t == null or not t.alive():
			t = _pick_mech_target(f)
		if t != null:
			struck.append(mechs.find(t))
			_strike(f, t)
	last_acts.append({"foe": f, "name": str(blow.get("name", "")), "mechs": struck})


## A core that falls for good takes its parts with it, on the field and waiting alike.
func _fall_with_cores() -> void:
	for core in field_foes():
		if core.alive() or not core.has_parts() or (Effects.has(core, "risen") and not core.stays_down):
			continue
		var parts := parts_of(core)
		for f in parts:
			f.hp = 0
			f.stays_down = true
		var waiting: Array[Foe] = []
		for f in reinforcements:
			if f.pack_id == core.pack_id and core.part_ids.has(f.content_id):
				waiting.append(f)
		for f in waiting:
			reinforcements.erase(f)
		core.regrow_due = []
		if not parts.is_empty() or not waiting.is_empty():
			log.append("%s falls, and its parts with it" % core.display_name)


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
						_last_act(f)
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

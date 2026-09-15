class_name Skirmish
extends RefCounted

## The dice skirmish. Mechs have no positions. Enemies stand in a two-rank, three-column
## formation fed from a pool, so a horde keeps coming.
##
## Round loop:
##   start_round()       roll every live mech's die (unless locked), telegraph foe intents
##   reroll([...])       up to REROLLS_PER_ROUND times, any subset of unspent mech dice,
##                       before or after spending others: a low damage roll is information;
##                       a reroll always lands on a different face (see Die.reroll)
##   assign(i, target)   spend a mech's face on a foe (attacks) or a mech (shield, vent);
##                       kinetic faces roll their damage here, immediately and visibly
##   end_round()         burn ticks, foes act, the dead are cleared, the pool refills,
##                       outcome is checked
##   can_withdraw()      at the start of any round, before any face is spent
##
## Numbers are in tens. Enemy damage is static; only the player's kinetic faces roll.

enum State { SETUP, ROUND_START, ASSIGN, DONE }
enum Outcome { NONE, VICTORY, DEFEAT, WITHDRAWN }

const COLUMNS := 3
const REROLLS_PER_ROUND := 3
const DANGER_CLOSE_DIVISOR := 2
const BURN_PER_STACK := 10          # damage each stack deals per round
const BURN_DAMAGE_PER_STACK := 20   # damage dealt per stack applied
const CRACK_MIN_HULL_PCT := 25      # a single hull hit this big (percent of max) may injure a face
const CRACK_CHANCE_PCT := 50


class MechState:
	var unit: Unit
	var die: Die
	var heat: int = 0
	var heat_max: int = 60
	var face_index: int = -1
	var locked: bool = false
	var assigned: bool = false

	func face() -> Face:
		if face_index < 0 or face_index >= die.faces.size():
			return null
		return die.faces[face_index]

	func alive() -> bool:
		return unit.hull > 0


var rng := RandomNumberGenerator.new()
var mechs: Array[MechState] = []
var squads: Array[Unit] = []
var front: Array = [null, null, null]
var back: Array = [null, null, null]
var pool: Array[Foe] = []
var round: int = 0
var rerolls_left: int = 0
var state: int = State.SETUP
var outcome: int = Outcome.NONE
var log: Array[String] = []

## The most recent attack, for the screen to show: {mech, target, rolled, final, crit, ranged}.
var last_roll: Dictionary = {}


func _init(seed_value: int = 0) -> void:
	rng.seed = seed_value


# ---------------------------------------------------------------- setup

func add_mech(u: Unit, d: Die = null) -> MechState:
	var ms := MechState.new()
	ms.unit = u
	ms.die = d if d != null else u.die
	ms.heat_max = u.heat_max
	mechs.append(ms)
	return ms


func add_foes(list: Array, from_squad: Unit = null) -> void:
	for f in list:
		if from_squad != null:
			f.squad_id = from_squad.id
		pool.append(f)
	if from_squad != null and not squads.has(from_squad):
		squads.append(from_squad)


func begin() -> void:
	_fill_from_pool()
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
		if f.squad_id == sq.id and f.alive():
			n += 1
	for f in pool:
		if f.squad_id == sq.id:
			n += 1
	return n


func any_assigned() -> bool:
	for m in mechs:
		if m.assigned:
			return true
	return false


## Withdraw is open at the start of any round, including the first, until a face is spent.
func can_withdraw() -> bool:
	if round == 0:
		return false
	if state == State.ROUND_START:
		return true
	return state == State.ASSIGN and not any_assigned()


## Heat the mech's current face will add if it is spent as an attack.
func pending_heat(ms: MechState) -> int:
	var f := ms.face()
	if f == null or ms.assigned or not f.is_attack():
		return 0
	var heat := f.heat
	if f.has(Face.Keyword.OVERCHARGE):
		heat *= 2
	return Passives.on_attack(ms.unit.passive, 0, heat)[1]


## The foes that will strike this mech when the round ends, in the order they act: alive,
## not suppressed, aimed at it, and not about to die to burn first.
func attackers_of(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	for f in field_foes():
		if not f.alive() or f.suppressed or f.target != ms:
			continue
		if f.burn > 0 and f.hp - f.burn * BURN_PER_STACK <= 0:
			continue
		out.append(f)
	return out


func incoming_for(ms: MechState) -> int:
	var total := 0
	for f in attackers_of(ms):
		total += f.attack
	return total


## What the end of the round does to this mech if nothing else changes: the screen's warning
## signs and bar overlays. Recomputed after every action, so shielding or killing an attacker
## moves the numbers at once.
func forecast(ms: MechState) -> Dictionary:
	var shield := ms.unit.shield
	var hull := ms.unit.hull
	var incoming := 0
	var component_risk := false
	for f in attackers_of(ms):
		incoming += f.attack
		var absorbed := mini(shield, f.attack)
		shield -= absorbed
		var through := f.attack - absorbed
		hull -= through
		if through > 0 and through * 100 >= ms.unit.hull_max * CRACK_MIN_HULL_PCT:
			component_risk = true
	var heat_after := ms.heat + pending_heat(ms)
	var over := maxi(0, heat_after - ms.heat_max)
	hull -= over
	return {
		"incoming": incoming,
		"shield_after": shield,
		"hull_after": hull,
		"heat_after": mini(heat_after, ms.heat_max),
		"overheat": over,
		"breaks_shield": ms.unit.shield > 0 and incoming >= ms.unit.shield,
		"component_risk": component_risk,
		"destroyed": hull <= 0 and ms.alive(),
	}


## Foes this mech's current face may be spent on.
func targets_for(mech_index: int) -> Array[Foe]:
	var out: Array[Foe] = []
	var ms := mechs[mech_index]
	var f := ms.face()
	if f == null or not f.is_attack():
		return out
	for col in range(COLUMNS):
		if front[col] != null and not out.has(front[col]):
			out.append(front[col])
		if back[col] != null and not out.has(back[col]) and (f.reach == Face.Reach.INDIRECT or is_exposed(col)):
			out.append(back[col])
	return out


# ---------------------------------------------------------------- round flow

func start_round() -> void:
	assert(state == State.ROUND_START, "start_round called out of order")
	round += 1
	rerolls_left = REROLLS_PER_ROUND
	last_roll.clear()
	for ms in mechs:
		ms.assigned = false
		if not ms.alive():
			continue
		if ms.locked:
			ms.locked = false
		else:
			ms.face_index = ms.die.roll(rng)
	for f in field_foes():
		f.target = _pick_mech_target()
	state = State.ASSIGN


func reroll(mech_indices: Array) -> bool:
	if state != State.ASSIGN or rerolls_left <= 0:
		return false
	for i in mech_indices:
		var ms := mechs[i]
		if ms.alive() and not ms.assigned:
			ms.face_index = ms.die.reroll(rng, ms.face_index)
	rerolls_left -= 1
	return true


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
	match f.kind:
		Face.Kind.BLANK:
			pass
		Face.Kind.SHIELD:
			var who: MechState = target if target is MechState else ms
			who.unit.shield = mini(who.unit.shield_max, who.unit.shield + f.power)
			log.append("%s shields %s for %d" % [ms.unit.display_name, who.unit.display_name, f.power])
		Face.Kind.VENT:
			var who: MechState = target if target is MechState else ms
			who.heat = maxi(0, who.heat - f.power)
			log.append("%s vents %s by %d" % [ms.unit.display_name, who.unit.display_name, f.power])
		Face.Kind.ATTACK:
			if not (target is Foe) or not targets_for(mech_index).has(target):
				return false
			_resolve_attack(mech_index, ms, f, target)
	if f.has(Face.Keyword.LOCK):
		ms.locked = true
	ms.assigned = true
	return true


func end_round() -> int:
	assert(state == State.ASSIGN, "end_round called out of order")
	# Burn ticks before the enemy acts, so a burning foe may die without striking.
	for f in field_foes():
		if f.burn > 0:
			f.hp -= f.burn * BURN_PER_STACK
			f.burn -= 1
	_clear_dead()
	for f in field_foes():
		if f.suppressed:
			f.suppressed = false
			continue
		var t := f.target as MechState
		if t == null or not t.alive():
			t = _pick_mech_target()
		if t == null:
			break
		_damage_mech(t, f.attack, f)
	_clear_dead()
	_advance()
	_fill_from_pool()
	_check_outcome()
	if outcome == Outcome.NONE:
		state = State.ROUND_START
	return outcome


func withdraw() -> bool:
	if not can_withdraw():
		return false
	outcome = Outcome.WITHDRAWN
	_finish()
	log.append("Withdrew at the start of round %d" % round)
	return true


# ---------------------------------------------------------------- resolution

## Roll the face, apply crit, keywords, and passives, then hit every foe the face reaches.
func _resolve_attack(mech_index: int, ms: MechState, f: Face, target: Foe) -> void:
	var rolled := f.power
	if f.is_ranged():
		rolled = f.average() if f.has(Face.Keyword.STEADY) else rng.randi_range(f.power, f.power_max)
	var dmg := rolled
	var heat := f.heat
	var crit := f.crit > 0 and rng.randi_range(1, 100) <= f.crit
	var extra_burn := 0
	var vent := 0
	if crit:
		dmg *= 2
		var c := Passives.on_crit(ms.unit.passive, dmg)
		dmg = c["damage"]
		extra_burn = c["burn"]
		vent = c["vent"]
	if f.has(Face.Keyword.OVERCHARGE):
		dmg *= 2
		heat *= 2
	if f.has(Face.Keyword.EXECUTE) and target.hp * 2 <= target.hp_max:
		dmg *= 2
	var modded := Passives.on_attack(ms.unit.passive, dmg, heat)
	dmg = modded[0]
	heat = modded[1]
	last_roll = {"mech": mech_index, "target": target, "rolled": rolled, "final": dmg, "crit": crit, "ranged": f.is_ranged()}
	# Keywords stack: a cleaving, piercing face hits the neighbours and the column.
	var hit: Array[Foe] = [target]
	if f.has(Face.Keyword.CLEAVE):
		for c in [target.column - 1, target.column + 1]:
			if c >= 0 and c < COLUMNS:
				var n := foe_at(target.rank, c)
				if n != null and not hit.has(n):
					hit.append(n)
	if f.has(Face.Keyword.PIERCE):
		var other := foe_at(1 - target.rank, target.column)
		if other != null and not hit.has(other):
			hit.append(other)
	if f.has(Face.Keyword.CHAIN):
		var best: Foe = null
		for cand in targets_for(mech_index):
			if not hit.has(cand) and (best == null or cand.hp < best.hp):
				best = cand
		if best != null:
			hit.append(best)
	for foe in hit:
		foe.hp -= dmg
		if f.has(Face.Keyword.BURN):
			foe.burn += ceili(float(dmg) / BURN_DAMAGE_PER_STACK)
		if f.has(Face.Keyword.SUPPRESS):
			foe.suppressed = true
	target.burn += extra_burn
	var how := f.describe()
	if crit:
		how = "CRIT " + how
	elif f.is_ranged():
		how = "rolled %d, " % rolled + how
	log.append("%s hits %s for %d (%s)" % [ms.unit.display_name, target.display_name, dmg, how])
	if f.reach == Face.Reach.INDIRECT and target.rank == 0:
		var splash := ceili(float(dmg) / DANGER_CLOSE_DIVISOR)
		ms.unit.shield = maxi(0, ms.unit.shield - splash)
		log.append("%s: danger close, shield -%d" % [ms.unit.display_name, splash])
	if vent > 0:
		ms.heat = maxi(0, ms.heat - vent)
	_add_heat(ms, heat)


func _add_heat(ms: MechState, amount: int) -> void:
	if amount <= 0:
		return
	ms.heat += amount
	if ms.heat > ms.heat_max:
		var over := ms.heat - ms.heat_max
		ms.unit.hull -= over
		ms.heat = ms.heat_max
		log.append("%s overheats: hull -%d" % [ms.unit.display_name, over])


func _damage_mech(ms: MechState, amount: int, source: Foe) -> void:
	var absorbed := mini(ms.unit.shield, amount)
	ms.unit.shield -= absorbed
	var through := amount - absorbed
	ms.unit.hull -= through
	log.append("%s hits %s: shield -%d, hull -%d" % [source.display_name, ms.unit.display_name, absorbed, through])
	# The global injury rule: a big hit that reaches the hull may damage a face. Shield before
	# a telegraphed blow is the counterplay.
	if through > 0 and through * 100 >= ms.unit.hull_max * CRACK_MIN_HULL_PCT:
		if rng.randi_range(1, 100) <= CRACK_CHANCE_PCT:
			apply_injury(ms)


## One random usable face takes damage. An intact face cracks: keywords, crit and unique
## effect are gone, the basic action stays. A cracked face is destroyed: blank. The damage is
## a damaged component: it lives on the unit and persists until repaired in the hangar.
func apply_injury(ms: MechState) -> void:
	var candidates: Array[int] = []
	for i in range(ms.die.faces.size()):
		if ms.die.faces[i].kind != Face.Kind.BLANK:
			candidates.append(i)
	if candidates.is_empty():
		return
	var idx: int = candidates[rng.randi_range(0, candidates.size() - 1)]
	var f := ms.die.faces[idx]
	var originals: Dictionary = ms.unit.damaged_faces
	if not originals.has(idx):
		originals[idx] = f.duplicate_face()
	if f.cracked:
		ms.die.faces[idx] = Face.blank()
		log.append("%s: a cracked component is destroyed (%s)" % [ms.unit.display_name, originals[idx].describe()])
	else:
		var c := f.duplicate_face()
		c.crack()
		ms.die.faces[idx] = c
		log.append("%s: a component cracks (%s)" % [ms.unit.display_name, originals[idx].describe()])


func _pick_mech_target() -> MechState:
	var best: MechState = null
	for ms in live_mechs():
		if best == null \
				or ms.unit.shield < best.unit.shield \
				or (ms.unit.shield == best.unit.shield and ms.unit.hull < best.unit.hull):
			best = ms
	return best


# ---------------------------------------------------------------- formation

func _clear_dead() -> void:
	for col in range(COLUMNS):
		for rank in [front, back]:
			var f: Foe = rank[col]
			if f != null and not f.alive():
				if f.rank >= 0:
					log.append("%s destroyed" % f.display_name)
				f.rank = -1
				rank[col] = null


## Back-rank foes that do not prefer the back step up into an empty front slot.
func _advance() -> void:
	for col in range(COLUMNS):
		if front[col] == null and back[col] != null and not back[col].prefers_back and not back[col].is_massive():
			var f: Foe = back[col]
			back[col] = null
			front[col] = f
			f.rank = 0


## Massive foes need a whole empty column and take both slots. Then front slots take
## front-preferrers only, and back slots take back-preferrers first, then anyone waiting
## to step up.
func _fill_from_pool() -> void:
	for col in range(COLUMNS):
		if front[col] == null and back[col] == null:
			var i := _pool_index_massive()
			if i >= 0:
				var f: Foe = pool.pop_at(i)
				_place(f, 0, col)
				back[col] = f
	for col in range(COLUMNS):
		if front[col] == null:
			var i := _pool_index(false, false)
			if i >= 0:
				_place(pool.pop_at(i), 0, col)
	for col in range(COLUMNS):
		if back[col] == null:
			var i := _pool_index(true, true)
			if i >= 0:
				_place(pool.pop_at(i), 1, col)


func _pool_index_massive() -> int:
	for i in range(pool.size()):
		if pool[i].is_massive():
			return i
	return -1


func _pool_index(want_back: bool, allow_any: bool) -> int:
	for i in range(pool.size()):
		if pool[i].is_massive():
			continue
		if pool[i].prefers_back == want_back:
			return i
	if allow_any:
		for i in range(pool.size()):
			if not pool[i].is_massive():
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
	elif field_foes().is_empty() and pool.is_empty():
		outcome = Outcome.VICTORY
		_finish()


## Damaged faces are NOT restored here: they are damaged components, repaired in the hangar.
func _finish() -> void:
	state = State.DONE
	for ms in mechs:
		ms.locked = false

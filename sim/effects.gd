class_name Effects
extends RefCounted

## The one pipeline for everything that changes a mech's numbers or a component's
## properties: the chassis passive, component passives, battle-long rewards, skirmish-long
## buffs and debuffs, and effects timed to a round. Decided with Ryan, 18 September.
##
## Nothing is ever written to a stat or a component. Every read asks this pipeline, so an
## effect that is gone (its scope ended, its round passed, it was suppressed, its component
## was destroyed) simply stops answering, and the answer always has a source.
##
## A Modifier is a passive (the content shape: id, name, description, effects) with a
## lifetime (scope) and a source. Scopes, shortest-lived first:
##   ROUNDS    gone after the end of `expires_round` (a debuff "until end of next round")
##   SKIRMISH  gone when the skirmish ends (a buff "for this fight")
##   BATTLE    gone when the battle ends (a skirmish reward)
##   LOADOUT   the chassis passive and every fitted component's passive; until refitted
##
## Order of operations, the same for every query:
##   0. suppression: shortest scope to longest, a live modifier's `suppress` effect turns off
##      every modifier whose id or tag it names; a suppressed modifier suppresses nothing
##   1. gate: a modifier takes part only if it is live, not suppressed, its trigger fires now
##      (static: always; on_attack: any attack; on_crit: only a crit; on_injury: an injury),
##      its `when` holds, and, for an ability, its component is not destroyed (a destroyed
##      component keeps its stat bonuses and loses its abilities)
##   2. adds, every source summed
##   3. multiplies, every source multiplied
##   4. floors and caps (min_damage; a stat never below zero)
##   5. overrides (set_reach): the shortest-lived source wins, then the latest granted
## In an attack, the crit multiplier and the fixed keyword rules (execute) are
## applied by the skirmish before step 2, so the pipeline's adds and multiplies come last.
##
## Stacking. A modifier has stacks (one by default). Granting the same id in the same scope
## again adds stacks instead of a second copy; an add is worth its value per stack, a
## multiply is applied once per stack. A status with tick decay ticks at its owner's turn:
## its tick effects apply per stack (tick_hp, tick_heat), then it loses one stack and is
## gone at zero. Burning on a foe and heat stacks on a mech are the same object.

const LOADOUT := 0
const BATTLE := 1
const SKIRMISH := 2
const ROUNDS := 3

## What the content may ask for, by trigger. The validator refuses anything else.
const SUPPORTED_EFFECTS := {
	"on_attack": ["multiply_damage", "add_damage", "min_damage", "multiply_heat", "add_heat", "add_burn", "roll_max"],
	"on_crit": ["multiply_damage", "add_damage", "add_burn", "vent_heat", "add_crit_damage"],
	"on_injury": ["no_destroy"],
	"static": ["set_reach", "add_stat", "multiply_stat", "add_damage_taken", "multiply_damage_taken", "suppress", "shock_on_hull_strike", "shock_on_block", "draw_rank", "grant_keyword", "free_reroll", "add_armour_vs_rank", "keep_status", "screen_withdraw"],
	"on_round_start": ["shield_per_heat", "add_shield", "vent_heat"],
	"on_hull_damage": ["stack_status"],
	"status": ["tick_hp", "tick_heat", "skip_action", "resist_suppress", "disable_entry", "corrupt_entry"],
	"on_foe_status": ["chance_suppress"],
}
const DECAY_NONE := 0    # lives until its scope ends
const DECAY_TICK := 1    # loses a stack each tick, gone at zero

## The tag a cleanse clears (decided 25 September): what a foe did to a machine, never what
## the machine did to itself (a rapid component's own switch-off keeps the turn finite).
const CLEANSABLE := "cleansable"

## The engine's own statuses, granted by keywords and foe attacks. Names are placeholders
## for Ryan's vocabulary; ids are what the engine keys on.
const STATUS := {
	"burning": {"id": "burning", "name": "Burning", "description": "Loses 5 HP per stack at the start of its action, then loses a stack.",
		"tags": ["dot"], "effects": [{"trigger": "status", "effect": "tick_hp", "value": 5}]},
	"overheating": {"id": "overheating", "name": "Overheating", "description": "Gains 5 heat per stack at the end of the round, then loses a stack.",
		"tags": ["dot", CLEANSABLE], "effects": [{"trigger": "status", "effect": "tick_heat", "value": 5}]},
	"suppressed": {"id": "suppressed", "name": "Suppressed", "description": "Skips its telegraphed action this round.",
		"effects": [{"trigger": "status", "effect": "skip_action", "value": 1}]},
	"numbed": {"id": "numbed", "name": "Numbed", "description": "Resists a suppress, 10% per stack, on top of its own resistance; loses a stack each turn.",
		"effects": [{"trigger": "status", "effect": "resist_suppress", "value": 10}]},
	# The machines' buffs (29 September): what buff equipment grants for a round or more.
	# Devour will stack Overcharged too, for the skirmish. Names are placeholders for Ryan.
	"overcharged": {"id": "overcharged", "name": "Overcharged", "description": "Attacks deal +10% damage per stack.",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "multiply_damage", "value": 1.1}]},
	"braced": {"id": "braced", "name": "Braced", "description": "Takes 15% less damage per stack.",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "multiply_damage_taken", "value": 0.85}]},
	"primed": {"id": "primed", "name": "Primed", "description": "Every blow it lands leaves a stack of Burning, per stack.",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_burn", "value": 1}]},
	# Retaliation as a debuff, not thorns (Ryan, 28 September): a foe that strikes this
	# machine's bare hull is Shocked, and the team's next blow on it lands double.
	"retaliate": {"id": "retaliate", "name": "Retaliate", "description": "A foe that strikes this machine's bare hull is Shocked.",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "shock_on_hull_strike", "value": 1}]},
	# Damage redirection, common not locked (Ryan, 28 September): a rank of foes turns on the
	# machine for the round. From a shield or vent keyword, or a buff. draw_rank 0 is the
	# front rank, 1 the back.
	"taunt": {"id": "taunt", "name": "Taunt", "description": "Every front-rank foe targets this machine.",
		"tags": ["buff", "draw"], "effects": [{"trigger": "static", "effect": "draw_rank", "value": 0}]},
	"beacon": {"id": "beacon", "name": "Beacon", "description": "Every back-rank foe targets this machine.",
		"tags": ["buff", "draw"], "effects": [{"trigger": "static", "effect": "draw_rank", "value": 1}]},
	# The foe's side of it: one status, never stacked, spent by the blow it doubles.
	"shocked": {"id": "shocked", "name": "Shocked", "description": "The next blow it takes deals double, then the shock is spent. Striking bare hull again costs it 10.",
		"tags": ["shock"], "effects": [{"trigger": "static", "effect": "multiply_damage_taken", "value": 2}]},
}
## The statuses a buff component may grant: the machines' own, never a foe's.
const MECH_STATUSES := ["overcharged", "braced", "primed", "retaliate", "taunt", "beacon"]
## target_status: the foe struck carries any live status (burning, suppressed, numbed...).
## ally_present: another live machine is in the fight (the unit's `allies`, kept by the skirmish).
const SUPPORTED_WHEN := ["component_cracked", "reach_melee", "reach_line", "reach_indirect", "target_status", "ally_present"]
## Stats a static effect may change: the mech's base numbers by these names.
const STATS := ["hull", "shield", "heat", "armour", "move", "recharge", "cooling"]
## Effects that are bonuses (a destroyed component keeps them) rather than abilities.
const BONUS_EFFECTS := ["add_stat", "multiply_stat"]

static var _seq := 0


class Modifier:
	extends RefCounted
	var id: String = ""
	var name: String = ""
	var description: String = ""
	var source: String = ""        # "chassis", a component id, "reward", "foe:<id>"...
	var component: String = ""     # the fitted component this came from, or ""
	var scope: int = LOADOUT
	var expires_round: int = -1    # ROUNDS only: gone after the end of this round
	var tags: Array[String] = []
	var effects: Array = []        # [{trigger, effect, value, (when), (stat)}]
	var seq: int = 0               # grant order, for override ties
	var stacks: int = 1
	var decay: int = DECAY_NONE

	func matches(key: String) -> bool:
		return id == key or tags.has(key)


## A modifier from a content passive. A draft ("status": "planned") or an empty passive
## grants nothing.
static func make(passive: Dictionary, scope: int, source: String, component: String = "") -> Modifier:
	if passive.is_empty() or str(passive.get("status", "implemented")) != "implemented":
		return null
	var m := Modifier.new()
	m.id = str(passive.get("id", source))
	m.name = str(passive.get("name", ""))
	m.description = str(passive.get("description", ""))
	m.source = source
	m.component = component
	m.scope = scope
	for t in passive.get("tags", []):
		m.tags.append(str(t))
	m.effects = passive.get("effects", [])
	return m


static func grant(u, m: Modifier) -> Modifier:
	if m == null:
		return null
	_seq += 1
	m.seq = _seq
	u.modifiers.append(m)
	return m


## A timed effect: gone after the end of `round`.
static func grant_for_rounds(u, passive: Dictionary, source: String, round: int) -> Modifier:
	var m := make(passive, ROUNDS, source)
	if m != null:
		m.expires_round = round
	return grant(u, m)


## Add stacks of a status. The same id in the same scope stacks up instead of doubling;
## a fresh one is granted with `n` stacks. Tick-decaying statuses lose a stack per tick.
static func stack(u, passive: Dictionary, scope: int, source: String, n: int = 1, decay: int = DECAY_TICK, expires_round: int = -1) -> Modifier:
	var id := str(passive.get("id", ""))
	for m in u.modifiers:
		if m.id == id and m.scope == scope:
			m.stacks += n
			if expires_round >= 0:
				m.expires_round = maxi(m.expires_round, expires_round)
			return m
	var m := make(passive, scope, source)
	if m == null:
		return null
	m.stacks = n
	m.decay = decay
	m.expires_round = expires_round
	return grant(u, m)


## Every live stack of a status, across scopes: a buff's Overcharged for the round and
## devour's for the skirmish are the same status to the machine.
static func stacks_of(u, id: String) -> int:
	var n := 0
	for m in live(u):
		if m.id == id:
			n += m.stacks
	return n


static func has(u, id: String) -> bool:
	return stacks_of(u, id) > 0


## Drop every copy of a status, whatever its scope: a spent one-shot (Shocked, once the blow
## it doubled has landed). Returns whether anything went.
static func remove(u, id: String) -> bool:
	var keep: Array = []
	var gone := false
	for m in u.modifiers:
		if m.id == id:
			gone = true
		else:
			keep.append(m)
	u.modifiers = keep
	return gone


## Does this machine draw the foes of `rank` (0 front, 1 back) onto itself right now?
static func draws_rank(u, rank: int) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "draw_rank" and int(pair[0].get("value", -1)) == rank:
			return true
	return false


## Does this machine shock a foe that strikes it? `blocked` asks about a blow its shield
## stopped whole (the Faraday Shutters' Live Shell); otherwise about one that reached hull
## (the Armadillo's Faraday Hull, the Retaliate status).
static func shocks_striker(u, blocked: bool) -> bool:
	var want := "shock_on_block" if blocked else "shock_on_hull_strike"
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == want:
			return true
	return false


## What a status effect amounts to right now across live statuses: {hp, heat, skip,
## resist}. hp and heat are per stack sums; skip is any skip_action; resist is percent.
static func tick_preview(u) -> Dictionary:
	var out := {"hp": 0, "heat": 0, "skip": false, "resist": 0}
	for pair in _taking_part(u, "status", null):
		var eff: Dictionary = pair[0]
		var m: Modifier = pair[1]
		var v := int(eff.get("value", 0)) * m.stacks
		match str(eff.get("effect", "")):
			"tick_hp":
				out["hp"] += v
			"tick_heat":
				out["heat"] += v
			"skip_action":
				out["skip"] = true
			"resist_suppress":
				out["resist"] += v
	return out


## The owner's turn comes: apply this tick (the caller subtracts hp and adds heat), then
## every tick-decaying status loses a stack and the empty ones go.
static func tick(u) -> Dictionary:
	var out := tick_preview(u)
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_TICK:
			m.stacks -= 1
			if m.stacks <= 0:
				continue
		keep.append(m)
	u.modifiers = keep
	return out


static func supports(trigger: String, effect: String) -> bool:
	return SUPPORTED_EFFECTS.has(trigger) and SUPPORTED_EFFECTS[trigger].has(effect)


static func supports_when(when: String) -> bool:
	return when.is_empty() or SUPPORTED_WHEN.has(when)


# ---------------------------------------------------------------- lifetimes

static func end_round(u, round: int) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if not (m.scope == ROUNDS and m.expires_round <= round):
			keep.append(m)
	u.modifiers = keep


static func end_skirmish(u) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if m.scope != ROUNDS and m.scope != SKIRMISH:
			keep.append(m)
	u.modifiers = keep


static func end_battle(u) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if m.scope == LOADOUT:
			keep.append(m)
	u.modifiers = keep


# ---------------------------------------------------------------- the gate

## Live modifiers after suppression, shortest scope first, latest granted first within a
## scope: the order overrides are resolved in.
static func live(u) -> Array:
	var all: Array = u.modifiers.duplicate()
	all.sort_custom(func(a, b) -> bool: return a.scope > b.scope or (a.scope == b.scope and a.seq > b.seq))
	var off := {}
	for m in all:
		if off.has(m):
			continue
		for eff in m.effects:
			if str(eff.get("trigger", "")) == "static" and str(eff.get("effect", "")) == "suppress":
				var key := str(eff.get("value", ""))
				for other in all:
					if other != m and other.matches(key):
						off[other] = true
	var out: Array = []
	for m in all:
		if not off.has(m):
			out.append(m)
	return out


## A component-sourced ability is off while its component is destroyed; its bonuses stay.
static func _usable(u, m: Modifier, effect: String) -> bool:
	if m.component.is_empty() or BONUS_EFFECTS.has(effect) or u.get("die") == null:
		return true
	var seen := false
	for f in u.die.faces:
		if f.component == m.component:
			seen = true
			if f.kind != Face.Kind.BLANK:
				return true
	return not seen


## Whether a trigger fires in the query asking: the caller asks on_injury only on an injury
## and on_attack only on an attack, so those always fire here; on_crit needs the crit.
static func _fires(trigger: String, crit: bool) -> bool:
	if trigger == "on_crit":
		return crit
	return SUPPORTED_EFFECTS.has(trigger)


## Does an effect's `when` hold for the component in hand? Reach conditions read the
## effective reach, so "+10% melee" follows a component the same passive sent to melee.
## `target` is the foe an attack is aimed at, for conditions on it; null outside an attack.
static func _holds(u, eff: Dictionary, face: Face, target = null) -> bool:
	match str(eff.get("when", "")):
		"":
			return true
		"component_cracked":
			return face != null and face.cracked
		"reach_melee":
			return face != null and effective_reach(u, face) == Face.Reach.MELEE
		"reach_line":
			return face != null and effective_reach(u, face) == Face.Reach.LINE
		"reach_indirect":
			return face != null and effective_reach(u, face) == Face.Reach.INDIRECT
		"target_status":
			return target != null and target.get("modifiers") != null and not live(target).is_empty()
		"ally_present":
			return u.get("allies") != null and int(u.allies) > 0
	return false


## Every effect taking part in a query: [effect dictionary, modifier], gated as above.
static func _taking_part(u, trigger: String, face: Face, crit: bool = false, target = null) -> Array:
	var out: Array = []
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != trigger or not _fires(trigger, crit):
				continue
			var name := str(eff.get("effect", ""))
			if not _usable(u, m, name) or not _holds(u, eff, face, target):
				continue
			out.append([eff, m])
	return out


# ---------------------------------------------------------------- queries

## A mech stat: its base, plus every add, times every multiplier, never below zero. `upto`
## is the longest-lived scope that takes part, ROUNDS by default (everything live); the
## codex asks with BATTLE (Ryan, 26 September: the codex is the machine's base state with
## its battle rewards, never its combat effects).
static func stat(u, name: String, upto: int = ROUNDS) -> int:
	var base: float = float(u.base.get(name, 0))
	var add := 0.0
	var mult := 1.0
	for pair in _taking_part(u, "static", null):
		var eff: Dictionary = pair[0]
		var n: int = pair[1].stacks
		if str(eff.get("stat", "")) != name or pair[1].scope > upto:
			continue
		match str(eff.get("effect", "")):
			"add_stat":
				add += float(eff.get("value", 0)) * n
			"multiply_stat":
				mult *= pow(float(eff.get("value", 1)), n)
	return maxi(0, int(roundf((base + add) * mult)))


## What the pipeline adds to the crit multiplier (add_crit_damage, on a crit), summed.
static func crit_bonus(u, face: Face, target = null) -> float:
	var total := 0.0
	for pair in _taking_part(u, "on_crit", face, true, target):
		if str(pair[0].get("effect", "")) == "add_crit_damage":
			total += float(pair[0].get("value", 0)) * pair[1].stacks
	return total


## An attack after the crit multiplier and the keyword rules: adds, then multiplies, then
## floors, on damage and on heat; burn and vent from crit effects. `target` is the foe the
## blow is aimed at, for conditions on it (null when only the heat is asked). Returns
## {damage, heat, burn, vent}.
static func attack(u, face: Face, dmg: int, heat: int, crit: bool, target = null) -> Dictionary:
	var d_add := 0.0
	var d_mult := 1.0
	var d_floor := 0
	var h_add := 0.0
	var h_mult := 1.0
	var burn := 0
	var vent := 0
	var parts: Array = _taking_part(u, "on_attack", face, crit, target)
	parts.append_array(_taking_part(u, "on_crit", face, crit, target))
	for pair in parts:
		var eff: Dictionary = pair[0]
		var v: float = float(eff.get("value", 0))
		var n: int = pair[1].stacks
		# `per_stack` scales an effect by the machine's stacks of a status (the Nemesis's
		# Crucible: melee damage per Overheating stack); none of the status, no effect.
		if eff.has("per_stack"):
			n *= stacks_of(u, str(eff["per_stack"]))
		match str(eff.get("effect", "")):
			"add_damage":
				d_add += v * n
			"multiply_damage":
				d_mult *= pow(v, n)
			"min_damage":
				d_floor = maxi(d_floor, int(v))
			"add_heat":
				h_add += v * n
			"multiply_heat":
				h_mult *= pow(v, n)
			"add_burn":
				burn += int(v) * n
			"vent_heat":
				vent += int(v) * n
	var out_dmg := maxi(d_floor, int(roundf((dmg + d_add) * d_mult)))
	var out_heat := maxi(0, int(roundf((heat + h_add) * h_mult)))
	return {"damage": out_dmg, "heat": out_heat, "burn": burn, "vent": vent}


## An incoming blow before shield and armour see it: adds, then multiplies, never below zero.
static func damage_taken(u, amount: int) -> int:
	var add := 0.0
	var mult := 1.0
	for pair in _taking_part(u, "static", null):
		var eff: Dictionary = pair[0]
		var n: int = pair[1].stacks
		match str(eff.get("effect", "")):
			"add_damage_taken":
				add += float(eff.get("value", 0)) * n
			"multiply_damage_taken":
				mult *= pow(float(eff.get("value", 1)), n)
	return maxi(0, int(roundf((amount + add) * mult)))


## A component's reach as it is right now: its own, unless a live set_reach holds. Static
## reach rules are read against the component itself (never against effective reach, which
## would loop), so they may key on cracked but not on reach. The first live modifier in
## override order (shortest scope, latest granted) wins.
static func effective_reach(u, face: Face) -> int:
	if face == null:
		return Face.Reach.NONE
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != "static" or str(eff.get("effect", "")) != "set_reach":
				continue
			if str(eff.get("when", "")).begins_with("reach_") or not _usable(u, m, "set_reach"):
				continue
			if _holds(u, eff, face):
				var r := Face.reach_from_name(str(eff.get("value", "")))
				if r >= 0:
					return r
	return face.reach


## Keywords a live passive grants this component beyond its own (grant_keyword, static, its
## `when` honoured; the Wild Boar's Juggernaut Drive puts overwhelm on every attack). An
## attack keyword lands on attacks only, a support keyword on equipment only, a spend
## keyword on anything; a keyword the component already carries is not granted twice.
static func granted_keywords(u, face: Face) -> Array[int]:
	var out: Array[int] = []
	if face == null or face.kind == Face.Kind.BLANK:
		return out
	for pair in _taking_part(u, "static", face):
		if str(pair[0].get("effect", "")) != "grant_keyword":
			continue
		var kw := Face.keyword_from_name(str(pair[0].get("value", "")))
		if kw <= 0 or face.has(kw) or out.has(kw):
			continue
		var fits := Face.ANY_KEYWORDS.has(kw) or (face.is_attack() != Face.SUPPORT_KEYWORDS.has(kw))
		if fits:
			out.append(kw)
	return out


## The component as it is right now for this machine: its own entry, unless a live passive
## changes its reach or grants it a keyword, in which case a copy carrying both. What the
## resolver spends, the bot weighs and the screen draws; the die keeps the real one.
static func effective_face(u, face: Face) -> Face:
	if face == null:
		return null
	var r := effective_reach(u, face)
	var granted := granted_keywords(u, face)
	if r == face.reach and granted.is_empty():
		return face
	var c := face.duplicate_face()
	c.reach = r
	for kw in granted:
		c.add_keyword(kw)
	return c


## The chance, percent, that a foe gaining a status is also suppressed by this machine's
## passives (the Baboon's Pocket Paradox, 28 September): each effect's base plus its
## `per_missing_shield` for every point of shield the machine is missing, summed, capped.
static func foe_status_suppress_chance(u) -> int:
	var total := 0.0
	var missing: int = maxi(0, int(u.shield_max) - int(u.shield))
	for pair in _taking_part(u, "on_foe_status", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "chance_suppress":
			continue
		var n: int = pair[1].stacks
		total += (float(eff.get("value", 0)) + float(eff.get("per_missing_shield", 0)) * missing) * n
	return clampi(int(roundf(total)), 0, 100)


## Armour this machine has against blows from a rank (0 front, 1 back) on top of its stat
## (add_armour_vs_rank, static; the Breaching Plow's Glacis against the front).
static func armour_against(u, rank: int) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "add_armour_vs_rank":
			continue
		var want := 0 if str(eff.get("rank", "front")) == "front" else 1
		if want == rank:
			n += int(eff.get("value", 0)) * int(pair[1].stacks)
	return maxi(0, n)


## Does a passive keep a status from fading on this machine and carry it through the battle
## (keep_status, static; the Ammit's Quintessence Tap on Overcharged)?
static func keeps(u, status_id: String) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "keep_status" and str(pair[0].get("value", "")) == status_id:
			return true
	return false


## The chance, percent, that an ally slips out under this machine's screen when the team
## withdraws (screen_withdraw, static; the Prairie Dog): zero when it has none.
static func screen_chance(u) -> int:
	var best := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "screen_withdraw":
			best = maxi(best, int(pair[0].get("value", 0)))
	return clampi(best, 0, 100)


## The machine has just lost hull to a blow or a bite (never to its own overheat): every
## on_hull_damage passive fires. stack_status adds a stack of a status for the skirmish,
## fading a stack a turn (the Crucible's Overheating). Returns the names granted, for the log.
static func hull_damaged(u) -> Array[String]:
	var out: Array[String] = []
	for pair in _taking_part(u, "on_hull_damage", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "stack_status":
			continue
		var id := str(eff.get("value", ""))
		if not STATUS.has(id):
			continue
		var m := stack(u, STATUS[id], SKIRMISH, "passive:" + str(pair[1].id), int(pair[1].stacks), DECAY_TICK)
		if m != null and not out.has(m.name):
			out.append(m.name)
	return out


## Does a kinetic attack roll its maximum (roll_max on_attack; the Dingo's Tactical Databank
## with an ally in the fight)?
static func rolls_max(u, face: Face, target = null) -> bool:
	for pair in _taking_part(u, "on_attack", face, false, target):
		if str(pair[0].get("effect", "")) == "roll_max":
			return true
	return false


## Free rerolls of this machine's own die each round, on top of the team's (free_reroll,
## static; the Clydesdale's Battery Director).
static func free_rerolls(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "free_reroll":
			n += int(pair[0].get("value", 0)) * pair[1].stacks
	return maxi(0, n)


## What the start of a round does for this machine (on_round_start, after the roll):
## {shield, vent}. shield_per_heat pays its value for every 10 heat the machine carries
## (the Goshawk's Thermal Recoupler); add_shield and vent_heat are flat.
static func round_start(u, heat: int) -> Dictionary:
	var out := {"shield": 0, "vent": 0}
	for pair in _taking_part(u, "on_round_start", null):
		var eff: Dictionary = pair[0]
		var v: int = int(eff.get("value", 0)) * int(pair[1].stacks)
		match str(eff.get("effect", "")):
			"shield_per_heat":
				out["shield"] += v * int(heat / 10)
			"add_shield":
				out["shield"] += v
			"vent_heat":
				out["vent"] += v
	return out


## Does the pipeline hold a cracked component short of destruction?
static func no_destroy(u, face: Face) -> bool:
	for pair in _taking_part(u, "on_injury", face):
		if str(pair[0].get("effect", "")) == "no_destroy":
			return true
	return false


## Switch one die entry off until the end of `until_round`: the entry shows blank, the
## component itself is untouched. Applied to the target's showing entry by a foe's disable
## (through the mech's next turn) and by a mech's own rapid component (this round only).
## A foe's disable can be cleansed; the rapid switch-off cannot (it only stops an infinite
## turn, and a cleanse that lifted it would start one).
static func disable_entry(u, index: int, source: String, until_round: int) -> Modifier:
	var status := {"id": "disabled_%d" % index, "name": "Disabled", "description": "This component is switched off.",
		"tags": [] if source == "rapid" else [CLEANSABLE],
		"effects": [{"trigger": "status", "effect": "disable_entry", "value": index}]}
	return grant_for_rounds(u, status, source, until_round)


static func is_entry_disabled(u, index: int) -> bool:
	for pair in _taking_part(u, "status", null):
		if str(pair[0].get("effect", "")) == "disable_entry" and int(pair[0].get("value", -1)) == index:
			return true
	return false


## A buff component's grant (29 September): `stacks` of a machine status through the end of
## `until_round`. The same status from the same scope stacks up and keeps the later expiry.
static func grant_buff(u, status_id: String, stacks: int, source: String, until_round: int) -> Modifier:
	if not STATUS.has(status_id):
		return null
	return stack(u, STATUS[status_id], ROUNDS, source, stacks, DECAY_NONE, until_round)


## Corrupt one die entry for the skirmish (the corrupt foe keyword, 25 September): every
## time the entry is spent it bites its owner, per stack. The component itself is untouched;
## the same entry corrupted again stacks up. Cleansable.
static func corrupt_entry(u, index: int, source: String, n: int = 1) -> Modifier:
	var status := {"id": "corrupted_%d" % index, "name": "Corrupted", "description": "This component bites its owner when spent.",
		"tags": [CLEANSABLE], "effects": [{"trigger": "status", "effect": "corrupt_entry", "value": index}]}
	return stack(u, status, SKIRMISH, source, n, DECAY_NONE)


static func corrupt_stacks(u, index: int) -> int:
	var n := 0
	for pair in _taking_part(u, "status", null):
		if str(pair[0].get("effect", "")) == "corrupt_entry" and int(pair[0].get("value", -1)) == index:
			n += pair[1].stacks
	return n


## Clear every cleansable status on a unit (the cleanse keyword, 25 September). Returns the
## names of what went, once each, for the log; empty when there was nothing to clear.
static func cleanse(u) -> Array[String]:
	var gone: Array[String] = []
	var keep: Array = []
	for m in u.modifiers:
		if m.tags.has(CLEANSABLE):
			if not gone.has(m.name):
				gone.append(m.name)
		else:
			keep.append(m)
	u.modifiers = keep
	return gone


## One effect in plain words, the way the die screen prints it: what it does, and when.
static func effect_text(eff: Dictionary) -> String:
	var v = eff.get("value", 0)
	var vs := str(v) if not (v is float) else (str(v) if v != floorf(v) else str(int(v)))
	var body := ""
	match str(eff.get("effect", "")):
		"multiply_damage": body = "damage ×%s" % vs
		"add_damage": body = "damage +%s" % vs
		"min_damage": body = "damage at least %s" % vs
		"multiply_heat": body = "heat ×%s" % vs
		"add_heat": body = "heat +%s" % vs
		"add_burn": body = "+%s burn" % vs
		"vent_heat": body = "vents %s heat" % vs
		"add_crit_damage": body = "crit multiplier +%s" % vs
		"no_destroy": body = "cracked components are never destroyed"
		"set_reach": body = "reach becomes %s" % vs
		"add_stat": body = "%s +%s" % [str(eff.get("stat", "")), vs]
		"multiply_stat": body = "%s ×%s" % [str(eff.get("stat", "")), vs]
		"add_damage_taken": body = "damage taken +%s" % vs
		"multiply_damage_taken": body = "damage taken ×%s" % vs
		"suppress": body = "turns off %s" % vs
		"shock_on_hull_strike": body = "a foe that strikes bare hull is Shocked"
		"shock_on_block": body = "a foe whose blow the shield blocks is Shocked"
		"draw_rank": body = "the %s rank targets this machine" % ("front" if int(v) == 0 else "back")
		"grant_keyword":
			var kw := Face.keyword_from_name(str(v))
			body = "gains %s" % (Face.keyword_label(kw) if kw > 0 else str(v))
		"roll_max": body = "kinetic weapons roll their maximum"
		"add_armour_vs_rank": body = "armour +%s against %s-rank blows" % [vs, str(eff.get("rank", "front"))]
		"keep_status": body = "%s never fades and lasts the battle" % str(STATUS.get(str(v), {}).get("name", str(v)))
		"screen_withdraw": body = "on a withdrawal this machine is out before the enemy strikes, and each ally has a %s%% chance to slip out with it; a blow at a covered machine is lost" % vs
		"stack_status": body = "gains a stack of %s" % str(STATUS.get(str(v), {}).get("name", str(v)))
		"free_reroll": body = "%s free reroll%s of this die a round" % [vs, "" if int(v) == 1 else "s"]
		"shield_per_heat": body = "+%s shield for every 10 heat carried" % vs
		"add_shield": body = "+%s shield" % vs
		"tick_hp": body = "%s damage per stack each turn" % vs
		"tick_heat": body = "%s heat per stack each turn" % vs
		"skip_action": body = "skips its action"
		"resist_suppress": body = "resists suppress %s%% per stack" % vs
		"disable_entry": body = "die entry %s switched off" % str(int(v) + 1)
		"corrupt_entry": body = "die entry %s bites its owner when spent" % str(int(v) + 1)
		"chance_suppress":
			body = "%s%% chance a foe gaining a status is also suppressed" % vs
			if float(eff.get("per_missing_shield", 0)) > 0.0:
				body += ", +%s%% per shield point missing" % _trim_num(float(eff.get("per_missing_shield", 0)))
		_: body = str(eff.get("effect", ""))
	if eff.has("per_stack"):
		body += " per stack of %s" % str(STATUS.get(str(eff["per_stack"]), {}).get("name", str(eff["per_stack"])))
	var lead := ""
	match str(eff.get("trigger", "")):
		"on_crit": lead = "on a crit: "
		"on_injury": lead = "on an injury: "
		"on_round_start": lead = "at the start of the round: "
		"on_hull_damage": lead = "on losing hull: "
	match str(eff.get("when", "")):
		"component_cracked": lead += "cracked components: "
		"reach_melee": lead += "melee attacks: "
		"reach_line": lead += "line-of-sight attacks: "
		"reach_indirect": lead += "indirect attacks: "
		"target_status": lead += "foes carrying a status: "
		"ally_present": lead += "with an ally in the fight: "
	return lead + body


static func _trim_num(x: float) -> String:
	return str(x) if x != floorf(x) else str(int(x))


## The effects that apply to this component right now, as short tags with their source:
## what the row on the die screen shows beside the component's name. A component's own
## passive is named first (the codex has its description), on any kind of entry.
static func explain(u, face: Face) -> Array[String]:
	var out: Array[String] = []
	if face == null:
		return out
	for m in live(u):
		if m.scope == LOADOUT and not m.component.is_empty() and m.component == face.component and not face.empty:
			out.append("passive: %s" % m.name)
	if not face.is_attack():
		return out
	for m in live(u):
		for eff in m.effects:
			var trig := str(eff.get("trigger", ""))
			var name := str(eff.get("effect", ""))
			if trig == "static" and name == "set_reach":
				if not str(eff.get("when", "")).begins_with("reach_") and _usable(u, m, name) and _holds(u, eff, face) and effective_reach(u, face) == Face.reach_from_name(str(eff.get("value", ""))) and effective_reach(u, face) != face.reach:
					out.append("%s (%s)" % [effect_text(eff), m.name])
			elif trig == "static" and name == "grant_keyword":
				var kw := Face.keyword_from_name(str(eff.get("value", "")))
				if kw > 0 and not face.has(kw) and granted_keywords(u, face).has(kw):
					out.append("%s (%s)" % [effect_text(eff), m.name])
			elif trig == "on_attack" or trig == "on_crit":
				# A condition on the target is shown as a rule (its lead says when), since
				# the row has no target in hand.
				if _usable(u, m, name) and (str(eff.get("when", "")) == "target_status" or _holds(u, eff, face)):
					out.append("%s (%s)" % [effect_text(eff), m.name])
	return out


## Every live modifier as [name, description, source, scope, stacks, id]: the codex lists
## the loadout and battle ones, the hold popup the skirmish and round ones.
static func describe(u) -> Array:
	var out: Array = []
	for m in live(u):
		out.append([m.name, m.description, m.source, m.scope, m.stacks, m.id])
	return out

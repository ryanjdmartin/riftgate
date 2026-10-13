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
##      (static: always; on_attack: any attack; on_injury: an injury),
##      its `when` holds, and, for an ability, its component is not destroyed (a destroyed
##      component keeps its stat bonuses and loses its abilities)
##   2. adds, every source summed
##   3. multiplies, every source multiplied
##   4. floors and caps (min_damage; a stat never below zero)
##   5. overrides (set_reach): the shortest-lived source wins, then the latest granted
## In an attack, the roll (or the flat number, with what heat fired or the target's missing
## hull adds) comes first, from the skirmish, so the pipeline's adds and multiplies come last. A raised
## ceiling or floor (add_ceiling, add_floor) is the one exception: it moves the range before
## the roll, so it lives on the effective face (effective_face) and the face shows it.
##
## Stacking. A modifier has stacks (one by default). Granting the same id in the same scope
## again adds stacks instead of a second copy; an add is worth its value per stack, a
## multiply is applied once per stack. A status with tick decay ticks at its owner's turn:
## its tick effects apply per stack (tick_hp, tick_heat), then it loses one stack and is
## gone at zero. A machine's Burning and Scorched tick at the end of its turn instead (turn
## decay, 13 October): Burning's heat lands before the overheat and a stack goes; Scorched
## goes whole.

const LOADOUT := 0
const BATTLE := 1
const SKIRMISH := 2
const ROUNDS := 3

## What the content may ask for, by trigger. The validator refuses anything else.
const SUPPORTED_EFFECTS := {
	"on_attack": ["multiply_damage", "add_damage", "min_damage", "multiply_heat", "add_heat", "add_burn", "add_ceiling", "add_floor"],
	"on_injury": ["no_destroy"],
	"static": ["set_reach", "add_stat", "multiply_stat", "add_damage_taken", "multiply_damage_taken", "suppress", "shock_on_hull_strike", "shock_on_block", "grant_keyword", "free_reroll", "add_armour_vs_rank", "keep_status", "screen_withdraw", "add_attack", "never_hunted", "extra_action", "spares_splash", "hull_per_spend"],
	"on_round_start": ["shield_per_heat", "add_shield", "vent_heat", "stack_status"],
	"on_hull_damage": ["stack_status", "add_shield", "vent_heat"],
	"on_skirmish_start": ["add_shield", "vent_heat", "stack_status"],
	"on_shield_gain": ["vent_heat", "stack_status"],
	"on_shield_granted": ["vent_heat", "stack_status"],
	"on_heat_gain": ["add_shield", "stack_status"],
	"out_of_combat": ["add_shield"],
	"status": ["tick_hp", "tick_heat", "skip_action", "resist_suppress", "disable_entry", "corrupt_entry", "scramble_reroll"],
	"on_foe_status": ["paradox"],
	"on_stack": ["add_stacks"],
}
const DECAY_NONE := 0    # lives until its scope ends
const DECAY_TICK := 1    # loses a stack each tick, gone at zero
const DECAY_ROUND := 2   # gone at its owner's next tick, every stack at once (Braced: one turn from any source, 12 October)
const DECAY_TURN := 3    # ticks at the end of its owner's turn and loses a stack there, not at the round's end (a machine's Burning, 13 October)
const DECAY_TURN_ALL := 4    # lasts until the end of its owner's turn, every stack going there at once (a machine's Scorched, 13 October: it never piles up)

## The tag a cleanse clears (decided 25 September): what a foe did to a machine, never what
## the machine did to itself (a rapid component's own switch-off keeps the turn finite).
const CLEANSABLE := "cleansable"

## The engine's own statuses, granted by keywords and foe attacks. Names are placeholders
## for Ryan's vocabulary; ids are what the engine keys on.
const STATUS := {
	"burning": {"id": "burning", "name": "Burning", "description": "Loses 5 HP per stack at the start of its action, then loses a stack.",
		"tags": ["dot"], "effects": [{"trigger": "status", "effect": "tick_hp", "value": 5}]},
	# The Nemesis's rage (Ryan, 12 October, in place of the Crucible): its passive banks a
	# stack for every hull hit, its own included, for the skirmish (`decay` none overrides a
	# passive's tick), and an entry that rolls again on it spends one to roll the die again.
	# A store like the hopper: it does nothing by itself.
	"rage": {"id": "rage", "name": "Rage", "description": "Banked for the skirmish; an entry that rolls again on rage spends one to roll the die again.", "decay": "none",
		"tags": ["store"], "effects": []},
	# A foe's fire on a machine (Ryan, 13 October: Burn and Scorch; direct heat retired). Burning
	# is the player's word on the other body: metal does not burn, it heats, so a stack adds its
	# heat at the end of the player's turn, before the overheat, where a vent made room for it
	# or a cleanse took it off, then loses a stack. Scorched is the softer: every weapon fired
	# runs hotter until the turn's end, when every stack goes, so it never piles up under several
	# scorchers, and spending equipment or a cool weapon plays round it.
	"burning_mech": {"id": "burning_mech", "name": "Burning", "description": "Gains 5 heat per stack at the end of the player's turn, before the overheat, then loses a stack.", "decay": "turn",
		"tags": ["dot", CLEANSABLE], "effects": [{"trigger": "status", "effect": "tick_heat", "value": 5}]},
	"scorched": {"id": "scorched", "name": "Scorched", "description": "Every weapon it fires runs 5 hotter per stack, until the end of the player's turn, when every stack goes.", "decay": "turn_all",
		"tags": [CLEANSABLE], "effects": [{"trigger": "on_attack", "effect": "add_heat", "value": 5}]},
	"suppressed": {"id": "suppressed", "name": "Suppressed", "description": "Skips its telegraphed action this round.",
		"effects": [{"trigger": "status", "effect": "skip_action", "value": 1}]},
	# Numbed is a resistance, not a status or a buff (Ryan, 10 October): it lives here as a
	# modifier for the pipeline's arithmetic, and nothing reads it but suppress (FOE_STATUSES).
	"numbed": {"id": "numbed", "name": "Numbed", "description": "Resists a suppress, 10% per stack, the only resistance a foe has; loses a stack each turn.",
		"effects": [{"trigger": "status", "effect": "resist_suppress", "value": 10}]},
	# The Baboon's Pocket Paradox as a meter (Ryan, 10 October): a status like any other, and
	# it never decays; at the machine's count the foe is Suppressed and the Paradox clears.
	"paradox": {"id": "paradox", "name": "Paradox", "description": "A paradox building: at the count it is Suppressed, and the Paradox clears.",
		"effects": []},
	# The machines' buffs (29 September): what buff equipment grants for a round or more.
	# Devour will stack Overcharged too, for the skirmish. Names are placeholders for Ryan.
	# Flat since 2 October (the damage scale: a tenth of a blow of 10 to 20 is nothing to read).
	"overcharged": {"id": "overcharged", "name": "Overcharged", "description": "Attacks deal +5 damage per stack.",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 5}]},
	# Brace is temporary armour (2 October): flat off every blow, the same word and icon as the
	# chassis stat, never a percentage.
	# Braced lasts one turn from any source (Ryan, 12 October: a defensive buff that lingered,
	# a stack fading a round, would stack into a wall; armour is the dearest stat there is).
	"braced": {"id": "braced", "name": "Braced", "description": "Armour +5 per stack, until the round's end.", "decay": "round",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 5}]},
	"primed": {"id": "primed", "name": "Primed", "description": "Every blow it lands leaves a stack of Burning, per stack.",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_burn", "value": 1}]},
	# Retaliation as a debuff, not thorns (Ryan, 28 September): a foe that strikes this
	# machine's bare hull is Shocked, and the team's next blow on it lands double.
	"retaliate": {"id": "retaliate", "name": "Retaliate", "description": "A foe that strikes this machine's bare hull is Shocked.",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "shock_on_hull_strike", "value": 1}]},
	# The foe's side of it: one status, never stacked, spent by the blow it doubles.
	"shocked": {"id": "shocked", "name": "Shocked", "description": "The next blow it takes deals double, then the shock is spent.",
		"tags": ["shock"], "effects": [{"trigger": "static", "effect": "multiply_damage_taken", "value": 2}]},
	# What a foe's defend, buff and debuff actions leave (30 September). Folded fades at the
	# foe's next action; Kindled lasts the next round; Risen is a charge spent by a death;
	# Scrambled sits on a machine until its next reroll, and a cleanse clears it.
	"folded": {"id": "folded", "name": "Folded", "description": "Armour +5 until its next action.",
		"tags": ["guard"], "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 5}]},
	# Kindled carries its rally's own value (13 October: the Wolf's Howl says 5, Stoke the
	# Forge 10; kindled() below) and goes live from the next round, when intents are drawn
	# with it, so no foe strikes above the intent it showed: the skirmish grants it once the
	# enemy's turn is over. The 10 here is only the default a bare grant would carry.
	"kindled": {"id": "kindled", "name": "Kindled", "description": "Hits 10 harder this round.",
		"tags": ["rally"], "effects": [{"trigger": "static", "effect": "add_attack", "value": 10}]},
	"risen": {"id": "risen", "name": "Getting Back Up", "description": "Returns from the pool once after dying.",
		"tags": ["revive"], "effects": []},
	# The Honey Badger's hopper (Ryan, 11 October): loads the Chainsaw Claw digs out of what it
	# hits, which the Bullion Fragmenter fires a few a shot. A store on the machine with no
	# effect of its own (the weapon that fires it reads it); it lasts the skirmish, never
	# decays, and nothing cleanses it.
	"hopper": {"id": "hopper", "name": "Hopper", "description": "Loads in the hopper, for a weapon that fires it.", "decay": "none",
		"tags": ["store"], "effects": []},
	"scrambled": {"id": "scrambled", "name": "Scrambled", "description": "This die's next reroll lands anywhere, the same entry included.",
		"tags": [CLEANSABLE], "effects": [{"trigger": "status", "effect": "scramble_reroll", "value": 1}]},
}
## The statuses a buff component may grant: the machines' own, never a foe's.
const MECH_STATUSES := ["overcharged", "braced", "primed", "retaliate"]


## Kindled at a rally's own value: the status above with the move's value in place of the
## default, so the Howl's 5 is 5 and the chip says so.
static func kindled(value: int) -> Dictionary:
	var d: Dictionary = STATUS["kindled"].duplicate(true)
	d["description"] = "Hits %d harder this round." % value
	d["effects"][0]["value"] = value
	return d
## What a foe carrying a status means (target_status, the Susceptibility Tensor; 10 October):
## what the team put on it. Never Numbed, a resistance and not a status, and never the foe's
## own buffs (Folded, Kindled, Getting Back Up).
const FOE_STATUSES := ["burning", "suppressed", "shocked", "paradox"]
## target_status: the foe struck carries any of FOE_STATUSES (Numbed and its own buffs never count).
## ally_present: another live machine is in the fight (the unit's `allies`, kept by the skirmish).
## A `tag_<tag>` condition reads the component's tags (10 October: a tag never carries a rule of
## its own; a passive may read one its machine's stock carries, the Badger's melee).
const SUPPORTED_WHEN := ["component_cracked", "rolled", "reach_direct", "reach_indirect", "target_status", "ally_present"]
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


## Spend up to `n` stacks of a status, shortest-lived scope first (the hopper's loads, fired a
## few a shot); a copy spent to nothing goes. Returns how many were spent.
static func spend_stacks(u, id: String, n: int) -> int:
	var spent := 0
	var order: Array = []
	for m in u.modifiers:
		if m.id == id:
			order.append(m)
	order.sort_custom(func(a, b) -> bool: return a.scope > b.scope)
	for m in order:
		if spent >= n:
			break
		var take := mini(m.stacks, n - spent)
		m.stacks -= take
		spent += take
	u.modifiers = u.modifiers.filter(func(m) -> bool: return m.id != id or m.stacks > 0)
	return spent


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
## `at_turn_end` asks the statuses that tick at the end of the owner's turn (turn decay, a
## machine's Burning and Scorched), and only those; otherwise every other.
static func tick_preview(u, at_turn_end: bool = false) -> Dictionary:
	var out := {"hp": 0, "heat": 0, "skip": false, "resist": 0}
	for pair in _taking_part(u, "status", null):
		var eff: Dictionary = pair[0]
		var m: Modifier = pair[1]
		if ends_with_turn(m) != at_turn_end:
			continue
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


## Does this modifier end with its owner's turn rather than the round (turn decay, either kind)?
static func ends_with_turn(m) -> bool:
	return m.decay == DECAY_TURN or m.decay == DECAY_TURN_ALL


## The decay a status names in its definition ("none", "round", "turn", "turn_all"), a
## stack a tick when it names none.
static func status_decay(def: Dictionary) -> int:
	return {"none": DECAY_NONE, "round": DECAY_ROUND, "turn": DECAY_TURN, "turn_all": DECAY_TURN_ALL}.get(str(def.get("decay", "")), DECAY_TICK)


## The end of a machine's turn (the player's, 13 October): its turn statuses tick, Burning's
## heat for the caller to add before the overheat, then Burning loses a stack, Scorched goes
## whole and the empty ones go. The round's tick leaves them alone.
static func turn_tick(u) -> Dictionary:
	var out := tick_preview(u, true)
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_TURN_ALL:
			continue
		if m.decay == DECAY_TURN:
			m.stacks -= 1
			if m.stacks <= 0:
				continue
		keep.append(m)
	u.modifiers = keep
	return out


## The owner's turn comes: apply this tick (the caller subtracts hp and adds heat), then
## every tick-decaying status loses a stack and the empty ones go.
static func tick(u) -> Dictionary:
	var out := tick_preview(u)
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_ROUND:
			continue
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
	return when.is_empty() or SUPPORTED_WHEN.has(when) or (when.begins_with("tag_") and when.length() > 4)


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
## and on_attack only on an attack, so a known trigger always fires here.
static func _fires(trigger: String) -> bool:
	return SUPPORTED_EFFECTS.has(trigger)


## Does an effect's `when` hold for the component in hand? Reach conditions read the
## effective reach, so a reach condition follows a component a passive's set_reach moved.
## `target` is the foe an attack is aimed at, for conditions on it; null outside an attack.
static func _holds(u, eff: Dictionary, face: Face, target = null) -> bool:
	match str(eff.get("when", "")):
		"":
			return true
		"component_cracked":
			return face != null and face.cracked
		"rolled":
			return face != null and face.is_ranged()
		"reach_direct":
			return face != null and effective_reach(u, face) == Face.Reach.DIRECT
		"reach_indirect":
			return face != null and effective_reach(u, face) == Face.Reach.INDIRECT
		"target_status":
			return target != null and target.get("modifiers") != null and carries_status(target)
		"ally_present":
			return u.get("allies") != null and int(u.allies) > 0
	var w := str(eff.get("when", ""))
	if w.begins_with("tag_"):
		return face != null and face.tags.has(w.substr(4))
	return false


## Every effect taking part in a query: [effect dictionary, modifier], gated as above.
static func _taking_part(u, trigger: String, face: Face, target = null) -> Array:
	var out: Array = []
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != trigger or not _fires(trigger):
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


## What a machine's live effects add to the top of its rolled weapons' ranges (add_ceiling,
## on_attack; the Muzzle Velocity Booster, 10 October), summed. A flat face has no range to
## widen, so it gets nothing.
static func ceiling_bonus(u, face: Face) -> int:
	return _range_bonus(u, face, "add_ceiling")


## What they add to the bottom (add_floor; the Tactical Databank, 10 October): the floor and
## the ceiling are the two ways to push a range. Never past the top, so a narrow range can
## end up flat.
static func floor_bonus(u, face: Face) -> int:
	return _range_bonus(u, face, "add_floor")


static func _range_bonus(u, face: Face, effect: String) -> int:
	if face == null or not face.is_attack() or not face.is_ranged():
		return 0
	var total := 0
	for pair in _taking_part(u, "on_attack", face):
		if str(pair[0].get("effect", "")) == effect:
			total += int(pair[0].get("value", 0)) * pair[1].stacks
	return maxi(0, total)


## An attack after the roll and the keyword rules: adds, then multiplies, then floors, on
## damage and on heat, with the burn and the vent the effects add. `target` is the foe the
## blow is aimed at, for conditions on it (null when only the heat is asked). Returns
## {damage, heat, burn, vent}.
static func attack(u, face: Face, dmg: int, heat: int, target = null) -> Dictionary:
	var d_add := 0.0
	var d_mult := 1.0
	var d_floor := 0
	var h_add := 0.0
	var h_mult := 1.0
	var burn := 0
	var vent := 0
	var parts: Array = _taking_part(u, "on_attack", face, target)
	for pair in parts:
		var eff: Dictionary = pair[0]
		var v: float = float(eff.get("value", 0))
		var n: int = pair[1].stacks
		# `per_stack` scales an effect by the machine's stacks of a status (no content uses it since
		# the Nemesis's Crucible became rage, 12 October); none of the status, no effect.
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
## `when` honoured; the Wild Boar's Juggernaut Drive puts spillover on every attack). An
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
## changes its reach, grants it a keyword or pushes its range (a raised ceiling or floor), in
## which case a copy carrying all of it. What the resolver spends, the bot weighs and the
## screen draws; the die keeps the real one.
static func effective_face(u, face: Face) -> Face:
	if face == null:
		return null
	var r := effective_reach(u, face)
	var granted := granted_keywords(u, face)
	var ceiling := ceiling_bonus(u, face)
	var floor_up := floor_bonus(u, face)
	if r == face.reach and granted.is_empty() and ceiling == 0 and floor_up == 0:
		return face
	var c := face.duplicate_face()
	c.reach = r
	for kw in granted:
		c.add_keyword(kw)
	c.power_max += ceiling
	c.power = mini(c.power + floor_up, c.power_max)
	return c


## Does a foe carry a status the team put on it (FOE_STATUSES)? Numbed and its own buffs
## never count.
static func carries_status(f) -> bool:
	for m in live(f):
		if FOE_STATUSES.has(m.id):
			return true
	return false


## The Paradox meter a machine runs (the Baboon's Pocket Paradox, a meter since 10 October,
## Ryan): [stacks of Paradox a foe gains each time it gains another status, the count that
## knocks it out], or [0, 0] for none. Several effects add their stacks; the lowest count trips.
static func paradox(u) -> Array[int]:
	var adds := 0
	var at := 0
	for pair in _taking_part(u, "on_foe_status", null):
		if str(pair[0].get("effect", "")) != "paradox":
			continue
		adds += int(pair[1].stacks)
		var t := int(pair[0].get("value", 0))
		if t > 0 and (at == 0 or t < at):
			at = t
	if at <= 0:
		return [0, 0] as Array[int]
	return [adds, at] as Array[int]


## Stacks a status this machine applies gains from its passives (add_stacks on on_stack;
## the Stingray's Exothermic Suite, 2 October): `value` per stack of the passive, times
## the machine's heat over `per_heat` when the effect carries one. It reads any stack the
## machine applies, on a foe, an ally or itself (a burn, a buff, a devour), never Numbed,
## which is exempt from every interaction but suppress and its own decay (Ryan, 2 October:
## a touchable stun resist is where other games' combat loops broke).
static func extra_stacks(u, status_id: String, heat: int) -> int:
	if status_id == "numbed":
		return 0
	var n := 0
	for pair in _taking_part(u, "on_stack", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "add_stacks":
			continue
		var v: int = int(eff.get("value", 0)) * int(pair[1].stacks)
		var per := int(eff.get("per_heat", 0))
		n += v * int(maxi(0, heat) / per) if per > 0 else v
	return maxi(0, n)


## What a foe's blows gain from its statuses (add_attack, static; a Kindled foe), per stack.
static func foe_attack_bonus(f) -> int:
	var n := 0
	for pair in _taking_part(f, "static", null):
		if str(pair[0].get("effect", "")) == "add_attack":
			n += int(pair[0].get("value", 0)) * int(pair[1].stacks)
	return n


## What a foe's armour gains from its statuses (add_stat armour, static; a hardened foe), per
## stack. A foe has no base dictionary, so this is its half of `stat`.
static func foe_armour_bonus(f) -> int:
	var n := 0
	for pair in _taking_part(f, "static", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) == "add_stat" and str(eff.get("stat", "")) == "armour":
			n += int(eff.get("value", 0)) * int(pair[1].stacks)
	return n


## Is this machine's next reroll scrambled (a foe's debuff)?
static func is_scrambled(u) -> bool:
	for pair in _taking_part(u, "status", null):
		if str(pair[0].get("effect", "")) == "scramble_reroll":
			return true
	return false


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


## Whether no hunter ever picks this machine as its prey (never_hunted, static; the Prairie
## Dog's, bible section 7, the cars).
static func never_hunted(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "never_hunted":
			return true
	return false


## Actions a turn this machine has past the one every machine has (extra_action, static; the
## Dingo's second, bible section 7, the cars).
static func extra_actions(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "extra_action":
			n += int(pair[0].get("value", 0)) * pair[1].stacks
	return maxi(0, n)


## The machine has just lost hull to a blow, a bite or its own overheat: every on_hull_damage
## passive fires (the Nemesis's Crucible). Returns the names of the
## statuses granted, for the log; shield and vent from it are the caller's to apply.
static func hull_damaged(u) -> Dictionary:
	return fire(u, "on_hull_damage")


## An event on a machine (on_skirmish_start as the fight begins, on_round_start after the
## roll, on_shield_gain and on_heat_gain as the gauges move, on_hull_damage on a hit,
## out_of_combat at the end of a phase spent out of a fight): every passive on that trigger
## fires. `amount` is what the event carried (the heat carried for shield_per_heat, the
## shield or heat gained). Returns {shield, vent, statuses}: shield to gain and heat to shed,
## for the caller to apply where the gauges live, and the names of the statuses granted
## (stack_status: a stack for the skirmish, fading a stack a turn), on `onto` when it is
## given (the ally an on_shield_granted passive shields) and on the machine itself otherwise.
## Nothing here can fire itself: a shield gained here grants no more shield, heat shed here
## grants no heat.
static func fire(u, trigger: String, amount: int = 0, onto = null) -> Dictionary:
	var out := {"shield": 0, "vent": 0, "statuses": [] as Array[String]}
	for pair in _taking_part(u, trigger, null):
		var eff: Dictionary = pair[0]
		var v: int = int(eff.get("value", 0)) * int(pair[1].stacks)
		match str(eff.get("effect", "")):
			"shield_per_heat":
				out["shield"] += v * int(amount / 10)
			"add_shield":
				out["shield"] += v
			"vent_heat":
				out["vent"] += v
			"stack_status":
				var id := str(eff.get("value", ""))
				if STATUS.has(id):
					var decay := status_decay(STATUS[id])
					var m := stack(u if onto == null else onto, STATUS[id], SKIRMISH, "passive:" + str(pair[1].id), int(pair[1].stacks), decay)
					if m != null and not (out["statuses"] as Array).has(m.name):
						(out["statuses"] as Array).append(m.name)
	return out


## Free rerolls of this machine's own die each round, on top of the team's (free_reroll,
## static; the Clydesdale's Battery Director).
static func free_rerolls(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "free_reroll":
			n += int(pair[0].get("value", 0)) * pair[1].stacks
	return maxi(0, n)


## What the start of a round does for this machine (on_round_start, after the roll), with
## the heat it carries: the Goshawk's Thermal Recoupler.
static func round_start(u, heat: int) -> Dictionary:
	return fire(u, "on_round_start", heat)


## What this machine's passives do to an ally it shields (on_shield_granted; the Puffin's
## escort passive, 5 October): heat the ally sheds and statuses it gains, for the caller to
## apply on the ally. Fires on the spend, whatever the shield gained, so a shield die on a
## topped-up ally still does its other work. Never on itself: the trigger is for allies.
static func shield_granted(u, ally, amount: int) -> Dictionary:
	return fire(u, "on_shield_granted", amount, ally)


## The heat an ally this machine shields would shed (on_shield_granted vent_heat), for the
## bot to weigh a shield spend on an ally by.
static func granted_vent(u) -> int:
	var n := 0
	for pair in _taking_part(u, "on_shield_granted", null):
		if str(pair[0].get("effect", "")) == "vent_heat":
			n += int(pair[0].get("value", 0)) * int(pair[1].stacks)
	return maxi(0, n)


## Is this machine spared danger close (spares_splash, static; the Artillery Rangefinder)?
static func spares_splash(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "spares_splash":
			return true
	return false


## Hull this machine pays for every component it spends (hull_per_spend, static; the
## Tithe Coupling), like a volatile bite: shield and armour never see it.
static func hull_per_spend(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "hull_per_spend":
			n += int(pair[0].get("value", 0)) * int(pair[1].stacks)
	return maxi(0, n)


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


## Is the entry switched off by something a cleanse clears (a foe's disable), rather than by a
## rapid component's own switch-off, which keeps the turn finite and no cleanse touches?
static func cleansable_disable(u, index: int) -> bool:
	for m in live(u):
		if not m.tags.has(CLEANSABLE):
			continue
		for eff in m.effects:
			if str(eff.get("effect", "")) == "disable_entry" and int(eff.get("value", -1)) == index:
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
		"vent_heat": body = "sheds %s heat" % vs
		"add_ceiling": body = "rolls reach %s higher" % vs
		"add_floor": body = "the lowest roll %s higher" % vs
		"no_destroy": body = "cracked components are never destroyed"
		"set_reach": body = "reach becomes %s" % vs
		"add_stat": body = "%s +%s" % [str(eff.get("stat", "")), vs]
		"multiply_stat": body = "%s ×%s" % [str(eff.get("stat", "")), vs]
		"add_damage_taken": body = "damage taken +%s" % vs
		"multiply_damage_taken": body = "damage taken ×%s" % vs
		"suppress": body = "turns off %s" % vs
		"shock_on_hull_strike": body = "a foe that strikes bare hull is Shocked"
		"shock_on_block": body = "a foe whose blow the shield blocks is Shocked"
		"grant_keyword":
			var kw := Face.keyword_from_name(str(v))
			body = "gains %s" % (Face.keyword_label(kw) if kw > 0 else str(v))
		"add_armour_vs_rank": body = "armour +%s against %s-rank blows" % [vs, str(eff.get("rank", "front"))]
		"keep_status": body = "%s never fades and lasts the battle" % str(STATUS.get(str(v), {}).get("name", str(v)))
		"screen_withdraw": body = "on a withdrawal this machine is out before the enemy strikes, and each ally has a %s%% chance to slip out with it; a blow at a covered machine is lost" % vs
		"stack_status": body = "gains a stack of %s" % str(STATUS.get(str(v), {}).get("name", str(v)))
		"add_attack": body = "attack +%s" % vs
		"never_hunted": body = "no hunter ever picks it as its prey"
		"extra_action": body = "%s more action%s a turn: move and fight again" % [vs, "" if int(v) == 1 else "s"]
		"spares_splash": body = "indirect fire on the front rank never splashes it"
		"hull_per_spend": body = "every component it spends costs %s hull" % vs
		"scramble_reroll": body = "the next reroll of this die lands anywhere"
		"free_reroll": body = "%s free reroll%s of this die a round" % [vs, "" if int(v) == 1 else "s"]
		"shield_per_heat": body = "+%s shield for every 10 heat carried" % vs
		"add_shield": body = "+%s shield" % vs
		"tick_hp": body = "%s damage per stack each turn" % vs
		"tick_heat": body = "%s heat per stack each turn" % vs
		"skip_action": body = "skips its action"
		"resist_suppress": body = "resists suppress %s%% per stack" % vs
		"disable_entry": body = "die entry %s switched off" % str(int(v) + 1)
		"corrupt_entry": body = "die entry %s bites its owner when spent" % str(int(v) + 1)
		"paradox":
			body = "a foe gaining any other status gains Paradox; at %s it is suppressed and the Paradox clears" % vs
		"add_stacks":
			body = "every stack this machine applies is %s deeper" % vs
			if int(eff.get("per_heat", 0)) > 0:
				body += " for every %s heat it carries" % str(int(eff["per_heat"]))
		_: body = str(eff.get("effect", ""))
	if eff.has("per_stack"):
		body += " per stack of %s" % str(STATUS.get(str(eff["per_stack"]), {}).get("name", str(eff["per_stack"])))
	var lead := ""
	match str(eff.get("trigger", "")):
		"on_injury": lead = "on an injury: "
		"on_round_start": lead = "at the start of the round: "
		"on_hull_damage": lead = "on losing hull: "
		"on_skirmish_start": lead = "as the fight begins: "
		"on_shield_gain": lead = "on gaining shield: "
		"on_shield_granted": lead = "an ally this machine shields: "
		"on_heat_gain": lead = "on gaining heat: "
		"out_of_combat": lead = "each phase out of combat: "
	match str(eff.get("when", "")):
		"component_cracked": lead += "cracked components: "
		"rolled": lead += "rolled weapons: "
		"reach_direct": lead += "direct attacks: "
		"reach_indirect": lead += "indirect attacks: "
		"target_status": lead += "foes carrying a status: "
		"ally_present": lead += "with an ally in the fight: "
	if str(eff.get("when", "")).begins_with("tag_"):
		lead += "%s weapons: " % str(eff["when"]).substr(4)
	return lead + body


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
			elif trig == "on_attack":
				# A condition on the target is shown as a rule (its lead says when), since
				# the row has no target in hand. A raised ceiling means nothing to a flat face.
				if (name == "add_ceiling" or name == "add_floor") and not face.is_ranged():
					continue
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

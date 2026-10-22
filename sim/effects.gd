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
## multiply is applied once per stack. A timed grant (ROUNDS) adds its stacks only to one
## that ends the same round, and is otherwise a modifier of its own, so each grant's stacks
## go when its own rounds run out (Ryan, 16 October: "Timed stacks should decay based on when
## they started. Not stack and refresh."); every reader sums a status across its modifiers.
## A status with tick decay ticks at its owner's turn:
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
	"on_attack": ["multiply_damage", "add_damage", "min_damage", "multiply_heat", "add_heat", "add_burn", "add_ceiling", "add_floor", "lay_status", "multiply_stacks", "multiply_printed"],
	"on_injury": ["no_destroy"],
	"static": ["set_reach", "add_stat", "multiply_stat", "add_damage_taken", "multiply_damage_taken", "suppress", "shock_on_hull_strike", "shock_on_block", "grant_keyword", "free_reroll", "add_armour_vs_rank", "keep_status", "screen_withdraw", "add_attack", "never_hunted", "extra_action", "hull_per_spend", "seal_form", "step_die", "rewrite_weapon", "vent_blast", "heat_per_blow", "mute_keywords", "weapon_cooldown", "lay_mines", "muster", "carry", "forge"],
	"on_round_start": ["shield_per_heat", "add_shield", "vent_heat", "stack_status"],
	"on_hull_damage": ["stack_status", "add_shield", "vent_heat"],
	"on_skirmish_start": ["add_shield", "vent_heat", "stack_status"],
	"on_shield_gain": ["vent_heat", "stack_status"],
	"on_shield_granted": ["vent_heat", "stack_status", "shield_per_ally_heat"],
	"on_heat_gain": ["add_shield", "stack_status"],
	"out_of_combat": ["add_shield"],
	"status": ["tick_hp", "tick_hp_share", "tick_heat", "skip_action", "resist_suppress", "disable_entry", "corrupt_entry", "scramble_reroll"],
	"on_foe_status": ["paradox"],
	"on_stack": ["add_stacks"],
	"on_kill": ["stack_status", "add_shield", "vent_heat"],
}
const DECAY_NONE := 0    # lives until its scope ends
const DECAY_TICK := 1    # loses a stack each tick, gone at zero
const DECAY_ROUND := 2   # gone at its owner's next tick, every stack at once (Braced: one turn from any source, 12 October)
const DECAY_TURN := 3    # ticks at the end of its owner's turn and loses a stack there, not at the round's end (a machine's Burning, 13 October)
const DECAY_TURN_ALL := 4    # lasts until the end of its owner's turn, every stack going there at once (a machine's Scorched, 13 October: it never piles up)
const DECAY_HALF := 5    # halves at its owner's tick, rounded down, gone at zero (Overcharged, 18 October: a halving rule has no duration)

## The tag a cleanse clears (decided 25 September): what a foe did to a machine, never what
## the machine did to itself (a rapid component's own switch-off keeps the turn finite).
const CLEANSABLE := "cleansable"

## The engine's own statuses, granted by keywords and foe attacks. Names are placeholders
## for Ryan's vocabulary; ids are what the engine keys on.
## A status may name how a second grant of it lands, "stacking" (Ryan, 17 October: renewal
## without stacking must be supported, "a pretty common thing for a powerful or non-number-
## related buff to do"): "add", the default, stacks it, a timed grant keeping its own end;
## "renew" keeps one grant, its end the later and its count the larger, so on an untimed
## one-stack status (Shocked, Guarded) a second grant changes nothing (Ryan, 17 October:
## never stacking and renewing are one state, parted only by a timer).
const STATUS := {
	# A damage point a stack since 18 October (Ryan, in the spirit of flattening the numbers;
	# 5 before), the stacks the Burn keyword's own number.
	"burning": {"id": "burning", "name": "Burning", "description": "Loses 1 HP per stack at the start of its action, then loses a stack.",
		"tags": ["dot"], "effects": [{"trigger": "status", "effect": "tick_hp", "value": 1}]},
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
	"suppressed": {"id": "suppressed", "name": "Suppressed", "description": "Skips its telegraphed action this round.", "stacking": "renew",
		"effects": [{"trigger": "status", "effect": "skip_action", "value": 1}]},
	# Numbed is a resistance, not a status or a buff (Ryan, 10 October): it lives here as a
	# modifier for the pipeline's arithmetic, and nothing reads it but suppress (FOE_STATUSES).
	"numbed": {"id": "numbed", "name": "Numbed", "description": "Resists a suppress, 10% per stack, the only resistance a foe has; loses a stack each turn.",
		"effects": [{"trigger": "status", "effect": "resist_suppress", "value": 10}]},
	# The Baboon's Pocket Paradox as a meter (Ryan, 10 October): a status like any other, and
	# it never decays; at the machine's count the foe is Suppressed and the Paradox clears.
	"paradox": {"id": "paradox", "name": "Paradox", "description": "A paradox building: at the count it is Suppressed, and the Paradox clears.",
		"effects": []},
	# The funnel-web's acid (Ryan's go, 18 October; Vitriol his word): a share of the foe's
	# current hull a stack at its action, past armour, after Burning's flat tick, rounded down
	# and never the last hit point, then a stack fades (Burning's shape, stacking add): it
	# opens on a boss, finishes no foe and so sets off no last act. Its passive lays it a stack
	# per hit on a foe showing no intent on it (lay_status on on_attack, when target_no_intent).
	"vitriol": {"id": "vitriol", "name": "Vitriol", "description": "Loses 5% of its current HP per stack at its action, past armour, after Burning, rounded down, then loses a stack. It never finishes a foe.",
		"tags": ["dot"], "effects": [{"trigger": "status", "effect": "tick_hp_share", "value": 5}]},
	# The funnel-web's web (18 October): the mark its Web Bomb leaves. The skirmish bursts it at
	# the end of the foe's action (Skirmish._web_burst): a Suppress on it and on the next foe
	# to act beside it, each for itself. One web on a foe, however often it is webbed.
	"webbed": {"id": "webbed", "name": "Webbed", "description": "At the end of its action the web bursts: it and the next foe to act beside it are Suppressed.", "stacking": "renew", "decay": "none",
		"tags": ["web"], "effects": []},
	# The machines' buffs (29 September): what buff equipment grants. Names are placeholders
	# for Ryan. Flat since 2 October (the damage scale: a tenth of a blow of 10 to 20 is nothing
	# to read). A damage point a stack since 18 October (Ryan: the count is the bonus, read at a
	# glance), and it halves at the end of each round, rounded down, whatever granted it: a
	# source feeding so many stacks a round settles near twice that, where a stack fading a
	# round climbed without limit ("stacking to the moon and fueling massive ramp strategies").
	# The Ammit's Quintessence Tap keeps every grant of it for the battle (stack()).
	"overcharged": {"id": "overcharged", "name": "Overcharged", "description": "Attacks deal +1 damage a stack. Halves at the end of each round, rounded down.", "decay": "half",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 1}]},
	# Armoured (Braced until 18 October; the engine id stays) is temporary armour (2 October):
	# flat off every blow, the same word and icon as the chassis stat, never a percentage, and
	# a point a stack since 18 October (Ryan: both sides say Armoured, and the count is the
	# armour). It lasts one turn from any source (Ryan, 12 October: a defensive buff that
	# lingered, a stack fading a round, would stack into a wall; armour is the dearest stat
	# there is), every stack going at once at its owner's turn: a machine's at the round's
	# end, a foe's at its next action. A foe's brace grants it too (Ryan, 16 October: a
	# keyword or an effect and the buff it creates share a name), its value its stacks.
	"braced": {"id": "braced", "name": "Armoured", "description": "Armour +1 a stack, every stack at once: on a machine until the round's end, on a foe until its next action.", "decay": "round",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 1}]},
	"primed": {"id": "primed", "name": "Primed", "description": "Every blow it lands leaves a stack of Burning, per stack.",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_burn", "value": 1}]},
	# Retaliation as a debuff, not thorns (Ryan, 28 September): a foe that strikes this
	# machine's bare hull is Shocked, and the team's next blow on it lands double.
	"retaliate": {"id": "retaliate", "name": "Retaliate", "description": "A foe that strikes this machine's bare hull is Shocked.", "stacking": "renew",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "shock_on_hull_strike", "value": 1}]},
	# The foe's side of it: one status, never stacked, spent by the blow it doubles.
	# A core whose parts stand takes nothing (the boss in parts, 15 October): the skirmish grants
	# and lifts it as its parts fall and grow back, so every number reads it, the die's too.
	"guarded": {"id": "guarded", "name": "Guarded", "description": "Takes no damage while its parts stand.", "stacking": "renew",
		"tags": ["guard"], "effects": [{"trigger": "static", "effect": "multiply_damage_taken", "value": 0}]},
	"shocked": {"id": "shocked", "name": "Shocked", "description": "The next blow it takes deals double, then the shock is spent.", "stacking": "renew",
		"tags": ["shock"], "effects": [{"trigger": "static", "effect": "multiply_damage_taken", "value": 2}]},
	# Exposed (the Kestrel session, 20 and 21 October; built 21 October), the debuff: the foe
	# stands in Direct reach of every machine as if its column's front were empty, and its
	# armour counts for nothing, its own and any Armoured (Foe.armour_total), through the next
	# round, refreshed and never added. The formation's exposed back rank is reach only, and the
	# id is "exposure" since "exposed" names that formation word and the foes' default aim.
	"exposure": {"id": "exposure", "name": "Exposed", "description": "In Direct reach of every machine, and its armour counts for nothing. Through the next round.", "stacking": "renew",
		"tags": ["expose"], "effects": []},
	# The Lammergeier's Syrinx Drone (Ryan's go, 21 October; built 21 October): the debuff the
	# piece leaves, its own name. The next weapon to kill the foe, any machine's, leaves its shot
	# in the slot the foe empties, a mine; one mine a drone; it lasts the fight, and a death by a
	# tick leaves nothing. A status the team put on the foe, so the Paradox counts it.
	"syrinx_drone": {"id": "syrinx_drone", "name": "Syrinx Drone", "description": "The next weapon to kill it leaves its shot in the slot it empties, a mine. Lasts the fight.", "stacking": "renew",
		"tags": ["drone"], "effects": []},
	# The Needletail's gate spent (the Quick-turn Avionics Relay, Ryan's go of 21 October; built
	# that day): its free setup this round is used. A marker, never a chip: the die shows the
	# gate open by the Rapid it grants a setup.
	"quick_turned": {"id": "quick_turned", "name": "Quick turn spent", "description": "Its free setup this round is spent.", "stacking": "renew",
		"tags": ["marker"], "effects": []},
	# The Swallowtail's (Ryan's go, 21 October; built that day). The Muster: a store of points,
	# every die's roll a point and a kill by its own guns more, a charge every so many (the
	# passive's muster rule), spent by its locked pieces' charged forms; never decays, and a
	# store is a resource, so no Silence or Purge touches it (Ryan, 21 October). Phased: cannot act, take damage or be
	# targeted until the round's end, granted only to a machine that has not acted. Rallied:
	# the team has one reroll more this round, given as it is granted.
	"muster": {"id": "muster", "name": "Muster", "description": "A charge its locked pieces spend for their charged forms. Every die that rolls fills it a sliver.", "decay": "none",
		"tags": ["store"], "effects": []},
	"phased": {"id": "phased", "name": "Phased", "description": "Cannot act, take damage or be targeted until the round's end.", "stacking": "renew",
		"tags": ["buff"], "effects": []},
	"rallied": {"id": "rallied", "name": "Rallied", "description": "The team has one reroll more this round.", "stacking": "renew",
		"tags": ["buff"], "effects": []},
	# What a foe's defend, buff and debuff actions leave (30 September), besides the Braced of
	# its brace (above): Kindled lasts the next round; Risen is a charge spent by a death;
	# Scrambled sits on a machine until its next reroll, and a cleanse clears it.
	# Kindled carries its rally's own value (13 October: the Dire Wolf's Howl says 5, Stoke the
	# Forge 10; kindled() below) and goes live from the next round, when intents are drawn
	# with it, so no foe strikes above the intent it showed: the skirmish grants it once the
	# enemy's turn is over. The 10 here is only the default a bare grant would carry.
	"kindled": {"id": "kindled", "name": "Kindled", "description": "Hits 10 harder this round.",
		"tags": ["rally"], "effects": [{"trigger": "static", "effect": "add_attack", "value": 10}]},
	"risen": {"id": "risen", "name": "Getting Back Up", "description": "Returns from the pool once after dying.", "stacking": "renew",
		"tags": ["revive"], "effects": []},
	# The Honey Badger's hopper (Ryan, 11 October): loads the Chainsaw Claw digs out of what it
	# hits, which the Bullion Fragmenter fires a few a shot. A store on the machine with no
	# effect of its own (the weapon that fires it reads it); it lasts the skirmish, never
	# decays, and nothing cleanses it.
	"hopper": {"id": "hopper", "name": "Hopper", "description": "Loads in the hopper, for a weapon that fires it.", "decay": "none",
		"tags": ["store"], "effects": []},
	# The Armadillo's seal (Ryan's go, 20 October; the form-changing tank of his 15 October
	# framework): a shield it spends on itself seals it, a vent or a damaging weapon opens it.
	# One chip while sealed, carrying the armour its Lockdown grants (sealed_status builds it
	# with the passive's numbers), renewing, never stacking (Ryan: the granted armour is tied
	# to the mode). Its own cooling stops and it runs hotter at the end of each turn
	# (Skirmish); an ally's vent still cools it (Ryan, 20 October: allowed).
	"sealed": {"id": "sealed", "name": "Sealed", "description": "Sealed: armour up, its own cooling stopped, hotter at the end of each turn. A vent or a damaging weapon opens it.", "decay": "none", "stacking": "renew",
		"tags": ["buff", "form"], "effects": []},
	# Cryo (Ryan, 20 October: the Armadillo's Cryo Flinger, the debuff called Cryo too, marked
	# for reuse as the healthier way to cool an ally): a foe mark that pays in cooling. Any
	# machine's damaging hit on it spends every stack and cools the hitter so much a stack,
	# the cool_hitter number here (Skirmish.cryo_cool; a field since the stock pass's engine, 22
	# October). It never fades on its own: the canister sticks.
	"cryoed": {"id": "cryoed", "name": "Cryo", "description": "A damaging hit on it spends every stack and cools the hitter 10 a stack.", "decay": "none",
		"tags": ["mark"], "effects": [{"trigger": "status", "effect": "cool_hitter", "value": 10}]},
	# Corrupted (the foes' Corrupt, 25 September): the definition each entry's own status is built
	# from (corrupt_entry, one an entry), and the bite a stack takes from its owner each time the
	# entry is spent, shield first (Skirmish.corrupt_bite; a field since the stock pass's engine,
	# 22 October). Cleansable.
	"corrupted": {"id": "corrupted", "name": "Corrupted", "description": "This component bites its owner 10 a stack when spent.",
		"tags": [CLEANSABLE], "effects": [{"trigger": "status", "effect": "corrupt_bite", "value": 10}]},
	# Flak (Ryan's go, 19 October; built 21 October): Wainwright & Sutler's on-hit, laid by the
	# Flak keyword's number. Every blow the foe takes deals a point more a stack, an add before
	# the multiplies (a Shocked foe takes blow plus Flak, doubled) and before its armour comes off,
	# and a blow of nothing stays nothing (damage_taken). The stacks halve at the end of each
	# round, rounded down (Overcharged's clock: Skirmish.end_round halves a foe's), so a sprayer
	# feeding three a round settles near six and a boss never ramps. Past armour or not is the
	# stock pass's call; through the plain pipeline, the armour comes off it, until then.
	"flakked": {"id": "flakked", "name": "Flak", "description": "Every blow it takes deals a point more a stack. At the end of each round the stacks halve, rounded down.", "decay": "half",
		"tags": ["flak"], "effects": [{"trigger": "static", "effect": "add_damage_taken", "value": 1}]},
	"scrambled": {"id": "scrambled", "name": "Scrambled", "description": "This die's next reroll lands anywhere, the same entry included.", "stacking": "renew",
		"tags": [CLEANSABLE], "effects": [{"trigger": "status", "effect": "scramble_reroll", "value": 1}]},
	# The Cassowary's Spun Up (Ryan's go, 19 October; built 21 October): the Spin-Up's buff, +5
	# a stack on the next weapon spend, stacking, carried between turns until a weapon spends
	# it, damage or none (`spent_by`: the skirmish lifts every stack after a weapon spend, and a
	# buff grants it with no rounds).
	"spun_up": {"id": "spun_up", "name": "Spun Up", "description": "Its next weapon spend deals 5 more a stack, then every stack is spent. Carried between turns until a weapon spends it.", "decay": "none", "spent_by": "weapon",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 5}]},
	# A count a rule reads (the Cassowary's sixth shot, 21 October): the machine's weapon
	# spends this fight, a stack each, kept only where a live effect counts them (nth_shot). A
	# store with no effect of its own; the screen draws it as pips under the heat bar.
	"shots": {"id": "shots", "name": "Shots", "description": "Weapon spends this fight, counted for a rule that lands on a number of them.", "decay": "none",
		"tags": ["store", "count"], "effects": []},
	# The Whip Scorpion's Siphon (Ryan's go, 20 October; built 21 October): spending it, every
	# blow a foe lands on the machine that round adds heat, next round's fuel for its vents; the
	# blows land in the enemy's turn, after the overheat, so it is never a same-turn burn. The
	# value is the entry's own (siphon_status builds it); 10 here is the default a bare grant
	# would carry. Renewing, the machine's own doing, so no cleanse lifts it.
	# The enemy's answer to a stacked machine (Ryan, 17 and 18 October; built 21 October): a
	# foe's silence leaves the machine Silenced through its next round, every buff it carries
	# counting for nothing (the pipeline's suppress turns them off) and its components' keywords
	# muted (Ryan, 21 October: "Silence mutes keywords, we'll dial it back in testing if
	# needed"); its stores fill and spend as ever (Ryan, 21 October: a store is a resource, and
	# a balance lever if silence does not hurt enough). It costs time, never ability.
	# Cleansable; a Ward turns it away.
	"silenced": {"id": "silenced", "name": "Silenced", "description": "Its buffs count for nothing and its components' keywords are muted through its next round.", "stacking": "renew",
		"tags": [CLEANSABLE, "silence"], "effects": [{"trigger": "static", "effect": "suppress", "value": "buff"},
		{"trigger": "static", "effect": "mute_keywords", "value": 1}]},
	"siphoning": {"id": "siphoning", "name": "Siphoning", "description": "Every blow a foe lands on it this round adds 10 heat.", "stacking": "renew",
		"tags": ["fuel"], "effects": [{"trigger": "static", "effect": "heat_per_blow", "value": 10}]},
	# The block as a buff (Ryan, 14 October, the honest shield's upside; built 21 October), one
	# machine at a time. A Barrier is Shocked's mirror on the machines' side: the next blow a
	# foe lands on it deals nothing, so it never injures, its riders landing, and a blow of
	# nothing leaves it standing (Skirmish._damage_mech spends it). A Ward turns away every rider
	# a foe's blows lay on it that round, a breach included, so its shield absorbs the needle; the
	# damage lands. Neither stacks, and both go at the round's end (a buff's grant).
	"barrier": {"id": "barrier", "name": "Barrier", "description": "The next blow a foe lands on it deals no damage, so it never injures; its riders land. Until the round's end.", "stacking": "renew",
		"tags": ["buff"], "effects": []},
	"ward": {"id": "ward", "name": "Ward", "description": "Every blow a foe lands on it this round leaves no rider (breach, burn, scorch, disable, corrupt); its damage lands. Until the round's end.", "stacking": "renew",
		"tags": ["buff"], "effects": []},
	# The Kite's heat tax (Ryan's direction of 19 October, his go of 21 October; a working name):
	# each attack that killed makes its shots 5 hotter for the fight, a stack a killing attack.
	# The passive's own price, so neither a buff nor a store (no silence or purge lifts it) and no
	# cleanse takes it; it lasts the fight.
	"hot_streak": {"id": "hot_streak", "name": "Hot Streak", "description": "Its shots run 5 hotter a stack this fight: a stack for each attack that killed.", "decay": "none",
		"tags": ["tax"], "effects": [{"trigger": "on_attack", "effect": "add_heat", "value": 5}]},
}
## The statuses a buff component may grant: the machines' own (Braced is a foe's too, from its
## brace), never one only a foe carries.
const MECH_STATUSES := ["overcharged", "braced", "primed", "retaliate", "barrier", "ward", "spun_up", "phased", "rallied"]


## Is this id one of the engine's statuses: an id in STATUS, or a die entry's Corrupted or
## Disabled (corrupted_<n>, disabled_<n>, one an entry)? A status is a chip in the fight
## whatever its scope (Ryan, 16 October: the Ammit is Overcharged, "so anything that
## interacts with overcharged needs it displayed"); a passive, a module's rule or a battle
## reward is none.
static func is_status(id: String) -> bool:
	if STATUS.has(id):
		return true
	for head in ["corrupted_", "disabled_"]:
		if id.begins_with(head) and id.substr(head.length()).is_valid_int():
			return true
	return false


## Kindled at a rally's own value: the status above with the move's value in place of the
## default, so the Howl's 5 is 5 and the chip says so.
static func kindled(value: int) -> Dictionary:
	var d: Dictionary = STATUS["kindled"].duplicate(true)
	d["description"] = "Hits %d harder this round." % value
	d["effects"][0]["value"] = value
	return d


## The armour one stack of Armoured adds (its add_stat): one, since 18 October.
static func braced_armour() -> int:
	for eff in STATUS["braced"]["effects"]:
		if str(eff.get("effect", "")) == "add_stat" and str(eff.get("stat", "")) == "armour":
			return int(eff.get("value", 0))
	return 0


## The stacks of Armoured a foe's brace of `value` armour grants (16 October): the value over a
## stack's armour, which is the value itself since a stack is a point (18 October).
static func brace_stacks(value: int) -> int:
	return int(maxi(0, value) / maxi(1, braced_armour()))


## What a foe carrying a status means (target_status, the Susceptibility Tensor; 10 October):
## what the team put on it. Never Numbed, a resistance and not a status, and never the foe's
## own buffs (Braced, Kindled, Getting Back Up).
const FOE_STATUSES := ["burning", "suppressed", "shocked", "paradox", "vitriol", "webbed", "cryoed", "flakked", "exposure", "syrinx_drone"]
## target_status: the foe struck carries any of FOE_STATUSES (Numbed and its own buffs never count).
## ally_present: another live machine is in the fight (the unit's `allies`, kept by the skirmish).
## A `tag_<tag>` condition reads the component's tags (10 October: a tag never carries a rule of
## its own; a passive may read one its machine's stock carries, the Badger's melee).
## target_no_intent (the funnel-web's Ambush, 18 October): the foe struck shows no intent on this
## machine, as the HUD draws its arrow (Foe.intent_on): aimed at another machine, Suppressed, or
## on a special that acts on nobody in particular; a gathering countdown and a blow at every
## machine count as aimed. Read at the spend before its own riders, each foe reached alone.
## attacker_status (the Prairie Dog's fight half, 21 October): the foe whose blow this machine
## is taking carries the status the effect's `status` names (any of FOE_STATUSES when it names
## none). Read by damage_taken alone, which is handed the striker; every other static query
## has no striker, so the condition never holds there. A status the engine lacks never holds.
const SUPPORTED_WHEN := ["component_cracked", "rolled", "reach_direct", "reach_indirect", "target_status", "ally_present", "target_no_intent", "attacker_status", "nth_shot", "target_rank"]
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
	var held := _held(u, passive, ROUNDS, 1, round)
	if held != null:
		return held
	var m := make(passive, ROUNDS, source)
	if m != null:
		m.expires_round = round
	return grant(u, m)


## How a second grant of a status lands: "add" or "renew" (the STATUS note above).
static func status_stacking(def: Dictionary) -> String:
	return str(def.get("stacking", "add"))


## The grant a second one of `passive` renews, or null when the status adds (and the caller
## grants as usual). A renewal takes the later end of two timed grants and the larger count,
## never a second stack.
static func _held(u, passive: Dictionary, scope: int, n: int, expires_round: int) -> Modifier:
	if status_stacking(passive) != "renew":
		return null
	var id := str(passive.get("id", ""))
	for m in u.modifiers:
		if m.id != id:
			continue
		if m.scope == ROUNDS and scope == ROUNDS:
			m.expires_round = maxi(m.expires_round, expires_round)
		m.stacks = maxi(m.stacks, n)
		return m
	return null


## Add stacks of a status. The same id in the same scope stacks up instead of doubling;
## a fresh one is granted with `n` stacks. Tick-decaying statuses lose a stack per tick, a
## halving one half of them. A timed one (ROUNDS) stacks up only with one ending the same
## round (a brace beside a buff of Armoured); a grant ending another round is its own
## modifier, so a later grant never lengthens an earlier one's stacks (16 October). A status
## that renews (its "stacking") is one grant however often it is granted. A machine that
## keeps the status (keep_status, the Ammit's Quintessence Tap) keeps every grant of it for
## the battle, whatever granted it (Ryan, 18 October: "that's the rules text, it doesn't care
## where it came from"): the grant's own scope and decay give way.
static func stack(u, passive: Dictionary, scope: int, source: String, n: int = 1, decay: int = DECAY_TICK, expires_round: int = -1) -> Modifier:
	if keeps(u, str(passive.get("id", ""))):
		scope = BATTLE
		decay = DECAY_NONE
		expires_round = -1
	var held := _held(u, passive, scope, n, expires_round)
	if held != null:
		return held
	var id := str(passive.get("id", ""))
	for m in u.modifiers:
		if m.id == id and m.scope == scope and (scope != ROUNDS or m.expires_round == expires_round):
			m.stacks += n
			return m
	var m := make(passive, scope, source)
	if m == null:
		return null
	m.stacks = n
	m.decay = decay
	m.expires_round = expires_round
	return grant(u, m)


## Every live stack of a status, across scopes and grants: a buff's Overcharged for the round
## and devour's for the skirmish, or a timed buff spent in two rounds, are one status to the
## machine.
static func stacks_of(u, id: String) -> int:
	var n := 0
	for m in live(u):
		if m.id == id:
			n += m.stacks
	return n


static func has(u, id: String) -> bool:
	return stacks_of(u, id) > 0


## Spend up to `n` stacks of a status, shortest-lived first (the hopper's loads, fired a few a
## shot): the shortest scope, and among timed grants the one ending soonest; a copy spent to
## nothing goes. Returns how many were spent.
static func spend_stacks(u, id: String, n: int) -> int:
	var spent := 0
	var order: Array = []
	for m in u.modifiers:
		if m.id == id:
			order.append(m)
	order.sort_custom(func(a, b) -> bool: return a.scope > b.scope or (a.scope == b.scope and a.expires_round < b.expires_round))
	for m in order:
		if spent >= n:
			break
		var take := mini(m.stacks, n - spent)
		m.stacks -= take
		spent += take
	u.modifiers = u.modifiers.filter(func(m) -> bool: return m.id != id or m.stacks > 0)
	return spent


## Drop every copy of a status, whatever its scope or grant: a spent one-shot (Shocked, once
## the blow it doubled has landed). Returns whether anything went.
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
## resist, share}. hp and heat are per stack sums; skip is any skip_action; resist is percent;
## share is the part of hp that is a share of the owner's current hull (tick_hp_share:
## Vitriol, 18 October), read after the flat ticks (after Burning), the whole share rounded
## down and never the last hit point, so it opens on a boss and finishes no foe.
## `at_turn_end` asks the statuses that tick at the end of the owner's turn (turn decay, a
## machine's Burning and Scorched), and only those; otherwise every other.
static func tick_preview(u, at_turn_end: bool = false) -> Dictionary:
	var out := {"hp": 0, "heat": 0, "skip": false, "resist": 0, "share": 0}
	var pct := 0
	for pair in _taking_part(u, "status", null):
		var eff: Dictionary = pair[0]
		var m: Modifier = pair[1]
		if ends_with_turn(m) != at_turn_end:
			continue
		var v := int(eff.get("value", 0)) * m.stacks
		match str(eff.get("effect", "")):
			"tick_hp":
				out["hp"] += v
			"tick_hp_share":
				pct += v
			"tick_heat":
				out["heat"] += v
			"skip_action":
				out["skip"] = true
			"resist_suppress":
				out["resist"] += v
	if pct > 0:
		var hp_now = u.get("hp")   # a foe's hull; a machine carries no share tick, and has no hp
		var left := (int(hp_now) if hp_now != null else 0) - int(out["hp"])
		if left > 1:
			out["share"] = mini(left - 1, int(floorf(float(left) * float(pct) / 100.0)))
			out["hp"] += int(out["share"])
	return out


## The value one stack of a status carries by an effect's name ("tick_hp_share" for the share
## Vitriol eats a stack, "cool_hitter" for Cryo's cooling, "corrupt_bite" for Corrupted's
## bite): the engine, the chips and the bot read it here, never hardcoded.
static func status_value(status_id: String, effect: String) -> int:
	var n := 0
	for eff in STATUS.get(status_id, {}).get("effects", []):
		if str(eff.get("trigger", "")) == "status" and str(eff.get("effect", "")) == effect:
			n += int(eff.get("value", 0))
	return n


## Does this modifier end with its owner's turn rather than the round (turn decay, either kind)?
static func ends_with_turn(m) -> bool:
	return m.decay == DECAY_TURN or m.decay == DECAY_TURN_ALL


## The decay a status names in its definition ("none", "round", "turn", "turn_all", "half"),
## a stack a tick when it names none.
static func status_decay(def: Dictionary) -> int:
	return {"none": DECAY_NONE, "round": DECAY_ROUND, "turn": DECAY_TURN, "turn_all": DECAY_TURN_ALL, "half": DECAY_HALF}.get(str(def.get("decay", "")), DECAY_TICK)


## Does the status run down to zero on its own clock (halving each tick), rather than end
## with a timer? Ryan, 18 October: "Things either decrease to zero, or are timed, not both",
## so a buff component granting such a status grants stacks and no rounds (grant_buff). Only
## a status that names its decay counts: one that names none ticks a stack when a passive
## grants it and is timed when a buff component does, as before.
static func decays_to_zero(def: Dictionary) -> bool:
	return str(def.get("decay", "")) == "half"


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
## every tick-decaying status loses a stack and the empty ones go. A machine's turn is the
## round's end, so its halving statuses halve here too; a foe's comes at its action, so it
## passes `halving` false and its halving statuses wait for the round's end (halve: Flak on
## Overcharged's clock, 21 October).
static func tick(u, halving: bool = true) -> Dictionary:
	var out := tick_preview(u)
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_ROUND:
			continue
		if m.decay == DECAY_TICK:
			m.stacks -= 1
			if m.stacks <= 0:
				continue
		elif m.decay == DECAY_HALF and halving:
			# Rounded down, so it reaches zero on its own (one stack halves to none).
			m.stacks = int(m.stacks / 2.0)
			if m.stacks <= 0:
				continue
		keep.append(m)
	u.modifiers = keep
	return out


## The round's end for a foe (Flak, 21 October: it halves at the end of each round, rounded
## down, Overcharged's clock): every halving status halves and the empty ones go. Its other
## statuses tick at its action (tick).
static func halve(u) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_HALF:
			m.stacks = int(m.stacks / 2.0)
			if m.stacks <= 0:
				continue
		keep.append(m)
	u.modifiers = keep


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
		"target_no_intent":
			return target != null and target.has_method("intent_on") and not target.intent_on(u)
		"attacker_status":
			return target != null and target.get("modifiers") != null and carries_status(target, str(eff.get("status", "")))
		"ally_present":
			return u.get("allies") != null and int(u.allies) > 0
		"target_rank":
			# The rank the spend is aimed at (the Cottonmouth's drum, 19 October): front or back;
			# nothing without a target in hand, so the keyword it grants waits for the aim.
			return target != null and target.get("rank") != null and int(target.get("rank")) == (1 if str(eff.get("rank", "front")) == "back" else 0)
		"nth_shot":
			# Every n-th weapon spend of the fight (the Cassowary's sixth shot): this one, when the
			# count so far is one short of a multiple of `every`.
			return face != null and face.is_attack() and (stacks_of(u, "shots") + 1) % maxi(1, int(eff.get("every", 6))) == 0
		"setup_once":
			# A setup (the Needletail's gate, 21 October): a debuff or a buff, read on the entry
			# as it is spent, while the machine's free one this round is unspent.
			return face != null and (face.is_debuff() or face.kind == Face.Kind.BUFF) and not has(u, "quick_turned")
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
	var p_mult := 1.0   # a multiply on the entry's own number alone, before the adds (the Kite's double: the printed number, buffs once)
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
			"multiply_printed":
				p_mult *= pow(v, n)
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
	var out_dmg := maxi(d_floor, int(roundf((float(dmg) * p_mult + d_add) * d_mult)))
	var out_heat := maxi(0, int(roundf((heat + h_add) * h_mult)))
	if face != null and face.is_debuff():
		# A debuff deals nothing under any effect (Ryan's die grammar, 20 and 21 October): no
		# flat add (Overcharged, Spun Up), no multiply, no floor, no burn of a Primed machine;
		# its heat is a weapon's and its keywords its whole effect. Read on the entry as spent,
		# so a weapon the Cottonmouth's drum fires is its shot of 15, a gun.
		out_dmg = 0
		burn = 0
	return {"damage": out_dmg, "heat": out_heat, "burn": burn, "vent": vent}


## An incoming blow before shield and armour see it: adds, then multiplies, never below zero.
## A blow of nothing (a lure, a web, a probe) stays nothing: an add on what a blow deals
## (Flak's point a stack) never turns no blow into one.
static func damage_taken(u, amount: int, source = null) -> int:
	if amount <= 0:
		return 0
	var add := 0.0
	var mult := 1.0
	for pair in _taking_part(u, "static", null, source):
		var eff: Dictionary = pair[0]
		var n: int = pair[1].stacks
		match str(eff.get("effect", "")):
			"add_damage_taken":
				add += float(eff.get("value", 0)) * n
			"multiply_damage_taken":
				mult *= pow(float(eff.get("value", 1)), n)
	return maxi(0, int(roundf((amount + add) * mult)))


## What a blow on this unit gains from its flat damage-taken adds alone (a foe's Flak), never
## its multiplies: the die over a foe folds it in as it does armour, and leaves a Shocked
## foe's doubling to its chip (Skirmish.shown_number).
static func damage_taken_add(u, source = null) -> int:
	var add := 0
	for pair in _taking_part(u, "static", null, source):
		if str(pair[0].get("effect", "")) == "add_damage_taken":
			add += int(pair[0].get("value", 0)) * int(pair[1].stacks)
	return add


## A component's reach as it is right now: its own, unless a live set_reach holds. Static
## reach rules are read against the component itself (never against effective reach, which
## would loop), so they may key on cracked but not on reach. The first live modifier in
## override order (shortest scope, latest granted) wins.
static func effective_reach(u, face: Face) -> int:
	if face == null:
		return Face.Reach.NONE
	face = rewritten(u, face)
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
## `printed_only`: just the grants written out (`printed`, the Boar's spill), which the die
## draws as the star with the hold reading the passive's line, never a keyword chip.
static func granted_keywords(u, face: Face, target = null, printed_only: bool = false) -> Array[int]:
	var out: Array[int] = []
	if face == null or face.kind == Face.Kind.BLANK:
		return out
	for pair in _taking_part(u, "static", face, target):
		if str(pair[0].get("effect", "")) != "grant_keyword":
			continue
		if printed_only and not bool(pair[0].get("printed", false)):
			continue
		var kw := Face.keyword_from_name(str(pair[0].get("value", "")))
		if kw <= 0 or face.has(kw) or out.has(kw):
			continue
		var fits := Face.ANY_KEYWORDS.has(kw) or (face.is_attack() != Face.SUPPORT_KEYWORDS.has(kw))
		if fits:
			out.append(kw)
	return out


## The statuses this machine's live passives lay on one foe its blow reaches (lay_status on
## on_attack, its `when` read against that foe: the funnel-web's Ambush, 18 October), as
## [[status id, stacks a hit], ...]. The skirmish asks once a foe at the spend, before any
## strike's riders land, and lays them a stack per strike that lands with a number; the bot
## asks the same. Nothing for a foe the condition rules out.
static func laid_statuses(u, face: Face, target) -> Array:
	var out: Array = []
	if face == null or not face.is_attack() or target == null:
		return out
	for pair in _taking_part(u, "on_attack", face, target):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "lay_status":
			continue
		var id := str(eff.get("value", ""))
		if not STATUS.has(id):
			continue
		out.append([id, maxi(1, int(eff.get("stacks", 1))) * int(pair[1].stacks)])
	return out


## Does any live passive of this machine read a foe's intent on it (a `when` of
## target_no_intent)? The screen's predator sense shows for such a machine alone.
static func reads_intent(u) -> bool:
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("when", "")) == "target_no_intent":
				return true
	return false


## The component as it is right now for this machine: its own entry, unless a live passive
## changes its reach, grants it a keyword or pushes its range (a raised ceiling or floor), in
## which case a copy carrying all of it. What the resolver spends, the bot weighs and the
## screen draws; the die keeps the real one.
static func effective_face(u, face: Face, target = null) -> Face:
	if face == null:
		return null
	var base := rewritten(u, face)
	var r := effective_reach(u, face)
	var muted := keywords_muted(u) and not base.keywords.is_empty()
	var granted: Array[int] = []
	var printed: Array[int] = []
	if not keywords_muted(u):
		granted = granted_keywords(u, base, target)
		printed = granted_keywords(u, base, target, true)
	var ceiling := ceiling_bonus(u, base)
	var floor_up := floor_bonus(u, base)
	if base == face and r == face.reach and granted.is_empty() and ceiling == 0 and floor_up == 0 and not muted:
		return face
	var c := base.duplicate_face() if base == face else base
	if muted:
		c.keywords.clear()   # Silenced: the entry acts without its keywords this round
	c.reach = r
	for kw in granted:
		c.add_keyword(kw)
		if printed.has(kw) and not c.printed.has(kw):
			c.printed.append(kw)
	c.power_max += ceiling
	c.power = mini(c.power + floor_up, c.power_max)
	return c


## A weapon as a live rewrite fires it (the Cottonmouth's Adaptive Munitions Drum, Ryan's go of
## 19 October): every weapon leaves as the drum's shot, its number flat, its reach and its heat
## the rewrite's, one blow, its tag added, and its keywords, rules and other tags kept. Any
## other entry, or none, is the face itself. Read first, under every other passive's change.
static func rewritten(u, face: Face) -> Face:
	if face == null or not face.is_attack():
		return face
	# Read alone, never through every static effect's gate: a reach condition asks the reach,
	# and the reach asks this (so a rewrite never keys on reach, as set_reach never does).
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != "static" or str(eff.get("effect", "")) != "rewrite_weapon":
				continue
			if str(eff.get("when", "")).begins_with("reach_") or not _usable(u, m, "rewrite_weapon") or not _holds(u, eff, face):
				continue
			return _rewrite(face, eff)
	return face


## The drum's shot from a weapon and the rewrite that fires it.
static func _rewrite(face: Face, eff: Dictionary) -> Face:
	var c := face.duplicate_face()
	c.power = maxi(0, int(eff.get("value", c.power)))
	c.power_max = c.power
	var rr := Face.reach_from_name(str(eff.get("reach", "")))
	if rr > 0:
		c.reach = rr
	c.heat = maxi(0, int(eff.get("heat", c.heat)))
	c.strikes = 1
	var tag := str(eff.get("tag", ""))
	if not tag.is_empty() and not c.tags.has(tag):
		c.tags.append(tag)
	return c


## Does a foe carry a status the team put on it (FOE_STATUSES)? Numbed and its own buffs
## never count.
static func carries_status(f, which: String = "") -> bool:
	for m in live(f):
		if (which.is_empty() and FOE_STATUSES.has(m.id)) or (not which.is_empty() and m.id == which):
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


## What a foe's armour gains from its statuses (add_stat armour, static; a braced foe), per
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


## The form a machine seals into (seal_form, static; the Armadillo's Lockdown, 20 October):
## {"armour": the armour the seal grants, "heat": what it runs hotter at the end of each turn}
## when a live passive carries it, else empty.
static func seal_form(u) -> Dictionary:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "seal_form":
			return {"armour": int(pair[0].get("value", 0)), "heat": int(pair[0].get("heat", 0))}
	return {}


## The Sealed status with the seal's own numbers in it: the chip the machine wears while
## sealed, carrying the armour as its one effect (the stat pipeline reads it like any add).
static func sealed_status(armour: int, heat: int) -> Dictionary:
	var d: Dictionary = STATUS["sealed"].duplicate(true)
	d["description"] = "Sealed: armour +%d, its own cooling stopped, %d hotter at the end of each turn. A vent or a damaging weapon opens it." % [armour, heat]
	d["effects"] = [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": armour}]
	return d


static func is_sealed(u) -> bool:
	return has(u, "sealed")


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
## (stack_status: its `stacks`, one by default, for the skirmish, decaying as the status
## says, never past its `cap` when it names one, a store's), on `onto` when it is given (the
## ally an on_shield_granted passive shields) and on the machine itself otherwise.
## Nothing here can fire itself: a shield gained here grants no more shield, heat shed here
## grants no heat.
static func fire(u, trigger: String, amount: int = 0, onto = null) -> Dictionary:
	var out := {"shield": 0, "vent": 0, "statuses": [] as Array[String]}
	for pair in _taking_part(u, trigger, null):
		var eff: Dictionary = pair[0]
		var v: int = int(eff.get("value", 0)) * int(pair[1].stacks)
		match str(eff.get("effect", "")):
			"shield_per_heat":
				out["shield"] += v * int(amount / maxi(1, int(eff.get("per_heat", 10))))
			"add_shield":
				out["shield"] += v
			"vent_heat":
				out["vent"] += v
			"stack_status":
				var id := str(eff.get("value", ""))
				if STATUS.has(id):
					var who = u if onto == null else onto
					var n := maxi(1, int(eff.get("stacks", 1))) * int(pair[1].stacks)
					# A store's cap (the Nemesis's rage, five; Ryan, 22 October): it banks no more.
					if int(eff.get("cap", 0)) > 0:
						n = mini(n, int(eff["cap"]) - banked(who, id))
					if n > 0:
						var decay := status_decay(STATUS[id])
						var m := stack(who, STATUS[id], SKIRMISH, "passive:" + str(pair[1].id), n, decay)
						if m != null and not (out["statuses"] as Array).has(m.name):
							(out["statuses"] as Array).append(m.name)
	return out


## Every stack of a status the machine carries, live or asleep: what a cap counts.
static func banked(u, id: String) -> int:
	var n := 0
	for m in u.modifiers:
		if m.id == id:
			n += m.stacks
	return n


## The most stacks of a store a live passive lets this machine bank (stack_status's cap, any
## trigger; the Nemesis's rage, five, Ryan, 22 October), 0 when nothing caps it: the boxes of
## its bar under the heat.
static func store_cap(u, id: String) -> int:
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("effect", "")) == "stack_status" and str(eff.get("value", "")) == id and int(eff.get("cap", 0)) > 0:
				return int(eff["cap"])
	return 0


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


## The shield this machine's spend gives an ally beyond the entry's own number: its passives'
## shield_per_ally_heat (on_shield_granted; the Puffin's Slipstream Projector, 21 October),
## `value` for every `per_heat` (10 until the stock pass's landing) the ally carries, pro rata
## and rounded down, so a value of 2 per 10 is a fifth of the ally's heat. Read at the spend,
## before the shield lands, from the heat the ally
## carries then; never on the machine itself, since the trigger is for allies (the caller asks
## only for an ally). The die dragged over the ally and the bot read the same number.
static func granted_shield(u, ally_heat: int) -> int:
	var n := 0.0
	for pair in _taking_part(u, "on_shield_granted", null):
		if str(pair[0].get("effect", "")) == "shield_per_ally_heat":
			n += float(int(pair[0].get("value", 0)) * int(pair[1].stacks) * maxi(0, ally_heat)) / float(maxi(1, int(pair[0].get("per_heat", 10))))
	return maxi(0, floori(n + 0.000001))


## The heat an ally this machine shields would shed (on_shield_granted vent_heat), for the
## bot to weigh a shield spend on an ally by.
static func granted_vent(u) -> int:
	var n := 0
	for pair in _taking_part(u, "on_shield_granted", null):
		if str(pair[0].get("effect", "")) == "vent_heat":
			n += int(pair[0].get("value", 0)) * int(pair[1].stacks)
	return maxi(0, n)


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


## Does this machine's die step instead of rolling (the Cassowary's Indexed Cylinder, Ryan's
## wording of 12 October: "Whenever its die rolls, it moves to the next entry instead, in
## sequence")?
static func steps_die(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "step_die":
			return true
	return false


## Every how many weapon spends a live rule of this machine lands (the Cassowary's sixth
## shot): the `every` of its first nth_shot effect, 0 when nothing counts. The skirmish keeps
## the count only for a machine that has one, and the screen draws it as that many pips.
static func counts_shots(u) -> int:
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("when", "")) == "nth_shot":
				return maxi(1, int(eff.get("every", 6)))
	return 0


## Whether this machine's next weapon spend is the one its count lands on.
static func nth_shot_due(u) -> bool:
	var every := counts_shots(u)
	return every > 0 and (stacks_of(u, "shots") + 1) % every == 0


## What the stacks a weapon spend lays are multiplied by (the sixth shot's double), through
## the on_attack multiply_stacks effects that hold for it: 1 when none does.
static func stack_multiplier(u, face: Face, target = null) -> int:
	var mult := 1
	for pair in _taking_part(u, "on_attack", face, target):
		if str(pair[0].get("effect", "")) == "multiply_stacks":
			mult *= int(pow(maxf(1.0, float(pair[0].get("value", 1))), int(pair[1].stacks)))
	return mult


## Are this machine's components' keywords muted (Silenced, 21 October)? Its entries are spent,
## shown and weighed without them, granted ones too, while the die keeps the real ones.
static func keywords_muted(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "mute_keywords":
			return true
	return false


## Is this modifier one a silence turns off and a purge takes: a buff (a kept Overcharged
## too), never a store (Ryan, 21 October: a store is a capped resource, as heat and the
## magazine are, so the rage, the hopper and the Muster stay), a passive, a module's rule or a
## count?
static func purgeable(m) -> bool:
	return m.scope != LOADOUT and m.tags.has("buff")


## The stacks of buffs a machine carries, silenced or not: what a foe that aims at the buffed
## reads.
static func buff_stacks(u) -> int:
	var n := 0
	for m in u.modifiers:
		if purgeable(m):
			n += maxi(1, m.stacks)
	return n


## A purge (the enemy's Purge, a hero's or a boss's, 17 October; built 21 October): every buff
## on the machine goes, every stack, the kept ones included (they last the battle and never
## between battles); its stores stay (Ryan, 21 October). Returns the names of what went, once
## each.
static func purge(u) -> Array[String]:
	var gone: Array[String] = []
	var keep: Array = []
	for m in u.modifiers:
		if purgeable(m):
			if not gone.has(m.name):
				gone.append(m.name)
		else:
			keep.append(m)
	u.modifiers = keep
	return gone


## The Siphoning status with an entry's own heat a blow (the Whip Scorpion's Heliographic
## Siphon), as kindled() carries a rally's value.
static func siphon_status(per_blow: int) -> Dictionary:
	var s: Dictionary = STATUS["siphoning"].duplicate(true)
	s["description"] = "Every blow a foe lands on it this round adds %d heat." % per_blow
	s["effects"] = [{"trigger": "static", "effect": "heat_per_blow", "value": per_blow}]
	return s


## The heat every blow a foe lands on this machine adds this round (Siphoning), 0 for none.
static func heat_per_blow(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "heat_per_blow":
			n += int(pair[0].get("value", 0))
	return n


## What this machine's vents spent on itself blast a random foe for, as a share of the heat
## they take off it (the Whip Scorpion's Thermal Ejection Manifold, 12 and 13 October; built
## 21 October): 1 for the whole heat, 0 when nothing blasts.
static func vent_blast(u) -> float:
	var share := 0.0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "vent_blast":
			share += float(pair[0].get("value", 1))
	return share


## A count as the rules say it: "sixth".
static func ordinal(n: int) -> String:
	var words := {1: "first", 2: "second", 3: "third", 4: "fourth", 5: "fifth", 6: "sixth", 7: "seventh", 8: "eighth", 9: "ninth", 10: "tenth"}
	return str(words.get(n, "%dth" % n))


## Switch one die entry off until the end of `until_round`: the entry shows dark, the
## component itself is untouched. Applied to the target's showing entry by a foe's disable
## (through the mech's next turn) and by a spent entry's own cooldown (`source` "cooldown":
## the rounds it prints, this one included, Rapid's switch-off a cooldown of one). A foe's
## disable can be cleansed; a cooldown cannot (it is the piece's price, and a cleanse that
## lifted Rapid's would start an infinite turn).
static func disable_entry(u, index: int, source: String, until_round: int) -> Modifier:
	var cooldown := source == "cooldown"
	var status := {"id": "disabled_%d" % index, "name": "Cooldown" if cooldown else "Disabled",
		"description": "This component is dark, cooling down." if cooldown else "This component is switched off.",
		"tags": [] if cooldown else [CLEANSABLE],
		"effects": [{"trigger": "status", "effect": "disable_entry", "value": index}]}
	return grant_for_rounds(u, status, source, until_round)


## The rounds every weapon this machine spends goes dark, granted by its passives (static
## weapon_cooldown; the Kite's Disabled Weapon Regulators, 21 October: the cooldown property
## granted), the longest live one; 0 for none or for equipment. An entry's own cooldown stands
## beside it and the longer wins (Skirmish.cooldown_of).
static func granted_cooldown(u, face: Face) -> int:
	if face == null or not face.is_weapon():
		return 0
	var n := 0
	for pair in _taking_part(u, "static", face):
		if str(pair[0].get("effect", "")) == "weapon_cooldown":
			n = maxi(n, int(pair[0].get("value", 0)))
	return n


## The machine's muster rule (static muster, the Swallowtail's Muster Deck, 21 October): its
## points a charge (`value`), its cap in charges (`cap`), the points a kill by its own guns
## gives (`kill`); empty for a machine that musters nothing.
static func muster_rule(u) -> Dictionary:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "muster":
			return pair[0]
	return {}


## The machine's forge rule (static forge, the Musk Ox's Desublimation Forge, 21 October): its
## magazine's size (`value`), the load it opens each fight with (`start`), the round's trickle
## (`per_round`), the heat an ammo stands for (`per_heat`), and what a vent (`vent`) and a shield
## (`shield`) it spends on itself reload; empty for a machine that forges nothing.
static func forge_rule(u) -> Dictionary:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "forge":
			return pair[0]
	return {}


## The heat a weapon's spend would make that a foe's debuff adds (Scorched's extra, a
## cleansable status's add_heat): the part a forge leaves on the heat bar.
static func debuff_heat(u, face: Face) -> int:
	var add := 0
	for pair in _taking_part(u, "on_attack", face):
		var m: Modifier = pair[1]
		if str(pair[0].get("effect", "")) == "add_heat" and m.tags.has(CLEANSABLE):
			add += int(pair[0].get("value", 0)) * m.stacks
	return add


## What a damaging gun costs a forging machine in ammo (the Musk Ox's, 21 October): 1 for every
## `per_heat` of the heat the gun's own spend would make through the pipeline, a foe's debuff's
## extra aside, rounded up, at least 1 (a gun of no heat pays 1); 0 for anything else, a debuff
## included, and on any machine that forges nothing.
static func ammo_price(u, face: Face) -> int:
	var rule := forge_rule(u)
	if rule.is_empty() or face == null or not face.is_attack() or face.is_debuff():
		return 0
	var own := maxi(0, int(attack(u, face, 0, face.heat)["heat"]) - debuff_heat(u, face))
	return maxi(1, ceili(float(own) / float(maxi(1, int(rule.get("per_heat", 10))))))


## Does this machine carry its neighbours when it moves on the map (static carry, the Swallowtail's
## Muster Deck, 21 October)?
static func carries(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "carry":
			return true
	return false


## The charges the machine's Muster holds right now (a Silenced store holds none it can spend).
static func muster_charges(u) -> int:
	var rule := muster_rule(u)
	if rule.is_empty():
		return 0
	return stacks_of(u, "muster") / maxi(1, int(rule.get("value", 30)))


## Is this entry Rapid by a once-a-round gate (a grant_keyword of rapid on setup_once, the
## Needletail's Quick-turn Avionics Relay, 21 October), its own Rapid aside? Spent so, the gate
## closes for the round (the quick_turned marker).
static func quick_turn_live(u, face: Face) -> bool:
	if face == null:
		return false
	var base := rewritten(u, face)
	if base.has(Face.Keyword.RAPID) or keywords_muted(u):
		return false
	for pair in _taking_part(u, "static", base, null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) == "grant_keyword" and str(eff.get("value", "")) == "rapid" and str(eff.get("when", "")) == "setup_once":
			return true
	return false


## Does this machine lay mines (static lay_mines; the Lammergeier's Fuse-delayed Bay, 21
## October): its weapons may be spent on an empty slot in the enemy's formation, the shot
## waiting there for whoever steps in.
static func lays_mines(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "lay_mines":
			return true
	return false


## Every entry dark from a cooldown comes back at once (the Kite's reset gun, 21 October: a
## kill brings every weapon back); an entry a foe switched off stays off. Returns how many.
static func clear_cooldowns(u) -> int:
	var back := 0
	for m in u.modifiers.duplicate():
		if m.source == "cooldown":
			u.modifiers.erase(m)
			back += 1
	return back


## The rounds an entry stays dark, this one included: the latest end of whatever switched it
## off (a cooldown, a foe's disable) less `round`, plus one; 0 for a lit entry. The die shows
## it on the dark entry (the cooldown row: dark with the rounds left).
static func dark_rounds(u, index: int, round: int) -> int:
	var until := -1
	for m in live(u):
		if m.scope != ROUNDS:
			continue
		for eff in m.effects:
			if str(eff.get("effect", "")) == "disable_entry" and int(eff.get("value", -1)) == index:
				until = maxi(until, m.expires_round)
	return maxi(0, until - round + 1) if until >= 0 else 0


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
## `until_round`. A grant ending the same round as one already there stacks onto it; one
## ending another round is its own, and each goes when its own rounds run out (16 October).
## A status that decays to zero on its own (Overcharged, halving) takes no rounds: the grant
## carries the status's decay and lasts the skirmish or until it runs out (18 October).
static func grant_buff(u, status_id: String, stacks: int, source: String, until_round: int) -> Modifier:
	if not STATUS.has(status_id):
		return null
	var def: Dictionary = STATUS[status_id]
	if decays_to_zero(def):
		return stack(u, def, SKIRMISH, source, stacks, status_decay(def))
	# One a use spends (Spun Up, spent by the next weapon spend) lasts until then, across turns.
	if def.has("spent_by"):
		return stack(u, def, SKIRMISH, source, stacks, DECAY_NONE)
	return stack(u, def, ROUNDS, source, stacks, DECAY_NONE, until_round)


## Corrupt one die entry for the skirmish (the corrupt foe keyword, 25 September): every
## time the entry is spent it bites its owner, per stack. The component itself is untouched;
## the same entry corrupted again stacks up. Cleansable.
static func corrupt_entry(u, index: int, source: String, n: int = 1) -> Modifier:
	var def: Dictionary = STATUS["corrupted"]
	var status := {"id": "corrupted_%d" % index, "name": def["name"], "description": def["description"],
		"tags": (def["tags"] as Array).duplicate(), "effects": [{"trigger": "status", "effect": "corrupt_entry", "value": index}]}
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
	var signed := vs if vs.begins_with("-") else "+" + vs   # an add reads with its sign, never "+-5"
	var body := ""
	match str(eff.get("effect", "")):
		"multiply_damage": body = "damage ×%s" % vs
		"multiply_printed": body = "the printed number ×%s, before any buff" % vs
		"weapon_cooldown": body = "every weapon it fires goes dark for %s rounds" % vs
		"lay_mines": body = "its weapons may be spent on an empty slot in the enemy's formation, the shot waiting there for whoever steps in"
		"carry": body = "the machines beside it on the map travel with it when it moves"
		"forge": body = "its damaging guns spend ammo instead of heating it, 1 for every %d heat, its magazine %s, opening at %d and gaining %d a round" % [int(eff.get("per_heat", 10)), vs, int(eff.get("start", 0)), int(eff.get("per_round", 0))]
		"muster": body = "every die that rolls fills its Muster a point, %s a charge, a kill by its own guns %d more, up to %d charges" % [vs, int(eff.get("kill", 0)), int(eff.get("cap", 3))]
		"add_damage": body = "damage %s" % signed
		"min_damage": body = "damage at least %s" % vs
		"multiply_heat": body = "heat ×%s" % vs
		"add_heat": body = "heat %s" % signed
		"add_burn": body = "+%s burn" % vs
		"lay_status":
			var n := int(eff.get("stacks", 1))
			body = "lays %s on each foe hit, %s a hit" % [str(STATUS.get(str(v), {}).get("name", str(v))), "a stack" if n <= 1 else "%d stacks" % n]
		"vent_heat": body = "sheds %s heat" % vs
		"add_ceiling": body = "rolls reach %s higher" % vs
		"add_floor": body = "the lowest roll %s higher" % vs
		"no_destroy": body = "cracked components are never destroyed"
		"set_reach": body = "reach becomes %s" % vs
		"add_stat": body = "%s +%s" % [str(eff.get("stat", "")), vs]
		"multiply_stat": body = "%s ×%s" % [str(eff.get("stat", "")), vs]
		"add_damage_taken": body = "damage taken %s" % signed
		"multiply_damage_taken": body = "damage taken ×%s" % vs
		"suppress": body = "turns off %s" % vs
		"shock_on_hull_strike": body = "a foe that strikes bare hull is Shocked"
		"shock_on_block": body = "a foe whose blow the shield blocks is Shocked"
		"grant_keyword":
			var kw := Face.keyword_from_name(str(v))
			body = "gains %s" % (Face.keyword_label(kw) if kw > 0 else str(v))
		"add_armour_vs_rank": body = "armour +%s against %s-rank blows" % [vs, str(eff.get("rank", "front"))]
		"keep_status": body = "%s never fades and lasts the battle" % str(STATUS.get(str(v), {}).get("name", str(v)))
		"seal_form": body = "a shield spent on itself seals it: armour +%s, its own cooling stopped, %s hotter at the end of each turn; a vent or a damaging weapon opens it" % [vs, str(eff.get("heat", 0))]
		"screen_withdraw": body = "on a withdrawal this machine is out before the enemy strikes, and each ally has a %s%% chance to slip out with it; a blow at a covered machine is lost" % vs
		"stack_status":
			var nm := str(STATUS.get(str(v), {}).get("name", str(v)))
			var k := maxi(1, int(eff.get("stacks", 1)))
			body = ("gains a stack of %s" % nm) if k == 1 else ("gains %s ×%d" % [nm, k])
			if int(eff.get("cap", 0)) > 0:
				body += ", up to %d" % int(eff["cap"])
		"add_attack": body = "attack %s" % signed
		"never_hunted": body = "no hunter ever picks it as its prey"
		"extra_action": body = "%s more action%s a turn: move and fight again" % [vs, "" if int(v) == 1 else "s"]
		"hull_per_spend": body = "every component it spends costs %s hull" % vs
		"step_die": body = "its die never rolls: each fight opens on a random entry, and every roll steps it to the next in order"
		"rewrite_weapon": body = "every weapon fires as one %s %s blow, heat %s, its keywords and rules kept" % [str(eff.get("reach", "direct")), vs, str(eff.get("heat", 0))]
		"vent_blast": body = "a vent it spends on itself blasts a random foe for %s the heat it takes off" % ("the whole of" if is_equal_approx(float(v), 1.0) else "%s×" % vs)
		"heat_per_blow": body = "every blow a foe lands on it adds %s heat" % vs
		"mute_keywords": body = "its components' keywords are muted"
		"multiply_stacks": body = "the stacks it lays ×%s" % vs
		"scramble_reroll": body = "the next reroll of this die lands anywhere"
		"free_reroll": body = "%s free reroll%s of this die a round" % [vs, "" if int(v) == 1 else "s"]
		"shield_per_heat": body = "+%s shield for every %d heat carried" % [vs, int(eff.get("per_heat", 10))]
		"shield_per_ally_heat": body = "the shield grows by %s for every %d heat it carries" % [vs, int(eff.get("per_heat", 10))]
		"add_shield": body = "+%s shield" % vs
		"tick_hp": body = "%s damage per stack each turn" % vs
		"tick_hp_share": body = "loses %s%% of its current HP per stack each turn" % vs
		"tick_heat": body = "%s heat per stack each turn" % vs
		"skip_action": body = "skips its action"
		"resist_suppress": body = "resists suppress %s%% per stack" % vs
		"disable_entry": body = "die entry %s switched off" % str(int(v) + 1)
		"corrupt_entry": body = "die entry %s bites its owner when spent" % str(int(v) + 1)
		"corrupt_bite": body = "bites its owner %s a stack when its entry is spent" % vs
		"cool_hitter": body = "a damaging hit on it cools the hitter %s heat a stack" % vs
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
		"on_kill": lead = "after an attack that killed: "
	match str(eff.get("when", "")):
		"component_cracked": lead += "cracked components: "
		"rolled": lead += "rolled weapons: "
		"reach_direct": lead += "direct attacks: "
		"reach_indirect": lead += "indirect attacks: "
		"target_status": lead += "foes carrying a status: "
		"target_no_intent": lead += "foes showing no intent on this machine: "
		"attacker_status":
			var st := str(eff.get("status", ""))
			lead += "blows from foes carrying %s: " % (str(STATUS[st]["name"]) if STATUS.has(st) else (st.capitalize() if not st.is_empty() else "a status"))
		"ally_present": lead += "with an ally in the fight: "
		"nth_shot": lead += "every %s shot: " % ordinal(int(eff.get("every", 6)))
		"target_rank": lead += "aimed at the %s rank: " % str(eff.get("rank", "front"))
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
	# A status granted again in a later round is a second modifier of one status (16 October):
	# its effects are listed once.
	var listed := {}
	for m in live(u):
		if STATUS.has(m.id):
			if listed.has(m.id):
				continue
			listed[m.id] = true
		for eff in m.effects:
			var trig := str(eff.get("trigger", ""))
			var name := str(eff.get("effect", ""))
			if trig == "static" and name == "set_reach":
				if not str(eff.get("when", "")).begins_with("reach_") and _usable(u, m, name) and _holds(u, eff, face) and effective_reach(u, face) == Face.reach_from_name(str(eff.get("value", ""))) and effective_reach(u, face) != face.reach:
					out.append("%s (%s)" % [effect_text(eff), m.name])
			elif trig == "static" and name == "grant_keyword":
				var kw := Face.keyword_from_name(str(eff.get("value", "")))
				if kw > 0 and not face.has(kw) and granted_keywords(u, face).has(kw):
					# A grant written out (the Boar's spill) reads the passive's own line, the
					# star's text, since the player learns no keyword for it.
					out.append("%s (%s)" % [m.description if bool(eff.get("printed", false)) and not m.description.is_empty() else effect_text(eff), m.name])
			elif trig == "on_attack":
				# A condition on the target is shown as a rule (its lead says when), since
				# the row has no target in hand. A raised ceiling means nothing to a flat face.
				if (name == "add_ceiling" or name == "add_floor") and not face.is_ranged():
					continue
				if _usable(u, m, name) and (str(eff.get("when", "")) in ["target_status", "target_no_intent"] or _holds(u, eff, face)):
					out.append("%s (%s)" % [effect_text(eff), m.name])
	return out


## Every live modifier as [name, description, source, scope, stacks, id]: the codex lists
## the loadout and battle ones, the hold popup the skirmish and round ones. One row a
## modifier, so a status granted in two rounds is two rows; the chips sum them by id.
static func describe(u) -> Array:
	var out: Array = []
	for m in live(u):
		out.append([m.name, m.description, m.source, m.scope, m.stacks, m.id])
	return out

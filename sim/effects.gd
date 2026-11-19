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
## In an attack, the number (with what heat fired or the target's missing hull adds) comes
## first, from the skirmish, so the pipeline's adds and multiplies come last.
##
## Stacking. A modifier has stacks (one by default). Granting the same id in the same scope
## again adds stacks instead of a second copy; an add is worth its value per stack, a
## multiply is applied once per stack. A timed grant (ROUNDS) adds its stacks only to one
## that ends the same round, and is otherwise a modifier of its own, so each grant's stacks
## go when its own rounds run out (Ryan, 16 October: "Timed stacks should decay based on when
## they started. Not stack and refresh."); every reader sums a status across its modifiers.
## A status with tick decay ticks at its owner's turn:
## its tick effects apply per stack (tick_hp), then it loses one stack and is
## gone at zero. A machine's Ablating and Scorched tick at the end of its turn instead (turn
## decay, 13 October): Ablating's points land before the overheat and a stack goes; Scorched
## goes whole.

const LOADOUT := 0
const BATTLE := 1
const SKIRMISH := 2
const ROUNDS := 3

## What the content may ask for, by trigger. The validator refuses anything else.
const SUPPORTED_EFFECTS := {
	"on_attack": ["multiply_damage", "add_damage", "min_damage", "multiply_heat", "add_heat", "lay_status", "multiply_stacks", "multiply_printed", "split_strikes"],
	"on_injury": ["no_destroy"],
	"static": ["set_reach", "add_stat", "multiply_stat", "add_damage_taken", "multiply_damage_taken", "suppress", "grant_keyword", "ignore_armour", "spillover", "hold_all", "free_reroll", "one_of_each", "add_attack", "never_hunted", "extra_action", "hull_per_spend", "seal_form", "step_die", "fold_die", "rewrite_weapon", "heat_per_blow", "reboot_release", "shove_behind", "mine_on_spend", "muster", "carry", "forge", "bank_rerolls", "fill_hopper", "hopper_plate", "hold_status", "self_status", "shield_zap", "add_power", "offhand", "side_strike", "strike_again", "buff_status"],
	"on_hull_damage": ["stack_status", "add_shield", "vent_heat"],
	"on_shield_hit": ["stack_status", "add_shield", "vent_heat"],
	"on_blocked": ["stack_status"],
	"on_barrier": ["stack_status"],
	"on_skirmish_start": ["add_shield", "vent_heat", "stack_status"],
	"on_shield_gain": ["vent_heat", "stack_status"],
	"on_shield_granted": ["vent_heat", "stack_status", "shield_per_ally_heat"],
	"on_heat_gain": ["add_shield", "shield_per_heat", "stack_status"],
	"status": ["tick_hp", "tick_hp_share", "skip_action", "disable_entry", "corrupt_entry", "regrow"],
	"on_foe_status": ["paradox"],
	"on_stack": ["add_stacks"],
	"on_damage": ["stack_status", "add_shield", "vent_heat"],
	"on_kill": ["stack_status", "add_shield", "vent_heat", "refill_shield"],
	"on_round_kill": ["stack_status"],   # the end of a round in which an attack of this machine's own killed, once however many fell (the Ammit's flare, Ryan, 16 November)
	"on_foe_killed": ["stack_status", "add_shield"],   # every kill in this machine's fight, whoever made it, once for each foe (the Ammit's Essence, 12 November; the Buzzard's carrion, 18 November)
}
const DECAY_NONE := 0    # lives until its scope ends
const DECAY_TICK := 1    # loses a stack as its carrier's turn ends, gone at zero: a foe's stacks at the end of its own action (Ablating, Vitriol, Regenerating), since 16 November; at its start until then
const DECAY_ROUND := 2   # gone as its side's next turn begins, every stack at once (Armoured: Ryan, 15 November, "The common \"end\" state between both sides is \"start of their next turn.\""): a machine's as the round opens, a foe's as the enemy's turn opens (turn_opens, both)
const DECAY_TURN := 3    # ticks at the end of its owner's turn and loses a stack there, not at the round's end (a machine's Ablating, 13 October)
const DECAY_TURN_ALL := 4    # lasts until the end of its owner's turn, every stack going there at once (a machine's Scorched, 13 October: it never piles up)
const DECAY_HALF := 5    # halves, rounded down, gone at zero (Empowered, 18 October: a halving rule has no duration): a buff as its carrier's turn ends, where it has worked (Empowered: a machine's at END TURN, a foe's as its own action ends: halve_buffs); a debuff as its carrier's turn starts, where the other side's blows have used it (Brittle: turn_opens)
const DECAY_AFTER_TURN := 6    # gone after its owner's next turn, every stack at once: a foe's at the end of its next action, a machine's at the end of the player's turn (Sapped, 11 November)
const DECAY_START := 7   # a timed mark that falls as its carrier's turn starts, the first one after the round it names (Exposed: Ryan, 16 November, "Exposed on next turn start"); the round's end leaves it alone
const DECAY_BREAK := 8   # lasts until its machine's shield breaks, every stack going then, a reboot's drop included (Hardened Light: Ryan, 18 November, "The reboot breaks it yes. When it breaks, it loses all of them"); no turn and no round touches it (clear_on_break)

## The tag a cleanse clears (decided 25 September): what a foe did to a machine, never what
## the machine did to itself (a component's own cooldown, the price a Rapid piece pays).
const CLEANSABLE := "cleansable"

## The engine's own statuses, granted by keywords and foe attacks. Names are placeholders
## for Ryan's vocabulary; ids are what the engine keys on.
## A status may name how a second grant of it lands, "stacking" (Ryan, 17 October: renewal
## without stacking must be supported, "a pretty common thing for a powerful or non-number-
## related buff to do"): "add", the default, stacks it, a timed grant keeping its own end;
## "renew" keeps one grant, its end the later and its count the larger, so on an untimed
## one-stack status (Shocked, Guarded) a second grant changes nothing (Ryan, 17 October:
## never stacking and renewing are one state, parted only by a timer).
## A status may be "single": one stack whoever grants it and however deep the grant, so no
## passive that deepens a stack counts it past one (the Barrier, Ryan, 10 November: "Barrier
## probably shouldn't be stackable. The stingray stacks it due to its passive": its Exothermic
## Suite had it read x2 at five heat, though it only ever took one blow).
const STATUS := {
	# Ablating on a foe (Ryan, 15 November: Ablate, his word, in Burn's place; "evokes eating
	# though armour to me"). A damage point a stack since 18 October (in the spirit of flattening
	# the numbers; 5 before), the stacks the Ablate keyword's own number.
	"ablating": {"id": "ablating", "name": "Ablating", "description": "Loses {value} HP per stack as its turn ends, then loses a stack.",
		"tags": ["dot"], "effects": [{"trigger": "status", "effect": "tick_hp", "value": 1}]},
	# The Nemesis's rage (Ryan, 12 October, in place of the Crucible): its passive banks a
	# stack for every hull hit, its own included, for the skirmish (`decay` none overrides a
	# passive's tick), and an entry that rolls again on it spends one to roll the die again.
	# A store like the hopper: it does nothing by itself.
	"rage": {"id": "rage", "name": "Rage", "description": "Banked for the skirmish, up to its cap; a piece charged on rage spends it for its charged form.", "decay": "none",
		"tags": ["store"], "effects": []},
	# Ablating on a machine, the same rule on the other body (Ryan, 15 November: "hits shield
	# first, I think. Pretty deadly otherwise. Bypasses armour when damaging hull"; "Tick of ablate
	# ignores barrier yes"): a point a stack at the end of the player's turn, before the overheat,
	# so the player has a turn to cleanse what the foes laid; the shield first, then the hull past
	# armour; then a stack fades (Skirmish._ablate_mechs). It took the place of Burning as heat (13
	# October), which the reboot left with one answer where its row asked for two. Scorched is
	# the foes' tax on heat: every weapon and equipment aimed at a foe runs hotter until the
	# turn's end, when every stack goes, so it never piles up under several scorchers, and a hold,
	# a buff or a cool weapon plays round it.
	"ablating_mech": {"id": "ablating_mech", "name": "Ablating", "description": "Loses {value} shield per stack as its turn ends, then hull, past armour and a Barrier; then loses a stack.", "decay": "turn",
		"tags": ["dot", CLEANSABLE], "effects": [{"trigger": "status", "effect": "tick_hp", "value": 1}]},
	"scorched": {"id": "scorched", "name": "Scorched", "description": "Every weapon and equipment it aims at a foe runs {value} hotter per stack, until its turn ends, when every stack goes.", "decay": "turn_all",
		"tags": [CLEANSABLE], "effects": [{"trigger": "on_attack", "effect": "add_heat", "value": 1}]},
	"suppressed": {"id": "suppressed", "name": "Suppressed", "description": "Skips its next turn.", "stacking": "renew",
		"effects": [{"trigger": "status", "effect": "skip_action", "value": 1}]},
	# Numbed (Ryan, 2 November, in place of the ten per cent a stack of 10 October): a foe buff, the
	# rounds until one stun lands. A stun on a Numbed foe strips a stack and lands nothing; the foe
	# gains its stun resist in stacks as it recovers from a stun, after the round's decay, and a
	# stack goes at the end of each round (Skirmish._enemy_turn). A Purge strips it like any buff.
	"numbed": {"id": "numbed", "name": "Numbed", "description": "A stun on it strips a stack and lands nothing; a stack goes as each of its turns ends, so the count is the rounds until one stun lands.", "decay": "none",
		"tags": ["buff"], "effects": []},
	# The Baboon's Pocket Paradox as a meter (Ryan, 10 October): a status like any other, and
	# it never decays; at the machine's count the foe is Suppressed and the Paradox clears.
	"paradox": {"id": "paradox", "name": "Paradox", "description": "A paradox building, a stack for every debuff stack it gains: at the count every stack is consumed and it is Suppressed.",
		"effects": []},
	# The funnel-web's acid (Ryan's go, 18 October; Vitriol his word): a share of the foe's
	# current hull a stack as its turn ends, past armour, after Ablating's flat tick, rounded down
	# and never the last hit point, then a stack fades (Ablating's shape, stacking add): it
	# opens on a boss, finishes no foe and so sets off no last act. Its passive lays it a stack
	# per hit on a foe showing no intent on it (lay_status on on_attack, when target_no_intent).
	"vitriol": {"id": "vitriol", "name": "Vitriol", "description": "Loses {value}% of its current HP per stack as its turn ends, past armour, after Ablating, rounded down, then loses a stack. It never finishes a foe.",
		"tags": ["dot"], "effects": [{"trigger": "status", "effect": "tick_hp_share", "value": 10}]},
	# The funnel-web's web (18 October): the mark its Web Bomb leaves, named for the piece since
	# 15 November (Ryan: "the debuff can be renamed \"web bomb.\""; the id is the engine's). The
	# skirmish bursts it as the round ends (Skirmish._burst_webs; at the end of the foe's own
	# action until 16 November): a Suppress on it and on the foe beside it, each for its next
	# turn, each for itself. One web on a foe, however often it is webbed.
	"webbed": {"id": "webbed", "name": "Web Bomb", "description": "As the round ends the web bursts: it and the foe beside it are Suppressed, each losing its next turn.", "stacking": "renew", "decay": "none",
		"tags": ["web"], "effects": []},
	# The machines' buffs (29 September): what buff equipment grants. Names are placeholders
	# for Ryan. Flat since 2 October (the damage scale: a tenth of a blow of 10 to 20 is nothing
	# to read). A damage point a stack since 18 October (Ryan: the count is the bonus, read at a
	# glance), and it halves as its carrier's turn ends, rounded down, whatever granted it
	# (a machine's at END TURN since 16 November, Ryan: "Empowered should decay at the end of
	# turn, clearly, not end of round"; at the round's end until then, where a stack gained in
	# the enemy's turn halved away before its machine could spend it): a
	# source feeding so many stacks a round settles near twice that, where a stack fading a
	# round climbed without limit ("stacking to the moon and fueling massive ramp strategies").
	# No machine keeps it: the Ammit's Tap held every stack for the battle until its rework (12
	# November), and that keep left the engine with it. Its battle-long part is its Essence, below,
	# and what they grant is this, halving like any.
	"overcharged": {"id": "overcharged", "name": "Empowered", "description": "Attacks deal +1 damage a stack. Halves as its turn ends, rounded down.", "decay": "half",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 1}]},
	# Armoured (Braced until 18 October; the engine id stays) is temporary armour (2 October):
	# flat off every blow, the same word and icon as the chassis stat, never a percentage, and
	# a point a stack since 18 October (Ryan: both sides say Armoured, and the count is the
	# armour). It lasts one turn from any source (Ryan, 12 October: a defensive buff that
	# lingered, a stack fading a round, would stack into a wall; armour is the dearest stat
	# there is), every stack going at once at its owner's turn: a machine's at the round's
	# end, a foe's at its next action. A foe's brace grants it too (Ryan, 16 October: a
	# keyword or an effect and the buff it creates share a name), its value its stacks.
	"braced": {"id": "braced", "name": "Armoured", "description": "Armour +1 a stack, every stack at once, until its next turn starts.", "decay": "round",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 1}]},
	# Hardened Light, the Storm Petrel's shield armour (Ryan, 18 November: "no innate shield
	# armour. The Pulse grants one Hardened Light at tier 1. Hardened Light only decays when the
	# shield breaks, and has a cap of 3 stacks"; "The reboot breaks it yes. When it breaks, it loses
	# all of them"): a point off every blow a stack while its shield stands, every stack going when
	# the shield breaks, a reboot's drop among the breaks. The cap is the grant's (Skirmish._self_grants),
	# its machine's branches raising it. Shield armour, never armour: an Expose leaves it ("It's the
	# only tank not weak to Expose"); a Purge takes stacks as any buff's, a bar of its own the move
	# if that proves too threatening (his word of the same day).
	"hardened": {"id": "hardened", "name": "Hardened Light", "description": "While its shield stands, every blow on it loses 1 a stack. Every stack goes when its shield breaks.", "decay": "break",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "add_damage_taken", "value": -1, "when": "shield_up"}]},
	# Primed, the third primer since 15 November (Ryan's mark: "give it the same format as cryo
	# ... use a stack on firing"; "Primed - agreed, how many Ablate stacks does each Primed stack
	# apply? Just one, like supercooled?"; one): the primers below have its rule, and a foe's is
	# the same in its own words (primed_foe). Until then every blow left a stack of Ablating a
	# stack of Primed, for the round on a machine and for one move on a foe.
	"primed": {"id": "primed", "name": "Primed", "description": "Its weapons fire with Ablate 1 while it lasts, a stack a strike, one more on a gun that carries Ablate; a weapon fired spends a stack.", "decay": "none", "spent_by": "weapon",
		"tags": ["buff"], "effects": []},
	# A core whose parts stand takes nothing (the boss in parts, 15 October): the skirmish grants
	# and lifts it as its parts fall and grow back, so every number reads it, the die's too.
	"guarded": {"id": "guarded", "name": "Guarded", "description": "Takes no damage while its parts stand.", "stacking": "renew",
		"tags": ["ability", "guard"], "effects": [{"trigger": "static", "effect": "multiply_damage_taken", "value": 0}]},
	# Shocked (Ryan, 29 October): only a weapon's strike aimed at the foe reads it (aimed_only), so a
	# blow that merely reaches it, an area's, a Chain's arc or a spill, neither doubles nor spends it.
	"shocked": {"id": "shocked", "name": "Shocked", "description": "When a weapon's strike aimed at it lands, the blow deals double and the shock is spent; a blow that only reaches it neither doubles nor spends it.", "stacking": "renew",
		"tags": ["shock"], "effects": [{"trigger": "static", "effect": "multiply_damage_taken", "value": 2, "aimed_only": true}]},
	# Exposed (the Kestrel session, 20 and 21 October; built 21 October), the debuff: the foe
	# stands in Direct reach of every machine as if its column's front were empty, and its
	# armour counts for nothing, its own and any Armoured (Foe.armour_total), through the next
	# round, refreshed and never added. The formation's exposed back rank is reach only, and the
	# id is "exposure" since "exposed" names that formation word and the foes' default aim.
	# Pinned (the Hollow-point Harpoon's, Ryan, 11 November): a status of its own, holding the
	# foe's Brittle from its next halving and spent by it (16 November: "the next time it would
	# decay, it doesn't"; a status for the round until then). HOLDERS names the holder of each
	# status a piece may hold, so a like one for Ablating is a row there and a status here.
	"pinned": {"id": "pinned", "name": "Pinned", "description": "The next time its Brittle would halve, it does not.", "stacking": "renew",
		"tags": ["pin"], "effects": [{"trigger": "static", "effect": "hold_status", "value": "brittled"}]},
	# Ablating's pin, Seared (Ryan, 11 November: "Might as well code it in since the Mastema will
	# want it as a fitted piece, if nothing else"; its name his, 15 November: "Rename 'Seared.'"):
	# its Ablating takes its points and loses no stack this round. No piece lays it yet.
	"seared": {"id": "seared", "name": "Seared", "description": "The next time its Ablating would lose a stack, it does not.", "stacking": "renew",
		"tags": ["pin"], "effects": [{"trigger": "static", "effect": "hold_status", "value": "ablating"}]},
	"exposure": {"id": "exposure", "name": "Exposed", "description": "In Direct reach of every machine, and its armour counts for nothing. Lasts through your next turn.", "stacking": "renew", "decay": "turn_start",
		"tags": ["expose"], "effects": []},
	# Exposed on a machine (Ryan, 15 November, the vocabulary pass's fourth and fifth rounds;
	# built 16 November), from a foe's Expose: the armour half is the foe's rule whole, "all
	# armour of all kinds", its own, any Armoured and what a kit grants by a condition, read as
	# nothing through the stat itself, so armour gained while it stands is gained and does
	# nothing until the mark ends; the shield, and a reduction that is no armour, are untouched.
	# The second half is the skirmish's: as the next round opens every targeted intent turns on
	# the machine until the blows already drawn would wreck it (Skirmish._pick_mech_target). It
	# lands in the enemy's turn and stands through the round after, refreshed and never added;
	# an ally's Cleanse gives the armour back and leaves the intents where they turned.
	"exposure_mech": {"id": "exposure_mech", "name": "Exposed", "description": "Its armour counts for nothing, and as the round opens every foe's targeted move turns on it, up to the blows that would wreck it. Lasts the round after it lands.", "stacking": "renew", "decay": "turn_start",
		"tags": ["expose", "cleansable"], "effects": [{"trigger": "static", "effect": "multiply_stat", "stat": "armour", "value": 0}]},
	# The Mine (the Lammergeier's Reverberant Payload, Ryan, 9 November: "the lammergeier basically
	# converts all hits to AoE hits, at the cost of a delay until Death"): a spend of its weapons and
	# equipment aimed at a foe leaves a Mine on it, flat damage and the spend's keywords, one Mine a
	# foe however many spends fed it ("the single big hit first ... the chip shows the damage instead
	# of the stacks, with the tooltip showing the riders"). Its stacks are its damage; its riders ride
	# in its one effect (Skirmish.mine_riders). When the foe falls, getting back up or splitting
	# included, the Mine blows on every foe round its slot (Skirmish._blow_mine). A mark the team
	# laid, so a Ward turns it away, a foe's cleanse takes it and the Paradox counts it.
	"mine": {"id": "mine", "name": "Mine", "description": "When this foe falls, even if it gets back up or splits, the Mine blows: its damage and its riders on every foe round its slot.",
		"tags": ["mine"], "effects": []},
	# The Needletail's second action spent (the Quick-turn Avionics Relay as Ryan settled it on 11
	# November: two things a round, a weapon and an equipment): its die has turned once this
	# round. A marker, never a chip: the die shows the turn it still has in its passive box.
	"quick_turned": {"id": "quick_turned", "name": "Quick turn spent", "description": "Its second action this round is spent.", "stacking": "renew",
		"tags": ["marker"], "effects": []},
	# The Swallowtail's (Ryan's go, 21 October; built that day). The Muster: a store of points,
	# every die's roll a point and a kill by its own guns more, a charge every so many (the
	# passive's muster rule), spent by its locked pieces' charged forms; never decays, and a
	# store is a resource, so no Purge touches it (Ryan, 21 October).
	# Phased (Ryan's mark, 15 November: "New effect: "Cannot be damaged or targeted by anything
	# until the end of this round." We remove the awkward act clause, but still ensure that it
	# cannot be buffed or interacted with by allies until it unphases"; "all sources of Phased
	# should say "at the end of this round, grant Phased.""): out of reach of both sides for a
	# round, the machine acting all the same. What a source lays is the wait for it (phasing),
	# on a machine that must stand through the foes' turn first ("you have to survive the
	# current round"); the skirmish lands it as that turn ends (_land_phases). Until then it
	# could not act, take damage or be targeted until the round's end, and was granted at once,
	# only to a machine that had not acted.
	"muster": {"id": "muster", "name": "Muster", "description": "A charge its locked pieces spend for their charged forms. Every die that rolls fills it a sliver.", "decay": "none",
		"tags": ["store"], "effects": []},
	"phased": {"id": "phased", "name": "Phased", "description": "Cannot be damaged or targeted by anything until the end of this round.", "stacking": "renew",
		"tags": ["buff"], "effects": []},
	"phasing": {"id": "phasing", "name": "Phasing", "description": "At the end of this round, gains Phased, if it still stands.", "stacking": "renew", "single": true,
		"tags": ["buff"], "effects": []},
	# Swallowed (a foe's swallow, Floraison's, 30 October): out of reach as a Phased machine is,
	# laid by a foe and timed by its move, ended early by its swallower's fall; out of play too,
	# so everything it carries pauses where a Phased machine's ticks (Skirmish.paused, 16 November).
	"swallowed": {"id": "swallowed", "name": "Swallowed", "description": "Out of the fight: it cannot act, take damage or be targeted, and everything it carries waits, until its rounds run out, its swallower falls, or its swallower loses a quarter of its HP.", "stacking": "renew",
		"tags": ["debuff"], "effects": []},
	# The primers (Ryan, 2 November; Primed, above, the third since 15 November): a stack a weapon
	# fired, each lending its rider to that fire as a keyword (effective_face), landing after the
	# blows as the keyword does. A use spends them (`spent_by`), so a grant lasts until its
	# stacks are fired, across rounds, and a buff grants one stacks and no rounds.
	"charged": {"id": "charged", "name": "Charged", "description": "Its weapons fire with Shock while it lasts; a weapon fired spends a stack.", "decay": "none", "spent_by": "weapon",
		"tags": ["buff"], "effects": []},
	"supercooled": {"id": "supercooled", "name": "Supercooled", "description": "Its weapons fire with Cryo 1 while it lasts, a stack a strike, one more on a gun that carries Cryo; a weapon fired spends a stack.", "decay": "none", "spent_by": "weapon",
		"tags": ["buff"], "effects": []},
	# What a foe's defend, buff and debuff actions leave (30 September), besides the Braced of
	# its brace (above): Empowered from a rally; Risen is a charge spent by a death.
	# Empowered carries its rally's own value (13 October) and lands the moment the rally does,
	# on every foe on the field, its rallier too since 15 November (Ryan, 26 October: "howl is
	# more clear if it gives kindled for the next action, which could be the turn its granted"):
	# a foe acting after the rallier hits harder this turn, and one that has acted carries half
	# to the next. It halves as the foes' turn ends, which is the round's end, the machines'
	# clock on the other side (4 November; a machine's at its own turn's end since 16 November):
	# no move spends it and a Suppress takes none of it. The intents read a rally on its way
	# (Skirmish.incoming_rally), so no foe strikes above the number it showed. A point a stack
	# on every strike of its move, on the move's own number (Foe.damage_of; 18 November), one
	# damage formula for the whole game (Ryan, 26 October), as Empowered is on the machines'
	# side. Each grant is its rally's value; the stacks add.
	"kindled": {"id": "kindled", "name": "Empowered", "description": "Its blows hit +1 harder a stack. Halves as its turn ends, rounded down.", "decay": "half",
		"tags": ["buff", "rally"], "effects": [{"trigger": "static", "effect": "add_attack", "value": 1}]},
	# Enraged (3 November, the Goblin Nob's): a stack for every shield, vent or equipment entry
	# the team spends while the foe stands and rages (Foe.rage, its own from the fight's start
	# since 8 November), a point of attack a stack for the rest of the fight, never spent by a
	# move, so the chip climbs as the player plays safe; a Purge lowers the stacks, a buff's, and
	# the rage goes on, the Nob's ability (its chip on a solid tile, never purged: 8 November).
	"enraged": {"id": "enraged", "name": "Enraged", "description": "Its blows hit {value} harder for the rest of the fight: a stack for every shield, vent or equipment entry the team has spent while it stands.", "decay": "none",
		"tags": ["buff", "rally"], "effects": [{"trigger": "static", "effect": "add_attack", "value": 1}]},
	# Golden (4 November, Ryan's read of Rajang: the golden rage "is a mode, not an attack ... a
	# cycle that forces the player into a cycle of attack and defense, broken by a bold player
	# with great timing"): a timed grant, its blows harder and a point of plate for the rounds its
	# move says; a quarter of its HP lost since it went gold, or a Suppress, breaks it and it
	# staggers (Skirmish._break_golden, _stagger). An ability, never a buff (Ryan, 8 November:
	# "Golden rage should be an ability chip too"), so no Purge strips it. Its add is the move's
	# value (golden()); one rage at a time (renew), the next once it is calm.
	"golden": {"id": "golden", "name": "Golden", "description": "Its blows hit {value} harder and it wears a point of armour until its rage ends; a quarter of its HP lost since it went gold, or a Suppress, breaks it, and it staggers.", "stacking": "renew", "decay": "none",
		"tags": ["ability"], "effects": [{"trigger": "static", "effect": "add_attack", "value": 2}, {"trigger": "static", "effect": "add_stat", "stat": "armour", "value": 1}]},
	"risen": {"id": "risen", "name": "Undying", "description": "Returns from the pool once after dying.", "stacking": "renew",
		"tags": ["buff", "revive"], "effects": []},
	# Appropriated (Gilgamesh's; Ryan's mark of 15 November on the steal: "It grants Jammed on the
	# target, and Gilgamesh gains Appropriated with the value"): what a foe took off a machine,
	# the number its borrowed swing lands, a point a stack, and the swing spends it (a move whose
	# `power` names it: Foe.power_status). His Ability, a count on his own chip (Ryan, 16
	# November, of the purgeable buff a session had read from "gains Appropriated": "I think
	# Appropriated is a balance read. Maybe make it his ability, a number that fluctuates
	# depending on what he's currently holding"), so no Purge reaches it.
	# One hold at a time: what it takes next replaces what it held. The steal's own field on the
	# foe until 16 November.
	# Aloft (the Roc's climb; Ryan, 16 November: "the stoop can make it untargetable, yes. I don't
	# think I'd call it phased though, it should still take damage from its riders, unlike phased.
	# So it's different, should be a different buff, could be unique to the Roc for now if nothing
	# else has that shape"): worn while a move that climbs gathers (Foe.climbs). No die may be
	# dropped on it and nothing a spend lands with no aim reaches it (17 November: "the roc
	# doesn't get splashed while aloft"); what it carries still wears at it
	# (Skirmish.out_of_reach). The name is a working one, his to change.
	"aloft": {"id": "aloft", "name": "Aloft", "description": "Out of reach while it climbs: no die can be dropped on it, and nothing aimed elsewhere reaches it. What it carries still wears at it. It comes down as it strikes.", "decay": "none", "stacking": "renew",
		"tags": ["buff"], "effects": []},
	"appropriated": {"id": "appropriated", "name": "Appropriated", "description": "The number of the piece it took off a machine: its borrowed swing lands it, and spends it.", "decay": "none", "stacking": "renew", "counted": true,
		"tags": ["ability"], "effects": []},
	# The Honey Badger's hopper (Ryan, 11 October; its Ore Hopper since 31 October): loads every
	# foe its weapons damage puts in, which the Bullion Fragmenter fires a few a shot. A store on
	# the machine with no effect of its own (the weapon that fires it reads it, and what the loads
	# are worth is granted as Armoured, plate_round); it lasts the skirmish, never decays, and
	# nothing cleanses it.
	"hopper": {"id": "hopper", "name": "Hopper", "description": "Loads in the hopper, for a weapon that fires it.", "decay": "none",
		"tags": ["store"], "effects": []},
	# The Polar Bear's seal (Ryan's go, 20 October; the form-changing tank of his 15 October
	# framework): a shield it spends on itself seals it, a vent or a weapon opens it.
	# One chip while sealed, carrying the armour its Lockdown grants (sealed_status builds it
	# with the passive's numbers), renewing, never stacking (Ryan: the granted armour is tied
	# to the mode). Its own cooling stops and it runs hotter at the end of each turn
	# (Skirmish); an ally's vent still cools it (Ryan, 20 October: allowed).
	# The Clydesdale's batteries (Ryan, 11 November: "One half at a time ... The active half should
	# persist between skirmishes"): its die folds in two, a battery up and one stowed, and this
	# chip says the second is up; with none the first is. Held for the battle (fold_die), never a
	# buff, so nothing purges it; the model holds the form of the same name (the second battery up).
	"changed_over": {"id": "changed_over", "name": "Changed Over", "description": "Its second battery is up and its first stowed: its die rolls the second battery and its fixed pieces.", "decay": "none", "stacking": "renew",
		"tags": ["ability", "form"], "effects": []},
	"sealed": {"id": "sealed", "name": "Sealed", "description": "Sealed: armour up, its own cooling stopped, hotter at the end of each turn. A weapon it fires opens it.", "decay": "none", "stacking": "renew",
		"tags": ["ability", "form"], "effects": []},
	# Cryo (Ryan, 20 October: the Polar Bear's Cryo Flinger, the debuff called Cryo too, marked
	# for reuse as the healthier way to cool an ally): a foe mark that pays in cooling. Any
	# machine's hit on it with a weapon spends every stack and cools the hitter so much a stack,
	# the cool_hitter number here (Skirmish.cryo_cool; a field since the stock pass's engine, 22
	# October). It never fades on its own: the canister sticks.
	"cryoed": {"id": "cryoed", "name": "Cryo", "description": "A hit on it with a weapon spends every stack and cools the hitter {value} a stack.", "decay": "none",
		"tags": ["mark"], "effects": [{"trigger": "status", "effect": "cool_hitter", "value": 2}]},
	# Corrupted (the foes' Corrupt, 25 September): the definition each entry's own status is built
	# from (corrupt_entry, one an entry), and the bite a stack takes from its owner each time the
	# entry is spent, shield first (Skirmish.corrupt_bite; a field since the stock pass's engine,
	# 22 October). Cleansable.
	"corrupted": {"id": "corrupted", "name": "Corrupted", "description": "This component bites its owner {value} a stack when spent.",
		"tags": [CLEANSABLE], "effects": [{"trigger": "status", "effect": "corrupt_bite", "value": 3}]},
	# Sapped (Ryan, 11 November: "Deals 1 less damage per stack with attacks"; "Weaken can apply to
	# both sides"; "Weaken can change till after it's next turn then, instead of round end. Let's
	# use Sapped"): a machine's attacks through its pipeline's add (never below nothing), a foe's
	# blow through its attack's; every stack goes after its owner's next turn (after_turn): a
	# foe's at the end of its next action, a machine's at the end of the player's turn.
	# The Juggernaut Drive's waiting state (the Wild Boar's, Ryan, 11 November: "After gaining
	# Barrier, its next weapon attack gains Breach"; "The next attack breach will need to be
	# represented by a purgeable buff"; 15 November, Breach cut on our side: 'Change to explicit
	# "ignores armour."', the state under the passive's own name): one whoever grants it, lifted by the next weapon the
	# machine spends, equipment leaving it standing; a buff, so a purge takes it.
	"juggernaut": {"id": "juggernaut", "name": "Juggernaut Drive", "description": "Its next weapon attack ignores armour.", "decay": "none", "spent_by": "weapon", "single": true, "stacking": "renew",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "ignore_armour", "value": 1}]},
	"sapped": {"id": "sapped", "name": "Sapped", "description": "Its attacks deal 1 less damage a stack. Every stack goes as its next turn ends.", "decay": "after_turn",
		"tags": ["sap", CLEANSABLE], "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": -1}, {"trigger": "static", "effect": "add_attack", "value": -1}]},
	# Brittle, one state on either body (Ryan, 15 November: "Crushed and flak - agreed, brittle";
	# his mark on the crush: "We could consider making this one symmetrical and folding it into
	# Flak as well, changing the name so it works on both sides"): a point more on every blow its
	# carrier takes a stack, halving at the end of each round, rounded down. Flak on a foe until
	# then (Ryan's go, 19 October; built 21 October: Wainwright & Sutler's on-hit) and Crushed on
	# a machine (4 November, the World Eater's pin: Monster Hunter's Defense Down by archetype,
	# Ryan: "something we don't have"), which stood whole through the next round.
	# On a foe ("brittled"), laid by the Brittle keyword's number: every blow of a weapon the foe takes deals a point more a stack, a
	# strike of 0 included (Ryan, 25 October: "Flak and overcharge exist in part to get past
	# armour"), an add before the multiplies (a Shocked foe takes a strike aimed at it plus Brittle, doubled) and
	# before its armour comes off (the bible's armour row); equipment's blow stays nothing
	# (damage_taken). The stacks halve at the end of each round, rounded down (Empowered's
	# clock: Skirmish.end_round halves a foe's), so a sprayer feeding three a round settles near
	# six and a boss never ramps. The clock is this entry's decay, read where Brittle is laid, by
	# the bot and by the hold (stacks_next_round), so the stock pass's loop can read a stack a
	# round against it (Ryan's question, 22 October).
	"brittled": {"id": "brittled", "name": "Brittle", "description": "Every blow of a weapon it takes deals a point more a stack. Halves as its turn starts, rounded down.", "decay": "half",
		"tags": ["brittle"], "effects": [{"trigger": "static", "effect": "add_damage_taken", "value": 1}]},
	# On a machine ("brittled_mech"), laid by a foe's Brittle rider, its number a blow: the same
	# point a stack on every blow it takes, the shield taking the extra first as it takes any
	# blow, and the same clock, a machine's halving statuses going with its Empowered as the
	# round ends (tick). So it stands whole for the foes still to strike this turn and half for
	# the next: a Brittle 1 is the pack's this turn and gone by the next. An ally's Cleanse
	# lifts it; a Ward turns the rider away as it turns any.
	"brittled_mech": {"id": "brittled_mech", "name": "Brittle", "description": "Every blow it takes deals a point more a stack. Halves as its turn starts, rounded down.", "decay": "half",
		"tags": [CLEANSABLE], "effects": [{"trigger": "static", "effect": "add_damage_taken", "value": 1}]},
	# The Cassowary's Spun Up (Ryan's go, 19 October; built 21 October): the Spin-Up's buff, its
	# number a stack on the next weapon the machine spends, stacking, carried between turns until
	# then (`spent_by`: the skirmish lifts every stack after a weapon's spend, equipment leaving
	# them, since it only adds damage: Ryan, 26 October; a buff grants it with no rounds).
	"spun_up": {"id": "spun_up", "name": "Spun Up", "description": "The next weapon it spends deals {value} more a stack and takes every stack; equipment leaves them standing. Carried between turns until then.", "decay": "none", "spent_by": "weapon",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 2}]},
	# Ricochet (the Skua's, Ryan, 12 November: "After firing a weapon, it hits the primary target 1
	# more time per stack, dealing 1 damage each time and applying all effects other than area
	# keywords"; 11 November: "Lose half stacks of Ricochet on any hull damage"): a buff that lasts
	# the fight (`lasts`: a buff component grants it stacks and no rounds), read by the hit
	# (Skirmish._hit) and halved, rounded down, whenever its machine's hull is damaged
	# (`halves_on`, Skirmish._hull_damaged).
	"ricochet": {"id": "ricochet", "name": "Ricochet", "description": "After a weapon fires, it hits its target again for 1, once a stack, with every effect but its area. Hull damage halves the stacks, rounded down.", "decay": "none", "lasts": "fight", "halves_on": "hull_damage",
		"tags": ["buff"], "effects": []},
	# A count a rule reads (the Cassowary's sixth shot, 21 October): every weapon and equipment the
	# machine aims at a foe this fight, a stack each, kept only where a live effect counts them (nth_shot). A
	# store with no effect of its own; the screen draws it as pips under the heat bar.
	"shots": {"id": "shots", "name": "Shots", "description": "Every weapon and equipment it aims at a foe this fight, counted for a rule that lands on a number of them.", "decay": "none",
		"tags": ["store", "count"], "effects": []},
	# The block as a buff (Ryan, 14 October, the honest shield's upside; built 21 October), one
	# machine at a time. A Barrier is Shocked's mirror on the machines' side: the next blow a
	# foe lands on it deals nothing, so a rider that reads the hull (Destroy) finds none, its riders landing, and a blow of
	# nothing leaves it standing (Skirmish._damage_mech spends it). A Ward turns away every rider
	# a foe's blows lay on it that round; the
	# damage lands. Neither stacks, and both go as their carrier's next turn starts (16 November,
	# his four places; a machine's at the round's end and a foe's at END TURN until then, neither
	# a blow apart). A foe's (28 October), from its own specials, reads in
	# its own words (foe_barrier, foe_ward): its Barrier pops on a weapon's blow alone, and its
	# Ward turns the team's marks (TEAM_MARKS, turns_mark), Suppressed excepted.
	"barrier": {"id": "barrier", "name": "Barrier", "description": "The next blow a foe lands on it deals no damage; its riders land. Until its next turn starts.", "stacking": "renew", "single": true, "decay": "round",
		"tags": ["buff"], "effects": []},
	# Regenerating (28 October; one clock on both sides since 15 November, Ryan's mark: "These
	# are structured as 'Regen 1 per stack' and I'd give all sources either a fixed duration, say
	# 2 or 3 turns, or have it decay one stack at a time"; "Regenerating - agreed"): a point a
	# stack as its unit's turn comes round, then a stack fades, Ablating's clock turned round, so
	# Regenerating 3 gives 3, 2 and 1 and grants add their stacks. A foe's is hit points as its
	# turn ends, after its Ablating and Vitriol have ticked, so an Ablate is a race and never a
	# wall (regrowth() below; the Marsh's by lean). A machine's is shield as its turn ends, after
	# its Ablating the same (regenerating_mech; built 30 October for the Storm Petrel's lock, which
	# no longer grants it, and kept on Ryan's word of 17 November with no piece granting it yet:
	# "put machine regeneration back, that will literally be added in this session probably").
	# Until 15 November a foe's was its value at each of three actions. A buff a Purge lowers, on
	# either side.
	"regenerating": {"id": "regenerating", "name": "Regenerating", "description": "Regrows {value} HP a stack as its turn ends, after its Ablating and Vitriol, then loses a stack.",
		"tags": ["buff"], "effects": [{"trigger": "status", "effect": "regrow", "value": 1}]},
	"ward": {"id": "ward", "name": "Ward", "description": "No rider a foe lays lands on it this round, from a blow or a move of its own (ablate, scorch, jam, corrupt, purge); a blow's damage lands. Until its next turn starts.", "stacking": "renew", "decay": "round",
		"tags": ["buff"], "effects": []},
	# The Ammit's Essence (Ryan, 12 November, its rework: "Kills grant one Soul"; "Souls granted by
	# any kill"; "The souls last the battle"; "I wasn't going to cap it, as part of the fantasy"):
	# a count its passive banks, one for every foe that falls in its fight, kept from fight to
	# fight through the battle (its `scope`) with no cap. Uncapped, it is no store (a store is a
	# capped resource with a bar): it is the machine's Ability, a chip with its count (`counted`:
	# the chip says it at one too), so no Purge or Cleanse touches it.
	# Its flares read it (stack_status's `per_stack` and `stack_step`) and its Quintessence Tap spends it
	# (Face.spends).
	# Essence is its name since 15 November (Ryan: "Rename souls to Essence"; Souls until then).
	"essence": {"id": "essence", "name": "Essence", "description": "1 for every foe that has fallen in its fights this battle. Its flares grant Empowered by the Essence it holds, and its Quintessence Tap consumes it.", "decay": "none", "scope": "battle", "counted": true,
		"tags": ["ability"], "effects": []},
	# The Quintessence Tap's hold (Ryan, 12 November: "No Empowered decays this round. And I mean
	# none, not ally or enemy"), a buff on the machine that spent it since 15 November ("This is
	# not pinned empowered, this is an Ammit specific buff. I would give it to the Ammit only, even
	# though it affects the whole battlefield"; "the no-decay state which is represented as a buff
	# on the Ammit called Essence Flare"): while a live machine carries it as the round's statuses
	# run down, no unit's Empowered halves, either side's, what stood and what came later in the
	# round alike (Skirmish.field_holds). A buff like any: a Purge takes it, and the hold with it.
	# Pinned Empowered, a chip on every unit holding Empowered and a rule of the round's, was its
	# form from 12 to 15 November.
	"essence_flare": {"id": "essence_flare", "name": "Essence Flare", "description": "No Empowered decays this round, its own or any other unit's, on either side.", "stacking": "renew", "single": true,
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "hold_all", "value": "overcharged"}]},
	# The line frame's offhand (Ryan, 19 November: "Only its offhand swaps"; "It cycles after a
	# spend"; "remove the manual weapon cycle"): the form its offhand holds, the machine's own Ability.
	# The fight opens on its passive's first form and every spend of a weapon or equipment at a foe
	# turns it to the next (Skirmish._turn_offhand). A form is content's, an `offhand` effect on the
	# passive with its name, its line and its riders, so the chip a fight shows is built from it
	# (hold_form): this entry is the shape every form's chip takes, its name and line the form's own.
	"offhand": {"id": "offhand", "name": "Offhand", "description": "The form its offhand holds: a rider on every weapon and equipment it aims at a foe, turning to the next form after each.", "decay": "none", "stacking": "renew",
		"tags": ["ability", "form"], "effects": []},
	# The Aile Booster's buffs (Ryan, 19 November: "Rapid. Next weapon strike gains Indirect reach";
	# "Next weapon strike -> Next weapon fired. Applies to the whole spend"; "Booster's buff is the
	# booster's name, as per the other one-off buffs caused by locked pieces. 'Aile Boost,' 'Aile
	# Blitz,' 'Aile Assault.'"): the piece's and its two branches' (the Blitzer's and the
	# Assaulter's, each granted in the Boost's place: buff_status), each waiting on the next weapon
	# its machine fires and lifted by it, equipment leaving it standing (Juggernaut Drive's shape).
	# That weapon reaches as Indirect for every strike of its spend; the Blitz's blows ignore armour
	# too. The Assaulter's Empowered is its piece's own grant beside the buff (self_status).
	"aile_boost": {"id": "aile_boost", "name": "Aile Boost", "description": "The next weapon it fires reaches as Indirect, every strike of the spend, and lifts it; equipment leaves it standing.", "decay": "none", "spent_by": "weapon", "single": true, "stacking": "renew",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "set_reach", "value": "indirect", "when": "weapon"}]},
	"aile_blitz": {"id": "aile_blitz", "name": "Aile Blitz", "description": "The next weapon it fires reaches as Indirect and ignores armour, every strike of the spend, and lifts it; equipment leaves it standing.", "decay": "none", "spent_by": "weapon", "single": true, "stacking": "renew",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "set_reach", "value": "indirect", "when": "weapon"}, {"trigger": "static", "effect": "ignore_armour", "value": 1}]},
	"aile_assault": {"id": "aile_assault", "name": "Aile Assault", "description": "The next weapon it fires reaches as Indirect, every strike of the spend, and lifts it; equipment leaves it standing.", "decay": "none", "spent_by": "weapon", "single": true, "stacking": "renew",
		"tags": ["buff"], "effects": [{"trigger": "static", "effect": "set_reach", "value": "indirect", "when": "weapon"}]},
	# The Beam Buckler's Parry (Ryan, 19 November: "The first weapon fired next turn gains bonus
	# damage equal to half of all damage blocked by this machine this round (rounded down)"; what is
	# blocked, his answer the same day: what a Barrier and armour keep off a blow, never what its
	# shield soaks). Two states under one name. Parry, through the round it is gained: the skirmish
	# counts what a Barrier and its armour keep off each foe's blow on it (MechState.parried), and it
	# goes as its machine's next turn starts. Then half of that count, rounded down, stands as
	# parry_strike, a point a stack on its next strike (19 November: "Can we change it to 'next
	# strike' instead?"), the first blow of the first weapon it fires that turn by the strike order,
	# on its target, in Empowered's place in the blow; that weapon lifts it, and it goes as the turn
	# ends if none fires.
	"parry": {"id": "parry", "name": "Parry", "description": "What a Barrier and its armour keep off foes' blows this round is counted; next turn, its next strike deals half of it more, rounded down.", "decay": "round", "single": true, "stacking": "renew",
		"tags": ["buff"], "effects": []},
	"parry_strike": {"id": "parry_strike", "name": "Parry", "description": "Its next strike this turn deals {value} more a stack: the first weapon it fires, its first blow, on its target; that weapon lifts it, equipment leaving it standing. Gone as its turn ends.", "decay": "after_turn", "spent_by": "weapon", "counted": true, "stacking": "renew",
		"tags": ["buff"], "effects": [{"trigger": "on_attack", "effect": "add_damage", "value": 1, "when": "first_blow"}]},
}
## The statuses a buff component may grant: the machines' own (Braced is a foe's too, from its
## brace), never one only a foe carries.
const MECH_STATUSES := ["overcharged", "braced", "primed", "barrier", "ward", "spun_up", "phased", "ricochet", "aile_boost", "aile_blitz", "aile_assault"]


## Is this id one of the engine's statuses: an id in STATUS, or a die entry's Corrupted or
## Disabled (corrupted_<n>, disabled_<n>, one an entry)? A status is a chip in the fight
## whatever its scope (Ryan, 16 October: the Ammit is Empowered, "so anything that
## interacts with overcharged needs it displayed"); a passive, a module's rule or a battle
## reward is none.
static func is_status(id: String) -> bool:
	if STATUS.has(id):
		return true
	for head in ["corrupted_", "disabled_"]:
		if id.begins_with(head) and id.substr(head.length()).is_valid_int():
			return true
	return false


## Empowered at a rally's own value: the status above with the move's value in place of the
## default, so the Howl's 5 is 5 and the chip says so.

## Golden at a move's own value (4 November): the status above with the move's add in place of
## the default; the plate stays a point whatever the move says.
static func golden(value: int) -> Dictionary:
	var d: Dictionary = STATUS["golden"].duplicate(true)
	d["effects"][0]["value"] = value
	d["description"] = filled(str(STATUS["golden"]["description"]), d["effects"])
	return d


## What a foe's gold adds to its blows: its live Golden grant's add, 0 while it is calm.
static func golden_value(f) -> int:
	for m in live(f):
		if m.id == "golden":
			for eff in m.effects:
				if str(eff.get("effect", "")) == "add_attack":
					return int(eff.get("value", 0))
	return 0


## What a unit regrows as its turn ends: a point for every stack of Regenerating it carries (the
## status's own number a stack), a foe's HP and a machine's shield, read before the tick that
## fades one.
static func regrowth(u) -> int:
	var n := 0
	for m in live(u):
		if m.id == "regenerating":
			for eff in m.effects:
				if str(eff.get("effect", "")) == "regrow":
					n += int(eff.get("value", 0)) * maxi(0, m.stacks)
	return n


## What Regenerating at so many stacks regrows before it runs out, a point a stack and a stack
## fading a turn: the stacks and every count under them (3 gives 3, 2 and 1).
static func regen_total(stacks: int) -> int:
	var n := maxi(0, stacks)
	return n * (n + 1) / 2


## Primed on a foe, a stoker's (28 October; the primers' format since 15 November), the status
## in the foe's own words: each blow of a move that strikes leaves Ablating 1 on the machine it
## hits, as an Ablate rider would, and that move spends a stack; a move that strikes nobody
## spends none. Stokings add their stacks (Skirmish stacks it, as any count).
static func primed_foe() -> Dictionary:
	var d: Dictionary = STATUS["primed"].duplicate(true)
	d["description"] = "Each blow of its next move that strikes leaves Ablating 1 on the machine it hits; that move spends a stack."
	return d


## A Barrier and a Ward on a foe (28 October): the machines' statuses in the foe's own words,
## since its Barrier pops on a weapon's blow alone and its Ward turns the team's marks,
## Suppressed excepted. Each lasts until its next turn starts, as a machine's does (16 November).
static func foe_barrier() -> Dictionary:
	var d: Dictionary = STATUS["barrier"].duplicate(true)
	d["description"] = "The next blow of a weapon it takes deals no damage; the blow's riders land, and equipment pops nothing. Until it pops or its next turn starts."
	return d


static func foe_ward() -> Dictionary:
	var d: Dictionary = STATUS["ward"].duplicate(true)
	d["description"] = "No mark the team lays lands on it but Suppressed: no Ablating, Brittle, Cryo, Vitriol, Shock, Expose, Web Bomb, Paradox or drone. Damage lands. Until its next turn starts."
	return d


## Does a Ward turn this mark away (28 October)? A foe under a Ward takes none of the team's
## marks (TEAM_MARKS), Suppressed excepted, since Numbed stays the one stun resistance; a mark
## id only ever lands on a foe, so a machine's Ward is never asked.
static func turns_mark(u, id: String) -> bool:
	return TEAM_MARKS.has(id) and has(u, "ward")


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
## what the team put on it. Never Numbed (a buff only a Purge lowers, 2 November), and never the foe's
## own buffs (Braced, Empowered, Undying).
const FOE_STATUSES := ["ablating", "suppressed", "shocked", "paradox", "vitriol", "webbed", "cryoed", "brittled", "exposure", "mine", "pinned", "seared", "sapped"]
## The status that holds each status a piece may hold on its target (Face.holds).
const HOLDERS := {"brittled": "pinned", "ablating": "seared"}
## The buff a machine gains when it spends an entry that holds a status on every unit this round
## (Face.holds_all: the Quintessence Tap's hold on Empowered is Essence Flare), by the status the
## entry names. The buff's own effect is the hold (hold_all), so the rule lives on the buff.
const ROUND_HOLDERS := {"overcharged": "essence_flare"}
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
## target_unhurt and target_half (the Kite's opener and its lock's finish, 11 November): the foe
## the blow is aimed at stands at its full HP, or at half its HP or less. Read as the hit judges
## the foe, as the die is spent, never between its strikes (the spend hands the HP it judged in
## `ctx`; a forecast reads the foe's own).
## shield_up (the Storm Petrel's plate, built 30 October): the machine's own shield stands, read
## on the shield as it is before the blow (damage_taken's `shield` when a forecast walks its blows).
## sealed (the Polar Bear's Lockdown, 9 November): the machine wears its seal (is_sealed), so a
## grant holds only in the sealed form; with an `entry` beside it (any effect may carry one: a
## component id) it holds on that piece's entries alone.
## weapon (the line frame's Aile Booster, Ryan, 19 November: "Next weapon fired gains Indirect
## reach"): the entry is a weapon, so a status that waits on the next weapon fired reaches none of
## the machine's equipment while it stands.
## first_blow (the Parry's return, Ryan, 19 November: "Can we change it to 'next strike'
## instead?"): the blow is its spend's first by the strike order, its first strike's on its target
## (the skirmish says so in `ctx`), so an add on the next strike lands on that blow alone and on
## none of its area's; a forecast of the entry's number reads it as no first blow.
const SUPPORTED_WHEN := ["reach_direct", "reach_indirect", "target_status", "ally_present", "target_no_intent", "attacker_status", "nth_shot", "target_rank", "target_unhurt", "target_half", "shield_up", "sealed", "weapon", "first_blow"]
## Stats a static effect may change: the mech's base numbers by these names.
const STATS := ["hull", "shield", "heat", "armour", "move", "cooling", "shield_regen"]
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


## A description's {value} filled from the number its first effect carries (the stock pass,
## 22 October: a status's numbers are fields the loops move, so its text reads them, never a
## copy). A text without the mark is returned as it stands.
static func filled(text: String, effects) -> String:
	if not text.contains("{value}") or not (effects is Array):
		return text
	for eff in effects:
		if eff is Dictionary and (eff.get("value") is int or eff.get("value") is float):
			return text.replace("{value}", str(int(eff["value"])))
	return text


## A modifier from a content passive. A draft ("status": "planned") or an empty passive
## grants nothing.
static func make(passive: Dictionary, scope: int, source: String, component: String = "") -> Modifier:
	if passive.is_empty() or str(passive.get("status", "implemented")) != "implemented":
		return null
	var m := Modifier.new()
	m.id = str(passive.get("id", source))
	m.name = str(passive.get("name", ""))
	m.description = filled(str(passive.get("description", "")), passive.get("effects", []))
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
	_record(u, m, m.stacks)
	return m


## What a play lands (Ryan, 26 October: "All incoming chips should appear as pulsing opacity
## versions"): every grant and every stack added to a unit or foe that carries a recorder, noted
## in it as [the unit or foe, the modifier, the stacks]. Skirmish.preview_round gives one to its
## copy's machines and foes, so only the copy's play is noted and the recorder goes with the copy.
static func _record(u, m: Modifier, n: int) -> void:
	if n > 0 and u.recorder != null:
		u.recorder.append([u, m, n])


## A timed effect: gone after the end of `round`.
static func grant_for_rounds(u, passive: Dictionary, source: String, round: int) -> Modifier:
	if turns_mark(u, str(passive.get("id", ""))):
		return null   # a foe's Ward turns the team's mark away (28 October)
	var held := _held(u, passive, ROUNDS, 1, round)
	if held != null:
		return held
	var m := make(passive, ROUNDS, source)
	if m != null:
		m.expires_round = round
		if status_decay(passive) == DECAY_START:
			m.decay = DECAY_START   # it falls as its carrier's turn starts, the first after `round` (turn_opens); the round's end leaves it alone
	return grant(u, m)


## How a second grant of a status lands: "add" or "renew" (the STATUS note above).
static func status_stacking(def: Dictionary) -> String:
	return str(def.get("stacking", "add"))


## Whether a status is one stack whoever grants it (its "single": the STATUS note above).
static func is_single(status_id: String) -> bool:
	return bool(STATUS.get(status_id, {}).get("single", false))


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
		_record(u, m, n - m.stacks)
		m.stacks = maxi(m.stacks, n)
		return m
	return null


## Add stacks of a status. The same id in the same scope stacks up instead of doubling;
## a fresh one is granted with `n` stacks. Tick-decaying statuses lose a stack per tick, a
## halving one half of them. A timed one (ROUNDS) stacks up only with one ending the same
## round (a brace beside a buff of Armoured); a grant ending another round is its own
## modifier, so a later grant never lengthens an earlier one's stacks (16 October). A status
## that renews (its "stacking") is one grant however often it is granted. Whatever granted a
## stack, it is a stack (Ryan, 8 November: "A stack is a stack, doesn't matter where it came
## from").
static func stack(u, passive: Dictionary, scope: int, source: String, n: int = 1, decay: int = DECAY_TICK, expires_round: int = -1) -> Modifier:
	if turns_mark(u, str(passive.get("id", ""))):
		return null   # a foe's Ward turns the team's mark away (28 October)
	if bool(passive.get("single", false)):
		n = mini(n, 1)   # one stack whoever grants it (the STATUS note above)
	var held := _held(u, passive, scope, n, expires_round)
	if held != null:
		return held
	var id := str(passive.get("id", ""))
	for m in u.modifiers:
		if m.source == HOPPER_PLATE:
			continue   # the hopper's grant of Armoured stays its own (_plate), so the loads fired take back only what it gave
		if m.id == id and m.scope == scope and (scope != ROUNDS or m.expires_round == expires_round):
			m.stacks += n
			_record(u, m, n)
			return m
	var m := make(passive, scope, source)
	if m == null:
		return null
	m.stacks = n
	m.decay = decay
	m.expires_round = expires_round
	return grant(u, m)


## Every live stack of a status, across scopes and grants: a buff's Empowered for the round
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


## What a status effect amounts to right now across live statuses: {hp, skip, share}. hp is a
## per stack sum (a foe's hit points; a machine's shield and then its hull, Ablating's on either
## body); skip is any skip_action;
## share is the part of hp that is a share of the owner's current hull (tick_hp_share:
## Vitriol, 18 October), read after the flat ticks (after Ablating), the whole share rounded
## down and never the last hit point, so it opens on a boss and finishes no foe.
## `at_turn_end` asks the statuses that tick at the end of the owner's turn (turn decay, a
## machine's Ablating and Scorched), and only those; otherwise every other. What the ticks take
## goes through what the unit takes, its multiplies alone (Guarded's nothing: Ryan, 8 November, a
## guarded core takes no tick "by definition"), never a weapon's adds (Brittle) nor an aimed strike's
## (Shocked).
static func tick_preview(u, at_turn_end: bool = false) -> Dictionary:
	var out := {"hp": 0, "skip": false, "share": 0}
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
			"skip_action":
				out["skip"] = true
	var taken := ticks_taken(u)
	out["hp"] = int(roundf(int(out["hp"]) * taken))
	if pct > 0:
		var hp_now = u.get("hp")   # a foe's hull; a machine carries no share tick, and has no hp
		var left := (int(hp_now) if hp_now != null else 0) - int(out["hp"])
		if left > 1:
			out["share"] = mini(left - 1, int(roundf(floorf(float(left) * float(pct) / 100.0) * taken)))
			out["hp"] += int(out["share"])
	return out


## What a unit takes of its ticks, a factor: the multiplies on what it takes that any blow reads
## (Guarded's nothing), never an aimed strike's alone (Shocked's double).
static func ticks_taken(u) -> float:
	var mult := 1.0
	for pair in _taking_part(u, "static", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) == "multiply_damage_taken" and not bool(eff.get("aimed_only", false)):
			mult *= pow(float(eff.get("value", 1)), int(pair[1].stacks))
	return mult


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


## The decay a status names in its definition ("none", "round", "turn", "turn_all", "half",
## "after_turn", "turn_start"), a stack a tick when it names none.
static func status_decay(def: Dictionary) -> int:
	return {"none": DECAY_NONE, "round": DECAY_ROUND, "turn": DECAY_TURN, "turn_all": DECAY_TURN_ALL, "half": DECAY_HALF, "after_turn": DECAY_AFTER_TURN, "turn_start": DECAY_START, "break": DECAY_BREAK}.get(str(def.get("decay", "")), DECAY_TICK)


## What a foe's status keeps into the next round on the clock its definition names (the bot's
## look a round on, the hold's line): half, rounded down, on a halving clock; a stack less on a
## stack a turn (a foe's fade as its own turn ends); nothing on a turn-start's; all of it on none.
static func stacks_next_round(def: Dictionary, n: int) -> int:
	match status_decay(def):
		DECAY_HALF:
			return int(n / 2.0)
		DECAY_TICK, DECAY_TURN:
			return maxi(0, n - 1)
		DECAY_ROUND, DECAY_TURN_ALL, DECAY_AFTER_TURN:
			return 0
	return n   # none, and a mark timed to a turn start (Exposed), which stands through the next


## Does the status run down to zero on its own clock (halving each tick), rather than end
## with a timer? Ryan, 18 October: "Things either decrease to zero, or are timed, not both",
## so a buff component granting such a status grants stacks and no rounds (grant_buff). Only
## a status that names its decay counts: one that names none ticks a stack when a passive
## grants it and is timed when a buff component does, as before.
static func decays_to_zero(def: Dictionary) -> bool:
	return str(def.get("decay", "")) == "half"


## The four places a status decays, ticks or falls off (Ryan, 16 November: "I see four places
## things should decay, tick, or fall off"): its carrier's turn start, its turn end, the round's
## end, and when it is spent. A machine's turn is the player's: it starts as the round opens and
## ends at END TURN. A foe's turn starts as the foes' turn opens, since what one foe lays on
## another must outlast that other's own action that round (a guard on every foe would fall off
## the foes still to act before the player ever met it), and ends as its own action does.

## A machine's turn ends (END TURN): its turn statuses tick, Ablating's points for the caller to
## take before the overheat, then every stack that fades a turn loses one (Ablating,
## Regenerating, whose regrowth the caller reads first: regrowth), Scorched and Sapped go whole,
## and the empty ones go. `spared`: nothing damages the machine (Phased), so its Ablating takes
## no point, and fades a stack all the same (Ryan, 16 November: "Everything ticks during
## phased. It doesn't take damage but it's a way of waiting out a debuff"). A Swallowed machine
## is never asked: everything on it pauses.
static func turn_tick(u, spared: bool = false) -> Dictionary:
	var out := tick_preview(u, true)
	if spared:
		out["hp"] = 0   # nothing damages it (Phased): its stacks tick and fade all the same
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_TURN_ALL or m.decay == DECAY_AFTER_TURN:
			continue
		if m.decay == DECAY_TURN or m.decay == DECAY_TICK:   # a stack a turn, whichever way it was granted: a status that names no clock fades here on a machine as it does at a foe's turn's end
			m.stacks -= 1
			if m.stacks <= 0:
				continue
		keep.append(m)
	u.modifiers = keep
	return out


## A foe's turn ends, its own action done or lost: apply this tick (the caller subtracts hp,
## and reads the regrowth first), then every stack that fades a turn loses one and the empty
## ones go (Ablating, Vitriol, Regenerating). A pin on one is spent in its place: "the next
## time it would decay, it doesn't" (Ryan, 16 November; Seared holds Ablating's fade, its
## points still taken). `round_end` is a machine's call instead, as the round ends: its
## once-a-round notes go, and nothing else of its is on this clock.
static func tick(u, round_end: bool = false) -> Dictionary:
	var out := tick_preview(u)
	var held: Array = []
	if not round_end:
		for m in u.modifiers.duplicate():   # a pin spent leaves the list as it is read
			if m.decay == DECAY_TICK and not held.has(m.id) and spend_hold(u, m.id):
				held.append(m.id)
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_ROUND and round_end and m.tags.has(ONCE):
			continue   # a once-a-round gate's own note goes with the round
		if m.decay == DECAY_TICK and not round_end and not held.has(m.id):
			m.stacks -= 1
			if m.stacks <= 0:
				continue
		keep.append(m)
	u.modifiers = keep
	return out


## A unit's turn starts (Ryan, 15 November: "The common "end" state between both sides is
## "start of their next turn""; 16 November, his four places): what lasts until then goes, every
## stack at once (Armoured, a Barrier, a Ward); a debuff that halves does, the other side's
## blows having used it (Brittle), unless a pin holds it, which is spent in its place; and a
## mark timed to a turn start falls once the round it names is past (Exposed; `round` the
## round this turn belongs to). A machine's as the round opens, before the foes announce; a
## foe's as the foes' turn opens, before the first of them acts.
static func turn_opens(u, round: int = -1) -> void:
	var held: Array = []
	for m in u.modifiers.duplicate():
		if m.decay == DECAY_HALF and not m.tags.has("buff") and not held.has(m.id) and spend_hold(u, m.id):
			held.append(m.id)
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_ROUND and not m.tags.has(ONCE):
			continue
		if m.decay == DECAY_START and round >= 0 and m.expires_round < round:
			continue
		if m.decay == DECAY_HALF and not m.tags.has("buff") and not held.has(m.id):
			# Rounded down, so it reaches zero on its own (one stack halves to none). Its grants
			# are one modifier, whatever granted each stack (stack), so it halves as one number.
			m.stacks = int(m.stacks / 2.0)
			if m.stacks <= 0:
				continue
		keep.append(m)
	u.modifiers = keep


## A unit's turn ends: the buffs it carries that halve do, rounded down, and the empty ones go
## (Empowered; Ryan, 16 November: "Empowered should decay at the end of turn, clearly, not end
## of round"), each but what the field holds this round (Essence Flare). A machine's at END
## TURN; a foe's as its own action ends, so a rally stands whole on the next blow of a foe that
## had already acted when it landed.
static func halve_buffs(u, held: Array = []) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_HALF and m.tags.has("buff") and not held.has(m.id):
			m.stacks = int(m.stacks / 2.0)
			if m.stacks <= 0:
				continue
		keep.append(m)
	u.modifiers = keep


## A machine's turn ends: every dark entry whose rounds are done lights again, a cooldown's, a
## jam's and Rapid's own switch-off alike (16 November: with Jammed, at its turn's end). The
## die is not read between here and the round's end, so nothing moves in play.
static func entries_relight(u, round: int) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if m.scope == ROUNDS and m.expires_round <= round and m.effects.any(func(eff) -> bool: return str(eff.get("effect", "")) == "disable_entry"):
			continue
		keep.append(m)
	u.modifiers = keep


## The pin on `u` that holds `status_id` from decaying, spent: "the next time it would decay,
## it doesn't" (Ryan, 16 November; the pin's own status for a round until then). True when one
## held it, and that pin is gone. Pinned holds Brittle's halving; Seared holds Ablating's fade.
static func spend_hold(u, status_id: String) -> bool:
	for m in u.modifiers:
		for eff in m.effects:
			if str(eff.get("trigger", "")) == "static" and str(eff.get("effect", "")) == "hold_status" and str(eff.get("value", "")) == status_id:
				u.modifiers.erase(m)
				return true
	return false


## Does a pin on `u` hold `status_id` from its next decay (the chip's lock, the bot's look a
## round on)?
static func holds(u, status_id: String) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "hold_status" and str(pair[0].get("value", "")) == status_id:
			return true
	return false


## The statuses `u` holds from decaying on every unit in its fight right now, either side's (a
## live hold_all: Essence Flare's hold on Empowered), each with every status that reads as it does
## (named_like: a machine's Empowered and a foe's).
static func holds_all(u) -> Array:
	var out: Array = []
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) != "hold_all":
			continue
		for id in named_like(str(pair[0].get("value", ""))):
			if not out.has(id):
				out.append(id)
	return out


## Every status that reads as `status_id` does on its chip, itself first: Empowered is a
## machine's `overcharged` and a foe's `kindled`, one word on both sides (3 November), so a rule
## that says "Empowered" names both (the Quintessence Tap's hold: Ryan, 12 November, "none, not ally or
## enemy").
static func named_like(status_id: String) -> Array:
	var out: Array = [status_id]
	var name := str(STATUS.get(status_id, {}).get("name", ""))
	if name.is_empty():
		return out
	for id in STATUS.keys():
		if id != status_id and str(STATUS[id].get("name", "")) == name:
			out.append(id)
	return out


## The scope a status's own definition names: "battle", kept from fight to fight until the battle
## ends (the Ammit's Essence); the skirmish when it names none.
static func status_scope(def: Dictionary) -> int:
	return BATTLE if str(def.get("scope", "")) == "battle" else SKIRMISH


## Whether a status is a count its chip always says, at one too (the Ammit's Essence), where a
## buff's chip says its stacks from two.
static func is_counted(status_id: String) -> bool:
	return bool(STATUS.get(status_id, {}).get("counted", false))


## The share of a front-rank foe's maximum HP, in percent, a machine's damaging blow drives into
## the foe behind it (the Wild Boar's Juggernaut Drive, Ryan, 11 November: "Damaging an enemy in
## the front rank deals 25% of its maximum HP, rounded up, to the enemy immediately behind"); 0 for
## a machine whose blows drive nothing.
static func shove_share(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "shove_behind":
			n += int(pair[0].get("value", 0))
	return n


## The end of a foe's action (Sapped, 11 November): what lasts until after its next turn goes.
static func foe_turn_end(u) -> void:
	u.modifiers = u.modifiers.filter(func(m) -> bool: return m.decay != DECAY_AFTER_TURN)


static func supports(trigger: String, effect: String) -> bool:
	return SUPPORTED_EFFECTS.has(trigger) and SUPPORTED_EFFECTS[trigger].has(effect)


static func supports_when(when: String) -> bool:
	return when.is_empty() or SUPPORTED_WHEN.has(when) or (when.begins_with("tag_") and when.length() > 4)


# ---------------------------------------------------------------- lifetimes

static func end_round(u, round: int) -> void:
	var keep: Array = []
	for m in u.modifiers:
		if not (m.scope == ROUNDS and m.expires_round <= round and m.decay != DECAY_START):
			keep.append(m)   # a mark timed to a turn start (Exposed) falls there, never here (turn_opens)
	u.modifiers = keep


## The round's end for a unit whose clocks are stopped but one (a Swallowed machine: Ryan, 16
## November, "Swallowed it's out of play so everything should pause"). While the one status
## that runs (`running`: the swallow's own rounds) holds, every other timed thing the unit
## carries moves a round later, a cooldown and a jam among them, so a round sat out is never
## counted against it. When the running status's round has come it goes and nothing moves: the
## unit is back before this round's end is read, which then reads it like any other. True
## while the unit is still paused.
static func pause_round(u, round: int, running: String) -> bool:
	var over := false
	for m in u.modifiers:
		if m.scope == ROUNDS and m.id == running and m.expires_round <= round:
			over = true
	if over:
		u.modifiers = u.modifiers.filter(func(m) -> bool: return not (m.scope == ROUNDS and m.id == running and m.expires_round <= round))
		return has(u, running)
	for m in u.modifiers:
		if m.scope == ROUNDS and m.id != running:
			m.expires_round += 1
	return true


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
## `ctx` carries what a what-if reads in place of the unit's own: the shield a forecast's blow
## meets ("shield"), for shield_up.
static func _holds(u, eff: Dictionary, face: Face, target = null, ctx: Dictionary = {}) -> bool:
	# An effect scoped to one of its machine's pieces (`entry`, a component id: the Polar Bear's
	# Lockdown granting its Cryo Flinger Spread while sealed, Ryan, 9 November) holds on that
	# piece's entries alone, never on a stat or another entry.
	var entry := str(eff.get("entry", ""))
	if not entry.is_empty() and (face == null or face.component != entry):
		return false
	match str(eff.get("when", "")):
		"":
			return true
		"sealed":
			# The machine's form (the Polar Bear's seal): its Sealed chip stands.
			return is_sealed(u)
		"weapon":
			return face != null and face.is_weapon()
		"first_blow":
			return bool(ctx.get("first_blow", false))
		"shield_up":
			# The machine's own shield stands (the Storm Petrel's plate, 30 October): the shield
			# the blow meets, before it lands.
			var own = ctx.get("shield", u.get("shield"))
			return own != null and int(own) > 0
		"reach_direct":
			return face != null and effective_reach(u, face) == Face.Reach.DIRECT
		"reach_indirect":
			return face != null and effective_reach(u, face) == Face.Reach.INDIRECT
		"target_status":
			# Any status the team put on it, or the one named, at least so many stacks (a gate's:
			# the Suppression Battery's on Brittle, the Backdraft Charge's on 2 Ablating; 22 October).
			if target == null or target.get("modifiers") == null:
				return false
			var want := str(eff.get("status", ""))
			if want.is_empty():
				return carries_status(target)
			return stacks_of(target, want) >= maxi(1, int(eff.get("stacks", 1)))
		"target_no_intent":
			return target != null and target.has_method("intent_on") and not target.intent_on(u)
		"target_unhurt":
			# The foe stands at its full HP as its hit judged it (the Kite's opener, 11 November).
			return target != null and target.get("hp_max") != null and int(ctx.get("hp", target.hp)) >= int(target.hp_max)
		"target_half":
			# The foe stands at half its HP or less as its hit judged it.
			return target != null and target.get("hp_max") != null and int(ctx.get("hp", target.hp)) * 2 <= int(target.hp_max)
		"attacker_status":
			return target != null and target.get("modifiers") != null and carries_status(target, str(eff.get("status", "")))
		"ally_present":
			return u.get("allies") != null and int(u.allies) > 0
		"target_rank":
			# The rank the spend is aimed at (the Cottonmouth's drum, 19 October): front or back;
			# nothing without a target in hand, so the keyword it grants waits for the aim. A
			# reach named beside it reads the spend's too (the Ram Frame and the Artillery
			# Rangefinder, mirrors: Direct at the front, Indirect at the back; Ryan, 22 October),
			# on an attack's own effects only, never a static one the reach itself reads.
			if target == null or target.get("rank") == null or int(target.get("rank")) != (1 if str(eff.get("rank", "front")) == "back" else 0):
				return false
			var need := str(eff.get("reach", ""))
			return need.is_empty() or (face != null and effective_reach(u, face) == Face.reach_from_name(need))
		"nth_shot":
			# Every n-th spend at a foe this fight (the Cassowary's sixth shot): this one, when the
			# count so far is one short of a multiple of `every`.
			return face != null and face.is_attack() and (stacks_of(u, "shots") + 1) % maxi(1, int(eff.get("every", 6))) == 0
	var w := str(eff.get("when", ""))
	if w.begins_with("tag_"):
		return face != null and face.tags.has(w.substr(4))
	return false


## Every effect taking part in a query: [effect dictionary, modifier], gated as above.
static func _taking_part(u, trigger: String, face: Face, target = null, ctx: Dictionary = {}) -> Array:
	var out: Array = []
	# An effect that names a `slot` gives way to a later grant in the same slot (an upgrade's step
	# replacing its passive's number or form: the Buzzard's Sustain, Ryan, 18 November, "the death
	# gives 2 shield regen instead of the flat boost"): the latest granted stands alone.
	var slotted := {}
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != trigger or not _fires(trigger):
				continue
			var name := str(eff.get("effect", ""))
			if not _usable(u, m, name) or not _holds(u, eff, face, target, ctx):
				continue
			var slot := str(eff.get("slot", ""))
			if not slot.is_empty():
				if slotted.has(slot):
					var at: int = slotted[slot]
					if (out[at][1] as Modifier).seq < m.seq:
						out[at] = [eff, m]
					continue
				slotted[slot] = out.size()
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


## How many times over an entry spent at a foe hits (split_strikes, on_attack; the Skua's
## Split-cycle Breech from 25 October to 11 November, a module of that name since the 12th; Ryan, 7 November:
## "Doubles the number of hits ... for Weapons and Equipment. Base weapon damage is halved (rounded
## down, minimum 1)"): an entry hits that many times as often, and each hit's base, the number and what the entry prints from its firer, is
## divided by it, rounded down and never below one (Skirmish.split_share); every buff, passive and
## foe's condition counts on each hit after it ("the spirit of buffs and riders is they happen
## after"). A debuff deals nothing to divide and hits as often all the same, its riders landing on
## each hit (Ryan, 25 October: "Debuff should fire twice regardless of damage. That's kind of the
## whole point"). 1 for anything spent on a machine, which hits nothing.
static func split_of(u, face: Face) -> int:
	if face == null or not face.is_attack():
		return 1
	var n := 1
	for pair in _taking_part(u, "on_attack", face):
		if str(pair[0].get("effect", "")) == "split_strikes":
			n = maxi(n, int(pair[0].get("value", 1)))
	return n


## An attack after the roll and the keyword rules: adds, then multiplies, then floors, on
## damage and on heat, with the vent the effects add. `target` is the foe the
## blow is aimed at, for conditions on it (null when only the heat is asked). Returns
## {damage, heat, vent}.
static func attack(u, face: Face, dmg: int, heat: int, target = null, ctx: Dictionary = {}) -> Dictionary:
	var d_add := 0.0
	var d_mult := 1.0
	var d_floor := 0
	var h_add := 0.0
	var h_mult := 1.0
	var p_mult := 1.0   # a multiply on the entry's own number alone, before the adds (the Kite's double: the printed number, buffs once)
	var vent := 0
	# The entry's own finish (the Kite's Pinion Driver, 11 November): its number multiplied against a
	# foe at half its HP or less, on the printed number as a passive's double is, the buffs once
	# after it; the HP the hit judged, as a passive's condition on it is.
	if face != null and face.finishes(target, int(ctx.get("hp", -1))):
		p_mult *= float(face.finisher)
	var parts: Array = _taking_part(u, "on_attack", face, target, ctx)
	for pair in parts:
		var eff: Dictionary = pair[0]
		var v: float = float(eff.get("value", 0))
		var n: int = pair[1].stacks
		# `per_stack` scales an effect by the machine's stacks of a status (no attack effect in
		# content uses it since the Nemesis's Crucible became rage, 12 October); none of the
		# status, no effect. `stack_step` counts it in steps of that many stacks (stack_steps).
		if eff.has("per_stack"):
			n *= stack_steps(u, eff)
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
			"vent_heat":
				vent += int(v) * n
	# The Buzzard's zap, paid for this spend (Skirmish._pay_zap): a flat add beside Empowered's (Ryan,
	# 18 November: "Put the bonus damage where Empowered goes in the damage calculation").
	d_add += float(ctx.get("zap", 0))
	var out_dmg := maxi(d_floor, int(roundf((float(dmg) * p_mult + d_add) * d_mult)))
	var out_heat := maxi(0, int(roundf((heat + h_add) * h_mult)))
	if face != null and face.is_debuff():
		# A debuff deals nothing under any effect (Ryan's die grammar, 20 and 21 October): no
		# flat add (Empowered, Spun Up), no multiply, no floor;
		# its heat runs as a weapon's and its keywords are its whole effect. Read on the entry as
		# spent, so a debuff the Cottonmouth's drum fires is its shot, a gun.
		out_dmg = 0
	return {"damage": out_dmg, "heat": out_heat, "vent": vent}


## An incoming blow before shield and armour see it: adds, then multiplies, never below zero.
## A blow of nothing (a lure, a web, a probe) stays nothing: an add on what a blow deals
## (Brittle's point a stack) never turns no blow into one. A `weapon` blow, a weapon's, takes every
## add whatever it deals, a strike of 0 included (Ryan, 25 October: "Flak and overcharge exist
## in part to get past armour"). An effect marked aimed_only (Shocked's double) is read only on a
## weapon's strike `aimed` at the unit, never on a blow that only reaches it (29 October).
## `shield`, when given, is the shield the blow meets in a forecast's walk, which a plate that
## stands with the shield reads (shield_up); the unit's own otherwise.
static func damage_taken(u, amount: int, source = null, weapon: bool = false, aimed: bool = true, shield: int = -1) -> int:
	if amount <= 0 and not weapon:
		return 0
	var add := 0.0
	var mult := 1.0
	for pair in _taking_part(u, "static", null, source, {"shield": shield} if shield >= 0 else {}):
		var eff: Dictionary = pair[0]
		if bool(eff.get("aimed_only", false)) and not (aimed and weapon):
			continue   # Shocked (29 October): read by a weapon's strike aimed at the unit, nothing else
		var n: int = pair[1].stacks
		match str(eff.get("effect", "")):
			"add_damage_taken":
				add += float(eff.get("value", 0)) * n
			"multiply_damage_taken":
				mult *= pow(float(eff.get("value", 1)), n)
	return maxi(0, int(roundf((amount + add) * mult)))


## A component's reach as it is right now: its own, unless a live set_reach holds. Static
## reach rules are read against the component itself (never against effective reach, which
## would loop), so they may key on the component (rolled, a tag) but not on reach. The first
## live modifier in override order (shortest scope, latest granted) wins.
static func effective_reach(u, face: Face) -> int:
	if face == null:
		return Face.Reach.NONE
	face = rewritten(u, face)
	if face.reach == Face.Reach.EVERY_FOE:
		return face.reach   # Every Foe is a targeting mode of its own (Ryan, 4 November): no passive turns it into Direct or Indirect
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
## `when` honoured). An
## attack keyword lands on attacks only, a support keyword on a shield, vent or buff only, a spend
## keyword on anything; a keyword the component already carries is not granted twice.
static func granted_keywords(u, face: Face, target = null) -> Array[int]:
	var out: Array[int] = []
	if face == null or face.kind == Face.Kind.BLANK:
		return out
	for pair in _taking_part(u, "static", face, target):
		if str(pair[0].get("effect", "")) != "grant_keyword":
			continue
		var kw := Face.keyword_from_name(str(pair[0].get("value", "")))
		if kw <= 0 or face.has(kw) or out.has(kw):
			continue
		var fits := Face.ANY_KEYWORDS.has(kw) or (face.is_attack() != Face.SUPPORT_KEYWORDS.has(kw))
		if fits:
			out.append(kw)
	return out


## The numbers a live passive's grants give a numbered keyword on this component (`number` on a
## grant_keyword: the Cottonmouth's drum, Spread 2 at the front rank and Penetrate 2 at the back;
## Ryan, 28 October), keyword -> number, its `when` honoured as the grant's: the grant's number
## replaces the component's own (Ryan: the drum "forces the weapon into its own shape", so a
## Spread 1 shell leaves it at the drum's 2, never the higher of the two, "as that's gaming the
## build"). A grant with no number gives none (an area keyword it adds then says one, as a
## synthetic entry does), and changes nothing on a keyword the component already carries.
static func granted_numbers(u, face: Face, target = null) -> Dictionary:
	var out := {}
	if face == null or face.kind == Face.Kind.BLANK:
		return out
	for pair in _taking_part(u, "static", face, target):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "grant_keyword" or not eff.has("number") or bool(eff.get("adds", false)):
			continue
		var kw := Face.keyword_from_name(str(eff.get("value", "")))
		if kw <= 0 or not Face.NUMBER_FIELDS.has(kw):
			continue
		out[kw] = maxi(int(out.get(kw, 0)), maxi(0, int(eff["number"])))
	return out


## The numbers a live grant adds to a numbered keyword's own (`adds` beside `number` on a
## grant_keyword: the line frame's Beam Bazooka, Ryan, 19 November, "Each strike gains Spread 2 and
## Penetrate 2"; "Two spreads on the same weapon would combine"), keyword -> what every such grant
## adds, summed: a Spread 1 gun under it is a Spread 3, one with none a Spread 2. A grant that
## replaces (the drum's shape) is granted_numbers'.
static func added_numbers(u, face: Face, target = null) -> Dictionary:
	var out := {}
	if face == null or face.kind == Face.Kind.BLANK:
		return out
	for pair in _taking_part(u, "static", face, target):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "grant_keyword" or not bool(eff.get("adds", false)) or not eff.has("number"):
			continue
		var kw := Face.keyword_from_name(str(eff.get("value", "")))
		if kw <= 0 or not Face.NUMBER_FIELDS.has(kw):
			continue
		var fits := Face.ANY_KEYWORDS.has(kw) or (face.is_attack() != Face.SUPPORT_KEYWORDS.has(kw))
		if fits:
			out[kw] = int(out.get(kw, 0)) + maxi(0, int(eff["number"])) * int(pair[1].stacks)
	return out


## The offhand's forms (the line frame's, Ryan, 19 November): its passive's `offhand` effects, in
## their order, each later grant in a slot standing in the place of the one it replaces (a branch's
## step: the Beam Saber in the Beam Sword's), so the cycle keeps its order whatever is upgraded.
## Each is {name, description, riders}: what its chip says and the effects it carries.
static func offhand_forms(u) -> Array:
	var mods: Array = live(u)
	mods.sort_custom(func(a, b) -> bool: return a.seq < b.seq)   # in grant order: the passive's forms set the cycle, a step's take their slots
	var out: Array = []
	var at := {}
	for m in mods:
		for eff in m.effects:
			if str(eff.get("trigger", "")) != "static" or str(eff.get("effect", "")) != "offhand" or not _usable(u, m, "offhand") or not _holds(u, eff, null):
				continue
			var slot := str(eff.get("slot", ""))
			if not slot.is_empty() and at.has(slot):
				out[int(at[slot])] = eff   # the later grant in the slot, in its place
				continue
			if not slot.is_empty():
				at[slot] = out.size()
			out.append(eff)
	return out


## The machine's offhand takes `form` up (one of offhand_forms): its chip, an Ability under the
## form's name and line, carrying the form's riders as its own effects, which the pipeline reads as
## it reads any status's (side_strike, strike_again, self_status, grant_keyword), until the next
## form takes its place. A fight's: it goes when the fight ends.
static func hold_form(u, form: Dictionary) -> Modifier:
	var def: Dictionary = STATUS["offhand"]
	u.modifiers = u.modifiers.filter(func(m) -> bool: return m.id != "offhand")
	var riders = form.get("riders", [])
	var m := make({"id": "offhand", "name": str(form.get("name", def["name"])), "description": str(form.get("description", def["description"])),
		"tags": def["tags"], "effects": (riders as Array).duplicate(true) if riders is Array else []}, SKIRMISH, "offhand:" + str(form.get("slot", form.get("id", ""))))
	if m == null:
		return null
	m.decay = DECAY_NONE
	return grant(u, m)


## The offhand's form up now: its chip's name, "" for a machine with none.
static func held_form(u) -> String:
	for m in live(u):
		if m.id == "offhand":
			return m.name
	return ""


## The slot of the offhand's form up now (rifle, sword, shield: the place in its cycle a branch's
## form takes over), "" for none: what its model's held armament keys on (MechRig.holds_form).
static func held_slot(u) -> String:
	for m in live(u):
		if m.id == "offhand":
			return m.source.trim_prefix("offhand:")
	return ""


## The offhand's form up now as the player reads it, [its name, its line]; empty for none.
static func held_form_line(u) -> Array:
	for m in live(u):
		if m.id == "offhand":
			return [m.name, m.description]
	return []


## What the rifle adds to every strike of an entry aimed at a foe (side_strike, static: the line
## frame's Beam Rifle, Ryan, 19 November: "Each strike also strikes the foe to the right for 2"):
## the number the foe to the right of its target takes, its own blow beside any area's ("Two spreads
## on the same weapon would combine, but the rifle buff is a different form"), summed over every
## live grant; 0 for none.
static func side_strike(u, face: Face, target = null) -> int:
	if face == null or not face.is_attack():
		return 0
	var n := 0
	for pair in _taking_part(u, "static", face, target):
		if str(pair[0].get("effect", "")) == "side_strike":
			n += maxi(0, int(pair[0].get("value", 0))) * int(pair[1].stacks)
	return n


## What the sword adds after every strike of an entry aimed at a foe (strike_again, static: the line
## frame's Beam Sword, Ryan, 19 November: "After each strike, hit the target again for half of the
## strike's damage (rounded down)"; its Beam Saber's "for full damage"): the share of the strike's
## blow, in percent, its hit again carries, the most any live grant says; 0 for none.
static func strike_again(u, face: Face, target = null) -> int:
	if face == null or not face.is_attack():
		return 0
	var n := 0
	for pair in _taking_part(u, "static", face, target):
		if str(pair[0].get("effect", "")) == "strike_again":
			n = maxi(n, int(pair[0].get("value", 0)))
	return n


## The branch's steps taken on this piece (Ryan, 19 November, of an upgrade shown on the die: "I
## agree on the chevron"): every step a machine has picked with an effect scoped to the piece by
## `entry`, each once however many of its effects name it; a step on the passive alone is on no
## piece. The die and the codex draw a chevron for each beside the entry's place.
static func steps_on(u, face: Face) -> int:
	if face == null or face.component.is_empty() or face.kind == Face.Kind.BLANK:
		return 0   # a destroyed piece takes its tweaks with it, and shows none
	var n := 0
	for m in u.modifiers:
		if m.source != "branch":
			continue
		for eff in m.effects:
			if eff is Dictionary and str(eff.get("entry", "")) == face.component:
				n += 1
				break
	return n


## The piece as its branch's steps make it, for the codex, which shows every piece at its own
## numbers: what the steps turn it into, its name (entry_name) and the status a buff grants in its
## own's place (buff_rewrite), and nothing a passive, a module or a fight adds. The piece itself
## when no step turns it into another.
static func upgraded_face(u, face: Face) -> Face:
	var named := entry_name(u, face)
	var buff_to := buff_rewrite(u, face)
	if named.is_empty() and buff_to.is_empty():
		return face
	var c := face.duplicate_face()
	c.renamed = named
	if not buff_to.is_empty():
		c.buff_status = buff_to
	return c


## The name a live effect gives this piece (`name` on an effect scoped to it by `entry`: the line
## frame's Aile Booster as the Aile Blitzer or the Aile Assaulter, Ryan, 19 November: "I intended
## the gundam to change its equipment names for the booster and the offhand"; "the upgrade
## decisions should be represented on the die somehow"): the latest grant's, "" for its own.
static func entry_name(u, face: Face) -> String:
	if face == null or face.component.is_empty():
		return ""
	var out := ""
	var seq := -1
	for pair in _taking_part(u, "static", face):
		var eff: Dictionary = pair[0]
		if eff.has("name") and str(eff.get("entry", "")) == face.component and (pair[1] as Modifier).seq > seq:
			seq = (pair[1] as Modifier).seq
			out = str(eff["name"])
	return out


## The status a buff entry grants as its machine's live effects make it (buff_status, static, scoped
## to its piece by `entry`: the Aile Booster's branches, the Blitzer's Aile Blitz and the
## Assaulter's Aile Assault in the Aile Boost's place, Ryan, 19 November): the latest grant's, ""
## for the piece's own.
static func buff_rewrite(u, face: Face) -> String:
	if face == null or face.kind != Face.Kind.BUFF:
		return ""
	var out := ""
	var seq := -1
	for pair in _taking_part(u, "static", face):
		if str(pair[0].get("effect", "")) == "buff_status" and (pair[1] as Modifier).seq > seq:
			seq = (pair[1] as Modifier).seq
			out = str(pair[0].get("value", ""))
	return out if STATUS.has(out) else ""


## What a spend of this entry lays on its own machine, as [{status, stacks, per_foe, cap, (plus)},
## ...]: what the piece prints (Face.self_statuses: the Hardlight Pulse's Hardened Light, 18
## November) and what a live effect adds to it (self_status, static, scoped to its piece by
## `entry`, its `when` honoured: the Storm Petrel's branches; on every weapon and equipment it aims
## at a foe when it names no piece: the line frame's offhand, its Beam Shield's Armoured 2). Each
## status once: its stacks the most any grant says, a stack set for every foe the spend reached if
## any says per_foe, beside the flat stacks any `plus` says (the Beam Pavise's "Gain 1 Armoured,
## plus 1 Armoured for every foe struck"), and its cap the highest any names (0 for none), so a
## direction's step takes the piece's own grant further (Ryan, 18 November: "max stacks raised to
## 4"; "grants 1 Hardened Light per target hit instead of a flat 1. Max stacks raised to 5"). An
## attack's, or a buff's where an effect names its piece (the Aile Assaulter's Empowered, 19
## November: "Gain 1 Empowered"); the skirmish lays them once the spend is done (Skirmish._self_grants).
static func self_grants(u, face: Face, target = null) -> Array:
	var out: Array = []
	if face == null or face.kind == Face.Kind.BLANK:
		return out
	var attack := face.is_attack()
	var at := {}
	var grants: Array = []
	if attack:
		for g in face.self_statuses:
			grants.append(g)
	for pair in _taking_part(u, "static", face, target):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "self_status" or (not attack and str(eff.get("entry", "")).is_empty()):
			continue   # a rider on what it aims at foes rides no buff; a buff's own lay names its piece
		grants.append({"status": str(eff.get("status", "")), "stacks": int(eff.get("value", 1)), "per_foe": bool(eff.get("per_foe", false)), "cap": int(eff.get("cap", 0)), "plus": int(eff.get("plus", 0))})
	for g in grants:
		var id := str(g.get("status", ""))
		if not STATUS.has(id):
			continue
		var n := maxi(1, int(g.get("stacks", 1)))
		var each := bool(g.get("per_foe", false))
		var cap := maxi(0, int(g.get("cap", 0)))
		var plus := maxi(0, int(g.get("plus", 0)))
		if at.has(id):
			var have: Dictionary = out[int(at[id])]
			have["stacks"] = maxi(int(have["stacks"]), n)
			have["per_foe"] = bool(have["per_foe"]) or each
			have["cap"] = maxi(int(have["cap"]), cap)
			if plus > int(have.get("plus", 0)):
				have["plus"] = plus
		else:
			at[id] = out.size()
			var grant := {"status": id, "stacks": n, "per_foe": each, "cap": cap}
			if plus > 0:
				grant["plus"] = plus
			out.append(grant)
	return out


## A machine's shield breaks (Skirmish._note_break: a blow, the overheat, a shield cost, the
## reboot's drop): every status held until then goes whole (DECAY_BREAK: Hardened Light). The
## names of what went, for the log.
static func clear_on_break(u) -> Array[String]:
	var gone: Array[String] = []
	var keep: Array = []
	for m in u.modifiers:
		if m.decay == DECAY_BREAK:
			if not gone.has(m.name):
				gone.append(m.name)
			continue
		keep.append(m)
	u.modifiers = keep
	return gone


## The statuses this machine's live passives lay on one foe its blow reaches (lay_status on
## on_attack, its `when` read against that foe: the funnel-web's Ambush, 18 October), as
## [[status id, stacks a hit, damaging], ...]. The skirmish asks once a foe at the spend,
## before any strike's riders land, and lays them on every strike that
## reaches the foe, one the spend fells too (the spend's order), a blow of nothing included,
## unless the effect asks for a weapon's hit (`damaging`, which its passive's text says: the
## Ambush's Vitriol, Ryan, 25 October); the bot asks the same. Nothing for a foe the condition
## rules out.
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
		out.append([id, maxi(1, int(eff.get("stacks", 1))) * int(pair[1].stacks), bool(eff.get("damaging", false))])
	return out


## Does any live passive of this machine read a foe's intent on it (a `when` of
## target_no_intent)? The screen's predator sense shows for such a machine alone. With `face`,
## only a rule that entry's hit sets off: one that asks for a weapon's hit (`damaging`, the
## Ambush's Vitriol) passes a debuff by.
static func reads_intent(u, face: Face = null) -> bool:
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("when", "")) == "target_no_intent" and (face == null or face.is_weapon() or not bool(eff.get("damaging", false))):
				return true
	return false


## The component as it is right now for this machine: its own entry, unless a live passive
## changes its reach or grants it a keyword, in
## which case a copy carrying all of it. What the resolver spends, the bot weighs and the
## screen draws; the die keeps the real one.
static func effective_face(u, face: Face, target = null) -> Face:
	if face == null:
		return null
	var base := rewritten(u, face)
	var r := effective_reach(u, face)
	var granted := granted_keywords(u, base, target)
	var numbers := granted_numbers(u, base, target)
	# A numbered grant on a keyword the entry already carries sets its number (the drum's shape).
	var raised := {}
	for kw in numbers.keys():
		if base.has(kw) and int(numbers[kw]) != base.number_of(kw):
			raised[kw] = numbers[kw]
	var split := split_of(u, base) if base.split <= 1 else 1   # never twice: an entry already split stays as it is
	# The primers (Ryan, 2 November; as keywords since 3 November: "a multi-hit weapon with Shock
	# would apply it after both hits ... Cryo should work the same way, resulting in 2
	# applications"): while the machine carries Charged its weapons fire with Shock, while it
	# carries Supercooled with Cryo and while it carries Primed with Ablate (15 November), one
	# more a strike on each foe hit; the skirmish spends a stack of each a weapon fired
	# (Skirmish._spend_primers). Equipment carries none of them.
	var primed_shock := base.is_weapon() and stacks_of(u, "charged") > 0 and not base.has(Face.Keyword.SHOCK)
	var primed_cryo := base.is_weapon() and stacks_of(u, "supercooled") > 0
	var primed_ablate := base.is_weapon() and stacks_of(u, "primed") > 0
	# A weapon's blows ignoring armour by a state its machine carries (the Wild Boar's Juggernaut
	# Drive, a written rule since 15 November, no keyword): a weapon alone.
	var unarmours := base.is_weapon() and not base.ignores_armour and grants_ignore_armour(u, base, target)
	# Damage past a kill spilling behind by a rule its machine wears (the Overrun Gearing's, a
	# module's; a written rule since 15 November, no keyword): every entry aimed at a foe.
	var spills := base.is_attack() and not base.spills and grants_spill(u, base, target)
	# What its spend lays on its own machine, by an upgrade's branch (self_status: the Storm
	# Petrel's lure, 17 November), the copy's to carry, never the die's.
	var grants := self_grants(u, base, target)
	var regranted := grants != base.self_statuses   # a branch takes the piece's own grant further, or adds one
	var more := power_added(u, base, target)   # a branch's raise of the piece's own number (the Buzzard's Burst)
	var added := added_numbers(u, base, target)   # a grant adding to a numbered keyword's own (the Beam Bazooka's Spread 2 on a Spread gun)
	var buff_to := buff_rewrite(u, base)   # a branch's status in the piece's own's place (the Aile Booster's Blitzer)
	var named := entry_name(u, base)   # the name a branch's step gives the piece (the Aile Blitzer)
	if base == face and r == face.reach and granted.is_empty() and raised.is_empty() and split <= 1 and not primed_shock and not primed_cryo and not primed_ablate and not unarmours and not spills and not regranted and more == 0 and added.is_empty() and buff_to.is_empty() and named.is_empty():
		return face
	var c := base.duplicate_face() if base == face else base
	c.reach = r
	for kw in granted:
		c.add_keyword(kw)
		if numbers.has(kw):
			c.set_number(kw, int(numbers[kw]))   # the grant's own number (the drum's Spread 2)
	for kw in raised.keys():
		c.set_number(kw, int(raised[kw]))
	for kw in added.keys():
		var had := int(numbers.get(kw, base.number_of(kw)))   # its own, or what a replacing grant sets it to; nothing on a keyword it lacks
		c.add_keyword(kw)
		c.set_number(kw, had + int(added[kw]))
	if not buff_to.is_empty():
		c.buff_status = buff_to
	if not named.is_empty():
		c.renamed = named
	if primed_shock:
		c.add_keyword(Face.Keyword.SHOCK)
	if primed_cryo:
		var frosted := c.has(Face.Keyword.CRYO)   # one more a strike on a Cryo gun; Cryo 1 on any other
		c.add_keyword(Face.Keyword.CRYO)
		c.cryo = c.cryo + 1 if frosted else maxi(1, c.cryo)
	if primed_ablate:
		var lit := c.has(Face.Keyword.ABLATE)   # one more a strike on an Ablate gun; Ablate 1 on any other
		c.add_keyword(Face.Keyword.ABLATE)
		c.ablate = c.ablate + 1 if lit else maxi(1, c.ablate)
	if split > 1:
		c.strikes = maxi(1, c.strikes) * split
		c.split = split
	if unarmours:
		c.ignores_armour = true
	if spills:
		c.spills = true
	if regranted:
		c.self_statuses = grants
	if more != 0:
		c.power = maxi(0, c.power + more)
	return c


## What a live effect adds to a weapon's own printed number (add_power, static, scoped to its piece
## by `entry`: the Buzzard's Burst branch, Ryan, 18 November, "better base damage"): its base before
## any buff, so the foes its area reaches take their shape's printed number as ever.
static func power_added(u, face: Face, target = null) -> int:
	if face == null or not face.is_weapon():
		return 0
	var n := 0
	for pair in _taking_part(u, "static", face, target):
		if str(pair[0].get("effect", "")) == "add_power":
			n += int(pair[0].get("value", 0)) * int(pair[1].stacks)
	return n


## Does a live effect make this weapon's blows ignore armour (ignore_armour, static, its `when`
## honoured: the Wild Boar's Juggernaut Drive, waiting on the machine as a state its next weapon
## spends)?
static func grants_ignore_armour(u, face: Face, target = null) -> bool:
	for pair in _taking_part(u, "static", face, target):
		if str(pair[0].get("effect", "")) == "ignore_armour":
			return true
	return false


## Does a live effect make this entry's damage past a kill spill into the foe behind (spillover,
## static, its `when` honoured: the Overrun Gearing's)?
static func grants_spill(u, face: Face, target = null) -> bool:
	for pair in _taking_part(u, "static", face, target):
		if str(pair[0].get("effect", "")) == "spillover":
			return true
	return false


## An entry spent at a foe as a live rewrite fires it (the Cottonmouth's Adaptive Munitions Drum,
## Ryan's go of 19 October): every weapon and debuff leaves as the drum's shot, its number flat, its reach and its heat
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


## The drum's shot from a weapon or a debuff and the rewrite that fires it.
static func _rewrite(face: Face, eff: Dictionary) -> Face:
	var c := face.duplicate_face()
	c.power = maxi(0, int(eff.get("value", c.power)))
	var rr := Face.reach_from_name(str(eff.get("reach", "")))
	if rr > 0:
		c.reach = rr
	c.heat = maxi(0, int(eff.get("heat", c.heat)))
	c.strikes = 1
	var tag := str(eff.get("tag", ""))
	if not tag.is_empty() and not c.tags.has(tag):
		c.tags.append(tag)
	return c


## Does a gated keyword land on this foe (the stock pass's engine, 22 October)? A keyword with
## no gate always does; a gated one (the face's `gates`, keyword name to condition) where the
## condition holds on the foe, read through the effects' conditions with the foe in hand. The
## spend reads it before its own riders, so a gate never opens on what the same spend lays.
static func gate_holds(u, f: Face, kw: int, foe) -> bool:
	if f == null or f.gates.is_empty():
		return true
	var g = f.gates.get(Face.KEYWORD_NAMES.get(kw, ""), null)
	if not (g is Dictionary):
		return true
	return _holds(u, g, f, foe)


## A gate in words, for the hold's line ("on a foe carrying Brittle").
static func gate_text(g) -> String:
	if not (g is Dictionary):
		return ""
	match str(g.get("when", "")):
		"target_status":
			var st := str(g.get("status", ""))
			if st.is_empty():
				return "on a foe carrying a status"
			var nm := str(STATUS.get(st, {}).get("name", st))
			var n := maxi(1, int(g.get("stacks", 1)))
			return ("on a foe carrying %s" % nm) if n == 1 else ("on a foe carrying %d %s or more" % [n, nm])
		"target_rank":
			return "aimed at the %s rank" % str(g.get("rank", "front"))
		"target_no_intent":
			return "on a foe showing no intent on it"
	return str(g.get("when", ""))


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
## machine applies, on a foe, an ally or itself (an ablate, a buff, a devour), never Numbed,
## which is exempt from every interaction but suppress and its own decay (Ryan, 2 October:
## a touchable stun resist is where other games' combat loops broke).
static func extra_stacks(u, status_id: String, heat: int) -> int:
	if status_id == "numbed" or is_single(status_id):
		return 0   # Numbed is exempt from every interaction; a single status has no second stack to gain
	var n := 0
	for pair in _taking_part(u, "on_stack", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "add_stacks":
			continue
		var v: int = int(eff.get("value", 0)) * int(pair[1].stacks)
		var per := int(eff.get("per_heat", 0))
		n += v * int(maxi(0, heat) / per) if per > 0 else v
	return maxi(0, n)


## What a foe's blows gain from its statuses (add_attack, static; a Empowered foe), per stack.
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


## The form a machine seals into (seal_form, static; the Polar Bear's Lockdown, 20 October):
## {"armour": the armour the seal grants, "heat": what it runs hotter at the end of each turn}
## when a live passive carries it, else empty.
static func seal_form(u) -> Dictionary:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "seal_form":
			return {"armour": int(pair[0].get("value", 0)), "heat": int(pair[0].get("heat", 0))}
	return {}


## The Buzzard's zap (shield_zap, static; Ryan, 11 November: "spend X shield and add it to the
## attack", "Automatically paid"; 18 November: "Put the bonus damage where Empowered goes in the
## damage calculation"): what each weapon it fires at a foe pays in shield, `cost`, and adds to its
## every blow, `value`, as {cost, damage}, or {} for an entry that pays none: equipment, and a gun
## that fires the whole shield (the Shield-burner Cannon, which leaves nothing to pay). A later grant
## in the same slot replaces the passive's (its Sustain branch's 3); otherwise the most of each.
static func zap_of(u, face: Face) -> Dictionary:
	if face == null or not face.is_weapon() or face.spends_shield:
		return {}
	var cost := 0
	var damage := 0
	for pair in _taking_part(u, "static", face):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) == "shield_zap":
			cost = maxi(cost, int(eff.get("cost", 0)))
			damage = maxi(damage, int(eff.get("value", 0)) * int(pair[1].stacks))
	return {"cost": cost, "damage": damage} if cost > 0 and damage > 0 else {}


## The Sealed status with the seal's own numbers in it: the chip the machine wears while
## sealed, carrying the armour as its one effect (the stat pipeline reads it like any add).
static func sealed_status(armour: int, heat: int) -> Dictionary:
	var d: Dictionary = STATUS["sealed"].duplicate(true)
	d["description"] = "Sealed: armour +%d, its own cooling stopped, %d hotter at the end of each turn. A weapon it fires opens it." % [armour, heat]
	d["effects"] = [{"trigger": "static", "effect": "add_stat", "stat": "armour", "value": armour}]
	return d


static func is_sealed(u) -> bool:
	for m in u.modifiers:
		if m.id == "sealed" and m.stacks > 0:
			return true
	return false


## Whether no hunter ever picks this machine as its prey (never_hunted, static; the Prairie
## Dog's, bible section 7, the cars).
static func never_hunted(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "never_hunted":
			return true
	return false


## Actions a turn on the battlefield this machine has past the one every machine has
## (extra_action, static; the Dingo's second, bible section 7, the cars): a move and a fight
## opened, twice. Never a second spend in a skirmish: inside a fight it acts once a round, like
## any machine (Ryan, 13 November: "Dingo doesn't act twice"; his line for it, "May move and act
## twice during each turn of the map phase").
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


## A foe's blow its shield took with nothing on its hull (on_shield_hit; the Nemesis's rage, Ryan,
## 11 November: "Taking a hit on shield gives 1 rage, hull damage gives 2", and "hull damage takes
## priority"): a blow that wounds fires on_hull_damage alone.
static func shield_hit(u) -> Dictionary:
	return fire(u, "on_shield_hit")


## A blow of the machine's weapon on a foe that the foe's armour or Barrier took whole (on_blocked;
## the Nemesis's rage, Ryan, 11 November: "getting its attacks completely blocked gives 2 rage",
## per blow: "every foe hit needs sufficient armour, or multiple barriers, to farm rage from every
## hit"): fired once a blow.
static func blow_blocked(u) -> Dictionary:
	return fire(u, "on_blocked")


## An event on a machine (on_skirmish_start as the fight begins, on_shield_gain and
## on_heat_gain as the gauges move, on_hull_damage on a hit): every
## passive on that trigger fires. `amount` is what the event carried (the shield or heat
## gained). Returns {shield, vent, statuses}: shield to gain and heat to shed,
## for the caller to apply where the gauges live, and the names of the statuses granted
## (stack_status: its `stacks`, one by default, for the skirmish or the scope the status names,
## decaying as the status says, never past its `cap` when it names one, a store's), on `onto`
## when it is given (the ally an on_shield_granted passive shields) and on the machine itself
## otherwise. A stack_status may count its grant off another status the machine carries
## (`per_stack`, in steps of `stack_step`: the Ammit's flare, an Empowered for every five Essence,
## nothing under five). How often a trigger fires is the trigger's own and never an effect's
## option: a kill's once an attack that killed, however many fell; a foe killed's once for each
## foe that falls, its caller firing it a foe at a time (a flag that chose between the two stood
## for a day, legal on one trigger only; Ryan, 12 November: "Makes no sense").
## Nothing here can fire itself: a shield gained here grants no more shield, heat shed here
## grants no heat.
static func fire(u, trigger: String, amount: int = 0, onto = null) -> Dictionary:
	var out := {"shield": 0, "vent": 0, "statuses": [] as Array[String]}
	for pair in _taking_part(u, trigger, null):
		var eff: Dictionary = pair[0]
		# An effect that fires once a round (its `once`: "round"; the Skua's stack of Ricochet for
		# damaging a foe, Ryan, 11 November: "once per turn"): a mark on the unit says it has,
		# gone at the round's tick (_once).
		if str(eff.get("once", "")) == "round" and not _once(u, pair[1], eff):
			continue
		var v: int = int(eff.get("value", 0)) * int(pair[1].stacks)
		match str(eff.get("effect", "")):
			"add_shield":
				out["shield"] += v
			"shield_per_heat":
				# Shield for every point of heat gained (the Storm Petrel's Hardlight Generator since 17
				# November, Ryan: "gaining shield when it gains heat is a really solid hook"; "I did mean
				# any source"): the trigger's amount, the points the gauge just climbed.
				out["shield"] += v * maxi(0, amount)
			"refill_shield":
				# The shield back whole (the Kite's kill, Ryan, 11 November: "kills recharge it's
				# shield completely"): what it is short of its maximum, no more.
				out["shield"] += maxi(0, int(u.shield_max) - int(u.shield))
			"vent_heat":
				out["vent"] += v
			"stack_status":
				var id := str(eff.get("value", ""))
				if STATUS.has(id):
					var who = u if onto == null else onto
					var n := maxi(1, int(eff.get("stacks", 1))) * int(pair[1].stacks)
					# Counted off a status the machine itself carries (the Ammit's flare, 12 November):
					# its stacks for every `stack_step` of `per_stack` held, rounded down.
					if eff.has("per_stack"):
						n *= stack_steps(u, eff)
					# A store's cap (the Nemesis's rage, five; Ryan, 22 October): it banks no more.
					if int(eff.get("cap", 0)) > 0:
						n = mini(n, int(eff["cap"]) - banked(who, id))
					if n > 0:
						# A machine's Regenerating is the status in a machine's words, shield (the Buzzard's
						# Sustain, 18 November); a foe's is hit points.
						var def: Dictionary = regenerating_mech() if id == "regenerating" and not (who is Foe) else STATUS[id]
						var decay := status_decay(def)
						var m := stack(who, def, status_scope(def), "passive:" + str(pair[1].id), n, decay)
						if m != null and not (out["statuses"] as Array).has(m.name):
							(out["statuses"] as Array).append(m.name)
	return out


## The steps an effect scaled by a status is worth right now (`per_stack`, with `stack_step` the
## stacks a step takes, one when it says none): how many whole steps of the status the machine
## carries. The Ammit's flare is a stack of Empowered a step of five Essence.
static func stack_steps(u, eff: Dictionary) -> int:
	return int(stacks_of(u, str(eff.get("per_stack", ""))) / maxi(1, int(eff.get("stack_step", 1))))


## What this machine's passives would grant it of `status_id` on `trigger` as it stands, a count
## read and nothing granted: the stacks a flare is worth now (the Ammit's, off its Essence), for the
## die, the bot and the codex: one firing of the trigger.
static func would_stack(u, trigger: String, status_id: String) -> int:
	var total := 0
	for pair in _taking_part(u, trigger, null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) != "stack_status" or str(eff.get("value", "")) != status_id:
			continue
		var n := maxi(1, int(eff.get("stacks", 1))) * int(pair[1].stacks)
		if eff.has("per_stack"):
			n *= stack_steps(u, eff)
		total += maxi(0, n)
	return total


## The counts this machine's passives bank as foes fall in its fight (on_foe_killed's
## stack_status: the Ammit's Essence), by status id: what a debug switch fills and a pose shows.
static func kill_counts(u) -> Array:
	var out: Array = []
	for pair in _taking_part(u, "on_foe_killed", null):
		var id := str(pair[0].get("value", ""))
		if str(pair[0].get("effect", "")) == "stack_status" and STATUS.has(id) and not out.has(id):
			out.append(id)
	return out


## The once-a-round gate of a fired effect: true the first time `eff` of modifier `m` fires on
## `u` this round, and false after, until the round's tick lifts the mark it leaves (a modifier
## tagged ONCE, the round's decay: the engine's own note, never described, shown or stripped).
const ONCE := "once"
static func _once(u, m, eff: Dictionary) -> bool:
	var mark := "once:%s:%s:%d" % [str(m.id), str(eff.get("trigger", "")), (m.effects as Array).find(eff)]
	for held in u.modifiers:
		if held.id == mark:
			return false
	var note := Modifier.new()
	note.id = mark
	note.source = "gate"
	note.scope = SKIRMISH
	note.decay = DECAY_ROUND
	note.tags.append(ONCE)
	grant(u, note)
	return true


## A unit's hull was damaged: every status that halves on it halves, rounded down, and goes at
## none (its `halves_on`: "hull_damage"; Ricochet, Ryan, 11 November: "Lose half stacks of
## Ricochet on any hull damage"), each halving at each blow that takes hull. Returns what it
## touched with what is left ("Ricochet 2", "Ricochet gone"), for the log.
static func halve_on_hull_damage(u) -> Array[String]:
	var told: Array[String] = []
	var left := {}
	var keep: Array = []
	for m in u.modifiers:
		if str(STATUS.get(m.id, {}).get("halves_on", "")) != "hull_damage":
			keep.append(m)
			continue
		m.stacks = int(m.stacks / 2.0)
		left[m.name] = int(left.get(m.name, 0)) + maxi(0, m.stacks)
		if m.stacks > 0:
			keep.append(m)
	u.modifiers = keep
	for name in left.keys():
		told.append("%s %d" % [name, int(left[name])] if int(left[name]) > 0 else "%s gone" % name)
	return told


## Every stack of a status the machine carries: what a cap counts.
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
			if id == "hopper" and str(eff.get("effect", "")) == "fill_hopper" and int(eff.get("cap", 0)) > 0:
				return int(eff["cap"])
	return 0


## The loads each foe its weapons damage puts in this machine's hopper (fill_hopper, static: the
## Honey Badger's Ore Hopper, Ryan, 31 October: "per foe damaged"), 0 when nothing fills it. A
## weapon that fills the hopper itself (the Chainsaw Claw's two) reads its own number instead.
static func hopper_fill(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "fill_hopper":
			n += int(pair[0].get("value", 0)) * int(pair[1].stacks)
	return n


## The armour `loads` in this machine's hopper are worth (hopper_plate, static: `value` for each
## `per` loads held; a point a load, Ryan, 31 October), the loads it holds when none are given;
## 0 when nothing plates it.
static func hopper_plate(u, loads: int = -1) -> int:
	var held := stacks_of(u, "hopper") if loads < 0 else loads
	var n := 0
	for pair in _taking_part(u, "static", null):
		var eff: Dictionary = pair[0]
		if str(eff.get("effect", "")) == "hopper_plate":
			n += int(eff.get("value", 0)) * int(pair[1].stacks) * int(held / maxi(1, int(eff.get("per", 1))))
	return n


## Loads into the hopper, never past its cap, and the hopper's Armoured moved by what the
## change is worth (_plate). Returns how many went in.
static func add_loads(u, n: int) -> int:
	var cap := store_cap(u, "hopper")
	if cap > 0:
		n = mini(n, cap - banked(u, "hopper"))
	if n <= 0:
		return 0
	var worth := hopper_plate(u)
	stack(u, STATUS["hopper"], SKIRMISH, "mech", n, DECAY_NONE)
	_plate(u, hopper_plate(u) - worth)
	return n


## Loads fired out of the hopper, and the hopper's Armoured brought down by what they were
## worth. Returns how many.
static func spend_loads(u, n: int) -> int:
	var worth := hopper_plate(u)
	var spent := spend_stacks(u, "hopper", n)
	_plate(u, hopper_plate(u) - worth)
	return spent


## What the hopper's loads are worth is the game's Armoured, granted by the hopper (Ryan, 10
## November: "The funnel fill is tracked by the resource bar. The buff he gets from it is
## Armoured, not an ability. Its purgeable, but returns at the start of his turn since its
## granted by the funnel bar"; an ability of its own, the Ore Plate, from 8 November until then).
## A buff like any Armoured: a Purge strips it, and it goes whole as its machine's turn starts,
## as every machine's Armoured does. The hopper grants it again as each round opens, to what the loads
## held are worth (plate_round), and between rounds it follows the loads by the change in their
## worth alone (_plate), so a load gained after a Purge brings back only its own point and the
## rest waits for the machine's next turn. The loads are the store's, on the resource bar, and
## no Purge touches them.
const HOPPER_PLATE := "store:hopper"   # the source its grant of Armoured carries


## The stacks of Armoured the hopper's own grant holds now.
static func plated(u) -> int:
	var n := 0
	for m in u.modifiers:
		if m.id == "braced" and m.source == HOPPER_PLATE:
			n += m.stacks
	return n


## The round opens: the hopper grants its Armoured afresh, up to what its loads are worth.
## Returns the stacks it granted.
static func plate_round(u) -> int:
	var short := hopper_plate(u) - plated(u)
	if short > 0:
		_plate(u, short)
	return maxi(0, short)


## The hopper's grant of Armoured moved by `change` stacks: more as a stack of its own, gone as
## the next round opens like any Armoured on a machine; fewer off its own grant alone, as far as that
## still stands (a Purge may have taken it already), never off another source's Armoured.
static func _plate(u, change: int) -> void:
	if change > 0:
		var def: Dictionary = STATUS["braced"]
		# A grant of its own, never merged into another source's Armoured, so loads fired take
		# back only what the hopper gave.
		for m in u.modifiers:
			if m.id == "braced" and m.source == HOPPER_PLATE:
				m.stacks += change
				_record(u, m, change)
				return
		var m := make(def, SKIRMISH, HOPPER_PLATE)
		if m != null:
			m.stacks = change
			m.decay = status_decay(def)
			grant(u, m)
	elif change < 0:
		var left := -change
		for m in u.modifiers:
			if m.id == "braced" and m.source == HOPPER_PLATE and left > 0:
				var take := mini(m.stacks, left)
				m.stacks -= take
				left -= take
		u.modifiers = u.modifiers.filter(func(m) -> bool: return not (m.id == "braced" and m.source == HOPPER_PLATE and m.stacks <= 0))


## Free rerolls of this machine's own die each round, on top of the team's (free_reroll,
## static; the Trim Tabs module's, the Clydesdale's Battery Director's until its batteries).
static func free_rerolls(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "free_reroll":
			n += int(pair[0].get("value", 0)) * pair[1].stacks
	return maxi(0, n)


## A machine's Regenerating: the status in the machine's own words, the one rule on either body:
## a point a stack as its turn ends, after its Ablating, then a stack fades (16 November, his four
## places). Shield where a foe's is hit points, a shield gain like any other, so a broken shield
## takes none. Stacked, never timed: grants add. No piece grants it today (the Storm Petrel's lock
## did until 17 November); kept on Ryan's word for the one to come.
static func regenerating_mech() -> Dictionary:
	var d: Dictionary = STATUS["regenerating"].duplicate(true)
	d["description"] = "Regains {value} shield a stack as its turn ends, after its Ablating, then loses a stack."
	d["decay"] = "turn"
	return d


## The shield a point of heat gained stands up on this machine (shield_per_heat, on_heat_gain; the
## Storm Petrel's Hardlight Generator since 17 November): the bot's and the die's read of the hook.
static func shield_per_heat(u) -> int:
	var n := 0
	for pair in _taking_part(u, "on_heat_gain", null):
		if str(pair[0].get("effect", "")) == "shield_per_heat":
			n += int(pair[0].get("value", 0)) * pair[1].stacks
	return maxi(0, n)


## The most of the team's unspent rerolls this machine banks at the round's end (bank_rerolls,
## static, its value the cap; the Giant Petrel's Maverick's Playbook, Ryan's go of 21 October,
## built 30 October); 0 for a machine that banks none.
static func bank_cap(u) -> int:
	var cap := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "bank_rerolls":
			cap = maxi(cap, int(pair[0].get("value", 0)))
	return cap


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


## Does the pipeline hold an injured component short of destruction (the Honey Badger's)?
static func no_destroy(u, face: Face) -> bool:
	for pair in _taking_part(u, "on_injury", face):
		if str(pair[0].get("effect", "")) == "no_destroy":
			return true
	return false


## How many hardpoints a battery of this machine's folded die holds (fold_die, static; the
## Clydesdale's, Ryan, 11 November): its die is two batteries of that many, one up at a time; 0
## for a die that does not fold.
static func folds_die(u) -> int:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "fold_die":
			return maxi(0, int(pair[0].get("value", 0)))
	return 0


## The entries a folded die rolls among: its fixed pieces, up on either battery, and the battery
## up (the first, or the second while it carries Changed Over); empty for a die that does not fold,
## which rolls among all of them.
static func live_entries(u, die) -> Array:
	var h := folds_die(u)
	if h <= 0 or die == null:
		return []
	var second := has(u, "changed_over")
	var out: Array = []
	var k := 0
	for i in range(die.faces.size()):
		if die.faces[i].fixed:
			out.append(i)
			continue
		if k < 2 * h and (k >= h) == second:
			out.append(i)
		k += 1
	return out


## The entries a folded die's stowed battery holds (the codex dims them); empty for a die that
## does not fold.
static func stowed_entries(u, die) -> Array:
	var live := live_entries(u, die)
	if live.is_empty():
		return []
	var out: Array = []
	for i in range(die.faces.size()):
		if not live.has(i):
			out.append(i)
	return out


## Turn a folded die to its other battery (the Changeover's spend): the second battery up carries
## Changed Over for the battle, the first carries nothing. True when the second is up after.
static func turn_die(u) -> bool:
	if remove(u, "changed_over"):
		return false
	stack(u, STATUS["changed_over"], BATTLE, "changeover", 1, DECAY_NONE)
	return true


## Does this machine's die step instead of rolling (the Cassowary's Indexed Cylinder, Ryan's
## wording of 12 October: "Whenever its die rolls, it moves to the next entry instead, in
## sequence")?
static func steps_die(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "step_die":
			return true
	return false


## Every how many spends at a foe a live rule of this machine lands (the Cassowary's sixth
## shot): the `every` of its first nth_shot effect, 0 when nothing counts. The skirmish keeps
## the count only for a machine that has one, and the screen draws it as that many pips.
static func counts_shots(u) -> int:
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("when", "")) == "nth_shot":
				return maxi(1, int(eff.get("every", 6)))
	return 0


## Whether this machine's next spend at a foe is the one its count lands on.
static func nth_shot_due(u) -> bool:
	var every := counts_shots(u)
	return every > 0 and (stacks_of(u, "shots") + 1) % every == 0


## What the stacks a spend at a foe lays are multiplied by (the sixth shot's double), through
## the on_attack multiply_stacks effects that hold for it: 1 when none does.
static func stack_multiplier(u, face: Face, target = null) -> int:
	var mult := 1
	for pair in _taking_part(u, "on_attack", face, target):
		if str(pair[0].get("effect", "")) == "multiply_stacks":
			mult *= int(pow(maxf(1.0, float(pair[0].get("value", 1))), int(pair[1].stacks)))
	return mult


## Is this modifier one a purge reaches: a buff (a kept Empowered
## too), never a store (Ryan, 21 October: a store is a capped resource, as heat and the
## magazine are, so the rage, the hopper and the Muster stay), a passive, a module's rule or a
## count?
static func purgeable(m) -> bool:
	return m.scope != LOADOUT and m.tags.has("buff")


## Is this status an ability (Ryan, 8 November): a unit's own mechanic, shown as its chip on a
## solid tile, never a buff or a debuff, so nothing that strips buffs or marks reaches it (the
## Polar Bear's seal, a core's guard, a golden rage).
static func is_ability(status_id: String) -> bool:
	return (STATUS.get(status_id, {}).get("tags", []) as Array).has("ability")


## What a status is to its unit, the one table its label reads (Ryan, 9 November: "Buffs and
## debuffs, or positive and negative status, whatever the terminology, need to be clearly labeled
## as such, so that it's clear what gets purged"): "buff" (a Purge takes N stacks of it: purgeable),
## "debuff" (laid by the other side to hinder it: a mark the team lays on a foe, a foe's rider on a
## machine, each component's Disabled and Corrupted), "ability" (the unit's own mechanic, which
## nothing strips), "store" (a capped resource, and a count a rule reads), or "" for one that is
## none of them: a marker no chip shows. The chip and the readout line wear the label; the
## keywords list files the term under it.
static func status_kind(status_id: String) -> String:
	if status_id.begins_with("disabled") or status_id.begins_with("corrupted"):
		return "debuff"
	if not STATUS.has(status_id):
		return ""
	var tags: Array = STATUS[status_id].get("tags", [])
	if tags.has("ability"):
		return "ability"
	if tags.has("buff"):
		return "buff"
	if tags.has("store") or tags.has("count"):
		return "store"
	if tags.has("marker"):
		return ""
	return "debuff"


## A Purge N, on either side (28 October; Ryan, 2 November: "lower everything by N"; 8 November:
## "A stack is a stack, doesn't matter where it came from"): every buff the unit carries loses N
## stacks across its grants, in the order they were granted, gone at none, an unstackable one a
## stack of one. An ability is no buff (the unit's own mechanic, its chip on a solid tile: Ryan, 8
## November, "It's not a Buff, it's not a Debuff, it's labelled as an Ability, so it doesn't get
## purged"), and a store is no buff. Returns what it touched, once each, with what it left
## ("Armoured 1", "Barrier gone").
static func purge(u, n: int = 1) -> Array[String]:
	var touched: Array[String] = []
	var left := {}
	var keep: Array = []
	for m in u.modifiers:
		if not purgeable(m):
			keep.append(m)
			continue
		var take: int = mini(m.stacks, int(left.get(m.id, maxi(1, n))))
		left[m.id] = int(left.get(m.id, maxi(1, n))) - take
		if take <= 0:
			keep.append(m)
			continue
		m.stacks -= take
		if not touched.has(m.id):
			touched.append(m.id)
		if m.stacks > 0:
			keep.append(m)
	u.modifiers = keep
	var out: Array[String] = []
	for id in touched:
		var name := str(STATUS.get(id, {}).get("name", id))
		var stacks := stacks_of(u, id)
		out.append(name + (" gone" if stacks <= 0 else " %d" % stacks))
	return out


## The marks the team lays on foes (28 October), what a foe's cleanse takes off its own: never
## Numbed (the buff nothing removes), never Suppressed (so a stun stays sure), never Guarded or a
## buff.
const TEAM_MARKS := ["ablating", "brittled", "cryoed", "vitriol", "shocked", "exposure", "webbed", "paradox", "mine", "pinned", "seared", "sapped"]


## How many of the team's marks a foe carries, each status one mark.
static func team_marks(u) -> int:
	var n := 0
	for id in TEAM_MARKS:
		if has(u, id):
			n += 1
	return n


## A foe's cleanse: every mark the team laid on it goes. Returns the names that went.
static func clear_marks(u) -> Array[String]:
	var gone: Array[String] = []
	for id in TEAM_MARKS:
		if has(u, id):
			remove(u, id)
			gone.append(str(STATUS[id]["name"]))
	return gone


## The stacks of buffs a purge can reach on a unit: what a foe that aims at the buffed reads,
## and what a purger's condition asks (28 October).
static func buff_stacks(u) -> int:
	var n := 0
	for m in u.modifiers:
		if purgeable(m):
			n += maxi(1, m.stacks)
	return n


## The heat every blow a foe lands on this machine adds (heat_per_blow, static: the Whip
## Scorpion's passive), 0 for none.
static func heat_per_blow(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "heat_per_blow":
			n += int(pair[0].get("value", 0))
	return n


## What a machine's reboot blasts as its heat vents (reboot_release, static; the Whip Scorpion's
## Thermal Ejection Manifold, Ryan, 12 November: "1 damage to each enemy, increased by 1 for each
## heat over 8"; 17 November, on the reboot's vent in place of a passed turn: "the reboot vent is
## the one that explodes"; no gate since the same day, "1 damage to all enemies for every X
## heat"): {value: what every foe takes a step, per: the heat a step, id: the passive's, which
## its model's firing is keyed by (the broadside, MechRig.fire_act)} (Skirmish.release_shot).
## Empty for a machine whose vent blasts nothing.
static func reboot_release(u) -> Dictionary:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "reboot_release":
			return {"value": int(pair[0].get("value", 1)), "per": maxi(1, int(pair[0].get("per", 1))), "id": str(pair[1].id)}
	return {}


## The kinds a piece is on this machine, in the engine's words (Ryan, 26 October: "Face type is
## either Weapon, Shield, Vent, or Equipment"): its own (equipment a buff or a debuff, a blank
## none). One kind a piece today: the hybrid he allowed ("Hybrid cases can exist. Such as the
## steam vents") was the vent that blasted, a weapon too, which left with the Whip Scorpion's
## rework; a passive that makes a piece a second kind adds it here. `_u` is the machine it is on.
static func kinds_of(_u, f: Face) -> Array[String]:
	var out: Array[String] = []
	if f == null:
		return out
	match f.kind:
		Face.Kind.ATTACK:
			out.append("weapon" if f.is_weapon() else "equipment")
		Face.Kind.SHIELD:
			out.append("shield")
		Face.Kind.VENT:
			out.append("vent")
		Face.Kind.BUFF:
			out.append("equipment")
	return out


## A count as the rules say it: "sixth".
static func ordinal(n: int) -> String:
	var words := {1: "first", 2: "second", 3: "third", 4: "fourth", 5: "fifth", 6: "sixth", 7: "seventh", 8: "eighth", 9: "ninth", 10: "tenth"}
	return str(words.get(n, "%dth" % n))


## Switch one die entry off until the end of `until_round`: the entry shows dark, the
## component itself is untouched. Applied to the target's showing entry by a foe's jam
## (through the mech's next turn; the status it leaves reads Jammed, Disabled until 15 November)
## and by a spent entry's own cooldown (`source` "cooldown": the
## rest of the round of the spend and the rounds it prints after it; Rapid's own switch-off, the
## rest of the round alone). A foe's jam can be cleansed; a cooldown cannot (it is the
## piece's price, and a cleanse that lifted a Rapid piece's would start an infinite turn).
static func disable_entry(u, index: int, source: String, until_round: int) -> Modifier:
	var cooldown := source == "cooldown"
	var status := {"id": "disabled_%d" % index, "name": "Cooldown" if cooldown else "Jammed",
		"description": "This component is dark, cooling down." if cooldown else "This component is jammed: it comes up blank.",
		"tags": [] if cooldown else [CLEANSABLE],
		"effects": [{"trigger": "status", "effect": "disable_entry", "value": index}]}
	return grant_for_rounds(u, status, source, until_round)


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


## The heat a weapon's or a debuff's spend would make that a foe's debuff adds (Scorched's extra, a
## cleansable status's add_heat): the part a forge leaves on the heat bar.
static func debuff_heat(u, face: Face) -> int:
	var add := 0
	for pair in _taking_part(u, "on_attack", face):
		var m: Modifier = pair[1]
		if str(pair[0].get("effect", "")) == "add_heat" and m.tags.has(CLEANSABLE):
			add += int(pair[0].get("value", 0)) * m.stacks
	return add


## What a weapon costs a forging machine in ammo (the Musk Ox's, 21 October): 1 for every
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


## The charges the machine's Muster holds right now (a store, which nothing a foe does takes).
static func muster_charges(u) -> int:
	var rule := muster_rule(u)
	if rule.is_empty():
		return 0
	return stacks_of(u, "muster") / maxi(1, int(rule.get("value", 30)))


## Does a kill of its own recharge this machine's shield whole (on_kill refill_shield, the Kite's
## Disabled Weapon Regulators since 11 November)? The bot's read of a kill's worth.
static func refills_on_kill(u) -> bool:
	for pair in _taking_part(u, "on_kill", null):
		if str(pair[0].get("effect", "")) == "refill_shield":
			return true
	return false


## Does the machine act twice a round, once with a weapon and once with equipment (static
## one_of_each, the Needletail's Quick-turn Avionics Relay; Ryan, 11 November: "using two things a
## round is very Kestrel and deserves a chassis")? After its first spend of either kind its die
## turns to a live entry of the other kind and it acts again, once a round (the quick_turned
## marker; Skirmish.turn_entries). The machine's own rule and no keyword.
static func one_of_each(u) -> bool:
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "one_of_each":
			return true
	return false


## The damage of the Mine this machine leaves on a foe with every spend of its weapons and
## equipment aimed at one (static mine_on_spend, the Lammergeier's Reverberant Payload, Ryan, 9
## November: "One mine per spend ... N flat damage (plain, not modified by lammergeier modifiers)"),
## every live source's value added; 0 for a machine that leaves none.
static func mine_damage(u) -> int:
	var n := 0
	for pair in _taking_part(u, "static", null):
		if str(pair[0].get("effect", "")) == "mine_on_spend":
			n += maxi(0, int(pair[0].get("value", 0)))
	return n


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


## Is the entry switched off by something a cleanse clears (a foe's disable), rather than by
## its own cooldown, which keeps a Rapid turn finite and no cleanse touches?
static func cleansable_disable(u, index: int) -> bool:
	for m in live(u):
		if not m.tags.has(CLEANSABLE):
			continue
		for eff in m.effects:
			if str(eff.get("effect", "")) == "disable_entry" and int(eff.get("value", -1)) == index:
				return true
	return false


## Does the status last the fight once granted (its `lasts`: "fight"; Ricochet), so a buff
## component grants it stacks and no rounds, as one a use spends?
static func lasts_the_fight(def: Dictionary) -> bool:
	return str(def.get("lasts", "")) == "fight"


## A buff component's grant (29 September): `stacks` of a machine status through the end of
## `until_round`. A grant ending the same round as one already there stacks onto it; one
## ending another round is its own, and each goes when its own rounds run out (16 October).
## A status that decays to zero on its own (Empowered, halving) takes no rounds: the grant
## carries the status's decay and lasts the skirmish or until it runs out (18 October).
static func grant_buff(u, status_id: String, stacks: int, source: String, until_round: int) -> Modifier:
	if not STATUS.has(status_id):
		return null
	return grant_def(u, STATUS[status_id], stacks, source, until_round)


## The grant itself, by the status's own definition: its clock decides how it is held (the
## three cases below), whichever status it is.
static func grant_def(u, def: Dictionary, stacks: int, source: String, until_round: int) -> Modifier:
	# One that ends as its side's next turn begins (Armoured) is held until then, whoever grants
	# it and whatever round the grant names: its end is the turn's opening, no round's.
	if status_decay(def) == DECAY_ROUND:
		return stack(u, def, SKIRMISH, source, stacks, DECAY_ROUND)
	if status_decay(def) == DECAY_BREAK:
		return stack(u, def, SKIRMISH, source, stacks, DECAY_BREAK)   # held until its machine's shield breaks (Hardened Light)
	if decays_to_zero(def):
		return stack(u, def, SKIRMISH, source, stacks, status_decay(def))
	# One a use spends (Spun Up, spent whole by the next weapon; a primer, a stack a weapon
	# fired) lasts until then, across turns; one that lasts the fight (Ricochet) until the fight
	# ends or its own rule takes it.
	if def.has("spent_by") or lasts_the_fight(def):
		return stack(u, def, SKIRMISH, source, stacks, DECAY_NONE)
	return stack(u, def, ROUNDS, source, stacks, DECAY_NONE, until_round)


## Corrupt one die entry for the skirmish (the corrupt foe keyword, 25 September): every
## time the entry is spent it bites its owner, per stack. The component itself is untouched;
## the same entry corrupted again stacks up. Cleansable.
static func corrupt_entry(u, index: int, source: String, n: int = 1) -> Modifier:
	var def: Dictionary = STATUS["corrupted"]
	var status := {"id": "corrupted_%d" % index, "name": def["name"], "description": filled(str(def["description"]), def["effects"]),
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
		"split_strikes": body = "hits twice, its base weapon damage halved, rounded down, never below one" if vs == "2" else "hits ×%s, its base weapon damage divided by %s, rounded down, never below one" % [vs, vs]
		"one_of_each": body = "acts twice a round, once with a weapon and once with equipment: after its first spend the die turns to an entry of the other kind"
		"mine_on_spend": body = "every weapon and equipment it aims at a foe leaves a Mine of %s on it with the spend's keywords, one Mine a foe however many spends feed it; when the foe falls the Mine blows on every foe round its slot" % vs
		"carry": body = "the machines beside it on the map travel with it when it moves"
		"forge": body = "its weapons spend ammo instead of heating it, 1 for every %d heat, its magazine %s, opening at %d and gaining %d a round" % [int(eff.get("per_heat", 10)), vs, int(eff.get("start", 0)), int(eff.get("per_round", 0))]
		"muster": body = "every die that rolls fills its Muster a point, %s a charge, a kill by its own guns %d more, up to %d charges" % [vs, int(eff.get("kill", 0)), int(eff.get("cap", 3))]
		"fill_hopper": body = "every foe its weapons damage puts %s in its hopper, up to %d" % ["a load" if vs == "1" else vs + " loads", int(eff.get("cap", 0))]
		"hopper_plate":
			var per := int(eff.get("per", 1))
			body = ("each load held grants %s of Armoured as each round opens" if per <= 1 else "every %d loads held grant %%s of Armoured as each round opens" % per) % ("a stack" if vs == "1" else vs + " stacks")
		"add_damage": body = "damage %s" % signed
		"min_damage": body = "damage at least %s" % vs
		"multiply_heat": body = "heat ×%s" % vs
		"add_heat": body = "heat %s" % signed
		"lay_status":
			var n := int(eff.get("stacks", 1))
			body = "lays %s on each foe %s, %s a hit" % [str(STATUS.get(str(v), {}).get("name", str(v))), "a weapon hits" if bool(eff.get("damaging", false)) else "hit", "a stack" if n <= 1 else "%d stacks" % n]
		"vent_heat": body = "sheds %s heat" % vs
		"no_destroy": body = "components are never destroyed"
		"set_reach": body = "reach becomes %s" % vs
		"add_stat": body = "%s +%s" % [str(eff.get("stat", "")), vs]
		"multiply_stat": body = "%s ×%s" % [str(eff.get("stat", "")), vs]
		"add_damage_taken": body = "damage taken %s" % signed
		"multiply_damage_taken": body = "damage taken ×%s" % vs
		"suppress": body = "turns off %s" % vs
		"spillover": body = Face.SPILLS_TEXT
		"grant_keyword":
			var kw := Face.keyword_from_name(str(v))
			body = "gains %s" % (Face.keyword_label(kw) if kw > 0 else str(v))
			if eff.has("number"):
				body += " %d" % int(eff["number"])   # a numbered grant says its number (the drum's Spread 2)
		"self_status":
			var sn := str(STATUS.get(str(eff.get("status", "")), {}).get("name", str(eff.get("status", ""))))
			body = "spent on a foe, lays %s %s on its own machine%s%s" % [sn, vs, " for each foe it reaches" if bool(eff.get("per_foe", false)) else "", (", up to %d" % int(eff["cap"])) if int(eff.get("cap", 0)) > 0 else ""]
		"seal_form": body = "equipment it spends on itself seals it: armour +%s, its own cooling stopped, %s hotter at the end of each turn; a weapon it fires opens it" % [vs, str(eff.get("heat", 0))]
		"stack_status":
			var nm := str(STATUS.get(str(v), {}).get("name", str(v)))
			var k := maxi(1, int(eff.get("stacks", 1)))
			body = ("gains a stack of %s" % nm) if k == 1 else ("gains %s ×%d" % [nm, k])
			if int(eff.get("cap", 0)) > 0:
				body += ", up to %d" % int(eff["cap"])
		"add_attack": body = "attack %s" % signed
		"never_hunted": body = "no hunter ever picks it as its prey"
		"extra_action": body = "may move and act %s during each turn of the map phase" % ("twice" if int(v) == 1 else "%d times" % (int(v) + 1))
		"hull_per_spend": body = "every component it spends costs %s hull" % vs
		"step_die": body = "its die never rolls: each fight opens on a random entry, and every roll steps it to the next in order"
		"fold_die": body = "its die is two batteries of %s, one up at a time with its fixed pieces; the battery up stays up from fight to fight, and a battle opens on the first" % vs
		"rewrite_weapon": body = "every weapon and equipment it aims at a foe fires as one %s %s blow, heat %s, its keywords and rules kept" % [str(eff.get("reach", "direct")), vs, str(eff.get("heat", 0))]
		"reboot_release": body = "a reboot blasts what it vents: %s on every foe for every %d heat" % [vs, maxi(1, int(eff.get("per", 1)))]
		"shove_behind": body = "damaging a foe in the front rank deals %s%% of its maximum HP, rounded up, to the foe behind it" % vs
		"hold_status": body = "its %s does not decay" % str(STATUS.get(str(v), {}).get("name", v))
		"hold_all": body = "no %s decays this round, any unit's" % str(STATUS.get(str(v), {}).get("name", v))
		"ignore_armour": body = "its weapons ignore armour"
		"heat_per_blow": body = "every blow a foe lands on it adds %s heat" % vs
		"multiply_stacks": body = "the stacks it lays ×%s" % vs
		"free_reroll": body = "%s free reroll%s of this die a round" % [vs, "" if int(v) == 1 else "s"]
		"shield_zap": body = "each weapon it fires pays %d shield, when it holds that much, for +%s on its every blow" % [int(eff.get("cost", 0)), vs]
		"add_power": body = "its own number +%s" % vs
		"shield_per_ally_heat": body = "the shield grows by %s for every %d heat it carries" % [vs, int(eff.get("per_heat", 10))]
		"add_shield": body = "+%s shield" % vs
		"shield_per_heat": body = "+%s shield for each point" % vs
		"refill_shield": body = "its shield recharges whole"
		"tick_hp": body = "%s damage per stack each turn" % vs
		"tick_hp_share": body = "loses %s%% of its current HP per stack each turn" % vs
		"skip_action": body = "skips its action"
		"disable_entry": body = "die entry %s switched off" % str(int(v) + 1)
		"corrupt_entry": body = "die entry %s bites its owner when spent" % str(int(v) + 1)
		"corrupt_bite": body = "bites its owner %s a stack when its entry is spent" % vs
		"cool_hitter": body = "a weapon's hit on it cools the hitter %s heat a stack" % vs
		"paradox":
			body = "a foe gains a Paradox stack for every stack of another debuff it gains; at %s or more every stack is consumed and it is Suppressed" % vs
		"add_stacks":
			body = "every stack this machine applies is %s deeper" % vs
			if int(eff.get("per_heat", 0)) > 0:
				body += " for every %s heat it carries" % str(int(eff["per_heat"]))
		_: body = str(eff.get("effect", ""))
	if eff.has("per_stack"):
		var of := str(STATUS.get(str(eff["per_stack"]), {}).get("name", str(eff["per_stack"])))
		var step := maxi(1, int(eff.get("stack_step", 1)))
		body += (" per stack of %s" % of) if step == 1 else (" for every %d %s it holds" % [step, of])
	var lead := ""
	match str(eff.get("trigger", "")):
		"on_injury": lead = "on an injury: "
		"on_hull_damage": lead = "on losing hull: "
		"on_shield_hit": lead = "on a foe's blow its shield takes, none on its hull: "
		"on_blocked": lead = "on each blow of its weapons a foe's armour or Barrier takes whole: "
		"on_barrier": lead = "as it gains a Barrier: "
		"on_skirmish_start": lead = "as the fight begins: "
		"on_shield_gain": lead = "on gaining shield: "
		"on_shield_granted": lead = "an ally this machine shields: "
		"on_heat_gain": lead = "on gaining heat: "
		"on_kill": lead = "after an attack that killed: "
		"on_round_kill": lead = "at the end of a round in which it killed: "
		"on_foe_killed": lead = "for each foe that falls in its fight: "
		"on_damage": lead = "after a spend of its weapons that damaged a foe: "
	match str(eff.get("when", "")):
		"reach_direct": lead += "direct attacks: "
		"reach_indirect": lead += "indirect attacks: "
		"target_status":
			# The status named, where one is (the Polar Bear's Lockdown: foes carrying Cryo), else any.
			var want := str(eff.get("status", ""))
			lead += ("foes carrying %s: " % str(STATUS[want]["name"])) if STATUS.has(want) else "foes carrying a status: "
		"target_no_intent": lead += "foes showing no intent on this machine: "
		"target_unhurt": lead += "unhurt foes: "
		"target_half": lead += "foes at half their HP or less: "
		"attacker_status":
			var st := str(eff.get("status", ""))
			lead += "blows from foes carrying %s: " % (str(STATUS[st]["name"]) if STATUS.has(st) else (st.capitalize() if not st.is_empty() else "a status"))
		"ally_present": lead += "with an ally in the fight: "
		"sealed": lead += "while sealed: "
		"nth_shot": lead += "every %s shot: " % ordinal(int(eff.get("every", 6)))
		"target_rank":
			var by := str(eff.get("reach", ""))
			lead += ("%s blows aimed at the %s rank: " % [by, str(eff.get("rank", "front"))]) if not by.is_empty() else ("aimed at the %s rank: " % str(eff.get("rank", "front")))
	if str(eff.get("when", "")).begins_with("tag_"):
		lead += "pieces tagged %s: " % str(eff["when"]).substr(4)
	if str(eff.get("once", "")) == "round":
		body += ", once a round"
	return lead + body


## The effects that apply to this component right now, as short tags with their source. A
## component's own passive is named first (the codex has its description), on any kind of
## entry. No screen lists them since the die's hold highlights a moved number instead (Ryan,
## 26 October); the tests read which passive reaches which entry through it.
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
					out.append("%s (%s)" % [effect_text(eff), m.name])
			elif trig == "static" and name == "spillover":
				# A rule written out (the Gearing's spill) reads the passive's own line, the
				# star's text: the player learns no keyword for it.
				if face.is_attack() and grants_spill(u, face):
					out.append("%s (%s)" % [written_out(m, eff), m.name])
			elif trig == "on_attack":
				# A condition on the target is shown as a rule (its lead says when), since
				# the row has no target in hand.
				var w := str(eff.get("when", ""))
				var on_target := w in ["target_status", "target_no_intent", "target_rank", "target_unhurt", "target_half"]
				if w == "target_rank" and not str(eff.get("reach", "")).is_empty():
					on_target = effective_reach(u, face) == Face.reach_from_name(str(eff["reach"]))   # the Ram Frame's read: Direct entries only
				if _usable(u, m, name) and (on_target or _holds(u, eff, face)):
					out.append("%s (%s)" % [effect_text(eff), m.name])
	return out


## The rules a live passive writes on this entry (the Gearing's spill): the passive's own line
## each, the text of the star the die draws for it, as the hold prints it.
static func written_rules(u, face: Face) -> Array[String]:
	var out: Array[String] = []
	if face == null or not face.is_attack() or not grants_spill(u, face):
		return out
	for m in live(u):
		for eff in m.effects:
			if str(eff.get("trigger", "")) != "static" or str(eff.get("effect", "")) != "spillover":
				continue
			var line := written_out(m, eff)
			if not out.has(line):
				out.append(line)
	return out


## The line a rule written out reads, the star's text: a module's rule (its `line`, the text's
## own, never the stat lines the module's description leads with), else the granting passive's
## description, else the effect's own words.
static func written_out(m, eff: Dictionary) -> String:
	var line := str(eff.get("line", m.description))
	return line if not line.is_empty() else effect_text(eff)


## Every live modifier as [name, description, source, scope, stacks, id]: the codex lists
## the loadout and battle ones, the hold popup the skirmish and round ones. One row a
## modifier, so a status granted in two rounds is two rows; the chips sum them by id.
static func describe(u) -> Array:
	var out: Array = []
	for m in live(u):
		if m.tags.has(ONCE):
			continue   # a once-a-round gate's mark: the engine's own note
		out.append([m.name, m.description, m.source, m.scope, m.stacks, m.id, m.component])
	return out

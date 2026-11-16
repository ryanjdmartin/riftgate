class_name Foe
extends RefCounted

## One enemy inside a skirmish. A pack on the battlefield unpacks into several of these.
##
## A foe has a base attack number, the player's quick read of how hard it hits, and a list
## of attack actions that scale it: {id, name, factor, strikes, weight, keywords, text}.
## Each round it picks one by weight before the player acts, so the intent shown is exact.
##
## Targeting: machines do not taunt (2 October), and a foe draws its target at random unless it
## or its move carries an `aim` (Ryan, 24 October: random is the baseline balanced on, and an
## aim serves a foe's threat, any foe's); the skirmish makes the pick (`Skirmish._pick_mech_target`), shown before the
## player acts, and the foes never over-commit to a machine already doomed.
## A move may carry a `when`, the condition that lets the foe pick it this round, and a
## special never fires twice running (`last_special`). A blow may carry `swarm`: so much more
## per other foe of its type on the field (`kin`, kept by the skirmish), the ghoul's threat.
## Damage is base attack, plus its Empowered and its swarm, times the action's factor (damage_of);
## strikes are separate blows; keywords are tags on the blow (scorch: stacks of Scorched on the
## machine it hits).

var display_name: String = "foe"
var content_id: String = ""      # id in content/foes.json, for the codex
var hp: int = 30
var hp_max: int = 30
var attack: int = 10             # base attack: the number the player reads as "how hard it hits"
var armour: int = 0              # flat off every blow that lands on it (content; 2 October: the one enemy mitigation besides recovery)
var armour_step: int = 0         # armour more a tier above one, a boss whose kit is armour (content `armour_step`; Ryan, 31 October)
var aim: String = AIM_ANYTHING   # the sense its target pick follows (content; a move may override it)
var prefers_back: bool = false   # ranged types hold the back rank and never step up
var pack_id: int = 0            # which battlefield pack this foe came from
var size: int = 1                # 2 = massive: fills both slots of a column
var elite: bool = false          # leads an elite composition (content `elite`): a mini-boss, resisting a stun as one
var resist: int = -1             # its stun resist (Ryan, 2 November): the Numbed it recovers from a stun with; content's, or by its size (stun_resist)
var actions: Array = []          # implemented attack actions; at least the basic one

# Live state.
var rank: int = -1               # 0 front, 1 back, -1 in reserve
var column: int = -1
var target: RefCounted = null    # Skirmish.MechState, set when intents are telegraphed
var action: Dictionary = {}      # this round's chosen action
var modifiers: Array = []        # statuses on this foe (ablating, suppressed, numbed...): Effects.Modifier list
var recorder = null              # the round preview's copy alone (Skirmish.preview_round): an Array every grant and stack this foe gains is noted in (Effects._record); null in any fight that plays
var recovering: bool = false     # lost its action to a stun this turn: its stun resist lands as Numbed as that turn ends
var die = null                   # foes have no die; the pipeline asks, so the field exists
var stays_down: bool = false     # gone whole (a Bomb's burst): a foe that would get back up does not (Execute retired 10 October)
var last_special: String = ""    # the special it announced last round, so none fires twice running
var kin: int = 0                 # other live foes of its type on the field, for a swarm blow; the skirmish keeps it
var hero: bool = false           # one of the party: a hero (content `hero`, human-sized, a domain's final, dealt from its bench) or its promoted form at the finale (content `promotes`)
var commands: bool = false       # a commander of its boss unit (the faction's boss, a final's hero, one of the finale's line), marked as the unit unpacks: the unit stands while one does
var escorts: bool = false        # the wildlife beside a boss unit's commanders (a final's), marked as the unit unpacks: the unit's strength counts them
var joined: bool = false         # it joined its pack in the fight (a Gel's half, a summon, a part): never one of the pack's own, whatever its type, so a pack never grows by what it called up (30 October)
var boss: bool = false           # a domain's boss (content: a faction's `boss`), whatever its size: big is an attribute of any tier (15 October)
var on_death: Dictionary = {}    # {"summon": foe id, "count": n}: destroyed, it splits, that many of the named foe stepping up in its place at once (the Gel)
var fresh: bool = false          # stepped up mid-round (a split's half): its round is over, so it shows no intent and acts from the next round
var pending: Dictionary = {}     # a countdown move it is gathering (`countdown` on the move): it holds until it lands
var charge: int = 0              # rounds before the pending move lands; at 0 it lands this round
var part_ids: Array = []         # a core's parts (content `parts`): the foes of its pack that stand beside it
var guard: String = ""          # a core takes no damage while "all" its parts stand, or while "any" does
var regrow_parts: int = 0        # rounds after a part falls before it grows back, while the core stands (0: never)
var regrow_due: Array = []       # [part id, round it returns] for each part on its way back
var next_move: String = ""       # the follow-up it announces next round: the move its last move names in `then` (30 October)
var committed: bool = false      # its action this round is the follow-up it announced, which no Disrupt turns (Ryan, 2 November)
var grudge: int = 0              # foes the team has killed this fight, for a blow that grows with them (`per_kill`); the skirmish keeps it
var spent_once: Array = []       # the moves marked `once` it has used this fight (30 October: the Vampire Lord readies its rise once)
var swallow_mark: int = -1       # its HP as it swallowed a machine, -1 holding none: a quarter of its HP lost since lets it go (31 October)
var wanders: bool = false        # an elite any domain's Fracture may send, drawn by chance (Gilgamesh, 31 October and 2 November)
var rage: int = 0                # what every shield, vent or equipment entry the team spends adds to its blows while it stands, its own from the fight's start (content's `rage`: the Goblin Nob, 3 November; innate since 8 November)
var golden_mark: int = -1        # its HP as it went gold (golden, 4 November: the Thunder Ape), -1 while calm: a quarter of its HP lost since breaks the rage
var drains: bool = false         # every blow of its own regrows it by what the blow took from the hull (content's `drains`: the Vampire Lord's, an Ability on the unit since 16 November, Ryan: "This should be moved to an ability on the unit since it's on every attack. Like the Nob"; a rider on its blows until then)

## The aims a foe type or a move may name, and how the codex says each.
const AIM_EXPOSED := "exposed"
const AIM_ANYTHING := "anything"   # at random: the default
const AIMS := ["exposed", "anything", "heat", "armed", "focus", "buffed"]
const AIM_TEXT := {
	"exposed": "aims at the exposed", "anything": "aims at anything", "heat": "aims at heat",
	"armed": "aims at the armed", "focus": "fires as one", "buffed": "aims at the buffed",
}
## The conditions a move may carry (`when`, one word or a list meaning any), and how the
## codex says each. The skirmish reads them (`Skirmish._when_holds`).
const WHENS := ["below_half", "missing_hull", "back_behind", "others_on_field", "ally_hurt", "machine_buffed", "ally_unready", "ally_marked", "part_fallen", "calm"]
const WHEN_TEXT := {
	"below_half": "when below half", "missing_hull": "when hurt", "calm": "when it is calm",
	"back_behind": "when something stands behind it",
	"others_on_field": "when another stands with it", "ally_hurt": "when one of its own is hurt",
	"machine_buffed": "when a machine carries a buff", "ally_unready": "when one of its own is not readied",
	"ally_marked": "when one of its own carries a mark the team laid",
	"part_fallen": "once one of its parts has fallen",
}


func ablate_stacks() -> int:
	return Effects.stacks_of(self, "ablating")


func is_suppressed() -> bool:
	return Effects.tick_preview(self)["skip"]


## Its stun resist (Ryan, 2 November): the stacks of Numbed it gains as it recovers from a stun,
## each a round until one stun lands again; content's `resist`, else by its size.
const RESIST_DEFAULT := 1   # the stun resist by kind (Ryan, 3 November: "1 small, 2 massive, 3 for elites and bosses")
const RESIST_MASSIVE := 2
const RESIST_BOSS := 3      # an elite's, a hero's, a boss's and a commander's (a final's hero, the finale's line)
func stun_resist() -> int:
	if resist >= 0:
		return resist
	if boss or hero or elite or commands:
		return RESIST_BOSS
	return RESIST_MASSIVE if is_massive() else RESIST_DEFAULT


static func make(name: String, hp_value: int, attack_value: int, back: bool = false) -> Foe:
	var f := Foe.new()
	f.display_name = name
	f.hp = hp_value
	f.hp_max = hp_value
	f.attack = attack_value
	f.prefers_back = back
	f.actions = [basic_action()]
	f.action = f.actions[0]
	return f


static func basic_action() -> Dictionary:
	return {"id": "attack", "name": "Attack", "factor": 1.0, "strikes": 1, "weight": 1, "keywords": [], "text": ""}


func alive() -> bool:
	return hp > 0


func is_massive() -> bool:
	return size >= 2


## Armour right now: the foe's own plus what a defend left on it (a braced Spawn), read
## through the pipeline like a machine's.
func armour_total() -> int:
	if Effects.has(self, "exposure"):
		return 0   # Exposed: its armour counts for nothing, its own and any Armoured
	return maxi(0, armour + Effects.foe_armour_bonus(self))


## The armour a blow of this entry meets: none for a piece that ignores armour, a rule written
## on it (Ryan, 15 November, where the Breach keyword stood), else the armour standing. A spill
## is plain damage and meets it.
func armour_for(f: Face) -> int:
	return 0 if f != null and f.ignores_armour else armour_total()


func on_field() -> bool:
	return rank >= 0


## Pick this round's action by weight from every action, no conditions read. The skirmish
## narrows the list first (`choose_from`); this is the plain roll.
func choose_action(rng: RandomNumberGenerator) -> void:
	choose_from(actions, rng)


## Pick this round's action by weight from the moves given. One move needs no roll.
func choose_from(legal: Array, rng: RandomNumberGenerator) -> void:
	if legal.is_empty():
		action = basic_action() if actions.is_empty() else actions[0]
		return
	if legal.size() == 1:
		action = legal[0]
		return
	var total := 0
	for a in legal:
		total += maxi(1, int(a.get("weight", 1)))
	var pick := rng.randi_range(1, total)
	for a in legal:
		pick -= maxi(1, int(a.get("weight", 1)))
		if pick <= 0:
			action = a
			return
	action = legal[legal.size() - 1]


## The sense a move's pick follows: its own, else the foe's.
func aim_of(a: Dictionary = action) -> String:
	return str(a.get("aim", aim))


## The conditions on a move, as a list (content writes one word or a list meaning any).
static func whens_of(a: Dictionary) -> Array:
	var w = a.get("when", [])
	if w is String:
		return [] if str(w).is_empty() else [str(w)]
	return Array(w) if w is Array else []


## What one blow of an action does: base attack, plus what its statuses add (a rally's Empowered),
## `extra` (the rallies the skirmish sees on their way to it, Skirmish.foe_blow), its swarm and
## its grudge (`per_kill`, a point a foe the team has killed this fight: the Pilgrim's Karma, 30
## October), times its factor, rounded to the nearest whole number: the adds, then the multiplies, one
## damage formula for the whole game (Ryan, 26 October: "One formula means one damage formula
## followed by the whole game"). A defend, buff or debuff action deals nothing.
func damage_of(a: Dictionary, extra: int = 0) -> int:
	if not is_attack_action(a):
		return 0
	# A swarm blow grows with the foe's kin on the field: the ghoul's threat is its numbers.
	var swarm := int(a.get("swarm", 0)) * kin
	var grudged := int(a.get("per_kill", 0)) * grudge
	return maxi(0, int(roundf((base_number(a) + Effects.foe_attack_bonus(self) + extra + swarm + grudged) * float(a.get("factor", 1.0)))))   # never below nothing (a Weakened foe's)


## The number a move's blow starts from: the foe's attack, or for a move whose `power` names a
## status of its own (a borrowed swing's Appropriated, what it took: 30 October, a status since
## 16 November) that status's stacks, nothing while it holds none.
func base_number(a: Dictionary) -> int:
	var held := power_status(a)
	if not held.is_empty():
		return Effects.stacks_of(self, held)
	return attack


## The foe kinds a move names in `foe` (one id or a list): the kinds a merge takes in, the one
## a summon calls.
static func kinds_named(a: Dictionary) -> Array:
	var k = a.get("foe", [])
	if k is Array:
		return Array(k).map(func(x) -> String: return str(x))
	return [] if str(k).is_empty() else [str(k)]


## The status of its own a move's blow takes its number from, and spends as it swings (`power`:
## a borrowed swing's Appropriated); "" for a move that swings its foe's own attack.
static func power_status(a: Dictionary) -> String:
	return str(a.get("power", ""))


## A move's steps in order (Ryan, 16 November, on the proposal that a move be a short list of
## steps where it was one effect: "Yes, go with the steps if you think that's best"): the move
## itself, its first step as a move has always been written, a blow with its riders or one
## special, then what it does also (`also`), each a special's effect with the fields it reads.
## So a spell may strike and curse, or mend one foe and call another. One blow a move, and that
## its first step, for now.
static func steps_of(a: Dictionary) -> Array:
	var out: Array = [a]
	for st in a.get("also", []):
		out.append(st)
	return out


## The steps of a move that are effects: its first when the move is a special, and every step
## after it.
static func effects_of(a: Dictionary) -> Array:
	var out: Array = []
	for st in steps_of(a):
		if not str(st.get("effect", "")).is_empty():
			out.append(st)
	return out


## Does any step of the move do `effect`?
static func does(a: Dictionary, effect: String) -> bool:
	for st in effects_of(a):
		if str(st.get("effect", "")) == effect:
			return true
	return false


## The kind an effect belongs to (ACTION_EFFECTS), for a step that names its effect alone; ""
## for a word no kind knows.
static func effect_kind(effect: String) -> String:
	for k in ACTION_EFFECTS.keys():
		if (ACTION_EFFECTS[k] as Array).has(effect):
			return str(k)
	return ""


## The moves another of its moves names in `then` (30 October): a follow-up comes only the round
## after the move that names it lands, never by the roll.
static func follow_ups(list: Array) -> Array:
	var out: Array = []
	for a in list:
		var t := str(a.get("then", ""))
		if not t.is_empty() and not out.has(t):
			out.append(t)
	return out


## One blow of an action at the foe's own numbers: its attack times the move's factor, with no
## kin and no rally (the codex's number, and what the hold reads a live blow against).
func base_damage_of(a: Dictionary) -> int:
	if not is_attack_action(a):
		return 0
	return int(roundf(base_number(a) * float(a.get("factor", 1.0))))


## The action's kind: attack by default (the basic action), or defend, buff, debuff.
static func kind_of(a: Dictionary) -> String:
	return str(a.get("kind", "attack"))


static func is_attack_action(a: Dictionary) -> bool:
	return kind_of(a) == "attack"


## Is this round's chosen action a blow at a machine? A move still gathering lands no blow
## this round (its countdown).
func attacks() -> bool:
	return is_attack_action(action) and not gathering()


## The rounds a move gathers before it lands (`countdown`, 15 October): announced as the round
## opens, it lands that many rounds later, the warning shown the whole time (the Lancer's
## Jump, one round; a Tonberry's walk or a Tyrano's five to zero, longer).
static func countdown_of(a: Dictionary) -> int:
	return maxi(0, int(a.get("countdown", 0)))


## A last act as an attack action (content `on_death.blow`, 15 October: the Gargantuan King's Meteor),
## shaped like any move so the blow reads through the same rules.
static func death_blow_from(b: Dictionary) -> Dictionary:
	return {"id": "last_act", "name": str(b.get("name", "Last Act")), "kind": "attack", "factor": float(b.get("factor", 1.0)),
		"strikes": maxi(1, int(b.get("strikes", 1))), "weight": 1, "keywords": Array(b.get("keywords", [])), "text": str(b.get("text", ""))}


## Its last act, if it has one: the blow it lands the moment it falls.
func last_act() -> Dictionary:
	var b = on_death.get("blow", null)
	return b if b is Dictionary else {}


## Is it a core with parts (the boss in parts, 15 October)?
func has_parts() -> bool:
	return not part_ids.is_empty()


## Is it gathering a move that lands in a later round?
func gathering() -> bool:
	return not pending.is_empty() and charge > 0


func damage() -> int:
	return damage_of(action)


func strikes() -> int:
	return maxi(1, int(action.get("strikes", 1)))


## What a defend, buff or debuff action does (built 30 September; the ten planned actions in
## content/foes.json). Each carries `effect` and, where it needs one, `value`, `foe`, `count`.
##   defend  brace: Armoured, the move's `value` in stacks of armour +1 (Effects.brace_stacks),
##           every stack going as the foes' next turn opens (Burrow; one word and one icon for both
##           sides, Ryan, 16 October: an effect and the buff it creates share a name)
##           recover: regains `value` hit points, itself (the treants' Recover; "regrow" until
##           15 November, Ryan: "it can just be named Heal, or Recover if it's self-only")
##           heal: the most hurt of its own, itself included, regains `value` (Cure;
##           "regrow_ally" until then)
##           brace_all: Armoured, `value` stacks, on every foe in the fight, on the same clock
##           (Protect, 15 October): until the foes' next turn opens
##           cleanse: every mark the team laid (Effects.TEAM_MARKS) off the most-marked of its
##           own, itself included (Hallow, 28 October: the Marsh's lever); never Numbed, never
##           Suppressed, never a buff
##           barrier: a Barrier on itself, the next weapon blow it takes dealing nothing, until
##           popped or the end of the player's next turn (28 October)
##           regenerate: Regenerating `value` on itself, a regrowth at each of its next three
##           actions after its ticks (28 October)
##   buff    revive_once: comes back from the pool once after dying (Get Back Up); Suppress and
##           Disrupt answer the telegraphed move, kill order the rest
##           revive_once_ally: one of its own, never itself, not yet readied, comes back once
##           the next time it falls (Reraise, the promoted Cleric's, 16 October): a party
##           member first, the heaviest hitter among them, then the rest of its own the same way
##           summon: `count` foes of `foe` join the pool at the round's end (Raise)
##           rally: every foe on the field, itself too, is Empowered `value`, at once (Kindle)
##           prime: Primed `value` on every other foe on the field, its next move's blows each
##           leaving that much Ablating on the machine they hit (28 October)
##           ward_all: a Ward on every foe on the field, itself included: no mark the team lays
##           lands, Suppressed excepted, until the end of the player's next turn (28 October)
##   debuff  drain_rerolls: the team has `value` fewer rerolls next round (Roar)
##           ablate: its target gains `value` stacks of Ablating, a point a stack off its shield
##           and then its hull as the player's turn ends (Stoke; Burning as heat until 15 November)
##           jam: its target's showing entry is Jammed, switched off through its next turn
##           (Hush; "disable" until 15 November, Ryan: "Rename to Jammed")
##           scorch_all: every machine gains `value` stacks of Scorched, its weapons and debuffs
##           running hotter (Eruption; nobody in particular)
##           corrupt_all: every machine's showing entry is corrupted (Unravel; nobody in particular)
##           expose: its target is Exposed through the round after (Ryan, 15 November): its
##           armour counts for nothing, and as that round opens every targeted intent turns on
##           it until the blows drawn would wreck it. Also a rider a blow may carry (`expose`
##           among its keywords). One out at a time: no foe announces one while another's is
##           out or a machine stands Exposed (Skirmish.legal_actions)
##           swallow: its target is Swallowed for `value` rounds, out of the fight until they run
##           out or the swallower falls; never the last machine able to act (Floraison's, 30
##           October: hard control on the team, answered before it lands by a Ward, a Lure, a
##           Suppress or a Disrupt, and after by the kill)
##   buff    merge: every other foe on the field of the kinds its `foe` names (one id or a list)
##           is taken into it, gone without a fall: it regrows the HP they had left and its next
##           move hits `value` harder for each (the King Gel's, 30 October: thin the Gels first)
##           appropriate: it gains Appropriated, the number of the entry its target's die shows,
##           a weapon's printed blow and 1 for anything else, the fake; what it held before is
##           replaced. A Ward on the machine turns it away. Gilgamesh's own rule, a step of his
##           Collect after the blow that jams the entry (Ryan's mark of 15 November: "It grants
##           Jammed on the target, and Gilgamesh gains Appropriated with the value")
## A move may do more than one of these: its first step is the move as written, and `also`
## lists what it does after, each an effect from these lists with its own fields (steps_of).
const ACTION_EFFECTS := {
	"defend": ["brace", "recover", "heal", "brace_all", "cleanse", "barrier", "regenerate"],
	"buff": ["revive_once", "revive_once_ally", "summon", "rally", "prime", "ward_all", "merge", "golden", "appropriate"],
	"debuff": ["drain_rerolls", "ablate", "jam", "scorch_all", "corrupt_all", "dispel", "swallow", "expose"],
}

## Foe effects that act on nobody in particular, so a lure has nothing to turn and no machine
## is shown intent (the ambush read below).
const UNTARGETED_EFFECTS := ["brace", "recover", "heal", "brace_all", "cleanse", "barrier", "regenerate", "revive_once", "revive_once_ally", "summon", "rally", "prime", "ward_all", "drain_rerolls", "scorch_all", "corrupt_all", "merge", "golden"]


## Does this round's move act on nobody in particular (one of UNTARGETED_EFFECTS)? Its pick
## is drawn like any foe's, and means nothing: no arrow, no intent on anyone.
func acts_on_nobody() -> bool:
	if is_attack_action(action):
		return false
	for st in effects_of(action):
		if not UNTARGETED_EFFECTS.has(str(st.get("effect", ""))):
			return false   # one step of it lands on its pick: the move is aimed
	return true


## Does this foe show intent on a machine (the funnel-web's ambush read, 18 October, as the
## HUD draws the arrows): alive, not suppressed, and its arrow on it, its pick or a blow at
## every machine, a gathering countdown included. A foe on a special that acts on nobody in
## particular shows intent on no machine, whatever its pick. `u` is the machine's Unit.
func intent_on(u) -> bool:
	if u == null or not alive() or is_suppressed() or target == null:
		return false
	if reaches_every_machine():
		return true
	if acts_on_nobody():
		return false
	return target.get("unit") == u


## Tags an attack action may carry. Anything true or false about a blow is a tag here, never
## a field of its own.
## scorch: a stack of Scorched on the machine it hits, its
## weapons and debuffs running hotter for the turn (the foes' one tax on heat); ablate: a stack of
## Ablating, a point a stack off the shield and then the hull, past armour and a Barrier, as the
## player's turn ends (Ryan, 15 November: one rule on both sides, in Burning's place).
## jam: the entry the target's die shows is Jammed, switched off through its next turn. corrupt:
## a stack of Corrupted on that entry, for the skirmish: it bites its owner every time it is
## spent. self_destruct: the blow spends the striker: it dies after it, whole, and never gets
## back up (the Bomb). all: the blow lands on every machine in the fight, each strike on each
## machine, so no aim or lure moves it (Ryan, 15 October: no foe struck more than one
## machine, the storms' three blows included; the content follows in a foe kit refresh).
## A steal is no rider since 16 November (Ryan's mark: "Doesn't need to be it's own rider"):
## Gilgamesh's Collect is a blow that jams and a step of its own, `appropriate`. A drain is no
## rider since the same day: it is the Vampire Lord's own Ability, on every blow (`drains`). destroy:
## any of the blow on the hull and the entry the machine's die shows is destroyed, blank until
## the hangar mends it (Ryan, 15 November: "a boss-level rider, that destroys the visible face
## if it damages hull at all. Only promoted form or superboss-level so we're not tuning the
## economy around it"); a shield that takes the whole blow, a Barrier or a Ward keeps the entry.
## A purge is a special, never a rider (28 October: a rider on a hitter's blow is a tax with no
## decision), so it is no attack keyword; the validator refuses it on a blow.
const ATTACK_KEYWORDS := ["scorch", "ablate", "jam", "corrupt", "brittle", "self_destruct", "all", "destroy", "expose"]
## The specials that may never ride a blow (28 October).
const SPECIALS_ONLY := ["dispel"]
## The riders that lay stacks, each a number on the move beside its keyword (24 October, as the
## player's Ablate N: Scorch 2 lays two stacks a blow).
const NUMBERED_RIDERS := ["scorch", "ablate", "corrupt", "brittle"]


## Does this move lay Exposed on the machine it lands on: a move of its own (`expose`), or a
## blow that carries the rider?
static func exposes(a: Dictionary) -> bool:
	if does(a, "expose"):
		return true   # its own move, or a step of one
	return is_attack_action(a) and Array(a.get("keywords", [])).has("expose")


func has_keyword(a: Dictionary, k: String) -> bool:
	return a.get("keywords", []).has(k)


## The stacks a numbered rider lays a blow: the move's number, one where it names none (a move
## built in a test; content always says it).
func rider(a: Dictionary, k: String) -> int:
	return maxi(1, int(a.get(k, 1)))


## Is this round's move a blow at every machine (`all`)?
func hits_all() -> bool:
	return attacks() and has_keyword(action, "all")


## Does its move reach every machine, landing this round or still gathering? The screen's read
## for the arrows and the hold, where the engine's own is hits_all.
func reaches_every_machine() -> bool:
	return is_attack_action(action) and has_keyword(action, "all")


## The action's text with {damage} and {value} filled in, so "Jaw Rend for {damage}" and
## "Regrows {value} HP" read as numbers.
func text_of(a: Dictionary) -> String:
	return str(a.get("text", "")).replace("{damage}", str(damage_of(a))).replace("{value}", str(int(a.get("value", 0))))


## How much this foe can threaten in a turn, for deployment order: the heaviest hitters stand
## left, where they strike first, so the player sees the big blow coming from the jump.
func threat() -> int:
	var best := 0
	for a in actions:
		best = maxi(best, damage_of(a) * maxi(1, int(a.get("strikes", 1))))
	return best

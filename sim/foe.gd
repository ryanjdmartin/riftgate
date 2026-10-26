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
## Damage is base attack times the action's factor; strikes are separate blows; keywords are
## tags on the blow (breach: ignores the shield and the armour, the whole blow to hull).

var display_name: String = "foe"
var content_id: String = ""      # id in content/foes.json, for the codex
var hp: int = 30
var hp_max: int = 30
var attack: int = 10             # base attack: the number the player reads as "how hard it hits"
var armour: int = 0              # flat off every blow that lands on it (content; 2 October: the one enemy mitigation besides recovery)
var aim: String = AIM_ANYTHING   # the sense its target pick follows (content; a move may override it)
var prefers_back: bool = false   # ranged types hold the back rank and never step up
var pack_id: int = 0            # which battlefield pack this foe came from
var size: int = 1                # 2 = massive: fills both slots of a column
var actions: Array = []          # implemented attack actions; at least the basic one

# Live state.
var rank: int = -1               # 0 front, 1 back, -1 in reserve
var column: int = -1
var target: RefCounted = null    # Skirmish.MechState, set when intents are telegraphed
var action: Dictionary = {}      # this round's chosen action
var modifiers: Array = []        # statuses on this foe (burning, suppressed, numbed...): Effects.Modifier list
var die = null                   # foes have no die; the pipeline asks, so the field exists
var stays_down: bool = false     # gone whole (a Bomb's burst): a foe that would get back up does not (Execute retired 10 October)
var last_special: String = ""    # the special it announced last round, so none fires twice running
var kin: int = 0                 # other live foes of its type on the field, for a swarm blow; the skirmish keeps it
var hero: bool = false           # one of the party: a hero (content `hero`, human-sized, a domain's final, dealt from its bench) or its promoted form at the finale (content `promotes`)
var commands: bool = false       # a commander of its boss unit (the faction's boss, a final's hero, one of the finale's line), marked as the unit unpacks: the unit stands while one does
var escorts: bool = false        # the wildlife beside a boss unit's commanders (a final's), marked as the unit unpacks: the unit's strength counts them
var boss: bool = false           # a domain's boss (content: a faction's `boss`), whatever its size: big is an attribute of any tier (15 October)
var on_death: Dictionary = {}    # {"summon": foe id, "count": n}: destroyed, it splits, that many of the named foe stepping up in its place at once (the Gel)
var fresh: bool = false          # stepped up mid-round (a split's half): its round is over, so it shows no intent and acts from the next round
var pending: Dictionary = {}     # a countdown move it is gathering (`countdown` on the move): it holds until it lands
var charge: int = 0              # rounds before the pending move lands; at 0 it lands this round
var part_ids: Array = []         # a core's parts (content `parts`): the foes of its pack that stand beside it
var guard: String = ""          # a core takes no damage while "all" its parts stand, or while "any" does
var regrow_parts: int = 0        # rounds after a part falls before it grows back, while the core stands (0: never)
var regrow_due: Array = []       # [part id, round it returns] for each part on its way back

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
const WHENS := ["below_half", "missing_hull", "few_waiting", "back_behind", "others_on_field", "ally_hurt", "machine_buffed", "ally_unready"]
const WHEN_TEXT := {
	"below_half": "when below half", "missing_hull": "when hurt", "few_waiting": "when few wait behind it",
	"back_behind": "when something stands behind it",
	"others_on_field": "when another stands with it", "ally_hurt": "when one of its own is hurt",
	"machine_buffed": "when a machine carries a buff", "ally_unready": "when one of its own is not readied",
}


func burn_stacks() -> int:
	return Effects.stacks_of(self, "burning")


func is_suppressed() -> bool:
	return Effects.tick_preview(self)["skip"]


## The chance a suppress fails against this foe right now: its Numbed, and nothing else (no foe
## resists by nature since 10 October, Ryan: the chip shows who resists, how much and how long).
func resist_total() -> int:
	return clampi(int(Effects.tick_preview(self)["resist"]), 0, 100)


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


## The armour a blow of this entry meets: none when it breaches (one breach, 22 October: a
## breaching weapon ignores a foe's armour as a foe's breach ignores a machine's shield and
## armour), else the armour standing. A spill and a vent's blast are plain damage and meet it.
func armour_for(f: Face) -> int:
	return 0 if f != null and f.has(Face.Keyword.BREACH) else armour_total()


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


## What one blow of an action does: base attack (plus what a rally adds for the round) times
## its factor, rounded to the nearest whole number (numbers are in the magnitude of tens,
## not multiples of ten). A defend, buff or debuff action deals nothing.
func damage_of(a: Dictionary) -> int:
	if not is_attack_action(a):
		return 0
	# A swarm blow grows with the foe's kin on the field: the ghoul's threat is its numbers.
	return int(roundf((attack + Effects.foe_attack_bonus(self)) * float(a.get("factor", 1.0)))) + int(a.get("swarm", 0)) * kin


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


## A last act as an attack action (content `on_death.blow`, 15 October: the Behemoth's Meteor),
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
##           every stack going at its next action (Burrow; one word and one icon for both
##           sides, Ryan, 16 October: an effect and the buff it creates share a name)
##           regrow: regains `value` hit points (Knit)
##           regrow_ally: the most hurt of its own, itself included, regains `value` (Cure)
##           brace_all: Armoured, `value` stacks, on every foe in the fight through the next
##           round (Protect, 15 October: until its next action, as the player sees it)
##   buff    revive_once: comes back from the pool once after dying (Get Back Up); Suppress and
##           Disrupt answer the telegraphed move, kill order the rest
##           revive_once_ally: one of its own, never itself, not yet readied, comes back once
##           the next time it falls (Reraise, the promoted Cleric's, 16 October): a party
##           member first, the heaviest hitter among them, then the rest of its own the same way
##           summon: `count` foes of `foe` join the pool at the round's end (Raise)
##           rally: every other foe on the field hits `value` harder next round (Kindle)
##   debuff  drain_rerolls: the team has `value` fewer rerolls next round (Roar)
##           burn: its target gains `value` stacks of Burning, heat at the end of the player's
##           turn (Stoke; direct heat retired 13 October)
##           disable: its target's showing entry is switched off through its next turn (Hush)
##           scorch_all: every machine gains `value` stacks of Scorched, its weapons running
##           hotter (Eruption; nobody in particular)
##           corrupt_all: every machine's showing entry is corrupted (Unravel; nobody in particular)
const ACTION_EFFECTS := {
	"defend": ["brace", "regrow", "regrow_ally", "brace_all"],
	"buff": ["revive_once", "revive_once_ally", "summon", "rally"],
	"debuff": ["drain_rerolls", "burn", "disable", "scorch_all", "corrupt_all", "silence", "dispel"],
}

## Foe effects that act on nobody in particular, so a lure has nothing to turn and no machine
## is shown intent (the ambush read below).
const UNTARGETED_EFFECTS := ["brace", "regrow", "regrow_ally", "brace_all", "revive_once", "revive_once_ally", "summon", "rally", "drain_rerolls", "scorch_all", "corrupt_all"]


## Does this round's move act on nobody in particular (one of UNTARGETED_EFFECTS)? Its pick
## is drawn like any foe's, and means nothing: no arrow, no intent on anyone.
func acts_on_nobody() -> bool:
	return not is_attack_action(action) and UNTARGETED_EFFECTS.has(str(action.get("effect", "")))


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
## breach: ignores the shield and the armour, the whole blow to hull. scorch: a stack of Scorched on the machine it hits, its
## weapons running hotter for the turn; burn: a stack of Burning, heat at the end of the
## player's turn (Ryan, 13 October: Burn and Scorch, foes heat machines only through them).
## disable: switches off the entry the target's die shows, through its next turn. corrupt:
## a stack of Corrupted on that entry, for the skirmish: it bites its owner every time it is
## spent. self_destruct: the blow spends the striker: it dies after it, whole, and never gets
## back up (the Bomb). all: the blow lands on every machine in the fight, each strike on each
## machine, so no aim or lure moves it (Ryan, 15 October: no foe struck more than one
## machine, the storms' three blows included; the content follows in a foe kit refresh).
## silence: the machine hit is Silenced, its buffs counting for nothing through its next
## round; dispel (Purge since 20 October, its id kept): the machine hit loses every buff, its
## stores kept (Ryan, 17, 18 and 21 October; built 21 October).
const ATTACK_KEYWORDS := ["breach", "scorch", "burn", "disable", "corrupt", "silence", "dispel", "self_destruct", "all"]
## The riders that lay stacks, each a number on the move beside its keyword (24 October, as the
## player's Burn N: Scorch 2 lays two stacks a blow).
const NUMBERED_RIDERS := ["scorch", "burn", "corrupt"]


func has_keyword(a: Dictionary, k: String) -> bool:
	return a.get("keywords", []).has(k)


## The stacks a numbered rider lays a blow: the move's number, one where it names none (a move
## built in a test; content always says it).
func rider(a: Dictionary, k: String) -> int:
	return maxi(1, int(a.get(k, 1)))


func breaches() -> bool:
	return has_keyword(action, "breach")


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
		best = maxi(best, damage_of(a) * maxi(1, int(a.get("strikes", 1))) + (1 if has_keyword(a, "breach") else 0))
	return best

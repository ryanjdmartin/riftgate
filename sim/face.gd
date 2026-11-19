class_name Face
extends RefCounted

## One face of a die. Reads as: primary icon (kind and reach), a number (power), a list of
## keywords and a heat cost.
##
## Numbers are in tens. A face is one number and involves no roll (rolled ranges gone since
## 2 November, Ryan: decided in play testing). There are no crits (10 October): chances live
## on riders, never on the damage (bible section 5).

enum Kind { ATTACK, SHIELD, VENT, BLANK, BUFF }
## Two reaches since 10 October (Ryan): Close, a worse Direct by design, is removed and melee
## is a tag. Direct was line of sight until 9 October.
enum Reach { NONE, DIRECT, INDIRECT, EVERY_FOE }   # Every Foe (4 November), below; Sweep, a rank picked and walked, went on 12 November
## Execute and Steady are retired (10 October): a threshold doubling is a hard sum hidden in
## a keyword, and a rolled weapon dealing its average is simply a flat one.
## Three rules that were keywords are rules written on their one piece since 15 November
## (Ryan's marks: "unique text, not a keyworded rider"), each a field below and the die's star:
## the Web Bomb's web (`webs`, 18 October: the foe hit wears the Web Bomb's mark, and as the
## round ends the web bursts into a Suppress on it and the foe beside it, each for its next
## turn, Skirmish._burst_webs); the Combat Translocator's swap (`swaps`, Ryan's go of 19 October: the
## spend takes a second target, another foe or an empty slot, and the two trade places); and
## the Overrun Gearing's spill (`spills`, a module's, on the effective entry alone: damage past
## a kill in the front rank carries into the foe behind).
## Brittle (Ryan's go, 19 October; built 21 October; Flak until 15 November): Wainwright &
## Sutler's on-hit, a numbered keyword like Ablate and Cryo; each foe hit gains that many stacks
## of Brittle.
## Area by shape, numbered (Ryan, 28 October; the half retired): Spread N (id `cleave`) the
## foes beside the target in its rank, Penetrate N the other rank of its column, each foe past
## the target taking N as its blow's number. A piece may carry both (the plus round its target);
## Splash, the two at one number under one word, was cut on 15 November (Ryan: "It might be a
## more interesting game with only the other area shapes, with a few select pieces carrying both
## spread and penetrate together").
## Chain N (Ryan, 28 October; the kill and repeat and the ping retired; its random charge of
## 29 October retired 3 November for the Charged primer): Shock's other payoff, every other
## Shocked foe on the field taking N as its blow's number, wherever it stands and whatever the
## gun's reach, plain, no strike being aimed at it, so its Shock stands. A weapon's alone.
## Every Foe and Every Ally are targeting modes (Ryan, 4 November: "Silence should not narrow
## targeting modes, that's why I'm switching them to targeting modes"; keywords from 2 November):
## Every Foe a reach (dropped on any foe, it lands on every foe in the fight: a debuff's riders,
## the Shift Whistle's lure-all's among them, a weapon's number whole on each, the two gated
## specials' since 12 November); Every Ally and Every Other Ally `targets` (a shield's or a buff's: the whole
## team, its own machine among them, or every machine but its own, the Mooring Screens'; Ryan:
## "the difference is whether the center one is lit or not, its two modes"). `reaches_all` reads
## any of them.
enum Keyword { NONE, CLEAVE, PENETRATE, ABLATE, SUPPRESS, CHAIN, RAPID, CLEANSE, LURE, DISRUPT, SHOCK, CRYO, BRITTLE, EXPOSE, DISPEL, INSTANT, SAP }
## Whom a component may be spent on (Ryan, 26 September): an attack (a weapon or a debuff)
## targets foes; a shield, a vent or a buff targets self and allies by default, and content may
## narrow one to self only or allies only, so the design space stays open; Every Ally and Every
## Other Ally (4 November), targeting modes, land on the whole team or every machine but its own.
enum Target { SELF_ALLY, SELF, ALLY, FOE, EVERY_ALLY, EVERY_OTHER_ALLY }

const KIND_NAMES := {
	Kind.ATTACK: "attack", Kind.SHIELD: "shield", Kind.VENT: "vent", Kind.BLANK: "blank", Kind.BUFF: "buff",
}
const REACH_NAMES := {
	Reach.NONE: "none", Reach.DIRECT: "direct", Reach.INDIRECT: "indirect", Reach.EVERY_FOE: "every_foe",
}
const KEYWORD_NAMES := {
	Keyword.NONE: "", Keyword.CLEAVE: "cleave", Keyword.PENETRATE: "penetrate", Keyword.ABLATE: "ablate",
	Keyword.SUPPRESS: "suppress",
	Keyword.CHAIN: "chain", Keyword.RAPID: "rapid", Keyword.CLEANSE: "cleanse",
	Keyword.LURE: "lure", Keyword.DISRUPT: "disrupt",
	Keyword.SHOCK: "shock",
	Keyword.CRYO: "cryo", Keyword.BRITTLE: "brittle",
	Keyword.EXPOSE: "expose",
	Keyword.DISPEL: "dispel", Keyword.INSTANT: "instant", Keyword.SAP: "sap",
}
## What the player reads where it differs from the content id (the vocabulary's name).
## Purge (28 October) is one id on both sides, dispel.
const KEYWORD_LABELS := { Keyword.CLEAVE: "spread", Keyword.DISPEL: "purge" }
## The status each foe hit gains from a keyword that lays one: the die's hold lists such a
## keyword as what the spend applies on hit, after its heat (Ryan, 25 October).
const KEYWORD_STATUS := {
	Keyword.ABLATE: "ablating", Keyword.CRYO: "cryoed", Keyword.BRITTLE: "brittled", Keyword.SHOCK: "shocked",
	Keyword.SUPPRESS: "suppressed", Keyword.EXPOSE: "exposure", Keyword.SAP: "sapped",
}
## The keywords that carry a number, each in the field of its name on the entry: the stacks a
## rider lays (Ablate, Cryo, Brittle), the blow an area keyword deals each foe past the target
## (Spread, Penetrate; Ryan, 28 October) or the blow Chain deals each conductor (Chain,
## 28 October).
const NUMBER_FIELDS := {
	Keyword.ABLATE: "ablate", Keyword.CRYO: "cryo", Keyword.BRITTLE: "brittle",
	Keyword.CLEAVE: "cleave", Keyword.PENETRATE: "penetrate",
	Keyword.CHAIN: "chain", Keyword.DISPEL: "dispel", Keyword.SAP: "sap",
}
## The area keywords (Ryan, 11 and 12 October; numbered 28 October; two since Splash's cut).
const AREA_KEYWORDS := [Keyword.CLEAVE, Keyword.PENETRATE]
const TARGET_NAMES := {
	Target.SELF_ALLY: "self_ally", Target.SELF: "self", Target.ALLY: "ally", Target.FOE: "foe", Target.EVERY_ALLY: "every_ally", Target.EVERY_OTHER_ALLY: "every_other_ally",
}
## Keywords that ride on a shield or vent component (spent on a machine, not a foe); every
## other keyword is an attack's, except the few that ride on anything. The validator holds
## content to this. Lure and disrupt (2 October) are attack keywords: they ride on any
## entry aimed at a foe, a weapon or equipment, whatever else it does.
## Shock (9 October) is an attack keyword too: every foe the blows reach and leave alive is
## Shocked.
const SUPPORT_KEYWORDS := [Keyword.CLEANSE]
## Keywords about the spend itself, not its target, so any kind of component may carry
## them: rapid (on a vent or a shield too since 9 October, the Wake Diffuser first) gives the
## machine its turn back whatever the component did, and instant (Ryan, 12 November) gives it
## back on a roll that may land on itself. Volatile rode here until 26 October, when it became
## a cost printed beside the heat (`volatile`, below), a keyword no longer.
const ANY_KEYWORDS := [Keyword.RAPID, Keyword.INSTANT]
## The keywords that give the machine its turn back once the entry is spent: Rapid's free reroll,
## never onto the entry just spent and the entry dark for the rest of the round (its own
## switch-off, never printed), and Instant's, a roll that may land on itself and darkens nothing
## (Ryan, 12 November: "rapid gets its innate cooldown zero back without the explicit display, and
## the rapid no cooldown pieces change to a new keyword: Instant (reroll after use, can land on
## itself)"). One entry carries one of them at most; the validator holds content to it.
const ACT_AGAIN_KEYWORDS := [Keyword.RAPID, Keyword.INSTANT]


static func keyword_label(k: int) -> String:
	return KEYWORD_LABELS.get(k, KEYWORD_NAMES[k])

# Enum-typed members are declared as int: GDScript 4 reports a spurious "Face.Kind vs Kind"
# type mismatch when a class_name script is loaded from a headless -s runner.
var kind: int = Kind.ATTACK
var reach: int = Reach.DIRECT
var power: int = 20
var keywords: Array[int] = []
var heat: int = 0
var strikes: int = 1          # blows per use: a rapid-fire weapon lands many small hits (each rolls and procs on its own)
var ablate: int = 0             # an attack with Ablate: the stacks of Ablating each blow leaves (Ryan, 18 October: a numbered keyword, never read off the damage)
var cryo: int = 0             # an attack with Cryo: the stacks of Cryo each foe it reaches gains (the Cryo Flinger, 20 October; a numbered keyword like Ablate)
var sap: int = 0              # an attack with Sap: the stacks of Sapped each foe hit gains (the Baboon's Redshift Emitter, 11 November; numbered like Brittle)
var disrupts_attackers: bool = false   # a buff: every foe aiming at the machine it lands on is Disrupted (the Baboon's Retrocausal Shroud, 11 November)
var brittle: int = 0             # an attack with Brittle: the stacks of Brittle each foe hit gains (the Flakshot Repeater, 21 October; numbered like Ablate)
var cleave: int = 0           # an attack with Spread: the number each foe beside its target in its rank takes as its blow's (Ryan, 28 October: Spread N, the half retired)
var penetrate: int = 0        # an attack with Penetrate: the number the other rank of its target's column takes (Penetrate N)
var chain: int = 0            # an attack with Chain: the number every other Shocked foe on the field takes as its blow's (Chain N, 28 October)
var dispel: int = 0           # an attack or equipment with Purge: the stacks every buff of each foe it reaches loses (Purge N, 2 November)
var shield_cost: int = 0      # a cost (Ryan, 26 October): the shield a spend takes from its owner first; short of it the entry cannot be played
var short: bool = false       # shown only: its machine cannot pay the entry's price now, a shield cost or the count it spends (Skirmish.shown_face), struck through on the die like a dry gun
var volatile: int = 0         # a cost (Ryan, 26 October, a keyword with a chip until then): the hull a spend bites its owner, past shield and armour, before the component acts; it may wreck it (a numbered keyword since the stock pass's engine, 22 October; a constant of 10 before)
var gates: Dictionary = {}    # an attack: keyword name -> the condition it lands under, read against each foe at the spend before its own riders (the Suppression Battery's Suppress on a foe carrying Brittle; the stock pass's engine, 22 October)
var holds: String = ""        # an attack: the status its target keeps through this round's end, its halving skipped (the Hollow-point Harpoon's pin on Brittle)
var consumes: String = ""     # an attack: the status it consumes on its target, every stack, a point more a stack before the multiplies (the Backdraft Charge's Ablating, 22 October)...
var per_consumed: int = 1     # ...the damage a stack consumed adds
var ignores_armour: bool = false   # an attack: its blows take nothing off for a foe's armour, a rule written on the piece (Ryan, 15 November: "Ignores armour can be an explicitly written out property", where the Breach keyword stood on our side)
var swaps: bool = false   # an attack: the spend takes a second target, another foe or an empty slot, and the two trade places; a rule written on the piece, no keyword (the Combat Translocator's; Ryan, 15 November: "Can be unique text, not a keyworded rider")
var webs: bool = false    # an attack: each foe hit wears the piece's web, which bursts as the round ends into a Suppress on it and the foe beside it, each for its next turn (the Web Bomb's; Ryan, 15 November: "It's a unique effect, and the debuff can be renamed \"web bomb.\"")
var spills: bool = false  # the effective entry only, never printed: damage past a kill in the front rank carries into the foe behind (the Overrun Gearing's, a module's; Ryan, 15 November: "As a module only effect, this does not need to be a keyword"; Effects.grants_spill)
var self_ablate: int = 0        # an attack: spending it sets its own machine Ablating, this many stacks (the Stoker's, the stock pass's landing, 22 October; a price in its own shield since Ablate, 15 November)
var component: String = ""    # the component this entry is (content id); "" for an empty hardpoint
var empty: bool = false       # an empty hardpoint: blank, and nothing was ever there to break
var fixed: bool = false       # built into the chassis (no hardpoint); false means this entry is a hardpoint
var disabled: bool = false    # a stand-in for an entry a status has switched off: blank for now, the real one is untouched
var targets: int = Target.SELF_ALLY   # a shield, a vent or a buff: whom it may be spent on; an attack is always FOE
var buff_status: String = ""  # a buff: the engine status it grants (Effects.STATUS id), with...
var buff_stacks: int = 1      # ...this many stacks...
var buff_rounds: int = 1      # ...through the end of this many rounds (1: this round)
var front_status: String = "" # a buff: the foe status it lays on the foe in front of the machine it lands on (the Photosphere Lance's Weakened), with...
var front_stacks: int = 0     # ...this many stacks
var vents_all: bool = false   # an attack that fires the machine's whole heat: the gauge is empty after the shot...
var power_per_heat: int = 0   # ...and each `per_heat` heat it fired adds this to the blow (the Heliographic Death Ray; the Buzzard's cannon first, 28 September)
var per_heat: int = 10        # ...the heat a step of power_per_heat stands for (the stock pass, 22 October: a field, 10 until the content landing)
var spends_shield: bool = false   # an attack that fires its machine's whole shield, leaving it at nothing, broken (the Shield-burner Cannon since 18 November: Ryan, "the cannon fires its whole field")...
var power_per_shield: int = 0   # ...and each `per_shield` shield it fired adds this to the blow, as power_per_heat does for heat
var per_shield: int = 2       # ...the shield a step of power_per_shield stands for
var power_per_missing: int = 0   # an attack: added for every per_missing HP its target is missing (10 October; flat, shown on the hover)...
var per_missing: int = 20     # ...the HP a step of power_per_missing stands for (the stock pass, 22 October: a field, 20 until the content landing)
var finisher: int = 0         # an attack: its number times this against a foe at half its HP or less, read as the hit judges the foe (the Kite's Pinion Driver, 11 November: the Coriolis's slope as one step); 0 for none
# The Quintessence Tap's (the Ammit's, Ryan, 12 November: "Consume up to 5 souls, granting 1 Empowered per soul"; "No Empowered decays this round. And I mean none, not ally or enemy"):
var spends: String = ""       # a buff: the status of its own machine it spends for its stacks, a stack granted a stack spent (its Essence); with none to spend the entry cannot be played
var spends_up_to: int = 0     # ...the most it spends, and so the most it grants (five); buff_stacks holds it as built, and what it would take now on the die as shown (Skirmish.shown_face)
# The Puffin's dump (Ryan, 11 November: "A locked piece can transfer the Puffins heat to another unit along with a buff based on heat moved"; "just allies"):
var passes_heat: bool = false  # a buff on an ally: its machine's whole heat, its overheat with it, passes onto the ally it is spent on, past that ally's maximum too...
var heat_per_stack: int = 0    # ...and the ally gains a stack of its status for every this many heat passed, rounded down (2); buff_stacks holds what it would grant now on the die as shown (Skirmish.shown_face)
var holds_all: String = ""    # any entry: once it is spent, no unit's stacks of this status run down at this round's end, either side's (Skirmish.round_holds)
var fills_hopper: int = 0     # an attack: loads it puts in its machine's hopper for each foe its blows reach (the Chainsaw Claw, 11 October)
var fires_hopper: int = 0     # an attack: the most loads one shot fires from the hopper...
var power_per_load: int = 0   # ...each adding this to the blow (the Bullion Fragmenter, 11 October)
var braces: int = 0           # any entry: spending it Armours its owner, this many stacks, until its side's next turn begins (the Breaching Plow, 12 October)
var cooldown: int = -1        # any entry: the rounds it sits out once spent, after the round of the spend (Ryan, 14 October; counted so since 12 November: "change the count so 1 is how I intended"), printed on it; -1 or 0, none (Rapid's own switch-off is the keyword's, never printed)
var team_rerolls: int = 0     # equipment: spending it gives the team this many rerolls this round, at once and past the round's two (the Reveille Horn, the Immelmann Booster; Ryan, 15 November, in the place of the Rallied buff: "This doesn't need to be a temporary buff or a keyword")
var turns_die: bool = false   # a Rapid buff on itself that turns a folded die to its other battery, its free roll landing there (the Clydesdale's Changeover, Ryan, 11 November)
## Reaches every foe in the fight (an attack: the Shift Whistle's lure-all), or the whole team or every machine but its own (a shield or a buff: the
## Swallowtail's Mooring Screens the latter): its targeting mode, Every Foe, Every Ally or Every
## Other Ally (4 November). Setting it on
## gives the entry the mode that reaches all it may be spent on (any foe; itself and its allies the
## whole team, its allies every other ally); off, the one target it may be dropped on.
var reaches_all: bool:
	get:
		return reach == Reach.EVERY_FOE or targets == Target.EVERY_ALLY or targets == Target.EVERY_OTHER_ALLY
	set(on):
		if kind == Kind.ATTACK:
			if on:
				reach = Reach.EVERY_FOE
			elif reach == Reach.EVERY_FOE:
				reach = Reach.INDIRECT
		elif kind != Kind.BLANK:
			if on and targets == Target.SELF_ALLY:
				targets = Target.EVERY_ALLY
			elif on and targets == Target.ALLY:
				targets = Target.EVERY_OTHER_ALLY
			elif not on and targets == Target.EVERY_ALLY:
				targets = Target.SELF_ALLY
			elif not on and targets == Target.EVERY_OTHER_ALLY:
				targets = Target.ALLY
var gathers_mines: bool = false   # an attack: every Mine on the field's other foes joins its target's (the Lammergeier's Lorentz Contractor, Ryan, 9 November)
var detonates: bool = false   # an attack: its target's Mine blows now, on it and every foe round it, after the spend's own Mine joined it (the Lammergeier's Syrinx Drone, Ryan, 9 November)
# The Swallowtail's locked pieces (Ryan's go, 21 October; built that day):
var vents: int = 0            # a shield: the heat it also takes off the machine it shields, first (the Sutler's Hoist)
var fills_shield: bool = false   # a shield: it fills the machine's shield to its maximum (the Hoist's charged form)
var cools_all: bool = false   # a shield: it takes the machine's heat to nothing first (the Hoist's charged form)
var not_acted: bool = false   # a buff reaching every ally: only those yet to act this round gain it (the Mooring Screens' Phased)
var act_again: bool = false   # a buff on an ally whose die is spent: it rolls again and the ally acts again (the Reveille Horn's charged form)
var charged: Dictionary = {}  # a locked piece's charged form, what a muster buys (read by charged_form)
# The Musk Ox's (Ryan's go, 21 October; built that day):
var ammo_per_foe_hit: int = 0 # an attack: ammo back to its forging machine for every foe its blows reach (the Shrapnel Recuperator)
var spends_magazine: bool = false   # an attack: the whole magazine its price (the Unrestricted Expenditure)
var magazine_min: int = 0     # with spends_magazine: the ammo the magazine must hold for it to fire (Ryan, 12 November: "needing 8 heat/ammo to fire their specials"); 0 for any
var split: int = 1            # the effective entry only, never printed: each roll serves this many strikes at its number divided among them, rounded down (the Skua's Split-cycle Breech; Effects.split_of)
var reloads_ammo: int = 0     # a vent: ammo it adds to its forging machine as it is spent (the quick reload; the Forge counts it as no vent)
var ammo: int = 0             # shown only: what a forging machine's gun costs it in ammo now (Skirmish.shown_face), its heat slot's place on the die
var dry: bool = false         # shown only: the magazine cannot pay that price, so the gun cannot be spent
# What a spend at a foe lays on its own machine: each {status, stacks, per_foe, cap}, a machine
# buff, its stacks once or once for every foe the spend reached, up to the cap it names (0 for
# none). Printed on a piece (the Hardlight Pulse's Hardened Light 1, up to 3: Ryan, 18 November)
# and taken further on the entry as spent by an upgrade's branch (Effects.self_grants).
var self_statuses: Array = []
# The Giant Petrel's locked pieces (Ryan's go, 21 October; built 30 October):
var action_price: int = 0     # a buff: on an ally whose die is spent, the team's rerolls it pays, and the ally's die rolls again, never onto the entry it showed, and it acts again (the Immelmann Booster); on itself, its status
var rolls_target: bool = false   # a buff: the die of the machine it lands on rolls again, never onto the entry showing; nothing on a spent die (the Reheat Uplink)
var kill_rerolls: int = 0     # an attack: if its spend kills, the team gains this many rerolls this round, banked if unspent (the Spindrift Salvo)
var tags: Array[String] = []  # its component's tags (10 October): build flavour that never carries a rule; a passive may read one


## `kws` may be a single Keyword or an Array of them.
static func attack(pwr: int, rch: int = Reach.DIRECT, kws = [], ht: int = 0) -> Face:
	var f := Face.new()
	f.kind = Kind.ATTACK
	f.targets = Target.FOE
	f.reach = rch
	f.power = pwr
	f.heat = ht
	if kws is Array:
		for k in kws:
			f.add_keyword(k)
	else:
		f.add_keyword(kws)
	return f


static func shield(pwr: int) -> Face:
	var f := Face.new()
	f.kind = Kind.SHIELD
	f.reach = Reach.NONE
	f.power = pwr
	return f


static func vent(pwr: int) -> Face:
	var f := Face.new()
	f.kind = Kind.VENT
	f.reach = Reach.NONE
	f.power = pwr
	return f


## A buff (decided 29 September): equipment that grants `status` to the machine it is spent
## on, `stacks` deep, through the end of `rounds` rounds. The status names what it does.
static func buff(status: String, stacks: int = 1, rounds: int = 1) -> Face:
	var f := Face.new()
	f.kind = Kind.BUFF
	f.reach = Reach.NONE
	f.power = 0
	f.buff_status = status
	f.buff_stacks = maxi(1, stacks)
	f.buff_rounds = maxi(1, rounds)
	return f


static func blank() -> Face:
	var f := Face.new()
	f.kind = Kind.BLANK
	f.reach = Reach.NONE
	f.power = 0
	return f


## What the die shows while an entry is disabled: blank, but still that component's slot.
static func disabled_stand_in(original: Face) -> Face:
	var f := blank()
	f.disabled = true
	f.component = original.component
	f.fixed = original.fixed
	return f


## A hardpoint with nothing in it: an entry on the die that does nothing when it comes up.
static func empty_slot() -> Face:
	var f := blank()
	f.empty = true
	return f


static func keyword_from_name(name: String) -> int:
	for k in KEYWORD_NAMES.keys():
		if KEYWORD_NAMES[k] == name:
			return k
	return -1


static func kind_from_name(name: String) -> int:
	for k in KIND_NAMES.keys():
		if KIND_NAMES[k] == name:
			return k
	return -1


static func reach_from_name(name: String) -> int:
	for r in REACH_NAMES.keys():
		if REACH_NAMES[r] == name:
			return r
	return -1


## A reach as text reads it (every foe, not every_foe).
static func reach_label(r: int) -> String:
	return str(REACH_NAMES.get(r, "")).replace("_", " ")


static func target_from_name(name: String) -> int:
	for t in TARGET_NAMES.keys():
		if TARGET_NAMES[t] == name:
			return t
	return -1


## Build from content JSON: {"kind": "attack", "reach": "direct", "power": 20,
## "keywords": ["cleave"], "heat": 10}. Unknown names are ignored here; the
## content validator reports them.
static func from_dict(d: Dictionary) -> Face:
	var f := Face.new()
	var k := kind_from_name(str(d.get("kind", "attack")))
	f.kind = k if k >= 0 else Kind.ATTACK
	var r := reach_from_name(str(d.get("reach", "direct" if f.kind == Kind.ATTACK else "none")))
	f.reach = r if r >= 0 else Reach.NONE
	f.power = int(d.get("power", 0))
	f.heat = int(d.get("heat", 0))
	f.strikes = maxi(1, int(d.get("strikes", 1)))
	if f.kind == Kind.ATTACK:
		f.targets = Target.FOE
	else:
		var t := target_from_name(str(d.get("targets", "self_ally")))
		f.targets = t if t >= 0 and t != Target.FOE else Target.SELF_ALLY
	if f.kind == Kind.BUFF:
		f.buff_status = str(d.get("status", ""))
		f.buff_stacks = maxi(1, int(d.get("stacks", 1)))
		f.buff_rounds = maxi(1, int(d.get("rounds", 1)))
		f.disrupts_attackers = bool(d.get("disrupts_attackers", false))
		var front = d.get("in_front", {})
		if front is Dictionary and not front.is_empty():
			f.front_status = str(front.get("status", ""))
			f.front_stacks = maxi(1, int(front.get("stacks", 1)))
		# A buff that spends a count of its machine's for its stacks (the Quintessence Tap): the most it
		# spends is the most it grants, and a save's `stacks` beside it says no more than that.
		f.spends = str(d.get("spends", ""))
		if not f.spends.is_empty():
			f.spends_up_to = maxi(1, int(d.get("spends_up_to", 1)))
			f.buff_stacks = f.spends_up_to
		# A buff that passes its machine's heat for its stacks (the Puffin's dump): as built it grants
		# none, its stacks what the heat passed makes, and a save's `stacks` beside it says what it showed.
		f.passes_heat = bool(d.get("passes_heat", false))
		if f.passes_heat:
			f.heat_per_stack = maxi(1, int(d.get("heat_per_stack", 1)))
			f.buff_stacks = maxi(0, int(d.get("stacks", 0)))
	f.holds_all = str(d.get("holds_all", ""))
	if f.kind == Kind.ATTACK:
		f.vents_all = bool(d.get("vents_all", false))
		f.power_per_heat = maxi(0, int(d.get("power_per_heat", 0))) if f.vents_all else 0
		f.per_heat = maxi(1, int(d.get("per_heat", 10)))
		f.spends_shield = bool(d.get("spends_shield", false))
		f.power_per_shield = maxi(0, int(d.get("power_per_shield", 0))) if f.spends_shield else 0
		f.per_shield = maxi(1, int(d.get("per_shield", 2)))
		f.power_per_missing = maxi(0, int(d.get("power_per_missing", 0)))
		f.per_missing = maxi(1, int(d.get("per_missing", 20)))
		f.finisher = maxi(0, int(d.get("finisher", 0)))
		f.fills_hopper = maxi(0, int(d.get("fills_hopper", 0)))
		f.ablate = maxi(0, int(d.get("ablate", 0)))   # add_keyword gives an Ablate entry one stack when it says none
		f.cryo = maxi(0, int(d.get("cryo", 0)))
		f.brittle = maxi(0, int(d.get("brittle", 0)))
		f.sap = maxi(0, int(d.get("sap", 0)))
		f.cleave = maxi(0, int(d.get("cleave", 0)))   # add_keyword gives an area keyword a number of one when it says none
		f.penetrate = maxi(0, int(d.get("penetrate", 0)))
		f.chain = maxi(0, int(d.get("chain", 0)))   # add_keyword gives Chain a number of one when it says none
		f.dispel = maxi(0, int(d.get("dispel", 0)))   # Purge N (2 November); one when it says none
		var g = d.get("gates", {})
		f.gates = (g as Dictionary).duplicate(true) if g is Dictionary else {}
		f.consumes = str(d.get("consumes", ""))
		f.holds = str(d.get("holds", ""))
		f.per_consumed = maxi(1, int(d.get("per_consumed", 1)))
		f.self_ablate = maxi(0, int(d.get("self_ablate", 0)))
		f.ignores_armour = d.get("ignores_armour", false) is bool and d.get("ignores_armour", false)
		f.swaps = d.get("swaps", false) is bool and d.get("swaps", false)
		f.webs = d.get("webs", false) is bool and d.get("webs", false)
		f.fires_hopper = maxi(0, int(d.get("fires_hopper", 0)))
		f.power_per_load = maxi(0, int(d.get("power_per_load", 0))) if f.fires_hopper > 0 else 0
	f.braces = maxi(0, int(d.get("braces", 0)))
	f.volatile = maxi(0, int(d.get("volatile", 0)))
	f.shield_cost = maxi(0, int(d.get("shield_cost", 0)))
	f.cooldown = maxi(0, int(d["cooldown"])) if d.has("cooldown") else -1
	f.turns_die = bool(d.get("turns_die", false)) and f.kind == Kind.BUFF
	f.team_rerolls = maxi(0, int(d.get("team_rerolls", 0))) if f.kind == Kind.BUFF else 0
	f.gathers_mines = bool(d.get("gathers_mines", false)) and f.kind == Kind.ATTACK
	f.detonates = bool(d.get("detonates", false)) and f.kind == Kind.ATTACK
	f.vents = maxi(0, int(d.get("vents", 0))) if f.kind == Kind.SHIELD and not (d.get("vents") is String) else 0
	f.fills_shield = bool(d.get("fills_shield", false)) and f.kind == Kind.SHIELD
	f.cools_all = bool(d.get("cools_all", false)) and f.kind == Kind.SHIELD
	f.not_acted = bool(d.get("not_acted", false)) and f.kind == Kind.BUFF
	f.act_again = bool(d.get("act_again", false)) and f.kind == Kind.BUFF
	var cd = d.get("charged", {})
	f.charged = (cd as Dictionary).duplicate(true) if cd is Dictionary else {}
	f.ammo_per_foe_hit = maxi(0, int(d.get("ammo_per_foe_hit", 0))) if f.kind == Kind.ATTACK else 0
	f.spends_magazine = bool(d.get("spends_magazine", false)) and f.kind == Kind.ATTACK
	f.magazine_min = maxi(0, int(d.get("magazine_min", 0))) if f.spends_magazine else 0
	f.reloads_ammo = maxi(0, int(d.get("reloads_ammo", 0))) if f.kind != Kind.ATTACK and f.kind != Kind.BLANK else 0
	var deal = d.get("ally_action", {})
	f.action_price = maxi(0, int((deal as Dictionary).get("rerolls", 0))) if f.kind == Kind.BUFF and deal is Dictionary else 0
	f.rolls_target = bool(d.get("rolls_target", false)) and f.kind == Kind.BUFF
	f.kill_rerolls = maxi(0, int(d.get("kill_rerolls", 0))) if f.kind == Kind.ATTACK else 0
	if f.kind == Kind.ATTACK and d.get("self_statuses", null) is Array:
		for g in d["self_statuses"]:
			if g is Dictionary and not str(g.get("status", "")).is_empty():
				f.self_statuses.append({"status": str(g["status"]), "stacks": maxi(1, int(g.get("stacks", 1))), "per_foe": bool(g.get("per_foe", false)), "cap": maxi(0, int(g.get("cap", 0)))})
	for name in d.get("keywords", []):
		var kw := keyword_from_name(str(name))
		if kw > 0:
			f.add_keyword(kw)
	return f


func to_dict() -> Dictionary:
	var names: Array[String] = []
	for k in keywords:
		names.append(KEYWORD_NAMES[k])
	var d := {
		"kind": KIND_NAMES[kind], "reach": REACH_NAMES[reach], "power": power,
		"keywords": names, "heat": heat,
	}
	if strikes > 1:
		d["strikes"] = strikes
	if kind != Kind.ATTACK and targets != Target.SELF_ALLY:
		d["targets"] = TARGET_NAMES[targets]
	if kind == Kind.BUFF:
		d["status"] = buff_status
		d["stacks"] = buff_stacks
		d["rounds"] = buff_rounds
		if not front_status.is_empty():
			d["in_front"] = {"status": front_status, "stacks": front_stacks}
		if not spends.is_empty():
			d["spends"] = spends
			d["spends_up_to"] = spends_up_to
		if passes_heat:
			d["passes_heat"] = true
			d["heat_per_stack"] = heat_per_stack
	if not holds_all.is_empty():
		d["holds_all"] = holds_all
	if vents_all:
		d["vents_all"] = true
		if power_per_heat > 0:
			d["power_per_heat"] = power_per_heat
			d["per_heat"] = per_heat
	if spends_shield:
		d["spends_shield"] = true
		if power_per_shield > 0:
			d["power_per_shield"] = power_per_shield
			d["per_shield"] = per_shield
	if power_per_missing > 0:
		d["power_per_missing"] = power_per_missing
		d["per_missing"] = per_missing
	if finisher > 1:
		d["finisher"] = finisher
	if ablate > 0 and has(Keyword.ABLATE):
		d["ablate"] = ablate
	if cryo > 0 and has(Keyword.CRYO):
		d["cryo"] = cryo
	if brittle > 0 and has(Keyword.BRITTLE):
		d["brittle"] = brittle
	if sap > 0 and has(Keyword.SAP):
		d["sap"] = sap
	if disrupts_attackers:
		d["disrupts_attackers"] = true
	if not is_debuff():
		for kw in AREA_KEYWORDS:
			if has(kw) and number_of(kw) > 0:
				d[NUMBER_FIELDS[kw]] = number_of(kw)   # a debuff's area deals nothing, so it prints no number
		if has(Keyword.CHAIN) and chain > 0:
			d["chain"] = chain
	if has(Keyword.DISPEL) and dispel > 0:
		d["dispel"] = dispel
	if volatile > 0:
		d["volatile"] = volatile
	if shield_cost > 0:
		d["shield_cost"] = shield_cost
	if not gates.is_empty():
		d["gates"] = gates.duplicate(true)
	if not holds.is_empty():
		d["holds"] = holds
	if not consumes.is_empty():
		d["consumes"] = consumes
		d["per_consumed"] = per_consumed
	if self_ablate > 0:
		d["self_ablate"] = self_ablate
	if ignores_armour:
		d["ignores_armour"] = true
	if swaps:
		d["swaps"] = true
	if webs:
		d["webs"] = true
	if fills_hopper > 0:
		d["fills_hopper"] = fills_hopper
	if fires_hopper > 0:
		d["fires_hopper"] = fires_hopper
		d["power_per_load"] = power_per_load
	if braces > 0:
		d["braces"] = braces
	if cooldown >= 0:
		d["cooldown"] = cooldown
	if turns_die:
		d["turns_die"] = true
	if team_rerolls > 0:
		d["team_rerolls"] = team_rerolls
	if gathers_mines:
		d["gathers_mines"] = true
	if detonates:
		d["detonates"] = true
	if vents > 0:
		d["vents"] = vents
	if fills_shield:
		d["fills_shield"] = true
	if cools_all:
		d["cools_all"] = true
	if not_acted:
		d["not_acted"] = true
	if act_again:
		d["act_again"] = true
	if not charged.is_empty():
		d["charged"] = charged.duplicate(true)
	if ammo_per_foe_hit > 0:
		d["ammo_per_foe_hit"] = ammo_per_foe_hit
	if spends_magazine:
		d["spends_magazine"] = true
	if magazine_min > 0:
		d["magazine_min"] = magazine_min
	if reloads_ammo > 0:
		d["reloads_ammo"] = reloads_ammo
	if action_price > 0:
		d["ally_action"] = {"rerolls": action_price}
	if rolls_target:
		d["rolls_target"] = true
	if kill_rerolls > 0:
		d["kill_rerolls"] = kill_rerolls
	if not self_statuses.is_empty():
		d["self_statuses"] = self_statuses.duplicate(true)
	return d


func add_keyword(kw: int) -> void:
	if kw > Keyword.NONE and not keywords.has(kw):
		keywords.append(kw)
	if kw == Keyword.ABLATE and ablate <= 0:
		ablate = 1   # an Ablate entry says its stacks; one when nothing says (a synthetic entry, an old save)
	if kw == Keyword.CRYO and cryo <= 0:
		cryo = 1
	if kw == Keyword.BRITTLE and brittle <= 0:
		brittle = 1
	if kw == Keyword.SAP and sap <= 0:
		sap = 1
	if kw == Keyword.DISPEL and dispel <= 0:
		dispel = 1   # Purge says its number; one when nothing says
	if (AREA_KEYWORDS.has(kw) or kw == Keyword.CHAIN) and int(get(NUMBER_FIELDS[kw])) <= 0:
		set(NUMBER_FIELDS[kw], 1)   # an area keyword or Chain says its number; one when nothing says (a synthetic entry, an old save)


func has(kw: int) -> bool:
	return keywords.has(kw)


## The number a numbered keyword carries here (Ablate's stacks, Spread's blow), 0 for a keyword
## it does not carry or one with no number.
func number_of(kw: int) -> int:
	var field: String = NUMBER_FIELDS.get(kw, "")
	return int(get(field)) if not field.is_empty() and has(kw) else 0


## Sets a numbered keyword's number, never below nothing.
func set_number(kw: int, n: int) -> void:
	var field: String = NUMBER_FIELDS.get(kw, "")
	if not field.is_empty():
		set(field, maxi(0, n))


## Area by shape (Ryan, 11 and 12 October; numbered 28 October): the row, the foes beside the
## target in its rank, is Spread's; the column, the other rank of its column, Penetrate's.
func reaches_row() -> bool:
	return has(Keyword.CLEAVE)


func reaches_column() -> bool:
	return has(Keyword.PENETRATE)


func has_area() -> bool:
	return reaches_row() or reaches_column()


## The number a foe the row reaches takes as its blow's: Spread's.
func row_number() -> int:
	return number_of(Keyword.CLEAVE)


## The number the column's foe takes: Penetrate's.
func column_number() -> int:
	return number_of(Keyword.PENETRATE)


## The rounds this entry sits out once spent, after the round of the spend (the cooldown row:
## Ryan, 14 October, counted so since 12 November): what it prints, a cost the die shows by its
## clock; none when it prints none. Rapid's own switch-off, dark for the rest of the round, is
## the keyword's and never counted here (Ryan, 12 November: "rapid gets its innate cooldown zero
## back without the explicit display").
func cooldown_rounds() -> int:
	return maxi(cooldown, 0)


## Does spending this entry give its machine its turn back (Rapid or Instant)?
func acts_again() -> bool:
	return has(Keyword.RAPID) or has(Keyword.INSTANT)


## A rule printed on the entry rather than a keyword (bible section 6: the die's star chip):
## Vents all, the missing-hull bonus, the hopper, the brace, a count it spends for its stacks or
## a status it holds on every unit (the Quintessence Tap's), the heat it passes (the Puffin's dump). A roll that may land on itself is Instant's, a
## keyword since 12 November, never the star. A cooldown is a cost the die prints with its clock, a reload the ammo the die
## prints with its shells (Ryan, 2 November), and a shield's cooling the number under its steam
## (3 November), so none of them is.
func has_unique_rule() -> bool:
	return vents_all or spends_shield or power_per_missing > 0 or finisher > 1 or not gates.is_empty() or not consumes.is_empty() or not holds.is_empty() or not front_status.is_empty() or disrupts_attackers or self_ablate > 0 or ignores_armour or swaps or webs or spills or fills_hopper > 0 or fires_hopper > 0 or braces > 0 \
		or turns_die or team_rerolls > 0 or gathers_mines or detonates \
		or fills_shield or cools_all or act_again or not charged.is_empty() \
		or ammo_per_foe_hit > 0 or spends_magazine \
		or not self_statuses.is_empty() or action_price > 0 or rolls_target or kill_rerolls > 0 \
		or not spends.is_empty() or not holds_all.is_empty() or passes_heat


## Whether the entry prints a cooldown: one round or more.
func printed_cooldown() -> bool:
	return cooldown > 0


func is_attack() -> bool:
	return kind == Kind.ATTACK


## Does the entry shield the machine it lands on: a shield. A shield that cools is a shield and a
## vent at once (Ryan, 8 November: "The venting shield is both types at once"); a vent that also
## shielded left with the Wake Diffuser, its last piece (19 November).
func shields_machine() -> bool:
	return kind == Kind.SHIELD


## Does the entry cool the machine it lands on: a vent (the quick reload's, which cools nothing,
## is a vent all the same), or a shield that cools too (the Sutler's Hoist)?
func cools_machine() -> bool:
	return kind == Kind.VENT or (kind == Kind.SHIELD and (vents > 0 or cools_all))


## A weapon (Ryan, 26 October): an attack that deals damage, spent on a foe within its reach.
## Its hits are what "hitting a foe with a weapon" reads, a blow of 0 included.
func is_weapon() -> bool:
	return kind == Kind.ATTACK and not is_debuff()


## A debuff (Ryan, 20 and 21 October, the die's kinds): equipment aimed at a foe, dealing no
## damage (26 October: a weapon deals damage; a buff or a debuff is equipment), the setters and
## the swap, whatever its keywords. It prints no number and deals none under any effect
## (Effects.attack holds it at nothing), its heat paid as a weapon's and its keywords its whole
## effect; the die draws its reach frame with the status mark inside. A gun whose blow is
## nothing here (its 5 against armour 5) is no debuff: it prints "0".
func is_debuff() -> bool:
	return kind == Kind.ATTACK and power <= 0 and not vents_all and not spends_shield and fires_hopper <= 0 and power_per_missing <= 0


## Equipment (Ryan, 26 October: "the label for all 4 forms of buff and debuff faces"): a buff,
## spent on a machine, or a debuff, spent on a foe; it deals no damage.
func is_equipment() -> bool:
	return kind == Kind.BUFF or is_debuff()


## Spent on a machine (itself, an ally, or either, as it says): a shield, a vent or a buff.
func on_machines() -> bool:
	return kind == Kind.SHIELD or kind == Kind.VENT or kind == Kind.BUFF


func can_target_self() -> bool:
	return on_machines() and (targets == Target.SELF_ALLY or targets == Target.SELF or targets == Target.EVERY_ALLY)


func can_target_ally() -> bool:
	return on_machines() and (targets == Target.SELF_ALLY or targets == Target.ALLY or targets == Target.EVERY_ALLY or targets == Target.EVERY_OTHER_ALLY)


## What this blow adds against `target` for the hull it is missing (power_per_missing), read
## as the die is spent: a known number, so the face is still flat. Nothing without a target.
func missing_bonus(target) -> int:
	if power_per_missing <= 0 or target == null:
		return 0
	return power_per_missing * int(maxi(0, int(target.hp_max) - int(target.hp)) / maxi(1, per_missing))


## Does this entry's finish hold against `target` (finisher: its number multiplied against a foe
## at half its HP or less)? `hp` is the HP its hit judged the foe at, the foe's own when none is
## given (a forecast, the die held over it).
func finishes(target, hp: int = -1) -> bool:
	if finisher <= 1 or target == null or target.get("hp_max") == null:
		return false
	return (hp if hp >= 0 else int(target.hp)) * 2 <= int(target.hp_max)


## What this blow adds against `target` for the stacks it consumes (the Backdraft Charge's
## Ablating, 22 October): a point a stack, per_consumed each, read as the die is spent and
## added before the multiplies; nothing without a target or a status to eat.
func consume_bonus(target) -> int:
	if consumes.is_empty() or target == null:
		return 0
	return per_consumed * Effects.stacks_of(target, consumes)


func duplicate_face() -> Face:
	var f := Face.new()
	f.kind = kind
	f.reach = reach
	f.power = power
	f.heat = heat
	f.strikes = strikes
	f.component = component
	f.empty = empty
	f.fixed = fixed
	f.disabled = disabled
	f.targets = targets
	f.buff_status = buff_status
	f.buff_stacks = buff_stacks
	f.buff_rounds = buff_rounds
	f.front_status = front_status
	f.front_stacks = front_stacks
	f.vents_all = vents_all
	f.spends_shield = spends_shield
	f.power_per_shield = power_per_shield
	f.per_shield = per_shield
	f.power_per_heat = power_per_heat
	f.per_heat = per_heat
	f.power_per_missing = power_per_missing
	f.per_missing = per_missing
	f.finisher = finisher
	f.spends = spends
	f.spends_up_to = spends_up_to
	f.passes_heat = passes_heat
	f.heat_per_stack = heat_per_stack
	f.holds_all = holds_all
	f.ablate = ablate
	f.cryo = cryo
	f.brittle = brittle
	f.sap = sap
	f.disrupts_attackers = disrupts_attackers
	f.cleave = cleave
	f.penetrate = penetrate
	f.chain = chain
	f.dispel = dispel
	f.volatile = volatile
	f.shield_cost = shield_cost
	f.short = short
	f.gates = gates.duplicate(true)
	f.consumes = consumes
	f.holds = holds
	f.per_consumed = per_consumed
	f.self_ablate = self_ablate
	f.ignores_armour = ignores_armour
	f.swaps = swaps
	f.webs = webs
	f.spills = spills
	f.fills_hopper = fills_hopper
	f.fires_hopper = fires_hopper
	f.power_per_load = power_per_load
	f.braces = braces
	f.cooldown = cooldown
	f.turns_die = turns_die
	f.team_rerolls = team_rerolls
	f.gathers_mines = gathers_mines
	f.detonates = detonates
	f.vents = vents
	f.fills_shield = fills_shield
	f.cools_all = cools_all
	f.not_acted = not_acted
	f.act_again = act_again
	f.charged = charged.duplicate(true)
	f.ammo_per_foe_hit = ammo_per_foe_hit
	f.spends_magazine = spends_magazine
	f.magazine_min = magazine_min
	f.split = split
	f.reloads_ammo = reloads_ammo
	f.ammo = ammo
	f.dry = dry
	f.self_statuses = self_statuses.duplicate(true)
	f.action_price = action_price
	f.rolls_target = rolls_target
	f.kill_rerolls = kill_rerolls
	f.tags = tags.duplicate()
	for k in keywords:
		f.keywords.append(k)
	return f


## The entry's charged form, what a muster buys (the Swallowtail's locked pieces, Ryan's go of
## 21 October): the plain entry as its `charged` draft rewrites it, a status reaching every ally
## (the Screens' Phased on those yet to act), keywords added (the Flare's Suppress), the full
## reset (the Hoist: the shield filled, the heat to nothing, a cleanse) or an ally acting again
## (the Horn); null for an entry with none.
func charged_form() -> Face:
	if charged.is_empty():
		return null
	var c := duplicate_face()
	c.charged = {}
	if charged.has("status"):
		c.kind = Kind.BUFF
		c.reach = Reach.NONE
		c.buff_status = str(charged["status"])
		c.buff_stacks = maxi(1, int(charged.get("stacks", 1)))
		c.buff_rounds = maxi(1, int(charged.get("rounds", 1)))
		c.power = 0
		c.vents = 0
		c.reaches_all = bool(charged.get("reaches_all", reaches_all))
		c.not_acted = bool(charged.get("not_acted", false))
	if str(charged.get("act_again", "")) == "ally":
		c.kind = Kind.BUFF
		c.buff_status = ""
		c.team_rerolls = 0   # the charged form is the act-again alone
		c.act_again = true
		c.targets = Target.ALLY
	if str(charged.get("shield", "")) == "full":
		c.fills_shield = true
	if str(charged.get("vents", "")) == "all":
		c.cools_all = true
		c.vents = 0
	if bool(charged.get("cleanse", false)):
		c.add_keyword(Keyword.CLEANSE)
	for name in charged.get("keywords", []):
		var kw := keyword_from_name(str(name))
		if kw > 0:
			c.add_keyword(kw)
	return c


## The musters a charged spend costs (one unless the draft says more).
func muster_price() -> int:
	return maxi(1, int(charged.get("muster", 1)))


## The store a charged spend draws on (the Nemesis's rage since 11 November, Ryan: "its rage is
## consumed in chunks of 5"): the Muster unless the draft names another store, a status tagged one.
func charge_store() -> String:
	return str(charged.get("store", "muster"))


## What a charged spend costs from its store: musters for the Muster (each its rule's points),
## stacks for any other store (`price`, one unless the draft says more).
func charge_price() -> int:
	if charge_store() == "muster":
		return muster_price()
	return maxi(1, int(charged.get("price", 1)))


## The entry's costs past heat as its text says them (Ryan, 26 October: Volatile a cost like
## heat, and a cost may be shield): the hull a spend bites, the shield it takes first.
func cost_text() -> String:
	return (" (-%d hull)" % volatile if volatile > 0 else "") + (" (-%d shield)" % shield_cost if shield_cost > 0 else "")


## The rules an entry prints past its number, its reach, whom it is spent on and its keywords,
## one phrase each in describe()'s own words (a test holds every phrase to describe()): the
## die's hold lists them a line each, last (Ryan, 25 October: "unique effects last"). A reload
## with no vent of its own is that vent's number, and a shield's cooling a number the die prints
## beside its shield's (3 November), so neither is a rule.
func rule_phrases() -> Array[String]:
	var out: Array[String] = []
	if kind == Kind.BLANK:
		return out
	if kind == Kind.ATTACK:
		if vents_all:
			out.append("vents all" + (", +%d per %d heat" % [power_per_heat, per_heat] if power_per_heat > 0 else ""))
		if spends_shield:
			out.append("fires the shield" + (", +%d per %d shield" % [power_per_shield, per_shield] if power_per_shield > 0 else ""))   # its term's name, so the readout links it
		if power_per_missing > 0:
			out.append("+%d per %d HP missing" % [power_per_missing, per_missing])
		if finisher > 1:
			out.append("×%d on a foe at half its HP or less" % finisher)
		if not consumes.is_empty():
			out.append("consumes %s, +%d a stack" % [str(Effects.STATUS.get(consumes, {}).get("name", consumes)), per_consumed])
		if not holds.is_empty():
			out.append("its target's %s does not decay this round" % str(Effects.STATUS.get(holds, {}).get("name", holds)))
		if ignores_armour:
			out.append("ignores armour")
		if swaps:
			out.append(SWAPS_TEXT)
		if webs:
			out.append(WEBS_TEXT)
		if self_ablate > 0:
			out.append("Ablating %d on itself" % self_ablate)
		if fills_hopper > 0:
			out.append("fills the hopper" + ("" if fills_hopper == 1 else " ×%d" % fills_hopper))
		if fires_hopper > 0:
			out.append("fires the hopper, +%d a load (%d a shot)" % [power_per_load, fires_hopper])
	elif cools_all:
		out.append("cools to nothing")
	if braces > 0:
		out.append("braces" + ("" if braces == 1 else " ×%d" % braces))
	if kind == Kind.ATTACK:
		if gathers_mines:
			out.append("gathers every Mine onto it")
		if detonates:
			out.append("detonates its Mine")
		if spends_magazine:
			out.append("empties the magazine, %d ammo or more" % magazine_min if magazine_min > 1 else "empties the magazine")
		if ammo_per_foe_hit > 0:
			out.append("+%d ammo a foe hit" % ammo_per_foe_hit)
		if kill_rerolls > 0:
			out.append(_kill_rerolls_text())
		if not self_statuses.is_empty():
			out.append(_self_text())
	else:
		if team_rerolls > 0:
			out.append(_team_rerolls_text())
		if action_price > 0:
			out.append(_action_text())
		if rolls_target:
			out.append("its die rolls again")
		if not front_status.is_empty():
			out.append(front_text())
		if disrupts_attackers:
			out.append(DISRUPTS_TEXT)
		if not spends.is_empty():
			out.append(_spends_text())
		if passes_heat:
			out.append(passes_text())
	if not holds_all.is_empty():
		out.append(_holds_all_text())
	if not charged.is_empty():
		out.append("%s: %s" % [charge_cost_text(), charged_form().describe()])
	return out


## The Petrels' rules as the entry's text says them (built 30 October): the Salvo's kill rider,
## the Regenerator's rider on its own spender, the Booster's price for an ally's action.
## The Retrocausal Shroud's rule as its text says it.
const DISRUPTS_TEXT := "disrupts the foes aiming at it"
## The three rules written on their one piece (15 November), as an entry's text says them: the
## Combat Translocator's, the Web Bomb's, and the spill a passive lays on its machine's weapons
## (the Overrun Gearing's, whose own line the die's readout prints: Effects.written_rules).
const SWAPS_TEXT := "its two targets trade places"
const WEBS_TEXT := "its web bursts as the round ends, suppressing it and the foe beside it"
const SPILLS_TEXT := "damage past a kill spills into the foe behind"


## What an entry lays on the foe in front of the machine it lands on, as its text says it.
func front_text() -> String:
	return "the foe in front of it gains %s ×%d" % [str(Effects.STATUS.get(front_status, {}).get("name", front_status)), front_stacks]


func _team_rerolls_text() -> String:
	return "the team gains %s" % ("a reroll" if team_rerolls == 1 else "%d rerolls" % team_rerolls)


func _kill_rerolls_text() -> String:
	return "a kill brings %d reroll%s" % [kill_rerolls, "" if kill_rerolls == 1 else "s"]


## What a spend at a foe lays on its own machine, in the codex's words: "Hardened Light 1 on itself for each
## foe reached", "Charged 2 on itself". The status's name is the vocabulary's, read off the engine's
## table so a rename follows.
func _self_text() -> String:
	var parts: Array[String] = []
	for g in self_statuses:
		var id := str(g.get("status", ""))
		var def: Dictionary = Effects.STATUS.get(id, {})
		var name := str(def.get("name", id.capitalize()))
		var one := Effects.status_stacking(def) == "renew"   # a Ward is one, whatever lays it: no number
		var cap := int(g.get("cap", 0))
		parts.append("%s on itself%s%s" % [name if one else "%s %d" % [name, int(g.get("stacks", 1))],
			" for each foe reached" if bool(g.get("per_foe", false)) else "", (", up to %d" % cap) if cap > 0 else ""])
	return ", ".join(parts)


func _action_text() -> String:
	return "on an ally whose die is spent, %d reroll%s: its die rolls again and it acts again" % [action_price, "" if action_price == 1 else "s"]


## The Quintessence Tap's two rules as the entry's text says them (Ryan, 12 November): the count it
## spends for its stacks, the most it takes and a stack a one; and the status no unit's clock runs
## down this round, either side's.
func _spends_text() -> String:
	return "consumes up to %d %s, 1 %s each" % [spends_up_to, str(Effects.STATUS.get(spends, {}).get("name", spends)), str(Effects.STATUS.get(buff_status, {}).get("name", buff_status))]


## The Puffin's dump as the entry's text says it: the heat it passes and the stacks that makes,
## its term's name first so the readout links it.
func passes_text() -> String:
	return "passes heat, %s 1 per %d heat" % [str(Effects.STATUS.get(buff_status, {}).get("name", buff_status)), heat_per_stack]


func _holds_all_text() -> String:
	var held := str(Effects.STATUS.get(holds_all, {}).get("name", holds_all))
	var flare := str(Effects.STATUS.get(str(Effects.ROUND_HOLDERS.get(holds_all, "")), {}).get("name", ""))
	return "no %s decays this round" % held if flare.is_empty() else "grants %s: no %s decays this round" % [flare, held]


## A printed cooldown as the entry's text says it, " cooldown 2"; nothing for an entry with none.
func cooldown_text() -> String:
	return " cooldown %d" % cooldown if printed_cooldown() else ""


func number_text() -> String:
	if kind == Kind.BLANK or is_debuff():
		return ""
	if kind == Kind.BUFF:
		return "" if buff_status.is_empty() else "×%d" % buff_stacks   # a buff that grants nothing (the Changeover) has no stacks to say
	if power <= 0 and reloads_ammo > 0:
		return "+%d" % reloads_ammo   # a reload (the Musk Ox's quick reload): the ammo it adds
	if split > 1:
		# A split entry (the Skua's): a strike's share of the number, rounded down.
		# A strike's share, rounded down and never below one while the number is one or more
		# (Skirmish.split_share; Ryan, 27 October).
		return str(maxi(1, power / split) if power > 0 else 0)
	return str(power)


func describe() -> String:
	var s := ""
	match kind:
		Kind.BLANK:
			if disabled:
				return "disabled"
			return "empty hardpoint" if empty else "destroyed"
		Kind.SHIELD, Kind.VENT, Kind.BUFF:
			if kind == Kind.BUFF and act_again:
				s = "an ally whose die is spent acts again"
			elif kind == Kind.BUFF and turns_die:
				s = "turns its die to its other battery"   # the Changeover's: a buff that grants nothing, its turn its whole effect
			elif kind == Kind.BUFF and team_rerolls > 0:
				s = _team_rerolls_text()   # the Horn's and the Booster's: no status, the reroll its whole effect
			elif kind == Kind.BUFF and not spends.is_empty():
				s = _spends_text()   # the Quintessence Tap's: what it grants is what it consumes, said once
			elif kind == Kind.BUFF and passes_heat:
				s = passes_text()   # the Puffin's dump: what it grants is what the heat it passes makes, said once
			elif kind == Kind.BUFF and buff_status.is_empty():
				s = ""   # a buff that grants nothing (the Retrocausal Shroud): its keywords and its rule say what it does
			elif kind == Kind.BUFF:
				var status_name := str(Effects.STATUS.get(buff_status, {}).get("name", buff_status))
				s = "%s ×%d" % [status_name, buff_stacks]
				if buff_rounds > 1:
					s += " for %d rounds" % buff_rounds
			elif fills_shield:
				s = "shield to its maximum"
			else:
				s = "%s %d" % ["shield" if kind == Kind.SHIELD else "vent", power]
			if reloads_ammo > 0:
				s += " reloads %d ammo" % reloads_ammo
			if vents > 0:
				s += " cools %d" % vents
			if cools_all:
				s += " cools to nothing"
			if targets == Target.EVERY_ALLY or targets == Target.EVERY_OTHER_ALLY:
				s += (" every ally" if targets == Target.EVERY_ALLY else " every other ally") + (" yet to act" if not_acted else "")   # its targeting mode, where its keyword stood
			for k in keywords:
				s += " " + keyword_label(k)
			if action_price > 0:
				s += " " + _action_text()   # the Immelmann Booster's ally use, after what it does on itself
			if rolls_target:
				s += " its die rolls again"   # the Reheat Uplink's roll on the machine it lands on
			if not front_status.is_empty():
				s += " " + front_text()   # the Photosphere Lance's: the foe in front of the machine it lands on
			if disrupts_attackers:
				s += " " + DISRUPTS_TEXT   # the Retrocausal Shroud's: the foes aiming at the machine it lands on
			if braces > 0:
				s += " braces" + ("" if braces == 1 else " ×%d" % braces)
			if not holds_all.is_empty():
				s += " " + _holds_all_text()
			s += cooldown_text() + cost_text()
			if targets == Target.SELF:
				s += " (self only)"
			elif targets == Target.ALLY and not reaches_all and not act_again:
				s += " (allies only)"
		_:
			# Direct is the default and goes unsaid; only indirect reach is called out. A debuff
			# has no number to say, so its reach and keywords are its whole line.
			s = " ".join(PackedStringArray([reach_label(reach) if reach != Reach.DIRECT else "", number_text()])).strip_edges()
			if strikes > 1:
				s += " ×%d" % strikes
			if swaps:
				s += " " + SWAPS_TEXT
			if webs:
				s += " " + WEBS_TEXT
			if spills:
				s += " " + SPILLS_TEXT
			for k in keywords:
				s += " " + keyword_label(k)
				if k == Keyword.ABLATE:
					s += " %d" % ablate   # a numbered keyword: the stacks each blow leaves
				if k == Keyword.CRYO:
					s += " %d" % cryo
				if k == Keyword.BRITTLE:
					s += " %d" % brittle
				if k == Keyword.SAP:
					s += " %d" % sap
				if k == Keyword.DISPEL:
					s += " %d" % maxi(1, dispel)   # Purge N: the stacks it takes off each buff (the audit's thirteenth bug, 8 November)
				if (AREA_KEYWORDS.has(k) or k == Keyword.CHAIN) and not is_debuff():
					s += " %d" % number_of(k)   # area by shape and Chain, numbered: what each foe past the target or each conductor takes (a debuff's deals nothing)
				if gates.has(KEYWORD_NAMES[k]):
					s += " (%s)" % Effects.gate_text(gates[KEYWORD_NAMES[k]])   # a gated keyword says where it lands
			if vents_all:
				s += " vents all" + (", +%d per %d heat" % [power_per_heat, per_heat] if power_per_heat > 0 else "")
			if spends_shield:
				s += " fires the shield" + (", +%d per %d shield" % [power_per_shield, per_shield] if power_per_shield > 0 else "")
			if power_per_missing > 0:
				s += " +%d per %d HP missing" % [power_per_missing, per_missing]
			if finisher > 1:
				s += " ×%d on a foe at half its HP or less" % finisher
			if not consumes.is_empty():
				s += " consumes %s, +%d a stack" % [str(Effects.STATUS.get(consumes, {}).get("name", consumes)), per_consumed]
			if not holds.is_empty():
				s += " its target's %s does not decay this round" % str(Effects.STATUS.get(holds, {}).get("name", holds))
			if ignores_armour:
				s += " ignores armour"
			if self_ablate > 0:
				s += " Ablating %d on itself" % self_ablate   # the Stoker's: its own machine set ablating as it fires
			if fills_hopper > 0:
				s += " fills the hopper" + ("" if fills_hopper == 1 else " ×%d" % fills_hopper)
			if fires_hopper > 0:
				s += " fires the hopper, +%d a load (%d a shot)" % [power_per_load, fires_hopper]
			if braces > 0:
				s += " braces" + ("" if braces == 1 else " ×%d" % braces)
			if gathers_mines:
				s += " gathers every Mine onto it"
			if detonates:
				s += " detonates its Mine"
			if spends_magazine:
				s += (" empties the magazine, %d ammo or more" % magazine_min) if magazine_min > 1 else " empties the magazine"
			if ammo_per_foe_hit > 0:
				s += " +%d ammo a foe hit" % ammo_per_foe_hit
			if kill_rerolls > 0:
				s += " " + _kill_rerolls_text()   # the Spindrift Salvo's kill rider
			if not self_statuses.is_empty():
				s += " " + _self_text()   # what the spend lays on its own machine (the Storm Petrel's lure)
			if not holds_all.is_empty():
				s += " " + _holds_all_text()
			s += cooldown_text()
			if heat > 0:
				s += " (+%d heat)" % heat
			s += cost_text()
	if not charged.is_empty():
		# What a store buys (a muster, the Swallowtail's locked pieces; rage, the Nemesis's): the
		# charged form, after the plain.
		var cf := charged_form()
		s += " · %s: %s" % [charge_cost_text(), cf.describe()]
	return s.strip_edges()


## What a charged spend costs, as the entry prints it: "a muster" (or "N musters"), or the
## store's stacks by name ("5 rage").
func charge_cost_text() -> String:
	if charge_store() == "muster":
		return "a muster" if muster_price() == 1 else "%d musters" % muster_price()
	return "%d %s" % [charge_price(), str(Effects.STATUS.get(charge_store(), {}).get("name", charge_store())).to_lower()]

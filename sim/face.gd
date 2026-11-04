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
enum Reach { NONE, DIRECT, INDIRECT, SWEEP, EVERY_FOE }   # Sweep (Ryan, 3 November): a targeting mode, a rank picked and its filled slots walked; Every Foe (4 November), below
## Execute and Steady are retired (10 October): a threshold doubling is a hard sum hidden in
## a keyword, and a rolled weapon dealing its average is simply a flat one.
## The Soulcutter Talons' kill rule is a count printed on its one carrier (Ryan, 11 October: no
## keyword to learn; 18 October: "devour is not a thing"): `devours`, the stacks a kill gives.
## Web (18 October, the funnel-web's Web Bomb): the foe hit is Webbed, and after its action the
## web bursts into a Suppress on it and the next foe to act beside it (Skirmish._web_burst).
## Flak (Ryan's go, 19 October; built 21 October): Wainwright & Sutler's on-hit, a numbered
## keyword like Burn and Cryo; each foe hit gains that many stacks of Flak.
## Swap (the Dingo's Combat Translocator, Ryan's go of 19 October; built 21 October): the spend
## takes a second target, another foe or an empty slot, and the two trade places.
## Area by shape, numbered (Ryan, 28 October; the half retired): Spread N (id `cleave`) the
## foes beside the target in its rank, Penetrate N the other rank of its column, Splash N the
## two together (the plus round it), each foe past the target taking N as its blow's number.
## Chain N (Ryan, 28 October; the kill and repeat and the ping retired; its random charge of
## 29 October retired 3 November for the Charged primer): Shock's other payoff, every other
## Shocked foe on the field taking N as its blow's number, wherever it stands and whatever the
## gun's reach, plain, no strike being aimed at it, so its Shock stands. A weapon's alone.
## Every Foe and Every Ally are targeting modes (Ryan, 4 November: "Silence should not narrow
## targeting modes, that's why I'm switching them to targeting modes"; keywords from 2 November):
## Every Foe a reach (a debuff's, the Siphon's lure-all: dropped on any foe, it lands on every
## foe in the fight), Every Ally a `targets` (a shield's or a buff's, the Mooring Screens': spent
## on an ally, it lands on every other machine). `reaches_all` reads either.
enum Keyword { NONE, CLEAVE, PENETRATE, BURN, SUPPRESS, CHAIN, RAPID, CLEANSE, LURE, DISRUPT, SPILLOVER, OVERSHIELD, SHOCK, WEB, CRYO, FLAK, SWAP, EXPOSE, BREACH, SPLASH, DISPEL }
## Whom a component may be spent on (Ryan, 26 September): an attack (a weapon or a debuff)
## targets foes; a shield, a vent or a buff targets self and allies by default, and content may
## narrow one to self only or allies only, so the design space stays open; Every Ally (4
## November), a targeting mode, lands on every machine but its own.
enum Target { SELF_ALLY, SELF, ALLY, FOE, EVERY_ALLY }

const KIND_NAMES := {
	Kind.ATTACK: "attack", Kind.SHIELD: "shield", Kind.VENT: "vent", Kind.BLANK: "blank", Kind.BUFF: "buff",
}
const REACH_NAMES := {
	Reach.NONE: "none", Reach.DIRECT: "direct", Reach.INDIRECT: "indirect", Reach.SWEEP: "sweep", Reach.EVERY_FOE: "every_foe",
}
const KEYWORD_NAMES := {
	Keyword.NONE: "", Keyword.CLEAVE: "cleave", Keyword.PENETRATE: "penetrate", Keyword.BURN: "burn",
	Keyword.SUPPRESS: "suppress",
	Keyword.CHAIN: "chain", Keyword.RAPID: "rapid", Keyword.CLEANSE: "cleanse",
	Keyword.LURE: "lure", Keyword.DISRUPT: "disrupt",
	Keyword.SPILLOVER: "spillover", Keyword.OVERSHIELD: "overshield", Keyword.SHOCK: "shock",
	Keyword.WEB: "web", Keyword.CRYO: "cryo", Keyword.FLAK: "flak", Keyword.SWAP: "swap",
	Keyword.EXPOSE: "expose", Keyword.BREACH: "breach", Keyword.SPLASH: "splash",
	Keyword.DISPEL: "dispel",
}
## What the player reads where it differs from the content id (the vocabulary's name).
## Purge (28 October) is one id on both sides, dispel, as breach is.
const KEYWORD_LABELS := { Keyword.CLEAVE: "spread", Keyword.DISPEL: "purge" }
## The status each foe hit gains from a keyword that lays one: the die's hold lists such a
## keyword as what the spend applies on hit, after its heat (Ryan, 25 October).
const KEYWORD_STATUS := {
	Keyword.BURN: "burning", Keyword.CRYO: "cryoed", Keyword.FLAK: "flakked", Keyword.SHOCK: "shocked",
	Keyword.SUPPRESS: "suppressed", Keyword.WEB: "webbed", Keyword.EXPOSE: "exposure",
}
## The keywords that carry a number, each in the field of its name on the entry: the stacks a
## rider lays (Burn, Cryo, Flak), the blow an area keyword deals each foe past the target
## (Spread, Penetrate, Splash; Ryan, 28 October) or the blow Chain deals each conductor (Chain,
## 28 October).
const NUMBER_FIELDS := {
	Keyword.BURN: "burn", Keyword.CRYO: "cryo", Keyword.FLAK: "flak",
	Keyword.CLEAVE: "cleave", Keyword.PENETRATE: "penetrate", Keyword.SPLASH: "splash",
	Keyword.CHAIN: "chain", Keyword.DISPEL: "dispel",
}
## The area keywords (Ryan, 11 and 12 October: three shapes, three keywords; numbered 28 October).
const AREA_KEYWORDS := [Keyword.CLEAVE, Keyword.PENETRATE, Keyword.SPLASH]
const TARGET_NAMES := {
	Target.SELF_ALLY: "self_ally", Target.SELF: "self", Target.ALLY: "ally", Target.FOE: "foe", Target.EVERY_ALLY: "every_ally",
}
## Keywords that ride on a shield or vent component (spent on a machine, not a foe); every
## other keyword is an attack's, except the few that ride on anything. The validator holds
## content to this. Lure and disrupt (2 October) are attack keywords: they ride on any
## entry aimed at a foe, a weapon or equipment, whatever else it does.
## Shock (9 October) is an attack keyword too: every foe the blows reach and leave alive is
## Shocked.
const SUPPORT_KEYWORDS := [Keyword.CLEANSE, Keyword.OVERSHIELD]
## Of those, the ones only a shield may carry: overshield (5 October, the Puffin's Prow
## Projector first, rare) lets a shield pass its target's maximum, and the excess fades at the
## round's end. A vent has nothing to pass.
const SHIELD_ONLY_KEYWORDS := [Keyword.OVERSHIELD]
## Keywords about the spend itself, not its target, so any kind of component may carry
## them: rapid (on a vent or a shield too since 9 October, the Wake Diffuser first) gives the
## machine its turn back whatever the component did. Volatile rode here until 26 October, when
## it became a cost printed beside the heat (`volatile`, below), a keyword no longer.
const ANY_KEYWORDS := [Keyword.RAPID]


static func keyword_label(k: int) -> String:
	return KEYWORD_LABELS.get(k, KEYWORD_NAMES[k])

# Enum-typed members are declared as int: GDScript 4 reports a spurious "Face.Kind vs Kind"
# type mismatch when a class_name script is loaded from a headless -s runner.
var kind: int = Kind.ATTACK
var reach: int = Reach.DIRECT
var power: int = 20
var keywords: Array[int] = []
var printed: Array[int] = []  # of those, the ones a passive grants written out (the Boar's spill): drawn as the star, never a keyword chip (the stock pass, 22 October)
var heat: int = 0
var strikes: int = 1          # blows per use: a rapid-fire weapon lands many small hits (each rolls and procs on its own)
var burn: int = 0             # an attack with Burn: the stacks of Burning each blow leaves (Ryan, 18 October: a numbered keyword, never read off the damage)
var cryo: int = 0             # an attack with Cryo: the stacks of Cryo each foe it reaches gains (the Cryo Flinger, 20 October; a numbered keyword like Burn)
var flak: int = 0             # an attack with Flak: the stacks of Flak each foe hit gains (the Flakshot Repeater, 21 October; numbered like Burn)
var cleave: int = 0           # an attack with Spread: the number each foe beside its target in its rank takes as its blow's (Ryan, 28 October: Spread N, the half retired)
var penetrate: int = 0        # an attack with Penetrate: the number the other rank of its target's column takes (Penetrate N)
var splash: int = 0           # an attack with Splash: the number each foe of the plus round its target takes, the row's and the column's (Splash N)
var chain: int = 0            # an attack with Chain: the number every other Shocked foe on the field takes as its blow's (Chain N, 28 October)
var dispel: int = 0           # an attack or equipment with Purge: the stacks every buff of each foe it reaches loses (Purge N, 2 November)
var shield_cost: int = 0      # a cost (Ryan, 26 October): the shield a spend takes from its owner first, overshield included; short of it the entry cannot be played
var short: bool = false       # shown only: the shield cannot pay the entry's shield cost now (Skirmish.shown_face), struck through on the die like a dry gun
var volatile: int = 0         # a cost (Ryan, 26 October, a keyword with a chip until then): the hull a spend bites its owner, past shield and armour, before the component acts; it may wreck it (a numbered keyword since the stock pass's engine, 22 October; a constant of 10 before)
var gates: Dictionary = {}    # an attack: keyword name -> the condition it lands under, read against each foe at the spend before its own riders (the Suppression Battery's Suppress on a foe carrying Flak; the stock pass's engine, 22 October)
var consumes: String = ""     # an attack: the status it consumes on its target, every stack, a point more a stack before the multiplies (the Backdraft Charge's Burning, 22 October)...
var per_consumed: int = 1     # ...the damage a stack consumed adds
var self_burn: int = 0        # an attack: spending it sets its own machine Burning, this many stacks (the Stoker's slow fuel by decision, the stock pass's landing, 22 October)
var label: String = ""
var component: String = ""    # the component this entry is (content id); "" for an empty hardpoint
var empty: bool = false       # an empty hardpoint: blank, and nothing was ever there to break
var fixed: bool = false       # built into the chassis (no hardpoint); false means this entry is a hardpoint
var disabled: bool = false    # a stand-in for an entry a status has switched off: blank for now, the real one is untouched
var targets: int = Target.SELF_ALLY   # a shield, a vent or a buff: whom it may be spent on; an attack is always FOE
var buff_status: String = ""  # a buff: the engine status it grants (Effects.STATUS id), with...
var buff_stacks: int = 1      # ...this many stacks...
var buff_rounds: int = 1      # ...through the end of this many rounds (1: this round)
var vents_all: bool = false   # an attack that fires the machine's whole heat: the gauge is empty after the shot...
var power_per_heat: int = 0   # ...and each `per_heat` heat it fired adds this to the blow (the Afterburner Cannon, 28 September)
var per_heat: int = 10        # ...the heat a step of power_per_heat stands for (the stock pass, 22 October: a field, 10 until the content landing)
var power_per_missing: int = 0   # an attack: added for every per_missing HP its target is missing (10 October; flat, shown on the hover)...
var per_missing: int = 20     # ...the HP a step of power_per_missing stands for (the stock pass, 22 October: a field, 20 until the content landing)
var devours: int = 0          # an attack: each kill gives its owner this many stacks of Empowered (the Soulcutter Talons' rule; a keyword until 11 October, a count since 18 October)
var fills_hopper: int = 0     # an attack: loads it puts in its machine's hopper for each foe its blows reach (the Chainsaw Claw, 11 October)
var fires_hopper: int = 0     # an attack: the most loads one shot fires from the hopper...
var power_per_load: int = 0   # ...each adding this to the blow (the Bullion Fragmenter, 11 October)
var braces: int = 0           # any entry: spending it Braces its owner, this many stacks, until the round's end (the Breaching Plow, 12 October)
var rolls_again_on: String = ""   # any entry: spending it spends a stack of this status, if its owner has one, and the die rolls again (the Nemesis's fists on rage, 12 October)
var cooldown: int = -1        # any entry: the rounds it goes dark once spent, this one included (Ryan, 14 October), printed on it; -1 or 0, none (Rapid carries none of its own, 2 November)
var spins: bool = false       # a Rapid entry whose free reroll is a true spin over every entry, itself included (the Cassowary's Spin-Up: Ryan's exception to the reroll rule, 19 October)
## Reaches every foe in the fight (an attack: the Whip Scorpion's Heliographic Siphon, a
## lure-all, 20 October) or every machine but its own (a shield or a buff: the Swallowtail's
## Mooring Screens): its targeting mode, Every Foe or Every Ally (4 November), so a Silence, which
## mutes keywords, leaves it whole. Setting it on gives the entry the mode its kind takes; off,
## one foe it may be dropped on anywhere (Indirect) or one ally.
var reaches_all: bool:
	get:
		return reach == Reach.EVERY_FOE or targets == Target.EVERY_ALLY
	set(on):
		if kind == Kind.ATTACK:
			if on:
				reach = Reach.EVERY_FOE
			elif reach == Reach.EVERY_FOE:
				reach = Reach.INDIRECT
		elif kind != Kind.BLANK:
			if on:
				targets = Target.EVERY_ALLY
			elif targets == Target.EVERY_ALLY:
				targets = Target.ALLY
var heat_per_blow: int = 0    # any entry: spending it, every blow a foe lands on its owner this round adds this much heat (the Siphon's, next round's fuel)
var shields: int = 0          # a vent: the shield it also gives the machine it cools, after the vent (the combined entry, Ryan's go of 20 October: the Wake Diffuser)
var resets_on_kill: bool = false   # an attack: if its spend kills, every entry dark from a cooldown comes back and its machine acts again (the Kite's Pinion Driver, 21 October)
var pulls_mines: bool = false # an attack: every mine on the field gathers into the slot it is spent on, a foe there taking them now (the Lammergeier's Lorentz Contractor, 21 October)
var drones: bool = false      # an attack: the foe carries the Syrinx Drone; Rapid on a foe already Exposed, otherwise it Exposes (the Lammergeier's, 21 October)
# The Swallowtail's locked pieces (Ryan's go, 21 October; built that day):
var vents: int = 0            # a shield: the heat it also takes off the machine it shields, first (the Sutler's Hoist)
var fills_shield: bool = false   # a shield: it fills the machine's shield to its maximum (the Hoist's charged form)
var cools_all: bool = false   # a shield: it takes the machine's heat to nothing first (the Hoist's charged form)
var not_acted: bool = false   # a buff reaching every ally: only those yet to act this round gain it (the Mooring Screens' Phased)
var act_again: bool = false   # a buff on an ally whose die is spent: it rolls again and the ally acts again (the Reveille Horn's charged form)
var charged: Dictionary = {}  # a locked piece's charged form, what a muster buys (read by charged_form)
# The Musk Ox's (Ryan's go, 21 October; built that day):
var ammo_per_foe_hit: int = 0 # an attack: ammo back to its forging machine for every foe its blows reach (the Shrapnel Recuperator)
var spends_magazine: bool = false   # an attack: every ammo in the magazine as a strike, the magazine its price (the Unrestricted Expenditure)
var split: int = 1            # the effective entry only, never printed: each roll serves this many strikes at its number divided among them, rounded down (the Skua's Split-cycle Breech; Effects.split_of)
var reloads_ammo: int = 0     # a vent: ammo it adds to its forging machine as it is spent (the quick reload; the Forge counts it as no vent)
var ammo: int = 0             # shown only: what a forging machine's gun costs it in ammo now (Skirmish.shown_face), its heat slot's place on the die
var dry: bool = false         # shown only: the magazine cannot pay that price, so the gun cannot be spent
# The Storm Petrel's and the Giant Petrel's locked pieces (Ryan's go, 21 October; built 30 October):
var regen_shield: int = 0     # an attack: spent on a foe, its machine gains Regenerating, this much shield at the start of each round...
var regen_rounds: int = 0     # ...through this many rounds after the spend, a grant of its own (the St. Elmo's Regenerator)
var action_price: int = 0     # a buff: on an ally whose die is spent, the team's rerolls it pays, and the ally's die rolls again, never onto the entry it showed, and it acts again (the Immelmann Booster); on itself, its status
var rolls_target: bool = false   # a buff: the die of the machine it lands on rolls again, never onto the entry showing; nothing on a spent die (the Reheat Uplink)
var kill_rerolls: int = 0     # an attack: if its spend kills, the team gains this many rerolls this round, banked if unspent (the Spindrift Salvo)
var burns: int = 0            # shown only: the shield the spend burns in place of heat now (the Storm Petrel's Riot Field Generator, Skirmish.shown_face), drawn in the heat slot
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
	if name == "line" or name == "melee":
		return Reach.DIRECT   # a save from before 10 October: line was direct's name, and melee went into it
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
	if f.kind == Kind.ATTACK:
		f.vents_all = bool(d.get("vents_all", false))
		f.power_per_heat = maxi(0, int(d.get("power_per_heat", 0))) if f.vents_all else 0
		f.per_heat = maxi(1, int(d.get("per_heat", 10)))
		f.power_per_missing = maxi(0, int(d.get("power_per_missing", 0)))
		f.per_missing = maxi(1, int(d.get("per_missing", 20)))
		f.fills_hopper = maxi(0, int(d.get("fills_hopper", 0)))
		# A save or a draft from before 11 October lists devour as a keyword, and one from before
		# 18 October says `true`: each reads as the rule, a stack a kill.
		f.devours = maxi(0, int(d.get("devours", 0)))
		if Array(d.get("keywords", [])).has("devour"):
			f.devours = maxi(1, f.devours)
		f.burn = maxi(0, int(d.get("burn", 0)))   # add_keyword gives a Burn entry one stack when it says none
		f.cryo = maxi(0, int(d.get("cryo", 0)))
		f.flak = maxi(0, int(d.get("flak", 0)))
		f.cleave = maxi(0, int(d.get("cleave", 0)))   # add_keyword gives an area keyword a number of one when it says none
		f.penetrate = maxi(0, int(d.get("penetrate", 0)))
		f.splash = maxi(0, int(d.get("splash", 0)))
		f.chain = maxi(0, int(d.get("chain", 0)))   # add_keyword gives Chain a number of one when it says none
		f.dispel = maxi(0, int(d.get("dispel", 0)))   # Purge N (2 November); one when it says none
		var g = d.get("gates", {})
		f.gates = (g as Dictionary).duplicate(true) if g is Dictionary else {}
		f.consumes = str(d.get("consumes", ""))
		f.per_consumed = maxi(1, int(d.get("per_consumed", 1)))
		f.self_burn = maxi(0, int(d.get("self_burn", 0)))
		f.fires_hopper = maxi(0, int(d.get("fires_hopper", 0)))
		f.power_per_load = maxi(0, int(d.get("power_per_load", 0))) if f.fires_hopper > 0 else 0
	f.braces = maxi(0, int(d.get("braces", 0)))
	f.volatile = maxi(0, int(d.get("volatile", 0)))
	f.shield_cost = maxi(0, int(d.get("shield_cost", 0)))
	f.rolls_again_on = str(d.get("rolls_again_on", ""))
	f.cooldown = maxi(0, int(d["cooldown"])) if d.has("cooldown") else -1
	f.spins = bool(d.get("spins", false))
	f.heat_per_blow = maxi(0, int(d.get("heat_per_blow", 0)))
	f.shields = maxi(0, int(d.get("shields", 0))) if f.kind == Kind.VENT else 0
	f.resets_on_kill = bool(d.get("resets_on_kill", false)) and f.kind == Kind.ATTACK
	f.pulls_mines = bool(d.get("pulls_mines", false)) and f.kind == Kind.ATTACK
	f.drones = bool(d.get("drones", false)) and f.kind == Kind.ATTACK
	f.vents = maxi(0, int(d.get("vents", 0))) if f.kind == Kind.SHIELD and not (d.get("vents") is String) else 0
	f.fills_shield = bool(d.get("fills_shield", false)) and f.kind == Kind.SHIELD
	f.cools_all = bool(d.get("cools_all", false)) and f.kind == Kind.SHIELD
	f.not_acted = bool(d.get("not_acted", false)) and f.kind == Kind.BUFF
	f.act_again = bool(d.get("act_again", false)) and f.kind == Kind.BUFF
	var cd = d.get("charged", {})
	f.charged = (cd as Dictionary).duplicate(true) if cd is Dictionary else {}
	f.ammo_per_foe_hit = maxi(0, int(d.get("ammo_per_foe_hit", 0))) if f.kind == Kind.ATTACK else 0
	f.spends_magazine = bool(d.get("spends_magazine", false)) and f.kind == Kind.ATTACK
	f.reloads_ammo = maxi(0, int(d.get("reloads_ammo", 0))) if f.kind != Kind.ATTACK and f.kind != Kind.BLANK else 0
	var regen = d.get("regenerates", {})
	if f.kind == Kind.ATTACK and regen is Dictionary:
		f.regen_shield = maxi(0, int((regen as Dictionary).get("shield", 0)))
		f.regen_rounds = maxi(0, int((regen as Dictionary).get("rounds", 0))) if f.regen_shield > 0 else 0
	var deal = d.get("ally_action", {})
	f.action_price = maxi(0, int((deal as Dictionary).get("rerolls", 0))) if f.kind == Kind.BUFF and deal is Dictionary else 0
	f.rolls_target = bool(d.get("rolls_target", false)) and f.kind == Kind.BUFF
	f.kill_rerolls = maxi(0, int(d.get("kill_rerolls", 0))) if f.kind == Kind.ATTACK else 0
	for name in d.get("keywords", []):
		var kw := keyword_from_name(str(name))
		if kw > 0:
			f.add_keyword(kw)
	# A save from before the targeting modes (4 November) writes Every Foe or Every Ally among its
	# keywords, and one from before 2 November says `reaches_all`: either reads as the mode its kind takes.
	var old_kw: Array = d.get("keywords", [])
	if (old_kw.has("every_foe") or old_kw.has("every_ally") or bool(d.get("reaches_all", false))) and f.kind != Kind.BLANK and not f.reaches_all:
		f.reaches_all = true
	f.label = str(d.get("label", ""))
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
	if vents_all:
		d["vents_all"] = true
		if power_per_heat > 0:
			d["power_per_heat"] = power_per_heat
			d["per_heat"] = per_heat
	if power_per_missing > 0:
		d["power_per_missing"] = power_per_missing
		d["per_missing"] = per_missing
	if devours > 0:
		d["devours"] = devours
	if burn > 0 and has(Keyword.BURN):
		d["burn"] = burn
	if cryo > 0 and has(Keyword.CRYO):
		d["cryo"] = cryo
	if flak > 0 and has(Keyword.FLAK):
		d["flak"] = flak
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
	if not consumes.is_empty():
		d["consumes"] = consumes
		d["per_consumed"] = per_consumed
	if self_burn > 0:
		d["self_burn"] = self_burn
	if fills_hopper > 0:
		d["fills_hopper"] = fills_hopper
	if fires_hopper > 0:
		d["fires_hopper"] = fires_hopper
		d["power_per_load"] = power_per_load
	if braces > 0:
		d["braces"] = braces
	if not rolls_again_on.is_empty():
		d["rolls_again_on"] = rolls_again_on
	if cooldown >= 0:
		d["cooldown"] = cooldown
	if spins:
		d["spins"] = true
	if heat_per_blow > 0:
		d["heat_per_blow"] = heat_per_blow
	if shields > 0:
		d["shields"] = shields
	if resets_on_kill:
		d["resets_on_kill"] = true
	if pulls_mines:
		d["pulls_mines"] = true
	if drones:
		d["drones"] = true
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
	if reloads_ammo > 0:
		d["reloads_ammo"] = reloads_ammo
	if regen_shield > 0 and regen_rounds > 0:
		d["regenerates"] = {"status": "regenerating", "shield": regen_shield, "rounds": regen_rounds}
	if action_price > 0:
		d["ally_action"] = {"rerolls": action_price}
	if rolls_target:
		d["rolls_target"] = true
	if kill_rerolls > 0:
		d["kill_rerolls"] = kill_rerolls
	return d


func add_keyword(kw: int) -> void:
	if kw > Keyword.NONE and not keywords.has(kw):
		keywords.append(kw)
	if kw == Keyword.BURN and burn <= 0:
		burn = 1   # a Burn entry says its stacks; one when nothing says (a synthetic entry, an old save)
	if kw == Keyword.CRYO and cryo <= 0:
		cryo = 1
	if kw == Keyword.FLAK and flak <= 0:
		flak = 1
	if (AREA_KEYWORDS.has(kw) or kw == Keyword.CHAIN) and int(get(NUMBER_FIELDS[kw])) <= 0:
		set(NUMBER_FIELDS[kw], 1)   # an area keyword or Chain says its number; one when nothing says (a synthetic entry, an old save)


func has(kw: int) -> bool:
	return keywords.has(kw)


## The number a numbered keyword carries here (Burn's stacks, Spread's blow), 0 for a keyword
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
## target in its rank, is Spread's and Splash's; the column, the other rank of its column,
## Penetrate's and Splash's.
func reaches_row() -> bool:
	return has(Keyword.CLEAVE) or has(Keyword.SPLASH)


func reaches_column() -> bool:
	return has(Keyword.PENETRATE) or has(Keyword.SPLASH)


func has_area() -> bool:
	return reaches_row() or reaches_column()


## The number a foe the row reaches takes as its blow's: Spread's or Splash's, the higher when
## both are there (a grant beside a printed one).
func row_number() -> int:
	return maxi(number_of(Keyword.CLEAVE), number_of(Keyword.SPLASH))


## The number the column's foe takes: Penetrate's or Splash's, the higher when both are there.
func column_number() -> int:
	return maxi(number_of(Keyword.PENETRATE), number_of(Keyword.SPLASH))


## The rounds this entry goes dark once spent, this one included (the cooldown row, 14
## October): what it prints, a cost the die shows by its clock; none when it prints none.
func cooldown_rounds() -> int:
	return maxi(cooldown, 0)   # the entry's own, printed; Rapid carries none (Ryan, 2 November: "Rapid does not have a native Cooldown")


## A rule printed on the entry rather than a keyword (bible section 6: the die's star chip):
## Vents all, the missing-hull bonus, the talons' kill rule, the hopper, the brace, rolling
## again on a status (the Nemesis's rage), a spin (the Spin-Up's), the Siphon's heat a blow, or a
## labelled effect. A cooldown is a cost the die prints with its clock, a reload the ammo the die
## prints with its shells (Ryan, 2 November), and a shield's cooling the number under its steam
## (3 November), so none of them is.
func has_unique_rule() -> bool:
	return vents_all or power_per_missing > 0 or not gates.is_empty() or not consumes.is_empty() or self_burn > 0 or devours > 0 or fills_hopper > 0 or fires_hopper > 0 or braces > 0 or not rolls_again_on.is_empty() or not label.is_empty() or not printed.is_empty() \
		or spins or heat_per_blow > 0 or resets_on_kill or pulls_mines or drones \
		or fills_shield or cools_all or act_again or not charged.is_empty() \
		or ammo_per_foe_hit > 0 or spends_magazine \
		or regen_shield > 0 or action_price > 0 or rolls_target or kill_rerolls > 0


## Whether the entry prints a cooldown: one round or more.
func printed_cooldown() -> bool:
	return cooldown > 0


func is_attack() -> bool:
	return kind == Kind.ATTACK


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
	return kind == Kind.ATTACK and power <= 0 and not vents_all and fires_hopper <= 0 and power_per_missing <= 0


## Equipment (Ryan, 26 October: "the label for all 4 forms of buff and debuff faces"): a buff,
## spent on a machine, or a debuff, spent on a foe; it deals no damage.
func is_equipment() -> bool:
	return kind == Kind.BUFF or is_debuff()


## Spent on a machine (itself, an ally, or either, as it says): a shield, a vent or a buff.
func on_machines() -> bool:
	return kind == Kind.SHIELD or kind == Kind.VENT or kind == Kind.BUFF


func can_target_self() -> bool:
	return on_machines() and (targets == Target.SELF_ALLY or targets == Target.SELF)


func can_target_ally() -> bool:
	return on_machines() and (targets == Target.SELF_ALLY or targets == Target.ALLY or targets == Target.EVERY_ALLY)


## What this blow adds against `target` for the hull it is missing (power_per_missing), read
## as the die is spent: a known number, so the face is still flat. Nothing without a target.
func missing_bonus(target) -> int:
	if power_per_missing <= 0 or target == null:
		return 0
	return power_per_missing * int(maxi(0, int(target.hp_max) - int(target.hp)) / maxi(1, per_missing))


## What this blow adds against `target` for the stacks it consumes (the Backdraft Charge's
## Burning, 22 October): a point a stack, per_consumed each, read as the die is spent and
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
	f.printed = printed.duplicate()
	f.label = label
	f.component = component
	f.empty = empty
	f.fixed = fixed
	f.disabled = disabled
	f.targets = targets
	f.buff_status = buff_status
	f.buff_stacks = buff_stacks
	f.buff_rounds = buff_rounds
	f.vents_all = vents_all
	f.power_per_heat = power_per_heat
	f.per_heat = per_heat
	f.power_per_missing = power_per_missing
	f.per_missing = per_missing
	f.devours = devours
	f.burn = burn
	f.cryo = cryo
	f.flak = flak
	f.cleave = cleave
	f.penetrate = penetrate
	f.splash = splash
	f.chain = chain
	f.dispel = dispel
	f.volatile = volatile
	f.shield_cost = shield_cost
	f.short = short
	f.gates = gates.duplicate(true)
	f.consumes = consumes
	f.per_consumed = per_consumed
	f.self_burn = self_burn
	f.fills_hopper = fills_hopper
	f.fires_hopper = fires_hopper
	f.power_per_load = power_per_load
	f.braces = braces
	f.rolls_again_on = rolls_again_on
	f.cooldown = cooldown
	f.spins = spins
	f.heat_per_blow = heat_per_blow
	f.shields = shields
	f.resets_on_kill = resets_on_kill
	f.pulls_mines = pulls_mines
	f.drones = drones
	f.vents = vents
	f.fills_shield = fills_shield
	f.cools_all = cools_all
	f.not_acted = not_acted
	f.act_again = act_again
	f.charged = charged.duplicate(true)
	f.ammo_per_foe_hit = ammo_per_foe_hit
	f.spends_magazine = spends_magazine
	f.split = split
	f.reloads_ammo = reloads_ammo
	f.ammo = ammo
	f.dry = dry
	f.regen_shield = regen_shield
	f.regen_rounds = regen_rounds
	f.action_price = action_price
	f.rolls_target = rolls_target
	f.kill_rerolls = kill_rerolls
	f.burns = burns
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


## The entry's costs past heat as its text says them (Ryan, 26 October: Volatile a cost like
## heat, and a cost may be shield): the hull a spend bites, the shield it takes first.
func cost_text() -> String:
	return (" (-%d hull)" % volatile if volatile > 0 else "") + (" (-%d shield)" % shield_cost if shield_cost > 0 else "")


## A Rapid entry's spin as its text says it, and the Siphon's two rules. Equipment that reaches
## every ally says so in its own words ("on every ally"), never "reaches every foe".
func spin_text() -> String:
	var out := ""
	for p in _spin_phrases():
		out += " " + p
	return out


func _spin_phrases() -> Array[String]:
	var out: Array[String] = []
	if spins:
		out.append("spins the die")
	if heat_per_blow > 0:
		out.append("+%d heat a blow taken this round" % heat_per_blow)
	return out


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
		if power_per_missing > 0:
			out.append("+%d per %d HP missing" % [power_per_missing, per_missing])
		if not consumes.is_empty():
			out.append("consumes %s, +%d a stack" % [str(Effects.STATUS.get(consumes, {}).get("name", consumes)), per_consumed])
		if self_burn > 0:
			out.append("Burning %d on itself" % self_burn)
		if devours > 0:
			out.append("Empowered ×%d a kill" % devours)
		if fills_hopper > 0:
			out.append("fills the hopper" + ("" if fills_hopper == 1 else " ×%d" % fills_hopper))
		if fires_hopper > 0:
			out.append("fires the hopper, +%d a load (%d a shot)" % [power_per_load, fires_hopper])
	elif cools_all:
		out.append("cools to nothing")
	if braces > 0:
		out.append("braces" + ("" if braces == 1 else " ×%d" % braces))
	if not rolls_again_on.is_empty():
		out.append("spends a %s to roll again" % str(Effects.STATUS.get(rolls_again_on, {}).get("name", rolls_again_on)))
	if kind == Kind.ATTACK:
		if resets_on_kill:
			out.append("a kill brings back every entry its cooldowns darkened and it acts again")
		if pulls_mines:
			out.append("gathers every mine into its slot")
		if drones:
			out.append("leaves a Syrinx Drone, Rapid on a foe already Exposed, else Exposing it")
		if spends_magazine:
			out.append("a strike for every ammo in the magazine")
		if ammo_per_foe_hit > 0:
			out.append("+%d ammo a foe hit" % ammo_per_foe_hit)
		if kill_rerolls > 0:
			out.append(_kill_rerolls_text())
		if regen_shield > 0 and regen_rounds > 0:
			out.append(_regen_text())
	else:
		if action_price > 0:
			out.append(_action_text())
		if rolls_target:
			out.append("its die rolls again")
	out.append_array(_spin_phrases())
	if not charged.is_empty():
		out.append("%s: %s" % ["a muster" if muster_price() == 1 else "%d musters" % muster_price(), charged_form().describe()])
	return out


## The Petrels' rules as the entry's text says them (built 30 October): the Salvo's kill rider,
## the Regenerator's rider on its own spender, the Booster's price for an ally's action.
func _kill_rerolls_text() -> String:
	return "a kill brings %d reroll%s" % [kill_rerolls, "" if kill_rerolls == 1 else "s"]


func _regen_text() -> String:
	return "Regenerating on itself, %d shield a round for %d round%s" % [regen_shield, regen_rounds, "" if regen_rounds == 1 else "s"]


func _action_text() -> String:
	return "on an ally whose die is spent, %d reroll%s: its die rolls again and it acts again" % [action_price, "" if action_price == 1 else "s"]


## A printed cooldown as the entry's text says it, " cooldown 2"; nothing for an entry with none.
func cooldown_text() -> String:
	return " cooldown %d" % cooldown if printed_cooldown() else ""


func number_text() -> String:
	if kind == Kind.BLANK or is_debuff():
		return ""
	if kind == Kind.BUFF:
		return "×%d" % buff_stacks
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
			elif kind == Kind.BUFF:
				var status_name := str(Effects.STATUS.get(buff_status, {}).get("name", buff_status))
				s = "%s ×%d" % [status_name, buff_stacks]
				if buff_rounds > 1:
					s += " for %d rounds" % buff_rounds
			elif fills_shield:
				s = "shield to its maximum"
			else:
				s = "%s %d" % ["shield" if kind == Kind.SHIELD else "vent", power]
				if shields > 0:
					s += " shield %d" % shields   # the combined entry: both halves, the vent first
			if reloads_ammo > 0:
				s += " reloads %d ammo" % reloads_ammo
			if vents > 0:
				s += " cools %d" % vents
			if cools_all:
				s += " cools to nothing"
			if targets == Target.EVERY_ALLY:
				s += " every ally" + (" yet to act" if not_acted else "")   # its targeting mode, where its keyword stood
			for k in keywords:
				if not printed.has(k):
					s += " " + keyword_label(k)
			if action_price > 0:
				s += " " + _action_text()   # the Immelmann Booster's ally use, after what it does on itself
			if rolls_target:
				s += " its die rolls again"   # the Reheat Uplink's roll on the machine it lands on
			if braces > 0:
				s += " braces" + ("" if braces == 1 else " ×%d" % braces)
			if not rolls_again_on.is_empty():
				s += " spends a %s to roll again" % str(Effects.STATUS.get(rolls_again_on, {}).get("name", rolls_again_on))
			s += cooldown_text() + spin_text() + cost_text()
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
			for k in keywords:
				if printed.has(k):
					continue   # a grant written out says itself in its passive's line (the star), never as a keyword
				s += " " + keyword_label(k)
				if k == Keyword.BURN:
					s += " %d" % burn   # a numbered keyword: the stacks each blow leaves
				if k == Keyword.CRYO:
					s += " %d" % cryo
				if k == Keyword.FLAK:
					s += " %d" % flak
				if (AREA_KEYWORDS.has(k) or k == Keyword.CHAIN) and not is_debuff():
					s += " %d" % number_of(k)   # area by shape and Chain, numbered: what each foe past the target or each conductor takes (a debuff's deals nothing)
				if gates.has(KEYWORD_NAMES[k]):
					s += " (%s)" % Effects.gate_text(gates[KEYWORD_NAMES[k]])   # a gated keyword says where it lands
			if vents_all:
				s += " vents all" + (", +%d per %d heat" % [power_per_heat, per_heat] if power_per_heat > 0 else "")
			if power_per_missing > 0:
				s += " +%d per %d HP missing" % [power_per_missing, per_missing]
			if not consumes.is_empty():
				s += " consumes %s, +%d a stack" % [str(Effects.STATUS.get(consumes, {}).get("name", consumes)), per_consumed]
			if self_burn > 0:
				s += " Burning %d on itself" % self_burn   # the Stoker's: its own machine set burning as it fires
			if devours > 0:
				s += " Empowered ×%d a kill" % devours
			if fills_hopper > 0:
				s += " fills the hopper" + ("" if fills_hopper == 1 else " ×%d" % fills_hopper)
			if fires_hopper > 0:
				s += " fires the hopper, +%d a load (%d a shot)" % [power_per_load, fires_hopper]
			if braces > 0:
				s += " braces" + ("" if braces == 1 else " ×%d" % braces)
			if not rolls_again_on.is_empty():
				s += " spends a %s to roll again" % str(Effects.STATUS.get(rolls_again_on, {}).get("name", rolls_again_on))
			if resets_on_kill:
				s += " a kill brings back every entry its cooldowns darkened and it acts again"
			if pulls_mines:
				s += " gathers every mine into its slot"
			if drones:
				s += " leaves a Syrinx Drone, Rapid on a foe already Exposed, else Exposing it"
			if spends_magazine:
				s += " a strike for every ammo in the magazine"
			if ammo_per_foe_hit > 0:
				s += " +%d ammo a foe hit" % ammo_per_foe_hit
			if kill_rerolls > 0:
				s += " " + _kill_rerolls_text()   # the Spindrift Salvo's kill rider
			if regen_shield > 0 and regen_rounds > 0:
				s += " " + _regen_text()   # the St. Elmo's Regenerator's rider on its own spender
			s += cooldown_text() + spin_text()
			if heat > 0:
				s += " (+%d heat)" % heat
			s += cost_text()
	if not charged.is_empty():
		# What a muster buys (the Swallowtail's locked pieces): the charged form, after the plain.
		var cf := charged_form()
		s += " · %s: %s" % ["a muster" if muster_price() == 1 else "%d musters" % muster_price(), cf.describe()]
	return s.strip_edges()

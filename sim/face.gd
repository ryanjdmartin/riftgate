class_name Face
extends RefCounted

## One face of a die. Reads as: primary icon (kind and reach), a number or a range (power to
## power_max), a list of keywords and a heat cost.
##
## Numbers are in tens. A flat face has power_max equal to power and involves no roll; a rolled
## face rolls between power and power_max when spent. There are no crits (10 October): chances
## live on riders, never on the damage (bible section 5, the damage ranges row).

enum Kind { ATTACK, SHIELD, VENT, BLANK, BUFF }
## Two reaches since 10 October (Ryan): Close, a worse Direct by design, is removed and melee
## is a tag. Direct was line of sight until 9 October.
enum Reach { NONE, DIRECT, INDIRECT }
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
enum Keyword { NONE, CLEAVE, PENETRATE, BURN, SUPPRESS, CHAIN, RAPID, CLEANSE, VOLATILE, LURE, DISRUPT, SPILLOVER, OVERSHIELD, SHOCK, WEB, CRYO, FLAK, SWAP }
## Whom a component may be spent on (Ryan, 26 September): a weapon (an attack) targets foes;
## equipment (a shield, a vent) targets self and allies by default, and content may narrow
## one to self only or allies only, so the design space stays open.
enum Target { SELF_ALLY, SELF, ALLY, FOE }

## A blow that grows with its target's missing hull adds its power_per_missing for every this
## much the target has lost (the Sparrowhawk's rifle, 10 October). Flat: no roll involved.
const MISSING_STEP := 20

const KIND_NAMES := {
	Kind.ATTACK: "attack", Kind.SHIELD: "shield", Kind.VENT: "vent", Kind.BLANK: "blank", Kind.BUFF: "buff",
}
const REACH_NAMES := {
	Reach.NONE: "none", Reach.DIRECT: "direct", Reach.INDIRECT: "indirect",
}
const KEYWORD_NAMES := {
	Keyword.NONE: "", Keyword.CLEAVE: "cleave", Keyword.PENETRATE: "penetrate", Keyword.BURN: "burn",
	Keyword.SUPPRESS: "suppress",
	Keyword.CHAIN: "chain", Keyword.RAPID: "rapid", Keyword.CLEANSE: "cleanse",
	Keyword.VOLATILE: "volatile", Keyword.LURE: "lure", Keyword.DISRUPT: "disrupt",
	Keyword.SPILLOVER: "spillover", Keyword.OVERSHIELD: "overshield", Keyword.SHOCK: "shock",
	Keyword.WEB: "web", Keyword.CRYO: "cryo", Keyword.FLAK: "flak", Keyword.SWAP: "swap",
}
## What the player reads where it differs from the content id (the vocabulary's name).
const KEYWORD_LABELS := { Keyword.CLEAVE: "spread" }
const TARGET_NAMES := {
	Target.SELF_ALLY: "self_ally", Target.SELF: "self", Target.ALLY: "ally", Target.FOE: "foe",
}
## Keywords that ride on a shield or vent component (spent on a machine, not a foe); every
## other keyword is an attack's, except the few that ride on anything. The validator holds
## content to this. Lure and disrupt (2 October) are attack keywords: they ride on any
## foe-targeted entry, a damage weapon, a status weapon or an entry that does nothing else.
## Shock (9 October) is an attack keyword too: every foe the blows reach and leave alive is
## Shocked.
const SUPPORT_KEYWORDS := [Keyword.CLEANSE, Keyword.OVERSHIELD]
## Of those, the ones only a shield may carry: overshield (5 October, the Puffin's Prow
## Projector first, rare) lets a shield pass its target's maximum, and the excess fades at the
## round's end. A vent has nothing to pass.
const SHIELD_ONLY_KEYWORDS := [Keyword.OVERSHIELD]
## Keywords about the spend itself, not its target, so any kind of component may carry
## them: volatile (the Arsenal's self-damage, 28 September) bites the owner whatever the
## component does, and rapid (equipment too since 9 October, the Wake Diffuser first) gives
## the machine its turn back whatever the component did.
const ANY_KEYWORDS := [Keyword.VOLATILE, Keyword.RAPID]


static func keyword_label(k: int) -> String:
	return KEYWORD_LABELS.get(k, KEYWORD_NAMES[k])

# Enum-typed members are declared as int: GDScript 4 reports a spurious "Face.Kind vs Kind"
# type mismatch when a class_name script is loaded from a headless -s runner.
var kind: int = Kind.ATTACK
var reach: int = Reach.DIRECT
var power: int = 20
var power_max: int = 20       # equal to power for a flat face
var keywords: Array[int] = []
var heat: int = 0
var strikes: int = 1          # blows per use: a rapid-fire weapon lands many small hits (each rolls and procs on its own)
var burn: int = 0             # an attack with Burn: the stacks of Burning each blow leaves (Ryan, 18 October: a numbered keyword, never read off the damage)
var cryo: int = 0             # an attack with Cryo: the stacks of Cryo each foe it reaches gains (the Cryo Flinger, 20 October; a numbered keyword like Burn)
var flak: int = 0             # an attack with Flak: the stacks of Flak each foe hit gains (the Flakshot Repeater, 21 October; numbered like Burn)
var label: String = ""
var cracked: bool = false     # injured: modifiers gone, basic action intact
var component: String = ""    # the component this entry is (content id); "" for an empty hardpoint
var empty: bool = false       # an empty hardpoint: blank, and nothing was ever there to break
var fixed: bool = false       # built into the chassis (no hardpoint); false means this entry is a hardpoint
var disabled: bool = false    # a stand-in for an entry a status has switched off: blank for now, the real one is untouched
var targets: int = Target.SELF_ALLY   # equipment: whom it may be spent on; an attack is always FOE
var buff_status: String = ""  # a buff: the engine status it grants (Effects.STATUS id), with...
var buff_stacks: int = 1      # ...this many stacks...
var buff_rounds: int = 1      # ...through the end of this many rounds (1: this round)
var vents_all: bool = false   # an attack that fires the machine's whole heat: the gauge is empty after the shot...
var power_per_heat: int = 0   # ...and each 10 heat it fired adds this to the blow (the Afterburner Cannon, 28 September)
var power_per_missing: int = 0   # an attack: added for every MISSING_STEP hull its target is missing (10 October; flat, shown on the hover)
var devours: int = 0          # an attack: each kill gives its owner this many stacks of Overcharged (the Soulcutter Talons' rule; a keyword until 11 October, a count since 18 October)
var fills_hopper: int = 0     # an attack: loads it puts in its machine's hopper for each foe its blows reach (the Chainsaw Claw, 11 October)
var fires_hopper: int = 0     # an attack: the most loads one shot fires from the hopper...
var power_per_load: int = 0   # ...each adding this to the blow (the Bullion Fragmenter, 11 October)
var braces: int = 0           # any entry: spending it Braces its owner, this many stacks, until the round's end (the Breaching Plow, 12 October)
var rolls_again_on: String = ""   # any entry: spending it spends a stack of this status, if its owner has one, and the die rolls again (the Nemesis's fists on rage, 12 October)
var cooldown: int = -1        # any entry: the rounds it goes dark once spent, this one included (Ryan, 14 October); -1 reads its keywords (Rapid's switch-off, 1), 0 none
var spins: bool = false       # a Rapid entry whose free reroll is a true spin over every entry, itself included (the Cassowary's Spin-Up: Ryan's exception to the reroll rule, 19 October)
var reaches_all: bool = false # an attack that reaches every foe in the fight from its target (the Whip Scorpion's Heliographic Siphon, a lure-all, 20 October)
var heat_per_blow: int = 0    # any entry: spending it, every blow a foe lands on its owner this round adds this much heat (the Siphon's, next round's fuel)
var tags: Array[String] = []  # its component's tags (10 October): build flavour that never carries a rule; a passive may read one


## `kws` may be a single Keyword or an Array of them. `pwr_max` of 0 means static.
static func attack(pwr: int, rch: int = Reach.DIRECT, kws = [], ht: int = 0, pwr_max: int = 0) -> Face:
	var f := Face.new()
	f.kind = Kind.ATTACK
	f.targets = Target.FOE
	f.reach = rch
	f.power = pwr
	f.power_max = maxi(pwr, pwr_max)
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
	f.power_max = pwr
	return f


static func vent(pwr: int) -> Face:
	var f := Face.new()
	f.kind = Kind.VENT
	f.reach = Reach.NONE
	f.power = pwr
	f.power_max = pwr
	return f


## A buff (decided 29 September): equipment that grants `status` to the machine it is spent
## on, `stacks` deep, through the end of `rounds` rounds. The status names what it does.
static func buff(status: String, stacks: int = 1, rounds: int = 1) -> Face:
	var f := Face.new()
	f.kind = Kind.BUFF
	f.reach = Reach.NONE
	f.power = 0
	f.power_max = 0
	f.buff_status = status
	f.buff_stacks = maxi(1, stacks)
	f.buff_rounds = maxi(1, rounds)
	return f


static func blank() -> Face:
	var f := Face.new()
	f.kind = Kind.BLANK
	f.reach = Reach.NONE
	f.power = 0
	f.power_max = 0
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


static func target_from_name(name: String) -> int:
	for t in TARGET_NAMES.keys():
		if TARGET_NAMES[t] == name:
			return t
	return -1


## Build from content JSON: {"kind": "attack", "reach": "direct", "power": 20, "power_max": 50,
## "keywords": ["cleave"], "heat": 10}. Unknown names are ignored here; the
## content validator reports them.
static func from_dict(d: Dictionary) -> Face:
	var f := Face.new()
	var k := kind_from_name(str(d.get("kind", "attack")))
	f.kind = k if k >= 0 else Kind.ATTACK
	var r := reach_from_name(str(d.get("reach", "direct" if f.kind == Kind.ATTACK else "none")))
	f.reach = r if r >= 0 else Reach.NONE
	f.power = int(d.get("power", 0))
	f.power_max = maxi(f.power, int(d.get("power_max", f.power)))
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
		f.power_per_missing = maxi(0, int(d.get("power_per_missing", 0)))
		f.fills_hopper = maxi(0, int(d.get("fills_hopper", 0)))
		# A save or a draft from before 11 October lists devour as a keyword, and one from before
		# 18 October says `true`: each reads as the rule, a stack a kill.
		f.devours = maxi(0, int(d.get("devours", 0)))
		if Array(d.get("keywords", [])).has("devour"):
			f.devours = maxi(1, f.devours)
		f.burn = maxi(0, int(d.get("burn", 0)))   # add_keyword gives a Burn weapon one stack when it says none
		f.cryo = maxi(0, int(d.get("cryo", 0)))
		f.flak = maxi(0, int(d.get("flak", 0)))
		f.fires_hopper = maxi(0, int(d.get("fires_hopper", 0)))
		f.power_per_load = maxi(0, int(d.get("power_per_load", 0))) if f.fires_hopper > 0 else 0
	f.braces = maxi(0, int(d.get("braces", 0)))
	f.rolls_again_on = str(d.get("rolls_again_on", ""))
	f.cooldown = maxi(0, int(d["cooldown"])) if d.has("cooldown") else -1
	f.spins = bool(d.get("spins", false))
	f.reaches_all = bool(d.get("reaches_all", false)) and f.kind == Kind.ATTACK
	f.heat_per_blow = maxi(0, int(d.get("heat_per_blow", 0)))
	for name in d.get("keywords", []):
		var kw := keyword_from_name(str(name))
		if kw > 0:
			f.add_keyword(kw)
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
	if power_max != power:
		d["power_max"] = power_max
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
	if power_per_missing > 0:
		d["power_per_missing"] = power_per_missing
	if devours > 0:
		d["devours"] = devours
	if burn > 0 and has(Keyword.BURN):
		d["burn"] = burn
	if cryo > 0 and has(Keyword.CRYO):
		d["cryo"] = cryo
	if flak > 0 and has(Keyword.FLAK):
		d["flak"] = flak
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
	if reaches_all:
		d["reaches_all"] = true
	if heat_per_blow > 0:
		d["heat_per_blow"] = heat_per_blow
	return d


func add_keyword(kw: int) -> void:
	if kw > Keyword.NONE and not keywords.has(kw):
		keywords.append(kw)
	if kw == Keyword.BURN and burn <= 0:
		burn = 1   # a Burn weapon says its stacks; one when nothing says (a synthetic entry, an old save)
	if kw == Keyword.CRYO and cryo <= 0:
		cryo = 1
	if kw == Keyword.FLAK and flak <= 0:
		flak = 1


func has(kw: int) -> bool:
	return keywords.has(kw)


## The rounds this entry goes dark once spent, this one included (the cooldown row, 14
## October): what it prints, or else Rapid's switch-off, a cooldown of one, the rest of this
## round; none for any other entry. A cracked Rapid entry has lost the keyword and its
## switch-off with it; a printed cooldown is a price, and a crack keeps it as it keeps heat.
func cooldown_rounds() -> int:
	if cooldown >= 0:
		return cooldown
	return 1 if has(Keyword.RAPID) else 0


## A rule printed on the entry rather than a keyword (bible section 6: the die's star chip):
## Vents all, the missing-hull bonus, the talons' kill rule, the hopper, the brace, rolling
## again on a status (the Nemesis's rage), a printed cooldown (Rapid's own switch-off aside,
## and a Rapid entry's "no cooldown" with it), a spin (the Spin-Up's), the Siphon's reach over
## every foe and its heat a blow, or a labelled effect.
func has_unique_rule() -> bool:
	return vents_all or power_per_missing > 0 or devours > 0 or fills_hopper > 0 or fires_hopper > 0 or braces > 0 or not rolls_again_on.is_empty() or not label.is_empty() \
		or printed_cooldown() or spins or reaches_all or heat_per_blow > 0


## Whether the entry prints a cooldown of its own: a number past Rapid's switch-off, or a
## Rapid entry's "no cooldown".
func printed_cooldown() -> bool:
	if has(Keyword.RAPID):
		return cooldown == 0 or cooldown > 1
	return cooldown > 0


func is_attack() -> bool:
	return kind == Kind.ATTACK


## The two component types (Ryan, 26 September): a weapon is spent on a foe and need not
## deal damage; equipment is spent on a machine. A blank is neither.
func is_weapon() -> bool:
	return kind == Kind.ATTACK


func is_equipment() -> bool:
	return kind == Kind.SHIELD or kind == Kind.VENT or kind == Kind.BUFF


func can_target_self() -> bool:
	return is_equipment() and (targets == Target.SELF_ALLY or targets == Target.SELF)


func can_target_ally() -> bool:
	return is_equipment() and (targets == Target.SELF_ALLY or targets == Target.ALLY)


## Rolled: the face rolls when spent. A flat face involves no roll, whatever feeds its number.
func is_ranged() -> bool:
	return power_max > power


## What this blow adds against `target` for the hull it is missing (power_per_missing), read
## as the die is spent: a known number, so the face is still flat. Nothing without a target.
func missing_bonus(target) -> int:
	if power_per_missing <= 0 or target == null:
		return 0
	return power_per_missing * int(maxi(0, int(target.hp_max) - int(target.hp)) / MISSING_STEP)


func average() -> int:
	return ceili((power + power_max) / 2.0)


func duplicate_face() -> Face:
	var f := Face.new()
	f.kind = kind
	f.reach = reach
	f.power = power
	f.power_max = power_max
	f.heat = heat
	f.strikes = strikes
	f.label = label
	f.cracked = cracked
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
	f.power_per_missing = power_per_missing
	f.devours = devours
	f.burn = burn
	f.cryo = cryo
	f.flak = flak
	f.fills_hopper = fills_hopper
	f.fires_hopper = fires_hopper
	f.power_per_load = power_per_load
	f.braces = braces
	f.rolls_again_on = rolls_again_on
	f.cooldown = cooldown
	f.spins = spins
	f.reaches_all = reaches_all
	f.heat_per_blow = heat_per_blow
	f.tags = tags.duplicate()
	for k in keywords:
		f.keywords.append(k)
	return f


## An injury: the component keeps its action, its numbers and its heat, and loses
## its keywords (Ryan, 18 September: cracked is the mild state; destroyed is the real one).
## A cracked component hit again is destroyed, which is Face.blank().
func crack() -> void:
	cracked = true
	keywords.clear()
	label = ""
	spins = false   # Rapid's reroll as a spin goes with Rapid


## A Rapid entry's spin as its text says it, and the Siphon's two rules.
func spin_text() -> String:
	return (" spins the die" if spins else "") + (" reaches every foe" if reaches_all else "") \
		+ (" +%d heat a blow taken this round" % heat_per_blow if heat_per_blow > 0 else "")


## A printed cooldown as the entry's text says it: " cooldown 2", or " no cooldown" on a Rapid
## entry that prints none; nothing for Rapid's own switch-off or an entry with no cooldown.
func cooldown_text() -> String:
	if not printed_cooldown():
		return ""
	return " no cooldown" if cooldown == 0 else " cooldown %d" % cooldown


func number_text() -> String:
	if kind == Kind.BLANK:
		return ""
	if kind == Kind.BUFF:
		return "×%d" % buff_stacks
	return "%d–%d" % [power, power_max] if is_ranged() else str(power)


func describe() -> String:
	var s := ""
	match kind:
		Kind.BLANK:
			if disabled:
				return "disabled"
			return "empty hardpoint" if empty else "destroyed"
		Kind.SHIELD, Kind.VENT, Kind.BUFF:
			if kind == Kind.BUFF:
				var status_name := str(Effects.STATUS.get(buff_status, {}).get("name", buff_status))
				s = "%s ×%d" % [status_name, buff_stacks]
				if buff_rounds > 1:
					s += " for %d rounds" % buff_rounds
			else:
				s = "%s %d" % ["shield" if kind == Kind.SHIELD else "vent", power]
			for k in keywords:
				s += " " + keyword_label(k)
			if braces > 0:
				s += " braces" + ("" if braces == 1 else " ×%d" % braces)
			if not rolls_again_on.is_empty():
				s += " spends a %s to roll again" % str(Effects.STATUS.get(rolls_again_on, {}).get("name", rolls_again_on))
			s += cooldown_text() + spin_text()
			if targets == Target.SELF:
				s += " (self only)"
			elif targets == Target.ALLY:
				s += " (allies only)"
		_:
			# Direct is the default and goes unsaid; only indirect reach is called out.
			s = number_text() if reach == Reach.DIRECT else "%s %s" % [REACH_NAMES[reach], number_text()]
			if strikes > 1:
				s += " ×%d" % strikes
			for k in keywords:
				s += " " + keyword_label(k)
				if k == Keyword.BURN:
					s += " %d" % burn   # a numbered keyword: the stacks each blow leaves
				if k == Keyword.CRYO:
					s += " %d" % cryo
				if k == Keyword.FLAK:
					s += " %d" % flak
			if vents_all:
				s += " vents all" + (", +%d per 10 heat" % power_per_heat if power_per_heat > 0 else "")
			if power_per_missing > 0:
				s += " +%d per %d hull missing" % [power_per_missing, MISSING_STEP]
			if devours > 0:
				s += " Overcharged ×%d a kill" % devours
			if fills_hopper > 0:
				s += " fills the hopper" + ("" if fills_hopper == 1 else " ×%d" % fills_hopper)
			if fires_hopper > 0:
				s += " fires the hopper, +%d a load (%d a shot)" % [power_per_load, fires_hopper]
			if braces > 0:
				s += " braces" + ("" if braces == 1 else " ×%d" % braces)
			if not rolls_again_on.is_empty():
				s += " spends a %s to roll again" % str(Effects.STATUS.get(rolls_again_on, {}).get("name", rolls_again_on))
			s += cooldown_text() + spin_text()
			if heat > 0:
				s += " (+%d heat)" % heat
	if cracked:
		s += " (cracked)"
	return s

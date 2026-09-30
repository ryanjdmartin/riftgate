class_name Face
extends RefCounted

## One face of a die. Reads as: primary icon (kind and reach), a number or a range (power to
## power_max), a list of keywords, a heat cost, and a crit chance.
##
## Numbers are in tens. A static face has power_max equal to power (energy weapons). A kinetic
## face rolls between power and power_max when spent, and may crit for double.

const CRIT_MULT := 2.0        # a crit multiplies the roll by this plus every crit bonus (component, passives): additive, tunable

enum Kind { ATTACK, SHIELD, VENT, BLANK, BUFF }
enum Reach { NONE, LINE, INDIRECT, MELEE }
enum Keyword { NONE, CLEAVE, PENETRATE, BURN, SUPPRESS, EXECUTE, CHAIN, STEADY, RAPID, CLEANSE, VOLATILE, DEVOUR, TAUNT, BEACON, OVERWHELM }
## Whom a component may be spent on (Ryan, 26 September): a weapon (an attack) targets foes;
## equipment (a shield, a vent) targets self and allies by default, and content may narrow
## one to self only or allies only, so the design space stays open.
enum Target { SELF_ALLY, SELF, ALLY, FOE }

const KIND_NAMES := {
	Kind.ATTACK: "attack", Kind.SHIELD: "shield", Kind.VENT: "vent", Kind.BLANK: "blank", Kind.BUFF: "buff",
}
const REACH_NAMES := {
	Reach.NONE: "none", Reach.LINE: "line", Reach.INDIRECT: "indirect", Reach.MELEE: "melee",
}
const KEYWORD_NAMES := {
	Keyword.NONE: "", Keyword.CLEAVE: "cleave", Keyword.PENETRATE: "penetrate", Keyword.BURN: "burn",
	Keyword.SUPPRESS: "suppress", Keyword.EXECUTE: "execute",
	Keyword.CHAIN: "chain", Keyword.STEADY: "steady", Keyword.RAPID: "rapid", Keyword.CLEANSE: "cleanse",
	Keyword.VOLATILE: "volatile", Keyword.DEVOUR: "devour", Keyword.TAUNT: "taunt", Keyword.BEACON: "beacon",
	Keyword.OVERWHELM: "overwhelm",
}
## What the player reads where it differs from the content id (the vocabulary's name).
const KEYWORD_LABELS := { Keyword.CLEAVE: "spread" }
const TARGET_NAMES := {
	Target.SELF_ALLY: "self_ally", Target.SELF: "self", Target.ALLY: "ally", Target.FOE: "foe",
}
## Keywords that ride on a shield or vent component (spent on a machine, not a foe); every
## other keyword is an attack's, except the few that ride on anything. The validator holds
## content to this.
const SUPPORT_KEYWORDS := [Keyword.CLEANSE, Keyword.TAUNT, Keyword.BEACON]
## Keywords about the spend itself, not its target, so any kind of component may carry
## them: volatile (the Arsenal's self-damage, 28 September) bites the owner whatever the
## component does.
const ANY_KEYWORDS := [Keyword.VOLATILE]


static func keyword_label(k: int) -> String:
	return KEYWORD_LABELS.get(k, KEYWORD_NAMES[k])

# Enum-typed members are declared as int: GDScript 4 reports a spurious "Face.Kind vs Kind"
# type mismatch when a class_name script is loaded from a headless -s runner.
var kind: int = Kind.ATTACK
var reach: int = Reach.LINE
var power: int = 20
var power_max: int = 20       # equal to power for a static face
var crit: int = 0             # percent chance to crit
var crit_bonus: float = 0.0   # added to the crit multiplier (base Skirmish.CRIT_MULT); +0.5 means crits do half again more
var keywords: Array[int] = []
var heat: int = 0
var strikes: int = 1          # blows per use: a rapid-fire weapon lands many small hits (each rolls, crits and procs on its own)
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


## `kws` may be a single Keyword or an Array of them. `pwr_max` of 0 means static.
static func attack(pwr: int, rch: int = Reach.LINE, kws = [], ht: int = 0, pwr_max: int = 0, crit_pct: int = 0) -> Face:
	var f := Face.new()
	f.kind = Kind.ATTACK
	f.targets = Target.FOE
	f.reach = rch
	f.power = pwr
	f.power_max = maxi(pwr, pwr_max)
	f.crit = crit_pct
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
	for r in REACH_NAMES.keys():
		if REACH_NAMES[r] == name:
			return r
	return -1


static func target_from_name(name: String) -> int:
	for t in TARGET_NAMES.keys():
		if TARGET_NAMES[t] == name:
			return t
	return -1


## Build from content JSON: {"kind": "attack", "reach": "line", "power": 20, "power_max": 50,
## "crit": 15, "keywords": ["cleave"], "heat": 10}. Unknown names are ignored here; the
## content validator reports them.
static func from_dict(d: Dictionary) -> Face:
	var f := Face.new()
	var k := kind_from_name(str(d.get("kind", "attack")))
	f.kind = k if k >= 0 else Kind.ATTACK
	var r := reach_from_name(str(d.get("reach", "line" if f.kind == Kind.ATTACK else "none")))
	f.reach = r if r >= 0 else Reach.NONE
	f.power = int(d.get("power", 0))
	f.power_max = maxi(f.power, int(d.get("power_max", f.power)))
	f.crit = int(d.get("crit", 0))
	f.crit_bonus = float(d.get("crit_bonus", 0.0))
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
	if crit > 0:
		d["crit"] = crit
	if crit_bonus != 0.0:
		d["crit_bonus"] = crit_bonus
	if strikes > 1:
		d["strikes"] = strikes
	if kind != Kind.ATTACK and targets != Target.SELF_ALLY:
		d["targets"] = TARGET_NAMES[targets]
	if kind == Kind.BUFF:
		d["status"] = buff_status
		d["stacks"] = buff_stacks
		d["rounds"] = buff_rounds
	return d


func add_keyword(kw: int) -> void:
	if kw > Keyword.NONE and not keywords.has(kw):
		keywords.append(kw)


func has(kw: int) -> bool:
	return keywords.has(kw)


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


## Kinetic: the face rolls when spent.
func is_ranged() -> bool:
	return power_max > power


func average() -> int:
	return ceili((power + power_max) / 2.0)


func duplicate_face() -> Face:
	var f := Face.new()
	f.kind = kind
	f.reach = reach
	f.power = power
	f.power_max = power_max
	f.crit = crit
	f.crit_bonus = crit_bonus
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
	for k in keywords:
		f.keywords.append(k)
	return f


## An injury: the component keeps its action, its numbers, its crit and its heat, and loses
## its keywords (Ryan, 18 September: cracked is the mild state; destroyed is the real one).
## A cracked component hit again is destroyed, which is Face.blank().
func crack() -> void:
	cracked = true
	keywords.clear()
	label = ""


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
			if targets == Target.SELF:
				s += " (self only)"
			elif targets == Target.ALLY:
				s += " (allies only)"
		_:
			# Line of fire is the default and goes unsaid; only indirect reach is called out.
			s = number_text() if reach == Reach.LINE else "%s %s" % [REACH_NAMES[reach], number_text()]
			if strikes > 1:
				s += " ×%d" % strikes
			for k in keywords:
				s += " " + keyword_label(k)
			if crit > 0:
				s += " crit %d%%" % crit
				if crit_bonus != 0.0:
					s += " (×%s)" % _trim(CRIT_MULT + crit_bonus)   # the resulting multiplier, never the bonus
			if heat > 0:
				s += " (+%d heat)" % heat
	if cracked:
		s += " (cracked)"
	return s


static func _trim(x: float) -> String:
	return str(x) if x != floorf(x) else str(int(x))

class_name Face
extends RefCounted

## One face of a die. Reads as: primary icon (kind and reach), a number (power),
## a list of keywords, and a heat cost. Authored faces carry few keywords; upgrades
## during a battle or in the meta may add more.

enum Kind { ATTACK, SHIELD, VENT, BLANK }
enum Reach { NONE, LINE, INDIRECT }
enum Keyword { NONE, CLEAVE, PIERCE, BURN, SUPPRESS, OVERCHARGE, EXECUTE, CHAIN, LOCK }

const KIND_NAMES := {
	Kind.ATTACK: "attack", Kind.SHIELD: "shield", Kind.VENT: "vent", Kind.BLANK: "blank",
}
const REACH_NAMES := {
	Reach.NONE: "none", Reach.LINE: "line", Reach.INDIRECT: "indirect",
}
const KEYWORD_NAMES := {
	Keyword.NONE: "", Keyword.CLEAVE: "cleave", Keyword.PIERCE: "pierce", Keyword.BURN: "burn",
	Keyword.SUPPRESS: "suppress", Keyword.OVERCHARGE: "overcharge", Keyword.EXECUTE: "execute",
	Keyword.CHAIN: "chain", Keyword.LOCK: "lock",
}

# Enum-typed members are declared as int: GDScript 4 reports a spurious "Face.Kind vs Kind"
# type mismatch when a class_name script is loaded from a headless -s runner.
var kind: int = Kind.ATTACK
var reach: int = Reach.LINE
var power: int = 2
var keywords: Array[int] = []
var heat: int = 0
var label: String = ""


## `kws` may be a single Keyword or an Array of them.
static func attack(pwr: int, rch: int = Reach.LINE, kws = [], ht: int = 0) -> Face:
	var f := Face.new()
	f.kind = Kind.ATTACK
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


static func blank() -> Face:
	var f := Face.new()
	f.kind = Kind.BLANK
	f.reach = Reach.NONE
	f.power = 0
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


## Build from content JSON: {"kind": "attack", "reach": "line", "power": 3,
## "keywords": ["cleave"], "heat": 1}. Unknown names are ignored here; the content
## validator reports them.
static func from_dict(d: Dictionary) -> Face:
	var f := Face.new()
	var k := kind_from_name(str(d.get("kind", "attack")))
	f.kind = k if k >= 0 else Kind.ATTACK
	var r := reach_from_name(str(d.get("reach", "line" if f.kind == Kind.ATTACK else "none")))
	f.reach = r if r >= 0 else Reach.NONE
	f.power = int(d.get("power", 0))
	f.heat = int(d.get("heat", 0))
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
	return {
		"kind": KIND_NAMES[kind], "reach": REACH_NAMES[reach], "power": power,
		"keywords": names, "heat": heat,
	}


func add_keyword(kw: int) -> void:
	if kw > Keyword.NONE and not keywords.has(kw):
		keywords.append(kw)


func has(kw: int) -> bool:
	return keywords.has(kw)


func is_attack() -> bool:
	return kind == Kind.ATTACK


func duplicate_face() -> Face:
	var f := Face.new()
	f.kind = kind
	f.reach = reach
	f.power = power
	f.heat = heat
	f.label = label
	for k in keywords:
		f.keywords.append(k)
	return f


func describe() -> String:
	match kind:
		Kind.BLANK:
			return "cracked"
		Kind.SHIELD:
			return "shield %d" % power
		Kind.VENT:
			return "vent %d" % power
		_:
			var s := "%s %d" % [REACH_NAMES[reach], power]
			for k in keywords:
				s += " " + KEYWORD_NAMES[k]
			if heat > 0:
				s += " (+%d heat)" % heat
			return s

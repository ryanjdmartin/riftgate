class_name Foe
extends RefCounted

## One enemy inside a skirmish. A squad on the battlefield unpacks into several of these.

var display_name: String = "foe"
var content_id: String = ""      # id in content/foes.json, for the codex
var hp: int = 30
var hp_max: int = 30
var attack: int = 10
var prefers_back: bool = false   # ranged types hold the back rank and never step up
var squad_id: int = 0            # which battlefield squad this foe came from
var size: int = 1                # 2 = massive: fills both slots of a column
var strikes: int = 1             # hits per turn, each its own blow: a double strike breaks a shield and reaches the hull
var breach: bool = false         # its blows overflow shield into hull (a boss trait); a shielded hit still never injures

# Live state.
var rank: int = -1               # 0 front, 1 back, -1 in reserve
var column: int = -1
var burn: int = 0
var suppressed: bool = false
var target: RefCounted = null    # Skirmish.MechState, set when intents are telegraphed


static func make(name: String, hp_value: int, attack_value: int, back: bool = false) -> Foe:
	var f := Foe.new()
	f.display_name = name
	f.hp = hp_value
	f.hp_max = hp_value
	f.attack = attack_value
	f.prefers_back = back
	return f


func alive() -> bool:
	return hp > 0


func is_massive() -> bool:
	return size >= 2


## How much this foe threatens per turn, for deployment order: the heaviest hitters stand
## left, where they strike first, so the player sees the big blow coming from the jump.
func threat() -> int:
	return attack * strikes + (1 if breach else 0)


func on_field() -> bool:
	return rank >= 0

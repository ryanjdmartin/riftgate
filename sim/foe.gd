class_name Foe
extends RefCounted

## One enemy inside a skirmish. A squad on the battlefield unpacks into several of these.

var display_name: String = "ghoul"
var content_id: String = ""      # id in content/foes.json, for the codex
var hp: int = 30
var hp_max: int = 30
var attack: int = 10
var prefers_back: bool = false   # ranged types hold the back rank and never step up
var squad_id: int = 0            # which battlefield squad this foe came from
var size: int = 1                # 2 = massive: fills both slots of a column

# Live state.
var rank: int = -1               # 0 front, 1 back, -1 in the pool
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


func on_field() -> bool:
	return rank >= 0

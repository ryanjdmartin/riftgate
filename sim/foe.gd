class_name Foe
extends RefCounted

## One enemy inside a skirmish. A squad on the battlefield unpacks into several of these.
##
## A foe has a base attack number, the player's quick read of how hard it hits, and a list
## of attack actions that scale it: {id, name, factor, strikes, breach, weight, text}.
## Each round it picks one by weight before the player acts, so the intent shown is exact.
## Damage is base attack times the action's factor; strikes are separate blows; breach
## overflows shield into hull.

var display_name: String = "foe"
var content_id: String = ""      # id in content/foes.json, for the codex
var hp: int = 30
var hp_max: int = 30
var attack: int = 10             # base attack: the number the player reads as "how hard it hits"
var prefers_back: bool = false   # ranged types hold the back rank and never step up
var squad_id: int = 0            # which battlefield squad this foe came from
var size: int = 1                # 2 = massive: fills both slots of a column
var actions: Array = []          # implemented attack actions; at least the basic one

# Live state.
var rank: int = -1               # 0 front, 1 back, -1 in reserve
var column: int = -1
var burn: int = 0
var suppressed: bool = false
var target: RefCounted = null    # Skirmish.MechState, set when intents are telegraphed
var action: Dictionary = {}      # this round's chosen action


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
	return {"id": "attack", "name": "Attack", "factor": 1.0, "strikes": 1, "breach": false, "weight": 1, "text": ""}


func alive() -> bool:
	return hp > 0


func is_massive() -> bool:
	return size >= 2


func on_field() -> bool:
	return rank >= 0


## Pick this round's action by weight. One action needs no roll.
func choose_action(rng: RandomNumberGenerator) -> void:
	if actions.is_empty():
		action = basic_action()
		return
	if actions.size() == 1:
		action = actions[0]
		return
	var total := 0
	for a in actions:
		total += maxi(1, int(a.get("weight", 1)))
	var pick := rng.randi_range(1, total)
	for a in actions:
		pick -= maxi(1, int(a.get("weight", 1)))
		if pick <= 0:
			action = a
			return
	action = actions[actions.size() - 1]


## What one blow of an action does: base attack times its factor, rounded to the nearest
## whole number (numbers are in the magnitude of tens, not multiples of ten).
func damage_of(a: Dictionary) -> int:
	return int(roundf(attack * float(a.get("factor", 1.0))))


func damage() -> int:
	return damage_of(action)


func strikes() -> int:
	return maxi(1, int(action.get("strikes", 1)))


func breaches() -> bool:
	return bool(action.get("breach", false))


## The action's text with {damage} filled in, so "Jaw Rend for {damage}" reads as a number.
func text_of(a: Dictionary) -> String:
	return str(a.get("text", "")).replace("{damage}", str(damage_of(a)))


## How much this foe can threaten in a turn, for deployment order: the heaviest hitters stand
## left, where they strike first, so the player sees the big blow coming from the jump.
func threat() -> int:
	var best := 0
	for a in actions:
		best = maxi(best, damage_of(a) * maxi(1, int(a.get("strikes", 1))) + (1 if bool(a.get("breach", false)) else 0))
	return best

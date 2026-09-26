class_name Foe
extends RefCounted

## One enemy inside a skirmish. A squad on the battlefield unpacks into several of these.
##
## A foe has a base attack number, the player's quick read of how hard it hits, and a list
## of attack actions that scale it: {id, name, factor, strikes, weight, keywords, text}.
## Each round it picks one by weight before the player acts, so the intent shown is exact.
## Damage is base attack times the action's factor; strikes are separate blows; keywords are
## tags on the blow (breach: overflows shield into hull).

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
var target: RefCounted = null    # Skirmish.MechState, set when intents are telegraphed
var action: Dictionary = {}      # this round's chosen action
var modifiers: Array = []        # statuses on this foe (burning, suppressed, numbed...): Effects.Modifier list
var die = null                   # foes have no die; the pipeline asks, so the field exists


func burn_stacks() -> int:
	return Effects.stacks_of(self, "burning")


func is_suppressed() -> bool:
	return Effects.tick_preview(self)["skip"]


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


## Tags an attack action may carry. Anything true or false about a blow is a tag here, never
## a field of its own.
## breach: overflows shield into hull. scorch: stacks Overheating on the mech it hits (a
## placeholder name; the mech-side heat DOT Ryan asked for). disable: switches off the entry
## the target's die shows, through its next turn. corrupt: a stack of Corrupted on that
## entry, for the skirmish: it bites its owner every time it is spent.
const ATTACK_KEYWORDS := ["breach", "scorch", "disable", "corrupt"]


func has_keyword(a: Dictionary, k: String) -> bool:
	return a.get("keywords", []).has(k)


func breaches() -> bool:
	return has_keyword(action, "breach")


## The action's text with {damage} filled in, so "Jaw Rend for {damage}" reads as a number.
func text_of(a: Dictionary) -> String:
	return str(a.get("text", "")).replace("{damage}", str(damage_of(a)))


## How much this foe can threaten in a turn, for deployment order: the heaviest hitters stand
## left, where they strike first, so the player sees the big blow coming from the jump.
func threat() -> int:
	var best := 0
	for a in actions:
		best = maxi(best, damage_of(a) * maxi(1, int(a.get("strikes", 1))) + (1 if has_keyword(a, "breach") else 0))
	return best

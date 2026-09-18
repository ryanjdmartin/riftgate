class_name Die
extends RefCounted

## A mech's die: one entry per component slot, the chassis's fixed components first, then
## its hardpoints (a component of size two appears twice; an empty hardpoint is a blank
## entry). The player never sees a polyhedron, so shown text says "component", not "face";
## Face is the engine's word for one entry.

var faces: Array[Face] = []


static func of(list: Array) -> Die:
	var d := Die.new()
	for f in list:
		d.faces.append(f)
	return d


## A one-faced die. Handy for tests: it always rolls the same thing.
static func single(f: Face) -> Die:
	return of([f])


func size() -> int:
	return faces.size()


func roll(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(0, faces.size() - 1)


## A reroll always lands on a different face: never the one showing, never one equivalent
## to it. These are not really dice, and a reroll that changes nothing reads as a bug. A die
## whose faces are all alike keeps the face it has.
func reroll(rng: RandomNumberGenerator, current: int) -> int:
	if current < 0 or current >= faces.size():
		return roll(rng)
	var showing := faces[current].to_dict()
	var options: Array[int] = []
	for i in range(faces.size()):
		if i != current and faces[i].to_dict() != showing:
			options.append(i)
	if options.is_empty():
		return current
	return options[rng.randi_range(0, options.size() - 1)]


## Chance of any given face, for the builder's odds display.
func odds() -> float:
	return 1.0 / float(maxi(1, faces.size()))

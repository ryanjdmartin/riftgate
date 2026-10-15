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


## A reroll lands on any other face, never the one showing: a copy of it may come up, at the
## odds its copies give it (Ryan, 15 October; the team's rerolls and Rapid's alike). Skipping
## copies too was abusable: a die of one key entry and copies of one filler sent every reroll
## from a filler onto the key. A one-faced die keeps its face.
func reroll(rng: RandomNumberGenerator, current: int) -> int:
	if current < 0 or current >= faces.size():
		return roll(rng)
	if faces.size() == 1:
		return current
	var pick := rng.randi_range(0, faces.size() - 2)
	return pick if pick < current else pick + 1


## Chance of any given face, for the builder's odds display.
func odds() -> float:
	return 1.0 / float(maxi(1, faces.size()))

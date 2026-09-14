class_name Die
extends RefCounted

## A mech's die. Its size is its face count: one face per hardpoint, chassis fills the rest.

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


## Chance of any given face, for the builder's odds display.
func odds() -> float:
	return 1.0 / float(maxi(1, faces.size()))

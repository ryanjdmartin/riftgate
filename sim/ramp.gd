class_name Ramp
extends RefCounted

## The ramp: the soft scaling (Ryan, 30 October: the tier is the hard scaling, the ramp the
## soft, intra-tier scaling), one table of placeholders by the Convergence, 0 to TOP, read live
## as a battle starts and the same for every open front, never shown, monotone and never reset
## at a tier step (with the tier locked when the rift opens, a reset would make an old rift
## easier by waiting). The tier, locked and shown, sets the kind: who comes, the Fractures, the
## elites and which, the boss's numbers and escort. The ramp sets the count and the speed: the
## compositions on the field at the start and their density, Rift Pressure's fill, the tears a
## peak, the seam's creep, and since the long wall brief (docs/briefs/long_wall_build.md) the
## field's size and the spread of the pushers' wall segments. The interval step inside a battle is on the table at zero until the
## turtle read asks for it (the bible's stall row; the brief: git show 85e28fd:docs/briefs/fresh_start.md).
## Every number here is a placeholder,
## measured by the campaign runner and moved on Ryan's word.

const TOP := 12   # the Convergence the finale is due at (Campaign.FINALE_AT)

## By the tier (0 to 2, the locked kind): the Fractures to the Rupture, and the Fractures that
## spawn an elite (the bible's pacing row; the elites' moment is a Fracture, 30 October).
const FRACTURES := [3, 4, 5]
const ELITE_FRACTURES := [[1], [1, 3], [1, 2, 4]]


static func clampc(c: int) -> int:
	return clampi(c, 0, TOP)


## Formations on the field at the start: one, two from Convergence 3, three from 8.
static func formations_at(c: int) -> int:
	return 1 + (clampc(c) + 2) / 5


## Patrols on the field at the start: two, one from Convergence 8.
static func patrols_at(c: int) -> int:
	return 2 if clampc(c) < 8 else 1


## The density: each member's strength scaled, 1.0 at the start to 1.5 at the top.
static func density_at(c: int) -> float:
	return 1.0 + float(clampc(c)) / 24.0


## A strength at the ramp's density, never below one.
static func scaled(strength: int, c: int) -> int:
	return maxi(1, roundi(float(strength) * density_at(c)))


## Rift Pressure's fill, the beat (the long wall brief 3.2: the tide's waves come on it): 3
## turns at the start, 2 from Convergence 8.
static func timer_at(c: int) -> int:
	return 3 if clampc(c) < 8 else 2   # placeholder (the long wall brief)


## Tears that open at a peak: one, two from Convergence 8.
static func tears_at(c: int) -> int:
	return 1 + clampc(c) / 8


## The seam's creep a peak, in rows: flat.
static func seam_creep_at(_c: int) -> int:
	return 2


## The interval step a peak, the escalation inside a battle: zero, on the table.
static func step_at(_c: int) -> int:
	return 0


static func fractures_at(tier: int) -> int:
	return int(FRACTURES[clampi(tier, 0, FRACTURES.size() - 1)])


static func elite_fractures_at(tier: int) -> Array:
	return Array(ELITE_FRACTURES[clampi(tier, 0, ELITE_FRACTURES.size() - 1)])


## How far either side of the rift's column a pusher's wall segment may fall (the long wall brief
## 3.3; Ryan, 5 November: "The variance of where they target can even be a ramp factor"): 2 at the
## foot, half the wall's length at the top. `width` is the wall's length.
static func spread_at(c: int, width: int) -> int:
	return 2 + ((width / 2 - 2) * clampc(c)) / 12   # placeholder (the long wall brief)


## The wall's length: the count of hexes along the wall, the map's width (the long wall, Ryan,
## 5 November: "Wide map, with lots of wall to defend, but not as deep"; the build brief,
## docs/briefs/long_wall_build.md 3.1). A lever of the ramp's, never fixed.
static func wall_length_at(_c: int) -> int:
	return 20   # placeholder (the long wall brief)


## The field's depth: the rows from the rift's row to the last wall row inclusive, the map's
## height (the long wall brief 3.1).
static func depth_at(_c: int) -> int:
	return 12   # placeholder (the long wall brief)

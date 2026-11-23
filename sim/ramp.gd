class_name Ramp
extends RefCounted

## The ramp: the soft scaling (Ryan, 30 October: the tier is the hard scaling, the ramp the
## soft, intra-tier scaling), one table of placeholders by the Convergence, 0 to TOP, read live
## as a battle starts and the same for every open front, never shown, monotone and never reset
## at a tier step (with the tier locked when the rift opens, a reset would make an old rift
## easier by waiting). The tier, locked and shown, sets the kind: who comes, the Fractures, the
## elites and which, the boss's numbers and escort. The ramp sets the map's count and speed: the
## compositions on the field at the start, Rift Pressure's fill, the tears a peak, the step of
## the tears' row, and since the long wall brief (docs/briefs/long_wall_build.md) the field's
## size. It no longer scales a pack (Ryan, 7 November: with fixed
## compositions and no reinforcement, "it probably doesn't need to be a dynamic multiplication of
## ramp for foes ... maybe gate certain predefined compositions behind a ramp+tier"): a pack is its
## composition as content writes it, never more than its eight slots hold. The interval step inside a battle is on the table at zero until the
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


## Rift Pressure's fill, the beat (the long wall brief 3.2: the tide's waves come on it): 3
## turns at the start, 2 from Convergence 8.
static func timer_at(c: int) -> int:
	return 3 if clampc(c) < 8 else 2   # placeholder (the long wall brief)


## Tears that open at a peak: one, two from Convergence 8.
static func tears_at(c: int) -> int:
	return 1 + clampc(c) / 8


## How far the tears' row steps toward the wall a peak, in rows: flat.
static func tear_creep_at(_c: int) -> int:
	return 2


## The interval step a peak, the escalation inside a battle: zero, on the table.
static func step_at(_c: int) -> int:
	return 0


static func fractures_at(tier: int) -> int:
	return int(FRACTURES[clampi(tier, 0, FRACTURES.size() - 1)])


## The Rupture's size, in beats of the tide (the pacing discussion of 11 November; Ryan: "Try
## your lean first"): a beat is a peak of Rift Pressure, and the meter's field part is what the
## opening places and the tide sends through this many peaks (Battle.setup). Two at every tier:
## the ramp grows what a beat holds by itself (the opening's formations, the tears a peak, the
## beat's length), and more Fractures at a higher tier are for more elites, never to make the
## battle much longer (his word the same day). Placeholder.
const BEATS := 2
## A trial count of beats, 0 for the game's: a debug build's SETTINGS → TRIALS → RUPTURE and
## RIFTGATE_BEATS set it (Settings.field_trial), so he feels one beat or three beside the two.
static var beats_trial: int = 0


static func beats_at(_tier: int) -> int:
	return beats_trial if beats_trial > 0 else BEATS


## The tide's density on trial, in hundredths, 100 the game's (Ryan, 11 November: "I think we
## should try to lean for noticeably more spawns then the minimum number required for our
## target completion speed. When I was playing I felt the need to chase every pack down, since
## that felt possible. I think that's wrong. More pusher and flanker packs, even if it means
## that each needs to do less to the wall, is better"): how many packs the opening places and
## the tide sends against the game's own counts, the Rupture's size left on the game's (the
## length is the meter's, the choice is the tide's: Battle.setup). A debug build's SETTINGS →
## TRIALS → TIDE and RIFTGATE_TIDE set it (Settings.field_trial); the strike a pip beside it
## is Battlefield.strike_trial.
static var tide_trial: int = 100


## A count of the opening's under the tide's trial: `n` of the game's by the trial's
## hundredths, whole packs only and never fewer (half again as many of one is one, of two
## three).
static func dense(n: int) -> int:
	return maxi(n, (n * tide_trial) / 100) if tide_trial > 100 else n


## How many times over the `k`th peak (from one) sends under the tide's trial: the whole
## numbers the trial's running total crosses at it, so half again as many is one, two, one,
## two and twice as many two at every peak. One with no trial.
static func dense_at(k: int) -> int:
	return maxi(0, (k * tide_trial) / 100 - ((k - 1) * tide_trial) / 100) if tide_trial > 100 else 1


static func elite_fractures_at(tier: int) -> Array:
	return Array(ELITE_FRACTURES[clampi(tier, 0, ELITE_FRACTURES.size() - 1)])


## The wall's length: the count of hexes along the wall, the map's width (the long wall, Ryan,
## 5 November: "Wide map, with lots of wall to defend, but not as deep"; the build brief,
## docs/briefs/long_wall_build.md 3.1). A lever of the ramp's, never fixed.
static func wall_length_at(_c: int) -> int:
	return 20   # placeholder (the long wall brief)


## The field's depth: the rows from the rift's row to the last wall row inclusive, the map's
## height (the long wall brief 3.1).
static func depth_at(_c: int) -> int:
	return depth_trial if depth_trial > 0 else 12   # placeholder (the long wall brief)


## A trial depth for the field, 0 for none (Ryan, 10 November, after his play: "I think the map
## is a bit too shallow ... If the map is a little deeper, and the seam starts a little farther
## out, it will feel more like I can actually plan a little bit ahead instead of panicking from
## the very start"): a debug build's SETTINGS → FIELD DEPTH and RIFTGATE_FIELD_DEPTH set it
## (Settings.field_trial), so he finds the number on the phone before the placeholder moves. The
## tears' row starts at a share of the depth with a ceiling (Battlefield.tear_row_start), so a
## deeper field leaves it that much farther from the wall.
static var depth_trial: int = 0

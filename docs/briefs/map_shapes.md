# The map shapes

A generator session's brief: the five map types reworked into six shapes. The movement rule it
builds on landed on 28 October (moves in hexes, ground is ground, water the one priced hex,
crags the flyer's, winged packs crossing, a hunter picking again: the bible's section 4 rows,
`docs/rules.md`'s battlefield part; the proposal it came from retired with the landing, `git
show f6c99d6:docs/movement_proposal.md` for its last full form). Nothing here is built.

## Ryan's direction (28 October)

On whether the five types stay: "I would prefer to rework them into shapes. So heavy water
that runs horizontally (aka, river crossings with fords), heavy water that runs vertically (a
fjord), a mix of small ponds and grouped crags breaking the battlefield into winding paths
(Badlands), Relatively clear (Open Steppe), heavy crags using the ruins tile that run
horizontally with gaps (ruined city), heavy crags that run vertically (gorge or ravines). Does
that work?"

## Claude's read (28 October)

It works, and better than the five: under the new rule a type changes only water and crags,
and each shape tests one thing the rule prices, so the name is the intel and the intel is the
shape. Open Steppe and Rubble Field read nothing since the landing (the bible's map-types
row); the six would each read something.

- **River** (heavy water across the field, with fords): packs funnel through the fords, the
  horde's guaranteed crossing; a ground squad holds a ford or wades (a move of 2 spends two
  turns in a river two wide, a move of 4 one); hover and flyers cross anywhere. Tests the
  crossing held and the wade.
- **Fjord** (heavy water down the field): two lanes for the packs; a ground squad changes lane
  by wading, hover and flyers freely; a hunter on the far bank picks again. Tests lane choice
  and a detachment across water.
- **Badlands** (small ponds and grouped crags, winding paths): packs wind, flyers go straight,
  hover crosses the ponds, ground machines wade them. Tests everything at once, and the
  longest walks.
- **Open Steppe** (relatively clear): no lanes; the baseline the others are read against.
- **Ruined City** (crag bands across the field with gaps, on a ruins base): packs and ground
  squads funnel through the gaps; flyers and winged packs go over. The 3D map already draws a
  crag on a ruins base as dead skyscrapers (`Map3D._crag`, `BattleMap.crag_base`), so the look
  costs no art. Tests the gaps held and the flyer's one crossing of its own.
- **Gorge** (crag walls down the field): lanes with no wading, changed only round a wall's
  ends; flyers and winged packs cross. Tests the hardest commitment to a lane and the re-pick
  across walls.

## What stands, and what the generator needs

- The crossing guarantee stands as it is (three disjoint horde routes, `_ensure_ground_path`
  carving where a shape closes the field): a band across the field is laid with its gaps (two
  or three hexes each, placed by the seed) and checked by the guarantee; a wall down the field
  cuts nothing, and a lane one machine could plug alone is what the guarantee already
  forbids. The field row's "one real water feature" retires with the session: a shape has its
  own features, and three shapes have no water.
- Every shape keeps the rift's mouth and the rows round the boss's ring clear (rows 0 to 3),
  the team's ground and the two rows before the gate clear of water and crags (as today), the
  gate's and the rift's neighbours open, and the roads as art (a city's streets).
- New laying: a band of water or crags across the field with gaps; one or two bands down the
  field (the fjord, the gorge's walls), placed by the seed, from row 4 to the team's ground;
  ponds (the `puddles_t` field grown to two or three hexes); grouped crags (the ridge noise at
  a higher threshold, clustered). The river with fords exists (`_lay_feature`); the lake band
  retires. Thickness and count are each shape's knobs in `BattleMap.KINDS`, every number a
  placeholder: a river two to three thick with one or two fords; a fjord two to three wide;
  city bands one to two thick with one or two gaps; one or two gorge walls one thick.
- The survey (`tools/map_survey.gd`, `--type` a shape) measures each: the ground shares, the
  horde's narrowest crossing and its route length (19 to 20 hexes today; a winding Badlands
  that doubles it changes the pacing, since Rift Pressure fills at 12), and the phases and
  reach by way; `--show SEED` prints a map as text for Ryan's eye, and the harness with
  `RIFTGATE_MAP_KIND` shows it running.
- The campaign draws a shape by the rift's seed, every shape alike, until a domain lean is
  decided (a Lean row, never an exclusion: the Marsh toward water, the Peak toward crags); the
  front card shows the shape's name once the mission map exists.

## Questions for Ryan

1. The names, as the front card will show them: RIVER (or RIVER CROSSING), FJORD, BADLANDS,
   OPEN STEPPE, RUINED CITY, GORGE (or RAVINES).
2. Mixed Ground: retired (Claude's lean: the six replace the five, and the campaign draws by
   the seed), or kept as a seventh for the harness.
3. Domain leans toward shapes, now or later (Claude's lean: later, from play).

## What the session hands back

The shapes in `BattleMap.KINDS` and their laying, the harness picker and `RIFTGATE_MAP_KIND`
on the new names, the survey rerun at 200 seeds a shape (its read in `docs/measurements.md`),
the bible's map-types and field rows rewritten, `docs/rules.md`'s ground bullet, the status and
the to-do; then this brief retires.

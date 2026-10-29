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

## Ryan's calls (29 October)

- **The names**, as the front card shows them: RIVER CROSSING, FJORD, BADLANDS, OPEN STEPPE,
  RUINED CITY, GORGE.
- **Mixed Ground retires** with the session: it tests nothing a shape does not test better,
  and Open Steppe is the baseline. The campaign draws one of the six by the rift's seed.
- **The walls are named by what they are**, one rule under every name (impassable to all but
  a flyer and a winged pack). Ryan: "the busted skyscraper that serves as a ruins crag,
  shouldn't be called a crag". **Crags** are the rock spikes on open ground and in water;
  **Mesas** stand on scrub, the badlands' walls; **Towers** are the dead skyscrapers on ruins,
  the city's; **Cliffs** are a continuous rock wall, a new look, the gorge's. The ground tap and
  a fight's label show the name (today every wall reads "Mountain", the vocabulary's word); the
  rules call the class impassable ground.
- **The decoration is laid to be read.** Plain, road, scrub and ruins all play alike since the
  landing, and every map mixes all four everywhere. Ryan: their placement, and the map types
  they appear on, "can go a long way towards making the map less cluttered and easier to read,
  while still looking believable". So:
  1. A palette per shape: each uses the one or two decorative grounds that belong to it (the
     table), never all four.
  2. Placement that makes sense: roads lead somewhere (to the fords, through the city's gaps,
     to the gate); reeds along the banks, scree at the cliffs' feet, rubble round the towers.
  3. A height gap: decoration knee-high, walls tall, nothing between, measured from the ground
     so a raised hex never lifts a tree above a wall (today a dead tree stands to 40, a ruin's
     wall stub to 32 and a mesa 46).
  4. Calm lanes, busy edges: dense dressing in the margin and against the walls, sparse in the
     open ground the squads play on.

| Front card | Layout | Walls | Water | Dressing |
|---|---|---|---|---|
| RIVER CROSSING | a river across, one or two fords | none, or a crag on a bank | the river | fields, reeds, a road to each ford |
| FJORD | water down the field | none | the fjord | rocky shore, shingle |
| BADLANDS | ponds and grouped mesas, winding paths | mesas | ponds | low scrub, dry ground |
| OPEN STEPPE | relatively clear | a lone crag at most | a pond at most | grass, one road |
| RUINED CITY | bands of towers across, with gaps | towers | none | streets, rubble |
| GORGE | cliff walls down the field | cliffs | none | scree at the cliffs' feet |

Not this session's: the domains' tilesets in the painted bleed, an art task of its own (the
to-do), and any rule on a rift tile (Ryan, 29 October: art only for now; the bible's row on
the landscape twisted by the rift).

## The open question

A domain's lean toward shapes is section 12's (each domain names a map type its rifts lean to:
does it decide the shape, bias it, or stay out?). Until it is answered the campaign draws by the
seed alone. Claude's lean: a lean from play, never an exclusion.

## What the session hands back

The shapes in `BattleMap.KINDS` and their laying, Mixed Ground out of it, the harness picker
and `RIFTGATE_MAP_KIND` on the new names; the walls' names in the vocabulary, on the ground tap
and on a fight's label (by the wall's look, its `crag_base`, the gorge's cliffs a look of their
own); the decoration's palette, placement and height gap in `Map3D`; the survey rerun at 200
seeds a shape (its read in `docs/measurements.md`); the bible's map-types and field rows
rewritten, `docs/rules.md`'s ground bullet, the status and the to-do; then this brief retires.

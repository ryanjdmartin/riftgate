# The pricing run, and the roster's synergy holes: a proposal

The stock pass's tail (the status's order of work, item 2; the to-do's "Prices and tier
ladders"): the run that prices every slottable component against its tier's others, every
module against the catalogue, and the guns' heat against the heat row's test, on the content
as the stock pass landed it (22 October) and the bot as fixed since (the Shock priced at the
hitter in hand, 23 October; a flat buff counted a strike, 25 October). Ryan, 24 October: "we are
still due a heat pricing". This file holds the method, its driver, what the records already say,
the heat pricing's levers, and a read of the roster's synergy holes from the content as it
stands (27 October), until the run is read and Ryan has marked it; then its decisions become
bible rows, fills through `tools/stock_fills.py` and the to-do's catalogue line, and the file
retires (git keeps it). Everything here is Ryan's to move; the numbers are placeholders until
they are measured.

**Status, 27 October**: the method and its driver are built (`tools/pricing_run.py`) and the
run was made the same day in the cloud session (393 variants, 188,640 fights, about three hours
on four cores; the run and its tables in `docs/measurements.md`, 27 October, the pricing run);
what it says is section 2, the heat read section 3, and the structure for Ryan's marks section
6. Reviewed 28 October against what landed since the run (section 0): the numbered area and
the blow's order on main, the ladder's design goals on the fresh start's branch and Ryan's
direction on component tiers; the area carriers and the modules that read them rerun on the
merged head (`docs/measurements.md`, 28 October). The synergy map (section 4) is generated from
content by `tools/synergy_map.py` and is current; the holes (section 5) are Claude's read of it,
hole E measured.

**Read first**: the bible's balance rows (section 11: "Every stat and passive has a price,
measured"; "A component is balanced against the components of its tier; a chassis alone is a
diagnostic"), its heat row (section 5), its modules, tags and catalogue rows (section 7 and
10), the tiers row (section 10); `docs/measurements.md` of 22 and 23 October (the bands, the
starter trios, the built teams, the endgame fours); `docs/balance.md` (the pick shares and the
heat section); the retired stock pass brief (`git show a550c2e:docs/briefs/stock_pass.md`) for
the heat classes and the first fills.

## 0. What changed under the run (28 October)

The run was made on main's head of the 27th (`e59691d`). Since then, on main: area is numbered
(Spread N, Penetrate N and Splash N, the half retired: the Claw and the Plow Spread 2, the
Enfilade Beam Penetrate 3, the Airburst Shell and the Flakshot Spread 1, the Musk Ox's two guns
Splash 1, the drum 2 and 2; the Howitzer's and the Meteor's Splash open in section 12), the
blow's order puts the firer's modifiers on every blow and each foe's own reads after (so a
firer's point lands on every strike and every area foe), the Marsh formation holds the Zombie
Knight pair, and the 200-seed report of the 27th is the baseline (`docs/measurements.md`). On
the fresh start's branch (`ccr-6073bda9-p34o8q`, unmerged): the ladder, twenty-six recolours
by tier with the spawn lists by tier and the runner's cells for them ("meadow formation tier
2"), the three verbs (Silence muting keywords, Purge taking what a die face bought, a foe's
Cleanse), four buffs crossing to the foes and the player's Purge on the Null Field Emitter.

Two decisions of the 28th bear on this proposal directly:

- **What the tiers buy** (the bible's section 3 row, measured on the fresh start's branch):
  never-inflate is an aspiration; "with component tiers and synergy payoffs, inflation is just
  a matter of course for some units", and a tier's units need "on average bigger numbers than
  tier 1 just to stay relevant", a floor set against the tier's kit; the measurement grouped
  the 27 October matrix by chassis tier and found the tiers' kit buying options more than
  numbers (a weapon's number times its strikes means 2.2, 3.5, 3.2 and 4.0 at tiers zero to
  three), which is this run's finding from the other side.
- **Ryan's direction on component tiers** (28 October, the to-do's pricing line on that
  branch): tier two and three "need to feel worth it to upgrade to", plain number increases
  beside the keywords, "especially to shield and vent", since "if there isn't sufficient
  pressure to replace equipment, the economy becomes pointless", the raw DPS arms race on both
  sides a big factor.

So the run's read that tier two buys no kill time over tier one is no longer a question of
whether tiers are a power ladder for guns: it is the measurement of the step Ryan wants and the
content lacks. Section 2's structure for the marks is rewritten on that (the tier steps, the
equipment ramp first), section 1's benches become the tiers' fights once the ladder lands, and
the area carriers and the modules that read every blow were rerun on the merged head (below).
What stands untouched by the changes: the heat read (section 3), the dead equipment and the
setups under the greedy, the three verdicts on the bot, the knock-outs as directions, and the
holes but G (sharper) and H (the Purge).

## 1. What the run measures, and how

The bible's row (Ryan, 12 October) names three measures: a component against its tier's
others in the same hardpoint of the same machines (its value and its pick share), the team
rows, and whole runs; a chassis alone is a diagnostic. The driver reads the first two; whole
runs are the campaign runner's and cost four minutes a variant, so they are run by hand on the
top and bottom of each ladder once the ladders have named them (`tools/stock_loop.py run
<name> --lever set:...`, a copy with the piece in a stock).

Four parts, each one balance-runner process a variant, its `--set` and `--fit` applied in
memory (content is never written; the report goes to the run's folder, never
`docs/balance.md`), on the records' team rows as `--team` rows, against the sixteen big fights
but the finale (the four massive foes, the four formations, the eight finals: the finale is a
wall for every trio, and a wall reads nothing), greedy play at 30 seeds a cell:

| Part | What it reads | Variants | Fights |
|---|---|---|---|
| The stock rows | the baseline every delta is read against: the four team rows and the Arsenal bench's row | 5 | 2,400 |
| Knock-outs | each stocked piece out of its own row, the hardpoint left empty (or the basic of its kind in its place, `--knock basic`): a piece's worth to its row, and a stock's filler | 51 | 24,480 |
| Tier ladders | every slottable component (48: eight basics, 24 of tier one, 14 of tier two, two of tier three) in the same hardpoint of the same machine, five benches | 240 | 115,200 |
| The module ladder | every module fitted alone to the bench machine, the same five benches | 85 | 40,800 |
| The heat ladder | every attack a step hotter, the cold basics alone at 1, and cooling 0, on the four team rows | 12 | 5,760 |

The benches (`BENCHES` in the driver), each a role the roster's pieces are priced on, the
candidate going into the slot in place of the stock piece there:

| Bench | Hardpoint | Why |
|---|---|---|
| The Honey Badger, in the default team (with the Clydesdale and the Kite) | its first, the Rivet Gun | a heavy tank with armour 2 and cooling 1, a five-entry die, two locked pieces: a found piece on a tank |
| The Prairie Dog, in Wainwright & Sutler's team (with the Clydesdale and the Dingo) | its first, the Twin Autoguns | a light car beside a Flak layer and a Shock: the setup pieces and the strikes read here |
| The Puffin, in Kestrel's team (with the Kite and the Buzzard) | its fourth, the Laser Carbine | a light escort beside two hot kits: equipment, ally vents and ally shields read here |
| The Buzzard, in Kestrel's team | its third, the Arc Fault Cannon | a hot flyer (maximum 14, cooling 1, a Railgun of 8): a gun's heat is priced where heat bites |
| The Nemesis, beside the Ammit and the Puffin | its first, the Plasma Arquebus | the Arsenal's bruiser beside the Ammit: the Volatile pieces, the Thurible and the hull-damage loops read here |

The reads, and what each moves (the decision rules the summary's flags stand for):

1. **A tier's band.** Within a tier on a bench, the spread of the candidates' deltas against
   the stock row is the band; a piece above its tier's band on every bench is underpriced (its
   number or its heat moves, or its tier), one below on every bench is overpriced or dead.
   Asymmetry is wanted (the design tests' parity row): a piece reads differently on the tank
   and on the car by design, and only a piece ahead or behind everywhere is a price question.
2. **The tier ladder.** A tier-N piece under the best of tier N minus one on every bench says
   its tier is wrong, or that the lower piece's is: the flag `under tier N-1`.
3. **Pick share**, the component signal (the bible's balance row): a candidate the bot spends
   under about 5% of the row's spends is dead on that bench (`dead`), one over about 35% is the
   whole die (`the die`). A dead piece is a question for the bot before it is one for the
   price: the Entropy Condenser's 0% on the Ammit (the 200-seed bands) is the greedy holding a
   vent that costs hull, read on a trace before its number moves.
4. **Heat.** A candidate that overheats the bench a fight more than stock is very hot there
   (`hot`): its number must pay for it, or its heat comes down a class. The Buzzard bench is
   the one where every gun's heat is felt.
5. **Knock-outs.** A stock piece worth nothing to its own row (no drop without it) is filler in
   that stock: the stock's question (the tiers row: a tier one shows its identity with basics
   alone), never the piece's price. The stock pick shares of the bands already name the
   candidates (the Coolant Jacket at 1 to 6% on ten kits, the Combat Translocator at 1%).
6. **Modules.** The Ram Frame's and the Artillery Rangefinder's stat lines come from this run
   (the catalogue row, 22 October): each is set so its delta sits inside tier two's band on the
   benches where its rule reads (the Frame on the Direct benches, the Rangefinder beside an
   Indirect kit), and a module ahead of every other on every bench is the universal must-pick
   the modules row forbids. The two "bad text" modules (the Exotic-matter Shell, the Tithe
   Coupling) are read on the bench where their text is a key (the Nemesis's) as well as where
   it is a price.

**Once the ladder lands** (section 0), the benches read by tier: a tier's candidates on the
tier's fights (the runner's "meadow formation tier 2" and "tier 3" cells and the recolours'
own, `--packs`), tier one's on today's, so that "a component against its tier's others" is read
where the tier's units set the floor; the driver's `--packs` takes the ids, and its default
list follows the spawn lists by tier when the factions' file carries them. The Marsh formation
holds the Zombie Knight pair since the 27th, so the four rows' Marsh cells read harder than
the run's, as the rerun's stock rows show.

The bands: 30 seeds a cell is a direction (a cell near 50% carries about 18 points, a row
mean about 4), so the summary ranks and flags, and a delta a number lands on is read again at
200 seeds (`--seeds 200` on the variants it names) before the fill. The caveats the bible's
price row already carries hold: one bot, a win rate that saturates on a team row (the rounds and
the hull lost carry the read where the wins sit at 100), and a setup's worth read within a round
(the planner is the rung for a piece whose worth is two rounds out; `--policies greedy,planner`
on the variants that need it). Equipment aimed at allies reads only on a team row, which is why
the ladders run on them and never alone.

How it lands: the fills through the stock pass's applier (`tools/stock_fills.py`, its tables
edited, the script run), on Ryan's marks of the structure, never a hundred numbers (the scales
row); every run a decision cites in `docs/measurements.md`; each decision its bible row.

The commands (the README has them):

```sh
python3 tools/pricing_run.py plan                      # the variants and their fights, nothing run
python3 tools/pricing_run.py run prices                # about two and a half hours on four cores; resumable
python3 tools/pricing_run.py summarise prices          # build/pricing/prices/summary.md, a partial run included
python3 tools/pricing_run.py run heat --parts heat --policies random,greedy   # the heat ladder alone, with the decision read
```

## 2. What the run says

The run as made (`docs/measurements.md`, 27 October: the stock rows, the knock-outs, the
cross-bench ladder table, the tiers' bands, the module ladder, the heat ladder, the Ammit's
fits). A direction at 30 seeds; every row wins 99 to 100% of these cells, so the reads are the
rounds to win, the hull lost, the pick shares and the heat columns.

1. **The benches are too strong for most of the read.** Four rows win these sixteen fights in
   2.9 to 4.9 rounds for 5 to 10% of their hull, so one hardpoint moves them by a third of a
   round at most and a shield has nothing to save; Wainwright & Sutler's row (5.9 rounds, 18%
   hull) carries the ladder. Guns price by kill time there; equipment and the setup pieces do
   not price on this run at all (below). The next run is a harder bench: the four formations
   and the two breaching bosses alone, the planner beside the greedy (the setups' rung), on
   Wainwright & Sutler's row and a starter trio without a carry, or the fresh start's
   compositions once they exist.
2. **Tier one's ceiling is tier two's, and the tiers do not step.** The Arc Fault Cannon and
   the Overclocked Railgun (1.7 and 1.9 rounds off the car, 0.5 off the five benches' mean) sit
   at or above every tier-two gun (the Meteor Artillery, the Cyclic Cannon, the Tesla
   Gauntlets) and the tier-three Gravity Knuckles; the next tier-one guns (the Thermal Ray, the
   Blazethrower, the Transonic Rifle) sit with tier two's, and the rolled tier-one guns a step
   above the basics. A tier-two gun buys no kill time a tier-one gun does not, and the content
   says why: a gun's number times its strikes means 2.2 at tier zero, 4.1 at tier one, 3.6 at
   tier two and 4.0 at tier three on the merged head (thirteen, nine and two guns), and the
   equipment runs flat or backwards (shields: the basics 6 and 8, the Oblation Mantle 10 at
   tier one, the Laminar Deflector and the Corona Shield 6 at tier two; vents: the basics 4
   and 6, the Radiator Sail 5 and the Sublimator 4 at tier one, the Condenser 10 at tier two
   for 3 hull). The Stoker reads as the Blazethrower on every bench at a third of the heat: a
   tier step paid in heat alone. This is the step Ryan asked for on the 28th and the content
   lacks (section 0), measured.
3. **Heat prices show where heat bites, and nowhere else.** The Railgun pays half an overheat a
   fight on the car and holds the Buzzard's dice; the Thermal Ray and the Meteor sit at the
   maximum on the hot kits; the Buzzard's cool Arc Fault Cannon is the best piece in its own
   slot by a third of a round. The heat ladder (section 3) says a class up on every attack
   doubles the hot rows' overheats and leaves the cold rows cold, with no row's rounds moved.
4. **Equipment is dead under the greedy on these packs.** Every shield, vent and buff reads 1
   to 8% of a row's spends and a fifth to a half of a round behind the stock gun; the Entropy
   Condenser is never spent on any bench, and the Oblation Mantle, the Radiator Sail, the
   Phased Sublimator, the Wake Diffuser, the Shoring Jack, the Retribution Thurible, the Aurora
   Lattice and the Proximity Klaxon 1 to 5%. The one with a read is the Blast Door (a round
   slower for 2 to 7 points of hull saved), the Barrier's shape working as decided. The setups
   on the car read small (the Flak Cannon 1.1 rounds off at 17%, the Overcharge Coil 0.1 at
   11%, the Suppression Battery and the Backdraft Charge 0.1 at 12 to 15%, the Polarity
   Projector 0.1 on at 9%), so the Backdraft's and the Battery's numbers (the to-do) wait on
   the harder bench too.
5. **Three verdicts on the bot before any price.** The Differentiation Probe reads worse than
   an empty hardpoint on four benches (a Disrupt the greedy spends onto moves that cost the row
   more); the Condenser's 0% is the greedy never venting unless an overheat threatens (the heat
   ladder: it holds dice instead); the Ammit's loop never spins because the greedy halves the
   Ammit's spends under the Tithe's price rather than feed a stack a spend that pays later. The
   to-do's valuation line (a Disrupt, a vent that costs hull, a loop two rounds out) comes
   before those three pieces' numbers; the planner is the rung to read them on.
6. **The modules.** The Ram Frame is the first module on every bench, the universal pick the
   modules row forbids, with the catalogue's biggest stat line (hull +24, the placeholder this
   run was to set) beside a point on every Direct blow at the front, strikes included; the
   Artillery Rangefinder read nothing because no bench machine stocks an Indirect gun (the
   method's one hole: its mirror needs an Indirect bench); the Tensor reads beside setups, the
   Booster and the Databank alike on rolled guns and not at all on flat ones; the stat modules
   move a point or two of hull; the Tithe Coupling is a loss on four benches and the Nemesis's
   one trade of hull for rounds.
7. **The knock-outs.** Ten of 51 move their row by a fifth of a round or two points of hull:
   the Dingo's Airburst Shell, the Kite's Transonic Rifle, the Clydesdale's Enfilade Beam and
   Maxigun, the Buzzard's Arc Fault Cannon and Railgun, the Puffin's Laser Carbine, the
   Armadillo's Twin Autoguns; every stock's shields and vents read as their row, and the
   Prairie Dog's Halo Shield out makes its row quicker. On these packs the stocks' equipment is
   filler to the greedy; the stock's question, with the harder bench.
8. **The rerun on the merged head** (section 0; `docs/measurements.md`, 28 October): the rows
   read a little harder with the Marsh's Knights (Wainwright & Sutler's 99.6 to 93.5% won, 18
   to 24% hull), and every candidate's delta on the car holds within a tenth of a round and a
   point or two of hull under the numbered area and the blow's order, so the ladders stand;
   the Ram Frame reads two points of hull more (its point on every area foe). The Splash
   what-ifs: the Howitzer at Splash 1 takes 0.9 rounds off the row (0.5 plain), at Splash 2
   1.2, a tier-one shell at tier two's kill time for heat 1; the Meteor Artillery at Splash 1
   or 2 takes 2.4 off, the most of any piece on this bench, the same at both numbers, because
   its Burn 3 rides every foe struck: on the Meteor the rider is the lever, not the number.

The structure for the marks (Claude's leans, rewritten 28 October on Ryan's direction; nothing
lands before them, and a delta a number lands on is read again at 200 seeds):

- **A tier is a step on the plain number, the keywords beside it.** The fill the loops read:
  a flat Direct gun 3 at tier zero, 4 to 5 at tier one, 6 to 7 at tier two and 8 to 10 at tier
  three at the same heat class (the scales row's 1 to 6, big guns to 10, the capstone 12), a
  rolled gun's middle the same step, a keyword gun a point under the plain one of its tier; so
  tier two is more number for the same heat, which is what "worth it to upgrade" means on a hot
  kit, and the heat classes stand (section 3). The two outliers of tier one then sit inside the
  band or above it: the Railgun at 10 is tier three's number on a tier-one piece, so it moves
  up a tier or its heat stays its price (it pays: half an overheat a fight on a 12-maximum kit),
  Ryan's call; the Arc Fault Cannon's lever stays the Chain's rework (section 12).
- **The equipment ramp first**, Ryan's "especially to shield and vent": a shield's number by
  tier 6 and 8 at zero, 10 at one, 12 at two, 16 at three (the scales row's 6 to 16), a keyword
  shield two under the plain one of its tier (so the Laminar Deflector and the Corona Shield
  at 10, the Oblation Mantle's 10 at tier one its Volatile's price); a vent 4 and 6, then 6,
  8 and 10 (the Condenser's 10 the capstone, paid in hull; the Sail and the Diffuser a step
  under); a buff's stacks or rounds a step a tier (the Coil 2 at one, a tier-two Overcharge 3).
  What it buys the economy: a found tier-two shield replaces the basic by its number, which
  today it does not.
- **The enemy's floor follows the tier's kit** (section 0): the ladders are read per tier on
  the fresh start's formations and recolours, the tier's pieces on the tier's fights, and the
  recolours' numbers set where a tier-N kit meets them as a fight (the fresh start's own
  measurement, the 200-seed matrix with the ladder's cells on the to-do). The two ramps are set
  together, never one against today's enemy: the run read on the tier-one enemy says a step
  lands as kill time, which is the lever; whether it is the right size is the tiered read's.
- **The Ram Frame's hull line comes down to the catalogue's band**, from +24 to about +8 (the
  Ablative Plating's +8, the Flak Skirt's +6, the Reliquary's +4), so the module is its text;
  under the blow's order its point lands on every area blow too, so the rerun on the merged
  head (below) is its read; the Artillery Rangefinder takes the same line and is read on an
  Indirect bench (the Clydesdale's Howitzer slot in Wainwright & Sutler's row) before either
  lands.
- **No equipment or setup number moves on this run.** The pressure to replace equipment Ryan
  wants needs two things the run lacks: a bot that spends equipment (the planner, or a
  cautious persona that vents and shields before the overheat) and fights where a shield
  saves hull (the tiered formations; the Marsh with its Knights already walls a trio). The
  equipment ramp above is set by its numbers and read there.
- **The heat classes stand** (section 3), and with them the guns' heat the Storm Petrel's
  brief waited on: its engine session is free to run on today's heats once these marks are in,
  its hole (2 shield a spend on basics alone) read on them; a tier step on a gun's number at
  the same class is more shield burnt a spend on that machine, its own read.
- **The pool's size** (section 12's 50 to 75 against 41): the run adds no pressure to grow it;
  the dead pieces are the bot's before they are the pool's.

## 3. The heat pricing

Ryan, 24 October, with the foes' heat doubled: "Don't worry about the storm petrel yet, as I
think we are still due a heat pricing". The heat row's test (Claude's placeholders until play):
a build that runs hot overheats by about its third round of firing without a vent; a cold build
is a healthy build and pays somewhere else, never for free; the worst case is slack, a kit with
the hot build's damage that ends the fights that matter with budget unused. The levers the row
names: the maxima, cooling, the weapons' heat and the vents' numbers. The heat classes the
stock pass set by niche (its retired brief): a rolled basic cold or cool (0 or 1), a flat basic
warm (2), a keyword piece warm to hot (2 to 4), a big flat gun very hot (6 or 8), a Rapid piece
paying heat as its price.

What the run read (`docs/measurements.md`, the heat ladder):

- **A class up on every attack** (`step`: 0 to 1, 1 to 2, 2 to 3, 3 to 4, 4 to 6, 6 to 8, 8
  to 10) doubles the hot rows' overheats (Kestrel's 0.29 to 0.56 a fight, its peak 93 to 116%,
  its hull burned 1.0 to 2.4; the default team's 0.21 to 0.35) and leaves the cold rows cold
  (Minerva's peak 31 to 55% with nothing held, Wainwright & Sutler's 33 to 67%), with no row's
  wins or rounds moved: heat is a price the hot kits pay in hull, and the cold rows do not reach
  it even a class hotter, since their price is their numbers.
- **The cold basics at 1** (`cold1`: the eleven heat-0 attacks) move the peaks 2 to 9 points
  and nothing else: no Jacket's job appears, because the greedy answers heat by holding a die
  (the dice held nearly double under a class up) and never by venting (the Jacket's share 0.9
  to 2.5% stock, 1.2 to 4.0% a class up). The Jacket's job is a question for a bot that vents
  before the overheat (the to-do's heat report) before it is one for the basics' heat.
- **Cooling 0** warms every row, the hot one to 103%, as the 22 October loop read.
- **The heat columns on the ladders**: on the car (maximum 12) the Railgun peaks at 107% with
  0.51 overheats a fight (0.13 stock), the Meteor and the Thermal Ray 89% and 0.28, the
  Transonic Rifle 66%; on the Buzzard (maximum 14) every warmer candidate than its Arc Fault
  Cannon holds dice (0.21 to 0.27 a fight against 0.07), the Railgun at 105% and 0.58, the
  Thermal Ray and the Meteor at the maximum. A gun's heat is a real price on the kits that
  carry it and free on the cold rows, which is the heat row's design.

Claude's lean, for the marks: the class ladder stands (0, 1, 2, 4, 6, 8), pieces moved between
classes rather than new steps, so the player reads six heats and not twenty; the basics stay
cold (`cold1` bought nothing); the hot flat guns (the Transonic Rifle at 4, the Thermal Ray at
6, the Railgun at 8) are the anchors, a point of heat for a point of number above the warm
basic's 3, and the run reads them paying; no gun's heat moves on this run, and a vent's number
follows the guns it answers. The Storm Petrel's price list is the guns' heat as it stands, so
its engine session is free once these marks are in. The foes' side stays the fresh start's (the
status's item 3), and Ryan's play on the Peak decides whether the doubled stacks hold.

## 4. The synergy map

Generated from content by `tools/synergy_map.py --write` (rerun after any content change):
every status and resource, who sets it and who reads it. A setter puts it on the field; a
reader is anything whose worth changes because it is there, the engine's own rule first where
the currency pays by itself.

<!-- synergy-map:start (generated by tools/synergy_map.py from content: edit the content and rerun, never these lines) -->
| Currency | Side | Set by | Read by |
|---|---|---|---|
| Burning | on a foe | Incendiary Shells (tier 1), stocked; Solar Flare Array (locked, Baboon); Gravity Knuckles (tier 3); Blazethrower (tier 1), stocked; Meteor Artillery (tier 2); Photosphere Lance (locked, Stingray); Stoker (tier 2) | its tick: 1 HP a stack at the foe's action, past armour; Backdraft Charge (tier 2): gated on it; Backdraft Charge (tier 2): consumes it; Baboon's Pocket Paradox: counts it; Susceptibility Tensor (module, tier 1): any status |
| Flak | on a foe | Flakshot Repeater (locked, Prairie Dog); Shrapnel Recuperator (locked, Musk Ox); Airburst Shell (tier 1), stocked; Flak Cannon (tier 2) | every blow of a damaging weapon it takes, +1 a stack, a 0 included: most on strikes; Suppression Battery (tier 2): gated on it; Maxigun (tier 1), stocked: strikes; Unrestricted Expenditure (locked, Musk Ox): strikes; Flechette Pod (locked, Skua): strikes; Cyclic Cannon (tier 2): strikes; Baboon's Pocket Paradox: counts it; Prairie Dog's Track-Dispersing Tyres; Susceptibility Tensor (module, tier 1): any status |
| Shocked | on a foe | Megataser Harpoon (locked, Dingo); Polarity Projector (tier 1), stocked; Tesla Gauntlets (tier 2) | the next damaging blow it takes, doubled: most on one big blow; Overclocked Railgun (tier 1), stocked: a big blow; Knuckle of Fury (locked, Nemesis): a big blow; Gravity Knuckles (tier 3): a big blow; Meteor Artillery (tier 2): a big blow; Thermal Ray (tier 1), stocked: a big blow; Transonic Rifle (tier 1), stocked: a big blow; Baboon's Pocket Paradox: counts it; Susceptibility Tensor (module, tier 1): any status |
| Exposed | on a foe | Spotting Flare (locked, Swallowtail); Syrinx Drone (locked, Lammergeier); Fovea Designator (locked, Needletail) | Direct reach to it wherever it stands, and its armour counts for nothing; Baboon's Pocket Paradox: counts it; Susceptibility Tensor (module, tier 1): any status |
| Cryo | on a foe | Cryo Flinger (locked, Armadillo) | any machine's damaging hit on it spends every stack and cools the hitter 2 a stack; Baboon's Pocket Paradox: counts it; Susceptibility Tensor (module, tier 1): any status |
| Suppressed | on a foe | Suppression Battery (tier 2); Umbra Inducer (tier 3); Web Bomb (locked, Funnel-web); Spotting Flare (locked, Swallowtail): charged; Backdraft Charge (tier 2); Baboon's Pocket Paradox | it loses its next action (Numbed is the brake); Baboon's Pocket Paradox: counts it; Susceptibility Tensor (module, tier 1): any status |
| Webbed | on a foe | Web Bomb (locked, Funnel-web) | the burst at the end of its action: it and its neighbour Suppressed; Baboon's Pocket Paradox: counts it; Susceptibility Tensor (module, tier 1): any status |
| Vitriol | on a foe | Funnel-web's Ambush | its tick: 10% of its current HP a stack, past armour; Baboon's Pocket Paradox: counts it; Susceptibility Tensor (module, tier 1): any status |
| Syrinx Drone | on a foe | Syrinx Drone (locked, Lammergeier) | the next kill on it leaves a mine in its slot; Baboon's Pocket Paradox: counts it; Susceptibility Tensor (module, tier 1): any status |
| Paradox | on a foe | Baboon's Pocket Paradox | at three, Suppressed; Susceptibility Tensor (module, tier 1): any status |
| A foe's turn drawn (Lure) | on a foe | Proximity Klaxon (tier 1); Cryo Flinger (locked, Armadillo); Heliographic Siphon (locked, Whip Scorpion); St. Elmo's Regenerator (locked, Storm Petrel) [planned] | every foe reached turns on the spender, so whatever reads being struck pays (Retaliate, a Barrier, the Armoured and Sealed plate, and every reader of hull damage) |
| A foe's move changed (Disrupt) | on a foe | Differentiation Probe (tier 2) | the foe takes its next open move |
| A foe's place changed (Swap) | on a foe | Combat Translocator (locked, Dingo) | the two trade places: reach, the acting order, area |
| Overcharged | on a machine | Soulcutter Talons (locked, Ammit); Overcharge Coil (tier 1), stocked; Reheat Uplink (locked, Giant Petrel) [planned]; Grievance Reliquary (module, tier 2) | every blow +1 a stack: most on strikes; halves each round; Maxigun (tier 1), stocked: strikes; Unrestricted Expenditure (locked, Musk Ox): strikes; Flechette Pod (locked, Skua): strikes; Cyclic Cannon (tier 2): strikes; Ammit's Quintessence Tap: keeps it |
| Armoured | on a machine | Breaching Plow (locked, Wild Boar); Shoring Jack (tier 1); Heliographic Siphon (locked, Whip Scorpion); Armadillo's Lockdown; Phase Conjugator (module, tier 2) | armour +1 a stack until the round's end |
| Primed | on a machine | Aurora Lattice (tier 2) | every blow lays a Burning stack a stack: most on strikes; Maxigun (tier 1), stocked: strikes; Unrestricted Expenditure (locked, Musk Ox): strikes; Flechette Pod (locked, Skua): strikes; Cyclic Cannon (tier 2): strikes |
| Retaliate | on a machine | Retribution Thurible (tier 1), stocked | a foe striking bare hull is Shocked, so every reader of Shocked |
| Barrier | on a machine | Blast Door (tier 1) | the next blow deals nothing |
| Ward | on a machine | Decoherence Veil (tier 1) | no rider lands this round |
| Spun Up | on a machine | Spin-Up (locked, Cassowary) | the next weapon spend +2 a stack |
| Rallied | on a machine | Reveille Horn (locked, Swallowtail); Immelmann Booster (locked, Giant Petrel) [planned] | one reroll more this round |
| Phased | on a machine | Mooring Screens (locked, Swallowtail): charged | untouchable until the round's end |
| Sealed | on a machine | Armadillo's Lockdown | armour +3, cooling stopped, 3 heat a turn |
| Regenerating | on a machine | St. Elmo's Regenerator (locked, Storm Petrel) [planned] | 2 shield a round for three rounds (planned) |
| Burning | on a machine | Stoker (tier 2); Drake's Stoke (foe) | +1 heat a stack at the turn's end; Corona Shield (tier 2); Phased Sublimator (tier 1) |
| Scorched | on a machine | Bomb's Flare Up (foe); Salamander's Bite (foe); Drake's Breath (foe); Magma Elemental's Eruption (foe); The Black Mage's Fire (foe); The Black Mage's Fira (foe); The Summoner's Pyroclasm (foe) | every weapon fired runs 1 hotter a stack this turn; Corona Shield (tier 2); Phased Sublimator (tier 1) |
| Disabled | on a machine | Cockatrice's Stone (foe) | the entry comes up blank; Corona Shield (tier 2); Phased Sublimator (tier 1) |
| Corrupted | on a machine | The Thief's Mug (foe); The Summoner's Diamond Dust (foe) | each spend bites 3 a stack; Corona Shield (tier 2); Phased Sublimator (tier 1) |
| Hot Streak | on a machine | Kite's Disabled Weapon Regulators | its shots run 1 hotter a stack this fight: the Kite's own price |
| This machine's heat | a resource | every weapon with heat (43 pieces); Heliographic Siphon (locked, Whip Scorpion); Stoker (tier 2); Kite's Disabled Weapon Regulators; Armadillo's Lockdown; Thrust Overboost (module, tier 3) | the overheat: hull one for one past the maximum; Afterburner Cannon (locked, Buzzard); Buzzard's Thermal Recoupler; Stingray's Exothermic Suite: deepens every stack by it; Whip Scorpion's Thermal Ejection Manifold; Musk Ox's Desublimation Forge; Storm Petrel's Riot Field Generator: planned [planned]; Giant Petrel's Maverick's Playbook: planned [planned]; Boundary-layer Bleed (module, tier 1) |
| An ally's heat | a resource | nothing | Coolant Jacket (tier 0), stocked; Radiator Sail (tier 1); Entropy Condenser (tier 2), stocked; Phased Sublimator (tier 1); Wake Diffuser (tier 1); Puffin's Slipstream Projector |
| Hull damage taken | a resource | Umbra Inducer (tier 3); Entropy Condenser (tier 2), stocked; Oblation Mantle (tier 1), stocked; Tithe Coupling (module, tier 3) | the injury roll at a quarter of maximum hull in one blow; Nemesis's Crucible Capacitor; Spall Liner (module, tier 2); Grievance Reliquary (module, tier 2) |
| A shield granted to an ally | a resource | Laminar Deflector (tier 2); Corona Shield (tier 2); Halo Shield (tier 0), stocked; Backwash Ionizer (locked, Puffin); Oblation Mantle (tier 1), stocked; Mooring Screens (locked, Swallowtail); Sutler's Hoist (locked, Swallowtail) | Puffin's Slipstream Projector; Phase Conjugator (module, tier 2) |
| A kill | a resource | nothing | the slot clears: Direct opens on the foe behind (every weapon sets it); Pinion Driver (locked, Kite); Arc Fault Cannon (tier 1), stocked; Soulcutter Talons (locked, Ammit); Spindrift Salvo (locked, Giant Petrel) [planned]; Kite's Disabled Weapon Regulators |
| The team's rerolls | a resource | Spindrift Salvo (locked, Giant Petrel) [planned]; Clydesdale's Battery Director; Trim Tabs (module, tier 2); Mandragora's Scream (foe); The Thief's Steal (foe) | three a round, unbanked; Immelmann Booster (locked, Giant Petrel) [planned]; Cassowary's Indexed Cylinder; Swallowtail's Muster Deck |
| A foe's missing HP | a resource | nothing | Coriolis Accelerator (tier 2) |
| The rank a blow is aimed at | a resource | Combat Translocator (locked, Dingo) | Direct reaches the front, Indirect any; Cottonmouth's Adaptive Munitions Drum; Ram Frame (module, tier 2); Artillery Rangefinder (module, tier 2) |
| A rolled weapon | a resource | Chainsaw Claw (locked, Honey Badger); Shotfire Rack (tier 1), stocked; Slugthrower (tier 1), stocked; Twin Autoguns (tier 0), stocked; Ankle Mortar (tier 0), stocked; Howitzer (tier 1), stocked; Incendiary Shells (tier 1), stocked; Suppression Battery (tier 2); Breaching Plow (locked, Wild Boar); Megataser Harpoon (locked, Dingo); Plasma Arquebus (tier 1), stocked; Maxigun (tier 1), stocked; Flechette Pod (locked, Skua); Spindrift Salvo (locked, Giant Petrel) [planned]; Airburst Shell (tier 1), stocked | Muzzle Velocity Booster (module, tier 2); Tactical Databank (module, tier 2) |
| Several blows a spend | a resource | Chainsaw Claw (Spread 2) (locked, Honey Badger); Enfilade Beam (Penetrate 3) (tier 1), stocked; Proximity Klaxon (Spread a debuff's, no number) (tier 1); Breaching Plow (Spread 2) (locked, Wild Boar); Flakshot Repeater (Spread 1) (locked, Prairie Dog); Maxigun (tier 1), stocked; Shrapnel Recuperator (Splash 1) (locked, Musk Ox); Unrestricted Expenditure (Splash 1) (locked, Musk Ox); Flechette Pod (locked, Skua); Airburst Shell (Spread 1) (tier 1), stocked; Cyclic Cannon (tier 2); Wild Boar's Juggernaut Drive; Cottonmouth's Adaptive Munitions Drum; Skua's Split-cycle Breech | each strike takes the foe's conditions and armour on its own |
| A mine | a resource | Syrinx Drone (locked, Lammergeier); Lammergeier's Fuse-delayed Bay | whoever steps in takes every shot waiting; Lorentz Contractor (locked, Lammergeier) |
| Ammo | a store | Shrapnel Recuperator (locked, Musk Ox); Quick Reload (locked, Musk Ox); Musk Ox's Desublimation Forge | Unrestricted Expenditure (locked, Musk Ox) |
| The Muster | a store | Swallowtail's Muster Deck | Mooring Screens (locked, Swallowtail); Spotting Flare (locked, Swallowtail); Sutler's Hoist (locked, Swallowtail); Reveille Horn (locked, Swallowtail) |
| Rage | a store | Nemesis's Crucible Capacitor | Knuckle of Fury (locked, Nemesis) |
| The hopper | a store | Chainsaw Claw (locked, Honey Badger) | Bullion Fragmenter (locked, Honey Badger) |
| A foe's buffs (Armoured, Kindled, Getting Back Up; Primed, Barrier, Ward and Regenerating once the ladder lands) | on a foe | Dire Wolf's Howl (foe); Antlion's Burrow (foe); Sandworm's Burrow (foe); Zombie Knight's Reraise (foe); Magma Elemental's Stoke the Forge (foe) | each has an answer beside a purge: kill, suppress or disrupt the rallier, Expose or breach the brace, pop a Barrier with a cheap blow, wait out a Ward, burst what regenerates |

Tags, by the slottable pieces that wear them (locked in brackets); nothing but the screen's lunge reads one:

| Tag | Slottable | Locked |
|---|---|---|
| Ballistic | 14: Slugthrower, Twin Autoguns, Ankle Mortar, Howitzer, Incendiary Shells, Suppression Battery, Overclocked Railgun, Rivet Gun, Maxigun, Transonic Rifle, Airburst Shell, Cyclic Cannon, Flak Cannon, Stoker | 6: Bullion Fragmenter, Flakshot Repeater, Megataser Harpoon, Shrapnel Recuperator, Unrestricted Expenditure, Flechette Pod |
| Missile | 2: Shotfire Rack, Meteor Artillery | 5: Cryo Flinger, Web Bomb, Spotting Flare, Unrestricted Expenditure, Spindrift Salvo |
| Beam | 5: Enfilade Beam, Pulse Vacillator, Laser Carbine, Differentiation Probe, Thermal Ray | 2: Photosphere Lance, Heliographic Siphon |
| Plasma | 6: Umbra Inducer, Gravity Knuckles, Plasma Arquebus, Blazethrower, Meteor Artillery, Backdraft Charge | 3: Solar Flare Array, Afterburner Cannon, Knuckle of Fury |
| Flame | 4: Incendiary Shells, Blazethrower, Stoker, Backdraft Charge | 2: Solar Flare Array, Photosphere Lance |
| Arc | 6: Overclocked Railgun, Coriolis Accelerator, Arc Fault Cannon, Proximity Klaxon, Polarity Projector, Tesla Gauntlets | 2: Megataser Harpoon, Combat Translocator |
| Blade | 0: none | 3: Chainsaw Claw, Breaching Plow, Soulcutter Talons |
| Melee | 2: Gravity Knuckles, Tesla Gauntlets | 5: Chainsaw Claw, Bullion Fragmenter, Breaching Plow, Knuckle of Fury, Soulcutter Talons |

What the map computes (what it means is the section after the map):

- Unique to a chassis (set by locked pieces and passives alone, so a build reaches it only by fielding that machine): Exposed, Cryo, Webbed, Vitriol, Syrinx Drone, Paradox, A foe's place changed (Swap), Spun Up, Rallied, Phased, Sealed, Regenerating, A foe's buffs (Armoured, Kindled, Getting Back Up; Primed, Barrier, Ward and Regenerating once the ladder lands).
- **A foe's turn drawn (Lure)** has one slottable setter, Proximity Klaxon (tier 1).
- **A foe's move changed (Disrupt)** has one slottable setter, Differentiation Probe (tier 2).
- **Overcharged** has one slottable setter, Overcharge Coil (tier 1), stocked.
- **Armoured** has one slottable setter, Shoring Jack (tier 1).
- **Primed** has one slottable setter, Aurora Lattice (tier 2).
- **Retaliate** has one slottable setter, Retribution Thurible (tier 1), stocked.
- **Barrier** has one slottable setter, Blast Door (tier 1).
- **Ward** has one slottable setter, Decoherence Veil (tier 1).
- **A foe's buffs (Armoured, Kindled, Getting Back Up; Primed, Barrier, Ward and Regenerating once the ladder lands)** is read by nothing but its own effect.
<!-- synergy-map:end -->

## 5. The holes, read

Claude's read of the map, for Ryan to move. Each names the hole, why it matters, a proposal
(a bench of one line each, never a spec), the measure that decides and the rule it touches. A
status unique to a chassis is that chassis's identity and no hole by itself (the tiers row: a
chassis is a sandbox); the holes are where a route the records want is missing, where a
currency has setters and no payoff beyond its own, or where everything converges on one casher.

**A. Fire has one payoff beyond its tick, and it is a stun.** Burning has eight setters (five
slottable, three locked) and the Backdraft Charge is its one dedicated reader; the other two
readers count any status (the Susceptibility Tensor, the Paradox). The tags row's own example
of a soft-synergy pair ("beam weapons deal extra to burning foes" beside "missile weapons add a
stack of burn") is unbuilt, so a fire team's second route is the stun or nothing, and the
Lattice-to-strikes chain (the Aurora Lattice's Primed on a Maxigun or a Cyclic Cannon lays a
stack a blow, the Backdraft eats them) ends at one piece. Proposal: one reader that does not
consume (a module, or a tier-two piece: a point more on a Burning foe for a Beam blow, or a
Plasma blow that adds the foe's stacks once), so the fire pays in damage beside the stun; a tag
pair needs two readers (the tags row), and Flame, Plasma and Beam have the slottable carriers
for one (four, six and five). Measure: the reader's delta on the Nemesis bench (two fire
setters in its stock) against the Tensor's. The rule: the stun row's gate stays the Backdraft's;
a reader that fed only the Arsenal's pieces would be a lean, not a pair.

**B. Cryo has one setter, locked, and the vocabulary marks it for reuse.** The Cryo Flinger
(the Armadillo's, Rapid, Lure and Cryo 1) is the only piece that lays it, and the hot kits cool
only by a vent on themselves, the Coolant Jacket or the Radiator Sail from an ally, or a
cleanse; nothing cools a hot ally by hitting, which is what Cryo is ("a healthier ally cooling
than a vent", its vocabulary entry). With the foes' heat doubled, the five hot kits' team
answers are two vents and a cleanse. Proposal: a slottable Cryo setter, tier one, Indirect, no
damage, Cryo 2 (the foe the hot ally will hit next: a die aimed at a foe that cools whoever
strikes it, the Flinger's shape without its Rapid and its Lure), Minerva's by the cold-kinetics
lean or Aphelion's by the status lean, the piece's fantasy deciding. It erodes nothing of the
Armadillo's, whose Flinger is the Rapid lure. Measure: the Buzzard bench's heat columns with
it in the slot, and the Kestrel row's `held` beside its wins. The rule: the heat row's "heat is
a team problem".

**C. Exposed is unique to three locked pieces.** The Fovea Designator, the Spotting Flare and
the Syrinx Drone lay it, and Expose is the armour answer that is not an amp (a foe Exposed
takes Direct fire from anywhere with its armour at nothing); Flak, Shock and the Railgun's
Breach are the slottable ways through plate. Not a hole by itself (the Needletail's identity
is the paint), but a note for Aphelion's session: the status maker lays no Exposed, and its
slottable pieces set Shock, Disrupt and Primed alone. Bench: a tier-two Aphelion Expose piece as
its slottable control, beside the three ideas section 12 already logs for it (a spreader, a
stasis piece, the Zenith Emitter's return). Measure: none until Aphelion's roster is read
(section 12's own condition).

**D. Nothing turns an ally's heat into anything but shield.** The Puffin reads an ally's heat
(the Slipstream, the Backwash) and pays in shield; the Radiator Sail is the one slottable ally
vent and the Jacket the one basic that reaches an ally; no module reads an ally's heat. With B
above this closes; without it, a module that lets a machine's vents cool an ally a point more
is the smaller answer. Measure: the Puffin bench's equipment rows (the Sail's and the Jacket's
deltas beside the Wake Diffuser's). The rule: the Rapid row's, a vent is never Rapid below tier
three, so the answer is a number or a second route, never tempo.

**E. The Ammit's hull-damage loop is a lynchpin to test.** The Grievance Reliquary Overcharges
its machine a stack at every hull damage, a Volatile bite and the Tithe Coupling's price
included (the engine routes both through the hull-damage trigger, as a blow is); the Ammit's
Quintessence Tap keeps every stack for the battle. So the Ammit with the Reliquary and the
Oblation Mantle or the Entropy Condenser buys a permanent point on all four Talons for 3 hull a
spend, and with the Tithe Coupling every spend does: 32 hull (52 with the Tithe) is up to
seventeen stacks. The Nemesis with the Mantle (rage a bite) is the Arsenal's intended pair; the
Ammit's permanence is the question. Measured (27 October, `docs/measurements.md`): under the greedy the
loop never spins. The Reliquary alone on the Ammit reads as stock (the bot spends the Mantle
1% and the Condenser 0%, so nothing bites); with the Tithe beside it the row is slower (4.9
rounds against 4.5, 15% hull against 10), since the greedy halves the Ammit's Talons spends
under a 3-hull price it reads as a cost and never feeds a stack a spend that pays later; the
Nemesis with the Tithe spins its rage loop (3.9 rounds for 20% hull). A verdict on the bot's
horizon first (the planner's read next); if the loop then reads as the Ammit's must-pick, the
price is the Reliquary's trigger (a foe's blow, never a bite) or a cap on the Tap, never the
Reliquary's cut: the modules row forbids the universal pick, and the Arsenal's self-cost is its
identity.

**F. The modules read no tag, and two tags cannot carry a pair.** Every module's rule reads a
reach, a roll, a status, a shield granted, hull damage or heat; none reads a tag, by the
catalogue row's own wait on this run. The map's counts of slottable carriers: Ballistic 14,
Plasma 6, Arc 6, Beam 5, Flame 4, Missile 2, Melee 2, Blade none (every Blade is locked), so a
pair on Blade or Missile would feed locked pieces and a lynchpin, as the Melee read did. The
catalogue's soft-synergy pairs (the to-do's line, after this run sets the stat lines), Claude's
bench for it, each a module and a module or a module and a piece, two readers a tag: Beam reads
Burning (A); Arc reads Shocked or lays Flak; Ballistic reads Flak (Wainwright & Sutler's own,
the Prairie Dog's clause widened to a module); Plasma reads hull damage (the Arsenal's). The
Ram Frame and the Rangefinder stay the reach pair, the Booster and the Databank the roll pair.

**G. Every per-blow amp converges on the strike pieces.** Flak, Overcharged, Primed, the Ram
Frame's and the Rangefinder's point and the Tensor's point all count on each blow, so the
Maxigun (three strikes), the Cyclic Cannon (four), the Skua's split (every weapon twice) and the
Flechette Pod's spray are the one casher of five currencies, where a big flat gun cashes one
(Shocked). The two amps are two shapes by decision (the Flak row: Flak the on-hit for the many
small blows, Shocked the multiplier one blow spends), so this is a convergence to watch, not a
hole: if the ladders read every amp's best home as a Cyclic Cannon, the price is on the strikes
(fewer, or a module's point counting once a spend), never on the amps. Sharper since the 28th:
the blow's order lands a firer's add on every area foe as on every strike, so an Overcharged or
a Ram Frame's point rides a Spread 2 or a Penetrate 3 as it rides a strike, and the area pieces
join the strike pieces as the amps' home. Measure: the Prairie Dog bench (Flak) and the Puffin
bench (the Coil) ladders, the module ladder's adds on a strike kit against a flat one, and the
rerun on the merged head (`docs/measurements.md`, 28 October).

**H. What exists and only wants its measure.** Lure's readers are all tank-side (Armoured and
Sealed plate, a Barrier, Retaliate, the hull-damage readers), and its one slottable setter is
Minerva's Klaxon (Indirect, Spread: three foes turned); a Klaxon on a Nemesis with the Thurible
is a cross-maker pair that exists, and a Lure beside a Blast Door eats one blow of three. Swap is
unique to the Dingo and its readers are the rank pieces (the Ram Frame, the Rangefinder, the
Cottonmouth's drum), cross-maker. The shield cost built on 26 October has no carrier yet (the
to-do's Ryan line); its pair is Overshield (the Backwash Ionizer, locked) and the Storm Petrel's
planned passive, and a candidate reads through the run by `--set` once named. Purge, since the 28th on the
fresh start's branch, is a reader the map lacked: the foes' buffs (Armoured, Kindled, Getting
Back Up, and Primed, Barrier, Ward and Regenerating crossing to them) and the player's Purge on
the Null Field Emitter, a tier-two Indirect debuff, each buff with an answer beside the purge
by decision; a foe's Ward turns every mark but Suppressed away for a turn, the first counter
every setter here shares, and the Marsh's lean. The rerolls'
setters are Wainwright & Sutler's (the Clydesdale's director, the Horn) and Kestrel's Trim Tabs,
their readers Wainwright & Sutler's and Minerva's (the Cassowary's step, the Muster, the
Armadillo); reroll effects are Kestrel's lean (Ryan, 19 October), the Clydesdale's predates it,
a note and no hole. Barrier, Ward, Primed, Retaliate, Armoured and Overcharged have one
slottable setter each at tier one or two, which is the pool's size (section 12: 50 to 75
unlocked blueprints against 40 as landed), and the map says every setup status has at least
the engine's own payoff; the dedicated readers are the Backdraft (Burning) and the Battery
(Flak), and A would add the third.

## 6. Open for Ryan

1. The tier steps (section 2's structure, on your direction of the 28th): a step on the plain
   number a tier at the same heat class, the equipment ramp first (shields 6 and 8, 10, 12,
   16; vents 4 and 6, 6, 8, 10; a keyword piece a step under), the guns' step (3; 4 to 5; 6 to
   7; 8 to 10); the Railgun up a tier or kept at its heat price; and whether the fills land
   before the tiered read or with it.
2. The Ram Frame's hull line, +24 to about +8, and the Artillery Rangefinder read on an
   Indirect bench (the Clydesdale's Howitzer slot) with the same line before either lands.
3. The Howitzer's and the Meteor Artillery's Splash (section 12's shells question), read as
   what-ifs on the car bench (section 2, item 8): Claude's lean the Howitzer at Splash 1, the
   chip you named, and the Meteor at none while its Burn rides every foe struck (a Splash on it
   is a fire on five foes, the strongest piece on the bench at either number), or Splash 1 at
   Burn 2 as the next what-if; an area fire is a piece of its own, and hole A asks for fire's
   second reader rather than a bigger first setter.
4. The next run: the ladders per tier on the fresh start's formations and recolours once the
   ladder lands, with the planner beside the greedy for the equipment and the setups, on
   Wainwright & Sutler's row and a starter trio without a carry; the 200-seed reads on the
   deltas the marks name; whole runs by hand on the pieces named.
5. The heat classes kept and no gun's heat moved (section 3), so the Storm Petrel's engine
   session may run on today's heats.
6. The bot's valuation lines before the dead pieces' numbers: a Disrupt (the Probe reads worse
   than an empty hardpoint), a vent that costs hull (the Condenser's 0%), a loop that pays
   later (the Ammit's), and equipment spent before the overheat, read on the planner; and the
   Ammit's kept Overcharged at single digits against a purging pack (your note of the 28th,
   the fresh start's to-do line).
7. The holes: which of A, B and D get a line on the to-do or a brief; C to Aphelion's session;
   E answered for now by the bot's horizon; F's pairs as the catalogue session's list; H's
   Purge as the setters' first counter, read once the ladder lands.

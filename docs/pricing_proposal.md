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

**Status, 27 October**: the method and its driver are built (`tools/pricing_run.py`, a dry run
checked: 393 variants, 188,640 fights); the run itself has not been made. The cloud session
that built it could not fetch Godot (the download was refused), so the run is the desk
machine's, about two and a half hours on four cores at a guessed rate, or a cloud session's
once it may fetch the binary. The synergy map (section 4) is generated from content by
`tools/synergy_map.py` and is current; the holes (section 5) are Claude's read of it.

**Read first**: the bible's balance rows (section 11: "Every stat and passive has a price,
measured"; "A component is balanced against the components of its tier; a chassis alone is a
diagnostic"), its heat row (section 5), its modules, tags and catalogue rows (section 7 and
10), the tiers row (section 10); `docs/measurements.md` of 22 and 23 October (the bands, the
starter trios, the built teams, the endgame fours); `docs/balance.md` (the pick shares and the
heat section); the retired stock pass brief (`git show a550c2e:docs/briefs/stock_pass.md`) for
the heat classes and the first fills.

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

## 2. What the records already say

The directions the run starts from, from the bands of 22 October and the reads since
(`docs/measurements.md`, `docs/balance.md`):

- **Heat bites five kits and is decoration on the rest.** Greedy, the hottest machine as a turn
  ends: the Nemesis 94% of its maximum (0.50 overheats and 0.17 dice held a fight), the Kite 92%
  (0.29, 0.18), the Buzzard 87%, the Whip Scorpion 78%, the Stingray 74% (0.16 held), the
  Lammergeier 56%; every other kit 6 to 44% (the Honey Badger 28%, the Clydesdale 30%). The
  heat row's test is met on the hot kits; the cold kits are cold by their numbers, which is the
  row's own rule (a cold build pays in a rolled range, a short reach, a lower number or fewer
  strikes). What is open is the slack on the kits between (the Lammergeier, the Clydesdale's
  d9 at heat 0 to 2) and whether the basics' heat 0 leaves the Coolant Jacket with no job.
- **The pick shares name the dead entries.** The Ammit's Entropy Condenser 0%, the Dingo's
  Combat Translocator 1%, the Lammergeier's Syrinx Drone, Lorentz Contractor and Polarity
  Projector 2 to 3%, the Coolant Jacket 1 to 6% on ten kits (14% on the Musk Ox, whose forge
  turns a vent into ammo, 33% on the Whip Scorpion, whose vents are its guns), the Kite's Bleed
  Valve 18%.
- **The bot's Shock price was a fault, fixed** (23 October): priced at a share of the team's
  average blow, the Polarity Projector was spent 0.07 to 0.11 times a fight on the Honey Badger
  and 0.3 on the Puffin; priced at the biggest blow an ally still to act shows, 0.29 to 0.49 and
  0.55 to 0.62. The ladders run on the fixed bot; a setup piece's share is read on it, never on
  the bands of 22 October.
- **A flat buff rides on strikes** (25 October, the Skua's rows): the Overcharge Coil in the
  Puffin's Coolant Jacket's place took the Skua pair's big-foe wins from nine-round losses to
  nine-round wins, the Prairie Dog's pair doubled its big-foe wins, the Cottonmouth's one-strike
  drum gained nothing. The Coil's ladder delta on the Puffin bench reads the same.
- **The heat loops of 22 October**: cooling 0 warmed every kit a little and moved no row's wins
  or rounds; the maxima (16 to 12, 20 to 14) heated the hot kits and left the cold ones cold,
  and were kept. The foes' heat doubled since (24 October): the Peak's formation fell from 88 to
  69% won for the starter trios, the cold Honey Badger trios paying 0 to 9% of their hull to
  heat and the hottest starters walled on the greedy bot; Ryan's play judges it (the to-do).
- **The reach and the shapes** (`docs/balance.md`): Indirect's premium is the back rank alone
  since danger close retired; a rolled spend and a flat one are read side by side there, and
  the ladders' benches split Direct (the tank, the car, the flyer) from where Indirect pays
  (the formations and the finals, a back rank each).

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

What the run reads for it:

- **The heat ladder's three loops**, each on the four team rows against the rows as stocked:
  `step` (every attack a class up: 0 to 1, 1 to 2, 2 to 3, 3 to 4, 4 to 6, 6 to 8, 8 to 10)
  asks whether the kits between move from slack into the budget without walling the hot ones,
  and which cold kits start to pay; `cold1` (the heat-0 attacks alone at 1: the Twin Autoguns,
  the Rivet Gun, the Chainsaw Claw, the Breaching Plow, the Flakshot, the Afterburner, the Siphon,
  the Expenditure, the Pinion Driver, the Umbra Inducer and the Syrinx Drone) asks whether a
  cold floor of 1 gives the Coolant Jacket a job on the cold kits without a wall; `cooling0`
  re-reads the 22 October loop on the doubled foe heat. The reads are the heat section's
  columns (the peak, the hot rounds, the overheats and the hull they burned, the dice held and
  the damage held back, the heat left at the end) beside the wins and rounds.
- **The heat columns on every ladder variant**: a candidate's heat priced on the Buzzard bench,
  where it bites, beside its delta on the cold benches, where it is free.
- **The Storm Petrel's gate**: its weapons burn shield in place of heat, so the guns' heat the run
  settles is its price list, and its brief's hole (2 a spend on basics alone) is read on it.

Claude's lean, for the marks, and nothing moves before the loops are read: keep the class
ladder (0, 1, 2, 4, 6, 8) and move pieces between classes rather than invent steps, so the
player reads six heats and not twenty; the basics stay cold unless `cold1` reads as the
Jacket's job without a wall on the starter trios; the hot flat guns (the Transonic Rifle at 4,
the Thermal Ray at 6, the Railgun at 8) are the ladder's anchors, a point of heat for a point
of number above the warm basic's 3; a vent's number follows the guns it answers (a Jacket of 4
is one warm spend or two cool ones). The foes' side stays the fresh start's (the status's item
3), and Ryan's play on the Peak decides whether the doubled stacks hold.

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
| Several blows a spend | a resource | Chainsaw Claw (locked, Honey Badger); Enfilade Beam (tier 1), stocked; Proximity Klaxon (tier 1); Breaching Plow (locked, Wild Boar); Flakshot Repeater (locked, Prairie Dog); Maxigun (tier 1), stocked; Shrapnel Recuperator (locked, Musk Ox); Unrestricted Expenditure (locked, Musk Ox); Flechette Pod (locked, Skua); Airburst Shell (tier 1), stocked; Cyclic Cannon (tier 2); Wild Boar's Juggernaut Drive; Cottonmouth's Adaptive Munitions Drum; Skua's Split-cycle Breech | each strike takes the foe's conditions and armour on its own |
| A mine | a resource | Syrinx Drone (locked, Lammergeier); Lammergeier's Fuse-delayed Bay | whoever steps in takes every shot waiting; Lorentz Contractor (locked, Lammergeier) |
| Ammo | a store | Shrapnel Recuperator (locked, Musk Ox); Quick Reload (locked, Musk Ox); Musk Ox's Desublimation Forge | Unrestricted Expenditure (locked, Musk Ox) |
| The Muster | a store | Swallowtail's Muster Deck | Mooring Screens (locked, Swallowtail); Spotting Flare (locked, Swallowtail); Sutler's Hoist (locked, Swallowtail); Reveille Horn (locked, Swallowtail) |
| Rage | a store | Nemesis's Crucible Capacitor | Knuckle of Fury (locked, Nemesis) |
| The hopper | a store | Chainsaw Claw (locked, Honey Badger) | Bullion Fragmenter (locked, Honey Badger) |

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

- Unique to a chassis (set by locked pieces and passives alone, so a build reaches it only by fielding that machine): Exposed, Cryo, Webbed, Vitriol, Syrinx Drone, Paradox, A foe's place changed (Swap), Spun Up, Rallied, Phased, Sealed, Regenerating.
- **A foe's turn drawn (Lure)** has one slottable setter, Proximity Klaxon (tier 1).
- **A foe's move changed (Disrupt)** has one slottable setter, Differentiation Probe (tier 2).
- **Overcharged** has one slottable setter, Overcharge Coil (tier 1), stocked.
- **Armoured** has one slottable setter, Shoring Jack (tier 1).
- **Primed** has one slottable setter, Aurora Lattice (tier 2).
- **Retaliate** has one slottable setter, Retribution Thurible (tier 1), stocked.
- **Barrier** has one slottable setter, Blast Door (tier 1).
- **Ward** has one slottable setter, Decoherence Veil (tier 1).
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
Ammit's permanence is the question. Measure: the Nemesis bench's module ladder reads the
Reliquary and the Tithe on its row (the Ammit is in it), and one fit variant by hand (the
Ammit with both, `--fit ammit=grievance_reliquary,tithe_coupling`). If the Reliquary reads as
the Ammit's must-pick, the price is its trigger (a foe's blow, never a bite) or a cap on the
Tap, never the Reliquary's cut: the modules row forbids the universal pick, and the Arsenal's
self-cost is its identity.

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
(fewer, or a module's point counting once a spend), never on the amps. Measure: the Prairie Dog
bench (Flak) and the Puffin bench (the Coil) ladders, and the module ladder's adds on a strike
kit against a flat one.

**H. What exists and only wants its measure.** Lure's readers are all tank-side (Armoured and
Sealed plate, a Barrier, Retaliate, the hull-damage readers), and its one slottable setter is
Minerva's Klaxon (Indirect, Spread: three foes turned); a Klaxon on a Nemesis with the Thurible
is a cross-maker pair that exists, and a Lure beside a Blast Door eats one blow of three. Swap is
unique to the Dingo and its readers are the rank pieces (the Ram Frame, the Rangefinder, the
Cottonmouth's drum), cross-maker. The shield cost built on 26 October has no carrier yet (the
to-do's Ryan line); its pair is Overshield (the Backwash Ionizer, locked) and the Storm Petrel's
planned passive, and a candidate reads through the run by `--set` once named. The rerolls'
setters are Wainwright & Sutler's (the Clydesdale's director, the Horn) and Kestrel's Trim Tabs,
their readers Wainwright & Sutler's and Minerva's (the Cassowary's step, the Muster, the
Armadillo); reroll effects are Kestrel's lean (Ryan, 19 October), the Clydesdale's predates it,
a note and no hole. Barrier, Ward, Primed, Retaliate, Armoured and Overcharged have one
slottable setter each at tier one or two, which is the pool's size (section 12: 50 to 75
unlocked blueprints against 40 as landed), and the map says every setup status has at least
the engine's own payoff; the dedicated readers are the Backdraft (Burning) and the Battery
(Flak), and A would add the third.

## 6. Open for Ryan

1. The benches: the five as proposed, or his own; a sixth for Indirect (a Cottonmouth or a
   Musk Ox bench) if the Rangefinder's read wants one.
2. The knock-out's form: the hardpoint left empty (the piece's whole worth) or the basic of its
   kind in its place (the tier's premium); both are a flag away, the first the default.
3. Whether tier three joins the ladders (two pieces today; tier three is the chase, so its band
   is its own) and whether the rank-and-file packs join the benches' packs (`--packs all`: the
   area and Chain pieces read there, at 100% wins and in rounds alone).
4. The heat pricing's lean (section 3): the class ladder kept, pieces moved between classes.
5. The holes: which of A, B and D get a line on the to-do or a brief; C to Aphelion's session;
   E's price if the loop converges; F's pairs as the catalogue session's list.
6. Who runs it: the desk machine (the command in section 1), or a cloud session allowed to
   fetch Godot (the download was refused in this one).

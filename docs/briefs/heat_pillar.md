# Brief: heat as a pillar (a design session, waiting on Ryan)

The jumping-off point for a session on heat: what it is today, what is measured, what Ryan
said on 28 October, Claude's bench, and the questions only he can settle. Nothing here is
decided beyond what the bible's rows say; the bench is Claude's, for him to move.

**Status**: Ryan's frame recorded 28 October (the bible's triangle row, section 2; section 12's
heat question); the measures of the same day in `docs/measurements.md`; no number or rule
changed for it yet. **Read first**: `CLAUDE.md`; `docs/rules.md` ("Heat", "A blow", the
keywords list); the bible's triangle row (section 2), its heat row and area row (section 5),
its Rapid row and maker row (section 7), its pricing and effectiveness rows (section 11), its
heat question (section 12); `docs/measurements.md` of 27 October (the pricing run's heat
ladder) and 28 October (the vanilla ladder, the Clydesdale bench, the heat knee by the
maximum); `docs/briefs/README.md`; `tools/pricing_run.py` (the vanilla heat grid, `--set`,
the benches); `sim/skirmish.gd` (`_add_heat`, `forecast`, the overheat at the end of the
player's turn, `start_round`'s cooling); `content/chassis.json` (`heat_max`, `cooling`);
`content/components.json` (every `heat`, `volatile`, `self_burn`, `heat_per_blow`).

## What heat is today (the rules as built)

- A weapon adds its heat when spent, once a spend, through the attacker's modifiers. A debuff
  device carries heat too (the Polarity Projector 2). Shields and buffs carry none; a vent
  takes heat off; Volatile pieces pay hull instead; the Stoker burns itself.
- Heat may pass the maximum during the player's turn; at the end of the turn, before the enemy
  acts, the excess burns hull one for one (an overheat) and the gauge settles at the maximum.
  An overheat is hull damage for every passive that reads hull damage.
- Machines cool at the start of the round by their chassis's cooling: 1 on most, 2 on the
  Kite, the Cottonmouth, the Swallowtail and the Giant Petrel, 0 on the Stingray and the Whip
  Scorpion. The maxima: 12 on most, 14 on the Baboon, the Buzzard, the Nemesis, the Ammit,
  the Stingray, the Whip Scorpion, the Swallowtail, the Lammergeier and the Giant Petrel, 10
  on the Kite, 8 on the Musk Ox (the stock pass's loops of 22 October lowered them from 16
  and 20). Heat starts each fight at zero.
- Heat as fuel: Kestrel's passives turn it into shield (the Buzzard), stacks (the Stingray),
  ammo (the Musk Ox's forge) and power (the Afterburner Cannon, the Kite's flat heat on every
  shot); the Puffin reads an ally's heat; the Peak's Scorched and Burning on a machine add
  heat; Cryo cools the hitter.
- The heat classes the stock pass set by niche: a rolled basic cold or cool (0 or 1), a flat
  basic warm (2), a keyword piece warm to hot (2 to 4), a big flat gun very hot (6 or 8).

## What is measured (28 October unless said)

- **On a cold die** (the Prairie Dog's slot in Wainwright & Sutler's row, a three-entry die,
  maximum 12, cooling 1, a flat heatless gun at 3, 5 and 7 across heat 0 to 8): heat 2 and 4
  cost nothing in rounds; heat 6 takes 0.2 rounds back, about two thirds of a vanilla point;
  heat 8 takes 0.3 to 0.4 back, one and a half points, a quarter of a big gun's number. The
  knee is 6, the heat row's third round.
- **By the maximum** (the same grid with the Prairie Dog's maximum at 10 and at 8): the knee
  moves a class a step. At 10 heat 4 is still free in rounds (the peak 75%); at 8 heat 4 costs
  half a point, heat 6 one and a half, heat 8 two and a half. The warm classes bite on a cold
  die only at 8, the Musk Ox's number, a third under the fleet's.
- **On a hot die** (the Buzzard's third slot, maximum 14): a piece's heat costs hull and never
  rounds (the overheats 0.3 to 0.5 a fight, one to three hull), since the slot fires a tenth of
  the time and the row wins in 2.9 rounds.
- **On a nine-entry die** (the Clydesdale's Howitzer slot): a hot piece never reaches its knee,
  since its slot fires a ninth of the spends (the peak 72 to 75% at heat 8). Heat's price scales
  with how often the piece fires, so die size is a heat lever beside the maxima and the cooling.
- **Cooling 0 on every chassis** (the heat ladder of 27 October): every row's peak up ten to
  fifteen points, Kestrel's to 103%, no row's rounds moved, because the greedy answers heat by
  holding a die and never by venting (the Coolant Jacket's share 1 to 6% on every kit, the
  Entropy Condenser never spent). Every vent read needs a bot that vents: the persona on the
  to-do's valuation line.
- **The tiered formations**: Kestrel's row peaks at 128% with 1.6 overheats a fight on them at
  its 14 (the tier cells, 28 October), so a fleet-wide lever lands on the hot kits first.
- **With a bot that vents** (30 October, `docs/measurements.md`: the vanilla heat grid on the car
  under the cautious persona, `--cool-above 50`, and with the Prairie Dog's cooling 0; 30 seeds, a
  direction): caution costs more than the overheat. Keeping heat under half the maximum all but
  ends the overheats (0.07 a fight at heat 8 against the greedy's 0.50) and costs heat 4 nearly a
  point and heat 8 three, with more hull lost, not less: the overheat burns only the excess while
  holding a hot gun or venting early costs a spend, so eating the overheat is the better play
  today. Cooling 0 adds a third of a point to heat 4 and about half a point to heat 6 and 8 under
  the greedy, and nothing to the cold stock row.
- **The content's allowance**, read on the vanilla scale: the Transonic Rifle carries 1.5 over
  its floor for heat 4, the Thermal Ray 2.5 for heat 6, the Railgun at 8 about 3.5 with Breach,
  the Meteor nothing for its heat 6 (its Burn 3 is its premium). Paid in full only at a maximum
  of 8; on today's kits the warm classes are flavour.

## Ryan's frame (28 October, his words)

- Heat is "a core pillar of the game, and it's undervalued as a gameplay element".
- "Sometimes I think of the offense-defense-heat triangle as something the player has to work
  hard at to play around efficiently, like a eurogame, cutting one of the sides of the pyramid
  out while still being effective should feel like a huge accomplishment, and the enemy threats
  are the wrench that prevents a fully efficient build from just doing its infinite thing
  forever."
- "It might be easier to think of every component having a price, either in heat, hull, or
  shield, vanilla vents excluded. Possible that cooldown is also a sufficient cost, or certain
  payoff/consumer pieces that are a dead face otherwise don't need an additional cost."
- On heatless basics: "I would disagree with basics having no heat, as that teaches the player
  zero heat as the norm and not how to interact with the heat system. Plus it neuters many
  possible tier 1 chassis and makes others irrelevant (Puffin, for instance)." (Claude's lean
  that heat 0 is the basics' mark, retired.)
- On passive cooling: "Passive cooling was cut, right? If not, maybe it should be? That would
  help push the heat system into something the player MUST interact with, either by playstyle
  or build choice."
- On venting: "I agree with giving the player options other than 'gotta waste a turn venting,'
  although sometimes you do just need a big fat vent. Vent payoffs certainly can have a place."

## Claude's bench (28 October), with the holes

The order is Claude's lean; each line is his to move.

1. **Every component priced.** The twelve slottable pieces with no price today: the Twin
   Autoguns and the Rivet Gun (a heat point each, so the basics' guns teach the gauge); the
   Halo Shield, the Canopy and the Corona Shield (a heat point for the fields, a cooldown for
   the physical canopy); the six buffs, the Overcharge Coil, the Shoring Jack, the Retribution
   Thurible, the Blast Door, the Decoherence Veil and the Aurora Lattice (a heat point for the
   devices, a cooldown for the Blast Door and the Veil, a turn's answer). The ten locked free
   pieces (the Claw, the Plow, the Flakshot, the Afterburner, the Drone, the Horn, the
   Screens, the Hoist, the Expenditure, the Backwash) with their chassis sessions; the Pinion
   Driver pays through the Kite's passive. Consumers dead without their setup (the Backdraft,
   the Battery, the Afterburner's bonus) stay as they are, Ryan's rule. Hole: a shield priced in
   heat means a hot machine cannot shield, the spiral; the forecast shows a spend's heat before
   it is made, so Claude leans to the wrench, with the cooldown as the price where the spiral
   would be unfair. Ryan's call.
2. **Passive cooling 0 by default**, cooling kept where it is an identity (the Kite's 2, the
   Swallowtail's, the Giant Petrel's, the Cottonmouth's), bought elsewhere by a passive or a
   module. Holes: a plain vent on every die becomes a tax, the universal pick the modules row
   forbids, unless the vent payoffs land in the same pass; the Stingray's and the Whip
   Scorpion's 0 stops being theirs. Read with the venting persona before it lands.
3. **Vent payoffs**: a vent that cashes what it vents, a different piece a maker (damage for
   Kestrel, shield for Minerva, stacks for Aphelion), each proposed in chat first, so the
   cooling turn is a payoff turn and the overheat the cost of greed. "Sometimes you do just need
   a big fat vent": the plain vents stay.
4. **The maxima by chassis**, never a fleet-wide 8: the stock pass already sets the Kite's 10
   and the Musk Ox's 8; a cold kit whose warm pieces should bite takes a lower maximum.
5. **A soft zone** above two thirds of the maximum (the machine's spends a point hotter, or its
   cooling halved), only if the prices and the cooling leave the warm classes free. Visible on
   the gauge, no new overheat.
6. **A harder overheat** last (the excess doubled, or a dark entry next round): the blunt lever,
   punishing the cold kits that stray as hard as the hot kits that live there. The read of 30
   October argues for moving it up: while eating the overheat is cheaper than playing around
   heat, cutting the cooling makes the greedy eat more of it, not meet the system, so the
   overheat's price is the lever that makes the other levers bite.
7. **Heat between fights** (section 12's question, zero at every fight's start today): the
   campaign-layer answer, after the skirmish's bite is right.

What Claude would not do: a universal heat-as-fuel rule. That is Kestrel's identity, and giving
it to everyone flattens the maker.

## The questions for Ryan

1. Is passive cooling cut by default, and which chassis keep theirs?
2. Which price does each of the twelve free pieces take, and is a shield's price in heat the
   wrench or the trap?
3. Do the warm classes (1, 2, 4) need to bite on a cold die at all, or is the bite the hot
   kits' and the long fights' alone?
4. Which vent payoffs, by maker, and how many plain vents stay in the pool?
5. The overheat's cost: the excess one for one as today, or more?
6. Heat between fights: now, or after the skirmish's bite is right?

## The reads to run (each a what-if, content untouched)

- Done 30 October (`docs/measurements.md`): cooling 0 on the vanilla heat grid on the car, under
  the greedy and the cautious persona (`--cool-above 50`). Next the same on the hot rows (Kestrel's
  row, the Kite, the Stingray at its 0), and a harder overheat as a what-if, the excess doubled,
  which needs an engine switch first, to see whether caution then pays.
- The heat ladder on the four team rows with cooling 0 and a class up (`--parts heat`), after
  the venting persona exists; until then its `held` and `peak` columns are the read.
- A priced basic: `--set components/twin_autoguns/face/heat=1 --set
  components/rivet_gun/face/heat=1` on the team rows (`--parts knockouts`), for the stock
  rows' peaks and overheats.
- Each price that lands: the vanilla ladder's heat grid again, then the 200-seed read on the
  deltas it names (the pricing row's rule).

## What the session hands back

Rows in the bible (each decision with its reason and its exit), `docs/rules.md` where a rule
changes (the overheat, the cooling, a soft zone), the prices in content through a fills
script like `tools/stock_fills.py`'s, the reads in `docs/measurements.md`, the to-do's heat
session line ticked, `docs/status.md` updated. Nothing is built before Ryan's go.

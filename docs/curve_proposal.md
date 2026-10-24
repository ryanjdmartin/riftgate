# The curve and the fronts: a proposal

Ryan opened the curve's shape on 24 October (the bible's section 3, the curve row); section 12's
curve and bleed questions point here. This file holds the two forms, what a battle pays and the
fronts' pressure until Ryan has picked; then the picks become bible rows, `docs/rules.md` and
code, and the file retires (git keeps it). Everything here is Ryan's to move.

## Ryan's shape

- A soft ramp with the Convergence, battle by battle, and jumps per rift that the player sees
  and chooses (24 October: "through the scouting screen we can show when a rift has jumped to
  having 2 elites or extra fractures"), so battles still come in tiers, but each jump is
  taken by choice.
- Whatever the form, the trade shows on the map: "the strategic choices of chasing
  loot/rewards vs preventing city damage vs chasing anathema should be clear to see."
- His guesses at the pay are "general feelings, not rules".

## Two forms

| | A rift that deepens (Claude's) | A tier and a ramp (Ryan's) |
|---|---|---|
| Shown | The rift's depth: the Convergence sets it as the rift opens, a step deeper for each turn it is left alone | The rift's tier, set as it opens, never changing |
| What it sets | Its Fractures and elites | Its Fractures, its elites, its possible bosses and its possible spawns |
| Not shown | Nothing | The ramp, rising with the Convergence on every open rift: the spawn rate and the density |
| A front left alone costs | Its bleed and its depth | Its bleed alone, since the ramp rises on every front alike |
| The spiral | A front left alone grows harder as it nears falling | None: an old front is no harder than a new one of its tier |

Ryan, of the first: "Your method works." Claude's lean: the tier and the ramp. Its shown number
is a promise that never moves under the player. A front left alone costs its bleed and nothing
hidden, so there is no spiral. It reads the roster's tiers directly (section 9's tiers row: a
tier-two rift draws the tier-two spawns, elites and bosses). And the curve row's levers split
cleanly between its two numbers. What the foes are and what the fight holds (simple or advanced
foes, their mechanics, the elites, the identities, the guests) go on the tier; how many and how
fast (the density, the rift timer) go on the ramp. Both forms sit inside section 3's
never-inflate row, since the ramp is density and spawn rate, never the foes' numbers.

**How a rift's tier is set.** By the Convergence's tier as the rift opens, shown 1 to 3 where
the code counts 0 to 2. A rift's tier is then the components' tier it pays, so "a tier-2 rift"
reads straight off the card. On today's turn loop a front lives two or three turns, so two
tiers share the board only around the steps: a quarter of the turns when the oldest front is
always fought, half when the player chases the higher tier (`tools/turn_loop.py`;
`docs/measurements.md`, 24 October). If that is too seldom for the trade to show, a rift could
now and then open a tier above, more often as the ramp rises. Claude's lean: try it plain
first.

**The card.** A front's card shows the rift's tier where it shows the Convergence's today
(section 3's card row), and with it the count of elites. Their kinds show once scouted, as a
scouted formation does (section 3's sensor row), so scouting buys the kind and an unscouted
elite's kind stays the curveball.

## The pay

Ryan's guesses (24 October) beside what the records say today, with Claude's lean. "The tier"
means the rift's; a reward that no rift pays has no tier to read.

| Reward | Today | Ryan's guess | Claude's lean |
|---|---|---|---|
| Favour for the win | 100, docked a point for each gate point the battle let through | On the tier and the ramp | Agreed, since what it buys rises with the Convergence; docked for the whole siege (the fronts, below) |
| Salvage | 10 a kill, in any fight, to be weighted by threat (section 10's kill row) | By the kills, no scaling of its own | Agreed: the kills carry both, the tier in which foes they are, the ramp in how many |
| Anathema | The threat-weighted tally (section 3's tally row) | By the kills | Agreed, as salvage |
| The loot on the map | Salvage and components, seeded with the map; not built | Quality on the tier, or on both; quantity on the salvage scale | Quality on the tier alone, so the card says what a front pays; the ramp reaches the loot through its quantity |
| The host maker's offer | A module, a component a tier above the shelf's and a chassis (`docs/economy_pass.md`) | As the loot | The rift's tier, with its component at that tier, so an old front's offer may sit below the shelf: the price of the safe front |
| The boss's token | Three blueprints of the domain's theme at the Convergence's tier | As the loot | The rift's tier |
| The Fracture's picks (section 8) | A battle-long modifier, a one-shot or a boon; not built | Perhaps his "map cheats" | The rift's tier |
| The procurement shelf | Its tier gated by the Convergence (`docs/economy_pass.md`) | As the loot | The Convergence, since the shelf has no rift |

At the top the mapping bends. If a tier-three rift paid mostly tier three, the last third of a
run would be flooded with the tier that section 10 keeps powerful and rare (Ryan, 23 October).
Claude's lean: tier three stays a chance at every tier, rising with it.

## The fronts: does a rift close on its own, and is a perfect run possible?

Ryan, 24 October: "There's also a massive hole in whether a rift ever closes on its own. If
not, then we need to decide if a 'perfect run' where all 4 cities stand is possible, or if
we're expecting one or more to fall as a matter of course."

Today (the rules' campaign part): a rift closes only when its battle is won, and its city
opens none the next turn. A fallen city's rift stays open for good, cannot be fought and
drains the capital 25 a turn. At each turn's end, rifts open at standing cities up to 2 plus
the Convergence's tier. A won battle refills the gate free, and the win's Favour is docked
only for what the battle itself let through (section 3's free-restore row).

The arithmetic (`tools/turn_loop.py` models the turn loop from `sim/campaign.gd`'s constants,
2,000 seeds, with every battle won and no pusher let through):

- The schedule never fells a city. A player who fights the oldest front sees 2, 3 and 3 fronts
  by tier, no front is more than two bleeds down when fought (100 of 200), and one passed turn,
  at any point, fells none.
- The third tier's extra rift never opens while every battle is won: of four cities, the
  fourth is the one just won, which is quiet for a turn. The third tier adds pressure in the
  battles but none on the map, unless a battle is lost or a turn passed.
- Chasing costs little. A player who takes the higher tier whenever two are offered, and turns
  back only for a city one bleed from falling, keeps all four cities, at the price of three
  rescues a run fought on a gate of 50. A player who always takes the higher tier loses two
  cities a run.
- The battle count bounds nothing; the cap on open rifts does. Falls come from lost battles (a
  wipe lets the horde strike the gate for six phases and leaves the rift open), never from the
  schedule.
- The bleed short of a fall costs nothing once its rift is won, since the gate refills and
  the Favour docks only the battle's own damage. So "preventing city damage" today means
  preventing a fall, plus the rescue's risk on a low gate.

Claude's leans:

1. **A perfect run stays possible and hard, and no fall is scheduled.** Into the Breach's grid
   is the capital's touchstone (section 3's capital row): a perfect run is the mastery a player
   chases, and every loss is a consequence. A fall the loop forces is the helplessness section 2
   removes ("never helpless, sometimes unlucky"), and a fall in every run turns a city's fall
   into a set piece, when it has to hurt because it could have been prevented. This reopens
   if the runner, once a persona chooses fronts, shows good players never losing a city (the
   bleed too soft) or always losing one.
2. **No rift closes on its own.** A rift that closes itself pays the player to ignore it, and
   the cap already bounds the pressure. This reopens with the first lean: if falls prove
   routine for good players, a rift that burns out after a time shown on its card is the softer
   valve.
3. **If keeping the cities whole is to be one of the three trades, the bleed needs a price
   that outlasts the win.** Claude's lean: dock the win's Favour for the whole siege, every
   gate point the city lost since its rift opened, not only the battle's. The restore stays
   free, so no city runs on a one-way clock (section 3's row), and the Council paying for
   results already says it: a city saved late is a worse result. Without this, a careful
   chaser pays only the rescues' risk.

## The runner

The campaign runner's plain player defends the front nearest to falling and reads no tier, so
the trade can only be read once a persona weighs a front's tier and pay against its bleed. That
is a runner change of its own, after Ryan picks.

## The bench

Ideas that a rule kills here, one line each with the rule, so that Ryan can overrule the rule:

- A ramp on the foes' numbers, HP and blows rising with the Convergence: section 3's
  never-inflate row. The ramp is density and spawn rate.
- A partial restore on a win, which keeps the bleed's price in the gate: section 3's
  free-restore row ("no city runs on a one-way clock"). That row names the free restore as a
  lever for higher difficulty tiers.
- Two fronts a turn by splitting the squad, which would make a perfect run easy: section 3's
  one-front row (Ryan, 13 October).
- Command entries as a reward, if "map cheats" means them: section 8 ("Command entries come
  from the hangar, never from rewards").

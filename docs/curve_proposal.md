# The curve and the fronts: a proposal

Ryan opened the curve's shape on 24 October (the bible's section 3, the curve row); section 12's
curve and fronts questions point here. This file holds the two forms, what a battle pays and the
fronts' pressure until Ryan has picked; then the picks become bible rows, `docs/rules.md` and
code, and the file retires (git keeps it). Everything here is Ryan's to move.

## Ryan's shape

- A soft ramp with the Convergence, battle by battle, and jumps per rift that the player sees
  and chooses (24 October: "through the scouting screen we can show when a rift has jumped to
  having 2 elites or extra fractures"), so battles still come in tiers, but each jump is
  taken by choice.
- Whatever the form, the trade shows on the map: "the strategic choices of chasing
  loot/rewards vs preventing city damage vs chasing anathema should be clear to see."
- His guesses at the pay are "general feelings, not rules"; the calls he has made since are
  marked as his below.

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

What the records say today beside Ryan's guesses and calls (24 October), with Claude's lean.
"The tier" means the rift's; a reward that no rift pays has no tier to read.

| Reward | Today | Ryan | Claude's lean |
|---|---|---|---|
| Favour for the win | 100, docked a point for each gate point the battle let through | Guess: on the tier and the ramp | Agreed, since what it buys rises with the Convergence; the dock stays the battle's own (the stick and the carrot, below) |
| Salvage | 10 a kill, in any fight, to be weighted by threat (section 10's kill row) | Guess: by the kills, no scaling of its own | Agreed: the kills carry both, the tier in which foes they are, the ramp in how many |
| Anathema | The threat-weighted tally (section 3's tally row) | Guess: by the kills | Agreed, as salvage |
| The loot on the map (his "map chests"; working names Derelict, Carcass, Relic, never "chest" in shown text) | Salvage and components, seeded with the map; not built | Call: quality on the tier ("Loot being based on tier is fine"), the ramp kept for drop rates "if we need to fine tune later"; quantity on the salvage scale | Agreed |
| The host maker's offer | A module, a component a tier above the shelf's and a chassis (`docs/economy_pass.md`) | As the loot | The rift's tier, with its component at that tier, so an old front's offer may sit below the shelf: the price of the safe front |
| The boss's token | Three blueprints of the domain's theme at the Convergence's tier | As the loot | The rift's tier |
| The procurement shelf | Its tier gated by the Convergence (`docs/economy_pass.md`) | Call: the Convergence and the tier rifts are opening at | Agreed |

**Tier three** (Ryan's call): a chance, "probably zero in tier 1 rifts, small in tier two, and
a bit larger in tier 3. Subject to balance", since "I don't think outfitting 4 units in all
tier 3 gear is a healthy endgame, my intent is for them to be highlight, chase pieces." That is
the records' sense of a chase piece: the rare find that breaks the game now and then (section
2's rule-text row), never a lynchpin a build needs (section 2's synergy row).

**Breadth** (Ryan, 24 October): the concern is breadth, not quantity. "A blueprint offers more
volume of the same component, not additional options for finding synergy components ...
Especially since our component pool could be very large"; the boss's blueprint is themed and
meant as a guaranteed higher-quality piece, "which doesn't necessarily mean a useful synergy
piece"; and a build needs room to upgrade, an endgame build being all tier two and maybe a couple
of tier-three pieces ("Obviously any of the above can change"). What shows a run different
pieces today is the host maker's offer (one component among its three things a win), the shelf,
and the map's loot, which deals what it holds rather than a choice. With the loot by the rift's
tier, the first third of a run deals tier one, and today's unlocked pool is 24 tier-one pieces,
14 tier-two and 2 tier-three, so the tier a build upgrades into is the smaller share; if the
endgame is mostly tier two, that is where the pool grows. Claude's lean: loot at a battle's end
as a pick, one of three component copies from the whole pool at the rift's tier, unthemed. It is
the breadth source, as Slay the Spire's card reward is, and the token's complement: the token
gives depth in one themed piece, the pick breadth across the pool. The map's loot stays the
detour's luck. The records have the token's three at the rift's tier, as the loot is; a
guaranteed higher quality (a tier above, or a better chance at the top of its tier) is a line to
add, if that is the intent.

## The fronts: does a rift close on its own, and is a perfect run possible?

Ryan, 24 October: "There's also a massive hole in whether a rift ever closes on its own. If
not, then we need to decide if a 'perfect run' where all 4 cities stand is possible, or if
we're expecting one or more to fall as a matter of course." And restated: "should gates close
on their own. Thematically, no, it doesn't really make sense, but mechanically, if a rift closed
after dealing a bunch of city damage, that would open the door for a higher tier rift to then
open there to finish the job, which could make more interesting gameplay, I'm not sure."

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
2. **No rift closes on its own.** Ryan's thematic no stands, and the mechanical case fails. A
   rift that has bled its city long enough giving way to a higher tier, whether by closing and
   reopening or by widening in place (Claude's deepening rift again), pays the neglect a tier,
   since a battle's loot follows the tier: "a rift upgrading a tier is more like a reward for
   ignoring it" (Ryan, 24 October). The model shows it: at a rift's third bleed, the player who
   always takes the highest tier stops losing cities, because the widened front becomes the
   richest on the board (`--widen`, `docs/measurements.md`). Dropped.

## The stick and the carrot

Ryan, 24 October: city damage could hurt "in other ways than just not getting paid", the
city's maker's stock on the shelf "more expensive, and then more rare, before finally
disappearing if the city falls"; and a carrot beside the stick, "since if the penalties are too
great (i.e. payment for defending would be basically nothing), then it might just be a better
opportunity cost to ignore it and let it fall." Then: "The point of my maker penalties was only
biting during a seige, giving the player a discrete reason to go fix it."

- The stick, as he means it: while a siege lasts, the city's maker's stock on the shelf grows
  dearer, then rarer; lifting the siege restores it; a fall takes it off the shelf, as is already
  decided. A discrete, visible reason to go and fix it.
- Withdrawn on Ryan's points: Claude's siege dock, the win's Favour docked for the whole siege,
  which would leave a rescue from the brink paying nothing; and Claude's discount while a gate
  stands whole, which rewards chasing a single maker, saving it while it stands and ignoring the
  rest even more ("It stifles diversity").
- The carrot is the normal pay: a rescue pays its Favour, docked only for the battle's own
  damage, its maker's offer, its token and its loot. Any carrot beyond it is open, with two tests
  from this exchange: it must not reward waiting for the brink, nor nursing one maker.
- The late run: near the end a fall costs little. The maker's future hardly matters, the drain
  runs a turn or two, and the finale was due anyway: a fall on the last turn costs the capital
  25. If a perfect run is to mean something there, the finale could pay for each city still
  standing, its gate's guns or its maker's last shipment beside the capital. Claude's idea, for
  Ryan.

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
- Command entries as a reward: section 8 ("Command entries come from the hangar, never from
  rewards").

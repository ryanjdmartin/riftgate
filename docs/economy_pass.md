# The economy pass: notes for its session

The numbers quoted below are the 7 October run, before the domains; `docs/campaign_run.md` of 13
October (3 of 40 runs won, most fights one machine alone) and `docs/measurements.md` are the
current reads, and the campaign's fall is understood before any price is set.

Ryan, 7 October: the first estimate of every price, worked out from what the run pays in,
gets a session of its own. These notes are its starting brief. The ledger is in bible
section 10 (the ledger row, the loop row, the numbers row). Every constant named here is in
`sim/campaign.gd` and is a placeholder.

## What the run pays in today (measured)

`docs/campaign_run.md`, 7 October: 40 runs, greedy rung, the tier-one start (Badger,
Sparrowhawk, Baboon), a plain player. That player defends the front nearest to falling,
hunts the nearest enemy, puts all its salvage into the capital's gate and rushes a wreck
with Favour when nobody is ready.

| Measure | Reading | From |
|---|---|---|
| Battles a run | about 12.9 (514 in 40 runs) | |
| Won battles a run | about 10.7 (83%) | |
| Salvage banked per won battle | 111 (20 to 300) | `SALVAGE_PER_FOE` 10, every kill on any outcome but a fall |
| Favour per won battle | 94 of 100 (2 to 100) | `FAVOUR_PER_WIN` 100, less `FAVOUR_DOCK` 1 a gate point |
| Components destroyed per won battle | 0.07 (0.11 any outcome) | the loss the inflow must beat |
| Machines wrecked per battle | 0.53 | each one rushed (Favour) or sat out (a battle) |
| Wrecks rushed | 8 in 40 runs | `RUSH_PRICE` 100 Favour |

Since the draft (7 October, later): with each run's three drawn from its tender instead of the
fixed Badger, Sparrowhawk and Baboon, runs get harder. 32 of 40 are won, 75% of battles, and
0.17 components are destroyed per won battle. Salvage is 123 per won battle and Favour 92.
Re-read these against the new report before pricing.

So one run pays about **1,200 salvage** from won battles alone, plus the kills in held and
withdrawn ones. It also pays about **1,000 Favour** on top of `START_FAVOUR` 100. Read those
as the budget every price is cut from.

Three caveats before trusting them:

- **Salvage will rise.** The loot on the map is not built (Derelicts, Carcasses, Relics).
  The bot never detours for it.
- **Favour runs high.** The bot bunches and rarely lets a pack reach the gate, so the docking
  hardly bites. A player who splits lanes, or takes a detour for loot, will pay more of it.
- **Kills don't scale with danger yet.** Salvage is a flat 10 a foe, unweighted. Section 4's
  pacing calculation, which also fills the Rupture meter and Anathema, may weight kills by
  danger. Settle that first, since it moves the salvage rate.

## Every sink, and what it costs today

| Sink | Currency | Today | Notes |
|---|---|---|---|
| Building a component from a blueprint | salvage | not built, no price | by tier? one price per tier is the simplest start |
| The capital's gate | salvage | `REPAIR_COST` 5 a point (300 points: 1,500 for a full gate) | the bot's only sink today, so it spends everything here |
| Procurement: a component | Favour | not built | each standing city's maker, a few a turn |
| Procurement: a chassis (the fourth machine and later) | Favour | not built | now and then; the fourth slot is empty from the start and its machine is bought, never unlocked |
| The Arsenal's trickle at the capital | Favour | not built | gated by the Convergence's tier |
| Rushing a wreck | Favour | `RUSH_PRICE` 100 | each wreck its own cost (Ryan, 7 October) |

Free, and staying free: the host maker's offer after a won battle, a research token
unpacked, hull and cracked repairs, refits. Starting stock: `START_SALVAGE` 0,
`START_FAVOUR` 100, the tier-one blueprints, three tier-one machines.

## The method proposed

1. **Count the decisions.** The loop row asks for 15 to 25 real decisions across twelve
   battles. Split them between the two currencies by what each buys: salvage makes things,
   Favour buys services and stock.
2. **Cut prices from the budget.** A run's salvage divided by the builds it should
   afford gives the base build price. Tier two and three multiply it. Do the same for Favour
   with procurement, where a chassis should cost several wins' fees.
3. **Anchor the trade-offs to a battle's pay:**
   - Rushing a wreck should cost about one battle's Favour, the price of its seat for a battle.
   - Is a point of capital gate worth more than a build?
   - What is a pack reaching a city's gate worth in lost Favour? That decides whether loot
     detours pay.
4. **Measure, then read bands.** Run each price set and read the bands, never a decimal:
   - The bot buys everything it sees: too cheap.
   - It never affords a tier two: too dear.
   - Every run ends hoarding one currency: that currency has no sink worth it.

## What the runner needs first

The runner has nothing to buy yet, so the first job is a spending policy, an inflow bot:

- **Procurement in the sim:** what each maker stocks and at what Favour, refreshed each turn,
  with a fallen city's maker leaving the shelf.
- **Builds and fitting:** building from blueprints and fitting the best component to an open
  hardpoint (what refills a hardpoint whose component was destroyed).
- **Offers and tokens:** taking the host maker's offer, and unpacking research tokens (the boss
  drops one).
- **Loot on the map:** seeded and claimed, once its density is decided.
- **The report:** end-of-run inventory (unspent salvage and Favour, unfitted components,
  blueprints), hardpoints filled over the run, and the tier of what the squad fields by
  the finale.

## Open going in

- Price per tier, and whether a tier-three build needs anything beyond salvage.
- The docking rate. At `FAVOUR_DOCK` 1, a city gate of 200 can zero a win's fee.
- The procurement shelf: how many items, the refresh, the chassis rate, and the Arsenal's
  gate by the Convergence's tier.
- The breadth of components a run deals (Ryan, 24 October: breadth, not quantity, since a
  blueprint is more of one piece): the loot wrecks on the map beefed up, more plentiful or more
  bountiful, and more for the player to buy from the shelf with, loot at a battle's end waiting
  to see (`git show 85e28fd:docs/curve_proposal.md`, the pay).
- The capital's repair price, against what the finale needs the gate to be.
- Starting salvage and Favour, and whether the starting draft spends either.
- Deferred here from the bible's section 12 (Ryan, 4 November): what makes a Sponsorship piece
  rare now that tiers exist, and what a domain-themed research token draws from; whether a
  module is ever a blueprint or each one a single item, and whether its stat line is rolled or
  the catalogue's; whether a starting chassis is replaced or kept through a run; the roster's
  turnover (machines easier to scrap), read with the foes' damage axis.
- Whether a held battle (a wipe the city survives) should pay any Favour. Today it pays
  none, and the ledger says only a win pays unless that proves terrible for balance.

## From the roster analysis's go (14 and 15 October)

Raised in Ryan's go on the roster analysis and left for this pass; the offer's and the token's
kinds are settled (22 October), the rest is not.

- **The host maker's offer after a win** (Ryan's latest shape): a module, a component one tier
  above the shelf's and a chassis, all from its catalogue, the guaranteed chassis being the
  rebound after a bad battle. Settled (Ryan, 22 October): the component is a copy, never a
  blueprint, since the boss's token already yields a blueprint a win; the bible's offer row and
  the rules say so. If the chassis is guaranteed, the Recommended chassis offer rate
  (one every two or three battles, bible section 3) retires.
- **The boss's research token** unpacks into a choice of three blueprints of the domain's
  theme at the Convergence's tier, so tier-three blueprints come only from late bosses (Claude's
  proposal; Ryan's reading too, 22 October: settled).
- **Procurement**: tier ones early (Ryan asked whether the shelf and the offer should deal tier
  ones early in a run, 14 October); Claude's proposal around it: a shelf slot for each standing
  maker, the Arsenal's at the capital by the Convergence, the tier gated by the Convergence, a
  blueprint on it rarely and at a premium, repeats allowed.
- **Where blueprints come from, and what each currency buys.** Blueprints were meant to be
  Salvage's main sink, so if they come mostly from tokens and the offer, the sinks are re-read
  (Ryan's concern in the go). Claude's proposal: Salvage builds copies of owned blueprints,
  replaces destroyed pieces and repairs the gate; Favour buys the shelf, rushes and rare
  blueprints. Rates, not a redesign.
- **The roster's size**: about ten chassis a city maker at the top end (Ryan's counts, in
  `docs/briefs/README.md`), so the offer and the shelf deal from a catalogue far larger than
  a run fields.

Out of scope: the two shields no chassis stocks (the Halo Shield and the Corona Shield) keep
their placeholder tiers, one and two. They wait for the content revision and expansion
(Ryan, 7 October).

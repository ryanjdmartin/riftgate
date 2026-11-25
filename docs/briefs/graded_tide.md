# The graded tide: the battle's enemy side

<!-- hangar: {"kind": "rule", "maker": null, "tier": null, "status": "direction", "slot": false, "name": "the graded tide"} -->

A design in progress, the foes' line's. Its direction is locked (Ryan, 25 November: "our
direction here is locked"); its numbers are not. This brief holds the direction in his words,
which of the built numbers are placeholders, the Meadow's packs, what is his to settle and
the order of work. How it runs is `docs/rules.md` (The battlefield: The graded tide); why is
the bible's graded tide row (section 4); every read is `docs/measurements.md`, 23 to 25
November. The formation pass runs from here.

What it replaces is in git: the proposal it grew from, with the session's leans and the
trials cut on the way, `git show 81b1e522:docs/tide_proposal.md`; what was left of the
formation pass of 10 November, `git show 81b1e522:docs/formation_proposal.md`.

## 1. The direction

Each point is his, and locked.

1. **The question is where the forces go.** "All fodder safer to fight, reducing the 'fight
   short for efficiency, fight full for safety' decision in favour of 'where do I put my
   forces.'" The game it replaces failed that: "there is NO REASON to send a machine to the
   flanks ... Any time I tried splitting my forces, I lost the battle. Any time I stayed in
   the middle, I won."
2. **Packs are rated one to three, an elite four, and scaled, never split.** "I don't want
   the packs split, I want them SCALED. I didn't say to get rid of threat-3, I said to add
   threat-2 back in."
3. **Strength falls toward the wall's ends.** "So the far edges are 1s with a sprinkling of
   2s, then 2s in between, and 3s coming right down the center."
4. **Pace runs the other way**, and a pack's pace is its own: "1s fastest and 3s slowest (a
   hypothetical hunter threat 3 would be fast, obviously)."
5. **More packs, each less to the wall, and a pack pays for falling.** "More fodder overall,
   with choices of pack sizes and pack types ... Maybe add a flat fracture bonus to a pack on
   top of the per-foe weight, so that splitting into 4 fights across the map and grouping for
   bigger packs are both viable ways of farming fracture. Reduce foe damage to the wall so
   that quantity matters."
6. **A flanker ends a fight on the side without a reboot.** "A well-tuned and well-played
   flanker should be able to finish a fight on the sides without rebooting, and we leave
   reboots to the longer, more intense, hunter, elite, or boss fights."
7. **No authored waves.** "Variability is good, chaos is good, and allowed when each
   particular fodder pack is less threatening to both the player and the wall."
8. **Few tears; the packs a mouth sends at once are the volume and the Convergence's dial.**
   "I wouldn't clutter the map with a ton of tears. I think enabling multiple spawns at the
   rift and at tears is plenty ... it gives us a very useful tuning dial for convergences.
   More so then the beat, I think."
9. **A set form for each Convergence, never quantity alone.** "A set form of each formation,
   for each C. Bosses too ... It's fundamental for balance"; "Going from, say, 3 goblins to 2
   goblins and a mandragora should also be a bump, ideally."
10. **A massive foe is a kind of unit, no measure of threat.** "I always just wanted it to be
    another kind of unit, offering variety, not necessarily more threat"; "its a property, not
    a quota. Perhaps one domain has more massives as an identity, and one has less as an
    identity (probably Meadow)." They "go where they make sense."
11. **More kinds of enemy.** "In general, we just need more enemy diversity. Mixing and
    matching what we've got is fine, but if every pack were constructed of unique things,
    that would be fine too."
12. **A squad's growth inside a tier is a target, set before the components are filled to
    it.** "I will greatly enjoy filling out the component tiers, once our targets are set."
13. **The elite gathers the squad, and cannot be led about.** "I want it to be a forced
    fight, without feeling like a forced fight"; "get everyone back to the center to take
    this on together." The hunters are "probably bumped to 3" and pinned for now.
14. **The field is full from the first turn, and the rift's packs come out toward where they
    are going.** "There needs to be more packs on the field at the start, for sure. And
    spawns from the rift should probably spawn outside of the shell, and on a hex that is on
    the side of where they're headed."

## 2. What is built, and which of its numbers are placeholders

The engine deals the graded tide on its dial (a debug build's SETTINGS, TRIALS, SET, GRADED;
`RIFTGATE_GRADED=1` on the desk) and the earlier tide otherwise: the switch-over is the
order's first step. The Meadow alone has packs written for it; every other domain plays it
on its patrols and formations as they stand, by their ratings.

| The number | As built | Whose |
|---|---|---|
| The wall's bands and their ratings | Five: 1, 2, 3, 2, 1 | The session's reading of point 3 |
| An end's pack for two | One in five | The session's ("a sprinkling") |
| The paces | Ones 3; twos and threes their foes', 2, and 1 with a treant | The session's |
| The opening | Seven packs, eight from Convergence 3 and nine from 8 as the rules count it: two ones at each end, a two between, the ramp's threes down the middle | The session's count, his to mark |
| The hunting packs | One out of the rift every other peak from the second | The session's, pinned with the hunters |
| SENDS, the packs a mouth sends at a peak | A dial, 1, 2 or 3; the set lays 2 | His to set at each Convergence |
| STRIKE, a pip's strike at the wall | A dial, 10 (the game's), 5 or 3; the set lays 5 | His |
| PACK BONUS, a fallen pack's pay over its rating | A dial, none, half a pip or a pip; the set lays half | His |
| FIELD DEPTH | A dial, 12 (the game's), 14 or 16 | His |
| A rating's size | Eight hit points a machine, the read of what one gauge ends | A start; the target is his (section 5) |

## 3. The Meadow's packs

In content (`content/factions.json`, each marked `tide`: `graded`, dealt by the graded tide
alone), working ids and no names, every number a placeholder: his marks change them ("I
would mark a table"). The reads are stock dice at the tier's first battle, the greedy bot,
the six certain tier ones; reboots are a machine's a fight. "From" is the battle of the tier
a pack is first dealt at (C1 the tier's first, the code's ramp 0).

| The pack | For | Lane, pace | Hit points | At its rating | A machine short | From |
|---|---|---|---|---|---|---|
| Two mandragoras | 1 | Ends, 3 | 6 | 2.2 rounds, 0.1 reboots | | C1 |
| A goblin and a mandragora | 1 | Ends, 3 | 7 | 2.9 rounds, 0.3 reboots | | C1 |
| Two goblins | 1 | Ends, 3 | 8 | 3.8 rounds, 0.6 reboots | | C2 |
| A lone gel | 1 | Ends, 3 | 8 with its halves | 4.6 rounds, 0.8 reboots | | C3 |
| A lone whisker cat | 2, then 1 | Ends, 3 | 12 | As a one: 5.3 rounds, 1.2 reboots | | C1 as a two, C3 as a one |
| Three goblins | 2 | Between, 2 | 12 | 2.8 rounds, 0.2 reboots | Won 100%, a fifth of its hull | C1 |
| Two goblins, two mandragoras | 2 | Between, 2 | 14 | 3.0 rounds, 0.3 reboots | Won 63% | C1 |
| Two gels | 2 | Between, 2 | 16 with their halves | 4.5 rounds, 0.6 reboots | Won 50% | C2 |
| A lone treant | 2 | Between, 1 | 14, plated | 4.7 rounds, 0.9 reboots | Won 61% | C2 |
| Four goblins | 2 | Between, 2 | 16 | 4.3 rounds, 0.6 reboots | Won 83%, most of its hull | C3 |
| Two whisker cats | 2 | Between, 3 | 24 | 5.4 rounds, 1.1 reboots | Won 44% | C4 |
| The horde of six: three goblins, three mandragoras | 3 | Middle, 2 | 21 | 3.2 rounds, 0.3 reboots | Won 100%, a quarter of the pair's hull | C1 |
| The grove thinned: a treant, two goblins, a mandragora | 3 | Middle, 1 | 25, plated | 5.5 rounds, 1.0 reboots | Won 100%, 9.7 rounds | C1 |
| The horde of seven | 3 | Middle, 2 | 25 | 4.3 rounds, 0.8 reboots | Won 80% | C2 |
| The gel wall | 3 | Middle, 2 | 30 with their halves | 4.4 rounds, 0.7 reboots | Won 57% | C2 |
| The horde of eight | 3 | Middle, 2 | 28 | 5.2 rounds, 1.1 reboots | Won 47% | C3 |
| The grove | 3 | Middle, 1 | 32, plated | 6.6 rounds, 1.4 reboots | Won 63% | C3 |
| Two treants | 3 | Middle, 1 | 28, plated | 6.7 rounds, 1.4 reboots | Won 90%, 11 rounds | C4 |

A pack whose rating falls as the squad grows is two entries, each with its gate (the lone
whisker cat). Three treants are no tier-one pack as the treant stands. The wolves are the
hunters', pinned.

## 4. The leaders and the bosses as fixed entries

His, and built only on his go. Ryan, 7 November: "a boss' tiered and ramped stats and
escorts should be split into seperate fixed entries, same as a pack's would"; "Don't curate
the bosses now, that can wait"; and of the forms by Convergence on 23 November, "Bosses
too".

Today a boss, an elite, a final's hero and the finale's line ride a multiplier a tier
(`ContentDB.BOSS_TIERS`: hit points as written, by 1.1 and by 1.25; attack as written, one
more and two more) and nothing moves inside a tier. The form proposed, his to move:

- **Stat blocks on the entry**, in `content/foes.json`: a list of fixed entries, each a tier
  and an optional band of Convergences with its hit points, attack and armour, a tier's
  blocks together holding every Convergence. The engine takes the block that holds, in the
  multiplier's place; an entry with no blocks rides the multiplier until he marks it. A boss
  stays one named entity at every tier.
- **The escort stays an `escort` composition**, curated by tier and never grown, with a band
  of Convergences when wanted; a part's numbers ride its core's block.
- **A final's wildlife** becomes a named `escort` composition a domain and tier, so a
  final's fight is authored too.

What it waits on: a rating's size at each Convergence (section 5), since a leader's block is
sized to the same target; then the blocks go to him as a table. His marks on the escorts at
tiers two and three are `docs/bosses_proposal.md`'s.

## 5. Open, his

1. **The values.** SENDS at each Convergence, STRIKE, PACK BONUS, FIELD DEPTH, and the
   opening's count at each Convergence.
2. **The Meadow's table** (section 3): each row's rating, pace and gate, and what is missing.
   For the ends' packs in every domain his words on a second flank patrol stand ("Different
   enough that the same strategy doesn't strictly work on both would be ideal. Don't want to
   be able to hyperoptomize the flankers ... just not sending pushers that are designed to
   counter multiple mechs to the flanks"), and the pickets he standardized on 19 November are
   among them (`docs/briefs/refit_pass.md`, section 11, with their reads).
3. **A rating's size at each Convergence of a tier**, the target the packs' forms, the
   leaders' blocks and the component tiers are all filled to. The reads give its start:
   eight hit points a machine.
4. **The treant**, which waits on his marks ("Don't bother with the treant just yet. I will
   mark things"), and with it the pass for massive foes and more kinds of enemy in every
   domain; the ones he floated on 24 November were "complete spitballs", no list.
5. **The elite's arrival**, so it cannot be led, and **the hunters' role and rating**, when
   he takes each up.
6. **The duelists** (the whisker cat, the Roc, the Dullahan, Cerberus), which stand in
   content as each domain's lone pack for one: their numbers, their twelve working names and
   their sprites. Four holes stand from their landing: the cat's Jam can cost a lone machine
   its whole round; the Roc on a count of one is seen for a single round; the Dullahan and
   the Zombie Knight ask the same question; Cerberus asks for Armoured, which few tier ones
   stock.

## 6. What the reads say

- **A rating's size.** A machine's gauge is three shots of a basic gun, nine or ten points of
  damage, so eight hit points a machine is what a pack holds and still falls inside one
  gauge. The game's own ones (12 to 14), twos (24) and threes (28 to 38) are each over
  it, half again or more: at their ratings they cost a reboot a machine, and a machine short
  they are a coin's toss. The horde two heads lighter is 3.2 rounds and 0.3 reboots for three, and two machines
  always win it.
- **The squad's shape.** In the coverage model (`tools/tide_model.py`) a squad that camps
  loses the wall and so does one that never gathers; a free squad's greatest loss is to the
  twos, the ends' twos the worst of it; slowing the threes costs less than speeding the ones.
- **The whole battle, a direction at ten seeds.** The bot's player gathers and holds no
  lane, so it is a floor: at one send it wins half the Meadow's second battles with two
  thirds of its hull at the Rupture; at two it loses the wall in eight of ten.
- **A treant at eight hit points**, its plate and its blow as they are: two are 3.4 rounds
  and 0.5 reboots for three; one machine alone still spends 6.2 rounds and 1.8 reboots on
  one. Its plate, its regrowth and its blow make it strong, more than its hit points.
- **A kit's growth inside tier one.** Two of today's finds a die take a third off a leader's
  price, two of the bench's a sixth (`docs/briefs/numbers_pass.md`, section 6). The finds are
  placeholders, so this measures no design: point 12 stands over it.

## 7. Set aside, each with the test it failed

- Every formation dealt as small packs: his refusal ("I don't want the packs split").
- A formation as an authored wave through neighbouring tears: his refusal (point 7).
- The tide sending before the packs walk: his own, retired as "a bandaid solution".
- Tears open from the first turn: his refusal (point 8).
- A pack's blows scaled down by a dial: the size already makes a pack safe at its rating,
  and blows are content's numbers.
- A pace by the rating alone, written as a rule: his fast hunter is the exception that makes
  a pace the pack's.
- The elite hunting whichever machine is closest, read again each turn: it can be handed
  about and led, which he refused.

## 8. The order from here

1. **The switch-over**, on his word: the graded tide the game's own, its TIDE dial and the
   earlier tide's cycle cut from the engine, the runners and the tests moved onto it.
2. **Each value as it settles** landed in the engine or the ramp's table, the sends by the
   Convergence first, and its dial cut.
3. **A domain at a time**, each a table for his marks first; with it the pass for massive
   foes and for more kinds of enemy.
4. **A rating's size at each Convergence**, the target; then the leaders' and the bosses'
   blocks as a table for his marks, read with the tier-one bench.
5. **The elite's arrival and the hunters' role**, each its own session.
6. **The runner's player** rewritten to hold lanes and to gather, then the hull budget's
   shares read again.

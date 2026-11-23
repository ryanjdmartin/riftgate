# The graded tide

Ryan's design of 23 November for the battle's enemy side. Nothing of it is decided, built or
in content: section 4 is the design as the session reads it, for him to strike; section 6 is
where the session agrees and where it pushes back; section 7 is the Meadow's packs as a table
for his marks. The formation pass (the to-do's design sessions) runs from here.

## 1. What Ryan said (23 November)

After his play of the field's dials:

- "Right now, there is NO REASON to send a machine to the flanks to fight the 1s and 2s ...
  Any time I tried splitting my forces, I lost the battle. Any time I stayed in the middle, I
  won. The game as it was, was fundamentally flawed and not meeting our goals."
- "I don't actually think we were that far off, we just needed a paradigm shift: All fodder
  safer to fight, reducing the 'fight short for efficiency, fight full for safety' decision
  in favour of 'where do I put my forces.' More fodder overall, with choices of pack sizes and
  pack types - bring back threat 2 packs as fodder and not just hunters ... Maybe add a flat
  fracture bonus to a pack on top of the per-foe weight, so that splitting into 4 fights
  across the map and grouping for bigger packs are both viable ways of farming fracture.
  Reduce foe damage to the wall so that quantity matters. Spread fodder across the map,
  either through more Tears, or through multiple spawns at the rift headed in different
  directions (or both). Tears need to spread wide, the crawl forward isn't as important as
  distributing enemy forces."
- "I like our reboot mechanic, but it is a death sentence for a flanker fighting alone, which
  is why I only ever grouped. A well-tuned and well-played flanker should be able to finish a
  fight on the sides without rebooting, and we leave reboots to the longer, more intense,
  hunter, elite, or boss fights."
- Of a first trial that dealt every formation as packs for one machine and for two: "you're
  missing the point. A pack of slow treants coming down the center, scaled for 3 machines, is
  still a good pack and offers a decision point. I don't want the packs split, I want them
  SCALED. I didn't say to get rid of threat-3, I said to add threat-2 back in. Massive foes
  don't go away, they go where they make sense. Maybe a single treant is too strong to flank
  at C2, but not at C3."
- The shape: "Packs vary in strength, threat 1-3, 4 for elites. Hunters probably bumped to 3
  but still want to put a pin in those for now. Spawns reduce in strength the further to the
  sides of the map they target. So the far edges are 1s with a sprinkling of 2s, then 2s in
  between, and 3s coming right down the center. Move speed for pushers probably should reflect
  that, with 1s fastest and 3s slowest (a hypothetical hunter threat 3 would be fast,
  obviously)."
- No authored waves: "Variability is good, chaos is good, and allowed when each particular
  fodder pack is less threatening to both the player and the wall."
- The Convergence: "A set form of each formation, for each C. Bosses too ... It's fundamental
  for balance"; and never "just straight quantity. Going from, say, 3 goblins to 2 goblins and
  a mandragora should also be a bump, ideally."
- The elites: "I don't want to be able to lead around Elites. I want it to be a forced fight,
  without feeling like a forced fight"; their purpose, "get everyone back to the center to
  take this on together."
- The packs as content: "I would mark a table."

## 2. In the game since that day

The zoom out to the whole field; the seam a circle about the rift, a picture alone; the round
shown under the whole field; a pusher's segment the stretch of wall it reaches soonest; the
tears' row a row a peak and never within four rows of the wall; every tier-one stock die
basics beside its locked pieces (`docs/rules.md`, The battlefield; the bible's wall, tears and
seam rows). The basics' numbers are settled as built and their five dials cut.

## 3. On trial

A debug build's SETTINGS, TRIALS, each read as the next battle starts and none the game's:
PACK BONUS (a quarter, a half or a whole pip a pack pays the meter as it falls, the meter
sized to match), STRIKE (what a pip strikes the wall for), START TEARS (two at the wall's
ends, or four across it), PACE, RIFT SENDS, TIDE, FIELD DEPTH, OPENING, FODDER, RUPTURE and
LEADERS; SET's AS BUILT lays the page back.

Cut that day, each with the test it failed: the tide sending before the packs walk (his own,
"a bandaid solution"), and every formation dealt as small packs drawn by rule from its foes
(the session's reading of "all fodder safer": it took the threes and the massive foes off
the field, and left spreading the one answer where gathering had been).

## 4. The design, as the session reads it

1. A pack is rated one to three, an elite four. The rating is the machines it is for, and it
   is honest: that many machines end it comfortably, and fewer pay for it.
2. Packs are scaled, never split: each is sized to its rating at the tier's first battle and
   has a set form for each Convergence after. What steps is what the pack holds as much as
   how many.
3. Strength falls toward the wall's ends: threes down the middle, twos between, ones at the
   ends with a two now and then. The massive foes stand where they make sense, the middle
   first.
4. Pace runs the other way: ones fastest, threes slowest. A hunter is its own case.
5. More packs than today, each striking the wall for less; a pack pays a flat bonus on the
   meter as it falls.
6. The hunters are pinned, probably rated three; the elite gathers the squad.

## 5. What was measured

`docs/measurements.md`, 23 November, has every table.

**A rating's size.** A machine's gauge is three shots of a basic gun, nine or ten points of
damage, so eight hit points a machine is what a pack can hold and still fall inside one gauge.
Today's packs are over it at every rating, on stock dice at the tier's first battle:

| The pack | Hit points | At its rating | A machine short |
|---|---|---|---|
| A lone whisker cat, today's one | 12 | 5.3 rounds, 1.2 reboots | |
| Two goblins | 8 | 3.8 rounds, 0.6 reboots | |
| Two whisker cats, today's two | 24 | 5.4 rounds, 1.1 reboots a machine | won 44% |
| Three goblins | 12 | 2.8 rounds, 0.2 reboots | won 100%, a fifth of its hull |
| The goblin horde, today's three | 28 | 5.2 rounds, 1.1 reboots a machine | won 47%, a wreck a fight |
| The same horde two heads lighter | 21 | 3.2 rounds, 0.3 reboots | won 100%, a quarter of the pair's hull |

**The squad's shape.** The coverage model (`tools/tide_model.py`: twelve turns, fights for
free, a pack wanting its rating in machines) with the gradient laid, 33 pips in 19 packs
against today's 19 in 13, ten a pip:

| The squad | Gate lost | Lost to ones, twos, threes |
|---|---|---|
| Free, every pack at pace 2 | 193 | 32, 96, 64 |
| Free, paces 3, 2 and 1 | 151 | 39, 93, 19 |
| Free, paces 4, 3 and 2 | 274 | 50, 158, 66 |
| The same, fourteen deep | 205 | 48, 112, 45 |
| The same, no pack for two at the ends | 176 | 54, 77, 45 |
| The same, half the ends' packs for two | 370 | 43, 236, 91 |
| Holding the gate | 1050 | 435, 609, 6 |
| Camped on the rift | 1474 | 550, 924, 0 |
| Each machine holding a lane of its own | 1027 | 22, 400, 605 |
| The middle split into a two and a one, each machine holding a lane | 439 | 46, 394, 0 |

**A squad's growth inside a tier**, by guns alone: two of today's finds a die take a third off
a leader's price, two of the bench's a sixth (`docs/briefs/numbers_pass.md`, section 6). A lone
treant against one machine: stock dice won 71% in 11.3 rounds; two finds a die won 96% in 8.8
rounds with 2.6 reboots; every basic gun a find, 7.5 rounds, 2.3 reboots and half its hull.

**The forms the game lost.** His design of 7 November had compositions as variants placed on
the tier and the Convergence, and the bosses as fixed entries. The gate that deals a variant
still runs; the formation pass pruned the thinner of each pair on a read from before the
reboot, and the bosses' entries were never written. So 26 of 119 compositions carry a gate,
no leader's numbers move inside a tier, and the horde of six and of seven below are his own
variants coming back.

## 6. Where the session agrees, and where it pushes back

**Agrees.**

- The threes stay, and they are what makes the squad's shape a choice. Four machines stand
  as three and one, two and two, or two, one and one: a three and a two cannot both be met at
  their rating. In the model a squad that camps loses the wall and so does one that never
  gathers; with the middle split, holding a lane each cost little, so the trial of the
  morning had only swapped one answer for another.
- Scaled, never split. The size that makes a pack safe is the same at every rating, eight hit
  points a machine, and today's ones, twos and threes are each half again over it. The horde
  two heads lighter is a clean fight for three and a survivable one for two; as built it is a
  reboot each and a coin's toss short.
- The massive foes in the middle. They move 1 in content already, so the slow lane is theirs
  with no new rule, and a treant alone is a good pack for two.
- Strength falling toward the ends and pace rising. It gives a lane a kind of machine: the
  fast light ones at the ends, the heavy ones in the middle.
- The wall struck for less as the count rises: at this count even the model's free squad
  loses 150 to 270 at ten a pip.

**Pushes back**, each with what would settle it:

1. **The packs for two at the wall's ends.** In every row of the model a free squad's
   greatest loss is to the twos, and the ends' twos are the worst of it (176 with none, 370
   with half). In the fight an end's two is met by the one machine that lives there: at
   twelve hit points that is a reboot and a fifth of its hull, at twenty-four a loss more
   often than not. That is the fight short he wants gone, in the one place a machine is
   alone. The lean: an end's two is a twelve, slow enough to be seen coming, and rare.
2. **Slow the threes before speeding the ones.** Paces 3, 2 and 1 lose 151 in the model, 4, 3
   and 2 lose 274. A pack for one at pace 4 from a tear on the tears' row is at the wall in
   two walks. His own words on pace were "I'd rather they don't start so close but reach the
   wall faster", so a faster one wants its mouth farther back or a deeper field. The lean:
   ones 3, as today's lone flankers are; twos 2; threes 2, and 1 with a massive foe in them,
   as content has it; the ends' mouths set back by the rift's row and never creeping.
3. **Pace is the pack's, not the rating's.** His own exception says so, the hunter that is
   rated three and fast. The lean: a composition carries its pace where its design wants one,
   and walks at its slowest member's otherwise.
4. **"Too strong to flank at C2, but not at C3" asks for growth a tier does not have.** By
   the reads a lone treant is a pack for two through all of tier one, on any kit of today's
   finds, and the bench flattens the finds further. The principle stands and the Meadow has
   its case: the lone whisker cat, 1.2 reboots on stock dice and 0.6 with two finds a die. But
   a one's budget moves from eight to nine or ten across a tier, not to fourteen. What settles
   it: what else he counts on to grow a squad inside a tier (modules, branches), which no
   read here holds.
5. **Whether a three should fall without a reboot.** His line draws it at the flanker: the
   reboot is a death sentence alone, and in a three's fight two partners cover it, which is
   where the Shoring Jack and the Barrier earn their slots. The table shows the horde at six,
   seven and eight so he can say where it sits.

**Follows from his words, named and not asked.** A pack walks to the wall it reaches soonest
(his rule of the same morning), so its lane is its mouth's: the ends' mouths send ones, the
mouths between send twos, the rift sends threes, and no pack crosses a lane. A pack whose
rating falls as the squad grows is two entries in content, each with its gate; the meter and
the wall strike follow the rating it is dealt at.

## 7. The Meadow's packs, for his marks

Working labels, no names. Every read is stock dice at the tier's first battle, the greedy
bot, the six certain tier ones; reboots are a machine's a fight. "From" is the Convergence
the session would first deal it at.

| The pack | For | Lane, pace | Hit points | At its rating | A machine short | From |
|---|---|---|---|---|---|---|
| Two mandragoras | 1 | Ends, 3 | 6 | 2.2 rounds, 0.1 reboots | | C1 |
| A goblin and a mandragora | 1 | Ends, 3 | 7 | 2.9 rounds, 0.3 reboots | | C1 |
| Two goblins | 1 | Ends, 3 | 8 | 3.8 rounds, 0.6 reboots | | C2 |
| A lone gel | 1 | Ends, 3 | 8 with its halves | 4.6 rounds, 0.8 reboots | | C3 |
| A lone whisker cat | 2, then 1 | Ends, 3 | 12 | As a one: 5.3 rounds, 1.2 reboots; 3.9 and 0.6 with two finds a die | | C1 as a two, C3 as a one |
| Three goblins | 2 | Between, 2 | 12 | 2.8 rounds, 0.2 reboots | Won 100%, a fifth of its hull | C1 |
| Two goblins, two mandragoras | 2 | Between, 2 | 14 | 3.0 rounds, 0.3 reboots | Won 63% | C1 |
| Two gels | 2 | Between, 2 | 16 with their halves | 4.5 rounds, 0.6 reboots | Won 50% | C2 |
| A lone treant | 2 | Between, 1 | 14, plated | 4.7 rounds, 0.9 reboots | Won 61% | C2 |
| Four goblins | 2 | Between, 2 | 16 | 4.3 rounds, 0.6 reboots | Won 83%, most of its hull | C3 |
| Two whisker cats, as content has them | 2 | Between, 3 | 24 | 5.4 rounds, 1.1 reboots | Won 44% | C4, as its gate has it |
| The horde of six: three goblins, three mandragoras | 3 | Middle, 2 | 21 | 3.2 rounds, 0.3 reboots | Won 100%, a quarter of the pair's hull | C1 |
| The grove thinned: a treant, two goblins, a mandragora | 3 | Middle, 1 | 25, plated | 5.5 rounds, 1.0 reboots, almost no hull | Won 100%, 9.7 rounds | C1 |
| The horde of seven | 3 | Middle, 2 | 25 | 4.3 rounds, 0.8 reboots | Won 80% | C2 |
| The gel wall, as built | 3 | Middle, 2 | 30 with their halves | 4.4 rounds, 0.7 reboots | Won 57% | C2 |
| The horde of eight, as built | 3 | Middle, 2 | 28 | 5.2 rounds, 1.1 reboots | Won 47% | C3 |
| The grove, as built | 3 | Middle, 1 | 32, plated | 6.6 rounds, 1.4 reboots | Won 63% | C3 |
| Two treants | 3 | Middle, 1 | 28, plated | 6.7 rounds, 1.4 reboots | Won 90%, 11 rounds | C4 |

Three treants are no tier-one pack: three machines won 95% in 10.4 rounds at a quarter of a
squad's hull. The wolves are the hunters', pinned.

## 8. Questions for Ryan

1. The five points of section 6: which he takes, and which he holds to as he said them.
2. The table: each row's rating, lane, pace and Convergence, and what is missing.
3. Whether the ends' mouths and the mouths between are tears open from the first turn (START
   TEARS FOUR stands them at the wall's ends and thirds), or the rift fanning packs out.
4. The elite's arrival, so it cannot be led, and the hunters' role, when he takes each up.

## 9. Bench: ideas set aside, one line each, for him to overrule

- Every formation dealt as small packs: his refusal ("I don't want the packs split").
- A formation as an authored wave through neighbouring tears: his refusal ("that will reduce
  variability").
- The tide sending before the packs walk: his own, retired as a bandaid.
- A pack's blows scaled down by a dial: the size already makes a pack safe at its rating, and
  blows are content's numbers.
- A pace by the rating alone, written as a rule: his hunter is the exception that makes it
  the pack's.
- The elite hunting whatever machine is closest, read again each turn: it can be handed about
  and led, which he refused.
- A leader's numbers by a multiplier a Convergence as the game's rule: his form is the fixed
  entry; LEADERS is a dial for the feel alone.

## 10. If he says go: the order

1. His marks on the table and his answers to section 8.
2. The Meadow's packs as content, each with its rating, its pace where it has one and its
   gate by Convergence.
3. The lanes on a dial (a mouth deals by where it stands) with the pace beside it, for his
   play; then each value that settles landed and its dial cut.
4. A domain at a time, each a table first. The leaders' blocks by tier and Convergence as a
   table for his marks, read with the tier-one bench.
5. The elite's arrival and the hunters' role, each its own session.
6. The runner's player rewritten to hold lanes and to gather, then the hull budget's shares
   read again.

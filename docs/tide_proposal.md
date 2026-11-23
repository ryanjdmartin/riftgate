# The tide as fodder

Ryan's paradigm of 23 November for the battle's enemy side, on trial. What stands in the game
is section 2; section 3 is a debug build's dials, none the game's until he says; the rest is
what was measured, the forms by Convergence still to write, the reasoning, the holes and the
questions only he can answer. The
formation pass (the to-do's design sessions) runs from here once he has played it.

## 1. What Ryan said (23 November)

After his play of the field's dials:

- "Right now, there is NO REASON to send a machine to the flanks to fight the 1s and 2s ...
  Any time I tried splitting my forces, I lost the battle. Any time I stayed in the middle, I
  won. The game as it was, was fundamentally flawed and not meeting our goals."
- Then, of the first cut of this proposal (a front of tears, formations as authored waves):
  "I want to see how the game feels with my first set of changes, first. I don't actually
  think we were that far off, we just needed a paradigm shift: All fodder safer to fight,
  reducing the 'fight short for efficiency, fight full for safety' decision in favour of
  'where do I put my forces.' More fodder overall, with choices of pack sizes and pack types -
  bring back threat 2 packs as fodder and not just hunters. With the change that removed path
  blocking this is possible, now, without being clunky. Maybe add a flat fracture bonus to a
  pack on top of the per-foe weight, so that splitting into 4 fights across the map and
  grouping for bigger packs are both viable ways of farming fracture. Reduce foe damage to the
  wall so that quantity matters. Spread fodder across the map, either through more Tears, or
  through multiple spawns at the rift headed in different directions (or both). Tears need to
  spread wide, the crawl forward isn't as important as distributing enemy forces."
- The flow he wants: "I like our reboot mechanic, but it is a death sentence for a flanker
  fighting alone, which is why I only ever grouped. A well-tuned and well-played flanker
  should be able to finish a fight on the sides without rebooting, and we leave reboots to the
  longer, more intense, hunter, elite, or boss fights."
- No waves: "I wouldn't specify a 'wave' since that will reduce variability. Variability is
  good, chaos is good, and allowed when each particular fodder pack is less threatening to
  both the player and the wall."
- The Convergence: "A set form of each formation, for each C. Bosses too ... It's fundamental
  for balance"; and "Convergence scaling to a pack formation shouldn't just be straight
  quantity. Going from, say, 3 goblins to 2 goblins and a mandragora should also be a bump,
  ideally."
- The elites: "I don't want to be able to lead around Elites. I want it to be a forced fight,
  without feeling like a forced fight. The theme is 'they're crushing our armies, we need to
  sick an Elite on the machines'"; their purpose, "get everyone back to the center to take
  this on together."
- The hunters: "they aren't really cutting it at the moment, but I think we table that
  discussion until we decide what role they need to serve - if the role is 'chase the flanker
  back to the team' then it's kind of acting in the opposite direction I want, and its
  overlapping with the Elite purpose."
- The spawn order he had asked to try: "probably flawed, a bandaid solution and not
  addressing the root cause."

## 2. In the game since that day

The zoom out to the whole field; the seam a circle about the rift, a picture alone; the round
shown under the whole field; a pusher's segment the stretch of wall it reaches soonest; the
tears' row a row a peak and never within four rows of the wall; four tier-one stock dice back
to basics (`docs/rules.md`, The battlefield; the bible's wall, tears and seam rows). The
basics' numbers are settled as built and their five dials cut (the bible's vanilla, reboot and
Barrier rows). The spawn order's dial is cut with its engine path.

## 3. On trial: his first set

A debug build's SETTINGS, TRIALS, each read as the next battle starts. SET lays the first
four at once (FODDER TIDE) over whatever the rest hold, and AS BUILT sets the page back.

| The dial | The set | What it does |
|---|---|---|
| FORMATIONS | FODDER | Every formation the opening places or the rift sends comes apart into packs for one machine and for two, from its own foes, each to its own stretch of wall; every tear sends a patrol and a fodder pack in turn |
| PACK BONUS | +½ | A pack pays the Rupture meter that much of a pip as it falls, over its rating; the meter is sized to match, the tally untouched |
| STRIKE | 5 | What a pip of threat rating strikes the wall for a turn, ten the game's |
| START TEARS | TWO | Tears open from the first turn, at the wall's two ends; FOUR stands them at its ends and thirds |
| RIFT SENDS, TIDE | as built | More of the rift's sends, or of everything, for the same Rupture |
| PACE, FIELD DEPTH, OPENING | as he has them | His dials of the plays before |
| LEADERS | as he has it | An elite's and a boss's hit points a tenth or a fifth more for each Convergence past its tier's first |

**The fodder is a stand-in** (`ContentDB.fodder_of`), drawn by rule from today's formations
so the direction can be felt before a pack of it is written. Its rule, each part the
session's lean and none of it the game's:

- A formation's three pips come as three packs for one machine, or a pack for one and a pack
  for two, which by the battle's seed and the deal, so no two need come alike.
- A pack is any draw of its formation's own foes whose hit points come to a budget: 8 for one
  machine, 12 for two, never more than two in the back rank. A foe counts what it leaves as it
  falls (a gel's halves) and half again for a rising (the zombie knight's).
- The massive foes are in no pack: one met by a machine alone is ten rounds and three reboots.
- By the battle's place in its tier, more of a formation's packs are mixed: none at the tier's
  first battle, one in three at its second, two in three at its third, all at its last. The
  budget holds level through the tier.

The hunters, the elites, the boss, the Rupture's size and the ramp's counts are as built.

## 4. What was measured

`docs/measurements.md`, 23 November, has the tables.

**The size.** A machine's gauge is three shots of a basic gun, nine or ten points of damage,
so 8 hit points is what one gauge ends. Every pack the tier-one formations deal, at the
anchor, the greedy bot:

| The pack | At its rating, stock dice | With two finds a die | Met by one machine |
|---|---|---|---|
| For one (15 kinds) | 3.4 rounds, 1.0% of a four's hull, a reboot in 45% of fights | 2.7 rounds, 0.4%, a reboot in 19% | |
| For two (18 kinds) | 2.3 rounds, 0.1%, a reboot a machine in 14% | 2.0 rounds, 0.1%, 15% | won 95%, 6.3 rounds, 7.5% (three tenths of the machine's own), 1.5 reboots |

A pack for two at 16 hit points read the same at its rating and, met by one machine, won 73%
at most of that machine's hull: that is the fight short he wants gone, so the two holds 12. A
lone flanker of today (the whisker cat, the roc) is 5.8 rounds and a reboot a fight on stock
dice.

**The coverage** (`tools/tide_model.py`, twelve turns, fights for free): as built a squad
spends two actions in five and loses 15 of the gate. Under the set it spends three in five
and loses 16; with four tears from the start, three in four; with twice the tide on top it is
routed. A squad that holds the gate under the set loses 397 of a gate of 200, one camped on
the rift 535: the middle no longer wins on coverage.

**The whole battle**, a direction only (the bot's player, which gathers and holds no lane, ten
seeds a domain): under the set it loses the wall in half its battles where as built it lost
its machines; its fights for one go from 3.4 a battle at 5.5 to 8.9 rounds to 7.6 a battle at
4.2 to 6.3.

## 5. A set form for each Convergence

**What the records hold.** His design is there: compositions as discrete variants placed on
the tier and the Convergence (7 November: "if composition #3 is 3 goblins and a shaman, and
#3a is 4 goblins and a shaman ... we should be able to figure out somewhat empirically where
in the tier-ramp curve that should sit"), and "a boss' tiered and ramped stats and escorts
should be split into seperate fixed entries, same as a pack's would." The gate that deals a
variant at its Convergences was built that day and still runs. The formation pass then wrote
the variants and pruned the thinner of each pair on a read from before the reboot, and the
bosses' entries waited on "Don't curate the bosses now, that can wait". So today 26 of 119
compositions carry a gate, no leader's numbers move inside a tier, and from a tier's first
battle to its last the only thing that grows is the opening's count.

**How big the spike is** (the anchor, tier one's second battle, every squad of the six
certain tier ones; a battle's caches hold five to eight components against about fifteen
weapon slots, so two finds a die is a squad one or two battles in):

| The squad | A formation | An elite | A boss |
|---|---|---|---|
| Stock, basics | 8.0% of a four's hull, 6.1 rounds | 21.5%, 7.8 rounds | 27.0%, 10.6 rounds |
| Two of today's finds a die | 5.5%, 5.2 rounds | 13.7%, 5.6 rounds | 16.9%, 7.1 rounds |
| The same squad, the leaders' hit points half again | | 23.0%, 8.0 rounds | 26.7%, 10.5 rounds |

A third off every leader's price in two battles, from guns alone. Two slopes make the curve
inside a tier: the kit's growth, which the tier-one bench flattens
(`docs/briefs/numbers_pass.md`, section 6), and the foes' steps, which are nothing today.
They are sized together or the game is tuned twice.

**The form**, each a fixed entry by tier and Convergence, written and never multiplied:
fodder, what a pack holds at each (his goblins and a mandragora); a hunting pack, its heads;
an elite and a boss, a block of hit points, blows and plate with the retinue or escort beside
it (`docs/formation_proposal.md`, section 6, has the block's shape); the tide, its tears and
its beat (the ramp's table). A form holds from its Convergence until the next is written and
a tier's last holds to the end, so an old front fought late is never easier than it was.
LEADERS and the stand-in's mixed packs are dials for the feel, never the form.

## 6. How it fits together

- **Who the fodder threatens**: the wall, by count. Each pack strikes for its pips every turn
  it stands there, half what it struck, and there are about twice as many, across the whole
  width. No single pack is worth a squad; the sum of those left standing is.
- **What answers it**: one machine a pack for one, in one action and under one gauge. A pack
  for two is two machines' quick work or one machine's slow one, at a price in hull.
- **Why the middle stops winning**: the pips arrive across twenty columns from four or more
  mouths, so a squad that stands together answers a quarter of them, and nothing it meets
  alone on a flank costs it a reboot.
- **Why a machine alone is no longer fighting short**: the reboot is where a lone machine
  died, bare for a turn before a whole pack. At 8 hit points the fight is over before the
  gauge is.
- **What the meter pays an action**, in pips, a pack met at its rating:

  | The pack bonus | A pack for one | A pack for two | A formation of three |
  |---|---|---|---|
  | None | 1.0 | 1.0 | 1.0 |
  | +¼ | 1.25 | 1.13 | 1.08 |
  | +½ | 1.5 | 1.25 | 1.17 |
  | +1 | 2.0 | 1.5 | 1.33 |

  The game's own pay is level by the pip already (11 November), so the bonus tilts it toward
  the pack for one; the pack for two is the quicker and safer action. Both farm, as he asked.
- **Where the hard fights are**: the hunters, the elites and the boss, as built. The fodder's
  forms inside a tier change what a pack holds and never its size, since the tier's finds are
  tricks and never bigger numbers; the leaders carry the scaling (LEADERS).

## 7. Holes, each with what would settle it

1. **The stand-in is no content.** Its packs are a rule's draws, legible but nobody's design:
   a pair of goblins, a goblin before a mandragora, a lone gel. Settles it: his play, then the
   fodder written by domain with a set form a Convergence (section 5; question 1).
2. **The massive foes have no place.** A treant, a sandworm, a barrow giant and a magma
   elemental sit the stand-in out. Settles it: his word on where they go (question 2).
3. **The Waste's line hits hard.** Two needlers cost a lone stock machine a fifth of its hull,
   three met alone two thirds. A number for the numbers pass, with the Waste's kit.
4. **The wall under a player who cannot hold lanes.** The bot's player loses it. His play says
   whether five a pip is right for a player who can; three is the next notch down.
5. **The hunters.** As built they pull a machine off its lane, which he doubts is the role
   (section 1). Tabled on his word.
6. **The elite.** Still walks from the rift and can be led. His purpose for it is written;
   its arrival is not (question 4).
7. **The first battle's three machines.** The same tide against a trio; his sizing.
8. **The runner.** Its player gathers, so its reads of this are a floor until it is rewritten
   to hold lanes and choose what to let through.
9. **The battle's length.** About twice the fights at two thirds the rounds each by the bot;
   his play, timed.

## 8. Questions for Ryan

1. The fodder as content: do you write each domain's packs and their forms by Convergence, or
   mark a table the session drafts from what the stand-in deals?
2. The massive foes: a pack for three kept for a squad that gathers, a hunter's or an elite's
   retinue, or something else?
3. After your play: the values that land (STRIKE, PACK BONUS, START TEARS, PACE, FIELD DEPTH
   with OPENING), each cut from the page as it does.
4. The elite's arrival, so it cannot be led: the lean of the first cut was through a tear
   torn open beside the machine that tipped the Fracture, its fight opening your turn after
   next with every machine inside a ring of it. Yours to keep, change or drop.
5. The hunters' role, when you are ready to take it up.

## 9. Bench: ideas set aside, one line each, for him to overrule

- A formation as an authored wave of packs through neighbouring tears, shown a beat ahead: he
  refused it ("that will reduce variability").
- The rift sending no fodder, a front of tears alone: he asked for more tears or more of the
  rift's sends, or both; the trial keeps both mouths.
- The tide sending before the packs walk: his own, retired as a bandaid.
- The fodder's blows scaled down by a dial: the size already makes a pack safe at its rating,
  and the blows are content's numbers, the numbers pass's to move.
- A fodder fight won in its first round giving the machine its action back: it steps on the
  Dingo's second action.
- A fodder pack answered at twice its rating falling on the map with no fight: the skirmish is
  where the depth lives.
- The elite hunting whatever machine is closest, read again each turn: it can be handed about
  and led, which he refused.
- A leader's numbers by a multiplier a Convergence as the game's rule: his form is the fixed
  entry; LEADERS is a dial for the feel alone.

## 10. If he says go: the order

1. His play of the set and his answers to section 8.
2. Each value that settles landed in the engine or the ramp's table and its dial cut.
3. The Meadow's fodder in chat, a row a pack and a row a form by Convergence, then content;
   then a domain at a time. The stand-in leaves with the last.
4. The leaders' blocks by tier and Convergence as a table for his marks, tier one first, read
   with the tier-one bench.
5. The elite's arrival and the hunters' role, each its own session.
6. The runner's player rewritten for lanes, then the hull budget's shares read again.

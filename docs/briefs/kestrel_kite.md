# The Kite: from the ground up

<!-- hangar: {"kind": "chassis", "maker": "kestrel", "tier": null, "status": "proposal", "slot": false, "name": "Kite", "built": "kite"} -->

**Ryan's direction (11 November)**: "I want to revisit the Kite a bit. Something about it feels
clunky to me." Then, on Claude's read of where the clunk is: "If we were to redesign the kite from
the ground up, ignoring target tier and previous assumptions about what it should do or how it
should do it, what would you propose? Given our new battle framework, I want to settle the
identities of the Kestrel fast flyers. Not pigeonholes, but just what does what and why you'd want
one over the other." And of its sibling: "I feel like the "cousin" angle between kite and Buzzard
can be dropped since they no longer share names."

Kestrel's tier-two light flyer, built and dealt (the bible's Kite row, his go of 21 October: "a
flying accident that kills to stay alive"; its first brief, `git show
95d4ed3:docs/briefs/kestrel_kite.md`). Today: a d3 of the locked Pinion Driver and two hardpoints,
hull 12, shield 16 at a regen of 1, heat maximum 10, cooling 2, move 6. Its passive doubles every
weapon, runs every weapon and equipment it aims at a foe 2 hotter and dark through the next
round, and adds a point of heat a shot for the fight for each attack that killed (Hot Streak); the
Driver's kill brings back what the cooldowns darkened and it acts again. Where the three fast
flyers stand beside each other is the hub's (`kestrel_line.md`, The fast flyers); this brief is
the Kite's. It stays dealt as built until a go.

## Where the clunk is (Claude's read, 11 November)

Read from its row, its first brief, the rules and a probe of its fights (`docs/measurements.md`,
11 November, the Kite's turns: a direction).

1. **His sketch of 19 October never got its last step.** "Flies in, kills a couple things, gets
   out when it gets too hot": the skirmish has no way out (the withdrawal row), so a Kite that is
   too hot stays, holding its die or burning its own hull, the overheat passing its shield. Its
   own heat takes about as much of its hull as the foes do. The row's title has no mechanism
   either: a kill pays it tempo and makes every later shot hotter. The cover the design leaned on
   is gone for now (the Puffin is back in design; the starting three carry no Barrier, and the
   Baboon, as a fourth, carries one). Where it works is the short fight: alone it kills a
   tier-two duelist in two rounds with no hull lost.
2. **Its brakes overlap.** The cooldown was his first answer to cold guns under the double; the
   flat heat came the same day and answers that alone (one stockable gun is at no heat today and
   ten at 1, so the flat heat still earns its place). The tax and the gauge both cap the chain.
   The reset mostly exists to undo the cooldown.
3. **The dark entries are a chore.** The entry it spent is dark next round, so from round two its
   die opens dark about one round in three, and the fix is a team reroll with the other dice
   locked or spent first. The payoff is small: a d3 holds one entry dark from the round before,
   and the reset fires under once a fight.
4. Small: the act-again is a coin flip between its two other guns, and on the rank and file the
   Driver's second strike lands on nothing.

## The proposal: the one machine a fight cannot hold (Claude's, for him to move)

Its heat is its time on target. Every number is a placeholder and today's stand until its
session.

- **The passive** (Disabled Weapon Regulators, the name his to keep or move): every weapon it
  fires hits at double its printed number and runs 2 hotter; and the Kite never overheats: a turn
  it ends at its heat maximum, it breaks off, leaving the fight as that round ends.
- **The lock, the Pinion Driver**: it reaches any foe (Indirect: Kestrel's reach has lived on its
  locked pieces since the line review), two strikes as he has it, cold; if its spend kills, the
  Kite acts again.
- **Gone**: the dark rounds, Hot Streak and what the reset brought back. The die never goes dark.
- **What breaking off is**: the Kite is out of the fight, unharmed by its heat, its action spent,
  standing where it stood. Machines still in the fight go on without it. A fight the last machine
  has left ends as a fight lost does for the pack: its dead stay dead and counted (the Rupture
  meter, the salvage, its strike at the wall by the heads still standing), its survivors return
  whole. So what a pass does not kill, it did not hurt.
- **No control**: it leaves when the gauge says so (the bible's no extra controls row). The
  player steers it with the die: fire hot to go, fire cold or hold to stay.

**The round as played**, today's numbers. The Driver doubled is 4 and 4 for 2 heat, the rifle 10
for 6, the autoguns 4 for 3, on a gauge of 10 with cooling 2.

- A duel (a Sabre Cat, 13): the rifle, its claw on the shield, then any entry kills. A fight
  won in two rounds, as today.
- A hunting pack (four Wargs, 4 each): the Driver kills one, it acts again and kills another;
  two bite its shield; the same again and the fight is won.
- A pass on a formation (the tier-one horde: four Goblins in front, four Mandragoras behind,
  whose screams drain the rerolls): alone it holds both rerolls, so the Driver shows five rounds
  in six. The Driver on a screamer, it acts again, a gun on a goblin; six foes answer. A second
  round the same fills the gauge three times in four (the free roll's coin) and it is gone as
  the round ends: four of eight dead, two rounds of blows taken, the second from four foes.
  Every kill in a pass is a blow it does not take on the way out, which is "kills to stay
  alive" as arithmetic.
- In the squad's fight it is two or three doubled shots and gone, or the cold Driver every round
  for as long as it likes (2 heat against a cooling of 2).

**What it is for.** The priority target, as its codex has said since before any of this ("designed
to eliminate priority targets and disengage before getting overwhelmed"): the long wall's packs
are compositions with a back rank that works behind a front that holds, a lead, a howler, a
captain, and the Kite removes that head anywhere on the wall, a turn before the squad meets the
pack or instead of it. It thins a pusher the squad cannot reach in time, takes any small fight it
can finish on one gauge, and is the squad's way out of a fight for exactly one machine.

**What it is bad at.** Anything worth more than one gauge: a massive foe, an elite, a boss, a
formation's whole body. It cannot hold ground (what it leaves walks on) and it cannot grind (what
it wounds heals). The Buzzard is the burst that stays; the Kite is the pass.

**What it wants in its kit.** One or two decisive guns: a hot gun is one pass and out, cold guns
are a longer stay and more, smaller kills, and the choice is what the target needs. Heat
maximum and cooling modules are time on target. The Puffin's direction (it moves heat) keeps it on
target or throws it out of a fight a round early; a foe that scorches it (Cerberus's maul) hurries
it out of a duel, its bad matchup.

**Where it falls out.** One rule bent (a fight left), so tier two by the sort; it shows whole with
basics.

## Holes raised

- **It bends a Decided row** ("There is no withdrawal: a fight ends in the pack's fall or the
  machines' wreck", his simplification of 6 November). The passive row allows a one-off, and the
  form that failed was every machine's, at any point, by a button, "a tactical option not worth
  the rules it took"; this is one machine's, automatic and paid in its own gauge. His to weigh.
- **Farming** went with the withdrawal, and a machine that leaves could bring it back: the shield
  is full as every fight opens, so a pass whose blows stay inside its shield costs nothing.
  Three brakes: a pass is its whole action for the turn; only kills count; and the frame, its
  shield sized to a patrol's round, so that a formation's round reaches the paper hull, which
  nothing mends on the map. At today's 16 a tier-one formation's round mostly stays inside the
  shield, so that number moves with this: the lever, and what a first measurement reads.
- **When it leaves.** As the round ends, after the foes have acted, is the lean: every pass takes
  at least one round of blows. Leaving as its own turn ends, before they act, is the hotter form:
  a gauge filled in one turn is a pass nothing answers.
- **The boss's fight** takes every machine; a Kite that leaves it has left the others to win or
  be scrapped, and stands on the map after. No exception written; whether that reads right is
  his.
- **A hunter's catch** is fought to its end by the rule; a caught Kite that breaks off is caught
  again next turn while the hunter stands beside it. A pass a turn until one of them is gone.
- **The squad pays for its exit**: it leaves three machines to finish a fight for four. Its
  choice is the cold Driver and staying, which is its sustain and small.
- **A heal undone**: packs keeping their damage between fights was moot with no withdrawal (the
  pack row). It stays moot if survivors return whole, as after a wreck.
- **Cost to come**: a fight ending no rule has (left, the pack standing and the machine too), in
  the fight, the battle, both bots and the screens; the Kite's own valuation of a pass.

## Bench, one line each with what set it aside

- Leaving on a button, when the player says: the no extra controls row (11 November).
- A round out of the fight in place of leaving (it climbs, cannot act or be struck, comes back
  cold): the fight stays closed and no rule bends, but alone its off rounds are dead air, Phased
  is a buff the pool already holds, and Phased on a kill is his idea for the shadow panther (the
  Zoids walker, 6 November).
- **A kill costs no heat** (every weapon doubled and 2 hotter; a spend that kills pays none): the
  Kite if the exit is refused. Today's niche with one brake where there are three, cold through
  the rank and file and hot against what survives a shot; no last step to the sketch.
- A shield on a kill (the row's old lever): one more rule, and the shield already opens full.
- A quarry (one foe marked, doubled against it alone, gone when it falls): a second marker beside
  the Needletail, and a rule to learn before the first shot.
- The first weapon of each fight doubled: thin, chooses no piece (the test the interceptor's
  first kit failed, 20 October).
- Another action on the map for a fight won alone: the Dingo's two actions.

## Open, his

1. Does one machine get to leave a fight?
2. If so: after the foes have acted (the lean), or before.
3. If not: the bench's "a kill costs no heat", or another shape.

## What the session hands back

On his go: the passive and the Driver in content, the break-off in the engine with its tests, the
rules' withdrawal line and the bible's Kite and withdrawal rows, its numbers read by the runner
after the heat pass (its shield against a patrol's round and a formation's first), the vocabulary
(Reset, Hot Streak, Cooldown's passive grant), its text slots in the hangar, this brief retired.

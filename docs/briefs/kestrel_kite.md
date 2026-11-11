# The Kite: from the ground up

<!-- hangar: {"kind": "chassis", "maker": "kestrel", "tier": null, "status": "proposal", "slot": false, "name": "Kite", "built": "kite"} -->

**Ryan's direction (11 November)**: "I want to revisit the Kite a bit. Something about it feels
clunky to me." Then, on Claude's read of where the clunk is: "If we were to redesign the kite from
the ground up, ignoring target tier and previous assumptions about what it should do or how it
should do it, what would you propose? Given our new battle framework, I want to settle the
identities of the Kestrel fast flyers. Not pigeonholes, but just what does what and why you'd want
one over the other." And of its sibling: "I feel like the "cousin" angle between kite and Buzzard
can be dropped since they no longer share names."

**His call on the first round (11 November)**, a Kite that leaves a fight at its heat maximum: "The
kite could flee only if not in a boss or elite fight. In order for that withdrawal to work, it
would need to be impossible to overheat in one round. That said, I don't like it only because it
adds clunk to the battle. We ditched withdrawal and the game feels better for it. Forced withdrawal
probably feels bad." Declined: the fight stays closed (the bible's withdrawal row carries it), and
the second round below is built inside it.

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

The root under all four (Claude's, the second round): every brake it carries is there to price
one thing, a double on every shot at every foe for a whole fight. Four effects over a cap of three
is the row's one-off, and a one-off for balance is a symptom (his rule of 18 October). Price the
double by what it is aimed at and the brakes have nothing left to do.

## The second round: the opener (Claude's lean, for him to move)

First strike: the Kite kills what nothing has touched yet. Every number is a placeholder and
today's stand until its session.

- **The passive** (the name his): every weapon it fires hits an unhurt foe at double its printed
  number. Unhurt is at its full HP as the die is spent; the buffs once after, as the blow's order
  has it, each foe struck read for itself.
- **The lock, the Pinion Driver**, as built: two strikes, cold; if its spend kills, the Kite acts
  again.
- **Gone**: the flat heat, the dark rounds, Hot Streak, and what the reset brought back. Its heat
  is a light machine's, and its die never goes dark.

Each foe pays the double once, so no cold gun is a free lunch and nothing needs a brake: a boss
takes one doubled shot and then a light flyer's guns, a pack takes one each.

**The round as played**, today's stock (the Driver 2 and 2 cold, the rifle 5 for 4 heat, the
autoguns 2 for 1).

- A duelist (a Sabre Cat, 13): the rifle's 10 from full, then anything finishes it. Two rounds,
  as today; a bigger gun is one shot.
- A hunting pack (four Wargs, 4 each): the Driver kills one, it acts again and kills another;
  two rounds, at a heat it can carry.
- A massive foe (a Treant, 32, regrowing): one doubled shot, then guns that do not outrun the
  regrowth. Not its fight.
- With the squad it shoots first. What it kills never acts; what the others have chipped it only
  finishes. Each round it takes whatever is still untouched, and the Driver's kill chains it on.

**What it is for.** The first shot of any fight and the whole of a small one: a duel that ends as
it starts, the head of a pack gone before the pack has moved, an elite's own taken off it one a
round. The priority target its codex names, by being first to it.

**What it is bad at.** Anything already hurt, anything big after its first shot, and a long
fight. The Buzzard is the reverse, a machine that builds and then commits.

**What it wants in its kit.** One big single hit above all (the Railgun's 10 is 20 on anything
untouched, and its heat is then the round's whole budget, so the hold becomes its decision); reach
for the untouched back rank; a setter before it (an unhurt Shocked foe takes four times, the
interaction today's double already has). The Coriolis Accelerator in a hardpoint gives it both
ends, the opening and the finish.

**Where it falls out.** One rule, whole on basics (a doubled basic kills the rank and file a plain
one only wounds), so tier one by the sort, which would refill Kestrel's tier-one deal once the
Puffin moves to two. Its tier is his.

**The build.** Small: a condition on the target (unhurt) beside the ones the engine reads already
(a debuff on it, its rank, no intent on this machine), the passive's other effects dropped, the bot
taught to spend it first. A what-if on a scratch tree can give a direction before any go.

## The smaller step: a kill costs no heat

If the opener is too far from the machine he has: keep the double on every shot and the flat 2,
and a spend that kills pays no heat at all; the Driver as built. It stays the over-tuned, hot
machine: every shot is a bet that it kills, free through whatever dies to one shot and dear
against whatever survives, the overheat on a paper hull its accident. It pairs the other way
round: the squad wounds, the Kite takes the kill for nothing and chains. One brake where there are
three, and the blanket double still wants that one.

## Holes raised (the opener)

- **Area**: a doubled area gun on an untouched formation is a round-one sweep at double (the
  Howitzer's Splash, the Airburst's Spread). The lever: the double on the foe aimed at alone.
- **The squad's own area takes its targets.** After the first round little is untouched where a
  Clydesdale has been firing, so with the squad it is a first-round machine and a finisher after.
  Order as a decision, or an annoyance: his play.
- **Nothing in it is Kestrel's heat or its risk** but the frame, the paper hull under a big
  shield. The smaller step keeps both.
- **"Kills to stay alive"** is arithmetic and no rule: what it kills does not strike. A shield
  on a kill is still on the bench if the title's promise wants a mechanism.
- **A foe that heals to full** is untouched again (a cure, a regrowth that tops it up): a gift
  against healers, and a thing to check against a part that grows back.
- **The Driver's reach**: an untouched worker stands behind a front. Indirect on the lock would
  make the Kite the back rank's answer by itself; without it that is the Needletail's paint or a
  hole in the front. Free reach has been set aside twice (below), so his call.

## Declined: the one machine a fight cannot hold (the first round, 11 November)

Claude's proposal: its heat as its time on target. Every weapon doubled and 2 hotter, and at its
heat maximum the Kite broke off, leaving the fight as that round ended, its kills kept and the
pack's survivors whole; the Driver reaching any foe, a kill acting again. Its holes as raised: it
bent the withdrawal row; the shield opening full each fight made a pass that stayed inside it
free; it left the squad a machine short; and it wanted a fight ending no rule has. His call is at
this brief's head. What the form would have needed, his words: never in a boss's or an elite's
fight, and a gauge no single round can fill.

## Bench, one line each with what set it aside

- Leaving a fight, by its gauge or by a button: declined above; a button besides is the no extra
  controls row's.
- A round out of the fight in place of leaving (it climbs, cannot act or be struck, comes back
  cold): forced as the exit was, alone its off rounds are dead air, Phased is a buff the pool
  already holds, and Phased on a kill is his idea for the shadow panther (the Zoids walker, 6
  November).
- The double on a foe at half its HP or less, the finisher: the squad's Kite and no flanker,
  since alone nothing is hurt until it has spent its own shots; the Coriolis Accelerator is that
  piece, in the pool.
- The double on a foe that aims at it: the Funnel-web's condition turned round, and no decision,
  since killing what comes for it is right for two reasons at once.
- Every weapon acting again on a kill: with a double it clears a formation's small heads in a
  round, without one it only shows on guns big enough to kill, and either way it is the Skua's
  wide fight by another road.
- A shield on a kill (the row's old lever): a second idea beside the passive; kept as the lever
  it was.
- A quarry (one foe marked, doubled against it alone): a second marker beside the Needletail.
- The first weapon of each fight doubled: thin, chooses no piece (the test the interceptor's
  first kit failed, 20 October).
- Free reach on every weapon: reach is priced and the artillery makers', set aside in its first
  brief and on Wainwright & Sutler's bench.
- Another action on the map for a fight won alone: the Dingo's two actions.

## Open, his

1. The opener, the smaller step, or neither.
2. If the opener: whether the Driver reaches any foe, and whether the double is the aimed foe's
   alone.
3. A what-if on a scratch tree before any go, if he wants a direction first.

## What the session hands back

On his go: the passive in content with its engine's condition and tests, the bible's Kite row
rewritten with its exit and the rules' passive lines, the vocabulary (Hot Streak and the passive
grant of a cooldown retire with it), its numbers read by the runner (alone on the duelists and
the hunting packs, in the default three with the Kite spent first), its text slots in the
hangar, this brief retired.

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

**His refinement of the second round (11 November)**: "Kite: Burst glass cannon. I would  consider
removing the reset and giving it 4 faces again. A softer reset could be "kills recharge it's
shield completely" or something. Or if we wanted to lean completely into the guerilla aspect,
kills just straight up grant it Phased, and we make it out of paper - small hull, small shield, big
Regen. Not sure what the pinion driver becomes, but maybe it gains it's execution mechanism back so
the kite has a finisher to pair with its opener of choice." The third round, below, is his shape
with Claude's reading of it and the holes raised.

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

## The second round: the opener (Claude's; the third round keeps its passive)

First strike: the Kite kills what nothing has touched yet. Every number is a placeholder and
today's stand until its session. The round as it was proposed; his refinement, below, changes
its lock, its die and what a kill pays.

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
interaction today's double already has). The finish is its lock's since his refinement.

**Where it falls out.** One rule, whole on basics (a doubled basic kills the rank and file a plain
one only wounds), so tier one by the sort, which would refill Kestrel's tier-one deal once the
Puffin moves to two. The third round's lock and reward sort it back to two. Its tier is his.

**The build.** Small: a condition on the target (unhurt) beside the ones the engine reads already
(a debuff on it, its rank, no intent on this machine), the passive's other effects dropped, the bot
taught to spend it first. A what-if on a scratch tree can give a direction before any go.

## The third round: the burst glass cannon (his refinement, 11 November)

His shape, as Claude reads it: the opener stands as its passive (his "opener of choice" the gun
the player fits), and round it:

- **Four entries**: the lock and three hardpoints. The d3 was there to make dark entries felt,
  and none is left.
- **No reset.** The act-again goes; a kill pays it something softer.
- **The Pinion Driver the finisher again**: its old mechanism, a flat number that grows with the
  hull its target is missing, so the Kite opens with a fitted gun and finishes with its lock.
- **What a kill pays**, one of his two: its shield recharged whole; or Phased, on a frame of
  paper (a small hull, a small shield, a big regen), the guerilla.

What follows without a question (Claude's, built so unless he says):

- The opener and the finisher sit on one die without touching: the double is on the printed
  number and a foe's missing hull is added after it, undoubled (the blow's order). On an unhurt
  foe the Driver is a doubled base with nothing to add; on a hurt one, its growth and no double.
- With the reset gone no piece carries Reset, and the verb his note of 6 November called the
  Kite's ("the rapid on kill is now kind of the Kites thing") is free for the Zoids walker again.
- A fourth entry is a third pin on its model and a third piece in its stock, his to name.
- A lock with a rule and a kill's reward sort it back to tier two.

### Holes raised on it (Claude's)

1. **Every kill paying is the danger he named on 19 October** ("kills-grant-invulnerability and
   really go full assassin, but there's danger there"; the first brief's bench, "immune while
   farming trash"), and the opener feeds it: the rank and file stay unhurt until the Kite shoots
   them, so against them a kill a round is the ordinary case.
   - The shield, whole, at today's 16: a kill a round refills about what a tier-one formation's
     round takes off it (seven of the horde's eight land about 16), and more with every head
     that falls, so alone it outlasts a pack it thins a head a round, and with the squad it is
     the machine blows are wasted on. The danger is the gauge's size: mild on a small one.
   - Phased: alone, a round it kills in is a round no foe strikes at all; with the squad every
     blow aimed at it picks an ally instead, each round it kills.
2. **Phased has one gate and this is past it.** The Phased row: "granted only to a unit that has
   not acted this round, so the status always costs the action it protects"; "the one rule gates
   every grant of it". On a kill it costs nothing the Kite was not spending anyway. A passive may
   bend a rule as its one-off; this bends the one that keeps the status priced.
3. **Phased on a kill, very squishy, is his shadow panther** (the Zoids walker's note, 6
   November). One of the two machines has it.
4. **The Coriolis Accelerator is the Driver's old mechanism**, in the pool at tier two since 21
   October. If the lock takes it back the pool holds its twin, and his rule of 10 November wants
   a lock to be something nobody else has.
5. **A third Kestrel shield** if the reward is the shield: the Buzzard's regen from its heat, the
   Storm Petrel's shield for heat gained, the Kite's for a kill.

### Claude's leans, as put to him (his answer is below)

- **The reward on the Driver's kill alone**, as the reset was. The die is then the brake (the
  lock is one entry in four, and the team's rerolls are what buy it, Kestrel's lean and a real
  price in a squad), the machine's rhythm is open, finish, vanish, and the Driver has its
  answer: the finisher whose kill pays. Either reward fits it.
- **Phased, with the paper frame**, if the panther gives it up: nothing else of Kestrel's does
  it, and it keeps the glass honest where a shield from a kill makes the machine sturdier in the
  fights it already wins. Else the shield, on a small gauge.
- **The Coriolis comes home** as the Driver and leaves the pool.

### His answer, and the kit as it stands (11 November)

"Right, I liked shadow panther. It keeps the phased orbit, not the Kite. What exactly is wrong
from a shield refill if the max shield is small?"

So Phased stays the Zoids walker's, and the Kite's kill pays its shield. Claude's answer to his
question: nothing, at a small maximum. The fault was the gauge's size alone: at 16 a refill is
worth a formation's round, at 6 or 8 it is a blow or two, which is a glass cannon's reward. With
the gauge small the gate on the Driver's kill has no work to do, and every kill is the better
decision besides: take the kill it can make for the shield, or shoot the thing that matters.
Two things stay true and neither is a fault: the refill does nothing on a kill made at full
shield, so it starts in a fight's second round, survival and never burst; and a shield module
raises the maximum, so the gauge can be built back up, which is where to look if it ever
outlasts its rating.

The kit, every number a placeholder:

- **Four entries**: the Pinion Driver and three hardpoints.
- **The passive**: every weapon it fires hits an unhurt foe at double its printed number; a kill
  recharges its shield whole.
- **The Pinion Driver**: the finisher, in a simpler form than the Coriolis Accelerator's slope
  (his word; Claude's form of it below, a double on a foe at half its hull or less).
- **The frame**: a paper hull, a small shield, and a low regen (Claude's: on a small gauge a big
  regen refills it anyway and the kill's pay is noise, so the shield should come back by
  killing).
- **Gone**: the reset, the flat heat, the dark rounds, Hot Streak.

Still open on it: the passive now holding two lines, the opener and the refill, which Claude
reads as one idea, first blood, and the one-idea row is his to read.

### The Driver beside the Coriolis (11 November)

His answer on hole 4: "I think mechanically two execute pieces can exist - is there a way to make
the pinion driver simpler but fill the same purpose, and the Accelerator then keeps the full
missing-hp damage with the difficult math?" So both stand: the Coriolis Accelerator keeps the
slope in the pool, and the Driver wants a simpler finish.

Claude's answer, for him to move: **the Pinion Driver hits a foe at half its hull or less at
double.** One condition and no arithmetic, the passive's mirror: the Kite opens at double on the
unhurt and its lock finishes at double on the half-dead. The two never meet on one blow (an
unhurt foe is not at half), so nothing stacks. It is the Coriolis's slope as one step: weak on
the fresh, strong on the wounded. A duelist the opener leaves at 3 of 13 takes the Driver's two
strikes at 4 each; a boss feels it from half down. Both conditions read the target's hull, one
small family for the engine. The simpler still, benched: double on any hurt foe, which with the
passive makes the Driver doubled always on the Kite, a strong gun and no finisher.

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
- **Reach**: an untouched worker stands behind a front. Since his refinement the opener is a
  fitted gun, so its reach is the player's pick (an Indirect gun in a hardpoint), the
  Needletail's paint or a hole in the front; the lock, a finisher, asks for none.

## Declined: the one machine a fight cannot hold (the first round, 11 November)

Claude's proposal: its heat as its time on target. Every weapon doubled and 2 hotter, and at its
heat maximum the Kite broke off, leaving the fight as that round ended, its kills kept and the
pack's survivors whole; the Driver reaching any foe, a kill acting again. Its holes as raised: it
bent the withdrawal row; the shield opening full each fight made a pass that stayed inside it
free; it left the squad a machine short; and it wanted a fight ending no rule has. His call is at
this brief's head. What the form would have needed, his words: never in a boss's or an elite's
fight, and a gauge no single round can fill.

## Bench, one line each with what set it aside

- A kill costs no heat (the second round's smaller step: the double on every shot and the flat 2
  kept, a spend that kills paying none): not taken; his refinement builds on the opener.
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

1. The Driver's simpler form: a double at half its hull or less (Claude's), or another.
2. The passive's two lines (the opener, the refill): one idea by his read, or the refill on the
   Driver.
3. The frame's numbers: how small the shield, and the regen beside it.
4. Still open from the second round: whether the double is the aimed foe's alone, and a what-if
   on a scratch tree before any go.

Answered 11 November: Phased is the shadow panther's, and the kill pays the Kite's shield, on a
small gauge; with the gauge small Claude's gate on the Driver's kill is withdrawn, so any kill of
its own pays, as he first wrote it. The Coriolis Accelerator stays in the pool with its slope, and
the Driver takes a simpler form beside it.

## What the session hands back

On his go: the passive, the Driver and the kill's reward in content with the engine's condition
and tests, its fourth entry (the stock's third piece his, the model's third pin), the bible's
Kite row rewritten with its exit, the Phased row if it bends, the rules' passive lines, the
vocabulary (Reset, Hot Streak and the passive grant of a cooldown retire with it), the Coriolis
Accelerator's fate in the pool, its numbers read by the runner (alone on the duelists and the
hunting packs, in the default three with the Kite spent first), its text slots in the hangar,
this brief retired.

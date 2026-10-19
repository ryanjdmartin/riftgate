# Brief: the Prairie Dog's fight half (rework)

The session gives the Prairie Dog a die that can finish the small pack its map rule lets it
choose, without a second idea on its passive.

**Status**: in session (19 October): Claude's proposal below, in chat, Ryan's calls pending. **Maker**:
Wainwright & Sutler. **Tier**: one. **Read first**: `docs/briefs/README.md`;
`docs/roster_analysis.md` section 2 (the Prairie Dog's rating); the bible's rows on the cars
(section 7), on a map action that buys a fight buff (section 2), and on the four machines
moving as one (section 4); `content/chassis.json` (prairie_dog) and `content/components.json`
(flakshot_repeater).

## Where it stands

A light wheeled scout: no hunter ever picks it as its prey (the passive), and its locked
Flakshot Repeater is a small Rapid gun. The bible: the cars trade strengths (never hunted
against two actions); a decoy that every hunter picks was its original passive and stays out;
the cars' map rules are detachment tools on dice that cannot detach (the runner: it loses to
half the small packs alone, a diagnostic).

## The analysis's lean (14 October)

Keep the map rule. Give it the fight's half on the locked Repeater rather than the passive: a
rule on the gun that reads being alone (no ally in the fight), a state nothing reads, the
mirror of the Tactical Databank's "with an ally in the fight", so its round of shoot, roll
again, shoot, leave holds only when it has chosen to be there. Rapid stays small; the rule is a
locked piece's and costs the passive nothing.

## Since then

Cooldowns are decided as a printed property, and Rapid reads as "act again" with a cooldown of
one.

## The runner's read (13 October's report, `docs/balance.md`, 200 seeds)

Alone it takes every pack of two (the Mandragoras, the Cockatrices, the Drakes at 72 greedy)
and the Wolves and the Ghosts at three, and loses every pack of four or more (greedy 14
against the Gels, 32 the Needlers, 20 the Bombs, 0 the Goblins and the Revenants) and the
Salamanders (0, their heat), the Treant and every boss and formation. The fights it wins it
wins whole (84 to 100% hull left); the ones it loses it loses whole. In the maker's trio it
costs nothing and adds little; its spends are the Shells 29%, the Deflector 25%, the Autoguns
25%, the Repeater 18%. The one detachment identity in the roster is the Badger's (any small
pack alone for a tenth of its hull); section 4's row wants one among the fast machines.

## Claude's proposal (19 October)

- **The brief's first question.** Reading "alone" passes the section 2 test. That row strikes
  conditions the player meets anyway (moving, standing still, joining a fight, being caught):
  a boost switched on for free. Alone is not free: it costs the three dice that are not in the
  fight, and section 4 already prices a detachment with time. It is the first fight rule that
  reads the map's one real decision, and the one the passive makes safe to take.
- **The rule**, on the Flakshot Repeater as the analysis leaned, as the locked piece's own
  passive: "Alone in a fight, the Repeater sprays: Spread." Spread rather than a number
  because it bites exactly where the row fails (a pack of four or more fills the front rank's
  columns, so a spray takes the target and both neighbours), does nothing against a pack of
  two it already beats or a boss it should not take, and it is the flak fantasy (a scattergun
  on a pintle). Rapid stays as it is, switch-off and all; 5 to 15 at heat 0 stays. The rule
  rides the locked piece (rule 5: the identity shows with basics alone) and costs the passive
  nothing (one idea per passive).
- **Engine**, built at the go rather than planned: a `grant_keyword` effect with a new
  condition, the mirror of `ally_present` (the skirmish already counts live allies and
  refreshes the count at every death), a few lines and a test; the die shows the Spread chip
  only while it holds, the built shown-rule machinery; the bot already values Spread, so the
  runner's solo row reads the fight half the same day (one row, 200 seeds, minutes).
- **The decision it makes**: send the car alone at the flank pack while the four take the
  body, or keep it in the four as a d4 with a small gun. The team rows do not move; the solo
  row should: the second detachment identity beside the Badger.
- **Ceilings.** Alone against a formation the back rank shoots it dead, as it should (a spray
  reaches one rank). A boss alone takes 5 to 15 a shot, no more than today. When the last ally
  falls mid-fight the count reaches zero and the gun sprays: a last stand, the price already
  paid. Allies cannot help from outside a fight, so there is no "alone" with help.
- **Names** for the Repeater's rule (Ryan's to pick; Claude's candidates): Open Choke (the
  bore that widens a shotgun's pattern; lean), Flak Pattern, Lone Gun, Free Fire.
- **Stock**: the stock pass's call stands (the basic shield in place of the Deflector); the
  Incendiary Shells stay, since a spray that burns a rank is its best first fight.

## Holes

- The bot never detaches, so the campaign runner cannot show the map decision; only the
  balance runner's solo row shows the fight half, which is the measure the design wants.
- Budget rule 4 (two routes in and two payoffs from other makers' pieces) cannot be met by a
  rule that reads alone; the analysis named the hole for every map passive, and its answer
  applies: the Prairie Dog is the roster's declared detachment piece and says so.
- If the solo row turns every small pack into a free win (the Badger's tenth of its hull or
  better everywhere), the spray is too much and the bench's number form is the fallback.

## Bench

- Roll its maximum alone (the analysis's shape, 14 October; the Tactical Databank's mirror): a
  number with no new read; kept as the fallback if Spread proves too strong.
- The Repeater as a three-strike flak gun outright: a chase piece for Vitriol and Burn that
  nobody can slot, and it changes the team fight too, which the alone rule leaves alone.
- Hit and run (a withdrawal after its round, the pack left burning): Ryan's harasser fantasy
  as written; benched because a pack keeps only its survivor count between fights (damage
  short of a kill is lost), statuses carried between fights are parked (section 7) and the
  round stays move, then fight (section 4's pinned row).
- Rapid without the switch-off alone: a free chain (the Rapid row).
- A second clause on Track-Dispersing Tyres: one idea per passive.
- The disorder keyword on the Repeater: dropped 8 October (it pays in team fights, which an
  elusive car rarely joins).
- The old slip-out (the Static-screen Projector): retired 8 October, the guaranteed enemy turn.

## Open for the session

1. Whether Spread alone is the shape (or the bench's number), and the rule's name.
2. The go: the Repeater's passive built with the `alone` condition and its test, the bible's
   row, the rules' passive-condition line, the solo row rerun at 200 seeds into
   `docs/measurements.md`, this brief retired.

## What the session hands back

A proposal in chat; on Ryan's go, the rule built in content and the engine, the solo row
re-read, and this brief retired.

# Brief: the Sparrowhawk at tier two (rework)

The session reworks the Sparrowhawk from a tier-one glass cannon into a tier-two flying
accident that scores kills to stay alive, and prices its double so cool hard-hitting guns stop
being a free lunch on it.

**Status**: direction (Ryan, 18 and 19 October). **Maker**: Kestrel. **Tier**: two, from one.
**Read first**: `docs/briefs/README.md`; the bible's Sparrowhawk rows and its tiers row
(section 7 and 10), the cooldown row (section 8); `content/chassis.json` (sparrowhawk) and
`content/components.json` (pinion_driver); the Sparrowhawk's rows in `docs/balance.md`.

## What Ryan said

- 18 October: "I feel like the Sparrow should be more risky and moved to tier 2. Not sure,
  but that's how I interpret the data."
- 19 October: "If the sparrow is tier 2, and the whole gimmick is that its a flying accident
  waiting to happen, scoring kills by the seat of its pants in order to stay alive, then we
  could push that pretty far and not just double-damage-double-heat, which by todays
  standards feels thin and abusable (it was the first completed design, after all). Kills
  scoring shield is an option, letting it go above the shield cap (decaying per turn), with a
  hull as thin as paper - that's one way to go about it. Can also go as far as
  kills-grant-invulnerability and really go full assassin, but there's danger there. What's
  the actual niche it could fill, given the latest decisions made about how skirmishes play
  out on the battlefield?"
- 19 October, later: "What stops that sparrow spec from abusing hard hitting cool weapons like
  the current one? What if everything was doubled, but had a cooldown?"

## The data (13 October, `docs/balance.md`, 200 seeds)

Alone and greedy it wins 85 percent against the packs and 90 against the four big foes, the
best of the tier ones (a mean of 68 over every pack, second to the Armadillo's 70), and 0
against every formation with all its hull lost. A glass that is not glass enough alone.

## The session

- Claude, 18 October: the tiers row allows the move (a lower floor and a higher ceiling, never
  more power). The risk where its identity lives: everything doubled, the blows that reach its
  hull too, its shield absorbing as normal, so bare it dies to anything and the Barrier and the
  Puffin's overshield become its escorts; alternatives, its shield halved or an overheat
  burning double. The knock-on: the tender needs a built Kestrel tier one before it moves, so
  the strafer lands first, and the Kestrel team row re-reads.
- Claude, 19 October, the niche: the caster-killer. The decisions that frame it: the roster
  fights as a body at one front; formations spawn with a front and a back; elites surface
  from the wait; the boss is fought with its formation; five to ten skirmishes that matter,
  then the boss. In those fights the back rank's specials are what the body cannot stop (a
  scorch on every machine, a countdown on every machine, a summon, a raise), and nothing
  kills a caster before it acts except a hole in the front or the artillery makers' pieces.
  The assassin's job is that kill, and the kill is what keeps it alive. The shape: the Pinion
  Driver reaches any foe (the finisher is the dive, so the team's artillery, Penetrate and
  Vitriol hurt the caster and the Sparrowhawk finishes it; the reach lives on the lock); the
  double counts only what is printed on the entry, number and heat, buffs once (the mirror of
  the strafer's halving); a kill shields it 30 past its maximum, fading 15 a round (a slower
  fade than Overshield's, a one-off on this chassis); hull 30, shield 60, recharge 30. Alone it
  loses formations and bosses, the floor; in a team it is the Puffin's and the Barrier's
  machine. A new runner read: casters killed before their first special.
- Claude, 19 October, the cool guns. What stops the abuse today: nothing. The double counts
  the printed heat, so a weapon of no heat doubles for free: the Howitzer's 10 to 25 becomes
  20 to 50 Indirect at 0 heat every round (a mean of 35), the Twin Autoguns 10 to 30 free, the
  Slugthrower 30 to 60 for 20. The analysis read the pull of cold kinetics as a feature; at
  tier one with basics it was tolerable, and with Minerva's and Wainwright & Sutler's guns it
  is the free lunch. The printed-only double fixes the buffs (Overcharged 5 a stack, not 10),
  not the cold guns. Ryan's cooldown does: everything doubled, and a weapon it fires goes dark
  for two rounds. The price moves from heat to the die's reliability, which the cooldown row
  calls dear on a small die, and the Sparrowhawk's d4 is the smallest. On a d4: round one
  fires A; round two has three live entries of four; round three two, a dead roll one in two;
  round four A returns. It fires about two rounds in three from the third round on, never the
  same cold gun two rounds running, and the team's rerolls fix its dead rolls, which is
  Kestrel's reroll lean paying in (a reroll spent to keep the hawk firing is the risk and the
  reward, beside the gun platform's passes). With the kill-shield loop a dead round is a bare
  round: the accident. A cooldown of one on a d4 barely bites (never the same gun twice
  running, a dead roll one in four from round two); two is the battlecruiser's number, and the
  shapes differ (a volley of every gun there, one doubled gun rotated here). The other lever:
  10 heat added before the doubling, so a cold gun costs 20 on it and the Railgun 100, the
  overheat its accident, keeping the price in Kestrel's heat and the die reliable. Claude's
  lean: the cooldown, since it makes the hawk a reroll-eater beside the platform and the stock
  pass's heat prices raise the cold guns' price anyway.

## The design as it stands (Claude's spec on Ryan's direction, 19 October)

- **Passive.** Everything doubled: its damage, its heat and its reload, so a weapon it fires
  goes dark for two rounds; the double counts what is printed on the entry, buffs once. A
  kill shields it 30 past its maximum, fading 15 a round.
- **Lock.** The Pinion Driver, reaching any foe.
- **Numbers.** Hull 30, shield 60, field recharge 30, heat 60, cooling 0, armour 0, move 50, a
  light flyer; three hardpoints beside the lock, a d4; tier two, stocking tier-one pieces and
  basics.
- **Engine.** The cooldown property (the to-do's shield-rule line; not built), a passive that
  grants it to every weapon; the printed-only double (a multiply on the face's number before
  the pipeline's adds, the strafer's halving's mirror); the kill-shield as a status with its
  own fade; the finisher's reach as a `set_reach` on the lock.

## Open for the session

1. Ryan's call on the cooldown (two, or one) against the heat floor, and on the niche.
2. The kill-shield's numbers and fade; the hull; whether the Pinion Driver's reach is the dive.
3. When it moves: after a Kestrel tier one lands for the tender.

## Holes already raised

- Alone it now loses what it used to win (bosses alone at 90 percent), which is the floor and
  a change the runner will show as a wall; its team rows are the read.
- Every weapon Indirect was benched (free reach on a glass is the raider's loop again), and a
  Barrier a kill (the full assassin, immune while farming trash: Ryan's danger).
- The cooldown property is not built; this rework waits on it with the battlecruiser.

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Sparrowhawk rows and tiers row, the content's
tier and passive, `docs/rules.md`, and this brief retired.

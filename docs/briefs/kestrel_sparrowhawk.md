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

- Ryan, 19 October, later: "what if we made it even more polarizing, and gave it a d3? And/or
  kills refresh its cooldowns? And instead of double heat, it adds flat heat to every shot?
  Double damage, flat heat, with a thin hull we can effectively cap how much it can fire. All
  in aggro, dangerous but potentially fun: Guns go on cooldown after firing. Kills reset its
  cooldowns AND lets it act again this turn, but raises the flat heat per weapon by X,
  stacking? Shield on kill maybe, maybe not - depends on what the fantasy is. A hit-and run
  skirmisher, flies in, kills a couple things, gets out when it gets too hot or the enemy heat
  is too much? Burst, personified? Is that tunable?"
- Claude, 19 October: tunable, and the toy below says where each knob bites. The flat heat
  answers the cool-gun abuse by itself (every shot pays it, a cold gun included, and a hot
  gun pays its own on top); the d3 makes every dark entry felt and the team's rerolls its fix,
  Kestrel's reroll lean from the other side; the kill chain is the burst and the heat tax its
  rising price; the paper hull is the cap on how much it can fire, since the overheat burns
  it. The fantasy as read: the hit half is the chain, the run half is the map (a flyer at 50
  with Kestrel's field recharge detaches, kills a couple of things and flies off), and in the
  skirmish "getting out" is going dark and letting the team cover it; so no shield on kill in
  the first cut, the Puffin and the Barrier its escorts, the kill-shield the lever if it dies
  too often. Holes: one act-again a spend that kills, the tax a stack a kill, so a Spread kill
  of three is one more action and 15 more heat; Chain on it repeats the attack and then the
  passive acts again, which the runner reads; the injury rule (a quarter of its maximum hull
  reaching it rolls the die) bites at 8 on a hull of 30, so every blow that lands cracks
  something, which is the accident or a reason for 40; the Paradox counts a spend.

## A toy of the chain (19 October)

A toy of the Sparrowhawk alone, not the game's runner (cooldowns and the kill trigger are not
built): a d3 of the Pinion Driver and two cold guns, every shot paying the flat heat F plus
the fight's tax (X a kill), guns dark for the rounds shown after firing, a kill resetting
every cooldown and giving another action, heat over the maximum H burning hull one for one
at the end of the turn, cooling 10 a round, hull 30, six rounds, 6,000 fights. p is the odds a
shot kills (0.9 trash, 0.5 a mixed fight, 0 a boss). "Cautious" stops a chain when the next
shot would overheat; "reckless" fires while it kills, short of a burn that would wreck it. One
team reroll a round may fix a dead roll (the die on a dark entry), or none.

| Fight | Persona, rerolls | F, X, H, dark | Kills a fight | Shots | Hull burned | Dead rounds |
|---|---|---|---|---|---|---|
| trash | cautious, 1 | 10, 5, 40, 2 | 3.9 | 4.3 | 0 | 0.0 |
| trash | reckless, 1 | 10, 5, 40, 2 | 4.7 | 5.2 | 21 | 0.0 |
| trash | cautious, 1 | 5, 5, 60, 2 | 5.5 | 6.1 | 0 | 0.0 |
| trash | reckless, 1 | 5, 5, 60, 2 | 5.9 | 6.5 | 24 | 0.0 |
| trash | cautious, 1 | 10, 10, 40, 2 | 3.0 | 3.3 | 0 | 0.0 |
| mixed | cautious, 1 | 10, 5, 40, 2 | 2.6 | 5.3 | 0 | 0.3 |
| mixed | reckless, 1 | 10, 5, 40, 2 | 3.1 | 6.1 | 19 | 0.3 |
| mixed | cautious, 0 | 10, 5, 40, 2 | 2.4 | 4.8 | 0 | 1.2 |
| boss | either, 1 | 10, 5, 40, 2 | 0 | 5.1 | 0 | 0.9 |
| boss | either, 0 | 10, 5, 40, 2 | 0 | 4.0 | 0 | 2.0 |
| boss | either, 1 | 10, 5, 40, 1 | 0 | 6.0 | 0 | 0.0 |

The read: against trash the chain runs two to four kills a round before the heat says stop,
and the reckless pilot buys one more kill a fight for two thirds of its hull, which is the
accident; against a boss it is one doubled shot a round, two rounds in three without a
reroll, every round with one, so the team's rerolls are its boss-fight price. The knobs and
what each moves: F and H set the chain's length in a round (H over F shots, less the tax); X
sets how fast a fight's kills get dear (four kills and every shot costs 30); cooling sets the
trickle after the burst round; the dark rounds set the boss-fight floor and what the rerolls
buy back; the hull sets the size of the accident; the double and the die size the magnitude.

## The design as it stands (Claude's spec on Ryan's direction, 19 October)

- **Passive**, Ryan's sketch of 19 October written out. Every weapon it fires is doubled
  (the printed number, buffs once), adds 10 heat and goes dark for two rounds. A kill brings
  every weapon back and it acts again; each kill this fight adds 5 to the heat of its shots.
- **Lock.** The Pinion Driver, reaching any foe: the chain's opener on a hurt caster.
- **Numbers.** Hull 30, shield 40, field recharge 30, heat 40, cooling 10, armour 0, move 50,
  a light flyer; two hardpoints beside the lock, a d3; tier two, stocking tier-one pieces and
  basics (stand-ins: the Slugthrower and the Howitzer, cold hard hitters that kill trash
  doubled and pay the flat heat for it). No shield on kill in the first cut.
- **Engine.** The cooldown property (not built), granted to every weapon by the passive; a
  kill trigger (new; the Zoids walker's brief wants it too); act again on a kill through
  Rapid's path (a free roll onto another entry); the heat tax as a status on the machine, a
  stack a kill, each stack 5 heat on attack (the pipeline has it); the printed-only double (a
  multiply on the face's number before the adds, the strafer's halving's mirror); the
  finisher's reach as a `set_reach` on the lock.

## Open for the session

1. Ryan's call on the spec as it stands (his sketch written out) and its numbers: the flat
   heat, the tax, the heat maximum, the dark rounds, the hull (30 or 40 against the injury
   rule), with the toy's knobs; a shield on kill or none.
2. Whether the Pinion Driver's reach is the dive, and the niche (the caster-killer).
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

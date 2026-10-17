# Brief: the shield-spender (new chassis, direction)

The session designs a Kestrel tier one whose hits spend its own shield for more damage: a
sustained hitter with a real decision on every spend. "The shield-spender" is a working label;
the name and the look are Ryan's.

**Status**: direction (Ryan, 15 October). **Maker**: Kestrel. **Proposed tier**: one. **Read
first**: `docs/briefs/README.md`; `docs/roster_analysis.md` section 8 (Kestrel gap one, the
raider); the bible's shield rule and Kestrel rows; `content/chassis.json`
(puffin, goshawk) and `content/components.json` (backwash_ionizer, laminar_deflector).

## How it came about

- Claude, 14 October (the analysis, section 8): a raider whose weapons may fire its shield, so
  much shield for so much more damage a blow, its shield returning at the field rate out of
  fights, as Kestrel's detachment.
- Ryan, 14 October: "Your raider proposal fights with itself, a unit that spends its defenses
  to deal damage is a risky solo unit. A passive that consumes say, 5 shield on every hit to do
  5 more damage, pushing rapid and multihit weapons (which we have none of and badly need, I
  think), that feels very Kestrel. But that design isn't a detachment unit. What will happen is
  it will get into a fight, spend some shield, maybe kill a guy, and then get stuck in a loop
  where all the shield it raises gets burned before it can spend it on damage."
- Claude withdrew it from the detachment niche; the strafer took that niche.
- Ryan, 15 October: "The Kestrel shield-spender was a good design, just not for that niche. A
  sustained dps with a real gameplay decision. Not a terrible tier 1 either."

## What frames it now

- Under the honest shield rule (decided 14 October) its shield is its hit points, so every
  point spent is a real trade.
- It loops badly alone and shines beside a shielder: the Puffin's ally overshield, any maker's
  ally shield.
- Ryan's sketch pushes Rapid and multi-strike weapons, which the strafer and the stock pass
  also want.

## The session (15 October)

- Claude proposed: Ryan's sketch as the passive (every hit spends up to 5 of its shield for
  that much more damage, per hit, so Rapid and multi-strike pieces spend more for more); the
  decision in which entry is spent, the team's order (an ally's shield before it fires is
  damage, after it is protection) and the intents (what will strike it shows before the
  player acts); the shown number with the bonus in and a shield cost beside the heat;
  overshield as the intended synergy and not too free, since it fades after the enemy's turn
  and so guards that turn's blows; a locked gun of three small strikes, cool.
- Ryan, 15 October: "a really great tier one since it's very straightforward"; the trick is
  telling it from the strafer, since "both of their final results can converge easily -
  multi-hit flat damage stacking", so it "needs a hook to diversify its options away from just
  multi-hit to blast that shield". No multi-strike lock: "its completing the build and the
  unit needs nothing but that and fill the rest of its hardpoints with shields."
- Claude, 15 October, the hook: the convergence comes from "per hit" (a bonus per hit is a flat
  on-hit, which the strafer doubles), so change what scales the burn rather than add beside
  it: its weapons take their heat from its shield instead of its gauge and hit harder by as
  much, once a spend as heat is paid, so multi-hit gains nothing. Kestrel's three tier ones
  then want three kinds of weapon: the Sparrowhawk cold guns (it doubles heat), the strafer
  many hits, this one hot guns (Aphelion's and the Arsenal's hot pieces, where the Sparrowhawk
  pulls Minerva's and Wainwright & Sutler's kinetics). The decision moves onto the die with no
  gesture: a hot entry burns shield for a big hit, a cold one burns nothing. Routes in: every
  ally shield, and the Peak's Scorched (a stack makes its weapons 5 hotter: 5 more burnt, 5
  more dealt). Holes: it changes the sketch's 5 a hit; while its shield stands its gauge
  hardly moves, so vents are nearly dead on it (only Burning heats it), a direction refused;
  the stock pass's heat prices set its whole economy; a weapon hotter than the shield left
  pays the rest as heat and gains only what the shield paid. The lock: never a big hot gun,
  which would complete the build; Claude's lean, once the hook is settled, a cold gun whose
  hits regain shield, so the die always carries both halves of the decision, reload or burn.
  Bench: 5 a spend in place of 5 a hit (ends the convergence but adds no appetite); the burn
  sized by the blow (the Sparrowhawk's bargain at another price); a locked shield dump (the
  Goshawk's vents-all in shield, and the build would be the dump and shields).

- Ryan, 15 October, the second round: "the multi-hit part doesn't make sense with that
  description. Instead, 'While it has shield, consumes its own shield instead of generating
  heat. After firing a weapon, zap the target for the amount of shield consumed.' The zap would
  be wasted on a kill, but the shield still consumed, and that is correct." No gun as the lock
  ("then its just gun on gun"); instead: "Buff, self or ally, give target +X shield regen for Y
  turns (numbers tbd). Itself is probably the best target, but if it has a friend shielding it,
  then it can lend the buff to the friend instead. And its a really good reason to stop
  shooting for a turn."
- Claude, 15 October, reading it: a weapon hotter than the shield left pays what the shield
  holds and the rest as heat, the zap being what the shield paid; the zap is a blow of its own
  after the weapon's strikes, plain (no keyword, no buff added), so it loses the target's
  armour; since a kill wastes it, a hot gun wants a foe it will not finish, which makes the
  target a choice. The regen: at each round's start, as the Goshawk's, up to the maximum;
  whether a second cast stacks, as every status does, or only renews the count; and it takes
  in-fight regen past the Goshawk, whose content note calls its regen the game's first, kept
  safe on one chassis (one target at a time, so never shield in bulk).

- Ryan, 16 October: the regen was meant to wear off after a few turns, "so it could just be a
  refresh. How dangerous is stacking?" For the zap: a plain blow, one that pierces armour, a
  ping on a random foe, or a random ping that also Shocks "to set up its next hit"; "Not sure
  what opens more build options."
- Claude, 16 October: renew, never stack. Stacked, a regen recast every round grows to as many
  stacks as it lasts rounds (three rounds, three stacks), a heal that triples while it is kept
  up, lent to a tank, and doubled by a second shield-spender; renewing caps it at one regen a
  target however many cast it, and a recast early only wastes the rounds left. (First argued
  from the engine's old stacking, which pushed every stack to the newest expiry and so ramped
  without end: a bug, fixed the same day.) The zap: Shock on its own target opens the most builds,
  since it makes a state other pieces read (the Sparrowhawk's four-times blow, any big single
  blow, the Paradox meter, the Susceptibility Tensor), keeps the choice in the aim and keeps the
  waste on a kill (no zap, no Shock); to watch, its own next hot shot at that foe lands double,
  near the Sparrowhawk's bargain, and it is a second Shock setter at tier one beside the
  Dingo. Armour-piercing gives the sharpest identity (the armour-cracker, the strafer's
  opposite) and the fewest new builds. The random ping is the boiler's blast again (a random
  foe hit for the heat spent) and, beside the strafer's spray, a second random-target tier one
  in one maker.

- Ryan, 16 October, later: renewal without stacking is the right shape, "or it risks becoming a
  support"; the engine's stacking is a bug, timed stacks to decay from when they started (fixed
  in the engine the same day). Shock on the zap's target "makes no sense to me, because you've
  already chunked the guy for your weapon plus your shield", and a guaranteed Shock every round
  riding on damage "seems cheesy". The random zap is no repeat of the boiler, rewarded for a
  non-combat action, or of the strafer, a locked piece: "the only thing they have in common is
  random, their contexts are very different."
- Claude, 16 October: the zap as a random ping, any foe standing with its target among them, so
  a lone boss still takes it and a kill never wastes it: the soft area a sustained hitter
  wants, finishing stragglers wherever they stand. Plain is the zap with no hook;
  armour-piercing the sharper single-target identity.

## Open for the session

1. The zap's shape (Claude: the random ping); the regen's numbers.
2. How the die shows the burn and the zap.
3. Its numbers, size and way of moving, matched to Ryan's silhouette.

## Holes already raised

- Alone it burns its shield before it can spend it on damage (Ryan's loop), which is fine for a
  sustained hitter that fights beside a team, and a reason it is not the detachment.
- A shield spent is also an injury risked, since a blow on bare hull rolls the die; the entry
  should show the cost.
- The review (Claude, 16 October) raised Scorched inverting on it: a stack makes its weapons run
  5 hotter, under the passive 5 more shield burnt and 5 more zapped, so the Peak's scorchers
  make it a glass cannon rather than choking it. Ryan, 17 October: "flipping the shield and heat
  interactions on its head is kind of the shield-spender's whole deal": every point of heat its
  weapons would generate burns shield instead, Scorched's included.
- Its die carries hot and cold entries both, and its stock no vent (Ryan, 17 October, agreed:
  "sometimes you might actually want to not explode your whole shield"; with no weapon heat
  reaching the gauge a vent is nearly a blank, Burning alone heating it).
- The regen renews and never stacks: a stacking policy the engine lacked until 17 October
  (Ryan: "it should be supported, since that's a pretty common thing for a powerful or
  non-number-related buff to do"), now read off the status's definition (add, renew or never;
  the bible's section 5).
- The zap's ping (any foe standing, its target included), Chain's ping (Claude's lean, any other
  foe) and the strafer's spray (among the foes in reach, the same one again) are three rules for
  a random foe. Ryan, 17 October: neither the zap nor Chain is final and the spray is a locked
  unique, so the count is no worry now, "but point taken".

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Kestrel row moved from withdrawn to decided,
content planned, and this brief retired.

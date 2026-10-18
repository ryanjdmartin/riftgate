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

## The proposal for the go (Claude, 18 October)

Claude's proposal, in chat first; every number a placeholder, the name and the look Ryan's.

- **Shape.** Kestrel, tier one, a medium hovercraft on big boosters, move 40 (the 40 club):
  the one Kestrel tier one that is not a fast jet, so the tender's Kestrel deal varies on the
  map as it does on the die; a flyer if Ryan's silhouette is one. Hull 70, shield 80 (its
  shield is its gauge, so it carries the biggest one in the roster, and under the honest
  shield rule every point of it is hit points it chooses to burn), field recharge 30
  (Kestrel's), heat maximum 60, cooling 5 (idle while the shield stands, Burning aside),
  armour 0; four hardpoints beside the lock, a d5; two module slots.
- **The passive**, Ryan's words of 15 and 17 October as the codex would print them: while it
  has shield, its weapons burn shield in place of heat, every point a spend would add, a
  Scorched machine's extra included; a weapon hotter than the shield left burns what the
  shield holds and the rest reaches the gauge. After the weapon's strikes the target takes a
  zap of what the shield paid: a plain blow, no keyword, its armour off, lost on a kill.
- **The zap's shape: on the target**, Ryan's first wording and the waste on a kill he called
  correct, in place of the random ping Claude leaned to on 16 October. The reasons: the waste
  is the decision (a hot gun wants a foe it will not finish, and the drag shows whether the
  blow kills), where a ping that always lands somewhere deletes it; a ping on any foe standing
  hands a Direct gun's zap the back rank, a reach nobody paid for; against fodder a ping turns
  a hot shot into a two-kill spend, which is the strafer's ground, where the target zap keeps
  this machine the big-foe hitter that pays in shield, so Kestrel's two new tier ones part
  cleanly (trash, the big one); and it is one random-foe rule fewer beside the spray and
  Chain's rework. The zap is part of the spend: it lands after the strikes and before the
  spend's riders, so a Shock weapon's zap never spends the shock its strikes leave, as the
  strikes never do. Bench: the random ping (any foe standing, the target among them; back if
  the waste proves too harsh in play) and the armour-piercing zap (the sharpest identity, the
  fewest builds, a second armour rule to learn).
- **The lock, the regen buff**: self or ally, a full action (no Rapid: Ryan's "really good
  reason to stop shooting for a turn"), working name Regenerating, Ryan's to move: the target
  regains 10 shield at the start of each round for three rounds, up to its maximum. It renews
  and never stacks (decided 16 October): a recast sets the count back to three, and two
  casters are one regen. On itself 10 a round is a 10-heat gun fired free every round or a
  Railgun's 40 every four; lent to a tank or to the Puffin it is the game's second in-fight
  regen after the Goshawk's, one target at a time, never shield in bulk.
- **Stock**, stand-ins until the stock pass, hot and cold both and no vent (Ryan, 17
  October): the Laser Carbine (a small burn), the Overclocked Railgun (the big hot shot: 40
  shield for 50 and a zap of 40), the Twin Autoguns (cold: burns nothing, the entry to fire
  when the shield must stand), the Laminar Deflector (shield 20 with Rapid: reload and act).
- **The die.** The heat slot, bottom left, is where the burn shows: while the shield covers
  the spend the entry reads the burn there with the shield's glyph and its number (structure,
  never hue alone), and reads +N HEAT again for whatever the shield cannot pay. Since the
  burn is the zap, one number says both, and the hold's line reads "burns 10 shield, zaps the
  target for 10". Dragged over a foe the number shows what that foe takes, the blow and the
  zap with its armour off each, as two numbers joined ("10+5"), since the zap is a blow of its
  own and the rule is that the die shows one blow. Judged on the phone.
- **The arithmetic** at today's heat prices (mean a spend on the target; the pool 80):

  | Weapon | Burns and zaps | Target takes, armour 0 / 5 | Spends of a full pool | Regen refills one every |
  |---|---|---|---|---|
  | Laser Carbine 10 flat, heat 5 | 5 | 15 / 5 | 16 | half a round |
  | Slugthrower 15–30, heat 10 | 10 | 32.5 / 22.5 | 8 | a round |
  | Overclocked Railgun 50, heat 40 | 40 | 90 / 80 | 2 | four rounds |
  | Twin Autoguns 5–15, heat 0 | 0 | 10 / 5 | never | - |

  The read: with today's numbers the basics barely burn, so the identity shows with basics
  alone but small; the stock pass's heat (a hot kit overheats by its third round) is what
  sizes the decision, so its feel is read after the stock pass, like the boiler's, though its
  design waits on nothing. Multi-strike gains nothing, since heat is paid once a spend, which
  is the hook that parts it from the strafer.
- **Engine work.** A passive effect at the spend: the heat the pipeline returns is taken
  from the shield before the gauge, the zap a plain blow through the target's damage taken
  and armour after the strikes; the die's heat read (`shown_face`) becoming a burn while the
  shield stands; the regen as a status, likely cheap, since a status may carry the round-start
  shield effect the Goshawk's passive already runs and the renewing policy exists; the bot
  reading shield spent as a cost (its `shield_score` counts hull saved this round) and the
  zap as damage; each tested with synthetic passives. Its runner row lies until the honest
  shield rule is built (the to-do's shield-rule line): under today's whole-block rule a
  shield burnt to 1 still blocks a whole blow, so the burn costs nothing it should.
- **What the runner reads.** Alone (the loop: whether it burns before it spends); beside the
  Puffin (the overshield as the magazine, Kestrel's locked pieces working together); beside a
  tank (the regen lent out); the share of its spends that burn against the share that hold.

## Open for the session

1. Ryan's call on the proposal above: the zap on the target (Claude's lean since 18 October,
   the random ping benched) or the ping; the regen's numbers (10 a round for three rounds)
   and its working name; the die's reading of the burn; its numbers, size and way of moving
   (a medium hovercraft at 40, or a flyer), matched to Ryan's silhouette.

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
- The honest shield rule is decided and not built (Claude, 18 October): until it lands, a
  shield burnt down to a point still blocks a whole blow, so a runner row on this machine reads
  the old rule's free block, not the burn's price. Its engine follows the shield rule's.
- The zap on a Guarded core (a boss in parts) deals nothing, as every blow on it does; the zap
  carries no keyword, so it never spills, chains, burns or shocks, and Chain's repeat pays its
  heat again and so burns and zaps again on the new target (Claude, 18 October).

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Kestrel row moved from withdrawn to decided,
content planned, and this brief retired.

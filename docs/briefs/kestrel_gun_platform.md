# Brief: the gun platform, Kestrel's capstone (proposal)

The session designs Kestrel's second tier three beside the bomber: a giant, mean-looking,
fast-looking-but-slow gun platform whose passes are the team's rerolls. "The gun platform" is
a working label; the name and the look are Ryan's.

**Status**: proposal (Claude, 19 October), Ryan's gimmick test to pass. **Maker**: Kestrel.
**Proposed tier**: three. **Read first**: `docs/briefs/README.md` (Ryan's taste, the tiers,
Kestrel's leans as the fourth round of `kestrel_shield_spender.md` left them); the bible's rows
on rerolls (three a round, never onto the entry showing), on Rapid's limiter and on cooldowns;
`kestrel_bomber.md` (the other tier three); `docs/rules.md` on dice and the round.

## How it came about

- Ryan, 18 October: the capital ship need not be assault size, the bomber could be it; either
  way, "what would you propose for the other tier 3 Kestrel chassis?"
- Ryan, 19 October: the mode-shifter Claude proposed reads as an Aphelion tier three (an aura
  support with shifting auras; Aphelion's bench in the README). "Any other ideas for a Kestrel
  capstone or flagship? I mean, nothing says specifically that they CAN'T make a giant, mean
  looking, fast-looking-but-slow mobile gun platform, if we find the right Kestrel gimmick for
  it." And reroll-based effects are back on Kestrel's table, since Wainwright & Sutler's ten
  filled without effort: "It actually fits, and means we can push Kestrel way into the
  risk-versus-reward space, like a real maverick pilot."
- Claude, 19 October: the gimmick is the team's rerolls. Ryan: "Lay out what that reroll
  platform's kit could actually be."

## The kit (Claude, 19 October)

Every number a placeholder; the name and the look Ryan's.

- **The passive.** A team reroll rolls its die again even after it has acted, and it acts
  again. One line. Each pass pays its weapon's heat; nothing else limits it but the rerolls,
  three a round and never banked. The rules it bends: a die is spent once a round, and a
  reroll touches only unspent dice. It reads the team's rerolls, which nothing reads.
- **The throttle**, its lock: equipment on itself, Rapid with a cooldown of one, heat 20: the
  team gains a reroll this round. The maverick pushes the engines, so a pass can be bought
  with heat, and the overheat at the end of the turn is the accident.
- **The round, as played.** Roll. Spend rerolls on the team's dice if they need it. Spend the
  platform's die. Lock the others. Reroll: the platform rolls again and fires again. Repeat
  while rerolls last; the throttle, when it shows, adds one at 20 heat. End the turn, and the
  heat over the maximum burns hull.
- **The decision.** Each reroll is a pass or a fix for a teammate's die; the throttle is heat
  for a pass; each pass is a hot gun now or a cold one. Rerolls may be spent before or after
  attacking, so the order is the player's, and a reroll kept for a late fix is a pass not
  flown.
- **Frame.** Heavy or assault, hover (the ekranoplan, a giant ground-effect plane with a
  battery on its back, fast on water and slow on rough ground) or a flyer (the gunship, its
  guns down one side); move 20; hull 120, shield 80, field recharge 20, heat 120, cooling 10,
  armour 0; six hardpoints beside the throttle, a d7; two module slots.
- **Stock**, stand-ins, tier-two pieces since a tier three stocks below its tier, cold and
  hot both: the Twin Autoguns, the Howitzer, the Slugthrower, the Maxigun, the Arc Fault
  Cannon, the Laminar Deflector. Cold guns make cheap passes, which is the cross-maker pull
  (Minerva's and Wainwright & Sutler's kinetics on a Kestrel platform); the hot build is the
  accident. No vent in stock: a Rapid vent on it (the Wake Diffuser) is a pass that cools, the
  Rapid vent Ryan is wary of, and the Puffin's vent feeds it from outside.
- **The die.** After a spend its die stays live with a roll-again mark in place of the spent
  state; the REROLL control lights for it alone once the others are locked or spent; the hold
  reads the passes flown and the heat so far; the heat forecast shows the next pass's heat.
- **Engine.** `Skirmish.reroll` lets its assigned die be rerolled while the passive is live
  (un-assign, reroll, act again); the throttle's effect adds a team reroll this round; the
  bot's reroll loop gains pass options (the die's best expected spend less its heat's cost,
  against the reroll's worth to the other dice); the save carries nothing new; synthetic
  passives in the tests.
- **What the runner reads.** Passes a round; the share of the team's rerolls it takes and the
  dice left unfixed; overheats and the hull burned; the damage forgone to heat (the heat
  report); the team rows with and without it, since count dominates composition and four
  passes from one machine may read as a four of one.

## The second round (19 October)

- Ryan, 19 October: "cool, not deep enough. Doesn't push the maverick fantasy, its more just
  like free extra shots."
- Claude, 19 October, the push: each pass raises the stakes. The passive: a team reroll rolls
  its die again after it has acted, and it acts again; each pass after the first this round
  adds 10 to the blow and 10 to its heat. The second pass is +10 and +10, the third +20 and
  +20, the fourth +30 and +30, the throttle's fifth +40 and +40; the die shows the next pass's
  number and heat with the push in, so the bet is read before it is placed. The bust is the
  overheat at the end of the turn, hull burned one for one, and hull never heals in a battle,
  so bravado costs the campaign. What makes it deeper than free shots: every pass is a bet
  with rising stakes and the decision is when to stop; the entry each pass lands on is the
  die's (a vent mid-push is a cooling pass that extends the run, a shield a pass wasted or a
  pass kept for the enemy's turn); heat carries across rounds, so a big push today is a small
  one tomorrow; and the team's rerolls are its fuel, so the whole team plays the push. The
  throttle stays: Rapid, cooldown one, heat 20, the team gains a reroll, the engines pushed
  for one more pass. The knobs: the step (10 and 10), the heat maximum (120), cooling (10),
  the throttle's heat, a cap on passes; the runner's cautious and reckless personas (the heat
  row) differ most on this machine, which is its read. Bench, for Ryan to overrule: luck by
  rerolls left (its rolled weapons roll twice and take the better while the team holds a
  reroll, the worse once none is left: a maverick riding the team's nerve); the called shot (a
  bet on a rolled range, the top half doubled and the bottom half a fizzle), which the no-crits
  row refuses as a threshold on the damage; the dive (a Direct weapon spent on a back-rank
  foe through a standing front, the front foe of that column striking it as it passes), a
  maverick's mechanic for a smaller Kestrel, the interceptor perhaps, since a flagship does
  not dive; and the first kit, the free passes.

## Open for the session

1. Ryan's call on the push (passes bought with the team's rerolls, each hotter and harder
   than the last) and the throttle; or one of the bench's maverick mechanics in its place.
2. A cap on passes a round (none, or two) and the throttle's heat, read by the runner.
3. Its shape, the ekranoplan or the gunship, and its numbers, matched to Ryan's silhouette.

## Holes already raised

- Up to four or five spends a round from one machine: the team's turn becomes its turn. The
  levers: a cap of two passes a round, the throttle's heat, the stock pass's heat prices.
- The Paradox counts each pass's statuses; a Rapid gun on it adds passes outside the rerolls,
  its own cooldown the limit; a Scrambled die's reroll lands anywhere; the Clydesdale's free
  reroll of its own die does nothing for it.
- The bot must learn it before a runner row says anything about it (the to-do's valuations
  line).

## Bench

- A main battery as a second lock (a flat 30 cannon with a cooldown of two), if the throttle
  alone reads thin for a tier three's locked pieces.
- Unspent team rerolls at the round's end bank as Overcharged on it: press your luck by
  holding (the analysis's reroll-maker reversed).
- The chain: Rapid switches nothing off on it and vents do nothing on it, so every maker's
  Rapid pieces chain while its heat lasts (the third round of `kestrel_shield_spender.md`).

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Kestrel row, content planned, and this brief
retired.

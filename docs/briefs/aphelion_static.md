# Brief: Static, Aphelion's shock tier one (new chassis)

<!-- hangar: {"kind": "chassis", "maker": "aphelion", "tier": 1, "status": "idea", "slot": true, "name": "Static"} -->

The session designs Ryan's Static machine of 4 November: an Aphelion tier one whose every hit
lays Static, a debuff that discharges into the foes around its carrier and conducts Chain. On the
ten-a-maker plan it is also Aphelion's half of the shock-synergy unit. "Static" is Ryan's word for
the status; the machine's name is his.

**Status**: Ryan's idea of 4 November, Claude's first round below, unanswered. **Maker**: Aphelion.
**Proposed tier**: one. **Read first**: `docs/briefs/README.md` (ten a maker, the orbits); the
bible's Chain row and primers row and the Paradox's row (section 5); `docs/rules.md` on Chain,
Splash and a passive's lays.

## What Ryan said

- 4 November: "Hitting an enemy with a weapon or equipment inflicts Static 1. Static: Debuff, When
  damaged, deal 1 damage per stack to self and surrounding units in a Splash pattern, then reduce
  Static by 1. Static conducts Chain just like Shock."
- 4 November: "Aphelion and/or Arsenal: a shock-synergy unit. Arsenal is some kind of thunder
  demon/god homage." On the ten-a-maker plan the Aphelion half is this machine; the Arsenal's is
  its thunder figure (`arsenal_thunder.md`).

## Claude's first round (4 November)

**In today's engine.** The passive lays a status on each foe the machine hits. By the rule for
passives that is a stack a strike, and it lands after the hits, with the riders. The discharge
reads Splash's footprint: the foes beside the target in its rank, and the other rank of its
column. Chain reads a conductor.

It passes the tier-one test: every basic gun lays Static, so the machine is itself with basics.
It answers Ryan's own fix for Chain if it reads weak ("we can either add more things for it to
proc on, or give it the self-charge again", 2 November): a second conductor, which the Chain row
had pictured as Flak. It is also the first Shock-family piece that hits the foes around its
target.

**The holes.**

1. **Which damage sets it off.** "When damaged" covers a team blow, an area's blow, a
   spill, a mine, a Burning or Vitriol tick, and the discharge itself. If a discharge can set off
   Static, a foe's own share sets it off again: Static 3 deals 3, 2 and 1 to the foe and to each
   neighbour from a single hit. Two neighbours that both carry Static set each other off.
   Claude's lean: a discharge never sets off Static, on any foe. Then one damage is one discharge,
   and the forecast stays readable. Chain's ping is HP lost, no hit and no blow (24 November): if
   it counts as damage, Chain becomes what sets the field off, a use that pings discharging every
   Static foe once, each ping spending a stack where a Shock stays. The alternative lets the
   cascade run,
   with each foe discharging at most once a spend. That is the bigger fantasy and the harder read.
2. **The triangle.** Under Ryan's form, the stacks a strikes gun lays come back as a triangle. A
   ×3 Maxigun lays Static 3, which pays 3, 2 and 1 to the foe and to each neighbour: 6 to each. A
   ×4 lays 4, which pays 10 to each, where the scale's big guns deal 10 once. Ryan's call of 3
   November (riders land a stack a strike, because multi-hit pieces are "good with riders") keeps
   the lay at a strike. If the triangle reads too big, the lever is the discharge: deal 1 and
   spend a stack (so N stacks pay N), or discharge once a spend. Claude's lean: build his form,
   read the Maxigun's and the Cyclic Cannon's rows first, and keep the once-a-spend discharge as
   the exit.
3. **Armour.** If the discharge goes through armour (one rule for every blow), it vanishes on a
   braced foe and on a boss with armour. If it goes past armour, the way Burning does, it is
   reliable. Claude's lean: through armour, as every blow is. Tier one's rank and file carry no
   armour, and armour stays the foes' answer to small damage.
4. **How the other rules read it.** Static is a debuff the team lays:
   - The foes' Cleanse takes it, a foe's Ward turns it away, and the Susceptibility Tensor reads it.
   - The Paradox counts it. While the Baboon fights, every hit this machine lands adds a Paradox
     stack, so the two Aphelion tier ones stun together. The Paradox's row allows that.
   - A kill by a discharge counts for the spender; the on-a-kill trigger already counts Chain's
     ping and spills.
   - Chain is a ping since 24 November (Ryan: "Resolve: All Sprites with Shock, Static, or Sonic
     Needle lose {N} HP"): a foe that is both Shocked and Static loses its N once, not twice.
     Chain's tip names Shock alone since 25 November (Ryan: "the only non-exclusive conductor is
     Shock. So it's possible that we just need to mention Shock specifically"), so Static's own tip
     says "Conducts Chain", as Shocked's and Sonic Needle's do.
5. **The name.** The debuff is Static. The passive trigger `static` is named "Always on" since 25
   November (Ryan: "Rename the trigger term"); its id stays the engine's, so the debuff needs an id
   of its own (`static_charge`, say) under the name.

**The bench.** Static as a keyword on pieces rather than a passive: then the Stingray would deepen
it, and a keyword can still be added later. Splash 1 on every weapon: that is area by strength,
which the area row refuses.

## Open for the session

1. Whether a discharge sets off Static (the cascade), and whether Chain's ping does.
2. The triangle on strikes guns, and its exit.
3. Through armour or past it.
4. Its numbers and stock, and a locked piece if its silhouette has one.

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Aphelion row, Static in `content/vocabulary.json`
before its code, content planned, and this brief kept until its content lands.

# Brief: the Armadillo as a form-changing tank (rework)

The session settles the Armadillo's rework into a form-changing tank at tier one, from Ryan's
latest shape, and decides the one piece he left open: what its stored charge cashes in for on
unsealing, or whether there is a charge at all.

**Status**: rework, a direction Ryan is still weighing ("Interesting. I'll think about it", 15
October). **Maker**: Minerva. **Proposed tier**: one. **Read first**: `docs/briefs/README.md`;
`docs/roster_analysis.md` section 2 (the Armadillo's rating) and section 12 (the direction);
`content/chassis.json` (armadillo) and `content/components.json` (lockdown_shutters,
shoring_jack); the bible's rows on the Faraday Hull and the Armadillo's retaliation (section
7), and on Guard, Braced lasting the round, retaliation and thorns (section 5).

## Where it stands in content

An assault walker: hull 150, armour 15, five hardpoints, the locked Lockdown Shutters (a
self-only shield whose rule, Sealed Live, extends the Faraday Hull to blows on the shield), and
the Faraday Hull as its passive (a foe that strikes its bare hull is Shocked). The runner reads
it as nearly indestructible alone, which is a diagnostic only. The bible's open row: Ryan, 12
October, would remove the Faraday Hull first if a retaliation must go ("armoured, not a
porcupine").

## How the go got here (14 and 15 October)

- Ryan: "I wonder about pushing the Armadillo into tier 2 just so that tier 1 doesn't have
  access to a hypertank. That was part of my problem with the Faraday hull, it works as a
  support passive but what if the Armadillo was just the HYPERTANK in the game? And we move
  faraday to a new unit that still wants to get hit, but actually has to worry slightly about
  its own hull (Echidna/Hedgehog/etc), whereas the runner shows the armadillo is pretty much
  indestructible."
- Claude: a hypertank nobody shoots protects nobody, since the exposed aim weighs the hull a
  blow would reach; proposed a conditional draw on the locked shutters (blows at an ally's bare
  hull turn on it while they stand).
- Ryan: "If the armadillo is the hypertank, how do we make it's build interesting other than
  'slap all the lures on it?'" Then: "the shutters closed, protecting the carries, is going to
  be the default. Because it doesn't have a combat passive, there's no reason for it to try and
  beat them at their own role. What if it was a form shaper? Like shutters closed, defenses go
  up, and heat rises every turn? Still needs a payoff, and a build hook."
- Claude proposed the Faraday Hull as the sealed form's payoff. Ryan: "You're sure that
  enabling the shock hull during defensive mode isn't double-dipping? Luring on a tank is kind
  of the whole point, the optimal play, if you will, and rewarding it for doing it's job seems
  potentially dangerous." Claude agreed and withdrew it: under a draw every foe chooses it, so
  a Shock per striker scales with the enemy's blows, which is the old discharge's shape.
- Ryan: "As a form changing tank, the dillo could have a place in tier one as a simple
  role-filler... how can we push it to increase build diversity? The simplest way to implement
  the form change is via spending a weapon or shield, which would free up a locked component
  slot... The other option is to turn on the Faraday hull when it's NOT in defensive mode, but
  I still think that a thorns tank is only balanceable if the thorns themselves have a
  drawback."
- Claude: the form follows the die (a shield spent seals it, a weapon spent opens it); the
  build hooks are every maker's shield as a way to seal, Braced persisting while sealed (the
  longer Braced the bible allows once it carries a drawback, here the heat clock), vents and
  cooling for the open rounds, and lures while open. On the Hull in the open form: with armour
  15 the exposed aim rarely picks it, so it would be too little there and too much under any
  draw; its home is the hedgehog (see `minerva_hedgehog.md`).
- Ryan: "what if, on transforming back from defensive mode, it got a bonus not based on heat
  gained, but punishment endured? Like a kinetic capacitor? Not necessarily to unload extra
  damage, as that could put us back where we started, but as another buff that could be the
  build-around? And are we sure that it should blanket taunt in defensive mode, giving it's
  allies a free pass for what could be 3 or 4 turns? We could have the heat increase faster
  based on hits taken, but a form changer still needs to be able to shift for more than a turn
  at a time or it can get tedious to play."
- Claude proposed every ally Braced per blow endured on opening, and a draw limited to blows
  that would injure an ally. Ryan: "Yeah this is taking off into complicated territory I think.
  And giving the team tank stats is just as toxic as taking all the blows - it's an unkillable
  team by a different name. We need to think outside the box."

## Ryan's latest shape (15 October), the starting point

In his words: "The dillo hits a shield and transforms, building heat every turn. While
transformed, it gains braced (base armour needs to go down), and stores the unmitigated damage
it would have taken as a count on a buff token. Perhaps all its shield faces somehow become
lure faces? Then, when it unseals, it caches in the stored damage for...? A team buff? A self
buff? Something that's a build around that isn't just having it's cake (tanking effectively)
and eating it too (dealing damage)."

Claude's reading of it, for the session to confirm: a shield spent seals it, a weapon spent
opens it, anything else keeps the form; sealed, its shield entries are spent on a foe as lures
(the foe and its neighbours turn on it), the shield's number landing on itself, so the draw is
a spend that shows on the intent each round, never a blanket.

## Claude's proposals for the cash-in (15 October)

- **Lean: rerolls for the team, this round**, a reroll per so much stored, on top of the three.
  The one currency in the game that is neither hull nor damage; nothing gives it to the team
  today (the Clydesdale makes one for itself); it makes the squad's dice better without making
  the squad harder to kill or harder-hitting, and every reroll is still a decision. It composes
  with big dice and rolled weapons (the Muzzle Velocity Booster and the Tactical Databank sit
  on it), answers the Waste's theft of rerolls, and saturates rather than multiplies, since a
  fifth reroll is worth little and none can be banked. It makes "open first" a decision: unseal
  early in the turn and the team rerolls this turn's dice with the bonus.
- Alternatives if rerolls read too abstract for Minerva: Disrupt on every foe that struck it
  while sealed (soft control, the thinnest class, but it overlaps the jellyfish); or a round of
  Indirect reach on its guns when it opens (the turret rising over the shell; worth nothing
  against a pack with no back rank).

## Open for the session

1. The cash-in: rerolls, Disrupt, Indirect reach, something else, or no capacitor at all.
2. Whether its shields become lures while sealed (Ryan's "perhaps"), and how the die shows a
   shield entry as a lure in that form.
3. The heat clock: how many rounds a seal can last before opening is forced, and whether hits
   taken speed it (Ryan doubts it: a form changer must shift for more than a turn).
4. How far base armour comes down, and how many Braced stacks the sealed form gives.
5. Whether it keeps a locked piece (the shutters) or locks nothing because the form follows the
   die.
6. Tier one confirmed, and the passive's rule text within the budget.

## Refused along the way

Not to be proposed again without a new reason:

- The Faraday Hull on it in any form (a Shock per striker under a draw is the discharge again;
  in the open form the aim rarely picks it).
- A blanket draw while sealed (with armour 15 a swarm's blows bounce entirely and the Meadow is
  deleted; Ryan's "free pass for 3 or 4 turns").
- Team Braced or team shield on opening (an unkillable team by another name).
- Unloading the charge as damage (Ryan: "back where we started").
- Heat per hit so fast that a seal lasts a turn (tedious to play).

## Holes already raised

- The passive is two rule lines at least (sealed, and the cash-in), at the edge of the
  rule-text budget, so its description must do no other work.
- A shield spent on a foe is a new gesture for equipment; a passive may make it a one-off, but
  the die must show the entry as a lure while sealed.
- Rerolls step the revolver and never land on an identical entry, so a team with a revolver
  locks it before cashing the charge.
- The unmitigated count ignores the plate on purpose, so Braced never fights the charge; the
  heat clock decides how long the shell stays closed and is the number the stock pass tunes.
- The greedy bot values none of it (a lure, rerolls for others), so the runner's rows wait on
  its valuations.

## Pairs and dependencies

- The hedgehog (`minerva_hedgehog.md`) takes the Faraday Hull; Sealed Live goes with it.
- The shield rule (decided): shields are honest numbers now, so the plate it seals with is the
  shield's number.

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Armadillo rows (the open row on its retaliation
closed, the chassis table, the Faraday Hull row moved), content marked planned where the engine
cannot run it, and this brief retired.

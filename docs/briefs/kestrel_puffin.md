# Brief: the Puffin, the escort made Kestrel (rework, proposal)

The session reworks the Puffin's locked shield so the escort reads Kestrel's resource, heat,
in answer to Ryan's two worries about it, toxic and boring, without giving up the shield
support that is Kestrel's alone.

**Status**: proposal (Claude, 20 October) on Ryan's concern of the same day. **Maker**:
Kestrel. **Tier**: two. **Read first**: `docs/briefs/README.md`; `kestrel_line.md` (the
line review, where its kit was written out); the bible's Puffin row and its shield rule
(sections 5 and 7); `content/chassis.json` (puffin) and `content/components.json`
(backwash_ionizer, wake_diffuser); the Puffin's rows in `docs/balance.md`.

## What Ryan said

- 20 October: "Puffin I still worry is 1) toxic and 2) boring. The shield support is
  definitely a niche that we can fill, and it's very unique for Kestrels roster. There's no
  real reason to cram all the supports into Aphelion. That said, since I have concerns
  regarding the Puffin, it might be a chance to make it feel more...Kestrel-ey." Kestrel's
  identity, the same day: heat, rerolls, multi-strikes and risk. Its speed need not stay slow,
  "if its an all-in support", but nothing moves it.

## As built

A light hover at move 40. Hull 50, shield 30, field recharge 30, heat maximum 60, cooling 5,
armour 0; four hardpoints beside the fixed Backwash Ionizer, a d5; two module slots. The
passive, the Slipstream Projector: any ally this machine shields also sheds 10 heat. The
fixed piece, the Backwash Ionizer: shield 30, allies only, Overshield (past the ally's
maximum; the excess fades at the round's end). Stock: a small gun, the Rapid shield, the
Overcharged buff and the vent that shields (the Wake Diffuser, Rapid off since 20 October).

## The worries, read

- Toxic: 30 past the maximum and a vent on the key ally every round, whoever it is and
  whatever it did, is a wall by another name, the shield-bot the Puffin row refused, in degree
  rather than kind; under the honest shield rule it becomes 30 hit points a round for free.
- Boring: the decision each round is the same read (the ally the intents name) and the shield
  is the same number; nothing the allies do changes what the Puffin does.

## The proposal (Claude, 20 October)

**The Backwash Ionizer reads heat.** Its shield on an ally is as big as the heat that ally
carries, past the ally's maximum (allies only; Overshield as now); the passive still sheds 10
of it. The codex line already says it: it ionizes the target's backwash, and the hotter the
backwash the bigger the bubble. The number is the ally's heat one for one (Ryan's ratio; half
is the lever, and 30 plus the heat the lever if the floor on a cold ally proves too low).

- **The decision.** The hot ally or the threatened one, which are not always the same
  machine; and the team's order, since an ally that fires its hot gun before the Puffin spends
  is shielded for it, and one that fires after is not (the action-economy row's home for a
  second action: an ally's action as the pair). The jets run hot because their escort turns
  heat into shield; a cold ally gets nothing from the lock and is the stock shield's to cover.
- **Why it is less toxic.** The shield is paid for by heat the ally generated, a risk already
  taken (the overheat waits at the gauge's top, and cooling is 5); a cold body gets no free
  wall; it stays one ally a round and fades at the round's end.
- **Why it is less boring.** The number moves every round with the gauges and the order of
  spends is part of the play; the heat forecast on the die is the shield forecast.
- **Why it is Kestrel.** Heat as a resource converted for others (the Goshawk converts its own
  at the round's start; the Puffin converts an ally's at the spend: the shapes differ, Ryan's
  rule), risk rewarded. The wart dissolves: the Goshawk at 60 heat is shielded for 60 past its
  maximum and sheds 10, losing 5 of regen for the round.
- **Pairs.** The Sparrowhawk after a chain (30 heat, a shield of 30 on 30 hull); the
  interceptor's two spends; the Goshawk; the capital's rolls do not heat it. The off-tank is
  cold by design, so its magazine is the Puffin's stock shield, not the Ionizer. The Peak's
  Scorched and Burning heat the allies, so the Puffin's bubble grows in the one domain that
  presses heat: the escort's domain.

## The second round (20 October): the passive reads heat, the lock uses it

- Ryan, 20 October: "reading the teams heat and shielding based on that fits a lot of Kestrel
  principles, but are you just talking about the one overshield lock and not the passive that
  cools, the toxic part? Couldn't the passive be increase-shield-by-heat in some fashion, and
  the locked be overshield, that then uses the passive? Or am i not understanding?"
- Claude, 20 October: his split is the better one and the first proposal had it the wrong way
  round (the heat read on the lock, the cooling kept as the passive). As it stands now: the
  passive is the read, every shield it spends on an ally grows by the heat that ally carries,
  stocked shields included, so the passive multiplies what shields do (the row's rule); the
  lock is the Backwash Ionizer as built, shield 30, allies only, Overshield, which is the big
  one through the passive (30 and the ally's heat, past the maximum). The cooling goes with
  the old passive: it was the toxic half, and it fought the heat the new passive rewards (an
  ally shielded for its heat wants to keep it). Cooling becomes a stock choice, the vent that
  shields (the Diffuser: vent 10, shield 10 and the ally's heat through the passive, and it
  sheds 10). So the Goshawk wart is gone entirely, and the Puffin cools nobody by rule.

**The design as it stands (the second round).**

- **The passive**, working name Ryan's: a shield it spends on an ally grows by the heat that
  ally carries (one for one; half the lever).
- **The lock, the Backwash Ionizer** as built: shield 30, allies only, Overshield; through the
  passive, 30 plus the ally's heat, past its maximum, fading at the round's end.
- **The arithmetic.** An ally at 20, 40 or 60 heat: the Ionizer 50, 70 or 90 past its
  maximum; a plain shield of 20 is 40, 60 or 80 up to its maximum; the Diffuser 30, 50 or 70
  and the ally sheds 10. An ally at 0 heat (the off-tank) gets the plain numbers, so the
  stock shield is its magazine as before.

**The die, as the stock pass would leave it.**

| Entry | Piece | What it is for |
|---|---|---|
| I | the Backwash Ionizer: shield 30 and the ally's heat, past its maximum | the hot ally |
| II | a plain shield, self or ally | the cold ally; the off-tank's magazine |
| III | the Overcharged buff | the hitter's round |
| IV | the vent that shields (the Diffuser: vent 10, shield 10) | the hot ally that must cool: it sheds 10 and gains 10 and its heat |
| V | a small gun | when nobody needs anything |

**The arithmetic.** An ally at 20, 40, 60 or 80 heat is shielded for 20, 40, 60 or 80 past its
maximum and sheds 10; a Sparrowhawk after a two-kill chain (30 heat) gets 30; a Goshawk riding
at 60 gets 60; an off-tank at 0 gets nothing from the lock. Against today's 30 flat the hot
allies gain and the cold ones lose, which is the point.

**Engine.** A face whose number reads the target's heat (a printed property, `power_from_heat`
or its like, on a shield face); the die's number dragged over an ally reading that ally's
heat; the bot valuing heat as shield in hand; synthetic passives in the tests. Small.

## Holes already raised

- A hot ally that is not threatened gets a shield it does not need; the intents are still the
  read, and the overshield fades, so the waste is one spend.
- The Peak's Scorched and Burning become shield through it, an enemy-heat-into-shield loop; the
  ratio is the lever, and the Peak is the domain that should fear an escort.
- Under the honest shield rule every point of it is hit points; the stock pass re-reads the
  ratio with the other shield numbers.
- The passive's name and wording are Ryan's; the Slipstream Projector's "science magic" line
  (6 October) still fits.

## Bench, one line each

- The shield from its own pool (the Ionizer moves the Puffin's shield to an ally, past the
  ally's maximum): zero-sum, so never a wall, and the field recharge refills it between fights;
  set aside because no heat is in it.
- The shield that lends a look (an ally it shields rolls its die again): Kestrel's rerolls as
  a support's gift, the capital's launch at tier two; set aside as a second idea on one lock,
  free for a Kestrel piece of its own later.
- A rolled shield (a range the rerolls shift): a gamble on the number, a gimmick alone.

## Open for the session

1. Ryan's call on the second round's split (the passive reads heat, the Ionizer the overshield
   through it, the cooling gone) and the ratio.

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Puffin row rewritten in place, the content's
Ionizer (planned until its engine), and this brief retired.

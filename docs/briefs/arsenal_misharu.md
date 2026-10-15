# Brief: Misharu, with Penance (proposal)

The session settles Misharu's Penance, the weaken that replaced its sentence, against Ryan's
two holes, which fight each other.

**Status**: proposal with a place; the payoff decided as Penance (Ryan, 14 October). **Maker**:
the Arsenal. **Proposed tier**: two. **Read first**: `docs/briefs/README.md`; "The design as
proposed" below, with its first Penance; `docs/roster_analysis.md` section 4; the bible's
shield rule and its Barrier and Ward row (section 5), and its row on the Arsenal's next chassis
(section 7).

## The design (the proposal)

Passive: a foe whose blow breaks a machine's shield was Suppressed. Locked: the Vigil Pavise (a
self-only shield with Overshield, the game's first self overshield) and the Interdict Halberd
(Direct, flat, Penetrate). Every shield on the team is bait: a small fresh shield on the
machine a heavy hitter has picked is a sentence waiting.

## What changed in the go

- Ryan, 14 October: "Alter Misharu's shield-break payoff away from suppress, maybe."
- Claude: Penance from the bench, a weaken (the foe hits softer), the one verb nobody has on
  the foes' side; it changes the enemy's problem rather than removing its turn, every ally
  benefits, and it reads as judgement. Cap it so a boss is blunted, never nulled.
- Ryan, 14 October: "fine like that, but my holes are: the payoff has to be worth sacrificing a
  shield for, and the boss issue is a real concern. Both those holes fight each other."
- Claude: they stop fighting if the payoff is a proportion of the breaker's own blow, bounded
  per bait. Penance halves that foe's blows for its next action, never stacking. Against a
  goblin the halving is worth nothing, so nobody baits goblins; against the boss it is worth a
  small bait every round; the ceiling is fixed at half, so the boss is blunted, never nulled.
  The lever is the fraction, a third if half is too strong.
- Ryan, 14 October: "Misharu with a 'shield all allies for 5' component is kind of broken,
  isn't it? It makes me leery about the shield-blocking-a-blow mechanic, once again." This led
  to the honest shield rule (decided). Claude also proposed that the sentence lands once a
  round, on the foe whose blow broke the biggest shield, so a shield handed to every ally buys
  one Penance, not eight.

## Since then

Under the honest shield rule a break is a shield taken to zero, and a shield smaller than the
blow buys the Penance at the price of the overflow on hull: a real trade the bait was missing.

## The design as proposed (12 and 13 October)

Claude's proposal for Ryan to move, except where marked as his; names are working names and
numbers the proposal's placeholders. It was written for the suppress and under the whole-block
shield rule: where the go or a rule has since changed it, it says so, and what that leaves open
is in the questions below.

**Ryan, 12 October**, as the proposal recorded his notes: the first Misharu (gaining shield
Overcharged it) was an alternate Nemesis; the Arsenal needs archetypes other than Overcharge
scaling. Push the divine personification of justice, with a trigger such as a foe's blow that
would have killed an ally this round, a component breaking or a shield breaking, inflicting a
punishing debuff on those it deems sinners. Later that day: the suppress liked, needing lots
of testing, with hull damage or several procs to a suppress as the fallbacks (the bench).

**The chassis**: Arsenal Instrument II (medieval: justice), tier two, heavy, walker. Hull 120,
shield 40, armour 10, move 20, heat maximum 80, cooling 5, field 20, two modules; a die of
five, two locked entries and three hardpoints.

**The passive**, the Assize Relay (the travelling courts of medieval England; on reflection,
the Bloody Assizes). As drafted: *a foe whose blow breaks a machine's shield is Suppressed: it
loses its next action.* Its edges, written for the suppress:

- What counts: a foe's blow that takes any machine's shield to zero, Misharu's own included,
  while Misharu fights. The draft also counted a breach; under the shield rule a breach leaves
  the shield standing, so it breaks none.
- The striker has already acted, so the suppress cost its next action, and its chip showed it
  through the player's next turn.
- A foe with several strikes: the strike that breaks the shield convicts it; its other strikes
  this action still land.
- It counted toward the Baboon's Paradox as a debuff gained.
- Not a trigger: the splash an Indirect spend costs its own firer, a Corrupted entry's bite, a
  move that adds heat. None is a foe's blow.

**Locked pieces.**

| Piece | Kind | Reach | Number | Heat | Keywords | Targets | Tags |
|---|---|---|---|---|---|---|---|
| Vigil Pavise | shield | | 30 | | Overshield | self | |
| Interdict Halberd | attack | Direct | flat 10 | 5 | Penetrate | | Blade, Melee |

The Pavise is the game's only self overshield (the Puffin's Backwash Ionizer reaches allies
only), so Misharu can stand its own bait. The Halberd reaches through a column, front and back.

**Stock**, three hardpoints, provisional until the stock pass places the basics: the Oblation
Mantle (the Oblation Ward before Ryan's rename of 15 October), the Proximity Klaxon, the Plasma
Arquebus.

**Build space.** Every shield on the team is bait. Foes draw their targets as the round opens
and commit to them, so a small fresh shield on the machine a heavy hitter has picked is a
sentence waiting. The bait: ally shields from anyone (the Puffin, the Halo Shield, the Votive
Screen), modules that stand shield up (the Spall Liner, the Boundary-layer Bleed), and the
lure on its own die when no other machine is the bait. As written, the bait also blocked the
blow whole, so size did not matter (a 10 shield in front of a 40 blow blocked it and
convicted) and a shield topped up past the blow was a plain block. Under the shield rule the
10 absorbs its number and 30 reaches the hull, less armour ("Since then", above).

**What it answered**: the Peak, with small shields under its telegraphed blows, each blocking
the blow whole and convicting the striker (open item 6).

**Engine and tests**, as proposed for the suppress: small. In `_enemy_turn`
(`sim/skirmish.gd`), after each `_damage_mech`, the blow's event already carries
`broke_shield`; with Misharu fighting, the payoff goes on the striker (the draft:
`_suppress(foe)`, the striker being in `_acted`) and `_foe_gained_status`; a passive trigger in
`sim/effects.gd`, and the vocabulary's word. Tests: a break convicts and a shield left standing
does not; Misharu's own shield counts; no Misharu, no payoff; a multi-strike foe; the Paradox
counting it. The draft's "a blocked break and a breached break both convict" and "Numbed
resisting" belong to the old shield rule and the suppress.

**What the runner should read**: the boss cells (the Treant, the Sandworm, the Bone Dragon, the
Magma Golem), the Peak's cells, team rows beside shielders, and how often shield entries are
spent on Misharu's team; the analysis (section 4) reads Misharu beside the Puffin first.

**Penance as first benched** (12 October): a debuff, its blows 5 less a stack (never below 5),
a stack fading each of its turns; mitigation the game lacked, at the price of a new chip.
Claude's lean in the go is another shape (above); the shape is open item 1.

**The look**: Claude's (12 October), a gothic knight with a pavise as tall as its torso and a
halberd taller than the machine; its detail is in git. Looks are Ryan's.

## The bench, with what set each aside

- **The first Misharu**: gaining shield Overcharged it; an alternate Nemesis (Ryan, 12
  October).
- **The suppress on a broken shield**, the drafted passive (Ryan, 12 October: liked, to be
  tested hard): replaced by Penance (Ryan, 14 October).
- **The sentence**: a shield's breaker owes the shield it broke as damage at its next action.
  Ryan's first fallback (12 October); a thorn, allowed only with a drawback of its own. Set
  aside with the suppress.
- **Several breaks to a suppress**, a meter in the Paradox's shape: Ryan's second fallback (12
  October), set aside with the suppress.

## Open for the session

1. Penance's exact shape: the fraction (half or a third), for its next action or longer,
   stacking or not.
2. Once a round, and on which foe.
3. The locked pieces: the Pavise's self overshield and the Halberd's Penetrate, kept or
   changed.
4. Its chip: a new foe debuff kind (a weaken), with structure of its own.
5. The draft's edges (above), re-read for Penance: the multi-strike breaker, the Paradox, what
   never counts.
6. What Misharu answers under the shield rule: the proposal's answer to the Peak rested on the
   whole block, and the Peak's telegraph now wants a shield sized to it or a Barrier (the
   bible's shield rule, section 5).

## Holes already raised

- The greedy bot (`sim/policy.gd`, `shield_score`) knows nothing of a foe's lost damage when
  it weighs a breakable shield; the runner under-reads Misharu until it does.
- The player must see why a foe hits softer: a mark on it and a log line.
- Density, as the proposal raised it for the suppress: a team that shields whoever each heavy
  hitter picked could sentence every big blow every other round, and Numbed's ramp was the
  only brake. Numbed resists only a suppress (`docs/rules.md`), so it does not brake Penance.
- Under the shield rule the bait's overflow counts toward an injury (`docs/rules.md`,
  "Injury"): a 10 shield before a 40 blow puts 30 on the hull, enough to injure an unarmoured
  machine of 120 hull or less.

## What the session hands back

A proposal in chat; on Ryan's go, Penance into the vocabulary, the bible's row, content
planned, and this brief retired.

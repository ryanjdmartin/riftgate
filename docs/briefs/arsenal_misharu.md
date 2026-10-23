# Brief: Misharu, with Penance (proposal)

The session settles Misharu's Penance, the weaken that replaced its sentence, against Ryan's
two holes, which fight each other.

**Status**: proposal with a place; the payoff decided as Penance (Ryan, 14 October); in session
since 15 October (Claude's first round and its review, below; Ryan has answered none of it).
**Maker**: the Arsenal. **Proposed tier**: two. **Read first**: `docs/briefs/README.md`; "The
design as proposed" below, with its first Penance; `docs/roster_analysis.md` section 4; the
bible's shield rule and its Barrier and Ward row (section 5), and its row on the Arsenal's next
chassis (section 7).

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
Magma Elemental), the Peak's cells, team rows beside shielders, and how often shield entries are
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

## The Arsenal session (15 and 16 October)

Nothing here is Ryan's yet. Claude's first round went to chat on 15 October and Claude's review
of it on 16 October (Ryan's ask: errors in logic, biases, wrong assumptions, gaps in design).
He has answered none of it. Nothing landed on main since has changed Misharu.

**Found in the content (15 October).** A breach never breaks a shield: under the shield rule
the shield stands and the whole blow passes it. The breaching blows are the Sandworm's Swallow
and the Magma Golem's Slag Fist (40 each; the Waste's and the Peak's bosses in content, elites
once the slate lands), every Needler's, the Black Mage's Flare, the Lancer's Jump and Dragon
Dive, and the Bomb's self-destruct. As written, Misharu never sentences the heaviest single
blows of two domains of four, which is Ryan's boss hole from the other side.

**Claude's first round (15 October)**, by the open items below:

1. Penance: *its next attack deals half, then the Penance goes; it never stacks*, Shocked's
   mirror on the foe's offence. "Its next attack" in place of the 14 October lean's "its next
   action", so a heal, a rally or a summon drawn next does not waste it; every strike of that
   attack is halved, an attack at every machine included, and Kindled with it (adds before
   multiplies).
2. No once-a-round cap: the honest shield rule did the cap's job, since each Penance now costs
   a shield that absorbed only its own number, and the overflow on hull.
3. The Vigil Pavise: its Overshield now works against the bait (30 over a maximum of 40 is a
   70 wall no blow in content breaks). The lean: it Wards its target, as the Breaching Plow Braces the
   Boar: shield 20, self or ally, and a Ward, so a breach meets the shield, breaks it and earns
   the Penance, which closes the breach hole. A pavise covered the crossbowman behind it, so
   self or ally reads. The Interdict Halberd kept.
4. The chip: the foe's intent line shows the halved number, so the read is the number itself;
   the chip's glyph needs structure of its own, never hue alone.
5. The edges: any foe's attack that takes any machine's shield to zero while Misharu fights,
   its own included; a breach never, unless its target is Warded; an attack that spends a
   Penance lays a fresh one if it breaks another shield; the Paradox counts it as a debuff
   gained, and it joins the Susceptibility Tensor's list; Numbed never touches it, since it is
   no suppress; splash, bites and Volatile never count, being no foe's blow; a Penance laid
   stays when Misharu falls.
6. What it answers: the big single hitter in every domain, wherever the bait is smaller than
   the blow. Ryan's two holes stop fighting: the bait is worth it only against a blow much
   bigger than the shield (never a goblin), and a boss is never cut below half.

Its holes: a boss held at half every round, since a halved attack that breaks a second small
bait renews the Penance (if too strong, the first lever is that the attack a Penance softened
lays none, so every other attack at most, before the fraction); and Misharu as its own bait,
armour 10 under a small bait and a lured big hitter at half, with the Proximity Klaxon in its
stock as the lure (the levers: the stock pass taking the Klaxon out, or armour 5).

**Claude's review (16 October)**, correcting the round:

- Penance's proportion is Claude's lean of 14 October, never Ryan's call: the records hold his
  "fine like that, but my holes are" on the weaken as first put, and no answer to the
  proportion. The round presented it as settled.
- "Misharu takes no hull a round" holds against a 30-hitter only: a halved 40 still puts 5
  past a bait of 5 and armour 10, and no shield of 5 exists in content.
- The Pavise with a Ward is worth about a Barrier against a breacher, and the Penance besides:
  against the Golem it is the best spend every round, the shape Ryan turned the Aspergillum
  down for (the die's best entry, wanting no upgrades). The levers: its number, or the Ward on
  self only. It also puts a Ward carrier in content ahead of the stock pass, which the Barrier
  and Ward row leaves the carriers to; a locked piece is no stock, so no rule breaks, but it is
  a call to make in the open.
- Without the cap nothing limits how often: the honest shield rule limits what a shield is
  worth, not how often the rider fires, and Numbed does not brake Penance. The damage-rider
  row (section 2: a rider on an action the player takes anyway needs a limit) asks the same of
  a mitigation rider: the dice are the limit, or the renewal rule is.
- Unexamined: Penance and a countdown, whether a Penance laid while a blow gathers halves its
  landing (the Lancer's Jump breaches, so it convicts only when Warded).

## Open for the session

The first round's answers and the review's corrections are above; Ryan has given none. Put
items 1 and 2 to him first.

1. Penance's shape: the proportion (half, or a third) or the 12 October form (5 less a stack),
   on its next attack (the round) or its next action (the 14 October lean), never stacking.
2. How often: once a round on the biggest shield broken (14 October), no cap (the round), or
   no renewal off the attack a Penance softened (the review's lever).
3. The locked pieces: the Pavise with its Overshield, plain, or with a Ward (then its number,
   and self only or self or ally); the Halberd's Penetrate kept.
4. Its chip, and the intent line's halved number.
5. The edges (the round's list above), with Penance and a countdown unexamined.
6. What Misharu answers: the breach hole closes only by a Ward, the Pavise's or a carrier the
   stock pass places; without one it answers the blows that do not breach (the Treant's and
   the Bone Dragon's among the bosses) and never the Waste's or the Peak's biggest.

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

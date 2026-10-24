# Brief: the line frame, the Gundam homage (proposal reworked into a direction)

The session designs Aphelion's Gundam homage as the most tempo-oriented damage dealer in the
game: a duelist whose combo builds a rhythm until something breaks it. "The line frame" is a
working label; the name and the look are Ryan's.

**Status**: direction (14 and 15 October); in session since 15 October (Claude's first round,
its review and Ryan's first calls, below). **Maker**: Aphelion.
**Proposed tier**: one. **Read first**: `docs/briefs/README.md`; the bible's rows on
Aphelion's next chassis, on tags and on motion ("Heavy and mechanical, with inertia"), all in
section 7.

## Ryan's calls before the go (11 and 12 October)

- 11 October, his brief for Aphelion: "a Gundam-homage walker".
- 12 October: "Can't be too on point. I'm fine trying it as described since I doubt we'll get
  full RX78 in our renderer, but as long as it has a shield, a handheld rifle, and a beam
  sword - it's a Gundam. That said, I think if any chassis wants to go all in on a tag-based
  passive, it would be this one with something 'beam' based." "As described" was the
  round-one proposal below: its look, the locked saber, and a passive since benched.
- 12 October, for every Aphelion machine: "Aphelion doesn't use rotors as a general rule. They
  use thrusters, sci-fi space-age rockets."

## What Ryan said in the go

- 14 October: "the gundam needs a gundam-ey niche. If we boil down what a gundam does in anime
  - it combos, it duels other gundams, it usually SLAUGHTERS all the enemy's trash without
  breaking a sweat, and its theme is Beam weapons (beam saber, beam rifle, beam shield, and so
  on)."
- 14 October: "The interesting angle is making this the most tempo-oriented damage dealer in
  the game. Not Scaling, not burst, just sustained damage if you can land your blows in the
  right order. It could be the Eurogame engine in the game - plan your move, payoff that lines
  up another payoff that lines up another payoff - continue until your combo is broken. I think
  the Beam aspect is just setting it up for a different synergy that it doesn't start with, if
  there are modules that read Beam, it starts with 3 of them so its the obvious candidate."
- 14 October: "I think it can be simplified and made more elegant. What if it just had a combo
  buff, and not a marking of enemies. The more combo you have, the stronger it gets - but maybe
  not by damage, maybe it gains cooling and shield Regen or something. Ending a turn without
  attacking breaks the combo... Trying to evoke a feel of a duelists grace, chaining moves
  together, building a battle rhythm and becoming unstoppable. The other idea is a double-edged
  sword, where it gains a stacking buff that increases maybe damage but decreases some
  defenses, so you have to make a choice as to when to break the combo. That feels less Gundam,
  and not as unique, but it works."
- 14 October: "Regarding the Gundam shield, either the shield doesn't break the combo, or its
  rapid. Not sure what's more balanced. An aside, since it's a physical shield, it could be a
  self-barrier, blocking damage but not status effects and only for one turn (parry), so the
  foes have at least some small avenue of stopping its roll. And yes if we give it a stack on
  every hit, I would make the stacks very small. Like 1 cooling and 1 shield Regen to start.
  The fantasy is getting a huge chain. The alternative is to give boosts at combo thresholds:
  cooling at 5, shield at 10, damage at 20, or anything really. It would be a unique stacking
  buff on the machine either way."
- 15 October, on cantrips: "There could be a case for a cantrip-style component that has rapid
  without cooldown, as a combo piece for some kind of roll-related effect?"

## What Claude proposed

- 14 October, superseded by Ryan's simplification: an opener that marks a foe, later blows on
  it harder by the count, a finisher whose kill carries the mark on, the chain broken when no
  weapon shows.
- 14 October, on Ryan's combo: the sustain version is the one, since the payoff is the fuel
  (its beams run hot, so cooling per stack lets it keep firing them). Count weapons spent, not
  rounds, so Rapid pieces climb it faster; cap the stacks. The break is a turn that ends
  without a weapon spent, which on a d5 with three weapons and the team's rerolls comes by
  choice, the round the best play is a vent or a shield, and costs the whole ramp. Spending its
  own locked shield keeps the combo, or the beam shield fights its own passive. The saber may
  scale with the count as a dial, not in the first cut. Then: start with "spending the shield
  keeps the combo", reach for Rapid only if it needs tempo, with a parry on a cooldown of two
  as the middle step; thresholds rather than a linear 1-and-1 for the feel, the first low
  enough to pay in a five-round fight, a cap at the top (1 cooling a stack reads as nothing a
  hit on a phone).
- Cantrips (15 October): a single Rapid entry never lands on itself, so "no cooldown" matters
  only when a later reroll brings it back in the same round; that is a cantrip's value and its
  brake. Small pieces at tier two or three, the combo's fuel. Since Ryan's call the same day,
  Rapid's free reroll may land on a copy (stacked copies chain), so stacked cantrips with no
  cooldown can bounce from copy to copy, and a die of nothing but cantrips never ends its turn:
  they need the limit raised in the Armadillo's brief (`minerva_armadillo.md`) before they are
  built. Ryan's proposal there (15 October) is heat paid every spend; Claude's earlier one, a
  Rapid reroll never landing on an entry already spent this round, is its alternative.

## The design as proposed (11 to 13 October)

From the Aphelion chat, written up on 13 October for the batch evaluation. The bible's
Aphelion row records Ryan's call of 13 October: that session went off the rails, and its
proposal is "a list of ideas, not a design to defend". Everything here is Claude's unless
marked Ryan's, and the numbers are the proposal's placeholders.

- **The frame**: tier one, medium, a walker (Ryan's), move 30. Locked: the beam saber (round
  one) and a kite shield on the forearm (round two). Hardpoints: the rifle stocked in a hand
  mount, the hand showing whatever is fitted to it; the rest basic kit after the stock pass.
- **The look** (round one, part of what Ryan was "fine trying"): a V-crest on a small head,
  chest intakes, the kite shield on the forearm, saber hilts on the backpack; pearl and red are
  already half the RX-78's colours. The homage lives in the silhouette only, and it moves as
  every machine does (the bible: "MechWarrior or Star Wars, not Gundam or Evangelion").
- **Engine**: components still carry the old internal filing tags and only `melee` is read,
  though a `tag_<tag>` condition already works (`docs/rules.md`, tags); the stock pass assigns
  the new tags, Beam among them.

The bench, the forms set aside:

- Gaining shield gives a stack of Overcharged (+5 damage a stack, fading a stack at the
  round's end), so any shield source becomes damage (round one): set aside by Ryan's Beam call
  (12 October).
- Its beam blows deal +5 (round two, the plain form; the hole raised with it was that a passive
  reading one tag asks for every piece carrying it): set aside in the go, when Ryan turned Beam
  into a later synergy and the passive toward a combo (14 October).
- Its beam blows deal +5 to a foe it has already hit this round, the rifle then the saber,
  nothing carried past the round (round two, Claude's lead): set aside by the same call.
- Spending the shield lets the saber reach any foe that round, a locked pair (round two): set
  aside in the go, where Ryan's shield keeps the combo or is Rapid, and may parry as a
  self-Barrier (14 October).

## The Aphelion session, first round (15 to 20 October)

Ryan, 15 October, opening the session: "I want to work on the Aphelion design brief. Not
including the Zoid walker question, yet." Claude proposed for the line frame, the Baboon, the
jellyfish and the Carrier in chat that day. On 16 October, at Ryan's ask ("Review what we've
talked about and worked on so far. Look for errors in logic, biases, incorrect assumptions, and
gaps in good game design principles"), Claude reviewed its own proposal against main and the
open branches. On 20 October it was written down for Ryan to pick up later, with what had moved
on main by then. Ryan's first calls on it came the same day (below); everything else in this
section is Claude's, for him to move, and every number is a placeholder.

**The proposal, as the review left it**

- **The combo**: a stack for every hit its weapons land (Ryan's "a stack on every hit", 14
  October; a fighting game's hit counter). A turn it ends without spending a weapon clears it,
  its locked parry counting as a weapon for this. It lasts the skirmish. Every blow counts,
  strikes included (Ryan's call of 20 October, below).
- **The payoffs**, Ryan's thresholds as placeholders: at 5 it cools more, at 10 it regains
  shield as each round opens, at 20 its blows deal more; past 20 the count climbs for the show
  and pays nothing more. Each payoff takes away a reason to break the combo (heat forces a
  vent, danger a shield), and its damage does not grow until 20: what grows is how long it
  keeps attacking, Claude's reading of "not Scaling, not burst, just sustained damage". The
  review's correction: the cooling stays under its own weapons' heat, so the gauge still climbs
  while it fires, only slower. The 15 October figure (10 more on a base of 5, beside 10-heat
  beams) was close to heat-neutral, the free way out of the heat system Ryan is very wary of
  (the bible's Rapid row, 15 and 20 October).
- **The parry**: the locked shield, self only, grants a Barrier (the next blow deals no damage
  and its riders land: the foes' small avenue Ryan asked for, 14 October). Cooldown 2, and
  spending it keeps the combo. Chosen over Rapid: a Rapid parry is free (a parry and an attack
  in every round it shows), and Ryan's rule of 20 October, a Rapid shield never below tier two,
  reads against one on a tier one, locked or not (his call). Under "keeps the combo" a live
  parry is a safe entry and a dark one rolls as a blank, so the cooldown raises the odds of a
  break for the two rounds after a parry.
- **The saber**: locked, melee, flat, tagged Beam. Proposed on 15 October with Chain, the
  trash-slaughter (a flat kill carried on to the next foe, each link a hit); withdrawn in the
  review, since Chain is being reworked (Ryan, 15 and 16 October: "janky at best and snowbally
  at worst", the bible's section 12). Its keyword is open; scaling with the count stays a dial
  for later.
- **The rifle**: the basic Laser Carbine, tagged Beam in the stock pass, held in the hand (a
  look; the hand-holds row stays pinned). Two Beam pieces at the start; whether the shield
  carries Beam is the model session's (Ryan's call of 20 October, below; he called it a
  physical shield, 14 October).

**What the review corrected** (16 October)

- **Fight lengths.** The 15 October case for counting hits used single-pack fights (a lone
  machine 1 to 12 rounds, a team 1 to 6, most under 4). Against a formation a team fights 4 to
  16 rounds, most 5 to 10, and against one of the big foes (the 13 October bosses, elites
  since) 2 to 7 (`docs/balance.md`, greedy, 13 October); the pacing row asks for longer
  fights. At one hit a round, a single-strike kit reaches 5 in a typical formation fight and 10
  only in the longest, and seldom passes 5 against a big foe today; 20 needs volume. A
  formation machine first, which suits "a battle rhythm", but a different claim from the 15
  October one.
- **A break the die forces** is random that takes away (section 2's chances row, Ryan, 16
  October). It is rare with three weapons on the die and the team's three rerolls, but the ramp
  is lost through no choice of the player's. The alternative for Ryan: only spending equipment
  (the parry excepted) breaks it, and a turn with no weapon showing holds the count.
- **Decision density.** Once the combo is up, its payoffs take away the reasons to break it,
  and in the Marsh nothing attacks the die or heats it (the Meadow drains rerolls, the Waste
  disables, the Peak scorches and corrupts), so there it is a stat line that grows. The
  decisions left are the team's: rerolls spent on its die rather than an ally's, and allies
  cooling or shielding it (an ally's equipment spent on it never breaks it). The double-edged
  form has its decision built in and was undersold on 15 October.
- **The second in-fight shield regen** beside the Goshawk's (the first hole below), read by
  pattern in context (Ryan, 16 October): its regen is paid only while it attacks every round,
  so it cannot turtle; the runner's stall mark (past 60 rounds) reads it.
- **Showing it**: a count chip like the Paradox's with the next threshold, loud, and a debug
  switch that runs it.

**Since then, on main** (to 20 October)

- The action-economy row (section 5, Ryan, 20 October): counters count blows, not spends, so
  strikes and area pieces are their fuel. The briefs README's table lists the combo under
  "spends counted", and the Kestrel session parts the tempo machines by currency with the line
  frame on blows (`kestrel_gun_platform.md`, its fifth round). The row makes cantrips combined
  entries before Rapid ones, so the 15 October note above (cantrips as the combo's fuel) is
  superseded: the fuel is blows.
- Kestrel's interceptor (tier one; Ryan, 18 October: "a great tier-one design") spends twice a
  round, and its brief raised that tempo was this machine's claim. The shapes part: a combo
  that a weaponless turn breaks, against two spends a round.
- Ryan, 19 October: Aphelion needs a defensive tier one (the to-do's line for this session).
  With the Baboon going up and this machine a duelist, Aphelion's tier ones as proposed (the
  Stingray, the line frame) hold no body.
- The Arsenal's Minos is drawn as a corrupted Gundam (Ryan, 12 October: "Two Gundams are fine,
  since this is the stereotypical dark one and not the hero frame"), so the two silhouettes
  must part (Ryan's).
- The heat numbers here re-scale with the stock pass's heat scale (1 to 20, proposed in the
  Kestrel session on 20 October, on main since that branch merged on 21 October).

**Ryan's calls on the first round** (20 October), in his words:

- "Every blow counts, and we will follow the new conventions when we pick this up again."
- "Don't tag the shield beam now, that's the model session's job."

What they settle: the combo counts every blow its weapons land, strikes included, so strikes
and area pieces are its fuel, as the action-economy row has it; the session resumes under the
conventions decided since 15 October (as Claude reads them: the action-economy row, Rapid's
limiter, a Suppress priced by a gate, the overlap rule, random that adds against random that
takes away); and the shield's tag waits on the line frame's model session, not this one.

**The bench** (each with what set it aside)

- Counting spends: too slow to see in fights of these lengths, and the action-economy row
  points counters at blows.
- Counting each foe a spend damages (the hopper's rule): Ryan's call, 20 October, every blow
  counts.
- A combo that lasts the battle: it reaches 20 on spends, but one bad roll wipes a battle's
  work, and the team would spend every reroll guarding it.
- A Rapid parry: free, so no decision; and the 20 October rule on a Rapid shield's tier.
- 1 cooling and 1 shield a stack: too small to see on a phone.
- The double-edged form (stacks raise damage and lower defence, broken by choice): Ryan finds
  it less Gundam, and the Sparrowhawk has the shape; its built-in decision is the review's
  point in its favour.
- Chain on the saber: Chain's rework.

**Ryan, 21 October** (another session, on stores): "Combo (for line frame): design is unfinished,
but I suspect it will be a smooth bar with ticks for each power boost. The powers it grants will
be one or more active buff effects." So the combo is a store (the bible's row on stores): a
capped resource no Silence or Purge touches, its bar a smooth fill with a tick a power boost,
and what it grants buffs, slept by a silence and silenced a turn by a purge.

## Open for the session

Ryan settled what one hit is on 20 October (every blow counts) and sent the shield's Beam tag
to the model session; what stays open:

1. What breaks it: a turn ended without a weapon spent (Ryan's), or only equipment spent (the
   review's alternative, so the die never takes the ramp away).
2. The thresholds' numbers against these fight lengths, now that strikes and area pieces climb
   the count, and the cooling kept under the weapons' heat.
3. The parry: a self-Barrier, cooldown 2, keeping the combo (proposed), or Rapid against the
   20 October tier rule.
4. The saber's keyword now that Chain is being reworked; its scaling with the count later.
5. Its designation in Aphelion's shape ("Flight n" and a job; "Frame" is Aphelion's word).

## Holes already raised

- It would be the second in-fight shield regen; the Buzzard's was kept safe on one chassis, and
  with the Puffin beside both a team can out-sustain a pack (the runner marks stalls past sixty
  rounds).
- Once the combo is up, the enemy breaks it: the Waste's Disabled attacks the die,
  and the Peak's Scorched runs its beams hotter than the stacks cool.
- The count must show on the machine, and the die's heat must show the cooling it has earned.
- At tier one it is Aphelion's third tier one (its second once the Baboon moves up), which
  varies its tender deal, and the first Aphelion machine with a locked shield.
- The rifle as stock (raised 15 October, folding the proposal in): a tier one stocks only
  basics beside its locked pieces (`docs/rules.md`, tiers), so a stocked rifle is a basic the
  player may replace, while Ryan counts three Beam pieces at the start ("it starts with 3 of
  them", 14 October). How does the rifle start, and does the count hold?

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Aphelion row, content planned, and this brief
retired (cantrips are the stock pass's, as combined entries, since the action-economy row of 20
October).

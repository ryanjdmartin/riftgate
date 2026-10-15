# Brief: the line frame, the Gundam homage (proposal reworked into a direction)

The session designs Aphelion's Gundam homage as the most tempo-oriented damage dealer in the
game: a duelist whose combo builds a rhythm until something breaks it. "The line frame" is a
working label; the name and the look are Ryan's.

**Status**: direction (14 and 15 October); the proposal was unfinished. **Maker**: Aphelion.
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
  brake. Small pieces at tier two or three, the combo's fuel.

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

## Open for the session

1. Per-stack payoffs or thresholds, and what the thresholds pay (cooling, shield regen,
   damage).
2. The shield: keeps the combo, or Rapid; the parry as a self-Barrier whose riders land (Ryan),
   and its cooldown.
3. The saber, the rifle and the Beam tag (Ryan: Beam sets it up for a later synergy).
4. The double-edged alternative, which Ryan finds less Gundam.
5. Its designation in Aphelion's shape ("Flight n" and a job; "Frame" is Aphelion's word).

## Holes already raised

- It would be the second in-fight shield regen; the Goshawk's was kept safe on one chassis, and
  with the Puffin beside both a team can out-sustain a pack (the runner marks stalls past sixty
  rounds).
- Once the combo is up, the enemy breaks it: the Waste's Disabled and Scrambled attack the die,
  and the Peak's Scorched runs its beams hotter than the stacks cool.
- The count must show on the machine, and the die's heat must show the cooling it has earned.
- At tier one it is Aphelion's third tier one, which varies its tender deal, and the first
  Aphelion machine with a locked shield.
- The rifle as stock (raised 15 October, folding the proposal in): a tier one stocks only
  basics beside its locked pieces (`docs/rules.md`, tiers), so a stocked rifle is a basic the
  player may replace, while Ryan counts three Beam pieces at the start ("it starts with 3 of
  them", 14 October). How does the rifle start, and does the count hold?

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Aphelion row, content planned, cantrips as a
stock-pass item if Ryan takes them, and this brief retired.

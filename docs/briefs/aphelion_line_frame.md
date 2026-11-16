# Brief: the line frame, the Gundam homage (proposal reworked into a direction)

<!-- hangar: {"kind": "chassis", "maker": "aphelion", "tier": 1, "status": "direction", "slot": true, "name": "the line frame"} -->

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
  they need the limit raised in the Polar Bear's brief (`minerva_armadillo.md`) before they are
  built. Ryan's proposal there (15 October) is heat paid every spend; Claude's earlier one, a
  Rapid reroll never landing on an entry already spent this round, is its alternative.

## The design as proposed (11 to 13 October)

From the Aphelion chat, written up on 13 October for the batch evaluation. The bible's
Aphelion row records Ryan's call of 13 October: that session went off the rails, and its
proposal is "a list of ideas, not a design to defend". Everything here is Claude's unless
marked Ryan's, and the numbers are the proposal's placeholders.

- **The frame**: tier one, medium, a walker (Ryan's), move 30. Its locked pieces and its mounts
  are his of 16 November (its own section, below): transforming weaponry in its forearms, and
  the other weapons on the shoulders or the chest pectorals. They take the place of round one's
  locked saber, round two's kite shield on the forearm and the rifle stocked in a hand mount.
- **The look**: his of 16 November too, below. Round one's (a V-crest on a small head, chest
  intakes, the kite shield, saber hilts on the backpack, part of what he was "fine trying" on 12
  October) was built as the first look test (`docs/looks/aphelion_line_frame.png`, 15 November)
  and he read it as "too stocky, and too much like a bad clone of the RX". The homage lives in
  the silhouette only, and it moves as every machine does (the bible: "MechWarrior or Star Wars,
  not Gundam or Evangelion").
- **Engine**: components still carry the old internal filing tags and only `melee` is read,
  though a `tag_<tag>` condition already works (`docs/rules.md`, tags); the stock pass assigns
  the new tags, Beam among them.

The bench, the forms set aside:

- Gaining shield gives a stack of Empowered (+5 damage a stack, fading a stack at the
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
- **A break the die forces** loses the ramp through no choice of the player's. It is rare with
  three weapons on the die and the team's three rerolls. The alternative for Ryan: only spending a shield, a
  vent or a buff (the parry excepted) breaks it, and a turn with no weapon showing holds the count.
- **Decision density.** Once the combo is up, its payoffs take away the reasons to break it,
  and in the Marsh nothing attacks the die or heats it (the Meadow drains rerolls, the Waste
  disables, the Peak scorches and corrupts), so there it is a stat line that grows. The
  decisions left are the team's: rerolls spent on its die rather than an ally's, and allies
  cooling or shielding it (an ally's shield, vent or buff spent on it never breaks it). The double-edged
  form has its decision built in and was undersold on 15 October.
- **The second in-fight shield regen** beside the Buzzard's (the first hole below), read by
  pattern in context (Ryan, 16 October): its regen is paid only while it attacks every round,
  so it cannot turtle; the runner's stall mark (past 60 rounds) reads it.
- **Showing it**: a count chip like the Paradox's with the next threshold, loud, and a debug
  switch that runs it.

**Since then, on main** (to 20 October)

- The action-economy row (section 5, Ryan, 20 October): counters count blows, not spends, so
  strikes and area pieces are their fuel. The briefs README's table lists the combo under
  "spends counted", and the Kestrel session parts the tempo machines by currency with the line
  frame on blows (`git show d84ad16:docs/briefs/kestrel_gun_platform.md`, retired with its engine on 30 October, its fifth round). The row makes cantrips combined
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
limiter, a Suppress priced by a gate, the overlap rule); and the shield's tag waits on the line frame's model session, not this one.

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
  it less Gundam, and the Kite has the shape; its built-in decision is the review's
  point in its favour.
- Chain on the saber: Chain's rework.

**Ryan, 21 October** (another session, on stores): "Combo (for line frame): design is unfinished,
but I suspect it will be a smooth bar with ticks for each power boost. The powers it grants will
be one or more active buff effects." So the combo is a store (the bible's row on stores): a
capped resource no Silence or Purge touches, its bar a smooth fill with a tick a power boost,
and what it grants buffs, slept by a silence and silenced a turn by a purge.

## Ryan, 16 November: its own identity, and transforming weaponry

His words, on the first look test: "The line frame is too stocky, and too much like a bad clone
of the RX. It needs its own identity. Let's go with a transforming type of weaponry for its
locked pieces: it has fists (use the baboon/nemesis as a base), that retract and get replaced
with guns for its beam rifles. It has beam blades mounted on its forearms, that can turn on and
off. It can project a shield made of light from each forearm, like a buckler (the "beam
shields"). It cycles through weapon combinations as it idles and as it fights. Other weapons are
mounted either on the shoulders, or on the chest pectorals. A small winged backpack that it uses
to boost along the ground, not true flight or hover. The rest is up to you, it's a homage not a
clone, remember, so maybe pull from a few different main character Gundams and take some from
each."

What it settles: the locked pieces are built into the forearms, the same on both arms, a beam
rifle (the fist gone and a gun in its place), a beam blade and a beam shield; the hardpoints sit
on the shoulders or the pectorals, and no hand is a mount; it boosts along the ground on a small
winged pack and neither flies nor hovers; the homage draws on several lead machines and copies
none. What it leaves to the session: how the three sit on the die and what each does. A beam
shield is a shield gain or a block by another name, which the reboot makes dear, so its rule
says which (`CLAUDE.md`, the reboot's expectation).

**The second look test** (`docs/looks/aphelion_line_frame2.png`, the `SHEET2` of
`tools/lowforge/looks/line_frame_looks.py`; look tests, never content until the chassis lands).
A lean frame with heavy forearms: 91 to the helm where round one stood 78, 46 across the
shoulders where it was 62, its hips at 59% of its height, a stance of 24; bare dark upper arms
and a bare inner frame at the waist, so the gauntlets, 23 long, are the arms' weight. Its head
is a small helm with a visor band, dark cheeks and chin, and one red blade of a crest swept up
and back. The pack is small, two short drooped wings inside the shoulder line over two boosters
canted down and back, a booster on each calf. One builder takes a state for each arm, and the
sheet has four as baked poses:

- **Fists, at rest**: the Nemesis's fist at each wrist, thumb up.
- **Rifles out**: the fists gone, a shrouded barrel with a lit lens out of each wrist.
- **A blade and a buckler**: a beam run 37 past the hand off a rail on top of one forearm; off
  the other's outer face a hexagon of light 23 across.
- **Twin blades**.

Four placeholder mounts: a rack and a dish on the shoulder tops, a barrel and a twin barrel in
the pectorals. The cues taken, each from a different lead machine's vocabulary: forearm blades,
forearm beam shields, wing binders, a bare inner frame. Kept out: the V-fin, twin eyes, a red
chin, chest intakes, skirt armour, red feet, any third colour. On the way the pack's wings rose
beside the head and read as a V-crest from head on, so they came down and shrank. His to judge:
the crest is a thin upright bar from head on; the shoulder mounts are boxy from above; the
blade arm foreshortens at the codex angle. Nothing animates: the cycling he asks for is a
model's acts and its firing, judged running once it is one.

His notes on it, the same day: "Line frame is a much better take. Forearms are way too big and
long. The beam rifles can be smaller to let the arms shrink, since they can be custom geometry.
Blades to the outer faces of the wrist. Shield closer to the classic Gundam shield shape.
Backpack can use another pair of wings and reconfigure it so that it would boost forward, not up
- it's a dash, not a hover. I think scrap the chest ports, and maybe add a mount to the side of
the head instead." So the mounts are the two shoulders and one on the side of the head, three
in all, and the chest is clean; the pack dashes along the ground. The third round
(`docs/looks/aphelion_line_frame3.png`, the module's `SHEET3`) takes each note. The forearms
15 long where they were 23, about 7.5 across where they were 11, the fist scaled with them; the
rifle a compact shroud about 11 past the wrist with a lit lens (round two's ran 18); each blade's
emitter on the outer face of its wrist, the beam 33 past it along the outside of the hand; the
beam shield a kite of light 17 across and 30 tall, chamfered at the shoulders and closing to a
point, upright with its point down, from an emitter nearer the elbow, the shape alone and no
emblem; the pack's two pairs of flat wings swept back about 50 degrees over two boosters with
their nozzles straight back, the calves' boosters back too, the wings hidden behind the
shoulders from head on. The mounts: a slim barrel on the right shoulder and a twin barrel on the
left, each on a small ring, and a small rack pod on the right side of the helm (the right, so
the codex and skirmish angles show it); the chest plain armour. Five states as baked poses:
fists at rest, rifles out, a blade and a shield, twin blades, a rifle and a shield. On the way
the first wings, long and narrow, read as spikes, so they gained depth and a slight tilt. His to
judge: the hands are small at rest, the forward blade shows as a stub from head on, and from
behind the shield's top shows over the shoulder.

## Open for the session

Ryan settled what one hit is on 20 October (every blow counts) and sent the shield's Beam tag
to the model session; what stays open:

1. What breaks it: a turn ended without a weapon spent (Ryan's), or only a shield, a vent or a buff
   spent (the review's alternative, so the die never takes the ramp away).
2. The thresholds' numbers against these fight lengths, now that strikes and area pieces climb
   the count, and the cooling kept under the weapons' heat.
3. The parry: a self-Barrier, cooldown 2, keeping the combo (proposed), or Rapid against the
   20 October tier rule.
4. The saber's keyword now that Chain is being reworked; its scaling with the count later.
5. Its designation in Aphelion's shape ("Flight n" and a job; "Frame" is Aphelion's word).
6. Its look: his read of the third look test (16 November), or another round.
7. Its locked pieces on the die (his direction of 16 November): how the rifle, the blade and
   the shield sit there, what each does, and what the cycling reads.

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

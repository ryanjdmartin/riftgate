# Proposal: Ryan's chassis ideas of 4 November

Ryan posted a list of chassis ideas in chat on 4 November, outside any session: seven for
Aphelion, six for Minerva, and two Arsenal homages that share their verbs with Aphelion pieces.
This file holds his words and Claude's first round on them. For each idea it records what the
rules, the bible and the code already say, the holes, the questions and Claude's leans, for him
to move.

**Status**: proposal, Claude's first round (4 November). Nothing is decided and nothing is built.
**Read first**: `docs/briefs/README.md` (Ryan's taste, the tiers, the action economy, the
benches); the bible's rows on retaliation and thorns, Barrier and Ward, Armoured, Purge, the stun
and the primers (section 5), Chain (section 5's weapons), and in section 7 the untyped
hardpoints, the Armadillo, the makers, the names and the transforming chassis.

How to read it: Ryan's words are quoted and dated, and everything else is Claude's. Names,
numbers and looks are his, and every number here is a placeholder. The echidna's new shape is
recorded in its own brief, `docs/briefs/minerva_hedgehog.md`, which has been its home since 15
October. The time-shifter's idea stays on the briefs README's Aphelion bench, and this file
notes only what has changed since. Once Ryan marks it, each machine he takes gets a brief (or
goes into the existing one), its bible rows and its content as planned. This file retires when
those decisions are rows and briefs.

## Ryan's list, in his words (4 November)

> New chassis ideas:
>
> Aphelion:
> Hitting an enemy with a weapon or equipment inflicts Static 1
> Static: Debuff, When damaged, deal 1 damage per stack to self and surrounding units in a
> Splash pattern, then reduce Static by 1. Static conducts Chain just like Shock.
>
> Aphelion flagship:
> Mode changer (macross), tier 3:
> In Flight mode, attacks have Primed 2. When shifting to Flight mode, other allies gain 1
> overcharged.
> In Gerwalk (hover) mode, attacks have Charged. When shifting to Gerwalk mode, other allies
> gain shield regen for 2 turns.
> In mech (ground) mode, attacks have Chilled. When shifting to Mech mode, allies gain 1
> armoured.
>
> Minerva: tier 1 tank
> Every hit lures. Needs a hook on how to stay alive. Maybe something like, "every hit taken
> grants 1 armoured until end of turn" so it works well at soaking multiple hits but still
> bleeds on the first couple.
>
> Aphelion/Arsenal:
> Plants cryo and somehow blows the cryo for damage, adding Suppress if enough stacks
> consumed. Arsenal version more of a Frost demon/god homage.
>
> Minerva: A cryo synergy party defense, units with Cryo deal 1 less damage or something.
> Possibly Cryo is applied on shield or hull hit, or some other more party-wide trigger to be
> unique. Mastodon/Mammoth type unit.
>
> Aphelion: time-shifter
>
> Aphelion: Barrier+Ward support. Have to make it interesting but not broken.
>
> Aphelion: Cannot mount weapons. enemies hit by its equipment gain a debuff that explodes
> after their action, dealing 1 damage per stack of buff and debuff on them, Purging them of
> all buffs and Cleansing their debuffs.
>
> Minerva: Some kind of drill-tank mole machine
>
> Minerva: Shield-basher, deals bonus damage per armour it has then loses all stacks of
> armoured
>
> Minerva: Immune to all buffs and debuffs. Can pass this to an ally using a component, and
> take it back. When receiving the passive, all buffs and debuffs are immediately removed, so
> you can't buff and then re-protect on top.
>
> Aphelion and/or Arsenal: a shock-synergy unit. Arsenal is some kind of thunder demon/god
> homage.
>
> Minerva Echidna: new shape idea, debuff foes that strike it so that they damage themselves
> after they act. So it's not immediate thorns damage, it's delayed. Locked component can
> spread or synergize the debuff to make it interesting.

## What touches several of them

### Words that have moved

- **"Overcharged"** has been **Empowered** since the randomness pass (2 to 4 November: Overcharged
  and Kindled were both named Empowered). Each stack is +1 damage, and the stacks halve at the
  round's end. The engine id stays `overcharged`.
- **"Chilled"** is not a term. The Cryo primer is **Supercooled** (the primers row: a machine buff
  whose weapons lay one more Cryo a strike), so this file reads Chilled as Supercooled.
- **"Shield regen"** is **Regenerating**, the machine's version: shield at the start of each round
  it names. The Storm Petrel's lure grants it today.
- **"Static"** is already a name in the vocabulary. The passive trigger `static` ("Passive trigger.
  Always on.") uses it. A keyword and the status it lays share a name (section 6), and the
  keywords list shows terms by name. So the debuff needs an id of its own (`static_charge`, say),
  and then either the debuff takes another word or the trigger is renamed. The trigger is engine
  vocabulary, so "Always on" would do.

### The counts

Ryan's counts (14 to 18 October) are about ten machines a city maker, split 3-5-2 or 4-4-2. He
called eleven too many for Wainwright & Sutler. If every idea here is taken:

| Maker | Built | Briefed or benched | New on 4 November | All |
|---|---|---|---|---|
| Minerva | Honey Badger 1, Armadillo 1, Wild Boar 2 | the echidna 2, the siege battery 3, the battlecruiser 3 | the lure tank 1, the mammoth, the mole, the shield-basher, the immune one (tiers open) | 11 |
| Aphelion | Stingray 1, Baboon 1 (2 proposed) | the line frame 1, the jellyfish 2, the Carrier 3; the time-shifter and the aura-shifter on the bench; the Zoids walker, its maker open | Static, the Macross 3, the Cryo detonator, the Barrier and Ward support, the status detonator, the shock unit | 11 to 14 |
| the Arsenal | Nemesis 2, Ammit 3 | Misharu 2, the Onryō 2, Mastema 3, Minos 3 | the frost figure, the thunder figure | 8 |

Ryan set a target the same day: ten a maker, for now. The section "Ten a maker", below, works
through it. The cuts there serve his target, never the work already done on a machine.

### Three Minerva ideas react to being struck

The three ideas:

- The lure tank hardens a point for every hit it takes.
- The mammoth may lay Cryo on whatever strikes it.
- The echidna's new shape gives its strikers a debuff that hurts them later.

Retaliate, the Retribution Thurible's buff, already Shocks a foe that strikes bare hull. The
bible's retaliation row (section 5) allows a debuff on the striker. Its thorns line governs
damage paid back: "a thorn is balanced only by a drawback it carries and never rides a
megatank." The three ideas part by payoff:

- the lure tank gets armour for itself;
- the mammoth gives the team a weaken and cooling;
- the echidna deals damage.

The echidna is the only one the thorns line applies to.

### Grants to the whole team

The Macross's shifts hand every ally Empowered, Regenerating or Armoured. The mammoth's Cryo
weakens every foe's blow on every machine. Two records stand against grants like these:

- Ryan's taste, in the briefs README: "giving the team tank stats is just as toxic as taking all
  the blows".
- The Armadillo's row refused "team armour or a team shield on opening (an unkillable team by
  another name)".

One precedent passed, and its row draws the line exactly: the Swallowtail's Mooring Screens, an
Every Ally shield at tier three. Its row reads: "the team shield, honest by its number, where
Armoured on all hands four machines the dearest stat and a Barrier on every ally breaks the
Barrier row." (The screens' gate, "only while none has acted this round", belongs to their
charged form, which Phases every ally.) So a shield number for the whole team has passed at tier
three, and Armoured for the whole team has been refused there. The mammoth's grant differs in
kind. It is a debuff the team must lay and keep, and any weapon hit cashes it away.

### Armour at or over the tier's blows is immunity

Section 12's Armadillo question found that flat armour at or over a tier's blows is immunity at
any number, and tier one's rank and file hit for 2 or 3. A tank's base armour of 2, plus a point
for each hit it takes, is immune after the first hit at tier one. So "still bleeds on the first
couple" holds only against bigger blows.

Claude's lean in that question is a floor of 1 past armour on a blow that reaches the hull, on
both sides. With that floor, the lure tank reads as Ryan describes at every tier. Without it, the
tank's base armour wants to be 0 or 1, and its passive becomes its armour (the toughness row: a
tank is tough "through its numbers and passive").

### Names on the reserved list

The bible's names row and the validator refuse a chassis named for a machine from BattleTech,
Heavy Gear, Warhammer 40,000 or Halo (`content/reserved_names.json`). These obvious picks are on
that list:

- **Mammoth**: Heavy Gear's strider and Halo's Mammoth.
- **Mastodon**: BattleTech's, Heavy Gear's and 40K's.
- **Valkyrie**: BattleTech's and 40K's. It is also the VF-1's own nickname.
- **Hedgehog**: BattleTech's. The echidna is free.
- **Raijin, Thor, Zeus and Ymir**: all BattleTech's. These are the obvious thunder and frost figures.

Skaði and Surtr are the Summoner's summons, so they belong to the invasion's side. The Arsenal
names its machines for figures who punish, never for war gods. Every name is Ryan's.

## Ten a maker

Ryan, 4 November, after the first round: "I want to target 10 per maker, at least for now. How
do you see that shaking out with these specs? Anything to merge, move to another maker, or cut
in favour of another missing hole/niche?" Ten for each of the five makers is fifty, his "roster
of up to 50 units" of 18 October. What follows is Claude's shake-out as his calls on it
have moved it.

**Ryan's calls on the shake-out** (4 November), in his words:

- "Cut shield-basher as a unit, but add it as a potential minervan tier 3 weapon or module -
  bonus damage equal to armour, then armour zero until end of round."
- "Mole needs a better hook than 'ignores armour' but we can work on that later."
- "Armadillo moves to T2, and either Boar or Mole will move down."
- "The two slots you pegged for aphelion aren't relevant. What is the current brief of the
  Jellyfish? its very WIP. If the status detonator idea folds into it, then i'd rather flesh out
  the time-shifter support since that's an entire unexplored area."
- "Arsenal 10th can wait until its many unrefined ideas are settled."

The two moves to the Arsenal and the other merges stand as Claude proposed them, unanswered.

**Kestrel and Wainwright & Sutler are already at ten**, so nothing moves to them. Kestrel has
eight decided plus the Magpie and the Snowy Owl, both "completely unspecced other than general
directions and names" (Ryan, 5 November). Of the ideas folded or moved here, only the Cryo
detonator fits one of those slots: Cryo as the Snowy Owl's cold (its brief). Ryan, 5 November:
"assuming we take the cryo direction with the owl - which makes a lot of sense - that leaves one
open kestrel slot (Magpie, or other), one aphelion slot, and one Arsenal slot". That count holds
while the Arsenal's frost figure keeps the blow; the roster then stands at 47 named and 3 open. Wainwright & Sutler is 3-5-2 with the gunship.

### Minerva: eleven to ten (3-5-2)

| Tier one | Tier two | Tier three |
|---|---|---|
| Honey Badger, the lure tank, the Wild Boar or the mole | the Armadillo, the echidna, the mammoth, the immune one, the mole or the Wild Boar | the siege battery, the battlecruiser |

- **The shield-basher is cut as a unit** (Ryan's call) and becomes a potential Minerva tier-three
  weapon or module: bonus damage equal to armour, then armour zero until the end of the round.
  Its notes are under "The shield bash" below.
- **The Armadillo moves to tier two** (Ryan's call), which answers section 12's Armadillo
  question. Either the Wild Boar or the mole comes down to tier one. The open point is timing.
  Moved now, Minerva's tier-one deal would be the Honey Badger every time until the Boar or the
  mole comes down, or the lure tank lands. The Baboon's move was held for the same reason, its
  maker's deal left fixed. So the content, the bible's Armadillo row and section 12 move either
  now or with whichever machine comes down: Ryan's word.
- **The mole keeps its slot with its verb open.** Ryan: it "needs a better hook than 'ignores
  armour'", later. Claude's breach lean is withdrawn.
- **The mammoth and the echidna part by trigger.** In Ryan's list both lay a debuff on whatever
  strikes them. Claude's lean: the mammoth's frost comes from a blow on any ally's shield (his
  "some other more party-wide trigger to be unique"), and the echidna's quills from a blow on its
  own hull. One reads the team's shield layer, the other its own wound. With frost that common,
  the team's cooling is the thing to watch (the Armadillo's row names the all-in cooling team
  among the things that would reopen it).

### Aphelion: fourteen at most, down to ten (4-4-2)

| Tier one | Tier two | Tier three |
|---|---|---|
| Stingray, the line frame, Static, the Barrier and Ward support | Baboon, the jellyfish, the time-shifter, one open | the Carrier, the Macross |

- **Two move to the Arsenal.**
  - **The Zoids walker.** Ryan, 12 October: "The kill-turning-rapid as a feline/canine hunter
    mauling feels very Arsenal. Maybe that's a sign." Aphelion's row also keeps cats and wolves
    out of its names. Its round-one verb, a kill that lets it act again, is the Kite's Reset
    now, so it moves with its verb open.
  - **The Cryo detonator**, as the Arsenal's frost figure. Consuming a status for a blow is the
    Arsenal's Backdraft Charge shape, and it fits Claude's line of 22 October, "the Arsenal
    consumes statuses where Aphelion reads them". Aphelion keeps Cryo through the Macross's
    Battroid mode and the slottable Cryo setter the to-do gives it.
- **Three merges.**
  - **The shock unit** is the Static machine.
  - **The aura-shifter** becomes the Macross's shifts.
  - **The status detonator folds into the jellyfish**, unrefined (Ryan, 4 November: "Let's say
    we're folding the unrefined detonator concept into the Science vessel, yes"). The
    jellyfish is the Science Vessel homage, and StarCraft's Science Vessel is unarmed; its EMP
    Shockwave strips shields and energy. So "cannot mount weapons", and a blast that purges and
    cleanses, are its homage made concrete, and Aphelion keeps one Purge machine. Its notes are
    in the jellyfish's brief.
- **The defensive tier one is the Barrier and Ward support**, a protector at tier one, as the
  Puffin is Kestrel's. Its identity should lean on the Barrier half: every domain throws a big
  blow, while the Ward's worth waits on the domains' riders (its row), a dependency the immune
  one shares. With it in place, the Baboon's move to tier two is free; the hole its brief
  recorded was Aphelion's tender deal.
- **The open slot stays open.** The detonator's fold freed it, and Ryan is "keeping the
  unrefined time shifter" (4 November) as one of the ten. The time area may take the slot when
  the time-shifter is fleshed out ("an entire unexplored area"). The two candidates Claude pegged
  (the reinforcement phase, the long guns) are struck.

### The Arsenal: six to ten (0-5-5)

This applies if ten holds for the capital's maker too, which has no tier ones and is the
Council's trickle. If it doesn't, the Arsenal stops at nine or fewer.

| Tier one | Tier two | Tier three |
|---|---|---|
| none | Nemesis, Misharu, the Onryō, the Zoids walker, the frost figure | Ammit, Mastema, Minos, the thunder figure, one open |

- **The frost figure** is the Cryo detonator: one machine, the Arsenal's.
- **The thunder figure is a smiter, not retribution.** Claude's first-round lean for it was
  Retaliate on every ally. That is the Onryō's trigger (a curse on whoever wounds the team) and
  close to Misharu's (a foe that breaks a shield is punished), so the Arsenal would hold three
  machines punishing the striker. The first round's frost form, cold laid on whatever strikes
  the team, was the same trigger again, and the mammoth's too. So the thunder figure is Chain's
  capstone at tier three. The rule it bends: its arcs carry its blow's whole number. Its locked
  piece is an area Shock setter: the bench's bell tower toll, a big Indirect blow with Spread,
  Penetrate and Shock, set aside on 11 October for the four briefed machines with no other
  reason recorded. That toll is also the Spread Shock setter the to-do says Chain still lacks.
  The thunder figure feeds Aphelion's Static and is fed by it.
- **The tenth waits** until the Arsenal's many unrefined ideas are settled (Ryan's call): the
  four briefed machines, the two figures and the Zoids walker.

## Aphelion

### Static

Ryan's words are in the list above.

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

1. **Which damage sets it off.** "When damaged" covers a team blow, an area's blow, an arc, a
   spill, a mine, a Burning or Vitriol tick, and the discharge itself. If a discharge can set off
   Static, a foe's own share sets it off again: Static 3 deals 3, 2 and 1 to the foe and to each
   neighbour from a single hit. Two neighbours that both carry Static set each other off.
   Claude's lean: a discharge never sets off Static, on any foe. Then one damage is one discharge,
   and the forecast stays readable. Chain becomes what sets the field off: each arc is damage, so
   a Chain hit discharges every Static foe it reaches once. The alternative lets the cascade run,
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
   - A kill by a discharge counts for the spender; the on-a-kill trigger already counts arcs and
     spills.
   - A foe that is both Shocked and Static takes one arc, not two.
   - A Shocked conductor keeps its Shock, but a Static one spends a stack to its arc. So a Static
     field is a charge that gets spent, never the standing charge the Chain row describes.
5. **The name** (see "Words that have moved").

**The bench.** Static as a keyword on pieces rather than a passive: then the Stingray would deepen
it, and a keyword can still be added later. Splash 1 on every weapon: that is area by strength,
which the area row refuses.

### The mode changer, the Macross homage (tier three)

**In today's engine.** The three riders are the three primers, each a machine buff today:

- **Primed**: each blow leaves a Burning stack for each Primed stack.
- **Charged**: the machine's weapons fire with Shock.
- **Supercooled**: one more Cryo a strike.

A mode would grant its primer as a form does. The grant stands while the mode does, and a Purge
puts it to sleep until the player's turn. Nothing grants Charged or Supercooled yet ("capacitor
pieces are content to propose", the primers row), so this machine would be their first carrier.
The shifts grant Empowered (a point a stack, halving at the round's end), Regenerating's machine
half, and Armoured (until the round's end).

A form-change system has existed since the Armadillo. It has two forms: spending a piece on itself
changes the form, and each form wears its chip on the pieces that change it. Three forms is the
next step. This machine reopens the bible's pin on transforming chassis (section 7: "One reads
only with a form-change system, which could be built and is not a priority"). Aphelion's profile
already names "variable geometry".

**The holes.**

1. **What shifts it.** Ryan's list says what each mode does, not how the machine changes mode.
   There are three shapes:
   - **The Armadillo's**: the kind of entry it spends picks the mode. This breaks on its own
     riders. A weapon spent while it shifts fires in either the mode it leaves or the one it
     enters, so one mode's rider always rides that weapon.
   - **A piece a mode**: three locked pieces, each its mode's entry and none of them a weapon (a
     vent, a shield, a buff). Spending one shifts the machine to that mode. The die shows which
     modes are open this round, the team's rerolls steer it, and a shift is the machine's action
     for the turn, which prices the grants. A tier three may lock this much (the Swallowtail locks
     four).
   - **One shift piece** that steps through the modes in order: Fighter, GERWALK, Battroid, and
     back. GERWALK is the halfway form, so this order is the homage's. It would be Rapid on a
     cooldown of one: shift, then act, once a round.

   Claude's lean: a piece a mode, because it prices the grants in the machine's own turn. The
   Rapid shift piece makes shifting nearly free, so every round would carry a grant to the whole
   team.
2. **The grants are team stats, and the records split them.** The Swallowtail's row passed a
   shield number for every ally ("the team shield, honest by its number") and refused Armoured for
   every ally ("Armoured on all hands four machines the dearest stat"). The Armadillo's row
   refused "team armour or a team shield on opening". Read against those:
   - GERWALK's Regenerating is a shield number over two rounds, in the honest team shield's
     family.
   - Fighter's Empowered is the cheapest: a point on each ally's blows, for this round only.
   - Battroid's Armoured on every ally is the form the Swallowtail's row refused.

   Claude's lean: keep Ryan's "allies" for GERWALK and Fighter, priced by the shift being the
   machine's turn and never granting twice in a round. Battroid's grant needs another form: one
   ally armoured (the shift spent on it), a shield number in place of the armour, or Ryan
   overruling the row in the open. Read it all on the runner. This makes it the first team aura
   read in the game, the one the aura-shifter on the bench asked for (Ryan, 19 October: "an
   all-in aura support, maybe, with shifting auras for the team").
3. **Each grant pays at a different moment.** Empowered 1 halves to nothing at the round's end, so
   the Fighter grant pays only before the allies act. Regenerating's shield arrives next round.
   Armoured covers this round's enemy turn. So each mode asks the turn to be played in a different
   order, which is a fair decision for a tier three.
4. **Whom Battroid armours.** Fighter and GERWALK say "other allies"; Battroid says "allies". Does
   Battroid armour the machine itself?
5. **The riders' weights.** Primed 2 is the heaviest: two Burning a blow, each pair worth 3 damage
   over the foe's next two actions. Charged is a setup the team cashes. Supercooled is the team's
   cooling. That asymmetry is fine, to be read on the runner.
6. **The map.** Fighter, GERWALK and Battroid are a flyer, a hovercraft and a walker. A chassis has
   one way of moving today, and the ways of moving are the map's only crossing rule: a flyer
   crosses walls, and a hovercraft crosses water at one. The mode the machine stands in could set
   how it crosses. That is the strongest homage and a real map decision. Its prices are a new rule
   on the map, and the caution of the row that a map action buying a fight buff is no condition,
   if the map also sets the fight's opening mode. Claude's lean: modes in the fight only for the
   first cut, and a flyer on the map.
7. **Its place.** "Flagship" could mean Aphelion's capital ship, the slot the Carrier holds ("the
   capital ship that it seems like every maker is going to end up getting"). It could also mean a
   second tier three beside the Carrier, which Ryan's counts allow. Claude's lean: the aura-shifter
   folds in here either way, since its idea is this machine's shift grants.
8. **The look.** Kestrel's Needletail has two modes in its look queue (wings that fold up to hover,
   or a tail-sitter on its boosters), so the two silhouettes must part, as the two Gundams must.
   The line frame is Aphelion's other humanoid homage.

### The Cryo detonator (Aphelion, or the Arsenal's frost homage)

**In today's engine.** This is the Backdraft Charge's pattern with Cryo. The Backdraft is the
Arsenal's, tier two: it consumes Burning for a point a stack, and its Suppress is gated at two
stacks. Consuming and gates are both built. Cryo is Aphelion's lean (Ryan, 28 October), and
Minerva's Armadillo lays it.

**The holes.**

1. **Cryo does not build up.** Any machine's weapon hit spends every stack for cooling. So Cryo
   piles up only on a foe nobody shoots: from equipment, which spends none, or from a strikes
   gun's riders, which land after the hits. Planting and then blowing is a team sequence: hold
   fire on the frosted foe until the detonator goes. That is a decision, and it is the one this
   machine asks for.
2. **The cooling.** If the blow eats the stacks, Cryo's own cash (2 heat a stack to the hitter) has
   nothing left. The trade is then the team's cooling for damage and the stun, a real price (the
   stun row: a self-sacrifice, a setup). If the blow gets both, the damage is free. Claude's lean:
   the trade.
3. **A component or a chassis.** As a piece, it is the Backdraft Charge's frost twin, a repeat. As
   a chassis, every weapon it fires consumes Cryo, which changes what a kind of piece does (the
   identity test), and its own planter makes the setup. Claude's lean: the chassis, with its
   planter locked. The planter could be the slottable Cryo setter the to-do's synergy line already
   asks for (the Cryo Flinger's shape without its Rapid and its lure).
4. **The gate.** "Enough stacks" is the Backdraft's gate at some number. Numbed takes a stun as it
   always does.
5. **Against the mammoth.** The mammoth wants Cryo left on foes, and this machine wants it blown.
   On one team they contend. That may be the point (hold the weaken, or cash it), or it may be a
   clash. The Armadillo's mark is already the cooling the team contends for.
6. **One machine, the Arsenal's frost figure** ("Ten a maker"). The first round's split, with an
   Arsenal version that punished with the cold (laid on whatever strikes the team), is
   withdrawn: that is the Onryō's and Misharu's trigger, and the mammoth's.

### The time-shifter

Ryan listed it again on 4 November, and after the shake-out the same day: "i'd rather flesh out
the time-shifter support since that's an entire unexplored area." Last that day, he kept it as
it stands: "keeping the unrefined time shifter". It is one of Aphelion's ten, and Claude's first
round below waits for its session. It sits on the briefs README's
Aphelion bench (Ryan, 17 October: a machine
"that wants to control the battlefield by delaying and redirecting blows... Soft control, moving
or delaying hits as a whole identity") and is parked in the bible's Aphelion row, with its holes
there. What has moved since 17 October:

- **The pick is a commitment** (26 October). In the player's turn a foe's pick moves only by a
  Lure, by its machine leaving the fight, or by a Disrupt. A redirect would be a fourth way, so it
  goes into that rule.
- **Countdowns are built**: a Suppress holds one for a round, and a Disrupt breaks it off. A delay
  is therefore a countdown on the foe, and its chip must read as ours.
- **A delay is a stun on a foe the team kills before the blow lands**, so it is priced as one (the
  stun row). That is the bench's "delay alone is tempo... it pairs with burst".
- **The burrow** on the same bench is this machine's shift, sound only with Phased's rule (only
  before the machine acts). The mole might want it too (below).

The Baboon is already Aphelion's time loop, through the Paradox, so a second time machine keeps a
Lean rather than breaking one.

**Claude's first round** (4 November), for Ryan to move. Every number is a placeholder.

**The principle: time is conserved.** The machine moves actions in time and never makes or
deletes one. Every blow it moves still comes, so it is soft control by construction, as Ryan's
17 October words ask. Its tempo is the kind the action economy row sanctions: a second action
paid for in an ally's own turn.

**The clocks it can touch**, the area as the engine has it:

- the foes' moves: each round's move and target, and the countdowns that gather;
- the team's actions: one spend a die a round, the rerolls, the dark entries;
- the statuses' clocks: Burning and Vitriol fading a stack an action, Flak halving, Exposed
  through the next round, Numbed decaying, Empowered halving.

**The kit, one verb for each clock:**

- **Delay** (a locked debuff, the foes' clock). The move the foe shows waits a round and lands
  beside its next move: both land next round, the waiting one first. Its pick holds while its
  machine stands, as a countdown's does. A foe killed first takes both with it, so on rank and
  file the team will kill next round, a delay is a stun. It therefore sits on Numbed's clock: a
  Numbed foe strips a stack instead, and a delayed foe gains its stun resist as its waiting move
  lands. Its gate is the debt, the stun row's self-sacrifice: a foe that lives hits twice. A
  delayed countdown gathers a round longer, as a Suppress already holds one. Its chip is ours, an
  hourglass with the waiting blow's number, never the enemy's violet.
- **Bank** (a locked buff, allies only, the team's clock). An ally that has not acted is Phased
  this round, so every blow aimed at it re-picks by its foe's aim. That is Ryan's redirect, with
  no ally chosen to take the blow, so it is no interpose. Next round the ally acts twice: after
  its first spend its die rolls again, never onto the entry just spent. Both parts are built:
  Phased (the Swallowtail's Mooring Screens) and the roll-again (the Reveille Horn's charged
  form, the Reheat Uplink).
- **Stasis** (the passive, the statuses' clock). Every foe its equipment hits keeps every mark the
  team laid through the next round: Flak does not halve, Burning and Vitriol tick without fading,
  Exposed holds. Numbed holds too, which is the price a stun team pays. This is the 22 October
  bench idea. It reads other makers' marks (Wainwright & Sutler's Flak, the Arsenal's and
  Aphelion's Burn, Kestrel's Exposed, the funnel-web's Vitriol), so it opens build space. It also
  gives Aphelion's status house a third axis: the Stingray goes deep, the jellyfish wide, the
  time-shifter long.

**The holes.**

1. **The forecast plays one round.** Next round's debt and the banked ally's second action must
   show on their chips, since the gauges forecast only the round in hand.
2. **Two moves in one foe action** is new code. The intent shows both, the waiting one first. A
   Suppress on a delayed foe holds both a round, and a Disrupt breaks off the waiting move, as it
   breaks off a countdown.
3. **It cannot bank itself.** Spending is acting, and Phased goes only to a machine that has not
   acted.
4. **It is a tier two.** No basic is equipment, so its passive needs a tier-one debuff in its
   stock.
5. **The stun budget.** The delay is the one piece that removes a blow (when its foe dies first),
   so it lives on Numbed's clock. The bank removes none: the blows re-pick onto others. Stasis
   freezes Numbed against the team's own stuns. Ryan logged stasis on 22 October with a caution:
   none of those slot-ins was to get a brief until Aphelion's powers were read, "or we'll end up
   with an OP umbra inducer all over again".
6. **It parts by pattern** from the jellyfish, which changes the move and purges; from the Baboon,
   whose Paradox removes the action; from the Swallowtail's charged screens, which phase every
   ally at a muster's price with the action lost; and from the Lammergeier's mines, which act on
   arrivals.

**One machine or two**, for its session. The time-shifter is one of Aphelion's ten, and the open
slot is the time area's if it wants it. Claude would split it by whose clock. The time-shifter keeps the foes'
clocks (delay and stasis). A time support takes the team's: the bank, and its mirror, a borrow,
where an ally that has acted rolls again and acts now, and its die stands down next round. Each is
a second action paid in the ally's own turn. Otherwise it is one machine with the kit above, and
the slot stays open.

### The Barrier and Ward support

**What stands.** The Barrier and Ward row (section 5):

- A Barrier stops the next blow's damage, and that blow's riders still land.
- A Ward turns every rider away for the round, and the damage still lands.
- "Both up is the old whole block at twice its price."
- A Barrier is never granted to every ally at once.
- Both want the same care as Suppress.

The carriers are the Blast Door (Minerva's) and the Decoherence Veil (Aphelion's), each self or
ally, tier one, and in no stock. Aphelion's defensive tier one is still unproposed (the to-do;
Ryan, 19 October), and the tier sort puts a support at tier two.

**Shapes**, each Claude's and each one machine at a time:

- **Its shields ward.** A shield it spends also Wards the machine it lands on for the round. Its
  basics show it: a Halo Shield on an ally. Every shield it carries does the Veil's job, and a
  Blast Door beside them gives the whole block on one machine for two spends, the row's price.
  This is a candidate for the defensive tier one, if a support stands there.
- **The riders it turns are its fuel.** A Ward it grants feeds a count for each rider it turns
  away, and at three the holder gains a Barrier. The Ward pays where riders come in volume, as its
  row says it should.
- **The riders come to it.** When a Barrier it granted pops, the blow's riders land on this machine
  instead of the ally, so its own Ward makes the block whole. That is a redirect of riders, an
  interpose by another name, which the redirection row allows on a locked piece only.

### The status detonator (no weapons)

Folded into the jellyfish, the Science Vessel homage, unrefined. Ryan, 4 November: "Lots to sort
out here, but this isn't the time. Let's say we're folding the unrefined detonator concept into
the Science vessel, yes, and keeping the unrefined time shifter."
Its notes and holes moved to that brief, the design's home (`docs/briefs/aphelion_jellyfish.md`).

### The shock-synergy unit (Aphelion and/or the Arsenal's thunder homage)

**What stands.** Shock and Chain are Aphelion's lean ("most Shock and Chain setters land in its
content"). Today's setters are the Polarity Projector, the Tesla Gauntlets (Minerva's), the
Megataser Harpoon (the Dingo's), Retaliate, and Charged, which has no carrier yet. Static, above,
is already a Shock-family machine.

**Claude's leans.**

- Aphelion's shock unit is the Static machine: one machine, not two.
- The Arsenal's thunder figure is a smiter: Chain's capstone, with the benched bell tower toll as
  its area Shock setter ("Ten a maker"). The first round's retribution form (Retaliate on every
  ally) is withdrawn, because it is the Onryō's trigger and close to Misharu's.

**Forms already set aside.** The kill and repeat (Ryan, 28 October: "a no-go"). The charge to a
random foe (retired 3 November).

## Minerva

### The tier-one lure tank

**In today's engine.** The passive grants Lure to every weapon the machine fires, the Wild Boar's
shape (a keyword a passive grants). Each blow it takes adds an Armoured stack until the round's
end. The round ends at the end of the enemy's turn, so "until end of turn" reads the same.

It passes the tier-one test: every basic gun lures.

It is the luring tank the echidna's brief split from the spikes (Ryan, 15 October: "we can either
play up the spikes, or the luring tank, not both"). So Ryan's two Minerva ideas take the two
halves. It is also one of the tier-one fronts beside the Armadillo's move to tier two (Ryan, 4
November: "Armadillo moves to T2, and either Boar or Mole will move down"), the option section
12's Armadillo question waited on.

**The holes.**

1. **Immunity at tier one** (see "Armour at or over the tier's blows is immunity"). Base armour 2
   plus a point a hit walls out the 2s and 3s after the first hit. Base armour of 0 or 1, or the
   floor of 1, makes "bleeds on the first couple" true. Against a massive foe's single big blow it
   gains nothing, so it is a swarm tank rather than a wall, which sets it apart from the Armadillo.
2. **What counts as a hit.** Does a blow that lands on its shield count, or only one that reaches
   its hull? Hull only means it bleeds to harden, and it reuses the engine's hull-damage trigger
   (the Nemesis's). That trigger also reads an overheat and a bite, so it would need to read a
   foe's blow only; otherwise an overheat buys armour. Claude's lean: a foe's blow that reaches its
   hull.
3. **The lure's reach.** One spend a round lures the one foe it hits, or more with an area or a
   sweep. So the choice is which foe to pull: the small hitters, which its ramp eats, rather than
   the big one, which it cannot.
4. **The bot.** The greedy bot values a lure for allies at nothing (the Armadillo's row), so this
   machine's runner rows wait on that valuation.
5. **Its stock and numbers.** Its hull, and the lure through its basics. It needs no locked piece.

### The mammoth (Cryo for the party)

**What stands.** Cryo never fades on its own, and any weapon hit cashes it for cooling (the
Armadillo's row: the cooling the team contends for). Ryan marked Cryo for reuse and allowed it "a
minor rider later, only if the roster has room" (20 October). This idea is that rider: a foe
carrying Cryo hits every machine a point lighter while the mammoth fights. It lives on one
machine's passive, as the Paradox lives on the Baboon's. The Prairie Dog's passive already has
the shape for itself alone: a foe carrying Flak hits it 1 lighter.

**The holes.**

1. **The decision it asks for.** A weakened foe stays weak only while nobody shoots it, so "hold
   fire on the frosted foe, or cash its cooling" is a real choice. Against rank and file, killing
   beats weakening, so the passive pays on the big foes and on foes out of Direct reach.
2. **Scale.** A point off a blow of 2 or 3 is a third to a half of it. With armour 1 or 2 it is
   immunity (see above). Read it on the runner against tier one's compositions.
3. **Cryo on its strikers.** This is the retaliation row's shape, a debuff on the striker, which is
   fine. It scales with the blows the mammoth takes, which a debuff may do; the thorns line governs
   damage. The echidna lays its debuff on its strikers too, so Claude's lean ("Ten a maker") is
   that the mammoth's frost comes from a blow on any ally's shield, the party-wide trigger Ryan
   asked for, while the echidna's quills come from a blow on its own hull.
4. **Overlaps.** Misharu's Penance is "a weaken on the breaker" (the Arsenal's, briefed), so there
   would be two weakens with different triggers. The Aphelion detonator blows the same Cryo.
5. **Names.** Mammoth and Mastodon are both on the reserved list.

### The mole, a drill tank

This is a shape with no verb yet. Ryan, 4 November: it "needs a better hook than 'ignores
armour' but we can work on that later". So Claude's breach lean is withdrawn. The directions from
the first round stay for that session:

- **Under the wall.** On the map it tunnels under walls, the first ground machine past one. A map
  rule alone is a weak identity (section 7), so it would want a fight half too.
- **Through the front.** Its Direct blows reach the back rank under the front, or every weapon
  drills through the column (Penetrate granted, the Boar's shape). The Boar's Spillover already
  carries damage past a kill into the foe behind, so the mole parts from it by not needing the
  kill.
- **Deeper each bite.** A drill that bores: each hit on a foe it has already hit this fight deals a
  point more. The line frame's combo counts blows on anything; this counts blows on one foe.
- **The burrow** (from the bench, 17 October; Ryan called it "hilarious"). Spent on itself, it goes
  under and every foe aiming at it re-picks. That form was broken on the spider and was a reverse
  Lure without the choice. It is sound only with Phased's rule (only before it acts), and it is
  the time-shifter's shift on the same bench.

### The shield bash (a potential Minerva tier-three weapon or module)

Ryan, 4 November: "Cut shield-basher as a unit, but add it as a potential minervan tier 3 weapon
or module - bonus damage equal to armour, then armour zero until end of round." Claude's notes on
that form:

- **It reads every armour the machine carries**: base, Armoured, the Ore Plate and the seal. That
  makes it the payoff for an armour build, which no tier-three piece offers today. A sealed
  Armadillo cashes its seal (a weapon would open the seal anyway). A full Honey Badger cashes its
  plate while its loads stay in the hopper.
- **The price is the enemy's turn.** Armour zero until the round's end means the machine meets
  that turn's blows bare. It cashes no blows taken: Armoured from being struck ended with the last
  round, so it is never the Armadillo's refused "stored blows cashed as damage".
- **A weapon or a module.** As a weapon it is one entry, and the choice is made on the die when it
  shows. As a module, the rule would ride every weapon the machine fires: the first spend each
  round pays, and the rest of the round fires at armour zero. Claude's lean: the weapon. It reads
  as one decision, where a module's one rule would reach every gun the machine carries.
- **The scale.** Armour runs 0 to 5 (a sealed Armadillo), so the bonus runs 0 to 5 on a tier-three
  blow, near the scale's capstone of 12 at the top.
- **The Badger's choice** (hold the ore or fire it) stays the Badger's. This piece offers the same
  choice to any armoured machine, at tier three.

### The immune one

**The holes.**

1. **Whose statuses.** "All" reaches a machine's own statuses. The Armadillo could not seal, the
   Badger's plate would go, and the Kite's Hot Streak, its passive's price, would never land, so
   its drawback would be erased. Claude's lean: immune to what another unit lays or grants (a
   foe's riders and specials, an ally's buffs), while its own kit and passive work as usual, on it
   and on whoever holds the immunity.
2. **Breach and the specials.** A Ward turns away a breach and a swallow. The immunity should say
   the same (a lasting Ward that also locks out buffs), or name breach as a kind of blow rather
   than a status.
3. **The pass and the return.** Is it one locked piece, spent on an ally to pass the immunity and
   on itself to take it back? While the immunity is passed, the chassis is a plain machine. If it
   is wrecked while an ally holds the immunity, does the ally keep it? Ryan's call.
4. **On receipt.** The removal is a Cleanse of everything (Burning, Corrupted, Silenced, Crushed)
   plus a Purge of every bought buff: a strong spend. Its price is that the holder takes no buffs
   from then on.
5. **Its worth depends on the domains' riders,** as the Ward's does ("thin while few domains lay
   riders on machines"). The fresh start's one rider a domain still waits on Ryan's marks (section
   12).

### The echidna, a new shape

Recorded in its brief, `docs/briefs/minerva_hedgehog.md` (Ryan, 4 November).

## Questions for Ryan

In the order they unblock work:

1. **Ten a maker** (Ryan's target and calls, 4 November). The Armadillo's move to tier two: now,
   or with the Wild Boar or the mole coming down, and which of the two comes down. The moves to
   the Arsenal (the Zoids walker, the Cryo detonator as the frost figure) and the merges (Static
   as the shock unit, the aura-shifter into the Macross), unmarked. Aphelion's open slot, the time
   area's if it wants it.
2. **The lure tank.** Its base armour, and whether the floor of 1 (section 12's Armadillo question)
   lands with it. It is one of the tier-one fronts beside the Armadillo's move to tier two.
3. **Static.** Whether a discharge cascades, the triangle on strikes guns, whether it goes through
   armour, and its name.
4. **The Macross.** What shifts it; the grants to every ally, with Battroid's Armoured on all
   hands the form the Swallowtail's row refused (one ally, a shield number, or the row
   overruled); whether the mode sets the way of moving on the map; and whether it is the flagship
   in the Carrier's place or beside it.
5. **The Cryo detonator** (the Arsenal's frost figure): the cooling traded for the blow, its
   planter, its gate. The status detonator's questions moved to the jellyfish's brief with it.
6. **The immune one.** Whose statuses it is immune to; breach; what happens when its machine is
   wrecked.
7. **The shield bash.** A weapon or a module, and its numbers.
8. **The echidna** (its brief). Its drawback, the damage's size and timing, its locked piece's
   verb, and whether the Sonic Needle is kept or replaced.
9. **The rest.** The time-shifter's first round (its principle, the delay, the bank, stasis), kept
   unrefined until its session; the Barrier and Ward support's shape and tier; the mole's hook
   (later, Ryan's word).
10. **Names** (all his). The reserved list's collisions.

## What it hands back

On Ryan's marks, for each machine he takes:

- a brief in `docs/briefs/`, or the existing one extended (the echidna's, the Carrier's for the
  flagship);
- the bible's rows (each Open row of section 7 that lists its maker's candidates, and the
  transforming chassis pin, if the Macross is taken);
- new keywords in `content/vocabulary.json` before their code;
- content marked `"status": "planned"` where the engine cannot run it yet.

This file then retires.

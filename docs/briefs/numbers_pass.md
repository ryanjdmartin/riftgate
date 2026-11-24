# The numbers pass: tier one sized against the reboot

<!-- hangar: {"kind": "rule", "maker": null, "tier": null, "status": "direction", "slot": false, "name": "the numbers pass"} -->

A design in progress, this line's (`ccr-722ca9f0-yj8na3`). It holds what the vocabulary pass
left to do once its rules were built: the offence side's bench and the defence side's
sizing. The vocabulary pass's proposal is retired with its rules in the bible, the rules and
content (`git show 07f01fb:docs/vocabulary_pass_proposal.md`, thirty-five sections, his words
round by round at its head; its table of marks `git show 07f01fb:docs/vocabulary_table.md`).
Every run named here is in `docs/measurements.md` under its date.

Ryan, 17 November, on who moves these numbers: "When it comes to the sizing numbers, you have
authority over the other session ... You can adjust content if you feel like it's ready to
do so." So this pass may land numbers in content when a read supports them; his play judges
them after. Numbers in content are placeholders until then, as ever.

## 1. His words that set it

- The budget (9 November, accepted with the model, "Your leans are good"; the bible's scale
  row, section 11): a formation's fight costs a twentieth of the squad's hull at its rating,
  a flanker's a thirtieth or less, a hunter's a tenth, an elite's a quarter, the boss what
  is left. Danger "should be reserved for Hunter, Elite and Boss packs, not pushers and
  flankers".
- The vanilla (14 November): "the plain vanilla gun is the benchmark for 'viable,' not
  'good.' There needs to be a reason to upgrade. I hope, at tier 1, that the reason to slot
  in found components is to start the Synergy scaling with their units, not an obviously
  straight power increase. I think tier 2 and up, it's probably safe to use the TCG
  heuristic that a vanilla is slightly under the average".
- The standard foe (15 November): "Ok let's go 3 against 5 or 3 against 4 as the options.
  Either number eases my concerns about armoured on the foe's side. As long as we don't
  exceed base armour of 2 in tier 1, I think it'll be fine."
- The Barrier (15 November): "I don't want the existence of barrier as an accessible-to-all
  tool, to justify the existence of massive enemy strikes. That's my main concern,
  degenerate or not. I think that's why I lean towards not having it as a basic." And 18
  November, his lean on the strikes said: "I think it can stay on the starting dice, with
  this change to hit counts, and possibly with giving it cooldown 1. It's one of the two
  sides of the defensive coin, and without it the starting draft leans towards taking units
  that are ok with hull hits, and not ones that actually need their shield for stuff. Makes
  sense or no?" And the same day, on reading the budget on the squad without it: "I agree.
  And sizing it without means that if it does prove toxic after all, in my play, then it's
  relatively easy to remove. Go ahead."
- How the leaders strike (17 November, of tuning for a block that exists: "large blows should
  be multi-strikes except where particularly thematic or the whole point is to suppress,
  disrupt, or block it ... Just a thought, not an instruction"; 18 November, the read in
  hand): "I don't think I'd go so far as to make everything a multi-hit. Barrier can still
  have a niche, as an alternative to suppress, basically. Plus, if everything is a 2x it can
  get pretty cluttered and clunky with too much head math. And we have to watch not only
  riders, as you said, but also brittle and empowered, which scale hard on multi. But
  leaning slightly towards multi to gently boost armour in boss and elite fights seems
  worthwhile. Not so much that an armoured tank is just best in every fight, though."
- The defence side (14 November): "How are we going to approach enemy kits and damage in
  relation to the various shield and hull values we have? Since our shield and hull values
  are, bluntly, pretty completely random, so there's no reason to keep those locked either."
- The bench (14 November): "including both a hot 4 and a less hot 2x2 costs us nothing as
  far as content, gives us more data to work with, and helps to create domain identities
  without a ton of work ... placeholder weapons and equipment for a variety of combinations
  of riders, damage, heat, and hit counts, and then see what sticks and is interesting and
  what is redundant enough to cut."
- The baseline (19 November): "Keep going on all domains, adjusting kits and sizing for
  convergence 2 as our baseline (since convergence 1 is always going to be 3 machines on
  the meadow - I'll handle that one). Finish the first battle build and bot fixes too." His
  Convergence 2 is the second battle, four machines, the anchor of section 3 (the code's
  ramp 1). The first battle's sizing is his; this pass sizes nothing for a trio.
- The kits are not a menu (15 November): a foe's move need not fit a component's format;
  the units below measure a kit and never write one (the bible's row on the foes' rule set).

## 2. The yardsticks, as content has them

| | Tier one today |
|---|---|
| The vanilla, a plain basic gun | 3 for 4 heat (the Twin Autoguns, the Rivet Gun, the Ankle Mortar) |
| The gun that deals one more | The Laser Carbine, 4 for 5 heat |
| The standard foe's hit points | 4, on 59% of formation slots; 5 with the dial |
| The standard blow | 3; the heavy standard 4 (a goblin, a needler, a knight, a lone flanker); a root lashes for 2; a massive strikes for 6 or 7. Tiers two and three: 4 and 5, unsized |
| A machine's shield | 6 to 12, so two to four standard blows |
| A machine's heat maximum | 12 or 14 on all but one: three vanilla shots fill a gauge of 12, the fourth is past it |
| An overheat | A point of hull a point past the maximum, every turn, until the reboot |
| Foes' plate | 1 on about a tenth of slots; his ceiling for tier one's base armour is 2 |
| The Barrier basic | The Halo Projector, on seven dealt stock dice, sitting out a round after a spend |

Each of these as built is his pick since 23 November, after his play of their five dials,
which are cut ("We can lock in the rank and file setting as 4, heat as built, top basic as
built, and overheat at x1. That all felt fine enough as a starting point, to me"; "barrier
basic yes, for now at least"). The runners still lay each as a what-if (`--refit`,
`RIFTGATE_OVERHEAT`).

## 3. Where tier one stands

Sized on 17 and 18 November (section 8) and read at the anchor: tier one at Convergence 1,
the six certain tier ones (the Honey Badger, the Skua, the Storm Petrel, the Prairie Dog,
the Cassowary, the Cottonmouth), each on its stock die with no module and no found piece,
squads as large as the fight is rated (a lone flanker one machine, a hunter's pack two, a
formation three, an elite and a boss four), the greedy bot (`tools/anchor_read.gd`). Every
squad of the pool is read, the even draw: a count of them was uneven by machine until 18
November, the Honey Badger in four of the five fours the leaders were sized on, and the
sizing held when it was read again on all fifteen (`docs/measurements.md`, that day). Hull
is a share of a four's, 96 points for this pool. The squad on the field is four in every
row: a formation's fight is three of it by its rating, the fourth on a flank (his split of
6 November), and all four on a formation cost a fifth of its price or less, the Waste's two
0.8% and 1.5% for 6.9% and 5.4% (18 November). The trio's battle is the first alone, and
the Meadow's alone on his word of that day.

| Kind of fight | Rounds | Hull lost | The budget | Before the sizing |
|---|---|---|---|---|
| A lone flanker | 5.3 | 3.4% | 3.3% or less | 5.9% |
| A hunter's pack | 4.8 | 8.9% | 10% | 12.7% |
| A formation | 5.8 | 5.5% | 5% | 8.3% |
| An elite, the squad without the Barrier | 6.6 | 24.4% | 25% | 23.6%, the Nob at 65.1% |
| A boss, the squad without the Barrier | 9.1 | 29.5%, a wreck in a fight of five | what is left | 53.2%, 86% won |

By formation, since the baseline pass of 19 November (section 10): the goblin horde 3.3%,
the knights' vigil 3.6%, the gel wall 4.9%, the treant's grove 5.2%, the sandworm's ambush
5.4%, the magma vent 6.1%, the barrow mound 6.2%, the grave throng 6.6%, the ember pyre
6.7%, the needler thicket 6.9%. The flankers cost 2.5% to 4.1%; the wolf pack 7.1% and the
antlion trio 10.7%. Every one is won in every fight.

The elites and the bosses are sized for a squad without the Barrier (section 8), the
Armoured basic in the Halo Projector's slot: an elite from 20.3% (the Thunder Ape) to 27.7%
(Gilgamesh), every fight won, and a boss from 25.1% (the Mantis Ant, the Matador) to 36.1%
(the Marsh Serpent), a row a direction at thirty fights. The squad as the dice deal it,
the Barrier basic on them, pays an elite 15.9% and a boss 20.4%: a third to a half where a
leader's weight is one great blow, and what the other squad pays or more where it is
strikes, a purge ahead of the blow or a blow at every machine (`docs/measurements.md`, 19
November, has every row). The piece stays on the starting dice on his word, his play to say
whether it proves toxic; the game is sized for the day it leaves.

## 4. What a point is worth

Measured 14 and 15 November at the trial's basics, tier one's ten formations at their
rating. A cell is a direction; the scale is what holds.

| The point | What it buys |
|---|---|
| A point on every rank-and-file blow | Four to seven points of a four's hull, more with each step: the shields are a fixed pool and every point past them is hull |
| A point of damage on the basic guns | 0.6 rounds and 1.5 points of hull from 2 to 3 and from 3 to 4; little past 4 |
| A point of heat on every weapon | Half a point of damage at most; a quarter once the gauge outlasts the fight; nothing in a duel |
| A hit point on the rank and file | 0.7 rounds and 2.9 points of hull at a vanilla of 3 |
| A point of plate on a whole horde of 4s | Doubles what the horde costs the vanilla; on 3s, a third more |

Our riders, in points of damage on a gun: Ablate 1 nine tenths (Burn's measure, the rule it
took over), and its second stack a point more; Spread 1 a point by rounds and two in hull
kept; Penetrate 1 six tenths, Penetrate 2 a point and a half; Shock nine tenths, nothing
against a horde and over two against a massive; Brittle 1 half; Expose six tenths; Sap a
point of hull a stack and nothing in rounds; Cryo a fifth whatever its number; Chain and
Purge nothing alone. A split gun: 2 twice reads as a flat 3.8, 1 four times as 3.7, and
against plate as 3.5 and 2.0 to 2.6. A rider's worth is the foe it answers: the area chips
and the point more answer a horde, Shock, Brittle and Expose a massive behind plate.

The foes' riders, in points on every rank-and-file blow: Corrupt 1 about 1.3; Brittle 1
(Crush's measure) 1.2; Scorch 2 a fifth and Scorch 1 nothing; Jam and a drained reroll a
tenth. Scorch, Jam and the drain change what the player does without costing a fight. A
blow at every machine is the foes' answer to the reboot, since every bare machine stands
under it. Ablate on a machine was not run as built: its heat form read a third of a point
at 1 and a point and a half at 2 with fights lost.

Armour: a standing point should sit under half the standard blow, a basic's timed armour a
point under it, and a wall is a kit's own state, the seal or the loaded hopper. Armour does
nothing while a shield takes the blow whole, so under the reboot it is the cover of the bare
turn against a swarm, as a Barrier is against a spike.

Plate against a leader's blow, by how it lands: of a blow of 16 that reaches the hull,
plate 2, the Shoring Jack's round, takes an eighth whole, a quarter in two strikes and
three eighths in three; plate 4, the Polar Bear sealed, a quarter, a half and three
quarters. A pair is a gentle lift for plate; three strikes and more are a wall's fight.

## 5. The defence side: the approach

The machine is fixed first and the foes' blows measured against it, the mirror of the guns.
One thing does not mirror: a gun's damage past a kill is wasted, so a gun is read in shots to
kill; a blow's damage past a shield reaches the hull, so a shield is a pool, read in totals.

1. Three clocks. The round's: a Barrier is one blow, Armoured a point a blow. The cycle's,
   from one reboot to the next: the shield and the heat. The battle's: the hull, by the
   budget.
2. A shield is counted in standard blows, two to four at tier one.
3. A fight is counted in cycles, the foes' damage over the squad's shields: a formation
   about one, an elite nearly two, a boss three to four. Each cycle past the first is bought
   with a reboot, turned by a Barrier, or paid in hull.
4. Two clocks, one reset. A machine's heat runs out in its maximum over its guns' heat and
   its shield in its size over the blows it draws; the reboot resets both. If one always
   runs out first the other gauge is decoration, so a standard machine's two clocks should
   run out within a round or two of each other at its fights' rating, and a role is which
   one it leans on.
5. A hull has two jobs: the battle's pool, and the blow that would destroy a component, a
   rule that is off today.
6. A foe's kit is which clock it presses or goes round. The swarm presses every shield, and
   armour is its answer. The spike presses one, and the Barrier is its answer. Scorch
   presses the heat. Ablate goes round the plate and the Barrier and not the shield. An
   Exposed turns the field on one machine with its plate off. A blow at every machine
   catches the reboot. The hottest finds the machine a reboot is due on. Jam, a corrupted
   entry and a drained reroll attack the die.
7. A model first (`tools/budget_model.py`: what a shape of pack costs a squad that buys its
   shields back with a turn), then the numbers, read by the bot at the anchor as bands
   (`tools/anchor_read.gd`), then his play.

The order of work, with what is done: the bot prices every step of a foe's move (17
November); the model; tier one's flankers, hunters and formations on the budget (section 8).
The elites and the bosses of tier one followed on 18 November, for a squad without the
Barrier. Still to come: the scorches on every machine above tier one (the Eruptions' 4 and 5, Fira's and Pyroclasm's 4,
sized against a cooling of 2) toward 2; then the first battle scaled down and tiers two and
three up.

## 6. The offence side: the bench

His proposal, agreed, and priced from the vanilla he settled on 23 November. The grid below
is the session's lean for his marks: nothing of it is content, and each piece goes to the
hangar's Components tab as a placeholder once he has marked it ("Placeholder pieces can go in
the Hangar Bench for my review?"), then to content with working names for what survives.

Five things keep it small:

- One trade a piece: the vanilla with one thing traded, named. A point more for heat, a
  point more split in two, a point less for a rider, the rider kept for a point of heat,
  Indirect for a point of heat.
- A kill signature: a gun's spends to kill five marks (a plain 4, a 3 behind a point of
  plate, a thin 3, a thick 6, a 4 behind plate; `tools/basics_model.py`, section 8). Two guns
  with the same row and heat are one gun.
- Marks as well as guns: a placeholder formation is one standard foe eight times.
- Par, then the unit: a piece is priced to read as the vanilla alone, then read on each
  machine, since the reason to slot a find is what a unit does with it.
- Read by the kind of formation, by the bot's pick share and by his play.

**The ladder the basics set.** A whole shot: 3 for 4 heat (the vanilla), 4 for 5 (the Laser
Carbine), and from there two points of heat a point, 5 for 7 and 6 for 9; Indirect a point of
heat on top (the Ankle Mortar, 3 for 5). Each step ends one more mark in one shot and holds
one shot fewer in a gauge of 12: three, two, one and a second past it, one. A split reads as
its flat number less a little (2 twice as 3.8, 1 four times as 3.7) and far less into plate; a
rider as its points (section 4).

**Tier one's fourteen against it**, as built:

| The gun | As built | Reads as | The ladder's heat for that | Under by |
|---|---|---|---|---|
| The Plasma Arquebus | Direct 4 for 5 | 4 | 5 | par: it is the Carbine |
| The Transonic Rifle | Direct 5 for 7 | 5 | 7 | par |
| The Thermal Ray | Direct 6 for 9 | 6 | 9 | par |
| The Arc Fault Cannon | Direct 4 for 5, Chain 2 | 4 alone | 5 | par alone: the Carbine with a hook |
| The Slugthrower | Direct 4 for 4 | 4 | 5 | 1 |
| The Shotfire Rack | Indirect 4 for 5 | 4 | 6 | 1 |
| The Flechette Pod | Direct 1 four times for 4 | 3.7, and 2 to 2.6 into plate | 5 | 1, and plate stops it |
| The Blazethrower | Direct 3 for 6, Ablate 2 | about 5 | 7 | 1 |
| The Airburst Shell | Indirect 2 for 4, Spread 1, Brittle 1 | about 3.5 | 5 to 6 | 1 to 2 |
| The Incendiary Shells | Indirect 2 for 4, Ablate 2 | about 4 | 6 | 2 |
| The Overclocked Railgun | Direct 8 for 11, ignores armour | 8 and more | 13 | 2 and more |
| The Enfilade Beam | Direct 4 for 5, Penetrate 3 | 5.5 and more | 8 to 9 | 3 to 4 |
| The Howitzer | Indirect 4 for 4, Spread 1, Penetrate 1 | about 5.6 | 9 to 10 | 5 |
| The Maxigun | Direct 2 three times for 4 | about 5.7, half of it into plate | 9 | 5 |

Three stand on the ladder already; ten are under it, by one point of heat to five. Eleven of
the fourteen deal 4 or more, where a find in a tier-one rift "is a new trick and never a
bigger number".

**The bench**, a piece a line, each a trade from the vanilla or from the basic of its reach.
Spends to kill, in order: a plain 4, a 3 behind plate, a thin 3, a thick 6, a 4 behind plate.

| The gun | On the bench | The trade | Spends to kill | What it is for |
|---|---|---|---|---|
| The Slugthrower | Direct 2 twice for 5 | A point more, split in two, at the Carbine's price | 1, 2, 1, 2, 2 | Whatever fires a strike; as built it is the Carbine a point cooler, so it changes or goes |
| The Plasma Arquebus | Cut, or a trade of its own | None: it is the Carbine by another maker | as the Carbine | One machine's passive reads a tag today, so the tag alone is no trick |
| The Transonic Rifle | As built, 5 for 7 | Two more | 1, 1, 1, 2, 1 | Ends a 4 behind plate in one; a shot a gauge and a second past it |
| The Thermal Ray | As built, 6 for 9 | Three more | 1, 1, 1, 1, 1 | Ends a thick 6 in one; a shot a gauge |
| The Overclocked Railgun | Up a tier, with the component pass | | | The one open tier-one piece that ignores armour |
| The Maxigun | Direct 2 three times for 8 | Three more, split: a point cooler than the Thermal Ray for what plate takes | 1, 1, 1, 1, 2 | The horde gun and three triggers a spend; a shot a gauge |
| The Flechette Pod | As built, 1 four times for 4 | A point more, split fine | 1, never, 1, 2, never | Four triggers a spend at the vanilla's heat; nothing behind plate, which is the trade |
| The Enfilade Beam | Direct 3 for 5, Penetrate 2 | The rider kept for a point of heat | 2, 2, 1, 2, 2, and 2 behind | A column: a front and what stands behind it |
| The Arc Fault Cannon | Direct 3 for 4, Chain 2 | None alone: the vanilla with a hook | 2, 2, 1, 2, 2 | Chain reads nothing until something Shocks; the find that starts a synergy |
| The Blazethrower | As built, 3 for 6, Ablate 2 | The rider kept, a point of heat a stack | 2, 2, 1, 2, 2, and 3 more over two turns | Past plate, slowly; two shots a gauge |
| The Shotfire Rack | Indirect 4 for 6 | The Carbine's point on the Mortar | 1, 1, 1, 2, 2 | The back rank's 4 in one; two shots a gauge |
| The Howitzer | Indirect 3 for 6, Spread 1 | The Mortar, the rider kept for a point of heat | 2, 2, 1, 2, 2, and 1 beside | A rank. Its Penetrate goes |
| The Incendiary Shells | Indirect 2 for 6, Ablate 2 | The Blazethrower's trade on the Mortar, Indirect paid in the point of damage | 2, 3, 2, 3, 4, and 3 more over two turns | Past plate from the back, slowly |
| The Airburst Shell | Indirect 2 for 5, Spread 1 | The Mortar, a point less for the rider | 2, 3, 2, 3, 4, and 1 beside | A rank, cool. Its Brittle goes, or stays for a point of heat |

After it three finds deal 4 or more in one strike (the Shotfire Rack, the Transonic Rifle, the
Thermal Ray), each paid in shots a gauge; the split guns reach it across their strikes and pay
in plate. The spec that lays the bench over content for a read, the pieces by today's ids
(`sim/refit.gd`'s `face=`):

```
face=slugthrower:power=2:strikes=2:heat=5,face=plasma_arquebus:tier=2,face=overclocked_railgun:tier=2,face=maxigun:heat=8,face=enfilade_beam:power=3:penetrate=2,face=arc_fault_cannon:power=3:heat=4,face=shotfire_rack:heat=6,face=howitzer:power=3:heat=6:penetrate=0,face=incendiary_shells:heat=6,face=airburst_shell:heat=5:brittle=0
```

Its read at the anchor (`docs/measurements.md`, 23 November; tier one's second battle, every
squad of the six certain tier ones, of a four's hull):

| The squad | A lone flanker | A hunter's pack | A formation | An elite | A boss |
|---|---|---|---|---|---|
| Stock, basics | 3.9%, 5.8 rounds | 9.4%, 5.1 rounds | 8.0%, 6.1 rounds | 21.5%, 7.8 rounds | 27.0%, 10.6 rounds |
| Two of today's finds a die | 2.5%, 4.7 rounds | 5.0%, 4.2 rounds | 5.5%, 5.2 rounds | 13.7%, 5.6 rounds | 16.9%, 7.1 rounds |
| Two of the bench's finds a die | 3.4%, 5.3 rounds | 7.4%, 4.8 rounds | 6.2%, 5.6 rounds | 18.1%, 6.8 rounds | 21.6%, 9.1 rounds |

Two bench finds a die take a sixth off an elite's price and a fifth off a boss's, where two of
today's take more than a third. What is left is about what a quarter more of a leader's hit
points answers across the tier, half of what today's finds ask (`docs/tide_proposal.md`,
section 5): the bench and the leaders' forms are sized together.

The equipment is no part of the grid, with one line for him: the Blast Door is the Halo
Projector's entry under another name, a Barrier with a round's cooldown, so it is one piece
twice. And the Shoring Jack, of which he said on 23 November "a dead face most of the time,
but that's possibly because I felt I couldn't afford any break in my shield": its Armoured
lasts until its machine's next turn starts and a reboot is that whole turn, so a machine's own
Jack never covers its own bare turn. Alone it pays only on a turn fought on a broken shield;
in a pair it covers a partner's reboot. Packs sized to their rating make the pair's case more
often and the lone one no better.

## 7. Open

His, each with this pass's lean and its read (`docs/measurements.md`, 17 and 18 November):

| The call | The lean | Why |
|---|---|---|
| Whether the Barrier basic proves toxic | His play's to say (18 November: "if it does prove toxic after all, in my play, then it's relatively easy to remove"); it stays on the starting dice (23 November: "barrier basic yes, for now at least"), its dial cut | The leaders are sized for a squad without it, so taking it off moves no number. With it a squad pays about half, and the leaders whose weight is one great blow cost it least: the Vampire Lord 7.1%, the Fell Rider and the Rust Monster 7.4%, the Mantis Ant 7.8%, the Marsh Serpent 8.3%, the Nob 9.6%. A second round of cooldown is 3.5 points on a boss where the piece itself is 20 |
| How the leaders strike | His lean, 18 November (section 1; the bible's section 9): whole blows the norm, "leaning slightly towards multi to gently boost armour in boss and elite fights", never so "an armoured tank is just best in every fight" | A pair is the gentle setting and three strikes or more a wall's fight (section 4's plate arithmetic), so three and more stay the rare kit shape. Today one boss a domain carries a move of strikes (Floraison's three and five, the Emperor Scorpion's pair, the Matador's four, the Fiend of Fire's six) and one elite fight of tier one's eleven (the Thunder Ape's three). Two more bosses strike in pairs on his go of 18 November, the Mantis Ant and the Gargantuan King (section 8). What room the lean has left is a pair on a few elites' plain blows, each a proposal in chat by the kit's fantasy. A move of strikes is sized with what lands once a strike: its riders, and a machine's Brittle (the World Eater its one layer, so it keeps whole blows). A foe's Empowered goes through the move's multiplier, so a pair at the same total takes a rally as the whole blow did, and it grows on a move whose strikes add up to more than its attack (Full Bloom, five strikes at half, takes two and a half of one). This pass's lean of 17 November, every plain blow as two strikes, is retired; its read stands, and the what-if that made it, the anchor read's `split=`, left with the leader pass (`git show 4ae57e4:tools/anchor_read.gd`) |

Settled on 23 November after his play, each as built and its dial cut (section 2): the vanilla
3 for 4 heat where this pass leaned a point cooler, the Carbine 4 for 5 where it leaned 4 for 6,
a standard foe of 4, a point of hull a point of heat past the maximum.

Landed on 19 November on his "Agreed on all, send Coil to T2", read at the baseline
(`docs/measurements.md`, that day): the Field Radiators and the Boundary-layer Bleed lose their
point of cooling, the Radiators keeping their maximum, so no piece grants a cooling or a shield
regen today (the engine keeps both, the reboot's rulings on a granted one standing); Cryo cools
1 a stack; the Ankle Mortar deals 3 for 5, Indirect a point of heat over Direct (the bench prices
the finds by the same trade); the Overcharge Coil is tier two, at its two stacks; the seven
planned shields and vents of tiers zero and one are retired, the three of tier two kept as
drafts until a kit wants one. The Wake Diffuser was the last piece of a vent's shield half, so
that half left the engine with it. Beside them, his yes to the refit brief's placeholder slots:
the Cassowary's second Twin Autoguns is a Laser Carbine and the Cottonmouth's the Incendiary
Shells. His answers on the rest of this table: the walled tank is an identity ("Reboot for free
is an identity"), and the bench's pieces go on the hangar's Bench for his review (section 6).

- Tiers two and three scale from the same attacks, so the leaders there came down with tier
  one's and are unsized as before.

## 8. What landed, 17 and 18 November

Tier one's flankers, hunters and formations, in `content/foes.json` and one grid of
`content/factions.json`. The table of moves with each read is `docs/measurements.md`, 17
November. The rules the moves follow, each a lean of this pass and his to overrule:

- A lone flanker's blow is the heavy standard, 4, the Roc's. The Whisker Cat, the Dullahan
  and the Cerberus came down from 5; the Dullahan, which rises once, has 9 hit points for 10.
- A pack that rallies strikes for the standard blow, 3: the Dire Wolf.
- A back rank strikes for the standard blow: the Drake, at 3 as the roots, the ghosts and
  the cockatrices are. Its Stoke lays Ablate 1.
- A foe that strikes every round pays for it in its blow. The Mandragora and the Mandrake
  lost Scream as a move on 17 November and strike a point lighter, for the same blows a
  round as before.
- A split conserves the blow: a Half-Gel strikes for 1, half its Gel's 2.
- A blow that lost Breach takes back what it paid: the Needler and the Zombie Knight strike
  for 4, and the two massives, the Sandworm and the Magma Elemental, for 6. The Needler's
  body was the other half of that price, 2 hit points for a needle through the shield: it
  has the standard foe's 4 since 18 November, and the old man's rising fields two Needlers
  for three.
- A scorch on every machine is 2 at tier one: the Magma Elemental's Eruption.
- The standard blow with a rider on top: the Salamander strikes for 3.
- The two formations that ran longest and dearest: the Treant strikes for 6 and mends 2, and
  the gel wall fields two mandragoras behind its four gels, not three.

The Waste's two formations cost 1.3% and 1.5% until the Needler's body, and 6.3% and 5.4%
with its kit (section 9). A blow that carries a Purge ahead of it pays a point, as a blow
under a rider does: the Old Man of the Desert strikes for 11 where he struck for 12.

The elites and the bosses of tier one, 18 November, in `content/foes.json`, read for a
squad without the Barrier. Every boss and every changed elite, before and after for both
squads, is `docs/measurements.md` under that date. The rules the moves follow:

- A boss's attack is its number, every move a share of it, so a boss is sized by its
  attack: eleven came down, by a fifth to two fifths, and Floraison and the Matador stand.
- A great blow a squad without the Barrier cannot stand comes down first: the Nob's Rush is
  14 for 23, the Phantom Train's Run Down 12 for 16, the Obsidian Tyrant's Crunch 11 for 18.
- What a leader gains is damage a Barrier does not take whole: the old man's Quake is 7 at
  every machine for 3, the Gargantuan King's Meteor keeps its 11 while its horns come down,
  the Rust Monster lives longer for the same bite.
- A heal that feeds on a blow at every machine is sized by the fight's length, never the
  blow: the Vampire Lord's Blood Feast at 6 or 7 for 5 had it out-heal a squad, 93% and 83%
  won, so its attack came down and the feast stands.
- The Pilgrim rose through its blows, and its knife is damage a Barrier does not take since
  18 November, on his thought ("should the knife attack purge before hitting"): Purge 1 and
  then the blow, a step ahead of the blow that the move says, a Ward the answer, and its
  move's own order, no rule of Purge ("pilgrim-only was in reference to not making it a
  purge rule, not restricting it to literally just the pilgrim": the bible's row on the
  foes' rule set), so another move may carry a step ahead where its kit calls for one. It costs a
  squad without the Barrier 19.2% and one with it 16.0% for 7.6%. The Reaper rose the same
  way, for a day: its Harvest is a sweep at every machine since 18 November, on his word ("Reaper
  sweep seems like a good idea"), 9 at each and corrupting 1, drawn as often as its scythe,
  and its Scythe and Knell are 12 and 18 again. It costs a squad without the Barrier what
  it did, 24.3%, and one with it 13.5% for 7.8%.
- Two bosses strike in pairs since 18 November, on his go ("go ahead with both"), the first
  carriers of his lean that the leaders strike slightly towards multi: the Mantis Ant's
  Mandibles are two strikes of 7 for one of 13 and the Gargantuan King's Gore two of 6 for
  one of 11, each beside a whole blow, the Upheaval and the Charge. A pair cost the squad
  without the Barrier nothing (26.1% for 25.9%, 33.4% for 31.6%) and took half the piece's
  edge (13.8% for 7.8%, 27.4% for 23.1%).
- No one action takes the lightest machine from full, the scale row's cap, 26 points on the
  Cottonmouth: the Thunder Ape's Rampage is three strikes of 6 for 8, so gold it lands 24
  where the foes' adds on every strike had made it 30, and the Ape has 54 hit points for 48.

## 9. The Waste's kit, landed 19 November

On his go ("Ok, go ahead with your Waste changes"). The decision is the bible's levers row;
this section holds what landed, its reads and what is still open.

**What landed**, in `content/foes.json` and the faction's notes:

- A Purge ahead of the blow, the knife's own order (section 8), on the needler line's
  Needles, every rung ("Purge 1, then exactly 4"; Thousand Needles is the Great Needler's
  own move and unmoved), on the Old Man of the Desert's Maw, and since the baseline pass
  on the Rust Monster's Rusting Bite (section 10). His question set it, 18
  November, on this pass's first lean of a new rule for the Needler: "Doesn't purge make
  the most thematic sense for the waste based on your reasoning?" A buff is a thing bought
  with a die, and the Purge takes it with a rule the game already ran.
- What such a blow meets: a Barrier is gone before it, a brace is a stack thinner for each
  blow, a hopper's plate loses a stack until the round turns, and a stack of Ricochet, of
  Hardened Light or of an unspent Spun Up goes for good. What still answers it: the gauge,
  the hull, a chassis's own plate, the kill, a Lure and a Ward. The Sandworm, the Antlion
  and the Roc strike plain, so a Barrier has work in the Waste and where it goes is the
  question.
- The Old Man's attack 11 for 12, the Needler's body 4 for 2 (18 November), the old man's
  rising at two Needlers.
- The Waste's signature and answer, in the faction's notes and the bible's table: this
  pass's words, his to rewrite. The word "rerolls" is off it: the reroll's thief is the
  Meadow's Mandragora, its whole back rank, eight in tier one's three formations (his word:
  "the mandragoras are pretty common in the meadow"), and no second thief is added.
- The Waste's nine notes that still said breach. The other domains' wait for their kits.
- Four moves' texts and four codex lines are drafts for his writing.

**The reads** (`docs/measurements.md`, 18 and 19 November; every squad of the pool, hull a
share of a four's):

| Fight | Without the Barrier | With the Barrier basic | Before the kit, without and with |
|---|---|---|---|
| The needler thicket, three on it | 6.4% | 6.3% | 5.7%, 5.3% |
| The sandworm's ambush, three on it | 7.4% | 5.4% | 6.9%, 5.5% |
| Either, all four on it | about 1% | about 1% | about 1% |
| The old man's rising | 24.9% | 23.5% | 27.5%, 15.8% |
| The Pilgrim's wake | 20.7% | 16.3% | 20.5%, 15.5% |

A squad of four fells the Needlers before they strike ("the waste will only ever be fought
with 4 machines"), so the needle is a split squad's lesson, a point of hull where three
stand on a formation and nothing where four do. The weight is the leaders': under the Maw
the squad with the Barrier basic pays what the squad without it pays, where it paid little
more than half, the knife's read again. So in the Waste the Barrier basic is no pass.

**Open, his:**

- The bosses' blows that lost their breach, one at a time, each by its kit. The Ruby
  Colossus's tentacle from below was read on 19 November and the lean is to leave it plain:
  a small blow of a boss whose weight is elsewhere, its purge costs the squad with the
  Barrier a point and a half and the squad with a brace three and a half. The Lancer's
  Jump is a hero's, read with the finals. The Fallen Weapon's Piercing Eye lays Exposed
  already. So the purge sits where one great blow is the leader's weight, the knife and
  the Maw, and no boss of tier one's Waste is that shape today.
- The second lever, held until his play says the stare reads as nothing: the Cockatrice's
  Stone holding until that Cockatrice falls, one stone a machine, a new stare moving it.
- His play of the kit: whether a standing stack going for good is a question or a tax
  (the Skua's Ricochet a stack a needle; the bot prices a stack taken since 19 November,
  at what it pays to gain one, and reads the kill order, a Lure and where a buff goes by it), and whether four purges a round in the thicket read as his "flat tax on every
  foe of a formation" of Breach's second form. It falls on what the player chose to put up,
  and the intents show where.
- The Waste's two cells in his words, and the texts.

**How a kit is put to him**, for the three domains to come (18 November): "I have only
really been playtesting the meadow so you'll have to break down your proposals for me
explicitly." Against the Meadow's fights, piece for piece, with its fights' screens and a
round worked through; a squad of four on the field, a formation's fight three of it by its
rating, and shown against all four beside it.

**The bench**, each killed by a rule he may overrule:

- Needles that armour does not thin, the shield still taking them. The rule: every blow of
  a foe's meets the shield and then the armour, plate's answers being Exposed and Ablate
  (15 November). The purge takes the half of it the rule allows, the armour a machine put
  up, and leaves a chassis's own.
- Needles that hit a shield double. The rule: his second form of Breach, set aside that day
  as a flat tax on every foe of a formation.
- The barb at tier one. The rule: a rung's twist is its own (the recolours' row), and the
  barb is the Barbed Needler's at tier two; its price is the dearest rider's, 1.3 points a
  blow.
- The Sandworm swallows. The rule: danger is a leader's (the budget's words), and the
  swallow is Floraison's and the Colossus's.
- The whole thicket on one machine. The rule: the field on one machine is Exposed's, tier
  two and up.
- Thousand Needles at tier one. The rule: a countdown on the rank and file is "too
  ubiquitous".
- A Needler that takes 1 from any blow, the genre's metal slime. The rule: his ceiling of 2
  on tier one's plate; the Metal Gel is that trope at tier three.
- The Needler holds still in a round a machine has aimed a die at it, this pass's first
  lean. No rule's kill: set aside for the purge, a foe carrying one twist. Its read moved
  no number.

## 10. Every domain at the baseline, 19 November

On his word: "Keep going on all domains, adjusting kits and sizing for convergence 2 as our
baseline." Landed in `content/foes.json` and two grids of `content/factions.json`; every
row before and after is `docs/measurements.md` under that date. What each domain asked
without Breach, and what moved:

**The Meadow.** Breach took nothing of its ranks: its question is numbers, and its ranks
teach a wall, a howl, a split, a mend and a scream. The silence's place is the command its
pieces already carry. Sizing: the Treant has 14 hit points for 16 and the grove two
Mandragoras for three (9.3% to 5.2%); the shaman strikes for 12, his Chain Lightning 6 at
every machine (15.0% to 24.6%); the King Gel for 11 (37.0% to 30.7%). The Nob's rage at 2 a
spend was read and taken back. Open, his: whether eight screams in tier one's three
formations are too many (four in the horde, two in the grove since this pass, two in the gel
wall), the Mandragora being the Meadow's whole back rank.

**The Waste** (section 9), and since: a Purge 1 ahead of the Rust Monster's Rusting Bite,
the leader whose weight is one great bite and whose fantasy is eating what a machine put
up, so the squad with the Barrier basic pays 28.6% where it paid 7.4%. Sizing: Gilgamesh
strikes for 16 (33.5% to 27.7%), the Emperor Scorpion for 10 (37.8% to 27.2%), the Ruby
Colossus for 10 (20.8% to 30.1%), the Fallen Weapon for 11 (22.2% to 29.0%).

**The Marsh.** Breach was the Zombie Knight's cleaver, and its 4 hit points were the
price: at 5 a hurt knight lives to ready its rising, the Marsh's lesson, and the vigil
costs 3.6% for 2.4%. The Marsh Serpent's Bite is two fangs of 7, a pair by its fantasy on
his lean that a leader strikes slightly towards strikes, its Coil left whole (the squad
with the Barrier basic 12.8% for 8.3%). Sizing: a Wild Hunt rider strikes for 8 (37.3% to
23.9%); the Vampire Lord has 56 hit points (20.6% to 26.4%), its attack left alone since
at 11 and 12 its drain out-heals a squad.

**The Peak.** Its signature is the hard hit on a telegraph, and at tier one no rank
carried one once the Magma Elemental's breach and its countdown had gone. The Bomb's burst
is that hit now, half again its number, 6, shown a round ahead by a hurt bomb: kill it
outright, leave it alone or shield what it picked. A shield for the telegraph is the
Peak's own answer, so a Barrier's work there is by design. Sizing: the magma vent fields
two Drakes behind for one (2.7% to 6.1%); the Obsidian Tyrant strikes for 10 and its
Saurian Queen for 10 (41.5% to 31.4%).

The notes that still said breach are rewritten in every domain, and the drafts of the two
kit changes (the Serpent's fangs, the Rust Monster's bite and codex) are his to write.

## 11. The battle whole at the baseline, 19 November

The close of section 10: with every fight on the budget at its rating, the second battle
read whole in every domain (`docs/measurements.md`, 19 November; `docs/battle_run.md`). The
map's player is the runner's, a rule and never his play.

- **The fights hold inside a battle.** A player kept to its ratings pays for a formation
  about what the anchor says and wins it.
- **One machine short is a cliff.** A formation with two machines on it costs four to six
  times its price (18 to 36% of a four's hull for 3 to 7%) and is lost up to four times in
  ten; an elite with three costs about twice; one with two is lost. The Meadow's formations
  are the gentlest short, the Marsh's throng and mound the harshest. This is the squad row's
  lead as a number: splitting up against staying together.
- **The runner's player fights short**, 2.4 to 2.7 machines on a formation and 2.0 to 2.8 on
  an elite, and wins 0 to 25% of second battles in every domain, as it did before the
  sizing. Its hull runs out more than its gate: the wall struck for half turns the gate's
  falls into wipes, a one-beat Rupture adds ten points or so, and a player that never fights
  short keeps half its hull and loses the gate three times in four. No dial read takes it
  past a third. It fights the boss in one battle in ten or two.
- **The Waste is the heaviest battle for it now**, where it was the lightest: its fights were
  under the budget on 16 November and are on it, and its formations are among the harshest
  short.
- **The budget's sum.** The fights a second battle holds, at their ratings, come to 58 to
  75% of a squad's hull with the Barrier basic and 79 to 89% without it, counted on battles
  that mostly ended early, so an underestimate. A battle fought at its ratings throughout
  is won with a tenth to a fifth of the hull left by the squad the leaders are sized for,
  and one formation met a machine short spends that.

**Open, his:** what a battle should leave a squad with, and so whether the budget's shares
stand. This pass's lean: leave the fights as they are, even across the domains, until he
has played a second battle with four machines; if it reads as too tight, the first lever is
the count of fights a battle holds (the tide, the Rupture's length: his dials) and the
second the elite's and the boss's shares, since a formation's twentieth is already small.
The runner cannot settle it: its map player needs a rule for when a strike is worth taking,
and that rule would be a guess at his play.

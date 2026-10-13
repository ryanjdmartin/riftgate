# Measurements

Every run a decision cites, dated, with its method and its seeds, so a bible row keeps the
reason and the exit condition and never the run. The generated reports are `docs/balance.md`
(the matrix at 200 seeds) and `docs/campaign_run.md` (whole runs); this file holds the quick
runs made for a decision, which the reports do not repeat. Add an entry when a decision cites a
run; never edit an old one (git has the history).

## How to read a run

Win rates are binomial, so a cell's band depends on its seeds. Near 50%, the 95% band on one
cell is about:

| Seeds a cell | Band on one cell | A row mean over twenty packs |
|---|---|---|
| 30 | about 18 points | about 4 |
| 50 | about 14 | about 3 |
| 200 | about 7 | about 1.5 |

So a row mean (one machine over every pack, or every machine over every pack) is readable at
30 seeds; a single cell is a direction until it is run at 200 seeds or its delta is far outside
the band. "Alone" is one machine against one pack; "random/greedy" are the ladder's two rungs
(bible section 11). The greedy bot values only what it knows: a verdict on a mechanic it cannot
value (a sentence, a doubling, a turn of the ranks, a wound) is a verdict on the bot.

## 11 October

**The first prices of stats and passives.** Every machine alone, greedy, 30 seeds a cell; each
bump given to every machine against the same run without it; the mean change in win rate over
the thirteen machines, read in hull at 2.9 points for 20 hull. Means over thirteen machines and
twenty packs, so bands, not directions. Shield 20 is worth about 17 hull, armour 5 about 53,
5 more on every blow about 60, cooling 5 and heat maximum 20 almost nothing (only the
Sparrowhawk, which runs hot, values heat). Passives average about 45: the Sparrowhawk's about
200, the Armadillo's about 130 (with the discharge still in), the Nemesis's about 110 (the
Crucible), the Goshawk's about 50, the Ammit's, the Clydesdale's, the Baboon's and the Stingray's
20 to 30, the Wild Boar's about 7, and nothing alone for the Badger's, the Prairie Dog's, the
Dingo's and the Puffin's, which work on the map, on allies or never fire. Module list prices
from those lines: the Flak Skirt about 63 hull, Ablative Plating 83, the Ram Frame 166, the
Field Radiators 4; the Booster and the Databank about 14 on average, 40 to 70 on a rolled kit,
nothing on a flat one. Bible sections 7 and 10.

**The Muzzle Velocity Booster against the Tactical Databank.** Each fitted to every machine, 50
seeds a cell. Worth the same within the noise: five to ten points of greedy win rate on a
machine of rolled weapons (the Badger, the Clydesdale) and nothing on a flat one. Single cells,
each a direction at 50 seeds: the Badger against the Salamanders 56 against 38 and the Waste
formation 90 against 48 for the Booster; the Clydesdale against the Bombs 26 against 4 and the
Treant 98 against 80 for the Databank. Bible section 7.

**The Faraday Hull.** The lone Armadillo, 50 seeds a cell, random and greedy win rates averaged
over twenty packs (a row mean): 85 and 92 with the discharge, 64 and 85 without, 72 and 85 with
one Shocked foe a round. Without the discharge the Armadillo stands at the Wild Boar's level
against swarms and formations and above it against bosses; Minerva's team wins everything
either way. Bible section 7.

**Danger close.** 50 seeds a cell, every row with the Artillery Rangefinder fitted to every
machine (the game without danger close) against the same run without it. No row's win rate
moves by more than three points, most not at all. Indirect's share of attack spends rises from
23% to 25%; the share aimed at the back rank falls from 25% to 19% over every pack and from 63%
to 51% against packs with a back rank. Indirect lands about 12 hull a spend for 8 heat against
Direct's 18 for 9. `docs/keyword_lineup.md` section 6; bible section 5.

**Area by shape.** 40 seeds a cell, random/greedy averaged over twenty packs. Spread at half:
the Badger 45/69 to 42/66, the Wild Boar 62/85 to 60/82, the teams unmoved. Penetrate off the
Enfilade Beam: nothing outside the four formations (the only fights with a back rank); the
Wainwright & Sutler team 78 to 70 greedy against the Meadow formation, the Clydesdale losing
either way. Chain off the Arc Fault Cannon: the Sparrowhawk 46/68 to 38/55, every swarm it beat
collapsing (Goblins and Revenants 20/88 to 0/0, Bombs 52/100 to 0/8, Needlers 72/100 to 18/100),
the Goshawk and the Kestrel team three points greedy. Spillover, with every passive removed
(30 seeds, greedy): the Wild Boar loses about one point. `docs/keyword_lineup.md` section 7;
bible section 5.

**Chassis tiers track nothing.** Alone, greedy, 30 seeds a cell, means over twenty packs: the
tier-one machines win 45% of their fights on average, tier two 52%, the one tier three (the
Ammit) 32%. Bible section 10.

**The Gravity Knuckles as a blueprint.** A sidegrade on other machines; four on the Nemesis its
best build only because the Crucible fed on their bite. Bible section 7.

**The Glacis and the injury threshold.** The Glacis as armour +5 against front-rank blows only
measured no different from flat armour, so it was hidden base armour. The injury threshold at a
quarter of maximum hull sorts the machines as meant: no heavy machine is ever injured, the
light ones 1.4 to 1.9 times a fight; a crack costs 0.4 keywords on average, most cracked
entries losing nothing. `docs/keyword_lineup.md` section 2; bible section 5.

## 12 October

**Modules measured whole.** Each fitted to every machine, greedy, 30 seeds a cell, stats and
rule together, read in hull by the 11 October price: the Ram Frame with no rule about 143 hull
(20 points of greedy win rate on average, every machine gaining), the Flak Skirt about 61, the
Grievance Reliquary 43 (the Clydesdale +17 points), the Spall Liner 43 (the Badger +17), the
Boundary-layer Bleed 36, the Susceptibility Tensor 13 (the Baboon +7), the Thrust Overboost 11
(the Goshawk +13, the Sparrowhawk −15), the Tithe Coupling about −50 (a loss everywhere but on
the Nemesis, whose Crucible its bite fed), the Exotic-matter Shell about −74. The list prices
predict the stat lines (the Flak Skirt listed at 63, the Shell at −68), armour flattening past 5
(the Ram Frame listed at 166). The tier-three modules measured are the worst. Bible section 10.

**The Laminar Deflector's Rapid and the Entropy Condenser's Volatile.** Alone, greedy, 30
seeds a cell (directions): the Prairie Dog 22 to 29, the Sparrowhawk 68 to 70, the Goshawk 37 to
39, the Puffin 11 to 12; the Nemesis and the Ammit unmoved, the bot spending the volatile vent
1% of the time. Bible section 7.

**The Breaching Plow bracing the Boar.** The lone Boar, greedy, 30 seeds a cell (directions):
84 with the Glacis, 81 bracing two, 77 bracing one; the plow spent 37% of the time, 29% before.
Bible section 7.

**The Nemesis's rage.** Alone, 30 seeds a cell, random/greedy averaged over twenty packs (row
means): the Crucible 62/84, rage 56/79, rage on Rapid's reroll 50/76. Cells (directions): random
against the Sandworm 70 to 30 and the Magma Golem 60 to 20; greedy against the Bombs 80 to 37
and the Salamanders 100 to 57; the Meadow formation greedy 13 to 40. Its die: the fists 66% to
53% of its spends, the Retribution Thurible 4 to 10%, the Oblation Ward 1 to 4%. It rolls again
about twice a fight alone, 0.3 times beside the Badger and the Sparrowhawk, 0.6 beside the
Armadillo and the Prairie Dog; every team wins everything for 5 to 7% of its hull; a team's foes
reach its hull 0.15 times a round. Bible section 7.

**The shield rule.** Letting every blow's excess past a standing shield: the machines' mean win
rate 46 to 45 (greedy, 30 seeds a cell, a mean over every machine and pack). Bible section 5.

**Armour lowered.** Every chassis's armour 5 lower, then 10, greedy, 30 seeds a cell. The team
rows move by a point or two of hull (the Minerva team 1 to 3%) at 5, up to 5% at 10, every team
still winning every single pack. Alone (directions): the Armadillo 88 to 79, then 58; the Wild
Boar 81 to 64, then 53; the Badger 67 to 49, then 46. What makes fights easy that day: every team
row beats every boss for 1 to 15% of its hull, the Minerva team every formation for 1 to 11%;
the Kestrel and Wainwright & Sutler teams lose the Marsh's formation at 7 and 0%. Bible section
11.

**The area set.** Greedy, 30 seeds a cell; the artillery shells as a provisional explosive set
(the Shotfire Rack, the Ankle Mortar, the Howitzer, the Incendiary Shells, the Suppression
Battery, the Meteor Artillery), tags being unassigned. The Wainwright & Sutler team against the
Meadow, Marsh and Peak formations: the half rule with danger close gone 63, 10 and 13% won for
62, 98 and 97% of its hull; the shells carrying Spread and Penetrate 100, 100 and 97% for 10, 17
and 23%; danger close kept as the firer's price 100, 100 and 97% for 18, 17 and 26%. The
explosives' share of its spends 35% to 46%. Alone, the half rule costs the Badger and the Wild
Boar 3 to 5 points; the shells add a few points to whoever carries them (the Clydesdale 48 to
61). `docs/keyword_lineup.md` section 7; bible section 5.

**Injuries, one state.** Greedy, 30 seeds a cell. An injury that destroys outright moves no
machine's win rate or hull. Components destroyed a fight, averaged over the machines alone: 0.09
today (two states at a quarter of the hull), 0.57 in one state at a quarter, 0.21 at 40%, 0.10
at half; the Puffin 0.3 at half. Bible section 12.

## 13 October

**The heat debuffs.** Random/greedy averaged over twenty packs, 30 seeds a cell, against the
same rows before. Row means: the starting team 96/100 to 97/100; the Kestrel and Wainwright &
Sutler teams 82/91 to 82/90 and 82/94. Cells (directions): the Wainwright & Sutler team beats
the Peak's formation 83% of the time from 33%; the Nemesis alone on the Peak greedy 32 to 52;
the Goshawk alone against the Salamanders 67 to 3; the Kestrel team 73% on the Peak's formation
at 100 seeds (80% before). Overheats a fight: the Nemesis 12.5 hull to 3.5, the Goshawk 3.4 to
0.1. Scorched losing a stack a turn (tried first): four Bombs held the lone Nemesis to 33%,
against 100 with every stack going at the turn's end; the Kestrel team 86% on the Peak's
formation under the pile. Bible section 5.

**The Nemesis's fists and rage, continued.** Alone, 30 seeds a cell over twenty packs. The fists
without Burn: 44/67; the fists at 25: 52/81 (the lever, left at 15 until play). Rage per 10 hull
taken against one a hit: 6.8 against 7.2 rages a fight alone, 0.46 against 0.39 beside the
Badger and the Sparrowhawk (a blow through its armour averages 9, a bite 10, an overheat 29).
With the Tithe Coupling fitted it rolls again 1.26 times a fight beside the Badger and the
Sparrowhawk against 0.25 stock, for 4 points more of the team's hull; the Proximity Klaxon in
place of the Thurible moves it to 0.29. Bible section 7.

**Fights the team fights together.** From `docs/campaign_run.md` of 9 October: with two or three
machines on the field, 674 fights were solo and 322 joint (one of two 424, one of three 250; two
of two 198, two of three 111, three of three 13). The balance team rows assume a joint fight;
whether the ring and range rules split the team or the bot does is the question in bible
section 11.

## 13 October, the reports

**The balance report at 200 seeds on today's rules** (`docs/balance.md`: 144,000 fights, the
same twenty packs as the 9 October report, which predates the 10 to 13 October rules). Read as
bands. Every team row keeps its band: the starting team 97/100, Minerva 100/100, Kestrel 82/91,
Wainwright & Sutler 81/94. Alone, the row means move by a few points except the Nemesis (greedy
61 to 76, mostly the Peak and the Meadow's swarms: the rage beside the heat debuffs reads higher
than the 30-seed direction of 12 October had it), the Prairie Dog (21 to 31, the Deflector's
Rapid) and the Badger (81 to 74, the bosses). The cells that moved 20 points or more follow the
rules: the Peak's cells opened for nearly everyone once foes heat only through debuffs (the
Bombs: the Clydesdale 1 to 72, the Wild Boar 76 to 100, the Nemesis 65 to 100; the Salamanders:
the Boar 54 to 98, the Badger 77 to 97) and closed for the Goshawk (the Salamanders 80 to 6, as
the heat-debuff row foresaw); the bosses got harder for the heavy machines (the Treant and the
Bone Dragon: the Badger greedy 100 to 46, the Nemesis random 71 to 25; the Sandworm: the Badger
66 to 21); the Marsh's formation turned from a free win into a decision for the Armadillo
(random 98 to 2, greedy 100 to 99) and a wall for the Boar (greedy 95 to 49); the Wainwright &
Sutler team took the Peak's formation (greedy 10 to 68) and the Meadow's (79 to 99). Reach:
Direct is 76% of attack spends at 17.6 hull a spend for 9.8 heat, Indirect 24% at 12.5 for 8.9,
so the numbers still carry the price. Rolled against flat: rolled is 59% of damaging spends at
14.9 hull a spend for 6.4 heat, flat 41% at 18.4 for 14.3, so flat pays about twice the heat per
point of damage, more than the "a little more" of the rolled-or-flat row (bible section 5): a
band for Ryan's play to read.

**The campaign report on the four domains** (`docs/campaign_run.md`: 40 runs, the plain
player). 3 of 40 runs won (29 of 40 on 9 October, before the domains), 6% of battles won, 93%
wiped, 3.9 cities fallen a run, the first city falling on turn 4 on average. The same report on
the commit before the Rally fix gave 0 of 40 and 4%, so the fall is the domains and the 10 to 13
October rules, not Rally. Fights: 1,157 of 1,747 with one machine alone; one machine wins 64%
against one pack and 37% against two; two machines together win 92%.

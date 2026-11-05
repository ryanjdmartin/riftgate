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
the band. "Alone" is one machine against one pack; "random/greedy" are the ladder's first two
rungs, and blind play and the planner the two the coordination gap is read between since 22
October (bible section 11). The greedy bot values only what it knows: a verdict on a mechanic it cannot
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
Direct's 18 for 9. the keyword line-up of 11 and 12 October (retired 13 October; git has it); bible section 5.

**Area by shape.** 40 seeds a cell, random/greedy averaged over twenty packs. Spread at half:
the Badger 45/69 to 42/66, the Wild Boar 62/85 to 60/82, the teams unmoved. Penetrate off the
Enfilade Beam: nothing outside the four formations (the only fights with a back rank); the
Wainwright & Sutler team 78 to 70 greedy against the Meadow formation, the Clydesdale losing
either way. Chain off the Arc Fault Cannon: the Sparrowhawk 46/68 to 38/55, every swarm it beat
collapsing (Goblins and Revenants 20/88 to 0/0, Bombs 52/100 to 0/8, Needlers 72/100 to 18/100),
the Goshawk and the Kestrel team three points greedy. Spillover, with every passive removed
(30 seeds, greedy): the Wild Boar loses about one point. the keyword line-up of 11 and 12 October (retired 13 October; git has it);
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
entries losing nothing. the keyword line-up of 11 and 12 October (retired 13 October; git has it); bible section 5.

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
61). the keyword line-up of 11 and 12 October (retired 13 October; git has it); bible section 5.

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

**One, two, three and four machines together** (`tools/balance.gd --team`, 100 seeds a cell,
random/greedy; the formations are the four domains' whole spawn lists in one fight). Win rates
and the hull lost per fight as a share of the row's total hull, greedy, averaged over the sixteen
single packs, the four bosses and the four formations:

| Row | Packs | Bosses | Formations | Hull lost: packs, bosses, formations |
|---|---|---|---|---|
| Honey Badger alone | 59/79 | 1/24 | 18/48 | 38%, 96%, 76% |
| Sparrowhawk alone | 62/85 | 64/90 | 0/0 | 36%, 50%, 100% |
| Honey Badger and Sparrowhawk | 100/100 | 100/100 | 48/89 | 6%, 10%, 54% |
| Armadillo and Baboon | 99/100 | 98/100 | 49/86 | 7%, 10%, 58% |
| Clydesdale and Prairie Dog | 82/99 | 77/100 | 0/26 | 9%, 8%, 91% |
| Nemesis and Puffin | 73/98 | 42/96 | 5/50 | 20%, 36%, 84% |
| The starting trio | 100/100 | 100/100 | 86/100 | 2%, 4%, 20% |
| Badger, Clydesdale, Sparrowhawk, Armadillo | 100/100 | 100/100 | 100/100 | 1%, 2%, 8% |
| Armadillo, Baboon, Nemesis, Puffin | 100/100 | 100/100 | 92/100 | 0%, 0%, 9% |

Read: a formation costs a pair about 1.1 machines' worth of hull, a trio 0.6, a four 0.3, and
a pair loses a formation outright one fight in four to one in two (the Peak's against the
Armadillo and the Baboon 43%, the Marsh's against the Badger and the Sparrowhawk 75%). Two
pairs fighting two formations spend about three times the hull of one four fighting both in
turn, and risk half the team each. A boss alone is two rounds and 2% of a four's hull: no exam.
Count dominates composition: a four of tank, controller, bruiser and support reads the same as
a four of hitters. Bible sections 4 and 7.

**The campaign without the in-fight Rift Pressure tick** (`docs/campaign_run.md`, 40 runs,
the plain player, 13 October, late). With the tick per round fought removed and the map's tick
alone: 12 of 40 runs won (3 with the tick that morning, on the same rules otherwise), 24% of
battles won (6%), 75% wiped (93%), 3.5 cities fallen a run (3.9), the capital's gate at 90 of
300 at the end (22), 1,383 fights against 1,747. The tick had been spawning packs into the
bot's long solo fights, so about a third of the campaign's fall was the clock; the rest is the
domains and the solo fights, which the fresh-start session owns. One battle ran 55 phases: a
stall the runner now shows instead of punishing. Bible section 4.

## 13 October, the gunship's stand-in

**The gunship's tag rows on a stand-in.** Wainwright & Sutler's proposed medium gunship, whose
fitted weapons raise its numbers by their tags (`docs/briefs/ws_gunship.md`). Measured under the
whole-block shield rule (a standing shield blocked a whole blow), which changed on 14 October; a
rerun before the honest shield rule is built still measures the old rule. Every machine alone
against the twenty packs, greedy, 100 seeds a cell, the mean win %: a row mean over twenty packs
carries a band of about 3 points, so these are directions, a gap under about 5 points is noise,
and the bot values these stats through its forecast. The stand-in is the Goshawk's frame (a
medium flyer with five hardpoints) stripped of its passive and locked piece and set to the
gunship's placeholder numbers (hull 100, shield 20, armour 0, heat 60, cooling 5) with a
five-weapon kit; each tag's bonus is a `--bump`, or for Arc's higher top roll the Muzzle
Velocity Booster with its value set. A lone machine is a diagnostic: teams and whole runs
decide.

The roster that day, for scale: the Armadillo 92, the Wild Boar 83, the Nemesis 72, the Badger
70, the Sparrowhawk 68, the Clydesdale 48, the Goshawk 36, the Ammit 34, the Prairie Dog 30, the
Stingray 26, the Baboon 25, the Dingo 11, the Puffin 11. The stand-in with no bonus: 23 to 28,
whatever its kit. Prices on it, in hull at its kit's own: armour 5 about 78, 10 about 106, 15
about 222, 20 about 349 (on five Ballistic guns, steeper as more blows bounce whole); shield
about 1 a point; a top roll 5 higher 20 to 29 on a rolled kit, 10 about 60, 15 about 100; 5 more
on every blow 58 to 68. Cooling is worth nothing on a die that never overheats (the Beam, the
mixed and the Ballistic kits at 60 heat and 5 cooling), up to about 100 hull on a die of the
hottest pieces (the Overclocked Railgun, the Photosphere Lance, the Meteor Artillery), and
little more once it pays a round's heat.

The tables tried (a weapon's amounts: Ballistic armour and cooling, Beam shield, Missile hull,
Arc the others' top roll; move and field recharge are map numbers a fight cannot read):

| Build | None | Low 2, 2, 8, 8, 2 | Mid 3, 2, 12, 12, 3 | Bold 4, 3, 16, 16, 3 | Mid, riders up 3, 4, 12, 12, 5 |
|---|---|---|---|---|---|
| Five Ballistic | 28 | 46 | 66 | 84 | 66 |
| Five Beam | 23 | 27 | 29 | 32 | 29 |
| Five Missile | 27 | 34 | 39 | 44 | 39 |
| Two Ballistic, a Missile, a Beam, an Arc | 27 | 42 | 45 | 54 | 50 |
| Two Ballistic beside three hot energy guns | 28 | 41 | 43 | 47 | 48 |
| The first mix, its two Ballistic guns Missile too | 27 | 43 | 53 | 65 | 61 |
| Five Missile and Beam pieces | 27 | 41 | 52 | 59 | 52 |
| Five Ballistic and Arc pieces | 28 | 46 | 66 | 84 | 66 |
| Five Ballistic and Beam pieces | 28 | 48 | 74 | 88 | 74 |
| Five Ballistic and Missile pieces | 28 | 55 | 83 | 92 | 83 |
| Five Ballistic, Missile and Beam pieces | 28 | 61 | 86 | 95 | 86 |

The riders-up column was run on the three mixes; the rest equal mid by construction (cooling
buys nothing on a die that does not overheat, and an Arc's roll reaches no Arc weapon). A
falling ladder on armour (5, 4, 3, 2, 1 a Ballistic weapon, five still 15) was run on the mixes
too: 57, 52 and 66.

Read: the middle, single-tag weapons in a mix, wins 48 to 50 with the riders up, the
Clydesdale's 48 and above the medium machines (the Goshawk 36, the Ammit 34). Five of one tag is
the best at its number: Ballistic in the heavy band (66 at armour 15), Missile 39 with the
fastest move, Beam 29 alone with the biggest shield, whose worth is the battle (shield returns
between fights and hull never heals), which one fight cannot see. The warp is armour, not the
doubles: every steep build is five Ballistic tags, a second tag adding its own row on top (hull
60 about 17 points, shield 60 about 8), and five Missile and Beam pieces, with no armour,
win 52. Two two-tag pieces in a mix win 61, about 11 over the plain mix; five pieces sharing two
tags win 52 to 83, sharing three 86, all under the Armadillo's 92, and Bold's armour 20 puts
five Ballistic at 84 and the three-tag die at 95, past it. So diminishing returns were not
needed at these amounts: the riders only a mix uses lift the middle with no caveat (+5 here),
and the falling ladder lifts the mixes 9 to 12 points with five Ballistic unchanged, at a
caveat's cost. Read under the honest shield rule, the shield prices and the Beam rows are the
first to want a rerun.

To reproduce, with the runner as it stands (no code added; about a minute a run on one core;
point `--out` and `--json` away from `docs/balance.md`):

```sh
STAND="--rows goshawk --nopassive --set chassis/goshawk/fixed=[] --set chassis/goshawk/hull=100
  --set chassis/goshawk/shield=20 --set chassis/goshawk/armour=0 --set chassis/goshawk/heat_max=60
  --set chassis/goshawk/cooling=5"
perl -e 'alarm 900; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 100 \
  --policies greedy $STAND --set 'chassis/goshawk/loadout=["maxigun","twin_autoguns","slugthrower","rivet_gun","flakshot_repeater"]' \
  --bump armour:15 --bump cooling:20 --out /tmp/gun.md --json /tmp/gun.json
```

The kits: five Ballistic (Maxigun, Twin Autoguns, Slugthrower, Rivet Gun, Flakshot Repeater);
five Beam (Laser Carbine, Enfilade Beam, Zenith Emitter, Umbra Inducer, Photosphere Lance); five
Missile (Howitzer, Ankle Mortar, Shotfire Rack, Suppression Battery, Incendiary Shells); the
hottest (Overclocked Railgun, Photosphere Lance, Meteor Artillery, Arc Fault Cannon, Enfilade
Beam); the first mix (Maxigun, Howitzer, Enfilade Beam, Arc Fault Cannon, Slugthrower); two
Ballistic beside three hot energy guns (Maxigun, Slugthrower, Photosphere Lance, Enfilade Beam,
Arc Fault Cannon). The tags stand in by each piece's fantasy until the stock pass assigns them.
A full die's bonus is the row times the count of its tag, given as `--bump stat:N` (armour,
cooling, shield, hull); a two-tag piece adds both rows. Arc's row is the Booster fitted with its
value set, `--module muzzle_velocity_booster --set
modules/muzzle_velocity_booster/text/effects/0/value=N` (it reaches every rolled weapon, and no
Arc weapon rolls in these kits). Prices convert a win-rate change to hull by the kit's own runs
at +20 and +40 hull. The roster's numbers are each machine's row as it stood; a machine's
passive and locked pieces together are its row against `--nopassive --set
chassis/<id>/fixed=[]`. Bible section 7 (Wainwright & Sutler's next chassis).

## 15 October

**A reroll that may land on a copy.** Ryan's call of 15 October: a reroll, the team's and
Rapid's free one, lands on any other entry, a copy of the one showing included; before it, a
reroll skipped every copy of the entry showing. The four machines whose default dice carry
copies (the Baboon two Umbra Inducers of seven entries, the Wild Boar two Slugthrowers of six,
the Nemesis two Knuckles of Fury of six, the Ammit four Soulcutter Talons of eight), each alone
against the twenty packs, greedy only (the random rung never rerolls), 100 seeds a cell, then
the same with the old rule restored. No default die carries copies of a Rapid piece, so this
measures the team's rerolls only. Mean win %, mean hull lost, rerolls a round:

| Row | Win, old rule | Win, new rule | Hull lost, old | Hull lost, new | Rerolls, old | Rerolls, new |
|---|---|---|---|---|---|---|
| Ammit | 34.2 | 33.5 | 78.8% | 78.8% | 0.90 | 0.94 |
| Baboon | 26.2 | 26.2 | 81.2% | 81.2% | 0.94 | 0.94 |
| Nemesis | 75.6 | 76.0 | 48.3% | 48.2% | 0.76 | 0.77 |
| Wild Boar | 84.8 | 84.5 | 34.5% | 34.6% | 0.93 | 0.95 |

Read: no row mean moved a point, inside the band of about 3 on a difference of two row means
at 100 seeds, and no cell moved past its band (the largest: the Ammit against two Antlions 23
to 14 and against four Bombs 50 to 41, the Nemesis against the Sandworm 47 to 54, the Wild
Boar against the Marsh formation 51 to 45). The one shift is the Ammit's pick share: its
Talons 46% of its spends to 51%, its Oblation Ward 21% to 18%, since a reroll from a Talon now
lands on another three times in seven. The default dice cannot show the change: their copies
are each machine's best entry, which the greedy bot rerolls toward, not away from, and from a
unique entry both rules land alike. The abuse the old rule allowed, copies of a filler beside
one key entry, is a build the player makes, which no default loadout is.

To reproduce, with the runner as it stands; the old rule is `sim/die.gd` at commit 987f7ee,
whose only difference is `Die.reroll`:

```sh
perl -e 'alarm 1500; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 100 \
  --policies greedy --rows baboon,wild_boar,nemesis,ammit --out /tmp/new.md --json /tmp/new.json
git show 987f7ee:sim/die.gd > sim/die.gd    # the old rule, then the same run to /tmp/old.*
git checkout -- sim/die.gd
```

About ten minutes a run on one core. Bible section 6 (the rerolls row).

**The Flakshot Repeater as a flat 5 that sprays** (the Prairie Dog's go, 19 October). The
Prairie Dog's solo row rerun with the Repeater at Direct, flat 5, Spread, Rapid, its Flak
planned and so not run (`tools/balance.gd --rows prairie_dog`, 200 seeds a cell,
random/greedy, 8,000 fights), against the 13 October report at the same seeds: the row did
not move. The Wolves 65/98 (64/98 before), the Gels 0/16 (0/14), the Needlers 5/28 (1/32), the
Antlions 2/25 (5/26), the Ghosts 82/100 (79/100), the Bombs 1/18 (0/20), the Drakes 39/62
(32/72), the Treant 3/25 (2/30), the rest at 0 or 100 as before; the Repeater's share of its
spends 15% (18%), its hull left within a few points everywhere. Read: a flat 5 that sprays is
worth about what a rolled 5 to 15 single shot was, less on a pack of two and more on a full
rank, so the built half of the go changes nothing alone, and Claude's Spread-alone shape
would not have moved the row either; the fight half is Flak's, and the row is re-read when
the engine has it (the to-do). The maker's trio (the Clydesdale, the Prairie Dog, the Dingo;
`--rows "wainwright_sutler team"`, 8,000 fights, 947 s) did not move either: the Goblins
90/100 (91/100), the Meadow formation 3/96 (4/99), the Waste 40/100 (34/100), the Marsh 0/5
(0/12), the Peak 0/59 (0/68), everything else at 97 to 100. Its pick shares are no clean read
of the Repeater, since the 13 October report predates the harpoon's Shock (15 October): the
Harpoon 9% (17%), the Twin Autoguns 23% (16%), the Ankle Mortar 8% (5%), the Repeater 6%
(8%), rerolls 1.97 a round (2.30). Bible section 7, the Prairie Dog row.

## 18 October, the funnel-web alone

**The funnel-web's row alone, a diagnostic the day its engine landed.** `tools/balance.gd
--rows funnel_web --seeds 30`, both rungs, the stock stand-ins (the Web Bomb, the Maxigun, the
Howitzer, the Twin Autoguns, the Laminar Deflector), the bot valuing a bite by Vitriol's ticks
on the hull the blow leaves and a web by the blows its burst stops. Thirty seeds: a direction.
Random / greedy win rates: 0 / 0 against the Goblins, the Revenants, the Salamanders and every
formation; 7 / 87 the Gels, 80 / 90 the Needlers, 67 / 97 the Antlions, 10 / 13 the Bombs,
13 / 87 the Treant, 3 / 37 the Sandworm, 13 / 87 the Bone Wyvern, 0 / 3 the Magma Golem; 100 /
100 against the Dire Wolves, the Mandragoras, the Cockatrices, the Ghosts and the Drakes. Pick
share, greedy: Web Bomb 30%, Maxigun 30%, Howitzer 21%, Laminar Deflector 11%, Twin Autoguns
7%; 0.92 rerolls a round.

Read: alone it is a plain d5 with a web and loses where every machine alone loses, which is
tier two's shape and what the brief said. Alone, every foe aims at it, so the ambush bites
only through the window its own web opens (the webbed foe held the round after shows no
intent) and the row cannot read the passive; the web's third of its spends is the die's odds
(one entry in five, rerolled toward) and the bot's valuation of a stun it can always use, no
must-pick read, since no team row ran. The reads the bible's funnel-web row asks for (the
share of its blows that bite, the web's share in formation fights, the Baboon pairing) are
team rows at 200 seeds, after the stock pass; the runner does not yet count the bites.

## 21 October, Flak on the Prairie Dog

**The Prairie Dog's rows with and without Flak, the day its engine landed.** `tools/balance.gd
--rows prairie_dog,team,"wainwright_sutler team" --seeds 200`, both rungs, against the same run
with the Flakshot Repeater's Flak knocked out (`--set
components/flakshot_repeater/face/keywords=["cleave"]`: its Spread and its flat 5 kept, and the
Prairie Dog's 5 less from a Flak carrier asleep with it, so the delta is the keyword and its
clause together). On the Flak commit (`5abc6760`), before the honest shield. At 200 seeds a
row mean's band is about 1.5 points.

Row means, random / greedy, without and then with Flak: the Prairie Dog alone 12.0 / 22.0 and
16.2 / 28.6; the Wainwright & Sutler team (Clydesdale, Prairie Dog, Dingo) 77.6 / 91.3 and 79.4
/ 91.8; the default team, which carries no Prairie Dog, the same both times (96.9 / 100). The
Prairie Dog's greedy cells that moved: the Gels 0 to 24, the Needlers 0 to 22, the Antlions 2
to 19, the Bombs 0 to 13, the Drakes 21 to 57, the Dire Wolves 86 to 96; random, the Dire
Wolves 11 to 38, the Ghosts 33 to 74, the Drakes 1 to 12. The team's: the Goblins and the
Revenants 80 to 88 random, the Peak's formation 35 to 42 greedy. Pick share, greedy, the
Flakshot Repeater: 18% to 19% alone, 7% to 10% on the team.

Read: Flak is worth about six points of the Prairie Dog's row alone, outside the band, and a
point or two on its maker's team, where the row stands near its ceiling and reads a direction
only. The gain sits where many blows land on one foe (the Gels, the Needlers, the Antlions) and
against the Drakes. The family's numbers are the stock pass's (the bible's Prairie Dog row).

## 21 October, the reports

**The balance report at 200 seeds after the shield rule** (`docs/balance.md`: 255,200 fights,
four parts side by side, on the Kite's commit `f1b8c663`). Twenty-two rows (the Cassowary, the
Cottonmouth and the Whip Scorpion runnable that day; the Swallowtail, the Musk Ox and the
Lammergeier not yet, so their rows wait on the next rerun) against twenty-nine packs: the twenty
of 13 October and the party's nine (each bench hero's final, the hero with three of its domain's
first pack, and the finale, the four first heroes promoted). It reads everything landed since 13
October together, the honest shield, Barrier, Ward and cooldowns among it, so a delta reads the
week, not one rule. A run on the shield rule's own commit (`b8cf462e`, 152,000 fights, the
twenty packs) stands between: every row the later commits left alone reads the same in both to
the decimal (the seeds are the same), so what moved from it to the report is the Kite's rework,
the Puffin's, the Dingo's Translocator and the bot's seal. Row means over the twenty packs,
random / greedy:

| Row | 13 October | The shield commit | The report |
|---|---|---|---|
| Honey Badger | 50.5 / 74.3 | 50.4 / 73.5 | 50.4 / 73.5 |
| Clydesdale | 34.9 / 48.0 | 32.1 / 47.5 | 32.1 / 47.5 |
| Kite (the Sparrowhawk until its rework) | 49.3 / 67.7 | 44.1 / 58.9 | 21.2 / 26.9 |
| Baboon | 12.7 / 26.5 | 12.2 / 25.4 | 12.2 / 25.4 |
| Armadillo | 79.0 / 94.7 | 25.9 / 39.0 | 25.9 / 39.3 |
| Wild Boar | 55.3 / 84.9 | 55.2 / 82.0 | 55.2 / 82.0 |
| Prairie Dog | 19.2 / 31.1 | 15.8 / 23.4 | 15.8 / 23.4 |
| Dingo | 4.0 / 11.2 | 4.5 / 10.8 | 2.6 / 10.4 |
| Buzzard | 19.9 / 36.7 | 17.7 / 33.1 | 17.7 / 33.1 |
| Nemesis | 48.2 / 76.2 | 47.5 / 73.6 | 47.5 / 73.6 |
| Ammit | 21.6 / 33.9 | 19.6 / 29.5 | 19.6 / 29.5 |
| Stingray | 13.8 / 26.6 | 11.8 / 24.3 | 11.8 / 24.3 |
| Puffin | 0.9 / 11.1 | 0.9 / 10.7 | 0.4 / 9.2 |
| Funnel-web | | 31.4 / 45.0 | 31.4 / 45.0 |
| Cassowary | | | 7.5 / 16.8 |
| Cottonmouth | | | 12.8 / 30.1 |
| Whip Scorpion | | | 48.5 / 74.0 |
| The starting team (Honey Badger, Clydesdale, Kite) | 97.0 / 100 | 96.8 / 100 | 92.7 / 100 |
| Minerva Heavy Works team | 100 / 100 | 99.5 / 100 | 99.5 / 100 |
| Kestrel Dynamics team (Kite, Buzzard, Puffin) | 81.7 / 90.9 | 80.0 / 90.5 | 67.4 / 84.0 |
| Wainwright & Sutler team | 80.9 / 94.0 | 74.5 / 91.3 | 73.2 / 91.4 |

Read: the rows the week did not rework move a few points at most (the Badger, the Boar, the
Nemesis and the Clydesdale three or less, the Ammit and the Buzzard four), under the honest
shield and the 18 October rules together (Armoured and Overcharged in points, Burn numbered).
The shield rule alone, read from the Flak entry's rows on its parent (`5abc6760`, the same
seeds): the Wainwright & Sutler team 79.4 / 91.8 to 74.5 / 91.3, the Prairie Dog 16.2 / 28.6 to
15.8 / 23.4, the starting team 96.9 / 100 to 96.8 / 100; of the Peak's cells it was to move, the
Wainwright & Sutler team's formation 42 to 34 greedy and the Prairie Dog's Drakes 57 to 50,
directions at one cell's band. The Armadillo alone falls from the top of the table to the middle
with its rework (20 October), a team tank whose team holds: alone it loses every formation,
every boss (2 greedy at most), the Goblins, the Revenants and the Salamanders (a trace, six
Goblins at seed 1: open it takes 15 a blow where the old shell took 5, sealing costs the round's
action, and it falls in five rounds). The Kite's rework halves its row alone and takes the
starting team's Peak and Marsh formations from 66 and 73 to 30 and 26 random, and the Kestrel
team's Waste formation from 35 / 99 to 1 / 57. The party's cells: every team row wins every
final greedy (the Kestrel team's lowest, the Martial Artist's, 37 / 100), the starting team and
Minerva's in both rungs at 100, so a final against a team is no decision; the finale is a wall
for three teams (the starting team 0 / 16, Kestrel's and Wainwright & Sutler's 0 / 0) and a
decision for Minerva's (3 / 71). Alone, the Badger, the Boar, the Nemesis and the Whip Scorpion
win every final a third of the time or more greedy and the Cleric's, the Augur's and the
Summoner's nearly always; the Clydesdale, the Armadillo, the Funnel-web, the Buzzard and the
Cottonmouth take a few; the rest lose nearly all of them. The new rows: the Whip Scorpion in the
Nemesis's band (the Bombs 91 / 100, the Drakes 100 / 100), the Cassowary among the weakest alone
(its Spin-Up and its Coolant Jacket never picked: the bot turns the dial and never plans, the
to-do's line). The heat section, new: the Whip Scorpion peaks at 83% of its maximum, the Kite
79%, the Armadillo 74% with 0.73 overheats a fight, and the Kestrel team holds back 0.72
damaging dice a fight for heat; the stock pass's heat re-pricing reads these.

**The campaign's wall, found** (the to-do's line of 21 October; `docs/campaign_run.md`
regenerated on main, `32c438ab`). A bisect at three runs a probe (`tools/campaign_run.gd --runs
3`, seeds 1 to 3: 27% of 36 battles won on the 13 October report's commit `b15e2707`, none of 29
on main) lands on the Armadillo's rework (`fdb8d6c1`, 20 October: 3% of 33), its parent the
merge of main into the Minerva branch (`63487a9c`: 27% of 36). Forty runs either side: 12 of 40
runs won and 27% of 459 battles before it, 1 of 40 and 5% of 391 after. Before it the Armadillo
started 20 runs and won 11, the other 20 won one; after it the Armadillo's won none and the rest
still one, so the rework took the Armadillo's runs and nothing else. Forty runs on main's line
after it: 4% of 391 battles on the Minerva merge (`459ada33`), 1% of 374 after Flak and the
shield rule (`9ac36662`), 1% of 373 with the day's engines and the party (`899a7725`), and 0 of
40 runs, one battle in 348, from the Kestrel merge on (`eee55775`, and main), where the tender
the draft deals from has changed under the same seeds (the Puffin at tier one, the Cassowary and
the Cottonmouth dealt, the Kite and the Dingo gone to tier two). On main, 572 of 734 fights hold
one machine; one machine against one pack wins 31% (64% on 13 October), two together 64 to 76%.

Read: no bug. The old Armadillo was the one machine that carried a lone fight (alone 79 / 95
over the twenty packs, the next the Boar at 55 / 85), and the plain player's fights are mostly
one machine alone; the reworked one is the team tank its bible row decided. The rest of the
slide is the week's small moves on a run that had no margin left, not a second break. The
campaign report reads nothing while every run is lost: its number waits on a player that fights
as a team (the status's fourth item), Ryan's question in the bible's section 12.

## 22 October, the baseline before the stock pass

**The balance report at 200 seeds on main's head of the morning** (`a1585a9`, before the stock
pass's engine chunk: `docs/balance.md`, 290,000 fights, four parts side by side in a worktree
while the chunk was built beside it; the report as that commit's runner writes it, so it has
the reach table's splash column and no rounds-to-win section). The before for every band the
stock pass's landing reads. Every row the day's main left alone reads as on 21 October to the
decimal (the seeds are the same), so what moved is the commits between the two: the Clydesdale
32.1 / 47.5 to 33.0 / 49.1, the Funnel-web 31.4 / 45.0 to 32.6 / 47.8, the Whip Scorpion 48.5 /
74.0 to 48.9 / 74.8 and the Wainwright & Sutler team's greedy 91.4 to 91.7, which fits the fix
of 21 October that made a multi-strike gun pay its heat once a spend. The new rows, alone, row
means over the twenty packs, random / greedy:

| Row | The baseline |
|---|---|
| Swallowtail | 16.4 / 42.0 |
| Musk Ox | 56.4 / 67.5 |
| Lammergeier | 3.0 / 27.1 |

Read: the Musk Ox alone stands with the Boar and the Badger at the top of the random rung and
lower on the greedy (its salvo is random by design and the bot's ammo pricing a first reading);
the Swallowtail is a carrier whose pieces work on allies, so alone it is a diagnostic; the
Lammergeier's mines wait on reinforcements, which most packs do not field. The party's cells
read as on 21 October (every team wins every final greedy; the finale 0 / 16 for the starting
team, 3 / 74 for Minerva's, 0 / 0 for Kestrel's and Wainwright & Sutler's). Heat, greedy, the
before for the heat test (a hot kit overheats by its third round of firing): the hottest rows
peak at 70 to 80% of their maximum as a turn ends (the Whip Scorpion 81%, the Kite 79%, the
Armadillo 74%, the Nemesis 71%), overheat under once a fight (the Armadillo 0.73, the rest under
0.45) and hold back a damaging die for heat almost never (the Kite 0.28 a fight, the Kestrel
team 0.72, everything else under 0.11); the Buzzard, whose passive turns heat to shield, peaks
at 20%. So heat barely bites today, the stock pass's heat row's premise.

**The coordination gap today** (the stock pass's Rounds to win, on main's engine at `a1585a9`
with the branch's report code alone: the team rows against the twenty-nine packs at 200 seeds,
58,000 fights, four parts beside the baseline). Random's rounds over greedy's, a mean over the
cells both rungs win at least a quarter of:

| Team | The big fights | The rank and file |
|---|---|---|
| The starting team (Honey Badger, Clydesdale, Kite) | 1.63 over 16 | 1.56 over 12 |
| Minerva Heavy Works team | 1.62 over 16 | 1.60 over 12 |
| Kestrel Dynamics team | 1.57 over 11 | 1.57 over 12 |
| Wainwright & Sutler team | 1.40 over 12 | 1.35 over 12 |

The big fights are the massive foes, the bosses, the formations and the finals; the rank and
file the twelve packs of wildlife. Read: greedy wins about half again as fast everywhere, the
big fights no more than the rank and file, so today's gap is an efficiency edge (the better
target, no die wasted), not the coordination gap the tests ask for (the bible's section 2: about
2 on the big fights and none on the rank and file, which at today's scale take several blows
each). The landing reads it again: the rank and file dying to a die or two should close their
gap, and the big foes' HP span open theirs. A direction at the cells' count, read as a band.

**The campaign report** (`docs/campaign_run.md`, 40 runs) rerun on the same commit reads line
for line as 21 October's, its header's date aside: the day's main changed nothing the plain
player's runs touch.

## 22 October, the stock pass's fills as a direction

**The brief's first fills, run before Ryan's marks** (sections 1 to 5 of
the stock pass's brief, `git show a550c2e:docs/briefs/stock_pass.md`, applied by script to a scratch checkout of the branch: every
chassis's, component's, foe's and module's numbers, the status values and the engine constants
of section 1's tables; today's stocks, since the new pieces do not exist; no module fitted;
the goblins' and revenants' swarm, the Prairie Dog's Flak clause, the Lammergeier's, the
Pinion Driver's and the Lorentz Contractor's numbers filled by scale, since the brief had
none). Every row against the twenty-nine packs at 30 seeds (43,500 fights) with the branch's
Rounds to win, and the campaign report at 40 runs. A direction, read as bands against the
design tests (the bible's section 2):

| Test | At the fills | At the baseline |
|---|---|---|
| Rank and file die to a die or two | a team wins a wildlife pack in 1.0 to 3.1 rounds greedy, 1.3 to 4.0 random; one machine in 2.4 to 10 | passes |
| A massive foe, a round or two of focus | a team of three takes 3.4 to 6.2 rounds greedy on the Treant and the Wyvern, 4.7 to 11.5 on the Sandworm, 5.2 to 10.4 on the Golem; alone, the Armadillo, the Boar, the Swallowtail and the Musk Ox stall past sixty rounds on the Treant and the Wyvern, whose regrow of 5 outpaces what their blows leave past armour 1 | fails by two to five times |
| The coordination gap, about 2 on the big foes, none on the rank and file | the teams 1.39 to 1.56 on the big fights and 1.23 to 1.55 on the rank and file | 1.40 to 1.63 and 1.35 to 1.60: unchanged, and the same on both kinds |
| Wear, about four hard fights unwithdrawn | a team loses 0.2 to 1.5% of its hull on a wildlife pack, 8 to 22% on a massive foe, 2.5 to 12% on a formation, 0.2 to 1.8% on a final | 0.2 to 4.8%, 8 to 42%, 7 to 84%, 1.5 to 11% |
| A hot kit overheats by its third round | the Kite peaks at 101% and overheats 0.88 a fight, the Baboon 83% and 0.82, the Nemesis 90% and 0.46, the Stingray 72%, the Whip Scorpion 70%; the other fifteen rows peak at 11 to 49% and hold no die for heat | the Scorpion 81%, the Kite 79%, the Armadillo 74%, the Nemesis 71%, the rest cold |

Win rates, row means over the twenty packs, random / greedy: every team 95 to 100 / 100 (the
baseline 67 to 99 / 84 to 100); alone, every machine rose, most by fifteen to thirty points on
the random rung (the Kite 21 to 48, the Baboon 12 to 36, the Cottonmouth 13 to 48, the Buzzard
18 to 49, the Ammit 20 to 49, the Lammergeier 3 to 28; the Badger 50 to 58, the Boar 55 to 61);
the finale is a wall for all four teams (0 / 0; Minerva's 3 / 74 at the baseline). The
campaign's plain player wins 7% of battles (0% at the baseline), 36% of its three-machine
battles (2%) and 48% of its lone fights (31%), and 36 of 40 runs reach the finale (16); no run
is won.

Read: the fills are not derived from the tests; they are the old numbers divided, unevenly.
Our hull is divided by about four and a half and our shields by four, the foes' blows by five
to six, our damage by five, and the rank and file's HP by eight to ten (the Goblin 30 to 3, the
Needler 20 to 2, the Antlion 50 to 6). Two tilts toward the machines follow: trash dies about
twice as fast relative to our blows, which the first test asked for, and the machines take
about a quarter less relative to the foes' blows, which nothing asked for; so every pack but
the finale is a free win for a team, on the random rung too. The massive foes divided by four
and a half kept their ratio, and their armour bites steeper at single digits (2 off blows of 1
to 3 is a wall where 5 off 10 to 20 was half), so the rounds a team takes on them rose while
the rank and file fell: the gap between smashing and playing did not open, because the greedy
rung is a one-round bot that sets up only where the setup pays within the round, and on a
braced worm it does not, so the runner's two rungs cannot read the third test as written. The
heat classes keep today's ratios (a cool gun's 1 or 2 against a maximum of 16 and cooling 1),
so heat bites on the five kits that ran hot before and is decoration on the rest. What moves,
for the marks: the foes' blows up by half to double (the rank and file 2 to 3, the elites 6 to
8, the bosses 8 to 12) or our hull and shield down a quarter; cooling 0 on most chassis with
the typical gun at 2 to 4, or the maxima 10 to 14; the massive elites' armour 1 rather than 2
if basics are to touch them, else Flak, Shock and Exposed are the only way in; the regrow of
the Treant and the Wyvern at 3; and a rung that sets up over two rounds before the gap can be
read. The bot's valuations under the new constants are a first reading (the Musk Ox's greedy
rung wins slower than its random one, its ammo pricing holding fire).

## 22 October, the planner and blind rungs on today's content

**The two rungs the coordination gap is read between, first run** (the stock pass's second
chunk; the bible's row on the two rungs): the default team (the Honey Badger, the Clydesdale,
the Kite) against the twenty packs, `--rows team --noparty`, 10 seeds a cell, each rung alone
(`--policies greedy`, `blind`, `planner`), on today's content at the old scale and today's
stocks. A direction, and a check that the rungs run; the gap the tests ask for is read on the
landed content.

| Read | Big fights (the four massive foes and the four formations) | The rank and file (twelve packs) |
|---|---|---|
| Blind play's rounds over the planner's | 1.20 over 8 cells (0.92 to 1.55) | 1.11 over 12 (1.00 to 1.28) |
| Blind over the greedy | 1.20 (1.00 to 1.43) | 1.11 (1.00 to 1.26) |
| The greedy's over the planner's | 0.99 (0.92 to 1.09) | 1.00 (0.95 to 1.03) |

Every rung wins every cell but blind play's 80% on the Peak's formation. Mean hull lost over
the twenty packs: blind 10.7%, greedy 5.5%, the planner 4.9%. The planner weighed 2.6 to 8.6
decisions a fight on the rank and file and 7 to 23 on the big fights, and spent otherwise than
the greedy at 22 to 32% of them on the massive foes and 40 to 45% on the formations. Its cost:
548 s against the greedy's 156 and blind play's 176 for the same 400 fights (the team row and
its comparison row), about three and a half greedy fights a fight, after the rollouts stopped
rerolling the next round's dice (five times cheaper; 15 greedy fights a fight before).

Read: blind play removes most of the random rung's waste on trash (1.11 where random over
greedy read 1.35 to 1.60 at the baseline), so the trash test reads near its "no gap" on it. The
planner plays the greedy's game in rounds on this content: the stocks hold few setups that pay
a round later, and its fight's worth counts hull as well as kills, so where it parts from the
greedy it buys hull (4.9% against 5.5%) more often than rounds. The gap on the big fights is
the greedy's 1.2 over blind play. What follows: the read waits for the landed stocks (the Flak
family, the Backdraft Charge, the Shock pieces beside the hitters); if the planner still plays
the greedy's rounds there, its worth or its horizon is the next thing to read, never the
content.

## 22 October, the stock pass's loops

**The loops on the landed content** (the stock pass's brief, `git show a550c2e:docs/briefs/stock_pass.md`, section 7, step 2; copies of
the branch between `dd3037c` and `d4e009a`, the same in play; Flak's clock a field since
`9c32ecf`, which the Flak loops' copies carry). Each loop is a copy of the branch with its
levers moved in the copy's content, the balance runner at 30 seeds a cell on the four team rows
(the default team as a `--team` row, so the targeting comparison is skipped; Minerva Heavy
Works', Kestrel Dynamics' and Wainwright & Sutler's) against the twenty-nine packs, and the
campaign report at 40 runs where the lever reaches the campaign. Each loop carries the levers
kept before it, and a lever that touches only its own foes is read on their packs alone
(`--packs`; the bosses fight in no other cell). The kept levers are `tools/stock_fills.py`'s
fills since. Directions, read as bands against the tests (the bible's section 2).

**Loop 0, the landed fills**, every rung, and every chassis alone, greedy, without the party:

| Read | The default team | Minerva's | Kestrel's | Wainwright & Sutler's |
|---|---|---|---|---|
| A wildlife pack, greedy rounds | 1.6 | 1.7 | 1.6 | 2.2 |
| A massive foe, greedy / planner rounds | 3.9 / 3.9 | 9.8 / 10.0 | 3.1 / 3.1 | 9.8 / 7.9 |
| The gap, big fights / rank and file | 1.18 / 1.04 | 1.03 / 1.09 | 1.13 / 1.03 | 1.15 / 1.15 |
| Hull lost, greedy: massive / formation / final | 10 / 5 / 0.5% | 24 / 3 / 0.8% | 12 / 7 / 1.5% | 35 / 12 / 2.6% |
| Random's wins: massive / formation / final | 87 / 100 / 100% | 71 / 100 / 100% | 94 / 89 / 100% | 52 / 72 / 100% |

Every rung wins every wildlife pack, and the finale is a wall (no rung wins it; Kestrel's
greedy 3%). Blind play takes the greedy's rounds on a lone massive foe, whose nearest foe is the
only one. Heat bites one kit alone: the Kite peaks at 96% of its maximum and holds a die for heat
a quarter of fights; the Nemesis 76%, the Buzzard, the Stingray and the Whip Scorpion 67 to 70%,
the rest 5 to 47%. The campaign: 7% of battles won, 92% ended in a team wipe, a lone machine wins
40% of its fights.

**Loops 1 and 2, the bosses' own cells**, every rung:

- **Armour 1 on the Sandworm and the Golem.** Minerva's and Wainwright & Sutler's 11.6 to 12.9
  greedy rounds on them become 7.2 to 7.6, and their hull lost there, 40 to 81%, becomes 23 to
  47% (Wainwright & Sutler's Golem from 67% won to all); the default team's and Kestrel's 3.4 to
  5.0 rounds become 3.2 to 3.8. The gap stands (1.00 for three teams; Wainwright & Sutler's 1.22
  becomes 1.15), and random play now beats both with Minerva's team (63 and 20% before). Kept.
- **Regrow 3 on the Treant and the Wyvern.** Minerva's 7.0 rounds become 6.7 and Wainwright &
  Sutler's 7.9 become 7.2; the other two teams read the same. Neither foe costs any team more
  than 1% of its hull: the shields recharge their blows. Kept (no cost, and the lone stall).

**Loop 3, the wear**, random and greedy, with the campaign, the two alternatives side by side:

| Read | The foes' blows up (rank and file ×1.5, massive ×1.33, heroes ×2) | Our hull and shield ×0.75 |
|---|---|---|
| Hull lost on the formations, greedy (default / Minerva / Kestrel / W&S) | 8 / 7 / 10 / 36% | 7 / 4 / 9 / 20% |
| On the finals | 2 / 4 / 5 / 12% | 1 / 2 / 3 / 4% |
| Random's wins on the formations | 96 / 100 / 58 / 23% | 99 / 100 / 78 / 48% |
| The campaign's battles won | 1% | 2% |

A single wildlife pack costs no team more than 2% of its hull under either. Kept: the blows (the brief's first
lever; the formations gain a decision band, random losing where greedy wins, and the finals a
cost). Wainwright & Sutler's team, with two machines of 16 hull, takes three to five times the
others' wear.

**Loop 4, the heat**, random and greedy on the team rows and every chassis alone, greedy, the two
alternatives side by side (peak heat a fight, alone):

| Kit | Loop 0 | Cooling 0 | Maxima 20 to 14, 16 to 12, 10 to 8, 8 to 6 |
|---|---|---|---|
| The Kite / the Nemesis / the Buzzard | 96 / 76 / 70% | 102 / 81 / 67% | 107 / 89 / 85% |
| The Stingray / the Whip Scorpion | 70 / 67% | 60 / 62% | 78 / 78% |
| The Badger / the Boar / the Clydesdale | 24 / 22 / 26% | 35 / 37 / 48% | 27 / 26 / 30% |

The team rows' wins and rounds do not move under either. Kept: the maxima, which heat the hot
kits (the Nemesis overheats half a fight, the Stingray holds a die for heat a sixth of fights)
and leave the cold ones cold, where cooling 0 warms every kit a little; the Kite's 10 and the
Musk Ox's 8 stand (the Kite peaked at 96% at 10; the Musk Ox's forge keeps it cold at any
maximum).

**Loop 5, Flak's clock**, every rung on the big fights of the two teams that lay Flak (Wainwright
& Sutler's and the default team, whose Clydesdale fires the Airburst Shell), the halving against
a stack a round: alike. Wainwright & Sutler's planner takes 6.3 and 6.4 rounds on the Treant,
7.2 and 6.9 on the Sandworm, 7.8 and 7.4 on the Golem; the massive foes' mean 7.6 and 7.7 greedy,
the gap 1.20 under both; the default team's cells read identically. Today's feeds lay a stack or
two a spend, where the two clocks are the same, so the call is readability (the bible's section
12). Not moved.

**A diagnostic on the landed set**, every rung at 30 seeds: the default team beside the same
team with the Dingo added, a fourth die and the only Shock it would carry (its harpoon). The four
take a massive foe in 2.5 rounds where the three take 3.4 (the planner; blind play 3.1 and 3.4),
and the gap on the massive foes opens from 1.01 to 1.25 (the big fights 1.16 to 1.26, the rank
and file 1.04 to 1.08); the finale stays a wall for both.

**Read**: the landed set (the blows, the elites' armour, the regrows, the maxima) moves the wear,
the free wins and the heat toward their tests and leaves two tests where they stood. The kill
time on a massive foe stays at 3 to 8 rounds against the test's one or two: a team of three
lands 5 to 10 a round past armour against 32 to 40 HP, so a round or two needs about half
the HP or more blows. The gap stays at 1.0 to 1.2 on the big fights: it opens only where a stock
carries a setup (Wainwright & Sutler's Shock and Flak, 1.2), and three of the four teams carry no
Shock; a fourth machine with a Shock takes the default team to 2.5 rounds and 1.25. The finale
stays a wall, and the campaign's plain player, who fights alone most of the
time, wins 1% of battles. Those reads are Ryan's (the bible's section 12), with the bands at 200
seeds.

## 22 October, the stock pass's bands at 200 seeds

**The balance report at 200 seeds on the landed numbers** (`docs/balance.md`, on `cf7d283`:
290,000 fights in four parts, 6,462 s), read beside the baseline of the morning (`ace3c3c`, run
on `a1585a9`: the old scale and the old stocks, so a row's change is the whole stock pass, never
one lever); the coordination gap at 200 seeds, blind play and the planner on the team rows'
seventeen big fights (`--packs big`, the default team as a `--team` row, 27,200 fights); the
campaign report at 40 runs (`docs/campaign_run.md`). Bands, not directions.

Row means over the twenty packs, random / greedy:

| Row | The baseline | Landed |
|---|---|---|
| Honey Badger | 50.4 / 73.5 | 43.9 / 66.8 |
| Clydesdale | 33.0 / 49.1 | 39.9 / 60.1 |
| Kite | 21.2 / 26.9 | 34.8 / 50.5 |
| Baboon | 12.2 / 25.4 | 24.2 / 39.6 |
| Armadillo | 25.9 / 39.3 | 28.2 / 37.4 |
| Wild Boar | 55.2 / 82.0 | 47.9 / 69.8 |
| Prairie Dog | 15.8 / 23.4 | 8.0 / 19.1 |
| Dingo | 2.6 / 10.4 | 7.7 / 21.4 |
| Buzzard | 17.7 / 33.1 | 46.9 / 74.8 |
| Nemesis | 47.5 / 73.6 | 59.8 / 73.2 |
| Ammit | 19.6 / 29.5 | 36.2 / 55.5 |
| Stingray | 11.8 / 24.3 | 23.2 / 30.3 |
| Puffin | 0.4 / 9.2 | 4.7 / 20.0 |
| Funnel-web | 32.6 / 47.8 | 34.2 / 47.8 |
| Cassowary | 7.5 / 16.8 | 16.1 / 23.4 |
| Cottonmouth | 12.8 / 30.1 | 34.0 / 54.3 |
| Whip Scorpion | 48.9 / 74.8 | 40.7 / 64.3 |
| Swallowtail | 16.4 / 42.0 | 19.5 / 41.7 |
| Musk Ox | 56.4 / 67.5 | 56.9 / 49.2 |
| Lammergeier | 3.0 / 27.1 | 19.5 / 56.0 |
| The default team | 92.8 / 100 | 98.5 / 100 |
| Minerva Heavy Works team | 99.5 / 100 | 99.3 / 100 |
| Kestrel Dynamics team | 67.4 / 84.0 | 91.0 / 100 |
| Wainwright & Sutler team | 73.2 / 91.7 | 75.3 / 98.0 |

The team rows by kind of fight, greedy (random's wins in brackets):

| Team | A wildlife pack | A massive foe | A formation | A hero's final |
|---|---|---|---|---|
| The default team | 1.6 rounds, 1% hull (100) | 3.3 rounds, 10% (98) | 4.2 rounds, 7% (94) | 2.4 rounds, 2% (100) |
| Minerva's | 1.8, 1% (100) | 7.2, 19% (97) | 5.1, 7% (99) | 3.8, 4% (100) |
| Kestrel's | 1.6, 1% (100) | 2.9, 13% (95) | 3.9, 14% (60) | 2.5, 5% (97) |
| Wainwright & Sutler's | 2.2, 2% (100) | 7.8, 32% (54) | 7.4, 37% (22) | 4.4, 11% (90) |

The finale stays a wall: no rung wins it on any team row. Free wins (random winning 90% or more)
are 28, 27, 22 and 19 of the twenty-nine packs on the four teams; walls (greedy under 25%) one
each, the finale. Alone, a machine meets walls on 6 to 24 of the twenty-nine and free wins on 0
to 11.

Heat, greedy, the hottest machine as a turn ends: the Nemesis 94% of its maximum (0.50 overheats
and 0.17 dice held for heat a fight), the Kite 92% (0.29, 0.18), the Buzzard 87%, the Whip
Scorpion 78%, the Stingray 74% (0.16 held), the Lammergeier 56%; every other kit 6 to 44%. The
baseline's hottest were the Whip Scorpion 81%, the Kite 79%, the Armadillo 74% and the Nemesis
71%, with everything else cold.

Pick share, greedy: the Ammit's Entropy Condenser 0%, the Dingo's Combat Translocator 1%, the
Lammergeier's Syrinx Drone, Lorentz Contractor and Polarity Projector 2 to 3%; the Coolant
Jacket 1 to 6% on ten kits, 14% on the Musk Ox (whose forge turns a vent into ammo) and 33% on
the Whip Scorpion (whose vents are its guns); the Kite's Bleed Valve 18%.

**The gap at 200 seeds**, blind play's rounds over the planner's on the big fights both win a
quarter of (sixteen a team; neither wins the finale): the default team 1.16, Minerva's 1.05,
Kestrel's 1.16, Wainwright & Sutler's 1.17. On a lone massive foe it reads 1.00 to 1.03 for the
three teams that carry no Shock and 1.21 for Wainwright & Sutler's (8.0 rounds against 6.6); the
formations read 1.14 to 1.26 and the finals 1.03 to 1.21. The planner spent otherwise than the
greedy on 19 to 36% of the decisions it weighed (7 to 12 a fight).

**The campaign** (40 runs, the plain player): no run won, 25 of 40 reaching the finale (32 at
loop 0, 36 at the first fills), 1% of 368 battles won and 98% ending in a team wipe, a lone
machine winning 23% of its fights (40% at loop 0); a battle the squad fields three for is won 9%
of the time.

**Read**: the landed set holds at 200 seeds what the loops read at 30. Met: the rank and file
die in under two rounds for every team and cost it nothing; a formation costs a team 7 to 37% of
its hull and a final 2 to 11%, and the two lighter teams' formations hold a decision band (random
winning 60 and 22% where greedy wins 100 and 95); heat bites the hot kits and leaves the cold
ones cold. Not met, Ryan's reads (the bible's section 12): a massive foe takes a team of three
2.9 to 7.8 rounds against one or two; the gap reads 1.05 to 1.17 against about 2, opening on a
massive foe only where a team carries a Shock; random play still wins 19 to 28 of the
twenty-nine packs a team, so outside the formations a team of three meets no decision; the
finale is a wall; and the campaign's plain player, fighting alone most of the time, wins 1% of
battles. The lone machine and the team of three stand far apart (walls on 6 to 24 packs alone,
free wins on 19 to 28 as three).

## 22 October, the light hulls at the floor

**The review's one content change, confirmed** (Ryan's go, the evening of the bands): the four
light machines' hull from 16 to 20, the scales row's floor (the Prairie Dog, the Dingo, the
Puffin, the Cottonmouth; the Kite's paper hull 12 stands, its row's one-off), so a hero's
finisher at the doubled blow (the Black Mage's Flare at 16 through the shield, the Lancer's Dive
at 15) no longer takes one from full. Run with `tools/stock_loop.py` on the content as landed:
the two teams that field them, every rung at 30 seeds against the twenty-nine packs; the five
light machines alone, greedy, without the party; the campaign at 40 runs. A direction, read
against the bands at 200 seeds (above, at hull 16):

| Read | Kestrel's team, bands then now | Wainwright & Sutler's, bands then now |
|---|---|---|
| A formation: random's wins / greedy's hull lost | 60% / 14% then 59% / 12% | 22% / 37% then 29% / 31% |
| A massive foe: greedy rounds / hull lost | 2.9 / 13% then 2.9 / 12% | 7.8 / 32% then 7.4 / 25% |
| A final: greedy hull lost | 5% then 5% | 11% then 10% |
| The gap, big fights | 1.16 then 1.17 | 1.17 then 1.15 |

The rank and file still die in under two rounds for both; the finale stays a wall; the hot
kits' heat does not move. Alone, greedy, the four read as before (walls on most packs: the
Prairie Dog wins 35% of the wildlife packs, the Dingo 38%, the Puffin 39%, the Cottonmouth 91%,
none a massive foe). The campaign reads as the bands' (0 of 40 runs, 1% of battles, the lone
fight 24%).

Read: the floor costs no band. Wainwright & Sutler's formations keep their decision (random
losing where greedy wins) and shed about a sixth of their wear, which stays three to five times
the heavy teams' since the trio is light and the heavies' armour 2 walls the rank and file's
blows outright; the finisher's one-shot is gone. The 200-seed reports (`docs/balance.md`,
`docs/campaign_run.md`) predate the four hulls' rise and are rerun with the pricing run.

## 23 October, the tests on a squad of four and on built teams

**Ryan's calls on the bands, read** (23 October, his "I think your suggestions are sound" of
Claude's leans: the kill time read on a squad of four, the gap on built teams). Run with
`tools/stock_loop.py` (its `--team` and `--set`, added for these) on main's head (`399a72d`,
the content as landed, the light hulls at 20), each at 30 seeds against the seventeen big fights
(`--packs big`) with greedy play, blind play and the planner, no campaign: the four team rows as
stocked, the same seeds' baseline for the rest (its Kestrel and Wainwright & Sutler cells equal
the hull loop's fight for fight); the four with setup pieces fitted; five squads of four, as
stocked and with the same fits; then two experiments in copies, on the bots' price for a Shock
and on a trio's order. Directions.

The fits, through the runner's overrides (applied after the content loads and never validated,
since a chassis stocks only below its own tier): a tier-zero basic swapped for a found setup
piece, so each trio carries a Shock and Flak beside its stock's. The Honey Badger's Rivet Gun
for the Polarity Projector, the Clydesdale's Twin Autoguns for the Flak Cannon, the Armadillo's
Twin Autoguns for the Flak Cannon, the Puffin's Twin Autoguns and Laser Carbine for the Polarity
Projector and the Flak Cannon, the Prairie Dog's Twin Autoguns for the Suppression Battery. The
overrides are global, so a machine on two rows carries one fit. The fours: the default team with
the Baboon (the file's fourth machine, a fourth die and no setup) and with the Dingo (a fourth
die and a Shock), Minerva's three with the Baboon (the maker fields three), and Kestrel's and
Wainwright & Sutler's first four in file order (with the Lammergeier, with the Funnel-web).

A lone massive foe (the four of them), mean rounds to win, greedy / blind / the planner:

| Squad | Stocked | Built |
|---|---|---|
| The default team | 3.4 / 3.4 / 3.4 | 3.2 / 3.2 / 3.1 |
| with the Baboon | 2.8 / 2.9 / 2.8 | 2.4 / 2.5 / 2.4 |
| with the Dingo | 2.6 / 3.1 / 2.5 | 2.5 / 2.9 / 2.3 |
| Minerva's team | 7.3 / 7.3 / 7.4 | 5.1 / 4.8 / 4.4 |
| with the Baboon | 4.8 / 4.8 / 4.7 | 3.6 / 3.4 / 3.2 |
| Kestrel's team | 2.9 / 3.1 / 2.9 | 2.4 / 2.6 / 2.3 |
| with the Lammergeier | 2.4 / 2.5 / 2.4 | 2.2 / 2.3 / 2.1 |
| Wainwright & Sutler's team | 7.4 / 7.8 / 6.5 | 6.8 / 6.0 / 5.6 |
| with the Funnel-web | 4.6 / 4.3 / 4.0 | 4.3 / 3.8 / 3.7 |

The gap, blind play's rounds over the planner's on the big fights (the report's mean over the
cells both win a quarter of), the lone massive foes' in brackets:

| Squad | Stocked | Built |
|---|---|---|
| The default team | 1.16 (1.01) | 1.15 (1.01) |
| with the Baboon | 1.13 (1.04) | 1.12 (1.04) |
| with the Dingo | 1.26 (1.24) | 1.23 (1.23) |
| Minerva's team | 1.05 (0.99) | 1.11 (1.09) |
| with the Baboon | 1.07 (1.01) | 1.08 (1.05) |
| Kestrel's team | 1.17 (1.07) | 1.22 (1.15) |
| with the Lammergeier | 1.12 (1.06) | 1.10 (1.07) |
| Wainwright & Sutler's team | 1.15 (1.20) | 1.10 (1.08) |
| with the Funnel-web | 1.07 (1.06) | 1.04 (1.02) |

A four loses 3 to 7% of its hull on a formation, greedy (the trios 7 to 31%). The finale stays a
wall but for the planner on Kestrel's four (one fight of thirty stocked, three built) and on the
default team with the Baboon built (one).

Why the gap stays shut, first the bots: every rung takes the greedy's rerolls, and they priced a
Shock at 0.6 of the team's average blow per entry (shields and vents counting nothing), so a
Shock of no damage read as a bad roll beside any gun. The Polarity Projector was spent 0.07 to
0.11 times a fight on the Honey Badger and 0.3 on the Puffin, on every rung, and the
Lammergeier's 0.05. Priced instead at the biggest blow an ally still to act shows on that foe
(an experiment in a copy of `sim/policy.gd`, the built trios on the same seeds), it is spent
0.29 to 0.49 a fight on the Honey Badger and 0.55 to 0.62 on the Puffin, and the gap opens by
0.0 to 0.1: on the massive foes the default team's 1.01 to 1.11, Kestrel's 1.15 to 1.21,
Wainwright & Sutler's 1.08 to 1.12, Minerva's 1.09 as it was; on the big fights 1.18, 1.11,
1.27 and 1.10. The rounds move by a few tenths at most. On a lone massive foe a Shock is worth
about the basic it displaced, and a setup pays whoever cashes it, so blind play, spending every
die on the one foe, banks it too.

Then the order, on the same priced bot, since blind play spends left to right: three trios with
their order reversed. Kestrel's with its setter first (the Puffin before the Kite) reads 1.05 on
the massive foes, where its file order, the setter last, read 1.21; the default team and
Minerva's with the setter last read 1.07 and 1.14, where they read 1.11 and 1.09, a Shock laid
last being cashed by the next round's first blow. The order moves the gap on a lone massive foe
by up to about 0.15 either way and never toward 2; the formations' and the finals' do not move.

Read: on a squad of four with a run's kit, a massive foe takes the fast squads about two rounds
(2.2 to 2.5, greedy) and Minerva's and Wainwright & Sutler's three and a half to four and a
half (the planner's 3.2 and 3.7); the kill time holds near its edge for three squads and misses by half
again to twice for the slow makers', whose stocks are basics against armour. The gap does not open on
built teams: 1.04 to 1.27 on the big fights and about 1.0 to 1.2 on a lone massive foe, against
about 2. The bots' Shock price was a fault, fixed in `sim/policy.gd` the same day in the
experiment's form, and not the cause.

## 23 October, the starter trios

**Every trio a tender can deal, stock, against every pack** (Ryan, 23 October: balance is read
by stage, which compositions are harder for an early stock team of three than for an endgame
optimized four; this is the early half). Run with `tools/stock_loop.py` on main's head
(`781c4d5`): the 28 trios of three tier-one machines from three city makers (the Honey Badger or
the Armadillo; the Puffin; the Prairie Dog, the Cassowary or the Cottonmouth; the Baboon or the
Stingray), in stock loadouts, against the twenty-nine packs, random and greedy, 30 seeds a cell,
no campaign. A direction. The runner's team rows are no starters: each fields a tier-two machine
and three are one maker's.

By pack over the 28 trios: greedy's mean win rate (its lowest and highest trio), random's mean,
the trios walled (greedy under 25%), the trios random wins nine times in ten, and greedy's rounds
and hull lost:

| Pack | Greedy | Random | Walled | Free | Rounds | Hull lost |
|---|---|---|---|---|---|---|
| The finale | 0 | 0 | 28 | 0 | - | 100% |
| The Peak formation | 74 (0 to 100) | 31 | 4 | 0 | 8.1 | 46% |
| The Marsh formation | 78 (20 to 100) | 23 | 4 | 0 | 9.3 | 43% |
| The Meadow formation | 84 (13 to 100) | 31 | 2 | 1 | 8.8 | 48% |
| The Magma Golem | 89 (0 to 100) | 25 | 1 | 0 | 7.3 | 56% |
| The Sandworm | 97 (40 to 100) | 54 | 0 | 3 | 7.7 | 42% |
| The Martial Artist's final | 99 | 60 | 0 | 4 | 5.2 | 29% |
| The Waste formation | 100 | 65 | 0 | 9 | 5.8 | 19% |
| The Treant, the Bone Wyvern | 100 | 94 | 0 | 25 | 8.5 | 1% |
| The other seven finals | 100 | 85 to 100 | 0 | 18 to 28 | 3.9 to 5.7 | 1 to 15% |
| The twelve rank-and-file packs | 100 | 96 to 100 | 0 | 24 to 28 | 1.5 to 3.0 | 0 to 15% |

By trio, on the five hard fights (the Peak's, the Marsh's and the Meadow's formations, the Golem,
the Sandworm): the sixteen trios with the Honey Badger or the Cottonmouth win them 96 to 100% of
the time for 16 to 47% of their hull; the twelve with neither win 25 to 89% for 54 to 93%, the
Armadillo, the Puffin and the Prairie Dog the lowest. By tender (one tier-one machine a city
maker, the player taking three): the eight tenders that deal the Badger or the Cottonmouth hold
a pick that clears all five (16 to 31% hull); the four that deal neither top out at 80 to 89%
for 54 to 68%; a tender's worst pick reads 25 to 100%.

Read: for a stock starter the rank and file, the Treant, the Bone Wyvern and most finals are
free; the three formations, the Golem and the Sandworm are the fights, random losing where
greedy wins; the finale is a wall. The Treant and the Wyvern take eight and a half rounds and
cost nothing: their blows carry no breach, so shields take them, where the Sandworm's and the
Golem's main blows breach. A hero's final comes easier than any formation but the Waste's. A starter's strength rides on the draft: the Honey
Badger and the Cottonmouth carry it, and a third of tenders deal neither. The endgame half waits
on what an endgame optimized four is (Ryan's call).

## 23 October, whom the foes strike

**Ryan's question on targeting** (23 October: does a tank with a low shield and a high hull
trip the exposed aim most often, so that most foes hit the thickest machines and the decisions
go?). `tools/target_probe.gd` on the content as at `76f8ad1`: every starter trio a tender can
deal, stock, greedy play, against each faction's formation, its boss and its first pack, 20
seeds a cell, 6,720 fights. A direction.

The aim as built: each machine weighs one, plus the hull the foe's blows would reach through its
shield and armour, plus half any shield they would break, and the pick is drawn by weight. Hull
adds nothing and armour subtracts, so while every shield would hold the blow the draw is level:
52% of the exposed aim's 50,726 picks were. The rest of the foes aim at anything, at their
rank's shared pick or at the armed.

Each machine's share of the single-machine attacks in its fights (a third is even): picked as
the round's intents are drawn with all three standing, picked over the whole fight, swung at as
the enemy's turn opens (after any Lure), and its share of its team's hull lost:

| Machine | Hull / shield / armour | Picked, all standing | Picked, whole fight | Swung at | Hull lost |
|---|---|---|---|---|---|
| Baboon | 28 / 10 / 0 | 36% | 36% | 34% | 36% |
| Honey Badger | 36 / 8 / 2 | 36% | 36% | 38% | 34% |
| Armadillo | 40 / 8 / 2 | 35% | 41% | 49% | 43% |
| Stingray | 24 / 12 / 0 | 35% | 34% | 31% | 33% |
| Puffin | 20 / 8 / 0 | 32% | 30% | 28% | 30% |
| Cassowary | 24 / 8 / 0 | 31% | 30% | 28% | 31% |
| Prairie Dog | 20 / 10 / 0 | 30% | 28% | 27% | 27% |
| Cottonmouth | 20 / 8 / 0 | 29% | 29% | 26% | 28% |

By kind of fight, with all three standing: the rank and file and the formations spread 28 to
39%; the breaching bosses (the Golem, the Sandworm) 30 to 39%, every shield failing their blow
so the draw is near level; the Treant and the Wyvern put 47% on the Armadillo and 44% on the
Honey Badger, 23 to 33% on the rest. Their blow of 7 is held by a standing shield, so the draw
follows whichever shield is down, and the tanks' shields hold it least often (38 and 56% of
the picks, the rest 63 to 81%).

Read: the aim does not pile blows on thick machines while the team stands; the lean to the
tanks comes from their outliving the light machines (every pick after a wreck lands on a
survivor), from the Armadillo's Lure (its share of the swings the highest), and against the
shield-held bosses from the draw chasing a broken shield. Half the exposed aim's picks are a
level draw. Against a boss whose one blow a round a shield holds, the round asks only which
machine to shield, and the tank's armour takes what gets through: the depth and the pressure
are short, not the targeting.

## 23 October, targeting and shields on the starters

**Ryan's questions on threat and pressure** (23 October: is there a case that the shield
pieces are too high or too cheap, and what does a run look like with the foes targeting
completely at random, as the baseline that targeting rules for advanced foes would build on?).
Loops on the starters, the 28 trios a tender can deal, stock, against every pack, random and
greedy, 30 seeds a cell, each read against the starter run of the same day (`starters30`):
every foe and every move aiming at random (`--lever aim:anything`, thirty-one foes moved), every
foe aiming as its rank's one shared pick (`--lever aim:focus`), and the two basic shield pieces
halved (the Canopy 8 to 4, the Halo Shield 6 to 3). Directions.

The shield economy first, from the starter run, greedy, a round: the damage the machines took
(shield and hull) against the shield their spends restored, and the share the shield held. A
trio opens a fight with about 27 points of standing shield. Both basic pieces cost no heat and
carry no cooldown, a die entry their one price, where a basic gun deals 2 or 3:

| Fight | Damage taken a round | Shield spent a round | Held by the shield |
|---|---|---|---|
| The Treant, the Bone Wyvern | 4.5 | 4.5 | 97% |
| The Sandworm, the Magma Golem (breaching) | 5.0 to 5.9 | 0.6 to 0.9 | 2 to 16% |
| The Peak's, the Marsh's and the Meadow's formations | 6.7 to 10.7 | 1.6 to 4.4 | 39 to 68% |
| The rank-and-file packs | 0.5 to 4.8 | 0.2 to 2.1 | 96 to 100%; 0% against the Gel and the Needler, whose blows breach |

The loops, over the 28 trios: greedy's win rate, its hull lost and the trios walled, as shipped,
with every foe at random, with every foe on focus, and with the shields halved:

| Pack | Greedy wins | Hull lost | Walled |
|---|---|---|---|
| The Peak formation | 74 / 78 / 72 / 67 | 46 / 42 / 50 / 51% | 4 / 4 / 3 / 7 |
| The Marsh formation | 78 / 82 / 77 / 78 | 43 / 39 / 45 / 45% | 4 / 1 / 4 / 3 |
| The Meadow formation | 84 / 84 / 76 / 82 | 48 / 47 / 50 / 50% | 2 / 2 / 4 / 1 |
| The Magma Golem | 89 / 90 / 89 / 89 | 56 / 57 / 56 / 56% | 1 / 1 / 1 / 1 |
| The Sandworm | 97 / 96 / 97 / 97 | 42 / 43 / 42 / 42% | 0 / 0 / 0 / 0 |
| The Treant, the Bone Wyvern | 100 / 100 / 100 / 100 | 1 / 1 / 1 / 4% | 0 / 0 / 0 / 0 |

On every other pack greedy's wins move two points at most under any loop; random play wins the
Treant and the Wyvern 98% with every foe at random against 94% as shipped.

Read: the shield pieces are not what keeps a lone boss harmless. Halved, the Treant and the
Wyvern take 4% of a trio's hull where they took 1%: such a boss deals about 4.5 a round over
eight and a half rounds, a fight's whole output about the size of the trio's standing shield,
so it is short of pressure, not of a breach. The halving bites only where the blows come in
volume (the Peak's formation walls three more trios) and nowhere a blow breaches. Random
targeting reads a little easier than the shipped aims, on the formations alone (the Marsh's
walls 4 to 1, its Ghosts' focus gone), so the numbers stand without the aims and an aim is a
lever on top of them. Every foe on focus reads harder than the shipped aims on the formations
(the Meadow's greedy wins 84 to 76, its walls 2 to 4) and changes nothing against a lone foe,
whose one pick is its own. On the twelve trios with neither the Honey Badger nor the Cottonmouth
the five hard fights read 67% won with every foe at random, 64% as shipped, 59% on focus and 60%
with the shields halved: a rank's blows on one machine take about as much from a starter as
halving every basic shield, with no number moved. The sixteen trios with a carry win all five
every way.

## 23 October, the endgame fours

**The endgame half of Ryan's read by stage** (23 October: which foes and compositions are
harder for an early stock trio than for an endgame four, the four fitted from pieces and
modules up to tier two, since tier three is powerful and rare by design, until the components'
power curve is known). Five fours built by Claude for the read, each a concept and Ryan's to
move, chassis of any tier, every hardpoint and module slot filled from tiers zero to two
(`tools/endgame_fours.py`, which checks the fits and runs `tools/stock_loop.py` with them: the
loadouts through the runner's `--set`, the modules through its `--fit`, added for this), against
the twenty-nine packs, random and greedy, 30 seeds a cell, no campaign, on the content as it
stands after `d592823` (the Elemental renamed). Read beside the starter trios above. A
direction.

The fours, each machine's pieces and then its modules:

- The heavy line: the Nemesis (Meteor Artillery, Blazethrower, Backdraft Charge, Oblation
  Mantle; Ward Plate, Grievance Reliquary), the Wild Boar (Tesla Gauntlets, Slugthrower,
  Shotfire Rack, Canopy, Coolant Jacket; Ram Frame, Tactical Databank), the Honey Badger
  (Transonic Rifle, Canopy, Coolant Jacket; Ram Frame, Tactical Databank), the Buzzard
  (Overclocked Railgun, Transonic Rifle, Cyclic Cannon, Canopy, Bleed Valve; Boundary-layer
  Bleed, Ward Plate).
- The setups: the Prairie Dog (Flak Cannon, Corona Shield, Coolant Jacket; Susceptibility
  Tensor, Flak Skirt), the Clydesdale (Maxigun, Cyclic Cannon, Enfilade Beam, two Howitzers,
  Airburst Shell, Canopy, Suppression Battery, Coolant Jacket; Tactical Databank, Susceptibility
  Tensor, Flak Skirt), the Baboon (Polarity Projector, Pulse Vacillator, Corona Shield, Coolant
  Jacket, Airburst Shell, Differentiation Probe; Phase Conjugator, Susceptibility Tensor), the
  Dingo (Airburst Shell, Cyclic Cannon, Coolant Jacket; Susceptibility Tensor, Flak Skirt).
- Kestrel's four: the Lammergeier (Meteor Artillery, Polarity Projector, Cyclic Cannon, Wake
  Diffuser; Boundary-layer Bleed, Ward Plate), the Kite (its stock; Boundary-layer Bleed, Ward
  Plate), the Puffin (Corona Shield, Laminar Deflector, Radiator Sail, Cyclic Cannon; Phase
  Conjugator, Flak Skirt), the Buzzard as above.
- Armour and the drum: the Honey Badger as above, the Cottonmouth (Flak Cannon, Tesla Gauntlets,
  Meteor Artillery, Corona Shield; Susceptibility Tensor, Flak Skirt), the Armadillo (Proximity
  Klaxon, Slugthrower, Canopy, Bleed Valve; Ward Plate, Ablative Plating), the Musk Ox (its
  stock; Ward Plate, Flak Skirt).
- The statuses: the Stingray (Incendiary Shells, Airburst Shell, Corona Shield, Aurora Lattice,
  Coolant Jacket; Susceptibility Tensor, Field Radiators), the Funnel-web (Maxigun, Howitzer,
  Cyclic Cannon, Canopy; Susceptibility Tensor, Flak Skirt), the Whip Scorpion (Thermal Ray,
  Entropy Condenser, Coolant Jacket, Maxigun; Ward Plate, Ablative Plating), the Baboon as above.

By pack, the 28 starter trios against the five fours: greedy's mean win rate and random's, then
greedy's rounds and hull lost (walled: greedy under 25%; free: random nine times in ten, as
above):

| Pack | Starter trios | Endgame fours |
|---|---|---|
| The finale | 0 / 0, all 28 walled | 67 (50 to 87) / 1, 12.8 rounds, 64%; none walled, none free |
| The Peak formation | 74 / 31, 8.1 rounds, 46% | 100 / 100, 3.0 rounds, 0.3% |
| The Marsh formation | 78 / 23, 9.3, 43% | 100 / 99, 4.3, 0.7% |
| The Meadow formation | 84 / 31, 8.8, 48% | 100 / 100, 4.6, 3.4% |
| The Magma Elemental | 89 / 25, 7.3, 56% | 100 / 100, 2.6, 6.0% |
| The Sandworm | 97 / 54, 7.7, 42% | 100 / 100, 2.5, 4.9% |
| The Martial Artist's final | 99 / 60, 5.2, 29% | 100 / 100, 2.1, 1.3% |
| The Waste formation | 100 / 65, 5.8, 19% | 100 / 100, 2.7, 3.1% |
| The Treant, the Bone Wyvern | 100 / 94, 8.5, 1% | 100 / 100, 2.2, 0% |
| The other seven finals | 100 / 85 to 100, 3.9 to 5.7, 1 to 15% | 100 / 100, 2.0 to 2.4, 0 to 2% |
| The twelve rank-and-file packs | 100 / 96 to 100, 1.5 to 3.0, 0 to 15% | 100 / 100, 1.0 to 2.1, 0 to 2% |

By four on the finale, greedy: the heavy line 87% for 60% of its hull in 11.4 rounds, the
statuses 70% for 56% in 11.7, Kestrel's 67% for 63% in 12.4, the setups 63% for 62% in 15.5,
armour and the drum 50% for 78% in 13.1; random play wins it 0 to 3%. A lone massive foe falls to
a four in 2.1 to 3.1 rounds (armour and the drum the slowest), where a starter needs 7.3 to 8.5.

Read: an endgame four meets nothing in today's roster but the finale. Every pack a starter
fights is free for it, random play included, at 0 to 6% of its hull a fight (the five's mean;
11% at most for one four), and a lone massive foe dies in two to three rounds, about section 2's round or two of focus, where a starter needs
seven to eight and a half. Only the finale presses it: greedy wins two times in three for about
two thirds of the squad's hull over twelve rounds and random play loses, the one cell that reads
as a fight for an endgame four. So the grid has two rungs and nothing between them, the
starter's fights (the formations, the two breaching bosses, the Martial Artist's final) and the
finale: no composition is a starter's wall and a fair fight late but the finale, and none is a
wall late. Every tier draws the same lists today, so a run's later battles field what its first
did; the middle and late curve is the foes' fresh start's to build (the bible's section 3 curve
row).

## 24 October, the foes' specials and their gates

**Ryan's question on the specials' conditions** (24 October: does the Cockatrice's Stone ever
fire, and does the Drake's Stoke, if no machine runs hot?). `tools/special_probe.gd` on the
content as at `7a10d09`: every third starter trio a tender can deal (10 trios), stock, greedy
play, against each domain's formation, each boss alone and each hero alone, 10 seeds a cell,
each cell played twice on the same seeds: as built, and with the three conditions that read
the player's state opened (a machine at the move's heat, a machine showing an intact weapon,
the team having a reroll left). 3,200 fights. A direction.

Per special, the rounds its foe drew a move, the share of those draws its condition held, the
share it was picked as built, and the share it was picked with the gates opened (the other
conditions are untouched, so their two columns agree but for the knock-on):

| Special | Condition | Draws | Held | Picked | Picked, opened |
|---|---|---|---|---|---|
| the Cockatrice's Stone | a machine showing a weapon | 969 | 90% | 24% | 26% |
| the Summoner's Diamond Dust | a machine showing a weapon | 261 | 93% | 28% | 30% |
| the Drake's Stoke | a machine at 5 heat | 1,132 | 47% | 12% | 25% |
| the Black Mage's Fira | a machine at 5 heat | 298 | 5% | 2% | 27% |
| the Mandragora's Scream | a reroll left | 1,013 | 100% | 27% | 27% |
| the Thief's Steal | a reroll left | 305 | 100% | 30% | 30% |
| the Dire Wolf's Howl | another on the field | 610 | 98% | 30% | 30% |
| the Ghost's Raise | few waiting | 1,973 | 45% | 12% | 12% |
| the Cleric's Cure | one of its own hurt | 303 | 67% | 16% | 16% |
| the regrows (Treant, Wyvern, Martial Artist) and the Sandworm's Burrow | hurt | 359 to 906 | 70 to 86% | 18 to 19% | 18 to 19% |
| the bosses' and heroes' signatures | below half | 173 to 906 | 29 to 46% | 9 to 20% | 9 to 20% |
| the Bomb's Self-Destruct and the Antlion's Burrow | below half | 753 to 1,658 | 5 to 14% | 3 to 4% | 3 to 5% |

The fights, as built against opened, where a gate moved anything: the Peak's formation won 77%
against 78%, in 8.3 rounds against 7.9, with 47% of the trio's hull lost against 41%; the Black
Mage alone 2.6% of the hull lost against 1.9%; the Waste's formation 19.5% against 19.3%; every
other cell the same.

Read: the weapon gate is nearly always open, read as the dice land, so the Stone and Diamond
Dust fire at about their weight (and they land on whatever the die shows after the player's
turn, not on what the gate read). The heat gate holds the Drake's Stoke to half its weight, never
in the first round (no machine is hot yet) and never against a cold team, and almost silences the
Black Mage's Fira, whose hero dies in about three rounds. The reroll gate never closes. Opening the
gates makes the Peak a little easier, not harder: a special replaces its foe's blow, and Stoke's
two stacks of Burning are worth less than the Breath's 5 and a Scorched it replaces, as Fira's two
Scorched each are against Fire's 8 and a Scorched. So the gates are not what makes the packs soft;
the heat specials are weaker than the blows they replace.

## 24 October, the rank and file at random

**Ryan's baseline** (24 October: the rank and file target at random, agnostic of the player's
composition, and never over-commit; an elite, a boss or a hero keeps an aim where it fits).
`tools/special_probe.gd` on the content after the change, the same 10 starter trios, cells and
10 seeds as the run above, its fights read against that run's opened column (the gates already
gone, the old aims standing). 1,600 fights. A direction.

| Cell | Won, old aims / at random | Rounds | Hull lost |
|---|---|---|---|
| The Marsh's formation | 81 / 88% | 8.1 / 8.1 | 40 / 33% |
| The Meadow's formation | 84 / 83% | 8.7 / 8.6 | 50 / 47% |
| The Peak's formation | 78 / 85% | 7.9 / 8.4 | 41 / 39% |
| The Waste's formation | 100 / 100% | 6.0 / 5.7 | 19 / 15% |
| The Magma Elemental alone | 87 / 88% | 7.9 / 7.8 | 59 / 57% |
| The Sandworm alone | 95 / 93% | 7.7 / 8.2 | 43 / 44% |
| The Treant alone | 100 / 100% | 9.1 / 8.6 | 1 / 1% |
| Every hero alone, the Bone Wyvern alone | the same | the same | the same |
| Every cell | 95.3 / 96.1% | 5.6 / 5.6 | 18.2 / 17.2% |

Read: the formations read easier at random, a few points of hull and up to seven of wins, as
the all-random run of 23 October found, and the lone fights barely move: a lone foe has no one
to over-commit beside, and the heroes and the Bone Wyvern keep their aims. The numbers now stand
on a baseline the player's composition does not move; the formations' pressure is the numbers'
to restore when the units are balanced for real, and an advanced foe's aim is a lever on top.

## 24 October, the turn loop's pressure

**Ryan's question** (24 October: does a rift ever close on its own, and is a perfect run, every
city standing, possible in a run of limited battles?). `tools/turn_loop.py`: the turn loop of
`sim/campaign.gd` modelled from its constants (four cities, gate 200, bleed 50, rifts open to 2
plus the Convergence's tier, a won city quiet a turn, the finale at 12), with every battle won
and no pusher let through, so whatever falls, the schedule felled. Each rift keeps the tier it
opened at (Ryan's locked tier, `git show 85e28fd:docs/curve_proposal.md`). 2,000 seeds. A model of the
arithmetic, not a run of the game.

| Front chosen | Cities fallen a run | Fronts on the board, by tier | Two tiers on the board | Most gate lost when fought | Rescues on a gate of 50 |
|---|---|---|---|---|---|
| The oldest | 0 | 2, 3, 3 | 25% of turns | 100 | 0 |
| The higher tier, turning back for a city one bleed from falling | 0 | 2, 3, 3 | 50% of turns, the higher taken on half | 150 | 3 a run |
| The higher tier always | 2 | 2, 2 or 3, 2 | 55% of turns | 50 | 0 |

Read: the schedule never fells a city, nor does one passed turn at any Convergence (the oldest
front fought every other turn), so falls come from lost battles; the cap on open rifts
bounds the pressure and the battle count does not. The third tier's extra rift never opens while
every battle is won (the fourth city is the one just won, quiet for a turn). The bleed short of
a fall costs nothing once its rift is won (the free restore; Favour docks only the battle's
damage), so a careful chaser keeps every city at the price of three rescues on a low gate.
Two tiers share the board only around the steps, since a front lives two or three turns.

**The widening rift** (`--widen N`, Ryan's idea of 24 October in the form Claude proposed, then
dropped: a rift that has bled its city N times steps a tier up, once, to the top tier at most).
The same 2,000 seeds.

| Widens at | Front chosen | Cities fallen a run | Widened rifts fought a run | Their cities' gate | Two tiers on the board |
|---|---|---|---|---|---|
| The third bleed | The oldest | 0 | 0 | none met | 25% of turns |
| The third bleed | The higher tier, turning back for a city one bleed from falling | 0 | 3 | 50 | 33% |
| The third bleed | The higher tier always | 0 | 3 | 50 | 33% |
| The second bleed | The oldest | 0 | 6 | 100 | 33% |
| The second bleed | Either chaser | 0 | 7 | 100 | 33% |

Read: at the third bleed the widening touches only the fronts a rotation never leaves that long,
and it pays the chase: the always-chaser keeps its cities because a widened front becomes the
richest on the board, a tier of loot for the neglect (Ryan, 24 October: "more like a reward for
ignoring it"); at the second bleed it meets the rotation too, a tier up on half the run's
battles. Dropped (`git show 85e28fd:docs/curve_proposal.md`).

## 24 October, the foes' heat doubled

**Ryan's call** (24 October: heat needs to be more threatening, and because the heat debuffs can
be countered, with multiple release valves, they can be significantly buffed).
`tools/special_probe.gd --heat` on the content as at `e638c41`, every foe's heat stacks (its
Scorch riders, the Stoke's Burning, the scorches on every machine) scaled ×1, ×2 and ×3: every
third starter trio (10), stock, greedy, against the Peak's formation, the Magma Elemental, the
Black Mage and the Summoner alone, 30 seeds a cell, 3,600 fights. A direction.

| The Peak's formation | Won | Hull lost | Overheats a fight | Hull lost to heat | Fights with an overheat |
|---|---|---|---|---|---|
| ×1 | 88% | 36% | 1.4 | 4.5% | 39% |
| ×2 | 69% | 48% | 3.1 | 12.2% | 71% |
| ×3 | 60% | 56% | 4.6 | 22.4% | 85% |

By trio, ×1 / ×2 / ×3: the four Honey Badger trios, the coldest, win 93 to 100% at ×2 and pay
0 to 9% of their hull to heat (0 to 1% at ×1, 1 to 26% at ×3); the two Cottonmouth and Stingray
trios win every fight at every step; the two Cassowary and Baboon trios fall from 90 and 97% won
to 33 and 47% (20 and 10% at ×3); the two Armadillo and Puffin trios, already hard at ×1 (23
and 73%) with the seal's own heat, to 3 and 13%. The Magma Elemental, the Black Mage and the
Summoner alone barely move at any step: the Elemental's breaching blows are its fight, and the
heroes die in about three rounds, before heat builds.

Read: ×2 makes heat the Peak's threat, felt by the cold teams and walling the hottest starters
on the greedy bot, which manages heat only as far as its one-round forecast reads it; ×3 walls
all but the coldest. ×2 is the first cut in content, for Ryan's play.

## 25 October, the weld's draw calls

**The battery plan's weld** (bible section 11; the to-do's line: count draw calls before and
after). `tools/perf_probe.gd` on the Compatibility renderer (the phone's) in a cloud container,
whose renderer is Mesa's llvmpipe on the CPU: its frame times say nothing about a phone, its
draw calls are the engine's own count. The battle screen at zoom 1 and 2.6 and the skirmish
screen, the default team (the Badger, the Clydesdale, the Sparrowhawk) and a heavy four (the
funnel-web, the Ammit, the Goshawk, the Puffin), `RIFTGATE_WELD=off` against the weld. Draw
calls a frame; "machines" is the map's machines' layer, or the skirmish's machine views:

| Screen | Team | Frame, off / on | The map's world, off / on | Machines, off / on |
|---|---|---|---|---|
| Battle, zoom 1 | Default | 1,650 / 1,081 | 957 / 639 | 508 / 257 |
| Battle, zoom 2.6 | Default | 1,400 / 844 | 743 / 432 | 490 / 245 |
| Skirmish | Default | 929 / 668 | | 507 / 256 |
| Battle, zoom 1 | Heavy | 2,506 / 1,583 | 1,445 / 928 | 874 / 468 |
| Battle, zoom 2.6 | Heavy | 1,894 / 1,200 | 1,037 / 643 | 688 / 388 |
| Skirmish | Heavy | 1,305 / 900 | | 873 / 467 |

The fourteen models go from 917 meshes to 521 (29 to 91 a machine, to 19 to 57). In a skirmish
view a mesh costs two calls and its trace one, so a part cost three; a group's trace is now
one call. The triangles drawn are the same: the primitives within a tenth of a percent at zoom
1 and in the skirmish, and up 0.2% (default) to 1.2% (heavy) at full zoom, where a welded group
is drawn whole once any part of it is in view. The frame's remainder is the field and the 2D,
which the weld does not touch.

The look, diffed pixel by pixel against the code before the weld, at a fixed frame rate so a
render is the same every run: 103 renders of the fourteen machines (at rest, outlined and bare,
each act halfway through, driving; 240x288), each skirmish view and the map's world and
machines' layer at both zooms. With the weld off every one matches the code before it. With
the weld on, 0.14% of the machines' pixels differ, 82% of those by one or two levels of 255
(float rounding where a part's transform is baked into its mesh), the rest single edge pixels
and speckle where a shadow's test sits on its threshold; no outline or silhouette pixel moves,
on a fitted mount or a bared socket either. The importer's levels of detail (about fifty parts
carry one or two: the Dingo's body, the Goshawk's and the Sparrowhawk's fuselages, the Puffin's
hull) are live at these sizes, and a weld without them differed twice as much; the welded
meshes carry every part's levels. The weld costs 9 to 31 ms the first time a model is seen and
about 1 to 9 ms an instance after it (the plan is built once a model).

## 25 October, the Skua's rows

**Its engine session's reads** (the Skua fielded 25 October: each roll halved, rounded down, and
struck twice; the Flechette Pod's spray), as its brief asked: alone against the packs (the trash
claim) and the four big foes (the bounce), beside the Puffin with the Overcharge Coil (a flat
buff counted twice), and the spray's share of the spends. `tools/balance.gd`, 200 seeds a cell,
random and greedy, no party, on the content as at `36ec6da` (the later commits of the day touch
no row here: the Skua's stock carries no debuff, no machine here a passive lay, a Shock or a
Cryo, and the bot's buff fix only the Coil's rows, which were run again on it).

**Alone**, the nine runnable tier ones against the twenty packs, 72,000 fights: won, random /
greedy.

| Row | Every pack | Rank and file (12) | The four big foes | The four formations | Hull lost (greedy) |
|---|---|---|---|---|---|
| Honey Badger | 43 / 67 | 72 / 95 | 0 / 37 | 0 / 11 | 53% |
| Cottonmouth | 38 / 55 | 63 / 91 | 0 / 0 | 0 / 0 | 51% |
| **Skua** | **27 / 37** | **45 / 61** | **0 / 0** | **0 / 0** | **69%** |
| Baboon | 25 / 37 | 41 / 55 | 0 / 22 | 0 / 0 | 74% |
| Armadillo | 25 / 33 | 41 / 55 | 0 / 0 | 0 / 0 | 77% |
| Stingray | 23 / 29 | 38 / 48 | 1 / 3 | 0 / 0 | 74% |
| Cassowary | 16 / 23 | 27 / 38 | 0 / 0 | 0 / 0 | 84% |
| Puffin | 8 / 22 | 14 / 37 | 0 / 0 | 0 / 0 | 86% |
| Prairie Dog | 11 / 21 | 18 / 35 | 0 / 0 | 0 / 0 | 85% |

By pack, greedy: the Skua wins every small pack the field wins (the Cockatrice, Drake, Ghost,
Mandragora and Wolf packs 100%, the Antlions 88%) in 2.3 to 3.5 rounds, behind only the
Cottonmouth's 1.3 to 3.1 (the Badger's 2.4 to 4.1); the swarms are where it falls on its 20
hull: the Goblin and Revenant sixes 12% (the Badger 93, the Cottonmouth 100), the Gel's four 4%,
the Needler's five 48%, the Bomb's four 55%, the Salamander's three 21%. Every big foe and
formation 0%, as for every tier one but the Badger (the Treant 75%, the Bone Wyvern 73%, the
Waste's and the Marsh's formations 32 and 12%) and the Baboon (the Treant 38%, the Bone Wyvern 45%).

The Flechette Pod's share of the Skua's spends, greedy: 48 to 65% against the full fronts of
the Meadow's, the Marsh's and the Peak's formations (the Waste's 29%, its Needlers met by the
basics); 72 and 76% against a lone Sandworm and Magma Elemental, 29% against the Treant and the
Bone Wyvern, where the Canopy takes three spends in five; 35 to 65% on the rank and file.

**Beside the Puffin**, three pairs, 24,000 fights a run: won, random / greedy.

| Pair | Every pack | Rank and file | The four big foes | The four formations | Hull lost (greedy) |
|---|---|---|---|---|---|
| Skua + Puffin, stock | 49 / 70 | 81 / 100 | 0 / 43 | 1 / 9 | 40% |
| Cottonmouth + Puffin, stock | 58 / 86 | 91 / 100 | 10 / 53 | 6 / 77 | 25% |
| Prairie Dog + Puffin, stock | 36 / 60 | 60 / 94 | 0 / 16 | 0 / 0 | 47% |
| Skua + Puffin, the Coil | 50 / 75 | 83 / 100 | 0 / 66 | 2 / 12 | 35% |
| Cottonmouth + Puffin, the Coil | 59 / 86 | 91 / 100 | 13 / 52 | 6 / 77 | 25% |
| Prairie Dog + Puffin, the Coil | 37 / 62 | 62 / 94 | 0 / 32 | 0 / 0 | 48% |

Stock, by pack, greedy: the Skua's pair wins every rank-and-file pack (98 to 100%), the Treant
90% and the Bone Wyvern 84% (in 23 and 24 rounds), the Waste's formation 34% and no other
formation; the Cottonmouth's wins every pack but the Peak's formation (27%), the Sandworm (10%)
and the Magma Elemental (0%), in fewer rounds; the Prairie Dog's 76 to 100% on the rank and file,
16 and 48% on the Wyvern and the Treant, no formation.

With the Overcharge Coil in the Puffin's Coolant Jacket's place (`--set
chassis/puffin/loadout=["halo_shield","overcharge_coil","twin_autoguns","laser_carbine"]`),
on the bot that counts a flat buff once a strike of the ally's gun (`e28c40f`): the Puffin
spends it on 9% of the Skua pair's spends (6 and 5% of the others'), and the Skua's pair takes
the Treant and the Bone Wyvern in 9 rounds where it took 23 and 24 (90 and 84% won, now 100),
the Sandworm 39% and the Magma Elemental 26% where it took neither; the Cottonmouth's pair, its
drum one strike, gains nothing; the Prairie Dog's doubles its big-foe wins (16 to 32%, the
Treant 48 to 82%). The first Coil run, on the bot that counted a flat buff once a blow whatever
the gun, spent the Coil on 4% of the Skua pair's spends and moved its rows a point or two (the
other two pairs read as now): a verdict on the bot, fixed the same day.

Read: alone, the Skua is third of the nine tier ones on the rank and file, behind the Badger and
the Cottonmouth and level with or above the rest, with a decision in it (random 45%, greedy
61%); it kills the small packs fast, falls to the swarms on its 20 hull, and bounces off the big
foes, as designed. The Pod is its most spent entry on nearly every pack, against a full front
and a lone foe alike, the locked piece doing a lock's work. Beside the Puffin it sits between the
Cottonmouth's pair and the Prairie Dog's, and a flat buff counted on each strike is its way
through plate, the brief's claim: the Coil turns the big foes from the pair's slowest wins into
nine-round ones. A tier one in the middle of the field, neither weak nor a must-pick; Ryan's play
decides whether its start bites.

## 25 October, formations back to back

**How many complete formations a squad gets through in a row** (Ryan's quick campaign of 25
October as first proposed, `git show 2b64715:docs/quick_campaign_proposal.md`: battles of four,
six and eight fights before the boss,
every one a formation or an elite, nothing healed until the boss falls). `tools/chain_probe.gd`
on the content at `a8a0e43`: a squad fights one domain's formation (its whole spawn list in one
fight, as the balance report's formation cells) up to nine times in a row, hull, shield, cracks
and wrecks carried and heat starting each fight at zero, greedy play, never withdrawing; each
chain with no shield back between fights (every machine fought, so no field recharge) and with
one field recharge (a map turn's walk to the next pack). The squads: every trio a tender deals
(44 since the Skua, stock) at 2 seeds a domain, every four (24, stock) at 3, and the five endgame
fours of 23 October (`tools/endgame_fours.py --json`) at 5. The share of chains still winning
after the k-th formation, and the hull they have left (a wreck counting nothing):

| Squad | Between fights | 1 | 2 | 4 | 6 | 8 |
|---|---|---|---|---|---|---|
| Starter trios (352 chains each) | no shield back | 85% (76%) | 63% (60%) | 32% (48%) | 14% (40%) | 6% (39%) |
| | a field recharge | 87% (74%) | 64% (68%) | 43% (58%) | 29% (59%) | 19% (61%) |
| Starter fours (288) | no shield back | 100% (93%) | 98% (81%) | 84% (68%) | 70% (60%) | 56% (55%) |
| | a field recharge | 100% (93%) | 98% (86%) | 89% (79%) | 80% (75%) | 71% (71%) |
| Endgame fours (100) | no shield back | 100% (98%) | 100% (96%) | 100% (89%) | 100% (83%) | 99% (76%) |
| | a field recharge | 100% (97%) | 100% (95%) | 100% (91%) | 100% (86%) | 97% (84%) |
| The same, half again as dense (`--density 1.5`) | a field recharge | 100% (95%) | 100% (90%) | 99% (80%) | 95% (73%) | 90% (66%) |
| The same, double (`--density 2`) | a field recharge | 100% (91%) | 100% (82%) | 94% (68%) | 75% (64%) | 66% (60%) |

By domain, the Meadow is the starters' wall: a stock four wins four of its formations in a row
67% of the time (76% with the recharge), the Waste's 100%. By machine, the Cottonmouth carries
(the trios with it win four in a row 85% and 95%, the fours with it eight 95% and 97%) and the
Cassowary and the Prairie Dog least (their trios 4% and 9% without the recharge), as the trios'
reads of 23 October had it. The survivors' hull reads high late because the chains that last are
the strong pairings. Denser formations take longer as well as more: 4.2 rounds a fight for the
endgame fours, 6.4 at half again as dense, 8.4 at double.

Read: a trio cannot carry a battle of formations: more than half the stock trios fall before the
fourth. A fourth machine about halves each fight's cost (section 4's four-machines row) and takes
most stock fours through four (84 to 89%) and half or more through eight. The field recharge is
worth five to fifteen points on a starter squad; on a built one it moves the hull left (76% to
84% after eight), not the wins. A four fitted to tier two loses about a thirtieth of its hull a
formation and leaves eight with three quarters of it or more; every tier draws the same lists
today (the curve row), so only the formation's density presses it, half again as dense taking it
to 90% through eight and double to 66%. A direction: 2 to 5 seeds a cell over many cells, greedy
only.

## 25 October, the mechanics audit's fixes

**The tender on its own stream** (`docs/mechanics_audit.md`, item 33). `tools/campaign_run.gd`,
40 runs from seed 1, the greedy rung, on the content as at this entry's commit (the audit's
fixes with `ccr-170f6d81-465jnr`'s day merged in). Who started the runs, against the 22 October
report: the Honey Badger 11 (9), the Baboon 15 (18), the Armadillo 17 (20), the Prairie Dog 10
(12), the Stingray 10 (14), the Puffin 16 (28), the Cassowary 16 (12), the Cottonmouth 10 (7),
the Skua 15 (not dealt then). On 22 October the tender and the run drew one stream, so the
runner's pick of three reread Minerva's offer: the Armadillo started every run it was offered
and the Badger about half. A model of Godot's PCG32 reproduces that table run for run, and on
the new streams puts every machine at about three starts in four offers over 4,000 seeds. The
report's other rows (37 of 40 runs to the finale against 25, 3.92 cities fallen a run against
3.75) carry everything landed since 22 October, the targeting at random and the doubled heat
among it, and say nothing about the fix. A direction at 40 runs.

## 25 October, the quick campaign's first runs

**Whole quick runs, the mode as Ryan decided it that day** (the bible's quick campaign row;
`docs/rules.md`'s quick campaign part): `tools/quick_run.gd` at 40 runs from seed 1, each
starting with three different draft chassis at random, the plain player picking the loot by
tier and fitting it the same way, once on the greedy rung (`docs/quick_run.md`, 129 s in four
parts) and once on the planner (563 s), on the content and engine at `f7c1fa0`.
Every fight a complete formation, an elite (each domain's other bench hero leading its
formation) or the boss with its formation, the enemy the same at every tier. A direction.

| Read | Greedy | Planner |
|---|---|---|
| Runs won | 1 of 40 | 1 of 40 |
| Runs lost in the first battle | 34 (its elite 15, a formation 10, its boss 9) | 35 (15, 8, 12) |
| The first battle won | 15% | 13% |
| Battles 2 to 8 won, by the runs that passed the first | 80 to 100% (4 to 6 runs) | 100% (5 runs) |
| The squad's hull as the boss fight opened, battles 2 to 10 | 76 to 96% | 70 to 98% |
| Battles 11 and 12 won; hull before the boss | 67%, 100%; 62%, 56% | 80%, 75%; 58%, 48% |
| The finale | 2 reached, 1 won | 3 reached, 1 won |
| The kit at battle 7 (a squad's hardpoint pieces of tiers 0 / 1 / 2 / 3, and modules) | 0 / 6.5 / 8.5 / 1.2, 1.0 | 0 / 6.4 / 8.6 / 1.2, 1.4 |

By fight on the greedy rung: a tier-one formation won 90% (5.0 rounds, the squad at 73% of its
hull after), a tier-one elite 72% (49%), a tier-one boss 73% (47%); from tier two every
formation and elite 97 to 100%, the bosses 91 to 94%. The Meadow is the hardest lead (38% of its
battles won), the Marsh and the Peak the easiest (71 and 70%); the Cottonmouth's runs won the
most battles (3.7 a run), the Puffin's none.

Read: the first battle is a cliff and the middle a plateau, alike on both rungs, so it is the
shape and not the bot. A starting trio meets three complete formations, an elite and a boss with
its formation with no heal, which the chain probe of the same day reads as a trio's wall; the
few runs through it field four from the first offer and win nearly everything to tier three,
since the loot ramps their kit while the enemy keeps the first battle's tiers. Tier three's
bosses and the finale press again. What moves it is section 12's (the bible's quick campaign
question).

## 25 October, one damage state's threshold

**An injury that destroys outright, at four thresholds** (Ryan, 25 October: "Cracked is gone"):
`tools/balance.gd -- --policies greedy --seeds 30 --noparty` in four parts, once on the two
states as they stood (at `54e064a`) and once for each threshold with `--injury N` and the one
state; every machine alone and the four team rows against the twenty packs and formations, the
components destroyed a fight (gone for good when the fight is won). A direction, 30 seeds a cell.

| Injury | Alone: destroyed a fight | Alone: a won fight | Alone: won | Teams: destroyed a fight | Teams: won |
|---|---|---|---|---|---|
| Two states at a quarter (before) | 0.108 | 0.006 | 45.7% | 0.019 | 100% |
| One state at a quarter | 0.500 | 0.046 | 45.3% | 0.223 | 99.9% |
| One state at a third | 0.162 | 0.004 | 46.0% | 0.123 | 99.9% |
| One state at two fifths | 0.079 | 0.004 | 46.0% | 0.099 | 99.9% |
| One state at half | 0.008 | 0.000 | 46.0% | 0.031 | 100% |

Read: no threshold moves a win rate, as on 12 October, and only half keeps a squad's losses near
the two states' (0.031 a team fight against 0.019). Half was set and retired the same day (Ryan:
"a unit has to lose half it's hull to lose a component? Ergo the maximum components a unit can
lose is...1? ... It's not about win rate, it's about forcing player choices and balancing
compositions"): the threshold is set by what it asks of the player, so it stands at a quarter,
where every injury now destroys (0.22 a team fight, about a piece every four or five, against
0.02 on the two states). What that costs a run is the economy pass's to read against the inflow
(section 10's guard: about one a won battle). The wreck's old price, its cracked components,
goes with the state (Ryan: being wrecked and out for a battle is the price). Bible section 7's
damage-state row.

The quick campaign's greedy runs rerun on the one state at a quarter, with the bosses' escort
by tier and the finals drawn as bosses from tier two (`docs/quick_run.md` at `a34f2cc`, 40 runs
from seed 1, 94 s in four parts): 36 runs of 40 lost in the first battle (34 on the two states, the first
runs above), none won (1): the same cliff, inside 40 runs' noise. A squad loses 0.15 to 1.75
pieces for good a battle through tier one (0.12 to 0.50 on the two states) and 0.5 to 1.3
after; the finals turned up ten times (eight at tier two, all won, the squad keeping 80% of its
hull; two at tier three, one won).

## 26 October, the bosses at their tier

**The quick campaign with a boss, a final's hero and the finale's line at the battle's tier**
(the bible's section 9 boss row; the placeholders: HP ×1.25 and ×1.5, attack +1 and +2, an escort
of two and four of the domain's units of the tier): `tools/quick_run.gd` at 40 runs from seed 1,
greedy, 160 s in four parts (`docs/quick_run.md`), against the same runs before (`a34f2cc`). A
direction. The first battle's cliff is untouched (36 runs of 40 lost there, its boss at tier one
as before). The finals at tier two are still all won (10 of 10) but cost the squad more, 56% of
its hull standing after against 80%; tier three's bosses fall 60% of the time (67%), its finals
one of two as before, and battle 9 is won by two of the four runs reaching it (all three
before). None of 40 reached the finale, as before.

## 26 October, the fight-size spectrum as it stands

**The sizes the fresh start's proposal sizes its compositions against** (`git show 85e28fd:docs/foes_proposal.md`;
the four-machines row's targets, section 4: a small pack one or two machines take for about a
tenth of their hull, a formation the body's). `tools/balance.gd` with its new `--pack` cells
(one foe type times a strength, or several together in one fight) on the merged code (`49211ca`,
main's playtest list in: the Gel's halves a pair in its slot), 30 seeds a cell, random and
greedy, no party, 8,400 fights. The rows: five machines alone (the Honey Badger, the Puffin, the
Prairie Dog, the Cottonmouth, the Skua), a built pair (the Honey Badger and the Puffin), a light
pair (the Cassowary and the Prairie Dog), the default team (the Honey Badger, the Clydesdale, the
Kite: a tier-two trio, no starter) and that team with the Baboon. The packs: patrols (two and
three goblins, three needlers, two wolves), five fronts with a back, the goblin pack of six, the
Treant and two whole spawn lists. Random's wins, greedy's wins, and greedy's hull lost over every
fight, won or not. A direction.

| Pack | Badger | Puffin | Dog | Cottonmouth | Skua | Badger + Puffin | Cassowary + Dog | The trio | The four |
|---|---|---|---|---|---|---|---|---|---|
| Goblin x2 | 100 / 100, 0% | 83 / 100, 4% | 93 / 100, 1% | 100 / 100, 0% | 100 / 100, 0% | 100 / 100, 0% | 100 / 100, 0% | 100 / 100, 0% | 100 / 100, 0% |
| Goblin x3 | 100 / 100, 2% | 13 / 87, 42% | 27 / 63, 65% | 97 / 100, 1% | 70 / 90, 21% | 100 / 100, 0% | 100 / 100, 1% | 100 / 100, 0% | 100 / 100, 0% |
| Needler x3 | 90 / 100, 15% | 10 / 93, 62% | 20 / 83, 72% | 77 / 100, 3% | 83 / 100, 38% | 100 / 100, 4% | 93 / 100, 14% | 100 / 100, 0% | 100 / 100, 0% |
| Dire Wolf x2 | 100 / 100, 0% | 57 / 100, 14% | 87 / 100, 8% | 100 / 100, 0% | 100 / 100, 0% | 100 / 100, 0% | 100 / 100, 0% | 100 / 100, 0% | 100 / 100, 0% |
| Goblin x4 + Mandragora x2 | 70 / 100, 27% | 0 / 0, 100% | 0 / 0, 100% | 30 / 100, 17% | 3 / 17, 94% | 97 / 100, 4% | 17 / 83, 51% | 100 / 100, 0% | 100 / 100, 0% |
| Revenant x4 + Ghost x2 | 70 / 100, 24% | 0 / 0, 100% | 0 / 0, 100% | 30 / 100, 16% | 3 / 17, 94% | 97 / 100, 4% | 17 / 87, 49% | 100 / 100, 0% | 100 / 100, 0% |
| Needler x3 + Cockatrice x2 | 77 / 100, 17% | 0 / 13, 98% | 0 / 17, 95% | 47 / 100, 30% | 57 / 90, 50% | 100 / 100, 6% | 77 / 100, 18% | 100 / 100, 1% | 100 / 100, 0% |
| Bomb x2 + Drake x2 | 33 / 57, 64% | 0 / 0, 100% | 0 / 0, 100% | 67 / 100, 1% | 7 / 57, 74% | 100 / 100, 5% | 47 / 93, 44% | 100 / 100, 0% | 100 / 100, 0% |
| Salamander x3 + Drake x2 | 7 / 13, 93% | 0 / 0, 100% | 0 / 0, 100% | 0 / 0, 100% | 0 / 0, 100% | 13 / 90, 44% | 0 / 0, 100% | 100 / 100, 0% | 100 / 100, 0% |
| Goblin x6 | 43 / 87, 37% | 0 / 0, 100% | 0 / 0, 100% | 50 / 100, 5% | 3 / 10, 96% | 93 / 100, 4% | 13 / 77, 63% | 100 / 100, 0% | 100 / 100, 0% |
| The Treant | 0 / 63, 88% | 0 / 0, 100% | 0 / 0, 100% | 0 / 0, 100% | 0 / 3, 100% | 70 / 100, 8% | 10 / 100, 11% | 100 / 100, 0% | 100 / 100, 0% |
| The Meadow formation (15) | 3 / 20, 96% | 0 / 0, 100% | 0 / 0, 100% | 0 / 0, 100% | 0 / 0, 100% | 0 / 93, 60% | 0 / 0, 100% | 100 / 100, 4% | 100 / 100, 1% |
| The Peak formation (9) | 0 / 0, 100% | 0 / 0, 100% | 0 / 0, 100% | 0 / 0, 100% | 0 / 0, 100% | 3 / 13, 96% | 0 / 0, 100% | 87 / 100, 6% | 100 / 100, 1% |

Read: the spectrum is steep, and a size is a fight for one squad and free for the next. A patrol
of two is free for any machine alone. Three of a swarm type are the lone light machine's fight
(random losing where greedy wins: the Puffin 13 / 87 at 42% of its hull, the Prairie Dog 27 / 63
at 65%, the Skua 70 / 90 at 21%) and free for a heavy (the Honey Badger and the Cottonmouth at 1
to 2%), whose fight is the pack of six (87 at 37%; the Cottonmouth 100 at 5%). A front and a back
of six cost a lone heavy a quarter (random 70, greedy 100), wall every lone light (0 / 0), cost
the built pair 4% and the light pair half (17 / 83 to 87 at 49 to 51%), and cost the trio and
the four nothing. The Peak's pairs are the hardest for their size: three salamanders and two
drakes wall every lone machine (the Honey Badger 7 / 13 at 93%) and take 44% off the built pair
(13 / 90), two bombs and two drakes 64% off the lone Badger. A whole spawn list costs this trio 4
to 6% (random 87 to 100) and the four 1%, the built pair 60 to 96% and the light pair everything.
So the body's formation at a tenth of a four's hull is more than today's whole spawn list for a
tier-two squad, and the proposal's tier table thins tier one's formations for a starter trio and
thickens tier three's. The Gel's pair moved one cell against the probe run before the merge: the
Meadow formation (the trio 90 / 100 at 12% before, 100 / 100 at 4% now; the lone Badger 0 / 0 to
3 / 20), the Gel a wall whose Engulf no longer breaches and whose halves step up in place.

## 26 October, the campaign bot moving as one, and the persona

**The runner work the fresh start's session built without waiting** (`git show 85e28fd:docs/foes_proposal.md`,
its last section): the campaign bot's squad moving as one (every machine toward the pack nearest
the squad, every machine in range fighting it, a caught machine's allies walking into range of
the hunters before the catch opens; `--solo` the old walk, each machine toward its own nearest
enemy), the fight bot's withdrawing persona on it (`--withdraw N`, a catch always fought out),
and a rule the bot had been missing once main's boss row landed: a fight needs an order, a
machine with an action left within attack range of the pack, and only then the boss's fight
brings every machine; without it the bot opened the boss's fight from the gate on its first turn
and won 41% of battles in one fight, 571 fights in 570 battles, a bot artefact and no read.
`tools/campaign_run.gd` at 40 runs from seed 1, greedy, on the merged code (`49211ca`): the squad
as one (`docs/campaign_run.md`), the old walk, and the squad as one withdrawing under half its
fighters' hull. Directions.

| Read | Battles | Won | Wiped | Battles by squad size (one, two, three machines), and won | Fights | Alone (1 of 1), won | The whole squad (3 of 3), won | Withdrawn from |
|---|---|---|---|---|---|---|---|---|
| The squad as one | 416 | 15% | 84% | 167, 165, 84; 0, 8, 60% | 1,049 | 416, 32% | 81, 96% | |
| The old walk | 397 | 13% | 86% | 164, 158, 75; 0, 6, 54% | 976 | 419, 33% | 58, 98% | |
| As one, withdrawing under 50% | 388 | 14% | 85% | 156, 152, 80; 0, 7, 56% | 1,135 | 507, 21% | 81, 97% | 186 (16%) |

Every run lost on each read, 3.8 cities fallen a run, the finale reached by 25 to 32 runs of 40
and won by none. Before the merge, on this branch's base (`ef91382`, the same seeds): the old walk
377 battles, 1% won, 97% wiped, the three-machine battles won 13%, 913 fights, 465 of them alone;
the squad as one 385 and 2%, 466 alone; as one with allies joining a catch 393 and 4%, 458 alone,
the three-machine battles 23%; the old walk withdrawing under 50% 361 and 2%, a quarter of its
fights left.

Read: the lone fights are the roster's, not the walk's. Four battles in five are fought by one or
two machines, wrecks sitting out with no spares (section 3's roster row), and the squad walking as
one moves the alone fights by none (465 to 466 before the merge, 419 to 416 after) and the
whole-squad fights by a third (58 to 81). What moved the battles won from 1% to 13 to 15% is
main's boss row: once a machine stands in range of the boss every machine joins its fight,
whatever its turn, so a trio that reaches the boss fights it together, and the three-machine
battles are won 54 to 60% against 13 to 23% before. The same read says why the proposal's seal
matters: without it the boss's fight is the battle's first decision and not its last. The
persona buys the plain player nothing (14% against 15%, the first city falling a turn sooner),
since a pack withdrawn from walks on to the gate and the bot fights it again next turn; it leaves
a sixth of its fights, a fifth of the lone ones. So the campaign report reads the spiral the
economy answers (the inflow of machines) and the boss row, and the fights' shape is the quick
campaign's to read (`claude/quick-campaign-mode-pafhiv`) until a run can field a squad.

## 26 October, the rally at once

**The rally landing at once, its intents counted** (the bible's rally row, section 5).
`tools/balance.gd -- --seeds 30 --packs "wolf x3,magma_golem x1,meadow formation"`, every row,
random and greedy, on this entry's commit against the same run with its change stashed; the
change carries the greedy bot's read of a rallier (its threat is what its rally adds to the
blows after it), so the delta is the rule and the bot together. Dire Wolf x3 holds its band on
every row (the largest moves 3 to 6 points, inside a cell's band at 30 seeds: the Kite's
random 93 to 90, the Prairie Dog's greedy 73 to 67). The Magma Elemental alone does not move:
its rally needs others on the field. The Meadow formation moves on four greedy cells, three up and
one down: the Honey Badger's 20 to 37, Wainwright & Sutler's team's 40 to 57, the Nemesis's 0
to 3, the Wild Boar's 83 to 73. No cell turns into a wall or goes easy for random
play. A direction at 30 seeds.

## 26 October, area at half

**Spread and Penetrate at half** (built 26 October, `2018722`: the foe a strike is aimed at takes
the blow, every other foe its Spread or Penetrate reaches half, rounded down, before its own
Flak, Shock and armour; a mine's spread the same). The nine runnable tier ones alone against the
twenty packs, as the 25 October table above, `tools/balance.gd`, 200 seeds a cell, random and
greedy, no party, 72,000 fights: won, random / greedy, before and after.

| Row | Every pack | Rank and file (12) | The four big foes | The four formations | Hull lost (greedy) |
|---|---|---|---|---|---|
| Honey Badger | 43 / 67 → 38 / 63 | 72 / 95 → 64 / 92 | 0 / 37 → 0 / 37 | 0 / 11 → 0 / 1 | 53% → 58% |
| Cottonmouth | 38 / 55 → 31 / 49 | 63 / 91 → 52 / 82 | 0 / 0 | 0 / 0 | 51% → 61% |
| Prairie Dog | 11 / 21 → 8 / 19 | 18 / 35 → 13 / 32 | 0 / 0 | 0 / 0 | 85% → 86% |

The other six (the Skua, the Baboon, the Armadillo, the Stingray, the Cassowary, the Puffin)
read the same to the fight: their stock carries no area. By pack: the Cottonmouth's drum, Spread
at the front and Penetrate at the back on every shot, lost the swarms it had cleared at full: the
Goblin and Revenant sixes 40 / 100 to 10 / 62, the Salamander's three 16 / 96 to 11 / 62, the
Bomb's four 79 / 100 to 37 / 96, each a round or more slower. The Badger lost its two formations
(the Waste's 32 to 4%, the Marsh's 12 to 0) and half its Gel wins (58 to 32%); random play on its
swarms fell from 44 to 26%, greedy from 93 to 90. The Prairie Dog's small packs a few points
each, its Needlers 8 to 0%.

Read: the rule moves the three machines that carry area and nothing else, and moves them where
it was meant to, on the swarms. In bands, the Cottonmouth's swarms were cells random play came
close to and greedy play never lost (no decision); at half they hold one (random 10%, greedy
62%). The Badger's formations go back to the walls every other tier one meets alone. The
earlier read of Spread at half (the area-by-shape run above: the Badger 45/69 to 42/66 at 40
seeds) holds in direction; the Cottonmouth, whose every shot carries area, did not exist then.

## 27 October, the bot on the copy

Whether the greedy should read the round preview's copy (Skirmish.preview_round) in place of the
hand-summed forecast, which misses a heal, a last act and a spill. Timed in a cloud session on
a four-machine team (Badger, Clydesdale, Sparrowhawk, Armadillo) against six goblins and three
wolves, six seeds, eight rounds each (18 rounds played): the greedy spends 145 ms a round and
reads 391 forecasts a round, at 0.19 ms each; a copy's play costs 2.42 ms a call on the same
fight. Read through the copy, a round would cost about a second, some seven times what it does,
and the matrix at 200 seeds (hours on one core) a day. Most of the 391 are what-ifs with a
parameter (a shield added, a status granted, a face in hand) the copy does not take, so moving
the baseline reads alone would leave the bot reading two truths. Decision: the bot keeps the
hand sum (the bible's round preview row); the exit is a cell whose band the greedy misreads for
a heal or a last act, when a memoised copy, one play a decision point, is the first thing to try.

## 27 October, the reports on the merged head

**The two short reports rerun on main as it stands after the review's merges** (`3e1d083`: the
round preview and the next-in-line re-pick, the rally at once, Volatile a cost, area at half,
Flak on a 0, the one damage state, the bosses at their tier and the campaign bot moving as one,
together for the first time). `tools/quick_run.gd` at 40 runs from seed 1, greedy, and
`tools/campaign_run.gd` at 40 runs from seed 1, greedy, no persona. Directions.

The quick campaign (`docs/quick_run.md`): no run leaves its first battle (40 of 40, where the
branch's run of 26 October lost 34 there and six runs reached tier two): 12 fall at a formation,
22 at the elite stand-in and 6 at the boss. By fight at tier one: formations won 77% in 7.6
rounds leaving 58% hull (91%, 5.8 rounds and 75% on the branch), the elite 37% leaving 14% (65%,
45%), the boss 0 of 6 (73% of 30). The squad opens its boss fight at 53% hull as before (52%), so
the shift is in the fights and not in the attrition before them.

The campaign (`docs/campaign_run.md`): no run won, 39 of 40 reaching the finale; battles won 7%
(15% on the fresh start's bot of 26 October, before the merges; 1 to 2% before the boss row),
the three-machine battles 36% (54 to 60%), the whole squad's fights 93% (96 to 98%); 0.49
components destroyed a battle and 1.42 a won battle on one damage state (0.67 and 0.35 on the
two states, the 26th's report); no final fought (one on the 26th), since three bosses of one
domain fall in no run.

Read: tier one reads harder for the greedy bot on the merged head than on any branch alone, by
more than any one of the merged rules moved when measured by itself (the rally at once at 30
seeds, area at half at 200 on the tier ones alone, Flak on a 0 on no measured row, next in line
unmeasured). Which rule, or their sum, is the 200-seed matrix's to say (running as this entry is
written; its deltas against `docs/balance.md` of 22 October and the tier-one tables of 25 and 26
October). Until it does, no band read on the branches stands, and the quick campaign's
first-battle question (section 12) is read on these numbers.

**Two experiments, the same 40 quick campaign runs with one rule put back** (the same day, each
a one-line change in a working copy, never committed). The re-pick before next in line (a fresh
pick by the foe's aim when its machine has fallen, in place of the next machine in line): no run
leaves its first battle, the tier-one formations won 79%, the elite 36%, the boss 0 of 6, so
next in line is not what moved. Area at full (every foe a Spread or Penetrate reaches taking the
whole blow, as before 26 October): the branch's shape comes back and past it, the first battle
won 18% (seven runs on, one to the finale), the tier-one formations 94% in 5.5 rounds leaving
80% hull, the elite 65%, the boss 80% of 35, every domain's battles won 50 to 68%.

Read: area at half is the rule that walled the quick campaign's first battle. The 26 October
read of the halving, on the tier ones alone, saw only the three area carriers' swarm cells move;
in a trio those carriers are the Honey Badger and the Cottonmouth, which carried the starters'
formation fights (the 23 October grid: the sixteen trios with either win the five hard fights,
the twelve without top out at 80 to 89%), and a chain of formations with no heal compounds what
each loses. Whether the half stands, with the fresh start's thinner tier-one formations to
answer it, or the player's area stays whole, is Ryan's (section 12's quick campaign question);
the halving's own exit (a plus too strong where back ranks stand) was written for the other
direction.

**The same 40 runs with the bench-hero stand-in out and the Skua's floor of one** (27 October,
Ryan's calls of the day, `docs/quick_run.md` as committed): an elite's slot holds the lead's
formation alone, so the first battle is three formations and the boss. One run of 40 leaves it
(10 fall at a formation, 7 at the formation in the elite's slot, 22 at the boss); the tier-one
formations are won 87% in 7.3 rounds leaving 63% hull, the boss's fight with its formation 15%
of 26 from 59% of the squad's hull (the branch's 73% of 30 from 52%). So the stand-in hid the
boss fight: with it out, most trios reach the boss and lose there, the halving's cost showing on
the one fight a tier-one battle cannot avoid. The Skua's floor moves no quick campaign number
anyone can read at 40 runs; its own row is the next entry.

## 27 October, the Skua's floor of one

**A split strike never below one** (Ryan, 27 October: "rounded down, min 1"; `Skirmish.split_share`),
the Skua's row alone against the 29 packs, `tools/balance.gd --rows skua`, 200 seeds a cell,
random and greedy, 11,600 fights, read against the same row in the day's report (the floor's
one change between them). The row moves +1.2 points for random play and +0.1 for greedy over
the packs; four cells move five or more, three of them up (the Dire Wolves random 85 to 94, the
Drakes random 76 to 85, the Needlers greedy 48 to 55) and the Gels greedy 45 to 40, a band's
width. Read: a roll of 1 no longer wastes a strike, which random play felt most; the Skua's
place among the tier ones does not move, and its start still bites with basics alone (the
to-do's play line).

## 27 October, the balance report on the merged head

**The matrix rerun on main as it stands** (`docs/balance.md`, 313,200 fights, 200 seeds a cell,
random and greedy, eight parts side by side: the 26 rows, the Skua and the Needletail among
them for the first time, against the 29 packs), read cell by cell against the 22 October
report, which predates the targeting at random, the doubled heat, the Gel as a wall, area at
half, Flak on a 0, the one damage state and the bosses at their tier. Then three runs of the
cells that moved most (five rows, the Honey Badger, the Wild Boar, the Nemesis, the Cottonmouth
and the Musk Ox, against six packs: the Needlers, the Salamanders, the Waste and Marsh
formations, the Augur's and the Summoner's finals, 200 seeds a cell) with one rule put back at a
time in a working copy: as the head stands, injuries off (`--injury`), and area at full.

By pack, the mean move over the 24 rows both reports hold, random / greedy: the Gels +24 / +33
(16 rows' cells moved ten points or more, most of them free now: the Badger 7 / 61 to 94 / 100,
the Boar 15 / 53 to 100 / 100, the Armadillo 0 / 0 to 46 / 100); the Bombs -8 / -8, the
Salamanders -4 / -8, the Drakes -3 / -4 (the Armadillo against the Drakes 94 / 100 to 51 / 65,
the Ammit against the Bombs 99 to 69 greedy, the Nemesis against the Salamanders 100 to 76);
the Meadow formation +1 / +4 (the Boar greedy 6 to 55, the Buzzard 0 to 41), the Waste -1 / -2,
the Marsh +1 / -1, the Peak -1 / -1; the Augur's final -4 / -6, the Summoner's -3 / -6; every
other pack within three points, the finale 0 / 0 on every row as before. By row the Cottonmouth
is the one past three points (-3 / -9); the four team rows move a point or less.

What moved each, the experiments deciding where a cell could carry more than one cause:

- The Gel as a wall without a breach (25 October): a lone machine's shield now holds its
  Engulf, so Gel x4 alone is a pack both rungs beat for most of the roster, no decision, and
  the Meadow formation eases for the heavies. The Gel's work is inside a formation, where it
  holds a slot; as a pack of its own it is free.
- The doubled heat (24 October): the Peak's three packs and its finals, the seal's own heat
  walling the Armadillo against the Drakes.
- Area at half (26 October): the Cottonmouth's swarms (the Goblins and Revenants 98 to 62
  greedy) and its finals (the Augur's 88 to 4, the Summoner's 99 to 23, the Cleric's 43 to 10),
  and the formation cells of the other area carriers, which the 26 October read on the tier
  ones alone did not hold: the Badger's Waste 30 to 4 and Marsh 11 to 0, the Boar's Waste 30
  to 7 and Marsh 45 to 14, the Musk Ox's Needlers 60 to 15 and Waste 11 to 6. With area at
  full they come back to the 22nd's bands or near them (the Badger's Waste 32 and Marsh 17,
  the Boar's Waste 22 and Marsh 42, the Cottonmouth's Augur 91 and Summoner 100, the Musk
  Ox's Needlers 54), and the Nemesis, which carries no area, does not move.
- The one damage state (25 October): with injuries off only the Augur's final cells move,
  ten to sixteen points (the Boar 41 to 57 random, the Nemesis 72 to 82, the Musk Ox 70 to
  81, the Cottonmouth 4 to 16 greedy), and the Cottonmouth's Salamanders (56 to 66 greedy):
  the Augur's Omen is the one blow in these cells big enough to injure, and a lone machine
  that loses an entry to it loses the race.
- The Skua reads for the first time (above, its own row at min 1 beside it); the Needletail
  alone reads 0 on all but the small packs, a spotter with no one to spot for.

Read: every move is a rule of the week landing where it was meant to, and one of them, area at
half, lands harder than its read said: on every area carrier alone, on the trios in the quick
campaign (above), and nowhere else. The 23 October grids by stage (`tools/stock_loop.py`, the
starter trios and the endgame fours) were not rerun and predate all of it; this report is the
baseline for the rows it holds until the fresh start lands.

## 27 October, area at half, the forms on the teams

**The halving read on teams, in three forms** (Ryan, 27 October: does the half make sense at
this scale, and does the fall it caused say single-target is too weak). `tools/balance.gd` on
three copies of main's head (`71ab3d7`, before the Zombie Knight's line, so the Marsh formation
is its fifteen), 200 seeds a cell, random and greedy, five team rows against the four formations
and the two swarms of six, 14,400 fights a form: area at half as built; half rounded up
(`(dmg + 1) / 2` at the engine's two sites and in the bot's valuation); and whole (every foe
reached taking the blow, as before 26 October), the bot valuing each form as the engine runs it.
The rows: the starting team (the Honey Badger, the Clydesdale, the Kite: the Claw, the Enfilade
Beam and the Airburst Shell); a four without an area piece (the Armadillo, the Cassowary, the
Skua, the Puffin); a four with two carriers (the Honey Badger, the Cottonmouth, the Cassowary,
the Puffin); a trio without (the Armadillo, the Cassowary, the Puffin); a trio with (the Honey
Badger, the Cottonmouth, the Puffin). Then `tools/quick_run.gd` at 40 runs, greedy, in the
whole and the rounded-up copies, beside the committed run at half (the stand-in out, above).

The arithmetic at this scale first. The rank and file stand at 2 to 6 HP (3 the Goblin's and
the Revenant's, 4 most of the rest) and the area pieces blow 1 to 5: the Claw 2 to 4, the Plow
2 to 5, the Enfilade Beam and the drum's shot 4, the Airburst Shell 1 to 2, the Flakshot 1. A
neighbour's blow, mean, whole / half rounded down / rounded up: the Claw 3.0 / 1.3 / 1.7, the
Plow 3.5 / 1.5 / 2.0, the Beam and the drum 4 / 2 / 2, the Airburst 1.5 / 0.5 / 1.0, the
Flakshot 1 / 0 / 1. The chance a neighbour at 3 HP dies to it: the Claw 67% whole and 0 under
either half, the Plow 75%, 0 and 25%, the Beam and the drum 100%, 0 and 0. So at single digits
a half-blow kills no rank and file at full HP (the Beam's 2 on a Needler the one exception),
whichever way it rounds: the halving removes the neighbours' kills and leaves wounded foes for
the next die, where at the old scale (11 October, above: the Claw's and the Plow's spread at
half cost the Badger three points, 45 / 69 to 42 / 66) it took a share of a foe that took three
blows anyway.

Won, random / greedy, half, then rounded up, then whole (a cell that reads the same under every
form is given once):

| Row | Goblins x6 | Revenants x6 | Meadow formation | Waste | Marsh | Peak |
|---|---|---|---|---|---|---|
| The starting team | 100 / 100 | 100 / 100 | 99 / 100, 98 / 100, 100 / 100 | 99 / 100, 99 / 100, 100 / 100 | 89 / 100, 89 / 100, 94 / 100 | 81 / 100, 85 / 100, 89 / 100 |
| A four, no area | 100 / 100 | 100 / 100 | 99 / 100 | 100 / 100 | 80 / 100 | 70 / 100 |
| A four, two carriers | 100 / 100 | 100 / 100 | 99 / 100, 99 / 100, 100 / 100 | 100 / 100 | 93 / 100, 93 / 100, 97 / 100 | 89 / 100, 91 / 100, 96 / 100 |
| A trio, no area | 97 / 100 | 97 / 100 | 1 / 100 | 27 / 100 | 0 / 87 | 0 / 14 |
| A trio, two carriers | 99 / 100 | 99 / 100 | 77 / 100, 77 / 100, 91 / 100 | 86 / 100, 87 / 100, 95 / 100 | 51 / 100, 50 / 100, 73 / 100 | 36 / 100, 39 / 100, 60 / 100 |

Rounds to win and hull lost, greedy, on the rows the form moves (half, rounded up, whole): the
starting team on the Meadow 6.0 rounds and 7%, 6.0 and 7%, 5.2 and 4%, on the Marsh 5.7 and 8%,
5.6 and 7%, 4.7 and 4%; the four with two carriers on the Meadow 5.3 and 0%, 5.2, 4.2 and 0%, on
the Marsh 4.8, 4.8, 3.6, on the Peak 4.1 and 2%, 4.0, 3.1 and 0%; the trio with two carriers on
the Meadow 6.1 and 4%, 6.0, 4.6 and 1%, on the Marsh 5.6 and 6%, 5.5, 3.9 and 0%, on the Peak
4.8 and 10% with 0.36 components lost, 4.8, 3.7 and 3% with 0.10. The rows without an area piece
do not move by a fight: the four without wins every formation at 100% greedy in 4.5 to 8.0
rounds for 3 to 14% of its hull (the Peak the 14%, 0.6 components lost); the trio without takes
9 to 17 rounds where it wins and bleeds 30% on the Waste, 40% on the Meadow, 70% on the Marsh and
96% on the Peak, which it wins 14% of.

The quick campaign, 40 runs, greedy, the stand-in out, half (the committed run), rounded up,
whole: the first battle won 3%, 8%, 28% (its boss fight 1 of 23, 3 of 21, 11 of 27; whole, four
runs reach the finale and one wins); runs falling at a formation 10, 14, 9, at the elite's slot
7, 5, 4, at the boss 22, 18, 16; the tier-one formations won 87% in 7.3 rounds leaving 63%
hull, 83% in 6.6 leaving 64%, 93% in 5.1 leaving 83%; the squad's hull as the boss fight opens
59%, 64%, 70%; the tier-one boss fights won 15% of 26, 32% of 28, 73% of 60. Past the first
battle the enemy is the same at every tier (no tiers on its side yet), and tier two's formations
are won 100% leaving 85 to 96% hull under every form.

Read. The half walls no four: with an area piece or without, a stock four beats every formation
and swarm at 100% on the greedy rung in a single fight from full hull, for 3 to 14% of its hull,
and random play beats them 70 to 100%, the too-easy side of the bands and not a wall; the form
changes how fast an area four wins (a round or two of four to six) and what it bleeds (a few
points), never whether. So the halving does not say single-target is too weak: the no-area rows
read the same under every form, and they read easy. Where the forms part is the trio: with two
carriers a formation costs it 4 to 10% of its hull at half and 0 to 3% whole, and the Marsh and
the Peak sit in a decision band at half (random 51 and 36, greedy 100) that whole area lifts
toward too easy (73 and 60); without a carrier a trio bleeds a third to all of its hull on a
formation under every form. The quick campaign's first battle is three formations and the
boss's on a trio with no mend, so each fight's rounds compound into the cliff, and whole area
hides it by tempo, a fight of four rounds in place of six, the hull kept for the next. The cliff
is the trio's against the fights' size (section 4's four-machines row: a formation is the
squad's fight) and the boss fight's (the whole formation beside the boss and its escort), the
sizes the foes' fresh start sets, not the rule's. The half does what it was meant to for the
aim and the carriers (the aim matters, the Cottonmouth's swarm cells left the no-decision band
on the 26th), but at single digits it is not a half: it zeroes the neighbours' kills, and
rounding up mends nothing (the first battle 3% to 8%, the cells by 0 to 4 points). The scales
row's own argument, an amp a point a stack so that blows stay at 2 to 6 rather than 1 to 3, is
the argument against a ratio on the blow at this scale: a halved 2 to 6 is the 1 to 3 the scale
was built to avoid. The forms, Ryan's to pick (section 12's quick campaign question): the half
kept, the fresh start's fight sizes answering the trio; whole, the carriers must-picks again
(the 23 October grid) and the aim moot on a swarm; rounded up, measured as nothing; or a printed
number a piece, Spread N and Penetrate N, the neighbours taking N before their own statuses and
armour, Claude's lean: the bible's own exit ("the lever is its number") made the rule, no
rounding, each carrier's price its own (the drum's and the Beam's 4 spreading 2 or 3, the Claw's
and the Plow's 2, the Flak spreaders 1), read on the die as Burn N is; the numbers content's.

## 27 October, the trios against thinner formations, and the Knight's first read

**Formations thinned, for the trio** (the same day, for the quick campaign question and the
three-or-four question). `tools/balance.gd` on main's head after the Zombie Knight's line
(`b9f85c7d`, area at half as built), 200 seeds a cell, random and greedy, three trio rows (the
starting team; the Armadillo, the Cassowary and the Puffin without an area piece; the Honey
Badger, the Cottonmouth and the Puffin with two) against each formation at two thirds and at
half of its size (`--pack`; the Meadow 10 and 8 foes of 15, the Waste 6 and 5 of 9, the Marsh 7
and 6 of 11, the Peak 6 and 5 of 9), and the Marsh at its new full size, 14,400 fights. Then
`tools/quick_run.gd` at 40 runs, greedy, the stand-in out, with tier one's formations at two
thirds and at half (`--density 0.67,1,1` and `0.5,1,1`; the Marsh list before the Knight, as
the committed run at half above).

Won, random / greedy, then the greedy win's rounds and hull, at two thirds and at half:

| Row | Meadow | Waste | Marsh | Peak |
|---|---|---|---|---|
| The starting team | 100 / 100 (3.9 r, 2%), 100 / 100 (3.2 r, 1%) | 100 / 100 (2.3 r, 2%), 100 / 100 (2.1 r, 5%) | 95 / 100 (2.9 r, 3%), 99 / 100 (2.4 r, 2%) | 100 / 100 (2.7 r, 1%), 100 / 100 (2.3 r, 0%) |
| A trio, no area | 68 / 100 (10.5 r, 14%), 94 / 100 (8.3 r, 8%) | 82 / 100 (6.6 r, 10%), 100 / 100 (4.1 r, 3%) | 9 / 89 (10.6 r, 55%, 3.1 lost), 18 / 92 (10.1 r, 49%, 2.9 lost) | 48 / 99 (10.6 r, 37%), 71 / 100 (8.1 r, 19%) |
| A trio, two carriers | 100 / 100 (4.2 r, 1%), 100 / 100 (3.3 r, 0%) | 98 / 100 (2.5 r, 4%), 100 / 100 (2.1 r, 4%) | 59 / 100 (4.1 r, 20%, 1.6 lost), 73 / 100 (3.7 r, 18%, 1.5 lost) | 96 / 100 (3.2 r, 2%), 97 / 100 (2.9 r, 1%) |

Against the formations whole (the entry above, the Marsh at its old fifteen) the trio without
area read 1 / 100 on the Meadow for 40% of its hull, 27 / 100 on the Waste for 30%, 0 / 87 on
the Marsh for 70% and 0 / 14 on the Peak for 96%, the trio with two carriers 77, 86, 51 and 36
by random play at 4 to 10% of its hull.

The quick campaign at tier one thinned, half area, the first battle won 55% at two thirds (16
runs fall at its boss, 2 at a formation) and 70% at half (12 at its boss), from 3% whole; the
tier-one formations won 99% in 3.8 rounds leaving 94% hull and 100% in 3.3 leaving 96%; the
tier-one boss fights 82% of 100 at two thirds; the squad's hull as the boss fight opens 85% and
88%. The runs then play out (4.97 and 6.35 battles a run; none and three reach the finale, none
won), tier two and three the same enemy as tier one, since no tier is the foes' yet.

**The Zombie Knight's first read.** The Marsh at its new full size (the Revenant ×6, the Zombie
Knight ×2, the Ghost ×3), the same rows: the starting team 42 / 99 (5.1 rounds, 23% hull, 0.66
components lost), the trio without area 0 / 0, the trio with two carriers 2 / 77 (9.1 rounds,
74% hull, 4.3 components lost); the old fifteen read 89 / 100 at 8%, 0 / 87 at 70% and 51 / 100
at 6%. Thinned to seven, the Marsh still costs the trio without area 55% of its hull and three
components. The Knight is the Marsh's one armoured foe at 8 HP, armour 1 and a breaching blow of
6: a massive foe's blow on a rank-and-file body (the scales row: the rank and file's blows 2 or
3), and every one of its blows reaches a tier one's 20 to 24 hull past the shield and injures
at a quarter of it, so the pair is an injury mill for a trio. Its numbers were never read before
today, since it never spawned; a placeholder like every number, Ryan's to move.

Read. The fights' size is the bigger lever on the trio's chain by far: a third off tier one's
formations takes the first battle from 3% to 55% at half area, where area whole took it to 28%,
and the thinned formations sit where the bands want a trio, random play losing some and greedy
winning nearly all for a few points of hull, except the Marsh, which the Knight's blow sets
apart. The fours were not run against the thinned fights, since whole formations are already
free for them (the entry above), so the thinned sizes are a trio's fights and the whole ones
nobody's: section 12's three-or-four question.

**A fixed number by shape, the neighbours always taking 2** (the same day, the same five team
rows and six packs at 200 seeds, `mini(dmg, 2)` at the engine's two sites and in the bot's
valuation; the quick campaign at 40 runs beside it). It reads as the half does: no greedy cell
moves, the rounds move by a tenth at most, and the random cells by 0 to 6 points on the trio
with two carriers alone (the Meadow 77 to 79, the Waste 86 to 91, the Peak 36 to 42); the
quick campaign's first battle is won 5% (3% at half, 8% rounded up, 28% whole), the tier-one
formations 83% in 6.6 rounds leaving 65% hull. Read: a 2 on the neighbours is what the halving
already deals from the pieces that carry area (their halves are 1 or 2), so the number a form
gives the neighbours matters only at the swarm's kill threshold, 3 for the Goblin and the
Revenant: below it every form is a softening and reads as the half, at it a form reads as whole
on that class. A number a piece is therefore a dial with two settings on today's rank and file,
a softening (1 or 2) or a kill (3), and a tier's dial rather than a fine one; the fights' size
remains the lever on the trio's chain.

## 27 October, the pricing run

**The pricing run's first pass** (the method and its reads in the proposal, retired 28 October into the bible's pricing row, `git show a89cfc6:docs/pricing_proposal.md`;
`tools/pricing_run.py run prices`, the content and the engine as at main's `e59691d`, this
branch adding tools and docs alone): 393 variants, each one balance-runner process on the
records' four team rows as `--team` rows and on the Arsenal bench's row (the Nemesis, the Ammit,
the Puffin), against the sixteen big fights but the finale (the four massive foes, the four
formations, the eight finals), greedy play at 30 seeds a cell, 188,640 fights, about three
hours on a cloud session's four cores. Every stocked piece knocked out of its row (51), every
slottable component (48) through the same hardpoint of five benches (240), every module on
them (85) and three heat loops on the four team rows (12). A direction, read on the rounds to
win and the hull lost, since every row wins 99 to 100% of these cells.

The rows as stocked, greedy: the mean win rate over the sixteen packs, the mean rounds of the
fights won, the hull lost, the peak heat as a turn ended, the overheats and the damaging dice
held for heat a fight:

| Row | Win | Rounds | Hull | Peak | Overheats | Held |
|---|---|---|---|---|---|---|
| The default team (Honey Badger, Clydesdale, Kite) | 100 | 3.1 | 5% | 80% | 0.21 | 0.11 |
| Minerva's team (Honey Badger, Armadillo, Wild Boar) | 100 | 4.9 | 7% | 31% | 0.05 | 0.01 |
| Kestrel's team (Kite, Buzzard, Puffin) | 100 | 2.9 | 8% | 93% | 0.29 | 0.07 |
| Wainwright & Sutler's team (Clydesdale, Prairie Dog, Dingo) | 99.6 | 5.9 | 18% | 33% | 0.13 | 0.04 |
| The Arsenal bench's row (Nemesis, Ammit, Puffin) | 100 | 4.5 | 10% | 69% | 0.17 | 0.04 |

**The knock-outs.** Ten of the 51 move their row by a fifth of a round or two points of hull;
the other 41 read as their row (the stock's shields and vents among them, every one):

| Row | Machine | Piece out | Its stock share | Rounds | Hull |
|---|---|---|---|---|---|
| Wainwright & Sutler's | Dingo | Airburst Shell | 13% | 5.9 to 6.6 | 18 to 23% |
| The default team | Kite | Transonic Rifle | 13% | 3.1 to 3.8 | 5 to 7% |
| Wainwright & Sutler's | Clydesdale | Enfilade Beam | 8% | 5.9 to 6.4 | 18 to 23% |
| Kestrel's | Kite | Transonic Rifle | 22% | 2.9 to 3.4 | 8 to 9% |
| Kestrel's | Buzzard | Arc Fault Cannon | 10% | 2.9 to 3.4 | 8 to 10% |
| Kestrel's | Buzzard | Overclocked Railgun | 10% | 2.9 to 3.2 | 8 to 9% |
| Wainwright & Sutler's | Clydesdale | Maxigun | 9% | 5.9 to 6.1 | 18 to 20% |
| Kestrel's | Puffin | Laser Carbine | 11% | 2.9 to 3.2 | 8 to 10% |
| Minerva's | Armadillo | Twin Autoguns | 13% | 4.9 to 5.1 | 7 to 8% |
| Wainwright & Sutler's | Prairie Dog | Halo Shield | 8% | 5.9 to 5.6 | 18 to 20% |

**The ladders.** Each candidate's rounds and hull against the bench's stock row, and its share
of the row's spends; hot marks a peak at the maximum or a quarter of an overheat a fight more
than stock, dead a share under 5%:

| Tier | Piece | Kind | Honey Badger | Prairie Dog | Puffin | Buzzard | Nemesis | Mean |
|---|---|---|---|---|---|---|---|---|
| 0 | Twin Autoguns | dir 1-3, heat 0 | +0.0 r, -0% hull, 5% dead | +0.0 r, +0% hull, 25% | +0.2 r, +1% hull, 28% | +0.5 r, +2% hull, 16% | +0.0 r, -0% hull, 13% | +0.14 |
| 0 | Ankle Mortar | ind 1-3, heat 1 | +0.0 r, -0% hull, 5% dead | +0.0 r, +0% hull, 16% | +0.2 r, +1% hull, 14% | +0.5 r, +2% hull, 4% dead | +0.0 r, -0% hull, 2% dead | +0.14 |
| 0 | Coolant Jacket | vent 4 | +0.0 r, -0% hull, 2% dead | +0.2 r, -1% hull, 5% dead | +0.3 r, +2% hull, 4% dead | +0.5 r, +2% hull, 2% dead | +0.0 r, -0% hull, 3% dead | +0.19 |
| 0 | Rivet Gun | dir 2, heat 0 | +0.0 r, +0% hull, 3% dead | -0.1 r, -2% hull, 11% | +0.1 r, +0% hull, 10% | +0.5 r, +2% hull, 2% dead | -0.0 r, -0% hull, 2% dead | +0.09 |
| 0 | Laser Carbine | dir 3, heat 2 | +0.0 r, -0% hull, 7% | -0.5 r, -3% hull, 15% | +0.0 r, +0% hull, 11% | +0.5 r, +2% hull, 17% | +0.0 r, -0% hull, 15% | -0.01 |
| 0 | Bleed Valve | vent 6 | +0.0 r, -0% hull, 5% | +0.2 r, -0% hull, 1% dead | +0.3 r, +2% hull, 8% | +0.5 r, +2% hull, 9% | +0.0 r, +0% hull, 1% dead | +0.19 |
| 0 | Halo Shield | shield 6 | +0.0 r, -0% hull, 1% dead | +0.3 r, -2% hull, 16% | +0.2 r, +1% hull, 7% | +0.5 r, +2% hull, 6% | +0.2 r, -0% hull, 9% | +0.26 |
| 0 | Canopy | shield 8 | +0.0 r, -0% hull, 2% dead | +0.2 r, -1% hull, 4% dead | +0.3 r, +1% hull, 4% dead | +0.5 r, +2% hull, 2% dead | +0.1 r, -0% hull, 2% dead | +0.21 |
| 1 | Shotfire Rack | ind 2-4, heat 2 | +0.0 r, +0% hull, 9% | -0.4 r, -3% hull, 17% | +0.1 r, -0% hull, 15% | +0.5 r, +2% hull, 7% | +0.0 r, +0% hull, 5% dead | +0.03 |
| 1 | Slugthrower | dir 2-5, heat 1 | +0.0 r, +0% hull, 10% | -0.5 r, -3% hull, 17% | +0.0 r, -0% hull, 16% | +0.4 r, +2% hull, 7% | +0.0 r, -0% hull, 7% | -0.00 |
| 1 | Enfilade Beam | dir 4, heat 2, penetrate | -0.1 r, -0% hull, 15% | -1.0 r, -6% hull, 25% | -0.1 r, -0% hull, 13% | +0.3 r, +1% hull, 8% | -0.1 r, -1% hull, 6% | -0.18 |
| 1 | Howitzer | ind 2-5, heat 1 | +0.0 r, +0% hull, 17% | -0.6 r, -4% hull, 24% | +0.0 r, -0% hull, 16% | +0.4 r, +2% hull, 7% | +0.0 r, -0% hull, 7% | -0.01 |
| 1 | Incendiary Shells | ind 1-3, heat 1, burn | -0.1 r, -0% hull, 12% | -0.7 r, -3% hull, 22% | +0.0 r, -0% hull, 15% | +0.5 r, +2% hull, 5% dead | -0.0 r, -0% hull, 5% dead | -0.06 |
| 1 | Overclocked Railgun | dir 10, heat 8, breach | -0.3 r, -1% hull, 11% | -1.9 r, -7% hull, 17% hot | -0.2 r, -1% hull, 24% | +0.3 r, +2% hull, 18% hot | -0.3 r, -0% hull, 8% hot | -0.49 |
| 1 | Arc Fault Cannon | dir 4, heat 2, chain | -0.2 r, -1% hull, 11% | -1.7 r, -8% hull, 19% | -0.3 r, -1% hull, 25% | +0.0 r, +0% hull, 10% | -0.4 r, -1% hull, 8% | -0.51 |
| 1 | Proximity Klaxon | ind 0, heat 1, lure cleave | +0.0 r, -0% hull, 1% dead | +0.2 r, -1% hull, 3% dead | +0.3 r, +2% hull, 2% dead | +0.5 r, +2% hull, 2% dead | +0.1 r, -0% hull, 2% dead | +0.21 |
| 1 | Overcharge Coil | buff  | -0.0 r, -0% hull, 3% dead | -0.1 r, -0% hull, 11% | +0.2 r, +2% hull, 9% | +0.5 r, +2% hull, 1% dead | -0.0 r, -0% hull, 1% dead | +0.11 |
| 1 | Radiator Sail | vent 5 | +0.0 r, -0% hull, 1% dead | +0.2 r, -1% hull, 2% dead | +0.3 r, +2% hull, 2% dead | +0.5 r, +2% hull, 1% dead | +0.0 r, -0% hull, 1% dead | +0.19 |
| 1 | Plasma Arquebus | dir 2-4, heat 2 | +0.0 r, +0% hull, 9% | -0.4 r, -3% hull, 16% | +0.1 r, -0% hull, 15% | +0.5 r, +2% hull, 6% | +0.0 r, +0% hull, 10% | +0.03 |
| 1 | Blazethrower | dir 3, heat 3, burn | -0.1 r, -0% hull, 8% | -1.2 r, -6% hull, 17% | -0.1 r, -0% hull, 12% | +0.4 r, +2% hull, 7% | -0.0 r, -0% hull, 18% | -0.20 |
| 1 | Phased Sublimator | vent 4, cleanse | +0.0 r, -0% hull, 1% dead | +0.2 r, -1% hull, 2% dead | +0.3 r, +2% hull, 3% dead | +0.5 r, +2% hull, 1% dead | +0.0 r, -0% hull, 1% dead | +0.19 |
| 1 | Polarity Projector | dir 0, heat 2, shock | -0.0 r, -0% hull, 3% dead | +0.1 r, +0% hull, 9% | +0.0 r, +1% hull, 10% | +0.5 r, +2% hull, 2% dead | +0.0 r, +0% hull, 3% dead | +0.13 |
| 1 | Shoring Jack | buff  | +0.0 r, -0% hull, 1% dead | +0.4 r, +0% hull, 5% | +0.3 r, +2% hull, 4% dead | +0.5 r, +2% hull, 2% dead | +0.0 r, -0% hull, 2% dead | +0.24 |
| 1 | Oblation Mantle | shield 10 | +0.0 r, -0% hull, 0% dead | +0.2 r, -1% hull, 3% dead | +0.3 r, +2% hull, 1% dead | +0.5 r, +2% hull, 1% dead | +0.1 r, +0% hull, 2% dead | +0.22 |
| 1 | Retribution Thurible | buff  | -0.0 r, -0% hull, 1% dead | +0.1 r, -1% hull, 3% dead | +0.2 r, +2% hull, 5% dead | +0.5 r, +2% hull, 1% dead | -0.0 r, -0% hull, 3% dead | +0.16 |
| 1 | Maxigun | dir 1-2, heat 1 | +0.0 r, -0% hull, 18% | -0.7 r, -4% hull, 27% | +0.0 r, -0% hull, 15% | +0.5 r, +2% hull, 8% | -0.0 r, -1% hull, 6% | -0.05 |
| 1 | Wake Diffuser | vent 3 | +0.0 r, -0% hull, 1% dead | +0.3 r, -0% hull, 6% | +0.3 r, +2% hull, 4% dead | +0.5 r, +2% hull, 1% dead | +0.1 r, -0% hull, 2% dead | +0.23 |
| 1 | Thermal Ray | dir 6, heat 6 | -0.1 r, -0% hull, 9% | -1.3 r, -6% hull, 17% | -0.1 r, -1% hull, 14% | +0.4 r, +3% hull, 9% hot | -0.1 r, -0% hull, 7% | -0.23 |
| 1 | Transonic Rifle | dir 5, heat 4 | -0.0 r, -0% hull, 22% | -1.1 r, -5% hull, 18% | -0.1 r, -0% hull, 34% | +0.4 r, +2% hull, 29% | -0.0 r, -0% hull, 7% | -0.17 |
| 1 | Airburst Shell | ind 1-2, heat 1, cleave flak | -0.0 r, -0% hull, 8% | -0.7 r, -4% hull, 28% | +0.0 r, +0% hull, 14% | +0.4 r, +2% hull, 5% dead | -0.0 r, -0% hull, 3% dead | -0.07 |
| 1 | Blast Door | buff  | +0.1 r, -2% hull, 5% dead | +0.5 r, -7% hull, 12% | +0.3 r, -2% hull, 10% | +0.6 r, +0% hull, 4% dead | +0.4 r, -2% hull, 6% | +0.36 |
| 1 | Decoherence Veil | buff  | +0.1 r, -2% hull, 4% dead | +0.4 r, -4% hull, 5% | +0.2 r, -1% hull, 6% | +0.5 r, +1% hull, 2% dead | +0.2 r, -0% hull, 3% dead | +0.27 |
| 2 | Suppression Battery | ind 1-3, heat 2, suppress | +0.0 r, -0% hull, 4% dead | -0.1 r, -2% hull, 15% | +0.2 r, +1% hull, 14% | +0.5 r, +2% hull, 4% dead | -0.0 r, +0% hull, 2% dead | +0.11 |
| 2 | Coriolis Accelerator | dir 3, heat 1 | -0.1 r, -0% hull, 9% | -1.0 r, -5% hull, 16% | -0.1 r, -0% hull, 13% | +0.4 r, +2% hull, 7% | -0.0 r, -0% hull, 6% | -0.14 |
| 2 | Laminar Deflector | shield 6, rapid | -0.0 r, -0% hull, 1% dead | +0.1 r, -4% hull, 7% | +0.2 r, +1% hull, 3% dead | +0.5 r, +2% hull, 2% dead | -0.0 r, -1% hull, 3% dead | +0.16 |
| 2 | Corona Shield | shield 6, cleanse | +0.0 r, -0% hull, 1% dead | +0.3 r, -2% hull, 8% | +0.2 r, +1% hull, 4% dead | +0.5 r, +2% hull, 2% dead | +0.2 r, -0% hull, 4% dead | +0.26 |
| 2 | Pulse Vacillator | dir 2, heat 2, rapid | -0.0 r, -0% hull, 3% dead | -0.2 r, -3% hull, 11% | +0.1 r, +0% hull, 9% | +0.4 r, +2% hull, 2% dead | -0.1 r, -0% hull, 2% dead | +0.03 |
| 2 | Meteor Artillery | ind 5, heat 6, burn | -0.1 r, -0% hull, 9% | -1.7 r, -7% hull, 18% | -0.2 r, -1% hull, 14% | +0.3 r, +2% hull, 9% hot | -0.2 r, -1% hull, 7% | -0.39 |
| 2 | Entropy Condenser | vent 10 | +0.0 r, -0% hull, 0% dead | +0.2 r, -0% hull, 0% dead | +0.3 r, +2% hull, 0% dead | +0.5 r, +2% hull, 0% dead | +0.0 r, +0% hull, 0% dead | +0.19 |
| 2 | Aurora Lattice | buff  | +0.0 r, -0% hull, 1% dead | +0.2 r, +0% hull, 3% dead | +0.3 r, +2% hull, 3% dead | +0.5 r, +2% hull, 1% dead | +0.0 r, +0% hull, 1% dead | +0.20 |
| 2 | Differentiation Probe | ind 0, heat 2, disrupt | +0.1 r, -0% hull, 4% dead | +0.9 r, -1% hull, 10% | +0.2 r, +1% hull, 6% hot | +0.6 r, +2% hull, 3% hot dead | +0.5 r, +0% hull, 5% | +0.46 |
| 2 | Tesla Gauntlets | dir 4, heat 3, shock | -0.2 r, -1% hull, 9% | -1.3 r, -6% hull, 18% | -0.2 r, -1% hull, 15% | +0.3 r, +1% hull, 9% | -0.1 r, -0% hull, 8% | -0.31 |
| 2 | Cyclic Cannon | dir 2, heat 3 | -0.1 r, -0% hull, 10% | -1.6 r, -7% hull, 19% | -0.1 r, -0% hull, 14% | +0.4 r, +2% hull, 9% | -0.1 r, -1% hull, 8% | -0.29 |
| 2 | Flak Cannon | dir 3, heat 2, flak | -0.1 r, -0% hull, 8% | -1.1 r, -6% hull, 17% | -0.1 r, -0% hull, 12% | +0.5 r, +2% hull, 7% | -0.1 r, -0% hull, 6% | -0.18 |
| 2 | Stoker | dir 3, heat 1, burn | -0.1 r, -0% hull, 8% | -1.2 r, -6% hull, 18% | -0.1 r, -0% hull, 12% | +0.5 r, +2% hull, 7% | -0.0 r, -0% hull, 6% | -0.20 |
| 2 | Backdraft Charge | dir 2, heat 2, suppress | +0.0 r, -0% hull, 3% dead | -0.1 r, -2% hull, 12% | +0.1 r, +0% hull, 10% | +0.5 r, +2% hull, 2% hot dead | +0.0 r, -0% hull, 2% dead | +0.10 |
| 3 | Umbra Inducer | dir 3, heat 0, suppress | +0.0 r, +0% hull, 7% | -0.6 r, -1% hull, 15% | +0.1 r, +2% hull, 12% | +0.5 r, +3% hull, 6% | +0.1 r, +1% hull, 7% | +0.03 |
| 3 | Gravity Knuckles | dir 5, heat 4, burn | -0.1 r, -1% hull, 9% | -1.8 r, -8% hull, 19% | -0.2 r, -1% hull, 14% | +0.4 r, +2% hull, 9% | -0.2 r, -1% hull, 8% | -0.40 |

Guns alone, each tier's rounds against stock, the best and the worst on each bench:

| Tier | Honey Badger | Prairie Dog | Puffin | Buzzard | Nemesis |
|---|---|---|---|---|---|
| 0 | +0.0 to +0.0 over 4 | -0.5 to +0.0 over 4 | +0.0 to +0.2 over 4 | +0.5 to +0.5 over 4 | -0.0 to +0.0 over 4 |
| 1 | -0.3 to +0.0 over 13 | -1.9 to -0.4 over 13 | -0.3 to +0.1 over 13 | +0.0 to +0.5 over 13 | -0.4 to +0.0 over 13 |
| 2 | -0.2 to +0.0 over 9 | -1.7 to -0.1 over 9 | -0.2 to +0.2 over 9 | +0.3 to +0.5 over 9 | -0.2 to +0.0 over 9 |
| 3 | -0.1 to +0.0 over 2 | -1.8 to -0.6 over 2 | -0.2 to +0.1 over 2 | +0.4 to +0.5 over 2 | -0.2 to +0.1 over 2 |

**The module ladder**, each module fitted alone to the bench machine:

| Tier | Module | Stats and text | Honey Badger | Prairie Dog | Puffin | Buzzard | Nemesis | Mean |
|---|---|---|---|---|---|---|---|---|
| 1 | Ablative Plating | hull +8, armour +1, move -10 | -0.0 r, -1% hull | -0.0 r, -2% hull | -0.0 r, -1% hull | +0.0 r, -1% hull | +0.0 r, -2% hull | +0.00 |
| 1 | Boundary-layer Bleed | cooling +1; Each time its heat climbs, it stands up 1 shield. | +0.0 r, -0% hull | -0.0 r, -0% hull | +0.0 r, +0% hull | +0.0 r, -0% hull | +0.0 r, -0% hull | +0.00 |
| 1 | Flak Skirt | hull +6 | +0.0 r, -0% hull | -0.0 r, -1% hull | +0.0 r, -1% hull | +0.0 r, -1% hull | +0.0 r, -1% hull | -0.00 |
| 1 | Field Radiators | heat +4, cooling +1 | -0.0 r, -0% hull | +0.0 r, +0% hull | +0.0 r, -0% hull | +0.0 r, -1% hull | +0.0 r, -0% hull | +0.00 |
| 1 | Susceptibility Tensor | shield +4; Its blows deal 1 more to a foe carrying any status. | -0.0 r, -0% hull | -0.5 r, -4% hull | -0.0 r, -1% hull | -0.0 r, -0% hull | +0.0 r, -1% hull | -0.09 |
| 2 | Ram Frame | hull +24; Its Direct blows aimed at the front rank deal 1 more. | -0.1 r, -2% hull | -0.8 r, -7% hull | -0.1 r, -3% hull | -0.1 r, -3% hull | -0.2 r, -4% hull | -0.26 |
| 2 | Spall Liner | move -10, heat -4; Taking hull damage stands up 2 shield. | -0.0 r, -0% hull | -0.0 r, -1% hull | +0.0 r, -0% hull | +0.0 r, +1% hull hot | +0.0 r, +0% hull | +0.01 |
| 2 | Muzzle Velocity Booster | Its rolled weapons reach 1 higher. | -0.0 r, -0% hull | -0.2 r, -1% hull | -0.0 r, -0% hull | +0.0 r, +0% hull | +0.1 r, +0% hull | -0.05 |
| 2 | Tactical Databank | Its rolled weapons' lowest roll is 1 higher. | -0.1 r, -0% hull | -0.2 r, -1% hull | -0.1 r, -1% hull | +0.0 r, +0% hull | +0.1 r, +0% hull | -0.05 |
| 2 | Artillery Rangefinder | Its Indirect blows aimed at the back rank deal 1 more. | +0.0 r, +0% hull | +0.0 r, +0% hull | +0.0 r, +0% hull | +0.0 r, +0% hull | +0.0 r, +0% hull | +0.00 |
| 2 | Phase Conjugator | shield +4; An ally it shields is Armoured 1 for the round. | -0.0 r, -0% hull | +0.1 r, -1% hull | -0.0 r, -1% hull | -0.0 r, -0% hull | +0.1 r, -0% hull | +0.02 |
| 2 | Ward Plate | shield +8, armour +1 | -0.0 r, -0% hull | +0.0 r, -2% hull | -0.0 r, -1% hull | -0.0 r, -0% hull | +0.1 r, -1% hull | +0.02 |
| 2 | Grievance Reliquary | hull +4; Taking hull damage Overcharges it, a stack a blow. | -0.0 r, -0% hull | -0.0 r, -1% hull | -0.0 r, -1% hull | +0.0 r, -1% hull | -0.0 r, -1% hull | -0.01 |
| 2 | Trim Tabs | heat -4; Rerolling only its own die is free once a round. | -0.0 r, -0% hull | -0.1 r, -1% hull | -0.0 r, -0% hull | -0.0 r, +1% hull hot | +0.0 r, +1% hull | -0.02 |
| 3 | Thrust Overboost | move +20, shield +12; Its weapons run twice as hot. | +0.0 r, -0% hull | +0.1 r, -1% hull | -0.0 r, -2% hull | +0.2 r, +4% hull hot | +0.5 r, +4% hull hot | +0.15 |
| 3 | Exotic-matter Shell | shield +16, heat +6; Every blow on it lands 2 harder. | -0.0 r, +0% hull | +0.1 r, +1% hull | -0.0 r, -1% hull | -0.0 r, -0% hull | +0.1 r, +0% hull | +0.02 |
| 3 | Tithe Coupling | hull +20, shield +12; Every component it spends costs 3 hull. | +0.4 r, +4% hull | +1.2 r, +7% hull | +0.2 r, +0% hull | +0.2 r, +7% hull | -0.6 r, +9% hull | +0.29 |

**The heat ladder**, the four team rows with every attack a class hotter (step: 0 to 1, 1 to
2, 2 to 3, 3 to 4, 4 to 6, 6 to 8, 8 to 10), the eleven heat-0 attacks alone at 1 (cold1), and
cooling 0 on every chassis (cooling0):

| Row | Variant | Win | Rounds | Hull | Peak | Hot rounds | Over | Burned | Held | Damage held | Heat left |
|---|---|---|---|---|---|---|---|---|---|---|---|
| the default team | stock | 100.0 | 3.1 | 5% | 80% | 0.8 | 0.21 | 0.7 | 0.11 | 0.6 | 29% |
| Minerva Heavy Works team | stock | 100.0 | 4.9 | 7% | 31% | 0.1 | 0.05 | 0.2 | 0.01 | 0.0 | 14% |
| Kestrel Dynamics team | stock | 100.0 | 2.9 | 8% | 93% | 1.0 | 0.29 | 1.0 | 0.07 | 0.4 | 43% |
| Wainwright & Sutler team | stock | 99.6 | 5.9 | 18% | 33% | 0.3 | 0.13 | 0.3 | 0.04 | 0.1 | 16% |
| the default team | step | 100.0 | 3.1 | 6% | 102% | 1.9 | 0.35 | 1.0 | 0.19 | 0.9 | 48% |
| the default team | cold1 | 100.0 | 3.1 | 5% | 89% | 1.0 | 0.22 | 0.9 | 0.12 | 0.6 | 34% |
| the default team | cooling0 | 100.0 | 3.1 | 5% | 95% | 1.4 | 0.20 | 0.8 | 0.13 | 0.6 | 45% |
| Minerva Heavy Works team | step | 100.0 | 4.9 | 7% | 55% | 0.3 | 0.10 | 0.3 | 0.01 | 0.0 | 32% |
| Minerva Heavy Works team | cold1 | 100.0 | 4.9 | 7% | 35% | 0.1 | 0.06 | 0.2 | 0.01 | 0.0 | 20% |
| Minerva Heavy Works team | cooling0 | 100.0 | 4.9 | 7% | 47% | 0.3 | 0.09 | 0.3 | 0.01 | 0.0 | 29% |
| Kestrel Dynamics team | step | 100.0 | 3.0 | 10% | 116% | 2.1 | 0.56 | 2.4 | 0.16 | 0.9 | 57% |
| Kestrel Dynamics team | cold1 | 100.0 | 2.9 | 8% | 97% | 1.2 | 0.29 | 1.1 | 0.08 | 0.4 | 47% |
| Kestrel Dynamics team | cooling0 | 100.0 | 3.0 | 9% | 103% | 1.6 | 0.31 | 1.2 | 0.10 | 0.5 | 53% |
| Wainwright & Sutler team | step | 99.4 | 6.0 | 18% | 67% | 0.8 | 0.22 | 0.5 | 0.08 | 0.2 | 38% |
| Wainwright & Sutler team | cold1 | 99.6 | 5.9 | 18% | 35% | 0.3 | 0.15 | 0.4 | 0.03 | 0.1 | 19% |
| Wainwright & Sutler team | cooling0 | 99.0 | 5.9 | 19% | 61% | 0.6 | 0.20 | 0.5 | 0.06 | 0.1 | 35% |

Read:

- **The benches are too strong for most of the read.** Four rows win these cells in 2.9 to
  4.9 rounds for 5 to 10% of their hull, so one hardpoint moves them by a third of a round at
  most and a shield has nothing to save; Wainwright & Sutler's row (5.9 rounds, 18% hull) is
  the one bench with room, and it carries the ladder: tier one's guns take 0.4 to 1.9 rounds
  off it, tier two's 0.1 to 1.7, tier three's 0.6 to 1.8. The 23 October reads said the same
  of a trio against today's packs (the formations and the two breaching bosses are its fights,
  the rest free); the pricing run says it of a bench. Equipment and the setup pieces need a
  harder bench (the formations and the breaching bosses alone, with the planner, or the fresh
  start's compositions) before any of their numbers moves.
- **Tier one's ceiling is tier two's.** The Arc Fault Cannon (1.7 rounds off the car, 0.5 off
  the Nemesis's row, 0.51 off the five benches' mean) and the Overclocked Railgun (1.9, 0.3,
  0.49) sit at or above every tier-two gun (the Meteor Artillery 1.7 and 0.39, the Cyclic Cannon
  1.6 and 0.29, the Tesla Gauntlets 1.3 and 0.31) and the tier-three Gravity Knuckles (1.8 and
  0.40); the next tier-one guns (the Thermal Ray 1.3, the Blazethrower 1.2, the Transonic Rifle
  1.1) sit with tier two's; the rolled tier-one guns (the Slugthrower, the Howitzer, the
  Shotfire Rack, the Arquebus, the Maxigun, the Incendiary Shells, the Airburst Shell) take 0.4
  to 0.7 off the car and nothing elsewhere, a tier above the basics (0.0 to 0.5) and below the
  flat hot guns, which is the heat row's rolled-range price. So a tier-two gun buys no kill
  time a tier-one gun does not: the ladder's steps are heat and shape, not tiers.
- **Heat prices show where heat bites.** On the car (maximum 12, cooling 1) the Railgun peaks
  at 107% with 0.51 overheats a fight (0.13 stock), the Meteor Artillery and the Thermal Ray at
  89% with 0.28, the Transonic Rifle 66%, the Gravity Knuckles 63%; on the Buzzard (maximum 14)
  its stock Arc Fault Cannon is the best piece in its slot by 0.3 rounds over anything, the
  cool gun that chains, and every warmer candidate holds dice for heat (0.21 to 0.27 a fight
  against 0.07), the Railgun at 105% and 0.58 overheats, the Thermal Ray and the Meteor at 100%.
  The Stoker reads as the Blazethrower on every bench (1.2 rounds off the car each, 0.20 off
  the mean each) at a third of the heat.
- **Equipment is dead under the greedy on these packs.** Every shield, vent and buff reads 1 to
  8% of the row's spends and 0.2 to 0.5 rounds behind the stock gun on every bench; the one
  that reads is the Blast Door (0.4 rounds slower, 2 to 7 points of hull saved: a Barrier
  trades a round for hull), the Halo Shield and the Decoherence Veil behind it on the car. The
  Entropy Condenser is never spent (0% on all five), the Oblation Mantle, the Radiator Sail,
  the Phased Sublimator, the Wake Diffuser, the Shoring Jack, the Retribution Thurible, the
  Aurora Lattice and the Proximity Klaxon 1 to 5%. A verdict on the greedy's valuation and the
  benches' ease before any price (the proposal's rule 3; the to-do's valuation line).
- **The Differentiation Probe reads worse than an empty hardpoint** on four benches (0.9
  rounds slower on the car, 0.46 on the mean): a Disrupt moving foes onto the move that costs
  the row more, or spends wasted; the bot's reading of a Disrupt first, then the jellyfish's
  session.
- **The setups on the car**, beside the Dingo's harpoon and its Flak: the Flak Cannon 1.1
  rounds off at 17%, the Overcharge Coil 0.1 off at 11%, the Polarity Projector 0.1 on at 9%,
  the Suppression Battery 0.1 off at 15%, the Backdraft Charge 0.1 off at 12%; the Umbra
  Inducer 0.6 off at 15%, below every tier-two gun on kill time, as a stun is (its worth is the
  turn it buys, which rounds do not count: the finals' hull is its read).
- **The modules.** The Ram Frame is the first module on every bench (0.1 to 0.8 rounds and 2
  to 7 points of hull off, 0.26 off the mean), the universal pick the modules row forbids, the
  catalogue's biggest stat line (hull +24, a placeholder that waited on this run) beside a
  point on every Direct blow at the front, strikes included. The Artillery Rangefinder reads
  nothing on any bench by construction: no bench machine stocks an Indirect gun, so its mirror
  needs an Indirect bench (the Clydesdale's or the Cottonmouth's slot). The Susceptibility
  Tensor reads where setups exist (0.5 rounds and 4 points off the car, beside Flak and a
  Shock; nothing elsewhere); the Booster and the Databank read alike on the car's rolled guns
  (0.2 off) and nothing on the flat kits, the mirror of 11 October again; the stat modules (the
  Ablative Plating, the Flak Skirt, the Field Radiators, the Ward Plate, the Boundary-layer
  Bleed) move no rounds and a point or two of hull, as the Spall Liner, the Phase Conjugator,
  the Grievance Reliquary and the Trim Tabs do; the Thrust Overboost costs the hot benches (0.2
  to 0.5 rounds and 4 points of hull on the Buzzard and the Nemesis) and pays the Puffin its
  shield; the Exotic-matter Shell reads as nothing; the Tithe Coupling is a loss on four
  benches (0.2 to 1.2 rounds and 4 to 7 points of hull on) and on the Nemesis the one module
  that trades hull for rounds (0.6 off for 10 points on), the rage loop spinning on its own
  bites.
- **The Ammit's loop** (the proposal's hole E), fitted by hand on the Arsenal row since the
  ladder fits the bench machine, the Nemesis:

| The Ammit fitted with | Win | Rounds | Hull | Peak | Overheats | The Talons' share | The Mantle's | The Condenser's |
|---|---|---|---|---|---|---|---|---|
| nothing (the row as stocked) | 100 | 4.5 | 10% | 69% | 0.17 | 22% | 1% | 0% |
| the Grievance Reliquary | 100 | 4.4 | 9% | 69% | 0.14 | 22% | 1% | 0% |
| the Reliquary and the Tithe Coupling | 100 | 4.9 | 15% | 73% | 0.19 | 11% | 1% | 0% |
| the Tithe Coupling | 99.2 | 5.6 | 18% | 82% | 0.38 | 7% | 2% | 0% |
| (the Nemesis with the Tithe, from the module ladder) | 100 | 3.9 | 20% | 81% | 0.26 | | 1% | 0% |

  The Reliquary alone reads as stock: the greedy spends the Mantle 1% and the Condenser 0% of
  the row's spends, so nothing bites. With the Tithe beside it the row is slower (4.9 rounds,
  15% hull): the greedy halves the Ammit's Talons spends (22 to 11%) under a 3-hull price it
  reads as a cost, and never feeds the loop (7.2 rounds on the Treant against 4.8, 7.6 on the
  Wyvern against 4.9, the formations a few tenths quicker for twice the hull); the Tithe alone
  5.6 and 18%. Under the greedy the Ammit's permanence never spins, a verdict on the bot's
  horizon (a stack a spend that pays over the rounds after) before any verdict on the loop,
  the planner's read next; the Nemesis's rage loop spins today, at a price in hull.
- **The heat ladder.** A class up on every attack doubles the hot rows' overheats (Kestrel's
  0.29 to 0.56 a fight, its peak 93 to 116%, its hull burned 1.0 to 2.4; the default team's 0.21
  to 0.35 and 80 to 102%) and leaves the cold rows cold (Minerva's peak 31 to 55%, 0.05 to 0.10
  overheats, nothing held; Wainwright & Sutler's 33 to 67%, 0.13 to 0.22), and no row's wins or
  rounds move; the cold basics at 1 move the peaks 2 to 9 points and nothing else; cooling 0
  warms every row, the hot one to 103%, as on 22 October. The greedy answers heat by holding a
  die, never by venting: the Coolant Jacket's share rises from 0.9 to 2.5% to 1.2 to 4.0% under
  a class up, the rows' vents and shields together from 7 to 12% to 8 to 13%, while the dice
  held for heat nearly double. So the heat row's test holds on the hot kits (met, and met harder
  a class up), the cold rows pay in their numbers and reach no heat even a class hotter, and
  the Jacket's job is a question for a bot that vents before the overheat (the to-do's heat
  report) before it is one for the basics' heat.

## 28 October, area numbered, on the team rows

**Spread N, Penetrate N and Splash N with the blow's order, built** (Ryan, 28 October; the
build of `3215b987`, its internal design notes aside). `tools/balance.gd`, 200 seeds a cell,
random and greedy, the five team rows of the 27 October forms entry against the four
formations and the two swarms of six, 14,400 fights, the carriers at the numbers content holds
(the Claw and the Plow Spread 2, the Enfilade Beam Penetrate 3, the Airburst Shell and the
Flakshot Repeater Spread 1, the Musk Ox's two guns Splash 1, the drum Spread 2 and Penetrate 2).
The Marsh formation holds the Zombie Knight pair since 27 October, so its cell is read against
the half on main's head before the build (`2b1ace78`, 2,400 fights), which repeats the Knight's
first read above to the fight; the other cells against the 27 October forms entry, whose content
differs from today's in the Marsh alone.

The rows without an area piece (the four of the Armadillo, the Cassowary, the Skua and the
Puffin; the trio without the Skua) read the same in every cell, wins, rounds and hull, fight for
fight: the blow read for each foe struck leaves single-target play, the Skua's spray among it,
as it was.

Won, random / greedy, at half, numbered, whole (whole not run on today's Marsh):

| Row | Meadow formation | Waste formation | Marsh formation | Peak formation |
|---|---|---|---|---|
| The starting team | 99, 100, 100 / 100 | 99, 100, 100 / 100 | 42, 46 / 99, 100 | 81, 87, 89 / 100 |
| A four, two carriers | 99, 99, 100 / 100 | 100 / 100 | 15, 15 / 100 | 89, 92, 96 / 100 |
| A trio, two carriers | 77, 79, 91 / 100 | 86, 91, 95 / 100 | 2, 2 / 77, 85 | 36, 42, 60 / 100 |

The swarms of six are won by every area row at 99 to 100% under every form, in 2.0 to 2.3
greedy rounds. Greedy rounds and hull lost, half, numbered, whole: the starting team on the
Meadow 6.0 and 7%, 5.8 and 6%, 5.2 and 4%, on the Peak 4.1 and 7%, 4.1 and 7%, 3.7 and 6%, on
the Marsh (with the Knights) 5.1 and 23% with 0.66 components lost, 4.8 and 17% with 0.50; the
four with two carriers on the Peak 4.1, 4.0, 3.1 rounds, on the Marsh 7.0 and 42% with 4.5
components lost, 6.4 and 36% with 4.0; the trio with two carriers on the Meadow 6.1 and 4%, 6.0
and 3%, 4.6 and 1%, on the Peak 4.8 and 10%, 4.7 and 9%, 3.7 and 3%, on the Marsh 9.1 and 74%
with 4.3 components lost, 8.0 and 62% with 3.7. Pick share does not move under any form (the
Claw 12 to 14% of a row's spends, the Enfilade Beam 6 to 7%, the Airburst Shell 2 to 3%).

Read. At these numbers the area sits between the half and whole, nearer the half: the random
rung gains 0 to 6 points on a formation where whole gained up to 24, the greedy rounds fall by
a tenth or two where whole took a round off, and a carrier row's hull on a formation moves a
point or two; only the Marsh, where every blow counts against the Knights, moves further (a
trio's greedy wins 77% to 85%, its hull 74% to 62%). The trio with two carriers reads exactly
the fixed-2 read of 27 October on its random cells (79, 91, 42), its two carriers being Spread 2
pieces, so the firer's adds and each foe's own reads move no cell there. The neighbours' number
tells at the rank and file's kill threshold, 3 for the Goblin and the Revenant (the fixed-2
entry above): the Enfilade Beam's 3 kills what it reaches, the 2s soften, an Overcharged or a
sixth shot lifting a 2 to a kill. So the carriers chip as Ryan asked of the big hitters, no
form walls a four, and a dedicated trash-clearer is a piece at N 3 or more; the numbers are
the lever, each piece's own, read on the bands as the foes' fresh start sets the fights' size.

## 28 October, the rank and file against the chassis tiers

**A grouping of the 27 October matrix** (`docs/balance.md`, 200 seeds a cell, every chassis
with its stock kit, no new run), on Ryan's question of 28 October: do tier-two units need
bigger numbers than tier one's on average just to stay relevant? Each chassis row's greedy
cells against the twelve rank-and-file packs (Goblin x6 to Drake x2) and against the four
formations, meaned by the chassis's tier; rounds to win over the packs won, hull lost over
every fight of the cell, won or not.

| Chassis tier | Rows | Won, rank and file | Rounds to win | Hull lost a fight | Won, formations |
|---|---|---|---|---|---|
| 1 | 9 | 59% | 6.3 | 56% | 0% |
| 2 | 9 | 78% | 4.3 | 38% | 7% |
| 3 | 4 | 84% | 5.6 | 37% | 4% |

By row, won / rounds / hull lost: tier one, the Honey Badger 98% / 4.7 / 27%, the Cottonmouth
87 / 3.2 / 34, the Skua 65 / 3.7 / 47, the Armadillo 64 / 10.5 / 57, the Baboon 58 / 5.6 / 58,
the Stingray 49 / 5.8 / 56, the Cassowary 39 / 7.1 / 74, the Puffin 37 / 7.0 / 76, the Prairie
Dog 32 / 9.5 / 77; tier two, the Wild Boar 99 / 4.9 / 22, the Nemesis 98 / 3.7 / 23, the Whip
Scorpion 98 / 4.1 / 32, the Buzzard 96 / 2.9 / 15, the Clydesdale 90 / 5.1 / 38, the Kite 72 /
3.0 / 32, the Funnel-web 64 / 6.4 / 51, the Needletail 54 / 3.7 / 56, the Dingo 32 / 5.2 / 78;
tier three, the Ammit 92 / 4.8 / 43, the Lammergeier 86 / 2.9 / 23, the Musk Ox 83 / 6.1 / 37,
the Swallowtail 76 / 8.8 / 47.

What the content holds by tier, the same day: a weapon's power times its strikes (a rolled
one at its middle) means 2.2 at tier zero, 3.5 at tier one, 3.2 at tier two and 4.0 at tier
three (4, 15, 10 and 2 pieces; the locked pieces 2.0 over 24); a chassis's hull means 26 at
tier one, 29 at tier two and 39 at tier three, its shield 10, 10 and 13.

Read. By the chassis tier alone, with the kit the stock pass gave each, the rank and file at
their one set of numbers go from a fight a tier one wins three times in five for half its hull
to one a tier three wins five times in six for a third; and the tiers' kit buys options more
than numbers (the weapon means barely move, the hull by half), so the late tiers' power is
keywords and synergy, which a stock loadout on a lone machine does not yet show, and the gap
only widens once the runner fits tier-two and tier-three pieces (the prices-and-tiers pass).
Every tier loses alone to a formation (a wall for one machine of any tier), so the formation
read is the fours'. So yes: a tier's units need a floor above tier one's to stay a fight,
measured against the tier's kit, and the question is what makes the tier (the bible's section
3 row, rewritten the same day). The area numbers sharpen it: a neighbour's Spread 2 or 3 tells
at the rank and file's kill threshold of 3, so a tier whose units stay at 2 to 4 HP dies to
the column once the tier's pieces carry area.

## 28 October, the ladder at 30 seeds

**The ladder's first read** (its brief's section F, `git show 26c54c7:docs/briefs/foes_ladder.md`),
a direction and called one: `tools/balance.gd` at 30 seeds a cell, random and greedy, every
row, on the branch's head (`ccr-6073bda9-p34o8q`, the ladder's content as landed; the layout
fix after it moves no number, and the Red Dragon's Stoke, dropped after it on Ryan's call of
the same day, moves only the Peak's tier-three cells, read again at 200 seeds). Three runs, four parts each: the ladder's 34 new cells (a pack
cell for each of the twenty-six recolours at its strength in its own tier's list, and the
formation of each domain at tiers two and three), 55,080 fights in 1,462 s; tier one's 17
cells at the same seeds for the baseline, since the 27 October matrix's Marsh formation
predates the Zombie Knight, 27,540 fights in 764 s; and the file's first four machines (the
Honey Badger, the Clydesdale, the Sparrowhawk and the Baboon, the default team with the
Baboon) on the twelve formations, 720 fights in 142 s.

The formations by tier, as the lists send them:

| Domain | Tier | Foes | HP | Armour | Base attack |
|---|---|---|---|---|---|
| Meadow | 1 / 2 / 3 | 15 / 19 / 22 | 58 / 74 / 90 | 0 / 2 / 11 | 39 / 63 / 94 |
| Waste | 1 / 2 / 3 | 9 / 10 / 10 | 30 / 41 / 49 | 0 / 0 / 0 | 33 / 43 / 51 |
| Marsh | 1 / 2 / 3 | 11 / 12 / 12 | 46 / 71 / 98 | 2 / 2 / 3 | 33 / 44 / 57 |
| Peak | 1 / 2 / 3 | 9 / 10 / 11 | 42 / 57 / 73 | 0 / 0 / 0 | 57 / 73 / 84 |

The rank and file, each domain's pack cells at a tier (tier one its bases, tiers two and three
its recolours of that tier), every single machine meaned by its chassis tier, greedy won / hull
lost over every fight, and random's wins on the tier-one rows:

| Domain | Tier | Chassis tier 1 | Chassis tier 2 | Chassis tier 3 | Random, tier 1 |
|---|---|---|---|---|---|
| Meadow | 1 | 64% / 50% | 81% / 33% | 86% / 35% | 46% |
| Meadow | 2 | 65% / 56% | 88% / 28% | 98% / 24% | 33% |
| Meadow | 3 | 25% / 87% | 67% / 55% | 58% / 70% | 7% |
| Waste | 1 | 67% / 49% | 79% / 39% | 92% / 33% | 47% |
| Waste | 2 | 52% / 65% | 73% / 49% | 68% / 49% | 31% |
| Waste | 3 | 76% / 47% | 90% / 24% | 97% / 22% | 46% |
| Marsh | 1 | 39% / 70% | 58% / 57% | 53% / 58% | 25% |
| Marsh | 2 | 24% / 87% | 48% / 69% | 39% / 75% | 10% |
| Marsh | 3 | 47% / 59% | 58% / 48% | 62% / 49% | 38% |
| Peak | 1 | 44% / 70% | 76% / 43% | 75% / 46% | 28% |
| Peak | 2 | 38% / 79% | 67% / 47% | 69% / 55% | 19% |
| Peak | 3 | 60% / 56% | 85% / 31% | 85% / 33% | 40% |

By cell, the tier-one rows' random and greedy wins: the easy end the Lich ×1 (97% and 100%),
the Balloon ×2 (83 and 99: its burst spends it, and the pack goes with it), the Basilisk ×2
(76 and 99), the Great Needler ×2 (54 and 91: three HP a needler), the Antlion Queen ×1 (53
and 81); the walls the Death Knight ×2 and the Dread Knight ×2 (0 for every single machine of
every tier), the Fire Lizard ×3 (0, and 22% for a tier two), the Pit Antlion ×2 (7 and 46),
the Wight ×4 (9 and 52) and the Metal Gel ×3 (6 and 44).

The formations, greedy won / hull lost (no single machine of any tier wins a formation at tier
two or three, the Goshawk's 7% on the Meadow's tier two the most):

| Squad | Meadow 1 / 2 / 3 | Waste 1 / 2 / 3 | Marsh 1 / 2 / 3 | Peak 1 / 2 / 3 |
|---|---|---|---|---|
| The default team | 100/6, 100/16, 13/98 | 100/7, 100/15, 93/31 | 97/18, 60/78, 0/100 | 100/8, 100/25, 70/71 |
| Minerva's team | 100/4, 100/15, 33/94 | 100/4, 100/32, 97/55 | 100/46, 53/90, 0/100 | 100/11, 97/43, 13/96 |
| Kestrel's team | 100/12, 97/25, 0/100 | 100/10, 100/29, 93/43 | 100/17, 27/91, 0/100 | 100/7, 90/49, 70/70 |
| Wainwright & Sutler's team | 100/21, 70/72, 0/100 | 100/18, 70/79, 13/98 | 13/97, 0/100, 0/100 | 87/45, 20/94, 3/99 |
| The default team with the Baboon | 100/1, 100/5, 90/57 | 100/3, 100/8, 100/9 | 100/10, 100/32, 0/100 | 100/2, 100/7, 100/19 |

The cleansers against the Ammit and the Cassowary (greedy won / hull lost): the Ammit takes
the Spectre ×3 at 100% for 31% and the Wraith ×2 at 100% for 39%; the Cassowary 17% for 97%
and 3% for 100%. No purging pack exists, so the Ammit's kept Overcharged waits on one (the
to-do's line).

Read against the brief's bands. A tier's formation costs every squad more than the tier
under it in every domain, as it should. The rank and file do not: a tier two's cells cost a
tier-one machine more than tier one's in the Waste, the Marsh and the Peak and about the same
in the Meadow, but tier three's cost less than tier one's in all three and random play wins
38 to 46% of them there (the band: none), since those lists send a tier-three unit one or two
at a time (the Lich, the Antlion Queen, the Great Needlers, the Balloons), where tier two's
send two to four. The Meadow, whose dial is its count, sends three and four at tier three and
reads as the band asks. The formations at tier three wall every single machine, as asked; for
the four they are a fight in the Meadow (90% for 57%) and nothing in the Waste (100% for 9%)
or the Peak (100% for 19%), and a wall in the Marsh (0%), whose Dread Knights (16 HP, armour,
a breaching 8, a last act and a Reraise) and Death Knight (12 HP, the guard on every foe) make
it what the Zombie Knight pair began (the status's injury mill). The numbers that would move
each, for Ryan's word and moved by none of these runs: the tier-three strengths (the Lich ×1
and the Antlion Queen ×1 to two or three, the Great Needler ×2 and the Balloon ×2 to four), or
the Waste's and the Peak's tier-three HP above the floor; the Marsh's knights (their HP, 12 and
16, or the Dread Knight ×2 to one, or the Marsh's tier-three dial ×2 to the floor's ×1.5); and
the Balloon's burst spending a pack that a lone machine then wins.

The campaign report rerun once beside it, for the record (`docs/campaign_run.md`, 40 runs,
198 s), since the tier-two and tier-three battles field the ladder now: the plain player wins
none, as before; its tier-two battles (the report's tier 1, counting from 0) are won in none of
160 where they were 5%, its runs end a turn sooner (8.8 turns), every city falls in every run
(four of four), and its machines end with 39% of their hardpoints filled where they kept 59%.
The spiral it was, a little steeper; no decision reads it.

## 28 October, the pricing run's area carriers on the numbered area

**The car bench rerun on the merged head** (main's `a34a3cc` merged into the pricing run's
branch: the numbered area, the blow's order, the Marsh's Zombie Knight pair; `tools/pricing_run.py
run area28 --benches prairie_dog --pieces ... --modules ...`): the four team rows as stocked, and
fourteen candidates and four modules on the Prairie Dog's first hardpoint in Wainwright &
Sutler's row, greedy at 30 seeds against the sixteen big fights, 10,560 fights; then the
Howitzer and the Meteor Artillery with Splash 1 and 2 as what-ifs by hand (`--set` on the
keywords and the number, the Meteor's Burn kept), 1,920 fights. A direction, read beside the
27 October run's same variants.

The rows as stocked, the 27 October run against the merged head (win, rounds, hull lost):

| Row | 27 October | 28 October, the merged head |
|---|---|---|
| The default team | 100, 3.1, 5% | 99.8, 3.2, 7% |
| Minerva's team | 100, 4.9, 7% | 100, 5.3, 11% |
| Kestrel's team | 100, 2.9, 8% | 100, 2.9, 9% |
| Wainwright & Sutler's team | 99.6, 5.9, 18% | 93.5, 6.1, 24% |

The candidates on the car, each against its own run's stock row (rounds, hull, the candidate's
share), and its peak heat and overheats on the merged head:

| Candidate | Kind | 27 October | 28 October | Peak, overheats |
|---|---|---|---|---|
| Twin Autoguns (stock) | Direct 1 to 3, heat 0 | +0.0 r, +0% hull, 25% | +0.0 r, +0% hull, 24% | 35%, 0.18 |
| Laser Carbine | Direct 3, heat 2 | -0.5 r, -3%, 15% | -0.6 r, -2%, 14% | 37%, 0.19 |
| Howitzer | Indirect 2 to 5, heat 1 | -0.6 r, -4%, 24% | -0.5 r, -4%, 24% | 33%, 0.12 |
| Maxigun | Direct 1 to 2 x3, heat 1 | -0.7 r, -4%, 27% | -0.7 r, -4%, 26% | 33%, 0.13 |
| Airburst Shell | Indirect 1 to 2, heat 1, Spread 1, Flak 1 | -0.7 r, -4%, 28% | -0.6 r, -4%, 26% | 34%, 0.12 |
| Enfilade Beam | Direct 4, heat 2, Penetrate 3 | -1.0 r, -6%, 25% | -1.0 r, -6%, 24% | 37%, 0.10 |
| Flak Cannon | Direct 3, heat 2, Flak 2 | -1.1 r, -6%, 17% | -1.2 r, -6%, 17% | 37%, 0.17 |
| Tesla Gauntlets | Direct 4, heat 3, Shock | -1.3 r, -6%, 18% | -1.4 r, -7%, 18% | 50%, 0.14 |
| Cyclic Cannon | Direct 2 x4, heat 3 | -1.6 r, -7%, 19% | -1.7 r, -8%, 19% | 49%, 0.13 |
| Arc Fault Cannon | Direct 4, heat 2, Chain | -1.7 r, -8%, 19% | -1.7 r, -10%, 18% | 55%, 0.16 |
| Meteor Artillery | Indirect 5, heat 6, Burn 3 | -1.7 r, -7%, 18% | -1.8 r, -9%, 17% | 88%, 0.31 |
| Overclocked Railgun | Direct 10, heat 8, Breach | -1.9 r, -7%, 17% | -2.0 r, -11%, 16% | 107%, 0.52 |
| Proximity Klaxon | Indirect debuff, heat 1, Lure, Spread | +0.2 r, -1%, 3% | +0.2 r, +1%, 3% | 36%, 0.20 |
| Overcharge Coil | a buff, Overcharged 2 | -0.1 r, -0%, 11% | -0.1 r, -0%, 10% | 35%, 0.18 |
| Ram Frame (module) | +1 on Direct blows at the front | -0.8 r, -7% | -0.8 r, -9% | 32%, 0.10 |
| Susceptibility Tensor (module) | +1 on a foe carrying a status | -0.5 r, -4% | -0.4 r, -3% | 33%, 0.13 |
| Muzzle Velocity Booster (module) | rolled weapons reach 1 higher | -0.2 r, -1% | -0.2 r, -1% | 35%, 0.16 |
| Tactical Databank (module) | rolled weapons' lowest roll 1 higher | -0.2 r, -1% | -0.1 r, -1% | 34%, 0.16 |

The what-ifs on the car, against the merged head's stock row (6.1 rounds, 24% hull):

| The shell with a Splash | Rounds | Hull | Share | Peak |
|---|---|---|---|---|
| Howitzer, Splash 1 | 5.3 (-0.9) | 18% (-6) | 24% | 32% |
| Howitzer, Splash 2 | 5.0 (-1.2) | 16% (-8) | 25% | 31% |
| Meteor Artillery, Burn 3 and Splash 1 | 3.7 (-2.4) | 10% (-13) | 19% | 87% |
| Meteor Artillery, Burn 3 and Splash 2 | 3.7 (-2.4) | 9% (-14) | 20% | 88% |
| Meteor Artillery, Splash 1 alone (its Burn dropped, a first run's slip) | 4.9 (-1.2) | 16% (-7) | 16% | 87% |
| Meteor Artillery, Splash 2 alone | 4.8 (-1.3) | 16% (-8) | 16% | 89% |

Read:

- The rows read a little harder on the merged head, the Marsh's Knight pair most of it
  (Wainwright & Sutler's row 99.6 to 93.5% won, 18 to 24% hull; Minerva's 4.9 to 5.3 rounds),
  and every candidate's delta against its own stock row holds within a tenth of a round and a
  point or two of hull: the numbered area (the Beam's Penetrate 3, the Airburst's Spread 1 in
  place of the half) and the blow's order move no rank on the car, so the 27 October ladders
  stand as directions on the merged head. The Ram Frame reads two points of hull more under the
  order (its point on every area foe as on every strike), the Tensor a point less; the Railgun
  four points of hull more.
- The Howitzer with Splash 1 takes 0.9 rounds and 6 points of hull off the row, with Splash 2
  1.2 and 8, from 0.5 and 4 plain: a chip at the neighbours moves a tier-one shell into tier
  two's band on kill time at heat 1, the number the lever.
- The Meteor Artillery with Splash 1 or 2 takes 2.4 rounds and 13 to 14 points off, the
  biggest delta any piece has read on this bench, and the same at both numbers: its riders
  land on every foe struck (the blow's order), so a Splash on it is Burn 3 on up to five foes
  and the rank and file die to the fire whatever N is; without its Burn (the slip) a Splash of
  1 or 2 reads 1.2 and 1.3, a plain shell's step. On the Meteor the rider is the lever, not the
  number. Claude's lean for section 12's shells question: the Howitzer carries Splash 1 (the
  chip Ryan named for the big hitters), the Meteor none while Burn rides every foe struck, or
  Splash 1 at Burn 2 as the next what-if, since an area fire is a piece of its own (the
  pricing proposal's hole A asks for fire's second reader, not a bigger first setter); Ryan's
  to move.

## 28 October, the vanilla ladder

**The vanilla ladder** (`tools/pricing_run.py run vanilla28 --parts vanilla,vanillaheat,ladders
--benches prairie_dog,goshawk --pieces ...`, the merged head of the 28th; the method in
the scale, the bible's pricing row; the proposal's section 1 at `git show a89cfc6:docs/pricing_proposal.md`): Ryan's frame of the 28th, a piece priced by
its effectiveness and never its number, the baseline a vanilla at each tier, heat priced up
from the heatless vanilla, a rolled gun its mean. A flat heatless gun reshaped by `--set` from
a basic no bench row stocks (the Rivet Gun for the Direct, the Shotfire Rack made flat for the
Indirect) in the bench hardpoint at every number from 2 to 10, so the row's other dice stay as
they are; the same vanilla at 3, 5 and 7 across heat 0, 2, 4, 6 and 8; and twenty real guns in
the same slot, each read in vanilla points, the heatless flat Direct number that takes the same
rounds off the row. Two benches: the Prairie Dog's first hardpoint in Wainwright & Sutler's row
(the cold car, maximum 12, cooling 1, the one bench with room) and the Buzzard's third in
Kestrel's row (the hot flyer, maximum 14, cooling 1, where heat bites). The sixteen big fights
but the finale, greedy at 30 seeds a cell: 124 variants, 59,520 fights, about 44
minutes on a cloud session's four cores. A direction, read on the rounds to win and the hull
lost, since both rows win these cells.

**The heatless curve**, a flat gun of each shape at heat 0 in the bench hardpoint: rounds off
the stock row, hull off it, and the vanilla's share of the row's spends (the car's stock row
6.1 rounds and 24% hull, the Buzzard's 2.9 and 8%):

| Number | flat Indirect, Prairie Dog | flat Indirect, Buzzard | flat Direct, Prairie Dog | flat Direct, Buzzard |
|---|---|---|---|---|
| 2 | -0.0 r, -1%, 11% | +0.4 r, +2%, 2% | -0.1 r, -1%, 11% | +0.4 r, +2%, 2% |
| 3 | -0.5 r, -3%, 14% | +0.4 r, +2%, 5% | -0.5 r, -3%, 14% | +0.4 r, +2%, 5% |
| 4 | -0.9 r, -6%, 16% | +0.4 r, +2%, 9% | -0.9 r, -5%, 16% | +0.4 r, +2%, 8% |
| 5 | -1.2 r, -7%, 18% | +0.3 r, +2%, 9% | -1.2 r, -7%, 18% | +0.3 r, +2%, 9% |
| 6 | -1.5 r, -9%, 19% | +0.3 r, +2%, 10% | -1.6 r, -9%, 19% | +0.3 r, +1%, 10% |
| 7 | -1.7 r, -10%, 19% | +0.3 r, +2%, 10% | -1.7 r, -10%, 19% | +0.3 r, +1%, 10% |
| 8 | -1.9 r, -10%, 19% | +0.3 r, +1%, 11% | -1.9 r, -11%, 19% | +0.3 r, +1%, 11% |
| 10 | -2.2 r, -13%, 19% | +0.2 r, +1%, 10% | -2.2 r, -13%, 20% | +0.2 r, +1%, 10% |

**The heat grid on the car** (flat Direct; the flat Indirect reads the same within a tenth of
a round in every cell): rounds off stock, hull off stock, share, the peak heat as a turn ended,
the overheats and the dice held for heat a fight, hot where the peak reaches the maximum or the
overheats rise a quarter a fight over stock (0.13):

| Number | heat 0 | heat 2 | heat 4 | heat 6 | heat 8 |
|---|---|---|---|---|---|
| 3 | -0.5 r, -3%, 14%, 34%, 0.17, 0.03 | -0.6 r, -2%, 14%, 37%, 0.19, 0.04 | -0.6 r, -2%, 13%, 60%, 0.22, 0.05 | -0.3 r, -1%, 12%, 79%, 0.29, 0.11 | -0.2 r, -1%, 9%, 82%, 0.41, 0.19 |
| 5 | -1.2 r, -7%, 18%, 32%, 0.10, 0.01 | -1.2 r, -7%, 18%, 37%, 0.12, 0.03 | -1.2 r, -6%, 18%, 67%, 0.20, 0.03 | -1.0 r, -5%, 15%, 87%, 0.30, 0.06 | -0.8 r, -3%, 12%, 95%, 0.55, 0.10 hot |
| 7 | -1.7 r, -10%, 19%, 30%, 0.08, 0.02 | -1.7 r, -9%, 19%, 35%, 0.10, 0.02 | -1.7 r, -9%, 19%, 65%, 0.18, 0.03 | -1.6 r, -8%, 17%, 90%, 0.33, 0.05 | -1.3 r, -6%, 14%, 104%, 0.61, 0.07 hot |

**The heat grid on the Buzzard** (flat Direct; the Indirect the same), the stock row's
overheats 0.29 and its held dice 0.07:

| Number | heat 0 | heat 2 | heat 4 | heat 6 | heat 8 |
|---|---|---|---|---|---|
| 3 | +0.4 r, +2%, 5%, 95%, 0.38, 0.20 | +0.4 r, +2%, 5%, 96%, 0.41, 0.21 | +0.4 r, +2%, 5%, 97%, 0.43, 0.24 | +0.4 r, +3%, 4%, 99%, 0.46, 0.22 | +0.4 r, +3%, 3%, 100%, 0.49, 0.22 |
| 5 | +0.3 r, +2%, 9%, 92%, 0.32, 0.22 | +0.3 r, +2%, 9%, 93%, 0.36, 0.20 | +0.3 r, +2%, 9%, 97%, 0.38, 0.19 | +0.4 r, +2%, 8%, 101%, 0.43, 0.21 hot | +0.4 r, +3%, 7%, 100%, 0.49, 0.21 hot |
| 7 | +0.3 r, +1%, 10%, 89%, 0.32, 0.20 | +0.3 r, +2%, 10%, 91%, 0.36, 0.19 | +0.3 r, +2%, 10%, 95%, 0.39, 0.20 | +0.3 r, +2%, 9%, 100%, 0.44, 0.21 hot | +0.3 r, +3%, 8%, 102%, 0.51, 0.20 hot |

**The pool's attacks in vanilla points on the car**, the heatless flat Direct number that takes
the same rounds off the row: the twenty guns of this run, the area carriers rerun on the merged
head (28 October, above) and the rest from the 27 October run (its stock row 5.9 rounds and 18%
hull; the rerun found every delta holding within a tenth of a round), each converted with
today's curve:

| Tier | Piece | Its number, heat, keywords | Rounds off stock | Vanilla points | Share | Run |
|---|---|---|---|---|---|---|
| 0 | Laser Carbine | 3, heat 2 | -0.6 r, -2% hull | 3.1 | 14% | vanilla28 |
| 0 | Rivet Gun | 2, heat 0 | -0.1 r, -2% hull | 2.2 | 11% | 27th |
| 0 | Twin Autoguns | 1-3, heat 0 | +0.0 r, +0% hull | 2 or under | 24% | vanilla28 |
| 0 | Ankle Mortar | 1-3, heat 1 | +0.0 r, +0% hull | 2 or under | 16% | 27th |
| 1 | Overclocked Railgun | 10, heat 8, breach | -2.0 r, -11% hull | 8.8 | 16% | vanilla28 |
| 1 | Arc Fault Cannon | 4, heat 2, chain | -1.7 r, -10% hull | 6.7 | 18% | vanilla28 |
| 1 | Thermal Ray | 6, heat 6 | -1.3 r, -7% hull | 5.3 | 17% | vanilla28 |
| 1 | Blazethrower | 3, heat 3, burn 2 | -1.3 r, -6% hull | 5.3 | 17% | vanilla28 |
| 1 | Transonic Rifle | 5, heat 4 | -1.2 r, -6% hull | 4.9 | 18% | vanilla28 |
| 1 | Enfilade Beam | 4, heat 2, penetrate 3 | -1.0 r, -6% hull | 4.3 | 24% | vanilla28 |
| 1 | Maxigun | 1-2 x3, heat 1 | -0.7 r, -4% hull | 3.5 | 26% | vanilla28 |
| 1 | Incendiary Shells | 1-3, heat 1, burn 2 | -0.7 r, -3% hull | 3.4 | 22% | 27th |
| 1 | Airburst Shell | 1-2, heat 1, cleave 1 flak 1 | -0.6 r, -4% hull | 3.2 | 26% | vanilla28 |
| 1 | Slugthrower | 2-5, heat 1 | -0.6 r, -3% hull | 3.2 | 17% | vanilla28 |
| 1 | Howitzer | 2-5, heat 1 | -0.5 r, -4% hull | 3.0 | 24% | vanilla28 |
| 1 | Plasma Arquebus | 2-4, heat 2 | -0.4 r, -2% hull | 2.8 | 16% | vanilla28 |
| 1 | Shotfire Rack | 2-4, heat 2 | -0.4 r, -3% hull | 2.8 | 17% | 27th |
| 1 | Polarity Projector | debuff 0, heat 2, shock | +0.1 r, +0% hull | 2 or under | 9% | 27th |
| 1 | Proximity Klaxon | debuff 0, heat 1, lure cleave | +0.2 r, +1% hull | 2 or under | 3% | area28 |
| 2 | Meteor Artillery | 5, heat 6, burn 3 | -1.8 r, -9% hull | 7.2 | 17% | vanilla28 |
| 2 | Cyclic Cannon | 2 x4, heat 3 | -1.7 r, -8% hull | 6.8 | 19% | vanilla28 |
| 2 | Tesla Gauntlets | 4, heat 3, shock | -1.4 r, -7% hull | 5.4 | 18% | vanilla28 |
| 2 | Stoker | 3, heat 1, burn 2 self_burn 1 | -1.3 r, -6% hull | 5.3 | 17% | vanilla28 |
| 2 | Flak Cannon | 3, heat 2, flak 2 | -1.2 r, -6% hull | 5.0 | 17% | vanilla28 |
| 2 | Coriolis Accelerator | 3, heat 1, power_per_missing 1 per_missing 5 | -1.0 r, -5% hull | 4.2 | 16% | vanilla28 |
| 2 | Pulse Vacillator | 2, heat 2, rapid | -0.2 r, -3% hull | 2.4 | 11% | 27th |
| 2 | Backdraft Charge | 2, heat 2, suppress gates suppress: when target_status, status burning, stacks 2 consumes burning per_consumed 1 | -0.1 r, -2% hull | 2.2 | 12% | 27th |
| 2 | Suppression Battery | 1-3, heat 2, suppress gates suppress: when target_status, status flakked | -0.1 r, -2% hull | 2.1 | 15% | 27th |
| 2 | Differentiation Probe | debuff 0, heat 2, disrupt | +0.9 r, -1% hull | 2 or under | 10% | 27th |
| 3 | Gravity Knuckles | 5, heat 4, burn 3 | -1.9 r, -9% hull | 7.7 | 18% | vanilla28 |
| 3 | Umbra Inducer | 3, heat 0, suppress volatile 3 | -0.6 r, -1% hull | 3.2 | 15% | 27th |

**The same twenty on the Buzzard**, where the heatless curve is flat (0.2 rounds between 2 and
10: the slot fires a tenth of the time and the row wins in 2.9 rounds), so no vanilla points,
only the rounds against stock, the share and the peak:

| Tier | Piece | Its number, heat, keywords | Rounds off stock | Share | Peak |
|---|---|---|---|---|---|
| 0 | Laser Carbine | 3, heat 2 | +0.4 | 17% | 96% |
| 0 | Twin Autoguns | 1-3, heat 0 | +0.4 | 16% | 98% |
| 1 | Overclocked Railgun | 10, heat 8, breach | +0.2 | 19% | 104% |
| 1 | Thermal Ray | 6, heat 6 | +0.4 | 9% | 100% |
| 1 | Transonic Rifle | 5, heat 4 | +0.3 | 30% | 97% |
| 1 | Maxigun | 1-2 x3, heat 1 | +0.4 | 8% | 94% |
| 1 | Arc Fault Cannon | 4, heat 2, chain | +0.0 | 10% | 93% |
| 1 | Enfilade Beam | 4, heat 2, penetrate 3 | +0.3 | 8% | 92% |
| 1 | Howitzer | 2-5, heat 1 | +0.4 | 7% | 96% |
| 1 | Slugthrower | 2-5, heat 1 | +0.4 | 7% | 96% |
| 1 | Blazethrower | 3, heat 3, burn 2 | +0.4 | 7% | 96% |
| 1 | Plasma Arquebus | 2-4, heat 2 | +0.4 | 6% | 97% |
| 1 | Airburst Shell | 1-2, heat 1, cleave 1 flak 1 | +0.3 | 3% | 97% |
| 2 | Cyclic Cannon | 2 x4, heat 3 | +0.3 | 10% | 94% |
| 2 | Meteor Artillery | 5, heat 6, burn 3 | +0.3 | 9% | 100% |
| 2 | Tesla Gauntlets | 4, heat 3, shock | +0.2 | 9% | 92% |
| 2 | Coriolis Accelerator | 3, heat 1, power_per_missing 1 per_missing 5 | +0.4 | 7% | 93% |
| 2 | Flak Cannon | 3, heat 2, flak 2 | +0.4 | 7% | 94% |
| 2 | Stoker | 3, heat 1, burn 2 self_burn 1 | +0.4 | 7% | 94% |
| 3 | Gravity Knuckles | 5, heat 4, burn 3 | +0.3 | 9% | 95% |

**The rolled and strikes guns against their means** (the middle of the range times the strikes):

| Piece | Its number, heat | Mean | Prairie Dog points | Buzzard points |
|---|---|---|---|---|
| Slugthrower | 2-5, heat 1 | 3.5 | 3.2 | 3.9 |
| Twin Autoguns | 1-3, heat 0 | 2.0 | 2 or under | 2 or under |
| Howitzer | 2-5, heat 1 | 3.5 | 3.0 | 4.2 |
| Plasma Arquebus | 2-4, heat 2 | 3.0 | 2.8 | 3.9 |
| Maxigun | 1-2 x3, heat 1 | 4.5 | 3.5 | 4.0 |
| Cyclic Cannon | 2 x4, heat 3 | 8.0 | 6.8 | 6.3 |

Read:

- **A vanilla point buys a third of a round up to 6 and a seventh past it on the car.** The
  heatless flat gun takes 0.1 rounds off at 2, 0.5 at 3, 0.9 at 4, 1.2 at 5, 1.6 at 6, then 1.7
  at 7, 1.9 at 8 and 2.2 at 10, the hull 1 to 13%: the knee sits where a blow kills any of the
  rank and file outright (their HP 2 to 6), and past it a point buys kill time only on the
  massive foes and the heroes. The flat Indirect reads the same at every number, so the shape
  is free on this bench and a reach price is the fight's, not the piece's.
- **The hot bench reads no number.** On the Buzzard every vanilla at every number and heat
  reads 0.2 to 0.4 rounds behind its stock Arc Fault Cannon, with 2 to 11% of the row's spends:
  the third gun on a hot die fires a tenth of the time, and the row wins in 2.9 rounds without
  it. What beats the vanilla there is a keyword that reaches a second foe or amplifies the row:
  the Chain (level with stock, the one piece that is), the Shock and the Breach (0.2 behind),
  Burn 3 and Penetrate 3 (0.3). The hot bench prices reach and nothing else.
- **Heat's knee on a cold die is 6, the heat row's third round.** Heat 2 and 4 move nothing at
  3, 5 or 7 (the peak 37 to 67%); heat 6 takes 0.2 rounds back at every number (the peak 79 to
  90%, 0.3 overheats a fight), 0.6 to 0.7 vanilla points; heat 8 takes 0.3 to 0.4 back and reads
  hot (the peak 95 to 104%, 0.4 to 0.6 overheats), 0.9 points at 3, 1.3 at 5 and 2.0 at 7, a
  quarter of the number: a die of 7 held for heat forgoes more than a die of 3. On the Buzzard
  no heat cell moves the rounds; the overheats climb from 0.31 to 0.53 a fight and the hull lost
  from 1 to 3 points, so a hot die pays a third gun's heat in hull however small its number.
- **A rolled gun is its mean, less a third of a point.** The Slugthrower reads 3.2 for a mean
  of 3.5, the Howitzer 3.0 for 3.5, the Arquebus 2.8 for 3.0, the Twin Autoguns 2 or under for
  2: the threshold a kill needs, the roll's low end wasting a point. A strikes gun reads a point
  under its total (the Maxigun 3.5 for 4.5, the Cyclic Cannon 6.8 for 8), the armour and the
  overkill each strike pays alone. Ryan's asymptote holds within that.
- **The keywords in vanilla points on the car**: Flak 2 buys 2.0 (the Flak Cannon 5.0 for its
  3, beside the Dingo's and the Clydesdale's guns), Burn 2 2.3 (the Stoker and the Blazethrower
  5.3 for their 3 at heat 1 and 3 alike), Burn 3 2.7 (the Knuckles 7.7 for 5; the Meteor 7.2
  after heat 6's 0.7), the Chain 2.7 (the Arc Fault 6.7 for 4), the Shock 1.4 (the Tesla 5.4
  for 4, beside the Maxigun's strikes), Penetrate 3 0.3 (the Enfilade 4.3 for 4: no second foe
  in the line at the car's reach), the Breach about 1 (the Railgun 8.8 for 10, less heat 8's
  2), the Coriolis's point a missing five 1.2, the Airburst's Cleave 1 and Flak 1 together 1.7
  over its mean of 1.5. Tier two's three setups (the Vacillator, the Backdraft, the Battery)
  read 2.1 to 2.4, under tier zero, the greedy's valuation before their price.
- **The tiers on the scale**: tier zero 2 to 3.1; tier one 2.8 to 3.5 for its rolled and
  strikes guns, 4.3 for the Enfilade, 4.9 to 5.3 for the hot flat guns and the Blazethrower,
  the Arc Fault 6.7 and the Railgun 8.8 outliers; tier two 4.2 to 5.4 for its keyword pieces,
  the Cyclic 6.8 and the Meteor 7.2; tier three the Knuckles 7.7. The tiers overlap end to
  end, as the 27 October run said in numbers; in vanilla points the mass of each tier sits a
  point and a half above the last (3, 5, 7 for tiers one to three), which is the floors the
  proposal leans to (2, 3.5, 5, 7: half a round a tier on the car).

## 28 October, the Clydesdale bench

**The warm Indirect bench** (`tools/pricing_run.py run clyde28 --parts vanilla,vanillaheat,ladders,modules
--benches clydesdale --pieces ... --modules artillery_rangefinder,ram_frame --set
modules/ram_frame/stats/hull=8 --set modules/artillery_rangefinder/stats/hull=8`, the merged
head of the 28th, before the fills): the Clydesdale's Howitzer slot in Wainwright & Sutler's row,
a nine-piece die at maximum 12 with cooling 1 whose spends run warm (the Maxigun 1, the Enfilade
Beam 2, the shells 1), the sixth bench, added for three reads the proposal's leans asked for
before the fills: the heat knee on a warm die beside the cold car's and the hot Buzzard's; the
Indirect pieces in an Indirect slot (the car read the flat Indirect as the flat Direct); and the
Artillery Rangefinder beside the Ram Frame at the hull line the pass sets (+8 each), on a
machine whose Indirect guns the Rangefinder's rule reads. The vanilla ladder as on the car
(heatless 2 to 10, the grid at 3, 5 and 7 across heat 0 to 8), twenty-three guns and the two
modules: 69 variants, 33,120 fights, about 39 minutes on four cores. A direction at 30
seeds.

**The heatless curve** in the Clydesdale's Howitzer slot (rounds off the stock row, 6.1 and 24%,
hull off it, the vanilla's share of the row's spends):

| Number | flat Indirect, Clydesdale | flat Direct, Clydesdale |
|---|---|---|
| 2 | +0.1 r, +0%, 1% | -0.0 r, -0%, 1% |
| 3 | -0.0 r, -0%, 6% | -0.1 r, -0%, 6% |
| 4 | -0.3 r, -2%, 7% | -0.3 r, -2%, 7% |
| 5 | -0.4 r, -3%, 7% | -0.4 r, -3%, 7% |
| 6 | -0.6 r, -4%, 8% | -0.6 r, -4%, 8% |
| 7 | -0.7 r, -4%, 8% | -0.7 r, -4%, 8% |
| 8 | -0.8 r, -5%, 8% | -0.8 r, -5%, 8% |
| 10 | -1.0 r, -7%, 8% | -1.0 r, -7%, 8% |

**The heat grid** (flat Direct; the flat Indirect reads the same): rounds, hull, share, the peak
heat, the overheats and the dice held a fight:

| Number | heat 0 | heat 2 | heat 4 | heat 6 | heat 8 |
|---|---|---|---|---|---|
| 3 | -0.1 r, -0%, 6%, 34%, 0.15, 0.04 | -0.0 r, -0%, 6%, 38%, 0.19, 0.05 | -0.0 r, +0%, 6%, 49%, 0.19, 0.04 | -0.1 r, +0%, 5%, 59%, 0.25, 0.06 | +0.1 r, +1%, 4%, 62%, 0.21, 0.07 |
| 5 | -0.4 r, -3%, 7%, 34%, 0.15, 0.04 | -0.4 r, -2%, 7%, 38%, 0.19, 0.05 | -0.4 r, -2%, 7%, 52%, 0.20, 0.05 | -0.3 r, -2%, 7%, 66%, 0.28, 0.06 | -0.1 r, -1%, 5%, 72%, 0.29, 0.08 |
| 7 | -0.7 r, -4%, 8%, 33%, 0.17, 0.04 | -0.7 r, -4%, 8%, 38%, 0.20, 0.04 | -0.7 r, -4%, 8%, 52%, 0.23, 0.05 | -0.6 r, -3%, 7%, 66%, 0.30, 0.05 | -0.5 r, -3%, 6%, 75%, 0.33, 0.05 |

**The pieces on the Clydesdale**, in vanilla points by this bench's own curve (coarse: the curve
spans a round from 2 to 10, so a point here is a tenth of a round):

| Tier | Piece | Its number, heat, keywords | Clydesdale: rounds, points, share, peak |
|---|---|---|---|
| 0 | Laser Carbine | 3, heat 2 | -0.0 r, 2.6 (2.6 by shape), 6%, 38% |
| 0 | Ankle Mortar | 1-3, heat 1 | +0.2 r, 2 or under (2 or under by shape), 4%, 35% |
| 0 | Twin Autoguns | 1-3, heat 0 | +0.1 r, 2 or under (2 or under by shape), 26%, 35% |
| 1 | Overclocked Railgun | 10, heat 8, breach | -1.0 r, 9.4 (9.4 by shape), 7%, 79% |
| 1 | Thermal Ray | 6, heat 6 | -0.6 r, 5.6 (5.6 by shape), 7%, 66% |
| 1 | Transonic Rifle | 5, heat 4 | -0.4 r, 4.8 (4.8 by shape), 7%, 52% |
| 1 | Maxigun | 1-2 x3, heat 1 | +0.0 r, 2 or under (2 or under by shape), 16%, 35% |
| 1 | Arc Fault Cannon | 4, heat 2, chain | -0.7 r, 6.6 (6.6 by shape), 7%, 48% |
| 1 | Enfilade Beam | 4, heat 2, penetrate 3 | -0.3 r, 4.1 (4.1 by shape), 15%, 39% |
| 1 | Howitzer | 2-5, heat 1 | +0.0 r, 2 or under (2.7 by shape), 7%, 35% |
| 1 | Slugthrower | 2-5, heat 1 | +0.0 r, 2 or under (2 or under by shape), 7%, 35% |
| 1 | Blazethrower | 3, heat 3, burn 2 | -0.4 r, 4.9 (4.9 by shape), 6%, 44% |
| 1 | Plasma Arquebus | 2-4, heat 2 | +0.0 r, 2 or under (2 or under by shape), 6%, 39% |
| 1 | Shotfire Rack | 2-4, heat 2 | +0.0 r, 2 or under (2.7 by shape), 6%, 39% |
| 1 | Incendiary Shells | 1-3, heat 1, burn 2 | -0.1 r, 3.2 (3.3 by shape), 12%, 34% |
| 1 | Airburst Shell | 1-2, heat 1, cleave 1 flak 1 | +0.1 r, 2 or under (2.0 by shape), 15%, 35% |
| 2 | Cyclic Cannon | 2 x4, heat 3 | -0.6 r, 6.2 (6.2 by shape), 8%, 44% |
| 2 | Meteor Artillery | 5, heat 6, burn 3 | -0.9 r, 8.4 (8.3 by shape), 7%, 63% |
| 2 | Tesla Gauntlets | 4, heat 3, shock | -0.5 r, 5.3 (5.3 by shape), 7%, 45% |
| 2 | Coriolis Accelerator | 3, heat 1, power_per_missing 1 per_missing 5 | -0.4 r, 4.9 (4.9 by shape), 7%, 34% |
| 2 | Flak Cannon | 3, heat 2, flak 2 | -0.5 r, 5.2 (5.2 by shape), 7%, 38% |
| 2 | Stoker | 3, heat 1, burn 2 self_burn 1 | -0.4 r, 4.9 (4.9 by shape), 6%, 37% |
| 3 | Gravity Knuckles | 5, heat 4, burn 3 | -0.9 r, 8.7 (8.7 by shape), 7%, 50% |

**The two modules at the hull line the pass sets (+8)**, fitted to the Clydesdale alone:

| Module | At hull +8 | Win | Rounds | Hull | Against stock | Peak | Overheats |
|---|---|---|---|---|---|---|---|
| Ram Frame | hull +24; Its Direct blows aimed at the front rank deal 1 more. | 96.9 | 5.7 | 19% | win +3.3, -0.4 r, -5% hull | 33% | 0.14 |
| Artillery Rangefinder | Its Indirect blows aimed at the back rank deal 1 more. | 95.0 | 6.0 | 21% | win +1.5, -0.1 r, -2% hull | 35% | 0.18 |

Read:

- **A nine-entry die dilutes its slot.** The vanilla in the Clydesdale's slot takes a tenth of
  a round off at 4 and a round at 10, with 6 to 8% of the row's spends, where the same vanilla
  in the Prairie Dog's three-entry slot took 0.9 and 2.2 with 16 to 20%: a piece's worth to its
  row is its number times how often the die lands on it, so the same gun is worth a third as
  much on a nine-entry die. The flat Indirect reads as the flat Direct here too, on the machine
  with the Indirect guns.
- **Heat never bites on the nine-entry die.** At 5 and 7 the slot's heat 8 takes 0.2 rounds back
  and lifts the peak to 72 to 75%, with no overheat; the knee the car reached at heat 6 (its
  peak 79 to 90%) is never reached here, since the slot fires a ninth of the spends. So heat's
  price scales with how often the piece fires: the die's size is a lever beside the maxima and
  the cooling, and a hot gun on a big die is a cool one.
- **The order holds.** The Railgun 9.4, the Knuckles 8.7, the Meteor 8.4, the Arc Fault 6.6,
  the Cyclic 6.2, the Thermal Ray 5.6, the Tesla 5.3, the Flak Cannon 5.2, the Blazethrower,
  the Stoker and the Coriolis 4.9, the Transonic 4.8, the Enfilade 4.1, the Incendiary 3.2, the
  Carbine 2.6; every rolled gun and the Maxigun at 2 or under, since a tier-one rolled gun's
  3.5 is a tenth of a round on this slot, within the direction's noise.
- **The Ram Frame at +8 is still the better mirror.** On the Clydesdale's strikes and its
  Direct guns the Frame takes 0.4 rounds and 5 points of hull off the row (its point on every
  Maxigun strike at the front); the Rangefinder at +8 takes 0.1 and 2, its back-rank rule
  reading on the one back-rank foe type each tier-one formation fields (two or three foes) and
  on a greedy that aims Indirect at the kill, not at the rank. Both land at +8, the module its
  text, and the Rangefinder is read again on the ladder's tier cells, where tier three's
  formations field three back-rank types.

## 28 October, the pricing pass's fills at 200 seeds

**The landed deltas read again** (`tools/pricing_run.py run land200car --seeds 200 --parts ladders
--benches prairie_dog --pieces ...` and `run land200clyde --seeds 200 --parts modules --benches
clydesdale --modules ram_frame,artillery_rangefinder`, the content as the fills left it; the
pricing row's rule that a delta a number lands on is read again at 200 seeds): the six moved
pieces in the Prairie Dog's slot of Wainwright & Sutler's row, and the two modules at +8 on the
Clydesdale in the same row, against that row as stocked after the fills, which carries the
Howitzer at 2-6 with Splash 1 in the Clydesdale's stock. The sixteen big fights but the finale,
greedy, 200 seeds a cell: 16 variants, about 53 minutes on four cores. A band, not a
direction: a row mean at 200 seeds carries about a point and a half of win rate and a twentieth
of a round.

The row as stocked after the fills, beside its 30-seed read before them: 5.8 rounds and 21% hull
(94.8% won) against 6.1 and 24% (93.5%), the Howitzer's Splash 1 in the Clydesdale's stock a
third of a round off the row by itself.

| Piece | Before, 30 seeds (its number; rounds off stock, hull, share) | After, 200 seeds (its number; rounds off stock, hull, share, peak, overheats) |
|---|---|---|
| Overclocked Railgun | 10, heat 8, Breach; -2.0 r, -11%, 16% | 8, heat 8, Breach; -1.5 r, -8%, 15%, 104%, 0.58 (hot) |
| Coriolis Accelerator | 3, heat 1, a point a missing five; -1.0 r, -5%, 16% | 4; -1.1 r, -5%, 17%, 31%, 0.10 |
| Howitzer | 2-5, heat 1, plain; -0.5 r, -4%, 24% (Splash 1 as a what-if -0.9) | 2-6, Splash 1; -0.8 r, -4%, 26%, 32%, 0.07 |
| Slugthrower | 2-5, heat 1; -0.6 r, -3%, 17% | 2-6; -0.6 r, -3%, 17%, 33%, 0.13 |
| Plasma Arquebus | 2-4, heat 2; -0.4 r, -2%, 16% | 2-6; -0.6 r, -3%, 17%, 37%, 0.13 |
| Shotfire Rack | 2-4, heat 2; -0.4 r, -3%, 17% (the 27th) | 2-6; -0.6 r, -3%, 17%, 37%, 0.11 |

The two modules at +8, fitted to the Clydesdale alone, against the same row, beside their 30-seed
read on the Clydesdale bench before the fills:

| Module | Before, 30 seeds (rounds off stock, hull, win) | After, 200 seeds (rounds off stock, hull, win) |
|---|---|---|
| Ram Frame, hull +8, a point on its Direct blows at the front | -0.4 r, -5%, +3.3 | -0.3 r, -3%, +2.1 |
| Artillery Rangefinder, hull +8, a point on its Indirect blows at the back | -0.1 r, -2%, +1.5 | -0.0 r, -2%, +1.0 |

Read:

- **The Railgun at 8 sits where tier one's top should.** 1.5 rounds off the row against 2.0 at
  10, still hot (the peak 104%, 0.58 overheats a fight), now under the Gravity Knuckles (1.9)
  and the Meteor Artillery (1.8) and above the Thermal Ray (1.3) and the Transonic Rifle (1.2),
  the two hot flat guns of its own tier: about 7 vanilla points on the ladder's curve, tier
  three's floor rather than a point past it.
- **The Coriolis at 4 reaches tier two's floor.** 1.1 rounds off, beside the Flak Cannon (1.2)
  and the Stoker (1.3), where its 3 read 1.0 and sat under the Transonic; the lift bought a
  twentieth of a round at 200 seeds, the 30-seed read of its 3 having been a tenth generous.
- **The rolled vanillas' lift is the half point it was meant to be.** At 2-6 the Slugthrower,
  the Arquebus and the Shotfire Rack read 0.6 rounds off alike (0.4 to 0.6 before), a tenth
  above the tier-zero Carbine's 0.6 on the old row and level with the Maxigun; a rolled gun
  still reads a third of a point under its mean (4 reads about 3.6), as the ladder said.
- **The Howitzer with Splash 1 at 2-6 reads 0.8 rounds off**, a tier-one shell at tier two's kill
  time (the Flak Cannon's 1.2, the Tesla's 1.4 above it; the Enfilade's 1.0 beside it), as the
  what-if of the 28th said at 0.9 on the old row: the chip Ryan named, priced.
- **The modules at +8 are their text.** The Ram Frame takes a third of a round and three points
  of hull off the row on the Clydesdale's strikes, a tier-two module's worth and no longer the
  universal pick (+24 took 0.8 rounds and 7 to 9 points off the car on the 27th); the
  Rangefinder at the same line takes nothing off the rounds and two points of hull on tier
  one's formations, with their one back-rank foe type each, so there it is the hull it carries;
  tier three's formations field three, the ladder's tier cells its next read. The pair's read on
  a Direct kit against an Indirect one is the catalogue line's.

## 28 October, the Indirect bench on the ladder's tier cells

**The Rangefinder and the Indirect pieces on the tiered formations** (`tools/pricing_run.py run
tiers28 --parts ladders,modules --benches clydesdale --pieces ... --modules
artillery_rangefinder,ram_frame --packs tiers`, the merged head with the ladder and the pass's
fills; the driver reads the spawn lists by tier since this run): the Clydesdale's Howitzer slot
in Wainwright & Sutler's row against the eight tiered formations alone (the Meadow's, the
Waste's, the Marsh's and the Peak's at tier two and at tier three), where the back rank is a
tier's weight: tier one's formations field one back-rank foe type each, tier two's one, tier
three's three (the Goblin Captain, the Mandrake and the Alraune in the Meadow; the Basilisk and
the Gorgon; the Lich, the Spectre and the Wraith; the Wyvern and the Red Dragon). Ten guns and
the two modules at +8, greedy at 30 seeds: 16 variants, 3,840 fights, 15 minutes. A
direction, and Ryan's correction of the evening: the fresh start is complete and has its ranks,
so the Rangefinder's read waits on nothing but the cells it is read on.

The four team rows as stocked on the eight tiered formations (the win rate, the rounds of the
fights won, the hull lost, the peak heat, the overheats and the dice held a fight):

| Row | Win | Rounds | Hull | Peak | Over | Held | Spends |
|---|---|---|---|---|---|---|---|
| the default team | 68.3 | 6.9 | 52% | 115% | 1.17 | 0.71 | Bullion Fragmenter 13%, Pinion Driver 13%, Chainsaw Claw 13%, Transonic Rifle 8%, Howitzer 8%, Bleed Valve 8% |
| Minerva Heavy Works team | 68.3 | 9.9 | 63% | 59% | 1.09 | 0.16 | Slugthrower 13%, Canopy 13%, Bullion Fragmenter 12%, Chainsaw Claw 12%, Rivet Gun 11%, Twin Autoguns 10% |
| Kestrel Dynamics team | 58.3 | 6.1 | 64% | 128% | 1.61 | 0.66 | Transonic Rifle 18%, Pinion Driver 15%, Bleed Valve 10%, Laser Carbine 10%, Twin Autoguns 9%, Overclocked Railgun 8% |
| Wainwright & Sutler team | 28.8 | 9.5 | 90% | 48% | 0.60 | 0.20 | Twin Autoguns 18%, Airburst Shell 13%, Halo Shield 12%, Megataser Harpoon 9%, Flakshot Repeater 8%, Howitzer 8% |

The Clydesdale's Howitzer slot on the tiered formations, each candidate against the row as
stocked:

| Tier | Candidate | Kind | Win | Rounds | Hull | Delta | Share | Peak | Over | Held | Flags |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Overclocked Railgun | direct 8, heat 8, breach | 30.0 | 9.0 | 88% | win +1.2, -0.5 r, -2% hull | 6% | 95% | 1.03 | 0.20 | hot |
| 1 | Thermal Ray | direct 6, heat 6 | 27.9 | 9.3 | 89% | win -0.8, -0.2 r, -1% hull | 7% | 84% | 0.80 | 0.25 |  |
| 1 | Enfilade Beam | direct 4, heat 2, penetrate 3 | 25.4 | 9.3 | 91% | win -3.3, -0.2 r, +1% hull | 16% | 54% | 0.59 | 0.19 |  |
| 1 | Howitzer (stock) | indirect 2-6, heat 1, splash 1 | 28.8 | 9.5 | 90% | +0.0 r, +0% hull | 8% | 48% | 0.60 | 0.20 |  |
| 1 | Shotfire Rack | indirect 2-6, heat 2 | 23.3 | 9.7 | 92% | win -5.4, +0.3 r, +2% hull | 7% | 52% | 0.57 | 0.19 |  |
| 1 | Maxigun | direct 1-2 x3, heat 1 | 21.7 | 9.8 | 92% | win -7.1, +0.4 r, +2% hull | 15% | 47% | 0.54 | 0.20 |  |
| 1 | Transonic Rifle | direct 5, heat 4 | 24.6 | 10.7 | 91% | win -4.2, +1.2 r, +1% hull | 7% | 69% | 0.67 | 0.23 |  |
| 1 | Airburst Shell | indirect 1-2, heat 1, cleave 1 flak 1 | 18.8 | 9.3 | 94% | win -10.0, -0.1 r, +3% hull | 17% | 45% | 0.49 | 0.15 |  |
| 1 | Incendiary Shells | indirect 1-3, heat 1, burn 2 | 19.2 | 9.8 | 94% | win -9.6, +0.3 r, +4% hull | 8% | 45% | 0.45 | 0.18 |  |
| 2 | Meteor Artillery | indirect 5, heat 6, burn 3 | 26.2 | 8.9 | 90% | win -2.5, -0.6 r, +0% hull | 7% | 84% | 0.90 | 0.25 | hot, under tier 1 |

The two modules at +8 on the Clydesdale alone, against the same row:

| Tier | Module | Stats and text | Win | Rounds | Hull | Delta | Peak | Over |
|---|---|---|---|---|---|---|---|---|
| 2 | Ram Frame | hull +8; Its Direct blows aimed at the front rank deal 1 more. | 33.3 | 8.8 | 85% | win +4.6, -0.7 r, -5% hull | 48% | 0.68 |
| 2 | Artillery Rangefinder | hull +8; Its Indirect blows aimed at the back rank deal 1 more. | 34.2 | 10.1 | 87% | win +5.4, +0.6 r, -3% hull | 49% | 0.78 |

Read:

- **The tiered formations are walls for the stock trios.** Wainwright & Sutler's row wins 29%
  of them in 9.5 rounds for 90% of its hull, Kestrel's 58% at 128% peak heat and 1.6 overheats
  a fight, Minerva's and the default team 68%: a tier-one kit against tier two's and tier
  three's rank and file, which the ladder's own read of the 28th said (a fight that costs a
  tier-one machine half its hull costs a tier three a third). A wall reads nothing about a
  piece: the candidates' wins move 1 to 10 points on eight cells at 30 seeds, inside the band.
- **The Rangefinder's rule needs a kit that can stand there.** On the wall the Rangefinder at
  +8 reads as its hull (3 points kept) with the row half a round slower, the greedy spending
  its Indirect guns at the back rank for the point rather than at the kill; the Ram Frame at
  +8 reads 0.7 rounds and 5 points of hull off, its point on the Clydesdale's strikes at the
  front. The pair's read by tier is the per-tier ladders' (the to-do): the tier's pieces and
  modules on the tier's fights with a tier-matched kit, the endgame fours or a tier-three
  trio, where the rows win and the rounds carry the read.
- **The small shells fall off against bigger foes.** The Airburst Shell (1-2, Cleave 1 and Flak
  1) and the Incendiary Shells (1-3, Burn 2) lose 10 points of wins against the Howitzer's
  stock on these cells, where on tier one's they read beside it: a 1 or 2 with a rider kills
  none of the ladder's rank and file, the kill-time test's arithmetic again (the area row).
  The Transonic Rifle at heat 4 on the car's die runs 1.2 rounds slower on fights this long
  (the peak 69%, 0.67 overheats), the one cell where heat 4 reads on a cold die.

## 28 October, the heat knee by the maximum

**The maxima lever, read as a what-if** (`tools/pricing_run.py run heatmax10 --parts vanillaheat
--benches prairie_dog --set chassis/prairie_dog/heat_max=10` and the same at 8; content
untouched; the merged head with the pass's fills): Ryan's question of the evening, what heat
buys and how to make it threatening but fun, and the bench's first step, the maxima before any
new rule. The vanilla heat grid of the vanilla ladder (the heatless flat Direct at 3, 5 and 7
across heat 0 to 8 in the Prairie Dog's slot of Wainwright & Sutler's row, the sixteen big
fights but the finale, greedy at 30 seeds) with the Prairie Dog's maximum at 10 and at 8
against its 12, the other machines' as they are; 34 variants a run, 18 minutes each. A
direction. The stock row reads the same at every maximum (5.9 rounds, 22% hull), since its
Twin Autoguns carry no heat.

At the maximum of 12 (the vanilla ladder's grid, for the comparison; rounds off stock, hull off
stock, share, peak, overheats, dice held):

| Number | heat 0 | heat 2 | heat 4 | heat 6 | heat 8 |
|---|---|---|---|---|---|
| 3 | -0.5 r, -3%, 14%, 34%, 0.17, 0.03 | -0.6 r, -2%, 14%, 37%, 0.19, 0.04 | -0.6 r, -2%, 13%, 60%, 0.22, 0.05 | -0.3 r, -1%, 12%, 79%, 0.29, 0.11 | -0.2 r, -1%, 9%, 82%, 0.41, 0.19 |
| 5 | -1.2 r, -7%, 18%, 32%, 0.10, 0.01 | -1.2 r, -7%, 18%, 37%, 0.12, 0.03 | -1.2 r, -6%, 18%, 67%, 0.20, 0.03 | -1.0 r, -5%, 15%, 87%, 0.30, 0.06 | -0.8 r, -3%, 12%, 95%, 0.55, 0.10 hot |
| 7 | -1.7 r, -10%, 19%, 30%, 0.08, 0.02 | -1.7 r, -9%, 19%, 35%, 0.10, 0.02 | -1.7 r, -9%, 19%, 65%, 0.18, 0.03 | -1.6 r, -8%, 17%, 90%, 0.33, 0.05 | -1.3 r, -6%, 14%, 104%, 0.61, 0.07 hot |

At 10:

| Number | heat 0 | heat 2 | heat 4 | heat 6 | heat 8 |
|---|---|---|---|---|---|
| 3 | -0.5 r, -2%, 14%, 34%, 0.15, 0.04 | -0.4 r, -2%, 14%, 40%, 0.19, 0.05 | -0.3 r, -1%, 13%, 68%, 0.23, 0.08 | -0.2 r, -1%, 11%, 84%, 0.52, 0.14 hot | -0.1 r, -0%, 8%, 86%, 0.32, 0.21 |
| 5 | -1.1 r, -7%, 18%, 31%, 0.12, 0.01 | -1.1 r, -6%, 18%, 40%, 0.16, 0.02 | -1.1 r, -6%, 17%, 75%, 0.25, 0.04 | -0.8 r, -4%, 14%, 96%, 0.68, 0.09 hot | -0.5 r, -3%, 10%, 97%, 0.37, 0.16 |
| 7 | -1.6 r, -9%, 19%, 30%, 0.09, 0.02 | -1.6 r, -9%, 19%, 39%, 0.12, 0.01 | -1.6 r, -8%, 19%, 75%, 0.23, 0.03 | -1.3 r, -7%, 16%, 99%, 0.67, 0.06 hot | -1.0 r, -5%, 12%, 104%, 0.41, 0.12 hot |

At 8:

| Number | heat 0 | heat 2 | heat 4 | heat 6 | heat 8 |
|---|---|---|---|---|---|
| 3 | -0.5 r, -2%, 14%, 34%, 0.17, 0.04 | -0.4 r, -2%, 14%, 45%, 0.20, 0.05 | -0.3 r, -1%, 13%, 78%, 0.31, 0.09 | -0.1 r, -1%, 9%, 87%, 0.43, 0.21 | +0.0 r, -0%, 7%, 99%, 0.35, 0.20 |
| 5 | -1.1 r, -7%, 18%, 32%, 0.14, 0.01 | -1.1 r, -6%, 18%, 47%, 0.18, 0.02 | -0.9 r, -5%, 16%, 86%, 0.41, 0.04 | -0.7 r, -3%, 13%, 102%, 0.57, 0.12 hot | -0.4 r, -3%, 9%, 108%, 0.40, 0.16 hot |
| 7 | -1.6 r, -9%, 19%, 30%, 0.10, 0.01 | -1.6 r, -9%, 19%, 46%, 0.14, 0.02 | -1.5 r, -8%, 18%, 87%, 0.36, 0.03 | -1.2 r, -6%, 15%, 111%, 0.64, 0.07 hot | -0.9 r, -5%, 10%, 116%, 0.45, 0.16 hot |

Read:

- **The knee moves with the maximum, a class a step.** At 12 heat 2 and 4 are free and heat 6
  takes 0.2 rounds back; at 10 heat 4 is still free in rounds (the peak 68 to 75%, the fourth
  round's overheat past most fights) and heat 6 takes 0.3 back with 0.67 overheats a fight;
  at 8 heat 4 takes 0.1 to 0.2 back (the peak 78 to 87%), heat 6 0.4 and heat 8 0.7, the
  peaks past the maximum. So the warm classes bite on a cold die only at 8, which is the Musk
  Ox's number and a third under the fleet's.
- **In vanilla points**: at 8, heat 4 costs about half a point, heat 6 a point and a half,
  heat 8 two and a half; at 10 nothing, one, and two; at 12 nothing, two thirds, and one and a
  half. The hot guns' allowance over their floor (the Transonic 1.5 at heat 4, the Thermal Ray
  2.5 at heat 6, the Railgun at 8 about 3.5 with Breach) is paid in full only at a maximum of
  8, and at 10 the Transonic's heat is still free on a cold die.
- **A global 8 is the blunt end.** Kestrel's row already peaks at 128% with 1.6 overheats a
  fight on the tiered formations at its 14; a fleet at 8 would overheat the hot kits every
  round, so the bite for the warm classes on cold dice costs the hot kits their play. The
  selective levers are the bench's next steps: a soft zone above two thirds of the maximum, the
  cooling, or the maxima by chassis (the stock pass already sets the Kite's 10 and the Musk
  Ox's 8), each a what-if the driver's `--set` can read the same way.

## 28 October, movement in hexes

The map's movement on Ryan's calls of 27 and 28 October (the bible's section 4 rows: a move is a
count of hexes, ground is ground, water the one priced hex, a move in one go, winged packs, a
hunter picking again), measured on the landing's head.

**The map survey** (`tools/map_survey.gd`, 200 seeds, `docs/map_survey.md`). The maps are the
same maps: every ground's share, the water, the horde's crossings and its route are unchanged
seed for seed, since the generator reads only the horde's rule, which is unchanged. Phases to
the rift from the best lane at move 3 (move 30 on 8 October): every way of moving 6.0, where
wheels took 3.8 (their fast open ground) and hover 5.6; the packs 8.0 at their 2, as before.
Reach after two phases at the survey's reference moves (tracked 3, walker 3, wheeled 5, hover 4,
flyer 5, the moves of 8 October in hexes): tracks 32% (31), walkers 32% (32), wheels 52% (61),
hover 44% (38), flyers 62% (62); making the horde's narrowest crossing by phase two, tracks 32
of 200 maps (30), walkers 32 (32), wheels 113 (166), hover 60 (69), flyers 115 (115). The map types at move 3 read the same
way (every phase count 6.0; reach on Badlands the lowest for the ground ways, 29/29/48/40/62,
and Flooded 33/33/55/47/62). Read: the trip north no longer reads the way of moving at all,
and reach is the move and the walls: the ground ways read alike at equal move, hover above
them by the water it crosses, the flyer above hover by the crags, which is the order the rule
sets. Wheels lose the most (their fast ground was the one large difference the table made);
hover gains rough and ruins and loses its fast water, so it reaches more of the field and makes
the crossing on a few maps fewer. A note on the method: the survey's reach is at its reference moves
because its reader of the content's moves looks for a `chassis` key the file no longer has (it
holds `entries`), so it has fallen back to those moves since before 8 October; the content's
biggest moves are walker 4 and hover 5.

**The campaign run** (`tools/campaign_run.gd`, 40 runs from seed 1, the greedy rung,
`docs/campaign_run.md`), on the merged head against main's report at c8dac4e: the same runner,
seeds and content, the movement aside. The bands hold: no run won (none), 31 of 40 reach the
finale (33), 373 battles won 7% (5%), held after a wipe 54% (50%), fell 38% (43%), 92% ending in
a team wipe (94%). One cell moved past its band: the three-machine battles, won 54% of 50 (35%
of 48). The fights inside them say why: lone fights in a three-machine battle fell from 33 to
17, fights with two of three rose from 29 to 60 and with all three from 39 to 49, since no slow
hex splits the squad as it walks onto a pack (the bot moves the squad as one onto the nearest
pack, and under the table a walker stopped in water or tracks in ruins arrived a turn behind).
Wrecks rushed 23 (31); components destroyed per battle 0.78 (0.80) and hardpoints filled at the
end 42% (39%) held. The branch's own read before the merge, against its run of 27 October,
moved the same cell the same way (54% of 50 against 36% of 57; lone fights 42 to 17, two of
three 35 to 61). A direction at 40 runs, not a band: the rule's effect on a squad moving
together, not a bug.

**The Dire Wolf's line at 4** (Ryan, the same day: it "can be faster"; the Dire Wolf, the Warg
and the Alpha Warg from 3; the heroes' dead moves dropped with it, which no run reads). The
campaign run on that head (40 runs from seed 1, the greedy rung, `docs/campaign_run.md`) against
the merged head's: no band moved. The Meadow's battles won 13% of 83 (12% of 79), fell 40%
(40%), wiped 86% (87%); the whole, won 7% (7%), held after a wipe 52% (54%), fell 40% (38%);
the three-machine battles 50% of 52 (54% of 50). A direction at 40 runs: a faster wolf moves no
cell this bot reads.

**The map survey's reader fixed** (the same day; the to-do's line, found while measuring the
landing): the reach table now reads each way's biggest move in content through ContentDB, as
its report always said (tracked 3, walker 4, wheeled 5, hover 5, flyer 5), where its own reader
of the file had looked for a key the file no longer has and fallen back, silently, to reference
moves (walker 3, hover 4) since before 8 October; a way no chassis takes now stops the survey.
Rerun at 200 seeds (`docs/map_survey.md`): the maps, the phases to the rift and the tracked,
wheeled and flyer rows are the same; walkers at 4 reach 42% of the field after two phases (32%
at 3) and make the horde's narrowest crossing by phase two on 59 of 200 maps (32); hover at 5
reaches 54% (44% at 4) and makes it on 115 (60). At equal move the order the rule sets holds:
at 5, wheels 52% and 113 maps, hover 54% and 115, flyers 62% and 115, hover's edge over the
ground the water and the flyer's the crags. The map types read alike (walker and hover reach:
Mixed 42 and 54, Steppe 46 and 58, Rubble 46 and 58, Badlands 39 and 49, Flooded 44 and 58).
Every survey read before this one gave the walkers' and the hovercraft's reach at 3 and 4.

## 29 October, Chain's read

**The conductor on the benches** (Chain built the same day: the bible's Chain row; `tools/pricing_run.py
run chain29 --parts vanilla,ladders --benches prairie_dog,goshawk --pieces arc_fault_cannon
--numbers 4,6 --shapes direct --bench-stocks --seeds 200`, then the same on the car with the Tesla
Gauntlets on the Clydesdale in the Maxigun's place, `chain29t`, a `--set` of its loadout and a
what-if only, a tier-two piece on a tier-two chassis; and with the Dingo's Megataser Harpoon given
Spread 1, `chain29s`, so one spend shocks the target and its neighbours, standing in for the spread
Shock setter Aphelion's content lacks): the Arc Fault Cannon (4, heat 2, Chain 2) in the bench
hardpoint beside flat heatless vanillas of 4 and 6 in the same slot, each against its row as
stocked, the sixteen big fights but the finale, greedy at 200 seeds: 16 variants, about 65 minutes
on four cores. Then 24 formation fights traced with the spread harpoon (the Meadow's, the Waste's,
the Marsh's and the Peak's, seeds 1 to 6), and the planner at 30 seeds, a direction, on the car and
with the spread harpoon (`chain29p`, `chain29ps`, `--policies planner`; 8 variants, 22 minutes).
The runner is deterministic: Wainwright & Sutler's row, which carries no Chain, reads exactly as
it did before Chain landed (94.8% won, 5.80 rounds, 21.2% hull), so every delta here is Chain's.

Greedy, 200 seeds (the win rate, the rounds of the fights won, the hull lost, the delta against the
row as stocked, the piece's share of the row's spends, the peak heat and the overheats a fight):

| Bench | In the slot | Win | Rounds | Hull | Against stock | Share | Peak | Overheats |
|---|---|---|---|---|---|---|---|---|
| Prairie Dog | stock (Twin Autoguns) | 94.8 | 5.80 | 21.2% |  |  | 35% | 0.14 |
| Prairie Dog | Arc Fault Cannon (4, heat 2, Chain 2) | 96.5 | 5.04 | 17.2% | -0.76 r, -4.0% hull | 16% | 36% | 0.10 |
| Prairie Dog | vanilla 4 (flat, heat 0) | 96.4 | 5.09 | 17.6% | -0.70 r, -3.6% hull | 16% | 32% | 0.09 |
| Prairie Dog | vanilla 6 (flat, heat 0) | 97.8 | 4.50 | 14.6% | -1.30 r, -6.6% hull | 18% | 31% | 0.08 |
| Buzzard | stock (Arc Fault Cannon) | 99.9 | 3.40 | 11.0% |  | 8% | 97% | 0.41 |
| Buzzard | Arc Fault Cannon (4, heat 2, Chain 2) | 99.9 | 3.40 | 11.0% | +0.00 r, +0.0% hull | 8% | 97% | 0.41 |
| Buzzard | vanilla 4 (flat, heat 0) | 99.9 | 3.40 | 10.9% | +0.00 r, -0.1% hull | 9% | 96% | 0.37 |
| Buzzard | vanilla 6 (flat, heat 0) | 99.9 | 3.35 | 10.6% | -0.05 r, -0.4% hull | 9% | 94% | 0.36 |
| Prairie Dog, with the Tesla Gauntlets on the Clydesdale | stock (Twin Autoguns) | 95.9 | 5.57 | 19.9% |  |  | 45% | 0.15 |
| Prairie Dog, with the Tesla Gauntlets on the Clydesdale | Arc Fault Cannon (4, heat 2, Chain 2) | 97.7 | 4.77 | 15.7% | -0.80 r, -4.2% hull | 16% | 43% | 0.11 |
| Prairie Dog, with the Tesla Gauntlets on the Clydesdale | vanilla 4 (flat, heat 0) | 97.7 | 4.82 | 16.0% | -0.75 r, -3.9% hull | 16% | 41% | 0.10 |
| Prairie Dog, with the Tesla Gauntlets on the Clydesdale | vanilla 6 (flat, heat 0) | 98.5 | 4.22 | 13.2% | -1.35 r, -6.7% hull | 19% | 38% | 0.08 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | stock (Twin Autoguns) | 96.5 | 5.57 | 18.9% |  |  | 34% | 0.12 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | Arc Fault Cannon (4, heat 2, Chain 2) | 98.0 | 4.78 | 14.8% | -0.79 r, -4.1% hull | 16% | 35% | 0.05 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | vanilla 4 (flat, heat 0) | 97.9 | 4.87 | 15.5% | -0.70 r, -3.4% hull | 15% | 32% | 0.07 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | vanilla 6 (flat, heat 0) | 98.8 | 4.32 | 12.7% | -1.25 r, -6.2% hull | 18% | 30% | 0.05 |

The planner, 30 seeds:

| Bench | In the slot | Win | Rounds | Hull | Against stock | Share | Peak | Overheats |
|---|---|---|---|---|---|---|---|---|
| Prairie Dog | stock (Twin Autoguns) | 95.6 | 5.22 | 17.7% |  |  | 33% | 0.11 |
| Prairie Dog | Arc Fault Cannon (4, heat 2, Chain 2) | 97.5 | 4.64 | 14.2% | -0.58 r, -3.5% hull | 16% | 35% | 0.07 |
| Prairie Dog | vanilla 4 (flat, heat 0) | 97.1 | 4.69 | 15.0% | -0.53 r, -2.7% hull | 16% | 31% | 0.08 |
| Prairie Dog | vanilla 6 (flat, heat 0) | 98.1 | 4.20 | 12.2% | -1.01 r, -5.4% hull | 18% | 30% | 0.05 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | stock (Twin Autoguns) | 97.5 | 5.08 | 16.5% |  |  | 32% | 0.09 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | Arc Fault Cannon (4, heat 2, Chain 2) | 98.5 | 4.37 | 12.7% | -0.71 r, -3.8% hull | 16% | 33% | 0.05 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | vanilla 4 (flat, heat 0) | 98.3 | 4.55 | 13.6% | -0.53 r, -2.9% hull | 16% | 30% | 0.06 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | vanilla 6 (flat, heat 0) | 99.0 | 4.04 | 10.6% | -1.04 r, -5.9% hull | 18% | 29% | 0.06 |

Read:

- **Chain 2 is a plain 4 on today's kits.** On the car the Arc Fault takes 0.76 rounds off the row
  against a vanilla 4's 0.70 and a vanilla 6's 1.30, about 0.2 vanilla points for the keyword; the
  kill and repeat read 6.7 points on the same bench on the 28th, 2.7 for the keyword. With the Tesla
  Gauntlets a second Shock setter, 0.80 against 0.75; with the harpoon shocking three foes a spend,
  0.79 against 0.70, about 0.3 points. The Arc Fault now prices at about 4.2 points, inside tier
  one's band (floor 3.5), where the kill and repeat put it at tier two's top.
- **The charges are spent before the arc fires.** In the 24 traced fights with the spread harpoon
  about 80 charges were laid and the Arc Fault arced 20 times in 98 spends: nearly every charge was
  spent first by another machine's doubled blow, since the greedy takes each spend's best trade now
  and a Shocked foe doubles any gun's blow. The decision the Chain row names (arc now, or hold the
  charges for the big gun) is one the greedy never makes.
- **The planner finds some of it, with conductors to find.** With the spread harpoon the Arc Fault
  takes 0.71 rounds off against a vanilla 4's 0.53 and a vanilla 6's 1.04, about 0.7 points for the
  keyword; with today's single harpoon 0.58 against 0.53, about 0.2 again. So the arc pays only
  where one spend leaves several charges and the team leaves them for it: Aphelion's spread setter
  and a player who sequences, which the two-round planner does in part.
- **Kestrel's row lost the kill and repeat.** The row has no Shock setter, so the Buzzard's Arc
  Fault is a plain 4 there (it reads as a vanilla 4 in its own slot): the row as stocked takes 3.40
  rounds and 11.0% hull a fight at 200 seeds against 3.1 and 9% before Chain landed (the fills'
  read of the 28th), its overheats 0.41 a fight against 0.32, still winning 99.9%.
- For Ryan (the bible's section 12): N stays content's placeholder. Claude's lean is to keep Chain 2
  until Aphelion's spread Shock setter exists and read it again then under the planner, since with
  single-target setters no N changes the picture (the arc rarely finds a charge left); a bigger N
  now would price the keyword on the one team that sequences well. The Buzzard's stock is the other
  question: it keeps a Chain gun with no Shock beside it.

## 29 October, the Chain looks

**Six forms of Chain and a Shock setter on the Buzzard, read as what-ifs** (Ryan's looks of the
29th, after Chain's read: two consumption rules, two with Shock clarified, two self-fuelling; the
code on a throwaway worktree behind one switch, never on the branch, the bot valuing each; the
runs through `tools/pricing_run.py` with `--set` and the switch in the environment). The looks, each
one change from Chain as built (a conductor's arc doubled by its charge and spending it):

- A, keep: an arc is doubled by a conductor's charge and leaves it standing; the target as ever.
- B, keep all: the Chain weapon never spends a charge, its target's included, though each still
  doubles its blow.
- C, tap: Shock clarified, for every weapon: only a targeted strike (the blow on the foe it is
  aimed at) doubles and spends a charge, so an area blow or an arc neither doubles nor spends it;
  an arc lands Chain's number plain on every other Shocked foe, and a target Shocked as the die is
  spent also takes the tap beside its doubled blow.
- D, no tap: as C, without the tap on the target.
- E, fuel after: after the arcs, a random foe on the field (alive, not the target, not already
  Shocked) is Shocked, from the skirmish's seeded stream.
- F, fuel before: the same random Shock before the arcs, so a spend arcs at least once.

Each look's Arc Fault Cannon (4, heat 2, Chain 2) in the Prairie Dog's slot of Wainwright &
Sutler's row against the row as stocked and against a flat heatless vanilla 4 in the same slot,
the keyword read in vanilla points (the gap between the vanilla's 4 and 6 the scale): on the car,
where the Dingo's harpoon shocks one foe; on the car with the harpoon at Spread 1 (three charges a
spend, standing in for Aphelion's spread setter); and that again under the planner at 30 seeds, a
direction. The sixteen big fights but the finale, greedy at 200 seeds; a look that cannot move a
row without a Chain weapon reuses the row's stock read of the 29th (the runner is deterministic),
and C and D, which change Shock for every weapon, rerun the stock and the vanilla. Then Kestrel's
row, which has no Shock setter, under E and F, and with the Polarity Projector on the Buzzard in
the Transonic Rifle's place and in the Canopy's (Ryan's question: does Shock into the Afterburner
Cannon take the build over?), greedy at 200 seeds and the planner at 30. 25 runs, about two and a
half hours on four cores.

**On the car** (greedy, 200 seeds): the row as stocked, the Arc Fault's rounds and the vanilla 4's
against it, the keyword in vanilla points, the Arc Fault's share of the row's spends and its hull
against stock:

| Look | The row as stocked, rounds | Arc Fault, rounds off stock | Vanilla 4, rounds off stock | Chain, in vanilla points | Arc Fault share | Hull off stock |
|---|---|---|---|---|---|---|
| as built (doubles and spends on every conductor) | 5.80 | -0.76 | -0.70 | +0.2 | 16% | -4.0% |
| A, keep: conductors doubled, never spent | 5.80 | -0.78 | -0.70 | +0.2 | 16% | -4.2% |
| B, keep all: the Chain weapon never spends a charge | 5.80 | -0.79 | -0.70 | +0.3 | 16% | -4.2% |
| C, tap: only a targeted strike doubles and spends; a Shocked target also takes the tap | 5.80 | -0.80 | -0.71 | +0.3 | 16% | -4.1% |
| D, no tap: as C without the tap | 5.80 | -0.77 | -0.71 | +0.2 | 16% | -4.0% |
| E, fuel after: a random foe Shocked after the arcs | 5.80 | -0.94 | -0.70 | +0.8 | 17% | -5.3% |
| F, fuel before: a random foe Shocked before the arcs | 5.80 | -1.23 | -0.70 | +1.8 | 17% | -7.2% |

**On the car, the harpoon at Spread 1** (greedy, 200 seeds):

| Look | The row as stocked, rounds | Arc Fault, rounds off stock | Vanilla 4, rounds off stock | Chain, in vanilla points | Arc Fault share | Hull off stock |
|---|---|---|---|---|---|---|
| as built (doubles and spends on every conductor) | 5.57 | -0.79 | -0.70 | +0.4 | 16% | -4.1% |
| A, keep: conductors doubled, never spent | 5.57 | -0.85 | -0.70 | +0.6 | 16% | -4.6% |
| B, keep all: the Chain weapon never spends a charge | 5.57 | -0.86 | -0.70 | +0.6 | 16% | -4.6% |
| C, tap: only a targeted strike doubles and spends; a Shocked target also takes the tap | 5.56 | -0.86 | -0.69 | +0.6 | 16% | -4.5% |
| D, no tap: as C without the tap | 5.56 | -0.81 | -0.69 | +0.5 | 16% | -4.3% |
| E, fuel after: a random foe Shocked after the arcs | 5.57 | -0.97 | -0.70 | +1.0 | 17% | -4.9% |
| F, fuel before: a random foe Shocked before the arcs | 5.57 | -1.20 | -0.70 | +1.8 | 17% | -6.3% |

**The same under the planner** (30 seeds, a direction):

| Look | The row as stocked, rounds | Arc Fault, rounds off stock | Vanilla 4, rounds off stock | Chain, in vanilla points | Arc Fault share | Hull off stock |
|---|---|---|---|---|---|---|
| as built (doubles and spends on every conductor) | 5.08 | -0.71 | -0.53 | +0.7 | 16% | -3.8% |
| A, keep: conductors doubled, never spent | 5.08 | -0.74 | -0.53 | +0.8 | 16% | -4.2% |
| B, keep all: the Chain weapon never spends a charge | 5.08 | -0.86 | -0.53 | +1.3 | 16% | -4.8% |
| C, tap: only a targeted strike doubles and spends; a Shocked target also takes the tap | 5.08 | -0.79 | -0.57 | +0.9 | 17% | -4.3% |
| D, no tap: as C without the tap | 5.08 | -0.72 | -0.57 | +0.6 | 17% | -3.9% |
| E, fuel after: a random foe Shocked after the arcs | 5.08 | -0.84 | -0.53 | +1.2 | 17% | -4.6% |
| F, fuel before: a random foe Shocked before the arcs | 5.08 | -1.03 | -0.53 | +1.9 | 18% | -5.9% |

**Kestrel's row** (the Kite, the Buzzard, the Puffin; greedy, 200 seeds), with no Shock setter: as
stocked under Chain as built and with the Arc Fault a plain 4, under E and F, and with the Polarity
Projector on the Buzzard (the Afterburner Cannon's share 5.0% as stocked, 6.0% with the Projector
in the Transonic Rifle's place, 4.9% in the Canopy's; the Projector's own 2.4% and 1.8%):

| Row | Win | Rounds | Hull | Peak | Overheats | Top spends |
|---|---|---|---|---|---|---|
| as stocked, Chain as built | 99.9 | 3.40 | 11.0% | 97% | 0.41 | Transonic Rifle 22%, Pinion Driver 17%, Twin Autoguns 13%, Laser Carbine 11%, Overclocked Railgun 10%, Arc Fault Cannon 8% |
| the Arc Fault a plain 4 (vanilla 4) | 99.9 | 3.40 | 10.9% | 96% | 0.37 | Transonic Rifle 22%, Pinion Driver 17%, Twin Autoguns 13%, Laser Carbine 11%, Overclocked Railgun 10%, Rivet Gun 9% |
| E, fuel after | 99.9 | 3.29 | 10.4% | 95% | 0.39 | Transonic Rifle 22%, Pinion Driver 17%, Twin Autoguns 13%, Laser Carbine 11%, Overclocked Railgun 10%, Arc Fault Cannon 9% |
| F, fuel before | 99.9 | 3.21 | 9.7% | 94% | 0.35 | Transonic Rifle 22%, Pinion Driver 17%, Twin Autoguns 13%, Laser Carbine 11%, Overclocked Railgun 10%, Arc Fault Cannon 9% |
| the Polarity Projector in the Transonic Rifle's place | 99.8 | 3.47 | 11.4% | 97% | 0.46 | Pinion Driver 17%, Twin Autoguns 13%, Transonic Rifle 13%, Overclocked Railgun 12%, Laser Carbine 11%, Arc Fault Cannon 11% |
| the Polarity Projector in the Canopy's place | 99.9 | 3.37 | 10.9% | 97% | 0.42 | Transonic Rifle 22%, Pinion Driver 17%, Twin Autoguns 13%, Laser Carbine 11%, Overclocked Railgun 10%, Arc Fault Cannon 7% |

The same three rows under the planner (30 seeds): as stocked 3.39 rounds and 10.3% hull, the
Afterburner 4.7% of the spends; the Projector in the Transonic Rifle's place 3.38 rounds and 10.5%,
the Afterburner 5.8%, the Projector 2.5%, the overheats 0.47 a fight against 0.37; in the Canopy's
place 3.30 rounds and 9.9%, the Afterburner 4.7%, the Projector 1.8%.

Read:

- **How a charge is spent barely matters; how many charges there are does.** The four consumption
  looks move the Arc Fault within a tenth of a vanilla point of Chain as built on the car (0.2 to
  0.3 points) and within two tenths with the spread harpoon (0.5 to 0.6 against 0.4); under the
  planner A, C and D read 0.6 to 0.9 points against 0.7. The arc is short of charges to find, not
  of charges it keeps: another machine's doubled blow spends nearly every one first (the 29
  October trace), and keeping a charge an arc touched does not put more of them on the field.
- **Keep all is the one consumption look that pays, and it is the degenerate one.** Under the
  planner B reads 1.3 points, since the Chain weapon's own target keeps its charge through every
  spend: one charge on a boss doubles every Chain spend there until an ally's blow cashes it.
- **Shock clarified costs the stock rows nothing.** With only a targeted strike doubling and
  spending a charge, Wainwright & Sutler's row reads 5.80 rounds as before (5.799 to 5.804), with
  the spread harpoon 5.57 to 5.56 and half a point of wins more: an area blow on a Shocked foe
  rarely mattered, so the clarification stands or falls on its reading, not its balance.
- **Self-fuelling is what moves Chain.** E reads 0.8 points on the car, 1.0 with the spread harpoon,
  1.2 under the planner; F 1.8, 1.8 and 1.9. In Kestrel's row, with no setter at all, E takes the
  row from 3.40 rounds to 3.29 and F to 3.21 (3.1 with the kill and repeat): the Chain gun as its
  own setter is the only form that pays on a kit with no Shock. F pays most because it guarantees
  an arc, a doubled blow on a random foe every spend, which is the ping retired on the 28th at
  twice its number; E leaves the charge for the team's next targeted strike or the next arc, a
  setup that pays later.
- **A Shock setter on the Buzzard takes nothing over.** The Projector is spent 2% of the time under
  the greedy and the planner alike, and the Afterburner Cannon stays at 5 to 6% of the row's spends;
  in the Transonic Rifle's place the row is a touch slower (3.47 rounds greedy, the overheats 0.46
  a fight against 0.41), in the Canopy's place a touch quicker (3.37; 3.30 under the planner). The
  combo Ryan named needs the Afterburner shown and hot the round after a charge lands, which these
  fights, won in three and a half rounds, rarely give: a play test's question, and the tiered
  formations' once a tier-matched Kestrel kit stands on them.

## 29 October, Chain on its form of the 29th

**Ryan's pick of the looks, built, on the benches** (the looks' D and E together, built the same
day, the bible's Chain row: Shocked read only by a weapon's strike aimed at its foe; Chain's arcs
plain, each conductor keeping its charge; then a charge on one other foe at random, neither the
target nor already Shocked). `tools/pricing_run.py run de29 --parts vanilla,ladders --benches
prairie_dog --pieces arc_fault_cannon --numbers 4,6 --shapes direct --bench-stocks --seeds 200`,
then the same with the Dingo's Megataser Harpoon at Spread 1 (`de29s`, the `--set` of the 29th's
read), and both under the planner at 30 seeds (`de29p`, `de29ps`); Kestrel's row with vanillas 4
and 6 in the Buzzard's Arc Fault slot (`de29b`) and with the Polarity Projector in the Transonic
Rifle's place and in the Canopy's (`de29bpr`, `de29bpc`, a `--set` of the Buzzard's loadout; under
the planner `de29pb`, `de29pbpr`, `de29pbpc`); then Chain 3 and Chain 4 as what-ifs (`--set
components/arc_fault_cannon/face/chain=N`: `de29n3`, `de29n4`, `de29psn3`, `de29psn4`, `de29bn3`,
`de29bn4`), a row without the Arc Fault reusing its stock read, the runner being deterministic.
The sixteen big fights but the finale; about two hours on four cores. And 96 fights traced on the
car with the Arc Fault in the Prairie Dog's slot (the sixteen, seeds 1 to 3, with and without the
spread harpoon), counting each Arc Fault spend's arcs and charges. Run on `6f4de7e`, the branch's head of the 29th: before main's move-order fix (`0a9ca80`) and the foes' fresh start (`85e28fd`), whose slate is the big bench since, so the command names fights the driver no longer lists as `big`.

Greedy, 200 seeds (the win rate, the rounds of the fights won, the hull lost, the delta against the
row as stocked, the Arc Fault's share of the row's spends, the Projector's and the Afterburner
Cannon's, the peak heat and the overheats a fight):

| Bench | In the slot | Win | Rounds | Hull | Against stock | Arc Fault | Projector | Afterburner | Peak | Overheats |
|---|---|---|---|---|---|---|---|---|---|---|
| Prairie Dog | stock (Twin Autoguns) | 94.8 | 5.80 | 21.3% |  |  |  |  | 35% | 0.14 |
| Prairie Dog | Arc Fault Cannon (4, heat 2, Chain 2) | 98.1 | 4.87 | 15.9% | -0.94 r, -5.3% hull | 17% |  |  | 36% | 0.08 |
| Prairie Dog | vanilla 4 (flat, heat 0) | 96.4 | 5.09 | 17.6% | -0.71 r, -3.6% hull | 16% (the vanilla) |  |  | 32% | 0.09 |
| Prairie Dog | vanilla 6 (flat, heat 0) | 97.8 | 4.50 | 14.6% | -1.30 r, -6.7% hull | 18% (the vanilla) |  |  | 31% | 0.08 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | stock (Twin Autoguns) | 97.0 | 5.56 | 18.8% |  |  |  |  | 33% | 0.11 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | Arc Fault Cannon (4, heat 2, Chain 2) | 98.5 | 4.61 | 14.1% | -0.95 r, -4.8% hull | 17% |  |  | 35% | 0.05 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | vanilla 4 (flat, heat 0) | 98.1 | 4.87 | 15.6% | -0.69 r, -3.3% hull | 15% (the vanilla) |  |  | 32% | 0.07 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | vanilla 6 (flat, heat 0) | 98.8 | 4.32 | 12.6% | -1.24 r, -6.2% hull | 18% (the vanilla) |  |  | 30% | 0.05 |
| Buzzard | stock (Arc Fault Cannon) | 99.9 | 3.30 | 10.5% |  | 9% |  | 5% | 95% | 0.39 |
| Buzzard | vanilla 4 (flat, heat 0) | 99.9 | 3.40 | 10.9% | +0.11 r, +0.5% hull | 9% (the vanilla) |  | 5% | 96% | 0.37 |
| Buzzard | vanilla 6 (flat, heat 0) | 99.9 | 3.35 | 10.6% | +0.05 r, +0.2% hull | 9% (the vanilla) |  | 5% | 94% | 0.36 |
| Buzzard | the Polarity Projector in the Transonic Rifle's place | 99.8 | 3.34 | 10.6% | +0.04 r, +0.2% hull | 11% | 2% | 6% | 95% | 0.44 |
| Buzzard | the Polarity Projector in the Canopy's place | 99.9 | 3.27 | 10.4% | -0.03 r, -0.1% hull | 7% | 2% | 5% | 95% | 0.39 |

The planner, 30 seeds:

| Bench | In the slot | Win | Rounds | Hull | Against stock | Arc Fault | Projector | Afterburner | Peak | Overheats |
|---|---|---|---|---|---|---|---|---|---|---|
| Prairie Dog | stock (Twin Autoguns) | 95.6 | 5.24 | 17.7% |  |  |  |  | 33% | 0.10 |
| Prairie Dog | Arc Fault Cannon (4, heat 2, Chain 2) | 99.2 | 4.49 | 13.1% | -0.75 r, -4.6% hull | 17% |  |  | 34% | 0.06 |
| Prairie Dog | vanilla 4 (flat, heat 0) | 97.5 | 4.69 | 14.7% | -0.55 r, -2.9% hull | 16% (the vanilla) |  |  | 31% | 0.08 |
| Prairie Dog | vanilla 6 (flat, heat 0) | 98.3 | 4.20 | 12.1% | -1.05 r, -5.6% hull | 18% (the vanilla) |  |  | 30% | 0.05 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | stock (Twin Autoguns) | 97.9 | 5.08 | 16.2% |  |  |  |  | 32% | 0.09 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | Arc Fault Cannon (4, heat 2, Chain 2) | 99.2 | 4.25 | 11.7% | -0.83 r, -4.5% hull | 17% |  |  | 33% | 0.03 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | vanilla 4 (flat, heat 0) | 98.5 | 4.51 | 13.1% | -0.57 r, -3.0% hull | 16% (the vanilla) |  |  | 30% | 0.07 |
| Prairie Dog, with the Dingo's harpoon at Spread 1 | vanilla 6 (flat, heat 0) | 99.0 | 4.07 | 10.7% | -1.01 r, -5.5% hull | 18% (the vanilla) |  |  | 29% | 0.05 |
| Buzzard | stock (Kestrel's row) | 100.0 | 3.24 | 9.6% |  | 9% |  | 4% | 96% | 0.36 |
| Buzzard | the Polarity Projector in the Transonic Rifle's place | 100.0 | 3.19 | 9.6% | -0.05 r, -0.0% hull | 11% | 2% | 5% | 95% | 0.43 |
| Buzzard | the Polarity Projector in the Canopy's place | 100.0 | 3.16 | 9.2% | -0.08 r, -0.4% hull | 7% | 2% | 4% | 95% | 0.35 |

**By the kind of fight** (the Arc Fault's rounds in vanilla points: 4, plus twice its rounds past
a vanilla 4's over a vanilla 6's, on the fights of each kind; the lone massive foes are the
Treant, the Sandworm, the Bone Dragon and the Magma Golem, the formations the Meadow's, the
Waste's, the Marsh's and the Peak's, the finals the eight heroes'):

| Bench | A lone massive foe | The finals | The formations | All sixteen |
|---|---|---|---|---|
| The car, greedy 200 | 4.1 | 4.8 | 6.2 | 4.8 |
| The car with the spread harpoon, greedy 200 | 4.1 | 4.8 | 7.4 | 4.9 |
| The car, the planner 30 | 4.0 | 5.0 | 6.0 | 4.8 |
| The car with the spread harpoon, the planner 30 | 4.0 | 5.1 | 8.6 | 5.2 |

The Marsh's formation, the row's wall, at 200 seeds: won 45 times as stocked, 86 with a vanilla 4, 130
with a vanilla 6 and 141 with the Arc Fault (with the spread harpoon 113, 139, 162 and 154).

**The Arc Fault's Chain number** (Chain N is each weapon's own, priced as Spread's is; the Arc
Fault, the one Chain weapon in content, at Chain 3 and 4 as what-ifs, for the worth of a point of
N):

| Bench | Chain | Win | Rounds | Hull | Off stock | In vanilla points | On the formations | Arc Fault share |
|---|---|---|---|---|---|---|---|---|
| The car, greedy 200 | 2 | 98.1 | 4.87 | 15.9% | -0.94 r, -5.3% hull | 4.8 | 6.2 | 17% |
| The car, greedy 200 | 3 | 98.2 | 4.83 | 15.7% | -0.97 r, -5.5% hull | 4.9 | 6.6 | 17% |
| The car, greedy 200 | 4 | 98.2 | 4.81 | 15.5% | -0.99 r, -5.7% hull | 4.9 | 6.8 | 17% |
| The car with the spread harpoon, the planner 30 | 2 | 99.2 | 4.25 | 11.7% | -0.83 r, -4.5% hull | 5.2 | 8.6 | 17% |
| The car with the spread harpoon, the planner 30 | 3 | 99.0 | 4.22 | 11.8% | -0.86 r, -4.4% hull | 5.3 | 9.1 | 17% |
| The car with the spread harpoon, the planner 30 | 4 | 99.0 | 4.19 | 11.7% | -0.89 r, -4.4% hull | 5.5 | 9.4 | 17% |
| Kestrel's row (the Buzzard's slot), greedy 200 | 2 | 99.9 | 3.30 | 10.5% | -0.11 r against a vanilla 4 there | | 4.79 rounds (a vanilla 4 4.95, a 6 4.91) | 9% |
| Kestrel's row (the Buzzard's slot), greedy 200 | 3 | 99.9 | 3.30 | 10.4% | -0.11 r against a vanilla 4 there | | 4.79 rounds (a vanilla 4 4.95, a 6 4.91) | 9% |
| Kestrel's row (the Buzzard's slot), greedy 200 | 4 | 99.9 | 3.29 | 10.4% | -0.11 r against a vanilla 4 there | | 4.76 rounds (a vanilla 4 4.95, a 6 4.91) | 9% |

Read:

- **The form reads as look E said.** Chain 2 is worth about 0.8 vanilla points on the car over
  the sixteen big fights (the Arc Fault 0.94 rounds off its row against a vanilla 4's 0.71 and a
  6's 1.30: about 4.8 points, inside tier one's band), 0.9 with the spread harpoon, 0.8 under the
  planner and 1.2 with the spread harpoon there; look E alone read 0.8, 1.0 and 1.2. Shock's reading
  adds nothing of its own, and the two together compound nothing.
- **Chain is a weapon for a field of foes.** On a lone massive foe the Arc Fault is a plain 4 to a
  tenth of a point (nothing to charge, nothing to arc); on the finals it reads 4.8; on the four
  formations 6.2, past a vanilla 6, and 7.4 with the spread harpoon (8.6 under the planner, a
  direction). The sixteen big fights are a measuring set, four of them formations, so their
  average undersells a Chain weapon wherever several foes stand; the ladder's formations by tier
  (`--packs tiers`) would read it there.
- **The charge carries it, not the arcs.** In the 96 traced fights the Arc Fault charged a foe on
  0.35 of its spends (0.30 with the spread harpoon; never with no other foe on the field) and arced
  on 0.06 of them (0.14), never to more than two conductors: the team's aimed strikes cash each
  charge within the round, the greedy taking a doubled blow now over an arc of 2 later, so the
  charges never pile up and nothing compounds on today's kits and bot.
- **A point of N is worth little on this form; the keyword's worth is its charge.** On the Arc
  Fault, a 4, the keyword reads about 0.75 vanilla points at Chain 2, 0.9 at 3 and 0.95 at 4 over
  the sixteen (2.2, 2.6 and 2.8 on the formations), and nothing moves in Kestrel's row (3.30, 3.30
  and 3.29 rounds): a point of N adds about a tenth of a point (a third on the formations), since
  N prices the arcs and the arcs are rare while the team cashes the charges, and the charge, which
  no N moves, is the rest (about half a point over the sixteen and one and a half on the
  formations, extrapolated to N 0). That is the price for any Chain weapon to come, read again
  when a spread setter and a player who holds charges make the arcs common; the Arc Fault keeps its
  Chain 2.
- **Shock's reading costs the stock rows nothing.** Wainwright & Sutler's row reads 5.80 rounds and
  21.3% hull against 5.80 and 21.2% before it; with the spread harpoon 5.56 against 5.57.
- **Kestrel's row gains a setter.** The Buzzard's Arc Fault charges for itself: the row takes 3.30
  rounds against 3.40 on the conductor of the 28th, the Arc Fault ahead of a vanilla 6 in its slot
  (3.35); under the planner 3.24 against 3.39.
- **The Polarity Projector on the Buzzard takes nothing over.** It is spent 2% of the time and the
  Afterburner Cannon 5 to 6%; in the Canopy's place the row is a touch quicker (3.27 rounds greedy,
  3.16 under the planner, against 3.30 and 3.24), in the Transonic Rifle's place the same within the
  noise (3.34 and 3.19, its overheats 0.44 a fight against 0.39). With the Arc Fault its own setter,
  the Buzzard's Chain gun no longer wants one beside it; whether the Shock into the Afterburner is
  wanted on it stays a play test's question (the bible's section 12).

## 29 October, the map's relief

**The relief read** (`tools/map_survey.gd`'s new relief table, 200 seeds of Mixed Ground at
9x20, `docs/map_survey.md`; the decision it informs: the bible's map-types row, the relief laid
by the shape, on Ryan's "I like the look but maybe it's a bit too much for the phone screen").
No rule reads height, so the read is what the glass shows. The field's land (water and the
gate, the wall and the rift aside) stands 47% at step 0, 31% at 1, 20% at 2 and 3% at 3; 55%
of neighbouring land pairs stand at different heights (47% to 64% a map), a quarter of those
steps two or more; 13.7 hexes a map stand alone, every land neighbour at another height (6 to
29); and a ring of 2 wholly on the field, drawn as a pack's ring is, at each hex's height, jogs
at 5.9 of its 12 joints (4.6 to 7.1 a map). A step is 7 units, which the 42-degree camera lifts
7 map pixels at zoom 1 (a hex's circumradius 48 pixels to 35 units), the width of a ring's
stroke with its dark track (6 to 7.5), so a joint one step apart jogs the outline by its whole
width and two steps clear it. Every type reads alike (steps 52% to 55%, lone hexes 13.4 to
14.2 a map, seeds 1 to 100), the relief being a noise of its own, decoupled from the ground. A
scratch read earlier the same day (seeds 1000 to 1199, a script outside the tools) counted the
gate's and the rift's level ground as land and read 47% stepping, about 13 lone hexes and 6 or
7 jogs in a ring at the field's middle; the survey's table is the measure. The shapes
session's relief is read against it.

## 29 October, the enemy's red against the heat orange

**The red read** (the decision it informs: the bible's semantic-colours row, the red lifted on
Ryan's "Red chips everywhere need to brighten up, saturate, whatever, it's hard to see on the
new backgrounds", and his ask to see its closeness to the heat orange; then his try of pure red,
"try just full ff0000 for me, please. no outlines"). Method: the Machado
(2009) protan, deutan and tritan matrices at severity 1.0 in linear sRGB, CIELAB lightness,
CIEDE2000 distance (ΔE), and the luminance contrast of a chip's red on its own black (the
chip's ground over the field, #0c110a as drawn). Normal / protan / deutan / tritan:

| | Lightness | On a chip's black | ΔE to the orange #ff6a00 |
|---|---|---|---|
| #ff1e1e (the red until 29 October) | 54 / 42 / 61 / 53 | 5.0 / 3.2 / 6.1 / 4.8 | 15.7 / 13.8 / 6.1 / 10.2 |
| #ff7c80 (the first try) | 68 / 61 / 71 / 64 | 7.7 / 6.2 / 8.6 / 6.9 | 22.2 / 19.4 / 14.0 / 7.5 |
| #ff0000 (Ryan's try, that evening) | 53 / 40 / 60 / 53 | 4.8 / 3.0 / 6.0 / 4.8 | 14.7 / 14.7 / 6.8 / 13.1 |
| #ff6a00 (the orange, for scale) | 63 / 55 / 68 / 58 | 6.7 / 5.0 / 7.7 / 5.6 | — |

A red saturates little past #ff1e1e (#ff0000 is the limit), so a brighter one leans toward orange (more green) or
toward pink (more blue). Toward orange (#ff4420, #ff5530) the worst ΔE to the orange falls to 4.0
and 3.4 (deutan); toward pink the protan and deutan distances grow but tritan's falls, its
orange being a pink-red (#ff6464 2.6, #ff7070 4.6); with green and blue raised together the
light red's tritan lightness clears the orange's. The search (red 255, green and blue in
steps of 4) kept the reds at 6:1 or more on the chip in every simulation, 14 or more from the
gain green and the green HUD and 22 or more from the ink, and took the one furthest from the
orange in its worst simulation: #ff7c80, 7.5 (tritan) where #ff1e1e was 6.1 (deutan). It costs
the gain green (deutan 20 to 14), the green HUD (19 to 15) and the ink (protan 46 to 25). Deepening
the orange to #ff6000 as well would take the worst to 9.4, the orange's own protan contrast on a
chip falling from 5.0; the orange was left as it is.

A red drawn straight on the field fails on the bright grounds whatever the hue: an arrow of
#ff1e1e stood ΔE 8.1 from the meadow's and the waste's floors in the deutan simulation, its
luminance contrast 1.04 and 1.28, and #ff7c80 4.9 and 7.7, so the skirmish's arrows took the map's
deep-red edge (#5a0e0e). The dark edge and the light core part from every floor between them, the
edge on the bright ones and the core on the dark: on each floor's shades in every simulation the
better of the two stands ΔE 22.5 or more away (the marsh, protan, the worst), and the core stands
4.9:1 on its own edge in the worst simulation. Bare, as Ryan's try has it, an arrow of #ff0000
stands 8.3 and 8.6 from the meadow's and the waste's floors (deutan), its luminance contrast 1.02 and
1.31, within half a point of the old red's.

**The rule, that evening.** Ryan: "you're moving the blues as well when I ask for brighter/darker
and so on. Reds and oranges, compose them using RG only, not B. I actually like ff6000, once we get
past the ff8200 area it starts to get confusing whether its orange or yellow/green to me. ff30,
ff40, ff50, ff60 are all very distinct to my particular blindness." So the red is #ff0000 and heat's
orange #ff6000, and with no blue a red lightens only toward the orange. Normal / protan / deutan /
tritan:

| | Lightness | On a chip's black | ΔE to the orange #ff6000 |
|---|---|---|---|
| #ff0000 (the red) | 53 / 40 / 60 / 53 | 4.8 / 3.0 / 6.0 / 4.8 | 12.1 / 12.2 / 5.6 / 12.2 |
| #ff3000 (a lighter red, for scale) | 55 / 44 / 61 / 53 | 5.2 / 3.4 / 6.3 / 4.8 | 8.9 / 8.8 / 4.1 / 7.6 |
| #ff6000 (the orange) | 61 / 53 / 66 / 56 | 6.3 / 4.6 / 7.4 / 5.3 | — |

Against #ff6a00 the red stood 6.8 in deutan, so the orange's move costs 1.2 there; the orange
stands 14.6 or more from every HUD option and the gain green in every simulation (#ff6a00, 13.6).
The map's bright, #ff8a1e, past his line, became #ff6000, and the deep reds lost their blue
(#7a1414 to #7a1400, ΔE 5.0; the map's edge #5a0e0e to #5a0e00, ΔE 3.5).

## 30 October, red and yellow lines against the grounds

**The ground read** (the decision it informs: none yet; Ryan's note that a colour fails over the
backgrounds, never between two UI elements, "since we always have an icon", and his instinct that
the enemy's lines could leave red: "plotting all routes in a friendly easy-to-use yellow is
completely sane too"). Method: as the red read of 29 October, a line's colour against each
ground's sampled shades in the Machado simulations, the worst over the shades and the
simulations; luminance contrast / ΔE2000:

| Ground | #ff0000 | #ff1000 | #ffd000 | #ffff00 |
|---|---|---|---|---|
| The meadow | 1.02 / 8.3 | 1.03 / 8.3 | 1.25 / 10.6 | 1.72 / 17.2 |
| The waste | 1.31 / 8.6 | 1.30 / 8.5 | 1.06 / 2.5 | 1.45 / 15.0 |
| The marsh | 1.05 / 11.4 | 1.07 / 11.6 | 3.11 / 35.8 | 4.27 / 38.5 |
| The peak | 1.60 / 19.8 | 1.64 / 20.3 | 6.08 / 50.3 | 8.42 / 58.7 |
| Our floor | 1.88 / 22.6 | 1.93 / 23.1 | 7.49 / 60.4 | 10.38 / 64.7 |

Pure yellow stands further from every ground than pure red, by both measures; its weakest ground
is the waste's sand, where a golden yellow (#ffd000) all but vanishes. No single colour reaches
3:1 on the meadow or the waste, the field's two bright grounds.


## 30 October, the map's lines across the zoom

**The outline and the grid at one width** (the bible's row "Nothing is one device pixel thin, and
no line grows with the zoom"; Ryan: "I don't want the outline to thicken as I zoom in"). Renders
at the phone's layout and density on the Compatibility renderer, MSAA off (the phone's), the
battle screen's opening at zoom 1 and its `zoom` pose (2.4). The engine's outline, measured as
runs of its colour across the machines in device pixels: a median of 2 at zoom 1 (most 1 to 3),
6 at 2.4; the grid's ribbons, 1.5 map pixels, were 2.25 device pixels at zoom 1 and 5.4 at 2.4.
The compositor's outline is 2 design pixels (3 device pixels) and the grid 1.5 (2.25) at both.

Its cost, from `tools/perf_probe.gd` in a cloud container (Mesa's llvmpipe on the CPU, so a
direction for the phone, never its frame time), `RIFTGATE_OUTLINE=0` against the outline: 155.5
to 158.7 ms a frame at zoom 1 (2%), 125.6 to 130.3 ms at 2.6 (4%). It looks only inside each
machine's projected box; the machines fill 18 to 20% of their boxes, and no machine pixel fell
outside one. It adds no draw call, being the compositor's; the engine's outline pass is gone from
every machine's materials (not counted against the code before it).

## 30 October, the enemy's register in violet

**The violet read** (the decision it informs: none yet; Ryan's proposal that every enemy mark
take the rift's violet, freeing red for heat at about #ff3000 to #ff4000, the shield to a cool
blue if it sits too near the violet). Method: as the red read of 29 October, the Machado
simulations at severity 1.0, CIEDE2000 (ΔE) and luminance contrast; a line read as its light
core on its deep edge, the better of the two on each shade, the worst over a ground's shades
and the simulations. The grounds: the skirmish floors of the read above, and the battle map's
own, clustered from a render at the phone's layout (its ground #57564b, #4e4f3f, #626669 and
#42484f; its green #1e321e and #304331; its water #1c3e6b; its town #cad1d8 and #a59ca5).

| Ground | Red #ff0000 on #5a0e00 | Violet #c8a4ff on #2a0e4a |
|---|---|---|
| The meadow | 3.06 / 26.1 | 3.90 / 42.6 |
| The waste | 5.22 / 43.4 | 5.85 / 51.0 |
| The marsh | 1.81 / 14.9 | 3.23 / 30.6 |
| The peak | 1.60 / 19.8 | 4.57 / 46.7 |
| Our floor | 1.88 / 22.6 | 5.79 / 51.9 |
| The map's ground | 1.77 / 17.6 | 2.83 / 31.2 |
| The map's green | 1.63 / 19.5 | 5.05 / 52.2 |
| The map's water | 1.60 / 45.5 | 4.87 / 45.8 |
| The map's town | 4.88 / 46.5 | 6.09 / 46.7 |

The violet core stands 7.9:1 on its own edge in the worst simulation, the red 2.5. On a chip's
black (#0c110a), normal / protan / deutan / tritan: the violet #c8a4ff 9.3 / 9.2 / 9.3 / 9.5, the
red 4.8 / 3.0 / 6.0 / 4.8; heat at #ff6000 6.3 / 4.6 / 7.4 / 5.3, #ff4000 5.4 / 3.7 / 6.6 / 4.8,
#ff3000 5.2 / 3.4 / 6.3 / 4.8; the shield #2f63d8 3.5 / 4.0 / 3.4 / 4.1. A redder heat moves
from the greens in the deutan simulation (ΔE to the gain green 15.8 at #ff6000, 18.4 at #ff4000,
19.3 at #ff3000) and stands 35 or more from either violet in every simulation.

The shield against the violets, the worst simulation: today's #2f63d8 stands 21.9 from the light
violet (protan) and 6.1 from the deep (deutan). A cool blue nears the light violet, which loses
its red to protan and deutan vision and reads as a light blue: #2f8fff 9.2, #1e90ff 9.1, #3aa0ff
4.8, #00a0ff 5.1, #4ab4ff 0.5 (protan each). The light violet stands 4.2 from the blue HUD
option #5cd8ff (deutan) and 37.5 or more from the green HUD and the gain green.

The picks, that evening (Ryan: "keep purple for enemy activities", heat reddened, the other reds
case by case): the enemy's violet as above; its breath toward #ecdcff, ΔE 16.7 / 15.6 / 15.6 /
12.1 from the violet (normal / protan / deutan / tritan), 12.5:1 on the deep edge, about the
swing the red had toward the orange; heat #ff4000; harm's red-red #ff0000, 2.6 from heat in the
deutan simulation (5.5 / 5.7 / 2.6 / 7.7), the steps Ryan reads as distinct, each mark with its
glyph, 20.7 or more from the gain green and 37.5 or more from the violet in every simulation.

## 30 October, the HUD's green and amber apart

**The presets read** (the decision it informs: whether the green preset moves; Ryan's "Do we
have room to push the green and amber farther apart?", the free picker set aside). Method: as
the reads above, a preset against the others and every meaning (the enemy's violet, harm's red,
heat, the shield) in the worst simulation, and against each ground's shades. Today's green
#33ff55 and amber #fff21a stand 26.5 apart in normal vision but 2.4 (protan) and 8.1 (deutan),
both a bright yellow to red-green vision. The amber cannot move: a deeper gold (#f0c81a) all but
vanishes on the waste's sand (1.01:1, ΔE 3, where today's stands 1.35 and 13), and more orange
nears heat. The green can, toward mint, against the amber in the worst simulation / against the
blue preset (tritan) / on the meadow and the waste (ΔE):

| Green | Against the amber | Against the blue | Meadow | Waste |
|---|---|---|---|---|
| #33ff55 (today) | 2.4 | 9.4 | 11 | 6 |
| #50ff90 | 9.7 | 8.4 | 10 | 4 |
| #58ffa0 | 12.3 | 8.1 | 11 | 7 |
| #60ffb0 | 15.0 | 7.8 | 13 | 10 |
| #68ffc0 | 18.0 | 7.6 | 15 | 12 |

Each stands 13 or more from every meaning and 14:1 or more on the HUD's black; the blue preset
stands 4.2 from the enemy's violet (deutan), the closest pair the three presets keep.

**The six map shapes** (Ryan's direction of 28 October and his calls of 29 October; landed the
same day). The map survey on them (`docs/map_survey.md`, 200 seeds a shape at 9x20, the detailed
report on Open Steppe, the baseline): every shape keeps the horde's crossing three wide or more
on all 200 maps, the guarantee opening half a hex a map on the river (where a bend narrows a
ford) and on the badlands, none elsewhere; the horde's route is 19 hexes on every shape (19.0 to
19.2), since on hexes a route north lengthens only where walls run across many rows, so no
shape lengthens the walk; every way of moving reaches the rift's mouth in 6 phases at move 3.
The shapes part on reach, the share of the field a way can stand on two phases out from its
best lane at its content move (walker, hover, flyer): Open Steppe 51, 62, 62%; River Crossing
49, 62, 62; Fjord 47, 62, 62; Ruined City 42, 53, 62; Badlands 38, 47, 62; Gorge 38, 47, 62.
Water opens the hover's gap over the walkers (13 points on the river, 15 on the fjord),
walls the flyer's over the rest (9 to 15 points over the hover on the city, the badlands and
the gorge, 20 to 24 over the walkers). The grounds as laid: open ground 90%, 83%, 41%, 99%, 16%
and 85% of the field (river, fjord, badlands, steppe, city, gorge), the badlands' scrub 37% and
the city's rubble 73%; water 10% on the river and 17% on the fjord; walls 17% on the badlands,
11% in the city and 15% in the gorge. The relief: neighbouring land at different heights 0% on
four shapes, 4% on the steppe (its one rise) and 16% on the badlands (the mesas' shoulders),
against 55% on the morning's noise; no lone hex but 0.6 a map on the badlands on the survey's
count, which reads the field alone where the generator's rule also reads the scenery beside the
edge. A first run an hour earlier, before the badlands were made denser (four mesa groups of two
to four where about seven of three to five stand), read their walls 8%, their walker and hover
reach 45 and 56% and their route 19.0 like every shape's; the denser badlands match the gorge
on reach and hold the narrowest crossings, about three hexes (a scratch read at 60 seeds).

The campaign run on the shapes (40 runs from seed 1, the greedy rung, `docs/campaign_run.md`; a
battle that names no shape draws one by its seed) against the run of 28 October on Mixed
Ground: no band moved. Battles won 8% of 384 (7% of 377), held after a wipe 52% (52%), fell 38%
(40%), a team wipe 90% (92%); runs reaching the finale 34 (34), cities fallen 3.95 a run (4.00);
phases a battle 7.87 (7.96); three-machine battles won 49% of 63 (50% of 52). The run before the
denser badlands read the same bands (8% of 387, 53%, 38%). A direction at 40 runs: the shapes
move nothing this bot reads, which walks the squad as one at the nearest pack.

**The horde moves as the machines do, and fords and streets three or four in all** (Ryan, 29
October; built the same day: packs wade water at two a hex, pass through each other, flyers and
the ground pass each other, nobody stops on another unit's hex). The map survey
(`docs/map_survey.md`, 200 seeds a shape at 9x20) against the six shapes' survey of the morning:
the horde's crossing stays three wide or more on every map of every shape; the guarantee opens
nothing on the river and the fjord since the horde wades (it opened half a hex a map on the
river, where a bend narrowed a ford) and 0.3 a map on the badlands where it opened 0.5, the
ponds no longer walls; the horde's route is 19 hexes on every shape (19.2 on the fjord and 19.1
on the badlands before). Reach is unchanged but in the city, its streets one to four a band
where one gap of three or two of two stood: the walkers' two-phase reach 44% where it was 42%,
the wheels' and the hover's 54% where 53%; open ground there 21% where 16%, a street paved
through every gap, and the towers 10% where 11%. A first laying let a river take four fords as
a band takes four streets, and printed seed by seed (3, 7, 12, 21, 33) the river broke into
ponds; capped at two fords it reads as it did.

The campaign run on it (40 runs from seed 1, the greedy rung, `docs/campaign_run.md`) against
the six shapes' run of the morning: no band moved. Battles won 7% of 382 (8% of 384), held
after a wipe 53% (52%), fell 39% (38%), a team wipe 92% (90%); runs reaching the finale 34
(34), cities fallen 3.92 a run (3.95); phases a battle 7.96 (7.87); fights 794 (796), those
against two packs or more 354 (365); three-machine battles won 42% of 57 (49% of 63), a band of
some twelve points at sixty battles. A direction at 40 runs: this bot walks the squad as one at
the nearest pack and never holds a line, so what wading and passing change for a player who
holds the streets is Ryan's play to read.

**Hunters at a ring of two, and the machine nearest a sealed-off prey in place of the re-pick**
(Ryan, 29 October; built the same day: every hunter's ring two at least, the Goblin Captain's
three, one number for its catch, the fights it joins and the ring drawn; a hunter keeps its prey
and goes for it by any route, and only when walls and machines seal the prey off takes the
machine nearest it that a walk that turn can put inside its ring). The campaign run on it (40
runs from seed 1, the greedy rung, `docs/campaign_run.md`) against the horde-wading run of the
same afternoon: no outcome band moved, and the fights grew. Battles won 6% of 379 (7% of 382),
held after a wipe 52% (53%), fell 40% (39%), a team wipe 93% (92%); runs reaching the finale 32
(34), the first city falling on turn 3.55 (3.77); phases a battle 7.77 (7.96). Fights 733 (794),
those against two packs or more 399 (354), 54% of them where 45% were, one machine against three
packs or more 125 (86): a hunter at two joins the fights on the packs beside it, so the fights
come fewer and bigger. Three-machine battles won 39% of 58 (42% of 57); components destroyed a
won battle 1.15 (1.61). A direction at 40 runs, on a bot that walks the squad as one at the
nearest pack and never hides a machine behind a line, so the stand-in is a case it rarely meets;
whether the pounce is overbearing is Ryan's play to read (the bible's exit).

**The domains' tilesets: their colours by the colourblind simulations** (30 October; Ryan, 29
October: "They all need their own tileset"). The painted world reaches the screen through the
map's compositor, which posterizes it to six levels a channel (`bleed.gdshader`, `levels` 5), so
the colours that count are the posterized ones: the first picks' ash plain `5a3e34` showed as
maroon `#663333` and their red-rock ruins `8c4c2c` as red `#993333`, so every tileset colour now
sits on that grid and is what the map shows. Each ground's worst CIEDE2000 over normal vision and
the Machado protan, deutan and tritan simulations at severity 1.0 (linear RGB), against the HUD
options (green `33ff55`, amber `fff21a`, blue `5cd8ff`), the enemy red `ff1e1e`, the rift's
violets (`c8a4ff`, `6a30c0`), water and the walls as shown (`3366ff`, `999966`); the bar is the
Meadow's own as shown, plain `#339933` 8.3, road `#cccc99` 7.4, rough `#336633` 5.1, ruins
`#999999` 3.5 (against the walls). The Waste: plain `#cc9933` 6.9 (lightness 73), road `#ffcc99`
6.5 (93), rough `#663300` 16.7 (32), ruins `#993300` 11.6 (44). The Marsh: plain `#336666` 11.1
(42), road `#333300` 20.0 (22), rough `#333333` 18.0 (23), ruins `#669999` 9.1 (63); olive
`#666633`, the swamp's first idea, came to 3.8 against the enemy red under the deutan
simulation, so the bog is teal-grey. The Peak: plain `#666666` 11.2 (47), road `#cccccc` 6.7
(88), rough `#333333` 18.0 (23), ruins `#663300` 16.7 (32). A lava crack's glow is `#ffcc33`,
19.6 against the red; the hot orange `e8601a` came to 1.2 under the deutan simulation at the
red's own lightness, so no orange is used. Darker grounds score higher against every mark (the
sweep's best were all under lightness 30), so the bright overworld's look, Ryan's of 20 September,
is held against the Meadow's bar rather than maximized. Against the pure red on trial on
`claude/jolly-lovelace-scn82y` (`#ff0000`) no pick moves by two points (the Waste's plain 7.6 and
ruins 9.8, the Meadow's own forest 5.1 to 6.2). The Meadow's tileset is unchanged.

**The domains' tilesets, second build: their colours by the colourblind simulations** (30
October; Ryan's read of the first: water and the walls "certainly should change with
tileset", the grounds "not wildly different"). Method as the first build's: every colour on the
compositor's posterize grid, each scored by its worst CIEDE2000 over normal vision and the
Machado protan, deutan and tritan simulations at severity 1.0, against the HUD options (green
`33ff55`, amber `fff21a`, blue `5cd8ff`), the enemy red (`ff1e1e`, and `ff0000` on trial) and the
rift's violets (`c8a4ff`, `6a30c0`), and against the ground it is drawn on (the bible's rule of
30 October). Every ground, water and wall face scores 6.5 or more against every mark, where the
Meadow's old forest floor scored 5.1. The grounds: the Meadow `#339933` 7.9 (the pure red, deutan;
lightness 56), the Waste `#cc9966` 11.3 (74), the Marsh `#333300` 18.4 (22), the Peak `#333333`
18.0 (23). The water: the Meadow's `#3366ff` 13.1 (9.0 against its ground), the Waste's oasis
`#339999` 17.8 (16.0), the Marsh's `#003333` 18.3 (12.1), the Peak's lava `#ff9900` 9.1 (52.8; 12.2
against the red). The walls' faces, lit and shaded: the Meadow's `#cc9966` 11.3 and `#663300`
15.0, the Waste's buttes `#993300` 9.8 and `#663300` 15.0, the Marsh's crags `#666666` 11.2 and
`#333333` 18.0 (4.3 against the bog, the outline and the lit faces carrying the shape), the
Peak's `#666666` and `#333333` (its flows `#ff9900`). The roads: the Meadow's `#cc9966` 11.3, the
Waste's `#ffcc99` 6.5 (amber, tritan), the Marsh's `#663300` 15.0 (3.5 against the bog, its
stepping stones `#cccccc` 63.9 carrying it), the Peak's `#666666` 11.2. What the run moved before
anything landed: the Marsh's mid greens fold into the red for a protan (`#336633` 5.1, `#006633`
5.6, `#666633` 3.8) and the darkest fold into its water (`#003300` 2.6 against `#003333`), so its
bog is `#333300`; the Meadow's water rim `#66ccff` came to 1.7 against the rift's light violet for
a deutan, so the rim is foam `#ccffff` (8.4); its trees' shade `#006600` came to 1.7 against the
red for a protan, so it is `#003300` (19.7); its mountains' shaded face and the Waste's first track,
`#996633`, came to 3.9 against the red for a protan, so the face is `#663300` and the track the pale
`#ffcc99`; an orange darker than the lava's folds into the red for a deutan (`#cc6633` 4.3,
`#cc6600` 2.6, `#cc3300` 5.3), so none is used. Small marks score lower and stay small: the fissures'
and the fire's `#ffcc00` 5.1 against the amber (deutan), the Marsh's moss `#669933` 5.7 against the
red, the oasis rim `#66cccc` 4.7 against the blue (tritan).

**The domains' tilesets: a tone a ground** (30 October; Ryan, of one ground for all four: "the
different types need different backgrounds. Its very monotone now. It just needed to be less
jarring"). Each decorative ground takes its own tone a step at most from its domain's ground in
each channel of the posterize grid, picked among those neighbours by the same simulations (worst
CIEDE2000 against every mark; then against the domain's ground): the Meadow's road verge
`#669933` 5.7 (the pure red, deutan; 1.0), its forest floor `#336633` 5.1 (the red, protan; 18.0),
its village green `#669966` 13.9 (5.4); the Waste's road `#cc9933` 6.9 (2.4), its scrub `#999966`
11.6 (2.6), its ruins' bleached ground `#ffcc99` 6.5 (13.6), where the dusty rose `#cc9999` (12.4)
read as pink on the sheet; the Marsh's dead wood floor `#003300` 19.7 (1.3) and its graveyard's
grey `#333333` 18.0 (4.3); the Peak's scorched lava field `#330000` 34.1 (15.4) and its temple's
rust `#663333` 20.4 (4.6). The Marsh's and the Peak's roads keep their domain's ground, their
mud causeway and ash path carrying them. The lowest is the Meadow's forest floor, the score the
Meadow's own forest had before the domains had tilesets.

**The domains' tilesets: the rough set apart, and the lava toward red** (30 October; Ryan:
"rough on waste and marsh can use a bit more separation from the plains colour"; the lava
"looks more like acid than lava"). The same simulations, each colour's worst CIEDE2000 against
every mark, then against its plain worst case and for normal vision. The Waste's scrub went from
`#999966` (11.6; against the sand 2.6, normal 9.0) to the olive `#669933` (5.7, the pure red under
the deutan simulation; 8.9, normal 14.8), two steps of red from the sand; the lime `#99cc33` (7.1;
8.8, 13.4) and `#99cc66` (6.9; 5.9, 13.3) read as grass on the sheet. The Marsh's dead wood went
from `#003300` (19.7; against the bog 1.3, normal 9.3) to the moss `#336633` (5.1, the red under the
protan simulation, the Meadow forest's own score; 16.2, 19.5); `#006633` (5.6) read too saturated
and black `#000000` (38.0) as a hole in the field. The lava lake went from `#ff9900` (9.1; 12.2
against the reds) to the orange-red `#ff6600`, 5.6 against the red under the deutan simulation
and 37.2 against the Peak's ground, its rim `#990000` (16.4) and its crust `#990000` and `#330000`;
a redder lake folds into the enemy red: `#ff3300` 0.8 (tritan), `#cc3300` 3.4 (protan), `#ff3333`
1.6, `#ff0000` 0.0, while the deep reds hold by their darkness, `#cc0000` 6.3 and `#990000` 16.4.

## 30 October, the heat grid with a bot that vents

**The heat brief's first read** (`docs/briefs/heat_pillar.md`, the reads to run; the cautious
persona built the same day, `Policy.cool_above`): the vanilla heat grid on the car
(`tools/pricing_run.py run heat30g --parts vanillaheat --benches prairie_dog --bench-stocks
--seeds 30`: a flat heatless gun of each reach at 3, 5 and 7 in the Prairie Dog's slot of
Wainwright & Sutler's row, each at heat 0, 2, 4, 6 and 8, against the row as stocked; the sixteen
big fights but the finale), four ways: as today (the greedy, the Prairie Dog's cooling 1), with
its cooling 0 (`--set chassis/prairie_dog/cooling=0`, `heat30g0`), and both again under the
cautious persona, each machine keeping its heat under half its maximum (`--cool-above 50`,
`heat30c`, `heat30c0`). 124 variants, about two hours on four cores; 30 seeds, a direction. Run on `28a677f`, the persona's commit: before main's move-order fix (`0a9ca80`) and the foes' fresh start (`85e28fd`), whose slate is the big bench since.

Each heat's price in vanilla points (its rounds over the heatless gun's of the same number, over
the rounds a point buys between 3 and 7), the mean of the six guns, and the heat-8 guns'
overheats, peak heat and the Coolant Jacket's share of the row's spends:

| Setting | Heat 2 | Heat 4 | Heat 6 | Heat 8 | Overheats a fight at heat 8 | Peak at heat 8 | The Coolant Jacket at heat 8 |
|---|---|---|---|---|---|---|---|
| the greedy, cooling 1 (as today) | 0.1 | 0.2 | 0.7 | 1.4 | 0.50 | 92% | 4% |
| the greedy, cooling 0 | 0.1 | 0.3 | 1.2 | 2.0 | 0.33 | 89% | 5% |
| the cautious bot, cooling 1 | 0.1 | 0.9 | 1.9 | 2.9 | 0.07 | 65% | 7% |
| the cautious bot, cooling 0 | 0.3 | 1.3 | 2.3 | 3.2 | 0.08 | 64% | 10% |

What caution costs (the win rate, the rounds of the fights won, the hull lost, the overheats):

| Setting | Gun | Win | Rounds | Hull lost | Overheats a fight |
|---|---|---|---|---|---|
| the greedy, cooling 1 | Direct 5, heat 0 | 97.9 | 4.74 | 15.6% | 0.11 |
| the greedy, cooling 1 | Direct 5, heat 4 | 97.5 | 4.79 | 16.3% | 0.22 |
| the greedy, cooling 1 | Direct 5, heat 8 | 96.7 | 5.20 | 18.9% | 0.53 |
| the greedy, cooling 1 | Direct 7, heat 8 | 97.3 | 4.72 | 16.9% | 0.60 |
| the cautious bot, cooling 1 | Direct 5, heat 0 | 97.9 | 4.76 | 15.5% | 0.05 |
| the cautious bot, cooling 1 | Direct 5, heat 4 | 96.7 | 5.09 | 17.4% | 0.07 |
| the cautious bot, cooling 1 | Direct 5, heat 8 | 96.0 | 5.75 | 19.8% | 0.09 |
| the cautious bot, cooling 1 | Direct 7, heat 8 | 96.2 | 5.21 | 18.0% | 0.09 |
| the greedy, cooling 0 | Direct 5, heat 8 | 96.0 | 5.39 | 19.4% | 0.31 |
| the cautious bot, cooling 0 | Direct 5, heat 8 | 95.8 | 5.89 | 21.1% | 0.09 |

Read:

- **Today's prices hold.** Under the greedy at cooling 1, heat 2 and 4 cost next to nothing and
  heat 6 and 8 about 0.7 and 1.4 points, the read of 28 October.
- **Caution costs more than the overheat.** The bot that keeps its heat under half its maximum all
  but never overheats (0.07 a fight at heat 8 against the greedy's 0.50) and pays for it twice
  over: heat 4 costs it nearly a point and heat 8 three, and it loses more hull, not less (the
  Direct 5 at heat 8, 5.75 rounds and 19.8% hull against the greedy's 5.20 and 18.9%, its wins
  96.0% against 96.7%). The overheat burns only the excess, hull one for one, where holding a hot
  gun or venting early costs a whole spend, so on today's rules eating the overheat is the better
  play and heat is a tempo tax a player is right to ignore. That bears on the heat brief's fifth
  question (the overheat's cost) before its first (the cooling): while the overheat is this cheap,
  playing around heat loses.
- **Cooling 0 bites, modestly, on a cold die.** With no passive cooling the greedy pays heat 4 a
  third of a point and heat 6 and 8 about half a point more (1.2 and 2.0), overheating less (0.33
  a fight) since it holds the hot gun more; the cautious bot leans on the Coolant Jacket more (10%
  of the row's spends at heat 8 against 7%). The row as stocked does not notice (5.89 rounds
  against 5.88): Wainwright & Sutler's kit is cold, so the cut bites where heat is carried, and
  the hot rows (Kestrel's at its 14, the Kite, the Stingray at 0) are its next read.
- The cautious line at half the maximum is one habit among many, and a player who vents only when
  it pays sits between the two bots: the two ends bracket heat's price, they do not set it.


## 30 October, the pacing session and the foes' fresh start

**The engine of the pacing session and the fresh start, read three ways at 40 runs** (built
30 October, `85e28fd`; the bible's pacing, clocks, stall, tears, wall, curve and Anathema rows;
the brief: `git show 85e28fd:docs/briefs/fresh_start.md`). `tools/campaign_run.gd` at 40 runs
from seed 1, the greedy rung: the plain player (`docs/campaign_run.md`), the turtle (`--turtle`:
the squad holds the two rows before the gate at its columns and fights only what comes within
reach) and the detaching player (`--detach`: one machine sent at the nearest patrol within five
hexes while the body fights the nearest formation), against the run of 29 October (the hunters
at a ring of two, the same seeds, the old spawn lists as packs and the old clock). The field at
the start is the tier's compositions by the ramp (at tier one a formation and two patrols at
density 1.0), the wall is struck from anywhere along it with the strike's floor gone, the timer
is the ramp's (12 at Convergence 0, 9 at 9), the meter's Fractures are set from the field's
menace (the last at two thirds) and the boss is sealed until the Rupture. Directions, on a bot
whose battles end in a wipe before the first peak.

| Read | Battles | Won | Held | Fell | Wiped | Finale reached | First city fell, turn | Phases a battle | Three-machine battles won | Fights | Alone (1 of 1), won | The whole squad (3 of 3), won |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 29 October, the old field and clock | 379 | 6% | 52% | 40% | 93% | 32 | 3.55 | 7.77 | 39% of 58 | 733 | 327, 18% | 55, 81% |
| 30 October, plain | 308 | 2% | 39% | 57% | 97% | 18 | 2.50 | 7.66 (3 to 16) | 16% of 48 | 575 | 279, 14% | 18, 72% |
| 30 October, the turtle | 230 | 0% | 28% | 71% | 100% | 4 | 1.27 | 11 (5 to 81) | 0% of 44 | 536 | 228, 22% | 52, 90% |
| 30 October, detaching | 291 | 0% | 41% | 57% | 99% | 11 | 2.35 | 7.85 (4 to 18) | 2% of 43 | 588 | 324, 19% | 4, 25% |

The meter and the mouths, means a battle with their ranges:

| Read | Fractures reached, of those held | Battles reaching the Rupture | By the stall guard | The seal broke, turn | Peaks | The rift sent | The tears sent | Tears open at the end | Elites | Menace killed | Gate damage |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Plain | 0.85 of 3.33 | 11% | 0% | 2.92 (1 to 5) | 0.00 (0 to 1) | 0.00 (0 to 1) | 0 | 0.00 (0 to 1) | 0.38 (0 to 2) | 25 (0 to 127) | 65 (0 to 180) |
| The turtle | 1.24 of 3.12 | 20% | 0% | 4.89 (4 to 7) | 0.15 (0 to 6) | 0.15 (0 to 6) | 0.10 (0 to 15) | 0.15 (0 to 6) | 0.52 (0 to 2) | 40 (0 to 774) | 100 (1 to 200) |
| Detaching | 0.84 of 3.28 | 9% | 0% | 2.76 (2 to 4) | 0.00 (0 to 1) | 0.00 (0 to 1) | 0 | 0.00 (0 to 1) | 0.42 (0 to 2) | 23 (0 to 127) | 69 (0 to 150) |

Read. The field at the start is the harder battle for this bot: fell 57% where 40% fell, won 2%
where 6%, the first city falling on turn 2.5 where 3.55, the three-machine battles won 16% of 48
where 39% of 58. Two changes stand behind it and the run does not part them: the wall struck
from anywhere (a pusher that reaches any of the bottom rows strikes that turn, where it had to
reach the four hexes before the gate, which the squad stood on; the gate now takes 65 a battle
on the plain player) and the compositions on the field (a lone machine against a formation with
a patrol beside it wins 2% of 139 such fights, the patrols' rings covering the formation they
flank, where the old lists came as three to five one-type packs). The matrix's composition cells
by machine attribute it (the to-do); this is a direction.

The flood is unread on the plain player: its battles last 7.7 phases against a timer of 12 at
Convergence 0 (9 at 9), so no peak comes in all but a handful (0.00 a battle, 0 to 1): the rift
sent nothing and no tear opened. What the plain read sees is the field at the start, the
Fractures and the elites. The turtle's battles run 11 phases (5 to 81) and meet the peaks: 0.15
a battle (0 to 6), the tears sending up to 15 patrols in one battle, one battle of 81 phases
killing 774 menace: the stall the design prices exists on the turtle and is rare, since the
turtle holds the two rows before the gate at its own columns and the wall is struck from
anywhere beside it: the gate took 100 a battle (1 to 200) where the plain player's took 65,
every battle a wipe, 71% fell, the first city on turn 1.27. The whole-wall rule does its work
(the apron cannot be plugged), and the turtle read gives the interval step and the bounty cap no
case yet: the step stays at zero and the cap on the bench until a persona that holds the whole
apron row, or Ryan's play, meets a stall.

The timer's 12 is the old clock's number, set when every peak sent one pack and the clock was
inert (the bible's pacing row's arithmetic). The design test (a fought battle meets one or two
tears, a stall five) wants the first peak inside a fought battle of ten turns or so, which 12 at
the start cannot give: by arithmetic, not by the bot, Claude's lean is 8 at the start to 6 at the
top (one peak and one armed tear in a ten-turn battle, two or three in a stall of twenty), for
Ryan's word (`Ramp.timer_at`, section 12's ramp item).

The Rupture came in 11% of the plain player's battles (0.85 Fractures a battle of the 3.33
held), 20% of the turtle's and 9% of the detaching player's, never by the stall guard (the field
never clears under this bot; a wipe comes first). Where it came it came early (turn 2.9 on the
plain player), in the battles whose fights the trio won, and the boss's fight after it is the
exam the proposal meant: two machines against the boss alone won 83% of 6, three 100% of 3,
three against the boss with the first Fracture's elite beside it 25% of 4, the elite that
emerged at the rift standing in the boss's ring and joining its fight. The elites: 0.38 a battle
on the plain player, 0.52 on the turtle; a lone machine against an elite's composition won 28%
of 7 (plain) and 15% of 20 (turtle), two machines 100% of 6 and 14% of 7, small cells of
different elites.

The patrols: a lone machine against a patrol wins 45% of 133 (plain), 50% of 116 (turtle) and
48% of 196 (detaching), where the brief's target is a patrol costing one machine about a tenth,
so the tier-one patrols as partitioned (three goblins, two wolves and their kin in each domain)
are a lone starter's fight on the greedy rung, as the `--pack` read of 26 October said of three
of a swarm type for a light machine; the partition is Ryan's to mark and the composition cells
read it by machine. The detaching player sent a machine 219 times: its lone fights rose to 324
(279) at 19% won (14%), and it won no battle: a detachment pays, as the design wants, and the
patrols cost more than their tenth.

Salvage by menace: a won battle banks 246 (230 to 254) at 2 a point of menace where ten a kill
banked 163 (100 to 320), on 6 won battles against 23, so the constant reads about half again high
at a won battle and is the economy pass's number (section 10); components destroyed a won battle
0.44 (1.15). On every read the plain player wins no run, as since the Armadillo's rework, and the
reads of the fights' shape stay the quick campaign's until a runner player fields a squad
(section 12).

## 30 October, the fight's backdrops on the map's palettes

**The backdrop read** (the decision it informs: the bible's skirmish field row, the fight's
palettes kept beside the map's tilesets with the map's liquid). Method: as the reads above.
The Marsh's old backdrop against the rift's violets, the worst simulation: its poison purple
#6a2e8a 7 from the deep #6a30c0, its purple specks 11, its indigo sky (#1d1a34, #2c2848) and
violet-grey roofs (#3a3240) 6 to 9 from the violet edge #2a0e4a; all gone, the sky a cold teal
night, the pools the bog's water and moss. The enemy's violet drawn bare over each lake's new
body (luminance contrast / ΔE, the worst simulation, the old lake in brackets): the plains'
#3366ff 1.88 / 17 (#3f78dc 1.83 / 16), the Waste's #339999 1.51 / 19 (#2e8cbc 1.64 / 13), the
Marsh's #003333 6.40 / 56 (#3e4e46 4.18 / 46), the Peak's crust #330000 8.67 / 62 (7.61 / 60).

## 30 October, the foes' move order

**The boss cells before and after the move-order fix** (30 October; the status's bullet:
`ContentDB.make_foe` passed over an attack already in front and moved the next, so 25 of the
65 foes loaded out of content's order). `tools/balance.gd -- --seeds 30 --packs` the thirteen
boss cells (the four bosses alone, each bench hero's final with three of its domain's first
pack, the finale), random and greedy, on main's head (`8607407`) as it stood and with the fix,
the same seeds, against every row (the 22 runnable machines alone, the team and the three
makers' trios): 676 cells, 21,060 fights a side. Won, the mean over the 26 rows:

| Fight | Random, before / after | Greedy, before / after | Cells identical, of 52 |
|---|---|---|---|
| Treant | 24.2% / 24.2% | 43.8% / 44.0% | 16 |
| Sandworm | 12.6% / 13.2% | 18.6% / 19.4% | 29 |
| Bone Wyvern | 23.5% / 23.8% | 44.5% / 44.4% | 17 |
| Magma Elemental | 10.5% / 10.5% | 15.9% / 15.9% | 52 |
| The Warrior's final (with Goblin x3) | 15.1% / 15.1% | 18.2% / 17.6% | 35 |
| The Martial Artist's final (with Goblin x3) | 12.6% / 12.7% | 16.4% / 16.3% | 40 |
| The Thief's final (with Needler x3) | 19.2% / 19.2% | 27.9% / 27.9% | 52 |
| The Lancer's final (with Needler x3) | 15.4% / 16.4% | 20.9% / 19.2% | 0 |
| The Cleric's final (with Revenant x3) | 32.1% / 32.6% | 62.6% / 60.5% | 10 |
| The Augur's final (with Revenant x3) | 28.7% / 30.9% | 59.7% / 59.7% | 0 |
| The Black Mage's final (with Salamander x3) | 14.2% / 13.8% | 16.0% / 16.0% | 41 |
| The Summoner's final (with Salamander x3) | 18.3% / 18.3% | 25.9% / 25.9% | 52 |
| The finale (the Warrior, the Thief, the Cleric, the Black Mage, promoted) | 0.0% / 0.0% | 0.0% / 0.0% | 48 |

Read. The direction of the boss cells holds: no fight's mean moves more than 2.2 points on
either rung, inside the band of a mean over the rows at 30 seeds (about 4), and the thirteen
pooled read 17.4% won to 17.8% on the random rung and 28.5% to 28.2% on the greedy. The fights
that field no foe the fix touched (the Magma Elemental alone, the Thief's and the Summoner's
finals) are identical fight for fight, as are 392 of the 676 cells in all, where no draw fell
differently (a Treant that never falls below half draws as it did). No stock kit carries a
Disrupt (the Differentiation Probe alone has one, and no chassis fields it), so the matrix
reads only the draw's order, which moves which seed draws a move and never a move's odds:
every delta here is seeded noise, and the pattern a Disrupt steps through, which the fix
changed for nine foes, is unread until a kit fields one. Three single cells moved past a
cell's 30-seed band of about 18 points (the Musk Ox on the Lancer's final, random, 20% to 47%;
the Musk Ox on the Cleric's final, greedy, 97% to 70%; the Whip Scorpion on the Augur's final,
random, 3% to 27%). Read again at 200 seeds a side (those two rows against those three
finals, both rungs: twelve cells, 2,400 fights a side), they move +4.5, -6.5 and +7.0, inside
a 200-seed difference's band (about 8 there); the one cell of the twelve past it (the Musk Ox
on the Augur's final, random, 70.0% to 80.5%) moves +1.5 at 1,000 seeds (72.6% to 74.1%, the
band 3.9), and the Whip Scorpion's beside it -0.1 (18.0% to 17.9%). Run on Godot 4.7.2; the
Musk Ox's 1,000 replayed on main as it took the fix (`d84ad16` merged, Godot 4.8-beta2) come out
identical fight for fight, so the read stands for that head.

## 30 October, the meanings as text on the codex's plate

**Keywords in their colour** (the decision it informs: whether a term's word wears its colour or
ink, Ryan's "Try bold in the colour first, and I'll judge"). Method: luminance contrast of each
meaning drawn as text on the codex's plate (#0c100c), in normal vision and the three Machado
simulations, the worst case read; on a raised plate (#121812) each stands a few tenths lower.

| Colour | Normal | Protan | Deutan | Tritan | Worst |
|---|---|---|---|---|---|
| ink #f2f4ee | 17.3 | 17.3 | 17.3 | 17.3 | 17.3 |
| heat #ff4000 | 5.5 | 3.7 | 6.6 | 4.9 | 3.7 |
| the shield's blue #2f63d8 | 3.6 | 4.1 | 3.4 | 4.1 | 3.4 |
| the enemy's violet #c8a4ff | 9.3 | 9.3 | 9.4 | 9.5 | 9.3 |
| the red-red #ff0000 | 4.8 | 3.0 | 6.0 | 4.8 | 3.0 |
| the hull's #d8d2c4 | 12.7 | 12.6 | 12.8 | 12.7 | 12.6 |
| GAIN #5cff6a | 14.6 | 15.5 | 13.8 | 14.3 | 13.8 |
| the muted grey #7b857c | 5.0 | 5.0 | 5.0 | 5.0 | 5.0 |

The three darker meanings sit under the plate's quietest text, the flavour quote's muted grey
(5.0): heat 3.7, the shield's blue 3.4 and the red-red 3.0 at their worst, where the violet, the
hull's colour and ink read freely. None can simply be lightened: a lighter blue nears the violet
for red-green vision (the reason the shield stayed dark) and a lighter heat reads green to Ryan.
Drawn as icons at the chips' size, the three clear the 3:1 a graphic wants, the red-red at it.

## 30 October, the bosses' slate

**The slate's seven read alone, at the scale row's 80 and at 48** (`tools/balance.gd`, 30 seeds,
the greedy rung, each boss alone with nothing beside it; a direction). Rows: the default team
(the Honey Badger, the Clydesdale, the Kite), the three makers' trios and a stock four of tier
ones (the Honey Badger, the Baboon, the Armadillo, the Prairie Dog). The bosses as built, at 80
(the Fallen Weapon's core 64, its eyes 12), and at 48 by `--set foes/<id>/hp` (the core 40);
Rotbloom and the Fallen Weapon read on the fixed runner (below), the eyes once more at 8. Mean
rounds of the fights won, the win rate where under 100%:

| At 80 | Rotbloom | Floraison | Gilgamesh | Fallen Weapon | Matador | Behemoth | Cinder Tortoise | The four stand-ins |
|---|---|---|---|---|---|---|---|---|
| Default team | 8.9 | 8.4 | 7.1 | 13.1 (93%) | 8.4 | 8.8 | 10.5 | 3.1 to 4.0 |
| Minerva's trio | 17.3 (73%) | 17.3 | 13.8 | 26.9 (80%) | 18.6 | 17.2 | 32.1 | 6.4 to 7.1 |
| Kestrel's trio | 7.6 | 7.8 | 6.8 | 9.4 | 7.6 | 8.1 | 8.5 | 2.8 to 3.7 |
| Wainwright & Sutler's trio | 18.6 (20%) | 18.5 (83%) | 14.4 | 17.0 (0%) | 18.1 (97%) | 18.1 (97%) | 24.6 | 6.3 to 8.0 |
| The stock four | 13.2 (97%) | 13.4 | 11.3 | 22.1 | 13.4 | 11.6 | 19.0 | 5.1 to 5.9 |

| At 48 | Rotbloom | Floraison | Gilgamesh | Fallen Weapon, eyes 12 / 8 | Matador | Behemoth | Cinder Tortoise |
|---|---|---|---|---|---|---|---|
| Default team | 4.4 | 4.7 | 4.2 | 6.9 / 5.4 | 4.8 | 5.4 | 5.8 |
| Minerva's trio | 9.7 | 10.0 | 8.4 | 17.4 / 12.5 | 11.2 | 11.0 | 19.3 |
| Kestrel's trio | 4.2 | 4.8 | 4.2 | 5.4 / 4.6 | 4.5 | 5.5 | 5.1 |
| Wainwright & Sutler's trio | 12.4 (83%) | 10.7 | 9.0 | 17.1 (13%) / 18.4 (47%) | 10.7 | 11.3 (97%) | 14.4 |
| The stock four | 8.0 | 8.2 | 7.1 | 14.0 / 11.1 | 8.2 | 7.9 | 11.9 |

Read. The scale row's 80 to 100 for bosses (the bible's section 11), written before any boss
existed, fails the kill-time test (section 2: a boss three to five rounds for a squad of four,
with its mechanics) on today's kits: at 80 the default team takes 7 to 13 rounds against each
alone and the stock four 11 to 22, where the four stand-ins at their 32 to 40 take 3 to 4 and 5
to 6. At 48 the default team takes 4 to 7 and Kestrel's trio 4 to 5.5, the test's band, while
the stock four takes 7 to 14 and the slow trios 8 to 19, those kits' own pace (they take the
stand-ins 5 to 8). So the slate lands at 48 at tier one (60 and 72 at tiers two and three by
`ContentDB.BOSS_TIERS`), the boss in parts' core at 40 and its eyes at 8: at 12 the eyes grew
back faster than Wainwright & Sutler's trio could open the core (13% won, 94% of its hull spent),
at 8 it wins 47%, still the slate's hardest boss for a trio without burst. Alone, most of the
slate costs little hull (1 to 17% on four of the five rows): long rather than dangerous, its
threat the mechanics and, in a battle, the escort. The Cinder Tortoise is the slowest: its
shell's five armour walls the small blows, as meant, and Expose and a breach, its answers, are
in none of these stock kits. The row's 80 to 100 is Ryan's to keep or move; the 200-seed
matrix's boss cells and his play read it again.

**The balance runner fielded no split, no summon and no part until 30 October** (found reading
the Fallen Weapon, whose eyes never stood in its cell): it never set the skirmish's foe factory,
so a Gel never split there, a Ghost raised nothing, a summoner called nothing up and a core's
parts never stood (a trace of the default team against four Gels on the old runner: no half
stepped up; on the fixed one, every Gel split). Every matrix read until then, the 27 October
200-seed run among them, read those cells so. Fixed the same day: a cell fields a core's parts
and calls up splits, summons and regrown parts as a battle does. The Gel's, the summoners' and
the boss in parts' cells are read again at the next 200-seed matrix.

## 30 October, the Petrels' first rows

**Their engine session's reads** (the Storm Petrel and the Giant Petrel fielded 30 October on
`claude/affectionate-ramanujan-5d24t6`, from main's `d84ad16`), as their briefs asked: the Storm
Petrel alone and beside the Puffin, its magazine, each against the Armadillo, the other tier-one
body, in the same run; the Giant Petrel in two teams of four against the same three with another
machine in its place. `tools/balance.gd`, 30 seeds a cell (a direction), random and greedy, no
party, the matrix's 55 packs as it stands (the thirteen tier-one packs, the ladder's twenty-six
recolours, the four big foes and the twelve formations), on Godot 4.7.2 (the session's hook
installed it on the old head; the 4.8-beta2 build's unpacking and first run were refused by Auto
mode, and the headless sim reads no renderer). Won, random / greedy, then greedy's hull lost and
rounds to a win.

**The Storm Petrel alone**, beside the Armadillo:

| Row | Every pack | Tier-one rank and file (13) | Tiers two and three (26) | The four big foes | The twelve formations | Hull lost | Rounds won |
|---|---|---|---|---|---|---|---|
| Storm Petrel | 32 / 45 | 52 / 66 | 42 / 61 | 0 / 0 | 0 / 0 | 63% | 4.9 |
| Armadillo | 25 / 38 | 48 / 65 | 29 / 49 | 0 / 0 | 0 / 0 | 75% | 9.7 |

Pick share (greedy): the Laser Carbine 31%, the St. Elmo's Regenerator 24%, the Canopy 20%, the
Ankle Mortar 15%, the Twin Autoguns 9%. Its heat peaks at a tenth of its gauge (the Armadillo's
41%), 0.04 overheats a fight. The first run of the day, before the bot valued the regen, read the
row 32 / 46 with the Regenerator spent 4% of the time: valuing it moved the lock's share and not
the row.

Read: alone it stands in the Armadillo's band and above it on the ladder's recolours, winning in
half the rounds; every tier one alone is walled by the big foes and the formations, and so is it.
On its stock the burn is a trickle: the Carbine's 2 is the most any basic burns, and the gauge
never sees it, so its identity shows at the size of its basics' heat (the bible's section 12 holds
the question).

**Beside the Puffin**, the same two bodies:

| Row | Every pack | Tier-one rank and file | Tiers two and three | The four big foes | The twelve formations | Hull lost | Rounds won |
|---|---|---|---|---|---|---|---|
| Storm Petrel + Puffin | 53 / 66 | 85 / 94 | 68 / 84 | 4 / 51 | 0 / 2 | 39% | 4.5 |
| Armadillo + Puffin | 47 / 62 | 77 / 93 | 60 / 78 | 0 / 32 | 0 / 8 | 46% | 6.5 |

Pick share (greedy, the Storm Petrel's pair): the Laser Carbine 31%, the Twin Autoguns 24%, the
Regenerator 13%, the Halo Shield 10%, the Ankle Mortar 10%, the Canopy 6%, the Backwash Ionizer 3%.

Read: the escort pair reads a few points over the Armadillo's on the rank and file and about half
again on the big foes (51% against 32%, in a third the rounds), for less hull; the Armadillo's pair
takes a formation now and then where it takes almost none. Neither is a must-pick on this read; the
Puffin's overshield is rarely spent on it (the Ionizer 3%), so the brief's magazine claim is not
read here, the greedy shielding its ally against this round's blows and never for a burn to come.

**The Giant Petrel in a four**, beside the same three with the Lammergeier, Kestrel's other tier
three, in its place:

| Row | Every pack | Rank and file, tier one / two and three | The four big foes | Formations, tier one / two / three | Hull lost | Rounds won |
|---|---|---|---|---|---|---|
| Kite, Buzzard, Puffin, Giant Petrel | 88 / 98 | 100 / 100, 99 / 100 | 100 / 100 | 95 / 100, 50 / 100, 0 / 74 | 7% | 2.2 |
| Kite, Buzzard, Puffin, Lammergeier | 86 / 98 | 100 / 100, 96 / 100 | 98 / 100 | 92 / 100, 43 / 100, 0 / 73 | 7% | 2.2 |

Its four buys an ally's action 0.19 a fight under the greedy and banks 0.94 rerolls a round; the
Booster is 3% of the team's spends, the Salvo 9%, the Uplink 1%. The first run of the day priced
every reroll a spend paid or brought as a look and bought 0.01 actions a fight, the greedy rerolling
only as a round opens, so a reroll mid-round is worth only what the bank carries (`Policy.bank_delta`):
read again on that, the outcome cells moved by a point at most and the actions rose from 0.01 to 0.19.

Read: the formation leader's four reads level with the bomber's under the greedy everywhere (tier
three's formations 74% against 73%), random play a few points higher with it on tier two's (50%
against 43%). Its fights are short (2.2 rounds), so the bank and the bought action have little
room; the must-pick guard reads no must-pick on this team.

**The Giant Petrel in another four**, Wainwright & Sutler's three with the Swallowtail, the other
action-economy capstone, in its place:

| Row | Every pack | Rank and file, tier one / two and three | The four big foes | Formations, tier one / two / three | Hull lost | Rounds won |
|---|---|---|---|---|---|---|
| Cassowary, Clydesdale, Dingo, Giant Petrel | 87 / 95 | 100 / 100, 98 / 100 | 100 / 100 | 90 / 100, 41 / 100, 0 / 38 | 11% | 2.8 |
| Cassowary, Clydesdale, Dingo, Swallowtail | 83 / 93 | 99 / 100, 94 / 99 | 99 / 100 | 78 / 99, 28 / 93, 0 / 21 | 13% | 3.2 |

Its four buys an ally's action 0.24 a fight and banks 1.21 rerolls a round; the Salvo is 8% of the
team's spends, the Overclocked Railgun 9%, the Booster 3%, the Uplink 1%.

Read: here the Giant Petrel's four reads over the Swallowtail's on every formation, most on tier
three's (38% against 21% under the greedy) and on tier two's under random play (41% against 28%), in
fewer rounds. The bought actions are a fifth of a fight, so most of that is its own guns beside a
support capstone's kit; the must-pick guard to watch is this team's, read again at 200 seeds with
the matrix (the to-do), the levers the Booster's price, the bank's cap and the Salvo's two.

## 30 October, the overheat's price as what-ifs

**A harsher burn, burnout and self-Corrupted** (Ryan, 30 October: "let's try a more severe
overheat penalty just to see what happens", then his calls on the forms, the heat brief's
section on the overheat's penalties): test-only settings of the balance runner, off as the
engine runs (`--overheat N`, an overheat burning N hull a point past the maximum; `--burnout`,
an overheat whose burn reaches the injury threshold burning out the component whose spend took
the gauge over; `--overheat-corrupt N`, every overheat Corrupting that component N stacks), the
bot pricing each. Two benches: the car's vanilla heat grid (`tools/pricing_run.py run oh2g
--parts vanillaheat --benches prairie_dog --bench-stocks --shapes direct --seeds 30 --overheat
2`, Direct guns at 3, 5 and 7 and heat 0 to 8 in the Prairie Dog's slot of Wainwright &
Sutler's row) and Kestrel's row as stocked, the hot row (`--parts none --benches goshawk
--bench-stocks`), each under the greedy and the cautious persona (`--cool-above 50`), whose
line is priced at what an overheat burns. The sixteen big fights but the finale; 30 seeds, a
direction; about two and a half hours on four cores. Run on `e964de5`, the switch's commit: before main's move-order fix (`0a9ca80`) and the foes' fresh start (`85e28fd`), whose slate is the big bench since.

On the car (each heat's price in vanilla points, the mean of the three guns, as the heat grid of
the morning reads it; the heat-8 guns' overheats, hull lost, rounds and wins; the row as stocked):

| Setting | Heat 2 | Heat 4 | Heat 6 | Heat 8 | Overheats at 8 | Hull lost at 8 | Rounds at 8 | Win at 8 | The row as stocked: rounds, hull, overheats |
|---|---|---|---|---|---|---|---|---|---|
| the greedy, one for one (as today) | 0.1 | 0.2 | 0.8 | 1.4 | 0.51 | 19.1% | 5.22 | 96.6 | 5.88, 22.2%, 0.18 |
| the cautious bot, one for one | 0.1 | 1.0 | 1.9 | 2.8 | 0.08 | 19.9% | 5.70 | 95.9 | 5.98, 22.7%, 0.11 |
| the greedy, two a point | 0.1 | 0.3 | 0.9 | 1.9 | 0.23 | 19.5% | 5.36 | 95.8 | 5.91, 23.0%, 0.11 |
| the cautious bot, two a point | 0.1 | 1.1 | 2.1 | 3.9 | 0.02 | 22.6% | 6.06 | 94.1 | 6.02, 23.7%, 0.02 |
| the greedy, three a point | 0.1 | 0.4 | 1.0 | 2.1 | 0.14 | 19.5% | 5.42 | 95.8 | 5.90, 23.2%, 0.09 |
| the cautious bot, three a point | 0.1 | 1.5 | 2.5 | 4.9 | 0.02 | 24.1% | 6.32 | 93.4 | 6.01, 24.1%, 0.02 |
| the greedy, two a point and burnout | 0.1 | 0.3 | 1.0 | 1.9 | 0.21 | 19.4% | 5.37 | 95.8 | 5.90, 23.0%, 0.11 |
| the cautious bot, two a point and burnout | 0.1 | 1.1 | 2.2 | 3.9 | 0.02 | 22.6% | 6.06 | 94.1 | 6.02, 23.7%, 0.02 |
| the greedy, one for one and Corrupted | 0.1 | 0.3 | 0.9 | 1.8 | 0.30 | 18.8% | 5.33 | 96.7 | 5.90, 22.4%, 0.15 |
| the cautious bot, one for one and Corrupted | 0.1 | 1.0 | 2.0 | 2.9 | 0.06 | 20.2% | 5.73 | 95.8 | 6.03, 22.9%, 0.07 |

Kestrel's row as stocked (its Buzzard's Arc Fault and Afterburner Cannon, the Kite's flat heat
on every shot):

| Kestrel's row as stocked | Win | Rounds | Hull lost | Overheats a fight | Peak | Components destroyed a fight |
|---|---|---|---|---|---|---|
| the greedy, one for one | 100.0 | 3.28 | 9.8% | 0.34 | 94% | 0.46 |
| the greedy, two a point | 100.0 | 3.35 | 9.8% | 0.21 | 88% | 0.47 |
| the greedy, two a point and burnout | 100.0 | 3.39 | 9.9% | 0.20 | 86% | 0.50 |
| the greedy, one for one and Corrupted | 100.0 | 3.31 | 9.7% | 0.31 | 92% | 0.46 |
| the cautious bot, one for one | 100.0 | 3.53 | 10.1% | 0.10 | 79% | 0.52 |
| the cautious bot, two a point | 99.8 | 3.77 | 11.2% | 0.02 | 68% | 0.59 |
| the cautious bot, two a point and burnout | 99.8 | 3.78 | 11.2% | 0.01 | 68% | 0.59 |
| the cautious bot, one for one and Corrupted | 100.0 | 3.56 | 10.2% | 0.07 | 77% | 0.53 |

Read:

- **Every penalty does the same thing to play: the bot rides to the maximum and holds there.**
  At two a point the greedy overheats half as often on the car's hot guns (0.23 a fight at heat
  8 against 0.51) and in Kestrel's row (0.21 against 0.34), and holds the hot die instead, so
  heat costs tempo rather than hull: heat 8 from 1.4 vanilla points to 1.9 (2.1 at three a point),
  heat 6 from 0.8 to 0.9 or 1.0, while heat 2 and 4 stay all but free on a cold die. Kestrel's row
  pays a tenth of a round at most (3.35 rounds against 3.28) and wins as it did.
- **Caution never pays, under any penalty.** The cautious bot, whose line is priced at what an
  overheat burns, grows more cautious as the burn grows and loses more each step (on the car at
  heat 8, 5.70, 6.06 and 6.32 rounds and 19.9%, 22.6% and 24.1% hull against the greedy's 5.22,
  5.36 and 5.42 and about 19.5%; Kestrel's row 3.53 and 3.77 rounds against 3.28 and 3.35). The
  play the penalties reward is holding at the edge, not venting early.
- **Burnout adds nothing over two a point.** The bot prices the lost component and stays clear of
  the threshold (the overheats 0.21 against 0.23 on the car, 0.20 against 0.21 in Kestrel's row,
  its components destroyed a fight 0.50 against 0.47), so its weight is a threat the forecast must
  show, never a cost the runs see.
- **Corrupted at one for one deters as a burn of two does,** for less hull: heat 8 at 1.8 points,
  the overheats 0.30 a fight, the hull lost 18.8% against the greedy's 19.1% as today, and
  Kestrel's row 3.31 rounds; the softer form lands where the harsher burn lands.
- So the form is a question of feel and readability, Ryan's play, more than of balance: each
  makes the maximum a wall the player plans around, which is the meeting with the system his
  frame asks for, and none makes the warm classes bite on a cold die, which stays the maxima's
  and the cooling's.

## 30 October, the support ladders

**Every slottable shield, vent and buff in one slot** (the pricing row's next step, the equipment
ramp Ryan wants first: "especially to shield and vent"; `tools/pricing_run.py run sup30 --parts
ladders --benches puffin --pieces <the seventeen> --bench-stocks --seeds 30`): the seventeen
pieces of tiers 0 to 2 in the Puffin's slot of Kestrel's row (the Laser Carbine's, the bench
where equipment reads), each against the row as stocked, with today's bots and again with the
personas that value support (`--shield-ahead --cool-above 50`, `sup30p`). The sixteen big fights
but the finale; 30 seeds, a direction; 36 variants, about sixteen minutes on four cores. Run on `a6884b3`, the persona's commit: before main's move-order fix (`0a9ca80`) and the foes' fresh start (`85e28fd`), whose slate is the big bench since, the four formations with it.

The row as stocked: 100% won, 3.28 rounds and 9.8% hull today; 3.59 and 10.0% with the personas.
Each piece's rounds and hull against the row with the gun in its slot, and its share of the
row's spends:

| Piece | Tier | What it is | Today: rounds and hull off the gun | Its share | With the personas: rounds and hull off the gun | Its share |
|---|---|---|---|---|---|---|
| Blast Door | 1 | buff  | +0.27 r, -1.7% | 9% | +0.24 r, -2.3% | 7% |
| Decoherence Veil | 1 | buff  | +0.24 r, -0.7% | 6% | +0.19 r, -1.0% | 5% |
| Overcharge Coil | 1 | buff  | +0.24 r, +2.5% | 8% | +0.25 r, +2.3% | 5% |
| Retribution Thurible | 1 | buff  | +0.19 r, +2.0% | 4% | +0.16 r, +2.0% | 3% |
| Shoring Jack | 1 | buff  | +0.31 r, +2.3% | 4% | +0.27 r, +2.5% | 3% |
| Aurora Lattice | 2 | buff  | +0.26 r, +2.8% | 3% | +0.24 r, +2.8% | 2% |
| Canopy | 0 | shield 8 | +0.29 r, +2.1% | 4% | +0.27 r, +2.0% | 4% |
| Halo Shield | 0 | shield 6 | +0.28 r, +2.1% | 8% | +0.24 r, +2.0% | 8% |
| Oblation Mantle | 1 | shield 10 | +0.28 r, +2.5% | 1% | +0.23 r, +2.7% | 1% |
| Corona Shield | 2 | shield 6, cleanse | +0.28 r, +2.1% | 4% | +0.24 r, +1.9% | 4% |
| Laminar Deflector | 2 | shield 6, rapid | +0.26 r, +1.4% | 4% | +0.24 r, +1.6% | 4% |
| Bleed Valve | 0 | vent 6 | +0.24 r, +2.6% | 8% | +0.24 r, +2.9% | 10% |
| Coolant Jacket | 0 | vent 4 | +0.25 r, +2.5% | 4% | +0.25 r, +2.6% | 4% |
| Phased Sublimator | 1 | vent 4, cleanse | +0.25 r, +2.5% | 3% | +0.26 r, +2.6% | 2% |
| Radiator Sail | 1 | vent 5 | +0.25 r, +2.4% | 2% | +0.26 r, +2.5% | 2% |
| Wake Diffuser | 1 | vent 3 | +0.26 r, +2.3% | 4% | +0.25 r, +2.6% | 4% |
| Entropy Condenser | 2 | vent 10 | +0.24 r, +2.6% | 0% | +0.25 r, +2.8% | 0% |

Read:

- **No equipment beats the gun it replaces on this bench.** Every piece costs a quarter of a round
  (+0.19 to +0.31), and all but two cost hull too (+1.4% to +2.8%): the Blast Door, whose Barrier
  takes a big blow whole, saves 1.7% hull for its quarter round (2.3% with the personas), and the
  Decoherence Veil's Ward 0.7%. Kestrel's row wins every one of these fights in about three
  rounds, so support has little to save and the gun ending the fight sooner saves more.
- **The ladder is flat by tier.** The tier-two shields read as the basics do (the Corona Shield and
  the Laminar Deflector +0.26 to +0.28 rounds beside the Canopy's and the Halo Shield's +0.28 and
  +0.29), and the tier-two capstone vent as the basic ones (the Entropy Condenser +0.24 rounds,
  never spent, beside the Coolant Jacket's +0.25). The tiers carry keywords at the basics'
  numbers (the shields 6 to 10, the vents 3 to 6 and the Condenser's 10), so the ramp Ryan asked
  for, "plain number increases beside the keywords, especially to shield and vent" (28 October),
  is not there in content.
- **The personas change no ranking.** Valuing a standing shield by next round's blows and venting
  early slow the row by a third of a round and leave every piece where it stood, so the bot was
  not hiding the support's worth: the fights are.
- So the equipment ramp is read where support has work: on harder fights (the ladder's tier-two
  and tier-three formations, which walled the stock trios on 28 October), with tier-matched kits,
  and its numbers by tier are a fills proposal for Ryan's go.

## 30 October, the slate's last five

**The last five read alone, beside two of the first seven** (`tools/balance.gd`, 30 seeds, the
greedy rung, each boss alone, its parts with it; a direction). The same rows as the first seven's
read. Mean rounds of the fights won, the win rate where under 100%, and the row's hull lost (h,
percent of the squad's):

| As built | King Gel | Pilgrim | Phantom Train | Vampire Lord (40) | Obsidian Tyrant | Rotbloom | Matador |
|---|---|---|---|---|---|---|---|
| Default team | 4.2 h1 | 4.3 h9 | 4.7 h3 | 10.2 (86%) h24 | 5.2 h2 | 4.4 h3 | 4.8 h6 |
| Minerva's trio | 8.9 h4 | 8.1 h18 | 11.3 h7 | 43.0 (3%) h49 | 9.5 h6 | 9.7 h17 | 11.2 h9 |
| Kestrel's trio | 4.1 h2 | 4.1 h11 | 4.7 h4 | 8.6 h8 | 4.8 h2 | 4.2 h4 | 4.5 h6 |
| Wainwright & Sutler's trio | 8.8 h3 | 8.2 h24 | 12.6 (96%) h21 | (0%) h74 | 10.7 h8 | 11.3 (83%) h49 | 10.7 h21 |
| The stock four | 7.0 h0 | 7.1 h8 | 8.3 h0 | 19.3 h2 | 8.4 h1 | 8.0 h6 | 8.2 h1 |

Read. The King Gel alone (no Gels to take in), the Pilgrim, the Phantom Train and the Obsidian
Tyrant sit with the first seven, the default team 4 to 5 rounds; Rotbloom and the Matador read as
they did that morning, so the stand-ins' move left them be. The Vampire Lord at 40 is a wall: its
drain and a whole second life outrun the small blows, Minerva's trio winning 3% of its fights and
Wainwright & Sutler's none. Traces (one fight each, the default team) showed every new mechanic
firing in content: the Tyrant open and counting the moment its rider fell, the King Gel taking
its Gels in, the Pilgrim's knife walking in, the Vampire Lord draining and rising once.

**The Vampire Lord's drain, nine forms against the rows** (`tools/balance.gd`, 30 seeds, the
greedy rung, alone; `--set` on the HP and on Blood Feast; a direction). The first five keep the
drain as built that morning (it regrew what a blow dealt, shield and hull); the last four take
it from the hull alone. Mean rounds of the fights won, the win rate where under 100%, and the
fights past 60 rounds (st):

| Form | Default team | Minerva's trio | Kestrel's trio | Wainwright & Sutler's trio | The stock four |
|---|---|---|---|---|---|
| Shield and hull, 40 HP | 10.2 (86%) | 43.0 (3%) st29 | 8.6 | (0%) st17 | 19.3 |
| Shield and hull, 28 HP | 4.7 | 44.2 (36%) st19 | 4.8 | (0%) st17 | 12.3 |
| Shield and hull, 28 HP, Blood Feast at 0.34 | 4.5 | 38.3 (80%) st6 | 4.7 | 49.0 (3%) st15 | 11.7 |
| Shield and hull, 32 HP, Blood Feast no drain | 5.5 | 43.4 (73%) st8 | 5.5 | 43.7 (10%) st17 | 12.7 |
| Shield and hull, 24 HP | 3.8 | 44.5 (60%) st12 | 3.0 | 30.7 (10%) st12 | 10.2 |
| Hull alone, 40 HP | 4.8 | 14.5 | 4.6 | 14.4 | 9.6 |
| Hull alone, 36 HP | 4.1 | 13.9 | 4.2 | 13.1 | 8.5 |
| Hull alone, 32 HP | 3.7 | 11.2 | 3.4 | 10.5 | 7.3 |
| Hull alone, 28 HP | 2.9 | 8.8 | 2.7 | 8.4 | 6.4 |

Read. No HP fixed the drain of shield and hull: Wainwright & Sutler's trio won 0 to 10% at every
size down to 24, stalling past 60 rounds, since every blow regrew the lord whether the shield took
it or not, and a trio that deals less a round than it drinks never closes. From the hull alone,
the shield starves it, and every row wins every fight at 40, the slow trios in 14 rounds (9 to 13
against the rest of the slate), the hard-to-keep-down boss it was meant as. Landed: the hull alone,
40 HP kept.

**The two escorted bosses** (the same rows and rung; a direction): the King Gel with three Gels,
so its merge has fuel, 6.0 rounds for the default team, 10.4 and 12.1 for the slow trios, 9.5 for
the stock four, hull lost 1 to 11%; the Pilgrim with three Needlers, 5.6, 8.7, 10.3 and 7.7, hull
lost 10 to 35%. Every row won every fight.

**Three machines or four, against the slate** (31 October; `tools/balance.gd`, 20 seeds, the
greedy rung, each boss alone, its parts with it; a direction). Ryan's question of 30 October:
"the biggest power spike the player gets is probably going from 3 to 4 units, right?" The stock
four (Honey Badger, Baboon, Armadillo, Prairie Dog, stock kits) against each of its trios, the
same kit a machine short, over the twelve bosses at tier one:

| Row | Won | Mean rounds of the fights won | Hull lost |
|---|---|---|---|
| The stock four | 100% | 8.6 (7.0 to 12.1) | 2.4% |
| Less the Armadillo | 100% | 10.3 | 8.0% |
| Less the Prairie Dog | 100% | 10.4 | 8.8% |
| Less the Honey Badger | 92% | 14.9 | 17.7% |
| Less the Baboon | 92% | 18.5 | 24.4% |

Read. The fourth machine is the run's biggest step in wear: a trio loses three to ten times the
hull the four loses on the same bosses, the halving of 13 October and more. In rounds the step
is the machine's role: a fourth that deals damage cuts a fight by 40 to 55%, a support or a scout
by about a sixth. The trios' losses fall on the trios short of a damage dealer: the Fallen Weapon,
Rotbloom and the Phantom Train (45 to 90% won) and the Behemoth (95%). On the stock four the slate runs 7 to 12 rounds at 48 HP, long
against the kill-time test's three to five and safe, the basics' damage the limiter; the default
team (two tier-two machines) takes 4 to 5.

**The Cinder Tortoise's armour at tier one** (31 October; `tools/balance.gd`, 30 seeds, the
greedy rung, alone; `--set` on its base armour and on Withdraw's value; a direction). Ryan's
question of 31 October: "If 2 is a massive hurdle for a first battle", for the bosses that carry
armour scaling by tier. Mean rounds of the fights won (every fight won):

| Base, shell | Default team | Minerva's trio | Kestrel's trio | Wainwright & Sutler's trio | The stock four |
|---|---|---|---|---|---|
| 2, +3 (as built) | 5.8 | 19.3 | 5.1 | 14.4 | 11.9 |
| 2, +2 | 5.6 | 18.4 | 4.9 | 14.4 | 12.1 |
| 1, +3 | 4.6 | 11.4 | 4.5 | 10.8 | 8.2 |
| 0, +3 | 3.9 | 7.4 | 3.7 | 7.5 | 5.7 |

Read. The base is the hurdle and the shell is not: a point off Withdraw moves nothing, since the
shell stands one round in a few, while the base taxes every blow of every round. At base 2 the
small-blow kits (Minerva's trio, Wainwright & Sutler's, the stock four) take the Tortoise half
again to twice as long as the rest of the slate; at base 1 it sits in the slate's middle on
every row; at 0 it is the slate's quickest. Hull lost stays 0 to 9% throughout: a slog, never a
threat. A tier-one team has little against armour: no Expose below tier two's locked pieces, the
one breach a tier-one blueprint no tier-one chassis stocks, Flak on the Prairie Dog alone.

**The slate's blanket point of armour at tier one** (31 October; `tools/balance.gd`, 20 seeds,
the greedy rung, each boss alone; every boss at its standard 1 against every boss at 0, the
Cinder Tortoise at 1 in both; a direction). Ryan, 31 October: "be careful giving all bosses
blanket 1 armour early on". Mean rounds of the fights won over the twelve, the win rate where
under 100%:

| Row | Armour 1 | Armour 0 |
|---|---|---|
| Default team | 4.7 | 3.8 |
| Minerva's trio | 10.5 | 7.6 |
| Wainwright & Sutler's trio | 11.0 (92%) | 7.9 |
| The stock four | 8.3 | 6.0 |

Read. The blanket point costs the small-blow kits about 40% more rounds and the default team
about a quarter; Wainwright & Sutler's trio loses fights only with it (the Fallen Weapon 40% won,
Rotbloom 80%, the Behemoth 95%), and wins every one without. At 0 the stock four takes 5 to 7
rounds and the default team 3.3 to 4.7, against the kill-time test's three to five.

**The bosses' escorts at tiers two and three** (2 November; `tools/balance.gd --boss-tiers`, 20 seeds,
the greedy rung; the default team (the Honey Badger, the Clydesdale, the Kite) and the stock four
(the Armadillo, the Prairie Dog, the Badger, the Baboon), each with its tier-zero kit, so a
tier-three cell is a trio or a four above its station and the escort's delta, never the cell, is
the read; a direction). Each boss at the tier's numbers (`ContentDB.scale_boss`, its parts with
it) with its own escort composition and alone. Won, mean rounds of the fights won, mean hull lost
over every fight, the escort's figure before the lone boss's:

| Boss, tier | Its escort | Default team: won, rounds, hull | Stock four: won, rounds, hull |
|---|---|---|---|
| Rotbloom, 2 | Mandrake, Goblin Guard | 100 / 100%, 7.3 / 5.8, 24 / 13% | 100 / 100%, 11.8 / 11.1, 16 / 13% |
| Rotbloom, 3 | Alraune ×2, Mandrake, Goblin Guard | 75 / 95%, 12.5 / 9.0, 65 / 39% | 90 / 100%, 15.6 / 12.6, 52 / 25% |
| Floraison, 2 | Warg ×2 | 100 / 100%, 6.9 / 6.0, 20 / 17% | 100 / 100%, 10.8 / 9.4, 9 / 8% |
| Floraison, 3 | Alpha Warg ×2, Goblin Captain, Goblin Guard | 90 / 100%, 11.4 / 7.2, 57 / 22% | 100 / 100%, 15.1 / 11.3, 15 / 12% |
| The King Gel, 2 | Gel ×3, Bubble Gel ×2 | 100 / 100%, 9.8 / 5.3, 24 / 4% | 100 / 100%, 13.3 / 8.8, 2 / 1% |
| The King Gel, 3 | Bubble Gel ×3, Metal Gel ×2, Gel | 100 / 100%, 13.4 / 6.8, 41 / 13% | 100 / 100%, 15.9 / 10.3, 8 / 2% |
| The Ruby Colossus, 2 | Basilisk, Pit Antlion | 30 / 65%, 12.5 / 11.4, 90 / 64% | 15 / 80%, 18.0 / 18.6, 93 / 57% |
| The Ruby Colossus, 3 | Gorgon ×2, Antlion Queen, Pit Antlion | 0 / 15%, – / 12.0, 100 / 94% | 0 / 20%, – / 21.8, 100 / 93% |
| The Fallen Weapon, 2 | Barbed Needler, Basilisk | 100 / 100%, 10.2 / 8.2, 32 / 25% | 100 / 100%, 14.8 / 13.2, 21 / 11% |
| The Fallen Weapon, 3 | Great Needler ×2, Gorgon ×2 | 35 / 95%, 11.9 / 12.5, 86 / 45% | 20 / 100%, 19.5 / 17.2, 95 / 20% |
| The Pilgrim, 2 | Needler ×2 | 100 / 100%, 6.4 / 5.7, 19 / 15% | 100 / 100%, 9.0 / 8.6, 15 / 14% |
| The Pilgrim, 3 | Barbed Needler ×2, Great Needler ×2 | 100 / 100%, 8.8 / 7.1, 37 / 26% | 100 / 100%, 11.4 / 10.2, 28 / 18% |
| The Matador, 2 | Wight ×2 | 100 / 100%, 7.5 / 6.0, 17 / 9% | 100 / 100%, 11.1 / 9.7, 3 / 1% |
| The Matador, 3 | Wight ×2, Death Knight, Spectre | 35 / 100%, 13.0 / 8.5, 86 / 25% | 90 / 100%, 20.4 / 11.8, 51 / 3% |
| The Phantom Train, 2 | Revenant, Spectre | 100 / 100%, 8.3 / 5.9, 14 / 6% | 100 / 100%, 11.8 / 10.6, 2 / 1% |
| The Phantom Train, 3 | Wight ×2, Wraith, Spectre | 90 / 100%, 14.3 / 7.0, 50 / 12% | 100 / 100%, 18.9 / 13.1, 28 / 3% |
| The Vampire Lord, 2 | Death Knight, Wight | 95 / 100%, 14.6 / 6.5, 37 / 7% | 100 / 100%, 15.8 / 14.4, 8 / 3% |
| The Vampire Lord, 3 | Dread Knight, Death Knight, Lich, Wight | 0 / 85%, – / 13.8, 100 / 43% | 5 / 100%, 50.0 / 15.4, 99 / 2% |
| The Behemoth, 2 | Bomb, Grenade | 100 / 100%, 9.9 / 7.8, 32 / 23% | 100 / 100%, 9.9 / 10.0, 10 / 10% |
| The Behemoth, 3 | Grenade ×2, Balloon ×2 | 100 / 100%, 13.1 / 8.3, 59 / 34% | 100 / 100%, 14.8 / 12.4, 25 / 18% |
| The Cinder Tortoise, 2 | Fire Lizard ×2 | 100 / 100%, 11.1 / 7.3, 18 / 7% | 100 / 100%, 16.7 / 17.1, 3 / 0% |
| The Cinder Tortoise, 3 | Magma Lizard ×2, Fire Lizard, Wyvern | 80 / 100%, 29.9 / 19.3, 70 / 34% | 90 / 100%, 31.5 / 25.3, 25 / 2% |
| The Obsidian Tyrant, 2 | Wyvern, Fire Lizard | 100 / 100%, 7.2 / 6.3, 9 / 3% | 100 / 100%, 12.8 / 10.4, 12 / 5% |
| The Obsidian Tyrant, 3 | Red Dragon, Wyvern ×2, Magma Lizard | 100 / 100%, 11.2 / 7.2, 31 / 6% | 100 / 100%, 17.2 / 12.8, 37 / 14% |

Read. What an escort adds runs from a round or two and a few points of hull (the Pilgrim's
Needlers, Floraison's Wargs, the Behemoth's Bombs, the Tyrant's lizards, the Tortoise's at tier
two) to a wall: the Vampire Lord's four risers at tier three take the default team from 85% won
to none and the four from 100% to 5% at fifty rounds; the Fallen Weapon's Great Needlers and
Gorgons under its Drive take them from 95 and 100% to 35 and 20%; the Matador's Wights, Death
Knight and Spectre take the trio from 100% to 35%. The escorts were never weighed against each
other, and menace does not sort them: by the runner's menace summed from content they run from
9 to 20 at tier two and 23 to 46 at tier three, the heaviest the Tyrant's (46), which costs no
wins, where the walls sit on the escorts a boss's own mechanic amplifies: the Lich's Reraise and
the Wight's mend on a boss that drains and rises (35), Drive's rally on the Great Needlers'
countdowns (38), a Death Knight's grave guard and a Spectre's cleanse under the cape (27). The King Gel's court
costs rounds and little hull, the merge's fuel being the merge's target, and the Tyrant's escort
costs hull and no wins: the two shapes an escort should take. And the Ruby Colossus is a wall
alone, at tier two (65 and 80% won at 64 and 57% hull) and at tier three (15 and 20%), where the
Fallen Weapon alone wins 95 and 100%: its two tentacles are two more attackers a round (a breach
of 7 to 8 and two strikes of 5 to 6 at the tiers) that grow back in two rounds, its Whirlsand
takes a third of a trio's dice for two rounds, which the greedy cannot answer (it values no
swallow), and Ultima lands 13 to 15 on every machine; its numbers are the evening's placeholders.

What-ifs (the same day, the same rows and seeds, a direction). The Colossus with its tentacles
at 4 and 3 (from 6 and 4) and a regrowth of three rounds (from two): alone at tier two 95 and
100% won at 32 and 26% hull (from 65 and 80% at 64 and 57%), at tier three 60 and 95% at 69 and
45% (from 15 and 20%); with its escort 45 and 85% at tier two (from 30 and 15%), and at tier three
still none, as the Fallen Weapon's cells read under its Great Needlers. Landed. The Vampire
Lord's tier-three escort at the Lord's tier-one numbers (a `--pack` cell, the boss unscaled), with
the Lich and with a second Wight in its place: 20 and 30% won with the Lich, 40 and 60% without,
hull 92 and 88% against 87 and 70%; the Lich readying the Lord to rise again is half the wall,
the risers' guard and last act the rest. The Lich out, landed; a lighter form (a Death Knight and
three Wights) is Ryan's to mark.

## 31 October, the Honey Badger's rework

**Its build session's reads** (the Ore Hopper built 31 October on
`claude/affectionate-ramanujan-5d24t6`, on Ryan's go and his fallbacks should it read overpowered:
"I would probably go to 2 base armour and 1 for every 2 loads, to a total of 4. If that's still
busted, back to 1 base"; his question beside it, "Badger probably deserves less base shield from
this, right?"). `tools/balance.gd`, 30 seeds a cell (a direction), random and greedy, the party's
cells in, the matrix's 71 packs (the thirteen tier-one packs; thirty-three of tiers two and three
with the party's finals and the finale; thirteen lone big foes and bosses; twelve formations), on
Godot 4.8-beta2. Every row but the build's is the content as built with `--set`: the old Badger
is its Reinforced Skeleton passive, armour 2, the claw rolled 2-4 with Spread 2 filling one a foe
reached, the fragmenter firing three at +1 (the engine now fills by damage where it filled by
reach, which differs only on a blow armour or a Barrier stopped). Won, random / greedy, then
greedy's hull lost and rounds to a win.

**The Honey Badger alone**:

| Row | Every pack | Tier-one rank and file (13) | Tiers two and three, the party (33) | Lone big foes and bosses (13) | Formations (12) | Hull lost | Rounds won |
|---|---|---|---|---|---|---|---|
| The old Badger | 33 / 51 | 67 / 90 | 37 / 59 | 16 / 34 | 0 / 3 | 65% | 6.8 |
| As proposed (base 1, a point a load, 1 to 5) | 48 / 69 | 77 / 97 | 50 / 76 | 52 / 73 | 6 / 14 | 47% | 6.9 |
| As proposed, shield 6 | 46 / 68 | 75 / 97 | 48 / 75 | 49 / 73 | 6 / 14 | 49% | 6.8 |
| First fallback (base 2, a point for every two loads, to 4) | 45 / 67 | 76 / 97 | 47 / 73 | 45 / 72 | 6 / 10 | 50% | 6.5 |
| Second fallback (base 1, a point for every two loads, to 3) | 38 / 60 | 65 / 95 | 42 / 67 | 34 / 61 | 0 / 4 | 56% | 6.1 |
| As proposed, the claw 2 a strike | 44 / 64 | 76 / 94 | 44 / 72 | 45 / 59 | 6 / 16 | 51% | 7.4 |
| As proposed, no plate | 30 / 53 | 53 / 82 | 36 / 64 | 21 / 47 | 0 / 0 | 62% | 5.3 |
| The Armadillo (beside the old Badger) | 16 / 27 | 37 / 56 | 15 / 30 | 11 / 15 | 0 / 0 | 83% | 10.2 |

The lone foes the change moved most, random / greedy: the Treant 3 / 67 as it was, 97 / 100 as
proposed, 83 / 100 at the first fallback, 53 / 100 at the second; the Bone Dragon 3 / 77, 97 /
100, 83 / 100, 57 / 100; Gilgamesh 7 / 93, 100 / 100, 100 / 100, 80 / 100; the Bourgeon 0 / 0, 100
/ 100, 100 / 100, 67 / 100. The rounds to beat the Treant fell from 27 to 10.

**The Minerva team** (the Badger, the Armadillo, the Wild Boar):

| Row | Every pack | Tier-one rank and file | Tiers two and three, the party | Lone big foes and bosses | Formations | Hull lost | Rounds won |
|---|---|---|---|---|---|---|---|
| The old Badger | 84 / 92 | 99 / 100 | 92 / 96 | 92 / 100 | 38 / 63 | 16% | 4.6 |
| As proposed | 86 / 94 | 100 / 100 | 93 / 97 | 96 / 100 | 38 / 73 | 13% | 4.1 |
| As proposed, shield 6 | 86 / 94 | 100 / 100 | 93 / 97 | 96 / 100 | 38 / 73 | 13% | 4.1 |
| First fallback | 86 / 94 | 100 / 100 | 93 / 97 | 96 / 100 | 38 / 72 | 14% | 4.1 |

Read: the plate carries it. With no plate it reads at the old Badger's line, a claw of 2 a strike
takes four or five points off, its shield at 6 a point or two; a point a load lifts it eighteen
points greedy and random play past half the lone big foes, which the old Badger and the Armadillo
lose. Ryan's first fallback moves it two points, since base 2 keeps the early armour the second
point a load would have given; his second brings it to 38 / 60, a few points over the old Badger,
its lone big foes at 34 / 61. Landed: the second fallback, as his sequence said. Its base shield
stays 8, the read at 6 within a point or two. Still worth his eye: random play takes the Treant,
the Bone Dragon and Gilgamesh more often than not at the second fallback, where the old Badger
lost them, the detachment niche he gave it or still too easy; the claw's number is the next lever
measured. The team barely moves either way, the plate adding about ten points greedy on the
formations.

## 31 October, the weapons' flare colours

**The flare read** (the decision it informs: the weapons' muzzle flares, a colour a tag, Ryan's
31 October "If the flare colour of the weapons can follow their tags, that would be really
cool"; MuzzleFlare). Method: the Machado simulations at severity 1.0 (normal, protan, deutan,
tritan), CIE76 ΔE in CIELAB and luminance contrast, each pair at its worst simulation. The
palette: ballistic #ff6a00, missile #ff4c00, flame #ff2400, beam #ff0a40, plasma #ff2a8c, arc
#40d8ff, blade #ff7800 (the reds and oranges red and green alone, short of #ff8200; the beam and
the plasma carry blue, being no heat).

Between the flares (worst ΔE, the simulation): the heat family stands close in the deutan
simulation, ballistic and blade 2.8, missile and flame 4.0, ballistic and missile 4.9, ballistic
and flame 8.9; flame and beam 2.9 (tritan); every other pair 7.6 or more, the arc 62 or more from
everything. So no two looks part by hue alone: each has its beat and its shape (MuzzleFlare.BEATS:
a sharp four-point star for a gun, a slow round puff for a launcher, a flickering round gout for
a fire weapon, a held streak for a beam, a swelling six-point star for plasma, a strobing star for
lightning, eight quick sparks for a blade), and its class's place.

Against the meanings (worst ΔE): every flare 27 or more from the gain green except the arc, 15.3
(tritan); every one 34.9 or more from the enemy violet except the arc, 6.5 (deutan), the coil's own
cyan since the 31st; the plasma 44.0 and every other 41 or more from the shield.

On the grounds (contrast / worst ΔE): the Arsenal's black hull #2a2e36 3.5 to 8.1:1 / 31 to 79;
our floor #4a4438 2.5 to 5.7:1 / 18 to 64; a steel hull #8a9098 1.0 to 1.9:1 / 14 to 68; the
Aphelion's white #e8e8ec 1.4 to 3.2:1 / 24 to 73. A flare is laid over the hull rather than added
(added, the plasma read pale pink on the Badger's grey), so its colour holds on every hull; on a
mid steel its edge is its shape, not its lightness.

## 2 November, the bosses' escorts at tiers two and three

Written as a paragraph inside "30 October, the slate's last five" (above), where its method,
its seeds and its table are; this heading indexes it.

## 2 November, the Armadillo at tier one

**Is the Armadillo too much of a wall for tier one?** (Ryan's play test of 2 November: "armadillo
is probably too much of a wall for tier 1. It's very good at its job.") The balance runner,
greedy, 30 seeds a cell (a direction), the tier-one packs and formations (`--packs` the seventeen
of tier one: each spawn-table pack at its strength and each domain's tier-one formation;
`--noparty`): the Armadillo alone beside three tier-one peers (the Storm Petrel, the Baboon, the
Cassowary) and the Honey Badger; then a starter trio, the Honey Badger and the Skua with the
Armadillo in the middle seat, beside the same trio with each peer there; then three what-ifs on
the Armadillo's trio, its Lockdown's armour 3 to 2 (`--set
chassis/armadillo/passive/effects/0/value=2`), its base armour 2 to 1, and both. About twenty
minutes on two cores, from a frozen copy of `3929042`'s tree (this branch's base, the engine as main has it).

The trios' hull lost, mean of every fight (greedy):

| Trio (Honey Badger, X, Skua) | Rank and file (13 packs) | Meadow formation | Waste | Marsh | Peak |
|---|---|---|---|---|---|
| Armadillo | 0 to 2%, the Zombie Knights 28% | 6% | 6% | 82% | 8% |
| Storm Petrel | 0 to 2%, the Zombie Knights 25% | 4% | 4% | 83% | 4% |
| Baboon | 0 to 2%, the Zombie Knights 19% | 10% | 7% | 78% | 8% |
| Cassowary | 0 to 1%, the Zombie Knights 33% | 13% | 8% | 94% | 12% |
| Armadillo, Lockdown +2 | as the Armadillo's | 6% | 6% | 82% | 8% |
| Armadillo, armour 1 | as the Armadillo's | 9% | 6% | 81% | 9% |
| Armadillo, both | as the Armadillo's | 9% | 6% | 81% | 9% |

Alone, the Armadillo kills slowly and loses hull on most tier-one packs (98% on the goblins and the
revenants, 88% on the gels, 100% on every formation), the slowest of the five rows (5.6 to 27.9
rounds won where the Badger takes 2.3 to 10). In the trio, the Canopy is 6% of the spends (26%
alone): the greedy bot rarely seals in a team, so the runner barely reads Lockdown at all (its
+2 what-if moves no trio cell).

Read:

- **Every starter trio walls tier one's rank and file**: none loses more than 2% hull on any of the
  thirteen packs but the Zombie Knights, whoever sits in the middle seat; the formations take 4% to
  13% but the Marsh's (about 80%, its Zombie Knights). On the bot's play the Armadillo's trio sits
  in the band, and the Storm Petrel's takes less.
- **The seal is where the bot cannot look**: sealed, the Armadillo's armour is 5 against tier-one
  blows of 2 or 3 (the rank and file's), so once its shield is down a sealed Armadillo takes
  nothing from them; the greedy bot spends the Canopy on itself too rarely in a team to show it.
  Ryan's read is of play the runner does not make, so the runner neither confirms it nor clears
  it; the arithmetic agrees with him for a sealed Armadillo against the rank and file.
- **A smaller seal does not reach the root**: at Lockdown +2 the sealed armour is 4, still over
  every tier-one rank-and-file blow; flat armour at or over a tier's blows is immunity at any
  number. The question is the bible's section 12 (the Armadillo at tier one).

## 3 November, the Cassowary's cycle and the Cottonmouth beside it

**The bot's cycle** (`b6242a4`, the to-do's engine line): the greedy reroll had turned the
Cassowary's dial toward a better next chamber and never planned, so it stepped off a chamber
whose neighbour would open the next round better, never stepped through a weak chamber to a big
one, and priced the Spin-Up at its stack alone, rerolling away from the spin. It now weighs every
count of steps the rerolls in hand allow (`Policy.cycle_plan`). Old bot (`62ef7ee`) against new,
30 seeds a cell (a direction), no party, greedy won, by the matrix's 76 packs in six groups: tier
one's rank and file (13), its four big foes, its four formations, the ladder's recolours at tiers
two and three (35), their formations (8) and the twelve bosses alone at tier one.

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Rounds won |
|---|---|---|---|---|---|---|---|---|
| Cassowary | 36 → 46 | 0 → 0 | 0 → 0 | 22 → 32 | 0 → 0 | 0 → 1 | 16 → 23 | 6.8 → 4.8 |
| Cottonmouth | 75 → 75 | 0 → 0 | 0 → 0 | 39 → 39 | 0 → 0 | 0 → 0 | 31 → 31 | 3.4 → 3.4 |
| Cassowary + Prairie Dog | 89 → 92 | 25 → 35 | 0 → 0 | 56 → 66 | 0 → 0 | 32 → 53 | 47 → 57 | 9.6 → 8.1 |
| Cassowary + Cottonmouth + Prairie Dog | 99 → 100 | 72 → 82 | 10 → 18 | 80 → 83 | 0 → 0 | 81 → 88 | 71 → 75 | 5.6 → 5.2 |
| Badger + Cassowary + Puffin | 100 → 100 | 100 → 100 | 20 → 40 | 95 → 96 | 0 → 0 | 98 → 99 | 82 → 84 | 5.2 → 5.0 |

The random rung (it never rerolls) and the Cottonmouth alone come out identical cell for cell
(380 random cells, 152 of the Cottonmouth's), so the change reaches a stepping die's rerolls
alone. The Wainwright & Sutler team row (the Clydesdale, the Prairie Dog, the Dingo) fields
neither machine, hence the `--team` rows.

**At 200 seeds**, the new bot (`ef28a6b`; `fcdbbfb` reads each chamber once and plays the same,
its 43 cells of ten seeds identical), 152,000 fights, no party: won, random / greedy.

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| Cassowary | 29 / 44 | 0 / 0 | 0 / 0 | 15 / 30 | 0 / 0 | 0 / 0 | 12 / 21 | 84% | 4.8 |
| Cottonmouth | 47 / 75 | 0 / 0 | 0 / 0 | 20 / 40 | 0 / 0 | 0 / 0 | 17 / 31 | 76% | 3.4 |
| Cassowary + Prairie Dog | 52 / 90 | 0 / 35 | 0 / 0 | 37 / 66 | 0 / 0 | 1 / 51 | 26 / 56 | 56% | 8.2 |
| Cassowary + Cottonmouth + Prairie Dog | 92 / 100 | 27 / 79 | 0 / 18 | 65 / 83 | 0 / 0 | 43 / 88 | 54 / 74 | 32% | 5.2 |
| Badger + Cassowary + Puffin | 97 / 100 | 73 / 100 | 0 / 34 | 75 / 96 | 0 / 0 | 73 / 99 | 66 / 84 | 25% | 5.0 |

Pick share, greedy, every pack: the Cassowary alone spends the Spin-Up 36%, the Halo Shield 16%,
the Twin Autoguns 15%, the Rivet Gun 12%, the Ankle Mortar 11% and the Coolant Jacket 7% (the old
bot at 30 seeds: the Autoguns 29%, the Shield 27%, the Mortar 13%, the Rivet Gun and the Spin-Up
12% each); the Spin-Up is 16 to 23% of its teams' spends. The Cottonmouth alone: the Twin
Autoguns 33%, the Ankle Mortar 31%, the Halo Shield 31%, the Coolant Jacket 4%. Rerolls a round,
greedy, alone: the Cassowary 1.37 (0.98 on the old bot), the Cottonmouth 0.98. The runner plays
the Cassowary's fights about 2.3 times as slowly as before (ten seeds of its packs, 32 s against
14 s), its rounds holding more spends.

Read: the old bot left the dial unplayed. Planned, the Cassowary alone carries a decision (greedy
about twice random) and sits under the Cottonmouth, the stronger tier-one gun alone (31% against
21% over every pack, 75% against 44% on tier one's rank and file, faster and losing less hull);
neither takes a big foe, a formation or a boss alone. Neither reads as a wall or a free win on
tier one's rank and file (the roster row's exit): random play takes 29 and 47% of it, greedy 44
and 75%. In company, beside the Prairie Dog the Cassowary takes half the bosses greedy where random
play takes one in a hundred, and the maker's tier-one trio takes 88% of them and 79% of tier one's
big foes (random 43 and 27%); no row here swaps the Cassowary out, so its share of those wins is
unread. The plan steers the dial onto the Spin-Up, its most spent entry: a spin is an action again and a
stack of Spun Up whatever it lands on. Worth Ryan's eye in play: whether steering onto the spin
every round is the chase the design wanted or a line that flattens the dial.

## 3 November, the chassis' runner rows: the Whip Scorpion, the Swallowtail, the Musk Ox, the Needletail

The to-do's engine lines, each read with the levers its line and its bible row name. `tools/balance.gd`,
30 seeds a cell (a direction throughout), random and greedy, no party, the 76 packs in the six groups
of the Cassowary's entry above; the what-ifs by `--set` (content in memory, never written) and the
runner's `--pilot`. Run on this branch from `bd267ee` to `9ce9033`: no commit between changes a row's
play but the salvo's pricing, which reaches the Musk Ox alone, and its rows are on `061693c`.

**The band**, every other tier two and tier three alone on the same packs, so "cold" and "too easy"
read against their peers (the matrix on file, 27 October, predates these packs). Tier two:

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| Nemesis | 84 / 98 | 34 / 52 | 0 / 0 | 59 / 69 | 0 / 0 | 29 / 52 | 48 / 60 | 60% | 4.7 |
| Wild Boar | 81 / 93 | 0 / 14 | 0 / 0 | 48 / 61 | 0 / 0 | 8 / 40 | 37 / 51 | 63% | 7.2 |
| Goshawk | 53 / 75 | 8 / 41 | 0 / 0 | 39 / 65 | 0 / 0 | 6 / 36 | 28 / 51 | 63% | 5.0 |
| Clydesdale | 59 / 85 | 0 / 6 | 0 / 0 | 42 / 57 | 0 / 0 | 1 / 22 | 29 / 45 | 69% | 5.8 |
| **Whip Scorpion** | 58 / 86 | 0 / 6 | 0 / 0 | 42 / 59 | 0 / 0 | 1 / 15 | 29 / 44 | 69% | 4.4 |
| Funnel Web | 49 / 61 | 0 / 32 | 0 / 0 | 35 / 51 | 0 / 0 | 5 / 47 | 25 / 43 | 71% | 7.5 |
| Sparrowhawk | 54 / 61 | 2 / 22 | 0 / 0 | 39 / 57 | 0 / 0 | 0 / 3 | 27 / 39 | 66% | 2.6 |
| **Needletail** | 32 / 46 | 0 / 0 | 0 / 0 | 20 / 35 | 0 / 0 | 0 / 0 | 15 / 24 | 80% | 3.3 |
| Dingo | 18 / 33 | 0 / 0 | 0 / 0 | 9 / 19 | 0 / 0 | 0 / 0 | 7 / 14 | 91% | 4.8 |

Tier three (the boss cells are the bosses at tier one, below this tier):

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| **Musk Ox** (the salvo fixed) | 81 / 79 | 2 / 19 | 0 / 0 | 55 / 64 | 0 / 0 | 14 / 54 | 41 / 52 | 64% | 7.1 |
| Giant Petrel | 49 / 76 | 3 / 32 | 0 / 0 | 38 / 62 | 0 / 0 | 1 / 20 | 26 / 46 | 67% | 4.8 |
| Ammit | 57 / 80 | 0 / 1 | 0 / 0 | 41 / 54 | 0 / 0 | 0 / 6 | 29 / 40 | 72% | 4.5 |
| Lammergeier | 12 / 67 | 0 / 5 | 0 / 0 | 5 / 53 | 0 / 0 | 0 / 7 | 4 / 37 | 71% | 4.0 |
| **Swallowtail** | 37 / 69 | 0 / 0 | 0 / 0 | 24 / 46 | 0 / 0 | 0 / 14 | 17 / 35 | 76% | 9.0 |

**The Whip Scorpion** (its row's exits: the solo row cold, the pilot light; the boss cells too easy, half
the blast; the lure-all too swingy, the rank form). Alone and with the Clydesdale and the Dingo:

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| Stock | 58 / 86 | 0 / 6 | 0 / 0 | 42 / 59 | 0 / 0 | 1 / 15 | 29 / 44 | 69% | 4.4 |
| A pilot light of 1 (`--pilot whip_scorpion=1`) | 61 / 86 | 0 / 2 | 0 / 0 | 43 / 58 | 0 / 0 | 1 / 15 | 30 / 44 | 69% | 4.3 |
| A pilot light of 2 | 63 / 86 | 0 / 3 | 0 / 0 | 44 / 58 | 0 / 0 | 1 / 12 | 31 / 43 | 69% | 4.2 |
| Half the blast | 50 / 74 | 0 / 0 | 0 / 0 | 37 / 57 | 0 / 0 | 0 / 4 | 26 / 40 | 70% | 4.0 |
| Stock, the trio | 99 / 100 | 82 / 100 | 0 / 68 | 81 / 98 | 0 / 0 | 72 / 99 | 70 / 87 | 23% | 4.1 |
| A pilot light of 1, the trio | 99 / 100 | 80 / 100 | 0 / 67 | 80 / 98 | 0 / 0 | 71 / 99 | 69 / 87 | 23% | 4.2 |
| A pilot light of 2, the trio | 98 / 100 | 69 / 100 | 0 / 54 | 79 / 98 | 0 / 1 | 70 / 99 | 68 / 86 | 23% | 4.0 |
| Half the blast, the trio | 99 / 100 | 78 / 100 | 0 / 59 | 80 / 97 | 0 / 1 | 70 / 98 | 69 / 86 | 24% | 4.2 |

Its spends alone (greedy): the Coolant Jacket 35%, the Thermal Ray 32%, the Maxigun 22%, the Heliographic Siphon 11%; with a pilot light of 1, the Coolant Jacket 43%, the Thermal Ray 28%, the Maxigun 20%, the Heliographic Siphon 9%; of 2, the Coolant Jacket 51%, the Thermal Ray 23%, the Maxigun 17%, the Heliographic Siphon 8%. Its gauge alone peaks
at 77% of its maximum on average and ends a fight at 56%; a pilot light of 1 and 2 raises the overheats from
0.20 a fight to 0.33 and 0.40. The rank form (the Siphon as `lure` and `cleave` on its target, `reaches_all`
off) plays the same as stock alone, every number (a lone machine is every foe's target, so a lure moves
nothing there), and in the trio the Siphon is 3% of the spends stock and 4% in rank form, the spread of
hull lost within a cell 4.8 points against 4.7 (the runner's `hull_lost_sq`).

Read: none of the three exits is reached. The solo row sits in the middle of the tier twos' band (44%
greedy over every pack, fifth of nine) and its bosses alone (15%) below the band's middle, so neither
lever is called for. The pilot light is no lever at all: heat is not what limits it, and the extra heat
turns gun spends into vent spends; a cold row would want another lever. Half the blast bites
alone (its bosses 15% to 4%) and not in the trio. The lure-all's swing reads no wider than the rank
form's at the rate the bot spends the Siphon, so its swing is unread rather than absent.

**The Swallowtail** (its line: its team rows with and without it, the musters it spends and on which
piece, the Phased read against its price):

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| Swallowtail | 37 / 69 | 0 / 0 | 0 / 0 | 24 / 46 | 0 / 0 | 0 / 14 | 17 / 35 | 76% | 9.0 |
| Clydesdale + Dingo | 86 / 99 | 16 / 76 | 0 / 0 | 61 / 79 | 0 / 0 | 24 / 70 | 47 / 68 | 46% | 5.3 |
| Swallowtail + Clydesdale + Dingo | 97 / 100 | 78 / 100 | 0 / 54 | 79 / 96 | 0 / 1 | 71 / 98 | 68 / 85 | 24% | 5.1 |
| The Screens charged at two musters, the trio | 97 / 100 | 77 / 100 | 0 / 59 | 79 / 97 | 0 / 2 | 72 / 97 | 68 / 86 | 23% | 5.2 |

Charged spends a fight, greedy, in the trio: the Flare 0.32, the Hoist 0.21, the Screens 0.07, the Horn 0.02 (0.62 in all); alone, the Flare alone (0.31), the rest needing an ally. With the
Screens at two musters: the Flare 0.34, the Hoist 0.21, the Horn 0.02, the Screens 0.00. The bot
weighs Phased by the round's forecast with it and without it, less the ally's action it stands down.

Read: alone it is the tier threes' weakest (a support machine), and beside the Clydesdale and the Dingo
it lifts the pair seventeen points greedy, the formations from none to half, and halves their hull lost.
The Flare's Suppress takes about half its musters and the Hoist's refit a third; the charged dock is the
rarest charge bought (Phased about once in fifteen fights) and at two musters never, the rows unmoved: no
free round at one muster, so its price is not the question.

**The Musk Ox** (its row's exits: ammo running plentiful, the reloads or the trickle; the salvo
multiplying the foes' Flak past its worth, the strike's number; the Quick Reload kept or cut once
tested). First the bot (`061693c`): the greedy rung had priced the whole magazine against the salvo,
each ammo at half what it would buy on the other guns, so a full magazine of 10 read barely positive and
it rerolled the salvo away (2% of its spends) while random play fired it; it now counts only a reserve,
the ammo its dearest other gun's next spend needs. Alone and with the Clydesdale and the Dingo:

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| Old bot | 81 / 68 | 2 / 0 | 0 / 0 | 55 / 58 | 0 / 0 | 14 / 16 | 41 / 41 | 71% | 6.5 |
| Salvo fixed | 81 / 79 | 2 / 19 | 0 / 0 | 55 / 64 | 0 / 0 | 14 / 54 | 41 / 52 | 64% | 7.1 |
| Trickle 0 | 74 / 75 | 0 / 5 | 0 / 0 | 49 / 60 | 0 / 0 | 1 / 31 | 36 / 45 | 68% | 7.2 |
| Trickle 2 | 83 / 82 | 8 / 28 | 0 / 0 | 56 / 65 | 0 / 0 | 24 / 65 | 44 / 56 | 62% | 6.9 |
| The Quick Reload cut | 78 / 79 | 0 / 16 | 0 / 0 | 54 / 64 | 0 / 0 | 10 / 56 | 40 / 53 | 64% | 7.3 |
| Old bot, the trio | 99 / 100 | 100 / 100 | 18 / 58 | 86 / 93 | 0 / 3 | 91 / 96 | 77 / 84 | 27% | 5.0 |
| Salvo fixed, the trio | 99 / 100 | 100 / 100 | 18 / 73 | 86 / 97 | 0 / 5 | 91 / 100 | 77 / 87 | 23% | 4.7 |
| Trickle 0, the trio | 99 / 100 | 88 / 100 | 2 / 65 | 82 / 95 | 0 / 3 | 79 / 98 | 72 / 85 | 25% | 4.8 |
| Trickle 2, the trio | 100 / 100 | 100 / 100 | 21 / 81 | 89 / 98 | 0 / 10 | 93 / 100 | 79 / 88 | 22% | 4.6 |
| The Quick Reload cut, the trio | 100 / 100 | 98 / 100 | 3 / 76 | 87 / 97 | 0 / 8 | 85 / 99 | 76 / 88 | 23% | 4.7 |

Its spends alone, greedy: on the old bot the Canopy 31%, the Enfilade Beam 22%, the Coolant Jacket 14%, the Shrapnel Recuperator 12%, the Thermal Ray 10%, the Quick Reload 9%, the Unrestricted Expenditure 2%; fixed, the Canopy 26%, the Coolant Jacket 17%, the Enfilade Beam 14%, the Unrestricted Expenditure 13%, the Quick Reload 11%, the Thermal Ray 9%, the Shrapnel Recuperator 9%.

The Flak read: the salvo beside allies that lay Flak, the Musk Ox with the Clydesdale (its Airburst
Shell) and the Prairie Dog (its Flakshot Repeater), stock, with Flak struck from all three pieces (the
Recuperator's, the Shell's and the Repeater's), and with the salvo's strike at 1 and at 3 (stock 2):

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| Stock | 99 / 100 | 96 / 100 | 16 / 66 | 85 / 95 | 0 / 9 | 87 / 100 | 76 / 86 | 23% | 5.6 |
| No Flak anywhere | 99 / 100 | 92 / 100 | 13 / 65 | 83 / 93 | 0 / 8 | 84 / 99 | 74 / 85 | 25% | 5.8 |
| The salvo struck at 1 | 98 / 100 | 80 / 100 | 0 / 48 | 80 / 90 | 0 / 6 | 80 / 94 | 71 / 82 | 26% | 6.0 |
| The salvo struck at 3 | 100 / 100 | 100 / 100 | 30 / 83 | 91 / 99 | 0 / 21 | 94 / 100 | 80 / 90 | 19% | 5.1 |

The salvo is 5% of the trio's spends stock, under 2% struck at 1 and 7% at 3. Striking Flak from all
three pieces costs the trio at most two points in any group; the strike's number moves it most, the
formations at tier one 48, 66 and 83% greedy at a strike of 1, 2 and 3.

Read: the old bot left the salvo unplayed, a verdict on the bot and fixed. The salvo does not multiply
the team's Flak past its worth: the Flak is worth a point or two beside it, and the strike's number is
the lever if the salvo ever needs one. The trickle is the strong
lever and works through the bosses (alone, 31, 54 and 65% at a trickle of 0, 1 and 2), the salvo the boss
killer its row means it to be; whether that is ammo "running plentiful" is a call on feel, since the
boss cells here are tier one's and the Musk Ox is a tier three. The Quick Reload cut reads as nothing, on
a bot that never counts the action again a plain Rapid entry brings, so that test waits on the bot. Alone
the Recuperator's Flak never pays: one weapon a round, and Flak halves away at the round's end.

**The Needletail** (its line: alone as a diagnostic and in Kestrel's team, the share of its spends the gate
made free and of its paints an ally's Direct spend cashed). The gate tally was fixed on the way
(`9ce9033`: it had missed a free buff on a machine, the Overcharge Coil); the rerun plays the same, all
456 cells identical but for that count.

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| Needletail | 32 / 46 | 0 / 0 | 0 / 0 | 20 / 35 | 0 / 0 | 0 / 0 | 15 / 24 | 80% | 3.3 |
| Sparrowhawk + Goshawk | 91 / 100 | 57 / 98 | 0 / 0 | 77 / 93 | 0 / 0 | 65 / 96 | 64 / 80 | 28% | 3.0 |
| Needletail + Sparrowhawk + Goshawk | 99 / 100 | 98 / 100 | 0 / 54 | 94 / 100 | 0 / 3 | 89 / 100 | 79 / 87 | 19% | 2.6 |

Greedy: alone the gate makes 82% of its setups (the Fovea Designator and the Overcharge Coil) free,
17% of all its spends; in the trio 78% of its setups. It paints 0.41 foes a fight alone,
none cashed (no ally), and 0.52 in the trio, 67% of them cashed by an ally's Direct weapon spend
while the foe stood Exposed.

Read: alone it is the tier twos' second weakest, a 20-hull interceptor read as a diagnostic; in Kestrel's
trio it lifts the Sparrowhawk and the Goshawk seven points greedy, the formations from none to half, and
cuts their hull lost by a third. Its gate fires on most of its setups, and two paints in three are cashed.

## 4 November, a Rapid entry's action again

The bot's fix (`d160f8a`, Ryan: "If the bot doesn't value rapid property, it probably should be
fixed"): a plain Rapid entry now scores its blow or its spend plus the die's own average blow, its
action again, where it had scored the blow alone. The three machines carrying such a piece, alone,
the old bot (`aca3ee9`) against the new, 30 seeds a cell (a direction), no party, the 76 packs in the
six groups of 3 November: won, random / greedy.

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack | Hull lost (greedy) | Rounds won (greedy) |
|---|---|---|---|---|---|---|---|---|---|
| Armadillo, old bot | 37 / 56 | 0 / 0 | 0 / 0 | 22 / 36 | 0 / 0 | 0 / 0 | 16 / 26 | 83% | 9.8 |
| Armadillo, new | 37 / 56 | 0 / 0 | 0 / 0 | 22 / 36 | 0 / 0 | 0 / 1 | 16 / 27 | 83% | 9.9 |
| Giant Petrel, old bot | 49 / 76 | 3 / 32 | 0 / 0 | 38 / 62 | 0 / 0 | 1 / 20 | 26 / 46 | 67% | 4.8 |
| Giant Petrel, new | 49 / 76 | 3 / 29 | 0 / 0 | 38 / 62 | 0 / 0 | 1 / 17 | 26 / 46 | 67% | 4.7 |
| Musk Ox, old bot | 81 / 79 | 2 / 19 | 0 / 0 | 55 / 64 | 0 / 0 | 14 / 54 | 41 / 52 | 64% | 7.1 |
| Musk Ox, new | 81 / 79 | 2 / 21 | 0 / 0 | 55 / 65 | 0 / 0 | 14 / 51 | 41 / 53 | 64% | 6.9 |

Spends, greedy: the Armadillo's two Cryo Flingers 9% of its spends on the old bot, 13% on the new; the Giant
Petrel's Immelmann Booster under 2% (alone it buys no ally an action) and 14%; the Musk Ox's Quick
Reload 11% and 17%. Random play comes out identical cell for cell (76 of 76 for each machine).

Read: the fix changes how often the bot picks a Rapid piece, not the rows: the action again always
happened in play when the piece was spent, and the bot now spends it on its worth. The win rows move a
point or two either way, inside a 30-seed cell's band. The Musk Ox's Quick Reload cut of 3 November
was read on the old bot; its design session reads it again.

## 4 November, the elites' first read

The elites' cells on the runner, built today (`--packs elites`): every elite composition at each
tier it names, its elites at the tier's numbers as a battle fields them (`ContentDB.foes_for`,
`scale_boss` on every elite) and its rank and file as content has them, the lead with its
composition's members, its parts and its summons as in play. Each cell is the composition
against a fresh squad and nothing else, which a battle never gives it (an elite emerges at a
Fracture into a worn squad and joins the fights its ring covers), so the cells read the kit alone
and overstate the ease. Rows: the tender's team and the maker trios with three runnable chassis
(Minerva, Kestrel, Wainwright & Sutler), stock; and the five endgame fours (`tools/endgame_fours.py`,
fitted to tier two). Random and greedy, 30 seeds, a direction: 15,900 fights a run, 30 and 52
minutes. The band is read on the tier's own rows, tier one on the trios and tiers two and three on
the fours (a stock trio at tier three is the wrong row): random winning means too easy, greedy
losing a wall, the two landing together no decision.

| Composition, tier | Lead | Trios: random / greedy won, hull lost (greedy) | Fours: random / greedy won, hull lost (greedy) | Band (its tier's rows) |
|---|---|---|---|---|
| elder_treants_grove, 2 (meadow) | Elder Treant | 67 / 100%, 15% | 100 / 100%, 0% | no decision |
| elder_treants_grove, 3 (meadow) | Elder Treant | 46 / 98%, 28% | 100 / 100%, 0% | no decision |
| leshys_hunt, 2 (meadow) | Leshy | 99 / 100%, 0% | 100 / 100%, 0% | no decision |
| leshys_hunt, 3 (meadow) | Leshy | 98 / 100%, 0% | 100 / 100%, 0% | no decision |
| shamans_warband, 1 (meadow) | Goblin Shaman | 100 / 100%, 1% | 100 / 100%, 0% | no decision |
| shamans_warband, 2 (meadow) | Goblin Shaman | 100 / 100%, 1% | 100 / 100%, 0% | no decision |
| shamans_warband, 3 (meadow) | Goblin Shaman | 100 / 100%, 2% | 100 / 100%, 0% | no decision |
| the_nob, 1 (meadow) | The Goblin Nob | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| the_nob, 2 (meadow) | The Goblin Nob | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| the_nob, 3 (meadow) | The Goblin Nob | 100 / 100%, 1% | 100 / 100%, 0% | no decision |
| gilgamesh_and_enkidu, 3 (waste) | Gilgamesh | 77 / 100%, 12% | 100 / 100%, 0% | no decision |
| gilgamesh_wanders, 1 (waste) | Gilgamesh | 100 / 100%, 1% | 100 / 100%, 0% | no decision |
| gilgamesh_wanders, 2 (waste) | Gilgamesh | 100 / 100%, 2% | 100 / 100%, 0% | no decision |
| old_mans_rising, 1 (waste) | Old Man of the Desert | 11 / 81%, 60% | 88 / 100%, 15% | decision |
| old_mans_rising, 2 (waste) | Old Man of the Desert | 5 / 73%, 76% | 85 / 100%, 19% | too easy |
| old_mans_rising, 3 (waste) | Old Man of the Desert | 0 / 25%, 93% | 79 / 100%, 24% | too easy |
| pilgrims_wake, 1 (waste) | The Pilgrim | 95 / 100%, 13% | 100 / 100%, 1% | no decision |
| pilgrims_wake, 2 (waste) | The Pilgrim | 81 / 100%, 21% | 100 / 100%, 2% | no decision |
| pilgrims_wake, 3 (waste) | The Pilgrim | 67 / 100%, 30% | 99 / 100%, 4% | no decision |
| rust_monsters_scavenge, 1 (waste) | The Rust Monster | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| rust_monsters_scavenge, 2 (waste) | The Rust Monster | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| rust_monsters_scavenge, 3 (waste) | The Rust Monster | 100 / 100%, 1% | 100 / 100%, 0% | no decision |
| the_astromancer, 2 (waste) | The Astromancer | 42 / 96%, 19% | 100 / 100%, 0% | no decision |
| the_astromancer, 3 (waste) | The Astromancer | 28 / 92%, 29% | 97 / 100%, 1% | no decision |
| bone_wyverns_flight, 2 (marsh) | Bone Wyvern | 79 / 100%, 10% | 100 / 100%, 0% | no decision |
| bone_wyverns_flight, 3 (marsh) | Bone Wyvern | 71 / 100%, 15% | 100 / 100%, 0% | no decision |
| collectors_hall, 2 (marsh) | The Antiquarian | 59 / 100%, 19% | 100 / 100%, 4% | no decision |
| collectors_hall, 3 (marsh) | The Antiquarian | 43 / 100%, 27% | 98 / 100%, 5% | no decision |
| fell_riders_hunt, 1 (marsh) | The Fell Rider | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| fell_riders_hunt, 2 (marsh) | The Fell Rider | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| fell_riders_hunt, 3 (marsh) | The Fell Rider | 100 / 100%, 1% | 100 / 100%, 0% | no decision |
| skeleton_kings_court, 2 (marsh) | The Skeleton King | 1 / 55%, 68% | 92 / 100%, 10% | no decision |
| skeleton_kings_court, 3 (marsh) | The Skeleton King | 0 / 52%, 71% | 92 / 100%, 11% | no decision |
| the_reaper, 1 (marsh) | The Reaper | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| the_reaper, 2 (marsh) | The Reaper | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| the_reaper, 3 (marsh) | The Reaper | 100 / 100%, 0% | 100 / 100%, 0% | no decision |
| the_shambler, 2 (marsh) | The Shuffler | 91 / 100%, 4% | 100 / 100%, 0% | no decision |
| the_shambler, 3 (marsh) | The Shuffler | 84 / 100%, 8% | 100 / 100%, 0% | no decision |
| the_wild_hunt, 1 (marsh) | Rider of the Wild Hunt | 99 / 100%, 1% | 100 / 100%, 0% | no decision |
| the_wild_hunt, 2 (marsh) | Rider of the Wild Hunt | 93 / 100%, 3% | 100 / 100%, 0% | no decision |
| the_wild_hunt, 3 (marsh) | Rider of the Wild Hunt | 77 / 100%, 7% | 100 / 100%, 0% | no decision |
| cinder_tortoises_brood, 1 (peak) | Cinder Tortoise | 83 / 100%, 5% | 100 / 100%, 0% | too easy |
| cinder_tortoises_brood, 2 (peak) | Cinder Tortoise | 45 / 100%, 18% | 100 / 100%, 1% | no decision |
| cinder_tortoises_brood, 3 (peak) | Cinder Tortoise | 1 / 92%, 43% | 100 / 100%, 1% | no decision |
| firelords_rising, 2 (peak) | The Firelord | 12 / 80%, 41% | 100 / 100%, 1% | no decision |
| firelords_rising, 3 (peak) | The Firelord | 4 / 69%, 59% | 99 / 100%, 2% | no decision |
| the_bane, 2 (peak) | The Bane | 72 / 100%, 30% | 100 / 100%, 4% | no decision |
| the_bane, 3 (peak) | The Bane | 51 / 91%, 44% | 99 / 100%, 6% | no decision |
| the_ravener, 2 (peak) | The World Eater | 57 / 86%, 38% | 100 / 100%, 1% | no decision |
| the_ravener, 3 (peak) | The World Eater | 27 / 72%, 54% | 100 / 100%, 1% | no decision |
| thunder_apes_rampage, 1 (peak) | The Thunder Ape | 100 / 100%, 1% | 100 / 100%, 0% | no decision |
| thunder_apes_rampage, 2 (peak) | The Thunder Ape | 100 / 100%, 2% | 100 / 100%, 0% | no decision |
| thunder_apes_rampage, 3 (peak) | The Thunder Ape | 95 / 100%, 6% | 100 / 100%, 0% | no decision |

Read. Against the fours every cell is a free win: random play wins 79 to 100% and greedy 100%
at 0 to 24% hull, the Old Man of the Desert the only elite that costs a four more than a tenth
of its hull (15 to 24%). Greedy's fights last two to six rounds; the Goblin Nob and the Thunder
Ape die in two at tier three, before a bellow or a roar can matter. Against the stock trios the
lone elites read the same: the Nob, the Fell Rider, the Reaper, the Rust Monster, the Thunder
Ape, the Goblin Shaman's warband and Gilgamesh are won by random play 95 to 100% of the time at
0 to 2% hull, at every tier, since their HP is the rank and file's (8 to 24 at tier one, 12 to 36
at tier three) against a trio's twenty-odd damage a round. The fights that are fights for a
trio have mass or bodies: the Old Man (massive, 44 HP: a decision at tier one, 11 and 81% won at
60% hull, and a wall at tier three, 0 and 25%); the Skeleton King's court (its summons and its
risers: random 0 to 1%, greedy about half, 68 to 71% hull); the Firelord (12 and 80%, 4 and 69%);
the World Eater (57 and 86%, 27 and 72%); the Cinder Tortoise at tier three (1 and 92%); the
Astromancer (42 and 96%, 28 and 92%: its orbs the kill order); the Bane, the Antiquarian and the
Elder Treant at tier three (random about half). Bands: of the 53 cells read on their tier's rows,
49 read as no decision, 3 as too easy (the Cinder Tortoise at tier one for the trios; the Old Man
at tiers two and three for the fours) and 1 as a decision (the Old Man at tier one for the
trios); no elite is a wall for its tier's rows. What it says: the elites as built are not the
mini-boss event section 9 asks for (a harder fight that threatens the gate while it holds the
team); their numbers are the placeholders of 3 November, set at the hunters' and the rank and
file's band, and an elite that dies in two rounds never shows its mechanism. The lever on the
table, Ryan's to mark (the bible's section 12): the lone elites' HP to the massive band (the
scales row's 30 to 40 at tier one, where the Old Man and the World Eater stand), an escort each,
or both; read below as a what-if, and at 200 seeds once marked.

What-if, the same evening: every elite below 40 HP at 40 (`--set foes/<id>/hp=40`: the Leshy,
the Goblin Shaman, the Goblin Nob, the Rust Monster, the Astromancer, the Bone Wyvern, the
Antiquarian, the Fell Rider, the Skeleton King, the Reaper, the Shuffler, the Bane and the Thunder
Ape) and the Wild Hunt's riders at 16, the same rows, random and greedy, 30 seeds, a direction (38
and 63 minutes). The rows the what-if left alone (the Elder Treant, Gilgamesh, the Old Man, the
Pilgrim, the Cinder Tortoise, the Firelord and the World Eater, at 40 to 44 already) read the same
and are left out of the table.

| Composition, tier | Lead (HP as built, at the what-if) | Trios as built: random / greedy won, hull lost (greedy), rounds | Trios at the what-if | Fours as built | Fours at the what-if | Band as built, at the what-if (its tier's rows) |
|---|---|---|---|---|---|---|
| leshys_hunt, 2 (meadow) | Leshy (8, 40) | 99 / 100%, 0%, 2.9 | 88 / 100%, 3%, 7.4 | 100 / 100%, 0%, 2.0 | 100 / 100%, 0%, 3.7 | no decision, no decision |
| leshys_hunt, 3 (meadow) | Leshy (8, 40) | 98 / 100%, 0%, 3.2 | 79 / 100%, 4%, 8.7 | 100 / 100%, 0%, 2.2 | 100 / 100%, 0%, 4.1 | no decision, no decision |
| shamans_warband, 1 (meadow) | Goblin Shaman (8, 40) | 100 / 100%, 1%, 3.5 | 98 / 100%, 4%, 6.3 | 100 / 100%, 0%, 2.5 | 100 / 100%, 0%, 3.9 | no decision, no decision |
| shamans_warband, 2 (meadow) | Goblin Shaman (8, 40) | 100 / 100%, 1%, 3.6 | 98 / 100%, 5%, 7.3 | 100 / 100%, 0%, 2.7 | 100 / 100%, 0%, 4.3 | no decision, no decision |
| shamans_warband, 3 (meadow) | Goblin Shaman (8, 40) | 100 / 100%, 2%, 3.8 | 92 / 100%, 14%, 8.7 | 100 / 100%, 0%, 2.8 | 100 / 100%, 0%, 4.7 | no decision, no decision |
| the_nob, 1 (meadow) | The Goblin Nob (24, 40) | 100 / 100%, 0%, 2.7 | 100 / 100%, 1%, 4.0 | 100 / 100%, 0%, 1.6 | 100 / 100%, 0%, 2.2 | no decision, no decision |
| the_nob, 2 (meadow) | The Goblin Nob (24, 40) | 100 / 100%, 0%, 3.1 | 96 / 100%, 2%, 5.0 | 100 / 100%, 0%, 1.8 | 100 / 100%, 0%, 2.6 | no decision, no decision |
| the_nob, 3 (meadow) | The Goblin Nob (24, 40) | 100 / 100%, 1%, 3.8 | 80 / 100%, 5%, 6.0 | 100 / 100%, 0%, 2.1 | 100 / 100%, 0%, 3.0 | no decision, no decision |
| rust_monsters_scavenge, 1 (waste) | The Rust Monster (20, 40) | 100 / 100%, 0%, 2.5 | 100 / 100%, 1%, 4.3 | 100 / 100%, 0%, 1.4 | 100 / 100%, 0%, 2.3 | no decision, no decision |
| rust_monsters_scavenge, 2 (waste) | The Rust Monster (20, 40) | 100 / 100%, 0%, 2.9 | 100 / 100%, 4%, 5.2 | 100 / 100%, 0%, 1.6 | 100 / 100%, 0%, 2.6 | no decision, no decision |
| rust_monsters_scavenge, 3 (waste) | The Rust Monster (20, 40) | 100 / 100%, 1%, 3.2 | 98 / 100%, 8%, 6.3 | 100 / 100%, 0%, 1.8 | 100 / 100%, 0%, 3.0 | no decision, no decision |
| the_astromancer, 2 (waste) | The Astromancer (24, 40) | 42 / 96%, 19%, 8.2 | 22 / 90%, 31%, 12.0 | 100 / 100%, 0%, 3.7 | 97 / 100%, 1%, 4.6 | no decision, no decision |
| the_astromancer, 3 (waste) | The Astromancer (24, 40) | 28 / 92%, 29%, 9.8 | 3 / 82%, 44%, 14.3 | 97 / 100%, 1%, 4.2 | 93 / 100%, 1%, 5.3 | no decision, no decision |
| bone_wyverns_flight, 2 (marsh) | Bone Wyvern (32, 40) | 79 / 100%, 10%, 7.4 | 76 / 100%, 12%, 9.1 | 100 / 100%, 0%, 3.4 | 100 / 100%, 1%, 3.8 | no decision, no decision |
| bone_wyverns_flight, 3 (marsh) | Bone Wyvern (32, 40) | 71 / 100%, 15%, 8.9 | 64 / 100%, 19%, 10.9 | 100 / 100%, 0%, 3.7 | 100 / 100%, 1%, 4.3 | no decision, no decision |
| collectors_hall, 2 (marsh) | The Antiquarian (24, 40) | 59 / 100%, 19%, 5.1 | 33 / 99%, 32%, 7.7 | 100 / 100%, 4%, 2.7 | 99 / 100%, 6%, 3.5 | no decision, no decision |
| collectors_hall, 3 (marsh) | The Antiquarian (24, 40) | 43 / 100%, 27%, 5.8 | 19 / 91%, 49%, 9.1 | 98 / 100%, 5%, 3.0 | 91 / 100%, 8%, 4.0 | no decision, no decision |
| fell_riders_hunt, 1 (marsh) | The Fell Rider (16, 40) | 100 / 100%, 0%, 1.8 | 100 / 100%, 2%, 4.0 | 100 / 100%, 0%, 1.2 | 100 / 100%, 0%, 2.2 | no decision, no decision |
| fell_riders_hunt, 2 (marsh) | The Fell Rider (16, 40) | 100 / 100%, 0%, 2.4 | 100 / 100%, 5%, 4.9 | 100 / 100%, 0%, 1.4 | 100 / 100%, 0%, 2.6 | no decision, no decision |
| fell_riders_hunt, 3 (marsh) | The Fell Rider (16, 40) | 100 / 100%, 1%, 2.7 | 98 / 100%, 11%, 6.0 | 100 / 100%, 0%, 1.6 | 100 / 100%, 0%, 3.0 | no decision, no decision |
| skeleton_kings_court, 2 (marsh) | The Skeleton King (28, 40) | 1 / 55%, 68%, 9.0 | 0 / 47%, 73%, 10.4 | 92 / 100%, 10%, 4.3 | 91 / 100%, 11%, 5.1 | no decision, no decision |
| skeleton_kings_court, 3 (marsh) | The Skeleton King (28, 40) | 0 / 52%, 71%, 9.8 | 0 / 42%, 77%, 11.3 | 92 / 100%, 11%, 4.6 | 86 / 100%, 12%, 5.5 | no decision, too easy |
| the_reaper, 1 (marsh) | The Reaper (12, 40) | 100 / 100%, 0%, 1.5 | 100 / 100%, 4%, 4.0 | 100 / 100%, 0%, 1.1 | 100 / 100%, 0%, 2.2 | no decision, no decision |
| the_reaper, 2 (marsh) | The Reaper (12, 40) | 100 / 100%, 0%, 1.7 | 100 / 100%, 8%, 4.8 | 100 / 100%, 0%, 1.2 | 100 / 100%, 0%, 2.6 | no decision, no decision |
| the_reaper, 3 (marsh) | The Reaper (12, 40) | 100 / 100%, 0%, 2.1 | 97 / 100%, 13%, 5.8 | 100 / 100%, 0%, 1.3 | 100 / 100%, 1%, 3.0 | no decision, no decision |
| the_shambler, 2 (marsh) | The Shuffler (32, 40) | 91 / 100%, 4%, 5.0 | 86 / 100%, 8%, 6.1 | 100 / 100%, 0%, 2.3 | 100 / 100%, 0%, 2.7 | no decision, no decision |
| the_shambler, 3 (marsh) | The Shuffler (32, 40) | 84 / 100%, 8%, 5.9 | 72 / 100%, 15%, 7.5 | 100 / 100%, 0%, 2.6 | 100 / 100%, 0%, 3.1 | no decision, no decision |
| the_wild_hunt, 1 (marsh) | Rider of the Wild Hunt (10, 16) | 99 / 100%, 1%, 2.9 | 90 / 100%, 3%, 4.4 | 100 / 100%, 0%, 2.1 | 100 / 100%, 0%, 2.5 | no decision, too easy |
| the_wild_hunt, 2 (marsh) | Rider of the Wild Hunt (10, 16) | 93 / 100%, 3%, 3.8 | 68 / 99%, 10%, 5.7 | 100 / 100%, 0%, 2.2 | 100 / 100%, 0%, 3.0 | no decision, no decision |
| the_wild_hunt, 3 (marsh) | Rider of the Wild Hunt (10, 16) | 77 / 100%, 7%, 4.3 | 48 / 99%, 22%, 6.9 | 100 / 100%, 0%, 2.4 | 100 / 100%, 1%, 3.4 | no decision, no decision |
| the_bane, 2 (peak) | The Bane (36, 40) | 72 / 100%, 30%, 6.5 | 67 / 99%, 34%, 7.3 | 100 / 100%, 4%, 2.9 | 100 / 100%, 5%, 3.2 | no decision, no decision |
| the_bane, 3 (peak) | The Bane (36, 40) | 51 / 91%, 44%, 8.1 | 40 / 87%, 51%, 9.1 | 99 / 100%, 6%, 3.3 | 99 / 100%, 6%, 3.6 | no decision, no decision |
| thunder_apes_rampage, 1 (peak) | The Thunder Ape (24, 40) | 100 / 100%, 1%, 2.8 | 98 / 100%, 4%, 4.5 | 100 / 100%, 0%, 1.6 | 100 / 100%, 0%, 2.3 | no decision, no decision |
| thunder_apes_rampage, 2 (peak) | The Thunder Ape (24, 40) | 100 / 100%, 2%, 3.2 | 92 / 100%, 7%, 5.6 | 100 / 100%, 0%, 1.9 | 100 / 100%, 0%, 2.6 | no decision, no decision |
| thunder_apes_rampage, 3 (peak) | The Thunder Ape (24, 40) | 95 / 100%, 6%, 4.1 | 77 / 99%, 16%, 6.8 | 100 / 100%, 0%, 2.2 | 100 / 100%, 0%, 3.1 | no decision, no decision |

Read. Against the fours nothing moves: random play still wins 86 to 100% and greedy 100% at 0 to
12% hull, and greedy's fights grow by about a round, the lone elites from one or two rounds to two
or three (the Reaper 1.1 to 2.2, the Fell Rider 1.2 to 2.2, the Nob 1.6 to 2.2, the Thunder Ape
1.6 to 2.3); the Skeleton King's court at tier three (random 92 to 86%) and the Wild Hunt at tier
one for the trios (99 to 90%) cross the band rule's line into too easy by a few points of random,
within a direction's noise, so the bands read 47 no decision, 1 decision and 5 too easy where they
read 49, 1 and 3. Against the trios the lone elites still fall to random play 77 to 100% and to
greedy 99 to 100% at 1 to 16% hull, their fights grown from two rounds to four (the Reaper 1.5 to
4.0, the Nob 2.7 to 4.0, the Fell Rider 1.8 to 4.0), so a bellow or a roar gets a round to show;
the cells that move most have bodies, or a mechanism the rounds feed: the Astromancer (random 42
to 22% at tier two and 28 to 3% at tier three, greedy 96 to 90% and 92 to 82% at 31 and 44% hull,
its orbs with the rounds to call and to mend), the Antiquarian (59 to 33%, 43 to 19%), the Wild
Hunt (93 to 68%, 77 to 48%) and the Thunder Ape at tier three (95 to 77%). What it says: HP alone
buys rounds, not threat. A lone elite at 40 HP is still a free win for its tier's squad, since its
blow (3 to 7 a round, at one machine) is a rank-and-file's damage against a four's hull and
shields; the HP lets its mechanism fire once before it dies. What makes a fight in this table is
damage at the squad over several rounds: bodies (the Skeleton King's court, the Firelord's sons,
the Astromancer's orbs) or a massive foe's blow (the Old Man, the World Eater). So the lone elite as
the harder fight section 9 asks for wants the massive band in both numbers (the scales row: a blow
of 7 or 8 with the 30 to 40 HP), an escort each, or its curveball read on the map (the hunter's
catch, the World Eater's push), which no cell reads; the HP alone is not the lever. Ryan's to mark
(the bible's section 12), then the 200-seed read.

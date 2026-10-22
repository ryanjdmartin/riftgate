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
`docs/briefs/stock_pass.md`, applied by script to a scratch checkout of the branch: every
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

**The loops on the landed content** (`docs/briefs/stock_pass.md`, section 7, step 2; the branch
at `d4e009a`, Flak's clock a field since `9c32ecf`). Each loop is a copy of the branch with its
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

A single wildlife pack costs no team anything under either. Kept: the blows (the brief's first
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

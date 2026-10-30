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
opened at (Ryan's locked tier, `docs/curve_proposal.md`). 2,000 seeds. A model of the
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
battles. Dropped (`docs/curve_proposal.md`).

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

**The sizes the fresh start's proposal sizes its compositions against** (`docs/foes_proposal.md`;
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

**The runner work the fresh start's session built without waiting** (`docs/foes_proposal.md`,
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

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
200, the Polar Bear's about 130 (with the discharge still in), the Nemesis's about 110 (the
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

**The Faraday Hull.** The lone Polar Bear, 50 seeds a cell, random and greedy win rates averaged
over twenty packs (a row mean): 85 and 92 with the discharge, 64 and 85 without, 72 and 85 with
one Shocked foe a round. Without the discharge the Polar Bear stands at the Wild Boar's level
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
Polar Bear and the Prairie Dog; every team wins everything for 5 to 7% of its hull; a team's foes
reach its hull 0.15 times a round. Bible section 7.

**The shield rule.** Letting every blow's excess past a standing shield: the machines' mean win
rate 46 to 45 (greedy, 30 seeds a cell, a mean over every machine and pack). Bible section 5.

**Armour lowered.** Every chassis's armour 5 lower, then 10, greedy, 30 seeds a cell. The team
rows move by a point or two of hull (the Minerva team 1 to 3%) at 5, up to 5% at 10, every team
still winning every single pack. Alone (directions): the Polar Bear 88 to 79, then 58; the Wild
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
66 to 21); the Marsh's formation turned from a free win into a decision for the Polar Bear
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
| Polar Bear and Baboon | 99/100 | 98/100 | 49/86 | 7%, 10%, 58% |
| Clydesdale and Prairie Dog | 82/99 | 77/100 | 0/26 | 9%, 8%, 91% |
| Nemesis and Puffin | 73/98 | 42/96 | 5/50 | 20%, 36%, 84% |
| The starting trio | 100/100 | 100/100 | 86/100 | 2%, 4%, 20% |
| Badger, Clydesdale, Sparrowhawk, Polar Bear | 100/100 | 100/100 | 100/100 | 1%, 2%, 8% |
| Polar Bear, Baboon, Nemesis, Puffin | 100/100 | 100/100 | 92/100 | 0%, 0%, 9% |

Read: a formation costs a pair about 1.1 machines' worth of hull, a trio 0.6, a four 0.3, and
a pair loses a formation outright one fight in four to one in two (the Peak's against the
Polar Bear and the Baboon 43%, the Marsh's against the Badger and the Sparrowhawk 75%). Two
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

The roster that day, for scale: the Polar Bear 92, the Wild Boar 83, the Nemesis 72, the Badger
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
tags win 52 to 83, sharing three 86, all under the Polar Bear's 92, and Bold's armour 20 puts
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
| Polar Bear | 79.0 / 94.7 | 25.9 / 39.0 | 25.9 / 39.3 |
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
directions at one cell's band. The Polar Bear alone falls from the top of the table to the middle
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
Summoner's nearly always; the Clydesdale, the Polar Bear, the Funnel-web, the Buzzard and the
Cottonmouth take a few; the rest lose nearly all of them. The new rows: the Whip Scorpion in the
Nemesis's band (the Bombs 91 / 100, the Drakes 100 / 100), the Cassowary among the weakest alone
(its Spin-Up and its Coolant Jacket never picked: the bot turns the dial and never plans, the
to-do's line). The heat section, new: the Whip Scorpion peaks at 83% of its maximum, the Kite
79%, the Polar Bear 74% with 0.73 overheats a fight, and the Kestrel team holds back 0.72
damaging dice a fight for heat; the stock pass's heat re-pricing reads these.

**The campaign's wall, found** (the to-do's line of 21 October; `docs/campaign_run.md`
regenerated on main, `32c438ab`). A bisect at three runs a probe (`tools/campaign_run.gd --runs
3`, seeds 1 to 3: 27% of 36 battles won on the 13 October report's commit `b15e2707`, none of 29
on main) lands on the Polar Bear's rework (`fdb8d6c1`, 20 October: 3% of 33), its parent the
merge of main into the Minerva branch (`63487a9c`: 27% of 36). Forty runs either side: 12 of 40
runs won and 27% of 459 battles before it, 1 of 40 and 5% of 391 after. Before it the Polar Bear
started 20 runs and won 11, the other 20 won one; after it the Polar Bear's won none and the rest
still one, so the rework took the Polar Bear's runs and nothing else. Forty runs on main's line
after it: 4% of 391 battles on the Minerva merge (`459ada33`), 1% of 374 after Flak and the
shield rule (`9ac36662`), 1% of 373 with the day's engines and the party (`899a7725`), and 0 of
40 runs, one battle in 348, from the Kestrel merge on (`eee55775`, and main), where the tender
the draft deals from has changed under the same seeds (the Puffin at tier one, the Cassowary and
the Cottonmouth dealt, the Kite and the Dingo gone to tier two). On main, 572 of 734 fights hold
one machine; one machine against one pack wins 31% (64% on 13 October), two together 64 to 76%.

Read: no bug. The old Polar Bear was the one machine that carried a lone fight (alone 79 / 95
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
Polar Bear 74%, the Nemesis 71%), overheat under once a fight (the Polar Bear 0.73, the rest under
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
| A massive foe, a round or two of focus | a team of three takes 3.4 to 6.2 rounds greedy on the Treant and the Wyvern, 4.7 to 11.5 on the Sandworm, 5.2 to 10.4 on the Golem; alone, the Polar Bear, the Boar, the Swallowtail and the Musk Ox stall past sixty rounds on the Treant and the Wyvern, whose regrow of 5 outpaces what their blows leave past armour 1 | fails by two to five times |
| The coordination gap, about 2 on the big foes, none on the rank and file | the teams 1.39 to 1.56 on the big fights and 1.23 to 1.55 on the rank and file | 1.40 to 1.63 and 1.35 to 1.60: unchanged, and the same on both kinds |
| Wear, about four hard fights unwithdrawn | a team loses 0.2 to 1.5% of its hull on a wildlife pack, 8 to 22% on a massive foe, 2.5 to 12% on a formation, 0.2 to 1.8% on a final | 0.2 to 4.8%, 8 to 42%, 7 to 84%, 1.5 to 11% |
| A hot kit overheats by its third round | the Kite peaks at 101% and overheats 0.88 a fight, the Baboon 83% and 0.82, the Nemesis 90% and 0.46, the Stingray 72%, the Whip Scorpion 70%; the other fifteen rows peak at 11 to 49% and hold no die for heat | the Scorpion 81%, the Kite 79%, the Polar Bear 74%, the Nemesis 71%, the rest cold |

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
(`--packs`; the bosses fight in no other cell). The kept levers were `tools/stock_fills.py`'s
fills since (the script retired 12 November: `git show 27956e7:tools/stock_fills.py`). Directions, read as bands against the tests (the bible's section 2).

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
| Polar Bear | 25.9 / 39.3 | 28.2 / 37.4 |
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
baseline's hottest were the Whip Scorpion 81%, the Kite 79%, the Polar Bear 74% and the Nemesis
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
for the Polarity Projector, the Clydesdale's Twin Autoguns for the Flak Cannon, the Polar Bear's
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
the Polar Bear; the Puffin; the Prairie Dog, the Cassowary or the Cottonmouth; the Baboon or the
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
Polar Bear, the Puffin and the Prairie Dog the lowest. By tender (one tier-one machine a city
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
| Polar Bear | 40 / 8 / 2 | 35% | 41% | 49% | 43% |
| Stingray | 24 / 12 / 0 | 35% | 34% | 31% | 33% |
| Puffin | 20 / 8 / 0 | 32% | 30% | 28% | 30% |
| Cassowary | 24 / 8 / 0 | 31% | 30% | 28% | 31% |
| Prairie Dog | 20 / 10 / 0 | 30% | 28% | 27% | 27% |
| Cottonmouth | 20 / 8 / 0 | 29% | 29% | 26% | 28% |

By kind of fight, with all three standing: the rank and file and the formations spread 28 to
39%; the breaching bosses (the Golem, the Sandworm) 30 to 39%, every shield failing their blow
so the draw is near level; the Treant and the Wyvern put 47% on the Polar Bear and 44% on the
Honey Badger, 23 to 33% on the rest. Their blow of 7 is held by a standing shield, so the draw
follows whichever shield is down, and the tanks' shields hold it least often (38 and 56% of
the picks, the rest 63 to 81%).

Read: the aim does not pile blows on thick machines while the team stands; the lean to the
tanks comes from their outliving the light machines (every pick after a wreck lands on a
survivor), from the Polar Bear's Lure (its share of the swings the highest), and against the
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
  Meteor Artillery, Corona Shield; Susceptibility Tensor, Flak Skirt), the Polar Bear (Proximity
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
to 33 and 47% (20 and 10% at ×3); the two Polar Bear and Puffin trios, already hard at ×1 (23
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
| Polar Bear | 25 / 33 | 41 / 55 | 0 / 0 | 0 / 0 | 77% |
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
report: the Honey Badger 11 (9), the Baboon 15 (18), the Polar Bear 17 (20), the Prairie Dog 10
(12), the Stingray 10 (14), the Puffin 16 (28), the Cassowary 16 (12), the Cottonmouth 10 (7),
the Skua 15 (not dealt then). On 22 October the tender and the run drew one stream, so the
runner's pick of three reread Minerva's offer: the Polar Bear started every run it was offered
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

The other six (the Skua, the Baboon, the Polar Bear, the Stingray, the Cassowary, the Puffin)
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
a four-machine team (Badger, Clydesdale, Sparrowhawk, Polar Bear) against six goblins and three
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
the Boar 15 / 53 to 100 / 100, the Polar Bear 0 / 0 to 46 / 100); the Bombs -8 / -8, the
Salamanders -4 / -8, the Drakes -3 / -4 (the Polar Bear against the Drakes 94 / 100 to 51 / 65,
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
  walling the Polar Bear against the Drakes.
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
Beam and the Airburst Shell); a four without an area piece (the Polar Bear, the Cassowary, the
Skua, the Puffin); a four with two carriers (the Honey Badger, the Cottonmouth, the Cassowary,
the Puffin); a trio without (the Polar Bear, the Cassowary, the Puffin); a trio with (the Honey
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
starting team; the Polar Bear, the Cassowary and the Puffin without an area piece; the Honey
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
| Minerva's team (Honey Badger, Polar Bear, Wild Boar) | 100 | 4.9 | 7% | 31% | 0.05 | 0.01 |
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
| Minerva's | Polar Bear | Twin Autoguns | 13% | 4.9 to 5.1 | 7 to 8% |
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

The rows without an area piece (the four of the Polar Bear, the Cassowary, the Skua and the
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
87 / 3.2 / 34, the Skua 65 / 3.7 / 47, the Polar Bear 64 / 10.5 / 57, the Baboon 58 / 5.6 / 58,
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
0.44 (1.15). On every read the plain player wins no run, as since the Polar Bear's rework, and the
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
ones (the Honey Badger, the Baboon, the Polar Bear, the Prairie Dog). The bosses as built, at 80
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
Petrel alone and beside the Puffin, its magazine, each against the Polar Bear, the other tier-one
body, in the same run; the Giant Petrel in two teams of four against the same three with another
machine in its place. `tools/balance.gd`, 30 seeds a cell (a direction), random and greedy, no
party, the matrix's 55 packs as it stands (the thirteen tier-one packs, the ladder's twenty-six
recolours, the four big foes and the twelve formations), on Godot 4.7.2 (the session's hook
installed it on the old head; the 4.8-beta2 build's unpacking and first run were refused by Auto
mode, and the headless sim reads no renderer). Won, random / greedy, then greedy's hull lost and
rounds to a win.

**The Storm Petrel alone**, beside the Polar Bear:

| Row | Every pack | Tier-one rank and file (13) | Tiers two and three (26) | The four big foes | The twelve formations | Hull lost | Rounds won |
|---|---|---|---|---|---|---|---|
| Storm Petrel | 32 / 45 | 52 / 66 | 42 / 61 | 0 / 0 | 0 / 0 | 63% | 4.9 |
| Polar Bear | 25 / 38 | 48 / 65 | 29 / 49 | 0 / 0 | 0 / 0 | 75% | 9.7 |

Pick share (greedy): the Laser Carbine 31%, the St. Elmo's Regenerator 24%, the Canopy 20%, the
Ankle Mortar 15%, the Twin Autoguns 9%. Its heat peaks at a tenth of its gauge (the Polar Bear's
41%), 0.04 overheats a fight. The first run of the day, before the bot valued the regen, read the
row 32 / 46 with the Regenerator spent 4% of the time: valuing it moved the lock's share and not
the row.

Read: alone it stands in the Polar Bear's band and above it on the ladder's recolours, winning in
half the rounds; every tier one alone is walled by the big foes and the formations, and so is it.
On its stock the burn is a trickle: the Carbine's 2 is the most any basic burns, and the gauge
never sees it, so its identity shows at the size of its basics' heat (the bible's section 12 holds
the question).

**Beside the Puffin**, the same two bodies:

| Row | Every pack | Tier-one rank and file | Tiers two and three | The four big foes | The twelve formations | Hull lost | Rounds won |
|---|---|---|---|---|---|---|---|
| Storm Petrel + Puffin | 53 / 66 | 85 / 94 | 68 / 84 | 4 / 51 | 0 / 2 | 39% | 4.5 |
| Polar Bear + Puffin | 47 / 62 | 77 / 93 | 60 / 78 | 0 / 32 | 0 / 8 | 46% | 6.5 |

Pick share (greedy, the Storm Petrel's pair): the Laser Carbine 31%, the Twin Autoguns 24%, the
Regenerator 13%, the Halo Shield 10%, the Ankle Mortar 10%, the Canopy 6%, the Backwash Ionizer 3%.

Read: the escort pair reads a few points over the Polar Bear's on the rank and file and about half
again on the big foes (51% against 32%, in a third the rounds), for less hull; the Polar Bear's pair
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
four (Honey Badger, Baboon, Polar Bear, Prairie Dog, stock kits) against each of its trios, the
same kit a machine short, over the twelve bosses at tier one:

| Row | Won | Mean rounds of the fights won | Hull lost |
|---|---|---|---|
| The stock four | 100% | 8.6 (7.0 to 12.1) | 2.4% |
| Less the Polar Bear | 100% | 10.3 | 8.0% |
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
(the Polar Bear, the Prairie Dog, the Badger, the Baboon), each with its tier-zero kit, so a
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
| The Polar Bear (beside the old Badger) | 16 / 27 | 37 / 56 | 15 / 30 | 11 / 15 | 0 / 0 | 83% | 10.2 |

The lone foes the change moved most, random / greedy: the Treant 3 / 67 as it was, 97 / 100 as
proposed, 83 / 100 at the first fallback, 53 / 100 at the second; the Bone Dragon 3 / 77, 97 /
100, 83 / 100, 57 / 100; Gilgamesh 7 / 93, 100 / 100, 100 / 100, 80 / 100; the Bourgeon 0 / 0, 100
/ 100, 100 / 100, 67 / 100. The rounds to beat the Treant fell from 27 to 10.

**The Minerva team** (the Badger, the Polar Bear, the Wild Boar):

| Row | Every pack | Tier-one rank and file | Tiers two and three, the party | Lone big foes and bosses | Formations | Hull lost | Rounds won |
|---|---|---|---|---|---|---|---|
| The old Badger | 84 / 92 | 99 / 100 | 92 / 96 | 92 / 100 | 38 / 63 | 16% | 4.6 |
| As proposed | 86 / 94 | 100 / 100 | 93 / 97 | 96 / 100 | 38 / 73 | 13% | 4.1 |
| As proposed, shield 6 | 86 / 94 | 100 / 100 | 93 / 97 | 96 / 100 | 38 / 73 | 13% | 4.1 |
| First fallback | 86 / 94 | 100 / 100 | 93 / 97 | 96 / 100 | 38 / 72 | 14% | 4.1 |

Read: the plate carries it. With no plate it reads at the old Badger's line, a claw of 2 a strike
takes four or five points off, its shield at 6 a point or two; a point a load lifts it eighteen
points greedy and random play past half the lone big foes, which the old Badger and the Polar Bear
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

## 2 November, the Polar Bear at tier one

**Is the Polar Bear too much of a wall for tier one?** (Ryan's play test of 2 November: "armadillo
is probably too much of a wall for tier 1. It's very good at its job.") The balance runner,
greedy, 30 seeds a cell (a direction), the tier-one packs and formations (`--packs` the seventeen
of tier one: each spawn-table pack at its strength and each domain's tier-one formation;
`--noparty`): the Polar Bear alone beside three tier-one peers (the Storm Petrel, the Baboon, the
Cassowary) and the Honey Badger; then a starter trio, the Honey Badger and the Skua with the
Polar Bear in the middle seat, beside the same trio with each peer there; then three what-ifs on
the Polar Bear's trio, its Lockdown's armour 3 to 2 (`--set
chassis/armadillo/passive/effects/0/value=2`), its base armour 2 to 1, and both. About twenty
minutes on two cores, from a frozen copy of `3929042`'s tree (this branch's base, the engine as main has it).

The trios' hull lost, mean of every fight (greedy):

| Trio (Honey Badger, X, Skua) | Rank and file (13 packs) | Meadow formation | Waste | Marsh | Peak |
|---|---|---|---|---|---|
| Polar Bear | 0 to 2%, the Zombie Knights 28% | 6% | 6% | 82% | 8% |
| Storm Petrel | 0 to 2%, the Zombie Knights 25% | 4% | 4% | 83% | 4% |
| Baboon | 0 to 2%, the Zombie Knights 19% | 10% | 7% | 78% | 8% |
| Cassowary | 0 to 1%, the Zombie Knights 33% | 13% | 8% | 94% | 12% |
| Polar Bear, Lockdown +2 | as the Polar Bear's | 6% | 6% | 82% | 8% |
| Polar Bear, armour 1 | as the Polar Bear's | 9% | 6% | 81% | 9% |
| Polar Bear, both | as the Polar Bear's | 9% | 6% | 81% | 9% |

Alone, the Polar Bear kills slowly and loses hull on most tier-one packs (98% on the goblins and the
revenants, 88% on the gels, 100% on every formation), the slowest of the five rows (5.6 to 27.9
rounds won where the Badger takes 2.3 to 10). In the trio, the Canopy is 6% of the spends (26%
alone): the greedy bot rarely seals in a team, so the runner barely reads Lockdown at all (its
+2 what-if moves no trio cell).

Read:

- **Every starter trio walls tier one's rank and file**: none loses more than 2% hull on any of the
  thirteen packs but the Zombie Knights, whoever sits in the middle seat; the formations take 4% to
  13% but the Marsh's (about 80%, its Zombie Knights). On the bot's play the Polar Bear's trio sits
  in the band, and the Storm Petrel's takes less.
- **The seal is where the bot cannot look**: sealed, the Polar Bear's armour is 5 against tier-one
  blows of 2 or 3 (the rank and file's), so once its shield is down a sealed Polar Bear takes
  nothing from them; the greedy bot spends the Canopy on itself too rarely in a team to show it.
  Ryan's read is of play the runner does not make, so the runner neither confirms it nor clears
  it; the arithmetic agrees with him for a sealed Polar Bear against the rank and file.
- **A smaller seal does not reach the root**: at Lockdown +2 the sealed armour is 4, still over
  every tier-one rank-and-file blow; flat armour at or over a tier's blows is immunity at any
  number. The question is the bible's section 12 (the Polar Bear at tier one).

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
| Polar Bear, old bot | 37 / 56 | 0 / 0 | 0 / 0 | 22 / 36 | 0 / 0 | 0 / 0 | 16 / 26 | 83% | 9.8 |
| Polar Bear, new | 37 / 56 | 0 / 0 | 0 / 0 | 22 / 36 | 0 / 0 | 0 / 1 | 16 / 27 | 83% | 9.9 |
| Giant Petrel, old bot | 49 / 76 | 3 / 32 | 0 / 0 | 38 / 62 | 0 / 0 | 1 / 20 | 26 / 46 | 67% | 4.8 |
| Giant Petrel, new | 49 / 76 | 3 / 29 | 0 / 0 | 38 / 62 | 0 / 0 | 1 / 17 | 26 / 46 | 67% | 4.7 |
| Musk Ox, old bot | 81 / 79 | 2 / 19 | 0 / 0 | 55 / 64 | 0 / 0 | 14 / 54 | 41 / 52 | 64% | 7.1 |
| Musk Ox, new | 81 / 79 | 2 / 21 | 0 / 0 | 55 / 65 | 0 / 0 | 14 / 51 | 41 / 53 | 64% | 6.9 |

Spends, greedy: the Polar Bear's two Cryo Flingers 9% of its spends on the old bot, 13% on the new; the Giant
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


## 6 November, the long wall's Phase 1 reads

The reads the long wall's build brief asks for (`git show 68381ff:docs/briefs/long_wall_build.md`, section 10), on
`ccr-56b5169d-lsa2rg` with Phase 1 built: the field 20 by 12 at every Convergence; the tide (the
beat 3 turns, 2 from Convergence 8, the siege a turn short of its first peak at the start, the
beat halved at the Rupture); a pusher's segment of the wall; one pack one fight from beside it;
no withdrawal; the shield full at every fight's start, with the shield regen at zero everywhere;
the threat rating (a patrol 1, a formation 3, an elite and the boss 4); the rerolls at two. Every
new number is a placeholder (the table at the end). Each read is a direction and called one: 40
runs of the campaign runner on the steppe, 30 seeds of the balance runner, 200 maps of the survey.

### The campaign runner: 40 runs on the steppe

`tools/campaign_run.gd -- --runs 40 --shape steppe` (139 s): the greedy rung, each run the draft's
three machines of its tender at random, the defence rule on the map (the brief's section 5: a
hunter's catch first, then each machine onto the pack it can stand beside that reaches the wall
soonest, ties by the larger rating and then the nearer, the rest walking toward the soonest,
never the sealed boss, every fight fought out).

| Measure | Mean | Range |
|---|---|---|
| Runs won | 0 of 40 | |
| Turns a run | 5.72 | 5 to 8 |
| The turn the first city fell | 0.50 | 0 to 2 |
| Battles: won, held after a wipe, fell | 1%, 12%, 86% of 185 | |
| Battles ended in a team wipe | 97% | |
| Machines wrecked a battle | 1.76 | 0 to 3 |
| Phases a battle | 5.64 | 1 to 12 |
| Gate damage a battle | 134 | 0 to 200 |
| Peaks of Rift Pressure a battle | 0.94 | 0 to 7 |
| Compositions the rift sent a battle | 0.94 | 0 to 7 |
| Patrols the tears sent a battle | 1.25 | 0 to 21 |
| Tears open at a battle's end | 0.94 | 0 to 7 |
| Elites spawned a battle | 0.34 | 0 to 1 |
| Fractures reached a battle (of 3.01 held) | 0.75 | 0 to 3 |
| Battles reaching the Rupture | 14% | |
| Of those, by the stall guard | 0% | |
| The turn the seal broke, where it did | 3.37 | 2 to 6 |
| Stalemate fights (ten rounds with no foe's HP, hull or shield changed) | 0 | |
| Fights stalled past the fight bot's cap of 60 rounds | 0 | |

The pressure ratio, as each player's turn opens: the ratings of the packs on the apron and of
those whose walk ends there this coming enemy turn, over the machines standing.

| Measure | Mean | Range |
|---|---|---|
| A run's mean over its turns | 0.87 | 0.27 to 3.29 |
| Turns above 1.0, percent of a run's | 21 | 7 to 50 |
| A battle's highest, a run's mean | 1.56 | 0.60 to 5.00 |

The fights, 481 (2.6 a battle), by the pack's rating and the machines the defence rule sent at it:

| A fight for | Machines in it | Fights | Won |
|---|---|---|---|
| 1 | 1 | 94 | 61% |
| 1 | 2 | 30 | 83% |
| 1 | 3 | 7 | 85% |
| 3 | 1 | 169 | 5% |
| 3 | 2 | 52 | 48% |
| 3 | 3 | 54 | 96% |
| 4 | 1 | 45 | 8% |
| 4 | 2 | 21 | 95% |
| 4 | 3 | 9 | 88% |

Read, in bands, a direction. The campaign is a wall for the plain player on the defence rule: no
run won, the first city falling on the first or second turn, 86% of battles fell and 97% ended
in a wipe, so the battles are short (five or six phases) and the tide's later beats (under one
peak a battle), the Fractures (0.75 of 3) and the Rupture (14%) are barely reached. The fights
table shows where it breaks: the rule sends each machine at the pack nearest the wall it can
reach, so on a wall twenty long the three split, and 169 of the 481 fights are one machine
against a formation, won 5%; a formation fought by the three it is rated for is won 96%, by two
48%. A patrol fought alone is won 61% (worn machines among them); an elite fought by two is won
95%, so at tier zero an elite reads as a fight for two, its four unearned (the elites' numbers,
the to-do). The pressure ratio sits under one on average and above it a fifth of the turns. The
defence rule is the floor the brief built for these reads, not the player Ryan's change to the
runner will make (the to-do's engine line).

### The promise read: every composition at its rating, one short and one over

`tools/balance.gd -- --packs promise --seeds 30` (15,600 fights in 2,685 s): every patrol,
formation and elite composition of every domain at each tier it names, against the runner's
default team (the Honey Badger, the Clydesdale, the Kite and the Baboon, stock) cut to the
composition's threat rating (its first N machines), one short (N − 1) and one over (N + 1, four
at most); random and greedy, 30 seeds a cell, a direction. The escorts are left out (they fight
with their boss). The team is tier one's at every tier, so tiers two and three read a stock
tier-one team against the higher tiers' packs.

Means by size and tier, random / greedy won, then greedy's hull lost (percent of the cut's) and
rounds:

| Size, tier | Cells | Short | At its rating | Over |
|---|---|---|---|---|
| Patrol (for 1), tier 1 | 8 | — | 78 / 88%, 24% hull, 4.7 r | 95 / 100%, 5% hull, 2.9 r |
| Patrol, tier 2 | 8 | — | 39 / 65%, 57% hull, 6.0 r | 89 / 100%, 14% hull, 4.1 r |
| Patrol, tier 3 | 4 | — | 32 / 66%, 62% hull, 5.2 r | 98 / 100%, 8% hull, 3.5 r |
| Formation (for 3), tier 1 | 8 | 52 / 97%, 36% hull, 7.2 r | 87 / 100%, 13% hull, 4.2 r | 100 / 100%, 6% hull, 3.4 r |
| Formation, tier 2 | 13 | 24 / 62%, 66% hull, 9.3 r | 56 / 98%, 23% hull, 5.9 r | 86 / 100%, 10% hull, 4.4 r |
| Formation, tier 3 | 17 | 5 / 21%, 89% hull, 6.7 r | 20 / 69%, 57% hull, 7.6 r | 45 / 87%, 30% hull, 5.8 r |
| Elite (for 4), tier 1 | 11 | 92 / 100%, 5% hull, 2.9 r | 99 / 100%, 2% hull, 2.4 r | — |
| Elite, tier 2 | 21 | 85 / 99%, 9% hull, 4.1 r | 96 / 100%, 4% hull, 3.2 r | — |
| Elite, tier 3 | 21 | 78 / 95%, 17% hull, 5.4 r | 90 / 100%, 6% hull, 3.9 r | — |

The bands, by the earlier reads' convention (random winning 90% or more too easy; greedy under
25% a wall; greedy twenty points or more above random a decision; otherwise none):

| | Short | At its rating | Over |
|---|---|---|---|
| Patrols, 20 cells | — | 7 too easy, 9 decision, 4 walls | 16 too easy, 4 decision |
| Formations, 38 cells | 4 too easy, 18 decision, 16 walls | 10 too easy, 24 decision, 1 none, 3 walls | 21 too easy, 14 decision, 1 none, 2 walls |
| Elites, 53 cells | 38 too easy, 13 decision, 2 none | 47 too easy, 6 decision | — |

Read, in bands, a direction:
- **Formations** hold the promise best. At their rating of three they carry a decision in 24 of 38 cells. Tier one's are mostly too easy (random 87%) and tier three's hard (greedy 69% at 57% hull). One short, with two machines, they wall in 16 of 38, most at tiers two and three. One over, with four, they are too easy in 21.
- **Patrols** at their rating of one cost the lone machine a quarter of its hull at tier one and over half at tiers two and three (greedy 65 to 66%). Four of the twenty are walls: the Waste's pit pair and great scouts, the Marsh's knight's retinue, the Peak's fire lizards. With a second machine every patrol falls (greedy 100%).
- **Elites** do not earn their four. At their rating they are too easy in 47 of 53 cells (random 90 to 99%), and three machines, one short, beat them too (random 78 to 92%, greedy 95 to 100%). The campaign read's elites fought by two say the same.
- **The Marsh's tier-three formations** (the Lich's court, the dread host, the wraith choir) wall four machines as well as three.
- **By domain** at the rating, the Meadow is the easiest (its formations random 82%, greedy 99%) and the Marsh the hardest (random 29%, greedy 61%, 49% hull).

Each cell, random / greedy, as the read wrote it:

| Domain | Composition | Tier | For | Short | At its rating | Over |
|---|---|---|---|---|---|---|
| The Meadow | goblin_warband | 1 | 3 | 100% · 7.8 r · 41% hull / 100% · 5.0 r · 8% hull | 100% · 4.8 r · 6% hull / 100% · 3.2 r · 1% hull | 100% · 4.2 r · 3% hull / 100% · 2.6 r · 0% hull |
| The Meadow | wolf_pack | 1 | 1 |  | 100% · 6.5 r · 12% hull / 100% · 3.5 r · 2% hull | 100% · 3.2 r · 0% hull / 100% · 2.0 r · 0% hull |
| The Meadow | gel_cluster | 1 | 1 |  | 90% · 22.3 r · 61% hull / 100% · 13.0 r · 14% hull | 100% · 10.5 r · 18% hull / 100% · 6.1 r · 4% hull |
| The Meadow | guard_warband | 2 | 3 | 97% · 10.1 r · 59% hull / 100% · 6.6 r · 23% hull | 100% · 6.2 r · 18% hull / 100% · 4.3 r · 4% hull | 100% · 4.9 r · 7% hull / 100% · 3.4 r · 1% hull |
| The Meadow | warg_hunt | 2 | 3 | 93% · 17.8 r · 63% hull / 100% · 9.9 r · 18% hull | 100% · 12.7 r · 29% hull / 100% · 6.6 r · 5% hull | 100% · 8.9 r · 11% hull / 100% · 5.1 r · 3% hull |
| The Meadow | warg_pack | 2 | 1 |  | 77% · 7.9 r · 54% hull / 100% · 4.7 r · 14% hull | 100% · 4.4 r · 4% hull / 100% · 2.6 r · 0% hull |
| The Meadow | gel_drift | 2 | 1 |  | 30% · 16.8 r · 93% hull / 100% · 16.2 r · 45% hull | 100% · 13.3 r · 45% hull / 100% · 7.8 r · 16% hull |
| The Meadow | captains_warband | 3 | 3 | 17% · 8.4 r · 97% hull / 100% · 7.6 r · 46% hull | 80% · 9.1 r · 61% hull / 100% · 4.7 r · 9% hull | 100% · 6.9 r · 24% hull / 100% · 3.9 r · 2% hull |
| The Meadow | alpha_hunt | 3 | 3 | 3% · 4.6 r · 100% hull / 47% · 7.1 r · 87% hull | 50% · 8.1 r · 81% hull / 100% · 5.9 r · 24% hull | 93% · 6.9 r · 39% hull / 100% · 4.6 r · 6% hull |
| The Meadow | metal_drift | 3 | 3 | 0% · 4.5 r · 100% hull / 0% · 6.2 r · 100% hull | 0% · 6.2 r · 100% hull / 90% · 9.2 r · 66% hull | 30% · 9.8 r · 92% hull / 100% · 6.2 r · 23% hull |
| The Meadow | alpha_pack | 3 | 1 |  | 17% · 5.1 r · 94% hull / 70% · 5.3 r · 68% hull | 100% · 6.1 r · 37% hull / 100% · 3.7 r · 6% hull |
| The Meadow | shamans_warband | 1 | 4 | 100% · 4.7 r · 5% hull / 100% · 2.7 r · 1% hull | 100% · 4.2 r · 2% hull / 100% · 2.3 r · 0% hull |  |
| The Meadow | shamans_warband | 2 | 4 | 100% · 4.9 r · 5% hull / 100% · 2.7 r · 1% hull | 100% · 4.5 r · 3% hull / 100% · 2.4 r · 0% hull |  |
| The Meadow | shamans_warband | 3 | 4 | 100% · 5.3 r · 9% hull / 100% · 2.8 r · 0% hull | 100% · 4.6 r · 4% hull / 100% · 2.6 r · 0% hull |  |
| The Meadow | elder_treants_grove | 2 | 4 | 100% · 9.8 r · 27% hull / 100% · 5.2 r · 7% hull | 100% · 7.1 r · 9% hull / 100% · 4.2 r · 1% hull |  |
| The Meadow | elder_treants_grove | 3 | 4 | 97% · 15.2 r · 56% hull / 100% · 6.2 r · 12% hull | 100% · 8.8 r · 19% hull / 100% · 4.9 r · 2% hull |  |
| The Meadow | leshys_hunt | 2 | 4 | 100% · 3.5 r · 0% hull / 100% · 1.9 r · 0% hull | 100% · 2.9 r · 0% hull / 100% · 1.8 r · 0% hull |  |
| The Meadow | leshys_hunt | 3 | 4 | 100% · 3.7 r · 0% hull / 100% · 2.0 r · 0% hull | 100% · 3.1 r · 0% hull / 100% · 2.0 r · 0% hull |  |
| The Meadow | the_nob | 1 | 4 | 100% · 2.6 r · 1% hull / 100% · 2.0 r · 0% hull | 100% · 2.4 r · 0% hull / 100% · 1.8 r · 0% hull |  |
| The Meadow | the_nob | 2 | 4 | 100% · 3.2 r · 1% hull / 100% · 2.1 r · 0% hull | 100% · 3.1 r · 1% hull / 100% · 2.0 r · 0% hull |  |
| The Meadow | the_nob | 3 | 4 | 100% · 3.8 r · 2% hull / 100% · 2.6 r · 1% hull | 100% · 3.6 r · 2% hull / 100% · 2.2 r · 0% hull |  |
| The Meadow | treant_grove | 1 | 3 | 70% · 15.6 r · 80% hull / 100% · 9.2 r · 31% hull | 100% · 10.4 r · 33% hull / 100% · 4.8 r · 6% hull | 100% · 7.7 r · 13% hull / 100% · 4.2 r · 2% hull |
| The Meadow | treant_march | 2 | 3 | 27% · 16.5 r · 95% hull / 100% · 10.6 r · 38% hull | 100% · 11.8 r · 38% hull / 100% · 5.6 r · 8% hull | 100% · 8.0 r · 15% hull / 100% · 4.6 r · 3% hull |
| The Meadow | treant_wilds | 3 | 3 | 0% · 11.8 r · 100% hull / 100% · 12.7 r · 54% hull | 80% · 15.6 r · 67% hull / 100% · 6.6 r · 13% hull | 100% · 9.3 r · 25% hull / 100% · 5.0 r · 3% hull |
| The Meadow | rotblooms_bed | 2 | 3 | 63% · 13.7 r · 80% hull / 100% · 8.0 r · 23% hull | 97% · 8.3 r · 34% hull / 100% · 4.3 r · 5% hull | 100% · 6.8 r · 17% hull / 100% · 3.7 r · 1% hull |
| The Meadow | rotblooms_bed | 3 | 3 | 63% · 13.7 r · 80% hull / 100% · 8.0 r · 23% hull | 97% · 8.3 r · 34% hull / 100% · 4.3 r · 5% hull | 100% · 6.8 r · 17% hull / 100% · 3.7 r · 1% hull |
| The Waste | needler_swarm | 1 | 3 | 100% · 6.0 r · 36% hull / 100% · 4.0 r · 19% hull | 100% · 4.2 r · 16% hull / 100% · 2.5 r · 7% hull | 100% · 3.2 r · 7% hull / 100% · 2.0 r · 2% hull |
| The Waste | antlion_pair | 1 | 1 |  | 93% · 5.2 r · 42% hull / 100% · 2.5 r · 9% hull | 100% · 2.8 r · 2% hull / 100% · 2.0 r · 0% hull |
| The Waste | needler_scouts | 1 | 1 |  | 90% · 4.5 r · 51% hull / 100% · 3.0 r · 26% hull | 100% · 2.4 r · 8% hull / 100% · 2.0 r · 4% hull |
| The Waste | needler_scouts | 2 | 1 |  | 90% · 4.5 r · 51% hull / 100% · 3.0 r · 26% hull | 100% · 2.4 r · 8% hull / 100% · 2.0 r · 4% hull |
| The Waste | barbed_swarm | 2 | 3 | 13% · 6.5 r · 98% hull / 93% · 6.0 r · 57% hull | 80% · 7.9 r · 65% hull / 100% · 3.8 r · 20% hull | 100% · 5.5 r · 29% hull / 100% · 3.0 r · 7% hull |
| The Waste | pit_ambush | 2 | 3 | 3% · 4.5 r · 100% hull / 67% · 6.3 r · 89% hull | 43% · 6.7 r · 83% hull / 100% · 3.8 r · 26% hull | 90% · 5.7 r · 47% hull / 100% · 3.1 r · 13% hull |
| The Waste | pit_pair | 2 | 1 |  | 0% · 2.0 r · 100% hull / 0% · 2.8 r · 100% hull | 73% · 5.4 r · 78% hull / 100% · 3.2 r · 35% hull |
| The Waste | great_swarm | 3 | 3 | 0% · 4.8 r · 100% hull / 7% · 5.7 r · 99% hull | 23% · 7.0 r · 95% hull / 100% · 5.0 r · 39% hull | 77% · 8.1 r · 67% hull / 100% · 4.0 r · 17% hull |
| The Waste | queens_court | 3 | 3 | 0% · 3.2 r · 100% hull / 0% · 3.8 r · 100% hull | 0% · 4.4 r · 100% hull / 67% · 5.7 r · 71% hull | 13% · 6.8 r · 99% hull / 100% · 4.7 r · 32% hull |
| The Waste | gorgon_glare | 3 | 3 | 0% · 4.7 r · 100% hull / 0% · 6.3 r · 100% hull | 10% · 7.6 r · 97% hull / 100% · 6.2 r · 49% hull | 70% · 8.7 r · 66% hull / 100% · 4.4 r · 17% hull |
| The Waste | great_scouts | 3 | 1 |  | 3% · 3.5 r · 99% hull / 3% · 3.8 r · 100% hull | 93% · 4.7 r · 42% hull / 100% · 3.1 r · 21% hull |
| The Waste | old_mans_rising | 1 | 4 | 10% · 12.3 r · 97% hull / 97% · 7.1 r · 44% hull | 93% · 11.1 r · 56% hull / 100% · 5.0 r · 20% hull |  |
| The Waste | old_mans_rising | 2 | 4 | 7% · 10.8 r · 98% hull / 90% · 9.5 r · 62% hull | 70% · 14.4 r · 75% hull / 100% · 5.9 r · 25% hull |  |
| The Waste | old_mans_rising | 3 | 4 | 0% · 9.0 r · 100% hull / 33% · 11.2 r · 90% hull | 30% · 15.8 r · 90% hull / 100% · 7.8 r · 39% hull |  |
| The Waste | sandworm_ambush | 1 | 3 | 3% · 9.1 r · 100% hull / 90% · 9.1 r · 76% hull | 77% · 10.7 r · 80% hull / 100% · 5.9 r · 37% hull | 100% · 8.7 r · 45% hull / 100% · 4.3 r · 17% hull |
| The Waste | sandworm_pit | 2 | 3 | 0% · 5.5 r · 100% hull / 3% · 9.6 r · 100% hull | 10% · 10.5 r · 98% hull / 93% · 9.1 r · 60% hull | 83% · 13.9 r · 73% hull / 100% · 5.4 r · 23% hull |
| The Waste | sandworm_flats | 3 | 3 | 0% · 5.4 r · 100% hull / 0% · 8.0 r · 100% hull | 0% · 8.9 r · 100% hull / 67% · 11.1 r · 75% hull | 50% · 13.3 r · 85% hull / 100% · 6.4 r · 30% hull |
| The Waste | pilgrims_wake | 1 | 4 | 100% · 6.6 r · 23% hull / 100% · 3.4 r · 4% hull | 100% · 5.1 r · 15% hull / 100% · 3.1 r · 0% hull |  |
| The Waste | pilgrims_wake | 2 | 4 | 100% · 7.9 r · 35% hull / 100% · 4.2 r · 10% hull | 100% · 6.2 r · 20% hull / 100% · 3.5 r · 2% hull |  |
| The Waste | pilgrims_wake | 3 | 4 | 100% · 9.3 r · 46% hull / 100% · 5.1 r · 17% hull | 100% · 7.3 r · 23% hull / 100% · 4.0 r · 6% hull |  |
| The Waste | rust_monsters_scavenge | 1 | 4 | 100% · 2.2 r · 0% hull / 100% · 1.7 r · 0% hull | 100% · 1.9 r · 0% hull / 100% · 1.4 r · 0% hull |  |
| The Waste | rust_monsters_scavenge | 2 | 4 | 100% · 2.9 r · 1% hull / 100% · 2.0 r · 0% hull | 100% · 2.6 r · 0% hull / 100% · 2.0 r · 0% hull |  |
| The Waste | rust_monsters_scavenge | 3 | 4 | 100% · 3.4 r · 2% hull / 100% · 2.1 r · 0% hull | 100% · 3.2 r · 0% hull / 100% · 2.0 r · 0% hull |  |
| The Waste | gilgamesh_wanders | 1 | 4 | 100% · 5.9 r · 2% hull / 100% · 3.6 r · 1% hull | 100% · 5.0 r · 1% hull / 100% · 3.1 r · 0% hull |  |
| The Waste | gilgamesh_wanders | 2 | 4 | 100% · 7.1 r · 4% hull / 100% · 4.4 r · 1% hull | 100% · 6.0 r · 2% hull / 100% · 3.6 r · 0% hull |  |
| The Waste | gilgamesh_and_enkidu | 3 | 4 | 100% · 10.7 r · 24% hull / 100% · 5.8 r · 9% hull | 100% · 8.9 r · 13% hull / 100% · 4.8 r · 2% hull |  |
| The Waste | the_astromancer | 2 | 4 | 77% · 11.3 r · 51% hull / 100% · 4.2 r · 3% hull | 100% · 7.3 r · 17% hull / 100% · 3.2 r · 1% hull |  |
| The Waste | the_astromancer | 3 | 4 | 60% · 13.4 r · 74% hull / 100% · 5.0 r · 7% hull | 100% · 7.9 r · 22% hull / 100% · 4.2 r · 2% hull |  |
| The Marsh | grave_host | 1 | 3 | 53% · 10.8 r · 84% hull / 100% · 7.7 r · 27% hull | 87% · 7.8 r · 33% hull / 100% · 3.8 r · 3% hull | 100% · 5.5 r · 9% hull / 100% · 3.2 r · 1% hull |
| The Marsh | barrow_mound | 1 | 3 | 37% · 19.2 r · 93% hull / 100% · 8.7 r · 27% hull | 97% · 13.1 r · 39% hull / 100% · 4.7 r · 5% hull | 100% · 8.4 r · 13% hull / 100% · 4.0 r · 1% hull |
| The Marsh | knights_retinue | 1 | 1 |  | 0% · 3.6 r · 100% hull / 0% · 3.7 r · 100% hull | 57% · 8.0 r · 73% hull / 100% · 3.8 r · 32% hull |
| The Marsh | revenant_shamblers | 1 | 1 |  | 97% · 6.3 r · 21% hull / 100% · 3.4 r · 2% hull | 100% · 2.9 r · 1% hull / 100% · 2.0 r · 0% hull |
| The Marsh | wight_host | 2 | 3 | 7% · 8.6 r · 98% hull / 93% · 9.3 r · 61% hull | 67% · 12.3 r · 71% hull / 100% · 4.9 r · 8% hull | 100% · 8.5 r · 25% hull / 100% · 4.1 r · 2% hull |
| The Marsh | grave_field | 2 | 3 | 0% · 9.7 r · 100% hull / 43% · 23.9 r · 85% hull | 7% · 25.0 r · 96% hull / 97% · 10.3 r · 20% hull | 47% · 34.0 r · 65% hull / 100% · 5.7 r · 5% hull |
| The Marsh | death_knights_retinue | 2 | 3 | 0% · 6.9 r · 100% hull / 0% · 7.7 r · 100% hull | 7% · 10.5 r · 100% hull / 90% · 7.6 r · 51% hull | 37% · 13.1 r · 85% hull / 100% · 6.7 r · 30% hull |
| The Marsh | wight_shamblers | 2 | 1 |  | 40% · 5.3 r · 82% hull / 93% · 5.1 r · 46% hull | 100% · 5.3 r · 20% hull / 100% · 3.1 r · 4% hull |
| The Marsh | wight_shamblers | 3 | 1 |  | 40% · 5.3 r · 82% hull / 93% · 5.1 r · 46% hull | 100% · 5.3 r · 20% hull / 100% · 3.1 r · 4% hull |
| The Marsh | knight_and_wights | 2 | 1 |  | 3% · 4.9 r · 100% hull / 27% · 6.3 r · 96% hull | 73% · 11.6 r · 72% hull / 100% · 5.7 r · 29% hull |
| The Marsh | lichs_court | 3 | 3 | 0% · 3.9 r · 100% hull / 0% · 4.0 r · 100% hull | 0% · 5.3 r · 100% hull / 0% · 5.3 r · 100% hull | 0% · 7.0 r · 100% hull / 13% · 9.0 r · 96% hull |
| The Marsh | charnel_pit | 3 | 3 | 0% · 6.3 r · 100% hull / 0% · 12.3 r · 100% hull | 0% · 12.1 r · 100% hull / 63% · 21.7 r · 56% hull | 23% · 25.9 r · 85% hull / 100% · 7.0 r · 11% hull |
| The Marsh | dread_host | 3 | 3 | 0% · 3.6 r · 100% hull / 0% · 3.7 r · 100% hull | 0% · 4.5 r · 100% hull / 0% · 4.7 r · 100% hull | 0% · 6.0 r · 100% hull / 0% · 7.0 r · 100% hull |
| The Marsh | wraith_choir | 3 | 3 | 0% · 4.7 r · 100% hull / 0% · 4.7 r · 100% hull | 0% · 6.0 r · 100% hull / 3% · 6.9 r · 100% hull | 0% · 8.2 r · 100% hull / 63% · 9.5 r · 77% hull |
| The Marsh | fell_riders_hunt | 1 | 4 | 100% · 1.7 r · 0% hull / 100% · 1.1 r · 0% hull | 100% · 1.6 r · 0% hull / 100% · 1.0 r · 0% hull |  |
| The Marsh | fell_riders_hunt | 2 | 4 | 100% · 2.3 r · 0% hull / 100% · 1.7 r · 0% hull | 100% · 1.9 r · 0% hull / 100% · 1.4 r · 0% hull |  |
| The Marsh | fell_riders_hunt | 3 | 4 | 100% · 2.6 r · 0% hull / 100% · 2.1 r · 0% hull | 100% · 2.4 r · 0% hull / 100% · 1.9 r · 0% hull |  |
| The Marsh | skeleton_kings_court | 2 | 4 | 20% · 11.2 r · 91% hull / 87% · 7.9 r · 50% hull | 50% · 13.6 r · 72% hull / 97% · 5.5 r · 20% hull |  |
| The Marsh | skeleton_kings_court | 3 | 4 | 20% · 11.8 r · 93% hull / 80% · 9.3 r · 57% hull | 40% · 14.7 r · 77% hull / 97% · 6.4 r · 24% hull |  |
| The Marsh | collectors_hall | 2 | 4 | 80% · 9.7 r · 50% hull / 100% · 3.2 r · 10% hull | 100% · 5.6 r · 17% hull / 100% · 2.4 r · 6% hull |  |
| The Marsh | collectors_hall | 3 | 4 | 67% · 9.9 r · 59% hull / 100% · 3.5 r · 14% hull | 100% · 6.3 r · 22% hull / 100% · 2.9 r · 9% hull |  |
| The Marsh | bone_wyverns_flight | 2 | 4 | 100% · 7.7 r · 21% hull / 100% · 4.6 r · 5% hull | 100% · 6.1 r · 9% hull / 100% · 3.7 r · 1% hull |  |
| The Marsh | bone_wyverns_flight | 3 | 4 | 100% · 9.1 r · 29% hull / 100% · 5.4 r · 10% hull | 100% · 6.9 r · 12% hull / 100% · 4.2 r · 2% hull |  |
| The Marsh | the_reaper | 1 | 4 | 100% · 1.4 r · 0% hull / 100% · 1.0 r · 0% hull | 100% · 1.3 r · 0% hull / 100% · 1.0 r · 0% hull |  |
| The Marsh | the_reaper | 2 | 4 | 100% · 1.6 r · 0% hull / 100% · 1.1 r · 0% hull | 100% · 1.5 r · 0% hull / 100% · 1.0 r · 0% hull |  |
| The Marsh | the_reaper | 3 | 4 | 100% · 2.0 r · 0% hull / 100% · 1.4 r · 0% hull | 100% · 1.8 r · 0% hull / 100% · 1.1 r · 0% hull |  |
| The Marsh | the_wild_hunt | 1 | 4 | 100% · 3.7 r · 2% hull / 100% · 2.2 r · 0% hull | 100% · 3.4 r · 1% hull / 100% · 2.1 r · 0% hull |  |
| The Marsh | the_wild_hunt | 2 | 4 | 100% · 4.8 r · 9% hull / 100% · 2.8 r · 0% hull | 100% · 4.1 r · 4% hull / 100% · 2.6 r · 0% hull |  |
| The Marsh | the_wild_hunt | 3 | 4 | 100% · 5.7 r · 19% hull / 100% · 3.3 r · 2% hull | 100% · 4.6 r · 10% hull / 100% · 2.8 r · 1% hull |  |
| The Marsh | the_shambler | 2 | 4 | 100% · 6.1 r · 6% hull / 100% · 3.3 r · 0% hull | 100% · 4.7 r · 1% hull / 100% · 2.6 r · 0% hull |  |
| The Marsh | the_shambler | 3 | 4 | 100% · 7.2 r · 12% hull / 100% · 3.9 r · 1% hull | 100% · 6.1 r · 4% hull / 100% · 3.1 r · 0% hull |  |
| The Peak | ember_pit | 1 | 3 | 57% · 7.2 r · 85% hull / 100% · 4.8 r · 22% hull | 100% · 5.2 r · 22% hull / 100% · 2.8 r · 2% hull | 100% · 4.0 r · 6% hull / 100% · 2.4 r · 0% hull |
| The Peak | bomb_flight | 1 | 1 |  | 93% · 7.7 r · 44% hull / 100% · 4.8 r · 12% hull | 100% · 3.7 r · 5% hull / 100% · 2.5 r · 0% hull |
| The Peak | salamander_trio | 1 | 1 |  | 63% · 5.7 r · 66% hull / 100% · 4.0 r · 23% hull | 100% · 3.9 r · 7% hull / 100% · 2.6 r · 2% hull |
| The Peak | wyvern_roost | 2 | 3 | 3% · 5.1 r · 100% hull / 33% · 6.7 r · 91% hull | 47% · 6.7 r · 79% hull / 100% · 3.9 r · 12% hull | 93% · 6.4 r · 48% hull / 100% · 3.4 r · 7% hull |
| The Peak | grenade_volley | 2 | 3 | 3% · 5.6 r · 99% hull / 70% · 7.3 r · 72% hull | 63% · 7.8 r · 75% hull / 100% · 3.9 r · 13% hull | 97% · 6.2 r · 41% hull / 100% · 3.4 r · 5% hull |
| The Peak | grenade_flight | 2 | 1 |  | 70% · 9.9 r · 74% hull / 100% · 6.3 r · 32% hull | 100% · 5.3 r · 12% hull / 100% · 3.4 r · 1% hull |
| The Peak | fire_lizards | 2 | 1 |  | 0% · 3.1 r · 100% hull / 0% · 3.9 r · 100% hull | 67% · 6.3 r · 75% hull / 100% · 4.9 r · 27% hull |
| The Peak | dragons_roost | 3 | 3 | 0% · 3.2 r · 100% hull / 0% · 3.8 r · 100% hull | 0% · 4.3 r · 100% hull / 60% · 6.9 r · 82% hull | 3% · 5.9 r · 100% hull / 97% · 5.6 r · 33% hull |
| The Peak | magma_pit | 3 | 3 | 0% · 4.7 r · 100% hull / 0% · 5.7 r · 100% hull | 0% · 6.5 r · 100% hull / 93% · 6.8 r · 40% hull | 30% · 9.3 r · 92% hull / 100% · 5.6 r · 16% hull |
| The Peak | balloon_storm | 3 | 3 | 0% · 4.3 r · 100% hull / 0% · 5.7 r · 100% hull | 3% · 6.1 r · 100% hull / 93% · 6.9 r · 41% hull | 43% · 8.2 r · 86% hull / 100% · 4.8 r · 12% hull |
| The Peak | balloon_flight | 3 | 1 |  | 67% · 10.1 r · 74% hull / 97% · 6.4 r · 36% hull | 100% · 6.1 r · 17% hull / 100% · 4.0 r · 3% hull |
| The Peak | magma_vent | 1 | 3 | 0% · 7.8 r · 100% hull / 83% · 9.3 r · 81% hull | 33% · 10.8 r · 92% hull / 100% · 6.2 r · 42% hull | 100% · 9.1 r · 51% hull / 100% · 4.6 r · 21% hull |
| The Peak | magma_forge | 2 | 3 | 0% · 5.4 r · 100% hull / 0% · 9.1 r · 100% hull | 10% · 10.6 r · 99% hull / 97% · 9.0 r · 64% hull | 70% · 11.8 r · 73% hull / 100% · 5.9 r · 24% hull |
| The Peak | magma_caldera | 3 | 3 | 0% · 5.5 r · 100% hull / 0% · 8.0 r · 100% hull | 0% · 9.2 r · 100% hull / 33% · 10.8 r · 92% hull | 27% · 13.2 r · 91% hull / 100% · 7.1 r · 34% hull |
| The Peak | cinder_tortoises_brood | 1 | 4 | 100% · 8.5 r · 19% hull / 100% · 5.0 r · 2% hull | 100% · 6.8 r · 9% hull / 100% · 4.1 r · 1% hull |  |
| The Peak | cinder_tortoises_brood | 2 | 4 | 77% · 18.4 r · 67% hull / 100% · 8.0 r · 11% hull | 100% · 12.5 r · 32% hull / 100% · 5.9 r · 3% hull |  |
| The Peak | cinder_tortoises_brood | 3 | 4 | 0% · 23.1 r · 100% hull / 93% · 20.2 r · 55% hull | 53% · 24.1 r · 79% hull / 100% · 8.7 r · 8% hull |  |
| The Peak | thunder_apes_rampage | 1 | 4 | 100% · 2.8 r · 1% hull / 100% · 2.1 r · 1% hull | 100% · 2.6 r · 1% hull / 100% · 1.8 r · 0% hull |  |
| The Peak | thunder_apes_rampage | 2 | 4 | 100% · 3.5 r · 3% hull / 100% · 2.1 r · 1% hull | 100% · 3.3 r · 2% hull / 100% · 2.0 r · 1% hull |  |
| The Peak | thunder_apes_rampage | 3 | 4 | 100% · 4.3 r · 7% hull / 100% · 2.8 r · 3% hull | 100% · 3.8 r · 5% hull / 100% · 2.2 r · 1% hull |  |
| The Peak | the_bane | 2 | 4 | 93% · 8.3 r · 38% hull / 100% · 4.1 r · 15% hull | 100% · 5.7 r · 19% hull / 100% · 3.3 r · 8% hull |  |
| The Peak | the_bane | 3 | 4 | 83% · 10.2 r · 55% hull / 100% · 4.9 r · 24% hull | 100% · 6.9 r · 25% hull / 100% · 4.0 r · 10% hull |  |
| The Peak | firelords_rising | 2 | 4 | 37% · 14.1 r · 79% hull / 100% · 6.8 r · 11% hull | 97% · 9.4 r · 23% hull / 100% · 4.2 r · 3% hull |  |
| The Peak | firelords_rising | 3 | 4 | 20% · 14.6 r · 92% hull / 97% · 9.2 r · 24% hull | 77% · 12.8 r · 46% hull / 100% · 5.1 r · 5% hull |  |
| The Peak | the_ravener | 2 | 4 | 100% · 8.2 r · 43% hull / 100% · 4.4 r · 12% hull | 100% · 6.2 r · 20% hull / 100% · 3.7 r · 3% hull |  |
| The Peak | the_ravener | 3 | 4 | 87% · 10.5 r · 71% hull / 100% · 5.6 r · 25% hull | 100% · 7.7 r · 34% hull / 100% · 4.3 r · 6% hull |  |

### The map survey at 20 by 12

`tools/map_survey.gd -- --seeds 200 --type steppe --width 20 --height 12`. The steppe: plain 95%,
road 4%, water 1%; the horde's route 11 hexes on every map; the narrowest crossing 5 hexes on all
200; every way of moving reaches the rift in 3 phases at move 3, the packs at move 2 in 4; after
two phases tracked machines reach 35% of the field, walkers 59%, wheels, hovers and flyers 81 to
82%, every one making the crossing by phase 2. The shapes compared, each on seeds 1 to 200:

| Shape | Open | Rough | Ruins | Water | Walls | Crossing | Opened | Route | Phases T/W/Wh/H/F | Reach T/W/Wh/H/F | Steps | Lone |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| RIVER CROSSING | 80% | 0% | 0% | 19% | 0% | 200 of 200 at 3+ | 0.0 | 11.1 | 3.0/3.0/3.0/3.0/3.0 | 33/55/77/81/82% | 0% | 0.0 |
| FJORD | 95% | 0% | 0% | 5% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/59/81/82/82% | 0% | 0.0 |
| BADLANDS | 61% | 26% | 0% | 3% | 10% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 30/51/71/71/82% | 17% | 0.4 |
| OPEN STEPPE | 99% | 0% | 0% | 1% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/59/81/81/82% | 0% | 0.0 |
| RUINED CITY | 12% | 0% | 75% | 0% | 13% | 200 of 200 at 3+ | 0.0 | 11.4 | 3.0/3.0/3.0/3.0/3.0 | 27/46/65/65/82% | 0% | 0.0 |
| GORGE | 96% | 0% | 0% | 0% | 4% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/57/77/77/82% | 0% | 0.0 |

Read: at twelve deep the depth no longer parts the shapes (three phases to the rift at move 3
and a route of about 11 hexes on all six); what parts them is the lanes, read in the reach after two phases
(the ruined city's 27/46/65/65/82% and the badlands' 30/51/71/71/82% against the steppe's
35/59/81/81/82%). The shapes are laid by the old generator for the old field; their relaying is the
brief's open item 5.

### The shapes at 20 by 12

Each shape at seed 7 (`R` the rift, `G` the gate, `W` the wall, `~` water, `#` rock, `=` road, `,`
rough, `:` ruins, `.` plain; odd rows indented), as the proposal's section 3 printed them at 24 by 12:

```
river 20x12: water 35, rock 1, opened 0, narrowest crossing 5
.   .   .   .   .   .   .   .   .   R   R   R   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   ~   ~   .   ~   .   #   .   .   .   .   .   =   ~   ~   .   .   .   .
  ~   ~   ~   ~   .   ~   ~   ~   ~   .   .   .   =   .   ~   ~   ~   ~   ~   ~
~   ~   ~   .   .   .   ~   ~   ~   ~   ~   ~   .   .   .   .   ~   ~   ~   ~
  .   .   .   .   .   .   .   .   .   ~   ~   ~   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   =   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   =   =   .   .   .   .   .   .   .   .
W   W   W   W   W   W   W   W   W   G   G   G   G   W   W   W   W   W   W   W
  W   W   W   W   W   W   W   W   W   G   G   G   W   W   W   W   W   W   W   W
fjord 20x12: water 9, rock 0, opened 0, narrowest crossing 5
.   .   .   .   .   .   .   .   .   R   R   R   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   ~   ~   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   ~   ~   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   ~   ~   ~   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   ~   ~   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
W   W   W   W   W   W   W   W   W   G   G   G   G   W   W   W   W   W   W   W
  W   W   W   W   W   W   W   W   W   G   G   G   W   W   W   W   W   W   W   W
badlands 20x12: water 9, rock 20, opened 0, narrowest crossing 5
.   .   ,   ,   ,   ,   .   .   .   R   R   R   .   .   ,   ,   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
  ,   ,   .   .   .   ,   ,   ,   ,   .   .   .   .   ,   ,   ,   .   ,   ,   ,
,   #   ,   .   .   ,   #   #   #   ,   .   .   .   ,   #   #   ,   ,   #   ,
  ,   #   ,   .   .   ,   ,   ,   ,   .   .   .   .   ,   #   ,   #   #   ,   ~
#   #   ,   ~   ~   ,   #   #   #   ,   .   .   .   .   ,   #   ,   #   ,   ~
  #   ,   .   .   ~   ,   ,   ,   ,   .   ~   ~   ~   ,   #   ,   ,   ,   .   ~
,   ,   .   .   .   .   .   .   .   .   .   .   .   .   ,   ,   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
W   W   W   W   W   W   W   W   W   G   G   G   G   W   W   W   W   W   W   W
  W   W   W   W   W   W   W   W   W   G   G   G   W   W   W   W   W   W   W   W
steppe 20x12: water 0, rock 1, opened 0, narrowest crossing 5
.   .   .   .   .   .   .   .   .   R   R   R   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   =   .   .   .   .   .   .   #   .   .
.   .   .   .   .   .   .   .   .   .   .   =   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   =   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   =   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   =   .   .   .   .   .   .   .   .   .
W   W   W   W   W   W   W   W   W   G   G   G   G   W   W   W   W   W   W   W
  W   W   W   W   W   W   W   W   W   G   G   G   W   W   W   W   W   W   W   W
city 20x12: water 0, rock 34, opened 0, narrowest crossing 3
:   :   :   :   :   :   :   :   .   R   R   R   .   :   :   :   :   :   :   :
  :   :   :   :   :   :   :   :   .   .   .   .   :   :   :   :   :   :   :   :
:   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
  :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
:   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
  #   #   #   #   #   #   :   =   :   #   #   #   #   #   #   #   #   #   #   #
#   #   #   #   #   #   :   =   =   #   #   #   #   #   #   #   #   #   #   #
  :   :   :   :   :   :   :   :   =   =   :   :   :   :   :   :   :   :   :   :
:   :   :   :   :   :   :   :   :   :   =   :   :   :   :   :   :   :   :   :
  :   :   :   :   :   :   :   :   .   .   =   .   .   :   :   :   :   :   :   :
W   W   W   W   W   W   W   W   W   G   G   G   G   W   W   W   W   W   W   W
  W   W   W   W   W   W   W   W   W   G   G   G   W   W   W   W   W   W   W   W
gorge 20x12: water 0, rock 8, opened 0, narrowest crossing 5
.   .   .   .   .   .   .   .   .   R   R   R   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   #   .   .   .   #   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   #   .   .   .   #   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   #   .   .   .   #   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   #   .   .   #   .   .   .   .   .   .   .   .   .   .   .   .   .
.   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
W   W   W   W   W   W   W   W   W   G   G   G   G   W   W   W   W   W   W   W
  W   W   W   W   W   W   W   W   W   G   G   G   W   W   W   W   W   W   W   W
```

### The placeholders

Every number the build set only so the mechanism runs, each marked `# placeholder (the long wall
brief)` where it stands, and moved only on Ryan's word:

| Number | Value | Where |
|---|---|---|
| The wall's length | 20 at every Convergence | `sim/ramp.gd:89` (`wall_length_at`) |
| The depth | 12 at every Convergence | `sim/ramp.gd:95` (`depth_at`) |
| The beat (Rift Pressure's fill) | 3 turns, 2 from Convergence 8 | `sim/ramp.gd:52` (`timer_at`) |
| The spread of a pusher's segment | 2 + ((length / 2 − 2) × Convergence) / 12 either side of the rift's column: 2 at the foot, 10 at the top on a wall of 20 | `sim/ramp.gd:82` (`spread_at`) |
| The opening pressure | a turn short of the first peak (the beat − 1) | `sim/battle.gd:172` |
| The opening rows | a formation one of its moves short of the apron, a patrol two (the 1 and 2 at `sim/battle.gd:207` and `:210`), never into the rift's mouth | `sim/battle.gd:289` (`_open_row`) |
| The beat after the Rupture | halved once, never below 1 | `sim/battle.gd:310` (`rupture`) |
| The attack range | 1 (adjacency) | `sim/unit.gd:108` |

## 9 November: the shapes relaid for the shallow field

`tools/map_survey.gd -- --seeds 200 --type steppe --width 20 --height 12` on `ccr-1e6e6571-7x7ayr`
(the shapes relaid, the to-do's map line): every shape on seeds 1 to 200 at 20 by 12, read against the
same table of 6 November (above, "The map survey at 20 by 12"). The mouth is three rows at twelve deep
(four on 6 November), so a shape has rows 3 to 7.

| Shape | Open | Rough | Ruins | Water | Walls | Crossing | Opened | Route | Phases T/W/Wh/H/F | Reach T/W/Wh/H/F | Steps | Lone |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| RIVER CROSSING | 72% | 9% | 0% | 19% | 0% | 200 of 200 at 3+ | 0.0 | 11.1 | 3.0/3.0/3.0/3.0/3.0 | 33/55/78/81/82% | 0% | 0.0 |
| FJORD | 81% | 8% | 0% | 12% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/57/79/82/82% | 0% | 0.0 |
| BADLANDS | 54% | 30% | 0% | 3% | 12% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 30/49/69/69/82% | 19% | 0.3 |
| OPEN STEPPE | 98% | 0% | 0% | 1% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/59/81/81/82% | 3% | 0.0 |
| RUINED CITY | 12% | 0% | 75% | 0% | 13% | 200 of 200 at 3+ | 0.0 | 11.5 | 3.0/3.0/3.0/3.0/3.0 | 28/46/65/65/82% | 0% | 0.0 |
| GORGE | 80% | 12% | 0% | 0% | 8% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 33/54/73/73/82% | 0% | 0.0 |

Read: the shapes tell apart again by what they lay, where on 6 November three had nothing to lay
(the fjord 5% water in one puddle, the gorge 4% walls in two stubs, the steppe bare): the fjord's
two channels put 12% of the field under water, the gorge's three cliff walls 8% in walls, the
steppe's crag and pond for every ten hexes of wall 1% water (none on 51 maps, a pond on 97, ponds
on 52), and the second ground lies along the landforms (the river's bars 9% of the field, the
fjord's shingle 8%, the gorge's scree 12%; the badlands' scrub 30%, the city's rubble 75%, the
steppe none). Every map keeps the horde's crossing at three or more with nothing opened, and the
route to the gate stays about 11 hexes on every shape, so the depth still parts nothing: what
parts the shapes is the lanes, read in the reach after two phases, now widest on the steppe
(35/59/81/81/82%) and narrowest in the city (28/46/65/65/82%), the badlands (30/49/69/69/82%)
and the gorge (33/54/73/73/82%, the river's and the fjord's wade between). The relief stands as
decided: level but the badlands' shoulders and the steppe's rise (3% of neighbouring land at
different heights there, the one rise), never a lone hex but the badlands' 0.3 a map. The
laying takes 13 ms a map. Nothing here is a decision: the shapes are judged running on the
phone (the to-do's Ryan list) and the counts (`BattleMap.FJORD_PER`, `GORGE_PER`, `STEPPE_PER`)
are placeholders.

The two shapes the shallow field had broken, at seed 3 (`--show 3`; `~` water, `^` a wall, `"`
rough, `=` road, `R` the rift, `G` the gate, `|` the wall, the scenery outside the brackets):

```
seed 3, FJORD, fjord, narrowest crossing 5, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[. . . . . . . . . R R R . . . . . . . .], , , , 
 , , , ,[. . . . . . . . . . . . . . . . . . . .], , , , 
, , , ,[. . " " . . . . . . . . . " . " " . . .], , , , 
 , , , ,[. " ~ ~ . . . . . . . . . ~ ~ ~ . . . .], , , , 
, , , ,[. " ~ ~ ~ " . . . . . . " ~ ~ . . . . .], , , , 
 , , , ,[. " ~ ~ . . . . . . . . " ~ ~ " . . . .], , , , 
, , , ,[. . ~ ~ " . . . . . . . . . ~ ~ ~ " . .], , , , 
 , , , ,[. . ~ ~ . . . . . . . . . . ~ ~ ~ " . .], , , , 
, , , ,[. . . " . . . . . . . . . . . . " . . .], , , , 
 , , , ,[. . . . . . . . . . . . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 3, GORGE, , narrowest crossing 5, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , " ,[, , , , , , , , , , , , , , , , , , , "], , , , 
, , , ^[. . . . . . . . . R R R . . . . . . . "]^ " , , 
 , , , ^[" . . . . . . . . . . . . . . . . . . .]^ , , , 
, , " ^[. . " " . . . . . " . . . . . " " . . .]^ , , , 
 , , " ^[. " ^ . . . . . . ^ " . . . " ^ . . . .]^ " , , 
, , " ^[" . . ^ . . . . " ^ . . . . . ^ . . . .]^ " , , 
 , , , ^[. . . ^ . . . . " ^ " . . . . ^ . . . "]^ , , , 
, , " ^[. . " ^ " . . . . ^ . . . . . ^ . . . .]^ " , , 
 , , , ^[" . . ^ . . . . " ^ " . . . . ^ . . . .]^ , , , 
, , , "[" . . " . . . . . . " . . . . . " . . .], , , , 
 , , , ,[. . . . . . . . . . . . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
```

### The recast of the three wall shapes, the same day

The same run again (`--seeds 200 --width 20 --height 12`, every shape on seeds 1 to 200) after
Ryan's recast of the gorge, the city and the badlands (the bible's shapes row): cliff mass cut by
channels, tower blocks in a street grid, an open field of small mesas. The river, the fjord and
the steppe are as above.

| Shape | Open | Rough | Ruins | Water | Walls | Crossing | Opened | Route | Phases T/W/Wh/H/F | Reach T/W/Wh/H/F | Steps | Lone |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| RIVER CROSSING | 72% | 9% | 0% | 19% | 0% | 200 of 200 at 3+ | 0.0 | 11.1 | 3.0/3.0/3.0/3.0/3.0 | 33/55/78/81/82% | 0% | 0.0 |
| FJORD | 81% | 8% | 0% | 12% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/57/79/82/82% | 0% | 0.0 |
| BADLANDS | 48% | 38% | 0% | 4% | 10% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 31/52/72/73/82% | 20% | 0.1 |
| OPEN STEPPE | 98% | 0% | 0% | 1% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/59/81/81/82% | 3% | 0.0 |
| RUINED CITY | 18% | 0% | 52% | 1% | 29% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 24/38/52/53/82% | 0% | 0.0 |
| GORGE | 64% | 7% | 0% | 1% | 27% | 200 of 200 at 3+ | 0.0 | 11.7 | 3.0/3.0/3.0/3.0/3.0 | 26/38/52/53/82% | 0% | 0.0 |

Read: the three now part by mass and by the ground machines' room, where before they parted by
little. The city (29% of the field in towers, the band's seven tenths) and the gorge (27%, the
channels a third of the band) are the two heavy shapes, and their tracked reach after two phases
falls to 24% and 26% against the steppe's 35%, the hover's to 53% against 81%, the flyer's 82%
untouched: the mass costs the ground a third of its room and the flyer nothing, which is the
flyer's crossing of its own. The badlands sits between (10% in small mesas, 38% scrub, tracked
reach 31%), its paths winding but open. Every map keeps the horde's crossing at three or more
with nothing opened; the gorge's route is the one longer one (11.7 hexes against 11.0: the
channels wind). Water lies in all three as Ryan asked (the gorge's flooded stretches and the
city's streets and fountains 1% each, the badlands' ponds 4%). The relief stands (the badlands'
shoulders, the steppe's rise, the scenery's first ring level since this run). The heavy
shapes are the floor "how far we can push it" is read against: a tracked machine with a
quarter of the field in reach after two moves is still a decision, not a wall, since every
apron hex stays land and every way of moving keeps a path; past this the city's one-wide
avenues would need widening before more mass. Nothing here is a decision: the three are first
cuts for the phone (the to-do), and the counts and chances (`BattleMap.GORGE_PER`,
`GORGE_BRANCHES`, `CITY_SIDE_SEGMENT`, `CITY_FALLEN`, `BADLANDS_PER`) are placeholders.

The three at seed 7 (`--show 7`; `~` water, `^` a wall, `"` rough, `#` rubble, `=` a street or
road, `R` the rift, `G` the gate, `|` the wall, the scenery outside the brackets):

```
seed 7, GORGE, , narrowest crossing 3, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , , ,[, , , , , , , , , , , , , , , , , , , "]" , , , 
, , , ^[. . . . . . . . . R R R . . . . . . . .]^ , , , 
 , , " ^[. . . . . . . . . . . . . . . . . . . .]^ , , , 
" " , ^[. . . . . . . " " . . . . " . . . . . .]^ , " " 
 ^ ^ ^ ^[^ ^ ^ ^ ^ " . ^ . ^ ^ ^ ^ ^ " " ^ ^ ^ ^]^ ^ ^ ^ 
^ ^ ^ ^[. . . . . . . . " . ^ . ^ ^ . . ^ ^ ^ ^]^ ^ ^ ^ 
 ^ ^ ^ ^[. . . . . . . . . " . ^ ^ . ^ . ^ ^ ^ ^]^ ^ ^ ^ 
^ ^ ^ ^[. ^ " . . . . . . " . ^ ^ ^ . . " ^ ^ ^]^ ^ ^ ^ 
 ^ ^ ^ ^[^ ^ ^ . " ^ . . . ^ ^ ^ ^ ^ ^ . ^ ^ ^ ^]^ ^ ^ ^ 
, , " ,[. . . . . . . . . " . . " . " . . . . .], " , , 
 , , , ,[. . . . . . . . . . . . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, RUINED CITY, a fountain, narrowest crossing 4, the guarantee opened 0
 # # ^ ^[^ # # # ^ ^ ^ # ^ ^ ^ # ^ ^ # ^ # ^ ^ #]# ^ # ^ 
# ^ # ^[^ ^ # ^ ^ ^ # ^ # ^ ^ ^ # ^ # ^ # ^ ^ #]# # # ^ 
 ^ # # #[^ # # ^ # # # # # # # ^ ^ # ^ ^ # ^ # #]# # ^ ^ 
^ # ^ ^[# # # # # # # # . R R R . # # # # # # #]# # ^ ^ 
 # ^ # #[# # # # # # # # . . . . # # # # # # # #]^ # # ^ 
^ # # ^[# # # # # # # # # # # # # # # # # # # #]^ ^ ^ ^ 
 ^ ^ # #[^ ^ ^ ^ ^ # ^ ^ ^ ^ = # ^ ^ ^ = ^ ^ ^ ^]^ ^ # ^ 
^ # ^ #[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # ^ ^ ^ = ^ ^ ^ ^]# # # # 
 # ^ # ^[^ ^ ^ ^ ^ = = = = # = # ^ ^ ^ = ^ ^ ^ ^]# # ^ ^ 
# # ^ ^[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # ^ ^ ^ = # # ~ #]^ # # # 
 ^ # ^ #[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # ^ ^ ^ = # # # #]^ ^ ^ ^ 
# # # #[# # # # # # # # # # # # # # # # # # # #]# # # # 
 # # # #[# # # # # # # # . . = . . # # # # # # #]# # # # 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, BADLANDS, ponds, narrowest crossing 5, the guarantee opened 0
 " " " "[" ^ " " " " " " " " " " " " " " " " " "]" " " " 
" " " "[" " " " " " ^ " " " " " " " " " " " " "]" " " " 
 " " " "[" " " " " " " " " " " " " " " " " " " "]" " " " 
" " " "[. . . . . . . . . R R R . . . . . . . .]" " " " 
 " " " "[. . . . . . . . . . . . . . . . . . . .]" " " " 
" " " "[. . . . . . . . . . . . . " " . . . . .]" " " ^ 
 " " " "[" . . . ~ ~ . . . . . . " ^ " ~ ~ ~ " "]" " ^ " 
^ " " "[^ " . . . . ~ ~ . " " . . " " " . " " ^]" " ^ " 
 ^ ^ " "[" " " . " " . . " ^ " " " ^ ^ " " ^ " "]" " " " 
" " " "[^ " ^ " " ^ " ~ ~ " " " ^ " " " ^ " " ^]" ^ " " 
 " " " "[" " " ^ " ^ " . ~ . . " " ^ ^ " ^ " " ^]" " " " 
" " " "[. . . " " " " . . . . . . " " " " " . "]" " " " 
 " " " "[. . . . . . . . . . . . . . . . . . . .]" " " " 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
```

## 10 November: the shapes laid to the rift's row

The same run (`--seeds 200 --width 20 --height 12`, every shape on seeds 1 to 200) after Ryan's
play of the 9 November shapes ("the flattened side needs features, all the way to the back"): the
rift's mouth is the bared ring beside the rift and nothing more, so every shape lays from the
rift's row and has eight open rows at twelve deep where it had five.

| Shape | Open | Rough | Ruins | Water | Walls | Crossing | Opened | Route | Phases T/W/Wh/H/F | Reach T/W/Wh/H/F | Steps | Lone |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| RIVER CROSSING | 68% | 10% | 0% | 22% | 0% | 200 of 200 at 3+ | 0.0 | 11.1 | 3.0/3.0/3.0/3.0/3.0 | 35/55/78/82/82% | 0% | 0.0 |
| FJORD | 72% | 10% | 0% | 19% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/57/77/82/82% | 0% | 0.0 |
| BADLANDS | 31% | 50% | 0% | 4% | 15% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 31/51/69/70/82% | 19% | 0.6 |
| OPEN STEPPE | 98% | 0% | 0% | 1% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/59/81/81/82% | 3% | 0.0 |
| RUINED CITY | 27% | 0% | 27% | 1% | 45% | 200 of 200 at 3+ | 0.5 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 23/35/46/46/82% | 0% | 0.0 |
| GORGE | 47% | 8% | 0% | 1% | 45% | 200 of 200 at 3+ | 3.0 | 11.6 | 3.0/3.0/3.0/3.0/3.0 | 24/35/45/45/82% | 0% | 0.0 |

Read: with eight rows to lay in the heavy shapes are heavier (the city 45% of the field in towers
where it had 29%, the gorge 45% in cliffs where it had 27%) and the ground's room smaller (tracked
reach after two phases 23% and 24%, hover 46% and 45%, against the steppe's 35% and 81%; the
flyer's 82% untouched). The gorge is the first shape the guarantee has to open for: 3.0 hexes a
map on average, where every other shape opens none or next to none (the city 0.5), since its
trunks start at the rift's row now and the rift's ring is bared after them; a trunk that does not
meet the ring is opened to it. The river and the fjord grew with the band (22% and 19% water) and
the badlands' scrub covers half the field at the mesas' feet. Every map keeps the crossing at
three or more and every way of moving its path; the route is unchanged but the gorge's (11.6).
This is the edge of "how far we can push it" at today's counts: a tracked machine with a quarter
of the field in reach after two moves, and a city or a gorge nearly half walls. Nothing here is
a decision: Ryan judges the look on the phone (the to-do), and the counts are placeholders.

Every shape at seed 7 (`--show 7`; `~` water, `^` a wall, `"` rough, `#` rubble, `=` a street or
road, `R` the rift, `G` the gate, `|` the wall, the scenery outside the brackets):

```
seed 7, RIVER CROSSING, river, narrowest crossing 5, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[. . . . . . = . . R R R . = . . . . . .], , , , 
 , , , ,[. . . . " . = . . . . . . = . . . . . .], , , " 
" " " "[~ . . ~ ~ . = " " . " . . = ~ ~ ~ " . "], , " ~ 
 ~ ~ ~ ~[~ ~ ~ ~ ~ " = ~ ~ ~ . . " = ~ ~ ~ ~ ~ ~]~ ~ ~ ~ 
~ ~ ~ ~[~ ~ ~ ~ ~ . = ~ ~ ~ ~ ~ ~ = . ~ ~ ~ ~ ~]~ ~ ~ ~ 
 " , , ~[~ . . . . = ~ . ~ " ~ ~ = . . . ~ ^ ~ ~]~ ~ ~ , 
, , , ~[" . . . . . = = = = ~ ~ ~ = . . " ^ " "]" , " , 
 , , " ,[. . . . . . . . . = " " = . . . . . . .], , , , 
, , , ,[. . . . . . . . . . = . = . . . . . . .], , , , 
 , , , ,[. . . . . . . . . . = = . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, FJORD, fjord, narrowest crossing 5, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , , ,[, , , , " " " , , , , , , " " , , , , ,], , , , 
, , , ,[. . . . . ~ ~ . . R R R . ~ ~ " . . . .], , , , 
 , , , ,[. . . . " ~ ~ " . . . . . ~ ~ . . . . .], , , , 
, , , ,[. . . . . ~ ~ ~ " . . . " ~ ~ " " . . .], , , , 
 , , , ,[. . . . " ~ ~ . . . . . " " ~ ~ . . . .], , , , 
, , , ,[. . . . . ~ ~ . " . . . . . . ~ ~ . . .], , , , 
 , , , ,[. . . . . ~ ~ ~ . . . . . . ~ ~ . . . .], , , , 
, , , ,[. . . . " ~ ~ " . . . . . ~ ~ " " . . .], , , , 
 , , , ,[. . . . ~ ~ . . . . . . . " ~ ~ . . . .], , , , 
, , , ,[. . . . " . . . . . . . . . " . " . . .], , , , 
 , , , ,[. . . . . . . . . . . . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, BADLANDS, ponds, narrowest crossing 5, the guarantee opened 0
 " " " "[" " " " " " " " " " " " " " " " " " " "]^ " " " 
" " " "[" " " " " " " ^ " " " " ^ " " " " " " "]^ ^ " " 
 ^ " " "[" " " " " " " " " " " " " " " " " " " "]" " " " 
" " " "[. . " " ^ " ^ " . R R R . ^ " . " " . .]" " " " 
 " " " "[. " ^ " " " " ~ . . . . ^ " . " ^ " " "]" " " " 
" " " "[" " " " . " " ~ . " ^ " " " " " " " ^ ^]" " " " 
 ^ " " "[^ " . . " ^ " " " " " ^ ^ " ^ " ^ " " "]" " " " 
^ ^ " "[" " . ~ . " " " ^ ^ " " " " ^ ^ " " ^ "]" " " " 
 " " " "[^ " . ~ ~ " ^ " " " " " . " " " . " " ~]" " " " 
^ " " "[^ " " ~ " " " " . " ^ ^ " " " ^ " . ~ ~]" " " " 
 " " " "[" ^ " " ^ " ^ " . " " " ^ " " " . . . .]" " " " 
" " " "[. " " . " " " " . . . . " " . . . . . .]" " " " 
 " " " "[. . . . . . . . . . . . . . . . . . . .]" " " " 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, OPEN STEPPE, , narrowest crossing 5, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , ^ , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , ^ , ,], , , , 
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[. . . . . . . . . R R R = . . . . . . .], , , , 
 , , , ,[. . . . . . . . . . . . = . . . . . . .], , , , 
, , , ,[. . . . . . . . . . . . = . . . . . . .], , , , 
 , , , ,[. . . . . . . . . . . = . . . . . ^ . .], , , , 
, , , ,[. . . . . . . . . . . . = . . . . . . .], , , , 
 , , , ,[. . . . . . . . . . . = . . . . . . . .], , , , 
, , , ,[. . . . . . ^ . . . . = . . . . . . . .], , , , 
 , , , ,[. . . . . . . . . . = . . . . . . . . .], , , , 
, , , ,[. . . . . . . . . . . = . . . . . . . .], , , , 
 , , , ,[. . . . . . . . . . = . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, RUINED CITY, a fountain, narrowest crossing 3, the guarantee opened 1
 ^ ^ # ^[# # ^ # # ^ ^ # ^ ^ ^ ^ # ^ ^ ^ ^ ^ # ^]^ ^ # ^ 
^ ^ ^ #[^ # ^ # # # ^ # ^ ^ ^ # # ^ ^ ^ ^ # # #]^ ^ # ^ 
 ^ ^ ^ ^[# # # # # # ^ ^ ^ # # # ^ ^ ^ ^ ^ # # ^]# ^ # ^ 
^ # # ^[^ ^ ^ ^ ^ = ^ ^ . R R R . ^ ^ # ^ ^ ^ ^]^ # ^ ^ 
 ^ # ^ #[^ ^ ^ ^ ^ = ^ ^ . . = . ^ ^ ^ # ^ ^ ^ ^]^ # ^ # 
# # ^ #[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # . ^ ^ = = = = =]^ # # # 
 ^ ^ ^ ^[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # # # # = ^ ^ ^ ^]^ # ^ ^ 
# # # #[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # # # # = ^ ^ ^ ^]# # ^ # 
 ^ # # ^[^ ^ ^ ^ ^ = ^ ^ ^ ^ # = = = # = = = = =]^ # # ^ 
^ ^ # #[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # # # # = ^ ^ ^ ^]# # # # 
 ^ # ^ ^[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # # ~ # = ^ ^ ^ ^]# # # ^ 
# # # #[# # # # # # # # # # # # # # # # # # # #]# # # # 
 # # # #[# # # # # # # # . . = . . # # # # # # #]# # # # 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, GORGE, flooded channels, narrowest crossing 4, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , , ,[" , , , , , , , , , , , , , , , , , , "]" " " , 
^ ^ ^ ^[^ ^ ^ ^ ^ . . . . R R R . . . " ^ ^ ^ ^]^ ^ ^ ^ 
 ^ ^ ^ ^[^ ^ ^ ^ ^ . . . . . . . ^ . . ^ ^ ^ ^ ^]^ ^ ^ ^ 
^ ^ ^ ^[^ ~ ^ ^ ^ . ^ " " ^ ^ ^ . " . ^ ^ ^ ^ ^]^ ^ ^ ^ 
 ^ ^ ^ ^[^ ~ " " . " . . . ^ ^ ^ " " ^ ^ ^ ^ ^ ^]^ ^ ^ ^ 
^ ^ ^ ^[^ ^ ~ . . . . . " . ^ . " . . ^ ^ ^ ^ ^]^ ^ ^ ^ 
 ^ ^ ^ ^[^ ^ ^ ~ . . . ^ ^ " ^ . . . . ^ ^ ^ ^ ^]^ ^ ^ ^ 
^ ^ ^ ^[^ ^ ^ ^ ^ ~ ^ ^ . " . . . " ^ ^ ^ ^ ^ ^]^ ^ ^ ^ 
 ^ ^ ^ ^[^ ^ ^ ^ ^ ~ ^ ^ . ^ ^ " . ^ ^ ^ ^ ^ ^ ^]^ ^ ^ ^ 
, , " ,[. . . . . . . " " " . . . . " . . . . .], " , , 
 , , , ,[. . . . . . . . . . . . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
```
## 9 November, the flankers' segments

Ryan, 9 November: "the flankers should target their closest wall with a small amount of
randomness, avoiding crowding, in order to force the player to make decisions". The rule built on
`claude/playtesting-ui-feedback-hfdiok` (a pusher's segment about the wall nearest where it is dealt:
a rift pack within the ramp's spread of the rift's column, any other within 2 of its own, the least
crowded column of the window winning) read against the rule before it (every pusher within the
ramp's spread of the rift's column), the same code but `Battlefield.assign_goal`, the old rule from
a worktree at `bc36ed9`. Each read is a direction and called one.

### The pushers on 160 opening battles, nobody fighting

A probe (the scratchpad's, not kept): seeds 1 to 40 on each domain, the default team standing
where it opens, twelve enemy turns or the battle's end.

| Measure | Before | After |
|---|---|---|
| A pusher's segment from the column it was dealt at, mean | 5.22 | 0.91 |
| Pushers with a segment more than 4 columns away | 308 of 656 | 0 of 492 |
| Pushers stuck (short of the wall, not moving, 3 turns) | 0 | 0 |
| Walks that waited (no way to the wall) | 0 | 0 |
| A turn's column shared by two pushers' segments, counted a column a turn | 752 | 0 |

Fewer pushers are counted after because the gate falls sooner with nobody fighting: the flankers
strike their own ends of the wall within two turns instead of crossing to the middle.

### The campaign runner, 40 runs each

`tools/campaign_run.gd -- --runs 40`, every map shape by its seed, the defence rule on the map (the
floor, not the player: Ryan, 6 November, "I wouldn't count anything until we've got everything in
place").

| Measure | Before | After |
|---|---|---|
| Battles: won, fell, wiped | 2%, 82%, 90% of 195 | 3%, 86%, 87% of 184 |
| Gate damage a battle, of 200 | 124 | 135 |
| The pressure ratio, a run's mean over its turns | 1.16 | 1.70 |
| Turns above 1.0, percent of a run's | 29 | 40 |
| A battle's highest ratio, a run's mean | 2.34 | 3.09 |
| Favour paid per won battle, of 100 | 89 | 65 |
| Turns a run | 6.03 | 5.75 |
| Fractures reached a battle | 0.90 | 0.99 |

The direction: the tide spread along the wall asks more of the squad's split, as the rule meant
it to; the defence bot, which sends each machine at the pack that reaches the wall soonest, leaks
more, a third more turns above a ratio of one. The full report is `docs/campaign_run.md` (after).

## 9 November, the Polar Bear's seal and lure, before the kit of the same day

**Why**: Ryan's play ("The Armadillo is OP. I never really felt strongly about Sealing it"), read
before his try of the same day landed (the bible's Polar Bear row). A scratch probe, not
committed, and this section is its whole description: the balance runner's fight
(`tools/balance.gd`'s `_fight`, a composition's members and grid as `--packs promise` fields
them) on a skirmish whose every blow on a machine is recorded as it lands (what arrived, what its
shield took, what its armour took and the seal's own share of that, what reached its hull,
breach or not), with the fight's lures and seals counted from its log. Main's `ee0b27d` (the
kit of 20 October: armour 2, Lockdown +3, two Rapid Cryo Flingers at 1 heat), tier one's 27
compositions (patrols, formations, elites; elites scaled as a battle scales them) and tier two's
42, 30 seeds a cell: a direction throughout. The team is the one Ryan reported from on 8 November
(the Polar Bear, the Honey Badger, the Clydesdale) unless a row says another. The players: the bot
as built (greedy, and the planner where said); two personas over the greedy rung, a lure-happy
one (each foe a lure turns worth the whole blow it takes off an ally, on top of the bot's own
reading) and a seal-holder (the same, sealing whenever a shield shows with room for two sealed
turns and holding it while the coming turn's end stays under the maximum, a vent or the clock
opening it). What-ifs as kits in memory: the Flinger without its lure, without Rapid; a stand-in
for the lure spreading while sealed (no Rapid, the lure turning the target's neighbours too, its
Cryo not spreading and no bot valuing it); and the seal's armour taken off a blow before its
shield rather than after.

**The seal**, per fight, over tier one's 27 compositions:

| Player and kit | Seals | Blows on the sealed shell | Taken whole by its shield | Breach | Hull the seal's +3 saved | Team hull lost | Rounds |
|---|---|---|---|---|---|---|---|
| The bot | 0.22 | 0.18 | 0.16 | 0.01 | 0.01 | 6.8% | 4.04 |
| The bot, the planner | 0.25 | 0.20 | 0.17 | 0.01 | 0.02 | 6.6% | 3.99 |
| The bot, armour before shield while sealed | 0.21 | 0.16 | 0 | 0.01 | 0.31 | 6.7% | 4.03 |
| Lure-happy, never holding | 0.28 | 0.36 | 0.28 | 0.01 | 0.07 | 7.3% | 4.05 |
| Seal-holder | 1.11 | 1.19 | 0.69 | 0.30 | 0.26 | 7.7% | 4.28 |
| Seal-holder, armour before shield | 1.12 | 1.17 | 0 | 0.30 | 1.53 | 7.3% | 4.28 |
| Seal-holder, no Rapid, the lure spreading sealed | 1.00 | 1.23 | 0.64 | 0.28 | 0.52 | 8.3% | 4.47 |
| The same, armour before shield | 0.99 | 1.22 | 0 | 0.28 | 1.62 | 8.0% | 4.44 |

Tier two, the 42 compositions, the same team: the bot 15.0% team hull lost (the seal's +3 saving
0.20 hull a fight), the seal-holder 16.4% (0.86), the seal-holder with armour before shield 15.4%
(3.57).

**The lure**, the lure-happy player, formations, a fight:

| Team and kit | Team hull lost | The Polar Bear's hull | The allies' | Its share of the blows | Lures | Components destroyed |
|---|---|---|---|---|---|---|
| As built | 12.9% | 11.3 | 3.6 | 68% | 2.2 | |
| The Flinger's lure removed | 12.7% | 4.6 | 10.1 | 32% | 0 | |
| Its Rapid removed | 13.9% | 11.6 | 4.5 | 64% | 1.9 | |
| The Storm Petrel in its seat | 11.6% | 4.7 | 6.9 | 45% | | |
| With the Skua and the Cassowary, as built | 35.3% | 15.8 | 13.8 | 58% | | 1.30 |
| With the Skua and the Cassowary, the lure removed | 35.4% | 11.9 | 17.8 | 37% | | 1.65 |

The elites and the patrols read the same way (the team's total within two points, the allies'
hull falling by three fifths beside the Badger and the Clydesdale, by a fifth to a third beside
the light pair). Of the hull the lured-on Polar Bear lost, 77% was
breach on the formations and the elites and 95% on the patrols. Over every tier-one composition
the planner lost 6.6% team hull with the Polar Bear and 5.8% with the Storm Petrel in its seat
(3.99 rounds against 3.59); caught alone by tier one's patrols, the bot's Polar Bear won 57 to 61%
for 64% of its hull in 11 rounds, the Storm Petrel 59% for 55% in 6.

Read, a direction:
- The seal's armour met almost no blow. Three rules meet: a shield takes a blow whole before
  armour and takes no armour off; the shield is full as every fight opens; the seal is entered by
  a shield spent on itself, so the spend that seals it tops up the shield in front of the armour,
  and the bot's next gun opens it. Held, it saved a quarter of a hull a fight and cost more in the
  guns not fired; with its armour before the shield it saved one and a half and held even with the
  player who never holds, at tier two within half a point of the bot.
- The lure moved the team's blows onto the Polar Bear without lessening them: three full shields
  soak a fight's blows spread by random picks, and one shield piled on spills into one hull, most
  of what reached it breach. Beside light allies it broke a fifth fewer of their components on
  the formations (1.30 against 1.65 a fight), 6 to 14% fewer on the elites and the patrols.
- Rapid barely moved a row: the lure's alternative is a 2-damage basic.
- The runner does not read the Polar Bear as OP against its peer: Ryan's play is the evidence, and
  his try of 9 November is judged there.

## 9 November, the Lammergeier's Mines on foes

Ryan's rework of the day (the bible's Lammergeier row): every spend it aims at a foe leaves a Mine
there, a flat 2 and the spend's keywords, blowing in Splash's shape round its slot when the foe
falls; the Syrinx Drone detonates and the Lorentz Contractor gathers. `tools/balance.gd`, 30 seeds
a cell (a direction), random and greedy, no party, alone, the matrix's 78 packs in six groups
(tier one's rank and file 13, its four big foes, its four formations, the ladder's recolours at
tiers two and three 36, their formations 8, the thirteen bosses alone), before on main at
`f4906ee` (the slot mines) and after on `ccr-a0b35006-od22d2` at `37e0b5a`, beside the other tier
threes. The four other rows came out identical cell for cell before and after, so the engine's
change moved no machine but the Lammergeier.

| Row | Tier one's rank and file | Its big four | Its formations | Tiers two and three | Their formations | The bosses | Every pack |
|---|---|---|---|---|---|---|---|
| Lammergeier, slot mines | 10 / 83 | 0 / 2 | 0 / 0 | 12 / 64 | 0 / 0 | 0 / 1 | 7 / 43 |
| **Lammergeier, Mines on foes** | 78 / 93 | 8 / 10 | 0 / 0 | 62 / 69 | 0 / 0 | 2 / 13 | 42 / 50 |
| Musk Ox | 85 / 89 | 0 / 0 | 0 / 0 | 64 / 67 | 0 / 0 | 1 / 5 | 44 / 47 |
| Giant Petrel | 65 / 90 | 3 / 34 | 0 / 0 | 57 / 69 | 0 / 0 | 0 / 10 | 38 / 50 |
| Ammit | 75 / 84 | 0 / 0 | 0 / 0 | 59 / 66 | 0 / 0 | 0 / 1 | 40 / 45 |
| Swallowtail | 43 / 74 | 0 / 0 | 0 / 0 | 41 / 62 | 0 / 0 | 0 / 7 | 26 / 42 |

Pick share, greedy: before, the Arc Fault Cannon 29%, the Enfilade Beam 27%, the Incendiary Shells
25%, the Syrinx Drone 6%, the Polarity Projector 5%, the Lorentz Contractor 4%; after, the Arc Fault
Cannon 25%, the Enfilade Beam 23%, the Syrinx Drone 21%, the Incendiary Shells 19%, the Lorentz
Contractor 5%, the Polarity Projector 5%. Its heat as a turn ends, greedy: a peak of 34% of its
maximum before, 27% after.

The direction: from the band's floor to its top, every pack 42 / 50 against the Musk Ox's 44 / 47
and the Giant Petrel's 38 / 50, the best of the band on the bosses greedy (13%), and the random rung
up from 7 to 42, so most of the old gap between the rungs was the slot mines' spends a player had
to find. Neither a wall nor a free win in any group the band shares; formations stay at 0 for the
whole band alone. The detonation carries the gain (picked 21%, from 6%); the gather is still
rarely picked (5%), which reads either as the bot's valuation of a Mine to come or as the piece,
for Ryan's play to say. Not weak, so the per-hit lever (his: "then look at per hit later if it's
weak") stays on the shelf for now; whether the AoE Expose or a Suppress Mine is dangerous is a
team question this solo read cannot answer.

The same day the Mine's riders became the spend's whole result on its target (every hit's
stacks as its machine laid them, Ryan's word, `ccr-a0b35006-od22d2` after `31a87f2`). The read
stands: no piece the Lammergeier fields here strikes more than once, and nothing on it deepens or
doubles a stack, so every Mine it lays carries what it carried when the read ran.

## 9 November, the formation pass's reads

The reads behind `docs/formation_proposal.md` (the decision they inform: the grids' ratings,
gates and pruning, and section 12's hunter questions; nothing moved in content). Method: the
proposal's patrols and formations were written to a scratch worktree's `content/factions.json`
(the elites and escorts as content has them), validated by `sim/content_db.gd`, and read by the
curve read (`tools/balance.gd --packs curve --seeds 30 --sizes patrol,formation`), random and
greedy, each composition against a team cut to one, two, three and four machines, each cell its
band (free: random wins half or more; a decision: greedy wins half or more and random less; a
wall: greedy wins less than half) with greedy's mean hull lost. Four teams in stock, by `--team`
(new today): the default four (the Honey Badger, the Clydesdale, the Kite, the Baboon) on every
tier; a light four (the Skua, the Prairie Dog, the Cottonmouth, the Puffin), the Skua alone the
rating of one's read, on every tier; a tier-two four (the Wild Boar, the Clydesdale, the Buzzard,
the Dingo) on tiers two and three; a tier-three four (the Swallowtail, the Musk Ox, the Ammit, the
Giant Petrel) on tier three. Today's compositions were read with the default four beside them.
Every cell is a direction at 30 seeds and is called one; the proposal's tables (its section 12)
carry every cell, and the gates and the pruning it proposes are read off them by the rule in its
section 5. A stall (the fight bot's sixty rounds) counts as no win, so a wall with little hull
lost reads as a stall and is named where it shows.

### The curve reads: today's compositions and the proposal's

The counts at the rating, by tier and size (a cell a composition at a tier; free / a decision /
a wall; greedy's mean hull lost at the rating):

| Read | Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost |
|---|---|---|---|---|---|---|---|
| Today, the default four | 1 | formation, 3 | 8 | 8 | 0 | 0 | 10% |
|  | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 24% |
|  | 2 | formation, 3 | 13 | 9 | 4 | 0 | 14% |
|  | 2 | patrol, 1 | 8 | 3 | 2 | 3 | 54% |
|  | 3 | formation, 3 | 17 | 8 | 7 | 2 | 35% |
|  | 3 | patrol, 1 | 4 | 1 | 3 | 0 | 50% |
| Default four | 1 | formation, 3 | 15 | 13 | 2 | 0 | 9% |
|  | 1 | patrol, 1 | 12 | 12 | 0 | 0 | 7% |
|  | 1 | patrol, 2 | 5 | 5 | 0 | 0 | 7% |
|  | 2 | formation, 3 | 15 | 11 | 4 | 0 | 15% |
|  | 2 | patrol, 1 | 10 | 8 | 2 | 0 | 21% |
|  | 2 | patrol, 2 | 5 | 5 | 0 | 0 | 8% |
|  | 3 | formation, 3 | 18 | 8 | 8 | 2 | 35% |
|  | 3 | patrol, 1 | 6 | 4 | 2 | 0 | 30% |
|  | 3 | patrol, 2 | 6 | 5 | 1 | 0 | 13% |
| Light four | 1 | formation, 3 | 15 | 9 | 3 | 3 | 26% |
|  | 1 | patrol, 1 | 12 | 8 | 1 | 3 | 41% |
|  | 1 | patrol, 2 | 5 | 3 | 1 | 1 | 28% |
|  | 2 | formation, 3 | 15 | 4 | 7 | 4 | 41% |
|  | 2 | patrol, 1 | 10 | 3 | 0 | 7 | 73% |
|  | 2 | patrol, 2 | 5 | 2 | 0 | 3 | 56% |
|  | 3 | formation, 3 | 16 | 0 | 7 | 9 | 72% |
|  | 3 | patrol, 1 | 6 | 0 | 1 | 5 | 92% |
|  | 3 | patrol, 2 | 6 | 3 | 0 | 3 | 55% |
| Tier-two four | 2 | formation, 3 | 17 | 11 | 6 | 0 | 18% |
|  | 2 | patrol, 1 | 10 | 9 | 0 | 1 | 21% |
|  | 2 | patrol, 2 | 5 | 5 | 0 | 0 | 9% |
|  | 3 | formation, 3 | 18 | 9 | 7 | 2 | 37% |
|  | 3 | patrol, 1 | 6 | 5 | 1 | 0 | 30% |
|  | 3 | patrol, 2 | 6 | 5 | 1 | 0 | 15% |
| Tier-three four | 3 | formation, 3 | 19 | 9 | 6 | 4 | 44% |
|  | 3 | patrol, 1 | 6 | 0 | 4 | 2 | 70% |
|  | 3 | patrol, 2 | 6 | 5 | 0 | 1 | 24% |

The proposal's table counts the candidates before the pruning its section 5 proposes (the
default four's tier-one patrol count of twelve includes the needler pair, the antlion pair and
the salamander pair, each pruned, and the ember pair, written after the first read). The light
four is tier one's stock, so its tier-two and tier-three rows read a light team a tier short, not
a light flanker of the tier.

Read, in bands, a direction:

- **Tier one's formations stay free for three.** Today's eight read free at their rating (10%
  hull); the proposal's fifteen read thirteen free and two decisions, both massive-anchored (the
  sandworm ambush at 37%, the magma vent at 41%, the only two of today's that were decisions
  for two), and the eight-slot variants move no band at three against the six they fill out
  (the goblin horde against the warband, the needler thicket against the swarm, the grave throng
  against the host, the ember pyre against the pit): the counts are at the slots' ceiling and
  the fodder formations' lever is the refit's numbers, held until Ryan plays Phase 2. The light
  four finds three of them decisions at three (the treant grove 16%, the barrow mound 23%, the
  ember pyre 27%) and walls on the three with a massive, since four stock lights cannot pass a
  point of plate on thirty-six HP that regrows; the knights wall it too.
- **The true ones exist.** Every patrol rated one is free for the Badger alone (7% hull against
  today's 24% with the knight's retinue's wall among them), and free or a decision for the Skua
  alone in every domain but the Peak's, whose salamander pair, trio and drakes' perch wall it
  (91 to 100% hull): the ember pair, written after the first read, is free for both (25% and
  0%). The ghost light is the Skua's one decision at tier one (51%); the Marsh's knight's
  retinue, today a patrol for one and a wall for one, is a two in the proposal and reads one
  (a wall for the Badger alone, free for a pair at a third of its hull; a wall for the light four
  up to three).
- **The twos.** The proposal's heavy patrols read as twos where they carry a knight, a pit or a
  queen: the antlion trio a decision for the Badger alone (36%) and a wall for the Skua, the pit
  pair a decision for the Badger and the Boar alone (76%), the queen's hunt a wall for either
  alone and free for a pair, the knight's retinue a wall for the Badger alone, the knight and
  wights a wall for the Boar alone and a decision for the Badger at 88% of its hull, the lizard trio and the wyverns' perch walls for the Boar alone, the grenade and
  balloon flights walls for the Skua and free for every pair. The wolf pack (free for the Skua
  at 21%, for the Badger at 4%), the warg pack (a decision for the Skua at 40%, free for the
  Badger and the Boar) and the bomb flight (a decision for the Skua at 48%, free for the Badger)
  read as ones: a blow of four kills a wolf or a bomb whole.
- **Tier two, read by its own team**, keeps the shape: the single-anchor formations are decisions
  for two and free for three (the treant march 10% at three, the pit ambush 16%, the wyvern roost
  10%, the grenade volley 8%, the grave field and the death knight's retinue the exceptions at
  21% and 36%), the worm and the forge true threes (the sandworm pit 44%, the magma forge 52%),
  and the two-anchor candidates written after the first read are true threes: the grove and
  bloom (a dusk treant and a rotbloom) a wall for two and a decision for three at 41%, the pit
  wall (four pit antlions behind the Waste's casters) at 43%, the frost and bloom at tier three a
  decision for three at 56% and for four at 31% a tier short. The fodder formations read
  decisions for one (the guard horde 66%, the gel drift 73%, the barbed swarm 89%, the djinn's
  mirage 78%).
- **The pruning the bands name**: fourteen candidates whose bands match another's at every size
  with the same question (the proposal's section 5), the six-slot half of each ramp pair among
  them, the antlion pair against the trio, the needler pair against the scouts, the salamander
  pair against the trio, the djinn's mirage against the barbed swarm, the bubble pair, the
  gorgon glare today against the great swarm.
- **A stall.** The light four against the grave field reads a wall at four with 12% hull lost,
  which is a stall, traced (`--trace`, the greedy rung, seed 1): the Grave Giant knits three a
  round while four light kits chip one or two through its plate, and its blow of eight never
  passes the shields they raise; sixty rounds, nobody loses hull. The Marsh's giants carry no
  escalation (a cleaver, a knit, a rise), so a kit that cannot out-damage the knit cannot lose or
  win; the proposal's hole 8.
- **The elites, today's cells, for the elites' item** (section 12 of the bible): the lone elites
  are free for the Badger alone (the Reaper at 0%, the Fell Rider 11%, the Thunder Ape 30%,
  the Rust Monster 18%, the Shaman's warband 13%), decisions for one at most (the Nob 28%, the
  Leshy's hunt 42%, the Wild Hunt 55%); the ones with a massive or a court are decisions for
  two or three (the Old Man's rising 41% at three, the Skeleton King's court 50% at three, the
  Firelord's rising 11% at three, the Astromancer 31% at two); every elite is free for four at
  tiers one and two, the Old Man at tier three a decision for four. Unchanged by this pass; his
  "don't downgrade them" stands.
- **Tier three, read by its own team** (the Swallowtail, the Musk Ox, the Ammit, the Giant
  Petrel), reads harder alone than tier two's did, since the Swallowtail is a support frame
  (every fodder patrol a decision for it at 42 to 75% hull where the Boar found them free), and
  much the same at three: the frost and bloom (72%), the sandworm flats (76%), the queen's court
  (48%), the dragon's roost (43%) and the magma caldera (89%) are decisions for three; the lich's
  court walls three and is a decision for four on every read (59 to 81% hull), the dread host
  walls four on every read (85 to 96%), and the charnel pit walls three for this team (68%) where
  the default and tier-two teams found it a decision (46%, 61%). The Marsh had no tier-three
  formation that is a decision for three, so today's wraith choir (two death knights, two wights,
  two wraiths, two spectres) was read again: a decision for three for the default four (68%) and the tier-two four (71%), a wall for the
  tier-three four at three (84%) and a decision at four (30%), the charnel pit's shape (46%, 61%,
  68% and 16%): the Marsh's tier-three formations are decisions for the mixed stock teams and walls
  for a tier-three trio with no burst for the knit, the Swallowtail, the Musk Ox and the Ammit.
  A thinner host (one death knight, three wights, two wraiths, a spectre) was written and read
  after that: a decision for three for the default four at 27% and for the tier-three four at 44%, a wall
  for two on both: the Marsh's tier-three three, the choir and the pit beside it.

### The campaign runner: 40 runs on the steppe, today's content and the proposal's

`tools/campaign_run.gd -- --runs 40 --shape steppe`, the same seeds, on main's content as it
stands (267 s) and on the proposal's grids in a scratch worktree (the same code; the patrols and
formations the proposal's, the elites and escorts today's). The greedy rung, the defence rule on
the map, three of the tender at random: the floor the brief built for these reads, not the
player (the to-do's runner line).

| Measure | Today | The proposal |
|---|---|---|
| Runs won | 0 of 40 | 0 of 40 |
| Turns a run | 5.85 (5 to 8) | 6.30 (5 to 8) |
| The turn the first city fell | 0.50 | 0.60 |
| Battles: won, held after a wipe, fell | 1%, 14%, 83% of 191 | 3%, 18%, 77% of 206 |
| Battles ended in a team wipe | 92% | 91% |
| Machines wrecked a battle | 1.71 | 1.69 |
| Components destroyed a battle | 0.98 | 0.52 |
| Phases a battle | 6.17 (1 to 12) | 6.16 (1 to 11) |
| Gate damage a battle | 128 | 116 |
| Peaks of Rift Pressure a battle | 1.18 | 1.27 |
| Patrols the tears sent a battle | 1.86 (0 to 28) | 1.57 (0 to 28) |
| Elites spawned a battle | 0.42 | 0.45 |
| Fractures reached a battle (of about 3) | 0.87 | 0.99 |
| Battles reaching the Rupture | 16% | 21% |
| The pressure ratio, a run's mean | 1.02 (0.30 to 2.65) | 1.25 (0.29 to 3.62) |
| Turns above 1.0, percent of a run's | 26 | 28 |
| Battles by three machines: won, fell | 6%, 57% of 47 | 15%, 55% of 45 |
| Battles by one machine: fell | 97% of 78 | 73% of 80 |

The fights, by the pack's rating and the machines the defence rule sent at it:

| A fight for | Machines in it | Today: fights, won | The proposal: fights, won |
|---|---|---|---|
| 1 | 1 | 86, 63% | 135, 82% |
| 1 | 2 | 51, 82% | 28, 100% |
| 1 | 3 | 31, 90% | 4, 100% |
| 2 | 1 | — | 11, 27% |
| 2 | 2 | — | 2, 0% |
| 3 | 1 | 169, 8% | 229, 10% |
| 3 | 2 | 69, 56% | 78, 66% |
| 3 | 3 | 53, 100% | 51, 100% |
| 4 | 1 | 30, 26% | 55, 27% |
| 4 | 2 | 37, 59% | 31, 87% |
| 4 | 3 | 15, 100% | 12, 91% |

Read, in bands, a direction. The campaign stays a wall for this bot either way (no run won, the
first city on the first turn, nine battles in ten a wipe): the defence rule sends a lone machine at
a formation 229 times and wins one in ten, which is the floor's shape, not the content's. Where the
content shows: a patrol rated one fought by one machine is won 82% on the proposal's grids against
63% today, so the true ones read as ones for the bot's random tier-one machines; a pack rated two
fought alone is won 27% of 11, a fight for two as its rating says; the pressure ratio rises (1.25
against 1.02, since more patrols stand on the field and a two counts two); components destroyed a
battle halve (0.52 against 0.98) and the gate takes less (116 against 128), the lighter patrols
costing less; a battle by three machines is won 15% against 6%. One fight stalled past the bot's sixty
rounds on the proposal's grids (none today), unread: the runner names no pack for it.

## 9 November, the refit pass's first reads

The reads behind the refit pass's brief (`docs/briefs/refit_pass.md`; the decisions they inform:
the defensive basic and its rule, the regen's size, the heat levers, breach under a regen, the
pushers' hull budget; nothing moved in content). Method: the what-if (`sim/refit.gd`, `--refit
SPEC` on both runners) lays the model over the loaded content for a run and names what it did in
the report's head. `die` swaps every stock shield and vent for a defensive basic in its own slot
(a shield spent on its own machine for the Armoured piece, any other shield for the Barrier piece,
a vent for whichever of the two the die lacks, else a tier-zero gun), leaves the four machines
the model cannot field undealt (the Polar Bear, the Puffin, the Whip Scorpion, the Swallowtail)
and lets the Stingray cool one; the tier-one Blast Door and Shoring Jack stand in for the Halo
Projector and the tier-zero Jack the audit names. That fill puts a Barrier on nearly every die;
`vents=guns` gives a vent's slot a gun instead, so a die holds a defensive basic only where a
shield stood, which is the audit's own deal (a Barrier where a Halo stood: the Baboon, the
Prairie Dog, the Stingray, the Cassowary, the Cottonmouth, and the Arsenal's two). `regen=half` gives every chassis half its gauge
a round, rounded up (the Badger 4, the Clydesdale and the Baboon 5, the Kite 8, the Skua 6), and
`regen=N` a flat N; `heat1` puts the tier-zero guns at heat one (the Twin Autoguns, the Rivet
Gun); `cooling=N` cools every chassis N more; `barrier=off`, `cooldown`, `heatN` and `ward` are
rules for the Barrier basic (none among the basics, an Armoured piece or a gun in its place;
dark the round after it is spent; N heat a spend; a Ward, the Decoherence Veil, in its place);
`all` is the die, half the gauge and heat one, and is what a section below means by the model
where it names no deal: a Barrier on every die. `--guard 0.05` is the
aggressor's habit for the fight bot (`Policy.guard_weight`: a block, a Barrier, Armoured or a
Ward, at a twentieth of its worth, so the bot never rerolls for one and spends one only when its
die is stuck showing it), read against the rung as it is, which takes every block worth making.
The injury rule is off in every read but the one that names it (`Skirmish.injuries`, off in the
game since this day; `--injury on` reads it back).

The curve read (`tools/balance.gd --packs curve --seeds 30`), random and greedy, each composition
against a team cut to one, two, three and four machines; a cell now carries greedy's mean rounds
and its stalled fights beside the band and the hull lost. The default four (the Honey Badger, the
Clydesdale, the Kite, the Baboon, in that cut order) unless a team is named; the light four is
the Skua, the Prairie Dog, the Cottonmouth and the Cassowary (the Puffin is back in design), and
the tier-two four the Wild Boar, the Clydesdale, the Buzzard and the Dingo. Probes of one
composition at 20 seeds (scratch tools over the same engine: the share of spends by component,
the heat a fight) are named as probes. Every cell is a direction at 30 seeds or fewer and is
called one; the bot is a floor that reads this round's forecast, never a player.

### Tier one, the default four: each part alone and the model

The counts at the rating (a patrol by the Badger alone, a formation by the Badger, the Clydesdale
and the Kite, an elite by the four), today's compositions:

| Read | Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost | Rounds | Stalled fights |
|---|---|---|---|---|---|---|---|---|---|
| Today | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 24% | 4.7 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 10% | 3.6 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 2% | 2.3 | 0 |
| Today, the injury rule on | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 24% | 4.7 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 10% | 3.7 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 2% | 2.3 | 0 |
| The regen alone (regen=half) | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 20% | 4.6 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 9% | 3.6 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 1% | 2.3 | 0 |
| The die alone (die,heat1) | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 23% | 4.8 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 3% | 4.3 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 2.5 | 0 |
| The die, regen 2 | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 20% | 4.8 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 3% | 4.2 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 2.5 | 0 |
| The die, regen 4 | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 19% | 4.8 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 3% | 4.2 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 2.5 | 0 |
| The model (all) | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 19% | 4.8 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 3% | 4.2 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 2.5 | 0 |
| The model, the basics free (die,regen=half) | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 19% | 4.8 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 3% | 4.2 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 2.5 | 0 |
| The model, cooling one more | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 19% | 4.8 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 3% | 4.2 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 2.5 | 0 |

By composition at its rating, the patrols and the formations (the elites move by a point or two:
every one is free for four on every read, the Old Man's rising 16% today and 3% under the model):

| Composition | Size | Tier | For | Today | The regen alone | The die alone | The model |
|---|---|---|---|---|---|---|---|
| `knights_retinue` | patrol | 1 | 1 | wall 100%, 3.7 r | wall 100%, 3.7 r | wall 100%, 4.9 r | wall 100%, 4.9 r |
| `revenant_shamblers` | patrol | 1 | 1 | free 2%, 3.4 r | free 1%, 3.4 r | free 1%, 3.4 r | free 0%, 3.4 r |
| `gel_cluster` | patrol | 1 | 1 | free 14%, 13.0 r | free 10%, 12.9 r | free 13%, 13.0 r | free 9%, 12.9 r |
| `wolf_pack` | patrol | 1 | 1 | free 2%, 3.5 r | free 0%, 3.5 r | free 1%, 3.5 r | free 0%, 3.5 r |
| `bomb_flight` | patrol | 1 | 1 | free 12%, 4.8 r | free 6%, 4.4 r | free 12%, 4.8 r | free 5%, 4.4 r |
| `salamander_trio` | patrol | 1 | 1 | free 23%, 4.0 r | free 11%, 3.7 r | free 22%, 3.7 r | free 9%, 3.7 r |
| `antlion_pair` | patrol | 1 | 1 | free 9%, 2.5 r | free 5%, 2.5 r | free 7%, 2.5 r | free 3%, 2.5 r |
| `needler_scouts` | patrol | 1 | 1 | free 26%, 3.0 r | free 26%, 3.0 r | free 26%, 3.0 r | free 26%, 3.0 r |
| `barrow_mound` | formation | 1 | 3 | free 3%, 4.3 r | free 1%, 4.3 r | free 1%, 4.4 r | free 1%, 4.2 r |
| `grave_host` | formation | 1 | 3 | free 1%, 3.0 r | free 1%, 3.0 r | free 1%, 3.0 r | free 1%, 3.0 r |
| `goblin_warband` | formation | 1 | 3 | free 0%, 2.4 r | free 0%, 2.4 r | free 0%, 2.4 r | free 0%, 2.4 r |
| `treant_grove` | formation | 1 | 3 | free 3%, 4.6 r | free 1%, 4.6 r | free 2%, 5.0 r | free 1%, 4.7 r |
| `ember_pit` | formation | 1 | 3 | free 0%, 2.4 r | free 0%, 2.4 r | free 0%, 2.4 r | free 0%, 2.4 r |
| `magma_vent` | formation | 1 | 3 | free 32%, 4.9 r | free 32%, 4.9 r | free 8%, 7.4 r | free 8%, 7.4 r |
| `needler_swarm` | formation | 1 | 3 | free 6%, 2.2 r | free 6%, 2.2 r | free 3%, 2.3 r | free 3%, 2.3 r |
| `sandworm_ambush` | formation | 1 | 3 | free 34%, 5.4 r | free 34%, 5.4 r | free 11%, 7.3 r | free 11%, 7.3 r |

The same compositions fought short-handed, which is most of a battle's fights for the bot's
defence rule (the campaign's table below): the formations and the elites by the Badger alone, and
by the Badger and the Clydesdale.

| Read | Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost | Rounds | Stalled fights |
|---|---|---|---|---|---|---|---|---|---|
| Today | 1 | formation, 1 | 8 | 1 | 1 | 6 | 91% | 7.8 | 0 |
|  | 1 | elite, 1 | 11 | 6 | 3 | 2 | 41% | 7.0 | 0 |
| The regen alone | 1 | formation, 1 | 8 | 2 | 3 | 3 | 72% | 9.3 | 0 |
|  | 1 | elite, 1 | 11 | 9 | 1 | 1 | 25% | 6.6 | 0 |
| The die alone | 1 | formation, 1 | 8 | 1 | 1 | 6 | 90% | 8.5 | 0 |
|  | 1 | elite, 1 | 11 | 7 | 3 | 1 | 41% | 7.2 | 0 |
| The die, regen 2 | 1 | formation, 1 | 8 | 1 | 4 | 3 | 83% | 9.9 | 0 |
|  | 1 | elite, 1 | 11 | 8 | 2 | 1 | 29% | 6.9 | 0 |
| The model (the Badger regains 4) | 1 | formation, 1 | 8 | 2 | 3 | 3 | 69% | 10.2 | 0 |
|  | 1 | elite, 1 | 11 | 9 | 1 | 1 | 22% | 6.8 | 0 |
| Today | 1 | formation, 2 | 8 | 6 | 2 | 0 | 28% | 6.3 | 0 |
|  | 1 | elite, 2 | 11 | 10 | 1 | 0 | 12% | 4.7 | 0 |
| The regen alone | 1 | formation, 2 | 8 | 6 | 2 | 0 | 21% | 6.0 | 0 |
|  | 1 | elite, 2 | 11 | 10 | 1 | 0 | 10% | 4.6 | 0 |
| The die alone | 1 | formation, 2 | 8 | 5 | 3 | 0 | 21% | 7.1 | 0 |
|  | 1 | elite, 2 | 11 | 10 | 1 | 0 | 7% | 5.1 | 0 |
| The die, regen 2 | 1 | formation, 2 | 8 | 6 | 2 | 0 | 16% | 6.7 | 0 |
|  | 1 | elite, 2 | 11 | 10 | 1 | 0 | 6% | 4.9 | 0 |
| The model | 1 | formation, 2 | 8 | 6 | 2 | 0 | 15% | 6.6 | 0 |
|  | 1 | elite, 2 | 11 | 10 | 1 | 0 | 5% | 4.8 | 0 |

By composition, the Badger alone:

| Composition | Size | Tier | For | Today | The regen alone | The die, regen 2 | The model |
|---|---|---|---|---|---|---|---|
| `barrow_mound` | formation | 1 | 1 | wall 100%, 12.6 r | decision 36%, 17.3 r | decision 82%, 16.8 r | decision 31%, 16.7 r |
| `grave_host` | formation | 1 | 1 | wall 91%, 11.4 r | decision 78%, 13.8 r | decision 81%, 15.9 r | decision 75%, 18.4 r |
| `goblin_warband` | formation | 1 | 1 | free 51%, 8.0 r | free 34%, 7.7 r | free 33%, 8.1 r | free 28%, 7.9 r |
| `treant_grove` | formation | 1 | 1 | wall 100%, 11.1 r | free 45%, 15.7 r | decision 85%, 15.1 r | free 37%, 15.7 r |
| `ember_pit` | formation | 1 | 1 | wall 99%, 5.3 r | wall 99%, 5.6 r | wall 99%, 6.1 r | wall 99%, 6.0 r |
| `magma_vent` | formation | 1 | 1 | wall 100%, 4.5 r | wall 100%, 4.9 r | wall 100%, 7.0 r | wall 100%, 7.2 r |
| `needler_swarm` | formation | 1 | 1 | decision 86%, 6.3 r | decision 84%, 6.3 r | decision 84%, 6.3 r | decision 83%, 6.3 r |
| `sandworm_ambush` | formation | 1 | 1 | wall 100%, 3.2 r | wall 100%, 3.2 r | wall 100%, 3.7 r | wall 100%, 3.7 r |
| `fell_riders_hunt` | elite | 1 | 1 | free 11%, 3.6 r | free 1%, 3.5 r | free 4%, 3.6 r | free 1%, 3.5 r |
| `the_reaper` | elite | 1 | 1 | free 0%, 2.6 r | free 0%, 2.6 r | free 0%, 2.6 r | free 0%, 2.6 r |
| `the_wild_hunt` | elite | 1 | 1 | decision 55%, 8.5 r | free 30%, 7.8 r | free 39%, 8.2 r | free 27%, 7.8 r |
| `shamans_warband` | elite | 1 | 1 | free 13%, 6.8 r | free 5%, 6.5 r | free 6%, 6.7 r | free 4%, 6.4 r |
| `the_nob` | elite | 1 | 1 | decision 28%, 5.3 r | free 6%, 4.8 r | free 15%, 4.9 r | free 5%, 4.8 r |
| `cinder_tortoises_brood` | elite | 1 | 1 | decision 63%, 14.1 r | free 18%, 13.2 r | decision 39%, 13.9 r | free 16%, 13.5 r |
| `thunder_apes_rampage` | elite | 1 | 1 | free 30%, 6.6 r | free 15%, 5.5 r | free 15%, 6.0 r | free 11%, 5.6 r |
| `gilgamesh_wanders` | elite | 1 | 1 | free 36%, 12.5 r | free 1%, 11.0 r | free 12%, 11.2 r | free 1%, 11.0 r |
| `old_mans_rising` | elite | 1 | 1 | wall 100%, 3.0 r | wall 100%, 3.0 r | wall 100%, 3.5 r | wall 100%, 3.5 r |
| `pilgrims_wake` | elite | 1 | 1 | wall 97%, 9.2 r | decision 94%, 9.5 r | decision 77%, 10.9 r | decision 75%, 11.0 r |
| `rust_monsters_scavenge` | elite | 1 | 1 | free 18%, 5.1 r | free 2%, 4.8 r | free 8%, 4.8 r | free 2%, 4.8 r |

Read, in bands, a direction:

- **The two parts do different jobs.** The regen alone, on today's dice, halves what a lone
  Badger loses to a plain-blow patrol (the salamander trio 23% to 11%, the bomb flight 12% to
  6%, the antlion pair 9% to 5%) and moves nothing at three, where little is lost but to the two
  formations with a massive. The die alone moves nothing for a lone machine and takes those two
  from a third of the trio's hull to a tenth (the magma vent 32% to 8%, the sandworm ambush 34%
  to 11%), each two rounds longer. Together they add: 19% at one, 3% at three.
- **Every cell that still costs hull is a breach.** The sandworm's maw and the magma elemental's
  fist (8, breach), the needlers (3, breach), the knights' cleaver (6, breach): the regen never
  meets them, so the needler scouts cost a lone Badger 26% on every read and the knights'
  retinue walls it on every read. Five of tier one's rank-and-file lines carry breach (the
  needler, the sandworm, the zombie knight, the bomb, the magma elemental), none of the Meadow's.
- **The regen's size shows short-handed.** At the rating its sizes read alike (2, 4 and half the
  gauge: 19 to 20% at one, 3% at three). A lone Badger against a formation for three is where it
  moves: six walls of eight with no regen, three walls and four decisions at 81 to 85% of its
  hull at 2, and at 4 (half its gauge) the barrow mound a decision at 31% and the treant grove
  free at 37%, each over sixteen rounds; the breach formations are walls on every read. By two
  machines the Meadow's and the Marsh's formations cost 1 to 2% under the model against 3 to 26%
  today.
- **The lone elites' blows are plain**, so a lone Badger loses 22% to them under the model against
  41% today (Gilgamesh 36% to 1%, the Nob 28% to 5%, the Cinder Tortoise's brood 63% to 16%, the
  Wild Hunt 55% to 27%); the Old Man's rising, a breach, walls it on every read. One more read
  for the elites' own item (the bible's section 12), no proposal here.
- **Heat's two levers move no cell.** The basics at heat one and a cooling of one more change
  nothing at any size: a basic's one heat is the cooling nearly every chassis has.
- **The injury rule off moves no band and no hull** (24%, 10% and 2% with it on or off): what it
  cost was components, which the curve read does not count.

### How the Barrier is dealt, and the aggressor

Tier one, the default four, the model with its Barrier basic dealt each way, and the every-die
deal played by the aggressor. The audit's own deal (`vents=guns`) gives the Badger, the
Clydesdale and the Kite no Barrier, so at one, two and three machines it is the no-Barrier row;
the Baboon holds one at four.

| Read | Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost | Rounds | Stalled fights |
|---|---|---|---|---|---|---|---|---|---|
| Today | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 24% | 4.7 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 10% | 3.6 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 2% | 2.3 | 0 |
| A Barrier on every die (all) | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 19% | 4.8 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 3% | 4.2 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 2.5 | 0 |
| Every die, resting a round | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 19% | 4.7 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 5% | 3.8 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 1% | 2.4 | 0 |
| A Ward in its place | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 20% | 4.9 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 4% | 4.1 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 2.5 | 0 |
| No Barrier | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 19% | 4.6 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 10% | 3.5 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 2% | 2.2 | 0 |
| Every die, the aggressor | 1 | patrol, 1 | 8 | 7 | 0 | 1 | 19% | 4.7 | 0 |
|  | 1 | formation, 3 | 8 | 8 | 0 | 0 | 8% | 3.6 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 1% | 2.3 | 0 |

By composition at its rating, the cells that move (every other patrol and formation is under 5%
on every read):

| Composition | Size | Tier | For | Today | On every die | Every die, resting | A Ward | No Barrier | The aggressor |
|---|---|---|---|---|---|---|---|---|---|
| `knights_retinue` | patrol | 1 | 1 | wall 100%, 3.7 r | wall 100%, 4.9 r | wall 100%, 4.2 r | wall 100%, 5.5 r | wall 100%, 3.7 r | wall 100%, 3.9 r |
| `gel_cluster` | patrol | 1 | 1 | free 14%, 13.0 r | free 9%, 12.9 r | free 9%, 12.9 r | free 9%, 12.9 r | free 8%, 12.6 r | free 9%, 12.9 r |
| `bomb_flight` | patrol | 1 | 1 | free 12%, 4.8 r | free 5%, 4.4 r | free 5%, 4.4 r | free 5%, 4.4 r | free 7%, 4.4 r | free 8%, 4.5 r |
| `salamander_trio` | patrol | 1 | 1 | free 23%, 4.0 r | free 9%, 3.7 r | free 9%, 3.7 r | free 11%, 3.7 r | free 10%, 3.6 r | free 9%, 3.7 r |
| `antlion_pair` | patrol | 1 | 1 | free 9%, 2.5 r | free 3%, 2.5 r | free 3%, 2.5 r | free 4%, 2.5 r | free 4%, 2.5 r | free 3%, 2.5 r |
| `needler_scouts` | patrol | 1 | 1 | free 26%, 3.0 r | free 26%, 3.0 r | free 26%, 3.0 r | free 26%, 3.2 r | free 25%, 3.0 r | free 26%, 3.0 r |
| `magma_vent` | formation | 1 | 3 | free 32%, 4.9 r | free 8%, 7.4 r | free 16%, 5.7 r | free 10%, 6.5 r | free 36%, 5.3 r | free 25%, 4.8 r |
| `needler_swarm` | formation | 1 | 3 | free 6%, 2.2 r | free 3%, 2.3 r | free 5%, 2.2 r | free 3%, 2.4 r | free 4%, 2.0 r | free 5%, 2.2 r |
| `sandworm_ambush` | formation | 1 | 3 | free 34%, 5.4 r | free 11%, 7.3 r | free 17%, 6.1 r | free 10%, 7.2 r | free 32%, 5.6 r | free 26%, 5.1 r |

Probes of the two formations with a massive, 20 seeds, the Badger, the Clydesdale and the Kite,
with the share of the trio's spends that went on the defensive basic:

| Deal | Sandworm ambush: rounds, hull lost | Its share of spends | Magma vent: rounds, hull lost |
|---|---|---|---|
| Today | 5.2, 32% | none (vents 7%, the Canopy 2%) | 4.8, 32% |
| A Barrier on every die | 7.5, 10% | 38% | 7.4, 7% |
| Every die, resting a round | 6.2, 18% | 24% | 5.8, 15% |
| Every die, at 3 heat | 7.7, 11% | 39% | not probed |
| Every die, at 6 heat | 7.3, 21% | 31% | not probed |
| A Ward in its place, the regen half the gauge | 6.8, 10% | 33% | 6.5, 11% |
| A Ward, the regen 2 | 6.5, 13% | 32% | not probed |
| A Ward, no regen | 6.2, 18% | 30% | 5.8, 16% |
| No Barrier (the Armoured piece, guns) | 5.9, 33% | none (the Shoring Jack 2%) | 5.3, 36% |

And the lone machine against the breach patrols, 20 seeds: the needler scouts cost the Badger 25%
and the Skua 21% under every deal, and the knights' retinue walls both under every deal.

Read, in bands, a direction:

- **The deal matters in one kind of fight.** A full squad against a massive whose blow breaches
  (the sandworm's maw and the magma elemental's fist, 8 each): with no Barrier the two cost a
  third of the trio's hull as they do today, with one on every die a tenth, with a resting one or
  a Ward between. Nowhere else does a cell move by more than a few points, and over a battle the
  deals land together (the campaign's table).
- **A block trades rounds for hull, and a round costs nothing.** With a Barrier on every die it
  is found and spent on four dice in ten and the fight runs half again as long (5 rounds to
  7.4); the aggressor, the same dice never rerolled for a block, loses a quarter of the trio's
  hull where the rung loses 8 to 11% and finishes in 4.8 to 5.1 rounds. Little in these fights
  makes the seventh round worse than the third (a bomb's fuse, an eruption's heat), so the block
  is nearly free hull and taking it is the best line: the block-everything loop on one fight's
  scale. What prices a round is a threat that rises (the model's ninth point), not the Barrier's
  rule.
- **A Ward makes the regen the dial against breach.** It lands the round's breaches on the shield,
  so the hull lost follows the regen (18% with none, 13% at 2, 10% at half the gauge) where a
  Barrier's does not, in a fight a round shorter than the every-die Barrier's. Against a plain
  blow it does nothing: the Meadow's tier-one rank and file lay no rider at all, and the Marsh's
  only the knights' breach.
- **A heat price on the Barrier does not shorten the fight** (7.7 rounds at 3 heat, 7.3 at 6,
  where the hull lost doubles to 21% with the Barrier still a third of the spends). A cooldown
  does (6.2).
- **A lone machine gets nothing from any of them.** One die a round goes on the kill; against a
  breach patrol the regen is skipped too, so the lone machine has no buffer there at all.

### Tier one, the light four

The Skua alone at the rating of one, the Skua, the Prairie Dog and the Cottonmouth at three, the
four with the Cassowary at four: stock lights, no plate and no lure. Under the audit's deal the
Skua holds an Armoured piece and no Barrier, the other three a Barrier each where their Halo
stood and a gun where their vent stood.

| Read | Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost | Rounds | Stalled fights |
|---|---|---|---|---|---|---|---|---|---|
| Today | 1 | patrol, 1 | 8 | 3 | 1 | 4 | 62% | 3.2 | 0 |
|  | 1 | formation, 3 | 8 | 4 | 2 | 2 | 30% | 10.2 | 4 |
|  | 1 | elite, 4 | 11 | 10 | 1 | 0 | 8% | 4.9 | 0 |
| The model, the audit's deal | 1 | patrol, 1 | 8 | 4 | 2 | 2 | 46% | 4.2 | 0 |
|  | 1 | formation, 3 | 8 | 6 | 2 | 0 | 8% | 9.2 | 0 |
|  | 1 | elite, 4 | 11 | 11 | 0 | 0 | 0% | 4.3 | 0 |
| The model, a Barrier on every die | 1 | patrol, 1 | 8 | 4 | 2 | 2 | 46% | 4.2 | 0 |
|  | 1 | formation, 3 | 8 | 5 | 3 | 0 | 9% | 10.8 | 1 |
|  | 1 | elite, 4 | 11 | 10 | 1 | 0 | 1% | 4.8 | 0 |

| Composition | Size | Tier | For | Today | The audit's deal | A Barrier on every die |
|---|---|---|---|---|---|---|
| `knights_retinue` | patrol | 1 | 1 | wall 100%, 2.2 r | wall 100%, 2.2 r | wall 100%, 2.2 r |
| `revenant_shamblers` | patrol | 1 | 1 | free 32%, 3.2 r | free 8%, 3.5 r | free 8%, 3.5 r |
| `gel_cluster` | patrol | 1 | 1 | wall 100%, 4.4 r | decision 63%, 10.0 r | decision 63%, 10.0 r |
| `bomb_flight` | patrol | 1 | 1 | decision 48%, 3.1 r | decision 40%, 3.3 r | decision 40%, 3.3 r |
| `salamander_trio` | patrol | 1 | 1 | wall 98%, 3.4 r | wall 91%, 3.9 r | wall 91%, 3.9 r |
| `antlion_pair` | patrol | 1 | 1 | wall 99%, 5.0 r | free 48%, 5.7 r | free 48%, 5.7 r |
| `needler_scouts` | patrol | 1 | 1 | free 19%, 1.7 r | free 19%, 1.7 r | free 19%, 1.7 r |
| `barrow_mound` | formation | 1 | 3 | decision 19%, 32.3 r, 3 stalled | free 6%, 14.6 r | decision 3%, 17.0 r, 1 stalled |
| `treant_grove` | formation | 1 | 3 | decision 13%, 17.1 r, 1 stalled | free 1%, 11.4 r | free 1%, 12.4 r |
| `ember_pit` | formation | 1 | 3 | free 5%, 2.9 r | free 2%, 2.9 r | free 2%, 3.0 r |
| `magma_vent` | formation | 1 | 3 | wall 100%, 9.3 r | decision 31%, 19.1 r | decision 35%, 24.2 r |
| `sandworm_ambush` | formation | 1 | 3 | wall 100%, 11.5 r | decision 22%, 16.7 r | decision 28%, 20.6 r |
| `cinder_tortoises_brood` | elite | 1 | 4 | free 2%, 10.6 r | free 0%, 8.3 r | free 0%, 9.5 r |
| `thunder_apes_rampage` | elite | 1 | 4 | free 3%, 3.3 r | free 0%, 3.5 r | free 0%, 4.4 r |
| `gilgamesh_wanders` | elite | 1 | 4 | free 0%, 7.6 r | free 0%, 6.5 r | free 0%, 7.4 r |
| `old_mans_rising` | elite | 1 | 4 | decision 74%, 12.2 r | free 4%, 10.9 r | decision 5%, 11.6 r |
| `pilgrims_wake` | elite | 1 | 4 | free 12%, 4.8 r | free 0%, 4.8 r | free 1%, 5.4 r |

Read, a direction. The model is worth most to the team with no plate and no lure. The Skua alone
loses 46% of its hull to a patrol against 62% (two walls against four: the knights' retinue and
the salamander trio stay walls, the gel cluster is a decision at 63% over ten rounds, the antlion
pair free at 48%); the needler scouts cost it 19% on every read, breach again. At three the two
formations with a massive are decisions where they were walls, and at four the Old Man's rising
costs 4 or 5% against 74%. The audit's deal reads as well as a Barrier on every die and ends
sooner (the magma vent 31% over 19 rounds against 35% over 24, the sandworm ambush 22% over 17
against 28% over 21, no fight past sixty rounds against one): a gun where a vent stood is worth
more to these three than a second block. What the model buys the lights is time: the fights it
turns from lost to won still run seventeen rounds and more.

### Heat with no vent: a probe

A probe, 20 seeds a cell (a scratch tool over the same engine): three stock trios against seven
tier-one formations, today, under the model and under the model cooling one more; the greedy
rung, which prices an overheat's hull and nothing under the cap (the reckless persona). The
model with the basics free was probed beside them: 13 of its 21 cells match the model's to the
digit and the rest sit inside the noise, so its rows are left out.

| Team | Composition | Read | Won | Rounds | Hull lost | Peak heat | Rounds a machine ended hot | Overheats a fight | Hull they burned | Hot dice held a fight |
|---|---|---|---|---|---|---|---|---|---|---|
| The Honey Badger, the Clydesdale, the Kite | `goblin_warband` | today | 100% | 2.4 | 0% | 76% | 0.4 | 0.05 | 0.1 | 0.00 |
|  |  | the model | 100% | 2.4 | 0% | 80% | 0.5 | 0.05 | 0.1 | 0.00 |
|  |  | the model, cooling one more | 100% | 2.4 | 0% | 74% | 0.3 | 0.05 | 0.1 | 0.05 |
|  | `treant_grove` | today | 100% | 4.8 | 4% | 104% | 1.9 | 0.55 | 1.2 | 0.00 |
|  |  | the model | 100% | 4.8 | 1% | 110% | 2.5 | 0.50 | 1.3 | 0.00 |
|  |  | the model, cooling one more | 100% | 4.7 | 1% | 94% | 1.3 | 0.45 | 0.9 | 0.00 |
|  | `needler_swarm` | today | 100% | 2.1 | 6% | 70% | 0.3 | 0.00 | 0.0 | 0.00 |
|  |  | the model | 100% | 2.3 | 4% | 64% | 0.4 | 0.00 | 0.0 | 0.00 |
|  |  | the model, cooling one more | 100% | 2.3 | 4% | 62% | 0.4 | 0.00 | 0.0 | 0.00 |
|  | `sandworm_ambush` | today | 100% | 5.2 | 32% | 100% | 1.4 | 0.45 | 0.8 | 0.00 |
|  |  | the model | 100% | 7.5 | 10% | 73% | 0.8 | 0.10 | 0.1 | 0.00 |
|  |  | the model, cooling one more | 100% | 7.6 | 10% | 68% | 0.5 | 0.00 | 0.0 | 0.00 |
|  | `grave_host` | today | 100% | 3.0 | 1% | 79% | 0.7 | 0.15 | 0.6 | 0.20 |
|  |  | the model | 100% | 3.0 | 1% | 85% | 1.0 | 0.30 | 0.6 | 0.25 |
|  |  | the model, cooling one more | 100% | 3.0 | 0% | 82% | 0.7 | 0.15 | 0.3 | 0.20 |
|  | `ember_pit` | today | 100% | 2.4 | 0% | 77% | 0.5 | 0.10 | 0.1 | 0.05 |
|  |  | the model | 100% | 2.4 | 1% | 85% | 0.8 | 0.25 | 0.3 | 0.05 |
|  |  | the model, cooling one more | 100% | 2.4 | 1% | 78% | 0.6 | 0.20 | 0.2 | 0.05 |
|  | `magma_vent` | today | 100% | 4.8 | 32% | 102% | 1.8 | 0.45 | 0.8 | 0.00 |
|  |  | the model | 100% | 7.4 | 7% | 79% | 1.1 | 0.10 | 0.1 | 0.00 |
|  |  | the model, cooling one more | 100% | 7.3 | 7% | 72% | 0.7 | 0.00 | 0.0 | 0.00 |
| The Stingray, the Storm Petrel, the Baboon | `goblin_warband` | today | 100% | 3.5 | 0% | 60% | 0.2 | 0.00 | 0.0 | 0.00 |
|  |  | the model | 100% | 3.3 | 0% | 56% | 0.1 | 0.00 | 0.0 | 0.00 |
|  |  | the model, cooling one more | 100% | 3.3 | 0% | 49% | 0.1 | 0.00 | 0.0 | 0.00 |
|  | `treant_grove` | today | 100% | 8.9 | 8% | 102% | 3.0 | 0.40 | 0.7 | 0.55 |
|  |  | the model | 100% | 8.0 | 2% | 101% | 2.5 | 0.60 | 1.4 | 0.10 |
|  |  | the model, cooling one more | 100% | 8.0 | 0% | 78% | 0.8 | 0.15 | 0.2 | 0.00 |
|  | `needler_swarm` | today | 100% | 2.9 | 5% | 44% | 0.1 | 0.00 | 0.0 | 0.00 |
|  |  | the model | 100% | 3.0 | 5% | 40% | 0.1 | 0.00 | 0.0 | 0.00 |
|  |  | the model, cooling one more | 100% | 3.0 | 5% | 38% | 0.1 | 0.00 | 0.0 | 0.00 |
|  | `sandworm_ambush` | today | 100% | 6.9 | 45% | 105% | 2.5 | 0.60 | 2.0 | 0.20 |
|  |  | the model | 100% | 8.1 | 25% | 94% | 1.8 | 0.35 | 0.5 | 0.05 |
|  |  | the model, cooling one more | 100% | 8.3 | 25% | 72% | 0.5 | 0.05 | 0.1 | 0.00 |
|  | `grave_host` | today | 100% | 4.6 | 1% | 76% | 1.1 | 0.05 | 0.1 | 0.00 |
|  |  | the model | 100% | 4.0 | 0% | 60% | 0.3 | 0.00 | 0.0 | 0.00 |
|  |  | the model, cooling one more | 100% | 4.0 | 0% | 48% | 0.1 | 0.00 | 0.0 | 0.00 |
|  | `ember_pit` | today | 100% | 5.0 | 14% | 104% | 2.4 | 1.10 | 2.8 | 0.60 |
|  |  | the model | 100% | 4.7 | 5% | 105% | 2.0 | 1.15 | 2.5 | 0.70 |
|  |  | the model, cooling one more | 100% | 4.8 | 4% | 94% | 1.6 | 0.60 | 1.2 | 0.40 |
|  | `magma_vent` | today | 95% | 7.8 | 58% | 112% | 3.5 | 0.65 | 1.9 | 0.40 |
|  |  | the model | 100% | 8.7 | 25% | 105% | 3.1 | 0.60 | 1.8 | 0.20 |
|  |  | the model, cooling one more | 100% | 8.7 | 23% | 88% | 1.8 | 0.20 | 0.3 | 0.10 |
| The Skua, the Prairie Dog, the Cottonmouth | `goblin_warband` | today | 100% | 2.7 | 0% | 34% | 0.0 | 0.00 | 0.0 | 0.00 |
|  |  | the model | 100% | 3.0 | 0% | 35% | 0.0 | 0.00 | 0.0 | 0.00 |
|  |  | the model, cooling one more | 100% | 3.0 | 0% | 25% | 0.0 | 0.00 | 0.0 | 0.00 |
|  | `treant_grove` | today | 95% | 17.7 | 14% | 62% | 0.4 | 0.05 | 0.1 | 0.00 |
|  |  | the model | 100% | 12.7 | 1% | 93% | 2.8 | 0.25 | 0.2 | 0.00 |
|  |  | the model, cooling one more | 100% | 12.6 | 0% | 25% | 0.0 | 0.00 | 0.0 | 0.00 |
|  | `needler_swarm` | today | 100% | 2.1 | 2% | 30% | 0.0 | 0.00 | 0.0 | 0.00 |
|  |  | the model | 100% | 2.1 | 1% | 29% | 0.0 | 0.00 | 0.0 | 0.00 |
|  |  | the model, cooling one more | 100% | 2.1 | 1% | 25% | 0.0 | 0.00 | 0.0 | 0.00 |
|  | `sandworm_ambush` | today | 0% | 11.4 | 100% | 49% | 0.0 | 0.00 | 0.0 | 0.00 |
|  |  | the model | 95% | 21.4 | 27% | 39% | 0.0 | 0.00 | 0.0 | 0.00 |
|  |  | the model, cooling one more | 95% | 21.4 | 27% | 25% | 0.0 | 0.00 | 0.0 | 0.00 |
|  | `grave_host` | today | 100% | 3.6 | 1% | 38% | 0.0 | 0.00 | 0.0 | 0.00 |
|  |  | the model | 100% | 3.9 | 0% | 43% | 0.0 | 0.00 | 0.0 | 0.00 |
|  |  | the model, cooling one more | 100% | 3.9 | 0% | 25% | 0.0 | 0.00 | 0.0 | 0.00 |
|  | `ember_pit` | today | 100% | 3.0 | 5% | 73% | 0.4 | 0.10 | 0.1 | 0.05 |
|  |  | the model | 100% | 2.9 | 2% | 80% | 0.7 | 0.30 | 0.9 | 0.00 |
|  |  | the model, cooling one more | 100% | 2.9 | 1% | 70% | 0.3 | 0.20 | 0.2 | 0.00 |
|  | `magma_vent` | today | 0% | 9.2 | 100% | 68% | 0.6 | 0.00 | 0.0 | 0.00 |
|  |  | the model | 95% | 24.9 | 41% | 85% | 2.0 | 0.00 | 0.0 | 0.50 |
|  |  | the model, cooling one more | 95% | 25.0 | 40% | 59% | 0.2 | 0.00 | 0.0 | 0.00 |

Read, a direction. Taking the vents off the die costs the bot nothing: on today's dice the default
trio spent 7% of its dice on vents and 2% on shields against the sandworm ambush (the spends
probe), and the model's peaks, overheats and hull burned sit where today's do (the default trio's overheats 0.05 to 0.55 a fight burning about a point of hull, the
hot trio's 0.35 to 1.15 burning one to three of its 76). And heat is not a pace in the bot's
hands on either die: a hot die is held less than once a fight on every row, and the hottest
tier-one trio loses one to three hull a fight to it. The basics at heat one are under the cooling
of one nearly every chassis has, so they are no price; cooling one more takes the peaks down ten
to twenty points and most of the hull burned with them. The prices are where the hold would come
from, which is the heat session's list (the brief's third point), and a rung that reads only an
overheat cannot say whether a player would feel it: the cautious persona (`--cool-above`) is the
read for that, not taken here.

### Tier two, by its own team

The tier-two four (the Wild Boar alone at the rating of one; the Wild Boar, the Clydesdale and
the Buzzard at three) against tier two's patrols and formations, today and under the model.
Tier three was read today only (a patrol 57% at one, a formation 34% at three with two walls of
seventeen, this team a tier short) and not under the model.

| Read | Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost | Rounds | Stalled fights |
|---|---|---|---|---|---|---|---|---|---|
| Today | 2 | patrol, 1 | 8 | 4 | 1 | 3 | 57% | 5.7 | 0 |
|  | 2 | formation, 3 | 13 | 12 | 1 | 0 | 14% | 4.9 | 0 |
| The model | 2 | patrol, 1 | 8 | 5 | 0 | 3 | 48% | 6.0 | 0 |
|  | 2 | formation, 3 | 13 | 13 | 0 | 0 | 8% | 5.5 | 0 |

| Composition | Size | Tier | For | Today | The model |
|---|---|---|---|---|---|
| `knight_and_wights` | patrol | 2 | 1 | wall 100%, 6.8 r | wall 100%, 9.0 r |
| `wight_shamblers` | patrol | 2 | 1 | decision 57%, 5.8 r | free 40%, 6.3 r |
| `gel_drift` | patrol | 2 | 1 | free 62%, 13.8 r | free 21%, 11.7 r |
| `warg_pack` | patrol | 2 | 1 | free 7%, 3.9 r | free 1%, 3.9 r |
| `fire_lizards` | patrol | 2 | 1 | wall 100%, 4.7 r | wall 98%, 6.6 r |
| `grenade_flight` | patrol | 2 | 1 | free 12%, 5.7 r | free 5%, 5.2 r |
| `needler_scouts` | patrol | 2 | 1 | free 16%, 2.2 r | free 16%, 2.2 r |
| `pit_pair` | patrol | 2 | 1 | wall 100%, 3.0 r | wall 100%, 2.9 r |
| `death_knights_retinue` | formation | 2 | 3 | free 29%, 5.5 r | free 19%, 8.2 r |
| `grave_field` | formation | 2 | 3 | decision 20%, 12.7 r | free 4%, 10.8 r |
| `rotblooms_bed` | formation | 2 | 3 | free 4%, 5.0 r | free 1%, 4.9 r |
| `treant_march` | formation | 2 | 3 | free 7%, 6.1 r | free 1%, 6.5 r |
| `grenade_volley` | formation | 2 | 3 | free 8%, 3.0 r | free 6%, 3.1 r |
| `magma_forge` | formation | 2 | 3 | free 40%, 6.6 r | free 20%, 9.8 r |
| `wyvern_roost` | formation | 2 | 3 | free 10%, 3.1 r | free 8%, 3.3 r |
| `barbed_swarm` | formation | 2 | 3 | free 5%, 2.9 r | free 5%, 2.8 r |
| `pit_ambush` | formation | 2 | 3 | free 16%, 3.0 r | free 10%, 3.6 r |
| `sandworm_pit` | formation | 2 | 3 | free 42%, 7.0 r | free 24%, 9.1 r |

Read, a direction: tier one's shape again. At three the formations with a breaching massive
cost about half (the magma forge 40% to 20%, the sandworm pit 42% to 24%, the death knight's
retinue 29% to 19%) at two or three rounds more, the plain-blow ones nearly nothing (the grave field
20% to 4%, the treant march 7% to 1%), and no formation is a wall or a decision for three. Alone,
the Wild Boar keeps its three walls (the knight and wights, the fire lizards, the pit pair) and
loses a third as much to the gel drift (62% to 21%).

### The proposal's tier-one formations under the model

The formation proposal's fifteen tier-one formations, written to a scratch worktree
(`tools/formation_proposal.py`) and read at three machines: the default trio (the Badger, the
Clydesdale, the Kite) on today's dice, with a Barrier on every die, and with none, which is the
audit's deal for this trio; and the light trio (the Skua, the Prairie Dog, the Cottonmouth) on
today's dice and with a Barrier on every die. The proposal's formations at every tier were read
on today's dice with the injury rule off beside them (tier one 9% at three, all fifteen free;
tier two 18%, eleven free and six decisions of seventeen; tier three 35%, eight free, nine
decisions and two walls of nineteen, the default four a tier and two short); their reads under
the model at tiers two and three were stopped past the hour, unfinished.

| Read | Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost | Rounds | Stalled fights |
|---|---|---|---|---|---|---|---|---|---|
| The default trio, today's dice | 1 | formation, 3 | 15 | 15 | 0 | 0 | 9% | 3.6 | 0 |
| The default trio, a Barrier on every die | 1 | formation, 3 | 15 | 15 | 0 | 0 | 4% | 4.0 | 0 |
| The default trio, no Barrier (the audit's deal) | 1 | formation, 3 | 15 | 15 | 0 | 0 | 9% | 3.5 | 0 |
| The light trio, today's dice | 1 | formation, 3 | 15 | 9 | 4 | 2 | 25% | 7.9 | 3 |
| The light trio, a Barrier on every die | 1 | formation, 3 | 15 | 11 | 4 | 0 | 12% | 8.7 | 0 |

| Composition | Size | Tier | For | Default, today | Default, every die | Default, no Barrier | Light, today | Light, every die |
|---|---|---|---|---|---|---|---|---|
| `barrow_mound` | formation | 1 | 3 | free 6%, 4.5 r | free 2%, 4.6 r | free 3%, 4.3 r | decision 21%, 34.4 r, 2 stalled | decision 6%, 20.8 r |
| `grave_host` | formation | 1 | 3 | free 1%, 3.0 r | free 1%, 3.0 r | free 1%, 2.6 r | free 1%, 3.7 r | free 0%, 3.9 r |
| `grave_throng` | formation | 1 | 3 | free 1%, 3.4 r | free 2%, 3.6 r | free 2%, 3.1 r | free 3%, 4.4 r | free 0%, 4.1 r |
| `knights_vigil` | formation | 1 | 3 | free 15%, 3.1 r | free 9%, 3.9 r | free 15%, 3.2 r | decision 86%, 9.4 r | decision 64%, 14.6 r |
| `gel_wall` | formation | 1 | 3 | free 4%, 5.1 r | free 1%, 5.1 r | free 2%, 4.8 r | free 7%, 5.5 r | free 0%, 5.1 r |
| `goblin_horde` | formation | 1 | 3 | free 1%, 3.3 r | free 1%, 3.4 r | free 2%, 3.1 r | free 2%, 3.9 r | free 0%, 4.2 r |
| `goblin_warband` | formation | 1 | 3 | free 0%, 2.4 r | free 0%, 2.4 r | free 0%, 2.2 r | free 0%, 2.8 r | free 0%, 3.1 r |
| `treant_grove` | formation | 1 | 3 | free 7%, 5.4 r | free 3%, 5.2 r | free 5%, 5.3 r | decision 18%, 18.0 r, 1 stalled | free 2%, 12.7 r |
| `ember_pit` | formation | 1 | 3 | free 0%, 2.4 r | free 0%, 2.4 r | free 1%, 2.3 r | free 5%, 2.9 r | free 2%, 3.0 r |
| `ember_pyre` | formation | 1 | 3 | free 6%, 3.2 r | free 5%, 3.3 r | free 6%, 3.2 r | decision 26%, 4.7 r | free 22%, 4.8 r |
| `magma_vent` | formation | 1 | 3 | free 39%, 5.6 r | free 7%, 7.9 r | free 39%, 5.6 r | wall 100%, 9.1 r | decision 42%, 25.0 r |
| `antlion_pit` | formation | 1 | 3 | free 3%, 2.2 r | free 3%, 2.2 r | free 3%, 2.0 r | free 3%, 2.9 r | free 2%, 3.0 r |
| `needler_swarm` | formation | 1 | 3 | free 6%, 2.2 r | free 3%, 2.3 r | free 4%, 2.0 r | free 2%, 2.1 r | free 1%, 2.1 r |
| `needler_thicket` | formation | 1 | 3 | free 8%, 3.1 r | free 5%, 3.0 r | free 8%, 2.9 r | free 2%, 3.0 r | free 1%, 3.2 r |
| `sandworm_ambush` | formation | 1 | 3 | free 35%, 5.3 r | free 12%, 7.9 r | free 39%, 5.7 r | wall 100%, 11.1 r | decision 32%, 20.6 r |

Read, a direction, against the brief's budget for a pusher (a twentieth of the squad's hull at
its rating). Twelve of the fifteen cost the default trio 8% or less on every read (the goblins,
the gels and the graves 4% or less). The three that cost more are breach: the magma vent (39%),
the sandworm ambush (35 to 39%) and the knights' vigil (15%). On the audit's deal this trio
holds no Barrier and the regen never meets a breach, so the model leaves those three where they
are today, eight times the budget for the two with a massive; with a Barrier on every die the
two cost 7 and 12% at two rounds more and the knights' vigil 9%. So the massives' own numbers
are the lever, the refit's first band, whatever the deal. For the light trio the model
takes the two walls to decisions over twenty rounds and more (the magma vent 42% over 25, the
sandworm ambush 32% over 21), the knights' vigil from 86% to 64%, and the three stalled fights
away.

### The proposal's hunters under the model

The formation proposal's six hunting patrols, each rated two, written to a scratch worktree
(`tools/formation_proposal.py`), the default four: by the Badger alone, the machine a hunter
catches, and by the Badger and the Clydesdale, its rating.

| Composition | Size | Tier | Fought by | The Badger alone, today's dice | The Badger alone, the model |
|---|---|---|---|---|---|
| `wolf_pack` | patrol | 1 | 1 | free 4%, 4.6 r | free 0%, 4.6 r |
| `antlion_trio` | patrol | 1 | 1 | decision 36%, 3.7 r | free 18%, 3.8 r |
| `warg_pack` | patrol | 2 | 1 | free 14%, 4.7 r | free 4%, 4.6 r |
| `pit_pair` | patrol | 2 | 1 | decision 76%, 3.8 r | decision 72%, 4.3 r |
| `alpha_pack` | patrol | 3 | 1 | free 16%, 4.0 r | free 6%, 4.0 r |
| `queens_hunt` | patrol | 3 | 1 | wall 100%, 3.4 r | wall 99%, 4.0 r |

| Composition | Size | Tier | Fought by | Two machines, today's dice | Two machines, the model |
|---|---|---|---|---|---|
| `wolf_pack` | patrol | 1 | 2 | free 0%, 2.6 r | free 0%, 2.6 r |
| `antlion_trio` | patrol | 1 | 2 | free 3%, 2.6 r | free 1%, 2.6 r |
| `warg_pack` | patrol | 2 | 2 | free 0%, 2.6 r | free 0%, 2.6 r |
| `pit_pair` | patrol | 2 | 2 | free 13%, 2.2 r | free 13%, 3.2 r |
| `alpha_pack` | patrol | 3 | 2 | free 1%, 2.4 r | free 0%, 2.4 r |
| `queens_hunt` | patrol | 3 | 2 | free 35%, 3.4 r | free 35%, 4.0 r |

Read, a direction. At their rating the hunters cost what they did (nothing to 3% for the wolves
and the antlion trio, 13% for the pit pair, 35% for the queen's hunt, on both reads). Caught
alone, the plain-blow lines lose their teeth on a tank under the regen (the wolf pack 4% to 0%,
the warg pack 14% to 4%, the alpha pack 16% to 6%, the antlion trio 36% to 18%), and the
breaching ones keep theirs (the pit pair 76% and 72%, the queen's hunt a wall on both). A
hunter's threat to the machine it catches is, under the model, its breach or its numbers; the
light caught alone was not read here.

### The campaign runner: 40 runs, today and the model under each deal

`tools/campaign_run.gd -- --runs 40` on the same seeds (each battle's map by its seed), the greedy
rung with the defence rule on the map, three of the tender at random, the injury rule off in all
eight: today's content; the regen alone on today's dice (`--refit regen=half`); the model on the
audit's deal (`all,vents=guns`: a Barrier where a Halo stood), with a Barrier on every die
(`all`), on every die and resting a round (`all,barrier=cooldown`), with a Ward in its place
(`all,barrier=ward`) and with none (`all,barrier=off`); and the every-die deal played by the
aggressor (`all --guard 0.05`). The die's six reads deal from a tender without the Polar Bear
and the Puffin (back in design), so they differ from today's by the tender too; the regen alone
keeps today's tender, and the six share theirs.

| Measure | Today | The regen alone | The audit's deal | A Barrier on every die | Every die, resting | A Ward in its place | No Barrier | Every die, the aggressor |
|---|---|---|---|---|---|---|---|---|
| Runs won | 0 of 40 | 0 of 40 | 0 of 40 | 0 of 40 | 0 of 40 | 0 of 40 | 0 of 40 | 0 of 40 |
| Turns a run | 5.92 | 6.15 | 6.15 | 6.05 | 6.05 | 6.10 | 6.20 | 6.20 |
| Battles | 191 | 193 | 201 | 194 | 193 | 198 | 201 | 195 |
| Battles won | 3% | 8% | 10% | 9% | 8% | 9% | 9% | 8% |
| Held after a wipe | 12% | 8% | 7% | 8% | 8% | 8% | 9% | 10% |
| Fell | 83% | 82% | 81% | 82% | 82% | 81% | 80% | 81% |
| Ended in a team wipe | 89% | 73% | 65% | 64% | 63% | 65% | 65% | 65% |
| Machines wrecked a battle | 1.69 | 1.52 | 1.44 | 1.44 | 1.44 | 1.44 | 1.42 | 1.44 |
| Phases a battle | 6.06 | 6.49 | 6.70 | 6.80 | 6.77 | 6.62 | 6.69 | 6.78 |
| Menace killed a battle | 45 | 70 | 91 | 91 | 88 | 86 | 89 | 90 |
| Fractures reached a battle (of about 3) | 0.99 | 1.49 | 1.81 | 1.80 | 1.75 | 1.71 | 1.75 | 1.77 |
| Battles reaching the Rupture | 16% | 35% | 42% | 42% | 42% | 40% | 43% | 43% |
| Gate damage a battle | 128 | 127 | 124 | 128 | 128 | 125 | 124 | 125 |
| Battles by three machines: won, wiped | 12%, 77% of 58 | 20%, 55% of 67 | 22%, 44% of 76 | 20%, 45% of 70 | 18%, 47% of 72 | 20%, 45% of 72 | 19%, 46% of 76 | 18%, 48% of 72 |
| Battles by one machine: fell | 93% of 76 | 93% of 65 | 93% of 63 | 91% of 58 | 91% of 58 | 91% of 62 | 90% of 66 | 90% of 60 |
| Fights | 565 | 794 | 944 | 921 | 894 | 886 | 933 | 920 |
| Fights stalled past sixty rounds | 0 | 19 | 11 | 14 | 11 | 11 | 5 | 8 |
| A fight for 1, 1 in it: won | 58% of 121 | 73% of 212 | 78% of 271 | 79% of 272 | 78% of 256 | 76% of 234 | 79% of 268 | 79% of 267 |
| A fight for 1, 2 in it: won | 97% of 43 | 95% of 63 | 92% of 95 | 93% of 93 | 94% of 94 | 93% of 102 | 94% of 103 | 93% of 98 |
| A fight for 1, 3 in it: won | 77% of 9 | 87% of 16 | 100% of 11 | 100% of 9 | 100% of 11 | 100% of 9 | 100% of 12 | 100% of 12 |
| A fight for 3, 1 in it: won | 16% of 178 | 25% of 222 | 35% of 252 | 36% of 249 | 34% of 246 | 32% of 243 | 38% of 244 | 39% of 247 |
| A fight for 3, 2 in it: won | 66% of 87 | 84% of 113 | 89% of 124 | 86% of 115 | 90% of 110 | 92% of 112 | 89% of 116 | 93% of 106 |
| A fight for 3, 3 in it: won | 95% of 40 | 100% of 45 | 100% of 49 | 100% of 47 | 97% of 47 | 100% of 48 | 100% of 47 | 100% of 48 |
| A fight for 4, 1 in it: won | 30% of 50 | 47% of 68 | 62% of 80 | 64% of 81 | 65% of 73 | 60% of 79 | 57% of 80 | 52% of 87 |
| A fight for 4, 2 in it: won | 72% of 22 | 88% of 35 | 85% of 42 | 86% of 37 | 82% of 39 | 85% of 40 | 86% of 43 | 84% of 38 |
| A fight for 4, 3 in it: won | 93% of 15 | 100% of 20 | 100% of 20 | 100% of 18 | 100% of 18 | 100% of 19 | 100% of 20 | 100% of 17 |

Read, in bands, a direction. The campaign stays a wall for this bot on every read (no run won;
the defence rule sends a lone machine at a formation 178 times today and some 245 times under the model), so the read is
how far a battle gets, not who wins it.

- **The model takes a battle about twice as far.** Menace killed a battle doubles (45 to about
  90), the Rupture is reached in four battles in ten against one in six, team wipes fall from nine
  battles in ten to under two in three, and the team lives to fight half again as many fights (565
  to about 920). A patrol fought alone is won 79% against 58%, a formation fought alone 36%
  against 16%, an elite fought alone 64% against 30%.
- **The regen is the larger half.** On today's dice it alone takes the wipes from 89% to 73% and
  the menace killed from 45 to 70. The die adds the rest (64%, about 90) whichever way the
  Barrier is dealt, the tender's difference inside that step.
- **How the Barrier is dealt is not visible over a battle.** The audit's deal, a Barrier on every
  die, a resting one, a Ward and no Barrier at all land together on every line (wipes 63 to 65%,
  menace 86 to 91, battles won 8 to 10%), and so does the aggressor, who never rerolls for a
  block. Most of a battle's fights are one or two machines against a pack, where a block is
  seldom worth the one die; the deal is felt only where a full squad meets a massive (the probes
  above).
- **The fight nobody can finish is back.** No fight passed the bot's sixty rounds today; 19 of
  794 did with the regen alone, 14 of 921 with a Barrier on every die, 11 on the audit's deal,
  with the Barrier resting and with a Ward, 5 with no Barrier and 8 for the aggressor. The runner
  names no pack for them (unread); the curve read's own stalls are the light trio against the
  barrow mound. The model's ninth point (every formation carries a rising threat, as a validator
  check) is the guard, and this is its evidence.

## 10 November: the passing and the catch at one, on the campaign runner

`tools/campaign_run.gd -- --runs 40 --shape steppe` (115 s) on `ccr-1e6e6571-7x7ayr` after the body
blocking went (every unit passes every other, nobody ends on another's hex) and the hunter's catch
became the engage range everyone shares (1, the pounce of two gone): the greedy rung, the draft's
three machines, the defence rule as the floor (the long wall brief, section 5). A direction, read
against the record of 9 November (`docs/campaign_run.md`, each battle's shape by its seed), which it
is not a cell match for, since that run drew every shape.

| Measure | 9 November, every shape | 10 November, the steppe, passing, catch at one |
|---|---|---|
| Runs won | 0 of 40 | 0 of 40 |
| Battles | 184: won 3%, held after a wipe 9%, fell 86% | 186: won 6%, held after a wipe 7%, fell 86% |
| Fights | 524 | 519 |
| Machines wrecked a battle | 1.66 | 1.63 |
| Phases a battle | 5.96 | 5.81 |
| Gate damage a battle | 135 | 134 |
| The pressure ratio, a run's mean | 1.70 | 1.48 |
| Turns above 1.0 | 40% | 34% |

Read: nothing moved that the defence rule can show. The bot never held a line, so it never lost
one: the runs, the battles, the fights, the wrecks and the gate's damage all land where they were,
and the ratio eases a little because the packs now walk straight to the wall and the bot meets
them where they end. The catch at one did not empty the hunters' fights (519 fights against 524).
What this cannot read is the thing Ryan changed it for, his own play: whether a pusher's straight
walk and a machine's slide through its allies feel right, and whether a hunter caught beside its
prey reads without a ring. Nothing here is a decision.

## 10 November, the wall strike by the threat rating

A read after the build, not behind the decision (Ryan, 10 November: the strike follows the
threat rating, a worn pack by the share of its heads still standing; the bible's wall row), kept
because every campaign number after it stands on the new strike. `tools/campaign_run.gd -- --runs
40`, the same seeds as the refit pass's runs above, the greedy rung with the defence rule, the
injury rule off: today's content and the trial's model on the audit's deal (`--refit
all,vents=guns`), each with the strike by head count (a third of ten a foe, the runs above) and
by rating (ten a pip, `Battlefield.strike_of`). All four were taken on this branch before it took
main's passing and catch at one (the section above), so the pairs differ by the strike alone.

| Measure | Today's content, by head count | Today's content, by rating | The trial's model, by head count | The trial's model, by rating |
|---|---|---|---|---|
| Battles | 191 | 179 | 201 | 195 |
| Battles won | 3% | 3% | 10% | 10% |
| Held after a wipe | 12% | 7% | 7% | 5% |
| Fell | 83% | 89% | 81% | 83% |
| Ended in a team wipe | 89% | 88% | 65% | 64% |
| Gate damage a battle | 128 | 140 | 124 | 130 |
| Phases a battle | 6.06 | 5.73 | 6.70 | 6.37 |
| Turns a run | 5.92 | 5.60 | 6.15 | 6.05 |
| Menace killed a battle | 45 | 45 | 91 | 91 |
| Battles reaching the Rupture | 16% | 17% | 42% | 40% |
| Fights | 565 | 534 | 944 | 918 |

Read, a direction. The wall takes about a tenth more a battle on today's content (128 to 140)
and a twentieth more under the model (124 to 130), a battle ends a third of a phase sooner, and
fewer battles are held after a wipe (12% to 7%, 7% to 5%), since what is left at the wall after
one now strikes by its rating: a formation thirty where six to eight heads struck twenty to
twenty-six, an elite forty where it struck for its head. The fights are the same (menace killed
and battles won do not move). A patrol of three strikes ten on both rules.

On the merged tree (main's passing and catch at one beside the strike by rating, the branch
having taken main at `e67645f`), the same 40 runs on today's content read where the branch stood
before it: 139 gate damage a battle, 8% of battles held after a wipe, 88% fell, 2% won
(`docs/campaign_run.md` is that run). One scene shows the two changes together: the campaign
tests' wipe at a quiet start, a formation and two patrols left to walk on the wall, took 160 of
a city gate's 200 in the six unopposed phases by head count and takes the whole 200 by rating
with the packs walking straight to the wall, so those two tests thin the field to one patrol to
keep reading what they read (a gate wounded and standing).

## 10 November, the regen's size and hotter weapons, after Ryan's first read of the trial

Probes behind the trial's regen row and its default (`Settings.REFIT_REGENS`, two) and behind
leaving a heat dial off the phone; nothing moved in content. His read of the trial at half the
gauge, the MODEL deal: "the half recovery I have a nigh unkillable team, even just stingray +
prairie dog against 4 goblins/2 mandragora. The same two handily beat the goblin shaman pack
without ever using a defensive tool"; and "Heat generation is too low, but I think we knew that."
Scratch probes over the engine, 20 seeds a cell, the greedy rung, the injury rule off, the
audit's deal (`all,vents=guns`) with the regen named: each a direction.

The two fights he played, by the same two machines (the Stingray regains 6 at half its gauge and
the Prairie Dog 5):

| Read | Goblin warband (a formation for three): rounds, hull lost | Shaman's warband (an elite): rounds, hull lost |
|---|---|---|
| Today's dice, no regen | 6.4, 31% (19 of 20 won) | 7.2, 9% |
| The model's dice, no regen | 6.3, 33% | 6.0, 8% |
| Regen 1 | 5.7, 21% | 5.7, 4% |
| Regen 2 | 5.5, 13% | 5.5, 1% |
| Regen 3 | 5.5, 9% | 5.5, 1% |
| Half the gauge | 5.2, 5% | 5.5, 1% |

Read. The bot agrees with him: at half the gauge two lights lose a twentieth of their hull to a
formation rated for three, the brief's budget for a full squad at its rating, and nothing to the
elite. The dice alone mitigate nothing in this fight (33% against today's 31%; the goblins' blows
are small and many, and the bot spends no Barrier on them), so what he felt as the MODEL being
enough was the regen. The first point of flat regen is worth twelve points of the pair's hull
here, the second eight, the third four; two leaves the formation a fight (13%) and is the row's
default, a placeholder. The elite costs two lights under a tenth of their hull on every read, its own
item's business.

Every weapon hotter (`hotter=N`, after the basics' one), at regen 2:

| Team | Composition | Hotter | Won | Rounds | Hull lost | Peak heat | Overheats a fight | Hot dice held a fight |
|---|---|---|---|---|---|---|---|---|
| The Stingray, the Prairie Dog | `goblin_warband` | 0 | 100% | 5.5 | 13% | 73% | 0.10 | 0.00 |
|  |  | 1 | 100% | 5.6 | 14% | 97% | 0.40 | 0.00 |
|  |  | 2 | 100% | 6.2 | 18% | 113% | 0.80 | 0.55 |
|  |  | 3 | 100% | 7.0 | 23% | 124% | 1.60 | 1.25 |
|  | `treant_grove` | 0 | 100% | 27.2 | 37% | 118% | 1.20 | 0.70 |
|  |  | 1 | 20% | 55.1 | 40% | 108% | 1.30 | 14.20 |
|  |  | 2 | 5% | 57.8 | 41% | 115% | 1.75 | 25.20 |
|  |  | 3 | 0% | 60.0 | 46% | 124% | 2.45 | 32.85 |
| The Stingray, the Prairie Dog, the Skua | `goblin_warband` | 0 | 100% | 3.0 | 0% | 54% | 0.00 | 0.00 |
|  |  | 1 | 100% | 3.0 | 0% | 72% | 0.00 | 0.00 |
|  |  | 2 | 100% | 3.0 | 0% | 86% | 0.05 | 0.00 |
|  |  | 3 | 100% | 3.0 | 0% | 93% | 0.05 | 0.00 |
|  | `treant_grove` | 0 | 100% | 13.8 | 2% | 111% | 0.60 | 0.15 |
|  |  | 1 | 100% | 28.2 | 2% | 122% | 0.60 | 11.00 |
|  |  | 2 | 10% | 58.5 | 4% | 106% | 0.65 | 51.25 |
|  |  | 3 | 0% | 60.0 | 3% | 108% | 0.65 | 66.30 |

Read. Hotter weapons with the cooling left at one make the hold appear in a short fight (two
hotter: a die held in one goblin fight in two, the gauge past its cap) and end the long one: a
machine that cools one a round sustains one shot of N heat every N rounds once its gauge is
full, so against the treant three lights go from fourteen rounds to twenty-eight at one hotter
and past the bot's sixty at two, losing almost no hull. Generation alone is therefore no dial: the
sustained rate is the cooling over a shot's heat and the burst is the gauge over it, and a price
pass moves the three together (the heat session's list). No heat row went on the phone for it.
The bot holds rather than overheat, where a player may fire hot and pass a round, so the stall
is the rung's and the arithmetic is not.

## 10 November, evening: the shapes reworked on Ryan's play in context

The same run (`--seeds 200 --width 20 --height 12`, every shape on seeds 1 to 200) after his notes
on the shapes in context (the bible's shapes row): the river winding through the centre with
narrows and tributaries, the fjord flooded, the gorge with more lanes and junctions, the badlands
in groups, the steppe with scrub and grass; the city as it was.

| Shape | Open | Rough | Ruins | Water | Walls | Crossing | Opened | Route | Phases T/W/Wh/H/F | Reach T/W/Wh/H/F | Steps | Lone |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| RIVER CROSSING | 65% | 10% | 0% | 26% | 0% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.2/3.2/3.2/3.0/3.0 | 33/51/75/82/82% | 0% | 0.0 |
| FJORD | 37% | 17% | 0% | 46% | 0% | 200 of 200 at 3+ | 0.0 | 11.1 | 3.0/3.0/3.0/3.0/3.0 | 32/51/71/82/82% | 0% | 0.0 |
| BADLANDS | 23% | 48% | 0% | 4% | 24% | 200 of 200 at 3+ | 0.0 | 11.1 | 3.0/3.0/3.0/3.0/3.0 | 28/45/61/62/82% | 14% | 0.3 |
| OPEN STEPPE | 85% | 12% | 0% | 1% | 1% | 200 of 200 at 3+ | 0.0 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 35/59/81/81/82% | 3% | 0.0 |
| RUINED CITY | 27% | 0% | 27% | 1% | 45% | 200 of 200 at 3+ | 0.5 | 11.0 | 3.0/3.0/3.0/3.0/3.0 | 23/35/46/46/82% | 0% | 0.0 |
| GORGE | 55% | 9% | 0% | 1% | 35% | 200 of 200 at 3+ | 0.5 | 11.5 | 3.0/3.0/3.0/3.0/3.0 | 27/40/54/54/82% | 0% | 0.0 |

Read: the fjord is 46% of the field in water, which is about seven tenths of the eight rows it
lays in (the team's two rows and the rift's bared ring hold none), at or past Ryan's "50-60% of
it"; its ground reach after two phases (32% tracked, 71% wheeled) is the river's, the wade
costing both alike, and the hover's and the flyer's untouched. The river at 26% water is the
first shape whose ground phases to the rift read above three (3.2), the wade across it where no
narrow lies. The gorge opened to 35% walls from 45% with its fourth trunk and its junctions, and
its ground reach rose (27% tracked, 54% hover, from 24% and 45%); the badlands doubled its mesas
(24% from 10%) and its reach fell to the gorge's (28% tracked), its scrub half the field; the
steppe carries 12% scrub and a crag or two where it had nothing. Every map keeps the crossing
at three or more, the gorge and the city opening half a hex a map. Nothing here is a decision:
the look is Ryan's to judge on the phone (the to-do), the counts placeholders.

Every shape at seed 7 (`--show 7`; `~` water, `^` a wall, `"` rough, `#` rubble, `=` a street or
road, `R` the rift, `G` the gate, `|` the wall, the scenery outside the brackets):

```
seed 7, RIVER CROSSING, river, narrowest crossing 5, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , , ,[, , , , , , , , , , , , , " " , , " , "]" " " , 
, , , ,[. . . . = . . . . R R R . " ~ ~ ~ ~ ~ ~]~ ~ ~ ~ 
 , " " ,[. . . . = . . . . . " " ~ . ~ ~ . . ~ ~]~ ~ ~ ~ 
" " ~ "[. . . . . = " " " . " ~ ~ ~ ~ ~ " . . ~]~ , " ~ 
 ~ ~ ~ ~[~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ = . . . ~], , , , 
~ ~ ~ ~[~ ~ ~ ~ . . " ~ ~ ~ ~ ~ " " ~ = . . . "], , , , 
 ~ , , ~[. ~ . . . . ~ . ~ ~ ~ . . ~ . . . . . .], , , , 
, " , ,[" . " . . . . = = = . . . " " . . . . .], , , , 
 , , , ,[. . . . . . . . . = . . . = . . . . . .], , , , 
, , , ,[. . . . . . . . . . = . . = . . . . . .], , , , 
 , , , ,[. . . . . . . . . . = = = . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, FJORD, fjord, narrowest crossing 5, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , " , "[" , , " " , , , , , , , , , , , , , , "]" " " , 
~ ~ ~ ~[~ ~ ~ ~ ~ . . . . R R R . " " " . . . ~]~ ~ ~ ~ 
 ~ ~ ~ ~[~ ~ ~ ~ ~ " . . . . " " . ~ ~ ~ ~ . . ~]~ ~ ~ ~ 
~ ~ ~ ~[. ~ ~ ~ ~ . . . . . " ~ ~ ~ ~ ~ ~ " . ~]~ ~ ~ ~ 
 ~ ~ ~ ~[. ~ ~ ~ " . . . . ~ . ~ ~ ~ ~ ~ . " . ~]~ ~ ~ ~ 
~ ~ ~ ~[~ ~ ~ ~ ~ . " ~ ~ ~ ~ ~ ~ " . . " ~ ~ ~]~ ~ ~ ~ 
 ~ ~ ~ ~[~ ~ ~ ~ . . . . ~ ~ ~ ~ ~ ~ ~ . . ~ ~ .]~ ~ ~ ~ 
~ ~ ~ ~[" ~ ~ ~ " " . . . ~ ~ ~ ~ ~ " " " ~ ~ "]~ ~ ~ ~ 
 ~ ~ ~ ~[~ ~ ~ ~ ~ " . . . ~ ~ ~ ~ ~ . ~ ~ ~ ~ ~]~ ~ ~ ~ 
" " " ,[" . . " " . . . . " . " " . " . " . . "], " , " 
 , , , ,[. . . . . . . . . . . . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, BADLANDS, ponds, narrowest crossing 5, the guarantee opened 0
 " " " "[" ^ ^ " ^ " " " " " " " " " " " " ^ " "]^ ^ " " 
^ ^ " ^[^ " " " ^ ^ " " " " " " " " " " " ^ ^ "]^ " " " 
 ^ " " "[" " " " " " " " " " " " " " " " " " " "]" " " " 
" " " "[" " " ^ ^ ^ " . . R R R . ^ " . " ^ " .]" " " " 
 " " " "[^ ^ " " " " . ~ . . . . " " . " ^ " " "]" " " " 
" " " "[^ " " ^ ^ " " ~ " " " ^ " " " " " " ^ ^]" " " " 
 " " " "[" . " " " ^ " " ^ ^ " ^ " ^ ^ ^ " " " "]" " " " 
" " " "[" " . ~ . " ^ ^ " ^ ^ " " ^ " " " ^ ^ "]" " " " 
 " " " "[^ " . ~ ~ " ^ ^ " " " " " " " ^ " " " ~]" " ^ " 
" " " "[^ " " ~ . " " " " " ^ ^ ^ " ^ " ^ " ~ ~]" " " " 
 ^ " " "[" ^ " . " ^ ^ ^ " " " " " ^ ^ " " . . .]" ^ " " 
" " " "[. " " . . " " " " . . . . " " " . . . .]" " " " 
 " " " "[. . . . . . . . . . . . . . . . . . . .]" " " " 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, OPEN STEPPE, ponds, narrowest crossing 5, the guarantee opened 0
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[. " " . . . . . . R R R . . . . . . . .], , , , 
 ^ , , ,[. . . . . . . " . . = . ~ ~ ~ . . . ~ .], , , , 
^ , , ,[" . . . . . . . " . = . " " " " . . ~ .], , , , 
 , , , ,[" " . . . . . . . . = . " " " . . . . "], , , , 
, , , ,[. . " . . . . . . . . = . . . . . . . .], , , , 
 , , , ,[. . " " . . . . . . . . . . . . . . ^ .], , , , 
, , , ,[. . . . . . . . . " " = . . " . . . . .], , , , 
 , , , ,[. . . . . . " . . . = . . " . . . . " .], , , , 
, , , ,[. . . . . . . . . . . = . . . . . . . .], , , , 
 , , , ,[. . . . . . . . . . = . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, RUINED CITY, a fountain, narrowest crossing 3, the guarantee opened 1
 ^ ^ # ^[# # ^ # # ^ ^ # ^ ^ ^ ^ # ^ ^ ^ ^ ^ # ^]^ ^ # ^ 
^ ^ ^ #[^ # ^ # # # ^ # ^ ^ ^ # # ^ ^ ^ ^ # # #]^ ^ # ^ 
 ^ ^ ^ ^[# # # # # # ^ ^ ^ # # # ^ ^ ^ ^ ^ # # ^]# ^ # ^ 
^ # # ^[^ ^ ^ ^ ^ = ^ ^ . R R R . ^ ^ # ^ ^ ^ ^]^ # ^ ^ 
 ^ # ^ #[^ ^ ^ ^ ^ = ^ ^ . . = . ^ ^ ^ # ^ ^ ^ ^]^ # ^ # 
# # ^ #[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # . ^ ^ = = = = =]^ # # # 
 ^ ^ ^ ^[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # # # # = ^ ^ ^ ^]^ # ^ ^ 
# # # #[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # # # # = ^ ^ ^ ^]# # ^ # 
 ^ # # ^[^ ^ ^ ^ ^ = ^ ^ ^ ^ # = = = # = = = = =]^ # # ^ 
^ ^ # #[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # # # # = ^ ^ ^ ^]# # # # 
 ^ # ^ ^[^ ^ ^ ^ ^ = ^ ^ ^ ^ = # # ~ # = ^ ^ ^ ^]# # # ^ 
# # # #[# # # # # # # # # # # # # # # # # # # #]# # # # 
 # # # #[# # # # # # # # . . = . . # # # # # # #]# # # # 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
seed 7, GORGE, flooded channels, narrowest crossing 3, the guarantee opened 2
 , , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
, , , ,[, , , , , , , , , , , , , , , , , , , ,], , , , 
 , , , ,[" , , , , , , , , , , , , " , , , , , "]" " " , 
^ ^ ^ ^[^ ^ ^ " . . ~ . . R R R . ^ ^ ^ ^ ^ . .]^ ^ ^ ^ 
 ^ ^ ^ ^[^ ^ ^ . ^ . ~ ^ . . . " ^ ^ ^ ^ . . . .]^ ^ ^ ^ 
^ ^ ^ ^[^ ^ ^ . ^ ^ " " ^ ^ ^ . . ^ ^ ^ ^ . ^ .]^ ^ ^ ^ 
 ^ ^ ^ ^[^ ^ " " . " . . . ^ . . ^ ^ ^ ^ ^ . ^ .]^ ^ ^ ^ 
^ ^ ^ ^[^ ^ ^ ^ . ^ ^ . " . . . ^ ^ ^ ^ ^ ^ ^ .]^ ^ ^ ^ 
 ^ ^ ^ ^[^ . . . ~ . ^ ^ ^ ^ . . ^ ^ . . . . . .]^ ^ ^ ^ 
^ ^ ^ ^[^ ^ ^ . . . . . . " ~ . . " . . ^ . ^ .]^ ^ ^ ^ 
 ^ ^ ^ ^[^ ^ . . . . . . . . . . . . . . . . " ^]^ ^ ^ ^ 
, , " ,[. . . . . . . . . . . . . . . . . . . .], " , , 
 , , , ,[. . . . . . . . . . . . . . . . . . . .], , , , 
, , , ,[| | | | | | | | | G G G G | | | | | | |], , , , 
 , , , ,[| | | | | | | | | G G G | | | | | | | |], , , ,
```

## 10 November, after Ryan's second read of the trial: the field's depth and the opening, the Rupture meter's shares, the goblin's knife

Probes behind the field's and the fodder's dials (a debug build's SETTINGS → TRIALS; `Ramp.depth_trial`,
`Battle.opening_trial`, `Battle.fodder_trial`) and behind the goblin's role put to him in chat.
The only content that moved with them is every machine's move, one more, on his word, which
no probe here reads; the goblin's own kit followed on his call (its part, below). His play (the MODEL deal at a regen of two): "I think the map is a bit too shallow
... If the map is a little deeper, and the seam starts a little farther out, it will feel more
like I can actually plan a little bit ahead instead of panicking from the very start, which is
the case now - feels like the correct play is to throw all machines down the middle and grind
out Fracture as fast as possible that way. If fracture rewards were a little lower for fodder,
then it becomes a bit more of a quantity game for non-elites and I'll feel more like sending my
flankers out"; and of the goblins, "Kill one goblin, suddenly the whole formation falls apart
... A straight attack, and a block of some kind, so they're a true frontliner".

**Every machine one more move.** The campaign runner's 40 runs on the tree with it
(`docs/campaign_run.md`) read as the 40 before it: battles won 3% against 2%, fallen 88% both,
team wipes 90% against 88%, the gate's damage a battle 140 against 139, the Rupture reached in
19% both. The plain player does nothing with the hex, so what the move is worth is his play's
to say.

**The field's depth and the opening's distance.** The Meadow at tier one, 20 seeds, the wall
twenty long, nobody fighting (the machines taken off the field, so the clock alone), six enemy
turns. The opening stands a formation one of its own moves from the apron and a patrol two; the
trial adds moves to both.

| Depth | Opening | The seam's first row, and its rows from the wall | The first strike, enemy turn | The gate has taken by turn 2 | By turn 4 | By turn 6 | A formation's walk from the rift to the wall, turns |
|---|---|---|---|---|---|---|---|
| 12 | +0 | row 4, 5 | 1.1 | 67 | 165 | 200 | 4 |
| 12 | +1 | row 4, 5 | 2.1 | 26 | 118 | 198 | 4 |
| 12 | +2 | row 4, 5 | 2.5 | 5 | 72 | 168 | 4 |
| 14 | +0 | row 4, 7 | 1.0 | 70 | 168 | 200 | 5 |
| 14 | +1 | row 4, 7 | 2.2 | 23 | 110 | 192 | 5 |
| 14 | +2 | row 4, 7 | 3.0 | 0 | 71 | 166 | 5 |
| 16 | +0 | row 5, 8 | 1.2 | 64 | 160 | 200 | 6 |
| 16 | +1 | row 5, 8 | 2.2 | 24 | 111 | 194 | 6 |
| 16 | +2 | row 5, 8 | 3.1 | 0 | 65 | 158 | 6 |

Read. Depth alone buys no planning turn: the opening is measured from the wall, so at any depth
the first formation strikes on the first enemy turn and the gate has taken a third of its bar
by the second. What buys the turns is the opening's distance, a turn for each move, and depth is
the room for it: at twelve deep two more moves run out of field (the first strike at 2.5 where
fourteen and sixteen give 3.0 and 3.1). Depth by itself moves the two things he named beside it:
the seam's first tears open seven and eight rows from the wall where they open five today, by
the seam's own rule, and everything the rift sends later walks a turn or two longer, which is
the time to regroup for an elite. So the pair to try first is fourteen deep with the opening a
move farther out (the first strike on the second enemy turn, 23 off the gate by then where it
is 70 today), and sixteen with two for a first strike on the third. Nobody fights in this read,
so the gate's numbers are the clock's and not a battle's. On the phone's glass with the wall at
the left, the rift's edge shows at twelve deep and is a scroll away at fourteen and sixteen.

**What a kill is worth on the Rupture meter.** Every domain, 20 seeds, the field at the start
as the game sets it: the meter's base is the menace placed and the first waves the rift will
send, the Rupture at two thirds of it.

| Domain, tier one | The meter's base (placed, the first waves) | The first Fracture, the Rupture | The one formation, in the middle | Each of the two patrols, on the flanks | The elites the first Fracture calls |
|---|---|---|---|---|---|
| The Meadow | 116 (52, 64) | 17, 78 | 20, 26% of the Rupture | 16, 21% | 22 or 28 |
| The Waste | 140 (59, 81) | 21, 94 | 28, 30% | 16, 16% | 20 to 61 |
| The Marsh | 127 (54, 73) | 19, 85 | 24, 28% | 15, 18% | 20 to 42 |
| The Peak | 236 (107, 129) | 35, 158 | 46, 29% | 30, 19% | 36 or 48 |

Tier two reads the same by its own numbers (four Fractures; the formation 25% to 28% of the
Rupture, a patrol 16% to 19%, the first Fracture at 16 to 30 against a formation of 29 to 58).

Read. In every domain the one formation in the middle is worth more than the first Fracture,
so the first fight there earns it and calls the elite at once; the elite's kill counts double
and is most of the second; and two more packs make the Rupture, about four fights in all (three
in the Waste, whose elites are worth 59 and 61 of 94). The first waves come down the rift's
column, so the middle alone supplies every one of them: the formation and the waves are 84 of
the Meadow's 78 before the elite is counted. That is his read ("throw all machines down the
middle"). A flank patrol already pays more for the machine sent than the middle does (16 for a
fight rated for one against 20 for a fight rated for three), so what keeps the flankers home is
not the patrol's worth but that the middle is enough. Lowering the fodder's worth is the lever
he names and it works that way: at three quarters the Meadow's first Fracture takes the
formation and a patrol and the Rupture about five fights; at half, the same two for the first
and about seven fights for the Rupture, which the middle alone reaches only with its fifth
wave, so the flanks' patrols and the tears' are the faster road. Its price is the battle's length: every
fight more is turns on the clock, a wave every third turn and the seam two rows nearer each
peak. `Battle.fodder_trial` counts a kill at the share when its pack came as no elite, an
elite's pack whole, and leaves the tally salvage and Anathema read as it was.

**The goblin's knife.** The goblin as content had it: 3 hit points, a knife of 2 and one more
for every other goblin standing, so four deal 20 a round, then 12, 6 and 2 as they fall.
Variants laid over the loaded content for the run, the greedy rung, 30 seeds a cell, each a
direction: rounds and hull lost, and the share won where it is under 100%. The wall is the
Goblin Guard's Shield Wall (armour up one until its next action, one action in three).

Corrected the same day. This probe's first run kept the loaded content between its variants
(the default content is cached, and a variant's wall was added on top of the last one's), so
every walled row after the first carried two or three walls, the always-on armour's row three
walls with it, and the grove's rows none of today's knife; what it said of them was wrong, and
the lean it gave Ryan (armour always on "holds for about the same hull") with it. The rows
below are the rerun, a fresh load for every variant and the goblin's kit pinned in the probe;
the rows that were right the first time read the same.

The goblin warband (four goblins before two Mandragoras, rated for three):

| The goblin | The default three: today's dice, the MODEL at regen 2 | The Stingray and the Prairie Dog: today's dice | The MODEL at regen 2 | The Stingray, the Prairie Dog and the Skua: today's dice, the MODEL |
|---|---|---|---|---|
| The old knife: 2, one more a peer | 2.4 · 0%, 2.2 · 0% | 97% · 6.5 · 30% | 5.5 · 12% | 3.3 · 1%, 3.1 · 0% |
| A straight 3 | 2.4 · 0%, 2.2 · 0% | 6.6 · 20% | 5.3 · 8% | 3.3 · 0%, 3.0 · 0% |
| A straight 4 | 2.4 · 0%, 2.2 · 0% | 97% · 6.7 · 37% | 5.4 · 18% | 3.3 · 1%, 3.1 · 0% |
| A straight 5 | 2.4 · 0%, 2.2 · 0% | 93% · 6.9 · 55% | 5.8 · 28% | 3.3 · 2%, 3.1 · 0% |
| A straight 3 and the wall | 2.5 · 0%, 2.1 · 0% | 6.7 · 10% | 5.3 · 3% | 3.3 · 0%, 3.1 · 0% |
| **A straight 4 and the wall (built)** | 2.5 · 0%, 2.0 · 0% | 6.9 · 22% | 5.4 · 9% | 3.4 · 1%, 3.2 · 0% |
| A straight 5 and the wall | 2.5 · 0%, 2.1 · 0% | 97% · 7.1 · 40% | 5.6 · 11% | 3.5 · 1%, 3.2 · 0% |
| A straight 6 and the wall | 2.5 · 0%, 2.1 · 0% | 93% · 7.2 · 50% | 6.3 · 21% | 3.5 · 2%, 3.3 · 1% |
| A straight 4, armour 1 always | 2.4 · 0%, 2.2 · 0% | 53% · 9.0 · 78% | 83% · 8.1 · 52% | 5.6 · 7%, 4.7 · 5% |
| The old knife at 5 hit points | 2.5 · 1%, 2.4 · 0% | 70% · 8.4 · 73% | 83% · 7.7 · 52% | 4.5 · 4%, 4.0 · 1% |
| A straight 4 and the wall, 5 hit points | 2.6 · 0%, 2.4 · 0% | 80% · 11.4 · 64% | 7.8 · 24% | 4.1 · 1%, 4.2 · 1% |
| A straight 4 and the wall, 6 hit points | 2.6 · 0%, 2.5 · 1% | 67% · 11.9 · 73% | 9.1 · 33% | 5.1 · 3%, 4.8 · 1% |
| A straight 5 and the wall, 6 hit points | 2.7 · 0%, 2.5 · 1% | 20% · 8.2 · 93% | 93% · 9.0 · 46% | 5.3 · 8%, 4.8 · 2% |

The treant's grove (a Treant and three goblins before two Mandragoras, rated for three):

| The goblin | The default three: today's dice, the MODEL | The Stingray and the Prairie Dog: today's dice | The MODEL at regen 2 | The three lights: today's dice, the MODEL |
|---|---|---|---|---|
| The old knife | 4.6 · 3%, 4.4 · 4% | 27% · 17.7 · 96% | 26.6 · 36% | 16.5 · 11%, 14.2 · 2% |
| A straight 4 | 4.6 · 4%, 4.6 · 5% | 3% · 13.7 · 99% | 93% · 27.2 · 52% | 17.8 · 13%, 13.8 · 4% |
| A straight 4 and the wall (built) | 4.6 · 5%, 4.6 · 5% | 10% · 18.6 · 99% | 97% · 27.1 · 42% | 18.1 · 14%, 15.3 · 4% |
| A straight 5 and the wall | 4.6 · 5%, 4.6 · 5% | 3% · 16.6 · 100% | 90% · 27.7 · 49% | 18.1 · 16%, 15.0 · 4% |

Read. A block that is an action softens the goblin: a goblin raising its wall is a goblin not
stabbing, so at the same knife the walled goblin costs the pair about half what the plain one
does (9% against 18% at a straight 4 under the model, 22% against 37% on today's dice), and
the wall does not make the line last (5.4 rounds both). Armour that is always there is no
gentler form of it: it walls the small blows, three rounds longer and 52% of the pair's hull
under the model, half the fights lost on today's dice, which is what the formation pass's
reads said of flat armour and the lights. Hit points are what make the front hold (a straight
4 and the wall at 6 hit points: nine rounds and a third of the pair's hull under the model).
And three machines of any weight clear the warband in two to five rounds for a few points of
hull at most on every row (the default three 1% at worst, three lights 8%), a knife of 5 at 6
hit points included: with a full squad what is felt is how fast the front dies, the player's
damage against the fodder's hit points, more than the knife's shape.
The old knife was not weak where the goblins lived (at 5 hit points, half the pair's hull and
one fight in six lost): its fault is the one he names, that the first kill takes two fifths
of it.

Built on his call ("I think the earlier goblin can have shield wall as well"): a straight 4
and the wall, the 4 a placeholder. Against the old knife it costs the pair a little less in
the warband (9% against 12% under the model, 22% against 30% on today's dice) and a little
more in the grove, where the goblins live long beside the Treant (42% against 36% under the
model); a 5 costs them as much in the warband under the model and a third more on today's
dice, and out-hits the Goblin Guard as content has it (3, one more a peer). The campaign
runner's 40 runs on the tree with it (`docs/campaign_run.md`) read as the 40 before it: won 3%
both, fallen 88% both, the gate's damage a battle 139 against 140.

The knife moves the goblin's menace with it, 5 where it was 3 (the weight reads a foe's best
blow, and the old knife's was read without its peers), so a goblin's kill fills more of the
meter and pays more salvage, and the Meadow's thresholds rise with its field. On the tree as
built the Meadow's tier-one meter reads: base 138, the first Fracture at 21, the Rupture at
92, the formation 28 (30% of the Rupture, from 26%), a flank patrol 16 (17%, from 21%), the
shaman's warband 26. The meter's read above stands, the middle's share a little larger.

## 10 November, the goblin's line on its straight knife: the Guard and the Captain in front

The Meadow's formations at tiers two and three before and after the Goblin Guard took the
straight knife (5, with its Shield Wall) and the Goblin Captain stepped into the front rank (a
straight 6, the wall, his Warcry the third move), on Ryan's "Put the captain in front, yeah".
The curve read (`tools/balance.gd --packs curve --domains meadow --sizes formation`), the greedy
rung, 20 seeds, today's dice, the tier's four cut from one machine to four, a heavy first (tier
two: the Wild Boar, the Clydesdale, the Buzzard, the Dingo; tier three: the Swallowtail, the
Musk Ox, the Ammit, the Giant Petrel): greedy's hull lost and rounds at two, three and four
machines (one machine is a wall or near it on every row, before and after). Before is the tree
with the tier-one Goblin already on its knife of 4. Each a direction.

| Tier | Composition | Before: two, three, four | After: two, three, four |
|---|---|---|---|
| 2 | `guard_warband` (two Guards and two Goblins before three Mandrakes) | 3% · 3.9, 0% · 2.9, 0% · 2.2 | 4% · 4.0, 0% · 2.9, 0% · 2.4 |
| 2 | `treant_march` | 37% · 12.3, 7% · 6.2, 4% · 5.0 | 37% · 12.6, 8% · 6.2, 5% · 5.2 |
| 2 | `rotblooms_bed` | 19% · 8.6, 4% · 5.0, 2% · 3.9 | 22% · 8.6, 5% · 5.1, 2% · 4.0 |
| 3 | `captains_warband` (was four Guards before two Captains and two Alraunes; now two Captains and two Guards before two Alraunes) | 35% · 6.8, 4% · 4.2, 0% · 3.2 | 12% · 5.8, 2% · 3.5, 0% · 2.5 |
| 3 | `alpha_hunt` | 39% · 6.7, 6% · 4.6, 1% · 3.1 | 41% · 6.7, 8% · 4.7, 1% · 3.0 |
| 3 | `metal_drift` (the Captain in a Bubble Gel's cell, seven where it was eight) | 87% · 11.1, 24% · 7.0, 6% · 4.5 | 58% · 10.9, 11% · 5.5, 2% · 3.9 |
| 3 | `treant_wilds` | 89% · 33.7, 15% · 11.6, 4% · 7.0 | 92% · 30.9, 17% · 12.2, 4% · 7.4 |
| 3 | `rotblooms_bed` | 50% · 17.2, 8% · 7.4, 1% · 5.2 | 51% · 15.6, 9% · 7.5, 2% · 5.2 |

Read. The line's new kit moves no band: where the grid is the same, the cost is the same to a
point or two. The two grids that gave up a body to seat the Captain in front read easier, the
captain's warband at a third of what it cost two machines and the metal drift at two thirds:
that is the body count and a rallier now in Direct reach, the grids' doing and the formation
pass's to re-cut, not the knife's. At its rating every formation here costs its tier's three
between nothing and a sixth of their hull, the Treant's and the gels' the dear ones.

## 10 November, the refit pass's model landed in content

The campaign runner's 40 runs (`tools/campaign_run.gd -- --runs 40`, the plain player, the
greedy rung, each run three tier-one machines of its tender) on the tree before and after the
model became content: the stock dice with no shield or vent (a defensive basic where a shield
stood, a Twin Autoguns where a vent did), every chassis its own shield regen of one to three,
the four basic guns each making heat, four machines undealt. Ryan, the same day: "The re-deal
with regen and heat, despite my tests showing it easy, seems like the correct way to go ... I
would start with regen 1-3, depending on the machine, its role and maker ... start with the
minimal swaps (The "Model" setting) and we'll go up from there." `docs/campaign_run.md` is the
run after. A direction.

| Measure | Before | The model landed |
|---|---|---|
| Battles won, fallen | 3%, 88% | 10%, 81% |
| Battles ended in a team wipe | 90% | 76% |
| Battles reaching the Rupture | 18% | 37% |
| Fractures a battle | 1.07 | 1.60 |
| Menace killed a battle | 50 | 83 |
| Gate damage a battle | 139 | 125 |
| Fights a run of 40 | 552 | 849 |
| A fight for three, one machine in it: won | 13% of 170 | 31% of 225 |
| A fight for three, two in it | 69% of 72 | 85% of 99 |
| A fight for three, three in it | 100% of 49 | 98% of 65 |
| A fight for four, one in it | 32% of 52 | 55% of 80 |

Read. The landed model does what the what-if did on 9 November: the plain player goes about
two thirds farther (menace killed 83 where it was 50, the Rupture twice as often), wins three
times the battles it did and still falls in four of five. The gain is where the reads put it,
short-handed: a machine alone against a formation rated for three wins one fight in three
where it won one in eight. At its rating nothing moved, since nothing was at stake there.

## 10 November, the duelists: a lone machine against one, and against a pair

The four flanker lines built with the formation pass (the Whisker Cat, the Roc, the Dullahan and
Cerberus, each with two recolours; Ryan: "Duelists are as you see fit, might as well jam them in
here as well as part of the pass"), each read as the duel it is made for: one stock machine of
the tier against one duelist of the tier, a skirmish with no field, the greedy rung, 30 seeds,
the landed model's dice and each chassis's own regen. A probe (a scratch script over `Skirmish`
and `Policy`, content loaded fresh for every variant: `ContentDB.reset_cache()`). Each cell:
won, mean rounds, mean hull lost. The decision they inform: the lines' placeholder numbers and
the pair's rating. Each a direction.

Tier one, as built: the Whisker Cat (10 hit points; a claw of 5, or a lash of 3 that switches
off the entry the die shows), the Roc (10; talons of 4, or a climb and a breaching stoop of 6 a
round on), the Dullahan (8; a blade of 5, and a rise it readies once it is hurt, once a fight),
Cerberus (10; three bites of 2, or a maul of 5 that scorches 2).

| Machine | Whisker Cat | Roc | Dullahan | Cerberus |
|---|---|---|---|---|
| Honey Badger | 100% · 2.2 · 0% | 100% · 2.2 · 1% | 100% · 2.3 · 0% | 100% · 2.2 · 0% |
| Baboon | 100% · 3.4 · 0% | 100% · 3.4 · 6% | 100% · 3.8 · 0% | 100% · 3.3 · 4% |
| Prairie Dog | 100% · 6.0 · 4% | 100% · 6.0 · 10% | 100% · 9.1 · 7% | 100% · 6.8 · 35% |
| Stingray | 100% · 2.9 · 0% | 100% · 3.2 · 1% | 100% · 2.7 · 0% | 100% · 2.9 · 1% |
| Cassowary | 100% · 3.7 · 1% | 100% · 3.8 · 3% | 100% · 4.1 · 0% | 100% · 3.6 · 5% |
| Cottonmouth | 100% · 3.0 · 0% | 100% · 3.2 · 1% | 100% · 2.0 · 0% | 100% · 3.0 · 3% |
| Skua | 100% · 5.2 · 2% | 100% · 5.0 · 27% | 100% · 7.7 · 5% | 100% · 8.4 · 31% |
| Storm Petrel | 100% · 3.9 · 0% | 100% · 3.9 · 9% | 100% · 3.3 · 0% | 100% · 3.8 · 0% |

Tier two, the tier's own machines: the Sabre Cat (13; 6 and a lash of 3), the Night Roc (14; 5
and a stoop of 8), the Grave Dullahan (10; 6), the Basalt Cerberus (14; bites of 2, a maul of
6).

| Machine | Sabre Cat | Night Roc | Grave Dullahan | Basalt Cerberus |
|---|---|---|---|---|
| Clydesdale | 100% · 3.5 · 1% | 100% · 3.6 · 7% | 100% · 3.5 · 1% | 100% · 3.5 · 4% |
| Kite | 100% · 2.0 · 0% | 100% · 2.0 · 0% | 100% · 1.1 · 0% | 100% · 2.0 · 0% |
| Wild Boar | 100% · 4.0 · 1% | 100% · 4.0 · 11% | 100% · 5.1 · 0% | 100% · 4.0 · 2% |
| Dingo | 100% · 6.1 · 30% | 100% · 5.7 · 47% | 100% · 7.7 · 44% | 100% · 5.8 · 66% |
| Buzzard | 100% · 2.7 · 0% | 100% · 3.1 · 9% | 100% · 3.0 · 2% | 100% · 3.2 · 3% |
| Nemesis | 100% · 3.2 · 4% | 100% · 3.3 · 5% | 100% · 2.7 · 2% | 100% · 3.1 · 5% |
| Funnel-web | 100% · 4.2 · 1% | 100% · 4.3 · 13% | 100% · 4.0 · 1% | 100% · 4.3 · 4% |
| Needletail | 100% · 3.9 · 6% | 100% · 3.5 · 19% | 100% · 3.3 · 3% | 100% · 3.4 · 13% |

Tier three: the Storm Cat (16; 7 and a lash of 4), the Great Roc (18; 6 and a stoop of 9), the
Charnel Dullahan (12; 7), the Sulphur Cerberus (18; bites of 2, a maul of 7).

| Machine | Storm Cat | Great Roc | Charnel Dullahan | Sulphur Cerberus |
|---|---|---|---|---|
| Ammit | 100% · 4.8 · 11% | 100% · 5.5 · 19% | 100% · 6.6 · 12% | 100% · 5.4 · 17% |
| Musk Ox | 100% · 6.5 · 19% | 100% · 7.2 · 33% | 100% · 8.4 · 26% | 100% · 7.4 · 24% |
| Lammergeier | 100% · 4.1 · 5% | 100% · 4.5 · 23% | 100% · 4.5 · 7% | 100% · 4.5 · 15% |
| Giant Petrel | 100% · 3.9 · 4% | 100% · 3.9 · 11% | 100% · 3.2 · 4% | 100% · 4.0 · 9% |

A pair of the same duelist at tier one, the same lone machine:

| Machine | Whisker Cat | Roc | Dullahan | Cerberus |
|---|---|---|---|---|
| Honey Badger | 100% · 4.9 · 4% | 100% · 4.5 · 14% | 100% · 4.9 · 4% | 100% · 4.6 · 5% |
| Baboon | 100% · 7.7 · 52% | 100% · 7.1 · 38% | 80% · 9.3 · 65% | 60% · 6.0 · 82% |
| Prairie Dog | 0% · 6.9 · 100% | 43% · 12.4 · 92% | 0% · 8.3 · 100% | 0% · 4.6 · 100% |
| Stingray | 97% · 6.9 · 36% | 100% · 6.4 · 26% | 87% · 6.4 · 34% | 53% · 7.4 · 85% |
| Cassowary | 100% · 7.5 · 35% | 100% · 7.0 · 32% | 100% · 7.4 · 46% | 73% · 6.4 · 83% |
| Cottonmouth | 100% · 4.4 · 39% | 100% · 4.3 · 31% | 100% · 4.0 · 15% | 63% · 4.8 · 88% |
| Skua | 0% · 6.2 · 100% | 60% · 8.0 · 90% | 0% · 7.2 · 100% | 0% · 6.3 · 100% |
| Storm Petrel | 100% · 9.9 · 33% | 100% · 6.9 · 39% | 83% · 8.8 · 42% | 97% · 10.4 · 31% |

Read. One duelist is the fight for one machine the role asks for: every machine of its tier wins
every seed, in two to nine rounds, and what it pays is the line's own question, the Roc's stoop
through the shield (the Skua a quarter of its hull, the lights a tenth) and Cerberus's bites
against a thin gauge (the Prairie Dog and the Skua a third), where the Cat and the Dullahan cost
almost nothing to a machine that kills them in time. So the lone duelist is rated one, and it
sits above the hull budget's thirtieth only for the two slow lights. The Dingo is tier two's
outlier on every column (30% to 66%), its own die's doing and its session's, no duelist's. A
pair is no duel: it is a wall for the slow lights alone and costs every other machine but the
Badger a third or more, so a pair is rated two and waits for the ramp's later steps.

What the forms tried along the way say, tier one, the same probe:

- The Dullahan's rise at weight three with no limit stalled the slow lights (the Prairie Dog won
  43% with 17 fights of 30 run to the bot's sixty rounds, the Skua 37%): it readied its rise
  again after rising. The engine's `once` on the action is the fix, no new rule: it rises once a
  fight, and both lights win every seed at 7% and 5%.
- Cerberus as first written (12 hit points; three bites of 2, each scorching; a maul of 6) cost
  the Prairie Dog 56% and the Skua 77% with one loss in ten. Taking the scorch off the bites
  changed no cell, and a machine's armour does nothing while its shield stands (the shield is
  not armoured, so a Shoring Jack blunts no bite until the gauge is gone): the cost is three
  blows a round against a gauge of three or four. At 10 hit points and an attack of 5 it is 35%
  and 31%; with bites of 1 it is nothing to anyone (0% on every row), so the bites stay at 2,
  plain, the scorch on the maul alone, and the hound is the dear duel for a thin shield.

## 10 November, the formation pass landed: the set by the curve read, and the campaign runner

The patrols and formations as content has them since the pass (the re-cut set: the pruned
formations, one hunting pack a domain and tier where the rank and file hunt, a lone duelist the
patrol rated one and a pair rated two on the ramp's later steps), read by the curve read
(`tools/balance.gd --packs curve --tiers N --seeds 20`, with `--team` at tiers two and three) on
the landed model's dice: each composition against its tier's four cut to every size, a heavy
first, the cell at its rating and the cell one machine short (the band, greedy's mean hull lost
and rounds; a stall named). The decision they inform: none yet. The pass moved no standing
foe's number, and these are the cells his play and the refit's numbers start from. Each a
direction at 20 seeds. The same reads' elite cells are the before of the elites' own read, the next section.

The counts at the rating:

| Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost |
|---|---|---|---|---|---|---|
| 1 | patrol, 1 | 4 | 4 | 0 | 0 | 0% |
| 1 | patrol, 2 | 6 | 6 | 0 | 0 | 1% |
| 1 | formation, 3 | 10 | 10 | 0 | 0 | 13% |
| 2 | patrol, 1 | 4 | 4 | 0 | 0 | 3% |
| 2 | patrol, 2 | 6 | 6 | 0 | 0 | 3% |
| 2 | formation, 3 | 14 | 13 | 1 | 0 | 14% |
| 3 | patrol, 1 | 4 | 4 | 0 | 0 | 25% |
| 3 | patrol, 2 | 6 | 6 | 0 | 0 | 12% |
| 3 | formation, 3 | 16 | 11 | 4 | 1 | 30% |

Tier one, the default four (the Honey Badger, the Clydesdale, the Kite, the Baboon):

| Domain | Size | Composition | Members | Ramp | Rated | At its rating | One short |
|---|---|---|---|---|---|---|---|
| The Meadow | patrol | `lone_whisker_cat` | Whisker Cat ×1 | any | 1 | free · 0% · 2.2 r |  |
| The Meadow | patrol | `whisker_cat_pair` | Whisker Cat ×2 | C3 to 12 | 2 | free · 0% · 2.9 r | free · 5% · 4.8 r |
| The Meadow | patrol | `wolf_pack` | Dire Wolf ×4 | any | 2 | free · 0% · 2.5 r | free · 1% · 4.7 r |
| The Meadow | formation | `goblin_horde` | Goblin ×4, Mandragora ×4 | C0 to 7 | 3 | free · 2% · 3.0 r | free · 2% · 4.8 r |
| The Meadow | formation | `treant_grove` | Treant ×1, Goblin ×3, Mandragora ×3 | any | 3 | free · 7% · 4.9 r | free · 14% · 8.6 r |
| The Meadow | formation | `gel_wall` | Gel ×4, Mandragora ×3 | C0 to 7 | 3 | free · 3% · 4.9 r | free · 9% · 7.2 r |
| The Waste | patrol | `lone_roc` | Roc ×1 | any | 1 | free · 2% · 2.2 r |  |
| The Waste | patrol | `roc_pair` | Roc ×2 | C3 to 12 | 2 | free · 2% · 2.8 r | free · 14% · 4.4 r |
| The Waste | patrol | `antlion_trio` | Antlion ×3 | any | 2 | free · 2% · 2.6 r | free · 21% · 3.7 r |
| The Waste | formation | `needler_thicket` | Needler ×4, Cockatrice ×4 | C0 to 7 | 3 | free · 8% · 2.9 r | free · 13% · 4.8 r |
| The Waste | formation | `sandworm_ambush` | Sandworm ×1, Needler ×3, Cockatrice ×2 | any | 3 | free · 40% · 5.8 r | decision · 76% · 8.9 r |
| The Marsh | patrol | `lone_dullahan` | Dullahan ×1 | any | 1 | free · 0% · 2.3 r |  |
| The Marsh | patrol | `dullahan_pair` | Dullahan ×2 | C3 to 12 | 2 | free · 0% · 2.4 r | free · 4% · 4.9 r |
| The Marsh | formation | `grave_throng` | Revenant ×4, Ghost ×4 | C0 to 7 | 3 | free · 3% · 3.1 r | free · 7% · 6.0 r |
| The Marsh | formation | `barrow_mound` | Barrow Giant ×1, Revenant ×3, Ghost ×2 | C0 to 7 | 3 | free · 5% · 4.2 r | free · 10% · 8.8 r |
| The Marsh | formation | `knights_vigil` | Zombie Knight ×2, Revenant ×2, Ghost ×2 | any | 3 | free · 15% · 3.4 r | decision · 51% · 5.6 r |
| The Peak | patrol | `lone_cerberus` | Cerberus ×1 | any | 1 | free · 0% · 2.2 r |  |
| The Peak | patrol | `cerberus_pair` | Cerberus ×2 | C3 to 12 | 2 | free · 1% · 2.8 r | free · 5% · 4.6 r |
| The Peak | formation | `ember_pyre` | Salamander ×2, Bomb ×2, Drake ×4 | C0 to 7 | 3 | free · 7% · 3.4 r | decision · 42% · 5.5 r |
| The Peak | formation | `magma_vent` | Magma Elemental ×1, Salamander ×2, Bomb ×1, Drake ×1 | any | 3 | free · 40% · 5.6 r | decision · 74% · 8.5 r |

Tier two, the tier-two four (the Wild Boar, the Clydesdale, the Buzzard, the Dingo):

| Domain | Size | Composition | Members | Ramp | Rated | At its rating | One short |
|---|---|---|---|---|---|---|---|
| The Meadow | patrol | `lone_sabre_cat` | Sabre Cat ×1 | any | 1 | free · 1% · 4.0 r |  |
| The Meadow | patrol | `sabre_cat_pair` | Sabre Cat ×2 | C8 to 12 | 2 | free · 1% · 3.7 r | free · 18% · 7.2 r |
| The Meadow | patrol | `warg_pack` | Warg ×4 | any | 2 | free · 0% · 2.1 r | free · 2% · 4.0 r |
| The Meadow | formation | `guard_horde` | Goblin Guard ×4, Mandrake ×4 | C4 to 7 | 3 | free · 1% · 3.2 r | free · 5% · 4.3 r |
| The Meadow | formation | `treant_march` | Dusk Treant ×1, Goblin Guard ×3, Mandrake ×3 | C4 to 7 | 3 | free · 6% · 6.9 r | free · 18% · 11.4 r |
| The Meadow | formation | `rotblooms_bed` | Rotbloom ×1, Goblin Guard ×2, Mandrake ×1 | any | 3 | free · 0% · 4.6 r | free · 5% · 7.0 r |
| The Meadow | formation | `gel_drift` | Bubble Gel ×2, Gel ×2, Mandrake ×2 | C4 to 7 | 3 | free · 1% · 4.8 r | free · 8% · 7.8 r |
| The Meadow | formation | `grove_and_bloom` | Dusk Treant ×1, Rotbloom ×1, Goblin Guard ×2, Mandrake ×2 | any | 3 | free · 25% · 9.8 r | decision · 79% · 17.8 r |
| The Waste | patrol | `lone_night_roc` | Night Roc ×1 | any | 1 | free · 11% · 4.0 r |  |
| The Waste | patrol | `night_roc_pair` | Night Roc ×2 | C8 to 12 | 2 | free · 5% · 3.7 r | free · 48% · 7.3 r |
| The Waste | patrol | `pit_pair` | Pit Antlion ×2 | any | 2 | free · 12% · 2.1 r | decision · 77% · 4.0 r |
| The Waste | formation | `barbed_swarm` | Barbed Needler ×2, Needler ×2, Basilisk ×2, The Djinn ×1 | C4 to 7 | 3 | free · 4% · 3.0 r | free · 13% · 4.0 r |
| The Waste | formation | `sandworm_pit` | Night Sandworm ×1, Barbed Needler ×3, Basilisk ×2 | any | 3 | free · 42% · 7.1 r | wall · 98% · 10.8 r |
| The Waste | formation | `djinns_mirage` | Barbed Needler ×2, Needler ×2, The Djinn ×2, Basilisk ×1 | any | 3 | free · 4% · 2.9 r | free · 13% · 4.2 r |
| The Marsh | patrol | `lone_grave_dullahan` | Grave Dullahan ×1 | any | 1 | free · 0% · 5.0 r |  |
| The Marsh | patrol | `grave_dullahan_pair` | Grave Dullahan ×2 | C8 to 12 | 2 | free · 0% · 3.2 r | free · 26% · 10.1 r |
| The Marsh | formation | `wight_host` | Wight ×4, Spectre ×3 | C4 to 7 | 3 | free · 2% · 3.6 r | free · 12% · 6.0 r |
| The Marsh | formation | `grave_field` | Grave Giant ×1, Wight ×3, Spectre ×2 | any | 3 | free · 11% · 11.6 r | decision · 43% · 42.5 r · 9 stalled |
| The Marsh | formation | `death_knights_retinue` | Death Knight ×2, Wight ×2, Spectre ×2 | any | 3 | free · 34% · 6.3 r | wall · 99% · 10.8 r |
| The Peak | patrol | `lone_basalt_cerberus` | Basalt Cerberus ×1 | any | 1 | free · 1% · 4.0 r |  |
| The Peak | patrol | `basalt_cerberus_pair` | Basalt Cerberus ×2 | C8 to 12 | 2 | free · 1% · 3.8 r | free · 12% · 7.5 r |
| The Peak | formation | `wyvern_roost` | Fire Lizard ×2, Bomb ×1, Grenade ×1, Wyvern ×2 | C4 to 7 | 3 | free · 10% · 3.2 r | free · 36% · 4.8 r |
| The Peak | formation | `grenade_volley` | Grenade ×2, Bomb ×1, Fire Lizard ×1, Wyvern ×2 | C4 to 7 | 3 | free · 9% · 3.0 r | free · 22% · 4.5 r |
| The Peak | formation | `magma_forge` | Basalt Elemental ×1, Fire Lizard ×2, Grenade ×1, Wyvern ×1 | any | 3 | decision · 47% · 7.4 r | wall · 100% · 9.2 r |

Tier three, a tier-three four (the Musk Ox, the Ammit, the Giant Petrel, the Lammergeier; the Swallowtail is undealt):

| Domain | Size | Composition | Members | Ramp | Rated | At its rating | One short |
|---|---|---|---|---|---|---|---|
| The Meadow | patrol | `lone_storm_cat` | Storm Cat ×1 | any | 1 | free · 17% · 6.2 r |  |
| The Meadow | patrol | `storm_cat_pair` | Storm Cat ×2 | C11 to 12 | 2 | free · 6% · 5.2 r | wall · 91% · 8.8 r |
| The Meadow | patrol | `alpha_pack` | Alpha Warg ×3 | any | 2 | free · 1% · 2.7 r | free · 16% · 5.0 r |
| The Meadow | formation | `rotblooms_bed` | Rotbloom ×1, Goblin Guard ×2, Mandrake ×1 | any | 3 | free · 2% · 5.2 r | free · 11% · 8.9 r |
| The Meadow | formation | `captains_warband` | Goblin Captain ×2, Goblin Guard ×2, Alraune ×2 | any | 3 | free · 0% · 2.9 r | free · 5% · 4.1 r |
| The Meadow | formation | `metal_drift` | Metal Gel ×2, Bubble Gel ×1, Goblin Captain ×1, Mandrake ×2, Alraune ×1 | any | 3 | free · 6% · 4.6 r | free · 43% · 7.0 r |
| The Meadow | formation | `treant_wilds` | Frost Treant ×1, Goblin Guard ×3, Alraune ×2 | any | 3 | free · 11% · 9.0 r | free · 40% · 14.2 r |
| The Meadow | formation | `frost_and_bloom` | Frost Treant ×1, Rotbloom ×1, Goblin Guard ×1, Goblin Captain ×1, Alraune ×1 | any | 3 | decision · 42% · 12.1 r | wall · 98% · 15.4 r |
| The Waste | patrol | `lone_great_roc` | Great Roc ×1 | any | 1 | free · 32% · 7.1 r |  |
| The Waste | patrol | `great_roc_pair` | Great Roc ×2 | C11 to 12 | 2 | free · 14% · 5.8 r | wall · 91% · 8.9 r |
| The Waste | patrol | `queens_hunt` | Antlion Queen ×1, Pit Antlion ×2 | any | 2 | free · 38% · 4.1 r | wall · 95% · 4.0 r |
| The Waste | formation | `great_swarm` | Great Needler ×2, Barbed Needler ×2, Gorgon ×2, Basilisk ×2 | any | 3 | free · 12% · 3.5 r | free · 38% · 5.0 r |
| The Waste | formation | `mirage_court` | Gorgon ×2, Great Needler ×1, Barbed Needler ×3, The Djinn ×2 | any | 3 | free · 10% · 3.5 r | free · 41% · 4.9 r |
| The Waste | formation | `sandworm_flats` | Salt Sandworm ×1, Great Needler ×3, Gorgon ×2 | any | 3 | free · 45% · 10.8 r | wall · 100% · 11.9 r |
| The Marsh | patrol | `lone_charnel_dullahan` | Charnel Dullahan ×1 | any | 1 | free · 30% · 9.2 r |  |
| The Marsh | patrol | `charnel_dullahan_pair` | Charnel Dullahan ×2 | C11 to 12 | 2 | free · 6% · 5.9 r | wall · 97% · 9.3 r |
| The Marsh | formation | `lichs_court` | Lich ×1, Draugr ×2, Dread Knight ×2, Spectre ×2, Wraith ×1 | C11 to 12 | 3 | wall · 95% · 11.5 r | wall · 100% · 4.3 r |
| The Marsh | formation | `charnel_pit` | Charnel Giant ×1, Draugr ×3, Wraith ×2 | any | 3 | decision · 56% · 32.0 r · 6 stalled | wall · 100% · 10.6 r |
| The Marsh | formation | `wraith_choir` | Wraith ×2, Draugr ×2, Death Knight ×2, Spectre ×2 | any | 3 | decision · 62% · 9.6 r | wall · 100% · 5.1 r |
| The Marsh | formation | `draugr_host` | Draugr ×4, Lich ×1, Wraith ×2 | any | 3 | free · 17% · 5.0 r | decision · 75% · 7.8 r |
| The Peak | patrol | `lone_sulphur_cerberus` | Sulphur Cerberus ×1 | any | 1 | free · 22% · 7.0 r |  |
| The Peak | patrol | `sulphur_cerberus_pair` | Sulphur Cerberus ×2 | C11 to 12 | 2 | free · 9% · 6.5 r | decision · 86% · 10.7 r |
| The Peak | formation | `dragons_roost` | Red Dragon ×2, Magma Lizard ×1, Fire Lizard ×1, Balloon ×1, Grenade ×1, Wyvern ×2 | any | 3 | free · 39% · 5.2 r | wall · 100% · 5.2 r |
| The Peak | formation | `magma_pit` | Magma Lizard ×2, Fire Lizard ×1, Grenade ×1, Red Dragon ×2 | any | 3 | free · 9% · 4.1 r | decision · 70% · 7.2 r |
| The Peak | formation | `balloon_storm` | Balloon ×2, Grenade ×1, Magma Lizard ×1, Wyvern ×2, Red Dragon ×1 | any | 3 | free · 15% · 4.6 r | decision · 74% · 7.9 r |
| The Peak | formation | `magma_caldera` | Sulphur Elemental ×1, Magma Lizard ×2, Balloon ×1, Wyvern ×1 | any | 3 | decision · 63% · 12.4 r | wall · 100% · 9.4 r |

Read, against the hull budget he accepted (a pusher's fight a twentieth of the squad's hull at
its rating, a flanker's a thirtieth, a hunter's a tenth):

- Every patrol is free at its rating at every tier, the lone duelist the fight for one it was
  written as. At tier three the lone duelist costs the Musk Ox a sixth to a third of its hull:
  the slowest machine of the tier reads them dearest, and a pair is a wall or near one for it
  alone, which is the pair's rating saying what it should.
- Tier one's formations sit on the budget (2% to 8% for three) but where a breach stands: the
  sandworm ambush and the magma vent at two fifths, the knights' vigil at a seventh. Breach
  under the regen is parked on his word; these are the cells it is parked with.
- Tier two is the same shape a step up: the fodder formations 0% to 11%, the anchored ones a
  quarter to a half (the grove and bloom, the sandworm pit, the death knights' retinue, the
  magma forge, the one decision). The grave field stalls nine fights in twenty one machine
  short: the giants' line has no escalation, the rising threat's defect, set aside.
- Tier three spreads widest, and the Marsh is its dearest domain: the Lich's court is a wall
  for the tier's three (greedy loses, 95% of the hull gone) and the charnel pit and the wraith
  choir cost over half, the pit stalling six fights in twenty. The draugr host, four Draugr
  before the Lich and two Wraiths, costs a sixth, so the new rung is not the cause: it is the
  knights' breach and the giant, with the Lich's raising behind them. The Lich's court holds
  the ramp's last step alone (Convergences 11 and 12), and the read is stock machines with no
  module or upgrade, so it is flagged for his play, not moved.

The campaign runner's 40 runs (`tools/campaign_run.gd -- --runs 40`, the plain player, the
greedy rung, three tier-one machines of its tender) before and after the set landed, both on
the landed model. A direction (`docs/campaign_run.md` holds the run after the elites' and bosses' guess of the same day: the next section).

| Measure | The model, the old set | The pass landed |
|---|---|---|
| Battles won, fallen | 10%, 81% | 19%, 76% |
| Battles ended in a team wipe | 76% | 69% |
| Battles reaching the Rupture | 37% | 34% |
| Fractures a battle | 1.60 | 1.50 |
| Menace killed a battle | 83 | 72 |
| Gate damage a battle | 125 | 117 |
| Machines wrecked a battle | 1.54 | 1.42 |
| Fights a run of 40 | 849 | 733 |
| A fight for one, one machine in it: won | 70% of 204 | 98% of 94 |
| A fight for two, one in it | none dealt | 66% of 15 |
| A fight for three, one in it | 31% of 225 | 17% of 219 |
| A fight for three, two in it | 85% of 99 | 69% of 107 |
| A fight for three, three in it | 98% of 65 | 100% of 80 |
| A fight for four, one in it | 55% of 80 | 51% of 72 |

Read. The ratings mean more than they did: a fight for one is won alone 98 times in 100 where
it was 70 (the old patrols were cut-down pushers that read as twos), and a formation costs a
machine alone or a pair more than it did (17% and 69% won, from 31% and 85%), since the pruned
set kept the anchored formations and dropped the ones that read free at eight foes. The plain
player wins twice the battles it did and still falls in three of four: it spreads its three
machines one to a pack, which is the play the ratings now punish, and no bot here reads a
rating before it commits.

## 10 November, the elites and the bosses guessed for the model

Ryan, 10 November: "I'd like you to guesstimate some elite and boss tweaks as well, but leave
out rising threat for now." The decision these inform: the guess itself, every number a
placeholder for his play (`content/foes.json`; the tier's step in `ContentDB.BOSS_TIERS`).
Method: a probe on the battle's own builders (`Battlefield.pack_of`, `Battle.make_boss_unit`,
`ContentDB.foes_for`), every elite composition a tier deals and every boss with its escort at
the tier, against a stock four of the tier cut to four, three, two and one machines (its first
N, a heavy first), the greedy rung, 20 seeds a cell unless said, the landed model's dice. Each
cell: greedy's mean hull lost (percent of the cut's hull) and mean rounds, its wins where it
lost any, a stall named. The tier-two and tier-three elites before the guess are the curve
read's cells of the same day (the formation pass's section), and the bosses before at those
tiers are 10 seeds. Each a direction.

### Before: free for a gathered squad

On the model as it landed, at the old numbers (a boss 48 hit points and a blow of 6 to 8, an
elite 8 to 44 and 3 to 10):

| Tier, the four | An elite: four machines | Three | A boss: four | Three |
|---|---|---|---|---|
| One: the Honey Badger, the Baboon, the Stingray, the Skua | 1% · 3.0 r | 2% · 3.4 r | 1% · 4.7 r | 2% · 5.2 r |
| One: the default four (the Honey Badger, the Clydesdale, the Kite, the Baboon) | 1% · 2.2 r | 4% · 2.7 r | 1% · 3.4 r | 2% · 4.1 r |
| Two: the Wild Boar, the Clydesdale, the Buzzard, the Dingo | 4% | 7% | 6% · 5.9 r | 12% · 7.8 r |
| Three: the Musk Ox, the Ammit, the Giant Petrel, the Lammergeier | 4% | 12% | 12% · 7.4 r | 39% · 12.4 r, won 85% |

Why. A blow under a fresh gauge costs nothing, the gauge refills, and a squad brings a gauge a
machine: the tier-one four hold 42 points of shield and regain 9 a round, so a boss that lands
8 a round for four rounds never reaches a hull. And the model's dice, a gun where a vent
stood, cut the kill time: the default four finish a tier-one boss in 2.3 to 4.2 rounds where
the 48 was set at 4 to 7 on the old dice (30 October).

### The grid: what moves them

Every tier-one elite and boss at its hit points ×1 to ×3 and its blow ×1.5 to ×3, eighteen
points, four machines, 10 seeds (the tier-one four). Three things read off it:

- The blow alone does little while the fight is short. At the old hit points and three times
  the blow, ten of thirteen bosses still cost the four 4% to 20%: four fresh gauges soak the
  first three or four blows whatever their size, so what a fight costs is its rounds times
  what gets past the gauges, and it needs both.
- One rule fits nobody. At hit points ×1.5 and the blow ×2.5 the King Gel, the Mantis Ant and
  the Vampire Lord cost 3% to 5%, and the Ruby Colossus 86% with three wins in ten: a single
  plain blow is soaked, and what is not soaked is a part that breaches and regrows (the
  Colossus's tentacle, the Fallen Weapon's eye), a last act on every machine (the Gargantuan
  King's Meteor) and many strikes on one machine (Floraison, the Fiend of Fire).
- The shaman's warband reads 0% to 1% at every point of the grid: its threat is its court of
  two Goblins and two Dire Wolves, which the pass did not touch, so no number on the Shaman
  moves it.

### The guess

The rule, and where a unit leaves it:

- A boss: half again its hit points (48 to 72) and two and a half times its blow. The 72 gives
  the default four back the kill time the test asks (the table below: 3.6 to 5.9 rounds).
- An elite: two and a half times its blow; twice its hit points at 20 or under and for the two
  that fight alone at 24 (the Goblin Nob, the Thunder Ape), so its kit plays against a squad
  (the Reaper fell in 1.2 rounds); half again for the rest.
- The cap, the scale row's own clause on hull (a telegraphed finisher never takes a machine
  from full), read at tier one against the lightest machine, the Cottonmouth's 8 of shield
  and 20 of hull: a blow that breaches stays under 20, and no one action lands 28 on one
  machine. It sets the blow of every unit that strikes many times or breaches.
- The tier's step: hit points ×1.1 at tier two and ×1.25 at tier three (×1.25 and ×1.5
  before), the blow +1 and +2 as it was. On the old step and the rule's numbers the stock
  four of tier two lost half its hull to a boss and won 88% (10 seeds), the Vampire Lord's
  court a wall.
- An elite's menace is no longer doubled (`ContentDB.menace`). Doubled on these numbers an
  elite's kill would fill 34 to 95 of a tier-one Rupture meter of 80 to 129; undoubled it is
  what it was within a quarter for every elite the rule moved (the Nob 31 from 28, the Wild
  Hunt 45 from 42), and a third lower for the two it did not (the Old Man's rising 37 from
  59, the Skeleton King's court 37 from 52). The thresholds do not move: they read the
  field's rank and file.

| Boss or part | HP | Blow | HP now | Blow now | Why |
|---|---|---|---|---|---|
| Floraison | 48 | 6 | 72 | 10 | its blow by the cap: its combos strike three and five times, and Full Bloom at 10 is 25 on one machine |
| King Gel | 48 | 6 | 72 | 15 | the rule |
| The Mantis Ant | 48 | 6 | 72 | 15 | the rule (its Upheaval breaches for 19, the cap) |
| The Ruby Colossus | 40 | 8 | 40 | 14 | its hit points kept and the blow ×1.75: its tentacles breach and regrow, and at the rule it was a wall for four |
| Burrowing Tentacle | 10 | 4 | 10 | 7 | with its core (it breaches) |
| Thrashing Tentacle | 10 | 3 | 10 | 5 | with its core |
| The Fallen Weapon | 40 | 8 | 40 | 20 | its hit points kept: its eyes guard it and regrow, and the fight was seven rounds as it stood |
| Piercing Eye | 8 | 5 | 8 | 10 | twice (it breaches) |
| Prising Eye | 8 | 5 | 8 | 10 | twice |
| The Emperor Scorpion | 48 | 7 | 72 | 18 | the rule |
| The Matador | 48 | 7 | 72 | 12 | its blow by the cap: Andalucía strikes four times, 24 on one machine |
| The Phantom Train | 48 | 8 | 72 | 20 | the rule |
| The Vampire Lord | 40 | 6 | 50 | 12 | a quarter more and twice the blow: it rises once, and its knights at tiers two and three are the dearest escort |
| The Marsh Serpent | 48 | 7 | 72 | 18 | the rule (its Coil lands 27, the cap) |
| The Gargantuan King | 48 | 8 | 72 | 15 | its blow by the cap (its Charge breaches for 19); its Meteor three quarters of its blow where it was the whole, since at the whole the bot's light four would not finish it |
| The Fiend of Fire | 48 | 7 | 72 | 14 | twice the blow: Six Blades strikes six times, 24 on one machine |
| The Obsidian Tyrant | 48 | 8 | 72 | 18 | its blow by the cap: its Firestorm lands 27 on every machine |
| The Saurian Queen | 12 | 5 | 18 | 12 | with its core |

| Elite or part | HP | Blow | HP now | Blow now | Why |
|---|---|---|---|---|---|
| Bone Wyvern | 32 | 7 | 48 | 18 | the rule |
| Goblin Shaman | 8 | 3 | 16 | 8 | the rule, twice the hit points |
| Elder Treant | 40 | 8 | 50 | 16 | a quarter more and twice the blow: the four massive elites read over a third of a four's hull at the rule, tier two |
| Leshy | 8 | 3 | 16 | 8 | the rule, twice the hit points |
| Old Man of the Desert | 44 | 10 | 44 | 10 | unchanged: its maw breaches, and it was the one elite that already cost a squad hull |
| The Reaper | 12 | 6 | 24 | 12 | twice the hit points and twice the blow; Death's Knell one and a half times its blow where it was twice, 18 through the shield where the rule would have made it 30 |
| The Goblin Nob | 24 | 6 | 48 | 15 | the rule, twice the hit points: it fights alone |
| The Bane | 36 | 8 | 54 | 16 | twice the blow (its Shadow Blade breaches) |
| The Firelord | 44 | 9 | 55 | 18 | as the Elder Treant |
| The Thunder Ape | 24 | 7 | 48 | 16 | twice the hit points: it fights alone; its blow by the cap (its Rampage, gold, lands 27) |
| The Rust Monster | 20 | 5 | 40 | 12 | the rule, twice the hit points |
| The Skeleton King | 28 | 7 | 28 | 7 | unchanged: its court of knights costs a squad a fifth already |
| The Fell Rider | 16 | 6 | 32 | 15 | the rule, twice the hit points |
| The Antiquarian | 24 | 5 | 36 | 10 | twice the blow (its Reach breaches) |
| The World Eater | 40 | 8 | 50 | 16 | as the Elder Treant |
| Rider of the Wild Hunt | 10 | 4 | 20 | 10 | the rule, twice the hit points, each of the three |
| The Shuffler | 32 | 6 | 48 | 15 | the rule |
| Gilgamesh | 40 | 7 | 60 | 18 | the rule |
| Cinder Tortoise | 40 | 7 | 50 | 14 | as the Elder Treant |
| The Astromancer | 24 | 6 | 36 | 15 | the rule |
| Warding Orb | 8 | 3 | 12 | 8 | its part, with it |
| The Pilgrim | 40 | 6 | 60 | 9 | half again of each: the Chef's Knife is twice its blow through the shield, 18 by the cap |

### After

Tier one, the tier-one four (the Honey Badger, the Baboon, the Stingray, the Skua), each fight
before and after:

| Domain | Kind | Fight | Its lead, before | Before: four | Before: three | Its lead, after | After: four | Three | Two | One |
|---|---|---|---|---|---|---|---|---|---|---|
| The Meadow | elite | `shamans_warband` | 8 hp, 3 | 0% · 2.6 r | 0% · 2.8 r | 16 hp, 8; Goblin ×2, Dire Wolf ×2 | 0% · 2.9 r | 0% · 3.5 r | 2% · 5.0 r | 12% · 7.9 r |
| The Meadow | elite | `the_nob` | 24 hp, 6 | 0% · 2.0 r | 0% · 2.2 r | 48 hp, 15 | 3% · 3.6 r | 9% · 4.4 r | 41% · 6.0 r | 100% · 4.7 r · won 0% |
| The Meadow | boss | `floraison` | 48 hp, 6 | 1% · 3.9 r | 2% · 4.2 r | 72 hp, 10 | 8% · 6.4 r | 17% · 6.7 r | 63% · 12.2 r | 100% · 13.6 r · won 0% |
| The Meadow | boss | `king_gel` | 48 hp, 6 | 1% · 4.8 r | 1% · 5.2 r | 72 hp, 15; Gel ×3 | 5% · 6.9 r | 12% · 7.3 r | 68% · 10.7 r · won 75% | 100% · 5.5 r · won 0% |
| The Meadow | boss | `mantis_ant` | 48 hp, 6 | 2% · 3.8 r | 1% · 4.5 r | 72 hp, 15 | 10% · 6.0 r | 7% · 6.5 r | 55% · 9.5 r · won 90% | 100% · 5.0 r · won 0% |
| The Waste | elite | `old_mans_rising` | 44 hp, 10, armour 1 | 7% · 6.2 r | 20% · 6.7 r | 44 hp, 10, armour 1; Needler ×3 | 7% · 6.2 r | 20% · 6.7 r | 67% · 10.0 r · won 90% | 100% · 3.0 r · won 0% |
| The Waste | elite | `pilgrims_wake` | 40 hp, 6 | 0% · 3.3 r | 3% · 4.6 r | 60 hp, 9; Needler ×3 | 1% · 4.5 r | 6% · 5.7 r | 32% · 8.5 r | 100% · 7.2 r · won 0% |
| The Waste | elite | `rust_monsters_scavenge` | 20 hp, 5 | 0% · 2.0 r | 0% · 2.0 r | 40 hp, 12 | 1% · 3.3 r | 1% · 3.7 r | 7% · 5.6 r | 88% · 8.2 r · won 40% |
| The Waste | elite | `gilgamesh_wanders` | 40 hp, 7, armour 1 | 0% · 4.1 r | 0% · 4.2 r | 60 hp, 18, armour 1 | 6% · 5.9 r | 5% · 6.1 r | 35% · 10.3 r · won 95% | 100% · 9.1 r · won 0% |
| The Waste | boss | `ruby_colossus` | 40 hp, 8, armour 1 | 7% · 6.9 r | 13% · 8.4 r | 40 hp, 14, armour 1; Burrowing Tentacle ×1, Thrashing Tentacle ×1 | 17% · 7.0 r | 39% · 9.4 r · won 90% | 100% · 7.5 r · won 0% | 100% · 2.6 r · won 0% |
| The Waste | boss | `fallen_weapon` | 40 hp, 8, armour 1 | 2% · 6.9 r | 3% · 7.0 r | 40 hp, 20, armour 1; Piercing Eye ×1, Prising Eye ×1 | 20% · 6.8 r | 31% · 7.7 r | 95% · 6.5 r · won 10% | 100% · 2.1 r · won 0% |
| The Waste | boss | `emperor_scorpion` | 48 hp, 7, armour 1 | 1% · 4.8 r | 1% · 4.9 r | 72 hp, 18, armour 1 | 18% · 7.5 r | 30% · 8.1 r | 94% · 10.2 r · won 20% | 100% · 4.1 r · won 0% |
| The Marsh | elite | `fell_riders_hunt` | 16 hp, 6 | 0% · 1.7 r | 0% · 2.0 r | 32 hp, 15 | 2% · 3.0 r | 3% · 3.3 r | 20% · 4.4 r | 78% · 5.8 r · won 70% |
| The Marsh | elite | `the_reaper` | 12 hp, 6 | 0% · 1.2 r | 0% · 1.2 r | 24 hp, 12 | 0% · 2.2 r | 0% · 2.5 r | 6% · 3.5 r | 52% · 4.8 r · won 95% |
| The Marsh | elite | `the_wild_hunt` | 10 hp, 4 | 0% · 2.5 r | 0% · 3.2 r | 20 hp, 10; Rider of the Wild Hunt ×3 | 10% · 5.2 r | 28% · 6.6 r | 94% · 7.6 r · won 35% | 100% · 2.7 r · won 0% |
| The Marsh | boss | `matador` | 48 hp, 7 | 0% · 4.1 r | 2% · 4.4 r | 72 hp, 12 | 6% · 6.2 r | 11% · 6.7 r | 48% · 10.6 r · won 90% | 100% · 7.8 r · won 0% |
| The Marsh | boss | `phantom_train` | 48 hp, 8, armour 1 | 1% · 5.3 r | 1% · 6.3 r | 72 hp, 20, armour 1 | 17% · 7.8 r | 19% · 9.2 r | 95% · 12.3 r · won 25% | 100% · 4.0 r · won 0% |
| The Marsh | boss | `vampire_lord` | 40 hp, 6 | 0% · 4.2 r | 1% · 4.7 r | 50 hp, 12 | 1% · 5.3 r | 2% · 6.0 r | 43% · 13.6 r · won 85% | 100% · 7.3 r · won 0% |
| The Marsh | boss | `marsh_serpent` | 48 hp, 7 | 0% · 3.5 r | 1% · 3.7 r | 72 hp, 18 | 9% · 5.7 r | 9% · 5.8 r | 59% · 8.6 r · won 85% | 100% · 4.4 r · won 0% |
| The Peak | elite | `cinder_tortoises_brood` | 40 hp, 7, armour 1 | 1% · 5.5 r | 2% · 5.9 r | 50 hp, 14, armour 1; Salamander ×2 | 4% · 6.5 r | 6% · 8.0 r | 40% · 10.2 r | 95% · 9.9 r · won 25% |
| The Peak | elite | `thunder_apes_rampage` | 24 hp, 7 | 0% · 2.2 r | 1% · 2.5 r | 48 hp, 16 | 9% · 4.2 r | 15% · 4.8 r | 44% · 7.3 r | 100% · 5.5 r · won 0% |
| The Peak | boss | `gargantuan_king` | 48 hp, 8 | 1% · 3.9 r | 2% · 4.0 r | 72 hp, 15 | 8% · 5.6 r | 13% · 5.9 r | 47% · 8.6 r | 100% · 5.2 r · won 0% |
| The Peak | boss | `fiend_of_fire` | 48 hp, 7 | 0% · 3.5 r | 3% · 4.2 r | 72 hp, 14 | 12% · 5.8 r | 28% · 6.3 r | 69% · 10.0 r · won 80% | 100% · 7.2 r · won 0% |
| The Peak | boss | `obsidian_tyrant` | 48 hp, 8, armour 1 | 1% · 6.0 r | 1% · 6.2 r | 72 hp, 18, armour 1; The Saurian Queen ×1 | 17% · 9.0 r | 24% · 9.3 r | 77% · 13.3 r · won 65% | 100% · 4.2 r · won 0% |

Tier one, the means by team (an elite, then a boss; hull lost and rounds):

| The four | An elite: four | Three | Two | One | A boss: four | Three | Two |
|---|---|---|---|---|---|---|---|
| The Honey Badger, the Baboon, the Stingray, the Skua | 4% · 4.3 r | 8% · 5.0 r | 35% · 7.1 r, won 93% | 84%, won 30% | 11% · 6.6 r | 19% · 7.3 r | 70% · 10.3 r, won 63% |
| The default four | 3% · 3.2 r | 13% · 3.9 r | | | 7% · 4.6 r | 28% · 6.0 r | |
| A light four with no tank (the Stingray, the Cassowary, the Cottonmouth, the Skua) | 4% · 5.5 r | 11% · 6.8 r | | | 21% · 10.4 r | 40% · 12.3 r, won 84% | |

Tier two, the stock four (the Wild Boar, the Clydesdale, the Buzzard, the Dingo, no Barrier
among them), each fight before and after at the tier's numbers, a boss with its escort:

| Domain | Kind | Fight | Before: four | Before: three | Its lead and court, after | After: four | Three |
|---|---|---|---|---|---|---|---|
| The Meadow | elite | `shamans_warband` | 0% · 2.3 r | 0% · 2.6 r | 18 hp, 9; Goblin ×2, Dire Wolf ×2 | 0% · 2.6 r | 0% · 3.1 r |
| The Meadow | elite | `elder_treants_grove` | 1% · 4.3 r | 2% · 6.5 r | 55 hp, 17, armour 1; Mandragora ×2 | 21% · 5.5 r | 38% · 8.0 r |
| The Meadow | elite | `leshys_hunt` | 0% · 2.0 r | 0% · 2.3 r | 18 hp, 9; Dire Wolf ×3 | 0% · 2.4 r | 0% · 3.1 r |
| The Meadow | elite | `the_nob` | 0% · 2.1 r | 0% · 2.7 r | 53 hp, 16 | 13% · 3.4 r | 22% · 4.2 r |
| The Meadow | boss | `floraison` | 3% · 4.8 r | 8% · 6.4 r | 79 hp, 11; Warg ×2 | 21% · 6.7 r | 37% · 9.8 r |
| The Meadow | boss | `king_gel` | 0% · 5.1 r | 3% · 6.4 r | 79 hp, 16; Gel ×2, Bubble Gel ×1 | 25% · 6.5 r | 45% · 8.3 r |
| The Meadow | boss | `mantis_ant` | 7% · 4.6 r | 8% · 5.8 r | 79 hp, 16; Goblin Guard ×2 | 29% · 6.1 r | 45% · 7.6 r |
| The Waste | elite | `old_mans_rising` | 28% · 5.5 r | 45% · 7.1 r | 48 hp, 11, armour 1; Needler ×3 | 25% · 5.0 r | 41% · 6.4 r |
| The Waste | elite | `pilgrims_wake` | 6% · 4.0 r | 11% · 5.0 r | 66 hp, 10; Needler ×3 | 16% · 4.8 r | 23% · 6.2 r |
| The Waste | elite | `rust_monsters_scavenge` | 0% · 1.9 r | 0% · 2.4 r | 44 hp, 13 | 3% · 3.0 r | 4% · 4.0 r |
| The Waste | elite | `gilgamesh_wanders` | 0% · 4.1 r | 0% · 5.3 r | 66 hp, 19, armour 1 | 15% · 5.3 r | 25% · 7.4 r |
| The Waste | elite | `the_astromancer` | 1% · 4.2 r | 2% · 5.5 r | 40 hp, 16; Warding Orb ×1, Storm Orb ×1, Mending Orb ×1 | 14% · 5.3 r | 32% · 7.2 r |
| The Waste | boss | `ruby_colossus` | 20% · 8.0 r | 52% · 15.4 r · won 70% | 44 hp, 15, armour 1; Burrowing Tentacle ×1, Thrashing Tentacle ×1, Basilisk ×1, Pit Antlion ×1 | 36% · 7.7 r | 91% · 11.4 r · won 30% |
| The Waste | boss | `fallen_weapon` | 6% · 6.6 r | 18% · 9.5 r | 44 hp, 21, armour 1; Piercing Eye ×1, Prising Eye ×1, Barbed Needler ×1, Basilisk ×1 | 46% · 7.2 r · won 95% | 90% · 9.2 r · won 25% |
| The Waste | boss | `emperor_scorpion` | 2% · 5.9 r | 5% · 7.4 r | 79 hp, 19, armour 1; Pit Antlion ×1, Barbed Needler ×1 | 53% · 8.5 r | 89% · 12.2 r · won 45% |
| The Marsh | elite | `fell_riders_hunt` | 0% · 1.6 r | 0% · 2.0 r | 35 hp, 16 | 4% · 2.5 r | 6% · 3.0 r |
| The Marsh | elite | `skeleton_kings_court` | 22% · 5.3 r | 34% · 7.5 r | 31 hp, 8, armour 1; Zombie Knight ×2, Revenant ×1 | 21% · 5.0 r | 33% · 6.9 r |
| The Marsh | elite | `antiquarians_hall` | 6% · 2.9 r | 10% · 4.0 r | 40 hp, 11; Revenant ×2 | 14% · 3.6 r | 24% · 5.0 r |
| The Marsh | elite | `bone_wyverns_flight` | 2% · 4.2 r | 4% · 5.8 r | 53 hp, 19, armour 1; Revenant ×3 | 28% · 5.5 r | 42% · 7.5 r |
| The Marsh | elite | `the_reaper` | 0% · 1.4 r | 0% · 1.6 r | 26 hp, 13 | 0% · 1.9 r | 1% · 2.5 r |
| The Marsh | elite | `the_wild_hunt` | 0% · 2.5 r | 1% · 3.5 r | 22 hp, 11; Rider of the Wild Hunt ×3 | 15% · 4.0 r | 36% · 5.9 r |
| The Marsh | elite | `the_shuffler` | 0% · 2.9 r | 0% · 4.3 r | 53 hp, 16 | 3% · 3.6 r | 7% · 5.3 r |
| The Marsh | boss | `matador` | 3% · 5.3 r | 9% · 6.9 r | 79 hp, 13; Wight ×2 | 19% · 6.8 r | 37% · 9.8 r |
| The Marsh | boss | `phantom_train` | 1% · 5.9 r | 4% · 7.4 r | 79 hp, 21, armour 1; Ghost ×2 | 43% · 7.9 r | 79% · 11.6 r · won 75% |
| The Marsh | boss | `vampire_lord` | 12% · 7.3 r | 22% · 9.4 r | 55 hp, 13; Death Knight ×1, Wight ×1 | 53% · 10.8 r · won 80% | 94% · 14.0 r · won 25% |
| The Marsh | boss | `marsh_serpent` | 1% · 4.2 r | 2% · 5.3 r | 79 hp, 19; Ghost ×2 | 29% · 5.3 r | 55% · 7.6 r |
| The Peak | elite | `cinder_tortoises_brood` | 2% · 6.7 r | 3% · 9.0 r | 55 hp, 15, armour 2; Salamander ×2 | 23% · 7.8 r | 42% · 11.1 r |
| The Peak | elite | `thunder_apes_rampage` | 0% · 2.1 r | 1% · 2.9 r | 53 hp, 17 | 14% · 3.8 r | 25% · 5.6 r · won 95% |
| The Peak | elite | `the_bane` | 8% · 3.5 r | 19% · 5.0 r | 59 hp, 17, armour 1 | 25% · 4.8 r | 51% · 7.3 r |
| The Peak | elite | `firelords_rising` | 5% · 5.8 r | 14% · 8.8 r | 61 hp, 19, armour 1 | 34% · 6.7 r | 85% · 11.7 r · won 35% |
| The Peak | elite | `the_world_eater` | 4% · 4.2 r | 9% · 5.3 r | 55 hp, 17, armour 1 | 32% · 5.0 r | 58% · 6.7 r · won 85% |
| The Peak | boss | `gargantuan_king` | 10% · 7.3 r | 11% · 6.5 r | 79 hp, 16; Bomb ×1, Grenade ×1 | 39% · 8.3 r | 51% · 8.2 r |
| The Peak | boss | `fiend_of_fire` | 4% · 4.8 r | 10% · 6.7 r | 79 hp, 15; Fire Lizard ×2 | 34% · 7.0 r | 59% · 10.6 r · won 95% |
| The Peak | boss | `obsidian_tyrant` | 3% · 6.7 r | 7% · 8.7 r | 79 hp, 19, armour 1; The Saurian Queen ×1, Wyvern ×1, Fire Lizard ×1 | 36% · 8.4 r | 80% · 13.9 r · won 95% |

Tier three, the stock four (the Musk Ox, the Ammit, the Giant Petrel, the Lammergeier):

| Domain | Kind | Fight | Before: four | Before: three | Its lead and court, after | After: four | Three |
|---|---|---|---|---|---|---|---|
| The Meadow | elite | `shamans_warband` | 0% · 2.0 r | 0% · 2.8 r | 20 hp, 10; Goblin ×2, Dire Wolf ×2 | 0% · 2.6 r | 1% · 3.6 r |
| The Meadow | elite | `elder_treants_grove` | 4% · 6.2 r | 12% · 10.6 r | 63 hp, 18, armour 1; Mandragora ×2 | 16% · 6.8 r | 51% · 13.1 r · won 90% |
| The Meadow | elite | `leshys_hunt` | 0% · 1.8 r | 0% · 2.8 r | 20 hp, 10; Dire Wolf ×3 | 0% · 2.5 r | 1% · 3.9 r |
| The Meadow | elite | `the_nob` | 1% · 2.7 r | 3% · 3.9 r | 60 hp, 17 | 16% · 4.5 r | 40% · 7.2 r |
| The Meadow | boss | `floraison` | 9% · 6.1 r | 30% · 10.0 r | 90 hp, 12; Alpha Warg ×2, Goblin Guard ×1, Goblin Captain ×1 | 24% · 7.8 r | 74% · 13.6 r · won 75% |
| The Meadow | boss | `king_gel` | 2% · 5.7 r | 7% · 9.3 r | 90 hp, 17; Bubble Gel ×1, Metal Gel ×1, Gel ×1 | 22% · 7.5 r | 58% · 12.9 r · won 95% |
| The Meadow | boss | `mantis_ant` | 5% · 6.0 r | 13% · 9.0 r | 90 hp, 17; Goblin Captain ×1, Goblin Guard ×1, Alraune ×2 | 21% · 7.7 r | 47% · 12.7 r |
| The Waste | elite | `old_mans_rising` | 19% · 6.7 r | 37% · 11.7 r | 55 hp, 12, armour 1; Needler ×3 | 18% · 5.9 r | 38% · 9.8 r |
| The Waste | elite | `pilgrims_wake` | 5% · 4.6 r | 13% · 6.8 r | 75 hp, 11; Needler ×3 | 10% · 5.7 r | 22% · 8.4 r |
| The Waste | elite | `rust_monsters_scavenge` | 0% · 2.2 r | 0% · 3.3 r | 50 hp, 14 | 3% · 3.5 r | 6% · 6.0 r |
| The Waste | elite | `gilgamesh_and_enkidu` | 1% · 5.1 r | 6% · 8.7 r | 75 hp, 20, armour 1; Enkidu ×1 | 11% · 6.9 r | 25% · 11.5 r |
| The Waste | elite | `the_astromancer` | 1% · 4.5 r | 9% · 7.9 r | 45 hp, 17; Warding Orb ×1, Storm Orb ×1, Mending Orb ×1 | 15% · 6.6 r | 58% · 12.2 r · won 90% |
| The Waste | boss | `ruby_colossus` | 29% · 9.6 r | 100% · 15.2 r · won 0% | 50 hp, 16, armour 1; Burrowing Tentacle ×1, Thrashing Tentacle ×1, Gorgon ×2, Antlion Queen ×1 | 40% · 8.3 r | 100% · 7.9 r · won 0% |
| The Waste | boss | `fallen_weapon` | 13% · 7.9 r | 59% · 16.6 r · won 80% | 50 hp, 22, armour 1; Piercing Eye ×1, Prising Eye ×1, Barbed Needler ×1, Gorgon ×2 | 43% · 8.0 r · won 95% | 99% · 11.1 r · won 5% |
| The Waste | boss | `emperor_scorpion` | 7% · 7.1 r | 23% · 11.5 r | 90 hp, 20, armour 1; Gorgon ×1, Pit Antlion ×1, Great Needler ×1 | 54% · 9.8 r · won 95% | 98% · 13.8 r · won 10% |
| The Marsh | elite | `fell_riders_hunt` | 0% · 2.0 r | 0% · 2.5 r | 40 hp, 17 | 2% · 3.1 r | 8% · 4.4 r |
| The Marsh | elite | `skeleton_kings_court` | 11% · 5.7 r | 34% · 9.5 r | 35 hp, 9, armour 1; Zombie Knight ×2, Revenant ×1 | 11% · 5.2 r | 33% · 8.3 r |
| The Marsh | elite | `antiquarians_hall` | 6% · 3.2 r | 16% · 5.4 r | 45 hp, 12; Revenant ×2 | 14% · 4.1 r | 30% · 7.5 r |
| The Marsh | elite | `bone_wyverns_flight` | 1% · 5.3 r | 11% · 7.7 r | 60 hp, 20, armour 1; Revenant ×3 | 21% · 7.0 r | 46% · 11.5 r · won 95% |
| The Marsh | elite | `the_reaper` | 0% · 1.9 r | 0% · 2.2 r | 30 hp, 14 | 0% · 2.4 r | 1% · 3.4 r |
| The Marsh | elite | `the_wild_hunt` | 1% · 3.0 r | 2% · 4.3 r | 25 hp, 12; Rider of the Wild Hunt ×3 | 17% · 4.7 r | 54% · 8.0 r · won 90% |
| The Marsh | elite | `the_shuffler` | 0% · 3.6 r | 1% · 5.9 r | 60 hp, 17 | 4% · 4.5 r | 21% · 7.9 r |
| The Marsh | boss | `matador` | 12% · 7.1 r | 23% · 10.0 r | 90 hp, 14; Wight ×3, Spectre ×1 | 25% · 8.6 r | 66% · 14.7 r · won 90% |
| The Marsh | boss | `phantom_train` | 5% · 7.9 r | 25% · 14.6 r | 90 hp, 22, armour 1; Ghost ×1, Wraith ×1, Spectre ×1 | 45% · 10.9 r | 94% · 17.6 r · won 40% |
| The Marsh | boss | `vampire_lord` | 38% · 10.4 r | 93% · 18.2 r · won 30% | 63 hp, 14; Dread Knight ×1, Death Knight ×1, Wight ×1 | 61% · 14.2 r · won 85% | 100% · 10.2 r · won 0% |
| The Marsh | boss | `marsh_serpent` | 5% · 5.6 r | 17% · 9.2 r | 90 hp, 20; Wight ×2, Spectre ×1, Ghost ×1 | 28% · 7.3 r | 63% · 13.1 r · won 90% |
| The Peak | elite | `cinder_tortoises_brood` | 3% · 6.4 r | 15% · 14.8 r | 63 hp, 16, armour 3; Salamander ×2 | 16% · 6.9 r | 66% · 18.1 r · won 90% |
| The Peak | elite | `thunder_apes_rampage` | 0% · 3.1 r | 3% · 4.0 r | 60 hp, 18 | 12% · 4.4 r | 34% · 7.7 r |
| The Peak | elite | `the_bane` | 6% · 4.5 r | 20% · 7.9 r | 68 hp, 18, armour 1 | 25% · 6.9 r | 77% · 13.8 r · won 70% |
| The Peak | elite | `firelords_rising` | 8% · 6.5 r | 32% · 16.1 r | 69 hp, 20, armour 1 | 17% · 7.5 r | 71% · 17.4 r · won 75% |
| The Peak | elite | `the_world_eater` | 7% · 5.2 r | 30% · 8.5 r | 63 hp, 18, armour 1 | 26% · 6.2 r | 82% · 10.8 r · won 55% |
| The Peak | boss | `gargantuan_king` | 9% · 6.7 r | 20% · 12.4 r | 90 hp, 17; Grenade ×2, Balloon ×1 | 26% · 7.5 r | 59% · 12.3 r · won 95% |
| The Peak | boss | `fiend_of_fire` | 14% · 6.2 r | 61% · 11.2 r · won 90% | 90 hp, 16; Magma Lizard ×2, Wyvern ×1 | 53% · 8.3 r · won 95% | 99% · 10.1 r · won 5% |
| The Peak | boss | `obsidian_tyrant` | 11% · 9.4 r | 40% · 14.4 r | 90 hp, 20, armour 1; The Saurian Queen ×1, Magma Lizard ×2, Wyvern ×2 | 53% · 11.6 r | 99% · 15.9 r · won 5% |

The means at tiers two and three:

| Tier, the four | An elite: four | Three | A boss: four | Three |
|---|---|---|---|---|
| Two, the stock four | 15% · 4.4 r | 28% · 6.1 r, won 96% | 36% · 7.5 r, won 98% | 66% · 10.3 r, won 76% |
| Two, the Nemesis in the Dingo's place (one Barrier) | 9% · 4.5 r | 20% · 6.5 r | 21% · 6.8 r | 46% · 10.1 r, won 93% |
| Three, the stock four | 12% · 5.1 r | 36% · 9.3 r, won 93% | 38% · 9.0 r, won 98% | 81% · 12.8 r, won 47% |

Read.

- The shape is the one the roles ask for. An elite is a wall for the machine it catches (30%
  won alone at tier one, the lone Badger at that), a decision for two (a third of their hull)
  and a tax on the gathered squad; a boss is a fight for four that three can lose.
- The guess does not reach the hull budget he accepted with the model (an elite's fight a
  quarter of a four's hull, the boss what is left): at tier one a gathered four loses a
  twentieth to an elite and a tenth to a boss. Tiers two and three sit nearer it (an eighth
  and a third), on fours that carry one Barrier or none.
- What would close it pulls against the kill-time test (a boss three to five rounds for a
  squad of four, 21 October). Under four pooled gauges a fight that short costs little
  whatever the blow, and the blow is already at the cap. The levers left are the fight's
  length, which the test refuses, or a kit that goes round the gauges (area, many strikes, a
  rising threat, set aside on his word). The guess takes the kill time and stops; which of the
  two gives is his (the refit brief's section 7).
- The Barrier is the swing. One machine with a Halo Projector in the tier-two four takes a
  boss from 36% of its hull to 21% and an elite from 15% to 9%. Five tier-one machines carry
  one in stock, one of tier two and one of tier three, so the model's deal makes the tier-one
  stock the best defended against a big blow.
- Soft whatever their numbers: the King Gel, the Mantis Ant, the Vampire Lord alone and the
  Marsh Serpent at tier one (1% to 10% for four), the shaman's warband and Leshy's hunt at
  every tier (0%), the Rust Monster and the Shuffler (1% to 4%). Their blows are single and
  plain or their threat is a court the pass did not touch; a kit question for their sessions.
- Dear at tiers two and three for what stands beside them, not for their own numbers: the
  Vampire Lord's knights (53% of the stock four's hull at tier two, won 80%; it was 12%
  before), the Waste's three bosses with their escorts (36% to 54%), the Peak's at tier three
  (26% to 53%). Three machines lose to most tier-three bosses (won 47%), and three lost to
  the Ruby Colossus at tier three before the guess too.
- A tier-three boss fight is nine rounds for the stock four, over the kill-time test. The
  stock machines of a tier hit little harder than tier one's, and the escorts add bodies; the
  test is read on built fours when a run can build one.

The campaign runner's 40 runs (`tools/campaign_run.gd -- --runs 40`, the plain player, the
greedy rung, three tier-one machines of its tender) before and after the guess, both on the
landed formations. A direction (`docs/campaign_run.md` is the run made again after the branch took main's third map list, the rift's five hexes under it, so its numbers sit a little off the column here).

| Measure | The formation pass landed | The guess |
|---|---|---|
| Battles won, fallen | 19%, 76% | 8%, 87% |
| Battles ended in a team wipe | 69% | 83% |
| Battles reaching the Rupture | 34% | 23% |
| Fractures a battle | 1.50 | 1.26 |
| Menace killed a battle | 72 | 57 |
| Gate damage a battle | 117 | 136 |
| Machines wrecked a battle | 1.42 | 1.60 |
| A fight for four, one machine in it: won | 51% of 72 | 25% of 74 |
| A fight for four, two in it | 91% of 46 | 51% of 33 |
| A fight for four, three in it | 97% of 44 | 92% of 28 |
| A fight for three, three in it | 100% of 80 | 100% of 60 |

Read. The fights for four are the elites' and the boss's, and the plain player sends whatever
stands nearest: one machine wins such a fight one time in four where it won one in two, a pair
one in two where it won nine in ten, three still nine in ten. So it wins 8% of its battles
where it won 19%, about where it stood before the formation pass. That is the guess doing what
an elite is for (the squad comes to it, or it takes a machine) against a player that never
gathers; it is also the read most likely to feel harsh in play, where a hunting elite catches
a machine alone before the squad can come.

What follows from it, named:

- A boss's menace rises with its numbers (Floraison 48 from 27, the Vampire Lord 25 from 16),
  so its kill banks more salvage, two a point: the economy pass's.
- A final's hero and the finale's line ride the tier's step, so each is a little softer at
  tiers two and three until its own numbers are guessed. They were not: the heroes' proposal
  waits on his marks.
- The adds in their kits were sized against the old blows and are small beside the new: the
  Thunder Ape's gold (+2 on a blow of 16), a rally's +2, the Goblin Nob's rage (a point a
  spend, and the model left few spends to punish), the riders' lance (+1 a rider). So are a
  machine's Armoured 2 and its regen against a blow of 15 to 20, which is the other half of
  why the Barrier is the swing.
- The cap is read at tier one. At tiers two and three the blow's +1 and +2 carry a few
  finishers past it (the Mantis Ant's Upheaval breaches for 20 at tier two).

## 11 November, tier one with three machines: the Badger's regen, the starting trios, the first boss

Ryan, 11 November: "Badger probably goes to Regen 1 with the amount of armour it's able to
get"; "Let's focus only on balancing tier 1 fights for now"; and "the first battle should be
tuned around 3 units, and possibly second convergence battles should be tuned around 3.5
units ... 3rd convergence battles onward we should tune it around 4 units ... it significantly
affects boss scaling, since the whole team is brought in." The decisions these inform: the
Honey Badger's regen (set to one), and the squad a battle is tuned for by the Convergence, his
to settle (the refit brief's section 10). Method: a probe on the battle's own builders
(`Battlefield.pack_of`, `Battle.make_boss_unit`, `ContentDB.foes_for`), every tier-one
formation and elite the first Convergence deals and every boss, against a squad of stock
tier-one machines, the greedy rung, 10 seeds a cell unless said, the elites' and bosses'
numbers of 10 November. Each cell: greedy's mean hull lost and rounds, its wins where it lost
any. Each a direction.

### The Honey Badger at a regen of three and of one

The trio at 20 seeds, the pair and the Badger alone at 10 on a sample (four patrols, five
formations, five elites). Hull lost, and the Badger's own beside it:

| The squad | Fights | Regen 3 | Regen 1 |
|---|---|---|---|
| The Badger, the Skua, the Baboon | the ten formations | 14% (its own 11%) | 14% (its own 13%) |
| | the eleven elites | 16% (its own 12%) | 17% (its own 14%) |
| | the thirteen bosses | 45% (its own 37%), won 89% | 50% (its own 46%), won 86% |
| The Badger and the Skua | five formations | 25% (its own 19%), won 92% | 28% (its own 24%), won 90% |
| | five elites | 56% (its own 50%), won 78% | 61% (its own 57%), won 66% |
| The Badger alone | four patrols | 6% (its own 6%) | 9% (its own 9%) |
| | five formations | 74% (its own 74%), won 68% | 78% (its own 78%), won 52% |
| | five elites | 87% (its own 87%), won 32% | 89% (its own 89%), won 24% |

Read. In a full trio nothing moves against a formation or an elite, and a boss costs five
points more over its ten rounds. Short-handed it is a few points dearer, and two coin flips
for the pair become losses (the Goblin Nob and the Thunder Ape, won one in two at three and one
in five at one). Alone it no longer wins a formation rated for three: the Treant's grove was
won four times in five at a regen of three and never at one, which is the lone tank beating a
formation rated for three that the regen's first reads flagged (9 November). A machine's
armour does nothing while its shield stands, so the faster regen was keeping the Badger's
plate idle against small blows.

### The starting trios, and what a fourth machine adds

A run starts with three machines, one from each of three city makers (the tender deals one
from each of the four, the player takes three), and the fourth is an offer's or bought. Eight
trios at three, four with the Badger (at a regen of one) and four without, and three squads of
four, a formation, an elite and a boss each the mean of its kind:

| The squad | A formation | An elite | A boss | Machines wrecked a boss |
|---|---|---|---|---|
| Three: the Honey Badger, the Baboon, the Skua | 14% · 5.9 r | 20% · 6.2 r | 46% · 10.5 r, won 88% | 0.61 |
| Three: the Honey Badger, the Stingray, the Cassowary | 9% · 5.8 r | 8% · 5.4 r | 24% · 8.6 r, won 99% | 0.11 |
| Three: the Honey Badger, the Storm Petrel, the Cottonmouth | 10% · 5.1 r | 11% · 6.0 r | 36% · 10.4 r, won 95% | 0.35 |
| Three: the Honey Badger, the Baboon, the Prairie Dog | 12% · 6.9 r | 11% · 6.3 r | 32% · 10.7 r, won 95% | 0.26 |
| Three: the Baboon, the Skua, the Cassowary | 18% · 7.3 r, won 99% | 19% · 7.9 r, won 97% | 52% · 13.8 r, won 77% | 0.90 |
| Three: the Stingray, the Storm Petrel, the Cottonmouth | 12% · 6.3 r | 10% · 6.9 r | 52% · 13.0 r, won 72% | 1.04 |
| Three: the Baboon, the Storm Petrel, the Prairie Dog | 18% · 8.6 r, won 99% | 16% · 9.1 r, won 98% | 52% · 15.0 r, won 70% | 1.07 |
| Three: the Stingray, the Skua, the Cottonmouth | 11% · 6.6 r | 13% · 7.7 r, won 99% | 61% · 15.1 r, won 61% | 1.39 |
| Four: the Honey Badger, the Baboon, the Skua, the Cassowary | 4% · 4.5 r | 5% · 4.9 r | 15% · 8.0 r | 0.07 |
| Four: the Baboon, the Skua, the Cassowary, the Stingray | 5% · 5.1 r | 5% · 5.2 r | 16% · 8.0 r | 0.05 |
| Four: the Stingray, the Storm Petrel, the Cottonmouth, the Honey Badger | 4% · 4.0 r | 4% · 4.5 r | 11% · 7.0 r | 0.03 |

Every fight, hull lost (T1 to T8 the trios in the table's order, F1 to F3 the fours):

| Fight | Kind | T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8 | F1 | F2 | F3 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `goblin_horde` | formation | 1% | 1% | 0% | 1% | 0% | 0% | 0% | 0% | 0% | 0% | 0% |
| `treant_grove` | formation | 4% | 3% | 1% | 4% | 5% | 2% | 3% | 3% | 1% | 1% | 1% |
| `gel_wall` | formation | 3% | 3% | 1% | 8% | 5% | 0% | 8% | 1% | 0% | 1% | 0% |
| `shamans_warband` | elite | 0% | 0% | 0% | 0% | 1% | 0% | 0% | 0% | 0% | 0% | 0% |
| `the_nob` | elite | 24% | 11% | 15% | 10% | 22% | 10% | 13% | 19% | 9% | 5% | 3% |
| `floraison` | boss | 26% | 23% | 30% | 27% | 60% (won 80%) | 61% (won 90%) | 43% (won 90%) | 86% (won 50%) | 4% | 10% | 10% |
| `king_gel` | boss | 34% | 16% | 36% | 13% | 27% | 20% | 26% | 16% | 9% | 9% | 6% |
| `mantis_ant` | boss | 30% | 13% | 21% | 12% | 23% | 14% | 8% | 23% (won 90%) | 9% | 6% | 6% |
| `needler_thicket` | formation | 2% | 5% | 3% | 4% | 5% | 3% | 4% | 1% | 1% | 2% | 0% |
| `sandworm_ambush` | formation | 35% | 18% | 24% | 24% | 26% | 23% | 29% | 13% | 10% | 9% | 10% |
| `old_mans_rising` | elite | 43% | 18% | 27% | 20% | 36% (won 90%) | 16% | 29% | 19% | 9% | 7% | 12% |
| `pilgrims_wake` | elite | 14% | 6% | 5% | 10% | 15% | 3% | 15% | 12% | 6% | 2% | 0% |
| `rust_monsters_scavenge` | elite | 5% | 1% | 2% | 1% | 4% | 1% | 1% | 3% | 1% | 1% | 1% |
| `gilgamesh_wanders` | elite | 30% | 5% | 9% | 7% | 12% | 9% | 9% | 4% | 3% | 1% | 3% |
| `ruby_colossus` | boss | 79% (won 50%) | 49% (won 90%) | 48% | 72% (won 70%) | 98% (won 10%) | 94% (won 10%) | 100% (won 0%) | 100% (won 0%) | 21% | 31% | 11% |
| `fallen_weapon` | boss | 72% (won 60%) | 34% | 61% (won 80%) | 55% (won 80%) | 91% (won 20%) | 100% (won 10%) | 100% (won 0%) | 100% (won 0%) | 18% | 24% | 10% |
| `emperor_scorpion` | boss | 78% (won 60%) | 40% | 80% (won 60%) | 58% (won 90%) | 71% (won 70%) | 93% (won 20%) | 88% (won 40%) | 93% (won 30%) | 27% | 20% | 29% |
| `grave_throng` | formation | 0% | 2% | 1% | 2% | 1% | 0% | 1% | 0% | 0% | 0% | 0% |
| `barrow_mound` | formation | 5% | 1% | 2% | 1% | 3% | 4% | 3% | 4% | 0% | 1% | 1% |
| `knights_vigil` | formation | 34% | 23% | 25% | 25% | 38% | 31% | 38% | 34% | 13% | 16% | 12% |
| `fell_riders_hunt` | elite | 8% | 2% | 1% | 2% | 8% | 2% | 3% | 1% | 2% | 1% | 1% |
| `the_reaper` | elite | 0% | 0% | 1% | 1% | 1% | 0% | 3% | 0% | 0% | 0% | 0% |
| `the_wild_hunt` | elite | 35% | 20% | 27% | 31% | 59% (won 80%) | 37% | 57% (won 80%) | 37% | 14% | 21% | 13% |
| `matador` | boss | 31% | 20% | 18% | 19% | 30% | 36% | 20% | 42% (won 90%) | 8% | 8% | 4% |
| `phantom_train` | boss | 67% (won 80%) | 22% | 45% (won 90%) | 42% | 66% (won 70%) | 59% (won 80%) | 78% (won 50%) | 82% (won 50%) | 22% | 18% | 10% |
| `vampire_lord` | boss | 14% | 5% | 8% | 4% | 20% | 8% | 8% | 16% | 2% | 1% | 1% |
| `marsh_serpent` | boss | 26% | 13% | 21% | 22% | 29% | 24% | 28% | 31% | 9% | 2% | 3% |
| `ember_pyre` | formation | 17% | 15% | 7% | 34% | 47% (won 90%) | 17% | 55% (won 90%) | 13% | 3% | 6% | 1% |
| `magma_vent` | formation | 38% | 21% | 35% | 16% | 45% | 39% | 39% | 36% | 14% | 16% | 13% |
| `cinder_tortoises_brood` | elite | 29% | 10% | 13% | 12% | 16% | 9% | 10% | 13% | 7% | 4% | 4% |
| `thunder_apes_rampage` | elite | 27% | 18% | 27% | 23% | 36% | 25% | 34% | 39% (won 90%) | 4% | 13% | 7% |
| `gargantuan_king` | boss | 38% | 12% | 21% | 11% | 28% (won 90%) | 20% | 16% | 19% | 11% | 9% | 14% |
| `fiend_of_fire` | boss | 36% | 38% | 32% | 46% | 67% (won 70%) | 98% (won 20%) | 81% (won 50%) | 98% (won 10%) | 17% | 30% | 20% |
| `obsidian_tyrant` | boss | 63% | 33% | 49% | 38% | 70% (won 90%) | 53% | 84% (won 80%) | 81% (won 70%) | 41% | 39% | 20% |

Read.

- The fourth machine halves or thirds everything, and the boss most. A formation costs three
  machines 9% to 18% and four 4% to 5%; an elite 8% to 20% and 4% to 5%; a boss 24% to 61%
  and 11% to 16%. A boss is nine to fifteen rounds for three where it is seven or eight for
  four, and wrecks a machine in one fight of nine at best and more than one a fight at worst,
  where four lose one in twenty.
- A trio without the Badger loses a quarter to two fifths of its boss fights. The Waste's
  three bosses are walls for it (their parts breach), and Floraison and the Fiend of Fire, who
  strike many times, close to it.
- The six fodder formations are on the pusher's budget for three (0% to 8%). The four led by
  a breach are not (the sandworm ambush 13% to 35%, the knights' vigil 23% to 38%, the magma
  vent 16% to 45%, the ember pyre 7% to 55%); breach under the regen is parked on his word.
- An elite at three is near the hull budget he accepted with the model (a tenth to a fifth of
  the squad's hull), where at four it is a twentieth. The Old Man's rising (16% to 43%), the
  Wild Hunt (20% to 59%, two trios losing one fight in five) and the Thunder Ape (18% to 39%)
  are the dear ones.

### What an offer buys at tier one: kit against a fourth machine

His second Convergence at "3.5 units" leans on what the hangar adds to three machines, so
the same probe with tier-one kit fitted: the Ablative Plating (8 hull and a point of armour,
the heaviest tier-one module) and the Slugthrower (a plain 4 in a Twin Autoguns' slot), on one
machine or on all three, against the same squad with a stock fourth. Two trios, 10 seeds, the
mean hull lost to a formation, an elite and a boss, the boss's wins beside it:

| The squad | The Honey Badger, the Baboon, the Skua | The Stingray, the Storm Petrel, the Cottonmouth |
|---|---|---|
| Three, stock | 14%, 20%, 46% (won 88%) | 12%, 10%, 52% (won 72%) |
| One offer: a module on one machine | 12%, 16%, 41% (won 89%) | 11%, 9%, 49% (won 75%) |
| One offer: a tier-one gun on one machine | 12%, 17%, 44% (won 88%) | 12%, 10%, 52% (won 72%) |
| Three offers: a module on each | 10%, 12%, 31% (won 95%) | 8%, 6%, 37% (won 87%) |
| Six offers: a module and a gun on each | 9%, 10%, 28% (won 98%) | 7%, 6%, 31% (won 95%) |
| One offer: a fourth machine, stock | 4%, 5%, 15% (won 100%) | 4%, 4%, 11% (won 100%) |

Read. At tier one kit does not stand in for a machine. One offer spent on kit moves a boss's
cost by nought to five points; the same offer spent on a chassis cuts it by two thirds. Six
offers of the best tier-one kit, more than tier one has battles, leave a boss twice as dear
as one stock machine more does. So with a slot empty the chassis is the pick every time, three
and a half is no state a squad is in, and the choice between a machine and better kit only
begins at the fifth machine.

### The first boss, sized for three

Every tier-one boss at a share of its hit points and of its blow, three machines, the mean of
the thirteen:

| Hit points | Blow | The Honey Badger, the Baboon, the Skua | The Honey Badger, the Stingray, the Cassowary | The Stingray, the Storm Petrel, the Cottonmouth |
|---|---|---|---|---|
| whole | whole | 46% · 10.5 r, won 88% · 0.61 wrecked | 24% · 8.6 r, won 99% · 0.11 wrecked | 52% · 13.0 r, won 72% · 1.04 wrecked |
| seven eighths | whole | 41% · 9.5 r, won 91% · 0.50 wrecked | 21% · 7.6 r · 0.08 wrecked | 46% · 12.0 r, won 78% · 0.82 wrecked |
| three quarters | whole | 32% · 8.3 r, won 97% · 0.29 wrecked | 16% · 6.5 r, won 99% · 0.07 wrecked | 40% · 10.1 r, won 86% · 0.52 wrecked |
| two thirds | whole | 28% · 7.3 r, won 97% · 0.24 wrecked | 14% · 5.9 r · 0.06 wrecked | 28% · 8.9 r, won 94% · 0.25 wrecked |
| whole | three quarters | 25% · 10.1 r, won 99% · 0.13 wrecked | 13% · 8.2 r · 0.00 wrecked | 31% · 13.2 r, won 92% · 0.31 wrecked |
| seven eighths | three quarters | 22% · 9.2 r, won 98% · 0.10 wrecked | 10% · 7.3 r · 0.00 wrecked | 23% · 10.9 r, won 99% · 0.09 wrecked |
| three quarters | three quarters | 17% · 7.8 r · 0.04 wrecked | 8% · 6.2 r · 0.01 wrecked | 16% · 8.9 r · 0.02 wrecked |
| two thirds | three quarters | 14% · 6.9 r · 0.03 wrecked | 7% · 5.6 r · 0.00 wrecked | 11% · 7.5 r · 0.01 wrecked |

Read. At three quarters of both, three machines pay a boss what four pay it whole (8% to 17%
against 11% to 16%), in six to nine rounds, with no machine wrecked: a boss for three is three
quarters of a boss for four. Hit points alone do not do it: at two thirds of the hit points
(the old 48) and the whole blow two trios still lose a quarter of their hull and a machine in
one fight of four.

## 11 November, the Rupture meter by the tier and the Convergence, and the first battle played whole

Ryan, 11 November: "I was going to say that the 3 fractures, with the current rate of fill,
felt short to me. I assume that needs to be tuned still, though. The answer could be that the
amount to reach a fracture probably scales by Convergence, with a step down at each tier when
we add another fracture step. Makes sense, or no? Either way, I think battle one should only
serve one elite. With 3 fractures, that was sending two elites, right?" The decisions these
inform, both his: the Rupture meter's size and whether it moves by the tier and the
Convergence (the bible's pacing row; on trial as a dial, `Battle.rupture_trial`), and the
first battle's shape (the refit brief's section 10). Each a direction.

### The meter as the game sets it

Method: `Battle.setup` on every domain at each tier and a Convergence in each of the ramp's
bands, 20 seeds, the thresholds as set; the menace of the tier's formations, patrols and elite
compositions the ramp's gate holds, the mean of each kind; then every Fracture paid at once,
to count the elites sent. A size in formations' worth is the threshold over the domain's mean
formation, its range over the four domains. The big fights' worth is the elites sent and the
formations it takes beside their kills, patrols aside.

| The rift | The opening places | The Rupture, in formations' worth | The first Fracture | A Fracture, on average | An elite's kill | Elites sent | Big fights' worth to the Rupture |
|---|---|---|---|---|---|---|---|
| Tier one, Convergences 0 to 2 | one formation, two patrols | 2.4 to 2.5 | 0.53 to 0.57 | 0.78 to 0.83 | 0.72 to 0.91 | 1 | 2.4 to 2.7 |
| Tier one, from Convergence 3 | two formations and two patrols, three and one from Convergence 8 | 3.1 to 3.4 | 0.69 to 0.76 | 1.04 to 1.14 | 0.69 to 0.91 | 1 | 3.3 to 3.6 |
| Tier two, Convergences 4 to 7 | two formations, two patrols | 3.7 | 0.52 to 0.53 | 0.91 to 0.93 | 0.62 to 0.81 | 2 | 4.1 to 4.4 |
| Tier two, from Convergence 8 | three formations, one patrol | 3.7 to 4.2 | 0.53 to 0.60 | 0.93 to 1.04 | 0.62 to 0.78 | 2 | 4.4 to 4.6 |
| Tier three | three formations, one patrol | 4.0 to 5.0 | 0.41 to 0.49 | 0.81 to 1.00 | 0.52 to 0.65 | 3 | 5.1 to 6.4 |

By domain, in menace:

| Domain | The rift | The field's menace | The Fractures at | A formation | A patrol | An elite's pack |
|---|---|---|---|---|---|---|
| The Meadow | tier one, Convergence 0 | 138 | 21, 51, 92 | 37 | 12 | 29 |
| The Meadow | tier one, Convergence 3 | 188 | 28, 70, 126 | 37 | 13 | 29 |
| The Meadow | tier two, Convergence 4 | 240 | 23, 57, 103, 161 | 44 | 15 | 30 |
| The Meadow | tier three, Convergence 8 | 277 | 19, 46, 84, 130, 186 | 46 | 16 | 30 |
| The Waste | tier one, Convergence 0 | 143 | 21, 53, 96 | 39 | 17 | 35 |
| The Waste | tier one, Convergence 3 | 194 | 29, 72, 130 | 39 | 18 | 35 |
| The Waste | tier two, Convergence 4 | 239 | 23, 57, 103, 160 | 43 | 17 | 35 |
| The Waste | tier three, Convergence 8 | 444 | 30, 74, 134, 208, 297 | 63 | 25 | 36 |
| The Marsh | tier one, Convergence 0 | 120 | 18, 45, 80 | 34 | 7 | 31 |
| The Marsh | tier one, Convergence 3 | 162 | 24, 60, 109 | 34 | 11 | 31 |
| The Marsh | tier two, Convergence 4 | 251 | 24, 60, 108, 168 | 45 | 9 | 32 |
| The Marsh | tier three, Convergence 8 | 402 | 27, 67, 121, 189, 269 | 55 | 10 | 32 |
| The Peak | tier one, Convergence 0 | 192 | 29, 71, 129 | 54 | 9 | 39 |
| The Peak | tier one, Convergence 3 | 250 | 37, 93, 168 | 54 | 14 | 39 |
| The Peak | tier two, Convergence 4 | 320 | 31, 77, 138, 214 | 58 | 10 | 36 |
| The Peak | tier three, Convergence 8 | 513 | 34, 86, 155, 241, 344 | 69 | 12 | 36 |

Read.

- One elite at tier one, the first Fracture's, in every domain and on every seed; two at tier
  two and three at tier three, as the rules have it. An elite is one pack: the Wild Hunt's is
  three Riders, the one tier-one elite that arrives as more than one foe of the rank.
- The shape he names is the meter's own. The Rupture is two thirds of the field's menace (the
  opening's packs and the rift's first waves, as many as the tier has Fractures), split over
  the tier's Fractures. So it grows where the ramp grows the opening, at Convergences 3 and 8,
  and a Fracture is cheaper at each tier that adds one: 1.04 to 1.14 of a formation where tier
  one ends, 0.91 to 0.93 where tier two starts, 0.81 to 1.00 at tier three. It moves at the
  ramp's steps only, never between them.
- What is short is tier one before Convergence 3. The Rupture there is two and a half
  formations' worth and an elite's kill is most of one, so the opening's formation, the first
  wave's formation and the elite fill it in every domain: 2.4 to 2.7 big fights' worth, where
  tier two takes 4.1 to 4.6 and tier three 5.1 to 6.4. The pacing row asks four to five at
  every tier.
- Two things in how it is built make it so. The elites the Fractures send fill the meter and
  are not in its base: one is a third of tier one's Rupture. And the rift's first three waves
  are a formation, a patrol and a formation, on the player's turns 2, 5 and 8 at a beat of
  three, while every tear sends a patrol a peak: past the opening's formation and the first
  wave's, what the tide supplies until the eighth turn is patrols.
- The first battle's two formations are one composition. The opening places the domain's
  first formation in content order and the first wave sends it again, on every seed (the
  cycle starts at its head whatever the opening placed): two goblin hordes in the Meadow, two
  needler thickets in the Waste, two grave throngs in the Marsh, two ember pyres on the Peak,
  the second composition coming with the third wave. On the Peak that first formation is led
  by a breach, and a trio reaches the Rupture there in 5% to 30% of its battles (below); the
  two are not told apart by any read here.

### The first battle whole, and the meter's size

Method: a scratch probe on the battle's own setup and the runner's player (`BattleBot`, the
greedy rung, the defence rule: it never gathers, never reads a fight's odds and fights every
fight out, a floor and no player). Tier one at Convergence 0, each domain, its three bosses in
turn by the seed, 20 seeds a cell. Three starting trios (the Honey Badger, the Baboon and the
Skua; the Honey Badger, the Stingray and the Cassowary; the Stingray, the Storm Petrel and the
Cottonmouth), a cell their range, and one four (the first trio and the Cassowary). The meter's
size is every threshold by a factor as the battle is set up, which is what
`Battle.rupture_trial` does. Read as the Rupture comes, over the battles that reached it: the
player's turn, the first counted one, the fights fought so far, the squad's hull, the gate.

The first battle as it is:

| Domain | The squad | Won | The team wiped | The gate fell | The Rupture reached | Its turn | Fights to it | Of them formations; patrols; the elite's | Hull then | The gate then, of 200 |
|---|---|---|---|---|---|---|---|---|---|---|
| The Meadow | three | 40% to 60% | 10% to 40% | 0% to 50% | 65% to 90% | 3.3 to 4.8 | 3.5 to 4.7 | 2.0 to 2.2; 0.4 to 1.2; 1.1 to 1.4 | 71% to 80% | 167 to 189 |
| The Meadow | four | 65% | 0% | 35% | 100% | 4.6 | 5.0 | 2.5; 1.4; 1.1 | 65% | 178 |
| The Marsh | three | 15% to 55% | 30% to 45% | 15% to 40% | 60% to 80% | 3.0 to 5.0 | 3.4 to 4.8 | 1.9 to 2.2; 0.4 to 1.2; 0.9 to 1.6 | 60% to 77% | 172 to 194 |
| The Marsh | four | 55% | 5% | 40% | 90% | 4.1 | 4.4 | 2.4; 0.8; 1.1 | 64% | 180 |
| The Waste | three | 0% to 15% | 45% to 95% | 5% to 55% | 60% to 90% | 4.4 to 6.5 | 4.7 to 5.7 | 2.0 to 2.6; 1.3 to 2.7; 0.8 to 1.1 | 48% to 54% | 126 to 171 |
| The Waste | four | 10% | 35% | 55% | 100% | 5.8 | 6.0 | 2.5; 2.5; 1.0 | 58% | 163 |
| The Peak | three | 0% to 5% | 55% to 95% | 5% to 40% | 5% to 30% | 4.0 to 8.5 | 4.0 to 7.0 | 2.0 to 2.5; 1.0 to 4.0; 0.5 to 1.0 | 15% to 81% | 120 to 180 |
| The Peak | four | 10% | 40% | 50% | 40% | 7.1 | 6.5 | 3.4; 2.2; 0.9 | 25% | 145 |

The meter's size:

| Domain, the squad | The meter | The Rupture reached | By the guard | Its turn | Fights to it | Of them formations; patrols; the elite's | Hull then | The gate then, of 200 | Won |
|---|---|---|---|---|---|---|---|---|---|
| The Meadow, three | as it is | 65% to 90% | 0% | 3.3 to 4.8 | 3.5 to 4.7 | 2.0 to 2.2; 0.4 to 1.2; 1.1 to 1.4 | 71% to 80% | 167 to 189 | 40% to 60% |
| The Meadow, three | half again | 50% to 85% | 30% to 41% | 7.5 to 7.6 | 7.3 to 7.4 | 2.2 to 2.7; 3.4 to 3.9; 1.1 to 1.3 | 51% to 81% | 129 to 137 | 15% to 20% |
| The Meadow, three | doubled | 20% to 60% | 25% to 40% | 9.5 to 10.6 | 9.1 to 10.6 | 2.5 to 2.8; 5.3 to 6.5; 1.0 to 1.4 | 41% to 73% | 92 to 103 | 5% to 15% |
| The Marsh, three | as it is | 60% to 80% | 0% | 3.0 to 5.0 | 3.4 to 4.8 | 1.9 to 2.2; 0.4 to 1.2; 0.9 to 1.6 | 60% to 77% | 172 to 194 | 15% to 55% |
| The Marsh, three | half again | 45% to 80% | 0% to 6% | 5.4 to 7.0 | 5.6 to 6.4 | 2.1 to 2.4; 2.3 to 2.5; 1.0 to 1.7 | 52% to 75% | 135 to 159 | 5% to 25% |
| The Marsh, three | doubled | 10% to 70% | 0% to 50% | 8.1 to 11.0 | 8.0 to 10.5 | 2.6 to 3.5; 4.3 to 5.6; 1.0 to 1.5 | 30% to 61% | 90 to 119 | 0% to 10% |
| The Waste, three | as it is | 60% to 90% | 0% | 4.4 to 6.5 | 4.7 to 5.7 | 2.0 to 2.6; 1.3 to 2.7; 0.8 to 1.1 | 48% to 54% | 126 to 171 | 0% to 15% |
| The Waste, three | half again | 15% to 45% | 0% to 22% | 8.0 to 8.6 | 7.0 to 7.6 | 2.2 to 2.3; 3.7 to 4.4; 1.0 | 38% to 60% | 92 to 125 | 0% |
| The Waste, three | doubled | 10% to 35% | 0% to 50% | 8.5 to 12.5 | 8.0 to 10.5 | 2.0 to 2.6; 4.4 to 7.0; 1.0 to 1.5 | 21% to 62% | 60 to 121 | 0% |
| The Peak, three | as it is | 5% to 30% | 0% | 4.0 to 8.5 | 4.0 to 7.0 | 2.0 to 2.5; 1.0 to 4.0; 0.5 to 1.0 | 15% to 81% | 120 to 180 | 0% to 5% |
| The Peak, three | half again | 0% to 5% | 0% | 9.0 to 11.0 | 9.0 | 2.0; 6.0; 1.0 | 29% to 69% | 90 to 110 | 0% |
| The Peak, three | doubled | 0% | | | | | | | 0% |
| The Meadow, four | as it is | 100% | 0% | 4.6 | 5.0 | 2.5; 1.4; 1.1 | 65% | 178 | 65% |
| The Meadow, four | half again | 85% | 71% | 7.2 | 7.8 | 2.5; 4.1; 1.2 | 69% | 153 | 35% |
| The Meadow, four | doubled | 75% | 47% | 8.9 | 9.6 | 3.2; 5.3; 1.1 | 56% | 116 | 35% |

The Meadow's first battle with the levers the refit brief's section 10 names, the boss in a
first block of its own (three quarters of its hit points and of its blow) and one flank
patrol at the start where the ramp places two:

| The Meadow's first battle, three machines | The meter | Won | The team wiped | The gate fell | The Rupture's turn | By the guard | Hull then | The gate then, of 200 |
|---|---|---|---|---|---|---|---|---|
| As it is | as it is | 40% to 60% | 10% to 40% | 0% to 50% | 3.3 to 4.8 | 0% | 71% to 80% | 167 to 189 |
| As it is | half again | 15% to 20% | 25% to 30% | 50% to 60% | 7.5 to 7.6 | 30% to 41% | 51% to 81% | 129 to 137 |
| The boss at three quarters of its hit points and of its blow | as it is | 40% to 70% | 10% to 30% | 0% to 50% | 3.3 to 4.8 | 0% | 71% to 80% | 167 to 189 |
| The boss at three quarters of its hit points and of its blow | a quarter more | 25% to 40% | 20% to 30% | 30% to 55% | 5.6 to 6.8 | 6% to 8% | 58% to 84% | 133 to 155 |
| The boss at three quarters of its hit points and of its blow | half again | 15% to 25% | 15% to 30% | 50% to 60% | 7.5 to 7.6 | 30% to 41% | 51% to 81% | 129 to 137 |
| That boss, and one flank patrol at the start | as it is | 55% to 80% | 15% to 20% | 0% to 30% | 3.1 to 5.2 | 0% | 62% to 90% | 160 to 195 |
| That boss, and one flank patrol at the start | a quarter more | 25% to 55% | 20% to 25% | 25% to 50% | 5.1 to 6.9 | 8% to 14% | 59% to 90% | 128 to 173 |
| That boss, and one flank patrol at the start | half again | 15% to 55% | 15% to 25% | 30% to 60% | 6.2 to 8.5 | 27% to 82% | 54% to 89% | 120 to 164 |
| One flank patrol at the start, the boss whole: two of the trios | as it is | 40% to 75% | 25% to 30% | 0% to 30% | 3.1 to 5.2 | 0% | 62% to 90% | 160 to 195 |
| One flank patrol at the start, the boss whole: two of the trios | half again | 15% to 50% | 20% to 25% | 30% to 60% | 6.2 to 8.5 | 27% to 82% | 54% to 89% | 120 to 164 |
| As it is, the same two trios | as it is | 40% to 60% | 10% to 30% | 10% to 50% | 3.4 to 4.8 | 0% | 71% to 80% | 167 to 189 |
| As it is, the same two trios | half again | 15% | 25% | 60% | 7.5 | 30% to 41% | 51% to 81% | 129 to 137 |

Read.

- As it is the seal breaks on the bot's fourth turn or so (3.0 to 5.0 in the Meadow and the
  Marsh, 4.4 to 6.5 in the Waste), after two formations, the elite and a patrol. That is his
  "short".
- A longer meter is more turns and more patrols, not more formations. In the Meadow half
  again the meter is the Rupture three or four turns later (7.5 to 7.6 against 3.3 to 4.8),
  with 3.4 to 3.9 patrol fights where there were 0.4 to 1.2 and the same two formations;
  doubled, the tenth turn and five or six patrols. It is the quantity game for non-elites he
  asked for on 10 November, and it is fought on the flanks.
- The gate pays for the turns. By the Rupture it has lost 11 to 33 of its 200 as it is, 63 to
  71 at half again and 97 to 108 doubled, and the bot's wins in the Meadow go from 40% to 60%
  of its first battles to 15% to 20% and 5% to 15%. This player leaves its flanks, so the
  sizes are the direction and not a player's.
- The stall guard caps the meter. A field cleared breaks the seal whatever the meter reads:
  never as it is, 30% to 41% of the trios' Ruptures in the Meadow at half again, 71% of the
  four's. From about half again, a squad ahead of the tide ends on the guard and the meter's
  size no longer reaches it.
- The first battle is no gift as it stands. The floor player wins 40% to 60% of them in the
  Meadow, 15% to 55% in the Marsh, 0% to 15% in the Waste and 0% to 5% on the Peak, and a
  fourth machine moves that less than it moves a single fight (65%, 55%, 10% and 10%), since
  what this player loses to is the wall it does not cover and the machines it sends in alone.
- The boss's first block alone does not make the Meadow's first battle easy for this player:
  at three quarters of both the wins are 40% to 70% where they were 40% to 60%, since most of
  its losses come before the boss. One flank patrol fewer at the start does more for the gate
  (it falls in 0% to 30% of the battles where it fell in 0% to 50%), and the two together win
  55% to 80%. A player who gathers is not this one: the single fights of the section above
  are what a gathered trio pays.

## 11 November, pacing from scratch: the tide by beat, a fight's length, the meter in beats

Ryan, 11 November: "I don't think the 4 to 5 guideline holds anything anymore. This is a
different game now. I think start this pacing and length discussion from scratch. We know the
elite needs to be worth a good chunk of malice, so work that in. And the fact that flanker
fights are faster, so we have more buffer for more fights. And that formation size goes up
with convergence, so scaling fracture cost at the same rate doesn't actually change anything."
The decision these inform, his: how long a battle runs before its boss and what the Rupture
meter is sized in (the bible's pacing row, its count retired that day; the refit brief's
section 11). Each a direction.

### The tide by beat

Method: `Battle.setup` and `Battlefield.peak` with nobody fighting, five seeds a cell (the
schedule is the content's order, the same on every seed): what stands at the start and what
each peak adds, by kind, with its menace. A beat is a peak of Rift Pressure, every three turns
(two from Convergence 8), the first at the end of the first turn; a peak sends the rift's next
composition and a patrol from every tear open before it, and opens a tear (two from
Convergence 8). A lone patrol is rated one, a heavier one two (a pair of duelists, a hunting
pack). Tier one at Convergence 0, each cell what arrives, its menace and the menace so far:

| Beat | On the field for the player's turn | The Meadow | The Waste | The Marsh | The Peak |
|---|---|---|---|---|---|
| The opening | 1 | 1 formation, 2 lone (52, 52 so far) | 1 formation, 2 lone (56, 56 so far) | 1 formation, 2 lone (46, 46 so far) | 1 formation, 2 lone (76, 76 so far) |
| Peak 1 | 2 | 1 formation (36, 88 so far) | 1 formation (36, 92 so far) | 1 formation (32, 78 so far) | 1 formation (58, 134 so far) |
| Peak 2 | 5 | 2 lone (16, 104 so far) | 2 lone (20, 112 so far) | 2 lone (14, 92 so far) | 2 lone (18, 152 so far) |
| Peak 3 | 8 | 1 formation, 1 lone, 1 heavier (66, 170 so far) | 1 formation, 1 lone, 1 heavier (75, 187 so far) | 1 formation, 2 lone (49, 141 so far) | 1 formation, 2 lone (67, 219 so far) |
| Peak 4 | 11 | 1 lone, 3 heavier (56, 226 so far) | 1 lone, 3 heavier (82, 269 so far) | 1 formation, 3 lone (55, 196 so far) | 1 formation, 3 lone (85, 304 so far) |
| Peak 5 | 14 | 1 formation, 2 lone, 2 heavier (80, 306 so far) | 1 formation, 2 lone, 2 heavier (104, 373 so far) | 1 formation, 4 lone (60, 256 so far) | 5 lone (45, 349 so far) |

What a battle holds through each of its first three peaks, the elites its Fractures send
counted in, every domain's range:

| The rift | The beat, turns | Elites | Through the first peak | Through the second | Through the third |
|---|---|---|---|---|---|
| Tier one, Convergences 0 to 2 | 3 | 1 | 5 fights: 2 formations, 2 patrols, by turn 2 | 7 fights: 2 formations, 4 patrols, by turn 5 | 10 fights: 3 formations, 6 patrols, by turn 8 |
| Tier one, from Convergence 3 | 3 | 1 | 6 fights: 3 formations, 2 patrols, by turn 2 | 8 fights: 3 formations, 4 patrols, by turn 5 | 11 fights: 4 formations, 6 patrols, by turn 8 |
| Tier two, Convergences 4 to 7 | 3 | 2 | 7 fights: 3 formations, 2 patrols, by turn 2 | 9 fights: 3 formations, 4 patrols, by turn 5 | 12 fights: 4 formations, 6 patrols, by turn 8 |
| Tier two, from Convergence 8 | 2 | 2 | 7 fights: 4 formations, 1 patrols, by turn 2 | 10 fights: 4 formations, 4 patrols, by turn 4 | 15 fights: 4 to 5 formations, 8 to 9 patrols, by turn 6 |
| Tier three | 2 | 3 | 8 fights: 4 formations, 1 patrols, by turn 2 | 11 fights: 4 formations, 4 patrols, by turn 4 | 16 fights: 5 formations, 8 patrols, by turn 6 |

### A fight's length

From the reads on file, tier one, stock, the greedy rung (10 November, the duelists; 11
November, the starting trios and the fours), in machine-turns, one machine acting once, the
unit of the player's time in a fight:

| The fight | Rounds | Machines in it | Machine-turns |
|---|---|---|---|
| A lone duelist | 2.0 to 9.1, mean 4.1 | 1 | 4 |
| A formation | 5.1 to 8.6, mean 6.6, for three; 4.0 to 5.1 for four | 3 or 4 | 20 or 18 |
| An elite's pack | 5.4 to 9.1, mean 6.9, for three; 4.5 to 5.2 for four | 3 or 4 | 21 or 20 |
| A boss | 8.6 to 15.1, mean 12.1, for three; 7.0 to 8.0 for four | 3 or 4 | 36 or 31 |

A heavier patrol has no read of its own with two machines in it. The first battle, three
machines, everything killed: through the first peak 2 formations, 2 lone duels and the elite
are 68 machine-turns and the boss 36 more; through the second peak 4 lone duels, 76; through
the third 3 formations and 5 or 6 patrols, 100 to 104 with a heavier patrol counted as a lone
one.

What the meter pays for the time, tier one: a lone patrol 7 to 10 menace, 1.7 to 2.4 a
machine-turn; a formation 32 to 58, 1.6 to 2.9; an elite's pack 22 to 49 by which elite the
roll sends (the Rust Monster's scavenge to the Pilgrim's wake), 1.1 to 2.4.

### The meter as it stands, in beats

The thresholds of the section above (11 November, the meter as the game sets it) against the
tide: the Rupture, what its elites' kills fill at their mean, what is left for the field, and
what the opening alone holds. Every domain's range:

| The rift | The Rupture | Its elites' kills | Left for the field | The opening holds | The first wave adds | The field's part, of the opening |
|---|---|---|---|---|---|---|
| Tier one, Convergence 0 | 80 to 129 | 29 to 39 | 49 to 90 | 46 to 76 | 32 to 58 | 106% to 121% |
| Tier one, Convergence 3 | 109 to 168 | 29 to 39 | 78 to 129 | 88 to 134 | 32 to 58 | 88% to 96% |
| Tier two, Convergence 4 | 160 to 214 | 60 to 72 | 90 to 142 | 107 to 136 | 39 to 58 | 77% to 104% |
| Tier three, Convergence 8 | 186 to 344 | 90 to 108 | 96 to 236 | 128 to 224 | 35 to 82 | 75% to 105% |

An elite's pack against its tier's mean formation: 0.57 to 1.34 of one at tier one, 0.51 to
1.15 at tier two, 0.35 to 0.82 at tier three (its menace is its content's numbers, the same at
every tier, while a formation's grows).

Read.

- The meter asks nothing of the tide. At every tier the field's part of the Rupture is about
  what the opening places (75% to 105% of it from Convergence 3 on, the opening and a tenth to
  a third of the first wave before that), and the elites it calls fill the rest. A squad that kills what
  stood at the start and the elites has broken the seal, by its fourth turn or so, whatever
  the tier. The dial's settings at tier one's start, with the elite's own menace: 1X is the
  opening, 1.25X the first peak, 1.5X the second, 2X nearly the third.
- A beat is the unit that means the same at every tier. Menace is not, since a formation's
  grows with the tier and the opening's count with the Convergence (his point: a threshold
  scaled at that rate changes nothing). A count of fights is not, since a lone duel is a fifth
  of a formation's fight in the player's time.
- At a fixed number of beats the battle grows by itself. Through the second peak it is 7
  fights before the boss at tier one's start, 8 from Convergence 3, 9 at tier two, 10 from
  Convergence 8 and 11 at tier three; through the third, 10 to 16. From Convergence 8 the
  third peak alone adds five fights, the tears opening two a peak.
- The second beat is cheap in time and the third is not. At tier one's start the second peak
  is two lone duels, 8 machine-turns on about a hundred with the boss; the third is a
  formation, two patrols and the first hunting packs, 24 to 28 more.
- The meter already pays a duel about what it costs in time, a fifth to a quarter of a
  formation for a fifth of its length. It underpays the elite and by a roll: a third to one
  and a third of a formation for a fight as long as a formation's.

### The Rupture sized in beats, played whole

Method: the scratch probe of 11 November's first battle played whole, the thresholds set as
the first shape has them (the refit brief's section 11) and the game's rule untouched: the
field's part everything the opening places and the tide sends through its Kth peak (the
rift's cycle and the tears' patrols as `Battlefield.peak` sends them), one lone patrol's
worth left; an elite's fall filling a formation and a half of the tier's mean formation in
place of its own menace; the Fractures at the steps as built. The runner's player (the
floor: it never gathers and leaves its flanks), 20 seeds a cell, each domain's bosses in turn.
"As it is" is the game's rule. Read as the Rupture comes, over the battles that reached it;
the bar as the elite falls is the meter's share of the Rupture once its pack is dead.

Tier one at Convergence 0, three trios (the Honey Badger, the Baboon and the Skua; the Honey
Badger, the Stingray and the Cassowary; the Stingray, the Storm Petrel and the Cottonmouth), a
cell their range:

| Domain | The Rupture | In menace | Reached | By the guard | Its turn | Fights before it | Of them formations; patrols; the elite's | Hull then | The gate then, of 200 | The bar as the elite falls | Won |
|---|---|---|---|---|---|---|---|---|---|---|---|
| The Meadow | as it is | 92 | 65% to 90% | 0% | 3.3 to 4.8 | 3.5 to 4.7 | 2.0 to 2.2; 0.4 to 1.2; 1.1 to 1.4 | 71% to 80% | 167 to 189 | 68% to 73% | 40% to 60% |
| The Meadow | two beats | 151 | 60% to 85% | 6% to 8% | 5.8 to 6.5 | 5.9 to 6.4 | 2.0 to 2.6; 2.5 to 2.9; 1.1 to 1.3 | 58% to 84% | 140 to 154 | 61% to 66% | 20% to 40% |
| The Meadow | three beats | 217 | 20% to 50% | 20% to 29% | 10.2 to 11.0 | 10.0 to 10.8 | 2.7 to 2.9; 6.0 to 6.7; 1.1 to 1.2 | 46% to 57% | 73 to 98 | 59% to 64% | 0% to 5% |
| The Marsh | as it is | 80 | 60% to 80% | 0% | 3.0 to 5.0 | 3.4 to 4.8 | 1.9 to 2.2; 0.4 to 1.2; 0.9 to 1.6 | 60% to 77% | 172 to 194 | 77% to 80% | 15% to 55% |
| The Marsh | two beats | 136 | 45% to 80% | 0% | 4.5 to 5.7 | 4.6 to 5.6 | 2.0 to 2.2; 1.4 to 1.7; 1.0 to 1.7 | 59% to 76% | 160 to 169 | 65% to 68% | 15% to 45% |
| The Marsh | three beats | 185 | 25% to 55% | 0% to 27% | 9.0 to 11.0 | 8.1 to 10.4 | 2.7 to 3.2; 4.3 to 5.6; 1.0 to 1.6 | 23% to 50% | 70 to 98 | 61% to 65% | 0% to 10% |
| The Waste | as it is | 96 | 60% to 90% | 0% | 4.4 to 6.5 | 4.7 to 5.7 | 2.0 to 2.6; 1.3 to 2.7; 0.8 to 1.1 | 48% to 54% | 126 to 171 | 64% to 85% | 0% to 15% |
| The Waste | two beats | 160 | 15% to 40% | 0% | 6.0 to 8.2 | 6.0 to 7.3 | 2.0 to 2.5; 3.0 to 3.5; 1.0 to 1.3 | 29% to 83% | 102 to 137 | 59% to 68% | 0% to 10% |
| The Waste | three beats | 235 | 0% to 25% | 40% to 50% | 9.0 to 9.8 | 9.0 to 10.0 | 2.5 to 2.8; 5.5 to 6.2; 1.0 | 30% to 37% | 70 to 132 | 57% to 63% | 0% |
| The Peak | as it is | 129 | 5% to 30% | 0% | 4.0 to 8.5 | 4.0 to 7.0 | 2.0 to 2.5; 1.0 to 4.0; 0.5 to 1.0 | 15% to 81% | 120 to 180 | 64% to 71% | 0% to 5% |
| The Peak | two beats | 223 | 0% to 5% | 0% | 7.0 to 9.0 | 6.0 to 8.0 | 2.0; 3.0 to 5.0; 1.0 | 29% to 69% | 110 to 130 | 62% to 66% | 0% |
| The Peak | three beats | 290 | 0% | | | | | | | 51% to 56% | 0% |

Tier one at Convergence 3, a four (the Honey Badger, the Baboon, the Skua and the Cassowary):

| Domain | The Rupture | In menace | Reached | By the guard | Its turn | Fights before it | Of them formations; patrols; the elite's | Hull then | The gate then, of 200 | The bar as the elite falls | Won |
|---|---|---|---|---|---|---|---|---|---|---|---|
| The Meadow | as it is | 126 | 95% | 0% | 4.4 | 5.9 | 2.9; 2.1; 0.9 | 60% | 182 | 97% | 20% |
| The Meadow | two beats | 201 | 75% | 27% | 6.7 | 8.3 | 3.7; 3.5; 1.2 | 47% | 155 | 79% | 30% |
| The Meadow | three beats | 275 | 55% | 64% | 8.6 | 10.4 | 3.7; 5.5; 1.1 | 47% | 127 | 58% | 25% |
| The Marsh | as it is | 109 | 100% | 0% | 2.0 | 3.1 | 2.0; 0.7; 0.5 | 66% | 192 | 121% | 15% |
| The Marsh | two beats | 178 | 85% | 0% | 5.5 | 6.9 | 3.2; 2.2; 1.5 | 28% | 163 | 93% | 20% |
| The Marsh | three beats | 234 | 40% | 25% | 7.4 | 8.6 | 4.0; 3.2; 1.4 | 24% | 138 | 73% | 5% |
| The Waste | as it is | 130 | 90% | 0% | 5.1 | 6.3 | 3.4; 2.2; 0.7 | 24% | 165 | 101% | 0% |
| The Waste | two beats | 211 | 10% | 0% | 5.0 | 7.5 | 3.5; 2.5; 1.5 | 40% | 159 | 77% | 0% |
| The Waste | three beats | 296 | 10% | 100% | 6.0 | 9.0 | 4.0; 4.0; 1.0 | 35% | 134 | 55% | 0% |
| The Peak | as it is | 168 | 0% | | | | | | | 62% | 0% |
| The Peak | two beats | 281 | 0% | | | | | | | 57% | 0% |
| The Peak | three beats | 357 | 0% | | | | | | | 46% | 0% |

Read.

- Two beats is the Rupture two or three turns later for this player (the Meadow 5.8 to 6.5
  where it was 3.3 to 4.8, the Marsh 4.5 to 5.7 from 3.0 to 5.0), about six fights where there
  were four, the added ones patrols, and the gate at 140 to 169 where it stood at 167 to 194.
- Three beats is its tenth or eleventh turn after ten fights, six of them patrols, the gate at
  70 to 98: the third beat costs this player a third of the gate, and it wins none.
- The elite's fall as a formation and a half leaves the bar at about three fifths for this
  player, which meets the elite on its second or third turn, before the field's part is done;
  a squad that takes the field first makes it the seal's last kill. As it is at Convergence 3
  the elite's fall is the Rupture itself (the bar at 97% to 121% as it falls).
- The stall guard takes a share again once the meter asks for the tide: 6% to 8% of the trios'
  Ruptures in the Meadow at two beats, 20% to 29% at three, and 27% and 64% of the four's.
- The wins are the floor's and measure the bot, not the shape: at Convergence 3 this player
  loses with four machines as it is (won 0% to 20%, the Peak a wipe on every seed), the wall
  it leaves and the machines it sends in alone.

## 11 November, the Rupture in beats as built, and a second flank patrol

Ryan's marks on the first shape, 11 November: "Try your lean first" (two beats), "Let's go 1.5
and I'll see how it feels" (the elite's chunk), "To me a clear field is its own reward, it's
breathing room to reposition or get loot" (so the stall guard goes and nothing takes its
place), and of the flank's variety, "Another would probably be smart, yeah. Different enough
that the same strategy doesn't strictly work on both would be ideal ... We can make flankers
out of pusher units if it makes sense ... just not sending pushers that are designed to
counter multiple mechs to the flanks (i.e., does area damage, buffs the whole field, that
kind of thing)." The decisions these inform: the meter as built that day (the bible's pacing
row), and a second flank patrol a domain, proposed and his to mark (the refit brief's section
11). Each a direction.

### The built rule against the what-if

The probe of the section above with no what-if, so the game's own rule (two beats, the
elite's fall a formation and a half, no stall guard), tier one at Convergence 0, the three
trios, 20 seeds a cell:

| Domain | The Rupture | In menace | Reached | By the guard | Its turn | Fights before it | Of them formations; patrols; the elite's | Hull then | The gate then, of 200 | The bar as the elite falls | Won |
|---|---|---|---|---|---|---|---|---|---|---|---|
| The Meadow | as built | 151 | 60% to 85% | 0% | 6.0 to 6.9 | 6.1 to 6.8 | 2.0 to 2.6; 2.8 to 3.0; 1.1 to 1.3 | 58% to 84% | 133 to 150 | 61% to 64% | 20% to 40% |
| The Marsh | as built | 136 | 45% to 80% | 0% | 4.5 to 5.7 | 4.6 to 5.6 | 2.0 to 2.2; 1.4 to 1.7; 1.0 to 1.7 | 59% to 76% | 160 to 169 | 65% to 68% | 15% to 45% |

Read. It is the what-if's two beats with the stall guard gone. The Marsh's rows are the
what-if's to the digit, the guard having broken no seal there; in the Meadow the 6% to 8% of
Ruptures the guard had given now wait on the meter, so the seal breaks on the sixth or
seventh turn (6.0 to 6.9 where the what-if read 5.8 to 6.5) after six or seven fights, the
gate at 133 to 150.

The campaign runner's 40 runs on the built rule (`docs/campaign_run.md`), against the 40 on
the meter as first built: battles won 6% against 5%, ended in a wipe 80% against 82%; the
Rupture reached in 18% of battles against 25%, the seal breaking a turn and a half later
where it broke (its sixth turn against its fourth or fifth); Fractures reached a battle 0.99
against 1.33, an elite spawned in 53% of battles against 65%, phases a battle 5.9 against
5.5. The plain player loses its battles before the meter matters, so the runs say the seal
comes later for it and little else.

### A lone machine against a picket of a domain's own units

Method: a scratch probe over `Skirmish` and `Policy`, a hand-made patrol built by
`Battlefield.pack_of` from a front and a back rank of units as content has them (nothing in
content), one stock tier-one machine against it, each of the nine dealt, the greedy rung, 20
seeds. Each cell: won, mean rounds, mean hull lost. The built duelist of each domain is its
first row.

| Domain | Patrol | Menace | Honey Badger | Baboon | Polar Bear | Prairie Dog | Stingray | Cassowary | Cottonmouth | Skua | Storm Petrel | Mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| The Meadow | the Whisker Cat (built) | 8 | 100% · 2.2 · 0% | 100% · 3.5 · 0% | 100% · 5.4 · 1% | 100% · 5.8 · 5% | 100% · 2.9 · 0% | 100% · 3.6 · 1% | 100% · 3.0 · 0% | 100% · 5.2 · 3% | 100% · 3.7 · 0% | 100% · 3.9 · 1% |
| The Meadow | two Goblins | 10 | 100% · 2.4 · 0% | 100% · 2.8 · 0% | 100% · 4.1 · 0% | 100% · 4.1 · 0% | 100% · 2.8 · 0% | 100% · 3.0 · 0% | 100% · 2.0 · 0% | 100% · 3.5 · 0% | 100% · 2.2 · 0% | 100% · 3.0 · 0% |
| The Meadow | three Goblins | 15 | 100% · 3.5 · 3% | 100% · 4.1 · 8% | 100% · 6.8 · 6% | 100% · 6.0 · 18% | 100% · 3.9 · 2% | 100% · 4.5 · 5% | 100% · 3.0 · 1% | 100% · 3.2 · 7% | 100% · 3.2 · 0% | 100% · 4.2 · 5% |
| The Meadow | a Gel | 5 | 100% · 3.4 · 0% | 100% · 3.6 · 0% | 100% · 5.2 · 0% | 100% · 5.3 · 0% | 100% · 3.8 · 0% | 100% · 4.2 · 0% | 100% · 3.0 · 0% | 100% · 4.5 · 0% | 100% · 4.1 · 0% | 100% · 4.1 · 0% |
| The Meadow | two Gels | 10 | 100% · 6.4 · 0% | 100% · 7.5 · 4% | 100% · 10.3 · 3% | 100% · 10.1 · 25% | 100% · 7.5 · 3% | 100% · 8.2 · 3% | 100% · 3.0 · 0% | 100% · 7.2 · 7% | 100% · 7.6 · 0% | 100% · 7.5 · 5% |
| The Waste | the Roc (built) | 10 | 100% · 2.2 · 2% | 100% · 3.5 · 7% | 100% · 5.1 · 11% | 100% · 5.8 · 11% | 100% · 3.1 · 1% | 100% · 3.6 · 4% | 100% · 3.2 · 2% | 100% · 5.0 · 29% | 100% · 3.6 · 9% | 100% · 3.9 · 8% |
| The Waste | two Needlers | 10 | 100% · 2.0 · 8% | 100% · 2.0 · 11% | 100% · 2.0 · 8% | 100% · 2.1 · 17% | 100% · 2.0 · 13% | 100% · 2.2 · 14% | 100% · 1.0 · 0% | 100% · 1.8 · 11% | 100% · 2.0 · 8% | 100% · 1.9 · 10% |
| The Waste | three Needlers | 15 | 100% · 3.0 · 25% | 100% · 3.0 · 32% | 100% · 3.1 · 24% | 100% · 3.1 · 48% | 100% · 3.0 · 38% | 100% · 3.2 · 42% | 100% · 1.0 · 0% | 95% · 1.7 · 21% | 100% · 3.0 · 25% | 99% · 2.7 · 28% |
| The Waste | two Cockatrices | 8 | 100% · 2.4 · 0% | 100% · 3.5 · 0% | 100% · 4.4 · 0% | 100% · 4.5 · 0% | 100% · 3.2 · 0% | 100% · 3.0 · 0% | 100% · 2.0 · 0% | 100% · 3.4 · 0% | 100% · 4.1 · 0% | 100% · 3.4 · 0% |
| The Waste | a Needler before a Cockatrice | 9 | 100% · 2.2 · 0% | 100% · 2.8 · 0% | 100% · 3.1 · 0% | 100% · 3.2 · 0% | 100% · 2.5 · 0% | 100% · 2.7 · 2% | 100% · 1.2 · 0% | 100% · 3.0 · 0% | 100% · 3.0 · 0% | 100% · 2.6 · 0% |
| The Waste | an Antlion | 8 | 100% · 1.4 · 0% | 100% · 2.2 · 0% | 100% · 3.0 · 0% | 100% · 3.3 · 0% | 100% · 1.9 · 0% | 100% · 2.1 · 0% | 100% · 2.0 · 0% | 100% · 3.0 · 0% | 100% · 3.0 · 0% | 100% · 2.4 · 0% |
| The Marsh | the Dullahan (built) | 7 | 100% · 2.3 · 0% | 100% · 3.9 · 0% | 100% · 7.2 · 0% | 100% · 9.1 · 8% | 100% · 2.9 · 0% | 100% · 3.8 · 0% | 100% · 2.0 · 0% | 100% · 7.8 · 5% | 100% · 3.4 · 0% | 100% · 4.7 · 1% |
| The Marsh | three Revenants | 12 | 100% · 3.4 · 1% | 100% · 3.9 · 4% | 100% · 7.3 · 10% | 100% · 5.5 · 23% | 100% · 4.1 · 5% | 100% · 4.5 · 9% | 100% · 3.0 · 0% | 95% · 3.5 · 17% | 100% · 3.0 · 0% | 99% · 4.2 · 8% |
| The Marsh | a Revenant before a Ghost | 8 | 100% · 2.5 · 0% | 100% · 3.8 · 0% | 95% · 7.0 · 6% | 85% · 7.7 · 26% | 100% · 3.6 · 0% | 100% · 4.3 · 0% | 100% · 2.2 · 0% | 100% · 6.3 · 4% | 100% · 3.6 · 0% | 98% · 4.6 · 4% |
| The Marsh | two Revenants before a Ghost | 12 | 100% · 4.4 · 1% | 100% · 5.5 · 11% | 85% · 11.2 · 39% | 55% · 8.2 · 70% | 100% · 5.2 · 6% | 95% · 5.8 · 17% | 100% · 2.2 · 0% | 80% · 9.2 · 58% | 100% · 4.7 · 0% | 91% · 6.3 · 22% |
| The Marsh | a Zombie Knight | 9 | 100% · 3.0 · 25% | 95% · 5.2 · 50% | 0% · 10.2 · 100% | 0% · 15.7 · 100% | 95% · 4.3 · 43% | 80% · 8.2 · 55% | 60% · 14.2 · 85% | 0% · 4.7 · 100% | 20% · 6.3 · 93% | 50% · 8.0 · 72% |
| The Peak | Cerberus (built) | 9 | 100% · 2.2 · 0% | 100% · 3.4 · 4% | 100% · 5.5 · 5% | 100% · 6.5 · 33% | 100% · 2.9 · 0% | 100% · 3.5 · 5% | 100% · 3.0 · 3% | 100% · 8.4 · 31% | 100% · 3.5 · 0% | 100% · 4.3 · 9% |
| The Peak | a Salamander | 7 | 100% · 1.4 · 0% | 100% · 2.2 · 0% | 100% · 3.1 · 0% | 100% · 3.1 · 0% | 100% · 1.9 · 0% | 100% · 2.1 · 0% | 100% · 2.0 · 0% | 100% · 3.0 · 0% | 100% · 3.0 · 0% | 100% · 2.4 · 0% |
| The Peak | two Salamanders | 14 | 100% · 2.5 · 4% | 100% · 5.2 · 26% | 0% · 15.8 · 100% | 35% · 7.9 · 94% | 100% · 4.5 · 18% | 100% · 4.2 · 19% | 100% · 2.0 · 10% | 75% · 6.2 · 76% | 90% · 6.7 · 25% | 78% · 6.1 · 41% |
| The Peak | a Bomb | 10 | 100% · 1.1 · 0% | 100% · 1.6 · 0% | 100% · 2.0 · 0% | 100% · 2.1 · 0% | 100% · 1.6 · 0% | 100% · 1.6 · 0% | 100% · 1.0 · 0% | 100% · 2.0 · 0% | 100% · 2.1 · 0% | 100% · 1.7 · 0% |
| The Peak | a Salamander before a Drake | 13 | 100% · 2.7 · 4% | 95% · 5.2 · 22% | 35% · 8.7 · 77% | 15% · 8.1 · 96% | 100% · 3.9 · 8% | 100% · 3.7 · 8% | 100% · 2.0 · 0% | 20% · 7.4 · 94% | 100% · 4.5 · 5% | 74% · 5.1 · 35% |

Read.

- Three Goblins, two Needlers and three Revenants each stand where a lone duelist stands:
  every machine wins every fight against the goblins and the needlers and all but one in a
  hundred and eighty against the revenants, in one to seven rounds, for a mean of 5%, 10% and
  8% of its hull against the duelists' 1% to 9%. The Prairie Dog pays the most to each (17%
  to 23%), as it does to the duelists.
- They turn the machines round. The Skua takes the goblins in 3.2 rounds and the Whisker Cat
  in 5.2, the Stingray the Cat in 2.9 and the goblins in 3.9; the Stingray pays the Roc 1% and
  two needlers 13%, the Skua 29% and 11%; the Stingray takes the Dullahan in 2.9 rounds for
  nothing and three revenants in 4.1 for 5%. A machine that sweeps is the picket's answer and
  a machine with one big die the duelist's.
- The needlers are a fight of two rounds that costs a tenth whoever comes, since no shield
  stops a needle: a toll more than a duel, unless the machine kills both before they loose
  (the Cottonmouth alone does).
- The Peak has no picket in what it holds. One Salamander is dead in two rounds for nothing
  and two are a wall for three machines of nine (the Polar Bear never wins, the Prairie Dog
  one fight in three), its bite's scorch and its hide's heat ending slow machines; a Drake
  behind one is the same wall, and a Bomb alone dies before it acts.
- Tried as a picket and not picked, each staying in its formations as it is: the Gel (two
  take seven to ten rounds for a twentieth of the hull), the Cockatrice and the Antlion alone
  (nothing lost), a Ghost behind a Revenant (the Prairie Dog loses three fights in twenty to
  the raise, and with two revenants half of them), the Zombie Knight (won one fight in two),
  three Needlers (28% of the hull).
- The Cottonmouth takes every patrol here but the Zombie Knight in one to three rounds for
  next to nothing: it is the flanker this bot would always send, which is the machine's
  question and none of the patrols'.

## 11 November, menace a pack's threat rating: the thresholds in pips and the salvage rate

Ryan, 11 November: "Maybe just 1-2-3-4 for now to keep math simple. But yes this direction
makes way more sense. We can tune difficulty to the value, within an acceptable band. It
gives us an absolute unbiased benchmark. I think the value can stay unchanged by tier, as
only salvage needs to scale, right." Built the same day: menace is a pack's threat rating, a
pip a hundred in the engine, read by the Rupture meter, salvage and Anathema (the bible's
tally row; `ContentDB.worth_of`).

The Rupture's Fractures in pips, as the game sets them (two beats, the tide's lightest patrol
left, four for each elite the tier calls), a battle set up in each domain:

| Tier | Convergence | The field's part | The Fractures, in pips |
|---|---|---|---|
| 1 | 0 | 10 | 2.9, 7.2, 13 |
| 1 | 3 | 14 | 3.8, 9.4, 17 |
| 2 | 4 | 13 | 2.9, 7.1, 12.9, 20 |
| 2 | 8 | 17 | 3.4, 8.6, 15.4, 24 |
| 3 | 8 | 16 or 17 | 2.8, 7.0, 12.6, 19.6, 28 at 17 |
| 3 | 12 | 17 | 2.8, 7.0, 12.6, 19.6, 28 |

Every domain reads the same but for tier three at Convergence 8, where the Marsh's and the
Peak's tide is a pip lighter than the Meadow's and the Waste's (a patrol of one rating in
the place of another's in the tears' order). By the sum of each foe's own numbers the same
first battle's Rupture was 123 in the Marsh and 191 on the Peak before its boss.

The salvage rate. The campaign runner on the same forty runs (`tools/campaign_run.gd -- --runs
40`, the floor player, its report `docs/campaign_run.md`), before and after:

| Measure | The sum, two salvage a point | The rating, eighteen a pip |
|---|---|---|
| Salvage banked a won battle | 369 (302 to 485) | 372 (344 to 397) |
| Menace killed a battle | 62 points | 6.1 pips |
| Battles reaching the Rupture | 18% of 180 | 18% of 179 |
| The turn the seal broke, where it did | 5.0 (2 to 12) | 5.6 (4 to 11) |
| Fractures reached a battle | 0.99 | 1.01 |
| Battles won | 6% | 4% |

Read. Eighteen a pip banks what a won battle banked, and the band is a third as wide, since
a domain's kills are worth what another's are. The floor player reaches the Rupture as
often; its wins, eleven and eight of some 180, are one direction's noise. Forty runs: a
direction.

## 11 November, more spawns than the Rupture needs: the tide's density and the wall strike

Ryan, 11 November: "I think we should try to lean for noticeably more spawns then the minimum
number required for our target completion speed. When I was playing I felt the need to chase
every pack down, since that felt possible. I think that's wrong. More pusher and flanker
packs, even if it means that each needs to do less to the wall, is better: It gives options
depending on player comp strengths, it forces choices, it looks more thematically intense and
interesting, it keeps offering something to do and analyze, and prevents field wipes."

What was read: a first battle whole (tier one, Convergence 0, three machines) under two
trial switches, the game's rule untouched. The tide's density (`Ramp.tide_trial`) multiplies
the packs the opening places and each peak sends, in whole packs, and leaves the Rupture's
size on the game's own tide, 13 pips. At tier one's start half again as many is one
formation and three flank patrols at the opening where two patrols stood, the rift sending
one composition then two at alternate peaks and the tears opening one then two; twice as many
is two formations and four patrols, two compositions a peak and two tears. The strike
(`Battlefield.strike_trial`) is what a pip of threat rating strikes the wall for, ten the
game's. The player is the runner's (a floor: every machine fights the pack nearest the wall
that it can reach, and it never declines a fight), 20 seeds a cell, each domain's bosses in
turn by the seed, three starting trios in the Meadow. Twenty seeds: a direction.

At the Rupture, the Meadow, a cell the range over the three trios, at ten a pip:

| The tide | Packs standing as a turn opens | Rupture reached | Its turn | Spawned by then, pips | Killed | Share killed | Standing then, pips | Of them at the wall | Hull then | Gate then, of 200 |
|---|---|---|---|---|---|---|---|---|---|---|
| The game's | 2.9 to 3.2 | 60 to 85% | 6.0 to 6.9 | 14 to 16 | 13 to 14 | 82 to 91% | 1 to 3 | 0.6 to 1.2 | 58 to 84% | 133 to 150 |
| Half again | 4.0 to 4.4 | 70 to 80% | 5.7 to 6.2 | 18 to 19 | 13 to 14 | 70 to 74% | 5 to 6 | 0.9 to 2.6 | 57 to 72% | 128 to 148 |
| Twice | 6.1 to 7.3 | 60 to 90% | 5.1 to 5.9 | 24 to 28 | 14 | 49 to 57% | 10 to 14 | 1.5 to 2.6 | 38 to 59% | 84 to 143 |

No turn opened on an empty field with the seal standing, in any cell, the game's own
included. A hunter forced under one fight a battle before the Rupture in every cell (0.0 to
0.7).

The battle's end. The defence rule never walks to the boss while a pack is nearer the wall,
so a denser field leaves it nothing but losses (won 0 to 5% at half again, where it won 20 to
40%). The read below gives it one habit more, a race: once the seal breaks the machine
nearest the boss walks for it and is ordered onto it when it can stand in reach, which
brings every machine into the fight, and the rest keep the defence rule. Won, and how the
rest ended, by trio:

| The trio | The tide | Won, at ten, seven, five and three a pip alike | At ten a pip: wiped, gate fell | At five | At three | Boss fought, its turn, at ten |
|---|---|---|---|---|---|---|
| Honey Badger, Baboon, Skua | the game's | 20% | 30%, 50% | 50%, 30% | 80%, 0% | 35%, 7.0 |
| | half again | 25% | 30%, 45% | 45%, 30% | 55%, 20% | 40%, 6.4 |
| | twice | 5% | 35%, 60% | 45%, 50% | 60%, 35% | 25%, 5.8 |
| Honey Badger, Stingray, Cassowary | the game's | 55% | 35%, 10% | 35%, 10% | 35%, 10% | 60%, 7.5 |
| | half again | 35% | 20%, 45% | 25%, 40% | 30%, 35% | 45%, 6.7 |
| | twice | 45% | 25%, 30% | 25%, 30% | 35%, 20% | 55%, 6.3 |
| Stingray, Storm Petrel, Cottonmouth | the game's | 65% | 30%, 5% | 35%, 0% | 35%, 0% | 80%, 7.3 |
| | half again | 45% | 50%, 5% | 55%, 0% | 55%, 0% | 75%, 6.5 |
| | twice | 15% | 15%, 70% | 50%, 35% | 60%, 25% | 25%, 6.2 |

Beside it, the same race: four machines at Convergence 3 in the Meadow (Honey Badger,
Baboon, Skua, Cassowary; the opening two formations and two patrols by the ramp's own count)
won 40% at the game's tide, 25% at half again and 5% at twice, the gate falling in 20%, 45%
and 95% at ten a pip and in 15%, 30% and 80% at five. The Marsh, the second trio: won 40%,
20% and 30%. On the Peak and in the Waste the first trio wins none at the game's own tide
and reaches the Rupture in 5% and 50% of battles; twice the tide ends it in two turns on the
Peak, whose patrols all hunt, so the opening's four catch the squad at once. Those two are
walls for a floor trio as they stand, which is their formations' and elites' own session.

Read.

- The chase is in the numbers. At the game's tide the floor player has killed 82 to 91% of
  every pip that had come by the time the seal breaks, and one to three pips stand: the
  meter asks for nine tenths of the field, so killing everything is both possible and asked.
- Half again as many packs leaves a third standing for the same meter: 13 to 14 of 18 to 19
  pips killed, five or six standing, one to three of them at the wall. The seal breaks half
  a turn sooner, since a pack is always in reach, and the boss is fought most of a turn
  sooner. The gate when the seal breaks is where it was at ten a pip.
- What more packs cost this player is hull, not the gate. The hull at the Rupture falls a
  little at half again (57 to 72% where it was 58 to 84%) and a lot at twice (38 to 59%),
  and the two stronger trios win twenty points less at half again. Twice as many is past
  what three machines carry: half the field stands, two trios of three win 5% and 15%, and
  at Convergence 3 it stacks on the ramp's own growth and the gate falls nineteen times in
  twenty.
- The strike moved no win. In all nine cells the wins are the same at ten, seven, five and
  three a pip; a lower strike turns a fallen gate into a wipe a turn or two later. That is
  this player: it never declines a fight, so it never spends the wall to save hull, which is
  the trade a lower strike is for. A player who leaves packs is the read that is missing,
  and Ryan's play is where it comes from.
- The floor player never clears the field at any density, the game's included, so his field
  wipes are a better player's: the bot takes six or seven turns over what he does in fewer.
- A multiplier is a trial's shape. On top of the ramp's own counts it compounds, so the form
  for the game is the ramp's table and the Rupture's share of it, not a factor over both.

## 11 November, the Kite's turns: a probe

Ryan, 11 November: "I want to revisit the Kite a bit. Something about it feels clunky to me." What
its turns hold, counted: a scratch script over `Skirmish` and `Policy` (the greedy rung; each
round played by `Policy.play_round`, the Kite's die read as the round opens and the log read for
its spends, its resets and its overheats), on main's content at `209112b`. Three reads: the
default team cut to three (the Honey Badger, the Clydesdale, the Kite) against every tier-one
patrol and formation of every domain, the same against tier two's, and the Kite with the Buzzard
and the Lammergeier against tier two's formations; 20 seeds a composition. A first pass at 30
seeds read the same on every counter the two share. A direction. The decision it informs: his
call of the same day to redesign the Kite from the ground up (`docs/briefs/kestrel_kite.md`).

| Read | The default three, tier one | The default three, tier two | With the Buzzard and the Lammergeier, tier two's formations |
|---|---|---|---|
| Fights, all won; mean rounds | 400; 2.7 | 480; 3.8 | 280; 4.0 |
| Its die opens on a dark entry, of its rounds | 18% | 17% | 20% |
| It spends nothing, of the rounds the fight goes on after | 6% | 13% | 13% |
| Spends a fight: the Driver, the rifle, the autoguns | 1.1, 0.9, 0.5 | 1.5, 0.9, 0.5 | 1.7, 1.0, 0.8 |
| Attacks that killed a fight | 1.8 | 1.8 | 2.2 |
| Resets a fight; the action it gives spent, held | 0.6; 0.5, 0.1 | 0.7; 0.5, 0.1 | 0.9; 0.7, 0.1 |
| Hot Streak at its peak | 1.3 | 1.3 | 1.8 |
| Hull lost a fight to its own heat, to the foes (of 12) | 1.3, 1.1 | 1.4, 1.7 | 1.8, 2.1 |
| Wrecked; by its own heat | 6%; 2% | 12%; 1% | 11%; 3% |

Read. The entry it spent is dark the round after, so from the second round its die opens dark
one time in three, about one round in five over fights this short; the bot buys most of them
back with the team's rerolls. The reset fires under once a fight, and a d3 holds at most one
entry dark from the round before, so what it brings back is that entry and the Driver itself.
Its own heat takes about as much of its hull as the foes do, and it is the machine that falls in
fights its team wins every time. One fight's log for the shape (`tools/balance.gd -- --trace
"kestrel team|meadow formation tier 2|greedy|1"`): over five rounds it burnt 11 of its 12 hull
itself and ended on 1, every blow the foes aimed at it stopped by its shield. Alone against a
tier-two duelist it wins in two rounds with no hull lost (the duelists' read of 10 November,
above). The Hot Streak figure is read as its turn ends, so a fight's last kill is not in it.

## 11 November, the three fast flyers rebuilt: each alone against the patrols, the old kit beside the new

The Needletail, the Kite and the Skua were rebuilt on 11 November on placeholder numbers (Ryan:
"Yes build them with placeholder numbers"; the bible's Kite and Kestrel rows). A first look at
where those numbers put each, the old kit beside the new: `tools/balance.gd -- --packs curve
--team <flyer>,badger,clydesdale,baboon --tiers 1,2 --sizes patrol --seeds 30`, read at the cut
of one (the flyer alone), on this branch at `4d70c47` and on main at `6cf3582` for the old kits.
Twenty patrols, tiers one and two: eight duels rated for one machine and twelve packs rated for
two, which a lone machine is over its rating against. The greedy rung's mean hull lost (percent
of its own) and mean rounds; a wall is the greedy winning under half. 30 seeds: a direction. No
decision reads it; it is the check that no placeholder is wildly off.

| Alone, the greedy rung | The Kite, old | new | The Skua, old | new | The Needletail, old | new |
|---|---|---|---|---|---|---|
| The eight duels: hull lost, rounds | 0%, 1.5 | 2%, 1.6 | 46%, 8.8 | 4%, 3.3 | 5%, 3.1 | 8%, 3.3 |
| The twelve packs rated for two: walls | 0 | 0 | 9 | 7 | 5 | 7 |
| All twenty: hull lost, rounds | 12%, 2.4 | 18%, 2.6 | 70%, 6.5 | 42%, 3.7 | 44%, 4.0 | 51%, 4.2 |

Read. The Kite stands where it stood on the duels made for one machine, a round and a half and
no hull to speak of, and pays more on the packs made for two (the antlion trio 8% to 33% of its
hull, the Cerberus pair 2% to 26%): the plain double it lost was worth more on a second and a
third foe than the opener is. The Skua moves most: its duels took five to fifteen rounds under
the Split-cycle Breech, a wall at tier two's lone Grave Dullahan, and take three to four now
with little hull lost; two tier-one pairs go from a wall to a win and the Roc pair from a
decision to one. It is slower than the Kite
and level with the Needletail on the duels, so no placeholder reads as runaway there; the long
fights it is built for are not in this read. The Needletail alone is a little worse off (five
walls to seven): alone its second action is the Designator, a mark worth little without armour
to strip or a squad to use it, where the old kit's free action was the Overcharge Coil it no
longer stocks. With the Honey Badger beside them (the cut of two) all three win every patrol,
old and new alike, the Pit pair the costliest (15% to 27% of the two machines' hull on the new
kits). The bot knows nothing of
holding the Kite's opener for a foe worth it or of keeping the Skua's hull clean, and a lone
machine against a pack rated for two is no fight the battle deals, so the walls are a ceiling
and no fault.

## 12 November, Sweep removed: the Whip Scorpion's release on every foe beside its Sweep, and the Skua without the Pod's Sweep

Sweep went on 12 November (the bible's Sweep row). Two reads of what took its place, the old
beside the new, `tools/balance.gd -- --packs curve --seeds 30`, this branch at `728e823` against
`a17339f` (the same tree with Sweep): a direction, the check on two placeholder calls. No
decision reads it.

The Whip Scorpion, `--team whip_scorpion,badger,clydesdale,baboon --tiers 2 --sizes
patrol,formation`: its release was a Sweep of the fuller rank, a shot of 2 for every heat; it is
1 on every foe at 8 heat and 1 more for each heat over (Ryan: "1 damage to each enemy, increased
by 1 for each heat over 8"; built as the rule reads, 7 at 14). The greedy rung's mean hull lost
and rounds, old then new:

| Tier two | Alone | With the Badger | The three | The four |
|---|---|---|---|---|
| Fourteen formations, rated 3 | 94%, 4.7 to 84%, 4.1; walls 8 to 7 | 39%, 7.1 to 36%, 6.3 | 13%, 5.1 to 13%, 5.0 | 5%, 4.4 to 5%, 4.2 |
| Six patrols rated 2 | 29%, 4.3 to 31%, 4.5 | 4%, 2.8 to 4%, 2.8 | 1%, 2.2 to 1%, 2.2 | 0%, 2.0 to 0%, 2.0 |
| Four duels rated 1 | 2%, 2.9 to 2%, 3.0 | no change | no change | no change |

Read. The new release sits where the Sweep sat: level in the squad of three the formations are
rated for, a little better alone against a formation (both ranks take it), a shade worse on the
small packs (nothing fires under 8 heat). The bot releases when the blow beats its best spend
and does not hold a die to bank the foes' blows on purpose, so the play he describes, ending
just under the maximum, is not in it.

The Skua, `--team skua,badger,clydesdale,baboon --tiers 1,2 --sizes patrol`, alone: its eight
duels are where they were (4% of its hull, 3.3 rounds, in the entry of 11 November above); on
the twelve packs rated for two the walls stay at 7, and over all twenty it loses 48% of its
hull in 4.2 rounds where it lost 42% in 3.7 with the Pod's Sweep: the Pod as three strikes of 1
at one foe is worth less against a pair than four shots along a rank were.

## 12 November, the Ammit's rework: a tier-three battle's chain, before against after

Ryan's rework of the Ammit, built 12 November (the bible's Ammit row, section 7): one Soulcutter
Talons entry of 1 ×4 with Breach where four talons of 3 stood, each of which Empowered a kill; a
Soul for every foe that falls in its fight, kept for the battle with no cap; a flare of 1
Empowered for every 5 Souls as a fight opens and on each of its own kills, where the Quintessence
Tap kept every stack for the battle; and the Soul Siphon, which consumes up to 5 Souls for a
stack each and holds every Empowered on the field for the round. (As measured, the kill's flare
came once for each foe a spend killed; since the same day it comes once an attack that kills,
however many fall to it, on Ryan's word. The two differ only when one attack of the Ammit's
kills two or more, and the read was not run again.) The to-do's test of the Tap
asked for "a battle's chain of fights, not one fight", since what the Ammit keeps carries from
one to the next; the single-fight matrix opens every fight with nothing kept and cannot see
either form.

What was read: a squad through one tier-three battle's fights back to back, dealt by the
battle's own builders at Convergence 8 (a formation, an elite's pack, a formation and two elites'
packs, 21 foes on average, then the lead domain's boss with its escort or its final, 4.6 heads),
the hull and whatever a machine keeps carried from fight to fight, the shields full and the heat
at nothing as each opens. The dealer is the quick campaign's encounter list, used as a dealer
alone: no run of the quick campaign is read. A scratch driver, not kept; the same seeds on main
at `87da46f` (before) and on the rework's commit (after). Two squads under the greedy rung and
one again under the planner, 30 seeds a row: a direction, never a band. The greedy reads the
kill flare and the Siphon by plain rules (`Policy.flare_gain`, `Policy.hold_score`), so the
Siphon's spends are a bot's.

A table a row, a fight a line: the rounds of the fights won and the squad's hull left after
them, what the Ammit holds as the fight opens where it still stands (before, the Empowered its
Tap kept; after, the flare and the Souls behind it), the Siphon's spends a fight, and how many
of the Ammit's spends killed and set off a flare (before, fed its talons).

The tier-three four (the Musk Ox, the Ammit, the Giant Petrel, the Lammergeier), the greedy. Battles won: 21 of 30 before and 19 of 30 after.

| Fight | Rounds, before | after | Hull left, before | after | Empowered as it opens, before (kept) | after (the flare) | Souls as it opens | Siphon spends | Its kills that flared |
|---|---|---|---|---|---|---|---|---|---|
| 1, formation | 4.7 | 3.5 | 96% | 97% | 0.0 | 0.0 | 0.0 | 0.07 | 0.9 |
| 2, elite | 5.0 | 5.1 | 85% | 89% | 1.3 | 0.7 | 6.5 | 0.43 | 0.7 |
| 3, formation | 4.5 | 4.3 | 82% | 84% | 1.9 | 1.1 | 7.9 | 0.37 | 1.9 |
| 4, elite | 4.6 | 4.5 | 70% | 74% | 3.4 | 2.2 | 12.5 | 0.27 | 0.9 |
| 5, elite | 4.4 | 5.4 | 63% | 66% | 4.4 | 2.6 | 14.6 | 0.33 | 1.0 |
| 6, the boss or the final | 5.4 | 6.4 | 54% | 58% | 5.2 | 2.8 | 15.9 | 0.28 | 1.4 |

The Ammit beside three tier ones (the Honey Badger, the Cassowary, the Storm Petrel), the greedy. Battles won: 21 of 30 before and 18 of 30 after.

| Fight | Rounds, before | after | Hull left, before | after | Empowered as it opens, before (kept) | after (the flare) | Souls as it opens | Siphon spends | Its kills that flared |
|---|---|---|---|---|---|---|---|---|---|
| 1, formation | 5.4 | 6.0 | 94% | 93% | 0.0 | 0.0 | 0.0 | 0.20 | 0.6 |
| 2, elite | 7.0 | 6.3 | 83% | 84% | 1.5 | 0.7 | 6.2 | 0.67 | 0.8 |
| 3, formation | 5.8 | 5.7 | 78% | 77% | 2.2 | 0.8 | 6.5 | 0.30 | 2.0 |
| 4, elite | 5.9 | 6.6 | 71% | 69% | 3.9 | 2.0 | 11.7 | 0.40 | 1.2 |
| 5, elite | 5.4 | 6.1 | 63% | 61% | 4.9 | 2.2 | 12.9 | 0.33 | 1.2 |
| 6, the boss or the final | 6.4 | 7.1 | 50% | 56% | 5.8 | 2.6 | 14.4 | 0.32 | 1.4 |

The tier-three four again, the planner (two rounds rolled out a decision), the same 30 seeds. Battles won: 25 of 30 before and 27 of 30 after.

| Fight | Rounds, before | after | Hull left, before | after | Empowered as it opens, before (kept) | after (the flare) | Souls as it opens | Siphon spends | Its kills that flared |
|---|---|---|---|---|---|---|---|---|---|
| 1, formation | 3.1 | 3.6 | 98% | 97% | 0.0 | 0.0 | 0.0 | 0.13 | 0.7 |
| 2, elite | 4.6 | 4.6 | 87% | 90% | 1.5 | 0.7 | 6.2 | 0.37 | 0.7 |
| 3, formation | 3.8 | 5.0 | 85% | 86% | 2.6 | 1.1 | 8.0 | 0.37 | 1.7 |
| 4, elite | 4.2 | 4.4 | 78% | 77% | 4.0 | 2.2 | 12.7 | 0.20 | 0.8 |
| 5, elite | 4.3 | 4.6 | 70% | 71% | 5.2 | 2.6 | 14.6 | 0.10 | 0.7 |
| 6, the boss or the final | 5.6 | 6.6 | 60% | 52% | 6.1 | 3.0 | 17.0 | 0.27 | 1.5 |

Read.

- The ramp is lower, and it has to be relit. Before, the Ammit opened the boss's fight holding
  5.2 to 6.1 stacks of Empowered kept from its talons' kills (1 to 10 by the seed), a point on
  every blow of that fight and of every fight after the one that earned it. After, it opens
  there on a flare of 2.6 to 3.0 from 14 to 17 Souls, which halves from the first round's end
  unless a kill of its own relights it; its kills flared about 1.4 times in that fight.
- The Souls come at the pace of the pack. Six after the first formation, 12 to 13 as the fourth
  fight opens and 14 to 17 at the boss's, by the seed 2 to 32, with the Siphon's spends taken
  out: the squad kills all 21 foes before the boss, so a count nothing spent stands at 21 to 26
  there, a flare of 4 or 5. Uncapped, that is the scale a battle of this length reaches; a
  longer battle on the map, or a summoner left alive, goes past it, and no player here tries.
- The boss's fight is a round longer in every row: 5.4 to 6.4 rounds and 6.4 to 7.1 under the
  greedy, 5.6 to 6.6 under the planner, where the kept stacks had been worth most. The five
  fights before it stand within a round of where they were and trade direction from row to row
  (the first fight 4.7 to 3.5 rounds for one squad, 5.4 to 6.0 for the other, 3.1 to 3.6 under
  the planner): noise at this size.
- The battle's result does not move at 30 seeds. Won, of 30: 21 to 19 and 21 to 18 under the
  greedy, 25 to 27 under the planner. Hull left by a battle won: 54 to 58% and 50 to 56%, and
  60 to 52%. One band, and no direction to name.
- The Siphon is spent about once in three fights by either rung, 1.4 to 2.2 times a battle,
  five Souls a time where it holds them, a quarter to a third of the time in the boss's fight.
  The greedy's rule is a plain one and the planner looks two rounds on, so this says the piece
  is spent, never that the spends were right, and nothing here says what a round given to it
  feels like.
- What this cannot read is his to play (the to-do's line): the kill flare at one stack, the
  Siphon's round, the talons at one roll in six, and the numbers, each a placeholder.

## 12 November, tier one on the reworked machines: the hull budget, and heat as a pace

Ryan, 12 November: "Pull in main. Many of the machine reworks are done, so they can be
included in the pass ... You can proceed with the steps as you see fit." Main at `8d936cf`:
every tier-one stock die is basics beside its locked pieces (the Baboon's rework, the
Photosphere Lance a support piece, the Flakshot Repeater, the Polar Bear's seal). Two reads,
the fight bot (greedy) throughout, each a direction.

**Where tier one stands against the hull budget.** Every tier-one patrol, formation, elite and
boss, twenty seeds, fought by two trios (Honey Badger, Baboon, Skua; Stingray, Cassowary, Honey
Badger) cut to the fight's threat rating, an elite and a boss by all three; a cell the range
over the two. The budget is his of 9 November (a pusher's fight a twentieth of the squad's
hull at its rating, a lone flanker's a thirtieth of the squad's, so a tenth of its own, a
hunter's a tenth, an elite's a quarter, the boss what is left, taken here as half). On
content's own heat.

| Domain | Kind | Fight | Rated | Machines | Won | Rounds | Hull lost, of the machines in it | The budget |
|---|---|---|---|---|---|---|---|---|
| The Meadow | patrol | lone_whisker_cat | 1 | 1 | 100% | 2.2 to 5.2 | 0 to 1% | 10% |
| The Meadow | patrol | wolf_pack | 2 | 2 | 100% | 3.8 to 4.2 | 0% | 10% |
| The Meadow | formation | goblin_horde | 3 | 3 | 100% | 4.5 to 4.7 | 1% | 5% |
| The Meadow | formation | treant_grove | 3 | 3 | 100% | 8.1 to 10.8 | 3 to 6% | 5% |
| The Meadow | formation | gel_wall | 3 | 3 | 100% | 6.5 to 6.7 | 2 to 5% | 5% |
| The Meadow | elite | shamans_warband | 4 | 3 | 100% | 4.1 to 4.3 | 0% | 25% |
| The Meadow | elite | the_nob | 4 | 3 | 100% | 5.8 to 6.5 | 12 to 24% | 25% |
| The Meadow | boss | floraison | 4 | 3 | 100% | 9.9 to 14.3 | 31 to 37% | 50% |
| The Meadow | boss | king_gel | 4 | 3 | 100% | 9.7 to 11.6 | 21 to 36% | 50% |
| The Meadow | boss | mantis_ant | 4 | 3 | 85 to 100% | 8.7 to 13.2 | 16 to 50% | 50% |
| The Waste | patrol | lone_roc | 1 | 1 | 100% | 2.2 to 5.5 | 2 to 11% | 10% |
| The Waste | patrol | antlion_trio | 2 | 2 | 100% | 3.6 to 5.0 | 6 to 13% | 10% |
| The Waste | formation | needler_thicket | 3 | 3 | 100% | 3.2 to 3.9 | 2 to 5% | 5% |
| The Waste | formation | sandworm_ambush | 3 | 3 | 100% | 7.8 to 10.9 | 24 to 31% | 5% |
| The Waste | elite | old_mans_rising | 4 | 3 | 100% | 7.8 to 13.0 | 16 to 35% | 25% |
| The Waste | elite | pilgrims_wake | 4 | 3 | 100% | 7.0 to 7.8 | 10 to 20% | 25% |
| The Waste | elite | rust_monsters_scavenge | 4 | 3 | 100% | 5.2 to 6.5 | 1 to 4% | 25% |
| The Waste | elite | gilgamesh_wanders | 4 | 3 | 100% | 8.3 to 11.3 | 6 to 10% | 25% |
| The Waste | boss | ruby_colossus | 4 | 3 | 0 to 70% | 13.2 to 15.3 | 74 to 100% | 50% |
| The Waste | boss | fallen_weapon | 4 | 3 | 35 to 80% | 10.9 to 13.6 | 47 to 87% | 50% |
| The Waste | boss | emperor_scorpion | 4 | 3 | 20 to 100% | 11.2 to 15.3 | 51 to 96% | 50% |
| The Marsh | patrol | lone_dullahan | 1 | 1 | 100% | 2.3 to 7.3 | 0% | 10% |
| The Marsh | formation | grave_throng | 3 | 3 | 100% | 4.1 to 5.2 | 1 to 2% | 5% |
| The Marsh | formation | barrow_mound | 3 | 3 | 100% | 7.2 to 12.2 | 3 to 4% | 5% |
| The Marsh | formation | knights_vigil | 3 | 3 | 100% | 5.8 to 7.0 | 26 to 35% | 5% |
| The Marsh | elite | fell_riders_hunt | 4 | 3 | 100% | 4.2 to 4.8 | 4% | 25% |
| The Marsh | elite | the_reaper | 4 | 3 | 100% | 3.0 to 3.2 | 0 to 1% | 25% |
| The Marsh | elite | the_wild_hunt | 4 | 3 | 95 to 100% | 7.9 to 8.8 | 32 to 50% | 25% |
| The Marsh | boss | matador | 4 | 3 | 100% | 9.2 to 13.2 | 24 to 39% | 50% |
| The Marsh | boss | phantom_train | 4 | 3 | 5 to 100% | 14.5 to 23.8 | 38 to 99% | 50% |
| The Marsh | boss | vampire_lord | 4 | 3 | 100% | 8.6 to 10.2 | 9 to 17% | 50% |
| The Marsh | boss | marsh_serpent | 4 | 3 | 100% | 8.0 to 9.8 | 13 to 39% | 50% |
| The Peak | patrol | lone_cerberus | 1 | 1 | 100% | 2.2 to 6.0 | 0 to 12% | 10% |
| The Peak | formation | ember_pyre | 3 | 3 | 100% | 4.7 to 5.8 | 20 to 29% | 5% |
| The Peak | formation | magma_vent | 3 | 3 | 100% | 8.8 to 10.8 | 23 to 46% | 5% |
| The Peak | elite | cinder_tortoises_brood | 4 | 3 | 100% | 9.4 to 13.9 | 13 to 30% | 25% |
| The Peak | elite | thunder_apes_rampage | 4 | 3 | 95 to 100% | 6.5 to 9.2 | 22 to 35% | 25% |
| The Peak | boss | gargantuan_king | 4 | 3 | 100% | 8.4 to 10.3 | 21 to 27% | 50% |
| The Peak | boss | fiend_of_fire | 4 | 3 | 100% | 8.7 to 11.8 | 42 to 44% | 50% |
| The Peak | boss | obsidian_tyrant | 4 | 3 | 80 to 100% | 11.3 to 23.2 | 44 to 74% | 50% |

Read.

- The formations with no breach sit at or under the budget: the goblin horde and the grave
  throng at 1 to 2%, the rest at 2 to 6% against 5%. His read of 10 November stands for
  them ("Enemy fodder damage might just be too low").
- The four that breach or burn are five to nine times over it: the sandworm ambush 24 to 31%,
  the knights' vigil 26 to 35%, the ember pyre 20 to 29%, the magma vent 23 to 46%. Both of
  the Peak's formations are among them, so the Peak has no formation a first battle can
  afford.
- The elites spread from nothing to twice the budget: four cost under 5% (the shaman's
  warband, the rust monster, the Reaper, the Fell Rider), five sit inside it, the Wild Hunt
  is 32 to 50%.
- The bosses: the Meadow's three, the Matador, the Marsh Serpent and the Peak's first two are
  fights three machines win for a fifth to a half of their hull; the Vampire Lord is soft
  (9 to 17%); the Waste's three and the Phantom Train are walls for one trio or both.
- A lone flanker costs its machine a tenth or less. The Stingray alone takes five to seven
  rounds over what the Honey Badger takes in two, since its Lance deals no damage now.

**Heat as a pace.** His reads: "Heat generation is too low, but I think we knew that" (10
November) and, of the model, "run hot, and you're forced to wait and think about your
decisions while you cool off" (9 November). The bible's test: a hot build overheats by about
its third round of firing, a formation fight forces a cooling turn or two, a short fight
none. The read: every tier-one fight at its rating's cut, ten seeds a fight, under a price
on every weapon, a cooling offset, a gauge offset and the hull an overheat burns a point. A
heat moment is a damaging die held because it would cross the gauge, or an overheat; the
table counts them a machine a formation fight, for two trios (Stingray, Cassowary, Honey
Badger; Skua, Baboon, Honey Badger).

| Weapons | Cooling | Gauge | An overheat burns | Formation: rounds | Hull lost | Heat moments a machine | Boss won |
|---|---|---|---|---|---|---|---|
| as they are | as it is | as it is | 1 | 6.5 to 7.4 | 11 to 14% | 0.1 to 0.2 | 76 to 98% |
| +1 | as it is | as it is | 1 | 6.4 to 7.7 | 12 to 16% | 0.4 to 0.5 | 74 to 98% |
| +2 | as it is | as it is | 1 | 6.6 to 8.8 | 15 to 20% | 0.9 to 1.7 | 68 to 91% |
| +3 | as it is | as it is | 1 | 7.2 to 11.2 | 21 to 30% | 1.8 to 3.6 | 57 to 83% |
| +2 | as it is | as it is | 2 | 7.1 to 12.4 | 18 to 27% | 1.0 to 3.0 | 64 to 83% |
| +2 | as it is | as it is | 3 | 7.6 to 14.4 | 19 to 26% | 1.1 to 3.6 | 60 to 82% |
| +2, the cautious player | as it is | as it is | 1 | 7.1 to 9.2 | 15 to 22% | 0.6 to 1.2 | 67 to 86% |
| +2 | +1 | as it is | 1 | 6.4 | 12% | 0.4 | 97% |
| +2 | +1 | 4 smaller | 1 | 6.6 to 7.8 | 14 to 20% | 0.7 to 1.0 | 72 to 95% |
| +2 | +1 | 4 smaller | 2 | 6.8 to 8.3 | 17 to 23% | 0.7 to 0.9 | 71 to 92% |
| +3 | +1 | as it is | 1 | 6.6 to 8.2 | 15 to 20% | 0.8 to 1.4 | 68 to 95% |
| +4 | +2 | as it is | 1 | 6.6 to 8.3 | 14 to 20% | 0.7 to 1.4 | 68 to 94% |

(The row at +2 with one more cooling is the first trio's alone.)

Read.

- At today's prices nothing binds: a tenth of a heat moment a machine a formation fight.
- Prices alone starve the long fight. Cooling stays one, so a gun of three or four heat
  fires once in three or four rounds at the gauge: the second trio's formation fights run
  eleven rounds at three hotter and some never end.
- A harsher overheat makes the bot hold more and the fights longer, with no fewer lost. The
  cautious player, who holds a hot die under three quarters of the gauge, does no better
  than the reckless one. So for this bot the overheat is a hull tax and a hold is a mistake,
  the read of 30 October again; what a hold is worth to a player is his play's.
- Prices with one more cooling keep the fights their length and bring the limit once a
  machine in a formation fight. Three shapes land alike, as the ratios say they should (the
  sustained rate is the cooling over a shot's heat, the burst the gauge over the heat a shot
  leaves): two hotter with a gauge four smaller, three hotter on the gauge as it is, four
  hotter with two more cooling.

**The shape chosen, and on trial rather than in content**: every weapon three hotter, every
chassis that cools cooling one more, the gauges as they are, an overheat one hull a point
as it is. Debuff devices keep their own heat, since they are equipment; the Whip Scorpion
still cools nothing; the Cottonmouth's drum shot moves with the guns, to 6. The basics would
be 4 (the Twin Autoguns, the Rivet Gun, the Ankle Mortar) and 5 (the Laser Carbine) against a
cooling of 2 and a gauge of 12 or 14: five cold shots or three warm ones from cold before
the limit, then one shot in two. Chosen over the smaller gauge because the gauges carry
other numbers (the Stingray's stacks by 5 heat, the Polar Bear's seal at 3 a turn, the
Buzzard's regen by 4). It is a dial (a debug build's SETTINGS → TRIALS → HEAT) and no
content: main moved under the read to `c717e69`, where another session had rebuilt the fast
flyers and set the Whip Scorpion's release against its gauge the same day, on today's
prices, and a price on every weapon moves every machine that reads heat. The four trios
under the shape, a formation fight, read at `8d936cf` with the prices laid over the content:

| The trio | Rounds, as it is | Rounds, the shape | Hull lost, as it is | Hull lost, the shape | Heat moments a machine, the shape | Boss won, as it is | Boss won, the shape |
|---|---|---|---|---|---|---|---|
| Stingray, Cassowary, Honey Badger | 6.5 | 6.6 | 11% | 15% | 0.8 | 98% | 95% |
| Skua, Baboon, Honey Badger | 7.4 | 8.0 | 14% | 20% | 1.3 | 76% | 68% |
| Cottonmouth, Storm Petrel, Polar Bear | 8.1 | 7.2 | 15% | 14% | 0.8 | 55% | 54% |
| Prairie Dog, Cassowary, Stingray | 9.2 | 10.0 | 18% | 22% | 1.1 | 65% | 61% |

Read again at `c717e69` on six seeds, with the Skua as rebuilt: the same picture (the first
three trios 0.8, 1.7 and 0.8 heat moments a machine, their formation fights 6.7, 7.9 and
7.2 rounds).

A lone duel brings the limit under once in two fights. The greedy bot pays the prices in
hull, four to six points a formation fight, because it overheats where a player would hold;
the Storm Petrel's trio pays none, since its guns burn shield for heat and zap for what
they burnt, three more a shot under the shape. The foes' numbers wait on the prices: tuned
first, they are tuned twice.

The campaign runner beside it (`tools/campaign_run.gd -- --runs 40`, the floor player, at
`8d936cf`), to part the shape from the reworks main brought the same day:

| The content | Battles reaching the Rupture | Battles won | With three machines: won | Wiped |
|---|---|---|---|---|
| Before the reworks, 11 November | 18% of 179 | 4% | 13% | 47% |
| The reworked machines, as content has them | 14% of 178 | 2% | 9% | 56% |
| The reworked machines under the shape | 10% of 174 | 1% | 6% | 66% |

The reworks and the prices each cost the floor player about four points of battles reaching
the Rupture. It overheats rather than holds, so the prices are hull to it; the campaign was
a wall for it before either. Forty runs: a direction.

Method: the scratch probes of this session (a tier-one fight probe at each rating's cut and
a heat probe over the same fights, prices, cooling and gauge laid over the loaded content),
the engine's own `Policy` counts for holds and overheats (`forced_holds`, `overheats`,
`overheat_hull`). The grid priced the debuff devices with the weapons; the shape and its
four-trio read do not.

## 12 November, the four over-budget formations cut toward the budget, and the second battle read whole

Ryan, 12 November, on whether the four formations that breach or burn may come into the
band with the breach rule left alone: "Yes go ahead with 2." And of the tuning's anchor:
"Important to get the convergence 2 fight tuned around real tier 1s with real tier 1 numbers
for damage, defense and heat, and then move on to the scaling for everything from there."
Main at `366b10e`; main's `ea2f143` since (the Ammit's flare, the dead-code pass) moves none
of these machines or foes. The fight bot (greedy) throughout, each a direction.

**The four formations.** Each fought by trios of built machines that are tier one under any
4-4-2 (Honey Badger, Skua, Cassowary; Honey Badger, Storm Petrel, Prairie Dog; Honey Badger,
Storm Petrel, Cassowary) and one with the Polar Bear (Polar Bear, Skua, Cottonmouth), the
foes' numbers laid over the content, ten seeds a variant and twenty for the first and last
rows; a cell the range over the trios. Hull lost is of the trio's hull, the budget 5%.

| The formation | The numbers | Rounds | Hull lost |
|---|---|---|---|
| The sandworm ambush | as it was: the sandworm 36 hit points, a maw of 8, plate 1 | 7.9 to 13.6 | 29 to 43% |
| | the maw 4, 28 hit points | 6.1 to 9.9 | 16 to 21% |
| | the maw 3, 24 hit points | 5.7 to 8.3 | 11 to 15% |
| | the maw 3, 22 hit points, no plate | 4.2 to 5.1 | 8 to 10% |
| | the maw 3, 14 hit points, the plate kept (landed) | 4.2 to 5.4 | 9 to 10% |
| The knights' vigil | as it was: the zombie knight 8 hit points, a cleaver of 6, plate 1 | 5.3 to 8.5 | 25 to 47% |
| | the cleaver 3 | 5.1 to 8.0 | 12 to 22% |
| | the cleaver 3, 6 hit points, no plate | 3.1 to 3.8 | 4 to 7% |
| | the cleaver 3, 4 hit points, the plate kept (landed) | 3.0 to 4.0 | 5 to 10% |
| The ember pyre | as it was: the bomb 8, the salamander and the drake 5 | 3.5 to 5.7 | 8 to 24% |
| | the bomb 4, the salamander and the drake 4 (landed) | 3.6 to 4.8 | 6 to 13% |
| The magma vent | as it was: the magma elemental 40 hit points, a fist of 8, plate 1 | 7.7 to 13.8 | 27 to 57% |
| | the fist 3, 26 hit points, with the Peak's blows as landed | 5.6 to 8.9 | 10 to 16% |
| | the fist 3, 26 hit points, no plate | 4.0 to 5.2 | 6 to 12% |
| | the fist 4, 14 hit points, the plate kept (landed) | 4.3 to 5.9 | 8 to 15% |

Read.

- A breach is hull whatever the shield holds, so a breaching blow has to be small to fit a
  budget of a twentieth: 3 or 4 where it was 6 or 8. At those numbers the four cost a trio a
  twentieth to a seventh of its hull, about twice what a formation with no breach costs. A
  blow every round cannot go lower without being a 1 or a 2; what would is a telegraph, the
  blow on a count the squad can answer, which is a kit and not a number.
- The plate was the multiplier. A basic gun of 2 does 1 through plate of 1, so 36 hit points
  under plate were 72 to a cold gun. Taking the plate off and cutting the hit points land
  alike in cost and rounds, so the plate stays as the knight's and the giants' own and the
  hit points came down: the warm gun and the big blow still matter against them.
- The Polar Bear's trio pays the most to each (10 to 15%): it holds no Barrier and the least
  damage.
- Beside them, unlanded: the Treant and the Barrow Giant, the two massive foes whose blow a shield meets, at 16 hit points run
  5.0 to 6.2 rounds where they run 6.6 to 10.8 at 32, for the same 2 to 3%; and the fodder
  a blow harder brings the grave throng to 3 to 5% and the gel wall to 4 to 13%, the goblin
  horde staying free until two harder.

**The second battle, whole.** Four tier-one machines against a tier-one rift at Convergence 1
(the second battle of a run), twenty seeds a domain, three squads (Honey Badger, Skua, Cassowary, Storm Petrel;
Honey Badger, Storm Petrel, Prairie Dog, Cottonmouth; Honey Badger, Skua, Cottonmouth,
Cassowary), the runner's player with the race for the boss; a cell the range over the squads.
Read before and after the four formations' numbers; only the Peak moved.

| Domain | Won | Wiped | Rupture reached | Its turn | Hull then |
|---|---|---|---|---|---|
| The Meadow | 70 to 75% | 5 to 10% | 75 to 80% | 5.7 to 6.0 | 89 to 94% |
| The Marsh | 65 to 75% | 5 to 10% | 75 to 80% | 5.9 to 6.2 | 80 to 86% |
| The Waste | 10 to 15% | 50 to 75% | 35 to 65% | 6.6 to 7.3 | 52 to 59% |
| The Peak, before | 5 to 20% | 55 to 65% | 30 to 40% | 7.9 to 8.2 | 36 to 50% |
| The Peak, after | 15 to 25% | 50 to 55% | 30 to 40% | 7.5 to 8.0 | 54 to 58% |

Read.

- The Meadow and the Marsh are soft by the budget: the squad breaks the seal with nine
  tenths of its hull where two formations, three duels and an elite are budgeted for about
  half of it.
- The Waste and the Peak are walls, and the four formations were not why: the Waste's rows
  did not move at all, since its rift opens on the needler thicket and the ambush is its
  third wave, after the seal. What wipes the squad there is the rest: lone machines the bot
  sends at packs, the elites and the bosses.
- So the anchor is two different problems by domain, and neither is a formation's number
  alone.

## 12 November, the anchor: the second battle's ledger, every fight at its rating, and tier one's own lines

Ryan, 12 November: "Remember that all the chassis numbers are on the table, including hull
and shield. Important to get the convergence 2 fight tuned around real tier 1s with real tier
1 numbers for damage, defense and heat, and then move on to the scaling for everything from
there." Main at `bf5158e`. The six machines that are built and tier one under any reading of
4-4-2 (the Honey Badger, the Skua, the Storm Petrel, the Prairie Dog, the Cassowary, the
Cottonmouth), a tier-one rift at Convergence 1, the fight bot (greedy) throughout. Each a
direction.

**The ledger: where the runner's player spends its hull.** The second battle whole, twenty
seeds a domain, three squads of four (as the section above), the race for the boss; every
fight written down by what it held and how many machines stood in it. A cell is the range
over the three squads; hull is a share of the squad's full hull.

| Domain | The fight | A battle | Machines in it | Rounds | Hull a fight | Lost | Wrecks a fight |
|---|---|---|---|---|---|---|---|
| The Meadow | a lone flanker | 3.0 | 1.3 to 1.6 | 2.7 to 2.9 | 0 to 0.1% | 0% | 0 |
| | a formation | 2.2 | 2.8 to 3.0 | 3.4 to 4.0 | 3 to 5% | 11 to 16% | 0.1 to 0.2 |
| | the elite | 1.2 to 1.4 | 1.7 to 1.9 | 5.9 to 9.3 | 12% | 33 to 41% | 0.4 to 0.5 |
| | the boss | 0.7 | 3.9 | 5.8 to 7.7 | 4 to 9% | 0% | 0 |
| The Marsh | a lone flanker | 3.0 | 1.4 to 1.7 | 2.1 to 2.8 | 0 to 0.1% | 0% | 0 |
| | a formation | 2.3 | 2.8 to 3.0 | 3.6 to 4.1 | 5 to 7% | 15 to 19% | 0.2 |
| | the elite | 1.2 to 1.4 | 2.0 to 2.2 | 5.4 to 7.0 | 13% | 33 to 43% | 0.4 to 0.5 |
| | the boss | 0.7 | 3.8 | 6.7 to 8.1 | 10 to 13% | 0% | 0.1 to 0.2 |
| The Waste | a lone flanker | 3.1 to 3.5 | 1.1 to 1.4 | 2.8 to 3.1 | 0.4 to 1.5% | 0% | 0 |
| | a formation | 2.2 to 2.4 | 2.3 to 2.6 | 3.3 to 3.9 | 7 to 10% | 16 to 24% | 0.2 |
| | the elite | 1.9 to 2.2 | 1.3 to 1.4 | 5.3 to 9.9 | 21 to 23% | 73 to 82% | 0.8 to 1.1 |
| | the boss | 0.3 to 0.5 | 2.8 to 3.3 | 6.6 to 10.6 | 29 to 46% | 50 to 80% | 1.3 to 2.2 |
| The Peak | a lone flanker | 2.8 to 3.0 | 1.2 to 1.4 | 2.6 to 2.9 | 0.2 to 0.7% | 0% | 0 |
| | a formation | 2.7 to 2.9 | 2.2 to 2.3 | 3.2 to 4.0 | 14 to 17% | 48% | 0.6 |
| | the elite | 1.2 to 1.5 | 1.3 to 1.4 | 7.7 to 9.9 | 22% | 71 to 83% | 0.9 |
| | the boss | 0.3 | 2.8 | 8.0 to 10.4 | 18 to 33% | 17 to 50% | 0.6 to 1.7 |

Read.

- The runner's player meets the elite, a fight rated for four, with one or two machines, and
  loses a third of those fights in the Meadow and the Marsh and four in five in the Waste and
  the Peak, a machine wrecked in most. A battle of its that ends at the gate (15 to 35% of
  them) is a lost elite fight standing at the wall. So its battle measures its own orders
  before it measures a number, and the costs have to be read with each fight at its rating.
- In the Peak its formation fights burn 8 to 10 points of hull in overheats each: the
  salamander, the bomb and the drake scorch, and the bot fires through it.

**Every fight at its rating.** Each composition and each boss fought by squads of the six, as
many machines as the fight is rated: a lone flanker by each of the six, a hunter's pack by
six pairs, a formation by six trios, an elite and a boss by five fours, five seeds a squad
(four for an elite and a boss). Hull lost is a share of a four's hull, 96 points, which is the
budget's measure: a lone flanker a thirtieth or less, a hunter a tenth, a pusher's formation
a twentieth, an elite a quarter. Three columns: content at `bf5158e`; that with heat's shape
(every weapon three hotter, every chassis that cools cooling one more); and that with tier
one's shields at three quarters and its regen one less, never under one, which is what
landed.

| The fight | Rated | Content at `bf5158e` | With heat's shape | With tier one's shields too (landed) | Rounds, landed |
|---|---|---|---|---|---|
| The Meadow: the lone whisker cat | 1 | 0.2% | 0.2% | 1.6% | 3.3 |
| the wolf pack | 2 | 0.0% | 0.0% | 0.1% | 3.0 |
| the goblin horde | 3 | 0.3% | 0.6% | 2.0% | 3.8 |
| the treant grove | 3 | 1.8% | 3.6% | 8.3% | 9.0 |
| the gel wall | 3 | 2.1% | 5.0% | 11.2% | 5.7 |
| The Waste: the lone roc | 1 | 0.7% | 0.5% | 0.8% | 3.3 |
| the antlion trio | 2 | 3.2% | 3.5% | 7.2% | 3.5 |
| the needler thicket | 3 | | 5.5% | 5.5% | 3.1 |
| the sandworm ambush | 3 | | 8.6% | 8.6% | 4.2 |
| The Marsh: the lone dullahan | 1 | | 0.0% | 1.1% | 3.7 |
| the grave throng | 3 | | 0.7% | 3.9% | 4.5 |
| the barrow mound | 3 | | 2.9% | 6.9% | 8.6 |
| the knights' vigil | 3 | | 2.7% | 2.7% | 3.1 |
| The Peak: the lone cerberus | 1 | | 1.1% | 4.3% | 3.7 |
| the ember pyre | 3 | | 8.1% | 12.5% | 4.2 |
| the magma vent | 3 | | 8.4% | 8.4% | 5.1 |
| The elites, the eleven: least to most | 4 | | 0.0% to 8.9% | 0.0% to 13.1% | 2.2 to 8.0 |
| their mean | 4 | | 3.7% | 5.5% | 4.5 |
| The bosses, the thirteen: least to most | 4 | | 2.2% to 40% | 5.0% to 56% | 5.2 to 25 |
| their mean | 4 | | 16.6% | 23.1% | 8.7 |

(The first column was stopped after the Waste's hunter, on every squad of the six: enough to
see it.) The means by kind, with two more what-ifs beside the landed lines: the rank and
file's blows one harder on the old shields, and both.

| Kind | Budget | Heat's shape alone | Shields down (landed) | Blows one harder | Both |
|---|---|---|---|---|---|
| A lone flanker | 3.3% or less | 0.5% | 2.0% | 0.9% | 2.5% |
| A hunter's pack | 10% | 1.7% | 3.6% | 3.3% | 5.5% |
| A formation | 5% | 4.6% | 7.0% | 8.3% | 12.5% |

Each machine alone against the four lone flankers, twelve seeds, the landed lines:

| The machine | Rounds | Hull lost (points) | Against the antlion trio alone |
|---|---|---|---|
| The Honey Badger | 2.2 to 2.3 | 0.1 to 1.0 | wins, 12 points |
| The Skua | 2.0 to 2.7 | 0 to 1.0 | wrecked |
| The Storm Petrel | 1.4 to 2.3 | 0 | wrecked |
| The Cottonmouth | 2.0 to 3.2 | 0 to 3.2 | wrecked five times in six |
| The Cassowary | 3.8 to 4.6 | 0.8 to 3.3 | wrecked |
| The Prairie Dog | 5.8 to 12.8 | 3.4 to 14.6, losing a third of its fights with the cerberus | wrecked |

Read.

- At its rating nothing in tier one cost a real squad its budget but the formations once
  heat was real: a lone flanker a seventh of it, a hunter a sixth, an elite a seventh.
  Ryan's read of 10 November in numbers ("Enemy fodder damage might just be too low"), and
  the reason the runner's player loses is its orders.
- A fight's cost is what the opening rounds deal past the gauges. On the old lines a four
  soaked about 76 points over a five-round fight (41 of gauge, 9 a round of regen) beside 96
  of hull, so a cost was the thin edge of a large number: nothing, or a lot. On the landed
  lines it soaks about 52 (31 and 5 a round).
- The shields move the duels most, which is where the gap was widest; the rank and file's
  blows move the formations most, which were on budget. So the shields came down and the
  blows stayed.
- The landed lines, tier one's ten: the Honey Badger 6 and 1 (8 and 1), the Storm Petrel 12
  and 1 (16 and 1), the Skua and the Stingray 9 and 1 (12 and 2), the Prairie Dog and the
  Baboon 8 and 1 (10 and 2), the Cassowary, the Cottonmouth, the Polar Bear and the Puffin 6
  and 2 (8 and 3). Hull is untouched. The reason beyond the reads is the levels: a level
  lifts hull, shield, regen and cooling, so level one is the low end of each scale, and
  every tier stood on one line.
- Heat's shape is content with them, the dial's of the section above: 43 weapons three
  hotter, 23 chassis cooling one more, the Cottonmouth's drum shot 6. The Storm Petrel burns
  4 or 5 of its 12 shield a shot and zaps for it, by its rule; as a duelist it reads level
  with the Honey Badger.
- A duel's cost is the machine's kill speed: the three that kill in two rounds pay nothing,
  the Prairie Dog pays a seventh of its hull or the fight. The lone flankers die before they
  act twice.
- Left for the foes' pass below: the lone flankers and the wolves under budget, the giants'
  fights nine rounds, the gel wall and the pyre over, the elites a fifth of theirs, the
  bosses from a twentieth to a half.

Method: scratch probes of this session (a ledger over `BattleBot`, and a fight-at-its-rating
probe over the battle's own builders); the engine's own `Policy` for every fight. The squads
are an even sample of the six's combinations. Read on the branch over `bf5158e`; main's
`6112939`, taken before the landing, moves none of it (the second battle's read for one
squad is the same to the digit on the merged engine).

**The foes' side, the same day.** On the landed lines, each fight at its rating as above,
before and after the foes' numbers moved.

| The fight | Rated | Foes as they were | Landed | Rounds, landed | What moved |
|---|---|---|---|---|---|
| The Meadow: the lone whisker cat | 1 | 1.6% | 2.4% | 3.9 | 12 hit points (10) |
| the wolf pack | 2 | 0.1% | 4.7% | 4.8 | the wolf 7 hit points and a bite of 4 (4 and 3) |
| the goblin horde | 3 | 2.0% | 2.3% | 4.1 | the goblin 4 hit points (3) |
| the treant grove | 3 | 8.3% | 7.3% | 6.4 (9.0) | the treant 16 hit points (32) |
| the gel wall | 3 | 11.2% | 7.1% | 5.7 | the gel's blow 2 (3) |
| The Waste: the lone roc | 1 | 0.8% | 1.8% | 4.3 | 14 hit points (10) |
| the antlion trio | 2 | 7.2% | 7.2% | 3.5 | |
| the needler thicket | 3 | 5.5% | 5.5% | 3.1 | |
| the sandworm ambush | 3 | 8.6% | 8.6% | 4.2 | |
| The Marsh: the lone dullahan | 1 | 1.1% | 2.6% | 5.7 | 10 hit points (8) |
| the grave throng | 3 | 3.9% | 3.9% | 4.5 | |
| the barrow mound | 3 | 6.9% | 4.4% | 6.2 (8.6) | the barrow giant 20 hit points (32) |
| the knights' vigil | 3 | 2.7% | 2.7% | 3.1 | |
| The Peak: the lone cerberus | 1 | 4.3% | 4.3% | 3.7 | |
| the ember pyre | 3 | 12.5% | 5.0% | 3.9 | the salamander, the bomb and the drake scorch 1 (2); the drake's stoke burns 2 (4) |
| the magma vent | 3 | 8.4% | 7.0% | 4.8 | the same |
| A lone flanker, the mean | 1 | 2.0% | 2.8% | 4.4 | the budget a thirtieth or less, 3.3% |
| A hunter's pack, the mean | 2 | 3.6% | 5.9% | 4.2 | the budget a tenth |
| A formation, the mean | 3 | 7.0% | 5.4% | 4.6 | the budget a twentieth |

| The elite | Foes as they were | Landed | Rounds | What moved | As they were, the Barrier dark two rounds once spent |
|---|---|---|---|---|---|
| The shaman's warband | 0.8% | 6.7% | 4.0 | the shaman 28 hit points and 10 (16 and 8), with the goblin's and the wolf's | 1.3% |
| The Nob | 5.9% | 11.2% | 4.9 | 60 hit points and 18 (48 and 15) | 9.3% |
| The Old Man's rising | 8.2% | 10.1% | 6.8 | a maw of 12 (10) | 17.6% |
| The Pilgrim's wake | 1.4% | 1.4% | 4.5 | | 3.0% |
| The Rust Monster | 1.3% | 2.5% | 3.7 | 48 hit points and 16 (40 and 12) | 1.8% |
| Gilgamesh | 6.1% | 6.1% | 6.3 | | 9.6% |
| The Fell Rider | 1.8% | 4.6% | 4.0 | 48 hit points and 16 (32 and 15) | 2.7% |
| The Reaper | 0.0% | 0.4% | 3.5 | 44 hit points (24) | 0.0% |
| The Wild Hunt | 13.1% | 13.1% | 4.8 | | 13.4% |
| The Cinder Tortoise's brood | 10.4% | 10.6% | 8.1 | | 21.9% |
| The Thunder Ape | 11.1% | 11.1% | 4.3 | | 12.4% |
| The mean | 5.5% | 7.1% | 5.0 | the budget a quarter | 8.5% |

| The boss | Foes as they were | Landed | Rounds | What moved | As they were, the Barrier dark two rounds once spent |
|---|---|---|---|---|---|
| Floraison | 22.3% | 22.3% | 6.0 | | 19.6% |
| King Gel | 14.3% | 12.7% | 6.9 | the gel's blow | 23.7% |
| The Mantis Ant | 5.0% | 5.0% | 6.0 | | 16.4% |
| The Ruby Colossus | 22.6% | 22.6% | 8.7 | | 24.2% |
| The Fallen Weapon | 26.9% | 26.9% | 8.6 | | 36.0% |
| The Emperor Scorpion | 55.6% | 25.0% | 8.4 | 60 hit points and 14 (72 and 18) | 57.2% |
| The Matador | 13.6% | 13.6% | 6.2 | | 17.0% |
| The Phantom Train | 38.2% | 18.5% | 10.1 | 16 (20) | 55.4% |
| The Vampire Lord | 5.4% | 5.4% | 5.4 | | 8.2% |
| The Marsh Serpent | 9.5% | 9.5% | 5.2 | | 18.0% |
| The Gargantuan King | 24.7% | 24.7% | 24.8, three of twenty stalled | | 46.8%, 15.4 rounds |
| The Fiend of Fire | 32.4% | 32.4% | 6.3 | | 36.8% |
| The Obsidian Tyrant | 30.3% | 30.3% | 8.5 | | 32.8% |
| The mean | 23.1% | 19.2% | 8.5 | | 30.1% |

Read.

- The lone flankers, the hunters and the formations sit in the budget's band at their
  rating: a flanker 2 to 4%, a formation 2 to 9% and 5 the mean, the four led by a breach
  or a burn the dear end of it.
- Numbers do not bring the elites to theirs, and a trace says why. Three of the six carry
  the Barrier basic, it costs nothing, and a foe's blow is announced: the squad lays a
  Barrier on the machine named every round and the blow deals nothing ("The Reaper hits
  Cassowary: the Barrier takes the blow", every round of its fight). An elite or a boss whose
  kit is one blow a round costs a gathered four a twentieth of its hull whatever the blow;
  the ones that cost are the ones that strike many times or everyone (the Wild Hunt, the
  Thunder Ape, Floraison, the Fiend of Fire, the Emperor Scorpion).
- The Gargantuan King's fight runs twenty-five rounds in the mean and three in twenty never
  end. (Corrected the same day. This line first said heat made the squad hold behind a
  Barrier at its limit. A trace of a forty-round fight says otherwise: no machine in it is
  hot. The squad lays a Barrier and braces every round where it could fire, since the King's
  blow is big and announced and a round costs it nothing. The fight was six rounds on the
  old shields, so the lower shields are what tipped the bot from the shot to the block; it
  is the parked question of what prices a round.)
- The what-if beside it, the Barrier basic dark for two rounds once spent: the single-blow
  fights come up two or three times (the Mantis Ant 5% to 16%, the Marsh Serpent 10% to 18%,
  the Old Man 8% to 18%, the tortoise 10% to 22%), the King's fight runs fifteen rounds, and
  the many-strike bosses go over (the Fallen Weapon 36%, the Phantom Train and the scorpion
  over half on their old numbers). A price in heat (4, a basic gun's) moves the elites'
  mean a point: the bot pays it. (Corrected the same day. This was written as one round
  dark. The what-if, `barrier=cooldown`, wrote a cooldown of 2, right for the count of 11
  November, when a cooldown counted the round of its spend; the count changed on main on 12
  November and the what-if's number did not follow, so every figure here and in the tables'
  last column is two rounds dark. The what-if is fixed, and one round is read in the section
  below.)
- The elites' numbers that landed are the ones a number could move without passing a rule:
  the Pilgrim's knife and the Reaper's knell are breaches a point under twenty already.

**The second battle whole, a player that musters.** The ledger's battle again, three squads
of four, twenty seeds a domain, with a scratch rule in place of the runner's: each pack takes
as many machines as it is rated, the nearest, the packs in the order they reach the wall; a
pack that cannot have its rating is fought one short if it strikes the wall this coming
turn, and is gathered on otherwise. A cell is the range over the squads.

| The numbers | Domain | Won | The gate fell | Hull at the Rupture | Hull at the end | Wrecks |
|---|---|---|---|---|---|---|
| Before, `bf5158e` | The Meadow | 85 to 90% | 10 to 15% | 93 to 98% | 87 to 91% | 0 to 0.2 |
| | The Marsh | 80 to 90% | 10 to 20% | 87 to 90% | 77 to 83% | 0.1 to 0.3 |
| | The Waste | 60 to 75% | 5 to 20% | 73 to 74% | 45 to 55% | 1.0 to 1.3 |
| | The Peak | 35 to 55% | 40 to 50% | 59 to 80% | 40 to 64% | 1.0 to 1.8 |
| Tier one's lines and heat, the foes as they were | The Meadow | 80 to 85% | 15 to 20% | 83 to 94% | 70 to 81% | 0.1 to 0.5 |
| | The Marsh | 70 to 80% | 10 to 25% | 76 to 77% | 59 to 61% | 0.8 to 0.9 |
| | The Waste | 40 to 70% | 10 to 20% | 66 to 71% | 30 to 44% | 1.3 to 2.2 |
| | The Peak | 20 to 35% | 35 to 55% | 48 to 57% | 24 to 33% | 2.0 to 2.5 |
| Landed | The Meadow | 75 to 85% | 15% | 75 to 85% | 53 to 67% | 0.5 to 1.1 |
| | The Marsh | 65 to 75% | 15 to 30% | 66 to 73% | 50 to 58% | 0.9 to 1.1 |
| | The Waste | 45 to 70% | 10 to 15% | 60 to 63% | 29 to 40% | 1.3 to 2.0 |
| | The Peak | 40 to 60% | 35 to 55% | 56 to 65% | 37 to 44% | 1.5 to 2.0 |
| Landed, the Barrier dark two rounds once spent | The Meadow | 70 to 85% | 15 to 20% | 73 to 81% | 44 to 63% | 0.5 to 1.4 |
| | The Marsh | 45 to 65% | 25 to 40% | 58 to 72% | 38 to 51% | 1.3 to 2.0 |
| | The Waste | 40 to 45% | 5 to 25% | 54 to 57% | 21 to 30% | 2.0 to 2.4 |
| | The Peak | 30 to 50% | 35 to 40% | 55 to 59% | 27 to 32% | 2.1 to 2.6 |

The runner's own player on the landed numbers, one squad: the Meadow 45%, the Marsh 55%, the
Waste and the Peak 10% (70, 75, 15 and 15 before). It fights the elite alone, and the lower
shields cost it most.

The first battle beside it, three machines at Convergence 0, the same player, three trios:

| The trio | Before: the Meadow, the Marsh, the Waste, the Peak won | Landed |
|---|---|---|
| The Honey Badger, the Skua, the Cassowary | 40%, 35%, 0%, 0% | 10%, 10%, 0%, 0% |
| The Honey Badger, the Storm Petrel, the Prairie Dog | 40%, 30%, 0%, 0% | 10%, 0%, 0%, 0% |
| The Skua, the Cottonmouth, the Stingray | 80%, 55%, 25%, 35% | 45%, 20%, 0%, 0% |

Read.

- For a player that musters, the second battle was the Meadow's and the Marsh's to win nine
  times in ten with four fifths of the hull in hand at the end. It is theirs seven or eight
  times in ten with half to two thirds. The Waste is won half to two thirds of the time
  with a third of the hull left, its bosses the reason; the Peak half the time, and its
  losses are the gate's, before the numbers and after: its battles run two turns longer.
- The four domains are nearer one band than they were (hull at the end 53 to 67, 50 to 58,
  29 to 40 and 37 to 44 where it was 87 to 91, 77 to 83, 45 to 55 and 40 to 64), and not in
  it: the Waste's bosses and the Peak's clock are the two left.
- The first battle is worse for it, and it was no easy battle for this player before: with
  the Honey Badger the gate fell in 40 to 85% of them on the old numbers, since three
  machines cannot hold a wall the rule musters them away from, and the lower shields now
  wipe the trio with no Badger. It is the first thing to scale from the anchor, and it
  wants its own rule (the refit brief's section 10: a block by Convergence, his to pick).
- The Barrier dark for two rounds costs the mustering player up to 25 points of battles
  won. (Corrected the same day, as above: two rounds, not one.)

## 12 November, the Barrier's cooldown: on the piece, on the machine, and both; the first battle beside it

Ryan, 12 November, on the anchor's read of the free Barrier: "Barrier can have a cooldown,
yeah. I gave it a cooldown on the Boar's locked and that's a tier 2 piece. This makes sense
regardless of the reasoning, you can't just protect forever. The more dramatic version would
actually apply the cooldown to the unit, similar to Numbed, where they can't get barrier twice
in a row." Main at `4c29e09`, the anchor's numbers; the six real tier ones, a tier-one rift at
Convergence 1, the fight bot (greedy). Each a direction.

**A correction first.** The what-if the section above cites, `barrier=cooldown`, wrote a
cooldown of 2: the next round dark by the count of 11 November, two rounds dark by the count
main took on 12 November (a cooldown is the rounds sat out after the round of the spend). So
what that section called one round dark was two. The what-if now writes a cooldown's own
number (`barrier=cooldownN`, the bare word 1), and both are read here.

**Each fight at its rating**, five squads of four, four seeds a squad, a share of a four's
hull. The machine's rest is read with the engine untouched: a fight bot that never lays a
Barrier on a machine that gained one the round before, which is the same fight, since every
Barrier in these reads is one the bot chose to lay.

| The elite | No cooldown | The piece dark a round | The machine rests a round | Both | The piece dark two rounds |
|---|---|---|---|---|---|
| The shaman's warband | 6.7% | 7.7% | 7.0% | 7.9% | 8.5% |
| The Nob | 11.2% | 17.0% | 14.6% | 19.4% | 20.9% |
| The Old Man's rising | 10.1% | 17.8% | 14.6% | 21.3% | 20.4% |
| The Pilgrim's wake | 1.4% | 2.4% | 1.8% | 2.4% | 3.0% |
| The Rust Monster | 2.5% | 2.9% | 2.8% | 3.9% | 4.4% |
| Gilgamesh | 6.1% | 7.9% | 7.1% | 7.9% | 9.6% |
| The Fell Rider | 4.6% | 6.7% | 8.3% | 9.0% | 8.6% |
| The Reaper | 0.4% | 0.5% | 0.6% | 0.5% | 0.1% |
| The Wild Hunt | 13.1% | 12.7% | 13.2% | 13.2% | 13.4% |
| The Cinder Tortoise's brood | 10.6% | 16.4% | 15.1% | 18.8% | 21.9% |
| The Thunder Ape | 11.1% | 13.1% | 12.0% | 13.1% | 12.4% |
| The mean | 7.1% | 9.5% | 8.8% | 10.7% | 11.2% |

| The boss | No cooldown | The piece dark a round | The machine rests a round | Both | The piece dark two rounds |
|---|---|---|---|---|---|
| Floraison | 22.3% | 20.0% | 20.4% | 19.1% | 19.6% |
| King Gel | 12.7% | 15.0% | 15.7% | 16.3% | 20.4% |
| The Mantis Ant | 5.0% | 8.6% | 8.7% | 9.9% | 16.4% |
| The Ruby Colossus | 22.6% | 24.8% | 23.8% | 24.0% | 24.2% |
| The Fallen Weapon | 26.9% | 35.5% | 30.4% | 38.2% | 36.0% |
| The Emperor Scorpion | 25.0% | 24.8% | 30.5% | 28.3% | 26.2% |
| The Matador | 13.6% | 16.7% | 12.9% | 14.8% | 17.0% |
| The Phantom Train | 18.5% | 26.7% | 30.1% | 29.9% | 39.8% |
| The Vampire Lord | 5.4% | 5.3% | 6.7% | 5.3% | 8.2% |
| The Marsh Serpent | 9.5% | 11.3% | 13.1% | 12.6% | 18.0% |
| The Gargantuan King | 24.7%, 25 rounds | 38.3%, 23 rounds | 36.4%, 20 rounds | 46.7%, 25 rounds | 46.8%, 15 rounds |
| The Fiend of Fire | 32.4% | 33.1% | 35.3% | 32.6% | 36.8% |
| The Obsidian Tyrant | 30.3% | 31.5% | 30.6% | 31.5% | 32.8% |
| The mean | 19.2% | 22.4% | 22.7% | 23.8% | 26.3% |

**The second battle whole**, the mustering player, three squads, twenty seeds a domain; won,
then the hull left at the end.

| The Barrier | The Meadow | The Marsh | The Waste | The Peak |
|---|---|---|---|---|
| No cooldown | 75 to 85%, 53 to 67% | 65 to 75%, 50 to 58% | 45 to 70%, 29 to 40% | 40 to 60%, 37 to 44% |
| The piece dark a round | 75 to 85%, 49 to 66% | 60 to 65%, 46 to 52% | 35 to 50%, 25 to 32% | 40 to 60%, 28 to 37% |
| The machine rests a round | 70 to 85%, 50 to 66% | 60 to 70%, 46 to 52% | 40 to 45%, 21 to 30% | 40 to 60%, 28 to 36% |
| Both | 75 to 85%, 48 to 66% | 60 to 65%, 46 to 51% | 35 to 55%, 25 to 31% | 35 to 60%, 26 to 37% |
| The piece dark two rounds | 70 to 85%, 44 to 63% | 45 to 65%, 38 to 51% | 40 to 45%, 21 to 30% | 30 to 50%, 27 to 32% |
| Landed: the piece dark a round, the Fallen Weapon lighter | 75 to 85%, 49 to 66% | 60 to 65%, 46 to 52% | 45 to 55%, 28 to 34% | 40 to 60%, 28 to 37% |

Read.

- A round dark on the piece lifts the elites' mean from 7 to 9.5% of a four's hull and the
  bosses' from 19 to 22%; the machine's rest lifts them to 9 and 23%; both to 11 and 24%.
  The fights that move are the ones with one big blow on a machine it names again: the Nob,
  the Old Man, the tortoise, the Mantis Ant, the Phantom Train. The Reaper, the Pilgrim and
  the Rust Monster move under none of them.
- The two bite in different places. The piece's cooldown halves one piece's supply and
  fades as a squad carries more of them: three of the six carry the basic, and two of
  those in a squad cover nearly every round again. The machine's rest holds however many pieces a
  squad carries and bites only where the same machine is named two rounds running, so it
  is a rule about the tank and the lure. Each alone leaves a way to cover every round, a
  second piece or a blow that moves; the two together leave none.
- Neither brings the elites to a quarter. What is left is their kits, a single blow a round
  against a squad of four gauges.
- The Gargantuan King's long fight ends under none of the one-round rules: twenty rounds
  and more, one in twenty never ending. A trace of a forty-round one: sixteen hits on the
  King in forty rounds, no machine hot, the squad laying a Barrier and bracing where it
  could fire. A round costs it nothing and three machines carry the piece. No Barrier
  rule of one round answers it; the section below finds what does, since with no Barrier
  basic at all the same fight is ten rounds.
- With the piece dark a round the Waste falls out of the others' band (35 to 50% won), the
  Fallen Weapon the reason (27% to 36% of a four's hull at its rating). Its haft at 16 and
  its eyes' gaze at 8, where they were 20 and 10, read 23% under the cooldown, and the Waste
  45 to 55%.

**Landed**: every piece that grants a Barrier carries a cooldown of 1, the Halo Projector and
the Blast Door as the Wild Boar's Breaching Plow already did; the Fallen Weapon's haft 16 and
its eyes' gaze 8. The machine's rest is read and not built: his to say.

**The first battle, three machines at Convergence 0.** It was not scaled: the anchor's
numbers are tier one's, and the first battle fights the same foes with three machines on the
same lines. The mustering player, three trios, twenty seeds a domain; won in the Meadow, the
Marsh, the Waste and the Peak.

| The trio | Before the anchor | The anchor | With the Barrier's cooldown | Elites and bosses at three quarters | Those at three fifths, the rank and file at three quarters |
|---|---|---|---|---|---|
| The Honey Badger, the Skua, the Cassowary | 40%, 35%, 0%, 0% | 10%, 10%, 0%, 0% | 5%, 5%, 0%, 0% | 15%, 25%, 0%, 0% | 35%, 70%, 20%, 10% |
| The Honey Badger, the Storm Petrel, the Prairie Dog | 40%, 30%, 0%, 0% | 10%, 0%, 0%, 0% | 0%, 0%, 0%, 0% | 10%, 0%, 5%, 0% | 45%, 70%, 30%, 35% |
| The Skua, the Cottonmouth, the Stingray | 80%, 55%, 25%, 35% | 45%, 20%, 0%, 0% | 25%, 20%, 0%, 0% | 55%, 25%, 30%, 15% | 90%, 95%, 90%, 65% |

By fight, the first trio in the Meadow, a share of the trio's own hull: on the old numbers
its elite cost 8% and was never lost, a formation 3%, the boss 26%; on the anchor's the
elite costs 28% and is lost half the time, a formation 12%, the boss 43%.

Read.

- The bump followed from the numbers. A fight rated for four, the elite and the boss, is
  met by three machines on tier one's lower shields, and the elites' own numbers went up
  for a squad of four.
- Two things lose a first battle, and they are separate. Hull: at three fifths for the
  elite and the boss and three quarters for the rank and file almost nobody is wiped (the
  trio with no Honey Badger, a fifth of the time in the Peak) and a trio ends with 45 to
  90% of its hull. The wall: the two trios with the Honey Badger still lose
  the gate in 30 to 90% of them at those numbers, as they did in 40 to 85% before the
  anchor. Three machines are asked for a formation and two flank patrols at once, five
  machines' worth, and this player gathers its three on the formation.
- So the first battle wants a share for its foes and a lighter ask at its wall, and neither
  is a number of tier one's. The refit brief's section 10 holds the bench.

Method: as the section above, with a fight bot for the rest (scratch, the engine untouched)
and a share laid over every elite's and boss's hit points and blow, and the rank and file's,
in memory.

## 12 November, the Barrier's place: what the Halo's slot holds, a Barrier, a shield grant, a temporary shield or neither

Ryan, 12 November: "So lets discuss Barrier, then. Is it toxic? Is it worse than giving
numerical shield? Should it be rare or locked? An argument could be made that a chassis with
barrier is a sub for a Tank on a team, and thus it's not widely available. One thing we could
do, which sounds terrible, is have a difference between shield and temporary shield. Or, we go
back to some shield-granting pieces, as a keyword on Equipment so its not ubiquitous as a
component type, but still exists. Armour grants and Barrier grants are very binary, shield is
a buffer. I liked our simplification, but maybe we went too far."

Main at `031ddcf`. The Halo Projector, the Barrier basic that three of the six tier ones
carry, with its entry replaced in memory and nothing else moved: the foes' numbers are the
anchor's, set with the Barrier in the slot. The fight bot (greedy), each fight at its rating
as in the sections above (six squads and five seeds for a flanker, a hunter and a formation;
five squads of four and four seeds for an elite and a boss); a share of a four's hull. Each a
direction.

| The Halo's slot holds | A lone flanker | A hunter's pack | A formation | An elite | A boss | The Gargantuan King's fight |
|---|---|---|---|---|---|---|
| A Barrier, free (read before the Fallen Weapon's cut) | | | | 7.1% | 19.2% | 25 rounds |
| A Barrier, cooldown 1 (content) | 2.8% | 6.3% | 5.9% | 9.5% | 21.4% | 23 rounds, one in twenty never ending |
| Overshield 4: a shield grant that may pass the gauge, the excess gone at the round's end | 3.0% | 6.5% | 6.1% | 17.6% | 34.0% | 10 rounds |
| Overshield 6 | | | | 15.4% | 27.2% | 11 rounds |
| Shield 4, plain: it refills the gauge | 3.0% | 7.1% | 6.4% | 18.8% | 37.7% | 10 rounds |
| The Shoring Jack, Armoured 2 | 3.5% | 6.9% | 6.6% | 19.8% | 37.7% | 10 rounds |
| A gun, the Twin Autoguns | | | | 19.5% | | |

The share of the foes' blows on machines that a Barrier took whole, with the cooldown: 12% in
a formation, 41% in an elite's fight (49% when it was free), 40% in a boss's. By fight: the
Rust Monster 79%, the Mantis Ant 72%, the Nob 70%, the Gargantuan King 65%, the Reaper 56%,
the Pilgrim and the Marsh Serpent 55%, the Phantom Train 54%, the Old Man 52%.

| The elite | A Barrier, cooldown 1 | Overshield 4 | Overshield 6 | Shield 4, plain | The Jack |
|---|---|---|---|---|---|
| The shaman's warband | 7.7% | 7.9% | 6.6% | 8.4% | 8.4% |
| The Nob | 17.0% | 39.3% | 35.4% | 37.1% | 36.1% |
| The Old Man's rising | 17.8% | 37.1% | 37.0% | 37.1% | 37.7% |
| The Pilgrim's wake | 2.4% | 13.1% | 13.0% | 13.2% | 13.5% |
| The Rust Monster | 2.9% | 7.3% | 6.1% | 11.5% | 11.1% |
| Gilgamesh | 7.9% | 16.1% | 14.6% | 21.1% | 23.8% |
| The Fell Rider | 6.7% | 14.4% | 11.1% | 16.9% | 15.8% |
| The Reaper | 0.5% | 1.1% | 0.7% | 2.6% | 2.4% |
| The Wild Hunt | 12.7% | 17.3% | 15.4% | 17.4% | 19.2% |
| The Cinder Tortoise's brood | 16.4% | 26.4% | 18.6% | 27.3% | 36.0% |
| The Thunder Ape | 13.1% | 13.2% | 10.7% | 14.6% | 13.6% |

| The boss | A Barrier, cooldown 1 | Overshield 4 | Overshield 6 | Shield 4, plain | The Jack |
|---|---|---|---|---|---|
| Floraison | 20.0% | 21.9% | 16.0% | 22.9% | 19.2% |
| King Gel | 15.0% | 32.8% | 23.6% | 39.2% | 42.1% |
| The Mantis Ant | 8.6% | 27.8% | 25.4% | 29.4% | 32.3% |
| The Ruby Colossus | 24.8% | 35.2% | 29.9% | 36.0% | 41.4% |
| The Fallen Weapon | 22.7% | 41.6% | 33.9% | 41.4% | 50.6% |
| The Emperor Scorpion | 24.8% | 40.7% | 27.6% | 44.0% | 41.4% |
| The Matador | 16.7% | 16.4% | 11.7% | 25.6% | 19.6% |
| The Phantom Train | 26.7% | 52.2% | 38.8% | 56.2% | 60.2% |
| The Vampire Lord | 5.3% | 14.5% | 6.8% | 19.8% | 23.0% |
| The Marsh Serpent | 11.3% | 30.7% | 27.0% | 35.1% | 32.9% |
| The Gargantuan King | 38.3% | 51.9% | 42.9% | 59.4% | 65.8% |
| The Fiend of Fire | 33.1% | 32.6% | 30.4% | 39.4% | 22.5% |
| The Obsidian Tyrant | 31.5% | 43.8% | 39.1% | 41.2% | 38.5% |

With Overshield 6 and the six elites back on their numbers of before the anchor (the shaman,
the Nob, the Old Man, the Rust Monster, the Fell Rider, the Reaper), the elites' mean is
11.7%: the Nob 17%, the Old Man 30%, the tortoise 19%, the Wild Hunt 15%, Gilgamesh 15%, the
Pilgrim 13%, the Thunder Ape 11%.

The second battle whole, the mustering player, three squads, twenty seeds a domain, on the
anchor's foe numbers; won, then the hull left at the end.

| The Halo's slot holds | The Meadow | The Marsh | The Waste | The Peak |
|---|---|---|---|---|
| A Barrier, cooldown 1 (content) | 75 to 85%, 49 to 66% | 60 to 65%, 46 to 52% | 45 to 55%, 28 to 34% | 40 to 60%, 28 to 37% |
| Overshield 6 | 75 to 80%, 53 to 57% | 35 to 75%, 38 to 48% | 15 to 25%, 17 to 36% | 40 to 60%, 28 to 37% |
| Overshield 4 | 65 to 85%, 39 to 51% | 25 to 60%, 33 to 43% | 10 to 30%, 13 to 32% | 25 to 50%, 24 to 32% |
| Shield 4, plain | 65 to 80%, 31 to 46% | 30 to 60%, 27 to 41% | 10 to 25%, 8 to 35% | 15 to 40%, 21 to 24% |
| The Shoring Jack | 50 to 80%, 32 to 47% | 25 to 40%, 20 to 35% | 0 to 30%, 13 to 27% | 25 to 45%, 20 to 27% |

Read.

- The Barrier's worth is the blow it meets. It takes two blows in five from an elite or a
  boss and seven in ten from the ones whose kit is a single blow, with its cooldown on; in a
  formation it takes one in eight. So it does nothing where blows are many and small and
  erases the fights built on one big announced blow, which is the bible's own diagnosis of
  the old shield rule (14 October: a small shield "was secretly 'negate one blow', worth the
  biggest blow it met rather than its number").
- Nothing in the slot changes a flanker's, a hunter's or a formation's cost.
- With any number in the slot, or nothing, the same elites cost a four about twice what they
  cost beside the Barrier, and the bosses a quarter to three quarters more, their numbers
  untouched. The elites' budget of a quarter is in reach of a number.
- The Gargantuan King's fight is ten rounds without the Barrier basic and twenty-three with
  it. The stall of the section above was the Barrier, three machines turning it; a block of
  4 or 6 is not worth a shot given up.
- A plain shield grant reads as no piece: the Jack and a gun land where it does. A gauge is
  full as a fight opens, and after that the grant is recovery, which the regen already is.
- Overshield does work and its number tunes it: 4 takes a ninth off the elites' cost and a
  tenth off the bosses' against no piece, 6 a fifth and a quarter. It is the plain grant
  with one thing more, the room past the maximum, so that room is what earns the entry: a
  grant that cannot pass a full gauge has nowhere to land when the fight opens.
- The whole battle on these foe numbers is too dear without the Barrier in the slot, the
  Waste most (its bosses a third to a half of a four's hull). The numbers were set with the
  Barrier there, the elites' raised against it, so they come down with it if it goes.

Method: the fight-at-its-rating probe and the ledger of the sections above, with one
component's entry replaced whole in memory; the blows are counted from each fight's log.

**The base shield's worth, the same day.** His follow-up: "I guess my point is, if we're making
temp shield ubiquitous, then why even have base shield?" The same reads with Overshield 6 in
the Halo's slot throughout, and the six machines' own shield in three forms: as content has
it, a gauge of 6 to 12 with a regen of 1 or 2; the gauge with no regen; and no shield at all,
nothing in its place. A share of a four's hull.

| The fight at its rating | Gauge and regen | Gauge, no regen | No base shield |
|---|---|---|---|
| A lone flanker | 2.0% | 3.8% | 13.2%, a quarter of the duels lost |
| A hunter's pack | 5.4% | 7.8% | 26.5% |
| A formation | 5.7% | 7.5% | 27.3% |
| An elite | 15.4% | 18.6% | 38.6%, one fight in sixteen lost |
| A boss | 27.2% | 34.9% | 63.7%, a quarter of the fights lost |

By formation with no base shield: the goblin horde 23%, the grave throng 29%, the gel wall 36%,
the ember pyre 38%, the treant grove 40%; the two led by a breach move least (the sandworm
ambush 10% to 14%), since a breach passes a shield already.

The second battle whole, the mustering player, three squads, on the anchor's foe numbers; won.

| The machines' own shield | The Meadow | The Marsh | The Waste | The Peak |
|---|---|---|---|---|
| Gauge and regen | 75 to 80% | 35 to 75% | 15 to 25% | 40 to 60% |
| Gauge, no regen | 50 to 75% | 20 to 50% | 5 to 25% | 20 to 25% |

Read.

- The gauge is what an entry's shield cannot be. With no base shield a formation costs a
  quarter of a four's hull where it costs a twentieth, and a squad is spent after two of
  them. An entry's grant covers one machine when its entry shows; the gauge covers every
  machine against the opening volley with no entry spent. To hold the
  budget without it the rank and file's blows would be a fifth of what they are, under one,
  or the hull five times its size, either of them off the scale's numbers.
- They stand on different clocks: the hull is the battle's, the gauge is the fight's, and
  what an entry adds past the gauge is the round's. The fight's layer is what lets an ordinary fight end
  clean and a bad one leave a mark that carries.
- The regen is the part an entry's grant overlaps: both are shield every round, one free and
  one chosen. It is worth two points of hull in a formation, three in an elite's fight and
  seven in a boss's, since it is paid by the round.
- These foe numbers were set with the regen and the Barrier both in place, so the whole
  battle without either is too dear and says only which way each moves it.

**13 November, how these reads were used: a correction.** The numbers stand. What this
session drew from them is withdrawn on Ryan's word ("I fail to see how what you proposed is
any different than what we had before when we had shield faces ... we cut that for a reason,
because it wasn't working for balance"): a shield grant with Overshield in the Halo's slot,
and the gauge without its regen beside it, are the third of his three shapes of 9 November.
Held beside the benches of 27 and 30 October above, the grant's rows say what those said of
every shield entry. A plain 4 reads as a gun in the slot does. An Overshield 4 reads two
points under the gun in an elite's fight, 17.6% against 19.5%. A 6, the Halo's own number
until 10 November, reads a fifth under. Two bullets above lean the wrong way for the model.
"Overshield does work and its number tunes it" reads a fifth off an elite's cost as a place
for the piece, where the model's test is whether a block belongs on the die at all. "The
regen is the part an entry's grant overlaps" has it backwards: the regen is the buffer no
die decides, his call of 5 and 9 November, and the entry is the part that was cut. The row
that still informs his call on the Barrier is the Shoring Jack's: the gauge and the regen,
no Barrier and no shield in the slot.

## 13 November, the breaking shield: the blow that breaks a shield stopped whole, and the broken shield at rest

Ryan, 13 November: "What if we bring back that when a shield breaks, it absorbs the whole blow?
It does not bleed into the hull. But in exchange, if a shield breaks, it's down for a couple of
turns before it starts to regenerate again. So you get the off dice defensive measure at the
cost of having to scramble to protect your lights small hull after they take a huge blow."

The decision it informs: none yet; the idea and its holes are the refit brief's section 15.
The rule is a what-if behind three switches (`Skirmish.shield_break`, `shield_rest`,
`shield_break_min`), off in the game. As read: the blow that takes a standing shield to
nothing is stopped whole; a shield a foe's blow broke stays down so many rounds, no regen and
nothing else raising it, and its regen starts again after; a blow exactly the shield's size
breaks it; a breach passes a shield that stands and rests nothing; a Barrier takes its blow
first. The branch over main at `ac48748`, the anchor's foe numbers, the six tier ones, the fight bot (greedy),
each fight at its rating as in the sections above (six squads and five seeds for a flanker, a
hunter and a formation; five squads of four and four seeds for an elite and a boss). A share
of a four's hull. Every row is read twice, since the Barrier's place is open: with the
Shoring Jack's entry in the Halo's slot, and with the Barrier basic as content has it. Each a
direction.

| The Halo's slot | The shield | A lone flanker | A hunter's pack | A formation | An elite | A boss |
|---|---|---|---|---|---|---|
| The Jack | Honest | 3.5% | 6.9% | 6.6% | 19.8% | 37.7% |
| The Jack | The rest alone, 2 rounds | 4.3% | 8.6% | 8.2% | 22.7% | 41.6% |
| The Jack | The break alone, no rest | 0.9% | 2.9% | 4.5% | 6.4% | 7.0% |
| The Jack | The break, rest 1 | 2.7% | 5.5% | 5.9% | 9.9% | 14.5% |
| The Jack | The break, rest 2 | 3.5% | 7.0% | 6.8% | 12.2% | 18.5% |
| The Jack | The break, rest 3 | 3.7% | 7.4% | 7.1% | 13.3% | 22.3% |
| The Jack | The break at half a gauge or more, rest 2 | 4.1% | 8.5% | 7.9% | 14.4% | 26.3% |
| The Jack | The break at a full gauge only, rest 2 | 4.3% | 8.6% | 8.1% | 15.7% | 27.3% |
| The Barrier basic | Honest (content) | 2.8% | 6.3% | 5.9% | 9.5% | 21.4% |
| The Barrier basic | The break, rest 1 | 1.8% | 4.8% | 5.2% | 3.7% | 8.3% |
| The Barrier basic | The break, rest 2 | 2.6% | 6.2% | 5.6% | 5.0% | 10.5% |
| The Barrier basic | The break, rest 3 | 3.1% | 6.5% | 5.9% | 5.5% | 11.8% |

Rounds and wrecks, an elite's fight and a boss's: the Jack and the honest shield 4.6 and 7.0
rounds, 0.16 and 0.60 wrecks a fight, 94% of the bosses' fights won; the Jack and the break at
rest 2, 4.5 and 6.2 rounds, 0.09 and 0.18 wrecks, 99% won; content, 4.8 and 8.1 rounds, 0.03
and 0.19 wrecks, 98% won.

By fight, the Jack in the slot, and content beside it:

| The elite | Honest | Rest 1 | Rest 2 | Rest 3 | Content |
|---|---|---|---|---|---|
| The shaman's warband | 8.4% | 8.6% | 10.1% | 11.1% | 7.7% |
| The Nob | 36.1% | 10.4% | 13.6% | 14.4% | 17.0% |
| The Old Man's rising | 37.7% | 37.8% | 37.4% | 38.1% | 17.8% |
| The Pilgrim's wake | 13.5% | 14.2% | 14.2% | 14.3% | 2.4% |
| The Rust Monster | 11.1% | 2.0% | 3.7% | 3.7% | 2.9% |
| Gilgamesh | 23.8% | 4.0% | 8.0% | 10.7% | 7.9% |
| The Fell Rider | 15.8% | 4.3% | 4.8% | 4.8% | 6.7% |
| The Reaper | 2.4% | 0.5% | 0.5% | 0.5% | 0.5% |
| The Wild Hunt | 19.2% | 7.3% | 8.5% | 9.3% | 12.7% |
| The Cinder Tortoise's brood | 36.0% | 10.2% | 24.0% | 29.0% | 16.4% |
| The Thunder Ape | 13.6% | 9.6% | 9.8% | 10.4% | 13.1% |

| The boss | Honest | Rest 1 | Rest 2 | Rest 3 | Content |
|---|---|---|---|---|---|
| Floraison | 19.2% | 17.8% | 18.0% | 17.9% | 20.0% |
| King Gel | 42.1% | 15.8% | 21.4% | 26.6% | 15.0% |
| The Mantis Ant | 32.3% | 19.0% | 21.9% | 24.7% | 8.6% |
| The Ruby Colossus | 41.4% | 14.4% | 15.1% | 18.3% | 24.8% |
| The Fallen Weapon | 50.6% | 11.8% | 16.8% | 21.8% | 22.7% |
| The Emperor Scorpion | 41.4% | 22.3% | 35.7% | 41.2% | 24.8% |
| The Matador | 19.6% | 12.7% | 12.7% | 14.8% | 16.7% |
| The Phantom Train | 60.2% | 16.9% | 26.9% | 34.5% | 26.7% |
| The Vampire Lord | 23.0% | 10.0% | 15.2% | 23.2% | 5.3% |
| The Marsh Serpent | 32.9% | 3.4% | 6.0% | 6.5% | 11.3% |
| The Gargantuan King | 65.8% | 16.1% | 21.4% | 31.0% | 38.3% |
| The Fiend of Fire | 22.5% | 18.3% | 19.5% | 19.8% | 33.1% |
| The Obsidian Tyrant | 38.5% | 10.1% | 10.1% | 10.1% | 31.5% |

By formation and patrol, the Jack in the slot, the honest shield and then the break at rest 2:
the treant grove 10.2% and 9.8%, the barrow mound 8.1% and 6.5%, the goblin horde 2.5% and
3.2%, the grave throng 3.5% and 5.0%, the gel wall 6.9% and 8.2%, the ember pyre 4.9% and
5.0%, the wolf pack 5.1% and 5.4%, the antlion trio 8.7% and 8.6%; the ones led by a breach
do not move under any rule (the sandworm ambush 9.9%, the magma vent 11.4% to 11.7%, the
needler thicket 5.1%, the knights' vigil 3.9%). No blow of 8 or more lands in any of them.

What became of the foes' damage on machines, the Jack in the slot (what is left of each row
is the armour's):

| The fight, the shield | The shield took | The hull took | A break stopped | Blows of 8 or more a fight | Of those, stopped whole | On a shield already gone | The hull they took a fight |
|---|---|---|---|---|---|---|---|
| An elite, honest | 43% | 46% | 0% | 2.9 | 0% | 10% | 18.0 |
| An elite, the break and rest 2 | 37% | 29% | 29% | 2.7 | 56% | 24% | 10.1 |
| An elite, the break alone | 41% | 15% | 42% | 2.5 | 73% | 8% | 5.6 |
| A boss, honest | 36% | 45% | 0% | 4.7 | 0% | 8% | 31.8 |
| A boss, the break and rest 2 | 31% | 22% | 34% | 4.1 | 70% | 26% | 11.8 |
| A boss, the break alone | 35% | 8% | 47% | 3.7 | 92% | 4% | 2.3 |
| A formation, honest | 65% | 24% | 0% | none | | | |
| A formation, the break and rest 2 | 59% | 25% | 8% | none | | | |

The worst single blow on a hull: 24 in an elite's fight and 27 in a boss's on the honest
shield, 24 and 26 under the break at rest 2; the lights' hulls are 20 to 24.

The sliver, the Jack in the slot: what a break stopped, in points of hull a fight, and how
much of it a shield under a third of its gauge stopped, or one that had already broken once
in the fight.

| The fight, the rule | Breaks a fight | Stopped a fight | By a shield that had broken before | By a shield under a third of its gauge |
|---|---|---|---|---|
| An elite, rest 2 | 2.0 | 11.8 | 2.1 | 2.9 |
| A boss, rest 2 | 3.8 | 25.4 | 7.4 | 8.2 |
| An elite, no rest | 2.6 | 15.9 | 6.4 | 6.6 |
| A boss, no rest | 4.5 | 31.4 | 14.9 | 14.6 |
| A boss, half a gauge or more, rest 2 | 3.9 | 18.1 | 2.3 | none |
| A formation, rest 2 | 1.3 | 1.9 | 0.6 | 1.5 |
| The Phantom Train, rest 2 | 5.6 | 49.0 | 21.2 | 19.6 |
| The Gargantuan King, rest 2 | 5.8 | 38.3 | 15.8 | 14.2 |
| The Cinder Tortoise's brood, rest 2 | 5.7 | 28.6 | 13.7 | 13.9 |

The rest's own cost at two rounds: a blow lands on a shield at rest 1.0 times an elite's
fight and 3.6 times a boss's, taking 6.9 and 14.9 hull; 1.5 times a formation's, taking 3.1.

By machine, its own hull lost and how often it was wrecked, the Jack in the slot:

| The machine | An elite, honest | An elite, rest 2 | A boss, honest | A boss, rest 2 | Wrecked in a boss's fight, honest | Rest 2 |
|---|---|---|---|---|---|---|
| The Honey Badger | 9% | 4% | 19% | 9% | 2% | 0% |
| The Skua | 20% | 15% | 40% | 22% | 19% | 6% |
| The Storm Petrel | 30% | 17% | 52% | 26% | 22% | 8% |
| The Prairie Dog | 23% | 14% | 34% | 18% | 12% | 5% |
| The Cassowary | 20% | 13% | 44% | 21% | 15% | 2% |
| The Cottonmouth | 28% | 19% | 55% | 24% | 28% | 7% |

The fight bot's spends on the Armoured basic, both slots holding it: 10.7% of an elite's
fight's spends on the honest shield and 7.8% under the break at rest 2 (2.0 a fight and 1.4);
16.8% and 11.8% of a boss's (4.7 a fight and 3.0); 8.2% and 7.4% of a formation's.

The second battle whole, the mustering player, three squads, twenty seeds a domain; won, then
the hull left at the end.

| The Halo's slot | The shield | The Meadow | The Marsh | The Waste | The Peak |
|---|---|---|---|---|---|
| The Jack | Honest | 50 to 80%, 32 to 47% | 25 to 40%, 20 to 35% | 0 to 30%, 13 to 27% | 25 to 45%, 20 to 27% |
| The Jack | The break, rest 1 | 75 to 85%, 54 to 66% | 45 to 70%, 44 to 62% | 20 to 60%, 24 to 37% | 40 to 60%, 48 to 51% |
| The Jack | The break, rest 2 | 65 to 85%, 45 to 58% | 50 to 55%, 37 to 55% | 15 to 35%, 19 to 32% | 40 to 50%, 39 to 42% |
| The Jack | The break, rest 3 | 65 to 85%, 42 to 56% | 30 to 55%, 30 to 51% | 15 to 30%, 17 to 34% | 35 to 50%, 35 to 38% |
| The Jack | Half a gauge or more, rest 2 | 55 to 80%, 36 to 51% | 30 to 50%, 30 to 45% | 5 to 30%, 13 to 25% | 25 to 35%, 29 to 35% |
| The Barrier basic | Honest (content) | 75 to 85%, 49 to 66% | 60 to 65%, 46 to 52% | 45 to 55%, 28 to 34% | 40 to 60%, 28 to 37% |
| The Barrier basic | The break, rest 1 | 75 to 85%, 66 to 76% | 70 to 90%, 66 to 74% | 65 to 75%, 45 to 50% | 50 to 70%, 50 to 58% |
| The Barrier basic | The break, rest 2 | 70 to 85%, 60 to 72% | 60 to 70%, 57 to 65% | 60 to 65%, 35 to 44% | 40 to 60%, 44 to 49% |
| The Barrier basic | The break, rest 3 | 75 to 85%, 55 to 70% | 45 to 70%, 47 to 63% | 45 to 60%, 34 to 39% | 30 to 55%, 37 to 45% |

One fight traced, the Gargantuan King against the Honey Badger, the Skua, the Prairie Dog and
the Cottonmouth, seed 2, the break at rest 2: round one, its 15 on the Prairie Dog's 8 of
shield, "it breaks and stops the other 7"; round two, its 15 on the Badger's 6, the other 9
stopped; round three it gathers its Charge; round four the Prairie Dog's regen brings back 1,
and the Charge of 11 on every machine takes 8 from the Badger, whose shield is at rest, and
nothing from the other three, the Prairie Dog's shield of 1 stopping the other 10. Four
rounds, eight hull.

Read.

- At a rest of two the fights of every day do not move. The break and the rest cancel: a
  flanker 3.5% and 3.5%, a hunter's pack 6.9% and 7.0%, a formation 6.6% and 6.8%. Their
  blows are 2 to 7, so a break has little left over to stop, and what it pays is the regen
  the rest takes. The swarms come a little dearer and the fights led by a giant a little
  cheaper.
- An elite costs two fifths less and a boss half, with no die spent and in fights no longer:
  19.8% to 12.2%, 37.7% to 18.5%, a boss's fight 7.0 rounds to 6.2. A light is wrecked in 2
  to 8% of its bosses' fights where it was wrecked in 12 to 28%.
- That is about what the Barrier basic is worth today (9.5% and 21.4%), without its dice or
  its stall: the Gargantuan King's fight is five rounds where three machines turning the
  Barrier made it twenty-three. The two together are worth twice either, an elite 5.0% and a
  boss 10.5%.
- It is the Barrier's shape. A foe whose kit is one blow a round falls to two fifths or less of
  what it cost (the Nob 36% to 14%, the Marsh Serpent 33% to 6%, the Gargantuan King 66% to
  21%, the Obsidian Tyrant 39% to 10%); a foe of many small blows does not move or comes
  dearer (the shaman's warband, Floraison, the Emperor Scorpion); a breach does not move at
  all (the Old Man 38% and 37%), and the Waste's battle is where the rule falls short of the
  Barrier basic (15 to 35% won against 45 to 55%).
- A big blow becomes nothing or all of it. Of the blows of 8 or more, a break stops 56% whole
  in an elite's fight and 70% in a boss's, and 24% and 26% land on a hull whose shield is
  gone, where 10% and 8% did. The worst blow a hull takes is as it was, 24 to 27 against
  hulls of 20 to 24, so a blow's number tunes nothing against a shield that stands and
  everything against one that does not.
- The sliver is a quarter to a third of the gain, and half of it in a long fight. A point of
  regen back after the rest stops the next blow whole, as the trace's shield of 1 stopped 10.
  With no rest it is half of everything stopped and a boss's big blow is stopped 92% of the
  time: the rule of before 14 October, the regen its stand-up shield. The rest is what holds
  it, and holds it in part. A guard at half a gauge closes it and keeps seven tenths of the
  gain on an elite (14.4%) and three fifths on a boss (26.3%), with the small fights a fifth
  dearer than on the honest shield, since the rest is then paid for a break that seldom stops
  anything.
- The scramble is rare and the bot does not answer it. A blow finds a shield at rest once an
  elite's fight and three and a half times a boss's. The bot spends about a third fewer
  dice on the Armoured basic under the rule than without it: 2 off a blow of 15 on a
  bare hull is not worth a die, and fewer blows reach a hull at all. So on the bot's play
  the rule makes killing first more right, his read of 10 November over again, and the
  rest's cost is paid in hull and not in a decision. What a scramble would be spent on is a
  Barrier or a lure, and the bot plans no round but this one; his play is the read of it.
- By the rest's length: one round is too kind (a boss 14.5%), three is near two (22.3% to
  18.5%), and the rest alone with the honest arithmetic costs a tenth to a quarter more than
  the honest shield in every kind of fight.

Method: the fight-at-its-rating probe and the ledger of the sections above, the engine's
switches set for the run, and a fight that counts each blow as it lands (what the shield
took, what reached the hull, what a break stopped, the shield as it stood, whether it was at
rest). The Jack in the Halo's slot is the Halo Projector's entry replaced in memory by the
Shoring Jack's. The honest rows reproduce the sections above to the decimal (19.8% and 37.7%;
9.5% and 21.4%). Scratch probes, not in the repository.

## 13 November, the reboot: each fight at its rating under the what-if, a first read

Ryan, 13 November, of the reboot he ruled that day (the refit brief's section 22): "the
overheat damage stacks, damages the hull every turn for the total stacks, and keeps building
until the player is essentially forced to reboot, or die."

The decision it informs: none. It is a first look at the rule as built, for his play of its
trial. Two things stand over every number here. Today's foes were built for another rule,
their blows sized against a shield that refills (12 November), so this says what they do to
the reboot and never whether the reboot is right (`CLAUDE.md`, the fundamentals' rule). And
the fight bot's play of it is a first cut (`Policy._reboot_first`, `_reboot_idle`): it
reboots where it must and reads the foes' picks crudely, so its cost is a floor of skill.

As read: `Skirmish.reboot` on, content as it stands with the Barrier basic on the stock dice,
the six tier ones, the fight bot (greedy), each fight at its rating as in the sections above
(six squads and five seeds for a flanker, a hunter and a formation; five squads of four and
four seeds for an elite and a boss), beside the same read as built (13 November's content
row). A share of a four's hull. Each a direction.

| The fight | As built | Its rounds | Under the reboot | Its rounds | Won | Reboots a machine a fight |
|---|---|---|---|---|---|---|
| A lone flanker | 2.8% | 4.3 | 6.8% | 5.5 | 96% | 1.1 |
| A hunter's pack | 6.3% | 4.0 | 11.6% | 5.3 | 100% | 1.1 |
| A formation | 5.9% | 4.5 | 10.7% | 6.0 | 100% | 1.0 |
| An elite | 9.5% | 4.8 | 14.8% | 6.1 | 100% | 0.9 |
| A boss | 21.4% | 8.1 | 37.1% | 10.8 | 93% | 1.6 |

Wrecks a fight, an elite's and a boss's: 0.03 and 0.19 as built, 0.10 and 0.58 under the
reboot; the bosses' fights won 98% as built. The burn took 0.2 hull a fight at most: the bot
all but never fires past its maximum. A machine gives a turn in five to seven to a reboot.

By fight, as built and under the reboot:

| The elite | As built | Under the reboot | Its rounds |
|---|---|---|---|
| The shaman's warband | 7.7% | 18.1% | 5.0 |
| The Nob | 17.0% | 21.4% | 6.4 |
| The Old Man's rising | 17.8% | 19.9% | 8.0 |
| The Pilgrim's wake | 2.4% | 6.3% | 6.0 |
| The Rust Monster | 2.9% | 4.6% | 4.4 |
| Gilgamesh | 7.9% | 13.7% | 8.6 |
| The Fell Rider | 6.7% | 11.0% | 4.5 |
| The Reaper | 0.5% | 0.7% | 3.8 |
| The Wild Hunt | 12.7% | 22.9% | 5.7 |
| The Cinder Tortoise's brood | 16.4% | 24.6% | 9.5 |
| The Thunder Ape | 13.1% | 19.7% | 5.6 |

| The boss | As built | Under the reboot | Its rounds | Won |
|---|---|---|---|---|
| Floraison | 20.0% | 34.2% | 8.0 | 100% |
| King Gel | 15.0% | 26.5% | 8.7 | 100% |
| The Mantis Ant | 8.6% | 14.6% | 7.8 | 100% |
| The Ruby Colossus | 24.8% | 61.0% | 13.4 | 65% |
| The Fallen Weapon | 22.7% | 48.7% | 11.1 | 85% |
| The Emperor Scorpion | 24.8% | 40.7% | 10.4 | 90% |
| The Matador | 16.7% | 24.7% | 8.7 | 100% |
| The Phantom Train | 26.7% | 52.0% | 15.8 | 95% |
| The Vampire Lord | 5.3% | 16.9% | 8.2 | 95% |
| The Marsh Serpent | 11.3% | 29.3% | 7.1 | 100% |
| The Gargantuan King | 38.3% | 32.5% | 20.9 | 85% |
| The Fiend of Fire | 33.1% | 56.2% | 9.2 | 100% |
| The Obsidian Tyrant | 31.5% | 44.7% | 11.2 | 95% |

What it says:

- Every fight costs more, 1.6 to 2.4 times its hull, and runs a quarter to a third longer in
  rounds. The model of section 21 had the length, a third longer, and had the cost closer:
  the game's foes lean on the regen their blows were sized against more than the model's did.
- The fights of every day roughly double: a formation 10.7% where the budget's anchor has it
  at 5.9%. The foes' numbers would be tuned again under the rule, as they were for the regen.
- The long fights grow longest: the Gargantuan King 20.9 rounds, the Phantom Train 15.8, the
  Ruby Colossus 13.4 with a third of its fights lost. A boss's fight is where a squad reboots
  most, 1.6 times a machine. The Gargantuan King is the one fight that costs less, 32.5%
  where it costs 38.3%: the long fight where a reset outdoes a regen, as the model had it.
- No fight stalls, and the bot never burns for a shot: the rule plays to the end as built.

Not read: the Barrier basic off the dice under the reboot (the Barrier is the reboot's cover
by his fourth ruling, so its place moves with this), the second battle whole, and any tier
past one. Each on his word.

## 14 November, the stock basics by the fodder's health: the roster counted, and a model apart from content

Ryan's logic of the day (the refit brief's section 23): the vanilla gun one under the
standard fodder's hit points, riders paid in damage, the gun that deals one more paid in
heat. Two reads, neither a fight of the game's.

**The roster, counted** (content of 14 November: the ten tier-one formations, 69 foes; a
foe's hit points and plate against a gun's number, one shot at a time, nothing else).

| A gun of | Kills in one shot | In two | In three | In four or more |
|---|---|---|---|---|
| 2, today's vanilla | 10% | 70% | 12% | 9% |
| 3 | 23% | 71% | none | 6% |
| 4 | 80% | 14% | none | 6% |
| 5 | 88% | 6% | none | 6% |

The slots: 23% thin (2 or 3 hit points), 57% a plain 4, 3% a 4 behind a point of plate, 12%
thick (5 or 6), 6% a big plated one (14 to 20). By domain, in one shot: a gun of 3 none of
the Meadow's or the Peak's, half the Waste's and 45% of the Marsh's; a gun of 4, 77%, 62%,
93% and 85%.

**The model** (`python3 tools/basics_model.py`; three machines, one gun a round each, a foe
dead before the foes' turn strikes nobody, heat under the reboot at a maximum of 12; no dice
but in its last table, no reach, shield or riders). Rounds to clear and blows taken, heat
left out:

| The pack | A gun of 2 | A gun of 3 | A gun of 4 |
|---|---|---|---|
| Eight thin, 3 | 6 rounds, 57 | 3 rounds, 21 | 3 rounds, 21 |
| Eight standard, 4 | 6 rounds, 76 | 6 rounds, 76 | 3 rounds, 28 |
| Six thick, 6 | 6 rounds, 60 | 4 rounds, 40 | 4 rounds, 40 |
| Six of 4 behind a point of plate | 8 rounds, 72 | 4 rounds, 30 | 4 rounds, 30 |
| A big plated one, three standard, three thin | 10 rounds, 101 | 6 rounds, 55 | 4 rounds, 30 |

Blows taken under the reboot, with the blows that land while the squad stands bare:

| The pack | 3 for 3 heat | 4 for 4 heat | 4 for 6 | 4 for 8 | 4 for 12 |
|---|---|---|---|---|---|
| Eight thin | 21 | 21 | 21 | 36 (15 bare) | 36 (15) |
| Eight standard | 84 (8) | 28 | 28 | 48 (20) | 48 (20) |
| Six thick | 40 | 40 | 52 (12) | 72 (32) | 72 (32) |
| Six plated | 30 | 30 | 39 (9) | 54 (24) | 54 (24) |
| The mixed pack | 62 (7) | 30 | 37 (7) | 53 (23) | 53 (23) |

One machine of the three changed, heat left out, 4,000 fights a cell, eight standard foes
and a vanilla of 3: 76 blows on plain dice, 71 with one of its six entries dealing one more,
66 with two, 64 with every weapon of its dealing one more from the second round; with a
vanilla of 2, 76 in every column. An entry in one of six shows on 17% of its machine's turns,
31% with one reroll given it, 42% with two.

What they say: against a foe of 4 a gun of 2 and a gun of 3 are one gun, and the third point
earns its place on everything else; the step from 3 to 4 is a cliff on a roster that sits on
one number; no heat under the maximum makes the gun of 4 the vanilla's equal against
standard fodder, and any heat over the vanilla's is a loss where its point crosses nothing;
a lasting point on every weapon is worth two entries and more, and nothing with the vanilla
at 2. What they do not say: what a fight of the game's costs, which is the anchor's read once
a number moves.

## 14 November, the basics on dials: tier one's fights under the reboot, the vanilla a point up and the heat down

Ryan's "Sure, let's try it" on a dial for the vanilla's number and heat (the refit brief's
section 23). Each fight at its rating, tier one at Convergence 1, the six certain tier ones
(the Honey Badger, the Skua, the Storm Petrel, the Prairie Dog, the Cassowary, the
Cottonmouth), six squads and five seeds a fight, the greedy rung with its first play of the
reboot, `Skirmish.reboot` on; the what-if's `basics`, `hotter` and `top` (scratch probe, the
battle's own builders). 30 fights a cell: a direction. Rounds, and hull lost as a share of a
squad of four's.

| The basics | A lone flanker (4 fights) | A hunter's pack (2) | A formation (10) | Reboots a machine a fight, a formation | The burn a fight |
|---|---|---|---|---|---|
| As built: 2 for 4 heat, the Laser Carbine 3 for 5 | 96% won, 5.5 rounds, 6.8% | 100%, 5.3, 11.6% | 100%, 6.0, 10.7% | 1.02 | 0.19 |
| `hotter=-1` | 96%, 5.4, 6.6% | 100%, 5.1, 11.8% | 100%, 5.5, 9.9% | 0.77 | 0.14 |
| `hotter=-2` | 96%, 5.4, 6.9% | 100%, 5.2, 11.6% | 100%, 5.0, 8.8% | 0.58 | 0.04 |
| `basics=1`: 3 for 4, the Carbine 4 for 5 | 100%, 4.5, 5.1% | 98%, 4.6, 9.3% | 100%, 5.1, 9.4% | 0.85 | 0.21 |
| `basics=1,hotter=-1` | 100%, 4.5, 4.9% | 98%, 4.5, 9.2% | 100%, 4.7, 8.1% | 0.64 | 0.10 |
| `basics=1,hotter=-2` | 100%, 4.5, 5.1% | 100%, 4.5, 9.6% | 100%, 4.5, 7.9% | 0.48 | 0.03 |
| `basics=1,hotter=-1,top=2`: the Carbine 4 for 6 | 100%, 4.5, 5.0% | 98%, 4.6, 9.7% | 100%, 4.8, 8.4% | 0.69 | 0.11 |
| `basics=1,hotter=-1,top=4`: the Carbine 4 for 8 | 100%, 4.4, 5.0% | 98%, 4.7, 10.0% | 100%, 5.0, 8.8% | 0.74 | 0.18 |

By fight, rounds and hull, as built and with the point of damage alone: the goblin horde 5.2
and 6.8% to 4.9 and 5.9%; the treant's grove 7.5 and 12.9% to 6.2 and 12.8%; the gel wall
7.5 and 15.2% to 7.3 and 18.8%; the needler thicket 3.6 and 6.2% to 3.3 and 6.2%; the
sandworm's ambush 5.8 and 10.7% to 4.9 and 9.7%; the grave throng 6.7 and 13.1% to 5.3 and
6.6%; the barrow mound 8.1 and 13.6% to 6.8 and 7.5%; the knights' vigil 4.2 and 5.1% to 3.2
and 4.5%; the ember pyre 5.2 and 11.4% to 4.8 and 11.5%; the magma vent 5.9 and 11.7% to 4.8
and 10.0%. The Laser Carbine is 10.5% of a formation's spends as built, 13.5% at 4 for 4
heat and 10.5% at 4 for 8.

The squads of four (five squads and four seeds a fight, 20 fights a cell):

| The basics | An elite (11 fights) | A boss (13) | Reboots a machine a fight: elite, boss |
|---|---|---|---|
| Before the reboot, as built (13 November's read) | 100% won, 4.8 rounds, 9.5% | 98%, 8.1, 21.4% | none |
| Under the reboot, as built (13 November's) | 100%, 6.1, 14.8% | 93%, 10.8, 37.1% | 0.89, 1.63 |
| `basics=1,hotter=-1` | 100%, 5.2, 11.1% | 99%, 8.7, 26.5% | 0.58, 1.12 |
| `basics=1,hotter=-2` | 100%, 4.9, 10.9% | 98%, 8.4, 23.6% | 0.36, 0.82 |

What it says: the point and the heat each take about a round off a formation and add to the
4.5 rounds a formation ran before the reboot (5.9% of a four's hull then); with both, an
elite and a boss stand within a round and a few points of hull of the anchor's, so most of
what the reboot added to tier one's fights was the basics themselves; a duel answers to
the point and not to the heat; the goblin horde barely moves for the point, the Marsh's
throng halves, the plated and the thick give a round; the top basic's heat is a slope. What
it does not say: whether a hold or a reboot is right, the bot's play being a floor; the gel
wall's rise is inside a cell's noise at 30 fights.

## 14 November, the rider and keyword pass: each rider on the vanilla, a gun's strikes, and the Barrier basic at a price

Ryan's "let's do the rider and keyword pass now" (`docs/vocabulary_pass_proposal.md`, whose
section 2 reads these). Each formation of tier one at its rating, Convergence 1, the six
certain tier ones as trios, six squads and five seeds a fight, the greedy rung, the reboot
on, the trial's basics (`basics=1,hotter=-1`: a vanilla of 3 for 3 heat). Every plain basic
gun, the Twin Autoguns, the Rivet Gun and the Ankle Mortar (which keeps its Indirect), is
replaced on every die by one test gun at 3 heat; the Laser Carbine and every fixed piece
stand as the trial has them (scratch probe, the battle's own builders). 30 fights a cell and
300 a row: a direction. Hull lost is a share of a squad of four's.

| The test gun | Won | Rounds | Hull | Reboots a machine | The foes' damage a fight | On shield, hull, a Barrier |
|---|---|---|---|---|---|---|
| A flat 1 | 99% | 6.0 | 12.4% | 0.91 | 38.8 | 51%, 31%, 14% |
| A flat 2 | 100% | 5.3 | 9.6% | 0.74 | 31.2 | 54%, 29%, 13% |
| A flat 3 | 100% | 4.7 | 8.1% | 0.64 | 25.6 | 57%, 30%, 9% |
| A flat 4 | 100% | 4.1 | 6.6% | 0.53 | 21.8 | 61%, 29%, 6% |
| A flat 5 | 100% | 3.9 | 6.4% | 0.48 | 21.0 | 62%, 29%, 5% |
| 1 three times | 100% | 4.8 | 8.4% | 0.67 | 26.5 | 57%, 30%, 9% |
| 2 twice | 100% | 4.2 | 6.8% | 0.53 | 21.9 | 61%, 30%, 6% |
| 1 four times | 100% | 4.3 | 7.1% | 0.56 | 22.7 | 59%, 30%, 7% |
| 3, Burn 2 | 100% | 3.9 | 6.4% | 0.48 | 21.0 | 61%, 29%, 6% |
| 3, Flak 1 | 100% | 4.4 | 7.6% | 0.59 | 24.7 | 59%, 29%, 7% |
| 3, Shock | 100% | 4.3 | 7.6% | 0.57 | 24.1 | 61%, 30%, 5% |
| 3, Spread 1 | 100% | 4.2 | 5.8% | 0.52 | 20.8 | 62%, 27%, 7% |
| 3, Splash 1 | 100% | 4.0 | 5.3% | 0.46 | 19.6 | 63%, 26%, 7% |
| 3, Penetrate 2 | 100% | 4.1 | 5.3% | 0.49 | 19.9 | 63%, 25%, 8% |
| 3, Breach | 100% | 4.4 | 7.6% | 0.60 | 24.3 | 59%, 30%, 8% |
| 3, Chain 2 | 100% | 4.7 | 8.1% | 0.64 | 25.6 | 57%, 30%, 9% |
| 3, Sap 1 | 100% | 4.6 | 6.7% | 0.60 | 23.1 | 61%, 28%, 8% |
| 3, Cryo 1 | 100% | 4.6 | 8.0% | 0.59 | 25.5 | 57%, 30%, 9% |
| 3, Expose | 100% | 4.4 | 7.8% | 0.59 | 24.6 | 60%, 30%, 7% |
| 3, Lure | 100% | 4.9 | 7.9% | 0.71 | 26.8 | 61%, 28%, 8% |
| 3, Purge 1 | 100% | 4.7 | 8.1% | 0.64 | 25.6 | 57%, 30%, 9% |
| 3, Disrupt | 100% | 5.2 | 7.9% | 0.73 | 25.0 | 60%, 30%, 6% |
| 3, Suppress | 100% | 4.8 | 6.3% | 0.62 | 20.4 | 63%, 29%, 5% |
| 2, Burn 2 | 100% | 4.3 | 7.7% | 0.55 | 24.3 | 59%, 30%, 8% |
| 2, Flak 1 | 100% | 5.0 | 9.1% | 0.70 | 29.1 | 56%, 30%, 11% |
| 2, Shock | 100% | 4.6 | 9.1% | 0.64 | 27.5 | 58%, 32%, 7% |
| 2, Spread 1 | 100% | 4.7 | 6.7% | 0.61 | 24.0 | 59%, 27%, 11% |
| 2, Splash 1 | 100% | 4.5 | 6.1% | 0.57 | 22.6 | 61%, 26%, 9% |
| 2, Breach | 100% | 4.9 | 8.9% | 0.67 | 29.1 | 57%, 29%, 10% |
| 2, Sap 1 | 100% | 5.3 | 8.5% | 0.71 | 27.2 | 58%, 29%, 9% |
| 2, Cryo 1 | 100% | 5.2 | 9.5% | 0.69 | 30.8 | 54%, 29%, 13% |

By fight, rounds and hull:

| The test gun | Goblin horde | Treant's grove | Gel wall | Needler thicket | Sandworm's ambush | Grave throng | Barrow mound | Knights' vigil | Ember pyre | Magma vent |
|---|---|---|---|---|---|---|---|---|---|---|
| A flat 1 | 5.7, 7.7% | 7.6, 14.2% | 8.0, 20.8% | 4.2, 10.5% | 5.3, 12.1% | 6.8, 16.0% | 7.8, 11.4% | 4.0, 6.8% | 5.3, 14.0% | 5.5, 10.8% |
| A flat 2 | 4.8, 5.6% | 7.0, 10.9% | 6.9, 14.6% | 3.2, 6.0% | 5.0, 9.1% | 5.8, 11.7% | 7.0, 11.0% | 3.6, 5.7% | 4.9, 11.2% | 5.1, 10.3% |
| A flat 3 | 4.4, 5.0% | 5.9, 10.6% | 6.9, 15.8% | 3.0, 6.0% | 3.9, 8.5% | 5.0, 5.6% | 5.9, 7.4% | 2.9, 4.2% | 4.6, 8.9% | 4.4, 9.1% |
| A flat 4 | 3.4, 1.3% | 5.3, 9.0% | 6.6, 13.0% | 2.9, 6.6% | 3.5, 8.5% | 4.5, 4.8% | 5.2, 6.3% | 2.3, 2.3% | 3.9, 5.8% | 3.9, 8.4% |
| A flat 5 | 3.4, 1.3% | 4.7, 8.5% | 6.5, 15.3% | 2.9, 6.6% | 3.2, 7.7% | 4.5, 4.8% | 4.8, 5.5% | 2.0, 1.0% | 3.8, 5.1% | 3.4, 7.8% |
| 1 three times | 4.7, 5.7% | 6.3, 10.9% | 6.9, 15.8% | 3.0, 6.0% | 4.1, 8.8% | 5.0, 5.7% | 5.7, 6.9% | 3.5, 6.2% | 4.5, 8.4% | 4.3, 9.5% |
| 2 twice | 3.4, 1.3% | 5.2, 8.8% | 6.5, 13.8% | 2.9, 6.6% | 3.9, 8.4% | 4.5, 4.8% | 5.1, 6.9% | 2.5, 3.2% | 3.9, 5.8% | 3.8, 8.4% |
| 1 four times | 3.6, 1.5% | 5.5, 8.9% | 6.5, 13.8% | 2.9, 6.6% | 3.9, 8.6% | 4.5, 4.8% | 5.2, 6.7% | 3.2, 5.7% | 3.9, 5.8% | 4.0, 8.5% |
| 3, Burn 2 | 3.6, 2.4% | 4.7, 7.4% | 6.5, 15.8% | 2.9, 6.0% | 3.2, 7.7% | 3.9, 2.9% | 4.2, 4.1% | 2.4, 3.1% | 4.1, 7.1% | 3.3, 7.7% |
| 3, Flak 1 | 4.4, 4.4% | 5.3, 10.3% | 6.8, 14.6% | 3.0, 6.0% | 3.5, 8.2% | 5.0, 5.5% | 5.3, 6.5% | 2.7, 3.2% | 4.5, 9.3% | 3.7, 8.5% |
| 3, Shock | 4.5, 4.7% | 5.0, 9.9% | 6.9, 16.4% | 3.1, 6.0% | 3.1, 6.6% | 5.1, 5.5% | 4.4, 6.4% | 2.6, 3.6% | 4.6, 9.0% | 3.3, 8.3% |
| 3, Spread 1 | 3.7, 1.5% | 5.7, 9.8% | 5.7, 6.5% | 2.8, 5.1% | 4.0, 8.9% | 4.2, 2.7% | 5.8, 5.6% | 2.6, 4.7% | 4.0, 5.0% | 3.6, 8.2% |
| 3, Splash 1 | 3.5, 2.1% | 5.7, 9.6% | 5.3, 4.6% | 2.8, 5.2% | 4.2, 9.2% | 3.8, 2.1% | 5.7, 4.9% | 2.3, 3.5% | 3.4, 3.4% | 3.7, 8.8% |
| 3, Penetrate 2 | 3.5, 1.4% | 5.7, 10.1% | 4.7, 2.7% | 2.7, 3.7% | 3.8, 7.3% | 3.9, 2.5% | 5.9, 6.5% | 2.2, 3.3% | 4.0, 6.6% | 4.1, 9.0% |
| 3, Breach | 4.4, 5.2% | 5.5, 10.8% | 6.9, 15.8% | 3.0, 6.0% | 3.4, 7.8% | 5.0, 5.6% | 5.0, 5.3% | 2.7, 3.6% | 4.6, 8.9% | 3.7, 7.4% |
| 3, Chain 2 | 4.4, 5.0% | 5.9, 10.6% | 6.9, 15.8% | 3.0, 6.0% | 3.9, 8.5% | 5.0, 5.6% | 5.9, 7.4% | 2.9, 4.2% | 4.6, 8.9% | 4.4, 9.1% |
| 3, Sap 1 | 4.2, 3.2% | 5.9, 9.4% | 6.6, 14.2% | 3.0, 5.3% | 4.1, 6.9% | 4.6, 3.7% | 5.7, 4.7% | 2.7, 3.6% | 4.5, 8.5% | 4.2, 7.9% |
| 3, Cryo 1 | 4.3, 5.2% | 5.9, 10.6% | 6.8, 15.8% | 3.0, 6.0% | 3.8, 8.4% | 4.9, 5.6% | 5.9, 7.6% | 2.8, 4.1% | 4.5, 8.4% | 4.1, 8.3% |
| 3, Expose | 4.3, 4.5% | 5.5, 12.4% | 6.6, 13.8% | 3.0, 6.0% | 3.3, 8.0% | 5.0, 5.7% | 5.2, 6.7% | 2.6, 3.1% | 4.5, 9.9% | 3.5, 8.2% |
| 3, Lure | 4.5, 4.8% | 6.4, 8.8% | 6.9, 16.2% | 3.0, 6.0% | 4.1, 8.5% | 5.0, 5.8% | 6.6, 7.1% | 2.9, 4.2% | 4.7, 8.6% | 4.4, 9.0% |
| 3, Purge 1 | 4.4, 5.0% | 5.9, 10.6% | 6.9, 15.8% | 3.0, 6.0% | 3.9, 8.6% | 5.0, 5.6% | 5.8, 7.3% | 2.9, 4.2% | 4.6, 8.9% | 4.4, 9.1% |
| 3, Disrupt | 4.4, 3.1% | 6.9, 11.0% | 6.7, 13.7% | 3.1, 5.9% | 5.6, 9.3% | 5.1, 5.7% | 8.3, 9.4% | 3.6, 3.0% | 4.3, 10.0% | 4.4, 8.2% |
| 3, Suppress | 4.3, 2.2% | 6.5, 7.0% | 6.8, 16.1% | 3.1, 5.9% | 3.9, 6.0% | 5.0, 4.0% | 6.4, 5.5% | 2.8, 2.2% | 4.9, 8.0% | 4.5, 6.5% |
| 2, Burn 2 | 4.0, 2.9% | 5.0, 9.9% | 6.7, 14.1% | 3.1, 5.9% | 3.6, 8.0% | 4.7, 7.0% | 4.9, 6.6% | 2.9, 4.7% | 4.4, 10.3% | 3.6, 7.5% |
| 2, Flak 1 | 4.9, 5.2% | 5.9, 10.8% | 7.0, 14.2% | 3.1, 6.0% | 4.1, 8.6% | 5.9, 11.4% | 6.1, 8.9% | 3.3, 5.4% | 5.0, 11.8% | 4.5, 9.0% |
| 2, Shock | 4.7, 6.0% | 5.4, 10.7% | 6.6, 13.8% | 3.2, 6.0% | 3.4, 7.6% | 5.5, 11.2% | 5.4, 9.4% | 3.3, 5.7% | 5.0, 12.6% | 3.7, 8.3% |
| 2, Spread 1 | 4.2, 2.9% | 6.5, 9.7% | 5.5, 6.4% | 2.8, 5.0% | 4.8, 9.5% | 4.4, 4.5% | 6.4, 7.2% | 3.2, 4.6% | 4.5, 8.1% | 4.3, 9.0% |
| 2, Splash 1 | 3.9, 2.7% | 6.1, 7.0% | 5.1, 6.1% | 2.8, 4.4% | 4.9, 9.9% | 4.4, 4.0% | 6.4, 7.4% | 2.8, 3.7% | 4.3, 7.0% | 4.2, 9.0% |
| 2, Breach | 4.5, 4.9% | 6.0, 11.0% | 6.9, 14.6% | 3.2, 6.0% | 3.8, 8.0% | 5.8, 11.7% | 6.3, 9.6% | 3.1, 3.4% | 4.9, 11.2% | 4.3, 9.0% |
| 2, Sap 1 | 4.8, 4.8% | 7.0, 11.9% | 6.9, 12.7% | 3.0, 5.3% | 5.3, 7.2% | 5.7, 10.4% | 7.1, 8.1% | 3.3, 5.0% | 4.8, 11.8% | 4.8, 7.6% |
| 2, Cryo 1 | 4.7, 5.6% | 6.9, 10.8% | 6.9, 14.5% | 3.2, 6.0% | 4.6, 8.9% | 5.7, 11.6% | 6.8, 11.1% | 3.5, 5.6% | 4.8, 10.9% | 4.9, 9.7% |

The squads of four against the Barrier basic at a price (five squads and four seeds a fight,
20 fights a cell; `basics=1,hotter=-1` throughout, the first row the read of the basics on
dials above):

| The Barrier basic | An elite (11 fights) | A boss (13) | Reboots a machine: elite, boss | The foes' damage a fight, and a Barrier's share: elite, boss | Its spends a fight: elite, boss |
|---|---|---|---|---|---|
| As built: no heat, sits out a round | 100% won, 5.2 rounds, 11.1%, 0.03 wrecks | 99%, 8.7, 26.5%, 0.22 wrecks | 0.58, 1.12 | 53.4 and 48%, 106.6 and 46% | 2.66, 5.17 |
| `barrier=heat3`: the same at 3 heat | 100%, 5.4, 12.7%, 0.05 | 99%, 9.0, 31.7%, 0.31 | 0.75, 1.52 | 56.3 and 45%, 113.0 and 39% | 2.52, 4.61 |
| `barrier=none`: the Armoured basic in its slot | 100%, 5.1, 24.6%, 0.23 | 92%, 8.4, 46.8%, 0.90 | 0.72, 1.34 | 50.0 and none, 102.3 and none | none; the Shoring Jack 1.62, 3.73 |

A formation with the Barrier basic at 3 heat: 100% won, 4.7 rounds, 8.3% (8.1% as built),
0.68 reboots a machine (0.64), a Barrier 8% of the foes' damage (9%), 0.54 spends a fight
(0.63).

What it says: a point of a flat gun is worth most where it crosses the kill line, 3 to 4
(0.6 rounds, 1.5 points of hull) against 4 to 5 (0.2 and 0.2); a gun of 2 twice runs as a
straight 4 but against the knights behind plate, and 1 four times falls under the vanilla
there; Burn 2 and the area chips of 1 read highest, by a point to two in rounds and more in
hull; Flak 1, Shock, Breach and Expose read as nothing in the four hordes and match or beat
a flat 4 in the four fights with a massive behind plate; Sap 1 reads in hull alone; Cryo 1,
Chain 2 and Purge 1 read as the vanilla; the gel wall answers to area and not to a gun's
number; the Barrier basic takes nearly half of an elite's and a boss's damage, a vanilla
shot's heat changes its use by a tenth, and without it an elite costs 2.2 times the hull and
a boss 1.8 times. What it does not say: what a rider is worth to a player who plans a second
spend, the greedy rung laying Shock, Flak and Expose without aiming to cash them; anything
of Lure, Disrupt or Suppress, read here on every gun of a squad at once; a duel, an elite or
a boss for the riders; a difference under 0.2 rounds or half a point of hull.

## 14 November, the vocabulary pass's second round: the unit riders, a horde by its hit points and plate, the foes' riders on the standard blow, Burning as erosion, and the Barrier by cooldown and by the spike

Ryan's second round on the pass (`docs/vocabulary_pass_proposal.md`, his words there): "Why
measure penetrate 2, burn 2, and not 1?", "Should we still be considering +2?", "I want to
examine enemy riders as well", Burn on a machine as "a DoT that hits both meters", and the
Barrier basic, "I'm really not sure how to unwind it from the data". The same squads, basics
and probe as the entry above: the six certain tier ones, the greedy rung, the reboot on,
`basics=1,hotter=-1`, hull as a share of a squad of four's. All a direction.

**The unit riders, and a second number for each** (every plain basic gun replaced by the test
gun at 3 heat; ten formations, 300 fights a row):

| The test gun | Won | Rounds | Hull | Wrecks a fight | Reboots a machine | The overheat's burn a fight | The foes' damage a fight | On shield, hull, a Barrier |
|---|---|---|---|---|---|---|---|---|
| 3, Burn 1 | 100% | 4.2 | 7.1% | 0.00 | 0.53 | 0.04 | 22.9 | 59%, 30%, 8% |
| 3, Burn 3 | 100% | 3.7 | 6.5% | 0.00 | 0.45 | 0.04 | 20.4 | 62%, 30%, 4% |
| 3, Penetrate 1 | 100% | 4.4 | 6.9% | 0.00 | 0.57 | 0.07 | 23.2 | 61%, 28%, 7% |
| 3, Spread 2 | 100% | 3.7 | 4.1% | 0.00 | 0.39 | 0.00 | 16.2 | 66%, 24%, 7% |
| 3, Splash 2 | 100% | 3.2 | 2.8% | 0.00 | 0.26 | 0.00 | 12.2 | 67%, 22%, 8% |
| 3, Flak 2 | 100% | 4.2 | 7.4% | 0.00 | 0.56 | 0.06 | 23.5 | 61%, 30%, 5% |
| 3, Sap 2 | 100% | 4.7 | 6.4% | 0.00 | 0.61 | 0.17 | 21.4 | 63%, 28%, 6% |
| 3, Cryo 2 | 100% | 4.6 | 7.9% | 0.00 | 0.57 | 0.07 | 25.3 | 58%, 30%, 9% |
| 2, Burn 1 | 100% | 4.8 | 8.9% | 0.00 | 0.63 | 0.10 | 27.6 | 56%, 31%, 11% |
| 2, Penetrate 1 | 100% | 5.0 | 8.1% | 0.00 | 0.67 | 0.05 | 27.4 | 56%, 28%, 12% |
| 2, Penetrate 2 | 100% | 4.4 | 6.0% | 0.00 | 0.57 | 0.04 | 22.5 | 61%, 26%, 10% |
| 1, Burn 1 | 100% | 5.4 | 10.9% | 0.01 | 0.76 | 0.09 | 33.5 | 52%, 31%, 13% |
| 1, Burn 2 | 100% | 4.8 | 9.6% | 0.00 | 0.65 | 0.06 | 29.5 | 54%, 31%, 11% |
| 1, Spread 1 | 100% | 5.1 | 7.6% | 0.00 | 0.69 | 0.08 | 27.3 | 56%, 26%, 14% |
| 1, Splash 1 | 100% | 4.9 | 7.3% | 0.00 | 0.67 | 0.06 | 26.6 | 57%, 26%, 12% |
| 1, Shock | 100% | 5.4 | 12.0% | 0.03 | 0.79 | 0.10 | 34.8 | 53%, 33%, 10% |

| The test gun | Goblin horde | Treant's grove | Gel wall | Needler thicket | Sandworm's ambush | Grave throng | Barrow mound | Knights' vigil | Ember pyre | Magma vent |
|---|---|---|---|---|---|---|---|---|---|---|
| 3, Burn 1 | 4.0, 3.1% | 5.4, 10.5% | 6.7, 15.2% | 3.0, 6.0% | 3.5, 8.2% | 3.9, 3.1% | 4.9, 5.1% | 2.5, 3.7% | 4.2, 8.5% | 3.7, 7.8% |
| 3, Burn 3 | 3.5, 2.8% | 4.2, 8.2% | 6.7, 18.6% | 2.9, 6.1% | 3.0, 7.8% | 4.0, 2.9% | 3.9, 4.3% | 2.4, 2.2% | 3.7, 4.5% | 3.0, 7.5% |
| 3, Penetrate 1 | 4.1, 2.9% | 5.9, 9.2% | 6.2, 12.2% | 2.8, 5.3% | 3.9, 7.8% | 4.4, 4.0% | 5.6, 7.1% | 2.5, 3.7% | 4.3, 7.0% | 4.2, 9.3% |
| 3, Spread 2 | 3.3, 1.3% | 5.5, 8.6% | 4.0, 1.6% | 2.3, 1.5% | 3.3, 5.3% | 3.4, 0.9% | 5.5, 4.8% | 2.3, 3.9% | 3.4, 4.0% | 3.5, 8.6% |
| 3, Splash 2 | 2.8, 0.8% | 5.1, 5.2% | 3.4, 0.2% | 2.0, 0.9% | 3.2, 4.3% | 2.2, 0.1% | 4.8, 4.2% | 2.1, 3.4% | 2.7, 1.0% | 3.3, 7.6% |
| 3, Flak 2 | 4.3, 4.2% | 5.1, 11.5% | 6.7, 14.8% | 3.0, 6.0% | 2.9, 6.5% | 5.0, 5.4% | 4.1, 5.6% | 2.7, 3.5% | 4.6, 9.1% | 3.3, 7.2% |
| 3, Sap 2 | 4.4, 4.0% | 6.2, 7.8% | 6.7, 15.6% | 3.0, 4.8% | 4.0, 5.6% | 4.7, 3.6% | 6.3, 3.5% | 2.7, 3.3% | 4.5, 8.3% | 4.4, 7.2% |
| 3, Cryo 2 | 4.3, 4.9% | 5.8, 10.5% | 6.8, 15.8% | 3.0, 6.0% | 3.8, 8.4% | 4.9, 5.6% | 5.9, 7.5% | 2.7, 4.0% | 4.4, 8.4% | 4.0, 8.2% |
| 2, Burn 1 | 4.5, 5.3% | 5.8, 10.9% | 6.8, 15.0% | 3.1, 6.0% | 3.8, 8.6% | 5.0, 9.2% | 6.2, 8.9% | 3.3, 5.4% | 4.7, 11.5% | 4.4, 8.6% |
| 2, Penetrate 1 | 4.4, 4.3% | 6.7, 10.0% | 6.1, 10.8% | 3.0, 5.0% | 4.9, 8.8% | 4.9, 8.1% | 6.8, 8.5% | 3.1, 4.9% | 4.7, 9.7% | 5.1, 10.4% |
| 2, Penetrate 2 | 4.1, 2.5% | 6.0, 9.1% | 4.9, 3.6% | 2.7, 3.7% | 4.4, 7.9% | 4.2, 4.7% | 6.1, 6.8% | 2.6, 3.8% | 4.5, 8.7% | 4.7, 9.5% |
| 1, Burn 1 | 4.9, 6.7% | 6.8, 12.8% | 7.7, 19.4% | 3.9, 9.6% | 5.0, 11.6% | 5.8, 11.9% | 6.3, 9.2% | 3.6, 5.9% | 5.0, 12.5% | 4.9, 9.6% |
| 1, Burn 2 | 4.4, 5.1% | 5.7, 10.9% | 7.3, 18.2% | 3.7, 9.4% | 4.2, 10.7% | 5.0, 9.0% | 5.5, 7.4% | 3.4, 5.5% | 4.8, 11.6% | 4.0, 8.4% |
| 1, Spread 1 | 4.6, 4.2% | 7.1, 11.7% | 5.5, 6.5% | 3.5, 6.2% | 4.7, 9.9% | 4.8, 4.1% | 7.1, 9.8% | 3.8, 5.5% | 4.9, 9.0% | 5.0, 9.3% |
| 1, Splash 1 | 4.7, 4.0% | 7.1, 11.3% | 5.3, 6.9% | 3.2, 5.4% | 4.7, 9.4% | 4.8, 4.4% | 7.0, 8.0% | 3.3, 5.0% | 4.6, 8.8% | 4.8, 9.4% |
| 1, Shock | 5.2, 7.9% | 6.3, 12.2% | 8.1, 21.5%, 97% won | 4.2, 10.5% | 4.3, 11.8% | 6.3, 13.7% | 5.8, 11.8% | 3.9, 6.3% | 5.1, 14.0% | 4.6, 9.9% |

**A horde by its hit points and its plate** (the goblin horde's grid, its goblins and
mandragoras each given the hit points and plate of the column, a blow of 3 and no move but
a blow; the test gun in every plain basic's place; six squads and twenty seeds, 120 fights a
cell; rounds and hull):

| The test gun | Eight plain 3s | Eight plain 4s | Eight plain 5s | Eight plain 6s | Eight of 3 behind a point of plate | Eight of 4 behind plate | Eight of 5 behind plate |
|---|---|---|---|---|---|---|---|
| A flat 1 |  | 5.2, 14.3% | 6.3, 21.1%, 99% won |  | 7.1, 23.2%, 93% won | 8.1, 31.8%, 88% won | 9.2, 39.4%, 78% won |
| A flat 2 | 4.5, 10.6% | 4.6, 11.4% | 5.4, 16.9% | 6.3, 21.5%, 98% won | 5.7, 16.4%, 99% won | 7.5, 25.8%, 97% won | 8.7, 33.4%, 91% won |
| A flat 3 | 3.7, 6.1% | 4.2, 10.0% | 4.9, 13.8% | 5.4, 17.1% | 5.1, 13.6% | 6.2, 21.2%, 99% won | 8.0, 30.5%, 96% won |
| A flat 4 | 3.7, 6.1% | 3.6, 6.2% | 4.6, 11.8% | 4.9, 14.1% | 3.9, 6.9% | 5.9, 18.8%, 98% won | 6.4, 22.7%, 99% won |
| A flat 5 | 3.7, 6.1% | 3.6, 6.2% | 4.0, 9.3% | 4.8, 13.8% | 3.9, 6.9% | 4.3, 9.9% | 6.3, 22.1% |
| 2 twice | 3.7, 6.1% | 3.6, 6.2% | 4.6, 11.8% | 4.9, 14.0% | 5.1, 13.6% | 6.0, 19.8%, 98% won | 7.7, 29.0%, 96% won |
| 1 four times | 3.7, 6.1% | 3.6, 6.2% | 4.6, 11.7% | 4.9, 14.1% | 6.2, 16.5% | 7.5, 25.8%, 95% won | 8.7, 32.7%, 92% won |
| 2, Spread 1 |  | 3.9, 6.6% | 4.5, 10.5% |  | 5.0, 12.4% | 6.8, 21.8%, 97% won | 8.1, 30.2%, 94% won |
| 3, Spread 1 | 3.4, 4.9% | 3.7, 6.2% | 4.2, 9.9% | 4.7, 12.6% | 4.8, 11.1% | 5.6, 17.1% | 7.3, 26.3%, 97% won |
| 2, Burn 1 |  | 4.4, 10.5% | 4.9, 13.5% |  | 4.9, 13.1%, 99% won | 6.7, 21.4%, 97% won | 7.8, 28.5%, 94% won |
| 3, Burn 1 | 3.3, 4.6% | 4.0, 8.8% | 4.6, 11.2% | 5.2, 15.0% | 4.5, 10.5% | 5.8, 18.1%, 99% won | 7.3, 25.2%, 98% won |
| 3, Breach |  | 4.2, 10.0% | 4.9, 13.8% |  | 3.7, 6.4% | 5.3, 15.3%, 99% won | 6.0, 20.8%, 98% won |

**The roster with every rank-and-file foe a hit point up** (the goblin, the mandragora, the
cockatrice, the ghost, the zombie knight, the bomb and the drake 5, the revenant 4, the
needler and the gel's half 3, the gel 6, the salamander 7; the massives as built; ten
formations, 300 fights a row):

| The test gun, the rank and file a hit point up | Won | Rounds | Hull | Wrecks a fight | Reboots a machine | The overheat's burn a fight | The foes' damage a fight | On shield, hull, a Barrier |
|---|---|---|---|---|---|---|---|---|
| A flat 2 | 100% | 6.2 | 13.3% | 0.02 | 1.02 | 0.14 | 40.6 | 52%, 31%, 12% |
| A flat 3 | 100% | 5.4 | 11.0% | 0.01 | 0.85 | 0.10 | 33.6 | 55%, 31%, 9% |
| A flat 4 | 100% | 5.0 | 9.5% | 0.00 | 0.75 | 0.14 | 29.3 | 58%, 30%, 7% |
| A flat 5 | 100% | 4.3 | 7.9% | 0.00 | 0.60 | 0.06 | 24.3 | 60%, 31%, 5% |
| 2 twice | 100% | 5.0 | 9.5% | 0.00 | 0.74 | 0.14 | 29.6 | 57%, 30%, 8% |
| 3, Spread 1 | 100% | 4.7 | 8.3% | 0.00 | 0.69 | 0.09 | 26.7 | 58%, 29%, 8% |
| 3, Burn 1 | 100% | 4.9 | 9.6% | 0.00 | 0.70 | 0.15 | 29.2 | 57%, 31%, 8% |
| 3, Burn 2 | 100% | 4.3 | 7.9% | 0.00 | 0.57 | 0.08 | 25.0 | 60%, 30%, 6% |

| The test gun, the rank and file a hit point up | Goblin horde | Treant's grove | Gel wall | Needler thicket | Sandworm's ambush | Grave throng | Barrow mound | Knights' vigil | Ember pyre | Magma vent |
|---|---|---|---|---|---|---|---|---|---|---|
| A flat 2 | 5.6, 8.9% | 7.6, 17.6% | 8.8, 23.9% | 4.6, 11.0% | 5.4, 11.7% | 6.7, 12.5% | 7.4, 11.1% | 4.4, 7.7% | 6.1, 16.3% | 5.9, 12.1% |
| A flat 3 | 5.2, 8.1% | 6.9, 16.4% | 7.6, 17.5% | 3.6, 7.0% | 4.1, 8.9% | 5.8, 9.5% | 6.6, 10.5% | 3.8, 7.2% | 5.6, 14.3% | 5.0, 10.5% |
| A flat 4 | 4.6, 6.5% | 6.3, 13.0% | 7.5, 18.6% | 3.6, 6.8% | 4.0, 8.6% | 5.3, 5.2% | 5.6, 6.9% | 3.5, 5.2% | 5.2, 14.1% | 4.3, 9.5% |
| A flat 5 | 3.9, 3.4% | 5.0, 11.5% | 7.2, 17.5% | 3.3, 7.4% | 3.4, 8.4% | 4.5, 3.9% | 4.9, 5.3% | 2.5, 4.0% | 4.4, 8.8% | 3.7, 8.6% |
| 2 twice | 4.7, 6.5% | 6.5, 13.3% | 7.5, 18.6% | 3.6, 6.8% | 3.9, 8.6% | 5.3, 5.2% | 5.6, 7.6% | 3.7, 6.5% | 5.0, 11.8% | 4.3, 10.0% |
| 3, Spread 1 | 4.2, 4.7% | 6.3, 12.5% | 6.0, 12.2% | 3.4, 5.2% | 4.1, 8.5% | 4.7, 4.9% | 6.1, 8.2% | 3.6, 6.7% | 4.7, 10.1% | 4.4, 10.0% |
| 3, Burn 1 | 4.5, 6.4% | 6.1, 13.3% | 7.3, 15.2% | 3.2, 5.0% | 3.9, 8.1% | 5.4, 8.8% | 5.7, 8.8% | 3.3, 6.2% | 5.2, 15.1% | 4.1, 9.1% |
| 3, Burn 2 | 4.0, 5.0% | 5.0, 9.7% | 7.0, 14.2% | 3.1, 4.8% | 3.3, 7.4% | 4.4, 5.3% | 4.5, 6.0% | 3.0, 5.9% | 5.0, 11.6% | 3.5, 8.8% |

**The foes' riders on the standard blow** (every rank-and-file foe of tier one's formations
carries the rider on its plain blow, beside what it already carries; the ladder is every
such foe's attack a point lighter to two heavier; the last three rows are a what-if in the
scratch probe, a machine's Burning taking shield then hull, past armour and Barrier, in
place of heat; ten formations, 300 fights a row):

| Every rank-and-file blow | Won | Rounds | Hull | Wrecks a fight | Reboots a machine | The overheat's burn a fight | The foes' damage a fight | On shield, hull, a Barrier |
|---|---|---|---|---|---|---|---|---|
| Every blow a point lighter | 100% | 4.5 | 4.0% | 0.00 | 0.49 | 0.06 | 16.6 | 66%, 23%, 9% |
| A point heavier | 99% | 4.8 | 13.7% | 0.05 | 0.75 | 0.09 | 36.4 | 50%, 36%, 10% |
| Two heavier | 95% | 5.0 | 20.9% | 0.22 | 0.85 | 0.10 | 47.7 | 44%, 43%, 10% |
| With Breach | 99% | 4.6 | 20.6% | 0.07 | 0.34 | 0.12 | 23.5 | 0%, 84%, 16% |
| With Burn 1, heat | 99% | 4.9 | 10.0% | 0.06 | 0.78 | 1.14 | 27.3 | 55%, 31%, 10% |
| With Burn 2, heat | 92% | 5.5 | 16.3% | 0.29 | 1.05 | 6.21 | 30.8 | 50%, 34%, 11% |
| With Scorch 1 | 100% | 4.8 | 8.3% | 0.00 | 0.69 | 0.09 | 26.3 | 57%, 30%, 9% |
| With Scorch 2 | 99% | 5.1 | 9.1% | 0.02 | 0.79 | 0.16 | 28.3 | 56%, 30%, 10% |
| With Disable | 100% | 4.9 | 8.7% | 0.00 | 0.67 | 0.08 | 27.1 | 57%, 30%, 9% |
| With Corrupt 1 | 96% | 4.9 | 15.6% | 0.20 | 0.83 | 0.09 | 27.9 | 49%, 38%, 9% |
| With Crush 1 | 94% | 4.7 | 15.4% | 0.21 | 0.70 | 0.02 | 37.0 | 46%, 41%, 9% |
| With Drain | 100% | 5.0 | 8.5% | 0.00 | 0.70 | 0.10 | 27.3 | 56%, 30%, 11% |
| With Burn 1, as erosion | 95% | 4.8 | 15.8% | 0.17 | 0.78 | 0.02 | 27.0 | 49%, 37%, 9% |
| With Burn 2, as erosion | 86% | 4.9 | 27.1% | 0.55 | 0.90 | 0.01 | 28.3 | 41%, 43%, 10% |
| Content as built, Burning as erosion | 100% | 4.7 | 8.5% | 0.00 | 0.64 | 0.06 | 25.6 | 57%, 31%, 9% |

| Every rank-and-file blow | Goblin horde | Treant's grove | Gel wall | Needler thicket | Sandworm's ambush | Grave throng | Barrow mound | Knights' vigil | Ember pyre | Magma vent |
|---|---|---|---|---|---|---|---|---|---|---|
| Every blow a point lighter | 4.2, 1.1% | 5.8, 6.5% | 6.7, 5.9% | 2.9, 3.6% | 4.0, 5.9% | 4.3, 0.5% | 5.8, 4.0% | 2.8, 2.4% | 4.5, 3.6% | 4.3, 6.6% |
| A point heavier | 4.3, 9.8% | 6.3, 16.9% | 7.3, 31.5%, 90% won | 3.2, 9.3% | 4.0, 11.4% | 4.9, 11.7% | 6.3, 12.3% | 3.0, 6.0% | 4.7, 16.4% | 4.4, 11.7% |
| Two heavier | 4.7, 17.7% | 6.8, 26.8%, 97% won | 6.7, 47.9%, 53% won | 3.3, 13.3% | 4.3, 15.0% | 5.3, 23.6% | 6.6, 16.9% | 2.9, 7.5% | 5.0, 25.6%, 97% won | 4.4, 14.7% |
| With Breach | 3.8, 17.2% | 6.0, 30.1% | 7.1, 41.3%, 87% won | 2.9, 13.4% | 3.9, 9.9% | 4.4, 20.5% | 6.4, 26.7% | 2.8, 10.7% | 4.8, 23.9% | 4.3, 12.3% |
| With Burn 1, heat | 4.5, 5.5% | 6.2, 11.1% | 8.0, 29.9%, 90% won | 3.1, 6.0% | 4.3, 8.8% | 5.2, 6.0% | 5.8, 7.5% | 3.0, 4.4% | 4.8, 11.5% | 4.4, 9.1% |
| With Burn 2, heat | 5.0, 9.2% | 7.1, 13.8% | 7.5, 53.0%, 40% won | 3.8, 7.6% | 4.8, 10.2% | 6.6, 17.8%, 93% won | 6.3, 8.4% | 3.2, 5.6% | 5.7, 24.4%, 87% won | 5.0, 12.4% |
| With Scorch 1 | 4.4, 5.2% | 6.0, 10.8% | 7.2, 16.8% | 3.0, 6.0% | 4.3, 8.8% | 5.0, 5.7% | 5.8, 7.1% | 3.0, 4.3% | 4.6, 8.9% | 4.4, 9.2% |
| With Scorch 2 | 4.6, 5.6% | 6.2, 11.3% | 8.0, 21.1%, 93% won | 3.5, 6.6% | 4.3, 8.8% | 5.4, 6.2% | 5.9, 7.2% | 3.3, 4.5% | 4.8, 10.1% | 4.6, 9.4% |
| With Disable | 4.6, 6.2% | 6.4, 11.8% | 7.0, 16.4% | 3.2, 6.5% | 4.0, 8.7% | 5.0, 5.9% | 6.1, 7.2% | 3.2, 4.3% | 4.8, 9.4% | 4.6, 10.3% |
| With Corrupt 1 | 4.5, 9.5% | 6.5, 20.8% | 7.4, 43.1%, 63% won | 3.1, 8.0% | 4.0, 9.1% | 5.3, 17.0%, 97% won | 5.9, 14.4% | 2.9, 4.7% | 4.9, 17.4% | 4.6, 11.6% |
| With Crush 1 | 4.7, 13.7%, 97% won | 6.3, 15.1% | 5.7, 49.5%, 47% won | 3.1, 8.6% | 3.9, 9.2% | 5.3, 13.1% | 6.1, 9.0% | 3.0, 4.4% | 4.8, 21.4%, 97% won | 4.4, 10.1% |
| With Drain | 4.5, 5.2% | 6.4, 11.1% | 7.0, 16.0% | 3.0, 6.0% | 4.9, 10.0% | 5.1, 5.2% | 6.4, 7.5% | 2.9, 3.9% | 4.8, 9.3% | 5.2, 10.7% |
| With Burn 1, as erosion | 4.6, 11.6% | 6.5, 19.5% | 6.6, 45.5%, 53% won | 3.1, 7.8% | 4.1, 9.1% | 5.1, 14.1% | 5.8, 11.9% | 3.0, 4.8% | 4.6, 22.9% | 4.4, 11.1% |
| With Burn 2, as erosion | 4.8, 24.2%, 90% won | 7.1, 37.2%, 80% won | 5.4, 59.1%, 30% won | 3.3, 12.6% | 4.2, 11.7% | 5.2, 32.6%, 90% won | 6.6, 25.7% | 2.9, 6.5% | 5.2, 46.7%, 67% won | 4.5, 14.6% |
| Content as built, Burning as erosion | 4.4, 5.0% | 5.9, 10.6% | 6.9, 15.8% | 3.0, 6.0% | 3.9, 8.5% | 5.0, 5.6% | 5.9, 7.4% | 2.9, 4.2% | 4.6, 12.4% | 4.3, 9.4% |

By machine, the same fights as built (its own hull lost a formation, of its own hull): the
Honey Badger 5%, the Storm Petrel 10%, the Cottonmouth 11%, the Skua 12%, the Prairie Dog
14%, the Cassowary 18%; none wrecked.

**The Barrier basic by its cooldown and by the spike** (squads of four, five squads and four
seeds a fight, 20 fights a cell; the rows as built, at 3 heat and off the dice are the entry
above's):

| The read | An elite (11 fights) | A boss (13) | Reboots a machine: elite, boss | The foes' damage a fight and a Barrier's share: elite, boss | Its spends a fight: elite, boss |
|---|---|---|---|---|---|
| `barrier=cooldown0`: no cooldown | 100% won, 5.4 rounds, 8.8%, 0.02 wrecks | 98%, 9.2, 23.1%, 0.19 wrecks | 0.55, 1.06 | 54.8 and 57%, 115.7 and 56% | 3.50, 7.75 |
| `barrier=cooldown2`: sits out two rounds | 100% won, 5.0 rounds, 13.0%, 0.05 wrecks | 99%, 8.0, 31.0%, 0.28 wrecks | 0.58, 1.15 | 49.6 and 41%, 99.5 and 34% | 1.96, 3.30 |
| As built, every elite and boss striking half again as hard | 97% won, 5.7 rounds, 24.4%, 0.40 wrecks | 73%, 10.5, 60.0%, 1.63 wrecks | 0.70, 1.16 | 87.6 and 47%, 191.7 and 43% | 2.97, 5.73 |
| As built, their blows doubled | 92% won, 5.9 rounds, 34.3%, 0.81 wrecks | 46%, 9.3, 76.4%, 2.68 wrecks | 0.67, 0.90 | 117.4 and 49%, 224.2 and 40% | 3.10, 4.47 |
| `barrier=none`, their blows halved | 100% won, 4.7 rounds, 6.0%, 0.00 wrecks | 100%, 6.6, 9.7%, 0.00 wrecks | 0.53, 1.00 | 22.4 and 0%, 40.5 and 0% | none, none |

By fight, as built against off the dice (the entry above's runs), a Barrier's share of the
foes' damage, then hull with it and without: the Thunder Ape 34%, 12.5% and 11.9%; the Fiend
of Fire 19%, 39.3% and 39.1%; Floraison 13%, 23.0% and 24.5%; the Shaman's warband 14%,
13.6% and 18.5%; the Matador 36%, 19.0% and 23.0%; the Wild Hunt 30%, 17.1% and 27.3%; the
Cinder Tortoise 36%, 21.3% and 40.8%; the Emperor Scorpion 30%, 35.3% and 51.7%; the Fell
Rider 47%, 9.6% and 19.5%; the Marsh Serpent 48%, 20.9% and 40.4%; the Phantom Train 47%,
30.8% and 71.4% with 75% won; the King Gel 49%, 21.3% and 51.6%; the Fallen Weapon 50%,
24.9% and 49.6%; the Ruby Colossus 45%, 37.3% and 61.5% with 70% won; the Vampire Lord 54%,
6.3% and 42.7% with 80% won; Gilgamesh 57%, 10.3% and 24.8%; the Old Man of the Desert 58%,
15.0% and 41.1%; the Pilgrim 65%, 3.7% and 17.4%; the Mantis Ant 66%, 11.1% and 42.7%; the
Reaper 66%, 0.4% and 3.3%; the Goblin Nob 73%, 15.6% and 53.3%; the Rust Monster 78%, 2.4%
and 12.6%; the Obsidian Tyrant 40%, 40.3% and 55.3%; the Gargantuan King 65%, 35.1% in 21.2
rounds with 85% won and two stalls, and 55.2% in 9.4 rounds with 95% won.

What it says: a rider reads the same on a gun of 3, of 2 and of 1 (Burn 1 nine tenths of a
point, Spread 1 a point, Splash 1 a point and a half, Shock nine tenths, Penetrate 1 six
tenths), Burn's and the area riders' second point is worth more than the first, Sap is a
point of hull a stack and Cryo a fifth of a point at 1 or 2; against eight plain 4s a flat 2
and a flat 3 stand 1.4 points of hull apart and a flat 4 takes 38% off the 3's, a straight 4
and 2 twice are one gun there and part against 3 behind plate, where 2 twice is the flat 3
to the decimal; a point of plate on eight 4s more than doubles the horde; the rank and file a
hit point up costs the roster 0.7 rounds and 2.9 points of hull at a flat 3; a point on
every rank-and-file blow is four to seven points of hull, Breach reads as two such points,
Corrupt 1 and Crush 1 as 1.2 to 1.3, Burn 2 as heat as 1.4 with 8% of fights lost, and
Disable, Drain and Scorch 1 as a tenth or less; Burning as erosion is dearer than as heat at
the same number, 15.8% for 10.0% at 1; the Barrier's cooldown is a slope of two to four
points of hull a round, an elite striking half again as hard costs a squad with the Barrier
basic what today's costs one without, and its share runs from an eighth to three quarters by
the foe's kit. What it does not say: anything a rider is worth to a planned second spend;
a formation of one rider on every blow is no formation, so the dearer riders read at their
worst; the marks are one grid and eight of one foe; 20 fights a cell by fight is a
direction's direction.

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

The dials still his to play, each a what-if over content (a debug build's TRIALS): HEAT,
every weapon one or two cooler; TOP BASIC, the Carbine's point at 2 or 4 more heat; RANK AND
FILE, the standard foe at 5; OVERHEAT, a point of excess burning 2 or 3; BARRIER BASIC, off
the stock dice with the Armoured basic in its slot.

## 3. Where tier one stands

Sized on 17 and 18 November (section 8) and read at the anchor: tier one at Convergence 1,
the six certain tier ones (the Honey Badger, the Skua, the Storm Petrel, the Prairie Dog,
the Cassowary, the Cottonmouth), each on its stock die with no module and no found piece,
squads as large as the fight is rated (a lone flanker one machine, a hunter's pack two, a
formation three, an elite and a boss four), the greedy bot (`tools/anchor_read.gd`). Every
squad of the pool is read, the even draw: a count of them was uneven by machine until 18
November, the Honey Badger in four of the five fours the leaders were sized on, and the
sizing held when it was read again on all fifteen (`docs/measurements.md`, that day). Hull
is a share of a four's, 96 points for this pool.

| Kind of fight | Rounds | Hull lost | The budget | Before the sizing |
|---|---|---|---|---|
| A lone flanker | 5.3 | 3.4% | 3.3% or less | 5.9% |
| A hunter's pack | 4.8 | 8.9% | 10% | 12.7% |
| A formation | 5.7 | 4.5% | 5% | 8.3% |
| An elite, the squad without the Barrier | 6.5 | 24.8% | 25% | 23.6%, the Nob at 65.1% |
| A boss, the squad without the Barrier | 8.9 | 29.8%, a wreck in a fight of five | what is left | 53.2%, 86% won |

By formation: the needler thicket 1.3%, the sandworm's ambush 1.5%, the knights' vigil 2.4%,
the magma vent 2.7%, the goblin horde 3.3%, the gel wall 4.9%, the barrow mound 6.2%, the
ember pyre 6.5%, the grave throng 6.6%, the treant's grove 9.3%. The flankers cost 2.5% to
4.1%; the wolf pack 7.1% and the antlion trio 10.7%. Every one is won in every fight.

The elites and the bosses are sized for a squad without the Barrier (section 8), the
Armoured basic in the Halo Projector's slot: an elite from about 15% (the shaman's warband)
to 27%, every fight won, and a boss from 21% (the Vampire Lord) to 42% (the Obsidian
Tyrant), a row a direction at thirty fights. The squad as the dice deal it, the Barrier
basic on them, pays about half: an elite 13.9%, a boss 19.2%. The piece stays on the
starting dice on his word, his play to say whether it proves toxic; the game is sized for
the day it leaves.

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

His proposal, agreed. It waits on his picks of the dials, since every piece is priced
against the vanilla he settles on. Five things keep it small:

- One trade a piece: the vanilla with one thing traded, named. A point more for heat, a
  point more split in two, a point less for a rider, the rider kept for a point of heat,
  Indirect for a point of heat.
- A kill signature: a gun's spends to kill five marks (a plain 4, a 3 behind a point of
  plate, a thin 3, a thick 6, a 4 behind plate; `tools/basics_model.py`). Two guns with the
  same row and heat are one gun.
- Marks as well as guns: a placeholder formation is one standard foe eight times.
- Par, then the unit: a piece is priced to read as the vanilla alone, then read on each
  machine, since the reason to slot a find is what a unit does with it.
- Read by the kind of formation, by the bot's pick share and by his play.

Where the pieces live is his: content with working names, or rows a debug dial deals with no
name, text or model owed until one is kept. The lean is the second for the grid and the
first for what survives it.

Tier one's finds as built are what it replaces: eleven of fourteen slottable tier-one guns
deal 4 or more, where a find in a tier-one rift "is a new trick and never a bigger number".
The Overclocked Railgun, the one open tier-one piece that ignores armour, may move up a
tier in the component pass.

## 7. Open

His, each with this pass's lean and its read (`docs/measurements.md`, 17 November, the last
two entries):

| The call | The lean | Why |
|---|---|---|
| Whether the Barrier basic proves toxic | His play's to say (18 November: "if it does prove toxic after all, in my play, then it's relatively easy to remove"); it stays on the starting dice until then, on BARRIER BASIC | The leaders are sized for a squad without it, so taking it off moves no number. With it a squad pays about half, and the leaders whose weight is one great blow cost it least: the Vampire Lord 7.1%, the Fell Rider and the Rust Monster 7.4%, the Mantis Ant 7.8%, the Marsh Serpent 8.3%, the Nob 9.6%. A second round of cooldown is 3.5 points on a boss where the piece itself is 20 |
| How the leaders strike | His lean, 18 November (section 1; the bible's section 9): whole blows the norm, "leaning slightly towards multi to gently boost armour in boss and elite fights", never so "an armoured tank is just best in every fight" | A pair is the gentle setting and three strikes or more a wall's fight (section 4's plate arithmetic), so three and more stay the rare kit shape. Today one boss a domain carries a move of strikes (Floraison's three and five, the Emperor Scorpion's pair, the Matador's four, the Fiend of Fire's six) and one elite fight of tier one's eleven (the Thunder Ape's three). The lean's room is a pair on a few leaders' plain blows, most of it among the elites, each a proposal in chat by the kit's fantasy. A move of strikes is sized with what lands once a strike: its riders, and a machine's Brittle (the World Eater its one layer, so it keeps whole blows). A foe's Empowered goes through the move's multiplier, so a pair at the same total takes a rally as the whole blow did, and it grows on a move whose strikes add up to more than its attack (Full Bloom, five strikes at half, takes two and a half of one). This pass's lean of 17 November, every plain blow as two strikes, is retired; its read stands, and the what-if that made it, the anchor read's `split=`, left with the leader pass (`git show 4ae57e4:tools/anchor_read.gd`) |
| A pair on two bosses | This pass's proposal, by the kits' own words, for his marks: the Mantis Ant's Mandibles as two strikes of 7 for one of 13, the Gargantuan King's Gore as two of 6 for one of 11 | Read as a what-if on every squad, sixty fights a cell: a pair leaves the squad without the Barrier where it was (the Mantis Ant 25.9% to 26.1%, the King 31.6% to 33.4%) and takes half the piece's edge with it (7.8% to 13.8%, 23.1% to 27.4%). Each boss keeps a whole blow beside the pair, the Ant's Upheaval and the King's Charge |
| HEAT | −1: a vanilla 3 for 3 | Four shots a gauge for three; a formation 0.7 rounds shorter and a point of hull lighter, a quarter fewer reboots; "I just know I overheated a lot" |
| TOP BASIC | +2: the Carbine 4 for 6 | Its point is paid in heat: two shots a gauge for the vanilla's four |
| RANK AND FILE | As built: a standard foe of 4 | At 5 a formation runs a round longer and costs half again as much, so the blows would be sized again. The room 5 was to buy, a point between the Carbine and the kill, is bought by the Carbine's heat. Loosely held; tier two's standard is 5 already |
| OVERHEAT | ×1, and the dial cut | A stack burns every turn until the reboot, so one compounds; the bot reboots before it burns |
| The walled tank | His to say | Whether a machine that reboots for nothing under a formation is its identity or a hole |
| Where the bench's pieces live | Rows a debug dial deals for the grid, content for what survives | A name and a line are his to write |

Leans not yet built, each a number this pass may land with its read:

- The Field Radiators and the Boundary-layer Bleed still grant a point of cooling from a
  slot, against his expectation that cooling is a kit's or gated; the lean is to drop the
  cooling and keep the Radiators' maximum.
- Cryo's stack cools 2, two thirds of a vanilla's heat at 3; the lean is 1 if the vanilla's
  heat lands at 3, with the Polar Bear's session.
- Indirect a point of heat over Direct.
- The Overcharge Coil at one stack, or tier two.
- The ten planned shields and vents: retire the seven at tiers zero and one, the three at
  tier two waiting for a kit that wants one.
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
  for 4, and the two massives, the Sandworm and the Magma Elemental, for 6.
- A scorch on every machine is 2 at tier one: the Magma Elemental's Eruption.
- The standard blow with a rider on top: the Salamander strikes for 3.
- The two formations that ran longest and dearest: the Treant strikes for 6 and mends 2, and
  the gel wall fields two mandragoras behind its four gels, not three.

The Waste's two formations stay light, 1.9% and 2.8%. Their foes are thin and lost the
rider that was their bite; what a domain's kit should be without Breach is a content
proposal for his marks, the Waste's first, and no number chases it.

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
  then the blow, a step ahead of the blow that the move says, a Ward the answer, and the
  Pilgrim's alone ("Agreed on pilgrim-only": the bible's row on the foes' rule set). It costs a
  squad without the Barrier 19.2% and one with it 16.0% for 7.6%. The Reaper rose the same
  way, for a day: its Harvest is a sweep at every machine since 18 November, on his word ("Reaper
  sweep seems like a good idea"), 9 at each and corrupting 1, drawn as often as its scythe,
  and its Scythe and Knell are 12 and 18 again. It costs a squad without the Barrier what
  it did, 24.3%, and one with it 13.5% for 7.8%.
- No one action takes the lightest machine from full, the scale row's cap, 26 points on the
  Cottonmouth: the Thunder Ape's Rampage is three strikes of 6 for 8, so gold it lands 24
  where the foes' adds on every strike had made it 30, and the Ape has 54 hit points for 48.


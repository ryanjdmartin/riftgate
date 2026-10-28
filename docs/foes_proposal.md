# The foes' fresh start: a proposal

The foes get their fresh start in a session of their own, proposed in chat first (the bible's
section 9, the working-set row; the status's order of work, item 3; the to-do's line). Ryan
opened the session on 26 October ("We need to work on the foe refresh"). This file is the
design's one home until he has moved it: the fights' shape, what the rift sends and when, the
Rupture meter with its Fractures and the seal, the elites, the boss's formation, and the bots
that read it all. Then its decisions become bible rows, `docs/rules.md` and content, and the
file retires (git keeps it). Names are working names, every number a placeholder, and
everything here is Ryan's to move. Nothing in the engine or the content changes before his go;
what this session built without waiting is runner work alone (the last section).

The same day's other sessions moved the ground this stands on, and it is written against the
live bible (v0.298): the quick campaign (section 3's row), the bosses at their tier (section 9's
boss row), the boss's fight that takes every machine and cannot be left (section 4's boss row),
the Gel's pair and a beaten domain's rifts closing.

## What the records already decide

One line each, so that nothing below re-opens a settled point by accident; each is a row.

- An enemy hex is a pack, one sprite and a number badge; a fight is the pack attacked and every
  pack whose ring covers it, with the machines whose attack range covers it (section 4, the
  round rows; section 5). Today a pack is one foe type times a strength (the vocabulary's pack
  entry, whose hole says the rift should spawn formations).
- Four machines, moving as one; a detachment is a decision priced by time, and the fights come
  in sizes: formations for the body, small packs one or two machines take for about a tenth of
  their hull (section 4's four-machines row, Ryan, 13 October). The sizes are the fresh start's;
  the row reopens if the fresh start's fights still hand a squad free wins.
- A battle is four to five meaningful skirmishes and then the boss, the count flat across tiers
  and the threat rising (section 4's pacing row, Open: the Rupture meter fills with the
  threat-weighted tally, each Fracture a prize, the Rupture at three, four or five Fractures by
  the Convergence's tier unseals the boss, later Fractures cost more; the names are Decided).
- The Rupture meter and Anathema fill by the threat-weighted tally, never by a count of fights
  or kills, so picking off small packs with flyers is not the optimal play; a detachment's kills
  add little meter, so its worth is defence and tempo (section 3). Salvage is weighted the same
  way (section 10's kill row). Not built on the map.
- The boss guards the rift, immune until the Rupture meter fills (the seal is not built); its
  fight takes every machine, whatever their range or their turn, and cannot be left: ENGAGE
  goes straight to the reveal, and the fight ends the battle, the rift sealed or the team
  scrapped (section 4's boss row, Ryan, 25 October). A fight the boss joins by its ring is its
  fight too. What reopens it: a boss fought more than once.
- A boss, a final's hero and the finale's line scale to the battle's tier, their HP and attack
  and an escort drawn from the domain's units of the tier (a unit's tier is content's, one by
  default), a named escort kept for the hand-tailored ones to come; the rank and file never
  scale (section 9's boss row and section 3's escalation row, Ryan, 25 and 26 October; built
  on `claude/quick-campaign-mode-pafhiv`).
- The quick campaign: battles without the map, an experiment and not a feature (section 3,
  Ryan, 25 and 28 October: no decision reads its runs).
  A battle's fights are as many as the Rupture's Fractures with the elites folded in, every one
  a complete formation, then the boss with its formation, no heal and no withdrawal; the enemy
  the same at every tier "until the foes' fresh start", the elite stood in by the domain's other
  bench hero ("I don't think that using the bench hero is a great elite, but I see why you did
  it"). It reads what the campaign runner cannot: a squad fighting every fight together.
- One clock, Rift Pressure, ticking on the map and never in a fight (section 4). Its escalation
  and backstop are Ryan's pacing session (section 12).
- Difficulty grows by smarter foes and nastier compositions, never by inflating the rank and
  file: aims, conditions, behaviours, back ranks, elites and pack count (section 3). The curve by
  stage is Recommended (section 3's curve row): early simpler foes, thinner formations, a longer
  timer, about one elite; middle mixed, denser, shorter, elites with curveballs, guests; late
  little fodder, very dense, short, elites regular. Its form is open in
  `docs/curve_proposal.md` (Ryan's tier and ramp, or Claude's deepening rift).
- Each foe picks at random by default, by an aim where its threat calls for one; the foes never
  over-commit (section 5's aim row). One rule set for foes: one or two moves for the rank and
  file, three for a boss or a hero, a special never twice running; a summoner needs no
  condition (section 9).
- The roster comes in tiers; size, rank and complexity are apart from the tier. An elite is a
  spawn of one or more unique packs outside the spawn list, a guaranteed miniboss event in the
  middle of a battle, about one an early battle and more later, worth a larger chunk of the
  meter; a boss's mechanics stay inside the skirmish, an elite's may work on the map (section
  9's tiers row). The Treant, the Magma Elemental and the Sandworm are rank and file; the Bone
  Wyvern is an elite unless a better setup comes. The slate is `docs/bosses_proposal.md`.
- A rank is a foe's only role until Ryan proposes a system (section 9, Open).
- The Gel is a wall: its halves step up in its place at once, a pair in one slot; summons and a
  foe getting back up step up at once too, their round over (section 5, Ryan, 25 and 26
  October). A beaten domain's rifts close (section 3, 25 October).
- The campaign's plain player is a floor, not a player; the fight bot's ladder reads bands
  (section 11).

## The problem, as measured

The reads this proposal answers, each in `docs/measurements.md` unless named otherwise.

- **Two rungs and nothing between** (23 October, the starter trios and the endgame fours). For a
  stock trio the rank-and-file packs are free (random play wins them nine times in ten at 0 to
  15% hull), the three dense formations, the two breaching massive foes and one final are the
  fights, and the finale is a wall. An endgame four fitted to tier two meets nothing but the
  finale: every pack is free at 0 to 6% of its hull. Every tier draws the same spawn lists at
  the same density, so a run's later battles field what its first did.
- **The trio's wall is the formation's size, and the enemy has no tiers** (27 October, the
  matrix's team rows at 200 seeds): a stock four beats every formation as it stands at 100% on
  the greedy rung for 3 to 14% of its hull, with an area piece or without; a trio sits in a
  decision band on the Meadow and the Waste and is walled on the Marsh and the Peak; formations
  a third thinner are a trio's decision band. Every tier draws the same lists at the same
  density, so a run's later battles field what its first did: the enemy's side of the curve is
  the hole. (The quick campaign's runs are not grounds: an experiment, Ryan, 28 October.)
- **A tier's units need a floor** (28 October, the matrix grouped by chassis tier): the rank
  and file at their one set of numbers cost a tier-one machine with its stock kit half its hull
  a fight and a tier three a third, and the content's weapon numbers barely move by tier where
  its hull does, so the late tiers' power is options and synergy; section 3's row is an
  aspiration now, and a tier's units carry the numbers that keep them a fight (section 9
  below).
- **A fight is one pack, mostly, because the squad is one machine, mostly** (26 October, this
  session's reads): four of the campaign runner's battles in five are fought by one or two
  machines, wrecks sitting out with no spares (section 3's roster row), so two fights in five
  are one machine alone against one pack, and the squad walking as one moves none of it. What
  main's boss row moved is the battles won, from 1% to 15%: a trio that reaches the boss fights
  it together, every machine in whatever its turn, so the boss's fight is the first decision a
  trio makes and the one it wins; the seal (section 4 below) is what makes it the last. The
  campaign report reads the roster's spiral and the boss row, not the fights' shape; the
  matrix's composed cells read the fights.
- **Formations are the only decision, and they read easier at random** (24 October): the
  formations' pressure is the balancing's to restore, and an advanced foe's aim is a lever on
  top.
- **A lone massive foe is no exam** (23 October): without a breach it deals about a trio's
  standing shield over eight rounds and costs 1% of its hull; a four kills any of them in two to
  three rounds. The bosses at their tier (26 October) answer the numbers' half of this, not the
  shape's: a lone boss, however big, is one column.
- **Nothing waits to be trapped**: eight slots hold a whole spawn-list pack, so the Lammergeier's
  mines find a reinforcement step with nobody in it outside the formations.
- **The fight-size spectrum as it stands** (26 October, below): two foes are free for any
  machine alone, three of a swarm type are a real fight for a light machine alone (random losing,
  greedy winning, a fifth to two thirds of its hull) and free for a heavy, a front and a back of
  six cost a lone heavy a quarter and wall the lights, and a whole spawn list costs a tier-two
  trio 6 to 12% and a four 1 to 6%.

## The design

### 1. A pack is a composition

A pack stays one hex, one sprite and one badge, as decided. What changes is what it holds: a
**composition**, several foe types with their strengths, dealt from the domain's list, so a
front and a back arrive together and a fight on it holds both ranks from the first round.

- Its sprite is its **lead**'s, the first member in content order (the bodies in front); its
  badge is the count of every member; a tap lists the members, exact (the exact preview, section
  3's sensor row: nothing in battle hides what a fight holds).
- Its ring is the largest of its members' (a front type 1, a massive type 2, a back type 3), so
  a formation with a back joins fights from three hexes as a back pack does today.
- It walks at its slowest member's pace and by its lead's behaviour (a goblin warband hunts as
  goblins do; a drake's roost pushes). Its survivors are kept by member, and a withdrawal
  returns them whole as today.
- It unpacks into the skirmish as the harness's composed enemy side, the runner's mixed cells
  and the quick campaign's formations already do: every member's foes into the pool, the
  heaviest hitters deploying left.
- The boss unit is already this shape (its commanders and its escort, drawn from the tier),
  so the engine gains one structure rather than a second: a pack's **members**, each a foe
  type, a strength and whether it commands.

Why one hex and not a front pack and a back pack walking together: while two packs stand
adjacent either's ring joins the other, so two hexes buy no peel and no decision, only drift
when their speeds part and the map code to hold them together; and the pack row (one sprite,
one badge) stands. Claude's lean. The two-hex form is on the bench.

Content: a domain's `spawn` list becomes its **compositions**, each a size (below), the tiers
that may deal it (one to three, as a unit's tier runs), and its members:

```json
{"id": "goblin_warband", "size": "formation", "tiers": [1, 2],
 "members": [{"foe": "goblin", "strength": 5}, {"foe": "mandragora", "strength": 2}]}
```

The compositions are content, authored by hand and proposed in chat (CLAUDE.md), never
generated: a domain's shape on the map is its author's to draw. A composition of one member is
today's pack, so the file reads as it does now with a size and a tier band added. The
quick campaign deals them as its formations and its elites; the map places and spawns them.

### 2. The fight-size spectrum

Four sizes, each a hull cost at the squad the stage fields (the four-machines row's own
numbers), produced by the compositions and never by a rule:

| Size | What it is | Who takes it | What it costs (the target) | The meter |
|---|---|---|---|---|
| A patrol | one or two front types, three to five foes, no back; the map's alone | one machine, a detachment; two for safety | about a tenth of the machine's hull, two or three rounds | little: a tenth of a formation's |
| A formation | a front of bodies and a back of problems, six to sixteen foes by the tier, the overflow waiting as reinforcements | the body: three or four machines | about a tenth of a four's hull, a fifth to a third of a trio's; five to eight rounds | the unit the Fractures are counted in |
| An elite | a unique composition outside the list, one or more packs, a miniboss event | the whole squad, or whoever it catches | a formation's cost and a curveball besides | a larger chunk than a formation |
| The boss with its formation | the boss at the tier's numbers, sealed until the Rupture on the map, with its escort of the tier's units in the other columns | every machine, by rule | the exam: the boss three to five rounds with its mechanics (section 2), its escort beside it | the end |

A battle at competent play costs 60 to 80% of a fresh squad's hull (the pacing row's target),
which four to five fights at a tenth each, the elite, and the boss's formation add up to. The
measured spectrum today (the last section): the formation size is what wants thinning at tier
one and thickening at tier three; the patrol size is a light machine's three or a heavy's five.

### 3. What the rift sends, by stage

The rift's tier (set as the rift opens, shown on the card; the quick campaign's battle tier)
picks **what** comes: which compositions (simple or advanced by their members' tiers), how many
elites and which, the bosses at their numbers, the Fractures. The ramp (the Convergence, live,
never shown) sets **how many and how fast**: the compositions on the field at the start, their
density, and Rift Pressure's fill. That is the split of `docs/curve_proposal.md`'s
tier-and-ramp form, Claude's lean there; the engine built here carries a rift's tier as one
number and the ramp as another, so either form is a one-line choice of where each number comes
from. Placeholders, by the three tiers:

| | Tier 1 (early) | Tier 2 (middle) | Tier 3 (late) |
|---|---|---|---|
| On the field at the start (the map) | one formation, two patrols | two formations, two patrols | three formations, one patrol |
| A formation's members | six to nine, two types | nine to twelve, three types | twelve to sixteen, the overflow waiting |
| A patrol's members | three or four | four or five | five or six, or none |
| Who comes | tier-one units, the domain's identity a lean | tier-one and tier-two units mixed, sharper identity, a guest | tier-two and tier-three units, sharp identities with guests, little fodder |
| Rift Pressure fills at (the timer) | 12 turns | 10 | 8 |
| Elites a battle, and when | one, the harder-fight kind, at the first Fracture | two, with curveballs, at the first and third | three, at the first, second and fourth |
| Fractures to the Rupture (the quick campaign's fights before the boss) | three | four | five |
| The boss's escort | the tier's units, two columns | the tier's units, three columns | the tier's units, three columns, a hand-tailored composition where one is written |

A rift's cycle at a pressure peak deals the domain's next composition fitting the tier, patrols
and formations alternating, the guest's alternating with the lead's from tier 2 as today. The
quick campaign's battle is the same table without the patrols, the timer and the start, a
convenience and never a read. Section 3's row (28 October): a tier's units carry their own
numbers, HP the general ramp and the damage's shape the domain's identity, by the ladder of
section 9 below; what rises besides is count, density, who comes and how soon, and the boss's
numbers as its row says.

A trio's first fights are this table's first column: compositions of six to nine tier-one
units, not whole spawn lists, which the matrix sizes (formations a third thinner are a trio's
decision band, 27 October; a nine-foe formation cost a starter trio 19% of its hull in six
rounds and a fifteen-foe one 43 to 48% in nine, 23 October). Four is kept (Ryan, 28 October;
section 12's three-or-four question), so the first column is sized for a four with a
detachment away.

### 4. The Rupture meter, the Fractures and the seal

**The tally.** Every kill adds the foe's **menace** to the meter, live during the battle (the
meter counts live; salvage still tallies at the end). Menace is one number read off the foe's
content, so no new number is written per foe: its heaviest blow (damage times strikes, a breach
one more: the engine's threat, which already orders the deployment) plus a quarter of its HP,
rounded up; an elite's doubled. Placeholders: a goblin 3, a mandragora 4, a Zombie Knight 8, a
Treant 15, a hero 15 to 19, an elite warband's shaman 8. The same number is the kill's worth
toward Anathema and toward salvage (section 10's kill row; the rate is the economy pass's,
set so a battle banks about what it banks today).

**The Fractures.** Thresholds on the tally, a count by the rift's tier (three, four or five),
each later one a little further than the last (the pacing row): a base of about a tier-one
formation's menace, then one and a half times it, then twice. Placeholders at tier 1: 20, 50,
90. A Fracture earned in a fight pays out when the fight ends (decided): the plaque names it,
and what it brings follows. In the quick campaign a fight is a Fracture by construction, as it
already is.

**The Rupture** is the last Fracture: the boss's seal breaks. The seal: while it holds, the
boss cannot be ordered onto, joins no fight (its ring is inert) and stands patrolling its
ring of the rift as today, marked SEALED on the map; the pressure spawns appear at the rift
beside it as now. Once it breaks, engaging the boss is the battle's last decision, as the boss
row has it since 25 October: every machine goes, and nobody leaves. Claude's lean on section
12's question (may a sealed boss still join fights in its ring): no, since a foe that strikes
in a fight and cannot be hurt in it is the helplessness section 2 removes, and a sealed boss
joining would also drag the whole squad into a fight it cannot win; the other form (it joins,
immune) is on the bench.

**The stall guard** (Claude's lean, a hole named below): the Rupture also comes when no
composition but the boss's stands on the field and none waits at the rift, so a team that has
cleared the field is never left waiting on Rift Pressure to earn the last points. Its share is
read by the runner; if it opens most battles, the thresholds are too high.

**What a Fracture brings.** Two things in this proposal, and one left open:

1. The elite's moment (section 5 below): the Fractures the tier names spawn the battle's elites,
   so the miniboss event is guaranteed and lands at the same point of progress for every team
   however fast it plays, mid-battle by construction, and the quick campaign's "elites folded
   into the Fracture count" is the same rule without a map. Claude's lean on section 12's
   question; the alternatives (Rift Pressure's tick, a turn count) are on the bench.
2. The boss's seal at the last.
3. Open: the reward pick (section 8: one of three, a battle-long modifier, a one-shot or a
   boon; Ryan, 24 October: the picks are the battle's roguelike part, never loot, "designed only
   in high-level theory, and maybe not warranted at all"). The quick campaign pays a loot pick
   for each fight before the boss at the boss's fall, which is a battle's pay and not a
   Fracture's prize. Claude's lean: build the meter, the Fractures and the seal without a prize
   first, since they pace the battle on their own (which fights to take, weighed by menace
   against the gate and the clock, and when to go for the boss); whether a prize rides each
   Fracture is decided after they are played, with the economy pass. The hole: without a prize
   the meter is a clock the player cannot ignore and nothing more; the decision it leaves is the
   order of fights and the detachments' worth, which the four-machines row already prices.

Rift Pressure stays the rank and file's clock and the stall's price: its fill by the ramp (the
timer), one composition a peak, no escalation inside a battle (the pacing session's).

### 5. The elites

Ryan's definition stands (section 9's tiers row), and the quick campaign waits on the elites
by name. What this proposal adds is the mechanism and a first set, each a candidate from his
marks (`docs/bosses_proposal.md`), with a kit from the engine's existing effects wherever one
serves, so the set is buildable the day he picks it.

**The mechanism.** A domain's content names its elites, each a composition of size `elite`
(an elite foe, flagged `elite`, and whatever stands with it). On the map, at each Fracture the
tier names, the next elite of the rift's domain not yet fought this battle spawns at the rift's
nearest free hex, announced on the plaque, and acts by its lead: a hunter heads for its prey, a
pusher for the gate. In the quick campaign it is the fight the Fracture count folds in. Its
curveball is one of five kinds, three of which the engine runs today:

| Curveball | How it works on the map | Engine |
|---|---|---|
| The harder fight | a massive or heavy composition that threatens the gate while it holds the team | runs today |
| The hunter | a fast pack that catches a machine and pins it (behaviour hunt, speed 40) | runs today |
| The swarm | several small packs at once, a composition of many members or two spawns in one Fracture | runs today (compositions) |
| The blitz | a fast pusher whose strike on the gate is its own number, not its count's | new, small: a `gate_blow` on the foe |
| The aura | a battle effect while it stands (shields that stop recharging at the field rate; a Rift Pressure that ticks twice) | new, later: a battle-scope modifier; not in the first set |

**The first set**, for Ryan to mark (the kits in the engine's words; every number a placeholder):

| Elite | Domain | Kind | Size | Kit | Stands with |
|---|---|---|---|---|---|
| The goblin shaman (Ryan, 15 October: a decent elite; the marked `goblin_takesD_1`) | Meadow | the harder fight, a commander: "this guy protects his allies" | not massive, back | Hex (a blow, 3), Warcry (rally 2), Ward-dance (brace_all 1); the lean carrier of an enemy silence (section 12) | four goblins and two wolves: a warband that hits harder while it stands, so reach the back first |
| The Reaper (Ryan, 15 and 24 October: the deadly hunter; art cut) | Marsh | the hunter: "this guy is going to kill my unit" | not massive, front, hunts the weakest at 40 | Scythe (6), Death's Knell (a countdown of two, breach, 12: the telegraphed knife), Harvest (corrupt 1) | alone: a fight the detachment it catches cannot win, so the squad comes to it |
| The Bone Wyvern (built; Ryan, 24 October: an elite unless a better setup comes) | Marsh | the harder fight | massive | as built | two ghosts behind: the regrow and the raise together |
| The Elder Treant (Ryan, 24 October) | Meadow | the harder fight | massive | the Treant's kit at an elite's numbers: regrow 5, Root Storm at a half | two mandragoras: the screams cost the rerolls the storm wants |
| The Leshy (Ryan, 24 October: liked, maybe a foe of its own) | Meadow | the swarm, a commander | not massive, back | Call of the Wild (summon two wolves, a special's weight, never twice running), Root Snare (disable), a blow (3) | a wolf pack: the forest keeps coming |
| The Old Man of the Desert (Ryan, 24 October) | Waste | the harder fight | massive | the Sandworm's kit at an elite's numbers: Swallow breach 10, Burrow brace 4, Quake | four needlers: fixed damage round a breach |

Two elites in each of two domains, one in the Waste and none in the Peak (its candidates are
the slate's bosses' kin); a Peak elite and a Waste hunter are for Ryan's marks, from the
candidates or new. The Reaper and the shaman are the hunter foe and the commander foe section
12 asks for, as elites first. An elite's numbers are its own and never scale with the tier
(the boss row scales bosses, heroes and the line); a tier's elites differ by which come.

### 6. The boss with its formation

Decided and built on 26 October (section 9's boss row): a boss at the tier's numbers, with an
escort of two or four more drawn from the domain's units of the tier, a named escort kept for
the hand-tailored ones Ryan expects. What this proposal adds is the hand-tailoring: each
domain's compositions include an `escort` size per tier, the boss's own formation, written
like any composition (the Treant with two mandragoras and a wolf pack; the Sandworm with
needlers and a cockatrice behind), so the boss fight is the exam the pacing row wants and never
a lone massive foe a four kills in two rounds. The engine fields a final the same way (the hero
with the escort); the final takes the tier's escort composition too. The bosses' slate
(`docs/bosses_proposal.md`) lands as content alone, as decided; until it does the four massive
foes stand in, and the Treant, the Elemental and the Sandworm join their domains' compositions
as the slate takes their slots.

### 7. Roles, and the kits the briefs wait on

**Roles.** Section 9 leaves roles Open until Ryan proposes a system. The smallest one that
serves is his own, in his words of 24 October: "this guy hits hard" (the hitter), "this guy
protects his allies" (the guard), "this guy heals" (the healer), "this guy debuffs" (the
debuffer), "this guy is going to kill my unit" (the killer), and "many" (the swarm). A role is a
word on the foe's content, the codex's first line, and the composition author's guide (a
formation is bodies in front and a problem behind: at least one hitter or swarm forward, a
healer, debuffer or guard behind); the engine reads it nowhere, so no foe gains a stat by it
and "I don't want to overcomplicate the enemies" holds. Whether it shows at all is Ryan's.

**What the briefs wait on** (the to-do's line), and what answers each:

- Back ranks in more fights (Minos's rank turn, the column keywords' keep): the compositions.
- Reinforcements worth trapping (the Lammergeier's mines): formations of twelve to sixteen at
  tier 3, the Marsh's Raise, the Leshy's wolves and an elite swarm; a summon or a Gel's half
  stepping up in place sets off a mine in its slot (the Gel row), so the mines keep their prey.
- Foes with more than one move (the jellyfish's Disrupt): most of the rank and file carry two
  already; compositions put them in every fight.
- Riders on machines in every domain (the Ward, Mastema's mover): the Peak has heat, the Waste
  breach, corrupt and disable, the Meadow the Gel's breach no longer (the Gel is a wall) and the
  Marsh the Zombie Knight's. Claude's lean, content for Ryan: one rider on one advanced foe a
  domain by its fantasy, the Ghost's Hex Bolt a curse (corrupt 1) and the shaman's Hex the
  Meadow's; the Meadow's identity otherwise stays numbers, so the Ward has little to do there
  by design.
- Enemy Shock, telegraphed, if any (Claude's lean of 15 October: a hero or an elite first):
  a mark on a machine that doubles the next foe blow it takes, on the shaman's Hex or the
  Reaper's Knell, so the Barrier has its best moment; a new rider, small. Ryan's call.
- An enemy silence or purge: the shaman the lean carrier of a silence (section 12 says so
  already); a purge stays a promoted form's or a boss's.

Out of scope here and left where they are: the heroes' extra moves and the Martial Artist's
four (`docs/heroes_proposal.md`), the Rune-bearer's execute, and the recolour tier (section 9,
Open).

### 8. The bots and the test bed

The test bed is the balance runner: its composed cells (`--pack` today, the content's
compositions as rows of cells on the go) by domain and tier at 200 seeds, against the squads
each tier fields, read as bands; the matrix's team rows are where the fights' size has been
read so far. The quick campaign is an experiment (Ryan, 28 October): the compositions may be
dealt there as a convenience, and nothing is read from it.

The campaign runner reads the map's half (the patrols, the detachments, the meter, the seal,
the elites' arrivals, the gate), and its player is a floor. Built this session, the last
section: the squad moves as one, allies join a hunter's catch, and the withdrawing persona.
Its reads (below) say the campaign's spiral is the roster's, which the economy answers, so no
read of the fights' shape is asked of it until a run can field a squad. Next, with the go: it
reads the meter (Fractures reached a battle, turns to the Rupture, the stall guard's share),
the elites (fought, the gate they took) and the fights by size.

### 9. The ladder: a tier's units (28 October)

Ryan's calls: the roster fills by tier with placeholder monsters or classic palette swaps "so
that ramp balance can begin", ideally with more threatening mechanics as well as more stats,
"but for now a numbers race is kind of what we need"; never-inflate is an aspiration, since
"with component tiers and synergy payoffs, inflation is just a matter of course for some
units"; HP and damage go up, "but each domain's identity should also sharpen as the tiers
rise, with guest appearances preventing the player from building a hard counter for a domain
and steamrolling it"; a recolour by hue is fine with a modified name, no other marker. His go
on the ladder as proposed, 28 October ("Ok, this seems good"). The measured floor is in
`docs/measurements.md` (28 October).

The shape: two layers of numbers, the floor the general ramp (the fight's length) and the
identity each domain's dial on top (the Peak's spike by the shield and the Barrier, the
Waste's breach by hull and tempo, the Meadow's volume by area and armour, the Marsh's returns
by kill order, burst and the Purge); Ryan's read, "enemy damage is more skewed towards a domain
identity, and HP is more of a general ramp tool", with two refinements agreed, the Meadow's
ramp count rather than HP and armour the wall's number whoever fields it. Thirteen base types,
two recolours each, every twist a mechanic the engine runs. The spec is the build brief's,
`docs/briefs/foes_ladder.md`: every entry, every number, the spawn lists by tier, the sprites'
hues and the engine's readers, so nothing of it is written twice.

### 10. The enemy's buffs and the player's Purge (28 October)

Ryan: "having more than one purpose for a player purge is important though. Enemies can
certainly carry offensive buffs such as primed in addition to kindled on more units, and
defense buffs like barrier, ward, Regen, or a delayed heal or something, shouldn't be out of
the question. Whatever you think adds healthy depth." The test for each buff that crosses: it
crosses under the machines' own word (section 6's convention), a telegraphed special grants it
and a chip shows it, it has an answer beside the purge so a Purge is a decision and never the
one key, and it sharpens a domain's identity. Four cross: Primed (the Peak's stoker), Barrier
(the Waste's burrow), Ward (the Marsh's hallow) and Regenerating (the Marsh's wight), beside
the Kindled, Armoured and Getting Back Up the foes carry already; never Numbed, never Guarded;
a delayed heal is a countdown, so it needs no buff. The player's Purge is a keyword on any
entry aimed at a foe, on a capstone's blow (the jellyfish's EMP) or alone on a debuff piece
at tier two, so the die asks "strip it or shoot". The semantics, the specials, the piece and
the bot's valuations are the brief's (`docs/briefs/foes_ladder.md`, sections B and C).

### 11. The three verbs, decided (28 October)

Silence mutes a machine's keywords through its next round and leaves its buffs (the enemy's
question to the keyword build); Purge takes every buff a die face bought for good and sleeps a
store's, a form's or a passive's grant until the start of the player's turn after its start
resolves, the Ammit's kept stacks its passive's own, never a last act's (the question to the
stack); a foe's Cleanse takes every mark the team laid off one of its own, never Numbed or
Suppressed (the question to the status build, the Marsh's). Specials only, telegraphed, each
a one-round window with an answer on the die (the Ward, an ally's Cleanse, the caster's
death, the timing of a spend). Leans: the Waste purges, the Marsh cleanses, the Meadow's
shaman silences, the Peak burns; a boss anywhere may carry any. The rows are the bible's
section 5 and section 9; the engine work is the brief's (`docs/briefs/foes_ladder.md`, section
A); the first carriers are the ladder's (the Spectre's hallow; a silence and a purge carrier
wait on the shaman and the Waste's casters, Ryan's marks).

## A battle, as proposed

A tier-1 Meadow battle, the stock trio. On the field at the start: a goblin warband (five
goblins, two mandragoras) in the north centre, a wolf patrol (three wolves, hunting the
slowest) on the west, a gel patrol (three gels) on the east; the Treant sealed at the rift with
its escort of two goblins beside it. Turn 2 the wolves catch the Puffin: the first fight is the
squad's, a patrol (menace 12). Turn 4 the warband (23): the tally is 35, the first Fracture at
20 fell in that fight, and as it ends the plaque names it and the shaman's warband appears at
the rift, pushing. Turn 6 the gels (15) and turn 7 the warband (28): 78, the second Fracture at
50. Rift Pressure peaks on turn 12 and the next formation emerges; it dies on turn 14 (20): 98,
past 90, and the Treant's seal breaks. One order onto the Treant, turn 15: every machine goes
in, the boss fight is the battle's last, and it ends it. About fifteen turns, six fights and
the boss. The hole it shows: the thresholds are set so the starting field and the elite carry
the tally almost to the Rupture and a pressure spawn or the guard carries it over, which the
runner reads across many battles before any number is kept.

## What is built on the go

The sim first, headless and tested, then the runners, then the screen's pieces.

- **Content** (`content/factions.json`, `content/foes.json`, the validator): compositions with
  a size, a tier band and members; a foe's `elite` flag and `gate_blow`; each domain's elites
  and its boss escorts; the role word if Ryan wants it. The validator refuses a composition
  without members, a hero in one, an elite without the flag, and a size outside the five.
- **The pack as a composition** (`sim/unit.gd`, `sim/content_db.gd`, `sim/battlefield.gd`,
  `sim/battle.gd`): members on the unit, the boss unit's lineup and escort folded into them;
  `foes_for` unpacks members; the ring, the pace and the behaviour read off the members;
  survivors by member; the placement at setup by the tier's counts, compositions spaced so
  their rings do not chain; the spawn cycle dealing compositions. The harness's composed enemy
  side and the runner's `--pack` cells are compositions already.
- **The ladder** (section 9; `content/foes.json`, `content/factions.json`, `tools/`): the
  recolours generated from the marked table, each with its `tier`, its numbers and its twist;
  the spawn lists carrying tiers and the rift dealing the battle's tier with the tier below as
  filler; the recolour script (a hue shift the three simulations keep apart, lightness with it,
  the base's sprite to `art/foes/<id>_combat.png` and `_map.png`); the quick run dealing the
  same, as a convenience.
- **The three verbs** (section 11; `sim/effects.gd`, `sim/skirmish.gd`, the validator): the
  silence's mute of keywords back from the 21st's code, its buffs left; the purge taking what a
  die face bought and sleeping a store's, a form's or a passive's grant until the start of the
  player's turn after its start resolves, the Ammit's kept stacks its passive's own; the foe's
  cleanse special; a Last Act never purges, and the validator refuses a silence or a purge as a
  rider.
- **The enemy's buffs and the player's Purge** (section 10): Primed, Barrier, Ward and
  Regenerating on foes under the same words, granted by specials; the Purge keyword on an entry
  aimed at a foe, taking every buff a foe carries but Numbed and Guarded.
- **The rift's tier and the ramp** (`sim/campaign.gd`, `sim/battle.gd`): a rift keeps the tier
  it opened at; the battle reads the tier for what comes and the Convergence for the counts
  and the timer, each a table of placeholders in one place, the quick campaign's battle tier
  the same number.
- **The Rupture meter** (`sim/battle.gd`): the live tally of menace, the Fractures by tier,
  the elites' spawns at the Fractures named, the seal on the boss unit (no order, no join), the
  Rupture by the last Fracture or the stall guard, the salvage and Anathema tallies on the same
  weight (Anathema recorded beside the count of three bosses, which still decides the final).
- **The elites** (content and `sim/`): the first set as Ryan marks it; the blitz's gate blow;
  an enemy Shock rider if he wants one.
- **The runners**: the campaign report's meter,
  elite and fight-size reads; the balance runner's composition cells by domain and tier
  (`--pack` today, the content's compositions as rows of cells on the go).
- **The screen**: the meter bar with its Fracture notches under the gate's, the SEALED mark on
  the boss and its break, the plaque at a Fracture and at an elite's arrival, the composition's
  members on a tap. The sim lands first; the screen's pieces are a pass of their own and are
  judged running on the phone.
- **The records**: the bible's rows (section 4's pacing row to Decided as far as Ryan takes it,
  section 9's roster and elites rows, the pack's definition, the quick campaign's row losing
  its stand-ins), `docs/rules.md`, the vocabulary (Composition, Patrol, Formation, Menace, the
  Rupture meter's entries from planned to implemented; Silence's, Silenced's and Purge's shown
  text to the decided forms; the foe's Cleanse and the crossed buffs), the to-do and the
  status.

## How it is measured

- The matrix's composed cells by domain and tier at 200 seeds: each tier's compositions
  against the squads that tier fields (the starter trios and fours at tier one, fours fitted to
  tier two and three), the tests the grids'; the ladder read as bands, a tier's units a fight
  for the tier's kit and no cell random play wins with the tier's kit; the Purge's and the
  Ward's pick share against the packs that carry buffs and purges, the buff pieces' against a
  purging pack, and the Ammit's row against one (the to-do).
- The grids of 23 October rerun by stage: every starter trio against the tier-1 compositions
  (patrols, formations, the elites, the boss with its escort) and the five endgame fours against
  the tier-3 ones, random and greedy at 30 seeds as a direction, the bands at 200. The tests:
  a patrol costs one machine about a tenth, a formation a four about a tenth and a trio a fifth
  to a third, the boss's formation is the exam, no composition hands a squad a free win at its
  stage.
- The campaign report, the squad moving as one: the fights by size, Fractures reached a battle,
  turns to the Rupture, the stall guard's share, elites fought, the gate the pushers took; with
  and without the persona; read once the economy lets a run field a squad.
- The fight-size table of this session (below) as the baseline the compositions are read
  against.

## Questions for Ryan

Each with Claude's lean; a question answered in chat lands as a row and leaves this list.

1. A pack as a composition on one hex (section 1), or a formation as two packs that walk
   together? Lean: one hex.
2. The curve's form (`docs/curve_proposal.md`): the tier and the ramp, or the deepening rift.
   The engine built here serves either; the table in section 3 is written for the first.
3. The ladder's marks (section 9): the names, the twists, the two layers' placeholders, and
   which recolours come first.
4. The elites' moment on the map: a Fracture (lean), Rift Pressure's tick, or a turn count?
5. The sealed boss: joins no fight while sealed (lean), or joins and takes no damage?
6. The stall guard: the Rupture also comes once the field is clear (lean), or the player waits
   on the clock?
7. The Fracture's prize: the meter, the Fractures and the seal built without one first (lean),
   the pick decided after they are played; or the pick built with them, one of three as
   Recommended.
8. Does a pack keep its foes' hull and statuses between fights? Lean: no, the survivors return
   whole as today, since the withdrawal's price is already right and a wounded pack is one more
   number on the map; reopens if hit-and-run farming shows in play.
9. Roles: the six words, shown in the codex or internal to content, or none yet?
10. The first elites: which of the six, their kits, and which Fracture each tier spawns them at;
    a Peak elite and a Waste hunter.
11. The boss's escort compositions by tier, hand-tailored in content, and the final's the same.
12. Menace as the one weight for the meter, Anathema and salvage, by the formula or by a number
    on each foe?
13. One rider on one advanced foe a domain: the Ghost's curse, the shaman's Hex; and enemy
    Shock on the shaman or the Reaper, telegraphed, or none (a silence and a purge are
    specials, never riders: decided).
14. The enemy's buffs (section 10): the set as proposed, which foe grants which, and the
    player's Purge as a debuff piece at tier two beside the jellyfish's EMP.

## The bench

Ideas a rule kills here, one line each with the rule, so Ryan can overrule the rule and not
only the idea.

- A formation as two packs, a front and a back, walking together: no peel and no decision while
  they stand adjacent, drift when they part, and the pack row (one sprite, one badge) stands.
- The same unit scaled in place by tier or ramp (a goblin at 5 HP and then at 50): section 3's
  row, Ryan's "that's lame"; a tier's units are their own, with their numbers and names.
- The boss joining fights while sealed, immune: section 2's never-helpless row (a blow source
  nothing in the fight can answer), and the boss row's every-machine rule.
- A Rift Pressure tick per fight or per round fought: section 4's clock row, retired 13
  October.
- A round cap or a boss forced by a turn count: section 5's no-round-limit row; the stall guard
  reads the field, never a clock.
- Packs keeping their damage between fights: a number on the map and attrition by withdrawal;
  the withdrawal's price is already right.
- Elites as one of the random spawns: Ryan, 24 October, guaranteed and mid-battle.
- The Fracture's pick as loot or as part of the pay table: Ryan, 24 October, never loot.
- The whole spawn list arriving as one formation at every pressure peak (the vocabulary's old
  hole): density and count are the ramp's, so one composition a peak.
- Hiding a composition's back rank in battle until scouted: the exact preview (section 3's
  sensor row); scouting is the campaign layer's.
- A silence or a purge as a rider on a foe's blow: a tax with no decision (28 October);
  specials only.
- One enemy verb for keywords and buffs alike, nothing permanent: the domains could not differ,
  and the stack question needs the bought buffs gone.
- A player silence: Suppress holds a special and Disrupt turns one; control stays scarce.
- Another marker on a recolour beside its hue and its name (a ring, a chevron): Ryan, 28
  October, "don't need another marker", the colour sufficiently different and checked by the
  three simulations.
- Anathema deciding a domain's final today: section 3's three-bosses row stands; the tally is
  recorded beside the count until Ryan judges the count against it (section 9's Rec row).
- A roles system the engine reads (a stat or a rule by role): one rule set for foes (section
  9) and Ryan's "I don't want to overcomplicate the enemies"; the word is the codex's.
- Elites scaling with the tier as the bosses do: the escalation row's exception names the
  bosses, the heroes and the line; a tier's elites differ by which come.

## Built this session, without waiting (26 October)

Runner work only; no rule, no content and no screen changed. The reads are in
`docs/measurements.md` (26 October).

- **The squad moves as one** (`sim/battle_bot.gd`, the decided default of section 4's
  four-machines row): the campaign's plain player walks every machine toward the pack nearest
  the squad and fights it with every machine in range, and a caught machine's allies walk into
  range of the hunters before the catch opens; before, each machine walked toward its own
  nearest enemy and a catch was fought by whoever stood in range. `--solo` on
  `tools/campaign_run.gd` keeps the old walk for comparison. What it found: the lone fights
  are the roster's, not the walk's (above), and the alone fights do not move with it (419 to
  416), while the whole squad's fights do (58 to 81). And one rule the bot had been missing
  under main's boss row: a fight needs an order, which needs a machine within attack range of
  the pack, and only then does the boss's fight bring every machine; the bot had been opening
  the boss's fight from across the map on its first turn once the row landed (41% of battles
  won in one fight on the first read of the merged code, a bot artefact and no read), and now
  opens a fight only where an order could.
- **The withdrawing persona on the campaign bot** (`--withdraw N`): the fight bot's persona on
  every fight the player picks, withdrawing once the fighters' hull is under N percent; a fight
  a hunter forced is fought out, since a withdrawal would only leave the machine caught. The
  report says how many fights were withdrawn from, and the fight-size table its share.
- **Composed packs on the balance runner** (`--pack foe:n[+foe:n]`): a cell of one foe type
  times a strength, or several together in one fight, so patrols and a front with a back can be
  read beside the spawn lists' packs.

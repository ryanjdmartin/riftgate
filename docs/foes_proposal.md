# The foes' fresh start: a proposal

The foes get their fresh start in a session of their own, proposed in chat first (the bible's
section 9, the working-set row; the status's order of work, item 3; the to-do's line). Ryan
opened the session on 26 October ("We need to work on the foe refresh"). This file is the
design's one home until he has moved it: the fights' shape, what the rift sends and when, the
Rupture meter with its Fractures and the seal, the elites, the boss with its formation, and the
bots that read it all. Then its decisions become bible rows, `docs/rules.md` and content, and
the file retires (git keeps it). Names are working names, every number a placeholder, and
everything here is Ryan's to move. Nothing in the engine or the content changes before his go;
what this session built without waiting is runner work alone (the last section).

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
  way (section 10's kill row). Not built.
- The boss guards the rift, immune until the Rupture meter fills (section 4's boss row; Ryan,
  24 October; the seal is not built). Withdrawing from its fight stays open.
- One clock, Rift Pressure, ticking on the map and never in a fight; a long fight costs one map
  turn like any other (section 4). Rift Pressure's escalation and its backstop are Ryan's pacing
  session (section 12).
- Difficulty grows by smarter foes and nastier compositions, never by inflating the rank and
  file: aims, conditions, behaviours, back ranks, elites and pack count (section 3). The curve by
  stage is Recommended (section 3's curve row): early simpler foes, thinner formations, a longer
  timer, about one elite; middle mixed, denser, shorter, elites with curveballs, guests; late
  little fodder, very dense, short, elites regular. Its form is open in
  `docs/curve_proposal.md` (Ryan's tier and ramp, or Claude's deepening rift).
- Each foe picks at random by default, by an aim where its threat calls for one; the foes never
  over-commit (section 5's aim row, 24 October). One rule set for foes: one or two moves for the
  rank and file, three for a boss or a hero, a special never twice running (section 9).
- The roster comes in tiers; size, rank and complexity are apart from the tier. An elite is a
  spawn of one or more unique packs outside the spawn list, a guaranteed miniboss event in the
  middle of a battle, about one an early battle and more later, worth a larger chunk of the
  meter; a boss's mechanics stay inside the skirmish, an elite's may work on the map (section
  9's tiers row, Ryan, 23 and 24 October). The Treant, the Magma Elemental and the Sandworm are
  rank and file; the Bone Wyvern is an elite unless a better setup comes. The slate is
  `docs/bosses_proposal.md`.
- A rank is a foe's only role until Ryan proposes a system (section 9, Open).
- The enemy stands in two ranks of four; reinforcements fill gaps at the end of each enemy turn
  (section 5). No round limit. Withdrawal costs one enemy turn and the survivors return whole.
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
- **A fight is one pack, mostly** (`docs/campaign_run.md`, 22 October, the plain player): 856
  fights, 638 of them one machine alone, 421 against one pack; a lone machine wins a quarter of
  its fights, and the campaign's player wins no run of 40 and 1% of battles. The lone fight is
  the bot's doing as much as the map's (its walk split the squad; the last section), but a
  formation's back rank enters a fight only through a formation, and three of the four spawn
  lists hold one back-rank type.
- **Formations are the only decision, and they read easier at random** (24 October): the rank
  and file at random cost the trios a few points of hull and up to seven of wins against the
  old aims; the lone fights did not move. The formations' pressure is the balancing's to
  restore, and an advanced foe's aim is a lever on top.
- **A lone massive foe is no exam** (23 October): without a breach it deals about a trio's
  standing shield over eight rounds and costs 1% of its hull; the two that breach cost 42 to
  56%. A four kills any of them in two to three rounds.
- **Nothing waits to be trapped**: eight slots hold a whole spawn-list pack, so the Lammergeier's
  mines and the Marsh's Reraise find a reinforcement step with nobody in it outside the
  formations (the to-do's Lammergeier line).
- **The heroes' finals come easier than a formation** for a starter (23 October: 99 to 100%
  won but the Martial Artist's 99 at 29% hull), since a hero stands with three columns of its
  domain's first pack and nothing behind.

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
- It unpacks into the skirmish as the harness's composed enemy side and the runner's mixed cells
  already do: every member's foes into the pool, the heaviest hitters deploying left.
- The boss unit is already this shape (its commanders and its escort), so the engine gains one
  structure rather than a second: a pack's **members**, each a foe type, a strength and whether
  it commands.

Why one hex and not a front pack and a back pack walking together: while two packs stand
adjacent either's ring joins the other, so two hexes buy no peel and no decision, only drift
when their speeds part and the map code to hold them together; and the pack row (one sprite,
one badge) stands. Claude's lean. The two-hex form is on the bench.

Content: a domain's `spawn` list becomes its **compositions**, each a size (below), the tiers
that may deal it, and its members:

```json
{"id": "goblin_warband", "size": "formation", "tiers": [0, 1],
 "members": [{"foe": "goblin", "strength": 5}, {"foe": "mandragora", "strength": 2}]}
```

The compositions are content, authored by hand and proposed in chat (CLAUDE.md), never
generated: a domain's shape on the map is its author's to draw. A composition of one member is
today's pack, so the file reads as it does now with a size and a tier band added.

### 2. The fight-size spectrum

Four sizes, each a hull cost at the squad the stage fields (the four-machines row's own
numbers), produced by the compositions and never by a rule:

| Size | What it is | Who takes it | What it costs (the target) | The meter |
|---|---|---|---|---|
| A patrol | one or two front types, two to four foes, no back | one machine, a detachment; two for safety | about a tenth of the machine's hull, two or three rounds | little: a tenth of a formation's |
| A formation | a front of bodies and a back of problems, six to twelve foes, the overflow waiting as reinforcements | the body: three or four machines | about a tenth of a four's hull, a fifth to a third of a trio's; five to eight rounds | the unit the Fractures are counted in |
| An elite | a unique composition outside the list, one or more packs, a miniboss event | the whole squad, or whoever it catches | a formation's cost and a curveball besides | a larger chunk than a formation |
| The boss with its formation | the boss, sealed until the Rupture, with an escort of its domain's advanced foes in the other columns | the whole squad, worn | the exam: the boss three to five rounds with its mechanics (section 2), its escort beside it | the end |

A battle at competent play costs 60 to 80% of a fresh squad's hull (the pacing row's target),
which four to five fights at a tenth each, the elite, and the boss's formation add up to.

### 3. What the rift sends, by stage

The rift's tier (set as the rift opens, shown on the card) picks **what** comes: which
compositions (simple or advanced by their members), how many elites and which, the bosses, the
Fractures. The ramp (the Convergence, live, never shown) sets **how many and how fast**: the
compositions on the field at the start, their density, and Rift Pressure's fill. That is the
split of `docs/curve_proposal.md`'s tier-and-ramp form, Claude's lean there; the engine built
here carries a rift's tier as one number and the ramp as another, so either form is a one-line
choice of where each number comes from. Placeholders, by the Convergence's three tiers:

| | Tier 1 (early) | Tier 2 (middle) | Tier 3 (late) |
|---|---|---|---|
| On the field at the start | one formation, two patrols | two formations, two patrols | three formations, one patrol |
| A formation's members | six to eight | eight to ten | ten to twelve (the overflow waits) |
| A patrol's members | two or three | three or four | four, or none |
| Who comes | simple types, the domain's identity a lean | simple and advanced mixed, sharper identity, a guest | advanced, sharp identities with guests, little fodder |
| Rift Pressure fills at (the timer) | 12 turns | 10 | 8 |
| Elites a battle, and when | one, the harder-fight kind, at the first Fracture | two, with curveballs, at the first and third | two or three, at the first, second and fourth |
| Fractures to the Rupture | three | four | five |
| The boss's escort | a patrol's worth | a formation's | a formation's, advanced |

A rift's cycle at a pressure peak deals the domain's next composition fitting the tier, patrols
and formations alternating, the guest's alternating with the lead's from tier 2 as today.
Section 3's never-inflate row holds: nothing here raises a foe's numbers. What rises is count,
density, who comes and how soon.

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
and what it brings follows.

**The Rupture** is the last Fracture: the boss's seal breaks. The seal: while it holds, the
boss cannot be ordered onto, joins no fight (its ring is inert) and stands patrolling its
ring of the rift as today, marked SEALED on the map; the pressure spawns appear at the rift
beside it as now. Claude's lean on section 12's question (may a sealed boss still join fights
in its ring): no, since a foe that strikes in a fight and cannot be hurt in it is the
helplessness section 2 removes; the other form (it joins, immune) is on the bench. Withdrawing
from the boss's fight stays open, as decided.

**The stall guard** (Claude's lean, a hole named below): the Rupture also comes when no
composition but the boss's stands on the field and none waits at the rift, so a team that has
cleared the field is never left waiting on Rift Pressure to earn the last points. Its share is
read by the runner; if it opens most battles, the thresholds are too high.

**What a Fracture brings.** Two things in this proposal, and one left open:

1. The elite's moment (section 5 below): the Fractures the tier names spawn the battle's elites,
   so the miniboss event is guaranteed and lands at the same point of progress for every team
   however fast it plays, mid-battle by construction. Claude's lean on section 12's question;
   the alternatives (Rift Pressure's tick, a turn count) are on the bench.
2. The boss's seal at the last.
3. Open: the reward pick (section 8: one of three, a battle-long modifier, a one-shot or a
   boon; Ryan, 24 October: the picks are the battle's roguelike part, never loot, "designed only
   in high-level theory, and maybe not warranted at all"). Claude's lean: build the meter, the
   Fractures and the seal without a prize first, since they pace the battle on their own (which
   fights to take, weighed by menace against the gate and the clock, and when to go for the
   boss); whether a prize rides each Fracture is decided after they are played, with the
   economy pass. The hole: without a prize the meter is a clock the player cannot ignore and
   nothing more; the decision it leaves is the order of fights and the detachments' worth,
   which the four-machines row already prices.

Rift Pressure stays the rank and file's clock and the stall's price: its fill by the ramp (the
timer), one composition a peak, no escalation inside a battle (the pacing session's).

### 5. The elites

Ryan's definition stands (section 9's tiers row). What this proposal adds is the mechanism and
a first set, each a candidate from his marks (`docs/bosses_proposal.md`), with a kit from the
engine's existing effects wherever one serves, so the set is buildable the day he picks it.

**The mechanism.** A domain's content names its elites, each a composition of size `elite`
(an elite foe, flagged `elite`, and whatever stands with it). At each Fracture the tier names,
the next elite of the rift's domain not yet fought this battle spawns at the rift's nearest
free hex, announced on the plaque, and acts by its lead: a hunter heads for its prey, a pusher
for the gate. Its curveball is one of four kinds, three of which the engine runs today:

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
| The Leshy (Ryan, 24 October: liked, maybe a foe of its own) | Meadow | the swarm, a commander | not massive, back | Call of the Wild (summon two wolves, few_waiting), Root Snare (disable), a blow (3) | a wolf pack: the forest keeps coming |
| The Old Man of the Desert (Ryan, 24 October) | Waste | the harder fight | massive | the Sandworm's kit at an elite's numbers: Swallow breach 10, Burrow brace 4, Quake | four needlers: fixed damage round a breach |

Two elites in each of two domains, one in the Waste and none in the Peak (its candidates are
the slate's bosses' kin); a Peak elite and a Waste hunter are for Ryan's marks, from the
candidates or new. The Reaper and the shaman are the hunter foe and the commander foe section
12 asks for, as elites first.

### 6. The boss with its formation

Every boss unit comes with an escort composition from content, dealt by the tier (a patrol's
worth early, a formation's later; the table above): the boss in its column and the escort's
front and back in the rest, so the boss fight is the exam and never a lone massive foe a four
kills in two rounds. The engine already fields a final this way (the hero with three columns of
the domain's first pack); the final takes the tier's escort too, so a hero's final is no easier
than a formation. The bosses' slate (`docs/bosses_proposal.md`) lands as content alone, as
decided; until it does the four massive foes stand in, and the Treant, the Elemental and the
Sandworm join their domains' compositions as the slate takes their slots.

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
- Reinforcements worth trapping (the Lammergeier's mines): formations of ten to twelve at tier
  3, the Marsh's Raise, the Leshy's wolves, and an elite swarm.
- Foes with more than one move (the jellyfish's Disrupt): most of the rank and file carry two
  already; compositions put them in every fight.
- Riders on machines in every domain (the Ward, Mastema's mover): the Peak has heat, the Waste
  breach, corrupt and disable, the Meadow the Gel's breach alone and the Marsh the Zombie
  Knight's. Claude's lean, content for Ryan: one rider on one advanced foe a domain by its
  fantasy, the Ghost's Hex Bolt a curse (corrupt 1) and the shaman's Hex the Meadow's; the
  Meadow's identity otherwise stays numbers, so the Ward has little to do there by design.
- Enemy Shock, telegraphed, if any (Claude's lean of 15 October: a hero or an elite first):
  a mark on a machine that doubles the next foe blow it takes, on the shaman's Hex or the
  Reaper's Knell, so the Barrier has its best moment; a new rider, small. Ryan's call.
- An enemy silence or purge: the shaman the lean carrier of a silence (section 12 says so
  already); a purge stays a promoted form's or a boss's.

Out of scope here and left where they are: the heroes' extra moves and the Martial Artist's
four (`docs/heroes_proposal.md`), the Rune-bearer's execute, and the recolour tier (section 9,
Open).

### 8. The bots

The campaign report reads nothing while every run is lost, so the player that reads the fresh
start comes first (section 12's campaign question, Claude's lean there). Built this session,
the last section: the squad moves as one, and the withdrawing persona. Next, with the go: the
runner reads the meter (Fractures reached a battle, turns to the Rupture, the stall guard's
share), the elites (fought, withdrawn from, the gate they took) and the fights by size; and the
front-choosing persona `docs/curve_proposal.md` asks for, so the tier's trade can be read.

## A battle, as proposed

A tier-1 Meadow battle, the stock trio. On the field at the start: a goblin warband (five
goblins, two mandragoras) in the north centre, a wolf patrol (two wolves, hunting the slowest)
on the west, a gel patrol (two gels) on the east; the Treant sealed at the rift with two
goblins beside it. Turn 2 the wolves catch the Puffin: the first fight is the squad's, a patrol
(menace 8). Turn 4 the warband (23): the tally is 31, the first Fracture at 20 fell in that
fight, and as it ends the plaque names it and the shaman's warband appears at the rift, pushing.
Turn 6 the gels (10) and turn 7 the warband (28): 69, the second Fracture at 50. Rift Pressure
peaks on turn 12 and the next formation emerges; it dies on turn 14 (20): 89, one short of 90,
and the field is clear, so the Rupture comes by the stall guard and the Treant's seal breaks. The
boss and its escort, turn 15 and 16; the battle about sixteen turns, six fights and the boss.
The hole it shows: the thresholds are set so the starting field and the elite carry the tally
almost to the Rupture and a pressure spawn or the guard carries it over, which the runner reads
across many battles before any number is kept.

## What is built on the go

The sim first, headless and tested, then the runners, then the screen's pieces.

- **Content** (`content/factions.json`, `content/foes.json`, the validator): compositions with
  a size, a tier band and members; a foe's `elite` flag and `gate_blow`; each domain's elites
  and its boss escorts; the role word if Ryan wants it. The validator refuses a composition
  without members, a hero in one, an elite without the flag, and a size outside the four.
- **The pack as a composition** (`sim/unit.gd`, `sim/content_db.gd`, `sim/battlefield.gd`,
  `sim/battle.gd`): members on the unit, the boss unit's lineup and escort folded into them;
  `foes_for` unpacks members; the ring, the pace and the behaviour read off the members;
  survivors by member; the placement at setup by the tier's counts, compositions spaced so
  their rings do not chain; the spawn cycle dealing compositions. The harness's composed enemy
  side and the runner's `--pack` cells are compositions already.
- **The rift's tier and the ramp** (`sim/campaign.gd`, `sim/battle.gd`): a rift keeps the tier
  it opened at; the battle reads the tier for what comes and the Convergence for the counts
  and the timer, each a table of placeholders in one place.
- **The Rupture meter** (`sim/battle.gd`): the live tally of menace, the Fractures by tier,
  the elites' spawns at the Fractures named, the seal on the boss unit (no order, no join), the
  Rupture by the last Fracture or the stall guard, the salvage and Anathema tallies on the same
  weight (Anathema recorded beside the count of three bosses, which still decides the final).
- **The elites** (content and `sim/`): the first set as Ryan marks it; the blitz's gate blow;
  an enemy Shock rider if he wants one.
- **The runners**: the campaign report's meter, elite and fight-size reads; the balance
  runner's composition cells by domain and tier (`--pack` today, the content's compositions as
  rows of cells on the go).
- **The screen**: the meter bar with its Fracture notches under the gate's, the SEALED mark on
  the boss and its break, the plaque at a Fracture and at an elite's arrival, the composition's
  members on a tap. The sim lands first; the screen's pieces are a pass of their own and are
  judged running on the phone.
- **The records**: the bible's rows (section 4's pacing row to Decided as far as Ryan takes it,
  section 9's roster and elites rows, the pack's definition), `docs/rules.md`, the vocabulary
  (Composition, Patrol, Formation, Menace, the Rupture meter's entries from planned to
  implemented), the to-do and the status.

## How it is measured

- The grids of 23 October rerun by stage: every starter trio against the tier-1 compositions
  (patrols, formations, the elites, the boss with its escort) and the five endgame fours against
  the tier-3 ones, random and greedy at 30 seeds as a direction, the bands at 200. The tests:
  a patrol costs one machine about a tenth, a formation a four about a tenth and a trio a fifth
  to a third, the boss's formation is the exam, no composition hands a squad a free win at its
  stage.
- The campaign report, the squad moving as one: runs won, the fights by size, Fractures reached
  a battle, turns to the Rupture, the stall guard's share, elites fought, the gate the pushers
  took; with and without the persona.
- The fight-size table of this session (below) as the baseline the compositions are read
  against.

## Questions for Ryan

Each with Claude's lean; a question answered in chat lands as a row and leaves this list.

1. A pack as a composition on one hex (section 1), or a formation as two packs that walk
   together? Lean: one hex.
2. The curve's form (`docs/curve_proposal.md`): the tier and the ramp, or the deepening rift.
   The engine built here serves either; the table in section 3 is written for the first.
3. The elites' moment: a Fracture (lean), Rift Pressure's tick, or a turn count?
4. The sealed boss: joins no fight while sealed (lean), or joins and takes no damage?
5. The stall guard: the Rupture also comes once the field is clear (lean), or the player waits
   on the clock?
6. The Fracture's prize: the meter, the Fractures and the seal built without one first (lean),
   the pick decided after they are played; or the pick built with them, one of three as
   Recommended.
7. Does a pack keep its foes' hull and statuses between fights? Lean: no, the survivors return
   whole as today, since the withdrawal's price is already right (section 4's boss row) and a
   wounded pack is one more number on the map; reopens if hit-and-run farming shows in play.
8. Roles: the six words, shown in the codex or internal to content, or none yet?
9. The first elites: which of the six, their kits, and which Fracture each tier spawns them at.
10. The boss's escort by tier, and the final's escort the same.
11. Menace as the one weight for the meter, Anathema and salvage, by the formula or by a number
    on each foe?
12. One rider on one advanced foe a domain: the Ghost's curse, the shaman's Hex; and enemy
    Shock on the shaman or the Reaper, telegraphed, or none.
13. The density and the timer by tier, after the runner has read the placeholders.

## The bench

Ideas a rule kills here, one line each with the rule, so Ryan can overrule the rule and not
only the idea.

- A formation as two packs, a front and a back, walking together: no peel and no decision while
  they stand adjacent, drift when they part, and the pack row (one sprite, one badge) stands.
- Inflating the rank and file by tier (HP or blows rising with the Convergence): section 3's
  never-inflate row; the ramp is count, density and who comes.
- The boss joining fights while sealed, immune: section 2's never-helpless row (a blow source
  nothing in the fight can answer).
- A Rift Pressure tick per fight or per round fought: section 4's clock row, retired 13
  October.
- A round cap or a boss forced by a turn count: section 5's no-round-limit row; the stall guard
  reads the field, never a clock.
- Packs keeping their damage between fights: a number on the map and attrition by withdrawal;
  the withdrawal's price is already right (section 4's boss row).
- Elites as one of the random spawns: Ryan, 24 October, guaranteed and mid-battle.
- The Fracture's pick as loot or as part of the pay table: Ryan, 24 October, never loot.
- The whole spawn list arriving as one formation at every pressure peak (the vocabulary's old
  hole): density and count are the ramp's, so one composition a peak.
- Hiding a composition's back rank in battle until scouted: the exact preview (section 3's
  sensor row); scouting is the campaign layer's.
- The recolour tier (Gel, Bubble Gel, Metal Gel) as a bigger number: section 9's Open row
  against never-inflate; a recolour that changes behaviour is a new foe and free.
- Anathema deciding a domain's final today: section 3's three-bosses row stands; the tally is
  recorded beside the count until Ryan judges the count against it (section 9's Rec row).
- A roles system the engine reads (a stat or a rule by role): one rule set for foes (section
  9) and Ryan's "I don't want to overcomplicate the enemies"; the word is the codex's.

## Built this session, without waiting (26 October)

Runner work only; no rule, no content and no screen changed.

- **The squad moves as one** (`sim/battle_bot.gd`, the decided default of section 4's
  four-machines row): the campaign's plain player walks every machine toward the pack nearest
  the squad and fights it with every machine in range, where before each machine walked toward
  its own nearest enemy and the squad fell into lone fights three times in four; `--solo` on
  `tools/campaign_run.gd` keeps the old walk for comparison.
- **The withdrawing persona on the campaign bot** (`--withdraw N`): the fight bot's persona on
  every fight the player picks, withdrawing once the fighters' hull is under N percent; a fight
  a hunter forced is fought out, since a withdrawal would only leave the machine caught. The
  report says how many fights were withdrawn from, and the fight-size table its share.
- **Composed packs on the balance runner** (`--pack foe:n[+foe:n]`): a cell of one foe type
  times a strength, or several together in one fight, so patrols and a front with a back can be
  read beside the spawn lists' packs.
- **The reads** are in `docs/measurements.md` (26 October): the fight-size probe and the four
  campaign runs.

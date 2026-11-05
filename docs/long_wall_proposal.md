# The long wall and the formations: a proposal

Ryan's direction of 5 November, from his play of the game beside other roguelikes: the map
phase flipped from a push to the rift into the defence of a long wall, and the skirmish's packs
made designed formations that pose a question. This file holds his words where they set the
strength, what the records already say about each point, the holes raised in the first round,
and Claude's leans for his marks. Nothing here is decided and nothing is built. On his go, each
decision becomes a bible row, `docs/rules.md` changes in place, and this file retires (git keeps
it). Every number is a placeholder.

## 1. Ryan's direction (5 November)

- The map phase is "a janky, flawed design": "We're never going to get a balanced, satisfactory
  'push through to the boss killing things on the way' with how we're set up, with fractures and
  so on." The elegant version is "the core of the original brief: defend the gate from a horde."
- Today "the only way it's getting overwhelmed is if the player opts out of fights ... So it's
  fight and lose, or fight and win, and the map might as well not be there."
- The flip: "Wide map, with lots of wall to defend, but not as deep. So instead of vertical
  scrolling, we go to horizontal scrolling. Or, we offer an alternate portrait view with the wall
  on the left, with vertical scrolling to see the length of the wall." The flattening still
  advances and puts the tears closer, "and those are far more threatening with the map
  orientation shift, since every hex closer to the wall matters so much more." Rift packs "don't
  need to take the shortest path to the gate, they can target a segment left or right of it,
  reducing clogging and creating extra tension. The variance of where they target can even be a
  ramp factor."
- The engagement system: "it was easy to pick off targets or head off pushers, meaning that the
  formations we were trying to balance around, I was able to circumvent completely ... it just
  adds so much complexity for not a lot of gain. If packs were formations, either completely
  predetermined by the engine or semi-random combinations, we would be able to craft far more
  engaging skirmishes with clear identities and patterns, threats and responses. That's the
  spark the skirmish is missing, and why it feels flat right now."
- The skirmish's flatness: "none of them actually DO anything that makes me actually react as a
  player on a tactical level. I'm dealing with each enemy individually ... There's no real
  decisions to be made other than 'who is taking damage this round'." And greed is free: "in
  this game I am rarely, if ever, punished for chasing my best die faces ... In slice and dice,
  you really consider before each reroll, if it's worth rerolling."
- The aim: "make sure that executing the player's build strategy is satisfying, while throwing
  enough wrenches in to keep it interesting. Right now we have 'kill or be killed', I want to see
  if we can rework things and try to push it a bit more into 'can they stop me from winning'."
  There is "not enough room to execute a setup-payoff strategy".
- The fallout: interceptors lose their job and become "flankers and firefighters", movement "a
  way of getting from one hotspot to the next, their longevity being a real strategic resource";
  the squad's configurations "1-2-1, 2-2, 1-3, and possibly all four" each viable.
- To consider with it: base shield regen and cooling back "as a build-strategy buffer"; a full
  shield recharge after a skirmish and the field recharge stat removed; withdrawal riskier so
  that damage and status persist after it, "enabling guerilla tactics"; wide-format map
  generation with interesting features ("the current map archetypes are pretty brute-force and
  uninspired"); what a Fracture means (checkpoints with rewards, scrapped for the Rupture alone,
  a boss always available that each Fracture weakens, or Fractures breaking tangible barriers on
  the field until the boss is exposed); width and depth as a difficulty factor no longer fixed;
  the default camera farther out once the rings and the band are gone.

## 2. What the records already say

Read before anything is proposed (CLAUDE.md). Each point, the row or the run, and what Ryan's
play adds to it.

- **The clock never fires.** The campaign runner's plain player (`docs/campaign_run.md`, 30
  October): battles last 7.7 phases (3 to 16) against a timer of 12, so Rift Pressure peaks 0.00
  times a battle, the rift sends nothing and no tear opens; what the player meets is the field
  placed at the start. The three-clocks row's own arithmetic said the same of the old clock ("a
  fifteen-turn battle saw one pack, so the timer priced nothing") and the to-do's answer was a
  shorter timer (Claude's lean 8 to 6). Ryan's play says the shape is wrong, not the number:
  a battle that is "clear what stands there" has no horde in it.
- **The tears row named the hole this proposal answers.** "The split comes from the seam's row
  more than its spread, since on a field nine wide a flank is one move away." Ryan's own shape
  for the tears (30 October): "spreading other rifts across the X axis of the map makes it
  harder for the player to stay grouped, which forces riskier detachments." Nine wide cannot
  deliver that; a long wall can.
- **The width was parked, not refused.** The grid row (30 October): "a wider map would need
  horizontal scroll, which he was never against while the map-edge tags work", parked as a
  finale lever. The reasons given for nine: the thumb's limit (a hex at the circumradius 48,
  "the map must not get smaller", 23 September), and that "every lane past nine is one the
  squad was never going to cover". The second reason now cuts the other way: lanes the squad
  cannot all cover are what make "where do I defend" a decision at all.
- **The compositions are placeholders.** The pack row: "the first set a partition of the
  ladder's lists by tier, placeholders for Ryan's marks" (a warband is six goblins and two
  mandragoras). The design test "Every pack poses a question" (section 2) is Decided and unmet
  by the content as partitioned; the fresh start's roles are "open, nothing built". So "none of
  them DO anything" is the known state of the content, and the engine already carries the
  verbs a question needs: breach, countdown, rally, follow-up, silence, purge, cleanse, summon,
  swallow, merge, drain, grudge, web, a foe in parts, a last act.
- **Low stakes a fight are by design.** The kill-time row: rank and file "die to a die or two",
  "on trash there is no gap, by design", the coordination gap opens on the big foes alone; the
  pacing row: "a meaningful fight costs a four about a tenth of its hull"; the wear test: four
  hard fights leave a machine worn, not wrecked. The stakes were put on the battle (hull that
  never heals) and taken off the fight. Ryan's "who is taking damage this round" is the only
  question because the answer barely matters this fight.
- **The detachment is punished too hard for a split to be a plan.** The campaign runner: a
  lone machine against a patrol wins 45% (plain) to 50% (turtle) of its fights; the detaching
  player wins no run, "a detachment pays, as the design wants, and the patrols cost more than
  their tenth". The four-machines row sizes the fights for a squad moving as one.
- **"A few machines against a horde" is the concept's own row** (section 1), and "Few machines
  against a horde is the fantasy" (section 6). The defence frame is not a reversal of the
  concept; it is the concept. What it rewrites is "Damage sticks ... The battle is a race to
  close the rift" (section 4), the race's half.
- **Heat already resets each fight** (Ryan, 4 November: heat is never carried between fights,
  "the skirmish's own bite comes first"). A shield that resets after a fight makes the shield
  the same kind of resource as heat: the fight's. Hull stays the battle's.

## 3. The battle as a defence

### The field, and what the phone can show

The sim is already orientation-free: `Battle.setup(team, faction, w, h)` and
`BattleMap.generate(w, h, seed, kind)` take any width and height, the rift on row 0 and the
gate on the last; the view draws it. Rows run rift to wall; "wide" is the wall's length.

The screen is 720 design pixels wide (`project.godot`), 1616 tall on the Pixel; a hex is a
pointy-top of circumradius 48 (`BattleMapView.HEX_SIZE`): 83 wide, rows 72 apart. Today's nine
columns are 790 wide and twenty rows 1440 tall: one screen, near enough.

- **Wall at the bottom, scrolled sideways** (Ryan's first option): twenty columns at today's hex
  are 1660 wide, 2.3 screens; thirty are 3.5. The map-edge tags for what is off-screen are the
  cost the grid row named.
- **Wall on the left, scrolled down** (his second): the field's long side runs down the screen,
  the scroll the portrait's natural one. The depth runs across the screen, so the depth is what
  the thumb's floor caps:

  | Hex circumradius | Flat-top hex, wide × tall | Depth that fits 720 across | Wall length on one 1616 screen |
  |---|---|---|---|
  | 48 (today) | 96 × 83 | 9 | 19 |
  | 44 | 88 × 76 | 10 | 21 |
  | 40 | 80 × 69 | 11 | 23 |
  | 36 | 72 × 62 | 13 | 26 |

  A rotated pointy-top is a flat-top, whose columns are straight, so the wall is a straight line
  and the team's line along it is too (pointy-top kept, the wall is a saw-tooth of bastions: a
  look, Ryan's). Every size above stays over a thumb's 48-pixel target; the floor of 23 September
  was set on a nine-wide map with rings, a band and routes on every hex, which this proposal
  removes.

  Claude's lean: the wall on the left, flat-top, the depth 10 to 12 and the wall 20 at the start,
  longer as the ramp or the tier says (section 3.5), one screen across and a short scroll along
  the wall; the finale's wider field, already parked, is the same lever pulled hard.

### The clock: waves, not a field

Today the formations stand on the field at the start as the meter's fuel and the rift sends
nothing in a fought battle (section 2). In the defence, the horde comes:

- The first wave stands on the field at the start, three or four turns out, so turn one has a
  plan; the rift sends a wave at every peak of a short timer (three turns at the start, two at
  the top: the ramp's); every tear open before a peak sends a patrol, as today; the seam creeps
  and the tears open on it, as today, now two or three hexes from the wall.
- A pusher draws a wall segment as its goal, not the gate's column: at the ramp's foot the
  segment near the rift's column, at its top anywhere along the wall (Ryan's "variance of where
  they target can even be a ramp factor"). The whole wall is struck already (the wall row), so
  the goal changes only where the pack arrives, which is the whole point: where it arrives
  decides who can reach it.
- The depth sets the response window: a pack at move 2 crosses a 12-deep field in five turns,
  a 10-deep one in four; a tear on the seam two hexes out sends a patrol that strikes the turn
  after it lands. A spawn is seen for a whole turn (the tears row), so the window is one turn
  and only a machine within its move of that segment meets it. The width sets the spread the
  squad must hold. Both are the ramp's levers, never fixed (section 3.5).
- The meter's thresholds today are fractions of the field's menace at the start; with the
  field thin at the start they read from the battle's waves (the cycle's compositions at the
  tier), a table by tier, the last at two thirds as today.

### Fights: one pack is one fight

- A fight is the pack ordered onto, and nothing joins it: no ring, no band, no attack range
  past adjacency (or two, a placeholder, so a pair reaches one pack without blocking each
  other). The map prices a fight with time (the turn it costs, the wall the other packs reach
  meanwhile), never with size. This reopens the fights-picked row (section 6).
- The pack carries its whole threat alone, so every pack is a designed fight (section 4) and
  "fight them one at a time" is always the plan; the map's question becomes "which, and can I
  get there in time", not "how many at once". What is lost with the rings is the one lever the
  map had on a fight's size; Claude's lean is that the lever was the circumvention Ryan found,
  and a designed pack is the better home for the threat.
- Hunters stay: a pack whose lead hunts walks for one machine and forces the fight when it
  reaches it (its pounce of two kept as its own reach, Ryan's of 29 October), since a hunter is
  what punishes standing still on the wall. The sealed-off prey rule stays.
- Withdrawal stays open at any point of the player's turn and costs the enemy's full turn, as
  today; what carries past it is section 4.3's.

### Movement and the squad's shape

- Movement is the time between hotspots: a car at move 5 covers ten hexes of wall a turn, a
  tracked body at 3 six. The crossing chassis (eleven of twenty-four) cross a divider the
  ground must go round, which on a long wall is worth what the crossing row priced it at.
- The squad's shapes (1-2-1, 2-2, 1-3, four) are viable only if the packs come in sizes a
  machine, a pair and a four can fight (section 4.4). The four-machines row's "concentration
  halves the hull a fight costs with every machine added" is the arithmetic a sized pack
  answers.
- The interceptor's job (a fast machine picking off a pack before it joins) goes with the
  rings; its new job is the firefighter's. Kestrel's line keeps "flying is the map identity"
  and Exposed in the fight; the Kestrel row and `docs/briefs/kestrel_line.md` restate the fantasy
  when this lands. Sunk cost counts for nothing (CLAUDE.md); the cost still to come is a
  sentence in each.

### The Fracture and the Rupture

Ryan's four shapes, each against the records, then Claude's lean:

- **Checkpoints with a roguelike pick.** The prize is section 8's Open row ("maybe not
  warranted at all", 24 October), decided with the economy pass; a wave beaten could pay a
  one-shot. Nothing here needs it.
- **Scrapped, the Rupture alone.** The meter still needs thresholds; a Fracture is its notch
  and the elites' moment and costs nothing kept.
- **The boss always available, weakened a Fracture.** Collides with the seal's reason (a boss
  that cannot be hurt in a fight nobody leaves is the helplessness section 2 removes) unless the
  early fight is hard and legible rather than impossible: the escort shrinks a member a
  Fracture, or a boss in parts loses a part's guard. The decision "go now or wait a Fracture" is
  real only when the readout shows the exam as it stands.
- **Fractures breaking barriers on the field.** On a shallow field the barrier is the rift's
  own shell: the mouth walled but for one crossing, each Fracture breaking a span (a wider
  crossing, the next wave through it, the elite emerging there), the last breaking it whole and
  exposing the boss. Progress and escalation are one picture, the seal stays, and every built
  piece (the meter, the thresholds, the elites at the Fractures, the stall guard) stays.

Claude's lean: the shell. It is one visible thing added, the elites already emerge at the rift,
and the boss's fight stays the battle's last decision (its row), three or four turns from the
wall on a shallow field. Bench: the boss as the last wave, coming to the wall at the Rupture
(the fight takes every machine wherever it stands, which is already the rule), against the seal
row's "won by killing the boss that powers the rift" at the rift; it trades the sally's decision
for a countdown.

### Width and depth as levers

The curve row: the tier is the kind, locked and shown; the ramp is the count and the speed,
live and unshown. The depth is speed (how many turns the horde takes) and the width is count
(how much wall the squad must spread over): both the ramp's, as placeholders in `sim/ramp.gd`,
read by the campaign runner; a finale's field wider still is the parked lever. The front card
shows the shape's word; whether it shows the wall's length is Ryan's (a long wall is intel).

### The camera

With no rings, no band and no routes on every hex, the map carries the packs, their walks, the
tears, the seam and the squad. A farther camera is then a smaller hex, which the table above
prices; the floor is Ryan's to move once he has seen a long wall on the phone. The 3D map draws
at any hex size (`Map3D.setup` takes it).

### Map generation

The generator was laid for twenty rows: it reserves four rows at the rift's mouth, two for the
team, two for the wall and one more, so a shape lays its water and walls in what is left.
Today's generator at 24×12 (seed 7, read as text in this session):

- RIVER CROSSING lays a moat along the wall with two fords, four rows out: a defended ford is
  a hotspot for free.
- RUINED CITY lays one band of towers along the wall with one street, three wide: an outer
  wall with a breach, which is exactly a feature.
- BADLANDS lays its mesas and ponds across the width and reads fine.
- FJORD, GORGE and OPEN STEPPE degenerate: a fjord "down the field" has four rows to run in
  and never reaches the wall, so it divides nothing; the gorge is two stubs; the steppe is bare.

So the rotation is not a loss, and the shapes' idea holds (each tests one thing the movement
rule prices): across the wall a river is a moat, down the field a fjord or a gorge is a divider
that cuts the wall into sectors a ground machine cannot cross between, the city a breached outer
line, the badlands winding ways. What Ryan calls brute-force is the laying by noise and chance.
Claude's lean, in the spirit of his formations: authored sectors. A wide map is a row of three
to five sectors, each four to eight hexes of wall by the field's depth, drawn from a sector
library by shape (a ford, a causeway, a breached outer wall, a hamlet, a divider's end, open
ground), each sector one feature with a name, stitched with the crossing guarantee per sector;
the shape's word on the front card, the sectors' names on a tap. Authored chunks in a random
order, never generated whole, so every battle reads and none repeats. Proposed in chat before
any is laid; the map survey reads the result.

### City defences and the commander

The city-defences row ("stand along the wall and can be targeted", not built) and the
commander's battlefield abilities (section 8: sprint, airlift, artillery that covers the
southern half) have their natural home on a long wall: a turret covers a segment the squad
leaves, an airlift moves a machine across the wall, artillery softens the pack at a far
segment. Nothing here designs them; the long wall is where they will matter.

## 4. The skirmish: tight fights, and formations with a question

### 4.1 The diagnosis, with numbers

- **Greed is free because fishing is cheap.** A tier-one die has four to seven entries (the
  Skua and the Cottonmouth four, the Badger five, the Baboon seven) and the team has three
  rerolls a round that cost nothing but the faces on the dice left unlocked. On a four-entry
  die the chance of reaching a named entry in a round is about 78% (a quarter on the roll, then
  a third a reroll since a reroll never lands on the entry showing); two named entries on two
  such dice about 60%; on a six-entry die 57%. Slice and Dice at two rerolls on a six-face die
  is under half, and its faces are uneven. Ryan's flechette-and-flakshot "almost every round"
  is the arithmetic.
- **Nothing in the fight threatens anything.** A rank-and-file blow is 2 or 3 at tier one; a
  tank's armour 2 walls it and a shield of 8 to 16 absorbs the rest, against hull 20 to 50 that
  no fight is meant to take more than a tenth of. The injury threshold (a quarter of maximum
  hull in one blow) is never reached by the rank and file, so the one punishment for holding a
  die out exists in the rules and never fires. The shield returns only at the field rate, so a
  fight's damage is the battle's, invisible in the moment.
- **The verbs exist and the compositions do not use them.** Section 2.

### 4.2 The resource shape: shield the fight's, hull the battle's

Claude's package for Ryan's "can they stop me from winning", each piece his to move:

- **The shield refills after a fight the pack lost.** Shield is then the fight's hit points, as
  heat is the fight's budget (both start each won fight full and empty), and hull is what leaks
  past a fight played badly: the battle's wear. The field recharge stat goes (Ryan's lean), and
  "about half the shield a map turn" with it. The scales row's shield 6 to 16 is then sized to
  the fight, not the battle.
- **Foe blows are refitted to threaten the shield.** With the shield resetting, a formation
  can put two or three shields' worth of blows at the team over five to eight rounds and the
  battle survives it. The tests move: a formation costs a four its shields and about a tenth of
  its hull at competent play, and a quarter or more played greedily; a patrol costs one machine
  the same share. The stock pass's loops (`tools/stock_fills.py`) refit the foes' blows against
  them; every number in `content/foes.json` is a placeholder by rule.
- **Base shield regen and cooling as the setup room.** A chassis stat, shield regen 0 to 2 a
  round at the round's start beside its cooling (Ryan's "build-strategy buffer"), is what lets
  a machine take a setup turn without spending its die on a shield; a harder-hitting formation
  takes the room back. It reverses his lean of 28 October to cut passive cooling (the triangle
  row; the heat brief's first question): say so in the row when it lands, since the brief waits
  on it. The hole is section 5.
- **Withdrawal carries, the fall resets.** After a withdrawal the shield and the heat carry as
  they stand (heat's one exception to "never carried between fights", narrower than the battle
  resource Ryan refused on 4 November) and the pack keeps its damage and its statuses, shown
  on its hold. So hit-and-run is an exchange, not an all-in and not a reset: the pack stays
  chipped, the machine comes back hot and low, and the map charges the turn. This reopens the
  pack row's "not taken" (section 6).
- **Rerolls, second.** Lethality first; if greed is still free with the fights tight, the levers
  are two rerolls (Slice and Dice's number; the Giant Petrel's bank and Rallied then matter
  more) or a price on the reroll (section 8's bench).

### 4.3 Formations with identity

A formation is authored, never partitioned (Ryan: "predetermined by the engine or semi-random
combinations"). In content, a composition gains:

- **A layout**: the front and back slots named by foe, left to right, in place of the engine's
  sort (heaviest hitter first, from the left: `Skirmish`'s first deployment); a slot may list
  two or three foes for the seed to draw from (his "semi-random"), so nobody learns an order
  and the guest's members stand where the tier says (the levers row).
- **A question**, under `design`, in the engine's own vocabulary: what the player must answer
  (the shaman's silence before it lands, the rallier before the countdown, the healer behind
  the wall, the bracers breached, the swarm's count before the add outgrows the armour). The
  design test "Every pack poses a question" is then checked by the validator's eye, not hoped.
- **Waves inside the formation**: members past the eight slots step in at a round the
  composition names, or when its lead falls, so a horde keeps coming inside the fight and a
  stall meets the next rank; the reinforcement step stays the mine's alone (its row).
- **A size for the squad**: sized for one machine, for a pair, or for four, shown on the pack's
  hold on the map ("a fight for two"), so the split is read before it is made. The three sizes
  replace patrol and formation as the content's words (elite and escort stay).
- **Roles**: the fresh start's open item (section 12), one word a foe, internal first.

The engine changes are small: placement from content, a wave at a round, the size on the hold,
the validator holding each shape, tests on synthetic foes. The content work is the formation
pass: every domain's compositions rewritten by its signature and the tier's units, proposed in
chat first, Ryan marking them against his notes. Examples of the shape, for the discussion and
nothing more: the Meadow's warband at tier one, a shaman in the back centre behind two bracing
guards, the question reach; the wolf pack, a hunter's patrol sized for one, the question the
pounce and the lure; the Marsh's grave host, a healer in the back and revenants that get back
up in front, the question kill order and burst; the Peak's ember pit, a drake's countdown
beside bombs, the question a shield sized to the telegraph and a cold machine for the lure.

### 4.4 What the runner reads

The ladder reads every formation by size: random beating a one-machine pack means too easy,
greedy losing a four's pack means a wall, both landing together no decision (the balance row);
the coordination gap on the formations with waves; the wear in the campaign runner at the new
shape. The 200-seed matrix the status puts first waits on the shape, since every blow moves.

## 5. Holes, each with what settles it

1. **Shield regen with no round limit.** Sustain can outpace damage on a thick team and a fight
   never ends; the map's clock never ticks inside a fight. Answers inside the fight: the
   formation's own waves and rallies, regen small (1 or 2) and the fights' damage fitted above
   it; the runner marks fights past sixty rounds. The stall row's prices stand on the map.
2. **Tight fights and damage that sticks.** If every fight threatens the shield and hull never
   heals, a battle of eight tight fights is lost by arithmetic, not play. The leak past the
   shield at competent play is the number to tune (a tenth); the wear test is read again.
3. **Hit-and-run with both resources resetting.** If the shield and the heat both reset after
   any fight, a withdrawal is a free reset of both and the only prices are time and the parting
   turn. Hence "the fall resets, a withdrawal carries" (section 4.2); Ryan's "make withdraw
   more risky" may want more (the bench: parting blows on bare hull).
4. **The thumb's floor against the depth.** The wall on the left caps the depth at nine hexes
   at today's hex size; twelve needs a hex a fifth smaller. Ryan's floor to move, on the phone.
5. **The response window of one turn.** A tear two hexes out costs gate points whatever the
   squad does unless a machine stands within its move; the gate's bar becomes the score of a
   battle rather than a loss condition, and the Favour dock (a point a gate point) becomes a
   tax on every battle, as the wall row already named. The economy pass's rate; or the dock
   gentler and the gate's fall the real loss.
6. **The meter in a wave game.** With kills coming to the wall a defending player fills it; a
   turtle fills it slowly (the reinforcements pay a trickle). The thresholds move off the
   field's menace at the start (section 3.2). The three-clocks row's reason ("nothing the rift
   sends is needed to earn the Rupture") is overturned on purpose: the waves are the fuel.
7. **The shell's feedback.** Fractures that open crossings make the player's success speed
   the horde: wanted, as every wave game ramps, since the Rupture ends the battle; it reads
   thematically (the rift tears as it is strained). If play finds it perverse, the Fracture
   opens the elite's crossing alone and the waves ramp on the timer.
8. **One pack, one fight, and the map's lever on size.** Section 3.3. What replaces it is the
   pack's own size and waves; whether the map needs a second lever is read in play.
9. **The 2×4 cap and a horde.** A formation sized for four holds eight on the field and the
   rest in waves; the cap stays a phone-readability cap (its row).
10. **The interceptor fantasy.** Kestrel's briefs and the Kestrel row restate it; the Needletail,
    the Dingo's two actions and the Sparrowhawk read as firefighters. Cost to come: a sentence
    each, no engine.
11. **The bots.** The battle bot moves as one toward the nearest pack; the campaign runner's
    player is Ryan's large change (the to-do). A defence bot (hold the wall by segment, send the
    nearest machine at a tear's patrol) is the first thing the runner needs to read the shape.

## 6. The rows this reopens, with the reason each had

- **Fights are picked on the map, by ring and range** (section 4): "The radii and the range are
  placeholders for play" and the hunters' exit was "the pounce overbearing in play". Ryan's play
  found the rings circumventable; the rows retire the joining and keep the hunter's reach.
- **A pack is one sprite and a number badge**: "packs keeping their damage between fights was
  not taken: a number on the map and attrition by withdrawal, whose price is already right".
  The price changes with the shield's reset, and the number is a line on the pack's hold.
- **A pointy-top hex grid nine wide, gate south, rift north**: the width parked on the thumb's
  floor and the lanes past nine; the finale lever; "pointy-top makes defensive lines straight
  rows", which a flat-top keeps as straight columns.
- **Three clocks, and what each prices**; **A battle is a short run of fights toward a boss the
  player earns**; **Rift Pressure feeds the boss fight only by what the rift itself sends**:
  the waves are the fuel, the thresholds move, the timer shortens to a wave's beat.
- **Damage sticks**: the hull half stands; "the battle is a race to close the rift" goes.
- **A shield absorbs its number**: "Shield returns only at the field rate out of fights, so
  withdrawing is no reset" becomes "the fall refills it, a withdrawal carries it".
- **Heat bites where it is carried**: "never carried between fights" gains the withdrawal's
  exception, if Ryan takes it.
- **The offence, defence and heat triangle**: passive cooling's cut was his lean; a base
  cooling and regen as the buffer reverses it, and the heat brief's first question is answered
  by this instead.
- **Four machines, moving as one; a detachment is a decision priced by time**: the splits are
  the point, priced by the pack's size rather than refused by the fight's cost.
- **Six map shapes, and the name is the intel**: the shapes' idea stands rotated; their laying
  becomes authored sectors.

## 7. Questions for Ryan, first round

1. The wall on the left and down the screen (flat-top, one screen across), or at the bottom
   and scrolled sideways? And the hex floor: nine deep at today's size, or a smaller hex for
   twelve?
2. The first cut's numbers to read, all placeholders: depth 12, wall 20, the timer 3 turns, a
   pusher's segment variance by the ramp. Yes to reading these on a bot before any look?
3. One pack, one fight: nothing joins, hunters keep the pounce, withdrawal stays open. Yes?
4. The shield: refilled after a fight the pack lost, carried after a withdrawal, the pack
   keeping its damage; heat carried after a withdrawal too, or reset as today?
5. Base shield regen and cooling as chassis stats: both back, at 0 to 2, and the heat brief's
   cooling question closed this way?
6. The Fracture: the shell (Claude's lean), or one of the other three?
7. Formations: the layout, the question, the waves and the size for the squad as the content's
   shape; the roles with them; the formation pass proposed in chat domain by domain. Yes, and
   which domain first?
8. The order of work: this ahead of the 200-seed matrix and the balancing (status items 1 to
   4), with the chassis sessions running beside it?

## 8. Bench: ideas the rules kill, one line each, for Ryan to overrule

- A reroll heats every die it rerolls by one: greed priced in the heat pillar, visible and
  shiftable, locked dice exempt; against "the player always has tools against the roll" and
  "elegant fun" (a second mechanism on the reroll).
- Parting blows on a withdrawal land on bare hull: the risk Ryan asked for, in one legible
  rule; against the shield row's honest number.
- The boss as the last wave, coming to the wall at the Rupture: against the seal row's fight at
  the rift and the sally's decision.
- A loss when the seam reaches the wall: refused already by the stall row (a round cap by
  another name).
- The map's turn ticking inside a long fight from round eight: the backstop held in reserve by
  the one-clock row, against "no round limit"; answers hole 1 if the waves do not.
- City defences as the fifth machine on the wall, a turret holding a segment: section 8's
  commander layer, which waits for a baseline, moved up.

## 9. If Ryan says go: the order

1. The sim first, headless and seeded: the field at any size with the mouth, the team's rows
   and the wall as fractions of the depth; the wave clock on the ramp; the pusher's segment; the
   fights without joining; the shield's reset and the withdrawal's carry; a defence bot. Read
   on the campaign runner before any look.
2. The formations' engine: placement from content, waves at a round, the size on the hold,
   the validator; synthetic tests.
3. The formation pass, domain by domain, in chat, then content; the foes' blows refitted by
   the stock pass's loops against the new tests.
4. The view: the rotated field (flat-top), the long wall's scroll, the tags for what is off
   screen, the camera; judged on the phone with the switches the README names.
5. The sectors: the library proposed in chat, then laid; the map survey reads it.
6. The rows, the rules, the briefs' fantasy lines, the status, the bible republished; this file
   retires.

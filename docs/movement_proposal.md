# Map movement in hexes: a proposal

Ryan opened it on 27 October, after playing the map a lot: "the current move points and
terrain system was built before numbers were reduced, and when upgrades were more plentiful.
Now, with modules being the only stat upgrade source ... our current movement rules just add
confusion and overhead for no strategic gain." The chat's read of the same day is below; of
its four options he took the third on 28 October ("going back to C makes sense"), and asked
whether tracks, wheels and legs need to differ in anything but their look. This file is the
design's one home until he has marked it; then its decisions become bible rows,
`docs/rules.md` and content, and the file retires (git keeps it). Every number is a
placeholder. Nothing in the engine or the content changes before his go.

## What the records already decide

One line each, so that nothing below re-opens a settled point by accident.

- Each way of moving calls each ground fast, normal or slow; a slow hex ends the move; "no move
  buys through a stop, so every way keeps a good and a bad ground and the player never weighs
  two numbers"; moves follow size and role (bible section 4, decided 2 October).
- Foes move binary: the Final Fantasy overworld rule, broken ground delays only machines, and
  terrain is never a bonus to foes (section 4).
- The player never does arithmetic on the map: the map draws reach, a slow end hex wears a
  dashed edge and a stop sign, move is a pip gauge with a slow last step hatched, the codex
  gives move in open-ground hexes, a terrain tap gives each way's word, move rewards come in
  tens (section 4).
- Five map types and the name is the intel; each passes "mismatch costs time, never ability"
  (section 4). Campaign battles all use Mixed Ground; the harness picks any.
- Every map guarantees the horde a crossing three hexes wide and one water feature; the two
  rows before the gate are never water or crags; height is landscape, no rule reads it.
- Four machines moving as one; a detachment is a decision priced by time (section 4).
- A move is tapped or drawn; moves are planned and played on ENGAGE or END TURN; UNDO runs in
  global order. Open after these: "a move given in one go, or a clearer mark that a machine has
  move left, since the gauge boxes on a dragged route sit under the thumb" (Ryan, 25 October;
  the to-do's line).
- A tag carries no rule of its own; a module or passive may read one (`docs/rules.md`, the
  machines). A maker's theme, word or keyword is a lean, never a rule (the bible's register).
- "A map rule alone is weak": crags as slow ground, set aside on the Wainwright & Sutler bench
  (`docs/briefs/README.md`, 11 to 13 October).
- Numbers are questions read through `sim/effects.gd`; a module is a modifier with a scope.

## The problem, as read (27 October)

- The weighing is the pathfinder's, not the player's. A tap takes the cheapest route and the
  map draws the reach, so the table never asks the player anything: it shapes a blob and plants
  a stop sign, the sign Ryan asked the meaning of on 25 October.
- The map survey of 8 October (`docs/map_survey.md`, 200 mixed maps) measured what the table
  does. Phases to the rift at move 30: tracks, walkers and flyers 6.0, hover 5.6, wheels 3.8.
  Reach after two phases: 31% of the field for tracks to 62% for flyers and wheels. Its own
  read: "the trip north barely moves, the lanes do". The walls bite; the words do not.
- Three of the five ways are indistinguishable in play: tracks stop on ruins, walkers stop in
  water, wheels run fast on open ground, and on a mixed map those are three slightly different
  blobs. The flyer over crags and the hover over water are the two a player can see. The
  mechanics audit's 29 found the words drifting from the numbers already (the Dire Wolf
  "faster than anything but the cars", outrun by ten machines that are no car).
- What reads move today: reach, the hunters' slowest and fastest picks, the model's pace on the
  map, the readouts, the codex, the hangar and the Sponsorship count. The balance runner reads
  none of it ("move and field recharge are map numbers a fight cannot read"); the campaign bot
  moves the squad as one onto the nearest pack. Nothing measured depends on movement. Ryan's
  play does, which is the bible's own order (his play decides feel).
- The display's weight traces to two rules: the fast hex is why the gauge has half pips, the
  slow stop is why it has hatched cells. The 25 October complaint is those two rules showing.
- The premise, corrected: move was never reduced. The chassis have stood at 20 to 50 since
  before the stock pass, which moved hull, shield and armour and left move alone. The tens were
  sized for move rewards in tens, which were never built, and the fast hex. Today three of
  seventeen modules touch move (Ablative Plating −10, Spall Liner −10, Thrust Overboost +20),
  so the step of five serves the fast hex alone.
- What C keeps on purpose: the spread of move is the one map number that does something. A
  fast machine taking a flank pack and rejoining is the detachment row, and with the squad
  moving as one the slowest machine sets the pace, so the spread goes unused unless the player
  detaches. That argues for a spread in hexes and nothing finer, not for flattening it.

## The design

### 1. Move in hexes

A chassis's move is a count of hexes, every hex one step. Placeholders: today's tens over ten,
so 2 (eight machines), 3 (four), 4 (six) and 5 (six). Packs 2; the fast foes 3 (the Dire Wolf,
the Needler, the Bomb, the Martial Artist, the Lancer); the Thief 4; a massive foe 1; the boss
patrols one hex as now. Modules: Ablative Plating −1, Spall Liner −1, Thrust Overboost +2. The
hunters' slowest and fastest read it as before. The validator takes a whole number from 1 to 6
(a placeholder bound) in place of a multiple of five.

### 2. Ground is binary, by side and by crossing

Every machine moves as the horde does: open ground (plain, road), rough and ruins are ground,
one step each; water and crags are walls. Two crossings, and only two: a hovercraft crosses
water; a flyer crosses water and crags. Rough and ruins become landscape like height: no rule
reads them. A ground machine and a pack now see the same map, which the crossing guarantee and
the river's fords already keep walkable, so the lanes stay and the arithmetic goes.

The way of moving stays in content, one a chassis, as the model's shape and motion, its
footfalls (`game/audio/sound.gd`'s step table) and its codex word, like a tag: no rule of its
own, and a passive or a module may read one as a one-off (an amphibious kit, a wading tank).
The two crossings belong to the hover and the flyer, which are the ways a player can see.

Ryan's question of 28 October, whether tracks, wheels and legs should differ in anything but
the look: nothing built or decided reads them apart from the terrain table and the footstep
sounds. No passive, module or foe in content names one; no brief needs one but the siege
battery's pitch ("Massive Chassis: terrain penalties don't apply"), which the brief already
pairs with an alternative (the charge as the passive). The differences the table drew were the
table's own reasons. So the answer is no: the look, the sound and a hook for a passive, which is
what the records say of a tag and a theme.

### 3. A move is one go

Tap a lit hex or draw a route, and the whole move is spent; the machine may then fight or
stand. No move left, no gauge, no stop sign: the lit reach is all the information there is,
and a drawn route cannot leave it. UNDO takes the move back as now; the carry rides as now;
the Dingo's two actions are two moves and two fights. This closes the 25 October open line by
removal. What moving in pieces bought, a look at the red band after a step, the band already
shows before the move, since it reads the whole reach.

### 4. What the player sees

- A selected machine: its reach lit under one kind of edge, the red band where it could attack
  from, the packs in it bracketed. Nothing dashed, no sign.
- The readout: "Move 4 · 1 of 1 actions left", the base and the change as the codex has them.
- The ground tap: "Ground: every machine and pack crosses it"; "Water: hovercraft and flyers
  cross it; packs never enter it"; "Crags: flyers cross it; packs never enter it".
- The codex and the hangar: "move 4", in place of "40 (4 open)".
- The front card's ground word, once the mission map exists: Badlands says the flyer's, Flooded
  says the hover's and the flyer's, the rest say what the ground looks like.

### 5. The map types

The five generators stay as landscapes; mechanically the intel is the walls. Badlands (crag
ridges) is the flyer's map and Flooded (a river, a lake, puddles) the hover's and the flyer's;
Mixed Ground is the base; Rubble Field (a ruins belt, "the walker's map") and Open Steppe
(mostly open, "wheels and the horde fly") read nothing any more and become looks. Whether the
five names stay or fold to three is Ryan's (the questions below).

## What it costs: the bench

One line each, with the rule that kills it, so Ryan can overrule the rule.

- Fast ground (wheels on open ground, hover on water): killed by binary ground; its only visible
  trace was the gauge's half pip and wheels making the rift in 3.8 phases.
- Slow ground as a stop (tracks on ruins, walkers in water, wheels and hover off their ground):
  killed by binary ground; the stop sign was what the player asked the meaning of.
- Tracks fording water (Minerva's tracked machines): killed by water as a wall to ground
  machines; the fords are land hexes, so the river is crossed where the horde crosses it.
- Water as a stop for everyone: today any machine can end a move in water, out of a ring-one
  hunter's reach; under C that refuge is the hover's and the flyer's alone.
- The Giant Petrel's irony, "fast-looking, slow, and fast only on water" (its brief): becomes
  slow and amphibious; its water speed, if wanted, is a passive of its own, not a way's rule.
- The Storm Petrel's river road, "water fast, so it rides the river the jets fly over" (its
  brief): the river becomes its refuge and its shortcut past a wall, not its speed.
- The siege battery's "Massive Chassis: terrain penalties don't apply" (Ryan's pitch, 15
  October): nothing left to ignore; the brief's alternative stands.
- Rubble Field as the walker's map and Open Steppe as the wheels' (the map-types row): looks.
- Moving in pieces (move, look, move again): killed by one go; the band shows the look first.
- The move gauge (decided 3 October) and the stop sign (25 October): none.
- The ground tap's word per way (12 vocabulary entries): three lines, by crossing.
- "Move rewards come in tens": in hexes, if rewards ever come.
- Crags as slow ground: already set aside (a map rule alone is weak).

## What it retires or rewrites

- Bible section 4: the ways-of-moving row, retired with the form that failed (the per-way table
  of fast, normal and slow) and the test it failed (Ryan's play of 27 October: confusion and
  overhead for no strategic gain; the survey's read that the trip north barely moves); the
  foes-binary row (both sides now); the no-arithmetic row (the gauge and the sign retired,
  rewards in hexes); the map-types row (the intel is the walls); the planned-moves row's open
  line (closed: one go). The four-machines row, the crossing row and section 7's model and
  motion rows stand.
- `docs/rules.md`: the chassis bullet's move; the battlefield's Ways of moving, A turn, The
  readout, Orders and Packs; the modules bullet.
- Content: `chassis.json` (`_about` and 24 moves), `foes.json` (26 moves), `modules.json`
  (three), `vocabulary.json` (the movespeed entry, the six grounds, the five ways).
- Briefs: the hover lines of `kestrel_gun_platform.md` and `kestrel_shield_spender.md`; the
  siege battery's passive candidate. The to-do's one-go line lands with it; the audit's 29
  stands.
- `docs/map_survey.md` and `docs/vocabulary.md` regenerated.

## The build, one session

- `sim/battle_map.gd`: the word table, `move_cost`, `spend`, `ground_ways` and the path cost
  become one crossing table and `passable`; `sim/battlefield.gd`'s search, route cost and walk
  budgets count hexes; `sim/battle.gd` drops `move_left`, `action_from`'s move, `draft_cost`
  and `draft_spend`, and a moved machine cannot move again this action; `sim/unit.gd`'s
  defaults; `sim/content_db.gd`'s validator and `stat_parts`.
- `game/battle/battle_map_view.gd`: the gauge, the hatching, the dashed edge and the sign go;
  the pace table (`MECH_PACE`, keyed by tens) is keyed by hexes; `game/battle/battle_screen.gd`'s
  readout and ground lines; `game/ui/mech_rig.gd`'s map speed.
- `sim/save.gd`: `move_left` dropped from the save; a save carrying it loads with it ignored.
- `tools/map_survey.gd`, `tools/hangar.html`'s move column, `tools/stock_fills.py`'s module
  fills; the hangar republished with the content files that moved.
- Tests: `tests/test_map.gd` (the table), `tests/test_battlefield.gd` (budgets, the slow hex),
  `tests/test_battle.gd` (the gauge, moving in pieces, route costs), about forty in all.

## How it is measured

- The survey rerun at 200 seeds under the new rule: phases to the rift and reach for ground
  machines, hover and flyers, read as bands against the 8 October table.
- The campaign runner before and after: its bot moves as one onto the nearest pack, so its wins
  should not move; a cell that moves is a bug.
- Ryan's play decides feel: the harness with `RIFTGATE_MAP_KIND` for each type, the Badlands and
  the Flooded first, since they are the two that still read.

## Flyers and hovers as the best pieces (Ryan's concern, 28 October)

Ryan, 28 October: "how do we stop flyers and hovers from taking over the game as the best
pieces. Especially when right now in the current active and designed roster backlog, they are
quite prevalent." Eleven of the 24 chassis cross something (six flyers, five hovers), and the
backlog adds more (Kestrel's last two, Aphelion's line, the Arsenal's Minos on hoverjets).

What the records and the numbers say:

- C narrows the gap; it does not widen it. Under the table a flyer already has no bad ground
  ("flyers exempt") and crosses crags, so nothing changes for it. A hover loses its fast water
  and its slow rough and ruins. A ground machine loses its stops and keeps only walls. In the
  survey's terms the flyer's reach after two phases stays at 62% and a ground machine's rises
  from 31% toward it, since the only hexes it cannot stand on are water and crags, a fifth of a
  mixed map (the rerun measures it); at equal move, wheels lose their 3.8 phases to the rift and
  run at 6 like the rest. The concern is the game's as it stands; C makes it smaller.
- Crossing buys a flank and a refuge, not tempo: the survey's phases to the rift are 6.0 for a
  flyer and 6.0 for a walker at the same move. Tempo is move, and move follows size: of the
  eleven crossers five are lights, the class with the thinnest hull, and two are assaults at a
  move of 2 (the Swallowtail, the Giant Petrel). The depth lives in the skirmish, and nothing in
  it reads the ground or the way of moving (the skirmish's terrain is its backdrop and a header
  word).
- A squad moves as one at its slowest machine's pace, so a crosser in a mixed squad uses its
  crossing only by detaching, and a machine alone meets walls (the stock pass's bands);
  concentration halves the hull a fight costs with every machine added. An all-crosser squad, a
  Kestrel tender, crosses as one: that is the maker's identity, paid in its kits.
- The refuge is the one thing C makes exclusive. Today every machine can end a move in water
  (tracks ford it, walkers and wheels stop in it) out of a ring-one hunter's reach; under C that
  is the hover's and the flyer's. A hunter keeps its lock until the machine is gone and never
  strikes the gate, so a flyer two hexes into a lake neutralises a hunter for the battle. The
  same holds today for every machine on water and for a flyer over crags.

The levers, least rule first (a map rule alone is weak; a one-off exception for balance is a
symptom):

1. Price it where balance is read. The stock pass sets a chassis's numbers by size and role,
   never by way, so a flyer and a walker of one size and role cost the same and the flyer
   crosses. The pricing run (the stock pass's tail, the to-do) can price the crossing in salvage
   and Favour, or a crossing chassis takes a step under its size's fill (wings are weight: a
   point of hull or armour). Read by the runner's solo value beside team value, the
   four-machines row's own measure, and by Ryan's play.
2. Give the sky to the foes too. Five foes have wings or float (the Cockatrice, the Ghost, the
   Bone Dragon, the Bomb, the Drake), and the fresh start's elites add the Bone Wyvern and the
   Reaper. A winged pack crossing water and crags as a flyer does takes the refuge from a flyer
   without touching the ground machines, and is parity, not the bonus the Final Fantasy rule
   forbids. The Bomb is a hunter already.
3. A hunter whose prey it cannot reach picks again, so no pack is neutralised by a lake.
4. The Rupture meter as the fresh start proposes it: a detachment's kills add little meter, so
   picking off small packs with flyers is not the optimal play.
5. Not a map rule on the crossers (no attacking from water, a price to cross): that is the
   table again, in another form.

Claude's lean: 1 and 2, with 3 whichever way 2 goes, and nothing before the pricing run and
the fresh start read it, since the gap is smaller under C than today.

## Questions for Ryan

1. Water is a wall to ground machines (Claude's lean: yes; ground to everyone would give every
   machine a refuge no ring-one hunter reaches, two hexes into any lake, and would make the
   crossing guarantee mean nothing to the squad).
2. Hover over crags stays a wall (Claude's lean: yes, so the Badlands stay the flyer's).
3. The moves: today's tens over ten, or a flatter spread.
4. The map types: five names as looks, or three that read.
5. The Giant Petrel and the Storm Petrel: slow and amphibious, and fast and amphibious, or a
   passive that gives one of them its water speed.
6. The crossing's price: in the hangar by the pricing run, as a step under the size's fill, by
   the foes' wings, or left until the runs read it (Claude's lean: the pricing run and the
   wings).

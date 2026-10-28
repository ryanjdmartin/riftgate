# Map movement in hexes: the proposal and the build spec

Ryan opened it on 27 October, after playing the map a lot: "the current move points and
terrain system was built before numbers were reduced, and when upgrades were more plentiful.
Now, with modules being the only stat upgrade source ... our current movement rules just add
confusion and overhead for no strategic gain." On 28 October he took movement in hexes with
binary ground ("going back to C makes sense"), the three levers against flyers and hovers
("I think your leans are correct, include 1, 2, and 3. I keep wanting to add more complexity
to the map, but ultimately I'm doing more harm than good"), and asked for water as the one
priced ground and for this file to be unambiguous enough that another model builds it without
a bad guess. This file is the design's one home until it lands: section 1 holds every
decision, made or open; sections 2 to 7 are the build; section 8 is the bench and section 9
the read behind it all. Every number is a placeholder. The rule that reads everywhere else in
this repo reads here: a builder changes nothing this file does not name, and asks rather than
guesses where it is silent.

## 1. Decisions

### Decided (Ryan, 27 and 28 October)

- **D1. Move is a count of hexes.** Every chassis's and foe's move is its move in tens over
  ten; a step is one hex (section 2).
- **D2. Ground is binary, by side and by crossing.** Open ground, rough and ruins are ground to
  everyone; crags are a wall to all but a flyer; water is the one priced ground (Q1: two
  of a ground machine's move). Rough and ruins are landscape like height: no rule reads them.
- **D3. Tracks, wheels and legs differ only in look and sound.** A way of moving stays in
  content, one a chassis, as the model's shape and motion, its footfall and its codex word,
  like a tag: no rule of its own, and a passive or a module may read it as a one-off. Ryan,
  28 October, on whether they need to differ otherwise: no reason beyond visual variety.
- **D4. A move is given in one go.** One move an action, the whole of it; then the machine may
  fight or stand. No move left, no gauge, no stop sign.
- **D5. The crossing is priced where balance is read, never by a map rule.** Lever 1: the
  pricing run (the stock pass's tail, the to-do) prices a crossing chassis in salvage and
  Favour, or the fill takes a step under its size; nothing to build in this session. Lever 2:
  winged packs cross water and crags as a flyer does and stand where a flyer stands. Lever 3: a
  hunter whose prey it cannot ring picks again. Levers 2 and 3 are built in this session.
- **D6. Not a map rule on the crossers** (no attacking from water, no price to cross): the
  table again in another form.

### Ryan's calls (28 October)

Every call is made; the build takes these and nothing else.

- **Q1, water: A.** The one priced ground: a water hex costs a ground machine (tracked,
  walker, wheeled) two of its move, and it can always enter one with whatever move it has left
  (`spend = min(2, left)` when `left >= 1`), so a move of 2 wades one hex a turn, 3 and 4 wade
  two, 5 wades three. A hovercraft and a flyer cross it at one. Packs never enter it; a winged
  pack crosses it at one.
- **Q2, hover over crags: A.** A wall; crags are crossed by flyers and winged packs alone.
- **Q3, the moves: A.** The tens over ten, every chassis and foe as the lists in section 5
  give them; the three modules −1, −1 and +2.
- **Q4, the map types: A now, the shapes next.** The five generators, names and the harness
  picker stand through this build, and only the bible's reading changes (the intel is the
  walls). Ryan's rework of the types into six shapes (a river, a fjord, badlands, open steppe,
  a ruined city, a gorge) is section 10, a generator session of its own after this one lands.
- **Q5, the winged packs: A.** The Cockatrice, the Ghost, the Bone Wyvern, the Bomb and the
  Drake; the fresh start adds its own winged elites (the Reaper among them) when they land.
- **Q6, the Giant Petrel and the Storm Petrel: A.** Amphibious at their moves, no passive;
  their briefs' hover lines rewritten now (section 5).
- **Q7, the re-pick: A.** The new lock holds.

## 2. The rule, as `docs/rules.md` will state it

Under Ryan's calls above. The builder pastes these over the battlefield section's matching
bullets, present tense, no dates.

- **Moving** (replaces "Ways of moving"): a machine's move is a count of hexes, each step one
  hex, and a chassis has one way of moving (tracked, walker, wheeled, hover or flyer), which
  is its look and its footfall and never a rule of its own. Open ground (plain, road), rough
  and ruins are ground to everyone. Water: a ground machine wades it, a water hex costing two
  of its move, and it can always enter one with whatever move it has left; a hovercraft and a
  flyer cross it at one. Crags are a wall to all but a flyer. Machines never enter or cross another unit's hex.
- **A turn**: "Each machine has one action (the Dingo two): one move, in one go, then it may
  fight; a fight ends the action however it ends." The rest of the bullet stands (the lit
  reach, the red band, the planned route, UNDO, ENGAGE and END TURN, the pulse).
- **The readout**: the ground's line becomes "the ground: who crosses it, who wades it and
  who cannot, and whether packs enter it".
- **Packs**: "They cross every land hex and never enter water or crags; a winged pack (the
  Cockatrice, the Ghost, the Bone Wyvern, the Bomb, the Drake) crosses both as a flyer does
  and may stand there; moves 2 (fast 3, the Thief 4, massive 1); rings 1 (front rank), 3 (back
  rank), 2 (massive)." The rest stands.
- **Hunters**, appended: "A hunter whose prey stands where no hex it can reach puts it inside
  its ring (a flyer over crags, a hovercraft out in a lake) picks another by its caveat among
  the machines it can reach, and the new lock holds; with none to pick, it walks as near as it gets."
- **The carry**: "keeping their action, and their move if they have not moved" in place of
  "keeping whatever move and action they had".
- **The boss**: "patrols its ring of the rift" stands; its step is one hex.
- The machines section: the chassis bullet's "move" and the modules bullet's "move" stand as
  words; nothing else there changes.

What the rule means at the edges, so nobody guesses:

- A move of 0 (a move of 2 under two −1 modules) lights nothing and cannot move; `nothing_left`
  treats it as a machine that cannot move, as it does today.
- A ground machine may end its move in water and stand there; next turn it wades on at two a
  hex. A hovercraft and a flyer may stand on water, a flyer on crags.
- Entering water with exactly one move left is allowed and spends the one. With no move left
  nothing is entered.
- Reach is still the cheapest-cost search (Dijkstra) over step costs of 1 and 2, bounded by
  the move; `destinations_for` maps each hex to its cost, and `attack_hex` still breaks a tie
  on distance by the cheaper hex.
- A drawn route is extended hex by hex along the cheapest continuation that fits the move,
  as today; it can never leave the lit reach, so the end of the route needs no gauge.
- Riders of a carrier keep their own move and action (they have not moved); a carrier moves
  in one go like any machine.
- A winged pack may spawn, walk and stop on water or crags; a fight at such a hex is fought
  there (the skirmish's backdrop reads the contact hex's terrain, which already draws every
  terrain). Machines join it from any hex within attack range, ground or not.
- The re-pick reads the ground alone: whether any hex the hunter could ever stand on (an
  unbounded search over its own passable ground, the other packs' holds ignored) is landable
  and puts the prey inside its ring. It never reads where the other packs stand this turn.
- The re-pick is computed in the walk plan (so the preview and the hunted tag show it) and
  committed to the hunter's lock only when the walk is played, so UNDO of a planned move shows
  the old lock again. The candidates are the machines a hunter may ever hunt (`never_hunted`
  excluded) for which such a hex exists; the caveat's key picks among them exactly as
  `pick_prey` does, the first best in field order on a tie; with none, the prey and the walk
  stay as today.

## 3. What the player sees

- A selected machine: its reach lit under one solid edge, every hex alike; the red band where
  it could attack from; the packs it could be ordered onto bracketed. No dashed edge, no stop
  sign, no mark on water.
- A route drawn by hand: the heavy line and the ring on its end hex as today; a carrier's
  landings and NO ROOM as today; no gauge.
- The orders board: READY, MOVED (it has moved this action and may still fight), ONE MORE,
  SPENT, CAUGHT, as today, MOVED read from the battle's `moved` set.
- The machine's readout: "Move 4" as base and change (`stat_parts`), then "1 of 1 actions
  left", unchanged in form.
- The pack's readout: "Dire Wolf ×4 · Move 3 · Ring 1", and "· Winged" after the ring on a
  winged pack; the foe's codex subtitle gains "// WINGED" the same way.
- The ground's readout, built from the crossing table (`BattleMap.ground_ways`, section 4) so
  it can never disagree with the rule, in the `_said` style (a bold head, then the rest):
  - plain and road, title "Plain" or "Road", type "Ground": `Cross: every machine`, then
    `Packs cross it`.
  - rough: the same lines under its name; ruins: the same.
  - water: `Wade: tracked, walker, wheeled (two move a hex)`, `Cross: hover, flyer`, then
    `Packs never enter it; a winged pack crosses it`.
  - mountain (shown as the vocabulary names it): `Cross: flyer`,
    `Wall: tracked, walker, wheeled, hover`, then `Packs never enter it; a winged pack crosses
    it`.
  The way names are the vocabulary's shown names, as `ground_lines` reads them today.
- The codex and the hangar: "move 4"; the hangar's "(4 open)" goes.
- The front card's ground word, once the mission map exists: not this session's.

## 4. The build: engine and screen

Every file named is the whole list; a builder who finds another reader of a changed thing
stops and reports it rather than guessing.

### `sim/battle_map.gd`

- Retire `FAST`, `NORMAL`, `SLOW`, `SLOW_PATH_COST`, `WORDS`, `WORD_NAMES`, `move_cost`,
  `move_word` and the comment block above them. Keep `WAYS` (the five machine ways: the
  validator and the survey read it) and `way_of`.
- Add `const STEP := 1`, `const WADE := 2`, `const WALL := -1`, and the crossing table, one
  entry a word, each `[water, crags]` as a step cost or `WALL`:
  `"tracked": [WADE, WALL]`, `"walker": [WADE, WALL]`, `"wheeled": [WADE, WALL]`,
  `"hover": [STEP, WALL]`, `"flyer": [STEP, STEP]`, `"winged": [STEP, STEP]`,
  `"": [WALL, WALL]` (the horde's rule, no trait). `way_of` learns `winged` as a sixth word it returns for a
  pack carrying it (it is not in `WAYS`).
- `static func step_cost(t: int, traits: Array) -> int`: `STEP` for plain, road, rough and
  ruins whatever the traits; the table's water or crags entry otherwise.
- `passable(t, traits)`: `step_cost(t, traits) != WALL`.
- `spend(t, traits, left)`: `-1` when the cost is `WALL` or `left <= 0`, else
  `mini(cost, left)`. This one clause is the whole of Q1A's "always enterable with what is
  left".
- `ground_ways(t) -> Array`: `[[word, ways]]` over the words `"wade"`, `"cross"`, `"wall"`
  in that order, each present only when non-empty, the ways in `WAYS` order; the packs' and the
  winged packs' lines are the screen's, read from `spend(t, [], 1)` and `spend(t, ["winged"],
  1)`.
- `find_path`: its cost is `step_cost`, a `WALL` skipped; its only callers are the generator's
  crossing guarantee and the survey, with no traits, so nothing it does changes.
- The comment "every pack and boss; the foes carry no trait" becomes "a pack carries no trait
  unless its foe is winged".

### `sim/battlefield.gd`

- `reachable`, `route_to`, `route_from`, `route_cost`, `_search`: unchanged in code; their
  budgets are now hexes. Their doc comments lose "move points" for "move".
- `dress_pack`: when the profile carries `winged` true, `sq.traits = ["winged"]`; otherwise
  the traits stay empty. The boss is never winged.
- `_walk`: the budget `sq.movespeed` in hexes, unchanged in code. Lever 3 goes in before the
  goal search: for a hunter with a prey, `_can_ring(sq, prey)` (new: an unbounded search over
  the hunter's own passable ground from its hex with an empty `blocked`, true when any landable
  hex puts the prey within `sq.zone`); when false, `_repick(sq)` (new: the machines
  `pick_prey` would consider, the current prey excluded, filtered by `_can_ring`, keyed by
  the caveat as `pick_prey` keys them) gives the walk's prey, or null to keep the current
  one. The walk is planned for the walk's prey, `w.prey` carries it, and `sq.prey` is set
  from `w.prey` in `enemy_turn` when the walk plays, with a log line "X loses Y and hunts Z".
- `pick_prey`: unchanged; its key block is shared with `_repick` (lift it into a helper).
- `can_stand`, `_walkable`, `_landable`: unchanged; they read `passable`, and a winged pack's
  trait flows through them. `Unit.can_block` reads the machines' `flyer` only, so a winged
  pack still blocks a machine and is still passed under nothing.

### `sim/battle.gd`

- Remove `move_left` and `moves_left()`; replace `action_from` (id → [hex, facing, move
  left]) with `moved: Dictionary` (mech id → true: it has moved this action). The only readers
  of `action_from` are `.has(id)` checks (the orders board, END TURN's "nothing planned" check,
  the snapshot and the save), so nothing else needs the hex or the facing.
- `can_move(u)`: PLAN, an action left, not `moved`, not pinned.
- `destinations_for(u)`: `field.reachable(u, u.movespeed)` with the carry's lift as today.
- `move_to`, `move_along`, `_walk_machine`: the budget is `u.movespeed`; `_walk_machine` sets
  `moved[u.id] = true` where it set `action_from` and `move_left`.
- `draft_step`: the draft's cost so far is `field.route_cost(u, draft, u.movespeed)` and the
  continuation's budget `u.movespeed - spent`; the function keeps its shape.
- Remove `draft_cost` and `draft_spend`; keep `draft_landing`.
- `_snapshot` / `_restore`: `moved` (as a list of ids) in place of `action_from` and
  `move_left`; `action_hexes` stays.
- `_new_turn` and `finish_skirmish`: clear or erase `moved` where they cleared `move_left` and
  `action_from`.
- `nothing_left`, `attack_hex`, `order_onto`, `threat_for`: unchanged in code.
- The header comment's "move_to() any machine with an action left" gains "once an action".

### `sim/unit.gd`

- `MECH_MOVE := 3`, `PACK_MOVE := 2`, `BOSS_MOVE := 1`; `base["move"]` stays 3. The traits
  comment lists `winged` as a pack's word.

### `sim/save.gd`

- `VERSION := 6` ("6: moves in hexes, a move in one go; 28 October's movement proposal") and
  `RUN_VERSION := 5` ("5: the battle inside it in hexes"), so an older save is refused as a
  version mismatch rather than loaded wrong. The battle's dictionary drops `move_left` and
  writes `moved` as a list of ids in place of `action_from`.

### `sim/content_db.gd`

- The chassis validator: `movespeed` is a whole number from 1 to 6 ("movespeed is in hexes, 1
  to 6"); the same for a foe's. A foe's `winged`, when present, is a bool.
- `pack_profiles`: carries `winged` when the foe has it.
- Retire `movement_flags` and its doc comment (the clause it served, "a ground chassis
  outpacing another way everywhere", retires with the table; section 5).
- `codex_for_unit`: unchanged; the subtitle of a foe's codex (`codex_entry_for` in the battle
  screen builds it) gains "// WINGED".

### `game/battle/battle_map_view.gd`

- Remove `draft_spend`, `draft_move`, the gauge draw at the end of the drawn route
  (`_move_gauge`, `gauge_cells`, `_hatch`, `Cell`, `GAUGE_PIP`, `GAUGE_GAP` and their comment),
  and the slow end hex's dashed edge and `_stop_mark` in the destinations loop (every lit hex
  takes the solid outline); `_stop_mark` has no other caller and goes.
- `MECH_PACE := {1: 2.8, 2: 1.9, 3: 1.25, 4: 0.55, 5: 0.42, 6: 0.36}` (the same seconds a hex
  for the same machine) and `MOVE_REF_SPEED := 5.0` (the packs' reference, so a pack at 2 is
  as slow against it as 20 was against 50).

### `game/battle/battle_screen.gd`

- `_on_route_drag_started`, `_on_route_drag_to`, `_on_route_drag_ended`: drop the
  `draft_move` and `draft_spend` lines; `draft` and `draft_land` stay.
- `_on_end_turn`: `battle.moved.has(m.id)` where it read `action_from`.
- `ground_lines`: rebuilt from `BattleMap.ground_ways` as section 3 lists it.
- `pack_lines`: "Winged" after the ring; `codex_entry_for`: "// WINGED" in the subtitle.

### `game/battle/orders_board.gd`

- `battle.moved.has(m.id)` where it read `action_from`.

### Untouched, by name

`sim/skirmish.gd`, `sim/policy.gd`, `sim/campaign.gd`, `sim/quick_run.gd`, `sim/effects.gd`
(the `move` stat and modules flow as before), `sim/battle_bot.gd` (`move_to` as before),
`game/ui/mech_rig.gd` and `game/ui/mech_view_3d.gd` (they pass the move to the pace table,
which is keyed by hexes now), `game/battle/map_3d.gd`, `game/battle/move_path.gd`,
`game/audio/sound.gd` (the step sounds by way), every model and rig, every content id, every
chassis's `traits`.

## 5. The build: content, tools, pages, records

### The moves, as they stand (Q3A)

Every chassis, its move today and in hexes; the shown names as content prints them.

| Chassis | Maker | Tier | Size | Way | Move today | Hexes |
|---|---|---|---|---|---|---|
| Honey Badger | Minerva | 1 | heavy | tracked | 20 | 2 |
| Baboon | Aphelion | 1 | medium | walker | 20 | 2 |
| Armadillo | Minerva | 1 | assault | walker | 20 | 2 |
| Nemesis | the Arsenal | 2 | heavy | walker | 20 | 2 |
| Whip Scorpion | Wainwright & Sutler | 2 | heavy | walker | 20 | 2 |
| Swallowtail | Wainwright & Sutler | 3 | assault | flyer | 20 | 2 |
| Musk Ox | Wainwright & Sutler | 3 | assault | wheeled | 20 | 2 |
| Giant Petrel (planned) | Kestrel | 3 | assault | hover | 20 | 2 |
| Clydesdale | Wainwright & Sutler | 2 | assault | walker | 30 | 3 |
| Wild Boar | Minerva | 2 | heavy | tracked | 30 | 3 |
| Ammit | the Arsenal | 3 | medium | walker | 30 | 3 |
| Funnel-web | Wainwright & Sutler | 2 | medium | walker | 30 | 3 |
| Dingo | Wainwright & Sutler | 2 | light | wheeled | 40 | 4 |
| Buzzard | Kestrel | 2 | medium | flyer | 40 | 4 |
| Stingray | Aphelion | 1 | medium | hover | 40 | 4 |
| Puffin | Kestrel | 1 | light | hover | 40 | 4 |
| Cassowary | Wainwright & Sutler | 1 | medium | walker | 40 | 4 |
| Lammergeier | Kestrel | 3 | heavy | flyer | 40 | 4 |
| Kite | Kestrel | 2 | light | flyer | 50 | 5 |
| Prairie Dog | Wainwright & Sutler | 1 | light | wheeled | 50 | 5 |
| Cottonmouth | Wainwright & Sutler | 1 | light | hover | 50 | 5 |
| Skua | Kestrel | 1 | light | flyer | 50 | 5 |
| Storm Petrel (planned) | Kestrel | 1 | medium | hover | 50 | 5 |
| Needletail | Kestrel | 2 | light | flyer | 50 | 5 |

Every foe that carries a move (the eight without one take the default, 2):

| Foe | Domain | Behaviour | Ring | Move today | Hexes |
|---|---|---|---|---|---|
| Goblin | Meadow | hunts the nearest | 1 | 20 | 2 |
| Dire Wolf | Meadow | hunts the slowest | 1 | 30 | 3 |
| Gel, Half-Gel | Meadow | push | 1 | 20 | 2 |
| Mandragora | Meadow | push | 3 | 20 | 2 |
| Treant (massive) | Meadow | push | 2 | 10 | 1 |
| Needler | Waste | hunts the nearest | 1 | 30 | 3 |
| Antlion | Waste | hunts the slowest | 1 | 20 | 2 |
| Cockatrice (winged) | Waste | push | 3 | 20 | 2 |
| Sandworm (massive) | Waste | push | 2 | 10 | 1 |
| Revenant | Marsh | hunts the nearest | 1 | 20 | 2 |
| Ghost (winged) | Marsh | push | 3 | 20 | 2 |
| Zombie Knight | Marsh | push | 1 | 20 | 2 |
| Bone Wyvern (massive, winged) | Marsh | push | 2 | 10 | 1 |
| Bomb (winged) | Peak | hunts the nearest | 1 | 30 | 3 |
| Salamander | Peak | push | 1 | 20 | 2 |
| Drake (winged) | Peak | push | 3 | 20 | 2 |
| Magma Elemental (massive) | Peak | push | 2 | 10 | 1 |
| The Warrior | Meadow | hunts the strongest | 2 | 20 | 2 |
| The Martial Artist | Meadow | hunts the nearest | 2 | 30 | 3 |
| The Thief | Waste | hunts the slowest | 2 | 40 | 4 |
| The Lancer | Waste | hunts the strongest | 2 | 30 | 3 |
| The Cleric, the Augur | Marsh | push | 3 | 20 | 2 |
| The Black Mage, the Summoner | Peak | push | 3 | 20 | 2 |

A boss patrols 1 (`Unit.BOSS_MOVE`); the engine's defaults are `MECH_MOVE` 3 and `PACK_MOVE`
2. Modules: Ablative Plating −1, Spall Liner −1, Thrust Overboost +2.

### Content

- `content/chassis.json`: every `movespeed` as the table above gives it (24 entries). Its `_about`'s
  movespeed sentence becomes: "movespeed is the move in hexes, a step a hex; water costs a
  ground machine two and a hovercraft or a flyer one, crags are the flyer's alone, and the
  way of moving among traits (tracked, walker, wheeled, hover, flyer; exactly one) is the
  model, the footfall and a word a passive may read, never a rule (bible section 4)."
- `content/foes.json`: every `movespeed` as the table above gives it (the 26 that carry one); `"winged":
  true` on Q5's foes; the `_about`'s "On the map" sentence becomes: "On the map: zone is the
  pack's ring in hexes (default 1), behaviour push (default; toward the gate) or hunt (one
  machine, locked at spawn; hunts names the caveat: nearest, weakest, strongest, slowest,
  fastest; a hunter that can no longer ring its prey picks again), movespeed in hexes (default
  2; foes move binary, water and crags walls, and a winged foe (winged true) crosses both as
  a flyer does; bosses patrol 1)."
- `content/modules.json`: `ablative_plating` move −1, `spall_liner` move −1,
  `thrust_overboost` move +2; nothing else.
- `content/vocabulary.json`: the shown names stay; the codex texts become, verbatim:
  - movespeed: "Move in hexes: how far a machine goes in an action, a step a hex. Water costs
    a ground machine two; a hovercraft and a flyer cross it at one; crags are the flyer's
    alone."
  - plain: "Open ground. Every machine and pack crosses it."
  - road: "Open ground, the same as plain: the road is art. Every machine and pack crosses it."
  - rough: "Forest and scrub. Every machine and pack crosses it."
  - ruins: "Rubble. Every machine and pack crosses it."
  - water: "Tracks, walkers and wheels wade it, a hex costing two of their move; hovercraft
    and flyers cross it at full pace. Packs never enter it; a winged pack crosses it."
  - mountain: "Impassable, except to flyers and winged packs."
  - flyer: "Crosses everything, water and crags included. Packs walk under it but never stop
    on its hex."
  - hover: "Skims water at full pace; crags stop it."
  - walker: "Legs. Wades water at half pace."
  - tracked: "Tracks. Wades water at half pace."
  - wheeled: "Wheels. Wades water at half pace."
- `tools/stock_fills.py`: the three modules' `move` fills to −1, −1 and +2 (the script is
  idempotent on the branch and must not put the tens back).
- Regenerate `docs/vocabulary.md` (`tools/export_vocabulary.gd`).

### Tools and pages

- `tools/map_survey.gd`: `move` defaults to 3; `moves` to `{"tracked": 3, "walker": 3,
  "wheeled": 5, "hover": 4, "flyer": 5}`; the report's "at move 30" wording to "at move 3";
  the five ways stay in the tables (three of them will read alike, which is the point) and
  the packs at their 2. Regenerate `docs/map_survey.md` at 200 seeds.
- `tools/hangar_motion.js`: `MECH_PACE` keyed by hexes as the view's; `topSpeed()`'s fallback
  `|| 5`. `tools/hangar.html`: the move stat prints `e.movespeed` alone (the "(n open)" goes);
  the stage's fallback `|| 5`.
- `tools/screenshot.gd`: the `draftslow` pose and its branch go; `draft` stays (its "about
  halfway" test reads the move in hexes unchanged). `README.md`: the pose list loses
  `draftslow`; the survey's "at move 30" becomes "at move 3".
- The hangar page republished by the README's procedure with the files that moved:
  `content/chassis.json`, `content/foes.json`, `content/modules.json`,
  `content/vocabulary.json`, `tools/hangar.html`, `tools/hangar_motion.js`; `edits` read
  first, each file checked against the last publish before it is replaced.

### Tests

- `tests/test_map.gd`: `test_words_by_way_of_moving` becomes the crossing table's test (water
  WADE for the three ground ways, STEP for hover, flyer and winged, WALL for no trait; crags
  WALL for all but flyer and winged; plain, road, rough and ruins STEP for everyone; road and
  plain alike; `ground_ways` grouping); `test_spend_ends_the_move_on_a_slow_hex` becomes
  `spend` on water: 2 with 3 left, 1 with 1 left, −1 with 0 left, 1 for a hover.
- `tests/test_battlefield.gd`: `test_reachable_respects_movespeed_and_occupancy` and
  `test_a_budget_is_the_move_left` at 2 and 1 hexes in place of 20 and 10;
  `test_a_slow_hex_is_reached_with_the_last_of_the_move_and_ends_it` and
  `test_any_move_left_enters_a_slow_hex_but_a_normal_one_needs_its_price` become water's:
  a walker at move 2 beside water reaches the water hex at cost 2 and nothing through it; at
  move 3 it reaches two water hexes; a hover reaches water at 1; `test_the_boss_takes_its_move_from_content`
  and `test_a_pack_is_dressed_from_its_foe_type` with the profile's move in hexes (4 and 2)
  and a winged profile giving the trait; two new tests: a winged pack walks over water and
  crags and may stop there; a hunter whose prey stands two hexes into water picks again by its
  caveat in the plan, the lock changing only when the walk plays, and keeps its prey when no
  machine can be ringed.
- `tests/test_battle.gd`: `test_a_machine_moves_at_once_and_keeps_what_is_left_of_its_move`
  becomes "a machine moves once an action": after a move shorter than its move it cannot
  move again, `can_move` false, `destinations_for` empty, its action unspent;
  `test_undo_puts_a_machine_back_with_its_whole_move` asserts `can_move` again;
  `test_nothing_is_left_once_every_machine_has_done_what_it_can` uses `moved` where it set
  `move_left`; `test_the_gauge_tells_a_slow_stop_from_a_spent_move` and
  `test_a_draft_never_outruns_the_move_left` go, the second's useful half ("a draft never
  outruns the move") kept as a test on `draft_step` against `route_cost` at `movespeed`;
  `test_a_drawn_route_is_walked_as_drawn` asserts `moved` in place of the move left; the
  carrier tests read "its action as it was" in place of its move.
- `tests/test_save.gd`: `test_a_battle_in_plan_round_trips` round-trips `moved` in place of
  the move left.
- `tests/test_content.gd`: `test_chassis_validator_wants_one_way_of_moving_and_moves_in_tens`
  refuses 0 and 7 ("in hexes"); `test_movement_flags_name_a_chassis_faster_on_every_ground_and_never_refuse`
  goes with `movement_flags`.
- `tests/test_battle_screen.gd`: `test_the_ground_and_a_refusal_read_as_lines` reads the new
  ground lines (water's wade and cross lines; a crag's wall line; the packs' line).
- The suite green (709 tests today), run as the README says, under the watchdog.

### Records

- `docs/rules.md`: section 2's bullets pasted in; the chassis `_about` text is content's.
- The bible (`docs/design-bible.html`, its first row says how a row is written; bump the
  version and republish by the status's Pages procedure, the live page read first):
  - Section 4, the ground row ("Each way of moving calls each ground fast, normal or slow
    ..."), rewritten Decided: move is a count of hexes and ground is ground, water the one
    priced hex (two of a ground machine's move, always enterable with what is left); hover and flyers cross it, crags are the flyer's; rough and ruins are landscape; a way of moving is the model, the footfall and a
    word a passive may read, never a rule (Ryan, 28 October: no reason beyond visual variety).
    Retired: the per-way table of fast, normal and slow with its stop (2 October): the form
    that failed is the table, and the test it failed is Ryan's play of 27 October ("confusion
    and overhead for no strategic gain") with the survey's read of 8 October (the trip north
    barely moves, the lanes do). What reopens a second priced ground: a decision the player
    makes on the map, never a shape of reach or a way's identity. What reopens water's price:
    Ryan's play finding the squad walled or the wade unread. The clause "the content check
    flags, never refuses, a ground chassis outpacing another way everywhere" retires with the
    table.
  - Section 4, the foes-binary row, rewritten: foes move binary, ground or wall, never slowed;
    a winged foe crosses water and crags as a flyer does and stands there (Ryan, 28 October,
    lever 2: parity that takes the refuge from a flyer, not the bonus the Final Fantasy rule
    forbids); terrain is never a bonus to foes.
  - Section 4, the no-arithmetic row, rewritten: the map draws reach and nothing else.
    Retired: the pip gauge (3 October) and the stop sign (25 October) with the fast and slow
    hexes they showed; move rewards, if rewards ever come, in hexes.
  - Section 4, the map-types row: the reading in Q4A's words ("the name is the intel, and the
    intel is the walls"), and Ryan's direction of 28 October as its Open tail: the five become
    six shapes (section 10), a generator session of its own.
  - Section 4, the planned-moves row: its Open line closed, Decided: a move is given in one
    go (Ryan, 28 October), what moving in pieces bought (a look at the red band after a step)
    the band shows before the move.
  - Section 4, a new row, Decided: the crossing is priced where balance is read, never by a
    map rule (Ryan, 28 October: levers 1, 2 and 3, his "I keep wanting to add more
    complexity to the map, but ultimately I'm doing more harm than good"); the reason (section
    9 here); the exit: the pricing run's read of the crossers, and Ryan's play.
  - Section 5, the hunters' row (the fights-picked-on-the-map row): the re-pick appended in
    section 2's words.
  - Section 12: nothing, unless a Q above is still open at the build, in which case the build
    stops at it.
- `docs/status.md`: the movement line under How things stand becomes the landing's; the
  tests line's count; the Pages bullets for the bible and the hangar.
- `docs/todo.md`: tick "Movement given in one go, or a clearer mark that a machine has move
  left" (landed by removal); the pricing-run line gains "and the crossing's price (the
  movement proposal, lever 1)"; the fresh start's line gains "its winged elites cross as the
  five do".
- `docs/briefs/kestrel_gun_platform.md` and `docs/briefs/kestrel_shield_spender.md`:
  each hover line rewritten to "a hover: crosses water at full pace where a ground machine
  wades, crags stop it" and the Giant Petrel's "fast-looking, slow, and fast only on water"
  to "fast-looking, slow, and amphibious"; `docs/briefs/minerva_siege_battery.md`: the passive
  candidate "Massive Chassis: terrain penalties don't apply" struck with "no penalties remain
  (the movement proposal, 28 October); the charge as the passive stands".
- `docs/measurements.md`: one entry for the survey rerun and the campaign rerun (section 6).
- `docs/mechanics_audit.md`: untouched (a record of 25 October).
- This file retires in the landing commit, its decisions being rows, rules and content.

## 6. Measurement, and done when

- `tools/map_survey.gd` at 200 seeds: phases to the rift and reach after two phases for the
  five ways and the packs, read as bands against the 8 October table; the ground ways read
  alike, hover above them, the flyer above hover.
- `tools/campaign_run.gd` at 40 runs: its bot moves the squad as one onto the nearest pack,
  so its wins and its battle counts should sit in the 27 October bands; a cell that moves is
  a bug to find, not a result to record.
- Ryan's play: the harness with `RIFTGATE_MAP_KIND` for Badlands and Flooded first, since
  they are the two that still read.
- Done when: the suite is green; both reports and the vocabulary are regenerated; the rules,
  the bible (republished), the status, the to-do and the briefs say the new thing and nothing
  of the old; the hangar page is republished; this file is retired; every Q was answered
  before its code was written.

## 7. Never

- No gauge, no stop sign, no dashed edge, no mark on water, no number on the map.
- No cost but water's, and water's only as Q1 says; no per-way cost, no "slow" word anywhere.
- No change to the skirmish, the policy, the campaign or the quick campaign.
- No move number other than Q3's; no content id renamed; no chassis trait changed; no model
  or rig touched.
- No new rule on the crossers (D6), and no re-pick that mutates a hunter's lock at preview.
- No tolerant loading of an old save: the version refuses it.
- No guess where this file is silent: stop and ask.

## 8. The bench

What this lands kills, one line each with the rule that kills it, so Ryan can overrule the rule.

- Fast ground (wheels on open ground, hover on water): killed by hexes and one ground; its
  only visible trace was the gauge's half pip and wheels making the rift in 3.8 phases.
- Slow ground as a stop (tracks on ruins, walkers in water, wheels and hover off their
  ground): killed by one ground; the stop sign was what the player asked the meaning of.
- Tracks fording water at full pace (Minerva's tracked machines): killed by one rule for every
  ground machine; every ground machine wades.
- Water as a refuge for everyone: today any machine can end a move in water out of a ring-one
  hunter's reach; under Q1A it still can, under Q1B it is the hover's and the flyer's, and
  levers 2 and 3 take its worth either way.
- The Giant Petrel's irony, "fast-looking, slow, and fast only on water": slow and
  amphibious; its water speed, if ever wanted, a passive of its own.
- The Storm Petrel's river road, "water fast, so it rides the river the jets fly over": the
  river is its shortcut past a wade, not its speed.
- The siege battery's "Massive Chassis: terrain penalties don't apply": nothing left to
  ignore; the brief's alternative stands.
- Rubble Field as the walker's map and Open Steppe as the wheels' (the map-types row): looks.
- Moving in pieces (move, look, move again): killed by one go; the band shows the look first.
- The move gauge (3 October) and the stop sign (25 October): none.
- The ground tap's word per way (twelve vocabulary entries): three lines, by crossing.
- "Move rewards come in tens": in hexes, if rewards ever come.
- The content check that flags a chassis faster on every ground: retired with the table; the
  pricing run reads the crossers instead.
- A map rule on the crossers (no attacking from water, a price to cross): never (D6).
- Crags as slow ground: already set aside (a map rule alone is weak).

## 9. The read behind it (27 and 28 October)

Kept short, since the bible rows carry it once it lands.

- The weighing was the pathfinder's, not the player's: a tap took the cheapest route and the
  map drew the reach, so the table never asked the player anything. It shaped a blob and
  planted a stop sign, the sign Ryan asked the meaning of on 25 October.
- The map survey of 8 October (`docs/map_survey.md`, 200 mixed maps): phases to the rift at
  move 30 were 6.0 for tracks, walkers and flyers, 5.6 for hover, 3.8 for wheels; reach after
  two phases 31% of the field for tracks to 62% for flyers and wheels. Its own read: "the trip
  north barely moves, the lanes do". The walls bit; the words did not.
- Three of the five ways were indistinguishable in play; the flyer over crags and the hover
  over water were the two a player could see. The audit's 29 found the words drifting from
  the numbers already.
- Nothing measured depends on movement: the balance runner reads no map number and the
  campaign bot moves the squad as one onto the nearest pack. Ryan's play decides feel, which
  is the bible's own order.
- The display's weight traced to two rules: half pips for the fast hex, hatched cells for the
  slow stop. The 25 October complaint was those two rules showing.
- Move was never reduced: the chassis stood at 20 to 50 since before the stock pass, which
  moved hull, shield and armour. The tens were sized for move rewards in tens, never built,
  and the fast hex; three of seventeen modules touch move.
- The spread of move is the one map number that does something (the detachment row), so it
  stays as hexes and nothing finer.
- Flyers and hovers (Ryan's concern, 28 October: eleven of 24 chassis cross, the backlog adds
  more): hexes narrow the gap rather than widening it, since a flyer already had no bad ground
  and the ground machines lose their stops; crossing buys a flank and a refuge, not tempo
  (equal phases to the rift at equal move); move follows size (five of the eleven are lights,
  two assaults at 2); a squad moves at its slowest; the depth lives in the fight, where nothing
  reads the ground. The refuge is the one thing walls would make exclusive, which levers 2 and
  3 answer; the price of crossing is the pricing run's, since the stock pass sets numbers by
  size and role and never by way.
- Water priced (Ryan's suggestion): it narrows the hover's edge without pricing anything,
  keeps water a cost in time as the 2 October row wanted (a stop for walkers and wheels, a
  ford for tracks), changes no lane under the player's feet, and shows nothing. Against it: it
  adds no decision (the pathfinder weighs the two against the one), two moves collapse in
  water under either rounding (rounded up, 3 and 4 both wade two), and it is the wedge Ryan
  named, guarded by the row that names water the only priced ground and what reopens a
  second.
- Ground movers (Ryan's question): nothing built or decided read tracks, wheels or legs but
  the terrain table and the footstep sounds; no passive, module or foe named one; the only
  brief that did was the siege battery's pitch, which already carried an alternative. What the
  records say of a tag and a theme (no rule of its own; a lean, never a rule; a map rule alone
  is weak) is what the ways become.

## 10. The map shapes: the second session (Ryan, 28 October)

Ryan, on Q4: "I would prefer to rework them into shapes. So heavy water that runs
horizontally (aka, river crossings with fords), heavy water that runs vertically (a fjord), a
mix of small ponds and grouped crags breaking the battlefield into winding paths (Badlands),
Relatively clear (Open Steppe), heavy crags using the ruins tile that run horizontally with
gaps (ruined city), heavy crags that run vertically (gorge or ravines)." Claude's read: it
works, and better than the five, because each shape tests exactly one of the two things the
new rule prices, so the name is the intel and the intel is the shape. It is a generator
session after the movement session lands, with its own survey run and Ryan's eye on the maps.

### What each shape tests

- **River** (heavy water across the field, with fords): packs funnel through the fords, which
  are the horde's guaranteed crossing; a ground squad holds a ford or wades (a two-wide river
  takes a move of 2 two turns, a move of 4 one); hover and flyers cross anywhere. Tests the
  crossing held and the wade.
- **Fjord** (heavy water down the field): two lanes for packs; a ground squad changes lanes by
  wading; hover and flyers freely; a hunter on the far side re-picks. Tests lane choice and a
  detachment across water.
- **Badlands** (small ponds and grouped crags, winding paths): packs wind, flyers go straight,
  hover crosses the ponds, ground machines wade them. Tests everything at once and the
  longest walks.
- **Open Steppe** (relatively clear): no lanes; the baseline the others are read against.
- **Ruined City** (crag bands across the field with gaps, on a ruins base): packs and ground
  squads funnel through the gaps; flyers and winged packs go over. The 3D map already draws a
  crag on a ruins base as dead skyscrapers (`Map3D._crag`, `crag_base`), so the look costs no
  art. Tests the gaps held and the flyer's one exclusive crossing.
- **Gorge** (crag walls down the field): lanes with no wading; a lane is changed only round a
  wall's ends; flyers and winged packs cross. Tests the hardest lane commitment and the
  re-pick across walls.

### What stands and what the generator needs

- The crossing guarantee stands as it is (three disjoint horde routes, `_ensure_ground_path`
  carving where a shape closes the field), so a band across the field is given its gaps by
  design (two or three hexes each, placed by seed) and checked by the guarantee; a wall down
  the field cuts nothing, and a lane a machine could plug alone is already what the guarantee
  forbids. The "one real water feature" clause of the field row retires: a shape has its own
  features, and three shapes have no water.
- Every shape keeps the rift's mouth and the rows around the boss's ring clear (rows 0 to 3),
  the team's ground and the two rows before the gate clear of water and crags (as today), the
  gate's and the rift's neighbours open, and the roads as art (a city's streets).
- New laying: a band of water or crags across the field with gaps; a band down the field (the
  fjord, the gorge's walls), one or two, placed by seed, running from row 4 to the team's
  ground; ponds (the `puddles_t` field, grown to two or three hexes); grouped crags (the ridge
  noise with a higher threshold, clustered). The horizontal river with fords exists
  (`_lay_feature`); the lake band retires. Thickness and count are the shape's knobs in
  `BattleMap.KINDS`, every number a placeholder: a river two to three thick with one or two
  fords; a fjord two to three wide; city bands one to two thick with one or two gaps; one or
  two gorge walls one thick.
- The survey (`tools/map_survey.gd`, `--type` each shape) measures each: the ground shares,
  the horde's narrowest crossing and its route length (today 19 to 20 hexes; a winding
  Badlands that doubles it changes the pacing, since Rift Pressure fills at 12), and the
  phases and reach by way; `--show SEED` prints a map as text for Ryan's eye, and the harness
  with `RIFTGATE_MAP_KIND` shows it on screen.
- The campaign picks a shape by the rift's seed, every shape alike, until a domain lean is
  decided (a Lean row, never an exclusion: the Marsh toward water, the Peak toward crags); the
  front card shows the shape's name once the mission map exists.

### Questions for Ryan, for the shapes session

1. The names, as the front card will show them: RIVER (or RIVER CROSSING), FJORD, BADLANDS,
   OPEN STEPPE, RUINED CITY, GORGE (or RAVINES).
2. Mixed Ground: retired (Claude's lean: the six replace the five, and the campaign draws by
   seed), or kept as a seventh for the harness.
3. Domain leans toward shapes, now or later (Claude's lean: later, from play).

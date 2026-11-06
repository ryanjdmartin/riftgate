# The long wall: the build brief

<!-- hangar: {"kind": "rule", "maker": null, "tier": null, "status": "session", "slot": false, "name": "the long wall"} -->

Instructions for the session that builds Ryan's redesign of 5 and 6 November: the battle as the
defence of a long wall, the packs as authored formations, the shield and the heat the fight's,
no withdrawal. The design and its rounds are `docs/long_wall_proposal.md` (read it first, its
section 10 newest where rounds differ); this file is the build order. It says what is decided
and by whom, what is a named placeholder, and what is open and must not be built. Nothing here
is to be reinterpreted, extended or completed: where this brief is silent, the rule is the one
the code runs today, and where a decision is missing it is listed in section 9 and left alone.

## 0. The rules of this build

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row, `docs/status.md`'s Start here,
  `docs/briefs/README.md`'s How a session runs, then `docs/long_wall_proposal.md`, then this.
  If a chat and a file disagree, the chat is newer; if this brief and the proposal disagree,
  this brief is newer.
- Work on a branch of your own taken from `ccr-56b5169d-lsa2rg` (it holds the proposal and the
  rerolls at two) or from main once that branch has landed; never on main.
- **Guess nothing.** Every number this brief calls a placeholder is set exactly as written,
  marked `# placeholder (the long wall brief)` in code, and listed in the hand-back (section
  10). A number the brief does not name is not yours to set: stop, list it in the hand-back
  under "needs a number", and build the mechanism with the value that changes nothing (zero, or
  today's value) so the build stays green. A design question the brief leaves open (section 9)
  is not built and not worked around.
- No new mechanism. The proposal's rounds retired the plan layer, the beat line, the second
  line's beat, the reroll tax, the re-seal and the shell; none returns under another name. No
  hint on the map but the threat rating (section 3.7). The player is never told how to beat a
  formation (Ryan, 6 November: "I don't think we should be telling the player explicitly how to
  beat a formation").
- No content invention. Compositions, their layouts, their sizes for the squad, foe numbers,
  chassis numbers, the map's shapes and any sector library are content and are proposed in chat
  to Ryan first (CLAUDE.md); this build changes content only where section 6 says so, and only
  as it says.
- Every rule that changes is edited in place in `docs/rules.md` in the same commit as its bible
  row, and the row carries Ryan's words as section 2 quotes them, with the date, never a
  paraphrase. Section 8 lists the rows and the lines.
- Tests are rewritten to state the new rule, never deleted; every new rule has a test on
  synthetic content (a synthetic composition, a synthetic chassis), never on a named entry.
  Enum-typed fields and params are declared `int`. Wrap every headless Godot run in the
  watchdog. A cloud container whose import predates a branch's new `class_name` fails the screen
  and rig suites with a parse error: run `--import` again first (the status's note).
- Commit after each verified chunk with the tests green; push the branch; update
  `docs/status.md` at the end of the session and when a large piece lands.
- The order is section 1. Phase 1 ends with a hand-back; Phase 2 starts only on Ryan's word
  after he has read it.

## 1. The order

Phase 1, the sim, headless and seeded, read before anything on a screen moves:

1. The field's size from the ramp, and the campaign, the harness and the runners passing it
   (section 3.1).
2. The tide: the opening, the beat, the tears and the seam at the new depth (3.2).
3. The pusher's segment (3.3).
4. Fights without joining; the attack range (3.4).
5. No withdrawal (3.5).
6. The shield and the heat fresh every fight; the field recharge stat removed; the shield regen
   stat added at zero (3.6).
7. The threat rating in the sim and on the hold (3.7).
8. The thresholds from the tide; the timer after the Rupture (3.8).
9. The composition schema: `layout`, `lead`, `squad`, variants (section 6).
10. The defence bot and the campaign runner's new measures; the promise read in the balance
    runner (section 5).
11. The records (section 8), then the reads (section 10), then the hand-back.

Phase 2, the view (section 7), on Ryan's word.

## 2. What is decided, and by whom

Each item: the decision, its source, and whether the build touches it. "Ryan" is his word in
the chat of 5 or 6 November, quoted; "Claude's lean, unmoved" is a form Claude proposed in the
rounds that Ryan read and did not move, built as the simplest form and listed in the hand-back
for his marks; "placeholder" is a number set only so the mechanism runs.

| # | Decision | Source | This build |
|---|---|---|---|
| D1 | The battle is the defence of a long wall: wide along the wall, shallow from the rift to it. | Ryan, 5 November: "Wide map, with lots of wall to defend, but not as deep." | Built (3.1) |
| D2 | Width and depth are levers, not fixed. | Ryan, 5 November: "playing with map width and depth is a direct factor on battle difficulty now, and it's possible we no longer need to fix it in stone." | Built as ramp functions at placeholder values (3.1) |
| D3 | The tears matter more the closer they open: "every hex closer to the wall matters so much more." | Ryan, 5 November | Built: the seam and the tears at the new depth (3.2) |
| D4 | Rift packs target a wall segment, not the gate's column; the variance of the target is a ramp factor. | Ryan, 5 November: "they can target a segment left or right of it, reducing clogging and creating extra tension. The variance of where they target can even be a ramp factor." | Built (3.3) |
| D5 | The engagement system (rings, joining, the band) goes: "it just adds so much complexity for not a lot of gain." | Ryan, 5 November | Built: one pack is one fight (3.4) |
| D6 | Packs are formations, "either completely predetermined by the engine or semi-random combinations". | Ryan, 5 November | Built as the composition schema only (section 6); no content |
| D7 | The field recharge stat goes. | Ryan, 6 November: "removing field recharge is fine" | Built (3.6) |
| D8 | No recharge anywhere: the shield and the heat are the fight's, full and zero as every fight opens; hull is the battle's. | Claude's answer to Ryan's "if there is in-battle recharge it's going to feel very disconnected", unmoved | Built (3.6) |
| D9 | Base shield regen as a chassis stat, a buffer for build strategy. | Ryan, 5 November: "Base shield regen and cooling returning, as a build-strategy buffer"; the form (a stat at the round's start beside cooling) Claude's | Built as the engine slot at zero on every chassis (3.6); no number |
| D10 | No withdrawal. | Ryan, 6 November: "what if there's just NO withdrawal? Tactical options get removed, obviously, but it does simplify things a huge amount." | Built (3.5) |
| D11 | No re-seal of the boss; the tide quickens after the Rupture instead. | Ryan, 6 November: "do we need to re-seal the boss? Isn't that just a feel-bad, or a non-choice?"; the quickening Claude's lean, unmoved | Built: nothing re-seals; the timer after the Rupture is a placeholder (3.8) |
| D12 | The escalation is time's, never the kills'; a Fracture brings the elite and nothing more. | Claude's third round, unmoved (after Ryan: "Let's not trip up at the finish line") | Built: the Fractures and the seal unchanged; no shell |
| D13 | The player is not told how to beat a formation; no beat line; no plan layer. | Ryan, 6 November: "I don't think we should be telling the player explicitly how to beat a formation. You even said that learning the formations is the mastery."; "Why do we need the beat line, at all ... It's so hamfisted" | Nothing built; nothing shown |
| D14 | The threat rating of a pack is shown on the map: how many machines it is intended for. A formation is a three, a patrol a one, an elite and a boss a true four. | Ryan, 6 November: "The one thing we should do is show the threat rating of a formation on the map. For how many units it's intended for."; and: "a 'true' 4 should be reserved for elites and bosses, with formations a 3. Then the decision becomes a 1-3 split, a 2-2 split where one is safe and one short (or taking two 3 fights short, or two patrol fights safe), or all 4 on the formations and ignoring the flanks." | Built: `squad` in the sim and on the hold (3.7); the pips are Phase 2 |
| D15 | The two views are a purely visual option: the wall at the left with the rift at the right, or the wall at the bottom with the rift at the top. | Ryan, 6 November: "I meant have a purely visual option between wall left + gate right and wall bottom + gate top. Just because some people like playing up instead of sideways." (his "gate right" reads as the rift's side, the wall and the gate being one side) | Phase 2 (section 7) |
| D16 | Rerolls are two a round. | Ryan, 6 November | Already built on `ccr-56b5169d-lsa2rg` |
| D17 | The battle opens with the siege under way, not with empty turns. | Claude's third round, unmoved | Built with placeholders (3.2) |
| D18 | The tide: waves on a beat, the beat the ramp's and shortening, the tears adding patrols, nothing on the field at the start but the first wave. | Claude's design; Ryan, 6 November: "We are aligned, your reasoning is sound." | Built with placeholders (3.2) |
| D19 | Reinforcement inside a fight stays as it is. | Open: Ryan asked "what gameplay does it solve?" and has not answered Claude's lean to cut it | Unchanged; not built, not removed |
| D20 | Carries, map loot, the map's shapes relaid, a sector library, the Fracture's shape beyond today's, the hex size floor, the elites' map effects, foe and chassis numbers, the formation content itself. | Open (section 9) | Not built |

## 3. The engine, piece by piece

File and function names are as they stand on `ccr-56b5169d-lsa2rg`. Where a function is named,
change that function; where a new one is named, add it beside its kin with a comment that says
what it is and cites this brief.

### 3.1 The field's size

- `sim/ramp.gd`: two new functions, `wall_length_at(c)` returning 20 and `depth_at(c)`
  returning 12 for every Convergence, each marked placeholder. The comment says the wall's
  length is the count of hexes along the wall (the map's `width`) and the depth the rows from
  the rift's row to the last wall row inclusive (the map's `height`).
- `sim/battle.gd`: `setup(team, faction_id, w, h)` takes `w = -1` and `h = -1` to mean the
  ramp's (`Ramp.wall_length_at(ramp)`, `Ramp.depth_at(ramp)`), read after `ramp` is set.
  `DEFAULT_WIDTH` and `DEFAULT_HEIGHT` stay as constants for tests that pass a size; nothing in
  the game passes them. `sim/campaign.gd` (`b.setup(team, lead)`), `sim/harness_setup.gd`
  (`b.setup(mechs, lead_faction())`) and both runners therefore take the ramp's size without
  a change; check each and `game/harness.gd`'s battle page and say in the hand-back which
  path each took.
- `sim/battle_map.gd`: no change to the shapes. `generate` already takes any size. The
  reservation (`MOUTH_ROWS` 4, `_hi()` = height − `GATE_ROWS` − 3) stays; at a depth of 12 the
  shapes lay in rows 4 to 7, and three of them degenerate (the proposal's section 3, Map
  generation). That is accepted for Phase 1: every read in section 10 runs on OPEN STEPPE, and
  the hand-back carries a text print of each shape at 20×12 for Ryan's sector decision (the
  proposal's authored sectors are a content proposal and are not built).
- The team's setup row, the gate's and the rift's columns, the apron and the walls follow the
  size already (`Battle.setup`, `BattleMap.flat`); confirm with a test at 20×12 and one at 30×10
  that the gate is centred, the wall spans the width, the rift is three hexes at the top
  centre and four machines stand on the row before the apron.
- `tools/map_survey.gd` takes `--width W --height H` (default today's 9 and 20); run it at
  20×12 on steppe for the hand-back, into `docs/measurements.md` (section 10), never over
  `docs/map_survey.md`.

### 3.2 The tide

- **The opening** (D17, placeholders): in `Battle.setup`, the ramp's count of formations
  (`Ramp.formations_at`) is placed as today across the width, but on the row `apron_row −
  move`, where `move` is the placed pack's move after `dress_pack` (its slowest member's), so
  its first walk ends on the apron and it strikes at the end of the first enemy turn unless
  fought on turn one. The ramp's count of patrols (`Ramp.patrols_at`) stands on the flanks as
  today, on the row `apron_row − 2 × move`. If a row would be above the mouth rows (a very
  shallow field), it is clamped to `MOUTH_ROWS`. Rift Pressure opens at `rift_pressure_max −
  1`, so the rift's first wave spawns at the end of turn one, "the second spawning behind it".
  Both the rows and the opening pressure are placeholders.
- **The beat**: `Ramp.timer_at(c)` returns 3 for Convergence 0 to 7 and 2 from 8 (placeholder;
  today 12 − c/3). `Battlefield.TIMER_FLOOR` becomes 1. `Ramp.step_at` stays 0.
- **A peak** (`Battlefield.peak`) is unchanged: the cycle's next composition from the rift, a
  patrol from every tear open before the peak, the seam's creep, the ramp's count of new tears.
- **The seam**: `SEAM_START` is replaced by `seam_start()` = `MOUTH_ROWS + 1` (5 at any depth:
  today's number at 20, one row below the mouth at 12), creeping `Ramp.seam_creep_at` (2) a peak
  as far as `apron_row()` as today. The save (`sim/save.gd`) reads `seam_row` with that default.
- **Tears**: `tear_hex` and `Ramp.tears_at` unchanged.
- Nothing else about the cycle changes: formations and patrols in turn, the lead's and the
  guest's in turn, the elites at the Fractures from the rift.

### 3.3 The pusher's segment

- `Unit` gains `goal_col: int = -1`, a pusher's wall column; saved and loaded like `prey`.
- When a pack is placed at the start or emerges (`Battlefield.emerge` and the setup's
  placements, in one helper `assign_goal(sq)`), a pusher (`behaviour == "push"`, not the boss)
  draws its goal: the rift's column plus a draw in `[−spread, +spread]`, `spread =
  Ramp.spread_at(ramp)`, clamped to `[0, width − 1]`. The draw is deterministic and uses no new
  stream: `(phase * 31 + sq.id * 17) % (2 * spread + 1) − spread`, so a resumed battle draws as
  the unbroken one did. `Ramp.spread_at(c)` returns `2 + ((width / 2 − 2) * c) / 12`, rounded
  down, where width is the wall's length (pass it in): 2 at the foot, half the wall at the top.
  Placeholder. A hunter draws none.
- `Battlefield._walk`: a pusher's goal is the apron hex in column `goal_col` when it is land and
  reachable; otherwise the reachable apron hex nearest that column by column distance, ties
  toward the gate's column. Everything else in the walk (the Dijkstra, the budget, the wade, the
  landable check, `strikes` on the apron) stays. A pusher already on the apron does not move
  (as today).
- The strike is unchanged: any pack ending its walk on the apron strikes the gate's bar for
  its strength × 10 / 3, at least 1 (`enemy_turn`).
- Tests: a pusher at spread 0 walks to the rift's column; at spread 4 the goals of eight
  pushers spread over nine columns; a goal column that is water or a wall resolves to the
  nearest land apron hex; a save and load keeps the goal.

### 3.4 One pack is one fight

- `Battlefield.attack_roster(targets)`: `joins` is always empty. The ring (`zone`) is read
  nowhere but a hunter's catch (`catch_of`, `reaches`, `_stand_in_walk`, `_walk`'s
  `w.catches`); `in_ring` keeps its definition for those callers. The doc comments of
  `Battlefield` and `Battle` that describe joining are rewritten to say one pack is one fight.
- `Unit.attack_range` default becomes 1 (placeholder: adjacency), and
  `ContentDB.pack_profiles` / the chassis load keep whatever sets it today (if content sets a
  machine's attack range anywhere, say so in the hand-back; the brief expects none).
- `Battle.attack(target, machines)` opens the fight on the one pack with the machines in range
  of it; `order`, `order_onto`, `attack_hex`, `in_range_from` and `can_target` read the new
  range and nothing else changes. Several orders onto different packs queue as today and
  `engage()` opens them one at a time, hunters' catches first; the order of fights in a turn
  never changes an outcome (test it: two packs, two machines, both orders, the result the same
  whichever engages first).
- The boss's fight: unchanged (ordered onto, takes every machine, ends the battle); since
  nothing joins, the boss's fight holds the boss unit alone, escort and commanders inside it.
  `Battle.next_fight_is_boss` and the screen's reveal are untouched.
- Hunters: unchanged in every rule (the prey, the caveat, the pounce at `HUNTER_RING` 2, the
  sealed-off prey, the forced fight first, the caught machine not moving first). A hunter's
  catch is now a fight to its end (3.5).
- Tests to rewrite (each keeps its name's meaning or is renamed to the new rule, never
  deleted): `test_attack_opens_a_fight_with_the_target_the_packs_that_join_and_the_machines_committed`,
  `test_a_fight_is_joined_by_every_pack_whose_ring_covers_the_target`,
  `test_the_machines_in_range_of_the_target_may_join`, `test_range_and_rings_count_from_any_footprint_hex`,
  `test_a_machine_out_of_range_cannot_be_committed`, `test_the_attack_hexes_ring_the_move`,
  `test_the_attack_hex_is_the_farthest_in_range_the_move_reaches`,
  `test_moving_out_of_range_drops_the_order`, `test_a_fight_the_boss_joins_takes_every_machine`
  (now: a fight on the boss takes every machine; no pack joins it), and the screen tests that
  draw joining.

### 3.5 No withdrawal

- `Skirmish.can_withdraw()` returns false; `withdraw()` returns false and does nothing.
  `Outcome.WITHDRAWN` stays in the enum (saves and the runners' tallies read it) and is never
  produced; the comment says so.
- `sim/battle_bot.gd`: `withdraw_below`, `withdrawals` and the persona's lines go; a forced
  fight needs no exception. `sim/policy.gd`'s `withdraw_below` goes with its callers.
  `tools/campaign_run.gd` and `tools/balance.gd` drop their withdrawal columns and the "w"
  mark; `tools/screenshot.gd`'s withdraw references (poses) go; `sim/quick_run.gd` and
  `tools/quick_run.gd` drop "no withdrawal" as a difference, since there is none anywhere.
- `game/skirmish/skirmish_screen.gd`: the WITHDRAW button is removed (Phase 2 may do this with
  the screen work; in Phase 1 it is disabled and hidden). `game/ui/hud_button.gd`'s comment on
  the quiet variant names another use or none.
- Tests: `test_a_withdrawal_never_grows_a_pack_by_its_halves` and
  `test_withdrawing_from_a_hunter_leaves_the_machine_caught` become tests that a fight has no
  withdrawal (the button's state, `can_withdraw` false at every state) and that a hunter's
  catch ends in the pack's fall or the machine's wreck; `test_the_bots_persona_withdraws_from_a_fight_it_is_losing`
  is replaced by a test that the bot fights every fight out; every skirmish test that withdraws
  is rewritten to end its fight by a kill or a wreck.
- The vocabulary's `withdraw` term is removed (section 8); no code reads it.

### 3.6 The shield and the heat the fight's; no recharge; the regen slot

- **Full shield at every fight's start**: in `Battle._build_skirmish`, before `sk.add_mech(u)`,
  `u.shield = u.shield_max`. The quick campaign's `_recharge()` in `sim/quick_run.gd` does the
  same for every standing machine in place of the field rate, and its screen's hint text
  (`game/quick/quick_run_screen.gd`) says shields are full at every fight. Heat already opens at
  zero (`ms.heat = 0` in `Skirmish`): confirm with a test that a machine leaving a fight at full
  heat and half shield opens the next at zero heat and full shield.
- **No recharge on the map**: `Battle.end_turn` no longer calls `recharge_shield` and no longer
  fires `out_of_combat` for shield (the trigger stays defined in `Effects` and the vocabulary as
  a trigger that fires at the end of a turn out of a fight, with no shield meaning; no content
  passive uses it today, which the hand-back confirms). `Unit.recharge_shield` stays as the
  method the Regenerating status and the skirmish's shield gains use, if they do; if nothing
  calls it, remove it.
- **The field recharge stat removed**: `recharge_field` leaves `Unit` (the property and
  `base["recharge"]`), `ContentDB` (the load at line 196, `STAT_WORDS`'s "recharge", the codex
  stat items at 459 and 504, the required-key list at 1759), `content/chassis.json` (every
  entry's `recharge_field`, 25 of them, and the `_about` text), `content/modules.json`'s
  `_about` text (no module carries the stat), `tools/stock_fills.py`, `tools/stock_loop.py`,
  `tools/chain_probe.gd` and `tools/chain_probe_read.py` (their recharge variant becomes the
  full shield between fights, the one rule). The validator refuses `recharge_field` with a
  message that names this brief, as it refuses `recharge_combat` today.
- **Shield regen** (D9): a chassis key `shield_regen` (default 0 when absent; the validator
  accepts 0 to 9 and nothing else), `Unit.shield_regen` read through `Effects` as `cooling` is
  (a stat modules and passives may add to later; none does now), `base["shield_regen"]`. In
  `Skirmish.start_round`, after the cooling and before the roll's passives, every live
  machine gains its `shield_regen` up to its maximum, one log line for all, as the cooling
  logs. `ContentDB.STAT_WORDS` gains "shield regen"; the codex and the hangar show the stat only
  when it is not zero. No chassis gets a value; a synthetic chassis in a test does.
- Tests: `test_shield_recharges_at_the_field_rate_only_in_a_turn_without_a_fight` becomes a
  test that a turn without a fight changes no shield and a fight opens at full; a regen test on
  a synthetic unit (2 a round, capped at the maximum, logged, none while sealed if the
  Armadillo's seal stops cooling: it does not stop regen, since nothing says so; say that in
  the test's comment); the validator's refusal of `recharge_field` and its acceptance of
  `shield_regen`.

### 3.7 The threat rating in the sim

- Every pack on the map carries `squad: int` (1 to 4): from its composition's `squad` when
  content gives one, else from its size (Ryan, 6 November): a patrol 1, a formation 3, an
  elite 4, an escort 4. A one-type pack with no composition (the harness's composed side) reads
  3. The boss unit reads 4. Saved and loaded. The default by size is his; a composition's own
  value, when the formation pass writes one, overrides it, and 2 is a legal value for a heavy
  patrol that pass may author.
- The hold (`Battle.roster` and whatever the map's readout strings come from) says "A fight
  for one", "for two", "for three", "for four" as the first line after the pack's name.
  Nothing else is added to the hold.
- The shape this sets, so the bot and the reads are built to it: fighting as four is the safe
  play, the lightest in hull and the heaviest at the wall, so a four on a formation is
  overkill the wall pays for; the default posture is three on the formation and one on the
  flank; a pair on a formation is short, a pair on a patrol is safe; an elite or a boss asks
  for all four and breaks the posture. The refit the reads inform (not run here, section 9)
  is held to: a pack for N fought by N costs the team about its shields and a tenth of its hull
  at competent play; by N − 1 about a quarter, with a real chance of a wreck on the greedy
  rung; by N + 1 almost nothing.
- The runner reads it (section 5).

### 3.8 The thresholds, and the timer after the Rupture

- `Battle.setup`'s `field_menace` becomes: the menace of the packs placed at the start (as
  today) plus the menace of the first `Ramp.fractures_at(tier)` compositions of `field.cycle`
  taken in order, each member's strength at the ramp's density (`Ramp.scaled`). Placeholder.
  `RUPTURE_SHARE` and `FRACTURE_STEPS` unchanged.
- After `rupture()` (either way it comes), `field.rift_pressure_max` becomes `maxi(1,
  rift_pressure_max / 2)` once, and `peak`'s own shortening by `Ramp.step_at` still applies
  after it. Placeholder. The log says "the rift convulses: the beat is now N".
- No shell, no re-seal, no change to `_fractures`, `_spawn_elite` or the stall guard.

## 4. What the engine does not change

Written down so it is not touched by accident: the skirmish's round, the die, reach, keywords,
statuses, the injury, heat's bite, cooling, the reinforcement step and the waiting rest
(D19), the 2×4 formation and its placement rule for compositions without a layout, the boss's
seal and the stall guard, the elites and the wanderers, the menace, salvage and Anathema, the
campaign's turns and cities, the quick campaign's flow, the hunters' every rule, the map's
shapes and the crossing guarantee, water's price and the ways of moving, the carry, the
Dingo's two actions, every passive, every piece of content not named in section 6.

## 5. The bots and the runners

- **The defence bot** replaces `BattleBot`'s `as_one` rule and the turtle and detaching
  personas (`turtle`, `detach`, `TURTLE_REACH`, `DETACH_REACH`, `detachments`, their flags and
  report lines in `tools/campaign_run.gd`). The rule, plain and nothing cleverer: hunters'
  catches first, as today. Then each machine with an action, in roster order: among the packs
  its move can bring it adjacent to this turn, order it onto the one that reaches the wall
  soonest (a pack on the apron first, then by the turns its planned walk needs to reach the
  apron, from `plan_walks`), ties by the larger `squad`, then by the nearer; machines ordered
  onto the same pack fight together; a machine with no pack in reach moves toward the pack that
  reaches the wall soonest. A machine never fights the sealed boss; the unsealed boss is a pack
  like any other to this rule. No reading of the fight's odds, no holding back.
- **The pressure ratio**, a measure in `BattleBot` reported by the campaign runner: at the
  start of each player turn, `demand` is the sum of `squad` over the packs on the apron and the
  packs whose planned walk ends on the apron this coming enemy turn; the ratio is `demand /
  max(1, machines alive)`. With a formation a three and a patrol a one, a wave of one formation
  and one patrol reads exactly 1.0, the 3-1 posture; two formations read 1.5, a split short.
  Report per run: the mean over turns, the share of turns above 1.0, and the mean of each
  battle's maximum.
- **The campaign runner** (`docs/campaign_run.md`) also reports: fights a battle by the pack's
  `squad` and by the machines in them (the fight-size table reworked to those two axes); gate
  damage a battle (exists); peaks a battle and packs sent (exist); the wall's length and the
  depth in its header; stalemate fights (no HP, hull or shield changed for ten rounds running,
  the fight bot's `MAX_ROUNDS` cap of 60 staying as the cap) counted apart from stalled fights.
  It takes `--shape <kind>` to fix the map's shape (add it if absent); Phase 1's reads use
  `--shape steppe`.
- **The promise read** in `tools/balance.gd`: `--packs promise` runs, for every composition of
  every domain at each tier it names, the runner's default four-machine team cut to the
  composition's `squad` (its first N machines, in the team's order) against it, and beside it
  the same team cut to N − 1 (short) and to N + 1 (over, where N is under 4), at the seeds
  given, reporting the win rate, the rounds and the hull lost per cell. A direction, read
  beside the other cells, never a gate; the band between short, intended and over is what the
  refit (section 9) will be held to.

## 6. Content: the composition schema, and nothing else

`content/factions.json`, the `compositions` list, with `_about` rewritten to say exactly this
and `sim/content_db.gd`'s validator holding it (the checks at lines 2146 to 2215 extended):

- `squad` (optional): 1, 2, 3 or 4, the machines the composition is intended for; when absent
  the engine reads a patrol as 1, a formation as 3, an elite as 4 and an escort as 4 (Ryan, 6
  November). No composition in content gets a value in this build; the formation pass does,
  in chat.
- `layout` (optional): `{"front": [c, c, c, c], "back": [c, c, c, c]}`, left to right as the
  formation stands; each cell `null` (empty), a foe id, or a list of foe ids from which the
  seed draws one. A size-2 foe's id stands in a front cell and its back cell is `null` (the
  validator refuses anything else). Every foe named in a layout must be a member of
  `members`, and for each foe the count of cells that can name it must not exceed its strength
  (the validator refuses otherwise). Members beyond what the layout places wait as
  reinforcements do today (D19). When `layout` is absent, placement is today's rule (heaviest
  hitters first from the left).
- `lead` (optional): a foe id among the members, the pack's sprite and behaviour; when absent
  the first member leads, as today.
- The draw for a list cell: deterministic and from no new stream, `absi(hash(Vector3i(seed,
  k, cell))) % n`, where `seed` is the battle's, `k` the composition's index in the cycle or its
  placement order, `cell` 0 to 7 front then back; judged as the pack is dealt (placed or
  emerged), so the pack's members on the map already show the draw; saved with the pack as its
  members are.
- `Skirmish` places a composition with a layout by its cells (a null cell empty), the rest of
  the members waiting; `Battle._build_skirmish` and `ContentDB.foes_for` pass the layout
  through. A synthetic composition with a layout and a variant cell is tested for placement, for
  the draw's determinism across a save and load, and for the validator's refusals.
- No composition in content is changed. No foe, chassis, component or module number is changed.
  `recharge_field` is removed from `content/chassis.json` (3.6); that is the only content edit
  outside `_about` texts.

## 7. Phase 2: the view

On Ryan's word only, after the hand-back. Built in this order, each judged on the phone by him
with a switch where the README's pattern applies:

1. **The orientation setting** (D15): a setting with two values, the wall at the left with the
   rift at the right (flat-top hexes, the wall a straight column, the scroll down the wall),
   and the wall at the bottom with the rift at the top (today's pointy-top, the scroll sideways
   along the wall). One field, one sim; the view transforms. The default is the wall at the
   left (placeholder: his call). `sim/hex.gd` gains the flat-top pixel conversion beside the
   pointy-top one; every overlay in `game/battle/battle_map_view.gd`, `move_path.gd`,
   `painted_map.gd`, `map_3d.gd` and the shaders go through one transform; the models are
   turned the way they move in either; the city stands behind the wall in either. The 3D
   reconstruction's tilt recedes toward the rift in the bottom view and along the wall in the
   left view: build it so and name it in the hand-back as the one look he must judge. A wall
   longer than a screen wants tags at the screen's edge for packs, tears and machines off
   screen, in both views: the existing tag pattern (`_draw_tags`, the hunter's plate).
2. **The marks that go**: every pack's ring, the selected machine's band and the attack-range
   band (`_field_rings`, `_target_rings`, `_ring_outline`, the band in `_draw`), and the
   joining pack's tint. A pack tapped shows its walk and its hold; a selected machine shows its
   move and the packs it could be ordered onto, bracketed, as today.
3. **The threat rating** (D14): one to four machine pips under the pack's count badge, the
   `squad` value; structure, never hue (Ryan is colourblind): a filled pip a machine; the hold's
   "A fight for N" beside them. The pips are the one hint on the map.
4. **The fight queue**: an action pip on each machine, lit until it fights; the order lines
   numbered in the order given; the one button reading `ENGAGE 1 OF N` while N orders wait;
   after a fight the map returns with the remaining orders intact and the button pulsing. No
   dialog on a split; nothing says "stay grouped".
5. **The withdraw button** gone from the skirmish screen; the map's shield gauge on a machine's
   readout gone (the shield is the fight's; the hull gauge stays); the shield regen stat on the
   codex only when not zero.
6. `tools/screenshot.gd`'s poses and the screen tests follow.

## 8. The records, in the same commits as the code

- **The bible** (`docs/design-bible.html`), each a row with the reason, Ryan's words from
  section 2 verbatim with the date, and the exit; rewritten in place, never appended beside the
  old truth (CLAUDE.md): the grid row (section 4: the field wide along the wall and shallow,
  both the ramp's, the finale lever folded in, the orientation a view setting); the whole-wall
  row (the segment and its variance); the fights-picked row (one pack is one fight; hunters
  keep the catch; the rings retired, the form that failed and the test it failed: Ryan's play
  of 5 November, "I was able to circumvent completely"); the four-machines row (the splits
  priced by the pack's size); the pack row (the composition's layout, lead, squad and variants;
  "packs keeping their damage" moot with no withdrawal); the three-clocks, pacing, tears and
  stall rows (the tide; the thresholds from the tide; the timer after the Rupture; the field
  thin at the start; the stall priced by the tide and the fight's own end); the "Rift Pressure
  feeds the boss fight" row (unchanged in rule, its reason restated); the damage-sticks row
  (the race's half gone); the skirmish shape's withdrawal row (there is no withdrawal, Ryan's
  words, the price of a bad commitment the wreck, the two guards: the threat rating and every
  formation able to end a fight, the second content's); the shield row (full at every fight's
  start, the field rate gone); the heat row ("never carried between fights" now the shield's
  rule too); the triangle row (the shield regen stat as the slot, zero everywhere, the heat
  brief's cooling question still Ryan's); the rerolls row (done); section 12: the open items of
  section 9 added in the form the section uses, and the battle-withdrawal Open row left as it
  is. Republish the page after the rows land: the status's procedure (a subagent reads the live
  page, merges onto it with `tools/pages/bible_merge.py`, reads the whole file, publishes by
  URL), and run `python3 tools/pages/bible_tables.py` after the vocabulary changes.
- **`docs/rules.md`**, in place: The game (a battle is the defence of a wall); Machines (the
  chassis list: field recharge out, shield regen in); the round's step 1 (shield regen with the
  cooling); the scales row (field recharge out; shield regen 0 to 2 as the magnitude, none
  set); the Skirmish's Withdrawal part replaced by "There is no withdrawal: a fight ends in the
  pack's fall or the machines' wreck"; Shields (full at every fight's start; nothing returns on
  the map); the battlefield part whole: the field's size from the ramp, the setup (the opening),
  the turn (no recharge), the fight (one pack, adjacency, no joining, the queue), packs (the
  goal segment; the squad on the hold), pushers, Rift Pressure (the beat, the opening pressure,
  the timer after the Rupture), the seam, the thresholds; the campaign and quick campaign lines
  on field recharge; Content conventions (the composition fields); Known gaps unchanged.
- **`content/vocabulary.json`** (then `tools/export_vocabulary.gd` regenerates
  `docs/vocabulary.md`): `shield` (full at every fight's start; nothing returns out of fights;
  the "never refills for free" sentence gone), `withdraw` removed, `contact` (one pack is the
  fight; a machine adjacent fights; nothing joins), `engagement_zone` (a hunter's reach alone,
  two at least; no pack joins by it), `caught` (a fight to its end), `patrol` and `formation`
  (the squad they are intended for, shown on the map), `pack` (its squad on the hold; its
  segment), `rift_pressure` (the beat's numbers), `rupture_meter` (the thresholds from the field
  and the first waves), `tear` and `seam` (the rows at the new depth), `gate` (the segment), and
  `out_of_combat` (the trigger with no shield meaning). Names carry their marks; no term says
  "face".
- **`docs/status.md`**: the branch, the tests' count, what is built and what waits, "Next, in
  order" with Phase 2 after Ryan's word; **`docs/todo.md`**: the open items of section 9 that
  are tasks, one line each, ticked lines pruned; the proposal file stays until its decisions
  are rows and content, then retires.

## 9. Open: not built, not worked around

Listed so the hand-back repeats them and nobody fills them.

1. Reinforcement inside a fight: cut, or kept (Claude's lean to cut; Ryan's call).
2. Carries: whether the roster wants two or three machines that ramp inside a fight, and their
   shapes (the charge that is a lock, the siege mode, the capacitor); not before the formation
   pass.
3. Map loot: whether, and as what (bait swallowed by the seam; a loot-runner pack).
4. The Fracture beyond today's: the shell, or a weakened boss, or picks; today's Fractures
   stand until he picks.
5. The map's shapes relaid for a shallow field, and the authored sectors: a content proposal in
   chat first.
6. The hex size floor against the depth, on the phone.
7. The views' default and the 3D tilt in the left view, on the phone.
8. The numbers: the wall's length and the depth, the beat, the opening rows and the opening
   pressure, the spread, the attack range, the timer after the Rupture, the thresholds' base;
   each a placeholder here, each moved only on his word after the reads. The default squad by
   size is his (a patrol 1, a formation 3, an elite and an escort 4) and is not a placeholder;
   an elite must then earn its four, which is the elites' numbers item already his (the
   to-do).
9. Every foe's blow, every chassis's shield and the shield regen values: the refit against the
   new shape is his call after the reads (the proposal's section 4.2 tests), and the stock pass's
   loops are not run in this build.
10. The formation content: layouts, leads, squads and variants per domain, proposed in chat.
11. The elites' map effects, city defences and the commander layer: the to-do's and section
    8's, untouched.
12. The Immelmann Booster's price and the Mandrake's Scream at two rerolls: the to-do's.
13. The campaign runner's player beyond the defence rule: the to-do names a change of Ryan's
    own; the defence rule here is the floor the reads need and may be superseded by his.

## 10. The hand-back

One message, and the same in `docs/status.md`'s branch line and `docs/measurements.md`'s dated
entry (every run a decision cites goes there), holding:

- The reads, each at 40 runs of the campaign runner on steppe and at 30 seeds of the balance
  runner, directions and called so: the pressure ratio (mean, share above 1, the battles'
  maxima); fights a battle by squad and by machines in them; gate damage a battle; peaks and
  packs sent; Fractures reached and the Rupture's turn; stalemate and stalled fights; the
  promise read's cells; the map survey at 20×12.
- The text print of each map shape at 20×12 (as the proposal's section 3 did at 24×12).
- The placeholders table: every number marked placeholder, its value, the file and the line.
- The list of section 9, repeated, with anything the build found that belongs on it.
- What each test file changed and the test count.
- The bible's page version after the republish, and the rows written.
- Nothing proposed, nothing recommended beyond what the reads say in bands; the next step is
  Ryan's marks, then Phase 2 on his word.

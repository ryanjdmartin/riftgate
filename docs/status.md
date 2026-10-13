# Status

How things stand, for the next session, and the order of work. Facts and the state as left;
history lives in git. The rules are `docs/rules.md`; the why and the questions only Ryan can
settle are the bible (`docs/design-bible.html`, its first row first); the tasks are
`docs/todo.md`; every run a decision cites is `docs/measurements.md`; the layout, every
document's job and every command are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row, this file and `docs/todo.md`. If a
  chat and a file disagree, the chat is newer.
- Sessions run in parallel on this repo: `git status` first, stage by path, diff a shared file
  before staging it, never a bare `git add -A`, never kill a bare `godot --path .`. Local main
  and `origin/main` diverge for a day at a time; merge `origin/main` into local main before a
  records pass, and expect the bible's live page to have moved (read it, merge, republish).
- Tests: 443 tests, 19,645 checks, green on main (13 October, evening). A cloud session fetches
  Godot 4.7's Linux build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots, and builds models
  with `BPY_PYTHON` set to a python3.11 venv holding `bpy==5.0.1`. Its first `--import`
  rewrites four Prairie Dog textures; restore them (`git checkout -- art/models/prairie_dog_*`)
  rather than commit them.

## Branches

- `main` holds everything decided and built to 13 October, including all of
  `claude/focused-ritchie-omn8i5`, `ccr-baf790be-gootfd` and `claude/ws-chassis-designs-wssq2u`
  (merged and safe to delete), the Kestrel canvas from `ccr-1a6d0a75-y2oqy8` (its file brought
  over; safe to delete) and the Minerva branch's one decision (its four designs abandoned, Ryan,
  13 October; the branch carries nothing else and is safe to delete). Pushed to `origin/main`
  on 13 October, evening. New work starts from main.
- `ccr-550650c0-g0kcbg`, the Aphelion session, stopped on Ryan's word (13 October, evening):
  its proposal `docs/aphelion_chassis_proposal.md` is on main and its bible rows were carried
  in; its other document changes described a pre-refactor state and were not taken. Safe to
  delete. A local sprite session is in flight in this folder (uncommitted `art/foes/`,
  `content/foes.json`, `tools/foeforge` and document hunks): leave them unstaged.
- The chassis proposals for the batch evaluation: Wainwright & Sutler's on main
  (`docs/ws_chassis_proposal.md`, with its look tests in `tools/lowforge/looks/` and
  `docs/looks/`), the Arsenal's on main (`docs/arsenal_proposal.md`), Kestrel's five airframes as
  a canvas on main (`docs/canvas/kestrel-airframes.html`, for Ryan's pick), Aphelion's on main
  (`docs/aphelion_chassis_proposal.md`, two rounds of proposals and their holes, no bench of
  ideas set aside yet), Minerva's abandoned.

## The game as left (13 October, evening)

- Built and tested: the battle (the round, orders, fights by ring and range, hunters, five map
  types, Rift Pressure without escalation, the boss after its reveal); the skirmish as
  `docs/rules.md` states it, Rally included (Kindled at its move's value, live from the next
  round); the campaign's rules headless only (`sim/campaign.gd`, no screens); the balance
  runner (`tools/balance.gd`: `--rows`, `--module`, `--bump`, `--nopassive`, `--set`,
  `--trace`), the campaign runner and the map survey; every ally model by lowforge with acts
  and gaits; the foe art; six tracks, the effects and Jenny's lines.
- Content: five makers, 13 chassis, 54 components (12 locked, 4 unstocked, among them the
  shelved Gravity Knuckles at tier three), 16 modules, four domains with 18 wildlife and bosses
  and 8 heroes; 8 foe moves still `planned`. Every number is a placeholder; any whole number
  may be used (the scales are magnitudes), move alone in steps of 5. The content still carries
  the old kinetic-and-energy split (every rolled weapon cold, every flat one hot), which the
  stock pass re-prices by niche (the bible's rolled-or-flat row, Ryan, 13 October).
- Decided on 13 October, from Ryan's clarifications: the whole roster goes to one front and
  the fronts left alone bleed (section 3); a battle is played to its end, no withdrawal from a
  battle (section 4); five to ten meaningful skirmishes then the boss, never twenty two-round
  fights (section 4's pacing row); neither rolled nor flat owns heat (section 5); stuns are
  budgeted and a depth-and-breadth session measures the roster against itself (section 5); the
  roster is widened so compositions can be read (section 11).
- The records, after Ryan's review of 13 October: the bible's first row says what a Decided
  row may be, what a Lean is and what a "never" must carry; the measurements live in
  `docs/measurements.md`; section 12 holds only the questions; this file holds the order of
  work; the to-do holds the tasks; the keyword line-up and the enemy roster proposal are
  retired (git has them), their open items in section 12 and their seeds in the bible's rows.
- Debug switches added on 12 and 13 October: `RIFTGATE_RAGE_DEBUG=1` (the rage's roll again);
  screenshot poses `rage` and `heat` (`tools/screenshot.gd`).
- Foe art: every foe and hero is cut from Ryan's picks at 72x96 (massive 96x144, chibis 36x48).
  On 13 October every wildlife foe but the Needler was re-picked from its battle-pose takes and
  cut, with the Lancer's and the Summoner's chibis; his note on each pick is in
  `tools/foeforge/picks/picks.json`. The same day the edit model tried a fix for each note
  (`forge.py fix`), the Treant and the Needler got new takes, and the heroes a diversity pass:
  all on the picker for Ryan. The cutter gained `--holes N` (a size floor), `--holes-tol` and
  `--glow`. The old sheet still makes the 16x16 map tokens.
- Known gaps: Jenny's foe-down lines are keyed by the retired families.

## Measured, 13 October

- `docs/campaign_run.md` on the four domains and today's rules: the plain player wins 3 of 40
  runs (29 of 40 on 9 October, before the domains), 6% of battles, 93% wiped, every city but the
  capital falling by turn 4 to 9. Not Rally: the commit before the fix gave 0 of 40. The bot
  takes every ready machine to one front, as intended, but fights inside a battle are mostly
  one machine alone (1,157 of 1,747), wrecks sit out with no spares, and the bot never
  withdraws from a skirmish. A lone machine wins 64% against a pack and 37% against two; two
  together win 92%.
- `docs/balance.md` at 200 seeds: every team row keeps its 9 October band; alone the machines
  move a few points, the Nemesis most (greedy 61 to 76); the cells that moved follow the rules
  (the Peak open to nearly everyone and closed to the Goshawk, the bosses harder for the heavy
  machines, the Marsh's formation a decision for the Armadillo and a wall for the Boar); flat
  weapons pay about twice the heat per point that rolled ones do. The bands of both are in
  `docs/measurements.md`.

## Decided, not built

- The stock pass: tags on every component (the working set Ballistic, Missile, Beam, Plasma,
  Flame, Arc, Blade, Melee), the shared basic kit at tier zero (every basic's blueprint owned
  from a run's start), the old close weapons brought to Direct's band, the Pinion Driver locked
  on the Sparrowhawk, the Baboon free to stock a shield, every tier-one chassis on basics beside
  its locked piece, each component's tier in its entry and every chassis stocking only below
  its own tier (the Arsenal's tier twos excepted until Ryan closes the hole), a bought chassis
  bringing copies of its stock and never the blueprints, heat re-priced by niche.
- Danger close retires and area belongs to keywords on any reach: Splash folds into Spread and
  Penetrate, an explosive carries both (the Artillery Rangefinder needs a new rule).
- A dispel keyword for the foes' buffs (its name, carriers and numbers open).

## Next, in order

1. Ryan reads the bible's first row and answers section 12's questions as they come up, the
   stock rule's hole, the foe roster after his picks and the mechanic budgets first; and plays
   the 10 to 13 October builds (the to-do's Ryan list).
2. The campaign's fall read against the two reports with a bot that withdraws and bunches (the
   lone-machine fights first, since the team rows did not move), under the intent recorded on
   13 October: the whole roster to one front, five to ten meaningful skirmishes a battle; then
   the runner's module rows.
3. The foes' fresh start, a session of its own: compositions with a front and a back spawned by
   the rift, upstream of the area keywords, the reach premium and any chassis that reads a rank.
4. The batch evaluation of the proposed chassis in a fresh session, Aphelion's written down
   first, and the depth-and-breadth session beside it.
5. The content questions settled, then the stock pass, then modules as soft-synergy pairs.
6. The rest in the roadmap's standing order: Ryan's text (codex and flavour, the Sponsorship
   notices, the mitigation discussion); the domains' engine (the planned moves, the party dealt
   from the benches, three bosses a domain); the pacing session; battery; audio; the screens (a
   prototype hangar, the mission map, the draft: section 12 asks whether they come before item
   4); art; the commander layer after a balance baseline; the economy pass, then the hangar's
   verbs, procurement and loot; onboarding before a phone leaves the desk.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them by
URL (read first). Databases are reachable only from the personal account. A page's link goes
into this file in the same commit as its first publish; the procedures are in `README.md`.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. Live: v0.145 (13 October, evening), the
  committed file as it stands on main, the Aphelion session's rows carried in.
  Before republishing, read the live page; if another session moved it, publish a three-way
  merge onto it.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map. Republished 13 October from main's content.
  Its database (Ryan's saved edits, collection `edits`; name candidates, `candidates`) opens
  only from the personal account and was not read on 13 October.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor); picks and notes in collection `picks`.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).
- The Kestrel airframe proposals, work account, private: https://claude.ai/artifact/1Snudf4fmTUw4hkr1ckMfy
  (`docs/canvas/kestrel-airframes.html`; its SVG sketches are inline, so edit the file in place).

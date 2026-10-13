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
  roster is widened so compositions can be read (section 11). Later the same day: four machines
  moving as one, a detachment a decision priced by time (section 4); the Rupture meter and
  Anathema fill by the threat-weighted tally, the Favour dock the gate's price (section 3);
  offers one of each kind, a chassis on the shelf, host-maker offers shaping the roster
  (section 10); twelve to sixteen battles recommended; the battle withdrawal reopened (section
  4, Claude's walk-out proposal, which Ryan finds thematic and decides later); heat bites where
  it is carried, a cold build pays elsewhere, and a cool weapon is soft cooling, heat builds are a
  spectrum between passive cooling and venting, and the runner reads heat spikes, forced choices
  and the damage forgone to heat rather than counting vents (section 5); cooldowns in a skirmish reopened, a
  decision made for Ryan by a session (section 8); the Arsenal's tier-one components exist
  (section 10); the map stays nine wide; the screens third in the order; Rift Pressure no longer
  ticks per round fought, only on the map (section 4, built); `docs/mechanic_budgets.md` the brief for the roster session.
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

- `docs/campaign_run.md` on the four domains and today's rules: the plain player wins 12 of 40
  runs with the in-fight Rift Pressure tick gone (3 of 40 with it that morning; 29 of 40 on 9
  October, before the domains), 24% of battles, 75% wiped, 3.5 cities fallen a run. Not Rally:
  the commit before the fix gave 0 of 40 with the tick. The bot
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
  its own tier (the Arsenal's tier-one components exist for its tier twos to stock), a bought
  chassis bringing copies of its stock and never the blueprints, heat re-priced by niche so
  that it bites (section 5's heat row: a machine firing every round overheats by its third).
- Danger close retires and area belongs to keywords on any reach: Splash folds into Spread and
  Penetrate, an explosive carries both (the Artillery Rangefinder needs a new rule).
- A dispel keyword for the foes' buffs (its name, carriers and numbers open).

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list).

1. **The batch evaluation with the depth-and-breadth session, one session.** Reads the bible's
   first row, section 5's stun row, `docs/mechanic_budgets.md` (the brief) and the four
   proposals on main, Aphelion's read as a list of ideas in a vacuum (Ryan: that session went
   off the rails) (`docs/arsenal_proposal.md`, `docs/ws_chassis_proposal.md`,
   `docs/aphelion_chassis_proposal.md`, `docs/canvas/kestrel-airframes.html`). Measures every
   chassis's solo value beside its team value (`tools/balance.gd --team`) and compositions at a
   fixed four; folds in the Honey Badger's identity, the Armadillo's Faraday Hull and the cars'
   missing solo niche; re-reads each proposal's set-aside lists under the first row. Ends with
   the go and the build order, and the rules it settled as rows.
2. **The foes' fresh start, the fight-size spectrum and the Rupture meter.** Reads section 4's
   pacing and four-machines rows, section 9, section 12's foe questions and
   `docs/campaign_run.md`. Builds compositions with a front and a back spawned by the rift, small
   packs for detachments and formations for the body, the boss sealed by the threat-weighted
   meter and fought with its formation, the withdrawing persona on the campaign bot; then reruns
   both reports and measures the fights a team fights together.
3. **The screens** (Ryan, 13 October: third, so the first thing built after the battle has its
   shape is a run he can play): a prototype hangar, the mission map and the draft; every build
   order the roster session hands down lands in a game being played.
4. **The stock pass**, once Ryan answers section 12's content questions: tags, the basic kit,
   heat re-priced by niche so that it bites where carried and a cold build pays elsewhere, the
   area keywords on the explosives.
5. **The economy pass** (`docs/economy_pass.md`): the runner's spending policy, then every price
   and yield with the offers one of each kind, a chassis on the shelf, the Favour dock as the
   gate's price, twelve to sixteen battles.
6. The rest in the roadmap's standing order: Ryan's text; the domains' engine (the planned
   moves, the party dealt from the benches, three bosses a domain); the pacing session's
   remaining pieces; battery; audio; art; the commander layer after a balance baseline;
   onboarding before a phone leaves the desk.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them by
URL (read first). Databases are reachable only from the personal account. A page's link goes
into this file in the same commit as its first publish; the procedures are in `README.md`.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. Live: v0.153 (13 October, evening), the
  committed file as it stands on main, the Aphelion session's rows carried in.
  Before republishing, read the live page; if another session moved it, publish a three-way
  merge onto it.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map. Republished 13 October from main's content.
  Its database (Ryan's saved edits, collection `edits`; name candidates, `candidates`) opens
  only from the personal account and was not read on 13 October.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor); picks and notes in collection `picks`, readable from a personal-account session.
  It holds the 13 October round: the fixes, the Treant's and the Needler's takes, the heroes.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).
- The Kestrel airframe proposals, work account, private: https://claude.ai/artifact/1Snudf4fmTUw4hkr1ckMfy
  (`docs/canvas/kestrel-airframes.html`; its SVG sketches are inline, so edit the file in place).

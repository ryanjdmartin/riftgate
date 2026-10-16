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
- Tests: 465 tests, 19,988 checks, green on `claude/adoring-planck-q8t63w` (15 October, main
  merged in, the reroll fix and the entries' places); main's last run was 462 tests, 19,765
  checks.
  A cloud session fetches
  Godot 4.7's Linux build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots, and builds models
  with `BPY_PYTHON` set to a python3.11 venv holding `bpy==5.0.1`. Its first `--import`
  rewrites four Prairie Dog textures; restore them (`git checkout -- art/models/prairie_dog_*`)
  rather than commit them.

## Branches

- `claude/adoring-planck-q8t63w` (15 October, the Minerva design session from the briefs: the
  Armadillo, the Honey Badger, the echidna, the H-tank and the battlecruiser, Ryan's calls
  recorded round by round in their briefs, nothing of the designs built; and the reroll fix
  and the entries' places, built, below): not merged; main merged into it on 15 October.
- `claude/pensive-albattani-q73ibs` (15 October, the small-work pass: the Oblation Mantle, the
  harpoon's Shock, a suppressed foe's hold readout, boss apart from size, the foe's save trip,
  below) merged into main on 15 October (Ryan: "update and merge into main"): safe to delete.
- `ccr-777fd46a-32dw2m` (the roster analysis, Ryan's go on it, the design-session briefs and
  the records' cleanup) merged into main on 15 October, with `ccr-3d9861dc-mp0v3w` (the
  analysis's brief) beneath it: both safe to delete.
- `main` holds everything decided and built to 13 October, including all of
  `claude/focused-ritchie-omn8i5`, `ccr-baf790be-gootfd` and `claude/ws-chassis-designs-wssq2u`
  (merged and safe to delete); `ccr-1a6d0a75-y2oqy8` (Kestrel) and the Minerva branch are
  struck and safe to delete. Pushed to `origin/main` on 13 October, evening. New work starts
  from main.
- `ccr-550650c0-g0kcbg`, the Aphelion session, stopped on Ryan's word (13 October, evening):
  its proposal reached main and its bible rows were carried in (the proposal folded into the
  briefs and retired on 15 October); its other document changes described a pre-refactor state and were not taken. Safe to
  delete. The local sprite session committed its round five on main (`53a1f26`) and may still
  be in flight in this folder: anything new and uncommitted under `art/foes/`, `content/foes.json`
  or `tools/foeforge` is its, left unstaged.
- The chassis proposals: Wainwright & Sutler's, the Arsenal's and Aphelion's reached main as
  proposal files and on 15 October were folded into the design-session briefs (`docs/briefs/`,
  each the design's one home) and retired, the gunship's stand-in table to
  `docs/measurements.md`; the multi-rotor's look tests stay in `tools/lowforge/looks/` and
  `docs/looks/`. Minerva's and Kestrel's earlier proposals are struck (Ryan, 13 and 14
  October): each maker's next chassis start fresh from the latest rules, with nothing of the
  struck designs in the records. A first pass at the analysis on 14 October drifted into
  measuring stand-ins and rating on performance and was retired to git (the branch's history).
  The analysis itself is `docs/roster_analysis.md` (14 October, from Ryan's brief of that day
  in `docs/mechanic_budgets.md`, retired with the proposals; published, the link under Pages),
  background since the go, which is recorded in the bible, the briefs, the to-do and
  `docs/economy_pass.md`.

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
  and the damage forgone to heat rather than counting vents (section 5); cooldowns in a skirmish reopened
  (decided 14 October: a printed property on specific pieces, section 8); the Arsenal's tier-one components exist
  (section 10); the map stays nine wide; the screens third in the order; Rift Pressure no longer
  ticks per round fought, only on the map (section 4, built); the brief for the roster session.
- The records, after Ryan's review of 13 October: the bible's first row says what a Decided
  row may be, what a Lean is and what a "never" must carry; the measurements live in
  `docs/measurements.md`; section 12 holds only the questions; this file holds the order of
  work; the to-do holds the tasks; the keyword line-up and the enemy roster proposal are
  retired (git has them), their open items in section 12 and their seeds in the bible's rows.
- Debug switches added on 12 and 13 October: `RIFTGATE_RAGE_DEBUG=1` (the rage's roll again);
  screenshot poses `rage` and `heat` (`tools/screenshot.gd`).
- Foe art: every foe and hero is cut from Ryan's picks at 72x96 (massive 96x144, chibis 36x48);
  fourteen rounds on the phone picker, 13 to 15 October, closed every note he wrote on the
  wildlife and the chibis, and his cutting batch (pockets of pure white now key by default,
  the chibis cut at one body scale with every weapon inside the frame); each pick's source, cut options and his notes are in
  `tools/foeforge/picks/picks.json`. What worked: a flaw tried through the edit model once
  or twice, then image to image from the pick he liked (`forge.py generate --image`), never
  from the last pass (it drifts) and never a PIL hand edit on a figure (three failed his bar);
  one set per sprite per round. The heroes' boss register is picked and recorded, not in the
  game (the promoted forms are not entries); staff fingers on the White and Black Mage and
  the Martial Artist's fist are hand jobs. The Summoner carries deep violet rune circles and
  Pyroclasm. Next for the foes: the roster questions in section 12 (the Bomb, the marked goblin and revenant candidates), the head sizes if Ryan wants them level.
- Built 15 October: a foe's blow at every machine (`all`: each strike on each live machine,
  arrows to every machine, the plaque naming it once, the bot counting it on each), carried by
  the four storms since the foe kit refresh (Root Storm, Quake, Bone Storm, Cleave); and the
  boss mechanics, each inside the skirmish: a countdown (the Lancer's Jump runs on it), a boss
  in parts (a core Guarded while its parts stand, parts regrowing), a last act (a death blow
  the moment a foe falls), foes helping foes (a cure and a protect; the White Mage carries
  Dia, Cure and Holy, Ryan's three, its Protect parked). The Summoner's summons are its moves,
  full Norse (Ryan): Skaði's frostbite, Surtr's Pyroclasm, Fáfnir the promoted form's; the Golem no longer called. The
  boss art round is on the picker: sets from `tools/foeforge/drafts.json` (art ahead of
  content), the Fallen Weapon drawn as hammer and as axe, the third round Skaði, Fáfnir and Floraison. The bosses' slate and Ryan's marks
  are `docs/bosses_proposal.md`.
- Built later on 15 October (the small-work pass): the Oblation Ward is the Oblation Mantle
  (its name; the id stays, as the Bone Wyvern's did); the Megataser Harpoon carries Shock in
  place of Suppress; a suppressed foe's hold readout names no blow and no target (its glyph,
  arrow and forecast already cleared, the Suppressed chip leading its row); a boss is the
  content's word whatever its size (`Foe.boss` from a faction's `boss`, the plaque reading it,
  the validator no longer asking a boss to be massive but refusing a hero as one), the boss
  pack `Unit.is_boss` (a save that says `elite` still loads), `RIFTGATE_BOSS=1` in place of
  `RIFTGATE_ELITE=1`; and a fight resumed from a save keeps a foe's boss, a Gel's split and a
  foe gone whole (all three were lost on the trip).
- Built 15 October, on the Minerva branch (Ryan's call in that session): every reroll, the
  team's and Rapid's free one, skips only the entry showing, so a copy of it may come up and
  copies of one Rapid component chain. Skipping copies too was abusable: a die of one key entry
  and copies of one filler sent every reroll from a filler onto the key. The machines with
  copies on their dice (the Baboon's Inducers, the Boar's Slugthrowers, the Nemesis's fists,
  the Ammit's talons) reroll onto a copy now and then: an A/B on those four, greedy, 100 seeds,
  moved no row mean a point (`docs/measurements.md`, 15 October), since their copies are the
  entries the bot keeps; the Ammit's Talons rose from 46% of its spends to 51%. Open with it:
  a Rapid piece with no cooldown (the Armadillo's lure, cantrips) needs a limit that keeps its
  chain finite: Ryan's rule (15 October) is that Rapid always carries one, a cooldown, heat or
  Volatile (the bible's Rapid row; the validator's check waits on the cooldown property).
- Built 15 October, on the Minerva branch (Ryan: "Roman numerals in the corner? ... grey on
  the black background"): every die entry shows its place on the die, from I, as a grey Roman
  numeral in the quotes' condensed italic, top left on the die and down the hold and the codex
  (a gutter left of each tile), counted fixed components first. It shows a reroll onto a copy,
  which hardpoint holds what, and the revolver's order. The codex's two narrow columns now
  give a long description a second line rather than clipping it. Judged from screenshots at
  the phone's layout; Ryan's read on the glass is owed.
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
- The go on the roster analysis, 14 and 15 October (rows and `docs/rules.md` lines): a shield
  absorbs its number and the excess passes to the hull, a breach ignores the shield, an injury
  counts what reaches the hull; Barrier and Ward; cooldowns a printed property on specific
  pieces (Rapid as a cooldown of one); Misharu's payoff Penance; the Votive Screen's name;
  Kestrel's strafer and bomber (the harpoon's Shock, the Oblation Mantle and the cleared
  intent built 15 October). The engine work is on the to-do. The budgets (15 October): adding
  hard control always carefully considered with other options explored first, no caps; a new
  chassis earns its place by a new read, product or price; a passive aims to be fed by and to
  feed other makers' pieces; a tier one shows its identity with basics alone.

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list).

1. **The design sessions, from the briefs** (`docs/briefs/`, 15 October). Ryan's go on the
   roster analysis decided what "Decided, not built" lists; every proposal, direction and
   rework it left open (the Onryō, the Armadillo as a form changer at tier one, the Baboon at
   tier two, the Gundam, the jellyfish, Mastema, the funnel-web and the rest) is a brief, the
   design's one home, with what Ryan said and what is open, and the README gives the shared
   context, the tiers as proposed, the budgets (decided 15 October), the roster holes and an order. Each
   decision becomes a row; the analysis page retires to git once the last brief that cites it
   lands.
2. **The stock pass**, once Ryan answers section 12's content questions: tags, the basic kit,
   heat re-priced by niche so that it bites where carried and a cold build pays elsewhere, the
   area keywords on the explosives.
3. **Balancing for real** (Ryan, 14 October: only once the go is hashed out and the stock
   pass is in can the units be balanced for real). The runner's rows on the roster as the
   stock pass leaves it, the third-machine read and the fours again, prices and tier ladders
   (the to-do's engine line), the heat report, and Ryan's play deciding feel.
4. **The foes' fresh start, the fight-size spectrum and the Rupture meter.** Reads section 4's
   pacing and four-machines rows, section 9, section 12's foe questions and
   `docs/campaign_run.md`. Builds compositions with a front and a back spawned by the rift, small
   packs for detachments and formations for the body, the boss sealed by the threat-weighted
   meter and fought with its formation, the withdrawing persona on the campaign bot; then reruns
   both reports and measures the fights a team fights together.
5. **The screens** (Ryan, 13 October: early, so the first thing built after the battle has
   its shape is a run he can play; the go, the stock pass and the balancing come first, Ryan,
   14 October): a prototype hangar, the mission map and the draft; every build
   order the roster session hands down lands in a game being played.
6. **The economy pass** (`docs/economy_pass.md`): the runner's spending policy, then every price
   and yield with the offers one of each kind, a chassis on the shelf, the Favour dock as the
   gate's price, twelve to sixteen battles.
7. The rest in the roadmap's standing order: Ryan's text; the domains' engine (the planned
   moves, the party dealt from the benches, three bosses a domain); the pacing session's
   remaining pieces; battery; audio; art; the commander layer after a balance baseline;
   onboarding before a phone leaves the desk.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them by
URL (read first). Databases are reachable only from the personal account. A page's link goes
into this file in the same commit as its first publish; the procedures are in `README.md`.

- The roster analysis: https://claude.ai/artifact/QVLRVD8YXsK8ZUKY3A1vxo, rendered from
  `docs/roster_analysis.md` by `tools/pages/roster_analysis_page.py` and published 14 October,
  republished 15 October with its section 12 cut to a pointer; republish after the page changes, and retire it with the page once the last brief
  that cites it lands.
- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. Live: v0.184 (16 October, another branch's,
  over main's v0.182); main's file v0.185 adds the Priest folded into the White Mage and the
  Martial Artist kept (Ryan, 16 October), unpublished: the next publish reads the live page
  through and merges onto it. The Minerva branch's file (main merged in, 16 October) carries
  v0.185 and its own rows, which the page already has: the rerolls onto a copy, the die
  entry's place, Rapid's limiter and the Wake Diffuser question. Main's file also carries the
  budgets decided, the maker rows pointing at the briefs, the proposal files retired, the
  Faraday Hull's move, the cooldown cap struck, homage by archetype, the small-work pass's three
  rows (the Oblation Mantle, the harpoon's Shock, a boss apart from its size), section 12's
  Numbed question and the boss mechanics (the storms at every machine, the countdown, the boss
  in parts, the last act, foes helping foes), and Ryan's calls of that evening: the Summoner's
  summons full Norse (Skaði, Surtr, Fáfnir), the White Mage's three (Dia, Cure, Holy) and the
  heroes' tropes from beyond Final Fantasy, then of 16 October: balance the series out a
  little, never purge it (the Lancer stays the dragoon, the Warrior the plain fighter, the Thief
  Persona 5's Joker under its plain name). The live page also carries rows from two branches,
  which reach main's file when they merge: `claude/zealous-cori-8xoly7` (its v0.177: the Boar's
  later strikes spilling, Chain's rework in section 12) and `claude/adoring-planck-q8t63w` (its
  v0.181: the die's Roman numerals, a reroll's copies, Rapid's limiter, the Nemesis's roll
  again, the Wake Diffuser's question).
  Before republishing, read the live page; if another session moved it, publish a three-way
  merge onto it.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map. Republished 15 October from main's content:
  only the four content files that had moved since 13 October (chassis, components, foes,
  vocabulary), the page, the models and the renders checked unchanged and kept; again that
  evening with the boss mechanics' foes and vocabulary alone, and with the White Mage's three
  and Skaði. Its database
  (Ryan's saved edits, collection `edits`; name candidates, `candidates`) opens only from the
  personal account; `edits` was empty on 15 October, after the second republish too.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor); picks and notes in collection `picks`, readable from a personal-account session.
  It holds the boss art round (15 October): the first round's six sets that stand (the
  Behemoth, the Cinder Tortoise, the Matador, the Fallen Weapon as hammer and as axe, the
  Reaper, Surtr) and the third (Skaði, Fáfnir, Floraison with its swallow and vines), built by
  `forge.py phone --only --tags bossart bossart3 --keys <the nine sets>`; the second-pass
  misses sit in each set's `set_aside/`.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

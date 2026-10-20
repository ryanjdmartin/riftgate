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
- The desk machine is a Windows PC since 19 October (the Mac went out of reach mid-session):
  `C:\Users\jam82\Desktop\Code\riftgate`, set up that day; the README's Running section says
  what is set up there. What the Mac held outside git is gone but the seventh round's foeforge
  renders, force-added in `fb45141` so the picks can be cut here; foeforge's `generate` and
  `fix` have no machine until a route for the image model is chosen.
- Tests: 485 tests, 20,291 checks, green on main (19 October, on the Windows desk machine as
  it was set up: about a minute there). A cloud session fetches
  Godot 4.7's Linux build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots, and builds models
  with `BPY_PYTHON` set to a python3.11 venv holding `bpy==5.0.1`. Its first `--import`
  rewrites four Prairie Dog textures; restore them (`git checkout -- art/models/prairie_dog_*`)
  rather than commit them.

## Branches

- `claude/adoring-planck-q8t63w` (15 to 18 October, the Minerva design session from the
  briefs: the Armadillo, the Honey Badger, the echidna, the H-tank and the battlecruiser,
  Ryan's calls recorded round by round in their briefs, nothing of the designs built; and the
  reroll fix and the entries' places, built, below): merged into main on 18 October on Ryan's
  word ("make sure main is up to date with any changes you've made"), main merged into it the
  same day, and kept open: the session resumes on it in a fresh context. To resume, read
  `docs/briefs/minerva_armadillo.md` (its open list and sixth round: the numbers, the mark's
  spender, allied cooling, the names), `docs/briefs/minerva_siege_battery.md` (the shells
  proposal, its third round), the to-do's review line under the design sessions (Armoured and
  Overcharged's halving, Ryan's ask for the next session), then the bible's state below.
- `ccr-b6da49d3-4ft738` (18 and 19 October, the Kestrel session resumed from main): Claude's
  proposal for the go on the three Kestrel machines in their briefs, then seven rounds with
  Ryan recorded there (the shield-spender's brief the session's log). As left: the strafer
  proposed for the go; the shield-spender an off-tank package at tier one on Ryan's word (a
  plated shield, the burn with its zap, a lure that regens itself); the bomber happy as a
  whole, heavy proposed and the capital ship; two briefs of their own,
  `kestrel_gun_platform.md` (the capstone, Ryan's shape: every roll of its die grows its
  entries, lock or ride) and `kestrel_sparrowhawk.md` (to tier two: a d3, doubled, flat heat,
  dark two rounds, a locked reset gun whose kill brings every weapon back; hull 30 decided);
  the interceptor (its first weapon each round Rapid) in the README's tiers table, no brief
  yet; Ryan's leans recorded (overlap is fine if the shapes differ, rerolls Kestrel's, a second
  tier-one lure so the Armadillo is no must-pick, Aphelion to need a defensive tier one, the
  mode-shifter to Aphelion's bench). Merged into main on 20 October (Ryan: the action economy's
  direction goes to main before anything else does any work) and kept open for the Kestrel line
  review. The eighth round (19 October) in the platform's brief: no doubled payout, multi-hit
  pieces its payoffs, the three shapes of the gamble with their arithmetic (growth,
  half-strikes, whole stacks), and a Rapid census across the branches (four chassis chase Rapid
  pieces first, in three makers, for five pieces). The ninth round (20 October): Ryan's
  deep-dive ask on the action economy, answered in the briefs README (Rapid sells five wants,
  four carriers ungated, a home for each want other than more Rapid pieces, the commander layer
  among them), and the platform's engine moved from Rapid to rerolls (an own reroll a round,
  the throttle retired, the three-strike shield its lock). Docs only; nothing built, nothing in
  content. Main merged in on 19 October (the Wainwright & Sutler goes). To resume: Ryan's calls
  in the open Kestrel briefs, then on his go the records each brief's "What the session hands
  back" lists. The tenth round (20 October), after the direction reached main: the Kestrel line
  review in `docs/briefs/kestrel_line.md` (each of the eight machines read under the direction,
  the overlap map, the stock holes by kind, the two free slots, the stale records), a brief for
  the interceptor (`kestrel_interceptor.md`: the dive as its lock, the caster-killer niche
  moved there from the Sparrowhawk's rework) and a round in each Kestrel brief (the bomber's
  mark gated and Chain in mines; the Goshawk's cold stock; the Puffin's Diffuser as a combined
  entry; the platform's settlements). Then, on Ryan's word (the review read as bullets, the
  stock pieces placeholders until the stock pass), every Kestrel kit written out whole in its
  brief, "The kit, written out", the stock by kind (the Goshawk's and the Puffin's in the line
  brief). The eleventh round (20 October), Ryan's reading of the kits: landed on his go, the
  Wake Diffuser's Rapid off (a vent that shields; its shield half with the combined entry's
  engine, the to-do; tests green) and his rule that a Rapid vent or shield is never below tier
  three (the bible's Rapid row, section 12's Deflector question in the Diffuser's place, the
  rules); recorded as his calls, the capital ship is the gun platform and it hovers (not the
  bomber), the off-tank a hovercraft at 50 and a tier-one generalist, the interceptor a
  tilt-jet, the exposed-rotor helicopter Aphelion's, Kestrel's identity heat, rerolls, strikes
  and risk (the leans row). Re-proposed at his ask: the capital's second form (the fleet's
  reroll bank with growth on every roll, a lock that relaunches a jet's die, four hardpoints;
  `kestrel_gun_platform.md`, the sixth round), the Puffin made Kestrel (its Ionizer reading an
  ally's heat; `kestrel_puffin.md`, new) and the interceptor's second kit (a weapon of no
  damage Rapid once a round, the designator dive that lights a back-rank foe for the team's
  Direct guns; its brief rewritten). The twelfth round (20 October, evening), Ryan's four
  calls: a Rapid shield never below tier two (a Rapid vent never below three), so the Laminar
  Deflector keeps its Rapid as a tier-two blueprint and leaves the early stocks with the stock
  pass (the bible's Rapid and Deflector rows, section 12's question gone, the rules, the
  vocabulary note, the Deflector's notes); the capital leans into the reroll economy all the
  way, no growth (its seventh round: the bank, an ally's action bought with three rerolls, the
  launch as a shield that rolls a jet's die, the flare as a vent that brews a reroll); the
  Puffin on his split (the passive grows every shield it spends on an ally by that ally's heat,
  the Ionizer the overshield through it, the cooling gone; its second round); the interceptor's
  third kit, refined (the control gate and a designator with free reach that paints a foe for
  the team's Direct guns; the dive benched). Proposals, waiting on Ryan's calls; on the branch,
  not on main.
- `claude/festive-cray-i7lvnm` (the Wainwright & Sutler design sessions, since 15 October): the spider
  landed on Ryan's go (18 October: the bible's row, the rules, Vitriol, Web and Webbed in the
  vocabulary, the chassis and its Web Bomb planned in content, the brief retired to git) and
  merged into main the same day, so a session can start on its engine and assets (the to-do's
  two lines); kept open for the next Wainwright & Sutler briefs; the revolver (the Cassowary), the
  fan-boat (the Cottonmouth) and the Dingo's Combat Translocator landed on 19 October (their
  rows, the rules, planned content, the briefs retired), and the Prairie Dog's fight half the
  same day (Flak), so the boiler and then the maker's tiers remain. The tender, the campaign
  runner and the balance runner skip a chassis whose passive or locked piece is planned
  (`ContentDB.chassis_runnable`, 19 October), so the revolver and the Cottonmouth can land
  planned at tier one without being dealt; until their engine lands the maker's deal is the
  Prairie Dog.
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

## The game as left (18 October)

- 18 October, the Kestrel session (`claude/zealous-cori-8xoly7`, fast-forwarded onto main as it
  went): the three Kestrel briefs carry every round of their design (the strafer decided in
  shape, the shield-spender's direction, the bomber's pull and mark); the bible's section 6
  holds the vocabulary's two tables from `tools/pages/bible_tables.py` and the naming
  convention; built: Folded become Braced, every status a chip, timed stacks keeping their own
  rounds, the stacking policy (add or renew), Suppressed never stacking nor carrying, the Boar's
  spill; records: Numbed and the banked stores are buffs (two kinds, no third), Silence and
  Dispel decided for the enemy's side with Ward turning both away (not built).
  Then 18 and 19 October (`ccr-b6da49d3-4ft738`, above): the session's rounds with Ryan in
  the Kestrel briefs, waiting on his calls.
- Built and tested: the battle (the round, orders, fights by ring and range, hunters, five map
  types, Rift Pressure without escalation, the boss after its reveal); the skirmish as
  `docs/rules.md` states it, Rally included (Kindled at its move's value, live from the next
  round); the campaign's rules headless only (`sim/campaign.gd`, no screens); the balance
  runner (`tools/balance.gd`: `--rows`, `--module`, `--bump`, `--nopassive`, `--set`,
  `--trace`), the campaign runner and the map survey; every ally model by lowforge with acts
  and gaits; the foe art; six tracks, the effects and Jenny's lines.
- Content: five makers, 13 chassis and three planned (the funnel-web, 18 October, its passive
  and its locked Web Bomb planned; the Cassowary and the Cottonmouth, 19 October, their
  passives and the Cassowary's locked Spin-Up planned; a planned chassis is never dealt, the
  campaign's Start rule), 56 components (14 locked, 4 unstocked, among them
  the shelved Gravity Knuckles at tier three), 16 modules, four domains with 18 wildlife and bosses
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
  Dia, Cure and Holy, Ryan's three, its Protect parked). On 16 October the Augur (Clair
  Obscur's Sciel by archetype; a working name) took the Necromancer's place on the Marsh's
  bench: Omen, a countdown of two at one machine, and Harvest below half, a countdown of one
  on every machine (the two pieces paired, tested); the Necromancer and its art are gone. The White Mage is the Cleric (id kept), its promoted form's one move more Reraise on its allies, planned (Ryan, 16 October). The Summoner's summons are its moves,
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
  give a long description a second line rather than clipping it. Ryan, 16 October, from the
  screenshots against Share Tech Mono: "Keep the italic for the number, it works better."
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

- The action economy's direction (the bible's section 5, 20 October, beside the stun row):
  Rapid is priced by a gate and never rationed, and each want it sells has a home that is not
  a Rapid piece (own rerolls as a number, the team's order, counters that count blows,
  combined entries, rolls again paid in a banked resource, cooldown bursts, delayed actions,
  commander actions on map cooldowns); what the stock pass does with it is in the to-do's
  stock pass line, the reasoning in the briefs README.
- Silence and Dispel on the enemy's side (the bible's section 5, 17 and 18 October): a Silenced
  status, the two foe keywords, Ward turning both away, the front's card's intel; carriers are
  section 12's.
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
- The funnel-web (Ryan's go, 18 October; its row in section 7): its blows on a foe showing no
  intent on it lay Vitriol (5% of current hull a stack at the foe's action, a stack per hit),
  its locked Web Bomb a delayed Suppress on the foe and the next to act beside it, no cooldown,
  no fangs; tier two; in content as planned entries; the engine and the assets are the
  to-do's two lines. With it, Ryan's 17 and 18 October leans on hard control (priced by a gate,
  never rationed) in the stun row, and the time-shifter parked in the Aphelion row.
- The Cassowary (Ryan's go, 19 October; its row in section 7): the revolver, the maker's
  gunslinger at tier one, a chicken walker whose die never rolls (each fight opens on a random
  chamber and every roll steps to the next; a lock holds, Scramble a true roll), every sixth
  weapon spend double, its locked Spin-Up a true spin of the whole cylinder (itself included,
  his exception to the reroll rule) with no cooldown, no heat and no Volatile (the cylinder
  is its limiter) granting Spun Up (+5 a stack on the next weapon spend, carried between
  turns); squishy, so the maker's tender deal holds no front, accepted; the names his, the
  passive's and the designation Claude's working ones; in content as planned entries; the
  engine and the assets are the to-do's two lines, the chain's price the stock pass's.
- The Cottonmouth (Ryan's go, 19 October; its row in section 7): the fan-boat, the maker's
  versatility of reach at tier one, a light hovercraft that locks nothing (a d4); its
  Adaptive Munitions Drum fires every weapon as the drum's Indirect shot (flat 15, heat 10,
  Ballistic) with the weapon's own keywords, punching through at the back rank (Penetrate)
  and spraying at the front (Spread), the shape following the aim; in content as a planned
  entry; the engine and the assets are the to-do's two lines.
- The Dingo's Combat Translocator (Ryan's go, 19 October; its row in section 7): a second
  locked piece that picks two foes, or a foe and an empty slot, and swaps them (Swap, planned
  in the vocabulary; a massive foe stays; an empty front slot makes it a pull), tier two with
  it; the piece lands in content with its engine and the tier moves then, so the Dingo stays
  dealable until a Wainwright & Sutler tier one beside the Prairie Dog can be (the to-do's
  line); its stock with the stock pass.
- The Prairie Dog's fight half (Ryan's go, 19 October; its row in section 7): Flak, the
  maker's on-hit, a foe status that adds a point a stack to every blow it takes and halves at
  each round's end (Overcharged's clock), on-hit only; laid by the Flakshot Repeater, now a
  flat 5 that sprays (Spread, built) and rolls again, Flak 2 (planned); the car is the maker's
  softener, not a detachment identity; the flat on-hit kind is Flak's, so the Onryō's Grudge
  finds another shape; Ryan's note: Flak at a point a stack may be overpowered beside
  Overcharged at a point, read together when the numbers branch merges; the engine is the
  to-do's line, the family the stock pass's.

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
   lands. The funnel-web landed first (18 October); the Cassowary, the Cottonmouth, the
   Dingo's Translocator and the Prairie Dog's fight half on 19 October; the boiler is next,
   then the maker's tiers.
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
  `docs/design-bible.html` after every change. Live is v0.218 (20 October, evening): the
  Kestrel branch's v0.209 (the Wake Diffuser's go and Ryan's rule on Rapid equipment in the
  Rapid row, a Rapid vent never below tier three and a Rapid shield never below tier two; the
  Deflector row's tier-two blueprint; the leans row's Kestrel line; the capital in the Kestrel
  row; section 12's Diffuser question gone; the Rapid row of the generated keyword table set
  by hand to the Diffuser's change, since the live tables are the review branch's content's)
  merged onto the live v0.217 (the review session's v0.211 and its publishes after it:
  Armoured and Overcharged in points, Burn numbered, Armoured's duration and dispel, the
  funnel-web's built clause and its model rounds to the eleventh, the walkers' footwork row).
  Main's file is v0.207 until this branch is merged; the review branch's rows reach main's
  file when that branch merges, and the next publish from main regenerates the tables. Git
  and the page's version history carry what each earlier publish brought. Before
  republishing, read the live page; if another session moved it, publish a three-way merge
  onto it.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map. Republished 15 October from main's content:
  only the four content files that had moved since 13 October (chassis, components, foes,
  vocabulary), the page, the models and the renders checked unchanged and kept; again that
  evening with the boss mechanics' foes and vocabulary alone, and with the White Mage's three
  and Skaði; on 16 October with the Augur in the Necromancer's place (foes, factions) and the
  Cleric (foes).
- The boss art round's picks (Ryan, 18 October): the Behemoth, the Cinder Tortoise and the Fallen
  Weapon (the axe, which settles hammer against axe) cut into `art/foes` and recorded in
  `tools/foeforge/picks/picks.json` (art ahead of content: nothing loads them until their kits
  land); since then the Reaper, Fáfnir, Skaði and the Matador (19 October) the same way, so of
  the slate on the picker only Surtr, Floraison and the Augur remain; his notes drove a second round, on the picker for his next picks: the Matador's missing
  hand, the Reaper's extra hand, Skaði's lower-hand weapon and Fáfnir's gold through the edit
  model (the Reaper's two edit passes failed and image to image from the pick fixed it, his pick
  of that set cut on 18 October; the fix order is a bible row now: structure through image to
  image, colour through the edit mode, costume by a fresh take); Floraison redrawn humanoid with
  take 1's face, Surtr made of fire rather than on fire,
  the Augur without the coat and hood, bigger blades, both hands on the haft (fresh takes and
  image to image from the take he called closest). His second picks, the same evening: the
  Reaper (image to image, its third hand gone) and Fáfnir (the gold off) cut; the Matador, Skaði,
  Surtr, Floraison and the Augur into a third round, image to image from his picks under the
  fix-order rule. His third picks (19 October) asked for composites (2's head and boots on the
  Matador's 3, 1's head on Floraison's 2), a defined face and a held sword on Surtr, another set
  for the Augur and a retry for Skaði; the fourth round answers each (the composites as layouts
  re-rendered close beside the edit model's version; the Augur from a prompt of her own, since
  the hero style's "robes and flowing cloth" was drawing her tunics) and is on the picker. His
  fourth picks (19 October) each carry one edit more (the Matador's jaw, Floraison's clipped
  spines, Skaði's lower half as the edit's, Surtr's sword alone after a two-part edit broke it,
  the Augur's omen dark then her blades matched, chained), the fifth round; the heroes' costume
  variety pass is a to-do, the Augur's omen dark in the bible's art row (v0.204, live, merged onto another session's v0.202).
  Ryan's ask of 19 October, the staff slanted so the lower blade goes behind her legs, is rendered
  (three usable each size) and on the picker beside the upright picks and his last pick; the
  slant gains the hero's body about a tenth in the cut, the chibi little. The size worry that
  started it was Claude's misreading (the cut crops to the figure's box, so a render's margin
  costs nothing), corrected in the heroes' proposal and the picker memory.
  His fifth picks (19 October): Skaði cut (fixbow5 1); the Matador's and Floraison's edits failed,
  so both go back to composites of aligned siblings, raw and after a close pass; Surtr's blade
  added to the grip he liked; the Augur's slanted 4 picked, its blades lengthened first, the eyes
  and the smoke to follow, and the other lean rendered at his ask. The sixth round is on the
  picker (19 October), one set per question: the Matador's and Floraison's composites clean (raw
  and closed), Surtr's blade of fire by the edit model (the pass at 0.6 lost it), the Augur's
  other lean (three usable each size), her blade options on one base (as picked; long, a
  composite stretch, at a fifth less body in the cut, 128 px of 144 to 103, measured; broader at
  no cost) and her smoke's three homes, her eyes relit on every one; the heroes' proposal has
  the round and what it found (room alone grows nothing, a pass redraws an earlier colour edit,
  so structure first and colour last). His sixth picks (19 October, afternoon): the Matador cut
  (fixhand6 3, the second close pass, recorded and imported); Surtr's 2 "so close", its blade to
  turn five degrees clockwise onto the grip's line, done by hand as a layout and closed at 0.9,
  the sword's column pasted back onto his pick beside the full pass; Floraison "still weird even
  at phone scale, cut off or blurred", so another way: the eyes inside the maw painted out on his
  pick itself (an erase over dark, nothing re-rendered) beside image to image at 0.7; the Augur's
  lean 1 his new base at both sizes (the rotation went too far, her other hand on the staff), the
  smoke erased by hand and the top blade flipped inward (the edit model landed the hero's in two
  of six seeds; the chibi's by a reflection of the head across the shaft's axis, the hand edit the
  layout for a pass); the blade and smoke sets superseded unpicked. The seventh round is on the
  picker. Its database
  (Ryan's saved edits, collection `edits`; name candidates, `candidates`) opens only from the
  personal account; `edits` was empty on 15 October, after the second republish too.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor); picks and notes in collection `picks`, readable from a personal-account session.
  It holds the boss art round's seventh sets (19 October): Surtr's blade on the grip's line
  (`surtr_bossart10`), Floraison's eyes painted out (`bourgeon_bossart10`) and the Augur's new
  base with the smoke gone and the top blade flipped inward (`augur_heroart16`,
  `augur_chibi_heroart16`), built by `forge.py phone --only --tags bossart10 heroart16
  chibi_heroart16 --keys surtr_bossart10 bourgeon_bossart10 augur_heroart16
  augur_chibi_heroart16`; every earlier round's folder stays under `tools/foeforge/out/` as the
  record, and the renders that lost a blade or a brief sit in each set's `set_aside/`.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

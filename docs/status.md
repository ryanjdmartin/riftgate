# Status

How things stand, for the next session, and the order of work. Facts and the state as left;
history lives in git (this file's changelog to 23 October: `git show 9bec2ba:docs/status.md`).
The rules are `docs/rules.md`; the why and the questions only Ryan can settle are the bible
(`docs/design-bible.html`, its first row first); the tasks are `docs/todo.md`; every run a
decision cites is `docs/measurements.md`; the layout, every document's job and every command
are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row, this file and `docs/todo.md`. If a
  chat and a file disagree, the chat is newer.
- Sessions run in parallel on this repo: `git status` first, stage by path, diff a shared file
  before staging it, never a bare `git add -A`, never kill a bare `godot --path .`. Local main
  and `origin/main` diverge for a day at a time; merge `origin/main` into local main before a
  records pass, and expect the bible's live page to have moved (read it, merge, republish).
- The desk machine is a Windows PC since 19 October (the Mac went out of reach mid-session):
  `C:\Users\jam82\Desktop\Code\riftgate`; the README's Running section says what is set up
  there. What the Mac held outside git is gone. Of the seventh round's foeforge renders
  (force-added in `fb45141`, its picks cut on 26 October), only the Augur's stay in git, her
  only surviving renders, kept for her next pass (the rest: `git show fb45141`); foeforge's
  `generate` and `fix` have no machine until a route for the image model is chosen.
- Tests: 721 tests, 66,033 checks, green on `ccr-7d865127-wr1ko2` with main merged (28 October,
  the numbered area and the blow's order from main, the Kestrel models' second notes and the
  glow-parts test tightened to the rig's own rule on the branch; before it 721 tests, 65,988
  checks, green on main's head), about four minutes in a cloud session, twenty on a slow one. A cloud session fetches Godot 4.7's Linux
  build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots (with
  `--rendering-method gl_compatibility`, Mesa's llvmpipe on the CPU: its draw calls are true
  counts, its frame times mean nothing), and builds models with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1` (the wheel takes about twenty minutes to install). Its first `--import` rewrites
  four Prairie Dog textures and a model build the maker's review tiles: restore both
  (`git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`) rather than commit them.

## Branches

The review of 27 October (this branch, `ccr-24cae16e-ryhv1v`) merged every branch that stood
beside main into it, since two sessions had each expected main to take theirs on the 26th and
neither merged the other: `ccr-170f6d81-465jnr` (Ryan's go of 26 October: the die's hold, the
units' holds and the codex as text, the keywords list, area at half, Flak on a weapon's blow of
0, the weapon and equipment words, the vent's blast as a weapon's hit, Spun Up spent by a weapon
alone, the Skua's runner rows), `claude/quick-campaign-mode-pafhiv` (the quick campaign, one
damage state, the bosses at their tier), `ccr-6073bda9-p34o8q` (the foes' fresh start proposed,
`docs/foes_proposal.md`; the campaign bot moving as one with its withdrawing persona; `--pack` on
the balance runner), `ccr-7d865127-wr1ko2` (the Kestrel looks' third and fourth rounds, which the
status of the 26th listed as fully merged while they stood unmerged) and `ccr-7effd31a-u5z4gw`
(the Hold The Line pair). The conflicts were the records and the two sessions' same-afternoon
changes to the skirmish (each merge commit says how it was resolved); the suite ran green on
the result (the Tests line) and main took this branch as a fast-forward the same day. Every
branch named here is fully merged, to delete from the desk machine or GitHub along with
`claude/affectionate-goldberg-8e3mkh`, `claude/playtesting-issues-08mnqj`, `ccr-535a7596-5ptzsj`,
`claude/eager-newton-sf947u`, `claude/friendly-cannon-kyk9v4` and, once this session ends,
`ccr-24cae16e-ryhv1v` (a cloud session may not delete one). Every other branch was
merged into main and deleted (22 October).

## The design sessions

Each resumes from its briefs; `docs/briefs/README.md`'s table says what each waits on.

- Kestrel: ten machines, eight decided and in content (the bible's Kestrel row; the hub
  `docs/briefs/kestrel_line.md`). Its models' second round landed 28 October and took two
  rounds of his notes the same day (the Storm Petrel's field strips, sparks, beaded arch and
  emitters clear of the guns; the Puffin's plates near plumb with lit rims, its amplify's glow
  found dead, a prefix the rig never matches, and the build refusing one since; the
  Lammergeier's launcher nacelles, riding the wing's upper skin, their tube mouths holes cut through the face plate and bored
  twelve deep above the skin,
  the Storm Petrel's arch on feet with two-thirds sleeves; the Skua's five acts,
  the run and the stoops flown as a banked circle and a figure eight on the map (the Kite's
  helpers under a spline height profile with the nose rate-limited, `_over_ground`) after
  Ryan's phone frames showed the keyed forty units as bobbing in its hex, the bigger keyed cut
  as janky and the first flown cut as flicking, the roll with the hands spread; Ryan's picks
  from
  five rounds of looks: the Skua the jaeger, the Puffin and the Storm Petrel on each other's hulls,
  the Lammergeier the flying wing; the Needletail's two modes and the Giant Petrel's catamaran
  his next session's, the to-do; the scissor swing wing tried again the same day as a look for
  one of the two unspecced designs, two F-14 pairs on their own pivots that open into an X and
  beat as an ornithopter and close into a blade, `docs/looks/kestrel_ornithopter.png`; parked as
  a candidate for the Owl or the Magpie, the bible's Kestrel row). The Skua fielded since its engine of 25 October (each roll
  halved, rounded down and never below one since 27 October, and struck twice; the Pod's spray), its rows read the same day: mid-field
  alone, its way through plate a flat buff on each strike (`docs/measurements.md`); the Giant Petrel's engine session
  follows from its brief, and the Storm Petrel's after the pricing run; the last two, the Magpie (a working name, a support engine)
  and the Snowy Owl (a stealth unit), are Ryan's next session, his directions and Claude's first
  round in each unanswered.
- Wainwright & Sutler: ten decided, 3-5-2, nine built (the bible's roster row); the gunship's
  session is free to run.
- Minerva: the Honey Badger's rework in session (Ryan's calls in its brief, four numbers open),
  the echidna left open, the siege battery parked on Ryan's charge brief, the battlecruiser never
  with the Carrier's session (Ryan, 20 October).
- Aphelion: the line frame and the Baboon first (the pair that keeps its tier-one deal varied),
  then the jellyfish; the Carrier on its own; a defensive tier one unproposed (the to-do).
- The Arsenal: Misharu, the Onryō, Mastema and Minos, Claude's first round and review in their
  briefs, unanswered: Misharu's two calls first (Penance's shape, how often it may fire), then
  the Onryō's kind and trigger.

## How things stand

- Built: what the bible's section 12 lists, run as `docs/rules.md` states it (its known gaps at
  the end). The campaign's rules run headless only (`sim/campaign.gd`); no screen shows them.
  Since 27 October main also holds, from the branches above, the quick campaign on screen with
  the game's first hangar, the die's, the units' and the map's holds as text with the keywords
  list, area at half, one damage state and the bosses at their tier.
- The quick campaign (25 October): battles without the map, headless, saved, on screen with the
  game's first hangar, run by `tools/quick_run.gd`. Its first runs (`docs/quick_run.md`,
  `docs/measurements.md`, 40 runs a rung) find a cliff at the first battle for a starting trio
  (34 to 36 runs of 40 lost there on the branch; 39 of 40 on main's head of 27 October with the
  bench-hero stand-in out, 22 of them at the boss, whose fight with its formation is won 15%
  of the time from 59% of the squad's hull, where the tier-one formations are won 87%) and a
  plateau after it while the enemy has no tiers: section 12's question, to read against the
  fresh start's compositions before any lever moves; area at half is the rule behind the
  cliff (the Balance bullet). Its elite slots hold the lead's formation alone until the elites
  land (the to-do; the bench hero that stood in went on 27 October, Ryan: "a can of worms");
  from tier two a domain's final may be a battle's boss (Ryan, 25 October), and every boss
  fight brings the tier's escort.
- Bosses scale to the battle's tier (Ryan, 25 and 26 October; the bible's section 9 row, section
  3's row carrying the exception): a domain's boss, a final's hero and the finale's line take
  the tier's HP and attack and bring more escort, drawn from the domain's units of the tier (a
  unit's `tier` in content, one by default: no unit has another yet), in the campaign and the
  quick campaign; the rank and file never scale. The campaign counts its tiers from the
  Convergence (tier two from 4, tier three from 8, the finale at 12 on tier three's step); every
  number a placeholder.
- Injuries (25 October): one damage state, Ryan's "Cracked is gone". An injury destroys the
  entry the die lands on, at a quarter of the maximum hull, the threshold set by what it asks of
  the player (half was tried and retired within the day: a machine could lose but one piece); a
  wreck loses only what was destroyed. The Honey Badger's "never destroyed" now holds off every
  injury until its identity session lands (Ryan: later; the to-do), so until then it is the one
  machine no blow can strip. The quick runs on the bot destroy about one to one and a half
  pieces a battle in tiers one and two (`docs/quick_run.md`), at or past section 10's "about one
  a won battle" line where the threshold moves, so the destroyed-is-gone threshold is the
  economy pass's first number to read.
- Content: five makers; 24 chassis, every one runnable but the Storm Petrel and the Giant Petrel
  (their passives and four locked pieces planned, so never dealt); 80 components,
  32 of them locked; 17 modules; four domains with 18 wildlife, their bosses among them, and 8
  heroes with their promoted forms; 5 foe moves planned (a flee, an interpose, a retaliate). The
  numbers are the stock pass's (22 October, `tools/stock_fills.py`), the four Kestrel machines'
  set by hand at its scale; every one a placeholder.
- Models: every machine's by lowforge but five (the Cassowary, the Cottonmouth, the Whip
  Scorpion, the Swallowtail and the Musk Ox, which draw the Badger's); the Lammergeier's, the
  Skua's, the Puffin's and the Storm Petrel's are the Kestrel second round's picks of 28 October,
  to judge running; the Needletail's and the Giant Petrel's are the first cut of 23 October
  until Ryan's next session (the to-do). Since 25 October every machine's parts are welded at load by material
  within each moving group (`game/ui/mech_weld.gd`, the bible's battery row): a machine's draw
  calls about halve and nothing on screen changes (`docs/measurements.md`); `RIFTGATE_WELD=off`,
  or a debug build's WELD setting on the phone, draws every part as authored to compare, and a
  new model's part that moves, glows or hides on its own needs a joint, a pin or a name in
  `glow_parts`.
- Foe art: every foe and hero cut from Ryan's picks, and every subject of the boss art round
  cut ahead of its kit (`art/foes`, `tools/foeforge/picks/picks.json`), the last three from the
  picker's seventh round on 26 October: Surtr (his white-hot blade and blaze kept by the cut's
  new `--keep-glow`), Floraison and the Augur, who needs another pass "at some point" (Ryan:
  "she's still not correct"; the to-do). The cloud session that cut those three could not fetch
  Godot; their six `.import` files were written and committed on the desk machine the same day,
  the suite green there (644 tests).
- Balance, read by stage (Ryan, 23 October; `docs/measurements.md`): a starter trio's fights
  are the Peak's, the Marsh's and the Meadow's formations, the Magma Elemental and the Sandworm,
  the rest free and the finale a wall; an endgame four fitted to tier two finds every pack free
  but the finale; nothing sits between, so the middle of the curve is the foes' fresh start's.
  The coordination gap reads 1.0 to 1.3 on built teams against the tests' about 2, and the
  campaign's plain player wins none of 40 runs (both section 12's). The 39% of battles that
  player won after the playtest list's boss fight (26 October, the report main carried until
  the 27th) was a bot artefact: it opened the boss's fight from the gate on its first turn, which
  no order allows; with the order rule on it (`ccr-6073bda9-p34o8q`, 26 October) it won 15%. On
  the merged head (27 October, `docs/measurements.md`) it wins 7% of its battles and no final,
  the three-machine battles 36%, and one quick campaign run of 40 leaves its first battle
  (with the bench-hero stand-in out and the Skua's floor of one, 27 October: 10 fall at a
  formation, 7 at the formation in the elite's slot, 22 at the boss; the tier-one formations
  won 87%, the boss's fight with its formation 15% of 26, where the branch read 91 and 73):
  tier one reads harder than on any branch alone, and the rule is area at half, by experiment
  (`docs/measurements.md`, 27 October, the stand-in still in: with area at full the first
  battle is won 18%, the formations 94%, the elite 65%, the boss 80%; the re-pick put back
  changes nothing), since the Honey Badger and the Cottonmouth carried the starter trios on
  their area and the 26th's read saw them alone:
  section 12's quick campaign question carries the call. The 200-seed matrix on the merged head
  (`docs/balance.md`, 27 October; its read in `docs/measurements.md`) finds every move a rule of
  the week landing where it was meant to, and area at half landing harder than its read of the
  26th said: the Honey Badger's, the Wild Boar's and the Musk Ox's formation cells and the
  Cottonmouth's finals go back to the 22nd's bands with area whole, and nothing else moves them.
  The Marsh's list holds the Zombie Knight ×2 since 27 October where its second Revenant line
  stood (the audit's 37, an oversight from the domains' landing), so the matrix's Marsh formation
  (fifteen foes there, eleven now) and its missing Zombie Knight ×2 cell predate it.
  Read again on the team rows in three forms, half, half rounded up and whole (27 October,
  `docs/measurements.md`): the half walls no four, with area or without (greedy wins every
  formation at 100% for 3 to 14% hull in a single fight), and moves an area four's rounds, not
  its wins; a trio without area bleeds 30 to 96% of its hull on a formation under every form,
  so the quick campaign's cliff is the trio's chain against the fights' size, which whole area
  hides by tempo (28% of trios pass the first battle whole, 8% rounded up, 3% at half); at
  single digits a half-blow kills no rank and file; a fixed 2 on the neighbours reads as the
  half (the same day), since a number tells only at the swarm's kill threshold of 3. Ryan's
  call, 28 October: Spread N, Penetrate N and Splash N, with the blow's order read for each
  foe struck (the bible's rows), built the same day with each carrier's N a placeholder from
  Claude's proposals and the Kite's double kept on the printed number; read on the team rows the
  same day (`docs/measurements.md`): between the half and whole, nearer the half, the rows
  without area the same fight for fight, a neighbour's number telling at the rank and file's
  kill threshold of 3 (the Enfilade Beam's), the 2s softening. The quick campaign is an
  experiment, not a feature (Ryan, 28 October): its reads above are history, not grounds.
  The fights' size is the bigger lever (the same day): tier one's formations a third thinner
  take the quick campaign's first battle from 3% to 55% at half area, half thinner to 70%, and
  thinned formations are a trio's decision band in the matrix; the Zombie Knight pair's first
  read makes the Marsh formation an injury mill for a trio (its breaching 6 is a massive foe's
  blow on a rank-and-file body: Ryan's number to move). Three or four is section 12's question
  since the 27th (Ryan: revisit it).
  Gel x4 alone is a free pack for most of the roster since the Gel became a wall; its work is
  inside a formation. The set finals (26 October) turn every rift a domain
  leads final at once; the rally at once moves no cell of the packs that field it out of its
  band (`docs/measurements.md`, 30 seeds, a direction). Since 24 October a foe picks at random unless its threat calls for an aim, every
  rank and file today, the baseline the numbers are balanced on, and no foe over-commits: the
  formations read a few points easier for it, and their pressure is the balancing's to restore.
  The foes' heat doubled the same day as its first cut: the Peak's formation fell from 88% won
  to 69% for the starter trios, the cold ones paying a little to heat and the hottest walled on
  the greedy bot (Ryan's play judges it, the to-do).

## Decided, not built

The tasks are the to-do's; this is the index of what waits.

- The Giant Petrel's engine and the Storm Petrel's, after the pricing run (their briefs).
- The elites on Ryan's definition of 23 and 24 October, a guaranteed miniboss event mid-battle
  (the bible's tiers row), with the bosses' slate
  (`docs/bosses_proposal.md`) and the promoted forms' one move more for seven of them
  (`docs/heroes_proposal.md`).
- The planned foe moves, Silence's and Purge's carriers (section 12), and Purge as our keyword
  (its carriers and numbers open).
- The Honey Badger's rework, once its numbers are settled (its brief).
- The six machines' models, the Armadillo's rebuilt with its seal, and the Translocator's mount.
- The commander layer, the screens, the economy's verbs and loot (sections 8 and 10).

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list). First: the three reports rerun on main's head (the to-do's first engine
line), since no number read since 22 October was read on the content as it now stands.

1. **The design sessions, from the briefs** (above): each decision a bible row, each brief
   retired once its decisions are rows and content.
2. **The stock pass's tail**: Ryan's name pass and the pricing run, on the bots' Shock priced at
   the hitter in hand (the to-do); the Lammergeier's stock.
3. **The foes' fresh start, the fight-size spectrum and the Rupture meter.** Reads section 4's
   pacing and four-machines rows, section 9, section 12's foe questions,
   `docs/campaign_run.md` and `docs/curve_proposal.md` (the tier a rift's foes, elites and
   Fractures follow, once Ryan picks its form). Builds compositions with a front and a back
   spawned by the rift, small packs for detachments and formations for the body, the boss sealed by the
   threat-weighted meter and fought with its formation, the withdrawing persona on the campaign
   bot, the curve by stage (section 3's curve row) and the elites on Ryan's definition (section
   9's tiers row), read against the starter and endgame grids of 23 October; then reruns both
   reports and measures the fights a team fights together.
4. **Balancing for real** (Ryan, 14 October: only once the go is hashed out and the stock pass
   is in can the units be balanced for real; 24 October: it "probably needs foes with proper
   formations", so it follows the fresh start): the runner's rows on the roster as it stands,
   the fours again, prices and tier ladders (the to-do's engine line), the heat report, and
   Ryan's play deciding feel.
5. **The screens** (Ryan, 13 October: early, so the first thing built after the battle has its
   shape is a run he can play; the go, the stock pass and the balancing come first, Ryan, 14
   October): a prototype hangar, the mission map and the draft.
6. **The economy pass** (`docs/economy_pass.md`): the runner's spending policy, then every price
   and yield with the offers one of each kind, a chassis on the shelf, the Favour dock as the
   gate's price, twelve to sixteen battles.
7. The rest in the standing order: Ryan's text; the domains' last engine (the planned moves;
   the bosses' slate as content alone); the pacing session's remaining pieces; the battery plan's rest (the props' fade, the 3D at 30); audio;
   art; the commander layer after a balance baseline; onboarding before a phone leaves the desk.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them by
URL (read first). Databases are reachable only from the personal account. A page's link goes
into this file in the same commit as its first publish; the procedures are in `README.md`.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. This file and the live page are v0.339 (the
  page's version 351, published 28 October from `ccr-7d865127-wr1ko2` as a three-way merge onto
  another session's v0.338 (version 350): the Skua's motion row, its run and stoops flown paths
  on the map; before it this branch's v0.334 (version 345) carried the Skua's second notes onto
  the area session's v0.333). The version numbers on the publishing branch's
  file and the live agree after every publish. Before republishing, read the live page; if
  another session moved it, publish a three-way merge onto it (`git merge-file` with the
  last-published file as the base, the wrapper's first line and its trailing `</body></html>`
  stripped from the saved live source). With every branch landed, the file holds no rows ahead
  of code, and the tables script may run freely again.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each checked identical to the last publish's
  before it is replaced and `edits` read first. Every file the page reads is fetched with a
  stamp on the URL past any cache between (28 October, after Ryan saw an older round's Skua
  acts on a reloaded page). At the page's version 136 (28 October, from
  `ccr-7d865127-wr1ko2` onto the area session's 127: the Skua's, the Puffin's, the Storm Petrel's and the Lammergeier's
  models and rigs after Ryan's eight rounds of notes, their renders and the manifest with his notes, the pins, `content/chassis.json` with the
  Lammergeier's designation and `content/factions.json` with the Zombie Knight; every other
  file identical to the live page's, `edits` empty). Its database (Ryan's saved edits,
  collection `edits`; name candidates, `candidates`) opens only from the personal account.
- The roster analysis: https://claude.ai/artifact/QVLRVD8YXsK8ZUKY3A1vxo, rendered from
  `docs/roster_analysis.md` by `tools/pages/roster_analysis_page.py`; background since the go,
  republished after the page changes and retired with it once the last brief that cites it
  lands.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor); picks and notes in collection `picks`, readable from a personal-account session.
  It holds the boss art round's seventh sets (19 October), all picked on 26 October and cut:
  Surtr's blade on the grip's line, Floraison's eyes painted out, and the Augur's new base with
  the smoke gone and the top blade flipped inward. Of the rounds' folders under
  `tools/foeforge/out/`, only the Augur's last two stay, with the seventh round's job lists (each
  set's `set_aside/` holds the renders that lost a blade or a brief); the README has the
  command that builds her sets as a page, and the fix order that worked is the bible's art row.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

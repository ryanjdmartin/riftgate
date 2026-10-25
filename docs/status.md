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
  there. What the Mac held outside git is gone but the seventh round's foeforge renders,
  force-added in `fb45141` so the picks can be cut here; foeforge's `generate` and `fix` have
  no machine until a route for the image model is chosen.
- Tests: 648 tests, 65,113 checks, green on `claude/quick-campaign-mode-pafhiv` (25 October, the
  quick campaign, one damage state and the bosses' escort by tier; main's 628 and 64,352 since
  the landing), about half a minute in a cloud session. A cloud session fetches Godot 4.7's Linux
  build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots (with
  `--rendering-method gl_compatibility`, Mesa's llvmpipe on the CPU: its draw calls are true
  counts, its frame times mean nothing), and builds models with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1` (the wheel takes about twenty minutes to install). Its first `--import` rewrites
  four Prairie Dog textures and a model build the maker's review tiles: restore both
  (`git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`) rather than commit them.

## Branches

This branch, `claude/quick-campaign-mode-pafhiv` (25 October), is the quick campaign built on
Ryan's calls of that day (the bible's section 3 row; `sim/quick_run.gd`, its screens in
`game/quick/`, its save, `tools/quick_run.gd`) with the chain probe its proposal cited, and one
damage state (his "Cracked is gone", the same day; the audit's 7a asked it), waiting on his play
and on section 12's quick campaign question before it merges. Other sessions' branches
of the same day stand beside it, each with its own status: `ccr-170f6d81-465jnr`'s later commits,
`claude/affectionate-goldberg-8e3mkh` (the mechanics audit, which carries them),
`claude/playtesting-issues-08mnqj` (Ryan's playtest list), and main's Windows launchers
(`ef91382`). A trial merge with each (25 October, after the damage state) takes the code clean
but for `Skirmish.can_withdraw` beside the playtest branch (at `3caf956`), whose `committed` (the
boss's fight, no withdrawal) is this branch's `withdraw_allowed` the other way round: one flag at
the landing, the quick run setting it. The records conflict: this file, the bible (its version
line; beside the playtest branch the built list and section 12's rules list), the measurements
beside the audit's, and `docs/vocabulary.md`, regenerated after the merge. Earlier on 25 October, on Ryan's
go ("merge in and clean up"), main took the three that stood beside it:
`ccr-170f6d81-465jnr` (the records swept on his ask of 23
October, the foes' conditions and their targeting at random, the riders numbered and the heat
doubled, the Kite's reset without a limit, the Skua's engine), which carried
`ccr-7d865127-wr1ko2` (the four Kestrel machines of 21 October and their models' first cut,
whose second round of looks is still Ryan's to judge) and `claude/eager-newton-sf947u` (the
stock pass's reads, the read by stage, Ryan's terms and elites, the curve and the fronts in
`docs/curve_proposal.md`). Main's weld (`claude/friendly-cannon-kyk9v4`, landed the same day)
was merged into them first, so main fast-forwarded. Delete the four from the desk machine or
GitHub, since a cloud session's push to delete one is refused; `ccr-170f6d81-465jnr`'s session
was still at work that day, so its later commits land by merging main in. Every other branch was
merged into main and deleted (22 October).

## The design sessions

Each resumes from its briefs; `docs/briefs/README.md`'s table says what each waits on.

- Kestrel: ten machines, eight decided and in content (the bible's Kestrel row; the hub
  `docs/briefs/kestrel_line.md`). The Skua fielded since its engine of 25 October (each roll
  halved, rounded down, and struck twice; the Pod's spray); the Giant Petrel's engine session
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
- The quick campaign (25 October, on the branch): battles without the map, headless, saved, on
  screen with the game's first hangar, and run by `tools/quick_run.gd`. Its first runs
  (`docs/quick_run.md`, `docs/measurements.md`) find a cliff at the first battle for a starting
  trio (34 and 35 runs of 40 lost there on the greedy and planner rungs) and a plateau after it
  while the enemy has no tiers: section 12's question. Its elite is a stand-in until the elites
  land (the to-do); from tier two a domain's final may be a battle's boss (Ryan, 25 October),
  and every boss fight brings the tier's escort.
- Bosses scale to the battle's tier (Ryan, 25 October; the bible's section 9 row): a boss
  unit brings two more of its escort at tier two and four at tier three, in the campaign and
  the quick campaign; its numbers wait on section 12's question against section 3's
  escalation row ("never an old one with a bigger number").
- Injuries (25 October, on the branch): one damage state, Ryan's "Cracked is gone". An injury
  destroys the entry the die lands on, at a quarter of the maximum hull, the threshold set by
  what it asks of the player (half was tried and retired within the day: a machine could lose
  but one piece); a wreck loses only what was destroyed. The Honey Badger's "never destroyed"
  now holds off every injury until its identity session lands (section 12). It settles the
  mechanics audit's 34 and the crack half of its 5 (its 7a's question to Ryan). Jenny's
  "component damaged" and "hardpoint hit" are folded into the destroyed pool (his call).
- Content: five makers; 24 chassis, every one runnable but the Storm Petrel and the Giant Petrel
  (their passives and four locked pieces planned, so never dealt); 80 components,
  32 of them locked; 17 modules; four domains with 18 wildlife, their bosses among them, and 8
  heroes with their promoted forms; 5 foe moves planned (a flee, an interpose, a retaliate). The
  numbers are the stock pass's (22 October, `tools/stock_fills.py`), the four Kestrel machines'
  set by hand at its scale; every one a placeholder.
- Models: every machine's by lowforge but six (the Cassowary, the Cottonmouth, the Whip
  Scorpion, the Swallowtail, the Musk Ox and the Lammergeier, which draw the Badger's); the four
  Kestrel models of 23 October are Claude's first cut, in a second round of looks on Ryan's
  notes (the to-do). Since 25 October every machine's parts are welded at load by material
  within each moving group (`game/ui/mech_weld.gd`, the bible's battery row): a machine's draw
  calls about halve and nothing on screen changes (`docs/measurements.md`); `RIFTGATE_WELD=off`,
  or a debug build's WELD setting on the phone, draws every part as authored to compare, and a
  new model's part that moves, glows or hides on its own needs a joint, a pin or a name in
  `glow_parts`.
- Foe art: every foe and hero cut from Ryan's picks; the boss art round's picks cut ahead of
  content (`art/foes`, `tools/foeforge/picks/picks.json`), Surtr, Floraison and the Augur on the
  picker's seventh round (Pages).
- Balance, read by stage (Ryan, 23 October; `docs/measurements.md`): a starter trio's fights
  are the Peak's, the Marsh's and the Meadow's formations, the Magma Elemental and the Sandworm,
  the rest free and the finale a wall; an endgame four fitted to tier two finds every pack free
  but the finale; nothing sits between, so the middle of the curve is the foes' fresh start's.
  The coordination gap reads 1.0 to 1.3 on built teams against the tests' about 2, and the
  campaign's plain player wins none of 40 runs, its fights mostly one machine alone (both
  section 12's). Since 24 October a foe picks at random unless its threat calls for an aim, every
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
to-do's Ryan list).

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
  `docs/design-bible.html` after every change. This file is v0.294, and so is the live (25 October,
  the page's version 311, from `claude/quick-campaign-mode-pafhiv`: the injury at a quarter, the
  bosses' escort by tier, the quick campaign's finals, on v0.292, which merged
  the quick campaign's rows onto the live v0.291, which carried `ccr-170f6d81-465jnr`'s v0.290 and
  the mechanics audit's v0.291, so this file holds their rows and tables ahead of their code, which
  lands with them: `tools/pages/bible_tables.py` run here before they land writes this branch's older
  tables back). The
  version numbers on the publishing branch's file and the live agree after every publish. Before
  republishing, read the live page; if another session moved it, publish a three-way merge onto
  it (`git merge-file` with the last-published file as the base, the wrapper's first line and
  its trailing `</body></html>` stripped from the saved live source).
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each checked identical to the last publish's
  before it is replaced and `edits` read first. At the page's version 112 (25 October, from
  `claude/quick-campaign-mode-pafhiv`: one damage state's content, the Badger's passive line and
  the vocabulary's injury terms at a quarter, merged three-way onto the mechanics audit's files
  of version 110; `edits` empty). The live content files are that merge, so neither branch's
  files match them until the two land. Its database (Ryan's saved edits,
  collection `edits`; name candidates, `candidates`) opens only from the personal account.
- The roster analysis: https://claude.ai/artifact/QVLRVD8YXsK8ZUKY3A1vxo, rendered from
  `docs/roster_analysis.md` by `tools/pages/roster_analysis_page.py`; background since the go,
  republished after the page changes and retired with it once the last brief that cites it
  lands.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor); picks and notes in collection `picks`, readable from a personal-account session.
  It holds the boss art round's seventh sets (19 October): Surtr's blade on the grip's line,
  Floraison's eyes painted out, and the Augur's new base with the smoke gone and the top blade
  flipped inward; the README has the command that builds it. Every earlier round's folder stays
  under `tools/foeforge/out/` as the record, and the renders that lost a blade or a brief sit in
  each set's `set_aside/`; the fix order that worked is the bible's art row.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

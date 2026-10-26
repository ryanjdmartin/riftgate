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
- Tests: 654 tests, 64,720 checks, green on `claude/affectionate-goldberg-8e3mkh` (26 October, Ryan's
  playtest list merged in with the mechanics audit's fixes), about a minute in a cloud session.
  A cloud session fetches Godot 4.7's Linux
  build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots (with
  `--rendering-method gl_compatibility`, Mesa's llvmpipe on the CPU: its draw calls are true
  counts, its frame times mean nothing), and builds models with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1` (the wheel takes about twenty minutes to install). Its first `--import` rewrites
  four Prairie Dog textures and a model build the maker's review tiles: restore both
  (`git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`) rather than commit them.

## Branches

Four branches of 25 and 26 October stand beside main, none of them in it yet.
`claude/affectionate-goldberg-8e3mkh` carries two of the others merged in. One is
`ccr-170f6d81-465jnr` to `70481ec`: main's landing of 25 October (Ryan's go: "merge in and clean
up") and that session's later commits of the day (a passive's lay on any hit, the Ambush's
damaging hit its own rule; the bot's flat buff counted on each strike; a damaging weapon's Shock,
Cryo and Vitriol whatever it dealt; the Skua's runner rows; Flak on a damaging weapon's blow of
0). The other is `claude/playtesting-issues-08mnqj`, merged on Ryan's word of 26 October ("Yes do
the merge, those changes were important"): his playtest list (the map's moves planned and played
on ENGAGE or END TURN, UNDO in the order things were done with orders in it, every pack's ring in
red and a selected machine's red band, the button's pulse on the map and in a fight, SIG LOST no
longer stuck under a held foe, the boss's order no longer bobbing, the grid down a fifth), his
second round (the boss's fight takes every machine, straight to the reveal, with no withdrawal; a
hunted machine's tag; a stop sign on end hexes; a foe flying into the pool's count) and his third
(the Gel's halves a pair in one slot, summons taking an empty slot, a foe getting back up in its
slot, no Exposed chip or codex line for an empty front, an area weapon bracketing the pair as
one, summoners with no condition), waiting on his phone read (the to-do). On them, the
mechanics audit Ryan asked for after the Flak fix (`docs/mechanics_audit.md`, 42 findings traced
through the code and cited by line, its "start here" list first) and the fixes he called for on
25 and 26 October (the audit's head lists them). Landing it lands all three.
`ccr-170f6d81-465jnr` has one commit past it (`b1aa261`, the die's hold showing the entry alone),
which main takes from that branch. `claude/quick-campaign-mode-pafhiv` (25 October) holds the
quick campaign (`sim/quick_run.gd` and its screen), one damage state (Cracked gone, each injury
destroying, at a quarter of the hull) and the bosses' escort by tier; its bible is the live page's
(v0.294 at the page's 311, this branch's v0.291 rows merged in ahead of their code). Landing it
beside this branch conflicts in `sim/skirmish.gd`, the rules, the bible, the vocabulary and its
page, the measurements and this file.
On 25 October, on Ryan's go ("merge in and clean up"), main took
the three that stood beside it: `ccr-170f6d81-465jnr` (the records swept on his ask of 23
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
  halved, rounded down, and struck twice; the Pod's spray), its rows read the same day: mid-field
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
  campaign's plain player wins none of 40 runs (both section 12's). Since the playtest list's
  boss fight (every machine goes in, with no withdrawal) its battles are mostly one fight, the
  boss's, joined by its ring within about four phases: it wins 39% of its battles where it won
  2%, a run lasting fourteen turns where it lasted nine (`docs/campaign_run.md`, 40 runs, a
  direction), so until the Rupture's seal lands a battle can be a straight rush on the boss. Since 24 October a foe picks at random unless its threat calls for an aim, every
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
  `docs/design-bible.html` after every change. This file is v0.291, and so is the live (25 October,
  the page's version 308, from `claude/affectionate-goldberg-8e3mkh`: the Ward turning away every
  rider, a special's too, and the tables; 307 was `ccr-170f6d81-465jnr`'s v0.290, Flak on a
  damaging weapon's blow of 0, which the live matched before 308). The
  version numbers on the publishing branch's file and the live agree after every publish. Before
  republishing, read the live page; if another session moved it, publish a three-way merge onto
  it (`git merge-file` with the last-published file as the base, the wrapper's first line and
  its trailing `</body></html>` stripped from the saved live source).
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each checked identical to the last publish's
  before it is replaced and `edits` read first. At the page's version 110 (25 October: from
  `ccr-170f6d81-465jnr`, the Skua fielded and the vocabulary's Spray at 106, the Ambush's damaging
  hits and Vitriol's line at 107, a damaging weapon's procs in Shocked, Cryoed, Cryo, Vitriol and
  the Cryo Flinger at 108, Flak's line at 109; from `claude/affectionate-goldberg-8e3mkh`, the
  Ward's, Phased's and Overshield's codex lines at 110; the live files identical to the last
  publish's and `edits` empty before each). Its database (Ryan's saved edits,
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

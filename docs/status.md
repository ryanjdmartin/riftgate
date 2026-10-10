# Status

How things stand, for the next session. Keep it under a screen and replace stale lines;
history lives in git. The rules are `docs/rules.md`, the why is the bible
(`docs/design-bible.html`), the next tasks are `docs/todo.md`, the layout and every
command are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, this file and `docs/todo.md`. If a chat and a file
  disagree, the chat is newer.
- Sessions run in parallel on this repo: `git status` first, stage by path, diff a shared
  file before staging it, never a bare `git add -A`, never kill a bare `godot --path .`.
- Tests: 428 tests, 19,544 checks, green (10 October, on `ccr-abac8c0f-yig0e2`). A cloud
  session fetches Godot 4.7's Linux build from the GitHub release asset
  (`godotengine/godot-builds`, `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for
  screenshots, and builds models with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1`.

## Branches

- `ccr-abac8c0f-yig0e2` (this one) carries the content revision, the modules, the 10 October
  weapon rules (no crits, two reaches, the die showing the number, the Paradox meter, Numbed
  the only resistance, the mirrored Booster and Databank, the Nemesis's Crucible) and the
  rewritten docs (`docs/rules.md`, the bible at v0.112, this file, the to-do). It is not on
  main yet.
- `main` has 21 commits this branch lacks: the first foe art (18 wildlife and 8 chibi heroes
  cut at 72x96 from Ryan's picks, `UnitView.pixel_snap`), foeforge's briefs, takes and phone
  picker, `RIFTGATE_FOES`, and a balance report at the halved scale on the four domains.
  Merging main in conflicts in the bible, this file and the to-do (take this branch's, which
  already carry main's facts), in `content/foes.json` (merge by hand: main's sprite briefs,
  this branch's numbers) and in `docs/balance.md` (main's, until the rerun); the rest merges
  clean (checked with `git merge-tree`). Rerun the tests after.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them
by URL (read first). Databases are reachable only from the personal account. A page's link
goes into this file in the same commit as its first publish.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change (v0.112).
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s map (which leaves out `content/modules.json`: add it).
  Stale since 9 October. After Ryan edits on its Content tab: pull `edits` with ArtifactData,
  apply by hand, test, commit, republish, clear the documents.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (private to Ryan, from
  main's `forge.py phone`); picks and notes land in collection `picks`.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

## Where things stand

- The docs were rebuilt on 10 October: `docs/rules.md` is new and states the rules; the bible
  is decisions and why, 538 KB down to 133 KB; shown text in the vocabulary and two modules
  now matches the rules. Ryan reads `docs/rules.md` once, then a fresh session starts here.
- Built, waiting on Ryan's play: the 10 October weapon rules, the modules (harness only), the
  content revision's components, the domains and the plaque.
- Reports out of date: `docs/balance.md` and `docs/campaign_run.md` on this branch predate the
  weapon rules; rerun after the stock pass, with module rows.
- Decided, not built: the shared basic kit and its stock pass, tags on components, heat from
  foes only through debuffs, the Headhunter's successor on the Sparrowhawk. The bible's
  section 12 lists the questions only Ryan can settle.
- Known gaps: Rally's Kindled is +10 at once, so foes acting after the rallier hit above their
  shown intent; Jenny's foe-down lines are keyed by the retired families.

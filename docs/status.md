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

- `main` has everything since 10 October: the content revision, the modules, the 10 October
  weapon rules (no crits, two reaches, the die showing the number, the Paradox meter, Numbed
  the only resistance, the mirrored Booster and Databank, the Nemesis's Crucible), the first
  foe art at 72x96 and the rewritten docs. `ccr-abac8c0f-yig0e2` was fast-forwarded into it
  and has nothing main lacks; new work starts from main.
- `claude/ws-chassis-designs-wssq2u` (12 October): `docs/ws_chassis_proposal.md`, the third
  round of six Wainwright & Sutler passives for Ryan's silhouettes (two spiders, a chicken
  walker, two helicopters, a fan-boat). Ryan liked the boiler (now cooling -10), the
  multi-rotor (its look brief is written) and the stun punish at full; the cylinder takes his
  wording; the gunship and the fan-boat now read tags, waiting on his read; retired ideas at
  its foot. Bible v0.113 on this branch: Ryan's design notes of 12 October (a chassis identity
  opens build space; a map action buying a fight buff is no condition; every rule is open to
  debate; the decoy stays out) and the W&S row as simple and straightforward, suppression
  being Aphelion's; one line on debate in CLAUDE.md. Merge it so other sessions get the notes;
  nothing is in content.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them
by URL (read first). Databases are reachable only from the personal account. A page's link
goes into this file in the same commit as its first publish.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. Live: v0.125 (12 October), the parallel
  branches' v0.124 plus this branch's W&S row; no single file holds it yet (main v0.112, this
  branch v0.113), so the next publish starts from the live page.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s map (which leaves out `content/modules.json`: add it).
  Stale since 9 October. After Ryan edits on its Content tab: pull `edits` with ArtifactData,
  apply by hand, test, commit, republish, clear the documents.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (private to Ryan). Picks
  and notes land in collection `picks` (`{pick, note, set, at}` a set key): read them with
  ArtifactData `list`, cut each with `forge.py cut`, carry the notes into the touch-up task.
  Rebuild with `forge.py phone [--tags <experiment>]` and republish `tools/foeforge/out/phone/`
  (with its `renders/`) to that URL with `root` set; a republish keeps the picks.
  Every candidate's source render lives only in `tools/foeforge/out` on Ryan's Mac (git-ignored,
  about 150 MB; never delete it): cutting a new pick, rebuilding the page and rendering takes all
  need the Mac. A cloud session can read the picks and notes, but only picks already copied into
  `tools/foeforge/picks` can be cut from there.
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
- Foe art: every foe and hero is cut from Ryan's picks at 72x96 (massive 96x144, chibis 36x48),
  drawn on whole device pixels with a gentle sharpen; the style is fixed in words in the bible's
  enemy art row (painterly, small heads, battle poses, the prompt anchored on SNES Final Fantasy IV
  to VI). Ryan is picking on the phone picker (two notes in so far, on the Goblin); the takes pass
  for the other 23 waits on his go.
- Known gaps: Rally's Kindled is +10 at once, so foes acting after the rallier hit above their
  shown intent; Jenny's foe-down lines are keyed by the retired families.

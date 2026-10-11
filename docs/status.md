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
- Tests: 433 tests, 19,569 checks, green (11 October, on `claude/focused-ritchie-omn8i5`).
  A cloud session fetches Godot 4.7's Linux build from the GitHub release asset
  (`godotengine/godot-builds`, `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for
  screenshots, and builds models with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1`. Its first `--import` rewrites four Prairie Dog textures; restore them
  (`git checkout -- art/models/prairie_dog_*`) rather than commit them.

## Branches

- `main` has everything to 10 October: the content revision, the modules, the 10 October
  weapon rules (no crits, two reaches, the die showing the number, the Paradox meter, Numbed
  the only resistance, the mirrored Booster and Databank, the Nemesis's Crucible), the first
  foe art at 72x96 and the rewritten docs.
- `claude/focused-ritchie-omn8i5` (11 October) is main plus Ryan's calls of that day: the
  overheat at the end of the player's turn, armour off a breach's overflow, the Badger's
  hopper, the Stingray at tier one, the runner's `--rows` and `--module`, and the keyword
  line-up proposal. Merge it into main once Ryan has read the chat.

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

- 11 October (this branch): Ryan's answers to the open questions of the 10 October session,
  in chat. Built: the overheat burns at the end of the player's turn (a withdrawal too; a
  foe's heat waits on the gauge for the next turn), armour comes off a breach's overflow, the
  Badger's hopper (the claw fills a load a foe, the fragmenter fires three at +5: greedy 62 to
  69 on the lone Badger, random unchanged), the Stingray at tier one, the runner's `--rows` and
  `--module`. Measured, in the bible: the Faraday Hull's levers (the discharge is the larger),
  the Booster and the Databank even, danger close doing almost nothing, cracks (see the chat
  of 11 October). Proposed, waiting on Ryan: `docs/keyword_lineup.md`, the Nemesis's new locked
  fists, the Ram Frame's rule, the Sparrowhawk finisher's name, the Gravity Knuckles as a
  blueprint with an area effect.
- The docs were rebuilt on 10 October: `docs/rules.md` states the rules; the bible is
  decisions and why. Ryan reads `docs/rules.md` once, then a fresh session starts here.
- Built, waiting on Ryan's play: the 10 and 11 October rules, the modules (harness only), the
  content revision's components, the domains and the plaque.
- Reports out of date: `docs/balance.md` and `docs/campaign_run.md` predate the weapon rules;
  rerun after the stock pass. Scratch reads at 50 seeds (11 October) are in the bible's rows.
- Decided, not built: the shared basic kit and its stock pass (the twists with it), tags on
  components, heat from foes only through debuffs, the Headhunter's successor on the
  Sparrowhawk, the Gravity Knuckles as a blueprint. The bible's section 12 lists the
  questions only Ryan can settle.
- Foe art: every foe and hero is cut from Ryan's picks at 72x96 (massive 96x144, chibis 36x48),
  drawn on whole device pixels with a gentle sharpen; the style is fixed in words in the bible's
  enemy art row (painterly, small heads, battle poses, the prompt anchored on SNES Final Fantasy IV
  to VI). Ryan is picking on the phone picker (two notes in so far, on the Goblin); the takes pass
  for the other 23 waits on his go.
- Known gaps: Rally's Kindled is +10 at once, so foes acting after the rallier hit above their
  shown intent; Jenny's foe-down lines are keyed by the retired families.

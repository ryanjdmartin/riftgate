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
- Tests: 433 tests, 19,571 checks, green (12 October, on `claude/focused-ritchie-omn8i5`).
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
- `claude/focused-ritchie-omn8i5` (11 and 12 October) is main plus Ryan's calls of 11
  October: the overheat at the end of the player's turn, armour off a breach's overflow, the
  Badger's hopper, the Stingray at tier one, the Faraday Hull's discharge gone, the Pinion
  Driver, Devour a rule; the runner's `--rows`, `--module`, `--bump`, `--nopassive` and
  `--set`; the keyword line-up and the first prices. Merge it into main once Ryan has read
  the chat.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them
by URL (read first). Databases are reachable only from the personal account. A page's link
goes into this file in the same commit as its first publish.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change (v0.114, 12 October).
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

- 11 October (this branch): Ryan's answers to the 10 October session's questions, in three
  rounds of chat. Built: the overheat at the end of the player's turn (a withdrawal too,
  before the enemy's turn), armour off a breach's overflow, the Badger's hopper, the Stingray
  at tier one, the discharge gone, the Pinion Driver, Devour a rule. Decided, not built:
  danger close retires once the area keywords land; the foes' Breach and the Boar's spill
  share a word. Measured, in the bible: the Gravity Knuckles as a blueprint (a sidegrade
  elsewhere; four on the Nemesis its best build, which Burn would make simply best), area
  (the spread at half costs about three points, Penetrate matters only against formations,
  Chain is the Sparrowhawk's swarm answer), the Glacis front-only (no change), the Booster and
  the Databank (even, apart by matchup), injuries, and the first price of every stat and
  passive (armour 5 about 53 hull, damage 5 a blow about 60, shield 20 about 17, heat and
  cooling almost nothing; passives from 0 to about 200) and of twelve modules (the ruleless
  Ram Frame the best on every machine, the two "bad text" ones losses). Proposed, waiting on Ryan (the chat
  of 11 October, `docs/keyword_lineup.md`, the bible's section 12): area by shape, the overflow
  word (Breach), the Nemesis's fists answering the foe that last struck it (as reach), the
  knuckles without Burn, the Glacis as a brace on the plow's spend, what a tier means (and no
  rolled module stats), new rules for the Ram Frame and the Artillery Rangefinder, what the
  Assembly branch is.
- The docs were rebuilt on 10 October: `docs/rules.md` states the rules; the bible is
  decisions and why. Ryan reads `docs/rules.md` once, then a fresh session starts here.
- Built, waiting on Ryan's play: the 10 and 11 October rules, the modules (harness only), the
  content revision's components, the domains and the plaque.
- Reports out of date: `docs/balance.md` and `docs/campaign_run.md` predate the weapon rules;
  rerun after the stock pass. Scratch reads at 50 seeds (11 October) are in the bible's rows.
- Decided, not built: the shared basic kit and its stock pass (the twists with it), tags on
  components, heat from foes only through debuffs, the Pinion Driver locked on the
  Sparrowhawk, the Gravity Knuckles as a blueprint, danger close retired with the area
  keywords. The bible's section 12 lists the
  questions only Ryan can settle.
- Foe art: every foe and hero is cut from Ryan's picks at 72x96 (massive 96x144, chibis 36x48),
  drawn on whole device pixels with a gentle sharpen; the style is fixed in words in the bible's
  enemy art row (painterly, small heads, battle poses, the prompt anchored on SNES Final Fantasy IV
  to VI). Ryan is picking on the phone picker (two notes in so far, on the Goblin); the takes pass
  for the other 23 waits on his go.
- Known gaps: Rally's Kindled is +10 at once, so foes acting after the rallier hit above their
  shown intent; Jenny's foe-down lines are keyed by the retired families.

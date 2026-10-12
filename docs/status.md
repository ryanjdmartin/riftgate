# Status

How things stand, for the next session. Keep it under a screen and replace stale lines;
history lives in git. The rules are `docs/rules.md`, the why is the bible
(`docs/design-bible.html`), the next tasks are `docs/todo.md`, the layout and every
command are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, this file and `docs/todo.md`. If a chat and a file
  disagree, the chat is newer.
- Ryan's next step (12 October): a fresh session evaluates every maker's proposed chassis as
  one batch, and nothing is built before it. Where each proposal lives is under Proposals below.
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
- Since 12 October `main` also carries the Arsenal's proposals (`docs/arsenal_proposal.md`,
  fast-forwarded from `ccr-baf790be-gootfd`) and the bible as published (v0.126), which runs
  ahead of main's code. It records work built on `claude/focused-ritchie-omn8i5` and not yet
  merged: the overheat at the end of the player's turn, armour off a breach's overflow, the
  Badger's hopper, the Stingray at tier one, the shock's discharge gone, the Pinion Driver
  named, Devour a printed rule, the modules priced, Braced for one turn, the plow's brace, the
  Deflector's Rapid and the Condenser's Volatile, the Nemesis's rage and the Knuckle of Fury,
  the keyword line-up and the runner's `--rows` and `--module`. Main's `docs/rules.md`, content
  and code predate all of it. `ccr-550650c0-g0kcbg` shares that branch's history to 12 October
  and adds Aphelion's calls, which are in the bible already. Merging either brings its code;
  its bible resolves to the live page, which holds every session's rows.

## Proposals

For the batch evaluation (Ryan, 12 October). Each is a pitch; nothing in them is in content.

- The Arsenal: `docs/arsenal_proposal.md` on main (Misharu, Mastema, Minos, the Onryō, and a
  cleanse that moves debuffs onto a foe).
- Wainwright & Sutler: `docs/ws_chassis_proposal.md` on `claude/ws-chassis-designs-wssq2u`
  (six silhouettes, the third round of 12 October).
- Minerva: `docs/minerva_chassis_proposal.md` on `claude/minerva-chassis-candidates-po893q`
  (four candidates, 11 October).
- Kestrel: `docs/canvas/kestrel-airframes.html` on `ccr-1a6d0a75-y2oqy8` (five airframes,
  11 October).
- Aphelion: in chat only, per the bible's row "Aphelion's next chassis"; to be written down
  before the evaluation.
- The keyword line-up (`docs/keyword_lineup.md` on `claude/focused-ritchie-omn8i5`), which
  several of the chassis lean on.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them
by URL (read first). Databases are reachable only from the personal account. A page's link
goes into this file in the same commit as its first publish.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change (v0.126).
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
- The Arsenal (12 October, bible v0.126): the occult is the Council's; its machines are twisted
  by it, never merged (mechanical, CARE-piloted, no mind of their own); grimdark is playing it
  straight; demonic in look, liturgical in word; a passive may break a rule as a one-off;
  retribution is the Arsenal's, thorns allowed with a drawback and never on a megatank; the
  rule-text budget counts the chassis's description, never its components. Four chassis are
  proposed in full in `docs/arsenal_proposal.md`, written for the batch evaluation: Misharu (a
  shield's breaker is Suppressed), Mastema (Burning passes from the dead; the Chrism Ewer
  doubles a foe's Burning, the Votive Ward shields 10 for each Burning foe), Minos (every foe it
  hits changes rank) and the Onryō (a Grudge on whoever wounds the team, never cashed in,
  outliving it; the Pall its guard). Ryan's last note: a cleanse that moves the team's debuffs
  onto a foe, which waits on the words the two sides share (none today). Nothing is built.
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

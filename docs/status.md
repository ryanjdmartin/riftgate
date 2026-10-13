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
- Tests: 441 tests, 19,633 checks, green (13 October, on `claude/focused-ritchie-omn8i5`).
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
  Driver, Devour a rule; and of 12 October: the plow's brace, Braced one turn, the two twists,
  the Nemesis's rage and its new fists; the runner's `--rows`, `--module`, `--bump`,
  `--nopassive` and `--set`; the keyword line-up and the first prices. Merge it into main once
  Ryan has read the chat.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them
by URL (read first). Databases are reachable only from the personal account. A page's link
goes into this file in the same commit as its first publish.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. Live: v0.129 (13 October), which is this
  branch's file plus other sessions' rows: the Aphelion calls of 12 October on
  `ccr-550650c0-g0kcbg` (built on this branch), and on `ccr-baf790be-gootfd` the Arsenal's
  tone and next chassis (`docs/arsenal_proposal.md`), retribution as the Arsenal's and thorns
  needing a drawback, the Armadillo's retaliation in question, Hellfire pinned, two design
  tests (a map action that buys a buff is no condition; every rule is open to debate), a
  chassis's identity opening build space, a passive breaking a rule as a one-off, the cars'
  decoy line; since then (another session, 12 and 13 October) the rule-text budget, makers'
  keywords as leanings, the Deflector's and the Condenser's lead, the Arsenal cleanse that
  moves debuffs, Wainwright & Sutler's next chassis (`docs/ws_chassis_proposal.md`) and
  what shown text calls the die. The live copy also says Burning is the first debuff both
  sides share, in those sessions' buffs-and-debuffs and Arsenal rows. Merge the branches
  before republishing from any; until then, publish a three-way merge onto the live version
  after reading it.
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

- 11 and 12 October (this branch): Ryan's answers to the 10 October session's questions, in
  four rounds of chat. Built: the overheat at the end of the player's turn (a withdrawal too),
  armour off a breach's overflow, the Badger's hopper, the Stingray at tier one, the discharge
  gone, the Pinion Driver, Devour a rule; 12 October: the Breaching Plow braces the Boar (the
  Glacis gone), Braced one turn from every source, the Laminar Deflector rapid 20 and the
  Entropy Condenser volatile 40, the runner's `--bump`, `--nopassive` and `--set`. Decided,
  not built: danger close retires once the area keywords land; tiers (a chassis's
  complexity, a component's power, modules flat); no hard guard against a build. Measured,
  in the bible: prices for every stat, passive and twelve modules; shields stopping a whole
  blow is not why fights are easy (one point), three machines against one pack is; injuries
  in one state at half the hull keep today's losses. Proposed, waiting on Ryan (the chat of
  12 October, `docs/keyword_lineup.md`, the bible's section 12): the three area shapes with
  one half rule, the Boar's spill dropped, the Badger's identity, the Nemesis's rage and
  release, a blueprint bolts on, injuries in one state, modules as priced bundles, roster
  turnover, the Rangefinder's and the Ram Frame's rules. Later on 12 October (Ryan): the Boar
  keeps its spill, written out; a component is balanced against its tier, a chassis alone is a
  diagnostic; keywords against written-out effects wait on the content lock; injuries shelved
  for an economy session; modules as bundles open. Tested: the area set (Splash folds into
  Spread and Penetrate, the firer's price no lever; the plus swings the formations), lower
  armour (teams barely move). Last on 12 October (Ryan): hands tabled and Melee kept; the
  Boar's spill no keyword (the star proposed); the basics are tier zero, 7 October's call
  that the 11 October rewrite of the bible had dropped, restored; a chassis stocks only below
  its own tier, a bought one bringing its stock and never the blueprints, tier three the
  unique effects and raw power, tier two the synergy pieces; direct heat from foes retired
  for the two debuffs. Built: the Nemesis's rage (all hull damage banks it; new locked fists,
  the Knuckle of Fury, spend one and the die rolls again, a plain roll with no switch-off).
  13 October (Ryan): the fists keep their name and lose Burn (the Nemesis alone 44/67, the
  fists at 25 restore 52/81); rage by damage taken measured and not worth it; the gravity
  piece shelved; the rage's roll again shown (the chip bursts, the die flips with the
  reroll's sound; `RIFTGATE_RAGE_DEBUG=1`); Burn and Scorch decided and built, foes heating
  machines only through Burning (at the end of the player's turn, before the overheat) and
  Scorched (every weapon hotter for the turn, every stack going at its end, since a stack a
  turn piled up under several scorchers); teams unmoved, machines overheating far less, the
  Goshawk (heat into shield) the one that loses; the die's heat shows every modifier. Open:
  Burning's glyph on a machine.
- The docs were rebuilt on 10 October: `docs/rules.md` states the rules; the bible is
  decisions and why. Ryan reads `docs/rules.md` once, then a fresh session starts here.
- Built, waiting on Ryan's play: the 10 and 11 October rules, the modules (harness only), the
  content revision's components, the domains and the plaque.
- Reports out of date: `docs/balance.md` and `docs/campaign_run.md` predate the weapon rules;
  rerun after the stock pass. Scratch reads at 50 seeds (11 October) are in the bible's rows.
- Decided, not built: the shared basic kit and its stock pass (the twists with it), tags on
  components, the basics at tier zero and stock below a chassis's tier, the Pinion Driver
  locked on the Sparrowhawk, danger close retired with the area keywords. The bible's section
  12 lists the questions only Ryan can settle.
- Foe art: every foe and hero is cut from Ryan's picks at 72x96 (massive 96x144, chibis 36x48),
  drawn on whole device pixels with a gentle sharpen; the style is fixed in words in the bible's
  enemy art row (painterly, small heads, battle poses, the prompt anchored on SNES Final Fantasy IV
  to VI). Ryan is picking on the phone picker (two notes in so far, on the Goblin); the takes pass
  for the other 23 waits on his go.
- Known gaps: Rally's Kindled is +10 at once, so foes acting after the rallier hit above their
  shown intent; Jenny's foe-down lines are keyed by the retired families.

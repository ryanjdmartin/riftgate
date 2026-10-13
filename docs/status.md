# Status

How things stand, for the next session: facts and the state as left, with the next steps. Keep
it short and replace stale lines; history lives in git. The rules are `docs/rules.md`, the why
is the bible (`docs/design-bible.html`; section 12 is the roadmap and the questions only Ryan
can settle), the tasks are `docs/todo.md`, the layout and every command are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, this file and `docs/todo.md`. If a chat and a file
  disagree, the chat is newer.
- Sessions run in parallel on this repo: `git status` first, stage by path, diff a shared
  file before staging it, never a bare `git add -A`, never kill a bare `godot --path .`.
- Tests: 442 tests, 19,636 checks, green on main (13 October). A cloud session fetches Godot
  4.7's Linux build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots, and builds models
  with `BPY_PYTHON` set to a python3.11 venv holding `bpy==5.0.1`. Its first `--import`
  rewrites four Prairie Dog textures; restore them (`git checkout -- art/models/prairie_dog_*`)
  rather than commit them.

## Branches

- `main` holds everything decided and built to 13 October, including all of
  `claude/focused-ritchie-omn8i5` and `ccr-baf790be-gootfd` (merged 13 October). New work
  starts from main.
- Not merged, by Ryan's word (13 October: work in progress, leave them): the chassis
  proposals for the batch evaluation, on `claude/ws-chassis-designs-wssq2u` (Wainwright &
  Sutler, `docs/ws_chassis_proposal.md`), `claude/minerva-chassis-candidates-po893q`
  (`docs/minerva_chassis_proposal.md`) and `ccr-1a6d0a75-y2oqy8` (Kestrel,
  `docs/canvas/kestrel-airframes.html`); the Arsenal's is `docs/arsenal_proposal.md` on main;
  Aphelion's exist in chat only. `ccr-550650c0-g0kcbg` has two bible-only commits whose rows
  are already in the bible. The batch evaluation is Ryan's to start; the Honey Badger's
  identity and the Armadillo's Faraday Hull fold into it (Ryan, 13 October).
- One rule decided on the Wainwright & Sutler branch is on main: the fives and tens are
  magnitudes, not steps (Ryan, 13 October; its commit 630c651's text in the rules, the
  content notes, the README, the vocabulary and the to-do). The rest of that branch is the
  proposal.

## The game as left (13 October)

- Built and tested: the battle (the round, orders, fights by ring and range, hunters, five
  map types, Rift Pressure without escalation, the boss after its reveal); the skirmish as
  `docs/rules.md` states it; the campaign's rules headless only (`sim/campaign.gd`, no screens);
  the balance runner (`tools/balance.gd`: `--rows`, `--module`, `--bump`, `--nopassive`,
  `--set`, `--trace`), the campaign runner and the map survey; every ally model by lowforge
  with acts and gaits; the first foe art; six tracks, the effects and Jenny's lines.
- The skirmish's latest rules, all built: the overheat burns at the end of the player's turn;
  armour comes off a breach's overflow; Braced lasts until the round's end; the Nemesis banks
  a rage on any hull damage and its locked Knuckle of Fury (15 flat, 10 heat) spends one to roll
  its die again; foes heat machines only through two debuffs: Burning (+5 heat a stack at the
  end of the player's turn, before the overheat, then a stack goes) and Scorched (every weapon
  the machine fires runs 5 hotter a stack until the end of the player's turn, when every stack
  goes); the Drake's Stoke sets the hottest machine burning ×2, Eruption, Fira and Hellfire
  scorch every machine ×2, the four scorching blows leave Scorched; a foe attack keyword
  `burn` exists, unused; the die's heat shows what a spend adds through every modifier (heat
  reads adds before multiplies, so the Sparrowhawk's double doubles Scorched's extra).
- Content: five makers, 13 chassis, 54 components (12 locked, 4 unstocked, among them the
  shelved Gravity Knuckles at tier three), 16 modules, four domains with 18 wildlife and
  bosses and 8 heroes; 8 foe moves still `planned`. Every number is a placeholder; any whole
  number may be used (the scales are magnitudes), move alone in steps of 5.
- Debug switches added on 12 and 13 October: `RIFTGATE_RAGE_DEBUG=1` (the rage's roll again);
  screenshot poses `rage` and `heat` (`tools/screenshot.gd`).
- Measurements: every number quoted in a decision is in its bible row. `docs/balance.md` and
  `docs/campaign_run.md` predate the 10 October weapon rules.
- Foe art: every foe and hero is cut from Ryan's picks at 72x96 (massive 96x144, chibis 36x48).
  On 10 October Ryan retired the original candidate sets (rendered before the style rules):
  every wildlife foe now has four battle-pose takes on the picker (`takesE`; the Goblin and the
  Revenant beside their 9 October takes, the Cockatrice with its 9 October takes alone), the
  heroes keep their chibi and boss sets. Next: Ryan picks from the takes, a session cuts each.
- Known gaps: Rally (below); Jenny's foe-down lines are keyed by the retired families.

## Decided, not built

- The stock pass: tags on every component (the working set Ballistic, Missile, Beam, Plasma,
  Flame, Arc, Blade, Melee), the shared basic kit at tier zero (every basic's blueprint owned
  from a run's start), the old close weapons brought to Direct's band, the Pinion Driver
  locked on the Sparrowhawk, the Baboon free to stock a shield, every tier-one chassis on
  basics beside its locked piece, each component's tier in its entry and every chassis
  stocking only below its own tier, a bought chassis bringing copies of its stock and never
  the blueprints.
- Danger close retires and area belongs to keywords on any reach (the Artillery Rangefinder
  needs a new rule). Which keywords is the open bible row "Area by shape": Ryan's condition
  for folding Splash into Spread and Penetrate (no price on the firer) measured true on 12
  October.
- A dispel keyword for the foes' buffs (its name, carriers and numbers open).

## Next, in order

1. Rally to its shown intent (engine, no decision pending). Today a foe's `rally` move (the
   Magma Golem's Stoke the Forge, value 10; the Wolf's Howl, value 5) grants every other foe
   Kindled at once (`Effects.STATUS["kindled"]`, a fixed +10 attack, through the next round),
   so foes striking after the rallier in the same enemy turn hit 10 above the intent they show,
   and the Howl gives 10, not 5. The fix in the to-do: Kindled carries its move's value and goes
   live from the next round, when intents are drawn with it.
2. The stock pass (above), once Ryan settles the content questions it needs: the basic kit's
   names, makers and numbers, and the Prairie Dog's basic shield (the bible's section 12).
3. The balance runner's module rows (a fitted cell beside the stock one), then
   `tools/balance.gd` at 200 seeds and `tools/campaign_run.gd` on the four domains, refreshing
   both reports.
4. Ryan's play and phone reads of the 10 to 13 October builds (the to-do's Ryan list).
5. The rest of the bible's section 12 order: Ryan's text, the domains' engine, the
   discuss-first questions, battery, audio, screens, art, the commander layer, the economy,
   onboarding. Section 12 holds 23 open questions for Ryan.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them
by URL (read first). Databases are reachable only from the personal account. A page's link
goes into this file in the same commit as its first publish.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. Live: v0.137 (13 October), the committed file
  as it stands on main; it also holds rows from branches not yet merged (Aphelion's
  calls, Wainwright & Sutler's next chassis, what shown text calls the die). Before
  republishing, read the live page; if another session moved it, publish a three-way merge
  onto it.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map (run it, then publish the page with that map).
  Republished 13 October from main's content. Its database (Ryan's saved edits, collection
  `edits`; name candidates, `candidates`) opens only from the personal account and was not
  read on 13 October. After Ryan edits on its Content tab: pull `edits` with ArtifactData,
  apply by hand, test, commit, republish, clear the documents.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor). Picks and notes land in collection `picks` (`{pick, note, set, at}` a set key):
  read them with ArtifactData `list` from the personal account. The work account cannot read
  the page's data even shared, so there Ryan taps Copy all picks (every stored pick and note,
  sets since taken off the page included) and pastes it. Cut each with `forge.py cut`, carry
  the notes into the touch-up task. Rebuild with `forge.py phone --tags takesD takesE
  --drop-originals` and republish `tools/foeforge/out/phone/index.html` to that URL with `root`
  set, its new `renders/` in `files` and a dropped set's renders as null; a republish keeps the picks.
  Every candidate's source render lives only in `tools/foeforge/out` on Ryan's Mac (git-ignored,
  about 150 MB; never delete it): cutting a new pick, rebuilding the page and rendering takes all
  need the Mac. A cloud session can read the picks and notes, but only picks already copied into
  `tools/foeforge/picks` can be cut from there.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

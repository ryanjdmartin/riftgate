# Status

How things stand, for the next session, and the order of work. Facts and the state as left;
history lives in git (the long form of this file to 4 November: `git show 1fa1155:docs/status.md`;
its changelog to 23 October: `git show 9bec2ba:docs/status.md`). The rules are `docs/rules.md`;
the why and the questions only Ryan can settle are the bible (`docs/design-bible.html`, its
first row first); the tasks are `docs/todo.md`; every run a decision cites is
`docs/measurements.md`; the layout, every document's job and every command are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row, this file and `docs/todo.md`. If a
  chat and a file disagree, the chat is newer.
- Sessions run in parallel on this repo: `git status` first, stage by path, diff a shared file
  before staging it, never a bare `git add -A`, never kill a bare `godot --path .`. A branch
  takes main as it lands and main takes the branch as a fast-forward on Ryan's word; expect the
  bible's live page to have moved (read it, merge, republish: Pages, below).
- The desk machine is a Windows PC (`C:\Users\jam82\Desktop\Code\riftgate`; the README's
  Running section says what is set up there). It draws with the phone's renderer
  (gl_compatibility, the project's setting), so a lit part's colour there is the phone's. The
  Mac is out of reach and what it held outside git is gone: of the foeforge renders only the
  Augur's survive (`tools/foeforge/out/`, for her next pass; the rest `git show fb45141`), and
  foeforge's `generate` and `fix` have no machine until a route for the image model is chosen:
  Ryan is trying the Windows PC first with a GTX 980 of his to go in (10 November), the cloud routes researched and parked (the
  to-do's Art line).
- Godot: the project runs 4.8-beta2 (published 29 October), the newest build at the last check,
  7 November (nothing newer on github.com/godotengine/godot-builds/releases); 4.8 stable is not
  out. The next check is due 21 November (`CLAUDE.md`, Session handoff); date this line again
  after each.
- Tests: 1094 tests, 325,124 checks, green on main (10 November, with the boss's hex, the third map list, the Text tab, the side session's work, the shapes reworked on Ryan's play, the second map list, the
  map session's shapes laid to the rift's row, the passing and the catch at one, and the map
  playtest list), and 1111 tests, 362,582 checks, green on `ccr-722ca9f0-yj8na3` (11 November, that
  main with the refit pass's first build, the wall strike by the rating, the trial's regen row,
  every machine one more move, the field's dials, the goblin's line on its straight knife and wall,
  the model as content, the formation pass and the elites' and bosses' guess; the
  map suite now paints fourteen and sixteen deep too, which is most of the checks' rise); one
  SCRIPT ERROR in every run's log is the runner's own test, raised on purpose; Godot 4.8-beta2;
  either map view on 6 November; about four minutes in a cloud session, twenty on a slow one;
  words after `--` run only the files whose names hold one (`-- loot rig`). A cloud
  container whose import predates a branch's new `class_name` fails the screen and rig suites
  with a parse error ("MuzzleFlare" not declared): run `--import` again first.
- A cloud session gets Godot and the first import from the repository's session-start hook
  (`.claude/hooks/session-start.sh`, registered in `.claude/settings.json`: the release asset
  `Godot_v4.8-beta2_linux.x86_64.zip` from `godotengine/godot-builds` into `~/bin`; without the
  hook, fetch it in one command and unpack and run it in another, since Auto mode refuses one
  line that fetches and runs). Screenshots there need `xvfb-run -a` and
  `--rendering-method gl_compatibility` (Mesa's llvmpipe: draw calls are true counts, frame
  times mean nothing). The hook imports only a checkout with no `.godot`, so a container that
  cached one keeps its old import: tests failing on a class name not declared (`MuzzleFlare`)
  mean run `--import` first (about fifteen seconds; 7 November). Models build with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1` (about twenty minutes to install). The first `--import` may rewrite four Prairie
  Dog textures and a model build the maker's review tiles: restore both
  (`git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`) rather than commit them.

## Branches

Everything is on main as of 10 November 2026 but the formation and refit session's branch and
the music session's, both below.
`ccr-c71bc17f-hclj2c`, Ryan's map playtest list of 10 November, his answers to it and his second
and third map lists the same day (How things stand below), cut from main at `aa40832`, landed on
main as fast-forwards on his word each time ("Ok, merge this into main so I can try it"; "yeah,
merge into main"; "Ok, merge to main"; "Yeah that will do. Merge into main"): the first after taking
the map session's main in a merge
(the shapes laid to the rift's row, no body blocking, the catch at one: the bible, the rules, this
file and `game/battle/bleed.gd` the conflicts, both sides kept, the bible's version main's plus
one), the second after taking the shapes' rework (this file the one conflict), the third and the
fourth (the boss's hex) with main unmoved; it is merged and to delete with the rest (the formation and refit session meets its
edits in `game/battle/battle_map_view.gd`, `game/battle/battle_screen.gd`, `sim/battle.gd`,
`sim/battle_map.gd`, `sim/save.gd`'s versions (the battle's 22, the run's 21), the bible and these
records when it takes main).
`ccr-df879779-uf9076`, the side session of 9 and 10 November (How things stand below: the test
runner's crash check, the caches' pictures, the screen's half of the audit's mirrors, the enemy
art routes parked), took main's Text tab in a merge (this file and the README the conflicts, both
sides' words kept: the two sessions' entries, the bible's line with the live v0.497 and main's
v0.498, the hangar's with versions 217 and 218 each named) and main took it as a fast-forward on
Ryan's word ("Merge everything into main and clean up"); it is merged and to delete with the rest.
`ccr-7d7ed303-tbdkg4`, the hangar's Text tab of 10 November (How things stand below), landed on
main as a fast-forward on Ryan's word ("Ok merge into main please"); it is merged and to delete
with the rest.
`claude/hangar-bench`, the hangar's Bench tab (10 November, cut from main on Ryan's word, "Yes,
start a fresh branch off main for it", so it landed ahead of the refit's branch), is on main as a
fast-forward on his word ("Ok merge into main and republish the hangar"); it is merged and to
delete with the rest.
`claude/modest-ramanujan-uovd42`, the Polar Bear's kit of 9 November, its id's rename and every id
following its name (How things stand below), landed on main as fast-forwards on Ryan's word ("merge
it into main so I can try it"; "clean up and merge into main"); it is merged and to delete with the rest.
`claude/playtesting-ui-feedback-hfdiok`, Ryan's playtest list of 9 November (How things stand
below), took main's map session and skirmish audit step 3 in a merge (the bible, the measurements
and this file the conflicts, both sides' words kept) and main took it as a fast-forward on Ryan's
word ("Ok clean up and merge into main"); it is merged and to delete with the rest. `ccr-1e6e6571-7x7ayr`,
the map session of 9 November (the shapes relaid and recast, How things stand below), took main's
skirmish audit step 3 as it landed and main took it as a fast-forward on Ryan's word ("push this
into main, so I can try it"), then again on 10 November with the shapes laid to the rift's row,
the passing and the catch at one ("put this in main so I can try it in context"), and a third
time that evening with the shapes reworked on his play, the 3D roads and the painted walls ("put
this in main so I can try it"); it is merged and to delete with the rest. The
branches that landed on 3 to 9 November, each a session of its own, fully merged and to delete
from GitHub and the desk machine (the command is in the audit's last chat;
`git push origin --delete` the merged ones, then `git fetch --prune`):
`ccr-d26a1321-xg9xge` (a hunter's reach, below: a composition saying whether it hunts, the rings
purged, a hunter's ring drawn; main took it as a fast-forward on Ryan's word of 9 November,
"merge this into main"), `ccr-1eaf0060-jrpw04` (the spend's order and Sweep's columns of 7 November, the Skua's base
halving, every shot seen to land, the Swap in the rider phase; main took it as a fast-forward
on Ryan's word, "Push this to main"; again on 8 November with the skirmish code audit, below), `claude/aphelion-minerva-chassis-9qf6cy` (Ryan's chassis session of 4 and 5 November: his ideas
and Claude's first round, a brief each in `docs/briefs/` with a header the hangar reads, the
briefs README's "Ten a maker" and "Orbits", the proposal retired,
`git show a228545:docs/aphelion_minerva_chassis_proposal.md`; the work account scrapped
everywhere, Ryan: the personal account is the only one; the hangar's Designs tab, whose marks a
design session folds in first, the briefs README's How a session runs; main took it as a
fast-forward on his word, "Clean up and merge into main"), `claude/inspiring-mendel-hkp5na` (the
audit of 4 November: the records trimmed, the bible's contradictions settled, Ryan's two speedrounds, three engine fixes, main
taken as it landed, and main took it as a fast-forward that evening on his word, "Ok, clean up
and merge into main"), `ccr-bb178c9b-l6airv` (the playtest list of 2 November and the die's marks; landed a
second time that evening with Every Foe, Every Ally and Every Other Ally as targeting modes and
Sweep's lobbed mark, Ryan: "ok, this is fine. Clean up and merge into main"),
`claude/elites-session`, `claude/charming-rubin-h954bp` (the models' motion, weapon fire and
micro-models), `ccr-c04908be-3r43xf` (the randomness pass; the pricing run and heat brief
before it), `claude/chassis-runner-rows`, `ccr-7effd31a-u5z4gw` (the pairs),
`claude/affectionate-ramanujan-5d24t6` (the Petrels, the Honey Badger's hopper, the Wainwright
& Sutler models), and the earlier `claude/zealous-wright-ixxo3l`, `claude/jolly-lovelace-scn82y`,
`claude/brave-cori-fr18de`, `ccr-7821127e-kwj874`, `ccr-24cae16e-ryhv1v`, `ccr-6073bda9-p34o8q`,
`ccr-7d865127-wr1ko2`, `ccr-170f6d81-465jnr`, `claude/quick-campaign-mode-pafhiv`,
`claude/affectionate-goldberg-8e3mkh`, `claude/playtesting-issues-08mnqj`, `ccr-535a7596-5ptzsj`,
`claude/eager-newton-sf947u` and `claude/friendly-cannon-kyk9v4` (a cloud session may not delete
one). Each merge commit says how its conflicts were settled.

Still working (10 November; every other branch on GitHub is merged): `ccr-722ca9f0-yj8na3`, the
formation pass and the refit pass's opening (the proposal `docs/formation_proposal.md`, the
brief `docs/briefs/refit_pass.md` and the briefs it sends machines back to; the curve read's
`--team`, `--tiers`, `--sizes`, `--domains` and `--ids`, its rounds and stalls; the formation
pass's reads in `docs/measurements.md`, 9 November, taken before it took main; and the refit
pass's first build and reads, below: the injury rule off in the game, the model as a what-if
and a trial, the fight bot's aggressor habit; and in `content/`, all of 10 November on his
words: every chassis's move, one more; the refit pass's model (the stock dice, a regen by
chassis, the basics, the drafts and four machines undealt); the goblin's line and the Marsh's;
thirteen new foes (the Draugr and four flanker lines); the formation pass's patrols and
formations in place of the old; the elites' and the bosses' numbers, a guess; and the Gate
Integrity entry's strike). It took main at
`2d489f7` on 9 November (Ryan: "merge main in here so that you're working on the latest engine
and changes"): the bible, the measurements, this file and the to-do the conflicts, both sides'
words kept (the bible's hunters row this branch's and its boss row main's, the measurements'
sections main's four and then this branch's, the to-do's lines each by the side that moved it),
and the proposal's tool following the one foe id it named that main renamed (`magma_elemental`).
It took main again at `e67645f` on 10 November (Ryan: "can you pull main in first? Some
complimentary side work went in that I want to look at in parallel": the map session's shapes
laid to the rift's row, no body blocking and the catch at one, the map playtest list, the
hangar's Text tab, the caches' pictures, the test runner's crash check): the bible, the
measurements, this file, the to-do, `tests/run_tests.gd` and `tests/test_battle_screen.gd` the
conflicts, both sides kept (the runner resets the injury switch and counts script errors; each
side's new screen tests stand; the bible's wall row this branch's strike with main's field
words, its version above both; the measurements' sections main's and then this branch's by
date; this file's entries each side's), and the engine merged by itself, the wall strike by the
rating beside main's walking with no body blocking. Two campaign tests' scene was thinned to
one patrol: with the strike by rating and the packs walking straight to the wall, the horde
takes a city gate's whole 200 in the six unopposed phases after a wipe at a quiet start (160
by head count), so the gate they need standing fell. `docs/vocabulary.md` and
`docs/campaign_run.md` were made again on the merged tree.
It took main once more at `fda02f9` that evening (the shapes reworked on his play and the
hangar's Bench tab, so his map points are answered on the latest map code): the bible's version,
this file's tests line and the measurements' order the conflicts, both sides kept.
And again at `a3b48c0` before the re-deal and the formation pass began (Ryan: "Make sure main is
in here first before you begin": his second map list of 10 November, the stores' cells, the
BLOCKED tag): the bible (its version above both, v0.509; the three clocks row this branch's,
the names row main's, the Armoured table row rewritten from content by its tool), this file and
the to-do the conflicts, both sides kept; `docs/vocabulary.md` made again.
And at `944cd5e` as the formation pass and the elites' guess closed (his third map list of 10
November: the rift's five hexes, the order's own undo, the planned route drawn again): the
bible (its version above both, v0.513; the grid row both sides' sentences, the wall row this
branch's), this file, the to-do and `sim/save.gd` the conflicts, both sides kept, the save
versions stacked (a battle's 22, a run's 21, the model's landing and then the rift's five
hexes with the formation pass's compositions; a quick run's 6 for the compositions).
And at `5d14088` on 11 November (the boss holding its hex in front of the rift, never
walking): the bible (v0.514, above both; the grid row main's sentences on the boss's hex set
into this branch's), this file, the to-do and `sim/save.gd` the conflicts, both sides kept, the
save versions stacked again (a battle's 23, a run's 22).
The bible's file is v0.519 (with `ccr-4d58b054-3lyj0a`'s locked row, tiers row and basic kit row of 10 November and its Polar Bear, Buzzard and Nemesis rows of 11 November), main's v0.506 with this branch's rows, its republish on Ryan's word
(Pages below); and `ccr-7effd31a-u5z4gw`, the
music session (Night Shift's and The Far Bank's rounds on the pair page), whose bible rows land
on the live page ahead of its branch, so a republish merges onto the live page (Pages). Landed
9 November: `ccr-a0b35006-od22d2`, the Lammergeier's rework (How things stand), on Ryan's word
("Merge this into main. Your reads are correct"), main taken as it landed twice (the Polar Bear,
then every renamed id: the save versions stacked, battles 20, runs 19 and quick runs 4; the
bible, the measurements, this file, the to-do and the synergy map the conflicts, both sides kept,
the generated tables, map and vocabulary run again) and main taking it as a fast-forward; it is merged and to delete with the rest. Landed
9 November: `ccr-8df9952c-4cccdf`, the skirmish code audit's step 3 (How things stand: one hit
routine, the hidden flags gone, one round model, the behaviour trace), on Ryan's word ("Ok, merge
into main"), main taken as it landed (the hunt and the rings, no conflict) and main taking it as
a fast-forward. Landed
8 November: `ccr-56b5169d-lsa2rg`, Ryan's redesign of 5 November (the battle as the defence of a
long wall, the packs as designed formations, the shield the fight's resource: his direction and
Claude's first round as `git show 68381ff:docs/long_wall_proposal.md`, the build brief
`git show 68381ff:docs/briefs/long_wall_build.md`; Phases 1 and 2, the reinforcement cut, the field's loot, the
harness's two tabs, the quick campaign on one code tree, the ramp gate, the compositions as grids
and his audit of 8 November, How things stand below). It took main's spend's order of 7 November
as it landed: in `sim/skirmish.gd`'s kill code main's queued split and the long wall's regrowing
corpse both stand, and the rules' massive-foe and kill lines carry both sides. Its saves are the
battle's 15 and the run's 14, so a battle saved before is refused. Then `ccr-1eaf0060-jrpw04`
again, the skirmish code audit (`docs/skirmish_audit.md`) and Ryan's answers to it (one kill at
the death check; a Sweep's shots judged each and queued as the spend begins, a pair's halves a
spot each; the Nob's rage its own from the start; Scorched on the bar, never the ammo or the
Petrel's shield; the enemy's turn's death check; a countdown shown at the fight as it stands; a
stack is a stack under a Purge, and Abilities, a unit's own mechanic, on a chip of their own that
no purge touches; Guarded, spills, rerolls and shown text), on his word ("If there's nothing else
open, clean up and merge into main"). It took the long wall's main first: the one kill tally
stands in place of the long wall's `came_with` (a foe that cannot stand is never counted, so
nothing is taken back), withdrawal stays gone (the audit's fix to it went with it), and the
rerolls row is the long wall's two with the audit's kept rolls.

## The design sessions

Each resumes from its brief; `docs/briefs/README.md`'s table says what each waits on.

- The inventory of 9 November (every chassis, built or briefed, with its state): 24 built, 23 in
  briefs, three slots open. Of the built, four went back to design with the refit pass and three
  are there still (the Whip Scorpion whole, the Swallowtail, the Puffin; a brief each), three are
  unfinished by Ryan's own notes (the Needletail, the Giant Petrel, the Musk Ox) and the rest
  stand. The to-do's roster is grouped by what each waits on, in the order he took (Next, in
  order, item 1).
- Ryan's round on the busted machines, 11 November (this branch): the Polar Bear dealt again,
  equipment it spends on itself sealing it and a weapon it fires opening it, its lure neutral
  (his words; the armour kept for his play, a regen seal his first change), the brief retired;
  the Buzzard's Thermal Recoupler made shield regen, read where every machine's regen is (his
  word, on its base regen of one). His directions are at each brief's head: the Whip Scorpion's
  role first, from a role map of the roster; the Swallowtail punted until its niche is carved;
  the Puffin a heat mover, tier two his lean; and two reworks with briefs of their own, still
  dealt: the Storm Petrel (shield as it gains heat, after the heat pass) and the Nemesis (a rage
  bar that breaches, a tank buster). The Ammit's stock wants a Ward piece (the to-do). The holes
  raised on each are in its brief with his answers of the same day (the Puffin's dump allies
  only; the Petrel's hook from any source, its zap a piece that spends shield into a blow; the
  Nemesis's blow on shield and hull two, its rage spent automatically, a Barrier left whole his
  lean), and the Buzzard is the one to change if it reads too close to the Petrel (the bible's
  Buzzard row). The Nemesis's rework is built on his answers (the same day): its Crucible
  Capacitor banks rage from a hit on its shield (1), hull damage (2, hull first) and every blow
  of its own weapons a foe's armour or Barrier takes whole (2 a blow, his "per blow"), up to 10,
  and its Knuckles of Fury go out charged on five rage, unasked, and breach (a charged form may
  now draw on another store than the Muster: `charged.store` and `price`); the roll again is
  gone from its die, one direction of its upgrades; its rage reads as a meter with a notch at
  five (`RIFTGATE_RAGE_DEBUG=1` fills it). 1115 tests green.
- The locked pieces' footing, decided 10 November (the bible's locked row, section 7, and tiers
  row, section 10; `docs/locked_pieces_proposal.md` holds what follows and the order; nothing
  built): a locked piece earns its lock as glue for its chassis's identity or as an exclusive,
  its number even with the kit beside it, a tier-N piece at its machine's level N. A machine
  holds a level, bought in the hangar, cheap and gated by the Convergence, that lifts its stats
  and its locked pieces together, with a branch that tweaks a locked piece, never a stat and
  not the passive (its number may rise with the plain lift); a higher chassis arrives at its level, a wreck keeps it. One ladder of three:
  tier zero is tier one's power, a basic a plain tier-one piece owned from the start, a machine
  stocking up to its own tier at one and two; the two meet at the basics' numbers, tier one's
  coming down (his lean, so the refit's reads stand). Six pieces that are neither glue nor an exclusive yet (the
  Lance, the Flechette Pod, the Solar Flare Array, the Flakshot Repeater, the Plow, the Harpoon)
  get a tweak before any cut: Claude's first round and his first answers are the proposal's
  section 4; open with him there, the Pod's lock and the Dingo's identity. A branch's shape is settled
  (two directions two steps deep, the second pick the deeper step or the one skipped). Every rework in design sorts its pieces on this footing.
- Kestrel: ten machines, eight decided, in content and fielded (the bible's Kestrel row; the hub
  `docs/briefs/kestrel_line.md`); the Puffin back in design (`kestrel_puffin.md`). The Magpie (a
  working name, a support engine) and the Snowy Owl (a stealth unit, leaning to Cryo: Ryan,
  5 November) are Ryan's next session, their briefs' first rounds unanswered. The
  Needletail's two modes and the Giant Petrel's catamaran hull are his to pick (the to-do).
- Wainwright & Sutler: ten decided, 3-5-2, nine built (the bible's roster row). The Whip Scorpion
  and the Swallowtail are back in design (`ws_whip_scorpion.md`, `ws_swallowtail.md`); they, the
  Musk Ox and the gunship (very rough; Claude's first round in `docs/briefs/ws_gunship.md`) each
  need a design session for kit and visual design, which Ryan starts himself (4 November; the
  Needletail likewise).
- Minerva: the Honey Badger's rework built 31 October (the Ore Hopper and the Reinforced Skeleton
  module); the echidna left open (Ryan's new shape of 4 November in its brief), the siege battery
  parked on Ryan's charge brief, the battlecruiser never with the Carrier's session. Ryan's ideas
  of 4 November wait on his marks, each in its brief: the lure tank (his tier-one tank, which the
  Polar Bear's move to tier two lands with), the immune one, the mole (its hook later), and the
  shield bash (the shield-basher cut as a unit, a tier-three piece). The Cryo party defence took
  his new direction of 5 November (no free Cryo, a locked piece that detonates it, the Arsenal's
  frost figure merged in), a first round on it owed. The Polar Bear is dealt again with its new
  seal trigger (11 November), its play his.
- Aphelion: the line frame and the Baboon first (the pair that keeps its tier-one deal varied),
  then the jellyfish; the Carrier on its own. Ryan's ideas of 4 November wait on his marks, each
  in its brief: Static, the Barrier and Ward support (the defensive tier one), the Macross
  flagship, the time-shifter kept unrefined; the jellyfish took his new direction of 5 November
  (the status payoff carry, no weapons), a first round on it owed; one slot open, the Zoids
  walker's if it comes back (his note of 6 November).
- The Arsenal: eight named and two slots open since Ryan cut the frost figure (5 November: "Cut.
  Moved onto Minerva"). His notes of 6 November, at each brief's head, replace the rounds that
  stood unanswered, a first round on each owed: Misharu (delayed judgement, in Penance's place),
  the Onryō (its own hull as a resource, a ramping carry), the thunder figure (the soft Archon
  homage), the Zoids walker (its maker open again, Aphelion's tenth or the Arsenal's) and Minos
  ("It needs something else"). Mastema's first round is unanswered; its tenth waits until its
  unrefined ideas settle (Ryan).
- The roster's tasks, group by group, are the to-do's "The roster: ten a maker".

## How things stand

What is built is run as `docs/rules.md` states it (its known gaps at the end); the bible's
section 12 lists what is built and what waits. The campaign's rules run headless only
(`sim/campaign.gd`); no screen shows them. The quick campaign is an experiment, not a feature
(Ryan, 28 October): no decision reads its runs. Landed in the last week, each with its reads in
`docs/measurements.md` and its judge or play line in the to-do's Ryan list:

- **The boss holds its hex** (`ccr-c71bc17f-hclj2c` from main at `944cd5e`, on main the same day on
  his word, "Yeah that will do. Merge into main"; Ryan, 10 November). The boss stands on the one hex touching both of the rift's front hexes, on its
  middle line, and never walks ("Put him on the single hex in front of the two new out of play
  ones"; `Battle.boss_home`): its patrol of 22 September is gone ("I feel like the boss no longer
  should patrol"), `_patrol_step` and `BOSS_ZONE` with it. Shown first as a still and set aside: the
  boss on the rift's front hexes, centred across both or on the one in line with the gate ("it
  looks silly on wall-left no matter what"). With the wall at the bottom the vortex stands a row
  lower, over its five hexes ("we can move the gate sprite down now that there's a home for it",
  read as the rift's vortex, nothing having changed at the gate), its eye kept over the rift's own
  row so the boss in front never covers it. The battle's save is 22 and the run's 21.
- **Ryan's third map list of 10 November** (`ccr-c71bc17f-hclj2c`, cut from main at `a3b48c0`,
  on main the same day on his word, "Ok, merge to main"; his words in the commit and the bible's
  rows). The bug first: the block that
  draws a machine's planned route had been cut with the hunters' rings, so a move was planned
  and nothing showed it ("I can, but the UI doesnt register it"); it is back, and no test could
  have seen it go (a draw), so the `route` pose is the check. Taking an order back is its own
  undo (`Battle.retake` takes the order's steps off the stack and makes every later step forget
  the plan; "The undo grows infinitely when I take back a move"), a new move takes the old
  one's place on it, and the tap that takes it back lets the machine go. The reach's border and
  the enemy's borders are the animated two-tone ones (`_region_outline`, `_enemy_border`); the
  chests 26 (36); the map's double-tap window 0.1 s (the die's 0.15); select and deselect on the
  map 10 dB down (`MAP_TAP_DB`); the vortex higher and half a hex toward the field with the wall
  at the left, the scroll showing one row of scenery behind it. The rift is five hexes
  (`BattleMap._widen_rift`: the two before its middle taken once the shape is laid, so no seed's
  water and walls moved; the mouth bared round all five, the roads and relief after it), the
  boss in front of them a row further out, a path into the rift crossing the rift's own hexes;
  the battle's save is 21 and the run's 20, so a battle saved before is refused. One test bound
  moved with it: a badlands field under nine wide may keep one pond (the wider mouth bares the
  other; no size the game deals). The 3D scenery's shade he passed ("3D scenery shade is good").
- **Ryan's second map list of 10 November** (`ccr-c71bc17f-hclj2c`, cut from main at `ccd71d9`,
  on main the same day on his word, "yeah, merge into main", after taking the shapes' rework in
  a merge, this file the one conflict and the bible's version main's plus one, v0.504; his words
  in the commits' messages and the bible's rows). The map: no
  hunter's ring (its code gone), a hunter's chip with its prey's small render and the hunted
  machine's tag, both with the attack mark (a sword in the reticle's ring); the threat pips under
  the pack and no count; every walk's end under a crawling border, the warning on it where the
  pack attacks from there this turn, CATCHES gone; a tapped pack's target the thing it attacks
  (`BattleMapView.target_hex`: the wall segment, the machine), and no whole way for a selected
  machine's hunters; a machine's reach under one border; an order given again
  (`Battle.retake`, `move_again`, `reach_if_retaken`: a tap on the machine in hand takes its
  order back, a new move or order replaces the old, each one undo; refused out of order where it
  would break another machine's plan); the map's tap on a unit waiting out the die's double-tap
  window; the caches' chests in place of name and pips; the tilt-shift along the rift's axis
  (`far_axis`: right and left with the wall at the left), the vortex shifted right there, the
  3D scenery a step darker; nothing takes a touch during a cutscene and nothing skips one; an
  elite introduced as it arrives after a Fracture (`hold_spawn`, `play_spawn`); no STRIKES THE
  GATE tag, and the rare pusher with nowhere beside the wall to land tagged BLOCKED (WAITS before). The skirmish,
  built by a worker in a worktree and cherry-picked: Jenny's heat warning latched a machine
  (once over three quarters until seen back under, the overheat every time); the hopper's worth
  the game's Armoured, granted as each round opens and following the loads between, a Purge
  stripping it until then, `ore_plate` retired everywhere; a resource that comes in whole units a row of
  separate cells under the heat, bordered, a pixel of ground between ("split them into different
  bars with borders and whitespace, in the same row": the hopper's four, the rage's five, the
  Musk Ox's ammo; `UnitView._draw_cells`), the Muster a meter still, the Cassowary's
  count cells too with its sixth marked (a heavier border, a diamond). Poses new: `hunter`, `elite`, `stores`. A route drawn by hand from a machine that
  already has an order is still refused (the tap gives it again). All first cuts (the to-do's
  judge line).
- **The refit pass's direction** (9 November, from the chat after his play and the formation
  pass's reads; `docs/briefs/refit_pass.md`): the block-everything loop is structural (hull
  permanent across eight to ten fights, an injury destroying a component for good, a rolled
  defence whose failure is permanent against a rolled offence whose failure delays, and packs of
  eight so a kill buys little safety); Ryan: "The balance between WANTING a tank and NEEDING a
  tank is pushed all the way to NEED"; "I think we're so worried about preventing stall that
  we're actually taking away tools that reward aggression." His calls: component destruction off
  completely to test ("placed to offer a balancing lever between tanks and dps, an issue that
  clearly no longer exists"; the injury's in-fight break off with it, "for now"); two rerolls stay (three "effective, but
  boring", two "less boring, but more unfair", doing its job); the resource model his second
  shape, "innate shield and shield regen, but no shield faces, only other defensive tools like
  armoured, barrier and ward", and heat the same way, no vent faces, cooling passive, the hold the
  decision: "Less component types - weapons and equipment. It's simple, elegant, streamlined …
  if you greed on heat, well you can always pass, which literally how a Mech game works - run
  hot, and you're forced to wait and think about your decisions while you cool off"; shield and
  vent faces "perfect commander actions" for the commander layer if it comes; the regen a flat
  number a chassis, never a full reset; the Puffin back to the drawing board (its brief,
  `docs/briefs/kestrel_puffin.md`: his instinct the one unit able to cool its allies); a hunting
  line never leads a pusher, members mixing. The cover (an unrolled interpose for the tank)
  withdrawn: the redirection row's reason stands. His leans accepted on the rest of the open list
  ("Your leans are good, but might as well rename the adjusted components when they need to to
  make sense"): the basics at heat one, the cooling by chassis, the shield pieces' fates, the
  hull budget by kind. The audit he asked for, on main's content as merged (the brief's section
  6; "send any machine or component or module that clearly doesn't work in the new system … back
  to design"): four machines back to design, each a brief (the Whip Scorpion whole, the Polar
  Bear's seal, the Puffin, the Swallowtail), seven touched without a redesign, thirteen untouched
  in kind; the eight shields and seven vents each with where it goes (the Halo the Barrier basic
  as the Halo Projector, the Shoring Jack down to tier zero in the Canopy's place, since the
  Barrier, Armoured and Ward pieces exist at tier one in no stock; the plain vents retired; the
  Arsenal's two paid in hull and the Wake Diffuser back to design); two modules whose rules stop
  firing; a stock re-deal of 37 slots; the foes it touches (the Nob's Enrage, breach against the
  regen, a common Barrier and his row of 17 October). And his point on the makeups, a direction
  (the brief's section 4, the bible's Foe roles row): a unit is made for a pusher's, a flanker's
  or a hunter's fight and tuned for it, a hunter its line and what keeps up with it, a flanker a
  duel and no small pusher, so the proposal's patrols rated one are to be rewritten and the
  Meadow and the Waste want a flanker line. The bible's Foe roles row carries it.
- **The refit pass's first build and reads** (9 November, on his "Your leans are good"; the
  brief's section 5; nothing in `content/` moved): the injury rule is off in the game
  (`Skirmish.injuries`; `--injury on` reads it back; the tests that read an injury turn it on);
  the model is a what-if the runners lay over the loaded content (`sim/refit.gd`, `--refit`: the
  die with no shield or vent, the regen, the cooling, the basics' heat, the Barrier basic's rule
  and deal) and a trial in the game (`RIFTGATE_REFIT`; a debug build's SETTINGS → REFIT TRIAL:
  MODEL, EVERY, RESTS, NONE, the four deals of the Barrier basic); the fight bot has an
  aggressor's habit (`--guard`: a block at a share of its worth) to read the blocks against. The
  reads (`docs/measurements.md`, 9 November, each a direction): over a battle the model takes
  the bot about twice as far (team wipes 89% to 64%, menace killed 45 to about 90), the regen
  the larger half; the regen is the buffer of the outnumbered and the lights against plain
  blows and never meets a breach, which is where every hull-costing cell sits; the Barrier
  matters for a full squad against a breaching massive and nowhere else, where a block trades
  rounds for hull and a round costs nothing, so blocking stays the best line until a threat
  rises (the model's ninth point, now more than a guard); fights past sixty rounds are back (5
  to 19 in some 900); heat is unchanged by losing the vents and still no pace; tier two reads
  the same by its own team. The what-if's first fill dealt a Barrier to nearly every die where
  the audit deals one only where a Halo stood: `vents=guns` is the audit's own deal and the
  trial's MODEL, and it lands with the rest over a battle and reads as well for the light trio
  in shorter fights. The proposal's fifteen tier-one formations cost the default trio 8% or less
  at three but for the three that breach (the two with a massive 39%, the knights' vigil 15%),
  which the audit's deal leaves where they are: the massives' numbers are the refit's first
  band. His to settle next, the brief's section 7: how common the Barrier is, what prices a
  round, the regen's size, breach under a regen, heat's prices. The scratch worktree is gone.
  His words of 10 November on that list: the wall strike follows the threat rating ("otherwise a
  single giant dude that composes a threat 3 on his own could be ignored. It also makes elites
  make more sense too"), built the same day (`Battlefield.strike_of`: ten a pip, a patrol 10, a
  formation 30, an elite 40; a pack a fight has worn by the share of its heads still standing,
  on his "Your lean for the pack survival is fine"; the pack's panel and the orders board say
  what the gate takes; the rules, the bible's wall row; the wall takes about a tenth more a
  battle for it, `docs/measurements.md`, and `docs/campaign_run.md` is this branch's run of 10
  November, the injury rule off and the strike by rating); breach
  parked ("Let's ignore breach for now, it's useless to evaluate at this junction"); a team Ward
  or a team Barrier "probably ok" where the two cannot be cast back to back, the Swallowtail a
  possible home, undecided (the Barrier and Ward row, its brief). What the trial plays without
  is the brief's section 5 (the content, the re-deal, the numbers, the foes, the reworks).
  His first read of the trial, 10 November (MODEL at half the gauge): "the half recovery I have
  a nigh unkillable team, even just stingray + prairie dog against 4 goblins/2 mandragora ...
  Just the MODEL seemed like enough mitigation, but the shield really made that hard to judge";
  "Heat generation is too low, but I think we knew that"; "Barrier probably shouldn't be
  stackable. The stingray stacks it due to its passive." Built on it: SETTINGS → REFIT REGEN
  beside the trial (0, 1, 2, 3, HALF, two the placeholder: a probe of his two fights reads the
  pair's hull lost at 33% with no regen, 13% at two, 5% at half); the Barrier one stack whoever
  grants it (the Exothermic Suite had counted it to two, a label: it took one blow all the
  same); and `hotter=N` for the runners, whose probe says generation is no dial alone (every
  weapon two hotter with the cooling at one stalls the long fights), so no heat row went on
  the phone and the heat prices are the price pass's, the cooling and the gauge with them.
- **Ryan's second read of the trial, and what was built on it** (10 November, the MODEL deal at
  a regen of two; the brief's section 2 has his words on the model, the bible's move, grid, three
  clocks and Foe roles rows the rest). The model on today's content: "Even with regen 2, I don't
  find myself feeling like I need to use defensive tools. Kill-to-prevent-damage seems to be
  back on the table, which is good, but its now the best choice every time. I feel like even
  with zero regen I would be fine", the fodder's damage maybe too low and the player's a bit
  high, "especially on the locked pieces", which is the Chassis Inventory session's. Built:
  **every machine one more move** ("Let's set move 3 as the slowest move, for now, and give all
  machines 1 more move across the board. The enemies feel like they move at the right pace":
  3 to 6 hexes, the validator's cap; the foes' moves untouched, so a hunter gains a hex less a
  turn on a machine that runs). On trial, each a dial on a debug build's new SETTINGS → TRIALS
  page, where the refit's two rows moved too (the settings page had reached the bottom of the
  phone's glass), nothing moved in the game until he picks: **FIELD DEPTH** (12, 14, 16) and
  **OPENING** (+0, +1, +2 moves farther from the wall), for "the map is a bit too shallow ... a
  little deeper, and the seam starts a little farther out"; and **FODDER** (FULL, 3/4, HALF: what
  a kill fills of the Rupture meter when its pack came as no elite), for "If fracture rewards
  were a little lower for fodder, then it becomes a bit more of a quantity game for non-elites
  and I'll feel more like sending my flankers out". On the desk `RIFTGATE_FIELD_DEPTH`,
  `RIFTGATE_OPENING` and `RIFTGATE_FODDER`. The width stays ("the right amount of 'epic'",
  perhaps "a tier 2 or 3 width"). What the probes say (`docs/measurements.md`, 10 November):
  depth alone buys no planning turn, since the opening is measured from the wall, so the
  opening's distance is the dial for the first turns and depth the room for it, while depth by
  itself puts the seam's first tears seven or eight rows from the wall where they are five and
  lengthens every later walk from the rift, the time to regroup for an elite; fourteen with the
  opening a move out is the pair to try first. At tier one the middle formation alone earns the
  first Fracture, which calls the elite at once, and about four fights earn the Rupture, every
  one to be had in the middle, so his "throw all machines down the middle" is the meter's
  arithmetic; a flank patrol already pays more for the machine sent, and what keeps the flankers
  home is that the middle is enough.
- **The goblin, and the recolours' archetype** (10 November, later). His lesson from the play:
  "A straight attack, and a block of some kind, so they're a true frontliner and not a lame
  not-really-damage-threat. Probably a good lesson there"; and his call on the form, hearing
  that a block that is an action softens it: "I think the earlier goblin can have shield wall
  as well." Built: the tier-one Goblin stabs straight for 4 and raises the Guard's Shield Wall
  one action in three, its codex and its Stab's line redrafted as little as the rule needs (two
  drafts on the Text tab, none of them signed; a new slot for its Shield Wall's line); the 4 is
  a placeholder (with the wall the warband costs two lights a little less than the old knife
  did and the treant's grove a little more, and nothing reaches three machines either way);
  its menace follows the knife, 5 where it was 3, so a goblin's kill is worth more on the
  Rupture meter and in salvage and the Meadow's thresholds rise with it. The
  first run of the goblin's probe was wrong and what it told him is corrected (it kept the
  loaded content between variants, so a variant's wall stacked onto the next: the rows after
  the first walled one, the grove's and the always-on armour's; `docs/measurements.md` says
  which and holds the rerun): armour that is always there does not "hold for the same hull",
  it walls the lights, so his pick is the better form and Claude's lean of that hour is
  withdrawn. His question of the same message: "If the captain is the back rank at tier 3, what
  stands in the front rank? I didn't think the recolours changed like, the archetype of the
  foes?" Answered from content (the brief's section 4 has every line): tier two's unit stands
  there, Goblin Guards at the Meadow's tier three and Wights at the Marsh's; fifteen of
  seventeen lines keep their rank and role up the ladder, and the two that do not are the
  Goblin Captain and the Lich, back-rank commanders at tier three, drafts of the ladder's brief
  of 28 October that he never marked. Open, his (the brief's section 7): each steps into its
  line's front with its Warcry or Reraise as the third move, or stands as a unit of its own
  while its line gets a tier-three rung; with it the Guard on the new knife and the Revenant's
  claw (both since answered and built: this bullet's end and the formation pass's, below). His
  calls, the same evening: "Put the captain in front, yeah", built (the Goblin
  Captain the tier-three goblin in the front rank, a straight knife of 6, the Shield Wall and
  his Warcry the third move; the Goblin Guard on the same knife at 5; each a placeholder a step
  over the rung under it; the four grids that field the Captain moved him into a front cell,
  the captain's warband two Captains and two Guards before two Alraunes; the shown drafts
  redrafted as little as the rule needs, none signed); the Lich "its own thing ... its own
  backliner" and "The tier 3 revenant shouldnt be a lich, it should be, well, a tier 3
  revenant", built with the formation pass (below); and of a
  block that walls the lights, "don't worry about walling the lights too much because the gobs
  are part of a threat-3 formation ... there should be at least one heavier unit in there to
  help out", so a formation is read with a heavier machine among its three and the pair of
  lights is no yardstick for a pusher (the bible's Foe roles row).
- **The refit pass's model is content** (10 November, on his "The re-deal with regen and heat,
  despite my tests showing it easy, seems like the correct way to go ... start with the minimal
  swaps (The "Model" setting) and we'll go up from there"; the brief's section 5 has it whole).
  The trial's MODEL deal is written into `content/`: on every stock die a shield's slot holds a
  defensive basic (the Halo Projector, a Barrier, where a shield for anyone stood; the Shoring
  Jack, Armoured 2, where one for itself did) and a vent's a Twin Autoguns, a placeholder; the
  basics are six, the four guns each making heat; every chassis regains its own `shield_regen`,
  one to three, the faster on the smaller gauge ("a smaller shield that regens fast, a fatter
  shield that regens slow, some variation of the middle"; the Nemesis and the Buzzard one by
  role); the Stingray cools one; the ten slottable shields and vents are planned drafts nothing
  deals; the machines back in design are undealt by `"status": "planned"` on their own
  entries, their kits still built (three since the Polar Bear came back on 11 November). Saves from before are refused (the three save versions).
  The trial's rows are gone but one: SETTINGS → TRIALS → SHIELD REGEN (BUILT, 0, 1, 2, 3), a
  flat regen in place of each chassis's own; `--refit` and `RIFTGATE_REFIT` keep the what-ifs
  that still mean something (regen, cooling, hotter, a price on the Barrier basic). The
  campaign runner reads it as the what-if did (`docs/measurements.md`: battles won 10% where
  they were 3%, the Rupture reached twice as often, four battles in five still lost). Not
  landed, each a later step: the re-deal proper (what each die wants in a vent's old slot), the
  component pass (three pieces to be made equipment, three back in design, the Blast Door, two
  modules), the heat prices, the four reworks.
- **The formation pass landed** (10 November; Ryan: "We've gotten off on a tangent from the
  main issue, which is the actual formation pass. What do we need to actually execute on it?",
  then, to the list: "Revenant 3 name is whatever you think. Make revenant stab flat, or flat
  with a Marsh twist, if a simple one exists. Duelists are as you see fit, might as well jam
  them in here as well as part of the pass"). The refit brief's section 9 has it in its order;
  the pass is structure and moves no standing foe's number but the two claws. Built: the
  Marsh's line (the Revenant's and the Wight's claws flat, 3 and 4; the Draugr the tier-three
  revenant, the name a draft for his name pass; the Lich its own backliner behind it; no Marsh
  twist on the claw, since every simple one is another unit's already); a flanker line a
  domain, each a duel for one machine from his bench of 3 November and from moves the engine
  ran already (the Whisker Cat, the Roc, the Dullahan, Cerberus, each with two recolours,
  placeholder sprites and drafted, unsigned text); a role on every rank-and-file foe (`role`:
  a pusher's unless it says a hunter's or a flanker's, internal) and the validator holding a
  formation to pushers, a patrol that pushes to flankers and a hunting pack to a hunter's lead
  and what keeps its pace, a crossing giving its reason; the proposal's grids re-cut and landed
  in `content/factions.json` in place of the old patrols and formations (the pruned
  formations, the antlions out of the Waste's pushers, the fronts by tier, one hunting pack a
  domain and tier where the rank and file hunt, a lone duelist the patrol rated one and a pair
  the heavy patrol rated two on the ramp's later steps), a question on every one and required;
  the opening placing its patrols from those that push, so no hunter stands at turn one. The
  elites and the escorts are as they were. The bible's Foe roles row is Decided and its
  hunters row settled (v0.511). The reads (`docs/measurements.md`, 10 November): a lone
  duelist is a fight every machine of its tier wins, dear only where its question bites (the
  Roc's stoop a quarter of the Skua's hull, Cerberus a third of a thin gauge's), and a pair is
  a wall for the slow lights alone; the landed set by the curve read and the campaign runner
  are there too. Two things found building it, both fixed with what the engine had: the
  Dullahan could ready its rise again after rising (the action's `once`), and three scorching
  bites walled the thin shields (the bites are plain, the scorch on the maul; a machine's
  armour does nothing while its shield stands). `tools/formation_proposal.py` is retired
  (`git show 3e44fe1:tools/formation_proposal.py`); the proposal stays for the bosses' stat
  blocks (its section 6). Not in it: the standing foes' numbers, the bosses' blocks, the
  rising threat's rule ("leave out rising threat for now").
- **The elites and the bosses guessed for the model** (10 November; Ryan: "I'd like you to
  guesstimate some elite and boss tweaks as well, but leave out rising threat for now").
  Before, every elite and boss read free for a gathered squad on the model (a hundredth of a
  four's hull): a blow under a fresh gauge costs nothing and a squad brings a gauge a machine.
  The guess, placeholders all (`docs/measurements.md` has the rule, every number and every
  read): a boss half again its hit points (72 at tier one) and about two and a half times its
  blow (10 to 20), which gives the default four back the kill time the test asks, four to six
  rounds; an elite two and a half times its blow (7 to 18), twice the hit points where it is
  light, so its kit plays against a squad; a cap from the scale row's own clause, no action
  taking the lightest tier-one machine from full; the tier's hit-point step halved (×1.1 and
  ×1.25), since the old step walled the stock fours of tiers two and three; an elite's menace
  no longer doubled, so its kill fills the Rupture meter about as it did where doubled on the
  new numbers it would have filled most of a tier-one meter (the rules, the bible's meter row
  and the glossary's Menace line follow, the last a draft redrafted as little as the rule
  needs). The Old Man of the Desert and the Skeleton King are unchanged, the two that cost a
  squad hull already. After: an elite is a wall for the machine it catches, a third of two
  machines' hull and a twentieth of four's; a boss costs four a tenth at tier one and a third
  at tiers two and three, and three machines can lose. Named, his: the guess does not reach
  the hull budget (an elite a quarter of a four's hull, the boss what is left), and what would
  close it pulls against the kill-time test, since under four pooled gauges a short fight
  costs little whatever the blow (the brief's section 7, item 10); the Barrier is the swing
  (one in a tier-two four takes a boss from 36% of its hull to 21%); some kits read soft
  whatever their numbers (the King Gel, the Mantis Ant, the Vampire Lord alone, the shaman's
  warband) and the adds in the kits (the Ape's gold, a rally, the Nob's rage) are small
  beside the new blows; a final's hero rides the tier's step and is a little softer at tiers
  two and three, its own numbers not guessed; a boss's kill banks more salvage. The campaign
  runner's plain player, which never gathers, wins 8% of its battles where it won 19%: a
  fight for four with one machine in it is won one time in four where it was one in two. The
  bible's scale row holds it (v0.512, v0.513 since the branch took main's third map list).
- **The fourth machine is the first battle's** (Ryan, 11 November, in the discussion that
  followed: "the only reason to leave it up to the player was to put them fully in control.
  But if the choice is in which city to defend in order to get a guaranteed choice from that
  maker, then that works"). The bible's squad row is rewritten (a run starts with three and
  its first battle brings the fourth, a choice from the host maker's catalogue; the fourth
  bought when the player chose, 7 October, retired with the test it failed), the offers row,
  the rules and `docs/economy_pass.md` follow; nothing is built. The read behind it
  (`docs/measurements.md`, 11 November): one offer of tier-one kit moves a boss's cost by
  nought to five points and a fourth machine cuts it by two thirds, so the choice was none
  and "3.5 units" no state a squad is in; the offer's machine against better kit begins at
  the fifth. Tier one is left with two bands, the first battle at three and the rest at four.
  His lean for the first: "battle one should be relatively easy, even considering the party
  of 3. It's more of an opportunity to gain resources, win, get your party in order, then the
  real game starts from battle 2." Open, his (the brief's section 10; the bible's section
  12): what easy is read as, whether it is short as well, and how it is made easy, since a
  flat cut of the boss reaches the Meadow's first battle and not the Waste's or the Peak's.
  The bible is v0.516.
- **Tier one at three machines, and Ryan's calls of 11 November.** His words: "Badger probably
  goes to Regen 1 with the amount of armour it's able to get"; "Draugr is fine as a name, as are
  your other working names"; "Let's focus only on balancing tier 1 fights for now", since tier
  three machines are to have higher stats and the lower tiers to be upgradeable; and his big
  question, when the player gets a fourth machine, with a direction: the first battle tuned
  around three units, the second Convergence around three and a half, the third onward around
  four, since a boss's fight brings the whole team in and the fourth unit's power is a flank
  covered. Built: the Honey Badger's regen is one (plate and regen answer the same small blows,
  and armour does nothing while the shield stands; in a full trio nothing moves, short-handed
  it is a few points dearer, alone it no longer wins a formation rated for three). Read, not
  built (`docs/measurements.md`, 11 November; the refit brief's section 10): eight starting
  trios and three fours, stock. A formation costs three machines 9% to 18% of their hull and
  four 4% to 5%, an elite 8% to 20% and 4% to 5%, a boss 24% to 61% and 11% to 16%, and a trio
  without the Badger loses a quarter to two fifths of its boss fights; at three quarters of its
  hit points and blow a boss costs three what the whole boss costs four. What the records say
  of the fourth machine: three at the start of four slots, the fourth an offer's after a won
  battle or bought on the shelf, neither built in the campaign, while the Convergence rises
  every turn, so a lost first battle meets a field tuned for more. The holes and Claude's
  leans are the brief's, for his answers; nothing of the tuning is built. The regen was
  assigned by the gauge's bands alone, which he asked and the brief now says. This session had
  not read the locked pieces' session (`ccr-4d58b054-3lyj0a`, `docs/locked_pieces_proposal.md`,
  not on main: a machine holds a level, bought, lifting its stats and locked pieces; tier one
  comes down to the basics) when it guessed the elites and bosses: the tier-two and tier-three
  reads of 10 November are stock machines that plan will not field, and are tuned no further.
- **Ryan's play of Phase 2** (9 November, his read of the long wall as built, on the phone): hard
  to judge; the packs as they were too hard, "but not for any particular one reason"; incoming
  damage high, so the tank tanked every turn while the rest could not take foes down reliably
  before a whiffed lure; Floraison impossible ("its HP was insurmountable", eating the tank and
  whittling the dealers); the Stingray caught by hunters and fine, since the Photosphere Lance at
  4 with Burn "takes down most foes", used as burst not as the hybrid meant; the Armadillo "a
  beast of a tank and way too strong for tier 1", the one reason a boss was reached (his notes
  became the Polar Bear's kit of the same day, below); never in control, every fight "how do I get out of this with all my machines
  intact", which "should be reserved for Hunter, Elite and Boss packs, not pushers and flankers".
  The locked pieces warp the die: he chased the Flak Repeater as his only area piece, the Lance
  and the Skua's sweep every round, heat no deterrent. His rough conclusions, each a direction
  for discussion first (the formation pass's chat): enemy HP down slightly and the synergy pieces
  up rather than raw numbers, judged after he plays the new formations, so the refit waits on
  them; the locked pieces on a new footing, a tier and upgrades his lean over utility-only; shield
  regen inside a fight back (the slot is built, `shield_regen`, zero everywhere), since nothing
  buffers a bad roll or an unlucky pick and the tank's pattern is "singular, inflexible,
  mandatory". The bombs never hunt (his answer to the proposal's first question): a hunter's
  threat is a sequence a lone support can play against, never a burst that decides the fight.
- **The formation pass, proposed** (9 November, `ccr-722ca9f0-yj8na3`, Ryan: "I'll sort out the
  questions in the formation pass"): `docs/formation_proposal.md`, every domain's patrols and
  formations written anew as grids with a question each under `design` (an anchor and a swarm,
  the grid carrying the reach question, eight the ceiling and the ramp's variant a step toward
  it), the hunters as heavy patrols rated two and no formation hunting (the wolf, antlion and
  bomb lines by their codex; the needlers and the Marsh's dead push), a true one for a lone light
  machine under every patrol for the Badger, the two hunter questions of section 12 with a lean
  each (the bombs his call; the opening placing its patrols from the pushers, one line), the
  bosses as stat blocks by tier and ramp with today's multiplier as the first entries, the holes,
  the bench and the order. The proposal was written to a scratch worktree as content, validated,
  and read by the curve read with the default four, a light four (the Skua first, for the rating
  of one) and a tier-two four (`--team`, new), its bands the tables' last columns and the gates
  and the pruning read off them; `docs/measurements.md`, 9 November. Nothing in `content/` moved
  with the proposal; its grids landed on 10 November, re-cut (the bullet above), and the tool
  that held them as code is retired. What the reads said: at
  tier one only the massive-anchored formations are a decision for three (the sandworm ambush,
  the magma vent), every fodder formation reads free for three at eight foes and the eight-slot
  variants move no band against the six (twelve prunings), so the fodder's lever is the refit's
  numbers; two-anchor formations written after the first read are true threes at tier two (the
  grove and bloom, the pit wall); every domain has true ones for the Skua alone (the Peak's the
  new ember pair); the antlions, the pit pair, the queen's hunt and the grenade and balloon
  flights read as twos, the wolf pack and the warg pack as ones (a two on them his word); the
  light four walls on every massive and stalls against the grave field (the giants' line has no
  escalation). His first answer, the same day: the bombs never hunt, so the Peak's hunters are its
  elites and the wanderers; its first question is settled, and the rest went by his "Your leans
  are good" and his calls of 10 November. Still the proposal's: the bosses' blocks, a session
  of their own.
- **The map playtest list of 10 November** (`ccr-c71bc17f-hclj2c`, on main the same day; five
  points from Ryan's phone, then his answers). A tear's ring stands on its hex: it was drawn in
  screen space at its map position, so it hung at one place on the glass while the map scrolled
  ("it's just fixed in place as I pan around"), and its plaque left the transform in map space
  for the edge tags and the scan lines after it. A tear has no edge tag ("same way the rift
  doesn't"; none had ever drawn, the tags' list refusing one with an error a frame). The boss
  has a picture of its own on the map ("now it's just a giant blob. Probably needs to be
  actually regenerated for a sensible size"): `art/foes/<id>_boss.png`, 48 pixels, cut from its
  combat sprite for all twenty-one that can lead a boss unit (the domains' bosses and benches)
  by `forge.py boss`, which needs no image model; the token stays for the small faces, and a
  test ties the pictures to content. Under the painting the scenery past the field is one shaded
  ground with no cells ("the out-of-play areas on the flattened parts of the map are made
  clear"; `PaintedMap`). The vortex stands a little higher with the wall at the left
  (`BattleMapView.rift_drop`). The painting's edge stands on the seam's own row ("The point of
  the seam was to visually represent where the tears can open"; `Bleed.gradient`: it stood at
  half the seam's distance, so a tear "spawned at the apron without the seam moving"): four rows
  painted as a battle opens and the field to the apron by the third peak, the engine untouched.
  A peak is shown as it happens ("an animation/cutscene when one opens. And ... when the seam
  moves, too"; `BattleMapView.hold_peak` and `play_peak`, the rules' "A peak is shown"): held
  through the packs' walks, then the seam's sweep under its front and each tear bursting open,
  a press skipping it; its two sounds are borrowed (`contact`, `reveal`). A hunter's lock is
  shown the same way ("We should pan and zoom to hunters when they acquire as well";
  `play_locks`): the map glides in on each hunter that turned on a machine, zoomed to 1.6 as it
  is on a tear, the HUNTED band over it, every lock of the turn in its turn where the first
  alone was declared, then back to the player's view. The `tear`, `peak` and `hunted` poses are
  new. His notes for a later session are in the bible's tears row (the seam starts too
  far up and could be curved; crossing the map is the issue more than the tears' distance). All
  first cuts (the to-do's judge line).
- **The side session of 9 November** (`ccr-df879779-uf9076`, beside the formation and refit pass,
  on Ryan's "go"; on main since 10 November). The test runner hears a crash: it reads the engine's log for
  script errors while each test runs (a Logger) and fails the test for each, in the test or under
  it, where a test that crashed after its first check had read as passed; `tests/test_runner.gd`
  raises one on purpose so the suite fails if the runner ever stops hearing them (that one SCRIPT
  ERROR is in every run's log); the suite as it stood hid none. The runner takes words after
  `--` and runs only the files whose names hold one (`-- loot rig`), for a quick look. The
  caches have pictures (Ryan: "can we get models (and art, when flattened), for loot caches on
  map?"; first cuts, the to-do's judge line): a lowforge model a kind on solid ground
  (`cache_derelict` a canted hulk, `cache_carcass` a skeleton of theirs, `cache_relic` splinters
  of their stone round a lit core the map turns; `Map3D._sync_caches`, in the world's layer like
  a prop, sunk and gone where the painting has the hex, hidden under a machine) and a 16 by 16
  token a kind under the painting (`art/loot/`, typed grids in `tools/loot_tokens.py`,
  `BattleMapView._draw_caches`), the name and the tier's pips over both; a kind's files are
  keyed by its id and `tests/test_loot.gd` ties them to content; `RIFTGATE_CACHE_DEBUG=1` lays
  one of every kind in each world. The Relic's light is a new tile, the enemy's violet (`rift`),
  with `stone` and `hide` beside it. The skirmish audit's structure 13 is done: the screen's
  Sweep rank is the engine's `sweep_rank_of` and the intent's number the engine's
  `intent_value`, one read for the field's chip and the readout's; the engine gained that one
  function and plays as it did, so no behaviour trace was run. Both pages were republished on
  his word (Pages). His question on enemy art from a cloud session was researched and parked
  (10 November, the to-do's Art line); nothing is built for it.
- **The hangar's Text tab** (10 November, `ccr-7d7ed303-tbdkg4`; the bible's shown-text row): Ryan,
  9 November, wants to work on "all in-game text that the player sees" and to get "a strong
  foothold on content I've written myself, so that you can do a better job of mimicking my
  intended writing style", the hangar being "hard to find what is visible in-game, what needs
  editing, what's outdated, and compare between entries". Claude's first cut, built on that
  statement, his to judge in use (the to-do's Ryan list). `tools/hangar_text.py` is the one
  inventory of shown text: 1,326 texts in seventeen kinds (a term's entry, a codex, a flavour,
  a passive, a module's rule, a foe's move, a title; and read-only, two tables the code holds:
  a status's line in `sim/effects.gd` and a foe's aim and condition words in `sim/foe.gd`),
  each with where the game draws it, the engine's facts under it and its maker's voice. 1,064
  are drawn by a screen today (943 drafts, 121 empty) and 262 by none: every component's
  flavour, every module's codex and flavour, the four domains' flavour, the planned moves and
  rules, 88 terms the keywords list leaves out (the rules' reference only), and the 43 status
  lines, which since 2 November show only in a codex's KEPT FOR THE BATTLE row (a chip's
  meaning is its term's entry). The tab is one row a text by kind, grouped by voice, filtered
  by state, edited in place; he signs a text his own (Mine, or by saving what he typed), passes
  a session's draft (Pass), pins texts to keep beside what he writes, and leaves a note for the
  session. His work waits in the page's `text` collection until `--fold` writes it: his words
  into content where they stand (the hand-laid files keep their layout), his marks into the
  ledger `docs/hangar/text.json`, his own texts into `docs/voice.md`, the corpus a session
  reads before drafting shown text (`CLAUDE.md`'s rule). A signed text a session rewords reads
  Changed since, one whose mechanics moved reads Stale. The ledger is empty: nothing is signed
  until he signs it, his four chassis codexes and three flavours included. Left out, and said
  so on the tab: entries' own names, the lines the code composes from numbers, the screens'
  furniture and Jenny's lines. Checked on a local copy of the page with a stand-in database
  (signing, writing, the next row, a live sync under a half-typed text, a fold into
  `chassis.json` and the hand-laid `foes.json`, both flags, a phone's width), then published
  (Pages, below).
- **The Lammergeier's rework** (9 November, `ccr-a0b35006-od22d2`; the bible's Lammergeier row):
  Ryan sent it back for more than a fix ("A chassis based around opening an empty spot isn't a
  good design"), the slot form waiting on arrivals the long wall cut. His shape, built: "the
  lammergeier basically converts all hits to AoE hits, at the cost of a delay until Death", the
  Cottonmouth's niche executed differently. The Reverberant Payload: every spend it aims at a
  foe leaves a Mine on it as a rider, one a spend at a flat 2 with the spend's whole result on
  that foe ("the mine should take the entire result of the spend, then apply it": every hit's
  stacks as its machine deepened and doubled them, a gated keyword where its gate held), the
  numbered ones added and the rest once, area, Sweep's targeting and Lure left behind;
  when the foe falls (getting back up, splitting, a tick or a part included) the Mine blows in
  Splash's shape round its slot, plain through each foe's own Flak and armour, in strike order,
  a blast's fall blowing its own. The Syrinx Drone detonates (a weapon of 1, no cooldown, its
  own Mine first); the Lorentz Contractor gathers every Mine onto one foe and Exposes it. A Mine
  is a foe status: its chip shows the damage and its readout the keywords; a Ward turns it away,
  a cleanse takes it, a merge hands it to the merger. The slot mines' code and the audit's faults
  parked on it went with it. Saves at 20, runs at 19, quick runs at 4 (the renames of the day took
  the numbers before). `RIFTGATE_MINE_DEBUG=1` mines every foe at
  a fight's open, to judge the blast running. His levers if it reads weak or dangerous: a Mine a
  hit; a cooldown on the drone. On main since 9 November ("Merge this into main. Your reads are
  correct": the Numbed call and the conditions read as the die is spent among them). The
  runner's read (30 seeds, a direction, alone): every pack 7 / 43
  before, 42 / 50 after, from the tier-three band's floor to its top beside the Giant Petrel's
  38 / 50, the drone picked 21% and the gather 5% (`docs/measurements.md`); not weak, so the
  per-hit lever waits.
- **The Polar Bear's kit of 9 November** (`claude/modest-ramanujan-uovd42`, Ryan: "The Armadillo is
  OP. I never really felt strongly about Sealing it"; built as he gave it after the holes, his play
  the judge): armour 1 open and 4 sealed, one Cryo Flinger on a die of five, the Flinger without
  Rapid and gaining Spread while sealed (Lockdown's grant, scoped to the piece: a `when` of
  `sealed` and an `entry` naming a component, both new), and its weapons 1 harder on a foe
  carrying Cryo (the strike that meets the stacks, its hit spending them). The probe that read the
  old kit is in `docs/measurements.md`. Renamed the Polar Bear the same day (the bible's names row; the claws in
  his words a metaphor for the damage boost), its id `polar_bear` with it on his word, its model, rig,
  textures, blend and hangar renders moved and the save versions bumped (battles 18, runs 17, quick runs 2). The same day every
  id still wearing an old name followed its name (Ryan: "Yes, rename them all"): `kite`, `buzzard`, `oblation_mantle`, eleven
  foes' (`antiquarian`, `world_eater`, `shuffler` and `shuffler_spawn`, `floraison`, `gargantuan_king`, `emperor_scorpion`,
  `astromancer`, `cleric` and `cleric_promoted`, `bone_wyvern`, `magma_elemental`) and the compositions named for them, their
  models, rigs, sprites, renders and picks moved; the Kite's codex says the Kite at last (it still said the Sparrowhawk), and
  the saves moved on again (battles 19, runs 18, quick runs 3). 1075 tests green.
- **The playtest list of 9 November** (`claude/playtesting-ui-feedback-hfdiok`; the bible's
  Rupture names, map marks, Ability, UNDO, tap and ranks rows, and section 12): built, first cuts
  all for his phone read (the to-do's one judge line). The battle's top bar is three gauges always
  on screen, the gate, the rift's spawn and the Fractures (`TopBar`), flashing as one changes; the
  turn and READY are the board's, the music between the bottom buttons; the gate's and the rift's
  bars left the map and the gate is no selection. A Fracture is announced as a fight ends (the
  warning band; THE RUPTURE at the last). Every walk's end hex is lit; a tapped pack shows its
  whole way to its goal (`Walk.route`, `Battlefield.turn_ends`), its later turns numbered (Claude's
  addition), its readout saying when it gets there; a selected machine shows its hunters' ways.
  The action pip is gone, the board's lower panel shows the hull alone, the boss stands 128 px tall
  on the map, the vortex stands on the rift's lowest hex with the wall at the left, and there the
  wall and the gate stand a row forward with the city behind (his word the same day: "the best
  solution", city defences to be wall segment upgrades). Both UNDOs read on or off by their edge;
  the skirmish's sits bottom-right, and it opens again after a spend (the bug: its re-opening
  tween ran a frame ahead of the clock and left it shut for good). The die's tap waits 0.15 s from its release to a second touch; a skirmish
  intent line leaves its intent chip's middle (`UnitView.intent_anchor_global`) for the machine's,
  the ranks 18 px apart each way and the edge foes' chip rows kept clear of their neighbours'; every status says Buff or
  Debuff (`Effects.status_kind`: a wedge on its chip, the word in its hold, its tip's heading, the
  keywords list's headings); the log stays at full strength; Jenny's "bogey eliminated" is cut.
  The "chase": no pusher read a machine, but every pusher's segment was drawn about the rift's
  column, where the machines open, so the flank patrols crossed toward them; on his word the same
  day ("the flankers should target their closest wall with a small amount of randomness, avoiding
  crowding ... Oversight if not implemented") a segment is the wall nearest where the pack is dealt,
  within 2 of its own column for a flank, a formation the opening places and a tear's patrol, the
  rift's packs keeping the ramp's spread about the rift's column, the least crowded column of the
  window winning.
- **The shapes relaid for the shallow field** (9 November, `ccr-1e6e6571-7x7ayr`, Ryan: "We lost a
  lot of polish when we went to the new archetypes, and things need to be adapted to the new map
  orientation (wide versus tall). It also needs to work for different map sizes, in case those
  change with convergence"; the long wall brief's open item 5). The old laying kept the old
  field's reservations as counts (a mouth of four rows, the team's two), so at twelve deep a shape
  had rows 4 to 7, and the "down the field" shapes laid one divider sized for a wall of nine: the
  fjord a puddle, the gorge two stubs, the steppe bare, the river a moat (the measurements of 6
  November). Built: the rift's mouth a share of the depth (`BattleMap.mouth_rows`: a row for every
  five of depth, two at least and four at most; three at twelve deep, so five open rows), the seam
  and the opening reading it (a pack whose opening hex the shape took goes along its row, never
  back into the mouth: `Battlefield.landing`'s floor); every shape laid to fill the open rows at
  any size, "across" along the wall and "down the field" rift to wall whichever way the view
  turns; the counts that are the field's scaled with the wall (a fjord for every ten hexes of it,
  a cliff wall for every six, the steppe's crag and pond for every ten) and the team's not (fords
  and streets three or four in all); a river between a bank row at the mouth's edge and one before
  the team's ground; a city's one band mid the open rows with rubble before and after; each shape's
  second ground along its landform in stretches from a seeded noise (gravel bars, shingle, scree,
  `BattleMap._shore`). Then Ryan's recast of the three wall shapes the same day ("the 'vertical
  versus horizontal' categorizations don't really hold together"; his words in the bible's shapes
  row): a spectrum by the mass and the structure of what blocks you, water in all three. Built as
  first cuts: the GORGE cliff mass over the open rows cut by winding, branching channels (a trunk
  for every seven hexes of wall, two or three branches each, a flooded stretch or two); the RUINED
  CITY large tower blocks in a grid of one-wide avenues (the gate's two wide, the roads) and
  broken side streets, a plaza with a fountain and a flooded street now and then; the BADLANDS an
  open field of small mesas a hex apart with ponds. A city band's streets rule retired with the
  band; the field of every shape but the badlands and the steppe level by rule, and the scenery's
  first ring level. Saves at 17, runs at 16. Read at 200 seeds on every shape at 20 by 12
  (`docs/measurements.md`, 9 November, twice: the relaying, then the recast) and drawn on both
  views (the river's bars, the gorge's mass and the city's blocks in the 3D); the to-do's Ryan
  list has the phone judge, with the counts and the authored sectors (the long wall proposal's
  lean, a content proposal only if these are not enough). The bible's shapes and field rows carry
  it (the shapes row live since the republish of v0.496; the field row's 10 November sentence and
  the section 12 row on the blocking are this file's, not yet the page's, Pages below). His first play (10 November): the flattened side wants features all the way to the back,
  built the same day: the rift's mouth is the bared ring beside the rift and nothing more, every
  shape laying from the rift's row (eight open rows at twelve deep), the opening's packs off the
  rift's row (`Battle.OPENING_FLOOR_ROW`) and the seam keeping its own start (row 4 at twelve
  deep, `Battlefield.seam_start`); the shores laid after the guarantee so no bar outlives its
  water. His second note, built the same day on his go ("it's fine to slide the units under each
  other"; "I'd love to try getting rid of the hunter catch radius"): no body blocking, every unit
  passing every other and nobody ending on another's hex (`Battlefield.passes`), the pusher that
  turned back and the sealed-off prey's stand-in gone with it; and a hunter catching at the engage
  range everyone shares (`Unit.ENGAGE_RANGE`, 1; `ContentDB.HUNTER_RING` gone), the readout's ring
  line with it, the ring drawn now the hexes beside the walk's end. The bible's passing, crossing,
  ring, fights and hunters rows carry it (v0.500); the campaign runner's 40 runs after it are in
  `docs/measurements.md` (a direction). His play of the shapes in context the same evening, built:
  the 3D map's road UV turned with the view, so the roads meet in both views as the painted ones
  did; the painted world drawing a wall by what it is (crags the ranges, mesas a stepped block,
  towers lit blocks, cliffs a ridge edge to edge: `DomainGround.draw_walls`); the river winding
  through the whole field through its centre with narrows (water fords) and tributaries, no land
  ford, the roads to the narrows; the fjord flooded, half to two thirds water with lanes carved as
  the gorge's channels are (`BattleMap._carve_lanes`) and islands; the gorge a trunk for every
  five hexes of wall with junctions; the badlands in groups of two to five mesas; the steppe with
  scrub belts, a crag for every seven hexes of wall and grass on the open field in the 3D (the
  dress's `field` word). The bible's shapes row carries his words (v0.501). The maps' seeding issues
  are the to-do's.
- **A hunter's reach** (8 November, `ccr-d26a1321-xg9xge`, from Ryan's bug report: on the first
  enemy walk a goblin warband caught the Polar Bear from three hexes, "No indication of catch
  range, nor why a normal goblin pack is now suddenly a hunter"). The three came from a pack
  taking its widest member's ring, the Mandragoras' back-rank three from the joining days. His
  calls the same day, built: a composition says whether it hunts, never its foes ("The
  composition should say if it hunts, not the units": `hunts`, its caveat, absent for a pusher,
  never on an escort; the twenty-nine hunts carried over from the foes but the goblins', "normal
  fodder, as per their codex lines"); the rings purged ("I had also assumed that all range rings
  were purged from code"): no foe and no pack carries one, a hunter catching at the pounce, 2
  (`ContentDB.HUNTER_RING`), the validator refusing `zone`, `behaviour` and `hunts` on a foe; and a
  hunter's ring drawn on the map, round where its walk ends and round the hunter while its catch
  waits, in the rings' old look (the bible's map marks row; `BattleMapView.hunter_rings`). The goblin
  has hunted since it entered content on 9 October, the ghoul's heir (git); what changed was its
  formation opening a move from the wall (6 November) and the HUNTED band (8 November). Saves at
  16, runs at 15. Section 12 asks whether the rank and file that still hunt (the revenants, the
  needlers, the bombs) are fodder too, and whether the opening deals no hunter in code, his to
  settle in the formation pass (9 November: "I'll sort out the questions in the formation pass");
  his phone read of the ring is the to-do's. On main since 9 November.
- **The long wall, Phase 1** (6 November, `ccr-56b5169d-lsa2rg`, from
  `git show 68381ff:docs/briefs/long_wall_build.md`): the field's size the ramp's (20 by 12 for now); the battle
  opening with the siege under way (formations a move from the wall, patrols on the flanks, the
  pressure a turn short of its first peak); the tide on a beat of 3 turns, 2 from Convergence 8,
  halved once at the Rupture; a pusher's own segment of the wall; one pack one fight from beside
  it, nothing joining, a hunter's catch first; no withdrawal; the shield full at every fight's
  start, the field recharge gone, the shield regen slot at zero; every pack's threat rating on
  the hold (a patrol 1, a formation 3, an elite and the boss 4); a composition's layout, lead and
  variants in the schema, no content written in it; the defence bot and the pressure ratio in the
  campaign runner, `--shape`, and the promise read (`tools/balance.gd --packs promise`). Phase
  2, the view, built the same evening on his word: MAP VIEW (the wall at the left, the default,
  flat-top; or at the bottom), the field scrolled along the wall with tags at every edge, no ring
  drawn, the threat pips under each pack's count, the fight queue numbered with ENGAGE 1 OF N
  and an action pip a machine, no withdraw button, no shield gauge on the map (`MapOrient`;
  the `queue` screenshot pose); his phone read next (the to-do). The reads (40 runs
  on the steppe, a direction): no run won, 86% of battles fell, 169 of 481 fights one machine
  against a formation; the defence rule is the floor, not the player (Ryan, 6 November: "I
  wouldn't count anything until we've got everything in place"). The promise read (30
  seeds): a formation at its rating of three a decision in 24 of 38 cells and a wall one short in
  16; a patrol alone costing its machine over half its hull from tier two; the elites too easy
  at their four in 47 of 53 cells, and beaten by three as well. Ryan's answers of 6 November:
  Phase 2 now and the branch landing after it; the placeholders kept until he plays it; the
  elites kept at four until his try; reinforcement inside a fight cut and the Lammergeier back
  to the shop; the map bait to build; the Fracture a shell; no battle opening on a forced fight
  (built); the Mandrake's Scream down to one (built); the formations, the refit and the ratings
  by who solos a pack after the rest. His answers of 7 November, built: a fight's dice whatever
  order its turn's fights open in (`Battle.fight_seed`); his Designs-tab notes folded into the
  briefs; the cut (a pack what its eight slots hold, every composition fitted to its ranks until
  the formation pass, no summon or split past the slots, a regrowing part's corpse holding its
  slot, a catch's overflow held back, the ramp scaling no pack, the reserve's plaques retired);
  the ramp scales the field alone, and the formation pass writes compositions as variants placed
  on the tier and the ramp by the runs; the harness's BATTLE (a battle as a run deals it) and
  FIGHT apart; the field's caches (`content/loot.json`: Derelicts, Carcasses and Relics on the
  field from the first turn short of the wall, the better kinds likelier the farther from the
  wall, claimed by a machine standing on one as the turn ends or as the battle is won, banked as
  the kills; his phone read next, the to-do).
  His corrections the same evening, built: a hunter's catch is a fight a hunter (a machine two
  hunters caught fights each in turn; the first build had kept them one fight and held back what
  its slots could not stand), and a boss's escort is its curated composition, never grown by the
  tier, so no fight is ever trimmed. Then: the bosses to become fixed entries by tier and ramp,
  numbers and escort, as a pack's variants, with the formation pass and not before (the flat
  multiplier the placeholder, a final's three wildlife curated then; the to-do); and the quick
  campaign follows the main content and code, one tree for both modes (CLAUDE.md): its fights
  built by `Battlefield.pack_of` and `Battle.make_boss_unit`, which the battle and the harness
  use too, a boss with its escort alone, its density lever gone.
  While he plays (his word, 7 November): a composition's ramp gate in the schema and the dealing,
  built and empty, the harness's battle raised to its tier's first Convergence; the curve read
  (`--packs curve`) for the formation pass; the runner's bot taking a cache when no pack is in
  reach, the runs reporting the loot banked. His audit of 8 November, built: the seam's upgrade of
  a cache set aside with the placeholders' seam (the kind by depth instead); the last turn's fetch
  banked with a win; a Convergence past 12 reads as 12 for the gates; a layout must place every
  member; a summoner needs room for its whole count; the tier fallback for compositions gone
  ("we've either defined the escort or we haven't"); the harness's C knob follows the tier; the
  quick campaign's elites draw their own layouts; `factions.json`'s `_about` and the mine's rule
  brought up to date. His calls on it, built the same day: one hunter a machine (an overflow
  hunter pushes and turns on a machine once one is free), a summoner standing as many as fit,
  no turn passed once the finale is due (the runner forfeits with nobody to field: the capital
  falls, his call), the gate's coverage rule kept strict; a hunter's turning on a machine declared
  on screen (the map scrolls to it, the HUNTED band; the roar the audio to-do's); and a
  composition is its grid ("Fix the comps so they make simple sense"): `front` and `back`, four
  cells each, the whole declaration, no members list and no listing cells, a variant its own
  composition, the 104 of content laid out mechanically from their member lists until the
  formation pass writes them.
- **The skirmish code audit and Ryan's answers** (7 and 8 November, `ccr-1eaf0060-jrpw04`;
  `docs/skirmish_audit.md`; the bible's Ability, Purge, spend's order and Sweep rows): a kill is
  a foe the death check clears that stays down, one tally for every kill trigger, the grudge,
  salvage and menace (a merge, a return, a split, a part and a burst none, only a core's fall
  counting for its unit); a
  Sweep's shots queued as the spend begins, a pair's halves a spot each, each shot judged on its
  own; the enemy's turn checks death after every foe and stops the moment the fight is decided;
  the Goblin Nob's rage its own from the start; Guarded on the die, the bot and the ticks;
  Scorched on the bar, never the ammo or the Storm Petrel's shield; a countdown shown at the fight
  as it stands; a Purge takes N stacks of every buff whatever granted them, on both sides, and a
  unit's own mechanic is an Ability on a chip of its own that no Purge touches
  (`RIFTGATE_ABILITY_DEBUG=1`); the Musk Ox reloads once, the greater; every roll inside the
  round follows the reroll rule but the Knuckle of Fury's and the Spin-Up's, each said on the
  die. The mine path went with the Lammergeier's rework (9 November). Its step 3 the same day
  (`ccr-8df9952c-4cccdf`, no behaviour changed): one hit routine (`_hit`) for the plain spend,
  the salvo and the blast, each paying its own (`_finish_hits`, `Pays`), one `_land_blow` for
  every blow of a hit, the hidden flags arguments and returns, the preview's recorder on its
  copy, one `_finish_round` and one `_blow_on`; checked by the suite and `tools/behaviour_trace.gd`
  (2,988 fights identical to main's). On his word, 9 November: the die-in-hand forecast gone
  (`forecast` the bot's estimate of the round as it stands; the round preview the one model with
  a die in hand, the twenty-three tests moved onto it) and the Swap's gauges on the preview while
  it waits (Bug 16, the one visible change). Waits on Ryan's phone read of the Ability chips (the to-do).
- **The spend's order and Sweep's columns** (7 November; the bible's section 5 Sweep, riders and
  spend's order rows): a single-target weapon's hits, their riders, the death check, the spend's
  end, then what its kills bring back (a foe getting back up, a split's halves), so nothing a
  spend does meets them and a Purge on the killing hit keeps Undying down; Sweep a shot at each
  column, left to right, repeating, an empty column's shot wasted and a corpse taking its
  column's later shots, each shot's riders before the next; every sweep one path, the salvo an
  ammo a shot; the zap lands on a felled target; the round preview's return chips (the rising
  arrow, the fork) in the skull's place; the Skua's text Ryan's ("Base weapon damage is
  halved"), its base halved before every buff ("the spirit of buffs and riders is they happen
  after"); a massive foe takes either rank's shot at its column; on screen every hit and shot
  lands, one on a corpse and a wasted shot on its empty slot (`RIFTGATE_MISS_DEBUG=1`), a death
  at the spend's death check after its last blow; a Swap lands in the rider phase on a felled
  target too, a return coming where the unit died. Waits on Ryan's phone read of the chips and the
  wasted shot, and a Skua read (the to-do).
- **The die's standard face** (2 to 4 November): one main mark holding what the entry delivers,
  whom it reaches under it, the costs along the foot, keywords down the edge, a passive box at
  the edge's foot for what the machine's passive adds (the Storm Petrel's zap, the Whip
  Scorpion's blast, the Cassowary's next chamber); Every Foe, Every Ally and Every Other Ally as
  targeting modes with marks of their own, never keywords, so a Silence leaves them whole (Ryan,
  4 November: "Silence should not narrow targeting modes"); Sweep's mark lobbed with a line of
  fire rising for each column; the readouts headed by the die's marks; gauges with ticks; strikes landing one at a time; the
  acting foe lit; UNDO to the last roll. `tools/die_sheet.gd` draws the whole iconography; the
  benched marks are `docs/looks/die_marks_candidates.png` and `die_polish_candidates*.png`.
  Waits on Ryan's phone read.
- **The randomness pass** (2 and 3 November; the bible's section 2 randomness row): rolled damage
  gone (every range at its mean, to be read again at 200 seeds), an injury breaking the entry
  the die shows, Numbed as a count of rounds with a stun resist by kind, Purge N on both sides,
  the Ward, the primers Charged and Supercooled (no piece grants them yet), Sweep as the third
  reach, riders landing after the hits, death after every effect (the spend's order since 7
  November), Overcharged and
  Kindled renamed Empowered and given one clock (a foe's halves at the round's end too, 4
  November). Left for Ryan: the Scorpion's rework (its blast is the one draw
  besides the die), rules for the two planned modules, the Emitter's Purge 2, whether a foe's
  ticks come before or after its action (section 12).
- **The elites session** (3 and 4 November; the bible's register and tiers rows, section 9;
  `docs/bosses_proposal.md`'s tables): twenty-one elite kits, six of them wanderers drawn at
  random on the Fracture's roll (Gilgamesh, the Reaper, the Wild Hunt, the World Eater, the
  Shuffler, the Astromancer, the first elite in parts); Enraged (the Nob's bellow), Golden (the
  Thunder Ape's mode), Crushed (the World Eater's pin), the opener; thirteen bosses, three a
  domain and the Marsh's four (the Fiend of Fire, the Mantis Ant, the Marsh Serpent and the
  Emperor Scorpion new); every foe with art, a placeholder stamped "?" where no pick exists
  (`tools/placeholder_art.py`); the hangar page's foe sprites with filters by kind, tier and
  art. First read at 30 seeds: every elite cell a free win, the lone elites dying in two rounds,
  and 40 HP buying rounds, not threat. Waits on Ryan: the elites' numbers (the massive band, an
  escort each, or the curveball on the map) and the names.
- **The chassis' runner rows** (3 and 4 November): the Cassowary's bot plans its cycle
  (`Policy.cycle_plan`) and at 200 seeds the Cassowary carries a decision under the Cottonmouth;
  the Musk Ox's salvo priced against a reserve; a plain Rapid entry's action valued again
  (`Policy.rapid_worth`); the Whip Scorpion, the Swallowtail, the Musk Ox and the Needletail
  read at 30 seeds, none finalized and none Ryan's concern until their design sessions. New in
  the runner: tallies of charged spends, gated spends and paints cashed, each cell's spread, and
  `--pilot chassis=N` (a what-if heat a round, `Skirmish.pilot`).
- **The models in motion** (28 October to 4 November, `claude/charming-rubin-h954bp`): the weapon
  that fires moves, kicks and flares at its business end in its tags' look; fixed weapons fire
  with slices of their acts; a blow jolts the machine and a lost one slumps; the boosters by
  maker (Aphelion's plumes, Kestrel's halos); a hardpoint's variant and scale per silhouette
  class (`tools/fit_sheet.gd`); micro-models for the Swallowtail's flares and the Musk Ox's
  rockets, shell and casing; shot trails tabled behind SHOT TRAILS. All first cuts for Ryan's
  judge lines; the render margin (a piece fired out cut at the view's edge) is his to judge running.
- **The Honey Badger's hopper** (31 October): a load a foe its weapons damage, four at most,
  every two loads a stack of Armoured, granted as each round opens (10 November; the Ore Plate before it), the first buff a store grants; "never destroyed" is the
  Reinforced Skeleton module. Read at 30 seeds, Ryan's second fallback landed.
- **The Petrels** (30 October): the Storm Petrel's shield pays its weapons' heat and zaps the
  target for what it paid; the Giant Petrel banks rerolls and buys an ally's action. Both
  fielded; the Storm Petrel is in Kestrel's tender.
- **The bosses' slate** (30 October to 2 November): the slate's bosses as runnable placeholder
  kits with their own escorts at tiers two and three, the stand-ins demoted to the ranks with
  recolour lines; a follow-up, a steal, a swallow, a merge, a drain, a grudge, a part's
  condition, a once-a-fight move and a foe's purge built for them. Waits on Ryan's content pass.
- **The skirmish field, the colours and the keywords** (29 and 30 October): one field in
  perspective; the enemy in the rift's violet, heat red-orange, harm red-red, a debug build's
  COLOURS page for Ryan's picks; every term bold in its colour with its icon and a tap opening
  its entry (`Terms`, `KeywordTip`); the dice's gestures (tap reads, double-tap or hold locks);
  Godot 4.8-beta2 for the MSAA fix, the player's AA MODE. Waits on Ryan's phone reads.
- **The pacing session and the foes' fresh start** (29 and 30 October): packs as compositions,
  the field and the rift's cycle by the tier and the ramp (`sim/ramp.gd`), the tears and the
  seam, the whole wall struck, the Rupture meter by menace with its Fractures, the elites at
  them, the boss sealed until the Rupture. Waits on Ryan's marks (section 12's fresh start item)
  and the ramp's numbers (the long wall's placeholders first, the timer now its beat).
- **The map** (27 to 30 October): movement in hexes given in one go, water the one priced ground;
  six map shapes drawn by the seed, never by the domain; the horde wading and passing through
  itself; hunters at a ring of two taking the machine nearest a sealed-off prey; each domain's
  tileset on the painted ground. Waits on Ryan's reads running.
- **The ladder** (28 October): the enemy's three verbs (Silence, Purge, Cleanse), four buffs on
  the foes, the player's Purge, twenty-six recolours by tier. **The pricing pass** (28 October):
  floors in vanilla points by tier, heat as measured, the Railgun, the Coriolis, the rolled
  vanillas, the Howitzer, the two modules; Chain the conductor with a random charge. **Heat as a
  pillar** opened the same evening: the brief `docs/briefs/heat_pillar.md` waits on Ryan's
  answers; the cautious and shield personas and the overheat what-ifs are built and read.
- **Content**: five makers; 24 chassis (ten at tier one, nine at two, five at three), every one
  runnable; 81 components, none planned; 18 modules; four domains with 59 rank-and-file foes (19
  at tier one, 13 massive), 21 elites (6 wanderers), 13 bosses with 6 parts, 8 heroes and their
  promoted forms; 4 foe moves planned (the Warrior's Cover, an interpose; the Martial Artist's Counter and the
  Salamander's Ember Hide, retaliates; the Lich's Dark Rite). Every number is a placeholder: the stock pass's fills as its loops moved them.
- **Models**: every machine's by lowforge with its rig sidecar (joints, acts, gait, pins, fires,
  launches, counts, forms). The Wainwright & Sutler five and the Kestrel four are to judge
  running on Ryan's notes (the to-do); the Needletail's and the Giant Petrel's are first cuts
  until his session. The guard: a model names the component each pin's stock part is and the
  game wears a die against that record; every model has as many pins as its chassis has
  hardpoints (a test).
- **Balance, read by stage** (the bible's section 2 kill-time row; `docs/measurements.md`): the
  200-seed matrix on file (`docs/balance.md`, 27 October) predates the ladder, the numbered
  area, the blow's order, the compositions and the randomness pass, so the next 200-seed run
  on the desk machine is the first read of the roster as it stands (the to-do's engine line).

## Decided, not built

The tasks are the to-do's; this is the index of what waits.

- The Fracture's prize (section 12); the escorts' marks (`docs/bosses_proposal.md`) and the
  promoted forms' one move more for seven of them (`docs/heroes_proposal.md`).
- The planned foe moves (the Lich's Dark Rite among them); a silence carrier and a purge
  carrier once Ryan marks them (section 12); the jellyfish's EMP, Purge on a capstone's blow
  (its chassis session).
- The commander layer, the screens, the economy's verbs and loot (sections 8 and 10).
- The long wall's view (`git show 68381ff:docs/briefs/long_wall_build.md`, section 7: the two orientations, the
  threat rating's pips, the field scrolled along the wall), on Ryan's word after the hand-back.
- The pairs in the game (the bible's pair row): Hold The Line settled on its thirteenth round (3
  November); Night Shift's battle half and The Far Bank's map half on the pair page waiting on
  Ryan's ear; then the engine (a pair as one synchronized stream, the map choosing the track, the
  3 s flip) and each picked half into the forge's SHIP table.

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list). Ahead of all of it: **the refit pass** (`docs/briefs/refit_pass.md`, the direction
Ryan set on 9 November after his play of Phase 2: shields and vents leave the die, a component a
weapon or equipment, the shield innate and regenerating, cooling passive, the hold the heat
decision, component destruction off to test, two rerolls kept; the formation pass folded into it,
its proposal's grids re-cut under the new model and read by hull lost), in its brief's order: the
what-if and its first reads are in (9 November), his two reads of the trial, the model as
content, the formation pass and a guess at the elites' and bosses' numbers (10 November: the
brief's sections 5, 8 and 9); tier one only for now (his word, 11 November), and next his
answers on the first battle (the brief's section 10: the fourth machine's route is settled,
the first battle's shape and the boss's numbers by ramp band wait on him), beside his play of what landed, with the field's
dials (the to-do's Ryan list), and his answers to the brief's section 7, then the content still to come (the stock re-deal proper as a table in chat first,
the component pass, the heat prices, the foes' numbers after his play, the bosses' stat
blocks, what prices a round), the vocabulary, the rules and the rows. Then the long wall's other open item (the bible's section 12: the shell). Beside them, the rest of the skirmish code audit
(`docs/skirmish_audit.md`; its questions answered and its bugs built 8 November; the Ammit's Tap
is section 12's, its test the to-do's): its structural steps in order (step 3 built on
`ccr-8df9952c-4cccdf`, the mine's half gone with the slot mines on 9 November; then the bot's
and the screen's mirrors onto the engine,
then a 30-seed direction; statuses as data, the Face, the dead code, each refactor checked by
`tools/behaviour_trace.gd`), since its tangles bend every read after it. The
redesign moves every foe's blow and the battle's shape, so the 200-seed matrix (below) waits on
the refit and the audit's bot step. First after that: the 200-seed matrix
with the ladder's, the compositions' and the elites' cells on the desk machine (the to-do's
engine line), since the matrix on file predates everything since 27 October.

1. **The design sessions, from the briefs** (above): each decision a bible row, each brief
   retired once its decisions are rows and content. The chassis in this order (Ryan, on the
   inventory of 9 November: "Yes, go ahead"), the to-do's roster grouped to match: the locked
   pieces' footing first, since every rework designs locked pieces (his direction of 10 November
   is the bible's locked and tiers rows, `docs/locked_pieces_proposal.md` the detail, and a
   tweak round on six pieces is with him); the four back in
   design from the refit pass, the Polar Bear, the Whip Scorpion, the Swallowtail, then the
   Puffin after the heat prices; the built but unfinished (the Needletail, the Giant Petrel, the
   Musk Ox) and the gunship; the tier-one fronts (Minerva's lure tank, an Aphelion tier one);
   Claude's first rounds on his directions of 5 and 6 November; the rest as its session comes.
2. **The stock pass's tail**: Ryan's name pass; the Lammergeier's stock; the pricing pass's next
   reads (the bible's pricing row, section 11): the equipment ramp on the fresh start's tier-two
   and tier-three formations with tier-matched kits and the planner beside the greedy, the
   shields' and vents' numbers by tier as a fills proposal, the ladders per tier, the synergy
   holes as pieces proposed in chat (`docs/synergy_map.md`), the catalogue's tag pairs; and the
   heat session from its brief.
3. **The foes' fresh start and the pacing session: Ryan's marks and the reads**: section 12's
   fresh start item (the elites' names and numbers, the compositions' partition, the escort
   compositions, roles, the one rider a domain and enemy Shock) and the ramp's numbers; then his
   play of the clocks on the phone and the Fracture's prize.
4. **Balancing for real** (Ryan, 14 and 24 October: once the go is hashed out, the stock pass is
   in and the foes have proper formations): the runner's rows on the roster as it stands, the
   fours again, prices and tier ladders, the heat report, and Ryan's play deciding feel.
5. **The screens** (Ryan, 13 October: early, so the first thing built after the battle has its
   shape is a run he can play): a prototype hangar, the mission map and the draft.
6. **The economy pass** (`docs/economy_pass.md`): the runner's spending policy, then every price
   and yield with the offers one of each kind, a chassis on the shelf, the Favour dock as the
   gate's price, twelve to sixteen battles.
7. The rest in the standing order: Ryan's text; the domains' last engine (the planned moves, the
   bosses' open calls); the battery plan's rest (the props' fade, the 3D at 30); audio; art; the
   commander layer after a balance baseline; onboarding before a phone leaves the desk.

## Pages

Every page lives in Ryan's account and is republished by its URL (read first), its database
with it. A page's link goes into this file in the same commit as its first publish; the
commands are in `README.md`.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. The live page is v0.497, dated 9 November (the
  page's Version 502, published from main at `2d489f7` on Ryan's word, "republish the hangar
  page and the bible": main's file whole, since the live v0.496 matched `f048e67`'s byte for byte
  and so needed no merge; it carries the Lammergeier's rework, its row, the Gel's and the
  reinforcement row's slot-mine lines and the tables). Main's file is v0.506 since the boss's hex landed (its patrol retired, the vortex lower with the wall at the bottom), v0.505 since the third map list landed (the rift's five hexes on the field row, the undo and marks rows), v0.504 with the second map list's rows (the marks row
  rewritten, the pack, undo, gesture, Fracture, reconstruction and tears rows, the Badger's and
  the store's) on the shapes' rework's v0.503 and the hangar's Bench tab's v0.502, unpublished; v0.501 since the map
  playtest list landed (the boss's picture, the scenery under the painting, the tears row's
  read of 10 November and the hunters' declaration, on the map session's v0.500 and v0.498's
  Text tab rows: the hangar row's tabs and the shown-text row), unpublished, its republish on
  Ryan's word; `ccr-722ca9f0-yj8na3`'s file is v0.516, main's with the formation and refit
  session's rows (the hunters row's who-may-hunt and its settled hunting packs, the Foe roles row
  Decided with the flanker lines, the goblin's
  lesson, his call on its form and the pusher's yardstick, the recolour row's two rungs that
  changed their archetype, his calls on each and the Draugr, the scale row's guess for the
  elites and the bosses with the meter row's and the boss row's lines on it,
  the wall row's strike by the rating, the kit, shield, triangle, redirection, injury,
  command-die, Barrier and Ward, Puffin, Whip Scorpion, Polar Bear, Swallowtail and Musk Ox
  rows' refit lines, section 12's items, and from his second read the move row's 3 to 6, the
  grid row's and the three clocks row's lines on the depth and the fodder on trial),
  unpublished too. BASE for the next merge is `2d489f7`'s file. The live
  page may carry rows ahead of main's code while a branch has not landed (the music session's
  track rows: Hold The Line's settled pair and its trial notes, Night Shift's duelling basses,
  The Far Bank's fretless bass). Before
  republishing, read the live page; if another session moved it, publish a three-way merge onto
  it row by row (`tools/pages/bible_merge.py`: BASE the last publish both started from, OURS
  this branch's file, THEIRS the saved live source with the tool's wrapper line and its trailing
  newline and `</body></html>` stripped, so it matches the file byte for byte). A page that size
  counts as read only once every line of its saved
  copy is read, so a subagent reads it and publishes the merge. After main merges in, check the
  tables script's run against the file's tables before keeping it: a row it reverts belongs to a
  branch not yet landed.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each live copy read first and checked against
  the last publish's before it is replaced, and `edits`, `designs` and `text` read first. At the
  page's Version 219 (10 November, main's `f49a90f`, on Ryan's word, "Ok merge into main and
  republish the hangar"): the page with its Bench tab, his working sheet for a machine, the
  second tab (the roster by where each machine stands, one flat sheet a machine; no file and no
  collection of its own, every write an edit of the entry in `edits`, his notes, state and
  upgrade ideas under its `design.bench`), with the three files that had moved since: the
  vocabulary (the map session's four codex lines), `text.json` for them and `designs.json` for
  its stamp. The live page matched `5a490e5`'s file byte for byte before it was replaced, and
  each of the three its last publish. Version 218 (main's `5a490e5`) was the page with its Text
  tab, `hangar/text.json` new beside it (332 files) and `designs.json` with its stamp. Version 217 was
  the side session's publish of main at `2d489f7` (9 November, on Ryan's word, "republish the
  hangar page and the bible": the three content files the Lammergeier's rework moved and
  `designs.json` from its briefs, the live copies matching `f048e67`'s before they were replaced
  and main's after), recorded on its branch and so unknown to the Text tab's session until the
  two met here; version 216 was main at `f048e67`. `edits` empty, `text`
  empty, `designs` the two folded ideas (the Giant Petrel and the Needletail, briefed), and one
  name candidate of Ryan's, the Tesla Gauntlets of 28 September, still saying "the Armadillo's
  status" (his words of then, kept). The Text tab's ledger is empty until he signs. The page
  does not show the caches' models (they are no chassis).
  `build/hangar/designs.json` is one
  795 KB line, so a session that must read it whole before publishing writes it indented first.
  Its lit parts show as the phone's renderer shows
  them, the light eased by the power 1/2.2 as the game eases it (`MechRig.light`); every file
  the page reads is fetched with a stamp on the URL. Its database: Ryan's saved edits
  (collection `edits`), name candidates (`candidates`) and his marks on the briefs (`designs`, the
  Designs tab's).
- The roster analysis: https://claude.ai/artifact/QVLRVD8YXsK8ZUKY3A1vxo, rendered from
  `docs/roster_analysis.md` by `tools/pages/roster_analysis_page.py`; background since the go,
  retired once the last brief that cites it lands.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei; picks and notes in
  collection `picks`. It holds the boss art round's seventh sets
  (19 October), all picked on 26 October and cut; the README has the command that builds the
  Augur's sets as a page, and the fix order that worked is the bible's art row.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV
  (`tools/soundforge/melody_desk.html`; collections `parts`, re-seeded by `desk_parts.py`, and
  `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`);
  its source's generic foe-down pool lost "bogey eliminated" on 9 November, unpublished.
- The pair page: https://claude.ai/artifact/19BTqzwbJ4q8qoUxCZNtSW (`tools/soundforge/out/pairs/`,
  built by `pair_sketches.py`, the page `pair_page.html`): each pair on a live switch, Hold The
  Line's run as the game plays it, and the later rounds' pairs and A/B sets (Hold The Line's
  thirteenth, `hold_sketches.py`; Night Shift's tenth, `night_sketches.py`; The Far Bank's map
  half's fourth, `far_sketches.py`), at the page's version 22. A round whose files pass a
  publish's 64 MB goes up in two publishes: the new files first under the live page, then the
  new page with the rest, the old round's files removed.
- The engagement sandbox: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

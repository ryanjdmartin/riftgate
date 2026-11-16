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
- **The reboot is the rule of the shield and of heat, in the game since 15 November, and no
  session skips it** (Ryan, 13 November: "This is fundamental, I don't want it to get skipped
  by other sessions"; folded in on his "Go ahead on the fold and build"). `docs/rules.md` has
  the rule (The reboot) and `docs/briefs/refit_pass.md`, section 22, his rules, his rulings,
  what landed and every machine read against it. No chassis regenerates or cools: the two
  stats are what a grant adds to, and the validator refuses both keys on a chassis. The foes'
  numbers are still the ones sized against a shield that refilled. Read both before any work
  on a machine, a component, a module or a foe (`CLAUDE.md` has the rule).
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
- Tests: 1196 tests, 372,811 checks, green on `ccr-722ca9f0-yj8na3` (16 November,
  Brittle, over main at `7ac3902`). Before it, 1196 tests, 372,829 checks, green on the same
  branch (16 November, the
  marks' first three rule changes, over main at `d1b6827`). Before it, 1195 tests, 372,792
  checks, green on the same branch (16 November, the
  marks' renames, over main at `0eb2745`). Before it, 1192 tests, 372,768 checks, green on
  the same branch (15 November, the marks' cuts, over main at `c9e55a9`). Before it, 1196 tests, 372,909 checks, green on the
  same branch (15 November, the vanilla's 3 and breach's cut). Before it, 1197 tests, 372,937
  checks, green on the same branch (15 November, Ablate in
  Burn's place, its rule's ten tests in a file of their own). Before
  it, 1188 tests, 372,897 checks, green on the same branch (15 November, the reboot
  folded in: five tests of the switch's off side cut with it, over main at `0f5c801`). Before
  it, 1193 tests, 372,939 checks, green on the same branch (15 November, the vocabulary
  pass's marks folded, documents alone, over main at `196d802` taken in a merge). Before it, the
  same count green on `ccr-b7d5164e-1wtzzm` as it landed on main (15 November, the
  blade class retired, the Kite's hood whole to its mouth and the Giant Petrel's fifteenth cut,
  over main at `3d195e0` taken in a merge). Before it, 1193 tests, 373,127 checks, green on
  `ccr-722ca9f0-yj8na3` (15 November, the FOE BREACH dial, over main at `0bd1799`). Before it,
  1192 tests, 372,709 checks, green on the same branch (15 November, the foes' reroll drains read
  as they announce, over main at `a9a8ffa`). Before it, 1190 tests, 372,677 checks, green on the
  same branch (15 November, the rank and file's dial and Exposed's texts, over main at
  `038b22b`). Before it, 1189 tests, 372,295 checks, green on `ccr-b7d5164e-1wtzzm` (15 November,
  the blade class retired, the Giant Petrel's fourteenth and fifteenth cuts and the Kite's hood,
  one content test's rule narrowed, a locked weapon wearing no class). Before it, 1189 tests,
  372,483 checks, green on `ccr-b7d5164e-1wtzzm` (14 November, the Needletail's nineteenth cut,
  the Giant Petrel's thirteenth and the Kite's round pair, over main at `bbcf375` taken in a
  merge). Before it, on main,
  1188 tests, 371,561 checks, green on `ccr-722ca9f0-yj8na3` (14 November, the
  vocabulary pass's two rounds of records, no engine code moved; before that the
  basics' what-ifs and their dials; before that REBOOT on the bottom row's middle with
  REROLL centred again; before that REBOOT a drop's target
  alone, and shot trails the game's own; before
  that the dragged die's target and drop; the KEYWORD INK and TRACES switches cut with their
  two tests; before that the same day, 1189 with the reboot's control remade and driven by a
  finger's events, and a lone fight from the menu reading the trial dials). Before it, 1187 tests, 371,387 checks (13
  November, the reboot's what-if, its trial and the bot's first play of it, the block's rest
  timer cut). Before it, 1167 tests, 371,269 checks (13 November, the breaking shield's what-if and its
  two trial dials, over main's Kite). Before it, 1154 tests,
  371,110 checks, green on main (13 November, as `ccr-e3ddf00b-ilkwbi` landed
  again with the Kite's model rounds, over the Barrier's cooldown, the shield's reads and the
  anchor); git keeps the counts before. One
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
  `bpy==5.0.1` (about twenty seconds to install on 11 November). The first `--import` may rewrite four Prairie
  Dog textures and a model build the maker's review tiles: restore both
  (`git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`) rather than commit them.

## Branches

Everything is on main as of 13 November 2026; the formation and refit session's branch lands as it goes, below.
`ccr-b7d5164e-1wtzzm`, this session's (12 November), cut from main at `6112939`: the to-do's
roster pruned, then the Needletail's two modes and the Giant Petrel's hull on Ryan's design and
mix, reworked on his notes (How things stand, below); it took main at `4a0c9b5` in a merge on 13
November (the Kite's port forms, for the Needletail's cheeks; the bible, this file and the to-do
the conflicts, both sides kept); not landed, main takes it on his word.
`ccr-8af28d03-re9kz4`, the Ammit's rework of 12 November and what followed it that day (How
things stand, below), cut from main at `87da46f`, landed three times as fast-forwards on Ryan's
word: the rework, after taking main twice in merges ("Merge into main when you're done"); the
kill's flare once an attack, Empowered's up sword and the dead-code pass, on "Merge in main and
then reassess", which was misread (he meant main into the branch; main had not moved at that
fetch, so it was taken for a landing); and its records, once it had taken main at `f3e4841` and
`27956e7` in merges and checked its calls against them ("Great, clean up and merge back into
main"). It is merged and to delete with the rest.
`ccr-e3ddf00b-ilkwbi`, the Kestrel fast flyers' session of 11 to 13 November (The design sessions, below),
cut from main at `209112b`, took main four times in merges before its first landing, the last at `8d936cf` (the cooldown's
count, Instant, Sapped, the Wild Boar's and the Baboon's reworks: the engine's Rapid and Instant
branch joined to the Needletail's turn, the validator, the bot, the rules, the bible, this file,
the to-do and the generated vocabulary the conflicts, both sides kept): the Needletail, the Kite
and the Skua rebuilt on placeholder numbers, Sweep removed with every branch it caused, the Whip
Scorpion's release and the Musk Ox's salvo on every foe; main took it as a fast-forward on Ryan's
word ("Merge into main and republish"). It then carried the Kite's model rounds of 12 and 13
November (the third mount's hood, bore and round cut with the port rack and the port dish, the
tail on its body with its glowing vents, the wings' sharper sweep), took main at `ac48748` in a
merge (the bible and this file the conflicts, both sides kept, the bible's version past both) and
landed as a fast-forward on his word again ("Ship it, clean up and merge into main"); it is
merged and to delete with the rest.
`ccr-63a1309a-caa9mw`, the cooldown's count, Rapid's own switch-off and Instant (12 November, How
things stand below), cut from main at `fbce698`, took main at `243737d` in a merge (this file's
tests line the one conflict, both landings kept) and main took it as a fast-forward on Ryan's word
("All good. Clean up and merge into main"); it is merged and to delete with the rest (it moved
`sim/save.gd`'s three versions: the battle's 25, the run's 24, the quick run's 7).
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

Landed 12 November: `claude/clydesdale-design-concept-cg6uyz`, the Clydesdale's review (Ryan's
other session), cut from main at `2a9242e`. The hand-built stock guns gone on his word ("There's
no reason to keep hand build guns anywhere"): sixteen on seven models rebuilt in the cloud, each
stock gun its class, a mount's fits saying how deep each class sits (the Polar Bear's port guns
deeper and a round rack flush, "that's perfect for bear"). The Clydesdale's batteries on his
picks ("Checkerboard, and the stock split is fine"): its die folded into two batteries of four
with one shared Changeover, the battery up kept from fight to fight (Changed Over), Battery
Director retired, its model eight square ports in a checkerboard, each a real well under
trapdoors ("Sure, square ports"; "Should it be a hole?"), its brief retired (the bible's
Clydesdale row, the to-do's play line). Its five idle acts ("Those all sound good. Don't need the
old ones"; the swap judged good, "the change over animation looks good to me"), the drill a
broadside and the hatch check a wave on his notes of 12 November; the hangar's mode note moved
into tooltips. Each chunk landed on main as a fast-forward on his word ("Clean up and merge in",
"Merge in and republish", "Republish please", "Yes please"; it took main at `e286f8d`,
`45b3190` and `6acc4d7` on the way, each merge commit saying how), the hangar to Version 231
and the bible to v0.536 with them, 1132 tests green; wrapped on his "Yes, clean up, merge in
and wrap up. All good." Still working, and landing as it goes (11 November): `ccr-722ca9f0-yj8na3`, the formation and
refit session. Everything it had committed to `4c8dbf1` went to main with `ccr-4d58b054-3lyj0a`,
below; its work since landed on Ryan's word of 11 November ("I think it's safe to start sending
our code here out to main and having me test there in context"), the branch taking main at
`60a0e4d` and at `2a9242e` first (this file the one conflict, on main's form) and main taking
it as a fast-forward: the first battle read whole, the Rupture meter sized in beats, menace a
pack's threat rating, the stall guard's end and the tide's and the strike's trial dials (the
refit brief's sections 10 and 11, the to-do, How things stand). Claude's reading of "start
sending", his to correct: this session's later chunks land the same way once verified, this
branch alone. On 12 November ("Pull in main ... You can proceed with the steps as you see
fit") it took main at `8d936cf` and at `c717e69` as fast-forwards and landed the tier-one
baseline's read and heat's and the overheat's dials, no content moved, then took main at
`ea2f143` and landed the four breach or burn formations' cut ("Yes go ahead with 2"), 4-4-2
from the records and the second battle's read, and then, over main at `6112939` (a merge:
the bible's version, v0.557 above both, its scale row and section 12 with both sides' edits,
and the synergy map regenerated), the anchor (heat's prices, tier one's shields and its
foes' numbers: How things stand). Landed 11 November: `ccr-4d58b054-3lyj0a`, the chassis inventory and the locked pieces'
footing of 10 November and Ryan's round on the busted machines of 11 November (the Polar Bear
dealt again, the Buzzard's regen, the Nemesis's rage bar; How things stand), carrying
`ccr-722ca9f0-yj8na3` whole to `4c8dbf1`, took main (the music session's landing: the bible's
version, v0.521 above both, and this file the conflicts, both sides kept) and main took it as a
fast-forward on Ryan's word ("Merge this all to main. I'll move it from there"), again with the
Buzzard's zap settled and the Whip Scorpion's role map, and with the records' clean-up and the
pages' republish ("Everything else let's clean up and merge into main first before
proceeding"), and again on 12 November with the rest of its locked pieces' round (the Whip
Scorpion's rework and its Heliographic Death Ray, the Dingo's pieces, the pins, the Flakshot
Repeater, Sapped and the Lance, the Wild Boar's and the Baboon's reworks) over main's cooldown
count ("Your names are fine. Clean up and merge into main"). Again on 12 November, with the vent
blast's and Siphoning's code cut, Spillover a module (the Overrun Gearing), the Shift Whistle
dealt, the machine's level named tier, the release's broadside and the Whip Scorpion's two new
idle acts, on his word ("You can then clean up and merge into main"), the branch having taken main
four times on the way (the fast flyers and Sweep's removal at `aac6bfc`, the Ammit's rework at
`366b10e`, the dead-code pass at `ea2f143`, the four formations at `bf5158e`; each merge commit
says how). Where the dead-code pass, which cut the same vent blast and heat a blow without knowing
this branch's calls, stepped on them, this branch's stand on his word ("take ours as correct"):
the release's `Pays.FREE` and its comments, Spillover kept as the Gearing's, the Shift Whistle
dealt; its own cuts (Empowered a kill, the kept status, Reset and the other retired rules) stand.
It is merged and to delete with the rest. The Skua is his other session's (the Clydesdale's review landed 12 November). The formation and refit session's merges of main before it are in
its branch's commits. Landed 11 November: `ccr-7effd31a-u5z4gw`, the music session (Hold The Line's, Night Shift's and
The Far Bank's pairs passed and built into art/audio, How things stand), took main in a merge (the bible, this
file and the to-do the conflicts: the bible three-way on the v0.469 both files carried, main's
v0.506 kept whole with the session's track rows over it as v0.507; this file and the to-do on
main's trimmed form with the session's lines brought to it, the to-do's ticked lines pruned) and
main took it as a fast-forward on Ryan's word ("I think this is a good spot to ship everything to
main"), then again with The Far Bank's pair ("Oh I thought far bank was done?") and its move off the
Marsh's boss into the fights' pool; it is merged and to delete with the rest. Landed
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
  briefs, three slots open. Of the built, four went back to design with the refit pass and two
  are there still (the Swallowtail and the Puffin, a brief each; the Polar Bear and the Whip
  Scorpion handed back 11 November), three are
  unfinished by Ryan's own notes (the Needletail, the Giant Petrel, the Musk Ox) and the rest
  stand. The to-do's roster is grouped by what each waits on, in the order he took (Next, in
  order, item 1).
- Ryan's rework of the Ammit, 12 November (`ccr-8af28d03-re9kz4`, his own design, posed with
  "Thoughts?"; three holes raised in chat and his calls on each the same day; built on his "Yes,
  go ahead"): How things stand, below. Its stock's Ward piece still waits (the to-do).
- Ryan's round on the busted machines, 11 November (`ccr-4d58b054-3lyj0a`): the Polar Bear dealt again,
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
  five (`RIFTGATE_RAGE_DEBUG=1` fills it). 1115 tests green. The Buzzard's rework settled the
  same day (`kestrel_buzzard.md`, built after the heat pass with the Petrel's): its passive pays
  a flat shield cost on each weapon, unasked, for flat damage, plain when short; its cannon
  fires its whole field; heat still raises its regen; Chain a candidate branch. With it the
  bible's design test "What a machine does, it does unasked: no extra controls" (his words:
  "Everything should be automatic in this game, I don't want extra controls"). The Whip
  Scorpion's rework is his of the same day and built (the bible's Whip Scorpion row, v0.527: the
  tier-two formation breaker; nothing cools it; a pass, a turn it ends with an entry it could
  have spent, opens its valves on every foe as the enemy's turn ends once it holds 8 heat, 1
  each and 1 more for each heat over 8 (Ryan, 12 November, in place of a Sweep of the fuller
  rank at a shot of 2 a heat), the blows it took banked on top; its locked ray the Buzzard's old
  form on one foe), dealt again, its brief retired: `pass_release` a passive's rule, the release
  after the enemy's turn in the round and its forecast, the bot holding its die when the
  release beats its best spend, the screen playing the shots once the enemy's turn has (a first
  cut). Its locked piece is the Heliographic Death Ray (his keep of the name; id
  `heliographic_death_ray`), remodelled the same day as a steam-fed mirrored railgun in the
  mast's place, with a firing act of its own (the model rebuilt in a cloud session: a python3.11
  venv with `bpy==5.0.1` as `BPY_PYTHON`, renders under `xvfb-run`). Its open ends are the to-do's
  line (its bot's first heuristic, its runner row unread, its release on screen a first cut). The
  release fires the model's broadside since 12 November (the blast act, keyed by the passive's
  id in the sidecar's `fires`, a firing alone: `Effects.pass_release` gives the id and the screen
  winds the slice up before the blow), and two idle acts came in its place on Ryan's pick ("1 and 2,
  sure"): a pressure check and a heliograph sighting, first cuts, five at rest in all. The
  lure on every foe it left is the Shift Whistle, dealt at Minerva tier three on Ryan's word of
  12 November ("The Minervan lure all can exist in tier 3, sure"), and the vent blast's code,
  Siphoning and an entry's heat a blow are cut ("Siphoning can get cut along with the old vent
  code"; the heat a blow is the passive's). On main since the same day ("Yes that's perfect. Merge that into main"). The Dingo and the Prairie Dog are this branch's next (11 November), the
  Skua his other session's (the Clydesdale's review landed 12 November).
- The locked pieces' footing, decided 10 November (the bible's locked row, section 7, and tiers
  row, section 10; `docs/locked_pieces_proposal.md` holds what follows and the order; nothing
  built): a locked piece earns its lock as glue for its chassis's identity or as an exclusive,
  its number even with the kit beside it, a tier-N piece on a machine of tier N. A machine
  holds a tier (his name, 12 November: "Machines level is tier. Everything is tier."), bought
  in the hangar, cheap and gated by the Convergence, that lifts its stats
  and its locked pieces together, with a branch that tweaks a locked piece, never a stat and
  not the passive (its number may rise with the plain lift); a higher chassis arrives at its own tier, a wreck keeps it. One ladder of three:
  tier zero is tier one's power, a basic a plain tier-one piece owned from the start, a machine
  stocking up to its own tier at one and two; the two meet at the basics' numbers, tier one's
  coming down (his lean, so the refit's reads stand). Six pieces that are neither glue nor an exclusive yet (the
  Lance, the Flechette Pod, the Solar Flare Array, the Flakshot Repeater, the Plow, the Harpoon)
  get a tweak before any cut: Claude's first round and his first answers are the proposal's
  section 4. The Dingo's is settled and built (11 November, the bible's Dingo row: Shock on the
  Translocator, the harpoon the Hollow-point Harpoon, Brittle 1 and a pin on its target's Brittle for
  the round, Pinned a status of its own with Burning's beside it), the Prairie Dog's Flakshot
  Repeater (Brittle 2 on a cooldown of 1), the Stingray's Photosphere Lance (support, no damage: on
  itself or an ally, Empowered there and Sapped, his name, on the foe in front of it, the squad's
  spots one rule in the sim the screen draws by; Sapped coded in for either side, until after its
  carrier's next turn), the Wild Boar's (the Plow a Cleanse and a Barrier on itself; its
  Juggernaut Drive a quarter of each damaged front foe's maximum HP into the foe behind, and
  Juggernaut Breach after a Barrier; Spillover, retired from it, a Minerva module since 12
  November on his "Spillover can be a module", the Overrun Gearing, a session's name he kept) and
  the Baboon's rework (a Paradox for every debuff stack,
  five Suppressing; the Retrocausal Shroud and the Redshift Emitter, Sap a new keyword, on its
  backpack's pods; four hardpoints; the Solar Flare Array parked), all built 11 November; the
  Skua with the Pod's lock is a session of his own. A branch's shape is settled
  (two directions two steps deep, the second pick the deeper step or the one skipped). Every rework in design sorts its pieces on this footing.
- Kestrel: ten machines, eight decided, in content and fielded (the bible's Kestrel row; the hub
  `docs/briefs/kestrel_line.md`); the Puffin back in design (`kestrel_puffin.md`). The Magpie (a
  working name, a support engine) and the Snowy Owl (a stealth unit, leaning to Cryo: Ryan,
  5 November) are Ryan's next session, their briefs' first rounds unanswered. The
  Needletail's two modes (his own design) and the Giant Petrel's catamaran hull (his mix of the
  second round's two) are built since 12 November and reworked on his notes of that evening and
  13 November, for him to judge running (the to-do); the Giant Petrel's kit is still his to start.
- Wainwright & Sutler: ten decided, 3-5-2, nine built (the bible's roster row). The Swallowtail
  is back in design (`ws_swallowtail.md`, punted); the Whip Scorpion's rework is built (11
  November). The Swallowtail, the
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
- Aphelion: the line frame first, the Baboon's rework built (11 November, its tier and the
  Stingray's placed later), then the jellyfish; the Carrier on its own. Ryan's ideas of 4 November wait on his marks, each
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
- The Kestrel fast flyers, 11 November (`ccr-e3ddf00b-ilkwbi`; Ryan: "I want to revisit the Kite a
  bit. Something about it feels clunky to me", then the Kite "from the ground up, ignoring target
  tier and previous assumptions" and the three move-six flyers' identities under the long wall,
  "what does what and why you'd want one over the other"). All three are built on his go
  ("Yes build them with placeholder numbers"), each to be played (the to-do's Ryan list); the
  map is at the head of `kestrel_line.md`. It landed on main 12 November on his word ("Merge into main and
  republish"), main's work of those two days merged in (the Swoop printing no cooldown since, as
  every Rapid piece: Rapid's own switch-off is its once a round by main's count). Sweep is gone on his word of 12 November ("let's remove it and clean up
  all those exceptions and code branches that it caused"; the bible's Sweep row):
  the reach, its spots and per-shot rules, the wasted shot and the rank's bracket, the bot's two
  special paths and the salvo's routine; every weapon is one shape. Every Foe is a weapon's mode
  too, for the Whip Scorpion's release (1 on every foe at 8 heat, 1 more for each heat over) and
  the Musk Ox's salvo (a stand-in behind 8 ammo, its own session's), each foe struck as its own
  target, so a Shock on any is doubled and spent. The Flechette Pod is four strikes of 1; Ricochet hits its weapon's target alone, his text of that day. A first direction on the placeholder
  numbers is in `docs/measurements.md` (each alone on the patrols, 30 seeds, the old kit beside
  the new): the Kite where it stood on its duels and a little dearer on packs rated for two, the
  Skua's duels from five to fifteen rounds down to three or four, the Needletail alone a little
  worse off without the Overcharge Coil. A probe of the old Kite's turns is in `docs/measurements.md` (its die opened
  dark a round in five, its own heat cost it as much hull as the foes did, its reset fired under
  once a fight). Where it stands:
  - The Kite: built as his "Burst glass cannon" (the bible's Kite row, v0.532 on this branch,
    unpublished). Four entries and no reset; every weapon doubled on an unhurt foe
    (`target_unhurt`); the Pinion Driver the finisher, doubled on a foe at half its HP or less (a
    component's `finisher`; Claude's form, his to move); a kill recharging its shield whole
    (`refill_shield`); hull 12, shield 8 at a regen of 1. Both doubles read the foe's HP once a
    hit, so a two-shot gun is doubled whole or not at all. Gone from content: the flat heat, the
    dark rounds, Hot Streak, the d3 (the die's minimum is four again); Reset and a passive's
    cooldown, which the engine kept with no piece, left it on 12 November (the dead-code pass,
    below). A Kite leaving a fight at its heat maximum he
    declined (the bible's withdrawal row); Phased on a kill he kept for the shadow panther. The
    model's third mount is ahead of the canopy, a port under a low curved hood carried forward
    over the mount to four past it, every class there in its port form, its root inside the hull
    (new variants: the port gun, the port rack and the port dish on its telescoping mast, and
    since 14 November the round pair, two barrels out of a round receiver the port rack's diameter,
    in place of the port pair, as in the Needletail's cheeks; the blade standard), coming out of a round bore drilled two into the hood
    along the line into a little round cut under the weapon that frees the launcher, the trough
    it first lay in filled and the line 0.6 higher (a unit's drop from there tried and taken
    back), shipped on his "Ship it" (13 November); the dish the launcher's diameter; the tail's top edges chamfered, the intake taking the face's new shape, the tail
    six longer and carried on one root of the body's section in place of its dark keel and the
    old scoop, filleted into the shoulders, raked vents glowing in it over the boosters, flaring
    with them, the tail floating behind it; the wings' leading and trailing edges swept more,
    and the tail segment's face behind the canopy is an air intake (his, 12 November). Its brief is retired; his play is the
    to-do's.
  - The Skua: built as his "Ramping Dakka" (the bible's Kestrel row). Its passive gains a stack of Ricochet the first time each round one of its
    weapons damages a foe (the trigger `on_damage`; an effect's `once: round`, open to any effect
    an event fires). Ricochet is a buff that lasts the fight: after each shot of a weapon a
    strike of 1 more a stack at its target once the weapon's own strikes are done, with every
    effect but its area; hull damage halves it, rounded down. Its lock is the
    Hypersonic Swoop (a stack, Rapid, a cooldown of one). The Flechette Pod is an ordinary
    tier-one weapon in its stock (four strikes of 1 since Sweep went), and the validator
    lets a machine stock up to its own tier at one and two (the bible's tiers row, its
    validator's half). The Split-cycle Breech is a module since 12 November (his: "Turn the skua
    split strikes into a module"), Kestrel's, tier two for now.
    The bot counts the bounces and values a stack at a flat guess. On screen, unjudged: each
    bounce a quick beat of its own, "+N" in the die's passive box by a placeholder glyph. The
    model: the Pod a rack on the belly mount, the spine's pods air intakes and the pod burst
    act gone (his, 12 November). Its brief is
    retired; his play is the to-do's.
  - The Needletail: settled ("I agree with the Needletail, yes") and built on his go ("Yes build
    them with placeholder numbers"): two things a round, a weapon and an equipment every round,
    its die turning to a lit entry of the other kind (the static `one_of_each`; one entry to turn
    to is no draw, the die showing it in its passive box; the bot weighs the second action; the
    once-a-round gate that made equipment Rapid is gone from the engine). Its stock is the
    Designator and four guns since 12 November (his design's fourth mount a second Laser
    Carbine), so it marks every round. The chassis that orbits Exposed is one of
    the two unspecced mediums. Its brief is retired; his play is the to-do's.

## How things stand

What is built is run as `docs/rules.md` states it (its known gaps at the end); the bible's
section 12 lists what is built and what waits. The campaign's rules run headless only
(`sim/campaign.gd`); no screen shows them. The quick campaign is an experiment, not a feature
(Ryan, 28 October): no decision reads its runs. Landed in the last week, each with its reads in
`docs/measurements.md` and its judge or play line in the to-do's Ryan list:

- **The blade class retired** (`ccr-b7d5164e-1wtzzm`, 15 November, on Ryan's "The four you listed are
  locked pieces. The others need to be renamed into short range (i.e "melee" as per our definition)
  guns, or just sent back to design"): four silhouette classes (barrel, twin barrel, rack, dish) in
  `ContentDB.SHAPES` and `models_low.SHAPES`; the blade's shape, fire, flare point, every mount's fit
  and its 44 files in `art/models/shapes` gone (a model and three tiles a maker, the fire, their imports), the five sidecars that fitted it rebuilt (their geometry unchanged).
  The Chainsaw Claw, the Breaching Plow, the Knuckle of Fury and the Soulcutter Talons wear `none`,
  each built into its machine, the two that had no sound named naming the blade's, so nothing in
  play changes (the lunge and the sparks read the tags). The Gravity Knuckles and the Tesla
  Gauntlets are back in design, undealt (`"status": "planned"`, a barrel meanwhile); their names as
  short-range guns are Ryan's (the to-do). The hangar's classes show four, and the three pictures
  that wore a blade (two refits and the Dingo's mixed swap) were rendered again. The bible's
  hardpoints row holds the retirement and its exit (a melee piece dealt to a mount); its section 12
  question is gone.
- **The Kite's hood whole to its mouth** (`ccr-b7d5164e-1wtzzm`, 15 November, on Ryan's "There's a
  chunk of casing sticking out the top of the fairing", from the hangar's live view): the cut that
  drills the port's bore and the round cut under it was one hull through three rings, the one ahead
  raised to ramp the round cut's floor up, which sloped its top through the hood's crown over its
  last 0.7; the notch bared the bore's dark lining above the hood's line. Two hulls now, the ramp's
  cutting the nose alone. The hangar's live view can be driven headless in a cloud session: three.js
  0.128.0 from npm in place of its CDN, the page served locally from `tools/hangar_data.py`'s map,
  and Playwright aiming its camera (the scratchpad's `hview/shot.js`; not kept in the repository).
- **The Needletail's two modes and the Giant Petrel's hull** (`ccr-b7d5164e-1wtzzm`, 12 November;
  on main since 14 November, on Ryan's "Needletail looks great. Ship it.", the Giant Petrel's
  thirteenth cut with it; the Giant Petrel's model shipped at its fifteenth cut on his "These look great", 15 November, its kit
  still his to start): built that day on Ryan's design and his mix, then reworked on his notes of that
  evening and 13 November (the bible's Kestrel row). The Needletail: a jet's chined fuselage
  (its round second cut retired: "I didn't literally mean round like a rocket"), shorter than the
  first cut and short and flat for its width, 15.8 at its widest since the twelfth cut (17.4
  before), a long, low canopy amidships standing proud of it, the nose one long smooth taper to its
  point and its needle, reaching the body's width only at the canopy's front
  third, so the straight body behind it is short; it stands and fights
  in hover mode, four shorter boosters upright on swivels (the front pair on short canards beside
  the pop-up just behind the cheeks, the thicker rear pair each on a hub at the tip of a long tailplane whose outer panel
  rides in with it, under long, steep X fins), two pods raised out of dark slots in the upper
  chamfers behind the canopy, each mount leaning with its pod (a pin's `up`, new in lowforge), its cheek guns lying in bays
  on the nose's sides toward the tip, each under one long teardrop clamshell, point forward, on the band between the chines
  (the eighteenth cut, on Ryan's "an elongated clamshell that covers the whole cut area"; the trough and its sliding cover
  gone), the muzzle clear of the skin (on the sides as in
  the thirteenth cut, Ryan's candidate final at `49657a4` (its pictures retired from the hangar once the nineteenth shipped), after a day's trial on the
  upper chamfers; nearer the tip since the sixteenth, with the canards and the pop-up, and a slice cut from the middle so the
  ship is 103 from point to needle, the ports and canards 2 back again in the seventeenth, each bay dark to its rim and each
  gun's root under the skin in hover), every other class rooted at the
  bay's back in its port form (the port rack, the port dish on its mast, taken from main with the Kite's
  port; the twin barrels on a round receiver the port rack's diameter, `twin_barrel_round`, new on the
  nineteenth cut), the Fovea Designator a low wedge pop-up
  after a sports car's, its lamp behind
  a six-bladed iris that widens and narrows as it paints, the tail's whole face a cut-out exhaust
  round a needle nineteen long, in a dark rim behind a cobalt band; on the map its gait changes it into flight mode as it gathers speed
  (the cheek guns drawn back and in under the skin, each long clamshell's halves rolling shut over its empty bay about a
  hinge laid along the nose's taper, a joint's resting heading, new in lowforge, the pods sunk flush, the iris shut and the pop-up folded, the boosters level and
  run in along their fins, straight, the front pair's canards running into the body with them, the swept wings out near the canards and slid back 8 clear of the front boosters (5 until the nineteenth cut), small flat tips, their roots in the
  fuselage, the exhaust burning white-hot; stowed in hover, each wing's leading edge shows as a
  cobalt strip down the chine) and back as it slows, its transition act the same
  change on the spot. A near-black tile (`void`) lines the
  bays, Kestrel's "dark" tile being a mid grey its chrome lights, and since the eighteenth cut that near-black lining
  takes no gloss in the game (`MechView3D.toon`), the chrome having lit an open bay's far wall as a bright band; a bore's
  plain dark keeps its maker's finish since 15 November (matte, Kestrel's mid grey lit pale: the Kite's port mouth, and
  the Needletail's four pod intakes, which had gone white in its shipped pictures, rendered again). The Giant Petrel: the
  railgun hung under the centre bow as a chin turret since the eleventh cut and a Twin Autoguns on an omnidirectional dome on each of the
  deckhouse roof's back quarters, either side of the mast, bigger and on short pedestals since
  the seventh cut, resting facing forward in line with the ship since the eighth (the skirmish
  turns a gun from where it points as built, `MechView3D.aim_rest`; no mount rests off ahead now,
  so its test builds one), their arc round the outboard side to dead aft, their traverse swinging them there since the
  tenth cut (a turret's own act reach, new in lowforge; the turret rule's 70 degrees otherwise), their line of fire
  astern over the aerofoil, big and back down at the seventh cut's height, its fins raked back hard; three salvo racks in line down the
  roof rippling ahead of a raked mast, eighteen tubes, each rack at its own pace; the racer's
  boosters on plinths either side of a raised aft deckhouse under its aerofoil on fins at the hulls'
  outer edges, the navy's two back at the hulls' sterns; the deckhouse's front a sharp prow raked
  steeply back (since the eleventh a long spearhead laid back to about 26 degrees over the centre bow, a brow's peak over the glass,
  a cowl since the fourteenth, the peak a third longer and carried down each shoulder's outer edge to the deck, one band mitred at
  the roof's corners since the fifteenth, its lip dipping in toward the face all the way round), each twisted facet laid smooth and the bridge's glass a shell following it, a
  raked pane each side of the prow, high under the brow and tall since the twelfth (his pick from the sheets), bigger and meeting on the
  crease, mirrored, since the thirteenth, lower since the fourteenth and lower again since the fifteenth, a fifth of the front's height
  to three quarters; the foot's shoulders square, so each corner facet is flat and faces ahead, the whole of it an intake, a raised
  cobalt border round its mouth and louvres since the fourteenth, the louvres plain metal since the fifteenth (a plate's seams had
  lined up across them, Ryan's "panel lines through the vents");
  two long windows forward down each flank and aft of them a turbine on a web, its fan turning (`fan_l`, `fan_r`), its last stage turning
  astern against the glow in its nozzle (`fan_l_aft`, `fan_r_aft`), its nozzle burning with the boosters, a fin on it canted up and out at
  45 degrees (the twelfth, his "combine A and C", and the thirteenth); a cobalt spearhead down each bow; the cushion open fore and aft. A render round in the hangar's Models tab for each at every cut (the last cut
  as Before); the tests green at each.

- **The Ammit's rework** (`ccr-8af28d03-re9kz4`, Ryan's own design, 12 November; on main): "The 4
  claws are combined into one weapon that deals 1x4 instead, with Breach. They no longer gain
  Empowered on kill"; "Kills grant one Soul. At the start of a skirmish, or on kill, the souls
  flare, granting 1 Empowered per 5 souls"; "Soul Siphon: Consume up to 5 souls, granting 1
  Empowered per soul. Cooldown 3". His calls on the three holes put to him first: the Souls last
  the battle and carry no cap ("as part of the fantasy"); any kill in its fight banks one and only
  its own kill flares; the Siphon's round holds every Empowered on the field ("And I mean none,
  not ally or enemy"), and the hold stays off the kill flare. And later that day, the flare comes
  once an attack that kills, however many fall to it ("Flaring twice for an AoE is probably
  wrong, let's make it 'one of more killed' by an attack"), a double kill's Souls both in first.
  As built: a die of six (the talons one entry of 1 ×4 with Breach, the Siphon, four hardpoints);
  Souls its Ability, a chip with its count, since a count with no cap is no store; the hold the
  round's rule and no status, so a Ward turns nothing away. Named, since they follow from his
  words: the talons show one roll in six (17%, about 47% with both team rerolls; 50% and 91%
  before); each battle opens with the Siphon unplayable until the first Soul; the Coil, the
  Uplink and the Reliquary are no longer kept on it; a burn's tick or a Mine banks a Soul and
  flares nothing; its cooldown of 3 is the rest of its round and three rounds after. Shown text
  is a session's drafts (the Tap's line, the Souls' and the pin's entries, Consumes' second
  half, the trigger), on the hangar's Text tab since Version 240. First cuts for his eye: the
  Souls chip's ghost, the pin beside each Empowered, the Siphon's firing act (the threat's coil,
  set by hand in the rig sidecar and `models_low.py`; no model was rebuilt). The first read is
  `docs/measurements.md`'s, a direction at 30 seeds made on the flare's first form. His lines are
  the to-do's: play it, judge its marks, write or pass its text. Its names and its hold moved on
  his marks of 15 November (built 16 November; the bible's Ammit row): the passive is the
  Quintessence Reactor, the Souls are Essence, the Siphon is the Quintessence Tap, and the hold
  is Essence Flare, a buff on the Ammit that a Purge takes, where a pin stood beside every
  unit's Empowered.
- **Empowered's mark** (12 November; on main): a blade with an arrow up, Sapped's pair ("Yes use
  the up sword for empowered", from a mock, after his "Does shock and empowered have the same
  glyph?": one bolt, Shock's in a ring and Empowered's bare). The bolt is Shock's alone; Enraged,
  the golden rage and a foe's Empowered drew Empowered's mark and follow it; its pin is a smaller
  blade beside the arrow standing on the lock, a first cut on the to-do's judging line.
- **The dead-code pass** (`ccr-8af28d03-re9kz4`, 12 November; on main). It began with his
  questions of the flare's flag ("Why is the per for trigger refused, but still exists as an
  exception? Makes no sense") and of Empowered a kill ("also an exception then?"), and his worry
  ("our trigger system is just spaghetti in there"). Measured, the triggers read sound (one
  table, one function that fires an event's passives, one place that raises each) and the
  weight was leftovers: seven rules had lost their last piece between 7 and 12 November and
  stayed. On his "Yeah go ahead and fix it":
  - The standing rule is CLAUDE.md's: a rule leaves the engine with its last piece, nothing
    parked as a rework's leavings. `tests/test_leftovers.gd` holds it both ways: an effect kind,
    a trigger, a die entry's key or a keyword that no piece prints fails the build until it is
    cut or listed there with what it is, and a listed one that is printed again fails too.
  - Cut, each with its engine path, validator check, term, bot weight, tools' rows and own
    tests: the flare's per-foe flag; Empowered a kill and the kept status (the Ammit's old two);
    Reset and a passive's cooldown (the Kite's); the vent blast, with its rings, die mark and a
    vent's second kind, and the old Siphon entry's heat a blow with its Siphoning status (the
    Whip Scorpion's, cut by `ccr-4d58b054-3lyj0a` too, whose form stands where the two met; its
    passive's heat a blow stays); shield for heat at the round's start; a shock for a blocked
    blow; armour against one rank; the out-of-combat event with the battle's `fought` record;
    and an entry's unused label, the round preview's notes and the readers for saves no version
    loads. The saves' versions moved (the battle's 26, the run's 25, the quick run's 8).
  - Kept, on the test's lists with their reasons: the one pipeline's own steps and the trigger
    table's plain cells (the general path: the Ammit's flare took two such cells off the audit's
    unused list five days after it named them), the shield cost the Buzzard's and the Storm
    Petrel's settled briefs pay, and two fields a charged form sets.
  - His calls, settled the same day: Reset let go ("Let it go I think, I'm fairly certain there
    was a better way of building it anyway"; git keeps it at `90feac1`); Spillover, listed as
    unprinted and put to him wrongly by the time it was read, is the Overrun Gearing's (his
    "Spillover can be a module"). The stock pass's fills script, `tools/stock_fills.py`, retired
    too, its tables a second copy of the content's numbers that no longer ran (his "Retire the
    loop thing"); the balance loop, `tools/stock_loop.py`, stays, a lever kept landing in the
    content by hand.
  - Next, the to-do's Engine line: the check does not yet hold a passive's conditions, the foes'
    moves or a status to what lays it (four conditions, two foe moves and seven helpers only
    tests call are unused there, checked on main at `f3e4841`), and Structure 11 is untouched:
    a die entry's 73 fields are each written out by hand in several places, with no drift today.
    The audit's Unused list holds the measure.
- **The cooldown counts after its round; Rapid's own switch-off; Instant** (`ccr-63a1309a-caa9mw`
  from main at `fbce698`, on main the same day on his word, "All good. Clean up and merge into
  main"; Ryan, 12 November, on "So rapid cooldown 1 and a weapon cooldown 1 are
  different, right?", which they were not: one count, the round of the spend included, so a plain
  weapon's 1 cost nothing). A printed cooldown is now the rounds an entry sits out after its spend
  ("change the count so 1 is how I intended"), so the Flakshot Repeater's 1 sits out the next
  round as he set it on 11 November, and the Kite's grant is 1, the same rounds dark as its old 2
  (its text "sits out the next round", a session's draft). Rapid darkens its entry for the rest
  of the round again, its own and never printed ("rapid gets its innate cooldown zero back
  without the explicit display"): the printed 1 left the Pulse Vacillator, the Changeover, the
  Quick Reload, the Immelmann Booster and the planned Laminar Deflector, each playing as before,
  and the Needletail's gate's setup goes dark for the round as the rules had said. Instant is a
  keyword ("the rapid no cooldown pieces change to a new keyword: Instant (reroll after use, can
  land on itself)"): the die rolls again as the round opens, itself included, a spin on a
  stepping die, nothing dark, so the validator holds an Instant piece to a limiter; the Spin-Up
  is Instant (`spins` retired). The Nemesis's Knuckle of Fury goes out charged on five rage with
  Instant in place of the Breach (his answer to the one question asked: "Each reroll costs 5
  rage. Just swapping the Breach for Instant, everything else stays the same"), the Breach one
  direction of its upgrades. Retired with it, no piece printing it since 11 November: the roll
  again on a status (`rolls_again_on`, its vocabulary entry "Rolls again", the bot's rage-on-hull
  credit), Instant the one roll that may land on itself. A spend that wins the fight rolls
  nothing, Rapid's as the old roll again's. The die marks Instant on its edge with one chevron and
  a loop back onto it, apart from Rapid's two chevrons by shape; his to judge on the phone. Saves
  before it are set aside (the battle's 25, the run's 24, the quick run's 7).
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
  brief's section 5; nothing in `content/` moved): the injury rule went off in the game (its threshold left
  the engine on 15 November, Destroy a foe's rider in its place: the bible's Destroy row);
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
  battle for it, `docs/measurements.md`, and `docs/campaign_run.md` the refit session's run of 10
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
  basics are six, the four guns each making heat; every chassis regained its own `shield_regen`,
  one to three, until the reboot's fold-in of 15 November took the regen and the cooling off
  every chassis; the ten slottable shields and vents are planned drafts nothing
  deals; the machines back in design are undealt by `"status": "planned"` on their own
  entries, their kits still built (three since the Polar Bear came back on 11 November). Saves from before are refused (the three save versions).
  The trial's rows are gone (SHIELD REGEN, the last, with the reboot's fold-in); `--refit` and
  `RIFTGATE_REFIT` keep the what-ifs that still mean something (the README lists the parts). The
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
- **The Rupture in beats, built** (Ryan, 11 November, retiring the count and marking the first
  shape the same day: "I don't think the 4 to 5 guideline holds anything anymore. This is a
  different game now ... start this pacing and length discussion from scratch"; then "Try your
  lean first", "Let's go 1.5 and I'll see how it feels", "To me a clear field is its own
  reward, it's breathing room to reposition or get loot", "A duel doesn't have to be two
  rounds, who said that?", "I'd probably set the range at 10-30 minutes, with most falling in
  the middle ... the only reason to have more fractures is to send more elites, not
  necessarily to make it significantly longer"). Built: the Rupture is sized in beats of the
  tide, a beat a peak of Rift Pressure, two at every tier (`Ramp.BEATS`): what the opening
  places and the tide sends through its second peak, the tide's lightest patrol left, and an
  elite's part for each the tier calls (a chunk of a formation and a half on the meter alone
  that morning, its rating's four since menace became the rating, below); and a field
  cleared with the seal standing does nothing, the
  stall guard gone from the battle, its save, the screen's band and the runner. The
  multiplier's dial of the morning is the beats': SETTINGS → TRIALS → RUPTURE, 1 BEAT, 2 BEATS,
  3 BEATS (`Ramp.beats_trial`, `RIFTGATE_BEATS`). The bible's pacing row holds his calls, the
  count retired with the test it failed and the guard with his (v0.525); the rules follow.
  Why it was needed (`docs/measurements.md`, 11 November, pacing from scratch): as first
  built the meter asked nothing of the tide, the opening's packs and the elites filling it at
  every tier by about the fourth turn; a lone duel is 4 machine-turns of the player's time
  against a formation's 20, an elite's 21 and a boss's 36; an elite's fall was worth a third
  to one and a third of a formation by which elite rolled; and at a fixed number of beats a
  battle grows by itself, 7 fights before the boss through the second peak where tier one
  starts and 11 at tier three. The bot's first battle in the Meadow as built breaks the
  seal on its sixth or seventh turn after six or seven fights, the gate at 133 to 150 of 200,
  and the campaign runner's plain player reaches the Rupture in 18% of its battles where it
  reached it in 25%, a turn and a half later. Proposed and
  his to mark (the refit brief's section 11, nothing in content): a second flank patrol a
  domain, a picket of its own front-rank pushers beside its duelist ("Different enough that
  the same strategy doesn't strictly work on both ... We can make flankers out of pusher
  units if it makes sense"): three Goblins, two Needlers, three Revenants, the Peak open.
  Still his: his play of the beats and the elite's four, the first wave repeating the
  opening's formation, and what measures a battle's minutes.
- **Menace is a pack's threat rating** (Ryan, 11 November, on his "I'd hope that the elites
  menace should match between elites ... probably it should be standardized so all domains
  are equivalent": "Maybe just 1-2-3-4 for now to keep math simple. But yes this direction
  makes way more sense. We can tune difficulty to the value, within an acceptable band. It
  gives us an absolute unbiased benchmark. I think the value can stay unchanged by tier, as
  only salvage needs to scale"; and "Boss' menace rewards for salvage and anathema can be
  completely whatever we need to make the economy work, so the placeholder doesn't really
  matter now"). Built: a lone patrol one, a heavier patrol two, a formation three, an elite
  four and a boss's unit four as a placeholder, flat by tier (`ContentDB.worth_of`, a pip a
  hundred in the engine), read by the Rupture meter, salvage and Anathema alike. A pack's
  fall pays its rating; a pack a fight wore down has paid the share its strike at the wall
  has lost, the heads gone of the heads it took the field with, and its fall pays the rest,
  nothing past the rating or twice (`Battle.pack_paid`). Named, since they follow from his
  rule and were no question: the elite's fall is four against a formation's three, a
  formation and a third where the morning's chunk was a formation and a half, and it is the
  same in salvage and Anathema; a worn pack pays by the head, as its strike wears, simpler
  than the form put to him (a share by each foe's own numbers); salvage is eighteen a pip,
  set to bank what a battle banked (the runner's won battle 372 where it was 369); a first
  battle's Rupture is 13 pips in every domain; and saves from before it are set aside
  (battle 24, run 23). The sum of a foe's own numbers stays as its weight, the balance
  report's column beside the rating. The bible's tally row holds it, the sum retired with the
  test it failed (v0.528); the pacing, stall, Anathema and kill rows follow, the stall row
  saying that the yield prices no stall now, a pack the tide sends paying what the opening's
  does; the rules and the glossary's Menace, Rupture meter and Seal lines follow, drafts
  redrafted. Left to the economy pass: what a boss pays and salvage's growth by tier.
- **The anchor: tier one's real lines, its foes in the budget's band, and the Barrier left
  open** (Ryan, 12 November: "Remember that all the chassis numbers are on the table,
  including hull and shield. Important to get the convergence 2 fight tuned around real tier
  1s with real tier 1 numbers for damage, defense and heat, and then move on to the scaling
  for everything from there"; Claude's reading of "the convergence 2 fight", his to correct:
  the second battle, four machines at Convergence 1). Read first
  (`docs/measurements.md`, 12 November, the six built and certain tier ones): the runner's
  player meets the elite with one or two machines and loses it, so its battle measures its
  orders; every fight was read at its rating instead, and the battle whole by a scratch
  player that musters. At its rating nothing in tier one cost a real squad its budget but
  the formations once heat was real. Landed, each a placeholder. The player's side: heat's
  prices are content (every weapon three hotter, every chassis that cools cooling one more,
  the gauges kept; the HEAT dial now a point either side, COOLER, BUILT, HOTTER), and tier
  one's ten chassis take the low end of the shield scale, three quarters of the gauge and
  one less regen, never under one (6 to 12 and 1 or 2), since a level lifts hull, shield,
  regen and cooling from level one; hull untouched. The foes at tier one: the lone flankers
  a duel of three or four rounds (the whisker cat 12 hit points, the roc 14, the dullahan
  10), the wolf 7 and a bite of 4, the goblin 4, the treant 16 and the barrow giant 20 so
  their fights are six rounds, the gel's blow 2, the Peak's rank and file scorching 1 and
  the drake's stoke burning 2; the elites a number could move (the shaman 28 and 10, the
  Nob 60 and 18, the Old Man's maw 12, the Rust Monster 48 and 16, the Fell Rider 48 and 16,
  the Reaper 44); the Emperor Scorpion 60 and 14 and the Phantom Train's blow 16. At its
  rating a lone flanker now costs 2 to 4% of a four's hull, a hunter's pack 5 to 7%, a
  formation 2 to 9% with 5 the mean, an elite 0 to 13%, a boss 5 to 32%. The second battle
  for the mustering player: the Meadow and the Marsh won 65 to 85% with half to two thirds
  of the hull left at the end (80 to 90% with four fifths before), the Waste 45 to 70% with
  a third left (its bosses), the Peak 40 to 60%, its losses the gate's before and after.
  Consequences, named: the machines that read heat moved under the prices and follow in
  their own sessions (the bible's section 12 lists each); every foe a higher tier shares
  with tier one moved and stands unread there, and the elites moved at every tier; the
  runner's own player wins far less on the lower shields (the Meadow 45% where it won 70%),
  since it fights alone; and the first battle is harder for three machines than it was (a
  mustering trio with the Honey Badger won 40% of the Meadow's and wins 10%; it lost to the
  gate before, 40 to 85% of the time), so it is the first thing to scale from the anchor.
  The Barrier's cooldown followed the same day (Ryan: "Barrier can have a cooldown, yeah. I
  gave it a cooldown on the Boar's locked and that's a tier 2 piece ... you can't just
  protect forever"): every piece that grants one carries a cooldown of 1, the Halo Projector
  and the Blast Door as the Breaching Plow did, and the Fallen Weapon's haft is 16 and its
  eyes' gaze 8 with it, since the cooldown took the Waste out of the others' band. With it
  the second battle reads the Meadow 75 to 85% won, the Marsh 60 to 65%, the Waste 45 to
  55%, the Peak 40 to 60%, and the elites' mean 9.5% of a four's hull where it was 7.
  Two corrections to what this session first wrote, both in `docs/measurements.md`: the
  what-if it cited for the cooldown was two rounds dark, not one (the cooldown's count had
  changed on main the same day), and the Gargantuan King's twenty-round fight is no matter
  of heat, the squad blocking and bracing where it could fire because a round costs it
  nothing. The Storm Petrel in these reads is the machine as built, zap and all; his
  direction of 11 November takes the zap off it, and that session waited on the heat pass,
  which has landed. Open, his: the Barrier's place, the discussion he opened the same day
  ("Is it toxic? Is it worse than giving numerical shield? Should it be rare or locked? An
  argument could be made that a chassis with barrier is a sub for a Tank on a team"). The
  reads: a Barrier takes seven blows in ten from a foe whose kit is one blow a round and one
  in eight in a formation; with the Shoring Jack or a gun in the Halo's slot the same elites
  cost a four a fifth of its hull where they cost 9.5%, against a budget of a quarter, and
  the Gargantuan King's fight is ten rounds where three machines turning the Barrier made
  it twenty-three. What is left to him is the Barrier a basic with its cooldown, as content
  has it, or rare or locked with the Jack or a gun in the slot, Claude's lean, which brings
  down the numbers set with the Barrier there. Closed on his word of 13 November: a shield
  grant in the Halo's slot, with Overshield, and the gauge without its regen beside it, which
  this session leaned to on the 12th and put to him as a second package ("I fail to see how
  what you proposed is any different than what we had before when we had shield faces ...
  we cut that for a reason, because it wasn't working for balance"). It is the third of his
  three shapes of 9 November, the one he passed over, and the session had listed the shapes
  without holding its lean to the reasons: a block on the die is the loop his play found, it
  has to be found in the roll, it puts the shield back among the die's verbs and recovery
  back on the die, and as a number it had read skipped or the whole turn (the benches of 27
  and 30 October). The bible's shield row now carries those reasons with the forms they
  retired, so the next session meets them; the brief's section 14 has the re-read and what
  stands of the reads. His "more dramatic version", the cooldown on the machine "similar to
  Numbed", matters only if the Barrier stays a basic (section 13 has its read and its
  holes). His idea of 13 November for the shield itself is read and on trial, nothing
  decided: "What if we bring back that when a shield breaks, it absorbs the whole blow? It
  does not bleed into the hull. But in exchange, if a shield breaks, it's down for a couple
  of turns before it starts to regenerate again." Its block is a what-if in the engine, off in
  the game (`Skirmish.shield_break`, `shield_break_min`; `tests/test_shield_break.gd`); its
  rest timer left the engine the same day with the reboot's build (below), nothing coming
  back by itself there. Two dials on a debug build's SETTINGS → TRIALS: SHIELD BREAK (BUILT,
  BLOCK; `RIFTGATE_SHIELD_BREAK`) and BARRIER BASIC (BUILT, NONE; the refit what-if's
  `barrier=none`, the Armoured basic in the Barrier basic's slot on the stock dice). The
  reads of that morning, the rest still on the dial (`docs/measurements.md`, 13 November):
  with the Barrier off the basics and a rest of
  two the fights of every day do not move (a formation 6.6% and 6.8% of a four's hull), an
  elite costs 12.2% where it costs 19.8% and a boss 18.5% where it costs 37.7%, no die spent
  and a boss's fight 6.2 rounds where it is 7.0, which is about what the Barrier basic is
  worth today (9.5% and 21.4%); the two together are worth twice either; the second battle
  reads as content's but for the Waste, where a breach passes a shield. Its holes, in the
  brief's section 15 with the bench and Claude's read: it is the Barrier's shape, so a foe of
  one blow a round falls to two fifths of its cost and a blow's number tunes nothing against
  a shield that stands; a point of regen back after the rest stops a whole blow, a quarter
  to a third of what the rule stops; and a blow finds a shield at rest once an elite's fight,
  the bot spending a third fewer dice on defence under it. His question on those reads the
  same day set the method for the fundamentals, now a rule in `CLAUDE.md`: "is it too much
  defense? ... our enemies aren't set up to threaten that type of defense ... we need to be
  thinking theoretically and critically about the system as a whole and how it fits together,
  and build simple models perhaps, before slamming it against the whole game as it stands."
  The model is `tools/shield_model.py` (seconds, no content: four machines, the same damage a
  round in each shape, the shield under each rule) and the frame is the brief's section 16.
  By the model the block is no more defence over all and a wall against the lone blow (64%
  of it reaches a hull as built, 26% with the block), which most elites and bosses are today,
  so the reads above measured that mismatch; what threatens it is a breaker the shield's size
  and a blow behind it, and it is the one shape of his three where a kill answers a big blow
  (the breaker's kill saves twice its own damage), the delay alone and the shooter's rule
  being answered by who gets hit. So the clause and the foes' kits are one decision, and the
  kits are next, proposed in chat against the model before any content or run. His play of
  the trial waits on them. He then asked for other shapes ("Think outside the box for a
  second ... Those 3 I just pulled from the top of my head"): nine are on a bench in the
  brief's section 17, four of them run by the model (`--bench`), and Claude's three to take
  further are one bar for heat and shield, a shield that comes back when a machine rests,
  and a block a machine calls once a fight. His answer: one shape first ("we need to find one
  that works, first, before trying to balance more"), so the shield for each maker is
  parked; a reboot that takes longer with every break, with the block or without; and the
  heat bar as one gauge filling from hits and heat. The model has a fight that ends for both
  (`--fight`; the brief's section 18): the growth is a rule a player would seldom meet, the
  first reboot's length is the dial, and without the block no reboot rule moves a fight; the
  one gauge is one currency, heat costing from the first point where as built it is free and
  then a wall, coherent and a rework of heat's economy. He then laid the pieces out as a
  menu to splice, and the model plays whole builds of them (`--builds`; the brief's section
  19). Claude's splice, his to take or leave: a shield that takes its number and does not
  regenerate, down at nothing until its machine passes a turn and back whole the round
  after; heat that cools only on a pass; an overheat that puts a machine down the same way.
  One verb and one state; a dud die is a pass and so a recovery; heat's price is the shots
  between passes (29%, 31%, 34% of the squad's hull at 2, 4, 6 heat where as built reads
  28%, 28%, 51%); it protects as the shield as built does in fights a sixth longer, and
  every threat to it is in the foes' vocabulary today. Dropped by the model: a pass that
  refills any shield or lands the same turn (the turtle), heat against the shield's regen or
  maximum, one bar as a first step. The block stays a clause for later, with foes built for
  it. He then stated the working shape himself (the brief's section 20 has his nine lines):
  no regen and no cooling; a break allows a shutdown and an overheat forces one; a shutdown
  recovers both meters; and "You cannot manually shutdown, so the game is to either try to
  play around it, or time it." It departs from the splice in that line (a turn passed
  recovers nothing unless the shield is down or the machine overheated, so the overheat is
  the one vent a machine controls and the hold goes) and in each condition paying out the
  other meter. The model plays it (`--shutdown`): about the shield as built, 3 to 13 points
  more hull lost in a four-round fight, level at six, half to two thirds of it in a long one
  against a lone hitter. His words leave two places open, and each is a row: what an overheat
  costs past the turn (nothing more, and a gun's heat reads 32%, 33%, 34% at 2, 4, 6 and a
  foe's heat costs nothing; the burn as today, a tax of 7 to 17 points no play avoids; the
  shield down at once, 32%, 38%, 42%) and when the recovery lands (the same turn is the
  turtle, 4% where the rule loses 33%). Claude's picks, his to take or leave: the shield
  down at once and no burn, the recovery as the next round opens, the block out until foes
  are built for it. His answer settled the recovery ("a whole turn of staying exposed with
  no shield") and moved the shape, since the forced form "takes away player agency, despite
  being thematic": "letting the player ride at max heat and the reboot being a choice to
  vent heat and recover shield. If the shield is not empty and the unit reboots, I'd feel
  like we should empty the shield." That is the working shape (the brief's section 21;
  `--choice`): no regen, no cooling, a reboot any turn for the turn, the shield to nothing
  at once and both meters back the round after, nothing forced. By the model the choice
  costs nothing in protection beside the forced form (35% and 35% against the lone blow);
  his emptying rule closes the stall (a squad that reboots at half a shield loses 5% to a
  foe that strikes every machine with a standing shield kept, 69% with it emptied); heat is
  priced on a slope (32%, 35%, 40% and 6.6, 7.0, 7.8 rounds at 2, 4, 6 heat); firing past
  the maximum is the wrong play and reading the foes' picks the right one; and the foes it
  wants are in the vocabulary today. It comes with fights about a third longer in rounds at
  the model's numbers. Open in it, his: what a shot past the maximum costs while a machine
  rides (the model keeps today's burn). The answer also lists the three differences he
  asked for between his statement and the splice. His go the same day: "Yes let's go for it.
  Dump the rules spec here first before we start", with three rules of his own (heat past
  the maximum stays, shown as an uncleanseable debuff, a stack a point, and anything that
  cools takes the stacks first; a broken shield "cannot gain shield by any method"; an
  overheat's triggers fire once until the reboot) and the point he calls undecided: at the
  maximum, burn hull or stop the spend. He ruled the same day (the brief's section 22 has
  his words and the spec as ruled): "I agree on burn over stop"; the burn is every stack at
  every turn, building "until the player is essentially forced to reboot, or die", since "in
  the old spec, overheat wasn't punishing enough ... We tried x3 damage and it still didn't
  stop the bot"; one shield-break trigger and one overheat trigger between reboots; a reboot
  only for a machine that has "spent nothing"; "Barrier is barrier, it's a buff, it sits in
  front of shield and hull"; and a shield spend or cost may break its own machine ("you can
  break yourself"). Left for after, his: the foes' Burn and an audit of every rider and
  keyword. The Dingo does not act twice in a fight, his correction: its two actions are on
  the map, and its passive's line, the engine's words, the rules and the bible's cars row
  now say so. The machines are read again against their briefs in section 22: the Storm
  Petrel, the Buzzard and the Puffin read differently by their settled reworks, and
  nineteen designs in briefs are reached by the rules. **Built the same day as a what-if and
  folded into the game on 15 November** (his "Go ahead on the fold and build";
  `tests/test_reboot.gd`, each line of the spec; the brief says what landed): no chassis
  carries a regen or a cooling, what is granted staying; `reboot_mech`
  the act, for a machine that has spent nothing, undone like a spend; every stack burning at
  every end of the player's turn and nothing settling; the first overheat between reboots
  breaking the shield; every shield gain refused while it is broken; the recovery as the
  round opens. Its switch, the REBOOT dial and `RIFTGATE_REBOOT` went with the fold-in, the
  SHIELD REGEN dial and HOTTER's one more cooling with them. REBOOT is a drop's target in the
  middle of the bottom row,
  between END TURN and UNDO, REROLL centred under the dice as it was (his option of 14
  November, after REROLL was tried at the row's left: "keep it centered and put reboot on the
  bottom middle between end turn and undo"; a reroll is the undo's floor, so UNDO onto REROLL
  is the dearest slip on the screen, and a target that takes no press parts the two buttons),
  and a die dragged onto it is the one way in ("dragging is the gesture we already have, we
  should stick with that"): dashed at rest, lit and pulsing with a die in hand, filled under
  it, the drop taken a thumb's width past its edge, a touch passing through it. The first
  cut lit for a die's open readout alone (his "So I can't actually trigger a reboot"), and
  the presses built in its place that day were cut on his word; heat past the maximum, a
  broken shield and a reboot under way each wear a chip, and a broken shield's gauge a
  dashed frame (the screenshot pose `reboot`). The three states are terms since the fold-in,
  Overheated, Broken and Rebooting, each a draft for his writing. The fight bot has a first play of it
  (`Policy._reboot_first`, `_reboot_idle`), so the runners finish a fight under the rule.
  First cuts, his to judge running: where the control sits, the chips, the die of a
  rebooting machine. A first read of it (`docs/measurements.md`, 13 November, a direction;
  today's foes were sized against a shield that refills, and the bot's play is a floor):
  every fight at its rating costs 1.6 to 2.4 times its hull and runs a quarter to a third
  longer (a formation 10.7% of a four's hull where it costs 5.9%, an elite 14.8% for 9.5%, a
  boss 37.1% for 21.4% with 93% won for 98%), a machine rebooting about once a fight, none
  stalling. **Next, his: his play of the trial; then the audit of every rider and keyword
  and the foes' Burn, each a first round in chat.** His notes on the list the same day:
  the Dingo's line is his now ("May move and act twice during each turn of the map
  phase"); a lure is activated, "So it's a choice. They can have a safe turn if they want",
  which corrects the list's first draft; what grants regen, cooling, flat shield or flat
  heat reduction he expects in a kit, a locked piece or behind a synergy, no strict rule;
  and a shield spend may not be standard fare, "because it's so expensive".
  His marks on 4-4-2 are in ("That's probably fine for 4-4-2 for
  now": the brief's section 13 has the table with his words, each open place its chassis's
  session's). Also open, his: the first battle's block (not scaled:
  on the anchor's numbers a mustering trio with the Honey Badger wins 0 to 5% of the
  Meadow's first battles where it won 40%; at three fifths for its elite and boss and three
  quarters for its rank and file a trio keeps its hull, and the trios with the Badger still
  lose the wall); the Waste's bosses and the Peak's clock; the Prairie Dog alone. The
  muster rule and the fight-at-its-rating read are scratch probes; the runner still plays
  the defence rule. The bible's triangle, scale, shield and Barrier rows and section 12 (v0.569);
  the rules' chassis, basics, heat and scale lines.
- **Four formations cut toward the budget, 4-4-2 to work with, and the anchor** (Ryan, 12
  November: "Yes go ahead with 2. Also, let's look at 4-4-2 right now so that you're working
  with correct tier 1 chassis for testing. Remember that all the chassis numbers are on the
  table, including hull and shield. Important to get the convergence 2 fight tuned around
  real tier 1s with real tier 1 numbers for damage, defense and heat, and then move on to
  the scaling for everything from there"). Landed in content, the breach rule untouched: the
  sandworm 14 hit points and a maw of 3 (36 and 8), the zombie knight 4 and a cleaver of 3
  (8 and 6), the magma elemental 14 and a fist of 4 (40 and 8), each keeping its plate, and
  the Peak's bomb 4 (8), its salamander and drake 4 (5). The sandworm ambush, the knights'
  vigil, the ember pyre and the magma vent cost a trio of real tier ones 5 to 15% of its
  hull where they cost 8 to 57% (`docs/measurements.md`, 12 November; twenty seeds, four
  trios, a direction), about twice a plain formation: a breach every round goes no lower
  on numbers, a blow on a count would, and that is a kit. The plate was the multiplier (a
  cold gun's 2 does 1 through it), so the hit points came down and the plate stayed.
  Consequences, named: the same foes stand in tier-two compositions (the wyvern roost, the
  grenade volley, the gargantuan king's herd, the skeleton king's court) and the salamander
  in an elite's brood, lighter with them and unread, tier two being scaled from the anchor
  after; the magma elemental's codex draft, unsigned, no longer calls its fist the biggest
  hit on the Peak. 4-4-2 from the records is the refit brief's section 13 and the bible's
  section 12: the six built and tier one under any reading (the Honey Badger, the Skua, the
  Storm Petrel, the Prairie Dog, the Cassowary, the Cottonmouth) are what the tuning uses,
  each maker's four his to mark (the Dingo down; both the Wild Boar and the mole; Kestrel's
  two of the Puffin, the Magpie and the Snowy Owl; Aphelion's fourth). The anchor, Claude's
  reading of "the convergence 2 fight", his to correct: the second battle, four tier ones
  against a tier-one rift at Convergence 1. The runner's player wins the Meadow and the
  Marsh seven times in ten there with nine tenths of its hull when the seal breaks, where
  the budget spends about half by then, and the Waste and the Peak one time in six, the
  formations not why (the Waste's rows did not move with the cut). What followed is the
  bullet above. The bible's scale row and section 12; the rules' scale line.
- **The player's side at tier one: the baseline, and heat on a dial** (Ryan, 12 November:
  "Pull in main. Many of the machine reworks are done, so they can be included in the pass
  ... You can proceed with the steps as you see fit"; the order agreed the day before, the
  machines' dice, heat, the foes' numbers, then hull and shield; what prices a round parked
  again, "Slice and Dice doesn't escalate mid fight, slay the Spire does. We have to see
  what fits after the other pieces are in place"). The branch took main at `8d936cf` and
  again at `c717e69` (the fast flyers rebuilt, Sweep removed, the Ammit's rework). Main had
  settled most of the dice: every tier-one stock die is basics beside its locked pieces, so
  what is left of the re-deal is a handful of placeholder slots (leans in the refit brief's
  section 12, nothing landed) and the tier-one slottable pieces' numbers. Read first, tier
  one against the hull budget (`docs/measurements.md`, 12 November, at `8d936cf`): the
  formations with no breach cost 1 to 6% of a trio's hull against 5%, the four that breach
  or burn 20 to 46% (both of the Peak's), the elites nothing to twice their quarter, the
  Waste's bosses and the Phantom Train walls for a trio. Heat as a pace, read and on a
  dial: every weapon three hotter with every chassis that cools cooling one more brings
  the bot to its limit about once a machine in a formation fight where it met it once in
  ten, in fights no longer; prices with no more cooling starve the long fight. It is no
  content yet: main moved under the read with another session tuning heat-reading machines
  on today's prices (the Whip Scorpion's release against its gauge the same day), and a
  price on every weapon moves each of them. So a debug build's SETTINGS → TRIALS has HEAT
  (BUILT, +2, +3, +4; the next launch; `Settings.HEAT_SPECS` over the what-if's `hotter` and
  `cooling`, which now leaves a chassis that cools nothing alone and moves a rewritten
  shot's heat with the guns) and OVERHEAT (×1, ×2, ×3; `RIFTGATE_OVERHEAT`; the skirmish's
  forecast row shows the hull it burns). The shape went into content the same day with the anchor (the bullet above), the dial
  re-based a point either side of it. Open, his: the shape by his play, what an overheat
  should burn (the bot overheats rather than holds and plays no better at two), whether
  equipment carries a price, and the heat-reading machines' numbers.
- **More spawns than the Rupture needs, on trial** (Ryan, 11 November: "I think we should try
  to lean for noticeably more spawns then the minimum number required for our target
  completion speed. When I was playing I felt the need to chase every pack down, since that
  felt possible. I think that's wrong. More pusher and flanker packs, even if it means that
  each needs to do less to the wall, is better"). The rule built that morning is the minimum
  he names: the Rupture takes nine pips of the field's ten. Nothing of the game's rule moved;
  two dials are on SETTINGS → TRIALS for his play: TIDE, ×1, ×1.5, ×2 (`Ramp.tide_trial`,
  `RIFTGATE_TIDE`), how many packs the opening places and each wave sends, in whole packs,
  the Rupture's size left on the game's own tide so the extras are a choice and never more to
  kill; and STRIKE, 10, 7, 5, 3 (`Battlefield.strike_trial`, `RIFTGATE_STRIKE`), what a pip
  of threat rating strikes the wall for. The floor player's reads (`docs/measurements.md`,
  11 November; three trios in the Meadow, twenty seeds a cell, a direction): at the game's
  tide it has killed 82 to 91% of all that had come when the seal breaks; at half again 70
  to 74%, five or six pips standing, the seal half a turn sooner and the gate where it was;
  at twice, half, with the hull at 38 to 59% and two trios of three winning 5% and 15%. The
  strike moved none of its wins, a lower one turning a fallen gate into a wipe: it never
  declines a fight, so it cannot show the wall spent to save hull, which is his play's to
  find. Claude's lean for his first play, ×1.5 with the strike at ten, and the holes (the
  elite's demand rides on the strike; salvage still pays by the pack; a multiplier compounds
  with the ramp, so the game's form is the ramp's counts and the Rupture a stated share of
  them, two pips in three at ×1.5) are the refit brief's section 11; the bible's pacing row
  carries his lean and section 12 what is open (v0.529).
- **One elite, the first battle read whole, and 4-4-2** (Ryan, 11 November, before the restart
  above: "the 3 fractures, with the current rate of fill, felt short to me"; "battle one
  should only serve one elite"; "we restructure the tier list from 3-5-2 to 4-4-2 ... I'll
  pose that in the chassis session"). Tier one sends one elite already, at its first Fracture.
  The first battle read whole on the meter as first built (`docs/measurements.md`, 11
  November; three trios and a four, the runner's player, 20 seeds a cell): a longer meter is
  more turns and more patrols, never more formations, and the gate pays; the first battle is
  no gift for the floor player in any domain (won 40% to 60% in the Meadow, 15% to 55% in the
  Marsh, 0% to 15% in the Waste, 0% to 5% on the Peak), the boss's first block alone moving it
  little, since that player loses before the boss; and a domain's first two formations are
  one composition on every seed, the first wave sending the opening's again. 4-4-2 is his
  lean and his to pose in the chassis session (the briefs README's Tiers).
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
  flat cut of the boss reaches the Meadow's first battle and not the Waste's or the Peak's
  (its length is answered since, the bullet above).
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
  on main since 11 November: a machine holds a tier, bought, lifting its stats and locked pieces; tier one
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
  Splash's shape round its slot, plain through each foe's own Brittle and armour, in strike order,
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
  spend's order rows; Sweep itself, its wasted shot and `RIFTGATE_MISS_DEBUG` went on 12 November,
  the fast flyers' block above): a single-target weapon's hits, their riders, the death check, the spend's
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
  Thunder Ape's mode), Brittle on a machine (the World Eater's pin), the opener; thirteen bosses, three a
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
  rockets, shell and casing; shot trails, kept as the game's own on 14 November ("adds a lot
  to both immersion and to readibility. Let's keep it"), their switch cut. All first cuts for Ryan's
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
  Godot 4.8-beta2 for the MSAA fix, the player's AA MODE. Waits on Ryan's phone reads; two are
  in (14 November): the keywords stay coloured ("it's fine coloured") and the map keeps its
  traces, and the two debug switches that set each against its other form are cut (KEYWORD
  INK, TRACES).
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

- Exposed for the foes (Ryan, 15 November, his third to fifth rounds; the bible's row in
  section 5): a machine's armour of every kind for nothing until the end of the next round,
  and the whole field's targeted intents on it as that round opens, up to its predicted
  death, the rule that foes never overkill kept; tier two and up, one machine at a time, a
  Lure wins. No foe carries it. It is the foes' pass's (the to-do's Engine list).
- His marks on the vocabulary's table (15 November, all eighty-two rows; the proposal's
  section 18 has each with its read, and the to-do's Engine list the build in parts), what
  is not built yet: Phased as he ruled it; and for the foes' pass,
  Drain, Steal and the drained reroll as their units' own text, countdowns an elite's or a
  boss's mostly, a fall free to do more than strike. Until built, content and the engine
  run each of those as before.
- A foe's move need not take a component's shape (the same day; the bible's row on the foes'
  rule set, the proposal's section 19): the direction for the foes' pass, with Claude's
  proposal of a move as a short list of steps. Nothing of it is built.

- The Fracture's prize (section 12); the escorts' marks (`docs/bosses_proposal.md`) and the
  promoted forms' one move more for seven of them (`docs/heroes_proposal.md`).
- The planned foe moves (the Lich's Dark Rite among them); a silence carrier and a purge
  carrier once Ryan marks them (section 12); the jellyfish's EMP, Purge on a capstone's blow
  (its chassis session).
- The commander layer, the screens, the economy's verbs and loot (sections 8 and 10).
- The long wall's view (`git show 68381ff:docs/briefs/long_wall_build.md`, section 7: the two orientations, the
  threat rating's pips, the field scrolled along the wall), on Ryan's word after the hand-back.
- The pairs in the game (the bible's pair row): Hold The Line's pair passed on its twenty-seventh round,
  Night Shift's on its thirty-fifth, at 96, and The Far Bank's on its eighth (10 and 11 November: "Full
  pair for HtL is good to ship"; "Keep 96. I think this is a good spot to ship everything to main"; "Oh
  I thought far bank was done?"), all three built into art/audio by the forge's SHIP from their
  sketches' `ship`: each track's shipped half where it played (Night Shift's map half now at 96, Sound's
  TEMPO with it; The Far Bank's battle half the shipped track itself, in the fights' pool since it came
  off the Marsh's boss, 11 November: "Take far bank off of the boss and add it to the regular pool", so
  no domain has a boss theme now), its new half beside it (`music_hold_the_line_map`,
  `music_night_shift_battle`, `music_far_bank_map`), all six halves played in the game since 11 November
  (Ryan: "let's pick the track when the battle starts and loop it. The player can change the track in
  the menu easily. Only put in the three finished ones for now"): each pair one
  `AudioStreamSynchronized` (`Sound.PAIRS`), a battle picking its pair as it starts (the next of the
  three after the last battle's, the first at random) and looping it, the field on the map half, a fight
  flipping to the battle half in place over 3 s from ENGAGE and back on the field, the pause menu
  changing the pair on the half the screen plays; Low Ground, The Crossing and Full Bore play nowhere
  until their pairs pass. The rest in a music session of Ryan's own (11 November: "I'll resume the
  remaining tracks in another session"): the map halves of Full Bore and The Crossing and Low Ground's
  battle half, each on the pair page at its first round.

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list).

**First: the vocabulary pass's build** (Ryan, 15 November, on his marks and his answers of
the seventh round: "Go ahead on the fold and build"). `docs/vocabulary_pass_proposal.md` is
its record: six rounds, his marks on all eighty-two rows (section 18), his answers and the
go (section 20), and his direction for the foes' moves (section 19). **The reboot is folded
in** (15 November: the rule out of its switch; the chassis's own regen and cooling and the
overheat that settles cut from the engine and from content; the three states terms; the
refit brief's section 22 says what landed). **Ablate is built in Burn's place on both
sides** (the same day; the bible's Ablate row, `tests/test_ablate.gd`): a machine's is a
point a stack off its shield and then its hull as the player's turn ends, where its Burning
was heat; the foes' numbers are unmoved, his to size. **The vanilla is 3 in content and
Breach is cut on both sides** (the same day; the bible's breach row and its vanilla row):
the plain basic guns deal 3 and the Carbine 4; every blow of a foe's meets the shield and
then the armour, thirty-four foes' moves plain blows at the numbers they had; ours is a rule
written on the piece, "ignores armour", on the Ammit's Talons, the Wild Boar's next weapon
after a Barrier and the Overclocked Railgun, whose tier is the component pass's. The BASIC
GUNS and FOE BREACH dials went with them. **His marks' cuts are built** (the same day; the
bible's area, Purge, retaliation, Destroy and rerolls rows): Splash, Silence, Overshield and
Retaliate are gone with their paths, terms, glyphs and tests, the Howitzer and the Shrapnel
Recuperator printing Spread 1 and Penetrate 1, the Retribution Thurible a planned draft and
the Nemesis's fourth hardpoint a placeholder gun; a granted reroll is no buff, landing at
once past the round's two with the REROLL button lit while the die in hand would grant one;
no blow destroys a component by its size, Destroy a rider on a foe's blow that no foe
carries yet; and the Djinn's Unmake reads Purge 1. With them a break the fold-in had left
on main is fixed: `tools/balance.gd` read the reboot's removed switch and would not parse,
and `tests/test_leftovers.gd` now loads every tool script. **His marks' renames are built,
with the words that left the keyword list** (16 November; the bible's Armoured, Ammit,
Dingo, funnel-web and Wild Boar rows and its row on the foes' rule set): Swap, Web and
Spillover are rules written on their one piece, the die's star and the piece's own text;
Follow-up is off the player's list; Jam lays Jammed; Pinned; Recover and Heal name a foe's
flat healing; the Ammit's passive is the Quintessence Reactor, its count Essence, its piece
the Quintessence Tap and the Tap's hold a buff on the Ammit, Essence Flare; Supercooled
says Cryo 1; and a foe's Armoured ends as the foes' next turn opens. **Three of his marks'
five rule changes are built** (16 November; the bible's rally, Regenerating and primers
rows): a rally reaches its rallier too; Regenerating is a point a stack as the carrier's
turn comes and then a stack fades, grants adding; and Primed is the third primer, a stack a
weapon fired lending Ablate 1, on a foe a stack a move that strikes. No number moved, so the
foes that regenerate regrow less in all and a rally of 1 leaves its rallier nothing: the
foes' pass sizes both. **Brittle is built** (16 November; the bible's Brittle row): Flak
and Crushed are one word and one state on either side, a point more on every blow a stack,
halving as each round ends, so a foe's Brittle on a machine is whole for the foes still to
strike that turn and half for the next. One foe carries it, the World Eater's Pin at 2.
**What rides behind, in the to-do's order**: Phased granted at the round's end; then
the anchor read again as the baseline. **Then the foes' pass**
(the to-do's line): Exposed's carriers and its engine, the moves his marks renamed or
moved onto the unit, the countdowns off the rank and file, a fall free to do more than
strike, and a move as a short list of steps if he takes section 19's proposal.
The table of every rider, buff and debuff (`docs/vocabulary_table.md`) stands with its page
(Pages, below) as the record of his marks until the pass retires.
With the pass, on his proposal, the tier-one
bench: placeholder pieces, each the vanilla with one thing traded and priced to read as the
vanilla alone ("the plain vanilla gun is the benchmark for 'viable,' not 'good'"), the
proposal's section 13, built after his marks. Then the foes' kits against the frame (who
the reboot protects and what threatens it: the brief's section 21; the approach to the
defence side he asked for, a shield in standard blows, a fight in cycles and a hull by its
budget, is the proposal's section 14), a small model first, no shield or hull
renumbered before it; tier one's numbers at the anchor
to the hull budget, since today's foes were sized against a shield that refills and cost
about twice the hull under it, and with them the stock basics' numbers, which are sized
against the same foes (his logic of 14 November, open: the vanilla gun one under the
standard fodder's hit points, riders paid in damage, the gun that deals one more paid in
heat; the refit brief's section 23 has it read, with `tools/basics_model.py`; his scope is
the basics and tier one, and a standard foe of 5 is set aside, the point being the same
question at any size). **It is on trial behind three dials** (a debug build's TRIALS: BASIC
GUNS, HEAT with two off, TOP BASIC; the what-if's `basics` and `top`), read by the bot the
same day (`docs/measurements.md`): a vanilla of 3 with a point or two of heat off gives a
formation back the 4.5 rounds it ran before the reboot, at 8% of a four's hull where today's
basics take 6.0 rounds and 10.7%, and an elite and a boss stand within a round and a few
points of hull of the anchor's (a boss 24 to 27% for 37%), so most of what the reboot added
to tier one's fights was the basics themselves; his play of the dials is next; then his play of
the anchor; then the scaling the paragraph below already orders, the first battle down and
tiers two and three up. His play's notes for those numbers (the bible's section 12 has his
words): a stack burns one hull, his pick to start; he overheated a lot, and today's basic
guns were priced against a cooling of 2 the reboot removes; some foes took "a shot too
many", which a vanilla of 2 does on a fifth of tier one's formation slots. Beside them, his: the
machines the rule reaches, each a design session as his brainstorm yields them.

Ahead of the rest: **the refit pass** (`docs/briefs/refit_pass.md`, the direction
Ryan set on 9 November after his play of Phase 2: shields and vents leave the die, a component a
weapon or equipment, the shield innate and regenerating, cooling passive, the hold the heat
decision, component destruction off to test, two rerolls kept; the formation pass folded into it,
its proposal's grids re-cut under the new model and read by hull lost), in its brief's order: the
what-if and its first reads are in (9 November), his two reads of the trial, the model as
content, the formation pass and a guess at the elites' and bosses' numbers (10 November: the
brief's sections 5, 8 and 9); tier one only for now (his word, 11 November), tuned on the
second battle with real tier ones before anything is scaled from it (his word, 12 November;
landed the same day with the Barrier's cooldown: the brief's section 13 has what landed, what
is open and 4-4-2 for his marks), next his play of the anchor and his word on the Barrier's
place (the brief's section 14) and on the first battle's block, then the first battle scaled down from the
anchor and tiers two and three scaled up, and his
play of the Rupture in beats and of the tide's and the strike's dials, and his marks on the
flanks' second patrols (the brief's section 11), and his answers on the first battle (section
10: the fourth machine's route is settled, the first battle's shape and the boss's numbers by
ramp band wait on him), beside his play of what landed, with the field's
dials (the to-do's Ryan list), and his answers to the brief's section 7, then the content still to come (the stock re-deal proper as a table in chat first,
the component pass, the heat prices, the foes' numbers after his play, the bosses' stat
blocks, what prices a round), the vocabulary, the rules and the rows. Then the long wall's other open item (the bible's section 12: the shell). Beside them, the rest of the skirmish code audit
(`docs/skirmish_audit.md`; its questions answered and its bugs built 8 November; the Ammit's Tap
settled by its rework of 12 November): its structural steps in order (step 3 built on
`ccr-8df9952c-4cccdf`, the mine's half gone with the slot mines on 9 November; then the bot's
and the screen's mirrors onto the engine,
then a 30-seed direction; statuses as data, the Face, the rest of the dead code (its rules with
no piece went on 12 November), each refactor checked by `tools/behaviour_trace.gd`), since its tangles bend every read after it. The
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
   design from the refit pass (the Polar Bear and the Whip Scorpion handed back 11 November),
   the Swallowtail, then the Puffin after the heat prices; the built but unfinished (the Needletail, the Giant Petrel, the
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

- The vocabulary pass's table, with his marks: https://claude.ai/artifact/Bmq4rxZEpFZznLJ8cLmtko,
  built from `docs/vocabulary_table.md` by `tools/pages/vocabulary_marks_page.py` and published
  with the `db` capability (Version 3, 15 November, from `ccr-722ca9f0-yj8na3`, with the
  fifth round's rows, once his marks were done). Each of its eighty-two rows takes a mark
  (KEEP, CHANGE, CUT, ASK) and a note, saved in the collection `marks`, a document a row
  keyed by the row's name as a slug (`mark`, `note`, `name`, `at`). **His marks are complete**
  (15 November, "My marks are done": forty-six kept, twenty-five changed, eight cut, three
  with a note alone; twelve of the rows were seeded from his calls in chat and he left those
  as they stood) and the proposal's section 18 is their fold, every note in his words. The
  page stays as the record: a session reads `marks` again before it builds from them
  (ArtifactData, `list`), in case he has moved one, and never republishes while he is on
  the page; a row renamed in the table loses its mark's key, so move the document with it.
  The page retires with the pass.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change, on Ryan's word. The live page is v0.564, dated 13
  November (the page's Version 512, published from main at `7b23422` on his "Sure" to the offer:
  main's file whole, dated the 13th since rows of that day are in it, Version 511 a minute before
  it the same file under the 12th's date; the live v0.547 matched `aac6bfc`'s file byte for byte
  before it was replaced, and the live copy matches `620c717`'s after). New since 510: the rows
  landed on main from v0.548 to v0.564, the Ammit's rework (its row, Souls and Pinned Empowered in
  the tables, Siphoning and Empowered a kill out of them), the dead-code pass's cuts and the rows
  that leaned on them, the triangle row's heat prices, the anchor's tier-one lines, Reset let go,
  the Barrier's cooldown and place, the shield's worth and the grant withdrawn, tier as a
  machine's word, and the looks row's Kite for its shipped mount. BASE for the next merge is
  `620c717`'s file. Main's file is v0.569 since
  `ccr-722ca9f0-yj8na3` landed again the same day (section 12's breaking shield, his idea of 13
  November read as a what-if, and the method his question set), unpublished, its republish on
  Ryan's word. The
  live page may carry rows ahead of main's code while a branch has not landed. Before
  republishing, read the live page; if another session moved it, publish a three-way merge onto
  it row by row (`tools/pages/bible_merge.py`: BASE the last publish both started from, OURS
  this branch's file, THEIRS the saved live source with the tool's wrapper line and its trailing
  newline and `</body></html>` stripped, so it matches the file byte for byte). The tool's read
  counts as viewing the page, its saved copy needing no whole Read (it said so on 11 November);
  the saved copy is about 700 KB, so a few lines of Python do the comparing (its first line and
  its closing `</body></html>` dropped, it is the file), and a subagent the merge when one is needed. After main
  merges in, check the tables script's run against the file's tables before keeping it: a row it
  reverts belongs to a branch not yet landed.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each live copy read first and checked against
  the last publish's before it is replaced, and `edits`, `designs` and `text` read first. At the
  page's Version 280 (15 November, from main at `4514a2c`, the branch `ccr-b7d5164e-1wtzzm` landed
  there on Ryan's "These look great. Let's clean up and merge into main"): main's `vocabulary.json`
  (the vocabulary pass's rounds), `text.json` from the merged tree, `renders.json` with the Giant
  Petrel shipped, and the Needletail's eight candidate-final pictures removed; the live copy
  Version 279's own, so the page and main match. Version 279 (15 November, from `ccr-b7d5164e-1wtzzm` at `a2f89ca`, ahead of main): the
  Kite's model with its crown whole to the mouth, the Giant Petrel's fifteenth cut, its model and
  its ten pictures with the fourteenth's as Before, the Kite's port close-up, and `renders.json`;
  the page untouched since Version 278. Version 278 (15 November, from `ccr-b7d5164e-1wtzzm` at `6ad897c`, ahead of main): the
  Giant Petrel's fourteenth cut, its model, rig and ten pictures with the thirteenth's as Before;
  the blade's five class models, its fire and its class picture removed, `shapes.json` and the
  muzzles without it, the four other rigs that fitted it, `components.json` with the six pieces,
  `motion.js` without its class look, `text.json` with the two back in design; the Needletail's
  eight pictures and the Kite's port close-up rendered again for the bores' dark, and the two
  refits and the Dingo's mixed swap without the blade; the live copy found to be Version 277's
  own (its version id) and each replaced file matched to that publish. `edits` and `text` empty,
  `designs` the two folded ideas. Version 277 (14 November, from main at `d80a996`, the branch `ccr-b7d5164e-1wtzzm` landed
  there on Ryan's "Ship it" for the Needletail): the Giant Petrel's thirteenth cut, its model and rig,
  its ten pictures (a turbine from astern the tenth) and the twelfth's as Before; the Kite's rig with
  its port's round pair, a close picture of it, and its entry from main (the live one was the 12
  November note, main's of the 13th never published); the round pair's class picture in place of the
  port pair's, which is gone with its models and burn; `shapes.json` and the muzzles without it;
  `content/chassis.json`, `components.json` and `foes.json`, `designs.json` and `text.json` brought
  up to main's (the live content was Version 260's); every replaced file read first and found older
  than main's or this branch's last publish. `edits` and `text` empty, `designs` the two folded
  ideas. `edits` and
  `text` empty, `designs` the two folded ideas. Version 254 (13 November,
  from `ccr-e3ddf00b-ilkwbi` at `0c03430`, ahead of main): the
  Kite's last round, its wings' back edge swept to match the front. The Kite's rounds went out
  from that branch as they were made (Versions 234 to 254, its model, rig and four renders, the
  port forms' variants and pictures, and `renders.json` with its Kite entry and port-forms block),
  over five publishes from elsewhere in between: main's Version 240 below, and Versions 245, 249,
  251 and 253 from `ccr-b7d5164e-1wtzzm`, with its Needletail's and Giant Petrel's render entries
  and its own `designs.json` and `text.json`, none of them on main yet. Until that branch lands, a
  publish from main builds `renders.json` from the live copy, keeping those two entries, and
  leaves its `designs.json` and `text.json` alone. Main has the Kite as live but for its note
  and its `when`, which since say it shipped (13 November), not yet published. Version 240 (12
  November, main's `f3e4841`, on Ryan's word, "Ok, republish the hangar on
  main"): the nine files moved since 233 (the five content files with the Ammit's rework, the
  dead-code pass, the four formations' numbers, the Overrun Gearing and the dealt Shift Whistle;
  the Ammit's rig sidecar with its Siphon's firing slice; the Whip Scorpion's, its broadside the
  release's and its two new idle acts; `designs.json` and `text.json`), the page unchanged, every
  live copy matching 233's build before it was replaced; `edits` and `text` empty, `designs` the
  two folded ideas. Version 233 (12 November, main's `aac6bfc`, on Ryan's word, "Merge into main and
  republish"): the twenty-two files moved since 232 (four content files with the three fast
  flyers, Ricochet, the Breech and Sweep's removal; the Kite's and the Skua's models and rigs;
  `pins.json`, `shapes.json` and `muzzles.json` with the Kite's third mount and the port gun; the
  Kite's and the Skua's renders, the old ones their before, and `renders.json`; `designs.json`
  without the three flyers' briefs; `text.json`), nine new (the port gun in five metals and its
  fire, its picture, the Kite's port with a gun and with a round rack) and two removed (the Skua's
  old pictures from above and of its strafing run), the page unchanged, every live copy matching
  232's build before it was replaced (`designs.json` and `text.json` but for their stamp) and
  main's after. `edits` and `text` empty, `designs` the two folded ideas. Version 232 (12
  November, main's `3e6912e`, on Ryan's word, "Yes") was the thirteen files
  moved since 231 (the three content files with the cooldown's count, Instant, Sapped, the Lance,
  the Wild Boar's and the Baboon's reworks; the Baboon's model, rig and pins, its four mounts and
  the backpack's two locked pieces; its renders, the stock rebuild's its before, and
  `renders.json`; `designs.json` without the Baboon's brief; `text.json`), the page unchanged,
  every live copy matching 231's build before it was replaced and main's after. `edits` and `text`
  empty, `designs` the two folded ideas. Version 231 (12 November, main's `fbce698`, on Ryan's
  word, "Yes please") was the same nine
  for the Clydesdale's wells, broadside drill and hatch wave (its model with the wells' linings, its
  rig, its four renders, `renders.json`, and `designs.json` and `text.json` for their stamp), the page
  unchanged, every live copy matching 230's before it was replaced. Version 230 (11 November, main's `3d5f98f`, on Ryan's word, "Republish please"): the nine
  files the Clydesdale's idle acts moved (its model with the radiator and its heat texture, its rig
  with the five acts and Changed Over's copies, its four renders, `renders.json`, and `designs.json`
  and `text.json` for their stamp), the page unchanged, every live copy matching 229's before it was
  replaced, and the live copies match main's after. Version 229 (11 November, main's `da18614`, on
  Ryan's word, "Pull in main and republish"): the page with the Models tab's mode note moved into its buttons' tooltips (his ask
  that evening: the paragraph under the model window kept the controls out of reach) and the six
  files the Dingo's pieces moved (`ccr-4d58b054-3lyj0a`: three content files, the Dingo's rig,
  `designs.json` and `text.json`), every live copy matching 228's before it was replaced, and the
  live copies match main's after. Version 228 (11 November, main's `d2c024d`, on Ryan's word, "Merge in and republish"):
  the 69 files that had moved or arrived since 227 and one retired render removed (the Nemesis's
  old roar), the page unchanged: the vocabulary (the glossary's Menace, Rupture meter and Seal
  lines, redrafted for menace as a pack's threat rating and the stall guard's end), `text.json`
  and `designs.json` (the refit brief, the Clydesdale's brief retired), the seven models rebuilt
  with their stock guns as classes (their model and rig files, the Polar Bear's fits with depths)
  and their renders with the old as Before, `renders.json`, `pins.json` (the Clydesdale's eight),
  the page's motion.js (a fit's depth, no hand-built flares), and the Clydesdale's batteries and
  square ports (two content files, its model, its renders with a second-battery view). Nobody had
  published since 227, every live copy matching `9fde357`'s build but for its stamp, and the
  live copies match main's after; `edits` and `text` empty, `designs` the two folded ideas.
  Version 227 (11 November, published from `ccr-4d58b054-3lyj0a` at `9fde357`, ahead of main, on Ryan's word, "Can I see this in hangar?", and again for each of his four notes on its model: the gun slid back in its mount, the vents more upright, the gun forward by half the slide, then nudged back): the Whip Scorpion's rework, the eight files that had moved since 222 (three content files, `designs.json` without its retired brief, `text.json`, `renders.json`, its model and rig) and its three new renders; nobody had published since 222, and the live copies match the branch's after. Version 222 (11 November, main's `892d804`, on Ryan's word, "Everything else let's clean
  up and merge into main first before proceeding"): `designs.json` with the Whip Scorpion's brief
  after the Buzzard's settlement and `text.json` for its stamp, over Version 221 of minutes before
  (main's `60a0e4d`: the two files that had moved since 220, `designs.json` with the Buzzard's new
  brief, the Whip Scorpion's role map and the briefs' table, `text.json` its stamp alone; nobody
  had published since 220, the live copies matching its build but for the stamp); the page
  unchanged, and the live copies match main's after. `edits` and `text` empty, `designs` the two
  folded ideas. Version 220 (11 November, main's `9ebf74b`,
  on Ryan's word, "republish the hangar and the bible") was the fourteen files that had moved since 219 (the five content files with the refit's
  model, the formation pass, the Polar Bear's seal, the Buzzard's regen and the Nemesis's rage;
  `designs.json` and `text.json`; `foes.json`; six rig sidecars, their stock pins following the
  Halo Projector) and the thirteen new foes' sprites (the four flanker lines and the Draugr), the
  page itself unchanged. Version 219 (10 November, main's
  `f49a90f`, on Ryan's word, "Ok merge into main and republish the hangar") was the page with its Bench tab, his working sheet for a machine, the
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
  (`tools/soundforge/melody_desk.html`; collections `parts`, re-seeded by `desk_parts.py`, a
  sketch's by `desk_parts.py --sketch <round>`, and `melodies`), at its version 8: a note bends a
  quarter-tone either way, bars run in 4/4, 7/8 or 12/8.
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`);
  its source's generic foe-down pool lost "bogey eliminated" on 9 November, unpublished.
- The pair page: https://claude.ai/artifact/19BTqzwbJ4q8qoUxCZNtSW (`tools/soundforge/out/pairs/`,
  built by `pair_sketches.py`, the page `pair_page.html`): each pair on a live switch, Hold The
  Line's run as the game plays it, and the later rounds' pairs (Hold The Line's twenty-seventh and
  Night Shift's thirty-fifth and The Far Bank's map half's eighth, passed and shipped,
  `hold_sketches.py`, `night_sketches.py` and `far_sketches.py`; the real basses, `real_bass.py`), at
  the page's version 88. A version holds at most 256 MiB of files, so a round's new files go up
  with the old rounds' removals beside them. A round whose files pass a
  publish's 64 MB goes up in two publishes: the new files first under the live page, then the
  new page with the rest, the old round's files removed.
- The engagement sandbox: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

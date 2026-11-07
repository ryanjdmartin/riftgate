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
  foeforge's `generate` and `fix` have no machine until a route for the image model is chosen.
- Godot: the project runs 4.8-beta2 (published 29 October), the newest build at the last check,
  30 October; 4.8 stable is not out. The next check is due 13 November (`CLAUDE.md`, Session
  handoff); date this line again after each.
- Tests: 1017 tests, 259,659 checks, green (7 November, `ccr-56b5169d-lsa2rg` with the long
  wall's Phases 1 and 2 and the cut, Godot 4.8-beta2; either map view on 6 November); about four minutes in a cloud session, twenty on a slow one. A cloud
  container whose import predates a branch's new `class_name` fails the screen and rig suites
  with a parse error ("MuzzleFlare" not declared): run `--import` again first.
- A cloud session gets Godot and the first import from the repository's session-start hook
  (`.claude/hooks/session-start.sh`, registered in `.claude/settings.json`: the release asset
  `Godot_v4.8-beta2_linux.x86_64.zip` from `godotengine/godot-builds` into `~/bin`; without the
  hook, fetch it in one command and unpack and run it in another, since Auto mode refuses one
  line that fetches and runs). Screenshots there need `xvfb-run -a` and
  `--rendering-method gl_compatibility` (Mesa's llvmpipe: draw calls are true counts, frame
  times mean nothing). Models build with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1` (about twenty minutes to install). The first `--import` may rewrite four Prairie
  Dog textures and a model build the maker's review tiles: restore both
  (`git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`) rather than commit them.

## Branches

Everything is on main as of 5 November 2026 but the two branches still working below. The
branches that landed on 3 to 5 November, each a session of its own, fully merged and to delete
from GitHub and the desk machine (the command is in the audit's last chat;
`git push origin --delete` the merged ones, then `git fetch --prune`):
`claude/aphelion-minerva-chassis-9qf6cy` (Ryan's chassis session of 4 and 5 November: his ideas
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

Still working (6 November; every other branch on GitHub is merged): `ccr-7effd31a-u5z4gw`, the
music session (Night Shift's and The Far Bank's rounds on the pair page), whose bible rows land
on the live page ahead of its branch, so a republish merges onto the live page (Pages); and
`ccr-56b5169d-lsa2rg`, Ryan's redesign of 5 November (the battle as the defence of a long wall,
the packs as designed formations, the shield the fight's resource: his direction and Claude's
first round as `docs/long_wall_proposal.md`; the build brief `docs/briefs/long_wall_build.md`,
written 6 November on his word for the session that builds it: Phase 1 the sim and the runners
with a hand-back, Phase 2 the view on his word). Built on it: the rerolls at two a round (Ryan,
6 November: "we might as well try it"), and Phase 1 whole (6 November; How things stand, below),
handed back that day with its reads in `docs/measurements.md` (6 November, the long wall's Phase
1 reads); Phase 2, the view, built that evening on his word, the branch landing on main after his
play ("Wait"). It took main as the chassis session landed (6 November). Its saves are the battle's 10 and the run's 9, so a battle saved
before is refused.

## The design sessions

Each resumes from its brief; `docs/briefs/README.md`'s table says what each waits on.

- Kestrel: ten machines, eight decided, in content and fielded (the bible's Kestrel row; the hub
  `docs/briefs/kestrel_line.md`). The Magpie (a working name, a support engine) and the Snowy Owl
  (a stealth unit, leaning to Cryo: Ryan, 5 November) are Ryan's next session, their briefs'
  first rounds unanswered. The
  Needletail's two modes and the Giant Petrel's catamaran hull are his to pick (the to-do).
- Wainwright & Sutler: ten decided, 3-5-2, nine built (the bible's roster row). The Musk Ox, the
  Whip Scorpion (a rework coming), the Swallowtail and the gunship (very rough; Claude's first
  round in `docs/briefs/ws_gunship.md`) each need a design session for kit and visual design,
  which Ryan starts himself (4 November; the Needletail likewise).
- Minerva: the Honey Badger's rework built 31 October (the Ore Hopper and the Reinforced Skeleton
  module); the echidna left open (Ryan's new shape of 4 November in its brief), the siege battery
  parked on Ryan's charge brief, the battlecruiser never with the Carrier's session. Ryan's ideas
  of 4 November wait on his marks, each in its brief: the lure tank (his tier-one tank, which the
  Armadillo's move to tier two lands with), the Cryo party defence, the immune one, the mole
  (its hook later), and the shield bash (the shield-basher cut as a unit, a tier-three piece).
- Aphelion: the line frame and the Baboon first (the pair that keeps its tier-one deal varied),
  then the jellyfish; the Carrier on its own. Ryan's ideas of 4 November wait on his marks, each
  in its brief: Static, the Barrier and Ward support (the defensive tier one), the Macross
  flagship, the time-shifter kept unrefined; the status detonator folded into the jellyfish,
  unrefined; one slot open.
- The Arsenal: Misharu, the Onryō, Mastema and Minos, Claude's first round and review in their
  briefs, unanswered: Misharu's two calls first (Penance's shape, how often it may fire), then
  the Onryō's kind and trigger. On the ten-a-maker plan the frost and thunder figures (Ryan's
  homages of 4 November) and the Zoids walker move in, each in its brief; its tenth waits until
  its unrefined ideas settle (Ryan).
- The roster's tasks, maker by maker, are the to-do's "The roster: ten a maker".

## How things stand

What is built is run as `docs/rules.md` states it (its known gaps at the end); the bible's
section 12 lists what is built and what waits. The campaign's rules run headless only
(`sim/campaign.gd`); no screen shows them. The quick campaign is an experiment, not a feature
(Ryan, 28 October): no decision reads its runs. Landed in the last week, each with its reads in
`docs/measurements.md` and its judge or play line in the to-do's Ryan list:

- **The long wall, Phase 1** (6 November, `ccr-56b5169d-lsa2rg`, from
  `docs/briefs/long_wall_build.md`): the field's size the ramp's (20 by 12 for now); the battle
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
  field from the first turn short of the wall, a kind up once the seam passes, claimed by a
  machine standing on one as the turn ends, banked as the kills; his phone read next, the to-do).
  His corrections the same evening, built: a hunter's catch is a fight a hunter (a machine two
  hunters caught fights each in turn; the first build had kept them one fight and held back what
  its slots could not stand), and a boss's escort is its curated composition, never grown by the
  tier, so no fight is ever trimmed; his calls in the bible's section 12: a final's three
  wildlife, still made by the engine, and whether the bosses' own numbers keep scaling.
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
  reach, riders landing after the hits, death the last thing checked in a spend, Overcharged and
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
  every two loads a point of Ore Plate, the first buff a store grants; "never destroyed" is the
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
- The long wall's view (`docs/briefs/long_wall_build.md`, section 7: the two orientations, the
  threat rating's pips, the field scrolled along the wall), on Ryan's word after the hand-back.
- The pairs in the game (the bible's pair row): Hold The Line settled on its thirteenth round (3
  November); Night Shift's battle half and The Far Bank's map half on the pair page waiting on
  Ryan's ear; then the engine (a pair as one synchronized stream, the map choosing the track, the
  3 s flip) and each picked half into the forge's SHIP table.

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list). Ahead of all of it: Ryan's play of the long wall with its view (built 6
November; his phone read, the to-do), the harness's BATTLE and FIGHT tabs for it; then the long
wall's open items (the bible's section 12: the shell, the ratings by who solos, the formations
and the refit, in that order of his answers). The branch lands on main after Phase 2. The redesign moves
every foe's blow and the battle's shape, so the 200-seed matrix (below) waits on the refit. First after that: the 200-seed matrix
with the ladder's, the compositions' and the elites' cells on the desk machine (the to-do's
engine line), since the matrix on file predates everything since 27 October.

1. **The design sessions, from the briefs** (above): each decision a bible row, each brief
   retired once its decisions are rows and content.
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
  `docs/design-bible.html` after every change. This file and the live page are v0.472, dated 7
  November (the page's version 484, published from `ccr-56b5169d-lsa2rg` with the cut, the loot
  and Ryan's answers of 7 November; the live page had not moved since version 483, so no merge).
  Version 483 (6 November, v0.471) was this branch's rows merged row by row onto the music
  session's v0.469, whose only change was Hold The Line's trial notes of 6 November, the merged
  file taken back into this branch. The file on this branch therefore carries the music session's track rows (Hold The
  Line's settled pair and its trial notes, Night Shift's duelling basses, The Far Bank's fretless
  bass) ahead of its branch, as the live page does. The live
  page may carry rows ahead of main's code while their branches have not landed. Before
  republishing, read the live page; if another session moved it, publish a three-way merge onto
  it row by row (`tools/pages/bible_merge.py`: BASE the last publish both started from, OURS
  this branch's file, THEIRS the saved live source with the tool's wrapper line and its trailing
  `</body></html>` stripped). A page that size counts as read only once every line of its saved
  copy is read, so a subagent reads it and publishes the merge. After main merges in, check the
  tables script's run against the file's tables before keeping it: a row it reverts belongs to a
  branch not yet landed.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each live copy read first and checked against
  the last publish's before it is replaced, and `edits` and `designs` read first. At the page's version 209
  (7 November, from `ccr-56b5169d-lsa2rg`, the live page main's of version 208 and differing from
  this branch's only by the long wall's own edit, its shield regen for the field recharge): the
  page, the six content files as this branch has them (the long wall, the cut's trimmed
  formations, the vocabulary without Reinforcements; `content/loot.json` is no tab's), the pins
  and `designs.json` from the briefs with Ryan's eight directions folded in (2e871be). Those eight
  documents are deleted from `designs` and his two ideas, the Giant Petrel and the Needletail,
  marked briefed (benched in the Kestrel hub's brief); `edits` empty. Main's next merge takes the
  page back from this branch. `build/hangar/designs.json` is one
  878 KB line, so a session that must read it whole before publishing writes it indented first.
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
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The pair page: https://claude.ai/artifact/19BTqzwbJ4q8qoUxCZNtSW (`tools/soundforge/out/pairs/`,
  built by `pair_sketches.py`, the page `pair_page.html`): each pair on a live switch, Hold The
  Line's run as the game plays it, and the later rounds' pairs and A/B sets (Hold The Line's
  thirteenth, `hold_sketches.py`; Night Shift's tenth, `night_sketches.py`; The Far Bank's map
  half's fourth, `far_sketches.py`), at the page's version 22. A round whose files pass a
  publish's 64 MB goes up in two publishes: the new files first under the live page, then the
  new page with the rest, the old round's files removed.
- The engagement sandbox: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

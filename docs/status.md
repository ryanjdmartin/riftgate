# Status

How things stand, for the next session, and the order of work. Facts and the state as left;
history lives in git (the long form of this file to 17 November: `git show 07f01fb:docs/status.md`,
and the deaths' branch's to 18 November, as it landed: `git show e0dd995:docs/status.md`;
to 4 November: `git show 1fa1155:docs/status.md`; its changelog to 23 October:
`git show 9bec2ba:docs/status.md`). The rules are `docs/rules.md`; the why and the questions
only Ryan can settle are the bible (`docs/design-bible.html`, its first row first); the tasks
are `docs/todo.md`; every run a decision cites is `docs/measurements.md`; the layout, every
document's job and every command are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row, this file and `docs/todo.md`. If a
  chat and a file disagree, the chat is newer.
- **The reboot is the rule of the shield and of heat, and no session skips it** (Ryan, 13
  November: "This is fundamental, I don't want it to get skipped by other sessions").
  `docs/rules.md` has the rule (The reboot) and `docs/briefs/refit_pass.md`, section 22, his
  rules, his rulings and the spec. Nothing regenerates or cools by itself: no chassis carries
  a regen or a cooling (the validator refuses both keys), and what a machine has of either is
  what a passive, a module, a status or a component grants it. Read both before any work on a
  machine, a component, a module or a foe.
- **A reboot's heat goes as its shield drops.** It vents at once, its turn has nothing to
  burn, the shield is back as the next round opens, and heat laid on the machine after the
  vent stays. The ruling it replaced, that the reboot's turn burns all the same, came in on
  `ccr-c1cf6f73-ql6n4q` and was dropped as that branch landed, main's side kept.
- **The vocabulary moved on 15 and 16 November.** Burn is Ablate; Flak and Crushed are
  Brittle; Breach, Splash, Silence, Overshield, Retaliate and Rallied are cut; every status
  ends on one of four clocks (the rules' When a status ends). `docs/vocabulary.md` is the
  vocabulary as it runs. The briefs and the older proposals predate it, and
  `docs/briefs/README.md` says how to read their words.
- **The sizing numbers have one owner** (Ryan, 17 November, to the session on
  `ccr-722ca9f0-yj8na3`, the foes' line: "When it comes to the sizing numbers, you have
  authority over the other session ... it's not actually going to change any balance-related
  numbers there, since you have the context ... You can adjust content if you feel like it's
  ready to do so"): the foes' blows and hit points and the machines' shield, hull and heat
  numbers are sized against the reboot by that line (the to-do's Engine list). A session on
  another line builds a kit at placeholder numbers and moves no balance number.
- Sessions run in parallel on this repo: `git status` first, stage by path, diff a shared file
  before staging it, never a bare `git add -A`, never kill a bare `godot --path .`. One folder
  a branch: the desk machine's folder stays on `main`, and a session that needs another branch
  works in a worktree under `.claude/worktrees/` (`CLAUDE.md`, Session handoff). A branch
  takes main as it lands and main takes the branch as a fast-forward on Ryan's word.
- Branches. Main holds everything this file describes, the terminology pass's branch
  (`claude/gameplay-terminology-tooltips-rug879`) landed on 22 November on Ryan's "Ok push to main".
  `ccr-bd73687d-w8qox1` (the deaths, the wrecks, the rift's shell, the muster) landed on 18
  November on Ryan's "You're good to clean up and merge into main", and `ccr-c1cf6f73-ql6n4q`
  (the look tests, Minerva under 4-4-2 and its vent, the Mole) the same day on his "looks
  great. Lets land it", and `ccr-178e0404-ptuh2m` (the Buzzard) on his "ok, merge into
  main", then the Needletail on 19 November on his "I think what we've got can merge into main",
  and `claude/laughing-gates-p2633f` (the summon texts with no pool, the Text tab's target
  words) the same day on his "Ok merge in", and `ccr-64b5deec-lunnff` (the Macaque, the line
  frame until its naming: its model, its kit and the offhand's engines, the strike order, the
  upgrade chevrons, the models' texture copies' test) the same day on his "Send it to Main", and
  `claude/locked-footing` (a basic a flag on tier one, a machine's tier and the upgrade verb, the
  Honey Badger's Ore and the Prairie Dog's Spreader with their branches) on 20 November on his
  "make sure we're cleaned up and merged in", and `ccr-64b5deec-lunnff` again on 21 November (the
  rules sweep's list for his marks, the Mole's kit and its move to tier two, the Echidna's kit,
  Chain's arcs flat, Godot 4.8-beta4) on his "The model is not finalized but the kit is good to
  test, so we can merge in now". A session's hangar publish runs
  ahead of main (Pages).
  Every other branch on GitHub but the lines' own working branches is merged and to delete
  (`git push origin --delete`, then `git fetch --prune`); a cloud session may not delete one.
- The desk machine is a Windows PC (`C:\Users\jam82\Desktop\Code\riftgate`; the README's
  Running section says what is set up there). It draws with the phone's renderer
  (gl_compatibility), so a lit part's colour there is the phone's. The Mac is out of reach:
  of the foeforge renders only the Augur's survive (`tools/foeforge/out/`; the rest
  `git show fb45141`), and its `generate` and `fix` have no machine (the to-do's Art line).
- Godot: the project runs 4.8-beta4 (published 18 November) since 21 November, on Ryan's "Go
  ahead with the Godot update": the cloud hook installs it, the suite passes on it as on beta2,
  the import rewrote nothing, and the skirmish draws under gl_compatibility. The desk runs it
  since 22 November (Godot_v4.8-beta4_win64 under `%LOCALAPPDATA%\Programs\Godot`, the `~/bin`
  shim on it, the beta4 templates at `editor_data\export_templates\4.8.beta4`): the import
  rewrote nothing there, the suite is green, and `tools/android.sh` put a beta4 build on the phone.
  Beta4 over beta2: the Android SDK Manager's setup fixed on Windows (the desk's export), an
  invalid dynamic font's import failed where it passed (ours import clean), and the text format
  of saved scenes with metadata or embedded scenes bumped (a scene saved on it may not open on
  beta2, so the desk moves with the repo). The notes are godotengine.org's (blocked here; read from
  the godot-website repository's article sources on GitHub). The next check is due 5 December
  (`CLAUDE.md`, Session handoff); date this line again after each.
- Tests: 1437 tests, 389,375 checks, green on Godot 4.8-beta4 (22 November, the battle UI pass: the intent plate, square chips, the crosshair aim; and the Macaque's offhand a chip on its die's rail). The runner fails a run
  whose tests never ran, so read the checks' count, never the exit code alone. One SCRIPT
  ERROR in every run's log is the runner's own test, raised on purpose. About four minutes in a
  cloud session; words after `--` run only the files whose names hold one (`-- loot rig`).
- A cloud session gets Godot and the first import from the session-start hook
  (`.claude/hooks/session-start.sh`); without it, fetch `Godot_v4.8-beta4_linux.x86_64.zip`
  from `godotengine/godot-builds` in one command and unpack and run it in another. The hook
  imports only a checkout with no `.godot`: a suite failing on a class name not declared means
  run `--import` first. A model's textures ride in its `.glb` and the import copies each out
  beside it as the PNG the game draws, so a model is committed with the copies the import then
  writes, and a texture a fresh import rewrites is one a model left behind: commit it, never
  restore it (`tests/test_model_textures.gd`). A model build rewrites the maker's review tiles
  (`tools/lowforge/tiles/`) too: restore those. Screenshots there need `xvfb-run -a` and
  `--rendering-method gl_compatibility`; models build with `BPY_PYTHON` set to a python3.11
  venv holding `bpy==5.0.1`.
- Saves: the battle's version is 42, the run's 34 and the quick run's 17 (`sim/save.gd`). A
  save from an older version is set aside, so a change to what a save holds moves its version.

## How things stand

What is built runs as `docs/rules.md` states it (its known gaps at the end), and the bible's
section 12 lists what waits on Ryan. Every number in content is a placeholder. Most of what
was built for his eye is a first cut with a judge or play line in the to-do's Ryan list.

- **The skirmish.** Every die rolls, the foes pick and show their moves, the player spends,
  locks and rerolls (two rerolls a round), then the foes act. A dealt component is a weapon or
  equipment; shields and vents are off the die, their slottable pieces planned drafts, and
  the engine still runs the four kinds for the locked pieces that are one. REBOOT is a drop's
  target in the middle of the bottom row, and a die dragged onto it is the one way in. No
  blow destroys a component by its size: Destroy is a rider on a foe's blow, in the engine and
  on no foe. A printed cooldown counts the rounds after its spend; Rapid darkens its own
  entry for the round; Instant rolls its die again. A status is a Buff or a Debuff; an
  Ability is a unit's own mechanic on a chip no Purge touches. Every weapon is one shape
  (Sweep is gone), and Every Foe and Every Ally are targeting modes, never keywords. Detail:
  the rules' The skirmish; the bible's section 5.
- **The foes.** A move is a short list of steps (`also`) and so is a fall (`on_death`); what
  a fall aims at one machine lands on the machine that made the kill. An attack at one
  machine picks anyone as the round opens, never overkills, and may carry a word for whom it
  goes for (`aim` on the move, never on a foe: the strongest, the weakest, the hottest, and
  the most buffed for the one purge); an Exposed machine comes first; a pick never moves by
  itself. A move at every machine or at nobody holds no pick, so `Foe.intends()` is the read
  of "does it show a move", never `target != null`. Exposed on a machine is the foes' mark,
  tier two and up among the rank and file, one machine at a time: the Goblin Warchief, the
  Basilisk, the Alpha Warg, the Lich, the Wild Huntsman and the Piercing Eye lay it.
  The Roc is Aloft while its Stoop gathers and nothing reaches it; the Spectre and the Wraith
  fade after their Hex Bolt, Phased through the next round and still acting; the Pilgrim is
  immune to Suppress and its knife purges before it lands, the one move with a step ahead of
  its blow, and the Obsidian Tyrant and the Ruby Colossus to Disrupt while Firestorm
  and Ultima gather. Four falls do more than strike: the root line's scream, the Gorgon's
  gaze, the Salamander's embers, the Lich's. The Red Dragon keeps its Crush on Ryan's word, so
  the Peak has no foe that Exposes. Content: four domains, 118 compositions as grids in
  `content/factions.json`, each a pusher's, a flanker's or a hunter's with a threat rating (a
  patrol 1, a heavy patrol 2, a formation 3, an elite and a boss 4) that is also its menace;
  129 foes, 21 of them elites and 8 heroes; thirteen bosses; two moves planned (the Warrior's
  Cover, the Martial Artist's Counter). The names of the newest moves and falls, the words
  for an aim and the term Immune are a session's drafts for Ryan's codex and terminology
  pass. Tier one's foes are sized for the reboot and the higher tiers' are not (The numbers,
  below). Detail: the rules' Foes;
  the bible's rows on the foes' rule set, targeting, Exposed and Phased.
- **The machines.** Five makers and 27 chassis, 26 of them dealt (eleven at tier one, eleven at
  two, four at three); the Swallowtail is back in design, undealt (`"status": "planned"`), its
  brief open. 84 components, 7 of them planned drafts nothing deals (the slottable shields and
  vents, the Gravity Knuckles and the Tesla Gauntlets, the Retribution Thurible, the Solar Flare
  Array); 20 modules. A stock die is basics beside its
  locked pieces: the basic guns deal 3 for 4 heat and the Laser Carbine 4 for 5, the Halo
  Projector lays a Barrier and the Shoring Jack Armoured 2, and every piece that grants a
  Barrier sits out a round after. A machine moves 3 to 6 hexes. A basic is a tier-one piece with
  a flag (its blueprint a run's from the start), never a find. A machine holds a tier, its
  chassis's as it arrives, bought up between battles once the Convergence opens the next (the
  campaign for `UPGRADE_PRICE` salvage, a placeholder; the quick campaign free): each tier one
  standard lift of its stat lines for every chassis for now (`tier_lift`, hull 4 and shield 2,
  placeholders the foes' line sizes; no locked piece's number rises with the tier, Ryan: "they
  scale with either the upgrades, or with the kit"), a passive sourced "tier", its branch's pick
  with it. No
  screen buys one yet; the campaign runner's plain player buys each as it opens. An
  upgrade branch is a passive scoped to a locked piece, or a step on the passive where its
  numbers warrant one (the rules' Branches; `docs/locked_pieces_proposal.md`; the bible's
  locked and tiers rows): the Storm Petrel carries the first two, the Buzzard two more, the
  Honey Badger (Miner, Smelter) and the Prairie Dog (Flakker, Harrier) theirs from Ryan's kits of
  20 November (the Badger's Ore, the Spreader; a grant held once a round, a piece remade whole and
  a strike counting Brittle twice the engine they brought), the
  harness's UPG line fields a build at the tier its picks make. A step may tweak as many pieces as
  it needs (Ryan, 19 November); the Macaque's second steps touch its offhand and its Aile
  Booster. An upgraded piece wears a chevron a step under its place, on the die and down the
  codex, and takes the name its step gives it (the Aile Blitzer); `RIFTGATE_TEAM` fields picks
  in a standalone fight (`macaque@duelist+duelist`). The machines the reboot broke
  are another session's line (`docs/reboot_machines_proposal.md`, read with
  `tools/reboot_probe.gd`): the Storm Petrel landed from it on 17 November and took Ryan's
  shape of the 18th (no shield armour on its passive; its Hardlight Pulse lays Hardened Light,
  up to 3, every stack gone when the shield breaks, the reboot included); the Buzzard landed
  on the 18th in his carrion form (every foe that falls in its fight gives it shield, every
  weapon it fires pays a zap of shield for a flat add, its Shield-burner Cannon fires the whole
  shield; Sustain on its passive and Burst on its cannon its branches); the Needletail the
  same day on his two calls (its Designator at no heat, and its reboot its second action) and
  his rewrite of its Relay (a kind spent goes on cooldown for the round; its die flips to the
  other kind, rolls land anywhere; a Rapid or Instant spend leaves its kind lit; it reboots
  after one action whatever its die shows, the one machine that may after a Rapid spend; its branches, one on
  the spotter and one turning the Designator into a weapon, wait on Kestrel's tier one); the Skua, the Kite, the Cottonmouth and the Polar Bear stand as built (19 November, his
  "Leave it"); the Puffin landed on the 19th at tier two on his calls (equipment it spends on an
  ally takes up to 4 of that ally's heat onto it; its lock passes its whole heat to an ally for
  Empowered 1 for every 2; its kit named on the 20th, the Downwash Exchanger and the Overdrive
  Injector; its shield-lit parts carry its heat, blue to red-orange, `RIFTGATE_HEAT_GLOW_DEBUG=1`), its strength his play's in
  a team that leverages heat, since the bot reads only its Empowered (20 November); its first
  round on the Swallowtail waits on Ryan's marks. Built on placeholder numbers and waiting on his play, a to-do line each:
  the Kite, the Skua, the Needletail, the Ammit, the Clydesdale, the Nemesis, the Polar Bear
  (a reboot opens its seal), the Whip Scorpion (its reboot's vent blasts every foe), the
  Lammergeier, the Wild Boar, the Baboon, the Stingray, and the Macaque, landed 19 November
  on `ccr-64b5deec-lunnff` from Ryan's kit (Aphelion's agile duelist at tier one: its offhand
  cycles the Beam Rifle, the Beam Sword and the Beam Shield after every spend at a foe, a rider
  on what it aims at foes, its Aile Booster a Rapid lunge to Indirect; Duelist and Valkyrie its
  directions, the Parry the Duelist's capstone, its return on the next strike alone; its
  name and designation Ryan's, the Macaque "for now", Capuchin held for a gentler walker). The Giant Petrel's kit, the Musk Ox
  and the gunship are unfinished by his own notes. Four tier ones a maker (4-4-2) is his lean
  (the refit brief's section 13); the six certain ones are the Honey Badger, the Skua, the
  Storm Petrel, the Prairie Dog, the Cassowary and the Cottonmouth, and Minerva's four are his
  (16 November: the Honey Badger, the Wild Boar, the Mole and the lure tank; on 20 November the
  Echidna took the Mole's place and the Mole went to tier two), so the Polar Bear is tier two in
  content and the Wild Boar tier one, its numbers still its tier two's but its armour 1 (Ryan, 20
  November: "the Boar at tier 1 needs base armour 1, not 2"). The designs still to come
  are briefs: `docs/briefs/README.md` says what each waits on.
- **The numbers.** Tier one alone is tuned (Ryan, 11 November), on the baseline: the second
  battle, four tier ones against a tier-one rift, a fight read at its rating (a flanker one
  machine, a hunter's pack two, a formation three, an elite and a boss four). The hull budget
  is a formation's fight a twentieth of a squad's hull, a flanker's a thirtieth, a hunter's a
  tenth, an elite's a quarter and the boss what is left. Every domain is on it since 19
  November (`docs/briefs/numbers_pass.md`, sections 3, 9 and 10; the reads
  `docs/measurements.md`), read on every squad of the six certain tier ones: a lone flanker
  3.4% of a four's hull, a hunter's pack 8.9%, a formation 5.5% (3.3% to 6.9%), every fight
  won. The elites and the bosses are sized for a squad without the Barrier, on his word
  ("sizing it without means that if it does prove toxic after all, in my play, then it's
  relatively easy to remove"): an elite 24.4% (20.3% to 27.7%), a boss 29.5% (25.1% to
  36.1%). The Barrier basic stays on the starting dice ("one of the two sides of the
  defensive coin"); the squad with it pays an elite 15.9% and a boss 20.4%, and whether that
  proves toxic is his play's to say, on BARRIER BASIC. Each domain's kit without Breach
  landed with its sizing (the bible's levers row): the Waste's purge ahead of the blow, a
  move's own order and no rule of Purge; the Peak's Bomb as its hard hit on a telegraph; the
  Marsh's knight and its Serpent's fangs; the Meadow's as it was. How the leaders strike is
  his lean (the bible's section 9): whole blows the norm, slightly towards strikes. His
  answers of 19 November landed the same day: the numbers pass's leans (no piece grants a
  cooling or a shield regen now; Cryo 1; the Ankle Mortar 3 for 5; the Overcharge Coil tier
  two; the slottable shields and vents of tiers zero and one retired, a vent's shield half
  leaving the engine with them), the Cassowary's Laser Carbine and the Cottonmouth's
  Incendiary Shells, and a foe's jam waiting for its machine's reboot; read, the baseline
  moved by a point or two. His second answers of 19 November: the roots scream Brittle 2,
  the Mandragora on its killer and the higher two on every machine (a fall takes no reroll
  since, a drain a move's alone), which costs the Meadow's formations about a point of a
  four's hull; a pin with nothing to hold goes as its foe's turn ends. His marks of 20
  November: the roots' lash corrupts, the Emperor Scorpion's Paralytail leaves Ablating
  (its blow lightened to pay for it), the Fell Rider's Shriek Saps every machine, and the
  alpha pack is one alpha and three wargs. His second round that day: every gel's Engulf a
  rider in place of a blow, the gel wall three gels and two roots since (a machine's Ablating
  grows while stacks come faster than one a turn, so the wall costs the square of its length:
  four gels read 17.5%, three 4.1%), the King Gel's Dissolve in Body Slam's place at Ablating 2
  (27.9% without the Barrier, 23.6% with it, its Purge taking the Barrier), the goblins' wall
  over their neighbours and their knife only with a buff on them or coming, the Tyrant's Roar
  Brittle 2 on every machine (a point), and the goblin horde as built at 7.4%, its four roots
  its cost. The shaman's warband reads 33% at sixty fights at every commit back to its sizing,
  whose thirty read 24.6%, so the leaders want a read at sixty or more (the to-do's defence line). His to pick: the pickets' count, and the rest of
  `docs/domain_statuses_proposal.md` (its section 8 holds this round's open items). The
  battle whole is the open question (the brief's section 11): at their ratings a second
  battle's fights come to three fifths to nine tenths of a squad's hull, and a fight met a
  machine short costs four to six times its price. Tiers two and three are unsized, their
  foes still the ones sized against a shield that refilled; the first battle, the Meadow's
  alone and the one a trio fights, is built and its sizing his. On a debug
  build's SETTINGS, TRIALS, each a number still to be picked: HEAT, TOP BASIC, RANK AND FILE
  and BARRIER BASIC (read at the next launch), OVERHEAT, FIELD DEPTH, OPENING, FODDER,
  RUPTURE, TIDE and STRIKE (read as the next battle starts). A dial leaves the page with its
  question; the block is cut, a blow past a shield reaching the hull. The runners lay the
  same what-ifs with `--refit` (`sim/refit.gd`). `docs/balance.md` is the matrix of 27
  October, older than every rule since, and still prints the old aims' cells and a
  comparison section the next run drops. Detail: `docs/briefs/numbers_pass.md`; the refit
  brief's sections 13, 22 and 23; the bible's scale row and section 12.
- **The battle and its map.** A battle is the defence of a long wall: a field 20 by 12, the
  wall along one edge and the rift opposite, the siege under way as it opens; MAP VIEW turns
  it (the wall at the left, the default, or at the bottom). A pack pushes for its own stretch
  of wall, flanks or hunts one machine; a pack is one fight, a hunter's catch first; nobody
  blocks a move and nobody ends on another's hex. The tide comes on a beat, a peak of Rift
  Pressure opening tears on the seam; the Rupture meter is two beats of it, filled by menace,
  its Fractures calling the elites; the boss holds its hex before the rift's five, sealed
  until the Rupture. A pip of threat rating strikes the wall for ten. A move that plays ends
  its machine's action unless an order stands, and UNDO gives it back. Six shapes by the
  seed: the river, the river delta, the gorge, the ruined city, the badlands and the steppe;
  the painted world stands at the 3D map's heights, each domain in its own tileset and rock.
  A machine standing on a cache claims it. A lost machine's wreck holds its hex for the
  battle: walks pass it and none ends on it, its model dark and slumped where it fell. The
  rift's shell walls the seven hexes beside it, closed to the machines while the seal stands,
  a stretch cracking at each Fracture and the whole bursting at the Rupture, a cache behind
  it. Detail: the rules' The battlefield; the bible's section 4.
- **The campaign.** Its rules run headless only (`sim/campaign.gd`); no screen shows them.
  The first battle is built as he decided it (the bible's squad row; the rules' The first
  battle): every rift is the Meadow's until it is fought, by content's mark (a domain's
  `opening`); won, one of three of the host maker's machines is taken before anything else;
  lost, the machine left on the tender comes. The quick campaign's first battle follows it.
  Today's makers field two tier ones or three, so the choice is of one or two until 4-4-2
  lands, and the runner's plain player loses that battle in every run as tier one is sized
  (`docs/campaign_run.md`), so the won branch is the tests'.
  The campaign runner's player fights alone by the map's defence rule, the floor the reads
  stand on; `--muster` plays the player that gathers (`BattleBot.Rule.MUSTER`: each pack its
  rating's count of the nearest machines, the unsealed boss first). With every fight on the
  budget it still wins a quarter of second battles at best in any domain: it fights a
  machine short, a formation then costing four to six times its price, and no dial read
  moves it past a third (`docs/measurements.md`, 19 November; the numbers brief's section
  11). What a battle should leave a squad with is his, by his play of a second battle. The quick campaign is an experiment (Ryan,
  28 October): no decision reads its runs, and it follows the main content and code on one
  tree, its fights built by the battle's own builders.
- **The screens.** The harness (`godot --path .`) launches a battle as a run deals it, a lone
  fight, a saved battle and the quick campaign, and picks a machine's upgrade build. The
  skirmish screen, the battle screen, the pause menu and its settings are built; the hangar,
  the mission map and the draft are not. In a fight (22 November, on the branch
  `claude/battle-ui-intents-status-6hgoi0` until Ryan lands it) a foe's intent is a plate above
  it, a status chip a square tile with its number at its corner (Settings → CHIPS on a debug
  build compares the corner, the tab and the old chip), and a die is spent by dragging a
  crosshair from it (`AimLayer`), the die staying in its tray. A debug build's settings hold TRIALS and COLOURS
  (`ColourTuner`: Ryan tunes there and sends its COPY text).
- **The hangar page.** `tools/hangar.html` over `tools/hangar_data.py`'s files, a tab a kind
  since 20 November: Chassis (the Bench renamed: every machine a card, a tap its working sheet
  with its codex, flavour and brief, and the Briefs list of the rest; each brief read only, with
  his notes), Components, Modules and Foes on its pattern (a tight list whose row opens the
  sheet, the raw editor behind a toggle; Foes formations first), the Text by chunk, a card an
  entity (`tools/hangar_text.py` is its one inventory), and the models. Since 20 November the
  words the game composes from a piece's numbers are content (`content/templates.json`, read by
  `sim/templates.gd`): the Text tab's Templates view, a card a kind, each template beside the
  pieces that print it, folded like any text; and on a piece's sheet (a Chassis sheet's locked
  pieces, a component's sheet) under its lines, each template a field in place with a hop to its
  Text row. A template's text saves only with the braces its `fills` names. The ledger `docs/hangar/text.json` names nothing as signed, so
  every shown text is a session's draft. His writing waits in the page's `text` collection (the
  Text tab's and a Chassis sheet's codex and flavour) and his notes on the briefs in `designs`: a
  session that touches either folds them in first. The Names tab retired on 20 November: the
  makers' kinds of names are `docs/naming.md`, the check `tools/check_name.py`.
- **Art and models.** Every machine's model is lowforge's with a rig sidecar; a hardpoint
  wears one of four silhouette classes (barrel, twin barrel, rack, dish), and a test holds
  each model's pins to its chassis's hardpoints. Every foe has art, a placeholder stamped "?"
  where no pick exists, and each boss a 48-pixel picture for the map. The hangar's live view
  can be driven headless in a cloud session (three.js 0.128.0 from npm in place of its CDN,
  the page served locally, Playwright aiming its camera); no script for it is kept. A lost
  machine goes down its own way, a death in its sidecar (`b.death`) for most of the roster
  and the slump for the rest: falling slow then hard, on the floor every frame, its body only
  ever going down, resting on what touches it and kept on its hex, its lights stuttering out
  (the bible's death row; `tools/death_floor.gd` reads each). Ryan has passed the Nemesis's
  kneel, the Clydesdale's face-plant, the Funnel-web, the Cassowary, the Whip Scorpion and the
  Ammit; the rest wait on his read, and some still cross parts as they lie (the to-do). The
  Cottonmouth fires every weapon from its drum. The Honey Badger and the Wild Boar wear
  Minerva's vent, the Polar Bear's (16 and 17 November). The Echidna is built (20 November, his
  kit that day, at tier one; the rules' Sonic Needle, the bible's Echidna row): every foe it
  strikes and every foe whose blow lands on it takes a Sonic Needle, a conductor of Chain, and
  the third in a foe fires Chain 2 on every conductor, that foe included; its Supersonic Spike
  Tether lures and saps, its directions Spiker and Chaos. A foe wears its needles on a chip
  counting toward the bolt ("1/3"), and the Mole's Applied Momentum on one (22 November, on his
  report that the Howitzer's needles showed on its target alone: laid on every foe it hit, worn by
  none); a status no chip line names wears its term's mark, never a star, on a foe or a machine
  (`test_screen.gd` holds both). Its look waits on his pick of the
  bristle, the stand-in drawing it meanwhile. The Mole is built (20 November, on
  his "Build the mole now", his kit of 16 November; at tier two since that day, its tree back in
  design; the rules' reboot section, the bible's Mole row): it burrows in its reboot's place, banks Conserved Momentum under, and its Inertia Drill
  lays Applied Momentum, a blow a turn in its foe until a burrow takes it home. Its model holds
  Burrowed and Drill Out from the statuses (a form may let others go as it is held, `releases`),
  and a form asked while a firing slice plays waits for it to land, so the drill launches and
  then the Mole comes up with its bore empty. The Macaque is a model from its third look round,
  reworked on Ryan's notes of 19 November: its main hand a mount over its fist, its offhand
  carrying the rifle, the blade and the kite of light, the last two made of light (`b.beams`),
  seen only while lit. In a fight it holds its offhand's armament (a form a slot, held while its
  offhand's form is in that slot) and dashes as its Aile Booster fires; off the field its idle
  runs the cycle. Look tests of four chassis are stills in `docs/looks/`, their
  choices in their briefs, never content.
- **Audio.** Three pairs play in the game (Hold The Line, Night Shift, The Far Bank;
  `Sound.PAIRS`): a battle picks one as it starts and loops it, the map half on the field and
  the battle half in a fight. Low Ground, The Crossing and Full Bore play nowhere until their
  pairs pass, in a music session of Ryan's own. No domain has a boss theme. The peak's sweep
  and a tear opening have their own sounds, and a hunter roars by its family as it turns on a
  machine (first cuts, unheard).
- **The runners and tools.** `tools/balance.gd` plays the skirmish with `sim/policy.gd`'s
  ladder and `tools/campaign_run.gd` whole runs (the README has every command). The bot has
  a first play of the reboot, and prices every step of a foe's move and of its fall by one
  table (`Policy.effect_cost`); a brace, a summon, a revival, a swallow, a purge and a merge
  it still counts as nothing; it reads a purge ahead of a blow, and holds a kill only for
  what a round's wait would save of a death blow. `tools/anchor_read.gd` reads every fight
  of a tier at its rating on every squad of its pool, and says who paid by machine: the
  measure the sizing stands on. `tools/battle_run.gd` plays one battle of a run
  whole by squads, reads the field's trial dials from the environment as the game does, and
  with `--whole` plays a player that never fights a pack short at the wall; and `tools/balance.gd --packs rating` fights every composition with squads
  of its rating. `tools/budget_model.py` and
  `tools/basics_model.py` are the small models apart from content.
  `tests/test_leftovers.gd` fails the build for a rule no piece prints, and
  `tools/behaviour_trace.gd` checks that a refactor changes no fight.
- **The phone.** A Pixel on a debug build (the README's phone commands). Ryan's reads arrive
  as screenshots, and `CLAUDE.md` says how to work one. What waits on his read is the to-do's
  Ryan list, from the reboot's control and the new targeting to the map's lists and MSAA.
- **Designed and not built.** The promoted forms' one move more (`docs/heroes_proposal.md`);
  the bosses' escorts and stat blocks by tier and ramp (`docs/bosses_proposal.md`); the
  Fracture's prize, the commander layer and the economy's verbs (the bible's sections 8, 10, 12).

## Next, in order

Each a session of its own; Ryan's play runs beside them (the to-do's Ryan list).

1. **The foes' line** (`ccr-722ca9f0-yj8na3`; `docs/briefs/numbers_pass.md`). His word of 19
   November is done: every domain's kit and sizing at the baseline (the second battle, four
   machines; the code's ramp 1), the first battle built, the bot pricing a purge. In this
   order from here:
   - His marks on the rest of `docs/domain_statuses_proposal.md`, then its rows built and
     read: a foe's Sap rider for the Ghost line, and Phased by source with his ruling on a
     ghost's own side, in one pass; his read of the formations that rally (the hangar's Foes
     tab shows each formation by name since 20 November, and the table went to him again by
     those names the same day).
   - Every tier-one leader read again at sixty fights or more (the shaman's warband reads 33%
     at every commit back to its thirty-fight sizing), then any leader moved into its band.
   - The formation pass (the bible's formation row): every composition given a purpose, a
     row a formation in chat first; the goblin horde's four roots on his play of it.
   - His play of a second battle, which says whether the budget's shares stand (the brief's
     section 11): the fights are even across the domains, and the battle whole is tight.
   - The tier-one bench, placeholder pieces each the vanilla with one thing traded, after
     his picks on RANK AND FILE, HEAT and TOP BASIC: its prices are read from the vanilla he
     settles on. It brings tier one's slottable numbers down to the basics' (Ryan, 21 November).
   - The scorches on every machine above tier one, then the scaling from the baseline: the
     first battle down, its sizing his ("I'll handle that one"), tiers two and three up.
2. **The machines the reboot broke** (another session's line, beside the first): each fix
   built on Ryan's marks, in its own commit, at placeholder numbers.
3. **The design sessions, from the briefs**: each decision a bible row, each brief retired
   once its decisions are rows and content. The locked pieces' footing first (its own session
   since 20 November), the Echidna's look beside it (its kit built 20 November; the bristle his
   pick, then its model), the Mole's tree at tier two, then the machine back in design (the Swallowtail), the built but
   unfinished (the Needletail, the Giant Petrel, the Musk Ox) and the gunship, the tier-one
   fronts (Minerva's lure tank, an Aphelion tier one), Claude's first rounds on his directions
   of 5 and 6 November, the rest as its session comes. The to-do's roster is grouped to match.
4. **The refit pass's tail** (`docs/briefs/refit_pass.md`): his word on the first battle's
   block, his marks on the flanks' second patrols, the stock
   re-deal proper as a table in chat first, the component pass, what prices a round (parked
   on his word).
5. **The skirmish code audit's structural steps** (`docs/skirmish_audit.md`): the bot's
   mirrors onto the engine, statuses as data, the Face, each checked by the behaviour trace.
   Then the 200-seed matrix on the desk machine, the first read of the roster as it stands.
6. **The stock pass's tail**: Ryan's name pass; the Lammergeier's stock; the pricing pass's
   next reads (the bible's pricing row); the heat session (`docs/briefs/heat_pillar.md`).
7. **The foes' fresh start and the pacing session**: Ryan's marks (the bible's section 12:
   the elites' names and numbers, the compositions' partition, the escorts, roles) and the
   ramp's numbers; then his play of the clocks on the phone.
8. **Balancing for real**, once the sizing, the stock pass and the formations are in: the
   runner's rows on the roster as it stands, prices and tier ladders, the heat report, and
   Ryan's play deciding feel.
9. **The screens**: a prototype hangar, the mission map and the draft, a run he can play.
10. **The economy pass** (`docs/economy_pass.md`): the spending policy, then every price.
11. The rest in the standing order: Ryan's text; the domains' last engine (the planned moves,
    the bosses' open calls); the battery plan's rest; audio; art; the commander layer after a
    balance baseline; onboarding before a phone leaves the desk.

The documents were cut down on 17 November on Ryan's word, so that a new session does not
wade through earlier forms of the game. A session keeps them so: a stale line is replaced,
never appended to, and what a line replaced stays in git.

## Pages

Every page lives in Ryan's account and is republished by its URL (read first), its database
with it, on his word. A page's link goes into this file in the same commit as its first
publish; the commands are in `README.md`.
Deleted on his word of 20 November: the vocabulary marks, the targeting scenes, the roster
analysis, the effects listening page and the engagement sandbox (the README's docs line has the
copies and the roster analysis in git; the sandbox's source is `docs/canvas/`).

- The terminology pass's rules, for his marks: https://claude.ai/artifact/TXNpkS4zuPJ5c6sEpk9oF4
  (Version 2, 22 November, from `claude/gameplay-terminology-tooltips-rug879`, the timing rules added), made from
  `docs/terminology_proposal.md`'s sections 2 and 4 by `tools/pages/terminology_marks_page.py` and
  published with the `db` and `user` capabilities. Each rule, call and name takes a mark and a
  note, saved in the collection `marks`, a document an item keyed by its id (`rule-13`,
  `name-aloft`: `title`, `mark`, `note`, `at`). He may mark there or in chat; a session reads
  `marks` (ArtifactData, `list`) before it folds them into the proposal's section 8, and never
  republishes while he is on the page.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, from `docs/design-bible.html`.
  Published at v0.655 on 20 November from main's file at `33c4cc61` (the page's Version 519),
  over this line's v0.654. Before republishing,
  read the live page; if another session moved it, publish a three-way merge onto it row by
  row (`tools/pages/bible_merge.py`: BASE the last publish both started from, the file of
  `33c4cc61` unless the live page says otherwise, OURS this branch's file, THEIRS the saved
  live source with the tool's wrapper line, its trailing newline and `</body></html>`
  stripped): check BASE against the live page byte for byte first. After main merges in,
  check the tables script's run against the file's tables before keeping it: a row it
  reverts belongs to a branch not yet landed.
- The hangar: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map. A publish sends only the files that moved,
  each checked against the live copy by hash (the files listing gives each one's), with
  `edits`, `designs` and `text` read first. Version 325 (22 November): the Inertia Drill's rule line, data only over 324's page. Version 324 (22 November): a machine's sheet lists every term it orbits, its own first,
  each editable in place; 323 the same day, a dealt machine with an open brief under Unfinished.
  Version 322 (22 November): Version 321's files, the Text
  tab's Vocabulary view with its category filter again, from `claude/gameplay-terminology-tooltips-rug879`. Version 321 (21 November): main at `8b5a027d`, the
  Echidna's line landed (the briefs' and the texts' inventories). Version 320 the same day: Chain's
  arcs flat and on any conductor, its text and Spread's and Penetrate's, over 319 (Chaos I as "reduce stacks to
  1") and 318 (the Echidna's kit and the Mole at tier two), each from `ccr-64b5deec-lunnff` with
  main taken in, the page main's and unchanged; that line landed on main on 21 November, so a
  publish from main carries its machines again. Versions 314 to 317 (20 November, main's: a tab a
  kind, the readouts, the Templates view, a piece's templates on its sheet) were a union of main
  and that line built in a scratch tree. The `edits` and `text` collections were empty,
  `designs` held his two notes of 5 November (both already briefed).
  The `candidates` collection (his names, 106 rows) stays in the database unread;
  `docs/name_candidates.md` holds them. The service refuses a republish until the live page's saved source has been
  read whole, every line: read it before the publish, not after the refusal. A view counts only in
  the context that read it, so an agent that reads the page for a session reads any moved file
  and publishes too; a compacted context has lost its views, its own publishes' included, so it
  reads the page and every file the publish replaces again first (the refusal names them).
  `build/hangar/designs.json` is one line of about 980 KB: write it indented before reading it whole.
- The rules sweep for his marks: https://claude.ai/artifact/LUUwdjFtsqGsVv3NYWzxpN, from
  `docs/rules_sweep_proposal.md` by `tools/pages/rules_sweep_page.py` (Version 2, 20 November:
  the Mole's brief retired under two of its items).
  His marks are its database's `marks` collection, a document an item (id the item's, `V1`),
  `{item, mark, note, by, day, updated}`: read them with ArtifactData before the fold. The page
  runs contract 0.2.96. Republish it from the script's output when the proposal changes.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (collection `picks`); the
  fix order that worked is the bible's art row.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV
  (`tools/soundforge/melody_desk.html`; collections `parts` and `melodies`), at its version 8.
- The pair page: https://claude.ai/artifact/19BTqzwbJ4q8qoUxCZNtSW
  (`tools/soundforge/out/pairs/`, built by `pair_sketches.py`), at its version 88. A version
  holds at most 256 MiB of files and a publish 64 MB, so a round's new files go up with the
  old round's removals, in two publishes when they pass the limit.

# Status

How things stand, for the next session, and the order of work. Facts and the state as left;
history lives in git. The rules are `docs/rules.md`; the why and the questions only Ryan can
settle are the bible (`docs/design-bible.html`, its first row first); the tasks are
`docs/todo.md`; every run a decision cites is `docs/measurements.md`; the layout, every
document's job and every command are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row, this file and `docs/todo.md`. If a
  chat and a file disagree, the chat is newer.
- Sessions run in parallel on this repo: `git status` first, stage by path, diff a shared file
  before staging it, never a bare `git add -A`, never kill a bare `godot --path .`. Local main
  and `origin/main` diverge for a day at a time; merge `origin/main` into local main before a
  records pass, and expect the bible's live page to have moved (read it, merge, republish).
- The desk machine is a Windows PC since 19 October (the Mac went out of reach mid-session):
  `C:\Users\jam82\Desktop\Code\riftgate`, set up that day; the README's Running section says
  what is set up there. What the Mac held outside git is gone but the seventh round's foeforge
  renders, force-added in `fb45141` so the picks can be cut here; foeforge's `generate` and
  `fix` have no machine until a route for the image model is chosen.
- Tests: 609 tests, 63,145 checks, green on `ccr-7d865127-wr1ko2` with the other two branches merged in (23 October, the four Kestrel machines in content and modelled, the rig tests reading their sidecars) and on `claude/eager-newton-sf947u` with the two merged in; 609 and 62,521 on main at `cd2ea56` (23 October, with the bots' Shock priced at the hitter in hand; main's two commits since are docs and the loop driver) and on `ccr-170f6d81-465jnr` with main's `d592823` merged in (in a cloud session the same day); 485 and 20,291 on the Windows desk machine on 19
  October, about a minute there. A cloud session fetches
  Godot 4.7's Linux build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots, and builds models
  with `BPY_PYTHON` set to a python3.11 venv holding `bpy==5.0.1`. Its first `--import`
  rewrites four Prairie Dog textures; restore them (`git checkout -- art/models/prairie_dog_*`)
  rather than commit them.

## Branches

Three branches stand beside main. `claude/eager-newton-sf947u`, the stock pass's, merged into
main on 22 October on Ryan's go and used again on 23 October for the reads of its bands and the
runs they called for (on main to `d592823`), now holds `ccr-7d865127-wr1ko2` (and through it
`ccr-170f6d81-465jnr`) merged in beneath the evening's work (Ryan's terms and elites, the
Elemental, the endgame fours), since the live bible was that branch's: it lands on main with
that branch, on Ryan's go once he has judged the Kestrel models running (a fast-forward while
main stands at `d592823`); delete it from the desk machine or GitHub once its work is done,
since a cloud session's push to delete one is refused. `ccr-170f6d81-465jnr`
(23 October, a cloud session) holds the to-do pruned of its ticked lines, the records swept
for the stock pass's landing (the to-do, the status, the briefs and their README, two content
notes and the vocabulary page) and the bible cut for session context (v0.265, its Pages line;
the register's new sentence in `CLAUDE.md`; the Retaliate codex's retired Faraday Hull struck,
the hangar's version 97), with main merged in, to merge into main (a fast-forward while main
stands at `d592823`). `ccr-7d865127-wr1ko2` (23 October, a cloud session) holds the four
Kestrel machines decided on 21 October in content and modelled and their second round of looks
(the bullet below), with the other two merged in at `7843c7b` and `5b9063c` (the bible's v0.268
and the hangar's version 99, their Pages lines); it merges on Ryan's go once the looks are
picked and judged running, carrying the other two. The stock pass's baseline (`ace3c3c`, 200
seeds) ran on
`a1585a9`, before main's rule and bot changes of that morning: the rage capped at 5 (the
Nemesis), the charged Screens for the whole team only (the Swallowtail), the bot's bunching
swap (the Dingo) and its boss reads (the Disrupt carriers, and the fights with a countdown,
parts or a last act: the Lancer's, the Augur's). Those rows re-baseline on merged main before
the stock pass is read against them; the rest stand (the forecast's reads with a die in hand
move no bot, which forecasts with none).

Every other branch was merged into main and deleted from GitHub (22 October, by Ryan from the
desk machine; a cloud session's push to delete one is refused). The five design sessions
merged on 21 October are paused, each resuming from its briefs:

- Wainwright & Sutler (since 15 October on `claude/festive-cray-i7lvnm`, its commits
  fast-forwarded into main as they landed; wrapped up 21 October, Ryan: "make sure everything is
  merged in and wrapped up"): ten machines decided, 3-5-2, the bible's roster row saying where
  each stands. Built: the Prairie Dog with Flak, the Clydesdale, the funnel-web, the Cassowary,
  the Cottonmouth, the Whip Scorpion and the Dingo with its Combat Translocator. The
  Swallowtail's and the Musk Ox's engines landed 21 October, so nothing of the maker's is
  planned in content. The gunship's brief waited for the stock pass's tags and the numbers'
  rescale (Ryan, 21 October), which landed 22 October, so its session is free to run; the five new machines' models and the Translocator's mount are the
  to-do's asset lines.
- Minerva (the Armadillo landed on Ryan's go, 20 October: Lockdown, the Cryo Flinger pair and
  Cryo; Armoured, Overcharged and Burn in points before it, 18 October; both built, below): the
  bible's Minerva roster row (section 7) says where each machine stands; the open briefs are
  the Honey Badger's (its numbers), the echidna's (left open), the siege battery's (parked on
  Ryan's charge brief) and the battlecruiser's (never with the Carrier's session, Ryan's call of
  20 October); the Armadillo's model is the to-do's art line.
- Aphelion (Claude's first round of 15 October and its review of 16 October in the four briefs'
  "Aphelion session, first round" sections, with Ryan's calls of 20 October: every blow counts
  for the line frame's combo, Purge on both sides for now, the shield's Beam tag the line
  frame's model session's): the line frame and the Baboon first (the pair that keeps Aphelion's
  tier-one deal varied), then the jellyfish; the Carrier on its own; Aphelion's defensive tier
  one (the to-do) unproposed; the session follows the conventions decided since 15 October.
- The Arsenal (Misharu, the Onryō, Mastema and Minos, the Zoids walker left out at Ryan's word:
  Claude's first round of 15 October and its review of 16 October in the four briefs' "The
  Arsenal session" sections, none of it answered): Misharu's two calls to Ryan first
  (Penance's shape, how often it may fire), then the Onryō's kind and trigger, which Flak
  reopened; the round's arithmetic is at 16 October's scales, and none of the four reads in
  the runner until the shield rule's engine and the bot's valuations land.
- Kestrel (the line, 18 to 21 October; merged on Ryan's word of 21 October: "I'd like to wrap
  this up and merge into main, and I'll take up the last 2 chassis in another session"): eight
  machines decided and named, 3-3-2, the bible's Kestrel row saying where each stands and
  `docs/briefs/kestrel_line.md` the line's hub; each decided machine's brief stays until its
  content and engine session lands it (the to-do's lines; the design under Decided, not built).
  The last two, the Magpie (a working name, a support engine) and the Snowy Owl (a stealth
  unit), are Ryan's next session, from `kestrel_magpie.md` and `kestrel_owl.md`: his
  directions and Claude's first round in each, unanswered (the Magpie the thief, the mimic or
  the cache; the Owl cold and so unseen, a hunter on the map, or Hidden as a status).

- The chassis proposals: Wainwright & Sutler's, the Arsenal's and Aphelion's reached main as
  proposal files and on 15 October were folded into the design-session briefs (`docs/briefs/`,
  each the design's one home) and retired, the gunship's stand-in table to
  `docs/measurements.md`; the multi-rotor's look tests stay in `tools/lowforge/looks/` and
  `docs/looks/`. Minerva's and Kestrel's earlier proposals are struck (Ryan, 13 and 14
  October): each maker's next chassis start fresh from the latest rules, with nothing of the
  struck designs in the records. A first pass at the analysis on 14 October drifted into
  measuring stand-ins and rating on performance and was retired to git (the branch's history).
  The analysis itself is `docs/roster_analysis.md` (14 October, from Ryan's brief of that day
  in `docs/mechanic_budgets.md`, retired with the proposals; published, the link under Pages),
  background since the go, which is recorded in the bible, the briefs, the to-do and
  `docs/economy_pass.md`.

## The game as left (18 October)

- 23 October, evening, Ryan's terms and his elites (the bible's tiers row, section 3's new curve
  row, section 12): a foe's tier (rank and file, elite, boss, final) is apart from its size, its
  rank and its complexity; an elite is a spawn of one or more unique packs outside the spawn
  list, a mini-boss tier throwing a visible curveball (a mechanic on the map, or a harder fight
  that holds the team and threatens the gate, the tier-one kind), about one an early battle and
  more later, worth a larger chunk of the Rupture meter and Anathema. By his leans none of the
  four built massive foes is an elite as built (the Treant rank and file, the Bone Wyvern an
  advanced foe or an elite, the Elemental and the Sandworm not special enough as they stand),
  and an alpha or named homage of the Treant or the Sandworm fits the harder-fight elite. The
  Magma Golem is the Magma Elemental (a golem implies a master; the id stays). Balance is read
  by stage (section 11's ladder row), the endgame four fitted from pieces and modules up to tier
  two; the runner and the loop driver take `--fit chassis=module,module`. The massive HP
  question retired; section 12 asks the elites' scouting and trigger, the Wyvern's, the
  Elemental's and the Sandworm's tiers, the homages' names and which stage the tests describe.
- 23 October, the four Kestrel machines decided on 21 October, in content and modelled (Ryan's
  ask: models for every chassis ready to build, their silhouettes apart from the Kestrel
  roster's; `ccr-7d865127-wr1ko2`). The Needletail is runnable, every part of it built 21
  October (the validator's list of passive conditions had missed its gate's `setup_once`,
  added); the Skua, the Storm Petrel and the Giant Petrel are planned (their passives and locks
  wait on their engines, so they are never dealt), with Regenerating planned in the vocabulary.
  Numbers are placeholders at the stock pass's scale; the stocks by kind (a tier one stocks
  basics). The models are Claude's first cut, each in `tools/lowforge/models_low.py` with its
  rig, four acts and a gait, Ryan's to judge running: the Skua the line's one conventional jet
  (swing wings over tailplanes, swept on the move), the Needletail a needle on a stub wing with
  an upright booster nacelle on each tip (level on the move), the Storm Petrel a narrow hull
  under two raised riot plates and a mast lit with St. Elmo's fire (a new `corona` tile), the
  Giant Petrel after the Lun (eight boosters on canards over the bow, a T-tail, the Salvo's
  tubes on its spine). The holes raised for the engine sessions are in their briefs: the Skua's
  halving rounds up at single digits (a printed 1 doubles), and the Storm Petrel's burn is 2 a
  spend on basics. The hangar's renders and the bible's chassis and motion tables carry them.
  Ryan's notes the same day, on the first cut, open a second round of looks (the to-do): the
  Skua was the F-14 poly for poly, a homage with no originality, so it is redrawn (look tests:
  the jaeger and the oblique, `docs/looks/kestrel_skua.png`); the Needletail read as a nerf
  football, its wings to sit on the centre of mass, and flipped into the classic starfighter's
  layout is his to see (`docs/looks/kestrel_needletail.png`); the Storm Petrel is a speedboat
  with a mast that does not look like it takes a hit, so he proposed it and the Puffin trade
  bases, its holes in chat first; the Giant Petrel read as a chunky airliner with rockets tied
  to the front, its reference (the Lun) his question. The aims' shown words are none of the
  Needletail's (Ryan), so its brief retired (`git show 9ced5e5:docs/briefs/kestrel_interceptor.md`).
  His reads of 26 October and the third round of looks (`tools/lowforge/looks/kestrel_looks2.py`,
  the sheets in `docs/looks/`): the jaeger "pretty cool", so a second crack at it beside two more
  swing-wings (the scissor, an X of two stacked wings; the drop-tip, whose tips fold down); the
  starfighter Needletail good, so two riffs (the lance, with the designator as the needle's tip;
  the dart, a faceted diamond body); the swap taken as a stab (the Puffin on the boat, the Storm
  Petrel on the Puffin's hull with a bow plate and a front riot shield); the Lun the wrong
  reference, so the Giant Petrel as a flying-wing hovercraft and as a catamaran. His reads of 27
  October (the fourth round, `kestrel_looks3.py`): the diamond body with the lance's nose and tail
  for the Needletail (his tilt-jet question open in chat); the jaeger less bird and his twin swing
  for the Skua, the drop-tip cut; the flying wing over the catamaran, held; the swap's second
  stab (no bow plate, the field as rails and pylons, St. Elmo's port in the nose; the Puffin's
  plates kept as wings and amplifiers). His picks next, then the picks built with their acts.
- 23 October, Ryan's reads of the stock pass's bands settled (his "I think your suggestions are
  sound", of Claude's leans): the kill time read on a squad of four and the gap on built teams
  (the bible's tests row), the free wins left to the foes' fresh start (section 4's four-machines
  row), the finale a wall for a stock trio until the campaign runner fields built teams (section
  9's finale row), Wainwright & Sutler's light trio's wear accepted, the Kite's finisher a play
  read (the to-do). The runs they called for (`docs/measurements.md`, 30 seeds, directions): a
  built squad of four takes a lone massive foe in about two rounds where its stocks carry damage
  and three and a half to four and a half for Minerva's and Wainwright & Sutler's; the gap stays at 1.0 to
  1.3 on built teams, since on a lone massive foe a setup pays whoever cashes it. The planner's
  valuation, read on the way, priced a Shock as a bad roll, so the rerolls every rung shares
  threw a Polarity Projector away nine times in ten: fixed in `sim/policy.gd` (a blow's Shock
  worth the hitter in hand), which opened the gap by a tenth at most. Two questions went back
  to Ryan (section 12: where the gap is read, the massive HP, the second retired the same
  evening by his read by stage). The loop driver takes `--team`
  and `--set`.
- 22 October, the stock pass's landing and loops (the brief's section 7, on Opus): the content
  stands at the brief's stocks and pieces (the basic kit, eight new pieces and Trim Tabs, the
  renames and retirements, every piece's tier and tags, the Stoker's own fire) with the numbers
  six measured loops moved from the fills (`docs/measurements.md`): the foes hit harder (the
  rank and file's blows up by half, the massive foes' by a third, the heroes' doubled), the
  Sandworm and the Elemental stand at armour 1, the Treant and the Wyvern regrow 3, and the heat
  maxima are 12 and 14 (the Kite's 10 and the Musk Ox's 8 standing), all set by
  `tools/stock_fills.py`. Flak's clock is a field in its status (it halves still; the loops read
  a stack a round alike), and the balance runner reads `--packs`. Wear, the free wins and heat
  moved toward their tests; a massive foe still takes a team of three 3 to 8 rounds and the gap
  reads 1.0 to 1.2 (read on squads of four and built teams on 23 October, the bullet above). The review of the same evening (Ryan's go)
  raised the four light machines' hull from 16 to the scales row's floor of 20 (the Kite's paper
  hull 12 stands), widened the row to the fills' field recharge and the Condenser's capstone
  vent, and put the loop driver in the repository (`tools/stock_loop.py`).
- 22 October, the stock pass's engine chunk (the brief's section 6, on Opus at Ryan's word; on
  `claude/eager-newton-sf947u`, main merged in first): the tags' working set is the validator's
  list and the filing tags are gone (melee kept on its seven); every component stores its tier,
  0 to 3, a run starting with the tier-zero blueprints (today's tier one, so nothing changed in
  play) and the validator holding each chassis to stocking below its own tier, which today's
  stocks already obey after the migration (the brief had held that check behind a flag);
  danger close is gone, the Artillery Rangefinder a planned draft with its rule open; one breach
  is built on both sides (a foe's breach takes no armour off a machine; Breach a keyword our
  weapons may carry, ignoring a foe's armour, its chip a plate split by an arrow; no weapon
  carries it yet); the shown text says HP of a foe and the vocabulary has HP; the balance report
  has a Rounds to win section with the coordination gap read on the big fights; the three heat
  converters' steps are content fields at today's 10; the Boar's Spillover is a grant written
  out, the star on each weapon with the hold reading the passive's line; the content files'
  field guides are rewritten. The baseline reports ran on main's head of the morning
  (`a1585a9`) in a worktree (below, Measured). Ryan's marks on the brief's sections 1 to 5 are
  next; the content landing (section 7) follows them on Opus.
- 22 October, the numbers, armour and breach, decided in chat on 21 and 22 October (the bible's
  scales row in section 11, the kill-time, gap and wear tests in section 2, the armour and breach
  rows in section 5, the HP row in section 6; the rules edited to match, not built): every number
  inside a fight is single digits or low tens, derived from the tests and not from the old
  content (a blow 1 to 6, big guns to 10; foe HP 2 to 6 rank and file, 30 to 40 massive, 80 to
  100 bosses; machine hull 20 to 50, shield 6 to 16; heat 1 to 20, 1 to 30 the fallback); every
  converter crossing heat into another axis re-read on its own; armour stays flat with complete
  blocks, priced by role not size (a tank 2, a heavy worker 1, the rest 0), timed to 4 or 5 from
  braces, seals and charges, module armour scarce; breach and the pierce that was never built are
  one rider that ignores shield and armour, by move, the Ward its answer; foes have HP, machines
  hull. The plan and every first fill are `docs/briefs/stock_pass.md`: Ryan marks the proposal,
  the engine chunk (tags, stored tiers, basics, danger close out, the merged breach, HP wording,
  a rounds-to-win column, the converters as fields, the baseline run) needs no marks, the
  content landing follows them; Ryan switches to Opus for the implementation, the thinking being
  done here (his ask). Open with it (section 12): Overcharged's and Flak's halving clock, kept or
  unified; whether our guns take Breach.
- 21 October, the Musk Ox (Ryan's go of that day): its damaging guns pay ammo for the heat their
  own spend would make (1 for every 10, at least 1), a foe's Scorched still heating them; the
  magazine (10, opening at 3, 1 a round from the second, a vent on itself 3, a shield 2) is a
  bar under the heat, never a status; the cluster cannon refunds an ammo a foe reached, the
  salvo fires the magazine at random live foes with Spread and Penetrate, the quick reload adds
  2 for 15 heat (equipment's printed heat now lands); the die prints each gun's price and DRY.
  The bot prices an ammo at half the best damage one buys. Its content is runnable (no model
  yet). Fixed on the way: a multi-strike gun had paid its modifiers' heat on every strike (the
  Maxigun under Scorched heated 20, its die showing 10); heat is paid once a spend.
- 21 October, the Swallowtail (Ryan's go of that day): its Muster fills a point for every die
  that rolls, any machine's, 30 a charge and 5 a kill by its own guns, three charges its cap,
  a store no Silence or Purge touches (Ryan, 21 October), shown as a gauge under the heat with
  a notch a charge; with a charge up its locked pieces go out charged unasked (Ryan, 22 October: never
  primed), the die showing the charged form, and a charged form with nowhere to land leaves the
  plain one, the charge waiting; the charged Screens Phase the whole team or nobody, only
  while no ally has acted (Ryan, 22 October: never a selective protection). The Mooring Screens shield every ally, or
  Phase every ally yet to act (its die stands down, foes pick again, nothing reaches it); the
  Spotting Flare Exposes, or Exposes and Suppresses; the Sutler's Hoist cools an ally 10 then
  shields it, or the full reset; the Reveille Horn gives the team a reroll, or a spent ally acts
  again. On the map the machines beside it are lifted and travel as a ring round it, landing as
  a block where they rode (Ryan, 21 October): a stop the block does not fit is marked on the
  drawn route (NO ROOM, the failing hex struck) and refused, an undo taking them back. The bot weighs the die as it will
  go out. Its content is runnable (no model yet); its Sponsorship is the maker's measure, a
  damaging weapon entry counting and nothing else (Ryan, 21 October).
- 21 October, the Needletail's gate: a setup (a debuff or a buff, read as spent) is Rapid on its
  machine once a round, a static grant of Rapid on `setup_once`, the die showing it while the
  gate is open; the machine waits on its content session.
- 21 October, the Lammergeier (Ryan's go of that day; its brief retired to git): a machine
  whose passive lays mines may spend a weapon on an empty slot as if a foe stood there; each
  strike a shot, its number and keywords fixed when laid, the shots stacking in laid order and
  carried by the save. The reinforcement step places every arrival, then the mines land left
  to right before anyone acts, every keyword acting as on a blow (a stun its first action, a
  Chain repeating its spender's attack), shots left when the arrival falls waiting on; a Swap
  into a mined slot sets it off at once. The Lorentz Contractor's pull gathers every mine
  into its slot and a foe there takes them now; the Syrinx Drone's foe leaves its killing
  shot as a mine, the drone Rapid on a foe already Exposed and Exposing it otherwise. The bot
  values a mine at the odds a waiting foe steps in; the screen lights the slots a dragged
  weapon may take and marks a mined slot (a dashed outline, the mine with its total, a chip a
  keyword, a hold listing the shots). The chassis is in content (tier three, K-19 Mk I, the
  brief's placeholder numbers, a stock by kind, no model yet); its runner rows, its assets
  and Ryan's play are the to-do's.
- 21 October, Expose and Exposed (the Kestrel session's): every foe an Expose reaches and leaves
  standing is Exposed through the next round, in Direct reach of every machine and its armour
  counting for nothing, refreshed and never added; it feeds the Paradox and the target-status
  condition; the foe's card shows it; the bot weighs it. No Expose keyword in content until the
  Needletail's content session; the Lammergeier's Syrinx Drone lays Exposed since 21 October,
  and the Swallowtail's Flare will when its engine lands.
- 21 October, the Kite's rework (Ryan's go of that day): a passive may double a weapon's
  printed number alone (the buffs once after it) and grant a cooldown to every weapon; a kill
  trigger fires once after an attack that killed (the Kite's tax, Hot Streak a working name,
  5 heat a stack for the fight); a reset gun's kill lights every dark entry and acts again
  through Rapid's path. The Kite is tier two (K-7 Mk IV), a d3 of the Pinion Driver locked and
  two hardpoints stocking placeholders by kind until the stock pass (the Transonic Rifle and the Bleed Valve since 22 October); its passive's four
  effects its one-off (the validator honours a chassis's design.one_off), the die minimum
  three; the Railgun carries its own tier two off every stock. Its brief retired.
- 21 October, the combined entry (Ryan's go, 20 October): a vent may carry a shield half
  (`shields`), spent on the same machine after the vent and sized on the heat the vent leaves,
  through the spender's passives for an ally (the Puffin's Slipstream); the die prints the
  half's shield mark and number beside the heat slot, the hold says both, the bot weighs both,
  the validator keeps it to a vent. The Wake Diffuser shields 10.
- 21 October, the die's kinds and the no-number rule (Ryan, 20 and 21 October, the Kestrel
  session's grammar): a debuff, a weapon of no damage, deals nothing under any effect (the
  pipeline holds it at nothing, its heat a weapon's), prints no number anywhere, and wears its
  reach frame with the down arrow inside; read on the entry as it is spent, so the
  Cottonmouth's drum makes a debuff its 15. Judging it on the phone is Ryan's.
- 21 October, the party: dealt as the run starts, one hero to each domain from its bench, the
  front and the back even (two and two), by the seed on a stream of its own, kept through a
  save; a domain's final fields its dealt hero in its rank with its domain's first pack in the
  other columns and is won when the hero falls; the finale fields the party promoted, a column a
  domain, a beaten hero's column held by a standing domain's boss drawn in turn. The promoted
  forms are entries holding what the class change adds (massive, armour 5, one move more), the
  rest their heroes' as the content loads, the same names (Ryan, 21 October; flag it if they
  feel thin); the Cleric's Reraise readies one of its own (a party member first), and the other
  six moves and Fáfnir's mechanics are a slate in `docs/heroes_proposal.md` (section 12). The
  unit at the rift now commands it (the boss, a final's hero with its escort, the finale's
  line) and stands while a commander does; a withdrawn boss had walked off as a pack and come
  back with a spawn foe beside it, fixed, and a boss's kill counts toward salvage. The
  campaign runner reports the party and the finals; the balance report carries the party's
  cells (each bench hero's final, the finale): at 200 seeds every team row wins every final
  greedy, and the finale is a wall but for Minerva's team (3 / 71). The party card waits on the
  mission map.
- 20 and 21 October, the Kestrel session's builds (merged 21 October): the Puffin reworked at
  tier one (the Slipstream Projector: a shield it spends on an ally grows by a fifth of the heat
  that ally carries, read at the spend, by the die dragged over the ally and by the bot alike,
  `Skirmish.shield_amount`); the Wake Diffuser's Rapid off (a vent of 10 that shields 10 since the combined entry's
  engine, 21 October); the old finisher renamed the Coriolis Accelerator (the id with it),
  the Pinion Driver's name kept for the Kite's reset gun; the Sparrowhawk and the Goshawk shown
  as the Kite and the Buzzard (the ids kept).
- 21 October, the Dingo's Combat Translocator and the multi-target spend (Ryan's go of 19
  October; the interaction his of 21 October): Swap takes a second target, another foe or an
  empty slot, and the two trade places (a massive foe stays); on the screen the die dropped on
  its first target waits there, the seconds lit, a tap spends it, a hold reads as ever and a
  drag picks it back up; the Translocator is in content as the Dingo's second locked piece and
  the Dingo is tier two. Its model mount is the asset session's.
- 21 October, Silence and Purge on the enemy's side (Ryan, 17 and 18 October; a silence mutes
  keywords too on his word of 21 October): Silenced turns a machine's buffs off and mutes its
  components' keywords through its next round (cleansable, a chip with a struck voice); Purge
  takes every buff; neither touches a store (Ryan, 21 October: a store is a capped resource
  with a bar, the Nemesis's rage five boxes since 22 October, and an effect it grants is a
  buff, slept by a silence and silenced a turn by a purge, built with its first carrier); both ride a blow or come as a move, aimed at the buffed
  and cast where a machine carries a buff; the Ward turns both away; the bot values a Ward and
  a cleanse against them. No foe carries either yet (section 12).
- 21 October, the small items: the heat bar reads the net over a Cryo foe while a damaging die
  is held over it; the run tallies each maker's Sponsorship measure (hexes moved, damage taken
  on shield and armour, dice spent on entries that deal damage or none; each maker's content
  names its own); the balance report gains a heat section (peaks, hot rounds, overheats, dice
  held for heat) and `--module` twin rows with their differences; the bot values the
  Armadillo's seal. Welding the machines' meshes waits for a session that can count draw calls.
- 21 October, the Whip Scorpion's engine (Ryan's go, 20 October; the bible's Whip Scorpion
  row): a vent it spends on itself blasts a random live foe for the heat it took off (a static
  vent_blast, one blow through the pipeline, back rank included); the Heliographic Siphon lures
  every foe in the fight (reaches_all), braces, and every blow a foe lands on it that round adds
  10 heat (Siphoning, after the overheat), which the forecast counts; the bot values the blast
  and the Siphon's fuel. Fielded now; the vent entry's and the Siphon's forecasts and its
  runner rows are the to-do's.
- 21 October, the Cottonmouth's engine (Ryan's go, 19 October; the bible's Cottonmouth row):
  the Adaptive Munitions Drum as a static rewrite read first under every other passive's
  change (every weapon one Indirect shot of a flat 15 at heat 10, Ballistic, its own keywords,
  rules and tags kept; equipment fires as itself), and a keyword granted by the rank the spend
  is aimed at (Spread at the front, Penetrate at the back), carried by the spend, the bot's
  weighing and the die dragged over a foe. Fielded now; its runner row waits with the
  Cassowary's for the stock pass.
- 21 October, the Cassowary's engine (Ryan's go, 19 October; the bible's Cassowary row): the
  stepping die (the fight's first roll a spin, then a step on every roll, reroll and Rapid
  reroll; a lock holds; Scramble a true roll), the sixth weapon spend doubling its damage and
  the stacks it lays (an nth_shot rule through the pipeline), the Spin-Up's true spin (a
  printed `spins` on the entry, no cooldown, the validator's stepping-die exemption) and Spun
  Up (a buff spent by the next weapon spend); six pips under the heat bar, the next-chamber chip
  on the die, the next chamber marked in the hold; the bot turns the dial. It is fielded now,
  so the tender and the runner deal it. A weapon of no damage is held at nothing under any
  effect since 21 October (Ryan's die grammar, built that day, below), so Spun Up spent by a
  lure is wasted, as its rule says. The bot's cycle is the
  to-do's; the hold's ring and the hangar's chambers were built 22 October.
- 21 October, the shield rule, Barrier, Ward and cooldowns (Ryan's go of 14 and 15 October; the
  bible's shield, Barrier and Ward, cooldown and Rapid rows): a shield absorbs its number and the
  excess passes to the hull, a breach ignores the shield and leaves it standing, an injury
  counts what reaches the hull (one blow walk, `Skirmish.blows_on`, under the hit, the forecast
  and the foes' aim). Barrier and Ward are machine buffs a buff entry grants one machine: the
  Barrier takes the next blow that deals anything and never lets it injure, the Ward turns away
  every rider and the breach that round; their chips are the shield's outline with a bar or a
  struck ring inside; nothing carries either yet. A cooldown is a number printed on an entry,
  its rounds counted with the one it is spent in: Rapid's switch-off is a cooldown of one, the
  Cryo Flinger prints none (cooldown 0, its heat the limiter, Ryan's design of 20 October), the
  dark entry shows its rounds left on the die, and the validator refuses a Rapid entry with no
  limiter. The bot values both buffs and prices a cooldown. The balance runner splits across
  cores (`--part i/n`, `--merge`); the report's rerun under the new rule is in (Measured,
  below).
- 21 October, Flak (Ryan's go, 19 October; the bible's Prairie Dog row), built on main once the
  numbers branch merged: Flak N on the Flakshot Repeater (Flak 2, Spread, a flat 5, no Rapid),
  each foe hit gaining the stacks after the blow; every blow on a Flak foe a point more a stack,
  before Shocked's doubling and the armour, a blow of nothing staying nothing; the stacks halving
  at the round's end; the airburst chip, and Cryo's chip and snowflake with it (it had none); the
  die folding Flak in; the bot's `flak_score`; the Prairie Dog's 5 less from a Flak carrier
  awake. Its rows with and without it are in `docs/measurements.md` (21 October: about six points of the Prairie Dog's row alone, greedy 22.0 to 28.6, and a point or two on its maker's team). The
  family landed with the stock pass (the Airburst Shell, the Flak Cannon, 22 October); the plain
  pipeline stands, armour coming off after the Flak.
- 19 October, the funnel-web's assets (`ccr-ffcf75fa-3gkbz9`): its lowforge model
  (`models_low.py`'s `funnel_web`, Wainwright & Sutler's iron), four cuts in the day, each on
  Ryan's notes (the bible's funnel-web row has each and its reasons): a mechanical spider (too
  literal; a war machine), a low quad in the BattleTech Scorpion's shape (the larger boiler
  spider's likely shape, a lean in `docs/briefs/ws_boiler.md`; this one wants the Revenant's
  and the Arachnotron's legs under a turret), that turret on a hub with the legs going down,
  up and down for clearance (leggy is fine), and the fourth as it stands: the body in W&S's
  military camp (the Prairie Dog's and the gunship's, not the Clydesdale's and the Dingo's
  steam; no boiler, stack or hazard stripes), a dark lower hull running into a snout under an
  armoured upper hull with a wedge brow, two slit eyes, livery appliqué, an exhaust grille and
  a whip antenna; the `head` joint yaws and nods the whole body on the hub; the stations as
  his fifth notes dealt them: the Maxigun and the Twin Autoguns static in two mantlets on the
  jaw's flat face (a hanging chin gun had read as a proboscis), the Howitzer alone on the roof
  on `elev_top`, the Web Bomb's lit four-tube launcher out of the left pod on `elev_l`, the
  dish on the right pod on `elev_r`; no traverse anywhere, the torso twist aims them. The legs: `coxa_` joints at the hub's corners carry struts down
  to low hips, thighs up to high knees, shins down to flat feet with toe plates (hip, knee and
  ankle each); 20 joints. Four acts (`stalk`, a sink and a lunge on a sharp servo; `scan`;
  `sight_in`, the torso twisting to the launcher as it rises lit, then to the roof gun as it
  elevates; `probe`, a fore leg tapping ahead) and the creep: `_plant` with every foot one step
  a stride, out of step, and the coxae rowing under the solver (his sixth notes, his pick of
  the options after the feet still flicked forward: a limb's `coxa` in `_plant`, the rest
  points turned about the pivot before each solve by `_turned`, the angle folded into the
  foot's flatness, the angle from `_coxa_row`, each half of the cycle a cosine; the strut
  steepened so the turn rows the hip fore and aft), a longer stride (sweep 36, stride 51) and
  the solver's new `carry` window, (0.04, 0.92) here, the old (0.12, 0.76) the default for every
  other walker; the fore feet's two short steps a stride and the head's turn toward each foot
  were cut on his fifth notes (hot-stepping, too busy; weird); the row at twenty degrees was
  a gait option for a day (his seventh: what would the extreme look like; his eighth: no
  visible difference, so it is gone); the jaw six shorter with the bow guns near flush and the
  roof mount aft of the pods (the seventh), sunk into the roof (the eighth); the flank plates
  are raked fins in the livery (the eighth); the acts on the eighth notes: the scan and the
  sighting twist the head twenty and turn the rest by pivoting the legs (quick steps, one
  foot up at a time; his ninth, 20 October: a shuffle whose planted feet slid was no shuffle,
  so each leg has a `yaw_` joint at its root and `_pivot` solves the yaw per frame that keeps
  a planted foot's world position in the leg's plane, the planar solver taking the rest, each
  stepping foot set down at rest under the body as the round ends; forward kinematics checks
  no planted foot moves; 24 joints), the fins' base squared off and the antenna's base run
  into the hull (the ninth too; his tenth, 20 October: a toned-back cut of the fins was too
  small, so they are the eighth's shape and size on a level base, and the scan's first turn,
  the slow one, goes in under a second; his eleventh, the same day: the antenna a little
  inboard, clear of the fin, and the model is good to go),
  and the acts use the vertical range (the stalk coils ten deep and strikes up, the scan rears
  and sinks, the sighting rears, the probe dips; the head's pitch limits -20 to 15); the
  cornering numbers; the rig test covers it; the hangar's renders (front,
  rear, the lunge, a side-on moment of the creep; the third cut under "before") and the page
  republished. Judging it running is Ryan's. A cloud note: the bpy wheel took twenty minutes
  to install; a build regenerates the maker's review tiles (`tools/lowforge/tiles/`)
  byte-different and the import four Prairie Dog textures, restore both rather than commit.
- 20 October, planted footwork across the walkers (`ccr-ffcf75fa-3gkbz9`, Ryan's ask after
  the funnel-web's pivot: a turn for the Dillo, lateral motion for the bipeds, more joints never
  hurt; the Clydesdale left as it is by lore, the Baboon as it is): `_footwork` in
  `models_low.py` plans a body free in every axis over planted feet and steps some of them,
  each hip's own yaw and roll keeping its foot where it stands and pointing where it landed
  (`_leg_fk6` and `_leg_newton6`, the engine's sums, six axes a leg, thirty keys a second;
  no joints added, since every joint carries three channels and the hips' limits name only
  the pitch; a step lands under the body as it will stand at a named moment, or halfway to
  the limb's next lift); sparse tracks beside the dense legs go through `_dense` so they keep
  their smooth ease under the act's linear one. The acts: the Armadillo's `come_about` (four
  diagonal pairs, eight degrees a step on the planted pair, twenty-four round, guns up and
  lamps lit in the hold, and back; it sits four and a half lower through it, its legs straight
  in their planes), the Nemesis's `raise_meteor` braced (its right foot back and out as the
  machine turns ten to its mark, the waist's sixteen on top; it was the waist alone) and
  `square_up` (the left foot stamps out wide and back as the machine turns twenty-six on its
  planted right, fists up, the torso wound further on the waist, the core burning, then the
  stamp back; a sideways `pace` was built first and looked like dancing to Ryan, so it is
  gone, git keeps it), the Ammit's `circle` (an arc about a point ahead, facing it, the hands
  two steps to a foot's one, two moves round to one side and two back, nose down, talons
  working; one each way through the centre read weaker to Ryan). The hangar's renders carry
  a frame of each; the bible's row and its motion table. Ryan's reads so far: the Dillo good;
  the square-up and the circle's second cut his to judge running.
- 18 October, the funnel-web's engine (`ccr-ffcf75fa-3gkbz9`): the chassis is playable, its
  content's planned marks off; its model landed 19 October (above).
  Vitriol is a foe status with a share tick of its own (`tick_hp_share`: after Burning, on
  what it leaves, the whole share rounded down and never the last hit point); the ambush is a
  passive effect, `lay_status` on the `target_no_intent` condition (`Foe.intent_on`, the read
  the arrows draw: a foe on a special that acts on nobody shows no arrow now), read at the
  spend before the spend's own riders, each foe reached judged alone, a stack per strike that
  lands with a number, so the web's blow of nothing is no hit; the Web Bomb carries the Web
  keyword, Webbed bursting at the end of the foe's action, skipped or not, into a Suppress on
  it and on the next to act beside it (`Skirmish.web_catch`: the right-hand neighbour in its
  rank, else the left, which has acted), each half feeding the Paradox as a weapon's would;
  the chips (Vitriol's count; the web's `>` or `<` at its catch); the predator sense
  (`PreyLayer`: the foes' ground dims, the eligible foes get narrowed pulsing eyes, ink on a
  dark edge with a HUD glow; `RIFTGATE_PREY_DEBUG=1` keeps it on), started hot and not yet
  judged on a phone; the bot values a bite by Vitriol's ticks on the hull the blow leaves
  (`Policy.dot_payout`, `VITRIOL_WEIGHT`) and a web by the blows its burst stops
  (`web_score`); its row alone at 30 seeds is in `docs/measurements.md`, a direction. Claude's
  engine calls, Ryan's to overrule: a blow of nothing is no hit; the web is a keyword, not a
  printed property; the chip's mark; the untargeted special's missing arrow.
- 18 October, the Kestrel session (`claude/zealous-cori-8xoly7`, fast-forwarded onto main as it
  went): the three Kestrel briefs carry every round of their design (the strafer decided in
  shape, the shield-spender's direction, the bomber's pull and mark); the bible's section 6
  holds the vocabulary's two tables from `tools/pages/bible_tables.py` and the naming
  convention; built: Folded become Braced, every status a chip, timed stacks keeping their own
  rounds, the stacking policy (add or renew), Suppressed never stacking nor carrying, the Boar's
  spill; records: Numbed and the banked stores are buffs (two kinds, no third), Silence and
  Dispel (Purge since 20 October) decided for the enemy's side with Ward turning both away (not
  built).
  Then 18 to 21 October (`ccr-b6da49d3-4ft738`, merged 21 October): the line decided and
  named in the Kestrel briefs (above, and under Decided, not built).
- Built and tested: the battle (the round, orders, fights by ring and range, hunters, five map
  types, Rift Pressure without escalation, the boss after its reveal); the skirmish as
  `docs/rules.md` states it, Rally included (Kindled at its move's value, live from the next
  round); the campaign's rules headless only (`sim/campaign.gd`, no screens); the balance
  runner (`tools/balance.gd`: `--rows`, `--module`, `--bump`, `--nopassive`, `--set`,
  `--trace`), the campaign runner and the map survey; every ally model by lowforge with acts
  and gaits; the foe art; six tracks, the effects and Jenny's lines.
- Content: five makers, 24 chassis, every one runnable but the Skua, the Storm Petrel and the
  Giant Petrel, planned since 23 October (the funnel-web built, its engine 18
  October and its model 19 to 20 October, its Web Bomb built; the Cassowary, the Cottonmouth
  and the Whip Scorpion built 21 October, and that day the Kite's rework, the Lammergeier, the
  Swallowtail and the Musk Ox; a planned chassis is never dealt, the campaign's Start rule),
  80 components (32 locked, five of them planned), 17 modules, four domains with 18 wildlife and bosses
  and 8 heroes; 8 foe moves still `planned`. Every number is a placeholder; any whole number
  may be used (the scales are magnitudes), move alone in steps of 5. The content still carries
  the old kinetic-and-energy split (every rolled weapon cold, every flat one hot), which the
  stock pass re-prices by niche (the bible's rolled-or-flat row, Ryan, 13 October).
- Decided on 13 October, from Ryan's clarifications: the whole roster goes to one front and
  the fronts left alone bleed (section 3); a battle is played to its end, no withdrawal from a
  battle (section 4); five to ten meaningful skirmishes then the boss, never twenty two-round
  fights (section 4's pacing row); neither rolled nor flat owns heat (section 5); stuns are
  budgeted and a depth-and-breadth session measures the roster against itself (section 5); the
  roster is widened so compositions can be read (section 11). Later the same day: four machines
  moving as one, a detachment a decision priced by time (section 4); the Rupture meter and
  Anathema fill by the threat-weighted tally, the Favour dock the gate's price (section 3);
  offers one of each kind, a chassis on the shelf, host-maker offers shaping the roster
  (section 10); twelve to sixteen battles recommended; the battle withdrawal reopened (section
  4, Claude's walk-out proposal, which Ryan finds thematic and decides later); heat bites where
  it is carried, a cold build pays elsewhere, and a cool weapon is soft cooling, heat builds are a
  spectrum between passive cooling and venting, and the runner reads heat spikes, forced choices
  and the damage forgone to heat rather than counting vents (section 5); cooldowns in a skirmish reopened
  (decided 14 October: a printed property on specific pieces, section 8); the Arsenal's tier-one components exist
  (section 10); the map stays nine wide; the screens third in the order; Rift Pressure no longer
  ticks per round fought, only on the map (section 4, built); the brief for the roster session.
- The records, after Ryan's review of 13 October: the bible's first row says what a Decided
  row may be, what a Lean is and what a "never" must carry; the measurements live in
  `docs/measurements.md`; section 12 holds only the questions; this file holds the order of
  work; the to-do holds the tasks; the keyword line-up and the enemy roster proposal are
  retired (git has them), their open items in section 12 and their seeds in the bible's rows.
- Debug switches added on 12 and 13 October: `RIFTGATE_RAGE_DEBUG=1` (the rage's roll again);
  on 18 October `RIFTGATE_PREY_DEBUG=1` (the predator sense kept on);
  screenshot poses `rage` and `heat` (`tools/screenshot.gd`).
- Foe art: every foe and hero is cut from Ryan's picks at 72x96 (massive 96x144, chibis 36x48);
  fourteen rounds on the phone picker, 13 to 15 October, closed every note he wrote on the
  wildlife and the chibis, and his cutting batch (pockets of pure white now key by default,
  the chibis cut at one body scale with every weapon inside the frame); each pick's source, cut options and his notes are in
  `tools/foeforge/picks/picks.json`. What worked: a flaw tried through the edit model once
  or twice, then image to image from the pick he liked (`forge.py generate --image`), never
  from the last pass (it drifts) and never a PIL hand edit on a figure (three failed his bar);
  one set per sprite per round. The heroes' boss register is picked and recorded, not in the
  game (the promoted forms are not entries); staff fingers on the White and Black Mage and
  the Martial Artist's fist are hand jobs. The Summoner carries deep violet rune circles and
  Pyroclasm. Next for the foes: the roster questions in section 12 (the Bomb, the marked goblin and revenant candidates), the head sizes if Ryan wants them level.
- Built 15 October: a foe's blow at every machine (`all`: each strike on each live machine,
  arrows to every machine, the plaque naming it once, the bot counting it on each), carried by
  the four storms since the foe kit refresh (Root Storm, Quake, Bone Storm, Cleave); and the
  boss mechanics, each inside the skirmish: a countdown (the Lancer's Jump runs on it), a boss
  in parts (a core Guarded while its parts stand, parts regrowing), a last act (a death blow
  the moment a foe falls), foes helping foes (a cure and a protect; the White Mage carries
  Dia, Cure and Holy, Ryan's three, its Protect parked). On 16 October the Augur (Clair
  Obscur's Sciel by archetype; a working name) took the Necromancer's place on the Marsh's
  bench: Omen, a countdown of two at one machine, and Harvest below half, a countdown of one
  on every machine (the two pieces paired, tested); the Necromancer and its art are gone. The White Mage is the Cleric (id kept), its promoted form's one move more Reraise on its allies, planned (Ryan, 16 October). The Summoner's summons are its moves,
  full Norse (Ryan): Skaði's frostbite, Surtr's Pyroclasm, Fáfnir the promoted form's; the Elemental no longer called. The
  boss art round is on the picker: sets from `tools/foeforge/drafts.json` (art ahead of
  content), the Fallen Weapon drawn as hammer and as axe, the third round Skaði, Fáfnir and Floraison. The bosses' slate and Ryan's marks
  are `docs/bosses_proposal.md`.
- Built later on 15 October (the small-work pass): the Oblation Ward is the Oblation Mantle
  (its name; the id stays, as the Bone Wyvern's did); the Megataser Harpoon carries Shock in
  place of Suppress; a suppressed foe's hold readout names no blow and no target (its glyph,
  arrow and forecast already cleared, the Suppressed chip leading its row); a boss is the
  content's word whatever its size (`Foe.boss` from a faction's `boss`, the plaque reading it,
  the validator no longer asking a boss to be massive but refusing a hero as one), the boss
  pack `Unit.is_boss` (a save that says `elite` still loads), `RIFTGATE_BOSS=1` in place of
  `RIFTGATE_ELITE=1`; and a fight resumed from a save keeps a foe's boss, a Gel's split and a
  foe gone whole (all three were lost on the trip).
- Built 15 October, on the Minerva branch (Ryan's call in that session): every reroll, the
  team's and Rapid's free one, skips only the entry showing, so a copy of it may come up and
  copies of one Rapid component chain. Skipping copies too was abusable: a die of one key entry
  and copies of one filler sent every reroll from a filler onto the key. The machines with
  copies on their dice (the Baboon's Inducers, the Boar's Slugthrowers, the Nemesis's fists,
  the Ammit's talons) reroll onto a copy now and then: an A/B on those four, greedy, 100 seeds,
  moved no row mean a point (`docs/measurements.md`, 15 October), since their copies are the
  entries the bot keeps; the Ammit's Talons rose from 46% of its spends to 51%. Open with it:
  a Rapid piece with no cooldown (the Armadillo's lure, cantrips) needs a limit that keeps its
  chain finite: Ryan's rule (15 October) is that Rapid always carries one, a cooldown, heat or
  Volatile (the bible's Rapid row; the validator's check waits on the cooldown property).
- Built 20 October, on the Minerva branch (Ryan's go; the bible's Armadillo row, section 7):
  the Armadillo is the form-changing tank. Lockdown, its passive (`seal_form`: armour +10 on a
  base of 5, 15 heat at the end of each sealed turn before the overheat, its own cooling
  stopped; a shield on itself seals, a vent or a damaging weapon opens; one renewing Sealed
  chip carrying the armour); the Cryo Flinger pair, fixed (Indirect, no damage, Lure, Rapid,
  Cryo 1, 5 heat); Cryo, a numbered keyword like Burn and a foe status, any machine's damaging
  hit spending every stack to cool the hitter 10 a stack after its own heat lands, valued by
  the bot as a vent; the Lockdown Shutters and the Faraday Hull out of content (the Shoring
  Jack unstocked, tier one); four hardpoints (rivet gun, slugthrower, Blast Door, Blowout
  Stack). Every heat number a placeholder ahead of the heat rework (Ryan). The model still
  has five pins and no racks (the to-do's art line).
- Built 18 October, on the Minerva branch (Ryan's calls, 18 October; the bible's section
  5): Braced is Armoured on both sides, an armour point a stack (the Shoring Jack 10, the
  Breaching Plow 10, the Phase Conjugator 3 a shield, a foe's brace its value in stacks, the
  engine id `braced` kept); Overcharged a damage point a stack, halving at the end of each
  round, rounded down, from every source, a buff of it carrying no rounds (the Overcharge
  Coil 2, the Grievance Reliquary a stack a blow); the Quintessence Tap keeps every
  Overcharged on the Ammit whatever granted it, the talons giving two a kill; Burn a numbered
  keyword (`burn` on the face beside the keyword, the validator asking for it: 3 on the
  10-damage pieces, 5 on the 15s) and a foe's Burning a damage point a stack; the status
  table's decays gained `half`, the brace validator asks a positive number, and the word
  "devour" is gone from the records (the vocabulary's entry is "Overcharged a kill").
- Built 15 October, on the Minerva branch (Ryan: "Roman numerals in the corner? ... grey on
  the black background"): every die entry shows its place on the die, from I, as a grey Roman
  numeral in the quotes' condensed italic, top left on the die and down the hold and the codex
  (a gutter left of each tile), counted fixed components first. It shows a reroll onto a copy,
  which hardpoint holds what, and the revolver's order. The codex's two narrow columns now
  give a long description a second line rather than clipping it. Ryan, 16 October, from the
  screenshots against Share Tech Mono: "Keep the italic for the number, it works better."
- Known gaps: Jenny's foe-down lines are keyed by the retired families.

## Measured, 22 and 23 October

- `docs/balance.md` at 200 seeds on main's head of the morning (`a1585a9`), the baseline before
  the stock pass: every row the day's main left alone reads as on 21 October to the decimal;
  the Clydesdale, the Funnel-web, the Whip Scorpion and the Wainwright & Sutler team rise a
  point or two (the heat paid once a spend); the new rows alone read the Musk Ox 56.4 / 67.5,
  the Swallowtail 16.4 / 42.0, the Lammergeier 3.0 / 27.1; the party's cells as on 21 October.
  Heat barely bites: the hottest rows peak at 70 to 80% and overheat under once a fight. The
  coordination gap today (the team rows, the same commit, the branch's Rounds to win): greedy
  wins about half again as fast on the big fights and on the rank and file alike (1.35 to 1.63),
  an efficiency edge, not the gap the tests ask for (about 2 on the big fights, none on trash).
  The 21 October report's reads stand beside it (the shield rule's few points, the Armadillo's
  and the Kite's reworks): `docs/measurements.md` has both.
- The stock pass's fills as a direction (30 seeds, every row against every pack, the brief's
  sections 1 to 5 applied to a scratch checkout; `docs/measurements.md`): trash dies to a die or
  two, a massive foe takes a team three to twelve rounds, the gap stays at one and a half
  everywhere, every team wins every pack but the finale on both rungs, heat bites on five kits.
  The fills divided the old numbers unevenly; the entry names the levers for Ryan's marks.
- The stock pass's loops on the landed content (30 seeds, the four team rows with every rung,
  every chassis alone for heat, the campaign; `docs/measurements.md`): kept the foes' blows up,
  the elites' armour 1, the regrows 3 and the maxima 12 and 14; our durability down a quarter
  and cooling 0 set aside; Flak's two clocks alike. The rank and file die in under two rounds
  for every team and cost nothing alone; formations cost 7 to 36% of a team's hull, random
  losing some where greedy wins; heat bites the hot kits alone (78 to 107% at the peak). Not
  moved: a massive foe at 3 to 8 rounds against one or two, the gap at 1.0 to 1.2 (opening only
  where a stock holds a Shock), the finale a wall, the campaign's plain player at 1% of battles.
- The stock pass's bands at 200 seeds on the landed numbers (`docs/balance.md`, the gap on the
  team rows' big fights, `docs/campaign_run.md`; `docs/measurements.md`): the loops' reads hold.
  The teams win a wildlife pack in 1.6 to 2.2 rounds, a massive foe in 2.9 to 7.8, a formation for
  7 to 37% of their hull; the gap 1.05 to 1.17; random play still wins 19 to 28 of the 29 packs a
  team while a machine alone meets walls on 6 to 24; the hot kits peak at 74 to 94%, the cold
  ones under 45; the campaign 0 of 40 runs, 1% of battles.
- The tests on squads of four and on built teams (23 October, 30 seeds on the big fights, greedy,
  blind and the planner; `docs/measurements.md`): a stocked four takes a lone massive foe in 2.4
  to 4.8 rounds and a built four in 2.2 to 4.3 (the trios 2.9 to 7.4); a four loses 3 to 7% of
  its hull on a formation; the gap 1.04 to 1.27 on built teams' big fights and 1.0 to 1.2 on a
  lone massive foe; the planner wins the finale now and then with Kestrel's four (one to three
  fights of thirty). Two experiments in copies, the bots' Shock priced at the hitter in hand
  (landed) and a trio's order, each moving the gap by 0.15 at most.
- The starter trios (23 October, every trio a tender can deal, stock, against every pack, 30
  seeds; `docs/measurements.md`), the early half of Ryan's read by stage: the rank and file, the
  Treant, the Bone Wyvern and most finals are free for a starter; the Peak's, the Marsh's and the
  Meadow's formations, the Magma Elemental and the Sandworm are its fights; the finale a wall. The
  Honey Badger and the Cottonmouth carry a starter, and a third of tenders deal neither.
- The endgame fours (23 October, the read's endgame half: five fours of any tier fitted from
  pieces and modules up to tier two, `tools/endgame_fours.py`, 30 seeds; `docs/measurements.md`):
  every pack but the finale is free for an endgame four, random play included (0 to 6% of its
  hull a fight, a lone massive foe in two to three rounds), and the finale is its one fight
  (greedy two times in three for about two thirds of its hull, random losing). Nothing sits
  between a starter's fights and the finale: the middle and late curve is the fresh start's.
- Whom the foes strike (23 October, `tools/target_probe.gd`, every starter trio against each
  faction's formation, boss and first pack, 20 seeds; `docs/measurements.md`): the exposed aim
  spreads its picks evenly while the team stands (29 to 36% a machine), half its draws level;
  the tanks take more over whole fights by outliving the light machines and by the Armadillo's
  Lure, and against the Treant and the Wyvern by the draw chasing a broken shield. A shield-held
  boss's round asks only whom to shield: the depth and the pressure are short, not the aim.
- Targeting and shields on the starters (23 October, 30 seeds; `docs/measurements.md`): halving
  both basic shield pieces barely moves a starter (the Treant and the Wyvern 1 to 4% hull, the
  Peak's formation three more walls), since a lone boss's whole fight is about a trio's standing
  shield; every foe at random reads a little easier than the shipped aims and every foe on focus
  harder, both on the formations alone, focus taking from the weaker starters about what the
  halved shields take. The loop driver's `aim` lever sets every foe's aim.
- `docs/campaign_run.md` on main (rerun 22 October on the baseline's commit, line for line the same): the plain player wins none of 40 runs and one battle of 348
  (12 of 40 and 24% on 13 October). No bug: a bisect lands on the Armadillo's rework, and 11 of
  the 12 runs won on 13 October had drafted the old Armadillo, the one machine that carried a
  lone fight; the plain player's fights are still mostly one machine (572 of 734), and one
  machine against one pack now wins 31%. The report reads nothing until a player fights as a
  team (the fourth item below; section 12 asks whether to bring that forward). Both in
  `docs/measurements.md`.

## Decided, not built

- The action economy's direction (the bible's section 5, 20 October, beside the stun row):
  Rapid is priced by a gate and never rationed, and each want it sells has a home that is not
  a Rapid piece (own rerolls as a number, the team's order, counters that count blows,
  combined entries, rolls again paid in a banked resource, cooldown bursts, delayed actions,
  commander actions on map cooldowns); what the stock pass does with it is in the row and in
  `docs/briefs/stock_pass.md`, the reasoning in the briefs README.
- Silence and Purge's carriers (section 12) and the front's card's intel (with the mission map).
- Area belongs to keywords on any reach: Splash folds into Spread and Penetrate, and an
  explosive carries both; which explosives is Ryan's (section 12), none landed with the stock
  pass (danger close retired 22 October; the Artillery Rangefinder's new rule built the same day).
- Purge, our keyword for the foes' buffs (its carriers and numbers open; Purge on both sides for
  now, Ryan, 20 October).
- The go on the roster analysis, 14 and 15 October (rows and `docs/rules.md` lines): the shield
  rule, Barrier and Ward, and cooldowns (built 21 October, above); Misharu's payoff Penance; the Votive Screen's name;
  Kestrel's strafer and bomber (the harpoon's Shock, the Oblation Mantle and the cleared
  intent built 15 October). The engine work is on the to-do. The budgets (15 October): adding
  hard control always carefully considered with other options explored first, no caps; a new
  chassis earns its place by a new read, product or price; a passive aims to be fed by and to
  feed other makers' pieces; a tier one shows its identity with basics alone.
- The Swallowtail's and the Musk Ox's models (their engines and content landed 21 October,
  the bible's rows in section 7; the to-do's asset lines).
- The Kestrel line (the session of 18 to 21 October; the bible's Kestrel, Kite, Puffin,
  die-entry, names, locked-component and stock-pass rows; each machine's kit in its brief): to
  build, the engines of the Skua (a swing-wing strafer, tier one), the Storm Petrel (a
  hovercraft off-tank, tier one) and the Giant Petrel (the formation leader, tier three), each
  the to-do's line, their content planned and their models in since 23 October (the Needletail
  landed whole that day; the Kite's rework, Exposed and Expose, the die's kinds and the
  Lammergeier built 21 October, above); a
  Rapid shield never below tier two and a Rapid vent never below three; a locked piece's power at its chassis's depth; the Buzzard's stock and the three
  stock pieces (the Cyclic Cannon, the Transonic Rifle, Trim Tabs), landed with the stock
  pass on 22 October; the designations K-13 to K-21. Kestrel's lean is heat, rerolls, strikes and risk; Expose stays
  out of it for now (Ryan, 21 October).

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list).

1. **The design sessions, from the briefs** (`docs/briefs/`, 15 October). Ryan's go on the
   roster analysis decided what "Decided, not built" lists; every proposal, direction and
   rework it left open (the Onryō, the Armadillo as a form changer at tier one, the Baboon at
   tier two, the Gundam, the jellyfish, Mastema, the funnel-web and the rest) is a brief, the
   design's one home, with what Ryan said and what is open, and the README gives the shared
   context, the tiers as proposed, the budgets (decided 15 October), the roster holes and an order. Each
   decision becomes a row; the analysis page retires to git once the last brief that cites it
   lands. The funnel-web landed first (18 October); the Cassowary, the Cottonmouth, the
   Dingo's Translocator and the Prairie Dog's fight half on 19 October, the boiler as the Whip
   Scorpion on 20 October, and the maker's tiers confirmed the same day (3-5-2, the bible's
   roster row). The Rapid discussion in the maker's context followed (20 October): the
   Prairie Dog's pivot, the helicarrier as the Swallowtail and the artillery as the Musk Ox
   landed (21 October); the gunship waited for the stock pass's tags and the numbers' rescale
   (Ryan, 21 October: "since that's its whole deal"), which landed 22 October, so its session
   is the maker's next. The Arsenal's four wait on Ryan: Claude's
   first round and its review are in their briefs, none of it answered, Misharu first.
   Kestrel's line is decided and named (21 October, merged that day): its last two chassis,
   the Magpie and the Snowy Owl, are Ryan's next session, from their briefs, and each decided
   machine's engine session follows from its brief (the to-do's lines), their content and
   models landed 23 October on `ccr-7d865127-wr1ko2`, the Needletail whole, and the looks in a
   second round on Ryan's notes of that day (the to-do).
2. **The stock pass** (`docs/briefs/stock_pass.md`): landed 22 October and merged into main
   that evening on Ryan's go: its engine items, its content at the brief's fills (the stocks,
   the renames and retirements, the eight new pieces and Trim Tabs, the tiers and tags), the
   loops' numbers and the bands at 200 seeds (`docs/measurements.md`); the stun calls are the
   stun row's. Ryan settled the bands' reads on 23 October (the bible's rows), and their runs
   put two questions back to him (section 12: where the gap is read, and which stage the tests
   describe, the massive HP retired by his read by stage); next his
   name pass and the pricing run, on the bots' Shock priced at the hitter in hand. Two content
   questions went to section 12 with the landing: which explosives carry Spread and Penetrate,
   and a flat Indirect basic. The brief's table missed the Lammergeier's stock (the to-do).
3. **Balancing for real** (Ryan, 14 October: only once the go is hashed out and the stock
   pass is in can the units be balanced for real). The runner's rows on the roster as the
   stock pass leaves it, the third-machine read and the fours again, prices and tier ladders
   (the to-do's engine line), the heat report, and Ryan's play deciding feel.
4. **The foes' fresh start, the fight-size spectrum and the Rupture meter.** Reads section 4's
   pacing and four-machines rows, section 9, section 12's foe questions and
   `docs/campaign_run.md`. Builds compositions with a front and a back spawned by the rift, small
   packs for detachments and formations for the body, the boss sealed by the threat-weighted
   meter and fought with its formation, the withdrawing persona on the campaign bot, the curve by
   stage (section 3's curve row) and the elites on Ryan's definition (section 9's tiers row), read
   against the starter and endgame grids of 23 October (`docs/measurements.md`); then reruns
   both reports and measures the fights a team fights together.
5. **The screens** (Ryan, 13 October: early, so the first thing built after the battle has
   its shape is a run he can play; the go, the stock pass and the balancing come first, Ryan,
   14 October): a prototype hangar, the mission map and the draft; every build
   order the roster session hands down lands in a game being played.
6. **The economy pass** (`docs/economy_pass.md`): the runner's spending policy, then every price
   and yield with the offers one of each kind, a chassis on the shelf, the Favour dock as the
   gate's price, twelve to sixteen battles.
7. The rest in the roadmap's standing order: Ryan's text; the domains' last engine (the planned
   moves; the party and three bosses a domain built, the bosses' slate content alone); the pacing session's
   remaining pieces; battery; audio; art; the commander layer after a balance baseline;
   onboarding before a phone leaves the desk.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them by
URL (read first). Databases are reachable only from the personal account. A page's link goes
into this file in the same commit as its first publish; the procedures are in `README.md`.

- The roster analysis: https://claude.ai/artifact/QVLRVD8YXsK8ZUKY3A1vxo, rendered from
  `docs/roster_analysis.md` by `tools/pages/roster_analysis_page.py` and published 14 October,
  republished 15 October with its section 12 cut to a pointer; republish after the page changes, and retire it with the page once the last brief
  that cites it lands.
- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. This file is v0.268, and so is the live (23
  October, the page's version 285, from `ccr-7d865127-wr1ko2`: the Kestrel models' second round
  of looks, the Needletail's brief retired and the aims' wording off it, the tables read with
  `ccr-170f6d81-465jnr`'s tooling, published onto `claude/eager-newton-sf947u`'s v0.267, the
  page's version 284: Ryan's terms and elite definition, the curve row, balance read by stage
  and the Elemental; its first row, from the bible cut for session context, says what a row
  holds).
  The version numbers on the publishing branch's file and the live agree after every publish,
  main's catching up at the merge; the rows between them are the other branches'. Git and the
  page's version history carry what each earlier publish brought.
  Before republishing, read the live page; if another session moved it, publish a three-way
  merge onto it (`git merge-file` with main's last-published file as the base, the wrapper's
  first line and its trailing `</body></html>` stripped from the saved live source).
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each checked identical to main's before it is
  replaced and `edits` read first. At the page's version 99 (23 October, from
  `ccr-7d865127-wr1ko2`: the foes' file with the Elemental, and the chassis and components files
  with the Needletail's brief retired; the live files identical to main's and to version 98's
  and `edits` empty before it); version 98 brought the four Kestrel machines' content, models,
  rigs and renders, and git and the page's history hold the republishes before. Its
  database (Ryan's saved edits, collection `edits`; name candidates, `candidates`) opens only
  from the personal account.
- The boss art round's picks (Ryan, 18 October): the Behemoth, the Cinder Tortoise and the Fallen
  Weapon (the axe, which settles hammer against axe) cut into `art/foes` and recorded in
  `tools/foeforge/picks/picks.json` (art ahead of content: nothing loads them until their kits
  land); since then the Reaper, Fáfnir, Skaði and the Matador (19 October) the same way, so of
  the slate on the picker only Surtr, Floraison and the Augur remain; his notes drove a second round, on the picker for his next picks: the Matador's missing
  hand, the Reaper's extra hand, Skaði's lower-hand weapon and Fáfnir's gold through the edit
  model (the Reaper's two edit passes failed and image to image from the pick fixed it, his pick
  of that set cut on 18 October; the fix order is a bible row now: structure through image to
  image, colour through the edit mode, costume by a fresh take); Floraison redrawn humanoid with
  take 1's face, Surtr made of fire rather than on fire,
  the Augur without the coat and hood, bigger blades, both hands on the haft (fresh takes and
  image to image from the take he called closest). His second picks, the same evening: the
  Reaper (image to image, its third hand gone) and Fáfnir (the gold off) cut; the Matador, Skaði,
  Surtr, Floraison and the Augur into a third round, image to image from his picks under the
  fix-order rule. His third picks (19 October) asked for composites (2's head and boots on the
  Matador's 3, 1's head on Floraison's 2), a defined face and a held sword on Surtr, another set
  for the Augur and a retry for Skaði; the fourth round answers each (the composites as layouts
  re-rendered close beside the edit model's version; the Augur from a prompt of her own, since
  the hero style's "robes and flowing cloth" was drawing her tunics) and is on the picker. His
  fourth picks (19 October) each carry one edit more (the Matador's jaw, Floraison's clipped
  spines, Skaði's lower half as the edit's, Surtr's sword alone after a two-part edit broke it,
  the Augur's omen dark then her blades matched, chained), the fifth round; the heroes' costume
  variety pass is a to-do, the Augur's omen dark in the bible's art row (v0.204, live, merged onto another session's v0.202).
  Ryan's ask of 19 October, the staff slanted so the lower blade goes behind her legs, is rendered
  (three usable each size) and on the picker beside the upright picks and his last pick; the
  slant gains the hero's body about a tenth in the cut, the chibi little. The size worry that
  started it was Claude's misreading (the cut crops to the figure's box, so a render's margin
  costs nothing), corrected in the heroes' proposal and the picker memory.
  His fifth picks (19 October): Skaði cut (fixbow5 1); the Matador's and Floraison's edits failed,
  so both go back to composites of aligned siblings, raw and after a close pass; Surtr's blade
  added to the grip he liked; the Augur's slanted 4 picked, its blades lengthened first, the eyes
  and the smoke to follow, and the other lean rendered at his ask. The sixth round is on the
  picker (19 October), one set per question: the Matador's and Floraison's composites clean (raw
  and closed), Surtr's blade of fire by the edit model (the pass at 0.6 lost it), the Augur's
  other lean (three usable each size), her blade options on one base (as picked; long, a
  composite stretch, at a fifth less body in the cut, 128 px of 144 to 103, measured; broader at
  no cost) and her smoke's three homes, her eyes relit on every one; the heroes' proposal has
  the round and what it found (room alone grows nothing, a pass redraws an earlier colour edit,
  so structure first and colour last). His sixth picks (19 October, afternoon): the Matador cut
  (fixhand6 3, the second close pass, recorded and imported); Surtr's 2 "so close", its blade to
  turn five degrees clockwise onto the grip's line, done by hand as a layout and closed at 0.9,
  the sword's column pasted back onto his pick beside the full pass; Floraison "still weird even
  at phone scale, cut off or blurred", so another way: the eyes inside the maw painted out on his
  pick itself (an erase over dark, nothing re-rendered) beside image to image at 0.7; the Augur's
  lean 1 his new base at both sizes (the rotation went too far, her other hand on the staff), the
  smoke erased by hand and the top blade flipped inward (the edit model landed the hero's in two
  of six seeds; the chibi's by a reflection of the head across the shaft's axis, the hand edit the
  layout for a pass); the blade and smoke sets superseded unpicked. The seventh round is on the
  picker.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor); picks and notes in collection `picks`, readable from a personal-account session.
  It holds the boss art round's seventh sets (19 October): Surtr's blade on the grip's line
  (`surtr_bossart10`), Floraison's eyes painted out (`bourgeon_bossart10`) and the Augur's new
  base with the smoke gone and the top blade flipped inward (`augur_heroart16`,
  `augur_chibi_heroart16`), built by `forge.py phone --only --tags bossart10 heroart16
  chibi_heroart16 --keys surtr_bossart10 bourgeon_bossart10 augur_heroart16
  augur_chibi_heroart16`; every earlier round's folder stays under `tools/foeforge/out/` as the
  record, and the renders that lost a blade or a brief sit in each set's `set_aside/`.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

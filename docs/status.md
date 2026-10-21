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
- Tests: 571 tests, 62,101 checks, green on main (21 October, with the Lammergeier, the Needletail's gate and the Swallowtail); 485 and 20,291 on the Windows desk machine on 19
  October, about a minute there. A cloud session fetches
  Godot 4.7's Linux build from the GitHub release asset (`godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`), uses `xvfb-run` for screenshots, and builds models
  with `BPY_PYTHON` set to a python3.11 venv holding `bpy==5.0.1`. Its first `--import`
  rewrites four Prairie Dog textures; restore them (`git checkout -- art/models/prairie_dog_*`)
  rather than commit them.

## Branches

No branch is live beside main. Every branch is merged into main (checked 21 October) and is to
be deleted from the desk machine or GitHub, since a cloud session's push to delete them is
refused: `claude/festive-cray-i7lvnm`, `ccr-b6da49d3-4ft738`, `ccr-3259e29d-ydwpom`,
`claude/intelligent-planck-uwmbhg` and `claude/busy-carson-hmaz96`, merged that day, and
`ccr-ffcf75fa-3gkbz9`, `claude/adoring-planck-q8t63w`, `claude/zealous-cori-8xoly7`,
`claude/pensive-albattani-q73ibs`, `ccr-777fd46a-32dw2m` and `ccr-3d9861dc-mp0v3w`, merged
before it. The five design sessions merged that day are paused, each resuming from its briefs:

- Wainwright & Sutler (since 15 October on `claude/festive-cray-i7lvnm`, its commits
  fast-forwarded into main as they landed; wrapped up 21 October, Ryan: "make sure everything is
  merged in and wrapped up"): ten machines decided, 3-5-2, the bible's roster row saying where
  each stands. Built: the Prairie Dog with Flak, the Clydesdale, the funnel-web, the Cassowary,
  the Cottonmouth, the Whip Scorpion and the Dingo with its Combat Translocator. Planned in
  content, and so never dealt until its engine lands: the Musk Ox (the to-do's engine line);
  the Swallowtail's engine landed 21 October. The gunship's brief waits for the stock pass's tags and the numbers'
  rescale (Ryan, 21 October); the five new machines' models and the Translocator's mount are the
  to-do's art lines.
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

- 21 October, the Swallowtail (Ryan's go of that day): its Muster fills a point for every die
  that rolls, any machine's, 30 a charge and 5 a kill by its own guns, three charges its cap,
  a store a Silence sleeps and a Purge takes, shown as a gauge under the heat with a notch a
  charge; a tap on the carrier arms its die for the charged form (Claude's gesture, Ryan's to
  judge), which the die shows until it is spent. The Mooring Screens shield every ally, or
  Phase every ally yet to act (its die stands down, foes pick again, nothing reaches it); the
  Spotting Flare Exposes, or Exposes and Suppresses; the Sutler's Hoist cools an ally 10 then
  shields it, or the full reset; the Reveille Horn gives the team a reroll, or a spent ally acts
  again. On the map the machines beside it ride with it and are set down beside its stop, a
  stop that cannot seat them refused, an undo taking them back. The bot spends a muster when the
  charged form beats the plain by more than half what the charge would buy banked, and always at
  the cap. Its content is runnable (no model yet); the Sponsorship clause is a section 12
  question.
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
  two hardpoints stocking placeholders by kind until the stock pass; its passive's four
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
  cells (each bench hero's final, the finale), a 30-seed direction on the team row reading
  every final won in both rungs and the finale 13 / 73. The party card waits on the mission map.
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
  keywords too on his word of 21 October): Silenced turns a machine's buffs and stores off and
  mutes its components' keywords through its next round (cleansable, a chip with a struck
  voice); Purge takes every buff and store; both ride a blow or come as a move, aimed at the
  buffed and cast where a machine carries a buff; the Ward turns both away; the bot values a
  Ward and a cleanse against them. No foe carries either yet (section 12).
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
  lure is wasted, as its rule says. The hold's ring, the
  hangar's chambers and the bot's cycle are the to-do's.
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
  cores (`--part i/n`, `--merge`); the report's rerun under the new rule is under way on
  today's main (a run on the shield commit itself finished, but main's rows have moved since).
- 21 October, Flak (Ryan's go, 19 October; the bible's Prairie Dog row), built on main once the
  numbers branch merged: Flak N on the Flakshot Repeater (Flak 2, Spread, a flat 5, no Rapid),
  each foe hit gaining the stacks after the blow; every blow on a Flak foe a point more a stack,
  before Shocked's doubling and the armour, a blow of nothing staying nothing; the stacks halving
  at the round's end; the airburst chip, and Cryo's chip and snowflake with it (it had none); the
  die folding Flak in; the bot's `flak_score`; the Prairie Dog's 5 less from a Flak carrier
  awake. Its rows with and without it are in `docs/measurements.md` (21 October: about six points of the Prairie Dog's row alone, greedy 22.0 to 28.6, and a point or two on its maker's team). The
  family (an airburst shell, a flak cannon) and past armour or not are the stock pass's.
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
- Content: five makers, 17 chassis and two planned (the funnel-web built, its engine 18
  October and its model 19 to 20 October, its Web Bomb built; the Cassowary, the Cottonmouth
  and the Whip Scorpion built 21 October; the Swallowtail and the Musk Ox, 21 October, planned;
  a planned chassis is never dealt, the campaign's Start rule), 58 components (15 locked, 4 unstocked, among them
  the shelved Gravity Knuckles at tier three), 16 modules, four domains with 18 wildlife and bosses
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
  full Norse (Ryan): Skaði's frostbite, Surtr's Pyroclasm, Fáfnir the promoted form's; the Golem no longer called. The
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

## Measured, 13 October

- `docs/campaign_run.md` on the four domains and today's rules: the plain player wins 12 of 40
  runs with the in-fight Rift Pressure tick gone (3 of 40 with it that morning; 29 of 40 on 9
  October, before the domains), 24% of battles, 75% wiped, 3.5 cities fallen a run. Not Rally:
  the commit before the fix gave 0 of 40 with the tick. The bot
  takes every ready machine to one front, as intended, but fights inside a battle are mostly
  one machine alone (1,157 of 1,747), wrecks sit out with no spares, and the bot never
  withdraws from a skirmish. A lone machine wins 64% against a pack and 37% against two; two
  together win 92%.
- `docs/balance.md` at 200 seeds: every team row keeps its 9 October band; alone the machines
  move a few points, the Nemesis most (greedy 61 to 76); the cells that moved follow the rules
  (the Peak open to nearly everyone and closed to the Buzzard, the bosses harder for the heavy
  machines, the Marsh's formation a decision for the Armadillo and a wall for the Boar); flat
  weapons pay about twice the heat per point that rolled ones do. The bands of both are in
  `docs/measurements.md`.

## Decided, not built

- The action economy's direction (the bible's section 5, 20 October, beside the stun row):
  Rapid is priced by a gate and never rationed, and each want it sells has a home that is not
  a Rapid piece (own rerolls as a number, the team's order, counters that count blows,
  combined entries, rolls again paid in a banked resource, cooldown bursts, delayed actions,
  commander actions on map cooldowns); what the stock pass does with it is in the to-do's
  stock pass line, the reasoning in the briefs README.
- Silence and Purge's carriers (section 12) and the front's card's intel (with the mission map).
- The stock pass: tags on every component (the working set Ballistic, Missile, Beam, Plasma,
  Flame, Arc, Blade, Melee), the shared basic kit at tier zero (every basic's blueprint owned
  from a run's start), the old close weapons brought to Direct's band, the Pinion Driver locked
  on the Kite, the Baboon free to stock a shield, every tier-one chassis on basics beside
  its locked piece, each component's tier in its entry and every chassis stocking only below
  its own tier (the Arsenal's tier-one components exist for its tier twos to stock), a bought
  chassis bringing copies of its stock and never the blueprints, heat re-priced by niche so
  that it bites (section 5's heat row: a machine firing every round overheats by its third).
- Danger close retires and area belongs to keywords on any reach: Splash folds into Spread and
  Penetrate, an explosive carries both (the Artillery Rangefinder needs a new rule).
- Purge, our keyword for the foes' buffs (its carriers and numbers open; Purge on both sides for
  now, Ryan, 20 October).
- The go on the roster analysis, 14 and 15 October (rows and `docs/rules.md` lines): the shield
  rule, Barrier and Ward, and cooldowns (built 21 October, above); Misharu's payoff Penance; the Votive Screen's name;
  Kestrel's strafer and bomber (the harpoon's Shock, the Oblation Mantle and the cleared
  intent built 15 October). The engine work is on the to-do. The budgets (15 October): adding
  hard control always carefully considered with other options explored first, no caps; a new
  chassis earns its place by a new read, product or price; a passive aims to be fed by and to
  feed other makers' pieces; a tier one shows its identity with basics alone.
- The Swallowtail (Ryan's go, 21 October; its row in section 7): the helicarrier, the maker's
  first tier three, an assault flyer; the multi-rotor's lending and then its equipment slots
  cut (20 October). Its Muster Deck carries the machines beside it on the map (set down on the
  nearest standable hexes, their move and action kept) and fills the Muster, a third bar, a
  sliver on every die's roll (about thirty a charge, a kill by its guns five), per fight; its
  four locked pieces each have a plain and a charged form (the Mooring Screens: a team shield,
  or Phased on every ally that has not acted, no cooldown; the Spotting Flare: it Exposes a
  foe, or Exposes and Suppresses it; the Sutler's Hoist: a shield and cooling, or the full
  reset; the Reveille Horn: a team reroll, or an ally acts again); three hardpoints. Nothing on
  it is called Mark (Ryan, 21 October, in the Kestrel session): the Flare's face takes Expose
  when Expose enters the vocabulary (the Needletail's content session, or the Swallowtail's
  engine if it comes first). In content as planned entries (Muster and Rallied in the
  vocabulary); the engine and the assets are the to-do's two lines. The Hoist is no loader for
  the artillery (Ryan, 21 October).
- The Musk Ox (Ryan's go, 21 October; its row in section 7): the artillery, the maker's second
  tier three, a wide assault battery on big wheels. Its Desublimation Forge fires its damaging
  guns from ammo instead of heat (1 for every 10 heat at today's scale, 2 at the pass's; at
  least 1), a magazine of 10 that opens each fight at 3 and gains 1 a round, its own vents
  adding 3 and shields 2; everything else keeps heat on a low heat bar. Locked: the Shrapnel
  Recuperator (Flak 1 for the team and 1 ammo back for every foe hit), the Unrestricted
  Expenditure (every ammo as a strike at a random foe, Spread and Penetrate) and the quick
  reload for testing (Rapid, 2 ammo, heat, no vent to the Forge); four hardpoints. Ryan agreed
  Claude's three calls the same day: ammo a resource no Silence or Purge reaches, the content
  at today's heat scale until the stock pass, the quick reload's 2 all it adds. In content as planned entries
  (Ammo a planned resource in the vocabulary); the engine and the assets are the to-do's two
  lines.
- The Kestrel line (the session of 18 to 21 October; the bible's Kestrel, Kite, Puffin,
  die-entry, names, locked-component and stock-pass rows; each machine's kit in its brief): to
  build, the Skua (a swing-wing strafer, tier one), the Storm Petrel (a hovercraft off-tank,
  tier one), the Needletail's content and its gate (a tilt-jet that Exposes, tier two) and
  the Giant Petrel (the formation leader, tier three), each the to-do's line (the Kite's
  rework, Exposed and Expose, the die's kinds and the Lammergeier built 21 October, above); a
  Rapid shield never below tier two and a Rapid vent never below three; a locked piece's power at its chassis's depth; the Buzzard's stock and three
  stock pieces (the Cyclic Cannon, the Transonic Rifle, Trim Tabs) with the stock pass; the
  designations K-13 to K-21. Kestrel's lean is heat, rerolls, strikes and risk; Expose stays
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
   landed (21 October); the gunship waits for the stock pass's tags and the numbers' rescale
   (Ryan, 21 October: "since that's its whole deal"), so the maker's design sessions are done
   until then. The Arsenal's four wait on Ryan: Claude's
   first round and its review are in their briefs, none of it answered, Misharu first.
   Kestrel's line is decided and named (21 October, merged that day): its last two chassis,
   the Magpie and the Snowy Owl, are Ryan's next session, from their briefs, and each decided
   machine's content and engine session follows from its brief (the to-do's lines).
2. **The stock pass**, once Ryan answers section 12's content questions: tags, the basic kit,
   heat re-priced by niche so that it bites where carried and a cold build pays elsewhere, the
   area keywords on the explosives.
3. **Balancing for real** (Ryan, 14 October: only once the go is hashed out and the stock
   pass is in can the units be balanced for real). The runner's rows on the roster as the
   stock pass leaves it, the third-machine read and the fours again, prices and tier ladders
   (the to-do's engine line), the heat report, and Ryan's play deciding feel.
4. **The foes' fresh start, the fight-size spectrum and the Rupture meter.** Reads section 4's
   pacing and four-machines rows, section 9, section 12's foe questions and
   `docs/campaign_run.md`. Builds compositions with a front and a back spawned by the rift, small
   packs for detachments and formations for the body, the boss sealed by the threat-weighted
   meter and fought with its formation, the withdrawing persona on the campaign bot; then reruns
   both reports and measures the fights a team fights together.
5. **The screens** (Ryan, 13 October: early, so the first thing built after the battle has
   its shape is a run he can play; the go, the stock pass and the balancing come first, Ryan,
   14 October): a prototype hangar, the mission map and the draft; every build
   order the roster session hands down lands in a game being played.
6. **The economy pass** (`docs/economy_pass.md`): the runner's spending policy, then every price
   and yield with the offers one of each kind, a chassis on the shelf, the Favour dock as the
   gate's price, twelve to sixteen battles.
7. The rest in the roadmap's standing order: Ryan's text; the domains' engine (the planned
   moves, the party dealt from the benches, three bosses a domain); the pacing session's
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
  `docs/design-bible.html` after every change. Main's file is v0.244, and so is the live
  (21 October): the live v0.243 (the Kestrel branch merged, its rows and the regenerated
  tables) with the party's rows on top (the deal, the Cleric's Reraise built, the promoted forms,
  the finale and the finals, section 12's slate question) and the tables regenerated (the
  promoted Cleric's Reraise beside the Zombie Knight's). The version numbers on main's file and the live agree after every
  publish; the rows between them are the other branches'. Git and the page's version history
  carry what each earlier publish brought.
  Before republishing, read the live page; if another session moved it, publish a three-way
  merge onto it (`git merge-file` with main's last-published file as the base, the wrapper's
  first line and its trailing `</body></html>` stripped from the saved live source).
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map. Republished 15 October from main's content:
  only the four content files that had moved since 13 October (chassis, components, foes,
  vocabulary), the page, the models and the renders checked unchanged and kept; again that
  evening with the boss mechanics' foes and vocabulary alone, and with the White Mage's three
  and Skaði; on 16 October with the Augur in the Necromancer's place (foes, factions) and the
  Cleric (foes); on 19 and 20 October with the funnel-web's model, rig sidecar, pins and renders,
  the content that had moved, and the walkers' planted footwork, the last on 20 October
  (`ccr-ffcf75fa-3gkbz9`); main's content has moved since (21 October's landings and merges,
  the Kestrel branch's among them: the Puffin's passive, the Kite's and the Buzzard's names, the
  Coriolis Accelerator, the Wake Diffuser), so the next content session republishes it. Its database
  (Ryan's saved edits, collection `edits`; name candidates, `candidates`) opens only from the
  personal account; `edits` was empty on 15 October, after the second republish too.
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

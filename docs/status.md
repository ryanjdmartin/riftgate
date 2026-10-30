# Status

How things stand, for the next session, and the order of work. Facts and the state as left;
history lives in git (this file's changelog to 23 October: `git show 9bec2ba:docs/status.md`).
The rules are `docs/rules.md`; the why and the questions only Ryan can settle are the bible
(`docs/design-bible.html`, its first row first); the tasks are `docs/todo.md`; every run a
decision cites is `docs/measurements.md`; the layout, every document's job and every command
are in `README.md`.

## Start here

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row, this file and `docs/todo.md`. If a
  chat and a file disagree, the chat is newer.
- Sessions run in parallel on this repo: `git status` first, stage by path, diff a shared file
  before staging it, never a bare `git add -A`, never kill a bare `godot --path .`. Local main
  and `origin/main` diverge for a day at a time; merge `origin/main` into local main before a
  records pass, and expect the bible's live page to have moved (read it, merge, republish).
- The desk machine is a Windows PC since 19 October (the Mac went out of reach mid-session):
  `C:\Users\jam82\Desktop\Code\riftgate`; the README's Running section says what is set up
  there. What the Mac held outside git is gone. Of the seventh round's foeforge renders
  (force-added in `fb45141`, its picks cut on 26 October), only the Augur's stay in git, her
  only surviving renders, kept for her next pass (the rest: `git show fb45141`); foeforge's
  `generate` and `fix` have no machine until a route for the image model is chosen.
- Tests: 777 tests, 204,651 checks, green on main (30 October, `ccr-c04908be-3r43xf`
  merged: the pricing pass, Chain, the cautious heat persona; 759 and 204,504 on the tilesets'
  second build), about four minutes in a cloud session, twenty on a slow one. A cloud
  session gets Godot 4.7's Linux build and the project's first import from the repository's
  session-start hook (`.claude/hooks/session-start.sh`, registered in `.claude/settings.json`,
  27 October, on main since 30 October; the GitHub release asset `godotengine/godot-builds`,
  `Godot_v4.7.2-stable_linux.x86_64.zip`, into `~/bin`; a session without the hook fetches it by
  hand, the download in a command of its own and the unpacking and first run in another, since
  Auto mode refuses one line that fetches and runs it), uses `xvfb-run` for screenshots (with
  `--rendering-method gl_compatibility`, Mesa's llvmpipe on the CPU: its draw calls are true
  counts, its frame times mean nothing), and builds models with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1` (the wheel takes about twenty minutes to install). Its first `--import` rewrites
  four Prairie Dog textures and a model build the maker's review tiles: restore both
  (`git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`) rather than commit them.

## Branches

`ccr-7821127e-kwj874` (28 October) carried the movement landing (moves in hexes, the proposal,
its build and its records), took main the same evening (the ladder: its 26 recolours' moves in
hexes, the cockatrice, ghost, bomb and drake lines winged), then the heroes without a map move,
the faster wolves and the battlefield viewer's deletion, and main took it as a fast-forward that
night on Ryan's word ("clean up and merge into main").

The review of 27 October (this branch, `ccr-24cae16e-ryhv1v`) merged every branch that stood
beside main into it, since two sessions had each expected main to take theirs on the 26th and
neither merged the other: `ccr-170f6d81-465jnr` (Ryan's go of 26 October: the die's hold, the
units' holds and the codex as text, the keywords list, area at half, Flak on a weapon's blow of
0, the weapon and equipment words, the vent's blast as a weapon's hit, Spun Up spent by a weapon
alone, the Skua's runner rows), `claude/quick-campaign-mode-pafhiv` (the quick campaign, one
damage state, the bosses at their tier), `ccr-6073bda9-p34o8q` (the foes' fresh start proposed,
`docs/foes_proposal.md`; the campaign bot moving as one with its withdrawing persona; `--pack` on
the balance runner), `ccr-7d865127-wr1ko2` (the Kestrel looks' third and fourth rounds, which the
status of the 26th listed as fully merged while they stood unmerged) and `ccr-7effd31a-u5z4gw`
(the Hold The Line pair). The conflicts were the records and the two sessions' same-afternoon
changes to the skirmish (each merge commit says how it was resolved); the suite ran green on
the result (the Tests line) and main took this branch as a fast-forward the same day. The
models session's `ccr-7d865127-wr1ko2` (the Kestrel models' second round through Ryan's eight
rounds of notes, the hangar's stamped fetches and the glow-parts guard) took main twice on the
28th and main took it as a fast-forward that evening on his word ("clean up and merge into
main"). `ccr-6073bda9-p34o8q` took main the same evening, carried the ladder's build on top
(the three verbs, the foes' buffs, the player's Purge, the recolours by tier, their sprites,
the read at 30 seeds and the move counts settled), and main took it as a fast-forward that
night on the same word. `ccr-c04908be-3r43xf` (27 to 30 October: the pricing run's method and
driver, the runs made and read, the synergy map (`docs/synergy_map.md`) and the roster's synergy
holes, the session-start hook that fetches Godot for cloud sessions, the pricing pass landed on
Ryan's go, Chain's conductor and its form of the 29th with every read, Shock read by an aimed
strike alone, the heat brief, the cautious heat persona) took main on the 28th and twice on the
30th, and main took it as a fast-forward on the 30th on Ryan's word ("merge into main and
republish the bible"); its session carries on there, its later commits landing the same way.
Every other branch named here is fully
merged, to delete from the desk machine or GitHub along with `ccr-6073bda9-p34o8q`,
`claude/affectionate-goldberg-8e3mkh`, `claude/playtesting-issues-08mnqj`, `ccr-535a7596-5ptzsj`,
`claude/eager-newton-sf947u`, `claude/friendly-cannon-kyk9v4`, `ccr-24cae16e-ryhv1v` and, once
its session ends, `ccr-7821127e-kwj874` and `ccr-c04908be-3r43xf` (a cloud session may not delete one). Every other branch was
merged into main and deleted (22 October).

## The design sessions

Each resumes from its briefs; `docs/briefs/README.md`'s table says what each waits on.

- Kestrel: ten machines, eight decided and in content (the bible's Kestrel row; the hub
  `docs/briefs/kestrel_line.md`). Its models' second round landed 28 October and took two
  rounds of his notes the same day (the Storm Petrel's field strips, sparks, beaded arch and
  emitters clear of the guns; the Puffin's plates near plumb with lit rims, its amplify's glow
  found dead, a prefix the rig never matches, and the build refusing one since; the
  Lammergeier's launcher nacelles, riding the wing's upper skin, their tube mouths holes cut through the face plate and bored
  twelve deep above the skin,
  the Storm Petrel's arch on feet with two-thirds sleeves; the Skua's five acts,
  the run and the stoops flown as a banked circle and a figure eight on the map (the Kite's
  helpers under a spline height profile with the nose rate-limited, `_over_ground`) after
  Ryan's phone frames showed the keyed forty units as bobbing in its hex, the bigger keyed cut
  as janky and the first flown cut as flicking, the roll with the hands spread; Ryan's picks
  from
  five rounds of looks: the Skua the jaeger, the Puffin and the Storm Petrel on each other's hulls,
  the Lammergeier the flying wing; the Needletail's two modes and the Giant Petrel's catamaran
  his next session's, the to-do; the scissor swing wing tried again the same day as a look for
  one of the two unspecced designs, two F-14 pairs on their own pivots that open into an X and
  beat as an ornithopter and close into a blade, `docs/looks/kestrel_ornithopter.png`; parked as
  a candidate for the Owl or the Magpie, the bible's Kestrel row). The Skua fielded since its engine of 25 October (each roll
  halved, rounded down and never below one since 27 October, and struck twice; the Pod's spray), its rows read the same day: mid-field
  alone, its way through plate a flat buff on each strike (`docs/measurements.md`); the Giant Petrel's engine session
  follows from its brief, and the Storm Petrel's is free since the pricing pass landed (28 October, the guns' heat
  standing); the last two, the Magpie (a working name, a support engine)
  and the Snowy Owl (a stealth unit), are Ryan's next session, his directions and Claude's first
  round in each unanswered.
- Wainwright & Sutler: ten decided, 3-5-2, nine built (the bible's roster row); the gunship's
  session is free to run.
- Minerva: the Honey Badger's rework in session (Ryan's calls in its brief, four numbers open),
  the echidna left open, the siege battery parked on Ryan's charge brief, the battlecruiser never
  with the Carrier's session (Ryan, 20 October).
- Aphelion: the line frame and the Baboon first (the pair that keeps its tier-one deal varied),
  then the jellyfish; the Carrier on its own; a defensive tier one unproposed (the to-do).
- The Arsenal: Misharu, the Onryō, Mastema and Minos, Claude's first round and review in their
  briefs, unanswered: Misharu's two calls first (Penance's shape, how often it may fire), then
  the Onryō's kind and trigger.

## How things stand

- Map movement in hexes (Ryan, 27 and 28 October: the move points and the terrain table "add
  confusion and overhead for no strategic gain"; landed on main 28 October, the proposal retired
  with it): a move is a count of hexes given in one go, ground is ground, water
  the one priced hex (two of a ground machine's move, always enterable with what is left), crags
  the flyer's; the winged foes (five and their eight recolours) cross both, and a hunter that cannot ring its prey picks
  again; the gauge and the stop sign gone (the bible's section 4 rows, v0.342). Measured the same
  day (`docs/measurements.md`): the maps are unchanged seed for seed; every way of moving now
  reaches the rift in 6 phases at move 3 and reach is the move and the walls; the campaign run's
  bands hold, its three-machine battles won more (a direction: the squad no longer split by
  slow ground). The six shapes followed the next day (below); still to come for the map: the
  domains' tilesets as an art task and the crossing's price in the pricing run (the to-do).
- The heroes carry no map move and no hunt (Ryan, 28 October, of the Thief's: "it's a boss so
  it doesn't need it"): a hero only commands the boss unit, which patrols a hex a turn, and the
  validator refuses either; the Thief's codex lost its speed claim. The Dire Wolf's line moves 4
  (Ryan: it "can be faster"), the Warg and the Alpha Warg with it, and its codex no longer
  compares it with the cars (the mechanics audit's 29); the campaign run moves no band on it.
- The six map shapes (Ryan's direction of 28 October and his calls of 29 October; landed 29
  October, the brief retired): RIVER CROSSING, FJORD, BADLANDS, OPEN STEPPE, RUINED CITY and
  GORGE, each laying its own water, walls, decorative ground and relief; a battle that names no
  shape (the campaign's) draws one by its seed, every shape alike; Mixed Ground and the other
  four types retired. The walls are named by what they are (crags, mesas, towers, cliffs) on the
  ground tap, a fight's label and the skirmish's header, the vocabulary's terms tied to the map
  by the validator, and the cliffs a new look (rock prisms, basalt-like). The decoration is
  knee-high under walls of 40 and more, dense in the scenery and against walls and water,
  sparse in the lanes, of the shape's kind (reeds, shingle, scree, scrub, rubble, grass), and
  the roads lead to the fords and through the gaps or are not laid. The field is level but for
  the badlands' mesas on their shoulders and the steppe's one rise; the scenery rises. A
  domain names no shape (Ryan, 30 October: "I don't see why the domain should be related to the
  map type in any way"; its `map_kind` gone from content and refused by the validator), height
  is a look alone ("Too complicated, not worth"), and a skirmish never reads our own ground,
  only, if a terrain effect ever comes, the ground the enemy paints (the bible's twisted
  landscape row). Measured (`docs/measurements.md`): every shape keeps the
  horde's crossing three wide on all 200 maps; the shapes part on reach (the walkers' two-phase
  reach 38% on the gorge and the badlands to 51% on the steppe, the hover's 47% to 62%, the
  flyer's 62% on all); the relief steps on 0% to 16% of neighbouring land where it stepped on
  55%; the campaign run moves no band. Next: Ryan's read of them running (the to-do).
- The horde moves as the machines do (Ryan, 29 October; built the same day): a pack wades water
  at two a hex as a ground machine does, packs pass through each other, a flyer (a machine or a
  winged pack) and the ground pass each other, and nobody stops on another unit's hex; grounded
  machines still block each other and the grounded packs, so the bodyblock stays and the
  crossing guarantee binds the walls alone. A river's fords and a city band's streets are three
  or four hexes in all, the river's one or two (four broke it into ponds) and a band's one to
  four. Measured (`docs/measurements.md`): the horde's crossing stays three wide on every map,
  the guarantee opens nothing on water, and only the city's reach moves (the walkers' 44% where
  42%, its streets spread); the campaign run moves no band, the fights' sizes with it on this
  bot, which never holds a line.
- The hunters pounce (Ryan, 29 October; built the same day): every hunter's ring is two at
  least (the Goblin Captain's three; the validator holds it), one number for its catch, the
  fights it joins and the ring drawn. A hunter keeps its prey and goes for it by any route; only
  when walls and machines seal the prey off does it take the machine nearest the prey that a
  walk that turn can ring, its tag, the board's HUNTED BY and its readout following ("It's just
  punishing hiding"); the re-pick is gone. Measured (`docs/measurements.md`): the campaign run
  moves no outcome band, and the fights grow, 54% of them against two packs or more where 45%
  were. Ryan asked whether a hunter joins a fight it did not start: it does, as every pack does,
  on Claude's lean until he says otherwise (the bible's fights-picked row). Next: his read of
  the pounce in play (the to-do), the exit bringing the ring back down.
- Each domain paints its own tileset (Ryan, 29 October), built twice on 30 October
  (`game/ui/domain_ground.gd`, by the factions' `bleed`). Ryan turned the first down (the
  marks were rectangles, water and the walls were alike everywhere, and each ground had its own
  fill: "walls and water certainly should change with tileset", the grounds "not wildly
  different"; the Peak not volcanic, the Marsh not an undead marsh). The second dresses every
  hex in outlined pixel sprites (ASCII art inked per domain, two pixels a design pixel; "Overall
  the art is a huge improvement"), each ground its own tone a step from its domain's on the
  posterize grid (his second read: one ground for all was "very monotone"). Each domain also
  has its own water (the Meadow's lake, the Waste's oasis, the Marsh's murk, the Peak's lava)
  and its own walls (snowy peaks, red buttes, black crags, volcanoes). A road follows the roads
  beside it, three road hexes round a corner making a loop with a gap in the middle (his ask).
  Every colour is on the posterize grid and scored against its ground by the colourblind
  simulations (`docs/measurements.md`). `RIFTGATE_BLEED_DEBUG=1` paints the whole
  field and `tools/tileset_shot.gd` draws all four. Next, Ryan's read of them running (the
  to-do). `claude/jolly-lovelace-scn82y` paints the skirmish's backdrop per domain from its
  own palette table (`BattleBackdrop.PALETTES`, the same bleed keys). When it lands, the two
  tables want one home, and its rewrite of `game/ui/terrain_art.gd` and
  `game/battle/painted_map.gd` meets this one's (the painted map draws through
  `DomainGround.draw_hex` and passes each road hex its links).
- The harness's battlefield viewer (`game/main.tscn`, a flat 2D debug view from before the 3D
  map) is gone (Ryan, 28 October): the battle screen shows all it did. The mechanics audit's
  map texts are closed (29 October: packs pass under a flyer, the gate's codex, a spawn's shown
  name, the boss's patrol and ring, the fifth caveat) but the crags' shown word (its 30).
- Built: what the bible's section 12 lists, run as `docs/rules.md` states it (its known gaps at
  the end). The campaign's rules run headless only (`sim/campaign.gd`); no screen shows them.
  Since 27 October main also holds, from the branches above, the quick campaign on screen with
  the game's first hangar, the die's, the units' and the map's holds as text with the keywords
  list, area at half, one damage state and the bosses at their tier.
- The quick campaign (25 October): battles without the map, headless, saved, on screen with the
  game's first hangar, run by `tools/quick_run.gd`. Its first runs (`docs/quick_run.md`,
  `docs/measurements.md`, 40 runs a rung) find a cliff at the first battle for a starting trio
  (34 to 36 runs of 40 lost there on the branch; 39 of 40 on main's head of 27 October with the
  bench-hero stand-in out, 22 of them at the boss, whose fight with its formation is won 15%
  of the time from 59% of the squad's hull, where the tier-one formations are won 87%) and a
  plateau after it while the enemy has no tiers: section 12's question, to read against the
  fresh start's compositions before any lever moves; area at half is the rule behind the
  cliff (the Balance bullet). Its elite slots hold the lead's formation alone until the elites
  land (the to-do; the bench hero that stood in went on 27 October, Ryan: "a can of worms");
  from tier two a domain's final may be a battle's boss (Ryan, 25 October), and every boss
  fight brings the tier's escort.
- Bosses scale to the battle's tier (Ryan, 25 and 26 October; the bible's section 9 row, section
  3's row carrying the exception): a domain's boss, a final's hero and the finale's line take
  the tier's HP and attack and bring more escort, drawn from the domain's units of the tier (a
  unit's `tier` in content, one by default: no unit has another yet), in the campaign and the
  quick campaign; the rank and file never scale in place, a tier's units being their own (the
  bible's section 3 row, 28 October). The campaign counts its tiers from the
  Convergence (tier two from 4, tier three from 8, the finale at 12 on tier three's step); every
  number a placeholder.
- Injuries (25 October): one damage state, Ryan's "Cracked is gone". An injury destroys the
  entry the die lands on, at a quarter of the maximum hull, the threshold set by what it asks of
  the player (half was tried and retired within the day: a machine could lose but one piece); a
  wreck loses only what was destroyed. The Honey Badger's "never destroyed" now holds off every
  injury until its identity session lands (Ryan: later; the to-do), so until then it is the one
  machine no blow can strip. The quick runs on the bot destroy about one to one and a half
  pieces a battle in tiers one and two (`docs/quick_run.md`), at or past section 10's "about one
  a won battle" line where the threshold moves, so the destroyed-is-gone threshold is the
  economy pass's first number to read.
- Content: five makers; 24 chassis, every one runnable but the Storm Petrel and the Giant Petrel
  (their passives and four locked pieces planned, so never dealt); 81 components,
  32 of them locked; 17 modules; four domains with 44 wildlife (18 at tier one, their bosses
  among them, and the ladder's 26 recolours) and 8 heroes with their promoted forms; 6 foe moves
  planned (two flees, an interpose, two retaliates and the Lich's Dark Rite). The
  numbers are the stock pass's (22 October, `tools/stock_fills.py`), the four Kestrel machines'
  set by hand at its scale; every one a placeholder.
- Models: every machine's by lowforge but five (the Cassowary, the Cottonmouth, the Whip
  Scorpion, the Swallowtail and the Musk Ox, which draw the Badger's); the Lammergeier's, the
  Skua's, the Puffin's and the Storm Petrel's are the Kestrel second round's picks of 28 October,
  to judge running; the Needletail's and the Giant Petrel's are the first cut of 23 October
  until Ryan's next session (the to-do). Since 25 October every machine's parts are welded at load by material
  within each moving group (`game/ui/mech_weld.gd`, the bible's battery row): a machine's draw
  calls about halve and nothing on screen changes (`docs/measurements.md`); `RIFTGATE_WELD=off`,
  or a debug build's WELD setting on the phone, draws every part as authored to compare, and a
  new model's part that moves, glows or hides on its own needs a joint, a pin or a name in
  `glow_parts`.
- Foe art: every foe and hero cut from Ryan's picks, and every subject of the boss art round
  cut ahead of its kit (`art/foes`, `tools/foeforge/picks/picks.json`), the last three from the
  picker's seventh round on 26 October: Surtr (his white-hot blade and blaze kept by the cut's
  new `--keep-glow`), Floraison and the Augur, who needs another pass "at some point" (Ryan:
  "she's still not correct"; the to-do). The cloud session that cut those three could not fetch
  Godot; their six `.import` files were written and committed on the desk machine the same day,
  the suite green there (644 tests).
- The ladder (28 October, `ccr-6073bda9-p34o8q`; its brief retired: `git show
  26c54c7:docs/briefs/foes_ladder.md`): the enemy's three verbs (Silence muting keywords, Purge
  taking what a die face bought and sleeping the machine's own grants until its turn, a foe's
  Cleanse), Primed, Barrier, Ward and Regenerating on the foes from specials of their own, the
  player's Purge (`dispel`) and its piece, the Null Field Emitter, and twenty-six recolours on
  the thirteen base types with the spawn lists by tier and their sprites (`tools/recolour.py`).
  Read at 30 seeds (`docs/measurements.md`, a direction): each tier's formation costs every
  squad more than the one under it; the tier-three rank and file read easier than tier one's in
  the Waste, the Marsh and the Peak, their lists sending them one or two at a time, random play
  winning 38 to 46% of them there; the Marsh's tier three walls even a four (its knights), and
  the Waste's and the Peak's ask a four nothing. Every number is Ryan's to move. Calls the build
  made where the brief was silent, his to confirm: a purge's sleeping buffs wake after the
  round's start and before the foes draw; a Shock is spent on the blow a foe's Barrier eats
  (his rule of 25 October), and a spill's or a mine's damage pops one; a cleanse's most-marked
  counts each status once; a buff with no component behind it counts as bought; Regenerating
  regrows on a suppressed foe; a laid shot carries the Purge; Primed wears its own glyph on both
  sides (the flame's core lit) and Regenerating a heart with a plus, so neither reads as Burning
  or Getting Back Up on a foe; the Null Field Emitter's shape a dish and its tag `arc` (the
  brief gave none and "Arc"); and a machine's incoming chips pulse as a foe's do. The six
  recolours' move counts are settled (Ryan, 28 October): tiers two and three carry up to
  three moves, the twist the third, and the Red Dragon dropped its Stoke.
- Balance, read by stage (Ryan, 23 October; `docs/measurements.md`): a starter trio's fights
  are the Peak's, the Marsh's and the Meadow's formations, the Magma Elemental and the Sandworm,
  the rest free and the finale a wall; an endgame four fitted to tier two finds every pack free
  but the finale; nothing sits between, so the middle of the curve is the foes' fresh start's.
  The coordination gap reads 1.0 to 1.3 on built teams against the tests' about 2, and the
  campaign's plain player wins none of 40 runs (both section 12's). The 39% of battles that
  player won after the playtest list's boss fight (26 October, the report main carried until
  the 27th) was a bot artefact: it opened the boss's fight from the gate on its first turn, which
  no order allows; with the order rule on it (`ccr-6073bda9-p34o8q`, 26 October) it won 15%. On
  the merged head (27 October, `docs/measurements.md`) it wins 7% of its battles and no final,
  the three-machine battles 36%, and one quick campaign run of 40 leaves its first battle
  (with the bench-hero stand-in out and the Skua's floor of one, 27 October: 10 fall at a
  formation, 7 at the formation in the elite's slot, 22 at the boss; the tier-one formations
  won 87%, the boss's fight with its formation 15% of 26, where the branch read 91 and 73):
  tier one reads harder than on any branch alone, and the rule is area at half, by experiment
  (`docs/measurements.md`, 27 October, the stand-in still in: with area at full the first
  battle is won 18%, the formations 94%, the elite 65%, the boss 80%; the re-pick put back
  changes nothing), since the Honey Badger and the Cottonmouth carried the starter trios on
  their area and the 26th's read saw them alone:
  section 12's quick campaign question carries the call. The 200-seed matrix on the merged head
  (`docs/balance.md`, 27 October; its read in `docs/measurements.md`) finds every move a rule of
  the week landing where it was meant to, and area at half landing harder than its read of the
  26th said: the Honey Badger's, the Wild Boar's and the Musk Ox's formation cells and the
  Cottonmouth's finals go back to the 22nd's bands with area whole, and nothing else moves them.
  The Marsh's list holds the Zombie Knight ×2 since 27 October where its second Revenant line
  stood (the audit's 37, an oversight from the domains' landing), so the matrix's Marsh formation
  (fifteen foes there, eleven now) and its missing Zombie Knight ×2 cell predate it.
  Read again on the team rows in three forms, half, half rounded up and whole (27 October,
  `docs/measurements.md`): the half walls no four, with area or without (greedy wins every
  formation at 100% for 3 to 14% hull in a single fight), and moves an area four's rounds, not
  its wins; a trio without area bleeds 30 to 96% of its hull on a formation under every form,
  so the quick campaign's cliff is the trio's chain against the fights' size, which whole area
  hides by tempo (28% of trios pass the first battle whole, 8% rounded up, 3% at half); at
  single digits a half-blow kills no rank and file; a fixed 2 on the neighbours reads as the
  half (the same day), since a number tells only at the swarm's kill threshold of 3. Ryan's
  call, 28 October: Spread N, Penetrate N and Splash N, with the blow's order read for each
  foe struck (the bible's rows), built the same day with each carrier's N a placeholder from
  Claude's proposals and the Kite's double kept on the printed number; read on the team rows the
  same day (`docs/measurements.md`): between the half and whole, nearer the half, the rows
  without area the same fight for fight, a neighbour's number telling at the rank and file's
  kill threshold of 3 (the Enfilade Beam's), the 2s softening. The quick campaign is an
  experiment, not a feature (Ryan, 28 October): its reads above are history, not grounds.
  The fights' size is the bigger lever (the same day): tier one's formations a third thinner
  take the quick campaign's first battle from 3% to 55% at half area, half thinner to 70%, and
  thinned formations are a trio's decision band in the matrix; the Zombie Knight pair's first
  read makes the Marsh formation an injury mill for a trio (its breaching 6 is a massive foe's
  blow on a rank-and-file body: Ryan's number to move). Three or four is section 12's question
  since the 27th (Ryan: revisit it).
  Gel x4 alone is a free pack for most of the roster since the Gel became a wall; its work is
  inside a formation. The set finals (26 October) turn every rift a domain
  leads final at once; the rally at once moves no cell of the packs that field it out of its
  band (`docs/measurements.md`, 30 seeds, a direction). Since 24 October a foe picks at random unless its threat calls for an aim, every
  rank and file today, the baseline the numbers are balanced on, and no foe over-commits: the
  formations read a few points easier for it, and their pressure is the balancing's to restore.
  The foes' heat doubled the same day as its first cut: the Peak's formation fell from 88% won
  to 69% for the starter trios, the cold ones paying a little to heat and the hottest walled on
  the greedy bot (Ryan's play judges it, the to-do).

## Decided, not built

The tasks are the to-do's; this is the index of what waits.

- The Giant Petrel's engine and the Storm Petrel's, the latter free since the pricing pass
  landed on 28 October with the guns' heat standing (their briefs).
- The elites on Ryan's definition of 23 and 24 October, a guaranteed miniboss event mid-battle
  (the bible's tiers row), with the bosses' slate
  (`docs/bosses_proposal.md`) and the promoted forms' one move more for seven of them
  (`docs/heroes_proposal.md`).
- The planned foe moves (the Lich's Dark Rite among them, a special with a countdown); a
  silence carrier and a purge carrier once Ryan marks them (section 12); the jellyfish's EMP,
  Purge on a capstone's blow (its chassis session).
- The Honey Badger's rework, once its numbers are settled (its brief).
- The six machines' models, the Armadillo's rebuilt with its seal, and the Translocator's mount.
- The commander layer, the screens, the economy's verbs and loot (sections 8 and 10).

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list). First: the 200-seed matrix with the ladder's cells on the desk machine (the
to-do's engine line), since the matrix on file (27 October) predates the ladder, area as
numbered keywords and the blow's order; the campaign report (29 October, the hunters at a ring
of two) and the map survey (29 October, the horde wading and the streets) are main's head's.

1. **The design sessions, from the briefs** (above): each decision a bible row, each brief
   retired once its decisions are rows and content.
2. **The stock pass's tail**: Ryan's name pass; the Lammergeier's stock; the pricing pass, landed
   28 October on Ryan's go ("I trust your leans for this pass"; the bible's pricing row, section
   11; the runs in `docs/measurements.md`, 27 and 28 October). The run of the 27th read every
   row winning its cells, tier one's two outlier guns above tier two's band, the Ram Frame the
   universal module on +24 hull, equipment and the setups priced not at all under the greedy,
   the Probe, the Condenser and the Ammit's loop verdicts on the bot; reviewed on the 28th
   against the numbered area, the blow's order and the ladder's design goals; reframed on
   Ryan's words of the 28th (the effectiveness row: a piece priced by its effectiveness in
   vanilla points, a vanilla at each tier the baseline, heat priced up from the heatless
   vanilla, a rolled gun its mean). The vanilla ladder read a point a third of a round up to
   6 and a seventh past it on the car, the hot bench reading keywords and no number, heat 1, 2
   and 4 free on a cold die and 6 and 8 a point and two, a hot die paying in hull, a rolled gun
   a third of a point under its mean, and the keywords' prices (Flak 2 two, Burn 2 two and a
   third, the Chain nearly three, the Shock one and a half). Landed on his go: the floors 2, 3.5, 5 and 7;
   the Railgun 10 to 8, the Coriolis 3 to 4, tier one's rolled vanillas to 2-6, the Howitzer
   Splash 1, the Ram Frame and the Rangefinder hull +8 (the Clydesdale bench: the Frame 0.4 rounds off its
   row, the Rangefinder 0.1, its back-rank rule reading on the one back-rank foe type a tier-one
   formation fields, tier three's fielding three; a nine-entry die dilutes its slot three to
   one and never reaches its heat knee); every landed delta read again at 200 seeds (the Railgun
   at 8 1.5 rounds off the car's row against 2.0 at 10, under the Knuckles and the Meteor and
   above the Thermal Ray; the Coriolis at 4 at tier two's floor; the rolled guns at 2-6 the
   half point meant; the Howitzer with Splash 1 a tier-one shell at tier two's kill time; the
   Frame at +8 a third of a round, the Rangefinder its hull on tier one's formations; the
   ladder's tier-two and tier-three formations are walls for the stock trios, Wainwright &
   Sutler's row winning 29% of them, so the Rangefinder's rule is the per-tier ladders' read
   with a tier-matched kit). Chain decided the same evening (the conductor, the bible's Chain
   row) and built on the 29th from its brief (retired); read the same day, it is a plain 4 on
   today's kits (another machine's doubled blow spends nearly every charge before the arc
   fires), about 0.7 vanilla points with a spread setter under the planner, and Kestrel's row,
   with no Shock setter, lost the kill and repeat's pace. Ryan's six looks at Chain's form read
   the same day as what-ifs (`docs/measurements.md`, the Chain looks): how a charge is spent
   barely matters, self-fuelling is what moves it, Shock clarified costs nothing, and a Shock
   setter on the Buzzard takes nothing over. Ryan picked the form the same evening (the arcs
   plain, Shock read only by a weapon's strike aimed at its foe, a charge on one other foe at
   random), built at once and read (`docs/measurements.md`): about 0.8 vanilla points over the
   sixteen big fights, nothing against a lone massive foe and about 2 on the formations, the
   charge carrying it (the team cashes each one, so nothing compounds); a point of Chain N on
   the Arc Fault adds about a tenth of a point, so it keeps its Chain 2. Ryan affirmed the
   random charge the same evening (lightning, free reach, it sets itself up) and kept the
   Buzzard's stock.
   Heat opened the same evening (Ryan: a core pillar, undervalued): the heat knee by the
   maximum measured as a what-if, his frame recorded (the triangle row of section 2: every
   component priced in heat, hull or shield, the basics too; passive cooling the lever that
   makes the player meet the system; vent payoffs), Claude's bench in section 12's heat
   question, the heat session on the to-do with its brief (`docs/briefs/heat_pillar.md`), waiting
   on Ryan's answers to its six questions. Next: a persona that
   shields and vents before the overheat and the planner on the equipment ladders, for the
   equipment ramp Ryan wants first; the ladders per tier on the fresh start's formations once
   the ladder lands; the synergy holes as pieces proposed in chat (the to-do's design-sessions
   line); the catalogue's tag pairs. The synergy map is `docs/synergy_map.md`, generated.
3. **The foes' fresh start, the fight-size spectrum and the Rupture meter.** Reads section 4's
   pacing and four-machines rows, section 9, section 12's foe questions,
   `docs/campaign_run.md` and `docs/curve_proposal.md` (the tier a rift's foes, elites and
   Fractures follow, once Ryan picks its form). Builds compositions with a front and a back
   spawned by the rift, small packs for detachments and formations for the body, the boss sealed by the
   threat-weighted meter and fought with its formation, the withdrawing persona on the campaign
   bot, the curve by stage (section 3's curve row) and the elites on Ryan's definition (section
   9's tiers row), read against the starter and endgame grids of 23 October; then reruns both
   reports and measures the fights a team fights together. Its first part, the ladder, built
   28 October on `ccr-6073bda9-p34o8q` (the recolours by tier, the three verbs, the enemy's
   buffs and the player's Purge; read at 30 seeds, `docs/measurements.md`): next its 200-seed
   matrix on the desk machine (the to-do). The rest of the fresh start waits on his marks on the proposal's questions
   1 to 13.
4. **Balancing for real** (Ryan, 14 October: only once the go is hashed out and the stock pass
   is in can the units be balanced for real; 24 October: it "probably needs foes with proper
   formations", so it follows the fresh start): the runner's rows on the roster as it stands,
   the fours again, prices and tier ladders (the to-do's engine line), the heat report, and
   Ryan's play deciding feel.
5. **The screens** (Ryan, 13 October: early, so the first thing built after the battle has its
   shape is a run he can play; the go, the stock pass and the balancing come first, Ryan, 14
   October): a prototype hangar, the mission map and the draft.
6. **The economy pass** (`docs/economy_pass.md`): the runner's spending policy, then every price
   and yield with the offers one of each kind, a chassis on the shelf, the Favour dock as the
   gate's price, twelve to sixteen battles.
7. The rest in the standing order: Ryan's text; the domains' last engine (the planned moves;
   the bosses' slate as content alone); the pacing session's remaining pieces; the battery plan's rest (the props' fade, the 3D at 30); audio;
   art; the commander layer after a balance baseline; onboarding before a phone leaves the desk.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them by
URL (read first). Databases are reachable only from the personal account. A page's link goes
into this file in the same commit as its first publish; the procedures are in `README.md`.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. This file is v0.381 (the page's version 393,
  published 30 October from main with `ccr-c04908be-3r43xf` merged: the pricing pass's
  effectiveness and pricing rows, the heat triangle, the maker leans, Chain's row and the rows
  Shock's reading touched, three-way merged onto the live v0.380, which other sessions moved
  past main's v0.376 with the foes' fresh start built with the pacing session (the packs as
  compositions, the tier locked and the ramp, the tears, the stall's prices, the whole wall
  struck, the elites at the Fractures, the seal), the music's rounds and the phone's line
  widths; on v0.376 at 388, from `ccr-7821127e-kwj874`: a tone a ground, on v0.375 at 387, the
  tilesets' second build, three-way merged onto the live v0.374 that `claude/charming-rubin-h954bp` published with its flush radiators,
  which carries `claude/jolly-lovelace-scn82y`'s v0.373, the map's lines one width at every zoom;
  on v0.372 at 384, the first build onto that branch's v0.371, the colour rows' pure red on
  trial and the rule that a colour is scored against the ground it is drawn on, and the FXAA of
  the map's own; on v0.365 at 377, Ryan's calls that a domain names no map shape, height is a
  look alone and a
  skirmish never reads our own ground). So this file carries
  those branches' rows ahead of their code (the models' glows, looks and acts, the Armadillo's
  seal on screen, the skirmish's field, the reds, the tracks in pairs, the map's FXAA and its
  lines at every zoom, the fresh start's and the pacing's rows) and the Strikes row in
  the keyword table, and the tables script,
  which writes the tables from main's content, waits until they land or it reverts that row. The
  version numbers on the publishing branch's file and the live agree after every publish.
  Before republishing, read the live page; if another session moved it, publish a three-way
  merge onto it (`git merge-file` with the last-published file as the base, the wrapper's
  first line and its trailing `</body></html>` stripped from the saved live source). With
  every branch landed, the file holds no rows ahead of code, and the tables script may run
  freely again.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each checked identical to the last publish's
  before it is replaced and `edits` read first. Every file the page reads is fetched with a
  stamp on the URL past any cache between (28 October, after Ryan saw an older round's Skua
  acts on a reloaded page). At the page's version 160 (30 October, from `ccr-7821127e-kwj874`:
  `content/factions.json`'s note naming the bleeds as the tilesets, onto version 159, its
  `index.html` and every other file kept as they stood, `edits` empty; 154 took the domains' map
  shapes out), on 153 (29 October:
  `content/foes.json` with the hunters at a ring of two and its map note current, replacing
  that branch's copy, whose note alone differed, and `content/vocabulary.json` with the Ring
  and Behaviour entries, onto version 152 of `claude/charming-rubin-h954bp`, its rebuilds'
  notes, its `index.html` and every other file kept as they stood, `edits` empty; 151 brought
  the horde's wade and the flyer's passing;
  at 147 the walls' four terms, onto version 146 of `claude/charming-rubin-h954bp`'s page and files; that branch's
  `content/chassis.json` carries its own Stingray note, so main's chassis file, whose `_about`
  alone moved, waits for that branch to land; `edits` empty). Its database (Ryan's saved edits,
  collection `edits`; name candidates, `candidates`) opens only from the personal account.
- The roster analysis: https://claude.ai/artifact/QVLRVD8YXsK8ZUKY3A1vxo, rendered from
  `docs/roster_analysis.md` by `tools/pages/roster_analysis_page.py`; background since the go,
  republished after the page changes and retired with it once the last brief that cites it
  lands.
- The foe picker: https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei (shared to the work account
  as Editor); picks and notes in collection `picks`, readable from a personal-account session.
  It holds the boss art round's seventh sets (19 October), all picked on 26 October and cut:
  Surtr's blade on the grip's line, Floraison's eyes painted out, and the Augur's new base with
  the smoke gone and the top blade flipped inward. Of the rounds' folders under
  `tools/foeforge/out/`, only the Augur's last two stay, with the seventh round's job lists (each
  set's `set_aside/` holds the renders that lost a blade or a brief); the README has the
  command that builds her sets as a page, and the fix order that worked is the bible's art row.
- The Melody Desk: https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV (`tools/soundforge/melody_desk.html`;
  collections `parts`, re-seeded by `desk_parts.py`, and `melodies`).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).

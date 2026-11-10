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
  there. Since 29 October it draws with the phone's renderer (gl_compatibility, the project's
  setting; Ryan's go), so a lit part's colour there is the phone's. What the Mac held outside git is gone. Of the seventh round's foeforge renders
  (force-added in `fb45141`, its picks cut on 26 October), only the Augur's stay in git, her
  only surviving renders, kept for her next pass (the rest: `git show fb45141`); foeforge's
  `generate` and `fix` have no machine until a route for the image model is chosen.
- Godot: the project runs 4.8-beta2 (published 29 October), the newest build at the last
  check, 30 October; 4.8 stable is not out. The next check is due 13 November (`CLAUDE.md`,
  Session handoff); date this line again after each.
- Tests: 959 tests, 256,122 checks, green (4 November, on main's head as `claude/elites-session`
  landed: the elites session's twenty-one kits, the Nob's rage, the wanderers' random draw, the
  Mantis Ant, the Marsh Serpent and the Emperor Scorpion, the golden rage and the crush, the
  Astromancer and its orbs, over main's 952 and 255,358 of the same day, `claude/charming-rubin-h954bp`'s
  weapon-fire, slump and micro-model work over `ccr-c04908be-3r43xf`'s randomness pass (921 and
  254,079) and the chassis runner rows (917 and 254,298; 911 and 254,286 on 3 November after the
  pairs), on Godot 4.8-beta2), about four minutes in a cloud session, twenty on a slow one. A cloud
  session gets Godot 4.8-beta2's Linux build and
  the project's first import from the repository's session-start hook
  (`.claude/hooks/session-start.sh`, registered in `.claude/settings.json`, 27 October; the
  GitHub release asset `godotengine/godot-builds`, `Godot_v4.8-beta2_linux.x86_64.zip`, into
  `~/bin`; a session without the hook fetches it by hand, the download in a command of its own and
  the unpacking and first run in another, since Auto mode refuses one line that fetches and runs
  it), uses `xvfb-run` for screenshots (with
  `--rendering-method gl_compatibility`, Mesa's llvmpipe on the CPU: its draw calls are true
  counts, its frame times mean nothing), and builds models with `BPY_PYTHON` set to a python3.11 venv holding
  `bpy==5.0.1` (the wheel takes about twenty minutes to install). Its first `--import` rewrites
  four Prairie Dog textures and a model build the maker's review tiles: restore both
  (`git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`) rather than commit them.

## Branches

`claude/elites-session` (3 and 4 November) carried the elites session from main's `e75be15` on
Ryan's marks of the 3rd and his calls and reads of the 4th (How things stand; the bible's
register row and tiers row): the demotions, the Fiend of Fire, twenty-one elite kits with
six wanderers, the Nob's rage, the golden rage and the crush, the Mantis Ant, the Marsh Serpent
and the Emperor Scorpion, the Astromancer, the wanderers' random draw, the placeholders' art, the
hangar's foe sprites and filters, the runner's elite cells with their first read and the what-if
at 40 HP, the records, the pages republished. It took main as it landed (to `a3ef10d`: the Honey
Badger's hopper, the five Wainwright & Sutler models, the pairs, `claude/chassis-runner-rows`'s
cycle bot, Rapid fix and runner rows, `ccr-c04908be-3r43xf`'s randomness pass, under which the
Nob's rage and the golden rage are buffs a Purge N lowers, and `claude/charming-rubin-h954bp`'s
weapon-fire, slump and micro-model work), and main took it as a
fast-forward on 4 November on his word ("If there's nothing else open, clean up and merge into
main"); its bible is v0.446 (the page's version 459; the Pages paragraph).

`claude/charming-rubin-h954bp` (28 October to 4 November) carried the model rebuilds of Ryan's
brief of the 28th (the pins' record and the game's plan against it, thirteen models rebuilt to
their stock, the Armadillo's seal) and his rounds of notes on them, and main took it twice on 30
October (his word, "Merge into main", and again as the lit parts' eased light landed). Since then
it carried the halos (a soft shell round every hot part: the boosters and vents, then the parts he
vetted), the burn weapons' fire on their silhouette classes, the weapon-fire package (the weapon
that fired the only one that moves, its muzzle flares in its tags' look, the cheap aim, the fixed
weapons' slices of their acts and the business ends their models mark), the swaps (a hardpoint's
variant and scale per class, the round launcher, `tools/fit_sheet.gd`), a blow moving the machine
and a lost machine's slump on its feet, the boosters by maker (Aphelion's plumes, Kestrel's
halos), his two rounds of notes of 3 November, and the micro-models on his go of 4 November (a
launch's flight shapes and landing, the world's once it leaves; the Swallowtail's flares, the Musk
Ox's rockets, shell and casing; `tools/act_shot.gd`'s `fire:`). It took main as it landed (to
`6c97852`: `claude/chassis-runner-rows`, `ccr-7effd31a-u5z4gw`'s pairs and `ccr-c04908be-3r43xf`'s
randomness pass), and main took it as a
fast-forward on 4 November on his word ("Ok might as well clean up and merge into main now, I'll
look at these issues after"); its bible was v0.442 (the page's version 455), inside main's v0.445 (the Pages paragraph), and the
hangar's version 201. What it leaves is his: the to-do's judge lines (the glows, the weapons firing, the swaps, the
hit and fire round, both rounds of notes of 3 November, the micro-models and the calls on that
line) and section 12's render margin.

`ccr-c04908be-3r43xf` (2 to 4 November) carried the randomness pass on Ryan's calls in chat (the
review's fixes of the 2nd; rolled damage gone, the injury on the entry showing and the withdrawal's
screen code deleted; Overcharged and Kindled named Empowered; Numbed on his clock, Purge N on both
sides and the Ward; Charged and Supercooled with Chain the arcs alone; Sweep, a reach by the day's
end; UNDO to the last roll with its HUD; every rider after the hits as one path and on the foe a
strike fells, death the last check in a spend and in the prediction; the stun resist by kind; the
open items logged), from main's `3929042`; it took main as it landed (the Badger's rework, the
bosses' slate, the elites, the pairs and the motion, to `d03ebed`, 4 November: the old Numbed's
helper and the views' range check cut, a boss unit's commander resisting as a boss, the Badger's
purge test turned to Purge N and its range assert to one number; then the chassis runner rows, to
`9a529ca`, the same evening: the bot's Sweep share beside its salvo reserve), and main took it as a
fast-forward on 4 November on his word ("clean up and merge into main"); its bible is v0.445 (the
Pages paragraph).

`claude/chassis-runner-rows` (3 and 4 November) carried the chassis to-dos on Ryan's word
("spawn a new session to continue the chassis to-dos"), from main's `62ef7ee`: the Cassowary's
cycle bot, the Musk Ox's salvo priced against a reserve, a Rapid entry's action again (4
November, his word: "If the bot doesn't value rapid property, it probably should be fixed"), the
runner's tallies and `--pilot`, and the runner rows of the Cassowary, the Cottonmouth, the Whip
Scorpion, the Swallowtail, the Musk Ox and the Needletail (How things stand), with the gunship's
first round in its brief. It took main as it landed (to `d03ebed`: `ccr-7effd31a-u5z4gw`'s track
pairs), and main took it as a fast-forward on 4 November on his word ("Ok, if there's nothing else
open, clean up and merge into main"); its bible is v0.438 (the page's version 451).

`ccr-7effd31a-u5z4gw` (28 October to 4 November) carried the pairs. Restarted from main's
head on 28 October (its first round, the Hold The Line pair, merged on the 27th), it carried
Ryan's go on them (every track a map half and a battle half, the bible's pair row), every new
half sketched on its shipped recipe's groove call and published on the pair page, then his notes
of 29 October to 3 November on Hold The Line's two halves, Night Shift's battle half and The Far
Bank's map half as further rounds on the same page (Hold The Line's thirteenth, which settled
it; Night Shift's tenth; The Far Bank's map half's fourth). It took main on the 29th and again
as it landed (to `62ef7ee`: the foes' fresh start and the pacing session, the bosses' slate and
the elites by the tier, the Petrels' engines, the skirmish's field, Godot 4.8-beta2, the model
rebuilds and the five Wainwright & Sutler models), and main took it as a fast-forward on
3 November on his word ("Good place to merge into main, I think, before we continue with
finalizing the other tracks"); its bible was v0.437 then (the page's version 450). It goes on
from main's head (`d03ebed`, the suite green there) with the other tracks' rounds: Night Shift's
eleventh, the bass clean (3 November), its twelfth, the guitar's walk on one string, and its
thirteenth, the guitar out, a bass jam, with The Far Bank's map half's fifth, the choir in the
intro alone, its fourteenth, the rhythm guitar back in the breakdown, D without the bass, R at
one level, the plucked string down, on the synth bass, and real basses for both tracks
(`real_bass.py`), then its fifteenth, on his pick of them, with its drive to try, and The Far
Bank's map half's sixth, its cellos and contrabass on true bass instruments, then Night Shift's
sixteenth, on the modern prog bass with the bass on the lead's lines, and the Omnific bass in Hold
The Line (4 November); it took main again as it landed that day (to `d28308e`: the elites
session, the randomness pass, the chassis runner rows and `claude/charming-rubin-h954bp`'s weapon
fire, slumps and micro models).

`claude/affectionate-ramanujan-5d24t6` (30 October to 3 November) carried the two Petrels'
engines on Ryan's go ("go for the ready to build ones", after his question of the 30th on which
chassis come next), from main's `d84ad16`, and main took it as a fast-forward on 31 October on
his word ("merge this into main"). It then carried his calls of the 31st (Onryō's Grudge a
working term; the Storm Petrel's burn on basics struck), the Giant Petrel's looks as a military
catamaran, the Honey Badger's hopper rework with his second fallback on the runner's read, and
the five Wainwright & Sutler models through his notes of 2 and 3 November; it took main as it
landed (to `e75be15`: the slate's last calls, the elites by the tier, the review's calls), and
main took it as a fast-forward on 3 November on his word ("merge this to main and clean up, I'll
resume chassis work later"); its bible is v0.430 (the Pages paragraph).

`claude/zealous-wright-ixxo3l` (30 October) carried the foes' move-order fix and its boss
cells' read (How things stand), took main as it landed (to `d84ad16`: the skirmish's field,
Godot 4.8-beta2, the enemy in violet, the backdrops on the map's palettes, the lit parts' eased
light), and main took it as a fast-forward on 30 October on Ryan's word ("merge into main
please").

`claude/jolly-lovelace-scn82y` (29 and 30 October) carried `claude/brave-cori-fr18de`'s bosses'
slate from 30 October (merged for its terms, so main took the two together), and the skirmish's field with the
Skirmish Controls setting, the map's lines and overlay at one size on screen, Godot 4.8-beta2
with AA MODE, the enemy in the rift's violet with heat reddened and harm a red-red, the fight's
backdrop on the map's palettes, the minty GREEN and the COLOURS page cut to what is in play; it
took main twice on 30 October (the tilesets, the pacing session and the foes' fresh start; then
`claude/charming-rubin-h954bp`'s model rebuilds as they landed, the fitted die worn on the pins
inside the map compositor's outline), and main took it on 30 October on Ryan's word ("merge
this into main"), then again that evening as a fast-forward ("Do those, then clean up and push to
main") with what it carried since: the codex's passive line in ink; the keywords in their colour
with their icons, a tap opening each; main's six commits after it landed merged in; the slate,
merged in for its terms, with the foe moves' keywords in the list; and the dice's gestures (a tap
reads a die once the double-tap window passes, a double-tap or a hold locks it, a tap on the
ground sends a waiting Swap home), KEYWORDS gone from the field to the menu. Its bible is v0.408
(the page's 420).

`claude/brave-cori-fr18de` (30 October) carried the pacing session and the foes' fresh start
(the brief, the engine in three commits to `85e28fd`, then the records), took main three times
(the tilesets' second build before its records pass; the pricing pass, Chain and the cautious
heat persona after them, on Ryan's word to bring the repricing in; the tilesets' walls and the
heat grid's read as it landed), and main took it as a fast-forward on 30 October on his word
("merge this into main"). It then carried the bosses' slate on his word the same evening, the
first seven ("build what can be built, and specify exactly what you need to flesh the rest out,
including any holes") and the last five ("Yes to all waiting bosses"), then the review's calls
of 2 November and the slate's last calls that evening; main took it all on 2 November (Ryan:
"merge into main"), with the elites session next in a session of its own
(`docs/briefs/elites.md`). Its bible is v0.427 (the page's version 439) and its hangar the
page's version 190. `claude/jolly-lovelace-scn82y` had merged its first seven on 30 October for
its terms (Ryan: "Fix the missing ones now, that's this sessions job, the other one doesn't have
your context"), and main took the two together that evening.

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
`git show 85e28fd:docs/foes_proposal.md`; the campaign bot moving as one with its withdrawing persona; `--pack` on
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

- Kestrel: ten machines, eight decided, in content and fielded since the Storm Petrel's and the
  Giant Petrel's engines (30 October, the How things stand bullet; the bible's Kestrel row; the hub
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
  alone, its way through plate a flat buff on each strike (`docs/measurements.md`); the last two, the Magpie (a working name, a support engine)
  and the Snowy Owl (a stealth unit), are Ryan's next session, his directions and Claude's first
  round in each unanswered.
- Wainwright & Sutler: ten decided, 3-5-2, nine built (the bible's roster row). The Musk Ox, the
  Whip Scorpion (a rework coming) and the Swallowtail are not finalized, and with the gunship (very
  rough, maybe back to the drawing board; Claude's first round of 3 November in its brief) each
  needs a design session for its kit and its visual design, which Ryan starts himself (4 November;
  the Needletail likewise, Kestrel's).
- Minerva: the Honey Badger's rework built 31 October (the Ore Hopper and the Reinforced
  Skeleton module; its brief retired), the echidna left open, the siege battery parked on Ryan's charge brief, the battlecruiser never
  with the Carrier's session (Ryan, 20 October).
- Aphelion: the line frame and the Baboon first (the pair that keeps its tier-one deal varied),
  then the jellyfish; the Carrier on its own; a defensive tier one unproposed (the to-do).
- The Arsenal: Misharu, the Onryō, Mastema and Minos, Claude's first round and review in their
  briefs, unanswered: Misharu's two calls first (Penance's shape, how often it may fire), then
  the Onryō's kind and trigger.

## How things stand

- The elites session (3 November, `claude/elites-session`, on Ryan's marks; the bible's register
  row and tiers row, section 9; `docs/bosses_proposal.md`'s elites table; its brief retired,
  `git show e75be15:docs/briefs/elites.md`). The register: a boss is a named JRPG entity; an
  elite is the domain's own grown or a homage from anywhere, made retro; what misses the cut may
  be rank and file. Landed: Rotbloom to the Meadow's ranks (a massive at tiers two and three),
  the Pilgrim to the Waste's elites as its hunter and the Cinder Tortoise to the Peak's, the
  Behemoth renamed the Gargantuan King (the King Behemoth by archetype; the name from Ryan's
  "<adjective> King" pattern, his to settle), the Fiend of Fire (Marilith) the Peak's third boss,
  the Goblin Shaman pushed into Warcraft's Thrall on his wolf; new placed elites the Goblin Nob
  (the Spire's), the Rust Monster (D&D's), the Skeleton King (Diablo's), the Fell Rider
  (Tolkien's Nazgûl on the fell beast), the Collector (Darkest Dungeon's), the Thunder Ape
  (Monster Hunter's Rajang), the Bane (Tolkien's Balrog), the Firelord (Warcraft's Ragnaros);
  the wanderers five, the Reaper (Persona) and the Wild Hunt (three riders, swarm) and the
  Ravener (Deviljho) and the Shambler beside Gilgamesh (Enkidu at tier three), drawn at random
  among those not yet sent on the Fracture's roll. Engine: Enraged, the Nob's rage (a stack on
  every shield, vent or equipment spend, a point of attack each for the fight; fed before the
  entry acts so a Purge lowers it by its number; the chip, the bot's cost, the save) and the opener (`opens`).
  Every elite drawn as a rough placeholder; the Matador stays a boss on Claude's call. Open for
  Ryan: the Meadow's and the Waste's third boss, the Fell Rider's mount, the rage's shape, the
  Monster Hunter nods, the names (the to-do).
  His calls of 4 November, landed: the rage permanent; the Fell Rider on the fell beast at
  every tier ("Flying is the map identity"; no horse, no Witch-king); the Collector renamed the
  Antiquarian and the Shambler the Shuffler (his names), the Ravener the World Eater (one of
  Deviljho's in-world epithets, from his list); the Mantis Ant (Secret of Mana) the Meadow's
  third boss and the Marsh Serpent (Final Fantasy VII's Midgar Zolom) the Marsh's fourth, each
  a placeholder kit with escorts and rough art; the Waste's third still his pick (Claude's lean
  Golden Sun's King Scorpion, the proposal's calls). The hangar page shows every foe's combat
  sprite in its Foes list, a grid to compare them, and filters by tier, kind (rank and file,
  elite, wanderer, boss, hero, part) and art (picked, its hero's, placeholder, none).
  His reads of the 4th, built the same day: the Thunder Ape's Golden Rage a mode (Golden, the
  session's third mechanism: its blows harder under a point of plate for three rounds, a
  quarter of its HP lost since or a stun breaking it and the stagger its next action lost, a
  Purge stripping it, gold again only once calm; Rampage the multi-punch; the spin and the
  dive on the bench), the World Eater's pin laying Crushed (Defense Down: a point more on
  every blow the machine takes a stack through the next round, Flak's shape on the other
  body, cleansable), the Emperor Scorpion (Golden Sun's King Scorpion) the Waste's third boss
  on his word, so every domain holds three; the foes without art drawn as placeholders (the
  first elites, the Scorpion) and the hangar's promoted forms wearing their heroes' sprites,
  so no foe lacks art. Later that evening, on his go ("feel free to throw it in"): the Astromancer,
  Golden Sun's Star Magician, a sixth wanderer at tiers two and three, the kill-order elite
  behind its orbs (the Warding Orb a part, the first on an elite; the Mending, Storm and Fuming
  Orbs its members and summons); and the runner's elite cells (`--packs elites`, every
  composition at each tier it names) with their first read at 30 seeds, a direction
  (`docs/measurements.md`): every cell a free win for the endgame fours and the lone elites for
  the stock trios too, dying in two rounds before their mechanisms matter; and the what-if at
  40 HP, which read HP alone as rounds, not threat (a trio's fight grown from two rounds to
  four, still a free win), so the lever on the table is the massive band in both numbers, an
  escort each, or the curveball on the map. Open for Ryan: the elites' numbers, the Dullahan as
  the superboss, the Scorpion's name (the to-do, section 12).
- The randomness pass, under way (2 and 3 November; Ryan's calls in chat, the bible's section 2
  randomness row and section 5's weapons row): rolled damage is gone, every weapon one number (each
  range landed at its mean, the halves rounded up on his word of the 3rd, to be read again at 200 seeds; the Muzzle Velocity
  Booster and the Tactical Databank planned until they have rules; a blow's sound by its tags, since
  rolled-or-flat was its label); an injury breaks the entry the die shows, so what faces the enemy
  is the player's choice and the threshold can come down once played; the withdrawal's screen code
  deleted (a defunct passive); the round preview exact on all three. Built 3 November: Numbed on Ryan's
  clock (the stacks are the rounds until one stun lands; a stun on a Numbed foe strips a stack and
  lands nothing; a stunned foe recovers with its stun resist, content's `resist`, by its kind when
  content says none: 1, a massive foe 2, an elite or a boss 3 (Ryan's defaults of 3 November), after
  the round's decay; Numbed a buff a Purge lowers), Purge N on both sides
  (N stacks off every buff, the Null Field Emitter at Purge 2, the bot pricing each at the stacks it
  reaches), a Ward turning a stun and a Purge and standing on either side; the preview exact on a
  stun. Built the same day: Charged and
  Supercooled, the primers (a stack a weapon fired, the Shock or the Cryo 1 on the foe the first
  strike was aimed at after the blows; no piece grants them yet), with Chain the arcs alone, its
  random charge retired. Sweep built the same day and made a reach, the third targeting mode, on
  his word of the 3rd ("You pick a rank and that's the rank it hits"): the entry is dropped on any
  foe and its strikes walk that foe's rank from its first filled slot, left to right, one a slot,
  wrapping, empties skipped; the Flechette Pod and the Musk Ox's salvo carry it; the spray and the
  random targets gone; the die shows the reach's own mark (`sweep`, `debuff_sweep`).
  UNDO built the same day, the pass's last piece (the fight keeps a snapshot before each spend and reroll of
  the player's turn, the save's own dictionaries written back in place; a draw is the floor: the
  round's roll, a reroll, Rapid's reroll, a roll again, the Scorpion's blast; a stepping die's step
  is taken back; the button at the reroll row's right end, its badge the spends it reaches, a bar in
  the trail at every roll). Riders land after the hits since the 3rd (Ryan: "a multi-hit weapon
  with Shock would apply it after both hits ... Cryo should work the same way, resulting in 2
  applications"; the bible's row beside the blow's order): every rider gathers on its strike's foe
  and lands once the strikes are done, one path ("It should be standard, not branching code"), on
  the foe its strike killed too, and death is the last thing checked in a spend and in the
  prediction since his word of the 3rd (the bible's death-last row: every effect of a spend lands
  on the fallen, a Shock, an Expose and a Lure's turn included, and the dead are cleared after the
  spend), so the preview shows every chip beside the skull and no trigger goes unfired; the
  enemy's turn stays sequenced as it happens on his correction of the 4th (a foe its tick kills
  never strikes, its intent still shown; whether ticks come before or after a foe's action is
  section 12's question); a spend never
  cashes or feeds on what it lays (Flak's self-feed on a later strike went with it: "5,5,5 makes
  way more sense to me"); Charged and Supercooled ride the weapon fired as its keywords, Shock and
  Cryo one more a strike, shown on the die. A sweep dragged over a foe lights and brackets that
  foe's rank whole, and a rank emptied loses the strikes left on his word. Overcharged and Kindled are
  Empowered on both sides since 3 November, the ids kept. What is left of the pass is Ryan's: the
  Scorpion's rework (tabled; its blast is the one draw besides the die), rules for the two planned
  modules and the Emitter's Purge 2 (the to-do), then the 200-seed reread of the flattened numbers
  on the desk machine, with the injury threshold's what-if (the to-do's engine line).
- The chassis' runner rows (3 November, the to-do's engine lines; `docs/measurements.md`, two
  entries). The Cassowary's bot plans its cycle (`Policy.cycle_plan`: the steps a round's rerolls
  take weighed with the chamber the dial then opens the next round on, a spin at the die's spun
  mean), where it had turned the dial only toward a better next chamber; read at 200 seeds, alone it
  carries a decision under the Cottonmouth, the stronger tier-one gun alone, neither a wall nor a
  free win, and the Spin-Up is its most spent entry (36% alone), the chase it was meant to be (Ryan,
  4 November: "that was the chase, yes"; his to judge in play). The Musk Ox's salvo had been priced against the whole magazine, so the bot rerolled it away
  and random play matched greedy alone: it now counts a reserve, the ammo its dearest other gun's
  next spend needs. The rest read at 30 seeds (directions) beside a band of every tier two and three
  alone on today's packs: the Whip Scorpion reaches none of its three exits and its pilot light is no
  lever (heat is not its limit); the Swallowtail lifts the Clydesdale and the Dingo seventeen points
  and its Phased is the rarest charge bought; the Musk Ox's strike number and trickle are its levers,
  the team's Flak worth a point or two; the Needletail's gate frees about four in five of its setups
  and an ally cashes two paints in three; those four are not finalized, and their performance is not
  Ryan's concern until their design sessions (4 November; the design sessions' Wainwright & Sutler
  line). Found on the way and fixed on Ryan's word (4 November: "If the bot doesn't value rapid
  property, it probably should be fixed"): the bot valued a plain Rapid entry at what it did once,
  never its action again; it now adds the die's own average blow (`Policy.rapid_worth`, as the rage,
  the reset gun, the gate and the Horn were valued), for the Laminar Deflector, the Pulse Vacillator,
  the Cryo Flinger, the Musk Ox's Quick Reload and the Immelmann Booster's own action; read at 30
  seeds on their three carriers (`docs/measurements.md`, 4 November), the pieces are picked more
  (the Cryo Flinger 9 to 13% of the Armadillo's spends, the Quick Reload 11 to 17%, the Booster from
  under 2% to 14% alone) and the win rows move a point or two, random play identical. New in
  the runner: a muster's charged spend tallied apart by piece, the gate's free spends and the paints
  cashed, each cell's squared hull lost for its spread, and `--pilot chassis=N` (a what-if heat a
  round, `Skirmish.pilot`, never content).
- The Honey Badger's rework built (31 October, Ryan: "agreed on all proposed. Build it"; its
  brief retired). Its passive, the Ore Hopper, puts a load in for each foe a spend of its weapons
  damages, four at most, boxes under the heat; every two loads held are a point of armour, the
  Ore Plate, the first buff a store grants, which a purge sleeps while the loads stay; base
  armour 1, so 1 empty and 3 full. The Chainsaw Claw is flat 3 twice with no area and digs two loads a foe;
  the Bullion Fragmenter fires two at +2, the plate they stood for spent with them; "never
  destroyed" is the Reinforced Skeleton, a Minerva module at tier two with +8 hull. The bot prices
  the plate a shot spends and the plate a spend digs (`Policy.hopper_score`). Read at 30 seeds
  the same day (`docs/measurements.md`): a point a load (1 to 5) read eighteen points over the old
  Badger alone, the plate carrying it, so Ryan's second fallback landed as his sequence said (his
  first moved it two points); at 38 / 60 it reads a few points over the old Badger, and its shield
  stays 8 (at 6 within a point or two). Still his eye: random play takes three lone big foes more
  often than not, where the old Badger lost them. Ore Hopper
  and Ore Plate are working names.
- The bosses' slate, all twelve (30 October to 2 November, on Ryan's word, his yes, his
  agreement with Claude's leans and his calls on the review of the 2nd; `docs/bosses_proposal.md`,
  its sections on what landed and the calls still open; the bible's section 9 rows), three a
  domain as runnable placeholder kits: Rotbloom, Floraison and the King Gel in the Meadow; the
  Ruby Colossus (Ruby Weapon by archetype, in the Djinn's place since the 2nd: two tentacles as
  parts that guard nothing, Whirlsand a swallow, Ultima at every machine three rounds on), the
  Fallen Weapon and the Pilgrim in the Waste; the Matador, the Phantom Train and the Vampire
  Lord in the Marsh; the Behemoth, the Cinder Tortoise and the Obsidian Tyrant (its rider the
  Saurian Queen, a part) in the Peak. The Djinn, a trope archetype, is the Waste's tier-two
  back-rank caster, the ranks' first purge. Gilgamesh is an elite that wanders: drawn by any
  domain's Fracture one time in three in place of its next own elite and always once its own are
  spent (`ContentDB.next_elite`); every elite is scaled by the tier as a boss is (Ryan, 2
  November), an elite may come again in a later battle, a boss never in a run. Every boss has its own escort at tiers two and three at
  the tier's counts (the King Gel's court at every tier, six at tier three) and stands alone at
  tier one, in the quick campaign too. The stand-ins went to the ranks with a line of recolours
  each at tiers two and three (their cut third moves the twist), the Marsh a massive line of its
  own (the Barrow, Grave and Charnel Giant), and the Bone Wyvern to the Marsh's elites. The
  worms' and the Antlion Queen's bites are Maw and Devour (Swallow is Floraison's word);
  Withdraw is 2, the Tortoise at tier three flagged (the to-do); no foe flees but a loot-runner
  (Ryan's rule of the 2nd), so the Needler's Scatter and the Thief's Flee are struck, Showtime
  the Thief's third. Built for them, on any foe: a follow-up, a steal with its borrowed swing, a swallow
  that lets go once its swallower loses a quarter of its HP (a second machine taken joining the
  first's count), a merge, a drain from the hull, a grudge (`per_kill`), a condition that reads
  a fallen part, a move used once a fight, an escort that names its boss, a boss's armour step a
  tier (`armour_step`: the Tortoise 1, 2, 3), a wandering elite (`wanders`), and a foe's purge
  in content (the Djinn's Unmake); Numbed's third stack goes to every boss. The elites' holes
  (the Peak has none of its own) have a brief for a session (`docs/briefs/elites.md`). Bosses and parts with no pick, and the
  giants, wear rough placeholders stamped "?" (`tools/placeholder_art.py`). The slate stands at
  48 HP at tier one (Ryan: "Whatever you think works best for scaling"). The reads of 30 and 31
  October (`docs/measurements.md`, directions): the default team kills each boss in 4 to 5
  rounds, the stock four in 7 to 12; the fourth machine is the run's biggest step in wear (a
  trio of the same kit loses three to ten times the hull), and in rounds by its role; the
  slate's blanket point of armour costs the small-blow kits about 40% more rounds at tier one;
  the escorts read on the 2nd (`--boss-tiers`, every boss at tiers two and three with its escort
  and alone): most cost a round or two and some hull, three make walls (the Vampire Lord's and the
  Fallen Weapon's at tier three, the Matador's for a trio), since menace does not sort them and a
  boss's own mechanic amplifies them, and the Ruby Colossus was a wall alone at its first numbers
  (its tentacles lightened and slowed on a what-if, and the Lich out of the Lord's escort: landed).
  Found on the way: the balance runner had never set the foe factory (fixed); the test runner
  passes a test that crashes after its first check (the to-do); a second swallow moved the
  first's release (fixed on the 2nd). Settled that evening (Ryan, 2 November): armour only where a
  boss's kit is armour (the Colossus, the Fallen Weapon, the Phantom Train, the Obsidian Tyrant
  and the Tortoise keep a point, the rest none), a follow-up that cannot be Disrupted once
  announced (the chip says so, a Disrupt held over the foe strikes through, the bot values it at
  nothing, a Suppress still takes it), Showtime the Thief's third (a blow at every machine below
  half) and the escorts' moves (Barbed Needlers for the Fallen Weapon's Great Needlers, the Death
  Knight out of the Matador's, Ghosts for the Phantom Train, stokers for the Tyrant at tier
  three). Waiting on Ryan: his marks on the session's placeholders and the elites brief.
- The Storm Petrel and the Giant Petrel fielded (30 October, Ryan: "go for the ready to build ones";
  their briefs retired: `git show d84ad16:docs/briefs/kestrel_shield_spender.md` and
  `kestrel_gun_platform.md`; `docs/rules.md` and the bible's Kestrel row). The Storm Petrel's shield
  pays its weapons' heat as they are spent, the rest reaching the gauge, and the target takes a
  zap of what it paid after the strikes, lost on a kill; its plate takes a point off every blow
  while its shield stands; its lock's Regenerating regains 2 shield a round for three rounds, a
  grant of its own each time. The Giant Petrel banks up to three unspent rerolls while it fights;
  its Immelmann Booster rallies itself or, for three rerolls, gives a spent ally its die again and
  its action; its Spindrift Salvo's kill brings two; its Reheat Uplink empowers an ally and rolls
  its die. The die shows the burn behind the shield's mark ("-2") and, over a foe, the blow joined
  to its zap ("3+2"); the hold says what it burns. The bot reads the burn as shield lost, the zap
  as damage and the regen as hull kept, and weighs looks against actions, a reroll a spend pays or
  brings mid-round worth what the bank carries (`Policy.bank_delta`); the runner tallies actions
  bought and rerolls banked. The Storm Petrel is in Kestrel's tender since, so a start that skips
  Minerva may still be dealt a front. Read at 30 seeds (directions, `docs/measurements.md`): alone
  the Storm Petrel stands in the Armadillo's band and above it on the ladder's recolours, in half
  the rounds, and beside the Puffin about half again the Armadillo's pair on the big foes; the Giant
  Petrel's four reads level with the Lammergeier's in Kestrel's team and over the Swallowtail's in
  Wainwright & Sutler's on every formation, the team its must-pick guard watches at 200 seeds. What
  waits on Ryan: his play of both (the to-do); the Storm Petrel's burn on basics stays as built (31 October).
- The skirmish is one field (29 October, on `claude/jolly-lovelace-scn82y`; Ryan of the looks
  on trial: "it's 100% field, it looks really good"): one floor seen by one level camera from
  behind the machines, the other world painted far under the foes in the domain's palette and
  dressed by the contact hex's ground, our ground near with the display's grid, meeting at a
  ragged dithered seam. The foes stand on their rank's feet line (a winged one over its shadow)
  and breathe planted at the feet; the squad stands in four fixed hexes of the grid, a smaller
  squad's spots dashed and empty, each machine drawn by the floor's own camera and square to the
  foes (the rear three-quarter turned left retired: "their angle is wrong for the field
  perspective"). The layout is the saved setting Skirmish Controls (Ryan: "Leave the layout as
  an option"), Middle by default, Bottom the machines right under the foes. The vista, window
  and holo grounds and the overworld tiles are gone. His second round that day, built: a squad
  of one or two in the middle hexes; the machines turned 15° toward the middle; a quick switch for the
  controls beside the eye, both inside the log's glass; a unit's readout a tap toggle, one at a
  time, translucent (70%) over the arrows it draws, a machine's resting on its gauges; at the
  bottom the field down to the log and the machines lower. His third round asked the red chips to
  brighten: the light #ff7c80 came first, then his try of pure #ff0000 with the arrows bare, and
  his rule that a red or an orange is red and green alone, never blue, heat's orange at #ff6000
  (`docs/measurements.md`). Then the colours went to him (30 October): a debug build's Settings
  → COLOURS sets any named colour by wheel or hex, and his picks come back as COPY text to land
  as the defaults; what fails is a colour over its ground, not two UI colours apart (his words,
  the bible's colour rows). Then the enemy left red (his call the same day: "keep purple for
  enemy activities"): every foe's mark wears the rift's violet #c8a4ff on a deep #2a0e4a edge,
  the rings and the band where a machine could attack from with them; heat reddened to #ff4000,
  since a lighter orange can read as green, good's colour, to him; harm to a unit a red-red
  #ff0000; Volatile's hull cost in the hull's colour; the shield kept, a cooler blue landing on
  the violet under red-green vision (`docs/measurements.md`). His read on the phone is the
  to-do's. His phone read of the map's aliasing (30 October) found the
  machines' textures sampled nearest without their mipmaps, sparkling when drawn small, and no
  anti-aliasing at all on the phone (MSAA leaks there): the textures read their mipmaps now and
  the map's compositor runs FXAA of its own where MSAA cannot, behind a debug AA toggle. His next
  read (the same day: grainy zoomed out, "I don't want the outline to thicken as I zoom in")
  settled the section 12 outline question: the grid's lines and the machines' outline keep one
  width on screen at every zoom, smoothed, the outline drawn round the machines' own layer in the
  compositor (unbroken, through the wall, the Kite outlined too) and the engine's outline retired
  everywhere. The MSAA leak is Godot's, fixed for 4.8 (godotengine/godot#124643); the one-pixel
  creases are what is left a pixel wide, behind a debug TRACES toggle. His phone read: "way
  sharper", the lines the biggest culprit, the creases the grain left and fine with AA on. Then
  every overlay mark held its zoom-1 size at every zoom (his call: "all UI overlay type items
  should hold at one width"), the fine map became permanent with its option gone, and the grid
  went back to its light before the 25 October dimming. His read of those is the to-do's. Then
  the project moved to Godot 4.8-beta2 for the MSAA fix (his call: "Let's update Godot so we can
  get the msaa fix"; 4.8 stable has not shipped, no 4.7 patch carries it): the suite and the
  renders came out the same as on 4.7.2, MSAA is back on the phone, and the import files are in
  4.8's form. Then the anti-aliasing became the player's (his ask: "Can we add an AA mode setting,
  not just for debug?"): SETTINGS → AA MODE, off, FXAA, MSAA 2X or MSAA 4X (the default), in
  place of the debug MSAA and AA toggles, the mipmaps on in every mode. The desk runs 4.8-beta2
  too (30 October, its build on the Pixel); the Pixel's read is the to-do's.
  With main in (30 October), the backdrop took the map's palettes: the Peak's lava orange-red,
  the Marsh's sky a cold night and its pools teal bog water and moss, the lakes the map's water.
  Then (his calls the same evening) the lava kept ("lava looks great"), the GREEN preset went
  minty, #60ffb0, apart from the amber for red-green eyes, and the COLOURS page was cut to what
  is in play: the presets, the enemy's four violets (the routes and the rift's bars and tears
  wear the violet itself) and the meanings; the old other-world drawing in TerrainArt is gone.
  The codex's passive line reads in ink since ("the passive line can go in normal colour"; it
  wore heat's colour, the old accent). Then the keywords, his calls the same evening ("Try bold
  in the colour first, and I'll judge"; "standardize the keyword colours"; "Tapping a keyword is
  exactly what we need"): every term the keywords list defines reads bold in its colour with its
  icon wherever shown text names it (the holds, the readouts, the codex, the list itself), and a
  tap opens its entry beside the word (`KeywordTip`); one table (`Terms`) gives each term its
  icon and its colour group, the die's marks, the chips and the text alike, never the HUD colour
  (Chain moved to heat; Cryo, Suppressed and Guarded to the blue; Exposed's die mark to the
  red-red; Spread, Rapid and the plain shapes to ink). A debug build's KEYWORD INK compares the
  words in ink. Then the bosses' slate came in for its terms (his word: "Fix the missing ones now,
  that's this sessions job"): `claude/brave-cori-fr18de` merged here, Steal and Swallowed in the
  table, and the keywords list's last heading, FOES' MOVES, the keywords a foe's move carries
  (Every Machine, Countdown, Last Act, Follow-up, Swallow, Scorch, Silence, Self-Destruct, Parts),
  each with an icon (Steal, Every Machine and Parts new), the engine's own words (its aim, menace)
  kept out; the slate's swallowed machine's dashed edge drawn round the machine, the field's views
  being wider than their machines, and its boss test reading a domain's first boss of the list
  (it had errored after its first check, unseen, since a domain's bosses became a list). Then his
  call on the dice ("can we just change lock/unlock to hold and double-tap, and tap to inspect for
  dice? That way it's standard across the board"; "And yes remove keywords button"): a tap reads a
  die as it reads a unit, its readout one with the units' and open until closed, so its terms take
  a tap; a double-tap or a hold locks or unlocks, the readouts left as they stand; the waiting
  Swap's die reads on a tap or a hold; KEYWORDS left the bottom row, the list in MENU alone, and
  the codex's panel runs to the foot again. His two follow-ups, agreed the same evening ("Yeah,
  agreed to all"): a die's tap lands once the double-tap window (0.3 s) passes, the face lit from
  the touch meanwhile, so a double-tap's lock never flashes the readout; and a tap on the ground
  sends a waiting Swap home (the first closing an open readout), since only the drag back had set
  it back, unseen; the Swap's keywords-list line says so.
- The pacing session and the foes' fresh start, one build (29 and 30 October; the bible's
  section 4 rows: the three clocks, a stall priced never free, the tears, the whole wall, the
  tier and the ramp; section 9's pack, tally, tiers and boss rows; the brief retired: `git show
  85e28fd:docs/briefs/fresh_start.md`): a pack is a composition on one hex (patrols,
  formations, elites and escorts by tier in `content/factions.json`, partitioned from the
  ladder's lists as placeholders for Ryan's marks; its members listed on a hold, the survivors
  kept by member); the field at the start and the rift's cycle come by the rift's tier, locked
  as it opens, and the live Convergence as the ramp (`sim/ramp.gd`, one table of placeholders:
  the counts, the density, the timer 12 to 8, the tears a peak, the seam's creep, the interval
  step at zero); a peak sends from the rift and from every tear open before it, creeps the seam
  (the bleed's edge) and opens tears on it, far from the other mouths, each armed a peak later;
  a pusher strikes the gate's bar from anywhere along the wall, the floor of ten gone; the
  Rupture meter fills by menace (a foe's heaviest blow plus a quarter of its HP, an elite's
  doubled) toward the tier's Fractures, set from the field's menace at the start, the elites
  emerging at the rift at the Fractures the tier names, the last Fracture or a cleared field
  breaking the seal on a boss that until then joins no fight; salvage at 2 a point of menace and
  Anathema by domain; five elites as placeholder kits (the goblin shaman, the Elder Treant, the
  Leshy, the Old Man of the Desert, the Reaper); the quick campaign's formations and elite
  slots on the compositions; the turtle and the detaching personas and the runner's reads of
  the meter and the mouths; the tears, the seam, the meter's bar, SEALED and the members on
  screen as a first cut (`RIFTGATE_PEAK_DEBUG=1` peaks every enemy turn). Read on the campaign
  runner three ways (`docs/measurements.md`, directions): the field at the start is harder for
  the plain bot (fell 57% where 40%, the wall struck anywhere and the compositions not parted),
  the flood is unread on it (its battles end before the first peak; the turtle's meet them, and
  the turtle loses to the gate), the Rupture comes in a tenth of its battles and never by the
  guard, the tier-one patrols read as a lone starter's fight, and salvage at a won battle banks
  half again what ten a kill did. The timer's 12 is the old clock's number: Claude's lean 8 to
  6, Ryan's word. What waits on his marks is section 12's fresh start item; the composition
  cells on the matrix and his play of the clocks are the to-do's.
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
- A foe's moves keep content's order (30 October): `ContentDB.make_foe`, bringing the first
  attack to the front when a special leads, passed over an attack already in front and moved
  the next, so 25 of the 65 foes loaded out of order (two attacks listed first swapped, as for
  the Lancer, the Augur and the Reaper; a below-half special put first, as for the Black Mage's
  Flare and three of the four bosses'). It now stops at the first attack, two tests in
  `tests/test_content.gd` holding it. The order is the codex's list, the opening intent, the
  order a seeded draw walks (each move's odds unchanged, so only which seed draws it moves)
  and the pattern a Disrupt steps through, which changed for nine (the Antlion Queen, the
  Wyvern, the Red Dragon, the Reaper, the Lancer and the Augur, and the promoted Lancer, Cleric
  and Augur; the rest's old order was a rotation of content's). A saved battle keeps the order
  its foes were saved in. The boss cells at 30 seeds hold their direction (`docs/measurements.md`,
  the foes' move order): no fight's mean over the rows moves more than 2.2 points, the fights
  with no foe it touched come out identical fight for fight, and the three single cells past a
  cell's band read inside it at 200 seeds; no stock kit fields a Disrupt, so the new pattern is
  unread until one does.
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
  posterize grid (his second read: one ground for all was "very monotone"; his third: the
  Waste's and the Marsh's rough wanted more separation, so olive and moss). Each domain also
  has its own water (the Meadow's lake, the Waste's oasis, the Marsh's murk, the Peak's lava,
  orange-red since the yellow read as acid, short of red, a redder lake his pick since the
  enemy's marks went violet on 30 October) and its own
  walls (snowy peaks, red buttes, black crags, volcanoes), each range standing out of the top
  of its hex, drawn after every hex's ground (`DomainGround.draw_walls`). A road follows the
  roads beside it, three road hexes round a corner making a loop with a gap in the middle.
  Every colour is on the posterize grid and scored against its ground by the colourblind
  simulations (`docs/measurements.md`). `RIFTGATE_BLEED_DEBUG=1` paints the whole
  field and `tools/tileset_shot.gd` draws all four. The painted map takes 45 to 120 ms a
  frame to draw on the cloud's CPU, twice at a battle's start; if the phone hitches there, the
  sprites' placement is the part to make cheaper. Next, Ryan's read of them running (the
  to-do). The skirmish's backdrop keeps its palettes beside the tilesets
  (`DomainGround.BACKDROPS`, since `claude/jolly-lovelace-scn82y` took main on 30 October), its
  water each domain's liquid (`DomainGround.LIQUIDS`, which the map's water, its rim and the
  lava's inks read too), so the Peak's lava is orange-red in the fight as on the map and no
  domain paints violet, the Marsh's poison purple gone; a test holds both.
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
  cliff (the Balance bullet). Its elite slots take the lead's elite compositions in turn since 30
  October (the bench hero that stood in went on 27 October, Ryan: "a can of worms"; a domain
  with none, the Peak today, the lead's formation), its formations the compositions in turn;
  from tier two a domain's final may be a battle's boss (Ryan, 25 October), and every boss
  fight brings the tier's escort.
- Bosses scale to the battle's tier (Ryan, 25 and 26 October; the bible's section 9 row, section
  3's row carrying the exception): a domain's boss, a final's hero and the finale's line take
  the tier's HP and attack and bring more escort, drawn from the domain's units of the tier (a
  unit's `tier` in content, one by default: no unit has another yet; a domain's `escort`
  composition at the tier stands in for them when one is written, the hook since 30 October,
  no content yet), in the campaign and the
  quick campaign; the rank and file never scale in place, a tier's units being their own (the
  bible's section 3 row, 28 October). The campaign counts its tiers from the
  Convergence (tier two from 4, tier three from 8, the finale at 12 on tier three's step); every
  number a placeholder.
- Injuries (25 October): one damage state, Ryan's "Cracked is gone". An injury destroys the
  entry the die lands on, at a quarter of the maximum hull, the threshold set by what it asks of
  the player (half was tried and retired within the day: a machine could lose but one piece); a
  wreck loses only what was destroyed. "Never destroyed" is the Reinforced Skeleton's since 31
  October, a Minerva module at tier two, so a stock machine has no such guard. The quick runs on the bot destroy about one to one and a half
  pieces a battle in tiers one and two (`docs/quick_run.md`), at or past section 10's "about one
  a won battle" line where the threshold moves, so the destroyed-is-gone threshold is the
  economy pass's first number to read.
- Content: five makers; 24 chassis, every one runnable since the Petrels' engines (30 October); 81 components,
  0 of them locked; 17 modules; four domains with 53 wildlife (18 at tier one, the three old
  stand-ins and the Barrow Giant among them, the ladder's recolours, the massive lines and the
  Djinn, each tier's compositions partitioned from its list as placeholders) and 7 elites as
  placeholder kits, the slate's twelve bosses and their 5 parts as placeholder kits, and 8
  heroes with their promoted forms; 4 foe moves
  planned (two flees, an interpose, two retaliates and the Lich's Dark Rite). The
  numbers are the stock pass's (22 October, `tools/stock_fills.py`), the four Kestrel machines'
  set by hand at its scale; every one a placeholder.
- Models: every machine's by lowforge; the five Wainwright & Sutler machines' are to judge
  running, on Ryan's notes of 2 and 3 November: the Musk Ox's, the Cassowary's, the Swallowtail's
  and the Whip Scorpion's second rounds and the Cottonmouth's third (its drum turning at idle,
  parked a barrel ahead for each of the ranging act's test shots, only the top barrel's mouth and
  lamp lit with the flash, the strip lit through every spin but the idle; `b.spin(..., step=)` and
  an act's `locks`); the Cassowary's capacitor charges a cell a counted shot and spins while Spun
  Up (`b.count`, `b.spin_held`), the Cottonmouth's mounts hide in its drum
  (`b.pin(..., hidden=True)`), and the to-do's lines say what waits; the Lammergeier's, the
  Skua's, the Puffin's and the Storm Petrel's are the Kestrel second round's picks of 28 October,
  to judge running; the Needletail's and the Giant Petrel's are the first cut of 23 October
  until Ryan's next session (the to-do). Since 28 October (Ryan's brief, `claude/charming-rubin-h954bp`) a
  model names the component each pin's stock part is and the game wears a die against that
  record, so a stock that moves on shows class shapes until the model follows; every model has
  as many pins as its chassis has hardpoints (a test); thirteen models were rebuilt to their
  stock that day (the Kite's wingtip drivers, the Stingray's dome lance, the Dingo's nose ports
  and Translocator, the Armadillo's four ports, flinger rack and seal, the Baboon, and eight
  the stock pass had left on old kit), and reworked on his notes of 29 and 30 October
  (the Kite's drivers as ramjet-guns, their teeth running aft as strakes; the Dingo's rear
  mount on a roof gimbal, its coil threaded and its second antenna gone; the Armadillo's bores
  bored and dark, its weapons sliding along their lines, its seal hiding the irises and
  hunkering, its stack a louvred radiator sunk in each flank's chamfer above the hind hip
  and two near-square vents standing out of the back panel, and a vent on each flank that slides out, glowing orange as the shell
  sinks once to vent, opening and shutting a pair at a time, and dark sealed; every Arsenal cockpit's glass
  lit, the Nemesis's visor flaring white-hot in its fierce acts), to judge running (the to-do). A model may hold a form while its
  machine carries the status of the same name, the form carrying the whole machine and acts of
  its own (the Armadillo's seal; `RIFTGATE_SEAL_DEBUG=1`, or Forms on the hangar's Models tab),
  and a glow must name a part that can light (lowforge refuses one that cannot). Since 25 October every machine's parts are welded at load by material
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

- The elites session (`docs/briefs/elites.md`: the Peak's own elite and a Waste hunter, three a
  domain at least, more wanderers; every elite scaled by the tier since 2 November) and the
  Fracture's prize (the bible's section 12), with the escorts' marks (`docs/bosses_proposal.md`) and the
  promoted forms' one move more for seven of them (`docs/heroes_proposal.md`).
- The planned foe moves (the Lich's Dark Rite among them, a special with a countdown); a
  silence carrier and a purge carrier once Ryan marks them (section 12); the jellyfish's EMP,
  Purge on a capstone's blow (its chassis session).
- Ryan's read of the five Wainwright & Sutler models running (the to-do's lines carry what each
  asks), and his pick of the Giant Petrel's hull (`docs/looks/kestrel_giant3.png`).
- The commander layer, the screens, the economy's verbs and loot (sections 8 and 10).
- Every track a pair (the bible's pair row, 28 October): the five new halves sketched; Hold The Line's
  pair passed on its twenty-seventh round and both halves built into art/audio by the forge's SHIP (10 November: "Full pair for HtL is good to ship"; the battle half as `music_hold_the_line`, playing where the track played, the map half as `music_hold_the_line_map`, unplayed until the engine's pairs), its map half settled on the thirteenth (3 November: "I think
  that's it for this track"): his map picks, X on the violins, U on the clean guitar, the drone
  moved to R, W low with a roll; the map half minimal, the lifts as they were with the riff on the
  soft sub and the tine piano and the first lift's bell calmer (5 November: "Map lifts should keep
  soft sub. it works better"), K's walk on the synth bass over its backing, the climax without the
  harp, the ticking guitar alone on its riff 3 dB up, the bell 3 dB down, the tine piano on Z's riff
  6 dB down and the drone held level from R into Z; its battle half's bass reopened (4 November: "I
  was never 100% satisfied with the driven bass") and now the Omnific, an active bass into the
  modern prog drive (`real_bass.py`), an octave down on the roots everywhere but the lifts and F's
  punchy sub ("Omnific low for everything except C, L, F"), the lifts' riff on the fingers into the
  same drive alone with the leads out ("Fingers for C and L, on the upper octave, just the single
  instrument"), the chug only the rhythm, out of every unison line ("I don't want to use the chug in
  unison lines at all") and 3 dB down in A and N, the drone 3 dB up under A and N ("A and N: keep
  low Omnific, bring drone volume up. Scrap lower octave fifths"); J gone, V and Q kept, K its first
  eight bars at its slower tempo on the drums in between with the plucked string beside the bass on
  its walk, its long crash choked to a second and a half, M as it ships with the crunch synth's line
  on the bass; his picks of the fifteenth ("HTL: omnific power chords option, no backing guitar in
  C, backing guitar up 3db in L, keys lead on L riff"), the Omnific's power chords over the low
  roots in A's back half, B, M and N ("Make sure B and M keep the new voices too"), B's chug hit 3
  dB down with A's and N's; the Omnific on its dirtier drive wherever it plays (6 November: "That
  Omnific voice change is perfect, that's what that voice needs to sound like everywhere it's
  used"), the lifts on their one bass ("scrap the doubling in the lifts, it was better how I had
  it"), the power chords one bass into one amp ("Keep the one bass, one-amp") and over the low roots
  through X, U, W, the climax and Y too ("we need it to fill out M, X, U, W, the climax, and Y"), N
  twice through on the keys lead's power chords an octave under, the map's N with it, X's riff in
  quarter-tones on every voice that plays it, its high C a quarter-tone flat the first time through
  and as written the second (7 November: "I meant the riff for quarter tones"; then "the second quarter
  tone riff with the c, cq, b doesn't work. Let's cut that one"; forge.py's riff reads a voice's own
  notes, a quarter-tone half a semitone), the riff in the Melody Desk for his own writing, the Desk
  bending notes a quarter-tone and drawing 7/8 bars ("have the melody desk support quarter tones? I
  think my writing is bad"; `desk_parts.py --sketch hold_the_line_r22` seeds it), W six beats, the
  keys lead carrying on from its solo into the held note with the basses ("the keys need to continue
  from their solo into the held note after all"), its drums from the first beat's off-beat ("The drums
  'Two beats earlier' in W is good") and a fill building to Bonham's triplets and ending on them ("the speeds that
  you start the fill at, those should be what it ends at"), his triplets and the descending sixteenth
  doubles as the record plays them a lean for any fill (pair_sketches' bonham_triplets,
  descending_doubles: "the spirit of it is in the tom/snare rhythm"), K's walk on the crunch synth
  beside the plucked string 3 dB down ("go with 'The plucked string 3 dB down'"); on trial, another
  voice on X's riff (the lead guitar's power chords, the keys lead's single notes: "I don't like the
  lead single"), X's quarter-tone as a bend up from B ("a quick b-b up- would be how I would play it
  in real life"; forge.py's riff takes a bent note, [from, to, wait, glide] or a path) or pushed and
  let back in triplets into A or B-flat ("b-bup-b-bflat as triplet-8th"), the backing guitar on X's
  riff with the keys lead on its chords ("the keys doing the backing descending chords instead"), both
  over a rock beat (the riff's two bars of 7/8 grouped 4, 4, 4 and 2 eighths, the kick on each group's
  first eighth and the snare on its third: "If each riff repetition is taken as bars of 4-4-4-2"; "Yeah,
  that's exactly right"), the kick on the riff with two snares ending each repetition without a bend,
  X's drums at W's level and its knocks out ("do the W level drums, kick the riff, maybe cut the knock"),
  the half-open and open hats rebuilt as sizzle and taken, X on the loose half-open hat with its knocks,
  W's first eighths on the new open hat louder (pair_sketches' hat_wash: "both those new hat voices are
  so much better"), the fingers bass on eighths under X on E, D, C-sharp, C ("go back to finger bass for X"), L's
  instruments on M's descent ("have the instruments from L join the descent in M") ("Make the kick punch the
  riff ... take back the dressing"; a dressing in three tiers was heard and taken back), W's first eighths on a
  half-open hat (pair_sketches' hat_half, new) or the china from the crash ("so there's no pause
  between the crash and when the drums continue"), then on the open hat louder ("try open hat,
  louder, from the second eighth"); the map's L and M on a clean finger bass ("Change L and
  M from cellos (i think?) to finger bass"), L's tine piano on M's line ("Map M, can the upper voice
  from L join in too?"), its U's sub on the riff ("Map U is what I meant ... you got it right in the
  full pair"), its W six beats.
  A mixing desk on pre-rendered stems was proposed for picking voices without a round and tabled (5
  November: "Tough if it's not completely flexible. That's ok, let's table it for now").
  Night Shift on its thirty-second (10 November: both halves at 96 where the track ships at 94, "Go with 96. 98 is ok but the arpeggios start to muddy"; every arpeggio and the battle half's snare 3 dB down; the intro's own fill kept, "I liked the original fill from I into A more"; the intro's kick, on the bass's rhythm, a set for his ear; the kit dressed, "the amount of dressing is good in your sample", with fills at the transitions, "Can use a few more fills and such, especially during transitions. Almost there"; its tunes locked, "Like the new R. I think that locks the tunes for now"; the head and the lead's section closed; the off-beat piano in the battle half's lead's section and R and out of its head, "Remove the piano from A, keep in C and R"; D's riff on the crunch synth 6 dB down; R's lead a tune that grows, not busier;  the bass on four core pairs of his rhythms, a bar each
  in turn, 4 and 7 sparingly, four cut; R a lead over the grooves, "no unisons", the stop-time out, the
  fingers walking and the top Omnific's lead fancier each pass; the synths' arpeggios between octaves;
  before it the duel on three basses, none trading, a pusher on the
  eighths, a riffer and the top Omnific, "trading was the mistake"; the drive on trial over round twenty-one's half, the
  turns of two bars gone ("the turn taking was a mistake"), a rhythm held eight bars, the bass or the
  crunch synth always on the eighths, the hat on eighths, the kick on the bass's rhythm or one and
  three, no off-beat piano or open hat; 9 November: the dark
  pass and the written bass lines at 96 both retired, "take a step back to the previous version, before both 'darkening' passes, and look
  at the root cause ... more intense, more driving, less chipper"; a set takes the off-beat piano,
  the open hat, the arpeggio and the bouncing bass out of the head one at a time; the map's
  intro without its front and its muted guitar out, his
  call of 4 November: "Map groove sounds better without the muted guitar", its drums 3 dB down in C
  and R, 6 November: "-3db solves it"; the battle half's parts named on the page for his notes, "is
  there a way to subdivide this so I can give you notes on each particular section?"; the battle half a whole
  jam in turns of two bars, 30 October, a bass jam, 4 November: the bass walking on his rhythms with
  the arpeggio or the FM hook, never both, holding three-three-two 6 dB down under the two together,
  the intro on three-three-two, D the piano's turn and the factory's blended over Hold The Line's
  riff as the map's nod with no bass under them ("The bass 3-3-2s in D don't make sense"), R a duel
  between two basses (5 November: "into more of a dueling basses type jam") three times through its
  chords (6 November: "I'm not worried about making this section longer since it's like the climax
  of this track"), the track's and a second an octave over it on the active bass trading two bars,
  a bar, half a bar, a beat, the second's first answer climbing from its root and its falling line
  the second time through ("that line coming from such a high note as the first time it appears is
  jarring"), through two bars of stop-time ("The stop time was cool, we can do more of that
  unexpected kind of thing") and a break where both basses fill in octaves, the hole retired
  ("sounds like a glitch or mistake instead of a stop time"), then together on three-three-two; the
  lower playing on under the upper's answers 3 dB under its own ("don't cut out the lower one when
  the upper comes in"), by the bar in unison or on three-three-two, holding the root under a stop's
  fill and out of the quickest trades ("both have a place"; "keeping the upper exposed on its own
  sometimes is good too"), the upper in chords where the lower doubles it and the end without the
  break on trial; the backing trading the tune under them at one level 3 dB under the basses ("keep
  their volumes consistent so they don't overshadow the basses"; "Keep the backing voices at the
  3db under, that works"), the FM synth out of R and the outro ("sounds like a glitch or alarm going
  off"; "It sounds good when it's being highlighted, if it's just plucking notes in the background
  it just sounds like weird boops"), the lower's unison in one octave or in two both working ("it was
  whether the lower line kept its lower octave unison as well"), the upper on the dirtier Omnific
  ("'upper on the dirtier Omnific' yes"), the two octaves, the upper's chords and both together on
  trial, the plucked string in tune (forge.py's pluck had played every note flat, B5 by 32 cents:
  "it comes across as sounding like the note is flat"), the rhythm guitar in the breakdown's ringing chords alone
  and the lead guitar's lines kept ("Yes, keep the lead guitar. Put the the rhythm guitar back in on
  B"), the plucked string 3 dB down wherever it plays ("Plucked string -3Db is good"), the bass 3 dB
  down everywhere on the fingers into a modern prog drive (`real_bass.py`: "go with the
  fingers-into-a-modern-drive-prog bass you built"), since the modelled basses read as guitars, C's
  long notes, the lead guitar's line, on that bass an octave under the guitar ("wherever there's a
  lead guitar, I want that bass instead playing the high lines"), the synth lines voiced for each
  turn's job, no drone, Hold The Line's drum energy); The Far Bank's map half on its eighth round,
  its flip retired (31 October: the bells calm in the groove and the lift alone, the strings section
  and the climax off the battle's orchestra; 4 November: the tune on the plucked string one note at
  a time in both, 6 dB under the violins' level in the strings section ("6db under good") and at it
  in the climax, the choir back ("that was a mistake"), the climax's swells half as far over their
  floor, the cellos' and the contrabass's lines on the fretless in place of the battle's saw strings
  ("not just sound like the battle half with the percussion taken out"; 5 November: "fretless bass
  wins, as does the 'half as far' option for the climax"), the lift coming in half as far, the
  fretless and the bells 3 dB down there and the choir held level ("In C, let's not swell the volume
  so far, especially for the choir"; 6 November: "the half as far, choir level from the full pair is
  good"), the climax's bells full, the plucked string in tune); the plucked string tuned and shipped (6 November:
  "ship the plucked string fixes everywhere"): the six music tracks built again into art/audio, every
  other sound unchanged (each of SHIP's 80 matched its file byte for byte on the old string first,
  but Night Shift's, built before the stack cymbal's 30 September pass, which it now carries in D),
  and every pair on the page built again on them; those waiting on his ear; then the
  engine (a pair as one synchronized stream, the map choosing the track, the 3 s flip) and each
  picked half into the forge's SHIP table, Hold The Line's first.

## Next, in order

Each a session of its own, with what it reads first; Ryan's play tasks run beside them (the
to-do's Ryan list). First: the 200-seed matrix with the ladder's and the compositions' cells on the desk machine
(the to-do's engine line), since the matrix on file (27 October) predates the ladder, area as
numbered keywords, the blow's order and the compositions; the campaign report (30 October, the
pacing session's plain read) is this head's and the map survey (29 October, the horde wading
and the streets) main's.

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
   on Ryan's answers to its six questions. The cautious persona built 30 October (`--cool-above
   N`) and its first read in the brief and `docs/measurements.md`: on the car's heat grid caution
   costs more than the overheat (more rounds and more hull), so the overheat's price comes before
   the cooling's cut, and cooling 0 bites modestly on a cold die. The overheat's price read as
   what-ifs the same day (a harsher burn, burnout, self-Corrupted: Ryan's calls in the brief):
   each makes the bot ride the maximum and hold, caution never pays, so the form is his call by
   feel. The shield persona built (`--shield-ahead`; since 2 November it reads next round's
   blow as each foe's roll by weight, not this round's pick) and the support ladders read on the
   Puffin bench: flat by tier, no shield, vent or buff beating the gun it replaces in fights
   Kestrel's row wins in three rounds, a bench the fresh start has since replaced (the four
   formations are the compositions', the big bench the slate's eleven bosses; the four entries
   name the heads they ran on). The pricing driver read the factions' retired `spawn` lists
   until 2 November, listing no formation on main since the fresh start; it reads the
   compositions as the runner does now. Next: the equipment ramp on the fresh start's tier-two
   and tier-three formations once Ryan's land, with tier-matched kits and the planner beside the
   greedy, and the shields' and vents' numbers by tier as a fills proposal; the ladders per tier
   on those formations once the ladder lands; the synergy holes as pieces proposed in chat (the
   to-do's design-sessions line); the catalogue's tag pairs. The synergy map is
   `docs/synergy_map.md`, generated.
3. **The foes' fresh start and the pacing session: Ryan's marks and the reads.** Built 30
   October (the How things stand bullet). What waits on him: section 12's fresh start item (the
   five kits' names and numbers, the Peak's elite and a Waste hunter, the compositions'
   partition of each tier's list, the escort compositions, roles, the one rider a domain and
   enemy Shock) and the ramp's numbers, the timer first (Claude's lean 8 to 6,
   `docs/measurements.md`). What reads next: the matrix's composition cells (first, above), his
   play of the clocks on the phone (the to-do's judge line: the tears, the seam, the meter's
   bar, SEALED, `RIFTGATE_PEAK_DEBUG=1`), and the Fracture's prize after the meter is played.
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
   the bosses' calls still open, the slate's twelve landed 30 October); the ramp's numbers on Ryan's word; the battery plan's rest (the props' fade, the 3D at 30); audio;
   art; the commander layer after a balance baseline; onboarding before a phone leaves the desk.

## Pages

Every page lives in Ryan's personal account; the bible, the hangar, the Melody Desk and the
listening page are shared to his work account as Editor, so either account republishes them by
URL (read first). Databases are reachable only from the personal account. A page's link goes
into this file in the same commit as its first publish; the procedures are in `README.md`.

- The bible: https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, republished from
  `docs/design-bible.html` after every change. This file is v0.470 (the track table's rows on Night Shift's
  nineteenth to twenty-third rounds, Hold The Line's seventeenth to twenty-seventh, the fills' lean and The Far Bank's pick of the lift),
  not yet published: a permission check blocked the publish on 6 November as unrequested, so it
  waits on Ryan's go; the live page had not moved. The live page is v0.469 (the
  page's version 482, published 6 November from `ccr-7effd31a-u5z4gw` by a subagent that read the
  live source whole: Hold The Line's set's new rows, the keys lead's power chords and the Omnific a
  bit dirtier, merged row by row onto the live v0.468 another session published, its long wall
  round; over v0.466 at 479: Hold The Line's sixteenth round, his picks; over v0.465 at 478: The Far Bank's
  lift half as far; over v0.464 at 477: Night Shift's duel's
  lower bass and The Far Bank's picks, the date brought to the day; over v0.463 at 476: Hold The
  Line's fifteenth round in its track row; over v0.462 at 475: Night
  Shift's R rewritten as a duel between two basses; over v0.461 at 474:
  Hold The Line's track row rewritten to its fourteenth round; over v0.460 at
  473: Hold The Line's chug down in A and N and its lifts on two basses, merged row
  by row onto the live v0.459 another session published at 472, its row a die entry's passive box,
  Direct's dashes and All Foes' brackets; over v0.458 at 471: Hold The Line's Omnific bass sparing
  F's punchy sub, his correction, merged row by row onto the live v0.457 another session published at 470, its rows the built
  Recommended rows promoted to Decided, the reinforcement phase the mine's alone, Empowered halving
  on both sides and a foe's tags; over v0.456 at 469: the Omnific bass in Hold The Line's track row
  and Night Shift's sixteenth round, merged row by row onto the live v0.455 another session published at 468, its rows the die
  the one draw of the player's turn, no rift closing on its own or stepping up a tier, and a tag
  flavour no mechanic reads; over v0.453 at 466: Night Shift's fifteenth round, Hold The Line's
  throughout as he meant it and The Far Bank's sixth in the track table, merged row by row onto the
  live v0.452 another session published at 465, its rows city defences targeted, Numbed a buff nothing cleanses and its
  bracketed chip, an injury a threshold on bare hull, and whether each Fracture grants a pick; over
  v0.451 at 464, Hold The Line's roots four ways; over v0.450 at 463, published by a subagent that read the live source
  whole: the real basses on trial in Night Shift's and Hold The Line's track rows,
  merged row by row onto the live v0.449 another session published at 462, its rows the standard
  component face, Every Ally and Every Foe, the cooldown a printed cost, the chip rows and END
  TURN asking; over v0.448 at 461, Night Shift's fourteenth round in the track table, the guitar
  that walked the bass's line retired; over v0.447 at 460,
  Night Shift's map half without its muted guitar, his call, and The Far Bank's map half's
  fifth round, three-way merged onto the live v0.446, main's file at
  `d28308e` (459, published from `claude/elites-session` as main took it, over v0.445 at 458 from
  `ccr-c04908be-3r43xf`: the randomness pass's rows and the elites' calls and reads of the day).
  So the live page carries this branch's track rows ahead of main's code until it lands, and the
  other session's v0.449 rows until theirs does.
  The live page may carry rows ahead of main's code while their branches have not landed. The
  version numbers on the publishing branch's file and the live agree after every publish. Before
  republishing, read the live page; if another session moved it, publish a three-way merge onto
  it, row by row rather than line by line (a `<div class="row">` keyed by its lead, each side's
  rows kept, a row both sides changed merged word by word with `git merge-file`; a line-based
  merge of the whole file conflicts on every neighbouring row: `tools/pages/bible_merge.py`, the
  README's command), with the last-published file as the base and the wrapper's first line and
  its trailing `</body></html>` stripped from the saved live source; a page that size counts as
  read only once every line of its saved copy is read, so a subagent can read it and publish the
  merge. With main merged in, the tables script's run is checked against the file's tables before
  it is kept: a row it reverts belongs to a branch not yet landed.
- The hangar page: https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, source `tools/hangar.html`,
  files from `tools/hangar_data.py`'s printed map, republished after every content, model or
  render change with only the files that moved, each checked identical to the last publish's
  before it is replaced and `edits` read first. At the page's version 203 (4 November, from
  `claude/elites-session` as main took it: `content/chassis.json`, `content/components.json`,
  `content/modules.json`, `content/vocabulary.json` and `content/foes.json` as the merged main
  has them, the randomness pass's numbers and names (rolled damage gone, Empowered, the primers,
  Sweep, Purge N) with this branch's elites, each live copy read back and checked identical to
  the last publish's first (the vocabulary and the foes this branch's of 202, the rest main's
  of 195); the page unchanged, `edits` empty), over 202 (4 November, from
  `claude/elites-session`, that evening: the Astromancer's and its four orbs' placeholder sprites
  under `hangar/foes/`, `content/foes.json` and `content/factions.json` with them, `hangar/foes.json`
  counting them; as main took the branch, every content file on the page and `hangar/pins.json`
  were read back and checked identical to the merged repo's, so the landing republished nothing,
  and `tools/hangar.html` is the live page taken whole, which carries another session's motion
  panel without its Melee button ahead of its code), over 201 (4 November, from
  `claude/charming-rubin-h954bp`; `edits` empty): the micro-models in `hangar/motion.js` (a
  launch's flight shapes, flying in the world once it leaves, a landing taken as it leaves) and
  the Swallowtail's and the Musk Ox's rigs and models, onto the 200 another session published
  (its page's foe sprites of 4 November, a branch not yet on main, kept as it stood: the page
  sent was the live one), each checked identical to 198's before it was replaced. At 198 (3 November, from
  `claude/charming-rubin-h954bp`; `edits` empty): Ryan's second notes of that day in
  `hangar/motion.js` (the slump on its feet, flyers and hovers at the skirmish's lift, a fixed
  weapon's turn held through its slice, the route hex by class), the rigs of the Nemesis, the
  Ammit, the Goshawk, the Puffin, the Sparrowhawk, the Cassowary, the Musk Ox, the Swallowtail and
  the Whip Scorpion, and the Nemesis's and the Ammit's models (their fume vents), onto the 197
  another session published (its page the same as 196's), each checked identical to 196's before
  it was replaced; the page and every other file as 197 left them. At 196 (3 November, from
  `claude/charming-rubin-h954bp`; `edits` empty): Ryan's notes of that day in the page and
  `hangar/motion.js` (a lost machine slumping, a fired weapon coming home on the paused stage,
  slices in turn and their wind-ups, the plumes gone at rest, a launched part flying, the Melee
  button retired), onto 195's; the rigs of the Nemesis, the Ammit, the Skua, the Goshawk, the
  Sparrowhawk, the Puffin, the Lammergeier, the Storm Petrel, the Needletail, the Giant Petrel and
  the Stingray, the Lammergeier's, the Puffin's and the Sparrowhawk's models, and the four
  Wainwright & Sutler machines that branch rebuilt for their stock classes as main merged in
  (the Musk Ox, the Cassowary, the Swallowtail, the Whip Scorpion), each checked identical to
  195's before it was replaced; every other file as 195 left it. At 195 (3 November, from
  `claude/affectionate-ramanujan-5d24t6`; `edits` empty): the Cottonmouth's ranging keyed a
  chamber a shot, held still through each flash, and the Models panel redrawn as a machine is
  lost or revived; onto 194, which `claude/charming-rubin-h954bp` merged onto 193 with its melee
  rule (a weapon lunges only as a blade), its motion script taken into `tools/hangar_motion.js`
  whole. At 193 (3 November, from this branch as main took it; `edits` empty): the Cottonmouth's
  third round (its model and rig), `content/vocabulary.json` as main has it (the Ore Plate, the
  hopper's new text and the Petrels' printed rules beside the slate's terms), and the page and
  `hangar/motion.js` three-way merged onto `claude/charming-rubin-h954bp`'s of 192 and committed
  so: this branch's count displays, held and stepped spins, act locks and hidden mounts (a
  hidden mount wears and flares nothing, `Stage.hidden`) and the Models tab's Statuses chips (a
  form or a spin held as its status would hold it, the panel redrawn as either changes) beside
  that branch's halos, weapon-fire acts, blows, losses, plume trial and each mount's declared
  variant and scale, which `tools/hangar.html` and `tools/hangar_motion.js` carry ahead of that
  branch's code. Every other file stays as 192 left it: that branch's round launcher shapes,
  muzzle places, renders' manifest and the models, rigs and renders it rebuilt (the Armadillo's,
  the Goshawk's and the Dingo's at 191; the Honey Badger's, the Prairie Dog's, the Stingray's,
  the Puffin's and the Giant Petrel's at 192), ahead of main, so a publish from main sends none of
  those; `hangar/pins.json` as main has it. Before it: 192 (3 November, from
  `claude/charming-rubin-h954bp`: a blow moves the machine, fixed pieces fire, the plume trial),
  191 (2 November, from `claude/charming-rubin-h954bp`: the round launcher in every maker's metal, the
  Classes tab, the mounts' declared variants and scales, those three machines), 190 (2 November,
  from `claude/brave-cori-fr18de`: the slate's last calls in the foes, the factions and the
  vocabulary), 185 and 184 (2 November, from this branch: the Honey Badger's rework in content,
  the Reinforced Skeleton, the five Wainwright & Sutler models' first cuts and second rounds).
  Its lit parts show as the phone's renderer shows them (29 October: a lit tile is the tile as
  stored times its light, clipped, before the page's own light), the light eased by the power
  1/2.2 as the game eases it so a flare holds its colour (30 October, `MechRig.light`). Every
  file the page reads is fetched with a stamp on the URL past any cache between (28 October,
  after Ryan saw an older round's Skua acts on a reloaded page). Its database (Ryan's saved
  edits, collection `edits`; name candidates, `candidates`) opens only from the personal account.
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
  collections `parts`, re-seeded by `desk_parts.py`, a sketch's by `desk_parts.py --sketch <round>`
  (`parts/sketch_hold_the_line_r22`, Hold The Line's seven), and `melodies`), at its version 8: notes
  bend a quarter-tone either way and bars run in 4/4, 7/8 or 12/8 (7 November).
- The listening page: https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9 (`tools/soundforge/out/fx/`).
- The pair page: https://claude.ai/artifact/19BTqzwbJ4q8qoUxCZNtSW (`tools/soundforge/out/pairs/`,
  built by `pair_sketches.py`, the page `pair_page.html`): each pair on a live switch, Hold The
  Line's run as the game plays it, and the later rounds' pairs and A/B sets (Hold The Line's
  twenty-seventh, the new hats in, the fingers bass's eighths under X, L's instruments on M, passed and shipped, `hold_sketches.py`; Night Shift's thirty-second, at 96, the tunes locked, the kit dressed, the intro's kick to hear, `night_sketches.py`;
  The Far Bank's map half's eighth, its lift settled, `far_sketches.py`; the real basses, `real_bass.py`), every pair on the shipped tracks as built in tune on 6 November, at the page's version 79. The page's version is capped at 256 MiB of files, so a round's new files go up with the old rounds' removals beside them. A round whose files pass a
  publish's 64 MB goes up in two publishes: the new files first under the live page, then the
  new page with the rest, the old round's files removed.
- The engagement sandbox, personal account only: https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg
  (`docs/canvas/engagement-sandbox.html`).
